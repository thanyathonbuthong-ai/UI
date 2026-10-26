--[[
	XLibrary - Roblox UI Library (Luau)
	ดีไซน์: dark navy + indigo accent, sidebar ไอคอนซ้าย, section แบบ panel 2 คอลัมน์

	Elements:
		Section:AddToggle({Text, Default, Keybind, Color, Callback, ColorCallback})
		Section:AddSlider({Text, Min, Max, Default, Increment, Suffix, Callback})
		Section:AddDropdown({Text, Options, Default, Multi, Callback})
		Section:AddTextbox({Text, Placeholder, Default, Callback})
		Section:AddButtons({ {Text, Callback}, ... })  /  Section:AddButton(text, callback)
		Section:AddKeybind({Text, Default, Callback})
		Section:AddLabel(text)

	หน่วยทั้งหมดออกแบบที่ขนาดครึ่งหนึ่งของภาพ แล้วขยายด้วย UIScale (Scale)
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local FONT = Enum.Font.GothamMedium
local FONT_BOLD = Enum.Font.GothamBold

local Theme = {
	Window = Color3.fromRGB(24, 24, 33),
	WindowStroke = Color3.fromRGB(34, 34, 47),
	Sidebar = Color3.fromRGB(19, 19, 27),
	NavActive = Color3.fromRGB(42, 46, 92),
	Panel = Color3.fromRGB(27, 27, 38),
	PanelStroke = Color3.fromRGB(42, 42, 58),
	Input = Color3.fromRGB(22, 22, 31),
	InputStroke = Color3.fromRGB(44, 44, 60),
	Button = Color3.fromRGB(30, 30, 42),
	ButtonHover = Color3.fromRGB(39, 39, 55),
	ButtonPress = Color3.fromRGB(48, 48, 70),
	Accent = Color3.fromRGB(108, 111, 230),
	Text = Color3.fromRGB(235, 235, 244),
	Muted = Color3.fromRGB(104, 104, 122),
	KeyText = Color3.fromRGB(150, 150, 168),
	CheckOff = Color3.fromRGB(30, 30, 42),
	CheckStroke = Color3.fromRGB(48, 48, 66),
	Track = Color3.fromRGB(44, 44, 58),
	Knob = Color3.fromRGB(214, 214, 226),
	Icon = Color3.fromRGB(150, 150, 172),
	IconActive = Color3.fromRGB(190, 194, 240),
	ItemHover = Color3.fromRGB(38, 38, 54),
}

local Library = { Theme = Theme }

----------------------------------------------------------------------
-- helpers
----------------------------------------------------------------------

local function create(class, props, children)
	local inst = Instance.new(class)
	local parent
	for k, v in pairs(props or {}) do
		if k == "Parent" then
			parent = v
		else
			inst[k] = v
		end
	end
	for _, child in ipairs(children or {}) do
		child.Parent = inst
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

local function tween(inst, props, duration)
	TweenService:Create(inst, TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function corner(radius)
	return create("UICorner", { CornerRadius = UDim.new(0, radius) })
end

local function stroke(color, thickness)
	return create("UIStroke", {
		Color = color,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function label(props)
	props.BackgroundTransparency = 1
	props.Font = props.Font or FONT
	props.TextSize = props.TextSize or 11
	props.TextColor3 = props.TextColor3 or Theme.Text
	props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
	return create("TextLabel", props)
end

local function keyToText(key)
	if typeof(key) ~= "EnumItem" then
		return "None"
	end
	if key == Enum.UserInputType.MouseButton1 then
		return "MB1"
	elseif key == Enum.UserInputType.MouseButton2 then
		return "MB2"
	elseif key == Enum.UserInputType.MouseButton3 then
		return "MB3"
	end
	return key.Name
end

local function isPress(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

-- ไอคอน: "dots" วาดเอง, "rbxassetid://..." เป็นรูป, อย่างอื่นเป็นข้อความ
local function makeIcon(parent, icon)
	if icon == "dots" then
		local holder = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(15, 3),
			BackgroundTransparency = 1,
			Parent = parent,
		})
		local dots = {}
		for i = 0, 2 do
			dots[#dots + 1] = create("Frame", {
				Position = UDim2.fromOffset(i * 6, 0),
				Size = UDim2.fromOffset(3, 3),
				BackgroundColor3 = Theme.Icon,
				BorderSizePixel = 0,
				Parent = holder,
			}, { corner(2) })
		end
		return function(color)
			for _, d in ipairs(dots) do
				d.BackgroundColor3 = color
			end
		end
	elseif type(icon) == "string" and icon:find("^rbxasset") then
		local img = create("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(20, 20),
			BackgroundTransparency = 1,
			Image = icon,
			ImageColor3 = Theme.Icon,
			Parent = parent,
		})
		return function(color)
			img.ImageColor3 = color
		end
	else
		local text = label({
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			Text = tostring(icon or "?"),
			Font = FONT_BOLD,
			TextSize = 15,
			TextColor3 = Theme.Icon,
			TextXAlignment = Enum.TextXAlignment.Center,
			Parent = parent,
		})
		return function(color)
			text.TextColor3 = color
		end
	end
end

----------------------------------------------------------------------
-- Section
----------------------------------------------------------------------

local Section = {}
Section.__index = Section

function Section:_item(class, props)
	self._order += 1
	props.LayoutOrder = self._order
	props.Parent = self.Container
	return create(class, props)
end

function Section:AddLabel(text)
	local l = self:_item("TextLabel", {
		Size = UDim2.new(1, 0, 0, 14),
		BackgroundTransparency = 1,
		Font = FONT,
		TextSize = 11,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = text or "",
	})
	return {
		Set = function(_, t)
			l.Text = t
		end,
	}
end

function Section:AddToggle(opts)
	opts = opts or {}
	local window = self.Window
	local toggle = { Value = opts.Default == true, Key = opts.Keybind, Color = opts.Color }

	local row = self:_item("Frame", { Name = "Toggle", Size = UDim2.new(1, 0, 0, 15), BackgroundTransparency = 1 })

	local box = create("Frame", {
		Size = UDim2.fromOffset(15, 15),
		BackgroundColor3 = Theme.CheckOff,
		BorderSizePixel = 0,
		Parent = row,
	}, { corner(3), stroke(Theme.CheckStroke) })

	-- เครื่องหมายถูก (วาดด้วยเฟรมหมุน)
	local white = Color3.new(1, 1, 1)
	local shortLeg = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(5, 9),
		Size = UDim2.fromOffset(2, 4),
		Rotation = -45,
		BackgroundColor3 = white,
		BorderSizePixel = 0,
		Visible = false,
		Parent = box,
	})
	local longLeg = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(8.75, 7),
		Size = UDim2.fromOffset(2, 8),
		Rotation = 45,
		BackgroundColor3 = white,
		BorderSizePixel = 0,
		Visible = false,
		Parent = box,
	})

	local text = label({
		Text = opts.Text or "Toggle",
		Position = UDim2.fromOffset(22, 0),
		Size = UDim2.new(1, -62, 1, 0),
		TextColor3 = Theme.Muted,
		Parent = row,
	})

	local hit = create("TextButton", {
		Size = UDim2.new(1, -44, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = row,
	})

	local function render(animate)
		local d = animate and 0.12 or 0
		tween(box, { BackgroundColor3 = toggle.Value and Theme.Accent or Theme.CheckOff }, d)
		tween(text, { TextColor3 = toggle.Value and Theme.Text or Theme.Muted }, d)
		shortLeg.Visible = toggle.Value
		longLeg.Visible = toggle.Value
	end

	function toggle:Set(value, silent)
		self.Value = value == true
		render(true)
		if not silent and opts.Callback then
			task.spawn(opts.Callback, self.Value)
		end
	end

	function toggle:Get()
		return self.Value
	end

	hit.MouseButton1Click:Connect(function()
		toggle:Set(not toggle.Value)
	end)

	-- keybind ด้านขวา
	if opts.Keybind ~= nil then
		local keyBtn = create("TextButton", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.fromOffset(40, 15),
			BackgroundTransparency = 1,
			Text = keyToText(toggle.Key),
			Font = FONT,
			TextSize = 11,
			TextColor3 = Theme.KeyText,
			TextXAlignment = Enum.TextXAlignment.Right,
			AutoButtonColor = false,
			Parent = row,
		})
		keyBtn.MouseButton1Click:Connect(function()
			keyBtn.Text = "..."
			window:_listen(function(k)
				toggle.Key = k
				keyBtn.Text = keyToText(k)
			end)
		end)
		window:_bind(function()
			return toggle.Key
		end, function()
			toggle:Set(not toggle.Value)
		end)
	elseif opts.Color then
		-- สี่เหลี่ยมเลือกสีด้านขวา
		local swatch = create("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.fromOffset(19, 10),
			BackgroundColor3 = opts.Color,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			Parent = row,
		}, { corner(3) })
		function toggle:SetColor(color)
			self.Color = color
			swatch.BackgroundColor3 = color
		end
		swatch.MouseButton1Click:Connect(function()
			if opts.ColorCallback then
				task.spawn(opts.ColorCallback, toggle.Color, swatch)
			end
		end)
	end

	render(false)
	return toggle
