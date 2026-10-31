--[[
    Menu UI Library
    Extracted from message.txt (the "Rivals Menu" UI): same sizes, colors, fonts,
    corner radii, strokes and tween timings as the original.

    Quick start (see Example.lua for a full demo):

        local Library = loadstring(readfile("MenuUILibrary.lua"))()
        local Window = Library:CreateWindow({ Title = "My Menu" })
        local Tab    = Window:AddTab({ Name = "Main", Icon = Library.Icons.Aimbot })
        local Panel  = Tab:AddPanel({ Name = "Main" })
        Panel:AddToggle({ Text = "Enable", Flag = "Enabled", Callback = function(v) end })

    Elements: AddSection, AddToggle, AddSafeToggle, AddToggleDropdown, AddToggleKeybind,
              AddDropdown, AddKeybind, AddPlayerDropdown, AddSlider, AddButton, AddConfirmButton
    Window:   AddTab, Notify, SetStatus, SetTheme, SetWatermark, SetCounter, Unlock,
              Show, Hide, Toggle, Set, Get, SaveConfig, LoadConfig, Destroy
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local Library = {}
Library.__index = Library

local Window = {}
Window.__index = Window
local Tab = {}
Tab.__index = Tab
local Panel = {}
Panel.__index = Panel

----------------------------------------------------------------------
-- Theme presets (identical to the original ThemePresets)
----------------------------------------------------------------------
Library.Themes = {
    Dark = {
        MainBg = Color3.fromRGB(18, 18, 20), PanelBg = Color3.fromRGB(30, 30, 34),
        Panel = Color3.fromRGB(22, 22, 25), Stroke = Color3.fromRGB(45, 45, 50),
        AccentOn = Color3.fromRGB(255, 255, 255), AccentOff = Color3.fromRGB(45, 45, 50),
    },
    Midnight = {
        MainBg = Color3.fromRGB(9, 14, 26), PanelBg = Color3.fromRGB(20, 30, 52),
        Panel = Color3.fromRGB(14, 20, 36), Stroke = Color3.fromRGB(45, 75, 140),
        AccentOn = Color3.fromRGB(90, 170, 255), AccentOff = Color3.fromRGB(28, 40, 66),
    },
    Violet = {
        MainBg = Color3.fromRGB(18, 12, 28), PanelBg = Color3.fromRGB(38, 26, 56),
        Panel = Color3.fromRGB(27, 18, 42), Stroke = Color3.fromRGB(95, 55, 145),
        AccentOn = Color3.fromRGB(205, 125, 255), AccentOff = Color3.fromRGB(48, 34, 70),
    },
}

-- Lucide icon assets (the same ids the original sidebar uses).
-- Shield id is the Lucide "shield" asset; verify it in game if the icon looks wrong.
Library.Icons = {
    Aimbot = "rbxassetid://7733917120",
    ESP = "rbxassetid://7733774602",
    Player = "rbxassetid://7733920644",
    Shield = "rbxassetid://7734056608",
}

-- User-facing strings (defaults are the original texts, override any of them)
Library.Strings = {
    On = "Đã Bật",
    Off = "Đã Tắt",
    Danger = "Nguy Hiểm",
    ConfirmPrompt = "BẤM LẦN NỮA ĐỂ XÁC NHẬN",
    Activated = "ĐÃ KÍCH HOẠT",
    PlayerPlaceholder = "Chọn Người",
    SafeWarn = "Tắt chế độ bảo vệ có thể bị Ban! Bấm lần nữa để TẮT.",
    SafeOnTitle = "An Toàn",
    SafeOnText = "Hệ thống bảo vệ đã BẬT!",
    SafeOffText = "Hệ thống tự vệ đã tắt, cẩn thận!",
    ConfigTitle = "Cấu Hình",
    ConfigSaved = "Đã lưu cài đặt thành công!",
    ConfigLoaded = "Đã tải cài đặt thành công!",
    ConfigNoFile = "Chưa có file cấu hình để tải",
    ConfigBadFile = "File cấu hình bị lỗi cú pháp",
    ConfigNoWrite = "Executor không hỗ trợ writefile",
    ConfigNoRead = "Executor không hỗ trợ đọc file",
    Connected = "Đã kết nối thành công!",
}

----------------------------------------------------------------------
-- Helpers
----------------------------------------------------------------------
local function mk(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    if parent then inst.Parent = parent end
    return inst
end

local function corner(inst, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius
    c.Parent = inst
    return c
end

local function stroke(inst, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1
    if transparency then s.Transparency = transparency end
    s.Parent = inst
    return s
end

local function tween(inst, info, props)
    local t = TweenService:Create(inst, info, props)
    t:Play()
    return t
end

local function randomString(len)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local out = {}
    for i = 1, len do
        local r = math.random(1, #chars)
        out[i] = string.sub(chars, r, r)
    end
    return table.concat(out)
end

local function stripRich(s)
    return (tostring(s):gsub("<[^>]+>", ""))
end

local function getSafeParent()
    if gethui and type(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    local ok, parent = pcall(function() return CoreGui end)
    if ok and parent then return parent end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function protectInstance(inst)
    if protect_gui and type(protect_gui) == "function" then
        pcall(protect_gui, inst)
    end
    if syn and syn.protect_gui then
        pcall(function() syn.protect_gui(inst) end)
    end
    if protectui and type(protectui) == "function" then
        pcall(protectui, inst)
    end
end

local function formatKey(key)
    if not key then return "None" end
    local name = (typeof(key) == "EnumItem") and key.Name or tostring(key)
    if name == "MouseButton1" then return "LClick" end
    if name == "MouseButton2" then return "RClick" end
    if name == "MouseButton3" then return "MClick" end
    return name
end

local function isAssetIcon(icon)
    return type(icon) == "string" and icon:match("rbxasset") ~= nil
end

----------------------------------------------------------------------
-- Window
----------------------------------------------------------------------
function Library:CreateWindow(opts)
    opts = opts or {}

    local self = setmetatable({}, Window)
    self.Flags = {}
    self.Elements = {}
    self.SearchIndex = {}
    self.Tabs = {}
    self.TabList = {}
    self.ActiveTab = nil
    self.Connections = {}
    self.Alive = true
    self.Connected = false
    self.Title = opts.Title or "Menu"
    self.Options = opts

    self.Theme = {
        MainBg = Color3.fromRGB(18, 18, 20), PanelBg = Color3.fromRGB(30, 30, 34),
        TopBarText = Color3.fromRGB(180, 180, 180), TextWhite = Color3.fromRGB(240, 240, 240),
        TextDark = Color3.fromRGB(120, 120, 120), AccentOn = Color3.fromRGB(255, 255, 255),
        AccentOff = Color3.fromRGB(45, 45, 50), KnobOn = Color3.fromRGB(18, 18, 20),
        KnobOff = Color3.fromRGB(180, 180, 180), DotGreen = Color3.fromRGB(0, 255, 0),
        DotRed = Color3.fromRGB(255, 50, 50),
        Font = Enum.Font.GothamMedium, FontBold = Enum.Font.GothamBold,
    }
    local Theme = self.Theme

    self._themed = { Panels = {}, Toggles = {}, SliderFills = {}, Dropbox = {} }
    self.ThemeName = opts.Theme or "Dark"

    local W = opts.Size and opts.Size.X or 650
    local H = opts.Size and opts.Size.Y or 420
    self._size = Vector2.new(W, H)
    local shownPos = UDim2.new(0.5, -W / 2, 0.5, -H / 2)
    local hiddenPos = UDim2.new(0.5, -W / 2, 1.5, 0)

    -- initial toggle key flag (mirrors Settings.ToggleKeybind)
    self.Flags.ToggleKeybind = opts.ToggleKey or Enum.KeyCode.Insert

    local function connect(signal, fn)
        local c = signal:Connect(fn)
        table.insert(self.Connections, c)
        return c
    end
    self._connect = connect

    ------------------------------------------------------------------
    -- ScreenGui + main frame
    ------------------------------------------------------------------
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = randomString(12)
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = getSafeParent()
    protectInstance(ScreenGui)
    self.Gui = ScreenGui

    local MainFrame = mk("Frame", {
        Name = randomString(8),
        Size = UDim2.new(0, W, 0, H),
        Position = shownPos,
        BackgroundColor3 = Theme.MainBg,
        BorderSizePixel = 0,
        Visible = false,
    }, ScreenGui)
    local MainStroke = stroke(MainFrame, Color3.fromRGB(45, 45, 50), 1)
    corner(MainFrame, UDim.new(0, 10))
    self.MainFrame = MainFrame
    self.MainStroke = MainStroke

    ------------------------------------------------------------------
    -- Top-center counter box
    ------------------------------------------------------------------
    local CounterBox = mk("Frame", {
        Name = "CounterBox",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 15),
        Size = UDim2.new(0, 60, 0, 56),
        BackgroundColor3 = Color3.fromRGB(10, 10, 12),
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Visible = false,
    }, ScreenGui)
    corner(CounterBox, UDim.new(0, 8))
    stroke(CounterBox, Color3.fromRGB(50, 50, 55), 1.5, 0.3)

    local CounterLabel = mk("TextLabel", {
        Name = "CounterLabel",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "0",
        TextColor3 = Color3.fromRGB(255, 50, 50),
        Font = Enum.Font.GothamBold,
        TextSize = 36,
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        TextStrokeTransparency = 0.4,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
    }, CounterBox)
    self.CounterBox = CounterBox
    self.CounterLabel = CounterLabel

    ------------------------------------------------------------------
    -- Watermark (bottom right, draggable)
    ------------------------------------------------------------------
    local wm = opts.Watermark
    local WatermarkFrame = mk("Frame", {
        Size = UDim2.new(0, 300, 0, 20),
        Position = UDim2.new(1, -310, 1, -30),
        BackgroundTransparency = 1,
        Visible = wm ~= nil,
    }, ScreenGui)

    local idleColor = (wm and wm.IdleColor) or Color3.fromRGB(255, 215, 0)
    local connectedColor = (wm and wm.ConnectedColor) or Color3.fromRGB(0, 255, 0)

    local Watermark = mk("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        RichText = true,
        Text = (wm and wm.Text) or "",
        TextColor3 = idleColor,
        Font = Theme.FontBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextStrokeTransparency = 0.5,
    }, WatermarkFrame)
    self.Watermark = Watermark
    self.WatermarkFrame = WatermarkFrame
    self._wmIdle = idleColor
    self._wmConnected = connectedColor

    ------------------------------------------------------------------
    -- Notifications
    ------------------------------------------------------------------
    local NotifyFrame = mk("Frame", {
        Name = randomString(6),
        Size = UDim2.new(0, 250, 1, -50),
        Position = UDim2.new(1, -260, 0, 10),
        BackgroundTransparency = 1,
    }, ScreenGui)
    do
        local l = Instance.new("UIListLayout")
        l.SortOrder = Enum.SortOrder.LayoutOrder
        l.VerticalAlignment = Enum.VerticalAlignment.Bottom
        l.Padding = UDim.new(0, 5)
        l.Parent = NotifyFrame
    end
    self.NotifyFrame = NotifyFrame

    ------------------------------------------------------------------
    -- Tooltip following the mouse
    ------------------------------------------------------------------
    local Tooltip = mk("TextLabel", {
        Size = UDim2.new(0, 190, 0, 26),
        BackgroundColor3 = Color3.fromRGB(16, 16, 18),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        TextColor3 = Color3.fromRGB(230, 230, 230),
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Center,
        Visible = false,
        ZIndex = 50,
    }, ScreenGui)
    corner(Tooltip, UDim.new(0, 6))
    self.Tooltip = Tooltip

    connect(UserInputService.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and Tooltip.Visible then
            local pos = UserInputService:GetMouseLocation()
            Tooltip.Position = UDim2.new(0, pos.X + 14, 0, pos.Y + 14)
        end
    end)

    ------------------------------------------------------------------
    -- Dragging
    ------------------------------------------------------------------
    local function makeDraggable(topbar, main)
        local dragging, dragInput, dragStart, startPos
        connect(topbar.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = main.Position
            end
        end)
        connect(topbar.InputChanged, function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        connect(UserInputService.InputChanged, function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                main.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        connect(topbar.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end
    makeDraggable(WatermarkFrame, WatermarkFrame)

    ------------------------------------------------------------------
    -- Top bar
    ------------------------------------------------------------------
    local TopBar = mk("Frame", {
        Name = randomString(6),
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
    }, MainFrame)
    makeDraggable(TopBar, MainFrame)

    mk("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Color3.fromRGB(35, 35, 40),
        BorderSizePixel = 0,
    }, TopBar)

    local subtitle = opts.Subtitle or "Login"
    local idleStatus = string.format(
        '<font color="#ffffff">● %s</font>   <font color="#666677">/</font>   <font color="#aaaaaa">%s</font>',
        self.Title, subtitle)
    self._idleStatus = idleStatus

    local StatusText = mk("TextLabel", {
        Size = UDim2.new(0, 400, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        RichText = true,
        Text = idleStatus,
        TextColor3 = Theme.TopBarText,
        Font = Theme.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Visible = true,
    }, TopBar)
    self.StatusText = StatusText

    local CloseBtn = mk("TextButton", {
        Size = UDim2.new(0, 40, 1, 0),
        Position = UDim2.new(1, -40, 0, 0),
        BackgroundTransparency = 1,
        Text = "X",
        TextColor3 = Theme.TextDark,
        Font = Theme.Font,
        TextSize = 14,
    }, TopBar)
    connect(CloseBtn.MouseButton1Click, function() self:Destroy() end)

    ------------------------------------------------------------------
    -- Sidebar + content area
    ------------------------------------------------------------------
    local Sidebar = mk("Frame", {
        Size = UDim2.new(0, 50, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1,
        Visible = false,
    }, MainFrame)
    mk("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = Color3.fromRGB(35, 35, 40),
        BorderSizePixel = 0,
    }, Sidebar)

    local ContentArea = mk("Frame", {
        Size = UDim2.new(1, -60, 1, -50),
        Position = UDim2.new(0, 50, 0, 40),
        BackgroundTransparency = 1,
        Visible = false,
    }, MainFrame)

    self.Sidebar = Sidebar
    self.ContentArea = ContentArea

    ------------------------------------------------------------------
    -- Login window (optional)
    ------------------------------------------------------------------
    local LoginFrame, ConnectFrame, ConnectBtn, TerminalFrame
    local loginCfg = opts.Login
    local connectCfg = opts.Connect

    if loginCfg then
        LoginFrame = mk("Frame", {
            Name = "LoginFrame",
            Size = UDim2.new(0, 360, 0, 225),
            Position = UDim2.new(0.5, -180, 0.5, -112),
            BackgroundColor3 = Theme.MainBg,
            BorderSizePixel = 0,
            Visible = true,
        }, ScreenGui)
        corner(LoginFrame, UDim.new(0, 10))
        stroke(LoginFrame, Color3.fromRGB(45, 45, 50), 1)

        local LoginTopBar = mk("Frame", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundTransparency = 1,
        }, LoginFrame)
        makeDraggable(LoginTopBar, LoginFrame)

        mk("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, -1),
            BackgroundColor3 = Color3.fromRGB(35, 35, 40),
            BorderSizePixel = 0,
        }, LoginTopBar)

        mk("TextLabel", {
            Size = UDim2.new(0, 300, 1, 0),
            Position = UDim2.new(0, 15, 0, 0),
            BackgroundTransparency = 1,
            RichText = true,
            Text = idleStatus,
            TextColor3 = Theme.TopBarText,
            Font = Theme.Font,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, LoginTopBar)

        local LoginCloseBtn = mk("TextButton", {
            Size = UDim2.new(0, 40, 1, 0),
            Position = UDim2.new(1, -40, 0, 0),
            BackgroundTransparency = 1,
            Text = "X",
            TextColor3 = Theme.TextDark,
            Font = Theme.Font,
            TextSize = 14,
        }, LoginTopBar)
        connect(LoginCloseBtn.MouseButton1Click, function() self:Destroy() end)

        local LoginBody = mk("Frame", {
            Size = UDim2.new(1, 0, 1, -40),
            Position = UDim2.new(0, 0, 0, 40),
            BackgroundTransparency = 1,
        }, LoginFrame)

        mk("TextLabel", {
            Size = UDim2.new(1, -36, 0, 18),
            Position = UDim2.new(0, 18, 0, 10),
            BackgroundTransparency = 1,
            Text = loginCfg.Label or "LICENSE KEY",
            TextColor3 = Color3.fromRGB(130, 130, 145),
            Font = Theme.FontBold,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, LoginBody)

        local KeyInputBox = mk("TextBox", {
            Size = UDim2.new(1, -36, 0, 42),
            Position = UDim2.new(0, 18, 0, 32),
            BackgroundColor3 = Color3.fromRGB(12, 12, 16),
            TextColor3 = Theme.TextWhite,
            PlaceholderText = loginCfg.Placeholder or "RLX-XXXX-XXXX-XXXX",
            PlaceholderColor3 = Color3.fromRGB(70, 70, 85),
            Font = Enum.Font.Gotham,
            TextSize = 13,
            Text = "",
            TextStrokeTransparency = 1,
            ClearTextOnFocus = false,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, LoginBody)
        corner(KeyInputBox, UDim.new(0, 8))
        do
            local pad = Instance.new("UIPadding")
            pad.PaddingLeft = UDim.new(0, 14)
            pad.PaddingRight = UDim.new(0, 14)
            pad.Parent = KeyInputBox
        end
        local KeyInputStroke = Instance.new("UIStroke")
        KeyInputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        KeyInputStroke.Color = Color3.fromRGB(35, 35, 45)
        KeyInputStroke.Thickness = 1
        KeyInputStroke.Parent = KeyInputBox

        local LoginBtn = mk("TextButton", {
            Size = UDim2.new(1, -36, 0, 40),
            Position = UDim2.new(0, 18, 0, 84),
            BackgroundColor3 = Color3.fromRGB(245, 245, 250),
            TextColor3 = Color3.fromRGB(10, 10, 15),
            Font = Theme.FontBold,
            TextSize = 14,
            Text = "LOGIN",
            AutoButtonColor = false,
        }, LoginBody)
        corner(LoginBtn, UDim.new(0, 8))

        local StatusBox = mk("Frame", {
            Size = UDim2.new(1, -36, 0, 38),
            Position = UDim2.new(0, 18, 0, 134),
            BackgroundColor3 = Color3.fromRGB(28, 16, 18),
            BorderSizePixel = 0,
            Visible = false,
        }, LoginBody)
        corner(StatusBox, UDim.new(0, 6))
        local StatusStroke = stroke(StatusBox, Color3.fromRGB(180, 45, 50), 1)

        local StatusLabel = mk("TextLabel", {
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Text = "",
            TextColor3 = Color3.fromRGB(255, 130, 140),
            Font = Enum.Font.Code,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, StatusBox)

        mk("TextLabel", {
            Size = UDim2.new(0.5, -18, 0, 20),
            Position = UDim2.new(0, 18, 1, -22),
            BackgroundTransparency = 1,
            Text = loginCfg.Footer or "Get a license →",
            TextColor3 = Color3.fromRGB(140, 140, 160),
            Font = Theme.Font,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, LoginBody)

        mk("TextLabel", {
            Size = UDim2.new(0.5, -18, 0, 20),
            Position = UDim2.new(0.5, 0, 1, -22),
            BackgroundTransparency = 1,
            Text = loginCfg.Version or "v1.0.0",
            TextColor3 = Color3.fromRGB(85, 85, 100),
            Font = Theme.Font,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Right,
        }, LoginBody)

        connect(KeyInputBox.Focused, function()
            tween(KeyInputStroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(65, 65, 80) })
            if StatusBox.Visible then
                StatusBox.Visible = false
                tween(LoginFrame, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 360, 0, 225),
                    Position = UDim2.new(0.5, -180, 0.5, -112),
                })
            end
        end)
        connect(KeyInputBox.FocusLost, function()
            tween(KeyInputStroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(35, 35, 45) })
        end)

        local isChecking = false
        local function processLogin()
            if isChecking then return end
            isChecking = true

            local inputKey = string.gsub(KeyInputBox.Text, "%s+", "")

            tween(LoginFrame, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 360, 0, 280),
                Position = UDim2.new(0.5, -180, 0.5, -140),
            })

            StatusBox.Visible = true
            StatusBox.BackgroundColor3 = Color3.fromRGB(28, 16, 18)
            StatusStroke.Color = Color3.fromRGB(180, 45, 50)
            StatusLabel.TextColor3 = Color3.fromRGB(255, 130, 140)

            local dmin = (loginCfg.Delay and loginCfg.Delay[1] or 2) * 100
            local dmax = (loginCfg.Delay and loginCfg.Delay[2] or 4) * 100
            local totalDuration = math.random(dmin, dmax) / 100
            local step1Time = totalDuration * 0.45
            local step2Time = totalDuration * 0.55

            local startTime = tick()
            local dotCount = 1
            while (tick() - startTime) < step1Time do
                StatusLabel.Text = (loginCfg.Step1 or "Connecting to key server") .. string.rep(".", dotCount)
                dotCount = (dotCount % 3) + 1
                task.wait(0.25)
            end

            startTime = tick()
            dotCount = 1
            while (tick() - startTime) < step2Time do
                StatusLabel.Text = (loginCfg.Step2 or "Authenticating key") .. string.rep(".", dotCount)
                dotCount = (dotCount % 3) + 1
                task.wait(0.25)
            end

            local valid = false
            if loginCfg.Validate then
                local ok, res = pcall(loginCfg.Validate, inputKey)
                valid = ok and res and true or false
            end

            if valid then
                StatusBox.BackgroundColor3 = Color3.fromRGB(16, 30, 20)
                StatusStroke.Color = Color3.fromRGB(40, 180, 80)
                StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 140)
                StatusLabel.Text = "Valid license key"

                LoginBtn.BackgroundColor3 = Color3.fromRGB(0, 220, 100)
                LoginBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
                LoginBtn.Text = "ACCESS GRANTED"
                task.wait(0.4)

                LoginFrame.Visible = false
                if connectCfg then
                    MainFrame.Visible = true
                    ConnectFrame.Visible = true
                    ConnectBtn.Visible = true
                    TerminalFrame.Visible = false
                else
                    self:Unlock(loginCfg.UnlockMessage)
                end
                isChecking = false
                if loginCfg.OnSuccess then task.spawn(loginCfg.OnSuccess, inputKey) end
            else
                StatusBox.BackgroundColor3 = Color3.fromRGB(32, 14, 16)
                StatusStroke.Color = Color3.fromRGB(220, 50, 60)
                StatusLabel.TextColor3 = Color3.fromRGB(255, 110, 120)
                StatusLabel.Text = "Invalid license key"

                LoginBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
                LoginBtn.TextColor3 = Theme.TextWhite
                LoginBtn.Text = "LOGIN FAILED"

                task.wait(1)

                LoginBtn.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
                LoginBtn.TextColor3 = Color3.fromRGB(10, 10, 15)
                LoginBtn.Text = "LOGIN"
                isChecking = false
            end
        end

        connect(LoginBtn.MouseButton1Click, processLogin)
        connect(KeyInputBox.FocusLost, function(enterPressed)
            if enterPressed then processLogin() end
        end)
    end
    self.LoginFrame = LoginFrame

    ------------------------------------------------------------------
    -- Connect screen (optional)
    ------------------------------------------------------------------
    if connectCfg then
        ConnectFrame = mk("Frame", {
            Size = UDim2.new(1, 0, 1, -40),
            Position = UDim2.new(0, 0, 0, 40),
            BackgroundTransparency = 1,
            Visible = true,
        }, MainFrame)

        local buttonText = connectCfg.ButtonText or "Connect"
        ConnectBtn = mk("TextButton", {
            Size = UDim2.new(0, 150, 0, 40),
            Position = UDim2.new(0.5, -75, 0.5, -20),
            BackgroundColor3 = Color3.fromRGB(0, 200, 0),
            TextColor3 = Color3.fromRGB(0, 0, 0),
            Font = Theme.FontBold,
            TextSize = 16,
            Text = buttonText,
        }, ConnectFrame)
        corner(ConnectBtn, UDim.new(0, 8))

        TerminalFrame = mk("Frame", {
            Size = UDim2.new(0.8, 0, 0.8, 0),
            Position = UDim2.new(0.1, 0, 0.1, 0),
            BackgroundColor3 = Color3.fromRGB(10, 10, 10),
            BorderSizePixel = 0,
            Visible = false,
        }, ConnectFrame)
        corner(TerminalFrame, UDim.new(0, 5))
        stroke(TerminalFrame, Color3.fromRGB(0, 255, 0), 1)

        local TerminalText = mk("TextLabel", {
            Size = UDim2.new(1, -20, 1, -20),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
            Text = "",
            TextColor3 = Color3.fromRGB(0, 255, 0),
            Font = Enum.Font.Code,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            RichText = true,
        }, TerminalFrame)

        local function typeWriter(text, label, delayMs)
            local current = label.Text
            if current ~= "" then current = current .. "\n" end
            label.Text = current
            local len = utf8.len(text) or #text
            for i = 1, len do
                local cut = utf8.offset(text, i + 1)
                local part = cut and string.sub(text, 1, cut - 1) or text
                label.Text = current .. part .. (i % 2 == 0 and "_" or "")
                task.wait(delayMs or 0.02)
            end
            label.Text = current .. text
        end

        connect(ConnectBtn.MouseButton1Click, function()
            if ConnectBtn.Text ~= buttonText then return end
            ConnectBtn.Visible = false
            TerminalFrame.Visible = true

            task.spawn(function()
                local gameName = connectCfg.GameName or "GAME"
                if not connectCfg.GameName then
                    pcall(function()
                        local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
                        if info and info.Name then gameName = info.Name end
                    end)
                end

                local lines = connectCfg.Lines
                if type(lines) == "function" then lines = lines(gameName) end
                lines = lines or {
                    "> Initializing secure session...",
                    "[+] Loading resources... 100%",
                    "> Verified: " .. gameName,
                }
                for _, line in ipairs(lines) do
                    typeWriter(line, TerminalText, 0.001)
                    task.wait(0.02)
                end
                task.wait(0.04)

                tween(TerminalText, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1 })
                task.wait(0.1)

                local GameLogo = mk("ImageLabel", {
                    Size = UDim2.new(0, 110, 0, 110),
                    Position = UDim2.new(0.5, -55, 0.5, -70),
                    BackgroundTransparency = 1,
                    Image = "rbxthumb://type=Asset&id=" .. (connectCfg.LogoId or game.PlaceId) .. "&w=150&h=150",
                    ImageTransparency = 1,
                }, TerminalFrame)
                corner(GameLogo, UDim.new(0, 12))
                local LogoStroke = stroke(GameLogo, Color3.fromRGB(0, 255, 0), 2, 1)

                local GameNameLbl = mk("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 30),
                    Position = UDim2.new(0, 0, 0.5, 55),
                    BackgroundTransparency = 1,
                    Text = (connectCfg.VerifyPrefix or "VERIFIED: ") .. string.upper(gameName),
                    TextColor3 = Color3.fromRGB(50, 255, 50),
                    Font = Enum.Font.GothamBold,
                    TextSize = 18,
                    TextTransparency = 1,
                }, TerminalFrame)

                local GameStatusLbl = mk("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 0, 0.5, 80),
                    BackgroundTransparency = 1,
                    Text = connectCfg.StatusText or "",
                    TextColor3 = Color3.fromRGB(150, 150, 150),
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextTransparency = 1,
                }, TerminalFrame)

                local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
                tween(GameLogo, tweenInfo, { ImageTransparency = 0, Position = UDim2.new(0.5, -55, 0.5, -90) })
                tween(LogoStroke, tweenInfo, { Transparency = 0.5 })
                tween(GameNameLbl, tweenInfo, { TextTransparency = 0, Position = UDim2.new(0, 0, 0.5, 35) })
                tween(GameStatusLbl, tweenInfo, { TextTransparency = 0, Position = UDim2.new(0, 0, 0.5, 60) })
                task.wait(0.35)

                local fadeOut = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                tween(GameLogo, fadeOut, { ImageTransparency = 1, Position = UDim2.new(0.5, -55, 0.5, -100) })
                tween(LogoStroke, fadeOut, { Transparency = 1 })
                tween(GameNameLbl, fadeOut, { TextTransparency = 1 })
                tween(GameStatusLbl, fadeOut, { TextTransparency = 1 })
                tween(TerminalFrame, fadeOut, { BackgroundTransparency = 1 })
                task.wait(0.12)

                GameLogo:Destroy()
                GameNameLbl:Destroy()
                GameStatusLbl:Destroy()

                self:Unlock((connectCfg.UnlockMessage or Library.Strings.Connected) .. " " .. gameName)
                if connectCfg.OnConnected then task.spawn(connectCfg.OnConnected, gameName) end
            end)
        end)
    end
    self.ConnectFrame = ConnectFrame

    ------------------------------------------------------------------
    -- Unlock (show the real menu)
    ------------------------------------------------------------------
    function self:Unlock(msg)
        self.Connected = true
        if LoginFrame then LoginFrame.Visible = false end
        MainFrame.Visible = true
        if ConnectFrame then ConnectFrame.Visible = false end
        Sidebar.Visible = true
        ContentArea.Visible = true
        StatusText.Visible = true
        StatusText.Text = '<font color="#00ff00">● CONNECTED</font>'
        Watermark.TextColor3 = self._wmConnected
        self:Notify("System", msg or Library.Strings.Connected)
    end

    ------------------------------------------------------------------
    -- Menu toggle key (slide animation)
    ------------------------------------------------------------------
    connect(UserInputService.InputBegan, function(input, gpe)
        if gpe then return end
        if input.KeyCode == self.Flags.ToggleKeybind and input.KeyCode ~= Enum.KeyCode.Unknown then
            if not self.Connected then
                if LoginFrame then
                    LoginFrame.Visible = not LoginFrame.Visible
                end
                return
            end
            self:Toggle()
        end
    end)

    ------------------------------------------------------------------
    -- Auto-save loop (optional)
    ------------------------------------------------------------------
    self._hasLoadedConfig = false
    if opts.Config and opts.Config.AutoSave then
        task.spawn(function()
            while self.Alive and task.wait(opts.Config.Interval or 30) do
                if self._hasLoadedConfig then
                    pcall(function() self:SaveConfig(true) end)
                end
            end
        end)
    end

    self._shownPos = shownPos
    self._hiddenPos = hiddenPos

    self:SetTheme(self.ThemeName)

    -- no login and no connect screen: open straight away
    if not loginCfg and not connectCfg then
        self:Unlock(opts.UnlockMessage)
    elseif not loginCfg and connectCfg then
        MainFrame.Visible = true
    end
    return self
end

----------------------------------------------------------------------
-- Window methods
----------------------------------------------------------------------
function Window:Notify(title, text)
    local Theme = self.Theme
    local Notif = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = Theme.PanelBg,
        BackgroundTransparency = 1,
    }, self.NotifyFrame)
    corner(Notif, UDim.new(0, 8))
    local Stroke = stroke(Notif, Color3.fromRGB(45, 45, 50), 1, 1)

    local Title = mk("TextLabel", {
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.TextWhite,
        TextTransparency = 1,
        Font = Theme.FontBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Notif)

    local Desc = mk("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 30),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.TextDark,
        TextTransparency = 1,
        Font = Theme.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Notif)

    local info = TweenInfo.new(0.3)
    tween(Notif, info, { BackgroundTransparency = 0 })
    tween(Stroke, info, { Transparency = 0 })
    tween(Title, info, { TextTransparency = 0 })
    tween(Desc, info, { TextTransparency = 0 })

    task.delay(3, function()
        if not Notif.Parent then return end
        tween(Notif, info, { BackgroundTransparency = 1 })
        tween(Stroke, info, { Transparency = 1 })
        tween(Title, info, { TextTransparency = 1 })
        tween(Desc, info, { TextTransparency = 1 })
        task.wait(0.3)
        Notif:Destroy()
    end)
end

function Window:ShowTooltip(text)
    local Tooltip = self.Tooltip
    if text and text ~= "" then
        Tooltip.Text = text
        Tooltip.Visible = true
        local pos = UserInputService:GetMouseLocation()
        Tooltip.Position = UDim2.new(0, pos.X + 14, 0, pos.Y + 14)
    else
        Tooltip.Visible = false
    end
end

function Window:SetStatus(richText)
    self.StatusText.Text = richText
end

function Window:SetWatermark(text, color)
    self.WatermarkFrame.Visible = true
    if text then self.Watermark.Text = text end
    if color then self.Watermark.TextColor3 = color end
end

function Window:SetCounter(value, visible)
    if value ~= nil then self.CounterLabel.Text = tostring(value) end
    if visible ~= nil then self.CounterBox.Visible = visible end
end

function Window:Show()
    if self.MainFrame.Visible then return end
    self.MainFrame.Position = self._hiddenPos
    self.MainFrame.Visible = true
    tween(self.MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), { Position = self._shownPos })
