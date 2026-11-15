--[[
    KING.VS UI Library
    Extracted from KING_VS___Z8OV.txt (buildGui + ModernAutoGrab HUD + floating button panel)

    Window:   Library.new({...})
    Tabs:     window:AddTab({Title=, Heading=, Icon=})
    Controls: tab:Section / Toggle / Input / Selector / Keybind / Value / Chip /
              Stepper / Button / ListButton / BackgroundSelector / BackgroundGrid / Spacer
    Extras:   window:CreateHud({...})  window:CreateFloatingPanel({...})
]]

local Library = {}
Library.__index = Library
Library.Version = "1.0.0"

local Tab = {}
Tab.__index = Tab

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer

----------------------------------------------------------------------
-- Constants (copied from the original script)
----------------------------------------------------------------------
local WHITE = Color3.fromRGB(235, 235, 235)
local INP = Color3.fromRGB(24, 24, 24)
local ROW_BORDER = Color3.fromRGB(0, 0, 0)
local GOLD = Color3.fromRGB(255, 215, 0)

Library.Themes = {
    Yellow = Color3.fromRGB(255, 215, 0),
    Gold = Color3.fromRGB(255, 200, 35),
    Orange = Color3.fromRGB(248, 165, 75),
    Gray = Color3.fromRGB(170, 170, 170),
}

Library.DefaultBackgrounds = { "81300675759357", "99738760095044", "128154493189387", "99700457964523" }

----------------------------------------------------------------------
-- Small helpers (KINGUI.new / round / stroke / text)
----------------------------------------------------------------------
local function New(class, parent, props)
    local object = Instance.new(class)
    for key, value in pairs(props or {}) do object[key] = value end
    object.Parent = parent
    return object
end

local function Round(object, radius)
    local corner = object:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", object)
    corner.CornerRadius = UDim.new(0, radius or 12)
    return corner
end

local function Stroke(object, color, transparency, thickness)
    return New("UIStroke", object, {
        Color = color, Transparency = transparency or 0,
        Thickness = thickness or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function Text(parent, text, position, size, fontSize, color, z)
    return New("TextLabel", parent, {
        Text = text, Position = position, Size = size,
        BackgroundTransparency = 1, TextColor3 = color or Color3.fromRGB(245, 241, 235),
        Font = Enum.Font.GothamMedium, TextSize = fontSize or 12, ZIndex = z or 8,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
    })
end

local function finite(n)
    return type(n) == "number" and n == n and math.abs(n) < math.huge
end

local function isGamepadInput(input)
    local t = input.UserInputType
    return t == Enum.UserInputType.Gamepad1 or t == Enum.UserInputType.Gamepad2
        or t == Enum.UserInputType.Gamepad3 or t == Enum.UserInputType.Gamepad4
        or t == Enum.UserInputType.Gamepad5 or t == Enum.UserInputType.Gamepad6
        or t == Enum.UserInputType.Gamepad7 or t == Enum.UserInputType.Gamepad8
end

local function isBindableInput(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        return input.KeyCode ~= Enum.KeyCode.Unknown
    end
    if isGamepadInput(input) then
        return input.KeyCode ~= Enum.KeyCode.Unknown
            and input.KeyCode ~= Enum.KeyCode.Thumbstick1
            and input.KeyCode ~= Enum.KeyCode.Thumbstick2
    end
    return false
end

----------------------------------------------------------------------
-- Icons: real Lucide icons instead of hand-drawn Frames.
-- Library.IconProvider can be replaced: function(name) -> assetId string
-- or table {Image=, ImageRectOffset=/ImageRectPosition=, ImageRectSize=}
----------------------------------------------------------------------
Library.IconProvider = nil
local iconModule = nil

local function loadIconModule()
    if iconModule ~= nil then return iconModule or nil end
    iconModule = false
    local ok, mod = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/Icons/main/Main.lua"))()
    end)
    if ok and type(mod) == "table" then
        pcall(function() if mod.SetIconsType then mod.SetIconsType("lucide") end end)
        iconModule = mod
    end
    return iconModule or nil
end

local function normalizeIcon(raw)
    if type(raw) == "string" then return { Image = raw } end
    if type(raw) ~= "table" then return nil end
    local data = { Image = raw.Image or raw[1] }
    local extra = type(raw[2]) == "table" and raw[2] or raw
    data.ImageRectOffset = extra.ImageRectOffset or extra.ImageRectPosition
    data.ImageRectSize = extra.ImageRectSize
    if type(data.Image) ~= "string" then return nil end
    return data
end

function Library.GetIcon(name)
    if Library.IconProvider then
        local ok, result = pcall(Library.IconProvider, name)
        if ok and result then return normalizeIcon(result) end
    end
    local mod = loadIconModule()
    if mod and type(mod.Icon) == "function" then
        local ok, result = pcall(mod.Icon, name)
        if ok and result then return normalizeIcon(result) end
    end
    return nil
end

-- returns an ImageLabel, or nil when the icon could not be resolved
function Library.CreateIcon(parent, name, props)
    local icon = Library.GetIcon(name)
    if not icon then return nil end
    props = props or {}
    props.BackgroundTransparency = 1
    props.Image = icon.Image
    if icon.ImageRectOffset then props.ImageRectOffset = icon.ImageRectOffset end
    if icon.ImageRectSize then props.ImageRectSize = icon.ImageRectSize end
    return New("ImageLabel", parent, props)
end

----------------------------------------------------------------------
-- Shared drag helper (HUD + floating buttons)
----------------------------------------------------------------------
local function attachDrag(handle, target, threshold, isLocked, onFinish)
    local dragging, dragStart, startPos, moved = false, nil, nil, 0
    local moveConn, endConn
    local function stopConns()
        if moveConn then pcall(function() moveConn:Disconnect() end); moveConn = nil end
        if endConn then pcall(function() endConn:Disconnect() end); endConn = nil end
    end
    local function finish()
        if not dragging then return end
        dragging = false
        stopConns()
        if moved > threshold and onFinish then onFinish() end
    end
    handle.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch then return end
        if isLocked and isLocked() then return end
        dragging = true
        moved = 0
        dragStart = input.Position
        startPos = target.Position
        stopConns()
        moveConn = UIS.InputChanged:Connect(function(inp)
            if not dragging then return end
            if inp.UserInputType == Enum.UserInputType.MouseMovement
                or inp.UserInputType == Enum.UserInputType.Touch then
                local delta = inp.Position - dragStart
                moved = delta.Magnitude
                if moved > threshold then
                    target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                        startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end
        end)
        endConn = UIS.InputEnded:Connect(function(inp)
            if inp.UserInputType ~= Enum.UserInputType.MouseButton1
                and inp.UserInputType ~= Enum.UserInputType.Touch then return end
            finish()
        end)
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then finish() end
        end)
    end)
    return function() return moved end
end

