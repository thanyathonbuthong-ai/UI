--[[
    FluxusUILib
    Reusable UI library extracted from recovered_ui_lua.txt.
    The script contained two interfaces, both are ported here with the same
    sizes / colors / fonts / corner radii / animations:

      Library.Android  ->  main UI  (loader, key page, sidebar tabs, minimize toggle)
      Library.Coral    ->  Coral UI (left bar with Executor / Cloud / Console / Settings sections)

    No auth, HWID, Discord or executor-specific hooks are included, only UI.
    See Example.lua for usage.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LogService = game:GetService("LogService")

local Library = {}
Library.Version = "1.0.0"

-- Image assets used by the original UI (real image icons, nothing drawn from Frames)
Library.Assets = {
	Logo = "rbxassetid://138900967749432",
	AndroidLogo = "rbxassetid://11434416211",
	Minimize = "rbxassetid://11447435879",
	IconScripts = "rbxassetid://11447575636",
	IconSettings = "rbxassetid://11447558233",
	IconHistory = "rbxassetid://11706698017",
	IconScriptBlox = "rbxassetid://11810985691",
	BannerWelcome = "rbxassetid://11440677815",
	BannerCredits = "rbxassetid://11445329779",
	BannerHistory = "rbxassetid://11706521913",
	BannerScripts = "rbxassetid://11441550965",
	BannerSettings = "rbxassetid://11441541927",
	ImageDefault = "rbxassetid://11440609775",
	ImagePlaceholder = "rbxassetid://11441046007",
}

-- Optional: map icon names (for example Lucide names) to asset ids.
-- Library:SetIconResolver(function(name) return "rbxassetid://..." end)
-- then CreateTab({ Icon = "settings" }) works.
function Library:SetIconResolver(fn)
	Library._iconResolver = fn
end

local function resolveIcon(icon)
	if type(icon) == "number" then
		return "rbxassetid://" .. tostring(icon)
	end
	if type(icon) == "string" and not string.find(icon, "rbx") and not string.find(icon, "://")
		and Library._iconResolver then
		local resolved = Library._iconResolver(icon)
		if resolved then
			return resolved
		end
	end
	return icon
end

--------------------------------------------------------------------------------
-- Shared helpers
--------------------------------------------------------------------------------

local WHITE = Color3.fromRGB(255, 255, 255)
local BLACK = Color3.fromRGB(0, 0, 0)
local V2, U, UD = Vector2.new, UDim2.new, UDim.new
local SCROLL_IMG = "rbxasset://textures/ui/Scroll/scroll-middle.png"

local function New(className, props, children)
	local inst = Instance.new(className)
	local parent = nil
	if props then
		for key, value in pairs(props) do
			if key == "Parent" then
				parent = value
			else
				inst[key] = value
			end
		end
	end
	if children then
		for _, child in ipairs(children) do
			child.Parent = inst
		end
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

-- TextLabel / TextButton with RichText on (the main UI turns it on for all of them)
local function NewA(className, props, children)
	props = props or {}
	if props.RichText == nil then
		props.RichText = true
	end
	return New(className, props, children)
end

local function Corner(parent, radius)
	local c = Instance.new("UICorner")
	if radius then
		c.CornerRadius = UD(0, radius)
	end
	c.Parent = parent
	return c
end

local function copyTable(t)
	local out = {}
	for k, v in pairs(t) do
		out[k] = v
	end
	return out
end

local function mergeInto(base, extra)
	if extra then
		for k, v in pairs(extra) do
			base[k] = v
		end
	end
	return base
end

local function getGuiParent()
	local ok, result = pcall(function()
		return gethui and gethui()
	end)
	if ok and typeof(result) == "Instance" then
		return result
	end
	ok, result = pcall(function()
		local probe = Instance.new("Folder")
		probe.Parent = game:GetService("CoreGui")
		probe:Destroy()
		return game:GetService("CoreGui")
	end)
	if ok and result then
		return result
	end
	return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function wrap(frame, api)
	api.Instance = frame
	function api:SetVisible(state)
		frame.Visible = state
		return self
	end
	return api
end

-- Same drag behaviour as the original (tweened follow, mouse + touch)
local function makeDraggable(base, handle, connections)
	local dragging, dragInput, dragStart, startPos
	local function track(c)
		if connections then
			table.insert(connections, c)
		end
	end
	track(handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = base.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end))
	track(base.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end))
	track(UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			base:TweenPosition(
				U(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Sine,
				0.2,
				true
			)
		end
	end))
end

--------------------------------------------------------------------------------
-- ANDROID UI  (main interface)
--------------------------------------------------------------------------------

local Android = {}
Android.__index = Android

local Tab = {}
Tab.__index = Tab

local SURFACE = Color3.fromRGB(36, 39, 58)
local MANTLE = Color3.fromRGB(30, 32, 48)
local CRUST = Color3.fromRGB(24, 25, 38)

local DEFAULT_STRINGS = {
	KeyInstructions = "Welcome to Fluxus X Android!<br/>Please click 'Get Key' to get a key.<br/>Once you've completed the key system, enter your key below, then click 'Check Key'",
	KeyPlaceholder = "Paste your key here",
	GetKey = "Get Key",
	CheckKey = "Check Key",
	KeyCopied = "Welcome to Fluxus X Android!<br/>The key link was copied to your clipboard - Please open it in a browser.<br/>Need help? Join discord.gg/",
	KeyInvalid = "Your key was incorrect!<br/>Please try getting a new key. If this issue persists, contact support.",
	ExecuteFromTextbox = "Execute from Textbox",
	ExecuteFromClipboard = "Execute from Clipboard",
	Submit = "Submit",
	SearchPlaceholder = "Search Query | Powered by scriptblox.com",
}

local function addBorder(parent)
	local border = New("Frame", {
		Name = "Border",
		Parent = parent,
		AnchorPoint = V2(0.5, 0.5),
		BackgroundColor3 = MANTLE,
		BorderSizePixel = 0,
		Position = U(0.5, 0, 0.5, 0),
		Size = U(1, 8, 1, 8),
		ZIndex = -1,
	})
	Corner(border, 20)
	return border
end

