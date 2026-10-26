--[[
    ZENTHRA UI LIBRARY  v1.0
    Dark "script hub" UI: draggable window, sidebar tabs, feature cards
    (lock / title / description / keybind pill / bell / toggle) and a
    settings popup (sliders, toggles, dropdowns, inputs, buttons).

    All icons are drawn with Frames, so no asset ids are needed.

    ------------------------------------------------------------------
    QUICK START
    ------------------------------------------------------------------
    local Library = loadstring(readfile("ZenthraUI.lua"))()

    local Window = Library:CreateWindow({
        Title     = "Zenthra",
        Size      = UDim2.fromOffset(672, 430),
        ToggleKey = Enum.KeyCode.RightShift,
        Accent    = Color3.fromRGB(255, 255, 255),   -- toggle "on" colour
    })

    local Player = Window:AddTab({ Name = "Player", Icon = "user" })

    local Speed = Player:AddFeature({
        Name        = "Speed",
        Description = "changes walk speed",
        Bell        = true,      -- show the bell (notify on toggle)
        Lock        = true,      -- show the lock icon (click = lock card)
        Keybind     = nil,       -- Enum.KeyCode or nil ("None")
        Default     = false,
        Flag        = "Speed",   -- Library.Flags.Speed
        Callback    = function(state) print("Speed", state) end,
    })

    -- the sliders icon in the card footer opens these options:
    Speed:AddSlider({ Name = "Walk Speed", Min = 16, Max = 200, Default = 16,
                      Flag = "SpeedValue", Callback = function(v) end })

    Built-in icon names:
      sword shield eye user users box globe skull settings scan search
      lock bell sliders x chevron
    A "rbxassetid://..." string (or number) also works as an icon.
    Library:RegisterIcon(name, function(ctx) ... end) adds custom icons.
]]

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local Library = {
    Flags   = {},
    Windows = {},
    Version = "1.0.0",
}

------------------------------------------------------------------------
-- THEME (colours measured from the reference screenshot)
------------------------------------------------------------------------
local Theme = {
    Border          = Color3.fromRGB(58, 58, 58),
    Divider         = Color3.fromRGB(30, 30, 30),
    Card            = Color3.fromRGB(24, 24, 24),
    CardStroke      = Color3.fromRGB(37, 37, 37),
    CardStrokeHover = Color3.fromRGB(54, 54, 54),
    CardFooter      = Color3.fromRGB(20, 20, 20),
    FooterLine      = Color3.fromRGB(34, 34, 34),
    Text            = Color3.fromRGB(255, 255, 255),
    SubText         = Color3.fromRGB(108, 108, 108),
    TabIdle         = Color3.fromRGB(128, 128, 128),
    TabHover        = Color3.fromRGB(188, 188, 188),
    Icon            = Color3.fromRGB(105, 105, 105),
    IconHover       = Color3.fromRGB(205, 205, 205),
    Pill            = Color3.fromRGB(66, 66, 66),
    PillText        = Color3.fromRGB(196, 196, 196),
    ToggleOff       = Color3.fromRGB(30, 30, 30),
    ToggleOffStroke = Color3.fromRGB(62, 62, 62),
    KnobOff         = Color3.fromRGB(150, 150, 150),
    Input           = Color3.fromRGB(30, 30, 30),
    Accent          = Color3.fromRGB(255, 255, 255),
}

------------------------------------------------------------------------
-- HELPERS
------------------------------------------------------------------------
local function New(className, props, children)
    local inst = Instance.new(className)
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
        for _, child in ipairs(children) do
            child.Parent = inst
        end
    end
    if parent then
        inst.Parent = parent
    end
    return inst
end

local function Corner(r)
    if typeof(r) == "UDim" then
        return New("UICorner", { CornerRadius = r })
    end
    return New("UICorner", { CornerRadius = UDim.new(0, r) })
end

local function Tween(inst, time, props)
    if not time or time <= 0 then
        for k, v in pairs(props) do
            inst[k] = v
        end
        return
    end
    local tw = TweenService:Create(inst, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local function Safe(fn, ...)
    if type(fn) ~= "function" then return end
    local ok, err = pcall(fn, ...)
    if not ok then
        warn("[ZenthraUI] " .. tostring(err))
    end
end

local function Luminance(c)
    return 0.299 * c.R + 0.587 * c.G + 0.114 * c.B
end

local function KeyName(key)
    if not key then return "None" end
    local n = key.Name
    n = string.gsub(n, "^Left", "L")
    n = string.gsub(n, "^Right", "R")
    n = string.gsub(n, "Control", "Ctrl")
    return n
end

local function GetGuiParent()
    local ok, ui = pcall(function()
        if gethui then return gethui() end
    end)
    if ok and ui then return ui end

    local ok2, core = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and core then
        local probe = Instance.new("ScreenGui")
        local canParent = pcall(function() probe.Parent = core end)
        probe:Destroy()
        if canParent then return core end
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function ProtectGui(gui)
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(gui)
        end
    end)
end

local function MakeDraggable(handle, target, conns)
    local state = { Moved = false }
    local dragging = false
    local startMouse, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            state.Moved = false
            startMouse = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    local c = UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - startMouse
            if d.Magnitude > 4 then
                state.Moved = true
            end
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
    table.insert(conns, c)
    return state
end

------------------------------------------------------------------------
-- ICON ENGINE  (16x16 design grid, drawn with Frames / UIStroke)
------------------------------------------------------------------------
local Ctx = {}
Ctx.__index = Ctx

local function NewCtx(parent, size, color)
    local ctx = setmetatable({
        Parent = parent,
        OX = 0,
        OY = 0,
        S = size / 16,
        Color = color,
        Parts = {},
    }, Ctx)
    ctx.Root = ctx
    return ctx
end

function Ctx:Track(inst, prop)
    table.insert(self.Root.Parts, { inst, prop })
end

function Ctx:Line(x1, y1, x2, y2, t)
    local S = self.S
    t = t or 1.5
    local dx, dy = x2 - x1, y2 - y1
    local len = math.sqrt(dx * dx + dy * dy)
    local f = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(((x1 + x2) / 2 - self.OX) * S, ((y1 + y2) / 2 - self.OY) * S),
        Size = UDim2.fromOffset((len + t) * S, t * S),
        Rotation = math.deg(math.atan2(dy, dx)),
        BackgroundColor3 = self.Root.Color,
        BorderSizePixel = 0,
        Parent = self.Parent,
    }, { New("UICorner", { CornerRadius = UDim.new(0.5, 0) }) })
    self:Track(f, "BackgroundColor3")
end

