--[[
	╔══════════════════════════════════════════════════════════════════════════╗
	║  SeptusUI  ·  Roblox UI Library                                          ║
	║  Extracted 1:1 from Septus Hub V3.7 (same Instances, sizes, colours,     ║
	║  tweens and behaviour). Original structure (App / Services / State / UI  ║
	║  / Refs / Lib / API) is kept so every function keeps its original name.  ║
	╠══════════════════════════════════════════════════════════════════════════╣
	║  QUICK START                                                             ║
	║                                                                          ║
	║    local SeptusUI = loadstring(game:HttpGet("<raw url>"))()              ║
	║                                                                          ║
	║    local Hub = SeptusUI.CreateHub({                                      ║
	║        Name = "MyHub",                                                   ║
	║        Tabs = {                                                          ║
	║            { id = "Home",     title = "Home",     icon = "rbxassetid://128407802503574", expWidth = 76 },
	║            { id = "Settings", title = "Settings", icon = "rbxassetid://112763474266331", expWidth = 94 },
	║        },                                                                ║
	║    })                                                                    ║
	║                                                                          ║
	║    local Home  = Hub:AddSection("Home", { Title = "Home" })              ║
	║    local View  = Home:AddTab("Overview", 50)                             ║
	║    local Scroll = View:AddScroll()                                       ║
	║    local Group = Scroll:AddGroup("Movement")                             ║
	║    Group:AddToggle("Fly", "Lets you fly", false, function(v) end)        ║
	║    Group:AddSlider("WalkSpeed", "Speed", 16, 200, 16, function(v) end)   ║
	║                                                                          ║
	║    Hub:Start()                                                           ║
	║                                                                          ║
	║  Everything from the original script is still reachable through the     ║
	║  returned table, e.g. SeptusUI.CreateSettingToggleItem(...),             ║
	║  SeptusUI.Notify({...}), SeptusUI.CreateModal(...), SeptusUI.ApplyTheme  ║
	╚══════════════════════════════════════════════════════════════════════════╝
]]

local env = type(getgenv) == "function" and getgenv() or _G


local Services = {
	Players = game:GetService("Players"),
	Tween = game:GetService("TweenService"),
	Run = game:GetService("RunService"),
	Stats = game:GetService("Stats"),
	HttpService = game:GetService("HttpService"),
	Lighting = game:GetService("Lighting"),
	Workspace = game:GetService("Workspace"),
	UserInputService = game:GetService("UserInputService"),
	GuiService = game:GetService("GuiService"),
	SoundService = game:GetService("SoundService")
}

local App = {
	Player = Services.Players.LocalPlayer,
	Camera = Services.Workspace.CurrentCamera,

	UI = {
		Screen = nil,
		Main = nil,
		MainCorner = nil,
		HeaderLogo = nil,
		HeaderIcon = nil,
		ContentArea = nil,
		TopNavContainer = nil,
		WindowBtns = nil,
		NavElements = {},
		CurrentHoveredNav = nil,
		NotifContainer = nil,
		ActiveNotifs = {},
		BackgroundContainer = nil,
		CustomBgImage = nil,

		Graphs = { FPS = {}, Ping = {}, Players = {} }, Labels = {},
		ThemeElements = {},
		PanelElements = {},
		TextThemeElements = {},
		Switches = {}
	},

	State = {
		Minimized = false, Maximized = false,
		ActiveMain = "",
		OriginalSize = UDim2.fromOffset(800, 540),
		MenuAnim = "Standard",
		SHStyle = "Classic",
		NavStyle = "Classic",
		CornerRadius = 10,
		SelectedThemeIndex = 1,
		SelectedFontIndex = 1,
		ThemeColor = Color3.fromRGB(18, 18, 18),
		WindowTransparency = 0,
		PanelTransparency = 0,
		HideLogo = false,
		HideName = false,
		LightTheme = false,
		CustomTheme = nil,
		CustomThemes = {},
		BgOpacity = 85,
		BgZoom = 100,
		BgSaturation = 100,

		NotificationsEnabled = true,
		NotifAnim = "Slide",
		NotifSound = "Off",
		NotifPosition = "Bottom Right",
		PlayerNotifsEnabled = true,

		Language = "English",
		Unloaded = false
	},

	Refs = {
		IntroBlur = nil
	},

	API = {},
	Lib = {},
	Handlers = {}
}

local Lib = App.Lib
local API = App.API
local State = App.State
local UI = App.UI
local Refs = App.Refs

Lib.Conns = {}
Lib.Config = { Name = "SeptusUI", Folder = "SeptusUI" }
Lib.Version = {
	Current = "1.0",
	Display = "V1.0",
	Url = nil,
	Repo = nil,
	Status = "idle",
	Listeners = {}
}
Lib.HeaderAssets = {
	Logo = "rbxassetid://97808676894113",
	LogoLight = "rbxassetid://105446913647633",
	Icon = "rbxassetid://74736110237331"
}
Lib.NavTabs = {}
Lib.Stats = { FPS = 0, Ping = 0, Players = 0 }
Lib.StatsTick = {}
Lib.UnloadHooks = {}
State.NavAlign = "Center"


-- ══════════════════════════════════════════════════════════════════════════
--  CORE · helpers, fonts, theme engine
-- ══════════════════════════════════════════════════════════════════════════

function Lib.C(signal, callback)
	local connection = signal:Connect(callback)
	Lib.Conns[#Lib.Conns + 1] = connection
	return connection
end

local ClickSound = Instance.new("Sound")
ClickSound.SoundId = "rbxassetid://6895079853"
ClickSound.Volume = 0.5

function Lib.PlayClick()
	pcall(function()
		ClickSound:Play()
	end)
end

Lib.ToggleControls = {}
Lib.SliderControls = {}
Lib.ChoiceControls = {}
Lib.ConfigExtras = {}
Lib.FontSelectors = {}
Lib.BoundCorners = {}
Lib.ImageTheme = {}
Lib.ThemeHooks = {}

function Lib.BindCorner(parent, name)
	local corner = Instance.new("UICorner")
	corner.Name = name
	corner.CornerRadius = UDim.new(0, State.CornerRadius)
	corner.Parent = parent
	Lib.BoundCorners[corner] = true
	return corner
end

function Lib.SetCornerRadius(radius)
	State.CornerRadius = radius
	local value = UDim.new(0, radius)
	UI.MainCorner.CornerRadius = value
	for corner in pairs(Lib.BoundCorners) do
		if corner.Parent then
			corner.CornerRadius = value
		else
			Lib.BoundCorners[corner] = nil
		end
	end
end

function Lib.RegisterThemeImage(image)
	Lib.ImageTheme[image] = true
	image.ImageColor3 = Lib.Palette.Primary
end

function Lib.ResolveImage(value)
	local id = tonumber(value) and value or value:match("rbxassetid://(%d+)") or value:match("[?&]id=(%d+)") or value:match("/library/(%d+)") or value:match("/catalog/(%d+)")
	return id and ("rbxassetid://" .. id) or value, id
end

do
	local FontRoles = setmetatable({}, { __mode = "k" })
	local BoldFonts = {
		[Enum.Font.GothamBold] = true,
		[Enum.Font.SourceSansBold] = true,
		[Enum.Font.RobotoCondensed] = true,
		[Enum.Font.FredokaOne] = true
	}

	Lib.TextClasses = { TextLabel = true, TextButton = true, TextBox = true }

	function Lib.StyleFont(inst)
		local role = FontRoles[inst]
		if role == 0 then return end
		if not role then
			role = BoldFonts[inst.Font] and 2 or 1
			FontRoles[inst] = role
		end
		local face = role == 2 and State.CurrentBoldFace or State.CurrentRegularFace
		if face then
			inst.FontFace = face
		else
			inst.Font = role == 2 and State.CurrentBoldFont or State.CurrentRegularFont
		end
	end

	function Lib.PinFont(inst)
		FontRoles[inst] = 0
	end

	function Lib.FontRole(inst)
		local role = FontRoles[inst]
		if role == nil then return BoldFonts[inst.Font] and 2 or 1 end
		return role
	end
end

function Lib.Create(className, props)
	local inst = Instance.new(className)
	if props then
		for k, v in pairs(props) do
			if type(k) == "number" then
				v.Parent = inst
			elseif k ~= "Parent" then
				inst[k] = v
			end
		end
	end
	if State.CurrentRegularFont and Lib.TextClasses[className] then Lib.StyleFont(inst) end
	if props and props.Parent then inst.Parent = props.Parent end
	return inst
end

function Lib.Tween(obj, time, style, dir, props)
	local tween = Services.Tween:Create(obj, TweenInfo.new(time, style, dir), props)
	tween:Play()
	return tween
end

Lib.SearchIcon = "rbxassetid://10734943674"

function Lib.MakeSearchBox(parent, placeholder, position, size, delay, onChange)
	local holder = Lib.Create("Frame", {
		Size = size, Position = position, BackgroundColor3 = Color3.fromRGB(22, 22, 22), Parent = parent,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 7) })
	})
	Lib.RegisterThemeElement(holder, "BackgroundColor3", 0.7, true)

	local box = Lib.Create("TextBox", {
		Size = UDim2.new(1, -42, 1, 0), Position = UDim2.fromOffset(12, 0), BackgroundTransparency = 1, Text = "",
		PlaceholderText = placeholder, PlaceholderColor3 = Color3.fromRGB(110, 110, 110), TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Parent = holder
	})
	Lib.RegisterThemeText(box, "Primary")

	local icon = Lib.Create("ImageLabel", {
		Size = UDim2.fromOffset(14, 14), Position = UDim2.new(1, -26, 0.5, -7), BackgroundTransparency = 1,
		Image = Lib.SearchIcon, ImageTransparency = 0.3, ScaleType = Enum.ScaleType.Fit, Parent = holder
	})
	Lib.RegisterThemeImage(icon)

	local ticket = 0
	box:GetPropertyChangedSignal("Text"):Connect(function()
		local text = box.Text:match("^%s*(.-)%s*$")
		if delay <= 0 then return onChange(text) end
		ticket += 1
		local mine = ticket
		task.delay(delay, function()
			if mine == ticket then onChange(text) end
		end)
	end)
	return box, holder
end

Lib.ThemeCount = 0
Lib.Theme = {
	Base = Color3.fromRGB(18, 18, 18),
	Main = Color3.fromRGB(0, 0, 0),
	Card = Color3.fromRGB(15, 15, 15),
	Item = Color3.fromRGB(22, 22, 22)
}

Lib.Palette = {
	Primary = Color3.fromRGB(245, 245, 245),
	Secondary = Color3.fromRGB(145, 145, 145),
	SwitchOn = Color3.fromRGB(46, 213, 115),
	SwitchOff = Color3.fromRGB(38, 38, 38)
}

Lib.ThemePresets = {
	Color3.fromRGB(18, 18, 18), Color3.fromRGB(225, 29, 52), Color3.fromRGB(45, 125, 245),
	Color3.fromRGB(155, 100, 245), Color3.fromRGB(255, 75, 75), Color3.fromRGB(46, 213, 115),
	Color3.fromRGB(255, 205, 50), Color3.fromRGB(0, 225, 225), Color3.fromRGB(255, 130, 200),
	Color3.fromRGB(60, 75, 105), Color3.fromRGB(75, 45, 75), Color3.fromRGB(255, 255, 255)
}

Lib.HalloweenTheme = {
	Name = "Halloween",
	Halloween = true,
	Background = Color3.fromRGB(14, 9, 18),
	Surface = Color3.fromRGB(26, 16, 30),
	Item = Color3.fromRGB(40, 24, 42),
	Text = Color3.fromRGB(255, 238, 220),
	Muted = Color3.fromRGB(178, 142, 122),
	Accent = Color3.fromRGB(255, 122, 24),
	SwitchOff = Color3.fromRGB(60, 40, 54)
}

Lib.HalloweenWeb = "rbxassetid://78965354526256"
Lib.HalloweenHeader = { Logo = "rbxassetid://131395638826833", Icon = "rbxassetid://71225773476867" }
Lib.DefaultHeaderIcon = "rbxassetid://74736110237331"

function Lib.ThemeColor(factor)
	if factor == 0.5 then return Lib.Theme.Card end
	if factor == 0.7 then return Lib.Theme.Item end
	return Lib.Theme.Base
end

function Lib.Lighten(color, amount)
	return color:Lerp(Color3.new(1, 1, 1), amount)
end

function Lib.Luma(color)
	return color.R * 0.299 + color.G * 0.587 + color.B * 0.114
end

function Lib.ResolveTheme(index)
	if index == 0 then return Lib.HalloweenTheme end
	local presets = Lib.ThemePresets
	if index <= #presets then return presets[index] end
	return State.CustomThemes[index - #presets]
end

function Lib.RegisterThemeElement(element, propType, darkMultiplier, panel)
	local prop, factor = propType or "BackgroundColor3", darkMultiplier or 1
	element[prop] = Lib.ThemeColor(factor)
	UI.ThemeElements[element] = { prop, factor }
	Lib.ThemeCount = Lib.ThemeCount + 1
	if (factor == 0.5 or panel) and prop == "BackgroundColor3" and element.BackgroundTransparency == 0 then
		element.BackgroundTransparency = State.PanelTransparency / 100
		UI.PanelElements[element] = true
	end
	element.Destroying:Connect(function()
		UI.ThemeElements[element] = nil
		UI.PanelElements[element] = nil
		Lib.ThemeCount = Lib.ThemeCount - 1
	end)
end

function Lib.RegisterThemeText(element, role)
	UI.TextThemeElements[element] = role or "Primary"
	element.Destroying:Connect(function()
		UI.TextThemeElements[element] = nil
	end)
end

function Lib.RegisterSwitch(switchBg, getStateFunc, updateKnobFunc)
	table.insert(UI.Switches, { Bg = switchBg, GetState = getStateFunc, UpdateKnob = updateKnobFunc })
	switchBg.Destroying:Connect(function()
		for i, sw in ipairs(UI.Switches) do
			if sw.Bg == switchBg then
				table.remove(UI.Switches, i)
				break
			end
		end
	end)
end

function Lib.GetActiveSwitchColor()
	return Lib.Palette.SwitchOn
end

Lib.SwitchTweens = setmetatable({}, { __mode = "k" })
Lib.SwitchPos = { On = UDim2.new(1, -19, 0.5, -8), Off = UDim2.new(0, 3, 0.5, -8) }
Lib.SwitchSize = { Rest = UDim2.fromOffset(16, 16), Stretch = UDim2.fromOffset(19, 16), Press = UDim2.fromOffset(18, 16) }
Lib.SwitchInfo = {
	Move = TweenInfo.new(0.46, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	Shape = TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	Color = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Press = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
}

function Lib.StopSwitch(knob)
	local running = Lib.SwitchTweens[knob]
	if running then
		Lib.SwitchTweens[knob] = nil
		for i = 1, #running do running[i]:Cancel() end
	end
end

function Lib.SetSwitch(bg, knob, on, color, animate)
	Lib.StopSwitch(knob)
	local position = on and Lib.SwitchPos.On or Lib.SwitchPos.Off
	if not animate then
		bg.BackgroundColor3 = color
		knob.Position = position
		knob.Size = Lib.SwitchSize.Rest
		return
	end
	local service, info = Services.Tween, Lib.SwitchInfo
	knob.Size = Lib.SwitchSize.Stretch
	local tweens = {
		service:Create(bg, info.Color, { BackgroundColor3 = color }),
		service:Create(knob, info.Move, { Position = position }),
		service:Create(knob, info.Shape, { Size = Lib.SwitchSize.Rest })
	}
	Lib.SwitchTweens[knob] = tweens
	for i = 1, #tweens do tweens[i]:Play() end
end

function Lib.BindSwitchPress(bg, knob)
	bg.MouseButton1Down:Connect(function()
		Lib.StopSwitch(knob)
		local tween = Services.Tween:Create(knob, Lib.SwitchInfo.Press, { Size = Lib.SwitchSize.Press })
		Lib.SwitchTweens[knob] = { tween, Press = true }
		tween:Play()
	end)
	bg.MouseLeave:Connect(function()
		local running = Lib.SwitchTweens[knob]
		if running and running.Press then
			Lib.StopSwitch(knob)
			Services.Tween:Create(knob, Lib.SwitchInfo.Shape, { Size = Lib.SwitchSize.Rest }):Play()
		end
	end)
end

function Lib.ApplyPanelTransparency()
	local value = State.PanelTransparency / 100
	for element in pairs(UI.PanelElements) do
		element.BackgroundTransparency = value
	end
end

function Lib.ApplyHeader()
	UI.HeaderIcon.Visible = not State.HideLogo
	UI.HeaderLogo.Visible = not State.HideName
	UI.HeaderLogo.Position = UDim2.fromOffset(State.HideLogo and 14 or 66, 10)
end

function Lib.ApplyTheme(spec, instant)
	local theme, palette = Lib.Theme, Lib.Palette
	local light

	if typeof(spec) == "Color3" then
		local r, g, b = spec.R, spec.G, spec.B
		light = r > 0.9 and g > 0.9 and b > 0.9
		local isDefaultBlack = math.floor(r * 255) == 18 and math.floor(g * 255) == 18 and math.floor(b * 255) == 18

		State.ThemeColor = spec
		State.CustomTheme = nil
		theme.Base = spec

		if isDefaultBlack then
			theme.Main, theme.Card, theme.Item = Color3.fromRGB(0, 0, 0), Color3.fromRGB(15, 15, 15), Color3.fromRGB(22, 22, 22)
		elseif light then
			theme.Main, theme.Card, theme.Item = Color3.fromRGB(242, 242, 244), Color3.fromRGB(255, 255, 255), Color3.fromRGB(232, 234, 238)
		else
			local function Scale(k)
				return Color3.new(math.clamp(r * k, 0, 1), math.clamp(g * k, 0, 1), math.clamp(b * k, 0, 1))
			end
			if Lib.Luma(spec) > 0.65 then
				theme.Main, theme.Card, theme.Item = Scale(0.92), Scale(0.98), Scale(0.85)
			else
				theme.Main, theme.Card, theme.Item = Scale(0.45), Scale(0.65), Scale(0.85)
			end
		end

		palette.Primary = light and Color3.fromRGB(15, 15, 15) or Color3.fromRGB(245, 245, 245)
		palette.Secondary = light and Color3.fromRGB(85, 85, 85) or Color3.fromRGB(145, 145, 145)
		palette.SwitchOff = light and Color3.fromRGB(205, 205, 210) or Color3.fromRGB(38, 38, 38)
		palette.SwitchOn = light and Color3.fromRGB(20, 20, 20) or (isDefaultBlack and Color3.fromRGB(46, 213, 115) or spec)
	else
		light = Lib.Luma(spec.Background) > 0.6

		State.ThemeColor = spec.Accent
		State.CustomTheme = spec
		theme.Base, theme.Main, theme.Card, theme.Item = spec.Background, spec.Background, spec.Surface, spec.Item

		palette.Primary = spec.Text
		palette.Secondary = spec.Muted
		palette.SwitchOn = spec.Accent
		palette.SwitchOff = spec.SwitchOff
	end

	State.LightTheme = light

	if Lib.SetHalloweenDecor then
		Lib.SetHalloweenDecor(typeof(spec) == "table" and spec.Halloween == true)
	end

	if UI.Main then
		if instant then
			UI.Main.BackgroundColor3 = theme.Main
		else
			Lib.Tween(UI.Main, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = theme.Main })
		end
	end

	local halloween = typeof(spec) == "table" and spec.Halloween == true

	if UI.HeaderLogo then
		UI.HeaderLogo.Image = halloween and Lib.HalloweenHeader.Logo or (light and Lib.HeaderAssets.LogoLight or Lib.HeaderAssets.Logo)
	end

	if UI.HeaderIcon then
		UI.HeaderIcon.Image = halloween and Lib.HalloweenHeader.Icon or Lib.DefaultHeaderIcon
	end

	local animate = not instant and Lib.ThemeCount <= 150

	for element, data in pairs(UI.ThemeElements) do
		local color = Lib.ThemeColor(data[2])
		if animate then
			Lib.Tween(element, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { [data[1]] = color })
		else
			element[data[1]] = color
		end
	end

	for element, role in pairs(UI.TextThemeElements) do
		local color = role == "Primary" and palette.Primary or palette.Secondary
		if animate then
			Lib.Tween(element, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { TextColor3 = color })
		else
			element.TextColor3 = color
		end
	end

	for _, bars in pairs(UI.Graphs) do
		for _, bar in ipairs(bars) do
			bar.BackgroundColor3 = palette.Primary
		end
	end

	for image in pairs(Lib.ImageTheme) do
		image.ImageColor3 = palette.Primary
	end

	for _, hook in ipairs(Lib.ThemeHooks) do
		pcall(hook)
	end

	for _, sw in ipairs(UI.Switches) do
		local color = sw.GetState() and palette.SwitchOn or palette.SwitchOff
		if instant then
			sw.Bg.BackgroundColor3 = color
		else
			Lib.Tween(sw.Bg, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = color })
		end
	end

	if Lib.RecalculateNavPositions then
		Lib.RecalculateNavPositions()
	end
end


-- ══════════════════════════════════════════════════════════════════════════
--  GLASS BACKDROP · GLOBAL FONT
-- ══════════════════════════════════════════════════════════════════════════

do
	local users = 0

	local function Prepare(backdrop)
		if backdrop:FindFirstChild("GlassCorner") then return end
		Lib.BindCorner(backdrop, "GlassCorner")
		Lib.Create("UIGradient", {
			Name = "GlassSheen",
			Rotation = 90,
			Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(200, 200, 200)),
			Parent = backdrop
		})
	end

	local fitted = setmetatable({}, {__mode = "k"})

	local function Fit(backdrop)
		local update = fitted[backdrop]
		if not update then
			local window
			for _, child in ipairs(backdrop:GetChildren()) do
				if child:IsA("GuiObject") and child.AnchorPoint == Vector2.new(0.5, 0.5) and child.Size.X.Scale == 0 then
					window = child
					break
				end
			end
			if not window then return end
			local constraint = Instance.new("UISizeConstraint")
			constraint.Parent = window
			update = function()
				local size = backdrop.AbsoluteSize
				constraint.MaxSize = Vector2.new(math.max(size.X - 24, 160), math.max(size.Y - 24, 120))
			end
			fitted[backdrop] = update
			Lib.C(backdrop:GetPropertyChangedSignal("AbsoluteSize"), update)
		end
		update()
	end

	function Lib.GlassOpen(backdrop)
		users = users + 1
		Prepare(backdrop)
		Fit(backdrop)
		local light = State.LightTheme
		backdrop.BackgroundColor3 = light and Color3.new(1, 1, 1) or Lib.Theme.Main:Lerp(Color3.new(1, 1, 1), 0.2)
		backdrop.BackgroundTransparency = 1
		backdrop.Visible = true
		Lib.Tween(backdrop, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundTransparency = light and 0.3 or 0.4 })
	end

	function Lib.GlassClose(backdrop, onDone)
		users = math.max(users - 1, 0)
		Lib.Tween(backdrop, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, { BackgroundTransparency = 1 }).Completed:Connect(onDone)
	end
end

function Lib.ApplyGlobalFont(regularFont, boldFont, regularFace, boldFace)
	State.CurrentRegularFont = regularFont
	State.CurrentBoldFont = boldFont or regularFont
	State.CurrentRegularFace = regularFace
	State.CurrentBoldFace = boldFace
	if not UI.Screen then return end
	for _, inst in ipairs(UI.Screen:GetDescendants()) do
		if Lib.TextClasses[inst.ClassName] then Lib.StyleFont(inst) end
	end
end


-- ══════════════════════════════════════════════════════════════════════════
--  LANGUAGE (pluggable) · CLIPBOARD
-- ══════════════════════════════════════════════════════════════════════════


do
	-- Optional translation layer. In the original hub this holds a Russian dictionary.
	-- Here it is pluggable: Lib.SetTranslator({ ["Hello"] = "Привет" }) and every
	-- label created afterwards (Notify, tooltips, search) goes through Lib.Tr / Lib.Ru.
	local dictionary, active = nil, false

	function Lib.SetTranslator(map)
		dictionary = type(map) == "table" and map or nil
		active = dictionary ~= nil
	end

	function Lib.Ru(text)
		if dictionary and type(text) == "string" then return dictionary[text] or text end
		return text
	end

	function Lib.Tr(text)
		if active and type(text) == "string" then return dictionary[text] or text end
		return text
	end

		function Lib.Lower(text)
			if not text:find("[\128-\255]") then return text:lower() end
			local ok, result = pcall(function()
				local out = {}
				for _, cp in utf8.codes(text) do
					if cp >= 0x410 and cp <= 0x42F then
						cp = cp + 32
					elseif cp == 0x401 then
						cp = 0x451
					elseif cp < 128 then
						cp = string.byte(string.lower(string.char(cp)))
					end
					out[#out + 1] = utf8.char(cp)
				end
				return table.concat(out)
			end)
			return ok and result or text:lower()
		end

	function Lib.OrigText(inst)
		return inst.Text
	end
end

function Lib.CopyText(text)
	local copy = setclipboard or toclipboard or set_clipboard
	if not copy then return false end
	return (pcall(copy, text))
end


-- ══════════════════════════════════════════════════════════════════════════
--  NOTIFICATIONS
-- ══════════════════════════════════════════════════════════════════════════

Lib.NotifSounds = {
	Ping = { "rbxasset://sounds/electronicpingshort.wav", 0.6, 0.16, -30, -6, 2 },
	Blip = { "rbxasset://sounds/kerplunk.wav", 1.35, 0.2, -26, -4, 1 },
	Pop = { "rbxasset://sounds/snap.mp3", 0.55, 0.2, -30, -6, 2 },
	Tick = { "rbxasset://sounds/switch.ogg", 0.75, 0.32, -22, -3, 0 },
	Tap = { "rbxasset://sounds/clickfast.wav", 0.7, 0.3, -24, -4, 0 }
}

function Lib.PlayNotifSound(name)
	local preset = Lib.NotifSounds[name or State.NotifSound]
	if not preset or not UI.Screen then return end
	local sound, eq = Lib.NotifSound, Lib.NotifEq
	if not sound then
		sound = Instance.new("Sound")
		sound.Name = "NotifSound"
		eq = Instance.new("EqualizerSoundEffect")
		eq.Parent = sound
		sound.Parent = UI.Screen
		Lib.NotifSound, Lib.NotifEq = sound, eq
	end
	sound:Stop()
	sound.SoundId, sound.PlaybackSpeed, sound.Volume = preset[1], preset[2], preset[3]
	eq.HighGain, eq.MidGain, eq.LowGain = preset[4], preset[5], preset[6]
	sound:Play()
end
Lib.MiniOffset = 0
Lib.NotifSides = {}

function Lib.NotifLayout()
	local name = State.NotifPosition or "Bottom Right"
	local cached = Lib.NotifSides[name]
	if cached then return cached end
	local top = name:find("Top", 1, true) ~= nil
	local left = name:find("Left", 1, true) ~= nil
	local middle = name:find("Center", 1, true) ~= nil
	local sx = middle and 0.5 or (left and 0 or 1)
	local ox = middle and 0 or (left and 150 or -150)
	local hiddenX = middle and 0 or (left and -170 or 170)
	local bottomRight = not top and not left and not middle
	local layout = {}
	function layout.Rest(i)
		if top then return UDim2.new(sx, ox, 0, 94 + (i - 1) * 68) end
		return UDim2.new(sx, ox, 1, 30 - i * 68 - (bottomRight and Lib.MiniOffset or 0))
	end
	function layout.Hidden(i)
		if middle then
			return top and UDim2.new(0.5, 0, 0, -50) or UDim2.new(0.5, 0, 1, 70)
		end
		local rest = layout.Rest(i)
		return UDim2.new(sx, hiddenX, rest.Y.Scale, rest.Y.Offset)
	end
	Lib.NotifSides[name] = layout
	return layout
end

function Lib.Notify(options)
	if not State.NotificationsEnabled then return end
	if not UI.NotifContainer then return end

	local isWhite = State.LightTheme
	local bgColor = isWhite and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(14, 14, 14)
	local textColor = isWhite and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(250, 250, 250)
	local subTextColor = isWhite and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(140, 140, 140)

	local title = Lib.Tr(options.Title or "Notification")
	local text = Lib.Tr(options.Text or "")
	local duration = options.Duration or 3.5
	local userId = options.UserId
	local mode = State.NotifAnim or "Slide"
	Lib.PlayNotifSound()

	local notifFrame = Lib.Create("CanvasGroup", {
		Size = UDim2.fromOffset(260, 60),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = Lib.NotifLayout().Hidden(#UI.ActiveNotifs + 1),
		BackgroundColor3 = bgColor,
		BorderSizePixel = 0,
		Parent = UI.NotifContainer,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) })
	})

	local contentX = 12
	if userId then
		contentX = 52
		Lib.Create("ImageLabel", {
			Size = UDim2.fromOffset(36, 36),
			Position = UDim2.new(0, 8, 0.5, -18),
			BackgroundTransparency = 1,
			Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(userId) .. "&w=100&h=100",
			Parent = notifFrame,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
		})
	end

	Lib.Create("TextLabel", {
		Size = UDim2.new(1, -(contentX + 10), 0, 18),
		Position = UDim2.new(0, contentX, 0, 10),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = textColor,
		TextSize = 12,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = notifFrame
	})

	Lib.Create("TextLabel", {
		Size = UDim2.new(1, -(contentX + 10), 0, 16),
		Position = UDim2.new(0, contentX, 0, 28),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = subTextColor,
		TextSize = 11,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = notifFrame
	})

	table.insert(UI.ActiveNotifs, notifFrame)

	local function Rest(i)
		return Lib.NotifLayout().Rest(i)
	end

	local function RepositionNotifs(skip)
		for i, n in ipairs(UI.ActiveNotifs) do
			if n ~= skip then
				Lib.Tween(n, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Position = Rest(i) })
			end
		end
	end

	local rest = Rest(#UI.ActiveNotifs)
	local pop
	if mode == "Pop" then
		pop = Lib.Create("UIScale", { Scale = 0.55, Parent = notifFrame })
		notifFrame.Position = rest
		notifFrame.GroupTransparency = 1
		Lib.Tween(notifFrame, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { GroupTransparency = 0 })
		Lib.Tween(pop, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Scale = 1 })
		RepositionNotifs(notifFrame)
	elseif mode == "Drop" then
		notifFrame.Position = rest - UDim2.fromOffset(0, 70)
		notifFrame.GroupTransparency = 1
		Lib.Tween(notifFrame, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { GroupTransparency = 0 })
		Lib.Tween(notifFrame, 0.6, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, { Position = rest })
		RepositionNotifs(notifFrame)
	elseif mode == "Fade" then
		notifFrame.Position = rest + UDim2.fromOffset(0, 16)
		notifFrame.GroupTransparency = 1
		Lib.Tween(notifFrame, 0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, { GroupTransparency = 0, Position = rest })
		RepositionNotifs(notifFrame)
	else
		RepositionNotifs()
	end

	task.delay(duration, function()
		if not (notifFrame and notifFrame.Parent) then return end
		local out
		if mode == "Pop" then
			Lib.Tween(pop, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In, { Scale = 0.8 })
			out = Lib.Tween(notifFrame, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In, { GroupTransparency = 1 })
		elseif mode == "Drop" or mode == "Fade" then
			out = Lib.Tween(notifFrame, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {
				GroupTransparency = 1, Position = notifFrame.Position - UDim2.fromOffset(0, 16)
			})
		else
			out = Lib.Tween(notifFrame, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {
				Position = Lib.NotifLayout().Hidden(table.find(UI.ActiveNotifs, notifFrame) or 1)
			})
		end
		out.Completed:Connect(function()
			local idx = table.find(UI.ActiveNotifs, notifFrame)
			if idx then table.remove(UI.ActiveNotifs, idx) end
			notifFrame:Destroy()
			RepositionNotifs()
		end)
	end)
