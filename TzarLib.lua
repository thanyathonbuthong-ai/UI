--[[
    TZAR.cc UI Library  (Roblox / Luau)
    ------------------------------------------------------------
    Dark rounded UI: top bar + sidebar tabs + collapsible sections.
    Elements: Toggle, Button, Dropdown (single/multi), Textbox,
              Slider, Keybind, Label, Notify, Config manager.

    Usage:
        local Library = loadstring(readfile("TzarLib.lua"))()
        local Window  = Library:CreateWindow({ Title = "TZAR", Subtitle = ".cc" })
        local Tab     = Window:AddTab({ Name = "Settings", Icon = "gear" })
        local Section = Tab:AddSection({ Name = "Configuration" })
        Section:AddToggle({ Name = "Auto Save", Description = "...", Callback = function(v) end })

    Icons: "gear" | "wrench" | "search" | "sliders" | "close" | "chevron"
           or any "rbxassetid://123" / number (custom image icon).
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Library = {
	Flags = {},
	Options = {},
	Windows = {},
	AutoSave = false,
	CurrentProfile = nil,
	Folder = "TZAR",
	LetterSpacing = true, -- spaced uppercase section headers (like the design)
	FontFamily = "rbxasset://fonts/families/GothamSSm.json",
}

----------------------------------------------------------------------
-- Theme (colors sampled from the reference screenshot)
----------------------------------------------------------------------
local Theme = {
	Root = Color3.fromRGB(10, 10, 10),
	RootStroke = Color3.fromRGB(30, 30, 30),
	Main = Color3.fromRGB(15, 15, 15),
	MainStroke = Color3.fromRGB(26, 26, 26),
	Panel = Color3.fromRGB(22, 22, 22),
	Header = Color3.fromRGB(26, 26, 26),
	TabActive = Color3.fromRGB(38, 38, 38),
	Input = Color3.fromRGB(26, 26, 26),
	InputStroke = Color3.fromRGB(44, 44, 44),
	InputStrokeFocus = Color3.fromRGB(86, 86, 86),
	Text = Color3.fromRGB(240, 240, 240),
	TextDim = Color3.fromRGB(205, 205, 205),
	Muted = Color3.fromRGB(110, 110, 110),
	MutedHover = Color3.fromRGB(170, 170, 170),
	Placeholder = Color3.fromRGB(88, 88, 88),
	Description = Color3.fromRGB(104, 104, 104),
	HeaderText = Color3.fromRGB(125, 125, 125),
	IconIdle = Color3.fromRGB(150, 150, 150),
	Accent = Color3.fromRGB(74, 222, 128),
	AccentText = Color3.fromRGB(10, 10, 10),
	ToggleOff = Color3.fromRGB(30, 30, 30),
	ToggleStroke = Color3.fromRGB(52, 52, 52),
	Knob = Color3.fromRGB(255, 255, 255),
	Scroll = Color3.fromRGB(70, 70, 70),
}
Library.Theme = Theme

local W = Enum.FontWeight

----------------------------------------------------------------------
-- Helpers
----------------------------------------------------------------------
local function GetFont(weight)
	return Font.new(Library.FontFamily, weight or W.Medium, Enum.FontStyle.Normal)
end

local function Create(className, props, children)
	local inst = Instance.new(className)
	local parent
	for k, v in pairs(props or {}) do
		if k == "Parent" then
			parent = v
		else
			inst[k] = v
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

local function Corner(parent, radius)
	local r = (radius == "full") and UDim.new(1, 0) or UDim.new(0, radius)
	return Create("UICorner", { CornerRadius = r, Parent = parent })
end

local function Stroke(parent, color, thickness)
	return Create("UIStroke", {
		Color = color,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent,
	})
end

local function Tween(obj, props, t, style, dir)
	local tw = TweenService:Create(
		obj,
		TweenInfo.new(t or 0.16, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
		props
	)
	tw:Play()
	return tw
end

local function SafeCall(fn, ...)
	if type(fn) ~= "function" then
		return
	end
	local ok, err = pcall(fn, ...)
	if not ok then
		warn("[TZAR UI] callback error: " .. tostring(err))
	end
end

local function NewText(p)
	local inst = Create(p.ClassName or "TextLabel", {
		Name = p.Name or "Text",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		FontFace = GetFont(p.Weight),
		Text = p.Text or "",
		TextSize = p.TextSize or 13,
		TextColor3 = p.Color or Theme.Text,
		TextXAlignment = p.XAlignment or Enum.TextXAlignment.Left,
		TextYAlignment = p.YAlignment or Enum.TextYAlignment.Center,
		TextTruncate = p.Truncate or Enum.TextTruncate.None,
		TextWrapped = p.Wrapped or false,
		Size = p.Size or UDim2.new(1, 0, 0, 16),
		Position = p.Position or UDim2.new(),
		AnchorPoint = p.AnchorPoint or Vector2.zero,
		AutomaticSize = p.AutomaticSize or Enum.AutomaticSize.None,
		ZIndex = p.ZIndex or 1,
		Parent = p.Parent,
	})
	return inst
end

local function Spaced(text)
	if not Library.LetterSpacing then
		return text
	end
	if text:find("[\128-\255]") then
		return text -- don't split non-ASCII (e.g. Thai) clusters
	end
	return (text:gsub(".", "%0\u{200A}"))
end

local function RoundTo(v, inc)
	if not inc or inc <= 0 then
		return v
	end
	local r = math.floor(v / inc + 0.5) * inc
	local frac = string.format("%.10g", inc):match("%.(%d+)")
	local mult = 10 ^ (frac and #frac or 0)
	return math.floor(r * mult + 0.5) / mult
end

local function GetGuiParent()
	local ok, ui = pcall(function()
		return gethui and gethui()
	end)
	if ok and ui then
		return ui
	end
	local okCore = pcall(function()
		local g = Instance.new("ScreenGui")
		g.Parent = game:GetService("CoreGui")
		g:Destroy()
	end)
	if okCore then
		return game:GetService("CoreGui")
	end
	return Players.LocalPlayer:WaitForChild("PlayerGui")
end

----------------------------------------------------------------------
-- Icons (drawn with Frames so no asset ids are required)
----------------------------------------------------------------------
local function IconBase(parent, size, color)
	local holder = Create("Frame", {
		Name = "Icon",
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(size, size),
		Parent = parent,
	})
	local api = { Holder = holder, _fills = {}, _strokes = {} }
	local s = size / 24
	local thick = math.max(1, 2 * s)

	function api:Line(x1, y1, x2, y2)
		local dx, dy = x2 - x1, y2 - y1
		local len = math.sqrt(dx * dx + dy * dy)
		local f = Create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset((x1 + x2) / 2 * s, (y1 + y2) / 2 * s),
			Size = UDim2.fromOffset(len * s + thick, thick),
			Rotation = math.deg(math.atan2(dy, dx)),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Parent = holder,
		})
		Corner(f, "full")
		table.insert(self._fills, f)
	end

	function api:Ring(cx, cy, r)
		local d = math.max(2, r * 2 * s - thick)
		local f = Create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(cx * s, cy * s),
			Size = UDim2.fromOffset(d, d),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Parent = holder,
		})
		Corner(f, "full")
		table.insert(self._strokes, Stroke(f, color, thick))
	end

	function api:SetColor(c)
		for _, f in ipairs(self._fills) do
			f.BackgroundColor3 = c
		end
		for _, st in ipairs(self._strokes) do
			st.Color = c
		end
	end

	return api
