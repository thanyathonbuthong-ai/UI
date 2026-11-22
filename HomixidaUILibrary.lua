--[[
	Homixida UI Library  (LocalScript)
	วางใน StarterPlayer > StarterPlayerScripts  หรือ StarterGui

	ฟีเจอร์:
	  - หน้าต่างธีมมืด ลากได้ + ปุ่มย่อ/ปิด + กด RightShift เพื่อซ่อน/แสดง
	  - Sidebar มี Category + Tab (สลับหน้าได้)
	  - Section (แผงซ้าย/ขวา) พร้อม header ไล่เฉด
	  - Toggle (checkbox), Slider, Dropdown (เลือกเดียว/หลายค่า), Textbox,
	    Button, Label, Color Picker (Hue/Sat + Value + Alpha + Hex/RGBA + Select/Cancel)

	ตัวอย่างการใช้งานอยู่ท้ายไฟล์ (ส่วน DEMO)
]]

--// Services ----------------------------------------------------------------
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

--// Theme -------------------------------------------------------------------
local Theme = {
	Window    = Color3.fromRGB(19, 19, 19),
	Panel     = Color3.fromRGB(26, 26, 26),
	HeaderA   = Color3.fromRGB(44, 44, 44),
	HeaderB   = Color3.fromRGB(30, 30, 30),
	Control   = Color3.fromRGB(33, 33, 33),
	PopupBg   = Color3.fromRGB(24, 24, 24),
	Stroke    = Color3.fromRGB(44, 44, 44),
	TabActive = Color3.fromRGB(30, 30, 30),
	Text      = Color3.fromRGB(235, 235, 235),
	SubText   = Color3.fromRGB(125, 125, 125),
	Dim       = Color3.fromRGB(70, 70, 70),
	Check     = Color3.fromRGB(240, 240, 240),
	CheckMark = Color3.fromRGB(20, 20, 20),
	Accent    = Color3.fromRGB(10, 88, 200),
}
local FONT      = Enum.Font.GothamMedium
local FONT_BOLD = Enum.Font.GothamBold

--// Helpers -----------------------------------------------------------------
local function New(class, props, parent)
	local obj = Instance.new(class)
	for k, v in pairs(props or {}) do
		obj[k] = v
	end
	if parent then obj.Parent = parent end
	return obj
end

local function Corner(parent, radius)
	return New("UICorner", { CornerRadius = UDim.new(0, radius or 4) }, parent)
end

local function Stroke(parent, color, thickness)
	return New("UIStroke", {
		Color = color or Theme.Stroke,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, parent)
end

local function Tween(obj, time, props)
	TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function IsPress(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

local function IsMove(input)
	return input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
end

local function Inside(gui, pos)
	local p, s = gui.AbsolutePosition, gui.AbsoluteSize
	return pos.X >= p.X and pos.X <= p.X + s.X and pos.Y >= p.Y and pos.Y <= p.Y + s.Y
end

local function Decimals(n)
	local d = tostring(n):match("%.(%d+)")
	return d and #d or 0
end

--// Icons --------------------------------------------------------------------
-- ไอคอนทั้งหมดวาดจาก Frame/UICorner/UIStroke (ไม่ใช้อิโมจิหรือตัวอักษรพิเศษ
-- และไม่ต้องพึ่ง asset id) ไอคอนที่มีให้: check, chevron, close, minimize,
-- person, group, eye, globe, target
local function MakeIcon(name, parent, px, color)
	local s = px / 14                       -- ออกแบบบนกริด 14x14 แล้วสเกลตามขนาดจริง
	local th = math.max(1, 1.4 * s)         -- ความหนาเส้น
	local holder = New("Frame", {
		Name = "Icon_" .. name,
		Size = UDim2.fromOffset(px, px),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
	}, parent)
	local fills, strokes = {}, {}

	-- แท่ง / วงกลมทึบ (round = 0.5 -> วงกลมหรือแคปซูล)
	local function bar(w, h, cx, cy, rot, round)
		local f = New("Frame", {
			Size = UDim2.fromOffset(w * s, h * s),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(cx * s, cy * s),
			Rotation = rot or 0,
			BackgroundColor3 = color,
			BorderSizePixel = 0,
		}, holder)
		if round then New("UICorner", { CornerRadius = UDim.new(round, 0) }, f) end
		table.insert(fills, f)
	end

	-- กรอบเส้นเปล่า (วงกลม / สี่เหลี่ยมมน)
	local function outline(w, h, cx, cy, round)
		local f = New("Frame", {
			Size = UDim2.fromOffset(w * s - th * 2, h * s - th * 2),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(cx * s, cy * s),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, holder)
		New("UICorner", { CornerRadius = UDim.new(round or 0.5, 0) }, f)
		table.insert(strokes, New("UIStroke", { Color = color, Thickness = th }, f))
	end

	if name == "check" then
		bar(1.8, 4.6, 4, 8.5, -45)
		bar(1.8, 9, 8.5, 7, 45)
	elseif name == "chevron" then
		bar(1.6, 5.2, 5.25, 7.75, -45)
		bar(1.6, 5.2, 8.75, 7.75, 45)
	elseif name == "close" then
		bar(1.6, 12, 7, 7, 45)
		bar(1.6, 12, 7, 7, -45)
	elseif name == "minimize" then
		bar(10, 1.6, 7, 7)
	elseif name == "person" then
		bar(5, 5, 7, 4.2, 0, 0.5)
		bar(9.5, 5, 7, 11, 0, 0.5)
	elseif name == "group" then
		bar(4, 4, 5, 4.5, 0, 0.5)
		bar(7.5, 4.2, 5, 10.8, 0, 0.5)
		bar(3.4, 3.4, 10.2, 5, 0, 0.5)
		bar(5, 3.6, 10.5, 10.9, 0, 0.5)
	elseif name == "eye" then
		outline(13, 8, 7, 7, 0.5)
		bar(4, 4, 7, 7, 0, 0.5)
	elseif name == "globe" then
		outline(12.5, 12.5, 7, 7, 0.5)
		outline(5, 12.5, 7, 7, 0.5)
		bar(12.5, 1.2, 7, 7)
	elseif name == "target" then
		outline(12.5, 12.5, 7, 7, 0.5)
		outline(6, 6, 7, 7, 0.5)
		bar(2, 2, 7, 7, 0, 0.5)
	elseif name == "lock" then
		outline(5.6, 6.4, 7, 4.6, 0.5)
		bar(9, 6.4, 7, 9.6, 0, 0.18)
	elseif name == "copy" then
		outline(8, 9, 5.4, 5.8, 0.15)
		outline(8, 9, 8.8, 8.6, 0.15)
	elseif name == "search" then
		outline(8.5, 8.5, 6, 6, 0.5)
		bar(1.7, 5, 10.7, 10.7, -45)
	elseif name == "info" then
		outline(12.5, 12.5, 7, 7, 0.5)
		bar(1.6, 1.6, 7, 4.3, 0, 0.5)
		bar(1.6, 4, 7, 8.2)
	elseif name == "grid" then
		bar(4.6, 4.6, 4.2, 4.2, 0, 0.2)
		bar(4.6, 4.6, 9.8, 4.2, 0, 0.2)
		bar(4.6, 4.6, 4.2, 9.8, 0, 0.2)
		bar(4.6, 4.6, 9.8, 9.8, 0, 0.2)
	elseif name == "keyboard" then
		outline(13, 8.5, 7, 7, 0.2)
		bar(7, 1.4, 7, 7)
	else
		outline(10, 10, 7, 7, 0.5)
	end

	local icon = { Holder = holder }
	function icon:SetColor(c)
		for _, f in ipairs(fills) do f.BackgroundColor3 = c end
		for _, st in ipairs(strokes) do st.Color = c end
	end
	return icon
end

local Flags = {}   -- ค่าทั้งหมดที่ตั้ง Flag ไว้ จะอ่านได้จาก Library.Flags

local function SetFlag(cfg, value)
	if cfg.Flag then Flags[cfg.Flag] = value end
end

--// Library tables -----------------------------------------------------------
local Library = { Flags = Flags }
local Window  = {}; Window.__index  = Window
local Tab     = {}; Tab.__index     = Tab
local Section = {}; Section.__index = Section

--=============================================================================
--  WINDOW
--=============================================================================
function Library:CreateWindow(cfg)
	cfg = cfg or {}
	local self = setmetatable({}, Window)
	self._conns = {}
	self._order = 0
	self.Tabs = {}
	self.ActiveTab = nil
	self.ToggleKey = cfg.ToggleKey or Enum.KeyCode.RightShift

	-- ลบ UI เก่าถ้ามี (กันซ้ำตอนรันใหม่)
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	local old = playerGui:FindFirstChild("HomixidaUI")
	if old then old:Destroy() end

	local gui = New("ScreenGui", {
		Name = "HomixidaUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 100,
	}, playerGui)
	self.Gui = gui

	local size = cfg.Size or UDim2.fromOffset(700, 440)
	local root = New("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = size,
		BackgroundColor3 = Theme.Window,
		BorderSizePixel = 0,
	}, gui)
	Corner(root, 6)
	Stroke(root, Color3.fromRGB(36, 36, 36))
	self.Root = root

	-- ย่อหน้าต่างอัตโนมัติถ้าจอเล็ก (มือถือ)
	local scale = New("UIScale", {}, root)
	local function fit()
		local vp = gui.AbsoluteSize
		scale.Scale = math.min(1, (vp.X - 20) / size.X.Offset, (vp.Y - 20) / size.Y.Offset)
	end
	fit()
	self:_on(gui:GetPropertyChangedSignal("AbsoluteSize"), fit)

	------------------------------------------------------------------ Sidebar
	New("TextLabel", {
		Name = "Title",
		Size = UDim2.new(0, 145, 0, 46),
		BackgroundTransparency = 1,
		Text = cfg.Title or "@homixida",
		TextColor3 = Theme.Text,
		Font = FONT,
		TextSize = 17,
	}, root)

	New("Frame", { -- เส้นแบ่ง sidebar
		Position = UDim2.new(0, 145, 0, 14),
		Size = UDim2.new(0, 1, 1, -28),
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BorderSizePixel = 0,
	}, root)

	local nav = New("ScrollingFrame", {
		Name = "Nav",
		Position = UDim2.fromOffset(0, 50),
		Size = UDim2.new(0, 145, 1, -56),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, root)
	New("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, nav)
	New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, nav)
	self.Nav = nav

	----------------------------------------------------------------- Content
	local content = New("Frame", {
		Name = "Content",
		Position = UDim2.fromOffset(153, 14),
		Size = UDim2.new(1, -161, 1, -28),
		BackgroundTransparency = 1,
	}, root)
	self.Content = content

	------------------------------------------------- Drag handle + header btns
	local dragTop = New("Frame", {
		Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1,
	}, root)
	self:_makeDraggable(dragTop)
	self:_makeDraggable(root:FindFirstChild("Title"))

	local function headerButton(iconName, xOffset, onClick)
		local b = New("TextButton", {
			Size = UDim2.fromOffset(20, 14),
			Position = UDim2.new(1, xOffset, 0, 1),
			BackgroundTransparency = 1,
			Text = "",
			ZIndex = 3,
		}, root)
		local ic = MakeIcon(iconName, b, 10, Theme.Dim)
		b.MouseEnter:Connect(function() ic:SetColor(Theme.Text) end)
		b.MouseLeave:Connect(function() ic:SetColor(Theme.Dim) end)
		b.MouseButton1Click:Connect(onClick)
		return b
	end
	headerButton("close", -26, function() self:Destroy() end)             -- ปิด (ลบ UI)
	headerButton("minimize", -48, function() self:SetVisible(false) end)  -- ย่อ (ซ่อน; กดปุ่ม ToggleKey เพื่อเปิดกลับ)

	---------------------------------------------------------- Global inputs
	-- คลิกนอก popup = ปิด popup
	self:_on(UserInputService.InputBegan, function(input, processed)
		if self.Popup and IsPress(input) then
			if not Inside(self.Popup.Frame, input.Position) and not Inside(self.Popup.Owner, input.Position) then
				self:ClosePopup()
			end
		end
		-- ปุ่มซ่อน/แสดง
		if not processed and not self._binding and input.KeyCode == self.ToggleKey then
			self:SetVisible(not root.Visible)
		end
	end)

	return self
end

function Window:_on(signal, fn)
	local c = signal:Connect(fn)
	table.insert(self._conns, c)
	return c
end

function Window:_next()
	self._order += 1
	return self._order
end

-- ลากหน้าต่างด้วย handle
function Window:_makeDraggable(handle)
	local dragging, startMouse, startPos = false, nil, nil
	self:_on(handle.InputBegan, function(input)
		if IsPress(input) then
			dragging = true
			startMouse = input.Position
			startPos = self.Root.Position
			self:ClosePopup()
		end
	end)
	self:_on(UserInputService.InputChanged, function(input)
		if dragging and IsMove(input) then
			local d = input.Position - startMouse
			self.Root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
	self:_on(UserInputService.InputEnded, function(input)
		if IsPress(input) then dragging = false end
	end)
end

-- ลากบน control (slider / color picker)
function Window:_bindDrag(obj, onInput, onEnd)
	local active = false
	self:_on(obj.InputBegan, function(input)
		if IsPress(input) then
			active = true
			onInput(input.Position)
		end
	end)
	self:_on(UserInputService.InputChanged, function(input)
		if active and IsMove(input) then onInput(input.Position) end
	end)
	self:_on(UserInputService.InputEnded, function(input)
		if active and IsPress(input) then
			active = false
			if onEnd then onEnd() end
		end
	end)
end

function Window:SetVisible(v)
	self.Root.Visible = v
	if not v then self:ClosePopup() end
end

function Window:Destroy()
	self:ClosePopup()
	for _, c in ipairs(self._conns) do c:Disconnect() end
	self.Gui:Destroy()
end

function Window:ClosePopup()
	local p = self.Popup
	if not p then return end
	self.Popup = nil
	if p.OnClose then p.OnClose() end
	if p.Persistent then p.Frame.Visible = false else p.Frame:Destroy() end
end

--// Sidebar: Category label --------------------------------------------------
function Window:AddCategory(name)
	New("TextLabel", {
		Size = UDim2.new(1, 0, 0, 22),
		BackgroundTransparency = 1,
		Text = name,
		TextColor3 = Theme.Dim,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = FONT,
		TextSize = 10,
		LayoutOrder = self:_next(),
	}, self.Nav)
end

--// Sidebar: Tab --------------------------------------------------------------
function Window:AddTab(cfg)
	cfg = type(cfg) == "string" and { Name = cfg } or cfg
	cfg.Name = cfg.Name or cfg.Title
	local tab = setmetatable({ Window = self, Name = cfg.Name, Active = false }, Tab)

	local btn = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundColor3 = Theme.TabActive,
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = self:_next(),
	}, self.Nav)
	Corner(btn, 4)

	tab.Bar = New("Frame", { -- แถบขาวซ้ายตอนเลือก
		Size = UDim2.fromOffset(2, 16),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		BackgroundColor3 = Theme.Text,
		BorderSizePixel = 0,
		Visible = false,
	}, btn)

	-- ไอคอน: Icon = ชื่อไอคอนที่มีให้ ("person","group","eye","globe","target")
	--         หรือ "rbxassetid://..." เพื่อใช้รูปของคุณเอง
	local iconHost = New("Frame", {
		Size = UDim2.fromOffset(14, 14),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 12, 0.5, 0),
		BackgroundTransparency = 1,
	}, btn)
	local iconSpec = cfg.Icon or "person"
	if string.find(iconSpec, "rbxasset", 1, true) then
		local img = New("ImageLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = iconSpec,
			ImageColor3 = Theme.SubText,
		}, iconHost)
		tab.SetIconColor = function(c) img.ImageColor3 = c end
	else
		local ic = MakeIcon(iconSpec, iconHost, 14, Theme.SubText)
		tab.SetIconColor = function(c) ic:SetColor(c) end
	end

	tab.Label = New("TextLabel", {
		Position = UDim2.fromOffset(34, 0),
		Size = UDim2.new(1, -34, 1, 0),
		BackgroundTransparency = 1,
		Text = cfg.Name,
		TextColor3 = Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = FONT,
		TextSize = 12,
	}, btn)
	tab.Button = btn

	-- หน้าเนื้อหา (2 คอลัมน์)
	local page = New("Frame", {
		Name = "Page_" .. cfg.Name,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
	}, self.Content)
	tab.Page = page

	local function column(side)
		local col = New("ScrollingFrame", {
			Name = side,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = Theme.Dim,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(0.5, -4.5, 1, 0),
			Position = side == "Left" and UDim2.new() or UDim2.new(0.5, 4.5, 0, 0),
		}, page)
		New("UIListLayout", { Padding = UDim.new(0, 9), SortOrder = Enum.SortOrder.LayoutOrder }, col)
		return col
	end
	tab.Columns = { Left = column("Left"), Right = column("Right") }

	btn.MouseEnter:Connect(function()
		if not tab.Active then Tween(tab.Label, 0.1, { TextColor3 = Color3.fromRGB(190, 190, 190) }) end
	end)
	btn.MouseLeave:Connect(function()
		if not tab.Active then Tween(tab.Label, 0.1, { TextColor3 = Theme.SubText }) end
	end)
	btn.MouseButton1Click:Connect(function() self:SelectTab(tab) end)

	table.insert(self.Tabs, tab)
	if not self.ActiveTab then self:SelectTab(tab) end
	return tab
