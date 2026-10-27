--[[
    Quantum Onyx UI Library  (QuantumOnyxUI.lua)
    โคลนจาก UI "Quantum Onyx Project" ในภาพ

    - หน้าต่างเลื่อนได้ (ลากที่ header), ปุ่ม Settings / Credits / ย่อ / ปิด
    - ช่องค้นหา (กรอง element ในแท็บปัจจุบัน)
    - แท็บแนวนอน (ไอคอน + ชื่อ) + ขีดไล่สีใต้แท็บที่เลือก
    - Section 2 คอลัมน์ (Left / Right) พร้อมหัวข้อมีแถบไล่สีสองข้าง
    - Element: Toggle (มี Description ได้), Button, Slider (ช่องพิมพ์ค่าได้),
               Dropdown (Single / Multi), Paragraph, Label, Input

    ใช้งาน:
        local Library = loadstring(readfile("QuantumOnyxUI.lua"))()
        local Window  = Library:CreateWindow({ Name = "...", Subtitle = "..." })
        local Tab     = Window:CreateTab({ Name = "Home", Icon = "⌂" })
        local Sec     = Tab:CreateSection({ Name = "Magnet Event", Side = "Left" })
        Sec:AddToggle({ Name = "Auto Farm", Callback = function(v) end })

    Icon: ใส่เป็นตัวอักษร/สัญลักษณ์ ("⌂") หรือ asset id ("rbxassetid://123") ก็ได้
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local CoreGui = game:GetService("CoreGui")

local Library = { Flags = {}, Version = "1.0.0" }

----------------------------------------------------------------------
-- Theme (สีวัดจากภาพ)
----------------------------------------------------------------------
local Theme = {
    Window = Color3.fromRGB(10, 9, 17),
    WindowStroke = Color3.fromRGB(36, 29, 66),
    Panel = Color3.fromRGB(14, 12, 22),
    Card = Color3.fromRGB(19, 16, 28),
    CardHover = Color3.fromRGB(24, 21, 36),
    Input = Color3.fromRGB(21, 17, 40),
    InputStroke = Color3.fromRGB(46, 37, 98),

    HeaderButton = Color3.fromRGB(19, 14, 44),
    HeaderButtonHover = Color3.fromRGB(27, 20, 62),
    HeaderButtonStroke = Color3.fromRGB(84, 60, 196),
    AccentBlue = Color3.fromRGB(66, 88, 255),

    Purple = Color3.fromRGB(126, 108, 250),
    TabIdle = Color3.fromRGB(112, 98, 184),
    Accent = Color3.fromRGB(112, 82, 228),
    AccentLight = Color3.fromRGB(152, 128, 240),
    AccentDark = Color3.fromRGB(92, 68, 190),

    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(146, 141, 160),
    TextMuted = Color3.fromRGB(104, 99, 120),
    Subtitle = Color3.fromRGB(150, 74, 112),

    ToggleOff = Color3.fromRGB(24, 21, 35),
    ToggleStroke = Color3.fromRGB(38, 33, 54),
    Knob = Color3.fromRGB(158, 158, 166),
    Track = Color3.fromRGB(29, 25, 45),

    BarA = Color3.fromRGB(46, 25, 132),
    BarB = Color3.fromRGB(76, 70, 236),
}
Library.Theme = Theme

local FONT_BOLD = Enum.Font.GothamBold
local FONT_MED = Enum.Font.GothamMedium

----------------------------------------------------------------------
-- Utilities
----------------------------------------------------------------------
local function create(class, props, children)
    local inst = Instance.new(class)
    local parent
    for k, v in pairs(props or {}) do
        if k == "Parent" then
            parent = v
        else
            inst[k] = v
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    inst.Parent = parent
    return inst
end

local function corner(radius)
    return create("UICorner", { CornerRadius = UDim.new(0, radius) })
end

local function stroke(color, thickness, transparency)
    return create("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function tween(inst, props, t)
    local tw = TweenService:Create(inst, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local function label(props)
    local base = {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Font = FONT_MED,
        TextSize = 12,
        TextColor3 = Theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Text = "",
    }
    for k, v in pairs(props) do
        base[k] = v
    end
    return create("TextLabel", base)
end

local function makeIcon(icon, size, color, props)
    local obj
    local asset
    if type(icon) == "number" then
        asset = "rbxassetid://" .. icon
    elseif type(icon) == "string" and (icon:find("rbxassetid://") or icon:find("rbxasset://") or icon:match("^%d+$")) then
        asset = icon:match("^%d+$") and ("rbxassetid://" .. icon) or icon
    end
    if asset then
        obj = create("ImageLabel", {
            BackgroundTransparency = 1,
            Image = asset,
            ImageColor3 = color,
            Size = UDim2.fromOffset(size, size),
        })
    else
        obj = create("TextLabel", {
            BackgroundTransparency = 1,
            Text = tostring(icon or ""),
            TextColor3 = color,
            Font = FONT_BOLD,
            TextSize = size,
            Size = UDim2.fromOffset(size, size),
        })
    end
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

local function textWidth(text, size, font)
    local ok, v = pcall(function()
        return TextService:GetTextSize(text, size, font, Vector2.new(1000, 100)).X
    end)
    return ok and v or (#text * size * 0.58)
end

local function fmt(v)
    if math.abs(v - math.floor(v + 0.5)) < 1e-6 then
        return tostring(math.floor(v + 0.5))
    end
    local s = string.format("%.2f", v)
    s = s:gsub("0+$", ""):gsub("%.$", "")
    return s
end

local function fire(cb, ...)
    if type(cb) == "function" then
        local args = table.pack(...)
        task.spawn(function()
            local ok, err = pcall(cb, table.unpack(args, 1, args.n))
            if not ok then
                warn("[QuantumOnyxUI] callback error: " .. tostring(err))
            end
        end)
    end
end

local function getParent()
    local ok, result = pcall(function()
        if gethui then
            return gethui()
        end
        return CoreGui
    end)
    if ok and result then
        return result
    end
    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function isPointer(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

local function isMove(input)
    return input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
end

----------------------------------------------------------------------
-- Classes
----------------------------------------------------------------------
local Window = {}
Window.__index = Window
local Tab = {}
Tab.__index = Tab
local Section = {}
Section.__index = Section

function Window:_track(conn)
    table.insert(self.Connections, conn)
    return conn
end

function Window:_makeDraggable(handle, target)
    local dragging, dragStart, startPos = false, nil, nil
    self:_track(handle.InputBegan:Connect(function(input)
        if isPointer(input) then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end))
    self:_track(UserInputService.InputChanged:Connect(function(input)
        if dragging and isMove(input) then
            local s = (self.UIScale and self.UIScale.Scale) or 1
            local d = (input.Position - dragStart) / s
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end))
end

----------------------------------------------------------------------
-- Column (2 คอลัมน์ต่อแท็บ)
----------------------------------------------------------------------
local function makeColumn(parent, side)
    local col = create("ScrollingFrame", {
        Name = side,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.AccentDark,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Parent = parent,
    })
    if side == "Left" then
        col.Position = UDim2.fromOffset(11, 0)
        col.Size = UDim2.new(0.5, -27, 1, 0)
    else
        col.Position = UDim2.new(0.5, 16, 0, 0)
        col.Size = UDim2.new(0.5, -27, 1, 0)
    end
    create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = col })
    create("UIPadding", { PaddingBottom = UDim.new(0, 10), Parent = col })
    return col
end

----------------------------------------------------------------------
-- Library:CreateWindow
----------------------------------------------------------------------
function Library:CreateWindow(cfg)
    cfg = cfg or {}
    local self = setmetatable({}, Window)
    self.Tabs = {}
    self.Connections = {}
    self.CurrentTab = nil
    self.ToggleKey = cfg.ToggleKey or Enum.KeyCode.RightControl

    local W, H = 560, 360

    local parent = getParent()
    local old = parent:FindFirstChild("QuantumOnyxUI")
    if old then
        old:Destroy()
    end

    local gui = create("ScreenGui", {
        Name = "QuantumOnyxUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        DisplayOrder = 999,
    })
    gui.Parent = parent
    self.Gui = gui

    local main = create("Frame", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(W, H),
        BackgroundColor3 = Theme.Window,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = gui,
    }, { corner(10), stroke(Theme.WindowStroke, 1) })
    self.Main = main

    local uiScale = create("UIScale", { Parent = main })
    self.UIScale = uiScale
    local function updateScale()
        local cam = workspace.CurrentCamera
        if not cam then
            return
        end
        local vp = cam.ViewportSize
        local auto = math.clamp(math.min((vp.X - 24) / W, (vp.Y - 24) / H), 0.45, 1.3)
        uiScale.Scale = self.ScaleOverride or auto
    end
    self._updateScale = updateScale
    updateScale()
    if workspace.CurrentCamera then
        self:_track(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale))
    end

    ------------------------------------------------------------------
    -- Header
    ------------------------------------------------------------------
    local header = create("Frame", {
        Name = "Header",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 34),
        Parent = main,
    })

    self.TitleLabel = label({
        Parent = header,
        Text = cfg.Name or "Quantum Onyx Project",
        Font = FONT_BOLD,
        TextSize = 12,
        TextColor3 = Theme.Text,
        Position = UDim2.fromOffset(13, 4),
        Size = UDim2.new(1, -250, 0, 14),
    })
    self.SubtitleLabel = label({
        Parent = header,
        Text = cfg.Subtitle or "",
        Font = FONT_MED,
        TextSize = 9,
        TextColor3 = Theme.Subtitle,
        Position = UDim2.fromOffset(13, 20),
        Size = UDim2.new(1, -250, 0, 11),
    })

    local function headerButton(name, icon, rightOffset)
        local btn = create("TextButton", {
            Name = name,
            Text = "",
            AutoButtonColor = false,
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -rightOffset, 0, 4),
            Size = UDim2.fromOffset(93, 27),
            BackgroundColor3 = Theme.HeaderButton,
            BorderSizePixel = 0,
            Parent = header,
        }, { corner(6), stroke(Theme.HeaderButtonStroke, 1) })
        create("Frame", {
            Name = "Accent",
            BackgroundColor3 = Theme.AccentBlue,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(3, 5),
            Size = UDim2.new(0, 2, 1, -10),
            Parent = btn,
        }, { corner(2) })
        makeIcon(icon, 11, Theme.Purple, {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, 18, 0.5, 0),
            Parent = btn,
        })
        label({
            Parent = btn,
            Text = name,
            Font = FONT_BOLD,
            TextSize = 9,
            TextColor3 = Theme.Purple,
            Position = UDim2.fromOffset(31, 0),
            Size = UDim2.new(1, -34, 1, 0),
        })
        btn.MouseEnter:Connect(function()
            tween(btn, { BackgroundColor3 = Theme.HeaderButtonHover }, 0.12)
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, { BackgroundColor3 = Theme.HeaderButton }, 0.12)
        end)
        return btn
    end

    local icons = cfg.Icons or {}
    local settingsBtn = headerButton("Settings", icons.Settings or "⚙", 169)
    local creditsBtn = headerButton("Credits", icons.Credits or "☺", 69)

    -- ปุ่มย่อ (ลูกศรสองหัว)
    local minBtn = create("TextButton", {
        Name = "Minimize",
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, -51, 0, 17),
        Size = UDim2.fromOffset(24, 24),
        Parent = header,
    })
    for _, a in ipairs({ { "↙", 11, 1 }, { "↗", 1, 11 } }) do
        label({
            Parent = minBtn,
            Text = a[1],
            Font = FONT_BOLD,
            TextSize = 13,
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Center,
            Position = UDim2.fromOffset(a[2], a[3]),
            Size = UDim2.fromOffset(12, 12),
        })
    end

    -- ปุ่มปิด (X)
    local closeBtn = create("TextButton", {
        Name = "Close",
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, -22, 0, 17),
        Size = UDim2.fromOffset(24, 24),
        Parent = header,
    })
    for _, rot in ipairs({ 45, -45 }) do
        create("Frame", {
            BackgroundColor3 = Theme.Text,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(14, 2),
            Rotation = rot,
            Parent = closeBtn,
        }, { corner(1) })
    end

    self:_makeDraggable(header, main)

    ------------------------------------------------------------------
    -- Search
    ------------------------------------------------------------------
    local searchFrame = create("Frame", {
        Name = "Search",
        BackgroundColor3 = Theme.Input,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(11, 37),
        Size = UDim2.fromOffset(140, 30),
        Parent = main,
    }, { corner(8) })

    -- ไอคอนแว่นขยาย (วาดเอง)
    create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(13, 9),
        Size = UDim2.fromOffset(9, 9),
        Parent = searchFrame,
    }, {
        corner(5),
        create("UIStroke", { Color = Theme.Purple, Thickness = 1.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }),
    })
    create("Frame", {
        BackgroundColor3 = Theme.Purple,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(23, 19),
        Size = UDim2.fromOffset(6, 2),
        Rotation = 45,
        Parent = searchFrame,
    }, { corner(1) })

    local searchBox = create("TextBox", {
        Name = "Box",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(32, 0),
        Size = UDim2.new(1, -38, 1, 0),
        Font = FONT_MED,
        TextSize = 9,
        TextColor3 = Theme.Text,
        PlaceholderText = "Search...",
        PlaceholderColor3 = Color3.fromRGB(92, 84, 125),
        Text = "",
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = searchFrame,
    })
    self.SearchBox = searchBox
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        if self.CurrentTab then
            self.CurrentTab:_applySearch(searchBox.Text)
        end
    end)

    ------------------------------------------------------------------
    -- Tab bar + Pages
    ------------------------------------------------------------------
    local tabBar = create("ScrollingFrame", {
        Name = "Tabs",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(154, 35),
        Size = UDim2.new(1, -162, 0, 30),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        ScrollingDirection = Enum.ScrollingDirection.X,
        ScrollBarThickness = 0,
        ClipsDescendants = true,
        Parent = main,
    })
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 13),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabBar,
    })
    create("UIPadding", { PaddingLeft = UDim.new(0, 5), Parent = tabBar })
    tabBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseWheel then
            tabBar.CanvasPosition = Vector2.new(math.max(0, tabBar.CanvasPosition.X - input.Position.Z * 40), 0)
        end
    end)
    self.TabBar = tabBar

    self.Pages = create("Frame", {
        Name = "Pages",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 74),
        Size = UDim2.new(1, 0, 1, -74),
        ClipsDescendants = true,
        Parent = main,
    })

    ------------------------------------------------------------------
    -- ปุ่มลอย (ตอนย่อหน้าต่าง)
    ------------------------------------------------------------------
    local float = create("TextButton", {
        Name = "Float",
        Text = "Q",
        Font = FONT_BOLD,
        TextSize = 18,
        TextColor3 = Theme.Purple,
        AutoButtonColor = false,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 12),
        Size = UDim2.fromOffset(40, 40),
        BackgroundColor3 = Theme.Window,
        BorderSizePixel = 0,
        Visible = false,
        Parent = gui,
    }, { corner(20), stroke(Theme.HeaderButtonStroke, 1.5) })
    self.Float = float
    self:_makeDraggable(float, float)
    float.MouseButton1Click:Connect(function()
        self:Toggle(true)
    end)

    minBtn.MouseButton1Click:Connect(function()
        self:Toggle(false)
    end)
    closeBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)

    self:_track(UserInputService.InputBegan:Connect(function(input, processed)
        if processed then
            return
        end
        if input.KeyCode == self.ToggleKey then
            self:Toggle()
        end
    end))

    ------------------------------------------------------------------
    -- Settings / Credits (แท็บซ่อน เปิดด้วยปุ่มบน header)
    ------------------------------------------------------------------
    self.SettingsTab = self:_newTab({ Name = "Settings" }, true)
    self.CreditsTab = self:_newTab({ Name = "Credits" }, true)

    local function openSpecial(tab)
        if self.CurrentTab == tab then
            self:_select(self.Tabs[1])
        else
            self:_select(tab)
        end
    end
    settingsBtn.MouseButton1Click:Connect(function()
        openSpecial(self.SettingsTab)
    end)
    creditsBtn.MouseButton1Click:Connect(function()
        openSpecial(self.CreditsTab)
    end)

    local ui = self.SettingsTab:CreateSection({ Name = "Interface", Side = "Left" })
    ui:AddSlider({
        Name = "UI Scale",
        Min = 50,
        Max = 130,
        Default = 100,
        Increment = 5,
        Callback = function(v)
            self.ScaleOverride = v / 100
            updateScale()
        end,
    })
    ui:AddButton({
        Name = "Unload UI",
        Callback = function()
            self:Destroy()
        end,
    })
    local info = self.SettingsTab:CreateSection({ Name = "Info", Side = "Right" })
    info:AddParagraph({ Title = "Toggle Key", Content = self.ToggleKey.Name })

    local credits = self.CreditsTab:CreateSection({ Name = "Credits", Side = "Left" })
    local list = cfg.Credits or { { Name = cfg.Name or "Quantum Onyx Project", Role = "Made with QuantumOnyxUI" } }
    for _, c in ipairs(list) do
        credits:AddParagraph({ Title = c.Name or "", Content = c.Role or "" })
    end

    table.insert(Library, self)
    return self