function Ctx:Poly(points, closed, t)
    for i = 1, #points - 1 do
        self:Line(points[i][1], points[i][2], points[i + 1][1], points[i + 1][2], t)
    end
    if closed then
        local a, b = points[#points], points[1]
        self:Line(a[1], a[2], b[1], b[2], t)
    end
end

function Ctx:Rect(x, y, w, h, r)
    local S = self.S
    local f = New("Frame", {
        Position = UDim2.fromOffset((x - self.OX) * S, (y - self.OY) * S),
        Size = UDim2.fromOffset(w * S, h * S),
        BackgroundColor3 = self.Root.Color,
        BorderSizePixel = 0,
        Parent = self.Parent,
    })
    if r == "full" then
        New("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = f })
    elseif r and r > 0 then
        New("UICorner", { CornerRadius = UDim.new(0, r * S), Parent = f })
    end
    self:Track(f, "BackgroundColor3")
end

function Ctx:Outline(x, y, w, h, r, t)
    local S = self.S
    t = t or 1.5
    local ts = t * S
    local f = New("Frame", {
        Position = UDim2.fromOffset((x - self.OX) * S + ts, (y - self.OY) * S + ts),
        Size = UDim2.fromOffset(math.max(w * S - 2 * ts, 0), math.max(h * S - 2 * ts, 0)),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = self.Parent,
    })
    if r == "full" then
        New("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = f })
    elseif r and r > 0 then
        New("UICorner", { CornerRadius = UDim.new(0, math.max(r - t, 0) * S), Parent = f })
    end
    local stroke = New("UIStroke", {
        Color = self.Root.Color,
        Thickness = ts,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = f,
    })
    self:Track(stroke, "Color")
end

function Ctx:Clip(x, y, w, h)
    local S = self.S
    local f = New("Frame", {
        Position = UDim2.fromOffset((x - self.OX) * S, (y - self.OY) * S),
        Size = UDim2.fromOffset(w * S, h * S),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.Parent,
    })
    return setmetatable({ Parent = f, OX = x, OY = y, S = S, Root = self.Root }, Ctx)
end

local Icons = {}

Icons.search = function(c)
    c:Outline(2, 2, 10, 10, "full", 1.7)
    c:Line(11, 11, 14.2, 14.2, 1.9)
end

Icons.lock = function(c)
    local shackle = c:Clip(4.2, 1, 7.6, 7)
    shackle:Outline(4.2, 1.2, 7.6, 10, "full", 1.6)
    c:Outline(2.6, 7, 10.8, 7.8, 2, 1.6)
end

Icons.bell = function(c)
    local dome = c:Clip(3.2, 1.5, 9.6, 6.5)
    dome:Outline(3.2, 1.5, 9.6, 9.6, "full", 1.6)
    c:Line(3.6, 7.6, 2.4, 11.2, 1.6)
    c:Line(12.4, 7.6, 13.6, 11.2, 1.6)
    c:Line(1.8, 11.6, 14.2, 11.6, 1.6)
    local clapper = c:Clip(6, 12.6, 4, 2.6)
    clapper:Outline(6.2, 10.8, 3.6, 3.6, "full", 1.5)
end

Icons.sliders = function(c)
    c:Line(3.5, 2, 3.5, 14, 1.4)
    c:Line(8, 2, 8, 14, 1.4)
    c:Line(12.5, 2, 12.5, 14, 1.4)
    c:Rect(1.5, 9, 4, 2.2, 1)
    c:Rect(6, 4.5, 4, 2.2, 1)
    c:Rect(10.5, 7.5, 4, 2.2, 1)
end

Icons.sword = function(c)
    c:Line(13.5, 2.5, 5.5, 10.5, 1.7)
    c:Line(3.8, 8.8, 7.2, 12.2, 1.7)
    c:Line(5.5, 10.5, 2.8, 13.2, 1.7)
end

Icons.shield = function(c)
    c:Poly({ { 2.5, 3.2 }, { 8, 1.6 }, { 13.5, 3.2 }, { 13.5, 8 }, { 8, 14.4 }, { 2.5, 8 } }, true, 1.5)
end

Icons.eye = function(c)
    c:Poly({
        { 1.2, 8 }, { 4.4, 4.9 }, { 8, 3.8 }, { 11.6, 4.9 },
        { 14.8, 8 }, { 11.6, 11.1 }, { 8, 12.2 }, { 4.4, 11.1 },
    }, true, 1.5)
    c:Outline(5.9, 5.9, 4.2, 4.2, "full", 1.5)
end

Icons.user = function(c)
    c:Outline(5.2, 1.8, 5.6, 5.6, "full", 1.6)
    local body = c:Clip(2.8, 9.2, 10.4, 6)
    body:Outline(2.8, 9.2, 10.4, 9, 4.6, 1.6)
end

Icons.users = function(c)
    c:Outline(3.4, 2, 5, 5, "full", 1.5)
    local body = c:Clip(1.2, 9, 9.4, 6)
    body:Outline(1.2, 9, 9.4, 9, 4, 1.5)
    c:Outline(9.6, 2.2, 4.4, 4.4, "full", 1.4)
    c:Poly({ { 12, 9.2 }, { 13.8, 10.2 }, { 14.8, 12 }, { 14.8, 14.6 } }, false, 1.4)
end

Icons.box = function(c)
    c:Poly({ { 8, 1.5 }, { 13.8, 4.8 }, { 13.8, 11.2 }, { 8, 14.5 }, { 2.2, 11.2 }, { 2.2, 4.8 } }, true, 1.4)
    c:Poly({ { 2.2, 4.8 }, { 8, 8.1 }, { 13.8, 4.8 } }, false, 1.4)
    c:Line(8, 8.1, 8, 14.5, 1.4)
end

Icons.globe = function(c)
    c:Outline(1.4, 1.4, 13.2, 13.2, "full", 1.5)
    c:Line(1.6, 8, 14.4, 8, 1.4)
    c:Poly({
        { 8, 1.5 }, { 10.6, 4.4 }, { 11.2, 8 }, { 10.6, 11.6 },
        { 8, 14.5 }, { 5.4, 11.6 }, { 4.8, 8 }, { 5.4, 4.4 },
    }, true, 1.3)
end

Icons.skull = function(c)
    c:Outline(2.2, 1.5, 11.6, 10.5, 5, 1.5)
    c:Outline(5.2, 10.5, 5.6, 4, 1.2, 1.4)
    c:Rect(4.9, 6.3, 2, 2.2, 1)
    c:Rect(9.1, 6.3, 2, 2.2, 1)
end

Icons.settings = function(c)
    for i = 0, 7 do
        local a = math.rad(i * 45)
        c:Line(
            8 + math.cos(a) * 4.7, 8 + math.sin(a) * 4.7,
            8 + math.cos(a) * 6.6, 8 + math.sin(a) * 6.6, 2.3
        )
    end
    c:Outline(3.8, 3.8, 8.4, 8.4, "full", 1.5)
    c:Outline(6.3, 6.3, 3.4, 3.4, "full", 1.3)
end

Icons.scan = function(c)
    c:Poly({ { 2, 6 }, { 2, 2 }, { 6, 2 } }, false, 1.6)
    c:Poly({ { 10, 2 }, { 14, 2 }, { 14, 6 } }, false, 1.6)
    c:Poly({ { 14, 10 }, { 14, 14 }, { 10, 14 } }, false, 1.6)
    c:Poly({ { 6, 14 }, { 2, 14 }, { 2, 10 } }, false, 1.6)
end

Icons.x = function(c)
    c:Line(3.5, 3.5, 12.5, 12.5, 1.6)
    c:Line(12.5, 3.5, 3.5, 12.5, 1.6)
end

Icons.chevron = function(c)
    c:Poly({ { 3.5, 6 }, { 8, 10.5 }, { 12.5, 6 } }, false, 1.6)
end

function Library:RegisterIcon(name, builder)
    Icons[string.lower(name)] = builder
end

local function MakeIcon(parent, icon, size, color)
    local holder = New("Frame", {
        Name = "Icon",
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(size, size),
        Parent = parent,
    })
    local obj = { Holder = holder, Parts = {} }

    local isAsset = false
    local assetId
    if type(icon) == "number" then
        isAsset, assetId = true, "rbxassetid://" .. tostring(icon)
    elseif type(icon) == "string" then
        if string.find(icon, "^rbxasset") then
            isAsset, assetId = true, icon
        elseif string.find(icon, "^%d+$") then
            isAsset, assetId = true, "rbxassetid://" .. icon
        end
    end

    if isAsset then
        local img = New("ImageLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Image = assetId,
            ImageColor3 = color,
            Parent = holder,
        })
        obj.Parts = { { img, "ImageColor3" } }
    else
        local builder = type(icon) == "string" and Icons[string.lower(icon)] or nil
        if builder then
            local ctx = NewCtx(holder, size, color)
            builder(ctx)
            obj.Parts = ctx.Parts
        end
    end

    function obj:SetColor(col)
        for _, part in ipairs(self.Parts) do
            part[1][part[2]] = col
        end
    end

    return obj
end

------------------------------------------------------------------------
-- SWITCH (22x12 toggle used by cards and popup options)
------------------------------------------------------------------------
local function MakeSwitch(parent, theme)
    local track = New("Frame", {
        Name = "Switch",
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.fromOffset(20, 10),
        BackgroundColor3 = theme.ToggleOff,
        BorderSizePixel = 0,
        Parent = parent,
    }, { Corner(UDim.new(1, 0)) })
    local stroke = New("UIStroke", { Color = theme.ToggleOffStroke, Thickness = 1, Parent = track })
    local knob = New("Frame", {
        Name = "Knob",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 1, 0.5, 0),
        Size = UDim2.fromOffset(8, 8),
        BackgroundColor3 = theme.KnobOff,
        BorderSizePixel = 0,
        Parent = track,
    }, { Corner(UDim.new(1, 0)) })

    local sw = { Track = track }
    function sw:Set(on, animate)
        local t = animate and 0.16 or 0
        Tween(track, t, { BackgroundColor3 = on and theme.Accent or theme.ToggleOff })
        Tween(stroke, t, { Color = on and theme.Accent or theme.ToggleOffStroke })
        Tween(knob, t, {
            BackgroundColor3 = on and theme.KnobOn or theme.KnobOff,
            Position = on and UDim2.new(1, -9, 0.5, 0) or UDim2.new(0, 1, 0.5, 0),
        })
    end
    return sw
end

------------------------------------------------------------------------
-- NOTIFICATIONS
------------------------------------------------------------------------
local function GetNotifyHolder()
    if Library._holder and Library._holder.Parent then
        return Library._holder
    end
    local g = New("ScreenGui", {
        Name = "ZenthraNotify",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 1001,
    })
    ProtectGui(g)
    g.Parent = GetGuiParent()
    local holder = New("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -16, 1, -16),
        Size = UDim2.new(0, 230, 1, -32),
        BackgroundTransparency = 1,
        Parent = g,
    }, {
        New("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
        }),
    })
    Library._holder = holder
    Library._notifyGui = g
    return holder