end


-- ══════════════════════════════════════════════════════════════════════════
--  CASCADE (card fade-in)
-- ══════════════════════════════════════════════════════════════════════════

do
	local Quad, Out = Enum.EasingStyle.Quad, Enum.EasingDirection.Out
	local active = setmetatable({}, { __mode = "k" })
	local STEP, TIME, CARDS, BUDGET, PER = 0.04, 0.32, 14, 650, 320

	local function Fade(inst, info)
		local goals
		if inst:IsA("GuiObject") then
			local value = inst.BackgroundTransparency
			if value < 1 then goals = { BackgroundTransparency = value } end
			if inst:IsA("CanvasGroup") then
				value = inst.GroupTransparency
				if value < 1 then
					goals = goals or {}
					goals.GroupTransparency = value
				end
			elseif inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
				value = inst.TextTransparency
				if value < 1 then
					goals = goals or {}
					goals.TextTransparency = value
				end
			elseif inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
				value = inst.ImageTransparency
				if value < 1 then
					goals = goals or {}
					goals.ImageTransparency = value
				end
			end
		elseif inst:IsA("UIStroke") then
			local value = inst.Transparency
			if value < 1 then goals = { Transparency = value } end
		end
		if goals then
			for prop in pairs(goals) do inst[prop] = 1 end
			Services.Tween:Create(inst, info, goals):Play()
		end
	end

	local function Ordered(parent)
		local items = {}
		for index, child in ipairs(parent:GetChildren()) do
			if child:IsA("GuiObject") and child.Visible then
				items[#items + 1] = { child, child.LayoutOrder, index }
			end
		end
		table.sort(items, function(a, b)
			if a[2] ~= b[2] then return a[2] < b[2] end
			return a[3] < b[3]
		end)
		return items
	end

	local function Targets(parent, out)
		local items = Ordered(parent)
		for i = 1, #items do
			if #out >= CARDS then return end
			local child = items[i][1]
			if child:GetAttribute("Cascade") then
				Targets(child, out)
			else
				out[#out + 1] = child
			end
		end
	end

	local function Scrolls(root)
		local out, queue, depth, head = {}, { root }, { [root] = 0 }, 1
		while head <= #queue and #out < 3 do
			local node = queue[head]
			head += 1
			for _, child in ipairs(node:GetChildren()) do
				if child:IsA("GuiObject") and child.Visible and not (child:IsA("CanvasGroup") and child.GroupTransparency > 0.98) then
					if child:IsA("ScrollingFrame") then
						if child.AbsoluteSize.X >= 300 then out[#out + 1] = child end
					elseif depth[node] < 4 and not child:IsA("GuiButton") then
						depth[child] = depth[node] + 1
						queue[#queue + 1] = child
					end
				end
			end
		end
		return out
	end

	function Lib.Cascade(root)
		if State.CascadeOff or not Lib.CascadeReady or not root.Parent then return end
		local targets = {}
		local scrolls = Scrolls(root)
		for i = 1, #scrolls do Targets(scrolls[i], targets) end
		local budget, index = BUDGET, 0
		for i = 1, #targets do
			local card = targets[i]
			if not active[card] then
				local descendants = card:GetDescendants()
				local count = #descendants
				if count <= PER and count <= budget then
					budget -= count
					active[card] = true
					local delay = index * STEP
					index += 1
					local info = TweenInfo.new(TIME, Quad, Out, 0, false, delay)
					Fade(card, info)
					for j = 1, count do Fade(descendants[j], info) end
					task.delay(delay + TIME + 0.05, function() active[card] = nil end)
				end
			end
		end
	end
end


-- ══════════════════════════════════════════════════════════════════════════
--  TAB SYSTEM · SKELETON SHIMMER
-- ══════════════════════════════════════════════════════════════════════════

function Lib.CreateTabSystem(section, sideBar, stateKey, onSwitch)
	local views, btns, icons, order, running = {}, {}, {}, {}, {}
	local SHOW = TweenInfo.new(0.36, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 0.05)
	local HIDE = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local REST = UDim2.new(0, 180, 0, 10)

	local function Tint(name, color, time)
		local icon = icons[name]
		if icon then Lib.Tween(icon, time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { ImageColor3 = color }) end
	end

	local function Play(view, info, goal)
		local old = running[view]
		if old then old:Cancel() end
		local tween = Services.Tween:Create(view, info, goal)
		running[view] = tween
		tween:Play()
		return tween
	end

	local function Switch(tabName)
		local previous = State[stateKey]
		if previous == tabName then return end
		State[stateKey] = tabName

		local isWhite = State.LightTheme
		local direction = (order[tabName] or 0) >= (order[previous] or 0) and 1 or -1
		local selColor = isWhite and Color3.fromRGB(15, 15, 15) or Color3.fromRGB(255, 255, 255)
		local unselColor = isWhite and Color3.fromRGB(110, 110, 110) or Color3.fromRGB(150, 150, 150)

		for name, view in pairs(views) do
			local isSel = (name == tabName)

			Lib.Tween(btns[name], 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
				TextColor3 = isSel and selColor or unselColor,
				BackgroundTransparency = isSel and (isWhite and 0.88 or 0.92) or 1
			})

			Tint(name, isSel and selColor or unselColor, 0.2)

			if isSel then
				local fresh = not view.Visible or view.GroupTransparency > 0.98
				if fresh then
					view.Position = UDim2.new(0, 180, 0, 10 + 14 * direction)
					view.GroupTransparency = 1
				end
				view.Visible = true
				Play(view, SHOW, { Position = REST, GroupTransparency = 0 })
				if fresh then Lib.Cascade(view) end
			elseif view.Visible then
				Play(view, HIDE, { Position = UDim2.new(0, 180, 0, 10 - 10 * direction), GroupTransparency = 1 }).Completed:Connect(function(state)
					if state == Enum.PlaybackState.Completed and State[stateKey] ~= name then view.Visible = false end
				end)
			end
		end

		if onSwitch then onSwitch(tabName) end
	end

	local function Make(name, posY, iconId)
		local isWhite = State.LightTheme
		local btn = Lib.Create("TextButton", {
			Size = UDim2.new(1, -30, 0, 34),
			Position = UDim2.new(0, 15, 0, posY),
			BackgroundColor3 = isWhite and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Text = name,
			TextColor3 = isWhite and Color3.fromRGB(110, 110, 110) or Color3.fromRGB(150, 150, 150),
			TextSize = 14,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = sideBar,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 7) }),
			Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 12) })
		})

		local view = Lib.Create("CanvasGroup", {
			Name = name,
			Size = UDim2.new(1, -190, 1, -20),
			Position = UDim2.new(0, 180, 0, 10),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = false,
			GroupTransparency = 1,
			Parent = section
		})

		views[name], btns[name], order[name] = view, btn, posY

		if iconId then
			local icon = Lib.Create("ImageLabel", {
				Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0, 0, 0.5, -8), BackgroundTransparency = 1,
				Image = "rbxassetid://" .. iconId, ImageColor3 = btn.TextColor3, ScaleType = Enum.ScaleType.Fit, Parent = btn
			})
			icons[name] = icon
			local function Place() icon.Position = UDim2.new(0, btn.TextBounds.X + 8, 0.5, -8) end
			btn:GetPropertyChangedSignal("TextBounds"):Connect(Place)
			Place()
		end

		btn.MouseEnter:Connect(function()
			local currentWhite = State.LightTheme
			if State[stateKey] ~= name then
				Tint(name, currentWhite and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(210, 210, 210), 0.15)
				Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
					TextColor3 = currentWhite and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(210, 210, 210),
					BackgroundTransparency = currentWhite and 0.92 or 0.96
				})
			end
		end)
		btn.MouseLeave:Connect(function()
			local currentWhite = State.LightTheme
			Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Size = UDim2.new(1, -30, 0, 34) })
			if State[stateKey] ~= name then
				Tint(name, currentWhite and Color3.fromRGB(110, 110, 110) or Color3.fromRGB(150, 150, 150), 0.15)
				Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
					TextColor3 = currentWhite and Color3.fromRGB(110, 110, 110) or Color3.fromRGB(150, 150, 150),
					BackgroundTransparency = 1
				})
			end
		end)
		btn.MouseButton1Down:Connect(function()
			Lib.PlayClick()
			Lib.Tween(btn, 0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Size = UDim2.new(1, -36, 0, 31) })
		end)
		btn.MouseButton1Up:Connect(function()
			Lib.Tween(btn, 0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Size = UDim2.new(1, -30, 0, 34) })
		end)
		btn.MouseButton1Click:Connect(function() Switch(name) end)

		return view
	end

	Lib.TabSystems[#Lib.TabSystems + 1] = { Key = stateKey, Switch = Switch, Order = order }

	return Switch, Make, views
end

Lib.Skeleton = {}
Lib.TabSystems = {}

do
	local Run, TweenService = Services.Run, Services.Tween
	local Quad, Out = Enum.EasingStyle.Quad, Enum.EasingDirection.Out
	local FADE_IN, FADE_OUT = TweenInfo.new(0.28, Quad, Out), TweenInfo.new(0.18, Quad, Out)
	local WHITE = Color3.new(1, 1, 1)
	local PERIOD, TRAVEL, START = 1.5, 2.6, -1.3
	local LINES = { 0.62, 0.84, 0.46, 0.74, 0.58, 0.8, 0.38 }
	local gradients, count, beat = {}, 0, nil

	local function Step()
		local offset = Vector2.new(START + TRAVEL * (os.clock() % PERIOD / PERIOD), 0)
		local index = 1
		while index <= count do
			local gradient = gradients[index]
			if gradient.Parent then
				gradient.Offset = offset
				index += 1
			else
				gradients[index] = gradients[count]
				gradients[count] = nil
				count -= 1
			end
		end
		if count == 0 and beat then
			beat:Disconnect()
			beat = nil
		end
	end

	function Lib.Skeleton.Attach(frame)
		local base = Lib.Theme.Item
		local peak = base:Lerp(Lib.Palette.Primary, State.LightTheme and 0.08 or 0.11)
		local gradient = Instance.new("UIGradient")
		gradient.Rotation = 16
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, base),
			ColorSequenceKeypoint.new(0.38, base),
			ColorSequenceKeypoint.new(0.5, peak),
			ColorSequenceKeypoint.new(0.62, base),
			ColorSequenceKeypoint.new(1, base)
		})
		gradient.Offset = Vector2.new(START, 0)
		gradient.Parent = frame
		frame.BackgroundColor3 = WHITE
		frame.BackgroundTransparency = 0
		count += 1
		gradients[count] = gradient
		if not beat then beat = Run.Heartbeat:Connect(Step) end
		return gradient
	end

	function Lib.Skeleton.Block(parent, size, position, radius)
		local frame = Instance.new("Frame")
		frame.BorderSizePixel = 0
		frame.Size = size
		frame.Position = position or UDim2.new()
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, radius or 6)
		corner.Parent = frame
		frame.Parent = parent
		Lib.Skeleton.Attach(frame)
		return frame
	end

	local function Card(parent, width, height, order)
		local card = Instance.new("Frame")
		card.Size = UDim2.fromOffset(width, height)
		card.BackgroundColor3 = Lib.Theme.Card
		card.BorderSizePixel = 0
		card.LayoutOrder = order
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = card
		card.Parent = parent
		local media = math.floor(height * 0.56)
		Lib.Skeleton.Block(card, UDim2.new(1, -16, 0, media), UDim2.fromOffset(8, 8), 6)
		Lib.Skeleton.Block(card, UDim2.new(0.72, 0, 0, 12), UDim2.fromOffset(10, media + 22), 4)
		Lib.Skeleton.Block(card, UDim2.new(0.46, 0, 0, 10), UDim2.fromOffset(10, media + 42), 4)
		Lib.Skeleton.Block(card, UDim2.new(1, -20, 0, 26), UDim2.new(0, 10, 1, -36), 6)
	end

	function Lib.Skeleton.Grid(anchor, cell, gap)
		local group = Instance.new("CanvasGroup")
		group.BackgroundTransparency = 1
		group.GroupTransparency = 1
		group.Position = anchor.Position
		group.Size = anchor.Size
		local layout = Instance.new("UIGridLayout")
		layout.CellSize = UDim2.fromOffset(cell.X, cell.Y)
		layout.CellPadding = UDim2.fromOffset(gap, gap)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = group
		local area = anchor.AbsoluteSize
		local width = area.X > 0 and area.X or 560
		local height = area.Y > 0 and area.Y or 420
		local columns = math.max(1, math.floor((width + gap) / (cell.X + gap)))
		local rows = math.clamp(math.ceil((height + gap) / (cell.Y + gap)), 1, 3)
		for index = 1, columns * rows do Card(group, cell.X, cell.Y, index) end
		group.Parent = anchor.Parent
		return group
	end

	function Lib.Skeleton.Pill(anchor)
		local group = Instance.new("CanvasGroup")
		group.BackgroundTransparency = 1
		group.GroupTransparency = 1
		group.AnchorPoint = anchor.AnchorPoint
		group.Position = anchor.Position
		group.Size = UDim2.fromOffset(110, 22)
		group.ZIndex = anchor.ZIndex
		Lib.Skeleton.Block(group, UDim2.fromScale(1, 1), UDim2.new(), 11)
		group.Parent = anchor.Parent
		return group
	end

	function Lib.Skeleton.Lines(anchor)
		local group = Instance.new("CanvasGroup")
		group.BackgroundTransparency = 1
		group.GroupTransparency = 1
		group.Size = UDim2.fromScale(1, 1)
		group.ZIndex = anchor.ZIndex + 3
		for index = 1, #LINES do
			Lib.Skeleton.Block(group, UDim2.new(LINES[index], -28, 0, 9), UDim2.fromOffset(14, 14 + (index - 1) * 20), 4)
		end
		group.Parent = anchor
		return group
	end

	function Lib.Skeleton.Watch(label, texts, build)
		local current
		local base = label.TextTransparency

		local function Drop()
			local old = current
			current = nil
			if not old then return end
			local tween = TweenService:Create(old, FADE_OUT, { GroupTransparency = 1 })
			tween.Completed:Connect(function() old:Destroy() end)
			tween:Play()
		end

		local function Sync()
			local loading = label.Visible and (texts[label.Text] or texts[Lib.OrigText(label)])
			if loading then
				label.TextTransparency = 1
				if not current then
					current = build()
					TweenService:Create(current, FADE_IN, { GroupTransparency = 0 }):Play()
				end
			else
				label.TextTransparency = base
				Drop()
			end
		end

		label:GetPropertyChangedSignal("Visible"):Connect(Sync)
		label:GetPropertyChangedSignal("Text"):Connect(Sync)
	end
end


-- ══════════════════════════════════════════════════════════════════════════
--  HTTP · VERSION CHECK · WEB IMAGES
-- ══════════════════════════════════════════════════════════════════════════

function Lib.Timed(fn, limit)
	local done, ok, result = false, false, nil
	task.spawn(function()
		ok, result = pcall(fn)
		done = true
	end)
	local started = os.clock()
	while not done and os.clock() - started < limit do task.wait(0.05) end
	if not done then return false, "timed out" end
	return ok, result
end