end

----------------------------------------------------------------------
-- Window methods
----------------------------------------------------------------------
function Window:Toggle(state)
    if state == nil then
        state = not self.Main.Visible
    end
    self.Main.Visible = state
    self.Float.Visible = not state
end

function Window:SetTitle(text)
    self.TitleLabel.Text = text
end

function Window:SetSubtitle(text)
    self.SubtitleLabel.Text = text
end

function Window:Destroy()
    for _, c in ipairs(self.Connections) do
        pcall(function()
            c:Disconnect()
        end)
    end
    self.Connections = {}
    if self.Gui then
        self.Gui:Destroy()
    end
end

function Window:_select(tab)
    if not tab or self.CurrentTab == tab then
        return
    end
    if self.CurrentTab then
        self.CurrentTab:_setActive(false)
    end
    self.CurrentTab = tab
    tab:_setActive(true)
    tab:_applySearch(self.SearchBox.Text)
end

function Window:CreateTab(cfg)
    if type(cfg) == "string" then
        cfg = { Name = cfg }
    end
    return self:_newTab(cfg or {}, false)
end

function Window:_newTab(cfg, hidden)
    local tab = setmetatable({}, Tab)
    tab.Window = self
    tab.Name = cfg.Name or "Tab"
    tab.Sections = {}
    tab._order = { Left = 0, Right = 0 }

    tab.Page = create("Frame", {
        Name = tab.Name,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Visible = false,
        Parent = self.Pages,
    })
    tab.Left = makeColumn(tab.Page, "Left")
    tab.Right = makeColumn(tab.Page, "Right")

    if not hidden then
        local width = 31 + textWidth(tab.Name, 12, FONT_BOLD) + 4
        local btn = create("TextButton", {
            Name = tab.Name,
            Text = "",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(width, 30),
            LayoutOrder = #self.Tabs + 1,
            Parent = self.TabBar,
        })
        makeIcon(cfg.Icon or "•", 15, Theme.Purple, {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 0, 0, 14),
            Parent = btn,
        })
        tab.Label = label({
            Parent = btn,
            Text = tab.Name,
            Font = FONT_BOLD,
            TextSize = 12,
            TextColor3 = Theme.TabIdle,
            Position = UDim2.fromOffset(31, 0),
            Size = UDim2.new(1, -31, 0, 28),
        })
        tab.Pill = create("Frame", {
            Name = "Pill",
            AnchorPoint = Vector2.new(0.5, 1),
            Position = UDim2.new(0.5, 0, 0, 28),
            Size = UDim2.fromOffset(0, 3),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = btn,
        }, {
            corner(2),
            create("UIGradient", {
                Color = ColorSequence.new(Color3.fromRGB(76, 52, 206), Color3.fromRGB(150, 126, 255)),
            }),
        })
        tab.Button = btn
        btn.MouseButton1Click:Connect(function()
            self:_select(tab)
        end)
        table.insert(self.Tabs, tab)
        if not self.CurrentTab then
            self:_select(tab)
        end
    end
    return tab
