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

	local function headerButton(text, xOffset, onClick)
		local b = New("TextButton", {
			Size = UDim2.fromOffset(20, 14),
			Position = UDim2.new(1, xOffset, 0, 1),
			BackgroundTransparency = 1,
			Text = text,
			TextColor3 = Theme.Dim,
			Font = FONT_BOLD,
			TextSize = 14,
			ZIndex = 3,
		}, root)
		b.MouseEnter:Connect(function() Tween(b, 0.1, { TextColor3 = Theme.Text }) end)
		b.MouseLeave:Connect(function() Tween(b, 0.1, { TextColor3 = Theme.Dim }) end)
		b.MouseButton1Click:Connect(onClick)
		return b
	end
	headerButton("×", -26, function() self:Destroy() end)             -- ปิด (ลบ UI)
	headerButton("–", -48, function() self:SetVisible(false) end)     -- ย่อ (ซ่อน; กดปุ่ม ToggleKey เพื่อเปิดกลับ)

	---------------------------------------------------------- Global inputs
	-- คลิกนอก popup = ปิด popup
	self:_on(UserInputService.InputBegan, function(input, processed)
		if self.Popup and IsPress(input) then
			if not Inside(self.Popup.Frame, input.Position) and not Inside(self.Popup.Owner, input.Position) then
				self:ClosePopup()
			end
		end
		-- ปุ่มซ่อน/แสดง
		if not processed and input.KeyCode == (cfg.ToggleKey or Enum.KeyCode.RightShift) then
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

	-- ไอคอน: ถ้าใส่ Icon = "rbxassetid://..." จะใช้รูป ถ้าไม่ใส่จะเป็นวงกลมเส้น
	if cfg.Icon then
		local img = New("ImageLabel", {
			Size = UDim2.fromOffset(14, 14),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 12, 0.5, 0),
			BackgroundTransparency = 1,
			Image = cfg.Icon,
			ImageColor3 = Theme.SubText,
		}, btn)
		tab.SetIconColor = function(c) img.ImageColor3 = c end
	else
		local dot = New("Frame", {
			Size = UDim2.fromOffset(12, 12),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 13, 0.5, 0),
			BackgroundTransparency = 1,
		}, btn)
		Corner(dot, 6)
		local st = New("UIStroke", { Color = Theme.SubText, Thickness = 1.5 }, dot)
		tab.SetIconColor = function(c) st.Color = c end
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
		Text = cfg.Name or "Section",
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
		Alpha = cfg.Alpha or 1,
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
--  CONTROLS
--=============================================================================

---------------------------------------------------------------- Toggle (checkbox)
-- cfg: Name, Default, Callback(value), Flag
function Section:AddToggle(cfg)
	cfg = type(cfg) == "string" and { Name = cfg } or cfg
	local toggle = { Value = false }

	local row = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 22),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = self:_next(),
	}, self.Body)

	local box = New("Frame", {
		Size = UDim2.fromOffset(18, 18),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		BackgroundColor3 = Theme.Control,
		BorderSizePixel = 0,
	}, row)
	Corner(box, 4)
	local boxStroke = Stroke(box, Color3.fromRGB(48, 48, 48))
	local mark = New("TextLabel", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "✓",
		TextColor3 = Theme.CheckMark, Font = FONT_BOLD, TextSize = 14, TextTransparency = 1,
	}, box)

	New("TextLabel", {
		Position = UDim2.fromOffset(28, 0),
		Size = UDim2.new(1, -70, 1, 0),
		BackgroundTransparency = 1,
		Text = cfg.Name or "Toggle",
		TextColor3 = Color3.fromRGB(225, 225, 225),
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = FONT,
		TextSize = 12,
	}, row)

	function toggle:Set(v, silent)
		toggle.Value = v and true or false
		SetFlag(cfg, toggle.Value)
		Tween(box, 0.12, { BackgroundColor3 = toggle.Value and Theme.Check or Theme.Control })
		Tween(mark, 0.12, { TextTransparency = toggle.Value and 0 or 1 })
		boxStroke.Color = toggle.Value and Theme.Check or Color3.fromRGB(48, 48, 48)
		if not silent and cfg.Callback then task.spawn(cfg.Callback, toggle.Value) end
	end

	-- เพิ่มช่องสีด้านขวาของ toggle นี้
	local win = self.Window
	function toggle:AddColorPicker(ccfg)
		toggle.Color = win:_newSwatch(row, ccfg or {})
		return toggle.Color
	end

	row.MouseButton1Click:Connect(function() toggle:Set(not toggle.Value) end)
	toggle:Set(cfg.Default or false, true)
	return toggle