----------------------------------------------------------------------
-- Window
----------------------------------------------------------------------
function Library.new(options)
    options = options or {}
    local self = setmetatable({}, Library)

    self.Name = options.Name or "KingVS"
    self.Title = options.Title or "👑 KING.VS"
    self.BaseWidth = options.Width or 385
    self.BaseHeight = options.Height or 390
    self.SidebarWidth = options.SidebarWidth or 110
    self.ScaleValue = options.Scale or 100
    self.Backgrounds = options.Backgrounds or Library.DefaultBackgrounds
    self.BackgroundIndex = 1
    self.BackgroundMode = options.Background or "Background 1"
    self.BackgroundImageTransparency = 0
    self.Effects = options.Effects ~= false
    self.Locked = false
    self.OnChanged = options.OnChanged
    self.ThemeName = options.Theme or "Yellow"
    self.ThemeColor = Library.Themes[self.ThemeName] or Library.Themes.Yellow
    self.Tabs = {}
    self.TabButtons = {}
    self.Cards = {}
    self.Animated = {}
    self.KeyButtons = {}
    self.AnyKeyListening = false
    self._themed = {}
    self._connections = {}
    self._backgroundRevision = 0

    local BODY_Y = 46
    local SIDEBAR_W = self.SidebarWidth

    -- Remove old instances
    local pgui = LP:WaitForChild("PlayerGui")
    local okCore, CoreGui = pcall(function() return game:GetService("CoreGui") end)
    local removeNames = { self.Name }
    for _, n in ipairs(options.RemoveOld or {}) do table.insert(removeNames, n) end
    for _, parent in ipairs({ okCore and CoreGui or pgui, pgui }) do
        for _, name in ipairs(removeNames) do
            pcall(function()
                local old = parent:FindFirstChild(name)
                if old then old:Destroy() end
            end)
        end
    end

    local gui = New("ScreenGui", nil, {
        Name = self.Name, ResetOnSpawn = false, IgnoreGuiInset = true,
        DisplayOrder = 999, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
    local ok = pcall(function() gui.Parent = CoreGui end)
    if not ok or not gui.Parent then gui.Parent = pgui end
    self.Gui = gui

    local main = New("Frame", gui, {
        Name = "Main", Size = UDim2.fromOffset(self.BaseWidth, self.BaseHeight),
        Position = options.Position or UDim2.fromOffset(20, 20),
        BackgroundColor3 = Color3.fromRGB(10, 10, 10), BackgroundTransparency = 0.40,
        BorderSizePixel = 0, ClipsDescendants = true, Active = true,
    })
    Round(main, 18)
    local border = Stroke(main, Color3.fromRGB(196, 154, 28), 0.22, 1.6)
    border.Name = "MainBorder"
    self.Main = main
    self.UIScale = New("UIScale", main, { Scale = self.ScaleValue / 100 })

    local bg = New("ImageLabel", main, {
        Name = "BackgroundImage", Size = UDim2.fromScale(1, 1),
        Image = "rbxassetid://" .. self.Backgrounds[self.BackgroundIndex],
        ImageTransparency = self.BackgroundImageTransparency,
        BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Crop, ZIndex = 0,
    })
    Round(bg, 18)

    local veil = New("Frame", main, {
        Name = "BackgroundVeil", Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(10, 10, 10), BackgroundTransparency = 0.82,
        BorderSizePixel = 0, ZIndex = 2,
    })
    Round(veil, 18)

    local inset = New("Frame", main, {
        Name = "PanelInset", Position = UDim2.fromOffset(3, 3), Size = UDim2.new(1, -6, 1, -6),
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 3,
    })
    Round(inset, 15)
    Stroke(inset, Color3.fromRGB(0, 0, 0), 0.3, 1)

    local topLight = New("Frame", main, {
        Name = "TopLight", Position = UDim2.fromOffset(28, 1), Size = UDim2.new(1, -56, 0, 1),
        BackgroundColor3 = Color3.fromRGB(255, 215, 0), BorderSizePixel = 0, ZIndex = 4,
    })
    New("UIGradient", topLight, {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.45),
            NumberSequenceKeypoint.new(1, 1),
        }),
    })

    -- Header
    local header = New("Frame", main, {
        Name = "ScriptHeader", Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 12,
    })
    self.Logo = Text(header, self.Title, UDim2.fromOffset(16, 0), UDim2.new(0, 140, 1, 0), 20,
        Color3.fromRGB(255, 215, 0), 13)
    self.Logo.Font = Enum.Font.GothamBlack
    self.Logo.TextXAlignment = Enum.TextXAlignment.Left

    local fpsLabel = Text(header, "FPS: -- | Ping: --", UDim2.new(0.5, -70, 0, 0), UDim2.new(0, 140, 1, 0), 12,
        Color3.fromRGB(170, 170, 170), 13)
    fpsLabel.Name = "FpsPing"
    fpsLabel.Font = Enum.Font.GothamBold
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Center
    self.FpsLabel = fpsLabel
    if options.ShowFps ~= false then
        local last, frames = tick(), 0
        table.insert(self._connections, RunService.RenderStepped:Connect(function()
            frames = frames + 1
            local now = tick()
            if now - last >= 0.5 then
                local fps = math.floor(frames / (now - last) + 0.5)
                frames = 0
                last = now
                local ping = 0
                pcall(function() ping = math.floor(LP:GetNetworkPing() * 1000 + 0.5) end)
                if fpsLabel.Parent then
                    fpsLabel.Text = string.format("FPS: %d | Ping: %dms", fps, ping)
                end
            end
        end))
    else
        fpsLabel.Visible = false
    end

    local close = New("TextButton", header, {
        Name = "Close", Size = UDim2.fromOffset(32, 32), Position = UDim2.new(1, -40, 0.5, -16),
        Text = "–", TextSize = 22, Font = Enum.Font.GothamBold, TextColor3 = WHITE,
        BackgroundColor3 = Color3.fromRGB(28, 28, 28), BackgroundTransparency = 0.35,
        BorderSizePixel = 0, AutoButtonColor = false, ZIndex = 20,
    })
    Round(close, 8)
    Stroke(close, Color3.fromRGB(0, 0, 0), 0, 1.2)

    local mini = New("TextButton", gui, {
        Name = "MinimizedFrame", Size = UDim2.fromOffset(110, 30), Position = UDim2.fromOffset(16, 58),
        Text = self.Title, BackgroundColor3 = Color3.fromRGB(16, 16, 16), BackgroundTransparency = 0.15,
        BorderSizePixel = 0, AutoButtonColor = false, Visible = false, ZIndex = 25,
        Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.fromRGB(220, 220, 220),
    })
    Round(mini, 10)
    Stroke(mini, Color3.fromRGB(0, 0, 0), 0, 1.5)
    self.MiniButton = mini

    -- Open / close animation
    local animating, animationId, tween = false, 0, nil
    local function animate(open)
        animationId = animationId + 1
        local thisId = animationId
        if tween then tween:Cancel() end
        animating = true
        main.Visible = true
        mini.Visible = false
        local width, height = self.FitWidth or self.BaseWidth, self.FitHeight or self.BaseHeight
        if open then main.Size = UDim2.fromOffset(width - 10, height - 8) end
        tween = TS:Create(main, TweenInfo.new(self.Effects and 0.23 or 0.01, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { Size = UDim2.fromOffset(open and width or width - 10, open and height or height - 8) })
        tween.Completed:Connect(function()
            if thisId ~= animationId or not main.Parent then return end
            animating = false
            main.Visible = open
            mini.Visible = not open
            main.Size = UDim2.fromOffset(width, height)
            self.Opened = open
        end)
        tween:Play()
    end
    self.Opened = true
    function self:Show() animate(true) end
    function self:Hide() animate(false) end
    function self:Toggle() animate(not self.Opened) end
    close.Activated:Connect(function() self:Hide() end)
    mini.Activated:Connect(function() self:Show() end)

    -- Dragging (header zone 42px)
    do
        local dn, ds, sp, di = false, nil, nil, nil
        local endConn = nil
        local function stopDrag()
            local was = dn
            dn = false
            di = nil
            if endConn then endConn:Disconnect(); endConn = nil end
            if was then self:_changed("move") end
        end
        main.InputBegan:Connect(function(i)
            if self.Locked then return end
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                if i.Position.Y > main.AbsolutePosition.Y + 42 then return end
                dn = true; ds = i.Position; sp = main.Position
                if endConn then endConn:Disconnect() end
                endConn = i.Changed:Connect(function()
                    if i.UserInputState == Enum.UserInputState.End then stopDrag() end
                end)
            end
        end)
        main.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then stopDrag() end
        end)
        table.insert(self._connections, UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then stopDrag() end
        end))
        main.InputChanged:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then di = i end
        end)
        table.insert(self._connections, UIS.InputChanged:Connect(function(i)
            if i == di and dn then
                if self.Locked then stopDrag(); return end
                if not ds or not sp then return end
                main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + (i.Position.X - ds.X),
                    sp.Y.Scale, sp.Y.Offset + (i.Position.Y - ds.Y))
            end
        end))
    end

    -- Body: sidebar + content
    local body = New("Frame", main, {
        Name = "Body", Size = UDim2.new(1, -16, 1, -(BODY_Y + 6)), Position = UDim2.fromOffset(8, BODY_Y),
        BackgroundTransparency = 1, ZIndex = 5,
    })
    local tabBar = New("Frame", body, {
        Name = "Navigation", Size = UDim2.new(0, SIDEBAR_W, 1, 0), Position = UDim2.fromOffset(0, 0),
        BackgroundColor3 = Color3.fromRGB(14, 14, 16), BackgroundTransparency = 0.65,
        BorderSizePixel = 0, ZIndex = 14,
    })
    Round(tabBar, 14)
    Stroke(tabBar, Color3.fromRGB(0, 0, 0), 0.1, 1.4)
    New("UIPadding", tabBar, {
        PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5),
    })
    New("UIListLayout", tabBar, {
        FillDirection = Enum.FillDirection.Vertical, HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top, Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder,
    })
    self.TabBar = tabBar

    self.Content = New("Frame", body, {
        Name = "Content", Size = UDim2.new(1, -(SIDEBAR_W + 6), 1, 0), Position = UDim2.fromOffset(SIDEBAR_W + 6, 0),
        BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 6,
    })

    -- Footer
    local footer = New("Frame", main, {
        Name = "Footer", Position = UDim2.new(0, 10, 1, -22), Size = UDim2.new(1, -20, 0, 18),
        BackgroundTransparency = 1, ZIndex = 8,
    })
    local avatar = New("ImageLabel", footer, {
        Position = UDim2.fromOffset(2, 1), Size = UDim2.fromOffset(14, 14),
        Image = "rbxthumb://type=AvatarHeadShot&id=" .. LP.UserId .. "&w=150&h=150",
        BackgroundColor3 = INP, BorderSizePixel = 0, ZIndex = 8,
    })
    Round(avatar, 4)
    Text(footer, "@" .. LP.Name, UDim2.fromOffset(20, 1), UDim2.new(0.5, -24, 0, 14), 8, Color3.fromRGB(150, 150, 150), 9)
    self.FooterRight = Text(footer, options.FooterText or "👑 KING ROYAL", UDim2.new(0.5, 0, 0, 1),
        UDim2.new(0.5, -2, 0, 14), 8, Color3.fromRGB(255, 215, 0), 9)
    self.FooterRight.TextXAlignment = Enum.TextXAlignment.Right

    -- Fit to viewport, effects, background
    self:Fit()
    local function followCamera()
        if self._viewConn then self._viewConn:Disconnect() end
        local cam = Workspace.CurrentCamera
        if cam then self._viewConn = cam:GetPropertyChangedSignal("ViewportSize"):Connect(function() self:Fit() end) end
        self:Fit()
    end
    local camConn = Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(followCamera)
    followCamera()
    gui.Destroying:Connect(function()
        camConn:Disconnect()
        if self._viewConn then self._viewConn:Disconnect() end
        for _, c in ipairs(self._connections) do pcall(function() c:Disconnect() end) end
        if self._effectConn then self._effectConn:Disconnect() end
        if self._backgroundTween then pcall(function() self._backgroundTween:Cancel() end) end
    end)
    self:_effectsLoop()
    task.spawn(function() pcall(function() game:GetService("ContentProvider"):PreloadAsync({ bg }) end) end)

    return self