end

----------------------------------------------------------------------
-- Tab methods
----------------------------------------------------------------------
function Tab:_setActive(active)
    self.Page.Visible = active
    if self.Label then
        tween(self.Label, { TextColor3 = active and Theme.Text or Theme.TabIdle }, 0.18)
        tween(self.Pill, {
            BackgroundTransparency = active and 0 or 1,
            Size = UDim2.fromOffset(active and 40 or 0, 3),
        }, 0.2)
    end
end

function Tab:_applySearch(query)
    query = (query or ""):lower()
    for _, sec in ipairs(self.Sections) do
        local any = false
        for _, el in ipairs(sec.Elements) do
            local match = query == "" or el.Name:lower():find(query, 1, true) ~= nil
            el.Card.Visible = match
            if match then
                any = true
            end
        end
        sec.Holder.Visible = query == "" or any or #sec.Elements == 0
    end
end

function Tab:CreateSection(cfg)
    if type(cfg) == "string" then
        cfg = { Name = cfg }
    end
    cfg = cfg or {}
    local sideName = (cfg.Side == "Right") and "Right" or "Left"
    local column = self[sideName]
    self._order[sideName] = self._order[sideName] + 1

    local sec = setmetatable({}, Section)
    sec.Tab = self
    sec.Name = cfg.Name or "Section"
    sec.Elements = {}
    sec._order = 1

    sec.Holder = create("Frame", {
        Name = sec.Name,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = self._order[sideName],
        Parent = column,
    })
    create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = sec.Holder })

    -- หัวข้อ: [แถบ]  ชื่อ  [แถบ]
    local head = create("Frame", {
        Name = "Head",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 28),
        LayoutOrder = 1,
        Parent = sec.Holder,
    })
    local function bar(anchorX)
        create("Frame", {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(anchorX, 0.5),
            Position = UDim2.new(anchorX, 0, 0.5, 0),
            Size = UDim2.fromOffset(50, 10),
            Parent = head,
        }, {
            corner(5),
            create("UIGradient", { Color = ColorSequence.new(Theme.BarA, Theme.BarB) }),
        })
    end
    bar(0)
    bar(1)
    label({
        Parent = head,
        Text = sec.Name,
        Font = FONT_BOLD,
        TextSize = 14,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Center,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, -120, 1, 0),
    })

    sec.Body = create("Frame", {
        Name = "Body",
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 2,
        Parent = sec.Holder,
    }, { corner(8) })
    create("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        Parent = sec.Body,
    })
    create("UIListLayout", { Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder, Parent = sec.Body })

    table.insert(self.Sections, sec)
    return sec