function API.HTTPRequest(url, accept, extra)
	local agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
	local headerSets = {
		{ ["User-Agent"] = agent, Accept = accept },
		{ ["User-Agent"] = agent, Accept = accept, ["Roblox-Place-Id"] = "", ["Roblox-Game-Id"] = "", ["Roblox-Universe-Id"] = "" }
	}
	if extra then
		for _, headers in ipairs(headerSets) do
			for name, value in pairs(extra) do headers[name] = value end
		end
	end
	local req = (syn and syn.request) or http_request or request or (fluxus and fluxus.request) or (http and http.request)
	local hasGet, httpGet = pcall(function() return game.HttpGet end)
	hasGet = hasGet and type(httpGet) == "function" and not extra
	local reasons = {}

	local function Note(host, text)
		reasons[#reasons + 1] = host .. ": " .. tostring(text):sub(1, 140)
	end

	local function Accept(host, body)
		if type(body) ~= "string" or body == "" then
			Note(host, "empty body")
			return nil
		end
		if body:find("In experience search is denied", 1, true) then
			Note(host, "in-experience search denied")
			return nil
		end
		local head = body:sub(1, 120):lower()
		if head:find("<!doctype", 1, true) or head:find("<html", 1, true) then
			Note(host, "HTML response (blocked or rate limited)")
			return nil
		end
		return body
	end

	local function Attempt(target)
		local host = target:match("//([^/]+)") or target
		if type(req) == "function" then
			for _, headers in ipairs(headerSets) do
				local ok, res = Lib.Timed(function()
					return req({ Url = target, Method = "GET", Headers = headers })
				end, 8)
				if not ok then
					Note(host, "request error " .. tostring(res))
				elseif type(res) ~= "table" then
					Note(host, "empty response")
				elseif res.StatusCode and (res.StatusCode < 200 or res.StatusCode >= 300) then
					local body = Accept(host, res.Body)
					if body then Note(host, "HTTP " .. res.StatusCode) end
				else
					local body = Accept(host, res.Body)
					if body then return body end
				end
			end
		end
		if hasGet then
			local ok, body = Lib.Timed(function() return game:HttpGet(target) end, 8)
			if ok then
				local accepted = Accept(host, body)
				if accepted then return accepted end
			else
				Note(host, "HttpGet error " .. tostring(body))
			end
		end
		if type(req) ~= "function" and not hasGet then
			Note(host, "executor has no HTTP function")
		end
	end

	local body = Attempt(url)
	if body then return true, body end

	if url:find("roblox%.com") then
		body = Attempt((url:gsub("roblox%.com", "roproxy.com")))
		if body then return true, body end
	end

	return false, nil, table.concat(reasons, "; ")
end

do
	local V = Lib.Version
	local HttpService = Services.HttpService

	local function Parts(value)
		local out = {}
		for number in tostring(value):gmatch("%d+") do out[#out + 1] = tonumber(number) end
		return out
	end

	local function IsNewer(a, b)
		local x, y = Parts(a), Parts(b)
		for i = 1, math.max(#x, #y) do
			local p, q = x[i] or 0, y[i] or 0
			if p ~= q then return p > q end
		end
		return false
	end

	local function Announce()
		if V.Status == "outdated" and V.Started and not V.Notified then
			V.Notified = true
			Lib.Notify({ Title = "Update Available", Text = "New version: V" .. V.Latest, Duration = 6 })
		end
	end

	local function Publish(status, latest)
		V.Status, V.Latest = status, latest
		for i = #V.Listeners, 1, -1 do task.spawn(V.Listeners[i], status, latest) end
		Announce()
	end

	function V.Listen(callback)
		V.Listeners[#V.Listeners + 1] = callback
		task.spawn(callback, V.Status, V.Latest)
		return function()
			local index = table.find(V.Listeners, callback)
			if index then table.remove(V.Listeners, index) end
		end
	end

	function V.Check()
		if V.Busy then return end
		if not V.Url then
			Publish("latest", V.Current)
			return
		end
		V.Busy = true
		Publish("checking")
		task.spawn(function()
			local status, latest = "failed", nil
			local ok, body = API.HTTPRequest(V.Url .. "?t=" .. os.time(), "application/json")
			if ok then
				local decoded, data = pcall(HttpService.JSONDecode, HttpService, body)
				local raw = decoded and type(data) == "table" and data.version
				if raw then
					latest = tostring(raw):gsub("^[vV]", "")
					status = IsNewer(latest, V.Current) and "outdated" or "latest"
				end
			end
			V.Busy = false
			if not State.Unloaded then Publish(status, latest) end
		end)
	end

	function V.Start()
		V.Started = true
		Announce()
	end
end

do
	local ROOT = Lib.Config.Folder
	local FOLDER = ROOT .. "/img"
	local PLACEHOLDER = "rbxassetid://113533839488998"
	local ACCEPT = "image/png,image/jpeg;q=0.9,*/*;q=0.1"
	local MAX_ACTIVE, MAX_FILES, RETRY_AFTER = 6, 400, 20
	local EXTENSIONS = { "png", "jpg" }
	local HttpService, Run = Services.HttpService, Services.Run
	local supported = type(writefile) == "function" and type(isfile) == "function" and type(getcustomasset) == "function"
	local ready, failed, waiting, queue = {}, {}, {}, {}
	local active = 0

	if supported and type(makefolder) == "function" and type(isfolder) == "function" then
		pcall(function()
			if not isfolder(ROOT) then makefolder(ROOT) end
			if not isfolder(FOLDER) then makefolder(FOLDER) end
		end)
		if type(listfiles) == "function" and type(delfile) == "function" then
			task.spawn(pcall, function()
				local files = listfiles(FOLDER)
				for index = MAX_FILES + 1, #files do pcall(delfile, files[index]) end
			end)
		end
	end

	local function Hash(text)
		local h = 5381
		for i = 1, #text do h = (h * 33 + text:byte(i)) % 4294967296 end
		return h
	end

	local function Extension(body)
		if body:sub(1, 8) == "\137PNG\r\n\26\n" then return "png" end
		if body:sub(1, 3) == "\255\216\255" then return "jpg" end
	end

	local function Sources(url)
		local host, path = url:match("^https?://([^/]+)(/.*)$")
		host = host and host:lower() or ""
		local list = {}
		if host:find("rbxcdn%.com$") then
			local png = url:gsub("/[Ww]ebp/", "/Png/")
			if png ~= url then list[#list + 1] = png end
		end
		list[#list + 1] = url
		list[#list + 1] = "https://wsrv.nl/?w=640&output=jpg&url=" .. HttpService:UrlEncode(url)
		return list
	end

	local function Download(url)
		local key = FOLDER .. "/" .. Hash(url)
		local path
		for _, ext in ipairs(EXTENSIONS) do
			if isfile(key .. "." .. ext) then
				path = key .. "." .. ext
				break
			end
		end
		if not path then
			for _, source in ipairs(Sources(url)) do
				local ok, body = API.HTTPRequest(source, ACCEPT)
				local ext = ok and type(body) == "string" and Extension(body)
				if ext then
					path = key .. "." .. ext
					if not pcall(writefile, path, body) then return nil end
					break
				end
			end
			if not path then return nil end
		end
		local ok, asset = pcall(getcustomasset, path)
		return ok and asset or nil
	end

	local function Spin(label)
		if label:FindFirstChild("SHSkeleton") then return end
		local fill = Instance.new("Frame")
		fill.Name = "SHSkeleton"
		fill.Size = UDim2.fromScale(1, 1)
		fill.BorderSizePixel = 0
		fill.ZIndex = 2
		local corner = label:FindFirstChildOfClass("UICorner")
		if corner then corner:Clone().Parent = fill end
		fill.Parent = label
		Lib.Skeleton.Attach(fill)
	end

	local function Unspin(label)
		local fill = label:FindFirstChild("SHSkeleton")
		if fill then fill:Destroy() end
	end

	local function Finish(url, labels, asset)
		waiting[url] = nil
		if asset then ready[url] = asset else failed[url] = os.clock() + RETRY_AFTER end
		for _, label in ipairs(labels) do
			if label.Parent then
				Unspin(label)
				label.Image = asset or PLACEHOLDER
			end
		end
	end

	local function Pump()
		while active < MAX_ACTIVE and #queue > 0 do
			local url = table.remove(queue, 1)
			local labels = waiting[url]
			local alive = false
			for _, label in ipairs(labels) do
				if label.Parent then
					alive = true
					break
				end
			end
			if alive then
				active += 1
				task.spawn(function()
					local ok, asset = pcall(Download, url)
					Finish(url, labels, ok and asset or nil)
					active -= 1
					Pump()
				end)
			else
				waiting[url] = nil
			end
		end
	end

	function Lib.LoadWebImage(label, url)
		if type(url) ~= "string" or url == "" then
			Unspin(label)
			label.Image = PLACEHOLDER
			return
		end
		if url:sub(1, 2) == "//" then url = "https:" .. url end
		if not url:find("^https?://") then
			Unspin(label)
			label.Image = url
			return
		end
		local asset = ready[url]
		if asset then
			Unspin(label)
			label.Image = asset
			return
		end
		local retry = failed[url]
		if not supported or (retry and retry > os.clock()) then
			Unspin(label)
			label.Image = PLACEHOLDER
			return
		end
		label.Image = ""
		Spin(label)
		local labels = waiting[url]
		if labels then
			labels[#labels + 1] = label
			return
		end
		waiting[url] = { label }
		queue[#queue + 1] = url
		Pump()
	end
end


-- ══════════════════════════════════════════════════════════════════════════
--  WINDOW · mount, layout, open/close animation
-- ══════════════════════════════════════════════════════════════════════════

function Lib.MountGui(gui)
	if syn and syn.protect_gui then pcall(syn.protect_gui, gui) end
	for _, resolve in ipairs({ function() return gethui() end, function() return game:GetService("CoreGui") end }) do
		local ok = pcall(function() gui.Parent = resolve() end)
		if ok and gui.Parent then return end
	end
	gui.Parent = App.Player:WaitForChild("PlayerGui")
end

Lib.DragOffset = Vector2.zero

function Lib.MainLayout()
	local original = State.OriginalSize
	local s = Lib.MenuBaseScale or 1
	local offset = State.Maximized and Vector2.zero or Lib.DragOffset
	if State.Minimized then
		if State.Maximized then
			return UDim2.new(1 / s, -30 / s, 0, 58), UDim2.new(0.5, 0, 0, 15 + 29 * s)
		end
		return UDim2.new(original.X.Scale, original.X.Offset, 0, 58), UDim2.new(0.5, offset.X, 0.5, (29 - original.Y.Offset / 2) * s + offset.Y)
	end
	if State.Maximized then
		return UDim2.new(1 / s, -30 / s, 1 / s, -30 / s), UDim2.new(0.5, 0, 0.5, 0)
	end
	return original, UDim2.new(0.5, offset.X, 0.5, offset.Y)
end

function Lib.WindowBusy()
	return State.MenuHiding or (Lib.WindowTween ~= nil and Lib.WindowTween.PlaybackState == Enum.PlaybackState.Playing)
end

function Lib.ApplyWindowState()
	local minimized = State.Minimized
	State.WindowAnimId = (State.WindowAnimId or 0) + 1
	local id = State.WindowAnimId
	local size, position = Lib.MainLayout()
	if not minimized then
		UI.TopNavContainer.Visible = true
		UI.ContentArea.Visible = true
	end
	local tween = Lib.Tween(UI.Main, 0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, { Size = size, Position = position })
	Lib.WindowTween = tween
	Lib.Tween(UI.TopNavContainer, 0.38, Enum.EasingStyle.Quint, minimized and Enum.EasingDirection.In or Enum.EasingDirection.Out, {
		Position = Lib.NavPosition(minimized and -44 or 11)
	})
	if minimized then
		tween.Completed:Connect(function()
			if State.WindowAnimId == id and State.Minimized then
				UI.TopNavContainer.Visible = false
				UI.ContentArea.Visible = false
			end
		end)
	end
end

function Lib.ToggleMenu(force)
	local show = force
	if show == nil then show = (not UI.Main.Visible) or State.MenuHiding end
	State.MenuToken = (State.MenuToken or 0) + 1
	local token = State.MenuToken
	local scale, button, main = UI.MainScale, UI.SHToggleButton, UI.Main
	if not scale or not button then
		main.Visible = show
		return
	end
	local base = Lib.MenuBaseScale or 1
	local size, target = Lib.MainLayout()
	local mode = State.MenuAnim
	local center = button.AbsolutePosition + button.AbsoluteSize / 2
	local origin = UDim2.fromOffset(center.X, center.Y)
	local below = UDim2.new(target.X.Scale, target.X.Offset, target.Y.Scale, target.Y.Offset + UI.Screen.AbsoluteSize.Y)
	local line = UDim2.new(size.X.Scale, size.X.Offset, 0, 4)
	local quint = Enum.EasingStyle.Quint

	local function Finish()
		if State.MenuToken ~= token then return end
		main.Visible = false
		State.MenuHiding = false
		scale.Scale = base
		main.Size, main.Position = Lib.MainLayout()
	end

	local function Chain(first, nextStage)
		Lib.WindowTween = first
		first.Completed:Connect(function()
			if State.MenuToken == token then nextStage() end
		end)
	end

	if show then
		State.MenuHiding = false
		if not State.Minimized then UI.ContentArea.Visible = true end
		if mode == "Slide Up" then
			scale.Scale = base * 0.9
			main.Size, main.Position = size, below
			main.Visible = true
			Lib.WindowTween = Lib.Tween(main, 0.6, quint, Enum.EasingDirection.Out, { Position = target })
			Lib.Tween(scale, 0.6, quint, Enum.EasingDirection.Out, { Scale = base })
		elseif mode == "Unfold" then
			scale.Scale = base
			main.Size, main.Position = UDim2.fromOffset(0, 4), target
			main.Visible = true
			Chain(Lib.Tween(main, 0.3, quint, Enum.EasingDirection.Out, { Size = line }), function()
				Lib.WindowTween = Lib.Tween(main, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Size = size })
			end)
		else
			scale.Scale = base * 0.05
			main.Size, main.Position = size, origin
			main.Visible = true
			Lib.WindowTween = Lib.Tween(main, 0.5, quint, Enum.EasingDirection.Out, { Position = target })
			Lib.Tween(scale, 0.5, quint, Enum.EasingDirection.Out, { Scale = base })
		end
		return
	end

	State.MenuHiding = true
	UI.ContentArea.Visible = false
	if mode == "Slide Up" then
		Lib.WindowTween = Lib.Tween(main, 0.45, quint, Enum.EasingDirection.In, { Position = below })
		Lib.Tween(scale, 0.45, quint, Enum.EasingDirection.In, { Scale = base * 0.9 }).Completed:Connect(Finish)
	elseif mode == "Unfold" then
		Chain(Lib.Tween(main, 0.3, quint, Enum.EasingDirection.In, { Size = line }), function()
			local last = Lib.Tween(main, 0.22, quint, Enum.EasingDirection.In, { Size = UDim2.fromOffset(0, 4) })
			Lib.WindowTween = last
			last.Completed:Connect(Finish)
		end)
	else
		Lib.WindowTween = Lib.Tween(main, 0.34, quint, Enum.EasingDirection.In, { Position = origin })
		Lib.Tween(scale, 0.34, quint, Enum.EasingDirection.In, { Scale = base * 0.05 }).Completed:Connect(Finish)
	end
end


Lib.FeatureToggles = {}

function Lib.Unload()
	if State.Unloaded then return end
	State.Unloaded = true

	for _, title in ipairs(Lib.FeatureToggles) do
		local control = Lib.ToggleControls[title]
		if control and control.Get() then pcall(control.Set, false) end
	end

	for _, hook in ipairs(Lib.UnloadHooks) do pcall(hook) end

	for _, connection in ipairs(Lib.Conns) do connection:Disconnect() end
	table.clear(Lib.Conns)
	ClickSound:Destroy()
end

function Lib.StartStats()
	local lastT, frames = tick(), 0
	Lib.C(Services.Run.RenderStepped, function()
		frames = frames + 1
		local curT = tick()
		if curT - lastT >= 1 then
			local fps = math.floor(frames / (curT - lastT))
			local okPing, ping = pcall(function() return math.floor(Services.Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
			ping = okPing and ping or 0
			local plrs = #Services.Players:GetPlayers()

			Lib.Stats.FPS, Lib.Stats.Ping, Lib.Stats.Players = fps, ping, plrs
			for i = 1, #Lib.StatsTick do pcall(Lib.StatsTick[i]) end

			frames, lastT = 0, curT
		end
	end)
end

function Lib.NavPosition(y, align)
	if State.NavStyle == "Icon Rail" then
		return UDim2.fromOffset(y < 0 and -(Lib.NavRailWidth + 8) or 0, 58)
	end
	align = align or State.NavAlign
	if align == "Left" then
		return UDim2.new(0, math.min(372, State.OriginalSize.X.Offset - 270), 0, y)
	elseif align == "Right" then
		return UDim2.new(1, -258, 0, y)
	end
	return UDim2.new(0.5, 0, 0, y)
end

function Lib.ApplyLayout(width, height, align)
	local scale = Lib.MenuBaseScale or 1
	local view = UI.Screen.AbsoluteSize
	width = math.clamp(math.floor(tonumber(width) or State.OriginalSize.X.Offset), 560, math.max(560, math.min(1500, view.X / scale - 20)))
	height = math.clamp(math.floor(tonumber(height) or State.OriginalSize.Y.Offset), 380, math.max(380, math.min(950, view.Y / scale - 20)))
	State.NavAlign = (align == "Left" or align == "Right") and align or "Center"
	State.OriginalSize = UDim2.fromOffset(width, height)
	UI.Main.Size, UI.Main.Position = Lib.MainLayout()
	UI.TopNavContainer.Position = Lib.NavPosition(State.Minimized and -44 or 11)
end

function Lib.FitMenuScale(cap)
	local view, size = UI.Screen.AbsoluteSize, State.OriginalSize
	local fit = math.min((view.X - 24) / math.max(size.X.Offset, 1), (view.Y - 24) / math.max(size.Y.Offset, 1))
	return math.clamp(math.min(fit, math.clamp(view.Y / 1080, 0.8, 1.4), cap or math.huge), 0.35, 1.4)
end


-- ══════════════════════════════════════════════════════════════════════════
--  HOVER STROKE
-- ══════════════════════════════════════════════════════════════════════════

function Lib.HoverStroke(card, stroke)
	stroke = stroke or card:FindFirstChildOfClass("UIStroke")
	card.MouseEnter:Connect(function() Lib.Tween(stroke, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Transparency = 0.6 }) end)
	card.MouseLeave:Connect(function() Lib.Tween(stroke, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Transparency = 0.88 }) end)
end


-- ══════════════════════════════════════════════════════════════════════════
--  CONTROLS · group, toggle, slider, choice, colour, button
-- ══════════════════════════════════════════════════════════════════════════

do
	Lib.SearchItems, Lib.SearchGroups, Lib.SearchScrolls = {}, {}, {}

	function Lib.SearchAdd(card, item, title)
		if not Lib.SearchGroups[card] then return end
		local list = Lib.SearchItems
		local index = #list + 1
		list[index] = { Item = item, Parent = card, Title = Lib.Lower(title), Alt = Lib.Lower(Lib.Ru(title)) }
		item.LayoutOrder = index
	end

	function Lib.CreateFeatureGroup(parentScroll, title, layoutOrder)
		local GroupContainer = Lib.Create("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = layoutOrder,
			Parent = parentScroll
		})

		local grpTitle = Lib.Create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.new(0, 4, 0, 0),
			BackgroundTransparency = 1,
			Text = title,
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 14,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = GroupContainer
		})
		Lib.RegisterThemeText(grpTitle, "Primary")

		local grp = Lib.Create("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Position = UDim2.new(0, 0, 0, 26),
			BackgroundColor3 = Color3.fromRGB(15, 15, 15),
			Parent = GroupContainer,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
			Lib.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder })
		})
		Lib.RegisterThemeElement(grp, "BackgroundColor3", 0.5)
		if Lib.SearchScrolls[parentScroll] then Lib.SearchGroups[grp] = true end
		return grp
	end

	function Lib.CreateSettingToggleItem(parentCard, title, desc, defaultState, onToggle, isLast)
		local Item = Lib.Create("Frame", {
			Size = UDim2.new(1, 0, 0, 50),
			BackgroundTransparency = 1,
			Parent = parentCard
		})

		local titleLabel = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -70, 0, 20),
			Position = UDim2.new(0, 14, 0, 7),
			BackgroundTransparency = 1,
			Text = title,
			TextColor3 = Color3.fromRGB(240, 240, 240),
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = Item
		})
		Lib.RegisterThemeText(titleLabel, "Primary")

		local descLabel = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -70, 0, 16),
			Position = UDim2.new(0, 14, 0, 26),
			BackgroundTransparency = 1,
			Text = desc,
			TextColor3 = Color3.fromRGB(130, 130, 130),
			TextSize = 11,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = Item
		})
		Lib.RegisterThemeText(descLabel, "Secondary")

		local inactiveBg = Lib.Palette.SwitchOff
		local activeBg = Lib.GetActiveSwitchColor()

		local SwitchBg = Lib.Create("TextButton", {
			Size = UDim2.fromOffset(40, 22),
			Position = UDim2.new(1, -54, 0.5, -11),
			BackgroundColor3 = defaultState and activeBg or inactiveBg,
			Text = "",
			AutoButtonColor = false,
			Parent = Item,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
		})

		local SwitchKnob = Lib.Create("Frame", {
			Size = UDim2.fromOffset(16, 16),
			Position = defaultState and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Parent = SwitchBg,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
		})

		if not isLast then
			Lib.Create("Frame", {
				Size = UDim2.new(1, -28, 0, 1),
				Position = UDim2.new(0, 14, 1, -1),
				BackgroundColor3 = Color3.fromRGB(25, 25, 25),
				BorderSizePixel = 0,
				Parent = Item
			})
		end

		local state = defaultState
		local function UpdateSwitchVisual()
			Lib.SetSwitch(SwitchBg, SwitchKnob, state, state and Lib.GetActiveSwitchColor() or Lib.Palette.SwitchOff, true)
		end

		Lib.BindSwitchPress(SwitchBg, SwitchKnob)
		Lib.RegisterSwitch(SwitchBg, function() return state end, UpdateSwitchVisual)

		Lib.ToggleControls[title] = {
			Item = Item,
			Get = function() return state end,
			Set = function(value)
				if state == value then return end
				state = value
				UpdateSwitchVisual()
				onToggle(state)
				local hook = Lib.ToggleChanged
				if hook then hook(title, state) end
			end
		}

		SwitchBg.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			state = not state
			UpdateSwitchVisual()
			onToggle(state)
			local hook = Lib.ToggleChanged
			if hook then hook(title, state) end
			Lib.Notify({ Title = title, Text = state and "Enabled" or "Disabled" })
		end)

		Lib.SearchAdd(parentCard, Item, title)
		return Item
	end

	function Lib.CreateSettingSliderItem(parentCard, title, desc, minVal, maxVal, defaultVal, onChange, isLast, suffix, step)
		local digits = step and #(tostring(step):match("%.(%d+)") or "") or 0
		local function Fmt(value)
			if not step then return tostring(math.floor(value)) end
			return string.format("%." .. digits .. "f", value)
		end

		local Item = Lib.Create("Frame", {
			Size = UDim2.new(1, 0, 0, 50),
			BackgroundTransparency = 1,
			Parent = parentCard
		})

		local titleLabel = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -190, 0, 20),
			Position = UDim2.new(0, 14, 0, 7),
			BackgroundTransparency = 1,
			Text = title,
			TextColor3 = Color3.fromRGB(240, 240, 240),
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = Item
		})
		Lib.RegisterThemeText(titleLabel, "Primary")

		local DescLabel = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -190, 0, 16),
			Position = UDim2.new(0, 14, 0, 26),
			BackgroundTransparency = 1,
			Text = desc .. " (" .. Fmt(defaultVal) .. (suffix or "") .. ")",
			TextColor3 = Color3.fromRGB(130, 130, 130),
			TextSize = 11,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = Item
		})
		Lib.RegisterThemeText(DescLabel, "Secondary")

		local SliderContainer = Lib.Create("Frame", {
			Size = UDim2.fromOffset(130, 24),
			Position = UDim2.new(1, -144, 0.5, -12),
			BackgroundTransparency = 1,
			Parent = Item
		})

		local SliderTrack = Lib.Create("Frame", {
			Size = UDim2.new(1, 0, 0, 4),
			Position = UDim2.new(0, 0, 0.5, -2),
			BackgroundColor3 = Color3.fromRGB(35, 35, 35),
			BorderSizePixel = 0,
			Parent = SliderContainer,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
		})

		local SliderFill = Lib.Create("Frame", {
			Size = UDim2.new(0, 0, 1, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			Parent = SliderTrack,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
		})

		local SliderKnob = Lib.Create("Frame", {
			Size = UDim2.fromOffset(20, 12),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			Parent = SliderTrack,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
		})

		if not isLast then
			Lib.Create("Frame", {
				Size = UDim2.new(1, -28, 0, 1),
				Position = UDim2.new(0, 14, 1, -1),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 0.9,
				BorderSizePixel = 0,
				Parent = Item
			})
		end

		local dragging = false

		local function UpdateSlider(inputPos)
			local trackAbsPos = SliderTrack.AbsolutePosition.X
			local trackAbsSize = SliderTrack.AbsoluteSize.X
			local relX = math.clamp((inputPos.X - trackAbsPos) / trackAbsSize, 0, 1)
			local currentVal = math.floor(minVal + (maxVal - minVal) * relX)
			local shown = relX
			if step then
				currentVal = tonumber(Fmt(math.clamp(minVal + math.floor((maxVal - minVal) * relX / step + 0.5) * step, minVal, maxVal)))
				shown = math.clamp((currentVal - minVal) / (maxVal - minVal), 0, 1)
			end

			SliderKnob.Position = UDim2.new(shown, 0, 0.5, 0)
			SliderFill.Size = UDim2.new(shown, 0, 1, 0)
			DescLabel.Text = desc .. " (" .. Fmt(currentVal) .. (suffix or "") .. ")"
			onChange(currentVal)
		end

		local function Display(value)
			local percent = math.clamp((value - minVal) / (maxVal - minVal), 0, 1)
			SliderKnob.Position = UDim2.new(percent, 0, 0.5, 0)
			SliderFill.Size = UDim2.new(percent, 0, 1, 0)
			DescLabel.Text = desc .. " (" .. Fmt(value) .. (suffix or "") .. ")"
		end

		Display(defaultVal)
		Lib.SliderControls[title] = function(value)
			Display(value)
			onChange(value)
		end

		local TriggerBtn = Lib.Create("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = "",
			Parent = SliderContainer
		})

		TriggerBtn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				UpdateSlider(input.Position)
			end
		end)

		Lib.C(Services.UserInputService.InputChanged, function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				UpdateSlider(input.Position)
			end
		end)

		Lib.C(Services.UserInputService.InputEnded, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)

		Lib.SearchAdd(parentCard, Item, title)
		return Item
	end

	function Lib.CreateSettingChoiceItem(parentCard, title, options, default, onChange, isLast, multi)
		local entries = {}
		for i, option in ipairs(options) do
			entries[i] = type(option) == "table" and option or { option, option }
		end
		local cycle = not multi and #entries > 4
		local selected, current = {}, entries[1][2]
		if multi then
			for _, value in ipairs(default or {}) do selected[value] = true end
		elseif default ~= nil then
			current = default
		end

		local Item = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 46), BackgroundTransparency = 1, Parent = parentCard })

		local titleLabel = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -28, 1, 0),
			Position = UDim2.fromOffset(14, 0),
			BackgroundTransparency = 1,
			Text = title,
			TextColor3 = Color3.fromRGB(240, 240, 240),
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = Item
		})
		Lib.RegisterThemeText(titleLabel, "Primary")

		local holder = Lib.Create("Frame", {
			Size = UDim2.fromOffset(0, 24),
			AutomaticSize = Enum.AutomaticSize.X,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -14, 0.5, 0),
			BackgroundTransparency = 1,
			Parent = Item,
			Lib.Create("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center
			})
		})

		local pills = {}

		local function Active(value)
			if multi then return selected[value] == true end
			return current == value
		end

		local function Label(value)
			for _, entry in ipairs(entries) do
				if entry[2] == value then return entry[1] end
			end
			return tostring(value)
		end

		local function Snapshot()
			local copy = {}
			for key in pairs(selected) do copy[key] = true end
			return copy
		end

		local function Paint()
			if cycle then
				pills[1].Text = Label(current)
				return
			end
			local on, off = Lib.Palette.SwitchOn, Lib.Palette.SwitchOff
			for i, pill in ipairs(pills) do
				local active = Active(entries[i][2])
				Lib.Tween(pill, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
					BackgroundColor3 = active and on or off,
					TextColor3 = active and Color3.new(1, 1, 1) or Color3.fromRGB(170, 170, 170)
				})
			end
		end

		for i = 1, cycle and 1 or #entries do
			local pill = Lib.Create("TextButton", {
				Size = UDim2.fromOffset(0, 24),
				AutomaticSize = Enum.AutomaticSize.X,
				LayoutOrder = i,
				AutoButtonColor = false,
				BackgroundColor3 = Lib.Palette.SwitchOff,
				TextColor3 = cycle and Color3.new(1, 1, 1) or Color3.fromRGB(170, 170, 170),
				Text = cycle and Label(current) or entries[i][1],
				TextSize = 11,
				Font = Enum.Font.GothamMedium,
				Parent = holder,
				Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
				Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })
			})
			pills[i] = pill
			if not cycle then
				Lib.RegisterSwitch(pill, function() return Active(entries[i][2]) end, Paint)
			end
			pill.MouseButton1Click:Connect(function()
				Lib.PlayClick()
				if cycle then
					local index = 1
					for j, entry in ipairs(entries) do
						if entry[2] == current then
							index = j
							break
						end
					end
					current = entries[index % #entries + 1][2]
					Paint()
					onChange(current)
				elseif multi then
					local value = entries[i][2]
					selected[value] = not selected[value] or nil
					Paint()
					onChange(Snapshot())
				else
					current = entries[i][2]
					Paint()
					onChange(current)
				end
			end)
		end
		Paint()

		Lib.ChoiceControls[title] = {
			Get = function()
				if not multi then return current end
				local list = {}
				for _, entry in ipairs(entries) do
					if selected[entry[2]] then list[#list + 1] = entry[2] end
				end
				return list
			end,
			Set = function(value)
				if multi then
					table.clear(selected)
					for _, item in ipairs(type(value) == "table" and value or { value }) do selected[item] = true end
					Paint()
					onChange(Snapshot())
					return
				end
				for _, entry in ipairs(entries) do
					if entry[2] == value then
						current = value
						Paint()
						onChange(value)
						return
					end
				end
			end
		}

		if not isLast then
			Lib.Create("Frame", {
				Size = UDim2.new(1, -28, 0, 1),
				Position = UDim2.new(0, 14, 1, -1),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 0.9,
				BorderSizePixel = 0,
				Parent = Item
			})
		end

		Lib.SearchAdd(parentCard, Item, title)
		return Item
	end

	function Lib.BindDrag(area, onMove)
		area.InputBegan:Connect(function(input)
			local kind = input.UserInputType
			if kind ~= Enum.UserInputType.MouseButton1 and kind ~= Enum.UserInputType.Touch then return end
			onMove(input.Position)
			local UIS, moveConn, endConn = Services.UserInputService
			moveConn = UIS.InputChanged:Connect(function(changed)
				local moved = changed.UserInputType
				if moved == Enum.UserInputType.MouseMovement or moved == Enum.UserInputType.Touch then onMove(changed.Position) end
			end)
			endConn = UIS.InputEnded:Connect(function(ended)
				local released = ended.UserInputType
				if released == Enum.UserInputType.MouseButton1 or released == Enum.UserInputType.Touch then
					moveConn:Disconnect()
					endConn:Disconnect()
				end
			end)
		end)
	end

	function Lib.CreateColorItem(group, title, tbl, key, last, onChange)
		local h, s, v = tbl[key]:ToHSV()
		local open = false
		local item = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 46), BackgroundTransparency = 1, ClipsDescendants = true, Parent = group })
		local label = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -90, 0, 46), Position = UDim2.fromOffset(14, 0), BackgroundTransparency = 1, Text = title,
			TextColor3 = Color3.fromRGB(240, 240, 240), TextSize = 13, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = item
		})
		Lib.RegisterThemeText(label, "Primary")
		local swatch = Lib.Create("TextButton", {
			Size = UDim2.fromOffset(44, 22), Position = UDim2.new(1, -58, 0, 12), BackgroundColor3 = tbl[key], Text = "", AutoButtonColor = false, Parent = item,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
			Lib.Create("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 1, Transparency = 0.8 })
		})
		local svArea = Lib.Create("Frame", {
			Size = UDim2.new(1, -28, 0, 70), Position = UDim2.fromOffset(14, 52), BackgroundColor3 = Color3.fromHSV(h, 1, 1), Parent = item,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
		})
		Lib.Create("Frame", {
			Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Parent = svArea,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
			Lib.Create("UIGradient", { Transparency = NumberSequence.new(0, 1) })
		})
		Lib.Create("Frame", {
			Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, Parent = svArea,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
			Lib.Create("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0) })
		})
		local svKnob = Lib.Create("Frame", {
			Size = UDim2.fromOffset(12, 12), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(s, 1 - v), BackgroundTransparency = 1, Parent = svArea,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
			Lib.Create("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
		})
		local svHit = Lib.Create("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Parent = svArea })
		local hueSteps = {}
		for i = 0, 6 do hueSteps[#hueSteps + 1] = ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 1, 1)) end
		local hueBar = Lib.Create("Frame", {
			Size = UDim2.new(1, -28, 0, 12), Position = UDim2.fromOffset(14, 130), BackgroundColor3 = Color3.new(1, 1, 1), Parent = item,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
			Lib.Create("UIGradient", { Color = ColorSequence.new(hueSteps) })
		})
		local hueKnob = Lib.Create("Frame", {
			Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(h, 0, 0.5, 0), BackgroundColor3 = Color3.new(1, 1, 1), Parent = hueBar,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
			Lib.Create("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1, Transparency = 0.6 })
		})
		local hueHit = Lib.Create("TextButton", {
			Size = UDim2.new(1, 0, 0, 24), Position = UDim2.new(0, 0, 0.5, -12), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Parent = hueBar
		})
		if not last then
			Lib.Create("Frame", {
				Size = UDim2.new(1, -28, 0, 1), Position = UDim2.new(0, 14, 1, -1), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.9, BorderSizePixel = 0, Parent = item
			})
		end

		local function Paint(exact)
			local color = exact or Color3.fromHSV(h, s, v)
			tbl[key] = color
			swatch.BackgroundColor3 = color
			svArea.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
			svKnob.Position = UDim2.fromScale(s, 1 - v)
			hueKnob.Position = UDim2.new(h, 0, 0.5, 0)
			if onChange then onChange(color) end
		end

		Lib.BindDrag(svHit, function(position)
			s = math.clamp((position.X - svArea.AbsolutePosition.X) / svArea.AbsoluteSize.X, 0, 1)
			v = 1 - math.clamp((position.Y - svArea.AbsolutePosition.Y) / svArea.AbsoluteSize.Y, 0, 1)
			Paint()
		end)
		Lib.BindDrag(hueHit, function(position)
			h = math.clamp((position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
			Paint()
		end)
		swatch.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			open = not open
			Lib.Tween(item, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Size = UDim2.new(1, 0, 0, open and 154 or 46) })
		end)

		return item, function(color)
			local nh, ns, nv = color:ToHSV()
			if ns > 0 and nv > 0 then h = nh end
			s, v = ns, nv
			Paint(color)
		end
	end

	function Lib.CreateSettingButtonItem(parentCard, title, desc, onClick, isLast)
		local Item = Lib.Create("TextButton", {
			Size = UDim2.new(1, 0, 0, 52),
			BackgroundColor3 = Color3.fromRGB(15, 15, 15),
			BackgroundTransparency = 0,
			Text = "",
			AutoButtonColor = false,
			Parent = parentCard,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) })
		})
		Lib.RegisterThemeElement(Item, "BackgroundColor3", 0.5)

		local TitleLabel = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -30, 0, 20),
			Position = UDim2.new(0, 14, 0, 8),
			BackgroundTransparency = 1,
			Text = title,
			TextColor3 = Color3.fromRGB(240, 240, 240),
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = Item
		})
		Lib.RegisterThemeText(TitleLabel, "Primary")

		local DescLabel = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -30, 0, 16),
			Position = UDim2.new(0, 14, 0, 28),
			BackgroundTransparency = 1,
			Text = desc,
			TextColor3 = Color3.fromRGB(130, 130, 130),
			TextSize = 11,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = Item
		})
		Lib.RegisterThemeText(DescLabel, "Secondary")

		if not isLast then
			Lib.Create("Frame", {
				Size = UDim2.new(1, -28, 0, 1),
				Position = UDim2.new(0, 14, 1, -1),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 0.9,
				BorderSizePixel = 0,
				Parent = Item
			})
		end

		Item.MouseEnter:Connect(function() Lib.Tween(Item, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Lib.Lighten(Lib.Theme.Card, 0.055) }) end)
		Item.MouseLeave:Connect(function() Lib.Tween(Item, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Lib.Theme.Card }) end)
		Item.MouseButton1Down:Connect(function()
			Lib.PlayClick()
			Lib.Tween(Item, 0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Lib.Lighten(Lib.Theme.Card, 0.105) })
		end)
		Item.MouseButton1Up:Connect(function() Lib.Tween(Item, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Lib.Lighten(Lib.Theme.Card, 0.055) }) end)
		Item.MouseButton1Click:Connect(function() onClick(TitleLabel) end)

		Lib.SearchAdd(parentCard, Item, title)
		return Item
	end
end

Lib.SearchShown = {}


-- ══════════════════════════════════════════════════════════════════════════
--  SEARCH · card helpers · filters
-- ══════════════════════════════════════════════════════════════════════════

function Lib.BuildGlobalSearch(section, sideBar, tabs, views, stateKey)
	local list, shown = Lib.SearchItems, Lib.SearchShown
	local active = false

	local results = Lib.Create("ScrollingFrame", {
		Size = UDim2.new(1, -190, 1, -20), Position = UDim2.new(0, 180, 0, 10), BackgroundTransparency = 1, BorderSizePixel = 0,
		ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100), CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, Parent = section,
		Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 15) })
	})
	local card = Lib.Create("Frame", {
		Size = UDim2.fromScale(1, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Color3.fromRGB(15, 15, 15), Parent = results,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
		Lib.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder })
	})
	Lib.RegisterThemeElement(card, "BackgroundColor3", 0.5)
	local empty = Lib.Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Text = "No features found", TextColor3 = Color3.fromRGB(130, 130, 130),
		TextSize = 13, Font = Enum.Font.GothamMedium, Visible = false, Parent = results
	})
	Lib.RegisterThemeText(empty, "Secondary")

	local function SetViews(current)
		for name, view in pairs(views) do
			view.Visible = name == current
		end
	end

	local function Release()
		for i = #shown, 1, -1 do
			local entry = shown[i]
			if entry.Item.Parent then entry.Item.Parent = entry.Parent end
			shown[i] = nil
		end
	end

	local function Apply(text)
		local query = Lib.Lower(text)
		Release()
		if query == "" then
			if active then
				active = false
				results.Visible = false
				SetViews(State[stateKey])
			end
			return
		end
		if not active then
			active = true
			SetViews(nil)
			results.Visible = true
		end
		local length, count = #query, 0
		for i = 1, #list do
			local entry = list[i]
			local item = entry.Item
			if item.Parent then
				local title, alt = entry.Title, entry.Alt
				if title:sub(1, length) == query or title:find(" " .. query, 1, true) or alt:sub(1, length) == query or alt:find(" " .. query, 1, true) then
					item.Parent = card
					count += 1
					shown[count] = entry
				end
			end
		end
		card.Visible = count > 0
		empty.Visible = count == 0
		results.CanvasPosition = Vector2.zero
	end

	local box = Lib.MakeSearchBox(sideBar, "Search", UDim2.fromOffset(15, 46), UDim2.new(1, -30, 0, 28), 0, Apply)
	for _, button in ipairs(tabs:GetChildren()) do
		if button:IsA("TextButton") then
			button.MouseButton1Click:Connect(function()
				task.defer(function() box.Text = "" end)
			end)
		end
	end
	section:GetPropertyChangedSignal("Visible"):Connect(function()
		if not section.Visible and box.Text ~= "" then box.Text = "" end
	end)
end

function Lib.BuildBrowseSearch(view, scroll, bottom, placeholder, onQuery)
	local api = {}

	local strip = Lib.Create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 0, 56), Position = UDim2.fromOffset(0, 38), BackgroundTransparency = 1, BorderSizePixel = 0,
		ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100), ScrollingDirection = Enum.ScrollingDirection.X,
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.X, Visible = false, Parent = view,
		Lib.Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
		Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 4) })
	})

	local function Layout(hasStrip)
		local top = hasStrip and 102 or 38
		scroll.Position = UDim2.fromOffset(0, top)
		scroll.Size = UDim2.new(1, 0, 1, -(top + bottom))
		strip.Visible = hasStrip
	end

	api.Box = Lib.MakeSearchBox(view, placeholder, UDim2.fromOffset(8, 0), UDim2.new(1, -16, 0, 30), 0.4, onQuery)

	function api.SetSuggestions(list)
		for _, child in ipairs(strip:GetChildren()) do
			if child:IsA("GuiButton") then child:Destroy() end
		end
		local count = list and #list or 0
		for i = 1, count do
			local data = list[i]
			local card = Lib.Create("TextButton", {
				Size = UDim2.fromOffset(190, 50), BackgroundColor3 = Color3.fromRGB(15, 15, 15), Text = "", AutoButtonColor = false,
				LayoutOrder = i, Parent = strip,
				Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) })
			})
			Lib.RegisterThemeElement(card, "BackgroundColor3", 0.5)

			local thumb = Lib.Create("ImageLabel", {
				Size = UDim2.fromOffset(36, 36), Position = UDim2.fromOffset(7, 7), BackgroundColor3 = Color3.fromRGB(22, 22, 22),
				ScaleType = Enum.ScaleType.Crop, Parent = card,
				Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
			})
			Lib.LoadWebImage(thumb, data.Image)
			Lib.RegisterThemeElement(thumb, "BackgroundColor3", 0.7)

			local name = Lib.Create("TextLabel", {
				Size = UDim2.new(1, -56, 0, 16), Position = UDim2.fromOffset(50, 7), BackgroundTransparency = 1, Text = data.Name,
				TextColor3 = Color3.fromRGB(240, 240, 240), TextSize = 12, Font = Enum.Font.GothamBold,
				TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = card
			})
			Lib.RegisterThemeText(name, "Primary")

			local sub = Lib.Create("TextLabel", {
				Size = UDim2.new(1, -56, 0, 20), Position = UDim2.fromOffset(50, 24), BackgroundTransparency = 1, Text = data.Sub or "",
				TextColor3 = Color3.fromRGB(130, 130, 130), TextSize = 10, Font = Enum.Font.Gotham, TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextTruncate = Enum.TextTruncate.AtEnd, Parent = card
			})
			Lib.RegisterThemeText(sub, "Secondary")

			card.MouseEnter:Connect(function()
				Lib.Tween(card, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Lib.Lighten(Lib.Theme.Card, 0.04) })
			end)
			card.MouseLeave:Connect(function()
				Lib.Tween(card, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Lib.Theme.Card })
			end)
			card.MouseButton1Click:Connect(function()
				Lib.PlayClick()
				api.Box.Text = data.Name
			end)
		end
		Layout(count > 0)
	end

	Layout(false)
	return api
end

function Lib.MakeStar(parent, position, saved, onToggle)
	local gold, white = Color3.fromRGB(255, 200, 40), Color3.new(1, 1, 1)
	local star = Lib.Create("TextButton", {
		Size = UDim2.fromOffset(24, 24), Position = position, BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.5,
		AutoButtonColor = false, Text = "\u{2605}", TextSize = 15, Font = Enum.Font.GothamBold, TextColor3 = saved and gold or white,
		ZIndex = 9, Parent = parent,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
	})
	star.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		Lib.Tween(star, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { TextColor3 = onToggle() and gold or white })
	end)
	return star
end

function Lib.MiniIcon(kind, parent, position, color)
	local box = Lib.Create("Frame", { Size = UDim2.fromOffset(14, 14), Position = position, BackgroundTransparency = 1, Parent = parent })
	if kind == "eye" then
		Lib.Create("Frame", {
			Size = UDim2.fromOffset(14, 9), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 1, Parent = box,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
			Lib.Create("UIStroke", { Color = color, Thickness = 1.3 })
		})
		Lib.Create("Frame", {
			Size = UDim2.fromOffset(4, 4), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), BackgroundColor3 = color, BorderSizePixel = 0, Parent = box,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
		})
	elseif kind == "folder" then
		Lib.Create("Frame", {
			Size = UDim2.fromOffset(6, 4), Position = UDim2.fromOffset(0, 1), BackgroundTransparency = 1, Parent = box,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 2) }),
			Lib.Create("UIStroke", { Color = color, Thickness = 1.3 })
		})
		Lib.Create("Frame", {
			Size = UDim2.fromOffset(14, 9), Position = UDim2.fromOffset(0, 4), BackgroundTransparency = 1, Parent = box,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
			Lib.Create("UIStroke", { Color = color, Thickness = 1.3 })
		})
	else
		Lib.Create("Frame", {
			Size = UDim2.fromOffset(13, 13), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 1, Parent = box,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
			Lib.Create("UIStroke", { Color = color, Thickness = 1.3 })
		})
		Lib.Create("Frame", { Size = UDim2.fromOffset(1, 4), AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromOffset(7, 7), BackgroundColor3 = color, BorderSizePixel = 0, Parent = box })
		Lib.Create("Frame", { Size = UDim2.fromOffset(3, 1), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromOffset(7, 7), BackgroundColor3 = color, BorderSizePixel = 0, Parent = box })
	end
	return box
