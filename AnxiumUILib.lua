--[[
    ╔══════════════════════════════════════════════════════════════════╗
    ║  AnxiumUILib  -  UI Library extracted from the Anxium script      ║
    ║  Look & animations are a 1:1 port of the original menu            ║
    ╚══════════════════════════════════════════════════════════════════╝

    local Library = loadstring(readfile("AnxiumUILib.lua"))()

    local Window = Library:CreateWindow({ Title = "ANXIUM", Version = "27092026" })
    local Visuals = Window:AddTab("Visuals")
    local Esp = Visuals:AddSection("ESP")
    Esp:AddToggle("2D Box ESP", { Color = Color3.fromRGB(160,120,255), Callback = function(v) end })
    Esp:AddSlider("Fill Rot Speed", { Min = 0.1, Max = 10, Default = 2, Callback = function(v) end })
    Esp:AddDropdown("Box Style", { Values = {"Full","Corner","Box3D"}, Default = "Full", Callback = function(v) end })

    (full API reference is at the bottom of this file / in example.lua)
]]

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local RunService       = game:GetService("RunService")
local Lighting         = game:GetService("Lighting")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════════════
--  Library table / theme (values copied from the original script)
-- ════════════════════════════════════════════════════════════════════
local Library = {
    Name           = "Anxium",
    GuiName        = "AnxiumGui",
    Flags          = {},      -- Flags[flag] = current value
    Options        = {},      -- Options[flag] = element object (:Get / :Set)
    Features       = {},      -- ordered list of toggles (used by Active / Binds HUD)
    Keybinds       = {},      -- Keybinds[flag] = "KeyName"
    NotifyOnToggle = true,    -- "<name> enabled / disabled" notifications like the original
    NotifyOnColor  = true,    -- "<name> color set" notification like the original
    MenuOpen       = false,
    MenuKey        = "Insert",
    Font           = Enum.Font.GothamBold,
    FontId         = "GothamBold",
    Tabs           = {},      -- Tabs[name] = Tab object
    _conns         = {},
    _tracked       = {},
    _sliderFills   = {},
    _sectionLabels = {},
    _toggles       = {},
    _bindRows      = {},
    _tabButtons    = {},
    _tabFrames     = {},
    CurrentTab     = nil,
}

local Theme = {
    Bg          = Color3.fromRGB(15, 17, 22),
    BgSecondary = Color3.fromRGB(20, 22, 28),
    BgTertiary  = Color3.fromRGB(28, 31, 40),
    Sidebar     = Color3.fromRGB(12, 14, 18),
    Card        = Color3.fromRGB(22, 24, 30),
    Text        = Color3.fromRGB(230, 232, 240),
    TextDim     = Color3.fromRGB(120, 125, 140),
    Accent      = Color3.fromRGB(160, 120, 255),
    AccentSoft  = Color3.fromRGB(120, 90, 210),
    ToggleOff   = Color3.fromRGB(45, 48, 58),
    ToggleOn    = Color3.fromRGB(160, 120, 255),
    Stroke      = Color3.fromRGB(40, 36, 55),
    TabActive   = Color3.fromRGB(30, 28, 42),
}
Library.Theme = Theme

Library.TabIcons = {
    Combat   = "rbxassetid://134242818164054",
    Visuals  = "rbxassetid://100033680381365",
    Movement = "rbxassetid://81589895647169",
    Settings = "rbxassetid://80758916183665",
    Configs  = "rbxassetid://74748492079329",
    Scripts  = "rbxassetid://79541605299928",
}

Library.FontOptions = {
    { name = "Gotham Bold",   id = "GothamBold" },
    { name = "Gotham",        id = "Gotham" },
    { name = "Gotham Medium", id = "GothamMedium" },
    { name = "Code",          id = "Code" },
    { name = "Builder Sans",  id = "BuilderSans" },
    { name = "Builder Mono",  id = "BuilderMono" },
    { name = "Roboto Mono",   id = "RobotoMono" },
    { name = "Nunito",        id = "Nunito" },
    { name = "Josefin Sans",  id = "JosefinSans" },
    { name = "Jura",          id = "Jura" },
    { name = "Ubuntu",        id = "Ubuntu" },
    { name = "Source Sans",   id = "SourceSans" },
    { name = "Arcade",        id = "Arcade" },
    { name = "Special Elite", id = "SpecialElite" },
    { name = "Fredoka One",   id = "FredokaOne" },
    { name = "Patrick Hand",  id = "PatrickHand" },
    { name = "Legacy",        id = "Legacy" },
    { name = "Highway",       id = "Highway" },
    { name = "SciFi",         id = "SciFi" },
    { name = "Cartoon",       id = "Cartoon" },
}

-- ════════════════════════════════════════════════════════════════════
--  Small helpers
-- ════════════════════════════════════════════════════════════════════
local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(Library._conns, c)
    return c
end

local function new(class, props, parent)
    local inst = Instance.new(class)
    if props then
        for k, v in pairs(props) do inst[k] = v end
    end
    if parent then inst.Parent = parent end
    return inst
end

local function corner(parent, radius)
    return new("UICorner", { CornerRadius = radius }, parent)
end

local function stroke(parent, color, thickness, transparency)
    return new("UIStroke", {
        Color = color, Thickness = thickness or 1, Transparency = transparency or 0,
    }, parent)
end

function Library:_Track(inst, prop)
    if not inst then return end
    prop = prop or "TextColor3"
    for _, e in ipairs(self._tracked) do
        if e.inst == inst and e.prop == prop then return end
    end
    table.insert(self._tracked, { inst = inst, prop = prop })
end

function Library.ColorToHex(col)
    local r = math.floor(col.R * 255 + 0.5)
    local g = math.floor(col.G * 255 + 0.5)
    local b = math.floor(col.B * 255 + 0.5)
    return string.format("#%02X%02X%02X", r, g, b)
end

function Library.HexToColor(str)
    if not str then return nil end
    str = tostring(str):gsub("#", ""):gsub("%s", "")
    if #str == 3 then
        str = str:sub(1,1)..str:sub(1,1)..str:sub(2,2)..str:sub(2,2)..str:sub(3,3)..str:sub(3,3)
    end
    if #str < 6 then return nil end
    local r = tonumber(str:sub(1, 2), 16)
    local g = tonumber(str:sub(3, 4), 16)
    local b = tonumber(str:sub(5, 6), 16)
    if not r or not g or not b then return nil end
    return Color3.fromRGB(r, g, b)
end

function Library.ResolveEnumFont(id)
    if typeof(id) == "EnumItem" then return id end
    local key = tostring(id or "GothamBold")
    local ok, f = pcall(function() return Enum.Font[key] end)
    if ok and f then return f end
    return Enum.Font.GothamBold
end

-- ════════════════════════════════════════════════════════════════════
--  ScreenGui / blur / notification container
-- ════════════════════════════════════════════════════════════════════
function Library:_EnsureGui()
    if self.ScreenGui and self.ScreenGui.Parent then return self.ScreenGui end

    -- remove an old copy that has the same name
    pcall(function()
        local roots = { CoreGui }
        if gethui then table.insert(roots, gethui()) end
        for _, root in ipairs(roots) do
            local old = root:FindFirstChild(self.GuiName)
            if old then old:Destroy() end
        end
    end)

    local gui = Instance.new("ScreenGui")
    gui.Name = self.GuiName
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local ok = pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(gui)
            gui.Parent = CoreGui
        elseif gethui then
            gui.Parent = gethui()
        else
            gui.Parent = CoreGui
        end
    end)
    if not ok or not gui.Parent then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    self.ScreenGui = gui

    local blur = Instance.new("BlurEffect")
    blur.Name = "AnxiumMenuBlur"
    blur.Size = 0
    blur.Parent = Lighting
    self.BlurEffect = blur

    local container = new("Frame", {
        Name = "NotifContainer",
        Size = UDim2.new(0, 280, 1, -24),
        Position = UDim2.new(1, -296, 0, 12),
        BackgroundTransparency = 1,
    }, gui)
    new("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 8),
    }, container)
    self._NotifContainer = container

    return gui
end

-- ════════════════════════════════════════════════════════════════════
--  Draggable (same smoothing as the original: 0.08s Quad tween)
-- ════════════════════════════════════════════════════════════════════
function Library:MakeDraggable(uiFrame, dragHandle)
    local dragging, dragInput, dragStart, startPos
    local moveTween = nil
    dragHandle = dragHandle or uiFrame
    connect(dragHandle.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = uiFrame.Position
            if moveTween then pcall(function() moveTween:Cancel() end) moveTween = nil end
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    connect(dragHandle.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    connect(UserInputService.InputChanged, function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local goal = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            if moveTween then pcall(function() moveTween:Cancel() end) end
            moveTween = TweenService:Create(
                uiFrame,
                TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Position = goal }
            )
            moveTween:Play()
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════
--  Notify
-- ════════════════════════════════════════════════════════════════════
function Library:Notify(title, message, duration)
    if self._suppressNotify then return end
    self:_EnsureGui()
    duration = duration or 2.6
    title = tostring(title or self.Name)
    message = tostring(message or "")

    local Card = new("Frame", {
        Name = "NotifCard",
        Size = UDim2.new(0, 268, 0, 48),
        BackgroundColor3 = Theme.BgSecondary,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })
    corner(Card, UDim.new(0, 10))

    local Stroke = stroke(Card, Theme.Accent, 1, 1)
    self:_Track(Stroke, "Color")

    local AccentBar = new("Frame", {
        Name = "Accent",
        Size = UDim2.new(0, 3, 1, -10),
        Position = UDim2.new(0, 0, 0, 5),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
    }, Card)
    self:_Track(AccentBar, "BackgroundColor3")
    corner(AccentBar, UDim.new(1, 0))

    local IconBg = new("Frame", {
        Name = "IconBg",
        Size = UDim2.fromOffset(32, 32),
        Position = UDim2.new(0, 12, 0.5, -16),
        BackgroundColor3 = Theme.BgTertiary,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
    }, Card)
    corner(IconBg, UDim.new(0, 8))

    local Icon = new("ImageLabel", {
        Name = "Icon",
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(20, 20),
        Position = UDim2.new(0.5, -10, 0.5, -10),
        Image = self.NotifyIcon or "rbxassetid://112102474509324",
        ImageColor3 = Theme.Accent,
        ScaleType = Enum.ScaleType.Fit,
        ImageTransparency = 1,
    }, IconBg)
    self:_Track(Icon, "ImageColor3")

    local TitleLbl = new("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -60, 0, 16),
        Position = UDim2.new(0, 52, 0, 8),
        Font = self.Font,
        TextSize = 12,
        TextColor3 = Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = title,
        TextTransparency = 1,
    }, Card)
    self:_Track(TitleLbl, "TextColor3")

    local MsgLbl = new("TextLabel", {
        Name = "Message",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -60, 0, 16),
        Position = UDim2.new(0, 52, 0, 24),
        Font = self.Font,
        TextSize = 11,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = message,
        TextTransparency = 1,
    }, Card)

    Card.Parent = self._NotifContainer

    local tiIn = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    TweenService:Create(Card, tiIn, { BackgroundTransparency = 0.08 }):Play()
    TweenService:Create(Stroke, tiIn, { Transparency = 0.45 }):Play()
    TweenService:Create(TitleLbl, tiIn, { TextTransparency = 0 }):Play()
    TweenService:Create(MsgLbl, tiIn, { TextTransparency = 0.12 }):Play()
    TweenService:Create(Icon, tiIn, { ImageTransparency = 0 }):Play()

    task.delay(duration, function()
        if not Card or not Card.Parent then return end
        local tiOut = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        TweenService:Create(Card, tiOut, { BackgroundTransparency = 1 }):Play()
        TweenService:Create(Stroke, tiOut, { Transparency = 1 }):Play()
        TweenService:Create(TitleLbl, tiOut, { TextTransparency = 1 }):Play()
        TweenService:Create(MsgLbl, tiOut, { TextTransparency = 1 }):Play()
        TweenService:Create(Icon, tiOut, { ImageTransparency = 1 }):Play()
        task.wait(0.3)
        pcall(function() Card:Destroy() end)
    end)
end

-- ════════════════════════════════════════════════════════════════════
--  Switch animation (toggle)
-- ════════════════════════════════════════════════════════════════════
function Library:_UpdateSwitch(state, bg, knob, featureName, instant)
    local info = TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    pcall(function()
        if knob then
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.Size = UDim2.new(0, 14, 0, 14)
        end
    end)
    local glow = bg and bg:FindFirstChild("SwitchGlow")
    local bgColor  = state and Theme.Accent or Theme.ToggleOff
    local knobPos  = state and UDim2.new(1, -9, 0.5, 0) or UDim2.new(0, 9, 0.5, 0)
    local glowGoal = state and { Transparency = 0.25, Thickness = 2 } or { Transparency = 0.92, Thickness = 1.5 }

    if instant then
        if bg then bg.BackgroundColor3 = bgColor end
        if knob then knob.Position = knobPos end
        if glow then glow.Transparency = glowGoal.Transparency glow.Thickness = glowGoal.Thickness end
    else
        if bg then TweenService:Create(bg, info, { BackgroundColor3 = bgColor }):Play() end
        if knob then TweenService:Create(knob, info, { Position = knobPos }):Play() end
        if glow then TweenService:Create(glow, info, glowGoal):Play() end
    end
    if featureName and Library.NotifyOnToggle then
        Library:Notify(Library.Name, featureName .. (state and " enabled" or " disabled"))
    end
    Library:UpdateActiveList()
    Library:UpdateBindList()
