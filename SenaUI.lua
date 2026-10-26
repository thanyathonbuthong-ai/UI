--[[
	SenaUI Library  (v1.0.0)
	UI Library สำหรับ Roblox ทำเลียนแบบหน้าต่าง "Sena | Steal an Egg" จากภาพ

	โครงสร้าง:
		Library:CreateWindow(opts)            -> Window
		Window:AddTab(opts)                   -> Tab
		Tab:AddSection(opts)                  -> Section   (การ์ดแบบ "Global Chat" ย่อ/ขยายได้)
		Section:AddChat / AddLabel / AddButton / AddToggle / AddSlider / AddInput / AddDropdown

	ไอคอน:
		ไอคอนใน Sidebar เป็น Lucide  -> ใส่เป็นชื่อ ("info", "zap", ...) หรือ rbxassetid ก็ได้
		ชื่อ Lucide จะถูกโหลดผ่าน IconProvider (ลองโหลดอัตโนมัติ ถ้าไม่ได้จะขึ้นเป็นวงกลมแทน)
		ตั้งเองได้:  Library.Icons["info"] = "rbxassetid://123"   หรือ   Library.IconProvider = function(name) ... end
]]

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")

local Library = {
	Version = "1.0.0",
	Icons = {},          -- ชื่อไอคอน -> rbxassetid (กำหนดเอง)
	IconProvider = nil,  -- function(name) -> string | {id, {ImageRectSize=, ImageRectPosition=}}
	Theme = {
		Window      = Color3.fromRGB(14, 14, 16),
		Sidebar     = Color3.fromRGB(17, 17, 19),
		Card        = Color3.fromRGB(20, 20, 22),
		CardStroke  = Color3.fromRGB(31, 31, 35),
		Border      = Color3.fromRGB(38, 38, 42),
		Divider     = Color3.fromRGB(28, 28, 32),
		Field       = Color3.fromRGB(18, 18, 20),
		FieldStroke = Color3.fromRGB(36, 36, 40),
		Pill        = Color3.fromRGB(25, 25, 28),
		Hover       = Color3.fromRGB(27, 27, 30),
		Off         = Color3.fromRGB(40, 40, 44),
		Text        = Color3.fromRGB(240, 240, 243),
		TextDim     = Color3.fromRGB(152, 152, 160),
		TextMute    = Color3.fromRGB(104, 104, 112),
		MsgName     = Color3.fromRGB(158, 158, 165),
		MsgText     = Color3.fromRGB(226, 226, 230),
		Accent      = Color3.fromRGB(245, 245, 247),
		AccentText  = Color3.fromRGB(14, 14, 16),
		Scroll      = Color3.fromRGB(72, 72, 78),
	},
}

local CHAT_LINE_HEIGHT = 1.15 -- ปรับถ้าอยากให้ระยะบรรทัดแชทห่าง/แคบขึ้น

------------------------------------------------------------------------
-- Helpers
------------------------------------------------------------------------
local FONT_FAMILY = "rbxasset://fonts/families/GothamSSm.json"
local function font(weight)
	return Font.new(FONT_FAMILY, weight or Enum.FontWeight.Regular)
end

local function New(class, props, children)
	local obj = Instance.new(class)
	local parent
	for k, v in pairs(props or {}) do
		if k == "Parent" then parent = v else obj[k] = v end
	end
	for _, c in ipairs(children or {}) do c.Parent = obj end
	if parent then obj.Parent = parent end
	return obj
end

local function Corner(r)
	return New("UICorner", {CornerRadius = UDim.new(0, r)})
end