end

function Section:AddSlider(opts)
	opts = opts or {}
	local window = self.Window
	local min, max = opts.Min or 0, opts.Max or 100
	local inc = opts.Increment or 1
	local suffix = opts.Suffix or ""
	local decimals = 0
	local frac = tostring(inc):match("%.(%d+)")
	if frac then
		decimals = #frac
	end
	local slider = { Value = math.clamp(opts.Default or min, min, max) }

	local block = self:_item("Frame", { Name = "Slider", Size = UDim2.new(1, 0, 0, 29), BackgroundTransparency = 1 })
	label({ Text = opts.Text or "Slider", Size = UDim2.new(0.7, 0, 0, 14), Parent = block })
	local valueLabel = label({
		Size = UDim2.new(0.3, 0, 0, 14),
		Position = UDim2.fromScale(0.7, 0),
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = block,
	})

	local area = create("TextButton", {
		Position = UDim2.fromOffset(0, 16),
		Size = UDim2.new(1, 0, 0, 11),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = block,
	})
	local track = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.new(1, 0, 0, 4),
		BackgroundColor3 = Theme.Track,
		BorderSizePixel = 0,
		Parent = area,
	}, { corner(2) })
	local fill = create("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Parent = track,
	}, { corner(2) })
	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(10, 10),
		BackgroundColor3 = Theme.Knob,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = track,
	}, { corner(5) })

	local function render()
		local f = (slider.Value - min) / (max - min)
		fill.Size = UDim2.fromScale(f, 1)
		knob.Position = UDim2.new(f, 0, 0.5, 0)
		valueLabel.Text = string.format("%." .. decimals .. "f", slider.Value) .. suffix
	end

	function slider:Set(value, silent)
		value = math.clamp(value, min, max)
		value = math.floor(value / inc + 0.5) * inc
		value = tonumber(string.format("%." .. decimals .. "f", value)) or value
		self.Value = math.clamp(value, min, max)
		render()
		if not silent and opts.Callback then
			task.spawn(opts.Callback, self.Value)
		end
	end

	function slider:Get()
		return self.Value
	end

	local dragging = false
	local function fromX(x)
		local f = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		slider:Set(min + f * (max - min))
	end

	area.InputBegan:Connect(function(input)
		if isPress(input) then
			dragging = true
			fromX(input.Position.X)
		end
	end)
	window:_connect(UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			fromX(input.Position.X)
		end
	end)
	window:_connect(UserInputService.InputEnded, function(input)
		if isPress(input) then
			dragging = false
		end
	end)

	render()
	return slider