end

function Window:Hide()
    if not self.MainFrame.Visible then return end
    tween(self.MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), { Position = self._hiddenPos })
    task.delay(0.3, function() self.MainFrame.Visible = false end)
end

function Window:Toggle()
    if self.MainFrame.Visible then self:Hide() else self:Show() end
end

function Window:SetTheme(name)
    local p = Library.Themes[name] or Library.Themes.Dark
    self.ThemeName = name
    local Theme = self.Theme
    Theme.MainBg = p.MainBg
    Theme.PanelBg = p.PanelBg
    Theme.AccentOn = p.AccentOn
    Theme.AccentOff = p.AccentOff

    pcall(function() self.MainFrame.BackgroundColor3 = p.MainBg end)
    pcall(function() self.MainStroke.Color = p.Stroke end)
    if self.LoginFrame then
        pcall(function() self.LoginFrame.BackgroundColor3 = p.MainBg end)
    end

    for _, o in pairs(self._themed.Panels) do
        pcall(function()
            o.Bg.BackgroundColor3 = p.Panel
            o.Header.BackgroundColor3 = p.PanelBg
            o.HeaderSquare.BackgroundColor3 = p.PanelBg
            o.Stroke.Color = p.Stroke
        end)
    end
    for _, o in pairs(self._themed.Toggles) do
        pcall(function()
            o.Btn.BackgroundColor3 = o.State and p.AccentOn or p.AccentOff
            o.Knob.BackgroundColor3 = o.State and Theme.KnobOn or Theme.KnobOff
        end)
    end
    for _, o in pairs(self._themed.SliderFills) do
        pcall(function() o.Fill.BackgroundColor3 = p.AccentOn end)
    end
    for _, o in pairs(self._themed.Dropbox) do
        pcall(function() o.Box.BackgroundColor3 = Color3.fromRGB(35, 35, 38) end)
    end
