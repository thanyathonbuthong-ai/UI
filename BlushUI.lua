--[[
    BlushUI Library  —  Roblox UI Library (clone of the "blush." menu)
    - Sidebar (sections / tabs / sub-tabs), breadcrumb header, header buttons + badge
    - Cards (collapsible), Checkbox (+keybind, +badge), Slider, Dropdown, Button, Label, Tab card
    - Notifications, Stats bar (fps / ping / time), draggable, auto UIScale for phones
    - Icons: Lucide (โหลดอัตโนมัติ) — ใส่ชื่อ เช่น "house", "crosshair", "target" หรือ "rbxassetid://..."
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local Library = { Flags = {}, Options = {}, Windows = {}, Theme = {}, _conns = {}, _guis = {} }

-- ───────────────────────── Theme ─────────────────────────
local Theme = Library.Theme
Theme.Sidebar      = Color3.fromRGB(10, 10, 10)
Theme.Content      = Color3.fromRGB(13, 13, 13)
Theme.Card         = Color3.fromRGB(26, 26, 26)
Theme.CardAlpha    = 0.25
Theme.Control      = Color3.fromRGB(32, 32, 32)
Theme.ControlHover = Color3.fromRGB(44, 44, 44)
Theme.Button       = Color3.fromRGB(12, 12, 12)
Theme.Box          = Color3.fromRGB(40, 40, 40)
Theme.BoxDisabled  = Color3.fromRGB(30, 30, 30)
Theme.Track        = Color3.fromRGB(55, 55, 55)
Theme.Accent       = Color3.fromRGB(255, 255, 255)
Theme.Text         = Color3.fromRGB(255, 255, 255)
Theme.TextDim      = Color3.fromRGB(190, 190, 190)
Theme.NavInactive  = Color3.fromRGB(190, 190, 190)
Theme.SubText      = Color3.fromRGB(160, 160, 160)
Theme.Muted        = Color3.fromRGB(125, 125, 125)
Theme.Disabled     = Color3.fromRGB(72, 72, 72)
Theme.Danger       = Color3.fromRGB(255, 69, 69)
Theme.Line         = Color3.fromRGB(48, 48, 48)

-- ───────────────────────── Fonts ─────────────────────────
local function MakeFont(weight)
	local ok, f = pcall(function()
		return Font.new(Font.fromEnum(Enum.Font.Roboto).Family, weight)
	end)
	return ok and f or Font.fromEnum(Enum.Font.Roboto)
end
local F = {
	Regular = MakeFont(Enum.FontWeight.Regular),
	Medium = MakeFont(Enum.FontWeight.Medium),
	SemiBold = MakeFont(Enum.FontWeight.SemiBold),
	Bold = MakeFont(Enum.FontWeight.Bold),
}

-- ───────────────────────── Helpers ─────────────────────────
local AS_X, AS_Y = Enum.AutomaticSize.X, Enum.AutomaticSize.Y
local HORIZ, VERT = Enum.FillDirection.Horizontal, Enum.FillDirection.Vertical

local Defaults = {
	Frame = { BorderSizePixel = 0 },
	TextLabel = { BackgroundTransparency = 1, BorderSizePixel = 0, FontFace = F.Regular, TextSize = 13, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left },
	TextButton = { BackgroundTransparency = 1, BorderSizePixel = 0, AutoButtonColor = false, FontFace = F.Regular, TextSize = 13, TextColor3 = Theme.Text, Text = "" },
	ImageLabel = { BackgroundTransparency = 1, BorderSizePixel = 0 },
	ScrollingFrame = { BackgroundTransparency = 1, BorderSizePixel = 0 },
	TextBox = { BackgroundTransparency = 1, BorderSizePixel = 0, FontFace = F.Regular, TextSize = 13, TextColor3 = Theme.Text, PlaceholderColor3 = Theme.Muted, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Text = "" },
}

local function Create(class, props, children)
	local inst = Instance.new(class)
	for k, v in pairs(Defaults[class] or {}) do inst[k] = v end
	local parent
	for k, v in pairs(props or {}) do
		if k == "Parent" then parent = v else inst[k] = v end
	end
	for _, c in ipairs(children or {}) do c.Parent = inst end
	inst.Parent = parent
	return inst
end

local function Corner(r) return Create("UICorner", { CornerRadius = UDim.new(0, r) }) end
local function Round() return Create("UICorner", { CornerRadius = UDim.new(1, 0) }) end
local function Stroke(color, th, tr)
	return Create("UIStroke", { Color = color, Thickness = th or 1, Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
end
local function List(pad, dir, ha, va)
	return Create("UIListLayout", {
		Padding = UDim.new(0, pad or 0), FillDirection = dir or VERT,
		HorizontalAlignment = ha or Enum.HorizontalAlignment.Left,
		VerticalAlignment = va or Enum.VerticalAlignment.Top,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
end
local function Pad(t, r, b, l)
	return Create("UIPadding", { PaddingTop = UDim.new(0, t or 0), PaddingRight = UDim.new(0, r or 0), PaddingBottom = UDim.new(0, b or 0), PaddingLeft = UDim.new(0, l or 0) })
end

local Counters = setmetatable({}, { __mode = "k" })
local function Order(c)
	Counters[c] = (Counters[c] or 0) + 1
	return Counters[c]
end

local function Tween(inst, props, time, style)
	local t = TweenService:Create(inst, TweenInfo.new(time or 0.15, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local function Connect(signal, fn)
	local c = signal:Connect(fn)
	table.insert(Library._conns, c)
	return c
end

local function NewGui(name)
	local gui = Create("ScreenGui", { Name = name, ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999 })
	pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
	local parent
	pcall(function() if gethui then parent = gethui() end end)
	if not parent then
		local ok = pcall(function() gui.Parent = CoreGui end)
		if ok and gui.Parent == CoreGui then parent = CoreGui end
	end
	gui.Parent = parent or LocalPlayer:WaitForChild("PlayerGui")
	table.insert(Library._guis, gui)
	return gui
end

local function SetAvatar(img, v)
	if type(v) == "string" then img.Image = v return end
	task.spawn(function()
		local ok, content = pcall(function()
			return Players:GetUserThumbnailAsync(v or LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		end)
		if ok then img.Image = content end
	end)
end

-- ───────────────────────── Icons (Lucide) ─────────────────────────
-- ใช้ไอคอน Lucide ตัวจริงจาก deividcomsono/lucide-roblox-direct (spritesheet)
local LUCIDE_URL = "https://raw.githubusercontent.com/deividcomsono/lucide-roblox-direct/refs/heads/main/source.lua"
local Lucide
do
	local ok, res = pcall(function()
		return loadstring(game:HttpGet(LUCIDE_URL))()
	end)
	if ok and type(res) == "table" and res.GetAsset then
		Lucide = res
	else
		warn("[BlushUI] โหลด Lucide icons ไม่สำเร็จ:", res)
	end
end
Library.Lucide = Lucide

-- ชื่อเก่า -> ชื่อใหม่ใน Lucide
local IconAlias = {
	home = "house",
	["alert-triangle"] = "triangle-alert",
	["check-circle"] = "circle-check",
	["x-circle"] = "circle-x",
	["help-circle"] = "circle-question-mark",
}

function Library:Icon(name, size, color, parent)
	size = size or 16
	color = color or Theme.Text
	local key = tostring(name or "")
	key = (key:gsub("^lucide[-:]", ""))
	key = IconAlias[key] or key

	local img = Create("ImageLabel", {
		Name = "Icon", Size = UDim2.fromOffset(size, size), ImageColor3 = color,
		ScaleType = Enum.ScaleType.Fit, Parent = parent,
	})
	if key:match("^rbxassetid://") or key:match("^%d+$") then
		img.Image = key:match("^%d+$") and ("rbxassetid://" .. key) or key
	elseif Lucide then
		local asset = Lucide.GetAsset(key)
		if asset then
			img.Image = asset.Url
			img.ImageRectSize = asset.ImageRectSize
			img.ImageRectOffset = asset.ImageRectOffset
		else
			warn("[BlushUI] ไม่พบไอคอน Lucide ชื่อ:", key)
		end
	end
	return {
		Root = img,
		SetColor = function(c, t)
			if t then Tween(img, { ImageColor3 = c }, t) else img.ImageColor3 = c end
		end,
	}
end

-- ───────────────────────── Keybind helpers ─────────────────────────
local MouseNames = { MB1 = Enum.UserInputType.MouseButton1, MB2 = Enum.UserInputType.MouseButton2, MB3 = Enum.UserInputType.MouseButton3 }
local function KeyName(k)
	if k == nil then return "None" end
	if k == Enum.UserInputType.MouseButton1 then return "MB1" end
	if k == Enum.UserInputType.MouseButton2 then return "MB2" end
	if k == Enum.UserInputType.MouseButton3 then return "MB3" end
	return k.Name
end
local function ToKey(v)
	if typeof(v) == "EnumItem" then return v end
	if MouseNames[v] then return MouseNames[v] end
	local ok, k = pcall(function() return Enum.KeyCode[v] end)
	return ok and k or nil
end

local function Register(o, obj)
	if o.Flag then Library.Flags[o.Flag] = obj.Value; Library.Options[o.Flag] = obj end
end
local function Fire(o, obj)
	if o.Flag then Library.Flags[o.Flag] = obj.Value end
	if o.Callback then task.spawn(o.Callback, obj.Value) end
end

-- ───────────────────────── Elements ─────────────────────────
local Elements = {}
Elements.__index = Elements

function Elements:AddCheckbox(o)
	o = o or {}
	o.Text = o.Text or o.Title
	if o.Default == nil then o.Default = o.Value end
	local Obj = { Type = "Checkbox", Value = false }
	local disabled = o.Disabled
	local Row = Create("Frame", { Name = o.Text or "Checkbox", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 23), LayoutOrder = Order(self.Body), Parent = self.Body })
	local Hit = Create("TextButton", { Size = UDim2.fromScale(1, 1), Parent = Row })
	local Box = Create("Frame", {
		BackgroundColor3 = disabled and Theme.BoxDisabled or Theme.Box, AnchorPoint = Vector2.new(0, .5),
		Position = UDim2.new(0, 0, .5, 0), Size = UDim2.fromOffset(17, 17), Parent = Row,
	}, { Corner(5) })
	local Check = Library:Icon("check", 11, Color3.fromRGB(10, 10, 10), Box, 3.2)
	Check.Root.AnchorPoint = Vector2.new(.5, .5)
	Check.Root.Position = UDim2.fromScale(.5, .5)
	Check.Root.Visible = false

	local Info = Create("Frame", { BackgroundTransparency = 1, Position = UDim2.new(0, 26, 0, 0), Size = UDim2.new(1, -26, 1, 0), Parent = Row },
		{ List(8, HORIZ, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) })
	Create("TextLabel", {
		Text = o.Text or "", TextColor3 = o.TextColor or (disabled and Theme.Disabled or Theme.Text),
		AutomaticSize = AS_X, Size = UDim2.new(0, 0, 1, 0), LayoutOrder = 1, Parent = Info,
	})
	if o.Badge then
		local B = Create("Frame", { BackgroundColor3 = Color3.fromRGB(14, 14, 14), AutomaticSize = AS_X, Size = UDim2.new(0, 0, 0, 17), LayoutOrder = 2, Parent = Info },
			{ Corner(6), Pad(0, 7, 0, 7) })
		Create("TextLabel", { Text = o.Badge, FontFace = F.Bold, TextSize = 9, AutomaticSize = AS_X, Size = UDim2.new(0, 0, 1, 0), Parent = B })
	end

	function Obj:SetValue(v, silent)
		v = v and true or false
		self.Value = v
		Tween(Box, { BackgroundColor3 = v and Theme.Accent or (disabled and Theme.BoxDisabled or Theme.Box) }, .12)
		Check.Root.Visible = v
		if silent then
			if o.Flag then Library.Flags[o.Flag] = v end
		else
			Fire(o, self)
		end
	end
	function Obj:SetVisible(v) Row.Visible = v end
	Obj.Root = Row

	if not disabled then
		Hit.MouseButton1Click:Connect(function() Obj:SetValue(not Obj.Value) end)
	end

	-- keybind (display + rebind + toggle/hold)
	if o.Keybind then
		Obj.Key = ToKey(o.Keybind)
		local KeyBtn = Create("TextButton", {
			Text = KeyName(Obj.Key), TextColor3 = Theme.SubText, TextSize = 12, AnchorPoint = Vector2.new(1, .5),
			Position = UDim2.new(1, 0, .5, 0), AutomaticSize = AS_X, Size = UDim2.new(0, 0, 1, 0), ZIndex = 3, Parent = Row,
		})
		KeyBtn.MouseButton1Click:Connect(function()
			KeyBtn.Text = "..."
			Obj._listening = true
			local con
			con = UserInputService.InputBegan:Connect(function(i)
				local k
				if i.UserInputType == Enum.UserInputType.Keyboard then
					k = (i.KeyCode ~= Enum.KeyCode.Escape) and i.KeyCode or nil
				elseif i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.MouseButton2 or i.UserInputType == Enum.UserInputType.MouseButton3 then
					k = i.UserInputType
				else
					return
				end
				con:Disconnect()
				Obj._listening = false
				Obj.Key = k
				KeyBtn.Text = KeyName(k)
				if o.KeybindChanged then task.spawn(o.KeybindChanged, k) end
			end)
		end)
		Connect(UserInputService.InputBegan, function(i, gp)
			if gp or Obj._listening or not Obj.Key or disabled then return end
			if i.KeyCode == Obj.Key or i.UserInputType == Obj.Key then
				if o.KeybindMode == "Hold" then Obj:SetValue(true) else Obj:SetValue(not Obj.Value) end
			end
		end)
		if o.KeybindMode == "Hold" then
			Connect(UserInputService.InputEnded, function(i)
				if Obj.Key and (i.KeyCode == Obj.Key or i.UserInputType == Obj.Key) then Obj:SetValue(false) end
			end)
		end
	end

	Obj:SetValue(o.Default or false, true)
	Register(o, Obj)
	return Obj
end

-- ───────────── shared helpers ─────────────
local function Common(Obj, Root)
	Obj.Root = Root
	function Obj:SetVisible(v) Root.Visible = v end
	function Obj:Destroy() Root:Destroy() end
	return Obj
end

local function Lum(c) return c.R * .3 + c.G * .59 + c.B * .11 end

local function IsPress(i)
	return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end
local function IsMove(i)
	return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch
end

local function ResolveImage(src, img)
	if type(src) ~= "string" then return end
	if src:match("^https?://") then
		if not (writefile and getcustomasset and isfile and isfolder and makefolder) then return end
		task.spawn(function()
			pcall(function()
				if not isfolder("BlushUI") then makefolder("BlushUI") end
				local hash = 0
				for i = 1, #src do hash = (hash * 31 + src:byte(i)) % 2147483647 end
				local path = "BlushUI/img_" .. hash .. ".png"
				if not isfile(path) then writefile(path, game:HttpGet(src)) end
				img.Image = getcustomasset(path)
			end)
		end)
	else
		img.Image = src
	end
end

-- ───────────── Slider ─────────────
function Elements:AddSlider(o)
	o = o or {}
	local rng = type(o.Value) == "table" and o.Value or {}
	local min, max = o.Min or rng.Min or 0, o.Max or rng.Max or 100
	local inc = o.Increment or o.Step or 1
	local title = o.Title or o.Text or ""
	local Obj = { Type = "Slider", Value = math.clamp(o.Default or rng.Default or min, min, max) }
	local Frame = Create("Frame", { Name = title, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 39), LayoutOrder = Order(self.Body), Parent = self.Body })
	Create("TextLabel", { Text = title, Size = UDim2.new(.65, 0, 0, 18), Parent = Frame })
	local ValueBox = Create("TextBox", {
		TextSize = 12, TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Right,
		Position = UDim2.fromScale(.65, 0), Size = UDim2.new(.35, 0, 0, 18), Parent = Frame,
	})
	local Track = Create("Frame", { BackgroundColor3 = Theme.Track, AnchorPoint = Vector2.new(0, .5), Position = UDim2.new(0, 0, 0, 29), Size = UDim2.new(1, 0, 0, 4), Parent = Frame }, { Corner(2) })
	local Fill = Create("Frame", { BackgroundColor3 = Theme.Accent, Size = UDim2.new(0, 0, 1, 0), Parent = Track }, { Corner(2) })
	local Knob = Create("Frame", { BackgroundColor3 = Theme.Accent, AnchorPoint = Vector2.new(.5, .5), Position = UDim2.new(0, 0, .5, 0), Size = UDim2.fromOffset(13, 13), ZIndex = 2, Parent = Track }, { Round() })
	local Hit = Create("TextButton", { Position = UDim2.new(0, 0, 0, 19), Size = UDim2.new(1, 0, 0, 22), ZIndex = 3, Parent = Frame })

	local function fmt(v)
		local s
		if inc % 1 == 0 then s = tostring(math.floor(v + .5)) else s = string.format("%." .. (o.Decimals or 2) .. "f", v) end
		return (o.Prefix or "") .. s .. (o.Suffix or "")
	end

	function Obj:SetValue(v, silent)
		v = math.clamp(v, min, max)
		v = math.floor((v - min) / inc + .5) * inc + min
		v = tonumber(string.format("%.6f", math.clamp(v, min, max)))
		self.Value = v
		local a = (max == min) and 0 or (v - min) / (max - min)
		Fill.Size = UDim2.new(a, 0, 1, 0)
		Knob.Position = UDim2.new(a, 0, .5, 0)
		ValueBox.Text = fmt(v)
		if silent then
			if o.Flag then Library.Flags[o.Flag] = v end
		else
			Fire(o, self)
		end
	end

	-- พิมพ์ตัวเลขเองได้ที่ช่องค่า
	ValueBox.FocusLost:Connect(function()
		local n = tonumber((ValueBox.Text:gsub("[^%d%.%-]", "")))
		Obj:SetValue(n or Obj.Value)
	end)

	local dragging = false
	local window = self.Window
	local function update(x)
		local a = math.clamp((x - Track.AbsolutePosition.X) / math.max(Track.AbsoluteSize.X, 1), 0, 1)
		Obj:SetValue(min + (max - min) * a)
	end
	Hit.InputBegan:Connect(function(i)
		if IsPress(i) then
			dragging = true
			if window then window:LockScroll(true) end
			update(i.Position.X)
		end
	end)
	Connect(UserInputService.InputChanged, function(i)
		if dragging and IsMove(i) then update(i.Position.X) end
	end)
	Connect(UserInputService.InputEnded, function(i)
		if dragging and IsPress(i) then
			dragging = false
			if window then window:LockScroll(false) end
		end
	end)

	Obj:SetValue(Obj.Value, true)
	Register(o, Obj)
	return Common(Obj, Frame)
end

-- ───────────── Dropdown (single / multi / search / allow none) ─────────────
function Elements:AddDropdown(o)
	o = o or {}
	local title = o.Title or o.Text or ""
	local Obj = { Type = "Dropdown", Options = o.Options or o.Values or {}, Multi = o.Multi, AllowNone = o.AllowNone }
	local default = o.Default
	if default == nil then default = o.Value end
	if Obj.Multi then
		Obj.Value = {}
		if type(default) == "table" then for _, x in ipairs(default) do Obj.Value[x] = true end end
	else
		Obj.Value = default
		if Obj.Value == nil and not Obj.AllowNone then Obj.Value = Obj.Options[1] end
	end

	local yo = o.Desc and 15 or 0
	local Frame = Create("Frame", { Name = title, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 50 + yo), LayoutOrder = Order(self.Body), Parent = self.Body })
	Create("TextLabel", { Text = title, Size = UDim2.new(1, 0, 0, 16), Parent = Frame })
	if o.Desc then
		Create("TextLabel", { Text = o.Desc, TextSize = 11, TextColor3 = Theme.Muted, Position = UDim2.fromOffset(0, 16), Size = UDim2.new(1, 0, 0, 14), Parent = Frame })
	end
	local Box = Create("TextButton", { BackgroundTransparency = 0, BackgroundColor3 = Theme.Control, Position = UDim2.fromOffset(0, 22 + yo), Size = UDim2.new(1, 0, 0, 28), Parent = Frame }, { Corner(8) })
	local Text = Create("TextLabel", { Position = UDim2.new(0, 9, 0, 0), Size = UDim2.new(1, -34, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, Parent = Box })
	local Chev = Library:Icon("chevron-down", 14, Theme.TextDim, Box)
	Chev.Root.AnchorPoint = Vector2.new(.5, .5)
	Chev.Root.Position = UDim2.new(1, -18, .5, 0)

	local function selected()
		local t = {}
		for _, opt in ipairs(Obj.Options) do if Obj.Value[opt] then t[#t + 1] = opt end end
		return t
	end
	Obj.GetSelected = selected
	local function refreshText()
		if Obj.Multi then
			local t = selected()
			Text.Text = #t > 0 and table.concat(t, ", ") or "None"
		else
			Text.Text = tostring(Obj.Value or "None")
		end
	end
	local function emit()
		local val = Obj.Multi and selected() or Obj.Value
		if o.Flag then Library.Flags[o.Flag] = val end
		if o.Callback then task.spawn(o.Callback, val) end
	end

	function Obj:SetValue(v, silent)
		if self.Multi then
			self.Value = {}
			if type(v) == "table" then for _, x in ipairs(v) do self.Value[x] = true end end
		else
			self.Value = v
		end
		refreshText()
		if silent then
			if o.Flag then Library.Flags[o.Flag] = self.Multi and selected() or self.Value end
		else
			emit()
		end
	end
	function Obj:SetOptions(opts) self.Options = opts refreshText() end

	local window = self.Window
	Box.MouseButton1Click:Connect(function()
		window:ClosePopup()
		local sc = window.Scale.Scale
		local searchable = o.Search ~= false and #Obj.Options > 8
		local listH = math.min(#Obj.Options * 26 + 8, 164)
		local h = listH + (searchable and 34 or 0)
		local abs = (Box.AbsolutePosition - window.Popups.AbsolutePosition) / sc
		local bh = Box.AbsoluteSize.Y / sc
		local y = abs.Y + bh + 4
		if y + h > window.Main.AbsoluteSize.Y / sc then y = math.max(4, abs.Y - h - 4) end

		local Panel = Create("Frame", {
			BackgroundColor3 = Color3.fromRGB(20, 20, 20), Position = UDim2.fromOffset(abs.X, y),
			Size = UDim2.fromOffset(Box.AbsoluteSize.X / sc, h),
		}, { Corner(8), Stroke(Theme.Line, 1) })
		local Search
		if searchable then
			Search = Create("TextBox", {
				PlaceholderText = "Search...", TextSize = 12, BackgroundTransparency = 0, BackgroundColor3 = Theme.Control,
				Position = UDim2.fromOffset(6, 6), Size = UDim2.new(1, -12, 0, 24), Parent = Panel,
			}, { Corner(6), Pad(0, 0, 0, 8) })
		end
		local L = Create("ScrollingFrame", {
			Position = UDim2.fromOffset(0, searchable and 34 or 0), Size = UDim2.new(1, 0, 0, listH),
			CanvasSize = UDim2.new(), AutomaticCanvasSize = AS_Y, ScrollBarThickness = 2, Parent = Panel,
		}, { List(0), Pad(4, 4, 4, 4) })

		local buttons = {}
		local function paint()
			for opt, b in pairs(buttons) do
				local sel = Obj.Multi and Obj.Value[opt] or (not Obj.Multi and Obj.Value == opt)
				b.TextColor3 = sel and Theme.Text or Theme.SubText
			end
		end
		for idx, opt in ipairs(Obj.Options) do
			local b = Create("TextButton", {
				Text = tostring(opt), TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
				BackgroundColor3 = Theme.Control, Size = UDim2.new(1, 0, 0, 26), LayoutOrder = idx, Parent = L,
			}, { Corner(6), Pad(0, 0, 0, 8) })
			buttons[opt] = b
			b.MouseEnter:Connect(function() b.BackgroundTransparency = 0 end)
			b.MouseLeave:Connect(function() b.BackgroundTransparency = 1 end)
			b.MouseButton1Click:Connect(function()
				if Obj.Multi then
					local on = Obj.Value[opt]
					if on and not Obj.AllowNone and #selected() <= 1 then return end
					Obj.Value[opt] = (not on) or nil
					refreshText(); paint(); emit()
				else
					if Obj.AllowNone and Obj.Value == opt then Obj:SetValue(nil) else Obj:SetValue(opt) end
					window:ClosePopup()
				end
			end)
		end
		if Search then
			Search:GetPropertyChangedSignal("Text"):Connect(function()
				local q = Search.Text:lower()
				for opt, b in pairs(buttons) do b.Visible = q == "" or tostring(opt):lower():find(q, 1, true) ~= nil end
			end)
		end
		paint()
		Tween(Chev.Root, { Rotation = 180 }, .15)
		window:OpenPopup(Panel, function() Tween(Chev.Root, { Rotation = 0 }, .15) end)
	end)

	refreshText()
	Register(o, Obj)
	if o.Flag then Library.Flags[o.Flag] = Obj.Multi and selected() or Obj.Value end
	return Common(Obj, Frame)
end

-- ───────────── Button (icon / desc / color / locked / justify) ─────────────
function Elements:AddButton(o)
	o = type(o) == "string" and { Title = o } or (o or {})
	local title = o.Title or o.Text or "Button"
	local justify = o.Justify or "Center" -- Center | Left | Between
	local hasDesc = o.Desc ~= nil
	local iconAlign = o.IconAlign or (justify == "Between" and "Right" or "Left")
	local Obj = { Type = "Button", Locked = o.Locked or false }
	local base = o.Color or Theme.Button
	local fg = Lum(base) > .6 and Color3.fromRGB(10, 10, 10) or Theme.Text
	local hover = base:Lerp(Color3.new(1, 1, 1), .08)
	local press = base:Lerp(Color3.new(0, 0, 0), .3)
	local locked = base:Lerp(Color3.new(0, 0, 0), .45)

	local Btn = Create("TextButton", {
		Name = title, BackgroundTransparency = 0, BackgroundColor3 = base,
		Size = UDim2.new(1, 0, 0, hasDesc and 44 or 27), LayoutOrder = Order(self.Body), Parent = self.Body,
	}, { Corner(8) })
	local ty, th = hasDesc and 6 or 0, hasDesc and 16 or 27
	local Row = Create("Frame", { BackgroundTransparency = 1, AutomaticSize = AS_X, Size = UDim2.new(0, 0, 0, th), Parent = Btn },
		{ List(6, HORIZ, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) })
	if justify == "Center" then
		Row.AnchorPoint = Vector2.new(.5, 0)
		Row.Position = UDim2.new(.5, 0, 0, ty)
	else
		Row.Position = UDim2.new(0, 10, 0, ty)
	end
	local Icon
	if o.Icon then
		Icon = Library:Icon(o.Icon, 15, fg, Row)
		Icon.Root.LayoutOrder = iconAlign == "Left" and 0 or 2
		if justify == "Between" and iconAlign == "Right" then
			Icon.Root.Parent = Btn
			Icon.Root.AnchorPoint = Vector2.new(1, .5)
			Icon.Root.Position = UDim2.new(1, -10, 0, ty + th / 2)
		end
	end
	local TitleL = Create("TextLabel", { Text = title, FontFace = F.Medium, TextColor3 = fg, AutomaticSize = AS_X, Size = UDim2.new(0, 0, 1, 0), LayoutOrder = 1, Parent = Row })
	local DescL
	if hasDesc then
		DescL = Create("TextLabel", {
			Text = o.Desc, TextSize = 11, TextColor3 = fg, TextTransparency = .35,
			TextXAlignment = justify == "Center" and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
			Position = UDim2.new(0, justify == "Center" and 0 or 10, 0, 24), Size = UDim2.new(1, justify == "Center" and 0 or -20, 0, 14), Parent = Btn,
		})
	end

	local function paint()
		if Obj.Locked then
			Btn.BackgroundColor3 = locked
			TitleL.Text = o.LockedTitle or title
			TitleL.TextColor3 = Theme.Disabled
			if Icon then Icon.SetColor(Theme.Disabled) end
		else
			Btn.BackgroundColor3 = base
			TitleL.Text = title
			TitleL.TextColor3 = fg
			if Icon then Icon.SetColor(fg) end
		end
	end
	paint()
	Btn.MouseEnter:Connect(function() if not Obj.Locked then Tween(Btn, { BackgroundColor3 = hover }, .12) end end)
	Btn.MouseLeave:Connect(function() if not Obj.Locked then Tween(Btn, { BackgroundColor3 = base }, .12) end end)
	Btn.MouseButton1Down:Connect(function() if not Obj.Locked then Tween(Btn, { BackgroundColor3 = press }, .08) end end)
	Btn.MouseButton1Up:Connect(function() if not Obj.Locked then Tween(Btn, { BackgroundColor3 = hover }, .08) end end)
	Btn.MouseButton1Click:Connect(function()
		if not Obj.Locked and o.Callback then task.spawn(o.Callback) end
	end)

	function Obj:SetTitle(t) title = t TitleL.Text = t end
	function Obj:SetDesc(t) if DescL then DescL.Text = t end end
	function Obj:Lock() Obj.Locked = true paint() end
	function Obj:Unlock() Obj.Locked = false paint() end
	return Common(Obj, Btn)
end

-- ───────────── Toggle (switch  /  Type = "Checkbox") ─────────────
function Elements:AddToggle(o)
	o = o or {}
	if o.Type == "Checkbox" then
		o.Text = o.Text or o.Title
		return self:AddCheckbox(o)
	end
	local title = o.Title or o.Text or "Toggle"
	local hasDesc = o.Desc ~= nil
	local h = hasDesc and 36 or 23
	local Obj = { Type = "Toggle", Value = false, Locked = o.Locked or false }
	local Row = Create("Frame", { Name = title, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, h), LayoutOrder = Order(self.Body), Parent = self.Body })
	local Hit = Create("TextButton", { Size = UDim2.fromScale(1, 1), Parent = Row })
	local tx = 0
	if o.Icon then
		local Icon = Library:Icon(o.Icon, 16, Theme.TextDim, Row)
		Icon.Root.Position = UDim2.fromOffset(0, (h - 16) / 2)
		tx = 25
	end
	local TitleL = Create("TextLabel", {
		Text = title, Position = UDim2.fromOffset(tx, hasDesc and 3 or 0),
		Size = UDim2.new(1, -(tx + 46), hasDesc and 0 or 1, hasDesc and 16 or 0), Parent = Row,
	})
	if hasDesc then
		Create("TextLabel", { Text = o.Desc, TextSize = 11, TextColor3 = Theme.Muted, Position = UDim2.fromOffset(tx, 19), Size = UDim2.new(1, -(tx + 46), 0, 14), Parent = Row })
	end
	local Track = Create("Frame", { BackgroundColor3 = Theme.Box, AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, 0, .5, 0), Size = UDim2.fromOffset(32, 17), Parent = Row }, { Round() })
	local Knob = Create("Frame", { BackgroundColor3 = Color3.fromRGB(150, 150, 150), AnchorPoint = Vector2.new(0, .5), Position = UDim2.new(0, 2, .5, 0), Size = UDim2.fromOffset(13, 13), Parent = Track }, { Round() })

	local function paint()
		local on = Obj.Value
		Tween(Track, { BackgroundColor3 = on and Theme.Accent or Theme.Box }, .15)
		Tween(Knob, { Position = on and UDim2.new(1, -15, .5, 0) or UDim2.new(0, 2, .5, 0), BackgroundColor3 = on and Color3.fromRGB(10, 10, 10) or Color3.fromRGB(150, 150, 150) }, .15)
		TitleL.TextColor3 = Obj.Locked and Theme.Disabled or (o.TextColor or Theme.Text)
		TitleL.Text = Obj.Locked and (o.LockedTitle or title) or title
		Track.BackgroundTransparency = Obj.Locked and .5 or 0
	end
	function Obj:SetValue(v, silent)
		self.Value = v and true or false
		paint()
		if silent then
			if o.Flag then Library.Flags[o.Flag] = self.Value end
		else
			Fire(o, self)
		end
	end
	function Obj:SetTitle(t) title = t paint() end
	function Obj:Lock() Obj.Locked = true paint() end
	function Obj:Unlock() Obj.Locked = false paint() end
	Hit.MouseButton1Click:Connect(function()
		if not Obj.Locked then Obj:SetValue(not Obj.Value) end
	end)

	Obj:SetValue(o.Default or o.Value or false, true)
	Register(o, Obj)
	return Common(Obj, Row)
end

-- ───────────── Input (single line / textarea) ─────────────
function Elements:AddInput(o)
	o = o or {}
	local title = o.Title or o.Text or ""
	local area = o.Type == "Textarea"
	local Obj = { Type = "Input", Value = o.Value or o.Default or "" }
	local yo = o.Desc and 15 or 0
	local bh = area and 72 or 28
	local Frame = Create("Frame", { Name = title, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22 + yo + bh), LayoutOrder = Order(self.Body), Parent = self.Body })
	Create("TextLabel", { Text = title, Size = UDim2.new(1, 0, 0, 16), Parent = Frame })
	if o.Desc then
		Create("TextLabel", { Text = o.Desc, TextSize = 11, TextColor3 = Theme.Muted, Position = UDim2.fromOffset(0, 16), Size = UDim2.new(1, 0, 0, 14), Parent = Frame })
	end
	local Box = Create("Frame", {
		BackgroundColor3 = Theme.Control, Position = UDim2.fromOffset(0, 22 + yo), Size = UDim2.new(1, 0, 0, bh),
		ClipsDescendants = true, Parent = Frame,
	}, { Corner(8) })
	local Ring = Stroke(Theme.Accent, 1, 1)
	Ring.Parent = Box
	local pad = o.Icon and 30 or 9
	if o.Icon then
		local ic = Library:Icon(o.Icon, 14, Theme.SubText, Box)
		ic.Root.Position = UDim2.fromOffset(9, area and 9 or 7)
	end
	local TB = Create("TextBox", {
		Text = Obj.Value, PlaceholderText = o.Placeholder or "", MultiLine = area, TextWrapped = area,
		TextYAlignment = area and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
		ClearTextOnFocus = o.ClearTextOnFocus or false, Position = UDim2.fromOffset(pad, 0), Size = UDim2.new(1, -(pad + 9), 1, 0), Parent = Box,
	}, { Pad(area and 8 or 0, 0, area and 8 or 0, 0) })

	TB.Focused:Connect(function() Tween(Ring, { Transparency = .55 }, .12) end)
	TB.FocusLost:Connect(function()
		Tween(Ring, { Transparency = 1 }, .12)
		Obj.Value = TB.Text
		Fire(o, Obj)
	end)
	if o.Numeric then
		TB:GetPropertyChangedSignal("Text"):Connect(function()
			local clean = TB.Text:gsub("[^%d%.%-]", "")
			if clean ~= TB.Text then TB.Text = clean end
		end)
	end
	function Obj:SetValue(v, silent)
		self.Value = tostring(v or "")
		TB.Text = self.Value
		if silent then
			if o.Flag then Library.Flags[o.Flag] = self.Value end
		else
			Fire(o, self)
		end
	end
	function Obj:GetValue() return TB.Text end
	function Obj:SetPlaceholder(t) TB.PlaceholderText = t end

	Register(o, Obj)
	return Common(Obj, Frame)
end

-- ───────────── Keybind (standalone) ─────────────
function Elements:AddKeybind(o)
	o = o or {}
	local title = o.Title or o.Text or "Keybind"
	local hasDesc = o.Desc ~= nil
	local Obj = { Type = "Keybind", Key = ToKey(o.Value or o.Default), Mode = o.Mode or "Toggle", State = false }
	Obj.Value = KeyName(Obj.Key)
	local Row = Create("Frame", { Name = title, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, hasDesc and 36 or 23), LayoutOrder = Order(self.Body), Parent = self.Body })
	Create("TextLabel", {
		Text = title, Position = UDim2.fromOffset(0, hasDesc and 3 or 0),
		Size = UDim2.new(1, -80, hasDesc and 0 or 1, hasDesc and 16 or 0), Parent = Row,
	})
	if hasDesc then
		Create("TextLabel", { Text = o.Desc, TextSize = 11, TextColor3 = Theme.Muted, Position = UDim2.fromOffset(0, 19), Size = UDim2.new(1, -80, 0, 14), Parent = Row })
	end
	local Btn = Create("TextButton", {
		Text = Obj.Value, TextSize = 12, TextColor3 = Theme.TextDim, BackgroundTransparency = 0, BackgroundColor3 = Theme.Control,
		AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, 0, .5, 0), AutomaticSize = AS_X, Size = UDim2.new(0, 0, 0, 20), Parent = Row,
	}, { Corner(6), Pad(0, 9, 0, 9) })

	function Obj:SetKey(k, silent)
		self.Key = k
		self.Value = KeyName(k)
		Btn.Text = self.Value
		if silent then
			if o.Flag then Library.Flags[o.Flag] = self.Value end
		else
			Fire(o, self)
		end
	end
	function Obj:SetValue(v, silent) self:SetKey(ToKey(v), silent) end

	Btn.MouseButton1Click:Connect(function()
		Btn.Text = "..."
		Btn.TextColor3 = Theme.Text
		Obj._listening = true
		local con
		con = UserInputService.InputBegan:Connect(function(i)
			local k
			if i.UserInputType == Enum.UserInputType.Keyboard then
				k = (i.KeyCode ~= Enum.KeyCode.Escape) and i.KeyCode or nil
			elseif i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.MouseButton2 or i.UserInputType == Enum.UserInputType.MouseButton3 then
				k = i.UserInputType
			else
				return
			end
			con:Disconnect()
			Obj._listening = false
			Btn.TextColor3 = Theme.TextDim
			Obj:SetKey(k)
		end)
	end)

	-- OnPress(state): Toggle = สลับค่า, Hold = true ตอนกด / false ตอนปล่อย
	Connect(UserInputService.InputBegan, function(i, gp)
		if gp or Obj._listening or not Obj.Key then return end
		if i.KeyCode == Obj.Key or i.UserInputType == Obj.Key then
			if Obj.Mode == "Hold" then Obj.State = true else Obj.State = not Obj.State end
			if o.OnPress then task.spawn(o.OnPress, Obj.State) end
		end
	end)
	Connect(UserInputService.InputEnded, function(i)
		if Obj.Mode == "Hold" and Obj.Key and (i.KeyCode == Obj.Key or i.UserInputType == Obj.Key) then
			Obj.State = false
			if o.OnPress then task.spawn(o.OnPress, false) end
		end
	end)

	Register(o, Obj)
	return Common(Obj, Row)
end

-- ───────────── Colorpicker (hue / saturation / alpha / hex) ─────────────
function Elements:AddColorpicker(o)
	o = o or {}
	local title = o.Title or o.Text or "Color"
	local hasAlpha = o.Transparency ~= nil
	local hasDesc = o.Desc ~= nil
	local Obj = { Type = "Colorpicker", Value = o.Default or o.Value or Color3.new(1, 1, 1), Transparency = o.Transparency or 0 }
	local h, s, v = Obj.Value:ToHSV()

	local Row = Create("Frame", { Name = title, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, hasDesc and 36 or 23), LayoutOrder = Order(self.Body), Parent = self.Body })
	Create("TextLabel", {
		Text = title, Position = UDim2.fromOffset(0, hasDesc and 3 or 0),
		Size = UDim2.new(1, -44, hasDesc and 0 or 1, hasDesc and 16 or 0), Parent = Row,
	})
	if hasDesc then
		Create("TextLabel", { Text = o.Desc, TextSize = 11, TextColor3 = Theme.Muted, Position = UDim2.fromOffset(0, 19), Size = UDim2.new(1, -44, 0, 14), Parent = Row })
	end
	local Swatch = Create("TextButton", {
		BackgroundTransparency = 0, BackgroundColor3 = Obj.Value, AnchorPoint = Vector2.new(1, .5),
		Position = UDim2.new(1, 0, .5, 0), Size = UDim2.fromOffset(32, 17), Parent = Row,
	}, { Corner(5), Stroke(Theme.Line, 1) })

	local window = self.Window
	local ui, drag

	local function emit()
		if o.Flag then Library.Flags[o.Flag] = Obj.Value end
		if o.Callback then task.spawn(o.Callback, Obj.Value, Obj.Transparency) end
	end
	local function refresh()
		Obj.Value = Color3.fromHSV(h, s, v)
		Swatch.BackgroundColor3 = Obj.Value
		if ui then
			ui.SV.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
			ui.Cursor.Position = UDim2.fromScale(s, 1 - v)
			ui.HueKnob.Position = UDim2.new(h, 0, .5, 0)
			if ui.Alpha then
				ui.Alpha.BackgroundColor3 = Obj.Value
				ui.AlphaKnob.Position = UDim2.new(Obj.Transparency, 0, .5, 0)
			end
			if not ui.Hex:IsFocused() then ui.Hex.Text = "#" .. Obj.Value:ToHex():upper() end
		end
	end
	function Obj:SetValue(c, t, silent)
		h, s, v = c:ToHSV()
		if t then self.Transparency = t end
		refresh()
		if not silent then emit() end
	end

	local function setFrom(pos)
		if not ui then return end
		if drag == "sv" then
			s = math.clamp((pos.X - ui.SV.AbsolutePosition.X) / ui.SV.AbsoluteSize.X, 0, 1)
			v = 1 - math.clamp((pos.Y - ui.SV.AbsolutePosition.Y) / ui.SV.AbsoluteSize.Y, 0, 1)
		elseif drag == "hue" then
			h = math.clamp((pos.X - ui.Hue.AbsolutePosition.X) / ui.Hue.AbsoluteSize.X, 0, .999)
		elseif drag == "alpha" and ui.Alpha then
			Obj.Transparency = math.clamp((pos.X - ui.Alpha.AbsolutePosition.X) / ui.Alpha.AbsoluteSize.X, 0, 1)
		end
		refresh()
		emit()
	end
	Connect(UserInputService.InputChanged, function(i) if drag and IsMove(i) then setFrom(i.Position) end end)
	Connect(UserInputService.InputEnded, function(i) if drag and IsPress(i) then drag = nil end end)

	local function Hit(parent, kind)
		local b = Create("TextButton", { Size = UDim2.new(1, 0, 1, 8), Position = UDim2.fromOffset(0, -4), ZIndex = 5, Parent = parent })
		b.InputBegan:Connect(function(i)
			if IsPress(i) then drag = kind setFrom(i.Position) end
		end)
	end

	Swatch.MouseButton1Click:Connect(function()
		window:ClosePopup()
		local sc = window.Scale.Scale
		local PW, PH = 200, hasAlpha and 190 or 172
		local abs = (Swatch.AbsolutePosition - window.Popups.AbsolutePosition) / sc
		local sw, sh = Swatch.AbsoluteSize.X / sc, Swatch.AbsoluteSize.Y / sc
		local x = math.max(4, abs.X + sw - PW)
		local y = abs.Y + sh + 4
		if y + PH > window.Main.AbsoluteSize.Y / sc then y = math.max(4, abs.Y - PH - 4) end

		local Panel = Create("Frame", { BackgroundColor3 = Color3.fromRGB(20, 20, 20), Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(PW, PH) }, { Corner(10), Stroke(Theme.Line, 1) })

		local SV = Create("Frame", { BackgroundColor3 = Color3.fromHSV(h, 1, 1), Position = UDim2.fromOffset(10, 10), Size = UDim2.fromOffset(180, 100), Parent = Panel }, { Corner(6) })
		Create("Frame", { BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.fromScale(1, 1), Parent = SV }, {
			Corner(6), Create("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }) }),
		})
		Create("Frame", { BackgroundColor3 = Color3.new(0, 0, 0), Size = UDim2.fromScale(1, 1), Parent = SV }, {
			Corner(6), Create("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }) }),
		})
		local Cursor = Create("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(.5, .5), Size = UDim2.fromOffset(10, 10), ZIndex = 3, Parent = SV }, { Round(), Stroke(Color3.new(1, 1, 1), 2) })
		Hit(SV, "sv")

		local Hue = Create("Frame", { BackgroundColor3 = Color3.new(1, 1, 1), Position = UDim2.fromOffset(10, 120), Size = UDim2.fromOffset(180, 10), Parent = Panel }, {
			Round(),
			Create("UIGradient", { Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)), ColorSequenceKeypoint.new(1 / 6, Color3.fromHSV(1 / 6, 1, 1)),
				ColorSequenceKeypoint.new(2 / 6, Color3.fromHSV(2 / 6, 1, 1)), ColorSequenceKeypoint.new(3 / 6, Color3.fromHSV(3 / 6, 1, 1)),
				ColorSequenceKeypoint.new(4 / 6, Color3.fromHSV(4 / 6, 1, 1)), ColorSequenceKeypoint.new(5 / 6, Color3.fromHSV(5 / 6, 1, 1)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
			}) }),
		})
		local HueKnob = Create("Frame", { BackgroundColor3 = Color3.new(1, 1, 1), AnchorPoint = Vector2.new(.5, .5), Size = UDim2.fromOffset(12, 12), ZIndex = 3, Parent = Hue }, { Round(), Stroke(Color3.fromRGB(20, 20, 20), 1) })
		Hit(Hue, "hue")

		local Alpha, AlphaKnob
		local hexY = 138
		if hasAlpha then
			Alpha = Create("Frame", { BackgroundColor3 = Obj.Value, Position = UDim2.fromOffset(10, 138), Size = UDim2.fromOffset(180, 10), Parent = Panel }, {
				Round(), Create("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, .9) }) }),
			})
			Create("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = Alpha }, { Round(), Stroke(Theme.Line, 1) })
			AlphaKnob = Create("Frame", { BackgroundColor3 = Color3.new(1, 1, 1), AnchorPoint = Vector2.new(.5, .5), Size = UDim2.fromOffset(12, 12), ZIndex = 3, Parent = Alpha }, { Round(), Stroke(Color3.fromRGB(20, 20, 20), 1) })
			Hit(Alpha, "alpha")
			hexY = 156
		end

		local Hex = Create("TextBox", {
			TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center, BackgroundTransparency = 0, BackgroundColor3 = Theme.Control,
			Position = UDim2.fromOffset(10, hexY), Size = UDim2.fromOffset(180, 24), Parent = Panel,
		}, { Corner(6) })
		Hex.FocusLost:Connect(function()
			local ok, c = pcall(Color3.fromHex, (Hex.Text:gsub("#", "")))
			if ok and c then h, s, v = c:ToHSV() end
			refresh()
			emit()
		end)

		ui = { SV = SV, Cursor = Cursor, Hue = Hue, HueKnob = HueKnob, Alpha = Alpha, AlphaKnob = AlphaKnob, Hex = Hex }
		window:OpenPopup(Panel, function() ui = nil drag = nil end)
		refresh()
	end)

	Register(o, Obj)
	return Common(Obj, Row)
end

-- ───────────── Paragraph ─────────────
function Elements:AddParagraph(o)
	o = o or {}
	local Obj = { Type = "Paragraph" }
	local Frame = Create("Frame", {
		Name = o.Title or "Paragraph", BackgroundColor3 = Color3.fromRGB(14, 14, 14), BackgroundTransparency = .15,
		AutomaticSize = AS_Y, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = Order(self.Body), Parent = self.Body,
	}, { Corner(8), List(5), Pad(9, 10, 9, 10) })
	local TitleL
	if o.Title then
		local Head = Create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 1, Parent = Frame },
			{ List(7, HORIZ, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) })
		local ic = o.Icon or o.Image
		if ic then
			local I = Library:Icon(ic, 14, Theme.Text, Head)
			I.Root.LayoutOrder = 0
		end
		TitleL = Create("TextLabel", { Text = o.Title, FontFace = F.Medium, AutomaticSize = AS_X, Size = UDim2.new(0, 0, 1, 0), LayoutOrder = 1, Parent = Head })
	end
	local DescL = Create("TextLabel", {
		Text = o.Desc or "", TextSize = 12, TextColor3 = Theme.SubText, TextWrapped = true, RichText = true,
		AutomaticSize = AS_Y, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 2, Visible = o.Desc ~= nil, Parent = Frame,
	})
	if o.Buttons and #o.Buttons > 0 then
		local BR = Create("Frame", { BackgroundTransparency = 1, AutomaticSize = AS_Y, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 3, Parent = Frame },
			{ List(6, HORIZ, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top) })
		for idx, b in ipairs(o.Buttons) do
			local Btn = Create("TextButton", {
				BackgroundTransparency = 0, BackgroundColor3 = Theme.Button, AutomaticSize = AS_X, Size = UDim2.new(0, 0, 0, 24), LayoutOrder = idx, Parent = BR,
			}, { Corner(6), Pad(0, 10, 0, 10), List(5, HORIZ, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center) })
			if b.Icon then
				local I = Library:Icon(b.Icon, 13, Theme.Text, Btn)
				I.Root.LayoutOrder = 0
			end
			Create("TextLabel", { Text = b.Title or b.Text or "Button", FontFace = F.Medium, TextSize = 12, AutomaticSize = AS_X, Size = UDim2.new(0, 0, 1, 0), LayoutOrder = 1, Parent = Btn })
			Btn.MouseEnter:Connect(function() Tween(Btn, { BackgroundColor3 = Color3.fromRGB(26, 26, 26) }, .12) end)
			Btn.MouseLeave:Connect(function() Tween(Btn, { BackgroundColor3 = Theme.Button }, .12) end)
			Btn.MouseButton1Click:Connect(function() if b.Callback then task.spawn(b.Callback) end end)
		end
	end
	function Obj:SetTitle(t) if TitleL then TitleL.Text = t end end
	function Obj:SetDesc(t) DescL.Text = t DescL.Visible = true end
	return Common(Obj, Frame)
end

-- ───────────── Code ─────────────
function Elements:AddCode(o)
	o = o or {}
	local Obj = { Type = "Code", Code = o.Code or "" }
	local Frame = Create("Frame", {
		Name = o.Title or "Code", BackgroundColor3 = Color3.fromRGB(10, 10, 10), AutomaticSize = AS_Y,
		Size = UDim2.new(1, 0, 0, 0), LayoutOrder = Order(self.Body), Parent = self.Body,
	}, { Corner(8), List(5), Pad(8, 10, 10, 10) })
	local Head = Create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), LayoutOrder = 1, Parent = Frame })
	Create("TextLabel", { Text = o.Title or "Code", FontFace = F.Medium, TextSize = 11, TextColor3 = Theme.SubText, Size = UDim2.new(1, -24, 1, 0), Parent = Head })
	local CopyBtn = Create("TextButton", { AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, 0, .5, 0), Size = UDim2.fromOffset(18, 18), Parent = Head })
	local CopyIcon = Library:Icon("copy", 14, Theme.SubText, CopyBtn)
	CopyIcon.Root.AnchorPoint = Vector2.new(.5, .5)
	CopyIcon.Root.Position = UDim2.fromScale(.5, .5)
	local CodeL = Create("TextLabel", {
		Text = Obj.Code, FontFace = Font.fromEnum(Enum.Font.RobotoMono), TextSize = 12, TextColor3 = Theme.TextDim,
		TextWrapped = true, AutomaticSize = AS_Y, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 2, Parent = Frame,
	})
	CopyBtn.MouseButton1Click:Connect(function()
		local fn = setclipboard or toclipboard or (syn and syn.write_clipboard)
		if fn then pcall(fn, Obj.Code) end
		if o.OnCopy then task.spawn(o.OnCopy) end
		CopyIcon.SetColor(Color3.fromRGB(95, 220, 135), .1)
		task.delay(1, function() CopyIcon.SetColor(Theme.SubText, .2) end)
	end)
	function Obj:SetCode(c) self.Code = c CodeL.Text = c end
	return Common(Obj, Frame)
