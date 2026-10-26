-- // XenoLib | Delta Executor Ready
-- // UI Library สไตล์เมนูในรูป (Dark Theme + Sidebar)
-- // ใช้: local XenoLib = loadstring(game:HttpGet("..."))() หรือวางทั้งไฟล์ไว้บนสุด

local XenoLib = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Themes = {
    Background   = Color3.fromRGB(13, 13, 20),      -- พื้นหลังหลัก
    Sidebar      = Color3.fromRGB(9, 9, 15),
    Element      = Color3.fromRGB(24, 24, 34),      -- กล่อง element
    ElementHover = Color3.fromRGB(32, 32, 46),
    Stroke       = Color3.fromRGB(38, 38, 52),
    Text         = Color3.fromRGB(235, 235, 245),
    TextDark     = Color3.fromRGB(120, 120, 140),
    Accent       = Color3.fromRGB(97, 90, 255),     -- ม่วงสไลเดอร์/ปุ่ม home
    AccentDark   = Color3.fromRGB(70, 65, 200),
    Enabled      = Color3.fromRGB(97, 90, 255),
}

local function protect(gui)
    local ok, hui = pcall(function() return gethui() end)
    if ok and hui then gui.Parent = hui return end
    local ok2, sp = pcall(function() return syn and syn.protectgui end)
    if ok2 and sp then pcall(function() syn.protectgui(gui) end) end
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local function tween(obj, t, props)
    TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quint), props):Play()
end

local function round(n, p) local m = 10^(p or 2) return math.floor(n*m+0.5)/m end

-- // Drag helper
local function makeDraggable(dragHandle, dragTarget)
    local dragging, dragInput, startPos, startInputPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startInputPos = input.Position
            startPos = dragTarget.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - startInputPos
            dragTarget.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                            startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-------------------------------------------------
