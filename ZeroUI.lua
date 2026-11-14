--[[
    ZeroUI  -  Roblox UI Library
    ----------------------------------------------------------------------
    Recreated 1:1 from the "zerohub.cc" Universal GUI (same sizes, colors,
    fonts, icons, animations, dark / light themes, sidebar drawer, tab
    carousel, toast notifications, script cards, console, editor, music
    player, AI chat ...), but exposed as a reusable library.

    Quick start
    ----------------------------------------------------------------------
        local ZeroUI = loadstring(game:HttpGet("<url of this file>"))()
        -- or:  local ZeroUI = require(path.to.ZeroUI)

        local Window = ZeroUI:CreateWindow({
            Name  = "myhub",
            Title = "myhub.cc",
        })

        local Tab = Window:AddTab({
            Name = "Universal", Icon = "rbxassetid://10723404337", Layout = "Grid",
        })

        local Card = Tab:AddSection({ Title = "Movement" })
        Card:AddToggle({ Text = "Fly", Icon = "rbxassetid://10734922971",
            Callback = function(on) print("fly", on) end })
        Card:AddSlider({ Icon = "rbxassetid://12975608939", Min = 0, Max = 500,
            Default = 16, Callback = function(v) print(v) end })

        Window:Notify("success", "Loaded", "Welcome!")

    API
    ----------------------------------------------------------------------
    ZeroUI:CreateWindow({ Name, Title, Loader, LoaderTime, LoaderText, Dark,
        ThemeFile, Wallpaper, ClickSound, Draggable, ToggleKey, Welcome,
        NotifyThemeChange, SidebarTitle, MenuIcon })

    Window:AddTab({ Name, Icon, Layout = "Grid"|"List"|"Free", Header, Default })
    Window:SelectTab(nameOrTab) · :Notify(type, title, desc) · :SetTheme(bool)
    Window:ToggleTheme() · :AddSidebarAction({Text, Icon, Callback})
    Window:SetTitle(t) · :SetWallpaper(id) · :SetVisible(b) · :Destroy()

    Tab:AddSection({ Title, Size, Position })  -> Section
        Section:AddToggle / AddButton / AddSlider / AddTextBox / AddLabel / AddSeparator
    Tab:AddSettingCard · AddSearchBar · AddSubTabs · AddProfileCard · AddStats
    Tab:AddInfoCard · AddScriptList · AddConsole · AddEditor · AddChat · AddMusicPlayer

    See Example.lua for every component.
]]

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TextService      = game:GetService("TextService")
local LogService       = game:GetService("LogService")

local LocalPlayer = Players.LocalPlayer

--------------------------------------------------------------------------
-- Constants (taken from the original interface)
--------------------------------------------------------------------------
local FONT_ID      = "rbxassetid://16658237174"   -- main UI font
local MONO_FONT_ID = "rbxassetid://16658246179"   -- console / editor font

local function mainFont(weight)
    return Font.new(FONT_ID, weight or Enum.FontWeight.Regular, Enum.FontStyle.Normal)