end

function Library:_changed(kind)
    if self.OnChanged then task.defer(function() pcall(self.OnChanged, kind) end) end
end

function Library:_theme(fn)
    table.insert(self._themed, fn)
    pcall(fn, self.ThemeColor)
end

function Library:SetTheme(nameOrColor)
    local color = nameOrColor
    if type(nameOrColor) == "string" then
        color = Library.Themes[nameOrColor]
        if not color then return end
        self.ThemeName = nameOrColor
    end
    self.ThemeColor = color
    for _, fn in ipairs(self._themed) do pcall(fn, color) end
end

function Library:SetLocked(on) self.Locked = on and true or false end
function Library:SetEffects(on) self.Effects = on and true or false end
function Library:SetTitle(text) self.Logo.Text = text; self.MiniButton.Text = text end
function Library:SetFooterText(text) self.FooterRight.Text = text end

function Library:SetScale(percent)
    self.ScaleValue = math.clamp(math.floor(percent + 0.5), 50, 150)
    self:Fit()
end

function Library:Fit()
    local main = self.Main
    if not main or not main.Parent then return end
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local viewport = cam.ViewportSize
    local width = self.BaseWidth
    local scale = math.max(0.25, math.min(self.ScaleValue / 100, (viewport.X - 24) / width, (viewport.Y - 24) / (self.BaseHeight + 10)))
    local height = math.min(self.BaseHeight, math.floor((viewport.Y - 24) / scale))
    self.UIScale.Scale = scale
    self.FitWidth, self.FitHeight = width, height
    main.Size = UDim2.fromOffset(width, height)
    local size = Vector2.new(width * scale, height * scale)
    local point = main.AbsolutePosition
    if point.X == 0 and point.Y == 0 then
        point = Vector2.new(main.Position.X.Offset, main.Position.Y.Offset)
    end
    main.Position = UDim2.fromOffset(
        math.clamp(point.X, 8, math.max(8, viewport.X - size.X - 8)),
        math.clamp(point.Y, 8, math.max(8, viewport.Y - size.Y - 8)))
end

-- items: {object=, position=UDim2, x=, y=, rotate=}
function Library:Animate(item)
    table.insert(self.Animated, item)
end

function Library:_effectsLoop()
    local accumulator, elapsed = 0, 0
    self._effectConn = RunService.Heartbeat:Connect(function(dt)
        if not self.Gui.Parent then return end
        accumulator = accumulator + dt
        elapsed = elapsed + dt
        if accumulator < 1 / 24 then return end
        accumulator = 0
        if not self.Effects or not self.Main.Visible then return end
        for i, item in ipairs(self.Animated) do
            if item.object.Parent then
                item.object.Position = item.position + UDim2.fromOffset(
                    math.sin(elapsed * 0.6 + i) * (item.x or 0), math.sin(elapsed * 1.1 + i) * (item.y or 4))
                if item.rotate then item.object.Rotation = math.sin(elapsed * 0.7 + i) * item.rotate end
            end
        end
    end)
end

function Library:Destroy()
    if self.Gui then self.Gui:Destroy() end
end