end

function Window:SelectTab(tab)
	self:ClosePopup()
	for _, t in ipairs(self.Tabs) do
		local on = (t == tab)
		t.Active = on
		t.Page.Visible = on
		t.Bar.Visible = on
		Tween(t.Button, 0.15, { BackgroundTransparency = on and 0 or 1 })
		Tween(t.Label, 0.15, { TextColor3 = on and Theme.Text or Theme.SubText })
		t.SetIconColor(on and Theme.Text or Theme.SubText)
	end
	self.ActiveTab = tab
end

--=============================================================================
--  SECTION (แผง)
--=============================================================================
-- cfg: Name, Side = "Left" | "Right", MinHeight
function Tab:AddSection(cfg)
	cfg = type(cfg) == "string" and { Name = cfg } or (cfg or {})
	local sec = setmetatable({ Window = self.Window, Tab = self, _o = 0 }, Section)
	local col = self.Columns[cfg.Side or "Left"]

	local frame = New("Frame", {
		Name = "Section_" .. (cfg.Name or ""),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		LayoutOrder = #col:GetChildren(),
	}, col)
	Corner(frame, 4)
	New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, frame)
	if cfg.MinHeight then
		New("UISizeConstraint", { MinSize = Vector2.new(0, cfg.MinHeight) }, frame)
	end

	local header = New("Frame", {
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		LayoutOrder = 1,
	}, frame)
	Corner(header, 4)
	New("UIGradient", { Color = ColorSequence.new(Theme.HeaderA, Theme.HeaderB) }, header)
	New("TextLabel", {
		Size = UDim2.new(1, -24, 1, 0),
		Position = UDim2.fromOffset(12, 0),
		BackgroundTransparency = 1,
		Text = cfg.Name or cfg.Title or "Section",
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = FONT,
		TextSize = 12,
	}, header)

	local body = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 2,
	}, frame)
	New("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, body)
	New("UIPadding", {
		PaddingTop = UDim.new(0, 11), PaddingBottom = UDim.new(0, 12),
		PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
	}, body)

	-- Collapsible = true: คลิกหัวแผงเพื่อพับ/ขยาย (Open = false เพื่อเริ่มแบบพับ)
	if cfg.Collapsible then
		local arrowHost = New("Frame", {
			Size = UDim2.fromOffset(16, 16), AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -8, 0.5, 0), BackgroundTransparency = 1,
		}, header)
		local arrow = MakeIcon("chevron", arrowHost, 12, Theme.SubText).Holder
		local hb = New("TextButton", {
			Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 2,
		}, header)
		local open = cfg.Open ~= false
		body.Visible = open
		arrow.Rotation = open and 0 or -90
		hb.MouseButton1Click:Connect(function()
			open = not open
			body.Visible = open
			Tween(arrow, 0.15, { Rotation = open and 0 or -90 })
		end)
	end

	sec.Frame, sec.Body = frame, body
	return sec
end

function Section:_next()
	self._o += 1
	return self._o
end