end
local function monoFont()
    return Font.new(MONO_FONT_ID, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
end

local ICONS = {
    menu     = "rbxassetid://10723345990",
    close    = "rbxassetid://10747384394",
    minimize = "rbxassetid://10734896206",
    settings = "rbxassetid://10734950309",
    search   = "rbxassetid://10734943674",
    copy     = "rbxassetid://10709812159",
    play     = "rbxassetid://10734923549",
    clear    = "rbxassetid://10709819059",
    save     = "rbxassetid://10734941499",
    plus     = "rbxassetid://10734924532",
    send     = "rbxassetid://10709768939",
    likes    = "rbxassetid://10723346959",
    user     = "rbxassetid://10747373176",
    music    = "rbxassetid://10723404337",
    success  = "rbxassetid://10709790644",
    warning  = "rbxassetid://10709753149",
    info     = "rbxassetid://10723415903",
}

local CLICK_SOUND_ID  = "rbxassetid://135366639238389"
local NOTIFY_SOUND_ID = "rbxassetid://117409737658405"

local WINDOW_W, WINDOW_H = 480, 309
local DRAWER_W           = 186
local BODY_TOP           = 33            -- tab content starts under the title bar

--------------------------------------------------------------------------
-- Palettes (dark = original look, light = original "light theme")
--------------------------------------------------------------------------
local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end

local PALETTES = {
    dark = {
        windowBg      = rgb(20, 20, 20),
        cardBg        = rgb(30, 30, 30),
        controlBg     = rgb(40, 40, 40),
        separator     = rgb(60, 60, 60),
        primaryText   = rgb(255, 255, 255),
        secondaryText = rgb(100, 100, 100),
        primaryIcon   = rgb(255, 255, 255),
        secondaryIcon = rgb(100, 100, 100),
        sliderFill    = rgb(255, 255, 255),
        inputBg       = rgb(40, 40, 40),
        lineNumbers   = rgb(100, 100, 100),
        trackBg       = rgb(100, 100, 100),
        hoverBg       = rgb(50, 50, 50),
        toggleOnBg    = rgb(255, 255, 255),
        toggleOnText  = rgb(30, 30, 30),
        pillActiveBg  = rgb(60, 60, 60),
        pillInactiveBg= rgb(30, 30, 30),
        gutterBg      = rgb(24, 24, 24),
        codeBg        = rgb(18, 18, 18),
        bubbleUser    = rgb(30, 30, 30),
        bubbleAI      = rgb(25, 25, 25),
        scrollBar     = rgb(101, 101, 101),
    },
    light = {
        windowBg      = rgb(244, 245, 248),
        cardBg        = rgb(255, 255, 255),
        controlBg     = rgb(228, 231, 235),
        separator     = rgb(218, 222, 229),
        primaryText   = rgb(17, 24, 39),
        secondaryText = rgb(107, 114, 128),
        primaryIcon   = rgb(17, 24, 39),
        secondaryIcon = rgb(107, 114, 128),
        sliderFill    = rgb(17, 24, 39),
        inputBg       = rgb(243, 244, 246),
        lineNumbers   = rgb(156, 163, 175),
        trackBg       = rgb(228, 231, 235),
        hoverBg       = rgb(216, 220, 226),
        toggleOnBg    = rgb(17, 24, 39),
        toggleOnText  = rgb(255, 255, 255),
        pillActiveBg  = rgb(209, 213, 219),
        pillInactiveBg= rgb(228, 231, 235),
        gutterBg      = rgb(236, 238, 242),
        codeBg        = rgb(238, 240, 244),
        bubbleUser    = rgb(255, 255, 255),
        bubbleAI      = rgb(250, 250, 251),
        scrollBar     = rgb(107, 114, 128),
    },
}

--------------------------------------------------------------------------
-- Small helpers
--------------------------------------------------------------------------
local function create(class, props, parent)
    local inst = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            inst[k] = v
        end
    end
    if parent then inst.Parent = parent end
    return inst
end

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    if radius then c.CornerRadius = radius end
    c.Parent = parent
    return c
end

-- UIShadow is not available on every client, so it is created defensively.
local function shadow(parent)
    local ok, inst = pcall(Instance.new, "UIShadow")
    if ok and inst then
        pcall(function() inst.Parent = parent end)
        return inst
    end
end

local function padding(parent, t, r, b, l)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t or 0)
    p.PaddingRight  = UDim.new(0, r or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft   = UDim.new(0, l or 0)
    p.Parent = parent
    return p
end

local function tween(inst, info, goals)
    local t = TweenService:Create(inst, info, goals)
    t:Play()
    return t
end

local QUAD_OUT_02 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local QUAD_OUT_03 = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local QUAD_OUT_035 = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function isPress(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
end

local function isMove(input)
    return input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
end

local function getGuiParent()
    local ok, parent = pcall(function()
        if type(gethui) == "function" then return gethui() end
    end)
    if ok and parent then return parent end
    ok, parent = pcall(function() return game:GetService("CoreGui") end)
    if ok and parent then return parent end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function protectGui(gui)
    pcall(function()
        if syn and syn.protect_gui then syn.protect_gui(gui) end
    end)
end

local function copyToClipboard(text)
    local fn = setclipboard or toclipboard or (syn and syn.write_clipboard)
    if fn then return pcall(fn, text) end
    return false
end

local function escapeRich(text)
    return (tostring(text):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function toHex(color)
    return string.format("%02X%02X%02X",
        math.floor(color.R * 255 + 0.5),
        math.floor(color.G * 255 + 0.5),
        math.floor(color.B * 255 + 0.5))
end

--------------------------------------------------------------------------
-- Theme manager (dark / light, animated, persisted)
--------------------------------------------------------------------------
local Theme = {}
Theme.__index = Theme

function Theme.new(isDark)
    local self = setmetatable({}, Theme)
    self.Dark = isDark ~= false
    self.Bindings = setmetatable({}, { __mode = "k" })
    self._listeners = {}
    return self
end

function Theme:Palette()
    return self.Dark and PALETTES.dark or PALETTES.light
end

function Theme:Get(role)
    return self:Palette()[role]
end

local function resolve(theme, value)
    if type(value) == "function" then return value(theme) end
    return theme:Palette()[value]
end

-- map: { PropertyName = "paletteRole" | function(theme) -> value }
function Theme:Bind(inst, map)
    local existing = self.Bindings[inst]
    if not existing then
        existing = {}
        self.Bindings[inst] = existing
    end
    for prop, role in pairs(map) do
        existing[prop] = role
        local value = resolve(self, role)
        if value ~= nil then inst[prop] = value end
    end
    return inst
end

function Theme:Apply(inst, animate)
    local map = self.Bindings[inst]
    if not map then return end
    local goals = {}
    for prop, role in pairs(map) do
        local value = resolve(self, role)
        if value ~= nil then goals[prop] = value end
    end
    if animate then
        tween(inst, typeof(animate) == "TweenInfo" and animate or QUAD_OUT_03, goals)
    else
        for prop, value in pairs(goals) do inst[prop] = value end
    end
end

function Theme:OnChanged(fn)
    table.insert(self._listeners, fn)
    return fn
end

function Theme:Set(isDark, animate)
    isDark = isDark and true or false
    if self.Dark == isDark then return end
    self.Dark = isDark
    for inst in pairs(self.Bindings) do
        if inst.Parent then
            self:Apply(inst, animate ~= false)
        else
            self.Bindings[inst] = nil
        end
    end
    for _, fn in ipairs(self._listeners) do
        task.spawn(fn, isDark)
    end
end

--------------------------------------------------------------------------
-- Library / classes
--------------------------------------------------------------------------
local Library = { Version = "1.0.0", Icons = ICONS, Windows = {} }
Library.__index = Library

local Window  = {}; Window.__index  = Window
local Tab     = {}; Tab.__index     = Tab
local Section = {}; Section.__index = Section

--------------------------------------------------------------------------
-- Internal primitives shared by every component
--------------------------------------------------------------------------

-- Plain themed text label.  role: "primaryText" | "secondaryText"
local function makeLabel(theme, parent, props, role)
    props = props or {}
    local label = create("TextLabel", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        FontFace = mainFont(props.Weight),
        TextSize = props.TextSize or 14,
        TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left,
        TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Top,
        TextWrapped = props.TextWrapped or false,
        Text = props.Text or "",
        Size = props.Size or UDim2.new(1, 0, 0, 16),
        Position = props.Position or UDim2.new(),
        AnchorPoint = props.AnchorPoint or Vector2.zero,
        Name = props.Name or "label",
        ZIndex = props.ZIndex or 1,
        RichText = props.RichText or false,
    }, parent)
    theme:Bind(label, { TextColor3 = role or "primaryText" })
    return label
end

local function makeIcon(theme, parent, image, size, position, role, anchor)
    local icon = create("ImageLabel", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Image = image or "",
        Size = size or UDim2.fromOffset(15, 15),
        Position = position or UDim2.new(),
        AnchorPoint = anchor or Vector2.zero,
        Name = "ImageLabel",
    }, parent)
    theme:Bind(icon, { ImageColor3 = role or "primaryIcon" })
    return icon
end

--[[
    Pill button: [icon] Text   (text is right aligned and carries two trailing
    spaces, exactly like the original).  Width is automatic.  A pill without
    text becomes the 25x25 icon-only square used in the "movement" cards.

    opts:
        Text, Icon, Height (default 22), Name
        Bg / TextRole / IconRole   palette roles for the idle state
        HoverBg / HoverText        palette roles for hover (nil = no hover)
        Toggle = true              pill has an on/off state (SetOn)
        OnBg / OnText              palette roles used while "on"
        IconPad / IconX            left padding reserved for the icon / icon x
]]
local function makePill(theme, parent, opts)
    local hasIcon  = opts.Icon ~= nil and opts.Icon ~= ""
    local iconOnly = hasIcon and (opts.Text == nil or opts.Text == "")
    local pad      = opts.IconPad or 25

    local btn = create("TextButton", {
        Name = opts.Name or "pill",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        FontFace = mainFont(),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right,
        Text = iconOnly and "" or ((opts.Text or "") .. "  "),
        LayoutOrder = opts.LayoutOrder or 0,
    }, parent)
    if iconOnly then
        btn.Size = UDim2.fromOffset(25, opts.Height or 25)
    else
        btn.Size = UDim2.new(0, 0, 0, opts.Height or 22)
        btn.AutomaticSize = Enum.AutomaticSize.X
        padding(btn, 0, 0, 0, hasIcon and pad or 10)
    end
    corner(btn)

    local icon
    if hasIcon then
        icon = create("ImageLabel", {
            Name = "ImageLabel",
            BackgroundTransparency = 1,
            Image = opts.Icon,
            Size = UDim2.fromOffset(15, 15),
        }, btn)
        if iconOnly then
            icon.AnchorPoint = Vector2.new(0.5, 0.5)
            icon.Position = UDim2.fromScale(0.5, 0.5)
        else
            -- UIPadding shifts child offsets, so compensate to keep the icon at x
            icon.AnchorPoint = Vector2.new(0, 0.5)
            icon.Position = UDim2.new(0, (opts.IconX or 5) - pad, 0.5, 0)
        end
    end

    local state = { hover = false, on = false }
    local bgRole    = opts.Bg or "controlBg"
    local textRole  = opts.TextRole or "primaryText"
    local iconRole  = opts.IconRole or "primaryIcon"
    local hoverBg   = opts.HoverBg
    local hoverText = opts.HoverText or textRole
    local onBg      = opts.OnBg or "toggleOnBg"
    local onText    = opts.OnText or "toggleOnText"

    local function bg(t)
        if opts.Toggle and state.on then return t:Get(onBg) end
        if state.hover and hoverBg then return t:Get(hoverBg) end
        return t:Get(bgRole)
    end
    local function fg(t)
        if opts.Toggle and state.on then return t:Get(onText) end
        if state.hover and hoverBg then return t:Get(hoverText) end
        return t:Get(textRole)
    end
    local function ic(t)
        if opts.Toggle and state.on then return t:Get(onText) end
        if state.hover and hoverBg then return t:Get(hoverText) end
        return t:Get(iconRole)
    end

    theme:Bind(btn, { BackgroundColor3 = bg, TextColor3 = fg })
    if icon then theme:Bind(icon, { ImageColor3 = ic }) end

    local function refresh(info)
        theme:Apply(btn, info)
        if icon then theme:Apply(icon, info) end
    end

    if hoverBg then
        btn.MouseEnter:Connect(function() state.hover = true;  refresh(QUAD_OUT_02) end)
        btn.MouseLeave:Connect(function() state.hover = false; refresh(QUAD_OUT_02) end)
    end

    local pill = { Instance = btn, Icon = icon, State = state }
    function pill:SetOn(on, info)
        state.on = on and true or false
        refresh(info or false)
    end
    function pill:SetText(text) btn.Text = text .. "  " end
    return pill
end

-- Make `frame` draggable (the original drags the whole window)
local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos = false, nil, nil

    handle.InputBegan:Connect(function(input)
        if isPress(input) then
            if frame:GetAttribute("IsDraggingSlider") then return end
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and isMove(input) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--------------------------------------------------------------------------
-- Window
--------------------------------------------------------------------------
function Library:CreateWindow(opts)
    opts = opts or {}
    local self = setmetatable({}, Window)

    local name     = opts.Name  or "zeroui"
    local title    = opts.Title or "zerohub.cc"
    local isDark   = opts.Dark ~= false
    local themeFile = opts.ThemeFile
    if themeFile == nil then themeFile = name .. "_theme.txt" end

    -- restore saved theme (exploit filesystem)
    if themeFile and type(isfile) == "function" and type(readfile) == "function" then
        local ok, exists = pcall(isfile, themeFile)
        if ok and exists then
            local ok2, saved = pcall(readfile, themeFile)
            if ok2 and type(saved) == "string" then
                saved = saved:match("^%s*(.-)%s*$")
                if saved == "light" then isDark = false
                elseif saved == "dark" then isDark = true end
            end
        end
    end

    local theme = Theme.new(isDark)
    self.Theme = theme
    self.Options = opts
    self.Tabs = {}
    self.TabIndex = {}
    self.CurrentTab = nil
    self._connections = {}
    self._notifications = {}
    self._sidebarOpen = false
    self._sidebarBusy = false
    self._switching = false

    ----------------------------------------------------------------- gui
    local parent = getGuiParent()
    local old = parent:FindFirstChild(name)
    if old then old:Destroy() end

    local gui = create("ScreenGui", {
        Name = name,
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 10000000,
    })
    pcall(function() gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets end)
    protectGui(gui)
    gui.Parent = parent
    self.Gui = gui

    local interface = create("Folder", { Name = "interface" }, gui)
    self.Interface = interface

    ----------------------------------------------------------------- loader
    local loader
    if opts.Loader then
        loader = create("Frame", {
            Name = "loader",
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.fromOffset(339, 194),
            Position = UDim2.fromScale(0.5, 0.5),
        }, interface)
        corner(loader)
        theme:Bind(loader, { BackgroundColor3 = "windowBg" })

        local bar = create("Frame", {
            Name = "loadingbar",
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.fromOffset(312, 1),
            Position = UDim2.new(0.5, 0, 0.94267, 0),
            BackgroundColor3 = rgb(51, 51, 51),
        }, loader)
        corner(bar, UDim.new(1, 0))
        local progress = create("Frame", {
            Name = "loadingbarprogress",
            BorderSizePixel = 0,
            Size = UDim2.new(0, 100, 1, 0),
        }, bar)
        theme:Bind(progress, { BackgroundColor3 = "sliderFill" })

        local label = create("TextLabel", {
            BorderSizePixel = 0,
            TextSize = 20,
            FontFace = mainFont(Enum.FontWeight.Bold),
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.fromOffset(200, 50),
            Text = opts.LoaderText or title,
            Position = UDim2.fromScale(0.5, 0.5),
        }, loader)
        theme:Bind(label, { TextColor3 = "primaryText" })

        -- looping bar animation (0.5s / 0.3s cycles, same as the original)
        task.spawn(function()
            local barWidth = 312
            progress.Size = UDim2.new(0, 0, 1, 0)
            local function cycle(duration)
                local info = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                local t1 = tween(progress, info, { Size = UDim2.new(0, barWidth, 1, 0), Position = UDim2.new() })
                t1.Completed:Wait()
                local t2 = tween(progress, info, { Size = UDim2.new(0, 0, 1, 0), Position = UDim2.new(0, barWidth, 0, 0) })
                t2.Completed:Wait()
                progress.Position = UDim2.new()
            end
            while loader and loader.Parent and loader.Visible do
                cycle(0.5)
                if not (loader and loader.Parent and loader.Visible) then break end
                cycle(0.3)
            end
        end)
    end
    self.Loader = loader

    ----------------------------------------------------------------- main
    local W, H = WINDOW_W, WINDOW_H
    local main = create("Frame", {
        Name = "main",
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        ClipsDescendants = true,
        Size = UDim2.fromOffset(W, H),
        Position = UDim2.fromScale(0.5, 0.5),
        Visible = not loader,
    }, interface)
    corner(main)
    shadow(main)
    theme:Bind(main, { BackgroundColor3 = "windowBg" })
    self.Main = main

    local wallpaper = create("ImageLabel", {
        Name = "wallpaper",
        ZIndex = -1,
        ScaleType = Enum.ScaleType.Crop,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Image = opts.Wallpaper or "",
    }, main)
    self.Wallpaper = wallpaper

    -- title bar -----------------------------------------------------------
    local titlebar = create("Frame", {
        Name = "titlebar",
        ZIndex = 5,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(W, 35),
    }, main)
    self.Titlebar = titlebar

    local function titleButton(nm, image, pos)
        local b = create("ImageButton", {
            Name = nm,
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0, 0.5),
            Image = image,
            Size = UDim2.fromOffset(20, 20),
            Position = pos,
        }, titlebar)
        theme:Bind(b, { ImageColor3 = "primaryIcon" })
        return b
    end

    local menuButton     = titleButton("menu",     opts.MenuIcon or ICONS.menu, UDim2.new(0.02083, 0, 0.5, 0))
    local minimizeButton = titleButton("minimize", ICONS.minimize,              UDim2.new(0.87083, 0, 0.5, 0))
    local closeButton    = titleButton("close",    ICONS.close,                 UDim2.new(0.93958, 0, 0.5, 0))

    self.TitleLabel = makeLabel(theme, titlebar, {
        Name = "windowtitle", Text = title, TextSize = 16,
        Size = UDim2.fromOffset(158, 14), Position = UDim2.new(0.08333, 0, 0.25, 0),
    }, "primaryText")

    -- tab container -------------------------------------------------------
    self.TabsFolder = create("Folder", { Name = "tabs" }, main)

    ----------------------------------------------------------------- open (minimised) button
    local openButton = create("ImageButton", {
        Name = "open",
        Visible = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0, 1),
        Image = opts.MenuIcon or ICONS.menu,
        Size = UDim2.fromOffset(50, 50),
        Position = UDim2.new(0, 0, 1, 0),
    }, interface)
    theme:Bind(openButton, { ImageColor3 = "primaryIcon" })
    makeDraggable(openButton)
    self.OpenButton = openButton

    minimizeButton.MouseButton1Click:Connect(function()
        main.Visible = false
        openButton.Visible = true
    end)
    openButton.MouseButton1Click:Connect(function()
        main.Visible = true
        openButton.Visible = false
    end)
    closeButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)

    if opts.Draggable ~= false then
        makeDraggable(main)
    end

    if opts.ToggleKey then
        table.insert(self._connections, UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == opts.ToggleKey then
                local show = not main.Visible
                main.Visible = show
                openButton.Visible = false
            end
        end))
    end

    ----------------------------------------------------------------- sidebar drawer
    self:_buildSidebar(menuButton)

    ----------------------------------------------------------------- notifications
    self:_buildNotifications()

    ----------------------------------------------------------------- click sound
    if opts.ClickSound ~= false then
        local sound = create("Sound", {
            Name = "UIClickSound", SoundId = CLICK_SOUND_ID, Volume = 1,
        }, gui)
        local hooked = {}
        local function hook(d)
            if d:IsA("GuiButton") and not hooked[d] then
                hooked[d] = true
                d.Activated:Connect(function() sound:Play() end)
            end
        end
        for _, d in ipairs(gui:GetDescendants()) do hook(d) end
        gui.DescendantAdded:Connect(hook)
        gui.DescendantRemoving:Connect(function(d) hooked[d] = nil end)
    end

    ----------------------------------------------------------------- theme persistence
    theme:OnChanged(function(dark)
        if themeFile and type(writefile) == "function" then
            pcall(writefile, themeFile, dark and "dark" or "light")
        end
        if opts.NotifyThemeChange ~= false then
            self:Notify("info", "Theme Changed", dark and "Dark theme enabled" or "Light theme enabled")
        end
    end)

    ----------------------------------------------------------------- loader -> main
    if loader then
        task.delay(opts.LoaderTime or 2, function()
            if not loader.Parent then return end
            loader.Visible = false
            main.Visible = true
            loader:Destroy()
            if opts.WelcomeNotification ~= false and opts.Welcome then
                self:Notify("success", opts.Welcome[1] or "Loaded", opts.Welcome[2] or "")
            end
        end)
    elseif opts.Welcome then
        task.defer(function()
            self:Notify("success", opts.Welcome[1] or "Loaded", opts.Welcome[2] or "")
        end)
    end

    table.insert(Library.Windows, self)
    return self
end

function Window:Destroy()
    for _, c in ipairs(self._connections) do pcall(function() c:Disconnect() end) end
    if self.Gui then self.Gui:Destroy() end
    local idx = table.find(Library.Windows, self)
    if idx then table.remove(Library.Windows, idx) end
end

function Window:SetTitle(text) self.TitleLabel.Text = text end
function Window:SetWallpaper(image) self.Wallpaper.Image = image or "" end

function Window:SetVisible(visible)
    self.Main.Visible = visible and true or false
    self.OpenButton.Visible = false
end

function Window:SetTheme(dark, animate)
    self.Theme:Set(dark, animate)
end

function Window:ToggleTheme()
    self.Theme:Set(not self.Theme.Dark, true)
end

function Window:IsDark() return self.Theme.Dark end