end

function Library:Notify(opts)
    opts = opts or {}
    local holder = GetNotifyHolder()
    local toast = New("CanvasGroup", {
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        GroupTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = holder,
    }, {
        Corner(6),
        New("UIStroke", { Color = Theme.CardStroke, Thickness = 1 }),
        New("UIPadding", {
            PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
        }),
        New("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }),
    })
    New("TextLabel", {
        BackgroundTransparency = 1, LayoutOrder = 1,
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        Font = Enum.Font.GothamBold, Text = tostring(opts.Title or "Zenthra"),
        TextSize = 11, TextColor3 = Theme.Text, TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = toast,
    })
    if opts.Content and opts.Content ~= "" then
        New("TextLabel", {
            BackgroundTransparency = 1, LayoutOrder = 2,
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            Font = Enum.Font.Gotham, Text = tostring(opts.Content),
            TextSize = 10, TextColor3 = Color3.fromRGB(150, 150, 150), TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = toast,
        })
    end
    Tween(toast, 0.2, { GroupTransparency = 0 })
    task.delay(opts.Duration or 3, function()
        if toast and toast.Parent then
            Tween(toast, 0.25, { GroupTransparency = 1 })
            task.wait(0.3)
            toast:Destroy()
        end
    end)
end

------------------------------------------------------------------------
-- CLASSES
------------------------------------------------------------------------
local WindowClass = {}
WindowClass.__index = WindowClass

local TabClass = {}
TabClass.__index = TabClass

local FeatureClass = {}
FeatureClass.__index = FeatureClass

local function MakePage(parent, cellW, cellH)
    return New("ScrollingFrame", {
        Name = "Page",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Color3.fromRGB(70, 70, 70),
        VerticalScrollBarInset = Enum.ScrollBarInset.None,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Visible = false,
        Parent = parent,
    }, {
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 28), PaddingRight = UDim.new(0, 42),
            PaddingTop = UDim.new(0, 22), PaddingBottom = UDim.new(0, 22),
        }),
        New("UIGridLayout", {
            CellSize = UDim2.fromOffset(cellW, cellH),
            CellPadding = UDim2.fromOffset(41, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Top,
        }),
    })
end