--=============================================================================
--  COLOR PICKER (ใช้ตัวเดียวร่วมกันทั้งหน้าต่าง)
--=============================================================================
function Window:_getPicker()
	if self._picker then return self._picker end
	local win = self
	local P = { h = 0, s = 0, v = 1, a = 1 }

	local frame = New("Frame", {
		Name = "ColorPicker",
		Size = UDim2.fromOffset(196, 244),
		BackgroundColor3 = Theme.PopupBg,
		BorderSizePixel = 0,
		Visible = false,
		Active = true,
		ZIndex = 100,
	}, self.Gui)
	Corner(frame, 5)
	Stroke(frame, Theme.Stroke)
	P.Frame = frame

	New("TextLabel", {
		Position = UDim2.fromOffset(11, 7), Size = UDim2.fromOffset(120, 16),
		BackgroundTransparency = 1, Text = "Pick a colour", TextColor3 = Color3.fromRGB(210, 210, 210),
		TextXAlignment = Enum.TextXAlignment.Left, Font = FONT, TextSize = 11,
	}, frame)

	-- Hue (แกน X) / Saturation (แกน Y)
	local sq = New("TextButton", {
		Position = UDim2.fromOffset(11, 28), Size = UDim2.fromOffset(175, 111),
		BackgroundColor3 = Color3.new(1, 1, 1), Text = "", AutoButtonColor = false, BorderSizePixel = 0,
	}, frame)
	Corner(sq, 3)
	local keys = {}
	for i = 0, 6 do
		table.insert(keys, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 1, 1)))
	end
	New("UIGradient", { Color = ColorSequence.new(keys) }, sq)
	local white = New("Frame", {
		Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
	}, sq)
	Corner(white, 3)
	New("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0) }, white)
	local cursor = New("Frame", {
		Size = UDim2.fromOffset(9, 9), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1,
	}, sq)
	Corner(cursor, 5)
	New("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 1.5 }, cursor)

	-- Value bar
	local vBar = New("TextButton", {
		Position = UDim2.fromOffset(11, 144), Size = UDim2.fromOffset(175, 11),
		BackgroundColor3 = Color3.new(1, 1, 1), Text = "", AutoButtonColor = false, BorderSizePixel = 0,
	}, frame)
	Corner(vBar, 3)
	local vGrad = New("UIGradient", { Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(1, 1, 1)) }, vBar)
	local vHandle = New("Frame", {
		Size = UDim2.fromOffset(3, 15), AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(1, 0.5), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
	}, vBar)
	Stroke(vHandle, Color3.fromRGB(20, 20, 20))

	-- Alpha bar (พื้นหมากรุก + ไล่ความโปร่งใส)
	local aHolder = New("Frame", {
		Position = UDim2.fromOffset(11, 159), Size = UDim2.fromOffset(175, 10),
		BackgroundColor3 = Color3.fromRGB(205, 205, 205), BorderSizePixel = 0, ClipsDescendants = true,
	}, frame)
	Corner(aHolder, 3)
	for i = 0, 34 do
		for j = 0, 1 do
			if (i + j) % 2 == 1 then
				New("Frame", {
					Position = UDim2.fromOffset(i * 5, j * 5), Size = UDim2.fromOffset(5, 5),
					BackgroundColor3 = Color3.fromRGB(140, 140, 140), BorderSizePixel = 0,
				}, aHolder)
			end
		end
	end
	local aBar = New("TextButton", {
		Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1),
		Text = "", AutoButtonColor = false, BorderSizePixel = 0,
	}, aHolder)
	New("UIGradient", { Transparency = NumberSequence.new(1, 0) }, aBar)
	local aHandle = New("Frame", {
		Size = UDim2.fromOffset(3, 14), AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(1, 0.5), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 2,
	}, aHolder)
	Stroke(aHandle, Color3.fromRGB(20, 20, 20))

	-- ช่อง Hex / R / G / B / A
	local function field(x, w, label)
		New("TextLabel", {
			Position = UDim2.fromOffset(x, 175), Size = UDim2.fromOffset(w, 12), BackgroundTransparency = 1,
			Text = label, TextColor3 = Theme.SubText, Font = FONT, TextSize = 9,
		}, frame)
		local box = New("TextBox", {
			Position = UDim2.fromOffset(x, 189), Size = UDim2.fromOffset(w, 18),
			BackgroundColor3 = Theme.Control, BorderSizePixel = 0, Text = "",
			TextColor3 = Theme.Text, Font = FONT, TextSize = 10, ClearTextOnFocus = false,
		}, frame)
		Corner(box, 3)
		Stroke(box, Color3.fromRGB(40, 40, 40))
		return box
	end
	local hexBox = field(11, 40, "Hex")
	local rBox   = field(54, 30, "R")
	local gBox   = field(87, 30, "G")
	local bBox   = field(120, 30, "B")
	local aBox   = field(153, 30, "A")

	local selectBtn = New("TextButton", {
		Position = UDim2.fromOffset(11, 216), Size = UDim2.fromOffset(50, 18),
		BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Text = "Select",
		TextColor3 = Color3.new(1, 1, 1), Font = FONT, TextSize = 11, AutoButtonColor = true,
	}, frame)
	Corner(selectBtn, 3)
	local cancelBtn = New("TextButton", {
		Position = UDim2.fromOffset(68, 216), Size = UDim2.fromOffset(50, 18),
		BackgroundTransparency = 1, Text = "Cancel",
		TextColor3 = Color3.fromRGB(200, 200, 200), Font = FONT, TextSize = 11,
	}, frame)

	------------------------------------------------------------------ refresh
	local function toByte(x) return math.clamp(math.floor(x * 255 + 0.5), 0, 255) end

	function P.refresh()
		local col = Color3.fromHSV(P.h, P.s, P.v)
		cursor.Position = UDim2.fromScale(P.h, 1 - P.s)
		vGrad.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.fromHSV(P.h, P.s, 1))
		vHandle.Position = UDim2.fromScale(P.v, 0.5)
		aBar.BackgroundColor3 = col
		aHandle.Position = UDim2.fromScale(P.a, 0.5)
		local r, g, b = toByte(col.R), toByte(col.G), toByte(col.B)
		hexBox.Text = string.format("%02x%02x%02x", r, g, b)
		rBox.Text, gBox.Text, bBox.Text, aBox.Text = tostring(r), tostring(g), tostring(b), tostring(toByte(P.a))
		if P.target then P.target:_preview(col, P.a) end
	end

	local function setRGB(r, g, b)
		P.h, P.s, P.v = Color3.fromRGB(r, g, b):ToHSV()
		P.refresh()
	end

	self:_bindDrag(sq, function(pos)
		local ap, sz = sq.AbsolutePosition, sq.AbsoluteSize
		P.h = math.clamp((pos.X - ap.X) / sz.X, 0, 1)
		P.s = 1 - math.clamp((pos.Y - ap.Y) / sz.Y, 0, 1)
		P.refresh()
	end)
	self:_bindDrag(vBar, function(pos)
		P.v = math.clamp((pos.X - vBar.AbsolutePosition.X) / vBar.AbsoluteSize.X, 0, 1)
		P.refresh()
	end)
	self:_bindDrag(aBar, function(pos)
		P.a = math.clamp((pos.X - aBar.AbsolutePosition.X) / aBar.AbsoluteSize.X, 0, 1)
		P.refresh()
	end)

	hexBox.FocusLost:Connect(function()
		local t = (hexBox.Text:gsub("#", ""))
		if #t == 6 and tonumber(t, 16) then
			setRGB(tonumber(t:sub(1, 2), 16), tonumber(t:sub(3, 4), 16), tonumber(t:sub(5, 6), 16))
		else
			P.refresh()
		end
	end)
	local function rgbChanged()
		local r = math.clamp(tonumber(rBox.Text) or 0, 0, 255)
		local g = math.clamp(tonumber(gBox.Text) or 0, 0, 255)
		local b = math.clamp(tonumber(bBox.Text) or 0, 0, 255)
		setRGB(r, g, b)
	end
	rBox.FocusLost:Connect(rgbChanged)
	gBox.FocusLost:Connect(rgbChanged)
	bBox.FocusLost:Connect(rgbChanged)
	aBox.FocusLost:Connect(function()
		P.a = math.clamp((tonumber(aBox.Text) or 255), 0, 255) / 255
		P.refresh()
	end)

	selectBtn.MouseButton1Click:Connect(function()
		local sw = P.target
		if sw then
			P.committed = true
			sw.Value = Color3.fromHSV(P.h, P.s, P.v)
			sw.Alpha = P.a
			sw:_preview(sw.Value, sw.Alpha)
			if sw.Callback then task.spawn(sw.Callback, sw.Value, sw.Alpha) end
		end
		win:ClosePopup()
	end)
	cancelBtn.MouseButton1Click:Connect(function() win:ClosePopup() end)

	self._picker = P
	return P
end

function Window:_openPicker(sw)
	local P = self:_getPicker()
	self:ClosePopup()

	P.target = sw
	P.committed = false
	P.h, P.s, P.v = sw.Value:ToHSV()
	P.a = sw.Alpha

	-- วาง popup ใต้ swatch ชิดขอบขวา (กันไม่ให้หลุดจอ)
	local ap, sz = sw.Frame.AbsolutePosition, sw.Frame.AbsoluteSize
	local vp = self.Gui.AbsoluteSize
	local x = math.clamp(ap.X + sz.X - 196, 4, math.max(4, vp.X - 200))
	local y = math.clamp(ap.Y + sz.Y + 10, 4, math.max(4, vp.Y - 248))
	P.Frame.Position = UDim2.fromOffset(x, y)
	P.Frame.Visible = true
	P.refresh()

	self.Popup = {
		Frame = P.Frame, Owner = sw.Frame, Persistent = true,
		OnClose = function()
			if not P.committed then sw:_preview(sw.Value, sw.Alpha) end -- Cancel = คืนค่าเดิม
		end,
	}
end

-- สร้างช่องสี (swatch) ไว้ใน parent
function Window:_newSwatch(parent, cfg)
	local win = self
	local sw = {
		Value = cfg.Default or Color3.fromRGB(123, 111, 255),
		Alpha = cfg.Alpha or (cfg.Transparency and (1 - cfg.Transparency)) or 1,
		Callback = cfg.Callback,
	}
	local btn = New("TextButton", {
		Size = UDim2.fromOffset(30, 14),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		BackgroundColor3 = sw.Value,
		BackgroundTransparency = 1 - sw.Alpha,
		Text = "",
		AutoButtonColor = false,
	}, parent)
	Corner(btn, 3)
	Stroke(btn, Color3.fromRGB(50, 50, 50))
	sw.Frame = btn

	function sw:_preview(c, a)
		btn.BackgroundColor3 = c
		btn.BackgroundTransparency = math.clamp(1 - a, 0, 0.92)
	end
	function sw:Set(color, alpha, silent)
		sw.Value, sw.Alpha = color, alpha or sw.Alpha
		sw:_preview(sw.Value, sw.Alpha)
		SetFlag(cfg, { Color = sw.Value, Alpha = sw.Alpha })
		if not silent and sw.Callback then task.spawn(sw.Callback, sw.Value, sw.Alpha) end
	end
	SetFlag(cfg, { Color = sw.Value, Alpha = sw.Alpha })

	btn.MouseButton1Click:Connect(function()
		if win.Popup and win.Popup.Owner == btn then
			win:ClosePopup()
		else
			win:_openPicker(sw)
		end
	end)
	return sw