end

-- Tab indicator: lit for the active tab, or any tab that has an enabled toggle
function Window:UpdateTabDots()
    for _, tab in ipairs(self.TabList) do
        local anyOn = false
        for flag in pairs(tab.ActiveFlags) do
            if self.Flags[flag] then
                anyOn = true
                break
            end
        end
        local ind = tab.Button:FindFirstChild("Indicator")
        if ind then ind.Visible = anyOn or (self.ActiveTab == tab) end
    end
end

function Window:Set(flag, value)
    local el = self.Elements[flag]
    if el and el.SetValue then el.SetValue(value) end
end

function Window:Get(flag)
    return self.Flags[flag]
end

function Window:SaveConfig(silent)
    local S = Library.Strings
    local cfg = self.Options.Config or {}
    local ok, err = pcall(function()
        if not writefile then
            if not silent then self:Notify("Lỗi Lưu", S.ConfigNoWrite) end
            return
        end
        local data = {}
        for k, v in pairs(self.Flags) do
            local t = typeof(v)
            if t == "EnumItem" then
                data[k] = "Enum." .. tostring(v.EnumType) .. "." .. tostring(v.Name)
            elseif t == "boolean" or t == "number" or t == "string" then
                data[k] = v
            end
        end
        local encodeOk, encoded = pcall(function() return HttpService:JSONEncode(data) end)
        if encodeOk and encoded and encoded ~= "" then
            writefile(cfg.File or "MenuConfig.json", encoded)
            self._hasLoadedConfig = true
            if not silent then self:Notify(S.ConfigTitle, S.ConfigSaved) end
        end
    end)
    if not ok then warn("SaveConfig error:", err) end