end

----------------------------------------------------------------------
-- Section helpers
----------------------------------------------------------------------
function Section:_card(height, searchText)
    local card = create("Frame", {
        Name = "Card",
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, height or 30),
        LayoutOrder = self._order,
        Parent = self.Body,
    }, { corner(7) })
    self._order = self._order + 1
    table.insert(self.Elements, { Name = searchText or "", Card = card })
    return card
end

local function overlayButton(card)
    local btn = create("TextButton", {
        Name = "Hit",
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 5,
        Parent = card,
    })
    btn.MouseEnter:Connect(function()
        tween(card, { BackgroundColor3 = Theme.CardHover }, 0.12)
    end)
    btn.MouseLeave:Connect(function()
        tween(card, { BackgroundColor3 = Theme.Card }, 0.12)
    end)
    return btn
end

----------------------------------------------------------------------
-- Toggle
----------------------------------------------------------------------
function Section:AddToggle(cfg)
    cfg = cfg or {}
    local name = cfg.Name or "Toggle"
    local desc = cfg.Description
    local hasDesc = type(desc) == "string" and desc ~= ""
    local card = self:_card(30, name .. " " .. (hasDesc and desc or ""))
    card.AutomaticSize = Enum.AutomaticSize.Y

    local content = create("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -55, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = card,
    })
    create("UIPadding", {
        PaddingTop = UDim.new(0, 7),
        PaddingBottom = UDim.new(0, hasDesc and 9 or 7),
        PaddingLeft = UDim.new(0, 12),
        Parent = content,
    })
    create("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder, Parent = content })

    local title = label({
        Parent = content,
        Text = name,
        TextSize = cfg.TextSize or (hasDesc and 13 or 12),
        TextColor3 = Theme.TextDim,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        TextWrapped = true,
        LayoutOrder = 1,
    })
    if hasDesc then
        label({
            Parent = content,
            Text = desc,
            TextSize = 9,
            TextColor3 = Theme.TextMuted,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            TextWrapped = true,
            TextYAlignment = Enum.TextYAlignment.Top,
            LineHeight = 1.15,
            LayoutOrder = 2,
        })
    end

    local switch = create("Frame", {
        Name = "Switch",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(42, 24),
        BackgroundColor3 = Theme.ToggleOff,
        BorderSizePixel = 0,
        Parent = card,
    }, { corner(12), stroke(Theme.ToggleStroke, 1) })
    local knob = create("Frame", {
        Name = "Knob",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 4, 0.5, 0),
        Size = UDim2.fromOffset(16, 16),
        BackgroundColor3 = Theme.Knob,
        BorderSizePixel = 0,
        Parent = switch,
    }, { corner(8) })

    local obj = { Name = name, Value = cfg.Default == true }
    local function render(animate)
        local t = animate and 0.16 or 0
        local on = obj.Value
        tween(switch, { BackgroundColor3 = on and Theme.Accent or Theme.ToggleOff }, t)
        tween(knob, {
            Position = on and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 4, 0.5, 0),
            BackgroundColor3 = on and Color3.new(1, 1, 1) or Theme.Knob,
        }, t)
        tween(title, { TextColor3 = on and Theme.Text or Theme.TextDim }, t)
    end

    function obj:Set(value, silent)
        self.Value = value and true or false
        if cfg.Flag then
            Library.Flags[cfg.Flag] = self.Value
        end
        render(true)
        if not silent then
            fire(cfg.Callback, self.Value)
        end
    end
    function obj:Get()
        return self.Value
    end

    overlayButton(card).MouseButton1Click:Connect(function()
        obj:Set(not obj.Value)
    end)

    if cfg.Flag then
        Library.Flags[cfg.Flag] = obj.Value
    end
    render(false)
    if obj.Value then
        fire(cfg.Callback, true)
    end
    return obj