end

function Lib.TimeAgo(stamp)
	local diff = math.max(os.time() - stamp, 0)
	if diff < 60 then return "just now" end
	if diff < 3600 then return diff // 60 .. "m ago" end
	if diff < 86400 then return diff // 3600 .. "h ago" end
	if diff < 2592000 then return diff // 86400 .. "d ago" end
	if diff < 31536000 then return diff // 2592000 .. "mo ago" end
	return diff // 31536000 .. "y ago"
end

function Lib.FormatViews(count)
	if count >= 1e6 then return (string.format("%.1f", count / 1e6):gsub("%.0$", "")) .. "M" end
	if count >= 1e3 then return (string.format("%.1f", count / 1e3):gsub("%.0$", "")) .. "K" end
	return tostring(math.floor(count))
end

function Lib.MakeCardList(view, emptyText, cell, gap, padX)
	local scroll = Lib.Create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100),
		BorderSizePixel = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = view,
		Lib.Create("UIGridLayout", { CellSize = cell, CellPadding = gap, SortOrder = Enum.SortOrder.LayoutOrder }),
		Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, padX), PaddingRight = UDim.new(0, padX), PaddingBottom = UDim.new(0, 15) })
	})
	local empty = Lib.Create("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = emptyText, TextColor3 = Color3.fromRGB(150, 150, 150),
		TextSize = 14, Font = Enum.Font.GothamMedium, Visible = false, Parent = view
	})
	Lib.RegisterThemeText(empty, "Secondary")
	return scroll, empty
end

function Lib.MakeFilterButton(sideBar, onClick)
	local api, hover = {}, false
	local function Idle() return State.LightTheme and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(150, 150, 150) end
	local button = Lib.Create("TextButton", {
		Size = UDim2.new(1, -30, 0, 34), Position = UDim2.new(0, 15, 1, -74), BackgroundColor3 = Lib.Palette.Primary, BackgroundTransparency = 1,
		Text = "", AutoButtonColor = false, Parent = sideBar,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 7) })
	})
	local label = Lib.Create("TextLabel", {
		Size = UDim2.new(1, -72, 1, 0), Position = UDim2.fromOffset(38, 0), BackgroundTransparency = 1, Text = "Filters", TextSize = 14,
		Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Idle(), Parent = button
	})
	local pieces = {}
	local function Piece(size, position, round)
		local piece = Lib.Create("Frame", { Size = size, Position = position, BackgroundColor3 = Idle(), BorderSizePixel = 0, Parent = button })
		if round then Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = piece }) end
		pieces[#pieces + 1] = piece
	end
	Piece(UDim2.fromOffset(14, 2), UDim2.fromOffset(12, 11))
	Piece(UDim2.fromOffset(14, 2), UDim2.fromOffset(12, 21))
	Piece(UDim2.fromOffset(6, 6), UDim2.fromOffset(21, 9), true)
	Piece(UDim2.fromOffset(6, 6), UDim2.fromOffset(13, 19), true)

	local badge = Lib.Create("TextLabel", {
		Size = UDim2.fromOffset(20, 18), Position = UDim2.new(1, -28, 0.5, -9), BackgroundColor3 = Lib.Palette.Primary, Text = "0",
		TextColor3 = Color3.new(0, 0, 0), TextSize = 11, Font = Enum.Font.GothamBold, Visible = false, Parent = button,
		Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
	})

	local function Paint()
		local color = hover and Lib.Palette.Primary or Idle()
		local info = { Enum.EasingStyle.Quad, Enum.EasingDirection.Out }
		Lib.Tween(label, 0.15, info[1], info[2], { TextColor3 = color })
		for _, piece in ipairs(pieces) do Lib.Tween(piece, 0.15, info[1], info[2], { BackgroundColor3 = color }) end
		Lib.Tween(button, 0.15, info[1], info[2], { BackgroundColor3 = Lib.Palette.Primary, BackgroundTransparency = hover and 0.92 or 1 })
		badge.BackgroundColor3 = Lib.Palette.Primary
		badge.TextColor3 = State.LightTheme and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
	end

	button.MouseEnter:Connect(function() hover = true Paint() end)
	button.MouseLeave:Connect(function() hover = false Paint() end)
	button.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		onClick()
	end)
	table.insert(Lib.ThemeHooks, Paint)
	Paint()

	function api.SetCount(count)
		badge.Text = tostring(count)
		badge.Visible = count > 0
	end
	return api
end

function Lib.MakeFilterChips(parent, title, options, isOn, onPick, order, cellWidth, disabled)
	local section = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = order, Parent = parent })
	local heading = Lib.Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = title, TextColor3 = Color3.fromRGB(200, 200, 200), TextSize = 12,
		Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = section
	})
	Lib.RegisterThemeText(heading, "Primary")
	local grid = Lib.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Position = UDim2.fromOffset(0, 22), BackgroundColor3 = Color3.fromRGB(22, 22, 22), Parent = section,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 9) }),
		Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) }),
		Lib.Create("UIGridLayout", { CellSize = UDim2.fromOffset(cellWidth, 28), CellPadding = UDim2.fromOffset(6, 6), SortOrder = Enum.SortOrder.LayoutOrder })
	})
	Lib.RegisterThemeElement(grid, "BackgroundColor3", 0.7)

	local buttons = {}
	local function Refresh()
		local light = State.LightTheme
		for option, button in pairs(buttons) do
			local on = isOn(option)
			local off = disabled and disabled[option]
			Lib.Tween(button, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
				BackgroundColor3 = Lib.Palette.Primary,
				BackgroundTransparency = on and 0 or 1,
				TextColor3 = on and (light and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)) or (off and Color3.fromRGB(85, 85, 85) or Color3.fromRGB(150, 150, 150))
			})
		end
	end
	for index, option in ipairs(options) do
		local button = Lib.Create("TextButton", {
			BackgroundColor3 = Lib.Palette.Primary, BackgroundTransparency = 1, Text = option, TextSize = 12, Font = Enum.Font.GothamMedium,
			TextColor3 = Color3.fromRGB(150, 150, 150), AutoButtonColor = false, LayoutOrder = index, Parent = grid,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 7) })
		})
		buttons[option] = button
		button.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			onPick(option)
			Refresh()
		end)
	end
	Refresh()
	table.insert(Lib.ThemeHooks, Refresh)
	return Refresh
end

function Lib.BuildFilterModal(title, subtitle)
	local api, busy = {}, false
	local backdrop = Lib.Create("TextButton", {
		Name = "FilterBackdrop", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1,
		Text = "", AutoButtonColor = false, Visible = false, ZIndex = 30, Parent = UI.Main
	})
	local window = Lib.Create("Frame", {
		Size = UDim2.fromOffset(400, 470), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(16, 16, 16), ClipsDescendants = true, Active = true, ZIndex = 31, Parent = backdrop,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
		Lib.Create("UIStroke", { Color = Color3.fromRGB(60, 60, 60), Thickness = 1, Transparency = 0.5 })
	})
	Lib.RegisterThemeElement(window, "BackgroundColor3", 0.7)

	local heading = Lib.Create("TextLabel", {
		Size = UDim2.new(1, -70, 0, 22), Position = UDim2.fromOffset(18, 14), BackgroundTransparency = 1, Text = title, TextSize = 17,
		Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 32, Parent = window
	})
	Lib.RegisterThemeText(heading, "Primary")
	local sub = Lib.Create("TextLabel", {
		Size = UDim2.new(1, -70, 0, 16), Position = UDim2.fromOffset(18, 37), BackgroundTransparency = 1, Text = subtitle, TextSize = 12,
		Font = Enum.Font.GothamMedium, TextColor3 = Color3.fromRGB(130, 130, 130), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 32, Parent = window
	})
	Lib.RegisterThemeText(sub, "Secondary")
	local close = Lib.Create("TextButton", {
		Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -42, 0, 14), BackgroundTransparency = 1, Text = "\u{00D7}", TextSize = 20,
		Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(150, 150, 150), AutoButtonColor = false, ZIndex = 32, Parent = window
	})
	Lib.RegisterThemeText(close, "Secondary")
	api.Backdrop, api.Sub = backdrop, sub

	api.Content = Lib.Create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, -70), Position = UDim2.fromOffset(0, 70), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2,
		ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 32, Parent = window,
		Lib.Create("UIListLayout", { Padding = UDim.new(0, 14), SortOrder = Enum.SortOrder.LayoutOrder }),
		Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 18), PaddingRight = UDim.new(0, 18), PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 18) })
	})

	function api.Open()
		if backdrop.Visible then return end
		Lib.GlassOpen(backdrop)
		window.Size = UDim2.fromOffset(380, 450)
		Lib.Tween(window, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, { Size = UDim2.fromOffset(400, 470) })
	end
	function api.Close()
		if not backdrop.Visible or busy then return end
		busy = true
		Lib.GlassClose(backdrop, function()
			backdrop.Visible = false
			busy = false
		end)
	end
	close.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		api.Close()
	end)
	backdrop.MouseButton1Click:Connect(api.Close)
	return api
end


-- ══════════════════════════════════════════════════════════════════════════
--  MODAL · FLOATING WINDOW · OVERLAY · CHIP
-- ══════════════════════════════════════════════════════════════════════════

do
	local UIS = Services.UserInputService
	local zTop = 10

	function Lib.CreateModal(title, width, height)
		local backdrop = Lib.Create("TextButton", {
			Name = (title:gsub("%s", "")) .. "Backdrop", Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1,
			Text = "", AutoButtonColor = false, Visible = false, ZIndex = 30, Parent = UI.Main
		})
		local window = Lib.Create("Frame", {
			Size = UDim2.fromOffset(width, height), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(16, 16, 16), ClipsDescendants = true, ZIndex = 31, Parent = backdrop,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
			Lib.Create("UIStroke", { Color = Color3.fromRGB(40, 40, 40), Thickness = 1, Transparency = 0.4 })
		})
		Lib.RegisterThemeElement(window, "BackgroundColor3", 0.5)
		local heading = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -60, 0, 35), Position = UDim2.fromOffset(16, 8), BackgroundTransparency = 1, Text = title,
			TextColor3 = Color3.new(1, 1, 1), TextSize = 15, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 32, Parent = window
		})
		Lib.RegisterThemeText(heading, "Primary")
		local closeBtn = Lib.Create("TextButton", {
			Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -38, 0, 10), BackgroundColor3 = Color3.new(1, 1, 1), Text = "×", TextColor3 = Color3.new(0, 0, 0),
			TextSize = 16, Font = Enum.Font.GothamBold, ZIndex = 32, Parent = window, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
		})
		local content = Lib.Create("ScrollingFrame", {
			Size = UDim2.new(1, -24, 1, -55), Position = UDim2.fromOffset(12, 45), BackgroundTransparency = 1, ScrollBarThickness = 2,
			ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80), BorderSizePixel = 0, ZIndex = 32, Parent = window
		})
		local layout = Lib.Create("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder, Parent = content })
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
		end)

		local isOpen = false
		local modal = { Backdrop = backdrop, Window = window, Content = content }

		function modal.IsOpen()
			return isOpen
		end

		function modal.Open()
			if isOpen then return end
			isOpen = true
			window.Size = UDim2.fromOffset(width - 40, height - 40)
			Lib.GlassOpen(backdrop)
			Lib.Tween(window, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Size = UDim2.fromOffset(width, height) })
		end

		function modal.Close()
			if not isOpen then return end
			isOpen = false
			Lib.Tween(window, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In, { Size = UDim2.fromOffset(width - 60, height - 60) })
			Lib.GlassClose(backdrop, function()
				if not isOpen then backdrop.Visible = false end
			end)
		end

		closeBtn.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			modal.Close()
		end)
		return modal
	end

	function Lib.CreateWindow(options)
		local width, height, headerHeight = options.Width, options.Height, 36
		local viewport = UI.Screen.AbsoluteSize
		local pos = Vector2.new(
			math.max((viewport.X - width) / 2 + (options.OffsetX or 0), 8),
			math.max((viewport.Y - height) / 2 + (options.OffsetY or 0), 8)
		)
		zTop = math.min(zTop + 1, 99)

		local root = Lib.Create("CanvasGroup", {
			Name = options.Name, Size = UDim2.fromOffset(width, height), Position = UDim2.fromOffset(pos.X, pos.Y),
			BackgroundColor3 = Color3.fromRGB(15, 15, 15), GroupTransparency = 1, Visible = false, ZIndex = zTop, Parent = UI.Screen,
			Lib.Create("UIStroke", { Color = Color3.fromRGB(45, 45, 45), Thickness = 1, Transparency = 0.3 })
		})
		Lib.BindCorner(root, "WindowCorner")
		Lib.RegisterThemeElement(root, "BackgroundColor3", 0.5)
		local scale = Lib.Create("UIScale", { Scale = 0.94, Parent = root })

		local header = Lib.Create("Frame", {
			Name = "Header", Size = UDim2.new(1, 0, 0, headerHeight), BackgroundColor3 = Color3.fromRGB(22, 22, 22), Active = true, ZIndex = 2, Parent = root
		})
		Lib.RegisterThemeElement(header, "BackgroundColor3", 0.7)
		local titleLabel = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -130, 1, 0), Position = UDim2.fromOffset(14, 0), BackgroundTransparency = 1, Text = options.Title,
			TextColor3 = Color3.new(1, 1, 1), TextSize = 13, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3, Parent = header
		})
		Lib.RegisterThemeText(titleLabel, "Primary")

		local function HeaderButton(text, offsetX)
			local button = Lib.Create("TextButton", {
				Size = UDim2.fromOffset(26, 26), Position = UDim2.new(1, offsetX, 0.5, -13), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1,
				Text = text, TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 16, Font = Enum.Font.GothamMedium, AutoButtonColor = false, ZIndex = 3, Parent = header,
				Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
			})
			Lib.RegisterThemeText(button, "Secondary")
			button.MouseEnter:Connect(function()
				Lib.Tween(button, 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundTransparency = 0.88 })
			end)
			button.MouseLeave:Connect(function()
				Lib.Tween(button, 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundTransparency = 1 })
			end)
			return button
		end

		local closeBtn = HeaderButton("×", -34)
		local minBtn = HeaderButton("—", -64)
		local gearBtn
		if options.Gear then
			gearBtn = HeaderButton("", -94)
			Lib.RegisterThemeImage(Lib.Create("ImageLabel", {
				Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0.5, -8, 0.5, -8), BackgroundTransparency = 1,
				Image = "rbxassetid://119430435918970", ScaleType = Enum.ScaleType.Fit, ZIndex = 4, Parent = gearBtn
			}))
		end

		local body = Lib.Create("Frame", {
			Name = "Body", Size = UDim2.new(1, 0, 1, -headerHeight), Position = UDim2.fromOffset(0, headerHeight),
			BackgroundTransparency = 1, ClipsDescendants = true, Parent = root
		})

		local win = { Root = root, Body = body, GearBtn = gearBtn }
		local token = 0
		local minimized = false

		function win.IsVisible()
			return root.Visible and token % 2 == 1
		end

		function win.Show()
			token = token + 1
			if token % 2 == 0 then token = token + 1 end
			local base = Lib.MenuBaseScale or 1
			zTop = math.min(zTop + 1, 99)
			root.ZIndex = zTop
			scale.Scale = 0.94 * base
			root.Visible = true
			Lib.Tween(root, 0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, { GroupTransparency = 0 })
			Lib.Tween(scale, 0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Scale = base })
			if options.OnVisibility then options.OnVisibility(true) end
		end

		function win.Hide()
			if token % 2 == 0 then return end
			token = token + 1
			local mine = token
			Lib.Tween(scale, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, { Scale = 0.94 * (Lib.MenuBaseScale or 1) })
			Lib.Tween(root, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, { GroupTransparency = 1 }).Completed:Connect(function()
				if token == mine then root.Visible = false end
			end)
			if options.OnVisibility then options.OnVisibility(false) end
		end

		function win.Toggle()
			if win.IsVisible() then win.Hide() else win.Show() end
		end

		closeBtn.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			win.Hide()
		end)

		minBtn.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			minimized = not minimized
			if not minimized then body.Visible = true end
			local tween = Lib.Tween(root, 0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, { Size = UDim2.fromOffset(width, minimized and headerHeight or height) })
			if minimized then
				tween.Completed:Connect(function()
					if minimized then body.Visible = false end
				end)
			end
		end)

		root.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				zTop = math.min(zTop + 1, 99)
				root.ZIndex = zTop
			end
		end)

		local dragging, origin, startPos, goal, loop = false, nil, nil, pos, nil

		local function Clamp(v)
			local view = UI.Screen.AbsoluteSize
			local w = root.AbsoluteSize.X
			return Vector2.new(math.clamp(v.X, 80 - w, view.X - 80), math.clamp(v.Y, 0, view.Y - 40))
		end

		local function Step(dt)
			pos = pos:Lerp(goal, 1 - math.exp(-dt * 24))
			if not dragging and (pos - goal).Magnitude < 0.4 then
				pos = goal
				loop:Disconnect()
				loop = nil
			end
			root.Position = UDim2.fromOffset(pos.X, pos.Y)
		end

		header.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				origin = input.Position
				startPos = pos
				goal = pos
				if not loop then loop = Services.Run.RenderStepped:Connect(Step) end
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then dragging = false end
				end)
			end
		end)

		Lib.C(UIS.InputChanged, function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - origin
				goal = Clamp(startPos + Vector2.new(delta.X, delta.Y))
			end
		end)

		return win
	end

	function Lib.CreateOverlay(win)
		local overlay = Lib.Create("Frame", {
			Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(15, 15, 15), Visible = false, ZIndex = 20, Parent = win.Body
		})
		Lib.RegisterThemeElement(overlay, "BackgroundColor3", 0.5)
		local scroll = Lib.Create("ScrollingFrame", {
			Size = UDim2.new(1, -20, 1, -16), Position = UDim2.fromOffset(10, 8), BackgroundTransparency = 1, ScrollBarThickness = 2,
			ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80), BorderSizePixel = 0, ZIndex = 21, Parent = overlay
		})
		local layout = Lib.Create("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder, Parent = scroll })
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
		end)
		win.GearBtn.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			overlay.Visible = not overlay.Visible
		end)
		return scroll
	end

	function Lib.MakeChip(parent, text, size, position)
		local chip = Lib.Create("TextButton", {
			Size = size, Position = position, BackgroundColor3 = Color3.new(1, 1, 1), Text = text, TextColor3 = Color3.new(0, 0, 0),
			TextSize = 12, Font = Enum.Font.GothamBold, AutoButtonColor = false, Parent = parent, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
		})
		chip.MouseEnter:Connect(function()
			Lib.Tween(chip, 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Color3.fromRGB(210, 210, 210) })
		end)
		chip.MouseLeave:Connect(function()
			Lib.Tween(chip, 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Color3.new(1, 1, 1) })
		end)
		return chip
	end
end


-- ══════════════════════════════════════════════════════════════════════════
--  MAIN TABS · SECTIONS
-- ══════════════════════════════════════════════════════════════════════════


do
	local SHOW = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 0.06)
	local HIDE = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local running = {}

	local function Play(section, info, goal)
		local old = running[section]
		if old then old:Cancel() end
		local tween = Services.Tween:Create(section, info, goal)
		running[section] = tween
		tween:Play()
		return tween
	end

	function Lib.AnimateSections(previous, tab)
		local rank = {}
		for index, data in ipairs(Lib.NavTabs) do rank[data.id] = index end
		local direction = (rank[tab] or 1) >= (rank[previous] or 1) and 1 or -1
		for _, data in ipairs(Lib.NavTabs) do
			local key = data.id
			local section = UI[key .. "Section"]
			if section then
				if key == tab then
					local fresh = not section.Visible or section.GroupTransparency > 0.98
					if fresh then
						section.Position = UDim2.fromOffset(0, 18 * direction)
						section.GroupTransparency = 1
					end
					section.Visible = true
					Play(section, SHOW, { Position = UDim2.new(), GroupTransparency = 0 })
					if fresh then Lib.Cascade(section) end
				elseif section.Visible then
					Play(section, HIDE, { Position = UDim2.fromOffset(0, -12 * direction), GroupTransparency = 1 }).Completed:Connect(function(state)
						if state == Enum.PlaybackState.Completed and State.ActiveMain ~= key then
							section.Visible = false
							section.Position = UDim2.new()
						end
					end)
				end
			end
		end
	end
end

function Lib.SwitchMainTab(tab)
	local previous = State.ActiveMain
	if previous == tab then return end
	State.ActiveMain = tab
	Lib.RecalculateNavPositions()
	Lib.AnimateSections(previous, tab)
	if Lib.OnMainTab then pcall(Lib.OnMainTab, tab, previous) end
end


-- A "section" is one page of the top navigation (Home / Features / Settings ...):
-- title + sub-title + 180px sidebar with the animated tab list + content views.
-- This is the block the original script repeats for every main tab.
function Lib.CreateSection(id, options)
	options = options or {}
	local Section = Lib.Create("CanvasGroup", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, Parent = UI.ContentArea })
	UI[id .. "Section"] = Section

	local Title = Lib.Create("TextLabel", { Size = UDim2.new(1, -30, 0, 30), Position = UDim2.new(0, 20, 0, 10), BackgroundTransparency = 1, Text = options.Title or id, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 20, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left })
	Lib.RegisterThemeText(Title, "Primary")

	local Sub
	if options.Subtitle then
		Sub = Lib.Create("TextLabel", { Size = UDim2.new(1, -30, 0, 20), AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 15, 1, -15), BackgroundTransparency = 1, Text = options.Subtitle, TextColor3 = Color3.fromRGB(100, 100, 100), TextSize = 11, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left })
		Lib.RegisterThemeText(Sub, "Secondary")
	end

	local SideBar = Lib.Create("Frame", { Size = UDim2.new(0, 180, 1, 0), BackgroundTransparency = 1, Parent = Section, Title, Sub })

	local Tabs = SideBar
	if options.Scroll ~= false then
		local top, bottom = options.TabsTop or 34, options.TabsBottom or 76
		Tabs = Lib.Create("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, -bottom), Position = UDim2.fromOffset(0, top), BackgroundTransparency = 1, BorderSizePixel = 0,
			ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100), ScrollingDirection = Enum.ScrollingDirection.Y,
			CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = SideBar
		})
		if options.TabsPaddingBottom then
			Lib.Create("UIPadding", { PaddingBottom = UDim.new(0, options.TabsPaddingBottom), Parent = Tabs })
		end
	end

	local stateKey = options.StateKey or ("Current" .. id .. "Tab")
	local Switch, Make, Views = Lib.CreateTabSystem(Section, Tabs, stateKey, options.OnSwitch)

	local object = {
		Id = id, Section = Section, SideBar = SideBar, Tabs = Tabs, Title = Title, Subtitle = Sub,
		Switch = Switch, Make = Make, Views = Views, StateKey = stateKey,
		TabStart = options.TabStart or 50, TabStep = options.TabStep or 40, Count = 0
	}

	if options.Search then
		Lib.BuildGlobalSearch(Section, SideBar, Tabs, Views, stateKey)
	end

	return object
end

-- ScrollingFrame + list layout used by every feature page (original MakeScroll)
function Lib.MakeScroll(view, padding, searchable)
	local scr = Lib.Create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1, ScrollBarThickness = 2,
		ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100), BorderSizePixel = 0,
		Parent = view
	})
	if searchable ~= false then Lib.SearchScrolls[scr] = true end
	local lyt = Lib.Create("UIListLayout", { Padding = UDim.new(0, padding or 14), SortOrder = Enum.SortOrder.LayoutOrder, Parent = scr })
	Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 15), Parent = scr })

	lyt:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scr.CanvasSize = UDim2.new(0, 0, 0, lyt.AbsoluteContentSize.Y + 20)
	end)
	return scr
end


-- ══════════════════════════════════════════════════════════════════════════
--  THEME PICKER · FONT PICKER · APPEARANCE
-- ══════════════════════════════════════════════════════════════════════════

function Lib.DeriveTheme(spec)
	local out = {}
	if typeof(spec) == "Color3" then
		local r, g, b = spec.R, spec.G, spec.B
		local light = r > 0.9 and g > 0.9 and b > 0.9
		local isDefaultBlack = math.floor(r * 255) == 18 and math.floor(g * 255) == 18 and math.floor(b * 255) == 18
		if isDefaultBlack then
			out.Main, out.Card, out.Item = Color3.fromRGB(0, 0, 0), Color3.fromRGB(15, 15, 15), Color3.fromRGB(22, 22, 22)
		elseif light then
			out.Main, out.Card, out.Item = Color3.fromRGB(242, 242, 244), Color3.fromRGB(255, 255, 255), Color3.fromRGB(232, 234, 238)
		else
			local function Scale(k)
				return Color3.new(math.clamp(r * k, 0, 1), math.clamp(g * k, 0, 1), math.clamp(b * k, 0, 1))
			end
			if Lib.Luma(spec) > 0.65 then
				out.Main, out.Card, out.Item = Scale(0.92), Scale(0.98), Scale(0.85)
			else
				out.Main, out.Card, out.Item = Scale(0.45), Scale(0.65), Scale(0.85)
			end
		end
		out.Light = light
		out.Base = spec
		out.Primary = light and Color3.fromRGB(15, 15, 15) or Color3.fromRGB(245, 245, 245)
		out.Secondary = light and Color3.fromRGB(85, 85, 85) or Color3.fromRGB(145, 145, 145)
		out.SwitchOff = light and Color3.fromRGB(205, 205, 210) or Color3.fromRGB(38, 38, 38)
		out.SwitchOn = light and Color3.fromRGB(20, 20, 20) or (isDefaultBlack and Color3.fromRGB(46, 213, 115) or spec)
		out.Halloween = false
	else
		out.Light = Lib.Luma(spec.Background) > 0.6
		out.Base = spec.Background
		out.Main, out.Card, out.Item = spec.Background, spec.Surface, spec.Item
		out.Primary, out.Secondary, out.SwitchOn, out.SwitchOff = spec.Text, spec.Muted, spec.Accent, spec.SwitchOff
		out.Halloween = spec.Halloween == true
	end
	return out
end

do
	local THEMES_FILE = Lib.Config.Folder .. "_Themes.json"
	local THEME_KEYS = { "Background", "Surface", "Text", "Accent", "Item", "Muted", "SwitchOff" }

	function Lib.SaveCustomThemes()
		if not writefile then return end
		local out = {}
		for i, theme in ipairs(State.CustomThemes) do
			local entry = { Name = theme.Name }
			for _, key in ipairs(THEME_KEYS) do
				entry[key] = theme[key]:ToHex()
			end
			out[i] = entry
		end
		pcall(writefile, THEMES_FILE, Services.HttpService:JSONEncode(out))
	end

	function Lib.LoadCustomThemes()
		if not (isfile and readfile) then return end
		pcall(function()
			if not isfile(THEMES_FILE) then return end
			for _, entry in ipairs(Services.HttpService:JSONDecode(readfile(THEMES_FILE))) do
				local theme = { Name = tostring(entry.Name or "Custom") }
				for _, key in ipairs(THEME_KEYS) do
					theme[key] = Color3.fromHex(entry[key])
				end
				table.insert(State.CustomThemes, theme)
			end
		end)
	end
end

