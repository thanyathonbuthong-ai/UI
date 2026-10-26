--[[
	Astral Hub UI Library  (Roblox / Luau)

	สองธีมตามภาพ:
	  Theme = "Terminal"  -> sidebar ซ้าย, ฟอนต์ mono, checkbox แบบ [ ]
	  Theme = "Glass"     -> dock ไอคอนด้านล่าง, สวิตช์ทรงเม็ดยา, กระจกฟ้า

	วิธีใช้ (ModuleScript):
		local Library = require(path.to.AstralHub)
		local Window  = Library:CreateWindow({ Title = "Astral Hub", Theme = "Terminal" })
		local Tab     = Window:AddTab({ Name = "combat", Icon = "swords" })
		local Section = Tab:AddSection({ Name = "Detection", Icon = "shield" })
		Section:AddToggle({ Name = "Auto Dodge", Description = "...", Callback = function(v) end })

	ไอคอนทั้งหมดวาดด้วยโค้ด (ไม่ต้องใช้ asset id) หรือส่ง "rbxassetid://123" / ตัวอักษร เช่น "M" แทนได้
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local Library = {}
Library.__index = Library
Library.Version = "1.0.0"
Library.Windows = {}

local Window = {}
Window.__index = Window
local Tab = {}
Tab.__index = Tab
local Section = {}
Section.__index = Section

local WHITE = Color3.new(1, 1, 1)

--==================================================================--
--  THEMES
--==================================================================--
local Themes = {
	Terminal = {
		Layout = "Sidebar",
		FontEnum = Enum.Font.RobotoMono,
		TitleWeight = Enum.FontWeight.Bold,
		BodyWeight = Enum.FontWeight.Regular,

		Window = Color3.fromRGB(10, 11, 16), WindowT = 0,
		WindowStroke = Color3.fromRGB(46, 47, 57), WindowStrokeT = 0,
		Divider = Color3.fromRGB(31, 32, 40), DividerT = 0,

		HeaderButton = Color3.fromRGB(21, 22, 28), HeaderButtonT = 0,
		HeaderButtonHover = Color3.fromRGB(33, 34, 43),
		HeaderButtonStroke = Color3.fromRGB(46, 47, 57), HeaderButtonStrokeT = 0,

		SideItem = Color3.fromRGB(16, 17, 23),
		SideItemActive = Color3.fromRGB(27, 28, 36),

		Card = WHITE, CardT = 0,
		CardGradient = { Color3.fromRGB(40, 35, 31), Color3.fromRGB(19, 19, 24) },
		CardStroke = Color3.fromRGB(38, 37, 43), CardStrokeT = 0,
		HeaderDivider = Color3.fromRGB(46, 44, 47),

		Row = Color3.fromRGB(16, 17, 23), RowT = 0,
		RowHover = Color3.fromRGB(23, 24, 32),
		RowStroke = Color3.fromRGB(35, 36, 44), RowStrokeT = 0,

		Button = Color3.fromRGB(14, 15, 21),
		ButtonHover = Color3.fromRGB(27, 28, 37),
		ButtonStroke = Color3.fromRGB(40, 41, 51), ButtonStrokeT = 0,

		Input = Color3.fromRGB(10, 11, 16),
		InputStroke = Color3.fromRGB(44, 45, 55),
		Toast = Color3.fromRGB(18, 19, 26), ToastT = 0,
		Track = Color3.fromRGB(36, 37, 46),

		Text = Color3.fromRGB(242, 242, 247),
		SubText = Color3.fromRGB(137, 138, 151),
		Accent = Color3.fromRGB(255, 255, 255),

		Switch = false,
		Corner = { Window = 12, Card = 8, Row = 6, Button = 6, Header = 7 },
		Size = { Window = 12, Item = 9, Desc = 8, Tab = 9, Header = 9, Button = 9 },
		PadLeft = 4,
		ContentBottom = 0,
	},

	Glass = {
		Layout = "Dock",
		FontEnum = Enum.Font.Gotham,
		TitleWeight = Enum.FontWeight.SemiBold,
		BodyWeight = Enum.FontWeight.Medium,

		Window = WHITE, WindowT = 0.06,
		WindowGradient = { Color3.fromRGB(31, 38, 54), Color3.fromRGB(17, 21, 31) },
		WindowStroke = Color3.fromRGB(78, 90, 118), WindowStrokeT = 0.45,
		Divider = Color3.fromRGB(78, 90, 118), DividerT = 0.7,

		HeaderButton = Color3.fromRGB(40, 47, 65), HeaderButtonT = 0.2,
		HeaderButtonHover = Color3.fromRGB(54, 63, 86),
		HeaderButtonStroke = Color3.fromRGB(84, 95, 122), HeaderButtonStrokeT = 0.45,

		Card = Color3.fromRGB(33, 39, 54), CardT = 0.18,
		CardStroke = Color3.fromRGB(70, 80, 106), CardStrokeT = 0.55,

		Row = Color3.fromRGB(46, 54, 74), RowT = 0.8,
		RowHover = Color3.fromRGB(58, 67, 92),

		Button = Color3.fromRGB(48, 56, 78),
		ButtonHover = Color3.fromRGB(62, 72, 99),
		ButtonStroke = Color3.fromRGB(78, 89, 117), ButtonStrokeT = 0.4,

		Input = Color3.fromRGB(24, 29, 41),
		InputStroke = Color3.fromRGB(70, 80, 106),
		Toast = Color3.fromRGB(30, 36, 51), ToastT = 0.05,
		Track = Color3.fromRGB(47, 55, 76),

		Dock = Color3.fromRGB(26, 31, 44), DockT = 0.12,
		DockStroke = Color3.fromRGB(70, 80, 106), DockStrokeT = 0.4,
		DockButtonA = Color3.fromRGB(116, 156, 228),
		DockButtonB = Color3.fromRGB(152, 190, 244),

		Text = Color3.fromRGB(236, 241, 250),
		SubText = Color3.fromRGB(148, 157, 176),
		Accent = Color3.fromRGB(128, 170, 238),

		Switch = true,
		SwitchOff = Color3.fromRGB(46, 53, 72),
		Corner = { Window = 12, Card = 8, Row = 7, Button = 8, Header = 8 },
		Size = { Window = 12, Item = 9, Desc = 8, Tab = 9, Header = 9, Button = 9 },
		PadLeft = 10,
		ContentBottom = 70,
	},
}

--==================================================================--
--  HELPERS
--==================================================================--
local function create(className, props, children)
	local inst = Instance.new(className)
	local parent
	for key, value in pairs(props or {}) do
		if key == "Parent" then
			parent = value
		else
			inst[key] = value
		end
	end
	for _, child in ipairs(children or {}) do
		child.Parent = inst
	end
	inst.Parent = parent
	return inst
end

local function corner(parent, radius)
	return create("UICorner", { CornerRadius = UDim.new(0, radius), Parent = parent })
end

local function stroke(parent, color, thickness, transparency)
	return create("UIStroke", {
		Color = color,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent,
	})
end

local function pad(parent, l, t, r, b)
	return create("UIPadding", {
		PaddingLeft = UDim.new(0, l or 0),
		PaddingTop = UDim.new(0, t or 0),
		PaddingRight = UDim.new(0, r or 0),
		PaddingBottom = UDim.new(0, b or 0),
		Parent = parent,
	})
end

local function list(parent, gap, props)
	local layout = create("UIListLayout", {
		Padding = UDim.new(0, gap or 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	for key, value in pairs(props or {}) do
		layout[key] = value
	end
	layout.Parent = parent
	return layout
end

local function gradient(parent, a, b, rotation)
	return create("UIGradient", {
		Color = ColorSequence.new(a, b),
		Rotation = rotation or 90,
		Parent = parent,
	})
end

local function tween(inst, time, props, style)
	local t = TweenService:Create(
		inst,
		TweenInfo.new(time, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		props
	)
	t:Play()
	return t
end

local function safe(callback, ...)
	if type(callback) ~= "function" then
		return
	end
	local ok, err = pcall(callback, ...)
	if not ok then
		warn("[AstralHub] callback error: " .. tostring(err))
	end
end

local function fontOf(T, weight)
	local base = Font.fromEnum(T.FontEnum)
	return Font.new(base.Family, weight or T.BodyWeight, Enum.FontStyle.Normal)
end

local function newText(T, class, props, weight)
	local base = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		FontFace = fontOf(T, weight),
		TextColor3 = T.Text,
		TextSize = T.Size.Item,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
	}
	for key, value in pairs(props) do
		base[key] = value
	end
	if class == "TextButton" then
		base.AutoButtonColor = false
		base.Text = base.Text or ""
	end
	return create(class, base)
end

local function isPress(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

local function isMove(input)
	return input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
end

local function hoverColor(btn, normal, hover, prop)
	prop = prop or "BackgroundColor3"
	btn.MouseEnter:Connect(function()
		tween(btn, 0.12, { [prop] = hover })
	end)
	btn.MouseLeave:Connect(function()
		tween(btn, 0.12, { [prop] = normal })
	end)
end

--==================================================================--
--  ICONS (วาดด้วย Frame ล้วน ไม่ต้องพึ่ง asset)
--  c = วงกลมเส้น | d = จุดทึบ | r = สี่เหลี่ยมมุมมน | l = เส้น   (กริด 24x24)
--==================================================================--
local ICONS = {
	search = { { "c", 10.5, 10.5, 6.5 }, { "l", 15.5, 15.5, 20.5, 20.5 } },
	bell = { { "r", 6, 4, 12, 12, 6 }, { "l", 4, 17, 20, 17 }, { "d", 12, 20.5, 1.5 } },
	save = { { "r", 3.5, 3.5, 17, 17, 3 }, { "r", 7.5, 3.5, 8, 5, 1 }, { "r", 6.5, 13, 11, 7.5, 1 } },
	terminal = { { "l", 5, 8, 10, 12 }, { "l", 10, 12, 5, 16 }, { "l", 12.5, 17, 19, 17 } },
	chevron = { { "l", 6, 9.5, 12, 15.5 }, { "l", 12, 15.5, 18, 9.5 } },
	check = { { "l", 5, 12.5, 10, 17 }, { "l", 10, 17, 19, 7 } },
	close = { { "l", 6, 6, 18, 18 }, { "l", 18, 6, 6, 18 } },
	shield = {
		{ "l", 5, 6, 12, 3 }, { "l", 19, 6, 12, 3 },
		{ "l", 5, 6, 5, 14 }, { "l", 19, 6, 19, 14 },
		{ "l", 5, 14, 12, 21 }, { "l", 19, 14, 12, 21 },
	},
	gauge = { { "c", 12, 12, 9 }, { "l", 12, 12, 16, 8 }, { "d", 12, 12, 1.6 } },
	eye = { { "r", 2.5, 7.5, 19, 9, 4.5 }, { "c", 12, 12, 2.6 } },
	pin = { { "c", 12, 9.5, 6.5 }, { "d", 12, 9.5, 2 }, { "l", 12, 16, 12, 21.5 } },
	user = { { "c", 12, 8, 4 }, { "r", 5, 14.5, 14, 7, 3.5 } },
	cube = {
		{ "r", 4, 4, 16, 16, 3 }, { "l", 4, 8.5, 12, 12.5 },
		{ "l", 20, 8.5, 12, 12.5 }, { "l", 12, 12.5, 12, 20 },
	},
	folder = { { "r", 3, 6.5, 18, 13, 2.5 }, { "r", 3, 4, 8, 4.5, 1.5 } },
	gear = {
		{ "c", 12, 12, 3 }, { "c", 12, 12, 7.5 },
		{ "l", 12, 2.5, 12, 4.5 }, { "l", 12, 19.5, 12, 21.5 },
		{ "l", 2.5, 12, 4.5, 12 }, { "l", 19.5, 12, 21.5, 12 },
	},
	info = { { "c", 12, 12, 9 }, { "l", 12, 11, 12, 16.5 }, { "d", 12, 7.7, 1.1 } },
	swords = {
		{ "l", 5, 19, 19, 5 }, { "l", 5, 5, 19, 19 },
		{ "l", 3.5, 15.5, 8.5, 20.5 }, { "l", 20.5, 15.5, 15.5, 20.5 },
	},
	crosshair = {
		{ "c", 12, 12, 8 }, { "l", 12, 2, 12, 7 }, { "l", 12, 17, 12, 22 },
		{ "l", 2, 12, 7, 12 }, { "l", 17, 12, 22, 12 },
	},
}

local function buildIcon(parent, name, size, color)
	local holder = create("Frame", {
		Name = "Icon",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(size, size),
		Parent = parent,
	})
	local parts = {}
	local k = size / 24
	local th = math.max(1, 1.8 * k)

	for _, s in ipairs(ICONS[name]) do
		local kind = s[1]
		if kind == "c" or kind == "d" then
			local x, y, r = s[2], s[3], s[4]
			local f = create("Frame", {
				BackgroundColor3 = color,
				BackgroundTransparency = kind == "d" and 0 or 1,
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(2 * r * k, 2 * r * k),
				Position = UDim2.fromOffset((x - r) * k, (y - r) * k),
				Parent = holder,
			})
			create("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = f })
			if kind == "c" then
				local st = create("UIStroke", { Color = color, Thickness = th, Parent = f })
				parts[#parts + 1] = { st, "Color" }
			else
				parts[#parts + 1] = { f, "BackgroundColor3" }
			end
		elseif kind == "r" then
			local x, y, w, h, r = s[2], s[3], s[4], s[5], s[6]
			local f = create("Frame", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(w * k, h * k),
				Position = UDim2.fromOffset(x * k, y * k),
				Parent = holder,
			})
			create("UICorner", { CornerRadius = UDim.new(0, r * k), Parent = f })
			local st = create("UIStroke", { Color = color, Thickness = th, Parent = f })
			parts[#parts + 1] = { st, "Color" }
		elseif kind == "l" then
			local x1, y1, x2, y2 = s[2], s[3], s[4], s[5]
			local dx, dy = (x2 - x1) * k, (y2 - y1) * k
			local len = math.sqrt(dx * dx + dy * dy)
			local f = create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = color,
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(len + th * 0.5, th),
				Position = UDim2.fromOffset((x1 + x2) / 2 * k, (y1 + y2) / 2 * k),
				Rotation = math.deg(math.atan2(dy, dx)),
				Parent = holder,
			})
			create("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = f })
			parts[#parts + 1] = { f, "BackgroundColor3" }
		end
	end

	return {
		Frame = holder,
		SetColor = function(c)
			for _, p in ipairs(parts) do
				p[1][p[2]] = c
			end
		end,
	}
end

local function makeIcon(T, parent, icon, size, color)
	if icon == nil then
		return nil
	end
	if type(icon) == "number" then
		icon = "rbxassetid://" .. icon
	end
	if ICONS[icon] then
		return buildIcon(parent, icon, size, color)
	end
	if type(icon) == "string" and icon:find("rbxasset") then
		local img = create("ImageLabel", {
			Name = "Icon",
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(size, size),
			Image = icon,
			ImageColor3 = color,
			Parent = parent,
		})
		return { Frame = img, SetColor = function(c) img.ImageColor3 = c end }
	end
	local lbl = newText(T, "TextLabel", {
		Name = "Icon",
		Size = UDim2.fromOffset(size, size),
		Text = tostring(icon),
		TextSize = math.floor(size * 0.85),
		TextColor3 = color,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = parent,
	}, Enum.FontWeight.Bold)
	return { Frame = lbl, SetColor = function(c) lbl.TextColor3 = c end }
end

local function centerIcon(icon)
	icon.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.Frame.Position = UDim2.fromScale(0.5, 0.5)
end

--==================================================================--
--  WINDOW
--==================================================================--
function Library:CreateWindow(options)
	options = options or {}
	local T = Themes[options.Theme or "Terminal"]
	assert(T, "AstralHub: unknown theme '" .. tostring(options.Theme) .. "' (use Terminal or Glass)")

	local self = setmetatable({}, Window)
	self.Theme = T
	self.Flags = {}
	self.Options = {}
	self.Tabs = {}
	self.Connections = {}
	self.Notifications = {}
	self.Commands = {}
	self.Unread = 0
	self.ToggleKey = options.ToggleKey or Enum.KeyCode.RightShift
	self.OnSave = options.OnSave
	self.ConfigName = options.ConfigName or "AstralHub.json"

	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local size = options.Size or Vector2.new(730, 394)
	local scale = options.Scale or math.clamp(viewport.Y / 520, 0.85, 1.5)
	scale = math.min(scale, viewport.X * 0.94 / size.X, viewport.Y * 0.92 / size.Y)
	self.Scale = scale

	local parent = options.Parent
	if not parent then
		local player = Players.LocalPlayer
		parent = player and player:WaitForChild("PlayerGui")
	end

	local gui = create("ScreenGui", {
		Name = options.Name or "AstralHub",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 1000,
		Parent = parent,
	})
	self.Gui = gui

	local function connect(signal, fn)
		local c = signal:Connect(fn)
		self.Connections[#self.Connections + 1] = c
		return c
	end
	self._connect = connect

	----------------------------------------------------------------
	-- Main frame
	----------------------------------------------------------------
	local main = create("Frame", {
		Name = "Main",
		BackgroundColor3 = T.Window,
		BackgroundTransparency = T.WindowT,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Size = UDim2.fromOffset(size.X, size.Y),
		Position = UDim2.fromOffset(
			math.floor((viewport.X - size.X * scale) / 2),
			math.floor((viewport.Y - size.Y * scale) / 2)
		),
		Parent = gui,
	})
	corner(main, T.Corner.Window)
	stroke(main, T.WindowStroke, 1, T.WindowStrokeT)
	create("UIScale", { Scale = scale, Parent = main })
	if T.WindowGradient then
		gradient(main, T.WindowGradient[1], T.WindowGradient[2], 90)
	end
	self.Main = main

	----------------------------------------------------------------
	-- Title bar
	----------------------------------------------------------------
	local top = create("Frame", {
		Name = "TopBar", BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 34), Parent = main,
	})
	create("Frame", {
		Name = "Divider", BackgroundColor3 = T.Divider, BackgroundTransparency = T.DividerT,
		BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 1), Parent = top,
	})

	-- traffic lights
	local function light(index, color)
		local b = create("TextButton", {
			AutoButtonColor = false, Text = "", BackgroundColor3 = color, BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(11, 11),
			Position = UDim2.fromOffset(19 + 18 * (index - 1), 17), Parent = top,
		})
		create("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = b })
		return b
	end
	local closeBtn = light(1, Color3.fromRGB(255, 95, 87))
	local minBtn = light(2, Color3.fromRGB(254, 188, 46))
	local maxBtn = light(3, Color3.fromRGB(40, 200, 64))

	-- logo
	local logo
	if options.Logo then
		logo = create("ImageLabel", {
			Name = "Logo", BackgroundTransparency = 1, Image = tostring(options.Logo):find("rbx") and options.Logo or ("rbxassetid://" .. options.Logo),
			Position = UDim2.fromOffset(73, 7), Size = UDim2.fromOffset(20, 20), Parent = top,
		})
		corner(logo, 5)
	else
		logo = create("Frame", {
			Name = "Logo", BackgroundColor3 = WHITE, BorderSizePixel = 0,
			Position = UDim2.fromOffset(73, 7), Size = UDim2.fromOffset(20, 20), Parent = top,
		})
		corner(logo, 5)
		gradient(logo, Color3.fromRGB(108, 148, 228), Color3.fromRGB(156, 194, 246), 45)
		local function bar(w, h, rot)
			local f = create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(w, h), Rotation = rot or 0,
				BackgroundColor3 = WHITE, BorderSizePixel = 0, Parent = logo,
			})
			corner(f, 1)
		end
		bar(2, 12, 0)
		bar(12, 2, 0)
		bar(1.5, 8, 45)
		bar(1.5, 8, -45)
	end

	create("TextLabel", {
		Name = "Title", BackgroundTransparency = 1, Text = options.Title or "Astral Hub",
		FontFace = fontOf(T, T.TitleWeight), TextSize = T.Size.Window, TextColor3 = T.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(101, 0), Size = UDim2.new(0.5, -101, 1, 0), Parent = top,
	})

	-- header buttons
	local headerHolder = create("Frame", {
		Name = "Buttons", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -9, 0.5, 0), Size = UDim2.fromOffset(0, 28),
		AutomaticSize = Enum.AutomaticSize.X, Parent = top,
	})
	list(headerHolder, 5, { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center })

	local function headerButton(iconName, order)
		local btn = newText(T, "TextButton", {
			Name = iconName, Size = UDim2.fromOffset(28, 28), LayoutOrder = order,
			BackgroundTransparency = T.HeaderButtonT, BackgroundColor3 = T.HeaderButton, Parent = headerHolder,
		})
		corner(btn, T.Corner.Header)
		stroke(btn, T.HeaderButtonStroke, 1, T.HeaderButtonStrokeT)
		local ic = makeIcon(T, btn, iconName, 14, T.Text)
		centerIcon(ic)
		hoverColor(btn, T.HeaderButton, T.HeaderButtonHover)
		return btn
	end
	local searchBtn = headerButton("search", 1)
	local bellBtn = headerButton("bell", 2)
	local saveBtn = headerButton("save", 3)
	local termBtn = headerButton("terminal", 4)

	self.BellBadge = create("Frame", {
		Name = "Badge", Visible = false, BackgroundColor3 = Color3.fromRGB(255, 95, 87), BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -5, 0, 5), Size = UDim2.fromOffset(6, 6),
		ZIndex = 5, Parent = bellBtn,
	})
	create("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = self.BellBadge })

	----------------------------------------------------------------
	-- Body / content
	----------------------------------------------------------------
	local body = create("Frame", {
		Name = "Body", BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 34), Size = UDim2.new(1, 0, 1, -34), Parent = main,
	})
	self.Body = body

	if T.Layout == "Sidebar" then
		local sidebar = create("Frame", {
			Name = "Sidebar", BackgroundTransparency = 1, Size = UDim2.new(0, 100, 1, 0), Parent = body,
		})
		create("Frame", {
			Name = "Divider", BackgroundColor3 = T.Divider, BackgroundTransparency = T.DividerT, BorderSizePixel = 0,
			AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.new(0, 1, 1, 0),
			Parent = sidebar,
		})
		self.SideList = create("ScrollingFrame", {
			Name = "Tabs", BackgroundTransparency = 1, BorderSizePixel = 0,
			Size = UDim2.new(1, -1, 1, 0), CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 0,
			ScrollingDirection = Enum.ScrollingDirection.Y, Parent = sidebar,
		})
		list(self.SideList, 4)
		pad(self.SideList, 8, 8, 5, 8)

		self.SidePinned = create("Frame", {
			Name = "Pinned", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, -1, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, Parent = sidebar,
		})
		list(self.SidePinned, 4)
		pad(self.SidePinned, 8, 0, 5, 8)
		connect(self.SidePinned:GetPropertyChangedSignal("AbsoluteSize"), function()
			self.SideList.Size = UDim2.new(1, -1, 1, -(self.SidePinned.AbsoluteSize.Y / self.Scale))
		end)

		self.Content = create("Frame", {
			Name = "Content", BackgroundTransparency = 1, ClipsDescendants = true,
			Position = UDim2.fromOffset(101, 0), Size = UDim2.new(1, -101, 1, 0), Parent = body,
		})
	else
		self.Content = create("Frame", {
			Name = "Content", BackgroundTransparency = 1, ClipsDescendants = true,
			Size = UDim2.new(1, 0, 1, -T.ContentBottom), Parent = body,
		})
		self.Dock = create("Frame", {
			Name = "Dock", AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -13),
			Size = UDim2.fromOffset(0, 48), AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = T.Dock, BackgroundTransparency = T.DockT, BorderSizePixel = 0,
			ZIndex = 5, Parent = body,
		})
		corner(self.Dock, 15)
		stroke(self.Dock, T.DockStroke, 1, T.DockStrokeT)
		list(self.Dock, 15, { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center })
		pad(self.Dock, 16, 0, 16, 0)
	end

	----------------------------------------------------------------
	-- Notifications (toast)
	----------------------------------------------------------------
	self.ToastHolder = create("Frame", {
		Name = "Toasts", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -14, 1, -14), Size = UDim2.fromOffset(230, 0),
		AutomaticSize = Enum.AutomaticSize.Y, Parent = gui,
	})
	list(self.ToastHolder, 6, { VerticalAlignment = Enum.VerticalAlignment.Bottom })
	create("UIScale", { Scale = scale, Parent = self.ToastHolder })

	----------------------------------------------------------------
	-- Drag / resize / traffic lights
	----------------------------------------------------------------
	do
		local dragging, dragStart, startPos = false, nil, nil
		top.InputBegan:Connect(function(input)
			if isPress(input) then
				dragging = true
				dragStart = input.Position
				startPos = main.Position
				local c
				c = input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
						c:Disconnect()
					end
				end)
			end
		end)
		connect(UserInputService.InputChanged, function(input)
			if dragging and isMove(input) then
				local d = input.Position - dragStart
				local vp = workspace.CurrentCamera.ViewportSize
				local x = math.clamp(startPos.X.Offset + d.X, -main.AbsoluteSize.X + 80, vp.X - 80)
				local y = math.clamp(startPos.Y.Offset + d.Y, 0, vp.Y - 40)
				main.Position = UDim2.fromOffset(x, y)
			end
		end)

		-- resize grip (มุมขวาล่าง)
		local grip = create("TextButton", {
			Name = "Grip", AutoButtonColor = false, Text = "", BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -2, 1, -2),
			Size = UDim2.fromOffset(18, 18), ZIndex = 50, Parent = main,
		})
		for _, p in ipairs({ { 12, 4 }, { 8, 8 }, { 12, 8 }, { 4, 12 }, { 8, 12 }, { 12, 12 } }) do
			local d = create("Frame", {
				BackgroundColor3 = T.SubText, BackgroundTransparency = 0.35, BorderSizePixel = 0,
				Position = UDim2.fromOffset(p[1], p[2]), Size = UDim2.fromOffset(2, 2), ZIndex = 50, Parent = grip,
			})
			create("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = d })
		end
		local resizing, rStart, rSize = false, nil, nil
		grip.InputBegan:Connect(function(input)
			if isPress(input) then
				resizing = true
				rStart = input.Position
				rSize = Vector2.new(main.Size.X.Offset, main.Size.Y.Offset)
				local c
				c = input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						resizing = false
						c:Disconnect()
					end
				end)
			end
		end)
		connect(UserInputService.InputChanged, function(input)
			if resizing and isMove(input) then
				local d = (input.Position - rStart) / self.Scale
				main.Size = UDim2.fromOffset(
					math.clamp(rSize.X + d.X, 520, 1400),
					math.clamp(rSize.Y + d.Y, 300, 900)
				)
			end
		end)
		self.Grip = grip

		closeBtn.Activated:Connect(function()
			self:Destroy()
		end)

		local minimized, restoreSize = false, nil
		minBtn.Activated:Connect(function()
			if minimized then
				minimized = false
				body.Visible = true
				grip.Visible = true
				tween(main, 0.2, { Size = restoreSize })
			else
				minimized = true
				restoreSize = main.Size
				body.Visible = false
				grip.Visible = false
				tween(main, 0.2, { Size = UDim2.fromOffset(main.Size.X.Offset, 34) })
			end
		end)

		local maximized, oldSize, oldPos = false, nil, nil
		maxBtn.Activated:Connect(function()
			if minimized then
				return
			end
			local vp = workspace.CurrentCamera.ViewportSize
			if maximized then
				maximized = false
				tween(main, 0.2, { Size = oldSize, Position = oldPos })
			else
				maximized = true
				oldSize, oldPos = main.Size, main.Position
				local w, h = vp.X * 0.96 / self.Scale, vp.Y * 0.94 / self.Scale
				tween(main, 0.2, {
					Size = UDim2.fromOffset(w, h),
					Position = UDim2.fromOffset(vp.X * 0.02, vp.Y * 0.03),
				})
			end
		end)
	end

	----------------------------------------------------------------
	-- Search bar
	----------------------------------------------------------------
	do
		local bar = create("Frame", {
			Name = "SearchBar", Visible = false, BackgroundColor3 = T.Input,
			Position = UDim2.fromOffset(8, 40), Size = UDim2.new(1, -16, 0, 28), ZIndex = 20, Parent = main,
		})
		corner(bar, 7)
		stroke(bar, T.InputStroke, 1, 0)
		local ic = makeIcon(T, bar, "search", 13, T.SubText)
		ic.Frame.Position = UDim2.fromOffset(9, 7.5)
		ic.Frame.ZIndex = 21
		local box = newText(T, "TextBox", {
			Name = "Box", PlaceholderText = "search...", PlaceholderColor3 = T.SubText, Text = "",
			ClearTextOnFocus = false, TextSize = T.Size.Item, Position = UDim2.fromOffset(30, 0),
			Size = UDim2.new(1, -38, 1, 0), ZIndex = 21, Parent = bar,
		})
		connect(box:GetPropertyChangedSignal("Text"), function()
			self:ApplySearch(box.Text)
		end)
		searchBtn.Activated:Connect(function()
			bar.Visible = not bar.Visible
			if bar.Visible then
				box:CaptureFocus()
			else
				box.Text = ""
				self:ApplySearch("")
			end
		end)
		self.SearchBar = bar
	end

	----------------------------------------------------------------
	-- Notification history panel (ปุ่มกระดิ่ง)
	----------------------------------------------------------------
	do
		local panel = create("Frame", {
			Name = "NotifPanel", Visible = false, BackgroundColor3 = T.Toast, BackgroundTransparency = T.ToastT,
			AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 40), Size = UDim2.fromOffset(250, 210),
			ZIndex = 30, Parent = main,
		})
		corner(panel, 8)
		stroke(panel, T.InputStroke, 1, 0)
		newText(T, "TextLabel", {
			Text = "notifications", Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -70, 0, 28),
			TextSize = T.Size.Header, ZIndex = 31, Parent = panel,
		}, T.TitleWeight)
		local clear = newText(T, "TextButton", {
			Text = "clear", TextColor3 = T.SubText, TextSize = T.Size.Desc, AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -8, 0, 0), Size = UDim2.fromOffset(50, 28), TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = 31, Parent = panel,
		})
		local scroll = create("ScrollingFrame", {
			BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 30),
			Size = UDim2.new(1, 0, 1, -30), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 3, ScrollBarImageColor3 = T.SubText, ZIndex = 31, Parent = panel,
		})
		list(scroll, 4)
		pad(scroll, 8, 0, 8, 8)

		local function rebuild()
			for _, c in ipairs(scroll:GetChildren()) do
				if c:IsA("Frame") then
					c:Destroy()
				end
			end
			if #self.Notifications == 0 then
				local empty = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), ZIndex = 32, Parent = scroll })
				newText(T, "TextLabel", {
					Text = "no notifications", TextColor3 = T.SubText, TextSize = T.Size.Desc,
					Size = UDim2.fromScale(1, 1), ZIndex = 32, Parent = empty,
				})
				return
			end
			for i, n in ipairs(self.Notifications) do
				local e = create("Frame", {
					BackgroundColor3 = T.Row, BackgroundTransparency = T.RowT, BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = i,
					ZIndex = 32, Parent = scroll,
				})
				corner(e, 6)
				list(e, 2)
				pad(e, 9, 7, 9, 7)
				newText(T, "TextLabel", {
					Text = n.Title .. "  " .. n.Time, TextSize = T.Size.Desc, TextColor3 = T.SubText,
					Size = UDim2.new(1, 0, 0, 11), LayoutOrder = 1, ZIndex = 33, Parent = e,
				})
				newText(T, "TextLabel", {
					Text = n.Content, TextSize = T.Size.Desc + 1, TextWrapped = true,
					Size = UDim2.new(1, 0, 0, 11), AutomaticSize = Enum.AutomaticSize.Y,
					TextYAlignment = Enum.TextYAlignment.Top, LayoutOrder = 2, ZIndex = 33, Parent = e,
				})
			end
		end

		bellBtn.Activated:Connect(function()
			panel.Visible = not panel.Visible
			if panel.Visible then
				self.Unread = 0
				self.BellBadge.Visible = false
				rebuild()
			end
		end)
		clear.Activated:Connect(function()
			table.clear(self.Notifications)
			rebuild()
		end)
		self.NotifPanel = panel
	end

	----------------------------------------------------------------
	-- Console panel (ปุ่ม >_)
	----------------------------------------------------------------
	do
		local panel = create("Frame", {
			Name = "Console", Visible = false, BackgroundColor3 = T.Input, BackgroundTransparency = 0.02,
			Position = UDim2.fromOffset(8, 42), Size = UDim2.new(1, -16, 1, -50), ZIndex = 25, Parent = main,
		})
		corner(panel, 8)
		stroke(panel, T.InputStroke, 1, 0)
		local logs = create("ScrollingFrame", {
			BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, -30),
			CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3,
			ScrollBarImageColor3 = T.SubText, ZIndex = 26, Parent = panel,
		})
		list(logs, 2)
		pad(logs, 10, 8, 10, 4)
		local inputHolder = create("Frame", {
			BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, 28), ZIndex = 26, Parent = panel,
		})
		create("Frame", {
			BackgroundColor3 = T.Divider, BackgroundTransparency = T.DividerT, BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 1), ZIndex = 27, Parent = inputHolder,
		})
		local mono = { FontEnum = Enum.Font.RobotoMono, BodyWeight = Enum.FontWeight.Regular, Size = T.Size, Text = T.Text }
		newText(mono, "TextLabel", {
			Text = ">", TextColor3 = T.SubText, Position = UDim2.fromOffset(10, 0), Size = UDim2.fromOffset(10, 28),
			ZIndex = 27, Parent = inputHolder,
		})
		local box = newText(mono, "TextBox", {
			PlaceholderText = "type a command (help)", PlaceholderColor3 = T.SubText, Text = "", ClearTextOnFocus = false,
			Position = UDim2.fromOffset(24, 0), Size = UDim2.new(1, -32, 1, 0), ZIndex = 27, Parent = inputHolder,
		})

		self._logs = logs
		self._mono = mono
		self.Console = panel

		function self:Log(text, color)
			local line = newText(mono, "TextLabel", {
				Text = tostring(text), TextColor3 = color or T.Text, TextSize = T.Size.Desc + 1, TextWrapped = true,
				Size = UDim2.new(1, 0, 0, 11), AutomaticSize = Enum.AutomaticSize.Y,
				TextYAlignment = Enum.TextYAlignment.Top, LayoutOrder = #logs:GetChildren() + 1, ZIndex = 27, Parent = logs,
			})
			logs.CanvasPosition = Vector2.new(0, 1e6)
			return line
		end

		box.FocusLost:Connect(function(enter)
			if not enter then
				return
			end
			local text = box.Text
			box.Text = ""
			if text ~= "" then
				self:Log("> " .. text, T.SubText)
				local args = string.split(text, " ")
				local cmd = table.remove(args, 1):lower()
				local c = self.Commands[cmd]
				if c then
					safe(c.Callback, args)
				else
					self:Log("unknown command: " .. cmd, Color3.fromRGB(255, 120, 110))
				end
			end
			box:CaptureFocus()
		end)

		termBtn.Activated:Connect(function()
			panel.Visible = not panel.Visible
			if panel.Visible then
				box:CaptureFocus()
			end
		end)

		self:AddCommand("help", function()
			for name, c in pairs(self.Commands) do
				self:Log(name .. " - " .. (c.Help or ""))
			end
		end, "list commands")
		self:AddCommand("clear", function()
			for _, c in ipairs(logs:GetChildren()) do
				if c:IsA("TextLabel") then
					c:Destroy()
				end
			end
		end, "clear console")
		self:AddCommand("flags", function()
			for flag, value in pairs(self.Flags) do
				self:Log(flag .. " = " .. tostring(value))
			end
		end, "print all flag values")
		self:Log("astral hub console ready. type 'help'.", T.SubText)
	end

	----------------------------------------------------------------
	-- Save button + toggle key
	----------------------------------------------------------------
	saveBtn.Activated:Connect(function()
		self:SaveConfig()
	end)

	connect(UserInputService.InputBegan, function(input, processed)
		if not processed and input.KeyCode == self.ToggleKey then
			self:Toggle()
		end
	end)

	Library.Windows[#Library.Windows + 1] = self
	return self
end

--==================================================================--
--  WINDOW METHODS
--==================================================================--
function Window:Toggle(state)
	if state == nil then
		state = not self.Gui.Enabled
	end
	self.Gui.Enabled = state
end

function Window:Destroy()
	for _, c in ipairs(self.Connections) do
		c:Disconnect()
	end
	table.clear(self.Connections)
	self.Gui:Destroy()
	local i = table.find(Library.Windows, self)
	if i then
		table.remove(Library.Windows, i)
	end
end

function Window:AddCommand(name, callback, help)
	self.Commands[name:lower()] = { Callback = callback, Help = help }
end

function Window:Notify(options)
	if type(options) == "string" then
		options = { Content = options }
	end
	local T = self.Theme
	local title = options.Title or "Astral Hub"
	local content = options.Content or ""
	local duration = options.Duration or 4

	table.insert(self.Notifications, 1, { Title = title, Content = content, Time = os.date("%H:%M") })
	if #self.Notifications > 30 then
		table.remove(self.Notifications)
	end
	if not self.NotifPanel.Visible then
		self.Unread += 1
		self.BellBadge.Visible = true
	end

	local toast = create("CanvasGroup", {
		Name = "Toast", BackgroundColor3 = T.Toast, BackgroundTransparency = T.ToastT, BorderSizePixel = 0,
		GroupTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		Parent = self.ToastHolder,
	})
	corner(toast, 8)
	create("Frame", {
		BackgroundColor3 = T.Accent, BorderSizePixel = 0, Size = UDim2.new(0, 2, 1, 0), Parent = toast,
	})
	local inner = create("Frame", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = toast,
	})
	list(inner, 2)
	pad(inner, 14, 10, 12, 10)
	newText(T, "TextLabel", {
		Text = title, Size = UDim2.new(1, 0, 0, 13), LayoutOrder = 1, Parent = inner,
	}, T.TitleWeight)
	newText(T, "TextLabel", {
		Text = content, TextColor3 = T.SubText, TextSize = T.Size.Desc, TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 11), AutomaticSize = Enum.AutomaticSize.Y,
		TextYAlignment = Enum.TextYAlignment.Top, LayoutOrder = 2, Parent = inner,
	})
	tween(toast, 0.25, { GroupTransparency = 0 })
	task.delay(duration, function()
		if toast.Parent then
			tween(toast, 0.3, { GroupTransparency = 1 })
			task.wait(0.3)
			toast:Destroy()
		end
	end)