------------------------------------------------------------------------
-- WINDOW
------------------------------------------------------------------------
function Library:CreateWindow(config)
    config = config or {}

    local theme = {}
    for k, v in pairs(Theme) do theme[k] = v end
    if config.Accent then theme.Accent = config.Accent end
    theme.KnobOn = (Luminance(theme.Accent) > 0.6) and Color3.fromRGB(17, 17, 17) or Color3.fromRGB(255, 255, 255)

    local size = config.Size or UDim2.fromOffset(672, 430)
    local W, H = size.X.Offset, size.Y.Offset
    local TITLE_H, SIDE_W = 48, 137
    local CARD_H = 84
    local cellW = math.floor((W - SIDE_W - 28 - 42 - 41) / 2)
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightShift
    local title = config.Title or "Zenthra"

    local window = setmetatable({
        Theme = theme,
        Tabs = {},
        Features = {},
        CellW = cellW,
        CellH = CARD_H,
        W = W,
        H = H,
        Searching = false,
        _order = 0,
        _conns = {},
    }, WindowClass)
    table.insert(Library.Windows, window)

    -- ScreenGui -------------------------------------------------------
    local gui = New("ScreenGui", {
        Name = "ZenthraUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 1000,
    })
    ProtectGui(gui)
    gui.Parent = GetGuiParent()

    local root = New("Frame", {
        Name = "Root",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = size,
        BackgroundTransparency = 1,
        Parent = gui,
    })

    New("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 47, 1, 47),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.45,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = 0,
        Parent = root,
    })

    local main = New("Frame", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(W, H),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = root,
    }, {
        Corner(10),
        New("UIStroke", { Color = theme.Border, Transparency = 0.45, Thickness = 1 }),
        New("UIGradient", {
            Rotation = 90,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(46, 46, 46)),
                ColorSequenceKeypoint.new(0.2, Color3.fromRGB(21, 21, 21)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 16, 16)),
            }),
        }),
    })
    local uiScale = New("UIScale", { Scale = 1, Parent = main })

    window.Gui, window.Root, window.Main, window.UIScale = gui, root, main, uiScale

    local function updateScale()
        local cam = workspace.CurrentCamera
        if not cam then return end
        local vp = cam.ViewportSize
        local s = math.min(1, (vp.X * 0.96) / W, (vp.Y * 0.92) / H)
        uiScale.Scale = s
        root.Size = UDim2.fromOffset(W * s, H * s)
    end
    updateScale()
    if workspace.CurrentCamera then
        table.insert(window._conns, workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale))
    end

    -- Title bar -------------------------------------------------------
    local titleBar = New("Frame", {
        Name = "TitleBar",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = main,
    })

    local logo = MakeIcon(titleBar, "scan", 17, theme.Text)
    logo.Holder.Position = UDim2.fromOffset(17, 12)

    New("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(39, 12),
        Size = UDim2.fromOffset(220, 16),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextSize = 13,
        TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = titleBar,
    })

    local searchIcon = MakeIcon(titleBar, "search", 13, Color3.fromRGB(160, 160, 160))
    searchIcon.Holder.AnchorPoint = Vector2.new(0.5, 0.5)
    searchIcon.Holder.Position = UDim2.fromOffset(W - 27, 21)

    local searchBtn = New("TextButton", {
        Name = "SearchButton",
        BackgroundTransparency = 1,
        Text = "",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(W - 27, 21),
        Size = UDim2.fromOffset(26, 26),
        Parent = titleBar,
    })

    local searchFrame = New("Frame", {
        Name = "SearchBox",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.fromOffset(W - 46, 21),
        Size = UDim2.fromOffset(0, 24),
        BackgroundColor3 = theme.Input,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
        Parent = titleBar,
    }, {
        Corner(6),
        New("UIStroke", { Color = theme.CardStroke, Thickness = 1 }),
    })
    local searchBox = New("TextBox", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -20, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "",
        PlaceholderText = "Search features...",
        PlaceholderColor3 = Color3.fromRGB(95, 95, 95),
        TextColor3 = theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = searchFrame,
    })
    window.SearchBox = searchBox

    local searchOpen = false
    local function setSearch(open)
        searchOpen = open
        if open then
            searchFrame.Visible = true
            Tween(searchFrame, 0.2, { Size = UDim2.fromOffset(170, 24) })
            searchIcon:SetColor(theme.Text)
            task.defer(function() searchBox:CaptureFocus() end)
        else
            searchBox.Text = ""
            searchBox:ReleaseFocus()
            Tween(searchFrame, 0.2, { Size = UDim2.fromOffset(0, 24) })
            searchIcon:SetColor(Color3.fromRGB(160, 160, 160))
            task.delay(0.22, function()
                if not searchOpen then searchFrame.Visible = false end
            end)
        end
    end
    searchBtn.Activated:Connect(function() setSearch(not searchOpen) end)
    searchBtn.MouseEnter:Connect(function()
        if not searchOpen then searchIcon:SetColor(theme.Text) end
    end)
    searchBtn.MouseLeave:Connect(function()
        if not searchOpen then searchIcon:SetColor(Color3.fromRGB(160, 160, 160)) end
    end)
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        window:_search(searchBox.Text)
    end)

    MakeDraggable(titleBar, root, window._conns)

    -- Sidebar ---------------------------------------------------------
    window.Sidebar = New("ScrollingFrame", {
        Name = "Sidebar",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, TITLE_H),
        Size = UDim2.fromOffset(SIDE_W, H - TITLE_H - 8),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Parent = main,
    }, {
        New("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
    })

    New("Frame", {
        Name = "Divider",
        BackgroundColor3 = theme.Divider,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(SIDE_W, 44),
        Size = UDim2.fromOffset(1, H - 44 - 12),
        Parent = main,
    })

    -- Pages -----------------------------------------------------------
    window.Pages = New("Frame", {
        Name = "Pages",
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Position = UDim2.fromOffset(SIDE_W + 1, TITLE_H),
        Size = UDim2.fromOffset(W - SIDE_W - 1, H - TITLE_H - 6),
        Parent = main,
    })
    window.SearchPage = MakePage(window.Pages, cellW, CARD_H)

    -- Popup overlay ---------------------------------------------------
    window.Overlay = New("Frame", {
        Name = "Overlay",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Visible = false,
        ZIndex = 30,
        Parent = main,
    })
    local blocker = New("TextButton", {
        Name = "Blocker",
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 1,
        Parent = window.Overlay,
    })
    blocker.Activated:Connect(function() window:_closePopup() end)

    -- Input (toggle key, keybinds) ------------------------------------
    table.insert(window._conns, UserInputService.InputBegan:Connect(function(input, gp)
        if Library._listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local f = Library._listening
                Library._listening = nil
                if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
                    f:SetKeybind(nil)
                else
                    f:SetKeybind(input.KeyCode)
                end
            end
            return
        end
        if gp then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if input.KeyCode == toggleKey then
            window:Toggle()
            return
        end
        for _, f in ipairs(window.Features) do
            if f.Key and input.KeyCode == f.Key and not f.Locked then
                f:Set(not f.State)
            end
        end
    end))

    -- Mobile toggle button -------------------------------------------
    if config.MobileButton ~= false and UserInputService.TouchEnabled then
        local mb = New("TextButton", {
            Name = "MobileToggle",
            Text = "",
            AutoButtonColor = false,
            Position = UDim2.new(0, 14, 0.5, -20),
            Size = UDim2.fromOffset(40, 40),
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            BorderSizePixel = 0,
            Parent = gui,
        }, {
            Corner(UDim.new(1, 0)),
            New("UIStroke", { Color = theme.Border, Transparency = 0.4, Thickness = 1 }),
        })
        local mi = MakeIcon(mb, "scan", 18, theme.Text)
        mi.Holder.AnchorPoint = Vector2.new(0.5, 0.5)
        mi.Holder.Position = UDim2.fromScale(0.5, 0.5)
        local st = MakeDraggable(mb, mb, window._conns)
        mb.Activated:Connect(function()
            if not st.Moved then window:Toggle() end
        end)
    end

    return window