end

--=============================================================================
--  CONTROLS  (องค์ประกอบสไตล์ WindUI แต่ดีไซน์เป็นของ Homixida)
--
--  Section:AddToggle     Type = "Checkbox" | "Switch", Desc, Locked, :AddColorPicker()
--  Section:AddButton     Desc, Icon, Justify = "Left" | "Center" | "Right", Locked
--  Section:AddSlider     Step, Value = {Min, Max, Default}, พิมพ์ตัวเลขในช่องค่าได้
--  Section:AddInput      Type = "Input" | "Textarea", Numeric, Placeholder
--  Section:AddDropdown   Multi (เลือกหลายอัน), Searchable (ค้นหา), AllowNone, :Refresh()
--  Section:AddKeybind    Mode = "Toggle" | "Hold" | "Always"
--  Section:AddColorPicker, AddParagraph, AddCode, AddImage, AddLabel, AddDivider, AddSpace
--  Window:Notify (toast)  /  Window:Dialog (หน้าต่างยืนยัน)
--
--  ทุก element รับชื่อพารามิเตอร์ได้ทั้ง Title/Name และ Value/Default
--  และมีเมธอด :SetTitle :SetDesc :SetVisible :Lock :Unlock :Destroy
--=============================================================================

-- คืนค่าแรกที่ไม่ใช่ nil (รองรับชื่อพารามิเตอร์แบบ WindUI)
local function Pick(cfg, ...)
	for _, k in ipairs({ ... }) do
		if cfg[k] ~= nil then return cfg[k] end
	end
	return nil
end

-- ฟังก์ชันที่ทุก element ใช้ร่วมกัน (SetTitle / Lock / Destroy ...)
local function Common(el, holder, cfg, titleLabel, descLabel)
	el.Holder = holder
	function el:SetTitle(t)
		if titleLabel then titleLabel.Text = t end
	end
	function el:SetDesc(t)
		if descLabel then
			descLabel.Text = t or ""
			descLabel.Visible = t ~= nil and t ~= ""
		end
	end
	function el:SetVisible(v) holder.Visible = v end
	function el:Destroy() holder:Destroy() end

	local overlay
	function el:Lock()
		if overlay then return end
		el.Locked = true
		overlay = New("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Theme.Panel,
			BackgroundTransparency = 0.35,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 10,
		}, holder)
		Corner(overlay, 4)
		local host = New("Frame", {
			Size = UDim2.fromOffset(16, 16), AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -6, 0.5, 0), BackgroundTransparency = 1,
		}, overlay)
		MakeIcon("lock", host, 12, Theme.SubText)
	end
	function el:Unlock()
		if overlay then overlay:Destroy(); overlay = nil end
		el.Locked = false
	end
	if cfg.Locked then el:Lock() end
	return el
end

-- ป้ายชื่อ + คำอธิบาย (ใช้ใน toggle/keybind/slider ...)
local function TitleBlock(parent, title, desc)
	local titleLabel = New("TextLabel", {
		Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Text = title,
		TextColor3 = Color3.fromRGB(225, 225, 225), TextXAlignment = Enum.TextXAlignment.Left,
		Font = FONT, TextSize = 12, LayoutOrder = 1,
	}, parent)
	local hasDesc = desc ~= nil and desc ~= ""
	local descLabel = New("TextLabel", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, Text = desc or "", Visible = hasDesc,
		TextColor3 = Theme.SubText, TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
		Font = FONT, TextSize = 10, LayoutOrder = 2,
	}, parent)
	return titleLabel, descLabel
end

---------------------------------------------------------------------- Toggle
-- cfg: Title/Name, Desc, Value/Default, Type = "Checkbox"|"Switch", Callback(bool), Flag, Locked
function Section:AddToggle(cfg)
	cfg = type(cfg) == "string" and { Title = cfg } or cfg
	local win = self.Window
	local isSwitch = cfg.Type == "Switch"
	local toggle = { Value = false }

	local row = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 22), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, Text = "", AutoButtonColor = false, LayoutOrder = self:_next(),
	}, self.Body)

	local text = New("Frame", {
		Position = UDim2.fromOffset(isSwitch and 0 or 28, 0),
		Size = UDim2.new(1, isSwitch and -50 or -70, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
	}, row)
	New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, text)
	local titleLabel, descLabel = TitleBlock(text, Pick(cfg, "Title", "Name") or "Toggle", cfg.Desc)

	local box, boxStroke, mark, track, knob
	if isSwitch then
		track = New("Frame", {
			Size = UDim2.fromOffset(30, 16), AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0, 11), BackgroundColor3 = Theme.Control, BorderSizePixel = 0,
		}, row)
		Corner(track, 8)
		boxStroke = Stroke(track, Color3.fromRGB(48, 48, 48))
		knob = New("Frame", {
			Size = UDim2.fromOffset(12, 12), AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 2, 0.5, 0), BackgroundColor3 = Theme.SubText, BorderSizePixel = 0,
		}, track)
		Corner(knob, 6)
	else
		box = New("Frame", {
			Size = UDim2.fromOffset(18, 18), AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0, 11), BackgroundColor3 = Theme.Control, BorderSizePixel = 0,
		}, row)
		Corner(box, 4)
		boxStroke = Stroke(box, Color3.fromRGB(48, 48, 48))
		mark = MakeIcon("check", box, 14, Theme.CheckMark).Holder
		mark.Visible = false
	end

	function toggle:Set(v, silent)
		local on = v and true or false
		toggle.Value = on
		SetFlag(cfg, on)
		if isSwitch then
			Tween(track, 0.12, { BackgroundColor3 = on and Theme.Check or Theme.Control })
			Tween(knob, 0.12, {
				Position = on and UDim2.new(1, -14, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
				BackgroundColor3 = on and Theme.CheckMark or Theme.SubText,
			})
		else
			Tween(box, 0.12, { BackgroundColor3 = on and Theme.Check or Theme.Control })
			mark.Visible = on
		end
		boxStroke.Color = on and Theme.Check or Color3.fromRGB(48, 48, 48)
		if not silent and cfg.Callback then task.spawn(cfg.Callback, on) end
	end

	-- เพิ่มช่องสีด้านขวาของ toggle นี้
	function toggle:AddColorPicker(ccfg)
		local host = New("Frame", {
			Size = UDim2.fromOffset(30, 14), AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, isSwitch and -42 or 0, 0, 11), BackgroundTransparency = 1,
		}, row)
		text.Size = UDim2.new(1, isSwitch and -84 or -70, 0, 0)
		toggle.Color = win:_newSwatch(host, ccfg or {})
		return toggle.Color
	end

	row.MouseButton1Click:Connect(function() toggle:Set(not toggle.Value) end)
	toggle:Set(Pick(cfg, "Value", "Default") or false, true)
	return Common(toggle, row, cfg, titleLabel, descLabel)
end

---------------------------------------------------------------------- Button
-- cfg: Title/Name, Desc, Icon, Justify = "Left"|"Center"|"Right", Callback, Locked
function Section:AddButton(cfg)
	cfg = type(cfg) == "string" and { Title = cfg } or cfg
	local btnObj = {}
	local hasIcon = cfg.Icon ~= nil

	local b = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 26), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Control, BorderSizePixel = 0, Text = "",
		AutoButtonColor = false, LayoutOrder = self:_next(),
	}, self.Body)
	Corner(b, 4)
	local st = Stroke(b, Color3.fromRGB(40, 40, 40))
	New("UIPadding", {
		PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
		PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5),
	}, b)

	local icon
	if hasIcon then
		local host = New("Frame", {
			Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0, 8), BackgroundTransparency = 1,
		}, b)
		icon = MakeIcon(cfg.Icon, host, 14, Theme.SubText)
	end

	local text = New("Frame", {
		Position = UDim2.fromOffset(hasIcon and 22 or 0, 0),
		Size = UDim2.new(1, hasIcon and -22 or 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
	}, b)
	New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, text)
	local titleLabel = New("TextLabel", {
		Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1,
		Text = Pick(cfg, "Title", "Name") or "Button",
		TextColor3 = Theme.Text, Font = FONT, TextSize = 11, LayoutOrder = 1,
	}, text)
	local descLabel = New("TextLabel", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
		Text = cfg.Desc or "", Visible = cfg.Desc ~= nil and cfg.Desc ~= "",
		TextColor3 = Theme.SubText, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
		Font = FONT, TextSize = 10, LayoutOrder = 2,
	}, text)
	local align = ({
		Left = Enum.TextXAlignment.Left, Center = Enum.TextXAlignment.Center, Right = Enum.TextXAlignment.Right,
	})[cfg.Justify or "Left"]
	titleLabel.TextXAlignment, descLabel.TextXAlignment = align, align

	b.MouseEnter:Connect(function()
		Tween(b, 0.1, { BackgroundColor3 = Color3.fromRGB(42, 42, 42) })
		st.Color = Color3.fromRGB(70, 70, 70)
		if icon then icon:SetColor(Theme.Text) end
	end)
	b.MouseLeave:Connect(function()
		Tween(b, 0.1, { BackgroundColor3 = Theme.Control })
		st.Color = Color3.fromRGB(40, 40, 40)
		if icon then icon:SetColor(Theme.SubText) end
	end)
	b.MouseButton1Down:Connect(function() Tween(b, 0.06, { BackgroundColor3 = Color3.fromRGB(56, 56, 56) }) end)
	b.MouseButton1Up:Connect(function() Tween(b, 0.1, { BackgroundColor3 = Color3.fromRGB(42, 42, 42) }) end)
	b.MouseButton1Click:Connect(function()
		if cfg.Callback then task.spawn(cfg.Callback) end
	end)

	return Common(btnObj, b, cfg, titleLabel, descLabel)
end

