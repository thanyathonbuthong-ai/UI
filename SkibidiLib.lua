--[[
    SkibidiLib  -  UI Library (extracted 1:1 from Skibidi Redeemer)

    Usage:
        local Library = loadstring(readfile("SkibidiLib.lua"))()
        local Window  = Library:CreateWindow({ Title = "Skibidi Redeemer", ... })
        local Tab     = Window:CreateTab({ Name = "Sniper", Icon = "sniper" })
        Tab:AddToggleTile({ Label = "Auto submit", Icon = "bolt", Default = true, Callback = function(v) end })

    See Example.lua for a full reproduction of the original menu.
]]

local Library = { Version = "1.0.0", Icons = {}, Windows = {} }

local cloneref = cloneref or function(o) return o end
local Players          = cloneref(game:GetService("Players"))
local TweenService     = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local RunService       = cloneref(game:GetService("RunService"))
local HttpService      = cloneref(game:GetService("HttpService"))
local SoundService     = cloneref(game:GetService("SoundService"))
local player = Players.LocalPlayer

local env = (getgenv and getgenv()) or _G
env.__SkibidiLibWindows = env.__SkibidiLibWindows or {}

-- ───────────────────────── theme / fonts ─────────────────────────
local rgb = Color3.fromRGB
local function gray(v) return rgb(v, v, v) end

local C = {
    Bg     = rgb(12, 12, 14),
    Panel  = rgb(20, 20, 23),
    Hover  = rgb(27, 27, 31),
    Raise  = rgb(34, 34, 39),
    Line   = rgb(38, 38, 43),
    Edge   = rgb(64, 64, 72),
    Text   = rgb(236, 236, 239),
    Sub    = rgb(142, 142, 150),
    Faint  = rgb(88, 88, 96),
    Green  = rgb(74, 222, 128),
    Red    = rgb(248, 113, 113),
}
Library.Theme = C

local GOTHAM = "rbxasset://fonts/families/GothamSSm.json"
local F = {
    Bold   = Font.new(GOTHAM, Enum.FontWeight.Bold),
    Medium = Font.new(GOTHAM, Enum.FontWeight.Medium),
    Book   = Font.new(GOTHAM, Enum.FontWeight.Regular),
    Mono   = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Regular),
}
Library.Fonts = F

-- ───────────────────────── tiny instance helpers ─────────────────────────
local function tween(obj, t, props, style, dir)
    local tw = TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local function new(class, props, kids)
    local obj = Instance.new(class)
    local parent
    for k, v in pairs(props or {}) do
        if k == "Parent" then parent = v else obj[k] = v end
    end
    for _, kid in ipairs(kids or {}) do kid.Parent = obj end
    if parent then obj.Parent = parent end
    return obj
end