end

function Window:LoadConfig(silent)
    local S = Library.Strings
    local cfg = self.Options.Config or {}
    local ok, err = pcall(function()
        if not (readfile and isfile) then
            if not silent then self:Notify("Lỗi Tải", S.ConfigNoRead) end
            return
        end
        local file = cfg.File or "MenuConfig.json"
        if not isfile(file) then
            self._hasLoadedConfig = true
            if not silent then self:Notify("Thông Báo", S.ConfigNoFile) end
            return
        end
        local raw = readfile(file)
        if not raw or raw == "" then return end

        local decodeOk, data = pcall(function() return HttpService:JSONDecode(raw) end)
        if not decodeOk or type(data) ~= "table" then
            if not silent then self:Notify("Lỗi Cấu Hình", S.ConfigBadFile) end
            return
        end

        for k, v in pairs(data) do
            local current = self.Flags[k]
            if current ~= nil then
                if type(v) == "string" and v:sub(1, 5) == "Enum." then
                    local parts = v:split(".")
                    if #parts >= 3 then
                        local enumType, enumName = parts[2], parts[3]
                        if Enum[enumType] and Enum[enumType][enumName] then
                            self.Flags[k] = Enum[enumType][enumName]
                        end
                    end
                elseif type(v) == type(current) then
                    self.Flags[k] = v
                end
            end
        end

        for key, el in pairs(self.Elements) do
            if self.Flags[key] ~= nil and el.SetValue then
                pcall(function() el.SetValue(self.Flags[key]) end)
            end
        end

        self._hasLoadedConfig = true
        if not silent then self:Notify(S.ConfigTitle, S.ConfigLoaded) end
    end)
    if not ok then warn("LoadConfig error:", err) end