end

-- ───────────── Divider / Space / Image ─────────────
function Elements:AddDivider()
	local Frame = Create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 9), LayoutOrder = Order(self.Body), Parent = self.Body })
	Create("Frame", { BackgroundColor3 = Theme.Line, BackgroundTransparency = .25, AnchorPoint = Vector2.new(0, .5), Position = UDim2.fromScale(0, .5), Size = UDim2.new(1, 0, 0, 1), Parent = Frame })
	return Common({ Type = "Divider" }, Frame)
end

function Elements:AddSpace(o)
	local n = type(o) == "number" and o or (type(o) == "table" and o.Columns) or 1
	local Frame = Create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, n * 8), LayoutOrder = Order(self.Body), Parent = self.Body })
	return Common({ Type = "Space" }, Frame)
end

function Elements:AddImage(o)
	o = o or {}
	local w, hgt = tostring(o.AspectRatio or "16:9"):match("^(%d+%.?%d*):(%d+%.?%d*)$")
	local ratio = (tonumber(w) or 16) / (tonumber(hgt) or 9)
	local Img = Create("ImageLabel", {
		Name = "Image", BackgroundColor3 = Theme.Control, BackgroundTransparency = o.Image and 1 or 0,
		ImageColor3 = o.Color or Color3.new(1, 1, 1), ScaleType = o.ScaleType or Enum.ScaleType.Crop,
		Size = UDim2.new(1, 0, 0, 0), LayoutOrder = Order(self.Body), Parent = self.Body,
	}, { Corner(o.Radius or 8), Create("UIAspectRatioConstraint", { AspectRatio = ratio, DominantAxis = Enum.DominantAxis.Width }) })
	ResolveImage(o.Image, Img)
	local Obj = { Type = "Image" }
	function Obj:SetImage(src) ResolveImage(src, Img) end
	return Common(Obj, Img)