end

local IconDraw = {
	search = function(i)
		i:Ring(11, 11, 8)
		i:Line(16.8, 16.8, 21, 21)
	end,
	sliders = function(i)
		i:Line(21, 4, 14, 4)
		i:Line(10, 4, 3, 4)
		i:Line(21, 12, 12, 12)
		i:Line(8, 12, 3, 12)
		i:Line(21, 20, 16, 20)
		i:Line(12, 20, 3, 20)
		i:Line(14, 2, 14, 6)
		i:Line(8, 10, 8, 14)
		i:Line(16, 18, 16, 22)
	end,
	close = function(i)
		i:Line(18, 6, 6, 18)
		i:Line(6, 6, 18, 18)
	end,
	chevron = function(i)
		i:Line(6, 9, 12, 15)
		i:Line(12, 15, 18, 9)
	end,
	gear = function(i)
		i:Ring(12, 12, 3.2)
		i:Ring(12, 12, 7.2)
		for k = 0, 7 do
			local a = math.rad(k * 45)
			i:Line(12 + math.cos(a) * 8, 12 + math.sin(a) * 8, 12 + math.cos(a) * 10.4, 12 + math.sin(a) * 10.4)
		end
	end,
	wrench = function(i)
		i:Ring(16.5, 7.5, 5)
		i:Line(13, 11, 4.5, 19.5)
	end,
}

local function MakeIcon(name, parent, size, color)
	if type(name) == "number" then
		name = "rbxassetid://" .. name
	end
	if type(name) == "string" and (name:find("^rbxassetid://") or name:find("^rbxasset://")) then
		local img = Create("ImageLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(size, size),
			Image = name,
			ImageColor3 = color,
			Parent = parent,
		})
		return {
			Holder = img,
			SetColor = function(_, c)
				img.ImageColor3 = c
			end,
		}
	end
	local api = IconBase(parent, size, color)
	;(IconDraw[name or "wrench"] or IconDraw.wrench)(api)
	return api
end