local function Stroke(color, thickness)
	return New("UIStroke", {
		Color = color, Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function Pad(l, r, t, b)
	return New("UIPadding", {
		PaddingLeft = UDim.new(0, l or 0), PaddingRight = UDim.new(0, r or 0),
		PaddingTop = UDim.new(0, t or 0), PaddingBottom = UDim.new(0, b or 0),
	})
end

local function Tween(obj, props, t)
	TweenService:Create(obj, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function Label(props)
	local d = {
		BackgroundTransparency = 1, BorderSizePixel = 0, Text = "",
		TextColor3 = Library.Theme.Text, TextSize = 12, FontFace = font(),
		TextXAlignment = Enum.TextXAlignment.Left,
	}
	for k, v in pairs(props) do d[k] = v end
	return New("TextLabel", d)
end

local function safe(fn, ...)
	if type(fn) == "function" then task.spawn(fn, ...) end
end

local function esc(s)
	return (tostring(s):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function hex(c)
	return string.format("#%02x%02x%02x",
		math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end

local function isPress(i)
	return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end
local function isMove(i)
	return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch
end

local function getParent()
	local ok, ui = pcall(function() return gethui and gethui() end)
	if ok and ui then return ui end
	local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
	if ok2 and cg then
		local probe = Instance.new("Folder")
		local writable = pcall(function() probe.Parent = cg end)
		probe:Destroy()
		if writable then return cg end
	end
	return Players.LocalPlayer:WaitForChild("PlayerGui")
end

------------------------------------------------------------------------
-- Icons (Lucide ผ่าน provider / rbxassetid, ถ้าไม่มีจะเป็นวงกลม)
------------------------------------------------------------------------
local providerLoaded = false
local function getProvider()
	if Library.IconProvider then return Library.IconProvider end
	if providerLoaded then return nil end
	providerLoaded = true
	local ok, mod = pcall(function()
		local src = game:HttpGet("https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua")
		return loadstring(src)()
	end)
	if ok and type(mod) == "table" and mod.Icon then
		pcall(function() if mod.SetIconsType then mod.SetIconsType("lucide") end end)
		Library.IconProvider = function(name) return mod.Icon(name) end
	end
	return Library.IconProvider
end

local function toAsset(id)
	if type(id) == "number" then return "rbxassetid://" .. id end
	return id
end

local function resolveIcon(icon)
	if icon == nil or icon == "" then return nil end
	if type(icon) == "number" then return {Image = toAsset(icon)} end
	if type(icon) == "string" and (icon:find("^rbxassetid://") or icon:find("^rbxasset://")) then
		return {Image = icon}
	end
	local custom = Library.Icons[icon]
	if custom then
		if type(custom) == "number" or (type(custom) == "string" and custom:find("^rbxasset")) then
			return {Image = toAsset(custom)}
		end
	end
	local provider = getProvider()
	if provider then
		local ok, r = pcall(provider, icon)
		if ok and r then
			if type(r) == "string" or type(r) == "number" then return {Image = toAsset(r)} end
			if type(r) == "table" then
				local id = r.Image or r.Id or r[1]
				local rect = (type(r[2]) == "table" and r[2]) or r
				local size = rect.ImageRectSize or rect.RectSize
				local off = rect.ImageRectPosition or rect.ImageRectOffset or rect.RectOffset
				if id then
					return {
						Image = toAsset(id),
						RectSize = typeof(size) == "Vector2" and size or nil,
						RectOffset = typeof(off) == "Vector2" and off or nil,
					}
				end
			end
		end
	end
	return nil
end

-- position == false -> ไม่จัดกึ่งกลาง (ใช้ใน UIListLayout)
local function MakeIcon(parent, icon, size, color, position)
	local holder = New("Frame", {
		BackgroundTransparency = 1, Size = UDim2.fromOffset(size, size),
		AnchorPoint = Vector2.new(0.5, 0.5), Position = position or UDim2.fromScale(0.5, 0.5),
		Parent = parent,
	})
	if position == false then
		holder.AnchorPoint = Vector2.new(0, 0)
		holder.Position = UDim2.new()
	end
	local img, ring
	local data = resolveIcon(icon)
	if data then
		img = New("ImageLabel", {
			BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
			Image = data.Image, ImageColor3 = color, Parent = holder,
		})
		if data.RectSize then img.ImageRectSize = data.RectSize end
		if data.RectOffset then img.ImageRectOffset = data.RectOffset end
	else
		local d = math.floor(size * 0.8)
		ring = New("Frame", {
			BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(d, d), Parent = holder,
		}, {Corner(d), Stroke(color, 1.5)})
	end
	local obj = {Frame = holder}
	function obj:SetColor(c)
		if img then img.ImageColor3 = c end
		if ring then ring:FindFirstChildOfClass("UIStroke").Color = c end
	end
	return obj
end

------------------------------------------------------------------------
-- Glyphs ที่วาดเอง (chevron / search / minimize / close) ไม่ต้องพึ่ง asset
------------------------------------------------------------------------
local function Bar(parent, w, h, x, y, rot, color)
	return New("Frame", {
		BackgroundColor3 = color, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(w, h), Position = UDim2.fromOffset(x, y), Rotation = rot or 0,
		Parent = parent,
	})
end

local function Chevron(parent, color)
	local holder = New("Frame", {
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(12, 12), Position = UDim2.fromScale(0.5, 0.5), Parent = parent,
	})
	local bars = {Bar(holder, 7, 2, 3.5, 5.5, 45, color), Bar(holder, 7, 2, 8.5, 5.5, -45, color)}
	return {Frame = holder, SetColor = function(_, c) for _, b in ipairs(bars) do b.BackgroundColor3 = c end end}
end

local function SearchGlyph(parent, color)
	local holder = New("Frame", {
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(16, 16), Position = UDim2.fromScale(0.5, 0.5), Parent = parent,
	})
	local ring = New("Frame", {
		BackgroundTransparency = 1, Size = UDim2.fromOffset(10, 10), Position = UDim2.fromOffset(1, 1), Parent = holder,
	}, {Corner(10), Stroke(color, 1.5)})
	local handle = Bar(holder, 5, 2, 12, 12, 45, color)
	return {Frame = holder, SetColor = function(_, c)
		ring:FindFirstChildOfClass("UIStroke").Color = c
		handle.BackgroundColor3 = c
	end}
end

local function MinimizeGlyph(parent, color)
	local holder = New("Frame", {
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(12, 12), Position = UDim2.fromScale(0.5, 0.5), Parent = parent,
	})
	local bar = Bar(holder, 10, 2, 6, 6, 0, color)
	return {Frame = holder, SetColor = function(_, c) bar.BackgroundColor3 = c end}
end

local function CloseGlyph(parent, color)
	local holder = New("Frame", {
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(14, 14), Position = UDim2.fromScale(0.5, 0.5), Parent = parent,
	})
	local bars = {Bar(holder, 14, 2, 7, 7, 45, color), Bar(holder, 14, 2, 7, 7, -45, color)}
	return {Frame = holder, SetColor = function(_, c) for _, b in ipairs(bars) do b.BackgroundColor3 = c end end}
end

------------------------------------------------------------------------
-- Window
------------------------------------------------------------------------
function Library:CreateWindow(opts)
	opts = opts or {}
	local T = self.Theme
	local Window = {Tabs = {}, CurrentTab = nil, _conns = {}, _query = ""}

	local function connect(signal, fn)
		local c = signal:Connect(fn)
		table.insert(Window._conns, c)
		return c
	end

	local gui = New("ScreenGui", {
		Name = opts.GuiName or "SenaUI", ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true, DisplayOrder = 999,
	})
	pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
	gui.Parent = getParent()
	Window.Gui = gui

	local W, H = 840, 564
	local SIDEBAR_W, HEADER_H, BAR_H = 170, 51, 44

	local Main = New("Frame", {
		Name = "Main", BackgroundColor3 = T.Window, BorderSizePixel = 0, ClipsDescendants = true,
		Size = UDim2.fromOffset(W, H), Position = UDim2.new(0.5, -W / 2, 0.5, -H / 2), Parent = gui,
	}, {Corner(10), Stroke(T.Border, 1)})
	Window.Main = Main

	----------------------------------------------------------------
	-- Sidebar
	----------------------------------------------------------------
	local Sidebar = New("Frame", {
		Name = "Sidebar", BackgroundColor3 = T.Sidebar, BorderSizePixel = 0,
		Size = UDim2.new(0, SIDEBAR_W, 1, -BAR_H), Parent = Main,
	})
	New("Frame", { -- เส้นแบ่ง sidebar
		BackgroundColor3 = T.Divider, BorderSizePixel = 0,
		Position = UDim2.fromOffset(SIDEBAR_W, 0), Size = UDim2.new(0, 1, 1, -BAR_H), Parent = Main,
	})

	local Logo
	if opts.Logo then
		Logo = New("ImageLabel", {
			BackgroundTransparency = 1, Image = toAsset(opts.Logo),
			Position = UDim2.fromOffset(18, 21), Size = UDim2.fromOffset(24, 24), Parent = Sidebar,
		}, {Corner(12)})
	else
		Logo = New("Frame", {
			BackgroundColor3 = Color3.fromRGB(30, 30, 33), BorderSizePixel = 0,
			Position = UDim2.fromOffset(18, 21), Size = UDim2.fromOffset(24, 24), Parent = Sidebar,
		}, {Corner(12)})
		Label({
			Text = "S", FontFace = font(Enum.FontWeight.Bold), TextSize = 15,
			TextColor3 = Color3.fromRGB(150, 150, 158), TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.fromScale(1, 1), Parent = Logo,
		})
	end
	Label({
		Text = opts.Title or "Sena", FontFace = font(Enum.FontWeight.Bold), TextSize = 15,
		Position = UDim2.fromOffset(53, 19), Size = UDim2.new(1, -60, 0, 18), Parent = Sidebar,
	})
	Label({
		Text = opts.Subtitle or "", TextSize = 11, TextColor3 = T.TextMute,
		Position = UDim2.fromOffset(53, 38), Size = UDim2.new(1, -60, 0, 13), Parent = Sidebar,
	})

	local TabList = New("Frame", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromScale(1, 1), Parent = Sidebar,
	})

	----------------------------------------------------------------
	-- Header (title / desc / search / min / close)
	----------------------------------------------------------------
	local Header = New("Frame", {
		Name = "Header", BackgroundTransparency = 1,
		Position = UDim2.fromOffset(SIDEBAR_W + 1, 0), Size = UDim2.new(1, -(SIDEBAR_W + 1), 0, HEADER_H),
		Parent = Main,
	})
	New("Frame", {
		BackgroundColor3 = T.Divider, BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, HEADER_H - 1), Size = UDim2.new(1, 0, 0, 1), Parent = Header,
	})
	local PageTitle = Label({
		FontFace = font(Enum.FontWeight.Bold), TextSize = 14,
		Position = UDim2.fromOffset(19, 11), Size = UDim2.new(0, 320, 0, 18), Parent = Header,
	})
	local PageDesc = Label({
		TextSize = 11, TextColor3 = T.TextMute,
		Position = UDim2.fromOffset(19, 29), Size = UDim2.new(0, 360, 0, 14), Parent = Header,
	})

	-- search
	local SearchBox = New("Frame", {
		BackgroundColor3 = T.Field, BorderSizePixel = 0, AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -81, 0, 11), Size = UDim2.fromOffset(182, 32), Parent = Header,
	}, {Corner(7), Stroke(T.FieldStroke)})
	local sIcon = SearchGlyph(SearchBox, T.TextMute)
	sIcon.Frame.Position = UDim2.fromOffset(18, 16)
	local SearchInput = New("TextBox", {
		BackgroundTransparency = 1, Text = "", PlaceholderText = "Search", PlaceholderColor3 = T.TextMute,
		TextColor3 = T.Text, TextSize = 12, FontFace = font(), ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(35, 0), Size = UDim2.new(1, -45, 1, 0), Parent = SearchBox,
	})

	-- min / close
	local function ControlButton(x, glyphFn, onClick)
		local b = New("TextButton", {
			Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x, 27),
			Size = UDim2.fromOffset(26, 26), Parent = Header,
		})
		local g = glyphFn(b, T.TextDim)
		b.MouseEnter:Connect(function() g:SetColor(T.Text) end)
		b.MouseLeave:Connect(function() g:SetColor(T.TextDim) end)
		b.MouseButton1Click:Connect(onClick)
		return b
	end
	ControlButton(609, MinimizeGlyph, function() Window:Toggle() end)
	ControlButton(642, CloseGlyph, function() Window:Destroy() end)

	-- drag
	do
		local dragging, dragStart, startPos
		connect(Header.InputBegan, function(i)
			if isPress(i) then
				dragging, dragStart, startPos = true, i.Position, Main.Position
				i.Changed:Connect(function()
					if i.UserInputState == Enum.UserInputState.End then dragging = false end
				end)
			end
		end)
		connect(UserInputService.InputChanged, function(i)
			if dragging and isMove(i) then
				local d = i.Position - dragStart
				Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end)
	end

	----------------------------------------------------------------
	-- Content
	----------------------------------------------------------------
	local Content = New("Frame", {
		Name = "Content", BackgroundTransparency = 1, ClipsDescendants = true,
		Position = UDim2.fromOffset(SIDEBAR_W + 1, HEADER_H),
		Size = UDim2.new(1, -(SIDEBAR_W + 1), 1, -(HEADER_H + BAR_H)), Parent = Main,
	})

	----------------------------------------------------------------
	-- Bottom bar (discord / executor / fps / version)
	----------------------------------------------------------------
	local Bar_ = New("Frame", {
		Name = "BottomBar", BackgroundColor3 = T.Sidebar, BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -BAR_H), Size = UDim2.new(1, 0, 0, BAR_H), Parent = Main,
	})
	New("Frame", {
		BackgroundColor3 = T.Divider, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 1), Parent = Bar_,
	})

	local function Pill(parent, icon, text)
		local pill = New("Frame", {
			BackgroundColor3 = T.Pill, BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 28), Parent = parent,
		}, {
			Corner(7), Pad(12, 14, 0, 0),
			New("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		})
		if icon then
			local ic = MakeIcon(pill, icon, 14, T.TextDim, false)
			ic.Frame.LayoutOrder = 1
		end
		local lbl = Label({
			Text = text, TextColor3 = T.TextDim, TextSize = 12, FontFace = font(Enum.FontWeight.Medium),
			AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), LayoutOrder = 2, Parent = pill,
		})
		return pill, lbl
	end

	local left = New("Frame", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 10),
		AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 28), Parent = Bar_,
	}, {New("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8)})})
	Pill(left, opts.DiscordIcon or "message-circle", opts.Discord or "dsc.gg/senahub")

	local right = New("Frame", {
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -13, 0, 10),
		AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 28), Parent = Bar_,
	}, {New("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})})

	local exec = opts.Executor
	if not exec then
		local ok, n = pcall(function() return identifyexecutor and identifyexecutor() end)
		exec = (ok and n) or "Unknown"
	end
	local pExec = Pill(right, "terminal", "Executor : " .. tostring(exec)); pExec.LayoutOrder = 1
	local pFps, fpsLabel = Pill(right, "activity", "-- FPS"); pFps.LayoutOrder = 2
	local pVer = Pill(right, nil, opts.Version or "v1.0"); pVer.LayoutOrder = 3
	pVer:FindFirstChildOfClass("UIPadding").PaddingLeft = UDim.new(0, 14)

	do -- FPS counter
		local frames, last = 0, os.clock()
		connect(RunService.RenderStepped, function()
			frames += 1
			local now = os.clock()
			if now - last >= 0.5 then
				fpsLabel.Text = math.floor(frames / (now - last) + 0.5) .. " FPS"
				frames, last = 0, now
			end
		end)
	end

	----------------------------------------------------------------
	-- Search filter
	----------------------------------------------------------------
	local function applyFilter()
		local tab, q = Window.CurrentTab, Window._query
		if not tab then return end
		for _, sec in ipairs(tab.Sections) do
			if sec.NoSearch or q == "" then
				sec.Card.Visible = true
				for _, e in ipairs(sec.Elements) do e.Frame.Visible = true end
			else
				local secMatch = sec.Name:lower():find(q, 1, true) ~= nil
				local any = false
				for _, e in ipairs(sec.Elements) do
					local m = secMatch or e.Name:lower():find(q, 1, true) ~= nil
					e.Frame.Visible = m
					any = any or m
				end
				sec.Card.Visible = any
			end
		end
	end
	connect(SearchInput:GetPropertyChangedSignal("Text"), function()
		Window._query = SearchInput.Text:lower()
		applyFilter()
	end)

	----------------------------------------------------------------
	-- Window API
	----------------------------------------------------------------
	function Window:Toggle(state)
		if state == nil then state = not Main.Visible end
		Main.Visible = state
	end

	function Window:Destroy()
		for _, c in ipairs(self._conns) do pcall(function() c:Disconnect() end) end
		gui:Destroy()
	end

	function Window:SelectTab(tab)
		if type(tab) == "string" then
			for _, t in ipairs(self.Tabs) do if t.Name == tab then tab = t break end end
		end
		if type(tab) ~= "table" then return end
		for _, t in ipairs(self.Tabs) do t:_setActive(t == tab) end
		self.CurrentTab = tab
		PageTitle.Text = tab.Title
		PageDesc.Text = tab.Description
		applyFilter()
	end

	function Window:AddTab(o)
		o = type(o) == "string" and {Name = o} or (o or {})
		local index = #self.Tabs + 1
		local Tab = {
			Name = o.Name or ("Tab " .. index), Title = o.Title or o.Name or ("Tab " .. index),
			Description = o.Description or "", Sections = {}, Window = self, _active = false,
		}
		local y = 72 + math.floor((index - 1) * 39.5 + 0.5)

		local Btn = New("TextButton", {
			Name = Tab.Name, Text = "", AutoButtonColor = false, BackgroundColor3 = T.Hover,
			BackgroundTransparency = 1, BorderSizePixel = 0,
			Position = UDim2.fromOffset(10, y), Size = UDim2.fromOffset(150, 36), Parent = TabList,
		}, {Corner(6)})
		local Indicator = New("Frame", {
			BackgroundColor3 = T.Accent, BackgroundTransparency = 1, BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 10), Size = UDim2.fromOffset(2, 16), Parent = Btn,
		}, {Corner(1)})
		local Icon = MakeIcon(Btn, o.Icon, 16, T.TextDim, UDim2.fromOffset(20, 18))
		local Text = Label({
			Text = Tab.Name, TextSize = 13, FontFace = font(Enum.FontWeight.Medium), TextColor3 = T.TextDim,
			Position = UDim2.fromOffset(39, 0), Size = UDim2.new(1, -45, 1, 0), Parent = Btn,
		})

		local Page = New("ScrollingFrame", {
			Name = Tab.Name, Visible = false, BackgroundTransparency = 1, BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y,
			ScrollBarThickness = 3, ScrollBarImageColor3 = T.Scroll, ElasticBehavior = Enum.ElasticBehavior.Never,
			Parent = Content,
		}, {
			Pad(13, 13, 18, 13),
			New("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder}),
		})
		Tab.Button, Tab.Page = Btn, Page

		function Tab:_setActive(on)
			self._active = on
			Page.Visible = on
			Tween(Btn, {BackgroundTransparency = on and 0 or 1})
			Tween(Indicator, {BackgroundTransparency = on and 0 or 1})
			Tween(Text, {TextColor3 = on and T.Text or T.TextDim})
			Icon:SetColor(on and T.Text or T.TextDim)
		end

		Btn.MouseEnter:Connect(function()
			if not Tab._active then
				Tween(Btn, {BackgroundTransparency = 0.55})
				Tween(Text, {TextColor3 = T.Text})
				Icon:SetColor(T.Text)
			end
		end)
		Btn.MouseLeave:Connect(function()
			if not Tab._active then
				Tween(Btn, {BackgroundTransparency = 1})
				Tween(Text, {TextColor3 = T.TextDim})
				Icon:SetColor(T.TextDim)
			end
		end)
		Btn.MouseButton1Click:Connect(function() Window:SelectTab(Tab) end)

		------------------------------------------------------------
		-- Section
		------------------------------------------------------------
		function Tab:AddSection(so)
			so = type(so) == "string" and {Name = so} or (so or {})
			local Section = {Name = so.Name or "Section", Elements = {}, Tab = Tab, NoSearch = false}
			local collapsible = so.Collapsible ~= false
			local open = so.Open ~= false

			local Card = New("Frame", {
				Name = Section.Name, BackgroundColor3 = T.Card, BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = #Tab.Sections + 1, Parent = Page,
			}, {Corner(8), Stroke(T.CardStroke), New("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder})})
			Section.Card = Card

			local Head = New("TextButton", {
				Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 40), LayoutOrder = 1, Parent = Card,
			})
			MakeIcon(Head, so.Icon or "message-circle", 16, T.TextDim, UDim2.fromOffset(21, 20))
			Label({
				Text = Section.Name, FontFace = font(Enum.FontWeight.SemiBold), TextSize = 13,
				Position = UDim2.fromOffset(39, 0), Size = UDim2.new(1, -80, 1, 0), Parent = Head,
			})
			local chev
			if collapsible then
				chev = Chevron(Head, T.TextDim)
				chev.Frame.Position = UDim2.new(1, -20, 0.5, 0)
			end

			local Body = New("Frame", {
				Name = "Body", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Visible = open, Parent = Card,
			}, {Pad(12, 12, 0, 12), New("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder})})
			if chev and not open then chev.Frame.Rotation = -90 end

			function Section:SetOpen(state)
				open = state
				Body.Visible = state
				if chev then Tween(chev.Frame, {Rotation = state and 0 or -90}) end
			end
			if collapsible then
				Head.MouseButton1Click:Connect(function() Section:SetOpen(not open) end)
			end

			local order = 0
			local function nextOrder() order += 1 return order end
			local function register(frame, name)
				table.insert(Section.Elements, {Frame = frame, Name = tostring(name or "")})
			end
			local function Row(h)
				return New("Frame", {
					BackgroundColor3 = T.Field, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, h),
					LayoutOrder = nextOrder(), Parent = Body,
				}, {Corner(6), Stroke(T.FieldStroke)})
			end

			--------------------------------------------------------
			-- Chat  (Live Chat + log + input + Send)
			--------------------------------------------------------
			function Section:AddChat(co)
				co = co or {}
				Section.NoSearch = true
				local Chat = {Messages = {}, Max = co.MaxMessages or 200, OnSend = co.OnSend or co.Callback}

				local Root = New("Frame", {
					Name = "Chat", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 384),
					LayoutOrder = nextOrder(), Parent = Body,
				})
				Label({
					Text = co.Title or "Live Chat", FontFace = font(Enum.FontWeight.Medium),
					Position = UDim2.fromOffset(13, 6), Size = UDim2.new(0, 220, 0, 16), Parent = Root,
				})
				local Online = Label({
					Text = "· " .. tostring(co.Online or 0) .. " online", TextSize = 11, TextColor3 = T.TextDim,
					TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(1, -11, 0, 6), Size = UDim2.fromOffset(200, 16), Parent = Root,
				})

				local Log = New("ScrollingFrame", {
					BackgroundColor3 = T.Window, BorderSizePixel = 0,
					Position = UDim2.fromOffset(4, 30), Size = UDim2.new(1, -8, 0, 311),
					CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
					ScrollBarThickness = 3, ScrollBarImageColor3 = T.Scroll,
					ElasticBehavior = Enum.ElasticBehavior.Never, Parent = Root,
				}, {
					Corner(6), Pad(12, 14, 4, 4),
					New("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder}),
				})

				local InputWrap = New("Frame", {
					BackgroundColor3 = T.Field, BorderSizePixel = 0,
					Position = UDim2.fromOffset(7, 345), Size = UDim2.new(1, -90, 0, 30), Parent = Root,
				}, {Corner(6), Stroke(T.FieldStroke)})
				local Box = New("TextBox", {
					BackgroundTransparency = 1, Text = "", PlaceholderText = co.Placeholder or "Type a message...",
					PlaceholderColor3 = T.TextMute, TextColor3 = T.Text, TextSize = 12, FontFace = font(),
					ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
					Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -20, 1, 0), Parent = InputWrap,
				})
				local Send = New("TextButton", {
					Text = "Send", AutoButtonColor = false, BackgroundColor3 = T.Accent, BorderSizePixel = 0,
					TextColor3 = T.AccentText, TextSize = 12, FontFace = font(Enum.FontWeight.SemiBold),
					Position = UDim2.new(1, -75, 0, 345), Size = UDim2.fromOffset(69, 30), Parent = Root,
				}, {Corner(6)})
				Send.MouseEnter:Connect(function() Tween(Send, {BackgroundColor3 = Color3.fromRGB(215, 215, 220)}) end)
				Send.MouseLeave:Connect(function() Tween(Send, {BackgroundColor3 = T.Accent}) end)

				local function scrollBottom()
					RunService.Heartbeat:Wait()
					Log.CanvasPosition = Vector2.new(0, math.max(0, Log.AbsoluteCanvasSize.Y))
				end

				function Chat:AddMessage(name, text, tag)
					local nearBottom = Log.CanvasPosition.Y + Log.AbsoluteWindowSize.Y >= Log.AbsoluteCanvasSize.Y - 10
					local head = esc(name) .. (tag and (" (" .. esc(tag) .. ")") or "")
					local rich = string.format('<font color="%s"><b>%s</b></font><font color="%s"> : %s</font>',
						hex(T.MsgName), head, hex(T.MsgText), esc(text))
					local m = Label({
						Text = rich, RichText = true, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
						LineHeight = CHAT_LINE_HEIGHT, AutomaticSize = Enum.AutomaticSize.Y,
						Size = UDim2.new(1, 0, 0, 0), LayoutOrder = #Chat.Messages + 1 + (Chat._offset or 0), Parent = Log,
					})
					table.insert(Chat.Messages, m)
					if #Chat.Messages > Chat.Max then
						Chat.Messages[1]:Destroy()
						table.remove(Chat.Messages, 1)
						Chat._offset = (Chat._offset or 0) + 1
					end
					if nearBottom then task.spawn(scrollBottom) end
					return m
				end

				function Chat:Clear()
					for _, m in ipairs(Chat.Messages) do m:Destroy() end
					table.clear(Chat.Messages)
				end

				function Chat:SetOnline(n)
					Online.Text = "· " .. tostring(n) .. " online"
				end

				local function submit()
					local text = Box.Text:match("^%s*(.-)%s*$")
					if text == "" then return end
					Box.Text = ""
					if Chat.OnSend then
						safe(Chat.OnSend, text, Chat)
					else
						local lp = Players.LocalPlayer
						Chat:AddMessage(lp and lp.Name or "You", text)
					end
				end
				Send.MouseButton1Click:Connect(submit)
				Box.FocusLost:Connect(function(enter) if enter then submit() end end)

				Chat.Frame, Chat.Log, Chat.Input = Root, Log, Box
				return Chat
			end

			--------------------------------------------------------
			-- Label / Button
			--------------------------------------------------------
			function Section:AddLabel(text)
				local l = Label({
					Text = tostring(text), TextColor3 = T.TextDim, TextWrapped = true,
					AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 16),
					LayoutOrder = nextOrder(), Parent = Body,
				})
				register(l, text)
				local obj = {Frame = l}
				function obj:SetText(t) l.Text = tostring(t) end
				return obj
			end

			function Section:AddButton(bo)
				bo = type(bo) == "string" and {Name = bo} or (bo or {})
				local b = New("TextButton", {
					Text = bo.Name or "Button", AutoButtonColor = false, FontFace = font(Enum.FontWeight.Medium),
					TextSize = 12, TextColor3 = T.Text, BackgroundColor3 = T.Pill, BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 34), LayoutOrder = nextOrder(), Parent = Body,
				}, {Corner(6), Stroke(T.FieldStroke)})
				b.MouseEnter:Connect(function() Tween(b, {BackgroundColor3 = T.Hover}) end)
				b.MouseLeave:Connect(function() Tween(b, {BackgroundColor3 = T.Pill}) end)
				b.MouseButton1Click:Connect(function() safe(bo.Callback) end)
				register(b, bo.Name)
				local obj = {Frame = b}
				function obj:SetText(t) b.Text = tostring(t) end
				return obj
			end

			--------------------------------------------------------
			-- Toggle
			--------------------------------------------------------
			function Section:AddToggle(to)
				to = type(to) == "string" and {Name = to} or (to or {})
				local row = Row(36)
				Label({Text = to.Name or "Toggle", Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -70, 1, 0), Parent = row})
				local track = New("Frame", {
					BackgroundColor3 = T.Off, BorderSizePixel = 0, AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(34, 18), Parent = row,
				}, {Corner(9)})
				local knob = New("Frame", {
					BackgroundColor3 = T.TextDim, BorderSizePixel = 0,
					Position = UDim2.new(0, 3, 0.5, -6), Size = UDim2.fromOffset(12, 12), Parent = track,
				}, {Corner(6)})
				local hit = New("TextButton", {
					Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = row,
				})

				local obj = {Frame = row, Value = to.Default == true}
				local function render()
					Tween(track, {BackgroundColor3 = obj.Value and T.Accent or T.Off})
					Tween(knob, {
						Position = obj.Value and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6),
						BackgroundColor3 = obj.Value and T.AccentText or T.TextDim,
					})
				end
				function obj:Set(v, silent)
					self.Value = v and true or false
					render()
					if not silent then safe(to.Callback, self.Value) end
				end
				function obj:Get() return self.Value end
				hit.MouseButton1Click:Connect(function() obj:Set(not obj.Value) end)
				render()
				register(row, to.Name)
				return obj
			end

			--------------------------------------------------------
			-- Slider
			--------------------------------------------------------
			function Section:AddSlider(so2)
				so2 = so2 or {}
				local min, max, inc = so2.Min or 0, so2.Max or 100, so2.Increment or 1
				local decimals = #((tostring(inc):match("%.(%d+)")) or "")
				local suffix = so2.Suffix or ""
				local row = Row(48)
				Label({Text = so2.Name or "Slider", Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -100, 0, 16), Parent = row})
				local valLbl = Label({
					TextColor3 = T.TextDim, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(1, -12, 0, 8), Size = UDim2.fromOffset(80, 16), Parent = row,
				})
				local track = New("Frame", {
					BackgroundColor3 = T.Off, BorderSizePixel = 0,
					Position = UDim2.fromOffset(12, 32), Size = UDim2.new(1, -24, 0, 4), Parent = row,
				}, {Corner(2)})
				local fill = New("Frame", {
					BackgroundColor3 = T.Accent, BorderSizePixel = 0, Size = UDim2.fromScale(0, 1), Parent = track,
				}, {Corner(2)})
				local hit = New("TextButton", {
					Text = "", BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 24),
					Size = UDim2.new(1, 0, 0, 22), Parent = row,
				})

				local obj = {Frame = row, Value = min}
				function obj:Set(v, silent)
					v = math.clamp(math.floor(v / inc + 0.5) * inc, min, max)
					v = tonumber(string.format("%." .. decimals .. "f", v))
					self.Value = v
					fill.Size = UDim2.fromScale((v - min) / math.max(max - min, 1e-9), 1)
					valLbl.Text = tostring(v) .. suffix
					if not silent then safe(so2.Callback, v) end
				end
				function obj:Get() return self.Value end

				local dragging = false
				local function fromX(x)
					local a = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
					obj:Set(min + (max - min) * a)
				end
				hit.InputBegan:Connect(function(i)
					if isPress(i) then dragging = true fromX(i.Position.X) end
				end)
				connect(UserInputService.InputChanged, function(i)
					if dragging and isMove(i) then fromX(i.Position.X) end
				end)
				connect(UserInputService.InputEnded, function(i)
					if isPress(i) then dragging = false end
				end)
				obj:Set(so2.Default or min, true)
				register(row, so2.Name)
				return obj
			end

			--------------------------------------------------------
			-- Input
			--------------------------------------------------------
			function Section:AddInput(io)
				io = io or {}
				local row = Row(36)
				Label({Text = io.Name or "Input", Position = UDim2.fromOffset(12, 0), Size = UDim2.new(0.5, -12, 1, 0), Parent = row})
				local wrap = New("Frame", {
					BackgroundColor3 = T.Window, BorderSizePixel = 0, AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(170, 24), Parent = row,
				}, {Corner(5), Stroke(T.FieldStroke)})
				local box = New("TextBox", {
					BackgroundTransparency = 1, Text = io.Default or "", PlaceholderText = io.Placeholder or "",
					PlaceholderColor3 = T.TextMute, TextColor3 = T.Text, TextSize = 12, FontFace = font(),
					ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
					Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -16, 1, 0), Parent = wrap,
				})
				local obj = {Frame = row}
				function obj:Get() return box.Text end
				function obj:Set(t, silent) box.Text = tostring(t) if not silent then safe(io.Callback, box.Text, false) end end
				box.FocusLost:Connect(function(enter) safe(io.Callback, box.Text, enter) end)
				register(row, io.Name)
				return obj
			end

			--------------------------------------------------------
			-- Dropdown (single / Multi = true)
			--------------------------------------------------------
			function Section:AddDropdown(do_)
				do_ = do_ or {}
				local multi = do_.Multi == true
				local options = do_.Options or {}
				local selected = {}
				if multi then
					for _, v in ipairs(type(do_.Default) == "table" and do_.Default or {}) do selected[v] = true end
				elseif do_.Default ~= nil then
					selected[do_.Default] = true
				end

				local row = New("Frame", {
					BackgroundColor3 = T.Field, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 36),
					AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), Parent = Body,
				}, {Corner(6), Stroke(T.FieldStroke), New("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder})})
				local head = New("TextButton", {
					Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 36), LayoutOrder = 1, Parent = row,
				})
				Label({Text = do_.Name or "Dropdown", Position = UDim2.fromOffset(12, 0), Size = UDim2.new(0.5, -12, 1, 0), Parent = head})
				local valLbl = Label({
					TextColor3 = T.TextDim, TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd,
					Position = UDim2.fromScale(0.5, 0), Size = UDim2.new(0.5, -36, 1, 0), Parent = head,
				})
				local chev = Chevron(head, T.TextDim)
				chev.Frame.Position = UDim2.new(1, -18, 0.5, 0)
				local list = New("Frame", {
					BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
					Visible = false, LayoutOrder = 2, Parent = row,
				}, {Pad(6, 6, 0, 6), New("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder})})

				local obj = {Frame = row}
				local buttons = {}
				local function get()
					if multi then
						local t = {}
						for _, opt in ipairs(options) do if selected[opt] then table.insert(t, opt) end end
						return t
					end
					for _, opt in ipairs(options) do if selected[opt] then return opt end end
				end
				local function refresh()
					local names = {}
					for _, opt in ipairs(options) do if selected[opt] then table.insert(names, tostring(opt)) end end
					valLbl.Text = #names > 0 and table.concat(names, ", ") or "None"
					for opt, b in pairs(buttons) do
						b.TextColor3 = selected[opt] and T.Text or T.TextDim
					end
				end
				local function setOpen(state)
					list.Visible = state
					Tween(chev.Frame, {Rotation = state and 180 or 0})
				end
				local function build()
					for _, b in pairs(buttons) do b:Destroy() end
					table.clear(buttons)
					for i, opt in ipairs(options) do
						local b = New("TextButton", {
							Text = tostring(opt), AutoButtonColor = false, BackgroundColor3 = T.Hover, BackgroundTransparency = 1,
							BorderSizePixel = 0, FontFace = font(), TextSize = 12, TextColor3 = T.TextDim,
							TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 26),
							LayoutOrder = i, Parent = list,
						}, {Corner(5), Pad(8, 8, 0, 0)})
						b.MouseEnter:Connect(function() Tween(b, {BackgroundTransparency = 0.4}) end)
						b.MouseLeave:Connect(function() Tween(b, {BackgroundTransparency = 1}) end)
						b.MouseButton1Click:Connect(function()
							if multi then
								selected[opt] = not selected[opt] or nil
							else
								selected = {[opt] = true}
								setOpen(false)
							end
							refresh()
							safe(do_.Callback, get())
						end)
						buttons[opt] = b
					end
					refresh()
				end

				head.MouseButton1Click:Connect(function() setOpen(not list.Visible) end)
				function obj:Get() return get() end
				function obj:Set(v, silent)
					selected = {}
					if multi then for _, x in ipairs(type(v) == "table" and v or {}) do selected[x] = true end
					elseif v ~= nil then selected[v] = true end
					refresh()
					if not silent then safe(do_.Callback, get()) end
				end
				function obj:SetOptions(newOptions)
					options = newOptions or {}
					selected = {}
					build()
				end
				build()
				register(row, do_.Name)
				return obj
			end

			table.insert(Tab.Sections, Section)
			return Section
		end

		table.insert(self.Tabs, Tab)
		if index == 1 then self:SelectTab(Tab) end
		return Tab
	end

	-- กดปุ่มลัดซ่อน/แสดง
	local toggleKey = opts.ToggleKey or Enum.KeyCode.RightShift
	connect(UserInputService.InputBegan, function(i, processed)
		if not processed and i.KeyCode == toggleKey then Window:Toggle() end
	end)

	return Window
end

return Library