end

---------------------------------------------------------------------- Slider
-- cfg: Name, Min, Max, Default, Increment, Suffix, Decimals, Callback(value), Flag
function Section:AddSlider(cfg)
	local win = self.Window
	local min, max = cfg.Min or 0, cfg.Max or 100
	local inc = cfg.Increment or 1
	local dec = cfg.Decimals or Decimals(inc)
	local suffix = cfg.Suffix or ""
	local slider = { Value = min }

	local holder = New("Frame", {
		Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, LayoutOrder = self:_next(),
	}, self.Body)

	New("TextLabel", {
		Size = UDim2.new(0.6, 0, 0, 16), BackgroundTransparency = 1, Text = cfg.Name or "Slider",
		TextColor3 = Color3.fromRGB(225, 225, 225), TextXAlignment = Enum.TextXAlignment.Left,
		Font = FONT, TextSize = 12,
	}, holder)
	local valueLabel = New("TextLabel", {
		Size = UDim2.new(0.4, 0, 0, 16), AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0),
		BackgroundTransparency = 1, Text = "", TextColor3 = Color3.fromRGB(200, 200, 200),
		TextXAlignment = Enum.TextXAlignment.Right, Font = FONT, TextSize = 11,
	}, holder)

	local track = New("Frame", {
		Position = UDim2.fromOffset(0, 26), Size = UDim2.new(1, 0, 0, 2),
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
		Position = UDim2.fromOffset(0, 16), Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
	}, holder)

	function slider:Set(v, silent)
		v = math.clamp(math.floor((v - min) / inc + 0.5) * inc + min, min, max)
		v = tonumber(string.format("%." .. dec .. "f", v))
		slider.Value = v
		SetFlag(cfg, v)
		fill.Size = UDim2.fromScale((v - min) / (max - min), 1)
		valueLabel.Text = string.format("%." .. dec .. "f", v) .. suffix
		if not silent and cfg.Callback then task.spawn(cfg.Callback, v) end
	end

	win:_bindDrag(hit, function(pos)
		local rel = math.clamp((pos.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		slider:Set(min + (max - min) * rel)
		Tween(knob, 0.1, { BackgroundTransparency = 0 })
	end, function()
		Tween(knob, 0.15, { BackgroundTransparency = 1 })
	end)

	slider:Set(cfg.Default or min, true)
	return slider
end

-------------------------------------------------------------------- Dropdown
-- cfg: Name, Options = {...}, Default, Multi, Callback(value), Flag
--   Multi = false -> Value เป็น string
--   Multi = true  -> Value เป็น table { [ชื่อ] = true }
function Section:AddDropdown(cfg)
	local win = self.Window
	local dd = { Options = cfg.Options or {}, Multi = cfg.Multi or false }

	if dd.Multi then
		dd.Value = {}
		for _, o in ipairs(cfg.Default or {}) do dd.Value[o] = true end
	else
		dd.Value = cfg.Default or dd.Options[1]
	end

	local holder = New("Frame", {
		Size = UDim2.new(1, 0, 0, 43), BackgroundTransparency = 1, LayoutOrder = self:_next(),
	}, self.Body)
	New("TextLabel", {
		Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Text = cfg.Name or "Dropdown",
		TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, Font = FONT, TextSize = 11,
	}, holder)

	local box = New("TextButton", {
		Position = UDim2.fromOffset(0, 19), Size = UDim2.new(1, 0, 0, 24),
		BackgroundColor3 = Theme.Control, BorderSizePixel = 0, Text = "", AutoButtonColor = false,
	}, holder)
	Corner(box, 4)
	Stroke(box, Color3.fromRGB(40, 40, 40))

	local valueLabel = New("TextLabel", {
		Position = UDim2.fromOffset(9, 0), Size = UDim2.new(1, -30, 1, 0), BackgroundTransparency = 1,
		Text = "", TextColor3 = Color3.fromRGB(150, 150, 150), TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Font = FONT, TextSize = 11,
	}, box)
	local arrow = New("TextLabel", {
		Size = UDim2.fromOffset(20, 24), AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0),
		BackgroundTransparency = 1, Text = "▾", TextColor3 = Theme.SubText, Font = FONT, TextSize = 12,
	}, box)

	local function display()
		if dd.Multi then
			local t = {}
			for _, o in ipairs(dd.Options) do
				if dd.Value[o] then table.insert(t, o) end
			end
			return #t > 0 and table.concat(t, ", ") or "None"
		end
		return dd.Value ~= nil and tostring(dd.Value) or "None"
	end

	function dd:Set(v, silent)
		if dd.Multi then
			dd.Value = {}
			for _, o in ipairs(v or {}) do dd.Value[o] = true end
		else
			dd.Value = v
		end
		valueLabel.Text = display()
		SetFlag(cfg, dd.Value)
		if not silent and cfg.Callback then task.spawn(cfg.Callback, dd.Value) end
	end

	local function open()
		win:ClosePopup()
		local ap, sz = box.AbsolutePosition, box.AbsoluteSize
		local h = math.min(#dd.Options * 22 + 8, 158)
		local list = New("ScrollingFrame", {
			Position = UDim2.fromOffset(ap.X, ap.Y + sz.Y + 4),
			Size = UDim2.fromOffset(sz.X, h),
			BackgroundColor3 = Theme.PopupBg, BorderSizePixel = 0, ZIndex = 100,
			ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Dim,
			CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		}, win.Gui)
		Corner(list, 4)
		Stroke(list, Theme.Stroke)
		New("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4) }, list)
		New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, list)

		local buttons = {}
		local function paint()
			for name, b in pairs(buttons) do
				local selected = dd.Multi and dd.Value[name] or (not dd.Multi and dd.Value == name)
				b.TextColor3 = selected and Theme.Text or Theme.SubText
			end
		end
		for i, opt in ipairs(dd.Options) do
			local b = New("TextButton", {
				Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Text = tostring(opt),
				TextXAlignment = Enum.TextXAlignment.Left, Font = FONT, TextSize = 11,
				TextColor3 = Theme.SubText, AutoButtonColor = false, LayoutOrder = i, ZIndex = 101,
			}, list)
			New("UIPadding", { PaddingLeft = UDim.new(0, 9) }, b)
			buttons[opt] = b
			b.MouseEnter:Connect(function() b.BackgroundTransparency = 0.85; b.BackgroundColor3 = Color3.new(1, 1, 1) end)
			b.MouseLeave:Connect(function() b.BackgroundTransparency = 1 end)
			b.MouseButton1Click:Connect(function()
				if dd.Multi then
					local new = {}
					for _, o in ipairs(dd.Options) do
						local on = dd.Value[o]
						if o == opt then on = not on end
						if on then table.insert(new, o) end
					end
					dd:Set(new)
					paint()
				else
					dd:Set(opt)
					win:ClosePopup()
				end
			end)
		end
		paint()

		Tween(arrow, 0.12, { Rotation = 180 })
		win.Popup = {
			Frame = list, Owner = box,
			OnClose = function() Tween(arrow, 0.12, { Rotation = 0 }) end,
		}
	end

	box.MouseButton1Click:Connect(function()
		if win.Popup and win.Popup.Owner == box then win:ClosePopup() else open() end
	end)

	dd:Set(dd.Multi and cfg.Default or dd.Value, true)
	return dd
end

--------------------------------------------------------------------- Textbox
-- cfg: Name, Default, Placeholder, Numeric, Callback(text), Flag
function Section:AddTextbox(cfg)
	local tb = { Value = cfg.Default or "" }

	local holder = New("Frame", {
		Size = UDim2.new(1, 0, 0, 43), BackgroundTransparency = 1, LayoutOrder = self:_next(),
	}, self.Body)
	New("TextLabel", {
		Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Text = cfg.Name or "Input",
		TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, Font = FONT, TextSize = 11,
	}, holder)

	local input = New("TextBox", {
		Position = UDim2.fromOffset(0, 19), Size = UDim2.new(1, 0, 0, 24),
		BackgroundColor3 = Theme.Control, BorderSizePixel = 0, Text = tb.Value,
		PlaceholderText = cfg.Placeholder or "Type here...", PlaceholderColor3 = Theme.Dim,
		TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false, Font = FONT, TextSize = 11,
	}, holder)
	Corner(input, 4)
	New("UIPadding", { PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 9) }, input)
	local st = Stroke(input, Color3.fromRGB(40, 40, 40))

	input.Focused:Connect(function() st.Color = Color3.fromRGB(90, 90, 90) end)
	input.FocusLost:Connect(function()
		st.Color = Color3.fromRGB(40, 40, 40)
		if cfg.Numeric then
			local n = tonumber(input.Text)
			input.Text = n and tostring(n) or tostring(tb.Value)
		end
		tb.Value = input.Text
		SetFlag(cfg, tb.Value)
		if cfg.Callback then task.spawn(cfg.Callback, tb.Value) end
	end)

	function tb:Set(text) input.Text = tostring(text); tb.Value = input.Text; SetFlag(cfg, tb.Value) end
	SetFlag(cfg, tb.Value)
	return tb
end

---------------------------------------------------------------------- Button
-- cfg: Name, Callback
function Section:AddButton(cfg)
	cfg = type(cfg) == "string" and { Name = cfg } or cfg
	local b = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = Theme.Control, BorderSizePixel = 0,
		Text = cfg.Name or "Button", TextColor3 = Theme.Text, Font = FONT, TextSize = 11,
		AutoButtonColor = false, LayoutOrder = self:_next(),
	}, self.Body)
	Corner(b, 4)
	Stroke(b, Color3.fromRGB(40, 40, 40))
	b.MouseEnter:Connect(function() Tween(b, 0.1, { BackgroundColor3 = Color3.fromRGB(44, 44, 44) }) end)
	b.MouseLeave:Connect(function() Tween(b, 0.1, { BackgroundColor3 = Theme.Control }) end)
	b.MouseButton1Click:Connect(function() if cfg.Callback then task.spawn(cfg.Callback) end end)
	return b