----------------------------------------------------------------------
-- Background
----------------------------------------------------------------------
function Library:SetBackground(mode)
    local images = self.Backgrounds
    if mode == "None" then
        self.BackgroundMode = "None"
    else
        local n = tonumber(string.match(tostring(mode), "^Background%s+(%d+)$")) or self.BackgroundIndex
        self.BackgroundIndex = math.clamp(math.floor(n), 1, #images)
        self.BackgroundMode = "Background " .. self.BackgroundIndex
    end
    self._backgroundRevision = self._backgroundRevision + 1
    local revision = self._backgroundRevision
    local main = self.Main
    if main then
        main.BackgroundColor3 = Color3.fromRGB(9, 12, 16)
        main.BackgroundTransparency = 0.40
        local bg = main:FindFirstChild("BackgroundImage")
        local overlay = main:FindFirstChild("BackgroundIncoming")
        if overlay then overlay:Destroy() end
        if self._backgroundTween then self._backgroundTween:Cancel() end
        if bg then
            local asset = "rbxassetid://" .. images[self.BackgroundIndex]
            local opacity = self.BackgroundMode == "None" and 1 or self.BackgroundImageTransparency
            if self.BackgroundMode == "None" or not self.Effects or bg.Image == asset then
                bg.Image = asset
                bg.ImageTransparency = opacity
            else
                local incoming = bg:Clone()
                incoming.Name = "BackgroundIncoming"
                incoming.Image = asset
                incoming.ImageTransparency = 1
                incoming.ZIndex = 1
                incoming.Parent = main
                self._backgroundTween = TS:Create(incoming, TweenInfo.new(0.28, Enum.EasingStyle.Quad), { ImageTransparency = opacity })
                self._backgroundTween.Completed:Connect(function()
                    if revision == self._backgroundRevision and bg.Parent then
                        bg.Image = asset
                        bg.ImageTransparency = opacity
                    end
                    if incoming.Parent then incoming:Destroy() end
                end)
                self._backgroundTween:Play()
            end
        end
    end
    if self.BackgroundLabel then self.BackgroundLabel.Text = self.BackgroundMode end
    for i, card in ipairs(self.Cards) do
        if card.Parent then
            local stroke = card:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Transparency = (self.BackgroundMode ~= "None" and i == self.BackgroundIndex) and 0 or 0.72 end
            local badge = card:FindFirstChild("Selected")
            if badge then badge.Visible = self.BackgroundMode ~= "None" and i == self.BackgroundIndex end
        end
    end
end

----------------------------------------------------------------------
-- Tabs
----------------------------------------------------------------------
function Library:AddTab(cfg)
    cfg = cfg or {}
    local window = self
    local i = #self.Tabs + 1
    local first = i == 1
    local title = cfg.Title or cfg.Name or ("Tab " .. i)

    local button = New("TextButton", self.TabBar, {
        Name = cfg.Name or title, Text = title, Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = first and Color3.fromRGB(48, 38, 14) or Color3.fromRGB(18, 18, 22),
        BackgroundTransparency = first and 0.35 or 0.70, BorderSizePixel = 0,
        Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = first and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(150, 150, 150),
        AutoButtonColor = false, ZIndex = 15, LayoutOrder = i,
    })
    Round(button, 8)
    local stroke = Stroke(button, Color3.fromRGB(0, 0, 0), 0.15, 1.2)
    stroke.Name = "TabStroke"

    local icon
    if cfg.Icon then
        icon = Library.CreateIcon(button, cfg.Icon, {
            Name = "TabIcon", Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(8, 8),
            ImageColor3 = first and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(150, 150, 150), ZIndex = 16,
        })
        if icon then New("UIPadding", button, { PaddingLeft = UDim.new(0, 22) }) end
    end

    local page = New("ScrollingFrame", self.Content, {
        Name = cfg.Name or title, Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(12, 12, 16), BackgroundTransparency = 0.70,
        BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100),
        ScrollBarImageTransparency = 0.3, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(),
        ScrollingDirection = Enum.ScrollingDirection.Y, ClipsDescendants = true, Visible = first, ZIndex = 6,
    })
    Round(page, 12)
    Stroke(page, Color3.fromRGB(0, 0, 0), 0.12, 1.2)
    New("UIListLayout", page, {
        Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    })
    New("UIPadding", page, {
        PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 18),
    })

    local tab = setmetatable({
        Window = self, Button = button, Page = page, Index = i, Icon = icon,
        Heading = string.format("%02d   /   %s", i, cfg.Heading or title:upper()), _order = 0,
    }, Tab)

    function tab:Select()
        window.CurrentHeading = self.Heading
        for _, t in ipairs(window.Tabs) do t.Page.Visible = false end
        page.Visible = true
        for _, t in ipairs(window.Tabs) do
            local on = t == self
            t.Button.TabStroke.Transparency = on and 0.1 or 0.25
            t.Button.TextColor3 = on and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(150, 150, 150)
            if t.Icon then t.Icon.ImageColor3 = t.Button.TextColor3 end
            TS:Create(t.Button, TweenInfo.new(0.12), {
                BackgroundTransparency = on and 0.35 or 0.70,
                BackgroundColor3 = on and Color3.fromRGB(48, 38, 14) or Color3.fromRGB(18, 18, 22),
            }):Play()
        end
    end

    table.insert(self.Tabs, tab)
    table.insert(self.TabButtons, button)
    button.Activated:Connect(function() tab:Select() end)
    if first then window.CurrentHeading = tab.Heading end
    return tab
end

----------------------------------------------------------------------
-- Tab components
----------------------------------------------------------------------
function Tab:_row(height, noBorder)
    self._order = self._order + 1
    local row = New("Frame", self.Page, {
        Name = "Control", Size = UDim2.new(1, -2, 0, math.max(height or 34, 32)),
        BackgroundColor3 = Color3.fromRGB(16, 16, 20), BackgroundTransparency = noBorder and 1 or 0.55,
        BorderSizePixel = 0, LayoutOrder = self._order, ZIndex = 7,
    })
    Round(row, 10)
    if not noBorder then
        local stroke = Stroke(row, Color3.fromRGB(50, 42, 28), 0.40, 1.2)
        row.MouseEnter:Connect(function()
            TS:Create(stroke, TweenInfo.new(0.1), { Transparency = 0.1, Color = Color3.fromRGB(196, 154, 28) }):Play()
        end)
        row.MouseLeave:Connect(function()
            TS:Create(stroke, TweenInfo.new(0.1), { Transparency = 0.40, Color = Color3.fromRGB(50, 42, 28) }):Play()
        end)
    end
    return row
end

function Tab:_label(row, text)
    return Text(row, text, UDim2.fromOffset(10, 0), UDim2.new(0.55, 0, 1, 0), 11, WHITE, 8)
end

function Tab:Section(text)
    self._order = self._order + 1
    local row = New("Frame", self.Page, {
        Name = "Section", Size = UDim2.new(1, -2, 0, 20), BackgroundTransparency = 1,
        LayoutOrder = self._order, ZIndex = 7,
    })
    local label = Text(row, tostring(text):upper(), UDim2.fromOffset(6, 0), UDim2.new(1, -12, 1, 0), 10, Color3.fromRGB(255, 215, 0), 8)
    label.Font = Enum.Font.GothamBlack
    return row
end

function Tab:Spacer(height)
    self._order = self._order + 1
    return New("Frame", self.Page, {
        Size = UDim2.new(1, 0, 0, height or 16), BackgroundTransparency = 1,
        LayoutOrder = self._order, ZIndex = 7,
    })
end