local function MakeLogo(parent, logo)
	if logo then
		return Create("ImageLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(18, 18),
			Image = type(logo) == "number" and ("rbxassetid://" .. logo) or logo,
			Parent = parent,
		})
	end
	-- default mark: little gamepad wearing a red hat
	local holder = Create("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(18, 18), Parent = parent })
	local body = Create("Frame", {
		Position = UDim2.fromOffset(1, 7),
		Size = UDim2.fromOffset(16, 10),
		BackgroundColor3 = Color3.fromRGB(232, 232, 232),
		BorderSizePixel = 0,
		Parent = holder,
	})
	Corner(body, 4)
	local dark = Color3.fromRGB(28, 28, 28)
	Create("Frame", { Position = UDim2.fromOffset(3, 10), Size = UDim2.fromOffset(5, 2), BackgroundColor3 = dark, BorderSizePixel = 0, Parent = holder })
	Create("Frame", { Position = UDim2.fromOffset(4.5, 8.5), Size = UDim2.fromOffset(2, 5), BackgroundColor3 = dark, BorderSizePixel = 0, Parent = holder })
	for _, p in ipairs({ { 11, 9.5 }, { 13.5, 11.5 } }) do
		local d = Create("Frame", { Position = UDim2.fromOffset(p[1], p[2]), Size = UDim2.fromOffset(2, 2), BackgroundColor3 = dark, BorderSizePixel = 0, Parent = holder })
		Corner(d, "full")
	end
	local hat = Create("Frame", { Position = UDim2.fromOffset(3, 1), Size = UDim2.fromOffset(11, 6), BackgroundColor3 = Color3.fromRGB(220, 38, 38), BorderSizePixel = 0, Rotation = -8, Parent = holder })
	Corner(hat, 4)
	local trim = Create("Frame", { Position = UDim2.fromOffset(2, 5), Size = UDim2.fromOffset(13, 3), BackgroundColor3 = Color3.fromRGB(250, 250, 250), BorderSizePixel = 0, Parent = holder })
	Corner(trim, "full")
	local pom = Create("Frame", { Position = UDim2.fromOffset(11.5, 0), Size = UDim2.fromOffset(4, 4), BackgroundColor3 = Color3.fromRGB(250, 250, 250), BorderSizePixel = 0, Parent = holder })
	Corner(pom, "full")
	return holder
end

----------------------------------------------------------------------
-- Classes
----------------------------------------------------------------------
local WindowClass, TabClass, SectionClass = {}, {}, {}
WindowClass.__index = WindowClass
TabClass.__index = TabClass
SectionClass.__index = SectionClass

function WindowClass:_Connect(signal, fn)
	local c = signal:Connect(fn)
	table.insert(self.Connections, c)
	return c
end

local function BindFlag(opts, obj)
	obj.Flag = opts.Flag
	if opts.Flag then
		Library.Flags[opts.Flag] = obj.Value
		Library.Options[opts.Flag] = obj
	end
end

local function Commit(obj, opts, silent)
	if obj.Flag then
		Library.Flags[obj.Flag] = obj.Value
	end
	if not silent then
		task.spawn(SafeCall, opts.Callback, obj.Value)
		Library:_AutoSave()
	end
end

local function Register(section, name, frame, obj)
	obj.Frame = frame
	obj.Name = name
	table.insert(section.Elements, obj)
	frame.LayoutOrder = #section.Elements
	return obj
end

----------------------------------------------------------------------
-- Window
----------------------------------------------------------------------
function Library:CreateWindow(opts)
	opts = opts or {}
	local Window = setmetatable({
		Tabs = {},
		Connections = {},
		ActiveTab = nil,
		ToggleKey = opts.ToggleKey or Enum.KeyCode.RightShift,
	}, WindowClass)

	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
	local size = opts.Size or Vector2.new(912, 572)
	if typeof(size) == "UDim2" then
		size = Vector2.new(size.X.Offset, size.Y.Offset)
	end
	local width = math.min(size.X, vp.X - 24)
	local height = math.min(size.Y, vp.Y - 24)

	local Gui = Create("ScreenGui", {
		Name = HttpService:GenerateGUID(false),
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 999,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	Gui.Parent = GetGuiParent()
	Window.Gui = Gui

	local Root = Create("Frame", {
		Name = "Root",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(width, height),
		BackgroundColor3 = Theme.Root,
		BorderSizePixel = 0,
		Parent = Gui,
	})
	Corner(Root, 22)
	Stroke(Root, Theme.RootStroke)
	Window.Root = Root

	local Main = Create("Frame", {
		Name = "Main",
		Position = UDim2.fromOffset(5, 5),
		Size = UDim2.new(1, -10, 1, -10),
		BackgroundColor3 = Theme.Main,
		BorderSizePixel = 0,
		Parent = Root,
	})
	Corner(Main, 18)
	Stroke(Main, Theme.MainStroke)

	-- Overlay (dropdown lists live here so they are never clipped)
	local Overlay = Create("Frame", {
		Name = "Overlay",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 10,
		Parent = Root,
	})
	local Blocker = Create("TextButton", {
		Name = "Blocker",
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		ZIndex = 1,
		Parent = Overlay,
	})
	Blocker.MouseButton1Click:Connect(function()
		if Window.CloseDropdown then
			Window.CloseDropdown()
		end
	end)
	Window.Overlay, Window.Blocker = Overlay, Blocker

	----------------------------------------------------------------
	-- Top bar
	----------------------------------------------------------------
	local TopBar = Create("Frame", {
		Name = "TopBar",
		Position = UDim2.fromOffset(8, 8),
		Size = UDim2.new(1, -16, 0, 42),
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		Parent = Main,
	})
	Corner(TopBar, 14)

	local Brand = Create("Frame", {
		Name = "Brand",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(15, 0),
		Size = UDim2.fromOffset(0, 42),
		AutomaticSize = Enum.AutomaticSize.X,
		Parent = TopBar,
	})
	Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 9),
		Parent = Brand,
	})
	local logoSlot = Create("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(18, 18), LayoutOrder = 1, Parent = Brand })
	MakeLogo(logoSlot, opts.Logo)
	local TitleGroup = Create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(0, 20),
		AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = 2,
		Parent = Brand,
	})
	Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 0),
		Parent = TitleGroup,
	})
	NewText({
		Text = opts.Title or "TZAR",
		TextSize = 15,
		Weight = W.Bold,
		Size = UDim2.fromOffset(0, 20),
		AutomaticSize = Enum.AutomaticSize.X,
		Parent = TitleGroup,
	}).LayoutOrder = 1
	NewText({
		Text = opts.Subtitle or ".cc",
		TextSize = 15,
		Weight = W.Medium,
		Color = Theme.Muted,
		Size = UDim2.fromOffset(0, 20),
		AutomaticSize = Enum.AutomaticSize.X,
		Parent = TitleGroup,
	}).LayoutOrder = 2

	-- icon buttons (right side): close, sliders, search
	local function TopButton(iconName, index, callback)
		local b = Create("TextButton", {
			Name = iconName,
			Text = "",
			AutoButtonColor = false,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -13 - 28 * (index - 1), 0.5, 0),
			Size = UDim2.fromOffset(28, 28),
			BackgroundColor3 = Theme.TabActive,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Parent = TopBar,
		})
		Corner(b, 10)
		local icon = MakeIcon(iconName, b, 14, Theme.IconIdle)
		icon.Holder.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Holder.Position = UDim2.fromScale(0.5, 0.5)
		b.MouseEnter:Connect(function()
			Tween(b, { BackgroundTransparency = 0 }, 0.12)
			icon:SetColor(Theme.Text)
		end)
		b.MouseLeave:Connect(function()
			Tween(b, { BackgroundTransparency = 1 }, 0.12)
			icon:SetColor(Theme.IconIdle)
		end)
		b.MouseButton1Click:Connect(callback)
		return b
	end

	-- search box
	local SearchFrame = Create("Frame", {
		Name = "Search",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -(13 + 28 * 3 + 6), 0.5, 0),
		Size = UDim2.fromOffset(188, 24),
		BackgroundColor3 = Theme.Input,
		BorderSizePixel = 0,
		Visible = false,
		Parent = TopBar,
	})
	Corner(SearchFrame, "full")
	Stroke(SearchFrame, Theme.InputStroke)
	local SearchBox = Create("TextBox", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -24, 1, 0),
		Position = UDim2.fromOffset(12, 0),
		FontFace = GetFont(),
		Text = "",
		PlaceholderText = "Search...",
		PlaceholderColor3 = Theme.Placeholder,
		TextColor3 = Theme.TextDim,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		Parent = SearchFrame,
	})

	TopButton("close", 1, function()
		if opts.OnClose then
			SafeCall(opts.OnClose)
		end
		Window:Destroy()
	end)
	TopButton("sliders", 2, function()
		if opts.OnSettings then
			SafeCall(opts.OnSettings)
		else
			Window:SelectTab(opts.SettingsTab or "Settings")
		end
	end)
	TopButton("search", 3, function()
		SearchFrame.Visible = not SearchFrame.Visible
		if SearchFrame.Visible then
			SearchBox:CaptureFocus()
		else
			SearchBox.Text = ""
		end
	end)

	SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
		Window:Search(SearchBox.Text)
	end)

	-- dragging
	do
		local dragging, dragStart, startPos = false, nil, nil
		TopBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = Root.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		Window:_Connect(UserInputService.InputChanged, function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local d = input.Position - dragStart
				Root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end)
	end

	----------------------------------------------------------------
	-- Body: sidebar + pages
	----------------------------------------------------------------
	local Body = Create("Frame", {
		Name = "Body",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(8, 58),
		Size = UDim2.new(1, -16, 1, -66),
		Parent = Main,
	})
	local Sidebar = Create("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, 215, 1, 0),
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		Parent = Body,
	})
	Corner(Sidebar, 16)
	local TabList = Create("ScrollingFrame", {
		Name = "Tabs",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 0,
		Parent = Sidebar,
	})
	Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 1), Parent = TabList })
	Create("UIPadding", {
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 6),
		PaddingLeft = UDim.new(0, 5),
		PaddingRight = UDim.new(0, 5),
		Parent = TabList,
	})
	local Pages = Create("Frame", {
		Name = "Pages",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(230, 0),
		Size = UDim2.new(1, -230, 1, 0),
		ClipsDescendants = true,
		Parent = Body,
	})
	Window.TabList, Window.Pages = TabList, Pages

	-- toggle key
	Window:_Connect(UserInputService.InputBegan, function(input, processed)
		if processed then
			return
		end
		if input.KeyCode == Window.ToggleKey then
			Window:Toggle()
		end
	end)

	table.insert(Library.Windows, Window)
	return Window