end

----------------------------------------------------------------------- Label
function Section:AddLabel(text)
	local l = New("TextLabel", {
		Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = text or "Label",
		TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, Font = FONT, TextSize = 11,
		LayoutOrder = self:_next(),
	}, self.Body)
	return { Set = function(_, t) l.Text = t end }
end

------------------------------------------------- Color picker (แถวแยกต่างหาก)
-- cfg: Name, Default (Color3), Alpha (0-1), Callback(color, alpha), Flag
function Section:AddColorPicker(cfg)
	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, LayoutOrder = self:_next(),
	}, self.Body)
	New("TextLabel", {
		Size = UDim2.new(1, -40, 1, 0), BackgroundTransparency = 1, Text = cfg.Name or "Color",
		TextColor3 = Color3.fromRGB(225, 225, 225), TextXAlignment = Enum.TextXAlignment.Left,
		Font = FONT, TextSize = 12,
	}, row)
	return self.Window:_newSwatch(row, cfg)
end

--=============================================================================
--  DEMO  (ลบส่วนนี้ทิ้งได้ถ้าจะใช้ไลบรารีเอง)
--=============================================================================
local Win = Library:CreateWindow({
	Title = "@homixida",
	Size = UDim2.fromOffset(700, 440),
	ToggleKey = Enum.KeyCode.RightShift, -- ซ่อน/แสดง UI
})