end

function Window:Destroy()
    if not self.Alive then return end
    self.Alive = false
    for _, c in ipairs(self.Connections) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(self.Connections)
    if self.Gui then self.Gui:Destroy() end
    if self.Options.OnClose then pcall(self.Options.OnClose) end
end

----------------------------------------------------------------------
-- Tabs
----------------------------------------------------------------------
function Window:AddTab(o)
    o = o or {}
    local Theme = self.Theme
    local name = o.Name or ("Tab" .. (#self.TabList + 1))
    local icon = o.Icon or ""
    local index = #self.TabList + 1
    local yPos = o.Y or (10 + (index - 1) * 45)

    local TabContent = mk("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
    }, self.ContentArea)

    local Btn = mk("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0.5, -15, 0, yPos),
        BackgroundTransparency = 1,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Text = "",
    }, self.Sidebar)
    corner(Btn, UDim.new(0, 8))

    local Icon
    if isAssetIcon(icon) then
        Icon = mk("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0.5, -8, 0.5, -8),
            BackgroundTransparency = 1,
            Image = icon,
            ImageColor3 = Theme.TextDark,
        }, Btn)
    else
        Icon = mk("TextLabel", {
            Name = "Icon",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = icon ~= "" and icon or string.sub(name, 1, 1),
            TextColor3 = Theme.TextDark,
            Font = Enum.Font.Gotham,
            TextSize = 18,
        }, Btn)
    end

    local Indicator = mk("Frame", {
        Name = "Indicator",
        Size = UDim2.new(0, 3, 0, 16),
        Position = UDim2.new(0, -10, 0.5, -8),
        BackgroundColor3 = Theme.DotGreen,
        BorderSizePixel = 0,
        Visible = false,
    }, Btn)
    corner(Indicator, UDim.new(1, 0))

    local tab = setmetatable({
        Name = name,
        Window = self,
        Content = TabContent,
        Button = Btn,
        Icon = Icon,
        ActiveFlags = {},
        PanelCount = 0,
    }, Tab)

    self.Tabs[name] = tab
    table.insert(self.TabList, tab)

    local function setIconColor(t, color)
        local ic = t.Button:FindFirstChild("Icon")
        if ic then
            if ic:IsA("ImageLabel") then ic.ImageColor3 = color else ic.TextColor3 = color end
        end
    end

    function tab:Select()
        local win = self.Window
        if win.ActiveTab == self then return end
        local old = win.ActiveTab
        if old then
            old.Content.Visible = false
            old.Button.BackgroundTransparency = 1
            setIconColor(old, win.Theme.TextDark)
        end
        win.ActiveTab = self
        self.Content.Visible = true
        self.Button.BackgroundTransparency = 0.9
        setIconColor(self, win.Theme.TextWhite)
        win.ContentArea.Position = UDim2.new(0, 32, 0, 40)
        tween(win.ContentArea, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Position = UDim2.new(0, 50, 0, 40) })
        win:UpdateTabDots()
    end

    self._connect(Btn.MouseButton1Click, function() tab:Select() end)

    self._connect(Btn.MouseEnter, function()
        if self.ActiveTab ~= tab then
            tween(Btn, TweenInfo.new(0.2), { BackgroundTransparency = 0.95 })
        end
    end)
    self._connect(Btn.MouseLeave, function()
        if self.ActiveTab ~= tab then
            tween(Btn, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
        end
    end)

    -- first tab is active from the start
    if index == 1 then
        TabContent.Visible = true
        Btn.BackgroundTransparency = 0.9
        setIconColor(tab, Theme.TextWhite)
        Indicator.Visible = true
        self.ActiveTab = tab
    end

    return tab
end

----------------------------------------------------------------------
-- Panels
----------------------------------------------------------------------
function Tab:AddPanel(o)
    o = o or {}
    local win = self.Window
    local Theme = win.Theme
    local name = o.Name or "Panel"
    local icon = o.Icon or ""

    self.PanelCount = self.PanelCount + 1
    local n = self.PanelCount
    local posX = o.Position and o.Position.X or ((n % 2 == 1) and 0 or 0.5)
    local posY = o.Position and o.Position.Y or 0
    local sizeX = o.Size and o.Size.X or 0.5
    local sizeY = o.Size and o.Size.Y or 1

    local PanelFrame = mk("Frame", {
        Name = name,
        Size = UDim2.new(sizeX, -14, sizeY, -14),
        Position = UDim2.new(posX, 7, posY, 7),
        BackgroundColor3 = Color3.fromRGB(22, 22, 25),
        BorderSizePixel = 0,
    }, self.Content)
    corner(PanelFrame, UDim.new(0, 8))

    local HeaderBg = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundColor3 = Theme.PanelBg,
        BorderSizePixel = 0,
    }, PanelFrame)
    corner(HeaderBg, UDim.new(0, 8))

    local HeaderSquare = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = Theme.PanelBg,
        BorderSizePixel = 0,
    }, HeaderBg)

    mk("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(45, 45, 50),
        BorderSizePixel = 0,
    }, HeaderBg)

    local titleText = name
    local titleX = 15
    if icon ~= "" then
        if isAssetIcon(icon) then
            mk("ImageLabel", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 15, 0, 14),
                BackgroundTransparency = 1,
                Image = icon,
                ImageColor3 = Theme.TextWhite,
            }, HeaderBg)
            titleX = 38
        else
            titleText = icon .. "  " .. name
        end
    end

    mk("TextLabel", {
        Size = UDim2.new(1, -30, 0, 45),
        Position = UDim2.new(0, titleX, 0, 0),
        BackgroundTransparency = 1,
        Text = titleText,
        TextColor3 = Theme.TextWhite,
        Font = Theme.FontBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, HeaderBg)

    local Container = mk("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -50),
        Position = UDim2.new(0, 0, 0, 45),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
    }, PanelFrame)

    local PanelStroke = stroke(PanelFrame, Color3.fromRGB(45, 45, 50), 1)

    table.insert(win._themed.Panels, {
        Bg = PanelFrame,
        Header = HeaderBg,
        HeaderSquare = HeaderSquare,
        Stroke = PanelStroke,
    })

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.Parent = Container

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 15)
    padding.PaddingRight = UDim.new(0, 15)
    padding.Parent = Container

    Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)

    win:SetTheme(win.ThemeName)

    return setmetatable({
        Window = win,
        Tab = self,
        Frame = PanelFrame,
        Container = Container,
    }, Panel)