end

local function makeGridIcon(parent)
	local holder = create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(11, 10),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	create("Frame", { Size = UDim2.fromOffset(11, 4), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = holder }, { corner(1) })
	create("Frame", { Position = UDim2.fromOffset(0, 6), Size = UDim2.fromOffset(5, 4), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = holder }, { corner(1) })
	create("Frame", { Position = UDim2.fromOffset(6, 6), Size = UDim2.fromOffset(5, 4), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = holder }, { corner(1) })
end

function Section:AddDropdown(opts)
	opts = opts or {}
	local window = self.Window
	local options = opts.Options or {}
	local multi = opts.Multi == true
	local dd = { Selected = {} }

	local def = opts.Default
	if type(def) == "table" then
		for _, v in ipairs(def) do
			dd.Selected[v] = true
		end
	elseif def ~= nil then
		dd.Selected[def] = true
	elseif not multi and options[1] then
		dd.Selected[options[1]] = true
	end

	local function values()
		local out = {}
		for _, o in ipairs(options) do
			if dd.Selected[o] then
				out[#out + 1] = o
			end
		end
		return out
	end

	local block = self:_item("Frame", { Name = "Dropdown", Size = UDim2.new(1, 0, 0, 41), BackgroundTransparency = 1 })
	label({ Text = opts.Text or "Dropdown", Size = UDim2.new(1, 0, 0, 14), Parent = block })

	local box = create("TextButton", {
		Position = UDim2.fromOffset(0, 15),
		Size = UDim2.new(1, 0, 0, 23),
		BackgroundColor3 = Theme.Input,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Parent = block,
	}, { corner(4), stroke(Theme.InputStroke) })
	local display = label({
		Position = UDim2.fromOffset(8, 0),
		Size = UDim2.new(1, -30, 1, 0),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = box,
	})
	makeGridIcon(box)

	local function renderText()
		local v = values()
		display.Text = #v > 0 and table.concat(v, ", ") or "None"
	end

	function dd:Get()
		local v = values()
		if multi then
			return v
		end
		return v[1]
	end

	function dd:Set(value, silent)
		self.Selected = {}
		if type(value) == "table" then
			for _, v in ipairs(value) do
				self.Selected[v] = true
			end
		elseif value ~= nil then
			self.Selected[value] = true
		end
		renderText()
		if not silent and opts.Callback then
			task.spawn(opts.Callback, self:Get())
		end
	end

	box.MouseButton1Click:Connect(function()
		if window._closeDropdown then
			window._closeDropdown()
		end
		local scale = window.Scale.Scale
		local main = window.Main
		local pos = (box.AbsolutePosition - main.AbsolutePosition) / scale
		local width = box.AbsoluteSize.X / scale
		local height = #options * 22 + 6
		local y = pos.Y + 26
		if y + height > main.Size.Y.Offset then
			y = pos.Y - height - 3
		end

		local blocker = create("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 59,
			Parent = main,
		})
		local list = create("Frame", {
			Position = UDim2.fromOffset(pos.X, y),
			Size = UDim2.fromOffset(width, height),
			BackgroundColor3 = Theme.Panel,
			BorderSizePixel = 0,
			ZIndex = 60,
			Parent = main,
		}, { corner(5), stroke(Theme.PanelStroke) })

		local function close()
			blocker:Destroy()
			list:Destroy()
			window._closeDropdown = nil
		end
		window._closeDropdown = close
		blocker.MouseButton1Click:Connect(close)

		local labels = {}
		local function refresh()
			for name, l in pairs(labels) do
				l.TextColor3 = dd.Selected[name] and Theme.Accent or Theme.Text
			end
		end

		for i, name in ipairs(options) do
			local item = create("TextButton", {
				Position = UDim2.fromOffset(3, 3 + (i - 1) * 22),
				Size = UDim2.new(1, -6, 0, 22),
				BackgroundColor3 = Theme.ItemHover,
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				ZIndex = 61,
				Parent = list,
			}, { corner(4) })
			labels[name] = label({
				Text = name,
				Position = UDim2.fromOffset(6, 0),
				Size = UDim2.new(1, -12, 1, 0),
				ZIndex = 62,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = item,
			})
			item.MouseEnter:Connect(function()
				tween(item, { BackgroundTransparency = 0 }, 0.08)
			end)
			item.MouseLeave:Connect(function()
				tween(item, { BackgroundTransparency = 1 }, 0.08)
			end)
			item.MouseButton1Click:Connect(function()
				if multi then
					dd.Selected[name] = not dd.Selected[name] or nil
					refresh()
					renderText()
					if opts.Callback then
						task.spawn(opts.Callback, dd:Get())
					end
				else
					dd.Selected = { [name] = true }
					renderText()
					if opts.Callback then
						task.spawn(opts.Callback, name)
					end
					close()
				end
			end)
		end
		refresh()
	end)

	renderText()
	return dd