end

----------------------------------------------------------------------
-- Button
----------------------------------------------------------------------
function Section:AddButton(cfg)
    if type(cfg) == "string" then
        cfg = { Name = cfg }
    end
    cfg = cfg or {}
    local name = cfg.Name or "Button"
    local card = self:_card(32, name)

    label({
        Parent = card,
        Text = name,
        Font = FONT_BOLD,
        TextSize = 14,
        TextColor3 = Theme.Text,
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -44, 1, 0),
    })
    label({
        Parent = card,
        Text = "›",
        Font = FONT_BOLD,
        TextSize = 16,
        TextColor3 = Color3.fromRGB(190, 185, 210),
        TextXAlignment = Enum.TextXAlignment.Center,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, -1),
        Size = UDim2.fromOffset(12, 16),
    })

    local hit = overlayButton(card)
    hit.MouseButton1Click:Connect(function()
        tween(card, { BackgroundColor3 = Theme.InputStroke }, 0.08)
        task.delay(0.1, function()
            if card.Parent then
                tween(card, { BackgroundColor3 = Theme.CardHover }, 0.15)
            end
        end)
        fire(cfg.Callback)
    end)
    return { Name = name }
end

----------------------------------------------------------------------
-- Slider
----------------------------------------------------------------------
function Section:AddSlider(cfg)
    cfg = cfg or {}
    local name = cfg.Name or "Slider"
    local min, max = cfg.Min or 0, cfg.Max or 100
    local inc = cfg.Increment or 1
    local value = math.clamp(cfg.Default or min, min, max)
    local card = self:_card(57, name)
    local win = self.Tab.Window

    label({
        Parent = card,
        Text = name,
        Font = FONT_BOLD,
        TextSize = 14,
        TextColor3 = Theme.Text,
        Position = UDim2.fromOffset(12, 9),
        Size = UDim2.new(1, -90, 0, 16),
    })

    local box = create("Frame", {
        Name = "ValueBox",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -10, 0, 3),
        Size = UDim2.fromOffset(52, 25),
        BackgroundColor3 = Theme.Input,
        BorderSizePixel = 0,
        Parent = card,
    }, { corner(6), stroke(Theme.InputStroke, 1) })
    local input = create("TextBox", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Font = FONT_MED,
        TextSize = 11,
        TextColor3 = Theme.Purple,
        Text = fmt(value),
        ClearTextOnFocus = false,
        Parent = box,
    })

    local track = create("Frame", {
        Name = "Track",
        Position = UDim2.fromOffset(11, 35),
        Size = UDim2.new(1, -22, 0, 10),
        BackgroundColor3 = Theme.Track,
        BorderSizePixel = 0,
        Parent = card,
    }, { corner(5) })
    local fill = create("Frame", {
        Name = "Fill",
        Size = UDim2.new(0, 8, 1, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = track,
    }, {
        corner(5),
        create("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(96, 68, 190), Color3.fromRGB(152, 128, 238)) }),
    })
    local knob = create("Frame", {
        Name = "Knob",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 8, 0.5, 0),
        Size = UDim2.fromOffset(16, 16),
        BackgroundColor3 = Color3.fromRGB(226, 218, 255),
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = track,
    }, { corner(8) })
    create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(7, 7),
        BackgroundColor3 = Color3.fromRGB(122, 92, 232),
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = knob,
    }, { corner(4) })

    local obj = { Name = name }
    local function snap(v)
        v = math.floor((v - min) / inc + 0.5) * inc + min
        v = tonumber(string.format("%.6f", v))
        return math.clamp(v, min, max)
    end
    local function render()
        local pct = (max == min) and 0 or (value - min) / (max - min)
        fill.Size = UDim2.new(pct, 8 - 16 * pct, 1, 0)
        knob.Position = UDim2.new(pct, 8 - 16 * pct, 0.5, 0)
        input.Text = fmt(value)
    end
    function obj:Set(v, silent)
        value = snap(tonumber(v) or value)
        if cfg.Flag then
            Library.Flags[cfg.Flag] = value
        end
        render()
        if not silent then
            fire(cfg.Callback, value)
        end
    end
    function obj:Get()
        return value
    end

    local hit = create("TextButton", {
        Name = "Hit",
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(6, 27),
        Size = UDim2.new(1, -12, 0, 26),
        ZIndex = 5,
        Parent = card,
    })
    local dragging = false
    local function update(x)
        local r = knob.AbsoluteSize.X / 2
        local w = track.AbsoluteSize.X - 2 * r
        if w <= 0 then
            return
        end
        local pct = math.clamp((x - track.AbsolutePosition.X - r) / w, 0, 1)
        obj:Set(min + pct * (max - min))
    end
    local scroller
    hit.InputBegan:Connect(function(i)
        if isPointer(i) then
            dragging = true
            scroller = card:FindFirstAncestorOfClass("ScrollingFrame")
            if scroller then
                scroller.ScrollingEnabled = false
            end
            update(i.Position.X)
        end
    end)
    win:_track(UserInputService.InputEnded:Connect(function(i)
        if dragging and isPointer(i) then
            dragging = false
            if scroller then
                scroller.ScrollingEnabled = true
            end
        end
    end))
    win:_track(UserInputService.InputChanged:Connect(function(i)
        if dragging and isMove(i) then
            update(i.Position.X)
        end
    end))
    input.FocusLost:Connect(function()
        local n = tonumber(input.Text)
        if n then
            obj:Set(n)
        else
            input.Text = fmt(value)
        end
    end)

    if cfg.Flag then
        Library.Flags[cfg.Flag] = value
    end
    render()
    return obj
