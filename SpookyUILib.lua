--[[
    SpookyUILib  —  UI Library แยกมาจากหน้าต่าง UI ของ "Spooky Hub"
    ------------------------------------------------------------------
    ขนาด สี ฟอนต์ มุมโค้ง เส้นขอบ อนิเมชัน (Pop/Bounce/SlideUp/SlideDown/ZoomSmooth/Fade)
    แถบแท็บซ้าย, ช่อง Log ขวา, หน้า Home, ปุ่มลอยเปิด/ปิด, ธีมสี ฯลฯ คงตามต้นฉบับ

    ใช้งานเร็ว ๆ:
        local Library = loadstring(readfile("SpookyUILib.lua"))()
        local Window  = Library:CreateWindow({ Title = "SPOOKY" })
        local Tab     = Window:AddTab({ Id = "Combat", Label = "Combat" })
        local Card    = Tab:AddCard({ Title = "Targeting & Aim" })
        Card:AddToggle({ Name = "Aimbot", Callback = function(v) print(v) end })

    ดูตัวอย่างเต็มในไฟล์ SpookyUILib_Example.lua
]]

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")
local StarterGui       = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

local ICON_ID      = "rbxassetid://124747708335361"
local WALLPAPER_ID = "rbxassetid://98256258425377"
local BANNER_ID    = "rbxassetid://139775297797213"

local Library = {
    Version   = "1.0",
    Flags     = {},
    Windows   = {},
    Language  = "EN",
    Themes    = {
        ["White"]  = { accent = Color3.fromRGB(255, 255, 255), bright = Color3.fromRGB(235, 235, 245) },
        ["Purple"] = { accent = Color3.fromRGB(160, 130, 255), bright = Color3.fromRGB(195, 170, 255) },
        ["Red"]    = { accent = Color3.fromRGB(255, 60, 75),   bright = Color3.fromRGB(255, 115, 125) },
        ["Cyan"]   = { accent = Color3.fromRGB(0, 215, 255),   bright = Color3.fromRGB(90, 235, 255) },
        ["Green"]  = { accent = Color3.fromRGB(50, 225, 120),  bright = Color3.fromRGB(110, 255, 170) },
        ["Blue"]   = { accent = Color3.fromRGB(65, 145, 255),  bright = Color3.fromRGB(120, 180, 255) },
        ["Yellow"] = { accent = Color3.fromRGB(255, 215, 50),  bright = Color3.fromRGB(255, 235, 110) },
        ["Orange"] = { accent = Color3.fromRGB(255, 135, 30),  bright = Color3.fromRGB(255, 175, 75) },
        ["Pink"]   = { accent = Color3.fromRGB(255, 105, 180), bright = Color3.fromRGB(255, 155, 210) },
        ["Gold"]   = { accent = Color3.fromRGB(238, 190, 40),  bright = Color3.fromRGB(255, 215, 80) },
        ["Spooky Dark"] = { accent = Color3.fromRGB(238, 190, 40), bright = Color3.fromRGB(255, 215, 80) },
    },
    ThemeOrder = { "White", "Purple", "Red", "Cyan", "Green", "Blue", "Yellow", "Orange", "Pink", "Gold", "Spooky Dark" },
}
Library.__index = Library

-- ============================================================
-- Utilities
-- ============================================================
local function New(class, props, parent)
    local obj = Instance.new(class)
    if props then
        for k, v in pairs(props) do obj[k] = v end
    end
    if parent then obj.Parent = parent end
    return obj
end

local function Corner(parent, radius)
    return New("UICorner", { CornerRadius = radius }, parent)
end

local function Stroke(parent, color, thickness)
    return New("UIStroke", { Color = color, Thickness = thickness }, parent)
end

local function Tween(obj, info, props)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function getSafeParent()
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    if syn and syn.protect_gui then
        pcall(syn.protect_gui, PlayerGui)
    end
    return PlayerGui
end

local function safeParent(gui)
    local target = getSafeParent()
    local ok = pcall(function() gui.Parent = target end)
    if not ok or not gui.Parent then
        pcall(function() gui.Parent = PlayerGui end)
    end
end

local function computeScale()
    local camera = workspace.CurrentCamera
    if not camera then return 0.85 end
    local vp = camera.ViewportSize
    local scaleX = (vp.X * 0.92) / 650
    local scaleY = (vp.Y * 0.90) / 369
    local minScale = math.min(scaleX, scaleY, 1)
    return math.clamp(minScale * 0.95, 0.35, 1.0)
end

-- รองรับข้อความแบบ string หรือ { EN = "...", ES = "...", TH = "..." }
local function tr(value)
    if type(value) == "table" then
        return value[Library.Language] or value.EN or value[next(value)] or ""
    end
    return tostring(value == nil and "" or value)
end

local function isPointer(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
end

-- ============================================================
-- Library : Notify (แจ้งเตือนแบบระบบ Roblox)
-- ============================================================
function Library:Notify(opts)
    opts = opts or {}
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title    = tostring(opts.Title or "Spooky"),
            Text     = tostring(opts.Text or ""),
            Duration = opts.Duration or 4,
            Icon     = opts.Icon or ICON_ID,
        })
    end)
end