end

-- ───────────── Section (collapsible group) / Group (columns) ─────────────
function Elements:AddSection(o)
	o = type(o) == "string" and { Title = o } or (o or {})
	local Root = Create("Frame", {
		Name = o.Title or "Section", BackgroundTransparency = 1, AutomaticSize = AS_Y, Size = UDim2.new(1, 0, 0, 0),
		LayoutOrder = Order(self.Body), Parent = self.Body,
	}, { List(6) })
	local Head = Create("TextButton", { Size = UDim2.new(1, 0, 0, o.Desc and 34 or 20), LayoutOrder = 1, Parent = Root })
	Create("TextLabel", { Text = o.Title or "", FontFace = F.SemiBold, TextSize = 12, TextColor3 = Theme.SubText, Size = UDim2.new(1, -20, 0, 20), Parent = Head })
	if o.Desc then
		Create("TextLabel", { Text = o.Desc, TextSize = 11, TextColor3 = Theme.Muted, Position = UDim2.fromOffset(0, 17), Size = UDim2.new(1, -20, 0, 14), Parent = Head })
	end
	local Body = Create("Frame", { BackgroundTransparency = 1, AutomaticSize = AS_Y, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 2, Parent = Root }, { List(6) })
	local C = setmetatable({ Body = Body, Window = self.Window, Frame = Root }, Elements)
	if o.Collapsible ~= false then
		local Chev = Library:Icon("chevron-down", 13, Theme.SubText, Head)
		Chev.Root.AnchorPoint = Vector2.new(.5, .5)
		Chev.Root.Position = UDim2.new(1, -7, 0, 10)
		local open = true
		function C:SetOpen(v)
			open = v
			Body.Visible = v
			Tween(Chev.Root, { Rotation = v and 0 or -90 }, .15)
		end
		Head.MouseButton1Click:Connect(function() C:SetOpen(not open) end)
		if o.Opened == false then C:SetOpen(false) end
	end
	function C:SetVisible(v) Root.Visible = v end
	return C