end

----------------------------------------------------------------------
-- Dropdown (Single / Multi)
----------------------------------------------------------------------
function Section:AddDropdown(cfg)
    cfg = cfg or {}
    local name = cfg.Name or "Dropdown"
    local options = cfg.Options or {}
    local multi = cfg.Multi == true
    local selected
    if multi then
        selected = {}
        if type(cfg.Default) == "table" then
            for _, v in ipairs(cfg.Default) do
                selected[v] = true
            end
        end
    else
        selected = type(cfg.Default) == "string" and cfg.Default or nil
    end

    local card = self:_card(36, name)
    card.AutomaticSize = Enum.AutomaticSize.Y
    create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = card })

    local headerRow = create("Frame", {
        Name = "Row",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 1,
        Parent = card,
    })
    create("UIPadding", {
        PaddingTop = UDim.new(0, 7),
        PaddingBottom = UDim.new(0, 7),
        PaddingLeft = UDim.new(0, 12),
        Parent = headerRow,
    })
    label({
        Parent = headerRow,
        Text = name,
        Font = FONT_BOLD,
        TextSize = 14,
        TextColor3 = Theme.Text,
        TextWrapped = true,
        Size = UDim2.new(1, -104, 0, 22),
        AutomaticSize = Enum.AutomaticSize.Y,
    })

    local chip = create("Frame", {
        Name = "Chip",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -26, 0.5, 0),
        Size = UDim2.fromOffset(76, 25),
        BackgroundColor3 = Theme.Input,
        BorderSizePixel = 0,
        Parent = headerRow,
    }, { corner(5), stroke(Color3.fromRGB(62, 46, 150), 1) })
    local chipLabel = label({
        Parent = chip,
        Font = FONT_MED,
        TextSize = 10,
        TextColor3 = Theme.Purple,
        TextWrapped = true,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Center,
        Position = UDim2.fromOffset(3, 0),
        Size = UDim2.new(1, -6, 1, 0),
    })
    local arrow = label({
        Parent = headerRow,
        Text = "▾",
        Font = FONT_BOLD,
        TextSize = 12,
        TextColor3 = Theme.Purple,
        TextXAlignment = Enum.TextXAlignment.Center,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
    })

    local optionsFrame = create("Frame", {
        Name = "Options",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = false,
        LayoutOrder = 2,
        Parent = card,
    })
    create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = optionsFrame })
    create("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        Parent = optionsFrame,
    })

    local obj = { Name = name }
    local open = false

    local function chipText()
        if multi then
            local list = {}
            for _, o in ipairs(options) do
                if selected[o] then
                    table.insert(list, o)
                end
            end
            return #list > 0 and table.concat(list, ", ") or "None"
        end
        return selected or "None"
    end

    local function result()
        if multi then
            local list = {}
            for _, o in ipairs(options) do
                if selected[o] then
                    table.insert(list, o)
                end
            end
            return list
        end
        return selected
    end

    local buttons = {}
    local function renderOptions()
        chipLabel.Text = chipText()
        for o, b in pairs(buttons) do
            local on = multi and selected[o] or (not multi and selected == o)
            b.TextColor3 = on and Theme.Purple or Theme.TextDim
            b.BackgroundColor3 = on and Color3.fromRGB(30, 24, 56) or Theme.Input
        end
    end

    local function build()
        for _, b in pairs(buttons) do
            b:Destroy()
        end
        buttons = {}
        for i, o in ipairs(options) do
            local b = create("TextButton", {
                Name = tostring(o),
                Text = tostring(o),
                Font = FONT_MED,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
                BackgroundColor3 = Theme.Input,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 24),
                LayoutOrder = i,
                Parent = optionsFrame,
            }, { corner(5), create("UIPadding", { PaddingLeft = UDim.new(0, 8) }) })
            buttons[o] = b
            b.MouseButton1Click:Connect(function()
                if multi then
                    selected[o] = not selected[o] or nil
                else
                    selected = o
                    open = false
                    optionsFrame.Visible = false
                    arrow.Rotation = 0
                end
                if cfg.Flag then
                    Library.Flags[cfg.Flag] = result()
                end
                renderOptions()
                fire(cfg.Callback, result())
            end)
        end
        renderOptions()
    end

    function obj:Set(v, silent)
        if multi then
            selected = {}
            for _, o in ipairs(type(v) == "table" and v or {}) do
                selected[o] = true
            end
        else
            selected = v
        end
        if cfg.Flag then
            Library.Flags[cfg.Flag] = result()
        end
        renderOptions()
        if not silent then
            fire(cfg.Callback, result())
        end
    end
    function obj:Get()
        return result()
    end
    function obj:Refresh(newOptions, keep)
        options = newOptions or {}
        if not keep then
            selected = multi and {} or nil
        end
        build()
    end

    local hit = create("TextButton", {
        Name = "Hit",
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -12, 0, -7),
        Size = UDim2.new(1, 12, 1, 14),
        ZIndex = 5,
        Parent = headerRow,
    })
    hit.MouseButton1Click:Connect(function()
        open = not open
        optionsFrame.Visible = open
        arrow.Rotation = open and 180 or 0
    end)
    hit.MouseEnter:Connect(function()
        tween(card, { BackgroundColor3 = Theme.CardHover }, 0.12)
    end)
    hit.MouseLeave:Connect(function()
        tween(card, { BackgroundColor3 = Theme.Card }, 0.12)
    end)

    build()
    if cfg.Flag then
        Library.Flags[cfg.Flag] = result()
    end
    return obj