end

----------------------------------------------------------------------
-- Element internals
----------------------------------------------------------------------
local function registerRow(panel, flag, text, Frame, extraFlags)
    local win, tab = panel.Window, panel.Tab
    if flag then
        win.SearchIndex[flag] = { Label = text, Frame = Frame, Tab = tab.Name }
    end
    if extraFlags then
        for f, label in pairs(extraFlags) do
            win.SearchIndex[f] = { Label = label, Frame = Frame, Tab = tab.Name }
        end
    end
end

local function hookTooltip(win, Frame, text)
    local tip = stripRich(text)
    win._connect(Frame.MouseEnter, function() win:ShowTooltip(tip) end)
    win._connect(Frame.MouseLeave, function() win:ShowTooltip(nil) end)
end

local function initFlag(win, flag, default)
    if not flag then return default end
    if default == nil then default = win.Flags[flag] end
    win.Flags[flag] = default
    return default
end

-- Dropdown control (box + arrow + list) shared by every dropdown variant
local function buildDropdown(win, Frame, cfg)
    local Theme = win.Theme

    local Dropbox = mk("TextButton", {
        Size = UDim2.new(0, cfg.Width, 0, 24),
        Position = cfg.BoxPos,
        BackgroundColor3 = Color3.fromRGB(35, 35, 38),
        Text = "",
    }, Frame)
    corner(Dropbox, UDim.new(0, 6))

    local ValLabel = mk("TextLabel", {
        Size = cfg.ValSize,
        Position = cfg.ValPos,
        BackgroundTransparency = 1,
        Text = cfg.InitialText or "",
        TextColor3 = Theme.TextWhite,
        Font = Theme.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Dropbox)

    local Arrow = mk("TextLabel", {
        Size = cfg.ArrowSize,
        Position = cfg.ArrowPos,
        BackgroundTransparency = 1,
        Text = "v",
        TextColor3 = Theme.TextDark,
        Font = Theme.Font,
        TextSize = cfg.ArrowTextSize,
    }, Dropbox)

    local ListFrame = mk("Frame", {
        Position = cfg.ListPos,
        BackgroundColor3 = Color3.fromRGB(30, 30, 33),
        BorderSizePixel = 0,
    }, Frame)
    corner(ListFrame, UDim.new(0, 6))
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = ListFrame

    table.insert(win._themed.Dropbox, { Box = Dropbox })

    local isOpen = false
    local listSize = 0

    local function closeList()
        isOpen = false
        tween(Frame, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, 35) })
        Arrow.Text = "v"
    end

    local function populate(list)
        for _, child in ipairs(ListFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for _, opt in ipairs(list) do
            local b = mk("TextButton", {
                Size = UDim2.new(1, 0, 0, 25),
                BackgroundTransparency = 1,
                Text = opt,
                TextColor3 = Theme.TextWhite,
                Font = Theme.Font,
                TextSize = 12,
            }, ListFrame)
            b.MouseButton1Click:Connect(function()
                ValLabel.Text = opt
                closeList()
                cfg.OnSelect(opt)
            end)
        end
    end

    if cfg.Options then
        listSize = #cfg.Options * 25
        ListFrame.Size = UDim2.new(0, cfg.Width, 0, listSize)
        populate(cfg.Options)
    end

    win._connect(Dropbox.MouseButton1Click, function()
        isOpen = not isOpen
        if isOpen then
            if cfg.GetOptions then
                local list = cfg.GetOptions()
                listSize = math.min(#list, cfg.MaxVisible or 6) * 25
                ListFrame.Size = UDim2.new(0, cfg.Width, 0, listSize)
                populate(list)
            end
            tween(Frame, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, 35 + listSize) })
            Arrow.Text = "^"
        else
            closeList()
        end
    end)

    return { Dropbox = Dropbox, ValLabel = ValLabel }
end

-- Keybind control shared by AddKeybind and AddToggleKeybind
local function buildKeybind(win, Frame, cfg)
    local Theme = win.Theme
    local KeyBtn = mk("TextButton", {
        Size = UDim2.new(0, cfg.Width, 0, 24),
        Position = cfg.Pos,
        BackgroundColor3 = Color3.fromRGB(35, 35, 38),
        Text = formatKey(cfg.Default),
        TextColor3 = Theme.TextWhite,
        Font = Theme.Font,
        TextSize = 12,
    }, Frame)
    corner(KeyBtn, UDim.new(0, 6))
    table.insert(win._themed.Dropbox, { Box = KeyBtn })

    local isBinding = false
    local connection

    win._connect(KeyBtn.MouseButton1Click, function()
        if isBinding then return end
        KeyBtn.Text = "..."
        task.wait(0.1)
        isBinding = true

        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard
                or input.UserInputType.Name:match("MouseButton") then
                local newKey = (input.KeyCode == Enum.KeyCode.Unknown)
                    and input.UserInputType or input.KeyCode
                if newKey.Name == "Unknown" then return end

                isBinding = false
                KeyBtn.Text = formatKey(newKey)
                cfg.OnBind(newKey)

                if connection then
                    connection:Disconnect()
                    connection = nil
                end
            end
        end)
    end)

    return KeyBtn
end