-- Toggle -------------------------------------------------------------
function Tab:Toggle(cfg)
    local window = self.Window
    local row = self:_row(cfg.Height or 34)
    local label = self:_label(row, cfg.Text or "")
    label.Size = UDim2.new(1, -55, 1, 0)

    local pill = New("Frame", row, {
        Name = "Track", Size = UDim2.fromOffset(36, 18), AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0), BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BorderSizePixel = 0, ZIndex = 8,
    })
    Round(pill, 9)
    Stroke(pill, Color3.fromRGB(0, 0, 0), 0.15, 1.2)
    local dot = New("Frame", pill, {
        Name = "Knob", AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.fromOffset(12, 12),
        Position = UDim2.new(0, 3, 0.5, 0), BackgroundColor3 = Color3.fromRGB(160, 160, 160),
        BorderSizePixel = 0, ZIndex = 9,
    })
    Round(dot, 6)

    local object = { Row = row, Label = label }
    local on = false
    local function set(value)
        on = value == true
        row:SetAttribute("KINGActive", on)
        TS:Create(pill, TweenInfo.new(0.08), {
            BackgroundColor3 = on and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(35, 35, 35),
        }):Play()
        TS:Create(dot, TweenInfo.new(0.08), {
            Position = on and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
            BackgroundColor3 = on and Color3.fromRGB(15, 15, 15) or Color3.fromRGB(160, 160, 160),
        }):Play()
        local pillStroke = pill:FindFirstChildOfClass("UIStroke")
        if pillStroke then
            pillStroke.Color = on and Color3.fromRGB(220, 180, 20) or Color3.fromRGB(0, 0, 0)
            pillStroke.Transparency = 0.15
        end
        row:FindFirstChildOfClass("UIStroke").Transparency = on and 0.4 or 0.73
    end
    function object:Set(value) set(value) end
    function object:Get() return on end

    local hit = New("TextButton", row, {
        Name = "ToggleHit", Size = UDim2.fromScale(1, 1), Text = "", BackgroundTransparency = 1,
        AutoButtonColor = false, ZIndex = 10,
    })
    hit.Activated:Connect(function()
        local previous = on
        set(not on)
        if cfg.Callback then
            local ok, err = pcall(cfg.Callback, on)
            if not ok then set(previous); warn("[KING] " .. tostring(cfg.Text) .. ": " .. tostring(err)) end
        end
        window:_changed("toggle")
    end)

    if cfg.Default == true then set(true) end
    return object
end

-- Input (numeric box) -------------------------------------------------
function Tab:Input(cfg)
    local window = self.Window
    local row = self:_row(cfg.Height or 42)
    self:_label(row, cfg.Text or "")
    local w = math.max(cfg.Width or 56, 64)
    local box = New("TextBox", row, {
        Size = UDim2.fromOffset(w, 32), Position = UDim2.new(1, -math.max(cfg.XOffset or 76, w + 12), 0.5, -16),
        Text = tostring(cfg.Default or ""), BackgroundColor3 = INP, BackgroundTransparency = 0.35,
        BorderSizePixel = 0, Font = Enum.Font.GothamBold, TextSize = 13,
        TextColor3 = Color3.fromRGB(250, 202, 129), ClearTextOnFocus = false, ZIndex = 9,
    })
    Round(box, 9)
    local border = Stroke(box, ROW_BORDER, 0.58, 1)
    local lastValid = tostring(cfg.Default or "")
    local numeric = cfg.Numeric ~= false

    box.Focused:Connect(function() border.Color = window.ThemeColor; border.Transparency = 0.10 end)
    box.FocusLost:Connect(function()
        border.Color = ROW_BORDER; border.Transparency = 0.58
        local value = numeric and tonumber(box.Text) or box.Text
        if (numeric and finite(value)) or (not numeric and value ~= "") then
            local ok = true
            if cfg.Callback then ok = pcall(cfg.Callback, value) end
            if ok then lastValid = box.Text else box.Text = lastValid end
        else
            box.Text = lastValid
        end
        window:_changed("input")
    end)

    local object = { Row = row, Box = box }
    function object:Set(value) box.Text = tostring(value); lastValid = box.Text end
    function object:Get() return numeric and tonumber(box.Text) or box.Text end
    return object
end

-- Selector (‹ value ›) ---------------------------------------------
function Tab:Selector(cfg)
    local window = self.Window
    local row = self:_row(cfg.Height or 46)
    self:_label(row, cfg.Text or "")
    local options = cfg.Options or {}
    local index = 1
    if cfg.Default ~= nil then
        for i, v in ipairs(options) do if v == cfg.Default then index = i end end
    end

    local frame = New("Frame", row, {
        Name = "Selector", Size = UDim2.fromOffset(146, 32), Position = UDim2.new(1, -156, 0.5, -16),
        BackgroundColor3 = INP, BackgroundTransparency = 0.35, BorderSizePixel = 0, ZIndex = 8,
    })
    Round(frame, 6)
    Stroke(frame, ROW_BORDER, 0.68, 1)
    local label = Text(frame, tostring(options[index] ~= nil and options[index] or cfg.Default or ""),
        UDim2.fromOffset(30, 0), UDim2.fromOffset(86, 32), 10, WHITE, 9)
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Center

    for i, direction in ipairs({ -1, 1 }) do
        local button = New("TextButton", frame, {
            Size = UDim2.fromOffset(29, 32), Position = UDim2.fromOffset(i == 1 and 0 or 117, 0),
            BackgroundColor3 = INP, BorderSizePixel = 0, Text = direction == -1 and "‹" or "›",
            TextSize = 21, Font = Enum.Font.GothamMedium, TextColor3 = window.ThemeColor,
            AutoButtonColor = false, ZIndex = 9,
        })
        Round(button, 6)
        window:_theme(function(c) button.TextColor3 = c end)
        button.Activated:Connect(function()
            if cfg.Handler then
                cfg.Handler(direction, function(text) label.Text = text end)
            elseif #options > 0 then
                index = (index - 1 + direction) % #options + 1
                label.Text = tostring(options[index])
                if cfg.Callback then pcall(cfg.Callback, options[index], index) end
            end
            window:_changed("selector")
        end)
    end

    local object = { Row = row, Label = label }
    function object:Set(value)
        for i, v in ipairs(options) do if v == value then index = i end end
        label.Text = tostring(value)
    end
    function object:Get() return options[index] end
    return object
end

-- Keybind -------------------------------------------------------------
-- entry = {kb = Enum.KeyCode | nil, gp = Enum.KeyCode | nil}
function Tab:Keybind(cfg)
    local window = self.Window
    local entry = cfg.Entry or {}
    if typeof(cfg.Default) == "EnumItem" then entry.kb = cfg.Default end
    local row = self:_row(cfg.Height or 46)
    self:_label(row, cfg.Text or "")

    local function name()
        return (entry.gp and entry.gp.Name) or (entry.kb and entry.kb.Name) or "None"
    end
    local button = New("TextButton", row, {
        Size = UDim2.fromOffset(116, 32), Position = UDim2.new(1, -128, 0.5, -16), Text = name(),
        BackgroundColor3 = INP, BackgroundTransparency = 0.35, TextSize = 11, Font = Enum.Font.GothamBold,
        TextColor3 = WHITE, BorderSizePixel = 0, AutoButtonColor = false, ZIndex = 9,
    })
    Round(button, 9)
    Stroke(button, ROW_BORDER, 0.42, 1)

    local connection, axisConnection, timeout, listening = nil, nil, nil, false
    local function stop()
        listening = false
        window.AnyKeyListening = false
        if connection then connection:Disconnect(); connection = nil end
        if axisConnection then axisConnection:Disconnect(); axisConnection = nil end
        if timeout then pcall(task.cancel, timeout); timeout = nil end
        button.Text = name()
        button.TextColor3 = WHITE
    end

    button.Activated:Connect(function()
        if listening then stop(); return end
        if window.AnyKeyListening then return end
        listening = true
        window.AnyKeyListening = true
        button.Text = "Press a key"
        button.TextColor3 = window.ThemeColor
        local started = tick()
        local function accept(input)
            if not listening then return end
            if input.KeyCode == Enum.KeyCode.Escape then stop(); return end
            if not isBindableInput(input) then return end
            local controller = isGamepadInput(input)
            if controller and tick() - started < 0.2 then return end
            if controller and (input.KeyCode == Enum.KeyCode.ButtonL2 or input.KeyCode == Enum.KeyCode.ButtonR2)
                and input.Position.Z < 0.55 then return end
            if controller then entry.gp = input.KeyCode; entry.kb = nil
            else entry.kb = input.KeyCode; entry.gp = nil end
            stop()
            if cfg.Callback then pcall(cfg.Callback, entry) end
            window:_changed("keybind")
        end
        connection = UIS.InputBegan:Connect(accept)
        axisConnection = UIS.InputChanged:Connect(accept)
        timeout = task.delay(10, stop)
    end)

    local object = { Row = row, Button = button, Entry = entry }
    function object:Refresh() if not listening then button.Text = name() end end
    table.insert(window.KeyButtons, object)
    return object
