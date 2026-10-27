--[[
	GX UI Library  -  Roblox (Luau)
	สร้างตาม UI ในภาพ: 3 แผง (MENU / Title+Search / SETTINGS), Keybinds list, Watermark

	วิธีใช้ดู Example.lua
	- ใส่เป็น ModuleScript แล้ว require() หรือ loadstring ก็ได้ (return Library ท้ายไฟล์)
	- Elements: Toggle, Toggle+Keybind, Slider (Suffix/Prefix/Decimals), Keybind (Press/Hold/Toggle),
	            Dropdown, ColorPicker, Button, TextBox, Label
	- แผง SETTINGS สร้างให้อัตโนมัติ (UI Scale, Streamer Mode, Toggle UI Key, Theme, Accent, Font, Padding)
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer

--------------------------------------------------------------------------------
-- Library state
--------------------------------------------------------------------------------
local Library = {
	Version = "1.0.0",
	Flags = {},
	Options = {},
	Binds = {},
	Padding = 6,
	Scale = 1,
	Visible = true,
	Font = Enum.Font.GothamMedium,
	BoldFont = Enum.Font.GothamBold,
	FontName = "GothamMedium",
	WatermarkEnabled = true,
	KeybindListEnabled = true,
	StreamerMode = false,
	Unloaded = false,
	Connections = {},
	_themed = {},
	_texts = {},
	_refreshers = {},
	_layouts = {},
	_scales = {},
}

--------------------------------------------------------------------------------
-- Themes
--------------------------------------------------------------------------------
local function rgb(r, g, b)
	return Color3.fromRGB(r, g, b)
end

local BaseTheme = {
	Accent = rgb(235, 64, 82),
	Window = rgb(10, 10, 12),
	Panel = rgb(19, 19, 23),
	Header = rgb(27, 27, 32),
	Card = rgb(30, 30, 36),
	Input = rgb(19, 19, 23),
	Stroke = rgb(54, 54, 62),
	Track = rgb(42, 42, 50),
	Text = rgb(244, 244, 247),
	Muted = rgb(160, 160, 170),
	SubText = rgb(118, 118, 128),
	Knob = rgb(236, 236, 240),
	TabActive = rgb(37, 37, 43),
}

local function derive(overrides)
	local t = {}
	for k, v in pairs(BaseTheme) do
		t[k] = v
	end
	for k, v in pairs(overrides) do
		t[k] = v
	end
	return t
end

Library.Themes = {
	GX = derive({}),
	Midnight = derive({
		Accent = rgb(99, 102, 241), Window = rgb(8, 9, 14), Panel = rgb(15, 17, 26), Header = rgb(21, 24, 36),
		Card = rgb(24, 27, 40), Input = rgb(15, 17, 26), Track = rgb(36, 40, 58), Stroke = rgb(48, 53, 76),
		TabActive = rgb(30, 34, 50),
	}),
	Ocean = derive({ Accent = rgb(0, 163, 255) }),
	Emerald = derive({ Accent = rgb(46, 204, 113) }),
	Violet = derive({ Accent = rgb(168, 85, 247) }),
	Amber = derive({ Accent = rgb(255, 176, 32) }),
}
Library.ThemeNames = { "GX", "Midnight", "Ocean", "Emerald", "Violet", "Amber" }
Library.ThemeName = "GX"
Library.Theme = derive({})

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------
local PILL = UDim.new(1, 0)
local TWEEN_INFO = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function connect(signal, fn)
	local c = signal:Connect(fn)
	Library.Connections[#Library.Connections + 1] = c
	return c
end

local function create(class, props, children)
	local inst = Instance.new(class)
	local parent
	if props then
		for k, v in pairs(props) do
			if k == "Parent" then
				parent = v
			else
				inst[k] = v
			end
		end
	end
	if children then
		for _, c in ipairs(children) do
			c.Parent = inst
		end
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

local function themed(inst, prop, key)
	inst[prop] = Library.Theme[key]
	Library._themed[#Library._themed + 1] = { inst, prop, key }
	return inst
end

local function tween(inst, props, info)
	local t = TweenService:Create(inst, info or TWEEN_INFO, props)
	t:Play()
	return t
end

local function apply(inst, props, animate)
	if animate then
		tween(inst, props)
	else
		for k, v in pairs(props) do
			inst[k] = v
		end
	end
end

local function corner(parent, radius)
	if type(radius) == "number" then
		radius = UDim.new(0, radius)
	end
	return create("UICorner", { CornerRadius = radius, Parent = parent })
end

local function stroke(parent, key, thickness, transparency)
	local s = create("UIStroke", {
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent,
	})
	themed(s, "Color", key)
	return s
end

local function pad(parent, l, r, t, b)
	return create("UIPadding", {
		PaddingLeft = UDim.new(0, l or 0),
		PaddingRight = UDim.new(0, r or 0),
		PaddingTop = UDim.new(0, t or 0),
		PaddingBottom = UDim.new(0, b or 0),
		Parent = parent,
	})
end

local function list(parent, padding, direction, register)
	local l = create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = direction or Enum.FillDirection.Vertical,
		Padding = UDim.new(0, padding or 0),
		Parent = parent,
	})
	if register then
		Library._layouts[#Library._layouts + 1] = l
	end
	return l
end

-- สร้าง TextLabel / TextButton / TextBox ที่ผูกกับธีมและฟอนต์
local function Text(props, colorKey, bold, manualColor)
	local class = props.ClassName or "TextLabel"
	local inst = Instance.new(class)
	inst.BackgroundTransparency = 1
	inst.BorderSizePixel = 0
	inst.Font = bold and Library.BoldFont or Library.Font
	inst.TextSize = 14
	inst.TextXAlignment = Enum.TextXAlignment.Left
	inst.TextColor3 = Library.Theme[colorKey or "Text"]
	local parent
	for k, v in pairs(props) do
		if k == "Parent" then
			parent = v
		elseif k ~= "ClassName" then
			inst[k] = v
		end
	end
	Library._texts[#Library._texts + 1] = { inst, bold }
	if not manualColor then
		Library._themed[#Library._themed + 1] = { inst, "TextColor3", colorKey or "Text" }
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

local function pointer(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		local inset = GuiService:GetGuiInset()
		return Vector2.new(input.Position.X + inset.X, input.Position.Y + inset.Y)
	end
	return UserInputService:GetMouseLocation()
end

local function isPress(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

local function makeDraggable(handle, target)
	connect(handle.InputBegan, function(input)
		if isPress(input) then
			local start = pointer(input)
			local origin = target.Position
			Library._drag = function(p)
				local d = (p - start) / Library.Scale
				target.Position = UDim2.new(origin.X.Scale, origin.X.Offset + d.X, origin.Y.Scale, origin.Y.Offset + d.Y)
			end
		end
	end)
end

function Library:_startDrag(fn, input)
	self._drag = fn
	fn(pointer(input))
end

function Library:_fire(fn, ...)
	if type(fn) ~= "function" then
		return
	end
	local args = table.pack(...)
	task.spawn(function()
		local ok, err = pcall(fn, table.unpack(args, 1, args.n))
		if not ok then
			warn("[GX] callback error: " .. tostring(err))
		end
	end)
end

--------------------------------------------------------------------------------
-- Theme / font / scale / padding
--------------------------------------------------------------------------------
function Library:_applyTheme()
	for i = #self._themed, 1, -1 do
		local e = self._themed[i]
		if e[1].Parent == nil then
			table.remove(self._themed, i)
		else
			e[1][e[2]] = self.Theme[e[3]]
		end
	end
	for _, fn in ipairs(self._refreshers) do
		pcall(fn)
	end
end

function Library:SetTheme(name)
	local t = self.Themes[name]
	if not t then
		return
	end
	self.ThemeName = name
	local copy = {}
	for k, v in pairs(t) do
		copy[k] = v
	end
	self.Theme = copy
	self:_applyTheme()
	if self._accentPicker then
		self._accentPicker:Set(copy.Accent, true)
	end
end

function Library:SetAccent(color)
	self.Theme.Accent = color
	self:_applyTheme()
end

local BoldMap = {
	GothamMedium = "GothamBold",
	Gotham = "GothamBold",
	SourceSans = "SourceSansBold",
	SourceSansSemibold = "SourceSansBold",
	Arial = "ArialBold",
}

function Library:SetFont(name)
	local ok, font = pcall(function()
		return Enum.Font[name]
	end)
	if not ok or not font then
		return
	end
	local okBold, boldFont = pcall(function()
		return Enum.Font[BoldMap[name] or name]
	end)
	self.FontName = name
	self.Font = font
	self.BoldFont = (okBold and boldFont) or font
	for i = #self._texts, 1, -1 do
		local e = self._texts[i]
		if e[1].Parent == nil then
			table.remove(self._texts, i)
		else
			e[1].Font = e[2] and self.BoldFont or self.Font
		end
	end
end

function Library:SetScale(s)
	self.Scale = s
	for _, u in ipairs(self._scales) do
		u.Scale = s
	end
end

function Library:SetPadding(px)
	self.Padding = px
	for _, l in ipairs(self._layouts) do
		if l.Parent then
			l.Padding = UDim.new(0, px)
		end
	end
end

function Library:_updateOverlays()
	if self._watermark then
		local show = self.WatermarkEnabled
		if self.StreamerMode and not self.Visible then
			show = false
		end
		self._watermark.Visible = show
	end
	self:_syncList()
end

function Library:Unload()
	self.Unloaded = true
	for _, c in ipairs(self.Connections) do
		pcall(function()
			c:Disconnect()
		end)
	end
	if self.Gui then
		self.Gui:Destroy()
	end
end

--------------------------------------------------------------------------------
-- Keybinds
--------------------------------------------------------------------------------
local KeyAlias = {
	MouseButton1 = "MB1", MouseButton2 = "MB2", MouseButton3 = "MB3",
	One = "1", Two = "2", Three = "3", Four = "4", Five = "5",
	Six = "6", Seven = "7", Eight = "8", Nine = "9", Zero = "0",
}

local function keyText(key)
	if key == nil then
		return "None"
	end
	return KeyAlias[key.Name] or key.Name
end

function Library:_makeRow(bind)
	local frame = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 30),
		Parent = self._listRows,
	})
	local dot = create("Frame", {
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 14, 0.5, 0),
		Size = UDim2.fromOffset(9, 9),
		BackgroundColor3 = self.Theme.Muted,
		Parent = frame,
	})
	corner(dot, PILL)
	local name = Text({
		Text = bind.Name,
		Position = UDim2.new(0, 32, 0, 0),
		Size = UDim2.new(1, -100, 1, 0),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = frame,
	}, "Muted")
	local key = Text({
		Text = "",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 0),
		Size = UDim2.new(0, 70, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = frame,
	}, "Text", true)
	return { Frame = frame, Dot = dot, Name = name, Key = key }
end

function Library:_syncList()
	if self.Unloaded or not self._list then
		return
	end
	local count = 0
	for _, b in ipairs(self.Binds) do
		if b.ShowInList then
			count = count + 1
			if not b._row then
				b._row = self:_makeRow(b)
			end
			b._row.Frame.LayoutOrder = count
			b._row.Name.Text = b.Name
			b._row.Key.Text = keyText(b.Key)
			local active = b:GetState()
			tween(b._row.Dot, { BackgroundColor3 = active and self.Theme.Accent or self.Theme.Muted })
		elseif b._row then
			b._row.Frame:Destroy()
			b._row = nil
		end
	end
	self._list.Size = UDim2.fromOffset(238, 35 + 7 + count * 30 + 7)
	self._list.Visible = self.KeybindListEnabled and count > 0
end

function Library:_newBind(parent, opts, height, showMode)
	local bind = {
		Type = "Keybind",
		Name = opts.Name or "Keybind",
		Key = opts.Default,
		Mode = opts.Mode or "Press",
		Active = false,
		ShowInList = opts.ShowInList ~= false,
		Linked = opts.Linked,
		Flag = opts.Flag,
		Callback = opts.Callback,
	}
	local m = tostring(bind.Mode):lower()
	bind.Mode = (m == "hold" and "Hold") or (m == "toggle" and "Toggle") or "Press"
	if bind.Linked then
		bind.Mode = "Toggle"
	end

	if showMode then
		local ml = Text({
			ClassName = "TextButton",
			AutoButtonColor = false,
			Text = bind.Mode:lower(),
			TextSize = 12,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, 0),
			LayoutOrder = 1,
			Parent = parent,
		}, "SubText")
		bind.ModeLabel = ml
		if not opts.LockMode then
			connect(ml.MouseButton1Click, function()
				local order = { "Press", "Hold", "Toggle" }
				local idx = table.find(order, bind.Mode) or 1
				bind:SetMode(order[(idx % 3) + 1])
			end)
		end
	end

	local h = height or 23
	local box = Text({
		ClassName = "TextButton",
		AutoButtonColor = false,
		Text = keyText(bind.Key),
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Center,
		BackgroundTransparency = 0,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 0, h),
		LayoutOrder = 2,
		Parent = parent,
	}, "Muted")
	themed(box, "BackgroundColor3", "Input")
	corner(box, 5)
	stroke(box, "Stroke", 1)
	pad(box, 22, 22, 0, 0)
	create("UISizeConstraint", { MinSize = Vector2.new(49, h), Parent = box })
	bind.Box = box

	function bind:GetState()
		if self.Linked then
			return self.Linked.Value
		end
		return self.Active
	end

	function bind:SetKey(key)
		self.Key = key
		self.Box.Text = keyText(key)
		Library:_syncList()
	end

	function bind:SetMode(mode)
		self.Mode = mode
		if self.ModeLabel then
			self.ModeLabel.Text = mode:lower()
		end
	end

	function bind:_set(active)
		self.Active = active
		if self.Flag then
			Library.Flags[self.Flag] = active
		end
		Library:_syncList()
	end

	function bind:_trigger(down)
		if self.Linked then
			if down then
				self.Linked:Set(not self.Linked.Value)
			end
			return
		end
		if self.Mode == "Press" then
			if down then
				self:_set(true)
				Library:_fire(self.Callback)
				task.delay(0.15, function()
					self:_set(false)
				end)
			end
		elseif self.Mode == "Hold" then
			self:_set(down)
			Library:_fire(self.Callback, down)
		else
			if down then
				self:_set(not self.Active)
				Library:_fire(self.Callback, self.Active)
			end
		end
	end

	connect(box.MouseButton1Click, function()
		local current = Library._listening
		if current == bind then
			Library._listening = nil
			box.Text = keyText(bind.Key)
			return
		end
		if current then
			current.Box.Text = keyText(current.Key)
		end
		Library._listening = bind
		box.Text = "..."
	end)

	Library.Binds[#Library.Binds + 1] = bind
	if bind.Flag then
		Library.Options[bind.Flag] = bind
		Library.Flags[bind.Flag] = false
	end
	Library:_syncList()
	return bind
end

function Library:_initInput()
	connect(UserInputService.InputBegan, function(input, processed)
		local listening = Library._listening
		if listening then
			local t = input.UserInputType
			if t == Enum.UserInputType.Keyboard then
				if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
					listening:SetKey(nil)
				else
					listening:SetKey(input.KeyCode)
				end
				Library._listening = nil
			elseif t == Enum.UserInputType.MouseButton2 or t == Enum.UserInputType.MouseButton3 then
				listening:SetKey(t)
				Library._listening = nil
			end
			return
		end
		if processed then
			return
		end
		local key = input.UserInputType
		if key == Enum.UserInputType.Keyboard then
			key = input.KeyCode
		end
		for _, b in ipairs(Library.Binds) do
			if b.Key ~= nil and b.Key == key then
				b:_trigger(true)
			end
		end
	end)

	connect(UserInputService.InputEnded, function(input)
		if isPress(input) then
			Library._drag = nil
		end
		local key = input.UserInputType
		if key == Enum.UserInputType.Keyboard then
			key = input.KeyCode
		end
		for _, b in ipairs(Library.Binds) do
			if b.Key ~= nil and b.Key == key and b.Mode == "Hold" and not b.Linked then
				b:_trigger(false)
			end
		end
	end)

	connect(UserInputService.InputChanged, function(input)
		if Library._drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			Library._drag(pointer(input))
		end
	end)
end

--------------------------------------------------------------------------------
-- Section (elements)
--------------------------------------------------------------------------------
local Section = {}
Section.__index = Section

function Section:_card(height, name, desc)
	local card = create("Frame", {
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, height),
		LayoutOrder = #self.Elements + 1,
		Parent = self.Body,
	})
	themed(card, "BackgroundColor3", "Card")
	corner(card, 7)
	self.Elements[#self.Elements + 1] = {
		Frame = card,
		Search = string.lower((name or "") .. " " .. (desc or "")),
	}
	return card
end

local function titleLabel(card, text, hasDesc, reserve)
	return Text({
		Text = text or "",
		Position = UDim2.new(0, 11, 0, hasDesc and 9 or 0),
		Size = UDim2.new(1, -reserve, 0, hasDesc and 16 or 38),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = card,
	}, "Text")
end

local function descLabel(card, text, reserve)
	return Text({
		Text = text,
		TextSize = 12,
		Position = UDim2.new(0, 11, 0, 26),
		Size = UDim2.new(1, -reserve, 0, 14),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = card,
	}, "SubText")
end

local function register(obj, opts)
	obj.Name = opts.Name
	obj.Flag = opts.Flag
	obj.Callback = opts.Callback
	if obj.Flag then
		Library.Options[obj.Flag] = obj
	end
end

------------------------------------------------------------------ Toggle -----
function Section:AddToggle(opts)
	opts = opts or {}
	local hasDesc = (opts.Description or "") ~= ""
	local card = self:_card(hasDesc and 61 or 38, opts.Name, opts.Description)
	local toggle = { Type = "Toggle", Value = false }
	register(toggle, opts)

	local click = create("TextButton", {
		BackgroundTransparency = 1, Text = "", Size = UDim2.fromScale(1, 1), Parent = card,
	})

	local kb = opts.Keybind
	if typeof(kb) == "EnumItem" then
		kb = { Default = kb }
	end
	local reserve = kb and 160 or 70
	titleLabel(card, opts.Name or "Toggle", hasDesc, reserve)
	if hasDesc then
		descLabel(card, opts.Description, reserve)
	end

	local right = create("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -15, 0, hasDesc and 7 or 8),
		Size = UDim2.new(0, 0, 0, 23),
		AutomaticSize = Enum.AutomaticSize.X,
		Parent = card,
	})
	local rl = list(right, 8, Enum.FillDirection.Horizontal)
	rl.VerticalAlignment = Enum.VerticalAlignment.Center
	rl.HorizontalAlignment = Enum.HorizontalAlignment.Right

	local track = create("Frame", {
		BorderSizePixel = 0, Size = UDim2.fromOffset(39, 19), LayoutOrder = 2, Parent = right,
	})
	corner(track, PILL)
	local knob = create("Frame", {
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 2, 0.5, 0),
		Size = UDim2.fromOffset(15, 15),
		Parent = track,
	})
	corner(knob, PILL)
	themed(knob, "BackgroundColor3", "Knob")

	local function render(animate)
		local on = toggle.Value
		apply(track, { BackgroundColor3 = on and Library.Theme.Accent or Library.Theme.Track }, animate)
		apply(knob, { Position = UDim2.new(0, on and 22 or 2, 0.5, 0) }, animate)
	end

	function toggle:Set(v, silent)
		v = v and true or false
		local changed = v ~= self.Value
		self.Value = v
		if self.Flag then
			Library.Flags[self.Flag] = v
		end
		render(true)
		Library:_syncList()
		if changed and not silent then
			Library:_fire(self.Callback, v)
		end
	end

	if kb then
		kb.Name = opts.Name
		kb.Linked = toggle
		kb.Mode = "Toggle"
		toggle.Keybind = Library:_newBind(right, kb, 23, false)
	end

	connect(click.MouseButton1Click, function()
		toggle:Set(not toggle.Value)
	end)

	Library._refreshers[#Library._refreshers + 1] = function()
		render(false)
	end

	toggle.Value = opts.Default and true or false
	if toggle.Flag then
		Library.Flags[toggle.Flag] = toggle.Value
	end
	render(false)
	Library:_syncList()
	return toggle
end

------------------------------------------------------------------ Slider -----
function Section:AddSlider(opts)
	opts = opts or {}
	local hasDesc = (opts.Description or "") ~= ""
	local h = hasDesc and 84 or 62
	local card = self:_card(h, opts.Name, opts.Description)
	local min, max = opts.Min or 0, opts.Max or 100
	local inc = opts.Increment or 1
	local decimals = opts.Decimals
	if decimals == nil then
		local s = tostring(inc)
		local dot = s:find("%.")
		decimals = dot and (#s - dot) or 0
	end
	local slider = { Type = "Slider", Value = min }
	register(slider, opts)

	titleLabel(card, opts.Name or "Slider", hasDesc, 120)
	if hasDesc then
		descLabel(card, opts.Description, 120)
	end

	local valueLabel = Text({
		Text = "",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -15, 0, hasDesc and 9 or 11),
		Size = UDim2.fromOffset(110, 16),
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = card,
	}, "Text", true)

	local track = create("Frame", {
		BorderSizePixel = 0,
		Position = UDim2.new(0, 11, 1, -19),
		Size = UDim2.new(1, -23, 0, 5),
		Parent = card,
	})
	themed(track, "BackgroundColor3", "Track")
	corner(track, PILL)
	local fill = create("Frame", { BorderSizePixel = 0, Size = UDim2.new(0, 0, 1, 0), Parent = track })
	themed(fill, "BackgroundColor3", "Accent")
	corner(fill, PILL)
	local knob = create("Frame", {
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		ZIndex = 2,
		Parent = track,
	})
	themed(knob, "BackgroundColor3", "Knob")
	corner(knob, PILL)

	local hit = create("TextButton", {
		BackgroundTransparency = 1,
		Text = "",
		Position = UDim2.new(0, 4, 1, -32),
		Size = UDim2.new(1, -8, 0, 28),
		ZIndex = 3,
		Parent = card,
	})

	local function format(v)
		local s
		if decimals > 0 then
			s = string.format("%." .. decimals .. "f", v)
		else
			s = tostring(math.floor(v + 0.5))
		end
		return (opts.Prefix or "") .. s .. (opts.Suffix or "")
	end

	function slider:Set(v, silent)
		v = tonumber(v) or min
		v = math.clamp(v, min, max)
		v = math.floor((v - min) / inc + 0.5) * inc + min
		v = math.round(v * 1000000) / 1000000
		v = math.clamp(v, min, max)
		local changed = v ~= self.Value
		self.Value = v
		local a = (max == min) and 0 or (v - min) / (max - min)
		fill.Size = UDim2.new(a, 0, 1, 0)
		knob.Position = UDim2.new(a, 0, 0.5, 0)
		valueLabel.Text = format(v)
		if self.Flag then
			Library.Flags[self.Flag] = v
		end
		if changed and not silent then
			Library:_fire(self.Callback, v)
		end
	end

	local function fromPointer(p)
		local a = math.clamp((p.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		slider:Set(min + a * (max - min))
	end

	connect(hit.InputBegan, function(input)
		if isPress(input) then
			Library:_startDrag(fromPointer, input)
		end
	end)

	slider.Value = nil
	slider:Set(opts.Default or min, true)
	return slider
end

---------------------------------------------------------------- Dropdown -----
function Section:AddDropdown(opts)
	opts = opts or {}
	local card = self:_card(38, opts.Name)
	card.ClipsDescendants = true
	local dd = { Type = "Dropdown", Values = opts.Values or {}, Open = false }
	register(dd, opts)

	local header = create("TextButton", {
		BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 0, 38), Parent = card,
	})
	titleLabel(card, opts.Name or "Dropdown", false, 150)
	local valueLabel = Text({
		Text = "",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -34, 0, 11),
		Size = UDim2.fromOffset(84, 16),
		TextXAlignment = Enum.TextXAlignment.Right,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = card,
	}, "Muted")
	local arrow = Text({
		Text = "v",
		TextSize = 11,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, -21, 0, 19),
		Size = UDim2.fromOffset(12, 12),
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = card,
	}, "SubText", true)

	local holder = create("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(8, 42),
		Size = UDim2.new(1, -16, 0, 0),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		Parent = card,
	})
	themed(holder, "ScrollBarImageColor3", "Accent")
	list(holder, 2)

	local buttons = {}

	local function paint()
		for _, e in ipairs(buttons) do
			e.Button.TextColor3 = (e.Value == dd.Value) and Library.Theme.Accent or Library.Theme.Muted
		end
	end

	local function targetHeight()
		local n = math.min(#dd.Values, 6)
		if n == 0 then
			return 38
		end
		return 42 + (n * 26 + (n - 1) * 2) + 8
	end

	local function setOpen(open)
		dd.Open = open
		tween(card, { Size = UDim2.new(1, 0, 0, open and targetHeight() or 38) })
		tween(arrow, { Rotation = open and 180 or 0 })
	end

	function dd:Set(v, silent)
		local changed = v ~= self.Value
		self.Value = v
		valueLabel.Text = tostring(v)
		paint()
		if self.Flag then
			Library.Flags[self.Flag] = v
		end
		if changed and not silent then
			Library:_fire(self.Callback, v)
		end
	end

	local function rebuild()
		for _, e in ipairs(buttons) do
			e.Button:Destroy()
		end
		buttons = {}
		for i, value in ipairs(dd.Values) do
			local b = Text({
				ClassName = "TextButton",
				AutoButtonColor = false,
				Text = tostring(value),
				TextSize = 13,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 26),
				LayoutOrder = i,
				Parent = holder,
			}, "Muted", false, true)
			themed(b, "BackgroundColor3", "Header")
			corner(b, 5)
			pad(b, 8, 0, 0, 0)
			connect(b.MouseEnter, function()
				tween(b, { BackgroundTransparency = 0 })
			end)
			connect(b.MouseLeave, function()
				tween(b, { BackgroundTransparency = 1 })
			end)
			connect(b.MouseButton1Click, function()
				dd:Set(value)
				setOpen(false)
			end)
			buttons[#buttons + 1] = { Button = b, Value = value }
		end
		local n = math.min(#dd.Values, 6)
		holder.Size = UDim2.new(1, -16, 0, n > 0 and (n * 26 + (n - 1) * 2) or 0)
		paint()
	end

	function dd:SetValues(values)
		self.Values = values
		rebuild()
		if table.find(values, self.Value) == nil then
			self:Set(values[1], true)
		end
	end

	connect(header.MouseButton1Click, function()
		setOpen(not dd.Open)
	end)

	Library._refreshers[#Library._refreshers + 1] = paint

	rebuild()
	dd:Set(opts.Default or dd.Values[1], true)
	return dd
end

------------------------------------------------------------- ColorPicker -----
function Section:AddColorPicker(opts)
	opts = opts or {}
	local card = self:_card(38, opts.Name)
	card.ClipsDescendants = true
	local cp = { Type = "ColorPicker", Value = opts.Default or Color3.fromRGB(255, 0, 0), Open = false }
	register(cp, opts)
	local hh, ss, vv = cp.Value:ToHSV()

	local header = create("TextButton", {
		BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 0, 38), Parent = card,
	})
	titleLabel(card, opts.Name or "Color", false, 100)
	local swatch = create("Frame", {
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -15, 0, 19),
		Size = UDim2.fromOffset(35, 18),
		BackgroundColor3 = cp.Value,
		Parent = card,
	})
	corner(swatch, 5)

	local area = create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(11, 46),
		Size = UDim2.new(1, -22, 0, 96),
		Parent = card,
	})

	local sv = create("Frame", {
		BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 78), BackgroundColor3 = Color3.fromHSV(hh, 1, 1), Parent = area,
	})
	corner(sv, 5)
	local white = create("Frame", {
		BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), Parent = sv,
	})
	corner(white, 5)
	create("UIGradient", {
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }),
		Parent = white,
	})
	local black = create("Frame", {
		BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), ZIndex = 2, Parent = sv,
	})
	corner(black, 5)
	create("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }),
		Parent = black,
	})
	local svCursor = create("Frame", {
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(9, 9),
		BackgroundColor3 = Color3.new(1, 1, 1),
		ZIndex = 4,
		Parent = sv,
	})
	corner(svCursor, PILL)
	create("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1, Parent = svCursor })

	local hue = create("Frame", {
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 86),
		Size = UDim2.new(1, 0, 0, 10),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = area,
	})
	corner(hue, 5)
	local seq = {}
	for i = 0, 6 do
		seq[#seq + 1] = ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i == 6 and 0 or i / 6, 1, 1))
	end
	create("UIGradient", { Color = ColorSequence.new(seq), Parent = hue })
	local hueCursor = create("Frame", {
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(4, 14),
		BackgroundColor3 = Color3.new(1, 1, 1),
		ZIndex = 4,
		Parent = hue,
	})
	corner(hueCursor, 2)
	create("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1, Parent = hueCursor })

	local function refresh(silent)
		cp.Value = Color3.fromHSV(hh, ss, vv)
		swatch.BackgroundColor3 = cp.Value
		sv.BackgroundColor3 = Color3.fromHSV(hh, 1, 1)
		svCursor.Position = UDim2.new(ss, 0, 1 - vv, 0)
		hueCursor.Position = UDim2.new(hh, 0, 0.5, 0)
		if cp.Flag then
			Library.Flags[cp.Flag] = cp.Value
		end
		if not silent then
			Library:_fire(cp.Callback, cp.Value)
		end
	end

	function cp:Set(color, silent)
		hh, ss, vv = color:ToHSV()
		refresh(silent)
	end

	connect(sv.InputBegan, function(input)
		if isPress(input) then
			Library:_startDrag(function(p)
				ss = math.clamp((p.X - sv.AbsolutePosition.X) / math.max(sv.AbsoluteSize.X, 1), 0, 1)
				vv = 1 - math.clamp((p.Y - sv.AbsolutePosition.Y) / math.max(sv.AbsoluteSize.Y, 1), 0, 1)
				refresh(false)
			end, input)
		end
	end)
	connect(hue.InputBegan, function(input)
		if isPress(input) then
			Library:_startDrag(function(p)
				hh = math.clamp((p.X - hue.AbsolutePosition.X) / math.max(hue.AbsoluteSize.X, 1), 0, 0.999)
				refresh(false)
			end, input)
		end
	end)
	connect(header.MouseButton1Click, function()
		cp.Open = not cp.Open
		tween(card, { Size = UDim2.new(1, 0, 0, cp.Open and 152 or 38) })
	end)

	refresh(true)
	return cp
end

----------------------------------------------------------------- Keybind -----
function Section:AddKeybind(opts)
	opts = opts or {}
	local card = self:_card(38, opts.Name)
	titleLabel(card, opts.Name or "Keybind", false, 190)
	local right = create("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -15, 0.5, 0),
		Size = UDim2.new(0, 0, 0, 25),
		AutomaticSize = Enum.AutomaticSize.X,
		Parent = card,
	})
	local rl = list(right, 6, Enum.FillDirection.Horizontal)
	rl.VerticalAlignment = Enum.VerticalAlignment.Center
	rl.HorizontalAlignment = Enum.HorizontalAlignment.Right
	return Library:_newBind(right, opts, 25, true)
end

------------------------------------------------------------------ Button -----
function Section:AddButton(opts)
	opts = opts or {}
	local card = self:_card(38, opts.Name)
	local btn = Text({
		ClassName = "TextButton",
		AutoButtonColor = false,
		Text = opts.Name or "Button",
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
		Parent = card,
	}, "Text")
	connect(btn.MouseButton1Click, function()
		card.BackgroundColor3 = Library.Theme.Accent
		tween(card, { BackgroundColor3 = Library.Theme.Card }, TweenInfo.new(0.35))
		Library:_fire(opts.Callback)
	end)
	return { Type = "Button", Name = opts.Name }
end

----------------------------------------------------------------- TextBox -----
function Section:AddTextBox(opts)
	opts = opts or {}
	local card = self:_card(38, opts.Name)
	local obj = { Type = "TextBox", Value = opts.Default or "" }
	register(obj, opts)
	titleLabel(card, opts.Name or "TextBox", false, 170)
	local boxFrame = create("Frame", {
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -15, 0.5, 0),
		Size = UDim2.fromOffset(130, 25),
		Parent = card,
	})
	themed(boxFrame, "BackgroundColor3", "Input")
	corner(boxFrame, 5)
	stroke(boxFrame, "Stroke", 1)
	local box = Text({
		ClassName = "TextBox",
		Text = obj.Value,
		PlaceholderText = opts.Placeholder or "",
		ClearTextOnFocus = false,
		TextSize = 12,
		Position = UDim2.fromOffset(8, 0),
		Size = UDim2.new(1, -16, 1, 0),
		ClipsDescendants = true,
		Parent = boxFrame,
	}, "Muted")
	themed(box, "PlaceholderColor3", "SubText")
	function obj:Set(v, silent)
		self.Value = tostring(v)
		box.Text = self.Value
		if self.Flag then
			Library.Flags[self.Flag] = self.Value
		end
		if not silent then
			Library:_fire(self.Callback, self.Value)
		end
	end
	connect(box.FocusLost, function()
		obj:Set(box.Text)
	end)
	if obj.Flag then
		Library.Flags[obj.Flag] = obj.Value
	end
	return obj