end

function WindowClass:Toggle(state)
	if state == nil then
		state = not self.Root.Visible
	end
	if not state and self.CloseDropdown then
		self.CloseDropdown()
	end
	self.Root.Visible = state
end

function WindowClass:Destroy()
	if self.CloseDropdown then
		self.CloseDropdown()
	end
	for _, c in ipairs(self.Connections) do
		c:Disconnect()
	end
	self.Connections = {}
	if self.Gui then
		self.Gui:Destroy()
	end
	local i = table.find(Library.Windows, self)
	if i then
		table.remove(Library.Windows, i)
	end
end

function WindowClass:SelectTab(tab)
	if type(tab) == "string" then
		for _, t in ipairs(self.Tabs) do
			if t.Name == tab then
				tab = t
				break
			end
		end
	end
	if type(tab) ~= "table" or not tab.Page then
		return
	end
	if self.CloseDropdown then
		self.CloseDropdown()
	end
	for _, t in ipairs(self.Tabs) do
		local active = (t == tab)
		t.Active = active
		t.Page.Visible = active
		Tween(t.Button, { BackgroundTransparency = active and 0 or 1 }, 0.15)
		t.Label.FontFace = GetFont(active and W.SemiBold or W.Medium)
		Tween(t.Label, { TextColor3 = active and Theme.Text or Theme.Muted }, 0.15)
		t.Icon:SetColor(active and Theme.Text or Theme.Muted)
	end
	self.ActiveTab = tab
end

function WindowClass:Search(query)
	query = (query or ""):lower()
	local firstTabWithMatch, activeHasMatch = nil, false
	for _, tab in ipairs(self.Tabs) do
		local tabMatch = false
		for _, sec in ipairs(tab.Sections) do
			local any = false
			for _, el in ipairs(sec.Elements) do
				local m = query == "" or tostring(el.Name or ""):lower():find(query, 1, true) ~= nil
				el.Frame.Visible = m
				any = any or m
			end
			sec.Container.Visible = any or query == ""
			sec.Body.Visible = (query ~= "") or sec.Open
			tabMatch = tabMatch or any
		end
		if query ~= "" and tabMatch then
			firstTabWithMatch = firstTabWithMatch or tab
			if tab == self.ActiveTab then
				activeHasMatch = true
			end
		end
	end
	if query ~= "" and not activeHasMatch and firstTabWithMatch then
		self:SelectTab(firstTabWithMatch)
	end
end

----------------------------------------------------------------------
-- Tab
----------------------------------------------------------------------
function WindowClass:AddTab(opts)
	if type(opts) == "string" then
		opts = { Name = opts }
	end
	opts = opts or {}
	local Tab = setmetatable({
		Window = self,
		Name = opts.Name or "Tab",
		Sections = {},
		Active = false,
	}, TabClass)

	local btn = Create("TextButton", {
		Name = Tab.Name,
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.new(1, 0, 0, 31),
		BackgroundColor3 = Theme.TabActive,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = #self.Tabs + 1,
		Parent = self.TabList,
	})
	Corner(btn, 12)
	local icon = MakeIcon(opts.Icon or "wrench", btn, 14, Theme.Muted)
	icon.Holder.Position = UDim2.new(0, 15, 0.5, -7)
	local label = NewText({
		Text = Tab.Name,
		TextSize = 12,
		Weight = W.Medium,
		Color = Theme.Muted,
		Position = UDim2.fromOffset(36, 0),
		Size = UDim2.new(1, -44, 1, 0),
		Truncate = Enum.TextTruncate.AtEnd,
		Parent = btn,
	})

	local page = Create("ScrollingFrame", {
		Name = Tab.Name,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Scroll,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		VerticalScrollBarInset = Enum.ScrollBarInset.None,
		Visible = false,
		Parent = self.Pages,
	})
	Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = page })
	Create("UIPadding", {
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 6),
		Parent = page,
	})

	Tab.Button, Tab.Label, Tab.Icon, Tab.Page = btn, label, icon, page

	btn.MouseEnter:Connect(function()
		if not Tab.Active then
			Tween(label, { TextColor3 = Theme.MutedHover }, 0.12)
			icon:SetColor(Theme.MutedHover)
		end
	end)
	btn.MouseLeave:Connect(function()
		if not Tab.Active then
			Tween(label, { TextColor3 = Theme.Muted }, 0.12)
			icon:SetColor(Theme.Muted)
		end
	end)
	btn.MouseButton1Click:Connect(function()
		self:SelectTab(Tab)
	end)

	table.insert(self.Tabs, Tab)
	if #self.Tabs == 1 then
		self:SelectTab(Tab)
	end
	return Tab
end

----------------------------------------------------------------------
-- Section (collapsible)
----------------------------------------------------------------------
function TabClass:AddSection(opts)
	if type(opts) == "string" then
		opts = { Name = opts }
	end
	opts = opts or {}
	local Section = setmetatable({
		Tab = self,
		Window = self.Window,
		Name = opts.Name or "Section",
		Elements = {},
		Open = not opts.Collapsed,
	}, SectionClass)

	local container = Create("Frame", {
		Name = Section.Name,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = #self.Sections + 1,
		Parent = self.Page,
	})
	Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 0), Parent = container })

	local header = Create("TextButton", {
		Name = "Header",
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = Theme.Header,
		BorderSizePixel = 0,
		LayoutOrder = 1,
		Parent = container,
	})
	Corner(header, 12)
	NewText({
		Text = Spaced(string.upper(Section.Name)),
		TextSize = 10,
		Weight = W.Bold,
		Color = Theme.HeaderText,
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, -50, 1, 0),
		Parent = header,
	})
	local chev = MakeIcon("chevron", header, 12, Theme.HeaderText)
	chev.Holder.AnchorPoint = Vector2.new(0.5, 0.5)
	chev.Holder.Position = UDim2.new(1, -22, 0.5, 0)
	chev.Holder.Rotation = Section.Open and 0 or -90

	local body = Create("Frame", {
		Name = "Body",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		Visible = Section.Open,
		Parent = container,
	})
	Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 18), Parent = body })
	Create("UIPadding", {
		PaddingTop = UDim.new(0, 11),
		PaddingBottom = UDim.new(0, 16),
		PaddingLeft = UDim.new(0, 14),
		PaddingRight = UDim.new(0, 14),
		Parent = body,
	})

	header.MouseEnter:Connect(function()
		Tween(header, { BackgroundColor3 = Color3.fromRGB(32, 32, 32) }, 0.12)
	end)
	header.MouseLeave:Connect(function()
		Tween(header, { BackgroundColor3 = Theme.Header }, 0.12)
	end)
	header.MouseButton1Click:Connect(function()
		Section:SetOpen(not Section.Open)
	end)

	function Section:SetOpen(state)
		self.Open = state
		self.Body.Visible = state
		Tween(chev.Holder, { Rotation = state and 0 or -90 }, 0.15)
	end

	Section.Container, Section.Body = container, body
	table.insert(self.Sections, Section)
	return Section