end

------------------------------------------------------------------------
-- WINDOW METHODS
------------------------------------------------------------------------
function WindowClass:AddTab(cfg)
    cfg = cfg or {}
    local theme = self.Theme
    local tab = setmetatable({
        Window = self,
        Name = cfg.Name or "Tab",
        Features = {},
    }, TabClass)
    table.insert(self.Tabs, tab)

    local btn = New("Frame", {
        Name = tab.Name,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 34),
        LayoutOrder = #self.Tabs,
        Parent = self.Sidebar,
    })

    tab.Indicator = New("Frame", {
        Name = "Indicator",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 12, 0.5, 0),
        Size = UDim2.fromOffset(2, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = btn,
    }, { Corner(UDim.new(1, 0)) })

    tab.Icon = MakeIcon(btn, cfg.Icon, 12, theme.TabIdle)
    tab.Icon.Holder.AnchorPoint = Vector2.new(0.5, 0.5)
    tab.Icon.Holder.Position = UDim2.new(0, 27, 0.5, 0)

    tab.Label = New("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(38, 0),
        Size = UDim2.new(1, -44, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = tab.Name,
        TextSize = 11,
        TextColor3 = theme.TabIdle,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = btn,
    })

    local hit = New("TextButton", {
        Name = "Hit",
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.fromScale(1, 1),
        Parent = btn,
    })
    hit.MouseEnter:Connect(function()
        if self.CurrentTab ~= tab then
            Tween(tab.Label, 0.12, { TextColor3 = theme.TabHover })
            tab.Icon:SetColor(theme.TabHover)
        end
    end)
    hit.MouseLeave:Connect(function()
        if self.CurrentTab ~= tab then
            Tween(tab.Label, 0.12, { TextColor3 = theme.TabIdle })
            tab.Icon:SetColor(theme.TabIdle)
        end
    end)
    hit.Activated:Connect(function() self:SelectTab(tab) end)

    tab.Page = MakePage(self.Pages, self.CellW, self.CellH)

    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    return tab
end

function WindowClass:SelectTab(tab)
    if type(tab) == "string" then
        for _, t in ipairs(self.Tabs) do
            if t.Name == tab then tab = t break end
        end
    end
    if type(tab) ~= "table" then return end

    self:_closePopup()
    if self.Searching then
        self.SearchBox.Text = ""
    end
    self.CurrentTab = tab

    local theme = self.Theme
    for _, t in ipairs(self.Tabs) do
        local active = (t == tab)
        t.Page.Visible = active and not self.Searching
        Tween(t.Indicator, 0.18, { Size = UDim2.fromOffset(2, active and 20 or 0) })
        Tween(t.Label, 0.18, { TextColor3 = active and theme.Text or theme.TabIdle })
        t.Label.Font = active and Enum.Font.GothamBold or Enum.Font.GothamMedium
        t.Icon:SetColor(active and theme.Text or theme.TabIdle)
    end
end

function WindowClass:_search(text)
    text = string.lower(text or "")
    if text == "" then
        if self.Searching then
            self.Searching = false
            self.SearchPage.Visible = false
            for _, f in ipairs(self.Features) do
                f.Card.Parent = f.Tab.Page
                f.Card.Visible = true
            end
            if self.CurrentTab then
                self.CurrentTab.Page.Visible = true
            end
        end
        return
    end

    self:_closePopup()
    self.Searching = true
    for _, t in ipairs(self.Tabs) do
        t.Page.Visible = false
    end
    self.SearchPage.Visible = true
    for _, f in ipairs(self.Features) do
        if f.Card.Parent ~= self.SearchPage then
            f.Card.Parent = self.SearchPage
        end
        local hay = string.lower(f.Name .. " " .. f.Description)
        f.Card.Visible = string.find(hay, text, 1, true) ~= nil
    end
end

function WindowClass:_openPopup(feature)
    if not feature.Popup or #feature.Elements == 0 then return end
    self:_closePopup()

    local popup = feature.Popup
    local s = self.UIScale.Scale
    local mainPos = self.Main.AbsolutePosition
    local cardPos = feature.Card.AbsolutePosition
    local x = (cardPos.X - mainPos.X) / s
    local cardY = (cardPos.Y - mainPos.Y) / s
    local y = cardY + self.CellH + 6

    popup.Position = UDim2.fromOffset(x, y)
    popup.Visible = true
    self.Overlay.Visible = true
    self.OpenPopup = feature

    task.spawn(function()
        RunService.Heartbeat:Wait()
        if self.OpenPopup ~= feature then return end
        local h = popup.AbsoluteSize.Y / s
        if y + h > self.H - 8 then
            popup.Position = UDim2.fromOffset(x, math.max(8, cardY - 6 - h))
        end
    end)
end

function WindowClass:_closePopup()
    if self.OpenPopup then
        if self.OpenPopup.Popup then
            self.OpenPopup.Popup.Visible = false
        end
        self.OpenPopup = nil
    end
    self.Overlay.Visible = false
end

function WindowClass:SetVisible(visible)
    self.Root.Visible = visible and true or false
    if not visible then self:_closePopup() end
end

function WindowClass:Toggle()
    self:SetVisible(not self.Root.Visible)
end

function WindowClass:Notify(opts)
    Library:Notify(opts)
end