local function corner(r) return new("UICorner", { CornerRadius = UDim.new(0, r) }) end
local function stroke(color)
    return new("UIStroke", { Color = color, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
end
local function pad(t, r, b, l)
    return new("UIPadding", {
        PaddingTop = UDim.new(0, t), PaddingRight = UDim.new(0, r),
        PaddingBottom = UDim.new(0, b), PaddingLeft = UDim.new(0, l),
    })
end
local function box(props, kids)
    props.BorderSizePixel = 0
    if props.BackgroundColor3 == nil then props.BackgroundTransparency = 1 end
    return new("Frame", props, kids)
end
local function text(props)
    props.BackgroundTransparency = 1
    props.BorderSizePixel = 0
    props.FontFace = props.FontFace or F.Medium
    props.TextSize = props.TextSize or 14
    props.TextColor3 = props.TextColor3 or C.Text
    props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
    props.TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center
    return new("TextLabel", props)
end
local function button(props, kids)
    props.Text = props.Text or ""
    props.AutoButtonColor = false
    props.BorderSizePixel = 0
    if props.BackgroundColor3 == nil then props.BackgroundTransparency = 1 end
    return new("TextButton", props, kids)
end
local function esc(s)
    return (tostring(s):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end
local function keyName(code)
    return (code.Name:gsub("^Right", "R"):gsub("^Left", "L"):gsub("Control", "Ctrl"))
end
local function clean(s)
    return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end
local function isPress(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end
local function tracks(stored, input)
    return input == stored
        or (stored.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement)
end

Library.Util = { tween = tween, new = new, box = box, text = text, button = button, esc = esc, keyName = keyName, gray = gray }

local function pixelArt(parent, rows, px, palette, origin, zindex)
    local frames = {}
    for y, line in ipairs(rows) do
        local x = 1
        while x <= #line do
            local ch = line:sub(x, x)
            local run = x
            while run < #line and line:sub(run + 1, run + 1) == ch do run += 1 end
            local color = palette[ch]
            if color then
                frames[#frames + 1] = box({
                    Position = UDim2.fromOffset(origin.X + (x - 1) * px, origin.Y + (y - 1) * px),
                    Size = UDim2.fromOffset((run - x + 1) * px, px),
                    BackgroundColor3 = color,
                    ZIndex = zindex or 1,
                    Parent = parent,
                })
            end
            x = run + 1
        end
    end
    return frames
end
Library.PixelArt = pixelArt

-- ───────────────────────── pixel art data ─────────────────────────
local SKIBIDI = {
    "......HHHHHHHH......",
    "....HHHHHHHHHHHH....",
    "...HHHHHHHHHHHHHH...",
    "...HHHHHHHHHHHHHH...",
    "...HHSSSSSSSSSSHH...",
    "...HBBBBSSSSBBBBH...",
    "...sSWWWWSSWWWWSs...",
    "...sSWPPWSSWPPWSs...",
    ".OOsSWWWWSSWWWWSsOO.",
    "..ooSSSSSssSSSSSoo..",
    "..ooSMSSSSSSSSMSoo..",
    "..ooSMTTTTTTTTMSoo..",
    "..ooSSMMUUUUMMSSoo..",
    "..ooSSSMMMMMMSSSoo..",
    "..oooSSSSSSSSSSooo..",
    ".OOOOOSSSSSSSSOOOOO.",
    ".OwwwwSSSSSSSSwwwwO.",
    ".OOOOOOOOOOOOOOOOOO.",
    "..oOOOOOOOOOOOOOOo..",
    "...oOOOOOOOOOOOOo...",
    "....ooOOOOOOOOoo....",
    ".....oOOOOOOOOo.....",
    "....OOOOOOOOOOOO....",
    "....oooooooooooo....",
}
local SKIBIDI_LIDS = {
    ".....SSSS..SSSS.....",
    ".....MMMM..MMMM.....",
    ".....SSSS..SSSS.....",
}
local SKIBIDI_PALETTE = {
    H = gray(34), S = gray(192), s = gray(158), B = gray(22),
    W = gray(250), P = gray(14), M = gray(38), T = gray(248), U = gray(112),
    O = gray(238), o = gray(196), w = gray(118),
}
Library.Logo = { Rows = SKIBIDI, Lids = SKIBIDI_LIDS, Palette = SKIBIDI_PALETTE }

local ICONS = {
    sniper = { "...#...", ".#####.", ".#...#.", "##.#.##", ".#...#.", ".#####.", "...#..." },
    activity = { "##.####", ".......", "##.####", ".......", "##.###.", ".......", "##.####" },
    admin = { "#######", "#.....#", "#..#..#", "#.###.#", ".#.#.#.", "..#.#..", "...#..." },
    anchor = { "...#...", "..###..", "...#...", "...#...", "#..#..#", ".#.#.#.", "..###.." },
    triggers = { "...#...", "..###..", ".#####.", ".#####.", ".#####.", "#######", "...#..." },
    optimizer = { "..###..", ".#...#.", "#..#..#", "#..#..#", "#...#.#", ".#...#.", "..###.." },
    cart = { "#......", ".######", ".#....#", ".######", ".#.....", "..#..#.", "......." },
    settings = { "..#.#..", ".#####.", "##...##", ".#...#.", "##...##", ".#####.", "..#.#.." },
    bolt = { "....##.", "...##..", "..##...", ".######", "...##..", "..##...", ".##...." },
    riddle = { ".#####.", "##...##", ".....##", "...###.", "...##..", ".......", "...##.." },
    retype = { ".####.#", "##...##", "#...###", ".......", "###...#", "##...##", "#.####." },
    collapse = { "...#", "..#.", ".#..", "#...", ".#..", "..#.", "...#" },
    expand   = { "#...", ".#..", "..#.", "...#", "..#.", ".#..", "#..." },
}
Library.Icons = ICONS

local function resolveIcon(icon)
    if type(icon) == "string" then return ICONS[icon] end
    if type(icon) == "table" then return icon end
    return nil
end

-- ───────────────────────── assistant defaults ─────────────────────────
local DEFAULT_MOODS = {
    excited = {
        { 4, { "....BBBB....BBBB....", "...HSSSSSSSSSSSSH..." } },
        { 10, { "....SMMMMMMMMMMS....", "....SMTTTTTTTTMS....", "....SMMUUUUUUMMS....", "....SSMMMMMMMMSS...." } },
    },
    sad = {
        { 4, { "......BB....BB......", "...HBBSSSSSSSSBBH..." } },
        { 10, { "....SSSSSSSSSSSS....", "....SSSMMMMMMSSS....", "....SSMSSSSSSMSS....", "....SSSSSSSSSSSS...." } },
    },
    thinking = {
        { 4, { "............BBB.....", "...HBBBBSSSSSSSSH..." } },
        { 6, { "...sSPPWWSSPPWWSs...", "...sSWWWWSSWWWWSs..." } },
        { 10, { "....SSSSSSSSSSSS....", "....SSSSSSSMMSSS....", "....SSSSSSSMMSSS....", "....SSSSSSSSSSSS...." } },
    },
}

local DEFAULT_LINES = {
    hello     = { chill = "Hey @%s, I'm here if you need me.", hype = "YOOO @%s! Let's grab some codes!", short = "Hi @%s." },
    hint      = { chill = "Open the menu and click me if you need help.", hype = "Need help? Open the menu and click me!", short = "Click me for help." },
    preview   = { chill = "Chill mode. Nice and calm.", hype = "HYPE MODE ACTIVATED!", short = "Short mode." },
    redeem    = { chill = "Nice, %s worked.", hype = "LET'S GOOO! %s claimed!", short = "Claimed %s." },
    reject    = { chill = "%s didn't work, no worries.", hype = "NOOO, %s got rejected!", short = "%s rejected." },
    reward    = { chill = "%s", hype = "WOW! %s!", short = "%s" },
    tracking  = { chill = "A code is coming, I'm watching.", hype = "CODE INCOMING! I'm locked in!", short = "Code incoming." },
    thinking  = { chill = "A riddle... let me think.", hype = "RIDDLE TIME! Brain at max power!", short = "Solving riddle." },
    answer    = { chill = "I think it's %s.", hype = "IT'S %s! I'm a genius!", short = "Answer: %s." },
    stumped   = { chill = "That riddle beat me, sorry.", hype = "ARGH, that riddle got me!", short = "No answer." },
    armed     = { chill = "Armed and ready.", hype = "ARMED! Nothing gets past me!", short = "Armed." },
    idle      = { chill = "Okay, taking a break.", hype = "Break time... I'll be back!", short = "Idle." },
    nokey     = { chill = "I need your Gemini key for riddles. Check the Riddle page.", hype = "I NEED a Gemini key for riddles! Riddle page, go!", short = "Gemini key needed." },
    geminiErr = { chill = "Gemini didn't answer: %s", hype = "Gemini is down?! %s", short = "Gemini error: %s" },
    thinkHelp = { chill = "Hmm, let me think...", hype = "Ooh, good question! Thinking...", short = "Thinking..." },
}
local DEFAULT_EVENT_MOOD = {
    redeem = "excited", reward = "excited", tracking = "excited", preview = "excited",
    reject = "sad", stumped = "sad", nokey = "sad", geminiErr = "sad",
    thinking = "thinking", thinkHelp = "thinking",
}
local DEFAULT_LOUD = { redeem = true, reward = true }
local DEFAULT_TIPS = {
    "Tip: press RShift to hide or show the menu.",
    "Tip: open the menu and drag me wherever you like.",
}
local DEFAULT_FAQ_REPLY = "Ask me anything about this menu!"


-- ═════════════════════════════════════════════════════════════════════
--  Library:CreateWindow
-- ═════════════════════════════════════════════════════════════════════
function Library:CreateWindow(cfg)
    cfg = cfg or {}
    local id = cfg.Id or "SkibidiLib"
    local prevWin = env.__SkibidiLibWindows[id]
    if prevWin and prevWin.Destroy then pcall(prevWin.Destroy, prevWin) end

    local Window = {
        Id = id,
        Flags = {},
        Tabs = {},
        Assistant = { Say = function() end, Event = function() end, OnMenu = function() end },
    }
    local flags = Window.Flags

    local W, H, RAIL = cfg.Width or 440, cfg.Height or 356, 60
    local CW = W - RAIL
    local PX = 20
    local TOP = 56
    local PAGE_H = H - TOP

    local conns, cleanups = {}, {}
    local function on(signal, fn)
        local c = signal:Connect(fn)
        conns[#conns + 1] = c
        return c
    end
    local function hoverColor(target, rest, hover)
        on(target.MouseEnter, function() tween(target, 0.15, { BackgroundColor3 = hover }) end)
        on(target.MouseLeave, function() tween(target, 0.2, { BackgroundColor3 = rest }) end)
    end

    -- ───────────── config persistence (optional) ─────────────
    local CONFIG_FILE = cfg.ConfigFile
    local saved = {}
    if CONFIG_FILE and isfile and readfile then
        pcall(function()
            if isfile(CONFIG_FILE) then saved = HttpService:JSONDecode(readfile(CONFIG_FILE)) end
        end)
        if type(saved) ~= "table" then saved = {} end
    end
    local persisted = {}
    local function register(flag, default)
        if flags[flag] ~= nil then return flags[flag] end
        persisted[flag] = true
        local value = default
        local s = saved[flag]
        if s ~= nil then
            if typeof(default) == "EnumItem" then
                if type(s) == "string" then
                    local ok, kc = pcall(function() return Enum.KeyCode[s] end)
                    if ok and kc then value = kc end
                end
            elseif type(s) == type(default) then
                if type(s) == "table" then
                    local list = {}
                    for _, w in ipairs(s) do
                        if type(w) == "string" and w ~= "" then list[#list + 1] = w end
                    end
                    value = list
                else
                    value = s
                end
            end
        end
        if type(value) == "table" and value == default then
            local copy = {}
            for i, v in ipairs(default) do copy[i] = v end
            value = copy
        end
        flags[flag] = value
        return value
    end
    local function writeConfig()
        if not CONFIG_FILE or not writefile then return end
        pcall(function()
            local out = {}
            for flag in pairs(persisted) do
                local v = flags[flag]
                if typeof(v) == "EnumItem" then v = v.Name end
                out[flag] = v
            end
            writefile(CONFIG_FILE, HttpService:JSONEncode(out))
        end)
    end
    local savePending = false
    local function saveSettings()
        if not CONFIG_FILE or not writefile or savePending then return end
        savePending = true
        task.delay(1, function()
            savePending = false
            writeConfig()
        end)
    end
    local function changed(flag, value)
        if not flag then return end
        flags[flag] = value
        persisted[flag] = true
        saveSettings()
        if cfg.OnChange then task.spawn(cfg.OnChange, flag, value) end
    end
    Window.Register, Window.Changed, Window.SaveConfig = register, changed, writeConfig

    local toggleKey = register("ToggleKey", cfg.ToggleKey or Enum.KeyCode.RightShift)

    -- ───────────── gui root ─────────────
    local guiName = cfg.GuiName or "SkibidiRedeemerUI"
    for _, getContainer in ipairs({
        function() return game:GetService("CoreGui") end,
        function() return player:FindFirstChildOfClass("PlayerGui") end,
    }) do
        pcall(function()
            local container = getContainer()
            local names = { guiName }
            for _, n in ipairs(cfg.LegacyGuiNames or {}) do names[#names + 1] = n end
            for _, name in ipairs(names) do
                local old = container:FindFirstChild(name)
                if old then old:Destroy() end
            end
        end)
    end

    local gui = new("ScreenGui", {
        Name = guiName,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 999,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    if not pcall(function() gui.Parent = game:GetService("CoreGui") end) or not gui.Parent then
        gui.Parent = player:WaitForChild("PlayerGui")
    end
    Window.Gui = gui

    local holder = box({
        Name = "Holder",
        Position = cfg.Position or UDim2.new(1, -(24 + W), 0, 24),
        Size = UDim2.fromOffset(W, H),
        Parent = gui,
    })
    local scale = new("UIScale", { Parent = holder })

    local win = box({
        Name = "Window",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = C.Bg,
        ClipsDescendants = true,
        ZIndex = 1,
        Parent = holder,
    }, { corner(6) })
    local winStroke = stroke(Color3.new(1, 1, 1))
    winStroke.Parent = win
    new("UIGradient", { Color = ColorSequence.new(C.Edge, C.Line), Rotation = 90, Parent = winStroke })

    -- ───────────── rail (left tab bar) ─────────────
    local rail = box({ Name = "Rail", Size = UDim2.fromOffset(RAIL, H), BackgroundColor3 = C.Panel, Parent = win }, { corner(6) })
    local railFill = box({ Position = UDim2.fromOffset(RAIL - 6, 0), Size = UDim2.fromOffset(6, H), BackgroundColor3 = C.Panel, Parent = rail })

    local logoDrag = box({ Name = "LogoDrag", Size = UDim2.fromOffset(RAIL, 64), Active = true, Parent = rail })
    local logoCfg = cfg.Logo or {}
    local logoRows = logoCfg.Rows or SKIBIDI
    local logoPalette = logoCfg.Palette or SKIBIDI_PALETTE
    local logoLids = logoCfg.Lids or (cfg.Logo == nil and SKIBIDI_LIDS or nil)
    local logo = box({ Name = "Logo", Position = UDim2.fromOffset(10, 10),
        Size = UDim2.fromOffset(#logoRows[1] * 2, #logoRows * 2), Parent = rail })
    pixelArt(logo, logoRows, 2, logoPalette, Vector2.zero, 1)
    local lids = box({ Name = "Lids", Position = UDim2.fromOffset(0, (logoCfg.LidsRow or 6) * 2),
        Size = UDim2.fromOffset(#logoRows[1] * 2, 6), Visible = false, ZIndex = 2, Parent = logo })
    if logoLids then pixelArt(lids, logoLids, 2, logoPalette, Vector2.zero, 2) end

    local indicator = box({ Size = UDim2.fromOffset(2, 16), BackgroundColor3 = C.Text, ZIndex = 3, Parent = rail })

    local navs, pages, tabOrder = {}, {}, {}
    local currentPage

    local function iconButton(y, icon)
        local b = button({
            Position = UDim2.fromOffset(12, y),
            Size = UDim2.fromOffset(36, 36),
            BackgroundColor3 = C.Panel,
            Parent = rail,
        }, { corner(4) })
        local w = #icon[1] * 2
        local frames = pixelArt(b, icon, 2, { ["#"] = C.Faint }, Vector2.new((36 - w) / 2, 11), 2)
        return b, frames
    end

    local function paint(frames, color, t)
        for _, f in ipairs(frames) do tween(f, t or 0.2, { BackgroundColor3 = color }) end
    end

    -- ───────────── content area / header ─────────────
    local content = box({ Name = "Content", Position = UDim2.fromOffset(RAIL, 0), Size = UDim2.fromOffset(CW, H), Parent = win })
    local topDrag = box({ Name = "TopDrag", Size = UDim2.fromOffset(CW - 120, TOP), Active = true, Parent = content })
    local title = text({ Text = cfg.Title or "", FontFace = F.Bold, TextSize = 16,
        Position = UDim2.fromOffset(PX, 18), Size = UDim2.fromOffset(200, 20), Parent = content })

    local pageArea = box({
        Name = "Pages",
        Position = UDim2.fromOffset(0, TOP),
        Size = UDim2.fromOffset(CW, PAGE_H),
        ClipsDescendants = true,
        Parent = content,
    })
    local function page(name)
        local p = box({ Name = name, Size = UDim2.fromOffset(CW, PAGE_H), Visible = false, Parent = pageArea })
        pages[name] = p
        return p
    end

    -- ───────────── master pill (Armed / Idle) ─────────────
    local master = cfg.Master
    local showMaster = master ~= false
    master = type(master) == "table" and master or {}
    local armed = register("Armed", master.Default ~= false)
    local pill = button({
        Name = "Master",
        Position = UDim2.fromOffset(CW - PX - 84, 14),
        Size = UDim2.fromOffset(84, 28),
        BackgroundColor3 = C.Panel,
        Visible = showMaster,
        Parent = content,
    }, { corner(4) })
    local pillScale = new("UIScale", { Parent = pill })
    local ring = box({ AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(15, 14),
        Size = UDim2.fromOffset(6, 6), BackgroundColor3 = C.Green, BackgroundTransparency = 1, ZIndex = 1, Parent = pill })
    local dot = box({ Position = UDim2.fromOffset(12, 11), Size = UDim2.fromOffset(6, 6),
        BackgroundColor3 = C.Green, ZIndex = 2, Parent = pill })
    local pillText = text({ Text = master.OnText or "Armed", TextSize = 13, Position = UDim2.fromOffset(26, 0),
        Size = UDim2.new(1, -30, 1, 0), Parent = pill })
    hoverColor(pill, C.Panel, C.Hover)

    -- ───────────── shared animation state / controls ─────────────
    local tickers = {}
    local KNOB, CTRL_H = 18, 22
    local PILL = UDim.new(1, 0)
    local squashes = {}

    local function sparkFill(track)
        local fill = box({ Size = UDim2.fromOffset(0, CTRL_H), BackgroundColor3 = Color3.new(1, 1, 1),
            ClipsDescendants = true, ZIndex = 2, Parent = track }, { new("UICorner", { CornerRadius = PILL }) })
        local gradient = new("UIGradient", { Color = ColorSequence.new(gray(40), gray(150)), Parent = fill })
        local sparks = {}
        for i = 1, 14 do
            local size = i % 3 == 0 and 3 or 2
            sparks[i] = {
                frame = box({ Size = UDim2.fromOffset(size, size), BackgroundColor3 = Color3.new(1, 1, 1),
                    BackgroundTransparency = 1, ZIndex = 3, Parent = fill }, { new("UICorner", { CornerRadius = PILL }) }),
                x = math.random() * 140, y = 5 + math.random() * (CTRL_H - 10 - size),
                speed = 6 + math.random() * 16, phase = math.random() * 6.28, freq = 2 + math.random() * 3,
            }
        end
        local spark = { fill = fill, gradient = gradient, active = 0 }
        tickers[#tickers + 1] = function(dt, t)
            local width = math.max(fill.Size.X.Offset, fill.AbsoluteSize.X / math.max(scale.Scale, 0.01), 1)
            local hidden = fill.BackgroundTransparency
            for i, s in ipairs(sparks) do
                s.x = (s.x + s.speed * dt) % width
                s.frame.Position = UDim2.fromOffset(math.floor(s.x), math.floor(s.y))
                local twinkle = 0.5 + 0.5 * math.sin(t * s.freq + s.phase)
                local alpha = 0.1 + 0.8 * (1 - twinkle)
                s.frame.BackgroundTransparency = i <= spark.active and (alpha + (1 - alpha) * hidden) or 1
            end
        end
        return spark
    end

    local function makeKnob(track)
        local knob = box({ AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(KNOB, KNOB),
            BackgroundColor3 = C.Text, ZIndex = 5, Parent = track }, { new("UICorner", { CornerRadius = PILL }) })
        local edge = new("UIStroke", { Color = Color3.new(0, 0, 0), Transparency = 0.55, Thickness = 1, Parent = knob })
        local squash = new("UIScale", { Parent = knob })
        squashes[#squashes + 1] = squash
        return knob, squash, edge
    end

    local function pressable(trigger, squash)
        on(trigger.InputBegan, function(input)
            if isPress(input) then tween(squash, 0.12, { Scale = 1.15 }) end
        end)
    end
    on(UserInputService.InputEnded, function(input)
        if not isPress(input) then return end
        for _, s in ipairs(squashes) do
            if s.Scale ~= 1 then tween(s, 0.3, { Scale = 1 }, Enum.EasingStyle.Back) end
        end
    end)

    local SW_W = 40
    local function switch(parent, position, initial, onChange, trigger, onRender)
        local track = box({ Position = position, Size = UDim2.fromOffset(SW_W, CTRL_H), BackgroundColor3 = C.Raise, Parent = parent },
            { new("UICorner", { CornerRadius = PILL }) })
        local spark = sparkFill(track)
        spark.active = 8
        local knob, squash = makeKnob(track)
        pressable(trigger, squash)
        local state = initial
        local function render(animate)
            local t = animate and 0.3 or 0
            tween(knob, t, {
                Position = UDim2.fromOffset(state and SW_W - 11 or 11, 11),
                BackgroundColor3 = state and C.Text or gray(150),
            })
            tween(spark.fill, t, {
                Size = UDim2.fromOffset(state and SW_W or KNOB + 4, CTRL_H),
                BackgroundTransparency = state and 0 or 1,
            })
            if onRender then onRender(state, animate) end
        end
        render(false)
        on(trigger.Activated, function()
            state = not state
            render(true)
            onChange(state)
        end)
        return function(value)
            state = value
            render(true)
        end, function() return state end
    end

    local function slider(parent, position, min, max, initial, onChange)
        local count = max - min + 1
        local TW = 138
        local first = KNOB / 2 + 2
        local step = (TW - first * 2) / (count - 1)
        local track = button({ Position = position, Size = UDim2.fromOffset(TW, CTRL_H), BackgroundColor3 = C.Raise, Parent = parent },
            { new("UICorner", { CornerRadius = PILL }) })
        local spark = sparkFill(track)
        local marks = {}
        for i = 1, count do
            marks[i] = text({ Text = tostring(min + i - 1), FontFace = F.Medium, TextSize = 11, TextColor3 = C.Faint,
                TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 4,
                Position = UDim2.fromOffset(first + (i - 1) * step - 9, 0), Size = UDim2.fromOffset(18, CTRL_H), Parent = track })
        end
        local knob, squash = makeKnob(track)
        pressable(track, squash)
        local knobText = text({ Text = tostring(initial), FontFace = F.Bold, TextSize = 11, TextColor3 = C.Bg,
            TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 6, Size = UDim2.fromScale(1, 1), Parent = knob })

        local value = initial - min + 1
        spark.active = 2 + value * 2
        local function setCenter(c)
            local center = math.clamp(c, first, TW - first)
            knob.Position = UDim2.fromOffset(math.floor(center + 0.5), 11)
            spark.fill.Size = UDim2.fromOffset(math.floor(center + KNOB / 2 + 2.5), CTRL_H)
            local f = (center - first) / (TW - first * 2)
            spark.gradient.Color = ColorSequence.new(gray(40), gray(math.floor(60 + 110 * f)))
            for i, m in ipairs(marks) do
                m.TextColor3 = first + (i - 1) * step < center and C.Text or C.Faint
            end
        end
        local anim = new("NumberValue", { Value = first + (value - 1) * step, Parent = track })
        on(anim.Changed, setCenter)
        setCenter(anim.Value)

        local snapTween
        local function moveTo(c, animate)
            if snapTween then snapTween:Cancel() snapTween = nil end
            if animate then snapTween = tween(anim, 0.35, { Value = c }) else anim.Value = c end
        end
        local function show(n)
            value = n
            spark.active = 2 + n * 2
            knobText.Text = tostring(min + n - 1)
        end
        local function pick(n)
            if n == value then return end
            show(n)
            onChange(min + n - 1)
        end
        local function nearest(c)
            return math.clamp(math.floor((c - first) / step + 0.5) + 1, 1, count)
        end
        local function centerFromX(x)
            return math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X * TW, first, TW - first)
        end

        local dragInput
        on(track.InputBegan, function(input)
            if not isPress(input) then return end
            dragInput = input
            local c = centerFromX(input.Position.X)
            moveTo(c, true)
            pick(nearest(c))
        end)
        on(UserInputService.InputChanged, function(input)
            if not dragInput then return end
            if not tracks(dragInput, input) then return end
            local c = centerFromX(input.Position.X)
            moveTo(c, false)
            pick(nearest(c))
        end)
        on(UserInputService.InputEnded, function(input)
            if dragInput and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1) then
                dragInput = nil
                moveTo(first + (value - 1) * step, true)
            end
        end)

        return function(raw)
            show(math.clamp(raw - min + 1, 1, count))
            moveTo(first + (value - 1) * step, true)
        end, function() return min + value - 1 end
    end

    local function smallButton(parent, label, color)
        local b = button({
            Text = label, FontFace = F.Medium, TextSize = 13, TextColor3 = color or C.Sub,
            AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 8),
            AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 24),
            BackgroundColor3 = C.Raise, Parent = parent,
        }, { corner(3), pad(0, 10, 0, 10) })
        hoverColor(b, C.Raise, C.Edge)
        return b
    end

    -- ───────────── toasts ─────────────
    local toastHolder = box({
        Name = "Toasts",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -24, 1, -24),
        Size = UDim2.fromOffset(260, 400),
        Parent = gui,
    }, {
        new("UIListLayout", {
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })
    local toastScale = new("UIScale", { Parent = toastHolder })
    local toastOrder = 0

    function Window:Toast(heading, body, mono, kind)
        toastOrder += 1
        local slot = box({ LayoutOrder = toastOrder, Size = UDim2.fromOffset(260, 56), Parent = toastHolder })
        local card = box({
            Position = UDim2.fromOffset(300, 0), Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = C.Bg, Parent = slot,
        }, { corner(6), stroke(C.Line) })
        box({ Position = UDim2.fromOffset(14, 16), Size = UDim2.fromOffset(6, 6),
            BackgroundColor3 = kind == "warn" and C.Red or C.Green, Parent = card })
        text({ Text = heading, TextSize = 13, Position = UDim2.fromOffset(28, 11), Size = UDim2.new(1, -42, 0, 16), Parent = card })
        text({ Text = body, FontFace = mono and F.Mono or F.Book, TextSize = mono and 12 or 13, TextColor3 = C.Sub,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Position = UDim2.fromOffset(28, 29), Size = UDim2.new(1, -42, 0, 16), Parent = card })
        local bar = box({ Position = UDim2.new(0, 0, 1, -2), Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = C.Raise, Parent = card })
        tween(card, 0.45, { Position = UDim2.fromOffset(0, 0) })
        tween(bar, 4, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)
        task.delay(4, function()
            if not card.Parent then return end
            tween(card, 0.3, { Position = UDim2.fromOffset(300, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In).Completed:Connect(function()
                slot:Destroy()
            end)
        end)
    end

    -- ───────────── logging (routes to the active console) ─────────────
    function Window:Log(message, kind, rich)
        if cfg.LogPrefix then
            print("[" .. cfg.LogPrefix .. "] [" .. os.date("%H:%M:%S") .. "] " .. (tostring(message):gsub("<[^>]->", "")))
        end
        if Window._console then return Window._console:Add(message, kind, rich) end
    end
    function Window:LogCode(code, prefix, kind)
        local chip = '<font face="RobotoMono">' .. esc(code) .. "</font>"
        return Window:Log((prefix and (esc(prefix) .. "  ") or "") .. chip, kind or "code", true)
    end

    local function onOff(v) return v and "on" or "off" end
    Window.OnOff = onOff

    -- ───────────── master pill logic ─────────────
    on(pill.InputBegan, function(input)
        if isPress(input) then tween(pillScale, 0.12, { Scale = 0.95 }) end
    end)
    squashes[#squashes + 1] = pillScale

    local function renderArmed(animate)
        local t = animate and 0.25 or 0
        pillText.Text = armed and (master.OnText or "Armed") or (master.OffText or "Idle")
        tween(dot, t, { BackgroundColor3 = armed and C.Green or C.Faint })
        tween(pillText, t, { TextColor3 = armed and C.Text or C.Sub })
    end
    local ringPhase = 0
    tickers[#tickers + 1] = function(dt)
        if armed then
            ringPhase = (ringPhase + dt / 1.8) % 1
            local size = 6 + 10 * ringPhase
            ring.Size = UDim2.fromOffset(size, size)
            ring.BackgroundTransparency = 0.5 + 0.5 * ringPhase
        else
            ring.BackgroundTransparency = 1
        end
    end
    renderArmed(false)

    function Window:SetMaster(value, silent)
        if armed == value then return end
        armed = value
        changed("Armed", value)
        renderArmed(true)
        if master.Callback then master.Callback(value, silent) end
    end
    function Window:GetMaster() return armed end
    on(pill.Activated, function() Window:SetMaster(not armed) end)

    -- ───────────── tab selection ─────────────
    function Window:SetTitle(t) title.Text = t end

    local function selectPage(name, animate)
        if currentPage == name or not navs[name] then return end
        currentPage = name
        title.Text = name
        for n, nav in pairs(navs) do
            local active = n == name
            tween(nav.button, animate and 0.2 or 0, { BackgroundColor3 = active and C.Raise or C.Panel })
            paint(nav.frames, active and C.Text or C.Faint, animate and 0.2 or 0)
        end
        tween(indicator, animate and 0.35 or 0, { Position = UDim2.fromOffset(0, navs[name].y + 10) })
        for n, p in pairs(pages) do p.Visible = n == name end
        if animate then
            pages[name].Position = UDim2.fromOffset(0, 10)
            tween(pages[name], 0.35, { Position = UDim2.fromOffset(0, 0) })
        end
    end
    function Window:SelectTab(name, animate) selectPage(name, animate) end

    -- ───────────── layout constants for tiles ─────────────
    local TILE_W, TILE_H = (CW - PX * 2 - 8) / 2, (PAGE_H - 28) / 2
    local CONTROL_Y = TILE_H - 14 - CTRL_H
    local CONTROL_POS = UDim2.fromOffset(14, CONTROL_Y)
    Window.TileSize = Vector2.new(TILE_W, TILE_H)

    local rebindFn
    local keybinds = {}

    local function initial(flag, default)
        if flag then return register(flag, default) end
        return default
    end
    local function commit(flag, cb, value)
        if flag then changed(flag, value) end
        if cb then cb(value) end
    end

    -- ═════════════ Window:CreateTab ═════════════
    function Window:CreateTab(tcfg)
        tcfg = tcfg or {}
        local name = tcfg.Name or ("Tab " .. (#tabOrder + 1))
        local p = page(name)
        local container = p
        if tcfg.Scroll ~= false then
            container = new("ScrollingFrame", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = C.Faint,
                ScrollingDirection = Enum.ScrollingDirection.Y,
                CanvasSize = UDim2.new(),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                Parent = p,
            }, { pad(0, 0, tcfg.BottomPadding or 0, 0) })
        end

        local Tab = {
            Name = name, Page = p, Container = container,
            Spacing = tcfg.Spacing or 8,
            _y = 0, _tileCol = 0, _tileRowY = 0,
        }

        -- rail button
        local index = #tabOrder + 1
        tabOrder[index] = name
        local y = 68 + (index - 1) * 40
        local b, frames = iconButton(y, resolveIcon(tcfg.Icon) or ICONS.settings)
        navs[name] = { button = b, frames = frames, y = y }
        on(b.MouseEnter, function()
            if currentPage ~= name then tween(b, 0.15, { BackgroundColor3 = C.Hover }); paint(frames, C.Sub, 0.15) end
        end)
        on(b.MouseLeave, function()
            if currentPage ~= name then tween(b, 0.2, { BackgroundColor3 = C.Panel }); paint(frames, C.Faint) end
        end)
        on(b.Activated, function() selectPage(name, true) end)
        if not currentPage then selectPage(name, false) end

        Window.Tabs[name] = Tab

        local function place(h, gap, at)
            Tab._tileCol = 0
            at = at or Tab._y
            Tab._y = at + h + (gap == nil and Tab.Spacing or gap)
            return at
        end
        function Tab:Skip(px) Tab._y += px end
        Tab.AddSpacer = Tab.Skip

        -- ───────── tiles (2-column grid) ─────────
        local function makeTile(label, icon, o)
            local x, ty
            if o.Column and o.Row then
                Tab._tileCol = 0
                Tab._y = math.max(Tab._y, o.Row * (TILE_H + 8))
                x = PX + (o.Column - 1) * (TILE_W + 8)
                ty = (o.Row - 1) * (TILE_H + 8)
            elseif Tab._tileCol == 1 then
                x = PX + (TILE_W + 8)
                ty = Tab._tileRowY
                Tab._tileCol = 2
            else
                x = PX
                ty = Tab._y
                Tab._tileRowY = ty
                Tab._y = ty + TILE_H + 8
                Tab._tileCol = 1
            end
            local t = button({
                Name = label,
                Position = UDim2.fromOffset(x, ty),
                Size = UDim2.fromOffset(TILE_W, TILE_H),
                BackgroundColor3 = C.Panel,
                Parent = container,
            }, { corner(4) })
            text({ Text = label, TextSize = 14, Position = UDim2.fromOffset(14, 14), Size = UDim2.new(1, -56, 0, 18), Parent = t })
            hoverColor(t, C.Panel, C.Hover)
            local iconFrames = {}
            if icon then
                iconFrames = pixelArt(t, icon, 2, { ["#"] = C.Faint }, Vector2.new(TILE_W - 14 - #icon[1] * 2, 16), 2)
            end
            return t, iconFrames
        end

        function Tab:AddTile(o)
            o = o or {}
            local t, frames = makeTile(o.Label or "", resolveIcon(o.Icon), o)
            return { Frame = t, IconFrames = frames }
        end

        function Tab:AddToggleTile(o)
            o = o or {}
            local value = initial(o.Flag, o.Default == true)
            local t, iconFrames = makeTile(o.Label or "", resolveIcon(o.Icon), o)
            local setter, getter = switch(t, CONTROL_POS, value, function(v)
                commit(o.Flag, o.Callback, v)
            end, t, function(state, animate)
                paint(iconFrames, state and C.Text or C.Faint, animate and 0.3 or 0)
            end)
            local El = { Frame = t }
            function El:Set(v, silent) setter(v) if not silent then commit(o.Flag, o.Callback, v) end end
            function El:Get() return getter() end
            return El
        end

        function Tab:AddSliderTile(o)
            o = o or {}
            local min, max = o.Min or 1, o.Max or 5
            local value = math.clamp(initial(o.Flag, o.Default or min), min, max)
            local t = makeTile(o.Label or "", resolveIcon(o.Icon), o)
            local setter, getter = slider(t, CONTROL_POS, min, max, value, function(n)
                commit(o.Flag, o.Callback, n)
            end)
            local El = { Frame = t }
            function El:Set(n, silent)
                n = math.clamp(math.floor(n), min, max)
                setter(n)
                if not silent then commit(o.Flag, o.Callback, n) end
            end
            function El:Get() return getter() end
            return El
        end

        -- ───────── full-width button (e.g. "Cancel current code") ─────────
        function Tab:AddButton(o)
            o = o or {}
            local h = o.Height or 32
            local at = place(h, o.Gap, o.Y)
            local b = button({
                Name = o.Name or o.Text or "Button",
                Position = UDim2.fromOffset(PX, at),
                Size = UDim2.fromOffset(CW - PX * 2, h),
                BackgroundColor3 = C.Raise,
                Parent = container,
            }, { corner(4) })
            local label = text({
                Text = o.Text or "Button",
                TextSize = 14, TextColor3 = C.Sub,
                TextXAlignment = Enum.TextXAlignment.Center,
                Size = UDim2.fromScale(1, 1),
                Parent = b,
            })
            hoverColor(b, C.Raise, C.Hover)
            on(b.Activated, function() if o.Callback then o.Callback() end end)
            local El = { Frame = b, Label = label }
            function El:SetText(t) label.Text = t end
            return El
        end

        -- ───────── icon + label + switch row (56px, "Admin" style) ─────────
        function Tab:AddToggleRow(o)
            o = o or {}
            local h = o.Height or 56
            local value = initial(o.Flag, o.Default == true)
            local at = place(h, o.Gap, o.Y)
            local r = button({
                Name = o.Label or "Row",
                Position = UDim2.fromOffset(PX, at),
                Size = UDim2.fromOffset(CW - PX * 2, h),
                BackgroundColor3 = C.Panel,
                Parent = container,
            }, { corner(4) })
            hoverColor(r, C.Panel, C.Hover)
            local icon = resolveIcon(o.Icon)
            local iconFrames = icon and pixelArt(r, icon, 2, { ["#"] = C.Faint }, Vector2.new(14, (h - 14) / 2), 2) or {}
            text({ Text = o.Label or "", TextSize = 14, Position = UDim2.fromOffset(icon and 42 or 14, 0),
                Size = UDim2.new(1, -120, 1, 0), Parent = r })
            local setter, getter = switch(r, UDim2.new(1, -14 - SW_W, 0, (h - CTRL_H) / 2), value, function(v)
                commit(o.Flag, o.Callback, v)
            end, r, function(state, animate)
                paint(iconFrames, state and C.Text or C.Faint, animate and 0.3 or 0)
            end)
            local El = { Frame = r }
            function El:Set(v, silent) setter(v) if not silent then commit(o.Flag, o.Callback, v) end end
            function El:Get() return getter() end
            return El
        end

        -- ───────── 40px setting rows ─────────
        local function settingRow(label, gap, at)
            at = place(40, gap, at)
            local r = box({
                Position = UDim2.fromOffset(PX, at),
                Size = UDim2.fromOffset(CW - PX * 2, 40),
                BackgroundColor3 = C.Panel,
                Parent = container,
            }, { corner(4) })
            text({ Text = label, TextSize = 14, Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -140, 1, 0), Parent = r })
            return r
        end

        function Tab:AddSwitch(o)
            o = o or {}
            local value = initial(o.Flag, o.Default == true)
            local row = settingRow(o.Label or "", o.Gap, o.Y)
            local rowHit = button({ Size = UDim2.fromScale(1, 1), Parent = row })
            local setter, getter = switch(row, UDim2.new(1, -8 - SW_W, 0, 9), value, function(v)
                commit(o.Flag, o.Callback, v)
            end, rowHit)
            local El = { Frame = row }
            function El:Set(v, silent) setter(v) if not silent then commit(o.Flag, o.Callback, v) end end
            function El:Get() return getter() end
            return El
        end

        function Tab:AddActionButton(o)
            o = o or {}
            local row = settingRow(o.Label or "", o.Gap, o.Y)
            local b = smallButton(row, o.Text or "Run", o.Color)
            on(b.Activated, function() if o.Callback then o.Callback() end end)
            return { Frame = row, Button = b }
        end

        function Tab:AddKeybind(o)
            o = o or {}
            local value
            if o.ToggleKey then
                value = toggleKey
            else
                value = initial(o.Flag, o.Default or Enum.KeyCode.RightShift)
            end
            local row = settingRow(o.Label or "Keybind", o.Gap, o.Y)
            local keycap = smallButton(row, keyName(value))
            keycap.FontFace = F.Mono
            keycap.TextSize = 12
            on(keycap.Activated, function()
                keycap.Text = "Press a key"
                keycap.TextColor3 = C.Text
                rebindFn = function(input)
                    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                    rebindFn = nil
                    if input.KeyCode ~= Enum.KeyCode.Escape then
                        value = input.KeyCode
                        if o.ToggleKey then
                            toggleKey = value
                            changed("ToggleKey", value)
                            if o.Callback then o.Callback(value) end
                        else
                            commit(o.Flag, o.Callback, value)
                        end
                    end
                    keycap.Text = keyName(value)
                    keycap.TextColor3 = C.Sub
                end
            end)
            if o.OnPress and not o.ToggleKey then
                keybinds[#keybinds + 1] = { get = function() return value end, press = o.OnPress }
            end
            local El = { Frame = row, Button = keycap }
            function El:Get() return value end
            function El:Set(code)
                value = code
                keycap.Text = keyName(code)
                if o.ToggleKey then toggleKey = code end
            end
            return El
        end

        function Tab:AddChoice(o)
            o = o or {}
            local options = o.Options or {}
            local current = initial(o.Flag, o.Default or options[1])
            local row = settingRow(o.Label or "", o.Gap, o.Y)
            local choices = box({
                AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 8),
                AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 24), Parent = row,
            }, {
                new("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 4),
                }),
            })
            local btns = {}
            local function render()
                for n, bt in pairs(btns) do
                    local active = n == current
                    tween(bt, 0.2, { BackgroundColor3 = active and C.Text or C.Raise, TextColor3 = active and C.Bg or C.Sub })
                end
            end
            for i, optName in ipairs(options) do
                local bt = button({
                    Text = optName:sub(1, 1):upper() .. optName:sub(2), FontFace = F.Medium, TextSize = 12, LayoutOrder = i,
                    AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 24),
                    BackgroundColor3 = C.Raise, TextColor3 = C.Sub, Parent = choices,
                }, { corner(3), pad(0, 8, 0, 8) })
                btns[optName] = bt
                on(bt.Activated, function()
                    current = optName
                    commit(o.Flag, o.Callback, optName)
                    render()
                end)
            end
            render()
            local El = { Frame = row }
            function El:Get() return current end
            function El:Set(v, silent)
                current = v
                render()
                if not silent then commit(o.Flag, o.Callback, v) end
            end
            return El
        end

        -- ───────── profile header (avatar + names) ─────────
        function Tab:AddProfile(o)
            o = o or {}
            local at = place(40, o.Gap == nil and 16 or o.Gap, o.Y)
            local avatar = new("ImageLabel", {
                Position = UDim2.fromOffset(PX, at), Size = UDim2.fromOffset(40, 40),
                BackgroundColor3 = C.Panel, BorderSizePixel = 0, Image = "", Parent = container,
            }, { corner(4) })
            task.spawn(function()
                local ok, image = pcall(function()
                    return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                end)
                if ok and avatar.Parent then avatar.Image = image end
            end)
            text({ Text = player.DisplayName, TextSize = 14, TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2.fromOffset(PX + 52, at + 2), Size = UDim2.fromOffset(240, 18), Parent = container })
            text({ Text = "@" .. player.Name, FontFace = F.Mono, TextSize = 12, TextColor3 = C.Faint, TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2.fromOffset(PX + 52, at + 22), Size = UDim2.fromOffset(240, 16), Parent = container })
            return { Avatar = avatar }
        end

        -- ───────── dropdown (150x22 button + floating list) ─────────
        function Tab:AddDropdown(o)
            o = o or {}
            local DD_W, DD_H, ROW = o.Width or 150, 22, 24
            local options = o.Options or {}
            local at = place(DD_H, o.Gap, o.Y)
            local current = initial(o.Flag, o.Default or (options[1] and options[1].Value))
            local ddBtn = new("TextButton", {
                Position = UDim2.fromOffset(PX, at), Size = UDim2.fromOffset(DD_W, DD_H),
                BackgroundColor3 = C.Panel, BorderSizePixel = 0, AutoButtonColor = false,
                Text = "", ZIndex = 20, Parent = container,
            }, { corner(4) })
            local ddLabel = text({ Text = "", TextSize = 13, TextColor3 = C.Sub, ZIndex = 21,
                Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -30, 1, 0), Parent = ddBtn })
            text({ Text = "\u{25BE}", TextSize = 12, TextColor3 = C.Faint, ZIndex = 21,
                TextXAlignment = Enum.TextXAlignment.Center,
                Position = UDim2.new(1, -20, 0, 0), Size = UDim2.fromOffset(16, DD_H), Parent = ddBtn })
            hoverColor(ddBtn, C.Panel, C.Hover)
            local list = new("Frame", {
                Position = UDim2.fromOffset(PX, at + DD_H + 2), Size = UDim2.fromOffset(DD_W, #options * ROW),
                BackgroundColor3 = C.Raise, BorderSizePixel = 0, Visible = false, ZIndex = 30, Parent = container,
            }, { corner(4) })
            local byValue = {}
            for _, opt in ipairs(options) do byValue[opt.Value] = opt end
            local El = { Frame = ddBtn }
            local function refresh()
                local opt = byValue[current]
                ddLabel.Text = opt and (opt.Text or tostring(opt.Value)) or ""
            end
            for i, opt in ipairs(options) do
                local ob = new("TextButton", {
                    Position = UDim2.fromOffset(0, (i - 1) * ROW), Size = UDim2.new(1, 0, 0, ROW),
                    BackgroundTransparency = 1, AutoButtonColor = false, Text = "", ZIndex = 31, Parent = list,
                })
                text({ Text = opt.ListText or opt.Text or tostring(opt.Value), TextSize = 13, ZIndex = 32,
                    Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -20, 1, 0), Parent = ob })
                on(ob.Activated, function()
                    list.Visible = false
                    if current == opt.Value then return end
                    current = opt.Value
                    refresh()
                    commit(o.Flag, o.Callback, opt.Value)
                end)
            end
            on(ddBtn.Activated, function() list.Visible = not list.Visible end)
            refresh()
            function El:Get() return current end
            function El:Set(v, silent)
                current = v
                refresh()
                if not silent then commit(o.Flag, o.Callback, v) end
            end
            function El:SetText(optValue, t)
                if byValue[optValue] then byValue[optValue].Text = t end
                refresh()
            end
            return El
        end

        -- ───────── key / token input (input + Connect + status line) ─────────
        function Tab:AddKeyInput(o)
            o = o or {}
            local CONNECT_W = 88
            local at = place(60, o.Gap, o.Y)
            local input = new("TextBox", {
                Position = UDim2.fromOffset(PX, at),
                Size = UDim2.fromOffset(CW - PX * 2 - 8 - CONNECT_W, 36),
                BackgroundColor3 = C.Panel,
                BorderSizePixel = 0,
                ClearTextOnFocus = false,
                Text = "",
                PlaceholderText = o.Placeholder or "Paste your key...",
                PlaceholderColor3 = C.Faint,
                TextColor3 = C.Text,
                FontFace = F.Mono,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = container,
            }, { corner(4), pad(0, 12, 0, 12) })
            local connectBtn = button({
                Text = o.ConnectText or "Connect", FontFace = F.Medium, TextSize = 13, TextColor3 = C.Bg,
                Position = UDim2.fromOffset(CW - PX - CONNECT_W, at), Size = UDim2.fromOffset(CONNECT_W, 36),
                BackgroundColor3 = C.Text, Parent = container,
            }, { corner(4) })
            hoverColor(connectBtn, C.Text, C.Sub)
            local status = text({ Text = "", FontFace = F.Book, TextSize = 12, TextColor3 = C.Faint,
                Position = UDim2.fromOffset(PX, at + 44), Size = UDim2.fromOffset(240, 16), Parent = container })
            local disconnectBtn = button({
                Text = o.DisconnectText or "Disconnect", FontFace = F.Medium, TextSize = 12, TextColor3 = C.Faint,
                TextXAlignment = Enum.TextXAlignment.Right,
                Position = UDim2.fromOffset(CW - PX - 90, at + 44), Size = UDim2.fromOffset(90, 16), Parent = container,
            })
            on(disconnectBtn.MouseEnter, function() tween(disconnectBtn, 0.15, { TextColor3 = C.Red }) end)
            on(disconnectBtn.MouseLeave, function() tween(disconnectBtn, 0.2, { TextColor3 = C.Faint }) end)

            local El = { Input = input, Status = status }
            function El:SetStatus(t, color) status.Text = t status.TextColor3 = color or C.Faint end
            function El:SetConnected(connected, statusText)
                if connected then
                    tween(connectBtn, 0.2, { BackgroundColor3 = C.Green })
                    connectBtn.Text = o.ConnectedText or "Connected"
                    status.Text = statusText or ""
                    status.TextColor3 = C.Green
                    disconnectBtn.Visible = true
                else
                    tween(connectBtn, 0.2, { BackgroundColor3 = C.Text })
                    connectBtn.Text = o.ConnectText or "Connect"
                    status.Text = statusText or "Not connected"
                    status.TextColor3 = C.Faint
                    disconnectBtn.Visible = false
                end
            end
            function El:SetPlaceholder(t) input.PlaceholderText = t end
            function El:GetText() return (input.Text:gsub("%s", "")) end
            function El:Clear() input.Text = "" end
            El:SetConnected(o.Connected == true, o.StatusText)
            local function submit()
                local key = El:GetText()
                if key == "" then return end
                if o.OnSubmit then o.OnSubmit(key) end
            end
            on(connectBtn.Activated, submit)
            on(input.FocusLost, function(enter) if enter then submit() end end)
            on(disconnectBtn.Activated, function() if o.OnDisconnect then o.OnDisconnect() end end)
            return El
        end

        -- ───────── editable list (input + Add + removable rows) ─────────
        function Tab:AddListEditor(o)
            o = o or {}
            local INPUT_H = 36
            local at = o.Y or Tab._y
            local listH = o.Height or (PAGE_H - at - INPUT_H - 8 - 20)
            place(INPUT_H + 8 + listH, o.Gap, o.Y)
            local items = initial(o.Flag, o.Default or {})
            local input = new("TextBox", {
                Position = UDim2.fromOffset(PX, at),
                Size = UDim2.fromOffset(CW - PX * 2 - 8 - 64, INPUT_H),
                BackgroundColor3 = C.Panel,
                BorderSizePixel = 0,
                ClearTextOnFocus = false,
                Text = "",
                PlaceholderText = o.Placeholder or "Add an item...",
                PlaceholderColor3 = C.Faint,
                TextColor3 = C.Text,
                FontFace = F.Medium,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = container,
            }, { corner(4), pad(0, 12, 0, 12) })
            local addBtn = button({
                Text = o.ButtonText or "Add", FontFace = F.Medium, TextSize = 13, TextColor3 = C.Bg,
                Position = UDim2.fromOffset(CW - PX - 64, at), Size = UDim2.fromOffset(64, INPUT_H),
                BackgroundColor3 = C.Text, Parent = container,
            }, { corner(4) })
            hoverColor(addBtn, C.Text, C.Sub)
            local listFrame = new("ScrollingFrame", {
                Position = UDim2.fromOffset(PX, at + INPUT_H + 8),
                Size = UDim2.fromOffset(CW - PX * 2, listH),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = C.Faint,
                CanvasSize = UDim2.new(),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                Parent = container,
            })
            new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), Parent = listFrame })

            local El = { Items = items, Frame = listFrame }
            local function fire(action, word)
                if o.Flag then changed(o.Flag, items) end
                if o.Callback then o.Callback(items, action, word) end
            end
            local render
            local function remove(word, silent)
                for i, w in ipairs(items) do
                    if w == word then table.remove(items, i) break end
                end
                render()
                if not silent then fire("remove", word) end
            end
            render = function()
                for _, child in ipairs(listFrame:GetChildren()) do
                    if child:IsA("Frame") then child:Destroy() end
                end
                if #items == 0 then
                    local empty = box({ Size = UDim2.new(1, 0, 0, 32), Parent = listFrame })
                    text({ Text = o.EmptyText or "Nothing here yet", FontFace = F.Book, TextSize = 13, TextColor3 = C.Faint,
                        Size = UDim2.fromScale(1, 1), Parent = empty })
                    return
                end
                for i, word in ipairs(items) do
                    local row = box({ LayoutOrder = i, Size = UDim2.new(1, -4, 0, 32), BackgroundColor3 = C.Panel, Parent = listFrame }, { corner(4) })
                    text({ Text = word, FontFace = F.Mono, TextSize = 12, TextTruncate = Enum.TextTruncate.AtEnd,
                        Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -56, 1, 0), Parent = row })
                    local rm = button({
                        Text = "Remove", FontFace = F.Medium, TextSize = 12, TextColor3 = C.Faint,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 0), Size = UDim2.fromOffset(60, 32),
                        Parent = row,
                    })
                    rm.MouseEnter:Connect(function() tween(rm, 0.15, { TextColor3 = C.Red }) end)
                    rm.MouseLeave:Connect(function() tween(rm, 0.2, { TextColor3 = C.Faint }) end)
                    rm.Activated:Connect(function() remove(word) end)
                end
            end
            local function add(raw, silent)
                local normalize = o.Normalize or function(s) return (s:lower():match("^%s*(.-)%s*$") or "") end
                local word = normalize(raw)
                if word == "" then return false end
                for _, w in ipairs(items) do
                    if w == word then return false end
                end
                table.insert(items, word)
                render()
                if not silent then fire("add", word) end
                return true
            end
            local function submit()
                local raw = input.Text
                input.Text = ""
                add(raw)
            end
            on(addBtn.Activated, submit)
            on(input.FocusLost, function(enter) if enter then submit() end end)
            render()
            function El:Add(word, silent) return add(word, silent) end
            function El:Remove(word, silent) remove(word, silent) end
            function El:Refresh() render() end
            function El:Get() return items end
            return El
        end

        -- ───────── console / log view ─────────
        function Tab:AddConsole(o)
            o = o or {}
            local LOG_W = CW - PX * 2
            local LOG_H = o.Height or (PAGE_H - 48)
            local at = o.Y or Tab._y
            place(LOG_H + 12 + 16, o.Gap, o.Y)
            local logFrame = box({ Position = UDim2.fromOffset(PX, at), Size = UDim2.fromOffset(LOG_W, LOG_H),
                BackgroundColor3 = C.Panel, Parent = container }, { corner(4) })
            local console = new("ScrollingFrame", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = C.Faint,
                ScrollingDirection = Enum.ScrollingDirection.Y,
                CanvasSize = UDim2.new(),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                Parent = logFrame,
            }, { pad(12, 14, 12, 14) })
            local consoleLayout = new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = console })
            local emptyText = text({ Text = o.EmptyText or "No activity yet", FontFace = F.Book, TextSize = 13, TextColor3 = C.Faint,
                TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), Parent = logFrame })
            local countText = text({ Text = "0 events", FontFace = F.Book, TextSize = 12, TextColor3 = C.Faint,
                Position = UDim2.fromOffset(PX, at + LOG_H + 12), Size = UDim2.fromOffset(160, 16), Parent = container })
            local clearBtn = button({
                Text = "Clear", FontFace = F.Medium, TextSize = 13, TextColor3 = C.Sub,
                TextXAlignment = Enum.TextXAlignment.Right,
                Position = UDim2.fromOffset(CW - PX - 60, at + LOG_H + 12), Size = UDim2.fromOffset(60, 16), Parent = container,
            })
            on(clearBtn.MouseEnter, function() tween(clearBtn, 0.15, { TextColor3 = C.Text }) end)
            on(clearBtn.MouseLeave, function() tween(clearBtn, 0.2, { TextColor3 = C.Sub }) end)
            on(consoleLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
                task.defer(function()
                    console.CanvasPosition = Vector2.new(0, math.max(0, console.AbsoluteCanvasSize.Y - console.AbsoluteWindowSize.Y))
                end)
            end)

            local KIND_COLOR = { info = C.Text, sys = C.Sub, good = C.Green, bad = C.Red, code = C.Text, ai = C.Text }
            for k, v in pairs(o.KindColors or {}) do KIND_COLOR[k] = v end
            local maxEntries = o.MaxEntries or 80
            local entries, order, total = {}, 0, 0
            local function updateCount()
                countText.Text = total == 1 and "1 event" or (total .. " events")
            end

            local Console = {}
            function Console:Add(message, kind, rich)
                order += 1
                total += 1
                local entry = box({ LayoutOrder = order, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = console })
                local stamp = text({ Text = os.date("%H:%M"), FontFace = F.Mono, TextSize = 12, TextColor3 = C.Faint,
                    TextTransparency = 1, Size = UDim2.fromOffset(40, 16), Parent = entry })
                local body = text({
                    Text = rich and message or esc(message), RichText = true, TextWrapped = true,
                    FontFace = F.Book, TextSize = 13, TextColor3 = KIND_COLOR[kind] or C.Text, TextTransparency = 1,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    Position = UDim2.fromOffset(52, 0), Size = UDim2.new(1, -52, 0, 16),
                    AutomaticSize = Enum.AutomaticSize.Y, Parent = entry,
                })
                tween(stamp, 0.35, { TextTransparency = 0 })
                tween(body, 0.35, { TextTransparency = 0 })
                entries[#entries + 1] = entry
                if #entries > maxEntries then
                    local oldest = entries[1]
                    table.move(entries, 2, #entries, 1)
                    entries[#entries] = nil
                    oldest:Destroy()
                end
                emptyText.Visible = false
                updateCount()
                return body
            end
            function Console:Clear()
                for _, e in ipairs(entries) do e:Destroy() end
                entries, total = {}, 0
                emptyText.Visible = true
                updateCount()
            end
            on(clearBtn.Activated, function() Console:Clear() end)
            if not Window._console or o.Primary then Window._console = Console end
            return Console
        end

        return Tab
    end

    -- ───────────── collapse button ─────────────
    local collapseBtn, collapseFrames = iconButton(H - 46, ICONS.collapse)
    local expandFrames = pixelArt(collapseBtn, ICONS.expand, 2, { ["#"] = C.Faint }, Vector2.new(14, 11), 2)
    for _, f in ipairs(expandFrames) do f.Visible = false end
    hoverColor(collapseBtn, C.Panel, C.Hover)
    local collapsed = false
    on(collapseBtn.Activated, function()
        collapsed = not collapsed
        tween(holder, 0.45, { Size = UDim2.fromOffset(collapsed and RAIL or W, H) })
        tween(railFill, 0.2, { BackgroundTransparency = collapsed and 1 or 0 })
        for _, f in ipairs(collapseFrames) do f.Visible = not collapsed end
        for _, f in ipairs(expandFrames) do f.Visible = collapsed end
    end)

    -- ───────────── dragging ─────────────
    do
        local dragInput, dragStart, startPos
        local function begin(input)
            local kind = input.UserInputType
            if kind ~= Enum.UserInputType.MouseButton1 and kind ~= Enum.UserInputType.Touch then return end
            dragInput, dragStart, startPos = input, input.Position, holder.Position
        end
        on(logoDrag.InputBegan, begin)
        on(topDrag.InputBegan, begin)
        on(UserInputService.InputChanged, function(input)
            if not dragInput then return end
            if not tracks(dragInput, input) then return end
            local delta = input.Position - dragStart
            tween(holder, 0.08, {
                Position = UDim2.new(startPos.X.Scale, math.floor(startPos.X.Offset + delta.X), startPos.Y.Scale, math.floor(startPos.Y.Offset + delta.Y)),
            }, Enum.EasingStyle.Sine)
        end)
        on(UserInputService.InputEnded, function(input)
            if dragInput and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1) then
                dragInput = nil
            end
        end)
    end

    -- ───────────── viewport fit / show & hide ─────────────
    local baseScale, shown, menuVisible = 1, true, false
    local function fit()
        local camera = workspace.CurrentCamera
        if not camera then return end
        local viewport = camera.ViewportSize
        local s = math.min(1, (viewport.Y - 48) / H, (viewport.X - 48) / W)
        if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then s = math.min(s, 0.85) end
        baseScale = math.max(0.5, s)
        toastScale.Scale = baseScale
        if shown then scale.Scale = baseScale end
    end
    local viewportConn
    local function watchCamera()
        if viewportConn then viewportConn:Disconnect() end
        local camera = workspace.CurrentCamera
        if camera then viewportConn = on(camera:GetPropertyChangedSignal("ViewportSize"), fit) end
        fit()
    end
    on(workspace:GetPropertyChangedSignal("CurrentCamera"), watchCamera)
    watchCamera()

    local function setShown(value)
        shown = value
        menuVisible = value
        Window.Assistant.OnMenu(value)
        if value then
            holder.Visible = true
            scale.Scale = baseScale * 0.96
            tween(scale, 0.4, { Scale = baseScale })
        else
            tween(scale, 0.15, { Scale = baseScale * 0.96 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In).Completed:Connect(function()
                if not shown then holder.Visible = false end
            end)
        end
    end
    function Window:SetVisible(value) setShown(value) end
    function Window:Toggle() setShown(not shown) end
    function Window:IsVisible() return shown end
    function Window:GetToggleKey() return toggleKey end
    function Window:SetToggleKey(code)
        toggleKey = code
        changed("ToggleKey", code)
    end

    -- ───────────── intro animation ─────────────
    function Window:PlayIntro(introText, done)
        local MOUTH_CLOSED = {
            "....SSSSSSSSSSSS....",
            "....SMMMMMMMMMMS....",
            "....SSSSSSSSSSSS....",
            "....SSSSSSSSSSSS....",
        }
        local TANK_BACK = {
            "....oooooooooooo....", "....oooooooooooo....", "....oooooooooooo....", "....oooooooooooo....",
            "....oooooooooooo....", "....oooooooooooo....", "....oooooooooooo....",
        }
        local TOILET_PAL = { O = SKIBIDI_PALETTE.O, o = SKIBIDI_PALETTE.o, w = SKIBIDI_PALETTE.w }
        local HEAD_PAL = {}
        for k, v in pairs(SKIBIDI_PALETTE) do
            if not TOILET_PAL[k] then HEAD_PAL[k] = v end
        end
        local function sliceRows(rows, first, last) return table.move(rows, first, last, 1, {}) end

        local IPX, RIM = 8, 17
        local STAGE_W = 280
        local ART_W, ART_H = 20 * IPX, #SKIBIDI * IPX
        local skipped = false
        local function pause(t)
            local stop = os.clock() + t
            while os.clock() < stop and not skipped and gui.Parent do RunService.Heartbeat:Wait() end
        end

        local backdrop = button({ Name = "IntroBackdrop", Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = C.Bg, BackgroundTransparency = 1, ZIndex = 50, Parent = gui })
        on(backdrop.Activated, function() skipped = true end)

        local stage = new("CanvasGroup", {
            Name = "Intro",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(STAGE_W, ART_H + 52),
            BackgroundTransparency = 1,
            GroupTransparency = 1,
            ZIndex = 51,
            Parent = gui,
        })
        local stageScale = new("UIScale", { Scale = baseScale * 0.85, Parent = stage })
        local art = box({ Position = UDim2.fromOffset((STAGE_W - ART_W) / 2, 0), Size = UDim2.fromOffset(ART_W, ART_H), Parent = stage })

        pixelArt(art, TANK_BACK, IPX, TOILET_PAL, Vector2.new(0, 8 * IPX), 1)
        pixelArt(art, sliceRows(SKIBIDI, 1, RIM), IPX, TOILET_PAL, Vector2.zero, 1)
        local headClip = box({ Size = UDim2.fromOffset(ART_W, RIM * IPX), ClipsDescendants = true, ZIndex = 2, Parent = art })
        local head = box({ Position = UDim2.fromOffset(0, RIM * IPX), Size = UDim2.fromOffset(ART_W, RIM * IPX), ZIndex = 2, Parent = headClip })
        pixelArt(head, sliceRows(SKIBIDI, 1, RIM), IPX, HEAD_PAL, Vector2.zero, 2)
        local bigLids = box({ Position = UDim2.fromOffset(0, 6 * IPX), Size = UDim2.fromOffset(ART_W, 3 * IPX), Visible = false, ZIndex = 3, Parent = head })
        pixelArt(bigLids, SKIBIDI_LIDS, IPX, SKIBIDI_PALETTE, Vector2.zero, 3)
        local mouthClosed = box({ Position = UDim2.fromOffset(0, 10 * IPX), Size = UDim2.fromOffset(ART_W, 4 * IPX), Visible = false, ZIndex = 3, Parent = head })
        pixelArt(mouthClosed, MOUTH_CLOSED, IPX, SKIBIDI_PALETTE, Vector2.zero, 3)
        pixelArt(art, sliceRows(SKIBIDI, RIM + 1, #SKIBIDI), IPX, TOILET_PAL, Vector2.new(0, RIM * IPX), 4)

        local titleLabel = text({ Text = introText or "", FontFace = F.Bold, TextSize = 22,
            TextXAlignment = Enum.TextXAlignment.Center, MaxVisibleGraphemes = 0,
            Position = UDim2.fromOffset(0, ART_H + 18), Size = UDim2.fromOffset(STAGE_W, 26), Parent = stage })

        task.spawn(function()
            tween(backdrop, 0.35, { BackgroundTransparency = 0.35 })
            tween(stage, 0.4, { GroupTransparency = 0 })
            tween(stageScale, 0.5, { Scale = baseScale }, Enum.EasingStyle.Back)
            pause(0.35)

            tween(head, 0.6, { Position = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Back)
            pause(0.75)

            for _ = 1, 2 do
                bigLids.Visible = true
                pause(0.1)
                bigLids.Visible = false
                pause(0.14)
            end

            for i = 1, 8 do
                local beat = i % 2 == 1
                mouthClosed.Visible = beat
                head.Position = UDim2.fromOffset(beat and IPX or -IPX, 0)
                pause(0.12)
            end
            mouthClosed.Visible = false
            head.Position = UDim2.fromOffset(0, 0)

            for i = 1, #titleLabel.Text do
                titleLabel.MaxVisibleGraphemes = i
                pause(0.035)
            end
            titleLabel.MaxVisibleGraphemes = -1
            pause(0.9)

            tween(backdrop, 0.3, { BackgroundTransparency = 1 })
            tween(stage, 0.3, { GroupTransparency = 1 })
            tween(stageScale, 0.3, { Scale = baseScale * 0.8 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            task.wait(0.3)
            backdrop:Destroy()
            stage:Destroy()
            if gui.Parent and done then done() end
        end)
    end

    -- ═════════════ Window:CreateAssistant (talking mascot) ═════════════
    function Window:CreateAssistant(a)
        a = a or {}
        local assistant = Window.Assistant
        local APX = 3
        local ART_W, ART_H = 20 * APX, #SKIBIDI * APX
        local MIN_SCALE, MAX_SCALE = 0.6, 2
        local TIP_INTERVAL = a.TipInterval or 180
        local HISTORY_MAX = 30
        local MOUTH_SHUT = {
            "....SSSSSSSSSSSS....",
            "....SMMMMMMMMMMS....",
            "....SSSSSSSSSSSS....",
            "....SSSSSSSSSSSS....",
        }

        local MOODS = a.Moods or DEFAULT_MOODS
        local LINES, EVENT_MOOD, LOUD = {}, {}, {}
        for k, v in pairs(DEFAULT_LINES) do LINES[k] = v end
        for k, v in pairs(a.Lines or {}) do LINES[k] = v end
        for k, v in pairs(DEFAULT_EVENT_MOOD) do EVENT_MOOD[k] = v end
        for k, v in pairs(a.EventMood or {}) do EVENT_MOOD[k] = v end
        for k, v in pairs(DEFAULT_LOUD) do LOUD[k] = v end
        for k, v in pairs(a.Loud or {}) do LOUD[k] = v end
        local TIPS = a.Tips or DEFAULT_TIPS
        local FAQ = a.FAQ or {}
        local FAQ_DEFAULT = a.FAQDefault or DEFAULT_FAQ_REPLY

        register("AssistantEnabled", a.Enabled ~= false)
        register("AssistantPersonality", a.Personality or "chill")
        if flags.AssistantMute == nil then flags.AssistantMute = a.Muted == true end
        if flags.AssistantSounds == nil then flags.AssistantSounds = a.Sounds ~= false end
        if flags.AssistantTips == nil then flags.AssistantTips = a.ShowTips ~= false end
        local savedScale = type(saved.AssistantScale) == "number" and saved.AssistantScale or a.Scale or 1
        local savedX = type(saved.AssistantX) == "number" and saved.AssistantX or nil
        local savedY = type(saved.AssistantY) == "number" and saved.AssistantY or nil
        persisted.AssistantX, persisted.AssistantY, persisted.AssistantScale = true, true, true
        flags.AssistantX, flags.AssistantY, flags.AssistantScale = savedX, savedY, savedScale

        local function personality()
            local p = flags.AssistantPersonality
            return (LINES.hello and LINES.hello[p]) and p or "chill"
        end

        local root = box({ Name = "Assistant", Size = UDim2.fromOffset(ART_W, ART_H), ZIndex = 40,
            Visible = flags.AssistantEnabled, Parent = gui })
        local rootScale = new("UIScale", { Scale = math.clamp(flags.AssistantScale or 1, MIN_SCALE, MAX_SCALE), Parent = root })
        local body = box({ Size = UDim2.fromOffset(ART_W, ART_H), ZIndex = 40, Parent = root })
        pixelArt(body, SKIBIDI, APX, SKIBIDI_PALETTE, Vector2.zero, 41)
        local moodFrames = {}
        for name, segments in pairs(MOODS) do
            local frame = box({ Size = UDim2.fromOffset(ART_W, ART_H), Visible = false, ZIndex = 42, Parent = body })
            for _, segment in ipairs(segments) do
                pixelArt(frame, segment[2], APX, SKIBIDI_PALETTE, Vector2.new(0, segment[1] * APX), 42)
            end
            moodFrames[name] = frame
        end
        local lidsA = box({ Position = UDim2.fromOffset(0, 6 * APX), Size = UDim2.fromOffset(ART_W, 3 * APX), Visible = false, ZIndex = 43, Parent = body })
        pixelArt(lidsA, SKIBIDI_LIDS, APX, SKIBIDI_PALETTE, Vector2.zero, 43)
        local mouthA = box({ Position = UDim2.fromOffset(0, 10 * APX), Size = UDim2.fromOffset(ART_W, 4 * APX), Visible = false, ZIndex = 43, Parent = body })
        pixelArt(mouthA, MOUTH_SHUT, APX, SKIBIDI_PALETTE, Vector2.zero, 43)

        local function setMood(name)
            for moodName, frame in pairs(moodFrames) do frame.Visible = moodName == name end
        end

        local editFrame = box({ Position = UDim2.fromOffset(-4, -4), Size = UDim2.new(1, 8, 1, 8), Visible = false, ZIndex = 44, Parent = root },
            { corner(4), stroke(C.Edge) })
        local hit = button({ Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 45, Parent = root })
        local grip = button({ Position = UDim2.new(1, 0, 1, 0), Size = UDim2.fromOffset(10, 10), BackgroundColor3 = C.Text,
            Visible = false, ZIndex = 46, Parent = root }, { corner(2) })

        local bubble = box({ Name = "Bubble", Size = UDim2.fromOffset(220, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = C.Panel, Visible = false, ZIndex = 47, Parent = root }, { corner(8), stroke(C.Edge), pad(9, 12, 9, 12) })
        new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = bubble })
        local bubbleScale = new("UIScale", { Parent = bubble })
        local historyFrame = new("ScrollingFrame", {
            LayoutOrder = 0, Size = UDim2.new(1, 0, 0, 110), BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness = 2, ScrollBarImageColor3 = C.Faint, CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y,
            Visible = false, ZIndex = 48, Parent = bubble,
        })
        new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), Parent = historyFrame })
        local bubbleText = text({ Text = "", FontFace = F.Medium, TextSize = 13, TextWrapped = true, LayoutOrder = 1,
            TextYAlignment = Enum.TextYAlignment.Top, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0),
            ZIndex = 48, Parent = bubble })
        local askBox = new("TextBox", {
            LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = C.Raise, BorderSizePixel = 0,
            ClearTextOnFocus = false, Text = "", PlaceholderText = "Type and press Enter...", PlaceholderColor3 = C.Faint,
            TextColor3 = C.Text, FontFace = F.Book, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
            Visible = false, ZIndex = 48, Parent = bubble,
        }, { corner(4), pad(0, 8, 0, 8) })

        local function viewport()
            local camera = workspace.CurrentCamera
            return camera and camera.ViewportSize or Vector2.new(1000, 600)
        end
        if flags.AssistantX and flags.AssistantY then
            root.Position = UDim2.fromOffset(flags.AssistantX, flags.AssistantY)
        else
            root.Position = UDim2.fromOffset(24, math.floor(viewport().Y - ART_H * rootScale.Scale - 24))
        end
        local function keepOnScreen()
            local vp = viewport()
            local w, h = ART_W * rootScale.Scale, ART_H * rootScale.Scale
            local x = math.clamp(root.Position.X.Offset, 0, math.max(0, vp.X - w))
            local y = math.clamp(root.Position.Y.Offset, 0, math.max(0, vp.Y - h))
            root.Position = UDim2.fromOffset(math.floor(x), math.floor(y))
        end
        keepOnScreen()
        if workspace.CurrentCamera then
            on(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), keepOnScreen)
        end

        local function placeBubble()
            local onRight = root.AbsolutePosition.X + root.AbsoluteSize.X / 2 < viewport().X / 2
            bubble.AnchorPoint = onRight and Vector2.new(0, 0) or Vector2.new(1, 0)
            bubble.Position = onRight and UDim2.new(1, 10, 0, 0) or UDim2.new(0, -10, 0, 0)
        end
        local function showBubble()
            placeBubble()
            bubble.Visible = true
            bubbleScale.Scale = 0.9
            tween(bubbleScale, 0.25, { Scale = 1 }, Enum.EasingStyle.Back)
        end

        local PING, BLIP = "rbxasset://sounds/electronicpingshort.wav", "rbxasset://sounds/clickfast.wav"
        local function playTone(soundId, speed, volume)
            if not flags.AssistantSounds then return end
            local sound = new("Sound", { SoundId = soundId, PlaybackSpeed = speed, Volume = volume, Parent = SoundService })
            sound:Play()
            task.delay(1.5, function() sound:Destroy() end)
        end
        local function jingle(mood)
            if mood == "excited" then
                task.spawn(function()
                    for _, speed in ipairs({ 1, 1.26, 1.5 }) do playTone(PING, speed, 0.3) task.wait(0.09) end
                end)
            elseif mood == "sad" then
                task.spawn(function()
                    for _, speed in ipairs({ 0.9, 0.72 }) do playTone(PING, speed, 0.25) task.wait(0.16) end
                end)
            end
        end

        local history = {}
        local function remember(who, message)
            history[#history + 1] = { who = who, text = message, time = os.date("%H:%M") }
            if #history > HISTORY_MAX then table.remove(history, 1) end
        end
        local function renderHistory()
            for _, child in ipairs(historyFrame:GetChildren()) do
                if child:IsA("TextLabel") then child:Destroy() end
            end
            for i, item in ipairs(history) do
                text({ Text = item.time .. "  " .. (item.who == "you" and "You: " or "") .. item.text,
                    FontFace = F.Book, TextSize = 12, TextWrapped = true, LayoutOrder = i,
                    TextColor3 = item.who == "you" and C.Text or C.Sub, TextYAlignment = Enum.TextYAlignment.Top,
                    AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, -6, 0, 0), ZIndex = 48, Parent = historyFrame })
            end
            historyFrame.Visible = #history > 0
            task.defer(function()
                historyFrame.CanvasPosition = Vector2.new(0, math.max(0, historyFrame.AbsoluteCanvasSize.Y - historyFrame.AbsoluteWindowSize.Y))
            end)
        end

        local queue, talking, asking = {}, false, false
        local mouthUntil = 0
        local function speak(item)
            talking = true
            askBox.Visible = false
            historyFrame.Visible = false
            setMood(item.mood)
            jingle(item.mood)
            remember("bot", item.text)
            bubbleText.Text = item.text
            bubbleText.MaxVisibleGraphemes = 0
            showBubble()
            local length = utf8.len(item.text) or #item.text
            for i = 1, length do
                if not root.Parent or not flags.AssistantEnabled then return end
                bubbleText.MaxVisibleGraphemes = i
                mouthUntil = os.clock() + 0.12
                if i % 3 == 1 then playTone(BLIP, 1.3 + math.random() * 0.4, 0.12) end
                task.wait(0.022)
            end
            bubbleText.MaxVisibleGraphemes = -1
            task.wait(math.clamp(1.8 + length * 0.035, 2, 7))
        end
        local function pump()
            if talking or #queue == 0 then return end
            task.spawn(function()
                while #queue > 0 and root.Parent and flags.AssistantEnabled and not asking do
                    speak(table.remove(queue, 1))
                end
                talking = false
                setMood(nil)
                if not asking then bubble.Visible = false end
            end)
        end
        local function say(message, mood, force)
            if not flags.AssistantEnabled or not message or message == "" then return end
            if flags.AssistantMute and not force then return end
            if #queue >= 3 then table.remove(queue, 1) end
            queue[#queue + 1] = { text = message, mood = mood }
            pump()
        end
        assistant.Say = function(message, mood) say(message, mood) end
        assistant.Event = function(key, arg)
            local set = LINES[key]
            if not set then return end
            local line = set[personality()]
            if not line then return end
            if arg ~= nil then line = line:format(tostring(arg)) end
            say(line, EVENT_MOOD[key], LOUD[key])
        end
        assistant.Personality = personality
        assistant.SetMuted = function(v) flags.AssistantMute = v end
        assistant.SetSounds = function(v) flags.AssistantSounds = v end
        assistant.SetTips = function(v) flags.AssistantTips = v end

        local function faqAnswer(question)
            local low = question:lower()
            for _, item in ipairs(FAQ) do
                for _, key in ipairs(item[1]) do
                    if low:find(key, 1, true) then return item[2] end
                end
            end
            return FAQ_DEFAULT
        end
        local function aiAnswer(question)
            if not a.Ask then return nil end
            local ok, reply = pcall(a.Ask, question, personality())
            if not ok or type(reply) ~= "string" then return nil end
            reply = clean(reply:gsub("[%*#`]", ""):gsub("%s+", " "))
            if reply == "" then return nil end
            if #reply > 280 then reply = reply:sub(1, 277) .. "..." end
            return reply
        end
        local function answer(question)
            remember("you", question)
            if not a.Ask or (a.CanAsk and not a.CanAsk()) then
                say(faqAnswer(question), nil, true)
                return
            end
            say(LINES.thinkHelp[personality()], "thinking", true)
            task.spawn(function()
                say(aiAnswer(question) or faqAnswer(question), nil, true)
            end)
        end

        local function openAsk()
            if asking or not flags.AssistantEnabled then return end
            asking = true
            setMood(nil)
            bubbleText.Text = a.AskPrompt or "Ask me how to use the menu!"
            bubbleText.MaxVisibleGraphemes = -1
            renderHistory()
            askBox.Text = ""
            askBox.Visible = true
            showBubble()
            askBox:CaptureFocus()
        end
        on(askBox.FocusLost, function(enter)
            local question = clean(askBox.Text)
            askBox.Visible = false
            historyFrame.Visible = false
            asking = false
            if enter and question ~= "" then
                answer(question)
            elseif not talking then
                bubble.Visible = false
            end
            pump()
        end)

        local blinkAt, blinkUntil = 2, 0
        tickers[#tickers + 1] = function(dt, t)
            if not root.Visible then return end
            if t >= blinkAt then
                blinkUntil = t + 0.12
                blinkAt = t + 2 + math.random() * 3
            end
            lidsA.Visible = t < blinkUntil
            mouthA.Visible = talking and os.clock() < mouthUntil and math.floor(t * 9) % 2 == 0
            body.Position = UDim2.fromOffset(0, math.floor(t * 1.5) % 2 == 0 and 0 or -APX)
        end

        task.spawn(function()
            while root.Parent do
                task.wait(TIP_INTERVAL)
                if flags.AssistantEnabled and flags.AssistantTips and not flags.AssistantMute and not talking and not asking and #TIPS > 0 then
                    say(TIPS[math.random(#TIPS)])
                end
            end
        end)

        local menuOpen = false
        local dragInput, dragStart, dragFrom, dragMoved
        local sizeInput, sizeStart, sizeFrom
        on(hit.InputBegan, function(input)
            if not menuOpen or not isPress(input) or sizeInput then return end
            dragInput, dragStart, dragFrom, dragMoved = input, input.Position, root.Position, false
        end)
        on(grip.InputBegan, function(input)
            if not menuOpen or not isPress(input) then return end
            dragInput = nil
            sizeInput, sizeStart, sizeFrom = input, input.Position, rootScale.Scale
        end)
        on(UserInputService.InputChanged, function(input)
            if dragInput and tracks(dragInput, input) then
                local delta = input.Position - dragStart
                if delta.Magnitude > 4 then dragMoved = true end
                if dragMoved then
                    local vp = viewport()
                    local x = math.clamp(dragFrom.X.Offset + delta.X, 0, vp.X - root.AbsoluteSize.X)
                    local y = math.clamp(dragFrom.Y.Offset + delta.Y, 0, vp.Y - root.AbsoluteSize.Y)
                    root.Position = UDim2.fromOffset(math.floor(x), math.floor(y))
                    if bubble.Visible then placeBubble() end
                end
            elseif sizeInput and tracks(sizeInput, input) then
                local delta = input.Position - sizeStart
                rootScale.Scale = math.clamp(sizeFrom + (delta.X + delta.Y) / 140, MIN_SCALE, MAX_SCALE)
            end
        end)
        on(UserInputService.InputEnded, function(input)
            if dragInput and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1) then
                local wasMoved = dragMoved
                dragInput = nil
                if wasMoved then
                    changed("AssistantX", root.Position.X.Offset)
                    changed("AssistantY", root.Position.Y.Offset)
                elseif menuOpen then
                    openAsk()
                end
            end
            if sizeInput and (input == sizeInput or input.UserInputType == Enum.UserInputType.MouseButton1) then
                sizeInput = nil
                changed("AssistantScale", math.floor(rootScale.Scale * 100 + 0.5) / 100)
            end
        end)

        assistant.OnMenu = function(open)
            menuOpen = open
            editFrame.Visible = open
            grip.Visible = open
            hit.Visible = open
            if not open then
                dragInput, sizeInput = nil, nil
                if asking then askBox:ReleaseFocus() end
            end
        end

        local greetToken = 0
        assistant.SetEnabled = function(enabled)
            flags.AssistantEnabled = enabled
            root.Visible = enabled
            greetToken += 1
            local token = greetToken
            if not enabled then
                queue = {}
                bubble.Visible = false
                return
            end
            task.delay(a.GreetDelay or 5, function()
                if token ~= greetToken or not flags.AssistantEnabled then return end
                assistant.Event("hello", player.Name)
                assistant.Event("hint")
            end)
        end

        assistant.SetEnabled(flags.AssistantEnabled)
        assistant.OnMenu(menuVisible)
        return assistant
    end

    -- ───────────── global input + render loop ─────────────
    on(UserInputService.InputBegan, function(input, processed)
        if rebindFn then
            rebindFn(input)
            return
        end
        if processed then return end
        if input.KeyCode == toggleKey then
            setShown(not shown)
            return
        end
        for _, kb in ipairs(keybinds) do
            if input.KeyCode == kb.get() then kb.press() end
        end
    end)

    local blinkAt, blinkUntil, clock = 3, 0, 0
    on(RunService.RenderStepped, function(dt)
        clock += dt
        if clock >= blinkAt then
            blinkUntil = clock + 0.12
            blinkAt = clock + 2.5 + math.random() * 3
            if math.random() < 0.25 then blinkAt = clock + 0.3 end
        end
        lids.Visible = clock < blinkUntil
        for _, tick in ipairs(tickers) do tick(dt, clock) end
    end)

    -- ───────────── teardown ─────────────
    function Window:OnDestroy(fn) cleanups[#cleanups + 1] = fn end
    function Window:Destroy()
        if savePending then writeConfig() end
        for _, fn in ipairs(cleanups) do pcall(fn) end
        cleanups = {}
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        conns = {}
        if gui then gui:Destroy() end
        if env.__SkibidiLibWindows[id] == Window then env.__SkibidiLibWindows[id] = nil end
        if cfg.OnDestroy then pcall(cfg.OnDestroy) end
    end
    function Window:Unload()
        setShown(false)
        task.delay(0.2, function() Window:Destroy() end)
    end

    env.__SkibidiLibWindows[id] = Window
    Library.Windows[id] = Window

    -- ───────────── start ─────────────
    holder.Visible = false
    local function ready()
        setShown(true)
        if cfg.OnReady then task.spawn(cfg.OnReady, Window) end
    end
    if cfg.Intro ~= false and cfg.Logo == nil then
        Window:PlayIntro(cfg.IntroText or cfg.Title or "", ready)
    else
        task.defer(ready)
    end

    return Window
end

return Library