end

----------------------------------------------------------------------
-- Elements
----------------------------------------------------------------------

-- Toggle -------------------------------------------------------------
function SectionClass:AddToggle(opts)
	opts = opts or {}
	local hasDesc = opts.Description ~= nil and opts.Description ~= ""
	local obj = { Type = "Toggle", Value = false }

	local frame = Create("Frame", {
		Name = "Toggle",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, hasDesc and 39 or 20),
		Parent = self.Body,
	})
	local title = NewText({
		Text = opts.Name or "Toggle",
		TextSize = 13,
		Position = UDim2.fromOffset(0, hasDesc and 0 or 2),
		Size = UDim2.new(1, -56, 0, 16),
		Truncate = Enum.TextTruncate.AtEnd,
		Parent = frame,
	})
	local desc
	if hasDesc then
		desc = NewText({
			Text = opts.Description,
			TextSize = 10,
			Color = Theme.Description,
			Position = UDim2.fromOffset(0, 20),
			Size = UDim2.new(1, -56, 0, 14),
			Truncate = Enum.TextTruncate.AtEnd,
			Parent = frame,
		})
	end

	local switch = Create("Frame", {
		Name = "Switch",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -1, 0, hasDesc and 17 or 10),
		Size = UDim2.fromOffset(34, 18),
		BackgroundColor3 = Theme.ToggleOff,
		BorderSizePixel = 0,
		Parent = frame,
	})
	Corner(switch, "full")
	local stroke = Stroke(switch, Theme.ToggleStroke)
	local knob = Create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 2, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = Theme.Knob,
		BorderSizePixel = 0,
		Parent = switch,
	})
	Corner(knob, "full")
	local hit = Create("TextButton", {
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 3,
		Parent = frame,
	})

	function obj:Set(v, silent)
		v = not not v
		self.Value = v
		Tween(switch, { BackgroundColor3 = v and Theme.Accent or Theme.ToggleOff }, 0.16)
		Tween(stroke, { Color = v and Theme.Accent or Theme.ToggleStroke }, 0.16)
		Tween(knob, { Position = v and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0) }, 0.16)
		Commit(self, opts, silent)
	end
	function obj:Get()
		return self.Value
	end
	function obj:Serialize()
		return self.Value
	end
	function obj:SetName(n)
		title.Text = n
		self.Name = n
	end

	hit.MouseButton1Click:Connect(function()
		obj:Set(not obj.Value)
	end)

	BindFlag(opts, obj)
	Register(self, opts.Name, frame, obj)
	if opts.Default then
		obj:Set(true, true)
		Commit(obj, opts, true)
	end
	return obj
end

-- Button -------------------------------------------------------------
function SectionClass:AddButton(opts)
	if type(opts) == "string" then
		opts = { Name = opts }
	end
	opts = opts or {}
	local obj = { Type = "Button", Text = opts.Name or "Button" }

	local btn = Create("TextButton", {
		Name = "Button",
		Text = obj.Text,
		AutoButtonColor = false,
		FontFace = GetFont(W.Bold),
		TextSize = 11,
		TextColor3 = Theme.AccentText,
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(0, 30),
		AutomaticSize = Enum.AutomaticSize.X,
		Parent = self.Body,
	})
	Corner(btn, "full")
	Create("UIPadding", { PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15), Parent = btn })

	local hover = Theme.Accent:Lerp(Color3.new(1, 1, 1), 0.14)
	local press = Theme.Accent:Lerp(Color3.new(0, 0, 0), 0.18)
	btn.MouseEnter:Connect(function()
		Tween(btn, { BackgroundColor3 = hover }, 0.12)
	end)
	btn.MouseLeave:Connect(function()
		Tween(btn, { BackgroundColor3 = Theme.Accent }, 0.12)
	end)
	btn.MouseButton1Down:Connect(function()
		Tween(btn, { BackgroundColor3 = press }, 0.08)
	end)
	btn.MouseButton1Up:Connect(function()
		Tween(btn, { BackgroundColor3 = hover }, 0.08)
	end)
	btn.MouseButton1Click:Connect(function()
		task.spawn(SafeCall, opts.Callback)
	end)

	function obj:SetText(t)
		self.Text = t
		btn.Text = t
	end
	function obj:Fire()
		task.spawn(SafeCall, opts.Callback)
	end

	Register(self, opts.Name, btn, obj)
	return obj
end