end

function Window:ApplySearch(query)
	query = (query or ""):lower()
	local tab = self.ActiveTab
	if not tab then
		return
	end
	for _, section in ipairs(tab.Sections) do
		local shown = 0
		for _, element in ipairs(section.Elements) do
			local match = query == "" or element.Text:find(query, 1, true) ~= nil
			element.Frame.Visible = match
			if match then
				shown += 1
			end
		end
		section.Card.Visible = query == "" or shown > 0
	end
end

function Window:SelectTab(tab)
	if self.ActiveTab == tab then
		return
	end
	if self.ActiveTab then
		self.ActiveTab.Page.Visible = false
		self.ActiveTab.SetActive(false)
	end
	self.ActiveTab = tab
	tab.Page.Visible = true
	tab.SetActive(true)
	if self.SearchBar and self.SearchBar.Visible then
		self:ApplySearch(self.SearchBar.Box.Text)
	end
end

function Window:GetConfig()
	local data = {}
	for flag, value in pairs(self.Flags) do
		if typeof(value) == "EnumItem" then
			value = value.Name
		end
		data[flag] = value
	end
	return HttpService:JSONEncode(data)
end

function Window:LoadConfig(json)
	local ok, data = pcall(HttpService.JSONDecode, HttpService, json)
	if not ok then
		return false
	end
	for flag, value in pairs(data) do
		local option = self.Options[flag]
		if option then
			option:Set(value)
		end
	end
	return true