end

function Section:AddTextbox(opts)
	opts = opts or {}
	local tb = { Value = opts.Default or "" }
	local block = self:_item("Frame", { Name = "Textbox", Size = UDim2.new(1, 0, 0, 41), BackgroundTransparency = 1 })
	label({ Text = opts.Text or "Textbox", Size = UDim2.new(1, 0, 0, 14), Parent = block })
	local box = create("Frame", {
		Position = UDim2.fromOffset(0, 15),
		Size = UDim2.new(1, 0, 0, 23),
		BackgroundColor3 = Theme.Input,
		BorderSizePixel = 0,
		Parent = block,
	}, { corner(4), stroke(Theme.InputStroke) })
	local input = create("TextBox", {
		Position = UDim2.fromOffset(8, 0),
		Size = UDim2.new(1, -16, 1, 0),
		BackgroundTransparency = 1,
		Text = tb.Value,
		PlaceholderText = opts.Placeholder or "",
		PlaceholderColor3 = Theme.Muted,
		TextColor3 = Theme.Text,
		Font = FONT,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		Parent = box,
	})
	input.FocusLost:Connect(function()
		tb.Value = input.Text
		if opts.Callback then
			task.spawn(opts.Callback, tb.Value)
		end
	end)
	function tb:Get()
		return self.Value
	end
	function tb:Set(text)
		self.Value = text
		input.Text = text
	end
	return tb