end

-- ════════════════════════════════════════════════════════════════════
--  Color picker popup (1:1 port of OpenRGBPicker)
-- ════════════════════════════════════════════════════════════════════
local Picker = {
    Frame = nil, Callback = nil, PreviewBtn = nil, Original = nil, Applied = false,
    H = 0.75, S = 0.55, V = 1, DraggingSV = false, DraggingHue = false,
    Selected = nil, Refresh = nil, SetFromColor = nil,
}

function Library:CloseColorPicker()
    if Picker.Frame then Picker.Frame.Visible = false end
    -- if the picker was closed without Apply, put the preview button back
    if Picker.PreviewBtn and Picker.Original and not Picker.Applied then
        pcall(function() Picker.PreviewBtn.BackgroundColor3 = Picker.Original end)
    end
    Picker.Callback = nil
    Picker.PreviewBtn = nil
    Picker.DraggingSV = false
    Picker.DraggingHue = false
end

function Library:OpenColorPicker(currentColor, onApply, previewBtn)
    local gui = self:_EnsureGui()
    Picker.Callback = onApply
    Picker.PreviewBtn = previewBtn
    Picker.Applied = false

    local col0 = currentColor or Color3.fromRGB(180, 140, 255)
    Picker.Original = col0
    local h0, s0, v0 = col0:ToHSV()
    Picker.H, Picker.S, Picker.V = h0, s0, v0
    Picker.Selected = col0

    if not Picker.Frame then
        local F = new("Frame", {
            Name = "AnxiumRGBPicker",
            Size = UDim2.new(0, 230, 0, 268),
            Position = UDim2.new(0.5, -115, 0.5, -134),
            BackgroundColor3 = Color3.fromRGB(22, 22, 26),
            BorderSizePixel = 0,
            ZIndex = 120,
        }, gui)
        Picker.Frame = F
        corner(F, UDim.new(0, 8))
        stroke(F, Color3.fromRGB(55, 55, 65), 1)

        local title = new("TextLabel", {
            Name = "Title",
            Size = UDim2.new(1, -40, 0, 24),
            Position = UDim2.new(0, 10, 0, 4),
            BackgroundTransparency = 1,
            Text = "Color Picker",
            TextColor3 = Color3.fromRGB(230, 230, 235),
            TextSize = 13,
            Font = self.Font,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 121,
        }, F)

        local closeBtn = new("ImageButton", {
            Size = UDim2.new(0, 22, 0, 22),
            Position = UDim2.new(1, -28, 0, 5),
            BackgroundTransparency = 1,
            Image = "rbxassetid://115678228554812",
            ImageColor3 = Color3.fromRGB(200, 200, 210),
            ScaleType = Enum.ScaleType.Fit,
            ZIndex = 121,
        }, F)
        connect(closeBtn.MouseButton1Click, function() Library:CloseColorPicker() end)

        -- saturation / value square
        local satFrame = new("TextButton", {
            Name = "SatFrame",
            Size = UDim2.new(0, 180, 0, 160),
            Position = UDim2.new(0, 12, 0, 32),
            BackgroundColor3 = Color3.fromHSV(0.75, 1, 1),
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 121,
            ClipsDescendants = true,
        }, F)
        corner(satFrame, UDim.new(0, 4))

        local satWhite = new("Frame", {
            Name = "SatWhite", Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 122,
        }, satFrame)
        new("UIGradient", {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1),
            }),
        }, satWhite)

        local satBlack = new("Frame", {
            Name = "SatBlack", Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 123,
        }, satFrame)
        new("UIGradient", {
            Rotation = 90,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0),
            }),
        }, satBlack)

        local svCursor = new("Frame", {
            Name = "SVCursor", Size = UDim2.new(0, 10, 0, 10),
            AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1,
            BorderSizePixel = 0, ZIndex = 125,
        }, satFrame)
        stroke(svCursor, Color3.new(1, 1, 1), 1.5)
        corner(svCursor, UDim.new(1, 0))

        -- hue strip
        local hueFrame = new("TextButton", {
            Name = "HueFrame",
            Size = UDim2.new(0, 18, 0, 160),
            Position = UDim2.new(0, 200, 0, 32),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 121,
        }, F)
        corner(hueFrame, UDim.new(0, 4))
        new("UIGradient", {
            Rotation = 90,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Color3.fromHSV(0, 1, 1)),
                ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
                ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
                ColorSequenceKeypoint.new(0.50, Color3.fromHSV(0.50, 1, 1)),
                ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
                ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
                ColorSequenceKeypoint.new(1.00, Color3.fromHSV(1, 1, 1)),
            }),
        }, hueFrame)

        local hueCursor = new("Frame", {
            Name = "HueCursor",
            Size = UDim2.new(1, 4, 0, 4),
            Position = UDim2.new(0.5, 0, 0, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            ZIndex = 125,
        }, hueFrame)
        stroke(hueCursor, Color3.fromRGB(30, 30, 35), 1)
        corner(hueCursor, UDim.new(0, 2))

        -- preview / hex / apply
        local preview = new("Frame", {
            Name = "Preview", Size = UDim2.new(0, 36, 0, 28),
            Position = UDim2.new(0, 12, 0, 202), BorderSizePixel = 0, ZIndex = 121,
        }, F)
        corner(preview, UDim.new(0, 5))
        stroke(preview, Color3.fromRGB(60, 60, 70), 1)

        local hexBox = new("TextBox", {
            Name = "HexBox",
            Size = UDim2.new(0, 90, 0, 28),
            Position = UDim2.new(0, 56, 0, 202),
            BackgroundColor3 = Color3.fromRGB(36, 36, 42),
            BorderSizePixel = 0,
            Text = "#B48CFF",
            TextColor3 = Color3.fromRGB(220, 220, 230),
            TextSize = 12,
            Font = self.Font,
            ClearTextOnFocus = false,
            ZIndex = 121,
        }, F)
        corner(hexBox, UDim.new(0, 5))

        local apply = new("TextButton", {
            Name = "ApplyBtn",
            Size = UDim2.new(0, 62, 0, 28),
            Position = UDim2.new(1, -74, 0, 202),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Text = "Apply",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 12,
            Font = self.Font,
            ZIndex = 121,
        }, F)
        corner(apply, UDim.new(0, 5))
        self:_Track(apply, "BackgroundColor3")

        new("TextLabel", {
            Size = UDim2.new(1, -20, 0, 18),
            Position = UDim2.new(0, 12, 0, 238),
            BackgroundTransparency = 1,
            Text = "Drag on square / hue · Enter hex · Apply",
            TextColor3 = Color3.fromRGB(120, 120, 130),
            TextSize = 10,
            Font = self.Font,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 121,
        }, F)

        local function refreshFromHSV()
            local h, s, v = Picker.H, Picker.S, Picker.V
            local col = Color3.fromHSV(h, s, v)
            Picker.Selected = col
            satFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            preview.BackgroundColor3 = col
            hexBox.Text = Library.ColorToHex(col)
            svCursor.Position = UDim2.new(s, 0, 1 - v, 0)
            hueCursor.Position = UDim2.new(0.5, 0, h, 0)
            if Picker.PreviewBtn then
                pcall(function() Picker.PreviewBtn.BackgroundColor3 = col end)
            end
        end
        Picker.Refresh = refreshFromHSV

        local function setFromColor(col)
            if not col then return end
            local h, s, v = col:ToHSV()
            Picker.H, Picker.S, Picker.V = h, s, v
            refreshFromHSV()
        end
        Picker.SetFromColor = setFromColor

        local function updateFromMouse(absPos, mode)
            if mode == "sv" then
                local ap, as = satFrame.AbsolutePosition, satFrame.AbsoluteSize
                if as.X <= 0 or as.Y <= 0 then return end
                Picker.S = math.clamp((absPos.X - ap.X) / as.X, 0, 1)
                Picker.V = 1 - math.clamp((absPos.Y - ap.Y) / as.Y, 0, 1)
                refreshFromHSV()
            elseif mode == "hue" then
                local ap, as = hueFrame.AbsolutePosition, hueFrame.AbsoluteSize
                if as.Y <= 0 then return end
                Picker.H = math.clamp((absPos.Y - ap.Y) / as.Y, 0, 1)
                refreshFromHSV()
            end
        end

        connect(satFrame.MouseButton1Down, function()
            Picker.DraggingSV = true
            updateFromMouse(UserInputService:GetMouseLocation(), "sv")
        end)
        connect(hueFrame.MouseButton1Down, function()
            Picker.DraggingHue = true
            updateFromMouse(UserInputService:GetMouseLocation(), "hue")
        end)
        connect(UserInputService.InputChanged, function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
            if not Picker.Frame or not Picker.Frame.Visible then return end
            if Picker.DraggingSV then
                updateFromMouse(input.Position, "sv")
            elseif Picker.DraggingHue then
                updateFromMouse(input.Position, "hue")
            end
        end)
        connect(UserInputService.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Picker.DraggingSV = false
                Picker.DraggingHue = false
            end
        end)

        connect(hexBox.FocusLost, function()
            local c = Library.HexToColor(hexBox.Text)
            if c then
                setFromColor(c)
            else
                hexBox.Text = Library.ColorToHex(Picker.Selected or col0)
            end
        end)

        connect(apply.MouseButton1Click, function()
            local col = Picker.Selected or Color3.fromRGB(180, 140, 255)
            local cb = Picker.Callback
            Picker.Applied = true
            if cb then pcall(cb, col) end
            if Picker.PreviewBtn then
                pcall(function() Picker.PreviewBtn.BackgroundColor3 = col end)
            end
            Library:CloseColorPicker()
        end)

        self:MakeDraggable(F, title)
        refreshFromHSV()
    end

    if Picker.SetFromColor then Picker.SetFromColor(col0) end
    Picker.Frame.Visible = true
end

-- ════════════════════════════════════════════════════════════════════
--  Tabs / search / menu open-close
-- ════════════════════════════════════════════════════════════════════
local Elements = {}          -- element builders shared by Tab and Section
local WindowMethods = {}     -- methods of the object returned by CreateWindow
WindowMethods.__index = WindowMethods

function Library:SwitchTab(tabName)
    self.CurrentTab = tabName
    for name, frame in pairs(self._tabFrames) do
        frame.Visible = (name == tabName)
    end
    for name, btn in pairs(self._tabButtons) do
        local label = btn:FindFirstChild("TabLabel")
        local icon = btn:FindFirstChild("TabIcon")
        local accent = btn:FindFirstChild("ActiveAccent")
        if name == tabName then
            btn.BackgroundColor3 = Theme.TabActive
            btn.BackgroundTransparency = 0
            btn.TextColor3 = Theme.Text
            if label then label.TextColor3 = Theme.Text end
            if icon then icon.ImageColor3 = Theme.Accent end
            if accent then
                accent.Visible = true
                accent.BackgroundColor3 = Theme.Accent
            end
        else
            btn.BackgroundColor3 = Theme.TabActive
            btn.BackgroundTransparency = 1
            btn.TextColor3 = Theme.TextDim
            if label then label.TextColor3 = Theme.TextDim end
            if icon then icon.ImageColor3 = Theme.TextDim end
            if accent then
                accent.Visible = false
                accent.BackgroundColor3 = Theme.Accent
            end
        end
    end
    if self.TitleLabel then self.TitleLabel.Text = tabName end
end

function Library:ApplySearch(query)
    query = string.lower(tostring(query or "")):gsub("^%s+", ""):gsub("%s+$", "")
    local searching = query ~= ""
    self._SearchQuery = query

    for tabName, btn in pairs(self._tabButtons) do
        local scroll = self._tabFrames[tabName]
        local tabHit = (not searching) or (string.find(string.lower(tabName), query, 1, true) ~= nil)
        local anyRow = false
        if scroll then
            for _, d in ipairs(scroll:GetDescendants()) do
                if d:IsA("Frame") or d:IsA("TextButton") then
                    local st = nil
                    pcall(function() st = d:GetAttribute("AnxiumSearchText") end)
                    if st and st ~= "" then
                        local hit = (not searching) or (string.find(st, query, 1, true) ~= nil)
                        d.Visible = hit
                        if hit then anyRow = true end
                    end
                end
            end
            for _, ch in ipairs(scroll:GetChildren()) do
                if ch:IsA("Frame") and ch:FindFirstChild("GroupContent") then
                    local content = ch:FindFirstChild("GroupContent")
                    local show = not searching
                    if content then
                        for _, r in ipairs(content:GetChildren()) do
                            if r:IsA("GuiObject") and r.Visible and r:GetAttribute("AnxiumSearchText") then
                                show = true
                                break
                            end
                        end
                    end
                    if searching then ch.Visible = show or tabHit end
                    if not searching then ch.Visible = true end
                    if show then anyRow = true end
                end
            end
        end
        local showTab = (not searching) or tabHit or anyRow
        if btn then btn.Visible = showTab end
    end
end

function Library:SetMenuOpen(open)
    if not self.MainFrame then return end
    self.MenuOpen = open and true or false
    local MainFrame = self.MainFrame
    local tweenInfo = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    if self.MenuOpen then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 680, 0, 440)
        MainFrame.BackgroundTransparency = 1
        TweenService:Create(MainFrame, tweenInfo, { Size = UDim2.new(0, 720, 0, 480), BackgroundTransparency = 0 }):Play()
        TweenService:Create(self.BlurEffect, tweenInfo, { Size = 18 }):Play()
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
            { Size = UDim2.new(0, 680, 0, 440), BackgroundTransparency = 1 }):Play()
        TweenService:Create(self.BlurEffect, tweenInfo, { Size = 0 }):Play()
        task.delay(0.26, function()
            if not Library.MenuOpen then MainFrame.Visible = false end
        end)
    end
    if self.OnMenuToggle then pcall(self.OnMenuToggle, self.MenuOpen) end