function Lib.CreateThemePicker(parent, layoutOrder)
	local NAMES = { "Dark", "Crimson", "Blue", "Purple", "Red", "Green", "Yellow", "Cyan", "Pink", "Slate", "Plum", "Light" }
	local FILTERS = { "All Themes", "Built-in", "Custom" }
	local Quad, Out = Enum.EasingStyle.Quad, Enum.EasingDirection.Out
	local filter, records = 1, {}
	local Rebuild, addCard

	local Section = Lib.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Color3.fromRGB(15, 15, 15), LayoutOrder = layoutOrder, Parent = parent,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
		Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 14), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) }),
		Lib.Create("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder })
	})
	Lib.RegisterThemeElement(Section, "BackgroundColor3", 0.5)

	local Head = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, LayoutOrder = 1, Parent = Section })

	local icon = Lib.Create("ImageLabel", {
		Size = UDim2.fromOffset(18, 18), Position = UDim2.fromOffset(0, 3), BackgroundTransparency = 1, Image = "rbxassetid://92865789131206",
		ScaleType = Enum.ScaleType.Fit, Parent = Head
	})
	Lib.RegisterThemeImage(icon)

	local title = Lib.Create("TextLabel", {
		Size = UDim2.new(1, -150, 0, 16), Position = UDim2.fromOffset(28, 0), BackgroundTransparency = 1, Text = "Theme", TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 14, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = Head
	})
	Lib.RegisterThemeText(title, "Primary")

	local desc = Lib.Create("TextLabel", {
		Size = UDim2.new(1, -150, 0, 14), Position = UDim2.fromOffset(28, 19), BackgroundTransparency = 1, Text = "Overall colour scheme applied to the entire application",
		TextColor3 = Color3.fromRGB(130, 130, 130), TextSize = 11, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = Head
	})
	Lib.RegisterThemeText(desc, "Secondary")

	local filterButton = Lib.Create("TextButton", {
		Size = UDim2.fromOffset(112, 28), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 3), BackgroundColor3 = Color3.fromRGB(22, 22, 22),
		Text = FILTERS[1], TextColor3 = Color3.fromRGB(240, 240, 240), TextSize = 11, Font = Enum.Font.GothamMedium, AutoButtonColor = false, Parent = Head,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 7) })
	})
	Lib.RegisterThemeElement(filterButton, "BackgroundColor3", 0.7)
	Lib.RegisterThemeText(filterButton, "Primary")

	local Grid = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, LayoutOrder = 2, Parent = Section })
	local GridLayout = Lib.Create("UIGridLayout", {
		CellSize = UDim2.new(1 / 3, -6, 0, 46), CellPadding = UDim2.fromOffset(8, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Grid
	})
	GridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Grid.Size = UDim2.new(1, 0, 0, GridLayout.AbsoluteContentSize.Y)
	end)

	local function Hover()
		if State.LightTheme then return Lib.Theme.Item:Lerp(Color3.new(0, 0, 0), 0.06) end
		return Lib.Lighten(Lib.Theme.Item, 0.07)
	end

	local function Bind(card)
		card.MouseEnter:Connect(function()
			Lib.Tween(card, 0.15, Quad, Out, { BackgroundColor3 = Hover() })
		end)
		card.MouseLeave:Connect(function()
			Lib.Tween(card, 0.15, Quad, Out, { BackgroundColor3 = Lib.Theme.Item })
		end)
	end

	local function UpdateSelection()
		for index, record in pairs(records) do
			local on = State.SelectedThemeIndex == index
			record.Check.Visible = on
			Lib.Tween(record.Stroke, 0.2, Quad, Out, { Transparency = on and 0.1 or 1 })
		end
	end

	function Lib.SelectTheme(index)
		local spec = Lib.ResolveTheme(index)
		if not spec then return end
		State.SelectedThemeIndex = index
		Lib.ApplyTheme(spec)
		UpdateSelection()
	end

	function Lib.AddCustomTheme(theme)
		for i, existing in ipairs(State.CustomThemes) do
			if existing.Name == theme.Name then
				State.CustomThemes[i] = theme
				Lib.SaveCustomThemes()
				Rebuild()
				return #Lib.ThemePresets + i
			end
		end
		table.insert(State.CustomThemes, theme)
		Lib.SaveCustomThemes()
		Rebuild()
		return #Lib.ThemePresets + #State.CustomThemes
	end

	local function DeleteCustom(theme)
		local position = table.find(State.CustomThemes, theme)
		if not position then return end
		local index = #Lib.ThemePresets + position
		table.remove(State.CustomThemes, position)
		Lib.SaveCustomThemes()
		Rebuild()
		if State.SelectedThemeIndex == index then
			Lib.SelectTheme(1)
		elseif State.SelectedThemeIndex > index then
			State.SelectedThemeIndex = State.SelectedThemeIndex - 1
			UpdateSelection()
		end
	end

	local function AddCard(index, order, name, spec, custom)
		local derived = Lib.DeriveTheme(spec)
		local stroke = Lib.Create("UIStroke", { Color = Lib.Palette.Primary, Thickness = 1.5, Transparency = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
		local card = Lib.Create("TextButton", {
			BackgroundColor3 = Color3.fromRGB(22, 22, 22), Text = "", AutoButtonColor = false, LayoutOrder = order, Parent = Grid,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) }), stroke
		})
		Lib.RegisterThemeElement(card, "BackgroundColor3", 0.7)

		local strips = Lib.Create("Frame", {
			Position = UDim2.fromOffset(6, 6), Size = UDim2.new(1, -12, 0, 20), BackgroundTransparency = 1, ClipsDescendants = true, Parent = card,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 5) })
		})
		local colors = { derived.Main, derived.Card, derived.SwitchOn, derived.Primary }
		for k = 1, 4 do
			Lib.Create("Frame", {
				Size = UDim2.new(0.25, k < 4 and 1 or 0, 1, 0), Position = UDim2.fromScale((k - 1) * 0.25, 0), BackgroundColor3 = colors[k], BorderSizePixel = 0, Parent = strips
			})
		end

		local label = Lib.Create("TextLabel", {
			Position = UDim2.fromOffset(8, 30), Size = UDim2.new(1, -30, 0, 12), BackgroundTransparency = 1, Text = name, TextColor3 = Color3.fromRGB(240, 240, 240),
			TextSize = 11, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = card
		})
		Lib.RegisterThemeText(label, "Primary")

		local check = Lib.Create("TextLabel", {
			Position = UDim2.new(1, -22, 0, 29), Size = UDim2.fromOffset(14, 14), BackgroundTransparency = 1, Text = "✓", TextColor3 = Color3.fromRGB(240, 240, 240),
			TextSize = 12, Font = Enum.Font.GothamBold, Visible = false, Parent = card
		})
		Lib.RegisterThemeText(check, "Primary")

		records[index] = { Stroke = stroke, Check = check }
		Bind(card)

		card.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			Lib.SelectTheme(index)
		end)

		if custom then
			card.MouseButton2Click:Connect(function() DeleteCustom(custom) end)
			local remove = Lib.Create("TextButton", {
				Size = UDim2.fromOffset(16, 16), Position = UDim2.new(1, -24, 0, 8), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.45,
				Text = "✕", TextColor3 = Color3.new(1, 1, 1), TextSize = 9, Font = Enum.Font.GothamBold, AutoButtonColor = false, ZIndex = 3, Parent = card,
				Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
			})
			remove.MouseButton1Click:Connect(function()
				Lib.PlayClick()
				DeleteCustom(custom)
			end)
		end
	end

	function Rebuild()
		for _, child in ipairs(Grid:GetChildren()) do
			if child:IsA("GuiButton") and child ~= addCard then child:Destroy() end
		end
		table.clear(records)
		local presets = #Lib.ThemePresets
		if filter ~= 2 then
			for k, theme in ipairs(State.CustomThemes) do
				AddCard(presets + k, k, theme.Name, theme, theme)
			end
		end
		if filter ~= 3 then
			for i = 1, presets do
				AddCard(i, 100 + i, NAMES[i] or ("Theme " .. i), Lib.ThemePresets[i])
			end
			AddCard(0, 200, "Halloween 🎃", Lib.HalloweenTheme)
		end
		UpdateSelection()
	end

	addCard = Lib.Create("TextButton", {
		BackgroundColor3 = Color3.fromRGB(22, 22, 22), Text = "", AutoButtonColor = false, LayoutOrder = 0, Parent = Grid,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) })
	})
	Lib.RegisterThemeElement(addCard, "BackgroundColor3", 0.7)

	local plusBox = Lib.Create("Frame", {
		Position = UDim2.fromOffset(6, 6), Size = UDim2.new(1, -12, 0, 20), BackgroundColor3 = Color3.fromRGB(15, 15, 15), Parent = addCard,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 5) })
	})
	Lib.RegisterThemeElement(plusBox, "BackgroundColor3", 0.5)

	local plus = Lib.Create("TextLabel", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "+", TextColor3 = Color3.fromRGB(145, 145, 145), TextSize = 16, Font = Enum.Font.GothamMedium, Parent = plusBox
	})
	Lib.RegisterThemeText(plus, "Secondary")

	local addLabel = Lib.Create("TextLabel", {
		Position = UDim2.fromOffset(8, 30), Size = UDim2.new(1, -16, 0, 12), BackgroundTransparency = 1, Text = "Add Custom Theme", TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 11, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = addCard
	})
	Lib.RegisterThemeText(addLabel, "Primary")
	Bind(addCard)
	addCard.Visible = Lib.OpenThemeEditor ~= nil

	addCard.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		if not Lib.OpenThemeEditor then return end
		Lib.OpenThemeEditor(function(theme)
			table.insert(State.CustomThemes, theme)
			Lib.SaveCustomThemes()
			Rebuild()
			Lib.SelectTheme(#Lib.ThemePresets + #State.CustomThemes)
		end)
	end)

	filterButton.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		filter = filter % #FILTERS + 1
		filterButton.Text = FILTERS[filter]
		Rebuild()
	end)

	table.insert(Lib.ThemeHooks, function()
		local color = Lib.Palette.Primary
		for _, record in pairs(records) do
			record.Stroke.Color = color
		end
	end)

	Lib.LoadCustomThemes()
	Rebuild()
end

function Lib.CreateFontPicker(parent, layoutOrder)
	local FontSection = Lib.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 148),
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		LayoutOrder = layoutOrder,
		Parent = parent,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) })
	})
	Lib.RegisterThemeElement(FontSection, "BackgroundColor3", 0.5)

	local fontIcon = Lib.Create("TextLabel", {
		Size = UDim2.fromOffset(18, 18),
		Position = UDim2.new(0, 14, 0, 12),
		BackgroundTransparency = 1,
		Text = "Aa",
		TextColor3 = Color3.fromRGB(220, 220, 220),
		TextSize = 13,
		Font = Enum.Font.GothamBold,
		Parent = FontSection
	})
	Lib.RegisterThemeText(fontIcon, "Primary")

	local fontTitle = Lib.Create("TextLabel", {
		Size = UDim2.new(1, -50, 0, 18),
		Position = UDim2.new(0, 40, 0, 12),
		BackgroundTransparency = 1,
		Text = "App Font",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = FontSection
	})
	Lib.RegisterThemeText(fontTitle, "Primary")

	local fontDesc = Lib.Create("TextLabel", {
		Size = UDim2.new(1, -50, 0, 16),
		Position = UDim2.new(0, 40, 0, 30),
		BackgroundTransparency = 1,
		Text = "Font used throughout the entire application",
		TextColor3 = Color3.fromRGB(130, 130, 130),
		TextSize = 11,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = FontSection
	})
	Lib.RegisterThemeText(fontDesc, "Secondary")

	local FontListScroll = Lib.Create("ScrollingFrame", {
		Size = UDim2.new(1, -28, 0, 42),
		Position = UDim2.new(0, 14, 0, 52),
		BackgroundTransparency = 1,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Parent = FontSection
	})

	local FontListLayout = Lib.Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = FontListScroll
	})

	FontListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		FontListScroll.CanvasSize = UDim2.new(0, FontListLayout.AbsoluteContentSize.X + 10, 0, 0)
	end)

	local FontItems = {
		{ name = "Gotham", regular = Enum.Font.GothamMedium, bold = Enum.Font.GothamBold },
		{ name = "Ubuntu", regular = Enum.Font.Ubuntu, bold = Enum.Font.Ubuntu },
		{ name = "JosefinSans", regular = Enum.Font.JosefinSans, bold = Enum.Font.JosefinSans },
		{ name = "FredokaOne", regular = Enum.Font.FredokaOne, bold = Enum.Font.FredokaOne },
		{ name = "SciFi", regular = Enum.Font.SciFi, bold = Enum.Font.SciFi },
		{ name = "BuilderSans", regular = Enum.Font.BuilderSansMedium, bold = Enum.Font.BuilderSansBold },
		{ name = "Roboto", regular = Enum.Font.Roboto, bold = Enum.Font.Roboto },
		{ name = "Nunito", regular = Enum.Font.Nunito, bold = Enum.Font.Nunito },
		{ name = "Oswald", regular = Enum.Font.Oswald, bold = Enum.Font.Oswald },
		{ name = "Titillium", regular = Enum.Font.TitilliumWeb, bold = Enum.Font.TitilliumWeb },
		{ name = "Michroma", regular = Enum.Font.Michroma, bold = Enum.Font.Michroma },
		{ name = "Jura", regular = Enum.Font.Jura, bold = Enum.Font.Jura },
		{ name = "SourceSans", regular = Enum.Font.SourceSans, bold = Enum.Font.SourceSansBold },
		{ name = "Merriweather", regular = Enum.Font.Merriweather, bold = Enum.Font.Merriweather }
	}

	local fontBtns, customFonts = {}, {}
	local FONT_FILE, FONT_DIR = Lib.Config.Folder .. "_Fonts.json", Lib.Config.Folder .. "_Fonts"
	local Http, Market = Services.HttpService, game:GetService("MarketplaceService")
	local selectedKey = State.SelectedFontIndex
	local Select

	local function MakeFaces(entry)
		local family = "rbxassetid://" .. entry.id
		if not entry.direct then
			if not (writefile and getcustomasset and isfile and isfolder and makefolder) then
				return nil, "Executor lacks writefile / getcustomasset"
			end
			local path = FONT_DIR .. "/" .. entry.id .. ".json"
			local ok, result = pcall(function()
				if not isfolder(FONT_DIR) then makefolder(FONT_DIR) end
				if not isfile(path) then
					writefile(path, Http:JSONEncode({
						name = "SeptusFont" .. entry.id,
						faces = {
							{ name = "Regular", weight = 400, style = "normal", assetId = family },
							{ name = "Bold", weight = 700, style = "normal", assetId = family }
						}
					}))
				end
				return getcustomasset(path)
			end)
			if not ok or type(result) ~= "string" or result == "" then return nil, "Could not prepare the font file" end
			family = result
		end
		local ok, regular, bold = pcall(function()
			return Font.new(family, Enum.FontWeight.Regular, Enum.FontStyle.Normal), Font.new(family, Enum.FontWeight.Bold, Enum.FontStyle.Normal)
		end)
		if not ok then return nil, "Invalid font asset" end
		return regular, bold
	end

	local function Persist()
		if writefile then pcall(writefile, FONT_FILE, Http:JSONEncode(customFonts)) end
	end

	local function AddFontButton(key, data, order, entry)
		local Item = Lib.Create("TextButton", {
			Size = UDim2.fromOffset(36, 36),
			BackgroundColor3 = Color3.fromRGB(22, 22, 22),
			Text = "Aa",
			TextColor3 = Color3.fromRGB(240, 240, 240),
			TextSize = 14,
			AutoButtonColor = false,
			LayoutOrder = order,
			Parent = FontListScroll,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) })
		})
		Lib.PinFont(Item)
		if data.boldFace then Item.FontFace = data.boldFace else Item.Font = data.bold end
		Lib.RegisterThemeElement(Item, "BackgroundColor3", 0.7)
		Lib.RegisterThemeText(Item, "Primary")

		local isSelected = key == selectedKey

		local Stroke = Lib.Create("UIStroke", {
			Color = Color3.fromRGB(255, 255, 255),
			Thickness = 1.5,
			Transparency = isSelected and 0 or 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Parent = Item
		})

		local CheckBadge = Lib.Create("Frame", {
			Size = UDim2.fromOffset(13, 13),
			Position = UDim2.new(0, 1, 0, 1),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Visible = isSelected,
			Parent = Item,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
			Lib.Create("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = "✓",
				TextColor3 = Color3.fromRGB(0, 0, 0),
				TextSize = 9,
				Font = Enum.Font.GothamBold
			})
		})

		fontBtns[key] = { Item = Item, Stroke = Stroke, Badge = CheckBadge, Data = data, Entry = entry }

		if entry then
			local Remove = Lib.Create("TextButton", {
				Size = UDim2.fromOffset(14, 14),
				Position = UDim2.new(1, -15, 0, 1),
				BackgroundColor3 = Color3.fromRGB(220, 70, 70),
				Text = "×",
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 11,
				Font = Enum.Font.GothamBold,
				AutoButtonColor = false,
				ZIndex = 3,
				Parent = Item,
				Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
			})
			Remove.MouseButton1Click:Connect(function()
				Lib.PlayClick()
				local index = table.find(customFonts, entry)
				if index then table.remove(customFonts, index) end
				Persist()
				local wasSelected = selectedKey == key
				fontBtns[key] = nil
				Lib.FontSelectors[key] = nil
				Item:Destroy()
				if wasSelected then Select(1) end
			end)
		end

		Item.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			Select(key)
		end)
	end

	Select = function(key)
		local info = fontBtns[key]
		if not info then return end
		selectedKey = key
		for otherKey, other in pairs(fontBtns) do
			local selected = otherKey == key
			other.Badge.Visible = selected
			other.Stroke.Transparency = selected and 0 or 1
		end
		if info.Entry then
			State.SelectedFontIndex, State.SelectedFontId = 0, info.Entry.id
		else
			State.SelectedFontIndex, State.SelectedFontId = key, nil
		end
		local data = info.Data
		Lib.ApplyGlobalFont(data.regular, data.bold, data.regularFace, data.boldFace)
	end

	for i, fData in ipairs(FontItems) do
		AddFontButton(i, fData, i)
		Lib.FontSelectors[i] = function() Select(i) end
	end

	local function Register(entry)
		local regular, bold = MakeFaces(entry)
		if not regular then return false, bold end
		local key = "c" .. entry.id
		AddFontButton(key, {
			regular = Enum.Font.Gotham, bold = Enum.Font.GothamBold, regularFace = regular, boldFace = bold
		}, 100 + #customFonts, entry)
		Lib.FontSelectors[key] = function() Select(key) end
		return true
	end

	function Lib.AddCustomFont(raw)
		local id = tostring(raw):match("%d+")
		if not id or #id < 5 then
			Lib.Notify({ Title = "App Font", Text = "Enter a valid font Asset ID" })
			return false
		end
		local key = "c" .. id
		if fontBtns[key] then
			Select(key)
			return true
		end
		local ok, info = pcall(Market.GetProductInfo, Market, tonumber(id))
		if not ok or type(info) ~= "table" then
			Lib.Notify({ Title = "App Font", Text = "Asset " .. id .. " was not found" })
			return false
		end
		local entry = { id = id, name = tostring(info.Name or id):sub(1, 40), direct = info.AssetTypeId == 73 }
		customFonts[#customFonts + 1] = entry
		local added, err = Register(entry)
		if not added then
			table.remove(customFonts)
			Lib.Notify({ Title = "App Font", Text = tostring(err) })
			return false
		end
		Persist()
		Select(key)
		Lib.Notify({ Title = "App Font", Text = entry.name .. " applied" })
		return true
	end

	if isfile and readfile then
		pcall(function()
			if not isfile(FONT_FILE) then return end
			for _, entry in ipairs(Http:JSONDecode(readfile(FONT_FILE))) do
				if type(entry) == "table" and tostring(entry.id):match("^%d+$") then
					local clean = { id = tostring(entry.id), name = tostring(entry.name or entry.id), direct = entry.direct == true }
					customFonts[#customFonts + 1] = clean
					Register(clean)
				end
			end
		end)
	end

	local FontInput = Lib.Create("TextBox", {
		Size = UDim2.new(1, -104, 0, 32),
		Position = UDim2.new(0, 14, 0, 104),
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
		PlaceholderText = "Custom font Asset ID...",
		PlaceholderColor3 = Color3.fromRGB(110, 110, 110),
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 12,
		Font = Enum.Font.GothamMedium,
		Text = "",
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = FontSection,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
		Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })
	})
	Lib.RegisterThemeElement(FontInput, "BackgroundColor3", 0.7, true)
	Lib.RegisterThemeText(FontInput, "Primary")

	local FontAdd = Lib.Create("TextButton", {
		Size = UDim2.fromOffset(62, 32),
		Position = UDim2.new(1, -76, 0, 104),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Text = "Add",
		TextColor3 = Color3.fromRGB(0, 0, 0),
		TextSize = 12,
		Font = Enum.Font.GothamBold,
		Parent = FontSection,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
	})

	local function Submit()
		local text = FontInput.Text
		if text == "" then return end
		task.spawn(function()
			if Lib.AddCustomFont(text) then FontInput.Text = "" end
		end)
	end

	FontAdd.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		Submit()
	end)
	FontInput.FocusLost:Connect(function(enter)
		if enter then Submit() end
	end)
end

function Lib.BuildAppearanceTabs(view, names)
	local NAMES = names or { "Theme", "Window", "Background", "Notifications", "Language", "Interface" }
	local COUNT, TOP = #NAMES, 44
	local Quad, Quint = Enum.EasingStyle.Quad, Enum.EasingStyle.Quint
	local Out, In = Enum.EasingDirection.Out, Enum.EasingDirection.In
	local SHOW = TweenInfo.new(0.36, Quint, Out, 0, false, 0.05)
	local HIDE = TweenInfo.new(0.14, Quad, In)
	local REST = UDim2.fromOffset(0, TOP)
	local pages, scrolls, buttons, order, running = {}, {}, {}, {}, {}
	local current = NAMES[1]

	local bar = Lib.Create("Frame", {
		Size = UDim2.new(1, -10, 0, 34), Position = UDim2.fromOffset(5, 3), BackgroundColor3 = Color3.fromRGB(15, 15, 15), Parent = view,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 9) })
	})
	Lib.RegisterThemeElement(bar, "BackgroundColor3", 0.5)

	local track = Lib.Create("Frame", { Size = UDim2.new(1, -6, 1, -6), Position = UDim2.fromOffset(3, 3), BackgroundTransparency = 1, Parent = bar })

	local thumb = Lib.Create("Frame", {
		Size = UDim2.fromScale(1 / COUNT, 1), BackgroundColor3 = Color3.fromRGB(34, 34, 34), BorderSizePixel = 0, Parent = track,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 7) })
	})

	local function ThumbColor()
		return State.LightTheme and Lib.Theme.Item or Lib.Lighten(Lib.Theme.Item, 0.08)
	end
	thumb.BackgroundColor3 = ThumbColor()
	table.insert(Lib.ThemeHooks, function()
		Lib.Tween(thumb, 0.25, Quad, Out, { BackgroundColor3 = ThumbColor() })
	end)

	local function Play(page, info, goal)
		local old = running[page]
		if old then old:Cancel() end
		local tween = Services.Tween:Create(page, info, goal)
		running[page] = tween
		tween:Play()
		return tween
	end

	local function Switch(name)
		if name == current or not order[name] then return end
		local direction = order[name] >= order[current] and 1 or -1
		current = name
		Lib.Tween(thumb, 0.34, Quint, Out, { Position = UDim2.fromScale((order[name] - 1) / COUNT, 0) })
		for key, page in pairs(pages) do
			local selected = key == name
			local button = buttons[key]
			UI.TextThemeElements[button] = selected and "Primary" or "Secondary"
			Lib.Tween(button, 0.2, Quad, Out, { TextColor3 = selected and Lib.Palette.Primary or Lib.Palette.Secondary })
			if selected then
				local fresh = not page.Visible or page.GroupTransparency > 0.98
				if fresh then
					page.Position = UDim2.fromOffset(0, TOP + 14 * direction)
					page.GroupTransparency = 1
				end
				page.Visible = true
				Play(page, SHOW, { Position = REST, GroupTransparency = 0 })
				if fresh then Lib.Cascade(page) end
			elseif page.Visible then
				Play(page, HIDE, { Position = UDim2.fromOffset(0, TOP - 10 * direction), GroupTransparency = 1 }).Completed:Connect(function(state)
					if state == Enum.PlaybackState.Completed and current ~= key then page.Visible = false end
				end)
			end
		end
	end

	for index, name in ipairs(NAMES) do
		order[name] = index
		local selected = index == 1

		local button = Lib.Create("TextButton", {
			Size = UDim2.fromScale(1 / COUNT, 1), Position = UDim2.fromScale((index - 1) / COUNT, 0), BackgroundTransparency = 1, Text = name,
			TextColor3 = selected and Lib.Palette.Primary or Lib.Palette.Secondary, TextSize = 12, TextScaled = true, Font = Enum.Font.GothamBold,
			AutoButtonColor = false, ZIndex = 2, Parent = track,
			Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), PaddingTop = UDim.new(0, 9), PaddingBottom = UDim.new(0, 9) }),
			Lib.Create("UITextSizeConstraint", { MaxTextSize = 12, MinTextSize = 7 })
		})
		Lib.RegisterThemeText(button, selected and "Primary" or "Secondary")
		buttons[name] = button

		button.MouseEnter:Connect(function()
			if current ~= name then Lib.Tween(button, 0.15, Quad, Out, { TextColor3 = Lib.Palette.Primary }) end
		end)
		button.MouseLeave:Connect(function()
			if current ~= name then Lib.Tween(button, 0.15, Quad, Out, { TextColor3 = Lib.Palette.Secondary }) end
		end)
		button.MouseButton1Click:Connect(function()
			if current ~= name then Lib.PlayClick() end
			Switch(name)
		end)

		local page = Lib.Create("CanvasGroup", {
			Name = name, Size = UDim2.new(1, 0, 1, -TOP), Position = REST, BackgroundTransparency = 1, BorderSizePixel = 0,
			Visible = selected, GroupTransparency = selected and 0 or 1, Parent = view
		})
		pages[name] = page

		scrolls[name] = Lib.Create("ScrollingFrame", {
			Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2,
			ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100), ScrollingDirection = Enum.ScrollingDirection.Y,
			CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = page,
			Lib.Create("UIListLayout", { Padding = UDim.new(0, 16), SortOrder = Enum.SortOrder.LayoutOrder }),
			Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 15) })
		})
	end

	Lib.SwitchAppearancePage = Switch
	return scrolls
end


-- Ready-made appearance settings page: Theme / Window / Notifications / Interface
function Lib.BuildAppearanceSettings(view)
	local Pages = Lib.BuildAppearanceTabs(view, { "Theme", "Window", "Notifications", "Interface" })
	Lib.CreateThemePicker(Pages.Theme, 1)

	local ThemeWindowGroup = Lib.CreateFeatureGroup(Pages.Theme, "Window Customization", 2)
	Lib.SearchGroups[ThemeWindowGroup] = true
	Lib.CreateSettingSliderItem(ThemeWindowGroup, "Corner Radius", "Adjust the roundness of the main window corners", 0, 28, State.CornerRadius, function(val)
		Lib.SetCornerRadius(val)
	end)
	Lib.CreateSettingSliderItem(ThemeWindowGroup, "Window Transparency", "Adjust overall background window opacity", 0, 80, State.WindowTransparency, function(val)
		State.WindowTransparency = val
		UI.Main.BackgroundTransparency = val / 100
	end)
	Lib.CreateSettingSliderItem(ThemeWindowGroup, "Panel Transparency", "Adjust opacity of the setting panels and cards", 0, 70, State.PanelTransparency, function(val)
		if val == State.PanelTransparency then return end
		State.PanelTransparency = val
		Lib.ApplyPanelTransparency()
	end, true)

	local WindowStyleGroup = Lib.CreateFeatureGroup(Pages.Window, "Navigation & Layout", 1)
	Lib.SearchGroups[WindowStyleGroup] = true
	Lib.CreateNavStylePicker(WindowStyleGroup)
	Lib.ConfigExtras.NavStyle = {
		Dump = function() return { Value = State.NavStyle } end,
		Apply = function(data)
			local control = Lib.ChoiceControls["Navigation Style"]
			if control and data.Value then pcall(control.Set, data.Value) end
		end
	}
	Lib.CreateSettingChoiceItem(WindowStyleGroup, "SH Button Style", { "Classic", "Dynamic Island" }, State.SHStyle, function(value)
		State.SHStyle = value
		if Lib.SetSHStyle then Lib.SetSHStyle(value) end
	end)
	Lib.ConfigExtras.SHStyle = {
		Dump = function() return { Value = State.SHStyle } end,
		Apply = function(data)
			local control = Lib.ChoiceControls["SH Button Style"]
			if control and data.Value then control.Set(data.Value) end
		end
	}
	Lib.CreateSettingChoiceItem(WindowStyleGroup, "Menu Animation", { "Standard", "Slide Up", "Unfold" }, State.MenuAnim, function(value)
		State.MenuAnim = value
	end)
	Lib.ConfigExtras.MenuAnim = {
		Dump = function() return { Value = State.MenuAnim } end,
		Apply = function(data)
			local control = Lib.ChoiceControls["Menu Animation"]
			if control and data.Value then control.Set(data.Value) end
		end
	}
	Lib.CreateSettingToggleItem(WindowStyleGroup, "Hide Logo", "Hides the icon in the main window header", State.HideLogo, function(val)
		State.HideLogo = val
		Lib.ApplyHeader()
	end)
	Lib.CreateSettingToggleItem(WindowStyleGroup, "Hide Name", "Hides the title next to the logo in the main window header", State.HideName, function(val)
		State.HideName = val
		Lib.ApplyHeader()
	end, true)

	Lib.CreateFontPicker(Pages.Interface, 2)

	local NotificationSettingsGroup = Lib.CreateFeatureGroup(Pages.Notifications, "Notification System", 1)
	Lib.SearchGroups[NotificationSettingsGroup] = true
	Lib.CreateSettingToggleItem(NotificationSettingsGroup, "System Notifications", "Enable or disable custom GUI notifications popup", State.NotificationsEnabled, function(val)
		State.NotificationsEnabled = val
	end)
	Lib.CreateSettingToggleItem(NotificationSettingsGroup, "Player Activity Notifications", "Show alerts when players join or leave the server", State.PlayerNotifsEnabled, function(val)
		State.PlayerNotifsEnabled = val
	end)
	Lib.CreateSettingChoiceItem(NotificationSettingsGroup, "Notification Animation", { "Slide", "Pop", "Drop", "Fade" }, State.NotifAnim, function(value)
		local previous = State.NotifAnim
		State.NotifAnim = value
		if value ~= previous then
			Lib.Notify({ Title = "Notifications", Text = "Animation: " .. value })
		end
	end)
	Lib.ConfigExtras.NotifAnim = {
		Dump = function() return { Value = State.NotifAnim } end,
		Apply = function(data)
			local control = Lib.ChoiceControls["Notification Animation"]
			if control and data.Value then control.Set(data.Value) end
		end
	}
	Lib.CreateSettingChoiceItem(NotificationSettingsGroup, "Notification Position", { "Top Left", "Top Center", "Top Right", "Bottom Left", "Bottom Center", "Bottom Right" }, State.NotifPosition, function(value)
		local previous = State.NotifPosition
		State.NotifPosition = value
		if value ~= previous and not Lib.QuietConfig then
			Lib.Notify({ Title = "Notifications", Text = "Position: " .. value })
		end
	end)
	Lib.ConfigExtras.NotifPosition = {
		Dump = function() return { Value = State.NotifPosition } end,
		Apply = function(data)
			local control = Lib.ChoiceControls["Notification Position"]
			if control and data.Value then
				Lib.QuietConfig = true
				pcall(control.Set, data.Value)
				Lib.QuietConfig = nil
			end
		end
	}
	Lib.CreateSettingChoiceItem(NotificationSettingsGroup, "Notification Sound", { "Off", "Ping", "Blip", "Pop", "Tick", "Tap" }, State.NotifSound, function(value)
		local previous = State.NotifSound
		State.NotifSound = value
		if value ~= previous and not Lib.QuietConfig then Lib.PlayNotifSound() end
	end, true)
	Lib.ConfigExtras.NotifSound = {
		Dump = function() return { Value = State.NotifSound } end,
		Apply = function(data)
			local control = Lib.ChoiceControls["Notification Sound"]
			if control and data.Value then
				Lib.QuietConfig = true
				pcall(control.Set, data.Value)
				Lib.QuietConfig = nil
			end
		end
	}
	return Pages
end


-- ══════════════════════════════════════════════════════════════════════════
--  SHELL · ScreenGui, window, drag, resize, navigation
-- ══════════════════════════════════════════════════════════════════════════