-- WINDOW
-------------------------------------------------
function XenoLib:CreateWindow(config)
    config = config or {}
    local Window = { Tabs = {}, CurrentTab = nil }

    -- ลบ GUI เก่าชื่อเดียวกัน
    pcall(function()
        for _, g in pairs((gethui and gethui()) or LocalPlayer.PlayerGui:GetChildren()) do
            if g.Name == (config.Name or "XenoLib") and g:IsA("ScreenGui") then g:Destroy() end
        end
    end)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = config.Name or "XenoLib"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    protect(ScreenGui)

    -- Main frame
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.fromOffset(1250, 700)
    Main.Position = UDim2.new(0.5, -625, 0.5, -350)
    Main.BackgroundColor3 = Themes.Background
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = Themes.Stroke; MainStroke.Thickness = 1.5
    Main.Parent = ScreenGui
    makeDraggable(Main, Main)

    -- // Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 150, 1, 0)
    Sidebar.BackgroundColor3 = Themes.Sidebar
    Sidebar.BorderSizePixel = 0
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)
    local SideFix = Instance.new("Frame", Sidebar) -- ปิดมุมขวาให้เหลี่ยมชิด main
    SideFix.Size = UDim2.new(0, 20, 1, 0); SideFix.Position = UDim2.new(1, -20, 0, 0)
    SideFix.BackgroundColor3 = Themes.Sidebar; SideFix.BorderSizePixel = 0
    Sidebar.Parent = Main

    local SideLayout = Instance.new("UIListLayout", Sidebar)
    SideLayout.Padding = UDim.new(0, 14)
    SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SideLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local SidePad = Instance.new("UIPadding", Sidebar)
    SidePad.PaddingTop = UDim.new(0, 40)

    -- Logo ด้านบน (X กะพรวด)
    local Logo = Instance.new("TextLabel", Sidebar)
    Logo.LayoutOrder = -1
    Logo.Size = UDim2.fromOffset(60, 60)
    Logo.BackgroundTransparency = 1
    Logo.Text = "⌖"
    Logo.TextColor3 = Color3.fromRGB(240, 240, 255)
    Logo.Font = Enum.Font.GothamBold
    Logo.TextSize = 38

    local sideOrder = 0
    function Window:_AddSideButton(icon, order, bottom, tooltip)
        local Btn = Instance.new("TextButton")
        Btn.Name = "SideBtn_" .. icon
        Btn.LayoutOrder = order
        Btn.Size = UDim2.fromOffset(52, 52)
        Btn.BackgroundColor3 = Themes.Element
        Btn.Text = icon
        Btn.TextColor3 = Themes.Text
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 24
        Btn.AutoButtonColor = false
        Btn.BorderSizePixel = 0
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 12)
        if not bottom then
            Btn.Parent = Sidebar
        else
            Btn.AnchorPoint = Vector2.new(0.5, 1)
            Btn.Position = UDim2.new(0.5, 0, 1, -25)
            Btn.Parent = Sidebar
        end
        Btn.MouseEnter:Connect(function() if Window._activeSide ~= Btn then tween(Btn, 0.15, {BackgroundColor3 = Themes.ElementHover}) end end)
        Btn.MouseLeave:Connect(function() if Window._activeSide ~= Btn then tween(Btn, 0.15, {BackgroundColor3 = Themes.Element}) end end)
        return Btn
    end

    -- พื้นที่เนื้อหา (1 แถว 2 คอลัมน์)
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -170, 1, -40)
    Content.Position = UDim2.fromOffset(160, 20)
    Content.BackgroundTransparency = 1
    Content.Parent = Main

    local ColLayout = Instance.new("UIListLayout", Content)
    ColLayout.FillDirection = Enum.FillDirection.Horizontal
    ColLayout.Padding = UDim.new(0, 20)
    ColLayout.SortOrder = Enum.SortOrder.LayoutOrder

    function Window:_ContentColumn(order)
        local Col = Instance.new("Frame")
        Col.LayoutOrder = order
        Col.Size = UDim2.new(0.5, -10, 1, 0)
        Col.BackgroundTransparency = 1
        Col.Parent = Content
        local l = Instance.new("UIListLayout", Col)
        l.Padding = UDim.new(0, 20)
        l.SortOrder = Enum.SortOrder.LayoutOrder
        return Col
    end

    local ColLeft = Window:_ContentColumn(1)
    local ColRight = Window:_ContentColumn(2)

    -------------------------------------------------
    -- TAB (กล่องมุมมอง + ปุ่ม sidebar)
    -------------------------------------------------
    function Window:CreateTab(opts)
        local Tab = { Sections = {} }
        opts = opts or {}
        sideOrder = sideOrder + 1

        local sideBtn = Window:_AddSideButton(opts.Icon or "•", opts.Bottom and 999 or sideOrder, opts.Bottom, opts.Name)

        local Box = Instance.new("Frame")
        Box.Name = opts.Name or "Tab"
        Box.Size = UDim2.new(1, 0, 1, 0)
        Box.BackgroundColor3 = Themes.Element
        Box.BorderSizePixel = 0
        Box.Visible = false
        Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 8)
        local bs = Instance.new("UIStroke", Box); bs.Color = Themes.Stroke; bs.Thickness = 1.5
        Box.Parent = opts.Column == 2 and ColRight or ColLeft

        local scroll = Instance.new("ScrollingFrame", Box)
        scroll.Size = UDim2.new(1, -30, 1, -30)
        scroll.Position = UDim2.fromOffset(15, 15)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 3
        scroll.ScrollBarImageColor3 = Themes.Accent
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

        local sl = Instance.new("UIListLayout", scroll)
        sl.Padding = UDim.new(0, 12)
        sl.SortOrder = Enum.SortOrder.LayoutOrder

        local sp = Instance.new("UIPadding", scroll)
        sp.PaddingRight = UDim.new(0, 6)

        function Tab:Show()
            for _, t in pairs(Window.Tabs) do t.Box.Visible = false end
            Box.Visible = true
            for _, b in pairs(Sidebar:GetChildren()) do
                if b:IsA("TextButton") then
                    if b == sideBtn then
                        tween(b, 0.15, {BackgroundColor3 = Themes.Accent})
                        b.TextColor3 = Color3.new(1, 1, 1)
                    else
                        tween(b, 0.15, {BackgroundColor3 = Themes.Element})
                        b.TextColor3 = Themes.Text
                    end
                end
            end
            Window._activeSide = sideBtn
        end

        sideBtn.MouseButton1Click:Connect(function() Tab:Show() end)

        Tab.Box = Box
        Tab.Scroll = scroll
        Tab.SideButton = sideBtn
        table.insert(Window.Tabs, Tab)
        if #Window.Tabs == 1 then Tab:Show() end
        return Tab
    end

    -------------------------------------------------
    -- ELEMENTS (สร้างใน Tab.Scroll)
    -------------------------------------------------
    local function newRow(parent, height)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, height or 30)
        f.BackgroundTransparency = 1
        f.BorderSizePixel = 0
        f.LayoutOrder = #parent:GetChildren()
        f.Parent = parent
        return f
    end

    local function newLabel(parent, text, size, color, align)
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = color or Themes.Text
        l.Font = Enum.Font.GothamBold
        l.TextSize = size or 15
        l.TextXAlignment = align or Enum.TextXAlignment.Left
        l.Parent = parent
        return l
    end

    -- ====== Checkbox (+ keybind ตัวอักษรด้านขวา) ======
    function XenoLib.__checkbox(tab, cfg)
        cfg = cfg or {}
        local row = newRow(tab.Scroll, 30)

        local cb = Instance.new("TextButton")
        cb.Size = UDim2.fromOffset(22, 22)
        cb.Position = UDim2.fromOffset(0, 4)
        cb.BackgroundColor3 = cfg.Default and Themes.Enabled or Themes.Background
        cb.BorderSizePixel = 0
        cb.Text = ""
        cb.AutoButtonColor = false
        Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 4)
        local cs = Instance.new("UIStroke", cb); cs.Color = Themes.Stroke; cs.Thickness = 1.5
        if cfg.Default then cs.Color = Themes.Accent end
        cb.Parent = row

        local check = newLabel(cb, "✓", 14, Color3.new(1, 1, 1), Enum.TextXAlignment.Center)
        check.Size = UDim2.fromScale(1, 1)
        check.Visible = cfg.Default == true
        check.Font = Enum.Font.GothamBold

        local lbl = newLabel(row, cfg.Name or "Toggle", 14, cfg.Default == false and Themes.TextDark or Themes.Text)
        lbl.Size = UDim2.new(1, -80, 1, 0)
        lbl.Position = UDim2.fromOffset(32, 0)

        local key = newLabel(row, cfg.Key or "", 14, Themes.Text, Enum.TextXAlignment.Right)
        key.Size = UDim2.new(0, 30, 1, 0)
        key.Position = UDim2.new(1, -30, 0, 0)

        local state = cfg.Default == true
        local callback = cfg.Callback or function() end

        local function set(v, fire)
            state = v
            check.Visible = v
            tween(cb, 0.12, {BackgroundColor3 = v and Themes.Enabled or Themes.Background})
            cs.Color = v and Themes.Accent or Themes.Stroke
            lbl.TextColor3 = (v and Themes.Text) or (cfg.Default == false and Themes.TextDark or Themes.Text)
            if fire ~= false then callback(v) end
        end
        cb.MouseButton1Click:Connect(function() set(not state) end)

        if cfg.Key then
            key.Text = cfg.Key
            key.TextColor3 = Themes.Text
        end

        return { Set = set, Get = function() return state end, Instance = cb }
    end

    -- ====== Slider ======
    function XenoLib.__slider(tab, cfg)
        cfg = cfg or {}
        local min, max = cfg.Min or 0, cfg.Max or 100
        local def = math.clamp(cfg.Default or min, min, max)
        local suffix = cfg.Suffix or ""
        local decimals = cfg.Decimals or 0
        if suffix:find("°") or suffix:find("%%") then decimals = 0 end

        local holder = newRow(tab.Scroll, 56)

        local name = newLabel(holder, cfg.Name or "Slider", 14)
        name.Size = UDim2.new(0.6, 0, 0, 22)

        local val = newLabel(holder, tostring(def) .. suffix, 14, Themes.Text, Enum.TextXAlignment.Right)
        val.Size = UDim2.new(0.4, 0, 0, 22)
        val.Position = UDim2.new(0.6, 0, 0, 0)

        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, 0, 0, 6)
        track.Position = UDim2.fromOffset(0, 34)
        track.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        track.BorderSizePixel = 0
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
        track.Parent = holder

        local fill = Instance.new("Frame")
        fill.Size = UDim2.fromScale((def - min) / (max - min), 1)
        fill.BackgroundColor3 = Themes.Accent
        fill.BorderSizePixel = 0
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
        fill.Parent = track

        local knob = Instance.new("Frame")
        knob.Size = UDim2.fromOffset(18, 18)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.new((def - min) / (max - min), 0, 0.5, 0)
        knob.BackgroundColor3 = Color3.fromRGB(225, 225, 235)
        knob.BorderSizePixel = 0
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        local kstroke = Instance.new("UIStroke", knob)
        kstroke.Color = Color3.fromRGB(180, 180, 200); kstroke.Thickness = 2
        knob.Parent = track

        local callback = cfg.Callback or function() end
        local current = def

        local function setValue(v, fire)
            v = math.clamp(v, min, max)
            current = round(v, decimals)
            local alpha = (v - min) / (max - min)
            fill.Size = UDim2.fromScale(alpha, 1)
            knob.Position = UDim2.new(alpha, 0, 0.5, 0)
            val.Text = tostring(round(v, decimals)) .. suffix
            if fire ~= false then callback(current) end
        end

        local sliding = false
        local function updateFromInput(x)
            local abs = track.AbsolutePosition.X
            local size = track.AbsoluteSize.X
            local alpha = math.clamp((x - abs) / size, 0, 1)
            setValue(min + (max - min) * alpha)
        end

        track.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                sliding = true; updateFromInput(i.Position.X)
            end
        end)
        knob.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                sliding = true; updateFromInput(i.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                sliding = false
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                updateFromInput(i.Position.X)
            end
        end)

        setValue(def, false)
        return { Set = function(v) setValue(v) end, Get = function() return current end }
    end

    -- ====== Dropdown ======
    function XenoLib.__dropdown(tab, cfg)
        cfg = cfg or {}
        local options = cfg.Options or {}
        local current = cfg.Default or options[1] or ""

        local holder = Instance.new("Frame")
        holder.BackgroundTransparency = 1
        holder.BorderSizePixel = 0
        holder.LayoutOrder = #tab.Scroll:GetChildren()
        holder.Parent = tab.Scroll
        holder.AutomaticSize = Enum.AutomaticSize.Y
        holder.Size = UDim2.new(1, 0, 0, 0)

        local name = newLabel(holder, cfg.Name or "Dropdown", 14)
        name.Size = UDim2.new(1, 0, 0, 22)

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 42)
        btn.Position = UDim2.fromOffset(0, 26)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local bs = Instance.new("UIStroke", btn); bs.Color = Themes.Stroke; bs.Thickness = 1.5
        btn.Parent = holder

        local txt = newLabel(btn, tostring(current), 14)
        txt.Size = UDim2.new(1, -50, 1, 0)
        txt.Position = UDim2.fromOffset(14, 0)

        -- ไอคอน grid 4 ช่อง (เหมือนในรูป)
        local grid = Instance.new("Frame")
        grid.Size = UDim2.fromOffset(20, 20)
        grid.AnchorPoint = Vector2.new(1, 0.5)
        grid.Position = UDim2.new(1, -14, 0.5, 0)
        grid.BackgroundTransparency = 1
        grid.Parent = btn
        local gl = Instance.new("UIGridLayout", grid)
        gl.CellSize = UDim2.fromOffset(8, 8); gl.CellPadding = UDim2.fromOffset(3, 3)
        for i = 1, 4 do
            local c = Instance.new("Frame")
            c.BackgroundColor3 = Themes.Accent
            c.BorderSizePixel = 0
            Instance.new("UICorner", c).CornerRadius = UDim.new(0, 2)
            c.Parent = grid
        end

        local list = Instance.new("Frame")
        list.Size = UDim2.new(1, 0, 0, 0)
        list.AutomaticSize = Enum.AutomaticSize.Y
        list.Position = UDim2.fromOffset(0, 74)
        list.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        list.Visible = false
        list.BorderSizePixel = 0
        list.ZIndex = 5
        Instance.new("UICorner", list).CornerRadius = UDim.new(0, 6)
        local ls = Instance.new("UIStroke", list); ls.Color = Themes.Stroke
        list.Parent = holder
        local ll = Instance.new("UIListLayout", list)
        ll.Padding = UDim.new(0, 2); ll.SortOrder = Enum.SortOrder.LayoutOrder

        local callback = cfg.Callback or function() end
        local open = false

        for idx, opt in ipairs(options) do
            local o = Instance.new("TextButton")
            o.LayoutOrder = idx
            o.Size = UDim2.new(1, 0, 0, 32)
            o.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
            o.BackgroundTransparency = 1
            o.Text = ""
            o.BorderSizePixel = 0
            o.ZIndex = 6
            o.AutoButtonColor = false
            o.Parent = list
            local ot = newLabel(o, tostring(opt), 13)
            ot.Size = UDim2.new(1, -16, 1, 0); ot.Position = UDim2.fromOffset(10, 0); ot.ZIndex = 6
            o.MouseEnter:Connect(function() tween(o, 0.1, {BackgroundTransparency = 0.4}) end)
            o.MouseLeave:Connect(function() tween(o, 0.1, {BackgroundTransparency = 1}) end)
            o.MouseButton1Click:Connect(function()
                current = opt
                txt.Text = tostring(opt)
                open = false; list.Visible = false
                callback(opt)
            end)
        end

        btn.MouseButton1Click:Connect(function()
            open = not open
            list.Visible = open
        end)

        return {
            Set = function(v) current = v; txt.Text = tostring(v) end,
            Get = function() return current end,
            Refresh = function(newOpts)
                for _, c in pairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                options = newOpts
                for idx, opt in ipairs(newOpts) do
                    local o = Instance.new("TextButton")
                    o.LayoutOrder = idx
                    o.Size = UDim2.new(1, 0, 0, 32)
                    o.BackgroundTransparency = 1
                    o.Text = ""; o.ZIndex = 6; o.AutoButtonColor = false
                    o.Parent = list
                    local ot = newLabel(o, tostring(opt), 13)
                    ot.Size = UDim2.new(1, -16, 1, 0); ot.Position = UDim2.fromOffset(10, 0); ot.ZIndex = 6
                    o.MouseButton1Click:Connect(function()
                        current = opt; txt.Text = tostring(opt)
                        open = false; list.Visible = false
                        callback(opt)
                    end)
                end
            end
        }
    end

    -- ====== Textbox (Whitelist input) ======
    function XenoLib.__textbox(tab, cfg)
        cfg = cfg or {}
        local holder = newRow(tab.Scroll, 42)
        holder.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
        holder.BorderSizePixel = 0
        Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 6)
        local hs = Instance.new("UIStroke", holder); hs.Color = Themes.Stroke; hs.Thickness = 1.5

        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, -24, 1, 0)
        box.Position = UDim2.fromOffset(12, 0)
        box.BackgroundTransparency = 1
        box.Text = ""
        box.PlaceholderText = cfg.Placeholder or "Player name..."
        box.PlaceholderColor3 = Themes.TextDark
        box.TextColor3 = Themes.Text
        box.Font = Enum.Font.Gotham
        box.TextSize = 14
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.ClearTextOnFocus = false
        box.Parent = holder

        local callback = cfg.Callback or function() end
        box.FocusLost:Connect(function() callback(box.Text) end)

        return { Get = function() return box.Text end, Set = function(t) box.Text = t end }
    end

    -- ====== Toggle Switch (Silent Aim แบบสวิตช์) ======
    function XenoLib.__switch(tab, cfg)
        cfg = cfg or {}
        local holder = newRow(tab.Scroll, 34)

        local name = newLabel(holder, cfg.Name or "Switch", 14, Themes.TextDark)
        name.Size = UDim2.new(0.6, 0, 1, 0)
        name.Position = UDim2.fromOffset(34, 0)

        local sw = Instance.new("TextButton")
        sw.Size = UDim2.fromOffset(44, 22)
        sw.AnchorPoint = Vector2.new(1, 0.5)
        sw.Position = UDim2.new(1, 0, 0.5, 0)
        sw.BackgroundColor3 = Themes.Background
        sw.BorderSizePixel = 0
        sw.Text = ""
        sw.AutoButtonColor = false
        Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)
        local ss = Instance.new("UIStroke", sw); ss.Color = Themes.Stroke; ss.Thickness = 1.5
        sw.Parent = holder

        local dot = Instance.new("Frame")
        dot.Size = UDim2.fromOffset(14, 14)
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.Position = UDim2.new(0, 8, 0.5, 0)
        dot.BackgroundColor3 = Color3.fromRGB(140, 140, 160)
        dot.BorderSizePixel = 0
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        dot.Parent = sw

        local cb = Instance.new("Frame")
        cb.Size = UDim2.fromOffset(22, 22)
        cb.Position = UDim2.fromOffset(0, 6)
        cb.BackgroundColor3 = Themes.Background
        cb.BorderSizePixel = 0
        Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 4)
        local cbs = Instance.new("UIStroke", cb); cbs.Color = Themes.Stroke; cbs.Thickness = 1.5
        cb.Parent = holder

        local state = cfg.Default == true
        local callback = cfg.Callback or function() end

        local function set(v, fire)
            state = v
            tween(sw, 0.15, {BackgroundColor3 = v and Themes.Enabled or Themes.Background})
            ss.Color = v and Themes.Accent or Themes.Stroke
            tween(dot, 0.15, {Position = v and UDim2.new(1, -8, 0.5, 0) or UDim2.new(0, 8, 0.5, 0)})
            tween(dot, 0.15, {BackgroundColor3 = v and Color3.new(1, 1, 1) or Color3.fromRGB(140, 140, 160)})
            name.TextColor3 = v and Themes.Text or Themes.TextDark
            if fire ~= false then callback(v) end
        end
        if state then set(true, false) end

        sw.MouseButton1Click:Connect(function() set(not state) end)
        return { Set = set, Get = function() return state end }
    end

    -- ====== Keybind (Override MB2) ======
    function XenoLib.__keybind(tab, cfg)
        cfg = cfg or {}
        local holder = newRow(tab.Scroll, 30)
        local name = newLabel(holder, cfg.Name or "Keybind", 14)
        name.Size = UDim2.new(0.5, 0, 1, 0)

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.fromOffset(50, 24)
        btn.AnchorPoint = Vector2.new(1, 0.5)
        btn.Position = UDim2.new(1, 0, 0.5, 0)
        btn.BackgroundTransparency = 1
        btn.Text = cfg.Default or "..."
        btn.TextColor3 = Themes.Text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.AutoButtonColor = false
        btn.Parent = holder

        local binding = false
        local current = cfg.Default
        local callback = cfg.Callback or function() end

        btn.MouseButton1Click:Connect(function()
            binding = true
            btn.Text = "..."
        end)
        UserInputService.InputBegan:Connect(function(i, gpe)
            if binding then
                if i.KeyCode ~= Enum.KeyCode.Unknown then
                    current = i.KeyCode.Name
                    btn.Text = current
                    binding = false
                    callback(current)
                end
            elseif current and i.KeyCode.Name == current then
                callback(current)
            end
        end)
        return { Get = function() return current end }
    end

    -- ====== Label (หัวข้อ เช่น Weapons) ======
    function XenoLib.__label(tab, text)
        local l = newLabel(tab.Scroll, text, 14)
        l.Size = UDim2.new(1, 0, 0, 20)
        return l
    end

    -- ====== ปุ่มคู่ (Reset / Apply) ======
    function XenoLib.__buttonrow(tab, cfg)
        cfg = cfg or {}
        local holder = newRow(tab.Scroll, 44)
        local layout = Instance.new("UIListLayout", holder)
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.Padding = UDim.new(0, 12)
        local pad = Instance.new("UIPadding", holder)

        local btns = {}
        for _, b in ipairs(cfg.Buttons or {}) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.5, -6, 1, 0)
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
            btn.Text = b.Name
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 14
            btn.AutoButtonColor = false
            btn.BorderSizePixel = 0
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            local bs = Instance.new("UIStroke", btn); bs.Color = Themes.Stroke; bs.Thickness = 1.5
            btn.Parent = holder
            btn.MouseEnter:Connect(function() tween(btn, 0.15, {BackgroundColor3 = Themes.ElementHover}) end)
            btn.MouseLeave:Connect(function() tween(btn, 0.15, {BackgroundColor3 = Color3.fromRGB(30, 30, 42)}) end)
            btn.MouseButton1Click:Connect(function() if b.Callback then b.Callback() end end)
            table.insert(btns, btn)
        end
        return btns
    end

    -- ผูก element เข้ากับ Tab object
    local elementMap = {
        AddCheckbox   = XenoLib.__checkbox,
        AddSlider     = XenoLib.__slider,
        AddDropdown   = XenoLib.__dropdown,
        AddTextbox    = XenoLib.__textbox,
        AddSwitch     = XenoLib.__switch,
        AddKeybind    = XenoLib.__keybind,
        AddLabel      = XenoLib.__label,
        AddButtonRow  = XenoLib.__buttonrow,
    }
    for name, fn in pairs(elementMap) do
        Tab[name] = function(self, cfg) return fn(self, cfg) end
    end

    -- ปุ่มเกียร์ล่างสุด (เปิด/ปิดเมนู)
    local Gear = Instance.new("TextButton")
    Gear.Size = UDim2.fromOffset(52, 52)
    Gear.AnchorPoint = Vector2.new(0.5, 1)
    Gear.Position = UDim2.new(0.5, 0, 1, -25)
    Gear.BackgroundColor3 = Themes.Element
    Gear.Text = "⚙"
    Gear.TextColor3 = Themes.Text
    Gear.Font = Enum.Font.GothamBold
    Gear.TextSize = 26
    Gear.AutoButtonColor = false
    Gear.BorderSizePixel = 0
    Instance.new("UICorner", Gear).CornerRadius = UDim.new(0, 12)
    Gear.Parent = Sidebar

    local menuOpen = true
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightShift
    local function setMenu(v)
        menuOpen = v
        tween(Main, 0.25, {Size = v and UDim2.fromOffset(1250, 700) or UDim2.fromOffset(1250, 0)})
        Main.Visible = v
    end
    Gear.MouseButton1Click:Connect(function() setMenu(not menuOpen) end)
    UserInputService.InputBegan:Connect(function(i, gpe)
        if not gpe and i.KeyCode == toggleKey then setMenu(not menuOpen) end
    end)

    Window.Main = Main
    Window.ScreenGui = ScreenGui
    return Window