end

-- แถวหลายคอลัมน์: local G = card:AddGroup({Columns = 2}); G[1]:AddButton{...}; G[2]:AddButton{...}
function Elements:AddGroup(o)
	o = o or {}
	local n = math.max(1, o.Columns or 2)
	local gap = 6
	local Row = Create("Frame", {
		BackgroundTransparency = 1, AutomaticSize = AS_Y, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = Order(self.Body), Parent = self.Body,
	}, { List(gap, HORIZ, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top) })
	local cells = { Frame = Row }
	for i = 1, n do
		local Cell = Create("Frame", {
			BackgroundTransparency = 1, AutomaticSize = AS_Y, Size = UDim2.new(1 / n, -gap * (n - 1) / n, 0, 0), LayoutOrder = i, Parent = Row,
		}, { List(6) })
		cells[i] = setmetatable({ Body = Cell, Window = self.Window, Frame = Cell }, Elements)
	end
	function cells:SetVisible(v) Row.Visible = v end
	return cells
end

function Elements:AddLabel(o)
	o = type(o) == "string" and { Text = o } or (o or {})
	local L = Create("TextLabel", {
		Text = o.Text or "", TextSize = o.Size or 12, TextColor3 = o.Color or Theme.Muted, TextWrapped = true,
		AutomaticSize = AS_Y, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = Order(self.Body), Parent = self.Body,
	})
	return { Root = L, Type = "Label", SetText = function(_, t) L.Text = t end, SetVisible = function(_, v) L.Visible = v end }