function Lib.BuildShell(config)
	config = config or {}
	Lib.SplashOptions = type(config.Splash) == "table" and config.Splash or {}

	UI.Screen = Lib.Create("ScreenGui", {
		Name = Lib.Config.Name,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 2147483647
	})

	Lib.MountGui(UI.Screen)
	ClickSound.Parent = UI.Screen
	do
		local record = Lib.InstanceKey and env[Lib.InstanceKey]
		if record then record.Gui = UI.Screen end
	end

	UI.NotifContainer = Lib.Create("Frame", {
		Name = "NotifContainer",
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = false,
		ZIndex = 150,
		Parent = UI.Screen
	})

	Lib.C(Services.Players.PlayerAdded, function(p)
		if State.PlayerNotifsEnabled and State.NotificationsEnabled then
			Lib.Notify({ Title = "Player Joined", Text = p.DisplayName .. " (@" .. p.Name .. ")", UserId = p.UserId })
		end
	end)

	Lib.C(Services.Players.PlayerRemoving, function(p)
		if State.PlayerNotifsEnabled and State.NotificationsEnabled then
			Lib.Notify({ Title = "Player Left", Text = p.DisplayName .. " (@" .. p.Name .. ")", UserId = p.UserId })
		end
	end)

	UI.MainCorner = Lib.Create("UICorner", { CornerRadius = UDim.new(0, State.CornerRadius) })

	UI.HeaderIcon = Lib.Create("ImageLabel", {
		Size = UDim2.fromOffset(45, 45),
		Position = UDim2.fromOffset(14, 7),
		BackgroundTransparency = 1,
		Image = Lib.HeaderAssets.Icon,
		ScaleType = Enum.ScaleType.Fit
	})

	UI.HeaderLogo = Lib.Create("ImageLabel", {
		Size = UDim2.fromOffset(174, 39),
		Position = UDim2.fromOffset(66, 10),
		BackgroundTransparency = 1,
		Image = Lib.HeaderAssets.Logo,
		ScaleType = Enum.ScaleType.Fit
	})

	UI.BackgroundContainer = Lib.Create("CanvasGroup", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ZIndex = 0
	})
	Lib.BindCorner(UI.BackgroundContainer, "BgCorner")

	function Lib.BgSize(factor)
		local zoom = State.BgZoom / 100 * factor
		return UDim2.fromScale(zoom, zoom)
	end

	UI.CustomBgImage = Lib.Create("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = Lib.BgSize(1),
		BackgroundTransparency = 1,
		ImageTransparency = (100 - State.BgOpacity) / 100,
		ScaleType = Enum.ScaleType.Crop,
		Visible = false,
		ZIndex = 0,
		Parent = UI.BackgroundContainer
	})
	Lib.BindCorner(UI.CustomBgImage, "ImageCorner")

	UI.Main = Lib.Create("Frame", {
		Name = "Main",
		Size = State.OriginalSize,
		ZIndex = 5,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		ClipsDescendants = true,
		Visible = false,
		Parent = UI.Screen,
		UI.MainCorner,
		UI.BackgroundContainer,
		UI.HeaderIcon,
		UI.HeaderLogo
	})
	do
		local container, active = nil, false

		local function Web(props)
			props.BackgroundTransparency = 1
			props.Size = UDim2.fromOffset(110, 110)
			props.Image = Lib.HalloweenWeb
			props.ImageTransparency = 0.15
			props.ScaleType = Enum.ScaleType.Fit
			props.Parent = container
			return Lib.Create("ImageLabel", props)
		end

		local function Build()
			container = Lib.Create("CanvasGroup", {
				Name = "HalloweenDecor",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				GroupTransparency = 1,
				ZIndex = 4,
				Visible = false,
				Parent = UI.Main
			})
			Lib.BindCorner(container, "DecorCorner")

			Web({ Name = "WebTopLeft", Position = UDim2.fromOffset(0, 0) })
			Web({ Name = "WebBottomRight", AnchorPoint = Vector2.new(1, 1), Position = UDim2.fromScale(1, 1), Rotation = 180 })
		end

		function Lib.SetHalloweenDecor(on)
			if on == active then return end
			active = on
			if on then
				if not container then Build() end
				container.Visible = true
				Lib.Tween(container, 0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { GroupTransparency = 0 })
			elseif container then
				Lib.Tween(container, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { GroupTransparency = 1 }).Completed:Connect(function()
					if not active then container.Visible = false end
				end)
			end
		end
	end

	UI.ContentArea = Lib.Create("Frame", { Size = UDim2.new(1, 0, 1, -58), Position = UDim2.new(0, 0, 0, 58), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 2, Parent = UI.Main })

	UI.TopNavContainer = Lib.Create("Frame", {
		Name = "TopNavContainer",
		Size = UDim2.new(0, 460, 0, 36),
		Position = UDim2.new(0.5, 0, 0, 11),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = false,
		ZIndex = 3,
		Parent = UI.Main
	})

	UI.WindowBtns = Lib.Create("Frame", { Size = UDim2.fromOffset(120, 36), Position = UDim2.new(1, -125, 0, 11), BackgroundTransparency = 1, ZIndex = 3, Parent = UI.Main })
	do
		local function MakeWinBtn(name, text, pos, callback)
			local btnContainer = Lib.Create("Frame", {
				Size = UDim2.fromOffset(34, 34),
				Position = pos,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Parent = UI.WindowBtns,
				Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
			})

			local btn = Lib.Create("TextButton", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = Color3.fromRGB(125, 125, 125),
				TextSize = 16,
				Font = Enum.Font.GothamMedium,
				Parent = btnContainer
			})
			Lib.RegisterThemeText(btn, "Secondary")

			btn.MouseEnter:Connect(function()
				local isWhite = State.LightTheme
				Lib.Tween(btnContainer, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
					BackgroundColor3 = isWhite and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = isWhite and 0.92 or 0.88
				})
				Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { TextColor3 = isWhite and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255) })
			end)

			btn.MouseLeave:Connect(function()
				local isWhite = State.LightTheme
				Lib.Tween(btnContainer, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundTransparency = 1 })
				Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { TextColor3 = isWhite and Color3.fromRGB(85, 85, 85) or Color3.fromRGB(125, 125, 125) })
			end)

			btn.MouseButton1Click:Connect(function()
				local report = Lib.CompatModal
				if report and report.IsOpen() then return end
				Lib.PlayClick()
				callback()
			end)
		end

		local function ApplyWindowState()
			Lib.ApplyWindowState()
		end

		MakeWinBtn("Minimize", "—", UDim2.fromOffset(0, 0), function()
			State.Minimized = not State.Minimized
			ApplyWindowState()
		end)

		MakeWinBtn("Maximize", "□", UDim2.fromOffset(40, 0), function()
			State.Minimized = false
			State.Maximized = not State.Maximized
			ApplyWindowState()
		end)

		MakeWinBtn("Close", "×", UDim2.fromOffset(80, 0), function()
			Lib.Unload()
			if Lib.OnClose then pcall(Lib.OnClose) end
			if Refs.IntroBlur then Refs.IntroBlur:Destroy() end
			if Refs.GlassBlur then Refs.GlassBlur:Destroy() end
			UI.Screen:Destroy()
		end)
	end
	do
		local UIS = Services.UserInputService
		local handle = Lib.Create("Frame", { Name = "DragHandle", Size = UDim2.new(1, 0, 0, 58), BackgroundTransparency = 1, Active = true, ZIndex = 1, Parent = UI.Main })
		local dragging, origin, startOffset, goal, loop = false, nil, nil, Lib.DragOffset, nil

		local function Clamp(v)
			local view = UI.Screen.AbsoluteSize
			local s = Lib.MenuBaseScale or 1
			local w, h = State.OriginalSize.X.Offset * s, State.OriginalSize.Y.Offset * s
			return Vector2.new(
				math.clamp(v.X, -view.X / 2 - w / 2 + 140, view.X / 2 + w / 2 - 140),
				math.clamp(v.Y, h / 2 - view.Y / 2, view.Y / 2 + h / 2 - 58 * s)
			)
		end

		local function Step(dt)
			Lib.DragOffset = Lib.DragOffset:Lerp(goal, 1 - math.exp(-dt * 22))
			if not dragging and (Lib.DragOffset - goal).Magnitude < 0.4 then
				Lib.DragOffset = goal
				loop:Disconnect()
				loop = nil
			end
			UI.Main.Position = select(2, Lib.MainLayout())
		end

		handle.InputBegan:Connect(function(input)
			if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not State.Maximized and not Lib.WindowBusy() then
				dragging = true
				origin = input.Position
				startOffset = Lib.DragOffset
				goal = Lib.DragOffset
				if not loop then loop = Services.Run.RenderStepped:Connect(Step) end
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then dragging = false end
				end)
			end
		end)

		Lib.C(UIS.InputChanged, function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - origin
				goal = Clamp(startOffset + Vector2.new(delta.X, delta.Y))
			end
		end)
	end
	do
		local UIS = Services.UserInputService
		local MIN_W, MIN_H, MAX_W, MAX_H = 560, 380, 1500, 950
		local EDGE, CORNER = 6, 14
		local active, origin, startW, startH, startOffset

		local handles = {
			{ -1, 0, UDim2.new(0, EDGE, 1, -CORNER * 2), UDim2.fromOffset(0, CORNER) },
			{ 1, 0, UDim2.new(0, EDGE, 1, -CORNER * 2), UDim2.new(1, -EDGE, 0, CORNER) },
			{ 0, -1, UDim2.new(1, -CORNER * 2, 0, EDGE), UDim2.fromOffset(CORNER, 0) },
			{ 0, 1, UDim2.new(1, -CORNER * 2, 0, EDGE), UDim2.new(0, CORNER, 1, -EDGE) },
			{ -1, -1, UDim2.fromOffset(CORNER, CORNER), UDim2.fromOffset(0, 0) },
			{ 1, -1, UDim2.fromOffset(CORNER, CORNER), UDim2.new(1, -CORNER, 0, 0) },
			{ -1, 1, UDim2.fromOffset(CORNER, CORNER), UDim2.new(0, 0, 1, -CORNER) },
			{ 1, 1, UDim2.fromOffset(CORNER, CORNER), UDim2.new(1, -CORNER, 1, -CORNER) }
		}

		local function Blocked()
			return State.Maximized or State.Minimized or Lib.WindowBusy()
		end

		for _, data in ipairs(handles) do
			local handle = Lib.Create("Frame", {
				Name = "ResizeHandle", Size = data[3], Position = data[4], BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 1, BorderSizePixel = 0, Active = true, ZIndex = 60, Parent = UI.Main
			})
			local function Glow(transparency)
				handle.BackgroundColor3 = State.LightTheme and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
				Lib.Tween(handle, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundTransparency = transparency })
			end
			handle.MouseEnter:Connect(function()
				if not active and not Blocked() then Glow(0.82) end
			end)
			handle.MouseLeave:Connect(function()
				if active ~= data then Glow(1) end
			end)
			handle.InputBegan:Connect(function(input)
				if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
				if Blocked() then return end
				active, origin = data, input.Position
				startW, startH, startOffset = State.OriginalSize.X.Offset, State.OriginalSize.Y.Offset, Lib.DragOffset
				Glow(0.6)
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						active = nil
						Glow(1)
					end
				end)
			end)
		end

		Lib.C(UIS.InputChanged, function(input)
			if not active or (input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch) then return end
			if Blocked() then
				active = nil
				return
			end
			local s = Lib.MenuBaseScale or 1
			local view = UI.Screen.AbsoluteSize
			local dx, dy = active[1], active[2]
			local delta = input.Position - origin
			local w = math.clamp(startW + dx * delta.X / s, MIN_W, math.max(MIN_W, math.min(MAX_W, view.X / s - 20)))
			local h = math.clamp(startH + dy * delta.Y / s, MIN_H, math.max(MIN_H, math.min(MAX_H, view.Y / s - 20)))
			State.OriginalSize = UDim2.fromOffset(w, h)
			Lib.DragOffset = startOffset + Vector2.new(dx * (w - startW) * s / 2, dy * (h - startH) * s / 2)
			UI.Main.Size, UI.Main.Position = Lib.MainLayout()
		end)
	end
	do
		local NavTabsData = Lib.NavTabs
		local TAB_COUNT = #NavTabsData
		local BASE_TAB_WIDTH, TAB_GAP, RAIL_WIDTH, SEGMENT_WIDTH = 34, 8, 60, 76
		local Out = Enum.EasingDirection.Out
		local Quad, Cubic, Quint = Enum.EasingStyle.Quad, Enum.EasingStyle.Cubic, Enum.EasingStyle.Quint
		local STYLES = { "Classic", "Floating Dock", "Floating Pill", "Segmented", "Icon Rail" }
		local Layouts = {}

		Lib.NavRailWidth = RAIL_WIDTH

		local function Go(obj, time, style, props, instant)
			if instant then
				for key, value in pairs(props) do obj[key] = value end
			else
				Lib.Tween(obj, time, style, Out, props)
			end
		end

		local PlateCorner = Lib.Create("UICorner", { CornerRadius = UDim.new(0, 14) })
		local PlateStroke = Lib.Create("UIStroke", { Thickness = 1, Transparency = 0.82, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromRGB(150, 150, 150) })
		local Plate = Lib.Create("Frame", {
			Name = "NavPlate", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.fromOffset(0, 0),
			BackgroundColor3 = Color3.fromRGB(22, 22, 22), BorderSizePixel = 0, Visible = false, ZIndex = 1, Parent = UI.TopNavContainer,
			PlateCorner, PlateStroke
		})

		local ThumbCorner = Lib.Create("UICorner", { CornerRadius = UDim.new(0, 7) })
		local ThumbStroke = Lib.Create("UIStroke", { Thickness = 1, Transparency = 0.88, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.new(0, 0, 0), Enabled = false })
		local Indicator = Lib.Create("Frame", {
			Name = "NavIndicator", Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.fromOffset(0, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0, Visible = false, ZIndex = 2, Parent = UI.TopNavContainer, ThumbCorner, ThumbStroke
		})

		local TipLabel = Lib.Create("TextLabel", {
			Size = UDim2.fromOffset(0, 0), AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, Text = "", TextSize = 12,
			Font = Enum.Font.GothamMedium, TextColor3 = Color3.fromRGB(240, 240, 240), ZIndex = 7
		})
		local TipStroke = Lib.Create("UIStroke", { Thickness = 1, Transparency = 0.75, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromRGB(150, 150, 150) })
		local Tip = Lib.Create("Frame", {
			Name = "NavTip", Size = UDim2.fromOffset(0, 0), AutomaticSize = Enum.AutomaticSize.XY, BackgroundColor3 = Color3.fromRGB(22, 22, 22),
			BorderSizePixel = 0, Visible = false, ZIndex = 6, Parent = UI.TopNavContainer,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }), TipStroke,
			Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 9), PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5) }),
			TipLabel
		})

		local function Context()
			local theme, palette, light = Lib.Theme, Lib.Palette, State.LightTheme
			local active
			for i = 1, TAB_COUNT do
				if NavTabsData[i].id == State.ActiveMain then
					active = i
					break
				end
			end
			return {
				hover = UI.CurrentHoveredNav, active = active,
				primary = palette.Primary, secondary = palette.Secondary, onPrimary = theme.Main, plate = theme.Item,
				thumb = light and Color3.new(1, 1, 1) or Lib.Lighten(theme.Item, 0.16),
				tile = light and theme.Item:Lerp(Color3.new(0, 0, 0), 0.07) or Lib.Lighten(theme.Item, 0.1)
			}
		end

		Layouts.Classic = function(c, instant)
			local isWhite = State.LightTheme
			local widths, totalWidth = {}, 0
			for i, tab in ipairs(NavTabsData) do
				widths[i] = (c.hover == i) and tab.expWidth or BASE_TAB_WIDTH
				totalWidth = totalWidth + widths[i]
			end
			totalWidth = totalWidth + (TAB_COUNT - 1) * TAB_GAP
			local currentX = -totalWidth / 2
			local activeColor = isWhite and Color3.fromRGB(15, 15, 15) or Color3.fromRGB(255, 255, 255)
			local inactiveColor = isWhite and Color3.fromRGB(130, 130, 130) or Color3.fromRGB(150, 150, 150)
			for i = 1, TAB_COUNT do
				local elem, w = UI.NavElements[i], widths[i]
				local isHover, isActive = c.hover == i, c.active == i
				Go(elem.Container, 0.22, Cubic, { Position = UDim2.new(0.5, currentX, 0, 0), Size = UDim2.fromOffset(w, 36), BackgroundTransparency = 1 }, instant)
				Go(elem.Icon, 0.2, Quad, {
					Position = isHover and UDim2.new(0, 7, 0.5, -9) or UDim2.new(0.5, -9, 0.5, -9), Size = UDim2.fromOffset(18, 18),
					ImageColor3 = (isActive or isHover) and activeColor or inactiveColor, ImageTransparency = 0
				}, instant)
				Go(elem.Text, 0.2, Quad, { TextTransparency = isHover and 0 or 1, TextColor3 = (isActive or isHover) and activeColor or inactiveColor }, instant)
				local lineWidth = isActive and (isHover and (w - 14) or 18) or 0
				elem.Line.BackgroundColor3 = activeColor
				Go(elem.Line, 0.2, Quad, {
					Position = UDim2.new(0, isHover and 7 or (w / 2 - lineWidth / 2), 1, -2), Size = UDim2.fromOffset(lineWidth, 2)
				}, instant)
				currentX = currentX + w + TAB_GAP
			end
		end

		Layouts["Floating Dock"] = function(c, instant)
			local sizes, total = {}, 0
			for i = 1, TAB_COUNT do
				local distance = c.hover and math.abs(c.hover - i)
				sizes[i] = distance == 0 and 46 or distance == 1 and 42 or 38
				total = total + sizes[i]
			end
			total = total + (TAB_COUNT - 1) * 6
			local x, tipX = -total / 2, nil
			for i = 1, TAB_COUNT do
				local elem, s = UI.NavElements[i], sizes[i]
				local isActive, isHover = c.active == i, c.hover == i
				local icon = s - 18
				Go(elem.Container, 0.2, Cubic, { Position = UDim2.new(0.5, x, 0, 18 - s / 2), Size = UDim2.fromOffset(s, s), BackgroundTransparency = 1 }, instant)
				Go(elem.Icon, 0.2, Quad, {
					Size = UDim2.fromOffset(icon, icon), Position = UDim2.new(0.5, -icon / 2, 0.5, -icon / 2 - (isActive and 2 or 0)),
					ImageColor3 = (isActive or isHover) and c.primary or c.secondary, ImageTransparency = 0
				}, instant)
				Go(elem.Text, 0.15, Quad, { TextTransparency = 1 }, instant)
				elem.Line.BackgroundColor3 = c.primary
				Go(elem.Line, 0.2, Quad, {
					Position = UDim2.new(0.5, isActive and -2 or 0, 1, isActive and -7 or -5), Size = UDim2.fromOffset(isActive and 4 or 0, isActive and 4 or 0)
				}, instant)
				if isHover then tipX = x + s / 2 end
				x = x + s + 6
			end
			Go(Plate, 0.2, Cubic, { Position = UDim2.new(0.5, 0, 0, -5), Size = UDim2.fromOffset(total + 20, 46), BackgroundColor3 = c.plate }, instant)
			PlateStroke.Color = c.secondary
			TipStroke.Color = c.secondary
			Tip.BackgroundColor3 = c.plate
			TipLabel.TextColor3 = c.primary
			if tipX then
				TipLabel.Text = Lib.Tr(NavTabsData[c.hover].title)
				Tip.AnchorPoint = Vector2.new(0.5, 0)
				Tip.Position = UDim2.new(0.5, tipX, 0, 46)
				Tip.Visible = true
			else
				Tip.Visible = false
			end
		end

		Layouts["Floating Pill"] = function(c, instant)
			local widths, total = {}, 0
			for i, tab in ipairs(NavTabsData) do
				widths[i] = c.active == i and tab.expWidth + 8 or 34
				total = total + widths[i]
			end
			total = total + (TAB_COUNT - 1) * 4
			local x, activeX, activeW = -total / 2, nil, nil
			for i = 1, TAB_COUNT do
				local elem, w = UI.NavElements[i], widths[i]
				local isActive, isHover = c.active == i, c.hover == i
				Go(elem.Container, 0.25, Cubic, { Position = UDim2.new(0.5, x, 0, 2), Size = UDim2.fromOffset(w, 32), BackgroundTransparency = 1 }, instant)
				Go(elem.Icon, 0.22, Quad, {
					Position = isActive and UDim2.new(0, 10, 0.5, -9) or UDim2.new(0.5, -9, 0.5, -9), Size = UDim2.fromOffset(18, 18),
					ImageColor3 = isActive and c.onPrimary or (isHover and c.primary or c.secondary), ImageTransparency = 0
				}, instant)
				Go(elem.Text, 0.22, Quad, { TextTransparency = isActive and 0 or 1, TextColor3 = c.onPrimary }, instant)
				Go(elem.Line, 0.15, Quad, { Size = UDim2.fromOffset(0, 0) }, instant)
				if isActive then activeX, activeW = x, w end
				x = x + w + 4
			end
			Go(Plate, 0.25, Cubic, { Position = UDim2.new(0.5, 0, 0, -2), Size = UDim2.fromOffset(total + 8, 40), BackgroundColor3 = c.plate }, instant)
			PlateStroke.Color = c.secondary
			if activeX then
				Go(Indicator, 0.25, Cubic, { Position = UDim2.new(0.5, activeX, 0, 2), Size = UDim2.fromOffset(activeW, 32), BackgroundColor3 = c.primary }, instant)
			end
			Tip.Visible = false
		end

		Layouts.Segmented = function(c, instant)
			local total = SEGMENT_WIDTH * TAB_COUNT
			local x, activeX = -total / 2, nil
			for i = 1, TAB_COUNT do
				local elem = UI.NavElements[i]
				local isActive, isHover = c.active == i, c.hover == i
				Go(elem.Container, 0.25, Cubic, { Position = UDim2.new(0.5, x, 0, 3), Size = UDim2.fromOffset(SEGMENT_WIDTH, 28), BackgroundTransparency = 1 }, instant)
				Go(elem.Icon, 0.15, Quad, { ImageTransparency = 1, Position = UDim2.new(0.5, -9, 0.5, -9), Size = UDim2.fromOffset(18, 18) }, instant)
				Go(elem.Text, 0.2, Quad, { TextTransparency = 0, TextColor3 = (isActive or isHover) and c.primary or c.secondary }, instant)
				Go(elem.Line, 0.15, Quad, { Size = UDim2.fromOffset(0, 0) }, instant)
				if isActive then activeX = x end
				x = x + SEGMENT_WIDTH
			end
			Go(Plate, 0.25, Cubic, { Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.fromOffset(total + 6, 34), BackgroundColor3 = c.plate }, instant)
			PlateStroke.Color = c.secondary
			if activeX then
				Go(Indicator, 0.3, Quint, { Position = UDim2.new(0.5, activeX, 0, 3), Size = UDim2.fromOffset(SEGMENT_WIDTH, 28), BackgroundColor3 = c.thumb }, instant)
			end
			Tip.Visible = false
		end

		Layouts["Icon Rail"] = function(c, instant)
			local tipY, activeY
			for i = 1, TAB_COUNT do
				local elem = UI.NavElements[i]
				local isActive, isHover = c.active == i, c.hover == i
				local y = 8 + (i - 1) * 42
				Go(elem.Container, 0.2, Cubic, {
					Position = UDim2.fromOffset(12, y), Size = UDim2.fromOffset(36, 36), BackgroundColor3 = c.primary,
					BackgroundTransparency = (isHover and not isActive) and 0.9 or 1
				}, instant)
				Go(elem.Icon, 0.2, Quad, {
					Position = UDim2.new(0.5, -10, 0.5, -10), Size = UDim2.fromOffset(20, 20),
					ImageColor3 = (isActive or isHover) and c.primary or c.secondary, ImageTransparency = 0
				}, instant)
				Go(elem.Text, 0.1, Quad, { TextTransparency = 1 }, instant)
				elem.Line.BackgroundColor3 = c.primary
				Go(elem.Line, 0.2, Quad, { Position = UDim2.new(0, -4, 0.5, isActive and -9 or 0), Size = UDim2.fromOffset(3, isActive and 18 or 0) }, instant)
				Go(elem.Corner, 0.2, Quad, { CornerRadius = UDim.new(0, (isActive or isHover) and 10 or 18) }, instant)
				if isHover then tipY = y end
				if isActive then activeY = y end
			end
			Go(Plate, 0.2, Quad, { BackgroundColor3 = c.plate }, instant)
			PlateStroke.Color = c.secondary
			if activeY then
				Go(Indicator, 0.25, Cubic, { Position = UDim2.fromOffset(12, activeY), Size = UDim2.fromOffset(36, 36), BackgroundColor3 = c.tile }, instant)
			end
			TipStroke.Color = c.secondary
			Tip.BackgroundColor3 = c.plate
			TipLabel.TextColor3 = c.primary
			if tipY then
				TipLabel.Text = Lib.Tr(NavTabsData[c.hover].title)
				Tip.AnchorPoint = Vector2.new(0, 0.5)
				Tip.Position = UDim2.fromOffset(RAIL_WIDTH + 2, tipY + 18)
				Tip.Visible = true
			else
				Tip.Visible = false
			end
		end

		function Lib.RecalculateNavPositions(instant)
			if not UI.NavElements[TAB_COUNT] then return end
			Layouts[State.NavStyle or "Classic"](Context(), instant == true)
		end

		for i, tab in ipairs(NavTabsData) do
			local TabCorner = Lib.Create("UICorner", { CornerRadius = UDim.new(0, 0) })
			local TabFrame = Lib.Create("TextButton", {
				Name = "NavTab_" .. tab.id,
				Size = UDim2.fromOffset(BASE_TAB_WIDTH, 36),
				Position = UDim2.new(0.5, 0, 0, 0),
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				ClipsDescendants = true,
				ZIndex = 3,
				Parent = UI.TopNavContainer,
				TabCorner
			})

			local TabIcon = Lib.Create("ImageLabel", {
				Size = UDim2.fromOffset(18, 18),
				Position = UDim2.new(0.5, -9, 0.5, -9),
				BackgroundTransparency = 1,
				Image = tab.icon,
				ImageColor3 = Color3.fromRGB(150, 150, 150),
				ScaleType = Enum.ScaleType.Fit,
				Parent = TabFrame
			})

			local TabText = Lib.Create("TextLabel", {
				Size = UDim2.new(1, -30, 1, 0),
				Position = UDim2.new(0, 30, 0, 0),
				BackgroundTransparency = 1,
				Text = tab.title,
				TextColor3 = Color3.fromRGB(150, 150, 150),
				TextSize = 13,
				Font = Enum.Font.GothamMedium,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTransparency = 1,
				Parent = TabFrame
			})

			local LineCorner = Lib.Create("UICorner", { CornerRadius = UDim.new(0, 1) })
			local TabLine = Lib.Create("Frame", {
				Size = UDim2.fromOffset(0, 2),
				Position = UDim2.new(0.5, -9, 1, -2),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				Parent = TabFrame,
				LineCorner
			})

			UI.NavElements[i] = {
				Container = TabFrame,
				Icon = TabIcon,
				Text = TabText,
				Line = TabLine,
				Corner = TabCorner,
				LineCorner = LineCorner,
				Data = tab
			}

			TabFrame.MouseEnter:Connect(function()
				UI.CurrentHoveredNav = i
				Lib.RecalculateNavPositions()
			end)

			TabFrame.MouseLeave:Connect(function()
				if UI.CurrentHoveredNav == i then
					UI.CurrentHoveredNav = nil
					Lib.RecalculateNavPositions()
				end
			end)

			TabFrame.MouseButton1Click:Connect(function()
				Lib.PlayClick()
				Lib.SwitchMainTab(tab.id)
			end)
		end

		function Lib.ApplyNavStyle(style, instant)
			if not Layouts[style] then style = "Classic" end
			State.NavStyle = style
			local rail, classic = style == "Icon Rail", style == "Classic"
			local dock, pill, segmented = style == "Floating Dock", style == "Floating Pill", style == "Segmented"
			local container = UI.TopNavContainer
			container.AnchorPoint = rail and Vector2.zero or Vector2.new(0.5, 0)
			container.Size = rail and UDim2.new(0, RAIL_WIDTH, 1, -58) or UDim2.fromOffset(460, 36)
			container.Position = Lib.NavPosition(State.Minimized and -44 or 11)
			UI.ContentArea.Position = UDim2.fromOffset(rail and RAIL_WIDTH or 0, 58)
			UI.ContentArea.Size = UDim2.new(1, rail and -RAIL_WIDTH or 0, 1, -58)
			Plate.Visible = not classic
			Plate.AnchorPoint = rail and Vector2.zero or Vector2.new(0.5, 0)
			if rail then
				Plate.Position = UDim2.fromOffset(8, 0)
				Plate.Size = UDim2.new(0, 44, 1, -8)
			end
			PlateCorner.CornerRadius = pill and UDim.new(0.5, 0) or UDim.new(0, dock and 15 or segmented and 9 or 12)
			Indicator.Visible = pill or segmented or rail
			ThumbCorner.CornerRadius = pill and UDim.new(0.5, 0) or UDim.new(0, segmented and 7 or 10)
			ThumbStroke.Enabled = segmented
			for i = 1, TAB_COUNT do
				local elem = UI.NavElements[i]
				local text = elem.Text
				elem.Container.ClipsDescendants = not rail
				elem.LineCorner.CornerRadius = classic and UDim.new(0, 1) or UDim.new(0.5, 0)
				if not rail then elem.Corner.CornerRadius = UDim.new(0, 0) end
				text.TextSize = segmented and 12 or 13
				if segmented then
					text.TextXAlignment = Enum.TextXAlignment.Center
					text.Position = UDim2.new()
					text.Size = UDim2.fromScale(1, 1)
				else
					text.TextXAlignment = Enum.TextXAlignment.Left
					text.Position = UDim2.fromOffset(pill and 34 or 30, 0)
					text.Size = UDim2.new(1, pill and -38 or -30, 1, 0)
				end
			end
			Tip.Visible = false
			Lib.RecalculateNavPositions(instant)
		end

		function Lib.CreateNavStylePicker(parentCard)
			local roles, cards, dots = {}, {}, {}
			local R1, R2, R3, RF = UDim.new(0, 1), UDim.new(0, 2), UDim.new(0, 3), UDim.new(0.5, 0)
			local CARD_W, CARD_H, STEP, VIEW_H = 140, 112, 130, 124
			local SCREEN_W, SCREEN_H = CARD_W - 12, 70
			local focus = table.find(STYLES, State.NavStyle) or 1
			local viewport, Focus, Layout, Paint, prevButton, nextButton

			local function Shown(gui)
				while gui and gui:IsA("GuiObject") do
					if not gui.Visible then return false end
					gui = gui.Parent
				end
				return true
			end

			local function Box(parent, x, y, w, h, role, radius)
				local frame = Lib.Create("Frame", { Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h), BorderSizePixel = 0, Parent = parent })
				if radius then Lib.Create("UICorner", { CornerRadius = radius, Parent = frame }) end
				roles[#roles + 1] = { frame, role }
				return frame
			end

			local function Content(p, y, h)
				Box(p, 6, y, 76, h, "card", R3)
				Box(p, 11, y + 5, 40, 3, "item", R1)
				Box(p, 11, y + 12, 26, 3, "item", R1)
			end

			local function At(x, y)
				return UDim2.fromOffset(x, y)
			end

			local Previews = {
				Classic = function(p)
					for i = 0, 4 do Box(p, 24 + i * 9, 4, 5, 5, "dim", R1) end
					local mark = Box(p, 33, 4, 5, 5, "bright", R1)
					local line = Box(p, 33, 11, 5, 1, "bright")
					Content(p, 16, 26)
					return 1, 5, function(i)
						local x = 24 + i * 9
						return { { mark, { Position = At(x, 4) } }, { line, { Position = At(x, 11) } } }
					end
				end,
				["Floating Dock"] = function(p)
					Box(p, 22, 2, 44, 13, "item", UDim.new(0, 5))
					for i = 0, 4 do Box(p, 26 + i * 8, 5, 5, 5, "dim", R2) end
					local big = Box(p, 41, 4, 7, 7, "bright", R2)
					local dot = Box(p, 43, 12, 2, 2, "bright", RF)
					Content(p, 19, 23)
					return 2, 5, function(i)
						return { { big, { Position = At(25 + i * 8, 4) } }, { dot, { Position = At(27 + i * 8, 12) } } }
					end
				end,
				["Floating Pill"] = function(p)
					local stops = { 20, 28, 38, 52 }
					Box(p, 18, 3, 54, 11, "item", RF)
					for i = 0, 3 do Box(p, 45 + i * 7, 6, 4, 4, "dim", RF) end
					local thumb = Box(p, 20, 5, 18, 7, "bright", RF)
					local label = Box(p, 26, 8, 7, 1, "main")
					Content(p, 19, 23)
					return 0, 4, function(i)
						local x = stops[i + 1]
						return { { thumb, { Position = At(x, 5) } }, { label, { Position = At(x + 6, 8) } } }
					end
				end,
				Segmented = function(p)
					Box(p, 18, 3, 52, 11, "item", R2)
					local thumb = Box(p, 29, 4, 10, 9, "thumb", R2)
					for i = 0, 4 do Box(p, 21 + i * 10, 8, 6, 1, "dim") end
					local mark = Box(p, 31, 8, 6, 1, "bright")
					Content(p, 19, 23)
					return 1, 5, function(i)
						return { { thumb, { Position = At(19 + i * 10, 4) } }, { mark, { Position = At(21 + i * 10, 8) } } }
					end
				end,
				["Icon Rail"] = function(p)
					Box(p, 3, 3, 11, 43, "item", UDim.new(0, 4))
					local thumb = Box(p, 4, 13, 9, 9, "thumb", R2)
					local bar = Box(p, 3, 14, 1, 7, "bright")
					for i = 0, 4 do Box(p, 6, 7 + i * 8, 5, 5, "dim", R1) end
					local mark = Box(p, 6, 15, 5, 5, "bright", R1)
					Box(p, 18, 3, 64, 42, "card", R3)
					Box(p, 23, 9, 36, 3, "item", R1)
					Box(p, 23, 16, 24, 3, "item", R1)
					return 1, 5, function(i)
						return { { thumb, { Position = At(4, 5 + i * 8) } }, { bar, { Position = At(3, 6 + i * 8) } }, { mark, { Position = At(6, 7 + i * 8) } } }
					end
				end
			}

			local function Hover()
				if State.LightTheme then return Lib.Theme.Item:Lerp(Color3.new(0, 0, 0), 0.06) end
				return Lib.Lighten(Lib.Theme.Item, 0.07)
			end

			local function Snap(c, index)
				for _, pair in ipairs(c.Move(index)) do
					for prop, value in pairs(pair[2]) do pair[1][prop] = value end
				end
			end

			local function Animate(c, on)
				c.Token += 1
				local token = c.Token
				if not on then
					local back = TweenInfo.new(0.25, Quint, Out)
					for _, pair in ipairs(c.Move(c.Rest)) do
						Services.Tween:Create(pair[1], back, pair[2]):Play()
					end
					return
				end
				local info = TweenInfo.new(0.34, Quint, Out)
				task.spawn(function()
					local index = c.Rest
					while c.Token == token and not State.Unloaded do
						if not Shown(c.Card) then
							Snap(c, c.Rest)
							return
						end
						index = (index + 1) % c.Count
						for _, pair in ipairs(c.Move(index)) do
							Services.Tween:Create(pair[1], info, pair[2]):Play()
						end
						task.wait(0.62)
					end
				end)
			end

			local item = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 196), BackgroundTransparency = 1, Parent = parentCard })

			local titleLabel = Lib.Create("TextLabel", {
				Size = UDim2.new(1, -28, 0, 16), Position = UDim2.fromOffset(14, 12), BackgroundTransparency = 1, Text = "Navigation Style",
				TextColor3 = Color3.fromRGB(240, 240, 240), TextSize = 13, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = item
			})
			Lib.RegisterThemeText(titleLabel, "Primary")

			local descLabel = Lib.Create("TextLabel", {
				Size = UDim2.new(1, -28, 0, 14), Position = UDim2.fromOffset(14, 30), BackgroundTransparency = 1,
				Text = "Choose how the tab bar looks. Tabs work the same in every style.", TextColor3 = Color3.fromRGB(130, 130, 130),
				TextSize = 11, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = item
			})
			Lib.RegisterThemeText(descLabel, "Secondary")

			viewport = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, VIEW_H), Position = UDim2.fromOffset(0, 50), BackgroundTransparency = 1, ClipsDescendants = true, Parent = item })

			local dotRow = Lib.Create("Frame", {
				Size = UDim2.new(1, 0, 0, 6), Position = UDim2.fromOffset(0, 182), BackgroundTransparency = 1, Parent = item,
				Lib.Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder })
			})

			Lib.Create("Frame", {
				Size = UDim2.new(1, -28, 0, 1), Position = UDim2.fromOffset(14, 195), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.9,
				BorderSizePixel = 0, Parent = item
			})

			local function BuildCard(index, name)
				local scale = Lib.Create("UIScale", { Scale = 1 })
				local stroke = Lib.Create("UIStroke", { Thickness = 1, Transparency = 0.85, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromRGB(150, 150, 150) })
				local card = Lib.Create("CanvasGroup", {
					AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(CARD_W, CARD_H), Position = UDim2.fromScale(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(22, 22, 22), BorderSizePixel = 0, Parent = viewport,
					Lib.Create("UICorner", { CornerRadius = UDim.new(0, 10) }), stroke, scale
				})
				local screen = Lib.Create("Frame", {
					Position = UDim2.fromOffset(6, 6), Size = UDim2.fromOffset(SCREEN_W, SCREEN_H), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0,
					ClipsDescendants = true, Parent = card, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 7) })
				})
				local canvas = Lib.Create("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(88, 48), BackgroundTransparency = 1, Parent = screen,
					Lib.Create("UIScale", { Scale = SCREEN_W / 88 })
				})
				local rest, count, move = Previews[name](canvas)
				local caption = Lib.Create("TextLabel", {
					Position = UDim2.fromOffset(0, 84), Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = name, TextSize = 12,
					Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(150, 150, 150), Parent = card
				})
				local hit = Lib.Create("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 5, Parent = card })
				local c = { Card = card, Screen = screen, Stroke = stroke, Caption = caption, Scale = scale, Hit = hit, Rest = rest, Count = count, Move = move, Token = 0 }
				cards[index] = c

				hit.MouseEnter:Connect(function()
					Lib.Tween(card, 0.12, Quad, Out, { BackgroundColor3 = Hover() })
					Animate(c, true)
				end)
				hit.MouseLeave:Connect(function()
					Lib.Tween(card, 0.12, Quad, Out, { BackgroundColor3 = Lib.Theme.Item })
					Animate(c, false)
				end)
				hit.InputBegan:Connect(function(input)
					local kind = input.UserInputType
					if kind ~= Enum.UserInputType.MouseButton1 and kind ~= Enum.UserInputType.Touch then return end
					local startX = input.Position.X
					local connection
					connection = input.Changed:Connect(function()
						if input.UserInputState ~= Enum.UserInputState.End then return end
						connection:Disconnect()
						local delta = input.Position.X - startX
						if math.abs(delta) > 36 then
							Lib.PlayClick()
							Focus(focus + (delta < 0 and 1 or -1))
						elseif index ~= focus then
							Lib.PlayClick()
							Focus(index)
						end
					end)
				end)

				local dot = Lib.Create("TextButton", {
					Size = UDim2.fromOffset(6, 6), Text = "", AutoButtonColor = false, LayoutOrder = index, BackgroundColor3 = Color3.fromRGB(150, 150, 150), BorderSizePixel = 0, Parent = dotRow,
					Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
				})
				dot.MouseButton1Click:Connect(function()
					Lib.PlayClick()
					Focus(index)
				end)
				dots[index] = dot
			end

			for index, name in ipairs(STYLES) do BuildCard(index, name) end

			local function Arrow(side, text)
				local right = side > 0
				local button = Lib.Create("TextButton", {
					Size = UDim2.fromOffset(26, 26), AnchorPoint = Vector2.new(right and 1 or 0, 0.5), Position = UDim2.new(right and 1 or 0, right and -6 or 6, 0.5, 0),
					BackgroundColor3 = Color3.fromRGB(22, 22, 22), Text = text, TextColor3 = Color3.fromRGB(240, 240, 240), TextSize = 18, Font = Enum.Font.GothamBold,
					AutoButtonColor = false, ZIndex = 30, Parent = viewport, Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
				})
				button.MouseButton1Click:Connect(function()
					Lib.PlayClick()
					Focus(focus + side)
				end)
				return button
			end
			prevButton, nextButton = Arrow(-1, "‹"), Arrow(1, "›")

			function Layout(instant)
				local width = viewport.AbsoluteSize.X
				if width <= 0 then return end
				local info = TweenInfo.new(0.42, Quint, Out)
				for index = 1, #STYLES do
					local c = cards[index]
					local d = index - focus
					local ad = math.abs(d)
					local position = UDim2.new(0, width / 2 + d * STEP, 0.5, 0)
					local fade = ad == 0 and 0 or ad == 1 and 0.55 or 1
					local size = ad == 0 and 1 or ad == 1 and 0.82 or 0.66
					c.Card.ZIndex = 10 - ad
					c.Hit.Visible = ad <= 1
					if instant then
						c.Card.Position, c.Card.GroupTransparency, c.Scale.Scale = position, fade, size
					else
						Services.Tween:Create(c.Card, info, { Position = position, GroupTransparency = fade }):Play()
						Services.Tween:Create(c.Scale, info, { Scale = size }):Play()
					end
				end
			end

			function Paint()
				local theme, palette = Lib.Theme, Lib.Palette
				local K = {
					main = theme.Main, card = theme.Card, item = theme.Item, bright = palette.Primary, dim = palette.Secondary,
					thumb = State.LightTheme and Color3.new(1, 1, 1) or Lib.Lighten(theme.Item, 0.16)
				}
				for i = 1, #roles do
					local role = roles[i]
					role[1].BackgroundColor3 = K[role[2]]
				end
				for index = 1, #STYLES do
					local c = cards[index]
					local selected = index == focus
					c.Card.BackgroundColor3 = theme.Item
					c.Screen.BackgroundColor3 = theme.Main
					Lib.Tween(c.Stroke, 0.22, Quad, Out, {
						Color = selected and palette.SwitchOn or palette.Secondary, Thickness = selected and 2 or 1, Transparency = selected and 0 or 0.85
					})
					Lib.Tween(c.Caption, 0.22, Quad, Out, { TextColor3 = selected and palette.Primary or palette.Secondary })
					local dot = dots[index]
					dot.BackgroundColor3 = selected and palette.Primary or palette.Secondary
					dot.BackgroundTransparency = selected and 0 or 0.55
					Lib.Tween(dot, 0.25, Quint, Out, { Size = UDim2.fromOffset(selected and 18 or 6, 6) })
				end
				prevButton.BackgroundColor3, nextButton.BackgroundColor3 = theme.Item, theme.Item
				prevButton.TextColor3 = focus > 1 and palette.Primary or palette.Secondary
				nextButton.TextColor3 = focus < #STYLES and palette.Primary or palette.Secondary
			end

			function Focus(index, instant)
				index = math.clamp(index, 1, #STYLES)
				focus = index
				Layout(instant)
				Paint()
				local name = STYLES[index]
				if State.NavStyle ~= name then Lib.ApplyNavStyle(name, instant) end
			end

			Lib.ChoiceControls["Navigation Style"] = {
				Get = function() return State.NavStyle end,
				Set = function(value)
					local index = table.find(STYLES, value)
					if index then Focus(index, true) end
				end
			}

			viewport:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() Layout(true) end)
			table.insert(Lib.ThemeHooks, Paint)
			Layout(true)
			Paint()
			Lib.SearchAdd(parentCard, item, "Navigation Style")
			return item
		end
	end

	Lib.StartStats()
	Lib.BuildToggleButton()
end


-- ══════════════════════════════════════════════════════════════════════════
--  TOGGLE BUTTON · Classic / Dynamic Island
-- ══════════════════════════════════════════════════════════════════════════

function Lib.BuildToggleButton()
	do
		local UIS = Services.UserInputService
		local TweenService = Services.Tween
		local touchOnly = UIS.TouchEnabled and not UIS.MouseEnabled
		local REST, FULL, PRESS = Vector2.new(100, 32), Vector2.new(256, 44), 0.93
		local WHITE, MUTED = Color3.fromRGB(245, 245, 245), "#8E8E93"
		local DOT_ON, DOT_OFF = Color3.fromRGB(52, 199, 89), Color3.fromRGB(88, 88, 92)
		local STROKE_ON, STROKE_OFF = Color3.fromRGB(86, 86, 92), Color3.fromRGB(40, 40, 44)
		local BACK, QUINT, QUAD, OUT = Enum.EasingStyle.Back, Enum.EasingStyle.Quint, Enum.EasingStyle.Quad, Enum.EasingDirection.Out

		local function Scaled(v, k)
			return UDim2.fromOffset(v.X * k, v.Y * k)
		end

		local function Fade(group, value, time, delay)
			TweenService:Create(group, TweenInfo.new(time, QUAD, OUT, 0, false, delay), { GroupTransparency = value }):Play()
		end

		local function Attach(button, onPress, onRelease)
			local dragging, moved, origin, start = false, false, nil, nil
			button.InputBegan:Connect(function(input)
				local kind = input.UserInputType
				if kind == Enum.UserInputType.MouseButton1 or kind == Enum.UserInputType.Touch then
					dragging, moved = true, false
					origin, start = input.Position, button.Position
					onPress()
				end
			end)
			Lib.C(UIS.InputChanged, function(input)
				if not dragging then return end
				local kind = input.UserInputType
				if kind == Enum.UserInputType.MouseMovement or kind == Enum.UserInputType.Touch then
					local delta = input.Position - origin
					if delta.Magnitude > 4 then moved = true end
					if moved then
						button.Position = UDim2.new(start.X.Scale, start.X.Offset + delta.X, start.Y.Scale, start.Y.Offset + delta.Y)
					end
				end
			end)
			Lib.C(UIS.InputEnded, function(input)
				local kind = input.UserInputType
				if dragging and (kind == Enum.UserInputType.MouseButton1 or kind == Enum.UserInputType.Touch) then
					dragging = false
					onRelease(moved)
				end
			end)
			return function() return dragging end
		end

		local classic = Lib.Create("TextButton", {
			Name = "SH_FloatingToggle",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(46, 46),
			Position = UDim2.new(0, 43, 0.5, 0),
			BackgroundColor3 = Color3.fromRGB(18, 18, 18),
			Text = "SH",
			TextColor3 = Color3.fromRGB(245, 245, 245),
			TextSize = 16,
			Font = Enum.Font.GothamBold,
			AutoButtonColor = false,
			Visible = false,
			ZIndex = 120,
			Parent = UI.Screen,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
			Lib.Create("UIStroke", {
				Color = Color3.fromRGB(60, 60, 60),
				Thickness = 1.5,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			})
		})
		Lib.RegisterThemeElement(classic, "BackgroundColor3", 0.5)
		Lib.RegisterThemeText(classic, "Primary")

		Attach(classic, function()
			Lib.Tween(classic, 0.1, QUAD, OUT, { Size = UDim2.fromOffset(40, 40) })
		end, function(moved)
			Lib.Tween(classic, 0.18, BACK, OUT, { Size = UDim2.fromOffset(46, 46) })
			if not moved then
				Lib.PlayClick()
				Lib.ToggleMenu()
			end
		end)

		local island = Lib.Create("TextButton", {
			Name = "SH_DynamicIsland",
			AnchorPoint = Vector2.new(0.5, 0),
			Size = Scaled(REST, 1),
			Position = UDim2.new(0.5, 0, 0, 10),
			BackgroundColor3 = Color3.new(0, 0, 0),
			Text = "",
			AutoButtonColor = false,
			Visible = false,
			ZIndex = 120,
			Parent = UI.Screen,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0.5, 0) })
		})
		local stroke = Lib.Create("UIStroke", {
			Color = STROKE_OFF,
			Thickness = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Parent = island
		})

		local idle = Lib.Create("CanvasGroup", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 121, Parent = island })
		Lib.Create("TextLabel", {
			Size = UDim2.fromOffset(32, 20),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 16, 0.5, 0),
			BackgroundTransparency = 1,
			Text = "SH",
			TextColor3 = WHITE,
			TextSize = 14,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 122,
			Parent = idle
		})
		local dot = Lib.Create("Frame", {
			Size = UDim2.fromOffset(8, 8),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -16, 0.5, 0),
			BackgroundColor3 = DOT_OFF,
			ZIndex = 122,
			Parent = idle,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0.5, 0) })
		})

		local info = Lib.Create("CanvasGroup", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, GroupTransparency = 1, ZIndex = 121, Parent = island })
		local cells = {}
		for i, key in ipairs({ "FPS", "Ping", "Players" }) do
			cells[key] = Lib.Create("TextLabel", {
				Size = UDim2.fromScale(1 / 3, 1),
				Position = UDim2.fromScale((i - 1) / 3, 0),
				BackgroundTransparency = 1,
				RichText = true,
				Text = "",
				TextColor3 = WHITE,
				TextSize = 13,
				Font = Enum.Font.GothamBold,
				ZIndex = 122,
				Parent = info
			})
			if i > 1 then
				Lib.Create("Frame", {
					Size = UDim2.fromOffset(1, 16),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new((i - 1) / 3, 0, 0.5, 0),
					BackgroundColor3 = Color3.fromRGB(60, 60, 66),
					BorderSizePixel = 0,
					ZIndex = 122,
					Parent = info
				})
			end
		end

		local function UpdateInfo()
			local stats = Lib.Stats
			cells.FPS.Text = string.format('<font color="%s">%s</font> %d', MUTED, Lib.Tr("FPS"), stats.FPS or 0)
			cells.Ping.Text = string.format('<font color="%s">%s</font> %d%s', MUTED, Lib.Tr("Ping"), stats.Ping or 0, Lib.Tr("ms"))
			cells.Players.Text = string.format('<font color="%s">%s</font> %d', MUTED, Lib.Tr("Players"), stats.Players or 0)
		end

		local over, peeking, expanded, pressed, peekToken = false, false, false, false, 0

		local function Rest()
			return Scaled(expanded and FULL or REST, pressed and PRESS or 1)
		end

		local function Sync()
			local want = over or peeking
			if want == expanded then return end
			expanded = want
			if want then UpdateInfo() end
			Lib.Tween(island, want and 0.45 or 0.32, want and BACK or QUINT, OUT, { Size = Rest() })
			Fade(idle, want and 1 or 0, want and 0.12 or 0.2, want and 0 or 0.1)
			Fade(info, want and 0 or 1, want and 0.22 or 0.1, want and 0.1 or 0)
			Lib.Tween(stroke, 0.25, QUAD, OUT, { Color = want and STROKE_ON or STROKE_OFF })
		end

		local function SyncDot(pulse)
			local open = UI.Main.Visible and not State.MenuHiding
			Lib.Tween(dot, 0.25, QUAD, OUT, { BackgroundColor3 = open and DOT_ON or DOT_OFF })
			if pulse then
				dot.Size = UDim2.fromOffset(13, 13)
				Lib.Tween(dot, 0.4, BACK, OUT, { Size = UDim2.fromOffset(8, 8) })
			end
		end

		local function Peek()
			peekToken = peekToken + 1
			local token = peekToken
			peeking = true
			Sync()
			task.delay(1.8, function()
				if token == peekToken then
					peeking = false
					Sync()
				end
			end)
		end

		local isDragging = Attach(island, function()
			pressed = true
			Lib.Tween(island, 0.12, QUAD, OUT, { Size = Rest() })
		end, function(moved)
			pressed = false
			Lib.Tween(island, 0.4, BACK, OUT, { Size = Rest() })
			if moved then
				Sync()
				return
			end
			Lib.PlayClick()
			Lib.ToggleMenu()
			SyncDot(true)
			if touchOnly then Peek() end
		end)

		if not touchOnly then
			island.MouseEnter:Connect(function()
				over = true
				Sync()
			end)
			island.MouseLeave:Connect(function()
				over = false
				if not isDragging() then Sync() end
			end)
		end

		Lib.C(UI.Main:GetPropertyChangedSignal("Visible"), function()
			SyncDot(false)
		end)

		Lib.StatsTick[#Lib.StatsTick + 1] = function()
			if expanded then UpdateInfo() end
		end

		local saved = {}
		UI.SHToggleButton = classic

		function Lib.SetSHStyle(style, instant)
			local target = style == "Dynamic Island" and island or classic
			State.SHStyle = target == island and "Dynamic Island" or "Classic"
			local old = UI.SHToggleButton
			if old == target then return end
			saved[old] = old.Position
			if saved[target] then target.Position = saved[target] end
			local visible = old.Visible
			old.Visible = false
			target.Visible = visible
			UI.SHToggleButton = target
			if target == island then
				over, peeking, expanded, pressed = false, false, false, false
				peekToken = peekToken + 1
				info.GroupTransparency = 1
				idle.GroupTransparency = 0
				stroke.Color = STROKE_OFF
				island.Size = Scaled(REST, 1)
				SyncDot(false)
				if visible and not instant then
					island.Size = Scaled(REST, 0.4)
					idle.GroupTransparency = 1
					Lib.Tween(island, 0.5, BACK, OUT, { Size = Scaled(REST, 1) })
					Fade(idle, 0, 0.3, 0.1)
				end
			elseif visible and not instant then
				classic.Size = UDim2.fromOffset(14, 14)
				classic.TextTransparency = 1
				Lib.Tween(classic, 0.45, BACK, OUT, { Size = UDim2.fromOffset(46, 46) })
				Lib.Tween(classic, 0.3, QUAD, OUT, { TextTransparency = 0 })
			end
		end

		if State.SHStyle ~= "Classic" then
			Lib.SetSHStyle(State.SHStyle, true)
		end
	end
end


-- ══════════════════════════════════════════════════════════════════════════
--  START SEQUENCE · intro, start screen, launch
-- ══════════════════════════════════════════════════════════════════════════


function Lib.Prepare()
	Lib.RecalculateNavPositions()
	if State.NavStyle ~= "Classic" and Lib.ApplyNavStyle then Lib.ApplyNavStyle(State.NavStyle, true) end
	for _, system in ipairs(Lib.TabSystems) do
		local first, best
		for name, y in pairs(system.Order) do
			if not best or y < best then first, best = name, y end
		end
		if first then system.Switch(first) end
	end
	if Lib.NavTabs[1] then Lib.SwitchMainTab(Lib.NavTabs[1].id) end
	task.delay(4, function() Lib.CascadeReady = true end)
	Lib.ApplyTheme(Lib.ResolveTheme(State.SelectedThemeIndex) or State.CustomTheme or State.ThemeColor)
end

function Lib.Launch(isMobileVersion, autoResolution)
	local Back, Out = Enum.EasingStyle.Back, Enum.EasingDirection.Out
	local scaleObj = UI.Main:FindFirstChild("SeptusScale") or Instance.new("UIScale")
	scaleObj.Name = "SeptusScale"
	local scaleCap = isMobileVersion and (1 / 1.5) or nil
	scaleObj.Scale = autoResolution and Lib.FitMenuScale(scaleCap) or scaleCap or 1
	scaleObj.Parent = UI.Main
	UI.MainScale = scaleObj
	Lib.MenuBaseScale = scaleObj.Scale

	local refitToken = 0
	if autoResolution then
		Lib.C(UI.Screen:GetPropertyChangedSignal("AbsoluteSize"), function()
			refitToken += 1
			local mine = refitToken
			task.delay(0.25, function()
				if mine ~= refitToken or State.Unloaded or not scaleObj.Parent or not UI.Main.Visible or Lib.WindowBusy() then return end
				local fitted = Lib.FitMenuScale(scaleCap)
				if math.abs(fitted - Lib.MenuBaseScale) < 0.01 then return end
				scaleObj.Scale, Lib.MenuBaseScale = fitted, fitted
				UI.Main.Size, UI.Main.Position = Lib.MainLayout()
			end)
		end)
	end

	UI.Main.Size = UDim2.fromOffset(760, 510)
	UI.Main.Visible = true
	Lib.Tween(UI.Main, 0.4, Back, Out, { Size = State.OriginalSize })

	if UI.SHToggleButton then
		UI.SHToggleButton.Visible = true
	end
	Lib.Version.Start()
	local record = Lib.InstanceKey and env[Lib.InstanceKey]
	if record then record.Ready = true end
end

function Lib.PlaySplash(Blur)
	Blur = Blur or Lib.Create("BlurEffect", { Name = Lib.Config.Name .. "_IntroBlur", Size = 0, Parent = Services.Lighting })
	Refs.IntroBlur = Blur
	Lib.Tween(Blur, 0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Size = 28 })

	local Quint, Quad, Sine, Back = Enum.EasingStyle.Quint, Enum.EasingStyle.Quad, Enum.EasingStyle.Sine, Enum.EasingStyle.Back
	local Out, InOut = Enum.EasingDirection.Out, Enum.EasingDirection.InOut
	local White, Muted = Color3.fromRGB(255, 255, 255), Color3.fromRGB(150, 150, 150)
	local Loops, Slots = {}, {}

	local function Loop(inst, info, goal)
		local tween = Services.Tween:Create(inst, info, goal)
		Loops[#Loops + 1] = tween
		tween:Play()
	end

	local SplashModal = Lib.Create("CanvasGroup", {
		Name = Lib.Config.Name .. "_Splash", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(6, 6, 6), BackgroundTransparency = 0.3,
		GroupTransparency = 1, ZIndex = 50, Parent = UI.Screen
	})

	local Backdrop = Lib.Create("Frame", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 50, Parent = SplashModal
	})

	local drift = TweenInfo.new(9, Sine, InOut, -1, true)
	for _, glow in ipairs({
		{ 520, UDim2.fromScale(0.22, 0.3), UDim2.fromScale(0.34, 0.44), 0.94 },
		{ 620, UDim2.fromScale(0.8, 0.72), UDim2.fromScale(0.66, 0.58), 0.955 }
	}) do
		Loop(Lib.Create("ImageLabel", {
			Size = UDim2.fromOffset(glow[1], glow[1]), Position = glow[2], AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1,
			Image = "rbxassetid://1316045217", ImageColor3 = White, ImageTransparency = glow[4], ZIndex = 50, Parent = Backdrop
		}), drift, { Position = glow[3] })
	end

	for _ = 1, 18 do
		local x, y, size = math.random(), math.random(), math.random(2, 4)
		Loop(Lib.Create("Frame", {
			Size = UDim2.fromOffset(size, size), Position = UDim2.fromScale(x, y), BackgroundColor3 = White, BackgroundTransparency = 0.93,
			BorderSizePixel = 0, ZIndex = 51, Parent = Backdrop,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
		}), TweenInfo.new(math.random(40, 90) / 10, Sine, InOut, -1, true, math.random(0, 30) / 10), {
			Position = UDim2.fromScale(math.clamp(x + (math.random() - 0.5) * 0.06, 0, 1), math.clamp(y - 0.04 - math.random() * 0.08, 0, 1)),
			BackgroundTransparency = 0.5 + math.random() * 0.2
		})
	end

	local CenterBox = Lib.Create("Frame", {
		Size = UDim2.fromOffset(440, 376), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1, ZIndex = 53, Parent = SplashModal
	})

	local function Slot(y, width, height, delay, x)
		x = x or 0
		local group = Lib.Create("CanvasGroup", {
			Size = UDim2.fromOffset(width, height), Position = UDim2.new(0.5, x, 0, y + 14), AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1, GroupTransparency = 1, ZIndex = 55, Parent = CenterBox
		})
		Slots[#Slots + 1] = { group, UDim2.new(0.5, x, 0, y), delay }
		return group
	end

	local center = UDim2.fromScale(0.5, 0.5)
	local anchor = Vector2.new(0.5, 0.5)

	local LogoSlot = Slot(0, 150, 150, 0.1)
	local Ripple = Lib.Create("Frame", {
		Size = UDim2.fromOffset(84, 84), Position = center, AnchorPoint = anchor, BackgroundTransparency = 1, ZIndex = 56, Parent = LogoSlot,
		Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
	})
	local RippleStroke = Lib.Create("UIStroke", { Color = White, Thickness = 1, Transparency = 0.5, Parent = Ripple })
	local rippleInfo = TweenInfo.new(3.2, Quad, Out, -1)
	Loop(Ripple, rippleInfo, { Size = UDim2.fromOffset(148, 148) })
	Loop(RippleStroke, rippleInfo, { Transparency = 1 })

	Loop(Lib.Create("ImageLabel", {
		Size = UDim2.fromOffset(130, 130), Position = center, AnchorPoint = anchor, BackgroundTransparency = 1, Image = "rbxassetid://1316045217",
		ImageColor3 = White, ImageTransparency = 0.9, ZIndex = 55, Parent = LogoSlot
	}), TweenInfo.new(2.6, Sine, InOut, -1, true), { Size = UDim2.fromOffset(150, 150), ImageTransparency = 0.94 })

	Lib.Create("ImageLabel", {
		Size = UDim2.fromOffset(84, 84), Position = center, AnchorPoint = anchor, BackgroundTransparency = 1, Image = Lib.SplashOptions.Logo or "rbxassetid://113533839488998",
		ScaleType = Enum.ScaleType.Fit, ZIndex = 57, Parent = LogoSlot
	})

	local TitleSlot = Slot(112, 440, 40, 0.3)
	local Shine = Lib.Create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Muted), ColorSequenceKeypoint.new(0.42, Muted), ColorSequenceKeypoint.new(0.5, White),
			ColorSequenceKeypoint.new(0.58, Muted), ColorSequenceKeypoint.new(1, Muted)
		}),
		Offset = Vector2.new(-1, 0)
	})
	Lib.Create("TextLabel", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = Lib.SplashOptions.Title or "RAVENSCALL", TextColor3 = White, TextSize = 30, Font = Enum.Font.GothamBold,
		ZIndex = 56, Parent = TitleSlot, Shine
	})
	Loop(Shine, TweenInfo.new(2.4, Sine, InOut, -1, true), { Offset = Vector2.new(1, 0) })

	local SubtitleSlot = Slot(158, 440, 16, 0.45)
	Lib.Create("TextLabel", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = Lib.SplashOptions.Subtitle or "MINIMALISTIC INTERFACE", TextColor3 = Color3.fromRGB(125, 125, 125),
		TextSize = 10, Font = Enum.Font.GothamMedium, ZIndex = 56, Parent = SubtitleSlot
	})

	local Line = Lib.Create("Frame", {
		Size = UDim2.fromOffset(0, 1), Position = UDim2.new(0.5, 0, 0, 188), AnchorPoint = Vector2.new(0.5, 0), BackgroundColor3 = White,
		BackgroundTransparency = 0.82, BorderSizePixel = 0, ZIndex = 55, Parent = CenterBox
	})

	local PillSlot = Slot(206, 300, 26, 0.75)
	local Pill = Lib.Create("Frame", {
		Size = UDim2.fromOffset(0, 26), AutomaticSize = Enum.AutomaticSize.X, Position = UDim2.fromScale(0.5, 0), AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = White, BackgroundTransparency = 0.94, ZIndex = 56, Parent = PillSlot,
		Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
		Lib.Create("UIStroke", { Color = White, Transparency = 0.9, Thickness = 1 }),
		Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 14) }),
		Lib.Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder
		})
	})
	local Dot = Lib.Create("Frame", {
		Size = UDim2.fromOffset(6, 6), LayoutOrder = 1, BackgroundColor3 = Muted, BorderSizePixel = 0, ZIndex = 57, Parent = Pill,
		Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
	})
	Lib.Create("TextLabel", {
		Size = UDim2.fromOffset(0, 26), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 2, BackgroundTransparency = 1, Text = Lib.Version.Display,
		TextColor3 = White, TextSize = 11, Font = Enum.Font.GothamBold, ZIndex = 57, Parent = Pill
	})
	local Status = Lib.Create("TextLabel", {
		Size = UDim2.fromOffset(0, 26), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 3, BackgroundTransparency = 1, Text = "Checking for updates...",
		TextColor3 = Muted, TextSize = 11, Font = Enum.Font.GothamMedium, ZIndex = 57, Parent = Pill
	})

	local tones = {
		latest = { Color3.fromRGB(96, 214, 128), Muted },
		outdated = { Color3.fromRGB(255, 184, 77), Color3.fromRGB(255, 205, 135) },
		failed = { Color3.fromRGB(214, 96, 96), Muted }
	}
	local pulse
	local StopListening = Lib.Version.Listen(function(status, latest)
		if not Dot.Parent then return end
		if pulse then
			pulse:Cancel()
			pulse = nil
		end
		local tone = tones[status]
		Dot.BackgroundTransparency = 0
		if tone then
			Dot.BackgroundColor3, Status.TextColor3 = tone[1], tone[2]
			Status.Text = status == "latest" and "Up to date" or status == "outdated" and ("Update available: V" .. latest) or "Update check failed"
		else
			Dot.BackgroundColor3, Status.TextColor3 = Muted, Muted
			Status.Text = "Checking for updates..."
			pulse = Services.Tween:Create(Dot, TweenInfo.new(0.7, Sine, InOut, -1, true), { BackgroundTransparency = 0.75 })
			pulse:Play()
		end
	end)

	local function Hover(button, scale, enter, leave)
		button.MouseEnter:Connect(function()
			Lib.Tween(scale, 0.3, Quint, Out, { Scale = 1.045 })
			enter()
		end)
		button.MouseLeave:Connect(function()
			Lib.Tween(scale, 0.3, Quint, Out, { Scale = 1 })
			leave()
		end)
		button.MouseButton1Down:Connect(function()
			Lib.PlayClick()
			Lib.Tween(scale, 0.08, Quad, Out, { Scale = 0.95 })
		end)
		button.MouseButton1Up:Connect(function()
			Lib.Tween(scale, 0.35, Back, Out, { Scale = 1.045 })
		end)
	end

	local StartScale = Lib.Create("UIScale", {})
	local StartBtn = Lib.Create("TextButton", {
		Size = UDim2.fromOffset(150, 44), Position = center, AnchorPoint = anchor, BackgroundColor3 = Color3.fromRGB(245, 245, 245),
		Text = "Start System", TextColor3 = Color3.fromRGB(10, 10, 10), TextSize = 13, Font = Enum.Font.GothamBold, AutoButtonColor = false,
		ZIndex = 57, Parent = Slot(256, 166, 52, 0.95, -84),
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 10) }), StartScale
	})
	local Arrow = Lib.Create("TextLabel", {
		Size = UDim2.fromOffset(16, 44), Position = UDim2.new(1, -28, 0, 0), BackgroundTransparency = 1, Text = "→", TextColor3 = Color3.fromRGB(10, 10, 10),
		TextTransparency = 0.55, TextSize = 14, Font = Enum.Font.GothamBold, ZIndex = 58, Parent = StartBtn
	})
	Hover(StartBtn, StartScale, function()
		Lib.Tween(Arrow, 0.3, Quint, Out, { Position = UDim2.new(1, -22, 0, 0), TextTransparency = 0 })
		Lib.Tween(StartBtn, 0.2, Quad, Out, { BackgroundColor3 = White })
	end, function()
		Lib.Tween(Arrow, 0.3, Quint, Out, { Position = UDim2.new(1, -28, 0, 0), TextTransparency = 0.55 })
		Lib.Tween(StartBtn, 0.2, Quad, Out, { BackgroundColor3 = Color3.fromRGB(245, 245, 245) })
	end)

	local GitScale = Lib.Create("UIScale", {})
	local GitStroke = Lib.Create("UIStroke", { Color = White, Thickness = 1, Transparency = 0.82, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
	local GithubBtn = Lib.Create("TextButton", {
		Size = UDim2.fromOffset(150, 44), Position = center, AnchorPoint = anchor, BackgroundColor3 = White, BackgroundTransparency = 0.96,
		Text = "GitHub", TextColor3 = Color3.fromRGB(205, 205, 205), TextSize = 13, Font = Enum.Font.GothamMedium, AutoButtonColor = false,
		ZIndex = 57, Parent = Slot(256, 166, 52, 1.05, 84),
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 10) }), GitScale, GitStroke
	})
	Hover(GithubBtn, GitScale, function()
		Lib.Tween(GithubBtn, 0.25, Quad, Out, { BackgroundTransparency = 0.9, TextColor3 = White })
		Lib.Tween(GitStroke, 0.25, Quad, Out, { Transparency = 0.5 })
	end, function()
		Lib.Tween(GithubBtn, 0.25, Quad, Out, { BackgroundTransparency = 0.96, TextColor3 = Color3.fromRGB(205, 205, 205) })
		Lib.Tween(GitStroke, 0.25, Quad, Out, { Transparency = 0.82 })
	end)

	local isMobileVersion, autoResolution = false, false

	local function Checkbox(y, delay, text, onToggle)
		local checked = false
		local toggle = Lib.Create("TextButton", {
			Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 56, Parent = Slot(y, 240, 22, delay)
		})
		local box = Lib.Create("Frame", {
			Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0, 14, 0.5, -8), BackgroundColor3 = White, BackgroundTransparency = 1, ZIndex = 57, Parent = toggle,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 5) }),
			Lib.Create("UIStroke", { Color = Color3.fromRGB(120, 120, 120), Thickness = 1.2 })
		})
		local check = Lib.Create("TextLabel", {
			Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "✓", TextColor3 = Color3.fromRGB(0, 0, 0), TextSize = 12,
			Font = Enum.Font.GothamBold, Visible = false, ZIndex = 58, Parent = box
		})
		local label = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -40, 1, 0), Position = UDim2.fromOffset(38, 0), BackgroundTransparency = 1, Text = text,
			TextColor3 = Muted, TextSize = 11, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 57, Parent = toggle
		})
		toggle.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			checked = not checked
			check.Visible = checked
			Lib.Tween(box, 0.2, Quad, Out, { BackgroundTransparency = checked and 0 or 1 })
			Lib.Tween(label, 0.2, Quad, Out, { TextColor3 = checked and White or Muted })
			onToggle(checked)
		end)
	end

	Checkbox(318, 1.2, "Mobile Version (1.5x Smaller)", function(value) isMobileVersion = value end)
	Checkbox(346, 1.3, "Auto Resolution Detection", function(value) autoResolution = value end)

	local Footer = Lib.Create("TextLabel", {
		Size = UDim2.fromOffset(300, 14), Position = UDim2.new(0.5, 0, 1, -20), AnchorPoint = Vector2.new(0.5, 1), BackgroundTransparency = 1,
		Text = Lib.SplashOptions.Footer or "RavenScall Project", TextColor3 = White, TextTransparency = 1, TextSize = 10, Font = Enum.Font.GothamMedium, ZIndex = 55, Parent = SplashModal
	})

	Lib.Prepare()

	Lib.Tween(SplashModal, 0.45, Enum.EasingStyle.Quad, Out, { GroupTransparency = 0 })
	for _, slot in ipairs(Slots) do
		task.delay(slot[3], function()
			if slot[1].Parent then
				Lib.Tween(slot[1], 0.75, Quint, Out, { GroupTransparency = 0, Position = slot[2] })
			end
		end)
	end
	task.delay(0.6, function()
		if Line.Parent then Lib.Tween(Line, 0.9, Quint, Out, { Size = UDim2.fromOffset(150, 1) }) end
	end)
	task.delay(1.3, function()
		if Footer.Parent then Lib.Tween(Footer, 0.8, Quad, Out, { TextTransparency = 0.6 }) end
	end)

	local copying = false
	GithubBtn.MouseButton1Click:Connect(function()
		local copyFunc = setclipboard or toclipboard or set_clipboard
		if copyFunc then pcall(copyFunc, Lib.SplashOptions.Link or "github.com/CherryCalCor") end
		if copying then return end
		copying = true
		GithubBtn.Text = "Link Copied ✓"
		Lib.Tween(GithubBtn, 0.2, Quad, Out, { BackgroundTransparency = 0.84, TextColor3 = White })
		task.delay(1.6, function()
			copying = false
			if GithubBtn.Parent then GithubBtn.Text = "GitHub" end
		end)
	end)

	local launched = false
	StartBtn.MouseButton1Click:Connect(function()
		if launched then return end
		launched = true
		StopListening()
		Lib.Tween(Blur, 0.4, Quad, Enum.EasingDirection.In, { Size = 0 })
		local fadeOut = Lib.Tween(SplashModal, 0.35, Quad, Out, { GroupTransparency = 1 })

		fadeOut.Completed:Connect(function()
			if pulse then pulse:Cancel() end
			for i = 1, #Loops do Loops[i]:Cancel() end
			SplashModal:Destroy()
			Blur:Destroy()

			Lib.Launch(isMobileVersion, autoResolution)
		end)
	end)