end

----------------------------------------------------------------------
-- Paragraph
----------------------------------------------------------------------
function Section:AddParagraph(cfg)
    cfg = cfg or {}
    local card = self:_card(30, (cfg.Title or "") .. " " .. (cfg.Content or ""))
    card.AutomaticSize = Enum.AutomaticSize.Y

    local content = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = card,
    })
    create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 13),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        Parent = content,
    })
    create("UIListLayout", { Padding = UDim.new(0, 13), SortOrder = Enum.SortOrder.LayoutOrder, Parent = content })

    local title = label({
        Parent = content,
        Text = cfg.Title or "",
        Font = FONT_BOLD,
        TextSize = 10,
        TextColor3 = Theme.Text,
        TextWrapped = true,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 1,
    })
    local body = label({
        Parent = content,
        Text = cfg.Content or "",
        Font = FONT_MED,
        TextSize = 9,
        TextColor3 = Theme.TextMuted,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 2,
    })

    local obj = {}
    function obj:SetTitle(t)
        title.Text = t
    end
    function obj:SetContent(t)
        body.Text = t
    end
    function obj:Set(t, c)
        if t then
            title.Text = t
        end
        if c then
            body.Text = c
        end
    end
    return obj
end

----------------------------------------------------------------------
-- Label
----------------------------------------------------------------------
function Section:AddLabel(text)
    local card = self:_card(26, tostring(text))
    local l = label({
        Parent = card,
        Text = tostring(text),
        TextSize = 11,
        TextColor3 = Theme.TextDim,
        TextWrapped = true,
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -24, 1, 0),
    })
    local obj = {}
    function obj:Set(t)
        l.Text = tostring(t)
    end
    return obj