end

-------------------------------------------------
-- // EXAMPLE: สร้าง UI ตามรูป 100%
-------------------------------------------------
local Window = XenoLib:CreateWindow({ Name = "XenoLib", ToggleKey = Enum.KeyCode.RightShift })

-- // TAB 1: AIMBOT (คอลัมน์ซ้าย)
local AimbotTab = Window:CreateTab({ Name = "Aimbot", Icon = "⌂" })

AimbotTab:AddCheckbox({ Name = "Enabled", Key = "Q", Default = true })
AimbotTab:AddCheckbox({ Name = "Visible Check", Default = true })
AimbotTab:AddCheckbox({ Name = "Team Check", Default = false })
AimbotTab:AddSlider({ Name = "Field of View", Min = 0, Max = 360, Default = 120, Suffix = "°" })
AimbotTab:AddSlider({ Name = "Smoothness", Min = 0, Max = 1, Default = 0.35, Decimals = 2 })
AimbotTab:AddDropdown({ Name = "Hit Part", Default = "Head", Options = { "Head", "Torso", "HumanoidRootPart", "Left Arm", "Right Arm" } })
AimbotTab:AddDropdown({ Name = "Priority", Default = "Closest to Crosshair, Lowest Health",
    Options = { "Closest to Crosshair, Lowest Health", "Lowest Health", "Closest Distance", "Farthest Distance" } })