end

-- Value row (label + right-aligned value, optional click) --------------
function Tab:Value(cfg)
    local row = self:_row(cfg.Height or 42)
    self:_label(row, cfg.Text or "")
    local value = New("TextLabel", row, {
        Size = UDim2.new(0, 110, 1, 0), Position = UDim2.new(1, -118, 0, 0), BackgroundTransparency = 1,
        Text = tostring(cfg.Value or ""), TextColor3 = WHITE, Font = Enum.Font.GothamBold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 8,
    })
    local click = New("TextButton", row, {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 8,
    })
    click.MouseButton1Click:Connect(function() if cfg.Callback then cfg.Callback() end end)
    local object = { Row = row, Label = value }
    function object:Set(text) value.Text = tostring(text) end
    return object
end

-- Chip (label + small button, e.g. "Jump Mode  [HOLD]") ----------------
function Tab:Chip(cfg)
    local window = self.Window
    local row = self:_row(cfg.Height or 42)
    self:_label(row, cfg.Text or "")
    local button = New("TextButton", row, {
        Size = UDim2.new(0, 100, 0, 32), Position = UDim2.new(1, -108, 0.5, -16),
        BackgroundColor3 = INP, BackgroundTransparency = 0.4, BorderSizePixel = 0,
        Text = tostring(cfg.Value or ""), TextColor3 = WHITE, Font = Enum.Font.GothamBold, TextSize = 11, ZIndex = 8,
    })
    Round(button, 6)
    button.Activated:Connect(function()
        if cfg.Callback then cfg.Callback(button) end
        window:_changed("chip")
    end)
    return button
end

-- Stepper ( < 100% > ) ------------------------------------------------
function Tab:Stepper(cfg)
    local window = self.Window
    local row = self:_row(cfg.Height or 42)
    self:_label(row, cfg.Text or "")
    local min, max, step = cfg.Min or 50, cfg.Max or 200, cfg.Step or 5
    local suffix = cfg.Suffix == nil and "%" or cfg.Suffix
    local value = cfg.Default or 100

    local frame = New("Frame", row, {
        Size = UDim2.fromOffset(130, 28), Position = UDim2.new(1, -140, 0.5, -14),
        BackgroundColor3 = Color3.fromRGB(28, 28, 32), BackgroundTransparency = 0.25, BorderSizePixel = 0, ZIndex = 8,
    })
    Round(frame, 6)
    local pct = New("TextLabel", frame, {
        Size = UDim2.new(1, -56, 1, 0), Position = UDim2.fromOffset(28, 0), BackgroundTransparency = 1,
        Text = tostring(value) .. suffix, TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold, TextSize = 12, ZIndex = 9,
    })
    local function set(v, silent)
        value = math.clamp(math.floor(v + 0.5), min, max)
        pct.Text = tostring(value) .. suffix
        if not silent then
            if cfg.Callback then pcall(cfg.Callback, value) end
            window:_changed("stepper")
        end
    end
    local function arrow(text, position, delta)
        local b = New("TextButton", frame, {
            Size = UDim2.fromOffset(26, 28), Position = position, BackgroundTransparency = 1, Text = text,
            TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold, TextSize = 14, ZIndex = 10,
        })
        b.MouseButton1Click:Connect(function() set(value + delta) end)
    end
    arrow("<", UDim2.fromOffset(0, 0), -step)
    arrow(">", UDim2.new(1, -26, 0, 0), step)

    local object = { Row = row }
    function object:Set(v) set(v, true) end
    function object:Get() return value end
    return object
end