-- Toggle row (plain / safe / with dropdown / with keybind)
local function buildToggle(panel, o, mode)
    local win = panel.Window
    local Theme = win.Theme
    local S = Library.Strings
    local text = o.Text or "Toggle"
    local flag = o.Flag

    local initial = initFlag(win, flag, o.Default)
    initial = initial and true or false
    if flag then win.Flags[flag] = initial end

    local dotColor = o.DotColor
    if dotColor == nil then dotColor = Theme.DotGreen elseif dotColor == false then dotColor = nil end

    local Frame = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = (mode == "dropdown"),
    }, panel.Container)

    if dotColor then
        local Dot = mk("Frame", {
            Size = UDim2.new(0, 6, 0, 6),
            Position = UDim2.new(0, 0, 0.5, -3),
            BackgroundColor3 = dotColor,
            BorderSizePixel = 0,
        }, Frame)
        corner(Dot, UDim.new(1, 0))
    end

    local labelSize = (mode == "dropdown" or mode == "keybind") and UDim2.new(1, -145, 0, 35) or UDim2.new(1, -70, 1, 0)
    mk("TextLabel", {
        Size = labelSize,
        Position = UDim2.new(0, dotColor and 15 or 0, 0, 0),
        BackgroundTransparency = 1,
        RichText = true,
        Text = text,
        TextColor3 = (mode == "safe") and Color3.fromRGB(255, 50, 50) or Theme.TextWhite,
        Font = (mode == "safe") and Theme.FontBold or Theme.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Frame)

    local extraFlags = nil

    -- dropdown beside the switch
    if mode == "dropdown" then
        local dd = o.Dropdown or {}
        local options = dd.Options or {}
        local dflag = dd.Flag
        local dval = initFlag(win, dflag, dd.Default)
        if dval == nil then dval = options[1] end
        if dflag then win.Flags[dflag] = dval end

        local ddRef = buildDropdown(win, Frame, {
            Width = 75,
            BoxPos = UDim2.new(1, -125, 0, 5),
            ValSize = UDim2.new(1, -20, 1, 0),
            ValPos = UDim2.new(0, 6, 0, 0),
            ArrowSize = UDim2.new(0, 16, 1, 0),
            ArrowPos = UDim2.new(1, -16, 0, 0),
            ArrowTextSize = 11,
            ListPos = UDim2.new(1, -125, 0, 32),
            Options = options,
            InitialText = tostring(dval or ""),
            OnSelect = function(opt)
                if dflag then win.Flags[dflag] = opt end
                if dd.Callback then dd.Callback(opt) end
            end,
        })
        if dflag then
            win.Elements[dflag] = {
                SetValue = function(val)
                    win.Flags[dflag] = val
                    ddRef.ValLabel.Text = tostring(val)
                    if dd.Callback then dd.Callback(val) end
                end,
            }
        end
        extraFlags = dflag and { [dflag] = dd.Text or "Option" } or nil
    end

    -- keybind beside the switch
    if mode == "keybind" then
        local kb = o.Keybind or {}
        local kflag = kb.Flag
        local kval = initFlag(win, kflag, kb.Default)
        if kflag then win.Flags[kflag] = kval end

        local KeyBtn = buildKeybind(win, Frame, {
            Width = 75,
            Pos = UDim2.new(1, -125, 0, 5),
            Default = kval,
            OnBind = function(newKey)
                if kflag then win.Flags[kflag] = newKey end
                if kb.Callback then kb.Callback(newKey) end
            end,
        })
        if kflag then
            win.Elements[kflag] = {
                SetValue = function(val)
                    win.Flags[kflag] = val
                    KeyBtn.Text = formatKey(val)
                    if kb.Callback then kb.Callback(val) end
                end,
            }
        end
        extraFlags = kflag and { [kflag] = kb.Text or "Key" } or nil
    end

    -- switch
    local ToggleBtn = mk("TextButton", {
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -40, 0.5, -10),
        BackgroundColor3 = initial and Theme.AccentOn or Theme.AccentOff,
        Text = "",
    }, Frame)
    corner(ToggleBtn, UDim.new(1, 0))

    local Knob = mk("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = initial and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = initial and Theme.KnobOn or Theme.KnobOff,
        BorderSizePixel = 0,
    }, ToggleBtn)
    corner(Knob, UDim.new(1, 0))

    local state = initial

    local function setVisual(val)
        tween(ToggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = val and Theme.AccentOn or Theme.AccentOff,
        })
        tween(Knob, TweenInfo.new(0.2), {
            Position = val and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
            BackgroundColor3 = val and Theme.KnobOn or Theme.KnobOff,
        })
    end

    if flag then panel.Tab.ActiveFlags[flag] = true end
    registerRow(panel, flag, text, Frame, extraFlags)

    table.insert(win._themed.Toggles, { Btn = ToggleBtn, Knob = Knob, State = initial })
    local reg = win._themed.Toggles[#win._themed.Toggles]

    local element = {
        Frame = Frame,
        Get = function() return state end,
        SetValue = function(val)
            state = val and true or false
            reg.State = state
            if flag then win.Flags[flag] = state end
            setVisual(state)
            win:UpdateTabDots()
            if o.Callback then o.Callback(state) end
        end,
    }
    if flag then win.Elements[flag] = element end

    hookTooltip(win, Frame, o.Tooltip or text)

    local warnState = 0
    win._connect(ToggleBtn.MouseButton1Click, function()
        if mode == "safe" then
            if state == true and warnState == 0 then
                warnState = 1
                win:Notify(o.WarnTitle or S.Danger, o.WarnText or S.SafeWarn)
                ToggleBtn.BackgroundColor3 = Theme.DotRed
                task.delay(3, function()
                    if warnState == 1 then
                        warnState = 0
                        ToggleBtn.BackgroundColor3 = Theme.AccentOn
                    end
                end)
                return
            end
            warnState = 0
        end

        state = not state
        reg.State = state
        if flag then win.Flags[flag] = state end
        setVisual(state)

        if mode == "safe" then
            if state then
                win:Notify(o.OnTitle or S.SafeOnTitle, o.OnText or S.SafeOnText)
            else
                win:Notify(o.OffTitle or S.Danger, o.OffText or S.SafeOffText)
            end
        else
            win:Notify(state and S.On or S.Off, stripRich(text))
        end

        win:UpdateTabDots()
        if o.Callback then o.Callback(state) end
    end)

    return element
end

----------------------------------------------------------------------
-- Panel elements
----------------------------------------------------------------------
function Panel:AddSection(text)
    local Theme = self.Window.Theme
    return mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Text = "— " .. text .. " —",
        TextColor3 = Theme.TextDark,
        Font = Theme.FontBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, self.Container)
end

function Panel:AddToggle(o) return buildToggle(self, o, "plain") end
function Panel:AddSafeToggle(o) return buildToggle(self, o, "safe") end
function Panel:AddToggleDropdown(o) return buildToggle(self, o, "dropdown") end
function Panel:AddToggleKeybind(o) return buildToggle(self, o, "keybind") end