Win:AddCategory("Main")
local avatarTab  = Win:AddTab({ Name = "Avatar" })          -- ใส่ Icon = "rbxassetid://..." เพื่อใช้ไอคอนรูป
Win:AddCategory("Globals")
local viewTab    = Win:AddTab({ Name = "View" })
local playersTab = Win:AddTab({ Name = "Players" })
local worldTab   = Win:AddTab({ Name = "World" })
Win:AddCategory("Miscellaneous")

----------------------------------------------------------------- Tab: Avatar
local main = avatarTab:AddSection({ Name = "Main", Side = "Left", MinHeight = 410 })
for i = 1, 8 do
	main:AddToggle({ Name = "Label", Default = true, Flag = "avatar_toggle_" .. i })
end

local misc = avatarTab:AddSection({ Name = "Misc", Side = "Right" })
misc:AddSlider({ Name = "Label", Min = 0, Max = 360, Default = 360, Suffix = "°", Flag = "angle" })
misc:AddSlider({ Name = "Label", Min = 0, Max = 1, Default = 1, Increment = 0.001, Flag = "smooth" })
misc:AddSlider({ Name = "Label", Min = 0, Max = 1000, Default = 222, Suffix = "px", Flag = "size" })

local misc2 = avatarTab:AddSection({ Name = "Misc 2", Side = "Right" })
misc2:AddDropdown({ Name = "Label", Options = { "None", "Option 1", "Option 2", "Option 3" }, Default = "None" })
misc2:AddDropdown({ Name = "Label", Options = { "None", "Option 1", "Option 2", "Option 3" }, Default = "None" })