--------------------------------------------------------------------------
-- Sidebar drawer + tab carousel
--------------------------------------------------------------------------
function Window:_buildSidebar(menuButton)
    local theme, main = self.Theme, self.Main
    local H = WINDOW_H

    local sidebar = create("Frame", {
        Name = "sidebar",
        Visible = false,
        ZIndex = 10,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(WINDOW_W, H),
    }, main)
    corner(sidebar)
    self.Sidebar = sidebar

    local drawer = create("Frame", {
        Name = "main",
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(DRAWER_W, H),
        Position = UDim2.fromOffset(-DRAWER_W, 0),
    }, sidebar)
    corner(drawer)
    theme:Bind(drawer, { BackgroundColor3 = "windowBg" })
    self.Drawer = drawer

    local closeIcon = create("ImageButton", {
        Name = "close",
        BackgroundTransparency = 1, BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0, 0.5),
        Image = ICONS.close,
        Size = UDim2.fromOffset(20, 20),
        Position = UDim2.new(0.05309, 0, 0.05987, 0),
    }, drawer)
    theme:Bind(closeIcon, { ImageColor3 = "primaryIcon" })

    makeLabel(theme, drawer, {
        Name = "sidebartitle", Text = self.Options.SidebarTitle or "Menu", TextSize = 16,
        Size = UDim2.fromOffset(131, 26), Position = UDim2.new(0.2043, 0, 0.01618, 0),
    }, "primaryText")

    local function separator(y)
        local s = create("Frame", {
            Name = "separator",
            BorderSizePixel = 0,
            BackgroundTransparency = 0.5,
            AnchorPoint = Vector2.new(0.5, 0),
            Size = UDim2.fromOffset(170, 1),
            Position = UDim2.new(0.5, 0, y, 0),
        }, drawer)
        theme:Bind(s, { BackgroundColor3 = "separator" })
        return s
    end
    separator(0.8)
    separator(0.115)

    self.TabsHolder = create("ScrollingFrame", {
        Name = "tabsholder",
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.fromOffset(168, 203),
        Position = UDim2.new(0.05376, 0, 0.135, 0),
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
    }, drawer)
    create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, self.TabsHolder)

    self.SidebarBottom = create("Frame", {
        Name = "bottom",
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.fromOffset(168, 51),
        Position = UDim2.new(0.05376, 0, 0.81965, 0),
    }, drawer)
    create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, self.SidebarBottom)

    -- clock / date (outside the drawer, fades in with it)
    local clock = makeLabel(theme, sidebar, {
        Name = "clock", Text = os.date("%H:%M"), TextSize = 25,
        TextXAlignment = Enum.TextXAlignment.Right, TextYAlignment = Enum.TextYAlignment.Bottom,
        Size = UDim2.fromOffset(200, 50), Position = UDim2.new(0.54167, 0, 0.74757, 0),
    }, "primaryText")
    local date = makeLabel(theme, sidebar, {
        Name = "date", Text = string.lower(os.date("%d %B %Y")), TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Right, TextYAlignment = Enum.TextYAlignment.Bottom,
        Size = UDim2.fromOffset(200, 50), Position = UDim2.new(0.54167, 0, 0.78317, 0),
    }, "secondaryText")
    clock.TextTransparency, date.TextTransparency = 1, 1

    task.spawn(function()
        while sidebar.Parent do
            clock.Text = os.date("%H:%M")
            date.Text = string.lower(os.date("%d %B %Y"))
            task.wait(1)
        end
    end)

    -- invisible backdrop button that closes the drawer
    local backdrop = create("TextButton", {
        Name = "close",
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Text = "",
        Size = UDim2.fromOffset(293, 308),
        Position = UDim2.new(0.38958, 0, 0.00324, 0),
    }, sidebar)

    local function openSidebar()
        if self._sidebarOpen or self._sidebarBusy then return end
        self._sidebarBusy, self._sidebarOpen = true, true
        local width = drawer.AbsoluteSize.X > 0 and drawer.AbsoluteSize.X or DRAWER_W
        sidebar.Visible = true
        sidebar.BackgroundTransparency = 1
        drawer.Position = UDim2.fromOffset(-width, 0)
        clock.TextTransparency, date.TextTransparency = 1, 1
        local info = TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
        tween(drawer, info, { Position = UDim2.new() })
        tween(sidebar, info, { BackgroundTransparency = 0.2 })
        tween(clock, info, { TextTransparency = 0 })
        tween(date, info, { TextTransparency = 0 })
        task.delay(0.3, function() self._sidebarBusy = false end)
    end

    local function closeSidebar()
        if not self._sidebarOpen or self._sidebarBusy then return end
        self._sidebarBusy, self._sidebarOpen = true, false
        local width = drawer.AbsoluteSize.X > 0 and drawer.AbsoluteSize.X or DRAWER_W
        local info = TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
        tween(drawer, info, { Position = UDim2.fromOffset(-width, 0) })
        tween(sidebar, info, { BackgroundTransparency = 1 })
        tween(clock, info, { TextTransparency = 1 })
        tween(date, info, { TextTransparency = 1 })
        task.delay(0.25, function()
            if not self._sidebarOpen then sidebar.Visible = false end
            self._sidebarBusy = false
        end)
    end

    self.OpenSidebar, self.CloseSidebar = openSidebar, closeSidebar
    function self:ToggleSidebar()
        if self._sidebarOpen then closeSidebar() else openSidebar() end
    end

    menuButton.MouseButton1Click:Connect(function() self:ToggleSidebar() end)
    closeIcon.MouseButton1Click:Connect(closeSidebar)
    backdrop.MouseButton1Click:Connect(closeSidebar)
end

-- Extra quick-action rows at the bottom of the drawer (Infinite Yield / Respawn ...)
function Window:AddSidebarAction(opts)
    local theme = self.Theme
    local btn = create("TextButton", {
        Name = opts.Name or opts.Text,
        AutoButtonColor = false,
        BackgroundTransparency = 1, BorderSizePixel = 0,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 14,
        FontFace = mainFont(),
        Size = UDim2.new(1, 0, 0, 25),
        Text = "       " .. (opts.Text or opts.Name or ""),
    }, self.SidebarBottom)
    local icon = create("ImageLabel", {
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Image = opts.Icon or "",
        Size = UDim2.fromOffset(15, 15),
        Position = UDim2.new(0, 0, 0.24, 0),
    }, btn)

    local hover = false
    theme:Bind(btn,  { TextColor3  = function(t) return hover and t:Get("primaryText") or t:Get("secondaryText") end })
    theme:Bind(icon, { ImageColor3 = function(t) return hover and t:Get("primaryIcon") or t:Get("secondaryIcon") end })
    btn.MouseEnter:Connect(function() hover = true;  theme:Apply(btn, QUAD_OUT_02); theme:Apply(icon, QUAD_OUT_02) end)
    btn.MouseLeave:Connect(function() hover = false; theme:Apply(btn, QUAD_OUT_02); theme:Apply(icon, QUAD_OUT_02) end)
    btn.MouseButton1Click:Connect(function()
        self.CloseSidebar()
        if opts.Callback then task.spawn(opts.Callback) end
    end)
    return btn
end

function Window:_updateTabHighlights()
    for _, tab in ipairs(self.Tabs) do
        tab._active = (tab == self.CurrentTab)
        self.Theme:Apply(tab.Button, QUAD_OUT_02)
        if tab.ButtonIcon then self.Theme:Apply(tab.ButtonIcon, QUAD_OUT_02) end
    end
end