---------------------------------------------------------------------- Slider
-- cfg: Title/Name, Desc, Step/Increment, Value = {Min=,Max=,Default=} (หรือ Min/Max/Default),
--      Suffix, Decimals, Callback(number), Flag, Locked
-- คลิกที่ตัวเลขด้านขวาเพื่อพิมพ์ค่าเองได้
function Section:AddSlider(cfg)
	local win = self.Window
	local v = cfg.Value
	local min = (type(v) == "table" and v.Min) or cfg.Min or 0
	local max = (type(v) == "table" and v.Max) or cfg.Max or 100
	local default = (type(v) == "table" and v.Default) or (type(v) == "number" and v) or cfg.Default or min
	local inc = Pick(cfg, "Step", "Increment") or 1
	local dec = cfg.Decimals or Decimals(inc)
	local suffix = cfg.Suffix or ""
	local hasDesc = cfg.Desc ~= nil and cfg.Desc ~= ""
	local dy = hasDesc and 14 or 0
	local slider = { Value = min }

	local holder = New("Frame", {
		Size = UDim2.new(1, 0, 0, 34 + dy), BackgroundTransparency = 1, LayoutOrder = self:_next(),
	}, self.Body)

	local titleLabel = New("TextLabel", {
		Size = UDim2.new(0.6, 0, 0, 16), BackgroundTransparency = 1,
		Text = Pick(cfg, "Title", "Name") or "Slider",
		TextColor3 = Color3.fromRGB(225, 225, 225), TextXAlignment = Enum.TextXAlignment.Left,
		Font = FONT, TextSize = 12,
	}, holder)
	local descLabel = New("TextLabel", {
		Position = UDim2.fromOffset(0, 16), Size = UDim2.new(1, 0, 0, 12), BackgroundTransparency = 1,
		Text = cfg.Desc or "", Visible = hasDesc, TextColor3 = Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left, Font = FONT, TextSize = 10,
	}, holder)

	local valueBox = New("TextBox", {
		Size = UDim2.fromOffset(80, 16), AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0),
		BackgroundTransparency = 1, Text = "", TextColor3 = Color3.fromRGB(200, 200, 200),
		TextXAlignment = Enum.TextXAlignment.Right, ClearTextOnFocus = false, Font = FONT, TextSize = 11,
	}, holder)

	local track = New("Frame", {
		Position = UDim2.fromOffset(0, 26 + dy), Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40), BorderSizePixel = 0,
	}, holder)
	local fill = New("Frame", {
		Size = UDim2.fromScale(0, 1), BackgroundColor3 = Theme.Text, BorderSizePixel = 0,
	}, track)
	local knob = New("Frame", {
		Size = UDim2.fromOffset(8, 8), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(1, 0.5),
		BackgroundColor3 = Theme.Text, BackgroundTransparency = 1, BorderSizePixel = 0,
	}, fill)
	Corner(knob, 4)

	local hit = New("TextButton", {
		Position = UDim2.fromOffset(0, 16 + dy), Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
	}, holder)

	function slider:Set(val, silent)
		val = math.clamp(math.floor((val - min) / inc + 0.5) * inc + min, min, max)
		val = tonumber(string.format("%." .. dec .. "f", val))
		slider.Value = val
		SetFlag(cfg, val)
		fill.Size = UDim2.fromScale((val - min) / (max - min), 1)
		valueBox.Text = string.format("%." .. dec .. "f", val) .. suffix
		if not silent and cfg.Callback then task.spawn(cfg.Callback, val) end
	end

	win:_bindDrag(hit, function(pos)
		local rel = math.clamp((pos.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		slider:Set(min + (max - min) * rel)
		Tween(knob, 0.1, { BackgroundTransparency = 0 })
	end, function()
		Tween(knob, 0.15, { BackgroundTransparency = 1 })
	end)

	valueBox.FocusLost:Connect(function()
		local n = tonumber(valueBox.Text:match("-?%d+%.?%d*"))
		slider:Set(n or slider.Value)
	end)

	slider:Set(default, true)
	return Common(slider, holder, cfg, titleLabel, descLabel)
end

--------------------------------------------------------------------- Dropdown
-- cfg: Title/Name, Desc, Values/Options, Value/Default, Multi, Searchable, AllowNone,
--      Callback(value), Flag, Locked
--   Multi = false -> Value เป็น string (หรือ nil ถ้า AllowNone และยังไม่เลือก)
--   Multi = true  -> Value เป็น array ของตัวเลือกที่เลือก (เรียงตามลำดับ Values)
function Section:AddDropdown(cfg)
	local win = self.Window
	local dd = { Options = Pick(cfg, "Values", "Options") or {}, Multi = cfg.Multi or false }
	local sel = {} -- map: ชื่อตัวเลือก -> true
	local hasDesc = cfg.Desc ~= nil and cfg.Desc ~= ""
	local dy = hasDesc and 13 or 0

	local function list()
		local t = {}
		for _, o in ipairs(dd.Options) do
			if sel[o] then table.insert(t, o) end
		end
		return t
	end
	local function value()
		if dd.Multi then return list() end
		return list()[1]
	end

	local default = Pick(cfg, "Value", "Default")
	if dd.Multi then
		if type(default) == "table" then
			for _, o in ipairs(default) do sel[o] = true end
		elseif default ~= nil then
			sel[default] = true
		end
	else
		if type(default) == "table" then default = default[1] end
		if default == nil and not cfg.AllowNone then default = dd.Options[1] end
		if default ~= nil then sel[default] = true end
	end

	local holder = New("Frame", {
		Size = UDim2.new(1, 0, 0, 43 + dy), BackgroundTransparency = 1, LayoutOrder = self:_next(),
	}, self.Body)
	local titleLabel = New("TextLabel", {
		Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1,
		Text = Pick(cfg, "Title", "Name") or "Dropdown",
		TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, Font = FONT, TextSize = 11,
	}, holder)
	local descLabel = New("TextLabel", {
		Position = UDim2.fromOffset(0, 13), Size = UDim2.new(1, 0, 0, 12), BackgroundTransparency = 1,
		Text = cfg.Desc or "", Visible = hasDesc, TextColor3 = Theme.Dim,
		TextXAlignment = Enum.TextXAlignment.Left, Font = FONT, TextSize = 10,
	}, holder)

	local box = New("TextButton", {
		Position = UDim2.fromOffset(0, 19 + dy), Size = UDim2.new(1, 0, 0, 24),
		BackgroundColor3 = Theme.Control, BorderSizePixel = 0, Text = "", AutoButtonColor = false,
	}, holder)
	Corner(box, 4)
	Stroke(box, Color3.fromRGB(40, 40, 40))

	local valueLabel = New("TextLabel", {
		Position = UDim2.fromOffset(9, 0), Size = UDim2.new(1, -30, 1, 0), BackgroundTransparency = 1,
		Text = "", TextColor3 = Color3.fromRGB(150, 150, 150), TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Font = FONT, TextSize = 11,
	}, box)
	local arrowHost = New("Frame", {
		Size = UDim2.fromOffset(22, 24), AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0),
		BackgroundTransparency = 1,
	}, box)
	local arrow = MakeIcon("chevron", arrowHost, 12, Theme.SubText).Holder

	local function display()
		local t = list()
		valueLabel.TextColor3 = #t > 0 and Color3.fromRGB(205, 205, 205) or Theme.Dim
		if #t == 0 then return "None" end
		return dd.Multi and table.concat(t, ", ") or tostring(t[1])
	end

	function dd:Set(v, silent)
		sel = {}
		if type(v) == "table" then
			for _, o in ipairs(v) do sel[o] = true end
		elseif v ~= nil then
			sel[v] = true
		end
		if not dd.Multi then -- โหมดเลือกเดียว: เก็บแค่ค่าแรก
			local first = list()[1]
			sel = {}
			if first ~= nil then sel[first] = true end
		end
		dd.Value = value()
		valueLabel.Text = display()
		SetFlag(cfg, dd.Value)
		if not silent and cfg.Callback then task.spawn(cfg.Callback, dd.Value) end
	end

	-- เปลี่ยนรายการตัวเลือกใหม่ (เก็บค่าที่ยังอยู่ในรายการ)
	function dd:Refresh(newOptions)
		dd.Options = newOptions or {}
		local keep = {}
		for _, o in ipairs(dd.Options) do
			if sel[o] then table.insert(keep, o) end
		end
		win:ClosePopup()
		dd:Set(keep, true)
	end

	local function open()
		win:ClosePopup()
		local ap, sz = box.AbsolutePosition, box.AbsoluteSize
		local vp = win.Gui.AbsoluteSize
		local searchH = cfg.Searchable and 30 or 0
		local totalH = math.min(#dd.Options * 22 + 8, 150) + searchH
		local y = ap.Y + sz.Y + 4
		if y + totalH > vp.Y - 4 then y = math.max(4, ap.Y - totalH - 4) end

		local frame = New("Frame", {
			Position = UDim2.fromOffset(ap.X, y), Size = UDim2.fromOffset(sz.X, totalH),
			BackgroundColor3 = Theme.PopupBg, BorderSizePixel = 0, ZIndex = 100,
		}, win.Gui)
		Corner(frame, 4)
		Stroke(frame, Theme.Stroke)

		local searchBox
		if cfg.Searchable then
			local sh = New("Frame", {
				Position = UDim2.fromOffset(6, 5), Size = UDim2.new(1, -12, 0, 20),
				BackgroundColor3 = Theme.Control, BorderSizePixel = 0,
			}, frame)
			Corner(sh, 3)
			local ih = New("Frame", {
				Position = UDim2.fromOffset(5, 3), Size = UDim2.fromOffset(14, 14), BackgroundTransparency = 1,
			}, sh)
			MakeIcon("search", ih, 11, Theme.SubText)
			searchBox = New("TextBox", {
				Position = UDim2.fromOffset(24, 0), Size = UDim2.new(1, -28, 1, 0), BackgroundTransparency = 1,
				Text = "", PlaceholderText = "Search...", PlaceholderColor3 = Theme.Dim, TextColor3 = Theme.Text,
				TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Font = FONT, TextSize = 11,
			}, sh)
		end

		local scroll = New("ScrollingFrame", {
			Position = UDim2.fromOffset(0, searchH), Size = UDim2.new(1, 0, 1, -searchH),
			BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2,
			ScrollBarImageColor3 = Theme.Dim, CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
		}, frame)
		New("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4) }, scroll)
		New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, scroll)

		local entries = {}
		local function paint()
			for name, e in pairs(entries) do
				local on = sel[name] == true
				e.txt.TextColor3 = on and Theme.Text or Theme.SubText
				if e.mini then
					e.mini.BackgroundColor3 = on and Theme.Check or Theme.Control
				end
				e.mark.Visible = on
			end
		end

		for i, opt in ipairs(dd.Options) do
			local b = New("TextButton", {
				Size = UDim2.new(1, 0, 0, 22), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1,
				Text = "", AutoButtonColor = false, LayoutOrder = i,
			}, scroll)
			local txt = New("TextLabel", {
				Position = UDim2.fromOffset(dd.Multi and 29 or 9, 0),
				Size = UDim2.new(1, dd.Multi and -35 or -32, 1, 0), BackgroundTransparency = 1,
				Text = tostring(opt), TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd, Font = FONT, TextSize = 11,
			}, b)
			local mini, mark
			if dd.Multi then
				mini = New("Frame", {
					Size = UDim2.fromOffset(13, 13), AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, 9, 0.5, 0), BackgroundColor3 = Theme.Control, BorderSizePixel = 0,
				}, b)
				Corner(mini, 3)
				Stroke(mini, Color3.fromRGB(55, 55, 55))
				mark = MakeIcon("check", mini, 11, Theme.CheckMark).Holder
			else
				local host = New("Frame", {
					Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -9, 0.5, 0), BackgroundTransparency = 1,
				}, b)
				mark = MakeIcon("check", host, 12, Theme.Text).Holder
			end
			entries[opt] = { btn = b, txt = txt, mini = mini, mark = mark }

			b.MouseEnter:Connect(function() b.BackgroundTransparency = 0.9 end)
			b.MouseLeave:Connect(function() b.BackgroundTransparency = 1 end)
			b.MouseButton1Click:Connect(function()
				if dd.Multi then
					local t = {}
					for _, o in ipairs(dd.Options) do
						local on = sel[o] == true
						if o == opt then on = not on end
						if on then table.insert(t, o) end
					end
					dd:Set(t)
					paint()
				else
					if sel[opt] then
						if cfg.AllowNone then dd:Set(nil) end
					else
						dd:Set(opt)
					end
					win:ClosePopup()
				end
			end)
		end
		paint()

		if searchBox then
			searchBox:GetPropertyChangedSignal("Text"):Connect(function()
				local q = string.lower(searchBox.Text)
				for name, e in pairs(entries) do
					e.btn.Visible = q == "" or string.find(string.lower(tostring(name)), q, 1, true) ~= nil
				end
			end)
		end

		Tween(arrow, 0.12, { Rotation = 180 })
		win.Popup = {
			Frame = frame, Owner = box,
			OnClose = function() Tween(arrow, 0.12, { Rotation = 0 }) end,
		}
	end

	box.MouseButton1Click:Connect(function()
		if win.Popup and win.Popup.Owner == box then win:ClosePopup() else open() end
	end)

	dd:Set(value(), true)
	return Common(dd, holder, cfg, titleLabel, descLabel)