function WindowClass:Destroy()
    for _, c in ipairs(self._conns) do
        pcall(function() c:Disconnect() end)
    end
    self._conns = {}
    if self.Gui then self.Gui:Destroy() end
end

function Library:Unload()
    for _, w in ipairs(self.Windows) do
        pcall(function() w:Destroy() end)
    end
    self.Windows = {}
    if self._notifyGui then
        self._notifyGui:Destroy()
        self._notifyGui, self._holder = nil, nil
    end
end

------------------------------------------------------------------------
-- FEATURE CARD
------------------------------------------------------------------------
function TabClass:AddFeature(cfg)
    cfg = cfg or {}
    local window = self.Window
    local theme = window.Theme

    local feature = setmetatable({
        Tab = self,
        Window = window,
        Name = cfg.Name or "Feature",
        Description = cfg.Description or "",
        State = false,
        Locked = cfg.Locked == true,
        NotifyEnabled = cfg.Notify == true,
        Key = nil,
        Flag = cfg.Flag,
        Callback = cfg.Callback,
        Elements = {},
        _order = 0,
    }, FeatureClass)

    table.insert(self.Features, feature)
    table.insert(window.Features, feature)
    window._order = window._order + 1

    local showBell = cfg.Bell ~= false
    local showLock = cfg.Lock ~= false

    -- Card ------------------------------------------------------------
    local card = New("Frame", {
        Name = feature.Name,
        BackgroundColor3 = theme.Card,
        BorderSizePixel = 0,
        LayoutOrder = window._order,
        Parent = self.Page,
    }, {
        Corner(6),
    })
    local cardStroke = New("UIStroke", { Color = theme.CardStroke, Thickness = 1, Parent = card })
    feature.Card = card

    feature.TitleLabel = New("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(15, 13),
        Size = UDim2.new(1, -52, 0, 14),
        Font = Enum.Font.GothamBold,
        Text = feature.Name,
        TextSize = 11,
        TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = card,
    })
    feature.DescLabel = New("TextLabel", {
        Name = "Description",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(15, 31),
        Size = UDim2.new(1, -52, 0, 10),
        Font = Enum.Font.Gotham,
        Text = feature.Description,
        TextSize = 8,
        TextColor3 = theme.SubText,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = card,
    })

    -- Lock icon (top right)
    feature.LockIcon = MakeIcon(card, "lock", 10, theme.Icon)
    feature.LockIcon.Holder.AnchorPoint = Vector2.new(0.5, 0.5)
    feature.LockIcon.Holder.Position = UDim2.new(1, -16, 0, 18)
    feature.LockIcon.Holder.Visible = showLock
    local lockBtn = New("TextButton", {
        Name = "LockButton",
        BackgroundTransparency = 1,
        Text = "",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, -16, 0, 18),
        Size = UDim2.fromOffset(18, 18),
        Visible = showLock,
        Parent = card,
    })

    -- Footer ----------------------------------------------------------
    local footer = New("Frame", {
        Name = "Footer",
        BackgroundColor3 = theme.CardFooter,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 53),
        Size = UDim2.new(1, 0, 0, 31),
        Parent = card,
    }, { Corner(6) })
    New("Frame", {
        Name = "FooterSquare",
        BackgroundColor3 = theme.CardFooter,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 10),
        Parent = footer,
    })
    New("Frame", {
        Name = "FooterLine",
        BackgroundColor3 = theme.FooterLine,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = 2,
        Parent = footer,
    })

    -- Sliders (options) icon
    feature.OptionsIcon = MakeIcon(footer, "sliders", 11, theme.Icon)
    feature.OptionsIcon.Holder.AnchorPoint = Vector2.new(0.5, 0.5)
    feature.OptionsIcon.Holder.Position = UDim2.new(0, 22, 0.5, 1)
    local optBtn = New("TextButton", {
        Name = "OptionsButton",
        BackgroundTransparency = 1,
        Text = "",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 22, 0.5, 1),
        Size = UDim2.fromOffset(18, 20),
        Parent = footer,
    })

    -- Keybind pill
    feature.Pill = New("TextButton", {
        Name = "Keybind",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 32, 0.5, 1),
        Size = UDim2.fromOffset(0, 14),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = theme.Pill,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.GothamMedium,
        Text = "None",
        TextSize = 8,
        TextColor3 = theme.PillText,
        Parent = footer,
    }, {
        Corner(4),
        New("UIPadding", { PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 7) }),
    })

    -- Bell
    feature.BellIcon = MakeIcon(footer, "bell", 11, theme.Icon)
    feature.BellIcon.Holder.AnchorPoint = Vector2.new(0.5, 0.5)
    feature.BellIcon.Holder.Position = UDim2.new(0, 160, 0.5, 1)
    feature.BellIcon.Holder.Visible = showBell
    local bellBtn = New("TextButton", {
        Name = "BellButton",
        BackgroundTransparency = 1,
        Text = "",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 160, 0.5, 1),
        Size = UDim2.fromOffset(18, 20),
        Visible = showBell,
        Parent = footer,
    })

    -- Toggle switch
    feature.Switch = MakeSwitch(footer, theme)
    feature.Switch.Track.Position = UDim2.new(0, 176, 0.5, 1)
    local switchBtn = New("TextButton", {
        Name = "ToggleButton",
        BackgroundTransparency = 1,
        Text = "",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 168, 0.5, 1),
        Size = UDim2.fromOffset(38, 22),
        Parent = footer,
    })

    -- Interactions ----------------------------------------------------
    card.MouseEnter:Connect(function()
        Tween(cardStroke, 0.12, { Color = theme.CardStrokeHover })
    end)
    card.MouseLeave:Connect(function()
        Tween(cardStroke, 0.12, { Color = theme.CardStroke })
    end)

    local function hoverIcon(button, icon, isActive)
        button.MouseEnter:Connect(function()
            if not isActive() then icon:SetColor(theme.IconHover) end
        end)
        button.MouseLeave:Connect(function()
            if not isActive() then icon:SetColor(theme.Icon) end
        end)
    end
    hoverIcon(lockBtn, feature.LockIcon, function() return feature.Locked end)
    hoverIcon(bellBtn, feature.BellIcon, function() return feature.NotifyEnabled end)
    hoverIcon(optBtn, feature.OptionsIcon, function() return false end)

    switchBtn.Activated:Connect(function()
        if feature.Locked then return end
        feature:Set(not feature.State)
    end)
    lockBtn.Activated:Connect(function()
        feature:SetLocked(not feature.Locked)
    end)
    bellBtn.Activated:Connect(function()
        feature:SetNotify(not feature.NotifyEnabled)
    end)
    optBtn.Activated:Connect(function()
        if window.OpenPopup == feature then
            window:_closePopup()
        else
            window:_openPopup(feature)
        end
    end)
    feature.Pill.Activated:Connect(function()
        if feature.Locked then return end
        if Library._listening == feature then
            Library._listening = nil
            feature.Pill.Text = KeyName(feature.Key)
            return
        end
        if Library._listening then
            Library._listening.Pill.Text = KeyName(Library._listening.Key)
        end
        Library._listening = feature
        feature.Pill.Text = "..."
    end)

    -- Initial state ---------------------------------------------------
    feature:_refreshLock()
    feature:_refreshBell()
    if cfg.Keybind then
        feature:SetKeybind(cfg.Keybind)
    end
    if cfg.Default then
        feature:Set(true)
    elseif feature.Flag then
        Library.Flags[feature.Flag] = false
    end

    return feature