end

function Section:AddButtons(list)
	local row = self:_item("Frame", { Name = "Buttons", Size = UDim2.new(1, 0, 0, 23), BackgroundTransparency = 1 })
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 5),
		Parent = row,
	})
	local n = #list
	local buttons = {}
	for i, def in ipairs(list) do
		local b = create("TextButton", {
			LayoutOrder = i,
			Size = UDim2.new(1 / n, -(5 * (n - 1)) / n, 1, 0),
			BackgroundColor3 = Theme.Button,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Text = def.Text or "Button",
			Font = FONT,
			TextSize = 11,
			TextColor3 = Theme.Text,
			Parent = row,
		}, { corner(4), stroke(Theme.InputStroke) })
		b.MouseEnter:Connect(function()
			tween(b, { BackgroundColor3 = Theme.ButtonHover }, 0.1)
		end)
		b.MouseLeave:Connect(function()
			tween(b, { BackgroundColor3 = Theme.Button }, 0.1)
		end)
		b.MouseButton1Down:Connect(function()
			tween(b, { BackgroundColor3 = Theme.ButtonPress }, 0.05)
		end)
		b.MouseButton1Up:Connect(function()
			tween(b, { BackgroundColor3 = Theme.ButtonHover }, 0.05)
		end)
		b.MouseButton1Click:Connect(function()
			if def.Callback then
				task.spawn(def.Callback)
			end
		end)
		buttons[i] = b
	end
	return buttons
end

function Section:AddButton(text, callback)
	return self:AddButtons({ { Text = text, Callback = callback } })[1]
end