end

function Lib.PlayCinematicIntro(onComplete)
	local IntroBlur = Lib.Create("BlurEffect", { Name = Lib.Config.Name .. "_IntroBlur", Size = 0, Parent = Services.Lighting })
	Refs.IntroBlur = IntroBlur
	Lib.Tween(IntroBlur, 1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Size = 30 })

	local Quint, Quad, Sine, Back, Cubic, Linear = Enum.EasingStyle.Quint, Enum.EasingStyle.Quad, Enum.EasingStyle.Sine, Enum.EasingStyle.Back, Enum.EasingStyle.Cubic, Enum.EasingStyle.Linear
	local Out, In, InOut = Enum.EasingDirection.Out, Enum.EasingDirection.In, Enum.EasingDirection.InOut
	local White, Muted, Dim, Amber = Color3.fromRGB(255, 255, 255), Color3.fromRGB(150, 150, 150), Color3.fromRGB(105, 105, 105), Color3.fromRGB(255, 184, 77)
	local center, anchor = UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5)
	local russian = State.Language == "Русский"
	local Loops = {}

	local function T(text)
		return russian and Lib.Ru(text) or text
	end

	local function Loop(inst, info, goal)
		local tween = Services.Tween:Create(inst, info, goal)
		Loops[#Loops + 1] = tween
		tween:Play()
	end

	local IntroGui = Lib.Create("CanvasGroup", {
		Name = Lib.Config.Name .. "_CinematicIntro", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(6, 6, 6), BackgroundTransparency = 0.3,
		GroupTransparency = 1, ZIndex = 100, Parent = UI.Screen
	})
	Lib.Tween(IntroGui, 0.5, Quad, Out, { GroupTransparency = 0 })

	local Backdrop = Lib.Create("Frame", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 100, Parent = IntroGui
	})
	local drift = TweenInfo.new(9, Sine, InOut, -1, true)
	for _, glow in ipairs({
		{ 520, UDim2.fromScale(0.22, 0.3), UDim2.fromScale(0.34, 0.44), 0.94 },
		{ 620, UDim2.fromScale(0.8, 0.72), UDim2.fromScale(0.66, 0.58), 0.955 }
	}) do
		Loop(Lib.Create("ImageLabel", {
			Size = UDim2.fromOffset(glow[1], glow[1]), Position = glow[2], AnchorPoint = anchor, BackgroundTransparency = 1,
			Image = "rbxassetid://1316045217", ImageColor3 = White, ImageTransparency = glow[4], ZIndex = 100, Parent = Backdrop
		}), drift, { Position = glow[3] })
	end
	for _ = 1, 16 do
		local x, y, size = math.random(), math.random(), math.random(2, 4)
		Loop(Lib.Create("Frame", {
			Size = UDim2.fromOffset(size, size), Position = UDim2.fromScale(x, y), BackgroundColor3 = White, BackgroundTransparency = 0.93,
			BorderSizePixel = 0, ZIndex = 101, Parent = Backdrop,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
		}), TweenInfo.new(math.random(40, 90) / 10, Sine, InOut, -1, true, math.random(0, 30) / 10), {
			Position = UDim2.fromScale(math.clamp(x + (math.random() - 0.5) * 0.06, 0, 1), math.clamp(y - 0.04 - math.random() * 0.08, 0, 1)),
			BackgroundTransparency = 0.5 + math.random() * 0.2
		})
	end

	task.spawn(function()
		local Stage = Lib.Create("CanvasGroup", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 102, Parent = IntroGui })
		local Box = Lib.Create("Frame", {
			Size = UDim2.fromOffset(360, 280), Position = center, AnchorPoint = anchor, BackgroundTransparency = 1, ZIndex = 102, Parent = Stage
		})

		local LogoScale = Lib.Create("UIScale", { Scale = 0.7 })
		local LogoHolder = Lib.Create("CanvasGroup", {
			Size = UDim2.fromOffset(130, 130), Position = UDim2.new(0.5, 0, 0, 62), AnchorPoint = anchor, BackgroundTransparency = 1,
			GroupTransparency = 1, ZIndex = 103, Parent = Box, LogoScale
		})
		Loop(Lib.Create("ImageLabel", {
			Size = UDim2.fromOffset(110, 110), Position = center, AnchorPoint = anchor, BackgroundTransparency = 1, Image = "rbxassetid://1316045217",
			ImageColor3 = White, ImageTransparency = 0.9, ZIndex = 103, Parent = LogoHolder
		}), TweenInfo.new(2.4, Sine, InOut, -1, true), { Size = UDim2.fromOffset(130, 130), ImageTransparency = 0.95 })
		Lib.Create("Frame", {
			Size = UDim2.fromOffset(100, 100), Position = center, AnchorPoint = anchor, BackgroundTransparency = 1, ZIndex = 104, Parent = LogoHolder,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
			Lib.Create("UIStroke", { Color = White, Thickness = 1, Transparency = 0.9 })
		})
		local ArcStroke = Lib.Create("UIStroke", { Color = White, Thickness = 1.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
		local ArcGradient = Lib.Create("UIGradient", {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.3, 0.7), NumberSequenceKeypoint.new(0.31, 1), NumberSequenceKeypoint.new(1, 1)
			}),
			Parent = ArcStroke
		})
		Lib.Create("Frame", {
			Size = UDim2.fromOffset(100, 100), Position = center, AnchorPoint = anchor, BackgroundTransparency = 1, ZIndex = 105, Parent = LogoHolder,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) }), ArcStroke
		})
		Loop(ArcGradient, TweenInfo.new(1.7, Linear, Out, -1), { Rotation = 360 })
		Lib.Create("ImageLabel", {
			Size = UDim2.fromOffset(62, 62), Position = center, AnchorPoint = anchor, BackgroundTransparency = 1, Image = Lib.SplashOptions.Logo or "rbxassetid://113533839488998",
			ScaleType = Enum.ScaleType.Fit, ZIndex = 106, Parent = LogoHolder
		})

		local TextService = game:GetService("TextService")
		local word, letterSize, letterGap, letterFont = Lib.SplashOptions.Title or "RAVENSCALL", 28, 7, Enum.Font.GothamBold
		local widths, offsets, total = {}, {}, 0
		for i = 1, #word do
			widths[i] = TextService:GetTextSize(word:sub(i, i), letterSize, letterFont, Vector2.new(200, 60)).X
			offsets[i] = total
			total = total + widths[i] + letterGap
		end
		total = total - letterGap
		local TitleHolder = Lib.Create("Frame", {
			Size = UDim2.fromOffset(total, 36), Position = UDim2.new(0.5, 0, 0, 130), AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1, ZIndex = 103, Parent = Box
		})
		local letters = {}
		for i = 1, #word do
			letters[i] = Lib.Create("TextLabel", {
				Size = UDim2.fromOffset(widths[i], 36), Position = UDim2.fromOffset(offsets[i], 14), BackgroundTransparency = 1, Text = word:sub(i, i),
				TextColor3 = White, TextTransparency = 1, TextSize = letterSize, Font = letterFont, ZIndex = 104, Parent = TitleHolder
			})
		end

		local Subtitle = Lib.Create("TextLabel", {
			Size = UDim2.fromOffset(360, 14), Position = UDim2.new(0.5, 0, 0, 178), AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1,
			Text = T(Lib.SplashOptions.Subtitle or "MINIMALISTIC INTERFACE"), TextColor3 = Dim, TextTransparency = 1, TextSize = 10, Font = Enum.Font.GothamMedium, ZIndex = 103, Parent = Box
		})

		local Track = Lib.Create("Frame", {
			Size = UDim2.fromOffset(0, 2), Position = UDim2.new(0.5, 0, 0, 226), AnchorPoint = Vector2.new(0.5, 0), BackgroundColor3 = White,
			BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 103, Parent = Box,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
		})
		local Fill = Lib.Create("Frame", {
			Size = UDim2.fromScale(0, 1), BackgroundColor3 = White, BorderSizePixel = 0, ZIndex = 104, Parent = Track,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
			Lib.Create("UIGradient", {
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.75), NumberSequenceKeypoint.new(1, 0) })
			})
		})
		local Percent = Lib.Create("TextLabel", {
			Size = UDim2.fromOffset(60, 14), Position = UDim2.new(0.5, -120, 0, 236), BackgroundTransparency = 1, Text = "0%", TextColor3 = Dim,
			TextTransparency = 1, TextSize = 10, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 103, Parent = Box
		})
		local Status = Lib.Create("TextLabel", {
			Size = UDim2.fromOffset(170, 14), Position = UDim2.new(0.5, 120, 0, 236), AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1,
			Text = T("Initializing"), TextColor3 = Dim, TextTransparency = 1, TextSize = 10, Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 103, Parent = Box
		})

		local Stages = { { 0.28, "Loading modules" }, { 0.58, "Preparing interface" }, { 0.86, "Almost ready" }, { 1, "Ready" } }
		local nextStage = 1
		local Progress = Instance.new("NumberValue")
		Progress.Parent = IntroGui
		Progress.Changed:Connect(function(value)
			Fill.Size = UDim2.fromScale(value, 1)
			Percent.Text = math.floor(value * 100) .. "%"
			local stage = Stages[nextStage]
			while stage and value >= stage[1] do
				nextStage = nextStage + 1
				Status.Text = T(stage[2])
				Status.TextTransparency = 1
				Lib.Tween(Status, 0.3, Quad, Out, { TextTransparency = 0.2 })
				stage = Stages[nextStage]
			end
		end)

		Lib.Tween(LogoHolder, 0.9, Quint, Out, { GroupTransparency = 0 })
		Lib.Tween(LogoScale, 1, Back, Out, { Scale = 1 })
		task.wait(0.4)
		for i, letter in ipairs(letters) do
			task.delay((i - 1) * 0.05, function()
				if letter.Parent then
					Lib.Tween(letter, 0.8, Quint, Out, { TextTransparency = 0, Position = UDim2.fromOffset(offsets[i], 0) })
				end
			end)
		end
		task.wait(0.8)
		Lib.Tween(Subtitle, 0.8, Quad, Out, { TextTransparency = 0.25 })
		Lib.Tween(Track, 0.8, Quint, Out, { Size = UDim2.fromOffset(240, 2), BackgroundTransparency = 0.88 })
		Lib.Tween(Percent, 0.6, Quad, Out, { TextTransparency = 0.2 })
		Lib.Tween(Status, 0.6, Quad, Out, { TextTransparency = 0.2 })
		task.wait(0.6)

		Lib.Tween(Progress, 0.9, Quad, Out, { Value = 0.4 }).Completed:Wait()
		Lib.Tween(Progress, 1.1, Sine, InOut, { Value = 0.78 }).Completed:Wait()
		Lib.Tween(Progress, 0.8, Cubic, Out, { Value = 1 }).Completed:Wait()
		Progress:Destroy()
		Lib.Tween(Track, 0.3, Quad, Out, { BackgroundTransparency = 0.7 })
		task.wait(0.45)

		Lib.Tween(Stage, 0.45, Quad, In, { GroupTransparency = 1 }).Completed:Wait()
		Stage:Destroy()
		if not IntroGui.Parent then return end

		if Lib.SplashOptions.Warning == false then
			local skipFade = Lib.Tween(IntroGui, 0.5, Quad, Out, { GroupTransparency = 1 })
			skipFade.Completed:Connect(function()
				for i = 1, #Loops do Loops[i]:Cancel() end
				IntroGui:Destroy()
				if onComplete then onComplete(IntroBlur) end
			end)
			return
		end
		local Warn = Lib.Create("CanvasGroup", {
			Size = UDim2.fromOffset(420, 210), Position = UDim2.new(0.5, 0, 0.5, 14), AnchorPoint = anchor, BackgroundTransparency = 1,
			GroupTransparency = 1, ZIndex = 104, Parent = IntroGui
		})
		local BadgeScale = Lib.Create("UIScale", { Scale = 0.6 })
		local Badge = Lib.Create("Frame", {
			Size = UDim2.fromOffset(46, 46), Position = UDim2.new(0.5, 0, 0, 40), AnchorPoint = anchor, BackgroundTransparency = 1, ZIndex = 105, Parent = Warn,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
			Lib.Create("UIStroke", { Color = Amber, Thickness = 1.5, Transparency = 0.35 }), BadgeScale
		})
		Lib.Create("TextLabel", {
			Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "!", TextColor3 = Amber, TextSize = 20, Font = Enum.Font.GothamBold, ZIndex = 106, Parent = Badge
		})
		local Ripple = Lib.Create("Frame", {
			Size = UDim2.fromOffset(46, 46), Position = UDim2.new(0.5, 0, 0, 40), AnchorPoint = anchor, BackgroundTransparency = 1, ZIndex = 105, Parent = Warn,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
		})
		local RippleStroke = Lib.Create("UIStroke", { Color = Amber, Thickness = 1, Transparency = 0.6, Parent = Ripple })
		local rippleInfo = TweenInfo.new(2.4, Quad, Out, -1)
		Loop(Ripple, rippleInfo, { Size = UDim2.fromOffset(86, 86) })
		Loop(RippleStroke, rippleInfo, { Transparency = 1 })

		Lib.Create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 18), Position = UDim2.fromOffset(0, 80), BackgroundTransparency = 1, Text = T(Lib.SplashOptions.WarningTitle or "SECURITY WARNING"),
			TextColor3 = White, TextSize = 13, Font = Enum.Font.GothamBold, ZIndex = 105, Parent = Warn
		})
		Lib.Create("TextLabel", {
			Size = UDim2.fromOffset(360, 54), Position = UDim2.new(0.5, 0, 0, 104), AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1,
			Text = T(Lib.SplashOptions.WarningText or "We strongly advise against using this script in games with powerful anti-cheats for the safety of your progress."),
			TextColor3 = Color3.fromRGB(170, 170, 170), TextSize = 13, Font = Enum.Font.GothamMedium, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
			ZIndex = 105, Parent = Warn
		})
		local Timer = Lib.Create("Frame", {
			Size = UDim2.fromOffset(140, 2), Position = UDim2.new(0.5, 0, 0, 176), AnchorPoint = Vector2.new(0.5, 0), BackgroundColor3 = White,
			BackgroundTransparency = 0.9, BorderSizePixel = 0, ZIndex = 105, Parent = Warn,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
		})
		local TimerFill = Lib.Create("Frame", {
			Size = UDim2.fromScale(1, 1), BackgroundColor3 = Amber, BorderSizePixel = 0, ZIndex = 106, Parent = Timer,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
		})
		Lib.Create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 14), Position = UDim2.fromOffset(0, 188), BackgroundTransparency = 1, Text = T("Continuing automatically"),
			TextColor3 = Dim, TextSize = 10, Font = Enum.Font.GothamMedium, ZIndex = 105, Parent = Warn
		})

		Lib.Tween(Warn, 0.8, Quint, Out, { GroupTransparency = 0, Position = center })
		Lib.Tween(BadgeScale, 0.9, Back, Out, { Scale = 1 })
		task.wait(0.5)
		Lib.Tween(TimerFill, 3.6, Linear, Out, { Size = UDim2.fromScale(0, 1) })
		task.wait(3.9)

		local fade = Lib.Tween(IntroGui, 0.5, Quad, Out, { GroupTransparency = 1 })
		fade.Completed:Connect(function()
			for i = 1, #Loops do Loops[i]:Cancel() end
			IntroGui:Destroy()
			if onComplete then onComplete(IntroBlur) end
		end)
	end)