end

------------------------------------------------------------------------
-- FEATURE METHODS
------------------------------------------------------------------------
function FeatureClass:Set(state, silent)
    state = state and true or false
    if self.State == state and self._init then return end
    self._init = true
    self.State = state
    self.Switch:Set(state, true)
    if self.Flag then
        Library.Flags[self.Flag] = state
    end
    if not silent then
        Safe(self.Callback, state)
        if self.NotifyEnabled then
            Library:Notify({
                Title = self.Name,
                Content = state and "Enabled" or "Disabled",
                Duration = 2,
            })
        end
    end
end

function FeatureClass:Get()
    return self.State
end

function FeatureClass:SetKeybind(key)
    self.Key = key
    self.Pill.Text = KeyName(key)
end

function FeatureClass:SetLocked(locked)
    self.Locked = locked and true or false
    self:_refreshLock()
end

function FeatureClass:SetNotify(on)
    self.NotifyEnabled = on and true or false
    self:_refreshBell()
end

function FeatureClass:SetName(text)
    self.Name = text
    self.TitleLabel.Text = text
end

function FeatureClass:SetDescription(text)
    self.Description = text
    self.DescLabel.Text = text
end

function FeatureClass:_refreshLock()
    local theme = self.Window.Theme
    self.LockIcon:SetColor(self.Locked and theme.Text or theme.Icon)
    self.TitleLabel.TextTransparency = self.Locked and 0.4 or 0
    self.Switch.Track.BackgroundTransparency = self.Locked and 0.5 or 0
end

function FeatureClass:_refreshBell()
    local theme = self.Window.Theme
    self.BellIcon:SetColor(self.NotifyEnabled and theme.Text or theme.Icon)
end

function FeatureClass:Destroy()
    if self.Window.OpenPopup == self then self.Window:_closePopup() end
    if self.Popup then self.Popup:Destroy() end
    self.Card:Destroy()
    for i, f in ipairs(self.Window.Features) do
        if f == self then table.remove(self.Window.Features, i) break end
    end
    for i, f in ipairs(self.Tab.Features) do
        if f == self then table.remove(self.Tab.Features, i) break end
    end
end

------------------------------------------------------------------------
-- FEATURE OPTIONS POPUP (opened by the sliders icon)
------------------------------------------------------------------------
function FeatureClass:_ensurePopup()
    if self.Popup then return self.Popup end
    local window = self.Window
    local theme = window.Theme

    local popup = New("Frame", {
        Name = self.Name .. "_Options",
        BackgroundColor3 = theme.Card,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 2,
        Size = UDim2.fromOffset(window.CellW, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = window.Overlay,
    }, {
        Corner(6),
        New("UIStroke", { Color = theme.CardStroke, Thickness = 1 }),
        New("UIPadding", {
            PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
        }),
        New("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
    })
    New("TextLabel", {
        Name = "Header",
        BackgroundTransparency = 1,
        LayoutOrder = 0,
        Size = UDim2.new(1, 0, 0, 14),
        Font = Enum.Font.GothamBold,
        Text = self.Name,
        TextSize = 11,
        TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = popup,
    })
    self.Popup = popup
    return popup
end

local function NextOrder(feature)
    feature._order = feature._order + 1
    return feature._order
end

local function OptionRow(feature, height)
    local popup = feature:_ensurePopup()
    return New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, height),
        LayoutOrder = NextOrder(feature),
        Parent = popup,
    })
end

local function OptionLabel(parent, text, props)
    local p = {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = text,
        TextSize = 10,
        TextColor3 = Color3.fromRGB(170, 170, 170),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = parent,
    }
    for k, v in pairs(props or {}) do p[k] = v end
    return New("TextLabel", p)
end

function FeatureClass:AddSlider(cfg)
    cfg = cfg or {}
    local window = self.Window
    local theme = window.Theme
    local row = OptionRow(self, 30)

    local min, max, inc = cfg.Min or 0, cfg.Max or 100, cfg.Increment or 1
    local suffix = cfg.Suffix or ""
    local value = min

    OptionLabel(row, cfg.Name or "Slider", { Size = UDim2.new(1, -60, 0, 12) })
    local valueLabel = OptionLabel(row, "", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.fromOffset(60, 12),
        Font = Enum.Font.Gotham,
        TextColor3 = Color3.fromRGB(125, 125, 125),
        TextXAlignment = Enum.TextXAlignment.Right,
    })

    local track = New("Frame", {
        Position = UDim2.fromOffset(0, 20),
        Size = UDim2.new(1, 0, 0, 4),
        BackgroundColor3 = theme.ToggleOff,
        BorderSizePixel = 0,
        Parent = row,
    }, { Corner(UDim.new(1, 0)) })
    local fill = New("Frame", {
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0,
        Parent = track,
    }, { Corner(UDim.new(1, 0)) })
    New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(1, 0.5),
        Size = UDim2.fromOffset(8, 8),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = fill,
    }, { Corner(UDim.new(1, 0)) })
    local hit = New("TextButton", {
        BackgroundTransparency = 1,
        Text = "",
        Position = UDim2.fromOffset(0, 12),
        Size = UDim2.new(1, 0, 0, 18),
        Parent = row,
    })

    local obj = {}
    local function apply(v, silent)
        v = math.floor((v - min) / inc + 0.5) * inc + min
        v = math.clamp(v, min, max)
        v = tonumber(string.format("%.4f", v))
        value = v
        local alpha = (max > min) and ((v - min) / (max - min)) or 0
        fill.Size = UDim2.fromScale(alpha, 1)
        valueLabel.Text = tostring(v) .. suffix
        if cfg.Flag then Library.Flags[cfg.Flag] = v end
        if not silent then Safe(cfg.Callback, v) end
    end
    function obj:Set(v, silent) apply(v, silent) end
    function obj:Get() return value end

    local dragging = false
    local function fromInput(input)
        local rel = (input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1)
        apply(min + (max - min) * math.clamp(rel, 0, 1))
    end
    hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            fromInput(input)
        end
    end)
    table.insert(window._conns, UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            fromInput(input)
        end
    end))
    table.insert(window._conns, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))

    apply(cfg.Default or min, true)
    table.insert(self.Elements, obj)
    return obj