-- Dropdown -----------------------------------------------------------
function SectionClass:AddDropdown(opts)
	opts = opts or {}
	local window = self.Window
	local multi = opts.Multi == true
	local obj = { Type = "Dropdown", Multi = multi, Options = table.clone(opts.Options or {}), Value = multi and {} or nil }

	local frame = Create("Frame", {
		Name = "Dropdown",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 58),
		Parent = self.Body,
	})
	NewText({ Text = opts.Name or "Dropdown", TextSize = 13, Size = UDim2.new(1, 0, 0, 16), Parent = frame })

	local box = Create("TextButton", {
		Name = "Box",
		Text = "",
		AutoButtonColor = false,
		Position = UDim2.fromOffset(1, 23),
		Size = UDim2.new(1, -2, 0, 28),
		BackgroundColor3 = Theme.Input,
		BorderSizePixel = 0,
		Parent = frame,
	})
	Corner(box, "full")
	local boxStroke = Stroke(box, Theme.InputStroke)
	local valueLabel = NewText({
		Text = "",
		TextSize = 11,
		Color = Theme.TextDim,
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, -44, 1, 0),
		Truncate = Enum.TextTruncate.AtEnd,
		Parent = box,
	})
	local chevron = MakeIcon("chevron", box, 12, Theme.Muted)
	chevron.Holder.AnchorPoint = Vector2.new(0.5, 0.5)
	chevron.Holder.Position = UDim2.new(1, -20, 0.5, 0)

	-- floating list
	local list = Create("Frame", {
		Name = "DropdownList",
		Visible = false,
		BackgroundColor3 = Theme.Input,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(100, 100),
		ZIndex = 2,
		Parent = window.Overlay,
	})
	Corner(list, 14)
	Stroke(list, Theme.InputStroke)
	local scroller = Create("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(5, 5),
		Size = UDim2.new(1, -10, 1, -10),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Scroll,
		Parent = list,
	})
	Create("UIListLayout", { Padding = UDim.new(0, 1), SortOrder = Enum.SortOrder.LayoutOrder, Parent = scroller })

	local optionButtons = {}
	local open, renderConn, listHeight = false, nil, 0

	local function isSelected(opt)
		if multi then
			return table.find(obj.Value, opt) ~= nil
		end
		return obj.Value == opt
	end

	local function refreshVisual()
		if multi then
			valueLabel.Text = (#obj.Value > 0) and table.concat(obj.Value, ", ") or (opts.Placeholder or "None")
		else
			valueLabel.Text = (obj.Value ~= nil) and tostring(obj.Value) or (opts.Placeholder or "Select...")
		end
		for opt, b in pairs(optionButtons) do
			local sel = isSelected(opt)
			b.TextColor3 = sel and Theme.Accent or Theme.TextDim
			b.FontFace = GetFont(sel and W.SemiBold or W.Medium)
		end
	end

	local closeList
	local function reposition()
		local bp, bs = box.AbsolutePosition, box.AbsoluteSize
		local op, os = window.Overlay.AbsolutePosition, window.Overlay.AbsoluteSize
		local x = bp.X - op.X
		local y = bp.Y - op.Y + bs.Y + 6
		if y + listHeight > os.Y - 6 then
			y = bp.Y - op.Y - listHeight - 6
		end
		list.Position = UDim2.fromOffset(x, y)
		list.Size = UDim2.fromOffset(bs.X, listHeight)
	end

	local function openList()
		if #obj.Options == 0 then
			return
		end
		if window.CloseDropdown then
			window.CloseDropdown()
		end
		open = true
		listHeight = math.min(#obj.Options, 6) * 27 + 9
		window.Blocker.Visible = true
		list.Visible = true
		Tween(chevron.Holder, { Rotation = 180 }, 0.15)
		Tween(boxStroke, { Color = Theme.InputStrokeFocus }, 0.15)
		renderConn = RunService.RenderStepped:Connect(reposition)
		reposition()
		window.CloseDropdown = closeList
	end

	closeList = function()
		if not open then
			return
		end
		open = false
		list.Visible = false
		window.Blocker.Visible = false
		Tween(chevron.Holder, { Rotation = 0 }, 0.15)
		Tween(boxStroke, { Color = Theme.InputStroke }, 0.15)
		if renderConn then
			renderConn:Disconnect()
			renderConn = nil
		end
		if window.CloseDropdown == closeList then
			window.CloseDropdown = nil
		end
	end

	local function choose(opt)
		if multi then
			local new = table.clone(obj.Value)
			local i = table.find(new, opt)
			if i then
				table.remove(new, i)
			else
				table.insert(new, opt)
			end
			obj:Set(new)
		else
			obj:Set(opt)
			closeList()
		end
	end

	local function build()
		for _, c in ipairs(scroller:GetChildren()) do
			if c:IsA("TextButton") then
				c:Destroy()
			end
		end
		table.clear(optionButtons)
		for i, opt in ipairs(obj.Options) do
			local b = Create("TextButton", {
				Text = tostring(opt),
				AutoButtonColor = false,
				BackgroundColor3 = Theme.TabActive,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 26),
				FontFace = GetFont(),
				TextSize = 11,
				TextColor3 = Theme.TextDim,
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = i,
				Parent = scroller,
			})
			Corner(b, 10)
			Create("UIPadding", { PaddingLeft = UDim.new(0, 10), Parent = b })
			b.MouseEnter:Connect(function()
				Tween(b, { BackgroundTransparency = 0 }, 0.1)
			end)
			b.MouseLeave:Connect(function()
				Tween(b, { BackgroundTransparency = 1 }, 0.1)
			end)
			b.MouseButton1Click:Connect(function()
				choose(opt)
			end)
			optionButtons[opt] = b
		end
		refreshVisual()
	end

	function obj:Set(v, silent)
		if multi then
			local clean = {}
			if type(v) == "table" then
				for _, x in ipairs(v) do
					if table.find(self.Options, x) and not table.find(clean, x) then
						table.insert(clean, x)
					end
				end
			end
			self.Value = clean
		else
			if v ~= nil and not table.find(self.Options, v) then
				return
			end
			self.Value = v
		end
		refreshVisual()
		Commit(self, opts, silent)
	end
	function obj:Get()
		return self.Value
	end
	function obj:Serialize()
		return self.Value
	end
	function obj:Refresh(newOptions, keepValue)
		self.Options = table.clone(newOptions or {})
		if multi then
			local clean = {}
			for _, x in ipairs(self.Value) do
				if keepValue ~= false and table.find(self.Options, x) then
					table.insert(clean, x)
				end
			end
			self.Value = clean
		elseif self.Value == nil or not table.find(self.Options, self.Value) then
			if opts.AllowNull then
				self.Value = nil
			else
				self.Value = self.Options[1]
			end
		end
		build()
		if self.Flag then
			Library.Flags[self.Flag] = self.Value
		end
	end

	box.MouseButton1Click:Connect(function()
		if open then
			closeList()
		else
			openList()
		end
	end)
	box.MouseEnter:Connect(function()
		if not open then
			Tween(boxStroke, { Color = Theme.InputStrokeFocus }, 0.12)
		end
	end)
	box.MouseLeave:Connect(function()
		if not open then
			Tween(boxStroke, { Color = Theme.InputStroke }, 0.12)
		end
	end)
	frame.Destroying:Connect(function()
		closeList()
		list:Destroy()
	end)

	-- initial value
	if multi then
		obj.Value = {}
		if type(opts.Default) == "table" then
			obj.Value = table.clone(opts.Default)
		end
	else
		obj.Value = opts.Default
		if obj.Value == nil and not opts.AllowNull then
			obj.Value = obj.Options[1]
		end
	end
	build()
	BindFlag(opts, obj)
	Register(self, opts.Name, frame, obj)
	return obj
end

-- Textbox ------------------------------------------------------------
function SectionClass:AddTextbox(opts)
	opts = opts or {}
	local obj = { Type = "Textbox", Value = opts.Default or "" }

	local frame = Create("Frame", {
		Name = "Textbox",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 53),
		Parent = self.Body,
	})
	NewText({ Text = opts.Name or "Textbox", TextSize = 13, Size = UDim2.new(1, 0, 0, 16), Parent = frame })

	local box = Create("TextBox", {
		Name = "Input",
		Position = UDim2.fromOffset(1, 21),
		Size = UDim2.new(1, -2, 0, 28),
		BackgroundColor3 = Theme.Input,
		BorderSizePixel = 0,
		FontFace = GetFont(),
		Text = obj.Value,
		PlaceholderText = opts.Placeholder or "Enter value...",
		PlaceholderColor3 = Theme.Placeholder,
		TextColor3 = Theme.TextDim,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = opts.ClearOnFocus == true,
		Parent = frame,
	})
	Corner(box, "full")
	local stroke = Stroke(box, Theme.InputStroke)
	Create("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), Parent = box })

	box.Focused:Connect(function()
		Tween(stroke, { Color = Theme.InputStrokeFocus }, 0.12)
	end)
	box.FocusLost:Connect(function()
		Tween(stroke, { Color = Theme.InputStroke }, 0.12)
		local text = box.Text
		if opts.Numeric then
			local n = tonumber(text)
			if n == nil then
				box.Text = obj.Value
				return
			end
			text = tostring(n)
		end
		obj.Value = text
		Commit(obj, opts, false)
	end)
	box:GetPropertyChangedSignal("Text"):Connect(function()
		obj.Value = box.Text
		if obj.Flag then
			Library.Flags[obj.Flag] = obj.Value
		end
	end)

	function obj:Set(v, silent)
		v = tostring(v or "")
		box.Text = v
		self.Value = v
		Commit(self, opts, silent)
	end
	function obj:Get()
		return self.Value
	end
	function obj:Serialize()
		return self.Value
	end

	BindFlag(opts, obj)
	Register(self, opts.Name, frame, obj)
	return obj
end

-- Slider -------------------------------------------------------------
function SectionClass:AddSlider(opts)
	opts = opts or {}
	local window = self.Window
	local min, max = opts.Min or 0, opts.Max or 100
	local inc = opts.Increment or 1
	local suffix = opts.Suffix or ""
	local decimals = (string.format("%.10g", inc):match("%.(%d+)") or ""):len()
	local obj = { Type = "Slider", Value = min }

	local frame = Create("Frame", {
		Name = "Slider",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 40),
		Parent = self.Body,
	})
	NewText({ Text = opts.Name or "Slider", TextSize = 13, Size = UDim2.new(1, -70, 0, 16), Parent = frame })
	local valueLabel = NewText({
		Text = "",
		TextSize = 11,
		Color = Theme.Description,
		XAlignment = Enum.TextXAlignment.Right,
		Position = UDim2.new(1, -70, 0, 0),
		Size = UDim2.fromOffset(70, 16),
		Parent = frame,
	})
	local track = Create("Frame", {
		Name = "Track",
		Position = UDim2.fromOffset(1, 26),
		Size = UDim2.new(1, -2, 0, 6),
		BackgroundColor3 = Theme.Input,
		BorderSizePixel = 0,
		Parent = frame,
	})
	Corner(track, "full")
	Stroke(track, Theme.InputStroke)
	local fill = Create("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Parent = track,
	})
	Corner(fill, "full")
	local knob = Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = Theme.Knob,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = track,
	})
	Corner(knob, "full")
	local hit = Create("TextButton", {
		Text = "",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 16),
		Size = UDim2.new(1, 0, 0, 24),
		ZIndex = 3,
		Parent = frame,
	})

	function obj:Set(v, silent)
		v = tonumber(v) or min
		v = RoundTo(math.clamp(v, min, max), inc)
		self.Value = v
		local a = (max == min) and 0 or (v - min) / (max - min)
		fill.Size = UDim2.fromScale(a, 1)
		knob.Position = UDim2.new(a, 0, 0.5, 0)
		valueLabel.Text = string.format("%." .. decimals .. "f", v) .. suffix
		Commit(self, opts, silent)
	end
	function obj:Get()
		return self.Value
	end
	function obj:Serialize()
		return self.Value
	end

	local dragging = false
	local function update(x)
		local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X), 0, 1)
		obj:Set(min + (max - min) * rel)
	end
	hit.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			update(input.Position.X)
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	window:_Connect(UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			update(input.Position.X)
		end
	end)

	BindFlag(opts, obj)
	Register(self, opts.Name, frame, obj)
	obj:Set(opts.Default or min, true)
	Commit(obj, opts, true)
	return obj