------------------------------------------------------------------- Tab: View
local inputs = viewTab:AddSection({ Name = "Inputs", Side = "Left" })
inputs:AddTextbox({
	Name = "Text input", Placeholder = "Type something...",
	Callback = function(text) print("Textbox:", text) end,
})
inputs:AddTextbox({ Name = "Number input", Numeric = true, Default = "100", Callback = function(t) print("Number:", t) end })
inputs:AddButton({ Name = "Print flags", Callback = function()
	for k, v in pairs(Library.Flags) do print(k, v) end
end })
inputs:AddLabel("RightShift = hide / show")

local viewR = viewTab:AddSection({ Name = "Multi dropdown", Side = "Right" })
viewR:AddDropdown({
	Name = "Pick many", Multi = true, Options = { "One", "Two", "Three", "Four" }, Default = { "Two" },
	Callback = function(v) for k in pairs(v) do print("selected:", k) end end,
})

----------------------------------------------------------------- Tab: Players
local pl = playersTab:AddSection({ Name = "Label", Side = "Left" })
pl:AddToggle({ Name = "Label", Default = true })
local colorToggle = pl:AddToggle({ Name = "Label", Default = true })
colorToggle:AddColorPicker({
	Default = Color3.fromRGB(123, 111, 255), Alpha = 123 / 255, Flag = "player_color",
	Callback = function(color, alpha) print("Color selected:", color, alpha) end,
})
pl:AddToggle({ Name = "Label", Default = true })
pl:AddToggle({ Name = "Label", Default = true })

local plR = playersTab:AddSection({ Name = "Label", Side = "Right" })
for _ = 1, 3 do
	plR:AddDropdown({ Name = "Label", Options = { "None", "Option 1", "Option 2" }, Default = "None" })
end

------------------------------------------------------------------- Tab: World
local world = worldTab:AddSection({ Name = "World", Side = "Left" })
world:AddToggle({ Name = "Label", Default = false })
world:AddColorPicker({ Name = "Sky colour", Default = Color3.fromRGB(180, 30, 20) })
world:AddSlider({ Name = "Label", Min = 0, Max = 100, Default = 50, Suffix = "%" })

return Library