-- Carousel scrolling between tabs (identical to the original)
function Window:SelectTab(target, instant)
    if type(target) == "string" then target = self.TabIndex[target] end
    if not target or target == self.CurrentTab then return end

    if instant or not self.CurrentTab then
        for _, tab in ipairs(self.Tabs) do tab.Frame.Visible = (tab == target) end
        self.CurrentTab = target
        self:_updateTabHighlights()
        return
    end
    if self._switching then return end

    local startIndex  = table.find(self.Tabs, self.CurrentTab)
    local targetIndex = table.find(self.Tabs, target)
    if not startIndex or not targetIndex then return end

    self._switching = true
    self.CurrentTab = target
    self:_updateTabHighlights()

    local minIndex, maxIndex = math.min(startIndex, targetIndex), math.max(startIndex, targetIndex)
    local height = self.Main.AbsoluteSize.Y > 0 and self.Main.AbsoluteSize.Y or WINDOW_H
    local duration = math.clamp(0.35 + (math.abs(targetIndex - startIndex) - 1) * 0.05, 0.35, 0.55)
    local info = TweenInfo.new(duration, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

    for i = minIndex, maxIndex do
        local frame = self.Tabs[i].Frame
        frame.Position = UDim2.fromOffset(0, (i - startIndex) * height)
        frame.Visible = true
        tween(frame, info, { Position = UDim2.fromOffset(0, (i - targetIndex) * height) })
    end

    task.delay(duration, function()
        for i = minIndex, maxIndex do
            local frame = self.Tabs[i].Frame
            if i ~= targetIndex then frame.Visible = false end
            frame.Position = UDim2.new()
        end
        self._switching = false
    end)
end

--[[
    Window:AddTab({
        Name   = "Universal",
        Icon   = "rbxassetid://10723404337",
        Layout = "Grid" | "List" | "Free",     -- how Tab:AddSection() arranges cards
        Header = false,                         -- true -> icon button in the drawer header (settings style)
    })
]]
function Window:AddTab(opts)
    local theme = self.Theme
    local name = opts.Name or ("Tab" .. (#self.Tabs + 1))
    local tab = setmetatable({}, Tab)
    tab.Window = self
    tab.Theme = theme
    tab.Name = name
    tab.Layout = opts.Layout or "List"
    tab.Options = opts

    tab.Frame = create("Frame", {
        Name = name,
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Visible = false,
    }, self.TabsFolder)

    tab.Body = tab:_makeBody(tab.Frame, tab.Layout)

    -- sidebar button -------------------------------------------------------
    local hover = false
    local function textColor(t)
        if tab._active or hover then return t:Get("primaryText") end
        return t:Get("secondaryText")
    end
    local function iconColor(t)
        if tab._active or hover then return t:Get("primaryIcon") end
        return t:Get("secondaryIcon")
    end

    if opts.Header then
        local b = create("ImageButton", {
            Name = name,
            BackgroundTransparency = 1, BorderSizePixel = 0,
            Image = opts.Icon or "",
            Size = UDim2.fromOffset(17, 17),
            Position = UDim2.new(0.86559, 0, 0.03236, 0),
        }, self.Drawer)
        theme:Bind(b, { ImageColor3 = iconColor })
        tab.Button = b
        tab.ButtonIcon = nil
        b.MouseEnter:Connect(function() hover = true;  theme:Apply(b, QUAD_OUT_02) end)
        b.MouseLeave:Connect(function() hover = false; theme:Apply(b, QUAD_OUT_02) end)
    else
        local b = create("TextButton", {
            Name = name,
            AutoButtonColor = false,
            BackgroundTransparency = 1, BorderSizePixel = 0,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 14,
            FontFace = mainFont(),
            Size = UDim2.new(1, 0, 0, 25),
            Text = "       " .. name,
            LayoutOrder = #self.Tabs + 1,
        }, self.TabsHolder)
        local icon = create("ImageLabel", {
            BackgroundTransparency = 1, BorderSizePixel = 0,
            Image = opts.Icon or "",
            Size = UDim2.fromOffset(15, 15),
            Position = UDim2.new(0, 0, 0.24, 0),
        }, b)
        theme:Bind(b,    { TextColor3  = textColor })
        theme:Bind(icon, { ImageColor3 = iconColor })
        tab.Button, tab.ButtonIcon = b, icon
        b.MouseEnter:Connect(function() hover = true;  theme:Apply(b, QUAD_OUT_02); theme:Apply(icon, QUAD_OUT_02) end)
        b.MouseLeave:Connect(function() hover = false; theme:Apply(b, QUAD_OUT_02); theme:Apply(icon, QUAD_OUT_02) end)
    end

    tab.Button.MouseButton1Click:Connect(function()
        self.CloseSidebar()
        self:SelectTab(tab)
    end)

    table.insert(self.Tabs, tab)
    self.TabIndex[name] = tab

    if #self.Tabs == 1 or opts.Default then
        self:SelectTab(tab, true)
    end
    return tab
end

--------------------------------------------------------------------------
-- Toast notifications
--------------------------------------------------------------------------
local NOTIFY_TYPES = {
    success = ICONS.success,
    warning = ICONS.warning,
    info    = ICONS.info,
}

function Window:_buildNotifications()
    local theme, main = self.Theme, self.Main
    self.NotificationFolder = create("Folder", { Name = "notifications" }, main)
    self.NotifySound = create("Sound", {
        Name = "NotificationSound", SoundId = NOTIFY_SOUND_ID, Volume = 1,
    }, self.Gui)
end

local TOAST_DURATION, TOAST_W, TOAST_H = 5, 170, 45
local TOAST_GAP, TOAST_MARGIN_BOTTOM, TOAST_X, TOAST_MAX = 7, 10, 300, 5

function Window:Notify(typeName, title, description)
    if type(typeName) == "table" then
        local t = typeName
        typeName, title, description = t.Type or "info", t.Title, t.Description or t.Content
    end
    local icon = NOTIFY_TYPES[typeName]
    if not icon then typeName, icon = "info", NOTIFY_TYPES.info end

    local theme, main, folder = self.Theme, self.Main, self.NotificationFolder
    local active = self._notifications

    pcall(function() self.NotifySound:Play() end)

    local function mainHeight()
        return main.AbsoluteSize.Y > 0 and main.AbsoluteSize.Y or WINDOW_H
    end
    local function targetPosition(index)
        return UDim2.fromOffset(TOAST_X,
            mainHeight() - TOAST_MARGIN_BOTTOM - TOAST_H - (index - 1) * (TOAST_H + TOAST_GAP))
    end
    local function reflow()
        for i, n in ipairs(active) do
            n.frame:TweenPosition(targetPosition(i), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
        end
    end
    local function close(n, immediate)
        if n.closing then return end
        n.closing = true
        local idx = table.find(active, n)
        if idx then table.remove(active, idx) end
        reflow()
        if immediate then
            n.frame:Destroy()
        else
            local t = tween(n.frame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                Position = n.frame.Position + UDim2.fromOffset(TOAST_W + 60, 0),
                BackgroundTransparency = 1,
            })
            t.Completed:Once(function() n.frame:Destroy() end)
        end
    end

    if #active >= TOAST_MAX then close(active[#active], true) end

    local frame = create("Frame", {
        Name = typeName .. "notification",
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(TOAST_W, TOAST_H),
    }, nil)
    corner(frame)
    shadow(frame)
    theme:Bind(frame, { BackgroundColor3 = "cardBg" })

    local ic = create("ImageLabel", {
        Name = "icon", BackgroundTransparency = 1, BorderSizePixel = 0,
        Image = icon, Size = UDim2.fromOffset(25, 25),
        Position = UDim2.new(0.06471, 0, 0.22222, 0),
    }, frame)
    theme:Bind(ic, { ImageColor3 = "primaryIcon" })

    makeLabel(theme, frame, {
        Name = "title", Text = title or "", TextSize = 14,
        Size = UDim2.fromOffset(123, 15), Position = UDim2.new(0.24118, 0, 0.22222, 0),
    }, "primaryText")
    makeLabel(theme, frame, {
        Name = "desc", Text = description or "", TextSize = 12, TextWrapped = true,
        Size = UDim2.fromOffset(123, 12), Position = UDim2.new(0.24082, 0, 0.50222, 0),
    }, "secondaryText")

    local bar = create("Frame", {
        Name = "bar", BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.fromOffset(150, 3),
        Position = UDim2.new(0.5, 0, 0.92726, 0),
    }, frame)
    corner(bar, UDim.new(1, 0))
    theme:Bind(bar, { BackgroundColor3 = "trackBg" })
    local fill = create("Frame", {
        Name = "fill", BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
    }, bar)
    corner(fill, UDim.new(1, 0))
    theme:Bind(fill, { BackgroundColor3 = "sliderFill" })

    local startX = main.AbsoluteSize.X > 0 and main.AbsoluteSize.X or WINDOW_W
    frame.Position = UDim2.fromOffset(startX + 10, targetPosition(1).Y.Offset)
    frame.Parent = folder

    local entry = { frame = frame, paused = false, elapsed = 0, closing = false }
    frame.MouseEnter:Connect(function() entry.paused = true end)
    frame.MouseLeave:Connect(function() entry.paused = false end)
    frame.InputBegan:Connect(function(input)
        if isPress(input) then close(entry, false) end
    end)

    table.insert(active, 1, entry)
    for i = 2, #active do
        active[i].frame:TweenPosition(targetPosition(i), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
    end
    frame:TweenPosition(targetPosition(1), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.35, true)

    task.spawn(function()
        while frame.Parent and not entry.closing do
            local dt = RunService.RenderStepped:Wait()
            if not entry.paused then
                entry.elapsed += dt
                fill.Size = UDim2.fromScale(math.clamp(1 - entry.elapsed / TOAST_DURATION, 0, 1), 1)
                if entry.elapsed >= TOAST_DURATION then
                    close(entry, false)
                    break
                end
            end
        end
    end)
    return entry
end

--------------------------------------------------------------------------
-- Tab bodies
--------------------------------------------------------------------------
--[[
    Layouts
        "Grid"  scrolling 220x150 cards, 8px gaps (the "Universal" tab)
        "List"  scrolling column of full-width cards (the "Settings" tab)
        "Free"  plain frame, you position every section yourself
                (coordinates start right under the title bar, y = 0)
]]
function Tab:_makeBody(parent, layout, geometry)
    local theme = self.Theme
    geometry = geometry or {}

    if layout == "Free" then
        return create("Frame", {
            Name = "body",
            BackgroundTransparency = 1, BorderSizePixel = 0,
            Position = geometry.Position or UDim2.fromOffset(0, BODY_TOP),
            Size = geometry.Size or UDim2.new(1, 0, 1, -BODY_TOP),
        }, parent)
    end

    local scroller = create("ScrollingFrame", {
        Name = "body",
        Active = true,
        BackgroundTransparency = 1, BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarImageColor3 = rgb(101, 101, 101),
    }, parent)

    if layout == "Grid" then
        scroller.Position = geometry.Position or UDim2.fromOffset(10, BODY_TOP)
        scroller.Size = geometry.Size or UDim2.new(1, -19, 1, -BODY_TOP)
        scroller.ScrollBarThickness = 5
        create("UIGridLayout", {
            CellSize = UDim2.fromOffset(220, 150),
            CellPadding = UDim2.fromOffset(8, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, scroller)
    else -- "List"
        scroller.Position = geometry.Position or UDim2.fromOffset(9, BODY_TOP)
        scroller.Size = geometry.Size or UDim2.new(1, -18, 1, -BODY_TOP)
        scroller.ScrollBarThickness = 0
        create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, scroller)
    end
    return scroller
end

function Tab:_nextOrder()
    self._order = (self._order or 0) + 1
    return self._order
end

-- Create a card (rounded frame with the card colour) inside this tab / page
function Tab:_makeCard(opts)
    local theme = self.Theme
    local card = create("Frame", {
        Name = opts.Name or "card",
        BorderSizePixel = 0,
        LayoutOrder = self:_nextOrder(),
    }, self.Body)
    corner(card)
    theme:Bind(card, { BackgroundColor3 = opts.Bg or "cardBg" })
    if opts.Position then card.Position = opts.Position end
    if opts.Size then
        card.Size = opts.Size
    elseif self.Layout == "List" then
        card.Size = UDim2.new(1, 0, 0, 0)
        card.AutomaticSize = Enum.AutomaticSize.Y
    else
        card.Size = UDim2.fromOffset(220, 150)
    end
    return card
end

--------------------------------------------------------------------------
-- Section (a card that stacks components)
--------------------------------------------------------------------------
--[[
    Tab:AddSection({
        Title    = "Visual",              -- optional 20px heading
        Size     = UDim2,                 -- optional (ignored by "Grid")
        Position = UDim2,                 -- "Free" layout only
        Top      = 32,                    -- optional: where the content starts
    })
]]
function Tab:AddSection(opts)
    opts = opts or {}
    local theme = self.Theme
    local card = self:_makeCard({ Name = opts.Name or opts.Title or "section", Size = opts.Size, Position = opts.Position })

    local section = setmetatable({}, Section)
    section.Tab, section.Window, section.Theme = self, self.Window, theme
    section.Card = card
    section._order = 0

    local top = opts.Top or (opts.Title and 32 or 5)
    if opts.Title then
        section.TitleLabel = makeLabel(theme, card, {
            Name = "title", Text = opts.Title, TextSize = 20,
            Size = UDim2.new(1, -12, 0, 22), Position = UDim2.fromOffset(6, 6),
        }, "primaryText")
    end

    local auto = card.AutomaticSize == Enum.AutomaticSize.Y
    section.Content = create("Frame", {
        Name = "content",
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = UDim2.fromOffset(opts.Left or 6, top),
        Size = auto and UDim2.new(1, -14, 0, 0) or UDim2.new(1, -14, 1, -top),
        AutomaticSize = auto and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
    }, card)
    create("UIListLayout", {
        Padding = UDim.new(0, opts.Gap or 7),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, section.Content)
    if auto then padding(card, 0, 0, 8, 0) end

    return section
end

function Section:_nextOrder()
    self._order += 1
    return self._order
end

-- consecutive toggles / pills share one wrapping row
function Section:_flow()
    if self._flowFrame and self._flowFrame.Parent then return self._flowFrame end
    local flow = create("Frame", {
        Name = "buttons",
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = self:_nextOrder(),
    }, self.Content)
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Wraps = true,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, flow)
    self._flowFrame = flow
    return flow
end

function Section:_breakFlow() self._flowFrame = nil end

--------------------------------------------------------------------------
-- Components: Toggle / Button
--------------------------------------------------------------------------
--[[
    Section:AddToggle({ Text = "Fly", Icon = "rbxassetid://...", Default = false,
                        Height = 20, Callback = function(state) end })
    -> { Set(state, silent), Get(), Toggle(), Instance }
    Leave Text empty for the 25x25 icon-only square.
]]
function Section:AddToggle(opts)
    local theme = self.Theme
    local pill = makePill(theme, self:_flow(), {
        Name = opts.Name or opts.Text or "toggle",
        Text = opts.Text, Icon = opts.Icon,
        Height = opts.Height or ((opts.Text and opts.Text ~= "") and 20 or 25),
        Toggle = true,
        LayoutOrder = self:_nextOrder(),
    })
    local on = opts.Default and true or false
    pill:SetOn(on)

    local toggle = { Instance = pill.Instance }
    function toggle:Get() return on end
    function toggle:Set(state, silent)
        state = state and true or false
        if on == state then return end
        on = state
        pill:SetOn(on)
        if not silent and opts.Callback then task.spawn(opts.Callback, on) end
    end
    function toggle:Toggle() self:Set(not on) end

    pill.Instance.MouseButton1Click:Connect(function() toggle:Toggle() end)
    if on and opts.Callback and opts.FireDefault then task.spawn(opts.Callback, on) end
    return toggle
end

--[[
    Section:AddButton({ Text = "Copy", Icon = "...", Callback = fn,
                        Wide = false })   -- Wide: full-width centred 24px button
]]
function Section:AddButton(opts)
    local theme = self.Theme
    if opts.Wide then
        self:_breakFlow()
        local btn = create("TextButton", {
            Name = opts.Name or opts.Text or "button",
            AutoButtonColor = false, BorderSizePixel = 0,
            FontFace = mainFont(), TextSize = 14,
            Text = opts.Text or "",
            Size = UDim2.new(1, 0, 0, 24),
            LayoutOrder = self:_nextOrder(),
        }, self.Content)
        corner(btn)
        local hover = false
        theme:Bind(btn, {
            BackgroundColor3 = function(t) return hover and t:Get("hoverBg") or t:Get("controlBg") end,
            TextColor3 = "primaryText",
        })
        btn.MouseEnter:Connect(function() hover = true;  theme:Apply(btn, QUAD_OUT_02) end)
        btn.MouseLeave:Connect(function() hover = false; theme:Apply(btn, QUAD_OUT_02) end)
        btn.MouseButton1Click:Connect(function()
            if opts.Callback then task.spawn(opts.Callback) end
        end)
        return { Instance = btn }
    end

    local pill = makePill(theme, self:_flow(), {
        Name = opts.Name or opts.Text or "button",
        Text = opts.Text, Icon = opts.Icon,
        Height = opts.Height or 20,
        Bg = "controlBg", TextRole = "primaryText", IconRole = "primaryIcon",
        HoverBg = "hoverBg",
        LayoutOrder = self:_nextOrder(),
    })
    pill.Instance.MouseButton1Click:Connect(function()
        if opts.Callback then task.spawn(opts.Callback) end
    end)
    return { Instance = pill.Instance, SetText = function(_, t) pill:SetText(t) end }
end

--------------------------------------------------------------------------
-- Components: Slider
--------------------------------------------------------------------------
--[[
    Section:AddSlider({ Icon = "rbxassetid://12975608939", Min = 0, Max = 500,
                        Default = 16, Increment = 1, Suffix = "",
                        Callback = function(value) end })
    -> { Set(value, silent), Get(), Instance }
]]
function Section:AddSlider(opts)
    local theme, window = self.Theme, self.Window
    self:_breakFlow()

    local min, max = opts.Min or 0, opts.Max or 100
    local inc = opts.Increment or 1
    local suffix = opts.Suffix or ""
    local value = math.clamp(opts.Default or min, min, max)

    local frame = create("Frame", {
        Name = opts.Name or "slider",
        Active = true,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Size = UDim2.new(1, 0, 0, 32),
        LayoutOrder = self:_nextOrder(),
    }, self.Content)
    corner(frame)
    theme:Bind(frame, { BackgroundColor3 = "controlBg" })

    local filler = create("Frame", {
        Name = "filler", BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 1, 0),
    }, frame)
    corner(filler)
    theme:Bind(filler, { BackgroundColor3 = "sliderFill" })

    local valueLabel = makeLabel(theme, frame, {
        Name = "value", ZIndex = 2, TextSize = 14,
        TextYAlignment = Enum.TextYAlignment.Center,
        Size = UDim2.fromOffset(60, 32), Position = UDim2.fromOffset(30, 0),
    }, "secondaryText")

    local icon = create("ImageLabel", {
        Name = "icon", ZIndex = 2, BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0, 0.5),
        Image = opts.Icon or "",
        Size = UDim2.fromOffset(20, 20), Position = UDim2.new(0, 4, 0.5, 0),
    }, frame)
    theme:Bind(icon, { ImageColor3 = "secondaryIcon" })

    local function alphaOf(v) return max == min and 0 or (v - min) / (max - min) end
    local targetAlpha, currentAlpha = alphaOf(value), alphaOf(value)

    local function format(v)
        if inc >= 1 then return tostring(math.floor(v + 0.5)) .. suffix end
        local decimals = math.max(0, math.ceil(-math.log10(inc)))
        return string.format("%." .. decimals .. "f", v) .. suffix
    end
    valueLabel.Text = format(value)
    filler.Size = UDim2.new(currentAlpha, 0, 1, 0)

    local slider = { Instance = frame }
    local function commit(v, silent)
        v = math.clamp(math.floor((v - min) / inc + 0.5) * inc + min, min, max)
        if v == value and not silent then return end
        value = v
        targetAlpha = alphaOf(v)
        valueLabel.Text = format(v)
        if not silent and opts.Callback then task.spawn(opts.Callback, v) end
    end
    function slider:Get() return value end
    function slider:Set(v, silent) commit(v, silent) end

    -- smooth fill (exponential ease, same feel as the original)
    task.spawn(function()
        while frame.Parent do
            local dt = RunService.RenderStepped:Wait()
            currentAlpha += (targetAlpha - currentAlpha) * (1 - math.exp(-dt * 22))
            if math.abs(targetAlpha - currentAlpha) < 0.0005 then currentAlpha = targetAlpha end
            filler.Size = UDim2.new(currentAlpha, 0, 1, 0)
        end
    end)

    local dragging = false
    local function fromInput(input)
        local width = frame.AbsoluteSize.X
        if width <= 0 then return end
        local a = math.clamp((input.Position.X - frame.AbsolutePosition.X) / width, 0, 1)
        commit(min + (max - min) * a)
    end
    frame.InputBegan:Connect(function(input)
        if isPress(input) then
            dragging = true
            window.Main:SetAttribute("IsDraggingSlider", true)
            fromInput(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and isMove(input) then fromInput(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if dragging and isPress(input) then
            dragging = false
            window.Main:SetAttribute("IsDraggingSlider", nil)
        end
    end)

    return slider
end

--------------------------------------------------------------------------
-- Components: TextBox / Label / Separator
--------------------------------------------------------------------------
--[[
    Section:AddTextBox({ Placeholder = "example.txt", Default = "", Height = 25,
                         Callback = function(text, enterPressed) end })
]]
function Section:AddTextBox(opts)
    local theme = self.Theme
    self:_breakFlow()
    local holder = create("Frame", {
        Name = opts.Name or "textbox",
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, opts.Height or 25),
        LayoutOrder = self:_nextOrder(),
    }, self.Content)
    corner(holder)
    theme:Bind(holder, { BackgroundColor3 = "inputBg" })

    local box = create("TextBox", {
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ClearTextOnFocus = opts.ClearOnFocus or false,
        FontFace = mainFont(), TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        PlaceholderText = opts.Placeholder or "",
        Text = opts.Default or "",
        Size = UDim2.new(1, -16, 1, 0), Position = UDim2.fromOffset(8, 0),
    }, holder)
    theme:Bind(box, { TextColor3 = "primaryText", PlaceholderColor3 = "secondaryText" })

    box.FocusLost:Connect(function(enter)
        if opts.Callback then task.spawn(opts.Callback, box.Text, enter) end
    end)
    return { Instance = box, Get = function() return box.Text end, Set = function(_, t) box.Text = t end }
end

--[[
    Section:AddLabel({ Text = "...", Size = 14, Secondary = true })
    -> { Set(text), Instance }
]]
function Section:AddLabel(opts)
    if type(opts) == "string" then opts = { Text = opts } end
    local theme = self.Theme
    self:_breakFlow()
    local label = makeLabel(theme, self.Content, {
        Name = opts.Name or "label", Text = opts.Text or "",
        TextSize = opts.Size or 14, TextWrapped = true,
        RichText = opts.RichText,
        Size = UDim2.new(1, 0, 0, 0),
    }, (opts.Secondary == false) and "primaryText" or (opts.Role or "secondaryText"))
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.LayoutOrder = self:_nextOrder()
    return { Instance = label, Set = function(_, t) label.Text = t end }
end

function Section:AddSeparator()
    self:_breakFlow()
    local sep = create("Frame", {
        Name = "separator", BorderSizePixel = 0,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, 0, 0, 1),
        LayoutOrder = self:_nextOrder(),
    }, self.Content)
    self.Theme:Bind(sep, { BackgroundColor3 = "separator" })
    return sep
end

--------------------------------------------------------------------------
-- Setting card  (title + description + button, the "Customize / Server" rows)
--------------------------------------------------------------------------
--[[
    Tab:AddSettingCard({
        Title = "Theme", Description = "Switch between dark and light.",
        ButtonText = "Switch themes", ButtonIcon = "rbxassetid://...",
        Callback = function() end, Height = 87,
    })
    -> { Button, SetTitle(t), SetDescription(t), Instance }
]]
function Tab:AddSettingCard(opts)
    local theme = self.Theme
    local card = self:_makeCard({
        Name = opts.Title or "setting", Position = opts.Position,
        Size = opts.Size or UDim2.new(1, 0, 0, opts.Height or 87),
    })

    local title = makeLabel(theme, card, {
        Name = "title", Text = opts.Title or "", TextSize = 20,
        Size = UDim2.new(1, -22, 0, 22), Position = UDim2.fromOffset(11, 8),
    }, "primaryText")
    local desc = makeLabel(theme, card, {
        Name = "description", Text = opts.Description or "", TextSize = 14, TextWrapped = true,
        Size = UDim2.new(1, -22, 0, 26), Position = UDim2.fromOffset(11, 27),
    }, "secondaryText")

    local pill
    if opts.ButtonText then
        pill = makePill(theme, card, {
            Name = "button", Text = opts.ButtonText, Icon = opts.ButtonIcon,
            Height = 24, Bg = "controlBg", TextRole = "secondaryText", IconRole = "secondaryIcon",
            HoverBg = "hoverBg", HoverText = "primaryText",
        })
        pill.Instance.AnchorPoint = Vector2.new(1, 1)
        pill.Instance.Position = UDim2.new(1, -11, 1, -9)
        pill.Instance.MouseButton1Click:Connect(function()
            if opts.Callback then task.spawn(opts.Callback) end
        end)
    end

    return {
        Instance = card,
        Button = pill and pill.Instance,
        SetTitle = function(_, t) title.Text = t end,
        SetDescription = function(_, t) desc.Text = t end,
        SetButtonText = function(_, t) if pill then pill:SetText(t) end end,
    }
end

--------------------------------------------------------------------------
-- Search bar  (460x25 pill with a search icon on the right)
--------------------------------------------------------------------------
function Tab:AddSearchBar(opts)
    opts = opts or {}
    local theme = self.Theme
    local bar = self:_makeCard({
        Name = "searchbar",
        Position = opts.Position or UDim2.fromOffset(10, 1),
        Size = opts.Size or UDim2.fromOffset(460, 25),
    })
    shadow(bar)

    local box = create("TextBox", {
        Name = "TextBox",
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ClearTextOnFocus = false,
        FontFace = mainFont(), TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        PlaceholderText = opts.Placeholder or "Search",
        Text = "",
        Size = UDim2.new(1, -43, 1, 0), Position = UDim2.fromOffset(11, 0),
    }, bar)
    theme:Bind(box, { TextColor3 = "primaryText", PlaceholderColor3 = "secondaryText" })

    makeIcon(theme, bar, opts.Icon or ICONS.search,
        UDim2.fromOffset(15, 15), UDim2.new(1, -23, 0, 5), "secondaryIcon")

    box:GetPropertyChangedSignal("Text"):Connect(function()
        if opts.OnChanged then task.spawn(opts.OnChanged, box.Text) end
    end)
    box.FocusLost:Connect(function(enter)
        if enter and opts.OnEnter then task.spawn(opts.OnEnter, box.Text) end
    end)
    return { Instance = bar, TextBox = box, Get = function() return box.Text end }
end

--------------------------------------------------------------------------
-- Sub tabs (the "AI | Customize" pill bar with sliding pages)
--------------------------------------------------------------------------
--[[
    local sub = Tab:AddSubTabs({
        { Name = "AI",        Icon = "rbxassetid://..." },
        { Name = "Customize", Icon = "rbxassetid://..." },
    })
    sub.Pages.AI:AddSettingCard({...})
    sub:Select("Customize")
    (give the parent tab Layout = "Free")
]]
function Tab:AddSubTabs(items, opts)
    opts = opts or {}
    local theme = self.Theme
    local frame = self.Frame

    local bar = create("Frame", {
        Name = "top",
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.fromOffset(409, 33),
        Position = UDim2.fromOffset(9, BODY_TOP - 6),
    }, frame)
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    }, bar)

    local pageTop = BODY_TOP + 30
    local sub = { Pages = {}, Pills = {}, Order = {}, Current = nil, _busy = false }

    for index, item in ipairs(items) do
        local pill = makePill(theme, bar, {
            Name = item.Name, Text = item.Name, Icon = item.Icon,
            Height = 23, IconPad = 31, IconX = 7,
            Toggle = true, Bg = "pillInactiveBg", TextRole = "secondaryText", IconRole = "secondaryIcon",
            OnBg = "pillActiveBg", OnText = "primaryText",
            LayoutOrder = index,
        })

        local page = setmetatable({}, Tab)
        page.Window, page.Theme, page.Name = self.Window, theme, item.Name
        page.Layout = item.Layout or "List"
        page.Frame = frame
        page.Body = page:_makeBody(frame, page.Layout, {
            Position = UDim2.fromOffset(9, pageTop),
            Size = UDim2.new(1, -18, 1, -pageTop),
        })
        page.Body.Visible = false

        sub.Pages[item.Name] = page
        sub.Pills[item.Name] = pill
        table.insert(sub.Order, item.Name)

        pill.Instance.MouseButton1Click:Connect(function() sub:Select(item.Name) end)
    end

    function sub:Select(name, instant)
        if self.Current == name or not self.Pages[name] or self._busy then return end
        local old = self.Current
        self.Current = name
        for n, pill in pairs(self.Pills) do pill:SetOn(n == name, QUAD_OUT_035) end

        local new = self.Pages[name].Body
        if instant or not old then
            for n, p in pairs(self.Pages) do p.Body.Visible = (n == name) end
            return
        end

        self._busy = true
        local dir = (table.find(self.Order, name) > table.find(self.Order, old)) and 1 or -1
        local width = WINDOW_W
        local info = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        local oldBody = self.Pages[old].Body
        local home = new.Position
        new.Position = home + UDim2.fromOffset(width * dir, 0)
        new.Visible = true
        tween(new, info, { Position = home })
        local oldHome = oldBody.Position
        tween(oldBody, info, { Position = oldHome - UDim2.fromOffset(width * dir, 0) })
        task.delay(0.35, function()
            oldBody.Visible = false
            oldBody.Position = oldHome
            self._busy = false
        end)
    end

    sub:Select(opts.Default or items[1].Name, true)
    return sub
end

--------------------------------------------------------------------------
-- Home-page widgets: profile card, stat tiles, info card
--------------------------------------------------------------------------
--[[
    Tab:AddProfileCard({
        Position = UDim2.fromOffset(10, 1),          -- Free layout
        DisplayName = "...", UserId = 123,           -- defaults to LocalPlayer
    })
    Returns a Section (use AddToggle / AddSlider ...) with an extra
        :SetFooter({ Text = "Join Discord", Callback = fn })
]]
function Tab:AddProfileCard(opts)
    opts = opts or {}
    local theme = self.Theme
    local section = self:AddSection({
        Name = "profile",
        Size = opts.Size or UDim2.fromOffset(185, 265),
        Position = opts.Position or UDim2.fromOffset(10, 1),
        Top = 80, Left = 5, Gap = 7,
    })
    section.Content.Size = UDim2.new(1, -10, 0, 140)
    local card = section.Card

    local sep = create("Frame", {
        Name = "separator", BorderSizePixel = 0, BackgroundTransparency = 0.5,
        AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.fromOffset(170, 1), Position = UDim2.new(0.5, 0, 0.26792, 0),
    }, card)
    theme:Bind(sep, { BackgroundColor3 = "separator" })

    local pfp = create("ImageLabel", {
        Name = "pfp", BackgroundTransparency = 1, BorderSizePixel = 0,
        Image = ICONS.user,
        Size = UDim2.fromOffset(50, 50), Position = UDim2.new(0.03784, 0, 0.05, 0),
    }, card)
    corner(pfp, UDim.new(1, 0))
    theme:Bind(pfp, { BackgroundColor3 = "controlBg" })

    local userId = opts.UserId or (LocalPlayer and LocalPlayer.UserId) or 0
    if opts.Image then
        pfp.Image = opts.Image
    else
        task.spawn(function()
            local ok, thumb = pcall(Players.GetUserThumbnailAsync, Players, userId,
                Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            if ok and thumb and pfp.Parent then pfp.Image = thumb end
        end)
    end

    makeLabel(theme, card, {
        Name = "displayname", Text = opts.DisplayName or (LocalPlayer and LocalPlayer.DisplayName) or "Player",
        TextSize = 20, TextWrapped = true,
        Size = UDim2.fromOffset(111, 23), Position = UDim2.new(0.35676, 0, 0.07547, 0),
    }, "primaryText")
    makeLabel(theme, card, {
        Name = "userid", Text = tostring(opts.UserIdText or userId),
        TextSize = 14, TextWrapped = true,
        Size = UDim2.fromOffset(111, 16), Position = UDim2.new(0.35676, 0, 0.15094, 0),
    }, "secondaryText")

    function section:SetFooter(f)
        local line = create("Frame", {
            Name = "separator", BorderSizePixel = 0, BackgroundTransparency = 0.5,
            AnchorPoint = Vector2.new(0.5, 0),
            Size = UDim2.fromOffset(170, 1), Position = UDim2.new(0.5, 0, 0.86038, 0),
        }, card)
        theme:Bind(line, { BackgroundColor3 = "separator" })

        local btn = create("TextButton", {
            Name = "footer", AutoButtonColor = false, BorderSizePixel = 0,
            FontFace = mainFont(), TextSize = 14, Text = f.Text or "",
            Size = UDim2.fromOffset(170, 24), Position = UDim2.new(0.04054, 0, 0.885, 0),
        }, card)
        corner(btn)
        local hover = false
        theme:Bind(btn, {
            BackgroundColor3 = function(t) return hover and t:Get("hoverBg") or t:Get("controlBg") end,
            TextColor3 = "primaryText",
        })
        btn.MouseEnter:Connect(function() hover = true;  theme:Apply(btn, QUAD_OUT_02) end)
        btn.MouseLeave:Connect(function() hover = false; theme:Apply(btn, QUAD_OUT_02) end)
        btn.MouseButton1Click:Connect(function()
            if f.Callback then task.spawn(f.Callback) end
        end)
        return btn
    end

    return section
end

--[[
    Tab:AddStats({ {Value = "240", Label = "FPS"}, {Value = "50", Label = "ms"}, ... },
                 { Position = UDim2.fromOffset(204, 1) })
    -> { Set(index, value) }
]]
function Tab:AddStats(items, opts)
    opts = opts or {}
    local theme = self.Theme
    local card = self:_makeCard({
        Name = "stats",
        Size = opts.Size or UDim2.fromOffset(267, 72),
        Position = opts.Position or UDim2.fromOffset(204, 1),
    })
    create("UIGridLayout", {
        CellSize = UDim2.new(0, 89, 1, 0),
        CellPadding = UDim2.fromOffset(0, 0),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, card)

    local values = {}
    for i, item in ipairs(items) do
        local tile = create("Frame", {
            Name = item.Label or tostring(i),
            BackgroundTransparency = 1, BorderSizePixel = 0,
            LayoutOrder = i,
        }, card)
        values[i] = makeLabel(theme, tile, {
            Name = "value", Text = tostring(item.Value or ""), TextSize = 20,
            TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.new(1, 0, 0, 50), Position = UDim2.new(0.5, 0, 0.43056, 0),
        }, "primaryText")
        makeLabel(theme, tile, {
            Name = "label", Text = item.Label or "", TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.new(1, 0, 0, 15), Position = UDim2.new(0.5, 0, 0.65972, 0),
        }, "secondaryText")
    end

    return {
        Instance = card,
        Set = function(_, index, value)
            if values[index] then values[index].Text = tostring(value) end
        end,
    }
end

--[[
    Tab:AddInfoCard({ Title = "31 october 2026", Text = "Changelog ...",
                      Position = UDim2.fromOffset(204, 81) })
]]
function Tab:AddInfoCard(opts)
    opts = opts or {}
    local theme = self.Theme
    local card = self:_makeCard({
        Name = "info",
        Size = opts.Size or UDim2.fromOffset(267, 185),
        Position = opts.Position or UDim2.fromOffset(204, 81),
    })
    local title = makeLabel(theme, card, {
        Name = "title", Text = opts.Title or "", TextSize = 20,
        Size = UDim2.fromOffset(200, 25), Position = UDim2.new(0.02996, 0, 0.04865, 0),
    }, "primaryText")
    local text = makeLabel(theme, card, {
        Name = "text", Text = opts.Text or "", TextSize = 14, TextWrapped = true,
        RichText = opts.RichText,
        Size = UDim2.new(0.93191, 0, 0.78108, 0), Position = UDim2.new(0.02996, 0, 0.18378, 0),
    }, "secondaryText")
    return {
        Instance = card,
        SetTitle = function(_, t) title.Text = t end,
        SetText = function(_, t) text.Text = t end,
    }
end

--------------------------------------------------------------------------
-- Script hub cards (460x150 cards with image / title / tags / Copy + Execute)
--------------------------------------------------------------------------
--[[
    local list = Tab:AddScriptList()           -- under a search bar in a "Free" tab
    list:AddScriptCard({
        Title = "Infinite Yield", Image = "rbxassetid://...", Likes = 1200,
        KeySystem = true, Verified = true,
        OnCopy = function() end, OnExecute = function() end,
    })
    list:Filter("yield")                       -- hides cards whose title doesn't match
]]
function Tab:AddScriptList(opts)
    opts = opts or {}
    local theme = self.Theme
    local scroller = create("ScrollingFrame", {
        Name = "scripts", Active = true,
        BackgroundTransparency = 1, BorderSizePixel = 0,
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = 0,
        Position = opts.Position or UDim2.fromOffset(10, 32),
        Size = opts.Size or UDim2.new(0, 460, 1, -32),
    }, self.Body)
    create("UIGridLayout", {
        CellSize = UDim2.new(1, 0, 0, 150),
        CellPadding = UDim2.fromOffset(5, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, scroller)

    local list = { Instance = scroller, Cards = {} }

    function list:AddScriptCard(c)
        local card = create("Frame", {
            Name = c.Title or "script", BorderSizePixel = 0,
            LayoutOrder = #self.Cards + 1,
        }, scroller)
        corner(card)
        theme:Bind(card, { BackgroundColor3 = "cardBg" })

        local img = create("ImageLabel", {
            Name = "image", BorderSizePixel = 0, ScaleType = Enum.ScaleType.Crop,
            Image = c.Image or "",
            Size = UDim2.fromOffset(236, 138), Position = UDim2.fromOffset(5, 6),
        }, card)
        corner(img)
        theme:Bind(img, { BackgroundColor3 = "controlBg" })

        makeLabel(theme, card, {
            Name = "title", Text = c.Title or "", TextSize = 20, TextWrapped = true,
            Size = UDim2.fromOffset(201, 71), Position = UDim2.fromOffset(250, 29),
        }, "primaryText")

        local tags = create("Frame", {
            Name = "tags", BackgroundTransparency = 1, BorderSizePixel = 0,
            Size = UDim2.fromOffset(148, 17), Position = UDim2.fromOffset(251, 8),
        }, card)
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder,
        }, tags)
        local function tag(text, bg, fg, order)
            local t = create("TextLabel", {
                BorderSizePixel = 0, BackgroundColor3 = bg, TextColor3 = fg,
                FontFace = mainFont(), TextSize = 12, Text = text,
                Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
                LayoutOrder = order,
            }, tags)
            corner(t)
            padding(t, 0, 5, 0, 5)
        end
        if c.KeySystem then tag("Key System", rgb(241, 178, 0), rgb(0, 0, 0), 1) end
        if c.Verified  then tag("Verified",   rgb(0, 146, 218), rgb(255, 255, 255), 2) end
        for i, extra in ipairs(c.Tags or {}) do
            tag(extra.Text, extra.Bg or rgb(60, 60, 60), extra.Fg or rgb(255, 255, 255), 2 + i)
        end

        if c.Likes ~= nil then
            makeIcon(theme, card, ICONS.likes, UDim2.fromOffset(10, 10), UDim2.fromOffset(250, 108), "secondaryIcon")
            makeLabel(theme, card, {
                Name = "likes", Text = tostring(c.Likes), TextSize = 12,
                Size = UDim2.fromOffset(184, 10), Position = UDim2.fromOffset(267, 108),
            }, "secondaryText")
        end

        local holder = create("Frame", {
            Name = "buttons", BackgroundTransparency = 1, BorderSizePixel = 0,
            AnchorPoint = Vector2.new(1, 1),
            Size = UDim2.fromOffset(200, 22), Position = UDim2.new(1, -3, 1, -5),
        }, card)
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder,
        }, holder)
        local function button(text, icon, order, callback)
            local pill = makePill(theme, holder, {
                Text = text, Icon = icon, Height = 22, LayoutOrder = order,
                Bg = "controlBg", TextRole = "secondaryText", IconRole = "secondaryIcon",
                HoverBg = "hoverBg", HoverText = "primaryText",
            })
            pill.Instance.MouseButton1Click:Connect(function()
                if callback then task.spawn(callback) end
            end)
        end
        button("Copy", ICONS.copy, 1, c.OnCopy)
        button("Execute", ICONS.play, 2, c.OnExecute)

        card:SetAttribute("SearchText", string.lower(c.Title or ""))
        table.insert(self.Cards, card)
        return card
    end

    function list:Filter(query)
        query = string.lower(query or "")
        for _, card in ipairs(self.Cards) do
            card.Visible = query == "" or string.find(card:GetAttribute("SearchText") or "", query, 1, true) ~= nil
        end
    end

    function list:Clear()
        for _, card in ipairs(self.Cards) do card:Destroy() end
        table.clear(self.Cards)
    end

    return list
end

--------------------------------------------------------------------------
-- Console  (log viewer + Clear / Save / Copy, with the "Save in workspace" dialog)
--------------------------------------------------------------------------
local LOG_COLORS = {
    dark = {
        [Enum.MessageType.MessageOutput]  = "FFFFFF",
        [Enum.MessageType.MessageInfo]    = "84D6F7",
        [Enum.MessageType.MessageWarning] = "FFFF00",
        [Enum.MessageType.MessageError]   = "FF0000",
    },
    light = {
        [Enum.MessageType.MessageOutput]  = "111827",
        [Enum.MessageType.MessageInfo]    = "0284C7",
        [Enum.MessageType.MessageWarning] = "D97706",
        [Enum.MessageType.MessageError]   = "DC2626",
    },
}

--[[
    local console = Tab:AddConsole({ CaptureOutput = true })   -- hooks LogService
    console:Log("hello", Enum.MessageType.MessageInfo)
    console:Clear() / console:Copy() / console:Save("console.txt")
]]
function Tab:AddConsole(opts)
    opts = opts or {}
    local theme, window = self.Theme, self.Window
    local console = { Entries = {}, Max = opts.MaxEntries or 500 }

    local holder = self:_makeCard({
        Name = "consoleholder",
        Position = opts.Position or UDim2.fromOffset(10, 0),
        Size = opts.Size or UDim2.fromOffset(461, 241),
    })

    local scroller = create("ScrollingFrame", {
        Name = "c", Active = true,
        BackgroundTransparency = 1, BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0.97121, 0, 0.93, 0), Position = UDim2.fromScale(0.5, 0.5),
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.XY,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = rgb(101, 101, 101),
    }, holder)

    local view = create("TextBox", {
        Name = "yesc",
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ClearTextOnFocus = false, TextEditable = false, MultiLine = true,
        RichText = true, TextWrapped = false,
        FontFace = monoFont(), TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.XY,
        Text = "",
    }, scroller)
    theme:Bind(view, { TextColor3 = "primaryText" })

    local function render()
        if #console.Entries == 0 then
            view.Text = '<font color="#' .. toHex(theme:Get("secondaryText")) .. '">No console logs yet.</font>'
            return
        end
        local palette = theme.Dark and LOG_COLORS.dark or LOG_COLORS.light
        local lines = table.create(#console.Entries)
        for i, e in ipairs(console.Entries) do
            lines[i] = string.format('<font color="#%s">%s</font>',
                palette[e.Type] or palette[Enum.MessageType.MessageOutput], escapeRich(e.Text))
        end
        view.Text = table.concat(lines, "\n")
    end
    render()
    theme:OnChanged(function() if view.Parent then render() end end)

    function console:Log(text, messageType)
        table.insert(self.Entries, { Text = tostring(text), Type = messageType or Enum.MessageType.MessageOutput })
        if #self.Entries > self.Max then table.remove(self.Entries, 1) end
        render()
        scroller.CanvasPosition = Vector2.new(0, math.max(0, scroller.AbsoluteCanvasSize.Y))
    end
    function console:Clear() table.clear(self.Entries); render() end
    function console:GetText()
        local out = {}
        for i, e in ipairs(self.Entries) do out[i] = e.Text end
        return table.concat(out, "\n")
    end
    function console:Copy()
        if copyToClipboard(self:GetText()) then
            window:Notify("success", "Copied", "Console logs copied.")
        else
            window:Notify("warning", "Copy failed", "Clipboard is not available.")
        end
    end
    function console:Save(fileName)
        fileName = (fileName and fileName ~= "") and fileName or "console.txt"
        if not fileName:find("%.") then fileName ..= ".txt" end
        if type(writefile) ~= "function" then
            window:Notify("warning", "Save failed", "writefile is not available.")
            return false
        end
        local ok = pcall(writefile, fileName, self:GetText())
        window:Notify(ok and "success" or "warning", ok and "Saved" or "Save failed",
            ok and ("Saved to " .. fileName) or "Could not write the file.")
        return ok
    end

    if opts.CaptureOutput then
        for _, m in ipairs(LogService:GetLogHistory()) do console:Log(m.message, m.messageType) end
        LogService.MessageOut:Connect(function(message, messageType) console:Log(message, messageType) end)
    end

    -- Clear / Save / Copy ---------------------------------------------------
    local buttons = create("Frame", {
        Name = "buttons", BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.fromOffset(341, 37), Position = UDim2.fromOffset(129, 240),
    }, self.Body)
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder,
    }, buttons)

    local function windowButton(parent, text, icon, order, cb)
        local pill = makePill(theme, parent, {
            Name = text, Text = text, Icon = icon, Height = 24, LayoutOrder = order,
            Bg = "cardBg", TextRole = "secondaryText", IconRole = "secondaryIcon",
            HoverBg = "hoverBg", HoverText = "primaryText",
        })
        pill.Instance.MouseButton1Click:Connect(function() task.spawn(cb) end)
        return pill
    end
    console._windowButton = windowButton

    -- save dialog -----------------------------------------------------------
    local overlay = create("Frame", {
        Name = "savedialog", Visible = false, ZIndex = 20, BorderSizePixel = 0,
        BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.2,
        Size = UDim2.fromScale(1, 1),
    }, window.Main)
    corner(overlay)
    local dialog = create("Frame", {
        Name = "dialog", BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(274, 126), Position = UDim2.fromScale(0.5, 0.5),
    }, overlay)
    corner(dialog)
    theme:Bind(dialog, { BackgroundColor3 = "windowBg" })
    makeLabel(theme, dialog, {
        Name = "title", Text = "Save in workspace", TextSize = 20,
        Size = UDim2.fromOffset(220, 25), Position = UDim2.fromOffset(11, 11),
    }, "primaryText")
    makeLabel(theme, dialog, {
        Name = "desc", Text = "Choose a file name for your console logs.", TextSize = 14, TextWrapped = true,
        Size = UDim2.fromOffset(250, 18), Position = UDim2.fromOffset(11, 36),
    }, "secondaryText")
    local closeBtn = create("ImageButton", {
        BackgroundTransparency = 1, BorderSizePixel = 0, Image = ICONS.close,
        Size = UDim2.fromOffset(20, 20), Position = UDim2.fromOffset(242, 14),
    }, dialog)
    theme:Bind(closeBtn, { ImageColor3 = "primaryIcon" })
    local nameHolder = create("Frame", {
        BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.fromOffset(253, 25), Position = UDim2.new(0.5, 0, 0, 65),
    }, dialog)
    corner(nameHolder)
    theme:Bind(nameHolder, { BackgroundColor3 = "cardBg" })
    local nameBox = create("TextBox", {
        BackgroundTransparency = 1, BorderSizePixel = 0, ClearTextOnFocus = false,
        FontFace = mainFont(), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
        PlaceholderText = "example.txt", Text = "",
        Size = UDim2.new(1, -16, 1, 0), Position = UDim2.fromOffset(8, 0),
    }, nameHolder)
    theme:Bind(nameBox, { TextColor3 = "primaryText", PlaceholderColor3 = "secondaryText" })
    local done = makePill(theme, dialog, {
        Name = "done", Text = "Done", Icon = ICONS.save, Height = 24,
        Bg = "controlBg", TextRole = "secondaryText", IconRole = "secondaryIcon",
        HoverBg = "hoverBg", HoverText = "primaryText",
    })
    done.Instance.Position = UDim2.fromOffset(200, 96)

    local function closeDialog() overlay.Visible = false end
    closeBtn.MouseButton1Click:Connect(closeDialog)
    done.Instance.MouseButton1Click:Connect(function()
        console:Save(nameBox.Text)
        closeDialog()
    end)

    windowButton(buttons, "Clear", ICONS.clear, 1, function() console:Clear() end)
    windowButton(buttons, "Save",  ICONS.save,  2, function() nameBox.Text = ""; overlay.Visible = true end)
    windowButton(buttons, "Copy",  ICONS.copy,  3, function() console:Copy() end)

    console.Instance = holder
    return console