end


-- ══════════════════════════════════════════════════════════════════════════
--  PUBLIC API
-- ══════════════════════════════════════════════════════════════════════════


-- ══════════════════════════════════════════════════════════════════════════════
--  Object API (thin wrappers around the original Lib.* constructors)
-- ══════════════════════════════════════════════════════════════════════════════
local Hub, Section, Tab, Group = {}, {}, {}, {}
Hub.__index, Section.__index, Tab.__index, Group.__index = Hub, Section, Tab, Group

-- Group: a rounded card holding rows (Lib.CreateFeatureGroup)
function Group:AddToggle(title, desc, default, callback, isLast)
	return Lib.CreateSettingToggleItem(self.Frame, title, desc or "", default and true or false, callback or function() end, isLast)
end

function Group:AddSlider(title, desc, min, max, default, callback, isLast, suffix, step)
	return Lib.CreateSettingSliderItem(self.Frame, title, desc or "", min, max, default or min, callback or function() end, isLast, suffix, step)
end

function Group:AddChoice(title, options, default, callback, isLast, multi)
	return Lib.CreateSettingChoiceItem(self.Frame, title, options, default, callback or function() end, isLast, multi)
end

function Group:AddColor(title, store, key, isLast, callback)
	return Lib.CreateColorItem(self.Frame, title, store, key, isLast, callback)
end

function Group:AddButton(title, desc, callback, isLast)
	return Lib.CreateSettingButtonItem(self.Frame, title, desc or "", callback or function() end, isLast)
end

-- Removes the divider line of the last row (same as passing isLast = true)
function Group:Finish()
	local last
	for _, child in ipairs(self.Frame:GetChildren()) do
		if child:IsA("GuiObject") then last = child end
	end
	if not last then return end
	for _, child in ipairs(last:GetChildren()) do
		if child:IsA("Frame") and child.Size.Y.Offset == 1 and child.Size.Y.Scale == 0 then
			child:Destroy()
		end
	end
end

-- Tab: one animated page (CanvasGroup) of a section
function Tab:AddScroll(padding)
	return setmetatable({ Frame = Lib.MakeScroll(self.View, padding, self.Searchable), Tab = self }, Tab)
end

function Tab:AddGroup(title, layoutOrder)
	self.Order = (self.Order or 0) + 1
	return setmetatable({ Frame = Lib.CreateFeatureGroup(self.Frame or self.View, title, layoutOrder or self.Order) }, Group)
end

-- Section: one main-navigation page
function Section:AddTab(name, positionY, iconId, searchable)
	self.Count = self.Count + 1
	local y = positionY or (self.TabStart + (self.Count - 1) * self.TabStep)
	local view = self.Make(name, y, iconId)
	return setmetatable({ View = view, Name = name, Section = self, Searchable = searchable ~= false }, Tab)
end

function Section:Select(name)
	self.Switch(name)
end

-- Hub: the window itself
function Hub:AddSection(id, options)
	options = options or {}
	local object = Lib.CreateSection(id, options)
	return setmetatable(object, Section)
end

function Hub:Show() Lib.ToggleMenu(true) end
function Hub:Hide() Lib.ToggleMenu(false) end
function Hub:Toggle() Lib.ToggleMenu() end
function Hub:Notify(options) Lib.Notify(options) end
function Hub:SelectMainTab(id) Lib.SwitchMainTab(id) end
function Hub:SetTheme(index) Lib.ApplyTheme(Lib.ResolveTheme(index) or Lib.ThemePresets[1]) State.SelectedThemeIndex = index end
function Hub:Destroy()
	Lib.Unload()
	if Refs.IntroBlur then Refs.IntroBlur:Destroy() end
	if Refs.GlassBlur then Refs.GlassBlur:Destroy() end
	if UI.Screen then UI.Screen:Destroy() end
end

function Hub:Start(options)
	Lib.Version.Check()
	local config = self.Config
	local intro = config.Intro ~= false
	local splash = config.Splash ~= false
	if intro and splash then
		Lib.PlayCinematicIntro(Lib.PlaySplash)
	elseif splash then
		Lib.PlaySplash()
	elseif intro then
		Lib.PlayCinematicIntro(function(blur)
			if blur then blur:Destroy() end
			Lib.Prepare()
			Lib.Launch(false, false)
		end)
	else
		Lib.Prepare()
		Lib.Launch(false, false)
	end
end

-- Applies the configuration table given to CreateHub
function Lib.Configure(config)
	Lib.Config.Name = config.Name or Lib.Config.Name
	Lib.Config.Folder = config.Folder or config.Name or Lib.Config.Folder

	local version = config.Version
	if type(version) == "table" then
		for key, value in pairs(version) do Lib.Version[key] = value end
		Lib.Version.Display = version.Display or ("V" .. tostring(Lib.Version.Current))
	end

	local header = config.Header
	if type(header) == "table" then
		for key, value in pairs(header) do Lib.HeaderAssets[key] = value end
		Lib.DefaultHeaderIcon = Lib.HeaderAssets.Icon
	else
		Lib.DefaultHeaderIcon = Lib.HeaderAssets.Icon
	end

	if config.Size then State.OriginalSize = config.Size end
	for _, key in ipairs({ "MenuAnim", "SHStyle", "NavStyle", "CornerRadius", "NotificationsEnabled", "NotifAnim", "NotifSound", "NotifPosition", "PlayerNotifsEnabled", "HideLogo", "HideName", "WindowTransparency", "PanelTransparency" }) do
		if config[key] ~= nil then State[key] = config[key] end
	end

	Lib.NavTabs = config.Tabs or Lib.NavTabs
end

function Lib.CreateHub(config)
	config = config or {}
	Lib.Configure(config)

	Lib.InstanceKey = (config.Name or "SeptusUI") .. "Instance"
	if config.SingleInstance ~= false then
		local ok, busy = pcall(function()
			local prev = env[Lib.InstanceKey]
			if not prev then return false end
			if prev.Ready then return prev.Gui ~= nil and prev.Gui.Parent ~= nil end
			return os.clock() - prev.Time < 60
		end)
		if ok and busy then
			pcall(function()
				game:GetService("StarterGui"):SetCore("SendNotification", { Title = config.Name or "SeptusUI", Text = "Already running. Close the current UI first.", Duration = 4 })
			end)
			return nil
		end
		env[Lib.InstanceKey] = { Time = os.clock() }
	end

	Lib.BuildShell(config)

	local hub = setmetatable({ Config = config, Lib = Lib, App = App, UI = UI, State = State, Services = Services, Screen = UI.Screen, Main = UI.Main }, Hub)
	Lib.Hub = hub
	return hub
end


return Lib