AimbotTab:AddButtonRow({ Buttons = {
    { Name = "Reset", Callback = function() print("[XenoLib] Reset settings") end },
    { Name = "Apply", Callback = function() print("[XenoLib] Applied settings") end },
}})

-- // TAB 2: TRIGGERBOT (คอลัมน์ขวา)
local TriggerTab = Window:CreateTab({ Name = "Triggerbot", Icon = "⌖", Column = 2 })

TriggerTab:AddCheckbox({ Name = "Triggerbot", Key = "T", Default = false })
TriggerTab:AddSlider({ Name = "Delay", Min = 0, Max = 500, Default = 80, Suffix = "ms" })
TriggerTab:AddTextbox({ Name = "Whitelist", Placeholder = "Player name..." })
TriggerTab:AddLabel("Weapons")
TriggerTab:AddDropdown({ Name = "Weapons", Default = "Weapon 1", Options = { "Weapon 1", "Weapon 2", "Weapon 3" } })
TriggerTab:AddSwitch({ Name = "Silent Aim", Default = false })
TriggerTab:AddSlider({ Name = "Hit Chance", Min = 0, Max = 100, Default = 69, Suffix = "%" })
TriggerTab:AddKeybind({ Name = "Override", Default = "MB2" })

-- // TAB เสริม (ไอคอนตา / คน / ...) เอาไว้ขยายเอง
Window:CreateTab({ Name = "Visuals", Icon = "👁" })
Window:CreateTab({ Name = "Players", Icon = "👥" })

return XenoLib