end

-- ชื่อแบบ WindUI: card:Button{...}, card:Toggle{...}, card:Colorpicker{...} ใช้ได้เหมือน AddXxx
for _, n in ipairs({ "Button", "Toggle", "Checkbox", "Slider", "Input", "Dropdown", "Paragraph", "Keybind", "Colorpicker", "Code", "Divider", "Space", "Image", "Section", "Group", "Label" }) do
	Elements[n] = Elements["Add" .. n]
end
Elements.HStack = Elements.AddGroup

-- ───────────────────────── Page (tab content) ─────────────────────────
local PageMethods = {}

function PageMethods:_Column(o)
	local c = o.Column or o.Side
	if c == 2 or c == "Right" or c == "right" then return self.Right end
	if c == 1 or c == "Left" or c == "left" then return self.Left end
	self._alt = not self._alt
	return self._alt and self.Left or self.Right
end

function PageMethods:AddCard(o)
	o = o or {}
	local col = self:_Column(o)
	local Frame = Create("Frame", {
		Name = o.Title or "Card", BackgroundColor3 = Theme.Card, BackgroundTransparency = Theme.CardAlpha,
		AutomaticSize = AS_Y, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = Order(col), Parent = col,
	}, { Corner(10) })
	local Head = Create("TextButton", { Size = UDim2.new(1, 0, 0, 38), Parent = Frame })
	if o.Icon then
		local ic = Library:Icon(o.Icon, 16, Theme.Text, Head)
		ic.Root.Position = UDim2.new(0, 13, .5, -8)
	end
	local Title = Create("TextLabel", { Text = o.Title or "", FontFace = F.Medium, TextSize = 14, Position = UDim2.new(0, o.Icon and 38 or 13, 0, 0), Size = UDim2.new(1, -70, 1, 0), Parent = Head })
	local Chev = Library:Icon("chevron-down", 14, Theme.TextDim, Head)
	Chev.Root.AnchorPoint = Vector2.new(.5, .5)
	Chev.Root.Position = UDim2.new(1, -19, .5, 0)
	Create("Frame", { BackgroundColor3 = Theme.Line, BackgroundTransparency = .35, Position = UDim2.new(0, 12, 0, 37), Size = UDim2.new(1, -24, 0, 1), Parent = Frame })
	local Body = Create("Frame", {
		BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 38), AutomaticSize = AS_Y, Size = UDim2.new(1, 0, 0, 0), Parent = Frame,
	}, { List(6), Pad(8, 11, 11, 11) })

	local Card = setmetatable({ Frame = Frame, Body = Body, Window = self.Window }, Elements)
	local open = true
	function Card:SetOpen(v)
		open = v
		Body.Visible = v
		Tween(Chev.Root, { Rotation = v and 0 or -90 }, .15)
	end
	function Card:SetVisible(v) Frame.Visible = v end
	function Card:SetTitle(t) Title.Text = t end
	if o.Collapsible ~= false then Head.MouseButton1Click:Connect(function() Card:SetOpen(not open) end) end
	if o.Open == false then Card:SetOpen(false) end
	return Card