end

-- Keybind ------------------------------------------------------------
function SectionClass:AddKeybind(opts)
	opts = opts or {}
	local window = self.Window
	local hasDesc = opts.Description ~= nil and opts.Description ~= ""
	local obj = { Type = "Keybind", Value = nil }

	local frame = Create("Frame", {
		Name = "Keybind",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, hasDesc and 39 or 24),
		Parent = self.Body,
	})
	NewText({
		Text = opts.Name or "Keybind",
		TextSize = 13,
		Position = UDim2.fromOffset(0, hasDesc and 0 or 4),
		Size = UDim2.new(1, -110, 0, 16),
		Parent = frame,
	})
	if hasDesc then
		NewText({
			Text = opts.Description,
			TextSize = 10,
			Color = Theme.Description,
			Position = UDim2.fromOffset(0, 20),
			Size = UDim2.new(1, -110, 0, 14),
			Truncate = Enum.TextTruncate.AtEnd,
			Parent = frame,
		})
	end
	local pill = Create("TextButton", {
		Name = "Key",
		Text = "None",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -1, 0, hasDesc and 17 or 12),
		Size = UDim2.fromOffset(0, 22),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Theme.Input,
		BorderSizePixel = 0,
		FontFace = GetFont(W.SemiBold),
		TextSize = 10,
		TextColor3 = Theme.TextDim,
		Parent = frame,
	})
	Corner(pill, "full")
	local stroke = Stroke(pill, Theme.InputStroke)
	Create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = pill })

	local listening = false
	function obj:Set(v, silent)
		if type(v) == "string" then
			local ok, key = pcall(function()
				return Enum.KeyCode[v]
			end)
			v = ok and key or nil
		end
		self.Value = v
		pill.Text = v and v.Name or "None"
		if self.Flag then
			Library.Flags[self.Flag] = v and v.Name or nil
		end
		if not silent then
			task.spawn(SafeCall, opts.Changed, v)
			Library:_AutoSave()
		end
	end
	function obj:Get()
		return self.Value
	end
	function obj:Serialize()
		return self.Value and self.Value.Name or "None"
	end

	pill.MouseButton1Click:Connect(function()
		listening = true
		pill.Text = "..."
		Tween(stroke, { Color = Theme.Accent }, 0.12)
	end)

	window:_Connect(UserInputService.InputBegan, function(input, processed)
		if listening then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				listening = false
				Tween(stroke, { Color = Theme.InputStroke }, 0.12)
				if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Escape then
					obj:Set(nil)
				else
					obj:Set(input.KeyCode)
				end
			end
			return
		end
		if not processed and obj.Value and input.KeyCode == obj.Value then
			task.spawn(SafeCall, opts.Callback, obj.Value)
		end
	end)

	BindFlag(opts, obj)
	Register(self, opts.Name, frame, obj)
	obj:Set(opts.Default, true)
	return obj