function Section:AddKeybind(opts)
	opts = opts or {}
	local window = self.Window
	local kb = { Key = opts.Default }
	local row = self:_item("Frame", { Name = "Keybind", Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1 })
	label({ Text = opts.Text or "Keybind", Size = UDim2.new(0.6, 0, 1, 0), Parent = row })
	local keyBtn = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0.4, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = keyToText(kb.Key),
		Font = FONT,
		TextSize = 11,
		TextColor3 = Theme.KeyText,
		TextXAlignment = Enum.TextXAlignment.Right,
		AutoButtonColor = false,
		Parent = row,
	})
	keyBtn.MouseButton1Click:Connect(function()
		keyBtn.Text = "..."
		window:_listen(function(k)
			kb.Key = k
			keyBtn.Text = keyToText(k)
			if opts.Changed then
				task.spawn(opts.Changed, k)
			end
		end)
	end)
	window:_bind(function()
		return kb.Key
	end, function()
		if opts.Callback then
			task.spawn(opts.Callback)
		end
	end)
	function kb:Get()
		return self.Key
	end
	return kb
end

----------------------------------------------------------------------
-- Tab
----------------------------------------------------------------------

local Tab = {}
Tab.__index = Tab

function Tab:AddSection(opts)
	opts = opts or {}
	local column = (opts.Side == "Right") and self._right or self._left
	local frame = create("Frame", {
		Name = opts.Title or "Section",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		Parent = column,
	}, { corner(6), stroke(Theme.PanelStroke) })
	create("UIPadding", {
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		PaddingTop = UDim.new(0, 7),
		PaddingBottom = UDim.new(0, 8),
		Parent = frame,
	})
	create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 7),
		Parent = frame,
	})
	label({
		Text = opts.Title or "Section",
		Font = FONT_BOLD,
		Size = UDim2.new(1, 0, 0, 14),
		LayoutOrder = 0,
		Parent = frame,
	})
	return setmetatable({ Container = frame, Window = self.Window, _order = 0 }, Section)
end

----------------------------------------------------------------------
-- Window
----------------------------------------------------------------------

local Window = {}
Window.__index = Window

function Window:_connect(signal, fn)
	local c = signal:Connect(fn)
	table.insert(self._conns, c)
	return c
end

function Window:_bind(getKey, fire)
	table.insert(self._binds, { getKey = getKey, fire = fire })
end

function Window:_listen(callback)
	self._listening = true
	local conn
	conn = UserInputService.InputBegan:Connect(function(input)
		local key
		if input.UserInputType == Enum.UserInputType.Keyboard then
			key = input.KeyCode
			if key == Enum.KeyCode.Escape then
				key = nil
			end
		elseif
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.MouseButton2
			or input.UserInputType == Enum.UserInputType.MouseButton3
		then
			key = input.UserInputType
		else
			return
		end
		conn:Disconnect()
		task.defer(function()
			self._listening = false
		end)
		callback(key)
	end)
end

function Window:SelectTab(tab)
	for _, t in ipairs(self.Tabs) do
		local active = t == tab
		t.Page.Visible = active
		tween(t.Button, { BackgroundTransparency = active and 0 or 1 }, 0.15)
		t._setIcon(active and Theme.IconActive or Theme.Icon)
	end
end

function Window:AddTab(opts)
	opts = opts or {}
	local tab = setmetatable({ Window = self }, Tab)
	local index = #self.Tabs + 1

	tab.Button = create("TextButton", {
		Name = "Tab" .. index,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 76 + 57 * (index - 1)),
		Size = UDim2.fromOffset(43, 43),
		BackgroundColor3 = Theme.NavActive,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Parent = self.Sidebar,
	}, { corner(7) })
	tab._setIcon = makeIcon(tab.Button, opts.Icon or opts.Name)

	tab.Page = create("Frame", {
		Name = "Page" .. index,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = self.Content,
	})
	local function column(x, width)
		local col = create("Frame", {
			Position = UDim2.fromOffset(x, 5),
			Size = UDim2.new(0, width, 1, -10),
			BackgroundTransparency = 1,
			Parent = tab.Page,
		})
		create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = col })
		return col
	end
	tab._left = column(5, 268)
	tab._right = column(280, 267)

	tab.Button.MouseButton1Click:Connect(function()
		self:SelectTab(tab)
	end)
	tab.Button.MouseEnter:Connect(function()
		if tab.Page.Visible == false then
			tab._setIcon(Theme.IconActive)
		end
	end)
	tab.Button.MouseLeave:Connect(function()
		if tab.Page.Visible == false then
			tab._setIcon(Theme.Icon)
		end
	end)

	self.Tabs[index] = tab
	if index == 1 then
		self:SelectTab(tab)
	end
	return tab