end

function Library:ToggleMenu()
    self:SetMenuOpen(not self.MenuOpen)
end

-- ════════════════════════════════════════════════════════════════════
--  Accent (theme color) / font
-- ════════════════════════════════════════════════════════════════════
function Library:SetAccent(color, silent)
    if typeof(color) ~= "Color3" then return end
    Theme.Accent = color
    Theme.ToggleOn = color

    if self._ThemeColorBtn then pcall(function() self._ThemeColorBtn.BackgroundColor3 = color end) end
    if self.WatermarkGrad then pcall(function() self.WatermarkGrad.Color = self:_WatermarkGradient() end) end

    pcall(function()
        if self.TitleLabel then self.TitleLabel.TextColor3 = Theme.Text end
        if self.LogoLabel then self.LogoLabel.TextColor3 = Color3.fromRGB(255, 255, 255) end
        if self.VersionTag then self.VersionTag.TextColor3 = Theme.TextDim end
        if self.ToggleStroke then self.ToggleStroke.Color = Color3.fromRGB(55, 55, 65) end
        if self.ToggleButton then self.ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255) end
    end)

    pcall(function()
        for _, btn in pairs(self._tabButtons) do
            local accent = btn:FindFirstChild("ActiveAccent")
            if accent then accent.BackgroundColor3 = color end
        end
        if self.CurrentTab then self:SwitchTab(self.CurrentTab) end
    end)

    for _, lbl in ipairs(self._sectionLabels) do
        if lbl and lbl.Parent then lbl.TextColor3 = color end
    end

    for _, t in ipairs(self._toggles) do
        if t.Value == true and t.Bg and t.Bg.Parent then t.Bg.BackgroundColor3 = color end
    end

    for _, fill in ipairs(self._sliderFills) do
        if fill and fill.Parent then fill.BackgroundColor3 = color end
    end

    pcall(function()
        for _, frame in pairs(self._tabFrames) do
            if frame and frame:IsA("ScrollingFrame") then frame.ScrollBarImageColor3 = color end
        end
        if self.ActiveContainer then self.ActiveContainer.ScrollBarImageColor3 = color end
        if self.BindListContainer then self.BindListContainer.ScrollBarImageColor3 = color end
    end)

    pcall(function() self:UpdateActiveList() end)
    pcall(function() self:UpdateBindList() end)

    for _, e in ipairs(self._tracked) do
        local inst, prop = e.inst, e.prop or "TextColor3"
        if inst and inst.Parent then
            pcall(function()
                if prop == "BackgroundColor3" then
                    inst.BackgroundColor3 = color
                elseif prop == "ImageColor3" then
                    inst.ImageColor3 = color
                elseif prop == "Color" then
                    inst.Color = color
                elseif prop == "TextColor3" then
                    inst.TextColor3 = color
                elseif inst:IsA("UIStroke") then
                    inst.Color = color
                elseif inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
                    inst.ImageColor3 = color
                elseif inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
                    inst.TextColor3 = color
                elseif inst:IsA("GuiObject") then
                    inst.BackgroundColor3 = color
                end
            end)
        end
    end

    for _, d in ipairs(self._dropdowns or {}) do pcall(d._Refresh) end
    if not silent then self:Notify("Theme", "Theme color applied") end
    if self.OnAccentChanged then pcall(self.OnAccentChanged, color) end
end

function Library:SetFont(fontId)
    fontId = tostring(fontId or "GothamBold")
    self.FontId = fontId
    self.Font = self.ResolveEnumFont(fontId)
    local font = self.Font

    local function applyTo(gui)
        if not gui then return end
        for _, d in ipairs(gui:GetDescendants()) do
            if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                local skip = false
                pcall(function()
                    if d:GetAttribute("AnxiumFontPreview") then skip = true end
                    if d:GetAttribute("AnxiumLockFont") then skip = true end
                end)
                if not skip then pcall(function() d.Font = font end) end
            end
        end
    end
    pcall(function() applyTo(self.ScreenGui) end)
    if self.OnFontChanged then pcall(self.OnFontChanged, fontId, font) end
end