end

function FeatureClass:AddToggle(cfg)
    cfg = cfg or {}
    local window = self.Window
    local theme = window.Theme
    local row = OptionRow(self, 18)

    OptionLabel(row, cfg.Name or "Toggle", {
        Size = UDim2.new(1, -34, 1, 0),
        TextYAlignment = Enum.TextYAlignment.Center,
    })
    local sw = MakeSwitch(row, theme)
    sw.Track.AnchorPoint = Vector2.new(1, 0.5)
    sw.Track.Position = UDim2.new(1, -1, 0.5, 0)
    local hit = New("TextButton", {
        BackgroundTransparency = 1, Text = "", Size = UDim2.fromScale(1, 1), Parent = row,
    })

    local obj = {}
    local value = false
    local function apply(v, silent)
        value = v and true or false
        sw:Set(value, true)
        if cfg.Flag then Library.Flags[cfg.Flag] = value end
        if not silent then Safe(cfg.Callback, value) end
    end
    function obj:Set(v, silent) apply(v, silent) end
    function obj:Get() return value end
    hit.Activated:Connect(function() apply(not value) end)

    apply(cfg.Default == true, true)
    table.insert(self.Elements, obj)
    return obj
end

function FeatureClass:AddDropdown(cfg)
    cfg = cfg or {}
    local window = self.Window
    local theme = window.Theme
    local popup = self:_ensurePopup()
    local values = cfg.Values or {}
    local current = cfg.Default or values[1]

    local holder = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = NextOrder(self),
        Parent = popup,
    }, {
        New("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
    })
    local head = New("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = 1, Parent = holder,
    })
    OptionLabel(head, cfg.Name or "Dropdown", { Size = UDim2.new(1, -118, 1, 0) })
    local button = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(110, 20),
        BackgroundColor3 = theme.Input,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.Gotham,
        Text = tostring(current or "None"),
        TextSize = 10,
        TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = head,
    }, {
        Corner(4),
        New("UIStroke", { Color = theme.CardStroke, Thickness = 1 }),
        New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 20) }),
    })
    local chev = MakeIcon(button, "chevron", 9, theme.SubText)
    chev.Holder.AnchorPoint = Vector2.new(1, 0.5)
    chev.Holder.Position = UDim2.new(1, 16, 0.5, 0)

    local list = New("Frame", {
        BackgroundColor3 = theme.Input,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = false,
        LayoutOrder = 2,
        Parent = holder,
    }, {
        Corner(4),
        New("UIStroke", { Color = theme.CardStroke, Thickness = 1 }),
        New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
    })

    local obj = {}
    local items = {}
    local function apply(v, silent)
        current = v
        button.Text = tostring(v)
        for name, b in pairs(items) do
            b.TextColor3 = (name == v) and theme.Text or Color3.fromRGB(135, 135, 135)
        end
        if cfg.Flag then Library.Flags[cfg.Flag] = v end
        if not silent then Safe(cfg.Callback, v) end
    end
    for i, v in ipairs(values) do
        local b = New("TextButton", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            LayoutOrder = i,
            Font = Enum.Font.Gotham,
            Text = tostring(v),
            TextSize = 10,
            TextColor3 = Color3.fromRGB(135, 135, 135),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = list,
        }, { New("UIPadding", { PaddingLeft = UDim.new(0, 8) }) })
        items[v] = b
        b.Activated:Connect(function()
            apply(v)
            list.Visible = false
        end)
    end
    button.Activated:Connect(function() list.Visible = not list.Visible end)

    function obj:Set(v, silent) apply(v, silent) end
    function obj:Get() return current end

    apply(current, true)
    table.insert(self.Elements, obj)
    return obj
end

function FeatureClass:AddInput(cfg)
    cfg = cfg or {}
    local window = self.Window
    local theme = window.Theme
    local row = OptionRow(self, 22)

    OptionLabel(row, cfg.Name or "Input", { Size = UDim2.new(1, -106, 1, 0) })
    local box = New("TextBox", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(100, 20),
        BackgroundColor3 = theme.Input,
        BorderSizePixel = 0,
        Font = Enum.Font.Gotham,
        Text = cfg.Default or "",
        PlaceholderText = cfg.Placeholder or "",
        PlaceholderColor3 = Color3.fromRGB(95, 95, 95),
        TextColor3 = theme.Text,
        TextSize = 10,
        ClearTextOnFocus = false,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = row,
    }, {
        Corner(4),
        New("UIStroke", { Color = theme.CardStroke, Thickness = 1 }),
        New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }),
    })

    local obj = {}
    function obj:Set(v) box.Text = tostring(v) end
    function obj:Get() return box.Text end
    box.FocusLost:Connect(function()
        if cfg.Flag then Library.Flags[cfg.Flag] = box.Text end
        Safe(cfg.Callback, box.Text)
    end)
    if cfg.Flag then Library.Flags[cfg.Flag] = box.Text end

    table.insert(self.Elements, obj)
    return obj
end

function FeatureClass:AddButton(cfg)
    cfg = cfg or {}
    local window = self.Window
    local theme = window.Theme
    local row = OptionRow(self, 24)

    local button = New("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(34, 34, 34),
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.GothamMedium,
        Text = cfg.Name or "Button",
        TextSize = 10,
        TextColor3 = theme.Text,
        Parent = row,
    }, {
        Corner(4),
        New("UIStroke", { Color = theme.CardStroke, Thickness = 1 }),
    })
    button.MouseEnter:Connect(function() Tween(button, 0.1, { BackgroundColor3 = Color3.fromRGB(44, 44, 44) }) end)
    button.MouseLeave:Connect(function() Tween(button, 0.1, { BackgroundColor3 = Color3.fromRGB(34, 34, 34) }) end)
    button.Activated:Connect(function() Safe(cfg.Callback) end)

    local obj = {}
    function obj:SetText(t) button.Text = t end
    table.insert(self.Elements, obj)
    return obj
end

function FeatureClass:AddLabel(text)
    local row = OptionRow(self, 14)
    local label = OptionLabel(row, text or "", {
        Size = UDim2.fromScale(1, 1),
        Font = Enum.Font.Gotham,
        TextColor3 = Color3.fromRGB(125, 125, 125),
    })
    local obj = {}
    function obj:SetText(t) label.Text = t end
    table.insert(self.Elements, obj)
    return obj
end

return Library