end

function Window:SetVisible(visible)
	self.Gui.Enabled = visible
end

function Window:Toggle()
	self.Gui.Enabled = not self.Gui.Enabled
end

function Window:Destroy()
	for _, c in ipairs(self._conns) do
		c:Disconnect()
	end
	self.Gui:Destroy()
end

function Library:CreateWindow(opts)
	opts = opts or {}
	local size = opts.Size or Vector2.new(626, 421)

	local window = setmetatable({
		Tabs = {},
		ToggleKey = opts.ToggleKey or Enum.KeyCode.RightShift,
		_conns = {},
		_binds = {},
		_listening = false,
	}, Window)

	local gui = create("ScreenGui", {
		Name = opts.Name or "XLibrary",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
		DisplayOrder = 100,
	})
	gui.Parent = opts.Parent or Players.LocalPlayer:WaitForChild("PlayerGui")
	window.Gui = gui

	local main = create("Frame", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(size.X, size.Y),
		BackgroundColor3 = Theme.Window,
		BorderSizePixel = 0,
		Parent = gui,
	}, { corner(8), stroke(Theme.WindowStroke) })
	window.Main = main
	window.Scale = create("UIScale", { Scale = opts.Scale or 1.2, Parent = main })

	-- sidebar
	local sidebar = create("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, 73, 1, 0),
		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0,
		Parent = main,
	}, { corner(8) })
	create("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0, 10, 1, 0),
		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0,
		Parent = sidebar,
	})
	window.Sidebar = sidebar

	-- โลโก้
	if opts.Logo and tostring(opts.Logo):find("^rbxasset") then
		create("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0, 36),
			Size = UDim2.fromOffset(40, 26),
			BackgroundTransparency = 1,
			Image = opts.Logo,
			Parent = sidebar,
		})
	else
		label({
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0, 36),
			Size = UDim2.fromOffset(40, 26),
			Text = opts.Title or "X",
			Font = Enum.Font.GothamBlack,
			TextSize = 22,
			TextColor3 = Color3.fromRGB(225, 225, 240),
			TextXAlignment = Enum.TextXAlignment.Center,
			Parent = sidebar,
		})
	end

	window.Content = create("Frame", {
		Name = "Content",
		Position = UDim2.fromOffset(73, 0),
		Size = UDim2.new(1, -73, 1, 0),
		BackgroundTransparency = 1,
		Parent = main,
	})

	-- ลากหน้าต่าง
	local dragging, dragStart, startPos = false, nil, nil
	local function beginDrag(input)
		if isPress(input) then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
		end
	end
	sidebar.InputBegan:Connect(beginDrag)
	main.InputBegan:Connect(function(input)
		if window.Content.Visible then
			-- ลากจากพื้นที่ว่างของ main ได้เช่นกัน
			beginDrag(input)
		end
	end)
	window:_connect(UserInputService.InputChanged, function(input)
		if
			dragging
			and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)
		then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
	window:_connect(UserInputService.InputEnded, function(input)
		if isPress(input) then
			dragging = false
		end
	end)

	-- keybind ทั้งหมด + ปุ่มเปิด/ปิดเมนู
	window:_connect(UserInputService.InputBegan, function(input, processed)
		if processed or window._listening then
			return
		end
		if input.KeyCode == window.ToggleKey then
			window:Toggle()
			return
		end
		for _, b in ipairs(window._binds) do
			local key = b.getKey()
			if key ~= nil and (input.KeyCode == key or input.UserInputType == key) then
				b.fire()
			end
		end
	end)

	return window
end

return Library