end

----------------------------------------------------------------------- Input
-- cfg: Title/Name, Desc, Value/Default, Placeholder, Type = "Input"|"Textarea",
--      Numeric, Callback(text), Flag, Locked
function Section:AddInput(cfg)
	local multiline = cfg.Type == "Textarea" or cfg.MultiLine == true
	local boxH = multiline and 72 or 24
	local hasDesc = cfg.Desc ~= nil and cfg.Desc ~= ""
	local dy = hasDesc and 13 or 0
	local input = { Value = tostring(Pick(cfg, "Value", "Default") or "") }

	local holder = New("Frame", {
		Size = UDim2.new(1, 0, 0, 19 + dy + boxH), BackgroundTransparency = 1, LayoutOrder = self:_next(),
	}, self.Body)
	local titleLabel = New("TextLabel", {
		Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1,
		Text = Pick(cfg, "Title", "Name") or "Input",
		TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, Font = FONT, TextSize = 11,
	}, holder)
	local descLabel = New("TextLabel", {
		Position = UDim2.fromOffset(0, 13), Size = UDim2.new(1, 0, 0, 12), BackgroundTransparency = 1,
		Text = cfg.Desc or "", Visible = hasDesc, TextColor3 = Theme.Dim,
		TextXAlignment = Enum.TextXAlignment.Left, Font = FONT, TextSize = 10,
	}, holder)

	local tb = New("TextBox", {
		Position = UDim2.fromOffset(0, 19 + dy), Size = UDim2.new(1, 0, 0, boxH),
		BackgroundColor3 = Theme.Control, BorderSizePixel = 0, Text = input.Value,
		PlaceholderText = cfg.Placeholder or "Type here...", PlaceholderColor3 = Theme.Dim,
		TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = multiline and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
		MultiLine = multiline, TextWrapped = multiline, ClearTextOnFocus = false, Font = FONT, TextSize = 11,
	}, holder)
	Corner(tb, 4)
	New("UIPadding", {
		PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 9),
		PaddingTop = UDim.new(0, multiline and 6 or 0), PaddingBottom = UDim.new(0, multiline and 6 or 0),
	}, tb)
	local st = Stroke(tb, Color3.fromRGB(40, 40, 40))

	tb.Focused:Connect(function() st.Color = Color3.fromRGB(95, 95, 95) end)
	tb.FocusLost:Connect(function()
		st.Color = Color3.fromRGB(40, 40, 40)
		if cfg.Numeric then
			local n = tonumber(tb.Text)
			tb.Text = n and tostring(n) or input.Value
		end
		input.Value = tb.Text
		SetFlag(cfg, input.Value)
		if cfg.Callback then task.spawn(cfg.Callback, input.Value) end
	end)

	function input:Set(text, silent)
		tb.Text = tostring(text)
		input.Value = tb.Text
		SetFlag(cfg, input.Value)
		if not silent and cfg.Callback then task.spawn(cfg.Callback, input.Value) end
	end
	SetFlag(cfg, input.Value)
	return Common(input, holder, cfg, titleLabel, descLabel)
end
Section.AddTextbox = Section.AddInput -- ชื่อเดิม

--------------------------------------------------------------------- Keybind
-- cfg: Title/Name, Desc, Value/Default = "G" (ชื่อ KeyCode), Mode = "Toggle"|"Hold"|"Always",
--      Callback(state)  -> ถูกเรียกเมื่อกดปุ่มที่ผูกไว้
--      OnChange(keyName) -> ถูกเรียกเมื่อผู้ใช้เปลี่ยนปุ่ม
--   คลิกปุ่มเพื่อเริ่มจับปุ่มใหม่ | Esc = ยกเลิก | Backspace = ล้างปุ่ม
function Section:AddKeybind(cfg)
	local win = self.Window
	local kb = { Mode = cfg.Mode or "Toggle", State = false, Listening = false }
	local keyName = Pick(cfg, "Value", "Default") or "None"
	if typeof(keyName) == "EnumItem" then keyName = keyName.Name end
	kb.Value = keyName

	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, 22), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, LayoutOrder = self:_next(),
	}, self.Body)
	local text = New("Frame", {
		Size = UDim2.new(1, -78, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
	}, row)
	New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, text)
	local titleLabel, descLabel = TitleBlock(text, Pick(cfg, "Title", "Name") or "Keybind", cfg.Desc)

	local keyBtn = New("TextButton", {
		Size = UDim2.fromOffset(70, 22), AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0),
		BackgroundColor3 = Theme.Control, BorderSizePixel = 0, Text = keyName,
		TextColor3 = Color3.fromRGB(205, 205, 205), TextTruncate = Enum.TextTruncate.AtEnd,
		Font = FONT, TextSize = 11, AutoButtonColor = false,
	}, row)
	Corner(keyBtn, 4)
	local st = Stroke(keyBtn, Color3.fromRGB(45, 45, 45))

	local function fire(state)
		kb.State = state
		if cfg.Callback then task.spawn(cfg.Callback, state) end
	end

	function kb:SetKey(name, silent)
		keyName = name or "None"
		kb.Value = keyName
		keyBtn.Text = keyName
		SetFlag(cfg, keyName)
		if not silent and cfg.OnChange then task.spawn(cfg.OnChange, keyName) end
	end
	function kb:SetMode(m) kb.Mode = m end

	local function stopListening()
		kb.Listening = false
		win._binding = false
		st.Color = Color3.fromRGB(45, 45, 45)
		keyBtn.Text = keyName
	end

	keyBtn.MouseButton1Click:Connect(function()
		if kb.Locked then return end
		kb.Listening = true
		win._binding = true
		keyBtn.Text = "..."
		st.Color = Color3.fromRGB(110, 110, 110)
	end)

	win:_on(UserInputService.InputBegan, function(input, processed)
		if kb.Listening then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == Enum.KeyCode.Escape then
					stopListening()
				elseif input.KeyCode == Enum.KeyCode.Backspace then
					stopListening()
					kb:SetKey("None")
				else
					stopListening()
					kb:SetKey(input.KeyCode.Name)
				end
			end
			return
		end
		if processed or kb.Locked or keyName == "None" or kb.Mode == "Always" then return end
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == keyName then
			if kb.Mode == "Hold" then fire(true) else fire(not kb.State) end
		end
	end)
	win:_on(UserInputService.InputEnded, function(input)
		if kb.Mode == "Hold" and kb.State and input.UserInputType == Enum.UserInputType.Keyboard
			and input.KeyCode.Name == keyName then
			fire(false)
		end
	end)

	SetFlag(cfg, keyName)
	if kb.Mode == "Always" then kb.State = true end
	return Common(kb, row, cfg, titleLabel, descLabel)
end

------------------------------------------------------------------- Paragraph
-- cfg: Title, Desc, Icon, Buttons = { { Title=, Icon=, Callback= }, ... }
function Section:AddParagraph(cfg)
	cfg = type(cfg) == "string" and { Desc = cfg } or cfg
	local para = {}
	local holder = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Control, BorderSizePixel = 0, LayoutOrder = self:_next(),
	}, self.Body)
	Corner(holder, 4)
	Stroke(holder, Color3.fromRGB(40, 40, 40))
	New("UIPadding", {
		PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
		PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
	}, holder)
	New("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, holder)

	local titleLabel
	local title = Pick(cfg, "Title", "Name")
	if title then
		local head = New("Frame", { Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, LayoutOrder = 1 }, holder)
		local off = 0
		if cfg.Icon then
			local host = New("Frame", {
				Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 0, 0.5, 0), BackgroundTransparency = 1,
			}, head)
			MakeIcon(cfg.Icon, host, 14, Theme.Text)
			off = 22
		end
		titleLabel = New("TextLabel", {
			Position = UDim2.fromOffset(off, 0), Size = UDim2.new(1, -off, 1, 0), BackgroundTransparency = 1,
			Text = title, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
			Font = FONT_BOLD, TextSize = 12,
		}, head)
	end

	local descLabel = New("TextLabel", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
		Text = cfg.Desc or "", Visible = cfg.Desc ~= nil and cfg.Desc ~= "", TextWrapped = true,
		TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top, Font = FONT, TextSize = 11, LayoutOrder = 2,
	}, holder)

	if cfg.Buttons and #cfg.Buttons > 0 then
		local rowB = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1, LayoutOrder = 3,
		}, holder)
		New("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal, Wraps = true,
			Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
		}, rowB)
		New("UIPadding", { PaddingTop = UDim.new(0, 4) }, rowB)
		for i, bc in ipairs(cfg.Buttons) do
			local b = New("TextButton", {
				Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X,
				BackgroundColor3 = Theme.Panel, BorderSizePixel = 0, Text = "", AutoButtonColor = false,
				LayoutOrder = i,
			}, rowB)
			Corner(b, 4)
			Stroke(b, Color3.fromRGB(50, 50, 50))
			New("UIPadding", { PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 9) }, b)
			New("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 5),
				VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
			}, b)
			if bc.Icon then
				local host = New("Frame", { Size = UDim2.fromOffset(12, 12), BackgroundTransparency = 1, LayoutOrder = 1 }, b)
				MakeIcon(bc.Icon, host, 12, Theme.SubText)
			end
			New("TextLabel", {
				Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1,
				Text = bc.Title or "Button", TextColor3 = Theme.Text, Font = FONT, TextSize = 11, LayoutOrder = 2,
			}, b)
			b.MouseEnter:Connect(function() Tween(b, 0.1, { BackgroundColor3 = Color3.fromRGB(40, 40, 40) }) end)
			b.MouseLeave:Connect(function() Tween(b, 0.1, { BackgroundColor3 = Theme.Panel }) end)
			b.MouseButton1Click:Connect(function()
				if bc.Callback then task.spawn(bc.Callback) end
			end)
		end
	end

	return Common(para, holder, cfg, titleLabel, descLabel)