end

--------------------------------------------------------------------------
-- Code editor  (tabs, line numbers, current-line highlight, Lua highlighting)
--------------------------------------------------------------------------
local function set(list)
    local t = {}
    for _, v in ipairs(list) do t[v] = true end
    return t
end

local LUA_KEYWORDS = set({
    "and", "break", "do", "else", "elseif", "end", "false", "for", "function", "goto", "if", "in",
    "local", "nil", "not", "or", "repeat", "return", "then", "true", "until", "while",
})
local LUA_GLOBALS = set({
    "getrawmetatable", "game", "workspace", "script", "math", "string", "table", "print", "wait",
    "BrickColor", "Color3", "next", "pairs", "ipairs", "select", "unpack", "Instance", "Vector2",
    "Vector3", "CFrame", "Ray", "UDim2", "Enum", "assert", "error", "warn", "tick", "loadstring",
    "_G", "shared", "getfenv", "setfenv", "newproxy", "setmetatable", "getmetatable", "os", "debug",
    "pcall", "ypcall", "xpcall", "rawequal", "rawset", "rawget", "tonumber", "tostring", "type",
    "typeof", "_VERSION", "coroutine", "delay", "require", "spawn", "LoadLibrary", "settings",
    "stats", "time", "UserSettings", "version", "Axes", "ColorSequence", "Faces",
    "ColorSequenceKeypoint", "NumberRange", "NumberSequence", "NumberSequenceKeypoint", "gcinfo",
    "elapsedTime", "collectgarbage", "PhysicalProperties", "Rect", "Region3", "Region3int16",
    "UDim", "Vector2int16", "Vector3int16",
})
local LUA_REMOTES = set({ "FireServer", "fireServer", "InvokeServer", "invokeServer" })