end

function PageMethods:AddTabCard(o)
	o = o or {}
	local col = self:_Column(o)
	local Frame = Create("Frame", {
		Name = "TabCard", BackgroundColor3 = Theme.Card, BackgroundTransparency = Theme.CardAlpha,
		AutomaticSize = AS_Y, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = Order(col), Parent = col,
	}, { Corner(10) })
	local Strip = Create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), Parent = Frame },
		{ List(22, HORIZ, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top), Pad(0, 0, 0, 17) })
	Create("Frame", { BackgroundColor3 = Theme.Line, BackgroundTransparency = .35, Position = UDim2.new(0, 17, 0, 35), Size = UDim2.new(1, -34, 0, 1), Parent = Frame })
	local Wrap = Create("Frame", { BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 36), AutomaticSize = AS_Y, Size = UDim2.new(1, 0, 0, 0), Parent = Frame })

	local TC = { Frame = Frame, Tabs = {}, Window = self.Window }
	local function select(t)
		for _, x in ipairs(TC.Tabs) do
			local on = x == t
			x.Body.Visible = on
			x.Line.Visible = on
			Tween(x.Btn, { TextColor3 = on and Theme.Text or Theme.SubText }, .12)
		end
	end
	function TC:AddTab(name)
		local Btn = Create("TextButton", {
			Text = name, FontFace = F.Medium, TextSize = 13, TextColor3 = Theme.SubText, AutomaticSize = AS_X,
			Size = UDim2.new(0, 0, 0, 40), LayoutOrder = Order(Strip), Parent = Strip,
		})
		local Line = Create("Frame", { BackgroundColor3 = Theme.Accent, Position = UDim2.new(0, 0, 0, 34), Size = UDim2.new(1, 0, 0, 2), Visible = false, Parent = Btn }, { Corner(1) })
		local Body = Create("Frame", { BackgroundTransparency = 1, AutomaticSize = AS_Y, Size = UDim2.new(1, 0, 0, 0), Visible = false, Parent = Wrap },
			{ List(6), Pad(12, 17, 12, 17) })
		local t = setmetatable({ Name = name, Btn = Btn, Line = Line, Body = Body, Window = TC.Window }, Elements)
		table.insert(TC.Tabs, t)
		Btn.MouseButton1Click:Connect(function() select(t) end)
		if #TC.Tabs == 1 then select(t) end
		return t
	end
	function TC:SetVisible(v) Frame.Visible = v end
	return TC
end

function PageMethods:AddConfigCard(o)
	o = o or {}
	local Card = self:AddCard({ Title = o.Title or "Config", Icon = o.Icon or "folder", Column = o.Column })
	local name = ""
	Card:AddInput({ Title = "Config name", Placeholder = "Enter name...", Callback = function(v) name = v end })
	local Dd = Card:AddDropdown({
		Title = "All configs", Options = Library:GetConfigs(), AllowNone = true,
		Callback = function(v) if v then name = v end end,
	})
	local function note(ok, msg) Library:Notify({ Title = ok and "Config" or "Config error", Content = msg, Type = ok and "Success" or "Error" }) end
	local G1 = Card:AddGroup({ Columns = 2 })
	G1[1]:AddButton({ Title = "Save", Icon = "save", Callback = function()
		if name == "" then return note(false, "Enter a config name first") end
		local ok, err = Library:SaveConfig(name)
		note(ok, ok and ("Saved " .. name) or tostring(err))
		Dd:SetOptions(Library:GetConfigs())
	end })
	G1[2]:AddButton({ Title = "Load", Icon = "folder-open", Callback = function()
		if name == "" then return note(false, "Select a config first") end
		local ok, err = Library:LoadConfig(name)
		note(ok, ok and ("Loaded " .. name) or tostring(err))
	end })
	local G2 = Card:AddGroup({ Columns = 2 })
	G2[1]:AddButton({ Title = "Delete", Icon = "trash", Color = Color3.fromRGB(120, 28, 28), Callback = function()
		if name == "" then return note(false, "Select a config first") end
		Library:DeleteConfig(name)
		Dd:SetOptions(Library:GetConfigs())
		Dd:SetValue(nil, true)
		note(true, "Deleted " .. name)
	end })
	G2[2]:AddButton({ Title = "Refresh", Icon = "refresh-cw", Callback = function() Dd:SetOptions(Library:GetConfigs()) end })
	return Card
end
PageMethods.Card = PageMethods.AddCard

local function MakePage(window)
	local Page = Create("ScrollingFrame", {
		Name = "Page", Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.new(), AutomaticCanvasSize = AS_Y,
		ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(90, 90, 90), ScrollingDirection = Enum.ScrollingDirection.Y,
		Visible = false, Parent = window._Pages,
	}, { Pad(0, 0, 11, 0) })
	local Left = Create("Frame", { Name = "Left", BackgroundTransparency = 1, AutomaticSize = AS_Y, Position = UDim2.new(0, 11, 0, 0), Size = UDim2.new(.5, -17, 0, 0), Parent = Page }, { List(12) })
	local Right = Create("Frame", { Name = "Right", BackgroundTransparency = 1, AutomaticSize = AS_Y, Position = UDim2.new(.5, 6, 0, 0), Size = UDim2.new(.5, -17, 0, 0), Parent = Page }, { List(12) })
	return Page, Left, Right
end

-- ───────────────────────── Notifications ─────────────────────────
local NotifyHolder
local NotifyTypes = {
	Info = { "info", Theme.Text },
	Success = { "circle-check", Color3.fromRGB(95, 220, 135) },
	Warning = { "triangle-alert", Color3.fromRGB(255, 190, 70) },
	Error = { "circle-x", Color3.fromRGB(255, 90, 90) },
}

function Library:Notify(o)
	o = o or {}
	if not NotifyHolder or not NotifyHolder.Parent then
		local gui = NewGui("BlushUI_Notify")
		NotifyHolder = Create("Frame", {
			AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -20, 1, -20), Size = UDim2.new(0, 402, 1, -40),
			BackgroundTransparency = 1, Parent = gui,
		}, { List(8, VERT, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom) })
		local sc = Create("UIScale", { Parent = NotifyHolder })
		local function fit() sc.Scale = math.clamp((gui.AbsoluteSize.Y - 24) / 600, .4, 1) end
		fit()
		gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
	end
	local kind = NotifyTypes[o.Type or "Info"] or NotifyTypes.Info
	local dur = o.Duration or 4

	local Holder = Create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 89), LayoutOrder = Order(NotifyHolder), Parent = NotifyHolder })
	local Card = Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(14, 14, 14), BackgroundTransparency = .03,
		Position = UDim2.new(1, 60, 0, 0), Size = UDim2.fromScale(1, 1), Parent = Holder,
	}, { Corner(15), Stroke(Color3.fromRGB(38, 38, 38), 1) })
	local IconBox = Create("Frame", { BackgroundColor3 = Color3.fromRGB(34, 34, 34), Position = UDim2.new(0, 20, 0, 23), Size = UDim2.fromOffset(43, 43), Parent = Card }, { Corner(10) })
	local ic = Library:Icon(o.Icon or kind[1], 22, kind[2], IconBox)
	ic.Root.AnchorPoint = Vector2.new(.5, .5)
	ic.Root.Position = UDim2.fromScale(.5, .5)
	Create("TextLabel", { Text = o.Title or "Info", FontFace = F.Bold, TextSize = 16, Position = UDim2.new(0, 75, 0, 17), Size = UDim2.new(1, -120, 0, 20), Parent = Card })
	Create("TextLabel", {
		Text = o.Content or "", TextSize = 14, TextColor3 = Theme.TextDim, TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.new(0, 75, 0, 45), Size = UDim2.new(1, -90, 0, 18), Parent = Card,
	})
	local Close = Create("TextButton", { Position = UDim2.new(1, -36, 0, 12), Size = UDim2.fromOffset(24, 24), Parent = Card })
	local xi = Library:Icon("x", 14, Theme.TextDim, Close)
	xi.Root.AnchorPoint = Vector2.new(.5, .5)
	xi.Root.Position = UDim2.fromScale(.5, .5)
	local Bar = Create("Frame", { BackgroundColor3 = Color3.fromRGB(190, 190, 190), Position = UDim2.new(0, 20, 0, 80), Size = UDim2.new(1, -40, 0, 3), Parent = Card }, { Round() })

	local closed = false
	local Obj = {}
	function Obj:Close()
		if closed then return end
		closed = true
		Tween(Card, { Position = UDim2.new(1, 60, 0, 0) }, .2)
		task.delay(.2, function()
			local t = Tween(Holder, { Size = UDim2.new(1, 0, 0, 0) }, .15)
			t.Completed:Wait()
			Holder:Destroy()
		end)
	end
	Close.MouseButton1Click:Connect(function() Obj:Close() end)

	Tween(Card, { Position = UDim2.new(0, 0, 0, 0) }, .25, Enum.EasingStyle.Back)
	Tween(Bar, { Size = UDim2.new(0, 0, 0, 3) }, dur, Enum.EasingStyle.Linear)
	task.delay(dur, function() Obj:Close() end)
	return Obj
end