end

--------------------------------------------------------------------------- Code
-- cfg: Title, Code  (ปุ่มคัดลอกใช้ได้เมื่อสภาพแวดล้อมรองรับ setclipboard)
function Section:AddCode(cfg)
	local win = self.Window
	local codeObj = {}
	local holder = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(16, 16, 16), BorderSizePixel = 0, LayoutOrder = self:_next(),
	}, self.Body)
	Corner(holder, 4)
	Stroke(holder, Color3.fromRGB(38, 38, 38))
	New("UIPadding", {
		PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
		PaddingTop = UDim.new(0, 7), PaddingBottom = UDim.new(0, 9),
	}, holder)
	New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, holder)

	local head = New("Frame", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, LayoutOrder = 1 }, holder)
	local titleLabel = New("TextLabel", {
		Size = UDim2.new(1, -26, 1, 0), BackgroundTransparency = 1, Text = Pick(cfg, "Title", "Name") or "Code",
		TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, Font = FONT, TextSize = 11,
	}, head)
	local copyBtn = New("TextButton", {
		Size = UDim2.fromOffset(20, 18), AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0),
		BackgroundTransparency = 1, Text = "",
	}, head)
	local copyIcon = MakeIcon("copy", copyBtn, 13, Theme.SubText)
	copyBtn.MouseEnter:Connect(function() copyIcon:SetColor(Theme.Text) end)
	copyBtn.MouseLeave:Connect(function() copyIcon:SetColor(Theme.SubText) end)

	local codeLabel = New("TextLabel", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
		Text = cfg.Code or "", TextColor3 = Color3.fromRGB(190, 200, 215), TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
		Font = Enum.Font.Code, TextSize = 11, LayoutOrder = 2,
	}, holder)

	copyBtn.MouseButton1Click:Connect(function()
		local ok, fn = pcall(function() return setclipboard end)
		if ok and type(fn) == "function" then
			fn(codeLabel.Text)
			win:Notify({ Title = "Copied", Content = "Code copied to clipboard.", Icon = "check", Duration = 2.5 })
		else
			win:Notify({ Title = "Copy unavailable", Content = "Clipboard is not supported here.", Icon = "info", Duration = 3 })
		end
	end)

	function codeObj:SetCode(c) codeLabel.Text = c end
	return Common(codeObj, holder, cfg, titleLabel, nil)
end

-------------------------------------------------------------------------- Image
-- cfg: Image = "rbxassetid://...", Height (default 100), Fit = true (ไม่ครอป)
function Section:AddImage(cfg)
	local imgObj = {}
	local holder = New("Frame", {
		Size = UDim2.new(1, 0, 0, cfg.Height or 100), BackgroundColor3 = Theme.Control,
		BorderSizePixel = 0, LayoutOrder = self:_next(),
	}, self.Body)
	Corner(holder, 4)
	local img = New("ImageLabel", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = cfg.Image or "",
		ScaleType = cfg.Fit and Enum.ScaleType.Fit or Enum.ScaleType.Crop,
	}, holder)
	Corner(img, 4)
	function imgObj:SetImage(i) img.Image = i end
	return Common(imgObj, holder, cfg, nil, nil)
end

------------------------------------------------------------------------- Label
-- text หรือ { Title = , Icon = }
function Section:AddLabel(cfg)
	cfg = type(cfg) == "string" and { Title = cfg } or (cfg or {})
	local lbl = {}
	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, LayoutOrder = self:_next(),
	}, self.Body)
	local off = 0
	if cfg.Icon then
		local host = New("Frame", {
			Size = UDim2.fromOffset(12, 12), AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0), BackgroundTransparency = 1,
		}, row)
		MakeIcon(cfg.Icon, host, 12, Theme.SubText)
		off = 18
	end
	local l = New("TextLabel", {
		Position = UDim2.fromOffset(off, 0), Size = UDim2.new(1, -off, 1, 0), BackgroundTransparency = 1,
		Text = Pick(cfg, "Title", "Name") or "Label", TextColor3 = Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left, Font = FONT, TextSize = 11,
	}, row)
	function lbl:Set(t) l.Text = t end
	return Common(lbl, row, cfg, l, nil)
end

------------------------------------------------- Color picker (แถวแยกต่างหาก)
-- cfg: Title/Name, Default (Color3), Alpha (0-1) หรือ Transparency (0-1 แบบ WindUI),
--      Callback(color, alpha), Flag
function Section:AddColorPicker(cfg)
	cfg = cfg or {}
	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, LayoutOrder = self:_next(),
	}, self.Body)
	local titleLabel = New("TextLabel", {
		Size = UDim2.new(1, -40, 1, 0), BackgroundTransparency = 1, Text = Pick(cfg, "Title", "Name") or "Color",
		TextColor3 = Color3.fromRGB(225, 225, 225), TextXAlignment = Enum.TextXAlignment.Left,
		Font = FONT, TextSize = 12,
	}, row)
	local sw = self.Window:_newSwatch(row, cfg)
	return Common(sw, row, cfg, titleLabel, nil)
end

----------------------------------------------------------- Divider / Space
function Section:AddDivider()
	local d = {}
	local f = New("Frame", {
		Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		BorderSizePixel = 0, LayoutOrder = self:_next(),
	}, self.Body)
	return Common(d, f, {}, nil, nil)
end

function Section:AddSpace(size)
	local d = {}
	local f = New("Frame", {
		Size = UDim2.new(1, 0, 0, size or 6), BackgroundTransparency = 1, LayoutOrder = self:_next(),
	}, self.Body)
	return Common(d, f, {}, nil, nil)
end

-- ชื่อเมธอดแบบ WindUI (section:Toggle / :Button / ...)
Section.Toggle      = Section.AddToggle
Section.Button      = Section.AddButton
Section.Slider      = Section.AddSlider
Section.Input       = Section.AddInput
Section.Dropdown    = Section.AddDropdown
Section.Keybind     = Section.AddKeybind
Section.Colorpicker = Section.AddColorPicker
Section.Paragraph   = Section.AddParagraph
Section.Code        = Section.AddCode
Section.Image       = Section.AddImage
Section.Label       = Section.AddLabel
Section.Divider     = Section.AddDivider
Section.Space       = Section.AddSpace
Tab.Section         = Tab.AddSection
Window.Tab          = Window.AddTab

--=============================================================================
--  NOTIFY (toast)  /  DIALOG
--=============================================================================
function Window:SetToggleKey(keyCode)
	self.ToggleKey = keyCode
end