local SYNTAX = {
    dark  = { comment = "3CC93C", global = "85D7F8", keyword = "F96E7D", number = "FFC700", remote = "0091FF", string = "AEF296" },
    light = { comment = "15803D", global = "0369A1", keyword = "DC2626", number = "B45309", remote = "1D4ED8", string = "047857" },
}

local function highlightLua(src, colors)
    local out, n, i = {}, #src, 1
    local function push(color, text)
        text = escapeRich(text)
        out[#out + 1] = color and ('<font color="#' .. color .. '">' .. text .. "</font>") or text
    end
    while i <= n do
        local c = src:sub(i, i)
        if src:sub(i, i + 1) == "--" then
            local eq = src:match("^%-%-%[(=*)%[", i)
            local stop
            if eq then
                local _, e = src:find("]" .. eq .. "]", i, true)
                stop = e or n
            else
                stop = (src:find("\n", i, true) or (n + 1)) - 1
            end
            push(colors.comment, src:sub(i, stop)); i = stop + 1
        elseif c == '"' or c == "'" then
            local j = i + 1
            while j <= n do
                local d = src:sub(j, j)
                if d == "\\" then j += 2
                elseif d == c then break
                elseif d == "\n" then j -= 1; break
                else j += 1 end
            end
            push(colors.string, src:sub(i, j)); i = j + 1
        elseif src:sub(i, i + 1) == "[[" or src:match("^%[=+%[", i) then
            local eq = src:match("^%[(=*)%[", i)
            local _, e = src:find("]" .. eq .. "]", i, true)
            local stop = e or n
            push(colors.string, src:sub(i, stop)); i = stop + 1
        elseif c:match("%d") then
            local num = src:match("^0[xX]%x+", i) or src:match("^%d[%d%.]*", i)
            push(colors.number, num); i += #num
        elseif c:match("[%a_]") then
            local word = src:match("^[%a_][%w_]*", i)
            if LUA_KEYWORDS[word] then push(colors.keyword, word)
            elseif LUA_REMOTES[word] then push(colors.remote, word)
            elseif LUA_GLOBALS[word] then push(colors.global, word)
            else push(nil, word) end
            i += #word
        else
            push(nil, c); i += 1
        end
    end
    return table.concat(out)
end

--[[
    local editor = Tab:AddEditor({
        Default   = "print('hello')",
        OnExecute = function(code) loadstring(code)() end,   -- default does exactly this
        MaxTabs   = 5,
    })
    editor:GetText() / editor:SetText(text) / editor:NewTab(name, text)
]]
function Tab:AddEditor(opts)
    opts = opts or {}
    local theme, window = self.Theme, self.Window
    local editor = { Tabs = {}, Current = nil, _counter = 0 }
    local maxTabs = opts.MaxTabs or 5
    local LINE_H = 14

    -- tab strip ---------------------------------------------------------------
    local strip = create("Frame", {
        Name = "tabs", BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.fromOffset(459, 25), Position = UDim2.fromOffset(10, 0),
    }, self.Body)
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    }, strip)

    local addButton = create("ImageButton", {
        Name = "addtab", BackgroundTransparency = 1, BorderSizePixel = 0,
        Image = ICONS.plus, Size = UDim2.fromOffset(20, 20), LayoutOrder = 1000,
    }, strip)
    theme:Bind(addButton, { ImageColor3 = "secondaryIcon" })

    -- editor area -------------------------------------------------------------
    local canvas = create("ScrollingFrame", {
        Name = "editor", Active = true, BorderSizePixel = 0,
        Size = UDim2.fromOffset(460, 211), Position = UDim2.fromOffset(10, 30),
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.XY,
        ScrollBarThickness = 4, ScrollBarImageColor3 = rgb(101, 101, 101),
        ClipsDescendants = true,
    }, self.Body)
    corner(canvas)
    theme:Bind(canvas, { BackgroundColor3 = "windowBg" })

    local lineBar = create("Frame", {
        Name = "LineHighlight", ZIndex = 0, BorderSizePixel = 0,
        Size = UDim2.new(0, 10000, 0, LINE_H), Position = UDim2.new(),
    }, canvas)
    theme:Bind(lineBar, { BackgroundColor3 = "cardBg" })

    local gutter = create("TextLabel", {
        Name = "Lines", ZIndex = 4, BorderSizePixel = 0,
        FontFace = monoFont(), TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Top,
        Size = UDim2.new(0, 21, 1, 0), AutomaticSize = Enum.AutomaticSize.Y,
        Text = "1",
    }, canvas)
    theme:Bind(gutter, { BackgroundColor3 = "gutterBg", TextColor3 = "lineNumbers" })

    local source = create("TextBox", {
        Name = "TextBox", ZIndex = 2,
        BackgroundTransparency = 1, BorderSizePixel = 0,
        MultiLine = true, ClearTextOnFocus = false, TextWrapped = false,
        FontFace = monoFont(), TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
        TextTransparency = 1,
        Size = UDim2.new(1, -25, 1, 0), Position = UDim2.fromOffset(25, 0),
        AutomaticSize = Enum.AutomaticSize.XY,
        Text = "",
    }, canvas)
    theme:Bind(source, { TextColor3 = "primaryText", PlaceholderColor3 = "secondaryText" })
    source.PlaceholderText = opts.Placeholder or ""

    local overlay = create("TextLabel", {
        Name = "Highlighted", ZIndex = 5,
        BackgroundTransparency = 1, BorderSizePixel = 0, RichText = true, TextWrapped = false,
        FontFace = monoFont(), TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
        Size = UDim2.fromScale(1, 1), Text = "",
    }, source)
    theme:Bind(overlay, { TextColor3 = "primaryText" })

    local function redraw()
        local text = source.Text
        if text:find("\t", 1, true) or text:find("\r", 1, true) then
            source.Text = text:gsub("\r", ""):gsub("\t", "    ")
            return -- Text change re-fires
        end
        overlay.Text = highlightLua(text, theme.Dark and SYNTAX.dark or SYNTAX.light)
        local lines = select(2, text:gsub("\n", "\n")) + 1
        local nums = table.create(lines)
        for i = 1, lines do nums[i] = tostring(i) end
        gutter.Text = table.concat(nums, "\n")
    end
    local function updateLine()
        local pos = source.CursorPosition
        local line = 1
        if pos and pos > 0 then
            line = select(2, source.Text:sub(1, pos - 1):gsub("\n", "\n")) + 1
        end
        lineBar.Position = UDim2.fromOffset(0, (line - 1) * LINE_H)
    end
    source:GetPropertyChangedSignal("Text"):Connect(function()
        redraw(); updateLine()
        if editor.Current then editor.Current.Text = source.Text end
    end)
    source:GetPropertyChangedSignal("CursorPosition"):Connect(updateLine)
    canvas:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        gutter.Position = UDim2.fromOffset(canvas.CanvasPosition.X, 0)
    end)
    theme:OnChanged(function() if source.Parent then redraw() end end)

    -- tabs ----------------------------------------------------------------------
    local function refreshTabs()
        for _, t in ipairs(editor.Tabs) do
            theme:Apply(t.Button, QUAD_OUT_02)
            theme:Apply(t.Title, QUAD_OUT_02)
        end
    end

    function editor:Select(tab)
        self.Current = tab
        source.Text = tab.Text
        refreshTabs()
        redraw(); updateLine()
    end

    function editor:NewTab(name, text)
        if #self.Tabs >= maxTabs then
            window:Notify("warning", "Tab limit", "Close a tab before opening another.")
            return
        end
        self._counter += 1
        local tab = { Text = text or "", Name = name or ("Script " .. self._counter) }

        local button = create("TextButton", {
            Name = tab.Name, AutoButtonColor = false, BorderSizePixel = 0, Text = "",
            Size = UDim2.fromOffset(90, 25), LayoutOrder = #self.Tabs + 1,
        }, strip)
        corner(button)
        local title = makeLabel(theme, button, {
            Name = "tabtitle", Text = tab.Name, TextSize = 14,
            TextYAlignment = Enum.TextYAlignment.Center,
            Size = UDim2.new(0, 55, 1, 0), Position = UDim2.fromOffset(10, 0),
        }, "primaryText")
        title.TextTruncate = Enum.TextTruncate.AtEnd
        local close = create("ImageButton", {
            Name = "close", BackgroundTransparency = 1, BorderSizePixel = 0,
            Image = ICONS.close, AnchorPoint = Vector2.new(0, 0.5),
            Size = UDim2.fromOffset(15, 15), Position = UDim2.new(0.76667, 0, 0.5, 0),
        }, button)
        theme:Bind(close, { ImageColor3 = "secondaryIcon" })

        tab.Button, tab.Title = button, title
        theme:Bind(button, { BackgroundColor3 = function(t)
            return editor.Current == tab and t:Get("controlBg") or t:Get("cardBg")
        end })
        theme:Bind(title, { TextColor3 = function(t)
            return editor.Current == tab and t:Get("primaryText") or t:Get("secondaryText")
        end })

        table.insert(self.Tabs, tab)
        button.MouseButton1Click:Connect(function() self:Select(tab) end)
        close.MouseButton1Click:Connect(function() self:CloseTab(tab) end)
        self:Select(tab)
        return tab
    end

    function editor:CloseTab(tab)
        local idx = table.find(self.Tabs, tab)
        if not idx then return end
        if #self.Tabs == 1 then
            tab.Text = ""
            source.Text = ""
            return
        end
        table.remove(self.Tabs, idx)
        tab.Button:Destroy()
        if self.Current == tab then
            self:Select(self.Tabs[math.max(1, idx - 1)])
        end
    end

    function editor:GetText() return source.Text end
    function editor:SetText(text) source.Text = text end

    addButton.MouseButton1Click:Connect(function() editor:NewTab() end)

    -- Copy / Clear / Execute --------------------------------------------------------
    local buttons = create("Frame", {
        Name = "buttons", BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.fromOffset(341, 37), Position = UDim2.fromOffset(129, 238),
    }, self.Body)
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder,
    }, buttons)

    local function actionButton(text, icon, order, cb)
        local pill = makePill(theme, buttons, {
            Name = text, Text = text, Icon = icon, Height = 24, LayoutOrder = order,
            Bg = "cardBg", TextRole = "secondaryText", IconRole = "secondaryIcon",
            HoverBg = "hoverBg", HoverText = "primaryText",
        })
        pill.Instance.MouseButton1Click:Connect(function() task.spawn(cb) end)
    end
    actionButton("Copy", ICONS.copy, 1, function()
        if copyToClipboard(source.Text) then window:Notify("success", "Copied", "Script copied.")
        else window:Notify("warning", "Copy failed", "Clipboard is not available.") end
    end)
    actionButton("Clear", ICONS.clear, 2, function() source.Text = "" end)
    actionButton("Execute", ICONS.play, 3, function()
        local code = source.Text
        if opts.OnExecute then return opts.OnExecute(code) end
        local fn, err = loadstring(code)
        if not fn then
            window:Notify("warning", "Syntax error", tostring(err):sub(1, 60))
            return
        end
        local ok, runtimeErr = pcall(fn)
        if not ok then window:Notify("warning", "Script error", tostring(runtimeErr):sub(1, 60)) end
    end)

    editor:NewTab(opts.TabName, opts.Default)
    return editor