end

function Window:SaveConfig()
	local json = self:GetConfig()
	if self.OnSave then
		safe(self.OnSave, json)
	elseif type(writefile) == "function" then
		pcall(writefile, self.ConfigName, json)
	end
	self:Notify({ Title = "Config", Content = "Settings saved.", Duration = 2.5 })
	return json
end

function Window:_register(flag, option)
	if flag then
		self.Flags[flag] = option.Value
		self.Options[flag] = option
	end
end

--==================================================================--
--  TABS
--==================================================================--
function Window:AddTab(options)
	if type(options) == "string" then
		options = { Name = options }
	end
	local T = self.Theme
	local tab = setmetatable({
		Window = self,
		Name = options.Name or "tab",
		Sections = {},
		SectionCount = 0,
	}, Tab)
	self.Tabs[#self.Tabs + 1] = tab
	local order = #self.Tabs

	-- page (scroll หนึ่งอัน สองคอลัมน์)
	local page = create("ScrollingFrame", {
		Name = tab.Name, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3,
		ScrollBarImageColor3 = T.SubText, ScrollBarImageTransparency = 0.5,
		ScrollingDirection = Enum.ScrollingDirection.Y, Visible = false, Parent = self.Content,
	})
	local columns = create("Frame", {
		Name = "Columns", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, Parent = page,
	})
	list(columns, 6, { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Top })
	pad(columns, T.PadLeft, 8, 14, 10)

	local function column(name, layoutOrder)
		local c = create("Frame", {
			Name = name, BackgroundTransparency = 1, Size = UDim2.new(0.5, -3, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = layoutOrder, Parent = columns,
		})
		list(c, 6)
		return c
	end
	tab.Page = page
	tab.LeftColumn = column("Left", 1)
	tab.RightColumn = column("Right", 2)

	-- ปุ่มแท็บ
	if T.Layout == "Sidebar" then
		local btn = newText(T, "TextButton", {
			Name = tab.Name, Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = T.SideItem, LayoutOrder = order,
			Parent = options.Pinned and self.SidePinned or self.SideList,
		})
		corner(btn, 7)
		local arrow = newText(T, "TextLabel", {
			Text = ">", Visible = false, Position = UDim2.fromOffset(9, 0), Size = UDim2.fromOffset(10, 36),
			TextSize = T.Size.Tab, Parent = btn,
		}, T.TitleWeight)
		local label = newText(T, "TextLabel", {
			Text = tab.Name, Position = UDim2.fromOffset(19, 0), Size = UDim2.new(1, -22, 1, 0),
			TextSize = T.Size.Tab, TextColor3 = T.Text, TextTruncate = Enum.TextTruncate.AtEnd, Parent = btn,
		}, T.BodyWeight)
		tab.SetActive = function(active)
			arrow.Visible = active
			label.FontFace = fontOf(T, active and T.TitleWeight or T.BodyWeight)
			label.TextColor3 = active and T.Text or Color3.fromRGB(205, 206, 216)
			tween(btn, 0.15, { BackgroundColor3 = active and T.SideItemActive or T.SideItem })
		end
		tab.SetActive(false)
		btn.Activated:Connect(function()
			self:SelectTab(tab)
		end)
		tab.Button = btn
	else
		local btn = create("TextButton", {
			Name = tab.Name, AutoButtonColor = false, Text = "", Size = UDim2.fromOffset(38, 38),
			BackgroundColor3 = WHITE, BorderSizePixel = 0, LayoutOrder = order, Parent = self.Dock,
		})
		corner(btn, 10)
		gradient(btn, T.DockButtonA, T.DockButtonB, 45)
		local ic = makeIcon(T, btn, options.Icon or tab.Name:sub(1, 1):upper(), 18, Color3.fromRGB(248, 251, 255))
		centerIcon(ic)
		local dot = create("Frame", {
			Name = "Dot", Visible = false, BackgroundColor3 = T.Text, BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 1, 11), Size = UDim2.fromOffset(5, 5),
			Parent = btn,
		})
		create("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = dot })
		tab.SetActive = function(active)
			dot.Visible = active
		end
		btn.MouseEnter:Connect(function() tween(btn, 0.12, { BackgroundTransparency = 0.12 }) end)
		btn.MouseLeave:Connect(function() tween(btn, 0.12, { BackgroundTransparency = 0 }) end)
		btn.Activated:Connect(function()
			self:SelectTab(tab)
		end)
		tab.Button = btn
	end

	if #self.Tabs == 1 then
		self:SelectTab(tab)
	end
	return tab
end

--==================================================================--
--  SECTIONS (การ์ดพับได้)
--==================================================================--
function Tab:AddSection(options)
	if type(options) == "string" then
		options = { Name = options }
	end
	local T = self.Window.Theme
	local side = options.Side
	if not side then
		self.SectionCount += 1
		side = (self.SectionCount % 2 == 1) and "Left" or "Right"
	end
	local col = side == "Right" and self.RightColumn or self.LeftColumn

	local section = setmetatable({
		Tab = self,
		Window = self.Window,
		Theme = T,
		Elements = {},
		Order = 0,
		Collapsed = false,
	}, Section)

	local card = create("Frame", {
		Name = options.Name or "Section", BackgroundColor3 = T.Card, BackgroundTransparency = T.CardT,
		BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = #col:GetChildren(), Parent = col,
	})
	corner(card, T.Corner.Card)
	stroke(card, T.CardStroke, 1, T.CardStrokeT)
	if T.CardGradient then
		gradient(card, T.CardGradient[1], T.CardGradient[2], 90)
	end
	list(card, 0, { HorizontalAlignment = Enum.HorizontalAlignment.Center })
	section.Card = card

	-- header
	local header = newText(T, "TextButton", {
		Name = "Header", Size = UDim2.new(1, 0, 0, 40), LayoutOrder = 1, Parent = card,
	})
	local x = 12
	if options.Icon then
		local ic = makeIcon(T, header, options.Icon, 16, T.Text)
		ic.Frame.AnchorPoint = Vector2.new(0, 0.5)
		ic.Frame.Position = UDim2.new(0, 9, 0.5, 0)
		x = 33
	end
	newText(T, "TextLabel", {
		Text = options.Name or "Section", Position = UDim2.fromOffset(x, 0), Size = UDim2.new(1, -(x + 30), 1, 0),
		TextSize = T.Size.Header, Parent = header,
	}, T.TitleWeight)
	local chev = makeIcon(T, header, "chevron", 12, T.Text)
	chev.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	chev.Frame.Position = UDim2.new(1, -15, 0.5, 0)

	local headerDivider
	if T.HeaderDivider then
		headerDivider = create("Frame", {
			Name = "Divider", BackgroundColor3 = T.HeaderDivider, BorderSizePixel = 0,
			Size = UDim2.new(1, -16, 0, 1), LayoutOrder = 2, Parent = card,
		})
	end

	local body = create("Frame", {
		Name = "Body", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 3, Parent = card,
	})
	list(body, 5)
	pad(body, 8, T.HeaderDivider and 5 or 0, 8, 8)
	section.Body = body

	function section:SetCollapsed(state)
		self.Collapsed = state
		body.Visible = not state
		if headerDivider then
			headerDivider.Visible = not state
		end
		tween(chev.Frame, 0.15, { Rotation = state and -90 or 0 })
	end
	header.Activated:Connect(function()
		section:SetCollapsed(not section.Collapsed)
	end)
	if options.Collapsed then
		section:SetCollapsed(true)
	end

	table.insert(self.Sections, section)
	return section
end

function Section:NextOrder()
	self.Order += 1
	return self.Order
end

function Section:_track(frame, name, desc)
	self.Elements[#self.Elements + 1] = {
		Frame = frame,
		Text = ((name or "") .. " " .. (desc or "")):lower(),
	}
end

-- แถวมาตรฐาน: ชื่อ + คำอธิบาย
local function newRow(section, opts, rightPad, extra)
	local T = section.Theme
	local hasDesc = opts.Description ~= nil and opts.Description ~= ""
	local row = create("Frame", {
		Name = opts.Name or "Row", BackgroundColor3 = T.Row, BackgroundTransparency = T.RowT,
		BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 45), AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = section:NextOrder(), Parent = section.Body,
	})
	corner(row, T.Corner.Row)
	if T.RowStroke then
		stroke(row, T.RowStroke, 1, T.RowStrokeT)
	end
	local info = create("Frame", {
		Name = "Info", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, Parent = row,
	})
	list(info, 2)
	local vpad = (hasDesc or extra) and 9 or 16
	pad(info, 12, vpad, rightPad, vpad)

	local title = newText(T, "TextLabel", {
		Name = "Title", Text = opts.Name or "", Size = UDim2.new(1, extra and -48 or 0, 0, 13),
		TextSize = T.Size.Item, TextTruncate = Enum.TextTruncate.AtEnd, LayoutOrder = 1, Parent = info,
	}, T.TitleWeight)
	local desc
	if hasDesc then
		desc = newText(T, "TextLabel", {
			Name = "Desc", Text = opts.Description, TextColor3 = T.SubText, TextSize = T.Size.Desc,
			TextWrapped = true, Size = UDim2.new(1, 0, 0, 11), AutomaticSize = Enum.AutomaticSize.Y,
			TextYAlignment = Enum.TextYAlignment.Top, LayoutOrder = 2, Parent = info,
		})
	end
	hoverColor(row, T.Row, T.RowHover)
	section:_track(row, opts.Name, opts.Description)
	return row, info, title, desc
end

--==================================================================--
--  ELEMENTS
--==================================================================--

-- Label / Paragraph
function Section:AddLabel(title, description)
	local T = self.Theme
	if type(title) == "table" then
		title, description = title.Title or title.Name, title.Description or title.Content
	end
	local frame = create("Frame", {
		Name = "Label", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = self:NextOrder(), Parent = self.Body,
	})
	list(frame, 3)
	pad(frame, 1, title and 9 or 6, 1, 8)
	local t, d
	if title then
		t = newText(T, "TextLabel", {
			Text = title, Size = UDim2.new(1, 0, 0, 13), TextSize = T.Size.Item, LayoutOrder = 1, Parent = frame,
		}, T.TitleWeight)
	end
	if description then
		d = newText(T, "TextLabel", {
			Text = description, TextColor3 = T.SubText, TextSize = T.Size.Desc, TextWrapped = true,
			Size = UDim2.new(1, 0, 0, 11), AutomaticSize = Enum.AutomaticSize.Y,
			TextYAlignment = Enum.TextYAlignment.Top, LayoutOrder = 2, Parent = frame,
		})
	end
	self:_track(frame, title, description)
	local obj = { Frame = frame }
	function obj:Set(newTitle, newDesc)
		if t and newTitle then t.Text = newTitle end
		if d and newDesc then d.Text = newDesc end
	end
	return obj
end
Section.AddParagraph = Section.AddLabel

-- Button
function Section:AddButton(opts)
	local T = self.Theme
	if type(opts) == "string" then
		opts = { Name = opts }
	end
	local btn = newText(T, "TextButton", {
		Name = opts.Name or "Button", Text = opts.Name or "Button", TextXAlignment = Enum.TextXAlignment.Center,
		TextSize = T.Size.Button, BackgroundColor3 = T.Button, Size = UDim2.new(1, 0, 0, 31),
		LayoutOrder = self:NextOrder(), Parent = self.Body,
	})
	corner(btn, T.Corner.Button)
	stroke(btn, T.ButtonStroke, 1, T.ButtonStrokeT)
	hoverColor(btn, T.Button, T.ButtonHover)
	btn.Activated:Connect(function()
		btn.BackgroundColor3 = T.Accent
		btn.BackgroundTransparency = 0.8
		tween(btn, 0.25, { BackgroundColor3 = T.Button, BackgroundTransparency = 0 })
		safe(opts.Callback)
	end)
	self:_track(btn, opts.Name, opts.Description)
	local obj = { Frame = btn }
	function obj:SetText(text) btn.Text = text end
	return obj
end

-- Toggle
function Section:AddToggle(opts)
	local T = self.Theme
	local row = newRow(self, opts, T.Switch and 62 or 52)
	local obj = { Type = "Toggle", Value = false }
	local setVisual

	if T.Switch then
		local track = create("Frame", {
			Name = "Switch", BackgroundColor3 = T.SwitchOff, BorderSizePixel = 0,
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(36, 18),
			ZIndex = 2, Parent = row,
		})
		create("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = track })
		local knob = create("Frame", {
			BackgroundColor3 = WHITE, BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 2, 0.5, 0), Size = UDim2.fromOffset(14, 14), ZIndex = 3, Parent = track,
		})
		create("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = knob })
		setVisual = function(on)
			tween(track, 0.15, { BackgroundColor3 = on and T.Accent or T.SwitchOff })
			tween(knob, 0.15, { Position = on and UDim2.new(0, 20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0) })
		end
	else
		local box = newText(T, "TextLabel", {
			Name = "Box", Text = "[ ]", TextColor3 = T.SubText, TextSize = T.Size.Item, TextXAlignment = Enum.TextXAlignment.Right,
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(30, 14),
			ZIndex = 2, Parent = row,
		}, T.TitleWeight)
		local rowStroke = row:FindFirstChildOfClass("UIStroke")
		setVisual = function(on)
			box.Text = on and "[x]" or "[ ]"
			box.TextColor3 = on and T.Accent or T.SubText
			if rowStroke then
				tween(rowStroke, 0.15, { Color = on and Color3.fromRGB(90, 91, 104) or T.RowStroke })
			end
		end
	end

	function obj:Set(value, silent)
		value = value and true or false
		self.Value = value
		setVisual(value)
		if opts.Flag then
			self.Window.Flags[opts.Flag] = value
		end
		if not silent then
			safe(opts.Callback, value)
		end
	end
	function obj:Get()
		return self.Value
	end
	obj.Window = self.Window

	local hit = create("TextButton", {
		Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 4, Parent = row,
	})
	hit.Activated:Connect(function()
		obj:Set(not obj.Value)
	end)

	if opts.Default then
		obj:Set(true, true)
	end
	self.Window:_register(opts.Flag, obj)
	return obj
end

-- Slider
function Section:AddSlider(opts)
	local T = self.Theme
	local min, max = opts.Min or 0, opts.Max or 100
	local inc = opts.Increment or 1
	local row, info = newRow(self, opts, 12, true)
	local obj = { Type = "Slider", Value = min, Window = self.Window }

	local valueLabel = newText(T, "TextLabel", {
		Name = "Value", Text = "", TextColor3 = T.SubText, TextSize = T.Size.Desc, TextXAlignment = Enum.TextXAlignment.Right,
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 9), Size = UDim2.fromOffset(60, 13), Parent = row,
	})

	local holder = create("Frame", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 12), LayoutOrder = 5, Parent = info,
	})
	local track = create("Frame", {
		BackgroundColor3 = T.Track, BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5), Size = UDim2.new(1, 0, 0, 4), Parent = holder,
	})
	create("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = track })
	local fill = create("Frame", {
		BackgroundColor3 = T.Accent, BorderSizePixel = 0, Size = UDim2.fromScale(0, 1), Parent = track,
	})
	create("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = fill })
	if T.Switch then
		local knob = create("Frame", {
			BackgroundColor3 = WHITE, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromOffset(10, 10), Parent = fill,
		})
		create("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = knob })
	end

	local function fmt(v)
		return tostring(math.floor(v * 100 + 0.5) / 100) .. (opts.Suffix or "")
	end

	function obj:Set(value, silent)
		value = math.clamp(tonumber(value) or min, min, max)
		value = math.clamp(math.floor((value - min) / inc + 0.5) * inc + min, min, max)
		self.Value = value
		fill.Size = UDim2.fromScale((value - min) / math.max(max - min, 1e-9), 1)
		valueLabel.Text = fmt(value)
		if opts.Flag then
			self.Window.Flags[opts.Flag] = value
		end
		if not silent then
			safe(opts.Callback, value)
		end
	end
	function obj:Get()
		return self.Value
	end

	local dragging = false
	local function fromX(x)
		local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		obj:Set(min + (max - min) * rel)
	end
	local hit = create("TextButton", {
		Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = holder,
	})
	hit.InputBegan:Connect(function(input)
		if isPress(input) then
			dragging = true
			self.Tab.Page.ScrollingEnabled = false
			fromX(input.Position.X)
		end
	end)
	self.Window._connect(UserInputService.InputChanged, function(input)
		if dragging and isMove(input) then
			fromX(input.Position.X)
		end
	end)
	self.Window._connect(UserInputService.InputEnded, function(input)
		if dragging and isPress(input) then
			dragging = false
			self.Tab.Page.ScrollingEnabled = true
		end
	end)

	obj:Set(opts.Default or min, true)
	self.Window:_register(opts.Flag, obj)
	return obj
end

-- Dropdown (เลือกอันเดียว หรือ Multi)
function Section:AddDropdown(opts)
	local T = self.Theme
	local row, info = newRow(self, opts, 150)
	local multi = opts.Multi == true
	local obj = { Type = "Dropdown", Options = opts.Options or {}, Value = multi and {} or nil, Window = self.Window }

	local valueLabel = newText(T, "TextLabel", {
		Name = "Value", Text = "None", TextColor3 = T.SubText, TextSize = T.Size.Desc, TextXAlignment = Enum.TextXAlignment.Right,
		TextTruncate = Enum.TextTruncate.AtEnd, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -28, 0, 0),
		Size = UDim2.fromOffset(110, 45), Parent = row,
	})
	local chev = makeIcon(T, row, "chevron", 12, T.SubText)
	chev.Frame.AnchorPoint = Vector2.new(1, 0.5)
	chev.Frame.Position = UDim2.new(1, -10, 0, 22.5)

	local listFrame = create("Frame", {
		Name = "Options", Visible = false, BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 45),
		Size = UDim2.new(1, -16, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 3, Parent = row,
	})
	list(listFrame, 3)
	pad(listFrame, 0, 0, 0, 8)

	local buttons = {}
	local function refreshText()
		if multi then
			local names = {}
			for _, o in ipairs(obj.Options) do
				if obj.Value[o] then
					names[#names + 1] = o
				end
			end
			valueLabel.Text = #names == 0 and "None" or table.concat(names, ", ")
		else
			valueLabel.Text = obj.Value or "None"
		end
		for name, b in pairs(buttons) do
			local selected = multi and obj.Value[name] or obj.Value == name
			b.TextColor3 = selected and T.Accent or T.SubText
		end
	end

	local function build()
		for _, b in pairs(buttons) do
			b:Destroy()
		end
		table.clear(buttons)
		for i, name in ipairs(obj.Options) do
			local b = newText(T, "TextButton", {
				Text = tostring(name), TextColor3 = T.SubText, TextSize = T.Size.Desc + 1,
				Size = UDim2.new(1, 0, 0, 22), BackgroundColor3 = T.Button, LayoutOrder = i, ZIndex = 4, Parent = listFrame,
			})
			corner(b, 5)
			pad(b, 8, 0, 8, 0)
			b.Activated:Connect(function()
				if multi then
					obj.Value[name] = not obj.Value[name] or nil
				else
					obj.Value = name
					listFrame.Visible = false
					tween(chev.Frame, 0.15, { Rotation = 0 })
				end
				refreshText()
				if opts.Flag then
					obj.Window.Flags[opts.Flag] = obj.Value
				end
				safe(opts.Callback, obj.Value)
			end)
			buttons[name] = b
		end
		refreshText()
	end

	function obj:Set(value, silent)
		if multi then
			self.Value = {}
			if type(value) == "table" then
				for k, v in pairs(value) do
					if type(k) == "number" then
						self.Value[v] = true
					elseif v then
						self.Value[k] = true
					end
				end
			end
		else
			self.Value = value
		end
		refreshText()
		if opts.Flag then
			self.Window.Flags[opts.Flag] = self.Value
		end
		if not silent then
			safe(opts.Callback, self.Value)
		end
	end
	function obj:Get()
		return self.Value
	end
	function obj:Refresh(newOptions)
		self.Options = newOptions
		build()
	end

	local hit = create("TextButton", {
		Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 45), ZIndex = 2, Parent = row,
	})
	hit.Activated:Connect(function()
		listFrame.Visible = not listFrame.Visible
		tween(chev.Frame, 0.15, { Rotation = listFrame.Visible and 180 or 0 })
	end)

	build()
	if opts.Default ~= nil then
		obj:Set(opts.Default, true)
	end
	self.Window:_register(opts.Flag, obj)
	return obj
end

-- Input (ช่องพิมพ์)
function Section:AddInput(opts)
	local T = self.Theme
	local row = newRow(self, opts, 134)
	local obj = { Type = "Input", Value = opts.Default or "", Window = self.Window }

	local holder = create("Frame", {
		BackgroundColor3 = T.Input, BorderSizePixel = 0, AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(112, 24), Parent = row,
	})
	corner(holder, 5)
	stroke(holder, T.InputStroke, 1, 0)
	local box = newText(T, "TextBox", {
		Text = obj.Value, PlaceholderText = opts.Placeholder or "...", PlaceholderColor3 = T.SubText,
		ClearTextOnFocus = false, TextSize = T.Size.Desc + 1, Size = UDim2.fromScale(1, 1),
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = holder,
	})
	pad(box, 8, 0, 8, 0)

	function obj:Set(value, silent)
		self.Value = tostring(value)
		box.Text = self.Value
		if opts.Flag then
			self.Window.Flags[opts.Flag] = self.Value
		end
		if not silent then
			safe(opts.Callback, self.Value)
		end
	end
	function obj:Get()
		return self.Value
	end
	box.FocusLost:Connect(function(enter)
		if enter or opts.CommitOnBlur then
			obj:Set(box.Text)
		else
			box.Text = obj.Value
		end
	end)

	self.Window:_register(opts.Flag, obj)
	return obj
end

-- Keybind
function Section:AddKeybind(opts)
	local T = self.Theme
	local row = newRow(self, opts, 110)
	local obj = { Type = "Keybind", Value = "None", Window = self.Window }
	local binding = false

	local btn = newText(T, "TextButton", {
		Name = "Key", TextSize = T.Size.Desc + 1, TextXAlignment = Enum.TextXAlignment.Center,
		BackgroundColor3 = T.Button, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(86, 22), ZIndex = 2, Parent = row,
	})
	corner(btn, 5)
	stroke(btn, T.ButtonStroke, 1, T.ButtonStrokeT)

	local function refresh()
		if binding then
			btn.Text = "..."
		else
			btn.Text = T.Switch and obj.Value or ("[ " .. obj.Value .. " ]")
		end
	end

	function obj:Set(key, silent)
		if typeof(key) == "EnumItem" then
			key = key.Name
		end
		self.Value = key or "None"
		refresh()
		if opts.Flag then
			self.Window.Flags[opts.Flag] = self.Value
		end
		if not silent then
			safe(opts.Changed, self.Value)
		end
	end
	function obj:Get()
		return self.Value
	end

	btn.Activated:Connect(function()
		binding = true
		refresh()
	end)
	self.Window._connect(UserInputService.InputBegan, function(input, processed)
		if binding then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				binding = false
				if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
					obj:Set("None")
				else
					obj:Set(input.KeyCode)
				end
			end
		elseif not processed and obj.Value ~= "None" and input.KeyCode.Name == obj.Value then
			safe(opts.Callback)
		end
	end)

	obj:Set(opts.Default or "None", true)
	self.Window:_register(opts.Flag, obj)
	return obj
end

--==================================================================--
function Library:Notify(options)
	local w = Library.Windows[#Library.Windows]
	if w then
		w:Notify(options)
	end
end

Library.Themes = Themes
return Library