end

------------------------------------------------------------------- Label -----
function Section:AddLabel(text)
	local card = self:_card(30, text)
	local lbl = Text({
		Text = text or "",
		TextSize = 12,
		Position = UDim2.new(0, 11, 0, 0),
		Size = UDim2.new(1, -22, 1, 0),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = card,
	}, "SubText")
	return {
		SetText = function(_, t)
			lbl.Text = t
		end,
	}
end

function Section:SetOpen(open)
	self.Open = open
	self.Body.Visible = open or (Library.Query or "") ~= ""
	tween(self.Chevron, { Rotation = open and 0 or -90 })
end

--------------------------------------------------------------------------------
-- Tab
--------------------------------------------------------------------------------
local Tab = {}
Tab.__index = Tab

local function newPage(parent)
	local page = create("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 4,
		ScrollBarImageTransparency = 0.3,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		VerticalScrollBarInset = Enum.ScrollBarInset.None,
		Visible = false,
		Parent = parent,
	})
	themed(page, "ScrollBarImageColor3", "Accent")
	pad(page, 7, 12, 6, 8)
	list(page, Library.Padding, nil, true)
	return page
end

function Tab:AddSection(opts)
	if type(opts) == "string" then
		opts = { Name = opts }
	end
	opts = opts or {}
	local section = setmetatable({
		Name = opts.Name or "Section",
		Elements = {},
		Tab = self,
		Open = opts.Open ~= false,
	}, Section)

	local frame = create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = #self.Sections + 1,
		Parent = self.Page,
	})
	list(frame, Library.Padding, nil, true)
	section.Frame = frame

	local header = create("TextButton", {
		BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 0, 28), LayoutOrder = 0, Parent = frame,
	})
	local bar = create("Frame", {
		BorderSizePixel = 0, Position = UDim2.fromOffset(8, 7), Size = UDim2.fromOffset(3, 14), Parent = header,
	})
	themed(bar, "BackgroundColor3", "Accent")
	corner(bar, 2)
	Text({
		Text = string.upper(section.Name),
		TextSize = 12,
		Position = UDim2.fromOffset(19, 0),
		Size = UDim2.new(1, -60, 1, 0),
		Parent = header,
	}, "Text", true)
	section.Chevron = Text({
		Text = "v",
		TextSize = 11,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, -20, 0.5, 0),
		Size = UDim2.fromOffset(12, 12),
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = header,
	}, "SubText", true)

	local body = create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 1,
		Parent = frame,
	})
	list(body, Library.Padding, nil, true)
	section.Body = body

	connect(header.MouseButton1Click, function()
		section:SetOpen(not section.Open)
	end)
	section:SetOpen(section.Open)

	self.Sections[#self.Sections + 1] = section
	return section
end

--------------------------------------------------------------------------------
-- Window
--------------------------------------------------------------------------------
local Window = {}
Window.__index = Window

local function isImage(icon)
	if type(icon) == "number" then
		return true
	end
	if type(icon) == "string" then
		return icon:find("^rbxassetid://") ~= nil or icon:find("^rbxasset://") ~= nil or icon:find("^http") ~= nil
	end
	return false
end

function Window:SelectTab(tab)
	for _, t in ipairs(self.Tabs) do
		t.Page.Visible = (t == tab)
		t:_paint(t == tab, true)
	end
	self.CurrentTab = tab
end

function Window:SetVisible(v)
	Library.Visible = v and true or false
	self.Main.Visible = Library.Visible
	Library:_updateOverlays()
end

function Window:Toggle()
	self:SetVisible(not Library.Visible)
end

function Window:Destroy()
	Library:Unload()
end

function Window:_search(query)
	query = string.lower(query or "")
	Library.Query = query
	local firstMatch
	for _, tab in ipairs(self.Tabs) do
		local tabMatches = 0
		for _, sec in ipairs(tab.Sections) do
			local nameMatch = query ~= "" and string.find(string.lower(sec.Name), query, 1, true) ~= nil
			local shown = 0
			for _, el in ipairs(sec.Elements) do
				local show = query == "" or nameMatch or string.find(el.Search, query, 1, true) ~= nil
				el.Frame.Visible = show
				if show then
					shown = shown + 1
				end
			end
			sec.Frame.Visible = query == "" or shown > 0
			sec.Body.Visible = sec.Open or query ~= ""
			tabMatches = tabMatches + shown
		end
		tab.Matches = tabMatches
		tab.Label.TextTransparency = (query ~= "" and tabMatches == 0) and 0.55 or 0
		if query ~= "" and tabMatches > 0 and not firstMatch then
			firstMatch = tab
		end
	end
	if query ~= "" and firstMatch and self.CurrentTab and (self.CurrentTab.Matches or 0) == 0 then
		self:SelectTab(firstMatch)
	end
end

function Window:AddTab(opts)
	if type(opts) == "string" then
		opts = { Name = opts }
	end
	opts = opts or {}
	local tab = setmetatable({ Name = opts.Name or "Tab", Sections = {}, Window = self }, Tab)

	local btn = create("TextButton", {
		AutoButtonColor = false,
		Text = "",
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 35),
		LayoutOrder = #self.Tabs + 1,
		Parent = self._tabList,
	})
	themed(btn, "BackgroundColor3", "TabActive")
	corner(btn, 6)

	local bar = create("Frame", {
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(3, 22),
		Parent = btn,
	})
	themed(bar, "BackgroundColor3", "Accent")
	corner(bar, 2)

	local iconObj, iconProp
	if opts.Icon then
		if isImage(opts.Icon) then
			local id = type(opts.Icon) == "number" and ("rbxassetid://" .. opts.Icon) or opts.Icon
			iconObj = create("ImageLabel", {
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 12, 0.5, 0),
				Size = UDim2.fromOffset(16, 16),
				Image = id,
				Parent = btn,
			})
			iconProp = "ImageColor3"
		else
			iconObj = Text({
				Text = tostring(opts.Icon),
				TextSize = 16,
				TextXAlignment = Enum.TextXAlignment.Center,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 12, 0.5, 0),
				Size = UDim2.fromOffset(16, 16),
				Parent = btn,
			}, "Muted", false, true)
			iconProp = "TextColor3"
		end
	end

	local label = Text({
		Text = tab.Name,
		Position = UDim2.new(0, iconObj and 37 or 14, 0, 0),
		Size = UDim2.new(1, -(iconObj and 44 or 20), 1, 0),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = btn,
	}, "Muted", false, true)

	tab.Button, tab.Label, tab.Matches = btn, label, 0
	tab.Page = newPage(self._pages)

	function tab:_paint(selected, instant)
		local t = Library.Theme
		apply(btn, { BackgroundTransparency = selected and 0 or 1 }, not instant)
		apply(bar, { BackgroundTransparency = selected and 0 or 1 }, not instant)
		apply(label, { TextColor3 = selected and t.Text or t.Muted }, not instant)
		if iconObj then
			apply(iconObj, { [iconProp] = selected and t.Accent or t.Muted }, not instant)
		end
		tab._selected = selected
	end

	Library._refreshers[#Library._refreshers + 1] = function()
		tab:_paint(tab._selected, true)
	end

	connect(btn.MouseEnter, function()
		if not tab._selected then
			tween(btn, { BackgroundTransparency = 0.6 })
		end
	end)
	connect(btn.MouseLeave, function()
		if not tab._selected then
			tween(btn, { BackgroundTransparency = 1 })
		end
	end)
	connect(btn.MouseButton1Click, function()
		self:SelectTab(tab)
	end)

	self.Tabs[#self.Tabs + 1] = tab
	tab:_paint(false, true)
	if #self.Tabs == 1 then
		self:SelectTab(tab)
	end
	return tab
end

--------------------------------------------------------------------------------
-- CreateWindow
--------------------------------------------------------------------------------
local function guiParent()
	if typeof(gethui) == "function" then
		local ok, result = pcall(gethui)
		if ok and result then
			return result
		end
	end
	return LocalPlayer:WaitForChild("PlayerGui")
end

local function randomName()
	local chars = {}
	for i = 1, 12 do
		chars[i] = string.char(math.random(97, 122))
	end
	return table.concat(chars)
end

local function grip(parent, x, y)
	local g = create("Frame", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(6, 6), Parent = parent,
	})
	for i = 0, 1 do
		for j = 0, 1 do
			local d = create("Frame", {
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(i * 4, j * 4),
				Size = UDim2.fromOffset(2, 2),
				Parent = g,
			})
			themed(d, "BackgroundColor3", "SubText")
		end
	end
	return g
end

local function buildPanel(parent, pos, size)
	local panel = create("Frame", {
		BorderSizePixel = 0, Position = pos, Size = size, ClipsDescendants = true, Parent = parent,
	})
	themed(panel, "BackgroundColor3", "Panel")
	corner(panel, 8)
	local header = create("Frame", { BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 32), Parent = panel })
	themed(header, "BackgroundColor3", "Header")
	local line = create("Frame", {
		BorderSizePixel = 0, Position = UDim2.new(0, 8, 0, 0), Size = UDim2.new(1, -16, 0, 2), ZIndex = 3, Parent = panel,
	})
	themed(line, "BackgroundColor3", "Accent")
	corner(line, 1)
	local content = create("Frame", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 32), Size = UDim2.new(1, 0, 1, -32), Parent = panel,
	})
	return panel, header, content