end

--------------------------------------------------------------------------
-- AI chat (message bubbles, code blocks with Copy / Execute, prompt box)
--------------------------------------------------------------------------
--[[
    local chat = Tab:AddChat({
        Placeholder = "Ask anything...",
        OnSend = function(text, chat)
            local reply = chat:AddMessage("ai", "Thinking...")
            reply:SetText("Here is a script:\n```lua\nprint('hi')\n```")
        end,
        OnExecute = function(code) end,            -- "Execute" on code blocks
    })
    chat:AddMessage("user" | "ai", text) -> { SetText(text) }
    chat:Clear()
]]
function Tab:AddChat(opts)
    opts = opts or {}
    local theme, window = self.Theme, self.Window
    local chat = {}

    local scroller = create("ScrollingFrame", {
        Name = "chatbox", Active = true,
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.fromOffset(449, 220), Position = UDim2.fromOffset(15, 0),
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
    }, self.Body)
    create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, scroller)

    local order = 0
    local function stick()
        task.defer(function()
            scroller.CanvasPosition = Vector2.new(0, math.max(0, scroller.AbsoluteCanvasSize.Y))
        end)
    end

    local function buildBody(parent, text, isUser)
        for _, child in ipairs(parent:GetChildren()) do
            if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then child:Destroy() end
        end
        local idx = 0
        local function textBlock(str)
            str = str:gsub("^\n+", ""):gsub("\n+$", "")
            if str == "" then return end
            idx += 1
            local l = makeLabel(theme, parent, {
                Name = "text", Text = str, TextSize = 14, TextWrapped = true,
                Size = UDim2.new(isUser and 0 or 1, 0, 0, 0),
            }, "primaryText")
            l.AutomaticSize = isUser and Enum.AutomaticSize.XY or Enum.AutomaticSize.Y
            l.LayoutOrder = idx
            if isUser then
                local c = Instance.new("UISizeConstraint"); c.MaxSize = Vector2.new(280, math.huge); c.Parent = l
            end
        end
        local function codeBlock(code)
            code = code:gsub("^[%w]*\n", "", 1):gsub("\n+$", "")
            idx += 1
            local frame = create("Frame", {
                Name = "code", BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = idx,
            }, parent)
            corner(frame)
            theme:Bind(frame, { BackgroundColor3 = "codeBg" })
            padding(frame, 6, 6, 6, 6)
            create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, frame)

            local body = create("TextLabel", {
                BackgroundTransparency = 1, BorderSizePixel = 0, RichText = true,
                FontFace = monoFont(), TextSize = 13, TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
                Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                Text = highlightLua(code, theme.Dark and SYNTAX.dark or SYNTAX.light),
                LayoutOrder = 1,
            }, frame)
            theme:Bind(body, { TextColor3 = "primaryText" })

            local row = create("Frame", {
                BackgroundTransparency = 1, BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 22), LayoutOrder = 2,
            }, frame)
            create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 5),
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
            }, row)
            local function btn(text, icon, cb)
                local pill = makePill(theme, row, {
                    Text = text, Icon = icon, Height = 22,
                    Bg = "controlBg", TextRole = "secondaryText", IconRole = "secondaryIcon",
                    HoverBg = "hoverBg", HoverText = "primaryText",
                })
                pill.Instance.MouseButton1Click:Connect(function() task.spawn(cb) end)
            end
            btn("Copy", ICONS.copy, function()
                if copyToClipboard(code) then window:Notify("success", "Copied", "Code copied.") end
            end)
            btn("Execute", ICONS.play, function()
                if opts.OnExecute then return opts.OnExecute(code) end
                local fn, err = loadstring(code)
                if not fn then return window:Notify("warning", "Syntax error", tostring(err):sub(1, 60)) end
                pcall(fn)
            end)
        end

        local pos = 1
        while true do
            local s, e = text:find("```", pos, true)
            if not s then textBlock(text:sub(pos)); break end
            textBlock(text:sub(pos, s - 1))
            local s2 = text:find("```", e + 1, true)
            if not s2 then codeBlock(text:sub(e + 1)); break end
            codeBlock(text:sub(e + 1, s2 - 1))
            pos = s2 + 3
        end
    end

    function chat:AddMessage(role, text)
        order += 1
        local isUser = (role == "user")
        local row = create("Frame", {
            Name = role .. "message", BackgroundTransparency = 1, BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = order,
        }, scroller)
        create("UIListLayout", {
            HorizontalAlignment = isUser and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Left,
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, row)

        local bubble = create("Frame", {
            Name = "bubble", BorderSizePixel = 0,
            Size = UDim2.new(isUser and 0 or 1, 0, 0, 0),
            AutomaticSize = isUser and Enum.AutomaticSize.XY or Enum.AutomaticSize.Y,
        }, row)
        corner(bubble)
        theme:Bind(bubble, { BackgroundColor3 = isUser and "bubbleUser" or "bubbleAI" })
        padding(bubble, 8, 10, 8, 10)
        create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, bubble)
        buildBody(bubble, text or "", isUser)

        local message = { Instance = row }
        function message:SetText(newText)
            buildBody(bubble, newText, isUser)
            stick()
        end
        stick()
        return message
    end

    function chat:Clear()
        for _, c in ipairs(scroller:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
    end

    -- prompt box ----------------------------------------------------------------------
    local prompt = create("Frame", {
        Name = "promptbox", BorderSizePixel = 0,
        Size = UDim2.fromOffset(449, 42), Position = UDim2.fromOffset(15, 222),
    }, self.Body)
    corner(prompt)
    shadow(prompt)
    theme:Bind(prompt, { BackgroundColor3 = "cardBg" })

    local input = create("TextBox", {
        Name = "input", BackgroundTransparency = 1, BorderSizePixel = 0,
        ClearTextOnFocus = false, MultiLine = true, TextWrapped = true,
        FontFace = mainFont(), TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center,
        PlaceholderText = opts.Placeholder or "Ask anything...", Text = "",
        Size = UDim2.fromOffset(385, 36), Position = UDim2.fromOffset(12, 3),
    }, prompt)
    theme:Bind(input, { TextColor3 = "primaryText", PlaceholderColor3 = "secondaryText" })

    local send = create("ImageButton", {
        Name = "send", BackgroundTransparency = 1, BorderSizePixel = 0,
        Image = ICONS.send, Size = UDim2.fromOffset(20, 20), Position = UDim2.fromOffset(414, 11),
    }, prompt)
    theme:Bind(send, { ImageColor3 = "primaryIcon" })

    local function submit()
        local text = input.Text:gsub("^%s+", ""):gsub("%s+$", "")
        if text == "" then return end
        input.Text = ""
        chat:AddMessage("user", text)
        if opts.OnSend then task.spawn(opts.OnSend, text, chat) end
    end
    send.MouseButton1Click:Connect(submit)
    input.FocusLost:Connect(function(enter) if enter then submit() end end)

    chat.Instance, chat.Input = scroller, input
    return chat
end

--------------------------------------------------------------------------
-- Music player  (32-bar visualiser, URL box, play / pause, progress)
--------------------------------------------------------------------------
--[[
    local player = Tab:AddMusicPlayer({
        Sound = nil,                       -- optional Sound instance (one is created if nil)
        Placeholder = "Audio URL or asset id...",
        OnSubmit = function(text, player) end,   -- override the default loader
    })
    player:Play(id/url) / player:Pause() / player:Resume() / player.Sound
]]
function Tab:AddMusicPlayer(opts)
    opts = opts or {}
    local theme, window = self.Theme, self.Window
    local player = {}

    local sound = opts.Sound or create("Sound", { Name = "UIMusic", Looped = opts.Looped or false, Volume = 1 }, window.Gui)
    player.Sound = sound

    -- visualiser -------------------------------------------------------------------------
    local viz = create("Frame", {
        Name = "av", BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.fromOffset(461, 201), Position = UDim2.fromOffset(9, 0),
    }, self.Body)
    local BARS = 32
    local bars, levels = {}, {}
    for i = 1, BARS do
        local bar = create("Frame", {
            Name = "CavaBar", BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0, 1),
            Size = UDim2.new(0.02737, 0, 0.05, 0),
            Position = UDim2.new(0.03137 * (i - 1), 0, 1, 0),
        }, viz)
        theme:Bind(bar, { BackgroundColor3 = "sliderFill" })
        bars[i], levels[i] = bar, 0.05
    end

    -- url box -------------------------------------------------------------------------------
    local urlBar = create("Frame", {
        Name = "url", BorderSizePixel = 0,
        Size = UDim2.fromOffset(461, 30), Position = UDim2.fromOffset(9, 206),
    }, self.Body)
    corner(urlBar)
    theme:Bind(urlBar, { BackgroundColor3 = "cardBg" })
    makeIcon(theme, urlBar, opts.Icon or ICONS.music, UDim2.fromOffset(15, 15), UDim2.fromOffset(6, 7), "secondaryIcon")
    local urlBox = create("TextBox", {
        BackgroundTransparency = 1, BorderSizePixel = 0, ClearTextOnFocus = false,
        FontFace = mainFont(), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
        PlaceholderText = opts.Placeholder or "Audio URL or asset id...", Text = "",
        Size = UDim2.new(1, -36, 1, 0), Position = UDim2.fromOffset(30, 0),
    }, urlBar)
    theme:Bind(urlBox, { TextColor3 = "primaryText", PlaceholderColor3 = "secondaryText" })

    -- transport -------------------------------------------------------------------------------
    local PLAY_ICON  = opts.PlayIcon  or ICONS.play
    local PAUSE_ICON = opts.PauseIcon or "rbxassetid://10734919336"

    local pp = create("TextButton", {
        Name = "pp", AutoButtonColor = false, BorderSizePixel = 0, Text = "",
        Size = UDim2.fromOffset(30, 30), Position = UDim2.fromOffset(9, 242),
    }, self.Body)
    corner(pp)
    theme:Bind(pp, { BackgroundColor3 = "cardBg" })
    local ppIcon = create("ImageLabel", {
        BackgroundTransparency = 1, BorderSizePixel = 0, Image = PLAY_ICON,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(15, 15), Position = UDim2.fromScale(0.5, 0.5),
    }, pp)
    theme:Bind(ppIcon, { ImageColor3 = "primaryIcon" })

    local timeHolder = create("Frame", {
        Name = "time", BorderSizePixel = 0,
        Size = UDim2.fromOffset(78, 30), Position = UDim2.fromOffset(43, 242),
    }, self.Body)
    corner(timeHolder)
    theme:Bind(timeHolder, { BackgroundColor3 = "cardBg" })
    local timeLabel = makeLabel(theme, timeHolder, {
        Text = "0:00", TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center,
        Size = UDim2.fromScale(1, 1),
    }, "secondaryText")

    local track = create("TextButton", {
        Name = "progress", AutoButtonColor = false, BorderSizePixel = 0, Text = "",
        ClipsDescendants = true,
        Size = UDim2.fromOffset(343, 30), Position = UDim2.fromOffset(127, 242),
    }, self.Body)
    corner(track)
    theme:Bind(track, { BackgroundColor3 = "cardBg" })
    local fill = create("Frame", {
        Name = "fill", BorderSizePixel = 0, Size = UDim2.new(0, 0, 1, 0),
    }, track)
    corner(fill)
    theme:Bind(fill, { BackgroundColor3 = "sliderFill" })

    local function fmt(t)
        t = math.max(0, math.floor(t))
        return string.format("%d:%02d", t // 60, t % 60)
    end

    function player:Pause()  sound:Pause() end
    function player:Resume() sound:Resume() end
    function player:Play(source)
        source = tostring(source)
        if tonumber(source) then
            sound.SoundId = "rbxassetid://" .. source
        elseif source:match("^https?://") and type(writefile) == "function" and type(getcustomasset) == "function" then
            local ok, data = pcall(function() return game:HttpGet(source) end)
            if not ok then
                window:Notify("warning", "Download failed", "Could not download the audio.")
                return
            end
            local file = "zeroui_music_" .. tostring(#source) .. ".mp3"
            writefile(file, data)
            sound.SoundId = getcustomasset(file)
        else
            sound.SoundId = source
        end
        sound.TimePosition = 0
        sound:Play()
    end

    pp.MouseButton1Click:Connect(function()
        if sound.IsPlaying then sound:Pause()
        elseif sound.SoundId ~= "" then sound:Resume() if not sound.IsPlaying then sound:Play() end
        end
    end)
    urlBox.FocusLost:Connect(function(enter)
        if not enter or urlBox.Text == "" then return end
        if opts.OnSubmit then opts.OnSubmit(urlBox.Text, player) else player:Play(urlBox.Text) end
    end)
    track.InputBegan:Connect(function(input)
        if isPress(input) and sound.TimeLength > 0 then
            local a = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            sound.TimePosition = a * sound.TimeLength
        end
    end)

    task.spawn(function()
        while viz.Parent do
            local dt = RunService.RenderStepped:Wait()
            local playing = sound.IsPlaying
            ppIcon.Image = playing and PAUSE_ICON or PLAY_ICON
            local loud = playing and math.clamp(sound.PlaybackLoudness / 600, 0, 1) or 0
            for i = 1, BARS do
                local target = playing and math.clamp(loud * (0.35 + math.random() * 0.65), 0.05, 1) or 0.05
                levels[i] += (target - levels[i]) * (1 - math.exp(-dt * 14))
                bars[i].Size = UDim2.new(0.02737, 0, levels[i], 0)
            end
            local length = sound.TimeLength
            fill.Size = UDim2.new(length > 0 and sound.TimePosition / length or 0, 0, 1, 0)
            timeLabel.Text = fmt(sound.TimePosition)
        end
    end)

    return player
end

--------------------------------------------------------------------------
-- Library level helpers
--------------------------------------------------------------------------
Library.Palettes = PALETTES

function Library:Notify(...)
    local window = Library.Windows[#Library.Windows]
    if window then return window:Notify(...) end
end

return Library