-- ───────────────────────── Window ─────────────────────────
function Library:CreateWindow(o)
	o = o or {}
	local Window = { Library = Library, Visible = true }
	local WSize = o.Size or Vector2.new(820, 600)
	local SB, HEADER, FOOT = 190, 55, 79

	local Gui = NewGui("BlushUI")
	Window.Gui = Gui
	local Main = Create("Frame", {
		Name = "Window", AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
		Size = UDim2.fromOffset(WSize.X, WSize.Y), BackgroundTransparency = 1, Parent = Gui,
	})
	local Scale = Create("UIScale", { Parent = Main })
	Window.Main, Window.Scale = Main, Scale
	local function Fit()
		local vp = Gui.AbsoluteSize
		if vp.X > 0 then Scale.Scale = math.clamp(math.min((vp.X - 24) / WSize.X, (vp.Y - 24) / WSize.Y), .35, 1) end
	end
	Fit()
	Connect(Gui:GetPropertyChangedSignal("AbsoluteSize"), Fit)

	-- content background (extends under the sidebar so only the right corners show)
	local geo = { Position = UDim2.new(0, SB - 24, 0, 0), Size = UDim2.new(1, -(SB - 24), 1, 0) }
	Create("Frame", { Name = "ContentBG", BackgroundColor3 = Theme.Content, BackgroundTransparency = o.Background and 0 or .05, Position = geo.Position, Size = geo.Size, ZIndex = 1, Parent = Main }, { Corner(12) })
	local BGImage = Create("ImageLabel", {
		Name = "BGImage", Image = o.Background or "", ImageTransparency = o.BackgroundTransparency or .3, ScaleType = Enum.ScaleType.Crop,
		Position = geo.Position, Size = geo.Size, ZIndex = 1, Visible = o.Background ~= nil, Parent = Main,
	}, { Corner(12) })
	function Window:SetBackground(img)
		BGImage.Image = img or ""
		BGImage.Visible = img ~= nil
	end

	-- sidebar
	local Sidebar = Create("Frame", { Name = "Sidebar", BackgroundColor3 = Theme.Sidebar, Size = UDim2.new(0, SB, 1, 0), ZIndex = 3, Parent = Main }, { Corner(12) })
	Create("Frame", { BackgroundColor3 = Theme.Sidebar, Position = UDim2.new(1, -14, 0, 0), Size = UDim2.new(0, 14, 1, 0), Parent = Sidebar })

	local Profile = Create("Frame", { Name = "Profile", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 68), Parent = Sidebar })
	local Av = Create("ImageLabel", { BackgroundTransparency = 0, BackgroundColor3 = Theme.Control, Position = UDim2.fromOffset(15, 14), Size = UDim2.fromOffset(40, 40), Parent = Profile }, { Round() })
	SetAvatar(Av, o.Avatar)
	Create("TextLabel", { Text = o.Name or "blush.", FontFace = F.Bold, TextSize = 15, Position = UDim2.fromOffset(65, 13), Size = UDim2.new(1, -75, 0, 20), Parent = Profile })
	Create("TextLabel", { Text = o.Subtitle or "", FontFace = F.Medium, TextSize = 11, TextColor3 = Theme.SubText, Position = UDim2.fromOffset(65, 35), Size = UDim2.new(1, -75, 0, 14), Parent = Profile })

	local Nav = Create("ScrollingFrame", {
		Name = "Nav", Position = UDim2.new(0, 0, 0, 68), Size = UDim2.new(1, 0, 1, -(68 + FOOT)), CanvasSize = UDim2.new(),
		AutomaticCanvasSize = AS_Y, ScrollBarThickness = 0, Parent = Sidebar,
	}, { List(18), Pad(8, 0, 8, 0) })

	-- footer (user / expiry)
	if o.User ~= false then
		local u = o.User or {}
		local Foot = Create("Frame", { Name = "Footer", BackgroundTransparency = 1, Position = UDim2.new(0, 0, 1, -FOOT), Size = UDim2.new(1, 0, 0, FOOT), Parent = Sidebar })
		Create("Frame", { BackgroundColor3 = Color3.fromRGB(30, 30, 30), Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -26, 0, 1), Parent = Foot })
		local fa = Create("ImageLabel", { BackgroundTransparency = 0, BackgroundColor3 = Theme.Control, Position = UDim2.new(0, 15, .5, -20), Size = UDim2.fromOffset(40, 40), Parent = Foot }, { Round() })
		SetAvatar(fa, u.Avatar)
		Create("TextLabel", { Text = u.Name or LocalPlayer.Name, FontFace = F.SemiBold, TextSize = 12, Position = UDim2.new(0, 65, .5, -19), Size = UDim2.new(1, -75, 0, 16), Parent = Foot })
		if u.Value then
			Create("TextLabel", {
				Text = (u.Label or "Expires:") .. ' <font color="#ffffff"><b>' .. u.Value .. "</b></font>", RichText = true,
				TextSize = 12, TextColor3 = Theme.TextDim, Position = UDim2.new(0, 65, .5, 1), Size = UDim2.new(1, -75, 0, 16), Parent = Foot,
			})
		end
	end

	-- content
	local Content = Create("Frame", { Name = "Content", BackgroundTransparency = 1, Position = UDim2.new(0, SB, 0, 0), Size = UDim2.new(1, -SB, 1, 0), ZIndex = 2, Parent = Main })
	local Header = Create("Frame", { Name = "Header", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, HEADER), Parent = Content })
	local Crumb = Create("Frame", { BackgroundTransparency = 1, Position = UDim2.new(0, 11, 0, 0), Size = UDim2.new(1, -200, 1, 0), Parent = Header },
		{ List(8, HORIZ, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) })
	local Buttons = Create("Frame", {
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -12, 0, 28),
		Size = UDim2.new(0, 0, 0, 32), AutomaticSize = AS_X, Parent = Header,
	}, { List(8, HORIZ, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) })
	Window._Pages = Create("Frame", { Name = "Pages", BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, HEADER), Size = UDim2.new(1, 0, 1, -HEADER), Parent = Content })

	function Window:SetBreadcrumb(parts)
		for _, c in ipairs(Crumb:GetChildren()) do
			if not c:IsA("UIListLayout") and c.Name ~= "Tag" then c:Destroy() end
		end
		for i, p in ipairs(parts) do
			if i > 1 then
				local ic = Library:Icon("chevron-right", 14, Theme.Muted, Crumb)
				ic.Root.LayoutOrder = i * 2 - 1
			end
			Create("TextLabel", {
				Text = p, FontFace = F.Bold, TextSize = 17, TextColor3 = (i == #parts and #parts > 1) and Theme.TextDim or Theme.Text,
				AutomaticSize = AS_X, Size = UDim2.new(0, 0, 1, 0), LayoutOrder = i * 2, Parent = Crumb,
			})
		end
	end

	function Window:AddHeaderButton(b)
		b = b or {}
		local Btn = Create("TextButton", {
			Name = b.Name or b.Icon or "Button", BackgroundTransparency = 0, BackgroundColor3 = Theme.Control,
			Size = UDim2.fromOffset(32, 32), LayoutOrder = Order(Buttons), Parent = Buttons,
		}, { Corner(8) })
		local ic = Library:Icon(b.Icon or "circle", 16, Theme.TextDim, Btn)
		ic.Root.AnchorPoint = Vector2.new(.5, .5)
		ic.Root.Position = UDim2.fromScale(.5, .5)
		Btn.MouseEnter:Connect(function() Tween(Btn, { BackgroundColor3 = Theme.ControlHover }, .12) ic.SetColor(Theme.Text, .12) end)
		Btn.MouseLeave:Connect(function() Tween(Btn, { BackgroundColor3 = Theme.Control }, .12) ic.SetColor(Theme.TextDim, .12) end)
		Btn.MouseButton1Click:Connect(function() if b.Callback then task.spawn(b.Callback) end end)
		local Badge = Create("Frame", {
			BackgroundColor3 = Theme.Danger, AnchorPoint = Vector2.new(.5, .5), Position = UDim2.new(1, -3, 0, 3),
			Size = UDim2.fromOffset(14, 14), ZIndex = 5, Visible = false, Parent = Btn,
		}, { Round() })
		local BadgeText = Create("TextLabel", { FontFace = F.Bold, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), Parent = Badge })
		local Obj = { Button = Btn }
		function Obj:SetBadge(n)
			Badge.Visible = n ~= nil and n ~= 0
			BadgeText.Text = tostring(n or "")
		end
		if b.Badge then Obj:SetBadge(b.Badge) end
		return Obj
	end

	-- popups (dropdown lists)
	Window.Popups = Create("Frame", { Name = "Popups", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 50, Visible = false, Parent = Main })
	local Catcher = Create("TextButton", { AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromScale(4, 4), ZIndex = 1, Parent = Window.Popups })
	function Window:ClosePopup()
		if self._popup then self._popup:Destroy() self._popup = nil end
		self.Popups.Visible = false
		if self._onClose then local f = self._onClose self._onClose = nil f() end
	end
	function Window:OpenPopup(frame, onClose)
		self:ClosePopup()
		frame.ZIndex = 2
		frame.Active = true
		frame.Parent = self.Popups
		self._popup, self._onClose = frame, onClose
		self.Popups.Visible = true
	end
	Catcher.MouseButton1Click:Connect(function() Window:ClosePopup() end)

	function Window:LockScroll(lock)
		if self.CurrentPage then self.CurrentPage.ScrollingEnabled = not lock end
	end

	-- dragging
	local function MakeDraggable(handle)
		local dragging, startMouse, startPos
		handle.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				dragging, startMouse, startPos = true, i.Position, Main.Position
				i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
			end
		end)
		Connect(UserInputService.InputChanged, function(i)
			if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				local d = (i.Position - startMouse) / Scale.Scale
				Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end)
	end
	MakeDraggable(Header)
	MakeDraggable(Profile)

	-- sections / tabs
	local function NewTab(container, t, parentTab)
		local level = parentTab and 1 or 0
		local Tab = setmetatable({ Name = t.Name, Parent = parentTab, Window = Window, Subs = {} }, { __index = PageMethods })
		local Holder = Create("Frame", { Name = t.Name, BackgroundTransparency = 1, AutomaticSize = AS_Y, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = Order(container), Parent = container }, { List(6) })
		local Btn = Create("TextButton", { Size = UDim2.new(1, 0, 0, 32), LayoutOrder = 1, Parent = Holder })
		local ix = level == 0 and 24 or 38
		local icon = Library:Icon(t.Icon or "circle", 16, Theme.NavInactive, Btn)
		icon.Root.Position = UDim2.new(0, ix, .5, -8)
		local text = Create("TextLabel", {
			Text = t.Name, FontFace = F.Medium, TextSize = level == 0 and 14 or 13, TextColor3 = Theme.NavInactive,
			Position = UDim2.new(0, ix + 26, 0, 0), Size = UDim2.new(1, -(ix + 26), 1, 0), Parent = Btn,
		})
		local bar = Create("Frame", {
			BackgroundColor3 = Theme.Text, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, .5),
			Position = UDim2.new(0, 9, .5, 0), Size = UDim2.fromOffset(3, 0), Parent = Btn,
		}, { Round() })

		Tab.Page, Tab.Left, Tab.Right = MakePage(Window)

		function Tab:_Paint()
			local cur = Window.Current
			local isSel = cur == Tab
			local active = isSel or (cur ~= nil and cur.Parent == Tab)
			local c = active and Theme.Text or Theme.NavInactive
			icon.SetColor(c, .15)
			Tween(text, { TextColor3 = c }, .15)
			Tween(bar, { Size = UDim2.fromOffset(3, isSel and 18 or 0), BackgroundTransparency = isSel and 0 or 1 }, .15)
		end

		Btn.MouseEnter:Connect(function()
			if Window.Current ~= Tab then Tween(text, { TextColor3 = Theme.Text }, .1) icon.SetColor(Theme.Text, .1) end
		end)
		Btn.MouseLeave:Connect(function() Tab:_Paint() end)

		Btn.MouseButton1Click:Connect(function()
			if Tab.SubHolder then
				local vis = not Tab.SubHolder.Visible
				Tab.SubHolder.Visible = vis
				local cur = Window.Current
				if vis and not (cur and cur.Parent == Tab) and Tab.Subs[1] then Window:SelectTab(Tab.Subs[1]) end
			else
				Window:SelectTab(Tab)
			end
		end)

		function Tab:AddSubTab(st)
			if not Tab.SubHolder then
				Tab.SubHolder = Create("Frame", { BackgroundTransparency = 1, AutomaticSize = AS_Y, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 2, Parent = Holder }, { List(0) })
			end
			local sub = NewTab(Tab.SubHolder, st, Tab)
			table.insert(Tab.Subs, sub)
			if Window.Current == Tab then Window:SelectTab(sub) end
			return sub
		end

		Tab.Holder = Holder
		table.insert(Window.Tabs or {}, Tab)
		if level == 0 and not Window.Current then Window:SelectTab(Tab) end
		return Tab
	end
	Window.Tabs = {}

	function Window:SelectTab(tab)
		local old = self.Current
		if old == tab then return end
		if old then old.Page.Visible = false end
		self:ClosePopup()
		self.Current = tab
		tab.Page.Visible = true
		self.CurrentPage = tab.Page
		self:SetBreadcrumb(tab.Parent and { tab.Parent.Name, tab.Name } or { tab.Name })
		if old then
			old:_Paint()
			if old.Parent then old.Parent:_Paint() end
		end
		tab:_Paint()
		if tab.Parent then tab.Parent:_Paint() end
	end

	function Window:AddSection(name)
		local Section = { Name = name }
		local Frame = Create("Frame", { Name = name, BackgroundTransparency = 1, AutomaticSize = AS_Y, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = Order(Nav), Parent = Nav }, { List(6) })
		local Head = Create("TextButton", { Size = UDim2.new(1, 0, 0, 24), LayoutOrder = 0, Parent = Frame })
		Create("TextLabel", { Text = name, FontFace = F.Medium, TextColor3 = Theme.SubText, Position = UDim2.new(0, 23, 0, 0), Size = UDim2.new(1, -60, 1, 0), Parent = Head })
		local Chev = Library:Icon("chevron-down", 14, Theme.SubText, Head)
		Chev.Root.AnchorPoint = Vector2.new(.5, .5)
		Chev.Root.Position = UDim2.new(1, -28, .5, 0)
		local Body = Create("Frame", { Name = "Body", BackgroundTransparency = 1, AutomaticSize = AS_Y, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 1, Parent = Frame }, { List(6) })
		local open = true
		Head.MouseButton1Click:Connect(function()
			open = not open
			Body.Visible = open
			Tween(Chev.Root, { Rotation = open and 0 or -90 }, .15)
		end)
		function Section:AddTab(t) return NewTab(Body, t, nil) end
		return Section
	end

	-- toggle key / tag / dialog (WindUI style)
	Window.ToggleKey = o.ToggleKey or Enum.KeyCode.RightShift
	function Window:SetToggleKey(k) self.ToggleKey = k end

	function Window:Tag(t)
		t = type(t) == "string" and { Title = t } or (t or {})
		local Chip = Create("Frame", {
			Name = "Tag", BackgroundColor3 = t.Color or Theme.Control, AutomaticSize = AS_X, Size = UDim2.new(0, 0, 0, 20),
			LayoutOrder = 1000 + Order(Crumb), Parent = Crumb,
		}, { Corner(6), Pad(0, 8, 0, 8) })
		Create("TextLabel", {
			Text = t.Title or "", FontFace = F.SemiBold, TextSize = 11, TextColor3 = t.TextColor or Theme.Text,
			AutomaticSize = AS_X, Size = UDim2.new(0, 0, 1, 0), Parent = Chip,
		})
		return { Root = Chip, SetTitle = function(_, x) Chip:FindFirstChildOfClass("TextLabel").Text = x end }
	end

	-- Dialog: Window:Dialog({Title, Content, Icon, Buttons = {{Title, Variant = "Primary"|"Secondary", Callback}}})
	function Window:Dialog(d)
		d = d or {}
		local Overlay = Create("TextButton", { BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 60, Parent = Main }, { Corner(12) })
		Tween(Overlay, { BackgroundTransparency = .45 }, .15)
		local Panel = Create("Frame", {
			BackgroundColor3 = Color3.fromRGB(16, 16, 16), AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
			Size = UDim2.new(0, 320, 0, 0), AutomaticSize = AS_Y, Parent = Overlay,
		}, { Corner(12), Stroke(Theme.Line, 1), List(10), Pad(16, 16, 16, 16) })
		local Head = Create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 1, Parent = Panel },
			{ List(8, HORIZ, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) })
		if d.Icon then
			local I = Library:Icon(d.Icon, 18, Theme.Text, Head)
			I.Root.LayoutOrder = 0
		end
		Create("TextLabel", { Text = d.Title or "Dialog", FontFace = F.Bold, TextSize = 15, AutomaticSize = AS_X, Size = UDim2.new(0, 0, 1, 0), LayoutOrder = 1, Parent = Head })
		if d.Content then
			Create("TextLabel", { Text = d.Content, TextSize = 13, TextColor3 = Theme.SubText, TextWrapped = true, RichText = true, AutomaticSize = AS_Y, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 2, Parent = Panel })
		end
		local Btns = Create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28), LayoutOrder = 3, Parent = Panel },
			{ List(8, HORIZ, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center) })
		local Obj = {}
		function Obj:Close() Overlay:Destroy() end
		for idx, b in ipairs(d.Buttons or { { Title = "OK", Variant = "Primary" } }) do
			local primary = b.Variant == "Primary"
			local Btn = Create("TextButton", {
				Text = b.Title or "OK", FontFace = F.Medium, TextSize = 13, TextColor3 = primary and Color3.fromRGB(10, 10, 10) or Theme.Text,
				BackgroundTransparency = 0, BackgroundColor3 = primary and Theme.Accent or Theme.Control,
				AutomaticSize = AS_X, Size = UDim2.new(0, 0, 0, 28), LayoutOrder = idx, Parent = Btns,
			}, { Corner(8), Pad(0, 14, 0, 14) })
			Btn.MouseButton1Click:Connect(function()
				Obj:Close()
				if b.Callback then task.spawn(b.Callback) end
			end)
		end
		return Obj
	end
	Window.Popup = Window.Dialog

	-- stats bar (top center)
	if o.StatsBar then
		local sb = type(o.StatsBar) == "table" and o.StatsBar or { Items = { o.Name or "blush." } }
		local Bar = Create("Frame", {
			Name = "StatsBar", BackgroundColor3 = Color3.fromRGB(10, 10, 10), AnchorPoint = Vector2.new(.5, 0),
			Position = UDim2.new(.5, 0, 0, -10), Size = UDim2.new(0, 0, 0, 38), AutomaticSize = AS_X, Parent = Gui,
		}, { Corner(9), List(0, HORIZ, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Bottom) })
		local n = 0
		local function item(text, bold)
			n += 1
			if n > 1 then
				local s = Create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(0, 1, 0, 28), LayoutOrder = n * 2 - 1, Parent = Bar })
				Create("Frame", { BackgroundColor3 = Color3.fromRGB(55, 55, 55), Position = UDim2.new(0, 0, .5, -7), Size = UDim2.new(1, 0, 0, 14), Parent = s })
			end
			return Create("TextLabel", {
				Text = text, FontFace = bold and F.Bold or F.Medium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center,
				AutomaticSize = AS_X, Size = UDim2.new(0, 0, 0, 28), LayoutOrder = n * 2, Parent = Bar,
			}, { Pad(0, 12, 0, 12) })
		end
		for idx, t in ipairs(sb.Items or {}) do item(t, idx == 1) end
		local fpsL = sb.FPS ~= false and item("0 fps")
		local pingL = sb.Ping ~= false and item("0 ms")
		local timeL = sb.Time ~= false and item(os.date("%H:%M"))
		local frames, last = 0, os.clock()
		Connect(RunService.RenderStepped, function()
			frames += 1
			local now = os.clock()
			if now - last >= .5 then
				if fpsL then fpsL.Text = math.floor(frames / (now - last) + .5) .. " fps" end
				if pingL then
					local ok, v = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
					pingL.Text = (ok and math.floor(v + .5) or 0) .. " ms"
				end
				if timeL then timeL.Text = os.date("%H:%M") end
				frames, last = 0, now
			end
		end)
		Window.StatsBar = Bar
	end

	-- toggle (key + mobile button)
	function Window:Toggle(v)
		if v == nil then v = not self.Visible end
		self.Visible = v
		Main.Visible = v
		if not v then self:ClosePopup() end
	end
	Connect(UserInputService.InputBegan, function(i, gp)
		if gp then return end
		if i.KeyCode == Window.ToggleKey then Window:Toggle() end
	end)
	if o.MobileButton ~= false and UserInputService.TouchEnabled then
		local TB = Create("TextButton", {
			BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(10, 10, 10), Position = UDim2.new(1, -56, 0, 56),
			Size = UDim2.fromOffset(38, 38), Parent = Gui,
		}, { Corner(10), Stroke(Theme.Line, 1) })
		local ic = Library:Icon("sparkles", 18, Theme.Text, TB)
		ic.Root.AnchorPoint = Vector2.new(.5, .5)
		ic.Root.Position = UDim2.fromScale(.5, .5)
		TB.MouseButton1Click:Connect(function() Window:Toggle() end)
	end

	Window.Notify = function(_, n) return Library:Notify(n) end
	table.insert(Library.Windows, Window)
	return Window