end

-- Label --------------------------------------------------------------
function SectionClass:AddLabel(text)
	local obj = { Type = "Label" }
	local lbl = NewText({
		Name = "Label",
		Text = type(text) == "table" and text.Text or text or "",
		TextSize = 11,
		Color = Theme.Description,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Wrapped = true,
		YAlignment = Enum.TextYAlignment.Top,
		Parent = self.Body,
	})
	function obj:SetText(t)
		lbl.Text = t
	end
	Register(self, lbl.Text, lbl, obj)
	return obj
end

----------------------------------------------------------------------
-- Notifications
----------------------------------------------------------------------
function Library:Notify(opts)
	if type(opts) == "string" then
		opts = { Content = opts }
	end
	opts = opts or {}
	if not self._notifyHolder or not self._notifyHolder.Parent then
		local gui = Create("ScreenGui", {
			Name = HttpService:GenerateGUID(false),
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			DisplayOrder = 1000,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		})
		gui.Parent = GetGuiParent()
		local holder = Create("Frame", {
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -18, 1, -18),
			Size = UDim2.fromOffset(280, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Parent = gui,
		})
		Create("UIListLayout", {
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Parent = holder,
		})
		self._notifyGui, self._notifyHolder = gui, holder
	end

	local wrap = Create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = self._notifyHolder,
	})
	local card = Create("Frame", {
		Position = UDim2.fromOffset(300, 0),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		Parent = wrap,
	})
	Corner(card, 14)
	Stroke(card, Theme.InputStroke)
	Create("UIPadding", {
		PaddingTop = UDim.new(0, 11),
		PaddingBottom = UDim.new(0, 11),
		PaddingLeft = UDim.new(0, 14),
		PaddingRight = UDim.new(0, 14),
		Parent = card,
	})
	Create("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder, Parent = card })
	NewText({ Text = opts.Title or "TZAR.cc", TextSize = 12, Weight = W.Bold, Size = UDim2.new(1, 0, 0, 16), Parent = card }).LayoutOrder = 1
	if opts.Content then
		NewText({
			Text = opts.Content,
			TextSize = 11,
			Color = Theme.Description,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Wrapped = true,
			YAlignment = Enum.TextYAlignment.Top,
			Parent = card,
		}).LayoutOrder = 2
	end

	Tween(card, { Position = UDim2.fromOffset(0, 0) }, 0.25, Enum.EasingStyle.Quint)
	task.delay(opts.Duration or 4, function()
		if card.Parent then
			Tween(card, { Position = UDim2.fromOffset(300, 0) }, 0.25, Enum.EasingStyle.Quint)
			task.wait(0.28)
		end
		wrap:Destroy()
	end)
end

----------------------------------------------------------------------
-- Config manager (needs executor file functions)
----------------------------------------------------------------------
local function fsOk()
	return typeof(writefile) == "function" and typeof(readfile) == "function"
end

local function cleanName(name)
	name = tostring(name or ""):gsub("[^%w%-%_ ]", "")
	return name
end

function Library:SetFolder(name)
	self.Folder = name
end

function Library:_EnsureFolders()
	if not fsOk() then
		return false
	end
	pcall(function()
		if not isfolder(self.Folder) then
			makefolder(self.Folder)
		end
		if not isfolder(self.Folder .. "/configs") then
			makefolder(self.Folder .. "/configs")
		end
	end)
	return true
end

function Library:ListConfigs()
	local out = {}
	if typeof(listfiles) ~= "function" then
		return out
	end
	self:_EnsureFolders()
	local ok, files = pcall(listfiles, self.Folder .. "/configs")
	if ok and type(files) == "table" then
		for _, f in ipairs(files) do
			local n = f:match("([^/\\]+)%.json$")
			if n then
				table.insert(out, n)
			end
		end
	end
	table.sort(out)
	return out
end

function Library:SaveConfig(name)
	if not fsOk() then
		return false, "writefile not supported"
	end
	name = cleanName(name)
	if name == "" then
		return false, "invalid name"
	end
	self:_EnsureFolders()
	local data = {}
	for flag, o in pairs(self.Options) do
		if o.Serialize then
			data[flag] = o:Serialize()
		end
	end
	local ok, err = pcall(function()
		writefile(self.Folder .. "/configs/" .. name .. ".json", HttpService:JSONEncode(data))
	end)
	return ok, err
end

function Library:LoadConfig(name)
	if not fsOk() then
		return false, "readfile not supported"
	end
	name = cleanName(name)
	local path = self.Folder .. "/configs/" .. name .. ".json"
	local okExists, exists = pcall(function()
		return isfile(path)
	end)
	if not okExists or not exists then
		return false, "config not found"
	end
	local ok, data = pcall(function()
		return HttpService:JSONDecode(readfile(path))
	end)
	if not ok or type(data) ~= "table" then
		return false, "invalid config"
	end
	self._loading = true
	for flag, value in pairs(data) do
		local o = self.Options[flag]
		if o then
			pcall(o.Set, o, value)
		end
	end
	self._loading = false
	return true
end

function Library:DeleteConfig(name)
	if typeof(delfile) ~= "function" then
		return false, "delfile not supported"
	end
	name = cleanName(name)
	local ok, err = pcall(function()
		delfile(self.Folder .. "/configs/" .. name .. ".json")
	end)
	return ok, err
end

function Library:SetAutoLoad(name)
	if not fsOk() then
		return false
	end
	self:_EnsureFolders()
	pcall(function()
		if name and name ~= "" then
			writefile(self.Folder .. "/autoload.txt", cleanName(name))
		elseif typeof(delfile) == "function" and isfile(self.Folder .. "/autoload.txt") then
			delfile(self.Folder .. "/autoload.txt")
		end
	end)
	return true
end

function Library:GetAutoLoad()
	if not fsOk() then
		return nil
	end
	local ok, name = pcall(function()
		local p = self.Folder .. "/autoload.txt"
		return isfile(p) and readfile(p) or nil
	end)
	return ok and name or nil
end

function Library:LoadAutoConfig()
	local name = self:GetAutoLoad()
	if name and name ~= "" then
		self.CurrentProfile = name
		return self:LoadConfig(name)
	end
	return false
end

function Library:_AutoSave()
	if self.AutoSave and self.CurrentProfile and not self._loading then
		self:SaveConfig(self.CurrentProfile)
	end
end

function Library:Unload()
	for i = #self.Windows, 1, -1 do
		self.Windows[i]:Destroy()
	end
	if self._notifyGui then
		self._notifyGui:Destroy()
	end
end

return Library