end

----------------------------------------------------------------------
-- Input (TextBox)
----------------------------------------------------------------------
function Section:AddInput(cfg)
    cfg = cfg or {}
    local name = cfg.Name or "Input"
    local card = self:_card(32, name)

    label({
        Parent = card,
        Text = name,
        TextSize = 12,
        TextColor3 = Theme.TextDim,
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -112, 1, 0),
    })
    local box = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(84, 22),
        BackgroundColor3 = Theme.Input,
        BorderSizePixel = 0,
        Parent = card,
    }, { corner(6), stroke(Theme.InputStroke, 1) })
    local tb = create("TextBox", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -8, 1, 0),
        Position = UDim2.fromOffset(4, 0),
        Font = FONT_MED,
        TextSize = 10,
        TextColor3 = Theme.Purple,
        PlaceholderText = cfg.Placeholder or "...",
        PlaceholderColor3 = Color3.fromRGB(92, 84, 125),
        Text = cfg.Default or "",
        ClearTextOnFocus = false,
        Parent = box,
    })
    local obj = {}
    function obj:Get()
        return tb.Text
    end
    function obj:Set(t)
        tb.Text = tostring(t)
    end
    tb.FocusLost:Connect(function()
        if cfg.Flag then
            Library.Flags[cfg.Flag] = tb.Text
        end
        fire(cfg.Callback, tb.Text)
    end)
    return obj
end

return Library