--[[
    Android.new(options)
      Name              ScreenGui name (default "FluxusAndroidUI")
      Parent            custom parent (default gethui / CoreGui / PlayerGui)
      Theme             { ButtonColor, TextColor, TabsColor, EditorColor, EditorTransparent,
                          Background = Color3 | image string }
      Strings           overrides for the default texts (see DEFAULT_STRINGS)
      SmallUI           bool  (container width 70%)
      ScreenHeight      number (default 1)
      FastAnimations / NoAnimations / CenteredMinimize   bool
      TabImages         bool  show the tab banner images (default false, like the original)
]]
function Android.new(options)
	options = options or {}
	local theme = mergeInto({
		ButtonColor = Color3.fromRGB(141, 115, 176),
		TextColor = WHITE,
		TabsColor = MANTLE,
		EditorColor = CRUST,
		EditorTransparent = false,
		Background = nil,
	}, options.Theme)

	local self = setmetatable({}, Android)
	self.Theme = theme
	self.Strings = mergeInto(copyTable(DEFAULT_STRINGS), options.Strings)
	self.Config = {
		FastAnimations = options.FastAnimations or false,
		NoAnimations = options.NoAnimations or false,
		CenteredMinimize = options.CenteredMinimize or false,
		SmallUI = options.SmallUI or false,
		ScreenHeight = options.ScreenHeight or 1,
	}
	self._connections = {}
	self._labels = {}
	self._groups = {}
	self._groupStates = {}
	self._tabs = {}
	self._unminimizeTarget = "Key"
	self._current = "Loader"
	self._busy = false
	self._loadedEvent = Instance.new("BindableEvent")
	self.Loaded = self._loadedEvent.Event
	self._keyCallbacks = {}

	local assets = Library.Assets

	local gui = New("ScreenGui", {
		Name = options.Name or "FluxusAndroidUI",
		DisplayOrder = 1999999999,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	pcall(function()
		gui.ScreenInsets = Enum.ScreenInsets.None
	end)
	self.Gui = gui

	local Container = New("Frame", {
		Name = "Container",
		Parent = gui,
		AnchorPoint = V2(0.5, 0.5),
		BackgroundColor3 = theme.EditorColor,
		BackgroundTransparency = 1,
		Position = U(0.5, 0, 0.5, 0),
		Size = U(1, 0, 1, 0),
	})
	self.Container = Container

	-- Loader ------------------------------------------------------------------
	local Loader = New("Frame", {
		Name = "Loader",
		Parent = Container,
		AnchorPoint = V2(0.5, 0.5),
		BackgroundColor3 = SURFACE,
		BorderColor3 = CRUST,
		BorderSizePixel = 0,
		Position = U(0.5, 0, 0.5, 0),
		Size = U(0.5, 0, 0.5, 0),
	})
	New("UIAspectRatioConstraint", { Parent = Loader })
	addBorder(Loader)
	Corner(Loader, 16)
	local LoaderIcon = New("ImageLabel", {
		Name = "Icon",
		Parent = Loader,
		AnchorPoint = V2(0.5, 0.5),
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		Position = U(0.5, 0, 0.5, 0),
		Size = U(0.75, 0, 0.75, 0),
		Image = options.Logo or assets.AndroidLogo,
	})
	New("UIAspectRatioConstraint", { Parent = LoaderIcon })

	-- Key page ----------------------------------------------------------------
	local Key = New("Frame", {
		Name = "Key",
		Parent = Container,
		AnchorPoint = V2(0.5, 0.5),
		BackgroundColor3 = SURFACE,
		BorderColor3 = CRUST,
		BorderSizePixel = 0,
		Position = U(0.5, 0, 0.5, 0),
		Size = U(0.97299999, 0, 0.660000026, 0),
		Visible = false,
	})
	New("UIAspectRatioConstraint", { Parent = Key, AspectRatio = 2.25 })
	addBorder(Key)
	Corner(Key, 16)
	local KeyIcon = New("ImageLabel", {
		Name = "Icon",
		Parent = Key,
		AnchorPoint = V2(0.5, 0.5),
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		Position = U(0.131224886, 0, 0.5, 0),
		Size = U(0.234455898, 0, 0.668276012, 0),
		Image = options.Logo or assets.AndroidLogo,
	})
	New("UIAspectRatioConstraint", { Parent = KeyIcon })

	local KeyInner = New("Frame", {
		Name = "Container",
		Parent = Key,
		AnchorPoint = V2(0, 0.5),
		BackgroundColor3 = theme.EditorColor,
		Position = U(0.25999999, 0, 0.5, 0),
		Size = U(0.714599609, 0, 0.877767384, 0),
	})
	Corner(KeyInner, 20)

	local CheckKey = New("TextButton", {
		Name = "CheckKey",
		Parent = KeyInner,
		AnchorPoint = V2(1, 1),
		BackgroundColor3 = theme.ButtonColor,
		Position = U(1, -8, 1.00000012, -8),
		Size = U(0.421657592, 0, 0.245564342, 0),
		AutoButtonColor = false,
		Font = Enum.Font.SourceSans,
		Text = "",
		TextColor3 = theme.TextColor,
		TextSize = 14,
	})
	Corner(CheckKey, 16)
	local CheckKeyLabel = New("TextLabel", {
		Parent = CheckKey,
		AnchorPoint = V2(0.5, 0.5),
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		Position = U(0.5, 0, 0.5, 0),
		Size = U(1, 0, 0.699999988, 0),
		Font = Enum.Font.SourceSans,
		Text = self.Strings.CheckKey,
		TextColor3 = theme.TextColor,
		TextScaled = true,
		TextSize = 14,
		TextWrapped = true,
		RichText = true,
	})

	local GetKey = New("TextButton", {
		Name = "GetKey",
		Parent = KeyInner,
		AnchorPoint = V2(0, 1),
		BackgroundColor3 = MANTLE,
		Position = U(0, 8, 1, -8),
		Size = U(0.421657592, 0, 0.245564342, 0),
		AutoButtonColor = false,
		Font = Enum.Font.SourceSans,
		Text = " ",
		TextColor3 = theme.TextColor,
		TextSize = 14,
	})
	Corner(GetKey, 16)
	local GetKeyLabel = New("TextLabel", {
		Parent = GetKey,
		AnchorPoint = V2(0.5, 0.5),
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		Position = U(0.5, 0, 0.5, 0),
		Size = U(1, 0, 0.699999988, 0),
		Font = Enum.Font.SourceSans,
		Text = self.Strings.GetKey,
		TextColor3 = theme.TextColor,
		TextScaled = true,
		TextSize = 14,
		TextWrapped = true,
		RichText = true,
	})

	local KeyContainer = New("TextLabel", {
		Name = "KeyContainer",
		Parent = KeyInner,
		AnchorPoint = V2(0.5, 0),
		BackgroundColor3 = SURFACE,
		Position = U(0.5, 0, 0, 8),
		Size = U(1, -16, 0.754000008, -24),
		Font = Enum.Font.SourceSans,
		Text = "",
		TextColor3 = theme.TextColor,
		TextSize = 16,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		RichText = true,
	})
	Corner(KeyContainer, 16)
	local Instructions = New("TextLabel", {
		Name = "Instructions",
		Parent = KeyContainer,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		Position = U(0.0214072056, 0, 0.0587453023, 0),
		Size = U(0.952989757, 0, 0.555652499, 0),
		Font = Enum.Font.SourceSans,
		Text = self.Strings.KeyInstructions,
		TextColor3 = theme.TextColor,
		TextScaled = true,
		TextSize = 14,
		TextWrapped = true,
		RichText = true,
	})
	local KeyBox = New("TextBox", {
		Name = "KeyBox",
		Parent = KeyContainer,
		AnchorPoint = V2(0.5, 1),
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		Position = U(0.50000006, 0, 0.94668895, 0),
		Size = U(1.00000024, 0, 0.257028431, 0),
		Font = Enum.Font.SourceSans,
		PlaceholderText = self.Strings.KeyPlaceholder,
		Text = "",
		TextColor3 = theme.TextColor,
		TextScaled = true,
		TextSize = 14,
		TextWrapped = true,
	})

	local KeyMinimizeContainer = New("Frame", {
		Name = "minimizeContainer",
		Parent = Key,
		AnchorPoint = V2(1, 0), -- hidden until the key page is shown
		BackgroundColor3 = MANTLE,
		BorderSizePixel = 0,
		Position = U(1, 0, 0, 10),
		Size = U(0.175999999, 0, 0.207000002, 0),
		ZIndex = -1,
	})
	Corner(KeyMinimizeContainer, 20)
	local KeyMinimize = New("ImageButton", {
		Name = "1Minimize",
		Parent = KeyMinimizeContainer,
		AnchorPoint = V2(1, 0.5),
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = U(1, 0, 0.5, 0),
		Size = U(0.5, 0, 1, 0),
		ZIndex = 0,
		Image = assets.Minimize,
	})
	New("UIAspectRatioConstraint", { Parent = KeyMinimize })
	New("UIAspectRatioConstraint", { Parent = KeyMinimizeContainer, AspectRatio = 2 })

	-- Transition frame ----------------------------------------------------------
	local TransitionUI = New("Frame", {
		Name = "TransitionUI",
		Parent = Container,
		AnchorPoint = V2(0.5, 0.5),
		BackgroundColor3 = SURFACE,
		BorderColor3 = CRUST,
		BorderSizePixel = 0,
		Position = U(0.5, 0, 0.5, 0),
		Size = U(0.5, 0, 0.5, 0),
		Visible = false,
		ZIndex = 50,
	})
	addBorder(TransitionUI)
	Corner(TransitionUI, 16)

	-- Main UI -------------------------------------------------------------------
	local MainUI = New("ImageLabel", {
		Name = "MainUI",
		Parent = Container,
		AnchorPoint = V2(0.5, 0.5),
		BackgroundColor3 = SURFACE,
		BorderColor3 = CRUST,
		BorderSizePixel = 0,
		Position = U(0.5, 0, 0.5, 0),
		Size = U(0.808145046, 0, 0.79543215, 0),
	})
	if theme.Background ~= nil then
		if typeof(theme.Background) == "Color3" then
			MainUI.BackgroundColor3 = theme.Background
		else
			MainUI.Image = theme.Background
		end
	end
	addBorder(MainUI)
	Corner(MainUI, 16)

	local Tabs = New("Frame", {
		Name = "Tabs",
		Parent = MainUI,
		BackgroundColor3 = theme.TabsColor,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Size = U(0, 64, 1, 0),
	})
	local Scroller = New("ScrollingFrame", {
		Name = "Scroller",
		Parent = Tabs,
		Active = true,
		AnchorPoint = V2(0.5, 0.5),
		BackgroundColor3 = MANTLE,
		BackgroundTransparency = 0.999,
		BorderColor3 = MANTLE,
		Position = U(0.5, 0, 0.563784838, 0),
		Size = U(1, 0, 0.905351698, -32),
		BottomImage = SCROLL_IMG,
		ScrollBarThickness = 2,
		TopImage = SCROLL_IMG,
		VerticalScrollBarInset = Enum.ScrollBarInset.Always,
		LayoutOrder = 2,
	})
	local ScrollerLayout = New("UIListLayout", {
		Parent = Scroller,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UD(0, 8),
	})
	table.insert(self._connections, ScrollerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Scroller.CanvasSize = UDim2.fromOffset(0, ScrollerLayout.AbsoluteContentSize.Y)
	end))
	Corner(Tabs, 16)
	local TabsMinimize = New("ImageButton", {
		Name = "1Minimize",
		Parent = Tabs,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = U(1, 0, 1, 0),
		Image = assets.Minimize,
		LayoutOrder = 1,
	})
	New("UIAspectRatioConstraint", { Parent = TabsMinimize })
	New("UIListLayout", { Parent = Tabs, Padding = UD(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })

	-- Minimized toggle button -----------------------------------------------------
	local ToggleBtn = New("Frame", {
		Name = "ToggleBtn",
		Parent = Container,
		BackgroundColor3 = SURFACE,
		BorderColor3 = CRUST,
		BorderSizePixel = 0,
		Position = U(0, 16, 0, 16),
		Size = U(0.0719999969, 0, 0, 32),
		Visible = false,
	})
	New("UIAspectRatioConstraint", { Parent = ToggleBtn })
	addBorder(ToggleBtn)
	Corner(ToggleBtn, 16)
	local ToggleIcon = New("ImageLabel", {
		Name = "Icon",
		Parent = ToggleBtn,
		AnchorPoint = V2(0.5, 0.5),
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		Position = U(0.5, 0, 0.5, 0),
		Size = U(0.75, 0, 0.75, 0),
		Image = options.Logo or assets.AndroidLogo,
	})
	New("UIAspectRatioConstraint", { Parent = ToggleIcon })
	local ClickHandler = New("TextButton", {
		Name = "ClickHandler",
		Parent = ToggleBtn,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 0.99,
		Size = U(1, 0, 1, 0),
		ZIndex = 2,
		Font = Enum.Font.SourceSans,
		Text = " ",
		TextColor3 = BLACK,
		TextSize = 14,
	})

	self.UIFrames = {
		Loader = Loader,
		Key = Key,
		TransitionUI = TransitionUI,
		MainUI = MainUI,
		ToggleBtn = ToggleBtn,
	}
	self.Scroller = Scroller
	self.Refs = {
		Instructions = Instructions,
		KeyBox = KeyBox,
		CheckKey = CheckKey,
		GetKey = GetKey,
		CheckKeyLabel = CheckKeyLabel,
		GetKeyLabel = GetKeyLabel,
		LoaderIcon = LoaderIcon,
	}

	-- only the loader is visible at start
	for name, frame in pairs(self.UIFrames) do
		frame.Visible = (name == "Loader")
	end

	-- group state ("tabimages" hidden by default, like the original)
	self._groupStates["tabimages"] = options.TabImages or false
	self._groupStates["!tabimages"] = not (options.TabImages or false)

	-- events
	table.insert(self._connections, ClickHandler.MouseButton1Click:Connect(function()
		task.spawn(function()
			self:Unminimize()
		end)
	end))
	makeDraggable(ToggleBtn, ClickHandler, self._connections)
	local function onMinimize()
		task.spawn(function()
			self:Minimize()
		end)
	end
	table.insert(self._connections, TabsMinimize.MouseButton1Click:Connect(onMinimize))
	table.insert(self._connections, KeyMinimize.MouseButton1Click:Connect(onMinimize))
	table.insert(self._connections, GetKey.MouseButton1Click:Connect(function()
		if self._keyCallbacks.OnGetKey then
			self._keyCallbacks.OnGetKey(self)
		end
	end))
	table.insert(self._connections, CheckKey.MouseButton1Click:Connect(function()
		task.spawn(function()
			local cb = self._keyCallbacks.OnCheckKey
			local ok = true
			if cb then
				ok = cb(KeyBox.Text, self)
			end
			if ok then
				if self._keyCallbacks.OnSuccess then
					self._keyCallbacks.OnSuccess(self)
				else
					self:ShowMain()
				end
			else
				Instructions.Text = self.Strings.KeyInvalid
			end
		end)
	end))

	-- re-render rich text labels every 5 seconds (same as the original Text component)
	task.spawn(function()
		while not self._destroyed do
			task.wait(5)
			if self._destroyed then
				break
			end
			self:_rerenderLabels()
		end
	end)

	-- intro animation
	task.spawn(function()
		local fast = self.Config.FastAnimations
		TweenService:Create(
			LoaderIcon,
			TweenInfo.new(fast and 0.3 or 1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, 0.2),
			{ ImageTransparency = 1 }
		):Play()
		local endSize = Loader.Size
		Loader.Size = U(0, 0, 0, 0)
		gui.Parent = options.Parent or getGuiParent()
		self:SetSmallUI(self.Config.SmallUI, true)
		local t = TweenService:Create(
			Loader,
			TweenInfo.new(fast and 0.3 or 1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0),
			{ Size = endSize }
		)
		t:Play()
		t.Completed:Wait()
		TransitionUI.Size = UDim2.fromOffset(Loader.AbsoluteSize.X, Loader.AbsoluteSize.Y)
		self._loaded = true
		self._loadedEvent:Fire()
	end)

	return self
end

function Android:WaitForLoaded()
	if not self._loaded then
		self.Loaded:Wait()
	end
end

function Android:_rerenderLabels()
	for _, fn in ipairs(self._labels) do
		fn()
	end
end

--- Feature groups (same idea as the original UI feature handler) ---------------
function Android:AddToGroup(name, item)
	assert(item and item.SetVisible, "not a ui element")
	self._groups[name] = self._groups[name] or {}
	table.insert(self._groups[name], item)
	local state = self._groupStates[name]
	if state ~= nil then
		item:SetVisible(state)
	end
	return item
end

function Android:SetGroupState(name, visible)
	self._groupStates[name] = visible
	self._groupStates["!" .. name] = not visible
	for _, item in ipairs(self._groups[name] or {}) do
		item:SetVisible(visible)
	end
	for _, item in ipairs(self._groups["!" .. name] or {}) do
		item:SetVisible(not visible)
	end
end

function Android:SetTabImagesVisible(state)
	self:SetGroupState("tabimages", state)
end

--- Settings --------------------------------------------------------------------
function Android:SetSmallUI(enabled, instant)
	self.Config.SmallUI = enabled and true or false
	local h = self.Config.ScreenHeight
	local target = enabled and U(0.7, 0, h, 0) or U(1, 0, h, 0)
	if instant then
		self.Container.Size = target
	else
		local t = TweenService:Create(
			self.Container,
			TweenInfo.new(self.Config.FastAnimations and 0.2 or 1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0),
			{ Size = target }
		)
		t:Play()
		t.Completed:Wait()
	end
	self:_rerenderLabels()
end

function Android:SetCenteredMinimize(enabled)
	self.Config.CenteredMinimize = enabled and true or false
	local t = self.UIFrames.ToggleBtn
	if enabled then
		t.Position = U(0.5, 0, 0, 0)
		t.AnchorPoint = V2(0.5, 0)
	else
		t.Position = U(0, 16, 0, 16)
		t.AnchorPoint = V2(0, 0)
	end
end

function Android:SetFastAnimations(state)
	self.Config.FastAnimations = state and true or false
end

function Android:SetNoAnimations(state)
	self.Config.NoAnimations = state and true or false
	self:SetGroupState("noanim", state and true or false)
end

--- Transitions -------------------------------------------------------------------
function Android:_transitionToSize(sizeTo, midPoint, pos, ap)
	local timing = self.Config.FastAnimations and 0.2 or 1
	if self.Config.NoAnimations then
		timing = 0
	end
	local ti = TweenInfo.new(timing, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0)
	local tui = self.UIFrames.TransitionUI
	tui.Visible = true
	tui.BackgroundTransparency = 1
	local t = TweenService:Create(tui, ti, { BackgroundTransparency = 0 })
	local t2 = TweenService:Create(tui, ti, {
		Size = sizeTo,
		Position = pos or tui.Position,
		AnchorPoint = ap or V2(0.5, 0.5),
	})
	local t3 = TweenService:Create(tui, ti, { BackgroundTransparency = 1 })
	t:Play()
	t.Completed:Wait()
	if midPoint then
		midPoint()
	end
	t2:Play()
	t2.Completed:Wait()
	return function()
		t3:Play()
		t3.Completed:Wait()
		tui.Visible = false
	end
end

function Android:_transitionToFrame(newName)
	local newFrame = self.UIFrames[newName]
	local complete = self:_transitionToSize(
		UDim2.fromOffset(newFrame.AbsoluteSize.X, newFrame.AbsoluteSize.Y),
		function()
			for name, frame in pairs(self.UIFrames) do
				frame.Visible = (name == "TransitionUI")
			end
		end,
		newFrame.Position,
		newFrame.AnchorPoint
	)
	for name, frame in pairs(self.UIFrames) do
		frame.Visible = (name == newName) or (name == "TransitionUI")
	end
	complete()
end

function Android:_prepareTransition(oldName)
	local oldFrame = self.UIFrames[oldName]
	local tui = self.UIFrames.TransitionUI
	tui.Size = UDim2.fromOffset(oldFrame.AbsoluteSize.X, oldFrame.AbsoluteSize.Y)
	tui.Position = oldFrame.Position
	tui.AnchorPoint = oldFrame.AnchorPoint
end

function Android:_keyButtonMove(anchor)
	local item = self.UIFrames.Key.minimizeContainer
	if self._unminimizeTarget == "Key" and not self.Config.NoAnimations then
		local ts = TweenService:Create(
			item,
			TweenInfo.new(self.Config.FastAnimations and 0.2 or 1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
			{ AnchorPoint = anchor }
		)
		ts:Play()
		ts.Completed:Wait()
	else
		item.AnchorPoint = anchor
	end
end

function Android:SetUnminimizeTarget(frameName)
	self._unminimizeTarget = frameName
end

function Android:Minimize()
	if self._busy then
		return
	end
	self._busy = true
	self:_keyButtonMove(V2(1, 0))
	self:_prepareTransition(self._unminimizeTarget)
	self:_transitionToFrame("ToggleBtn")
	self._busy = false
end

function Android:Unminimize()
	if self._busy then
		return
	end
	self._busy = true
	self:_prepareTransition("ToggleBtn")
	self:_transitionToFrame(self._unminimizeTarget)
	self:_keyButtonMove(V2(0.5, 0))
	self._busy = false
end

--[[
    Window:ShowKeyPage({
        Instructions = "text",            -- optional rich text
        OnGetKey   = function(window) end,
        OnCheckKey = function(key, window) return true | false end,
        OnSuccess  = function(window) end -- default: window:ShowMain()
    })
]]
function Android:ShowKeyPage(opts)
	opts = opts or {}
	self:WaitForLoaded()
	self._keyCallbacks = {
		OnGetKey = opts.OnGetKey,
		OnCheckKey = opts.OnCheckKey,
		OnSuccess = opts.OnSuccess,
	}
	if opts.Instructions then
		self.Refs.Instructions.Text = opts.Instructions
	end
	self:SetUnminimizeTarget("Key")
	self:_prepareTransition(self._current)
	self:_transitionToFrame("Key")
	self._current = "Key"
	self:_keyButtonMove(V2(0.5, 0))
end

function Android:SetKeyInstructions(text)
	self.Refs.Instructions.Text = text
end

function Android:ShowMain()
	self:WaitForLoaded()
	if self._current == "Key" then
		self:_keyButtonMove(V2(1, 0))
	end
	self:_prepareTransition(self._current)
	self:SetUnminimizeTarget("MainUI")
	self:_transitionToFrame("MainUI")
	self._current = "MainUI"
end

function Android:Destroy()
	self._destroyed = true
	for _, c in ipairs(self._connections) do
		pcall(function()
			c:Disconnect()
		end)
	end
	self.Gui:Destroy()
end

--------------------------------------------------------------------------------
-- Android tabs and components
--------------------------------------------------------------------------------

--[[
    Window:CreateTab({ Icon = "rbxassetid://...", Banner = "rbxassetid://...", Order = number })
    Banner is shown only when Window:SetTabImagesVisible(true).
]]
function Android:CreateTab(options)
	options = options or {}
	local theme = self.Theme
	local tab = setmetatable({ Window = self, _order = 0 }, Tab)

	local content = New("ScrollingFrame", {
		Name = "Content",
		Parent = self.UIFrames.MainUI,
		Active = true,
		AnchorPoint = V2(1, 0.5),
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 0.999,
		BorderSizePixel = 0,
		Position = U(0.995839119, -8, 0.5, 0),
		Size = U(0.995839119, -80, 1, -16),
		BottomImage = SCROLL_IMG,
		ScrollBarThickness = 2,
		TopImage = SCROLL_IMG,
		VerticalScrollBarInset = Enum.ScrollBarInset.Always,
		Visible = (#self._tabs == 0),
	})
	local layout = New("UIListLayout", {
		Parent = content,
		Padding = UD(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	table.insert(self._connections, layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		content.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y)
	end))
	tab.Content = content
	table.insert(self._tabs, tab)

	local btn = New("ImageButton", {
		Name = "Btn",
		Parent = self.Scroller,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		Size = U(1, 0, 1, 0),
		Image = resolveIcon(options.Icon or Library.Assets.AndroidLogo),
		LayoutOrder = options.Order or #self._tabs,
	})
	New("UIAspectRatioConstraint", { Parent = btn })
	Corner(btn, 16)
	table.insert(self._connections, btn.MouseButton1Click:Connect(function()
		tab:Focus()
	end))
	tab.Button = btn

	if options.Banner then
		self:AddToGroup("tabimages", tab:CreateImage({ Image = options.Banner }))
	end
	return tab
end

function Tab:_next()
	self._order = self._order + 1
	return self._order
end

function Tab:Focus()
	for _, t in ipairs(self.Window._tabs) do
		t.Content.Visible = (t == self)
	end
end

function Tab:CreateSpacer(height)
	local frame = New("Frame", {
		Name = "Spacer",
		Parent = self.Content,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 0.999,
		Position = U(0, 0, 0.204823568, 0),
		Size = U(0.995999992, 0, 0, height or 5),
		LayoutOrder = self:_next(),
	})
	local api = {}
	function api:SetHeight(h)
		frame.Size = U(frame.Size.X.Scale, frame.Size.X.Offset, 0, h)
		return self
	end
	return wrap(frame, api)
end

function Tab:CreateText(text)
	local theme = self.Window.Theme
	local window = self.Window
	local frame = New("Frame", {
		Name = "Text",
		Parent = self.Content,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		Size = U(0.995999992, 0, 0, 30),
		LayoutOrder = self:_next(),
	})
	local label = NewA("TextLabel", {
		Name = "Label",
		Parent = frame,
		AnchorPoint = V2(0, 0.5),
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		Position = U(0.00656450912, 0, 0.5, 0),
		Size = U(0.96189183, 0, 1, -4),
		Font = Enum.Font.SourceSans,
		TextColor3 = theme.TextColor,
		TextSize = 20,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	local baseline = frame.Size.X
	local function updateSize()
		local _, nl1 = string.gsub(label.Text, "\n", "")
		local _, nl2 = string.gsub(label.Text, "<br/>", "")
		local y = math.max(label.TextBounds.Y, 12 * (nl1 + nl2 + 1))
		frame.Size = U(baseline.Scale, baseline.Offset, 0, y)
	end
	local api = {}
	function api:UpdateText(t)
		label.Text = t
		updateSize()
		return self
	end
	function api:SetRichTextEnabled(v)
		label.RichText = v
		updateSize()
		return self
	end
	api.Label = label
	api:UpdateText(text or "no text")
	table.insert(window._labels, updateSize)
	table.insert(window._connections, label:GetPropertyChangedSignal("TextBounds"):Connect(updateSize))
	return wrap(frame, api)
end

function Tab:CreateImage(opts)
	opts = opts or {}
	if type(opts) == "string" then
		opts = { Image = opts }
	end
	local frame = New("Frame", {
		Name = "Image",
		Parent = self.Content,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		Position = U(-3.69178785e-08, 0, 0.218284875, 0),
		Size = U(0.994000018, 0, 0, 128),
		LayoutOrder = self:_next(),
	})
	local img = New("ImageLabel", {
		Parent = frame,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		Size = U(1, 0, 1, 0),
		Image = Library.Assets.ImageDefault,
		ScaleType = Enum.ScaleType.Crop,
	})
	Corner(img)
	local ratio = Instance.new("UIAspectRatioConstraint")
	local api = {}
	function api:SetImage(id)
		img.Image = resolveIcon(id) or Library.Assets.ImagePlaceholder
		return self
	end
	function api:SetHeight(px)
		frame.Size = U(frame.Size.X.Scale, frame.Size.X.Offset, 0, px)
		return self
	end
	function api:SetAspectRatio(r)
		if r == 0 then
			ratio.Parent = nil
		else
			ratio.Parent = frame
			ratio.AspectRatio = r
		end
		return self
	end
	api:SetImage(opts.Image or Library.Assets.ImagePlaceholder)
	api:SetHeight(opts.Height or 128)
	api:SetAspectRatio(opts.AspectRatio or 8)
	return wrap(frame, api)
end

--[[
    Tab:CreateButton({
        Text = "Run", SideText = "label on the left (optional)",
        Style = "Active" | "Passive", Callback = function() end
    })
]]
function Tab:CreateButton(opts)
	opts = opts or {}
	local theme = self.Window.Theme
	local frame = New("Frame", {
		Name = "Button",
		Parent = self.Content,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		Position = U(-3.69178785e-08, 0, 0, 0),
		Size = U(0.994000018, 0, 0, 30),
		LayoutOrder = self:_next(),
	})

	-- WithText layout (label on the left, small button on the right)
	local withText = New("Frame", {
		Name = "WithText",
		Parent = frame,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		Size = U(1, 0, 1, 0),
		Visible = false,
	})
	local function sideButton(name, color, visible)
		local b = NewA("TextButton", {
			Name = name,
			Parent = withText,
			AnchorPoint = V2(1, 0.5),
			BackgroundColor3 = color,
			Position = U(0.999999881, -8, 0.5, 0),
			Size = U(1, -16, 1, -4),
			Visible = visible,
			AutoButtonColor = false,
			Font = Enum.Font.SourceSans,
			TextColor3 = theme.TextColor,
			TextScaled = true,
			TextSize = 14,
			TextWrapped = true,
		})
		New("UIAspectRatioConstraint", { Parent = b, AspectRatio = 3, DominantAxis = Enum.DominantAxis.Height })
		New("UITextSizeConstraint", { Parent = b, MaxTextSize = 50 })
		Corner(b, 16)
		return b
	end
	local wActive = sideButton("ActiveButton", theme.ButtonColor, false)
	local wLabel = NewA("TextLabel", {
		Name = "Label",
		Parent = withText,
		AnchorPoint = V2(0, 0.5),
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		Position = U(0, 0, 0.5, 0),
		Size = U(0.892810702, 0, 1, -4),
		Font = Enum.Font.SourceSans,
		TextColor3 = theme.TextColor,
		TextScaled = true,
		TextSize = 14,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	local wPassive = sideButton("PassiveButton", MANTLE, true)

	-- NoText layout (full width button)
	local noText = New("Frame", {
		Name = "NoText",
		Parent = frame,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		Size = U(1, 0, 1, 0),
	})
	local function fullButton(name, color, pos, size, visible)
		local b = NewA("TextButton", {
			Name = name,
			Parent = noText,
			AnchorPoint = V2(1, 0.5),
			BackgroundColor3 = color,
			Position = pos,
			Size = size,
			Visible = visible,
			AutoButtonColor = false,
			Font = Enum.Font.SourceSans,
			Text = " ",
			TextColor3 = theme.TextColor,
			TextScaled = true,
			TextSize = 14,
			TextWrapped = true,
		})
		New("UITextSizeConstraint", { Parent = b, MaxTextSize = 50 })
		Corner(b, 16)
		NewA("TextLabel", {
			Parent = b,
			AnchorPoint = V2(0.5, 0.5),
			BackgroundColor3 = WHITE,
			BackgroundTransparency = 1,
			Position = U(0.5, 0, 0.5, 0),
			Size = U(1, -16, 1, -6),
			Font = Enum.Font.SourceSans,
			TextColor3 = theme.TextColor,
			TextScaled = true,
			TextSize = 14,
			TextWrapped = true,
		})
		return b
	end
	local nActive = fullButton("ActiveButton", theme.ButtonColor, U(1.00895214, -8, 0.5, 0), U(1.01790428, -16, 1, -4), true)
	local nPassive = fullButton("PassiveButton", MANTLE, U(0.999999881, -8, 0.5, 0), U(1, -16, 1, -4), false)

	local clicked = Instance.new("BindableEvent")
	for _, o in ipairs(frame:GetDescendants()) do
		if o:IsA("TextButton") then
			o.MouseButton1Click:Connect(function(...)
				clicked:Fire(...)
			end)
		end
	end

	local api = { Clicked = clicked.Event }
	function api:SetText(text)
		for _, o in ipairs(frame:GetDescendants()) do
			if o:IsA("TextButton") then
				local target = o
				if o:FindFirstChildOfClass("TextLabel") then
					target = o:FindFirstChildOfClass("TextLabel")
				end
				target.Text = text
			end
		end
		return self
	end
	function api:Update(style, text, sideText, callback)
		style = string.lower(style or "passive")
		if type(sideText) == "string" then
			withText.Visible = true
			noText.Visible = false
			wActive.Visible = (style == "active")
			wPassive.Visible = not wActive.Visible
			wLabel.Text = sideText
		else
			withText.Visible = false
			noText.Visible = true
			nActive.Visible = (style == "active")
			nPassive.Visible = not nActive.Visible
		end
		self:SetText(text or "")
		if callback then
			self.Clicked:Connect(callback)
		end
		return self
	end
	api:Update(opts.Style or "Passive", opts.Text or "Button", opts.SideText, opts.Callback)
	return wrap(frame, api)
end

--[[
    Tab:CreateCheckbox({ Text = "Option", Default = false, Callback = function(value) end })
]]
function Tab:CreateCheckbox(opts)
	opts = opts or {}
	local theme = self.Window.Theme
	local frame = New("Frame", {
		Name = "Checkbox",
		Parent = self.Content,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		Size = U(0.995999992, 0, 0, 30),
		LayoutOrder = self:_next(),
	})
	local function box(name, color, visible)
		local b = NewA("TextButton", {
			Name = name,
			Parent = frame,
			AnchorPoint = V2(1, 0.5),
			BackgroundColor3 = color,
			Position = U(0.999999881, -8, 0.5, 0),
			Size = U(1, -16, 1, -4),
			Visible = visible,
			AutoButtonColor = false,
			Font = Enum.Font.SourceSans,
			Text = " ",
			TextColor3 = theme.TextColor,
			TextScaled = true,
			TextSize = 14,
			TextWrapped = true,
		})
		New("UIAspectRatioConstraint", { Parent = b, DominantAxis = Enum.DominantAxis.Height })
		New("UITextSizeConstraint", { Parent = b, MaxTextSize = 50 })
		Corner(b, 16)
		return b
	end
	local checked = box("Checked", theme.ButtonColor, true)
	local unchecked = box("Unchecked", MANTLE, false)
	local label = NewA("TextLabel", {
		Name = "Label",
		Parent = frame,
		AnchorPoint = V2(0, 0.5),
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		Position = U(0.0121801738, 0, 0.5, 0),
		Size = U(0.587819874, 0, 1, -4),
		Font = Enum.Font.SourceSans,
		TextColor3 = theme.TextColor,
		TextScaled = true,
		TextSize = 14,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	local changed = Instance.new("BindableEvent")
	local api = { Status = opts.Default or false, Changed = changed.Event }
	function api:RawUpdate()
		checked.Visible = self.Status
		unchecked.Visible = not self.Status
		return self
	end
	function api:Set(value)
		if self.Status ~= value then
			self.Status = value
			changed:Fire(value)
		end
		return self:RawUpdate()
	end
	function api:Toggle()
		return self:Set(not self.Status)
	end
	function api:Get()
		return self.Status
	end
	function api:SetText(t)
		label.Text = t
		return self
	end
	api:SetText(opts.Text or "Checkbox")
	api:RawUpdate()
	checked.MouseButton1Click:Connect(function()
		api:Toggle()
	end)
	unchecked.MouseButton1Click:Connect(function()
		api:Toggle()
	end)
	if opts.Callback then
		api.Changed:Connect(opts.Callback)
	end
	return wrap(frame, api)
end

local function textboxApi(box)
	local api = {}
	function api:SetPlaceholder(p)
		box.PlaceholderText = p
		return self
	end
	function api:GetValue()
		return box.Text
	end
	function api:SetValue(v)
		if typeof(v) ~= "string" then
			error("Expected type string for argument in position 1, got " .. typeof(v))
		end
		box.Text = v
		return self
	end
	api.Changed = box:GetPropertyChangedSignal("Text")
	api.TextBox = box
	return api
end

--[[
    Tab:CreateTextbox({ Placeholder = "...", Callback = function(text) end })  -- on focus lost
]]
function Tab:CreateTextbox(opts)
	opts = opts or {}
	local theme = self.Window.Theme
	local frame = New("Frame", {
		Name = "Textbox",
		Parent = self.Content,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		Size = U(0.995999992, 0, 0, 30),
		LayoutOrder = self:_next(),
	})
	local box = New("TextBox", {
		Parent = frame,
		AnchorPoint = V2(1, 0.5),
		BackgroundColor3 = theme.EditorColor,
		Position = U(0.997991979, 0, 0.5, 0),
		Size = U(1.01599658, -16, 1.06666672, 0),
		Font = Enum.Font.SourceSans,
		PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
		PlaceholderText = opts.Placeholder or "PlaceholderPlaceholder",
		Text = opts.Text or "",
		TextColor3 = theme.TextColor,
		TextSize = 14,
	})
	Corner(box, 16)
	if opts.Callback then
		box.FocusLost:Connect(function()
			opts.Callback(box.Text)
		end)
	end
	return wrap(frame, textboxApi(box))
end

function Tab:CreateTextBoxMultiLine(opts)
	opts = opts or {}
	local theme = self.Window.Theme
	local frame = New("Frame", {
		Name = "TextBoxMultiLine",
		Parent = self.Content,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		Position = U(0, 0, 0.0424371213, 0),
		Size = U(0.990999997, 0, 0, opts.Height or 193),
		LayoutOrder = self:_next(),
	})
	local box = New("TextBox", {
		Parent = frame,
		AnchorPoint = V2(1, 0.5),
		BackgroundColor3 = theme.EditorColor,
		Position = U(1.0030272, 0, 0.499999851, 0),
		Size = U(1.02098584, -16, 1, 0),
		ClearTextOnFocus = false,
		Font = Enum.Font.SourceSans,
		MultiLine = true,
		PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
		PlaceholderText = opts.Placeholder or "PlaceholderPlaceholder",
		Text = opts.Text or "",
		TextColor3 = theme.TextColor,
		TextSize = 14,
	})
	Corner(box, 16)
	if opts.Callback then
		box.FocusLost:Connect(function()
			opts.Callback(box.Text)
		end)
	end
	return wrap(frame, textboxApi(box))
end

--[[
    Tab:CreateExecBox({
        Placeholder = "print('Hello World!')",
        OnExecute   = function(text) end,
        OnClipboard = function() end,
    })
    Height follows the window: MainUI height - 72 (same as the original).
]]
function Tab:CreateExecBox(opts)
	opts = opts or {}
	local window = self.Window
	local theme = window.Theme
	local strings = window.Strings
	local frame = New("Frame", {
		Name = "ExecBox",
		Parent = self.Content,
		BackgroundColor3 = theme.EditorColor,
		Position = U(-0.0133180944, 0, 0.0632952526, 0),
		Size = U(0.997780323, 0, 0, 512),
		LayoutOrder = self:_next(),
	})
	if theme.Background ~= nil then
		if typeof(theme.Background) == "Color3" then
			frame.BackgroundTransparency = 0.3
		else
			frame.BackgroundTransparency = 0.1
		end
	end
	if theme.EditorTransparent then
		frame.BackgroundTransparency = 1
	end
	local input = New("TextBox", {
		Parent = frame,
		AnchorPoint = V2(0.5, 0),
		BackgroundColor3 = theme.EditorColor,
		BackgroundTransparency = 0.999,
		BorderSizePixel = 0,
		Position = U(0.501114726, 0, 0.0430178083, 0),
		Size = U(0.962097406, 0, 0.961592555, -48),
		ClearTextOnFocus = false,
		Font = Enum.Font.RobotoMono,
		MultiLine = true,
		PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
		PlaceholderText = opts.Placeholder or "print('Hello World!')",
		Text = "",
		TextColor3 = theme.TextColor,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
	})
	local function bigButton(name, anchor, pos, text)
		local b = NewA("TextButton", {
			Name = name,
			Parent = frame,
			AnchorPoint = anchor,
			BackgroundColor3 = theme.ButtonColor,
			Position = pos,
			Size = U(0.5, -8, 0, 35),
			AutoButtonColor = false,
			Font = Enum.Font.SourceSans,
			Text = " ",
			TextColor3 = theme.TextColor,
			TextScaled = true,
			TextSize = 14,
			TextWrapped = true,
		})
		New("UITextSizeConstraint", { Parent = b, MaxTextSize = 50 })
		Corner(b, 16)
		NewA("TextLabel", {
			Parent = b,
			AnchorPoint = V2(0.5, 0.5),
			BackgroundColor3 = WHITE,
			BackgroundTransparency = 1,
			Position = U(0.5, 0, 0.5, 0),
			Size = U(1, -16, 1, -6),
			Font = Enum.Font.SourceSans,
			Text = text,
			TextColor3 = theme.TextColor,
			TextScaled = true,
			TextSize = 14,
			TextWrapped = true,
		})
		return b
	end
	local execBtn = bigButton("box", V2(0, 1), U(0, 4, 1, -4), opts.ExecuteText or strings.ExecuteFromTextbox)
	local clipBtn = bigButton("clippy", V2(1, 1), U(1, -4, 1, -4), opts.ClipboardText or strings.ExecuteFromClipboard)
	Corner(frame, 16)

	execBtn.MouseButton1Click:Connect(function()
		if opts.OnExecute then
			opts.OnExecute(input.Text)
		end
	end)
	clipBtn.MouseButton1Click:Connect(function()
		if opts.OnClipboard then
			opts.OnClipboard()
		end
	end)

	local mainUI = window.UIFrames.MainUI
	local function resize()
		local h = math.max(mainUI.AbsoluteSize.Y - 72, 100)
		frame.Size = U(frame.Size.X.Scale, frame.Size.X.Offset, 0, h)
	end
	resize()
	table.insert(window._connections, mainUI:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize))

	local api = { TextBox = input }
	function api:GetText()
		return input.Text
	end
	function api:SetText(t)
		input.Text = t
		return self
	end
	return wrap(frame, api)
end

--[[
    Tab:CreateSearch({ Placeholder = "...", ButtonText = "Submit", Callback = function(text) end })
]]
function Tab:CreateSearch(opts)
	opts = opts or {}
	if type(opts) == "function" then
		opts = { Callback = opts }
	end
	local window = self.Window
	local theme = window.Theme
	local frame = New("Frame", {
		Name = "Search",
		Parent = self.Content,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		Position = U(3.3869668e-08, 0, 0.364753366, 0),
		Size = U(0.991793573, 0, 0, 30),
		LayoutOrder = self:_next(),
	})
	local box = New("TextBox", {
		Parent = frame,
		AnchorPoint = V2(1, 0.5),
		BackgroundColor3 = theme.EditorColor,
		Position = U(0.768081725, 0, 0.5, 0),
		Size = U(0.786086261, -16, 1.06666672, 0),
		Font = Enum.Font.SourceSans,
		PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
		PlaceholderText = opts.Placeholder or window.Strings.SearchPlaceholder,
		Text = "",
		TextColor3 = theme.TextColor,
		TextSize = 14,
	})
	Corner(box, 16)
	local button = NewA("TextButton", {
		Name = "ActiveButton",
		Parent = frame,
		AnchorPoint = V2(1, 0.5),
		BackgroundColor3 = theme.ButtonColor,
		Position = U(1.00895214, -8, 0.5, 0),
		Size = U(0.242938325, -16, 1.20000005, -4),
		AutoButtonColor = false,
		Font = Enum.Font.SourceSans,
		Text = " ",
		TextColor3 = theme.TextColor,
		TextScaled = true,
		TextSize = 14,
		TextWrapped = true,
	})
	New("UITextSizeConstraint", { Parent = button, MaxTextSize = 50 })
	Corner(button, 16)
	NewA("TextLabel", {
		Parent = button,
		AnchorPoint = V2(0.5, 0.5),
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		Position = U(0.5, 0, 0.5, 0),
		Size = U(1, -16, 1, -6),
		Font = Enum.Font.SourceSans,
		Text = opts.ButtonText or window.Strings.Submit,
		TextColor3 = theme.TextColor,
		TextScaled = true,
		TextSize = 14,
		TextWrapped = true,
	})
	button.MouseButton1Click:Connect(function()
		if opts.Callback then
			opts.Callback(box.Text)
		end
	end)
	local api = { TextBox = box }
	function api:GetText()
		return box.Text
	end
	return wrap(frame, api)
end

--------------------------------------------------------------------------------
-- CORAL UI  (left bar with sections)
--------------------------------------------------------------------------------

local Coral = {}
Coral.__index = Coral

local Section = {}
Section.__index = Section

local BAR = Color3.fromRGB(45, 47, 51)
local ITEM = Color3.fromRGB(70, 70, 72)
local PURPLE = Color3.fromRGB(103, 61, 234)
local DARK = Color3.fromRGB(25, 25, 25)
local BTN_BG = Color3.fromRGB(69, 72, 79)
local INPUT_TEXT = Color3.fromRGB(216, 216, 216)

--[[
    Coral.new({
        Name = "CoralUI", Parent = nil, Logo = "rbxassetid://138900967749432",
        FastAnimations = false, NoAnimations = false, CenteredMinimize = false,
    })
]]
function Coral.new(options)
	options = options or {}
	local self = setmetatable({}, Coral)
	self.Config = {
		FastAnimations = options.FastAnimations or false,
		NoAnimations = options.NoAnimations or false,
		CenteredMinimize = options.CenteredMinimize or false,
	}
	self.Sections = {}
	self._connections = {}
	self._unlocked = true
	local logoImage = options.Logo or Library.Assets.Logo
	self.LogoImage = logoImage

	local gui = New("ScreenGui", {
		Name = options.Name or "CoralUI",
		DisplayOrder = 1999999999,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	pcall(function()
		gui.ScreenInsets = Enum.ScreenInsets.None
	end)
	gui.Parent = options.Parent or getGuiParent()
	self.Gui = gui

	local LeftBarFrame = New("Frame", {
		Name = "LeftBarFrame",
		Parent = gui,
		BackgroundColor3 = BAR,
		BorderColor3 = BAR,
		BorderSizePixel = 0,
		Size = U(0.1, 100, 1, 0),
		Position = U(-0.1, -100, 0, 0),
	})
	self.LeftBarFrame = LeftBarFrame

	local Logo = New("ImageButton", {
		Name = "Logo",
		Parent = LeftBarFrame,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = U(0.25, 0, 0, 10),
		Size = U(0.5, 0, 0, 50),
		Image = logoImage,
		ScaleType = Enum.ScaleType.Fit,
		AutoButtonColor = false,
	})
	self.Logo = Logo

	local ShowUI = New("Frame", {
		Parent = gui,
		BackgroundColor3 = BAR,
		BorderColor3 = BAR,
		BorderSizePixel = 0,
		Position = U(-0.1, -100, 0, 0),
		Size = U(0, 30, 0, 30),
		Visible = false,
	})
	New("UICorner", { Parent = ShowUI, CornerRadius = UD(1, 0) })
	local ShowUILogo = New("ImageButton", {
		Name = "Logo",
		Parent = ShowUI,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = U(0, 0, 0.166666672, 1),
		Size = U(1, 0, 0.6, 0),
		Image = logoImage,
		ScaleType = Enum.ScaleType.Fit,
		AutoButtonColor = false,
	})
	self.ShowUI = ShowUI

	table.insert(self._connections, Logo.MouseButton1Down:Connect(function()
		task.spawn(function()
			self:Hide()
		end)
	end))
	table.insert(self._connections, ShowUILogo.MouseButton1Down:Connect(function()
		task.spawn(function()
			self:Show()
		end)
	end))

	-- main selector (the list of section buttons)
	self.MainSelector = self:_makeSelector(true)

	self:_tween(LeftBarFrame, { Position = U(0, 0, 0, 0) }, 0.5, Enum.EasingStyle.Linear)
	return self
end

function Coral:_tween(obj, data, length, style)
	local time = (type(length) == "number") and length or 0.3
	if self.Config.NoAnimations then
		time = 0
	elseif self.Config.FastAnimations then
		if time > 0.4 then
			time = time - 0.4
		else
			time = time - 0.2
		end
	end
	time = math.max(time, 0)
	TweenService:Create(
		obj,
		TweenInfo.new(time, style or Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
		data
	):Play()
	return time + 0.2
end

function Coral:_makeSelector(visible)
	local selector = New("ScrollingFrame", {
		Name = "Selector",
		Parent = self.LeftBarFrame,
		Active = true,
		BackgroundColor3 = PURPLE,
		BackgroundTransparency = 1,
		BorderColor3 = BLACK,
		BorderSizePixel = 0,
		Position = U(0, 2, 0, 80),
		Size = U(0.98, 0, 1, -80),
		CanvasSize = U(0, 0, 0, 0),
		ScrollBarThickness = 2,
		Visible = visible,
		ElasticBehavior = Enum.ElasticBehavior.Never,
		ScrollingDirection = Enum.ScrollingDirection.Y,
	})
	local layout = New("UIListLayout", {
		Parent = selector,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UD(0, 5),
	})
	selector.CanvasSize = U(0, 0, 0, layout.AbsoluteContentSize.Y)
	table.insert(self._connections, layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		selector.CanvasSize = U(0, 0, 0, layout.AbsoluteContentSize.Y)
	end))
	return selector, layout
end

-- Frame + TextButton row used for every button in the bar
local function makeButton(parent, name, callback, opts)
	opts = opts or {}
	local frame = New("Frame", {
		Name = name,
		Parent = parent,
		BackgroundColor3 = opts.Color or (opts.Purple and PURPLE or ITEM),
		BorderSizePixel = 0,
		Size = U(0.9, 0, 0, 25),
	})
	New("UICorner", { Parent = frame })
	local button = New("TextButton", {
		Name = "TextButton",
		Parent = frame,
		BackgroundColor3 = BTN_BG,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = U(1, 0, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = name,
		TextColor3 = opts.TextColor or WHITE,
		TextSize = 12,
		TextStrokeColor3 = opts.TextStrokeColor or WHITE,
	})
	button.MouseButton1Down:Connect(function()
		if callback then
			callback(frame)
		end
	end)
	return frame, button
end

function Coral:_resetSections()
	for _, sec in ipairs(self.Sections) do
		sec.Frame.BackgroundColor3 = ITEM
		sec.TabItem.Position = U(0.1, 100, -1, 0)
		sec.Selector.Visible = false
		sec.TabItem.Visible = false
	end
end

function Coral:_switchTab(frame)
	if frame.BackgroundColor3 == ITEM then
		self.MainSelector.Visible = false
		for _, sec in ipairs(self.Sections) do
			if sec.Frame ~= frame then
				sec.Frame.BackgroundColor3 = ITEM
				sec.Selector.Visible = false
				sec.TabItem.Visible = false
				sec.TabItem.Position = U(0.1, 100, -1, 0)
			else
				sec.Frame.BackgroundColor3 = PURPLE
				sec.Selector.Visible = true
				sec.TabItem.Visible = true
				self:_tween(sec.TabItem, { Position = U(0.1, 100, 0, 0) }, 0.8)
			end
		end
	end
end

function Coral:_backTab()
	self:_resetSections()
	self.MainSelector.Visible = true
end

--- Minimize / restore the whole bar -------------------------------------------------
function Coral:Hide()
	local bar = self.LeftBarFrame
	if bar.Visible == false then
		return
	end
	self:_resetSections()
	if self._unlocked then
		self.MainSelector.Visible = true
	end
	local time = self:_tween(bar, { Position = U(-0.1, -100, 0, 0) }, 0.5, Enum.EasingStyle.Linear)
	task.wait(time)
	bar.Visible = false
	self.ShowUI.Visible = true
	if self.Config.CenteredMinimize then
		self.ShowUI.Position = U(0.5, -15, 0, -100)
		self:_tween(self.ShowUI, { Position = U(0.5, -15, 0, 60) }, 0.5, Enum.EasingStyle.Linear)
	else
		self.ShowUI.Position = U(-0.1, -100, 0, 0)
		self:_tween(self.ShowUI, { Position = U(0, 15, 0, 60) }, 0.5, Enum.EasingStyle.Linear)
	end
end

function Coral:Show()
	if self.Config.CenteredMinimize then
		local time = self:_tween(self.ShowUI, { Position = U(0.5, -15, 0, -100) }, 0.5, Enum.EasingStyle.Linear)
		task.wait(time - 0.1)
	end
	self.ShowUI.Visible = false
	self.LeftBarFrame.Visible = true
	self:_tween(self.LeftBarFrame, { Position = U(0, 0, 0, 0) }, 0.5, Enum.EasingStyle.Linear)
end

function Coral:SetCenteredMinimize(state)
	self.Config.CenteredMinimize = state and true or false
end

function Coral:SetFastAnimations(state)
	self.Config.FastAnimations = state and true or false
end

function Coral:SetNoAnimations(state)
	self.Config.NoAnimations = state and true or false
end

function Coral:Destroy()
	for _, c in ipairs(self._connections) do
		pcall(function()
			c:Disconnect()
		end)
	end
	self.Gui:Destroy()
end

--- Popup (same as the original notification box) ------------------------------------
function Coral:Notify(title, text, onOk)
	local notification = New("Frame", {
		Name = "Notification",
		Parent = self.Gui,
		BackgroundColor3 = DARK,
		BorderColor3 = DARK,
		BorderSizePixel = 0,
		Position = U(0.5, -210, 0.5, -120),
		Size = U(0, 420, 0, 240),
	})
	New("UICorner", { Parent = notification })
	New("TextLabel", {
		Name = "Title",
		Parent = notification,
		BackgroundColor3 = DARK,
		BackgroundTransparency = 1,
		BorderColor3 = WHITE,
		BorderSizePixel = 0,
		Position = U(0, 5, 0, 0),
		Size = U(1, -5, 0, 25),
		Font = Enum.Font.GothamMedium,
		Text = title,
		TextColor3 = WHITE,
		TextSize = 14,
		TextWrapped = true,
	})
	local body = New("TextLabel", {
		Name = "Text",
		Parent = notification,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		BorderColor3 = BLACK,
		BorderSizePixel = 0,
		Position = U(0, 5, 0, 25),
		Size = U(1, -5, 0, 175),
		Font = Enum.Font.Gotham,
		Text = text,
		TextColor3 = WHITE,
		TextSize = 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
	})
	if body.TextFits == false then
		body.TextScaled = true
	end
	local row = New("Frame", {
		Name = "Button",
		Parent = notification,
		BackgroundColor3 = PURPLE,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = U(0, 0, 1, -35),
		Size = U(1, 0, 0, 25),
	})
	New("UIListLayout", {
		Parent = row,
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UD(0, 2),
	})
	local ok = New("TextButton", {
		Parent = row,
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		BorderSizePixel = 0,
		Size = U(0, 150, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = "OK",
		TextColor3 = WHITE,
		TextSize = 12,
		TextStrokeColor3 = WHITE,
	})
	Corner(ok, 5)
	ok.MouseButton1Down:Connect(function()
		notification:Destroy()
		if onOk then
			onOk()
		end
	end)
	return notification
end

--- Key page (shown in the bar before the sections) ----------------------------------
--[[
    Coral:CreateKeyPage({
        ExtraText  = "The key link was copied ...",
        OnGetKey   = function() end,
        OnCheckKey = function(key) return true | false end,   -- true unlocks the UI
    })
]]
function Coral:CreateKeyPage(opts)
	opts = opts or {}
	self._unlocked = false
	self.MainSelector.Visible = false
	local selector = self:_makeSelector(true)
	self.KeySelector = selector

	New("TextLabel", {
		Name = "Title",
		Parent = selector,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		BorderColor3 = BLACK,
		BorderSizePixel = 0,
		Size = U(0.899999976, 0, 0, 25),
		Font = Enum.Font.GothamBold,
		Text = "Key",
		TextColor3 = WHITE,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	local KeyBox = New("Frame", {
		Name = "KeyBox",
		Parent = selector,
		BackgroundColor3 = ITEM,
		BorderSizePixel = 0,
		Size = U(0.899999976, 0, 0, 25),
	})
	New("UICorner", { Parent = KeyBox })
	local input = New("TextBox", {
		Parent = KeyBox,
		BackgroundColor3 = PURPLE,
		BackgroundTransparency = 1,
		BorderColor3 = BLACK,
		BorderSizePixel = 0,
		Position = U(0.130648464, 0, 0.159999996, 0),
		Size = U(0.869351506, 0, 0.720000029, 0),
		Font = Enum.Font.Gotham,
		MultiLine = true,
		Text = "",
		TextColor3 = INPUT_TEXT,
		TextSize = 14,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
	})
	New("ImageLabel", {
		Name = "Logo",
		Parent = KeyBox,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = U(0.0360067226, 0, -0.173333317, 10),
		Size = U(0.065416269, 0, 0.5, 0),
		Image = self.LogoImage,
		ScaleType = Enum.ScaleType.Fit,
	})
	New("Frame", {
		Name = "Sep",
		Parent = selector,
		BackgroundColor3 = ITEM,
		BorderSizePixel = 0,
		Size = U(0.899999976, 0, 0, 1),
	})

	local Extra
	makeButton(selector, "Check Key", function()
		local ok = true
		if opts.OnCheckKey then
			ok = opts.OnCheckKey(input.Text)
		end
		if ok then
			self:Unlock(true)
		end
	end, { Purple = true }).Name = "CheckKey"
	makeButton(selector, "Get Key", function()
		Extra.Visible = true
		if opts.OnGetKey then
			opts.OnGetKey()
		end
	end).Name = "GetKey"

	Extra = New("TextLabel", {
		Name = "Extra",
		Parent = selector,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		BorderColor3 = BLACK,
		BorderSizePixel = 0,
		Size = U(0.899999976, 0, 1, -135),
		Font = Enum.Font.Gotham,
		Text = opts.ExtraText or "The key link was copied to your clipboard! Paste it into a browser (like Chrome) to get a key!",
		TextColor3 = WHITE,
		TextSize = 14,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		Visible = false,
		TextScaled = true,
	})
	self.KeyExtra = Extra
	self.KeyBox = input
	return selector
end

function Coral:Unlock(animate)
	if self.KeySelector then
		self.KeySelector.Visible = false
	end
	if animate then
		local time = self:_tween(self.LeftBarFrame, { Position = U(-0.1, -100, 0, 0) }, 0.5, Enum.EasingStyle.Linear)
		task.wait(time)
		self:_tween(self.LeftBarFrame, { Position = U(0, 0, 0, 0) }, 0.5, Enum.EasingStyle.Linear)
	end
	self._unlocked = true
	self.MainSelector.Visible = true
end

--------------------------------------------------------------------------------
-- Coral sections
--------------------------------------------------------------------------------

--[[
    Coral:CreateSection("Executor", { BackButton = true })
    Adds a button to the bar, a hidden list for that section and a content panel (Section.Container).
    A "< Back" button and a small padding are added automatically (BackButton = false to skip).
]]
function Coral:CreateSection(name, opts)
	opts = opts or {}
	local sec = setmetatable({ Window = self, Name = name }, Section)

	local TabItem = New("Frame", {
		Name = "TabItem",
		Parent = self.Gui,
		BackgroundColor3 = BLACK,
		BackgroundTransparency = 0.3,
		BorderColor3 = BLACK,
		BorderSizePixel = 0,
		Position = U(0.1, 100, -1, 0),
		Size = U(0.9, -100, 1, 0),
		Visible = false,
	})
	local Container = New("Frame", {
		Name = "Container",
		Parent = TabItem,
		BackgroundColor3 = BLACK,
		BackgroundTransparency = 1,
		BorderColor3 = BLACK,
		BorderSizePixel = 0,
		Position = U(0, 10, 0, 10),
		Size = U(1, -10, 1, -10),
	})
	local selector = self:_makeSelector(false)
	sec.TabItem = TabItem
	sec.Container = Container
	sec.Selector = selector

	local frame, button = makeButton(self.MainSelector, name, function(f)
		self:_switchTab(f)
	end, { Purple = false })
	sec.Frame = frame
	sec.TextButton = button
	table.insert(self.Sections, sec)

	if opts.BackButton ~= false then
		sec:CreateBackButton()
		sec:CreatePadding()
	end
	return sec
end

function Section:CreateButton(name, callback, opts)
	return makeButton(self.Selector, name, callback, opts)
end

function Section:CreateLabel(name)
	return New("TextLabel", {
		Name = "Label",
		Parent = self.Selector,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		BorderColor3 = BLACK,
		BorderSizePixel = 0,
		Size = U(0.9, 0, 0, 25),
		Font = Enum.Font.GothamBold,
		Text = name,
		TextColor3 = WHITE,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
end

-- small info line (for example "USER IDENTITY" bold / the id below it regular)
function Section:CreateTextLine(text, opts)
	opts = opts or {}
	local label = New("TextLabel", {
		Name = opts.Name or "TextLine",
		Parent = self.Selector,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		BorderColor3 = BLACK,
		BorderSizePixel = 0,
		Size = U(0.899999976, 0, -0.0110905729, 25),
		Font = opts.Bold and Enum.Font.GothamBold or Enum.Font.Gotham,
		Text = text,
		TextColor3 = WHITE,
		TextSize = opts.TextSize or 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	if not opts.Bold and label.TextFits == false then
		label.TextScaled = true
	end
	return label
end

function Section:CreatePadding(size)
	return New("Frame", {
		Name = "Padding",
		Parent = self.Selector,
		BackgroundColor3 = PURPLE,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = U(0.9, 0, 0, size or 12.5),
	})
end

function Section:CreateSeparator()
	return New("Frame", {
		Name = "Padding",
		Parent = self.Selector,
		BackgroundColor3 = ITEM,
		BorderSizePixel = 0,
		Size = U(0.9, 0, 0, 1),
	})
end

function Section:CreateBackButton()
	local back = New("Frame", {
		Name = "Back",
		Parent = self.Selector,
		BackgroundColor3 = DARK,
		BorderSizePixel = 0,
		Size = U(0.9, 0, 0, 25),
	})
	New("UICorner", { Parent = back })
	local button = New("TextButton", {
		Parent = back,
		BackgroundColor3 = BTN_BG,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = U(1, 0, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = "< Back",
		TextColor3 = WHITE,
		TextSize = 14,
		TextStrokeColor3 = WHITE,
	})
	button.MouseButton1Down:Connect(function()
		self.Window:_backTab()
	end)
	return button
end

--[[
    Section:CreateToggle("Name", function(state) end, { Enabled = false, Call = false })
    Call = true fires the callback once at creation when Enabled.
]]
function Section:CreateToggle(name, callback, opts)
	opts = type(opts) == "table" and opts or {}
	local window = self.Window
	local enabled = opts.Enabled and true or false

	local toggle = New("Frame", {
		Name = "Toggle",
		Parent = self.Selector,
		BackgroundColor3 = PURPLE,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = U(0.05, 0, 0.111, 0),
		Size = U(0.9, 0, -0.003, 25),
	})
	New("TextLabel", {
		Name = "Text",
		Parent = toggle,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		BorderColor3 = BLACK,
		BorderSizePixel = 0,
		Position = U(0, 25, 0, 0),
		Size = U(1, -25, 1, 0),
		Font = Enum.Font.Gotham,
		Text = name,
		TextColor3 = WHITE,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	local outer = New("TextButton", {
		Parent = toggle,
		BackgroundColor3 = ITEM,
		BorderColor3 = BLACK,
		BorderSizePixel = 0,
		Size = U(0, 22, 0, 22),
		AutoButtonColor = false,
		Font = Enum.Font.SourceSans,
		Text = "",
		TextColor3 = BLACK,
		TextSize = 14,
	})
	Corner(outer, 5)
	local dot = New("TextButton", {
		Name = "Selector",
		Parent = toggle,
		BackgroundColor3 = enabled and PURPLE or ITEM,
		BorderColor3 = BLACK,
		BorderSizePixel = 0,
		Position = U(0, 4, 0, 4),
		Size = U(0, 14, 0, 14),
		AutoButtonColor = false,
		Font = Enum.Font.SourceSans,
		Text = "",
		TextColor3 = BLACK,
		TextSize = 14,
	})
	New("UICorner", { Parent = dot, CornerRadius = UD(1, 0) })

	local api = {}
	local function apply(value, silent)
		enabled = value
		window:_tween(dot, { BackgroundColor3 = enabled and PURPLE or ITEM })
		if callback and not silent then
			callback(enabled)
		end
	end
	function api:Get()
		return enabled
	end
	function api:Set(value, silent)
		apply(value and true or false, silent)
		return self
	end
	dot.MouseButton1Down:Connect(function()
		apply(not enabled)
	end)
	outer.MouseButton1Down:Connect(function()
		apply(not enabled)
	end)
	if enabled and opts.Call and callback then
		callback(true)
	end
	return wrap(toggle, api)
end

--[[
    Search box with the logo on the left.
    Section:CreateSearchBar({ Placeholder = "Search Console", ClearTextOnFocus = true, Truncate = false,
                              OnFocusLost = function(text) end })
]]
function Section:CreateSearchBar(opts)
	opts = opts or {}
	local frame = New("Frame", {
		Name = "Search",
		Parent = self.Selector,
		BackgroundColor3 = ITEM,
		BorderSizePixel = 0,
		Size = U(0.9, 0, 0, 25),
	})
	New("UICorner", { Parent = frame })
	local box = New("TextBox", {
		Parent = frame,
		BackgroundColor3 = PURPLE,
		BackgroundTransparency = 1,
		BorderColor3 = BLACK,
		BorderSizePixel = 0,
		Position = U(0.131, 0, 0.16, 0),
		Size = U(0.869, 0, 0.72, 0),
		Font = Enum.Font.Gotham,
		MultiLine = false,
		PlaceholderText = opts.Placeholder or "Search",
		Text = "",
		TextColor3 = INPUT_TEXT,
		TextSize = 14,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
	})
	if opts.Truncate then
		box.TextTruncate = Enum.TextTruncate.AtEnd
	end
	if opts.ClearTextOnFocus == false then
		box.ClearTextOnFocus = false
	end
	New("ImageLabel", {
		Name = "Logo",
		Parent = frame,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = U(0.036, 0, -0.173, 10),
		Size = U(0.065, 0, 0.5, 0),
		Image = self.Window.LogoImage,
		ScaleType = Enum.ScaleType.Fit,
	})
	if opts.OnFocusLost then
		box.FocusLost:Connect(function()
			opts.OnFocusLost(box.Text)
		end)
	end
	return frame, box
end

--[[
    Search bar + "Clear History" button + history buttons (the Cloud search layout).
    Section:CreateSearch({
        Placeholder = "Search Scripts", ClearText = "Clear History", HistorySize = 3,
        OnSearch = function(query) end,
    })
]]
function Section:CreateSearch(opts)
	opts = opts or {}
	local size = opts.HistorySize or 3
	local frame, box = self:CreateSearchBar({ Placeholder = opts.Placeholder or "Search Scripts" })

	local clearFrame, clearButton = makeButton(self.Selector, opts.ClearText or "Clear History", nil, { Purple = true })
	clearFrame.Name = "ClearHistory"
	self:CreateSeparator()

	local history = {}
	local function search(query)
		if opts.OnSearch then
			opts.OnSearch(query)
		end
	end
	for i = 1, size do
		local entry = makeButton(self.Selector, "", function(f)
			search(f.TextButton.Text)
		end)
		entry.Visible = false
		history[i] = entry
	end

	clearButton.MouseButton1Down:Connect(function()
		for _, entry in ipairs(history) do
			entry.Visible = false
		end
	end)
	box.FocusLost:Connect(function()
		local text = box.Text
		if text == "" then
			return
		end
		local placed = false
		for _, entry in ipairs(history) do
			if entry.Visible == false then
				entry.TextButton.Text = text
				entry.Visible = true
				placed = true
				break
			end
		end
		if not placed then
			for i = size, 2, -1 do
				history[i].TextButton.Text = history[i - 1].TextButton.Text
			end
			history[1].TextButton.Text = text
		end
		search(text)
	end)
	return { Frame = frame, TextBox = box, History = history }
end

--------------------------------------------------------------------------------
-- Executor-style script editor (content panel)
--------------------------------------------------------------------------------

--[[
    local editor = section:CreateScriptEditor({
        Tabs = { { TabName = "Script 1", Text = "..." } },   -- optional saved tabs
        Scripts = { ["name.luau"] = "source" },              -- optional "Script Folder" entries
        Placeholder = 'print("Hello World!")',
        OnTabsChanged = function(tabs) end,                  -- use it to save tabs
    })
    editor:GetText() / :SetText(t) / :GetName() / :SetName(n) / :AddScript(title, source)
    editor:NewTab(name, text) / :GetTabs() / :SetFolderVisible(bool)
]]
function Section:CreateScriptEditor(opts)
	opts = opts or {}
	local Container = self.Container

	local ScriptFrameContainer = New("Frame", {
		Name = "ScriptFrameContainer",
		Parent = Container,
		BackgroundColor3 = BLACK,
		BackgroundTransparency = 0.9,
		BorderColor3 = BLACK,
		BorderSizePixel = 0,
		Position = U(0.800000012, 0, 0, -10),
		Size = U(0.200000003, 0, 1, 10),
	})
	local ScriptFolder = New("ScrollingFrame", {
		Name = "ScriptFolder",
		VerticalScrollBarInset = Enum.ScrollBarInset.Always,
		ElasticBehavior = Enum.ElasticBehavior.Never,
		Parent = ScriptFrameContainer,
		Active = true,
		BackgroundColor3 = BLACK,
		BackgroundTransparency = 1,
		BorderColor3 = BLACK,
		BorderSizePixel = 0,
		Size = U(1, 0, 0.8, 0),
		ScrollBarThickness = 8,
	})
	local folderLayout = New("UIListLayout", {
		Parent = ScriptFolder,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UD(0, 5),
	})
	ScriptFolder.CanvasSize = U(0, 0, 0, folderLayout.AbsoluteContentSize.Y)
	folderLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		ScriptFolder.CanvasSize = U(0, 0, 0, folderLayout.AbsoluteContentSize.Y)
	end)
	New("TextLabel", {
		Name = "UserIdentity",
		Parent = ScriptFolder,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		BorderColor3 = BLACK,
		BorderSizePixel = 0,
		Position = U(0.0496892706, 0, 0.00134769862, 0),
		Size = U(0.89440614, 0, -0.00479941955, 25),
		Font = Enum.Font.GothamBold,
		Text = "Script Folder",
		TextColor3 = WHITE,
		TextSize = 10,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	New("UIPadding", { Parent = ScriptFolder, PaddingTop = UD(0, 1) })

	local TopBar = New("Frame", {
		Name = "TopBar",
		Parent = Container,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Position = U(0, 0, 0, -10),
		Size = U(1, 0, 0, 50),
	})
	New("UIListLayout", {
		Parent = TopBar,
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UD(0, 5),
	})

	-- script name box
	local ScriptSlot = New("Frame", {
		Name = "Script",
		Parent = TopBar,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = U(-0.00669243885, 100, 1, 0),
	})
	local nameFrame = New("Frame", {
		Parent = ScriptSlot,
		BackgroundColor3 = PURPLE,
		BorderSizePixel = 0,
		Position = U(0, 0, 0.25, 0),
		Size = U(1, 0, 0.5, 0),
	})
	New("UICorner", { Parent = nameFrame })
	local ScriptNameBox = New("TextBox", {
		Parent = nameFrame,
		BackgroundColor3 = BTN_BG,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = U(1, 0, 1, 0),
		Font = Enum.Font.Gotham,
		Text = opts.DefaultName or "Script 1",
		TextColor3 = WHITE,
		TextSize = 12,
		TextStrokeColor3 = WHITE,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextWrapped = true,
	})

	local function barButton(name, width, text, hidden)
		local slot = New("Frame", {
			Name = name,
			Parent = TopBar,
			BackgroundColor3 = WHITE,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = U(0.0638823658, 0, 0, 0),
			Size = U(0, width, 1, 0),
		})
		local box = New("Frame", {
			Parent = slot,
			BackgroundColor3 = BAR,
			BorderSizePixel = 0,
			Position = U(0, 0, 0.25, 0),
			Size = U(1, 0, 0.5, 0),
		})
		New("UICorner", { Parent = box })
		local btn = New("TextButton", {
			Parent = box,
			BackgroundColor3 = BTN_BG,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = U(1, 0, 1, 0),
			Font = Enum.Font.GothamBold,
			Text = text,
			TextColor3 = WHITE,
			TextScaled = true,
			TextSize = 12,
			TextStrokeColor3 = WHITE,
			TextWrapped = true,
		})
		return slot, box, btn
	end
	local _, _, plusButton = barButton("NewTab", 25, "+")
	local deleteSlot, _, deleteButton = barButton("Delete", 25, "-")
	deleteSlot.Visible = false
	local _, backBox, backButton = barButton("BackTab", 30, "<")
	backBox.Visible = false
	local _, nextBox, nextButton = barButton("NextTab", 30, ">")
	nextBox.Visible = false

	local TextBox = New("TextBox", {
		Parent = Container,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		BorderColor3 = BLACK,
		BorderSizePixel = 0,
		Position = U(0, 0, 0, 50),
		Size = U(0.75, 0, 1, -50),
		Font = Enum.Font.Gotham,
		MultiLine = true,
		PlaceholderText = opts.Placeholder or 'print("Hello World!")',
		Text = "",
		TextColor3 = INPUT_TEXT,
		TextSize = 14,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ClearTextOnFocus = false,
	})

	-- tab state (same logic as the original)
	local CurrentIndex = 1
	local MaxIndex = 1
	local TabItems = { { Text = "", TabName = opts.DefaultName or "Script 1" } }

	local function save()
		if opts.OnTabsChanged then
			local filtered = {}
			for i = 1, MaxIndex do
				local v = TabItems[i]
				if v then
					table.insert(filtered, { Text = v.Text, TabName = v.TabName })
				end
			end
			opts.OnTabsChanged(filtered)
		end
	end
	local function showNav()
		backBox.Visible = true
		nextBox.Visible = true
		deleteSlot.Visible = true
	end
	local function load(info)
		TextBox.Text = info.Text
		ScriptNameBox.Text = info.TabName
	end

	if opts.Tabs and #opts.Tabs > 0 then
		TabItems = {}
		for i, v in ipairs(opts.Tabs) do
			TabItems[i] = { Text = v.Text or "", TabName = v.TabName or ("Script " .. i) }
		end
		MaxIndex = #TabItems
		showNav()
		load(TabItems[1])
		CurrentIndex = 1
	end

	local function addItem(title, source)
		local row = New("Frame", {
			Name = "ClearScript",
			Parent = ScriptFolder,
			BackgroundColor3 = ITEM,
			BorderSizePixel = 0,
			Size = U(0.8, 0, 0, 17),
		})
		New("UICorner", { Parent = row })
		local btn = New("TextButton", {
			Parent = row,
			BackgroundColor3 = BTN_BG,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = U(1, 0, 1, 0),
			Font = Enum.Font.Gotham,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Text = title,
			TextColor3 = WHITE,
			TextSize = 12,
			TextStrokeColor3 = WHITE,
		})
		btn.MouseButton1Down:Connect(function()
			if CurrentIndex == 1 then
				showNav()
			end
			MaxIndex = MaxIndex + 1
			CurrentIndex = MaxIndex
			TabItems[CurrentIndex] = { Text = source, TabName = title }
			TextBox.Text = source
			ScriptNameBox.Text = title
		end)
	end

	local hasScripts = false
	if type(opts.Scripts) == "table" then
		for name, source in pairs(opts.Scripts) do
			addItem(name, source)
			hasScripts = true
		end
	end
	ScriptFrameContainer.Visible = hasScripts

	ScriptNameBox:GetPropertyChangedSignal("Text"):Connect(function()
		ScriptNameBox.TextScaled = not ScriptNameBox.TextFits
	end)
	TextBox.FocusLost:Connect(function()
		if TabItems[CurrentIndex] then
			TabItems[CurrentIndex].Text = TextBox.Text
		end
		save()
	end)
	ScriptNameBox.FocusLost:Connect(function()
		if TabItems[CurrentIndex] and TabItems[CurrentIndex].TabName then
			TabItems[CurrentIndex].TabName = ScriptNameBox.Text
			save()
		end
	end)

	local function newTab(name, text)
		if CurrentIndex == 1 then
			showNav()
		end
		MaxIndex = MaxIndex + 1
		CurrentIndex = MaxIndex
		TabItems[CurrentIndex] = { Text = text or "", TabName = name or ("Script " .. tostring(CurrentIndex)) }
		TextBox.Text = TabItems[CurrentIndex].Text
		ScriptNameBox.Text = TabItems[CurrentIndex].TabName
	end
	plusButton.MouseButton1Down:Connect(function()
		newTab()
	end)

	local function step(direction, limit)
		if CurrentIndex == limit then
			return false
		end
		local old = CurrentIndex
		CurrentIndex = CurrentIndex + direction
		while TabItems[CurrentIndex] == false do
			if CurrentIndex == limit then
				CurrentIndex = old
				return false
			end
			CurrentIndex = CurrentIndex + direction
		end
		load(TabItems[CurrentIndex])
		return true
	end
	deleteButton.MouseButton1Down:Connect(function()
		if CurrentIndex == 1 then
			return
		end
		local old = CurrentIndex
		TabItems[CurrentIndex] = false
		CurrentIndex = CurrentIndex - 1
		while TabItems[CurrentIndex] == false do
			if CurrentIndex == 1 then
				CurrentIndex = old
				return
			end
			CurrentIndex = CurrentIndex - 1
		end
		load(TabItems[CurrentIndex])
		save()
	end)
	backButton.MouseButton1Down:Connect(function()
		step(-1, 1)
	end)
	nextButton.MouseButton1Down:Connect(function()
		step(1, MaxIndex)
	end)

	local api = { TextBox = TextBox, NameBox = ScriptNameBox }
	function api:GetText()
		if TabItems[CurrentIndex] then
			TabItems[CurrentIndex].Text = TextBox.Text
		end
		return TextBox.Text
	end
	function api:SetText(t)
		TextBox.Text = t
		if TabItems[CurrentIndex] then
			TabItems[CurrentIndex].Text = t
		end
		save()
		return self
	end
	function api:GetName()
		return ScriptNameBox.Text
	end
	function api:SetName(n)
		ScriptNameBox.Text = n
		if TabItems[CurrentIndex] then
			TabItems[CurrentIndex].TabName = n
		end
		save()
		return self
	end
	function api:AddScript(title, source)
		ScriptFrameContainer.Visible = true
		addItem(title, source)
		return self
	end
	function api:SetFolderVisible(state)
		ScriptFrameContainer.Visible = state
		return self
	end
	function api:NewTab(name, text)
		newTab(name, text)
		return self
	end
	function api:GetTabs()
		local filtered = {}
		for i = 1, MaxIndex do
			local v = TabItems[i]
			if v then
				table.insert(filtered, { Text = v.Text, TabName = v.TabName })
			end
		end
		return filtered
	end
	return api
end

--------------------------------------------------------------------------------
-- Cloud style card list (content panel)
--------------------------------------------------------------------------------

--[[
    local list = section:CreateCardList()
    list:SetHeader("Matching <font ...>query</font>")   or  list:SetMatching("query")
    list:AddCard({
        Title = "...", Author = "name", Description = "...", Image = "rbxthumb://...",
        Buttons = { { Text = "Execute", Purple = true, Callback = fn }, { Text = "Copy Script", Callback = fn } },
    })
    list:Clear()
]]
function Section:CreateCardList()
	local Container = self.Container
	local scroll = New("ScrollingFrame", {
		Parent = Container,
		Active = true,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		BorderColor3 = BLACK,
		BorderSizePixel = 0,
		Size = U(1, 0, 1, 0),
		CanvasSize = U(0, 0, 5, 0),
		ScrollBarThickness = 5,
		ElasticBehavior = Enum.ElasticBehavior.Never,
		ScrollingDirection = Enum.ScrollingDirection.Y,
	})
	local header = New("TextLabel", {
		Name = "Clipboard",
		Parent = scroll,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		BorderColor3 = BLACK,
		BorderSizePixel = 0,
		Position = U(3.7057486e-08, 0, 0, 0),
		Size = U(0.99000001, 0, 0, 25),
		Font = Enum.Font.Gotham,
		Text = "",
		RichText = true,
		TextColor3 = WHITE,
		TextScaled = true,
		TextSize = 14,
		TextWrapped = true,
	})
	local layout = New("UIListLayout", { Parent = scroll, Padding = UD(0, 5) })
	scroll.CanvasSize = U(0, 0, 0, layout.AbsoluteContentSize.Y)
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = U(0, 0, 0, layout.AbsoluteContentSize.Y)
	end)
	New("Frame", {
		Name = "Padding",
		Parent = scroll,
		BackgroundColor3 = BLACK,
		BackgroundTransparency = 1,
		BorderColor3 = BLACK,
		BorderSizePixel = 0,
		Position = U(0.355789751, 0, 0.026041666, 0),
		Size = U(0, 0, 0, 10),
	})

	local cards = {}
	local api = { Instance = scroll, Header = header }
	function api:SetHeader(richText)
		header.Text = richText
		return self
	end
	function api:SetMatching(query)
		header.Text = 'Matching<font family="rbxasset://fonts/families/GothamSSm.json" style="Normal" weight="700" > '
			.. query .. "</font>"
		return self
	end
	function api:Clear()
		for i, card in ipairs(cards) do
			card:Destroy()
			cards[i] = nil
		end
		return self
	end
	function api:AddCard(card)
		card = card or {}
		local container = New("Frame", {
			Name = "ScriptContainer",
			Parent = scroll,
			BackgroundColor3 = BLACK,
			BackgroundTransparency = 0.5,
			BorderColor3 = BLACK,
			BorderSizePixel = 0,
			Size = U(0.99, 0, 0, 200),
		})
		table.insert(cards, container)
		local image = New("ImageLabel", {
			Parent = container,
			BackgroundColor3 = WHITE,
			BorderColor3 = BLACK,
			BorderSizePixel = 0,
			Size = U(1, 0, 1, 0),
			Image = card.Image or "",
			ScaleType = Enum.ScaleType.Tile,
		})
		New("UICorner", { Parent = image })
		New("UICorner", { Parent = container })
		local overlay = New("Frame", {
			Parent = container,
			BackgroundColor3 = BLACK,
			BackgroundTransparency = 0.3,
			BorderColor3 = BLACK,
			BorderSizePixel = 0,
			Size = U(1, 0, 1, 0),
		})
		New("UICorner", { Parent = overlay })
		New("TextLabel", {
			Name = "Title",
			Parent = overlay,
			BackgroundColor3 = WHITE,
			BackgroundTransparency = 1,
			BorderColor3 = BLACK,
			BorderSizePixel = 0,
			Position = U(0.0109999413, 0, 0.036896646, 0),
			Size = U(0.5, 0, 0, 25),
			Font = Enum.Font.GothamMedium,
			Text = card.Title or "",
			TextColor3 = WHITE,
			TextScaled = true,
			TextSize = 14,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		New("TextLabel", {
			Name = "Author",
			Parent = overlay,
			BackgroundColor3 = WHITE,
			BackgroundTransparency = 1,
			BorderColor3 = BLACK,
			BorderSizePixel = 0,
			Position = U(0.011712254, 0, -0.0285714287, 40),
			Size = U(0.978287756, 0, -0.05714285, 25),
			Font = Enum.Font.Gotham,
			Text = "By " .. (card.Author or "Unknown"),
			TextColor3 = WHITE,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		New("TextLabel", {
			Name = "Desc",
			Parent = overlay,
			BackgroundColor3 = WHITE,
			BackgroundTransparency = 1,
			BorderColor3 = BLACK,
			BorderSizePixel = 0,
			Position = U(0.011712254, 0, -0.0289999992, 65),
			Size = U(0.978287756, 0, 1, -120),
			Font = Enum.Font.Roboto,
			Text = card.Description or "",
			TextColor3 = WHITE,
			TextSize = 14,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
		})
		local buttons = card.Buttons or {
			{ Text = "Execute", Purple = true, Callback = card.OnExecute },
			{ Text = "Copy Script", Callback = card.OnCopy },
		}
		for i, b in ipairs(buttons) do
			local holder = New("Frame", {
				Name = (i == 1) and "Execute" or "CopyScript",
				Parent = overlay,
				BackgroundColor3 = b.Purple and PURPLE or ITEM,
				BorderSizePixel = 0,
				Position = U(0.0109999999, 110 * (i - 1), 1, -35),
				Size = U(0, 100, 0, 25),
			})
			New("UICorner", { Parent = holder })
			local btn = New("TextButton", {
				Parent = holder,
				BackgroundColor3 = BTN_BG,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = U(1, 0, 1, 0),
				Font = Enum.Font.GothamBold,
				Text = b.Text or "Button",
				TextColor3 = WHITE,
				TextSize = 12,
				TextStrokeColor3 = WHITE,
			})
			btn.MouseButton1Down:Connect(function()
				if b.Callback then
					b.Callback(card)
				end
			end)
		end
		return container
	end
	return api
end

--------------------------------------------------------------------------------
-- Console (content panel)
--------------------------------------------------------------------------------

local CONSOLE_COLORS = {
	SUCCESS = "#67C554",
	ERROR = "#E03232",
	WARN = "#FEEE79",
}

--[[
    local console = section:CreateConsole()
    console:Log("SUCCESS" | "OUTPUT" | "WARN" | "ERROR", "text")
    console:Clear() / console:Copy() / console:SetTypeVisible("WARN", false) / console:Filter("text")
    console:HookLogService()   -- forwards Roblox output / warnings / errors
]]
function Section:CreateConsole()
	local Container = self.Container
	local scroll = New("ScrollingFrame", {
		Parent = Container,
		Active = true,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		BorderColor3 = BLACK,
		BorderSizePixel = 0,
		Size = U(1, 0, 1, 0),
		CanvasSize = U(0, 0, 0, 0),
		ScrollBarThickness = 5,
	})
	local layout = New("UIListLayout", {
		Parent = scroll,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UD(0, 5),
	})
	scroll.CanvasSize = U(0, 0, 0, layout.AbsoluteContentSize.Y)
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = U(0, 0, 0, layout.AbsoluteContentSize.Y)
		scroll.CanvasPosition = V2(0, layout.AbsoluteContentSize.Y)
	end)
	New("Frame", {
		Name = "Padding",
		Parent = scroll,
		BackgroundColor3 = BLACK,
		BackgroundTransparency = 1,
		BorderColor3 = BLACK,
		BorderSizePixel = 0,
		Position = U(0.355789751, 0, 0.026041666, 0),
		Size = U(0, 0, 0, 10),
	})

	local typeState = { OUTPUT = true, WARN = true, ERROR = true, SUCCESS = true }
	local api = { Instance = scroll }

	function api:Log(kind, text, visible)
		text = tostring(text)
		if visible == nil then
			visible = typeState[kind] ~= false
		end
		local color = CONSOLE_COLORS[kind] or "#BFBFBF"
		local label = New("TextLabel", {
			Name = kind,
			Parent = scroll,
			BackgroundColor3 = WHITE,
			BackgroundTransparency = 1,
			BorderColor3 = BLACK,
			BorderSizePixel = 0,
			Position = U(0.002, 0, 0, 0),
			Font = Enum.Font.Gotham,
			AutoLocalize = false,
			Text = "[" .. os.date("%H:%M") .. '] <font family="rbxasset://fonts/families/GothamSSm.json" color="'
				.. color .. '" style="Normal" weight="500" >[' .. kind .. "] </font> " .. text,
			TextColor3 = WHITE,
			TextSize = 14,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			RichText = true,
			Visible = visible,
		})
		local count = select(2, text:gsub("\n", "\n"))
		if count > 1 then
			label.Size = U(0.99, 0, 0, (25 * (count - 1)) + 25)
		else
			label.Size = U(0.99, 0, 0, 25)
		end
		return label
	end
	function api:Clear()
		for _, v in ipairs(scroll:GetChildren()) do
			if v:IsA("TextLabel") then
				v:Destroy()
			end
		end
		return self
	end
	function api:Copy()
		local out = ""
		for _, v in ipairs(scroll:GetChildren()) do
			if v:IsA("TextLabel") then
				out = out .. v.Text .. "\n"
			end
		end
		return out
	end
	function api:SetTypeVisible(kind, state)
		typeState[kind] = state
		for _, v in ipairs(scroll:GetChildren()) do
			if v:IsA("TextLabel") and v.Name == kind then
				v.Visible = state
			end
		end
		return self
	end
	function api:Filter(query)
		query = string.lower(query or "")
		for _, v in ipairs(scroll:GetChildren()) do
			if v:IsA("TextLabel") and typeState[v.Name] ~= false then
				local body = string.match(string.lower(v.Text), "</font> (.*)") or ""
				v.Visible = string.find(body, query, 1, true) ~= nil
			end
		end
		return self
	end
	function api:HookLogService()
		return LogService.MessageOut:Connect(function(message, kind)
			if kind == Enum.MessageType.MessageOutput then
				self:Log("OUTPUT", message)
			elseif kind == Enum.MessageType.MessageWarning then
				self:Log("WARN", message)
			elseif kind == Enum.MessageType.MessageError then
				self:Log("ERROR", message)
			end
		end)
	end
	return api
end

Library.Android = Android
Library.Coral = Coral

return Library