end

function Library:CreateWindow(config)
	assert(not self.Window, "[GX] CreateWindow can only be called once")
	config = config or {}
	local window = setmetatable({ Tabs = {} }, Window)
	self.Window = window
	self.KeybindListEnabled = config.KeybindList ~= false
	self.WatermarkEnabled = not (config.Watermark and config.Watermark.Enabled == false)

	-- root ---------------------------------------------------------------
	local gui = create("ScreenGui", {
		Name = randomName(),
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 1000,
	})
	if syn and syn.protect_gui then
		pcall(syn.protect_gui, gui)
	end
	gui.Parent = guiParent()
	self.Gui = gui

	self:_initInput()

	-- main window --------------------------------------------------------
	local main = create("Frame", {
		Name = "Main",
		Active = true,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, -28),
		Size = UDim2.fromOffset(880, 540),
		BorderSizePixel = 0,
		Parent = gui,
	})
	themed(main, "BackgroundColor3", "Window")
	corner(main, 10)
	stroke(main, "Panel", 1.5)
	local mainScale = create("UIScale", { Parent = main })
	self._scales[#self._scales + 1] = mainScale
	window.Main = main

	-- MENU panel ---------------------------------------------------------
	local menu, menuHeader, menuContent = buildPanel(main, UDim2.fromOffset(12, 12), UDim2.fromOffset(250, 516))
	grip(menuHeader, 15, 13)
	Text({
		Text = config.MenuTitle or "MENU",
		TextSize = 15,
		Position = UDim2.fromOffset(28, 0),
		Size = UDim2.new(1, -40, 1, 0),
		Parent = menuHeader,
	}, "Text", true)
	makeDraggable(menuHeader, main)

	local tabList = create("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		Parent = menuContent,
	})
	themed(tabList, "ScrollBarImageColor3", "Accent")
	pad(tabList, 7, 7, 6, 6)
	list(tabList, self.Padding, nil, true)
	window._tabList = tabList

	-- CENTER panel -------------------------------------------------------
	local center, centerHeader, centerContent = buildPanel(main, UDim2.fromOffset(270, 12), UDim2.fromOffset(340, 516))
	local dragHandle = create("Frame", {
		BackgroundTransparency = 1, Size = UDim2.new(1, -196, 1, 0), Parent = centerHeader,
	})
	makeDraggable(dragHandle, main)
	grip(centerHeader, 15, 13)
	Text({
		Text = config.Title or "Title",
		TextSize = 14,
		Position = UDim2.fromOffset(28, 5),
		Size = UDim2.fromOffset(130, 16),
		Parent = centerHeader,
	}, "Text", true)
	Text({
		Text = config.SubTitle or "SubTitle",
		TextSize = 11,
		Position = UDim2.fromOffset(28, 17),
		Size = UDim2.fromOffset(130, 13),
		Parent = centerHeader,
	}, "SubText")

	local searchBox = create("Frame", {
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 4),
		Size = UDim2.fromOffset(178, 25),
		Parent = centerHeader,
	})
	themed(searchBox, "BackgroundColor3", "Input")
	corner(searchBox, 6)
	stroke(searchBox, "Stroke", 1)
	local ring = create("Frame", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(9, 6), Size = UDim2.fromOffset(10, 10), Parent = searchBox,
	})
	corner(ring, PILL)
	stroke(ring, "Muted", 1.5)
	local handleLine = create("Frame", {
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(19, 17),
		Size = UDim2.fromOffset(6, 2),
		Rotation = 45,
		Parent = searchBox,
	})
	themed(handleLine, "BackgroundColor3", "Muted")
	local searchInput = Text({
		ClassName = "TextBox",
		Text = "",
		PlaceholderText = "Search all tabs...",
		ClearTextOnFocus = false,
		TextSize = 13,
		Position = UDim2.fromOffset(28, 0),
		Size = UDim2.new(1, -34, 1, 0),
		ClipsDescendants = true,
		Parent = searchBox,
	}, "Text")
	themed(searchInput, "PlaceholderColor3", "SubText")
	connect(searchInput:GetPropertyChangedSignal("Text"), function()
		window:_search(searchInput.Text)
	end)

	window._pages = centerContent

	-- SETTINGS panel -----------------------------------------------------
	local settingsPanel, settingsHeader, settingsContent = buildPanel(main, UDim2.fromOffset(618, 12), UDim2.fromOffset(250, 516))
	grip(settingsHeader, 15, 13)
	Text({
		Text = config.SettingsTitle or "SETTINGS",
		TextSize = 15,
		Position = UDim2.fromOffset(28, 0),
		Size = UDim2.new(1, -40, 1, 0),
		Parent = settingsHeader,
	}, "Text", true)
	makeDraggable(settingsHeader, main)

	-- KEYBINDS list ------------------------------------------------------
	local kb = create("Frame", {
		Name = "Keybinds",
		BorderSizePixel = 0,
		Position = UDim2.new(0, 60, 0.5, -103),
		Size = UDim2.fromOffset(238, 49),
		ClipsDescendants = true,
		Visible = false,
		Parent = gui,
	})
	themed(kb, "BackgroundColor3", "Panel")
	corner(kb, 8)
	stroke(kb, "Window", 2)
	local kbScale = create("UIScale", { Parent = kb })
	self._scales[#self._scales + 1] = kbScale
	local kbHeader = create("Frame", { BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 35), Parent = kb })
	themed(kbHeader, "BackgroundColor3", "Header")
	local kbLine = create("Frame", {
		BorderSizePixel = 0, Position = UDim2.new(0, 9, 0, 0), Size = UDim2.new(1, -18, 0, 2), ZIndex = 3, Parent = kb,
	})
	themed(kbLine, "BackgroundColor3", "Accent")
	corner(kbLine, 1)
	Text({
		Text = "KEYBINDS",
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, -20, 1, 0),
		Parent = kbHeader,
	}, "Text", true)
	local rows = create("Frame", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 42), Size = UDim2.new(1, 0, 1, -42), Parent = kb,
	})
	list(rows, 0)
	makeDraggable(kbHeader, kb)
	self._list = kb
	self._listRows = rows
	self._refreshers[#self._refreshers + 1] = function()
		self:_syncList()
	end

	-- WATERMARK ----------------------------------------------------------
	local wcfg = config.Watermark or {}
	local wm = create("Frame", {
		Name = "Watermark",
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, -440, 0.5, 250),
		Size = UDim2.fromOffset(0, 55),
		AutomaticSize = Enum.AutomaticSize.X,
		Parent = gui,
	})
	themed(wm, "BackgroundColor3", "Panel")
	corner(wm, 7)
	stroke(wm, "Window", 2)
	pad(wm, 0, 14, 0, 0)
	create("UISizeConstraint", { MinSize = Vector2.new(150, 55), Parent = wm })
	local wmScale = create("UIScale", { Parent = wm })
	self._scales[#self._scales + 1] = wmScale

	local av = create("Frame", {
		BorderSizePixel = 0, Position = UDim2.fromOffset(6, 7), Size = UDim2.fromOffset(41, 41), Parent = wm,
	})
	themed(av, "BackgroundColor3", "Card")
	corner(av, 8)
	stroke(av, "Accent", 2)
	local img = create("ImageLabel", {
		BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Image = wcfg.Avatar or "", Parent = av,
	})
	corner(img, 7)
	if not wcfg.Avatar then
		task.spawn(function()
			local ok, url = pcall(function()
				return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
			end)
			if ok and url and img.Parent then
				img.Image = url
			end
		end)
	end
	Text({
		Text = wcfg.Name or LocalPlayer.Name,
		Position = UDim2.fromOffset(54, 9),
		Size = UDim2.fromOffset(0, 16),
		AutomaticSize = Enum.AutomaticSize.X,
		Parent = wm,
	}, "Text", true)
	Text({
		Text = wcfg.Info or (tostring(LocalPlayer.UserId) .. "  |  " .. os.date("%m/%d/%Y")),
		TextSize = 11,
		Position = UDim2.fromOffset(54, 30),
		Size = UDim2.fromOffset(0, 13),
		AutomaticSize = Enum.AutomaticSize.X,
		Parent = wm,
	}, "SubText")
	makeDraggable(wm, wm)
	self._watermark = wm

	-- SETTINGS content (built-in) ----------------------------------------
	local settingsPage = newPage(settingsContent)
	settingsPage.Visible = true
	local settings = setmetatable({ Name = "Settings", Sections = {}, Page = settingsPage, Window = window }, Tab)
	window.Settings = settings

	local interface = settings:AddSection("Interface")
	interface:AddSlider({
		Name = "UI Scale",
		Description = "Resize the whole interface",
		Min = 50, Max = 150, Default = config.UIScale or 100, Suffix = " %",
		Callback = function(v)
			Library:SetScale(v / 100)
		end,
	})
	interface:AddToggle({
		Name = "Streamer Mode",
		Description = "Hide watermark when UI is closed",
		Default = false,
		Callback = function(v)
			Library.StreamerMode = v
			Library:_updateOverlays()
		end,
	})
	interface:AddKeybind({
		Name = "Toggle UI Key",
		Default = config.ToggleKey or Enum.KeyCode.RightAlt,
		Mode = "Press",
		LockMode = true,
		ShowInList = false,
		Callback = function()
			window:Toggle()
		end,
	})

	local appearance = settings:AddSection("Appearance")
	appearance:AddDropdown({
		Name = "UI Theme",
		Values = Library.ThemeNames,
		Default = "GX",
		Callback = function(v)
			Library:SetTheme(v)
		end,
	})
	self._accentPicker = appearance:AddColorPicker({
		Name = "Accent Color",
		Default = Library.Theme.Accent,
		Callback = function(c)
			Library:SetAccent(c)
		end,
	})
	local fonts = {}
	for _, name in ipairs({
		"GothamMedium", "Gotham", "SourceSans", "SourceSansSemibold", "Ubuntu", "Roboto", "RobotoMono",
		"Nunito", "Jura", "Oswald", "TitilliumWeb", "Arial", "Code",
	}) do
		local ok = pcall(function()
			return Enum.Font[name]
		end)
		if ok then
			fonts[#fonts + 1] = name
		end
	end
	appearance:AddDropdown({
		Name = "Text Font",
		Values = fonts,
		Default = "GothamMedium",
		Callback = function(v)
			Library:SetFont(v)
		end,
	})
	appearance:AddSlider({
		Name = "Element Padding",
		Description = "Gap between cards and elements",
		Min = 2, Max = 16, Default = 6, Suffix = " px",
		Callback = function(v)
			Library:SetPadding(v)
		end,
	})

	local overlay = settings:AddSection("Overlay")
	overlay:AddToggle({
		Name = "Watermark",
		Description = "Show the user watermark",
		Default = self.WatermarkEnabled,
		Callback = function(v)
			Library.WatermarkEnabled = v
			Library:_updateOverlays()
		end,
	})
	overlay:AddToggle({
		Name = "Keybind List",
		Description = "Show the active keybinds window",
		Default = self.KeybindListEnabled,
		Callback = function(v)
			Library.KeybindListEnabled = v
			Library:_syncList()
		end,
	})

	local misc = settings:AddSection("Misc")
	misc:AddButton({
		Name = "Unload UI",
		Callback = function()
			Library:Unload()
		end,
	})

	self:SetScale((config.UIScale or 100) / 100)
	self:_updateOverlays()
	return window
end

return Library