function Panel:AddDropdown(o)
    local win = self.Window
    local Theme = win.Theme
    local text = o.Text or "Dropdown"
    local flag = o.Flag
    local options = o.Options or {}

    local current = initFlag(win, flag, o.Default)
    if current == nil then current = options[1] end
    if flag then win.Flags[flag] = current end

    local Frame = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, self.Container)

    mk("TextLabel", {
        Size = UDim2.new(0, 150, 0, 35),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.TextWhite,
        Font = Theme.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Frame)

    local dd = buildDropdown(win, Frame, {
        Width = 100,
        BoxPos = UDim2.new(1, -100, 0, 5),
        ValSize = UDim2.new(1, -25, 1, 0),
        ValPos = UDim2.new(0, 10, 0, 0),
        ArrowSize = UDim2.new(0, 20, 1, 0),
        ArrowPos = UDim2.new(1, -20, 0, 0),
        ArrowTextSize = 12,
        ListPos = UDim2.new(1, -100, 0, 32),
        Options = options,
        InitialText = tostring(current or ""),
        OnSelect = function(opt)
            if flag then win.Flags[flag] = opt end
            if o.Callback then o.Callback(opt) end
        end,
    })

    registerRow(self, flag, text, Frame)
    local element = {
        Frame = Frame,
        Get = function() return flag and win.Flags[flag] end,
        SetValue = function(val)
            if flag then win.Flags[flag] = val end
            dd.ValLabel.Text = tostring(val)
            if o.Callback then o.Callback(val) end
        end,
    }
    if flag then win.Elements[flag] = element end
    hookTooltip(win, Frame, o.Tooltip or text)
    return element
end

function Panel:AddKeybind(o)
    local win = self.Window
    local Theme = win.Theme
    local text = o.Text or "Keybind"
    local flag = o.Flag

    local current = initFlag(win, flag, o.Default)
    if flag then win.Flags[flag] = current end

    local Frame = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, self.Container)

    mk("TextLabel", {
        Size = UDim2.new(0, 150, 0, 35),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.TextWhite,
        Font = Theme.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Frame)

    local KeyBtn = buildKeybind(win, Frame, {
        Width = 80,
        Pos = UDim2.new(1, -80, 0, 5),
        Default = current,
        OnBind = function(newKey)
            if flag then win.Flags[flag] = newKey end
            if o.Callback then o.Callback(newKey) end
        end,
    })

    registerRow(self, flag, text, Frame)
    local element = {
        Frame = Frame,
        Get = function() return flag and win.Flags[flag] end,
        SetValue = function(val)
            if flag then win.Flags[flag] = val end
            KeyBtn.Text = formatKey(val)
            if o.Callback then o.Callback(val) end
        end,
    }
    if flag then win.Elements[flag] = element end
    hookTooltip(win, Frame, o.Tooltip or text)
    return element
end

function Panel:AddPlayerDropdown(o)
    local win = self.Window
    local Theme = win.Theme
    local S = Library.Strings
    local text = o.Text or "Player"
    local flag = o.Flag
    local placeholder = o.Placeholder or S.PlayerPlaceholder

    local current = initFlag(win, flag, o.Default)
    if current == nil then current = "" end
    if flag then win.Flags[flag] = current end

    local Frame = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, self.Container)

    mk("TextLabel", {
        Size = UDim2.new(0, 150, 0, 35),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.TextWhite,
        Font = Theme.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Frame)

    local dd = buildDropdown(win, Frame, {
        Width = 100,
        BoxPos = UDim2.new(1, -100, 0, 5),
        ValSize = UDim2.new(1, -25, 1, 0),
        ValPos = UDim2.new(0, 10, 0, 0),
        ArrowSize = UDim2.new(0, 20, 1, 0),
        ArrowPos = UDim2.new(1, -20, 0, 0),
        ArrowTextSize = 12,
        ListPos = UDim2.new(1, -100, 0, 32),
        MaxVisible = 6,
        GetOptions = function()
            local names = {}
            for _, p in ipairs(Players:GetPlayers()) do
                table.insert(names, p.Name)
            end
            return names
        end,
        InitialText = (current == "" or current == nil) and placeholder or current,
        OnSelect = function(name)
            if flag then win.Flags[flag] = name end
            if o.Callback then o.Callback(name) end
        end,
    })

    registerRow(self, flag, text, Frame)
    local element = {
        Frame = Frame,
        Get = function() return flag and win.Flags[flag] end,
        SetValue = function(val)
            if flag then win.Flags[flag] = val end
            dd.ValLabel.Text = (val == "" or val == nil) and placeholder or val
            if o.Callback then o.Callback(val) end
        end,
    }
    if flag then win.Elements[flag] = element end
    hookTooltip(win, Frame, o.Tooltip or text)
    return element
end

function Panel:AddSlider(o)
    local win = self.Window
    local Theme = win.Theme
    local text = o.Text or "Slider"
    local flag = o.Flag
    local min, max = o.Min or 0, o.Max or 100
    local suffix = o.Suffix

    local value = initFlag(win, flag, o.Default)
    if value == nil then value = min end
    if flag then win.Flags[flag] = value end

    local Frame = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, self.Container)

    mk("TextLabel", {
        Size = UDim2.new(0, 120, 1, 0),
        BackgroundTransparency = 1,
        RichText = true,
        Text = text,
        TextColor3 = Theme.TextWhite,
        Font = Theme.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Frame)

    local hasSuffix = suffix and suffix ~= ""
    local inputOffset = hasSuffix and -60 or -40

    local ValInput = mk("TextBox", {
        Size = UDim2.new(0, 35, 0, 20),
        Position = UDim2.new(1, inputOffset, 0.5, -10),
        BackgroundColor3 = Color3.fromRGB(35, 35, 38),
        TextColor3 = Theme.TextWhite,
        Font = Theme.Font,
        TextSize = 12,
        Text = tostring(value),
    }, Frame)
    corner(ValInput, UDim.new(0, 4))

    if hasSuffix then
        mk("TextLabel", {
            Size = UDim2.new(0, 20, 1, 0),
            Position = UDim2.new(1, -20, 0, 0),
            BackgroundTransparency = 1,
            Text = (suffix:gsub(" ", "")),
            TextColor3 = Theme.TextDark,
            Font = Theme.Font,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, Frame)
    end

    local SliderBg = mk("TextButton", {
        Size = UDim2.new(1, -190, 0, 4),
        Position = UDim2.new(0, 125, 0.5, -2),
        BackgroundColor3 = Color3.fromRGB(40, 40, 42),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, Frame)
    corner(SliderBg, UDim.new(1, 0))

    local pct = math.clamp((value - min) / (max - min), 0, 1)
    local SliderFill = mk("Frame", {
        Size = UDim2.new(pct, 0, 1, 0),
        BackgroundColor3 = Theme.TextWhite,
        BorderSizePixel = 0,
    }, SliderBg)
    corner(SliderFill, UDim.new(1, 0))

    local Knob = mk("Frame", {
        Size = UDim2.new(0, 10, 0, 10),
        Position = UDim2.new(1, -5, 0.5, -5),
        BackgroundColor3 = Theme.TextWhite,
        BorderSizePixel = 0,
    }, SliderFill)
    corner(Knob, UDim.new(1, 0))

    table.insert(win._themed.SliderFills, { Fill = SliderFill })

    local dragging = false
    local function updateSlider(p)
        p = math.clamp(p, 0, 1)
        SliderFill.Size = UDim2.new(p, 0, 1, 0)
        local newVal = min + (max - min) * p
        if max <= 1 then
            newVal = math.floor(newVal * 100) / 100
        else
            newVal = math.floor(newVal * 10) / 10
        end
        ValInput.Text = tostring(newVal)
        if flag then win.Flags[flag] = newVal end
        if o.Callback then o.Callback(newVal) end
    end

    local function posFromInput(input)
        return (input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X
    end

    win._connect(SliderBg.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(posFromInput(input))
        end
    end)
    win._connect(UserInputService.InputChanged, function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(posFromInput(input))
        end
    end)
    win._connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    win._connect(ValInput.FocusLost, function()
        local num = tonumber(ValInput.Text)
        if num then
            num = math.clamp(num, min, max)
            updateSlider((num - min) / (max - min))
        else
            updateSlider(SliderFill.Size.X.Scale)
        end
    end)

    registerRow(self, flag, text, Frame)
    local element = {
        Frame = Frame,
        Get = function() return flag and win.Flags[flag] end,
        SetValue = function(val)
            local p = math.clamp((val - min) / (max - min), 0, 1)
            SliderFill.Size = UDim2.new(p, 0, 1, 0)
            ValInput.Text = tostring(val)
            if flag then win.Flags[flag] = val end
            if o.Callback then o.Callback(val) end
        end,
    }
    if flag then win.Elements[flag] = element end
    hookTooltip(win, Frame, o.Tooltip or text)
    return element
end

-- Style: "Default" | "Success" | "Info" (the three button looks used in the original)
local ButtonStyles = {
    Default = {
        Height = 30, Bg = Color3.fromRGB(38, 38, 44), Text = Color3.fromRGB(175, 175, 185),
        Bold = false, TextSize = 12,
    },
    Success = {
        Height = 32, Bg = Color3.fromRGB(0, 210, 110), Text = Color3.fromRGB(10, 25, 18),
        Bold = true, TextSize = 13,
    },
    Info = {
        Height = 30, Bg = Color3.fromRGB(35, 45, 60), Text = nil,
        Bold = true, TextSize = 13,
    },
}

function Panel:AddButton(o)
    local win = self.Window
    local Theme = win.Theme
    local style = ButtonStyles[o.Style or "Default"] or ButtonStyles.Default
    local Btn = mk("TextButton", {
        Size = UDim2.new(1, 0, 0, style.Height),
        BackgroundColor3 = style.Bg,
        TextColor3 = style.Text or Theme.TextWhite,
        Font = style.Bold and Theme.FontBold or Theme.Font,
        TextSize = style.TextSize,
        Text = o.Text or "Button",
    }, self.Container)
    corner(Btn, UDim.new(0, 6))
    win._connect(Btn.MouseButton1Click, function()
        if o.Callback then o.Callback() end
    end)
    return Btn
end

function Panel:AddConfirmButton(o)
    local win = self.Window
    local Theme = win.Theme
    local S = Library.Strings
    local text = o.Text or "Button"

    local Frame = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, self.Container)

    local Btn = mk("TextButton", {
        Size = UDim2.new(1, -30, 1, -10),
        Position = UDim2.new(0, 15, 0, 5),
        BackgroundColor3 = Theme.AccentOff,
        TextColor3 = Theme.TextWhite,
        Font = Theme.FontBold,
        TextSize = 13,
        Text = text,
    }, Frame)
    corner(Btn, UDim.new(0, 6))

    local state = 0
    win._connect(Btn.MouseButton1Click, function()
        if state == 0 then
            state = 1
            Btn.Text = S.ConfirmPrompt
            Btn.BackgroundColor3 = Theme.DotRed
            win:Notify(S.Danger, o.WarningText or "")
            task.delay(3, function()
                if state == 1 then
                    state = 0
                    Btn.Text = text
                    Btn.BackgroundColor3 = Theme.AccentOff
                end
            end)
        elseif state == 1 then
            state = 2
            Btn.Text = S.Activated
            Btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            if o.Callback then o.Callback() end
        end
    end)
    return Btn
end

return Library