-- Button (primary / danger) -------------------------------------------
function Tab:Button(cfg)
    local window = self.Window
    local row = self:_row(cfg.Height or 44)
    row.Size = UDim2.new(1, 0, 0, cfg.Height or 44)

    local danger = cfg.Style == "Danger"
    local idleBg = Color3.fromRGB(27, 30, 33)
    local idleText = danger and Color3.fromRGB(170, 30, 50) or Color3.fromRGB(240, 214, 175)
    local button = New("TextButton", row, {
        Size = UDim2.new(1, -12, 0.8, 0), Position = UDim2.new(0, 6, 0.1, 0), BackgroundColor3 = idleBg,
        BorderSizePixel = 0, Text = cfg.Text or "", TextColor3 = idleText, Font = Enum.Font.GothamBold,
        TextSize = 13, AutoButtonColor = false, ZIndex = 8,
    })
    Round(button, 6)
    local stroke = Instance.new("UIStroke", button)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.4
    if danger then
        stroke.Color = Color3.fromRGB(200, 60, 80)
    else
        window:_theme(function(c) stroke.Color = c end)
    end
    button.MouseEnter:Connect(function()
        TS:Create(button, TweenInfo.new(0.15), { BackgroundColor3 = danger and Color3.fromRGB(200, 50, 70) or window.ThemeColor }):Play()
        TS:Create(button, TweenInfo.new(0.15), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
    end)
    button.MouseLeave:Connect(function()
        TS:Create(button, TweenInfo.new(0.15), { BackgroundColor3 = idleBg }):Play()
        TS:Create(button, TweenInfo.new(0.15), { TextColor3 = idleText }):Play()
    end)
    button.MouseButton1Click:Connect(function() if cfg.Callback then cfg.Callback(button) end end)

    local object = { Row = row, Button = button }
    function object:SetText(text) button.Text = text end
    return object
end

-- ListButton (song-style row button, optional cover image) ------------
function Tab:ListButton(cfg)
    local window = self.Window
    local row = self:_row(cfg.Height or 44)
    row.Size = UDim2.new(1, 0, 0, cfg.Height or 44)
    local button = New("TextButton", row, {
        Size = UDim2.new(1, -12, 1, -8), Position = UDim2.fromOffset(6, 4), Text = cfg.Text or "",
        TextSize = 13, Font = Enum.Font.GothamBold, TextColor3 = WHITE, BackgroundColor3 = INP,
        BorderSizePixel = 0, AutoButtonColor = false, ZIndex = 8,
    })
    local cover
    if cfg.Cover ~= nil then
        button.Position = UDim2.fromOffset(44, 4)
        button.Size = UDim2.new(1, -50, 1, -8)
        cover = New("ImageLabel", row, {
            Name = "SongCover", Position = UDim2.fromOffset(6, 6), Size = UDim2.fromOffset(32, 32),
            BackgroundTransparency = 1, Image = cfg.Cover, ScaleType = Enum.ScaleType.Fit, ZIndex = 8,
        })
        Round(cover, 5)
    end
    Round(button, 6)
    local stroke = Stroke(button, window.ThemeColor, 0.4, 1)
    window:_theme(function(c) stroke.Color = c end)
    button.Activated:Connect(function() if cfg.Callback then cfg.Callback(button) end end)
    return { Row = row, Button = button, Cover = cover }
end

-- Background selector + grid ------------------------------------------
function Tab:BackgroundSelector(text)
    local window = self.Window
    local options = { "None" }
    for i = 1, #window.Backgrounds do table.insert(options, "Background " .. i) end
    local function currentIndex()
        if window.BackgroundMode == "None" then return 1 end
        local n = tonumber(string.match(window.BackgroundMode, "^Background%s+(%d+)$")) or 1
        return math.clamp(n + 1, 1, #options)
    end
    local selector = self:Selector({
        Text = text or "Background", Height = 42, Default = window.BackgroundMode, Options = options,
        Handler = function(direction, update)
            local idx = currentIndex() + direction
            if idx < 1 then idx = #options end
            if idx > #options then idx = 1 end
            window:SetBackground(options[idx])
            update(window.BackgroundMode)
        end,
    })
    window.BackgroundLabel = selector.Label
    window:SetBackground(window.BackgroundMode)
    return selector
end

function Tab:BackgroundGrid(cfg)
    cfg = cfg or {}
    local window = self.Window
    local total = #window.Backgrounds
    local cols = cfg.Columns or 2
    local rowsN = math.ceil(total / cols)
    local gap = cfg.Gap or 6
    local cardH = cfg.CardHeight or 52
    local rowH = rowsN * cardH + (rowsN - 1) * gap + 4
    local row = self:_row(rowH, true)

    for i, asset in ipairs(window.Backgrounds) do
        local col = (i - 1) % cols
        local r = math.floor((i - 1) / cols)
        local card = New("ImageButton", row, {
            Size = UDim2.new(1 / cols, -gap, 0, cardH),
            Position = UDim2.new(col / cols, col * (gap / 2), 0, r * (cardH + gap)),
            Image = "rbxassetid://" .. asset, ScaleType = Enum.ScaleType.Crop,
            BackgroundColor3 = Color3.fromRGB(18, 18, 18), BorderSizePixel = 0, AutoButtonColor = false,
            ClipsDescendants = true, ZIndex = 8,
        })
        Round(card, 10)
        Stroke(card, Color3.fromRGB(0, 0, 0), 0.15, 1.5)
        local scrim = New("Frame", card, {
            Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(8, 12, 17),
            BackgroundTransparency = 0.6, BorderSizePixel = 0, ZIndex = 9,
        })
        Round(scrim, 12)
        local badge = New("Frame", card, {
            Name = "Selected", Size = UDim2.fromOffset(16, 16), Position = UDim2.new(1, -22, 0, 6),
            BackgroundColor3 = window.ThemeColor, BorderSizePixel = 0, Visible = false, ZIndex = 10,
        })
        Round(badge, 6)
        window:_theme(function(c) badge.BackgroundColor3 = c end)
        local check = Text(badge, "✓", UDim2.fromOffset(0, 0), UDim2.fromScale(1, 1), 11, WHITE, 11)
        check.TextXAlignment = Enum.TextXAlignment.Center
        local label = Text(card, (cfg.Prefix or "SCENE 0") .. i, UDim2.new(0, 8, 1, -25), UDim2.new(1, -12, 0, 19), 9, WHITE, 10)
        label.Font = Enum.Font.GothamBold
        card.Activated:Connect(function()
            window:SetBackground("Background " .. i)
            window:_changed("background")
        end)
        window.Cards[i] = card
    end
    window:SetBackground(window.BackgroundMode)
    return row
end

----------------------------------------------------------------------
-- Auto Grab HUD (ModernAutoGrab)
----------------------------------------------------------------------
function Library:CreateHud(cfg)
    cfg = cfg or {}
    local window = self
    local shell = New("Frame", self.Gui, {
        Name = cfg.Name or "ModernAutoGrab", Size = UDim2.fromOffset(330, 48),
        Position = cfg.Position or UDim2.new(1, -345, 0, 18), AnchorPoint = Vector2.new(0, 0),
        BackgroundColor3 = Color3.fromRGB(12, 12, 14), BackgroundTransparency = 0.12, BorderSizePixel = 0,
        ClipsDescendants = true, Active = true, ZIndex = 50,
    })
    Round(shell, 14)
    local uiScale = New("UIScale", shell, { Scale = math.clamp((cfg.Scale or 100) / 100, 0.5, 2) })

    local outline = New("UIStroke", shell, {
        Name = "RoyalOutline", Thickness = 1.6, Transparency = 0, Color = Color3.fromRGB(0, 0, 0),
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
    local outlineGradient = New("UIGradient", outline, {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(25, 25, 25)),
            ColorSequenceKeypoint.new(0.66, Color3.fromRGB(255, 235, 75)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 215, 0)),
        }),
    })

    local fill = New("Frame", shell, {
        Name = "ProgressFill", Position = UDim2.fromOffset(3, 3), Size = UDim2.new(0, 0, 1, -6),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.22,
        BorderSizePixel = 0, ZIndex = 51,
    })
    Round(fill, 11)
    local fillGradient = New("UIGradient", fill, {
        Color = ColorSequence.new(Color3.fromRGB(255, 225, 50), Color3.fromRGB(215, 165, 20)),
    })

    -- Crown: real Lucide icon (fallback: 👑 text, never hand-drawn frames)
    local crown = Library.CreateIcon(shell, cfg.Icon or "crown", {
        Name = "Crown", Size = UDim2.fromOffset(30, 30), Position = UDim2.fromOffset(10, 9),
        ImageColor3 = Color3.fromRGB(255, 215, 0), ZIndex = 52,
    })
    if not crown then
        crown = New("TextLabel", shell, {
            Name = "Crown", Size = UDim2.fromOffset(30, 30), Position = UDim2.fromOffset(10, 9),
            BackgroundTransparency = 1, Text = "👑", TextSize = 22, Font = Enum.Font.GothamBold,
            TextColor3 = Color3.fromRGB(255, 215, 0), ZIndex = 52,
        })
    end

    local accent = New("Frame", shell, {
        Name = "RoyalAccent", Size = UDim2.fromOffset(3, 24), Position = UDim2.fromOffset(46, 12),
        BackgroundColor3 = Color3.fromRGB(255, 215, 0), BorderSizePixel = 0, ZIndex = 53,
    })
    Round(accent, 2)

    local title = New("TextLabel", shell, {
        Name = "Title", BackgroundTransparency = 1, Position = UDim2.fromOffset(56, 7), Size = UDim2.fromOffset(130, 17),
        Font = Enum.Font.GothamBold, Text = cfg.Title or "AUTO GRAB", TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 53,
    })
    local sub = New("TextLabel", shell, {
        Name = "Subtitle", BackgroundTransparency = 1, Position = UDim2.fromOffset(56, 25), Size = UDim2.fromOffset(150, 14),
        Font = Enum.Font.Gotham, Text = cfg.Subtitle or "HALF HOLD  •  KING ROYAL",
        TextColor3 = Color3.fromRGB(240, 205, 90), TextSize = 8, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 53,
    })
    local status = New("TextLabel", shell, {
        Name = "StealProgressStatus", BackgroundTransparency = 1, Position = UDim2.new(1, -95, 0, 0),
        Size = UDim2.fromOffset(85, 48), Font = Enum.Font.GothamBlack, Text = "UNREADY",
        TextColor3 = Color3.fromRGB(160, 160, 160), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right,
        TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 53,
    })
    local percent = New("TextLabel", shell, {
        Name = "StealProgressPercent", BackgroundTransparency = 1, Position = UDim2.new(1, -155, 0, 0),
        Size = UDim2.fromOffset(55, 48), Font = Enum.Font.GothamBold, Text = "0%",
        TextColor3 = Color3.fromRGB(255, 220, 50), TextSize = 10, TextXAlignment = Enum.TextXAlignment.Right,
        TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 53,
    })
    local grabBtn = New("TextButton", shell, {
        BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "", AutoButtonColor = false, ZIndex = 55,
    })

    local hud = { Frame = shell, Value = 0, State = nil }
    local displayed = 0

    attachDrag(grabBtn, shell, 4, function() return window.Locked end, function()
        if cfg.OnMoved then pcall(cfg.OnMoved, shell.Position) end
        window:_changed("hud-move")
    end)
    grabBtn.Activated:Connect(function() if cfg.OnClick then pcall(cfg.OnClick) end end)

    local conn = RunService.RenderStepped:Connect(function(dt)
        if not shell.Parent then return end
        outlineGradient.Rotation = (outlineGradient.Rotation + dt * 45) % 360
        fillGradient.Offset = Vector2.new(math.sin(os.clock() * 1.5) * 0.12, 0)
        local target = hud.Value
        displayed = displayed + (target - displayed) * math.clamp(dt * 10, 0, 1)
        local d = math.clamp(displayed, 0, 1)
        fill.Size = UDim2.new(d, -6 * d, 1, -6)
        percent.Text = math.floor(d * 100 + 0.5) .. "%"
        local ready = displayed >= 0.87 or hud.State == "COMPLETE"
        local current = hud.State or (ready and "READY" or "UNREADY")
        status.Text = ready and (current == "COMPLETE" and "COMPLETE" or "READY 👑")
            or (current == "APPROACH" and "APPROACH" or current)
        status.TextColor3 = ready and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(160, 160, 160)
        accent.BackgroundColor3 = ready and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(70, 65, 30)
    end)
    shell.Destroying:Connect(function() conn:Disconnect() end)

    function hud:SetProgress(value, state)
        self.Value = math.clamp(value or 0, 0, 1)
        self.State = state
    end
    function hud:SetScale(percentValue) uiScale.Scale = math.clamp(percentValue / 100, 0.5, 2) end
    function hud:SetVisible(on) shell.Visible = on end
    function hud:SetTitle(text, subtitle) title.Text = text; if subtitle then sub.Text = subtitle end end
    function hud:Destroy() shell:Destroy() end
    return hud