end

-- ───────────────────────── Config (save / load) ─────────────────────────
Library.ConfigFolder = "BlushUI/configs"

local function CanFS()
	return writefile and readfile and isfile and isfolder and makefolder and listfiles and true or false
end
local function EnsureFolder()
	local path = ""
	for part in Library.ConfigFolder:gmatch("[^/]+") do
		path = path == "" and part or (path .. "/" .. part)
		if not isfolder(path) then makefolder(path) end
	end
end
local function CfgPath(name) return Library.ConfigFolder .. "/" .. name .. ".json" end

function Library:GetConfigs()
	if not CanFS() then return {} end
	local out = {}
	pcall(function()
		EnsureFolder()
		for _, f in ipairs(listfiles(Library.ConfigFolder)) do
			local n = f:gsub("\\", "/"):match("([^/]+)%.json$")
			if n then table.insert(out, n) end
		end
	end)
	table.sort(out)
	return out
end

function Library:SaveConfig(name)
	if not CanFS() then return false, "executor ไม่รองรับ writefile" end
	local data = {}
	for flag, obj in pairs(self.Options) do
		local t = obj.Type
		if t == "Checkbox" or t == "Toggle" or t == "Slider" or t == "Input" or t == "Keybind" then
			data[flag] = obj.Value
		elseif t == "Dropdown" then
			data[flag] = obj.Multi and obj.GetSelected() or obj.Value
		elseif t == "Colorpicker" then
			data[flag] = { obj.Value.R, obj.Value.G, obj.Value.B, obj.Transparency }
		end
	end
	local ok, err = pcall(function()
		EnsureFolder()
		writefile(CfgPath(name), HttpService:JSONEncode(data))
	end)
	return ok, err
end

function Library:LoadConfig(name)
	if not CanFS() then return false, "executor ไม่รองรับ readfile" end
	local path = CfgPath(name)
	if not isfile(path) then return false, "ไม่พบ config: " .. tostring(name) end
	local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
	if not ok then return false, "config เสียหาย" end
	for flag, val in pairs(data) do
		local obj = self.Options[flag]
		if obj then
			pcall(function()
				if obj.Type == "Colorpicker" then obj:SetValue(Color3.new(val[1], val[2], val[3]), val[4])
				else obj:SetValue(val) end
			end)
		end
	end
	return true
end

function Library:DeleteConfig(name)
	if CanFS() and delfile and isfile(CfgPath(name)) then pcall(delfile, CfgPath(name)) end
end

function Library:Unload()
	for _, c in ipairs(self._conns) do pcall(function() c:Disconnect() end) end
	for _, g in ipairs(self._guis) do pcall(function() g:Destroy() end) end
	table.clear(self._conns)
	table.clear(self._guis)
	NotifyHolder = nil
end

return Library