-- ════════════════════════════════════════════════════════════════════
--  Window
-- ════════════════════════════════════════════════════════════════════
function Library:CreateWindow(opts)
    opts = opts or {}
    self.Name    = opts.Name or self.Name
    self.GuiName = opts.GuiName or self.GuiName
    if opts.MenuKey then
        self.MenuKey = typeof(opts.MenuKey) == "EnumItem" and opts.MenuKey.Name or tostring(opts.MenuKey)
    end
    if opts.Font then self.FontId = tostring(opts.Font) self.Font = self.ResolveEnumFont(opts.Font) end
    if opts.Accent then Theme.Accent = opts.Accent Theme.ToggleOn = opts.Accent end
    if opts.NotifyIcon then self.NotifyIcon = opts.NotifyIcon end

    local gui = self:_EnsureGui()
    local Font = self.Font

    -- floating open button -------------------------------------------------
    local ToggleButton = new("TextButton", {
        Name = "AnxiumToggleButton",
        Size = UDim2.new(0, 128, 0, 28),
        Position = UDim2.new(0.02, 0, 0.42, 0),
        BackgroundColor3 = Color3.fromRGB(15, 17, 22),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Text = "  " .. (opts.ToggleText or "anxium"),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Font = Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClipsDescendants = true,
    }, gui)
    new("ImageLabel", {
        Name = "ToggleIcon",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -6, 0.5, 0),
        Size = UDim2.fromOffset(20, 20),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Image = opts.ToggleIcon or "rbxassetid://84168857053009",
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 2,
    }, ToggleButton)
    self.ToggleStroke = stroke(ToggleButton, Color3.fromRGB(55, 55, 65), 1, 0.25)
    pcall(function()
        ToggleButton.TextStrokeTransparency = 1
        ToggleButton.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    end)
    corner(ToggleButton, UDim.new(0, 6))
    self:MakeDraggable(ToggleButton)
    self.ToggleButton = ToggleButton
    if opts.HideToggleButton then ToggleButton.Visible = false end

    -- main frame -------------------------------------------------------------
    local MainFrame = new("Frame", {
        Name = "AnxiumMainFrame",
        Size = UDim2.new(0, 720, 0, 480),
        Position = UDim2.new(0.5, -360, 0.5, -240),
        BackgroundColor3 = Theme.Bg,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true,
    }, gui)
    corner(MainFrame, UDim.new(0, 10))
    self.MainFrame = MainFrame

    -- sidebar ----------------------------------------------------------------
    local Sidebar = new("Frame", {
        Size = UDim2.new(0, 168, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.Sidebar,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
    }, MainFrame)
    corner(Sidebar, UDim.new(0, 10))
    new("Frame", {
        Size = UDim2.new(0, 12, 1, 0),
        Position = UDim2.new(1, -12, 0, 0),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
    }, Sidebar)
    self.Sidebar = Sidebar

    local SidebarTop = new("Frame", {
        Name = "SidebarTop",
        Size = UDim2.new(1, 0, 0, 78),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, Sidebar)

    local LogoLabel = new("TextLabel", {
        Size = UDim2.new(1, -20, 0, 28),
        Position = UDim2.new(0, 14, 0, 10),
        BackgroundTransparency = 1,
        Text = opts.Title or "ANXIUM",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 18,
        Font = Enum.Font.GothamBlack,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }, SidebarTop)
    self.LogoLabel = LogoLabel

    local SearchFrame = new("Frame", {
        Name = "SearchFrame",
        Size = UDim2.new(1, -16, 0, 30),
        Position = UDim2.new(0, 8, 0, 40),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.94,
        BorderSizePixel = 0,
    }, SidebarTop)
    corner(SearchFrame, UDim.new(0, 6))
    stroke(SearchFrame, Theme.Stroke, 1, 0.55)

    new("ImageLabel", {
        Name = "IconSearch",
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 8, 0.5, 0),
        Size = UDim2.new(0, 15, 0, 15),
        Image = "rbxassetid://71309835376233",
        ImageColor3 = Theme.TextDim,
    }, SearchFrame)

    local SearchBox = new("TextBox", {
        Name = "SearchBox",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.new(0, 28, 0, 0),
        Size = UDim2.new(1, -32, 1, 0),
        Font = Font,
        PlaceholderText = "Search",
        PlaceholderColor3 = Theme.TextDim,
        Text = "",
        TextColor3 = Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    }, SearchFrame)
    self.SearchBox = SearchBox

    new("Frame", {
        Name = "SidebarDiv2",
        Size = UDim2.new(1, -16, 0, 1),
        Position = UDim2.new(0, 8, 0, 80),
        BackgroundColor3 = Theme.Stroke,
        BackgroundTransparency = 0.45,
        BorderSizePixel = 0,
    }, Sidebar)

    local SidebarTabs = new("Frame", {
        Name = "SidebarTabs",
        Size = UDim2.new(1, -12, 1, -150),
        Position = UDim2.new(0, 6, 0, 88),
        BackgroundTransparency = 1,
    }, Sidebar)
    new("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, SidebarTabs)
    self.SidebarTabs = SidebarTabs

    -- profile bar --------------------------------------------------------------
    if opts.Profile ~= false then
        local ProfileBar = new("Frame", {
            Name = "ProfileBar",
            Size = UDim2.new(1, -12, 0, 52),
            Position = UDim2.new(0, 6, 1, -58),
            BackgroundColor3 = Theme.BgTertiary,
            BackgroundTransparency = 0.25,
            BorderSizePixel = 0,
        }, Sidebar)
        corner(ProfileBar, UDim.new(0, 8))

        local ProfileAvatar = new("ImageLabel", {
            Name = "Avatar",
            Size = UDim2.new(0, 34, 0, 34),
            Position = UDim2.new(0, 8, 0.5, -17),
            BackgroundColor3 = Theme.BgTertiary,
            BorderSizePixel = 0,
            Image = "",
        }, ProfileBar)
        corner(ProfileAvatar, UDim.new(1, 0))

        new("TextLabel", {
            Size = UDim2.new(1, -52, 0, 16),
            Position = UDim2.new(0, 48, 0, 10),
            BackgroundTransparency = 1,
            Text = opts.ProfileName or LocalPlayer.DisplayName or LocalPlayer.Name,
            TextColor3 = Theme.Text,
            TextSize = 12,
            Font = Font,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, ProfileBar)
        new("TextLabel", {
            Size = UDim2.new(1, -52, 0, 14),
            Position = UDim2.new(0, 48, 0, 28),
            BackgroundTransparency = 1,
            Text = opts.ProfileSub or ("@" .. LocalPlayer.Name),
            TextColor3 = Theme.TextDim,
            TextSize = 10,
            Font = Font,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, ProfileBar)

        task.spawn(function()
            local ok, thumb = pcall(function()
                return Players:GetUserThumbnailAsync(
                    LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            end)
            if ok and thumb and ProfileAvatar then ProfileAvatar.Image = thumb end
        end)
    end

    -- header -------------------------------------------------------------------
    local Header = new("Frame", {
        Size = UDim2.new(1, -168, 0, 44),
        Position = UDim2.new(0, 168, 0, 0),
        BackgroundColor3 = Theme.Bg,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
    }, MainFrame)
    corner(Header, UDim.new(0, 10))
    new("Frame", {
        Size = UDim2.new(1, 0, 0, 12), Position = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = Theme.Bg, BorderSizePixel = 0,
    }, Header)
    new("Frame", {
        Size = UDim2.new(0, 14, 1, 0), Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.Bg, BorderSizePixel = 0,
    }, Header)
    new("Frame", {
        Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Stroke, BackgroundTransparency = 0.4,
        BorderSizePixel = 0, ZIndex = 2,
    }, Header)

    self.TitleLabel = new("TextLabel", {
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Theme.Text,
        TextSize = 15,
        Font = Font,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Header)

    self.VersionTag = new("TextLabel", {
        Size = UDim2.new(0, 120, 1, 0),
        Position = UDim2.new(1, -130, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(opts.Version or ""),
        TextColor3 = Theme.TextDim,
        TextSize = 11,
        Font = Font,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, Header)

    self:MakeDraggable(MainFrame, Header)
    self:MakeDraggable(MainFrame, LogoLabel)

    -- events -------------------------------------------------------------------
    connect(SearchBox:GetPropertyChangedSignal("Text"), function() Library:ApplySearch(SearchBox.Text) end)
    connect(SearchBox.FocusLost, function() Library:ApplySearch(SearchBox.Text) end)
    connect(ToggleButton.MouseButton1Click, function() Library:ToggleMenu() end)

    local Window = setmetatable({ Library = self, MainFrame = MainFrame, Tabs = self.Tabs }, WindowMethods)
    self.Window = Window
    return Window
end

function WindowMethods:SetOpen(v) Library:SetMenuOpen(v) end
function WindowMethods:Toggle() Library:ToggleMenu() end
function WindowMethods:SelectTab(name) Library:SwitchTab(name) end
function WindowMethods:Notify(...) Library:Notify(...) end
function WindowMethods:SetTitle(text) Library.LogoLabel.Text = tostring(text) end
function WindowMethods:SetVersion(text) Library.VersionTag.Text = tostring(text) end
function WindowMethods:SetToggleButtonVisible(v) Library.ToggleButton.Visible = v and true or false end
function WindowMethods:Destroy() Library:Unload() end

-- ════════════════════════════════════════════════════════════════════
--  Tabs and sections
-- ════════════════════════════════════════════════════════════════════
local TabMethods = {}

function WindowMethods:AddTab(name, icon, order)
    name = tostring(name)
    order = order or (#self.Tabs + 1)
    local SidebarTabs = Library.SidebarTabs
    local MainFrame = Library.MainFrame

    local Btn = new("TextButton", {
        Name = "Tab_" .. name,
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Theme.TabActive,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = order,
    }, SidebarTabs)
    corner(Btn, UDim.new(0, 6))

    local Accent = new("Frame", {
        Name = "ActiveAccent",
        Size = UDim2.new(0, 3, 0, 16),
        Position = UDim2.new(0, 4, 0.5, -8),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Visible = false,
    }, Btn)
    corner(Accent, UDim.new(1, 0))

    new("ImageLabel", {
        Name = "TabIcon",
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.new(0, 12, 0.5, -8),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Image = icon or Library.TabIcons[name] or "",
        ImageColor3 = Theme.TextDim,
        ScaleType = Enum.ScaleType.Fit,
    }, Btn)

    new("TextLabel", {
        Name = "TabLabel",
        Size = UDim2.new(1, -36, 1, 0),
        Position = UDim2.new(0, 34, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.TextDim,
        TextSize = 13,
        Font = Library.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Btn)

    connect(Btn.MouseButton1Click, function() Library:SwitchTab(name) end)

    local Scroll = new("ScrollingFrame", {
        Size = UDim2.new(1, -184, 1, -56),
        Position = UDim2.new(0, 176, 0, 52),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
    }, MainFrame)
    new("UIListLayout", {
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, Scroll)
    new("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 20) }, Scroll)

    Library._tabButtons[name] = Btn
    Library._tabFrames[name] = Scroll

    local Tab = setmetatable({
        IsTab = true, Name = name, Button = Btn, Scroll = Scroll,
        Host = Scroll, InGroup = false, _order = 0,
    }, { __index = function(_, k) return TabMethods[k] or Elements[k] end })
    self.Tabs[name] = Tab
    table.insert(self.Tabs, Tab)

    if not Library.CurrentTab then Library:SwitchTab(name) end
    return Tab
end

function TabMethods:AddSection(title, order)
    local tab = self
    title = tostring(title or "Section")
    tab._order = tab._order + 1

    local card = new("Frame", {
        Name = "Group_" .. tostring(title):gsub("%s+", "_"),
        Size = UDim2.new(0.96, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(20, 22, 28),
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        LayoutOrder = order or tab._order,
        ClipsDescendants = false,
    }, tab.Scroll)
    corner(card, UDim.new(0, 10))
    stroke(card, Color3.fromRGB(40, 42, 52), 1, 0.25)
    new("UIPadding", {
        PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
    }, card)
    new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5) }, card)

    local head = new("TextLabel", {
        Name = "GroupTitle",
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Library.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 0,
    }, card)
    table.insert(Library._sectionLabels, head)

    local content = new("Frame", {
        Name = "GroupContent",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = 1,
    }, card)
    new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) }, content)

    local Section = setmetatable({
        IsSection = true, Name = title, Tab = tab, Card = card, Title = head,
        Host = content, InGroup = true, _order = 0,
    }, { __index = Elements })

    tab.CurrentSection = Section   -- later tab:AddX() calls go into this section (same as the original)
    return Section
end

-- ════════════════════════════════════════════════════════════════════
--  Element builders (shared by Tab and Section)
-- ════════════════════════════════════════════════════════════════════
local function target(self)
    if self.IsTab and self.CurrentSection then return self.CurrentSection end
    return self
end
local function nextOrder(c) c._order = c._order + 1 return c._order end
local function rowSize(c, h) return UDim2.new(c.InGroup and 1 or 0.96, 0, 0, h) end
local function tagSearch(row, name)
    pcall(function() row:SetAttribute("AnxiumSearchText", string.lower(tostring(name or ""))) end)
end
local function register(flag, obj)
    Library.Options[flag] = obj
    Library.Flags[flag] = obj.Value
end
local function label(parent, props)
    props.BackgroundTransparency = 1
    props.Font = props.Font or Library.Font
    props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
    return new("TextLabel", props, parent)
end

-- ── Toggle (+ optional color button) ─────────────────────────────────
function Elements:AddToggle(name, opts)
    local c = target(self)
    opts = opts or {}
    local flag = opts.Flag or name
    local inGroup = c.InGroup

    local Row = new("Frame", {
        Size = rowSize(c, 34),
        BackgroundColor3 = inGroup and Color3.fromRGB(28, 31, 40) or Theme.Card,
        BackgroundTransparency = inGroup and 0.15 or 0,
        BorderSizePixel = 0,
        LayoutOrder = nextOrder(c),
    }, c.Host)
    tagSearch(Row, name)
    corner(Row, UDim.new(0, 6))
    local rowStroke = stroke(Row, Theme.Accent, 1, 0.82)
    Library:_Track(rowStroke, "Color")

    label(Row, {
        Size = UDim2.new(0.55, 0, 1, 0), Position = UDim2.new(0, 12, 0, 0),
        Text = name, TextColor3 = Theme.Text, TextSize = 12,
    })

    local obj = { Type = "Toggle", Name = name, Flag = flag, Row = Row, Value = false,
                  Color = opts.Color, Bindable = opts.Bindable ~= false }

    if opts.Color ~= nil then
        local colBtn = new("TextButton", {
            Name = "ColorBtn",
            Size = UDim2.new(0, 22, 0, 22),
            Position = UDim2.new(1, -82, 0.5, -11),
            BackgroundColor3 = opts.Color,
            BorderSizePixel = 0,
            Text = "",
        }, Row)
        corner(colBtn, UDim.new(0, 5))
        stroke(colBtn, Color3.fromRGB(70, 70, 80), 1)
        obj.ColorBtn = colBtn
        connect(colBtn.MouseButton1Click, function()
            Library:OpenColorPicker(obj.Color or Theme.Accent, function(col)
                obj.Color = col
                colBtn.BackgroundColor3 = col
                if opts.ColorCallback then pcall(opts.ColorCallback, col) end
                if Library.NotifyOnColor then Library:Notify("Color", name .. " color set") end
            end, colBtn)
        end)
    end

    local SwitchBg = new("Frame", {
        Name = "SwitchBg",
        Size = UDim2.new(0, 36, 0, 18),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        BackgroundColor3 = Theme.ToggleOff,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, Row)
    corner(SwitchBg, UDim.new(1, 0))
    local swGlow = stroke(SwitchBg, Theme.Accent, 1.5, 0.92)
    swGlow.Name = "SwitchGlow"
    Library:_Track(swGlow, "Color")

    local SwitchKnob = new("Frame", {
        Name = "SwitchKnob",
        Size = UDim2.new(0, 14, 0, 14),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 9, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 2,
    }, SwitchBg)
    corner(SwitchKnob, UDim.new(1, 0))

    local Button = new("TextButton", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 3,
    }, SwitchBg)

    obj.Bg, obj.Knob, obj.Button = SwitchBg, SwitchKnob, Button

    function obj:Set(v, silent)
        v = v and true or false
        self.Value = v
        Library.Flags[flag] = v
        Library:_UpdateSwitch(v, SwitchBg, SwitchKnob, (not silent) and opts.Notify ~= false and name or nil, silent)
        if not silent and opts.Callback then pcall(opts.Callback, v) end
    end
    function obj:Get() return self.Value end
    function obj:Toggle() self:Set(not self.Value) end
    function obj:SetColor(col)
        self.Color = col
        if self.ColorBtn then self.ColorBtn.BackgroundColor3 = col end
        if opts.ColorCallback then pcall(opts.ColorCallback, col) end
    end

    connect(Button.MouseButton1Click, function() obj:Set(not obj.Value) end)

    table.insert(Library._toggles, obj)
    table.insert(Library.Features, obj)
    register(flag, obj)
    if opts.Default then
        obj.Value = true
        Library.Flags[flag] = true
        Library:_UpdateSwitch(true, SwitchBg, SwitchKnob, nil, true)
        if opts.Callback and opts.FireDefault ~= false then task.defer(pcall, opts.Callback, true) end
    end
    if opts.Keybind then Library.Keybinds[flag] = typeof(opts.Keybind) == "EnumItem" and opts.Keybind.Name or tostring(opts.Keybind) end
    Library:_OnFeatureAdded(obj)
    return obj
end

-- ── Slider ───────────────────────────────────────────────────────────
function Elements:AddSlider(name, opts)
    local c = target(self)
    opts = opts or {}
    local minVal, maxVal = opts.Min or 0, opts.Max or 100
    local defaultVal = math.clamp(opts.Default or minVal, minVal, maxVal)
    local flag = opts.Flag or name
    local inGroup = c.InGroup

    local Row = new("Frame", {
        Size = rowSize(c, 48),
        BackgroundColor3 = inGroup and Color3.fromRGB(28, 31, 40) or Theme.Card,
        BackgroundTransparency = inGroup and 0.15 or 0,
        BorderSizePixel = 0,
        LayoutOrder = nextOrder(c),
    }, c.Host)
    tagSearch(Row, name)
    corner(Row, UDim.new(0, 9))
    Library:_Track(stroke(Row, Theme.Accent, 1, 0.84), "Color")

    local span = maxVal - minVal
    local needFloat = (minVal % 1 ~= 0) or (maxVal % 1 ~= 0) or span <= 10
    local function formatValue(v)
        if typeof(v) ~= "number" then return tostring(v) end
        if not needFloat then return tostring(math.floor(v + 0.5)) end
        if span <= 1 then return string.format("%.3f", v)
        elseif span <= 20 then return string.format("%.2f", v) end
        return string.format("%.1f", v)
    end
    local function quantize(raw)
        if not needFloat then return math.floor(raw + 0.5) end
        local decimals = span <= 1 and 3 or (span <= 20 and 2 or 1)
        local mult = 10 ^ decimals
        local v = math.floor(raw * mult + 0.5) / mult
        return math.clamp(v, minVal, maxVal)
    end

    local Label = label(Row, {
        Size = UDim2.new(0.7, 0, 0, 18), Position = UDim2.new(0, 12, 0, 6),
        Text = name .. "  " .. formatValue(defaultVal), TextColor3 = Theme.Text, TextSize = 12,
    })

    local SliderBar = new("Frame", {
        Size = UDim2.new(1, -24, 0, 5), Position = UDim2.new(0, 12, 1, -14),
        BackgroundColor3 = Theme.BgTertiary, BorderSizePixel = 0,
    }, Row)
    corner(SliderBar, UDim.new(1, 0))

    local rel0 = (defaultVal - minVal) / math.max(span, 1e-6)
    local SliderFill = new("Frame", {
        Size = UDim2.new(rel0, 0, 1, 0), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0,
    }, SliderBar)
    table.insert(Library._sliderFills, SliderFill)
    corner(SliderFill, UDim.new(1, 0))
    new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.35, Theme.Accent),
            ColorSequenceKeypoint.new(1, Theme.Accent),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.15),
            NumberSequenceKeypoint.new(0.4, 0),
            NumberSequenceKeypoint.new(1, 0.05),
        }),
        Rotation = 0,
    }, SliderFill)

    local Knob = new("Frame", {
        Name = "SliderKnob",
        Size = UDim2.fromOffset(9, 9), AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(rel0, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(245, 245, 250), BorderSizePixel = 0, ZIndex = 2,
    }, SliderBar)
    corner(Knob, UDim.new(1, 0))
    Library:_Track(stroke(Knob, Theme.Accent, 1), "Color")

    local obj = { Type = "Slider", Name = name, Flag = flag, Row = Row, Value = quantize(defaultVal) }

    local function apply(value, silent)
        local rel = math.clamp((value - minVal) / math.max(span, 1e-6), 0, 1)
        SliderFill.Size = UDim2.new(rel, 0, 1, 0)
        Knob.Position = UDim2.new(rel, 0, 0.5, 0)
        Label.Text = name .. "  " .. formatValue(value)
        obj.Value = value
        Library.Flags[flag] = value
        if not silent and opts.Callback then opts.Callback(value) end
    end

    local dragging = false
    local function fromInput(input)
        local barSize = math.max(SliderBar.AbsoluteSize.X, 1)
        local relX = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / barSize, 0, 1)
        apply(quantize(minVal + span * relX))
    end
    connect(SliderBar.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            fromInput(input)
        end
    end)
    connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    connect(UserInputService.InputChanged, function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            fromInput(input)
        end
    end)

    function obj:Set(v, silent) apply(quantize(tonumber(v) or minVal), silent) end
    function obj:Get() return self.Value end

    register(flag, obj)
    return obj
end

-- ── Dropdown (expandable list) ───────────────────────────────────────
function Elements:AddDropdown(name, opts)
    local c = target(self)
    opts = opts or {}
    local values = opts.Values or {}
    local flag = opts.Flag or name
    local maxHeight = opts.MaxHeight or 220
    local width = c.InGroup and 1 or 0.96
    Library._dropdowns = Library._dropdowns or {}

    local obj = { Type = "Dropdown", Name = name, Flag = flag, Values = values,
                  Value = opts.Default or values[1], Expanded = false }

    local HeaderRow = new("TextButton", {
        Name = "DropdownHeader_" .. name,
        Size = UDim2.new(width, 0, 0, 34),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        LayoutOrder = nextOrder(c),
    }, c.Host)
    tagSearch(HeaderRow, name)
    corner(HeaderRow, UDim.new(0, 8))

    local HeaderLbl = label(HeaderRow, {
        Size = UDim2.new(1, -36, 1, 0), Position = UDim2.fromOffset(12, 0),
        Text = name .. "  ·  " .. tostring(obj.Value), TextColor3 = Theme.Text, TextSize = 12,
    })
    local ArrowLbl = label(HeaderRow, {
        Size = UDim2.fromOffset(18, 18), Position = UDim2.new(1, -26, 0.5, -9),
        Text = "▼", TextColor3 = Theme.TextDim, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Center,
    })

    local ListFrame = new("Frame", {
        Name = "DropdownList_" .. name,
        Size = UDim2.new(width, 0, 0, 0),
        BackgroundColor3 = Theme.BgSecondary,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
        LayoutOrder = nextOrder(c),
    }, c.Host)
    corner(ListFrame, UDim.new(0, 8))

    local ListScroll = new("ScrollingFrame", {
        Size = UDim2.new(1, -8, 1, -8), Position = UDim2.fromOffset(4, 4),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, ListFrame)
    new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3) }, ListScroll)
    new("UIPadding", {
        PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4),
    }, ListScroll)

    local buttons = {}
    local function refresh()
        HeaderLbl.Text = name .. "  ·  " .. tostring(obj.Value)
        for v, b in pairs(buttons) do
            if b and b.Parent then
                if v == obj.Value then
                    b.BackgroundColor3 = Theme.Accent
                    b.TextColor3 = Color3.fromRGB(255, 255, 255)
                else
                    b.BackgroundColor3 = Theme.BgTertiary
                    b.TextColor3 = Theme.Text
                end
            end
        end
    end
    obj._Refresh = refresh

    local function listHeight() return math.min(28 * #obj.Values + 16, maxHeight) end
    local function resize()
        ListFrame.Size = obj.Expanded and UDim2.new(width, 0, 0, listHeight()) or UDim2.new(width, 0, 0, 0)
    end

    local function build()
        for _, b in pairs(buttons) do b:Destroy() end
        buttons = {}
        for i, v in ipairs(obj.Values) do
            local b = new("TextButton", {
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundColor3 = Theme.BgTertiary,
                BorderSizePixel = 0,
                Text = "  " .. tostring(v),
                TextColor3 = Theme.Text,
                TextSize = 12,
                Font = Library.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
                LayoutOrder = i,
            }, ListScroll)
            corner(b, UDim.new(0, 6))
            buttons[v] = b
            connect(b.MouseButton1Click, function() obj:Set(v) end)
        end
        refresh()
        resize()
    end

    function obj:Set(v, silent)
        self.Value = v
        Library.Flags[flag] = v
        refresh()
        if silent then return end
        if opts.Callback then pcall(opts.Callback, v) end
        if opts.NotifyTitle then
            Library:Notify(opts.NotifyTitle, (opts.NotifyPrefix or (name .. ": ")) .. tostring(v))
        end
    end
    function obj:Get() return self.Value end
    function obj:SetValues(list, keep)
        self.Values = list
        if not keep or not table.find(list, self.Value) then self.Value = list[1] end
        Library.Flags[flag] = self.Value
        build()
    end
    function obj:SetExpanded(state)
        self.Expanded = state and true or false
        ListFrame.Visible = self.Expanded
        ArrowLbl.Text = self.Expanded and "▲" or "▼"
        resize()
    end

    connect(HeaderRow.MouseButton1Click, function() obj:SetExpanded(not obj.Expanded) end)

    obj.Header, obj.List = HeaderRow, ListFrame
    table.insert(Library._dropdowns, obj)
    build()
    register(flag, obj)
    return obj
end

-- ── Color row ────────────────────────────────────────────────────────
function Elements:AddColor(name, opts)
    local c = target(self)
    opts = opts or {}
    local flag = opts.Flag or name

    local Row = new("Frame", {
        Size = rowSize(c, 34), BackgroundColor3 = Theme.Card, BackgroundTransparency = 0,
        BorderSizePixel = 0, LayoutOrder = nextOrder(c),
    }, c.Host)
    tagSearch(Row, name)
    corner(Row, UDim.new(0, 8))
    label(Row, {
        Size = UDim2.new(1, -52, 1, 0), Position = UDim2.new(0, 12, 0, 0),
        Text = name, TextColor3 = Theme.Text, TextSize = 12,
    })
    local colBtn = new("TextButton", {
        Name = "ColorBtn",
        Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(1, -34, 0.5, -11),
        BackgroundColor3 = opts.Default or Theme.Accent, BorderSizePixel = 0,
        Text = "", AutoButtonColor = false,
    }, Row)
    corner(colBtn, UDim.new(0, 5))
    stroke(colBtn, Color3.fromRGB(70, 70, 80), 1)

    local obj = { Type = "Color", Name = name, Flag = flag, Row = Row, Button = colBtn,
                  Value = opts.Default or Theme.Accent }
    function obj:Set(col, silent)
        self.Value = col
        colBtn.BackgroundColor3 = col
        Library.Flags[flag] = col
        if not silent and opts.Callback then pcall(opts.Callback, col) end
    end
    function obj:Get() return self.Value end

    connect(colBtn.MouseButton1Click, function()
        Library:OpenColorPicker(obj.Value, function(col) obj:Set(col) end, colBtn)
    end)
    register(flag, obj)
    return obj
end

-- ── Text box ─────────────────────────────────────────────────────────
function Elements:AddTextBox(name, opts)
    local c = target(self)
    opts = opts or {}
    local flag = opts.Flag or name
    local obj = { Type = "TextBox", Name = name, Flag = flag, Value = opts.Default or "" }
    local Row, Box

    if opts.Inline then
        Row = new("Frame", {
            Name = "ConfigNameRow",
            Size = rowSize(c, 40), BackgroundColor3 = Theme.BgSecondary, BackgroundTransparency = 0.45,
            BorderSizePixel = 0, LayoutOrder = nextOrder(c),
        }, c.Host)
        corner(Row, UDim.new(0, 8))
        label(Row, {
            Size = UDim2.new(0.4, 0, 1, 0), Position = UDim2.new(0, 12, 0, 0),
            Text = name, TextColor3 = Theme.Text, TextSize = 12,
        })
        Box = new("TextBox", {
            Size = UDim2.new(0, 160, 0, 26), Position = UDim2.new(1, -172, 0.5, -13),
            BackgroundColor3 = Theme.BgTertiary, BorderSizePixel = 0,
            Text = obj.Value, PlaceholderText = opts.Placeholder or "",
            TextColor3 = Theme.Text, PlaceholderColor3 = Theme.TextDim,
            TextSize = 12, Font = Library.Font, ClearTextOnFocus = false,
        }, Row)
        corner(Box, UDim.new(0, 6))
    else
        Row = new("Frame", {
            Size = rowSize(c, 56), BackgroundColor3 = Theme.BgSecondary, BackgroundTransparency = 0.45,
            BorderSizePixel = 0, LayoutOrder = nextOrder(c),
        }, c.Host)
        corner(Row, UDim.new(0, 9))
        label(Row, {
            Size = UDim2.new(1, -20, 0, 18), Position = UDim2.new(0, 12, 0, 6),
            Text = name, TextColor3 = Theme.Text, TextSize = 12,
        })
        local Bg = new("Frame", {
            Size = UDim2.new(1, -24, 0, 24), Position = UDim2.new(0, 12, 0, 26),
            BackgroundColor3 = Theme.BgTertiary, BorderSizePixel = 0,
        }, Row)
        corner(Bg, UDim.new(0, 6))
        Box = new("TextBox", {
            Size = UDim2.new(1, -12, 1, 0), Position = UDim2.new(0, 6, 0, 0),
            BackgroundTransparency = 1, Text = obj.Value,
            PlaceholderText = opts.Placeholder or "", PlaceholderColor3 = Theme.TextDim,
            TextColor3 = Theme.Text, TextSize = 12, Font = Library.Font,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, Bg)
    end
    tagSearch(Row, name)
    obj.Row, obj.Box = Row, Box

    connect(Box.FocusLost, function(enter)
        obj.Value = Box.Text
        Library.Flags[flag] = Box.Text
        if opts.Callback then pcall(opts.Callback, Box.Text, enter) end
    end)
    function obj:Set(text, silent)
        Box.Text = tostring(text)
        self.Value = Box.Text
        Library.Flags[flag] = Box.Text
        if not silent and opts.Callback then pcall(opts.Callback, Box.Text, false) end
    end
    function obj:Get() return self.Value end
    register(flag, obj)
    return obj
end

-- ── Button (full width accent button, like "Open Object Finder") ─────
function Elements:AddButton(text, opts)
    local c = target(self)
    if typeof(opts) == "function" then opts = { Callback = opts } end
    opts = opts or {}

    local Row = new("Frame", {
        Size = rowSize(c, 36), BackgroundColor3 = Theme.Card, BorderSizePixel = 0,
        LayoutOrder = nextOrder(c),
    }, c.Host)
    tagSearch(Row, text)
    corner(Row, UDim.new(0, 8))
    Library:_Track(stroke(Row, Theme.Accent, 1, 0.82), "Color")

    local Btn = new("TextButton", {
        Name = "ConfigAction",
        Size = UDim2.new(1, -16, 0, 28), Position = UDim2.new(0, 8, 0.5, -14),
        BackgroundColor3 = opts.Color or Theme.Accent, BorderSizePixel = 0,
        Text = text, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 13, Font = Library.Font,
    }, Row)
    corner(Btn, UDim.new(0, 6))
    if not opts.Color then Library:_Track(Btn, "BackgroundColor3") end
    connect(Btn.MouseButton1Click, function()
        if opts.Callback then pcall(opts.Callback) end
    end)

    local obj = { Type = "Button", Row = Row, Button = Btn }
    function obj:SetText(t) Btn.Text = t end
    return obj
end

-- ── Button grid (icon buttons, like Save / Create / Load ...) ────────
-- buttons = { {Text=, Callback=, Color=, Icon=}, ... }   (3 per row)
function Elements:AddButtonGrid(buttons)
    local c = target(self)
    local rows = math.max(math.ceil(#buttons / 3), 1)
    local Holder = new("Frame", {
        Name = "ConfigBtnRow",
        Size = rowSize(c, rows * 30 + (rows - 1) * 6 + 6),
        BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = nextOrder(c),
    }, c.Host)
    new("UIGridLayout", {
        CellSize = UDim2.new(0.32, -4, 0, 30),
        CellPadding = UDim2.new(0.02, 0, 0, 6),
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, Holder)

    local made = {}
    for i, def in ipairs(buttons) do
        local color = def.Color or Theme.BgSecondary
        local iconId = def.Icon
        local b = new("TextButton", {
            BackgroundColor3 = color, BorderSizePixel = 0, Text = "",
            AutoButtonColor = true, LayoutOrder = i,
        }, Holder)
        corner(b, UDim.new(0, 8))
        if def.Accent then Library:_Track(b, "BackgroundColor3") end
        if iconId and iconId ~= "" then
            new("ImageLabel", {
                Name = "Icon", BackgroundTransparency = 1, Size = UDim2.fromOffset(14, 14),
                Position = UDim2.new(0, 10, 0.5, -7), Image = iconId, ScaleType = Enum.ScaleType.Fit,
            }, b)
        end
        label(b, {
            Name = "Label", Size = UDim2.new(1, iconId and -30 or -12, 1, 0),
            Position = UDim2.new(0, iconId and 28 or 6, 0, 0), Text = def.Text,
            TextColor3 = Theme.Text, TextSize = 12, TextYAlignment = Enum.TextYAlignment.Center,
        })
        connect(b.MouseButton1Click, function() if def.Callback then pcall(def.Callback) end end)
        made[i] = b
    end
    return made
end

-- ── Label / hint text ────────────────────────────────────────────────
function Elements:AddLabel(text, opts)
    local c = target(self)
    opts = opts or {}
    local lbl = label(c.Host, {
        Size = UDim2.new(1, -20, 0, opts.Height or 28),
        Text = text, TextColor3 = Theme.TextDim, TextSize = opts.TextSize or 11,
        TextWrapped = true, LayoutOrder = nextOrder(c),
    })
    local obj = { Type = "Label", Label = lbl }
    function obj:Set(t) lbl.Text = tostring(t) end
    return obj
end

-- ── List box (config list style) ─────────────────────────────────────
function Elements:AddListBox(title, opts)
    local c = target(self)
    opts = opts or {}
    local obj = { Type = "ListBox", Items = opts.Items or {}, Selected = opts.Selected }

    local ListRow = new("Frame", {
        Name = "ConfigListRow",
        Size = rowSize(c, opts.Height or 168),
        BackgroundColor3 = Theme.BgSecondary, BackgroundTransparency = 0.45,
        BorderSizePixel = 0, ClipsDescendants = true, LayoutOrder = nextOrder(c),
    }, c.Host)
    corner(ListRow, UDim.new(0, 8))
    label(ListRow, {
        Size = UDim2.new(1, -16, 0, 22), Position = UDim2.new(0, 12, 0, 4),
        Text = title, TextColor3 = Theme.Text, TextSize = 12,
    })
    local scroll = new("ScrollingFrame", {
        Name = "ConfigListScroll",
        Size = UDim2.new(1, -16, 1, -30), Position = UDim2.new(0, 8, 0, 26),
        BackgroundColor3 = Color3.fromRGB(24, 24, 28), BackgroundTransparency = 0.25,
        BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, ListRow)
    corner(scroll, UDim.new(0, 6))
    new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, scroll)
    new("UIPadding", {
        PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4),
    }, scroll)
    obj.Row, obj.Scroll = ListRow, scroll

    local function rebuild()
        for _, ch in ipairs(scroll:GetChildren()) do
            if ch:IsA("TextButton") or ch:IsA("TextLabel") then ch:Destroy() end
        end
        if #obj.Items == 0 then
            label(scroll, {
                Size = UDim2.new(1, -8, 0, 28), Text = opts.EmptyText or "Nothing here yet",
                TextColor3 = Theme.TextDim, TextSize = 11,
            })
            return
        end
        for i, item in ipairs(obj.Items) do
            local selected = (item == obj.Selected)
            local row = new("TextButton", {
                Name = "Item_" .. tostring(item),
                Size = UDim2.new(1, -8, 0, 28),
                BackgroundColor3 = selected and Color3.fromRGB(55, 45, 80) or Theme.BgTertiary,
                BackgroundTransparency = 0.15,
                BorderSizePixel = 0,
                Text = "  " .. tostring(item),
                TextColor3 = selected and Theme.Accent or Theme.Text,
                TextSize = 12, Font = Library.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = i,
            }, scroll)
            corner(row, UDim.new(0, 6))
            connect(row.MouseButton1Click, function()
                obj.Selected = item
                rebuild()
                if opts.Callback then pcall(opts.Callback, item) end
            end)
            connect(row.MouseButton2Click, function()
                obj.Selected = item
                rebuild()
                if opts.OnRightClick then pcall(opts.OnRightClick, item) end
            end)
        end
    end
    function obj:SetItems(list, keepSelection)
        self.Items = list
        if not keepSelection or not table.find(list, self.Selected) then self.Selected = nil end
        rebuild()
    end
    function obj:Select(item) self.Selected = item rebuild() end
    function obj:Get() return self.Selected end
    rebuild()
    return obj
end

-- ════════════════════════════════════════════════════════════════════
--  Keybinds: element, per-feature bind rows, bind search
-- ════════════════════════════════════════════════════════════════════
Library._keybindElems = {}

local function keyToString(k)
    if k == nil then return nil end
    if typeof(k) == "EnumItem" then return k.Name end
    k = tostring(k)
    return k ~= "" and k or nil
end

local function keyLabelText(k) return k and ("[" .. k .. "]") or "[-]" end

-- generic "key  [Set] [x]" row (used for the Menu Key and for custom keybinds)
function Elements:AddKeybind(name, opts)
    local c = target(self)
    opts = opts or {}
    local flag = opts.Flag or name
    local big = opts.Menu == true

    local Row = new("Frame", {
        Size = rowSize(c, big and 34 or 32),
        BackgroundColor3 = Theme.Card, BackgroundTransparency = 0, BorderSizePixel = 0,
        LayoutOrder = nextOrder(c),
    }, c.Host)
    tagSearch(Row, name)
    corner(Row, UDim.new(0, big and 9 or 6))
    label(Row, {
        Size = UDim2.new(big and 0.45 or 0.5, 0, 1, 0), Position = UDim2.new(0, big and 12 or 10, 0, 0),
        Text = name, TextColor3 = Theme.Text, TextSize = big and 13 or 12,
    })

    local default = keyToString(opts.Default) or (big and "Insert" or nil)
    local KeyLbl = new("TextLabel", {
        Name = "KeyLbl", Size = UDim2.new(0, 70, 0, 22), Position = UDim2.new(1, -150, 0.5, -11),
        BackgroundColor3 = Theme.BgTertiary, BorderSizePixel = 0,
        Text = keyLabelText(default), TextColor3 = Theme.TextDim, TextSize = 11, Font = Library.Font,
    }, Row)
    corner(KeyLbl, UDim.new(0, 5))

    local SetBtn = new("TextButton", {
        Name = "SetBindBtn", Size = UDim2.new(0, 44, 0, 22), Position = UDim2.new(1, -72, 0.5, -11),
        BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Text = "Set",
        TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 11, Font = Library.Font,
    }, Row)
    Library:_Track(SetBtn, "BackgroundColor3")
    corner(SetBtn, UDim.new(0, 5))

    local ClrBtn = new("TextButton", {
        Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(1, -24, 0.5, -11),
        BackgroundColor3 = Theme.BgTertiary, BorderSizePixel = 0, Text = "×",
        TextColor3 = Theme.Text, TextSize = 14, Font = Library.Font,
    }, Row)
    corner(ClrBtn, UDim.new(0, 5))

    local obj = { Type = "Keybind", Name = name, Flag = flag, Row = Row, Label = KeyLbl,
                  Value = default, OnPress = opts.OnPress, OnRelease = opts.OnRelease }

    function obj:Set(key, silent)
        key = keyToString(key)
        if big and not key then key = "Insert" end
        self.Value = key
        KeyLbl.Text = keyLabelText(key)
        Library.Flags[flag] = key
        if big then Library.MenuKey = key end
        if not silent and opts.Callback then pcall(opts.Callback, key) end
    end
    function obj:Get() return self.Value end

    function obj:_Finish(keyName)
        if keyName == "Escape" then
            KeyLbl.Text = keyLabelText(self.Value)
            Library:Notify(big and "Menu" or "Binds", "Bind cancelled")
        elseif keyName == "Backspace" or keyName == "Delete" then
            self:Set(nil)
            Library:Notify(big and "Menu" or "Binds", big and "Menu key reset to [Insert]" or (name .. " bind cleared"))
        else
            self:Set(keyName)
            Library:Notify(big and "Menu" or "Binds", big and ("Open key: [" .. keyName .. "]") or (name .. " → [" .. keyName .. "]"))
        end
    end

    connect(SetBtn.MouseButton1Click, function()
        Library._waiting = { obj = obj, ignore = tick() + (big and 0.25 or 0.2) }
        KeyLbl.Text = "[...]"
        Library:Notify(big and "Menu" or "Binds",
            big and "Press a key for menu open (Esc = cancel)" or ("Press a key for " .. name .. " (Esc cancel, Backspace clear)"))
    end)
    connect(ClrBtn.MouseButton1Click, function()
        obj:Set(nil)
        Library:Notify(big and "Menu" or "Binds", big and "Menu key reset to [Insert]" or (name .. " bind cleared"))
    end)

    if big then Library.MenuKey = default end
    table.insert(Library._keybindElems, obj)
    register(flag, obj)
    return obj
end

-- bind row for a toggle (feature)
function Library:SetFeatureKeybind(flag, keyName)
    if keyName == nil or keyName == "" then
        self.Keybinds[flag] = nil
    else
        for f, k in pairs(self.Keybinds) do   -- one key = one feature
            if k == keyName and f ~= flag then self.Keybinds[f] = nil end
        end
        self.Keybinds[flag] = keyName
    end
    self:RefreshBindKeyLabels()
    self:UpdateBindList()
end

function Library:RefreshBindKeyLabels()
    for _, e in ipairs(self._bindRows) do
        if e.Label and e.Label.Parent then e.Label.Text = keyLabelText(self.Keybinds[e.Flag]) end
    end
end

function Library:_AddBindRow(container, flag)
    local obj = self.Options[flag]
    local name = obj and obj.Name or tostring(flag)

    local Row = new("Frame", {
        Size = rowSize(container, 32), BackgroundColor3 = Theme.Card, BackgroundTransparency = 0,
        BorderSizePixel = 0, LayoutOrder = nextOrder(container),
    }, container.Host)
    corner(Row, UDim.new(0, 6))
    label(Row, {
        Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0),
        Text = name, TextColor3 = Theme.Text, TextSize = 12,
    })
    local KeyLbl = new("TextLabel", {
        Name = "KeyLbl", Size = UDim2.new(0, 70, 0, 22), Position = UDim2.new(1, -150, 0.5, -11),
        BackgroundColor3 = Theme.BgTertiary, BorderSizePixel = 0,
        Text = keyLabelText(self.Keybinds[flag]), TextColor3 = Theme.TextDim, TextSize = 11, Font = self.Font,
    }, Row)
    corner(KeyLbl, UDim.new(0, 5))
    local SetBtn = new("TextButton", {
        Name = "SetBindBtn", Size = UDim2.new(0, 44, 0, 22), Position = UDim2.new(1, -72, 0.5, -11),
        BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Text = "Set",
        TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 11, Font = self.Font,
    }, Row)
    self:_Track(SetBtn, "BackgroundColor3")
    corner(SetBtn, UDim.new(0, 5))
    local ClrBtn = new("TextButton", {
        Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(1, -24, 0.5, -11),
        BackgroundColor3 = Theme.BgTertiary, BorderSizePixel = 0, Text = "×",
        TextColor3 = Theme.Text, TextSize = 14, Font = self.Font,
    }, Row)
    corner(ClrBtn, UDim.new(0, 5))

    local proxy = {}
    function proxy:_Finish(keyName)
        if keyName == "Escape" then
            Library:Notify("Binds", "Bind cancelled")
        elseif keyName == "Backspace" or keyName == "Delete" then
            Library:SetFeatureKeybind(flag, nil)
            Library:Notify("Binds", name .. " bind cleared")
        else
            Library:SetFeatureKeybind(flag, keyName)
            Library:Notify("Binds", name .. " → [" .. keyName .. "]")
        end
    end
    connect(SetBtn.MouseButton1Click, function()
        Library._waiting = { obj = proxy, ignore = tick() + 0.2 }
        Library:Notify("Binds", "Press a key for " .. name .. " (Esc cancel, Backspace clear)")
    end)
    connect(ClrBtn.MouseButton1Click, function()
        Library:SetFeatureKeybind(flag, nil)
        KeyLbl.Text = "[-]"
        Library:Notify("Binds", name .. " bind cleared")
    end)
    table.insert(self._bindRows, { Row = Row, Flag = flag, Name = name:lower(), Label = KeyLbl })
end

function Library:_OnFeatureAdded(obj)
    if self._bindHost and obj.Bindable then self:_AddBindRow(self._bindHost, obj.Flag) end
    self:UpdateActiveList()
    self:UpdateBindList()
end

-- search box + one bind row for each toggle (existing and future ones)
function Elements:AddBindList(opts)
    local c = target(self)
    opts = opts or {}

    local searchRow = new("Frame", {
        Size = rowSize(c, 34), BackgroundColor3 = Theme.Card, BorderSizePixel = 0,
        LayoutOrder = nextOrder(c),
    }, c.Host)
    corner(searchRow, UDim.new(0, 8))
    local searchBox = new("TextBox", {
        Name = "BindSearchBox",
        Size = UDim2.new(1, -20, 1, -8), Position = UDim2.new(0, 10, 0, 4),
        BackgroundTransparency = 1, BorderSizePixel = 0, Font = Library.Font,
        PlaceholderText = "Search binds...", PlaceholderColor3 = Theme.TextDim, Text = "",
        TextColor3 = Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    }, searchRow)
    connect(searchBox:GetPropertyChangedSignal("Text"), function()
        local q = string.lower(tostring(searchBox.Text or ""):gsub("^%s+", ""):gsub("%s+$", ""))
        for _, e in ipairs(Library._bindRows) do
            if e.Row then
                if q == "" then
                    e.Row.Visible = true
                else
                    local key = string.lower(tostring(Library.Keybinds[e.Flag] or ""))
                    e.Row.Visible = (string.find(e.Name or "", q, 1, true) ~= nil) or (string.find(key, q, 1, true) ~= nil)
                end
            end
        end
    end)

    Library._bindHost = c
    for _, f in ipairs(Library.Features) do
        if f.Bindable then Library:_AddBindRow(c, f.Flag) end
    end
end

-- ════════════════════════════════════════════════════════════════════
--  Global input
-- ════════════════════════════════════════════════════════════════════
connect(UserInputService.InputBegan, function(input, gameProcessed)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    local keyCode = input.KeyCode
    if not keyCode or keyCode == Enum.KeyCode.Unknown then return end
    local keyName = keyCode.Name

    local w = Library._waiting
    if w then
        if tick() < (w.ignore or 0) then return end
        Library._waiting = nil
        w.obj:_Finish(keyName)
        return
    end

    if gameProcessed then return end

    if Library.MainFrame and keyName == (Library.MenuKey ~= "" and Library.MenuKey or "Insert") then
        Library:ToggleMenu()
    end

    for flag, kn in pairs(Library.Keybinds) do
        if kn == keyName then
            local o = Library.Options[flag]
            if o and o.Set then o:Set(not o.Value) end
            break
        end
    end
    for _, kb in ipairs(Library._keybindElems) do
        if kb.Value == keyName and kb.OnPress then pcall(kb.OnPress) end
    end
end)

connect(UserInputService.InputEnded, function(input)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    local keyName = input.KeyCode and input.KeyCode.Name
    for _, kb in ipairs(Library._keybindElems) do
        if kb.Value == keyName and kb.OnRelease then pcall(kb.OnRelease) end
    end
end)

-- ════════════════════════════════════════════════════════════════════
--  HUD: Active modules list + Binds list (same frame layout as original)
-- ════════════════════════════════════════════════════════════════════
local HUD_W, HUD_H = 180, 148

local function makeHudFrame(name, position, titleText, iconId)
    local gui = Library:_EnsureGui()
    local Frame = new("Frame", {
        Name = name, Size = UDim2.new(0, HUD_W, 0, HUD_H), Position = position,
        BackgroundColor3 = Theme.Bg, BackgroundTransparency = 0.05, BorderSizePixel = 0,
        ClipsDescendants = true, Visible = false,
    }, gui)
    corner(Frame, UDim.new(0, 10))
    local st = stroke(Frame, Theme.Stroke, 1, 0.35)
    st.Name = "MenuStroke"
    Library:_Track(st, "Color")

    local Header = new("Frame", {
        Name = "Header", Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = Theme.Sidebar,
        BackgroundTransparency = 0, BorderSizePixel = 0,
    }, Frame)

    local titleX, titleW = 12, -20
    if iconId then
        new("ImageLabel", {
            Name = "BindListIcon", AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 12, 0.5, 0),
            Size = UDim2.fromOffset(16, 16), BackgroundTransparency = 1, BorderSizePixel = 0,
            Image = iconId, ScaleType = Enum.ScaleType.Fit,
        }, Header)
        titleX, titleW = 32, -40
    end
    label(Header, {
        Size = UDim2.new(1, titleW, 1, 0), Position = UDim2.new(0, titleX, 0, 0),
        Text = titleText, TextColor3 = Theme.Text, TextSize = 13, TextStrokeTransparency = 1,
    })
    local bar = new("Frame", {
        Name = "AccentBar", Size = UDim2.new(0, 3, 1, -8), Position = UDim2.new(0, 0, 0, 4),
        BackgroundColor3 = Theme.Accent, BorderSizePixel = 0,
    }, Header)
    Library:_Track(bar, "BackgroundColor3")
    corner(bar, UDim.new(1, 0))

    local Container = new("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -28), Position = UDim2.new(0, 0, 0, 28),
        BackgroundColor3 = Theme.BgSecondary, BackgroundTransparency = 0.15, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, Frame)
    new("UIListLayout", { HorizontalAlignment = Enum.HorizontalAlignment.Left, Padding = UDim.new(0, 1) }, Container)
    new("UIPadding", {
        PaddingLeft = UDim.new(0, 10), PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
    }, Container)

    Library:MakeDraggable(Frame, Header)
    return Frame, Container
end

-- opts: Title, Position (UDim2), Enabled
function Library:CreateActiveList(opts)
    opts = opts or {}
    local Frame, Container = makeHudFrame("ActiveFeaturesFrame",
        opts.Position or UDim2.new(0, 16, 0.38, -100), opts.Title or "Active")
    self.ActiveListFrame, self.ActiveContainer = Frame, Container
    self._activeEnabled = opts.Enabled == true
    self:UpdateActiveList()
    return Frame
end

function Library:SetActiveListVisible(v)
    self._activeEnabled = v and true or false
    self:UpdateActiveList()
end

function Library:UpdateActiveList()
    local Frame, Container = self.ActiveListFrame, self.ActiveContainer
    if not Frame then return end
    if not self._activeEnabled then Frame.Visible = false return end
    Frame.Visible = true
    for _, child in ipairs(Container:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
    for _, f in ipairs(self.Features) do
        if f.Value == true then
            label(Container, {
                Size = UDim2.new(1, -10, 0, 16), Text = f.Name,
                TextColor3 = Color3.fromRGB(230, 230, 240), TextSize = 12,
            })
        end
    end
    Frame.Size = UDim2.new(0, HUD_W, 0, HUD_H)
end

function Library:CreateBindList(opts)
    opts = opts or {}
    local Frame, Container = makeHudFrame("BindListFrame",
        opts.Position or UDim2.new(0, 16, 0.38, 80), opts.Title or "Binds",
        opts.Icon or "rbxassetid://121978468376124")
    self.BindListFrame, self.BindListContainer = Frame, Container
    self._bindListEnabled = opts.Enabled == true
    self:UpdateBindList()
    return Frame
end

function Library:SetBindListVisible(v)
    self._bindListEnabled = v and true or false
    self:UpdateBindList()
end

function Library:UpdateBindList()
    local Frame, Container = self.BindListFrame, self.BindListContainer
    if not Frame then return end
    if not self._bindListEnabled then Frame.Visible = false return end
    Frame.Visible = true
    for _, child in ipairs(Container:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
    end

    local count = 0
    local function addRow(displayName, keyName, on)
        count = count + 1
        local row = new("Frame", {
            Name = "BindRow", Size = UDim2.new(1, -8, 0, 18), BackgroundTransparency = 1, BorderSizePixel = 0,
        }, Container)
        label(row, {
            Size = UDim2.new(1, -56, 1, 0), BorderSizePixel = 0, Text = displayName,
            TextColor3 = on and Color3.fromRGB(245, 245, 245) or Theme.TextDim, TextSize = 11,
            TextTruncate = Enum.TextTruncate.AtEnd, TextStrokeTransparency = 1,
        })
        label(row, {
            Size = UDim2.new(0, 52, 1, 0), Position = UDim2.new(1, -52, 0, 0), BorderSizePixel = 0,
            Text = tostring(keyName), TextColor3 = on and Theme.Accent or Theme.TextDim, TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Right, TextStrokeTransparency = 1,
        })
    end

    local shown = {}
    for _, f in ipairs(self.Features) do
        local kn = self.Keybinds[f.Flag]
        if kn and kn ~= "" then
            shown[f.Flag] = true
            addRow(f.Name, kn, f.Value == true)
        end
    end
    for flag, kn in pairs(self.Keybinds) do
        if not shown[flag] and kn and kn ~= "" then
            local o = self.Options[flag]
            addRow(o and o.Name or tostring(flag), kn, o and o.Value == true)
        end
    end
    if count == 0 then
        label(Container, {
            Size = UDim2.new(1, -10, 0, 16), Text = "No binds set", TextColor3 = Theme.TextDim, TextSize = 11,
        })
    end
    Frame.Size = UDim2.new(0, HUD_W, 0, HUD_H)
end

-- ════════════════════════════════════════════════════════════════════
--  Watermark (logo | title | fps | link | config name)
-- ════════════════════════════════════════════════════════════════════
function Library:_WatermarkGradient()
    local a = Theme.Accent or Color3.fromRGB(160, 120, 255)
    local mid = Color3.new(a.R + (1 - a.R) * 0.45, a.G + (1 - a.G) * 0.45, a.B + (1 - a.B) * 0.45)
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0, a),
        ColorSequenceKeypoint.new(0.55, mid),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
    })
end

-- opts: Title, Link, ConfigName, Position ("Center"|"Left"|"Right"), LogoUrl, LogoFile, Icons = {fps,link,cfg}
function Library:CreateWatermark(opts)
    opts = opts or {}
    local gui = self:_EnsureGui()
    local WM = { H = 28, PAD = 6, LOGO = 26, W = 318, Position = opts.Position or "Center",
                 Title = opts.Title or "ANXIUM", Link = opts.Link == nil and "t.me/AnxiumHub" or opts.Link,
                 Config = opts.ConfigName or "default" }
    local icons = opts.Icons or {}
    self.Watermark = WM

    local Frame = new("Frame", {
        Name = "WatermarkFrame", Size = UDim2.fromOffset(WM.W, WM.H),
        Position = UDim2.new(0.5, -math.floor(WM.W / 2), 0, 10),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.05,
        BorderSizePixel = 0, ClipsDescendants = false,
    }, gui)
    stroke(Frame, Color3.fromRGB(0, 0, 0), 1, 0.35)
    corner(Frame, UDim.new(0, 8))
    WM.Frame = Frame

    WM.Logo = new("ImageLabel", {
        Name = "Logo", Size = UDim2.fromOffset(WM.LOGO, WM.LOGO),
        Position = UDim2.new(0, WM.PAD, 0.5, -math.floor(WM.LOGO / 2)),
        BackgroundTransparency = 1, BorderSizePixel = 0, ScaleType = Enum.ScaleType.Fit, Image = "",
    }, Frame)
    pcall(function() WM.Logo.ResampleMode = Enum.ResamplerMode.Pixelated end)
    corner(WM.Logo, UDim.new(0, 4))

    local function wmLabel(name, text)
        return new("TextLabel", {
            Name = name, BackgroundTransparency = 1, Text = text,
            TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 12, Font = self.Font,
            TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center,
        }, Frame)
    end
    local function wmIcon(name, image)
        return new("ImageLabel", {
            Name = name, BackgroundTransparency = 1, Size = UDim2.fromOffset(14, 14),
            Image = image, ScaleType = Enum.ScaleType.Fit,
        }, Frame)
    end

    WM.TitleLabel = wmLabel("WatermarkTitle", WM.Title)
    WM.FpsLabel   = wmLabel("WatermarkFps", "fps: --")
    WM.TgLabel    = wmLabel("WatermarkTg", WM.Link or "")
    WM.CfgLabel   = wmLabel("WatermarkCfg", WM.Config)
    WM.FpsIcon = wmIcon("FpsIcon", icons.Fps  or "rbxassetid://137527339160230")
    WM.TgIcon  = wmIcon("TgIcon",  icons.Link or "rbxassetid://86131768436965")
    WM.CfgIcon = wmIcon("CfgIcon", icons.Cfg  or "rbxassetid://98868866618869")

    self.WatermarkGrad = new("UIGradient", { Color = self:_WatermarkGradient() }, WM.TgLabel)

    function WM:Layout()
        local h, pad, logo, gap, icon = self.H, self.PAD, self.LOGO, 6, 14
        local x = pad + logo + 8
        self.Logo.Size = UDim2.fromOffset(logo, logo)
        self.Logo.Position = UDim2.new(0, pad, 0.5, -math.floor(logo / 2))
        self.TitleLabel.Size = UDim2.fromOffset(56, h)
        self.TitleLabel.Position = UDim2.fromOffset(x, 0)
        self.TitleLabel.Text = self.Title
        x = x + 56 + gap

        self.FpsIcon.Position = UDim2.new(0, x, 0.5, -math.floor(icon / 2))
        x = x + icon + 3
        self.FpsLabel.Size = UDim2.fromOffset(64, h)
        self.FpsLabel.Position = UDim2.fromOffset(x, 0)
        x = x + 64 + gap

        local showLink = self.Link and self.Link ~= ""
        self.TgIcon.Visible, self.TgLabel.Visible = showLink and true or false, showLink and true or false
        if showLink then
            self.TgIcon.Position = UDim2.new(0, x, 0.5, -math.floor(icon / 2))
            x = x + icon + 3
            self.TgLabel.Size = UDim2.fromOffset(110, h)
            self.TgLabel.Position = UDim2.fromOffset(x, 0)
            self.TgLabel.Text = self.Link
            x = x + 110 + gap
        end

        self.CfgIcon.Position = UDim2.new(0, x, 0.5, -math.floor(icon / 2))
        x = x + icon + 3
        local cfgName = tostring(self.Config or "none")
        self.CfgLabel.Text = cfgName
        self.CfgLabel.Size = UDim2.fromOffset(math.clamp(#cfgName * 7 + 8, 40, 140), h)
        self.CfgLabel.Position = UDim2.fromOffset(x, 0)
        x = x + self.CfgLabel.Size.X.Offset + pad

        self.W = math.max(x, 280)
        self.Frame.Size = UDim2.fromOffset(self.W, h)
    end

    function WM:UpdatePosition()
        self:Layout()
        local pos, w, y = self.Position, self.W, 10
        if pos == "Left" then
            self.Frame.Position = UDim2.new(0, 12, 0, y)
        elseif pos == "Right" then
            self.Frame.Position = UDim2.new(1, -(w + 12), 0, y)
        else
            self.Frame.Position = UDim2.new(0.5, -math.floor(w / 2), 0, y)
        end
    end
    function WM:SetPosition(p) self.Position = p self:UpdatePosition() end
    function WM:SetConfigName(n) self.Config = n self:UpdatePosition() end
    function WM:SetVisible(v) self.Frame.Visible = v and true or false end

    -- fps counter
    local frames, last = 0, tick()
    connect(RunService.RenderStepped, function()
        frames = frames + 1
        local now = tick()
        if now - last >= 0.5 then
            local fps = math.floor(frames / (now - last) + 0.5)
            last, frames = now, 0
            local shown = Library.FakeFps or fps
            WM.FpsLabel.Text = "fps: " .. tostring(shown)
        end
    end)

    -- logo (downloaded once and cached to disk, like the original)
    local logoUrl = opts.LogoUrl
    if logoUrl == nil then logoUrl = "https://raw.githubusercontent.com/AnxiumClient/png/main/photo_2026-09-13_13-05-41.jpg" end
    if logoUrl then
        local logoFile = opts.LogoFile or "Anxium_wm_logo.jpg"
        task.spawn(function()
            local asset = nil
            pcall(function()
                if typeof(getcustomasset) == "function" then
                    local onDisk = false
                    if typeof(isfile) == "function" then pcall(function() onDisk = isfile(logoFile) end) end
                    if not onDisk and typeof(writefile) == "function" then
                        local ok, body = pcall(function() return game:HttpGet(logoUrl) end)
                        if ok and body and #body > 0 then pcall(writefile, logoFile, body) end
                    end
                    local okA, a = pcall(function() return getcustomasset(logoFile) end)
                    if okA and a then asset = a end
                end
            end)
            if not asset then asset = logoUrl end
            if WM.Logo then WM.Logo.Image = tostring(asset) end
        end)
    end

    WM:UpdatePosition()
    task.defer(function() task.wait(0.1) pcall(function() WM:UpdatePosition() end) end)
    return WM
end

-- ════════════════════════════════════════════════════════════════════
--  Target HUD (avatar + name + health bar + info line)
-- ════════════════════════════════════════════════════════════════════
-- opts: Color (Color3), Position (UDim2)
function Library:CreateTargetHud(opts)
    opts = opts or {}
    local gui = self:_EnsureGui()
    local color = opts.Color or Color3.fromRGB(180, 140, 255)
    local HUD = { Visible = false, _tweens = {}, _thumbs = {}, _lastUserId = nil }

    local Frame = new("Frame", {
        Name = "AnxiumTargetHud", Size = UDim2.new(0, 240, 0, 78),
        Position = opts.Position or UDim2.new(0.5, 130, 0.5, 40),
        BackgroundColor3 = Theme.Bg, BackgroundTransparency = 1, BorderSizePixel = 0,
        Visible = false, ClipsDescendants = true,
    }, gui)
    local Stroke = stroke(Frame, color, 1, 1)
    corner(Frame, UDim.new(0, 12))
    self:MakeDraggable(Frame)

    local Avatar = new("ImageLabel", {
        Name = "TargetAvatar", Size = UDim2.new(0, 54, 0, 54), Position = UDim2.new(0, 12, 0.5, -27),
        BackgroundColor3 = Color3.fromRGB(40, 40, 50), BorderSizePixel = 0,
        ImageTransparency = 0, BackgroundTransparency = 0, ScaleType = Enum.ScaleType.Crop,
        ResampleMode = Enum.ResamplerMode.Pixelated, Image = "", ZIndex = 5, ClipsDescendants = true,
    }, Frame)
    corner(Avatar, UDim.new(0, 10))
    local AvatarStroke = stroke(Avatar, color, 1.5, 0.3)

    local NameLabel = label(Frame, {
        Name = "TargetName", Size = UDim2.new(1, -80, 0, 20), Position = UDim2.new(0, 76, 0, 12),
        Text = "Target", TextColor3 = Theme.Text, TextSize = 14, TextTransparency = 1,
    })
    local HealthBg = new("Frame", {
        Name = "HealthBg", Size = UDim2.new(1, -88, 0, 8), Position = UDim2.new(0, 76, 0, 38),
        BackgroundColor3 = Theme.BgTertiary, BorderSizePixel = 0, BackgroundTransparency = 1,
    }, Frame)
    corner(HealthBg, UDim.new(0, 4))
    local HealthFill = new("Frame", {
        Name = "HealthFill", Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0, BackgroundTransparency = 1,
    }, HealthBg)
    corner(HealthFill, UDim.new(0, 4))
    local HealthGrad = new("UIGradient", { Name = "HealthGrad", Rotation = 0 }, HealthFill)
    local InfoLabel = label(Frame, {
        Name = "TargetInfo", Size = UDim2.new(1, -88, 0, 16), Position = UDim2.new(0, 76, 0, 52),
        Text = "100 / 100  ·  0m", TextColor3 = Theme.TextDim, TextSize = 11, TextTransparency = 1,
    })

    local function gradFrom(a)
        local light = Color3.new(math.clamp(a.R + (1 - a.R) * 0.55, 0, 1), math.clamp(a.G + (1 - a.G) * 0.55, 0, 1), math.clamp(a.B + (1 - a.B) * 0.55, 0, 1))
        local dark = Color3.new(math.clamp(a.R * 0.35, 0, 1), math.clamp(a.G * 0.35, 0, 1), math.clamp(a.B * 0.35, 0, 1))
        return ColorSequence.new({
            ColorSequenceKeypoint.new(0, light), ColorSequenceKeypoint.new(0.5, a), ColorSequenceKeypoint.new(1, dark),
        })
    end
    function HUD:SetColor(c)
        Stroke.Color = c AvatarStroke.Color = c
        HealthGrad.Color = gradFrom(c)
        HealthFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    end
    HUD:SetColor(color)

    local function cancel()
        for _, tw in ipairs(HUD._tweens) do if tw then tw:Cancel() end end
        HUD._tweens = {}
    end

    function HUD:Show()
        if self.Visible then return end
        self.Visible = true
        cancel()
        Frame.Visible = true
        Frame.Size = UDim2.new(0, 228, 0, 72)
        Frame.BackgroundTransparency = 1
        Stroke.Transparency = 1
        Avatar.ImageTransparency = 1
        NameLabel.TextTransparency = 1
        InfoLabel.TextTransparency = 1
        HealthBg.BackgroundTransparency = 1
        HealthFill.BackgroundTransparency = 1
        local info = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        local t = self._tweens
        table.insert(t, TweenService:Create(Frame, info, { Size = UDim2.new(0, 240, 0, 78), BackgroundTransparency = 0.12 }))
        table.insert(t, TweenService:Create(Stroke, info, { Transparency = 0.35 }))
        table.insert(t, TweenService:Create(Avatar, info, { ImageTransparency = 0, BackgroundTransparency = 0 }))
        table.insert(t, TweenService:Create(NameLabel, info, { TextTransparency = 0 }))
        table.insert(t, TweenService:Create(InfoLabel, info, { TextTransparency = 0 }))
        table.insert(t, TweenService:Create(HealthBg, info, { BackgroundTransparency = 0 }))
        table.insert(t, TweenService:Create(HealthFill, info, { BackgroundTransparency = 0 }))
        for _, tw in ipairs(t) do tw:Play() end
        task.delay(0.35, function() if HUD.Visible then Avatar.ImageTransparency = 0 end end)
    end

    function HUD:Hide()
        if not self.Visible then return end
        self.Visible = false
        cancel()
        local info = TweenInfo.new(0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        local t = self._tweens
        table.insert(t, TweenService:Create(Frame, info, { BackgroundTransparency = 1 }))
        table.insert(t, TweenService:Create(Stroke, info, { Transparency = 1 }))
        table.insert(t, TweenService:Create(Avatar, info, { ImageTransparency = 1 }))
        table.insert(t, TweenService:Create(NameLabel, info, { TextTransparency = 1 }))
        table.insert(t, TweenService:Create(InfoLabel, info, { TextTransparency = 1 }))
        table.insert(t, TweenService:Create(HealthBg, info, { BackgroundTransparency = 1 }))
        table.insert(t, TweenService:Create(HealthFill, info, { BackgroundTransparency = 1 }))
        for _, tw in ipairs(t) do tw:Play() end
        task.delay(0.28, function()
            if not HUD.Visible then
                Frame.Visible = false
                Frame.Size = UDim2.new(0, 240, 0, 78)
            end
        end)
    end

    local function setAvatar(userId)
        userId = tonumber(userId) or userId
        if HUD._thumbs[userId] then Avatar.Image = HUD._thumbs[userId] Avatar.ImageTransparency = 0 return end
        local url = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=150&height=150&format=png"
        Avatar.Image = url
        Avatar.ImageTransparency = 0
        HUD._thumbs[userId] = url
        task.spawn(function()
            local ok, thumb = pcall(function()
                return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
            end)
            if ok and type(thumb) == "string" and #thumb > 0 then
                HUD._thumbs[userId] = thumb
                if HUD._lastUserId == userId then Avatar.Image = thumb Avatar.ImageTransparency = 0 end
            end
        end)
    end

    -- data = { Name=, Health=, MaxHealth=, Distance= (studs), UserId=, Info= (optional custom text) }
    function HUD:Update(data)
        data = data or {}
        if data.UserId and self._lastUserId ~= data.UserId then
            self._lastUserId = data.UserId
            setAvatar(data.UserId)
        end
        if data.Name then NameLabel.Text = tostring(data.Name) end
        local maxHp = math.max(data.MaxHealth or 100, 1)
        local hp = math.clamp(data.Health or maxHp, 0, maxHp)
        HealthFill.Size = UDim2.new(hp / maxHp, 0, 1, 0)
        InfoLabel.Text = data.Info or (math.floor(hp) .. " / " .. math.floor(maxHp) .. "  ·  " .. math.floor((data.Distance or 0) * 0.28) .. "m")
    end

    HUD.Frame = Frame
    self.TargetHud = HUD
    return HUD
end

-- ════════════════════════════════════════════════════════════════════
--  Config (flags <-> table / file)
-- ════════════════════════════════════════════════════════════════════
local function enc(v)
    if typeof(v) == "Color3" then return { __c = { v.R, v.G, v.B } } end
    return v
end
local function dec(v)
    if type(v) == "table" and v.__c then return Color3.new(v.__c[1], v.__c[2], v.__c[3]) end
    return v
end

function Library:GetConfig()
    local data = { Flags = {}, ToggleColors = {}, Keybinds = {}, Accent = enc(Theme.Accent), MenuKey = self.MenuKey }
    for flag, obj in pairs(self.Options) do
        if obj.Type ~= "Keybind" or not obj.Row then data.Flags[flag] = enc(obj.Value) end
        if obj.Type == "Toggle" and obj.Color then data.ToggleColors[flag] = enc(obj.Color) end
    end
    for flag, key in pairs(self.Keybinds) do data.Keybinds[flag] = key end
    return data
end

function Library:LoadConfig(data)
    if type(data) ~= "table" then return false end
    self._suppressNotify = true
    if data.Accent then self:SetAccent(dec(data.Accent), true) end
    for flag, v in pairs(data.Flags or {}) do
        local obj = self.Options[flag]
        if obj and obj.Set then pcall(function() obj:Set(dec(v)) end) end
    end
    for flag, v in pairs(data.ToggleColors or {}) do
        local obj = self.Options[flag]
        if obj and obj.SetColor then pcall(function() obj:SetColor(dec(v)) end) end
    end
    self.Keybinds = {}
    for flag, key in pairs(data.Keybinds or {}) do self.Keybinds[flag] = key end
    if data.MenuKey then
        self.MenuKey = data.MenuKey
        for _, kb in ipairs(self._keybindElems) do
            if kb.Row and kb.Row.Parent and kb.Name:lower():find("menu") then pcall(function() kb:Set(data.MenuKey, true) end) end
        end
    end
    self._suppressNotify = false
    self:RefreshBindKeyLabels()
    self:UpdateActiveList()
    self:UpdateBindList()
    return true
end

function Library:SaveConfig(path)
    if typeof(writefile) ~= "function" then return false end
    return pcall(writefile, path, HttpService:JSONEncode(self:GetConfig()))
end

function Library:LoadConfigFile(path)
    if typeof(readfile) ~= "function" then return false end
    local ok, body = pcall(readfile, path)
    if not ok then return false end
    local ok2, data = pcall(function() return HttpService:JSONDecode(body) end)
    if not ok2 then return false end
    return self:LoadConfig(data)
end

-- ════════════════════════════════════════════════════════════════════
--  Cleanup
-- ════════════════════════════════════════════════════════════════════
function Library:Unload()
    for _, c in ipairs(self._conns) do pcall(function() c:Disconnect() end) end
    self._conns = {}
    if self.ScreenGui then pcall(function() self.ScreenGui:Destroy() end) end
    if self.BlurEffect then pcall(function() self.BlurEffect:Destroy() end) end
    self.ScreenGui, self.BlurEffect, self.MainFrame = nil, nil, nil
end

return Library