end

----------------------------------------------------------------------
-- Floating button panel (mobile style 2-column grid)
----------------------------------------------------------------------
function Library:CreateFloatingPanel(cfg)
    cfg = cfg or {}
    local window = self
    local panel = { Buttons = {}, Positions = cfg.Positions or {}, Scale = cfg.Scale or 100, Defs = cfg.Buttons or {} }
    local panelName = cfg.Name or "KingVS_MobilePanel"

    local function metrics()
        local s = math.clamp(tonumber(panel.Scale) or 100, 50, 200) / 100
        return math.max(32, math.floor(60 * s + 0.5)), math.max(4, math.floor(8 * s + 0.5)),
            math.max(8, math.floor(10 * s + 0.5)), math.max(8, math.floor(18 * s + 0.5))
    end

    function panel:Build()
        local states = {}
        for name, b in pairs(self.Buttons) do states[name] = b.Active end
        if self.Gui then self.Gui:Destroy() end
        self.Buttons = {}

        local okCore, CoreGui = pcall(function() return game:GetService("CoreGui") end)
        local gui = New("ScreenGui", nil, {
            Name = panelName, ResetOnSpawn = false, DisplayOrder = 120, IgnoreGuiInset = true,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        })
        pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
        if not (okCore and pcall(function() gui.Parent = CoreGui end)) then gui.Parent = LP:WaitForChild("PlayerGui") end
        self.Gui = gui

        local BTN_W, GAP, TEXT_SZ, CORNER = metrics()
        local BTN_H = BTN_W
        local COLUMNS = 2
        local PANEL_W = BTN_W * COLUMNS + GAP * (COLUMNS - 1)

        local container = New("Frame", gui, {
            Name = "FloatingPanel", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
            BorderSizePixel = 0, Active = false, Selectable = false,
        })
        local holder = New("Frame", container, {
            Name = "ButtonsContainer", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
            Active = false, Selectable = false,
        })

        local INACTIVE_BG, ACTIVE_BG = Color3.fromRGB(14, 14, 16), Color3.fromRGB(255, 215, 0)
        local INACTIVE_TEXT, ACTIVE_TEXT = Color3.fromRGB(235, 235, 235), Color3.fromRGB(14, 14, 14)
        local STROKE_COLOR, ACCENT = Color3.fromRGB(0, 0, 0), Color3.fromRGB(255, 230, 70)

        for _, def in ipairs(self.Defs) do
            local order = def.Order or 0
            local cam = Workspace.CurrentCamera
            local vw = (cam and cam.ViewportSize.X) or 1920
            local dx = vw - (PANEL_W + 10) + (order % 2) * (BTN_W + GAP)
            local dy = 12 + math.floor(order / 2) * (BTN_H + GAP + 10)

            local btn = New("TextButton", holder, {
                Name = def.Name, Size = UDim2.new(0, BTN_W, 0, BTN_H), Position = UDim2.new(0, dx, 0, dy),
                BackgroundColor3 = INACTIVE_BG, BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = 30,
                Active = true, Selectable = true,
            })
            local saved = self.Positions[def.Name]
            if type(saved) == "table" then
                local xo = tonumber(saved.xOffset or saved.x or saved.X)
                local yo = tonumber(saved.yOffset or saved.y or saved.Y)
                if xo and yo then
                    btn.Position = UDim2.new(tonumber(saved.xScale) or 0, xo, tonumber(saved.yScale) or 0, yo)
                end
            end
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, CORNER)
            local stroke = Instance.new("UIStroke", btn)
            stroke.Name = "NormalStroke"
            stroke.Color = STROKE_COLOR
            stroke.Thickness = 1.5
            stroke.Transparency = 0
            local label = New("TextLabel", btn, {
                Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = def.Text or def.Name,
                TextColor3 = INACTIVE_TEXT, Font = Enum.Font.GothamBlack, TextSize = TEXT_SZ,
                TextWrapped = true, ZIndex = 31, Active = false, Selectable = false,
            })

            local item = { Instance = btn, Active = false }
            function item:SetActive(state)
                self.Active = state and true or false
                local a = self.Active
                TS:Create(btn, TweenInfo.new(0.08), { BackgroundColor3 = a and ACTIVE_BG or INACTIVE_BG }):Play()
                TS:Create(label, TweenInfo.new(0.08), { TextColor3 = a and ACTIVE_TEXT or INACTIVE_TEXT }):Play()
                TS:Create(stroke, TweenInfo.new(0.08), { Color = a and ACCENT or STROKE_COLOR, Transparency = 0 }):Play()
            end
            self.Buttons[def.Name] = item
            if states[def.Name] then item:SetActive(true) end

            local getMoved = attachDrag(btn, btn, 6, function() return window.Locked end, function()
                local p = btn.Position
                self.Positions[def.Name] = {
                    xScale = p.X.Scale, xOffset = p.X.Offset, yScale = p.Y.Scale, yOffset = p.Y.Offset,
                    x = p.X.Offset, y = p.Y.Offset,
                }
                if cfg.OnMoved then pcall(cfg.OnMoved, def.Name, self.Positions[def.Name]) end
                window:_changed("float-move")
            end)
            btn.MouseButton1Click:Connect(function()
                if getMoved() > 6 then return end
                if cfg.OnClick then cfg.OnClick(def.Name, item) end
            end)
        end
    end

    function panel:SetScale(percent)
        self.Scale = math.clamp(percent, 50, 200)
        self:Build()
    end
    function panel:SetVisible(on) if self.Gui then self.Gui.Enabled = on end end
    function panel:ResetPositions() self.Positions = {}; self:Build() end
    function panel:Destroy() if self.Gui then self.Gui:Destroy() end end

    panel:Build()
    return panel
end

return Library