-- cfg: Title, Content, Icon ("info" / "check" / ...), Duration (วินาที)
function Window:Notify(cfg)
	cfg = cfg or {}
	local c = self._toasts
	if not c then
		c = New("Frame", {
			Name = "Toasts", AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -16, 1, -16),
			Size = UDim2.new(0, 250, 1, -32), BackgroundTransparency = 1,
		}, self.Gui)
		New("UIListLayout", {
			Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Right,
		}, c)
		self._toasts = c
	end
	self._toastN = (self._toastN or 0) + 1
	local dur = cfg.Duration or 4

	local toast = New("CanvasGroup", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.PopupBg, BorderSizePixel = 0, GroupTransparency = 1,
		LayoutOrder = self._toastN,
	}, c)
	Corner(toast, 6)
	Stroke(toast, Theme.Stroke)

	local inner = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
	}, toast)
	New("UIPadding", {
		PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
		PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 14),
	}, inner)
	local iconHost = New("Frame", { Size = UDim2.fromOffset(16, 16), BackgroundTransparency = 1 }, inner)
	MakeIcon(cfg.Icon or "info", iconHost, 14, Theme.Text)

	local tf = New("Frame", {
		Position = UDim2.fromOffset(26, 0), Size = UDim2.new(1, -26, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
	}, inner)
	New("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, tf)
	New("TextLabel", {
		Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = cfg.Title or "Notification",
		TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Font = FONT_BOLD, TextSize = 12,
		LayoutOrder = 1,
	}, tf)
	if cfg.Content and cfg.Content ~= "" then
		New("TextLabel", {
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
			Text = cfg.Content, TextColor3 = Theme.SubText, TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
			Font = FONT, TextSize = 11, LayoutOrder = 2,
		}, tf)
	end

	local barBg = New("Frame", {
		AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = Color3.fromRGB(36, 36, 36), BorderSizePixel = 0,
	}, toast)
	local bar = New("Frame", {
		Size = UDim2.fromScale(1, 1), BackgroundColor3 = Theme.Text, BorderSizePixel = 0,
	}, barBg)

	Tween(toast, 0.2, { GroupTransparency = 0 })
	TweenService:Create(bar, TweenInfo.new(dur, Enum.EasingStyle.Linear), { Size = UDim2.fromScale(0, 1) }):Play()

	local closed = false
	local handle = {}
	function handle:Close()
		if closed then return end
		closed = true
		Tween(toast, 0.25, { GroupTransparency = 1 })
		task.delay(0.3, function() toast:Destroy() end)
	end
	task.delay(dur, function() handle:Close() end)
	return handle
end

-- cfg: Title, Content, Icon, Buttons = { { Title=, Callback=, Style = "Primary"|"Default" }, ... }
function Window:Dialog(cfg)
	cfg = cfg or {}
	self:ClosePopup()
	local overlay = New("TextButton", {
		Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1,
		BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = 200,
	}, self.Gui)
	Tween(overlay, 0.15, { BackgroundTransparency = 0.45 })

	local box = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(300, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.PopupBg, BorderSizePixel = 0,
	}, overlay)
	Corner(box, 6)
	Stroke(box, Theme.Stroke)
	New("UIPadding", {
		PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16),
		PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14),
	}, box)
	New("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, box)

	local head = New("Frame", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, LayoutOrder = 1 }, box)
	local off = 0
	if cfg.Icon then
		local host = New("Frame", {
			Size = UDim2.fromOffset(16, 16), AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0), BackgroundTransparency = 1,
		}, head)
		MakeIcon(cfg.Icon, host, 14, Theme.Text)
		off = 24
	end
	New("TextLabel", {
		Position = UDim2.fromOffset(off, 0), Size = UDim2.new(1, -off, 1, 0), BackgroundTransparency = 1,
		Text = cfg.Title or "Dialog", TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
		Font = FONT_BOLD, TextSize = 14,
	}, head)
	if cfg.Content and cfg.Content ~= "" then
		New("TextLabel", {
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
			Text = cfg.Content, TextColor3 = Theme.SubText, TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
			Font = FONT, TextSize = 12, LayoutOrder = 2,
		}, box)
	end

	local btnRow = New("Frame", {
		Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, LayoutOrder = 3,
	}, box)
	New("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6),
		HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Bottom,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, btnRow)

	local function close()
		Tween(overlay, 0.12, { BackgroundTransparency = 1 })
		overlay:Destroy()
	end
	local buttons = cfg.Buttons
	if not buttons or #buttons == 0 then buttons = { { Title = "OK", Style = "Primary" } } end
	for i, bc in ipairs(buttons) do
		local primary = bc.Style == "Primary"
		local b = New("TextButton", {
			Size = UDim2.fromOffset(0, 26), AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = primary and Theme.Check or Theme.Control, BorderSizePixel = 0,
			Text = bc.Title or "Button", TextColor3 = primary and Theme.CheckMark or Theme.Text,
			Font = FONT, TextSize = 12, AutoButtonColor = true, LayoutOrder = i,
		}, btnRow)
		Corner(b, 4)
		New("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) }, b)
		b.MouseButton1Click:Connect(function()
			close()
			if bc.Callback then task.spawn(bc.Callback) end
		end)
	end
	return { Close = close }
end

--=============================================================================
--  DEMO  (ลบส่วนนี้ทิ้งได้ถ้าจะใช้ไลบรารีเอง)
--=============================================================================
local Win = Library:CreateWindow({
	Title = "@homixida",
	Size = UDim2.fromOffset(700, 440),
	ToggleKey = Enum.KeyCode.RightShift, -- ซ่อน/แสดง UI (เปลี่ยนได้จาก Keybind ในแท็บ Elements)
})

Win:AddCategory("Main")
-- Icon: "person" | "group" | "eye" | "globe" | "target" | "grid" | "keyboard" หรือ "rbxassetid://..."
local avatarTab  = Win:AddTab({ Name = "Avatar", Icon = "person" })
Win:AddCategory("Globals")
local viewTab    = Win:AddTab({ Name = "View", Icon = "eye" })
local playersTab = Win:AddTab({ Name = "Players", Icon = "group" })
local worldTab   = Win:AddTab({ Name = "World", Icon = "globe" })
Win:AddCategory("Miscellaneous")
local elementsTab = Win:AddTab({ Name = "Elements", Icon = "grid" })

----------------------------------------------------------------- Tab: Avatar
local main = avatarTab:AddSection({ Name = "Main", Side = "Left", MinHeight = 410 })
for i = 1, 8 do
	main:AddToggle({ Title = "Label", Value = true, Flag = "avatar_toggle_" .. i })
end

local misc = avatarTab:AddSection({ Name = "Misc", Side = "Right" })
misc:AddSlider({ Title = "Label", Value = { Min = 0, Max = 360, Default = 360 }, Suffix = "°", Flag = "angle" })
misc:AddSlider({ Title = "Label", Value = { Min = 0, Max = 1, Default = 1 }, Step = 0.001, Flag = "smooth" })
misc:AddSlider({ Title = "Label", Value = { Min = 0, Max = 1000, Default = 222 }, Suffix = "px", Flag = "size" })

local misc2 = avatarTab:AddSection({ Name = "Misc 2", Side = "Right" })
misc2:AddDropdown({ Title = "Label", Values = { "Option 1", "Option 2", "Option 3" }, AllowNone = true })
misc2:AddDropdown({ Title = "Label", Values = { "Option 1", "Option 2", "Option 3" }, AllowNone = true })

------------------------------------------------------------------- Tab: View
local inputs = viewTab:AddSection({ Title = "Inputs", Side = "Left" })
inputs:AddInput({
	Title = "Text input", Placeholder = "Type something...",
	Callback = function(text) print("Input:", text) end,
})
inputs:AddInput({ Title = "Number input", Numeric = true, Value = "100", Callback = function(t) print("Number:", t) end })
inputs:AddInput({ Title = "Textarea", Type = "Textarea", Placeholder = "Write multiple lines..." })

local viewR = viewTab:AddSection({ Title = "Multi dropdown", Side = "Right" })
viewR:AddDropdown({
	Title = "Pick many", Multi = true, Values = { "One", "Two", "Three", "Four" }, Value = { "Two" },
	Callback = function(v) print("selected:", table.concat(v, ", ")) end,
})

----------------------------------------------------------------- Tab: Players
local pl = playersTab:AddSection({ Name = "Label", Side = "Left" })
pl:AddToggle({ Title = "Label", Value = true })
local colorToggle = pl:AddToggle({ Title = "Label", Value = true })
colorToggle:AddColorPicker({
	Default = Color3.fromRGB(123, 111, 255), Alpha = 123 / 255, Flag = "player_color",
	Callback = function(color, alpha) print("Color selected:", color, alpha) end,
})
pl:AddToggle({ Title = "Label", Value = true })
pl:AddToggle({ Title = "Label", Value = true })

local plR = playersTab:AddSection({ Name = "Label", Side = "Right" })
for _ = 1, 3 do
	plR:AddDropdown({ Title = "Label", Values = { "Option 1", "Option 2" }, AllowNone = true })
end

------------------------------------------------------------------- Tab: World
local world = worldTab:AddSection({ Name = "World", Side = "Left" })
world:AddToggle({ Title = "Label", Value = false })
world:AddColorPicker({ Title = "Sky colour", Default = Color3.fromRGB(180, 30, 20) })
world:AddSlider({ Title = "Label", Value = { Min = 0, Max = 100, Default = 50 }, Suffix = "%" })

---------------------------------------------------------------- Tab: Elements
-- ตัวอย่างองค์ประกอบทั้งหมด (สไตล์ WindUI)
local btns = elementsTab:AddSection({ Name = "Buttons", Side = "Left", Collapsible = true })
btns:AddButton({
	Title = "Notify", Desc = "Show a toast notification", Icon = "info",
	Callback = function()
		Win:Notify({ Title = "Hello", Content = "This is a toast notification.", Icon = "info", Duration = 4 })
	end,
})
btns:AddButton({
	Title = "Open dialog", Justify = "Center",
	Callback = function()
		Win:Dialog({
			Title = "Confirm", Icon = "info", Content = "Do you want to continue?",
			Buttons = {
				{ Title = "Cancel" },
				{ Title = "Confirm", Style = "Primary", Callback = function()
					Win:Notify({ Title = "Confirmed", Icon = "check", Duration = 2.5 })
				end },
			},
		})
	end,
})
btns:AddButton({ Title = "Locked button", Desc = "Can't be clicked", Icon = "lock", Locked = true })

local tgl = elementsTab:AddSection({ Name = "Toggles", Side = "Left", Collapsible = true })
tgl:AddToggle({ Title = "Checkbox", Desc = "Checkbox style toggle", Value = true })
tgl:AddToggle({ Title = "Switch", Desc = "Switch style toggle", Type = "Switch", Value = true })
local sw = tgl:AddToggle({ Title = "Switch + colour", Type = "Switch" })
sw:AddColorPicker({ Default = Color3.fromRGB(80, 200, 120) })
tgl:AddToggle({ Title = "Locked toggle", Type = "Switch", Locked = true })

local misc3 = elementsTab:AddSection({ Name = "Keybinds", Side = "Left", Collapsible = true })
misc3:AddKeybind({
	Title = "Toggle UI key", Desc = "Click, then press a key (Esc cancel, Backspace clear)",
	Value = "RightShift",
	OnChange = function(key)
		if Enum.KeyCode[key] then Win:SetToggleKey(Enum.KeyCode[key]) end
	end,
})
misc3:AddKeybind({
	Title = "Toggle mode", Value = "G", Mode = "Toggle",
	Callback = function(state) print("Keybind toggle:", state) end,
})
misc3:AddKeybind({
	Title = "Hold mode", Value = "H", Mode = "Hold",
	Callback = function(state) print("Keybind hold:", state) end,
})

local dds = elementsTab:AddSection({ Name = "Dropdowns", Side = "Right", Collapsible = true })
dds:AddDropdown({
	Title = "Single", Desc = "AllowNone: click again to clear",
	Values = { "Apple", "Banana", "Cherry" }, Value = "Apple", AllowNone = true,
	Callback = function(v) print("Single:", v) end,
})
dds:AddDropdown({
	Title = "Multi select", Values = { "Red", "Green", "Blue", "Yellow" }, Multi = true, Value = { "Red", "Blue" },
	Callback = function(v) print("Multi:", table.concat(v, ", ")) end,
})
dds:AddDropdown({
	Title = "Multi + search", Multi = true, Searchable = true,
	Values = { "Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot", "Golf", "Hotel", "India", "Juliet" },
})

local vals = elementsTab:AddSection({ Name = "Values", Side = "Right", Collapsible = true })
vals:AddSlider({
	Title = "Speed", Desc = "Click the number to type a value",
	Value = { Min = 16, Max = 120, Default = 70 }, Step = 1,
	Callback = function(v) print("Speed:", v) end,
})
vals:AddInput({ Title = "Name", Placeholder = "Enter text..." })

local info = elementsTab:AddSection({ Name = "Info", Side = "Right", Collapsible = true })
info:AddParagraph({
	Title = "Paragraph", Icon = "info",
	Desc = "A card with a title, description and optional buttons.",
	Buttons = {
		{ Title = "Notify", Icon = "info", Callback = function() Win:Notify({ Title = "Paragraph button" }) end },
		{ Title = "Dialog", Callback = function() Win:Dialog({ Title = "Hi", Content = "From a paragraph button." }) end },
	},
})
info:AddDivider()
info:AddCode({ Title = "Example", Code = 'print("Hello from Homixida UI")\nlocal x = 10' })
info:AddLabel({ Title = "RightShift = hide / show", Icon = "keyboard" })

Win:Notify({ Title = "Homixida UI", Content = "Loaded. Press RightShift to hide / show.", Icon = "check", Duration = 4 })

return Library