-- ============================================================
-- Library : CreateWindow
-- ============================================================
--[[
    Options:
        Title          string   ข้อความใต้ไอคอนซ้าย ("SPOOKY")
        Version        string   ป้ายเวอร์ชัน ("Version 1.7")
        Credits        string   ข้อความป้ายเครดิตหน้า Home
        Name           string   ชื่อ ScreenGui
        Theme          string   ชื่อธีมเริ่มต้น ("White")
        Scale          number   บังคับสเกลเอง (ไม่ใส่ = คำนวณอัตโนมัติ)
        Animation      string   Pop | Bounce | SlideUp | SlideDown | ZoomSmooth | Fade
        AnimDuration   number   0.1 - 0.6
        ToggleKeys     table    ปุ่มเปิด/ปิด UI (default RightControl, Insert)
        Icon           string   asset ไอคอนหลัก
        Wallpaper      string   asset พื้นหลัง ("" = ปิด)
        Banner         string   asset ภาพชื่อบนหน้า Home ("" = ปิด)
        Home           boolean  สร้างแท็บ Home (default true)
        AutoStats      boolean  อัปเดตการ์ด Bounty/Level/Faction จาก leaderstats (default true)
        ConfigFile     string   ชื่อไฟล์เซฟค่า (default "SpookyUILib_Config.json")
        OnClose        function เรียกเมื่อกดปุ่ม X
]]
function Library:CreateWindow(opts)
    opts = opts or {}
    local Window = { Tabs = {}, TabOrder = {}, _themed = {}, _emblems = {}, _toggles = {}, _cards = {}, _conns = {} }

    local title      = opts.Title or "SPOOKY"
    local iconAsset  = opts.Icon or ICON_ID
    local guiName    = opts.Name or "Spooky_GUI"
    local configFile = opts.ConfigFile or "SpookyUILib_Config.json"
    local homeEnabled = opts.Home ~= false

    -- ลบ GUI เก่าชื่อเดิม
    for _, parent in ipairs({ getSafeParent(), PlayerGui }) do
        local old = parent:FindFirstChild(guiName)
        if old then pcall(function() old:Destroy() end) end
        local oldToggle = parent:FindFirstChild(guiName .. "_MobileToggle")
        if oldToggle then pcall(function() oldToggle:Destroy() end) end
    end

    local function track(conn)
        table.insert(Window._conns, conn)
        return conn
    end

    -- --------------------------------------------------------
    -- ScreenGui + MainFrame
    -- --------------------------------------------------------
    local ScreenGui = New("ScreenGui", {
        Name = guiName, ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true,
    })
    safeParent(ScreenGui)
    Window.ScreenGui = ScreenGui

    track(ScreenGui.DescendantAdded:Connect(function(desc)
        if desc:IsA("TextBox") and (desc.Text == "TextBox" or desc.Text == "textbox") then
            desc.Text = ""
        end
    end))

    local Main = New("Frame", {
        Name = "MainFrame", Size = UDim2.new(0, 650, 0, 369),
        Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(9, 9, 13), BorderSizePixel = 0,
        ClipsDescendants = false, Visible = false,
    }, ScreenGui)
    Window.Main = Main
    local mainCorner = Corner(Main, UDim.new(0, 8))
    local mainStroke = New("UIStroke", {
        Thickness = 1.5, Color = Color3.fromRGB(9, 9, 13),
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, Main)

    local Wallpaper = New("ImageLabel", {
        Name = "SpookyUIWallpaper", Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Crop, ZIndex = 1,
        Image = (opts.Wallpaper == nil) and WALLPAPER_ID or opts.Wallpaper,
        ImageTransparency = 0.15, Visible = true,
    }, Main)
    Corner(Wallpaper, mainCorner.CornerRadius)
    Window.Wallpaper = Wallpaper

    local Overlay = New("ImageLabel", {
        Name = "SpookyUIOverlay", Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1, ZIndex = 1, Visible = false,
    }, Main)
    Corner(Overlay, mainCorner.CornerRadius)
    Window.Overlay = Overlay

    local UIScale = New("UIScale", nil, Main)
    local userScale = opts.Scale
    local baseScale = userScale or computeScale()
    UIScale.Scale = baseScale

    local lastUIPos = nil

    local function updateScaling()
        if userScale then
            baseScale = userScale
        else
            baseScale = computeScale()
        end
        UIScale.Scale = baseScale
    end
    updateScaling()
    if workspace.CurrentCamera then
        track(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScaling))
    end

    function Window:SetScale(value)
        userScale = tonumber(value)
        updateScaling()
    end

    -- --------------------------------------------------------
    -- Drag
    -- --------------------------------------------------------
    local function makeDraggable(dragBars, targetFrame)
        local bars = (typeof(dragBars) == "table") and dragBars or { dragBars }
        local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
        local function update(input)
            if not dragging or not dragStart or not startPos then return end
            local s = (UIScale.Scale > 0.1) and UIScale.Scale or 1
            local delta = (input.Position - dragStart) / s
            local newX = startPos.X.Offset + delta.X
            local newY = startPos.Y.Offset + delta.Y
            local cam = workspace.CurrentCamera
            if cam and cam.ViewportSize then
                local vp = cam.ViewportSize
                newX = math.clamp(newX, -vp.X / 2 + 100, vp.X / 2 - 100)
                newY = math.clamp(newY, -vp.Y / 2 + 60, vp.Y / 2 - 60)
            end
            targetFrame.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
        end
        for _, b in ipairs(bars) do
            if b then
                track(b.InputBegan:Connect(function(input)
                    if isPointer(input) then
                        dragging = true
                        dragStart = input.Position
                        startPos = targetFrame.Position
                        input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.End and dragging then
                                dragging = false
                                lastUIPos = targetFrame.Position
                            end
                        end)
                    end
                end))
                track(b.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement
                        or input.UserInputType == Enum.UserInputType.Touch then
                        dragInput = input
                    end
                end))
            end
        end
        track(UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    local isDown = false
                    pcall(function()
                        isDown = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
                    end)
                    if not isDown then
                        dragging = false
                        lastUIPos = targetFrame.Position
                        return
                    end
                end
                update(input)
                lastUIPos = targetFrame.Position
            end
        end))
        track(UserInputService.InputEnded:Connect(function(input)
            if isPointer(input) and dragging then
                dragging = false
                lastUIPos = targetFrame.Position
            end
        end))
    end

    local topDragHandle = New("Frame", {
        Name = "TopDragHandle", Size = UDim2.new(1, -120, 0, 42), Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1, ZIndex = 2,
    }, Main)
    makeDraggable({ topDragHandle, Main }, Main)

    -- --------------------------------------------------------
    -- แถบซ้าย (โลโก้ + ชื่อ)
    -- --------------------------------------------------------
    local leftSide = New("Frame", {
        Name = "left side image", Size = UDim2.new(0, 128, 0, 369), Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(9, 9, 13), BorderSizePixel = 0,
    }, Main)
    makeDraggable(leftSide, Main)
    Corner(leftSide, UDim.new(0, 8))
    New("Frame", {
        Name = "leftDivider", Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = Color3.fromRGB(28, 26, 38), BorderSizePixel = 0,
    }, leftSide)
    Window._themed.leftSide = leftSide

    local theme0 = Library.Themes[opts.Theme or "White"] or Library.Themes["White"]
    local initColor = theme0.accent

    local fireAura = New("ImageLabel", {
        Name = "spookyFireAura", Size = UDim2.new(0, 88, 0, 88), Position = UDim2.new(0, 20, 0, 6),
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 7, Image = iconAsset,
        ImageColor3 = initColor, ImageTransparency = 0.65, ScaleType = Enum.ScaleType.Stretch,
    }, Main)
    Corner(fireAura, UDim.new(0.5, 0))
    local auraStroke = New("UIStroke", { Thickness = 3.0, Transparency = 0.6, Color = initColor }, fireAura)

    local icon = New("ImageLabel", {
        Name = "icon", Size = UDim2.new(0, 80, 0, 80), Position = UDim2.new(0, 24, 0, 10),
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 8, Visible = true, Active = false,
        Image = iconAsset, ImageColor3 = initColor, ScaleType = Enum.ScaleType.Stretch,
    }, Main)
    Corner(icon, UDim.new(0.5, 0))
    local iconStroke = New("UIStroke", { Name = "iconGlow", Thickness = 2.0, Transparency = 0.35, Color = initColor }, icon)

    local titleLbl = New("TextLabel", {
        Name = "title", Size = UDim2.new(0, 128, 0, 24), Position = UDim2.new(0, 0, 0, 96),
        BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Text = tr(title), TextSize = 15,
        TextColor3 = Color3.fromRGB(255, 255, 255), TextXAlignment = Enum.TextXAlignment.Center,
    }, Main)

    -- --------------------------------------------------------
    -- แถบขวา (ปุ่มปิด/ย่อ + เวอร์ชัน + Log)
    -- --------------------------------------------------------
    local rightSide = New("Frame", {
        Name = "right side image", Size = UDim2.new(0, 122, 0, 369), Position = UDim2.new(0.811, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(9, 9, 13), BorderSizePixel = 0,
    }, Main)
    Corner(rightSide, UDim.new(0, 8))
    New("Frame", {
        Name = "rightDivider", Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(28, 26, 38), BorderSizePixel = 0,
    }, rightSide)
    Window._themed.rightSide = rightSide

    local CloseBtn = New("TextButton", {
        Name = "close button", Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(0.938, 0, 0, 8),
        BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Text = "X", TextSize = 14,
        TextColor3 = Color3.fromRGB(255, 255, 255), ZIndex = 10,
    }, Main)

    local MinimizeBtn = New("TextButton", {
        Name = "minimize button", Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(0.888, 0, 0, 8),
        BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Text = "-", TextSize = 18,
        TextColor3 = Color3.fromRGB(255, 255, 255), ZIndex = 10,
    }, Main)

    local versionBadge = New("Frame", {
        Name = "versionBadge", Size = UDim2.new(0, 106, 0, 22), Position = UDim2.new(0.824, 0, 0, 38),
        BackgroundColor3 = Color3.fromRGB(15, 15, 22), BorderSizePixel = 0, ZIndex = 10,
    }, Main)
    Corner(versionBadge, UDim.new(0, 6))
    Stroke(versionBadge, Color3.fromRGB(36, 36, 48), 1)
    local versionLbl = New("TextLabel", {
        Name = "version", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold, Text = tr(opts.Version or ("Version " .. Library.Version)),
        TextSize = 10.5, TextColor3 = Color3.fromRGB(200, 200, 220),
        TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 11,
    }, versionBadge)

    local changeThemeBtn = New("TextButton", {
        Name = "change hud / theme button", Size = UDim2.new(0, 106, 0, 20),
        Position = UDim2.new(0.824, 0, 0, 66), BackgroundTransparency = 1,
        Font = Enum.Font.Michroma, Text = "Change Hud", TextSize = 10,
        TextColor3 = Color3.fromRGB(210, 210, 230), ZIndex = 10,
    }, Main)
    track(changeThemeBtn.MouseEnter:Connect(function()
        Tween(changeThemeBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(28, 28, 38) })
    end))
    track(changeThemeBtn.MouseLeave:Connect(function()
        Tween(changeThemeBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(18, 18, 26) })
    end))

    -- Log panel
    local LogsScroll = New("ScrollingFrame", {
        Name = "LogsScroll", Size = UDim2.new(0, 112, 0, 258), Position = UDim2.new(0.820, 0, 0, 96),
        BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2,
        ScrollBarImageColor3 = Color3.fromRGB(60, 58, 80), CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 10,
    }, Main)
    New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5) }, LogsScroll)

    local logCount = 0
    function Window:Log(text)
        pcall(function()
            logCount += 1
            New("TextLabel", {
                Name = "Log_" .. logCount, Size = UDim2.new(1, -6, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium, Text = "- " .. tostring(text), TextSize = 9,
                TextColor3 = Color3.fromRGB(195, 195, 215), TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true, LayoutOrder = logCount,
            }, LogsScroll)
            if logCount > 40 then
                local first = LogsScroll:FindFirstChildOfClass("TextLabel")
                if first then first:Destroy() end
            end
        end)
    end
    Window:Log(opts.ReadyText or "Spooky Ready")

    -- --------------------------------------------------------
    -- Home (ภาพชื่อ + โปรไฟล์ + การ์ดสถิติ + เครดิต)
    -- --------------------------------------------------------
    local titleBanner, profileContainer, welcomeLbl, HomeStats, creditsBadge
    local statLabels = {}

    if homeEnabled then
        titleBanner = New("ImageLabel", {
            Name = "banner", Size = UDim2.new(0, 390, 0, 85), Position = UDim2.new(0, 135, 0, 6),
            BackgroundTransparency = 1, BorderSizePixel = 0,
            Image = (opts.Banner == nil) and BANNER_ID or opts.Banner,
            ScaleType = Enum.ScaleType.Fit, ImageColor3 = Color3.fromRGB(255, 255, 255),
            ZIndex = 5, Visible = true,
        }, Main)

        profileContainer = New("Frame", {
            Name = "profileContainer", Size = UDim2.new(0, 72, 0, 72), Position = UDim2.new(0, 294, 0, 98),
            BackgroundColor3 = Color3.fromRGB(16, 16, 24), BackgroundTransparency = 1, BorderSizePixel = 0,
            ClipsDescendants = true, ZIndex = 5, Active = true,
        }, Main)
        Corner(profileContainer, UDim.new(0.5, 0))

        local playerProfile = New("ImageLabel", {
            Name = "player profile", Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1, BorderSizePixel = 0,
            Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150",
            ScaleType = Enum.ScaleType.Crop, ZIndex = 6,
        }, profileContainer)
        Corner(playerProfile, UDim.new(0.5, 0))
        Window._profileStroke = Stroke(playerProfile, Color3.fromRGB(255, 255, 255), 2)
        task.spawn(function()
            pcall(function()
                local thumb = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
                if thumb and thumb ~= "" then playerProfile.Image = thumb end
            end)
        end)

        welcomeLbl = New("TextLabel", {
            Name = "welcomeLbl", Size = UDim2.new(0, 360, 0, 16), Position = UDim2.new(0, 150, 0, 176),
            BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
            Text = LocalPlayer.DisplayName or LocalPlayer.Name, TextSize = 12,
            TextColor3 = Color3.fromRGB(240, 240, 255), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 5,
        }, Main)

        HomeStats = New("Frame", {
            Name = "HomeStatsContainer", Size = UDim2.new(0, 360, 0, 96), Position = UDim2.new(0, 150, 0, 202),
            BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 5,
        }, Main)

        local function makeStatCard(pos, caption, defVal)
            local card = New("Frame", {
                Size = UDim2.new(0, 172, 0, 42), Position = pos, BackgroundColor3 = Color3.fromRGB(13, 13, 19),
            }, HomeStats)
            Corner(card, UDim.new(0, 7))
            Stroke(card, Color3.fromRGB(36, 34, 48), 1)
            New("TextLabel", {
                Size = UDim2.new(1, -16, 0, 12), Position = UDim2.new(0, 8, 0, 5), BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold, Text = tr(caption), TextSize = 8,
                TextColor3 = Color3.fromRGB(130, 130, 155), TextXAlignment = Enum.TextXAlignment.Left,
            }, card)
            return New("TextLabel", {
                Size = UDim2.new(1, -16, 0, 18), Position = UDim2.new(0, 8, 0, 18), BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold, Text = tostring(defVal), TextSize = 11,
                TextColor3 = Color3.fromRGB(245, 245, 255), TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
            }, card)
        end

        local statDefs = opts.HomeStats or {
            { Id = "Player",  Caption = "PLAYER",         Value = LocalPlayer.DisplayName or LocalPlayer.Name },
            { Id = "Bounty",  Caption = "BOUNTY / HONOR", Value = "0" },
            { Id = "Level",   Caption = "LEVEL",          Value = "Level 0" },
            { Id = "Faction", Caption = "FACTION",        Value = "None" },
        }
        local statPositions = {
            UDim2.new(0, 0, 0, 0), UDim2.new(0, 188, 0, 0),
            UDim2.new(0, 0, 0, 48), UDim2.new(0, 188, 0, 48),
        }
        for i, def in ipairs(statDefs) do
            if statPositions[i] then
                statLabels[def.Id or ("Stat" .. i)] = makeStatCard(statPositions[i], def.Caption, def.Value)
            end
        end

        creditsBadge = New("Frame", {
            Name = "CreditsBadge", Size = UDim2.new(0, 280, 0, 26), Position = UDim2.new(0, 190, 0, 312),
            BackgroundColor3 = Color3.fromRGB(15, 14, 22), BackgroundTransparency = 0.35, BorderSizePixel = 0, ZIndex = 5,
        }, Main)
        Corner(creditsBadge, UDim.new(0, 13))
        Stroke(creditsBadge, Color3.fromRGB(48, 44, 68), 1)
        Window._creditsLbl = New("TextLabel", {
            Name = "credits", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold, Text = tr(opts.Credits or "Project Spooky  •  By Darling"), TextSize = 10,
            TextColor3 = Color3.fromRGB(210, 210, 235), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 6,
        }, creditsBadge)

        -- อัปเดตสถิติอัตโนมัติจาก leaderstats / Team (ปิดได้ด้วย AutoStats = false)
        if opts.AutoStats ~= false then
            pcall(function()
                local function setStat(id, text)
                    if statLabels[id] then statLabels[id].Text = text end
                end
                local function update()
                    local ls = LocalPlayer:FindFirstChild("leaderstats")
                    if ls then
                        local b = ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Bounty") or ls:FindFirstChild("Honor")
                        if b then
                            local num = tonumber(b.Value) or 0
                            if num >= 1000000 then setStat("Bounty", string.format("%.2fM", num / 1000000))
                            elseif num >= 1000 then setStat("Bounty", string.format("%.1fK", num / 1000))
                            else setStat("Bounty", tostring(num)) end
                        end
                        local lvl = ls:FindFirstChild("Level")
                        if lvl then setStat("Level", "Level " .. tostring(lvl.Value)) end
                    end
                    if LocalPlayer.Team then setStat("Faction", tostring(LocalPlayer.Team.Name)) end
                    setStat("Player", LocalPlayer.DisplayName or LocalPlayer.Name)
                end
                update()
                local ls = LocalPlayer:FindFirstChild("leaderstats")
                if ls then
                    for _, stat in ipairs(ls:GetChildren()) do
                        track(stat.Changed:Connect(update))
                    end
                end
                track(LocalPlayer:GetPropertyChangedSignal("Team"):Connect(update))
            end)
        end
    end

    function Window:SetStat(id, text)
        if statLabels[id] then statLabels[id].Text = tostring(text) end
    end

    -- --------------------------------------------------------
    -- พื้นที่หน้า (Pages)
    -- --------------------------------------------------------
    local centerPagesBg = New("Frame", {
        Name = "center pages bg", Size = UDim2.new(0, 404, 0, 369), Position = UDim2.new(0, 128, 0, 0),
        BackgroundColor3 = Color3.fromRGB(8, 8, 12), BackgroundTransparency = 0, BorderSizePixel = 0,
        ZIndex = 2, Visible = true,
    }, Main)
    local PagesFolder = New("Frame", {
        Name = "Pages", Size = UDim2.new(0, 404, 0, 353), Position = UDim2.new(0, 128, 0, 8),
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 8, Visible = true,
    }, Main)
    Window.PagesFolder = PagesFolder

    local SidebarScroll = New("ScrollingFrame", {
        Name = "Sidebar", Size = UDim2.new(0, 112, 0, 235), Position = UDim2.new(0, 8, 0, 126),
        BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2,
        ScrollBarImageColor3 = Color3.fromRGB(65, 65, 85), CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y, ZIndex = 8,
    }, Main)
    New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3) }, SidebarScroll)

    -- --------------------------------------------------------
    -- Theme
    -- --------------------------------------------------------
    Window.Theme = opts.Theme or "White"
    Window.Accent = theme0.accent
    Window.AccentBright = theme0.bright
    local NavButtons = {}
    local currentTab = nil
    local MobileToggle -- สร้างด้านล่าง

    local function refreshToggleVisual(t)
        local active = t.State
        local a = Window.Accent
        local info = TweenInfo.new(0.18)
        Tween(t.btn, info, { BackgroundColor3 = active and Color3.fromRGB(24, 22, 34) or Color3.fromRGB(16, 16, 18) })
        Tween(t.txtLbl, info, { TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 215) })
        Tween(t.btnStk, info, { Color = active and a or Color3.fromRGB(36, 36, 42) })
        Tween(t.pill, info, { BackgroundColor3 = active and a or Color3.fromRGB(24, 24, 32) })
        Tween(t.pillStk, info, { Color = active and Color3.fromRGB(240, 245, 255) or Color3.fromRGB(45, 45, 58) })
        Tween(t.knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = active and UDim2.new(1, -11, 0.5, -4.5) or UDim2.new(0, 2, 0.5, -4.5),
            BackgroundColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(80, 80, 95),
        })
    end

    local function updateSidebarVisual(selectedId)
        local a, b = Window.Accent, Window.AccentBright
        for id, d in pairs(NavButtons) do
            local isSel = (id == selectedId)
            Tween(d.btn, TweenInfo.new(0.15), {
                BackgroundColor3 = isSel and Color3.fromRGB(24, 22, 38) or Color3.fromRGB(12, 12, 17),
            })
            Tween(d.st, TweenInfo.new(0.15), {
                Color = isSel and a or Color3.fromRGB(30, 28, 40), Thickness = isSel and 1.2 or 1,
            })
            Tween(d.ind, TweenInfo.new(0.15), {
                Size = isSel and UDim2.new(0, 3, 0, 14) or UDim2.new(0, 0, 0, 14),
                BackgroundColor3 = b, BackgroundTransparency = isSel and 0 or 1,
            })
            Tween(d.lbl, TweenInfo.new(0.15), {
                TextColor3 = isSel and b or Color3.fromRGB(150, 150, 170),
            })
        end
    end

    local function applyAccent(accent, bright)
        Window.Accent, Window.AccentBright = accent, bright
        if titleBanner then titleBanner.ImageColor3 = accent end
        icon.ImageColor3 = accent
        iconStroke.Color = accent
        fireAura.ImageColor3 = accent
        auraStroke.Color = accent
        titleLbl.TextColor3 = accent
        CloseBtn.TextColor3 = accent
        MinimizeBtn.TextColor3 = accent
        local chStk = changeThemeBtn:FindFirstChildOfClass("UIStroke")
        if chStk then chStk.Color = Color3.fromRGB(45, 45, 58) end
        changeThemeBtn.TextColor3 = Color3.fromRGB(235, 235, 245)
        if Window._profileStroke then Window._profileStroke.Color = accent end
        for _, emb in ipairs(Window._emblems) do
            if emb and emb.Parent then emb.ImageColor3 = accent end
        end
        if MobileToggle then
            MobileToggle.ImageColor3 = accent
            local mtStk = MobileToggle:FindFirstChildOfClass("UIStroke")
            if mtStk then mtStk.Color = accent end
        end
        updateSidebarVisual(currentTab or "Home")
        mainStroke.Color = Color3.fromRGB(0, 0, 0)
        for _, t in ipairs(Window._toggles) do
            if t.State then refreshToggleVisual(t) end
        end
    end

    function Window:SetTheme(name)
        local th = Library.Themes[name] or Library.Themes["White"]
        Window.Theme = Library.Themes[name] and name or "White"
        applyAccent(th.accent, th.bright)
    end

    -- ตั้งสีอะไรก็ได้ (bright = สีเดิม * 1.25 เหมือนต้นฉบับ)
    function Window:SetAccent(color)
        if typeof(color) ~= "Color3" then return end
        local r, g, b = color.R * 255, color.G * 255, color.B * 255
        local bright = Color3.fromRGB(math.min(255, math.floor(r * 1.25)),
            math.min(255, math.floor(g * 1.25)), math.min(255, math.floor(b * 1.25)))
        Window.Theme = "Custom"
        applyAccent(color, bright)
    end

    function Window:CycleTheme()
        local nextTheme = Library.ThemeOrder[1]
        for i, t in ipairs(Library.ThemeOrder) do
            if t == Window.Theme then
                nextTheme = Library.ThemeOrder[(i % #Library.ThemeOrder) + 1]
                break
            end
        end
        Window:SetTheme(nextTheme)
        Window:Log("Theme: " .. nextTheme)
    end
    track(changeThemeBtn.MouseButton1Click:Connect(function() Window:CycleTheme() end))

    -- --------------------------------------------------------
    -- Language
    -- --------------------------------------------------------
    local translatables = {}
    local function bindText(obj, source, formatter)
        local entry = { obj = obj, source = source, formatter = formatter }
        table.insert(translatables, entry)
        return entry
    end
    function Window:SetLanguage(lang)
        Library.Language = lang
        for _, e in ipairs(translatables) do
            if e.obj and e.obj.Parent then
                local txt = tr(e.source)
                e.obj.Text = e.formatter and e.formatter(txt) or txt
            end
        end
    end

    -- --------------------------------------------------------
    -- Tabs
    -- --------------------------------------------------------
    local function showTab(id)
        if not NavButtons[id] then id = Window.TabOrder[1] or "Home" end
        currentTab = id
        local isHome = (id == "Home" and homeEnabled)
        if titleBanner then titleBanner.Visible = isHome end
        if profileContainer then profileContainer.Visible = isHome end
        if welcomeLbl then welcomeLbl.Visible = isHome end
        if HomeStats then HomeStats.Visible = isHome end
        if creditsBadge then creditsBadge.Visible = isHome end
        centerPagesBg.Visible = true
        for tid, tab in pairs(Window.Tabs) do
            if tab.Page then tab.Page.Visible = (tid == id) and not isHome end
        end
        PagesFolder.Visible = true
        updateSidebarVisual(id)
        Window:Log("[TAB] " .. tostring(id))
        if Window.Tabs[id] and Window.Tabs[id].OnShow then
            task.defer(function() pcall(Window.Tabs[id].OnShow) end)
        end
    end
    Window.ShowTab = function(_, id) showTab(id) end

    local tabIndex = 0
    local function createTabButton(id, label, isSoon)
        tabIndex += 1
        local isDefault = (tabIndex == 1)
        local btn = New("TextButton", {
            Name = string.lower(tostring(label)) .. " button", Size = UDim2.new(1, -6, 0, 27),
            BackgroundColor3 = isDefault and Color3.fromRGB(24, 22, 38) or Color3.fromRGB(12, 12, 17),
            Font = Enum.Font.GothamBold, Text = "", AutoButtonColor = false, LayoutOrder = tabIndex, ZIndex = 9,
        }, SidebarScroll)
        Corner(btn, UDim.new(0, 7))
        local st = Stroke(btn, isDefault and Color3.fromRGB(120, 95, 195) or Color3.fromRGB(30, 28, 40), isDefault and 1.2 or 1)
        local ind = New("Frame", {
            Name = "ActiveIndicator", Size = isDefault and UDim2.new(0, 3, 0, 14) or UDim2.new(0, 0, 0, 14),
            Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Color3.fromRGB(160, 130, 255),
            BackgroundTransparency = isDefault and 0 or 1, BorderSizePixel = 0,
        }, btn)
        Corner(ind, UDim.new(1, 0))
        local lbl = New("TextLabel", {
            Name = "TabLabel", Active = false,
            Size = isSoon and UDim2.new(1, -36, 1, 0) or UDim2.new(1, -14, 1, 0),
            Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
            Text = tr(label), TextSize = isSoon and 8.5 or 10.5,
            TextColor3 = isDefault and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 170),
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10,
        }, btn)
        bindText(lbl, label)

        track(btn.MouseEnter:Connect(function()
            if btn.BackgroundColor3 ~= Color3.fromRGB(24, 22, 38) then
                Tween(btn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(18, 18, 26) })
                Tween(st, TweenInfo.new(0.12), { Color = Window.Accent })
                Tween(lbl, TweenInfo.new(0.12), { TextColor3 = Color3.fromRGB(220, 220, 235) })
            end
        end))
        track(btn.MouseLeave:Connect(function()
            if btn.BackgroundColor3 ~= Color3.fromRGB(24, 22, 38) then
                Tween(btn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(12, 12, 17) })
                Tween(st, TweenInfo.new(0.12), { Color = Color3.fromRGB(30, 28, 40) })
                Tween(lbl, TweenInfo.new(0.12), { TextColor3 = Color3.fromRGB(150, 150, 170) })
            end
        end))

        if isSoon then
            local badge = New("Frame", {
                Name = "SoonBadge", Size = UDim2.new(0, 24, 0, 11), Position = UDim2.new(1, -28, 0.5, -5.5),
                BackgroundColor3 = Color3.fromRGB(36, 26, 46), BorderSizePixel = 0, ZIndex = 11,
            }, btn)
            Corner(badge, UDim.new(0, 4))
            Stroke(badge, Color3.fromRGB(110, 75, 150), 0.8)
            New("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
                Text = "Soon", TextSize = 6.5, TextColor3 = Color3.fromRGB(215, 185, 255), ZIndex = 12,
            }, badge)
        end

        NavButtons[id] = { btn = btn, st = st, ind = ind, lbl = lbl }
        local function activated()
            if isSoon then return end
            showTab(id)
        end
        track(btn.MouseButton1Click:Connect(activated))
        pcall(function() track(btn.Activated:Connect(activated)) end)
    end

    local Tab = {}
    Tab.__index = Tab
    local Card = {}
    Card.__index = Card

    local CELL_X = { 6, 134, 262 }
    local CELL_W, CELL_H = 124, 30

    function Window:AddTab(def)
        def = def or {}
        local id = def.Id or def.Label or ("Tab" .. (#Window.TabOrder + 1))
        local tab = setmetatable({
            Window = Window, Id = id, Cards = {}, OnShow = def.OnShow,
        }, Tab)
        if id ~= "Home" or not homeEnabled then
            tab.Page = New("ScrollingFrame", {
                Name = id .. "_Page", Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4,
                ScrollBarImageColor3 = Color3.fromRGB(48, 48, 55), CanvasSize = UDim2.new(0, 0, 0, def.CanvasHeight or 550),
                Visible = false, ZIndex = 8, ClipsDescendants = true,
            }, PagesFolder)
        end
        Window.Tabs[id] = tab
        table.insert(Window.TabOrder, id)
        createTabButton(id, def.Label or id, def.Soon)
        return tab
    end

    -- จัดเรียงการ์ดในหน้าให้ต่อกันอัตโนมัติ (ช่องว่าง 6px เหมือนต้นฉบับ)
    function Tab:_relayout()
        if not self.Page then return end
        local y = 2
        for _, card in ipairs(self.Cards) do
            card.Frame.Position = UDim2.new(0, 5, 0, y)
            y = y + card.Height + 6
        end
        self.Page.CanvasSize = UDim2.new(0, 0, 0, y + 6)
    end

    function Tab:AddCard(def)
        def = def or {}
        assert(self.Page, "[SpookyUILib] แท็บ Home ไม่มีหน้าการ์ด ให้สร้างแท็บอื่นด้วย Window:AddTab")
        local glass = Window._glassAlpha
        local card = setmetatable({
            Tab = self, Height = 40, _row = 0, _col = 0, Controls = {},
        }, Card)
        local frame = New("Frame", {
            Size = UDim2.new(1, -10, 0, 40), Position = UDim2.new(0, 5, 0, 2),
            BackgroundColor3 = glass and Color3.fromRGB(5, 5, 10) or Color3.fromRGB(11, 11, 16),
            BackgroundTransparency = glass or 0, BorderSizePixel = 0, ClipsDescendants = false,
        }, self.Page)
        frame:SetAttribute("ControlGroup", tr(def.Title))
        Corner(frame, UDim.new(0, 10))
        local grad = New("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 16, 24)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 15)),
            }),
            Rotation = 90,
        }, frame)
        local cStroke = Stroke(frame, Color3.fromRGB(38, 36, 52), 1.1)
        cStroke.Transparency = glass and 0.4 or 0

        local header = New("Frame", {
            Name = "CardHeader", Size = UDim2.new(1, 0, 0, 22), Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1, BorderSizePixel = 0,
        }, frame)
        local emblem = New("ImageLabel", {
            Name = "HeaderEmblem", Size = UDim2.new(0, 13, 0, 13), Position = UDim2.new(0, 8, 0.5, -6.5),
            BackgroundTransparency = 1, Image = iconAsset, ImageColor3 = Window.Accent, ZIndex = 3,
        }, header)
        Corner(emblem, UDim.new(1, 0))
        table.insert(Window._emblems, emblem)
        local hdr = New("TextLabel", {
            Name = "HeaderTitle", Size = UDim2.new(1, -26, 1, 0), Position = UDim2.new(0, 25, 0, 0),
            BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Text = tr(def.Title), TextSize = 11,
            TextColor3 = Color3.fromRGB(240, 240, 252), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3,
        }, header)
        bindText(hdr, def.Title)
        New("Frame", {
            Name = "HeaderHairline", Size = UDim2.new(1, -16, 0, 1), Position = UDim2.new(0, 8, 0, 22),
            BackgroundColor3 = Color3.fromRGB(32, 32, 42), BorderSizePixel = 0,
        }, frame)

        card.Frame = frame
        card.Stroke = cStroke
        table.insert(self.Cards, card)
        table.insert(Window._cards, card)
        card:_resize()
        return card
    end

    -- ความสูงการ์ด: เริ่มแถวแรกที่ y=26, ทุกแถวห่าง 36 (ตรงกับต้นฉบับ 26/62/98/134)
    function Card:_resize()
        local bottom = self._bottom or 26
        self.Height = bottom + 12
        self.Frame.Size = UDim2.new(1, -10, 0, self.Height)
        self.Tab:_relayout()
    end

    -- ตำแหน่งถัดไปของคอนโทรลปกติ (3 คอลัมน์)
    function Card:_nextCell()
        if self._col >= 3 then self._col = 0 end
        if self._col == 0 then
            self._y = self._nextY or 26
            self._nextY = self._y + 36
        end
        local x = CELL_X[self._col + 1]
        self._col += 1
        local bottom = self._y + CELL_H
        if not self._bottom or bottom > self._bottom then self._bottom = bottom end
        self:_resize()
        return UDim2.new(0, x, 0, self._y)
    end

    -- ตำแหน่งแถวเต็มความกว้าง
    function Card:_nextRow(height)
        self._col = 0
        local y = self._nextY or 26
        self._nextY = y + height + 6
        local bottom = y + height
        if not self._bottom or bottom > self._bottom then self._bottom = bottom end
        self:_resize()
        return y
    end

    function Card:_setFlag(flag, value)
        if flag then Library.Flags[flag] = value end
    end

    -- --------------------------------------------------------
    -- Toggle
    -- --------------------------------------------------------
    function Card:AddToggle(def)
        def = def or {}
        local pos = self:_nextCell()
        local size = def.Size or UDim2.new(0, CELL_W, 0, CELL_H)
        local btn = New("TextButton", {
            Name = def.Name or tr(def.Text), Size = size, Position = pos,
            BackgroundColor3 = Color3.fromRGB(16, 16, 18), Font = Enum.Font.GothamBold, Text = "",
            AutoButtonColor = true, ClipsDescendants = true,
        }, self.Frame)
        Corner(btn, UDim.new(0, 9))
        local btnStk = Stroke(btn, Color3.fromRGB(36, 36, 42), 1.2)
        local label = def.Text or def.Name or "Toggle"
        local txtLbl = New("TextLabel", {
            Name = "TitleLabel", Size = UDim2.new(1, -38, 1, 0), Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Text = tr(label),
            TextXAlignment = Enum.TextXAlignment.Left, TextSize = def.Sub and 10.5 or 11.5,
            TextColor3 = Color3.fromRGB(200, 200, 215), ClipsDescendants = true,
            TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3, Active = false,
        }, btn)
        bindText(txtLbl, label)
        local pill = New("Frame", {
            Name = "SwitchPill", Size = UDim2.new(0, 24, 0, 13), Position = UDim2.new(1, -28, 0.5, -6.5),
            BackgroundColor3 = Color3.fromRGB(26, 26, 34), BorderSizePixel = 0, ZIndex = 3, Active = false,
        }, btn)
        Corner(pill, UDim.new(1, 0))
        local pillStk = Stroke(pill, Color3.fromRGB(48, 48, 62), 1)
        local knob = New("Frame", {
            Name = "SwitchKnob", Size = UDim2.new(0, 9, 0, 9), Position = UDim2.new(0, 2, 0.5, -4.5),
            BackgroundColor3 = Color3.fromRGB(80, 80, 95), BorderSizePixel = 0, ZIndex = 4, Active = false,
        }, pill)
        Corner(knob, UDim.new(1, 0))

        local toggle = {
            State = false, btn = btn, txtLbl = txtLbl, btnStk = btnStk, pill = pill, pillStk = pillStk, knob = knob,
        }
        table.insert(Window._toggles, toggle)
        table.insert(self.Controls, toggle)

        function toggle:Set(value, silent)
            value = value == true
            toggle.State = value
            if def.Flag then Library.Flags[def.Flag] = value end
            refreshToggleVisual(toggle)
            if not silent and def.Callback then
                task.spawn(function()
                    local ok, err = pcall(def.Callback, value)
                    if not ok then warn("[SpookyUILib] Toggle '" .. tostring(def.Name or label) .. "': " .. tostring(err)) end
                end)
            end
        end
        function toggle:Get() return toggle.State end
        function toggle:Toggle() toggle:Set(not toggle.State) end

        local lastClick = 0
        btn.Activated:Connect(function()
            local now = os.clock()
            if now - lastClick < 0.12 then return end
            lastClick = now
            toggle:Toggle()
            Window:Log((toggle.State and "[+] " or "[-] ") .. tr(label))
        end)

        if def.Flag then Library.Flags[def.Flag] = false end
        toggle.Flag = def.Flag
        toggle._kind = "toggle"
        refreshToggleVisual(toggle)
        if def.Default then toggle:Set(true, not def.FireDefault) end
        return toggle
    end

    -- --------------------------------------------------------
    -- Button (Action)
    -- --------------------------------------------------------
    function Card:AddButton(def)
        def = def or {}
        local pos = self:_nextCell()
        local btn = New("TextButton", {
            Size = def.Size or UDim2.new(0, CELL_W, 0, CELL_H), Position = pos,
            BackgroundColor3 = Color3.fromRGB(20, 20, 26), Font = Enum.Font.GothamBold, Text = "",
            AutoButtonColor = true, ClipsDescendants = true,
        }, self.Frame)
        Corner(btn, UDim.new(0, 7))
        local aStk = Stroke(btn, Color3.fromRGB(45, 45, 58), 1)
        local label = def.Text or def.Name or "Button"
        local txtLbl = New("TextLabel", {
            Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 5, 0, 0), BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold, Text = tr(label), TextSize = 11.5,
            TextColor3 = Color3.fromRGB(235, 235, 245), TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 3, Active = false,
        }, btn)
        bindText(txtLbl, label)

        track(btn.MouseEnter:Connect(function()
            Tween(btn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(25, 26, 36) })
            Tween(aStk, TweenInfo.new(0.12), { Color = Window.Accent })
        end))
        track(btn.MouseLeave:Connect(function()
            Tween(btn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(20, 20, 26) })
            Tween(aStk, TweenInfo.new(0.12), { Color = Color3.fromRGB(45, 45, 58) })
        end))

        local lastClick = 0
        btn.Activated:Connect(function()
            local now = os.clock()
            if now - lastClick < 0.12 then return end
            lastClick = now
            if def.Callback then
                task.spawn(function()
                    local ok, err = pcall(def.Callback)
                    if not ok then warn("[SpookyUILib] Button '" .. tostring(def.Name or label) .. "': " .. tostring(err)) end
                end)
            end
        end)

        local obj = { btn = btn, _kind = "button" }
        function obj:SetText(t) label = t; txtLbl.Text = tr(t) end
        table.insert(self.Controls, obj)
        return obj
    end

    -- --------------------------------------------------------
    -- Cycle (ปุ่มกดวนตัวเลือก)
    -- --------------------------------------------------------
    function Card:AddCycle(def)
        def = def or {}
        local choices = def.Choices or def.Options or { "Option" }
        local idx = 1
        if type(def.Default) == "number" then idx = def.Default
        elseif def.Default ~= nil then idx = table.find(choices, def.Default) or 1 end
        local pos = self:_nextCell()
        local btn = New("TextButton", {
            Size = def.Size or UDim2.new(0, CELL_W, 0, CELL_H), Position = pos,
            BackgroundColor3 = Color3.fromRGB(16, 16, 22), Font = Enum.Font.GothamBold, Text = "",
            AutoButtonColor = true, ClipsDescendants = true,
        }, self.Frame)
        Corner(btn, UDim.new(0, 7))
        local cStk = New("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromRGB(42, 42, 54), Thickness = 1,
        }, btn)
        local prefix = def.Text or def.Name or "Select"
        local txtLbl = New("TextLabel", {
            Name = "CycleText", Size = UDim2.new(1, -26, 1, 0), Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
            Text = string.format("%s: %s", tr(prefix), tostring(choices[idx])), TextSize = 11,
            TextColor3 = Color3.fromRGB(225, 225, 240), TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3,
        }, btn)
        local arrow = New("TextLabel", {
            Name = "ArrowIndicator", Size = UDim2.new(0, 16, 1, 0), Position = UDim2.new(1, -18, 0, 0),
            BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Text = "v", TextSize = 8.5,
            TextColor3 = Color3.fromRGB(130, 135, 155), ZIndex = 3,
        }, btn)

        local cycle = { btn = btn, _kind = "cycle", Choices = choices, Index = idx }
        local function render()
            txtLbl.Text = string.format("%s: %s", tr(prefix), tostring(choices[cycle.Index]))
        end
        -- ให้ SetLanguage เรียก render ใหม่ได้
        table.insert(translatables, {
            obj = txtLbl, source = prefix,
            formatter = function(txt) return string.format("%s: %s", txt, tostring(choices[cycle.Index])) end,
        })

        track(btn.MouseEnter:Connect(function()
            Tween(btn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(24, 26, 36) })
            Tween(cStk, TweenInfo.new(0.12), { Color = Window.Accent })
            Tween(arrow, TweenInfo.new(0.12), { TextColor3 = Color3.fromRGB(240, 245, 255) })
        end))
        track(btn.MouseLeave:Connect(function()
            Tween(btn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(16, 16, 22) })
            Tween(cStk, TweenInfo.new(0.12), { Color = Color3.fromRGB(42, 42, 54) })
            Tween(arrow, TweenInfo.new(0.12), { TextColor3 = Color3.fromRGB(130, 135, 155) })
        end))

        function cycle:Set(value, silent)
            local newIdx = (type(value) == "number") and value or table.find(choices, value)
            if not newIdx or not choices[newIdx] then return end
            cycle.Index = newIdx
            render()
            if def.Flag then Library.Flags[def.Flag] = choices[newIdx] end
            if not silent and def.Callback then
                task.spawn(function()
                    local ok, err = pcall(def.Callback, choices[newIdx], newIdx)
                    if not ok then warn("[SpookyUILib] Cycle: " .. tostring(err)) end
                end)
            end
        end
        function cycle:Get() return choices[cycle.Index], cycle.Index end
        function cycle:SetChoices(list, default)
            choices = list
            cycle.Choices = list
            cycle.Index = default or 1
            render()
        end

        local lastClick = 0
        local function onClick()
            local now = os.clock()
            if now - lastClick < 0.12 then return end
            lastClick = now
            cycle:Set((cycle.Index % #choices) + 1)
        end
        btn.Activated:Connect(onClick)

        cycle.Flag = def.Flag
        if def.Flag then Library.Flags[def.Flag] = choices[idx] end
        table.insert(self.Controls, cycle)
        return cycle
    end

    -- --------------------------------------------------------
    -- Slider
    -- --------------------------------------------------------
    function Card:AddSlider(def)
        def = def or {}
        local minV, maxV = def.Min or 0, def.Max or 100
        local defV = math.clamp(def.Default or minV, minV, maxV)
        local isFloat, step, sfx = def.Float == true, def.Step, def.Suffix or ""
        local y = self:_nextRow(38)
        local frame = New("Frame", {
            Size = UDim2.new(1, -12, 0, 38), Position = UDim2.new(0, 6, 0, y), BackgroundTransparency = 1,
        }, self.Frame)
        local label = def.Text or def.Name or "Slider"
        local titleLbl = New("TextLabel", {
            Size = UDim2.new(0.65, 0, 0, 16), Position = UDim2.new(0, 4, 0, 0), BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold, Text = tr(label), TextSize = 11,
            TextColor3 = Color3.fromRGB(210, 210, 225), TextXAlignment = Enum.TextXAlignment.Left,
        }, frame)
        bindText(titleLbl, label)
        local function fmt(v)
            return isFloat and string.format("%.2f%s", v, sfx) or string.format("%d%s", math.floor(v), sfx)
        end
        local valLbl = New("TextLabel", {
            Size = UDim2.new(0.35, -4, 0, 16), Position = UDim2.new(0.65, 0, 0, 0), BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold, Text = fmt(defV), TextSize = 11, TextColor3 = Color3.fromRGB(255, 255, 255),
            TextXAlignment = Enum.TextXAlignment.Right,
        }, frame)
        local track_ = New("Frame", {
            Size = UDim2.new(1, -8, 0, 6), Position = UDim2.new(0, 4, 0, 24),
            BackgroundColor3 = Color3.fromRGB(22, 22, 30), BorderSizePixel = 0,
        }, frame)
        Corner(track_, UDim.new(1, 0))
        Stroke(track_, Color3.fromRGB(42, 42, 55), 1)
        local curPct = (maxV > minV) and math.clamp((defV - minV) / (maxV - minV), 0, 1) or 0
        local fill = New("Frame", {
            Size = UDim2.new(curPct, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(195, 205, 230), BorderSizePixel = 0,
        }, track_)
        Corner(fill, UDim.new(1, 0))
        local knob = New("ImageButton", {
            Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(curPct, -9, 0.5, -9),
            BackgroundColor3 = Color3.fromRGB(16, 16, 22), Image = iconAsset, BorderSizePixel = 0, ZIndex = 5,
        }, track_)
        Corner(knob, UDim.new(1, 0))
        Stroke(knob, Color3.fromRGB(240, 240, 255), 1.5)

        local slider = { Value = defV, _kind = "slider", Flag = def.Flag }
        local dragging = false

        local function apply(rawVal, silent)
            if step and step > 0 then rawVal = math.floor(rawVal / step + 0.5) * step end
            rawVal = math.clamp(rawVal, minV, maxV)
            local pct = (maxV > minV) and ((rawVal - minV) / (maxV - minV)) or 0
            fill.Size = UDim2.new(pct, 0, 1, 0)
            knob.Position = UDim2.new(pct, -9, 0.5, -9)
            valLbl.Text = fmt(rawVal)
            slider.Value = rawVal
            if def.Flag then Library.Flags[def.Flag] = rawVal end
            if not silent and def.Callback then
                local ok, err = pcall(def.Callback, rawVal)
                if not ok then warn("[SpookyUILib] Slider: " .. tostring(err)) end
            end
        end
        local function fromInput(x)
            local absPos, absSize = track_.AbsolutePosition.X, track_.AbsoluteSize.X
            if absSize <= 0 then return end
            local pct = math.clamp((x - absPos) / absSize, 0, 1)
            apply(minV + pct * (maxV - minV))
        end

        local function begin(input)
            if isPointer(input) then
                dragging = true
                fromInput(input.Position.X)
            end
        end
        track(knob.InputBegan:Connect(begin))
        track(track_.InputBegan:Connect(begin))
        track(UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                fromInput(input.Position.X)
            end
        end))
        track(UserInputService.InputEnded:Connect(function(input)
            if isPointer(input) then dragging = false end
        end))

        function slider:Set(v, silent) apply(tonumber(v) or minV, silent) end
        function slider:Get() return slider.Value end
        if def.Flag then Library.Flags[def.Flag] = defV end
        table.insert(self.Controls, slider)
        return slider
    end

    -- --------------------------------------------------------
    -- TextBox
    -- --------------------------------------------------------
    function Card:AddTextBox(def)
        def = def or {}
        local wide = def.Wide == true
        local pos, size
        if wide then
            local y = self:_nextRow(26)
            pos, size = UDim2.new(0, 6, 0, y), UDim2.new(1, -12, 0, 26)
        else
            pos = self:_nextCell()
            size = def.Size or UDim2.new(0, CELL_W, 0, CELL_H)
        end
        local box = New("TextBox", {
            Size = size, Position = pos, Text = def.Default or "", PlaceholderText = tr(def.Placeholder or def.Text or ""),
            ClearTextOnFocus = def.ClearOnFocus == true, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundColor3 = Color3.fromRGB(16, 16, 22), TextColor3 = Color3.fromRGB(240, 240, 250),
            PlaceholderColor3 = Color3.fromRGB(125, 130, 150), Font = Enum.Font.GothamMedium,
            ClipsDescendants = true, ZIndex = 3,
        }, self.Frame)
        New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 26) }, box)
        Corner(box, UDim.new(0, 6))
        local stk = New("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromRGB(45, 45, 58), Thickness = 1,
        }, box)
        local emblem = New("ImageLabel", {
            Name = "SpookyBoxEmblem", Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -22, 0.5, -8),
            BackgroundTransparency = 1, Image = iconAsset, ImageColor3 = Color3.fromRGB(130, 135, 155), ZIndex = 4,
        }, box)
        Corner(emblem, UDim.new(1, 0))
        track(box.Focused:Connect(function()
            Tween(stk, TweenInfo.new(0.15), { Color = Color3.fromRGB(180, 195, 230) })
            Tween(emblem, TweenInfo.new(0.15), { ImageColor3 = Color3.fromRGB(255, 255, 255) })
        end))
        track(box.FocusLost:Connect(function(enter)
            Tween(stk, TweenInfo.new(0.15), { Color = Color3.fromRGB(45, 45, 58) })
            Tween(emblem, TweenInfo.new(0.15), { ImageColor3 = Color3.fromRGB(130, 135, 155) })
            if def.Flag then Library.Flags[def.Flag] = box.Text end
            if def.Callback then
                local ok, err = pcall(def.Callback, box.Text, enter)
                if not ok then warn("[SpookyUILib] TextBox: " .. tostring(err)) end
            end
        end))
        local obj = { Box = box, _kind = "textbox", Flag = def.Flag }
        function obj:Set(t, silent)
            box.Text = tostring(t)
            if def.Flag then Library.Flags[def.Flag] = box.Text end
            if not silent and def.Callback then pcall(def.Callback, box.Text, false) end
        end
        function obj:Get() return box.Text end
        if def.Flag then Library.Flags[def.Flag] = box.Text end
        table.insert(self.Controls, obj)
        return obj
    end

    -- --------------------------------------------------------
    -- Label (ข้อความหลายบรรทัดเต็มความกว้าง)
    -- --------------------------------------------------------
    function Card:AddLabel(def)
        if type(def) == "string" then def = { Text = def } end
        def = def or {}
        local h = def.Height or 32
        local y = self:_nextRow(h)
        local lbl = New("TextLabel", {
            Position = UDim2.fromOffset(8, y), Size = UDim2.new(1, -16, 0, h), BackgroundTransparency = 1,
            TextSize = 10, Font = Enum.Font.Gotham, TextWrapped = true, Text = tr(def.Text or ""),
            TextColor3 = Color3.fromRGB(170, 180, 200), TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
        }, self.Frame)
        bindText(lbl, def.Text or "")
        local obj = { Label = lbl, _kind = "label" }
        function obj:Set(t) lbl.Text = tr(t) end
        table.insert(self.Controls, obj)
        return obj
    end

    -- --------------------------------------------------------
    -- Glass mode (การ์ดโปร่งใส)
    -- --------------------------------------------------------
    function Window:SetGlass(alpha)
        Window._glassAlpha = alpha
        for _, c in ipairs(Window._cards) do
            if c.Frame and c.Frame.Parent then
                c.Frame.BackgroundColor3 = alpha and Color3.fromRGB(5, 5, 10) or Color3.fromRGB(11, 11, 16)
                c.Frame.BackgroundTransparency = alpha or 0
                c.Stroke.Transparency = alpha and 0.4 or 0
            end
        end
    end

    -- --------------------------------------------------------
    -- Config (เซฟ/โหลดค่า Flag + ธีม)
    -- --------------------------------------------------------
    local flagControls = function()
        local map = {}
        for _, tab in pairs(Window.Tabs) do
            for _, card in ipairs(tab.Cards) do
                for _, c in ipairs(card.Controls) do
                    if c.Flag then map[c.Flag] = c end
                end
            end
        end
        return map
    end

    function Window:SaveConfig()
        if not writefile then return false end
        local ok = pcall(function()
            local data = { theme = Window.Theme, flags = {} }
            for k, v in pairs(Library.Flags) do
                local t = type(v)
                if t == "boolean" or t == "number" or t == "string" then data.flags[k] = v end
            end
            writefile(configFile, HttpService:JSONEncode(data))
        end)
        return ok
    end

    function Window:LoadConfig()
        if not (isfile and readfile and isfile(configFile)) then return false end
        local ok = pcall(function()
            local data = HttpService:JSONDecode(readfile(configFile))
            if data.theme and Library.Themes[data.theme] then Window:SetTheme(data.theme) end
            local map = flagControls()
            for k, v in pairs(data.flags or {}) do
                local c = map[k]
                if c and c.Set then c:Set(v) end
            end
        end)
        return ok
    end

    -- --------------------------------------------------------
    -- ปุ่มลอยเปิด/ปิด UI (MobileToggle) + อนิเมชันเปิด/ปิด
    -- --------------------------------------------------------
    MobileToggle = New("ImageButton", {
        Name = guiName .. "_MobileToggle", Size = UDim2.new(0, 52, 0, 52), Position = UDim2.new(0, 20, 0, 80),
        BackgroundColor3 = Color3.fromRGB(10, 10, 14), BorderSizePixel = 0, Image = iconAsset,
        ScaleType = Enum.ScaleType.Stretch, ClipsDescendants = true, Visible = false, ZIndex = 9999, Active = true,
        ImageColor3 = Window.Accent,
    }, ScreenGui)
    Corner(MobileToggle, UDim.new(0, 8))
    New("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Window.Accent, Thickness = 1.2,
    }, MobileToggle)

    local userMovedTogglePos = nil
    local toggleDragging, toggleDragStart, toggleStartPos, toggleMoved = false, nil, nil, false
    track(MobileToggle.InputBegan:Connect(function(input)
        if isPointer(input) then
            toggleDragging = true
            toggleMoved = false
            toggleDragStart = input.Position
            toggleStartPos = MobileToggle.Position
        end
    end))
    track(UserInputService.InputChanged:Connect(function(input)
        if toggleDragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - toggleDragStart
            if delta.Magnitude > 8 then toggleMoved = true end
            if toggleStartPos then
                local newPos = UDim2.new(toggleStartPos.X.Scale, toggleStartPos.X.Offset + delta.X,
                    toggleStartPos.Y.Scale, toggleStartPos.Y.Offset + delta.Y)
                MobileToggle.Position = newPos
                userMovedTogglePos = newPos
            end
        end
    end))
    track(UserInputService.InputEnded:Connect(function(input)
        if isPointer(input) then
            toggleDragging = false
            if toggleMoved then task.delay(0.15, function() toggleMoved = false end) end
        end
    end))

    local isAnimating = false
    local currentAnim = (opts.Animation and ({ Pop = 1, Bounce = 1, SlideUp = 1, SlideDown = 1, ZoomSmooth = 1, Fade = 1 })[opts.Animation])
        and opts.Animation or "Pop"
    local animDuration = math.clamp(tonumber(opts.AnimDuration) or 0.28, 0.1, 0.6)

    function Window:SetAnimation(name, dur)
        if ({ Pop = 1, Bounce = 1, SlideUp = 1, SlideDown = 1, ZoomSmooth = 1, Fade = 1 })[name] then currentAnim = name end
        local d = tonumber(dur)
        if d and d == d then animDuration = math.clamp(d, 0.1, 0.6) end
    end
    function Window:GetAnimation() return currentAnim, animDuration end

    local animToken = 0
    local motionTweens = {}
    local requestedVisible = nil
    local lastToggleInput = nil
    local fadeConnection, fadeValue = nil, nil
    local fadeOriginals = {}

    local function resetFade()
        if fadeConnection then fadeConnection:Disconnect(); fadeConnection = nil end
        if fadeValue then fadeValue:Destroy(); fadeValue = nil end
        for obj, props in pairs(fadeOriginals) do
            if obj.Parent then
                for p, v in pairs(props) do obj[p] = v end
            end
        end
        table.clear(fadeOriginals)
    end
    local function collectFade(obj)
        if obj:IsA("GuiObject") and not obj.Visible then return end
        local props = {}
        if obj:IsA("GuiObject") then props.BackgroundTransparency = obj.BackgroundTransparency end
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            props.TextTransparency = obj.TextTransparency
            props.TextStrokeTransparency = obj.TextStrokeTransparency
        elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            props.ImageTransparency = obj.ImageTransparency
        elseif obj:IsA("UIStroke") then
            props.Transparency = obj.Transparency
        end
        if next(props) then fadeOriginals[obj] = props end
        for _, child in ipairs(obj:GetChildren()) do collectFade(child) end
    end

    local function showMobileBtn()
        MobileToggle.Position = userMovedTogglePos or UDim2.new(0, 20, 0, 80)
        MobileToggle.Size = UDim2.new(0, 52, 0, 52)
        MobileToggle.Visible = true
        isAnimating = false
    end

    local destroyed = false
    local function setVisibility(visible)
        if destroyed then return end
        visible = visible == true
        requestedVisible = visible
        animToken += 1
        local token = animToken
        for _, tw in ipairs(motionTweens) do tw:Cancel() end
        table.clear(motionTweens)
        resetFade()
        isAnimating = true
        local scale = tonumber(userScale or baseScale) or 0.85
        local base = lastUIPos or UDim2.new(0.5, 0, 0.5, 0)
        local duration = math.clamp(animDuration, 0.1, 0.6)
        if not visible then duration *= 0.75 end
        Main.AnchorPoint = Vector2.new(0.5, 0.5)
        MobileToggle.Visible = true
        local mode = currentAnim
        local offset = mode == "SlideDown" and -80 or (mode == "SlideUp" and 80 or 0)
        local startPosition = base + UDim2.fromOffset(0, offset)
        local factor = mode == "ZoomSmooth" and 0.72 or (mode == "Pop" and 0.88 or (mode == "Bounce" and 0.80 or 1))
        local compact = scale * factor
        local wasVisible = Main.Visible
        Main.Visible = true
        if visible and not wasVisible then
            Main.Position = startPosition
            UIScale.Scale = compact
        end
        local style = visible
            and (mode == "Pop" and Enum.EasingStyle.Back or (mode == "Bounce" and Enum.EasingStyle.Bounce or Enum.EasingStyle.Quint))
            or Enum.EasingStyle.Quad
        local info = TweenInfo.new(duration, style, visible and Enum.EasingDirection.Out or Enum.EasingDirection.In)
        local motion = TweenService:Create(Main, info, { Position = visible and base or startPosition })
        local zoom = TweenService:Create(UIScale, info, { Scale = visible and scale or compact })
        table.insert(motionTweens, motion); table.insert(motionTweens, zoom)
        motion:Play(); zoom:Play()
        if mode == "Fade" then
            collectFade(Main)
            fadeValue = Instance.new("NumberValue")
            fadeValue.Value = visible and 1 or 0
            local function applyFade(value)
                for obj, props in pairs(fadeOriginals) do
                    if obj.Parent then
                        for p, original in pairs(props) do obj[p] = original + (1 - original) * value end
                    end
                end
            end
            applyFade(fadeValue.Value)
            fadeConnection = fadeValue.Changed:Connect(applyFade)
            local fadeTween = TweenService:Create(fadeValue, info, { Value = visible and 0 or 1 })
            table.insert(motionTweens, fadeTween)
            fadeTween:Play()
        end
        task.delay(duration, function()
            if token ~= animToken or destroyed or not Main.Parent then return end
            Main.Visible = visible
            resetFade()
            Main.Position = base
            UIScale.Scale = scale
            isAnimating = false
            if not visible then showMobileBtn() end
        end)
    end
    Window.SetVisible = function(_, v) setVisibility(v) end

    function Window:Toggle(input)
        if destroyed then return end
        if input and input == lastToggleInput then return end
        lastToggleInput = input
        local visible = Main.Visible
        if isAnimating and requestedVisible ~= nil then visible = requestedVisible end
        setVisibility(not visible)
    end
    function Window:IsVisible() return Main.Visible end

    function Window:PreviewAnimation()
        if isAnimating then return end
        if not Main.Visible then
            setVisibility(true)
        else
            setVisibility(false)
            local pt = animToken
            task.delay(animDuration + 0.15, function()
                if pt ~= animToken or destroyed then return end
                setVisibility(true)
            end)
        end
    end

    function Window:Destroy()
        if destroyed then return end
        destroyed = true
        for _, c in ipairs(Window._conns) do pcall(function() c:Disconnect() end) end
        pcall(function() ScreenGui:Destroy() end)
        for i, w in ipairs(Library.Windows) do
            if w == Window then table.remove(Library.Windows, i) break end
        end
    end

    track(CloseBtn.Activated:Connect(function()
        if isAnimating then return end
        isAnimating = true
        Tween(UIScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Scale = 0.02 })
        task.delay(0.22, function()
            if opts.OnClose then pcall(opts.OnClose) end
            Window:Destroy()
        end)
    end))
    track(MinimizeBtn.Activated:Connect(function() setVisibility(false) end))
    track(MobileToggle.Activated:Connect(function()
        if toggleMoved then return end
        Window:Toggle()
    end))

    local toggleKeys = opts.ToggleKeys or { Enum.KeyCode.RightControl, Enum.KeyCode.Insert }
    track(UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or UserInputService:GetFocusedTextBox() then return end
        for _, k in ipairs(toggleKeys) do
            if input.KeyCode == k then Window:Toggle(input) break end
        end
    end))

    -- --------------------------------------------------------
    -- เริ่มต้น
    -- --------------------------------------------------------
    if homeEnabled then
        Window:AddTab({ Id = "Home", Label = opts.HomeLabel or "Home" })
    end

    -- Finalize: เรียกหลังเพิ่มแท็บ/การ์ดเสร็จ เพื่อเปิด UI พร้อมอนิเมชัน
    function Window:Init(startTab)
        Window:SetTheme(Window.Theme)
        showTab(startTab or (homeEnabled and "Home") or Window.TabOrder[1])
        MobileToggle.Visible = true
        Main.Visible = false
        updateScaling()
        UIScale.Scale = baseScale
        setVisibility(true)
        return Window
    end

    -- ใช้ธีมเริ่มต้นกับของที่สร้างไปแล้ว
    applyAccent(theme0.accent, theme0.bright)

    table.insert(Library.Windows, Window)
    return Window
end

return Library
