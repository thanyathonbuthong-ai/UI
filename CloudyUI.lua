--[[
    CloudyUI  -  UI library extracted from the Cloudy / Kicia Rebuild script.

    The widget code (window, tabs, sections, toggles, sliders, dropdowns, keybinds,
    colour pickers, notifications, settings/config/theme pages) is copied from the
    original script unchanged; only the game features, anti-cheat bypass and
    auto-run loader were left out.

    Usage:   local CloudyUI = loadstring(readfile("CloudyUI.lua"))()
             see example.lua
]]
if not game:IsLoaded() then game.Loaded:Wait() end

local K: { [string]: any } = { connections = {}, cleanups = {}, destroyed = false }

local Players = game:GetService("Players")
local _ReplicatedStorage = game:GetService("ReplicatedStorage")
local _RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local _CollectionService = game:GetService("CollectionService")
local _HttpService = game:GetService("HttpService")
local _SoundService = game:GetService("SoundService")
local _Lighting = game:GetService("Lighting")
local _player = Players.LocalPlayer
while not _player do
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    _player = Players.LocalPlayer
end

local rawget, rawset = rawget, rawset

function K.fn(name)
    local v
    pcall(function() v = getgenv()[name] end)
    if type(v) ~= "function" then pcall(function() v = getgenv()[name] end) end
    return type(v) == "function" and v or nil
end

local getthreadidentity_ = K.fn("getthreadidentity") or K.fn("getidentity")
local setthreadidentity_ = K.fn("setthreadidentity") or K.fn("setidentity")
local _sethiddenproperty = K.fn("sethiddenproperty")
local gethui_ = K.fn("gethui")
local function identity(n)
    if not setthreadidentity_ then return function() end end
    local old = getthreadidentity_ and getthreadidentity_() or nil
    pcall(setthreadidentity_, n)
    return function() if old then pcall(setthreadidentity_, old) end end
end
K.identity = identity
local function hudParent()
    local ok, h = pcall(function() return gethui_ and gethui_() end)
    if ok and h then return h end
    return game:GetService("CoreGui")
end
K.hudParent = hudParent

function K.track(c) K.connections[#K.connections + 1] = c; return c end
function K.onUnload(f) K.cleanups[#K.cleanups + 1] = f end

--==========================================================================
--  Signal / Trove (Kicia's own small versions)
--==========================================================================
local Signal = {}
Signal.__index = Signal
function Signal.new() return setmetatable({ _handlers = {} }, Signal) end
function Signal:Connect(fn)
    local h = { fn = fn, connected = true }
    table.insert(self._handlers, h)
    local sig = self
    return {
        Connected = true,
        Disconnect = function(c)
            if not h.connected then return end
            h.connected = false
            c.Connected = false
            local i = table.find(sig._handlers, h)
            if i then table.remove(sig._handlers, i) end
        end,
    }
end
function Signal:Once(fn)
    local c
    c = self:Connect(function(...) c:Disconnect(); fn(...) end)
    return c
end
function Signal:Fire(...)
    local list = table.clone(self._handlers)
    for _, h in ipairs(list) do
        if h.connected then task.spawn(h.fn, ...) end
    end
end
function Signal:FireSync(...)
    for _, h in ipairs(table.clone(self._handlers)) do
        if h.connected then h.fn(...) end
    end
end
function Signal:Destroy() table.clear(self._handlers) end
K.Signal = Signal

local Trove = {}
Trove.__index = Trove
function Trove.new(name) return setmetatable({ _name = name, _items = {} }, Trove) end
local function cleanItem(o)
    local t = typeof(o)
    if t == "RBXScriptConnection" then o:Disconnect()
    elseif t == "Instance" then pcall(function() o:Destroy() end)
    elseif t == "thread" then pcall(task.cancel, o)
    elseif type(o) == "function" then pcall(o)
    elseif type(o) == "table" then
        --  some objects (Kicia's signal connections) error on unknown fields
        local function member(k)
            local ok, v = pcall(function() return o[k] end)
            return ok and type(v) == "function" and v or nil
        end
        local cancel, getStatus = member("cancel"), member("getStatus")
        if cancel and getStatus then pcall(cancel, o); return end
        local destroy = member("Destroy")
        if destroy then pcall(destroy, o); return end
        local disconnect = member("Disconnect")
        if disconnect then pcall(disconnect, o) end
    end
end
function Trove:Add(o) table.insert(self._items, o); return o end
function Trove:Connect(sig, fn) return self:Add(sig:Connect(fn)) end
function Trove:Extend() return self:Add(Trove.new(self._name)) end
function Trove:Remove(o, keep)
    local i = table.find(self._items, o)
    if i then
        table.remove(self._items, i)
        if not keep then cleanItem(o) end
    end
end
--  Promise held until it settles; cancelled if the trove is cleaned first.
function Trove:AddPromise(promise)
    if tostring(promise:getStatus()) == "Started" then
        self:Add(promise)
        promise:finally(function()
            if not self._cleaning then self:Remove(promise, true) end
        end)
    end
    return promise
end
--  Sub-trove that cleans itself up when `instance` is destroyed.
function Trove:AttachExtend(instance)
    local sub = self:Extend()
    sub:Connect(instance.Destroying, function() self:Remove(sub) end)
    return sub
end
function Trove:Clean()
    local items = self._items
    self._items = {}
    self._cleaning = true
    for i = #items, 1, -1 do cleanItem(items[i]) end
    self._cleaning = false
end
Trove.Destroy = Trove.Clean
K.Trove = Trove

--==========================================================================
--  Kicia's constant pool (v86[...]) as recovered from usage in the dump
--==========================================================================
local C = {
    [3] = "Toggle", [9] = 20, [12] = 12, [18] = "0", [26] = 4, [34] = true, [44] = "Enabled",
    [45] = 90, [48] = 2, [53] = 20, [55] = "Mode", [56] = 2, [62] = 0.1, [63] = 1, [68] = "table",
    [75] = "None", [83] = 64, [91] = 100, [95] = "number", [101] = 0.5, [108] = 255, [116] = "boolean",
    [118] = 16, [122] = 8, [126] = 0.15, [127] = "CFrame", [128] = "Frame", [133] = 10, [137] = 256,
    [147] = 0.1, [149] = 1, [153] = false, [155] = 3, [160] = 50, [162] = 8, [165] = "string",
    [170] = 9, [173] = 0.88, [175] = 5, [186] = 0, [192] = 30, [195] = 0.7,
}
K.C = C
local v86 = {
    [2] = "ReactiveStore",
    [3] = "Toggle",
    [4] = "UIListLayout",
    [5] = "BackgroundColor3",
    [6] = 0,
    [7] = 60,
    [8] = 60,
    [9] = 20,
    [12] = 12,
    [13] = 14,
    [14] = "Settings",
    [15] = 120,
    [16] = "min",
    [17] = 200,
    [18] = "0",
    [19] = 200,
    [20] = "Vector3",
    [21] = "Always",
    [22] = "",
    [23] = 1.4707963267948965,
    [24] = "Roboto",
    [25] = 24,
    [26] = 4,
    [27] = "Color",
    [28] = 0.2,
    [29] = "Size",
    [30] = 0.35,
    [31] = 29,
    [32] = 24,
    [33] = "Button",
    [34] = true,
    [35] = "ConfigManager",
    [36] = "ApplyMigrations",
    [37] = "TextBounds",
    [38] = "DeleteFile",
    [39] = "Slider",
    [40] = "...",
    [42] = "left",
    [43] = "Proggy Clean",
    [44] = "Enabled",
    [45] = 90,
    [46] = "UIGradient",
    [47] = "CanvasGroup",
    [48] = 0.3,
    [49] = 2,
    [50] = "Side",
    [51] = " ",
    [52] = "BottomRight",
    [53] = 92,
    [54] = 6,
    [55] = "Mode",
    [56] = 2,
    [57] = "TextColor",
    [58] = 80,
    [59] = "Font",
    [60] = 29,
    [61] = 20,
    [62] = 0.1,
    [63] = 1,
    [64] = "ScrollingFrame",
    [65] = 200,
    [66] = 0.5,
    [67] = 100,
    [68] = "table",
    [69] = "Catalog unavailable",
    [70] = "GradientDark",
    [71] = 10,
    [72] = 12,
    [73] = "Keybind",
    [74] = 0.9,
    [75] = "None",
    [76] = "LoadFromFile",
    [77] = "FireServer",
    [78] = 720,
    [79] = 255,
    [80] = "Text",
    [81] = 1,
    [82] = "Realize() can only be called on the root",
    [83] = 64,
    [84] = 0.5,
    [85] = "UIStroke",
    [87] = 0.8,
    [88] = "TabHighlight",
    [89] = "Loading",
    [90] = "Gradient",
    [91] = 100,
    [92] = "TextButton",
    [93] = "ColorSequence",
    [94] = "Options",
    [95] = "number",
    [96] = "Unselected",
    [97] = "Mode",
    [98] = "UICorner",
    [99] = "ExportToJson",
    [100] = 14,
    [101] = 0.5,
    [102] = 231,
    [103] = 52,
    [104] = "Fonts",
    [105] = 0.85,
    [106] = "Menu Keybind",
    [107] = 40,
    [108] = 255,
    [109] = 77,
    [110] = 70,
    [111] = "Fetching items...",
    [112] = "Invisible",
    [113] = "UIPadding",
    [114] = "primary",
    [115] = "Color3",
    [116] = "boolean",
    [118] = 16,
    [119] = 159,
    [120] = "Outline",
    [121] = "ImageButton",
    [122] = 8,
    [123] = 19,
    [124] = "X",
    [125] = "Proggy Tiny",
    [126] = 0.15,
    [127] = "CFrame",
    [128] = "Frame",
    [129] = "Show Watermark",
    [131] = "AbsoluteSize",
    [132] = "Breathing",
    [133] = 10,
    [134] = "GradientTop",
    [135] = "TextLabel",
    [136] = "Unselected Text",
    [137] = 256,
    [138] = 0.85,
    [139] = "Accent",
    [140] = "danger",
    [141] = "GradientDeep",
    [142] = "Silent Load",
    [143] = 32,
    [144] = 20,
    [145] = "Dialog has been destroyed",
    [146] = "ImageLabel",
    [147] = 0.1,
    [148] = "TextBox",
    [149] = 1,
    [150] = "stop",
    [151] = "family",
    [153] = false,
    [154] = "ScrollBarImageColor3",
    [155] = 3,
    [156] = "ImageColor3",
    [157] = 20,
    [158] = "secondary",
    [159] = 20,
    [160] = 50,
    [161] = 0.5,
    [162] = 8,
    [163] = 80,
    [164] = "hue",
    [165] = "string",
    [166] = "family",
    [167] = "TextColor3",
    [168] = "ElementBackground",
    [169] = "FromJson",
    [170] = 9,
    [172] = "none",
    [173] = 0.88,
    [174] = "Unselected",
    [175] = 5,
    [176] = "UISizeConstraint",
    [177] = "Try a different search.",
    [178] = "ElementBackground",
    [181] = 10,
    [182] = "HttpService",
    [183] = 72,
    [184] = "Color",
    [186] = 0,
    [187] = "GradientMid",
    [189] = "Position",
    [190] = "Search...",
    [191] = "TabShadow",
    [192] = 30,
    [193] = 0,
    [194] = "Hold",
    [195] = 0.7,
    [196] = "Viewport",
    [197] = "Y",
    [198] = 400,
    [199] = "Unload",
    [200] = 26,
}

local tbl17: { [string]: any } = { cache = {} }
local v102, v103, v107 = rawget, rawset, pcall
--  integrity counters used by the original code (values sit in the window where every check takes the real branch)
local n25, n26 = 3870, 4800
local flag2, flag3 = true, true
local function n29(...) return 0 end
local cloneref = K.fn("cloneref") or function(x) return x end
local gethui = K.fn("gethui") or function() return game:GetService("CoreGui") end
local getthreadidentity = K.fn("getthreadidentity") or K.fn("getidentity") or function() return 8 end
local setthreadidentity = K.fn("setthreadidentity") or K.fn("setidentity") or function() end
local setclipboard = K.fn("setclipboard") or K.fn("toclipboard") or function() end
tbl17.bN = function() return {} end   -- profile store (pins) is not part of the library
tbl17.bG = function() return tbl17.cache.bG.c end   -- the settings store, set in CloudyUI.new

--  k: Trove
tbl17.k = function() return { new = function(name) return Trove.new(name) end } end

--  w: viewport / pointer / key / path helpers
do
    local UIS = UserInputService
    local _GuiService = game:GetService("GuiService")
    local function camera() return workspace.CurrentCamera end
    local W = {}
    function W.appendPath(path, key)
        local p = table.clone(path)
        table.insert(p, key)
        return p
    end
    function W.currentViewportSize()
        local c = camera()
        return c and c.ViewportSize or Vector2.new(1920, 1080)
    end
    function W.connectCurrentCameraViewport(trove, cb)
        local inner = trove:Extend()
        local function bind()
            inner:Clean()
            local c = camera()
            if c == nil then return end
            inner:Connect(c:GetPropertyChangedSignal("ViewportSize"), function() cb(c.ViewportSize) end)
            cb(c.ViewportSize)
        end
        trove:Connect(workspace:GetPropertyChangedSignal("CurrentCamera"), bind)
        bind()
    end
    function W.absoluteToLayerOffset(layer, pos)
        return pos - layer.AbsolutePosition
    end
    function W.clampOffsetToViewport(x, y, size)
        local vp = W.currentViewportSize()
        return math.clamp(x, 0, math.max(0, vp.X - size.X)), math.clamp(y, 0, math.max(0, vp.Y - size.Y))
    end
    function W.clampGuiToViewport(gui)
        local vp = W.currentViewportSize()
        local ap, as = gui.AbsolutePosition, gui.AbsoluteSize
        local dx = math.clamp(ap.X, 0, math.max(0, vp.X - as.X)) - ap.X
        local dy = math.clamp(ap.Y, 0, math.max(0, vp.Y - as.Y)) - ap.Y
        if dx ~= 0 or dy ~= 0 then
            local p = gui.Position
            gui.Position = UDim2.new(p.X.Scale, p.X.Offset + dx, p.Y.Scale, p.Y.Offset + dy)
        end
    end
    function W.snapPosition(u)
        return UDim2.new(u.X.Scale, math.round(u.X.Offset), u.Y.Scale, math.round(u.Y.Offset))
    end
    function W.onScreenKeyboardTop()
        local ok, visible = pcall(function() return UIS.OnScreenKeyboardVisible end)
        if not ok or not visible then return nil end
        local ok2, pos = pcall(function() return UIS.OnScreenKeyboardPosition end)
        return ok2 and pos and pos.Y or nil
    end
    function W.connectOnScreenKeyboard(trove, cb)
        pcall(function() trove:Connect(UIS:GetPropertyChangedSignal("OnScreenKeyboardVisible"), cb) end)
        pcall(function() trove:Connect(UIS:GetPropertyChangedSignal("OnScreenKeyboardPosition"), cb) end)
    end
    function W.getPointerPosition()
        return UIS:GetMouseLocation()
    end
    function W.matchesPointerDrag(input, started, movement)
        if started ~= nil and started.UserInputType == Enum.UserInputType.Touch then return input == started end
        return input.UserInputType == movement
    end
    function W.round(v, step)
        if step == nil or step == 0 then return v end
        return math.round(v / step) * step
    end
    W.KeyNames = {
        [Enum.UserInputType.MouseButton1] = "MB1", [Enum.UserInputType.MouseButton2] = "MB2",
        [Enum.UserInputType.MouseButton3] = "MB3", [Enum.KeyCode.LeftShift] = "LShift",
        [Enum.KeyCode.RightShift] = "RShift", [Enum.KeyCode.LeftControl] = "LCtrl",
        [Enum.KeyCode.RightControl] = "RCtrl", [Enum.KeyCode.LeftAlt] = "LAlt", [Enum.KeyCode.RightAlt] = "RAlt",
    }
    function W.serializeKey(key)
        if typeof(key) ~= "EnumItem" then return nil end
        return tostring(key.EnumType) .. "." .. key.Name
    end
    function W.deserializeKey(s)
        if type(s) ~= "string" then return nil end
        local kind, name = s:match("^(%w+)%.(%w+)$")
        if kind == nil then return nil end
        local ok, v = pcall(function() return Enum[kind][name] end)
        return ok and v or nil
    end
    function W.findScrollingAncestor(inst)
        local p = inst and inst.Parent
        while p ~= nil do
            if p:IsA("ScrollingFrame") then return p end
            p = p.Parent
        end
        return nil
    end
    function W.isEffectivelyVisible(gui)
        local p = gui
        while p ~= nil and p ~= game do
            if p:IsA("GuiObject") and not p.Visible then return false end
            if p:IsA("LayerCollector") then return p.Enabled end
            p = p.Parent
        end
        return false
    end
    function W.ensureStorageDirectories(dir)
        local isf, mkf = K.fn("isfolder"), K.fn("makefolder")
        if not (isf and mkf) or type(dir) ~= "string" then return end
        local function make(path)
            local acc
            for part in path:gmatch("[^/]+") do
                acc = acc and (acc .. "/" .. part) or part
                pcall(function() if not isf(acc) then mkf(acc) end end)
            end
        end
        make(dir)
        make(dir .. "/configs")
    end
    tbl17.w = function() return W end
end

--  P: two-way link between a control and a settings path. Sliders ask for
--  Debounce so dragging writes once per short burst instead of every frame.
do
    local P = {}
    function P.bind(trove, config, control, path, opts)
        local debounce = opts ~= nil and opts.Debounce == true
        local writeBack = opts ~= nil and opts.WriteBack or nil
        control:Set(config:Get(path), true)
        trove:Connect(config:Changed(path), function(v) control:Set(v, true) end)
        local pending, scheduled = nil, false
        local function write(v)
            if writeBack then writeBack(v) else config:Set(path, v) end
        end
        trove:Connect(control.Changed, function(v)
            if not debounce then write(v); return end
            pending = v
            if scheduled then return end
            scheduled = true
            task.delay(0.05, function()
                scheduled = false
                write(pending)
            end)
        end)
    end
    tbl17.P = function() return P end
end

do -- a
local function fn35()
return {
ok = function(arg)
return { Ok = true, Value = arg }
end,
err = function(arg, arg2, arg3)
return { Ok = false, Error = { Source = arg, Stage = arg2, Detail = arg3, Timestamp = os.clock() } }
end,
formatError = function(arg)
local v115 = tostring
local detail = arg.Detail
return string.format("'%s' @ %s failed during stage '%s'; %s", tostring(arg.Source), tostring(arg.Timestamp), tostring(arg.Stage), v115(detail))
end,
VoidOk = table.freeze({ Ok = true, Value = nil }),
}
end

tbl17.a = function()
local a = tbl17.cache.a

if not a then
a = { c = fn35() }
tbl17.cache.a = a
end

return a.c
end
end
do -- b
local function fn35()
tbl17.a()
local v115 = nil

return {
use = function(arg)
v115 = arg
end,
get = function()
assert(v115)
return v115
end,
}
end

tbl17.b = function()
local b = tbl17.cache.b

if not b then
b = { c = fn35() }
tbl17.cache.b = b
end

return b.c
end
end
do -- d
local function fn35()
local function copy(t)
if type(t) ~= "table" then return t end
local o = {}
for k, v in next, t do o[k] = copy(v) end
return setmetatable(o, getmetatable(t))
end
return copy
end

tbl17.d = function()
local d = tbl17.cache.d

if not d then
d = { c = fn35() }
tbl17.cache.d = d
end

return d.c
end
end
do -- e
local function fn35()
local v115 = tbl17.a()

return function(arg, arg2)
local parts = arg:split("/")
arg2 = arg2 or ""

for k, v116 in parts, nil, nil do
if v116 == "" then
continue
end
local str7 = k == #parts and "" or "/"
local v117 = tostring
arg2 ..= string.format("%s%s", tostring(v116), v117(str7))
if isfile(arg2) then
return v115.err("ensureFolderPath", "collision", string.format("expected `%s` to be non-existant or a folder, found a file instead.", tostring(arg2)))
end

if not isfolder(arg2) then
makefolder(arg2)
end
end

return v115.VoidOk
end
end

tbl17.e = function()
local e = tbl17.cache.e

if not e then
e = { c = fn35() }
tbl17.cache.e = e
end

return e.c
end
end
do -- f
local function fn35()
local v115 = tbl17.a()
local v116 = tbl17.d()
local v117 = tbl17.e()
local v118 = cloneref(game:GetService(v86[182]))
local index2 = {}
index2.__index = index2

local function fn36(arg)
local v119 = v86[68]
if type(arg) == v119 then
return v116(arg)
end
return arg
end

local function fn37(arg)
if arg == nil or arg == "" then
return ""
end

if arg:sub(-v86[63]) == "/" then
return arg
end
return arg .. "/"
end

local function fn38(arg)
if type(arg)~="string" or arg:match("^%s*$") then
return v115.err("ConfigManager", "validateConfigName", "config name cannot be empty")
end

if arg:find("/") or arg:find("\\") then
return v115.err("ConfigManager", "validateConfigName", "expected no directory traversal")
end
return v115.VoidOk
end

index2.new = function(arg)
assert(type(arg.CurrentVersion) == "number" and arg.CurrentVersion >= v86[63], "expected `CurrentVersion` >= 1")
local v119 = fn37(arg.SavePath)

if v119 ~= "" then
local v120 = v117(v119)

if not v120.Ok then
error(v120.Error.Detail, 2)
end
end

local serialize = arg.Serialize or function(arg2)
return arg2
end

local deserialize = arg.Deserialize or function(arg2)
return arg2
end

local v120 = fn36(arg.DefaultConfig)

local tbl18 = {
Data = fn36(v120),
_defaultConfig = v120,
_currentVersion = arg.CurrentVersion,
_legacyVersion = arg.LegacyVersion or 1,
_savePath = v119,
_migrations = arg.Migrations or {},
_serialize = serialize,
_deserialize = deserialize,
}

setmetatable(tbl18, index2)
return tbl18
end

index2._ConfigPath = function(arg, arg2)
if arg2:match("%.json$") then
return arg._savePath .. arg2
end
local v119 = tostring
return string.format("%s%s.json", tostring(arg._savePath), v119(arg2))
end

index2._ApplyMigrations = function(arg, arg2, arg3)
if arg2 < 1 then
return v115.err("ConfigManager", "ApplyMigrations", string.format("invalid file version %s", tostring(arg2)))
end

if arg._currentVersion < arg2 then
local v119 = tostring
local currentVersion = arg._currentVersion
return v115.err("ConfigManager", "ApplyMigrations", string.format("file version %s is newer than current version %s", tostring(arg2), v119(currentVersion)))
end

local v119 = fn36(arg3)

while arg2 < arg._currentVersion do
local v120 = arg._migrations[arg2]
if v120 == nil then
local v121 = tostring
return v115.err("ConfigManager", v86[36], string.format("missing migration for version %s -> %s", tostring(arg2), v121(arg2 + 1)))
end
local v121, v122 = v107(v120, v119, arg2, arg2 + v86[63])
if not v121 then
local v123 = tostring
return v115.err(v86[35], "ApplyMigrations", string.format("migration %s -> %s failed: %s", tostring(arg2), tostring(arg2 + v86[63]), v123(v122)))
end

if v122 == nil then
local v123 = tostring
return v115.err("ConfigManager", "ApplyMigrations", string.format("migration %s -> %s returned nil", tostring(arg2), v123(arg2 + 1)))
end
arg2 += 1
v119 = v122
end

return v115.ok(v119)
end

index2.SetData = function(arg, data)
arg.Data = data
end

index2.Reset = function(arg)
local v119 = v116(arg._defaultConfig)
arg.Data = v119
return v119
end

index2.ToJson = function(arg, arg2)
if arg2 == nil then
arg2 = arg.Data
end

local v119, v120 = v107(arg._serialize, arg2)
if not v119 then
return v115.err("ConfigManager", "ToJson", string.format("failed to serialize config: %s", tostring(v120)))
end
local v121, v122 = v107(v118.JSONEncode, v118, { Version = arg._currentVersion, Data = v120 })
if not v121 then
return v115.err("ConfigManager", "ToJson", string.format("failed to encode config payload as JSON: %s", tostring(v122)))
end
return v115.ok(v122)
end

index2.FromJson = function(arg, arg2)
local v119, v120 = v107(v118.JSONDecode, v118, arg2)
if not v119 then
return v115.err(v86[35], v86[169], string.format("failed to decode JSON payload: %s", tostring(v120)))
end

if type(v120) ~= "table" then
return v115.err("ConfigManager", "FromJson", "expected decoded config JSON to be a table")
end
local legacyVersion = arg._legacyVersion
local version = v120.Version
local data = v120.Data

if version == nil and data == nil then
version = v120.version
data = v120.data
end

if not (type(version) == "number" and data ~= nil) then
data = v120
version = legacyVersion
end

local v121 = arg:_ApplyMigrations(version, data)
if not v121.Ok then
return v115.err("ConfigManager", v86[169], v121.Error.Detail)
end
local v122, v123 = v107(arg._deserialize, v121.Value)
if not v122 then
return v115.err("ConfigManager", "FromJson", string.format("failed to deserialize config data: %s", tostring(v123)))
end

if v123 == nil then
return v115.err("ConfigManager", "FromJson", "deserializer returned nil")
end
arg.Data = v123
return v115.ok(v123)
end

local function readConfig(path)
local ok,text
for _=1,3 do
ok,text=pcall(readfile,path)
if ok and type(text)=="string" then return text end
end
if not ok or type(text)~="string" then return nil,tostring(text) end
return text
end
local function writeVerified(path,text)
local problem
for _=1,3 do
local ok,err=pcall(writefile,path,text)
if ok then
local actual,readError=readConfig(path)
if actual==text then return true end
problem=readError or "file contents did not match after writing"
else problem=tostring(err) end
end
return false,problem
end
local function isConfig(text)
if type(text)~="string" then return false end
local ok,value=pcall(v118.JSONDecode,v118,text)
return ok and type(value)=="table"
end

index2._SaveImpl = function(arg, arg2, arg3, arg4)
local valid=fn38(arg2)
if not valid.Ok then return valid end
local path=arg:_ConfigPath(arg2)
if arg4 and isfile(path) then
return v115.err("ConfigManager","SaveImpl",string.format("path '%s' already exists",path))
end
local encoded=arg:ToJson(arg3)
if not encoded.Ok then return v115.err("ConfigManager","SaveImpl",encoded.Error.Detail) end
if arg._savePath~="" then
local ok,folder=pcall(v117,arg._savePath)
if not ok or not folder or not folder.Ok then
return v115.err("ConfigManager","SaveImpl","could not create config folder: "..tostring(ok and folder and folder.Error and folder.Error.Detail or folder))
end
end
local previous,readError=readConfig(path)
if isfile(path) and previous==nil then return v115.err("ConfigManager","SaveImpl","could not read existing config: "..tostring(readError)) end
if previous==encoded.Value then return v115.VoidOk end
-- Keep the previous readable config before replacing it; backups do not appear in the list.
local previousValid=isConfig(previous)
if previousValid then
local backedUp,backupError=writeVerified(path..".bak",previous)
if not backedUp then return v115.err("ConfigManager","SaveImpl","could not back up config: "..tostring(backupError)) end
end
local saved,saveError=writeVerified(path,encoded.Value)
if not saved then
if previousValid then writeVerified(path,previous) end
return v115.err("ConfigManager","SaveImpl","config write failed verification: "..tostring(saveError))
end
return v115.VoidOk
end

index2.SaveToFile = function(arg, arg2, arg3)
return arg:_SaveImpl(arg2, nil, arg3)
end

index2.LoadFromFile = function(arg, arg2)
local valid=fn38(arg2)
if not valid.Ok then return valid end
local path=arg:_ConfigPath(arg2)
local text,readError=readConfig(path)
local result=text and arg:FromJson(text) or v115.err("ConfigManager","LoadFromFile",tostring(readError or "config not found"))
if result.Ok then return result end
local backup=readConfig(path..".bak")
if backup then
local recovered=arg:FromJson(backup)
if recovered.Ok then return recovered end
end
return result
end

index2.Exists = function(arg, arg2)
if not fn38(arg2).Ok then
return v86[153]
end
return isfile(arg:_ConfigPath(arg2))
end

index2.SaveDefaultToFile = function(arg, arg2, arg3)
return arg:_SaveImpl(arg2, arg._defaultConfig, arg3)
end

index2.Delete = function(arg,arg2)
local valid=fn38(arg2)
if not valid.Ok then return valid end
local path=arg:_ConfigPath(arg2)
if not isfile(path) and not isfile(path..".bak") then return v115.err("ConfigManager","Delete","config does not exist") end
for _,file in {path..".bak",path} do
if isfile(file) then
local ok,problem=pcall(delfile,file)
if not ok then return v115.err("ConfigManager","Delete",tostring(problem)) end
end
end
return v115.VoidOk
end

index2.AllConfigs = function(arg)
local tbl18 = {}
if arg._savePath == "" then
return tbl18
end

for _, v119 in listfiles(arg._savePath) do
if isfile(v119) then
local match = (v119:match("[/\\]([^/\\]+)$") or v119):match("(.+)%.json$")

if match ~= nil then
table.insert(tbl18, match)
end
end
end

return tbl18
end

return index2
end

tbl17.f = function()
local f = tbl17.cache.f

if not f then
f = { c = fn35() }
tbl17.cache.f = f
end

return f.c
end
end
do -- g
local function fn35()local I;local function W(N,...)local P=I;I=nil;N(...);I=P;end;local function N(...)W(...);while true do W(coroutine.yield());end;end;local W_1={};W_1.__index=W_1;W_1.Disconnect=function(P)if not P.Connected then return;end;P.Connected=false;if P._signal._handlerListHead==P then P._signal._handlerListHead=P._next;else local a=P._signal._handlerListHead;while a and a._next~=P do a=a._next;end;if a then a._next=P._next;end;end;end;W_1.Destroy=W_1.Disconnect;setmetatable(W_1,{__index=function(P,P_2)error(("Attempt to get Connection::%s (not a valid member)"):format(tostring(P_2)),2);end,__newindex=function(P,P_3,a)error(("Attempt to set Connection::%s (not a valid member)"):format(tostring(P_3)),2);end});local P={};P.__index=P;P.new=function()return(setmetatable({_handlerListHead=false,_proxyHandler=nil,_yieldedThreads=nil},P));end;P.Wrap=function(a)assert(typeof(a)=="RBXScriptSignal","Argument #1 to Signal.Wrap must be a RBXScriptSignal; got "..typeof(a));local e=P.new();e._proxyHandler=a:Connect(function(...)e:Fire(...);end);return e;end;P.Is=function(a)return type(a)=="table"and getmetatable(a)==P;end;P.Connect=function(a,e)local c=setmetatable({Connected=true,_signal=a,_fn=e,_next=false},W_1);if a._handlerListHead then c._next=a._handlerListHead;a._handlerListHead=c;else a._handlerListHead=c;end;return c;end;P.ConnectOnce=function(W,a)return W:Once(a);end;P.Once=function(W,a)local e;local c=false;e=W:Connect(function(...)if c then return;end;c=true;e:Disconnect();a(...);end);return e;end;P.GetConnections=function(W)local a,e={},W._handlerListHead;while e do table.insert(a,e);e=e._next;end;return a;end;P.DisconnectAll=function(W)local a=W._handlerListHead;while a do a.Connected=false;a=a._next;end;W._handlerListHead=false;a= v102 (W,"_yieldedThreads");if a then for e in a,nil,nil do if coroutine.status(e)=="suspended"then warn((debug.traceback :: any)(e,"signal disconnected; yielded thread cancelled",2));task.cancel(e);end;end;table.clear(W._yieldedThreads);end;end;P.Fire=function(W,...)local a=W._handlerListHead;while a do if a.Connected then W=I;if not W then I=coroutine.create(N);end;task.spawn(I,a._fn,...);end;a=a._next;end;end;P.FireDeferred=function(I,...)local W=I._handlerListHead;while W do local I_4=W;task.defer(function(...)if I_4.Connected then I_4._fn(...);end;end,...);W=W._next;end;end;P.Wait=function(I)local W= v102 (I,"_yieldedThreads");if not W then W={}; v103 (I,"_yieldedThreads",W);end;local N=coroutine.running();W[N]=true;I:Once(function(...)W[N]=nil;if coroutine.status(N)=="suspended"then task.spawn(N,...);end;end);return coroutine.yield();end;P.Destroy=function(I)I:DisconnectAll();local W= v102 (I,"_proxyHandler");if W then W:Disconnect();end;end;return table.freeze({new=P.new,Wrap=P.Wrap,Is=P.Is});end

tbl17.g = function()
local g = tbl17.cache.g

if not g then
local g2 = { c = fn35() }
tbl17.cache.g = g2
g = g2
end

return g.c
end
end
do -- h
local function fn35()
local v115 = tbl17.g()
local index2 = {}
index2.__index = index2
local index3 = {}
index3.__index = index3
index3.Enable = function(l)if l.Connected then return;end;l.Connected=true;l._inner=l._signal._inner:Connect(l._callback);end
index3.Disable = function(l)if not l.Connected then return;end;l.Connected=false;local I=l._inner;if I~=nil then I:Disconnect();end;l._inner=nil;end
index3.Disconnect = index3.Disable
index3.Destroy = index3.Disable
index2.Connect = function(I,W)local N=setmetatable({_signal=I,_callback=W,_inner=nil,Connected=false}, index3 );N:Enable();return N;end
index2.Fire = function(l,I)l._inner:Fire(I);end

index2.FireDeferred = function(arg, arg2)
arg._inner:FireDeferred(arg2)
end

index2.Once = function(arg, arg2)
return arg._inner:Once(arg2)
end

index2.Wait = function(arg)
return arg._inner:Wait()
end

index2.DisconnectAll = function(arg)
arg._inner:DisconnectAll()
end

index2.GetConnections = function(arg)
return arg._inner:GetConnections()
end

index2.Destroy = function(arg)
arg._inner:Destroy()
end

return table.freeze({ new = function()
return (setmetatable({ _inner = v115.new() }, index2))
end })
end

tbl17.h = function()
local h = tbl17.cache.h

if not h then
local h2 = { c = fn35() }
tbl17.cache.h = h2
h = h2
end

return h.c
end
end
do -- i
local function fn35()
local tbl18 = {}

return {
atomic = function(arg)
setmetatable(arg, tbl18)
return arg
end,
isAtomic = function(I)return type(I)=="table"and getmetatable(I)== tbl18 ;end,
}
end

tbl17.i = function()
local i = tbl17.cache.i

if not i then
local i2 = { c = fn35() }
tbl17.cache.i = i2
i = i2
end

return i.c
end
end
do -- j
local function fn35()
if true then
local isAtomic = tbl17.i().isAtomic
local tbl18

tbl18 = {
PathToKey = function(l)return table.concat(l,".");end,
KeyToPath = function(l)return l:split(".");end,
NavigateTo = function(l,I,W)if#I==0 then return nil;end;for N=1,#I,1 do local P=I[N];if N==#I then return l[P];end;l=l[P];if l==nil then if W then return nil;end;error(string.format("Invalid path specified '%s', key %s is nil!",tostring(table.concat(I,".")),tostring(P)),2);elseif type(l)~="table"then if W then return nil;end;error(string.format("Invalid path specified '%s', key %s is not a branch!",tostring(table.concat(I,".")),tostring(P)),2);end;end;return nil;end,
Set = function(I,W,N)for P=1,#W,1 do local a=W[P];if P==#W then I[a]=N;return;end;local Q=I[a];if Q==nil then Q={};I[a]=Q;elseif type(Q)~="table"then local N_5= tbl18 .PathToKey(W);error(string.format("Invalid path specified '%s', key %s is not a table!",tostring(N_5),tostring(a)),2);end;I=Q;end;end,
ForEachEntry = function(I,W)local N={};local function P(a)for e,c in a,nil,nil do table.insert(N,e);W(N,c);if type(c)=="table"and not  isAtomic (c)then P(c);end;table.remove(N);end;end;P(I);end,
ForEachLeafValue = function(I,W,N)local P={};local function a(e,c)for E,p in e,nil,nil do table.insert(P,E);local e_6=if c~=nil then c[E]else nil;local c_7=type(e_6)=="table";E=if type(p)=="table"and not  isAtomic (p)and not(c_7 and( isAtomic (e_6)))and(e_6==nil or c_7)then(a(p,if c_7 then e_6 else nil))else if c_7 and not  isAtomic (e_6)then false else N(P,p)==true;table.remove(P);if E then return true;end;end;return false;end;a(I,W);end,
}

return tbl18
end
return nil

-- (anti-tamper freeze trap removed)
end

tbl17.j = function()
local j = tbl17.cache.j

if not j then
local j2 = { c = fn35() }
tbl17.cache.j = j2
j = j2
end

return j.c
end
end
do -- l
local function fn35()
local v115 = tbl17.f()
local v116 = tbl17.h()
local v117 = tbl17.j()
local v118 = tbl17.a()
local v119 = tbl17.g()
local v120 = tbl17.k()
local v121 = tbl17.d()
local isAtomic = tbl17.i().isAtomic
local index2 = {}
index2.__index = index2

index2.new = function(arg)
local ReactiveStore = v120.new("ReactiveStore")

return setmetatable({
_trove = ReactiveStore,
Default = arg.DefaultConfig,
Data = v121(arg.DefaultConfig),
_middleware = {},
_configManager = v115.new({
DefaultConfig = arg.DefaultConfig,
CurrentVersion = arg.CurrentVersion,
LegacyVersion = arg.LegacyVersion,
SavePath = arg.SavePath,
Migrations = arg.Migrations,
Serialize = arg.Serialize,
Deserialize = arg.Deserialize,
}),
_listenerByPathKey = {},
_listenerTrieRoot = {},
_pendingUpdateByPathKey = {},
_pendingOrder = {},
_isFlushing = false,
_isLoading = false,
_lastPublishedValueByPathKey = {},
_liveValueByPathKey = {},
Reloaded = ReactiveStore:Add(v119.new()),
Changed = ReactiveStore:Add(v119.new()),
}, index2)
end

index2.UseMiddleware = function(arg, middleware)
arg._middleware = middleware
end

local tbl18 = {}

index2.GetPropertyChangedSignal = function(arg, arg2)
local v122 = v117.PathToKey(arg2)
local v123 = arg._listenerByPathKey[v122]

if v123 == nil then
local v124 = arg._trove:Add(v116.new())
arg._listenerByPathKey[v122] = v124
local listenerTrieRoot = arg._listenerTrieRoot

for _, v125 in arg2, nil, nil do
local v126 = listenerTrieRoot[v125]

if v126 ~= nil then
listenerTrieRoot = v126
else
local tbl19 = {}
listenerTrieRoot[v125] = tbl19
listenerTrieRoot = tbl19
end
end

listenerTrieRoot[tbl18] = v124
v123 = v124
end

return v123
end

index2._FireChanged = function(l,I,W,N)local P=l._pendingUpdateByPathKey[I];if not N and P==nil and l._lastPublishedValueByPathKey[I]==W then return;end;if P==nil then table.insert(l._pendingOrder,I);end;l._pendingUpdateByPathKey[I]={Value=W};end
index2._Flush = function(l)if l._isFlushing then return;end;l._isFlushing=true;while#l._pendingOrder>0 do local I,W=l._pendingOrder,l._pendingUpdateByPathKey;l._pendingUpdateByPathKey={};l._pendingOrder={};for N,N_8 in I,nil,nil do local I_9,P=W[N_8],l._listenerByPathKey[N_8];if P then P:Fire(I_9.Value);end;l._lastPublishedValueByPathKey[N_8]=I_9.Value;end;end;l._isFlushing=false;end
index2._FireForChangedPaths = function(arg, paths)
local function publish(p)
local value = v117.NavigateTo(arg.Data, p, true)
arg:_FireChanged(v117.PathToKey(p), value, type(value) == "table")
end
local function below(node, p)
for k, child in next, node do
if k ~= tbl18 and type(child) == "table" then
table.insert(p, k)
if child[tbl18] ~= nil then publish(p) end
below(child, p)
table.remove(p)
end
end
end
for _, path in paths do
local node, prefix = arg._listenerTrieRoot, {}
for i = 1, #path do
node = node[path[i]]
if node == nil then break end
prefix[i] = path[i]
if node[tbl18] ~= nil then publish(prefix) end
if i == #path then below(node, table.clone(prefix)) end
end
end
end
index2._FireListenersOnly = function(arg, path)
arg:_FireForChangedPaths({ path })
arg:_Flush()
end
index2.Get = function(I,W,N)return  v117 .NavigateTo(I.Data,W,N);end
index2.Set = function(I,W,N)local P=I._middleware;local a=P.Set;N=if a~=nil then(a(P,W,N))else N;local e=I.Data;a= v117 .NavigateTo(e,W,true)~=N;if a then  v117 .Set(e,W,N);end;e=P.SetApplied;if e~=nil then e(P,W,N);end;if a then I:_FireForChangedPaths({W});end;e= v117 .PathToKey(W);a=I._liveValueByPathKey[e];if a~=nil then a.Base=N;end;if I._pendingUpdateByPathKey[e]==nil then I:_FireChanged(e,N);end;I:_Flush();if not I._isLoading then I.Changed:Fire(W,N);end;end
index2.SetLiveOverride = function(I,W,N)local P= v117 .PathToKey(W);if I._liveValueByPathKey[P]==nil then I._liveValueByPathKey[P]={Path=W,Base= v117 .NavigateTo(I.Data,W,true)};end; v117 .Set(I.Data,W,N);I:_FireListenersOnly(W,N);end

index2.ClearLiveOverride = function(arg, arg2)
local v122 = v117.PathToKey(arg2)
local v123 = arg._liveValueByPathKey[v122]
if v123 == nil then
return
end
arg._liveValueByPathKey[v122] = nil
v117.Set(arg.Data, arg2, v123.Base)
arg:_FireListenersOnly(arg2, v123.Base)
end

index2.GetBase = function(I,W)local N=I._liveValueByPathKey[ v117 .PathToKey(W)];if N~=nil then return N.Base;end;return  v117 .NavigateTo(I.Data,W,true);end

index2.RebaseLiveOverride = function(arg, arg2, base)
local v122 = arg._liveValueByPathKey[v117.PathToKey(arg2)]
if v122 == nil then
return v86[153]
end
v122.Base = base
return true
end

index2.PublishPath = function(arg, arg2)
arg:_FireListenersOnly(arg2, v117.NavigateTo(arg.Data, arg2, true))
end

index2._PersistableData = function(arg)
local data = arg.Data
local flag19 = true

if next(arg._liveValueByPathKey) ~= nil then
data = v121(data)

for _, v122 in arg._liveValueByPathKey, nil, nil do
v117.Set(data, v122.Path, v122.Base)
end

flag19 = false
end

local middleware = arg._middleware
local persistable = middleware.Persistable
local v122

if persistable ~= nil then
v122 = persistable(middleware, data, flag19)
else
v122 = data
end

return v122
end

index2.SaveToFile = function(arg, arg2, arg3)
arg._configManager:SetData(arg:_PersistableData())
return arg._configManager:SaveToFile(arg2, arg3)
end

index2.CreateDefault = function(arg, arg2)
return arg._configManager:SaveDefaultToFile(arg2, v86[34])
end

local fn36 = nil

fn36 = function(arg, arg2)
if type(arg) ~= "table" or isAtomic(arg) then
local v122 = (arg2 == nil and { arg } or { arg2 })[1]
return (type(v122) == "table" and { (v121(v122)) } or { v122 })[1]
end

if type(arg2) ~= "table" then
return v121(arg)
end
local v122 = table.clone(arg)

for k, v123 in arg, nil, nil do
v122[k] = fn36(v123, arg2[k])
end

for k, v123 in arg2, nil, nil do
if arg[k] == nil then
v122[k] = (type(v123) == "table" and { (v121(v123)) } or { v123 })[v86[63]]
end
end

return v122
end

local fn37 = nil

fn37 = function(arg, arg2, arg3, arg4, arg5)
for k, v122 in arg, nil, nil do
if not (arg2 ~= nil and arg2[k] ~= nil) then
table.insert(arg4, k)
local v123 = (arg3 ~= nil and { arg3[k] } or { nil })[1]

if type(v122) == "table" and not isAtomic(v122) and (v123 == nil or type(v123) == "table" and not isAtomic(v123)) then
fn37(v122, nil, v123, arg4, arg5)
end

arg[k] = nil
table.insert(arg5, table.clone(arg4))
table.remove(arg4)
end
end

if arg2 == nil then
return
end

for k, v122 in arg2, nil, nil do
table.insert(arg4, k)
local tbl19 = arg[k]
local v123 = (arg3 ~= nil and { arg3[k] } or { nil })[1]

if type(v122) == "table" and not isAtomic(v122) and (v123 == nil or type(v123) == "table" and not isAtomic(v123)) then
if type(tbl19) ~= "table" or isAtomic(tbl19) then
tbl19 = {}
arg[k] = tbl19
table.insert(arg5, table.clone(arg4))
end

fn37(tbl19, v122, v123, arg4, arg5)
elseif tbl19 ~= v122 then
if type(tbl19) == "table" and not isAtomic(tbl19) and (v123 == nil or type(v123) == "table" and not isAtomic(v123)) then
fn37(tbl19, nil, v123, arg4, arg5)
end

arg[k] = v122
table.insert(arg5, table.clone(arg4))
end

table.remove(arg4)
end
end

index2._ApplyLoadedData = function(arg, arg2)
local v122 = fn36(arg.Default, arg2)
arg._isLoading = true
table.clear(arg._lastPublishedValueByPathKey)
table.clear(arg._pendingUpdateByPathKey)
table.clear(arg._pendingOrder)
table.clear(arg._liveValueByPathKey)
local tbl19 = {}
fn37(arg.Data, v122, arg.Default, {}, tbl19)
local loaded = arg._middleware.Loaded

if loaded ~= nil then
loaded(arg._middleware, v122)
end

arg:_FireForChangedPaths(tbl19)
arg:_Flush()
arg.Reloaded:Fire()
arg._isLoading = v86[153]
end

index2.LoadFromFile = function(arg, arg2)
local v122 = arg._configManager:LoadFromFile(arg2)
if not v122.Ok then
return v118.err("ReactiveStore", "LoadFromFile", v122.Error.Detail)
end
local value = v122.Value
arg:_ApplyLoadedData(value)
return v118.ok(value)
end

index2.ExportToJson = function(arg)
local v122 = arg._configManager:ToJson(arg:_PersistableData())
if not v122.Ok then
return v118.err("ReactiveStore", v86[99], v122.Error.Detail)
end
return v118.ok(v122.Value)
end

index2.InstallFromJson = function(arg, arg2, arg3)
local v122 = arg._configManager:FromJson(arg3)
if not v122.Ok then
return v118.err("ReactiveStore", "InstallFromJson", v122.Error.Detail)
end
local v123 = arg._configManager:SaveToFile(arg2)
if not v123.Ok then
return v118.err(v86[2], "InstallFromJson", v123.Error.Detail)
end
return v118.VoidOk
end

index2.LoadFromJson = function(arg, arg2)
local v122 = arg._configManager:FromJson(arg2)
if not v122.Ok then
return v118.err(v86[2], "LoadFromJson", v122.Error.Detail)
end
arg:_ApplyLoadedData(v122.Value)
return v118.VoidOk
end

index2.DeleteFile = function(arg, arg2)
local v122 = arg._configManager:Delete(arg2)
if not v122.Ok then
return v118.err("ReactiveStore", "DeleteFile", v122.Error.Detail)
end
return v118.VoidOk
end

index2.AllConfigs = function(arg)
return arg._configManager:AllConfigs()
end

index2.Destroy = function(arg)
arg._trove:Destroy()
end

return index2
end

tbl17.l = function()
local l = tbl17.cache.l

if not l then
l = { c = fn35() }
tbl17.cache.l = l
end

return l.c
end
end
do -- m
local function fn35()
local tbl18

tbl18 = {
normalize = function(arg)
local tbl19 = {}

for k, v115 in arg, nil, nil do
local kind = typeof(v115)
local tbl20

if kind == "Color3" then
tbl20 = { __type = v86[115], R = v115.R, G = v115.G, B = v115.B }
elseif kind == "EnumItem" then
tbl20 = { __type = "EnumItem", EnumType = tostring(v115.EnumType), Name = v115.Name }
elseif kind == "Vector3" then
tbl20 = { __type = v86[20], X = v115.X, Y = v115.Y, Z = v115.Z }
elseif kind == v86[127] then
tbl20 = { __type = "CFrame", Components = { v115:GetComponents() } }
elseif kind == "ColorSequence" then
local v116 = table.create(#v115.Keypoints)

for k2, v117 in v115.Keypoints, nil, nil do
v116[k2] = { Time = v117.Time, R = v117.Value.R, G = v117.Value.G, B = v117.Value.B }
end

tbl20 = { __type = v86[93], Keypoints = v116 }
elseif kind == "NumberSequence" then
local v116 = table.create(#v115.Keypoints)

for k2, v117 in v115.Keypoints, nil, nil do
v116[k2] = { Time = v117.Time, Value = v117.Value, Envelope = v117.Envelope }
end

tbl20 = { __type = "NumberSequence", Keypoints = v116 }
elseif kind == "table" then
tbl20 = tbl18.normalize(v115)
else
tbl20 = v115
end

tbl19[k] = tbl20
end

return tbl19
end,
parse = function(arg)
local tbl19 = {}

for k, v115 in arg, nil, nil do
if typeof(v115) == "table" then
local type_ = v115.__type

if type(type_) ~= "string" then
tbl19[k] = tbl18.parse(v115)
else
if type_ == "Color3" then
v115 = Color3.new(v115.R, v115.G, v115.B)
elseif type_ == "EnumItem" then
v115 = Enum[v115.EnumType][v115.Name]
elseif type_ == "Vector3" then
v115 = Vector3.new(v115.X, v115.Y, v115.Z)
elseif type_ == "CFrame" then
v115 = CFrame.new(unpack(v115.Components))
elseif type_ == v86[93] then
local v116 = table.create(#v115.Keypoints)

for k2, v117 in v115.Keypoints, nil, nil do
v116[k2] = ColorSequenceKeypoint.new(v117.Time, Color3.new(v117.R, v117.G, v117.B))
end

v115 = ColorSequence.new(v116)
elseif type_ == "NumberSequence" then
local v116 = table.create(#v115.Keypoints)

for k2, v117 in v115.Keypoints, nil, nil do
v116[k2] = NumberSequenceKeypoint.new(v117.Time, v117.Value, v117.Envelope)
end

v115 = NumberSequence.new(v116)
end

tbl19[k] = v115
end

continue
end

tbl19[k] = v115
end

return tbl19
end,
}

return tbl18
end

tbl17.m = function()
local m = tbl17.cache.m

if not m then
local m2 = { c = fn35() }
tbl17.cache.m = m2
m = m2
end

return m.c
end
end
do -- r
local function fn35()
tbl17.l()
tbl17.g()
tbl17.k()
return {}
end

tbl17.r = function()
local r = tbl17.cache.r

if not r then
r = { c = fn35() }
tbl17.cache.r = r
end

return r.c
end
end
do -- s
local function fn35()return table.freeze({Medium=Font.new("rbxassetid://12187365364",Enum.FontWeight.Medium,Enum.FontStyle.Normal),SemiBold=Font.new("rbxassetid://12187365364",Enum.FontWeight.SemiBold,Enum.FontStyle.Normal),Bold=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal)});end

tbl17.s = function()
local s = tbl17.cache.s

if not s then
local s2 = { c = fn35() }
tbl17.cache.s = s2
s = s2
end

return s.c
end
end
do -- t
local function fn35()return{Players=cloneref(game:GetService("Players")),GuiService=cloneref(game:GetService("GuiService")),UserInputService=cloneref(game:GetService("UserInputService")),RunService=cloneref(game:GetService("RunService")),TweenService=cloneref(game:GetService("TweenService")),HttpService=cloneref(game:GetService("HttpService")),CoreGui=cloneref(game:GetService("CoreGui"))};end

tbl17.t = function()
local t = tbl17.cache.t

if not t then
if n26 >= 4809 then
-- (anti-tamper freeze trap removed)
else
local t2 = { c = fn35() }
tbl17.cache.t = t2
t = t2
end
end

return t.c
end
end
do -- u
local function fn35()local I= tbl17 .t();local l,W,N=I.GuiService,I.UserInputService,{DesignSize=UDim2.fromOffset(919,643),MinSize=UDim2.fromOffset(700,400),Scale=1};local function I_10()return workspace.CurrentCamera;end;local function P(a)if not a then return false;end;a=I_10();if a==nil then return false;end;local I=a.ViewportSize;return math.min(I.X,I.Y)>500;end;local function I_11(a)if a then return false;end;a=W.PreferredInput;if a==Enum.PreferredInput.Touch then return true;end;if a==Enum.PreferredInput.KeyboardAndMouse or a==Enum.PreferredInput.Gamepad then return false;end;a=W:GetLastInputType();if a==Enum.UserInputType.Touch then return true;end;if a==Enum.UserInputType.MouseButton1 or a==Enum.UserInputType.MouseButton2 or a==Enum.UserInputType.MouseMovement or a==Enum.UserInputType.Keyboard then return false;end;return W.TouchEnabled and not W.KeyboardEnabled;end;local a=l:IsTenFootInterface();local l_12=I_11(a);local I_13;N.IsMobile=function()return l_12;end;N.ForceMobileLayout=function(e)l_12=true;I_13=e==true;end;N.IsTablet=function()local l=I_13;if l==nil then l=P(N.IsMobile());I_13=l;end;return l;end;N.HasTouch=function()return not a and W.TouchEnabled;end;N.WantsMobileButtons=function()return N.HasTouch()or(N.IsMobile());end;return N;end

tbl17.u = function()
local u = tbl17.cache.u

if not u then
local u2 = { c = fn35() }
tbl17.cache.u = u2
u = u2
end

return u.c
end
end
do -- v
local function fn35()local I,W,N,P= tbl17 .u(),{},table.freeze({IsCompact=false,Rail=table.freeze({Width=100,HeaderHeight=85,TabsTop=102,TabSize=66,TabGap=4,TabIconSize=26,LogoSize=Vector2.new(48,37),ShowLabels=true}),Page=table.freeze({HasTitleBlock=true,OuterInset=18,HorizontalInset=17,HeaderHeight=85,TabsHeight=84,BottomInset=17,TitleTextSize=18,DescriptionTextSize=13,TabMinWidth=50,TabHeight=50,TabIconSize=24,TabTextSize=16,TabGap=14,TabPaddingLeft=13,TabPaddingRight=16,SearchCollapsedWidth=90,SearchExpandedWidth=260,SearchHeight=33,SearchRightInset=14}),Navigation=table.freeze({CueDepth=12,RevealPadding=4,VisibilityEpsilon=1}),Grid=table.freeze({Gap=17,MinColumnWidth=220}),Section=table.freeze({Gap=17,TitleGap=16,InnerPadding=12,ElementGap=12,GroupGap=12,TitleTextSize=16,MultiHeaderHeight=45,MultiHeaderGap=12,MultiHeaderPadding=12,MultiPaneTop=57,MultiTabTextSize=16}),Row=table.freeze({Height=24,TextSize=16,ControlVerticalInset=0,ControlHeight=22,AttachmentGap=11,ListRowHeight=26}),Button=table.freeze({RowHeight=24,VisualHeight=22,Gap=13})}),table.freeze({IsCompact=true,Rail=table.freeze({Width=52,HeaderHeight=48,TabsTop=52,TabSize=44,TabGap=2,TabIconSize=20,LogoSize=Vector2.new(24,19),ShowLabels=false}),Page=table.freeze({HasTitleBlock=true,OuterInset=12,HorizontalInset=12,HeaderHeight=44,TabsHeight=40,BottomInset=12,TitleTextSize=16,DescriptionTextSize=10,TabMinWidth=44,TabHeight=34,TabIconSize=18,TabTextSize=13,TabGap=6,TabPaddingLeft=8,TabPaddingRight=10,SearchCollapsedWidth=32,SearchExpandedWidth=220,SearchHeight=32,SearchRightInset=8}),Navigation=table.freeze({CueDepth=12,RevealPadding=4,VisibilityEpsilon=1}),Grid=table.freeze({Gap=12,MinColumnWidth=220}),Section=table.freeze({Gap=12,TitleGap=8,InnerPadding=8,ElementGap=8,GroupGap=8,TitleTextSize=15,MultiHeaderHeight=36,MultiHeaderGap=8,MultiHeaderPadding=8,MultiPaneTop=44,MultiTabTextSize=13}),Row=table.freeze({Height=32,TextSize=14,ControlVerticalInset=4,ControlHeight=24,AttachmentGap=8,ListRowHeight=32}),Button=table.freeze({RowHeight=32,VisualHeight=30,Gap=8})});local l=table.freeze({IsCompact=true,Rail=P.Rail,Page=table.freeze({HasTitleBlock=false,OuterInset=12,HorizontalInset=12,HeaderHeight=0,TabsHeight=44,BottomInset=12,TitleTextSize=16,DescriptionTextSize=10,TabMinWidth=44,TabHeight=36,TabIconSize=18,TabTextSize=14,TabGap=6,TabPaddingLeft=8,TabPaddingRight=10,SearchCollapsedWidth=32,SearchExpandedWidth=220,SearchHeight=32,SearchRightInset=8}),Navigation=P.Navigation,Grid=table.freeze({Gap=12,MinColumnWidth=330}),Section=P.Section,Row=table.freeze({Height=40,TextSize=15,ControlVerticalInset=6,ControlHeight=28,AttachmentGap=8,ListRowHeight=40}),Button=table.freeze({RowHeight=40,VisualHeight=36,Gap=8})});W.get=function()if not I.IsMobile()then return N;end;if I.IsTablet()then return P;end;return l;end;return W;end

tbl17.v = function()
local v115 = tbl17.cache.v

if not v115 then
v115 = { c = fn35() }
tbl17.cache.v = v115
end

return v115.c
end
end
do -- x
local function fn35() tbl17 .k();local I,W= tbl17 .t(), tbl17 .w();local l,N,P=I.UserInputService,{},setmetatable({},{__mode="k"});N.suppressActivation=function(I)P[I]=true;end;local I_14=W.findScrollingAncestor;N.connectPress=function(a,e,c,E)local p,T,t,x=false, nil, nil, nil;local function S(J)if not p then return;end;p,T,t=false,nil,nil;if x~=nil then x:Disconnect();x=nil;end;E(J);end;a:Add({Destroy=function()p,T,t=false,nil,nil;if x~=nil then x:Disconnect();x=nil;end;end});a:Connect(e.InputBegan,function(E)if p then return;end;local J=E.UserInputType;if J~=Enum.UserInputType.MouseButton1 and J~=Enum.UserInputType.Touch then return;end;T,t,p=E,J,true;c();x=l.InputEnded:Connect(function(c)if T==nil then return;end;if not W.matchesPointerDrag(c,T,Enum.UserInputType.MouseButton1)then return;end;S(false);end);end);a:Connect(e.MouseLeave,function()if t==Enum.UserInputType.MouseButton1 then S(true);end;end);end;N.connectClick=function(a,e,c)if e:IsA("GuiButton")then a:Connect(e.Activated,function(E,p)if P[E]then P[E]=nil;return;end;c();end);return;end;a:Connect(e.InputBegan,function(P)local a=P.UserInputType;if a==Enum.UserInputType.MouseButton1 or a==Enum.UserInputType.Touch then c();end;end);end;N.connectDrag=function(P,a,e,c)local E,p,T,t,x=c or function(c,c_15)end, nil, nil, nil, nil;local c_16,S,J,B,X=false,false,0, nil, nil;local function H()J+=1;if B~=nil then B:Disconnect();B=nil;end;if X~=nil then X:Disconnect();X=nil;end;p,T,t,x,c_16,S=nil,nil,nil,nil,false,false;end;local function k(D)local Q=c_16;H();if Q then E(false,D);end;end;local function D()if p==nil or c_16 or S then return;end;c_16=true;E(true,false);end;P:Add({Destroy=H});P:Connect(a.InputBegan,function(P)local E=P.UserInputType;if E~=Enum.UserInputType.MouseButton1 and E~=Enum.UserInputType.Touch then return;end;H();p=P;T=P.Position;t=I_14(a);x=t and t.CanvasPosition or nil;J+=1;local I=J;task.delay(0.3,function()if J==I then D();end;end);X=l.InputEnded:Connect(function(I)if p==nil then return;end;if not W.matchesPointerDrag(I,p,Enum.UserInputType.MouseButton1)then return;end;J+=1;k(false);end);B=l.InputChanged:Connect(function(l)if p==nil or S then return;end;if not W.matchesPointerDrag(l,p,Enum.UserInputType.MouseMovement)then return;end;local I,W=t,x;if I~=nil and W~=nil then local P=I.CanvasPosition-W;if P.X*P.X+P.Y*P.Y>0.25 then if c_16 then k(true);else S=true;J+=1;end;return;end;end;if not c_16 and T~=nil then W,I=l.Position.X-T.X,l.Position.Y-T.Y;if W*W+I*I>=100 then D();end;end;if c_16 then e(l);end;end);end);end;return N;end

tbl17.x = function()
local x = tbl17.cache.x

if not x then
x = { c = fn35() }
tbl17.cache.x = x
end

return x.c
end
end
do -- y
local function fn35()
tbl17.k()
tbl17.r()
local color = Color3.fromRGB(255, v86[108], v86[108])
local tweenInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

return { attach = function(arg, arg2, parent, arg3)
local trigger = parent
local cornerRadius = nil

if arg3 ~= nil then
trigger = arg3.Trigger or parent
cornerRadius = arg3.CornerRadius
end

local frame = Instance.new("Frame")
frame.BackgroundTransparency = v86[63]
frame.Size = UDim2.fromScale(1, 1)
frame.BorderSizePixel = v86[186]
frame.ClipsDescendants = v86[34]
frame.ZIndex = 0
frame.Parent = parent

if cornerRadius ~= nil then
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, cornerRadius)
uiCorner.Parent = frame
end

arg2:Connect(trigger.InputBegan, function(arg4)
local userInputType = arg4.UserInputType
if userInputType ~= Enum.UserInputType.MouseButton1 and userInputType ~= Enum.UserInputType.Touch then
return
end
local absoluteSize = parent.AbsoluteSize
local absolutePosition = parent.AbsolutePosition
local n = arg4.Position.X - absolutePosition.X
local n33 = arg4.Position.Y - absolutePosition.Y
local n34 = math.max(absoluteSize.X, absoluteSize.Y) * v86[49]
local frame2 = Instance.new("Frame")
frame2.AnchorPoint = Vector2.new(0.5, v86[101])
frame2.Position = UDim2.fromOffset(n, n33)
frame2.Size = UDim2.fromOffset(0, 0)
frame2.BackgroundColor3 = color
frame2.BackgroundTransparency = 0.84
frame2.BorderSizePixel = 0
frame2.Parent = frame
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(v86[63], 0)
uiCorner.Parent = frame2
local v115 = arg:Tween(frame2, { Size = UDim2.fromOffset(n34, n34), BackgroundTransparency = 1 }, tweenInfo)

if v115 ~= nil then
v115.Completed:Once(function()
frame2:Destroy()
end)
else
frame2:Destroy()
end
end)
end }
end

tbl17.y = function()
local y = tbl17.cache.y

if not y then
local y2 = { c = fn35() }
tbl17.cache.y = y2
y = y2
end

return y.c
end
end
do -- z
local function fn35()return{Accent=Color3.fromRGB(197,59,59),Outline=Color3.fromRGB(220,220,220),Background=Color3.fromRGB(255,255,255),ElementBackground=Color3.fromRGB(245,245,245),TabButtonSelected=Color3.fromRGB(230,230,230),Unselected=Color3.fromRGB(210,210,210),TextColor=Color3.fromRGB(35,35,35),ToggleCircleUnselected=Color3.fromRGB(170,170,170),ToggleBackgroundUnselected=Color3.fromRGB(225,225,225),GradientTop=Color3.fromRGB(255,255,255),GradientMid=Color3.fromRGB(248,248,248),GradientDark=Color3.fromRGB(240,240,240),GradientDeep=Color3.fromRGB(232,232,232),TabHighlight=Color3.fromRGB(220,220,220),TabShadow=Color3.fromRGB(200,200,200)};end

tbl17.z = function()
local z = tbl17.cache.z

if not z then
local z2 = { c = fn35() }
tbl17.cache.z = z2
z = z2
end

return z.c
end
end
do -- A
local function fn35()
tbl17.k()
local v115 = tbl17.z()
local index2 = {}
index2.__index = index2
local tbl18 = {}
local tbl19 = { Tokens = v115 }

local function fn36(arg, arg2)
local n = #arg
if n == 1 then
return ColorSequence.new(v115[arg[1]])
end
local tbl20 = {}

for k, v116 in arg, nil, nil do
local n33

if arg2 ~= nil then
n33 = arg2[k]
else
n33 = (k - 1) / (n - 1)
end

tbl20[k] = ColorSequenceKeypoint.new(n33, v115[v116])
end

return ColorSequence.new(tbl20)
end

local function fn37(arg, arg2)
if arg._tokenSet[arg2] then
return
end
arg._tokenSet[arg2] = true
local tbl20 = tbl18[arg2]

if tbl20 == nil then
tbl20 = {}
tbl18[arg2] = tbl20
end

tbl20[arg] = v86[34]
end

index2.new = function()
return setmetatable({ _propBindingsByToken = {}, _gradients = {}, _statefulApplyByToken = {}, _tokenSet = {} }, index2)
end

index2.Bind = function(arg, arg2, arg3, arg4)
arg2[arg3] = v115[arg4]
local tbl20 = arg._propBindingsByToken[arg4]

if tbl20 == nil then
tbl20 = {}
arg._propBindingsByToken[arg4] = tbl20
end

table.insert(tbl20, { Instance = arg2, Property = arg3 })
fn37(arg, arg4)
end

index2.BindGradient = function(arg, arg2, arg3, arg4)
arg2.Color = fn36(arg3, arg4)
table.insert(arg._gradients, { Gradient = arg2, Tokens = arg3, Times = arg4 })

for _, v116 in arg3, nil, nil do
fn37(arg, v116)
end
end

index2.BindStateful = function(arg, arg2, arg3)
local tbl20 = arg._statefulApplyByToken[arg2]

if tbl20 == nil then
tbl20 = {}
arg._statefulApplyByToken[arg2] = tbl20
end

table.insert(tbl20, arg3)
fn37(arg, arg2)
end

index2.Destroy = function(arg)
for k in arg._tokenSet, nil, nil do
local v116 = tbl18[k]

if v116 ~= nil then
v116[arg] = nil
end
end

table.clear(arg._tokenSet)
table.clear(arg._propBindingsByToken)
table.clear(arg._gradients)
table.clear(arg._statefulApplyByToken)
end

tbl19.newBatch = function(arg)
local v116 = index2.new()

if arg ~= nil then
arg:Add(v116)
end

return v116
end

tbl19.get = function(arg)
return v115[arg]
end

local tbl20 = { "GradientTop", v86[187], v86[70], v86[141] }
local tbl21 = {}
local background = v115.Background

for _, v116 in tbl20, nil, nil do
local v117 = v115[v116]
tbl21[v116] = { R = v117.R - background.R, G = v117.G - background.G, B = v117.B - background.B }
end

local function fn38(I,W)if  v115 [I]==W then return;end; v115 [I]=W;local N= tbl18 [I];if N==nil then return;end;for P in N,nil,nil do local N_17=P._propBindingsByToken[I];if N_17~=nil then for a,a_18 in N_17,nil,nil do a_18.Instance[a_18.Property]=W;end;end;for a,a_19 in P._gradients,nil,nil do if table.find(a_19.Tokens,I)~=nil then a_19.Gradient.Color= fn36 (a_19.Tokens,a_19.Times);end;end;N_17=P._statefulApplyByToken[I];if N_17~=nil then for l,l_20 in N_17,nil,nil do l_20(W);end;end;end;end

local function fn39(arg)
for _, v116 in tbl20, nil, nil do
local v117 = tbl21[v116]
fn38(v116, Color3.new(math.clamp(arg.R + v117.R, v86[186], 1), math.clamp(arg.G + v117.G, 0, 1), math.clamp(arg.B + v117.B, 0, 1)))
end
end

tbl19.refresh = function(arg, arg2)
fn38(arg, arg2)

if arg == "Background" then
fn39(arg2)
end
end

return tbl19
end

tbl17.A = function()
local a = tbl17.cache.A

if not a then
local a2 = { c = fn35() }
tbl17.cache.A = a2
a = a2
end

return a.c
end
end
do -- B
local function fn35()
local v115 = tbl17.k()
tbl17.r()
local v116 = tbl17.s()
local v117 = tbl17.v()
local v118 = tbl17.A()
local index2 = {}
index2.__index = index2

index2.new = function(arg, arg2)
local v119 = v117.get()
local flag19 = arg2.Bare == v86[34]
local height = arg2.Height or v119.Row.Height
local n

if v119.IsCompact and not flag19 then
n = math.max(height, v119.Row.Height)
else
n = height
end

return setmetatable({
_menu = arg,
_metrics = v119,
Label = arg2.Label,
_tooltip = arg2.Tooltip,
_bare = flag19,
_isBareFlexRoot = false,
_visible = v86[34],
_height = n,
_mediumTitle = arg2.MediumTitle == true,
_rightOffset = arg2.RightOffset or 0,
_attachments = {},
_titleAccessories = {},
_titleAccessoryReserve = v86[186],
_isDestroyed = false,
_onVisibilityChanged = function()
end,
_ctx = nil,
_barePending = nil,
_isTooltipWired = false,
Frame = nil,
TitleLabel = nil,
Right = nil,
_rightLayout = nil,
}, index2)
end

index2.AttachRight = function(arg, arg2, arg3, arg4, arg5, arg6, arg7)
local tbl18 = {
Build = arg2,
BuildRoot = arg6,
IsFlexChild = arg7 == true,
IsInRight = false,
Widget = nil,
NaturalWidth = arg3,
Leading = arg4,
Trove = v115.new(),
Cleanup = nil,
}

local cleanup = { Destroy = function()
arg:_DetachAttachment(tbl18)
end }

tbl18.Cleanup = cleanup

if arg5 ~= nil then
arg5:Add(cleanup)
end

if arg._isDestroyed then
tbl18.Trove:Destroy()
return
end
table.insert(arg._attachments, tbl18)
local ctx = arg._ctx
if ctx == nil then
return
end
local barePending = arg._barePending

if barePending ~= nil then
arg._barePending = nil
arg:_BuildBareRoot(barePending.Parent, barePending.LayoutOrder, ctx)
return
end

arg:_RealizeAttachment(tbl18, ctx)
end

index2._DetachAttachment = function(arg, arg2)
local v119 = table.find(arg._attachments, arg2)
if v119 == nil then
return
end
local isInRight = arg2.IsInRight
table.remove(arg._attachments, v119)
arg2.Trove:Destroy()
arg2.Widget = nil
arg2.Cleanup = nil

if arg._bare and isInRight then
local flag19 = v86[153]

for _, v120 in arg._attachments, nil, nil do
if v120.IsInRight then
flag19 = true
break
end
end

if not flag19 then
local right = arg.Right

if right ~= nil then
right:Destroy()
arg.Right = nil
arg._rightLayout = nil
end
end
end

if #arg._attachments > 0 then
return
end
arg._isDestroyed = true
arg._barePending = nil
local frame = arg.Frame

if frame ~= nil then
frame:Destroy()
arg.Frame = nil
end

arg.TitleLabel = nil
arg.Right = nil
arg._rightLayout = nil
arg._isBareFlexRoot = false
arg._onVisibilityChanged()
end

index2.AttachTitleAccessory = function(arg, arg2, arg3, arg4)
local tbl18 = { Build = arg2, Trove = v115.new(), Widget = nil }

local tbl19 = { Destroy = function()
local v119 = table.find(arg._titleAccessories, tbl18)

if v119 ~= nil then
table.remove(arg._titleAccessories, v119)
end

tbl18.Trove:Destroy()
tbl18.Widget = nil
end }

if arg4 ~= nil then
arg4:Add(tbl19)
end

if arg._isDestroyed then
tbl18.Trove:Destroy()
return
end
table.insert(arg._titleAccessories, tbl18)
arg._titleAccessoryReserve = arg._titleAccessoryReserve + arg3
local ctx = arg._ctx

if ctx ~= nil and arg.TitleLabel ~= nil then
arg:_RealizeTitleAccessory(tbl18, ctx)
end
end

index2._RealizeTitleAccessory = function(arg, arg2, arg3)
arg2.Widget = arg2.Build(arg.TitleLabel, {
Menu = arg3.Menu,
Trove = arg2.Trove,
Batch = v118.newBatch(arg2.Trove),
ParentOverlay = arg3.ParentOverlay,
})
end

index2._EnsureRightLayout = function(arg, parent)
if arg._rightLayout ~= nil then
return
end
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
uiListLayout.FillDirection = Enum.FillDirection.Horizontal
uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
uiListLayout.Padding = UDim.new(0, arg._metrics.Row.AttachmentGap)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = parent
arg._rightLayout = uiListLayout

for k, v119 in arg._attachments, nil, nil do
if not (arg._bare and k == 1) then
local widget = v119.Widget

if widget ~= nil then
widget.LayoutOrder = v119.Leading and -1 or k
end
end
end
end

index2._EnsureBareRight = function(arg)
if arg.Right ~= nil then
return arg.Right
end
local frame = arg.Frame
if frame == nil then
return nil
end
local frame2 = Instance.new("Frame")
frame2.AnchorPoint = Vector2.new(v86[63], 0.5)
frame2.Position = UDim2.new(1, arg._rightOffset, 0.5, 0)
frame2.Size = UDim2.new(0.55, 0, v86[186], arg._height)
frame2.BorderSizePixel = 0
frame2.BackgroundTransparency = 1
frame2.Parent = frame
arg.Right = frame2
arg:_EnsureRightLayout(frame2)
return frame2
end

index2._RealizeAttachment = function(arg, arg2, arg3)
local frame

if arg._bare then
if arg._isBareFlexRoot and arg2.IsFlexChild then
frame = arg.Frame
else
frame = arg:_EnsureBareRight()
end
else
frame = arg.Right or arg.Frame

if arg.Right ~= nil and #arg._attachments >= 2 then
arg:_EnsureRightLayout(arg.Right)
end
end

if frame == nil then
return
end
arg2.IsInRight = arg.Right ~= nil and frame == arg.Right
local tbl18 = {}

for _, v119 in frame:GetChildren() do
tbl18[v119] = v86[34]
end

local v119 = arg2.Build(frame, {
Menu = arg3.Menu,
Trove = arg2.Trove,
Batch = v118.newBatch(arg2.Trove),
ParentOverlay = arg3.ParentOverlay,
})

arg2.Widget = v119

for _, v120 in frame:GetChildren() do
if not tbl18[v120] then
arg2.Trove:Add(v120)
end
end

if v119 ~= nil and arg._rightLayout ~= nil then
local layoutOrder = table.find(arg._attachments, arg2) or #arg._attachments

if arg2.Leading then
layoutOrder = -v86[63]
end

v119.LayoutOrder = layoutOrder
end
end

local function fn36(arg)
local v119 = v86[186]

for k, v120 in arg._attachments, nil, nil do
local naturalWidth = v120.NaturalWidth
if naturalWidth == nil then
return nil
end
v119 += naturalWidth

if k > 1 then
v119 += arg._metrics.Row.AttachmentGap
end
end

if v119 == 0 then
return nil
end
return v119
end

local function fn37(arg, arg2, arg3, arg4, arg5)
local flag19 = false
local flag20 = false
local size = arg5.Size
local anchorPoint = arg5.AnchorPoint
local position = arg5.Position
local position2 = arg4.Position
local size2 = arg3.Size
local automaticSize = arg3.AutomaticSize
local scale = size.X.Scale
local n = 1

if scale > 0 then
n = v86[63] - scale
end

local n33 = arg4.TextBounds.X + arg._titleAccessoryReserve

local function fn38()
if flag20 then
return
end
flag20 = true
local x = arg3.AbsoluteSize.X
if x <= 0 then
flag20 = false
return
end
local n34 = x * n - v86[162]
local v119 = fn36(arg)

if v119 ~= nil then
n34 = x - v119 - 8
end

local flag21 = n33 > n34
if flag21 == flag19 then
flag20 = false
return
end
flag19 = flag21

if flag19 then
local v120 = math.round(math.max(arg4.TextBounds.Y, arg._metrics.Row.TextSize))
arg4.AnchorPoint = Vector2.zero
arg4.Position = UDim2.new(0, 0, v86[186], v86[186])
arg5.AnchorPoint = Vector2.zero
arg5.Position = UDim2.fromOffset(0, v120 + 4)
arg5.Size = UDim2.new(1, 0, 0, size.Y.Offset)
arg3.AutomaticSize = Enum.AutomaticSize.None
arg3.Size = UDim2.new(1, 0, 0, v120 + 4 + size.Y.Offset)
else
arg4.AnchorPoint = Vector2.zero
arg4.Position = position2
arg5.AnchorPoint = anchorPoint
arg5.Position = position
arg5.Size = size
arg3.AutomaticSize = automaticSize
arg3.Size = size2
end

flag20 = false
end

fn38()
arg2.Trove:Connect(arg3:GetPropertyChangedSignal("AbsoluteSize"), fn38)

arg2.Trove:Connect(arg4:GetPropertyChangedSignal(v86[37]), function()
n33 = arg4.TextBounds.X + arg._titleAccessoryReserve
fn38()
end)
end

index2._BuildBareRoot = function(arg, arg2, layoutOrder, arg3)
local v119 = arg._attachments[1]
v119.IsInRight = false
arg._isBareFlexRoot = v119.IsFlexChild

local v120 = (v119.BuildRoot or v119.Build)(arg2, {
Menu = arg3.Menu,
Trove = v119.Trove,
Batch = v118.newBatch(v119.Trove),
ParentOverlay = arg3.ParentOverlay,
})

assert(v120 ~= nil, "Row: bare row builder returned no root")
v120.LayoutOrder = layoutOrder
v120.Visible = arg._visible
arg.Frame = v120

for _, v121 in v120:GetChildren() do
if not v121:IsA("UIListLayout") then
v119.Trove:Add(v121)
end
end

for i = 2, #arg._attachments do
local v121 = arg._attachments[i]

if v121.Widget == nil then
arg:_RealizeAttachment(v121, arg3)
end
end

arg:_WireTooltip()
end

index2.Realize = function(arg, parent, ctx, layoutOrder)
if arg._ctx ~= nil or arg._isDestroyed then
return
end
arg._ctx = ctx

if arg._bare then
if arg._attachments[1] == nil then
arg._barePending = { Parent = parent, LayoutOrder = layoutOrder }
return
end
arg:_BuildBareRoot(parent, layoutOrder, ctx)
else
local textButton = Instance.new("TextButton")
textButton.BackgroundTransparency = 1
textButton.Size = UDim2.new(1, 0, 0, arg._height)
textButton.BorderSizePixel = 0
textButton.AutomaticSize = Enum.AutomaticSize.Y
textButton.AutoButtonColor = false
textButton.Text = ""
textButton.LayoutOrder = layoutOrder
textButton.Visible = arg._visible
textButton.Parent = parent
arg.Frame = textButton
local n = arg._metrics.Row.TextSize + 4
local textLabel = Instance.new("TextLabel")
textLabel.Text = arg.Label or ""
textLabel.AnchorPoint = Vector2.zero
textLabel.BackgroundTransparency = v86[63]
textLabel.Position = UDim2.fromOffset(v86[186], math.round((arg._height - n) / 2))
textLabel.Size = UDim2.fromOffset(0, n)
textLabel.BorderSizePixel = 0
textLabel.AutomaticSize = Enum.AutomaticSize.X
textLabel.TextSize = arg._metrics.Row.TextSize
textLabel.TextXAlignment = Enum.TextXAlignment.Left

if arg._mediumTitle then
textLabel.FontFace = v116.Medium
else
textLabel.FontFace = ctx.Menu.Fonts.Main
end

ctx.Batch:Bind(textLabel, "TextColor3", "TextColor")
textLabel.Parent = textButton
arg.TitleLabel = textLabel
local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(1, v86[186])
frame.Position = UDim2.new(v86[63], arg._rightOffset, 0, 0)
frame.Size = UDim2.new(0.55, 0, 0, arg._height)
frame.BorderSizePixel = 0
frame.AutomaticSize = Enum.AutomaticSize.Y
frame.BackgroundTransparency = 1
frame.Parent = textButton
local controlVerticalInset = arg._metrics.Row.ControlVerticalInset

if controlVerticalInset > 0 then
frame.AutomaticSize = Enum.AutomaticSize.None
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingTop = UDim.new(0, controlVerticalInset)
uiPadding.PaddingBottom = UDim.new(v86[186], controlVerticalInset)
uiPadding.Parent = frame
end

arg.Right = frame

for _, v119 in arg._attachments, nil, nil do
if v119.Widget == nil then
arg:_RealizeAttachment(v119, ctx)
end
end

for _, v119 in arg._titleAccessories, nil, nil do
if v119.Widget == nil then
arg:_RealizeTitleAccessory(v119, ctx)
end
end

fn37(arg, ctx, textButton, textLabel, frame)
arg:_WireTooltip()
end
end

index2._WireTooltip = function(arg)
if arg._isTooltipWired or arg._tooltip == nil then
return
end
local ctx = arg._ctx
local frame = arg.Frame
if ctx == nil or frame == nil then
return
end
arg._isTooltipWired = true

ctx.Menu:AttachTooltip(ctx.Trove, frame, function()
return arg._tooltip
end)
end

index2.SetLabel = function(arg, label)
arg.Label = label
arg._menu:InvalidateSearch()
local titleLabel = arg.TitleLabel

if titleLabel ~= nil then
titleLabel.Text = label
end
end

index2.SetTooltip = function(arg, tooltip)
arg._tooltip = tooltip
arg:_WireTooltip()
end

index2.SetVisible = function(arg, visible)
if arg._visible == visible then
return
end
arg._visible = visible
local frame = arg.Frame

if frame ~= nil then
frame.Visible = visible
end

arg._onVisibilityChanged()
end

index2.IsVisible = function(arg)
return arg._visible
end

index2.Destroy = function(arg)
arg._isDestroyed = true
arg._barePending = nil

for i = #arg._attachments, 1, -v86[63] do
local v119 = arg._attachments[i]
table.remove(arg._attachments, i)
v119.Trove:Destroy()
v119.Widget = nil
v119.Cleanup = nil
end

for i = #arg._titleAccessories, 1, -1 do
local v119 = arg._titleAccessories[i]
table.remove(arg._titleAccessories, i)
v119.Trove:Destroy()
v119.Widget = nil
end

local frame = arg.Frame

if frame ~= nil then
frame:Destroy()
arg.Frame = nil
end

arg.TitleLabel = nil
arg.Right = nil
arg._rightLayout = nil
arg._isBareFlexRoot = false
arg._onVisibilityChanged()
end

return index2
end

tbl17.B = function()
local b = tbl17.cache.B

if not b then
b = { c = fn35() }
tbl17.cache.B = b
end

return b.c
end
end
do -- C
local function fn35()
local v115 = tbl17.g()
tbl17.k()
tbl17.r()
local v116 = tbl17.s()
local v117 = tbl17.v()
local v118 = tbl17.x()
local v119 = tbl17.y()
tbl17.B()
local v120 = tbl17.A()
local color = Color3.fromRGB(255, 255, 255)
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(v86[62], Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local color2 = Color3.fromRGB(v86[102], 92, v86[53])

local function fn36(arg, arg2)
local clamp = math.clamp
local n = arg.B * arg2
return Color3.new(math.clamp(arg.R * arg2, v86[186], v86[63]), math.clamp(arg.G * arg2, 0, v86[63]), clamp(n, 0, 1))
end

local function fn37(arg)
return arg == "primary" and v120.get("Accent") or color
end

local function fn38(arg)
local flag19 = arg == "primary"

if flag19 then
local v121 = v86[66]
flag19 = fn36(v120.get("Accent"), v121)
end

return flag19 or Color3.fromRGB(v86[65], 220, 230)
end

local function fn39(arg)
if arg == "primary" then
return color
end

if arg == "ghost" then
return v120.get("Unselected")
end
return v120.get("TextColor")
end

local function fn40(arg)
return arg == "primary" and fn36(v120.get(v86[139]), 0.6) or v120.get(v86[120])
end

local index2 = {}
index2.__index = index2

local function createFrame(arg, parent, arg2)
local menu = arg._menu
local variant = arg._variant
local button = v117.get().Button
local transparency = 0
local n = 0

if variant == "primary" then
n = 0.6
elseif variant == "ghost" then
if n26 < 4790 then
-- (anti-tamper freeze trap removed)
else
transparency = 1
n = 1
end
end

local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(v86[63], v86[186])
frame.Position = UDim2.new(1, -v86[63], 0, 1)
frame.Size = UDim2.fromOffset(v86[186], button.VisualHeight)
frame.BorderSizePixel = 0
frame.BackgroundColor3 = fn37(variant)
frame.ClipsDescendants = v86[34]
frame.Parent = parent

if variant == "default" then
local uiGradient = Instance.new("UIGradient")
uiGradient.Rotation = 90
arg2.Batch:BindGradient(uiGradient, { "GradientMid", "GradientDark" })
uiGradient.Parent = frame
end

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(v86[186], 5)
uiCorner.Parent = frame
local uiStroke = Instance.new("UIStroke")
uiStroke.Color = fn40(variant)
uiStroke.Transparency = transparency
uiStroke.Parent = frame
local instance = Instance.new(v86[92])
instance.BackgroundTransparency = 1
instance.Size = UDim2.fromScale(1, 1)
instance.BorderSizePixel = 0
instance.Text = ""
instance.AutoButtonColor = false
instance.Parent = frame
v119.attach(menu, arg2.Trove, frame, { Trigger = instance })
local textLabel = Instance.new("TextLabel")
textLabel.LayoutOrder = -v86[63]
textLabel.FontFace = v116.SemiBold
textLabel.TextColor3 = fn39(variant)
textLabel.Text = arg.Label
textLabel.BackgroundTransparency = 1
textLabel.Size = UDim2.fromScale(1, 1)
textLabel.BorderSizePixel = 0
textLabel.TextSize = 16
textLabel.Parent = frame
arg._title = textLabel

if variant == "default" then
arg2.Batch:Bind(textLabel, "TextColor3", "TextColor")
elseif variant == "ghost" then
arg2.Batch:Bind(textLabel, "TextColor3", "Unselected")
end

arg2.Trove:Connect(instance.MouseEnter, function()
menu:Tween(frame, { BackgroundColor3 = fn38(variant) }, tweenInfo)

if variant == "default" then
menu:Tween(uiStroke, { Color = v120.get("Accent") }, tweenInfo)
elseif variant == "primary" then
menu:Tween(uiStroke, { Transparency = n }, tweenInfo)
elseif variant == "ghost" then
menu:Tween(textLabel, { TextColor3 = v120.get("TextColor") }, tweenInfo)
end
end)

arg2.Trove:Connect(instance.MouseLeave, function()
menu:Tween(frame, { BackgroundColor3 = fn37(variant) }, tweenInfo)

if variant == "default" then
menu:Tween(uiStroke, { Color = v120.get("Outline") }, tweenInfo)
elseif variant == "primary" then
menu:Tween(uiStroke, { Transparency = transparency }, tweenInfo)
elseif variant == "ghost" then
menu:Tween(textLabel, { TextColor3 = v120.get("Unselected") }, tweenInfo)
end
end)

local backgroundColor3 = nil

v118.connectPress(arg2.Trove, instance, function()
backgroundColor3 = frame.BackgroundColor3
menu:Tween(frame, { BackgroundColor3 = fn36(backgroundColor3, 0.85) }, tweenInfo2)
end, function()
if backgroundColor3 ~= nil then
menu:Tween(frame, { BackgroundColor3 = backgroundColor3 }, tweenInfo2)
backgroundColor3 = nil
end
end)

local function fn41()
textLabel.TextColor3 = v120.get("Accent")
menu:Tween(textLabel, { TextColor3 = fn39(variant) })
arg._onClick()
arg.Clicked:Fire()
end

if not arg._requiresConfirm then
v118.connectClick(arg2.Trove, instance, fn41)
return frame
end
local v121 = nil

local function fn42()
local v122 = v121
if v122 == nil then
return
end
v121 = nil
v122:Destroy()
textLabel.Text = arg.Label
menu:Tween(textLabel, { TextColor3 = fn39(variant) }, tweenInfo)
end

v118.connectClick(arg2.Trove, instance, function()
if v121 == nil then
local v122 = arg2.Trove:Extend()
v121 = v122
menu:Tween(textLabel, { TextColor3 = color2 }, tweenInfo)

v122:Add(task.spawn(function()
for i = v86[155], 1, -1 do
textLabel.Text = string.format("%s (%s)", "Are you sure?", tostring(i))
task.wait(v86[63])
end

fn42()
end))

return
end

fn42()
fn41()
end)

return frame
end

local function createTextButton()
local button = v117.get().Button
local textButton = Instance.new("TextButton")
textButton.BackgroundTransparency = 1
textButton.Size = UDim2.new(1, v86[186], 0, button.RowHeight)
textButton.BorderSizePixel = 0
textButton.Text = ""
textButton.AutoButtonColor = false
local instance = Instance.new(v86[4])
instance.Padding = UDim.new(0, button.Gap)
instance.FillDirection = Enum.FillDirection.Horizontal
instance.HorizontalFlex = Enum.UIFlexAlignment.Fill
instance.SortOrder = Enum.SortOrder.LayoutOrder
instance.VerticalFlex = Enum.UIFlexAlignment.Fill
instance.Parent = textButton
return textButton
end

index2._New = function(arg, arg2, arg3, arg4, arg5)
local obj = setmetatable({
_trove = arg3,
_menu = arg,
Kind = v86[33],
Row = arg2,
Label = arg4.Label or "Button",
Clicked = arg3:Add(v115.new()),
_onClick = arg4.OnClick or function()
end,
_variant = arg4.Variant or "default",
_requiresConfirm = arg4.Confirm == true,
_title = nil,
}, index2)

if arg5 then
arg2:AttachRight(function(parent, arg6)
local v121 = createTextButton()
v121.Parent = parent
createFrame(obj, v121, arg6)
return v121
end, nil, nil, arg3, nil, v86[34])
else
arg2:AttachRight(function(arg6, arg7)
return createFrame(obj, arg6, arg7)
end, nil, nil, arg3, function(parent, arg6)
local v121 = createTextButton()
v121.Parent = parent
createFrame(obj, v121, arg6)
return v121
end, true)
end

return obj
end

index2.SetLabel = function(arg, label)
arg.Label = label
local title = arg._title

if title ~= nil then
title.Text = label
end

return arg
end

index2.SetTooltip = function(arg, arg2)
arg.Row:SetTooltip(arg2)
return arg
end

index2.SetVisible = function(arg, arg2)
arg.Row:SetVisible(arg2)
end

index2.OnClick = function(arg, arg2)
arg._trove:Connect(arg.Clicked, arg2)
return arg
end

index2.Connect = function(arg, arg2, arg3)
arg._trove:Connect(arg2, arg3)
return arg
end

index2.Destroy = function(arg)
arg._trove:Destroy()
end

return index2
end

tbl17.C = function()
local c = tbl17.cache.C

if not c then
local c2 = { c = fn35() }
tbl17.cache.C = c2
c = c2
end

return c.c
end
end
do -- D
local function fn35() tbl17 .r();local l={};local function I(W)local N={};for P,P_21 in W.Keypoints,nil,nil do table.insert(N,{Time=P_21.Time,Value=P_21.Value});end;return N;end;local function W(N)local P={};for a,a_22 in N,nil,nil do table.insert(P,ColorSequenceKeypoint.new(a_22.Time,a_22.Value));end;return ColorSequence.new(P);end;local function N(P)local a=P[1].Value;for e=2,#P,1 do if P[e].Value~=a then return false;end;end;return true;end;local function P(a)if type(a)=="number"then return 1-a;end;return 1;end;l.decodeSolid=function(a,e)if typeof(a)~="Color3"then return nil;end;return{Rgb=a,Alpha=P(e),Stops={}};end;l.encodeSolid=function(a)return a.Rgb,1-a.Alpha;end;l.decodeSequence=function(a,e)if typeof(a)~="ColorSequence"then return nil;end;local c=I(a);if#c==0 then return nil;end;a=P(e);if N(c)then return{Rgb=c[1].Value,Alpha=a,Stops={}};end;return{Rgb=c[1].Value,Alpha=a,Stops=c};end;l.encodeSequence=function(I)local N=I.Stops;if N~=nil and#N>=2 then return W(N),1-I.Alpha;end;return ColorSequence.new(I.Rgb),1-I.Alpha;end;return l;end

tbl17.D = function()
local d = tbl17.cache.D

if not d then
d = { c = fn35() }
tbl17.cache.D = d
end

return d.c
end
end
do -- E
local function fn35() tbl17 .r();local l;l={clone=function(I)local W={};if type(I)=="table"then for N,P in I,nil,nil do if type(P)=="table"then N=P.Value;if typeof(N)=="Color3"then table.insert(W,{Time=math.clamp(tonumber(P.Time)or 0,0,1),Value=N});end;end;end;end;return W;end,sort=function(I,W)table.sort(I,function(N,P)return N.Time<P.Time;end);if W~=nil then for N,P in I,nil,nil do if P==W then return N;end;end;end;return math.max(#I,1);end,ensure=function(I,W)local N=l.clone(I);if#N>=2 then l.sort(N);N[1].Time=0;N[#N].Time=1;return N;end;return{{Time=0,Value=W},{Time=1,Value=W}};end,toSequence=function(I)local W=l.clone(I);if#W==0 then return ColorSequence.new(Color3.new(1,1,1));end;l.sort(W);local I_23,N,P={},W[1],W[#W];if N.Time>0 then table.insert(I_23,ColorSequenceKeypoint.new(0,N.Value));end;for a,a_24 in W,nil,nil do N=math.clamp(a_24.Time,0,1);table.insert(I_23,ColorSequenceKeypoint.new(if#I_23>0 then(math.max(N,I_23[#I_23].Time))else N,a_24.Value));end;if I_23[#I_23].Time<1 then table.insert(I_23,ColorSequenceKeypoint.new(1,P.Value));end;return ColorSequence.new(I_23);end};return l;end

tbl17.E = function()
local e = tbl17.cache.E

if not e then
e = { c = fn35() }
tbl17.cache.E = e
end

return e.c
end
end
do -- F
local function fn35()
tbl17.A()

return {
addGlow = function(arg, parent, arg2)
local amount = arg2.Amount or v86[175]
local dampingFactor = arg2.DampingFactor or 0.4

for i = 1, amount do
local uiStroke = Instance.new("UIStroke")
uiStroke.LineJoinMode = Enum.LineJoinMode.Round
uiStroke.BorderOffset = UDim.new(0, i)
uiStroke.Transparency = 1 - (v86[63] - i / (amount + dampingFactor)) * (v86[63] - dampingFactor)
arg:Bind(uiStroke, "Color", "Outline")
uiStroke.Parent = parent
end
end,
bindSurfaceGradient = function(arg, arg2, arg3)
local n = #arg3
local v115 = table.clone(arg3)
table.insert(v115, arg3[n])
local tbl18 = {}

for i = 1, n do
tbl18[i] = (i - 1) / (n - 1) * v86[81]
end

tbl18[n + 1] = 1
arg:BindGradient(arg2, v115, tbl18)
end,
}
end

tbl17.F = function()
local f = tbl17.cache.F

if not f then
local f2 = { c = fn35() }
tbl17.cache.F = f2
f = f2
end

return f.c
end
end
do -- G
local function fn35()
tbl17.k()
local v115 = tbl17.F()
tbl17.r()
local v116 = tbl17.A()
local v117 = tbl17.w()
local index2 = {}
index2.__index = index2

local function fn36(arg)
local root = arg.Root
local v118, v119 = arg._place(arg._trigger, root)
local v120 = v117.absoluteToLayerOffset(arg._layer, Vector2.new(v118, v119))
local absoluteSize = root.AbsoluteSize

if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
local absoluteSize2 = arg._layer.AbsoluteSize
absoluteSize = Vector2.new(root.Size.X.Scale * absoluteSize2.X + root.Size.X.Offset, root.Size.Y.Scale * absoluteSize2.Y + root.Size.Y.Offset)
end

local anchorPoint = root.AnchorPoint
local v121, v122 = v117.clampOffsetToViewport(v120.X - absoluteSize.X * anchorPoint.X, v120.Y - absoluteSize.Y * anchorPoint.Y, absoluteSize)
local v123 = v117.onScreenKeyboardTop()
local n

if v123 == nil then
n = v122
else
n = math.clamp(v122, v86[186], math.max(0, v123 - absoluteSize.Y))
end

return math.round(v121 + absoluteSize.X * anchorPoint.X), math.round(n + absoluteSize.Y * anchorPoint.Y)
end

local function fn37(arg, arg2)
arg._geometryTrove:Clean()
arg._onToggle(arg2)
local menu = arg._menu
local root = arg.Root

if not arg2 then
local v118, v119 = fn36(arg)
menu:Tween(root, { Position = UDim2.fromOffset(v118, v119 - 15) })
menu:FadeCanvasGroup(root, false, arg._fadeState)
return
end

v117.connectOnScreenKeyboard(arg._geometryTrove, function()
local updateViewport = arg._updateViewport
if updateViewport ~= nil then
updateViewport()
return
end
arg:Reposition()
end)

local v118, v119 = fn36(arg)
root.Position = UDim2.fromOffset(v118, v119 - 15)

arg._geometryTrove:Add(task.defer(function()
if not arg.Entry.Open or root.Parent == nil then
return
end
local v120, v121 = fn36(arg)
root.Position = UDim2.fromOffset(v120, v121 - 15)
menu:FadeCanvasGroup(root, true, arg._fadeState)
menu:Tween(root, { Position = UDim2.fromOffset(v120, v121) })
end))
end

index2.new = function(arg, arg2, arg3)
local v118 = arg2:Extend()
local v119 = v116.newBatch(v118)
local canvasGroup = Instance.new("CanvasGroup")
canvasGroup.Visible = false
canvasGroup.GroupTransparency = 1
canvasGroup.BorderSizePixel = 0
canvasGroup.AnchorPoint = arg3.AnchorPoint or Vector2.zero
canvasGroup.Size = arg3.Size
canvasGroup.AutomaticSize = arg3.AutomaticSize or Enum.AutomaticSize.None

if arg3.FlatBackground then
canvasGroup.BackgroundTransparency = v86[6]
v119:Bind(canvasGroup, "BackgroundColor3", v86[168])
else
canvasGroup.BackgroundTransparency = 1
local frame = Instance.new("Frame")
frame.Size = UDim2.fromScale(v86[63], 1)
frame.BorderSizePixel = 0
frame.ZIndex = v86[186]
frame.BackgroundColor3 = Color3.fromRGB(v86[108], v86[108], 255)
frame.Parent = canvasGroup
local uiGradient = Instance.new("UIGradient")
uiGradient.Rotation = 90
v115.bindSurfaceGradient(v119, uiGradient, { "GradientMid", "GradientDark" })
uiGradient.Parent = frame
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, arg3.CornerRadius or 5)
uiCorner.Parent = frame
end

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(v86[186], arg3.CornerRadius or 5)
uiCorner.Parent = canvasGroup
local uiStroke = Instance.new("UIStroke")
v119:Bind(uiStroke, "Color", "Outline")
uiStroke.Parent = canvasGroup

if arg3.Glow then
v115.addGlow(v119, canvasGroup, { Amount = 5, DampingFactor = 0.6 })
end

local overlayLayer = arg:GetOverlayLayer()
canvasGroup.Parent = overlayLayer
v118:Add(canvasGroup)
local v120 = nil

local v121 = arg:RegisterOverlay(canvasGroup, {
Triggers = { arg3.Trigger },
ParentEntry = arg3.ParentEntry,
OnToggle = function(arg4)
local v121 = v120

if v121 ~= nil then
fn37(v121, arg4)
end
end,
})

v118:Add({ Destroy = function()
arg:UnregisterOverlay(v121)
end })

local obj = setmetatable({
Trove = v118,
_menu = arg,
_layer = overlayLayer,
Batch = v119,
_trigger = arg3.Trigger,
_place = arg3.Place,
_onToggle = arg3.OnToggle or function()
end,
_fadeState = { Tweening = v86[153] },
_geometryTrove = v118:Extend(),
_updateViewport = nil,
Root = canvasGroup,
Entry = v121,
}, index2)

v120 = obj

v118:Connect(arg3.Trigger:GetPropertyChangedSignal("AbsolutePosition"), function()
obj:Reposition()
end)

v117.connectCurrentCameraViewport(v118, function()
obj:Reposition()
end)

return obj
end

index2.RealizeCtx = function(arg)
return { Menu = arg._menu, Trove = arg.Trove, Batch = arg.Batch, ParentOverlay = arg.Entry }
end

index2.placeBelow = function(arg, arg2)
return function(arg3)
local absolutePosition = arg3.AbsolutePosition
return math.round(absolutePosition.X) + arg, math.round(absolutePosition.Y + arg3.AbsoluteSize.Y + arg2)
end
end

index2.AttachScrollingList = function(arg, arg2, arg3)
local root = arg.Root
local n = 12
local n33 = 12
local n34 = 12

if arg3 ~= nil then
n = arg3.Top
n33 = arg3.Bottom
n34 = arg3.Side
end

local instance = Instance.new(v86[64])
instance.Active = v86[34]
instance.Size = UDim2.fromScale(1, 1)
instance.BorderSizePixel = 0
instance.BackgroundTransparency = 1
instance.AutomaticCanvasSize = Enum.AutomaticSize.Y
instance.CanvasSize = UDim2.fromOffset(0, 0)
instance.ScrollBarImageTransparency = 0.35
instance.ScrollBarThickness = v86[186]
instance.Selectable = false
arg.Batch:Bind(instance, "ScrollBarImageColor3", "Accent")
instance.Parent = root
local instance2 = Instance.new(v86[128])
instance2.Position = UDim2.fromOffset(n34, n)
instance2.Size = UDim2.new(1, -n34 * 2, 0, 0)
instance2.AutomaticSize = Enum.AutomaticSize.Y
instance2.BorderSizePixel = 0
instance2.BackgroundTransparency = v86[63]
instance2.Parent = instance
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, v86[12])
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = instance2
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingBottom = UDim.new(0, n33)
uiPadding.Parent = instance2
local v118 = nil

local function updateViewport()
local y = v118 and v118.Y or v86[78]
local v119 = v117.onScreenKeyboardTop()
local n35

if v119 == nil then
n35 = y
else
n35 = math.min(y, v119)
end

local n36 = uiListLayout.AbsoluteContentSize.Y + n + n33
local n37 = math.min(n36, math.max(80, n35 - v86[13]))
root.Size = UDim2.fromOffset(arg2, n37)
local scrollBarThickness = v86[186]

if n36 > n37 + 0.5 then
scrollBarThickness = 4
end

instance.ScrollBarThickness = scrollBarThickness
arg:Reposition()
end

arg._updateViewport = updateViewport
arg.Trove:Connect(uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), updateViewport)

v117.connectCurrentCameraViewport(arg.Trove, function(arg4)
v118 = arg4
updateViewport()
end)

return instance, instance2
end

index2.IsOpen = function(arg)
return arg.Entry.Open
end

index2.Toggle = function(arg)
arg._menu:ToggleOverlay(arg.Entry)
end

index2.SetOpen = function(arg, arg2)
arg._menu:SetOverlayOpen(arg.Entry, arg2)
end

index2.Reposition = function(arg)
if not arg.Entry.Open then
return
end
local v118, v119 = fn36(arg)
if arg._fadeState.Tweening then
arg._menu:Tween(arg.Root, { Position = UDim2.fromOffset(v118, v119) })
return
end
arg.Root.Position = UDim2.fromOffset(v118, v119)
end

index2.Destroy = function(arg)
arg.Trove:Destroy()
end

return index2
end

tbl17.G = function()
local g = tbl17.cache.G

if not g then
g = { c = fn35() }
tbl17.cache.G = g
end

return g.c
end
end
do -- H
local function fn35()
local v115 = tbl17.g()
tbl17.k()
tbl17.r()
local v116 = tbl17.s()
local v117 = tbl17.v()
local v118 = tbl17.u()
local v119 = tbl17.x()
local v120 = tbl17.G()
tbl17.B()
local v121 = tbl17.A()
local v122 = tbl17.w()
local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local color = Color3.fromRGB(v86[108], v86[108], v86[108])
local index2 = {}
index2.__index = index2

local function fn36(arg)
local tbl18 = {}
local v123 = v86[165]

if type(arg) == v123 then
tbl18[arg] = true
else
local v124 = v86[68]

if type(arg) == v124 then
for k, v125 in arg, nil, nil do
local v126 = v86[165]

if type(k) == v126 and v125 == true then
tbl18[k] = true
else
local v127 = v86[95]

if type(k) == v127 and type(v125) == "string" then
tbl18[v125] = v86[34]
end
end
end
end
end

return tbl18
end

local function fn37(arg)
table.clear(arg._indexByName)

for k, v123 in arg.Options, nil, nil do
arg._indexByName[v123] = k
end
end

local function fn38(arg, arg2)
return arg._labelByValue[arg2] or arg2
end

local function fn39(arg)
local value = arg.Value
if type(value) == "string" then
return fn38(arg, value)
end

if type(value) == "table" then
local tbl18 = {}

for _, v123 in arg.Options, nil, nil do
if value[v123] then
table.insert(tbl18, fn38(arg, v123))
end
end

if v86[186] < #tbl18 then
return table.concat(tbl18, ", ")
end
end

return "Select"
end

local function fn40(arg)
local rt = arg._rt

if rt ~= nil then
rt.ValueLabel.Text = fn39(arg)
end
end

local function fn41(arg, arg2)
local value = arg.Value
if type(value) == "table" then
return value[arg2] == true
end
return value == arg2
end

local function fn42(arg, arg2, arg3, arg4)
local Unselected = v121.get("Unselected")
local imageTransparency = 1

if arg3 then
Unselected = v121.get(v86[174])
imageTransparency = 0
end

arg2.Tick.ImageColor3 = v121.get("TextColor")

if arg4 then
arg2.Button.TextColor3 = Unselected
arg2.Tick.ImageTransparency = imageTransparency
return
end

arg._menu:Tween(arg2.Button, { TextColor3 = Unselected })
arg._menu:Tween(arg2.Tick, { ImageTransparency = imageTransparency })
end

local function fn43(arg, arg2)
local panel = arg._panel
if panel == nil or not panel.Popup:IsOpen() then
return
end

for k, v123 in panel.Rows, nil, nil do
local v124 = arg.Options[k]
fn42(arg, v123, v124 ~= nil and fn41(arg, v124), arg2)
end
end

local function fn44(arg, arg2)
local panel = arg._panel
if panel == nil then
return
end
local str7 = arg2:lower()

for _, v123 in panel.Rows, nil, nil do
v123.Button.Visible = v123.Button.Text:lower():find(str7, 1, true) ~= nil
end

panel.Scroll.CanvasPosition = Vector2.zero
end

local function fn45(arg, arg2)
local v123 = arg.Options[arg2]
if v123 == nil then
return
end

if arg.Multi then
local tbl18 = {}
local value = arg.Value

if type(value) == "table" then
for k in value, nil, nil do
tbl18[k] = true
end
end

if tbl18[v123] then
tbl18[v123] = nil
else
tbl18[v123] = true
end

arg:Set(tbl18)
return
end

arg:Set(v123)
local panel = arg._panel

if arg.CloseOnSelect and panel ~= nil then
panel.Popup:SetOpen(v86[153])
end
end

local function fn46(arg, arg2, layoutOrder)
local listRowHeight = v117.get().Row.ListRowHeight
local textButton = Instance.new("TextButton")
textButton.AutoButtonColor = false
textButton.BackgroundTransparency = v86[63]
textButton.TextColor3 = v121.get(v86[96])
textButton.Text = ""
textButton.Size = UDim2.new(1, 0, v86[186], listRowHeight)
textButton.ClipsDescendants = v86[34]
textButton.TextXAlignment = Enum.TextXAlignment.Left
textButton.BorderSizePixel = 0
textButton.TextSize = v86[13]
textButton.FontFace = arg._menu.Fonts.Main
textButton.LayoutOrder = layoutOrder
textButton.Parent = arg2.Scroll
local instance = Instance.new(v86[113])
instance.PaddingTop = UDim.new(0, 5)
instance.PaddingBottom = UDim.new(0, 5)
instance.PaddingRight = UDim.new(0, 5)
instance.PaddingLeft = UDim.new(0, 29)
instance.Parent = textButton
local imageLabel = Instance.new("ImageLabel")
imageLabel.Image = "rbxassetid://73347151382921"
imageLabel.ImageColor3 = v121.get(v86[174])
imageLabel.ImageTransparency = 1
imageLabel.BackgroundTransparency = 1
imageLabel.AnchorPoint = Vector2.new(0, 0.5)
imageLabel.Position = UDim2.new(0, -22, 0.5, 0)
imageLabel.Size = UDim2.fromOffset(14, 14)
imageLabel.BorderSizePixel = 0
imageLabel.Parent = textButton

v119.connectClick(arg._trove, textButton, function()
if arg2.Popup:IsOpen() then
fn45(arg, layoutOrder)
end
end)

return { Button = textButton, Tick = imageLabel }
end

local function fn47(arg)
local listRowHeight = v117.get().Row.ListRowHeight
local n = #arg.Rows
local scroll = arg.Scroll
scroll.AutomaticCanvasSize = Enum.AutomaticSize.None
scroll.CanvasSize = UDim2.fromOffset(0, n * listRowHeight + v86[122])

if n >= 10 then
scroll.Size = UDim2.new(v86[63], -1, 0, math.min(v86[162], n) * listRowHeight + 7)
scroll.AutomaticSize = Enum.AutomaticSize.None
else
scroll.Size = UDim2.new(1, -1, 0, v86[186])
scroll.AutomaticSize = Enum.AutomaticSize.Y
end
end

local function fn48(arg)
local panel = arg._panel
if panel == nil then
return
end
local rows = panel.Rows
local options = arg.Options

for k, v123 in options, nil, nil do
local v124 = rows[k]

if v124 == nil then
v124 = fn46(arg, panel, k)
rows[k] = v124
end

local v125 = fn38(arg, v123)

if v124.Button.Text ~= v125 then
v124.Button.Text = v125
end

if not v124.Button.Visible then
v124.Button.Visible = true
end
end

for i = #rows, #options + 1, -v86[63] do
rows[i].Button:Destroy()
rows[i] = nil
end

fn47(panel)
panel.RepositionTrove:Clean()

panel.RepositionTrove:Add(task.defer(function()
panel.Popup:Reposition()
end))
end

local function fn49(arg, arg2)
local listRowHeight = v117.get().Row.ListRowHeight
local menu = arg._menu
local root = arg2.Popup.Root
local instance = Instance.new(v86[128])
instance.BackgroundColor3 = v121.get(v86[168])
instance.BorderSizePixel = 0
instance.Size = UDim2.new(1, 0, 0, listRowHeight)
instance.ClipsDescendants = true
instance.Parent = root
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(v86[186], v86[175])
uiCorner.Parent = instance
local uiStroke = Instance.new("UIStroke")
uiStroke.Color = v121.get("Outline")
uiStroke.Parent = instance
local textBox = Instance.new("TextBox")
textBox.PlaceholderText = v86[190]
textBox.PlaceholderColor3 = v121.get("Unselected")
textBox.FontFace = menu.Fonts.Main
textBox.TextColor3 = v121.get(v86[174])
textBox.Text = ""
textBox.AnchorPoint = Vector2.new(0, 0.5)
textBox.Position = UDim2.new(v86[186], v86[54], 0.5, 0)
textBox.Size = UDim2.new(1, -12, 1, 0)
textBox.BackgroundTransparency = 1
textBox.BorderSizePixel = 0
textBox.TextSize = 14
textBox.TextXAlignment = Enum.TextXAlignment.Left
textBox.ClearTextOnFocus = true
textBox.Active = v86[34]
textBox.Parent = instance
arg2.SearchInput = textBox
arg2.Scroll.Position = UDim2.fromOffset(v86[186], v86[192])

arg._trove:Connect(textBox:GetPropertyChangedSignal("Text"), function()
fn44(arg, textBox.Text)
end)

arg._trove:Connect(textBox.Focused, function()
menu:Tween(textBox, { TextColor3 = v121.get("Accent") })
end)

arg._trove:Connect(textBox.FocusLost, function()
menu:Tween(textBox, { TextColor3 = v121.get("TextColor") })
end)
end

local function fn50(arg)
local panel = arg._panel
if panel ~= nil then
return panel
end
local rt = arg._rt
if rt == nil then
return nil
end
local panel2 = nil

local v123 = v120.new(arg._menu, arg._trove, {
Trigger = rt.Pill,
Size = UDim2.fromOffset(80, 0),
AutomaticSize = Enum.AutomaticSize.Y,
AnchorPoint = Vector2.new(1, 0),
Glow = v86[34],
ParentEntry = arg._parentOverlay,
Place = function(arg2, arg3)
local absolutePosition = arg2.AbsolutePosition
local n = math.floor(arg2.AbsoluteSize.X + 2 + 0.5)
local n33 = math.max(n, 80)
local n34 = v86[186]

for _, v123 in panel2.Rows, nil, nil do
if v123.Button.Visible then
n34 = math.max(n34, v123.Button.TextBounds.X)
end
end

arg3.Size = UDim2.fromOffset(math.max(n33, math.ceil(n34) + 40), v86[186])
return math.floor(absolutePosition.X + 0.5) + n, (math.floor(absolutePosition.Y + arg2.AbsoluteSize.Y + 4))
end,
OnToggle = function(arg2)
arg._menu:Tween(rt.Arrow, { Rotation = arg2 and 180 or 0 })
panel2.FocusTrove:Clean()

if not arg2 then
local searchInput = panel2.SearchInput

if searchInput ~= nil then
searchInput:ReleaseFocus()
end

return
end

local getOptions = arg._getOptions

if getOptions ~= nil then
arg:SetOptions(getOptions())
end

fn43(arg, true)
panel2.Scroll.CanvasPosition = Vector2.zero
local searchInput = panel2.SearchInput

if searchInput ~= nil then
searchInput.Text = ""
fn44(arg, "")

panel2.FocusTrove:Add(task.defer(function()
if panel2.Popup:IsOpen() then
searchInput:CaptureFocus()
end

if not flag2 then
return
end
end))
end
end,
})

local y = v122.currentViewportSize().Y
local n = math.floor(y * 0.6)

if v118.IsMobile() then
n = math.floor(y * 0.5)
end

local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Active = true
scrollingFrame.ScrollBarImageTransparency = v86[101]
scrollingFrame.ScrollBarThickness = v86[26]
scrollingFrame.Size = UDim2.new(1, -v86[63], 0, 0)
scrollingFrame.BorderSizePixel = 0
scrollingFrame.BackgroundTransparency = v86[63]
scrollingFrame.AutomaticSize = Enum.AutomaticSize.Y
scrollingFrame.CanvasSize = UDim2.fromOffset(0, v86[186])
scrollingFrame.Selectable = v86[153]
scrollingFrame.ScrollBarImageColor3 = v121.get("Accent")
scrollingFrame.Parent = v123.Root
local instance = Instance.new(v86[176])
instance.MaxSize = Vector2.new(math.huge, n)
instance.Parent = scrollingFrame
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingBottom = UDim.new(0, v86[122])
uiPadding.Parent = scrollingFrame
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = scrollingFrame

panel2 = {
Popup = v123,
Scroll = scrollingFrame,
SearchInput = nil,
Rows = {},
RepositionTrove = v123.Trove:Extend(),
FocusTrove = v123.Trove:Extend(),
}

arg._panel = panel2

if arg.Search then
fn49(arg, panel2)
end

fn48(arg)
return panel2
end

local function createTextButton(arg, parent, arg2)
local menu = arg._menu
local v123 = v117.get()
local inline = arg.Inline
local textButton = Instance.new("TextButton")
textButton.AutoButtonColor = false
textButton.Text = ""
textButton.AnchorPoint = Vector2.new(1, v86[101])
textButton.Position = UDim2.new(1, -v86[63], 0.5, 0)
textButton.BorderSizePixel = 0
textButton.BackgroundColor3 = color

if inline then
textButton.Size = UDim2.fromOffset(0, v123.Row.ControlHeight)
textButton.ClipsDescendants = true
textButton.AutomaticSize = Enum.AutomaticSize.X
else
textButton.Size = UDim2.fromOffset(137, 24)
end

textButton.Parent = parent
local uiGradient = Instance.new("UIGradient")
uiGradient.Rotation = v86[45]
arg2.Batch:BindGradient(uiGradient, { "GradientMid", "GradientDark" })
uiGradient.Parent = textButton
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, v86[175])
uiCorner.Parent = textButton

if inline then
local uiSizeConstraint = Instance.new("UISizeConstraint")
uiSizeConstraint.MaxSize = Vector2.new(arg.MaxWidth, v123.Row.ControlHeight)
uiSizeConstraint.Parent = textButton
end

local uiStroke = Instance.new("UIStroke")

if not inline then
uiStroke.BorderOffset = UDim.new(0, -1)
end

uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
arg2.Batch:Bind(uiStroke, "Color", "Outline")
uiStroke.Parent = textButton
local imageLabel = Instance.new("ImageLabel")
imageLabel.Image = "rbxassetid://84796267467531"
imageLabel.BackgroundTransparency = v86[63]
imageLabel.Size = UDim2.fromOffset(9, 5)
imageLabel.BorderSizePixel = v86[186]

if inline then
imageLabel.LayoutOrder = 1
else
imageLabel.AnchorPoint = Vector2.new(1, 0.5)
imageLabel.Position = UDim2.new(1, -8, 0.5, 0)
end

arg2.Batch:Bind(imageLabel, "ImageColor3", "Unselected")
imageLabel.Parent = textButton
local instance = Instance.new(v86[135])
instance.Text = fn39(arg)
instance.AnchorPoint = Vector2.new(0, v86[101])
instance.Position = UDim2.new(0, 5, v86[101], 0)
instance.BackgroundTransparency = 1
instance.BorderSizePixel = 0
instance.TextSize = v86[13]
instance.TextTruncate = Enum.TextTruncate.AtEnd

if inline then
instance.LayoutOrder = -1
instance.FontFace = menu.Fonts.Main
instance.AutomaticSize = Enum.AutomaticSize.XY
else
instance.ClipsDescendants = true
instance.FontFace = v116.Medium
instance.Size = UDim2.new(1, -25, 0, 0)
instance.TextXAlignment = Enum.TextXAlignment.Left
instance.AutomaticSize = Enum.AutomaticSize.Y
end

arg2.Batch:Bind(instance, "TextColor3", "TextColor")
instance.Parent = textButton

if inline then
local instance2 = Instance.new(v86[113])
instance2.PaddingBottom = UDim.new(0, 2)
instance2.Parent = instance
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
uiListLayout.FillDirection = Enum.FillDirection.Horizontal
uiListLayout.Padding = UDim.new(0, 6)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = textButton
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingTop = UDim.new(v86[186], 2)
uiPadding.PaddingRight = UDim.new(0, 6)
uiPadding.PaddingLeft = UDim.new(v86[186], v86[54])
uiPadding.Parent = textButton
local v124 = menu:DragTweenInfo()

arg2.Trove:Connect(instance:GetPropertyChangedSignal("Text"), function()
local controlHeight = v123.Row.ControlHeight
menu:Tween(textButton, { Size = UDim2.fromOffset(math.min(instance.AbsoluteSize.X, arg.MaxWidth), controlHeight) }, v124)
end)

arg2.Trove:Add(task.defer(function()
if instance.Parent ~= nil then
local controlHeight = v123.Row.ControlHeight
textButton.Size = UDim2.fromOffset(math.min(instance.AbsoluteSize.X + v86[144], arg.MaxWidth + 22), controlHeight)
end
end))
end

arg._rt = { Pill = textButton, ValueLabel = instance, Arrow = imageLabel }

if arg._parentOverlay == nil then
arg._parentOverlay = arg2.ParentOverlay
end

v119.connectClick(arg2.Trove, textButton, function()
if #arg.Options == 0 and arg._getOptions == nil then
return
end
local v124 = fn50(arg)

if v124 ~= nil then
v124.Popup:Toggle()
end
end)

local v124 = nil

v119.connectPress(arg2.Trove, textButton, function()
local backgroundColor3 = textButton.BackgroundColor3
v124 = backgroundColor3
menu:Tween(textButton, { BackgroundColor3 = Color3.new(backgroundColor3.R * v86[105], backgroundColor3.G * 0.85, backgroundColor3.B * 0.85) }, tweenInfo)
end, function()
if v124 ~= nil then
menu:Tween(textButton, { BackgroundColor3 = v124 }, tweenInfo)
v124 = nil
end
end)

return textButton
end

local function fn51(arg, arg2, arg3, arg4, arg5, arg6, arg7)
local obj = setmetatable({
_trove = arg3,
_menu = arg,
Kind = "Dropdown",
Row = arg2,
Multi = arg5,
Search = arg4.Search == true,
Inline = arg4.Inline == true,
CloseOnSelect = arg4.CloseOnSelect == true,
MaxWidth = arg4.MaxWidth or 300,
Options = table.clone(arg4.Options or {}),
_labelByValue = arg4.Labels or {},
Value = arg6,
Changed = arg3:Add(v115.new()),
ValueChanged = arg3:Add(v115.new()),
_onChanged = arg7,
_getOptions = arg4.GetOptions,
_isOptionsPublished = arg4.Options ~= nil or arg4.GetOptions == nil,
_indexByName = {},
_rt = nil,
_panel = nil,
_parentOverlay = nil,
}, index2)

fn37(obj)
local n = 138

if obj.Inline then
n = nil
end

arg2:AttachRight(function(arg8, arg9)
return createTextButton(obj, arg8, arg9)
end, n, nil, arg3)

return obj
end

index2._New = function(arg, arg2, arg3, arg4)
local options = arg4.Options or {}
local default = arg4.Default

if not (default ~= nil and (not (arg4.Options ~= nil or arg4.GetOptions == nil) or table.find(options, default) ~= nil)) then
default = options[1]
end

local onChanged = arg4.OnChanged

local function fn52()
end

if onChanged ~= nil then
fn52 = function(arg5)
onChanged(arg5)
end
end

return (fn51(arg, arg2, arg3, arg4, false, default, fn52))
end

index2._NewMulti = function(arg, arg2, arg3, arg4)
local onChanged = arg4.OnChanged

local function fn52()
end

if onChanged ~= nil then
fn52 = function(arg5)
onChanged(arg5)
end
end

return (fn51(arg, arg2, arg3, arg4, v86[34], fn36(arg4.Default), fn52))
end

local function fn52(arg, arg2)
for k in arg, nil, nil do
if not arg2[k] then
return false
end
end

for k in arg2, nil, nil do
if not arg[k] then
return false
end
end

return true
end

index2.Set = function(I,W,N)if I.Multi then local P= fn36 (W);local a=I.Value;if type(a)=="table"and( fn52 (P,a))then return;end;I.Value=P; fn43 (I,N==true); fn40 (I);I.ValueChanged:Fire(I.Value);if not N then I._onChanged(I.Value);I.Changed:Fire(I.Value);end;return;end;local P=if type(W)=="string"and(not I._isOptionsPublished or I._indexByName[W]~=nil)then W else nil;local a=I._isOptionsPublished and W~=nil and P==nil;if P==I.Value and not a then return;end;W=I.Value;I.Value=P;a=I._panel;if a~=nil and(a.Popup:IsOpen())then local e=N==true;local c=type(W)=="string"and I._indexByName[W]or nil;if c~=nil and a.Rows[c]~=nil then  fn42 (I,a.Rows[c],false,e);end;c=P~=nil and I._indexByName[P]or nil;if c~=nil and a.Rows[c]~=nil then  fn42 (I,a.Rows[c],true,e);end;end; fn40 (I);I.ValueChanged:Fire(I.Value);if not N then I._onChanged(I.Value);I.Changed:Fire(I.Value);end;end

index2.SetOptions = function(arg, arg2)
local tbl18 = arg2 or {}
local options = arg.Options
local isOptionsPublished = arg._isOptionsPublished
arg._isOptionsPublished = true

if isOptionsPublished and #tbl18 == #options then
local flag19 = true

for k, v123 in tbl18, nil, nil do
if options[k] ~= v123 then
flag19 = v86[153]
break
end
end

if flag19 then
return
end
end

local value = arg.Value
arg.Options = table.clone(tbl18)
fn37(arg)
fn48(arg)

if arg.Multi then
fn43(arg, true)
fn40(arg)
arg.ValueChanged:Fire(arg.Value)
return
end

local value2 = arg.Value

if type(value2) ~= "string" or arg._indexByName[value2] == nil then
arg.Value = nil
end

fn43(arg, true)
fn40(arg)
arg.ValueChanged:Fire(arg.Value)

if value ~= arg.Value then
arg._onChanged(arg.Value)
arg.Changed:Fire(arg.Value)
end
end

index2.Add = function(arg, arg2)
local v123 = v86[165]
if type(arg2) ~= v123 or arg._indexByName[arg2] ~= nil then
return
end
local v124 = table.clone(arg.Options)
table.insert(v124, arg2)
arg:SetOptions(v124)
end

index2.Remove = function(arg, arg2)
local v123 = arg._indexByName[arg2]
if v123 == nil then
return
end
local v124 = table.clone(arg.Options)
table.remove(v124, v123)
arg:SetOptions(v124)
end

index2.SetOpen = function(arg, arg2)
local v123 = fn50(arg)

if v123 ~= nil then
v123.Popup:SetOpen(arg2)
end
end

index2.SetLabel = function(arg, arg2)
arg.Row:SetLabel(arg2)
return arg
end

index2.SetTooltip = function(arg, arg2)
arg.Row:SetTooltip(arg2)
return arg
end

index2.SetVisible = function(arg, arg2)
arg.Row:SetVisible(arg2)
end

index2.OnChanged = function(arg, arg2)
arg._trove:Connect(arg.Changed, arg2)
return arg
end

index2.Connect = function(arg, arg2, arg3)
arg._trove:Connect(arg2, arg3)
return arg
end

index2.Destroy = function(arg)
arg._trove:Destroy()
end

return index2
end

tbl17.H = function()
local h = tbl17.cache.H

if not h then
h = { c = fn35() }
tbl17.cache.H = h
end

return h.c
end
end
do -- I
local function fn35()
tbl17.r()
local v115 = tbl17.s()
tbl17.B()
local v116 = tbl17.w()
local color = Color3.fromRGB(v86[108], 255, 255)
local udim2 = UDim2.fromOffset(14, 14)
local udim22 = UDim2.fromOffset(18, 18)

return {
buildTrack = function(parent, arg, arg2)
local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(0, 0.5)
frame.Position = UDim2.fromScale(0, 0.5)
frame.Size = UDim2.new(1, -arg2 - 11, 0, 2)
frame.BorderSizePixel = 0
frame.BackgroundColor3 = color
frame.Parent = parent
local uiGradient = Instance.new("UIGradient")
arg.Batch:BindGradient(uiGradient, { "GradientDark", v86[187] })
uiGradient.Parent = frame
local uiStroke = Instance.new("UIStroke")
arg.Batch:Bind(uiStroke, "Color", "Outline")
uiStroke.Parent = frame
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(v86[63], 0)
uiCorner.Parent = frame
local instance = Instance.new(v86[128])
instance.AnchorPoint = Vector2.new(0.5, 0.5)
instance.Position = UDim2.fromScale(0.5, 0.5)
instance.Size = UDim2.new(1, v86[186], 0, 44)
instance.BackgroundTransparency = 1
instance.BorderSizePixel = v86[186]
instance.Active = true
instance.ZIndex = 0
instance.Parent = frame
return frame, instance
end,
buildThumb = function(parent)
local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.fromScale(v86[186], 0.5)
frame.Size = udim2
frame.BorderSizePixel = v86[186]
frame.BackgroundColor3 = color
frame.ZIndex = 2
frame.Parent = parent
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(1, 0)
uiCorner.Parent = frame
return frame
end,
setThumbPressed = function(arg, arg2, arg3)
arg:Tween(arg2, { Size = arg3 and udim22 or udim2 })
end,
valueAt = function(arg, arg2, arg3, arg4)
return (arg4 - arg3) * (arg2 - arg.AbsolutePosition.X) / arg.AbsoluteSize.X + arg3
end,
newTouchBubble = function(arg, arg2)
local v117 = nil
local v118 = nil

local function fn36()
local v119 = v117
local v120 = v118
if v119 ~= nil and v120 ~= nil then
return v119, v120
end
local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(v86[101], 0.5)
frame.Size = UDim2.fromOffset(42, 28)
frame.BorderSizePixel = 0
frame.Visible = false
frame.ZIndex = 20
arg2.Batch:Bind(frame, v86[5], "Background")
arg2.Trove:Add(frame)
frame.Parent = arg:GetOverlayLayer()
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 5)
uiCorner.Parent = frame
local uiStroke = Instance.new("UIStroke")
arg2.Batch:Bind(uiStroke, "Color", "Outline")
uiStroke.Parent = frame
local instance = Instance.new(v86[135])
instance.FontFace = v115.SemiBold
instance.BackgroundTransparency = 1
instance.Size = UDim2.fromScale(1, 1)
instance.BorderSizePixel = v86[186]
instance.TextSize = 14
instance.ZIndex = 21
arg2.Batch:Bind(instance, "TextColor3", "TextColor")
instance.Parent = frame
v117 = frame
v118 = instance
return frame, instance
end

return {
Show = function(arg3, text)
local v119, v120 = fn36()
v120.Text = text
v119.Size = UDim2.fromOffset(math.max(42, #text * 8 + 16), v86[25])
local n = arg3.AbsolutePosition + arg3.AbsoluteSize / 2
local v121 = v116.absoluteToLayerOffset(arg:GetOverlayLayer(), n)
v119.Position = UDim2.fromOffset(v121.X, v121.Y - 40)
v119.Visible = v86[34]
end,
Hide = function()
if v117 ~= nil then
v117.Visible = false
end
end,
}
end,
}
end

tbl17.I = function()
local i = tbl17.cache.I

if not i then
i = { c = fn35() }
tbl17.cache.I = i
end

return i.c
end
end
do -- J
local function fn35()
local v115 = tbl17.g()
tbl17.k()
tbl17.r()
local v116 = tbl17.s()
local v117 = tbl17.v()
local v118 = tbl17.x()
tbl17.B()
local v119 = tbl17.I()
local v120 = tbl17.w()
local index2 = {}
index2.__index = index2

local function fn36(arg, arg2, arg3)
local min = arg.Min
local max = arg.Max
local n = math.clamp(v120.round(arg2, arg.Step), min, max)
local n33 = math.clamp(v120.round(arg3, arg.Step), arg.Min, arg.Max)

if not (n33 < n) then
local v121 = n33
n33 = n
n = v121
end

return n33, n
end

local function fn37(arg, arg2)
if arg.Max == arg.Min then
return v86[186]
end
return (arg2 - arg.Min) / (arg.Max - arg.Min)
end

local function fn38(arg, arg2)
local v121 = fn37(arg, arg.Value.Min)
local v122 = fn37(arg, arg.Value.Max)
arg2.MinThumb.Position = UDim2.fromScale(v121, v86[101])
arg2.MaxThumb.Position = UDim2.fromScale(v122, v86[101])
local udim2 = UDim2.fromScale(v121, 0)
local udim22 = UDim2.fromScale(v122 - v121, v86[63])

if arg._isDragging then
arg2.Accent.Position = udim2
arg2.Accent.Size = udim22
else
arg._menu:Tween(arg2.Accent, { Position = udim2, Size = udim22 }, arg._menu:DragTweenInfo())
end

local v123 = tostring
local max = arg.Value.Max
arg2.ValueLabel.Text = ("%s - %s"):format(tostring(arg.Value.Min), v123(max))
end

local function fn39(arg, parent, arg2, arg3)
local menu = arg._menu
local controlHeight = v117.get().Row.ControlHeight
local v121, v122 = v119.buildTrack(parent, arg2, arg3)
local frame = Instance.new("Frame")
frame.Position = UDim2.new(0, 0, 0, v86[186])
frame.Size = UDim2.fromScale(0, 1)
frame.BorderSizePixel = 0
arg2.Batch:Bind(frame, "BackgroundColor3", v86[139])
frame.Parent = v121
local v123 = v119.buildThumb(v121)
local v124 = v119.buildThumb(v121)
local frame2 = Instance.new("Frame")
frame2.AnchorPoint = Vector2.new(v86[63], 0.5)
frame2.Position = UDim2.fromScale(1, 0.5)
frame2.Size = UDim2.fromOffset(arg3, controlHeight)
frame2.BorderSizePixel = v86[186]
frame2.ClipsDescendants = v86[34]
arg2.Batch:Bind(frame2, "BackgroundColor3", "Background")
frame2.Parent = parent
local instance = Instance.new(v86[176])
instance.MinSize = Vector2.new(arg3, controlHeight)
instance.Parent = frame2
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(v86[186], 5)
uiCorner.Parent = frame2
local uiStroke = Instance.new("UIStroke")
arg2.Batch:Bind(uiStroke, "Color", "Outline")
uiStroke.Parent = frame2
local textLabel = Instance.new("TextLabel")
textLabel.FontFace = v116.SemiBold
textLabel.Text = ""
textLabel.BackgroundTransparency = 1
textLabel.Size = UDim2.fromScale(1, 1)
textLabel.BorderSizePixel = 0
textLabel.TextSize = 14
arg2.Batch:Bind(textLabel, v86[167], "TextColor")
textLabel.Parent = frame2
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingRight = UDim.new(0, 6)
uiPadding.PaddingLeft = UDim.new(0, 6)
uiPadding.Parent = textLabel
local rt = { Outline = v121, Accent = frame, MinThumb = v123, MaxThumb = v124, ValueLabel = textLabel }
arg._rt = rt
local v125 = nil
local v126 = v119.newTouchBubble(menu, arg2)

local function fn40(arg4)
return arg4 == v86[16] and v123 or v124
end

local function fn41(arg4)
local x = v121.AbsolutePosition.X
local x2 = v121.AbsoluteSize.X
local n = x + fn37(arg, arg.Value.Min) * x2
local n33 = x + fn37(arg, arg.Value.Max) * x2
return math.abs(arg4 - n) < math.abs(arg4 - n33) and v86[16] or "max"
end

local function fn42(arg4, arg5)
local v127 = v125

if v127 == nil then
v127 = arg5 or fn41(arg4.Position.X)
v125 = v127
v119.setThumbPressed(menu, fn40(v127), true)
end

local v128 = v119.valueAt(v121, arg4.Position.X, arg.Min, arg.Max)

if v127 == v86[16] then
arg:Set({ Min = v128, Max = arg.Value.Max })
else
arg:Set({ Min = arg.Value.Min, Max = v128 })
end

if arg4.UserInputType == Enum.UserInputType.Touch then
local min = v127 == "min" and arg.Value.Min or arg.Value.Max
local v129 = tostring
v126.Show(fn40(v127), v129(min))
end
end

local tbl18 = nil

local function fn43(isDragging, arg4)
arg._isDragging = isDragging
if isDragging then
tbl18 = { Min = arg.Value.Min, Max = arg.Value.Max }
return
end

if arg4 and tbl18 ~= nil then
arg:Set(tbl18, true)
end

tbl18 = nil

if v125 ~= nil then
v119.setThumbPressed(menu, fn40(v125), false)
v125 = nil
end

v126.Hide()
end

v118.connectDrag(arg2.Trove, v122, function(arg4)
fn42(arg4, nil)
end, fn43)

v118.connectDrag(arg2.Trove, v123, function(arg4)
fn42(arg4, "min")
end, fn43)

v118.connectDrag(arg2.Trove, v124, function(arg4)
fn42(arg4, "max")
end, fn43)

arg2.Trove:Connect(arg.ValueChanged, function()
fn38(arg, rt)
end)

fn38(arg, rt)
end

index2._New = function(arg, arg2, arg3, arg4)
local min = arg4.Min
local max = arg4.Max

local obj = setmetatable({
_trove = arg3,
_menu = arg,
Kind = "RangeSlider",
Row = arg2,
Min = min,
Max = max,
Step = arg4.Step or v86[63],
Value = { Min = min, Max = max },
Changed = arg3:Add(v115.new()),
ValueChanged = arg3:Add(v115.new()),
_onChanged = arg4.OnChanged or function()
end,
_isDragging = false,
_rt = nil,
}, index2)

local default = arg4.Default

if default ~= nil then
local v121, v122 = fn36(obj, default.Min, default.Max)
obj.Value = { Min = v121, Max = v122 }
end

local n = math.max(v86[8], (#tostring(min) + #tostring(max) + 3) * 8 + 20)

arg2:AttachRight(function(arg5, arg6)
fn39(obj, arg5, arg6, n)
return nil
end, nil, nil, arg3)

return obj
end

index2.Set = function(arg, arg2, arg3)
if type(arg2) ~= "table" then
return
end
local v121, v122 = fn36(arg, tonumber(arg2.Min) or arg.Value.Min, tonumber(arg2.Max) or arg.Value.Max)
if v121 == arg.Value.Min and v122 == arg.Value.Max then
return
end
arg.Value = { Min = v121, Max = v122 }
arg.ValueChanged:Fire(arg.Value)

if not arg3 then
arg._onChanged(arg.Value)
arg.Changed:Fire(arg.Value)
end
end

index2.SetLabel = function(arg, arg2)
arg.Row:SetLabel(arg2)
return arg
end

index2.SetTooltip = function(arg, arg2)
arg.Row:SetTooltip(arg2)
return arg
end

index2.SetVisible = function(arg, arg2)
arg.Row:SetVisible(arg2)
end

index2.OnChanged = function(arg, arg2)
arg._trove:Connect(arg.Changed, arg2)
return arg
end

index2.Connect = function(arg, arg2, arg3)
arg._trove:Connect(arg2, arg3)
return arg
end

index2.Destroy = function(arg)
arg._trove:Destroy()
end

return index2
end

tbl17.J = function()
local j = tbl17.cache.J

if not j then
local j2 = { c = fn35() }
tbl17.cache.J = j2
j = j2
end

return j.c
end
end
do -- K
local function fn35()
local v115 = tbl17.g()
tbl17.k()
tbl17.r()
local v116 = tbl17.s()
local v117 = tbl17.v()
local v118 = tbl17.x()
tbl17.B()
local v119 = tbl17.I()
local v120 = tbl17.w()
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local color = Color3.fromRGB(255, v86[108], 255)
local index2 = {}
index2.__index = index2

local function fn36(arg, arg2)
return math.clamp(v120.round(tonumber(arg2) or arg.Min, arg.Step), arg.Min, arg.Max)
end

local function fn37(arg)
local suffix = arg.Suffix
return tostring(arg.Value) .. suffix
end

local function fn38(arg, arg2, arg3)
arg2.ValueText.Text = fn37(arg)

if not arg._isDragging then
arg2.UpdateValueBoxSize()
end

local n = 0

if arg.Max ~= arg.Min then
n = (arg.Value - arg.Min) / (arg.Max - arg.Min)
end

if arg._isDragging or arg3 then
arg2.Accent.Size = UDim2.fromScale(n, 1)
return
end
arg._menu:Tween(arg2.Accent, { Size = UDim2.fromScale(n, 1) }, arg._menu:DragTweenInfo())
end

local function fn39(arg, parent, arg2, arg3)
local menu = arg._menu
local controlHeight = v117.get().Row.ControlHeight
local v121, v122 = v119.buildTrack(parent, arg2, arg3)
local frame = Instance.new("Frame")
frame.Size = UDim2.fromScale(v86[186], v86[63])
frame.BorderSizePixel = 0
arg2.Batch:Bind(frame, v86[5], "Accent")
frame.Parent = v121
local uiStroke = Instance.new("UIStroke")
arg2.Batch:Bind(uiStroke, v86[27], v86[139])
uiStroke.Parent = frame
local v123 = v119.buildThumb(frame)
v123.Position = UDim2.fromScale(1, 0.5)
local instance = Instance.new(v86[128])
instance.AnchorPoint = Vector2.new(1, 0.5)
instance.Position = UDim2.fromScale(v86[63], 0.5)
instance.Size = UDim2.fromOffset(arg3, controlHeight)
instance.BorderSizePixel = v86[186]
instance.ClipsDescendants = true
instance.BackgroundColor3 = color
instance.Parent = parent
local uiGradient = Instance.new("UIGradient")
uiGradient.Rotation = 90
arg2.Batch:BindGradient(uiGradient, { "GradientMid", "GradientDark" })
uiGradient.Parent = instance
local uiSizeConstraint = Instance.new("UISizeConstraint")
uiSizeConstraint.MinSize = Vector2.new(24, controlHeight)
uiSizeConstraint.Parent = instance
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, v86[175])
uiCorner.Parent = instance
local uiStroke2 = Instance.new("UIStroke")
arg2.Batch:Bind(uiStroke2, "Color", v86[120])
uiStroke2.Parent = instance
local textBox = Instance.new("TextBox")
textBox.FontFace = v116.SemiBold
textBox.Text = ""
textBox.BackgroundTransparency = 1
textBox.Size = UDim2.fromScale(1, 1)
textBox.BorderSizePixel = 0
textBox.TextSize = 16
textBox.TextScaled = false
arg2.Batch:Bind(textBox, "TextColor3", "TextColor")
textBox.Parent = instance
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingRight = UDim.new(0, 5)
uiPadding.PaddingLeft = UDim.new(v86[186], 5)
uiPadding.Parent = textBox

local function fn40()
local n = #textBox.Text
local n33 = 16

if n > 5 then
n33 = math.max(v86[181], 16 - n - 5)
end

if textBox.TextSize ~= n33 then
menu:Tween(textBox, { TextSize = n33 }, tweenInfo)
end

local n34 = math.clamp(n * n33 * 0.6 + 12, arg3, 72)

if instance.Size.X.Offset ~= n34 then
menu:Tween(instance, { Size = UDim2.fromOffset(n34, controlHeight) }, tweenInfo)
menu:Tween(v121, { Size = UDim2.new(v86[63], -n34 - v86[181], v86[186], 2) }, tweenInfo)
end
end

local rt = { Outline = v121, Accent = frame, ValueBox = instance, ValueText = textBox, UpdateValueBoxSize = fn40 }
arg._rt = rt

arg2.Trove:Connect(textBox.FocusLost, function()
local num = tonumber(textBox.Text:match("[%d%.%-]+"))

if num == nil then
fn38(arg, rt, true)
else
arg:Set(num)
end

fn40()
end)

local v124 = v119.newTouchBubble(menu, arg2)

local function fn41(arg4)
arg:Set(v119.valueAt(v121, arg4.Position.X, arg.Min, arg.Max))

if arg4.UserInputType == Enum.UserInputType.Touch then
v124.Show(v123, fn37(arg))
end
end

local value = nil

local function fn42(isDragging, arg4)
arg._isDragging = isDragging
v119.setThumbPressed(menu, v123, isDragging)
if isDragging then
value = arg.Value
return
end
v124.Hide()

if arg4 and value ~= nil then
arg:Set(value, true)
end

value = nil
fn40()
end

v118.connectDrag(arg2.Trove, v122, fn41, fn42)
v118.connectDrag(arg2.Trove, v123, fn41, fn42)

arg2.Trove:Connect(arg.ValueChanged, function()
fn38(arg, rt, false)
end)

fn38(arg, rt, true)
fn40()
end

index2._New = function(arg, arg2, arg3, arg4)
local min = arg4.Min
local max = arg4.Max
local suffix = arg4.Suffix or ""

local obj = setmetatable({
_trove = arg3,
_menu = arg,
Kind = v86[39],
Row = arg2,
Min = min,
Max = max,
Step = arg4.Step or v86[63],
Suffix = suffix,
Value = v86[186],
Changed = arg3:Add(v115.new()),
ValueChanged = arg3:Add(v115.new()),
_onChanged = arg4.OnChanged or function()
end,
_isDragging = false,
_rt = nil,
}, index2)

obj.Value = fn36(obj, arg4.Default or min)
local v121 = v86[183]
local n = math.clamp(math.max(#tostring(min) + #suffix, #tostring(max) + #suffix) * 16 * 0.6 + 12, 24, v121)

arg2:AttachRight(function(arg5, arg6)
fn39(obj, arg5, arg6, n)
return nil
end, nil, nil, arg3)

return obj
end

index2.Set = function(arg, arg2, arg3)
local v121 = fn36(arg, arg2)
if v121 == arg.Value then
return
end
arg.Value = v121
arg.ValueChanged:Fire(v121)

if not arg3 then
arg._onChanged(v121)
arg.Changed:Fire(v121)
end
end

index2.SetLabel = function(arg, arg2)
arg.Row:SetLabel(arg2)
return arg
end

index2.SetTooltip = function(arg, arg2)
arg.Row:SetTooltip(arg2)
return arg
end

index2.SetVisible = function(arg, arg2)
arg.Row:SetVisible(arg2)
end

index2.OnChanged = function(arg, arg2)
arg._trove:Connect(arg.Changed, arg2)
return arg
end

index2.Connect = function(arg, arg2, arg3)
arg._trove:Connect(arg2, arg3)
return arg
end

index2.Destroy = function(arg)
arg._trove:Destroy()
end

return index2
end

tbl17.K = function()
local k = tbl17.cache.K

if not k then
local k2 = { c = fn35() }
tbl17.cache.K = k2
k = k2
end

return k.c
end
end
do -- L
local function fn35()
local v115 = tbl17.E()
tbl17.r()
local v116 = tbl17.H()
local v117 = tbl17.s()
local v118 = tbl17.x()
tbl17.G()
local v119 = tbl17.J()
local v120 = tbl17.B()
local v121 = tbl17.K()
local v122 = tbl17.A()
local v123 = tbl17.w()
local color = Color3.fromRGB(v86[108], v86[108], 255)
local tbl18 = { "None", "Rainbow", "Breathing" }
local tbl19 = { "None", "Rainbow" }

local function fn36(parent, arg, arg2)
local n = 12

if arg2 then
n = 27
end

local frame = Instance.new("Frame")
frame.ClipsDescendants = v86[34]
frame.Size = UDim2.fromOffset(0, v86[144])
frame.AutomaticSize = Enum.AutomaticSize.X
frame.BorderSizePixel = v86[186]
frame.BackgroundColor3 = v122.get(v86[168])
frame.Parent = parent
local instance = Instance.new(v86[176])
instance.MinSize = Vector2.new(math.min(arg + n, n + 36), 22)
instance.MaxSize = Vector2.new(arg + n, 22)
instance.Parent = frame
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 5)
uiCorner.Parent = frame
local instance2 = Instance.new(v86[85])
instance2.Color = v122.get("Outline")
instance2.Parent = frame
local textBox = Instance.new("TextBox")
textBox.ClearTextOnFocus = false
textBox.FontFace = v117.SemiBold
textBox.TextColor3 = v122.get("TextColor")
textBox.Text = ""
textBox.AnchorPoint = Vector2.new(0, 0)
textBox.BorderSizePixel = 0
textBox.BackgroundTransparency = 1
textBox.Position = UDim2.new(0, 0, 0, 0)
textBox.Size = UDim2.new(1, 0, 1, 0)
textBox.AutomaticSize = Enum.AutomaticSize.None
textBox.TextXAlignment = Enum.TextXAlignment.Left
textBox.TextSize = v86[13]
textBox.Selectable = false
textBox.Active = true
textBox.Parent = frame
local instance3

if arg2 then
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
uiListLayout.FillDirection = Enum.FillDirection.Horizontal
uiListLayout.Padding = UDim.new(0, v86[175])
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = frame
local instance4 = Instance.new(v86[113])
instance4.PaddingRight = UDim.new(0, 5)
instance4.PaddingLeft = UDim.new(0, 5)
instance4.Parent = frame
instance3 = Instance.new(v86[128])
instance3.LayoutOrder = -1
instance3.Size = UDim2.fromOffset(12, 12)
instance3.BorderSizePixel = 0
instance3.Parent = frame
local uiCorner2 = Instance.new("UICorner")
uiCorner2.CornerRadius = UDim.new(0, 3)
uiCorner2.Parent = instance3
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingBottom = UDim.new(0, 2)
uiPadding.PaddingLeft = UDim.new(0, -v86[63])
uiPadding.PaddingRight = UDim.new(0, v86[63])
uiPadding.Parent = textBox
else
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingRight = UDim.new(0, v86[175])
uiPadding.PaddingLeft = UDim.new(0, 1)
uiPadding.Parent = textBox
instance3 = nil
end

frame.Active = true
frame.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
task.defer(function() textBox:CaptureFocus() end)
end
end)
return frame, textBox, instance3
end

return { build = function(arg, arg2, arg3, arg4, arg5)
local trove = arg2.Trove
local batch = arg2.Batch
local root = arg2.Root
local tbl20 = { Menu = arg, Trove = trove, Batch = batch }
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, v86[170])
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = root
local instance = Instance.new(v86[113])
instance.PaddingTop = UDim.new(0, 9)
instance.PaddingBottom = UDim.new(0, 10)
instance.PaddingRight = UDim.new(0, 9)
instance.PaddingLeft = UDim.new(0, 9)
instance.Parent = root
local frame = Instance.new("Frame")
frame.LayoutOrder = -1
frame.BackgroundTransparency = 1
frame.Size = UDim2.new(1, 0, 0, 23)
frame.BorderSizePixel = v86[186]
frame.Parent = root
local textLabel = Instance.new("TextLabel")
textLabel.FontFace = v117.Medium
textLabel.Text = v86[184]
textLabel.AnchorPoint = Vector2.new(0, 0.5)
textLabel.BackgroundTransparency = v86[63]
textLabel.Position = UDim2.fromScale(v86[186], 0.5)
textLabel.BorderSizePixel = 0
textLabel.AutomaticSize = Enum.AutomaticSize.XY
textLabel.TextSize = v86[13]
batch:Bind(textLabel, "TextColor3", v86[174])
textLabel.Parent = frame
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingBottom = UDim.new(v86[186], v86[56])
uiPadding.Parent = textLabel
local frame2 = Instance.new("Frame")
frame2.AnchorPoint = Vector2.new(1, 0)
frame2.Position = UDim2.fromScale(1, 0)
frame2.BackgroundTransparency = v86[63]
frame2.Size = UDim2.fromScale(0, 1)
frame2.AutomaticSize = Enum.AutomaticSize.X
frame2.BorderSizePixel = 0
frame2.Parent = frame
local instance2 = Instance.new(v86[4])
instance2.SortOrder = Enum.SortOrder.LayoutOrder
instance2.Parent = frame2
local uiPadding2 = Instance.new("UIPadding")
uiPadding2.PaddingTop = UDim.new(0, 1)
uiPadding2.PaddingRight = UDim.new(v86[186], 1)
uiPadding2.PaddingLeft = UDim.new(0, 1)
uiPadding2.Parent = frame2
local v124 = nil

if arg4.Gradient == "editable" then
local v125 = v120.new(arg, { Bare = true })

local tbl21 = {
Inline = v86[34],
MaxWidth = 86,
Options = { "Solid", "Gradient" },
Default = arg3.Mode,
OnChanged = function(arg6)
if type(arg6) == "string" then
arg5.SetMode(arg6)
end
end,
}

v124 = v116._New(arg, v125, trove:Extend(), tbl21)
v125:Realize(frame2, tbl20, 0)
else
frame2.Visible = false
end

local frame3 = Instance.new("Frame")
frame3.LayoutOrder = 0
frame3.BackgroundTransparency = 1
frame3.BorderSizePixel = 0
frame3.AutomaticSize = Enum.AutomaticSize.XY
frame3.Parent = root
local uiListLayout2 = Instance.new("UIListLayout")
uiListLayout2.FillDirection = Enum.FillDirection.Horizontal
uiListLayout2.HorizontalFlex = Enum.UIFlexAlignment.Fill
uiListLayout2.Padding = UDim.new(v86[186], v86[149])
uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout2.Parent = frame3
local frame4 = Instance.new("Frame")
frame4.Size = UDim2.fromOffset(241, 234)
frame4.BorderSizePixel = 0
frame4.BackgroundColor3 = Color3.fromRGB(v86[108], 0, 0)
frame4.Parent = frame3
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, v86[133])
uiCorner.Parent = frame4
local frame5 = Instance.new("Frame")
frame5.Size = UDim2.fromScale(1, 1)
frame5.ZIndex = v86[56]
frame5.BorderSizePixel = 0
frame5.BackgroundColor3 = color
frame5.Parent = frame4
local uiGradient = Instance.new("UIGradient")
uiGradient.Rotation = 270
uiGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, v86[186]), NumberSequenceKeypoint.new(1, 1) })
uiGradient.Color = ColorSequence.new(Color3.new(0, 0, 0))
uiGradient.Parent = frame5
local instance3 = Instance.new(v86[98])
instance3.CornerRadius = UDim.new(v86[186], 7)
instance3.Parent = frame5
local frame6 = Instance.new("Frame")
frame6.Size = UDim2.fromScale(v86[63], 1)
frame6.BorderSizePixel = 0
frame6.BackgroundColor3 = color
frame6.Parent = frame4
local uiGradient2 = Instance.new("UIGradient")
uiGradient2.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(v86[186], 0), NumberSequenceKeypoint.new(1, 1) })
uiGradient2.Parent = frame6
local instance4 = Instance.new(v86[98])
instance4.CornerRadius = UDim.new(0, 7)
instance4.Parent = frame6
local instance5 = Instance.new(v86[128])
instance5.BackgroundTransparency = 1
instance5.Position = UDim2.fromOffset(v86[122], 7)
instance5.Size = UDim2.new(1, -14, 1, -14)
instance5.ZIndex = v86[56]
instance5.BorderSizePixel = 0
instance5.Parent = frame4
local instance6 = Instance.new(v86[98])
instance6.CornerRadius = UDim.new(v86[186], 7)
instance6.Parent = instance5
local frame7 = Instance.new("Frame")
frame7.AnchorPoint = Vector2.new(0.5, 0.5)
frame7.Position = UDim2.fromScale(0.5, v86[101])
frame7.Size = UDim2.fromOffset(v86[12], 12)
frame7.ZIndex = 100
frame7.BorderSizePixel = 0
frame7.BackgroundColor3 = color
frame7.Parent = instance5
local uiCorner2 = Instance.new("UICorner")
uiCorner2.CornerRadius = UDim.new(v86[186], 7)
uiCorner2.Parent = frame7
local uiStroke = Instance.new("UIStroke")
uiStroke.Color = color
uiStroke.Thickness = 2
uiStroke.Parent = frame7
local frame8 = Instance.new("Frame")
frame8.BackgroundTransparency = 1
frame8.Size = UDim2.fromOffset(v86[186], 234)
frame8.BorderSizePixel = 0
frame8.AutomaticSize = Enum.AutomaticSize.XY
frame8.Parent = frame3
local uiListLayout3 = Instance.new("UIListLayout")
uiListLayout3.Padding = UDim.new(0, 23)
uiListLayout3.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout3.FillDirection = Enum.FillDirection.Horizontal
uiListLayout3.Parent = frame8
local instance7 = Instance.new(v86[113])
instance7.PaddingRight = UDim.new(0, v86[122])
instance7.PaddingLeft = UDim.new(0, v86[175])
instance7.Parent = frame8
local frame9 = Instance.new("Frame")
frame9.Size = UDim2.fromOffset(8, 234)
frame9.BorderSizePixel = 0
frame9.BackgroundColor3 = color
frame9.Parent = frame8
local frame10 = Instance.new("Frame")
frame10.AnchorPoint = Vector2.new(0.5, 0)
frame10.Position = UDim2.fromScale(v86[101], 0)
frame10.Size = UDim2.new(0, 28, 1, 0)
frame10.BackgroundTransparency = 1
frame10.Active = true
frame10.ZIndex = 150
frame10.Parent = frame9
local uiCorner3 = Instance.new("UICorner")
uiCorner3.CornerRadius = UDim.new(0, v86[155])
uiCorner3.Parent = frame9
local uiGradient3 = Instance.new("UIGradient")
uiGradient3.Rotation = v86[45]
local colorSequence = ColorSequence.new
local tbl21 = {}
local v125 = ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, v86[186]))
local v126 = ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0))
local v127 = ColorSequenceKeypoint.new(0.33, Color3.fromRGB(v86[186], 255, 0))
local v128 = ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255))
local v129 = ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255))
local v130 = ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, v86[108]))
tbl21[1] = v125
tbl21[2] = v126
tbl21[3] = v127
tbl21[4] = v128
tbl21[5] = v129
tbl21[6] = v130

do
local values = table.pack(ColorSequenceKeypoint.new(v86[63], Color3.fromRGB(255, 0, v86[186])))
table.move(values, 1, values.n, 7, tbl21)
end

uiGradient3.Color = colorSequence(tbl21)
uiGradient3.Parent = frame9
local frame11 = Instance.new("Frame")
frame11.BackgroundTransparency = 1
frame11.Position = UDim2.fromOffset(0, v86[56])
frame11.Size = UDim2.new(1, 0, 1, -8)
frame11.ZIndex = 2
frame11.BorderSizePixel = 0
frame11.Parent = frame9
local instance8 = Instance.new(v86[128])
instance8.AnchorPoint = Vector2.new(0.5, 0.5)
instance8.Position = UDim2.fromScale(0.5, 0.5)
instance8.Size = UDim2.fromOffset(16, v86[162])
instance8.ZIndex = 100
instance8.BorderSizePixel = 0
instance8.BackgroundColor3 = color
instance8.Parent = frame11
local instance9 = Instance.new(v86[85])
instance9.Color = color
instance9.Thickness = 2
instance9.Parent = instance8
local uiCorner4 = Instance.new("UICorner")
uiCorner4.CornerRadius = UDim.new(v86[63], 0)
uiCorner4.Parent = instance8
local frame12 = Instance.new("Frame")
frame12.Size = UDim2.fromOffset(8, 234)
frame12.BorderSizePixel = 0
frame12.BackgroundColor3 = color
frame12.Visible = arg4.AlphaEnabled
frame12.Parent = frame8
local frame13 = Instance.new("Frame")
frame13.AnchorPoint = Vector2.new(0.5, 0)
frame13.Position = UDim2.fromScale(0.5, 0)
frame13.Size = UDim2.new(v86[186], 28, 1, v86[186])
frame13.BackgroundTransparency = 1
frame13.Active = true
frame13.ZIndex = v86[110]
frame13.Parent = frame12
local uiCorner5 = Instance.new("UICorner")
uiCorner5.CornerRadius = UDim.new(v86[186], 3)
uiCorner5.Parent = frame12
local imageLabel = Instance.new("ImageLabel")
imageLabel.ScaleType = Enum.ScaleType.Tile
imageLabel.Image = "rbxassetid://18274452449"
imageLabel.BackgroundTransparency = v86[63]
imageLabel.Size = UDim2.fromScale(1, 1)
imageLabel.TileSize = UDim2.fromOffset(8, 8)
imageLabel.BorderSizePixel = v86[186]
imageLabel.Parent = frame12
local uiCorner6 = Instance.new("UICorner")
uiCorner6.CornerRadius = UDim.new(0, v86[155])
uiCorner6.Parent = imageLabel
local instance10 = Instance.new(v86[128])
instance10.Size = UDim2.fromScale(1, 1)
instance10.BorderSizePixel = 0
instance10.BackgroundColor3 = arg3.Color
instance10.Parent = frame12
local uiCorner7 = Instance.new("UICorner")
uiCorner7.CornerRadius = UDim.new(v86[186], 3)
uiCorner7.Parent = instance10
local instance11 = Instance.new(v86[46])
instance11.Rotation = 90
instance11.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(v86[63], 0) })
instance11.Parent = instance10
local instance12 = Instance.new(v86[128])
instance12.BackgroundTransparency = v86[63]
instance12.Position = UDim2.fromOffset(0, 4)
instance12.Size = UDim2.new(1, 0, 1, -v86[162])
instance12.ZIndex = 2
instance12.BorderSizePixel = 0
instance12.Parent = frame12
local frame14 = Instance.new("Frame")
frame14.AnchorPoint = Vector2.new(0.5, 0.5)
frame14.Position = UDim2.fromScale(0.5, 0.5)
frame14.Size = UDim2.fromOffset(12, 12)
frame14.ZIndex = 100
frame14.BorderSizePixel = 0
frame14.BackgroundColor3 = color
frame14.Parent = instance12
local uiStroke2 = Instance.new("UIStroke")
uiStroke2.Color = color
uiStroke2.Thickness = 2
uiStroke2.Parent = frame14
local uiCorner8 = Instance.new("UICorner")
uiCorner8.CornerRadius = UDim.new(1, 0)
uiCorner8.Parent = frame14
local frame15 = Instance.new("Frame")
frame15.LayoutOrder = 1
frame15.BackgroundTransparency = 1
frame15.Size = UDim2.new(1, 0, v86[186], v86[159])
frame15.BorderSizePixel = 0
frame15.Parent = root
local textLabel2 = Instance.new("TextLabel")
textLabel2.FontFace = v117.Medium
textLabel2.Text = "Input"
textLabel2.AnchorPoint = Vector2.new(0, v86[101])
textLabel2.BackgroundTransparency = 1
textLabel2.Position = UDim2.fromScale(0, v86[101])
textLabel2.BorderSizePixel = v86[186]
textLabel2.AutomaticSize = Enum.AutomaticSize.XY
textLabel2.TextSize = 16
batch:Bind(textLabel2, "TextColor3", "TextColor")
textLabel2.Parent = frame15
local frame16 = Instance.new("Frame")
frame16.BackgroundTransparency = v86[63]
frame16.Size = UDim2.fromScale(v86[186], 1)
frame16.AutomaticSize = Enum.AutomaticSize.X
frame16.BorderSizePixel = v86[186]
frame16.Parent = frame15
local uiListLayout4 = Instance.new("UIListLayout")
uiListLayout4.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout4.Parent = frame16
local uiPadding3 = Instance.new("UIPadding")
uiPadding3.PaddingTop = UDim.new(0, 1)
uiPadding3.PaddingLeft = UDim.new(0, v86[63])
uiPadding3.Parent = frame16
local frame17 = Instance.new("Frame")
frame17.AnchorPoint = Vector2.new(1, 0)
frame17.Position = UDim2.new(1, -v86[63], 0, 0)
frame17.BackgroundTransparency = v86[63]
frame17.Size = UDim2.fromScale(0, v86[63])
frame17.AutomaticSize = Enum.AutomaticSize.X
frame17.BorderSizePixel = 0
frame17.Parent = frame15
local uiListLayout5 = Instance.new("UIListLayout")
uiListLayout5.FillDirection = Enum.FillDirection.Horizontal
uiListLayout5.Padding = UDim.new(0, 7)
uiListLayout5.Parent = frame17
local uiPadding4 = Instance.new("UIPadding")
uiPadding4.PaddingTop = UDim.new(0, 1)
uiPadding4.PaddingLeft = UDim.new(0, 1)
uiPadding4.Parent = frame17

local tbl22 = { Repaint = function(...)
end }

local v131 = nil

if arg4.AlphaEnabled then
local v132 = v120.new(arg, { Bare = true })

v132:AttachRight(function(arg6)
local v133, v134 = fn36(arg6, 49, false)
v131 = v134
return v133
end, nil, nil, trove)

v132:Realize(frame17, tbl20, 0)
end

local v132 = nil
local _v133 = nil
local v134 = v120.new(arg, { Bare = true })

v134:AttachRight(function(arg6)
local v135, v136, v137 = fn36(arg6, v86[110], v86[34])
v132 = v136
_v133 = v137
return v135
end, nil, nil, trove)

v134:Realize(frame17, tbl20, 1)

if v131 ~= nil then
local v135 = v131

trove:Connect(v135.FocusLost, function()
local v136 = tonumber
local str7 = v135.Text:gsub("%%", "")
local v137 = v136(str7)

if v137 ~= nil then
arg5.SetAlpha(1 - math.clamp(v137 / 100, 0, 1))
else
tbl22.Repaint(true)
end
end)
end

if v132 ~= nil then
local v135 = v132

trove:Connect(v135.FocusLost, function()
local v136, v137 = v107(Color3.fromHex, v135.Text)

if v136 then
arg5.SetRgb(v137)
end
end)
end

local frame18 = Instance.new("Frame")
frame18.LayoutOrder = v86[56]
frame18.Visible = arg3.Mode == "Gradient"
frame18.BackgroundTransparency = 1
frame18.Size = UDim2.fromScale(v86[63], 0)
frame18.BorderSizePixel = 0
frame18.AutomaticSize = Enum.AutomaticSize.XY
frame18.Parent = root
local frame19 = Instance.new("Frame")
frame19.Active = v86[34]
frame19.Position = UDim2.fromOffset(29, 0)
frame19.Size = UDim2.new(1, -v86[60], 0, v86[144])
frame19.BorderSizePixel = 0
frame19.BackgroundColor3 = color
frame19.Parent = frame18
local instance13 = Instance.new(v86[46])
instance13.Parent = frame19
local uiCorner9 = Instance.new("UICorner")
uiCorner9.CornerRadius = UDim.new(0, 5)
uiCorner9.Parent = frame19
local frame20 = Instance.new("Frame")
frame20.BackgroundTransparency = v86[63]
frame20.Size = UDim2.new(1, 0, 0, 29)
frame20.Position = UDim2.fromOffset(0, -1)
frame20.BorderSizePixel = 0
frame20.ZIndex = 2
frame20.Parent = frame19

local function createTextButton(text, arg6)
local textButton = Instance.new("TextButton")
textButton.Active = v86[34]
textButton.Text = ""
textButton.Size = UDim2.fromOffset(22, 22)
textButton.BorderSizePixel = 0
textButton.AutoButtonColor = false

if arg6 then
textButton.AnchorPoint = Vector2.new(1, 0)
textButton.Position = UDim2.fromScale(1, 0)
end

batch:Bind(textButton, "BackgroundColor3", "Background")
textButton.Parent = frame18
local uiCorner10 = Instance.new("UICorner")
uiCorner10.CornerRadius = UDim.new(0, 5)
uiCorner10.Parent = textButton
local uiStroke3 = Instance.new("UIStroke")
uiStroke3.BorderOffset = UDim.new(v86[186], -v86[63])
uiStroke3.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
batch:Bind(uiStroke3, "Color", v86[120])
uiStroke3.Parent = textButton
local textLabel3 = Instance.new("TextLabel")
textLabel3.FontFace = v117.Medium
textLabel3.TextColor3 = Color3.fromRGB(132, 133, 139)
textLabel3.Text = text
textLabel3.BackgroundTransparency = 1
textLabel3.Size = UDim2.new(1, 1, 1, -2)
textLabel3.BorderSizePixel = v86[186]
textLabel3.TextWrapped = true
textLabel3.TextSize = 22
textLabel3.Parent = textButton
local uiPadding5 = Instance.new("UIPadding")
uiPadding5.PaddingBottom = UDim.new(0, 2)
uiPadding5.PaddingLeft = UDim.new(0, -1)
uiPadding5.PaddingRight = UDim.new(0, v86[63])
uiPadding5.Parent = textLabel3
return textButton
end

local v135 = createTextButton("-", v86[153])
local v136 = createTextButton("+", true)
local imageLabel2 = Instance.new("ImageLabel")
imageLabel2.Active = true
imageLabel2.AnchorPoint = Vector2.new(0.5, 0)
imageLabel2.Image = "rbxassetid://127264563810956"
imageLabel2.BackgroundTransparency = v86[63]
imageLabel2.Position = UDim2.new(0.5, -1, v86[186], -1)
imageLabel2.Size = UDim2.fromOffset(10, 29)
imageLabel2.BorderSizePixel = 0
batch:Bind(imageLabel2, "ImageColor3", "Outline")
imageLabel2.Parent = frame19
local imageLabel3 = Instance.new("ImageLabel")
imageLabel3.Size = UDim2.new(v86[63], -2, 0, 27)
imageLabel3.Image = "rbxassetid://127264563810956"
imageLabel3.BackgroundTransparency = 1
imageLabel3.Position = UDim2.fromOffset(1, 1)
imageLabel3.ZIndex = 2
imageLabel3.BorderSizePixel = 0
imageLabel3.Parent = imageLabel2
local frame21 = Instance.new("Frame")
frame21.Position = UDim2.fromOffset(1, 1)
frame21.Size = UDim2.new(v86[63], -2, 0, v86[71])
frame21.BorderSizePixel = 0
frame21.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
frame21.Parent = imageLabel3
local instance14 = Instance.new(v86[46])
instance14.Rotation = v86[45]
instance14.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, color), ColorSequenceKeypoint.new(1, Color3.fromRGB(211, 211, 211)) })
instance14.Parent = frame21
local instance15 = Instance.new(v86[128])
instance15.LayoutOrder = 5
instance15.BackgroundTransparency = 1
instance15.Size = UDim2.new(1, 0, v86[186], 23)
instance15.BorderSizePixel = 0
instance15.Visible = arg4.Animatable
instance15.Parent = root
local textLabel3 = Instance.new("TextLabel")
textLabel3.FontFace = v117.Medium
textLabel3.Text = "Animation"
textLabel3.AnchorPoint = Vector2.new(0, v86[101])
textLabel3.BackgroundTransparency = 1
textLabel3.Position = UDim2.fromScale(v86[186], 0.5)
textLabel3.BorderSizePixel = 0
textLabel3.AutomaticSize = Enum.AutomaticSize.XY
textLabel3.TextSize = v86[13]
batch:Bind(textLabel3, v86[167], v86[174])
textLabel3.Parent = instance15
local frame22 = Instance.new("Frame")
frame22.AnchorPoint = Vector2.new(v86[63], 0)
frame22.Position = UDim2.fromScale(1, 0)
frame22.BackgroundTransparency = 1
frame22.Size = UDim2.fromScale(v86[186], 1)
frame22.AutomaticSize = Enum.AutomaticSize.X
frame22.BorderSizePixel = v86[186]
frame22.Parent = instance15
local uiListLayout6 = Instance.new("UIListLayout")
uiListLayout6.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout6.Parent = frame22
local instance16 = Instance.new(v86[128])
instance16.LayoutOrder = 8
instance16.BackgroundTransparency = 1
instance16.Size = UDim2.fromScale(v86[63], 0)
instance16.AutomaticSize = Enum.AutomaticSize.Y
instance16.BorderSizePixel = v86[186]
instance16.Visible = arg4.Animatable and arg4.AnimationMode == "Breathing"
instance16.Parent = root
local allowBreathing = arg4.AllowBreathing and tbl18 or tbl19
local v137 = v120.new(arg, { Bare = true })

local tbl23 = {
Inline = true,
MaxWidth = 100,
Options = allowBreathing,
Default = arg4.AnimationMode,
OnChanged = function(arg6)
if type(arg6) == "string" then
arg5.SetAnimationMode(arg6)
instance16.Visible = arg4.Animatable and arg6 == "Breathing"
end
end,
}

local v138 = v116._New(arg, v137, trove:Extend(), tbl23)
v137:Realize(frame22, tbl20, 0)
local frame23 = Instance.new("Frame")
frame23.LayoutOrder = 6
frame23.BackgroundTransparency = v86[63]
frame23.Size = UDim2.fromScale(1, v86[186])
frame23.AutomaticSize = Enum.AutomaticSize.Y
frame23.BorderSizePixel = 0
frame23.Visible = arg4.Animatable
frame23.Parent = root
local v139 = v120.new(arg, { Label = "Speed", Height = 24, MediumTitle = true, RightOffset = -1 })

local tbl24 = {
Label = "Speed",
Min = 0,
Max = v86[175],
Step = v86[62],
Default = arg4.AnimationSpeed,
OnChanged = function(arg6)
arg5.SetAnimationSpeed(arg6)
end,
}

local v140 = v121._New(arg, v139, trove:Extend(), tbl24)
v139:Realize(frame23, tbl20, 0)
local n = 100

if arg4.AnimationBreathingMin ~= nil then
n = math.floor((1 - arg4.AnimationBreathingMin) * 100 + 0.5)
end

local n33 = 0

if arg4.AnimationBreathingMax ~= nil then
n33 = math.floor((1 - arg4.AnimationBreathingMax) * v86[91] + 0.5)
end

local v141 = v120.new(arg, { Label = "Alpha Range", Height = 24, MediumTitle = true, RightOffset = -1 })

local tbl25 = {
Label = v86[132],
Min = 0,
Max = 100,
Step = 1,
Default = { Min = n33, Max = n },
OnChanged = function(arg6)
local setAnimationBreathingRange = arg5.SetAnimationBreathingRange

if setAnimationBreathingRange ~= nil then
setAnimationBreathingRange(arg6)
end
end,
}

local v142 = v119._New(arg, v141, trove:Extend(), tbl25)
v141:Realize(instance16, tbl20, 0)
local tbl26 = {}
local v143 = trove:Extend()

local function fn37(arg6)
local n34 = math.clamp((arg6 - frame19.AbsolutePosition.X) / math.max(frame19.AbsoluteSize.X - 1, 1), 0, 1)
local huge = math.huge
local n35 = 1

for k, v144 in arg3.Stops, nil, nil do
local n36 = math.abs(v144.Time - n34)

if n36 < huge then
huge = n36
n35 = k
end
end

return n35
end

local function fn38(arg6)
if arg3.Mode ~= "Gradient" then
return
end

if arg6 then
arg5.SetDragMode(v86[150])
elseif arg3._dragMode == "stop" then
arg5.SetDragMode(nil)
end

tbl22.Repaint(true)
end

local function fn39(arg6)
arg5.MoveActiveStop(math.clamp((arg6.Position.X - frame19.AbsolutePosition.X) / math.max(frame19.AbsoluteSize.X - v86[63], 1), 0, 1))
end

local function fn40()
v143:Destroy()
v143 = trove:Extend()

for _, v144 in tbl26, nil, nil do
v144.Marker:Destroy()
end

table.clear(tbl26)
if arg3.Mode ~= v86[90] then
return
end

for k, v144 in arg3.Stops, nil, nil do
local flag19 = k == arg3.ActiveStopIndex
local imageButton = Instance.new("ImageButton")
imageButton.Active = true
imageButton.AutoButtonColor = false
imageButton.ImageColor3 = v122.get(v86[120])
imageButton.AnchorPoint = Vector2.new(0.5, 0)
imageButton.Image = "rbxassetid://127264563810956"
imageButton.BackgroundTransparency = 1
imageButton.Position = UDim2.new(v144.Time, -v86[63], 0, -v86[63])
imageButton.Size = flag19 and UDim2.fromOffset(10, 29) or UDim2.fromOffset(8, 24)
imageButton.BorderSizePixel = 0
imageButton.Parent = frame20
local imageLabel4 = Instance.new("ImageLabel")
imageLabel4.Size = UDim2.new(v86[63], -2, 1, -v86[56])
imageLabel4.Image = "rbxassetid://127264563810956"
imageLabel4.BackgroundTransparency = 1
imageLabel4.Position = UDim2.fromOffset(v86[63], v86[63])
imageLabel4.BorderSizePixel = 0
imageLabel4.Parent = imageButton
local frame24 = Instance.new("Frame")
frame24.Position = UDim2.fromOffset(1, 1)
frame24.Size = flag19 and UDim2.new(1, -v86[56], 0, 19) or UDim2.new(1, -2, 0, 16)
frame24.BorderSizePixel = v86[186]
frame24.BackgroundColor3 = v144.Value
frame24.Parent = imageLabel4
local uiGradient4 = Instance.new("UIGradient")
uiGradient4.Rotation = 90
local new = ColorSequenceKeypoint.new
local color2 = Color3.fromRGB
uiGradient4.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, color), new(1, color2(211, 211, 211)) })
uiGradient4.Parent = frame24

if not flag19 then
imageButton.ImageTransparency = v86[62]
end

tbl26[k] = { Marker = imageButton, Accent = frame24 }

v118.connectClick(v143, imageButton, function()
arg5.SelectStop(k)
end)

v118.connectDrag(v143, imageButton, fn39, function(arg6)
if arg6 then
arg5.SelectStop(k)
end

fn38(arg6)
end)
end
end

local function fn41(arg6)
local v144 = arg:DragTweenInfo()

for k, v145 in tbl26, nil, nil do
local v146 = arg3.Stops[k]

if v146 ~= nil then
local imageTransparency = k == arg3.ActiveStopIndex
local udim2 = UDim2.new(v146.Time, -1, 0, -1)
local udim22 = imageTransparency and UDim2.fromOffset(10, 29) or UDim2.fromOffset(v86[162], v86[61])
local udim23 = imageTransparency and UDim2.new(1, -2, 0, 19) or UDim2.new(1, -v86[56], 0, v86[13])
imageTransparency = imageTransparency and 0 or v86[62]

if arg6 then
v145.Marker.Position = udim2
v145.Marker.Size = udim22
v145.Marker.ImageTransparency = imageTransparency
v145.Accent.Size = udim23
v145.Accent.BackgroundColor3 = v146.Value
else
arg:Tween(v145.Marker, { Position = udim2, Size = udim22, ImageTransparency = imageTransparency }, v144)
arg:Tween(v145.Accent, { Size = udim23, BackgroundColor3 = v146.Value }, v144)
end
end
end
end

local function _fn42(arg6)
instance13.Color = v115.toSequence(arg3.Stops)
local v144 = arg3.Stops[arg3.ActiveStopIndex]
local color2 = arg3.Color
local udim2 = UDim2.new(v86[101], -v86[63], 0, -1)

if v144 ~= nil then
color2 = v144.Value
udim2 = UDim2.new(v144.Time, -1, v86[186], -v86[63])
end

frame21.BackgroundColor3 = color2
local udim22 = UDim2.fromOffset(v86[133], v86[123])

if arg3._dragMode == "stop" then
udim22 = UDim2.fromOffset(12, v86[31])
end

if #tbl26 ~= #arg3.Stops then
fn40()
else
fn41(arg6)
end

if arg6 then
imageLabel2.Position = udim2
imageLabel2.Size = udim22
else
arg:Tween(imageLabel2, { Position = udim2, Size = udim22 }, arg:DragTweenInfo())
end
end

v118.connectDrag(trove, frame4, function(arg6)
local n34 = math.max(frame4.AbsoluteSize.X - 1, 1)
local n35 = math.max(frame4.AbsoluteSize.Y - v86[63], 1)
arg5.SetHSVA(arg3.Hue, math.clamp((arg6.Position.X - frame4.AbsolutePosition.X) / n34, v86[186], 1), 1 - math.clamp((arg6.Position.Y - frame4.AbsolutePosition.Y) / n35, 0, v86[63]), arg3.Alpha)
end, function(arg6)
local str7 = nil

if arg6 then
str7 = "sat"
end

arg5.SetDragMode(str7)
end)

v118.connectDrag(trove, frame10, function(arg6)
local v144 = v86[186]
arg5.SetHSVA(math.clamp((arg6.Position.Y - frame9.AbsolutePosition.Y) / math.max(frame9.AbsoluteSize.Y - 1, 1), v144, 1), arg3.Sat, arg3.Val, arg3.Alpha)
end, function(arg6)
local str7 = nil

if arg6 then
str7 = "hue"
end

arg5.SetDragMode(str7)
end)

v118.connectDrag(trove, frame13, function(arg6)
local n34 = math.clamp((arg6.Position.Y - frame12.AbsolutePosition.Y) / math.max(frame12.AbsoluteSize.Y - 1, 1), 0, 1)
arg5.SetHSVA(arg3.Hue, arg3.Sat, arg3.Val, n34)
end, function(arg6)
local str7 = nil

if arg6 then
str7 = "alpha"
end

arg5.SetDragMode(str7)
end)

v118.connectClick(trove, frame19, function()
if arg3.Mode == v86[90] then
arg5.SelectStop(fn37(v123.getPointerPosition().X))
end
end)

v118.connectDrag(trove, frame19, fn39, function(arg6)
if arg3.Mode ~= "Gradient" then
return
end

if arg6 then
arg5.SelectStop(fn37(v123.getPointerPosition().X))
end

fn38(arg6)
if not (n26 >= 4814) then
return
end

-- (anti-tamper freeze trap removed)
end)

v118.connectDrag(trove, imageLabel2, fn39, fn38)

v118.connectClick(trove, v136, function()
arg5.AddStop()
end)

v118.connectClick(trove, v135, function()
arg5.RemoveStop()
end)

local function repaint(snap)
local hueColor = Color3.fromHSV(arg3.Hue, 1, 1)
frame4.BackgroundColor3 = hueColor
frame7.Position = UDim2.new(arg3.Sat, 0, 1 - arg3.Val, 0)
frame7.BackgroundColor3 = arg3.Color
instance8.Position = UDim2.new(0.5, 0, arg3.Hue, 0)
frame14.Position = UDim2.new(0.5, 0, arg3.Alpha, 0)
frame14.BackgroundColor3 = arg3.Color
instance10.BackgroundColor3 = arg3.Color
if arg3.Mode == v86[90] then
_fn42(snap)
else
frame21.BackgroundColor3 = arg3.Color
end
if v132 ~= nil and not v132:IsFocused() then
v132.Text = arg3.Color:ToHex()
end
if v131 ~= nil and not v131:IsFocused() then
v131.Text = tostring(math.floor((1 - arg3.Alpha) * 100 + 0.5))
end
if _v133 ~= nil then
_v133.BackgroundColor3 = arg3.Color
end
end
tbl22.Repaint = repaint

return {
Repaint = repaint,
SyncMode = function(arg6)
frame18.Visible = arg6 == "Gradient"

if v124 ~= nil then
v124:Set(arg6, true)
end
end,
SyncAnimation = function(arg6, arg7)
v138:Set(arg6, true)
v140:Set(arg7, v86[34])
instance16.Visible = arg4.Animatable and arg6 == "Breathing"
end,
SyncAnimationBreathingRange = function(arg6)
v142:Set(arg6, v86[34])
end,
SetAnimationEnabled = function(visible, arg6)
instance15.Visible = visible
frame23.Visible = visible
instance16.Visible = visible and v138.Value == "Breathing"
local v144 = tbl18

if not arg6 then
v144 = tbl19
end

v138:SetOptions(v144)
end,
}
end }
end

tbl17.L = function()
local l = tbl17.cache.L

if not l then
local l2 = { c = fn35() }
tbl17.cache.L = l2
l = l2
end

return l.c
end
end
do -- M
local function fn35()
local v115 = tbl17.g()
tbl17.k()
local v116 = tbl17.L()
local v117 = tbl17.E()
tbl17.r()
local v118 = tbl17.u()
local v119 = tbl17.x()
local v120 = tbl17.G()
tbl17.B()
local color = Color3.fromRGB(255, 255, 255)
local index2 = {}
index2.__index = index2

local function fn36(arg)
return arg.Stops[arg.ActiveStopIndex]
end

local function fn37(arg, arg2)
local flag19 = arg2 == "Gradient" and arg.Gradient ~= "off"
local mode = "Solid"

if flag19 then
mode = "Gradient"
end

arg.Mode = mode

if mode == "Gradient" then
arg.Stops = v117.ensure(arg.Stops, arg.Color)
arg.ActiveStopIndex = math.clamp(arg.ActiveStopIndex, 1, #arg.Stops)
local v121 = fn36(arg)

if v121 ~= nil then
arg.Color = v121.Value
local v122, v123, v124 = v121.Value:ToHSV()
arg.Hue = v122
arg.Sat = v123
arg.Val = v124
end
end

local panel = arg._panel

if panel ~= nil then
panel.SyncMode(mode)
end
end

index2._ApplyState = function(I,W)local N=Color3.fromHSV(I.Hue,I.Sat,I.Val);local P=nil;if I.Mode=="Gradient"then I.Stops= v117 .ensure(I.Stops,N);I.ActiveStopIndex=math.clamp(I.ActiveStopIndex,1,#I.Stops);local a= fn36 (I);if a~=nil then a.Value=N;P=a.Value;else P=N;end;else P=N;end;I.Color=P;N=I._rt;if N~=nil then local a=I.Mode=="Gradient";N.Swatch.BackgroundColor3=if a then  color else P;N.SwatchGradient.Enabled=a;if a then N.SwatchGradient.Color= v117 .toSequence(I.Stops);else N.SwatchGradient.Color=ColorSequence.new(P);end;end;I.Value={Rgb=P,Alpha=I.Alpha,Stops=if I.Mode=="Gradient"then( v117 .clone(I.Stops))else nil};P=I._panel;if P~=nil then P.Repaint(I._dragMode~=nil or I.AnimationMode~="None");end;I.ValueChanged:Fire(I.Value);if not W then I._onChanged(I.Value);I.Changed:Fire(I.Value);end;end

local function fn38(arg, arg2)
local menu = arg._menu

local v121 = v120.new(menu, arg._trove, {
Trigger = arg2,
Size = UDim2.fromOffset(300, 300),
AutomaticSize = Enum.AutomaticSize.Y,
CornerRadius = 13,
FlatBackground = v86[34],
Glow = v86[34],
ParentEntry = arg._parentOverlay,
Place = v120.placeBelow(1, 2),
OnToggle = function(arg3)
if arg3 then
local panel = arg._panel

if panel ~= nil then
panel.Repaint(v86[34])
end
end
end,
})

arg._popup = v121

if v118.Scale ~= 1 then
local uiScale = Instance.new("UIScale")
uiScale.Scale = v118.Scale
uiScale.Parent = v121.Root
end

local v122 = v116.build(menu, v121, arg, {
AlphaEnabled = arg.AlphaEnabled,
Gradient = arg.Gradient,
Animatable = arg.Animatable,
AllowBreathing = arg._allowBreathing,
AnimationMode = arg.AnimationMode,
AnimationSpeed = arg.AnimationSpeed,
AnimationBreathingMin = arg.AnimationBreathingRange and arg.AnimationBreathingRange.Min,
AnimationBreathingMax = arg.AnimationBreathingRange and arg.AnimationBreathingRange.Max,
}, {
SetHSVA = function(hue, sat, val, alpha)
arg.Hue = hue
arg.Sat = sat
arg.Val = val
arg.Alpha = alpha
arg:_ApplyState(false)
end,
SetDragMode = function(dragMode)
arg._dragMode = dragMode
arg.Dragging = dragMode ~= nil
end,
SelectStop = function(arg3)
if arg.Mode ~= "Gradient" or #arg.Stops == 0 then
return
end
arg.ActiveStopIndex = math.clamp(arg3, v86[63], #arg.Stops)
local v122 = fn36(arg)

if v122 ~= nil then
arg.Color = v122.Value
local v123 = arg
local v124 = arg
local v125 = arg
local v126, v127, v128 = v122.Value:ToHSV()
v123.Hue = v126
v124.Sat = v127
v125.Val = v128
end

arg:_ApplyState(true)
end,
MoveActiveStop = function(arg3)
local v122 = fn36(arg)
if arg.Mode ~= "Gradient" or v122 == nil or arg.ActiveStopIndex == 1 or arg.ActiveStopIndex == #arg.Stops then
return
end
v122.Time = math.clamp(arg3, 0, 1)
arg.ActiveStopIndex = v117.sort(arg.Stops, v122)
arg:_ApplyState(false)
end,
AddStop = function()
if arg.Mode ~= "Gradient" then
fn37(arg, "Gradient")
end

local v122 = fn36(arg)
local n = 0.5

if v122 ~= nil then
if arg.ActiveStopIndex < #arg.Stops then
n = (v122.Time + arg.Stops[arg.ActiveStopIndex + 1].Time) * 0.5
elseif arg.ActiveStopIndex > 1 then
n = (arg.Stops[arg.ActiveStopIndex - 1].Time + v122.Time) * v86[101]
end
end

local tbl18 = { Time = n, Value = arg.Color }
table.insert(arg.Stops, tbl18)
arg.ActiveStopIndex = v117.sort(arg.Stops, tbl18)
arg:_ApplyState(false)
end,
RemoveStop = function()
if arg.Mode ~= "Gradient" or #arg.Stops <= v86[56] then
return
end
local activeStopIndex = arg.ActiveStopIndex
if activeStopIndex == 1 or activeStopIndex == #arg.Stops then
return
end
local time = arg.Stops[activeStopIndex].Time
table.remove(arg.Stops, activeStopIndex)
local huge = math.huge
local v122 = nil
local activeStopIndex2 = 1

for k, v123 in arg.Stops, v122, nil do
local n = math.abs(v123.Time - time)

if n < huge then
huge = n
activeStopIndex2 = k
end
end

arg.ActiveStopIndex = activeStopIndex2
arg._dragMode = nil
arg.Dragging = v86[153]
arg:_ApplyState(false)
end,
SetMode = function(arg3)
fn37(arg, arg3)
arg:_ApplyState(false)
end,
SetAlpha = function(arg3)
arg.Alpha = math.clamp(arg3, 0, 1)
arg:_ApplyState(v86[153])
end,
SetRgb = function(arg3)
arg:Set({ Rgb = arg3, Alpha = arg.Alpha, Stops = arg.Value.Stops }, false)
end,
SetAnimationMode = function(arg3)
arg:SetAnimationMode(arg3)
end,
SetAnimationSpeed = function(arg3)
arg:SetAnimationSpeed(arg3)
end,
SetAnimationBreathingRange = function(arg3)
arg:SetAnimationBreathingRange(arg3)
end,
})

arg._panel = v122
v122.Repaint(true)
end

local function createTextButton(arg, parent, arg2)
local textButton = Instance.new("TextButton")
textButton.AnchorPoint = Vector2.new(1, 0.5)
textButton.Position = UDim2.fromScale(1, 0.5)
textButton.Size = UDim2.fromOffset(v86[32], v86[32])
textButton.BorderSizePixel = 0
textButton.BackgroundColor3 = arg.Color
textButton.Text = ""
textButton.AutoButtonColor = false
textButton.Parent = parent
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(v86[186], v86[175])
uiCorner.Parent = textButton
local uiGradient = Instance.new("UIGradient")
uiGradient.Enabled = arg.Mode == "Gradient"

if arg.Mode == "Gradient" then
uiGradient.Color = v117.toSequence(arg.Stops)
else
uiGradient.Color = ColorSequence.new(arg.Color)
end

uiGradient.Parent = textButton
arg._rt = { Swatch = textButton, SwatchGradient = uiGradient }
arg._parentOverlay = arg2.ParentOverlay

v119.connectClick(arg2.Trove, textButton, function()
if arg._panel == nil then
fn38(arg, textButton)
end

local popup = arg._popup

if popup ~= nil then
popup:Toggle()
end
end)

return textButton
end

index2._New = function(arg, arg2, arg3, arg4)
local gradient = arg4.Gradient or "off"
local default = arg4.Default
local n = v86[63]
local rgb = color
local stops = nil

if default ~= nil then
rgb = color

if default.Rgb ~= nil then
rgb = default.Rgb
end

if default.Alpha ~= nil then
n = math.clamp(default.Alpha, 0, 1)
end

stops = default.Stops
end

local str7 = "Solid"

if gradient ~= "off" then
if gradient == "only" or stops ~= nil and #stops > v86[186] then
str7 = "Gradient"
end
end

local v121 = v117.ensure(stops, rgb)
local v122, v123, v124 = rgb:ToHSV()

local obj = setmetatable({
_trove = arg3,
_menu = arg,
Kind = "ColorPicker",
Row = arg2,
AlphaEnabled = arg4.Alpha == true,
Gradient = gradient,
Mode = str7,
Hue = v122,
Sat = v123,
Val = v124,
Alpha = n,
Color = rgb,
Stops = v121,
ActiveStopIndex = 1,
Dragging = false,
_dragMode = nil,
Animatable = arg4.Animatable == true,
AnimationMode = "None",
AnimationSpeed = 1,
AnimationBreathingRange = nil,
Value = { Rgb = rgb, Alpha = n, Stops = str7 == "Gradient" and v117.clone(v121) or nil },
Changed = arg3:Add(v115.new()),
ValueChanged = arg3:Add(v115.new()),
AnimationChanged = arg3:Add(v115.new()),
AnimationSpeedChanged = arg3:Add(v115.new()),
AnimationBreathingRangeChanged = arg3:Add(v115.new()),
_onChanged = arg4.OnChanged or function()
end,
_allowBreathing = arg4.Alpha == true,
_rt = nil,
_panel = nil,
_popup = nil,
_parentOverlay = nil,
}, index2)

arg2:AttachRight(function(arg5, arg6)
return createTextButton(obj, arg5, arg6)
end, 18, nil, arg3)

return obj
end

index2.Set = function(arg, arg2, arg3)
local rgb = arg2.Rgb or arg.Color
local alpha = arg.Alpha

if arg2.Alpha ~= nil then
alpha = math.clamp(arg2.Alpha, 0, v86[63])
end

local stops = arg2.Stops
local mode = arg.Mode

if arg.Gradient == v86[172] then
stops = nil
mode = "Solid"
elseif stops ~= nil then
if v86[186] < #stops then
mode = "Gradient"
else
mode = "Solid"
end
end

local hue, v121, v122 = rgb:ToHSV()

if mode == "Gradient" then
local ensure = v117.ensure
stops = stops or arg.Stops
arg.Stops = ensure(stops, rgb)
arg.ActiveStopIndex = math.clamp(arg.ActiveStopIndex, 1, #arg.Stops)
local v123 = fn36(arg)

if v123 ~= nil then
v123.Value = rgb
end
elseif stops ~= nil and #stops > 0 then
arg.Stops = v117.ensure(stops, rgb)
end

local flag19 = arg._dragMode == "sat" or arg._dragMode == v86[164]

if not flag19 then
flag19 = not (v122 > 0 and v121 > 0)
end

if flag19 then
hue = arg.Hue
end

fn37(arg, mode)
arg.Hue = hue
arg.Sat = v121
arg.Val = v122
arg.Alpha = alpha
arg:_ApplyState(arg3)
end

index2.EnableAnimation = function(arg, allowBreathing)
arg.Animatable = v86[34]
arg._allowBreathing = allowBreathing
local panel = arg._panel

if panel ~= nil then
panel.SetAnimationEnabled(true, allowBreathing)
end

return arg
end

index2.SetAnimationMode = function(arg, animationMode, arg2)
if arg.AnimationMode ~= animationMode then
arg.AnimationMode = animationMode
local panel = arg._panel

if panel ~= nil then
panel.SyncAnimation(animationMode, arg.AnimationSpeed)
end

if not arg2 then
arg.AnimationChanged:Fire(animationMode)
end
end

return arg
end

index2.SetAnimationSpeed = function(arg, animationSpeed, arg2)
if arg.AnimationSpeed ~= animationSpeed then
arg.AnimationSpeed = animationSpeed
local panel = arg._panel

if panel ~= nil then
panel.SyncAnimation(arg.AnimationMode, animationSpeed)
end

if not arg2 then
arg.AnimationSpeedChanged:Fire(animationSpeed)
end
end

return arg
end

index2.SetAnimationBreathingRange = function(arg, animationBreathingRange, arg2)
arg.AnimationBreathingRange = animationBreathingRange
local panel = arg._panel

if panel ~= nil then
panel.SyncAnimationBreathingRange(animationBreathingRange)
end

if not arg2 then
arg.AnimationBreathingRangeChanged:Fire(animationBreathingRange)
end

return arg
end

index2.SetOpen = function(arg, arg2)
local popup = arg._popup

if popup == nil then
local rt = arg._rt
if rt == nil then
return
end
fn38(arg, rt.Swatch)
popup = arg._popup
end

if popup ~= nil then
popup:SetOpen(arg2)
end
end

index2.SetLabel = function(arg, arg2)
arg.Row:SetLabel(arg2)
return arg
end

index2.SetTooltip = function(arg, arg2)
arg.Row:SetTooltip(arg2)
return arg
end

index2.SetVisible = function(arg, arg2)
arg.Row:SetVisible(arg2)
end

index2.OnChanged = function(arg, arg2)
arg._trove:Connect(arg.Changed, arg2)
return arg
end

index2.Connect = function(arg, arg2, arg3)
arg._trove:Connect(arg2, arg3)
return arg
end

index2.Destroy = function(arg)
arg._trove:Destroy()
end

return index2
end

tbl17.M = function()
local m = tbl17.cache.M

if not m then
m = { c = fn35() }
tbl17.cache.M = m
end

return m.c
end
end
do -- N
local function fn35()local I= tbl17 .D(); tbl17 .M(); tbl17 .r();local l={bind=function(W,N)local P=false;local function a()if P or W.Dragging then return;end;local e=N.Read();if e~=nil then W:Set(e,true);end;end;W:OnChanged(function(e)P=true;N.Write(e);P=false;end);for P,P_25 in N.Changed,nil,nil do W:Connect(P_25,a);end;a();return W;end};local function W(N,P)if N.GetBase~=nil then return N:GetBase(P);end;return N:Get(P);end;l.bindConfig=function(N,P,a)local e,c,E=a.Config,a.Transparency,a.Gradient=="editable"or a.Gradient=="only";a={P:Changed(e)};if c~=nil then table.insert(a,P:Changed(c));end;return l.bind(N,{Read=function()local N,p=W(P,e),if c~=nil then(W(P,c))else nil;if E then return I.decodeSequence(N,p);end;return I.decodeSolid(N,p);end,Write=function(W)local N;if E then local E;E,N=I.encodeSequence(W);P:Set(e,E);else local E;E,N=I.encodeSolid(W);P:Set(e,E);end;if c~=nil then P:Set(c,N);end;end,Changed=a});end;return l;end

tbl17.N = function()
local n = tbl17.cache.N

if not n then
local n33 = { c = fn35() }
tbl17.cache.N = n33
n = n33
end

return n.c
end
end
do -- Q
local function fn35()
tbl17.g()
tbl17.k()
tbl17.r()
local v115 = tbl17.s()
tbl17.B()
local index2 = {}
index2.__index = index2

local function createFrame(arg, parent, arg2)
local frame = Instance.new("Frame")
frame.BackgroundTransparency = v86[63]
frame.Size = UDim2.new(1, 0, 0, 16)
frame.BorderSizePixel = v86[186]
frame.Parent = parent
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.FillDirection = Enum.FillDirection.Horizontal
uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
uiListLayout.HorizontalFlex = Enum.UIFlexAlignment.Fill
uiListLayout.Padding = UDim.new(v86[186], v86[186])
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = frame

local function fn36(layoutOrder)
local frame2 = Instance.new("Frame")
frame2.BackgroundTransparency = v86[195]
frame2.BorderSizePixel = 0
frame2.Size = UDim2.fromOffset(0, v86[63])
frame2.LayoutOrder = layoutOrder
arg2.Batch:Bind(frame2, v86[5], "TextColor")
frame2.Parent = frame
local uiFlexItem = Instance.new("UIFlexItem")
uiFlexItem.FlexMode = Enum.UIFlexMode.Fill
uiFlexItem.Parent = frame2
end

fn36(0)
local textLabel = Instance.new("TextLabel")
textLabel.BackgroundTransparency = 1
textLabel.BorderSizePixel = 0
textLabel.Size = UDim2.fromScale(0, 1)
textLabel.AutomaticSize = Enum.AutomaticSize.X
textLabel.FontFace = v115.SemiBold
textLabel.Text = arg.Label:upper()
textLabel.TextSize = 12
textLabel.TextXAlignment = Enum.TextXAlignment.Center
textLabel.LayoutOrder = v86[63]
textLabel.Visible = arg.Label ~= ""
arg2.Batch:Bind(textLabel, "TextColor3", "TextColor")
textLabel.Parent = frame
local instance = Instance.new(v86[113])
instance.PaddingLeft = UDim.new(0, v86[162])
instance.PaddingRight = UDim.new(0, 8)
instance.Parent = textLabel
fn36(2)
arg._rt = { Object = frame, Label = textLabel }
return frame
end

index2._New = function(arg, arg2, arg3, arg4)
local obj = setmetatable({ _trove = arg3, _menu = arg, Kind = "Divider", Row = arg2, Label = arg4.Label or "", _rt = nil }, index2)

arg2:AttachRight(function(arg5, arg6)
return createFrame(obj, arg5, arg6)
end, nil, nil, arg3)

return obj
end

index2.SetLabel = function(arg, label)
arg.Label = label
local rt = arg._rt

if rt ~= nil then
rt.Label.Text = label:upper()
rt.Label.Visible = label ~= ""
end

return arg
end

index2.SetVisible = function(arg, arg2)
arg.Row:SetVisible(arg2)
end

index2.Connect = function(arg, arg2, arg3)
arg._trove:Connect(arg2, arg3)
return arg
end

index2.Destroy = function(arg)
arg._trove:Destroy()
end

return index2
end

tbl17.Q = function()
local q = tbl17.cache.Q

if not q then
local q2 = { c = fn35() }
tbl17.cache.Q = q2
q = q2
end

return q.c
end
end
do -- R
local function fn35()
local v115 = tbl17.g()
tbl17.k()
tbl17.r()
local v116 = tbl17.s()
local v117 = tbl17.x()
tbl17.B()
local v118 = tbl17.A()
local index2 = {}
index2.__index = index2

local function fn36(arg)
if arg.Default ~= nil then
return arg.Default
end
local v119 = arg.Options[1]
return (v119 ~= nil and { v119.Name } or { "" })[1]
end

local function fn37(arg, parent, arg2, arg3)
local instance = Instance.new(v86[128])
instance.BackgroundTransparency = v86[63]
instance.BorderSizePixel = 0
instance.Size = UDim2.new(1, 0, 0, arg3)
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.FillDirection = Enum.FillDirection.Horizontal
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0, v86[54])
uiListLayout.Parent = instance
local n = arg3 - 12 - v86[155] - 10 - 3
local n33 = #arg._options

for k, v119 in arg._options, nil, nil do
local imageButton = Instance.new("ImageButton")
imageButton.BackgroundTransparency = 1
imageButton.BorderSizePixel = 0
imageButton.AutoButtonColor = false
imageButton.Image = ""
imageButton.LayoutOrder = k
imageButton.Size = UDim2.new(v86[63] / n33, -v86[54], 1, 0)
imageButton.Parent = instance
local frame = Instance.new("Frame")
frame.BackgroundTransparency = 1
frame.BorderSizePixel = 0
frame.Position = UDim2.fromScale(0.5, 0)
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.Size = UDim2.new(1, -20, 1, -10)
frame.Parent = imageButton
local uiListLayout2 = Instance.new("UIListLayout")
uiListLayout2.FillDirection = Enum.FillDirection.Vertical
uiListLayout2.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout2.Padding = UDim.new(0, 3)
uiListLayout2.Parent = frame
local imageLabel = Instance.new("ImageLabel")
imageLabel.BackgroundTransparency = 1
imageLabel.BorderSizePixel = 0
imageLabel.LayoutOrder = 1
imageLabel.ScaleType = Enum.ScaleType.Fit
imageLabel.Size = UDim2.new(1, 0, 0, n)
imageLabel.Image = v119.Icon
imageLabel.Parent = frame
local textLabel = Instance.new("TextLabel")
textLabel.BackgroundTransparency = v86[63]
textLabel.BorderSizePixel = 0
textLabel.FontFace = v116.SemiBold
textLabel.LayoutOrder = v86[56]
textLabel.Size = UDim2.new(1, 0, 0, 14)
textLabel.Text = v119.Name
textLabel.TextSize = 12
textLabel.TextTruncate = Enum.TextTruncate.AtEnd
textLabel.Parent = frame
local frame2 = Instance.new("Frame")
frame2.BackgroundTransparency = v86[63]
frame2.BorderSizePixel = 0
frame2.Position = UDim2.new(0, 0, 1, -3)
frame2.Size = UDim2.new(v86[63], 0, 0, 10)
arg2.Batch:Bind(frame2, "BackgroundColor3", "Accent")
frame2.Parent = imageButton
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 3)
uiCorner.Parent = frame2
arg._cells[k] = { Icon = imageLabel, Label = textLabel, Accent = frame2, Name = v119.Name }

v117.connectClick(arg2.Trove, imageButton, function()
arg:Set(v119.Name)
end)
end

arg2.Batch:BindStateful(v86[174], function()
arg:_Refresh()
end)

arg2.Batch:BindStateful(v86[96], function()
arg:_Refresh()
end)

arg:_Refresh()
instance.Parent = parent
return instance
end

index2._New = function(arg, arg2, arg3, arg4)
local obj = setmetatable({
_trove = arg3,
_menu = arg,
_options = arg4.Options,
_cells = {},
Kind = "IconStrip",
Row = arg2,
Value = fn36(arg4),
ValueChanged = arg3:Add(v115.new()),
}, index2)

local height = arg4.Height or 62

arg2:AttachRight(function(arg5, arg6)
return fn37(obj, arg5, arg6, height)
end, nil, nil, arg3)

if arg4.OnChanged ~= nil then
arg3:Add(obj.ValueChanged:Connect(arg4.OnChanged))
end

return obj
end

index2._Refresh = function(arg)
local v119 = v118.get(v86[174])
local Unselected = v118.get("Unselected")

for _, v120 in arg._cells, nil, nil do
local backgroundTransparency = 1
local v121

if v120.Name ~= arg.Value then
v121 = Unselected
else
backgroundTransparency = v86[186]
v121 = v119
end

v120.Icon.ImageColor3 = v121
v120.Label.TextColor3 = v121
v120.Accent.BackgroundTransparency = backgroundTransparency
end
end

index2.Set = function(arg, value, arg2)
if value == arg.Value then
return
end
local flag19 = v86[153]

for _, v119 in arg._options, nil, nil do
if v119.Name == value then
flag19 = true
break
end
end

if not flag19 then
return
end
arg.Value = value
arg:_Refresh()

if not arg2 then
arg.ValueChanged:Fire(value)
end
end

index2.Get = function(arg)
return arg.Value
end

index2.Connect = function(arg, arg2, arg3)
arg._trove:Add(arg2:Connect(arg3))
end

index2.SetVisible = function(arg, arg2)
arg.Row:SetVisible(arg2)
end

index2.Destroy = function(arg)
arg._trove:Destroy()
end

return index2
end

tbl17.R = function()
local r = tbl17.cache.R

if not r then
r = { c = fn35() }
tbl17.cache.R = r
end

return r.c
end
end
do -- S
local function fn35()
local v115 = tbl17.g()
tbl17.k()
tbl17.r()
local v116 = tbl17.x()
tbl17.B()
local v117 = tbl17.A()
local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local color = Color3.fromRGB(255, 255, v86[108])

local function fn36(arg, arg2)
return Color3.new(arg.R * arg2, arg.G * arg2, arg.B * arg2)
end

local index2 = {}
index2.__index = index2

local function fn37(arg, arg2, arg3, arg4)
local backgroundTransparency = v86[63]
local ToggleCircleUnselected = v117.get("ToggleCircleUnselected")
local udim2 = UDim2.fromOffset(v86[155], 2)

if arg3 then
udim2 = UDim2.fromOffset(13, v86[56])
backgroundTransparency = 0
ToggleCircleUnselected = color
end

if arg4 then
arg2.Fill.BackgroundTransparency = backgroundTransparency
arg2.Circle.BackgroundColor3 = ToggleCircleUnselected
arg2.Circle.Position = udim2
return
end

arg._menu:Tween(arg2.Fill, { BackgroundTransparency = backgroundTransparency })
arg._menu:Tween(arg2.Circle, { BackgroundColor3 = ToggleCircleUnselected, Position = udim2 })
end

local function fn38(arg, parent, arg2)
local instance = Instance.new(v86[128])
instance.AnchorPoint = Vector2.new(1, v86[101])
instance.Position = UDim2.fromScale(1, v86[101])
instance.Size = UDim2.fromOffset(32, 20)
instance.BorderSizePixel = 0
instance.BackgroundColor3 = color
instance.Parent = parent
local instance2 = Instance.new(v86[46])
instance2.Rotation = 90
arg2.Batch:BindGradient(instance2, { "ToggleBackgroundUnselected", "GradientDark" })
instance2.Parent = instance
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(1, 0)
uiCorner.Parent = instance
local instance3 = Instance.new(v86[128])
instance3.Size = UDim2.fromScale(1, 1)
instance3.BorderSizePixel = 0
instance3.BackgroundColor3 = v117.get("Accent")
instance3.BackgroundTransparency = v86[63]
instance3.Parent = instance
local uiCorner2 = Instance.new("UICorner")
uiCorner2.CornerRadius = UDim.new(1, v86[186])
uiCorner2.Parent = instance3
local frame = Instance.new("Frame")
frame.Position = UDim2.fromOffset(v86[155], 2)
frame.Size = UDim2.fromOffset(16, 16)
frame.BorderSizePixel = v86[186]
frame.BackgroundColor3 = v117.get("ToggleCircleUnselected")
frame.Parent = instance
local uiCorner3 = Instance.new("UICorner")
uiCorner3.CornerRadius = UDim.new(1, v86[186])
uiCorner3.Parent = frame
local rt = { Fill = instance3, Circle = frame }
arg._rt = rt
local frame2 = arg.Row.Frame

if frame2 ~= nil then
v116.connectClick(arg2.Trove, frame2, function()
arg:Set(not arg.Value)
end)

v116.connectPress(arg2.Trove, frame2, function()
if arg.Value then
local v118 = v86[105]
arg._menu:Tween(instance3, { BackgroundColor3 = fn36(v117.get("Accent"), v118) }, tweenInfo)
end
end, function()
if arg.Value then
arg._menu:Tween(instance3, { BackgroundColor3 = v117.get(v86[139]) }, tweenInfo)
end
end)
end

arg2.Trove:Connect(arg._menu.AccentChanged, function(arg3)
arg._menu:Tween(instance3, { BackgroundColor3 = arg3 })
end)

arg2.Batch:BindStateful("ToggleCircleUnselected", function(backgroundColor3)
if not arg.Value then
frame.BackgroundColor3 = backgroundColor3
end
end)

arg2.Trove:Connect(arg.ValueChanged, function(arg3)
fn37(arg, rt, arg3, v86[153])
end)

fn37(arg, rt, arg.Value, true)
return instance
end

index2._New = function(arg, arg2, arg3, arg4)
local obj = setmetatable({
_trove = arg3,
_menu = arg,
Kind = "Toggle",
Row = arg2,
Value = arg4.Default == true,
Changed = arg3:Add(v115.new()),
ValueChanged = arg3:Add(v115.new()),
_onChanged = arg4.OnChanged or function()
end,
_rt = nil,
}, index2)

arg2:AttachRight(function(arg5, arg6)
return fn38(obj, arg5, arg6)
end, 32, nil, arg3)

return obj
end

index2.Set = function(arg, value, arg2)
local v118 = v86[116]
if type(value) ~= v118 or value == arg.Value then
return
end
arg.Value = value
arg.ValueChanged:Fire(value)

if not arg2 then
arg._onChanged(value)
arg.Changed:Fire(value)
end
end

index2.SetLabel = function(arg, arg2)
arg.Row:SetLabel(arg2)
return arg
end

index2.SetTooltip = function(arg, arg2)
arg.Row:SetTooltip(arg2)
return arg
end

index2.SetVisible = function(arg, arg2)
arg.Row:SetVisible(arg2)
end

index2.OnChanged = function(arg, arg2)
arg._trove:Connect(arg.Changed, arg2)
return arg
end

index2.Connect = function(arg, arg2, arg3)
arg._trove:Connect(arg2, arg3)
return arg
end

index2.Destroy = function(arg)
arg._trove:Destroy()
end

return index2
end

tbl17.S = function()
local s = tbl17.cache.S

if not s then
local s2 = { c = fn35() }
tbl17.cache.S = s2
s = s2
end

return s.c
end
end
do -- T
local function fn35()
local v115 = tbl17.g()
tbl17.k()
tbl17.r()
local v116 = tbl17.H()
local v117 = tbl17.s()
local v118 = tbl17.u()
local v119 = tbl17.x()
local v120 = tbl17.G()
local v121 = tbl17.B()
local v122 = tbl17.A()
local v123 = tbl17.S()
local v124 = tbl17.w()
local index2 = {}
index2.__index = index2

local function fn36(arg)
if typeof(arg) == "EnumItem" then
local v125 = v124.KeyNames[arg]
if type(v125) == "string" then
return v125
end
return arg.Name
end

if type(arg) == "string" then
return arg
end
return "None"
end

local function fn37(arg)
local panel = arg._panel

if panel ~= nil then
panel.KeyValue.Text = "Key: " .. fn36(arg.Value.Key)
end
end

local function fn38(arg)
local active = arg.Active or arg.Value.Mode == v86[21]
local featureEnabled = arg.ShowInList and arg.FeatureEnabled
local hud = arg._hud

if hud ~= nil then
hud:SetKeyText(fn36(arg.Value.Key))
hud:SetMode(arg.Value.Mode)
hud:SetActiveAppearance(active)
hud:SetEnabled(featureEnabled)
end

local mobile = arg._mobile

if mobile ~= nil then
mobile:SetMode(arg.Value.Mode)
mobile:SetActive(active)
mobile:SetVisible(featureEnabled)
end
end

local function createTextLabel(arg, parent, arg2)
local textButton = Instance.new("TextButton")
textButton.BackgroundTransparency = v86[63]
textButton.Size = UDim2.new(1, 0, 0, 20)
textButton.BorderSizePixel = 0
textButton.AutomaticSize = Enum.AutomaticSize.Y
textButton.Text = ""
textButton.AutoButtonColor = false
textButton.LayoutOrder = 0
textButton.Parent = parent
local textLabel = Instance.new("TextLabel")
textLabel.FontFace = v117.Medium
textLabel.Text = "Keybind"
textLabel.AnchorPoint = Vector2.new(0, 0.5)
textLabel.BackgroundTransparency = 1
textLabel.Position = UDim2.fromScale(0, v86[101])
textLabel.BorderSizePixel = v86[186]
textLabel.AutomaticSize = Enum.AutomaticSize.XY
textLabel.TextSize = 16
arg2.Batch:Bind(textLabel, v86[167], "TextColor")
textLabel.Parent = textButton
local textButton2 = Instance.new("TextButton")
textButton2.AnchorPoint = Vector2.new(1, v86[186])
textButton2.Position = UDim2.new(1, v86[186], 0, 1)
textButton2.Size = UDim2.fromOffset(2, v86[61])
textButton2.BorderSizePixel = v86[186]
textButton2.AutomaticSize = Enum.AutomaticSize.X
textButton2.Text = ""
textButton2.AutoButtonColor = v86[153]
arg2.Batch:Bind(textButton2, "BackgroundColor3", "Background")
textButton2.Parent = textButton
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 5)
uiCorner.Parent = textButton2
local uiStroke = Instance.new("UIStroke")
uiStroke.BorderOffset = UDim.new(v86[186], -v86[63])
uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
arg2.Batch:Bind(uiStroke, "Color", "Outline")
uiStroke.Parent = textButton2
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
uiListLayout.FillDirection = Enum.FillDirection.Horizontal
uiListLayout.Padding = UDim.new(v86[186], 10)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = textButton2
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingBottom = UDim.new(0, -1)
uiPadding.PaddingLeft = UDim.new(0, 5)
uiPadding.PaddingRight = UDim.new(v86[186], 5)
uiPadding.Parent = textButton2
local textLabel2 = Instance.new("TextLabel")
textLabel2.FontFace = v117.Medium
textLabel2.TextColor3 = v122.get("TextColor")
textLabel2.Text = ""
textLabel2.AnchorPoint = Vector2.new(0, 0.5)
textLabel2.BackgroundTransparency = 1
textLabel2.Position = UDim2.new(0, 5, v86[101], 0)
textLabel2.BorderSizePixel = 0
textLabel2.AutomaticSize = Enum.AutomaticSize.XY
textLabel2.TextSize = 16
textLabel2.Parent = textButton2
local instance = Instance.new(v86[113])
instance.PaddingBottom = UDim.new(0, v86[56])
instance.Parent = textLabel2

v119.connectClick(arg2.Trove, textButton2, function()
arg:StartCapture()
end)

return textLabel2
end

local function fn39(arg)
local panel = arg._panel
if panel ~= nil then
return panel
end
local rt = arg._rt
if rt == nil then
return nil
end
local menu = arg._menu
local gear = rt.Gear
local n = v86[17]

if v118.IsMobile() then
n = 240
end

local v125 = v120.new(menu, arg._trove, {
Trigger = gear,
Size = UDim2.fromOffset(n, 0),
ParentEntry = arg._parentOverlay,
Place = v120.placeBelow(2, 2),
OnToggle = function(arg2)
local n33 = v86[186]

if arg2 then
n33 = 180
end

menu:Tween(gear, { Rotation = n33 })

if arg2 then
local panel2 = arg._panel

if panel2 ~= nil then
panel2.Scroll.CanvasPosition = Vector2.zero
end
end
end,
})

local v126, v127 = v125:AttachScrollingList(n)
local v128 = v125:RealizeCtx()
local v129 = createTextLabel(arg, v127, v128)
local v130 = v121.new(menu, { Label = v86[97], Height = v86[9] })

local tbl18 = {
Label = "Show in list",
Default = arg.ShowInList,
OnChanged = function(arg2)
arg:SetShowInList(arg2)
end,
}

local v131 = v123._New(menu, v130, arg._trove:Extend(), tbl18)
v130:Realize(v127, v128, 2)
local v132 = nil

if v118.WantsMobileButtons() then
local v133 = v121.new(menu, { Label = v86[112], Height = 20 })

local tbl19 = {
Label = v86[112],
Default = arg.Invisible,
OnChanged = function(arg2)
arg:SetInvisible(arg2)
end,
}

v132 = v123._New(menu, v133, arg._trove:Extend(), tbl19)
v133:Realize(v127, v128, v86[155])
end

local v133 = v121.new(menu, { Label = v86[55], Height = 24 })

local tbl19 = {
Label = "Mode",
Options = arg.Modes,
Default = arg.Value.Mode,
OnChanged = function(arg2)
local v134 = v86[165]

if type(arg2) == v134 then
arg:Set({ Key = arg.Value.Key, Mode = arg2 })
end
end,
}

local v134 = v116._New(menu, v133, arg._trove:Extend(), tbl19)
v133:Realize(v127, v128, v86[26])

local panel2 = {
Popup = v125,
Scroll = v126,
KeyValue = v129,
ShowToggle = v131,
InvisibleToggle = v132,
ModeDropdown = v134,
}

arg._panel = panel2
fn37(arg)
return panel2
end

local function createImageButton(arg, parent, arg2)
local imageButton = Instance.new("ImageButton")
imageButton.Image = "rbxassetid://127083575814915"
imageButton.BackgroundTransparency = 1
imageButton.AnchorPoint = Vector2.new(1, 0.5)
imageButton.Position = UDim2.fromScale(1, 0.5)
imageButton.Size = UDim2.fromOffset(16, 16)
imageButton.BorderSizePixel = 0
imageButton.AutoButtonColor = false
arg2.Batch:Bind(imageButton, "ImageColor3", "TextColor")
imageButton.Parent = parent
arg._rt = { Gear = imageButton }
arg._parentOverlay = arg2.ParentOverlay

v119.connectClick(arg2.Trove, imageButton, function()
local v125 = fn39(arg)

if v125 ~= nil then
v125.Popup:Toggle()
end
end)

return imageButton
end

index2._New = function(arg, arg2, arg3, arg4)
local default = arg4.Default
local str7 = "Toggle"
local key = nil

if default ~= nil then
key = default.Key

if default.Mode ~= nil then
str7 = default.Mode
end
end

local obj = setmetatable({
_trove = arg3,
_menu = arg,
Kind = v86[73],
Row = arg2,
Modes = arg4.Modes or { "Hold", "Toggle", "Always" },
Value = { Key = key, Mode = str7 },
Active = false,
FeatureEnabled = false,
ShowInList = arg4.InKeybindList == true,
Invisible = v86[153],
ListLabel = arg4.ListLabel or arg4.Label or "Keybind",
Capturing = v86[153],
Changed = arg3:Add(v115.new()),
ValueChanged = arg3:Add(v115.new()),
ActiveChanged = arg3:Add(v115.new()),
ShowInListChanged = arg3:Add(v115.new()),
InvisibleChanged = arg3:Add(v115.new()),
_onChanged = arg4.OnChanged or function()
end,
_cancelCapture = nil,
_rt = nil,
_panel = nil,
_parentOverlay = nil,
_hud = nil,
_mobile = nil,
}, index2)

local v125 = arg:AddKeybindHudEntry()

if v125 ~= nil then
obj._hud = v125
v125:SetLabel(obj.ListLabel)
arg3:Add(v125)
end

local v126 = arg:RegisterMobileButton(arg4.RegistrationKey or obj.ListLabel, obj.ListLabel, obj.Value.Mode, function(arg5)
obj:SetActive(arg5)
end)

if v126 ~= nil then
obj._mobile = v126
arg3:Add(v126)
end

fn38(obj)

arg2:AttachRight(function(arg5, arg6)
return createImageButton(obj, arg5, arg6)
end, v86[13], nil, arg3)

return obj
end

index2._BindConfigMap = function(arg, arg2, arg3)
local flag19 = false

local function fn40(arg4, arg5, arg6, arg7)
if arg4 == nil then
return
end

local function fn41(arg8)
if arg8 == nil then
return
end
flag19 = v86[34]
arg7(arg8)
flag19 = v86[153]
end

fn41(arg2:Get(arg4))

arg._trove:Connect(arg5, function()
if flag19 then
return
end
arg2:Set(arg4, arg6())
end)

arg._trove:Connect(arg2:Changed(arg4, v86[34]), function(arg8)
if flag19 or arg8 == arg6() then
return
end
fn41(arg8)
end)
end

fn40(arg3.Key, arg.Changed, function()
local key = arg.Value.Key
if key == nil then
return v86[75]
end
return key
end, function(arg4)
if typeof(arg4) == "EnumItem" then
arg:SetKey(arg4)
elseif type(arg4) == "string" then
local v125 = arg
local setKey = v125.SetKey
local v126 = v124.deserializeKey(arg4)
setKey(v125, v126)
end
end)

fn40(arg3.Mode, arg.Changed, function()
return arg.Value.Mode
end, function(arg4)
if type(arg4) == "string" then
arg:SetMode(arg4)
end
end)

fn40(arg3.Active, arg.ActiveChanged, function()
return arg.Active
end, function(arg4)
arg:SetActive(arg4 == v86[34])
end)

fn40(arg3.ShowInList, arg.ShowInListChanged, function()
return arg.ShowInList
end, function(arg4)
arg:SetShowInList(arg4 == v86[34])
end)

fn40(arg3.Invisible, arg.InvisibleChanged, function()
return arg.Invisible
end, function(arg4)
arg:SetInvisible(arg4 == true)
end)
end

index2.StartCapture = function(arg)
local panel = arg._panel
if panel == nil then
return
end
arg.Capturing = v86[34]
panel.KeyValue.Text = "Key: ..."
arg._menu:Tween(panel.KeyValue, { TextColor3 = v122.get("Accent") })

arg._cancelCapture = arg._menu:CaptureKey(function(arg2)
arg.Capturing = false
arg._cancelCapture = nil
arg._menu:Tween(panel.KeyValue, { TextColor3 = v122.get("TextColor") })
if arg2 == nil then
fn37(arg)
return
end
arg:Set({ Key = arg2, Mode = arg.Value.Mode })
end)
end

index2.Set = function(arg, arg2, arg3)
local key = arg2.Key
local mode = arg2.Mode or arg.Value.Mode
if key == arg.Value.Key and mode == arg.Value.Mode then
return
end
arg.Value = { Key = key, Mode = mode }
fn37(arg)
fn38(arg)
local panel = arg._panel

if panel ~= nil then
panel.ModeDropdown:Set(mode, true)
end

arg.ValueChanged:Fire(arg.Value)

if not arg3 then
arg._onChanged(arg.Value)
arg.Changed:Fire(arg.Value)
end
end

index2.SetKey = function(arg, arg2, arg3)
arg:Set({ Key = arg2, Mode = arg.Value.Mode }, arg3)
end

index2.SetMode = function(arg, arg2, arg3)
arg:Set({ Key = arg.Value.Key, Mode = arg2 }, arg3)
end

index2.SetActive = function(arg, active, arg2)
if arg.Active == active then
return
end
arg.Active = active
fn38(arg)
arg.ActiveChanged:Fire(active)

if not arg2 then
arg.Changed:Fire(arg.Value)
end
end

index2.SetFeatureEnabled = function(arg, featureEnabled)
if arg.FeatureEnabled == featureEnabled then
return
end
arg.FeatureEnabled = featureEnabled
fn38(arg)
end

index2.SetShowInList = function(arg, arg2, arg3)
local showInList = arg2 == true
if arg.ShowInList == showInList then
return
end
arg.ShowInList = showInList
fn38(arg)
local panel = arg._panel

if panel ~= nil then
panel.ShowToggle:Set(showInList, true)
end

if not arg3 then
arg.ShowInListChanged:Fire(showInList)
end
end

index2.SetInvisible = function(arg, arg2, arg3)
local invisible = arg2 == true
if arg.Invisible == invisible then
return
end
arg.Invisible = invisible
local mobile = arg._mobile

if mobile ~= nil then
mobile:SetInvisible(invisible)
end

local panel = arg._panel

if panel ~= nil then
local invisibleToggle = panel.InvisibleToggle

if invisibleToggle ~= nil then
invisibleToggle:Set(invisible, v86[34])
end
end

if not arg3 then
arg.InvisibleChanged:Fire(invisible)
end
end

index2.SetLabel = function(arg, arg2)
arg.Row:SetLabel(arg2)
return arg
end

index2.SetTooltip = function(arg, arg2)
arg.Row:SetTooltip(arg2)
return arg
end

index2.SetVisible = function(arg, arg2)
arg.Row:SetVisible(arg2)
end

index2.OnChanged = function(arg, arg2)
arg._trove:Connect(arg.Changed, arg2)
return arg
end

index2.Connect = function(arg, arg2, arg3)
arg._trove:Connect(arg2, arg3)
return arg
end

index2.Destroy = function(arg)
local cancelCapture = arg._cancelCapture

if cancelCapture ~= nil then
cancelCapture()
end

arg._trove:Destroy()
end

return index2
end

tbl17.T = function()
local t = tbl17.cache.T

if not t then
t = { c = fn35() }
tbl17.cache.T = t
end

return t.c
end
end
do -- U
local function fn35()
tbl17.g()
tbl17.k()
tbl17.r()
local v115 = tbl17.s()
tbl17.B()
local index2 = {}
index2.__index = index2

local function createTextButton(arg, parent, arg2)
local textButton = Instance.new("TextButton")
textButton.BackgroundTransparency = 1
textButton.Size = UDim2.new(1, 0, 0, v86[61])
textButton.BorderSizePixel = 0
textButton.AutomaticSize = Enum.AutomaticSize.Y
textButton.Text = ""
textButton.AutoButtonColor = false
textButton.Parent = parent
local textLabel = Instance.new("TextLabel")
textLabel.RichText = v86[34]
textLabel.FontFace = v115.Medium
textLabel.Text = arg.Label
textLabel.AnchorPoint = Vector2.new(v86[186], 0.5)
textLabel.BackgroundTransparency = 1
textLabel.Position = UDim2.fromScale(v86[186], 0.5)
textLabel.BorderSizePixel = 0
textLabel.AutomaticSize = Enum.AutomaticSize.Y
textLabel.Size = UDim2.fromScale(1, 0)
textLabel.TextWrapped = v86[34]
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.TextSize = arg._textSize or 16

if arg._textColor ~= nil then
textLabel.TextColor3 = arg._textColor
else
arg2.Batch:Bind(textLabel, "TextColor3", "TextColor")
end

textLabel.Parent = textButton
arg._label = textLabel
return textButton
end

index2._New = function(arg, arg2, arg3, arg4)
local obj = setmetatable({
_trove = arg3,
_menu = arg,
Kind = "Label",
Row = arg2,
Label = arg4.Label or "",
_textColor = arg4.TextColor,
_textSize = arg4.TextSize,
_label = nil,
}, index2)

arg2:AttachRight(function(arg5, arg6)
return createTextButton(obj, arg5, arg6)
end, nil, nil, arg3)

return obj
end

index2.SetLabel = function(arg, label)
arg.Label = label
local label2 = arg._label

if label2 ~= nil then
label2.Text = label
end

return arg
end

index2.SetColor = function(arg, textColor)
local v116 = v86[115]
if typeof(textColor) ~= v116 then
return arg
end
arg._textColor = textColor
local label = arg._label

if label ~= nil then
label.TextColor3 = textColor
end

return arg
end

index2.SetTooltip = function(arg, arg2)
arg.Row:SetTooltip(arg2)
return arg
end

index2.SetVisible = function(arg, arg2)
arg.Row:SetVisible(arg2)
end

index2.Connect = function(arg, arg2, arg3)
arg._trove:Connect(arg2, arg3)
return arg
end

index2.Destroy = function(arg)
arg._trove:Destroy()
end

return index2
end

tbl17.U = function()
local u = tbl17.cache.U

if not u then
u = { c = fn35() }
tbl17.cache.U = u
end

return u.c
end
end
do -- V
local function fn35()
local v115 = tbl17.g()
tbl17.k()
local v116 = tbl17.F()
tbl17.r()
local v117 = tbl17.x()
tbl17.B()
local v118 = tbl17.A()
local index2 = {}
index2.__index = index2

local function fn36(arg, arg2)
local value = arg.Value
if type(value) == "table" then
return table.find(value, arg2) ~= nil
end
return value == arg2
end

local function fn37(arg, arg2, arg3, arg4)
local Unselected = v118.get("Unselected")
local imageTransparency = v86[63]
local n = v86[175]

if arg3 then
Unselected = v118.get("TextColor")
n = 29
imageTransparency = 0
end

arg2.Tick.ImageColor3 = v118.get(v86[174])
local udim = UDim.new(v86[186], n)

if arg4 then
arg2.Title.TextColor3 = Unselected
arg2.Tick.ImageTransparency = imageTransparency
arg2.Padding.PaddingLeft = udim
return
end

arg._menu:Tween(arg2.Title, { TextColor3 = Unselected })
arg._menu:Tween(arg2.Tick, { ImageTransparency = imageTransparency })
arg._menu:Tween(arg2.Padding, { PaddingLeft = udim })
end

local function fn38(arg, arg2)
local rt = arg._rt
if rt == nil then
return
end

for k, v119 in rt.Rows, nil, nil do
local v120 = arg.Options[k]
fn37(arg, v119, v120 ~= nil and fn36(arg, v120), arg2)
end
end

local function fn39(arg, arg2)
local rt = arg._rt
if rt == nil then
return
end
local str7 = arg2:lower()
rt.Scroll.CanvasPosition = Vector2.zero

for _, v119 in rt.Rows, nil, nil do
v119.Title.Visible = v119.Title.Text:lower():find(str7, 1, true) ~= nil
end
end

local function fn40(arg, arg2)
local v119 = arg.Options[arg2]
if v119 == nil then
return
end

if not arg.Multi then
arg:Set(v119)
return
end
local tbl18 = {}
local v120 = v86[68]

if type(arg.Value) == v120 then
tbl18 = table.clone(arg.Value)
end

local v121 = table.find(tbl18, v119)

if v121 ~= nil then
table.remove(tbl18, v121)
else
table.insert(tbl18, v119)
end

arg:Set(tbl18)
end

local function fn41(arg, arg2, layoutOrder)
local instance = Instance.new(v86[135])
instance.BackgroundTransparency = v86[63]
instance.TextColor3 = v118.get("Unselected")
instance.Text = ""
instance.Size = UDim2.fromScale(1, 0)
instance.ClipsDescendants = true
instance.TextXAlignment = Enum.TextXAlignment.Left
instance.BorderSizePixel = 0
instance.AutomaticSize = Enum.AutomaticSize.XY
instance.TextSize = 16
instance.FontFace = arg._menu.Fonts.Main
instance.LayoutOrder = layoutOrder
instance.Parent = arg2.Scroll
local instance2 = Instance.new(v86[113])
instance2.PaddingTop = UDim.new(0, 5)
instance2.PaddingBottom = UDim.new(0, 5)
instance2.PaddingRight = UDim.new(0, 5)
instance2.PaddingLeft = UDim.new(0, 5)
instance2.Parent = instance
local imageLabel = Instance.new("ImageLabel")
imageLabel.ImageTransparency = v86[63]
imageLabel.Image = "rbxassetid://73347151382921"
imageLabel.ImageColor3 = v118.get(v86[174])
imageLabel.BackgroundTransparency = v86[63]
imageLabel.AnchorPoint = Vector2.new(0, 0.5)
imageLabel.Position = UDim2.new(0, -22, v86[101], v86[186])
imageLabel.Size = UDim2.fromOffset(14, 14)
imageLabel.BorderSizePixel = v86[186]
imageLabel.Parent = instance

v117.connectClick(arg._trove, instance, function()
fn40(arg, layoutOrder)
end)

return { Title = instance, Padding = instance2, Tick = imageLabel }
end

local function fn42(arg)
local rt = arg._rt
if rt == nil then
return
end
local rows = rt.Rows
local options = arg.Options

for k, v119 in options, nil, nil do
local v120 = rows[k]

if v120 == nil then
v120 = fn41(arg, rt, k)
rows[k] = v120
end

if v120.Title.Text ~= v119 then
v120.Title.Text = v119
end

if not v120.Title.Visible then
v120.Title.Visible = true
end
end

for i = #rows, #options + 1, -1 do
rows[i].Title:Destroy()
rows[i] = nil
end
end

local function fn43(arg, arg2, arg3)
local menu = arg._menu
local instance = Instance.new(v86[128])
instance.LayoutOrder = -1
instance.Size = UDim2.new(1, 0, 0, 26)
instance.ClipsDescendants = true
instance.BorderSizePixel = 0
arg3.Batch:Bind(instance, "BackgroundColor3", "Background")
instance.Parent = arg2.Root
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 5)
uiCorner.Parent = instance
local uiStroke = Instance.new("UIStroke")
arg3.Batch:Bind(uiStroke, "Color", "Outline")
uiStroke.Parent = instance
local textBox = Instance.new("TextBox")
textBox.PlaceholderText = v86[190]
textBox.PlaceholderColor3 = v118.get("Unselected")
textBox.FontFace = menu.Fonts.Main
textBox.Text = ""
textBox.AnchorPoint = Vector2.new(v86[186], 0.5)
textBox.Position = UDim2.new(0, v86[54], 0.5, 0)
textBox.Size = UDim2.new(1, -12, 1, v86[186])
textBox.BackgroundTransparency = 1
textBox.BorderSizePixel = 0
textBox.TextSize = 14
textBox.TextXAlignment = Enum.TextXAlignment.Left
textBox.ClearTextOnFocus = false
textBox.Active = true
arg3.Batch:Bind(textBox, "TextColor3", "TextColor")
textBox.Parent = instance
arg2.SearchInput = textBox

arg3.Trove:Connect(textBox:GetPropertyChangedSignal(v86[80]), function()
fn39(arg, textBox.Text)
end)
end

local function fn44(arg, parent, arg2)
local instance = Instance.new(v86[92])
instance.BackgroundTransparency = v86[63]
instance.Size = UDim2.new(1, 0, v86[186], 24)
instance.BorderSizePixel = 0
instance.AutomaticSize = Enum.AutomaticSize.Y
instance.Text = ""
instance.AutoButtonColor = false
instance.Parent = parent
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(v86[186], v86[13])
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = instance
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.ScrollBarImageTransparency = 1
scrollingFrame.ScrollBarThickness = v86[186]
scrollingFrame.Selectable = false
scrollingFrame.Size = UDim2.new(1, 0, 0, arg.Height)
scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollingFrame.CanvasSize = UDim2.fromOffset(0, 0)
scrollingFrame.BackgroundColor3 = Color3.fromRGB(v86[108], 255, 255)
scrollingFrame.BorderSizePixel = 0
arg2.Batch:Bind(scrollingFrame, "ScrollBarImageColor3", "Accent")
scrollingFrame.Parent = instance
local instance2 = Instance.new(v86[46])
instance2.Rotation = v86[45]
v116.bindSurfaceGradient(arg2.Batch, instance2, { v86[187], "GradientDark" })
instance2.Parent = scrollingFrame
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 5)
uiCorner.Parent = scrollingFrame
local uiStroke = Instance.new("UIStroke")
arg2.Batch:Bind(uiStroke, "Color", v86[120])
uiStroke.Parent = scrollingFrame
local uiListLayout2 = Instance.new("UIListLayout")
uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout2.Parent = scrollingFrame
local rt = { Root = instance, Scroll = scrollingFrame, SearchInput = nil, Rows = {} }
arg._rt = rt

if arg.Search then
fn43(arg, rt, arg2)
end

fn42(arg)
fn38(arg, v86[34])
return instance
end

local function fn45(arg, arg2)
local tbl18 = {}

for _, v119 in arg, nil, nil do
if table.find(arg2, v119) ~= nil then
table.insert(tbl18, v119)
end
end

return tbl18
end

local function fn46(arg, arg2)
if #arg ~= #arg2 then
return false
end

for k, v119 in arg, nil, nil do
if arg2[k] ~= v119 then
return false
end
end

return true
end

local function fn47(arg, arg2, arg3, arg4, arg5, arg6, arg7)
local obj = setmetatable({
_trove = arg3,
_menu = arg,
Kind = "List",
Row = arg2,
Multi = arg5,
Search = arg4.Search == true,
Height = arg4.Height or v86[110],
Options = table.clone(arg4.Options or {}),
Value = arg6,
Changed = arg3:Add(v115.new()),
ValueChanged = arg3:Add(v115.new()),
_onChanged = arg7,
_rt = nil,
}, index2)

arg2:AttachRight(function(arg8, arg9)
return fn44(obj, arg8, arg9)
end, nil, nil, arg3)

return obj
end

index2._New = function(arg, arg2, arg3, arg4)
local options = arg4.Options or {}
local default = arg4.Default

if not (default ~= nil and table.find(options, default) ~= nil) then
default = nil

if arg4.SelectFirst ~= false then
default = options[1]
end
end

local onChanged = arg4.OnChanged

local function fn48()
end

if onChanged ~= nil then
fn48 = function(arg5)
onChanged(arg5)
end
end

return (fn47(arg, arg2, arg3, arg4, false, default, fn48))
end

index2._NewMulti = function(arg, arg2, arg3, arg4)
local v119 = fn45(arg4.Options or {}, arg4.Default or {})
local onChanged = arg4.OnChanged

local function fn48()
end

if onChanged ~= nil then
fn48 = function(arg5)
onChanged(arg5)
end
end

return (fn47(arg, arg2, arg3, arg4, v86[34], v119, fn48))
end

index2.Set = function(arg, value, arg2)
local flag19 = arg2 == v86[34]

if arg.Multi then
local tbl18 = {}

if type(value) ~= "table" then
local v119 = v86[165]

if type(value) ~= v119 then
value = tbl18
else
value = { value }
end
end

arg.Value = fn45(arg.Options, value)
else
local flag20 = type(value) == "string" and table.find(arg.Options, value) ~= nil
local v119 = nil

if not flag20 then
value = v119
end

arg.Value = value
end

fn38(arg, flag19)
arg.ValueChanged:Fire(arg.Value)

if not arg2 then
arg._onChanged(arg.Value)
arg.Changed:Fire(arg.Value)
end
end

index2.SetOptions = function(arg, arg2)
local value = arg.Value
arg.Options = table.clone(arg2 or {})
fn42(arg)
local rt = arg._rt
if rt ~= nil and rt.SearchInput ~= nil then
fn39(arg, rt.SearchInput.Text)
end
arg:Set(value, true)
local flag19 = value ~= arg.Value
local multi = arg.Multi

if multi then
local v119 = v86[68]
multi = type(value) == v119
end

if multi and type(arg.Value) == "table" then
flag19 = not fn46(value, arg.Value)
end

if flag19 then
arg._onChanged(arg.Value)
arg.Changed:Fire(arg.Value)
end
end

index2.Add = function(arg, arg2)
if type(arg2) ~= "string" or table.find(arg.Options, arg2) ~= nil then
return
end
local v119 = table.clone(arg.Options)
table.insert(v119, arg2)
arg:SetOptions(v119)
end

index2.Remove = function(arg, arg2)
local v119 = table.find(arg.Options, arg2)
if v119 == nil then
return
end
local v120 = table.clone(arg.Options)
table.remove(v120, v119)
arg:SetOptions(v120)
end

index2.SetLabel = function(arg, arg2)
arg.Row:SetLabel(arg2)
return arg
end

index2.SetTooltip = function(arg, arg2)
arg.Row:SetTooltip(arg2)
return arg
end

index2.SetVisible = function(arg, arg2)
arg.Row:SetVisible(arg2)
end

index2.OnChanged = function(arg, arg2)
arg._trove:Connect(arg.Changed, arg2)
return arg
end

index2.Connect = function(arg, arg2, arg3)
arg._trove:Connect(arg2, arg3)
return arg
end

index2.Destroy = function(arg)
arg._trove:Destroy()
end

return index2
end

tbl17.V = function()
local v115 = tbl17.cache.V

if not v115 then
local v116 = { c = fn35() }
tbl17.cache.V = v116
v115 = v116
end

return v115.c
end
end
do -- W
local function fn35()
local v115 = tbl17.F()
local v116 = tbl17.v()
tbl17.A()

return {
nextLayoutOrder = function(arg)
local n = 0

for _, v117 in arg:GetChildren() do
if v117:IsA("GuiObject") then
n += v86[63]
end
end

return n
end,
box = function(arg, parent)
local frame = Instance.new("Frame")
frame.BackgroundTransparency = 0
frame.Size = UDim2.fromScale(1, 0)
frame.BorderSizePixel = 0
frame.AutomaticSize = Enum.AutomaticSize.Y
frame.BackgroundColor3 = Color3.fromRGB(255, v86[108], 255)
frame.Parent = parent
local uiGradient = Instance.new("UIGradient")
uiGradient.Rotation = 90
v115.bindSurfaceGradient(arg, uiGradient, { "GradientMid", v86[70] })
uiGradient.Parent = frame
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 6)
uiCorner.Parent = frame
local instance = Instance.new(v86[85])
arg:Bind(instance, v86[27], "Outline")
instance.Parent = frame
return frame
end,
elementsContainer = function(parent, position, size)
local section = v116.get().Section
local frame = Instance.new("Frame")
frame.BackgroundTransparency = 1
frame.Position = position or UDim2.fromOffset(section.InnerPadding, section.InnerPadding)
frame.Size = size or UDim2.new(v86[63], -section.InnerPadding * v86[56], v86[186], 0)
frame.BorderSizePixel = 0
frame.AutomaticSize = Enum.AutomaticSize.Y
frame.Parent = parent
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(v86[186], section.ElementGap)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = frame
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingBottom = UDim.new(0, section.InnerPadding)
uiPadding.Parent = frame
return frame
end,
}
end

tbl17.W = function()
local w = tbl17.cache.W

if not w then
w = { c = fn35() }
tbl17.cache.W = w
end

return w.c
end
end
do -- X
local function fn35()
tbl17.g()
tbl17.k()
local v115 = tbl17.F()
tbl17.r()
local v116 = tbl17.s()
local v117 = tbl17.v()
tbl17.B()
local v118 = tbl17.W()
local v119 = tbl17.A()
local index2 = {}
index2.__index = index2

index2.new = function(arg, arg2, arg3, arg4)
return setmetatable({
_trove = arg2:Extend(),
_menu = arg,
_resolveParent = arg4,
Sections = arg3,
_activeIndex = 1,
_realized = false,
_ctx = nil,
_tabs = {},
_rootFrame = nil,
}, index2)
end

local function fn36(arg, parent, arg2, layoutOrder)
local section = v117.get().Section
local frame = Instance.new("Frame")
frame.LayoutOrder = layoutOrder or v118.nextLayoutOrder(parent)
frame.BackgroundTransparency = 1
frame.Size = UDim2.fromScale(1, 0)
frame.BorderSizePixel = v86[186]
frame.AutomaticSize = Enum.AutomaticSize.Y
frame.Parent = parent
arg._rootFrame = frame
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingTop = UDim.new(0, 3)
uiPadding.Parent = frame
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, v86[54])
uiCorner.Parent = frame
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, section.TitleGap)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = frame
local v120 = v118.box(arg2, frame)
local frame2 = Instance.new("Frame")
frame2.BackgroundTransparency = 0
frame2.ClipsDescendants = true
frame2.Size = UDim2.new(1, 0, 0, section.MultiHeaderHeight)
frame2.BorderSizePixel = v86[186]
frame2.BackgroundColor3 = Color3.fromRGB(v86[108], v86[108], 255)
frame2.Parent = v120
local uiCorner2 = Instance.new("UICorner")
uiCorner2.CornerRadius = UDim.new(0, 6)
uiCorner2.Parent = frame2
local uiGradient = Instance.new("UIGradient")
uiGradient.Rotation = 90
v115.bindSurfaceGradient(arg2, uiGradient, { "GradientTop", "GradientMid" })
uiGradient.Parent = frame2
local frame3 = Instance.new("Frame")
frame3.Position = UDim2.new(0, v86[186], 1, -1)
frame3.Size = UDim2.new(1, v86[186], 0, 1)
frame3.BorderSizePixel = 0
arg2:Bind(frame3, "BackgroundColor3", "Outline")
frame3.Parent = frame2
local instance = Instance.new(v86[128])
instance.BackgroundTransparency = 1
instance.Size = UDim2.fromScale(1, 1)
instance.BorderSizePixel = 0
instance.Parent = frame2
local uiListLayout2 = Instance.new("UIListLayout")
uiListLayout2.Padding = UDim.new(v86[186], section.MultiHeaderGap)
uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout2.FillDirection = Enum.FillDirection.Horizontal
uiListLayout2.Parent = instance
local uiPadding2 = Instance.new("UIPadding")
uiPadding2.PaddingRight = UDim.new(0, section.MultiHeaderPadding)
uiPadding2.PaddingLeft = UDim.new(v86[186], section.MultiHeaderPadding)
uiPadding2.Parent = instance
return v120, instance
end

local function fn37(arg, layoutOrder, arg2, parent, arg3)
local section = v117.get().Section
local udim2 = UDim2.new
local n = -section.InnerPadding * v86[56]
local v120 = v118.elementsContainer(arg2, UDim2.fromOffset(section.InnerPadding, section.MultiPaneTop), udim2(1, n, 0, 0))
v120.Visible = false
local textButton = Instance.new("TextButton")
textButton.BackgroundTransparency = 1
textButton.Size = UDim2.fromScale(0, 1)
textButton.BorderSizePixel = v86[186]
textButton.AutomaticSize = Enum.AutomaticSize.X
textButton.Text = ""
textButton.AutoButtonColor = false
textButton.LayoutOrder = layoutOrder
textButton.Parent = parent
local textLabel = Instance.new("TextLabel")
textLabel.FontFace = v116.SemiBold
textLabel.Text = arg.Sections[layoutOrder].Title
textLabel.TextColor3 = v119.get("Unselected")
textLabel.AnchorPoint = Vector2.new(0, 0.5)
textLabel.BackgroundTransparency = 1
textLabel.Position = UDim2.fromScale(v86[186], v86[101])
textLabel.BorderSizePixel = 0
textLabel.AutomaticSize = Enum.AutomaticSize.X
textLabel.Size = UDim2.fromOffset(0, section.MultiTabTextSize + 5)
textLabel.TextSize = section.MultiTabTextSize
textLabel.Parent = textButton
local frame = Instance.new("Frame")
frame.BackgroundTransparency = 1
frame.Position = UDim2.new(0, 0, v86[63], -v86[155])
frame.Size = UDim2.new(1, 0, 0, 10)
frame.BorderSizePixel = 0
arg3.Batch:Bind(frame, v86[5], v86[139])
frame.Parent = textButton
local instance = Instance.new(v86[98])
instance.CornerRadius = UDim.new(0, 3)
instance.Parent = frame

arg3.Trove:Connect(textButton.MouseButton1Click, function()
arg:_SetActive(layoutOrder)
end)

return { Label = textLabel, Accent = frame, Pane = v120 }
end

index2.Realize = function(arg, arg2)
if arg._realized then
return
end
arg._realized = true
local v120 = arg._trove:Extend()
local v121 = v119.newBatch(v120)
local ctx = { Menu = arg._menu, Trove = v120, Batch = v121 }
arg._ctx = ctx
local v122, v123 = fn36(arg, arg._resolveParent(), v121, arg2)

for k in arg.Sections, nil, nil do
arg._tabs[k] = fn37(arg, k, v122, v123, ctx)
end

v121:BindStateful("TextColor", function(textColor3)
local v124 = arg._tabs[arg._activeIndex]

if v124 ~= nil then
v124.Label.TextColor3 = textColor3
end
end)

v121:BindStateful("Unselected", function(textColor3)
for k, v124 in arg._tabs, nil, nil do
if k ~= arg._activeIndex then
v124.Label.TextColor3 = textColor3
end
end
end)

local v124 = arg._tabs[arg._activeIndex]

if v124 ~= nil then
v124.Label.TextColor3 = v119.get("TextColor")
v124.Accent.BackgroundTransparency = 0
v124.Pane.Visible = true
arg.Sections[arg._activeIndex]:_RealizeAsPane(v124.Pane, ctx)
end
end

index2._SetActive = function(arg, activeIndex)
if activeIndex == arg._activeIndex or arg._tabs[activeIndex] == nil then
return
end
local menu = arg._menu
local v120 = arg._tabs[arg._activeIndex]

if v120 ~= nil then
menu:Tween(v120.Label, { TextColor3 = v119.get(v86[96]) })
menu:Tween(v120.Accent, { BackgroundTransparency = 1 })
v120.Pane.Visible = false
arg.Sections[arg._activeIndex].Opened:Fire(v86[153])
end

arg._activeIndex = activeIndex
local v121 = arg._tabs[activeIndex]
local ctx = arg._ctx

if ctx ~= nil then
arg.Sections[activeIndex]:_RealizeAsPane(v121.Pane, ctx)
end

menu:Tween(v121.Label, { TextColor3 = v119.get("TextColor") })
menu:Tween(v121.Accent, { BackgroundTransparency = 0 })
v121.Pane.Visible = v86[34]
arg.Sections[activeIndex].Opened:Fire(true)
end

index2.SelectPane = function(arg, arg2)
if not arg._realized then
arg:Realize()
end

arg:_SetActive(arg2)
end

index2._SetGridParent = function(arg, parent, layoutOrder)
local rootFrame = arg._rootFrame
if rootFrame == nil then
return
end
rootFrame.LayoutOrder = layoutOrder
rootFrame.Parent = parent
end

index2.SetVisible = function(arg, visible)
local rootFrame = arg._rootFrame

if rootFrame ~= nil then
rootFrame.Visible = visible
end
end

index2.Destroy = function(arg)
local rootFrame = arg._rootFrame

if rootFrame ~= nil then
rootFrame:Destroy()
arg._rootFrame = nil

if n26 >= 4826 then
-- (anti-tamper freeze trap removed)
end
end

arg._trove:Destroy()
end

return index2
end

tbl17.X = function()
local x = tbl17.cache.X

if not x then
x = { c = fn35() }
tbl17.cache.X = x
end

return x.c
end
end
do -- Y
local function fn35()
local v115 = tbl17.g()
tbl17.k()
local v116 = tbl17.F()
tbl17.r()
local v117 = tbl17.s()
local v118 = tbl17.v()
local v119 = tbl17.x()
tbl17.B()
local index2 = {}
index2.__index = index2

local function fn36(arg, arg2)
local tbl18 = {}

for _, v120 in arg2, nil, nil do
if type(v120) == "string" and table.find(arg, v120) ~= nil and table.find(tbl18, v120) == nil then
table.insert(tbl18, v120)
end
end

for _, v120 in arg, nil, nil do
if table.find(tbl18, v120) == nil then
table.insert(tbl18, v120)
end
end

return tbl18
end

local function fn37(arg, arg2, arg3)
local v120 = table.find(arg, arg2)
if v120 == nil then
return false
end
local n = math.clamp(v120 + arg3, 1, #arg)
if n == v120 then
return false
end
table.remove(arg, v120)
table.insert(arg, n, arg2)
return v86[34]
end

local function fn38(arg)
local rt = arg._rt
if rt == nil then
return
end

for k, v120 in rt.Rows, nil, nil do
local layoutOrder = table.find(arg.Order, k) or 0
local autoButtonColor = layoutOrder > v86[63]
local autoButtonColor2 = layoutOrder > v86[186] and layoutOrder < #arg.Order
v120.Object.LayoutOrder = layoutOrder
v120.Index.Text = tostring(layoutOrder)
v120.Up.AutoButtonColor = autoButtonColor
v120.Down.AutoButtonColor = autoButtonColor2
local textTransparency = 0.6

if autoButtonColor then
textTransparency = 0
end

local textTransparency2 = v86[84]

if autoButtonColor2 then
textTransparency2 = 0
end

v120.Up.TextTransparency = textTransparency
v120.Down.TextTransparency = textTransparency2
end
end

local function fn39(arg, arg2)
arg.Value = table.clone(arg.Order)
arg.ValueChanged:Fire(arg.Value)

if not arg2 then
arg._onChanged(arg.Value)
arg.Changed:Fire(arg.Value)
end
end

local function fn40(arg, text, parent, arg2)
local menu = arg._menu
local v120 = v118.get()
local listRowHeight = v120.Row.ListRowHeight
local n = -v86[58]
local isCompact = v120.IsCompact
local n33 = -28
local textSize = 12
local n34 = 22

if isCompact then
n = -v86[53]
n33 = -42
textSize = 14
n34 = 30
end

local frame = Instance.new("Frame")
frame.BackgroundTransparency = 0.5
frame.Size = UDim2.new(1, 0, v86[186], listRowHeight)
frame.BorderSizePixel = v86[186]
arg2.Batch:Bind(frame, "BackgroundColor3", "ElementBackground")
frame.Parent = parent
local instance = Instance.new(v86[98])
instance.CornerRadius = UDim.new(0, v86[26])
instance.Parent = frame
local instance2 = Instance.new(v86[135])
instance2.BackgroundTransparency = 1
instance2.Position = UDim2.fromOffset(8, 0)
instance2.Size = UDim2.new(v86[186], 18, 1, v86[186])
instance2.Text = ""
instance2.TextSize = v86[118]
instance2.TextXAlignment = Enum.TextXAlignment.Left
instance2.FontFace = v117.Medium
arg2.Batch:Bind(instance2, "TextColor3", v86[96])
instance2.Parent = frame
local instance3 = Instance.new(v86[135])
instance3.BackgroundTransparency = 1
instance3.Position = UDim2.fromOffset(30, 0)
instance3.Size = UDim2.new(1, n, 1, 0)
instance3.Text = text
instance3.TextSize = v86[72]
instance3.TextXAlignment = Enum.TextXAlignment.Left
instance3.FontFace = v117.Medium
instance3.TextTruncate = Enum.TextTruncate.AtEnd
arg2.Batch:Bind(instance3, "TextColor3", v86[174])
instance3.Parent = frame
local textButton = Instance.new("TextButton")
textButton.AnchorPoint = Vector2.new(1, 0.5)
textButton.Position = UDim2.new(1, n33, 0.5, 0)
textButton.Size = UDim2.fromOffset(n34, n34)
textButton.BackgroundTransparency = 1
textButton.BorderSizePixel = 0
textButton.Text = "▲"
textButton.TextSize = textSize
textButton.AutoButtonColor = false
textButton.FontFace = menu.Fonts.Main
arg2.Batch:Bind(textButton, v86[167], "TextColor")
textButton.Parent = frame
local textButton2 = Instance.new("TextButton")
textButton2.AnchorPoint = Vector2.new(v86[63], 0.5)
textButton2.Position = UDim2.new(1, -4, 0.5, 0)
textButton2.Size = UDim2.fromOffset(n34, n34)
textButton2.BackgroundTransparency = 1
textButton2.BorderSizePixel = 0
textButton2.Text = "▼"
textButton2.TextSize = textSize
textButton2.AutoButtonColor = v86[153]
textButton2.FontFace = menu.Fonts.Main
arg2.Batch:Bind(textButton2, "TextColor3", "TextColor")
textButton2.Parent = frame

v119.connectClick(arg2.Trove, textButton, function()
if fn37(arg.Order, text, -v86[63]) then
fn38(arg)
fn39(arg)
end
end)

v119.connectClick(arg2.Trove, textButton2, function()
if fn37(arg.Order, text, 1) then
fn38(arg)
fn39(arg)
end
end)

return { Object = frame, Up = textButton, Down = textButton2, Index = instance2 }
end

local function createFrame(arg, parent, arg2)
local frame = Instance.new("Frame")
frame.BackgroundTransparency = 1
frame.Size = UDim2.fromScale(1, v86[186])
frame.BorderSizePixel = 0
frame.AutomaticSize = Enum.AutomaticSize.Y
frame.Parent = parent
local instance = Instance.new(v86[128])
instance.BackgroundColor3 = Color3.fromRGB(v86[108], v86[108], 255)
instance.Size = UDim2.fromScale(1, 0)
instance.AutomaticSize = Enum.AutomaticSize.Y
instance.BorderSizePixel = 0
instance.Parent = frame
local uiGradient = Instance.new("UIGradient")
uiGradient.Rotation = 90
v116.bindSurfaceGradient(arg2.Batch, uiGradient, { "GradientMid", v86[70] })
uiGradient.Parent = instance
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 5)
uiCorner.Parent = instance
local uiStroke = Instance.new("UIStroke")
arg2.Batch:Bind(uiStroke, "Color", "Outline")
uiStroke.Parent = instance
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(v86[186], 1)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = instance
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingTop = UDim.new(0, 4)
uiPadding.PaddingBottom = UDim.new(0, v86[26])
uiPadding.PaddingLeft = UDim.new(v86[186], 4)
uiPadding.PaddingRight = UDim.new(0, v86[26])
uiPadding.Parent = instance
local rt = { Root = frame, Rows = {} }
arg._rt = rt

for _, v120 in arg.Items, nil, nil do
rt.Rows[v120] = fn40(arg, v120, instance, arg2)
end

fn38(arg)
return frame
end

index2._New = function(arg, arg2, arg3, arg4)
local tbl18 = {}

for _, v120 in arg4.Items, nil, nil do
if type(v120) == "string" then
table.insert(tbl18, v120)
end
end

local v120

if arg4.Default ~= nil then
v120 = fn36(tbl18, arg4.Default)
else
v120 = table.clone(tbl18)
end

local obj = setmetatable({
_trove = arg3,
_menu = arg,
Kind = "OrderedList",
Row = arg2,
Items = tbl18,
Order = v120,
Value = table.clone(v120),
Changed = arg3:Add(v115.new()),
ValueChanged = arg3:Add(v115.new()),
_onChanged = arg4.OnChanged or function()
end,
_rt = nil,
}, index2)

arg2:AttachRight(function(arg5, arg6)
return createFrame(obj, arg5, arg6)
end, nil, nil, arg3)

return obj
end

index2.Set = function(arg, arg2, arg3)
if type(arg2) ~= "table" then
return
end
arg.Order = fn36(arg.Items, arg2)
fn38(arg)
fn39(arg, arg3)
end

index2.SetItems = function(arg, arg2)
local items = {}

for _, v120 in arg2, nil, nil do
if type(v120) == "string" then
table.insert(items, v120)
end
end

arg.Items = items
arg.Order = fn36(items, arg.Order)
arg.Value = table.clone(arg.Order)
return arg
end

index2.SetLabel = function(arg, arg2)
arg.Row:SetLabel(arg2)
return arg
end

index2.SetTooltip = function(arg, arg2)
arg.Row:SetTooltip(arg2)
return arg
end

index2.SetVisible = function(arg, arg2)
arg.Row:SetVisible(arg2)
end

index2.OnChanged = function(arg, arg2)
arg._trove:Connect(arg.Changed, arg2)
return arg
end

index2.Connect = function(arg, arg2, arg3)
arg._trove:Connect(arg2, arg3)
return arg
end

index2.Destroy = function(arg)
arg._trove:Destroy()
end

return index2
end

tbl17.Y = function()
local y = tbl17.cache.Y

if not y then
local y2 = { c = fn35() }
tbl17.cache.Y = y2
y = y2
end

return y.c
end
end
do -- Z
local function fn35()
local v115 = tbl17.g()
tbl17.k()
tbl17.r()
local v116 = tbl17.s()
local v117 = tbl17.x()
tbl17.B()
local v118 = tbl17.A()
local v119 = tbl17.w()
local color = Color3.fromRGB(v86[119], 159, 159)
local udim2 = UDim2.fromOffset(153, 150)
local udim22 = UDim2.fromOffset(5, 16)
local index2 = {}
index2.__index = index2

local function fn36(arg)
return arg.Title or arg.Name
end

local function fn37(arg, arg2, selected, arg3)
arg2.Selected = selected
local item = arg2.Item
local defaultAccentPosition = arg2.DefaultAccentPosition
local defaultImageSize = arg2.DefaultImageSize
local selectedPreviewColor, n, n33, n34

if selected then
selectedPreviewColor = item.SelectedPreviewColor or v118.get("TabButtonSelected")
defaultAccentPosition = UDim2.new(0.5, 0, 1, -2)
defaultImageSize = UDim2.new(arg2.DefaultImageSize.X.Scale, arg2.DefaultImageSize.X.Offset + 6, arg2.DefaultImageSize.Y.Scale, arg2.DefaultImageSize.Y.Offset + 6)
n = 0
n33 = 0.94
n34 = 0
else
selectedPreviewColor = arg2.DefaultPreviewColor
n = 1
n33 = 1
n34 = 0.08
end

selected = selected and arg2.TitleColor or v118.get("Unselected")

local function fn38(arg4, arg5)
if arg3 then
for k, v120 in arg5, nil, nil do
arg4[k] = v120
end
else
arg._menu:Tween(arg4, arg5)
end
end

fn38(arg2.Card, { BackgroundColor3 = selectedPreviewColor })
fn38(arg2.Title, { TextColor3 = selected })
fn38(arg2.Accent, { Position = defaultAccentPosition, BackgroundTransparency = n34 })
fn38(arg2.SelectIndicator, { BackgroundTransparency = n })
fn38(arg2.SelectIndicatorIcon, { TextTransparency = n })
fn38(arg2.SelectIndicatorStroke, { Transparency = n })
fn38(arg2.Image, { Size = defaultImageSize })
fn38(arg2.Button, { BackgroundTransparency = n33 })
end

local function fn38(arg, arg2)
local visible = arg2 == nil or arg2(arg.Item, arg.SearchKey)

if arg.Object.Visible ~= visible then
arg.Object.Visible = visible
end
end

local function fn39(arg)
if arg == v86[89] then
return "Loading catalog", v86[111]
end

if arg == "Unavailable" then
return v86[69], "The catalog could not be loaded."
end

if arg == "Empty" then
return "No items available", "This catalog does not have any items yet."
end

if arg == "NoMatches" then
return "No matches", v86[177]
end
return "", ""
end

local function fn40(arg)
local rt = arg._rt
if rt == nil then
return
end
local visible = arg.State == "Ready"
rt.Holder.Visible = visible
rt.StateRoot.Visible = not visible
local v120, v121 = fn39(arg.State)
rt.StateTitle.Text = v120
rt.StateMessage.Text = arg._stateMessage or v121
rt.ClearFilter.Visible = arg.State == "NoMatches" and arg._onClearFilter ~= nil
rt.UpdateHeight()
end

local function fn41(arg, arg2, parent, arg3, arg4)
local v120 = fn36(arg2)
local previewColor = arg2.PreviewColor or v118.get(v86[178])
local titleColor = arg2.TitleColor or v118.get("TextColor")
local frame = Instance.new("Frame")
frame.BackgroundTransparency = 1
frame.BorderSizePixel = 0
frame.Size = UDim2.fromOffset(100, 100)
frame.LayoutOrder = arg2.LayoutOrder or 0
frame.Visible = false
frame.Parent = parent
local instance = Instance.new(v86[4])
instance.HorizontalAlignment = Enum.HorizontalAlignment.Center
instance.VerticalAlignment = Enum.VerticalAlignment.Center
instance.HorizontalFlex = Enum.UIFlexAlignment.Fill
instance.VerticalFlex = Enum.UIFlexAlignment.Fill
instance.Padding = UDim.new(0, 16)
instance.SortOrder = Enum.SortOrder.LayoutOrder
instance.ItemLineAlignment = Enum.ItemLineAlignment.Center
instance.Parent = frame
local instance2 = Instance.new(v86[128])
instance2.BackgroundColor3 = previewColor
instance2.BorderSizePixel = v86[186]
instance2.AnchorPoint = Vector2.new(v86[101], 0.5)
instance2.Position = UDim2.fromScale(v86[101], 0.5)
instance2.Size = UDim2.fromScale(1, 1)
instance2.ClipsDescendants = true
instance2.Parent = frame
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, v86[54])
uiCorner.Parent = instance2
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingTop = UDim.new(0, 10)
uiPadding.PaddingRight = UDim.new(0, 10)
uiPadding.PaddingLeft = UDim.new(0, 10)
uiPadding.PaddingBottom = UDim.new(0, v86[133])
uiPadding.Parent = instance2
local textButton = Instance.new("TextButton")
textButton.BackgroundTransparency = v86[63]
textButton.BorderSizePixel = 0
textButton.Size = UDim2.fromScale(1, 1)
textButton.Text = ""
textButton.ZIndex = 5
textButton.AutoButtonColor = v86[153]
textButton.Parent = instance2
local instance3 = Instance.new(v86[98])
instance3.CornerRadius = UDim.new(0, v86[54])
instance3.Parent = textButton
local frame2 = Instance.new("Frame")
frame2.BackgroundTransparency = 1
frame2.BorderSizePixel = 0
frame2.AnchorPoint = Vector2.new(0.5, 0.5)
frame2.Position = UDim2.fromScale(0.5, 0.5)
frame2.AutomaticSize = Enum.AutomaticSize.XY
frame2.Parent = instance2
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.ItemLineAlignment = Enum.ItemLineAlignment.Center
uiListLayout.Parent = frame2
local imageLabel = Instance.new("ImageLabel")
imageLabel.BackgroundTransparency = 1
imageLabel.BorderSizePixel = v86[186]
imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
imageLabel.Position = UDim2.fromScale(0.5, 0.5)
imageLabel.Size = arg2.ImageSize or UDim2.fromOffset(v86[91], 100)
imageLabel.ScaleType = Enum.ScaleType.Fit
imageLabel.Image = arg2.Image or "rbxassetid://89204837120267"
imageLabel.Parent = frame2
local frame3 = Instance.new("Frame")
frame3.AnchorPoint = Vector2.new(1, 0)
frame3.Position = UDim2.new(1, 2, 0, -v86[56])
frame3.Size = UDim2.fromOffset(v86[144], 22)
frame3.BackgroundTransparency = 1
frame3.BorderSizePixel = 0
frame3.ZIndex = 6
arg4:Bind(frame3, "BackgroundColor3", "Accent")
frame3.Parent = instance2
local uiCorner2 = Instance.new("UICorner")
uiCorner2.CornerRadius = UDim.new(1, v86[186])
uiCorner2.Parent = frame3
local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(255, 255, 255)
uiStroke.Transparency = v86[63]
uiStroke.Thickness = 1.5
uiStroke.Parent = frame3
local instance4 = Instance.new(v86[135])
instance4.BackgroundTransparency = 1
instance4.Size = UDim2.fromScale(1, 1)
instance4.Text = "✓"
instance4.FontFace = v116.Bold
instance4.TextSize = 15
instance4.TextColor3 = Color3.fromRGB(v86[108], v86[108], 255)
instance4.TextTransparency = v86[63]
instance4.ZIndex = 7
instance4.Parent = frame3
local instance5 = Instance.new(v86[128])
instance5.BorderSizePixel = 0
instance5.AnchorPoint = Vector2.new(0.5, 0)
instance5.Position = UDim2.new(v86[101], 0, 1, 5)
instance5.Size = UDim2.fromOffset(v86[91], 100)
instance5.BackgroundTransparency = v86[147]

if arg2.AccentColor ~= nil then
instance5.BackgroundColor3 = arg2.AccentColor
else
arg4:Bind(instance5, "BackgroundColor3", "Accent")
end

instance5.Parent = instance2
Instance.new("UICorner").Parent = instance5
local uiGradient = Instance.new("UIGradient")
uiGradient.Rotation = v86[45]
local new = ColorSequenceKeypoint.new
local v121 = v86[63]
uiGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(v86[108], 255, v86[108])), new(v121, color) })
uiGradient.Parent = instance5
local textLabel = Instance.new("TextLabel")
textLabel.BackgroundTransparency = v86[63]
textLabel.BorderSizePixel = 0
textLabel.AnchorPoint = Vector2.new(0, v86[101])
textLabel.Position = UDim2.fromScale(0, 0.5)
textLabel.AutomaticSize = Enum.AutomaticSize.XY
textLabel.TextSize = 16
textLabel.Text = v120
textLabel.FontFace = v116.SemiBold
textLabel.TextColor3 = titleColor
textLabel.Parent = frame

local tbl18 = {
Item = arg2,
Object = frame,
Card = instance2,
Button = textButton,
Title = textLabel,
Image = imageLabel,
SelectIndicator = frame3,
SelectIndicatorIcon = instance4,
SelectIndicatorStroke = uiStroke,
Accent = instance5,
Selected = arg2.Selected == true,
TitleColor = titleColor,
DefaultPreviewColor = previewColor,
DefaultAccentPosition = instance5.Position,
DefaultImageSize = imageLabel.Size,
SearchKey = arg2.Name:lower(),
}

local render = arg2.Render

if render ~= nil then
local frame4 = Instance.new("Frame")
frame4.BackgroundTransparency = v86[63]
frame4.BorderSizePixel = 0
frame4.Size = UDim2.fromScale(1, 1)
frame4.Parent = instance2

render(arg2, {
Content = frame4,
HideImage = function()
imageLabel.Visible = false
end,
})
end

fn37(arg, tbl18, tbl18.Selected, true)

arg3:Connect(textButton.MouseEnter, function()
if tbl18.Selected then
return
end
arg._menu:Tween(tbl18.Card, { BackgroundColor3 = v118.get("Outline") })
end)

arg3:Connect(textButton.MouseLeave, function()
if tbl18.Selected then
return
end
arg._menu:Tween(tbl18.Card, { BackgroundColor3 = tbl18.DefaultPreviewColor })
end)

v117.connectClick(arg3, textButton, function()
arg:Set(arg2.Name)
end)

return tbl18
end

local function fn42(arg)
local value = arg.Value

if value == nil then
for _, v120 in arg._entries, nil, nil do
if v120.Item.Selected then
value = v120.Item.Name
break
end
end

if value == nil and arg._entries[v86[63]] ~= nil then
value = arg._entries[v86[63]].Item.Name
end

if value ~= nil then
arg:Set(value, true)
end

return
end

for _, v120 in arg._entries, nil, nil do
if v120.Item.Name == value then
arg._selectedEntry = v120
fn37(arg, v120, true)
return
end
end
end

local function fn43(arg, arg2)
for _, v120 in arg, nil, nil do
if v120.Name == arg2 then
return true
end
end

return false
end

local function fn44(arg)
for _, v120 in arg, nil, nil do
if v120.Selected then
return v120.Name
end
end

local v120 = arg[1]
if v120 ~= nil then
return v120.Name
end
return nil
end

local function fn45(arg)
if true then
local ctx = arg._ctx
local rt = arg._rt
if ctx == nil or rt == nil then
return
end
arg._buildToken = arg._buildToken + 1
local itemsTrove = arg._itemsTrove

if itemsTrove ~= nil then
itemsTrove:Destroy()
end

for _, v120 in arg._entries, nil, nil do
v120.Object:Destroy()
end

table.clear(arg._entries)
arg._selectedEntry = nil
local v120 = ctx.Trove:Extend()
local v121 = v118.newBatch(v120)
arg._itemsTrove = v120
local buildToken = arg._buildToken
local items = arg.Items

local function fn46(arg2)
for k, v122 in items, nil, nil do
if arg._buildToken ~= buildToken then
return
end
local v123 = fn41(arg, v122, rt.Holder, v120, v121)
table.insert(arg._entries, v123)
fn38(v123, arg._filter)

if arg2 and k % v86[192] == v86[186] then
task.wait()
end
end

if arg._buildToken == buildToken then
fn42(arg)
end
end

if #items <= 30 then
fn46(false)
else
v120:Add(task.spawn(fn46, true))
end

return
end

-- (anti-tamper freeze trap removed)
end

local function fn46(arg, parent, ctx)
local instance = Instance.new(v86[128])
instance.BackgroundTransparency = 1
instance.BorderSizePixel = 0
instance.Size = UDim2.new(1, 0, 0, arg._height)
instance.Parent = parent
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.Size = UDim2.fromScale(1, 1)
scrollingFrame.CanvasSize = UDim2.new(v86[186], 0, v86[186], 0)
scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollingFrame.ScrollBarThickness = v86[186]
scrollingFrame.ScrollBarImageTransparency = v86[63]
scrollingFrame.Selectable = false
ctx.Batch:Bind(scrollingFrame, v86[154], "Accent")
scrollingFrame.Parent = instance
local active = scrollingFrame.Active
local uiGridLayout = Instance.new("UIGridLayout")
uiGridLayout.CellSize = udim2
uiGridLayout.CellPadding = udim22
uiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiGridLayout.Parent = scrollingFrame
local frame = Instance.new("Frame")
frame.BackgroundTransparency = 1
frame.BorderSizePixel = 0
frame.Size = UDim2.fromScale(v86[63], 1)
frame.Visible = false
frame.Parent = instance
local frame2 = Instance.new("Frame")
frame2.AnchorPoint = Vector2.new(0.5, 0.5)
frame2.Position = UDim2.fromScale(0.5, 0.5)
frame2.Size = UDim2.new(v86[63], -48, 0, 0)
frame2.AutomaticSize = Enum.AutomaticSize.Y
frame2.BackgroundTransparency = 1
frame2.BorderSizePixel = v86[186]
frame2.Parent = frame
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayout.Padding = UDim.new(v86[186], 8)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = frame2
local instance2 = Instance.new(v86[135])
instance2.BackgroundTransparency = 1
instance2.BorderSizePixel = 0
instance2.Size = UDim2.new(1, 0, 0, v86[61])
instance2.FontFace = v116.SemiBold
instance2.Text = ""
instance2.TextSize = 17
instance2.TextWrapped = true
ctx.Batch:Bind(instance2, "TextColor3", "TextColor")
instance2.Parent = frame2
local instance3 = Instance.new(v86[135])
instance3.BackgroundTransparency = 1
instance3.BorderSizePixel = 0
instance3.Size = UDim2.fromScale(1, 0)
instance3.AutomaticSize = Enum.AutomaticSize.Y
instance3.FontFace = arg._menu.Fonts.Main
instance3.Text = ""
instance3.TextSize = 15
instance3.TextWrapped = true
ctx.Batch:Bind(instance3, "TextColor3", v86[96])
instance3.Parent = frame2
local textButton = Instance.new("TextButton")
textButton.Size = UDim2.fromOffset(v86[67], 32)
textButton.BackgroundColor3 = v118.get("ElementBackground")
textButton.BorderSizePixel = 0
textButton.AutoButtonColor = false
textButton.FontFace = v116.SemiBold
textButton.Text = "Clear Search"
textButton.TextSize = 15
textButton.Visible = v86[153]
ctx.Batch:Bind(textButton, "BackgroundColor3", "ElementBackground")
ctx.Batch:Bind(textButton, "TextColor3", "Accent")
textButton.Parent = frame2
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 6)
uiCorner.Parent = textButton
local uiStroke = Instance.new("UIStroke")
ctx.Batch:Bind(uiStroke, "Color", "Outline")
uiStroke.Parent = textButton

ctx.Trove:Connect(textButton.MouseEnter, function()
arg._menu:Tween(textButton, { BackgroundColor3 = v118.get(v86[88]) })
end)

ctx.Trove:Connect(textButton.MouseLeave, function()
arg._menu:Tween(textButton, { BackgroundColor3 = v118.get("ElementBackground") })
end)

v117.connectClick(ctx.Trove, textButton, function()
local onClearFilter = arg._onClearFilter

if onClearFilter ~= nil then
onClearFilter()
end
end)

local v120 = nil
local connection = nil
local n = -1

local function fn47()
local flag19 = arg._heightMode == "Fill"
local scrollingEnabled = not flag19
scrollingFrame.ScrollingEnabled = scrollingEnabled
scrollingFrame.Active = scrollingEnabled and active
local height = arg._height

if flag19 then
local y = uiGridLayout.AbsoluteContentSize.Y

if arg.State ~= "Ready" then
y = 144
end

local height2 = arg._height

if v120 ~= nil then
height2 = math.max(0, v120.AbsoluteSize.Y - instance.AbsolutePosition.Y - v120.AbsolutePosition.Y + v120.CanvasPosition.Y)
end

height = math.max(y, height2)
end

if height == n then
return
end
n = height
instance.Size = UDim2.new(1, 0, 0, height)
end

local offset = udim2.X.Offset
local offset2 = udim22.X.Offset
local y = udim2.Y
local n33 = -1

local function fn48()
local x = scrollingFrame.AbsoluteSize.X
if x < offset then
return
end
local n34 = math.floor((x + offset2) / (offset + offset2))

if n34 < 1 then
n34 = v86[63]
end

local n35 = math.floor((x - offset2 * (n34 - 1)) / n34)
if n35 == n33 then
return
end
n33 = n35
uiGridLayout.CellSize = UDim2.new(0, n35, y.Scale, y.Offset)
end

local function fn49()
local v121 = v119.findScrollingAncestor(instance)
if v121 == v120 then
return
end

if connection ~= nil then
ctx.Trove:Remove(connection)
connection = nil
end

v120 = v121

if v120 ~= nil then
connection = ctx.Trove:Connect(v120:GetPropertyChangedSignal("AbsoluteSize"), fn47)
end

fn47()
end

ctx.Trove:Connect(scrollingFrame:GetPropertyChangedSignal(v86[131]), fn48)
ctx.Trove:Connect(uiGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"), fn47)
ctx.Trove:Connect(instance:GetPropertyChangedSignal("AbsolutePosition"), fn47)
ctx.Trove:Connect(instance.AncestryChanged, fn49)
fn49()
ctx.Trove:Add(task.defer(fn48))
ctx.Trove:Add(task.defer(fn47))
arg._ctx = ctx

arg._rt = {
Holder = scrollingFrame,
StateRoot = frame,
StateTitle = instance2,
StateMessage = instance3,
ClearFilter = textButton,
UpdateHeight = fn47,
}

fn45(arg)
fn40(arg)
return instance
end

index2._New = function(arg, arg2, arg3, arg4)
local obj = setmetatable({
_trove = arg3,
_menu = arg,
Kind = "SkinChanger",
Row = arg2,
Items = arg4.Items or {},
_areItemsPublished = arg4.Items ~= nil,
Value = nil,
Changed = arg3:Add(v115.new()),
ValueChanged = arg3:Add(v115.new()),
_onChanged = arg4.OnChanged or function()
end,
_height = arg4.Height or 300,
_heightMode = arg4.HeightMode or "Fixed",
State = arg4.State or "Ready",
_stateMessage = arg4.StateMessage,
_onClearFilter = arg4.OnClearFilter,
_filter = nil,
_entries = {},
_selectedEntry = nil,
_buildToken = 0,
_itemsTrove = nil,
_ctx = nil,
_rt = nil,
}, index2)

arg2:AttachRight(function(arg5, arg6)
return fn46(obj, arg5, arg6)
end, nil, nil, arg3)

return obj
end

index2.Set = function(arg, arg2, arg3)
local v120

if arg2 ~= nil and arg._areItemsPublished and not fn43(arg.Items, arg2) then
v120 = nil
else
v120 = arg2
end

local flag19 = arg2 ~= nil and v120 == nil
local v121 = nil

if v120 ~= nil then
v121 = nil

for _, v122 in arg._entries, nil, nil do
if v122.Item.Name == v120 then
v121 = v122
break
else
v121 = nil
end
end
end

if arg.Value == v120 and (v121 == nil or arg._selectedEntry == v121) and not flag19 then
return
end
arg.Value = v120
local selectedEntry = arg._selectedEntry

if selectedEntry ~= nil and selectedEntry ~= v121 then
fn37(arg, selectedEntry, false)
end

arg._selectedEntry = v121

if v121 ~= nil then
fn37(arg, v121, v86[34])
end

arg.ValueChanged:Fire(v120)

if not arg3 then
arg._onChanged(v120)
arg.Changed:Fire(v120)
end
end

index2.SetItems = function(arg, arg2, arg3)
local value = arg.Value
arg.Items = table.clone(arg2)
arg._areItemsPublished = true
local v120 = v86[153]

if value == nil then
value = fn44(arg.Items)
elseif not fn43(arg.Items, value) then
value = fn44(arg.Items)
v120 = v86[34]
end

arg.Value = value
arg.ValueChanged:Fire(value)

if v120 and not arg3 then
arg._onChanged(value)
arg.Changed:Fire(value)
end

fn45(arg)
return arg
end

index2.SetFilter = function(arg, filter)
arg._filter = filter

for _, v120 in arg._entries, nil, nil do
fn38(v120, filter)
end

return arg
end

index2.SetState = function(arg, state, stateMessage)
arg.State = state
arg._stateMessage = stateMessage
fn40(arg)
return arg
end

index2.SetClearFilterAction = function(arg, onClearFilter)
arg._onClearFilter = onClearFilter
fn40(arg)
return arg
end

index2.SetLabel = function(arg, arg2)
arg.Row:SetLabel(arg2)
return arg
end

index2.SetTooltip = function(arg, arg2)
arg.Row:SetTooltip(arg2)
return arg
end

index2.SetVisible = function(arg, arg2)
arg.Row:SetVisible(arg2)
end

index2.OnChanged = function(arg, arg2)
arg._trove:Connect(arg.Changed, arg2)
return arg
end

index2.Connect = function(arg, arg2, arg3)
arg._trove:Connect(arg2, arg3)
return arg
end

index2.Destroy = function(arg)
arg._buildToken = arg._buildToken + 1
arg._trove:Destroy()
end

return index2
end

tbl17.Z = function()
local z = tbl17.cache.Z

if not z then
z = { c = fn35() }
tbl17.cache.Z = z
end

return z.c
end
end
do -- _
local function fn35()
local v115 = tbl17.g()
tbl17.k()
tbl17.r()
local v116 = tbl17.s()
local v117 = tbl17.v()
tbl17.B()
local v118 = tbl17.A()
local index2 = {}
index2.__index = index2

local function createFrame(arg, parent, arg2)
local menu = arg._menu
local controlHeight = v117.get().Row.ControlHeight
local frame = Instance.new("Frame")
frame.ClipsDescendants = true
frame.AnchorPoint = Vector2.new(v86[63], 0.5)
frame.Position = UDim2.new(v86[63], -v86[63], 0.5, 0)
frame.Size = UDim2.fromOffset(0, controlHeight)
frame.BorderSizePixel = 0
arg2.Batch:Bind(frame, v86[5], v86[168])
frame.Parent = parent
local uiSizeConstraint = Instance.new("UISizeConstraint")
uiSizeConstraint.MinSize = Vector2.new(math.min(arg.MaxWidth + v86[12], v86[163]), controlHeight)
uiSizeConstraint.MaxSize = Vector2.new(arg.MaxWidth + 12, controlHeight)
uiSizeConstraint.Parent = frame
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 5)
uiCorner.Parent = frame
local uiStroke = Instance.new("UIStroke")
arg2.Batch:Bind(uiStroke, v86[27], "Outline")
uiStroke.Parent = frame
local instance = Instance.new(v86[148])
instance.ClearTextOnFocus = false
instance.PlaceholderText = arg.Placeholder
arg2.Batch:Bind(instance, "PlaceholderColor3", "Unselected")
instance.FontFace = v116.SemiBold
instance.Text = ""
instance.AnchorPoint = Vector2.new(0, 0.5)
instance.BorderSizePixel = 0
instance.BackgroundTransparency = v86[63]
instance.Position = UDim2.new(0, 5, v86[101], 0)
instance.Size = UDim2.new(1, -10, 1, 0)
instance.AutomaticSize = Enum.AutomaticSize.None
instance.TextSize = v86[13]
instance.TextXAlignment = Enum.TextXAlignment.Left
instance.Selectable = v86[153]
instance.Active = v86[34]
arg2.Batch:Bind(instance, "TextColor3", "TextColor")
instance.Parent = frame
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingRight = UDim.new(0, v86[175])
uiPadding.PaddingLeft = UDim.new(0, 1)
uiPadding.Parent = instance
arg._rt = { Outline = frame, Input = instance }
frame.Active = true
arg2.Trove:Connect(frame.InputBegan, function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
task.defer(function() instance:CaptureFocus() end)
end
end)
local tweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, v86[186], false, 0)

local function fn36(arg3)
if instance.TextSize ~= 16 then
instance.TextSize = 16
end

local _tbp = Instance.new("GetTextBoundsParams")
_tbp.Text = instance.Text
_tbp.Size = 16
_tbp.Font = instance.FontFace
_tbp.Width = 100000
local x = game:GetService("TextService"):GetTextBoundsAsync(_tbp).X

if arg.MaxWidth < x then
instance.TextSize = math.max(math.floor(v86[13] * arg.MaxWidth / x), 8)
x = arg.MaxWidth
end

local udim2 = UDim2.fromOffset(x + 12, controlHeight)

if arg3 then
menu:Tween(frame, { Size = udim2 }, tweenInfo)
else
frame.Size = udim2
end
end

arg2.Trove:Connect(instance:GetPropertyChangedSignal("Text"), function()
fn36(true)

if not arg.FocusLostOnly then
arg:Set(instance.Text)
end
end)

arg2.Trove:Connect(instance.Focused, function()
menu:Tween(instance, { TextColor3 = v118.get(v86[139]) })
end)

arg2.Trove:Connect(instance.FocusLost, function()
menu:Tween(instance, { TextColor3 = v118.get("TextColor") })

if arg.FocusLostOnly then
arg:Set(instance.Text)
end
end)

arg2.Trove:Connect(arg.ValueChanged, function(text)
if instance.Text ~= text and not instance:IsFocused() then
instance.Text = text
end
end)

if instance.Text ~= arg.Value then
instance.Text = arg.Value
end

arg2.Trove:Add(task.defer(function()
fn36(false)
end))

return frame
end

index2._New = function(arg, arg2, arg3, arg4)
local obj = setmetatable({
_trove = arg3,
_menu = arg,
Kind = "Input",
Row = arg2,
Value = arg4.Default or "",
Placeholder = arg4.Placeholder or v86[22],
FocusLostOnly = arg4.FocusLostOnly == v86[34],
MaxWidth = arg4.MaxLength or 200,
Changed = arg3:Add(v115.new()),
ValueChanged = arg3:Add(v115.new()),
_onChanged = arg4.OnChanged or function()
end,
_rt = nil,
}, index2)

arg2:AttachRight(function(arg5, arg6)
return createFrame(obj, arg5, arg6)
end, nil, nil, arg3)

return obj
end

index2.Set = function(arg, arg2, arg3)
if type(arg2) == "boolean" or arg2 == nil then
return
end
local value = tostring(arg2)
if value == arg.Value then
return
end
arg.Value = value
arg.ValueChanged:Fire(value)

if not arg3 then
arg._onChanged(value)
arg.Changed:Fire(value)
end
end

index2.SetLabel = function(arg, arg2)
arg.Row:SetLabel(arg2)
return arg
end

index2.SetTooltip = function(arg, arg2)
arg.Row:SetTooltip(arg2)
return arg
end

index2.SetVisible = function(arg, arg2)
arg.Row:SetVisible(arg2)
end

index2.OnChanged = function(arg, arg2)
arg._trove:Connect(arg.Changed, arg2)
return arg
end

index2.Connect = function(arg, arg2, arg3)
arg._trove:Connect(arg2, arg3)
return arg
end

index2.Destroy = function(arg)
arg._trove:Destroy()
end

return index2
end

tbl17._ = function()
local tbl18 = tbl17.cache._

if not tbl18 then
tbl18 = { c = fn35() }
tbl17.cache._ = tbl18
end

return tbl18.c
end
end
do -- aa
local function fn35()
tbl17.k()
local v115 = tbl17.F()
tbl17.r()
local v116 = tbl17.x()
tbl17.B()
local v117 = tbl17.w()
local index2 = {}
index2.__index = index2

local function fn36(arg)
if arg:IsA("Model") then
local boundingBox, v118 = arg:GetBoundingBox()
return boundingBox.Position, math.max(v118.X, v118.Y, v118.Z) * 0.5
end

if arg:IsA("BasePart") then
local size = arg.Size
return arg.Position, math.max(size.X, size.Y, size.Z) * v86[101]
end
return Vector3.zero, 4
end

local function fn37(arg)
if arg._model == nil then
return
end
local modelCenter = arg._modelCenter
local n = math.max(arg._modelRadius * 2.4 * arg._distanceMultiplier, v86[26])
local rotation = arg._rotation
local n33 = math.clamp(arg._elevation, -1.4707963267948965, v86[23])
local v118 = math.cos(n33)
arg._camera.CFrame = CFrame.new(modelCenter + Vector3.new(math.cos(rotation) * n * v118, math.sin(n33) * n, math.sin(rotation) * n * v118), modelCenter)
end

local function createFrame(arg, parent, arg2)
local frame = Instance.new("Frame")
frame.BackgroundTransparency = 1
frame.Size = UDim2.new(1, v86[186], 0, arg._height)
frame.BorderSizePixel = v86[186]
frame.Parent = parent
local instance = Instance.new(v86[128])
instance.Size = UDim2.fromScale(v86[63], 1)
instance.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
instance.BorderSizePixel = 0
instance.ZIndex = 0
instance.Parent = frame
local instance2 = Instance.new(v86[46])
instance2.Rotation = v86[45]
v115.bindSurfaceGradient(arg2.Batch, instance2, { v86[187], v86[70] })
instance2.Parent = instance
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 6)
uiCorner.Parent = instance
local viewportFrame = Instance.new("ViewportFrame")
viewportFrame.Size = UDim2.fromScale(v86[63], 1)
viewportFrame.BackgroundTransparency = 1
viewportFrame.BorderSizePixel = 0
viewportFrame.LightDirection = Vector3.new(-1, -v86[63], -1).Unit
viewportFrame.LightColor = Color3.fromRGB(v86[108], 255, 255)
viewportFrame.Ambient = Color3.fromRGB(140, 140, 150)
viewportFrame.CurrentCamera = arg._camera
viewportFrame.Parent = frame
local uiCorner2 = Instance.new("UICorner")
uiCorner2.CornerRadius = UDim.new(0, v86[54])
uiCorner2.Parent = viewportFrame
local uiStroke = Instance.new("UIStroke")
arg2.Batch:Bind(uiStroke, "Color", "Outline")
uiStroke.Parent = viewportFrame
arg._worldModel.Parent = viewportFrame
arg._rt = viewportFrame
local textButton = Instance.new("TextButton")
textButton.BackgroundTransparency = 1
textButton.Size = UDim2.fromScale(1, 1)
textButton.BorderSizePixel = 0
textButton.Text = ""
textButton.AutoButtonColor = false
textButton.Parent = viewportFrame

arg2.Trove:Connect(textButton.InputBegan, function(arg3)
if arg3.UserInputType ~= Enum.UserInputType.MouseWheel then
return
end
local n = 1

if arg3.Position.Z > 0 then
n = -1
end

arg._distanceMultiplier = math.clamp(arg._distanceMultiplier * 0.85 ^ (-n), 0.2, v86[54])
fn37(arg)
end)

local v118 = nil

v116.connectDrag(arg2.Trove, textButton, function(arg3)
local v119 = v118
local vector2 = Vector2.new(arg3.Position.X, arg3.Position.Y)
v118 = vector2
if v119 == nil then
return
end
local n = vector2 - v119
arg._rotation = arg._rotation - n.X * 0.012
arg._elevation = math.clamp(arg._elevation - n.Y * 0.012, -1.4707963267948965, 1.4707963267948965)
fn37(arg)
end, function(arg3)
v118 = nil
if arg3 then
arg._autoRotate = false
return
end

if arg._userWantsAutoRotate then
arg._autoRotate = true
end
end)

arg2.Trove:Add(arg2.Menu:OnPreRender(function(arg3)
if arg._model == nil or not v117.isEffectivelyVisible(viewportFrame) then
return
end

if arg._autoRotate then
arg._rotation = arg._rotation + arg3 * arg._rotateSpeed
fn37(arg)
end
end))

for _, v119 in arg._onRealized, nil, nil do
v119(viewportFrame)
end

table.clear(arg._onRealized)
return frame
end

index2._New = function(arg, arg2, arg3, arg4)
local camera = Instance.new("Camera")
camera.FieldOfView = arg4.FieldOfView or 50
arg3:Add(camera)
local worldModel = Instance.new("WorldModel")
arg3:Add(worldModel)
local flag19 = arg4.AutoRotate ~= v86[153]

local obj = setmetatable({
_trove = arg3,
_menu = arg,
Kind = v86[196],
Row = arg2,
_height = arg4.Height or 180,
_rotation = 0,
_elevation = v86[30],
_autoRotate = flag19,
_userWantsAutoRotate = flag19,
_rotateSpeed = arg4.RotateSpeed or 0.6,
_distanceMultiplier = arg4.DistanceMul or 1,
_camera = camera,
_worldModel = worldModel,
_model = nil,
_modelCenter = Vector3.zero,
_modelRadius = 4,
_rt = nil,
_onRealized = {},
}, index2)

arg2:AttachRight(function(arg5, arg6)
return createFrame(obj, arg5, arg6)
end, nil, nil, arg3)

return obj
end

index2.SetModel = function(arg, arg2)
local model = arg._model

if model ~= nil and model.Parent == arg._worldModel then
model:Destroy()
end

arg._model = nil

if arg2 ~= nil then
local clone = arg2:Clone()

if clone ~= nil then
clone.Parent = arg._worldModel
arg._model = clone
local v118, v119 = fn36(clone)
arg._modelCenter = v118
arg._modelRadius = v119
fn37(arg)
end
end

return arg
end

index2.OnRealized = function(arg, arg2)
local rt = arg._rt
if rt ~= nil then
arg2(rt)
return arg
end
table.insert(arg._onRealized, arg2)
return arg
end

index2.SetDistance = function(arg, arg2)
arg._distanceMultiplier = math.max(0.1, arg2)
fn37(arg)
return arg
end

index2.SetRotation = function(arg, rotation)
arg._rotation = rotation
fn37(arg)
return arg
end

index2.SetVisible = function(arg, arg2)
arg.Row:SetVisible(arg2)
end

index2.Destroy = function(arg)
arg._trove:Destroy()
end

return index2
end

tbl17.aa = function()
local aa = tbl17.cache.aa

if not aa then
local aa2 = { c = fn35() }
tbl17.cache.aa = aa2
aa = aa2
end

return aa.c
end
end
do -- ab
local function fn35()
local v115 = tbl17.g()
tbl17.k()
local v116 = tbl17.P()
local v117 = tbl17.C()
local v118 = tbl17.N()
local v119 = tbl17.M()
tbl17.r()
local v120 = tbl17.Q()
local v121 = tbl17.H()
local v122 = tbl17.R()
local v123 = tbl17.T()
local v124 = tbl17.U()
local v125 = tbl17.v()
local v126 = tbl17.V()
local v127 = tbl17.X()
local v128 = tbl17.Y()
local v129 = tbl17.u()
local v130 = tbl17.x()
local v131 = tbl17.G()
local v132 = tbl17.J()
local v133 = tbl17.B()
local v134 = tbl17.W()
local v135 = tbl17.Z()
local v136 = tbl17.K()
local v137 = tbl17._()
local v138 = tbl17.A()
local v139 = tbl17.S()
local v140 = tbl17.aa()
local index2 = {}
index2.__index = index2

local function fn36(arg, arg2, arg3, arg4)
return setmetatable({
_trove = arg2,
_menu = arg,
_kind = arg3,
Title = arg4,
Opened = arg2:Add(v115.new()),
_side = nil,
_resolveParent = nil,
_groupSpec = nil,
_entries = {},
_visible = v86[34],
_realized = false,
_realizeTrove = nil,
_batch = nil,
_ctx = nil,
_elements = nil,
_titleLabel = nil,
_rootFrame = nil,
_separatorsDirty = false,
_separatorTrove = arg2:Extend(),
_popup = nil,
_gearOverlayParent = nil,
_gears = {},
_gearTrigger = nil,
_gearTooltip = nil,
_gearOwnerRow = nil,
}, index2)
end

index2.BuildSection = function(arg, arg2, arg3, resolveParent)
local v141 = fn36(arg, arg2:Extend(), "section", arg3.Title or "")
v141._side = arg3.Side
v141._resolveParent = resolveParent
return v141
end

index2.BuildPanes = function(arg, arg2, arg3)
local tbl18 = {}

for _, v141 in arg3, nil, nil do
table.insert(tbl18, fn36(arg, arg2:Extend(), "subsection", v141))
end

return tbl18
end

index2.BuildRoot = function(arg, arg2)
return fn36(arg, arg2:Extend(), "root", "")
end

local function fn37(arg, parent, arg2)
local v141 = v125.get()
local frame = Instance.new("Frame")
frame.LayoutOrder = v134.nextLayoutOrder(parent)
frame.BackgroundTransparency = 1
frame.Size = UDim2.fromScale(1, 0)
frame.BorderSizePixel = 0
frame.AutomaticSize = Enum.AutomaticSize.Y
frame.Visible = arg._visible
frame.Parent = parent
arg._rootFrame = frame
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, v141.Section.TitleGap)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = frame

if arg.Title ~= "" then
local instance = Instance.new(v86[135])
instance.Text = arg.Title
instance.AnchorPoint = Vector2.new(0, 0.5)
instance.BackgroundTransparency = 1
instance.Position = UDim2.fromScale(v86[186], 0.5)
instance.BorderSizePixel = 0
instance.AutomaticSize = Enum.AutomaticSize.XY
instance.TextSize = v141.Section.TitleTextSize
instance.FontFace = arg._menu.Fonts.Main
arg2:Bind(instance, "TextColor3", "TextColor")
instance.Parent = frame
arg._titleLabel = instance
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingLeft = UDim.new(0, -v86[63])
uiPadding.Parent = instance
end

local v142 = v134.box(arg2, frame)
arg._elements = v134.elementsContainer(v142)
end

local function createFrame(arg, parent)
local v141 = v125.get()
local frame = Instance.new("Frame")
frame.BackgroundTransparency = 1
frame.Size = UDim2.fromScale(1, 0)
frame.BorderSizePixel = 0
frame.AutomaticSize = Enum.AutomaticSize.Y
frame.Visible = arg._visible
frame.Parent = parent
arg._rootFrame = frame
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, v141.Section.GroupGap)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = frame
arg._elements = frame
return frame
end

local function fn38(arg)
local entries = arg._entries
local flag19 = false
local flag20 = false

for i = #entries, 1, -v86[63] do
local v141 = entries[i]
local flag21

if v141.Row ~= nil then
flag21 = v141.Row:IsVisible() and v141.Row.Frame ~= nil
else
flag21 = false

if v141.Group ~= nil then
local rootFrame = v141.Group._rootFrame
flag21 = rootFrame ~= nil and rootFrame.Visible
end
end

local separator = v141.Separator

if separator ~= nil then
separator.Visible = flag21 and flag19 and not flag20
end

if flag21 then
flag20 = v141.IsDivider == v86[34]
flag19 = true
end
end
end

index2._MarkSeparatorsDirty = function(arg)
if arg._separatorsDirty or not arg._realized then
return
end
arg._separatorsDirty = true
arg._separatorTrove:Clean()

arg._separatorTrove:Add(task.defer(function()
arg._separatorsDirty = false
fn38(arg)
end))
end

local function fn39(arg, arg2, arg3)
local elements = arg._elements
local ctx = arg._ctx
local batch = arg._batch
if elements == nil or ctx == nil or batch == nil then
return
end

if arg2.Row ~= nil then
arg2.Row:Realize(elements, ctx, arg3 * 2)
elseif arg2.Group ~= nil then
arg2.Group:_RealizeAsGroup(elements, ctx, arg3 * v86[56])
elseif arg2.Multi ~= nil then
arg2.Multi:Realize(arg3 * 2)
end

if not arg2.NoSeparator and arg2.Separator == nil then
local frame = Instance.new("Frame")
frame.Visible = v86[153]
frame.Size = UDim2.new(1, 0, 0, 1)
frame.BorderSizePixel = 0
frame.LayoutOrder = arg3 * 2 + v86[63]
batch:Bind(frame, v86[5], "Outline")
frame.Parent = elements
arg2.Separator = frame
end
end

local function fn40(arg, ctx)
arg._realizeTrove = ctx.Trove
arg._batch = ctx.Batch
arg._ctx = ctx

for k, v141 in arg._entries, nil, nil do
fn39(arg, v141, k)
end

fn38(arg)
end

index2.Realize = function(arg)
if arg._realized then
return
end
local resolveParent = arg._resolveParent
assert(arg._kind == "section", "Container.Realize is for sections")

if resolveParent == nil then
error("Container.Realize: section has no parent resolver")
end

arg._realized = true
local v141 = arg._trove:Extend()
local v142 = v138.newBatch(v141)
fn37(arg, resolveParent(), v142)
fn40(arg, { Menu = arg._menu, Trove = v141, Batch = v142 })
end

index2._SetGridParent = function(arg, parent, layoutOrder)
if true then
local rootFrame = arg._rootFrame

if rootFrame == nil then
if not flag2 then
return
end
return
end

rootFrame.LayoutOrder = layoutOrder
rootFrame.Parent = parent
return
end

-- (anti-tamper freeze trap removed)
end

index2._RealizeAsGroup = function(arg, arg2, arg3, layoutOrder)
if arg._realized then
return
end
arg._realized = true
local v141 = createFrame(arg, arg2)
v141.LayoutOrder = layoutOrder
local groupSpec = arg._groupSpec

if groupSpec ~= nil then
local function fn41()
v141.Visible = arg._visible and groupSpec.Predicate(groupSpec.Source.Value)
end

arg3.Trove:Connect(groupSpec.Source.ValueChanged, fn41)
fn41()
end

fn40(arg, arg3)
end

index2._RealizeAsPane = function(arg, elements, arg2)
if arg._realized then
return
end
arg._realized = true
arg._elements = elements
arg._rootFrame = elements
fn40(arg, arg2)
end

index2.RealizeRoot = function(arg, elements, arg2)
if arg._realized then
return
end
assert(arg._kind == "root", v86[82])
arg._realized = v86[34]
arg._elements = elements
arg._rootFrame = elements
local v141 = arg._trove:Extend()
fn40(arg, { Menu = arg._menu, Trove = v141, Batch = v138.newBatch(v141), ParentOverlay = arg2 })
end

local function fn41(arg, arg2)
local popup = arg._popup
if popup ~= nil then
return popup
end
local n = 300

if v129.IsMobile() then
n = v86[65]
end

local v141 = nil

local v142 = v131.new(arg._menu, arg._trove, {
Trigger = arg2,
Size = UDim2.fromOffset(n, v86[186]),
AnchorPoint = Vector2.new(1, 0),
CornerRadius = v86[118],
FlatBackground = v86[34],
ParentEntry = arg._gearOverlayParent,
Place = function(arg3)
local absolutePosition = arg3.AbsolutePosition
local absoluteSize = arg3.AbsoluteSize
return math.round(absolutePosition.X + absoluteSize.X), math.round(absolutePosition.Y + absoluteSize.Y + 2)
end,
OnToggle = function(arg3)
if arg3 and v141 ~= nil then
v141.CanvasPosition = Vector2.zero
end
end,
})

arg._popup = v142
local v143
v141, v143 = v142:AttachScrollingList(n, { Top = 9, Bottom = v86[133], Side = 9 })
arg._realized = v86[34]
arg._elements = v143
arg._rootFrame = v142.Root
fn40(arg, v142:RealizeCtx())
return v142
end

index2._RevealGear = function(arg)
local gearTrigger = arg._gearTrigger
if gearTrigger == nil then
return
end
fn41(arg, gearTrigger):SetOpen(v86[34])
end

local function createTextButton(arg, parent, arg2, name)
local n = 28
local n33 = 24

if v129.IsMobile() then
n = 44
n33 = 44
end

local textButton = Instance.new("TextButton")
textButton.Name = name
textButton.Text = name
textButton.TextTransparency = 1
textButton.Size = UDim2.fromOffset(n, n33)
textButton.AnchorPoint = Vector2.new(0, v86[101])
textButton.BackgroundTransparency = 1
textButton.Position = UDim2.fromScale(0, 0.5)
textButton.BorderSizePixel = 0
textButton.AutomaticSize = Enum.AutomaticSize.None
textButton.AutoButtonColor = false
textButton.Selectable = true
local textLabel = Instance.new("TextLabel")
textLabel.Name = "Ellipsis"
textLabel.Text = v86[40]
textLabel.AnchorPoint = Vector2.new(0.5, v86[101])
textLabel.Position = UDim2.fromScale(0.5, v86[101])
textLabel.Size = UDim2.fromOffset(v86[25], v86[61])
textLabel.BackgroundTransparency = 1
textLabel.BorderSizePixel = 0
textLabel.TextSize = 30
textLabel.FontFace = arg._menu.Fonts.Main
arg2.Batch:Bind(textLabel, "TextColor3", v86[174])
textLabel.Parent = textButton
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingBottom = UDim.new(0, 21)
uiPadding.Parent = textLabel
textButton.Parent = parent

arg2.Menu:AttachTooltip(arg2.Trove, textButton, function()
return name
end)

arg._gearOverlayParent = arg2.ParentOverlay
arg._gearTrigger = textButton

v130.connectClick(arg2.Trove, textButton, function()
fn41(arg, textButton):Toggle()
end)

return textButton
end

index2._AddEntry = function(arg, arg2, arg3)
local tbl18 = { Row = arg2, Group = nil, Separator = nil, NoSeparator = arg3 == v86[34] }
table.insert(arg._entries, tbl18)
arg._menu:InvalidateSearch()

arg2._onVisibilityChanged = function()
arg:_MarkSeparatorsDirty()
end

if arg._realized then
fn39(arg, tbl18, #arg._entries)
arg:_MarkSeparatorsDirty()
end
end

index2._RowFor = function(arg, arg2, arg3)
local row = arg2.Row
if row ~= nil then
return row
end
arg3.Label = arg2.Label
arg3.Tooltip = arg2.Tooltip
local v141 = v133.new(arg._menu, arg3)
arg:_AddEntry(v141, arg2.NoSeparator)
return v141
end

index2._Bind = function(arg, arg2, arg3, arg4, arg5)
local config = arg4.Config
if config == nil then
return
end
local config2 = arg._menu:GetConfig()
if config2 == nil then
return
end
local bind = arg4.Bind
local tbl18

if arg5 and (bind == nil or bind.Debounce == nil) then
tbl18 = {}
bind = bind and bind.WriteBack
tbl18.WriteBack = bind
tbl18.Debounce = true
else
tbl18 = bind
end

v116.bind(arg2, config2, arg3, config, tbl18)
end

index2.AddToggle = function(arg, arg2)
local v141 = arg:_RowFor(arg2, { Height = 20 })
local v142 = arg._trove:Extend()
local v143 = v139._New(arg._menu, v141, v142, arg2)
arg:_Bind(v142, v143, arg2)
return v143
end

index2.AddSlider = function(arg, arg2)
local v141 = arg:_RowFor(arg2, { Height = 24, MediumTitle = true, RightOffset = -1 })
local v142 = arg._trove:Extend()
local v143 = v136._New(arg._menu, v141, v142, arg2)
arg:_Bind(v142, v143, arg2, true)
return v143
end

index2.AddRangeSlider = function(arg, arg2)
local v141 = arg:_RowFor(arg2, { Height = v86[61], MediumTitle = v86[34], RightOffset = -v86[63] })
local v142 = arg._trove:Extend()
local v143 = v132._New(arg._menu, v141, v142, arg2)
arg:_Bind(v142, v143, arg2, true)
return v143
end

index2.AddButton = function(arg, arg2)
local flag19 = arg2.Row == nil
return v117._New(arg._menu, arg:_RowFor(arg2, { Bare = true }), arg._trove:Extend(), arg2, flag19)
end

index2.AddLabel = function(arg, arg2)
return v124._New(arg._menu, arg:_RowFor(arg2, { Bare = true }), arg._trove:Extend(), arg2)
end

index2.AddDivider = function(arg, arg2)
local tbl18 = arg2 or {}
tbl18.NoSeparator = v86[34]
local v141 = arg:_RowFor(tbl18, { Bare = v86[34] })
local v142 = arg._entries[#arg._entries]

if v142 ~= nil and v142.Row == v141 then
v142.IsDivider = true
end

return v120._New(arg._menu, v141, arg._trove:Extend(), tbl18)
end

index2.AddTextBox = function(arg, arg2)
local v141 = arg:_RowFor(arg2, { Height = 24, MediumTitle = true })
local v142 = arg._trove:Extend()
local v143 = v137._New(arg._menu, v141, v142, arg2)
arg:_Bind(v142, v143, arg2)
return v143
end

index2.AddDropdown = function(arg, arg2)
local v141 = arg:_RowFor(arg2, { Height = 24 })
local v142 = arg._trove:Extend()
local v143 = v121._New(arg._menu, v141, v142, arg2)
arg:_Bind(v142, v143, arg2)
return v143
end

index2.AddMultiDropdown = function(arg, arg2)
local v141 = arg:_RowFor(arg2, { Height = 24 })
local v142 = arg._trove:Extend()
local v143 = v121._NewMulti(arg._menu, v141, v142, arg2)
arg:_Bind(v142, v143, arg2)
return v143
end

index2.AddList = function(arg, arg2)
local v141 = arg:_RowFor(arg2, { Bare = true })
local v142 = arg._trove:Extend()
local v143 = v126._New(arg._menu, v141, v142, arg2)
arg:_Bind(v142, v143, arg2)
return v143
end

index2.AddMultiList = function(arg, arg2)
local v141 = arg:_RowFor(arg2, { Bare = true })
local v142 = arg._trove:Extend()
local v143 = v126._NewMulti(arg._menu, v141, v142, arg2)
arg:_Bind(v142, v143, arg2)
return v143
end

index2.AddKeybind = function(arg, arg2)
local v141 = v123._New(arg._menu, arg:_RowFor(arg2, { Height = 20 }), arg._trove:Extend(), arg2)
local configMap = arg2.ConfigMap

if configMap ~= nil then
local config = arg._menu:GetConfig()

if config ~= nil then
v141:_BindConfigMap(config, configMap)
end
end

return v141
end

local function fn42(arg, arg2, arg3)
local config = arg3.Config
local transparency = arg3.Transparency
arg:EnableAnimation(transparency ~= nil)

local function fn43()
local v141 = arg2:Get(config)
arg:SetAnimationMode(v141.Mode, v86[34])
arg:SetAnimationSpeed(v141.Speed, true)

if v141.BreathingMin ~= nil or v141.BreathingMax ~= nil then
arg:SetAnimationBreathingRange({
Min = math.floor((1 - (v141.BreathingMax or 1)) * v86[91] + v86[101]),
Max = math.floor((1 - (v141.BreathingMin or 0)) * 100 + 0.5),
}, true)
end

arg2:Apply(config, transparency, v141)
end

arg:Connect(arg.AnimationChanged, function(arg4)
arg2:SetMode(config, arg4)
end)

arg:Connect(arg.AnimationSpeedChanged, function(arg4)
arg2:SetSpeed(config, arg4)
end)

arg:Connect(arg.AnimationBreathingRangeChanged, function(arg4)
arg2:SetBreathing(config, 1 - arg4.Max / v86[91], 1 - arg4.Min / 100)
end)

arg:Connect(arg2:Changed(), fn43)
fn43()
end

index2.AddColor = function(arg, arg2)
local v141 = v119._New(arg._menu, arg:_RowFor(arg2, { Height = v86[9] }), arg._trove:Extend(), arg2)

if arg2.Config ~= nil then
local config = arg._menu:GetConfig()

if config ~= nil then
v118.bindConfig(v141, config, arg2)
end

if arg2.Animatable then
local colorAnimation = arg._menu:GetColorAnimation()

if colorAnimation ~= nil then
fn42(v141, colorAnimation, arg2)
end
end
end

return v141
end

index2.AddSkinChanger = function(arg, arg2)
local v141 = arg:_RowFor(arg2, { Bare = true })
local v142 = arg._trove:Extend()
local v143 = v135._New(arg._menu, v141, v142, arg2)
arg:_Bind(v142, v143, arg2)
return v143
end

index2.AddIconStrip = function(arg, arg2)
local v141 = arg:_RowFor({ Row = nil, NoSeparator = true }, { Bare = v86[34], Height = arg2.Height })
local v142 = arg._trove:Extend()
local v143 = v122._New(arg._menu, v141, v142, arg2)
arg:_Bind(v142, v143, { Config = arg2.Config, Bind = arg2.Bind })
return v143
end

index2.AddViewport = function(arg, arg2)
return v140._New(arg._menu, arg:_RowFor({ Label = arg2.Label, Tooltip = arg2.Tooltip, Row = arg2.Row, NoSeparator = arg2.NoSeparator }, { Bare = true }), arg._trove:Extend(), arg2)
end

index2.AddOrderedList = function(arg, arg2)
local v141 = arg:_RowFor(arg2, { Bare = true })
local v142 = arg._trove:Extend()
local v143 = v128._New(arg._menu, v141, v142, arg2)
arg:_Bind(v142, v143, arg2)
return v143
end

index2.GetConfig = function(arg)
return arg._menu:GetConfig()
end

index2.AddGear = function(arg, arg2)
local v141 = fn36(arg._menu, arg._trove:Extend(), "gear", "Gear")
v141._gearTooltip = arg2.Tooltip
local v142 = arg:_RowFor({ Row = arg2.Row }, { Height = v86[61] })
v141._gearOwnerRow = v142

if v129.IsMobile() then
v142._height = math.max(v142._height, 44)
end

local tooltip = arg2.Tooltip

if tooltip == nil then
local label = v142.Label

if label ~= nil and label ~= "" then
tooltip = "Open " .. label .. " details"
else
tooltip = "Open details"
end
end

local n = 28

if v129.IsMobile() then
n = 44
end

v142:AttachRight(function(arg3, arg4)
return createTextButton(v141, arg3, arg4, tooltip)
end, n, true, v141._trove)

table.insert(arg._gears, v141)
arg._menu:InvalidateSearch()
return v141
end

index2.AddGroup = function(arg, arg2)
local source = arg2.Source
local option = arg2.Option
local fn43

if option ~= nil then
fn43 = function(arg3)
if type(arg3) == "string" then
return arg3 == option
end
local v141 = v86[68]
if type(arg3) == v141 then
return arg3[option] == v86[34] or table.find(arg3, option) ~= nil
end
return v86[153]
end
else
fn43 = function(arg3)
return arg3 == true
end
end

local v141 = fn36(arg._menu, arg._trove:Extend(), "group", arg.Title)
v141._groupSpec = { Source = source, Predicate = fn43, Option = option }

if arg2.Visible ~= nil then
v141._visible = arg2.Visible
end

local tbl18 = { Row = nil, Group = v141, Separator = nil, NoSeparator = false }
table.insert(arg._entries, tbl18)
arg._menu:InvalidateSearch()

v141._trove:Connect(source.ValueChanged, function()
arg:_MarkSeparatorsDirty()
end)

if arg._realized then
fn39(arg, tbl18, #arg._entries)
arg:_MarkSeparatorsDirty()
end

return v141
end

index2.AddMultiSection = function(arg, arg2)
local v141 = index2.BuildPanes(arg._menu, arg._trove, arg2.Titles)

local tbl18 = {
Row = nil,
Group = nil,
Multi = v127.new(arg._menu, arg._trove, v141, function()
local elements = arg._elements
assert(elements ~= nil, "Container.AddMultiSection: container has not realized")
return elements
end),
Panes = v141,
Separator = nil,
NoSeparator = v86[34],
}

table.insert(arg._entries, tbl18)
arg._menu:InvalidateSearch()

if arg._realized then
fn39(arg, tbl18, #arg._entries)
end

return table.unpack(v141)
end

index2.CollectSearchHits = function(arg, arg2, arg3, arg4, arg5)
local tbl18 = arg5 or {}
if not arg._visible then
return
end
local groupSpec = arg._groupSpec
local str7, tbl19

if groupSpec == nil then
str7 = arg2
tbl19 = tbl18
else
local row = groupSpec.Source.Row
local v141 = v86[94]

if row ~= nil then
local label = row.Label

if typeof(label) == "string" and label ~= "" then
v141 = label
end
end

str7 = ("%s  ›  Requires %s: %s"):format(arg2, v141, groupSpec.Option or "On")
local resolveFrame = tbl18.ResolveFrame

tbl19 = {
Reveal = tbl18.Reveal,
ResolveFrame = function(arg6)
if not groupSpec.Predicate(groupSpec.Source.Value) and row ~= nil then
arg6 = row.Frame
end

if resolveFrame ~= nil then
return resolveFrame(arg6)
end
return arg6
end,
}
end

for _, v141 in arg._entries, nil, nil do
local row = v141.Row

if row ~= nil then
local label = row.Label

if label ~= nil and label ~= "" then
local resolveFrame = tbl19.ResolveFrame

table.insert(arg4, {
Kind = "control",
Label = label,
Crumb = str7,
Open = arg3,
Reveal = tbl19.Reveal,
GetFrame = function()
if resolveFrame ~= nil then
return resolveFrame(row.Frame)
end
return row.Frame
end,
})
end
end

local group = v141.Group

if group ~= nil then
group:CollectSearchHits(str7, arg3, arg4, tbl19)
end

local panes = v141.Panes
local multi = v141.Multi

if panes ~= nil and multi ~= nil then
for k, v142 in panes, nil, nil do
local reveal = tbl19.Reveal

local tbl20 = {
ResolveFrame = tbl19.ResolveFrame,
Reveal = function()
if reveal ~= nil then
reveal()
end

multi:SelectPane(k)
end,
}

local title = v142.Title
assert(typeof(title) == "string", "Container pane title must be a string")
v142:CollectSearchHits(("%s  ›  %s"):format(str7, title), arg3, arg4, tbl20)
end
end
end

for _, v141 in arg._gears, nil, nil do
local gearOwnerRow = v141._gearOwnerRow
local gearTooltip = v141._gearTooltip

if gearTooltip == nil and gearOwnerRow ~= nil then
gearTooltip = gearOwnerRow.Label
end

gearTooltip = gearTooltip or v86[14]
local reveal = tbl19.Reveal

local tbl20 = {
ResolveFrame = tbl19.ResolveFrame,
Reveal = function()
if reveal ~= nil then
reveal()
end

v141:_RevealGear()
end,
}

v141:CollectSearchHits(("%s  ›  %s"):format(str7, tostring(gearTooltip)), arg3, arg4, tbl20)
end
end

index2.SetTitle = function(arg, title)
arg.Title = title
arg._menu:InvalidateSearch()
local titleLabel = arg._titleLabel

if titleLabel ~= nil then
titleLabel.Text = title
end

return arg
end

index2.SetVisible = function(arg, visible)
if arg._visible == visible then
return
end
arg._visible = visible
arg._menu:InvalidateSearch()
local rootFrame = arg._rootFrame
if rootFrame == nil then
return
end
local groupSpec = arg._groupSpec

if groupSpec ~= nil then
visible = visible and groupSpec.Predicate(groupSpec.Source.Value)
rootFrame.Visible = visible
else
rootFrame.Visible = visible
end
end

index2.Destroy = function(arg)
local rootFrame = arg._rootFrame

if rootFrame ~= nil then
rootFrame:Destroy()
arg._rootFrame = nil
end

arg._trove:Destroy()
end

return index2
end

tbl17.ab = function()
local ab = tbl17.cache.ab

if not ab then
ab = { c = fn35() }
tbl17.cache.ab = ab
end

return ab.c
end
end
do -- ac
local function fn35()
local v115 = tbl17.k()
local v116 = tbl17.F()
local v117 = tbl17.ab()
tbl17.r()
local v118 = tbl17.s()
local v119 = tbl17.u()
local v120 = tbl17.x()
local v121 = tbl17.y()
local v122 = tbl17.W()
local v123 = tbl17.t()
local v124 = tbl17.A()
local v125 = tbl17.w()
local coreGui = v123.CoreGui
local guiService = v123.GuiService
local userInputService = v123.UserInputService
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(231, 92, v86[53])
local color3 = Color3.fromRGB(v86[65], 220, 230)
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function fn36(arg, arg2)
return Color3.new(arg.R * arg2, arg.G * arg2, arg.B * arg2)
end

local function fn37(arg, arg2)
local clamp = math.clamp
local n = arg.B * arg2
local v126 = v86[63]
return Color3.new(math.clamp(arg.R * arg2, v86[186], 1), math.clamp(arg.G * arg2, v86[186], v86[63]), clamp(n, 0, v126))
end

local function fn38(arg, arg2, arg3, parent, text, arg4, arg5)
local textButton = Instance.new("TextButton")
textButton.Size = UDim2.fromScale(0, 1)
textButton.BorderSizePixel = v86[186]
textButton.Text = text
textButton.TextSize = 14
textButton.FontFace = v118.Bold
textButton.TextTruncate = Enum.TextTruncate.AtEnd
textButton.AutoButtonColor = false
textButton.Active = v86[34]
textButton.Parent = parent
local uiGradient = Instance.new("UIGradient")
uiGradient.Rotation = v86[45]
arg3:BindGradient(uiGradient, { "GradientMid", "GradientDark" })
uiGradient.Parent = textButton
local instance = Instance.new(v86[98])
instance.CornerRadius = UDim.new(0, 5)
instance.Parent = textButton
local v126 = arg4
local flag19 = true
local flag20 = false

local function fn39()
if not flag19 then
uiGradient.Enabled = false
textButton.BackgroundColor3 = v124.get("ElementBackground")
textButton.TextColor3 = v124.get("Unselected")
textButton.TextTransparency = 0.45
return
end

textButton.TextTransparency = v86[186]

if v126 == "secondary" then
uiGradient.Enabled = false
textButton.BackgroundColor3 = v124.get("ElementBackground")
textButton.TextColor3 = v124.get(v86[174])
elseif v126 == "danger" then
uiGradient.Enabled = false
textButton.BackgroundColor3 = color2
textButton.TextColor3 = color
else
uiGradient.Enabled = false
textButton.BackgroundColor3 = v124.get(v86[139])
textButton.TextColor3 = color
end
end

local function fn40()
if not flag19 then
return
end

if v126 == v86[158] then
arg:Tween(textButton, { BackgroundColor3 = v124.get("TabButtonSelected") }, tweenInfo)
arg:Tween(textButton, { TextColor3 = v124.get("TextColor") }, tweenInfo)
elseif v126 == v86[140] then
arg:Tween(textButton, { BackgroundColor3 = fn37(color2, 1.12) }, tweenInfo)
else
local v127 = v86[138]
arg:Tween(textButton, { BackgroundColor3 = fn37(v124.get(v86[139]), v127) }, tweenInfo)
end
end

local function fn41()
if v126 == "secondary" then
arg:Tween(textButton, { BackgroundColor3 = v124.get("ElementBackground") }, tweenInfo)
elseif v126 == "danger" then
arg:Tween(textButton, { BackgroundColor3 = color2 }, tweenInfo)
else
arg:Tween(textButton, { BackgroundColor3 = v124.get("Accent") }, tweenInfo)
end
end

for _, v127 in { "Accent", v86[120], "ElementBackground", "TextColor", "Unselected" }, nil, nil do
arg3:BindStateful(v127, function()
if not flag20 then
fn39()
end
end)
end

arg2:Connect(textButton.MouseEnter, function()
if not flag19 then
return
end
flag20 = true
fn40()
end)

arg2:Connect(textButton.MouseLeave, function()
flag20 = v86[153]

if flag19 then
fn41()
else
fn39()
end
end)

v120.connectPress(arg2, textButton, function()
if not flag19 then
return
end
arg:Tween(textButton, { BackgroundColor3 = fn36(textButton.BackgroundColor3, 0.85) }, tweenInfo2)
end, function()
if flag20 then
fn40()
elseif flag19 then
fn41()
else
fn39()
end
end)

v120.connectClick(arg2, textButton, function()
if flag19 then
arg5()
end
end)

fn39()

return {
Object = textButton,
SetVariant = function(arg6)
v126 = arg6

if flag20 then
fn40()
else
fn39()
end
end,
SetEnabled = function(active)
flag19 = active
textButton.Active = active

if not active then
flag20 = false
end

fn39()
end,
}
end

local function fn39(arg, parent)
local v126 = v119.IsMobile()
local n = v126 and 14 or 20
local n33 = v126 and v86[181] or 14
local n34 = v126 and 10 or 12
local frame = Instance.new("Frame")
frame.Size = UDim2.fromScale(1, 0)
frame.AutomaticSize = Enum.AutomaticSize.Y
frame.BorderSizePixel = 0
frame.BackgroundColor3 = color
frame.LayoutOrder = 1
frame.Parent = parent
local uiGradient = Instance.new("UIGradient")
uiGradient.Rotation = 90
v116.bindSurfaceGradient(arg, uiGradient, { "GradientTop", "GradientMid" })
uiGradient.Parent = frame
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingTop = UDim.new(0, n33)
uiPadding.PaddingRight = UDim.new(0, n)
uiPadding.PaddingBottom = UDim.new(v86[186], n34)
uiPadding.PaddingLeft = UDim.new(0, n)
uiPadding.Parent = frame
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, 3)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = frame
local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, -v86[192], v86[186], v86[186])
textLabel.AutomaticSize = Enum.AutomaticSize.Y
textLabel.BackgroundTransparency = 1
textLabel.BorderSizePixel = 0
textLabel.Text = ""
textLabel.TextSize = v126 and 16 or v86[100]
textLabel.TextWrapped = true
textLabel.TextTruncate = Enum.TextTruncate.AtEnd
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.FontFace = v118.Bold
textLabel.LayoutOrder = 1
arg:Bind(textLabel, v86[167], v86[174])
textLabel.Parent = frame
local uiSizeConstraint = Instance.new("UISizeConstraint")
uiSizeConstraint.MaxSize = Vector2.new(100000, 44)
uiSizeConstraint.Parent = textLabel
local textLabel2 = Instance.new("TextLabel")
textLabel2.Size = UDim2.fromScale(1, 0)
textLabel2.AutomaticSize = Enum.AutomaticSize.Y
textLabel2.BackgroundTransparency = 1
textLabel2.BorderSizePixel = 0
textLabel2.Text = ""
textLabel2.TextSize = v126 and 11 or 13
textLabel2.TextWrapped = true
textLabel2.TextTruncate = Enum.TextTruncate.AtEnd
textLabel2.TextXAlignment = Enum.TextXAlignment.Left
textLabel2.FontFace = v118.SemiBold
textLabel2.LayoutOrder = 2
arg:Bind(textLabel2, "TextColor3", "Unselected")
textLabel2.Parent = frame
local instance = Instance.new(v86[176])
instance.MaxSize = Vector2.new(100000, v126 and 34 or 40)
instance.Parent = textLabel2
return { Root = frame, Title = textLabel, Description = textLabel2 }
end

local function createFrame(arg, parent, layoutOrder)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(1, 0, 0, v86[63])
frame.BorderSizePixel = 0
frame.LayoutOrder = layoutOrder
arg:Bind(frame, "BackgroundColor3", v86[120])
frame.Parent = parent
return frame
end

local function fn40(arg, parent)
local canvasGroup = Instance.new("CanvasGroup")
canvasGroup.Size = UDim2.fromScale(1, 1)
canvasGroup.BackgroundTransparency = 1
canvasGroup.BorderSizePixel = 0
canvasGroup.GroupTransparency = v86[63]
canvasGroup.Visible = false
canvasGroup.Parent = parent
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.fromScale(1, 1)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.Active = true
scrollingFrame.CanvasSize = UDim2.fromOffset(0, 0)
scrollingFrame.ScrollBarImageTransparency = 0.35
scrollingFrame.ScrollBarThickness = 0
scrollingFrame.Selectable = false
scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
arg:Bind(scrollingFrame, "ScrollBarImageColor3", "Accent")
scrollingFrame.Parent = canvasGroup
return { Group = canvasGroup, Body = scrollingFrame, Fade = { Tweening = false } }
end

local index2 = {}
index2.__index = index2

index2.new = function(arg, arg2, arg3, arg4, arg5, arg6)
local v126 = v115.new()
local v127 = v124.newBatch(v126)
local v128 = fn40(v127, arg2)
v126:Add(v128.Group)
local v129 = v122.box(v127, v128.Body)
v129.Position = UDim2.fromOffset(20, v86[72])
v129.Size = UDim2.new(1, -40, 0, 24)
v129.AutomaticSize = Enum.AutomaticSize.None
local v130 = v122.elementsContainer(v129)
local v131 = v130:FindFirstChildOfClass(v86[4])
local v132 = v117.BuildRoot(arg, v126)
v132:RealizeRoot(v130, arg3)

return setmetatable({
_trove = v126,
_props = arg4,
_view = v128,
_card = v129,
_contentLayout = v131,
_open = arg5,
_syncActionEnabled = arg6,
_isActionEnabled = arg4.ActionEnabled ~= false,
_isDestroyed = false,
Container = v132,
}, index2)
end

index2._PrepareLayout = function(arg, arg2, arg3)
local n = arg._contentLayout.AbsoluteContentSize.Y + 24
arg._card.Position = UDim2.fromOffset(arg2, arg3)
arg._card.Size = UDim2.new(1, -arg2 * 2, 0, n)
return n + arg3 * 2
end

index2._SetViewport = function(arg, arg2, arg3)
arg._view.Body.CanvasSize = UDim2.fromOffset(0, arg3)
arg._view.Body.ScrollBarThickness = arg3 > arg2 + v86[101] and 4 or 0
end

index2.Open = function(arg)
if not arg._isDestroyed then
arg._open()
end
end

index2.SetActionEnabled = function(arg, isActionEnabled)
if arg._isDestroyed or arg._isActionEnabled == isActionEnabled then
return
end
arg._isActionEnabled = isActionEnabled
arg._syncActionEnabled(isActionEnabled)
end

index2.Destroy = function(arg)
if arg._isDestroyed then
return
end
arg._isDestroyed = true
arg._trove:Destroy()
end

local index3 = {}
index3.__index = index3

local function fn41(arg, arg2, arg3, parent, arg4, arg5)
local instance = Instance.new(v86[92])
instance.BorderSizePixel = 0
instance.BackgroundColor3 = color
instance.Text = ""
instance.AutoButtonColor = false
instance.Active = true
instance.Parent = parent
local uiGradient = Instance.new("UIGradient")
uiGradient.Rotation = 90
v116.bindSurfaceGradient(arg3, uiGradient, { "ElementBackground", "GradientDark" })
uiGradient.Parent = instance
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 6)
uiCorner.Parent = instance
local uiStroke = Instance.new("UIStroke")
uiStroke.Transparency = 1

if arg4.Variant == "danger" then
uiStroke.Color = color2
else
arg3:Bind(uiStroke, "Color", "Accent")
end

uiStroke.Parent = instance
v121.attach(arg, arg2, instance, { CornerRadius = 6 })
local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(0, 0.5)
frame.Position = UDim2.new(0, v86[181], v86[101], 0)
frame.Size = UDim2.fromOffset(30, 30)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.9
frame.Visible = arg4.Glyph ~= nil

if arg4.Variant == "danger" then
frame.BackgroundColor3 = color2
else
arg3:Bind(frame, v86[5], "Accent")
end

frame.Parent = instance
local uiCorner2 = Instance.new("UICorner")
uiCorner2.CornerRadius = UDim.new(0, 6)
uiCorner2.Parent = frame
local uiStroke2 = Instance.new("UIStroke")
uiStroke2.Transparency = 0.7

if arg4.Variant == v86[140] then
uiStroke2.Color = color2
else
arg3:Bind(uiStroke2, "Color", "Accent")
end

uiStroke2.Parent = frame
local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.fromScale(1, 1)
textLabel.BackgroundTransparency = 1
textLabel.BorderSizePixel = 0
textLabel.Text = arg4.Glyph or ""
textLabel.TextSize = 17
textLabel.FontFace = v118.SemiBold

if arg4.Variant == "danger" then
textLabel.TextColor3 = color2
else
arg3:Bind(textLabel, "TextColor3", v86[139])
end

textLabel.Parent = frame
local n = arg4.Glyph ~= nil and 51 or 13
local frame2 = Instance.new("Frame")
frame2.AnchorPoint = Vector2.new(v86[186], 0.5)
frame2.Position = UDim2.new(0, n, 0.5, 0)
frame2.Size = UDim2.new(v86[63], -n - v86[192], 0, 34)
frame2.BackgroundTransparency = v86[63]
frame2.BorderSizePixel = 0
frame2.Parent = instance
local textLabel2 = Instance.new("TextLabel")
textLabel2.Size = UDim2.new(1, 0, v86[186], 16)
textLabel2.BackgroundTransparency = 1
textLabel2.BorderSizePixel = 0
textLabel2.Text = arg4.Title
textLabel2.TextSize = v86[118]
textLabel2.TextTruncate = Enum.TextTruncate.AtEnd
textLabel2.TextXAlignment = Enum.TextXAlignment.Left
textLabel2.FontFace = v118.Bold
arg3:Bind(textLabel2, "TextColor3", v86[174])
textLabel2.Parent = frame2
local instance2 = Instance.new(v86[135])
instance2.Position = UDim2.fromOffset(0, 18)
instance2.Size = UDim2.new(1, 0, 0, 16)
instance2.BackgroundTransparency = 1
instance2.BorderSizePixel = 0
instance2.Text = arg4.Description or ""
instance2.TextSize = 11
instance2.TextWrapped = v86[153]
instance2.TextTruncate = Enum.TextTruncate.AtEnd
instance2.TextXAlignment = Enum.TextXAlignment.Left
instance2.TextYAlignment = Enum.TextYAlignment.Top
instance2.FontFace = v118.SemiBold
instance2.Visible = arg4.Description ~= nil and arg4.Description ~= ""
arg3:Bind(instance2, "TextColor3", "Unselected")
instance2.Parent = frame2
local textLabel3 = Instance.new("TextLabel")
textLabel3.AnchorPoint = Vector2.new(1, 0.5)
textLabel3.Position = UDim2.new(1, -11, 0.5, 0)
textLabel3.Size = UDim2.fromOffset(16, 24)
textLabel3.BackgroundTransparency = 1
textLabel3.BorderSizePixel = 0
textLabel3.Text = "›"
textLabel3.TextSize = 18
textLabel3.FontFace = v118.SemiBold
arg3:Bind(textLabel3, "TextColor3", "Unselected")
textLabel3.Parent = instance
local flag19 = false

local function fn42(arg6)
if flag19 == arg6 then
return
end
flag19 = arg6
local n33 = 1

if arg6 then
n33 = 0
end

local Accent = arg4.Variant == "danger" and color2 or v124.get("Accent")
local v126 = arg6 and color3 or color
local Unselected = arg6 and Accent or v124.get("Unselected")
local udim2 = UDim2.new(1, arg6 and -7 or -11, 0.5, 0)
arg:Tween(uiStroke, { Transparency = n33 }, tweenInfo)
arg:Tween(instance, { BackgroundColor3 = v126 }, tweenInfo)
arg:Tween(textLabel3, { TextColor3 = Unselected, Position = udim2 }, tweenInfo)
end

local function fn43()
local v126 = v125.getPointerPosition()

for _, v127 in coreGui:GetGuiObjectsAtPosition(v126.X, v126.Y) do
if v127 == instance or v127:IsDescendantOf(instance) then
fn42(true)
return
end
end

fn42(false)
end

arg2:Connect(instance.MouseEnter, function()
fn42(true)
end)

arg2:Connect(instance.MouseLeave, function()
fn42(false)
end)

v120.connectClick(arg2, instance, arg5)
return { Object = instance, SyncHover = fn43 }
end

index3.new = function(arg, arg2, arg3, arg4, arg5)
local v126 = arg3:Extend()
local v127 = v124.newBatch(v126)
local v128 = v119.IsMobile()
local n = v128 and 46 or 50
local canvasGroup = Instance.new("CanvasGroup")
canvasGroup.Visible = false
canvasGroup.GroupTransparency = 1
canvasGroup.BackgroundTransparency = v86[63]
canvasGroup.BorderSizePixel = 0
canvasGroup.Active = v86[34]
canvasGroup.ClipsDescendants = v86[34]
canvasGroup.Parent = arg:GetOverlayLayer()
v126:Add(canvasGroup)
local instance = Instance.new(v86[128])
instance.Size = UDim2.fromScale(1, 1)
instance.BorderSizePixel = 0
instance.BackgroundColor3 = Color3.new(0, 0, v86[186])
instance.BackgroundTransparency = 0.58
instance.ZIndex = 1
instance.Parent = canvasGroup
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, v86[54])
uiCorner.Parent = instance
local canvasGroup2 = Instance.new("CanvasGroup")
canvasGroup2.AnchorPoint = Vector2.new(0.5, 0.5)
canvasGroup2.Position = UDim2.new(v86[101], 0, 0.5, -15)
canvasGroup2.Size = UDim2.fromOffset(520, v86[186])
canvasGroup2.AutomaticSize = Enum.AutomaticSize.Y
canvasGroup2.BorderSizePixel = 0
canvasGroup2.BackgroundTransparency = 1
canvasGroup2.ZIndex = 2
canvasGroup2.Parent = canvasGroup
local frame = Instance.new("Frame")
frame.Size = UDim2.fromScale(1, 1)
frame.BorderSizePixel = 0
frame.BackgroundColor3 = color
frame.ZIndex = v86[186]
frame.Parent = canvasGroup2
local uiCorner2 = Instance.new("UICorner")
uiCorner2.CornerRadius = UDim.new(0, 8)
uiCorner2.Parent = frame
local uiGradient = Instance.new("UIGradient")
uiGradient.Rotation = v86[45]
v116.bindSurfaceGradient(v127, uiGradient, { "GradientTop", v86[187], v86[70] })
uiGradient.Parent = frame
local uiCorner3 = Instance.new("UICorner")
uiCorner3.CornerRadius = UDim.new(0, 8)
uiCorner3.Parent = canvasGroup2
local uiStroke = Instance.new("UIStroke")
v127:Bind(uiStroke, "Color", "Outline")
uiStroke.Parent = canvasGroup2
v116.addGlow(v127, canvasGroup2, { Amount = 5, DampingFactor = 0.65 })
local frame2 = Instance.new("Frame")
frame2.Size = UDim2.fromScale(1, 0)
frame2.AutomaticSize = Enum.AutomaticSize.Y
frame2.BackgroundTransparency = 1
frame2.BorderSizePixel = 0
frame2.Parent = canvasGroup2
local instance2 = Instance.new(v86[4])
instance2.SortOrder = Enum.SortOrder.LayoutOrder
instance2.Parent = frame2
local v129 = fn39(v127, frame2)
createFrame(v127, frame2, 2)
local frame3 = Instance.new("Frame")
frame3.Size = UDim2.new(1, 0, 0, v128 and v86[103] or v86[83])
frame3.BackgroundTransparency = v86[63]
frame3.BorderSizePixel = 0
frame3.LayoutOrder = 3
frame3.ClipsDescendants = v86[34]
frame3.Parent = frame2
local v130 = createFrame(v127, frame2, v86[26])
local frame4 = Instance.new("Frame")
frame4.Size = UDim2.new(1, v86[186], 0, n)
frame4.ClipsDescendants = v86[34]
frame4.BorderSizePixel = 0
frame4.BackgroundTransparency = 0.28
frame4.LayoutOrder = v86[175]
v127:Bind(frame4, "BackgroundColor3", v86[141])
frame4.Parent = frame2
local frame5 = Instance.new("Frame")
frame5.AnchorPoint = Vector2.new(1, 0.5)
frame5.Position = UDim2.new(1, -20, 0.5, 0)
frame5.Size = UDim2.fromOffset(104, 32)
frame5.BackgroundTransparency = 1
frame5.BorderSizePixel = 0

if v128 then
frame5.AnchorPoint = Vector2.new(0.5, v86[101])
frame5.Position = UDim2.fromScale(0.5, v86[101])
frame5.Size = UDim2.new(1, -26, v86[186], 38)
end

frame5.Parent = frame4
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, 9)
uiListLayout.FillDirection = Enum.FillDirection.Horizontal
uiListLayout.HorizontalFlex = Enum.UIFlexAlignment.Fill
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = frame5
local v131 = nil

local back = fn38(arg, v126, v127, frame5, "Back", "secondary", function()
local v132 = v131

if v132 ~= nil then
if v132._isConfirming then
v132:_CancelConfirmation()
else
v132:_ShowHub()
end
end
end)

back.Object.LayoutOrder = v86[63]
back.Object.Visible = v86[153]

local v132 = fn38(arg, v126, v127, frame5, "", "primary", function()
local v132 = v131

if v132 ~= nil then
v132:_RunPageAction()
end
end)

v132.Object.LayoutOrder = 2
v132.Object.Visible = false
local instance3 = Instance.new(v86[92])
instance3.AnchorPoint = Vector2.new(1, v86[186])
instance3.Position = UDim2.new(v86[63], -10, 0, 10)
instance3.Size = UDim2.fromOffset(26, v86[200])
instance3.BackgroundTransparency = v86[63]
instance3.BorderSizePixel = 0
instance3.Text = "×"
instance3.TextSize = 18
instance3.FontFace = v118.SemiBold
instance3.AutoButtonColor = false
instance3.ZIndex = 4
v127:Bind(instance3, "BackgroundColor3", "ElementBackground")
v127:Bind(instance3, "TextColor3", "Unselected")
instance3.Parent = canvasGroup2
local uiCorner4 = Instance.new("UICorner")
uiCorner4.CornerRadius = UDim.new(0, v86[54])
uiCorner4.Parent = instance3
local frame6 = Instance.new("Frame")
frame6.Position = UDim2.fromOffset(0, 0)
frame6.Size = UDim2.new(1, 0, 0, 1)
frame6.BorderSizePixel = 0
frame6.ZIndex = 3
v127:Bind(frame6, "BackgroundColor3", "Accent")
frame6.Parent = canvasGroup2
local uiGradient2 = Instance.new("UIGradient")
local numberSequence = NumberSequence.new
local tbl18 = {}
local v133 = NumberSequenceKeypoint.new(0, 1)
local v134 = NumberSequenceKeypoint.new(v86[62], 0.28)
local v135 = NumberSequenceKeypoint.new(0.5, 0)
local v136 = NumberSequenceKeypoint.new(v86[173], 0.28)
tbl18[1] = v133
tbl18[2] = v134
tbl18[3] = v135
tbl18[4] = v136

do
local values = table.pack(NumberSequenceKeypoint.new(1, v86[63]))
table.move(values, 1, values.n, 5, tbl18)
end

uiGradient2.Transparency = numberSequence(tbl18)
uiGradient2.Parent = frame6
v116.addGlow(v127, frame6, { Amount = 2, DampingFactor = v86[161] })

local v137 = arg:RegisterOverlay(canvasGroup, {
Open = v86[153],
CloseOnOutside = false,
OnToggle = function(arg6)
if arg6 then
canvasGroup.Visible = true
return
end
local v137 = v131

if v137 ~= nil and v137:IsOpen() then
v137:Close()
else
canvasGroup.Visible = false
end
end,
})

v126:Add({ Destroy = function()
arg:UnregisterOverlay(v137)
end })

local v138 = fn40(v127, frame3)
local frame7 = Instance.new("Frame")
frame7.BackgroundTransparency = v86[63]
frame7.BorderSizePixel = 0
frame7.Parent = v138.Body
local instance4 = Instance.new(v86[128])
instance4.Size = UDim2.fromScale(1, v86[186])
instance4.BackgroundTransparency = 1
instance4.BorderSizePixel = v86[186]
instance4.Parent = frame7
local uiGridLayout = Instance.new("UIGridLayout")
uiGridLayout.CellPadding = UDim2.fromOffset(v86[133], 10)
uiGridLayout.FillDirectionMaxCells = v128 and 1 or 2
uiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiGridLayout.Parent = instance4

local obj = setmetatable({
_trove = v126,
_menu = arg,
_window = arg2,
_batch = v127,
_root = canvasGroup,
_panel = canvasGroup2,
_header = v129,
_closeButton = instance3,
_bodyHost = frame3,
_hubView = v138,
_hubContent = frame7,
_routes = instance4,
_routeLayout = uiGridLayout,
_routeButtons = {},
_footer = frame4,
_actionHolder = frame5,
_footerDivider = v130,
_footerHeightTween = nil,
_backAction = back,
_pageAction = v132,
_entry = v137,
_pages = {},
_activePage = nil,
_activeView = nil,
_bodyHeightTween = nil,
_rootTitle = arg4.Title,
_rootDescription = arg4.Description,
_activeDescription = arg4.Description,
_isConfirming = v86[153],
_onClosed = arg5,
_isOpen = false,
_isResolving = false,
_isDestroyed = false,
_didNotifyClosed = false,
_keyboardSyncToken = v86[186],
_previousSelectedObject = nil,
_hasSelectionGroup = false,
}, index3)

v131 = obj

v120.connectClick(v126, instance3, function()
obj:Close()
end)

v126:Connect(instance3.MouseEnter, function()
arg:Tween(instance3, { BackgroundTransparency = 0, TextColor3 = v124.get("TextColor") }, tweenInfo)
end)

v126:Connect(instance3.MouseLeave, function()
arg:Tween(instance3, { BackgroundTransparency = v86[63], TextColor3 = v124.get("Unselected") }, tweenInfo)
end)

v126:Connect(canvasGroup2:GetPropertyChangedSignal("AbsoluteSize"), function()
if obj._isOpen then
obj._panel.Position = obj:_ResolvePanelPosition(0)
end
end)

v126:Connect(arg2:GetPropertyChangedSignal("AbsolutePosition"), function()
obj:_SyncBounds()
end)

v126:Connect(arg2:GetPropertyChangedSignal("AbsoluteSize"), function()
obj:_SyncBounds()
end)

v126:Connect(arg.VisibilityChanged, function(arg6)
if not arg6 then
obj:Close()
end
end)

v126:Connect(userInputService.InputBegan, function(arg6)
if not obj._isOpen or arg6.KeyCode ~= Enum.KeyCode.Escape then
return
end

if arg:ShouldBlockKeybindCapture(arg6) then
return
end

if obj._isConfirming then
obj:_CancelConfirmation()
elseif obj._activePage ~= nil then
obj:_ShowHub()
else
obj:Close()
end
end)

v125.connectOnScreenKeyboard(v126, function()
obj:_SyncKeyboard()
end)

v126:Connect(userInputService.TextBoxFocused, function(arg6)
if arg6:IsDescendantOf(canvasGroup2) then
obj:_SyncKeyboard()
end
end)

v126:Connect(userInputService.TextBoxFocusReleased, function(arg6)
if arg6:IsDescendantOf(canvasGroup2) then
obj:_SyncKeyboard()
end
end)

obj:_ShowHub()
obj:_SyncBounds()
return obj
end

index3.AddPage = function(arg, arg2, arg3)
if arg._isDestroyed then
error(v86[145], 2)
end

local v126 = nil

local v127 = index2.new(arg._menu, arg._bodyHost, arg._entry, arg2, function()
local v127 = v126

if v127 ~= nil then
arg:_ShowPage(v127)
end
end, function(arg4)
if arg._activePage == v126 then
arg._pageAction.SetEnabled(arg4)
end
end)

arg._trove:Add(v127)
table.insert(arg._pages, v127)

local v128 = fn41(arg._menu, arg._trove, arg._batch, arg._routes, arg2, function()
v127:Open()
end)

v128.Object.LayoutOrder = #arg._pages
table.insert(arg._routeButtons, v128)

arg._trove:Connect(v127._contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
if arg._activePage == v127 then
arg:_UpdateLayout(true)
end
end)

if arg3 ~= nil then
arg3(v127.Container)
end

arg:_UpdateLayout()
v126 = v127
return v127
end

index3._SetHeader = function(arg, text, activeDescription)
local header = arg._header
arg._activeDescription = activeDescription
header.Title.Text = text
header.Description.Text = activeDescription or ""
header.Description.Visible = activeDescription ~= nil and activeDescription ~= "" and not arg:_IsKeyboardVisible()

if arg._isOpen then
header.Title.TextTransparency = 1
header.Description.TextTransparency = v86[63]
arg._menu:Tween(header.Title, { TextTransparency = 0 })
arg._menu:Tween(header.Description, { TextTransparency = 0 })
end
end

index3._ApplyFooter = function(arg, arg2)
local visible = not (arg2 == nil)
arg._backAction.Object.Visible = visible
arg._backAction.Object.Text = arg._isConfirming and "Cancel" or "Back"
local actionText = arg2 and arg2._props.ActionText or nil
local visible2 = actionText ~= nil and actionText ~= ""
arg._pageAction.Object.Visible = visible2

if visible2 and arg2 ~= nil then
local confirmation = arg2._props.Confirmation

if arg._isConfirming and confirmation ~= nil then
arg._pageAction.Object.Text = confirmation.ActionText or "Confirm"
else
arg._pageAction.Object.Text = actionText
end

local str7 = v86[114]

if arg2._props.Variant == "danger" then
str7 = "danger"
end

arg._pageAction.SetVariant(str7)
arg._pageAction.SetEnabled(arg2._isActionEnabled)
end

if not v119.IsMobile() then
local n = visible2 and v86[56] or 1
arg._actionHolder.Size = UDim2.fromOffset(n * 104 + (n - 1) * 9, 32)
end

arg._footerDivider.Visible = visible
local n = 0

if visible then
n = v119.IsMobile() and 46 or 50
end

local udim2 = UDim2.new(1, 0, 0, n)
local footerHeightTween = arg._footerHeightTween

if footerHeightTween ~= nil then
arg._footerHeightTween = nil
footerHeightTween:Cancel()
end

if arg._footer.Size ~= udim2 then
if arg._isOpen then
arg._footerHeightTween = arg._menu:Tween(arg._footer, { Size = udim2 })
else
arg._footer.Size = udim2
end
end
end

index3._ShowHub = function(arg)
if arg._isDestroyed or arg._isResolving then
return
end
arg._isConfirming = false
arg._menu:CloseOverlayDescendants(arg._entry)
arg._activePage = nil
arg._hubView.Body.CanvasPosition = Vector2.zero
arg:_TransitionViews(arg._hubView, -1)
arg:_SetHeader(arg._rootTitle, arg._rootDescription)
arg:_ApplyFooter(nil)
arg:_UpdateLayout(true)
arg:_SyncRouteHover()
end

index3._ShowPage = function(arg, activePage)
if arg._isDestroyed or arg._isResolving or not arg._isOpen then
return
end
arg._isConfirming = false
arg._menu:CloseOverlayDescendants(arg._entry)
arg._activePage = activePage
activePage._view.Body.CanvasPosition = Vector2.zero
arg:_TransitionViews(activePage._view, v86[63])
arg:_SetHeader(activePage._props.Title, activePage._props.Description)
arg:_ApplyFooter(activePage)
local onOpen = activePage._props.OnOpen

if onOpen ~= nil then
local v126, v127 = v107(onOpen)

if not v126 then
error(v127, 2)
end
end

arg:_UpdateLayout(true)
end

index3._BeginConfirmation = function(arg, arg2)
local confirmation = arg2._props.Confirmation
if confirmation == nil then
return
end
local description = confirmation.Description

if type(description) == "function" then
description = description()
end

arg._isConfirming = true
arg:_TransitionViews(nil, 0)
arg:_SetHeader(confirmation.Title or "Confirm action", description)
arg:_ApplyFooter(arg2)
arg:_UpdateLayout(true)
end

index3._CancelConfirmation = function(arg)
local activePage = arg._activePage
if not arg._isConfirming or activePage == nil or arg._isResolving then
return
end
arg._isConfirming = false
arg:_TransitionViews(activePage._view, v86[186])
arg:_SetHeader(activePage._props.Title, activePage._props.Description)
arg:_ApplyFooter(activePage)
arg:_UpdateLayout(true)
end

index3._RunPageAction = function(arg)
local activePage = arg._activePage
if activePage == nil or not activePage._isActionEnabled or arg._isResolving or not arg:IsOpen() then
return
end

if activePage._props.Confirmation ~= nil and not arg._isConfirming then
arg:_BeginConfirmation(activePage)
return
end
arg._isResolving = true
local onAction = activePage._props.OnAction
local flag19 = true
local v126 = nil

if onAction ~= nil then
flag19, v126 = v107(onAction)
end

arg._isResolving = false

if not flag19 then
error(v126, v86[56])
end

if v126 == false or not arg._isOpen or arg._activePage ~= activePage then
return
end
arg:_ShowHub()
end

index3._IsKeyboardVisible = function(arg)
local focusedTextBox = userInputService:GetFocusedTextBox()
return v125.onScreenKeyboardTop() ~= nil and focusedTextBox ~= nil and focusedTextBox:IsDescendantOf(arg._panel)
end

index3._GetKeyboardTop = function()
local guiInset = guiService:GetGuiInset()
return (v125.onScreenKeyboardTop() or 0) - guiInset.Y
end

local function fn42(arg, arg2)
local v126 = v86[56]
return math.round(arg - arg2) % 2 / v126
end

index3._ResolvePanelPosition = function(arg, arg2)
local absoluteSize = arg._root.AbsoluteSize
local absoluteSize2 = arg._panel.AbsoluteSize
local v126 = fn42(absoluteSize.X, absoluteSize2.X)
if not arg:_IsKeyboardVisible() then
return UDim2.new(0.5, v126, v86[101], arg2 + fn42(absoluteSize.Y, absoluteSize2.Y))
end
local y = absoluteSize2.Y
local absolutePosition = arg._root.AbsolutePosition
local v127 = v86[162]
return UDim2.new(0.5, v126, 0, math.round(math.max(absolutePosition.Y + 8 + y / v86[56], math.min(absolutePosition.Y + absoluteSize.Y / 2, arg:_GetKeyboardTop() - v127 - y / 2)) - absolutePosition.Y + arg2))
end

index3._GetActiveBody = function(arg)
local activePage = arg._activePage
if activePage ~= nil then
return activePage._view.Body
end
return arg._hubView.Body
end

index3._ScrollFocusedTextBox = function(arg)
if not arg:_IsKeyboardVisible() then
return
end
local v126 = arg:_GetActiveBody()
local focusedTextBox = userInputService:GetFocusedTextBox()
if focusedTextBox == nil or not focusedTextBox:IsDescendantOf(v126) then
return
end
local y = v126.AbsoluteWindowSize.Y
if y <= 0 then
return
end
local y2 = v126.CanvasPosition.Y
local n = focusedTextBox.AbsolutePosition.Y - v126.AbsolutePosition.Y + y2
local n33 = n + focusedTextBox.AbsoluteSize.Y

if n < y2 + v86[162] then
y2 = n - 8
elseif y2 + y - 8 < n33 then
y2 = n33 - y + 8
end

local n34 = math.max(v86[186], v126.AbsoluteCanvasSize.Y - y)
v126.CanvasPosition = Vector2.new(v126.CanvasPosition.X, math.clamp(y2, 0, n34))
end

index3._SyncKeyboard = function(arg)
if arg._isDestroyed then
return
end
arg._keyboardSyncToken = arg._keyboardSyncToken + 1
local keyboardSyncToken = arg._keyboardSyncToken
local activeDescription = arg._activeDescription
arg._header.Description.Visible = activeDescription ~= nil and activeDescription ~= "" and not arg:_IsKeyboardVisible()

task.defer(function()
if arg._isDestroyed or arg._keyboardSyncToken ~= keyboardSyncToken then
return
end
arg:_UpdateLayout()

task.defer(function()
if arg._isDestroyed or arg._keyboardSyncToken ~= keyboardSyncToken then
return
end
local v126 = arg:_ResolvePanelPosition(0)

if arg._isOpen and arg._root.Visible then
arg._menu:Tween(arg._panel, { Position = v126 })
else
arg._panel.Position = v126
end

arg:_ScrollFocusedTextBox()
end)
end)
end

index3._SetBodyHeight = function(arg, arg2, arg3)
local udim2 = UDim2.new(1, 0, 0, arg2)
local bodyHeightTween = arg._bodyHeightTween

if bodyHeightTween ~= nil then
arg._bodyHeightTween = nil
bodyHeightTween:Cancel()
end

if arg._bodyHost.Size == udim2 then
return
end

if arg3 and arg._isOpen then
arg._bodyHeightTween = arg._menu:Tween(arg._bodyHost, { Size = udim2 })
else
arg._bodyHost.Size = udim2
end
end

index3._TransitionViews = function(arg, activeView, arg2)
local activeView2 = arg._activeView
if activeView2 == activeView then
return
end
arg._activeView = activeView

if not arg._isOpen then
if activeView2 ~= nil then
activeView2.Group.Visible = false
activeView2.Group.GroupTransparency = 1
end

if activeView ~= nil then
activeView.Group.Position = UDim2.fromOffset(0, 0)
activeView.Group.GroupTransparency = 0
activeView.Group.Visible = true
end

return
end

if activeView2 ~= nil then
arg._menu:FadeCanvasGroup(activeView2.Group, v86[153], activeView2.Fade)
end

if activeView ~= nil then
if arg2 ~= 0 then
activeView.Group.Position = UDim2.fromOffset(arg2 * 16, 0)
arg._menu:Tween(activeView.Group, { Position = UDim2.fromOffset(0, 0) })
else
activeView.Group.Position = UDim2.fromOffset(0, 0)
end

arg._menu:FadeCanvasGroup(activeView.Group, true, activeView.Fade)
end
end

index3._SyncRouteHover = function(arg)
if v119.IsMobile() then
return
end

task.defer(function()
if arg._isDestroyed or arg._activeView ~= arg._hubView then
return
end

for _, v126 in arg._routeButtons, nil, nil do
v126.SyncHover()
end
end)
end

index3._UpdateLayout = function(arg, arg2)
if arg._isDestroyed then
return
end
local v126 = v119.IsMobile()
local n = v126 and 8 or v86[144]
local n33 = v126 and v86[103] or 64
local n34 = v126 and v86[118] or 20
local n35 = v126 and v86[181] or 14
local n36 = v126 and 56 or 60
local absoluteSize = arg._root.AbsoluteSize

if absoluteSize.X > 0 then
arg._panel.Size = UDim2.fromOffset(math.max(0, math.min(520, absoluteSize.X - n * 2)), 0)
end

local v127 = math.ceil(#arg._pages / 1)
local n37 = 0

if v127 > 0 then
n37 = v127 * n36 + (v127 - 1) * v86[133]
end

arg._routeLayout.FillDirectionMaxCells = 1
arg._routeLayout.CellSize = UDim2.new(1, 0, 0, n36)
arg._routes.Size = UDim2.new(1, v86[186], 0, n37)
local activePage = arg._activePage
local n38

if activePage == nil then
arg._hubContent.Position = UDim2.fromOffset(n34, n35)
arg._hubContent.Size = UDim2.new(1, -n34 * 2, 0, n37)
n38 = n37 + n35 * 2
else
n38 = activePage:_PrepareLayout(n34, n35)
end

local n39 = 0
local n40 = 1

if activePage ~= nil then
n39 = v126 and 46 or 50
n40 = 2
end

local n41 = arg._header.Root.AbsoluteSize.Y + n39 + n40
local n42 = math.max(0, absoluteSize.Y - n * v86[56] - n41)
local n43

if arg:_IsKeyboardVisible() then
local y = arg._root.AbsolutePosition.Y
n43 = math.min(n42, math.max(0, math.max(0, arg:_GetKeyboardTop() - y - 16) - n41))
else
n43 = n42
end

local n44 = 0

if not arg._isConfirming then
n44 = math.min(math.max(n33, n38), n43)
end

arg:_SetBodyHeight(n44, arg2 == true)

if activePage == nil then
arg._hubView.Body.CanvasSize = UDim2.fromOffset(0, n38)
arg._hubView.Body.ScrollBarThickness = n38 > n44 + v86[101] and v86[26] or 0
else
activePage:_SetViewport(n44, n38)
end
end

index3._SyncBounds = function(arg)
if arg._isDestroyed then
return
end
local v126 = v125.absoluteToLayerOffset(arg._menu:GetOverlayLayer(), arg._window.AbsolutePosition)
local absoluteSize = arg._window.AbsoluteSize
local floor2 = math.floor
local n = v126.Y + 0.5
arg._root.Position = UDim2.fromOffset(math.floor(v126.X + 0.5), floor2(n))
arg._root.Size = UDim2.fromOffset(math.floor(absoluteSize.X + v86[101]), math.floor(absoluteSize.Y + 0.5))
arg:_UpdateLayout()

if arg:_IsKeyboardVisible() then
arg:_SyncKeyboard()
end
end

index3._NotifyClosed = function(arg)
if arg._didNotifyClosed then
return
end
arg._didNotifyClosed = true
arg._onClosed()
end

index3._AcquireSelection = function(arg)
if arg._hasSelectionGroup then
return
end
arg._hasSelectionGroup = true
arg._previousSelectedObject = guiService.SelectedObject
arg._panel.SelectionGroup = true

if userInputService.GamepadEnabled then
guiService.SelectedObject = arg._closeButton
end
end

index3._ReleaseSelection = function(arg)
if not arg._hasSelectionGroup then
return
end
arg._hasSelectionGroup = false
arg._panel.SelectionGroup = false
local selectedObject = guiService.SelectedObject

if selectedObject ~= nil and selectedObject:IsDescendantOf(arg._panel) then
local previousSelectedObject = arg._previousSelectedObject

if previousSelectedObject ~= nil and previousSelectedObject.Parent ~= nil then
guiService.SelectedObject = previousSelectedObject
else
guiService.SelectedObject = nil
end
end

arg._previousSelectedObject = nil
end

index3._AnimateClosed = function(arg)
arg._menu:CloseOverlayDescendants(arg._entry)
local v126 = arg._menu:Tween(arg._root, { GroupTransparency = 1 })
arg._menu:Tween(arg._panel, { Position = arg:_ResolvePanelPosition(-15) })
if v126 == nil then
arg:Destroy()
return
end

arg._trove:Connect(v126.Completed, function()
arg:Destroy()
if not flag3 then
return
end
end)
end

index3._Open = function(arg)
if arg._isDestroyed or arg._isOpen then
return
end
arg._isOpen = true

task.defer(function()
if arg._isDestroyed or not arg._isOpen then
return
end
arg:_SyncBounds()
arg._hubView.Body.CanvasPosition = Vector2.zero
arg._root.GroupTransparency = 1
arg._panel.Position = arg:_ResolvePanelPosition(-15)
arg._menu:SetOverlayOpen(arg._entry, true)
arg:_AcquireSelection()
local v126 = arg:_ResolvePanelPosition(0)
local v127 = arg._menu:Tween(arg._root, { GroupTransparency = v86[186] })
local v128 = arg._menu:Tween(arg._panel, { Position = v126 })

if v127 == nil then
arg._root.GroupTransparency = v86[186]
end

if v128 == nil then
arg._panel.Position = v126
end

arg:_SyncRouteHover()
end)
end

index3.IsOpen = function(arg)
return arg._isOpen and not arg._isDestroyed
end

index3.Close = function(arg)
if not arg:IsOpen() then
return
end
arg._isOpen = v86[153]
arg:_ReleaseSelection()
arg:_NotifyClosed()
arg:_AnimateClosed()
end

index3.Destroy = function(arg)
if arg._isDestroyed then
return
end
arg._isDestroyed = true
arg._isOpen = false
arg:_NotifyClosed()
arg:_ReleaseSelection()
arg._trove:Destroy()
end

return index3
end

tbl17.ac = function()
local ac = tbl17.cache.ac

if not ac then
ac = { c = fn35() }
tbl17.cache.ac = ac
end

return ac.c
end
end
do -- ad
local function fn35()
local v115 = tbl17.b()
tbl17.a()
local index2 = {}
index2.__index = index2

index2.new = function()
local tbl18 = { _errors = {}, _sink = v115.get() }
setmetatable(tbl18, index2)
return tbl18
end

index2.Report = function(arg, arg2)
local errors = arg._errors

if #errors >= v86[137] then
table.remove(errors, v86[63])
end

table.insert(errors, arg2)
local sink = arg._sink

if sink ~= nil then
sink:Report(arg2)
end
end

index2.ReportResult = function(arg, arg2)
if not arg2.Ok then
arg:Report(arg2.Error)
end

return arg2
end

index2.GetErrors = function(arg)
return arg._errors
end

index2.Destroy = function(arg)
table.clear(arg._errors)
arg._sink = nil
end

return index2
end

tbl17.ad = function()
local ad = tbl17.cache.ad

if not ad then
local ad2 = { c = fn35() }
tbl17.cache.ad = ad2
ad = ad2
end

return ad.c
end
end
do -- ae
local function fn35()local I,W= tbl17 .f(), tbl17 .ad(); tbl17 .a(); tbl17 .r();local l={};l.__index=l;local N={AutoSave=false,AutoSaveConfigName=nil,AutoLoad=false,AutoLoadConfigName=nil,Keybind="RightShift",Size=nil,Position=nil,KeybindsListPosition=nil,WatermarkPosition=nil,MobileButtonPositions=nil,ShowKeybinds=nil,ShowWatermark=nil,MenuKeybindInList=nil,HideMobileMenuButton=nil,SilentLoad=nil};local function P(a)return(a:gsub("%.json$",""));end;local function a(e)if type(e)~="table"then return nil;end;local c,E=e[1],e[2];if type(c)~="number"or type(E)~="number"then return nil;end;if c~=c or E~=E then return nil;end;return{c,E};end;local function e(c)if type(c)~="table"then return nil;end;local E,p={},false;for T,t in c,nil,nil do if type(T)~="string"or T==""then continue;end;local c_26=a(t);if c_26==nil then continue;end;E[T]=c_26;p=true;end;return p and E or nil;end;local function c(E)local p=table.clone(N);if type(E)~="table"then return p;end;if type(E.AutoSave)=="boolean"then p.AutoSave=E.AutoSave;end;if type(E.AutoSaveConfigName)=="string"then p.AutoSaveConfigName=P(E.AutoSaveConfigName);end;if type(E.AutoLoad)=="boolean"then p.AutoLoad=E.AutoLoad;end;if type(E.AutoLoadConfigName)=="string"then p.AutoLoadConfigName=P(E.AutoLoadConfigName);end;if type(E.Keybind)=="string"then p.Keybind=E.Keybind;end;if type(E.ShowKeybinds)=="boolean"then p.ShowKeybinds=E.ShowKeybinds;end;if type(E.ShowWatermark)=="boolean"then p.ShowWatermark=E.ShowWatermark;end;if type(E.MenuKeybindInList)=="boolean"then p.MenuKeybindInList=E.MenuKeybindInList;end;if type(E.HideMobileMenuButton)=="boolean"then p.HideMobileMenuButton=E.HideMobileMenuButton;end;if type(E.SilentLoad)=="boolean"then p.SilentLoad=E.SilentLoad;end;p.Size=a(E.Size);p.Position=a(E.Position);p.KeybindsListPosition=a(E.KeybindsListPosition);p.WatermarkPosition=a(E.WatermarkPosition);p.MobileButtonPositions=e(E.MobileButtonPositions);return p;end;local function P_27(a)if type(a)~="table"then return{};end;local e=table.clone(a);a=e.autosave;e.autosave=nil;if type(a)=="string"then e.AutoSave=true;e.AutoSaveConfigName=a;end;a=e.autoload;e.autoload=nil;if type(a)=="string"then e.AutoLoad=true;e.AutoLoadConfigName=a;end;return e;end;local function a_28(e)if type(e)~="table"then return{};end;local E,p=table.clone(e),{"autoSave","autoSaveConfigName","autoLoad","autoLoadConfigName","keybind","size","position","keybindsListPosition","watermarkPosition","mobileButtonPositions","showKeybinds","showWatermark","menuKeybindInList","hideMobileMenuButton","silentLoad"};for T,T_29 in p,nil,nil do e=string.upper(string.sub(T_29,1,1))..string.sub(T_29,2);if E[e]==nil then E[e]=E[T_29];end;E[T_29]=nil;end;return E;end;l.new=function(e)return setmetatable({_errorReporter=W.new(),_manager=I.new({DefaultConfig=N,CurrentVersion=3,SavePath=e,Deserialize=c,Migrations={[1]=P_27,[2]=a_28}})},l);end;l.Load=function(I)if not I._manager:Exists("general")then return I._manager:Reset();end;local W=I._manager:LoadFromFile("general");if W.Ok then return W.Value;end;I._errorReporter:Report(W.Error);return I._manager:Reset();end;l.Save=function(I,W)I._manager:SetData(W);return I._errorReporter:ReportResult(I._manager:SaveToFile("general"));end;l.Destroy=function(I)I._errorReporter:Destroy();end;return l;end

tbl17.ae = function()
local ae = tbl17.cache.ae

if not ae then
ae = { c = fn35() }
tbl17.cache.ae = ae
end

return ae.c
end
end
do -- af
local function fn35()
tbl17.k()
local v115 = tbl17.ab()
tbl17.r()
local v116 = tbl17.v()
local v117 = tbl17.X()
tbl17.A()
local index2 = {}
index2.__index = index2

local function createScrollingFrame(arg, parent, arg2)
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.ScrollBarImageTransparency = 1
scrollingFrame.ScrollBarThickness = 0
scrollingFrame.Size = UDim2.fromScale(v86[63], v86[63])
scrollingFrame.Selectable = v86[153]
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollingFrame.BorderSizePixel = 0
scrollingFrame.CanvasSize = UDim2.new(v86[186], 0, 0, 0)
arg:Bind(scrollingFrame, "ScrollBarImageColor3", "Accent")
scrollingFrame.Parent = parent
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingTop = UDim.new(0, v86[63])
uiPadding.PaddingBottom = UDim.new(0, 1)
uiPadding.PaddingRight = UDim.new(0, 1)
uiPadding.PaddingLeft = UDim.new(0, v86[63])
uiPadding.Parent = scrollingFrame
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, arg2)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.HorizontalFlex = Enum.UIFlexAlignment.Fill
uiListLayout.Parent = scrollingFrame
return scrollingFrame
end

index2.new = function(arg, parent, arg2, arg3, arg4, arg5)
local v118 = v116.get()
local columns = v86[56]

if arg4 ~= nil and arg4.Columns ~= nil then
columns = arg4.Columns
end

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.FillDirection = Enum.FillDirection.Horizontal
uiListLayout.HorizontalFlex = Enum.UIFlexAlignment.Fill
uiListLayout.Padding = UDim.new(v86[186], v118.Grid.Gap)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.VerticalFlex = Enum.UIFlexAlignment.Fill
uiListLayout.Parent = parent
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Visible = false
scrollingFrame.ScrollBarImageTransparency = 1
scrollingFrame.ScrollBarThickness = 0
scrollingFrame.Size = UDim2.fromScale(1, 1)
scrollingFrame.Selectable = v86[153]
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollingFrame.BorderSizePixel = v86[186]
scrollingFrame.CanvasSize = UDim2.new(0, v86[186], v86[186], v86[186])
scrollingFrame.ZIndex = v86[56]
arg3:Bind(scrollingFrame, "ScrollBarImageColor3", "Accent")
scrollingFrame.Parent = parent
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingTop = UDim.new(0, 1)
uiPadding.PaddingBottom = UDim.new(0, 1)
uiPadding.PaddingRight = UDim.new(0, v86[63])
uiPadding.PaddingLeft = UDim.new(0, 1)
uiPadding.Parent = scrollingFrame
local uiListLayout2 = Instance.new("UIListLayout")
uiListLayout2.Padding = UDim.new(0, v118.Section.Gap)
uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout2.HorizontalFlex = Enum.UIFlexAlignment.Fill
uiListLayout2.Parent = scrollingFrame
local tbl18 = {}

for i = v86[63], columns do
table.insert(tbl18, createScrollingFrame(arg3, parent, v118.Section.Gap))
end

return setmetatable({
_trove = arg2,
_layoutTrove = arg2:Extend(),
_menu = arg,
_batch = arg3,
_parent = parent,
_effectiveColumns = columns,
Columns = columns,
_columns = tbl18,
_fullPage = scrollingFrame,
_items = {},
_realized = false,
_searchHost = arg5,
_hasFullSection = false,
_layoutQueued = false,
_columnCanvasPositions = {},
_fullCanvasPosition = Vector2.zero,
}, index2)
end

index2._SetMode = function(arg, visible)
if arg._fullPage.Visible == visible then
return
end

if arg._fullPage.Visible then
arg._fullCanvasPosition = arg._fullPage.CanvasPosition
else
for k, v118 in arg._columns, nil, nil do
arg._columnCanvasPositions[k] = v118.CanvasPosition
end
end

arg._fullPage.Visible = visible

for k, v118 in arg._columns, nil, nil do
local visible2 = not visible
v118.Visible = visible2

if visible2 then
v118.CanvasPosition = arg._columnCanvasPositions[k] or Vector2.zero
end
end

if visible then
arg._fullPage.CanvasPosition = arg._fullCanvasPosition
end
end

index2._ResolveColumnCount = function(arg)
if arg._hasFullSection or arg.Columns <= 1 then
return 1
end
local x = arg._parent.AbsoluteSize.X
if x <= 0 then
return arg.Columns
end
local v118 = v116.get()
local gap = v118.Grid.Gap
local n = math.max(1, math.floor((x + gap) / (v118.Grid.MinColumnWidth + gap)))
return math.min(arg.Columns, n)
end

index2._ParentForSide = function(arg, arg2)
if arg._effectiveColumns == 1 or arg2 == "full" then
return arg._fullPage
end

if arg2 == "right" and arg._effectiveColumns >= 2 then
return arg._columns[2]
end
return arg._columns[1]
end

index2._ApplyResponsiveLayout = function(arg)
local v118 = arg:_ResolveColumnCount()
arg._effectiveColumns = v118
arg:_SetMode(v118 == 1)

for k, v119 in arg._items, nil, nil do
v119.Reparent(arg:_ParentForSide(v119.Side), k)
end
end

index2.ColumnParent = function(arg, arg2)
return arg:_ParentForSide(arg2)
end

index2.AddSection = function(arg, arg2)
if arg2.Side == "full" then
arg._hasFullSection = true
end

local v118 = v115.BuildSection(arg._menu, arg._trove, arg2, function()
return arg:ColumnParent(arg2.Side)
end)

arg:_RegisterItem(arg2.Side, function()
v118:Realize()
end, function(arg3, arg4)
v118:_SetGridParent(arg3, arg4)
end)

arg._menu:RegisterSearchSection(arg._searchHost, v118, function(arg3, arg4, arg5)
v118:CollectSearchHits(arg3, arg4, arg5)
end)

return v118
end

index2.AddMultiSection = function(arg, arg2)
if arg2.Side == "full" then
arg._hasFullSection = true
end

local v118 = v115.BuildPanes(arg._menu, arg._trove, arg2.Titles)

local v119 = v117.new(arg._menu, arg._trove, v118, function()
return arg:ColumnParent(arg2.Side)
end)

arg:_RegisterItem(arg2.Side, function()
v119:Realize()
end, function(arg3, arg4)
v119:_SetGridParent(arg3, arg4)
end)

for k, v120 in v118, nil, nil do
arg._menu:RegisterSearchSection(arg._searchHost, v120, function(arg3, arg4, arg5)
v120:CollectSearchHits(arg3, arg4, arg5, { Reveal = function()
v119:SelectPane(k)
end })
end)
end

return table.unpack(v118)
end

index2._RegisterItem = function(arg, arg2, arg3, arg4)
table.insert(arg._items, { Side = arg2, Realize = arg3, Reparent = arg4 })

if arg._realized then
arg3()
arg:_ApplyResponsiveLayout()
end
end

index2.Register = function(arg, arg2)
arg:_RegisterItem(nil, arg2, function()
end)
end

index2.Realize = function(arg)
if arg._realized then
return
end
arg._effectiveColumns = arg:_ResolveColumnCount()
arg:_SetMode(arg._effectiveColumns == v86[63])
arg._realized = true

for _, v118 in arg._items, nil, nil do
v118.Realize()
end

arg:_ApplyResponsiveLayout()

arg._trove:Connect(arg._parent:GetPropertyChangedSignal(v86[131]), function()
if arg._layoutQueued then
return
end
arg._layoutQueued = true
arg._layoutTrove:Clean()

arg._layoutTrove:Add(task.defer(function()
arg._layoutQueued = v86[153]
arg:_ApplyResponsiveLayout()
end))
end)
end

return index2
end

tbl17.af = function()
local af = tbl17.cache.af

if not af then
local af2 = { c = fn35() }
tbl17.cache.af = af2
af = af2
end

return af.c
end
end
do -- ag
local function fn35() tbl17 .k();local I= tbl17 .t();local l,W,N,P=I.UserInputService,I.RunService,I.HttpService,{};P.__index=P;P.new=function(I)return setmetatable({_trove=I,_unlocked=false,_textbox=nil,_binding=nil,_oldMouseIconEnabled=nil},P);end;local function I_30(a)local e=a._textbox;if e~=nil then return e;end;e=Instance.new("TextBox");a._textbox=e;a._trove:Add(e);return e;end;P.Set=function(a,e)if a._unlocked==e then return;end;a._unlocked=e;if not l.KeyboardEnabled then return;end;if e then local e_31=I_30(a);a._oldMouseIconEnabled=l.MouseIconEnabled;local I=N:GenerateGUID(false);a._binding=I;W:BindToRenderStep(I,Enum.RenderPriority.Camera.Value+1,function()if not l.MouseIconEnabled then a._oldMouseIconEnabled=l.MouseIconEnabled;l.MouseIconEnabled=true;end;local f=l:GetFocusedTextBox();if f==nil or f==e_31 then e_31:CaptureFocus();end;end);else if a._binding~=nil then W:UnbindFromRenderStep(a._binding);a._binding=nil;end;if a._oldMouseIconEnabled~=nil then l.MouseIconEnabled=a._oldMouseIconEnabled;a._oldMouseIconEnabled=nil;end;if a._textbox~=nil then a._textbox:ReleaseFocus(false);end;end;end;P.Destroy=function(l)l:Set(false);end;return P;end

tbl17.ag = function()
local ag = tbl17.cache.ag

if not ag then
ag = { c = fn35() }
tbl17.cache.ag = ag
end

return ag.c
end
end
do -- ah
local function fn35()local I= tbl17 .k(); tbl17 .r();local W,N= tbl17 .t().UserInputService,{};N.__index=N;N.new=function(l)local P=I.new();local I={_trove=P,_captureTrove=P:Extend(),_active=nil,_pending=nil,_generation=0,_deliveryTrove=P:Extend(),_capturedInputSet={}};setmetatable(I._capturedInputSet,{__mode="k"});P=setmetatable(I,N);l:Add(P);return P;end;N.ShouldBlockMenuToggle=function(l,I)return l._active~=nil or l._capturedInputSet[I]==true;end;N.Begin=function(l,I)l:Cancel();l._generation=l._generation+1;local P=l._generation;l._active=I;l._captureTrove:Connect(W.InputBegan,function(I,W)if I.UserInputType==Enum.UserInputType.Touch then l:Cancel();return;end;local a=I.UserInputType;local e,c=a==Enum.UserInputType.Keyboard,a==Enum.UserInputType.MouseButton1 or a==Enum.UserInputType.MouseButton2 or a==Enum.UserInputType.MouseButton3;if not e and not c then return;end;c=e and I.KeyCode==Enum.KeyCode.Escape;if e and not c and W then return;end;local W_32=l._active;l:_Disarm();if W_32==nil then return;end;local E="None";if not c then if e then E=I.KeyCode;else E=a;end;end;l._capturedInputSet[I]=true;l._pending=W_32;l._deliveryTrove:Add(task.defer(function()if l._generation~=P or l._pending~=W_32 then return;end;l._pending=nil;l._capturedInputSet[I]=nil;W_32(E);end));end);return function()if l._generation==P then l:Cancel();end;end;end;N._Disarm=function(l)l._captureTrove:Clean();l._active=nil;end;N.Cancel=function(l)local I=l._active or l._pending;l._generation=l._generation+1;l._deliveryTrove:Clean();l:_Disarm();l._pending=nil;table.clear(l._capturedInputSet);if I~=nil then I(nil);end;end;N.Destroy=function(l)l:Cancel();l._trove:Destroy();end;return N;end

tbl17.ah = function()
local ah = tbl17.cache.ah

if not ah then
ah = { c = fn35() }
tbl17.cache.ah = ah
end

return ah.c
end
end
do -- ai
local function fn35()
tbl17.k()
tbl17.r()
local v115 = tbl17.u()
local v116 = tbl17.A()
local v117 = tbl17.w()
local tweenInfo = TweenInfo.new(v86[28], Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local index2 = {}
index2.__index = index2

local function fn36(arg, arg2)
return arg._enabled and arg2.Enabled
end

local function fn37(arg, arg2, visible)
local row = arg2.Row
if row == nil then
return
end
local outline = row.Outline
local fadeTween = row.FadeTween

if fadeTween ~= nil then
fadeTween:Cancel()
row.FadeTween = nil
end

local udim2 = UDim2.fromScale(1, 0)
local n = v86[63]

if visible then
udim2 = UDim2.new(v86[63], v86[186], 0, 22)
outline.Visible = v86[34]
n = 0
end

local v118 = arg._menu:Tween(outline, { Size = udim2, GroupTransparency = n }, tweenInfo)
row.FadeTween = v118
if v118 == nil then
outline.Visible = visible
return
end

if not visible then
v118.Completed:Once(function(playbackState)
if playbackState == Enum.PlaybackState.Completed then
outline.Visible = v86[153]
end
end)
end
end

local function fn38(arg)
local row = arg.Row
if row == nil then
return
end

if arg.Active then
row.Label.TextColor3 = v116.get("TextColor")
row.Label.TextTransparency = 0
row.ModeText.TextColor3 = v116.get("Accent")
row.ModeText.TextTransparency = 0
else
row.Label.TextColor3 = v116.get(v86[96])
row.Label.TextTransparency = v86[126]
row.ModeText.TextColor3 = v116.get("Unselected")
row.ModeText.TextTransparency = 0.25
end
end

local function fn39(arg, arg2)
local main = arg._menu.Fonts.Main
local canvasGroup = Instance.new("CanvasGroup")
canvasGroup.Visible = false
canvasGroup.GroupTransparency = 1
canvasGroup.BackgroundTransparency = 1
canvasGroup.BorderSizePixel = 0
canvasGroup.Size = UDim2.fromScale(1, 0)
canvasGroup.Parent = arg._rows
local frame = Instance.new("Frame")
frame.BackgroundTransparency = 1
frame.BorderSizePixel = 0
frame.Size = UDim2.fromScale(1, 1)
frame.Parent = canvasGroup
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.FillDirection = Enum.FillDirection.Horizontal
uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0, 10)
uiListLayout.Parent = frame
local instance = Instance.new(v86[135])
instance.TextTransparency = v86[186]
instance.Text = arg2.KeyText
instance.BackgroundTransparency = 1
instance.BorderSizePixel = 0
instance.Size = UDim2.new(0, v86[163], 1, v86[186])
instance.TextXAlignment = Enum.TextXAlignment.Left
instance.TextSize = 12
instance.LayoutOrder = v86[186]
instance.FontFace = main
arg._batch:Bind(instance, "TextColor3", "Accent")
instance.Parent = frame
local instance2 = Instance.new(v86[135])
instance2.Text = arg2.Label
instance2.BackgroundTransparency = 1
instance2.BorderSizePixel = 0
instance2.Size = UDim2.fromScale(v86[186], 1)
instance2.TextXAlignment = Enum.TextXAlignment.Left
instance2.TextTruncate = Enum.TextTruncate.AtEnd
instance2.TextSize = 12
instance2.LayoutOrder = v86[63]
instance2.FontFace = main
instance2.Parent = frame
local uiFlexItem = Instance.new("UIFlexItem")
uiFlexItem.FlexMode = Enum.UIFlexMode.Fill
uiFlexItem.Parent = instance2
local instance3 = Instance.new(v86[135])
instance3.Text = arg2.Mode
instance3.BackgroundTransparency = 1
instance3.BorderSizePixel = 0
instance3.AutomaticSize = Enum.AutomaticSize.X
instance3.Size = UDim2.fromScale(0, v86[63])
instance3.TextXAlignment = Enum.TextXAlignment.Right
instance3.TextSize = v86[133]
instance3.LayoutOrder = 2
instance3.FontFace = main
instance3.Parent = frame
arg2.Row = { Outline = canvasGroup, KeyText = instance, Label = instance2, ModeText = instance3, FadeTween = nil }
fn38(arg2)
end

local function fn40()
local v118 = v86[84]
return UDim2.fromOffset(50, math.min(v86[198], math.floor(v117.currentViewportSize().Y * v118)))
end

local function fn41(arg, arg2)
arg:Add(task.defer(function()
if arg2.Parent ~= nil then
v117.clampGuiToViewport(arg2)
end
end))

arg:Add(task.defer(function()
if arg2.Parent ~= nil then
v117.clampGuiToViewport(arg2)
end
end))
end

local function fn42(arg, arg2, parent, arg3)
local main = arg.Fonts.Main
local canvasGroup = Instance.new("CanvasGroup")
canvasGroup.GroupTransparency = 0
canvasGroup.BackgroundTransparency = 1
canvasGroup.Position = fn40()
canvasGroup.BorderSizePixel = v86[186]
canvasGroup.AutomaticSize = Enum.AutomaticSize.XY
canvasGroup.Parent = parent
arg3:Add(canvasGroup)
arg:MakeDraggable(canvasGroup, arg3, { PersistKey = "KeybindsListPosition" })

if v115.Scale ~= v86[63] then
local uiScale = Instance.new("UIScale")
uiScale.Scale = v115.Scale
uiScale.Parent = canvasGroup
end

local canvasGroup2 = Instance.new("CanvasGroup")
canvasGroup2.BackgroundTransparency = 0.06
canvasGroup2.BorderSizePixel = v86[186]
canvasGroup2.Size = UDim2.fromOffset(234, 0)
canvasGroup2.AutomaticSize = Enum.AutomaticSize.Y
canvasGroup2.GroupTransparency = v86[63]
canvasGroup2.Visible = false
arg2:Bind(canvasGroup2, "BackgroundColor3", "GradientDark")
canvasGroup2.Parent = canvasGroup
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 6)
uiCorner.Parent = canvasGroup2
local uiStroke = Instance.new("UIStroke")
uiStroke.Transparency = v86[87]
uiStroke.Thickness = 1
arg2:Bind(uiStroke, v86[27], "Outline")
uiStroke.Parent = canvasGroup2
local frame = Instance.new("Frame")
frame.BorderSizePixel = 0
frame.Position = UDim2.fromScale(v86[186], 0)
frame.Size = UDim2.new(0, v86[56], 1, 0)
arg2:Bind(frame, v86[5], "Accent")
frame.Parent = canvasGroup2
local frame2 = Instance.new("Frame")
frame2.BackgroundTransparency = 1
frame2.BorderSizePixel = 0
frame2.Position = UDim2.fromOffset(2, 0)
frame2.Size = UDim2.new(1, -2, 0, v86[186])
frame2.AutomaticSize = Enum.AutomaticSize.Y
frame2.Parent = canvasGroup2
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingTop = UDim.new(v86[186], v86[162])
uiPadding.PaddingBottom = UDim.new(v86[186], 9)
uiPadding.PaddingLeft = UDim.new(0, 12)
uiPadding.PaddingRight = UDim.new(0, 12)
uiPadding.Parent = frame2
local instance = Instance.new(v86[4])
instance.SortOrder = Enum.SortOrder.LayoutOrder
instance.Padding = UDim.new(0, v86[54])
instance.Parent = frame2
local textLabel = Instance.new("TextLabel")
textLabel.Text = "KEYBINDS"
textLabel.BackgroundTransparency = 1
textLabel.Size = UDim2.new(1, 0, 0, 12)
textLabel.BorderSizePixel = 0
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.TextSize = 10
textLabel.LayoutOrder = 0
textLabel.FontFace = main
arg2:Bind(textLabel, v86[167], "Unselected")
textLabel.Parent = frame2
local instance2 = Instance.new(v86[128])
instance2.BackgroundTransparency = v86[63]
instance2.Size = UDim2.fromScale(v86[63], v86[186])
instance2.AutomaticSize = Enum.AutomaticSize.Y
instance2.BorderSizePixel = 0
instance2.LayoutOrder = 1
instance2.Parent = frame2
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0, 1)
uiListLayout.Parent = instance2
return canvasGroup, canvasGroup2, instance2
end

index2.new = function(arg, arg2, arg3)
local v118 = arg3:Extend()
local v119 = v116.newBatch(v118)
local stateData = arg:GetStateData()
local flag19 = stateData ~= nil and stateData.ShowKeybinds == false
local flag20 = true

if flag19 then
flag20 = false
end

local v120, v121, v122 = fn42(arg, v119, arg2, v118)

local obj = setmetatable({
_trove = v118,
_menu = arg,
_batch = v119,
_entries = {},
_group = v120,
_card = v121,
_rows = v122,
_enabled = flag20,
_cardFadeState = { Tweening = false },
}, index2)

v119:BindStateful("Accent", function()
for _, v123 in obj._entries, nil, nil do
fn38(v123)
end
end)

v119:BindStateful("Unselected", function()
for _, v123 in obj._entries, nil, nil do
fn38(v123)
end
end)

if flag20 then
arg:FadeCanvasGroup(obj._card, true, obj._cardFadeState)
fn41(obj._trove, obj._group)
end

return obj
end

index2.SetEnabled = function(arg, enabled)
if arg._enabled == enabled then
return
end
arg._enabled = enabled

for _, v118 in arg._entries, nil, nil do
fn37(arg, v118, fn36(arg, v118))
end

arg._menu:FadeCanvasGroup(arg._card, enabled, arg._cardFadeState)

if enabled then
fn41(arg._trove, arg._group)
end

local stateData = arg._menu:GetStateData()

if stateData ~= nil then
stateData.ShowKeybinds = enabled
arg._menu:SaveState()
end
end

index2.IsEnabled = function(arg)
return arg._enabled
end

index2.AddEntry = function(arg)
local tbl18 = {
Label = v86[73],
KeyText = "NONE",
Mode = "TOGGLE",
Active = v86[153],
Enabled = false,
Row = nil,
}

table.insert(arg._entries, tbl18)

return {
SetLabel = function(arg2, label)
tbl18.Label = label
local row = tbl18.Row

if row ~= nil then
row.Label.Text = label
end
end,
SetKeyText = function(arg2, arg3)
tbl18.KeyText = arg3:upper()
local row = tbl18.Row

if row ~= nil then
row.KeyText.Text = tbl18.KeyText
end
end,
SetMode = function(arg2, arg3)
tbl18.Mode = arg3:upper()
local row = tbl18.Row

if row ~= nil then
row.ModeText.Text = tbl18.Mode
end
end,
SetActiveAppearance = function(arg2, active)
tbl18.Active = active
fn38(tbl18)
end,
SetEnabled = function(arg2, enabled)
if tbl18.Enabled == enabled then
return
end
tbl18.Enabled = enabled

if enabled and tbl18.Row == nil then
fn39(arg, tbl18)
end

fn37(arg, tbl18, fn36(arg, tbl18))
end,
Destroy = function()
local v118 = table.find(arg._entries, tbl18)

if v118 ~= nil then
table.remove(arg._entries, v118)
end

local row = tbl18.Row

if row ~= nil then
tbl18.Row = nil
row.Outline:Destroy()
end
end,
}
end

index2.Destroy = function(arg)
arg._trove:Destroy()
end

return index2
end

tbl17.ai = function()
local ai = tbl17.cache.ai

if not ai then
ai = { c = fn35() }
tbl17.cache.ai = ai
end

return ai.c
end
end
do -- aj
local function fn35()
tbl17.k()
tbl17.r()
local v115 = tbl17.s()
local v116 = tbl17.x()
local v117 = tbl17.t()
local v118 = tbl17.A()
local v119 = tbl17.w()
local userInputService = v117.UserInputService
local index2 = {}
index2.__index = index2

local function fn36(arg)
local rt = arg.Rt

if rt ~= nil and rt.Instance.Parent ~= nil then
v119.clampGuiToViewport(rt.Instance)
end
end

index2.new = function(arg, arg2, arg3)
local obj = setmetatable({
_trove = arg3:Extend(),
_menu = arg,
_parent = arg2,
_buttonByFlag = {},
_buttonCount = 0,
_isDragMode = false,
}, index2)

local v120 = obj._trove:Extend()

v119.connectCurrentCameraViewport(obj._trove, function(arg4)
v120:Clean()
if arg4 == nil then
return
end

v120:Add(task.defer(function()
for _, v121 in obj._buttonByFlag, nil, nil do
fn36(v121)
end
end))
end)

return obj
end

local function fn37(arg, arg2)
local rt = arg2.Rt
if rt == nil then
return
end
local str7 = "Background"

if arg2.Active then
str7 = "Accent"
end

arg:Tween(rt.Instance, { BackgroundColor3 = v118.get(str7) })
end

local function fn38(arg)
return arg.Visible and arg.Mode ~= "Always"
end

local function fn39(arg, arg2)
local rt = arg.Rt
if rt == nil then
return
end
local backgroundTransparency = v86[186]

if arg.Invisible and not arg2 then
backgroundTransparency = 1
end

rt.Instance.BackgroundTransparency = backgroundTransparency
rt.Label.TextTransparency = backgroundTransparency
rt.Stroke.Transparency = backgroundTransparency
end

local function fn40(arg)
local v120 = v119.currentViewportSize()
local n = math.min(300, math.floor(v120.Y * 0.45))
local v121 = v86[63]
local n33 = math.max(v86[63], math.floor((v120.Y - n - v86[143]) / 44) + v121)
return UDim2.fromOffset(20 + math.floor(arg / n33) * 140, n + arg % n33 * 44)
end

local function fn41(arg, arg2)
local rt = arg2.Rt
if rt ~= nil then
return rt
end
local menu = arg._menu
local v120 = v118.newBatch(arg2.Trove)
local udim2 = fn40(arg2.Slot)
local stateData = menu:GetStateData()

if stateData ~= nil and stateData.MobileButtonPositions ~= nil then
local v121 = stateData.MobileButtonPositions[arg2.Flag]

if v121 ~= nil and #v121 >= 2 then
udim2 = UDim2.fromOffset(v121[1], v121[2])
end
end

local textButton = Instance.new("TextButton")
textButton.Position = udim2
textButton.Size = UDim2.fromOffset(0, v86[143])
textButton.AutomaticSize = Enum.AutomaticSize.X
textButton.BorderSizePixel = 0
textButton.AutoButtonColor = v86[153]
textButton.Text = ""
textButton.Active = true
textButton.Visible = fn38(arg2)
v120:Bind(textButton, "BackgroundColor3", "Background")
textButton.Parent = arg._parent
arg2.Trove:Add(textButton)
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, v86[175])
uiCorner.Parent = textButton
local instance = Instance.new(v86[85])
instance.Thickness = v86[63]
instance.BorderOffset = UDim.new(0, -1)
instance.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
v120:Bind(instance, "Color", "Outline")
instance.Parent = textButton
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingLeft = UDim.new(0, 14)
uiPadding.PaddingRight = UDim.new(0, 14)
uiPadding.Parent = textButton
local instance2 = Instance.new(v86[135])
instance2.BackgroundTransparency = 1
instance2.Size = UDim2.fromOffset(v86[186], 36)
instance2.AutomaticSize = Enum.AutomaticSize.X
instance2.Text = arg2.LabelText
instance2.FontFace = v115.Medium
instance2.TextSize = 14
instance2.BorderSizePixel = 0
v120:Bind(instance2, "TextColor3", "TextColor")
instance2.Parent = textButton
local rt2 = { Instance = textButton, Label = instance2, Stroke = instance }
arg2.Rt = rt2

if arg2.Active then
textButton.BackgroundColor3 = v118.get("Accent")
end

fn39(arg2, arg._isDragMode)
arg2.Trove:Add(task.defer(fn36, arg2))
arg2.Trove:Add(task.defer(fn36, arg2))

v116.connectPress(arg2.Trove, textButton, function()
if arg._isDragMode then
return
end

if arg2.Mode == "Hold" then
arg2.Active = true
fn37(menu, arg2)
arg2.OnActivate(v86[34])
elseif arg2.Mode == "Toggle" or arg2.Mode == "Tap" then
arg2.Active = not arg2.Active
fn37(menu, arg2)
arg2.OnActivate(arg2.Active)
end
end, function()
if arg._isDragMode then
return
end

if arg2.Mode == "Hold" then
arg2.Active = false
fn37(menu, arg2)
arg2.OnActivate(false)
end
end)

return rt2
end

local function fn42(arg, arg2)
local v120 = fn38(arg2)

if v120 and arg2.Rt == nil then
fn41(arg, arg2)
end

local rt = arg2.Rt

if rt ~= nil then
rt.Instance.Visible = v120
end
end

index2.Register = function(arg, arg2, arg3, arg4, arg5)
local v120 = arg._buttonByFlag[arg2]

if v120 ~= nil then
v120.Trove:Destroy()
arg._buttonByFlag[arg2] = nil
end

local tbl18 = {
Flag = arg2,
Slot = arg._buttonCount,
Mode = arg4,
Active = false,
Visible = true,
Invisible = false,
LabelText = arg3,
Trove = arg._trove:Extend(),
OnActivate = arg5,
Rt = nil,
}

arg._buttonByFlag[arg2] = tbl18
arg._buttonCount = arg._buttonCount + 1

tbl18.Trove:Add(task.defer(function()
if arg._buttonByFlag[arg2] == tbl18 then
fn42(arg, tbl18)
end
end))

return {
SetActive = function(arg6, active)
tbl18.Active = active
fn37(arg._menu, tbl18)
end,
SetMode = function(arg6, mode)
tbl18.Mode = mode
fn42(arg, tbl18)
end,
SetLabel = function(arg6, labelText)
tbl18.LabelText = labelText
local rt = tbl18.Rt

if rt ~= nil then
rt.Label.Text = labelText
end
end,
SetVisible = function(arg6, visible)
tbl18.Visible = visible
fn42(arg, tbl18)
end,
SetInvisible = function(arg6, invisible)
tbl18.Invisible = invisible
fn39(tbl18, arg._isDragMode)
end,
Destroy = function()
if arg._buttonByFlag[arg2] == tbl18 then
arg._buttonByFlag[arg2] = nil
end

tbl18.Trove:Destroy()
end,
}
end

index2.EnterDragMode = function(arg, arg2)
arg._isDragMode = v86[34]
local menu = arg._menu
local textButton = Instance.new("TextButton")
textButton.AnchorPoint = Vector2.new(v86[101], 0)
textButton.Position = UDim2.new(0.5, 0, 0, 40)
textButton.Size = UDim2.fromOffset(140, 40)
textButton.BackgroundColor3 = v118.get("Accent")
textButton.BorderSizePixel = 0
textButton.Text = "Done"
textButton.FontFace = v115.Medium
textButton.TextSize = 16
textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
textButton.AutoButtonColor = false
textButton.Parent = arg._parent
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 6)
uiCorner.Parent = textButton
local v120 = arg._trove:Extend()

for _, v121 in arg._buttonByFlag, nil, nil do
fn39(v121, v86[34])
local rt = v121.Rt

if rt ~= nil then
menu:Tween(rt.Stroke, { Thickness = 2 })
end
end

local v121 = nil
local v122 = nil
local position = nil
local position2 = nil

for _, v123 in arg._buttonByFlag, nil, nil do
local rt = v123.Rt

if rt ~= nil then
v120:Connect(rt.Instance.InputBegan, function(arg3)
local userInputType = arg3.UserInputType
if userInputType ~= Enum.UserInputType.Touch and userInputType ~= Enum.UserInputType.MouseButton1 then
return
end
v121 = v123
v122 = arg3
position = arg3.Position
position2 = rt.Instance.Position
end)
end
end

v120:Connect(userInputService.InputChanged, function(arg3)
local v123 = v121
local v124 = position
local v125 = position2
if v123 == nil or v124 == nil or v125 == nil then
return
end
local rt = v123.Rt
if rt == nil then
return
end

if not v119.matchesPointerDrag(arg3, v122, Enum.UserInputType.MouseMovement) then
return
end
local n = arg3.Position - v124
rt.Instance.Position = UDim2.fromOffset(v125.X.Offset + n.X, v125.Y.Offset + n.Y)
v119.clampGuiToViewport(rt.Instance)
end)

v120:Connect(userInputService.InputEnded, function(arg3)
if v121 == nil then
return
end

if not v119.matchesPointerDrag(arg3, v122, Enum.UserInputType.MouseButton1) then
return
end
v121 = nil
v122 = nil
position = nil
position2 = nil
end)

v120:Connect(textButton.Activated, function()
arg:_ExitDragMode()

for _, v123 in arg._buttonByFlag, nil, nil do
fn39(v123, false)
local rt = v123.Rt

if rt ~= nil then
menu:Tween(rt.Stroke, { Thickness = 1 })
end
end

textButton:Destroy()
v120:Destroy()
arg2()
end)
end

index2._ExitDragMode = function(arg)
arg._isDragMode = false
local stateData = arg._menu:GetStateData()
if stateData == nil then
return
end
local mobileButtonPositions = stateData.MobileButtonPositions or {}

for k, v120 in arg._buttonByFlag, nil, nil do
local rt = v120.Rt

if rt ~= nil then
local position = rt.Instance.Position
mobileButtonPositions[k] = { position.X.Offset, position.Y.Offset }
end
end

stateData.MobileButtonPositions = mobileButtonPositions
arg._menu:SaveState()
end

index2.Destroy = function(arg)
arg._trove:Destroy()
end

return index2
end

tbl17.aj = function()
local aj = tbl17.cache.aj

if not aj then
aj = { c = fn35() }
tbl17.cache.aj = aj
end

return aj.c
end
end
do -- ak
local function fn35()
tbl17.g()
tbl17.k()
tbl17.r()
local userInputService = tbl17.t().UserInputService
local index2 = {}
index2.__index = index2

index2.new = function(arg, arg2, arg3)
local obj = setmetatable({
_trove = arg,
_layer = arg2,
_entries = {},
_blocker = nil,
_lastHandledInput = nil,
_onBeforeOpen = nil,
}, index2)

arg:Connect(userInputService.InputBegan, function(arg4, arg5)
local userInputType = arg4.UserInputType
local blocker = obj._blocker
local flag19 = blocker ~= nil and blocker.Parent ~= nil and blocker.Visible == v86[34]
if userInputType ~= Enum.UserInputType.MouseButton1 and userInputType ~= Enum.UserInputType.MouseButton2 and userInputType ~= Enum.UserInputType.Touch then
return
end

if arg5 and not flag19 then
return
end

obj:_HandlePointerInput(arg4, flag19 and not arg5)
end)

arg:Connect(arg3, function(arg4)
if not arg4 then
for _, v115 in obj._entries, nil, nil do
if v115.Open then
v115.Open = v86[153]
v115.Root.Visible = false
end
end

obj:_UpdateBlocker()
end
end)

return obj
end

index2._HandlePointerInput = function(arg, lastHandledInput, arg2)
if arg._lastHandledInput == lastHandledInput then
return
end
arg._lastHandledInput = lastHandledInput

task.defer(function()
if arg._lastHandledInput == lastHandledInput then
arg._lastHandledInput = nil
end
end)

local position = lastHandledInput.Position
local v115, v116 = arg:_FindHit(position, arg2 == v86[34])

if v115 then
if v116 then
arg:Toggle(v115)
return
end
local tbl18 = {}
local v117 = v86[153]

for _, v118 in arg._entries, nil, nil do
if v118 ~= v115 and arg:_IsDescendantOf(v118, v115) then
local v119 = v86[153]

for _, v120 in v118.Triggers, nil, nil do
if arg:_ContainsPoint(v120, position) then
v119 = v86[34]
break
end
end

if v119 then
v117 = v86[34]
elseif v118.Open and v118.CloseOnOutside and not arg:_ContainsPoint(v118.Root, position) then
table.insert(tbl18, v118)
end
end
end

for _, v118 in tbl18, nil, nil do
if v118.Open then
arg:_Apply(v118, false)
end
end

if not v117 then
arg:BringToFront(v115)
end

return
end

arg:CloseAll(nil, v86[153])
end

index2._EnsureBlocker = function(arg)
if arg._blocker ~= nil then
if arg._blocker.Parent ~= nil then
return arg._blocker
end
return nil
end

local textButton = Instance.new("TextButton")
textButton.Name = "\0"
textButton.Active = true
textButton.Visible = v86[153]
textButton.BackgroundTransparency = 1
textButton.Size = UDim2.fromScale(v86[63], 1)
textButton.BorderSizePixel = 0
textButton.ZIndex = v86[186]
textButton.Text = ""
textButton.Parent = arg._layer

arg._trove:Connect(textButton.InputBegan, function(arg2)
local userInputType = arg2.UserInputType
if userInputType ~= Enum.UserInputType.MouseButton1 and userInputType ~= Enum.UserInputType.MouseButton2 and userInputType ~= Enum.UserInputType.Touch then
return
end
arg:_HandlePointerInput(arg2)
end)

arg._blocker = textButton
return textButton
end

index2._UpdateBlocker = function(arg)
local v115 = arg:_EnsureBlocker()
if v115 == nil then
return
end
local visible = false

for _, v116 in arg._entries, nil, nil do
if v116.Open then
visible = true
break
end
end

v115.Visible = visible
end

index2.SetBeforeOpen = function(arg, onBeforeOpen)
arg._onBeforeOpen = onBeforeOpen
end

index2.Register = function(arg, arg2, arg3)
local triggers = arg3 ~= nil and arg3.Triggers or {}
local parentEntry = arg3 ~= nil and arg3.ParentEntry or nil
local onToggle = arg3 ~= nil and arg3.OnToggle or nil
local flag19 = arg3 ~= nil and arg3.Open == true
local flag20 = arg3 == nil or arg3.CloseOnOutside ~= false

if parentEntry == nil then
local parent

if triggers[1] ~= nil then
parent = triggers[1].Parent
else
parent = arg2.Parent
end

while parent ~= nil do
for _, v115 in arg._entries, nil, nil do
if v115.Root == parent then
parentEntry = v115
break
end
end

if parentEntry == nil then
parent = parent.Parent
continue
end
break
end
end

local tbl18 = {
Root = arg2,
Parent = arg2.Parent,
ParentEntry = parentEntry,
Triggers = triggers,
OnToggle = onToggle,
Open = flag19 or arg2.Visible == true,
CloseOnOutside = flag20,
}

table.insert(arg._entries, tbl18)
arg:_UpdateBlocker()
return tbl18
end

index2.Unregister = function(arg, arg2)
local v115 = table.find(arg._entries, arg2)

if v115 ~= nil then
table.remove(arg._entries, v115)
end

arg:_UpdateBlocker()
end

index2._ContainsPoint = function(arg, arg2, arg3)
if arg2.Visible ~= v86[34] then
return v86[153]
end
local absolutePosition = arg2.AbsolutePosition
local absoluteSize = arg2.AbsoluteSize
return arg3.X >= absolutePosition.X and arg3.X <= absolutePosition.X + absoluteSize.X and arg3.Y >= absolutePosition.Y and arg3.Y <= absolutePosition.Y + absoluteSize.Y
end

index2._FindHit = function(arg, arg2, arg3)
for i = #arg._entries, 1, -1 do
local v115 = arg._entries[i]
if v115.Open and arg:_ContainsPoint(v115.Root, arg2) then
return v115, false
end

if v115.Open or arg3 == true then
for _, v116 in v115.Triggers, nil, nil do
if arg:_ContainsPoint(v116, arg2) then
return v115, true
end
end
end
end

return nil, v86[153]
end

index2._Apply = function(arg, arg2, open)
if not open then
for _, v115 in arg._entries, nil, nil do
if v115.ParentEntry == arg2 and v115.Open then
arg:_Apply(v115, false)
end
end
end

if open then
local onBeforeOpen = arg._onBeforeOpen

if onBeforeOpen ~= nil then
onBeforeOpen()
end
end

arg2.Open = open
local onToggle = arg2.OnToggle

if type(onToggle) == "function" then
onToggle(open)
arg:_UpdateBlocker()
return
end

arg2.Root.Visible = open
arg:_UpdateBlocker()
end

index2._IsDescendantOf = function(arg, arg2, arg3)
local parentEntry = arg2.ParentEntry

while parentEntry do
if parentEntry == arg3 then
return true
end
parentEntry = parentEntry.ParentEntry
end

return false
end

index2._IsRelated = function(arg, arg2, arg3)
return arg2 == arg3 or arg:_IsDescendantOf(arg2, arg3) or arg:_IsDescendantOf(arg3, arg2)
end

index2.BringToFront = function(arg, arg2)
local root = arg2.Root
local parent = root.Parent or arg2.Parent
if parent == nil then
return
end

if root.Parent == parent then
local focusedTextBox = userInputService:GetFocusedTextBox()
if focusedTextBox ~= nil and focusedTextBox:IsDescendantOf(root) then
return
end
root.Parent = nil
end

root.Parent = parent
arg2.Parent = parent
end

index2.CloseAll = function(arg, arg2, arg3)
for _, v115 in arg._entries, nil, nil do
if v115.Open and v115 ~= arg2 and (arg2 == nil or not arg:_IsRelated(v115, arg2)) and (arg3 == true or v115.CloseOnOutside) then
arg:_Apply(v115, false)
end
end
end

index2.CloseDescendants = function(arg, arg2)
for _, v115 in arg._entries, nil, nil do
if v115.Open and arg:_IsDescendantOf(v115, arg2) then
arg:_Apply(v115, false)
end
end
end

index2.SetOpen = function(arg, arg2, arg3)
if arg3 then
arg:CloseAll(arg2, v86[34])
arg:BringToFront(arg2)
end

arg:_Apply(arg2, arg3)
end

index2.Toggle = function(arg, arg2)
arg:SetOpen(arg2, not arg2.Open)
end

return index2
end

tbl17.ak = function()
local ak = tbl17.cache.ak

if not ak then
ak = { c = fn35() }
tbl17.cache.ak = ak
end

return ak.c
end
end
do -- al
local function fn35()
tbl17.k()
local v115 = tbl17.F()
tbl17.r()
local v116 = tbl17.s()
local v117 = tbl17.t()
local v118 = tbl17.A()
local v119 = tbl17.w()
local guiService = v117.GuiService
local userInputService = v117.UserInputService
local runService = v117.RunService
local tweenInfo = TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, v86[186], false, 0.4)
local index2 = {}
index2.__index = index2

local function fn36()
return nil
end

local function fn37(arg)
return (arg:lower():gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", v86[51]))
end

local function fn38(arg)
if arg == nil then
return false
end
return arg >= 48 and arg <= 57 or arg >= 97 and arg <= 122
end

local function fn39(arg, arg2)
local pos = arg:find(arg2, v86[63], true)

if pos ~= nil then
if arg == arg2 then
return 0
end
local flag19 = not fn38(arg:byte(pos - 1))
local flag20 = not fn38(arg:byte(pos + #arg2 - 1 + 1))
if flag19 and flag20 then
return 5 + pos
end

if flag19 then
return 20 + pos
end
return 40 + pos
end

local n = #arg2
if n < v86[26] then
return nil
end
local n33 = #arg
local n34 = 1
local n35 = 1
local n36 = 0
local n37 = 0
local n38 = 0

while n34 <= n33 and n35 <= n do
if arg:byte(n34) == arg2:byte(n35) then
if n36 == v86[186] then
n36 = n34
end

if n37 ~= 0 then
n38 += n34 - n37 - 1
end

n35 += v86[63]
n37 = n34
end

n34 += 1
end

if n35 <= n then
return nil
end
return 100 + n36 + n38 * 4 + n33 - n
end

local function fn40(arg)
local tbl18 = {}

for match in arg:gmatch("%S+") do
table.insert(tbl18, match)
end

return tbl18
end

local function fn41(arg, arg2, arg3)
local v120 = fn39(arg.Label, arg2)
if v120 ~= nil then
return v120
end

if #arg3 == v86[63] then
return nil
end
local v121 = v86[186]
local flag19 = false

for _, v122 in arg3, nil, nil do
local v123 = fn39(arg.Label, v122)
local v124 = fn39(arg.Crumb, v122)

if v123 ~= nil and (v124 == nil or v123 <= v124 + 50) then
v121 += v123
flag19 = true
continue
end

if v124 ~= nil then
v121 += v124 + 50
continue
end
return nil
end

if not flag19 then
return nil
end
return 500 + v121
end

local function fn42(arg)
if arg == v86[186] then
return v86[143]
end
local v120 = v86[56]
return arg * 36 + math.max(0, arg - 1) * v120 + 8
end

local function fn43(arg, arg2)
table.insert(arg, { Hit = arg2, Label = arg2.Label:lower(), Crumb = arg2.Crumb:lower(), Score = 0 })
end

local function fn44(arg, parent)
if not parent:IsA("GuiObject") then
return
end
local instance = Instance.new(v86[85])
instance.Color = v118.get("Accent")
instance.Thickness = 2
instance.Transparency = 0
instance.LineJoinMode = Enum.LineJoinMode.Round

if parent.ClassName == "TextButton" then
instance.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
end

instance.Parent = parent
arg:Tween(instance, { Transparency = v86[63] }, tweenInfo)

task.delay(1.6, function()
if instance.Parent ~= nil then
instance:Destroy()
end
end)
end

local function fn45(arg, parent, arg2)
local instance = Instance.new(v86[92])
instance.Visible = false
instance.BackgroundTransparency = 1
instance.Position = UDim2.fromOffset(v86[26], 4)
instance.Size = UDim2.new(1, -8, 0, v86[143])
instance.BorderSizePixel = 0
instance.Text = ""
instance.LayoutOrder = v86[186]
instance.AutoButtonColor = false
arg2:Bind(instance, "BackgroundColor3", v86[178])
instance.Parent = parent
local instance2 = Instance.new(v86[98])
instance2.CornerRadius = UDim.new(0, 4)
instance2.Parent = instance
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingLeft = UDim.new(0, 8)
uiPadding.PaddingRight = UDim.new(v86[186], 8)
uiPadding.Parent = instance
local textLabel = Instance.new("TextLabel")
textLabel.BackgroundTransparency = v86[63]
textLabel.Position = UDim2.fromOffset(v86[186], 3)
textLabel.Size = UDim2.new(1, v86[186], v86[186], 16)
textLabel.TextSize = 13
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.TextTruncate = Enum.TextTruncate.AtEnd
textLabel.FontFace = v116.Medium
arg2:Bind(textLabel, "TextColor3", v86[174])
textLabel.Parent = instance
local textLabel2 = Instance.new("TextLabel")
textLabel2.BackgroundTransparency = 1
textLabel2.Position = UDim2.fromOffset(0, 19)
textLabel2.Size = UDim2.new(v86[63], v86[186], 0, 13)
textLabel2.TextSize = 11
textLabel2.TextXAlignment = Enum.TextXAlignment.Left
textLabel2.TextTruncate = Enum.TextTruncate.AtEnd
textLabel2.FontFace = arg._menu.Fonts.Main
arg2:Bind(textLabel2, "TextColor3", "Unselected")
textLabel2.Parent = instance

arg._trove:Connect(instance.MouseButton1Click, function()
local v120 = arg._scored[instance.LayoutOrder]

if v120 ~= nil then
arg:_NavigateTo(v120.Hit)
end
end)

arg._trove:Connect(instance.MouseEnter, function()
if arg._scored[instance.LayoutOrder] ~= nil then
arg._selectedIndex = instance.LayoutOrder
arg:_RefreshHighlight()
end
end)

return { Button = instance, Title = textLabel, Crumb = textLabel2 }
end

local function fn46(arg)
local ui = arg._ui
if ui == nil then
return
end
local n = #arg._scored
local n33 = 1

if v86[186] < n then
n33 = math.min(math.floor(math.max(0, ui.ResultList.CanvasPosition.Y - v86[26]) / 38) + 1, n)
end

for k, v120 in ui.Rows, nil, nil do
local layoutOrder = n33 + k - 1
local v121 = arg._scored[layoutOrder]

if v121 == nil then
v120.Button.Visible = false
v120.Button.LayoutOrder = v86[186]
v120.Button.BackgroundTransparency = 1
else
local hit = v121.Hit

if v120.Title.Text ~= hit.Label then
v120.Title.Text = hit.Label
end

if v120.Crumb.Text ~= hit.Crumb then
v120.Crumb.Text = hit.Crumb
end

v120.Button.LayoutOrder = layoutOrder
v120.Button.Position = UDim2.fromOffset(4, 4 + (layoutOrder - 1) * v86[107])
v120.Button.BackgroundTransparency = layoutOrder == arg._selectedIndex and 0 or 1
v120.Button.Visible = v86[34]
end
end
end

local function fn47(arg)
local ui = arg._ui
if ui ~= nil then
return ui
end
local menu = arg._menu
local v120 = v118.newBatch(arg._trove)
local instance = Instance.new(v86[128])
instance.Size = UDim2.fromOffset(260, 0)
instance.AutomaticSize = Enum.AutomaticSize.Y
instance.AnchorPoint = Vector2.new(1, 0)
instance.BackgroundColor3 = Color3.fromRGB(v86[108], v86[108], v86[108])
instance.BorderSizePixel = 0
instance.Visible = false
instance.Parent = menu:GetOverlayLayer()
arg._trove:Add(instance)
local uiGradient = Instance.new("UIGradient")
uiGradient.Rotation = 90
v120:BindGradient(uiGradient, { "GradientTop", v86[70] })
uiGradient.Parent = instance
local instance2 = Instance.new(v86[98])
instance2.CornerRadius = UDim.new(0, 8)
instance2.Parent = instance
local uiStroke = Instance.new("UIStroke")
v120:Bind(uiStroke, "Color", "Outline")
uiStroke.Parent = instance
v115.addGlow(v120, instance, { Amount = 4, DampingFactor = 0.6 })
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.fromScale(v86[63], 0)
scrollingFrame.AutomaticSize = Enum.AutomaticSize.None
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = v86[186]
scrollingFrame.Active = v86[34]
scrollingFrame.ScrollBarThickness = 3
scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.None
scrollingFrame.CanvasSize = UDim2.new(0, 0, v86[186], 0)
scrollingFrame.Selectable = v86[153]
v120:Bind(scrollingFrame, "ScrollBarImageColor3", v86[139])
scrollingFrame.Parent = instance
local textLabel = Instance.new("TextLabel")
textLabel.BackgroundTransparency = v86[63]
textLabel.Position = UDim2.fromOffset(4, 4)
textLabel.Size = UDim2.new(1, -8, v86[186], 28)
textLabel.Text = "No matches."
textLabel.TextSize = 12
textLabel.Visible = v86[153]
textLabel.FontFace = menu.Fonts.Main
v120:Bind(textLabel, "TextColor3", v86[96])
textLabel.Parent = scrollingFrame

local v121 = menu:RegisterOverlay(instance, {
CloseOnOutside = true,
OnToggle = function(arg2)
if not arg2 then
arg:Hide()
end
end,
})

local tbl18 = {}

for i = v86[63], v86[54] do
table.insert(tbl18, fn45(arg, scrollingFrame, v120))
end

local ui2 = { Dropdown = instance, ResultList = scrollingFrame, EmptyHint = textLabel, Batch = v120, Rows = tbl18, Entry = v121 }
arg._ui = ui2

arg._trove:Connect(scrollingFrame:GetPropertyChangedSignal("CanvasPosition"), function()
fn46(arg)
end)

return ui2
end

index2.new = function(arg, arg2)
local v120 = arg2:Extend()

local obj = setmetatable({
_trove = v120,
_menu = arg,
_registrations = {},
_index = nil,
_scored = {},
_selectedIndex = 1,
_activeBar = nil,
_visible = false,
_ui = nil,
}, index2)

v120:Connect(userInputService.InputBegan, function(arg3, arg4)
if arg3.UserInputType ~= Enum.UserInputType.Keyboard then
return
end

if arg3.KeyCode == Enum.KeyCode.Escape then
if obj._visible then
obj:Hide()
local activeBar = obj._activeBar

if activeBar ~= nil then
activeBar.Collapse()
end
end

return
end

if arg3.KeyCode == Enum.KeyCode.F then
if (userInputService:IsKeyDown(Enum.KeyCode.LeftControl) or userInputService:IsKeyDown(Enum.KeyCode.RightControl)) and arg.Visible then
local activeBar = obj._activeBar

if activeBar ~= nil then
activeBar.Expand()
end
end

return
end

if not obj._visible then
return
end

if arg3.KeyCode == Enum.KeyCode.Down then
obj:_MoveSelection(v86[63])
elseif arg3.KeyCode == Enum.KeyCode.Up then
obj:_MoveSelection(-1)
elseif arg3.KeyCode == Enum.KeyCode.Return and not arg4 then
local v121 = obj._scored[obj._selectedIndex]

if v121 ~= nil then
obj:_NavigateTo(v121.Hit)
end
end
end)

return obj
end

index2.Register = function(arg, arg2, arg3, arg4)
table.insert(arg._registrations, { Host = arg2, Section = arg3, Collect = arg4 })
arg._index = nil
end

index2.Invalidate = function(arg)
arg._index = nil
end

index2.SetActiveBar = function(arg, activeBar)
arg._activeBar = activeBar
end

local function fn48(arg)
local index3 = arg._index
if index3 ~= nil then
return index3
end
local index4 = {}
local tbl18 = {}
local tbl19 = {}

for _, v120 in arg._registrations, nil, nil do
local host = v120.Host
local tabLabel = host.TabLabel

if not tbl18[tabLabel] then
tbl18[tabLabel] = true

fn43(index4, {
Kind = "navigation",
Label = tabLabel,
Crumb = "Menu",
Open = host.OpenTab,
Reveal = nil,
GetFrame = fn36,
})
end

local pageLabel = host.PageLabel
local str7

if pageLabel == nil then
str7 = tabLabel
else
local str8 = tabLabel .. "\0" .. pageLabel

if not tbl19[str8] then
tbl19[str8] = true

fn43(index4, {
Kind = "navigation",
Label = pageLabel,
Crumb = tabLabel,
Open = host.Open,
Reveal = nil,
GetFrame = fn36,
})
end

str7 = ("%s  ›  %s"):format(tabLabel, pageLabel)
end

local title = v120.Section.Title
local tbl20 = {}
local open = host.Open
v120.Collect(("%s  ›  %s"):format(str7, title), open, tbl20)
local v121 = tbl20[1]
local reveal = nil
local getFrame = fn36

if v121 ~= nil then
reveal = v121.Reveal
getFrame = v121.GetFrame
end

if title ~= "" then
fn43(index4, {
Kind = "navigation",
Label = title,
Crumb = str7,
Open = host.Open,
Reveal = reveal,
GetFrame = getFrame,
})
end

for _, v122 in tbl20, nil, nil do
fn43(index4, v122)
end
end

arg._index = index4
return index4
end

index2.Search = function(arg, arg2)
local scored = arg._scored
table.clear(scored)
arg._selectedIndex = 1
local v120 = fn37(arg2)

if v120 == "" then
local ui = arg._ui

if ui ~= nil then
ui.EmptyHint.Visible = false
ui.ResultList.CanvasPosition = Vector2.zero
ui.ResultList.CanvasSize = UDim2.new(0, 0, 0, 0)
fn46(arg)
end

return 0
end

local v121 = fn40(v120)

for _, v122 in fn48(arg) do
local v123 = fn41(v122, v120, v121)

if v123 ~= nil then
v122.Score = v123
table.insert(scored, v122)
end
end

table.sort(scored, function(arg3, arg4)
if arg3.Score ~= arg4.Score then
return arg3.Score < arg4.Score
end

if arg3.Hit.Kind ~= arg4.Hit.Kind then
return arg3.Hit.Kind == "navigation"
end

if arg3.Label ~= arg4.Label then
return arg3.Label < arg4.Label
end
return arg3.Crumb < arg4.Crumb
end)

local v122 = fn47(arg)
local n = #scored
v122.EmptyHint.Visible = n == 0
local n33 = math.min(math.max(n, 1), 5)
local n34

if n == 0 then
n34 = 36
else
n34 = n33 * 36 + (n33 - 1) * 2 + 8
end

v122.ResultList.Size = UDim2.new(1, 0, 0, n34)
v122.ResultList.CanvasSize = UDim2.fromOffset(v86[186], fn42(n))
v122.ResultList.CanvasPosition = Vector2.zero
arg:_RefreshHighlight()
return n
end

index2.ShowAt = function(arg, arg2)
local v120 = fn47(arg)
local n = arg2.AbsolutePosition + guiService:GetGuiInset()
local absoluteSize = arg2.AbsoluteSize
local n33 = math.floor(absoluteSize.X)
local n34 = math.floor(n.X + absoluteSize.X)
local n35 = math.floor(n.Y + absoluteSize.Y + 4)
local currentCamera = workspace.CurrentCamera
local n36, n37, n38

if currentCamera == nil then
n36 = n34
n37 = n33
n38 = n35
else
local viewportSize = currentCamera.ViewportSize
n37 = math.min(n33, math.floor(viewportSize.X))
n36 = math.clamp(n34, n37, viewportSize.X)
n38 = math.clamp(n35, 0, math.max(0, viewportSize.Y - v120.ResultList.Size.Y.Offset))
end

v120.Dropdown.Size = UDim2.fromOffset(n37, 0)

if not arg._visible then
local n39 = math.max(0, n38 - 8)
v120.Dropdown.Position = UDim2.fromOffset(n36, n39)
v120.Dropdown.Visible = v86[34]
arg._menu:Tween(v120.Dropdown, { Position = UDim2.fromOffset(n36, n38) })
else
v120.Dropdown.Position = UDim2.fromOffset(n36, n38)
end

arg._visible = true
arg._menu:SetOverlayOpen(v120.Entry, v86[34])
end

index2.Hide = function(arg)
local ui = arg._ui
if ui == nil then
return
end
ui.Dropdown.Visible = false
arg._visible = false

if ui.Entry.Open then
arg._menu:SetOverlayOpen(ui.Entry, false)
end
end

index2._RefreshHighlight = function(arg)
local ui = arg._ui
if ui == nil then
return
end
local n = #arg._scored
if n == 0 then
fn46(arg)
return
end
local y = ui.ResultList.AbsoluteWindowSize.Y

if y <= 0 then
y = ui.ResultList.Size.Y.Offset
end

local n33 = 4 + (arg._selectedIndex - v86[63]) * 38
local n34 = n33 + 36
local y2 = ui.ResultList.CanvasPosition.Y

if not (n33 < y2) then
if not (y2 + y < n34) then
n33 = y2
else
n33 = n34 - y
end
end

local n35 = math.max(0, fn42(n) - y)
local n36 = math.clamp(n33, 0, n35)

if n36 ~= ui.ResultList.CanvasPosition.Y then
ui.ResultList.CanvasPosition = Vector2.new(0, n36)
end

fn46(arg)
end

index2._MoveSelection = function(arg, arg2)
local selectedIndex = #arg._scored
if selectedIndex == 0 then
return
end
local n = arg._selectedIndex + arg2

if not (n < 1) then
if not (selectedIndex < n) then
selectedIndex = n
else
selectedIndex = 1
end
end

arg._selectedIndex = selectedIndex
arg:_RefreshHighlight()
end

index2._NavigateTo = function(arg, arg2)
arg:Hide()
local activeBar = arg._activeBar

if activeBar ~= nil then
activeBar.Collapse()
end

arg2.Open()
local reveal = arg2.Reveal

if reveal ~= nil then
reveal()
end

task.spawn(function()
runService.Heartbeat:Wait()
local v120 = arg2.GetFrame()
if v120 == nil or v120.Parent == nil then
return
end
local v121 = v119.findScrollingAncestor(v120)

if v121 ~= nil then
local n = math.max(0, v120.AbsolutePosition.Y - v121.AbsolutePosition.Y + v121.CanvasPosition.Y - 80)
arg._menu:Tween(v121, { CanvasPosition = Vector2.new(0, n) })
end

fn44(arg._menu, v120)
end)
end

index2.Destroy = function(arg)
arg._trove:Destroy()
end

return index2
end

tbl17.al = function()
local al = tbl17.cache.al

if not al then
al = { c = fn35() }
tbl17.cache.al = al
end

return al.c
end
end
do -- am
local function fn35()
tbl17.k()
local v115 = tbl17.v()
tbl17.A()
local tbl18 = {}
local tbl19 = {}
setmetatable(tbl19, { __mode = "k" })

local function fn36(arg, arg2)
if arg2 == "X" then
return arg.AbsoluteCanvasSize.X, arg.AbsoluteWindowSize.X, arg.CanvasPosition.X
end
return arg.AbsoluteCanvasSize.Y, arg.AbsoluteWindowSize.Y, arg.CanvasPosition.Y
end

local function fn37(arg, parent, arg2, arg3, arg4, arg5)
local instance = Instance.new(v86[128])
instance.BackgroundTransparency = 0
instance.BorderSizePixel = v86[186]
instance.ZIndex = arg2.ZIndex + v86[63]
instance.Active = false
instance.Visible = false
arg:Bind(instance, "BackgroundColor3", "GradientDark")
local rotation

if arg3 == "X" then
local n

if arg4 then
instance.Position = arg2.Position
n = 0
else
instance.Position = UDim2.new(arg2.Position.X.Scale + arg2.Size.X.Scale, arg2.Position.X.Offset + arg2.Size.X.Offset, arg2.Position.Y.Scale, arg2.Position.Y.Offset)
n = 1
end

instance.AnchorPoint = Vector2.new(n, v86[186])
instance.Size = UDim2.new(0, arg5, arg2.Size.Y.Scale, arg2.Size.Y.Offset)
rotation = 0
else
local v116 = v86[63]

if arg4 then
v116 = v86[186]
instance.Position = arg2.Position
else
instance.Position = UDim2.new(arg2.Position.X.Scale, arg2.Position.X.Offset, arg2.Position.Y.Scale + arg2.Size.Y.Scale, arg2.Position.Y.Offset + arg2.Size.Y.Offset)
end

instance.AnchorPoint = Vector2.new(v86[186], v116)
instance.Size = UDim2.new(arg2.Size.X.Scale, arg2.Size.X.Offset, v86[186], arg5)
rotation = 90
end

instance.Parent = parent
local uiGradient = Instance.new("UIGradient")
uiGradient.Rotation = rotation

if arg4 then
local new = NumberSequenceKeypoint.new
local v116 = v86[63]
uiGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.25), new(1, v116) })
else
local new = NumberSequenceKeypoint.new
uiGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, v86[63]), new(1, 0.25) })
end

uiGradient.Parent = instance
return instance
end

tbl18.attachOverflowCues = function(arg, arg2, arg3, arg4, arg5)
local navigation = v115.get().Navigation
local v116 = fn37(arg2, arg4, arg3, arg5, true, navigation.CueDepth)
local v117 = fn37(arg2, arg4, arg3, arg5, false, navigation.CueDepth)

local function fn38()
local v118, v119, v120 = fn36(arg3, arg5)
local n = math.max(0, v118 - v119)
local visibilityEpsilon = navigation.VisibilityEpsilon
local flag19 = n > visibilityEpsilon
v116.Visible = flag19 and v120 > visibilityEpsilon
v117.Visible = flag19 and v120 < n - visibilityEpsilon
end

arg:Connect(arg3:GetPropertyChangedSignal("AbsoluteCanvasSize"), fn38)
arg:Connect(arg3:GetPropertyChangedSignal("AbsoluteWindowSize"), fn38)
arg:Connect(arg3:GetPropertyChangedSignal("CanvasPosition"), fn38)

task.defer(function()
if arg3.Parent ~= nil then
fn38()
end
end)
end

local function fn38(arg, arg2, arg3)
if arg.Parent == nil or arg2.Parent == nil then
return
end
local v116, v117, n = fn36(arg, arg3)
if v117 <= 0 then
return
end
local x, x2, x3

if arg3 == "X" then
x = arg2.AbsolutePosition.X
x2 = arg2.AbsoluteSize.X
x3 = arg.AbsolutePosition.X
else
x = arg2.AbsolutePosition.Y
x2 = arg2.AbsoluteSize.Y
x3 = arg.AbsolutePosition.Y
end

local revealPadding = v115.get().Navigation.RevealPadding
local n33 = x - x3 + n - revealPadding
local n34 = n33 + x2 + revealPadding * 2

if n33 < n then
n = n33
elseif n34 > n + v117 then
n = n34 - v117
end

local n35 = math.clamp(n, v86[186], math.max(0, v116 - v117))

if arg3 == "X" then
arg.CanvasPosition = Vector2.new(n35, arg.CanvasPosition.Y)
else
arg.CanvasPosition = Vector2.new(arg.CanvasPosition.X, n35)
end
end

tbl18.scrollIntoView = function(arg, arg2, arg3)
local n = (tbl19[arg] or 0) + 1
tbl19[arg] = n
fn38(arg, arg2, arg3)

task.defer(function()
if tbl19[arg] == n then
fn38(arg, arg2, arg3)
end
end)
end

return tbl18
end

tbl17.am = function()
local am = tbl17.cache.am

if not am then
local am2 = { c = fn35() }
tbl17.cache.am = am2
am = am2
end

return am.c
end
end
do -- an
local function fn35()
local v115 = tbl17.g()
tbl17.k()
local v116 = tbl17.ab()
tbl17.r()
local v117 = tbl17.af()
local v118 = tbl17.v()
local v119 = tbl17.am()
local v120 = tbl17.A()
local index2 = {}
index2.__index = index2

index2.new = function(arg, arg2, arg3, arg4, arg5)
local v121 = arg4:Extend()
local v122 = v120.newBatch(v121)
local page = v118.get().Page
local subtabs = arg2._subtabs
assert(subtabs ~= nil, "Page.new requires the tab's page header")
local textButton = Instance.new("TextButton")
textButton.BackgroundTransparency = 1
textButton.Size = UDim2.fromOffset(page.TabMinWidth, page.TabHeight)
textButton.BorderSizePixel = 0
textButton.AutomaticSize = Enum.AutomaticSize.X
textButton.Text = ""
textButton.AutoButtonColor = false
v122:Bind(textButton, "BackgroundColor3", "TabButtonSelected")
textButton.Parent = subtabs
local instance = Instance.new(v86[98])
instance.CornerRadius = UDim.new(v86[186], 6)
instance.Parent = textButton
local flag19 = arg5.Icon ~= nil and arg5.Icon ~= ""
local imageLabel = nil

if flag19 then
imageLabel = Instance.new("ImageLabel")
imageLabel.ImageColor3 = v120.get(v86[96])
imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
imageLabel.Image = arg5.Icon
imageLabel.BackgroundTransparency = 1
imageLabel.Position = UDim2.fromScale(0.5, 0.5)
imageLabel.Size = UDim2.fromOffset(page.TabIconSize, page.TabIconSize)
imageLabel.BorderSizePixel = 0
imageLabel.Parent = textButton
end

local frame = Instance.new("Frame")
frame.BackgroundTransparency = v86[63]
frame.Size = UDim2.new(0, 0, 0, 0)
frame.BorderSizePixel = 0
frame.AutomaticSize = Enum.AutomaticSize.XY
frame.Parent = textButton
local instance2 = Instance.new(v86[135])
instance2.TextTransparency = 0
instance2.Text = arg5.Label
instance2.AnchorPoint = Vector2.new(0, 0.5)
instance2.BorderSizePixel = 0
instance2.BackgroundTransparency = 1
instance2.Position = UDim2.fromScale(0, 0.5)
instance2.AutomaticSize = Enum.AutomaticSize.XY
instance2.TextSize = page.TabTextSize
instance2.FontFace = arg.Fonts.Main
v122:Bind(instance2, "TextColor3", v86[174])
instance2.Parent = frame
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingBottom = UDim.new(v86[186], 4)
uiPadding.PaddingTop = UDim.new(0, 4)
uiPadding.Parent = instance2
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
uiListLayout.Padding = UDim.new(0, v86[26])
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = frame
local instance3 = Instance.new(v86[4])
instance3.VerticalAlignment = Enum.VerticalAlignment.Center

if imageLabel == nil then
instance3.HorizontalAlignment = Enum.HorizontalAlignment.Center
end

instance3.FillDirection = Enum.FillDirection.Horizontal
instance3.Padding = UDim.new(0, page.TabGap)
instance3.SortOrder = Enum.SortOrder.LayoutOrder
instance3.Parent = textButton
local tabPaddingLeft = page.TabPaddingLeft
local tabPaddingRight = page.TabPaddingRight

if imageLabel == nil then
local n = (page.TabIconSize + page.TabGap) / 2
tabPaddingLeft = math.round(tabPaddingLeft + n)
tabPaddingRight = math.round(tabPaddingRight + n)
end

local instance4 = Instance.new(v86[113])
instance4.PaddingRight = UDim.new(0, tabPaddingRight)
instance4.PaddingLeft = UDim.new(0, tabPaddingLeft)
instance4.Parent = textButton
local instance5 = Instance.new(v86[47])
instance5.Visible = false
instance5.BackgroundTransparency = 1
instance5.GroupTransparency = 0
local n = page.HeaderHeight + page.TabsHeight
instance5.Position = UDim2.fromOffset(page.HorizontalInset, n)
instance5.Size = UDim2.new(1, -page.HorizontalInset * 2, v86[63], -n - page.BottomInset)
instance5.BorderSizePixel = v86[186]
instance5.Parent = arg2._page
local instance6 = Instance.new(v86[4])
instance6.SortOrder = Enum.SortOrder.LayoutOrder
instance6.HorizontalFlex = Enum.UIFlexAlignment.Fill
instance6.Padding = UDim.new(v86[186], v118.get().Section.Gap)
instance6.Parent = instance5
local frame2 = Instance.new("Frame")
frame2.BackgroundTransparency = 1
frame2.BorderSizePixel = 0
frame2.LayoutOrder = 1
frame2.Size = UDim2.fromScale(1, 1)
frame2.Parent = instance5
local uiFlexItem = Instance.new("UIFlexItem")
uiFlexItem.FlexMode = Enum.UIFlexMode.Fill
uiFlexItem.Parent = frame2

local obj = setmetatable({
_trove = v121,
_menu = arg,
_tab = arg2,
_openTab = arg3,
_batch = v122,
Label = arg5.Label,
_button = textButton,
_icon = imageLabel,
_page = instance5,
_body = frame2,
_header = nil,
_fadeState = { Tweening = v86[153] },
_grid = nil,
Opened = v121:Add(v115.new()),
_openedOnce = false,
_pendingOpen = v86[153],
_selected = false,
}, index2)

v121:Connect(textButton.MouseButton1Click, function()
obj:Open()
end)

v122:BindStateful("Accent", function(imageColor3)
local icon = obj._icon

if icon ~= nil and obj._selected then
icon.ImageColor3 = imageColor3
end
end)

v122:BindStateful("Unselected", function(imageColor3)
local icon = obj._icon

if icon ~= nil and not obj._selected then
icon.ImageColor3 = imageColor3
end
end)

if arg2.ActivePage == nil then
obj:Open()
end

return obj
end

index2._SetSelected = function(arg, selected)
arg._selected = selected
local str7 = "Unselected"
local n = 1

if selected then
str7 = "Accent"
n = 0
end

arg._menu:Tween(arg._button, { BackgroundTransparency = n })
local icon = arg._icon

if icon ~= nil then
arg._menu:Tween(icon, { ImageColor3 = v120.get(str7) })
end
end

index2.Open = function(activePage)
local activePage2 = activePage._tab.ActivePage
if activePage2 == activePage then
return
end
activePage._menu:CloseOverlays(nil, v86[34])

if activePage2 ~= nil then
activePage2:_SetSelected(false)
activePage._menu:FadeCanvasGroup(activePage2._page, false, activePage2._fadeState)

if activePage2._pendingOpen then
activePage2._pendingOpen = v86[153]
else
activePage2.Opened:Fire(false)
end
end

activePage:_SetSelected(true)
activePage._menu:FadeCanvasGroup(activePage._page, true, activePage._fadeState)
local subtabs = activePage._tab._subtabs

if subtabs ~= nil then
v119.scrollIntoView(subtabs, activePage._button, v86[124])
end

activePage._tab.ActivePage = activePage

if activePage._tab._openedOnce then
activePage._openedOnce = true
activePage:_MaybeRealize()
activePage.Opened:Fire(true)
else
activePage._pendingOpen = v86[34]
end
end

index2._FlushPendingOpen = function(arg)
if not arg._pendingOpen then
return
end
arg._pendingOpen = false
arg._openedOnce = v86[34]
arg:_MaybeRealize()
arg.Opened:Fire(true)
end

index2._MaybeRealize = function(arg)
if arg._tab.ActivePage ~= arg then
return
end

if not arg._tab._openedOnce then
return
end
local header = arg._header

if header ~= nil then
header:Realize()
end

local grid = arg._grid

if grid ~= nil then
grid:Realize()
end
end

index2.Grid = function(arg, arg2)
local grid = arg._grid
if grid ~= nil then
return grid
end
local openTab = arg._openTab

local v121 = v117.new(arg._menu, arg._body, arg._trove, arg._batch, arg2, {
TabLabel = arg._tab.Label,
PageLabel = arg.Label,
OpenTab = openTab,
Open = function()
openTab()
arg:Open()
end,
})

arg._grid = v121
arg:_MaybeRealize()
return v121
end

index2.Header = function(arg, arg2)
local header = arg._header
if header ~= nil then
return header
end
local frame = Instance.new("Frame")
frame.AutomaticSize = Enum.AutomaticSize.Y
frame.BackgroundTransparency = 1
frame.BorderSizePixel = 0
frame.LayoutOrder = v86[186]
frame.Size = UDim2.fromScale(v86[63], 0)
frame.Parent = arg._page
local instance = Instance.new(v86[113])
instance.PaddingTop = UDim.new(0, 1)
instance.PaddingBottom = UDim.new(0, 1)
instance.PaddingLeft = UDim.new(0, 1)
instance.PaddingRight = UDim.new(v86[186], 1)
instance.Parent = frame
local openTab = arg._openTab

local v121 = v116.BuildSection(arg._menu, arg._trove, arg2 or {}, function()
return frame
end)

arg._header = v121

arg._menu:RegisterSearchSection({
TabLabel = arg._tab.Label,
PageLabel = arg.Label,
OpenTab = openTab,
Open = function()
openTab()
arg:Open()
end,
}, v121, function(arg3, arg4, arg5)
v121:CollectSearchHits(arg3, arg4, arg5)
end)

arg:_MaybeRealize()
return v121
end

index2.OnFirstOpen = function(arg, arg2)
local function fn36()
local thread = coroutine.create(arg2)
arg._trove:Add(thread)
task.spawn(thread)
end

if arg._openedOnce then
fn36()
return
end
local connection = nil

connection = arg._trove:Connect(arg.Opened, function(arg3)
if arg3 ~= v86[34] then
return
end
connection:Disconnect()
fn36()
end)
end

index2.Destroy = function(arg)
arg._button:Destroy()
arg._page:Destroy()
arg._trove:Destroy()
end

return index2
end

tbl17.an = function()
local an = tbl17.cache.an

if not an then
local an2 = { c = fn35() }
tbl17.cache.an = an2
an = an2
end

return an.c
end
end
do -- ao
local function fn35()
tbl17.k()
local v115 = tbl17.F()
tbl17.r()
local v116 = tbl17.s()
local v117 = tbl17.v()
local v118 = tbl17.am()
local v119 = tbl17.A()
local tbl18 = {}
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function fn36(arg, arg2, parent, arg3)
local v120 = v117.get()
local page = v120.Page
local n = 10

if v120.IsCompact then
n = 6
end

local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(1, v86[101])
frame.Position = UDim2.new(1, -page.SearchRightInset, 0.5, 0)
frame.Size = UDim2.fromOffset(page.SearchCollapsedWidth, page.SearchHeight)
frame.BackgroundColor3 = Color3.fromRGB(v86[108], v86[108], 255)
frame.BorderSizePixel = v86[186]
frame.ClipsDescendants = true
frame.Parent = parent
local instance = Instance.new(v86[46])
instance.Rotation = 90
arg2:BindGradient(instance, { "GradientTop", "GradientMid" })
instance.Parent = frame
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(v86[186], 8)
uiCorner.Parent = frame
local uiStroke = Instance.new("UIStroke")
uiStroke.Color = v119.get("TabHighlight")
uiStroke.Transparency = v86[186]
uiStroke.Parent = frame
local imageLabel = Instance.new("ImageLabel")
imageLabel.AnchorPoint = Vector2.new(0, 0.5)
imageLabel.Position = UDim2.new(0, n, 0.5, 0)
imageLabel.Size = UDim2.fromOffset(16, v86[13])
imageLabel.BackgroundTransparency = 1
imageLabel.BorderSizePixel = 0
imageLabel.Image = "rbxassetid://72296609649861"
imageLabel.ImageColor3 = v119.get("Unselected")
imageLabel.Parent = frame
local textLabel = Instance.new("TextLabel")
textLabel.AnchorPoint = Vector2.new(0, 0.5)
textLabel.Position = UDim2.new(v86[186], 30, 0.5, 0)
textLabel.Size = UDim2.new(v86[63], -40, 1, 0)
textLabel.BackgroundTransparency = v86[63]
textLabel.Text = "Ctrl+F"
textLabel.TextSize = 12
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.FontFace = v116.SemiBold
arg2:Bind(textLabel, "TextColor3", "Unselected")
textLabel.Visible = not v120.IsCompact
textLabel.Parent = frame
local textBox = Instance.new("TextBox")
textBox.AnchorPoint = Vector2.new(0, v86[101])
textBox.Position = UDim2.new(0, 32, 0.5, 0)
textBox.Size = UDim2.new(1, -72, 1, -v86[162])
textBox.BackgroundTransparency = 1
textBox.BorderSizePixel = v86[186]
textBox.Text = ""
textBox.PlaceholderText = "Search..."
textBox.PlaceholderColor3 = v119.get("Unselected")
textBox.TextSize = v86[72]
textBox.TextXAlignment = Enum.TextXAlignment.Left
textBox.ClearTextOnFocus = v86[153]
textBox.FontFace = v116.SemiBold
textBox.Visible = false
arg2:Bind(textBox, "TextColor3", "TextColor")
textBox.Parent = frame
local textLabel2 = Instance.new("TextLabel")
textLabel2.AnchorPoint = Vector2.new(v86[63], v86[101])
textLabel2.Position = UDim2.new(1, -v86[143], 0.5, v86[186])
textLabel2.Size = UDim2.fromOffset(24, v86[32])
textLabel2.BackgroundTransparency = v86[105]
textLabel2.BorderSizePixel = 0
textLabel2.Text = v86[18]
textLabel2.TextSize = v86[181]
textLabel2.FontFace = v116.Bold
textLabel2.Visible = v86[153]
arg2:Bind(textLabel2, "BackgroundColor3", "Accent")
arg2:Bind(textLabel2, v86[167], "Accent")
textLabel2.Parent = frame
local instance2 = Instance.new(v86[98])
instance2.CornerRadius = UDim.new(0, 4)
instance2.Parent = textLabel2
local imageButton = Instance.new("ImageButton")
imageButton.AnchorPoint = Vector2.new(1, 0.5)
imageButton.Position = UDim2.new(1, -v86[162], 0.5, 0)
imageButton.Size = UDim2.fromOffset(16, 16)
imageButton.BackgroundTransparency = 1
imageButton.BorderSizePixel = 0
imageButton.Image = "rbxassetid://116396312853810"
imageButton.ImageColor3 = v119.get("Unselected")
imageButton.Visible = false
imageButton.AutoButtonColor = false
imageButton.Parent = frame
local flag19 = false

local function fn37()
if flag19 then
return
end
flag19 = v86[34]
textLabel.Visible = false
textBox.Visible = true
textBox:CaptureFocus()
arg:Tween(frame, { Size = UDim2.fromOffset(page.SearchExpandedWidth, page.SearchHeight) }, tweenInfo)
arg:Tween(uiStroke, { Color = v119.get(v86[139]), Transparency = v86[186] }, tweenInfo)
arg:Tween(imageLabel, { ImageColor3 = v119.get(v86[139]) }, tweenInfo)
end

local function fn38()
if not flag19 then
return
end
flag19 = false
textBox:ReleaseFocus()
textBox.Text = ""
textBox.Visible = false
textLabel.Visible = not v120.IsCompact
imageButton.Visible = false
textLabel2.Visible = false
arg:Tween(frame, { Size = UDim2.fromOffset(page.SearchCollapsedWidth, page.SearchHeight) }, tweenInfo)
arg:Tween(uiStroke, { Color = v119.get("TabHighlight"), Transparency = v86[186] }, tweenInfo)
arg:Tween(imageLabel, { ImageColor3 = v119.get(v86[96]) }, tweenInfo)
arg:HideSearchResults()
end

local instance3 = Instance.new(v86[92])
instance3.Size = UDim2.fromScale(1, v86[63])
instance3.BackgroundTransparency = 1
instance3.Text = ""
instance3.ZIndex = v86[186]
instance3.AutoButtonColor = v86[153]
instance3.Parent = frame
arg3:Connect(instance3.MouseButton1Click, fn37)

arg3:Connect(textBox:GetPropertyChangedSignal("Text"), function()
local text = textBox.Text
local visible = text ~= ""
imageButton.Visible = visible
local v121 = arg:SearchQuery(text)
textLabel2.Text = tostring(v121)
textLabel2.Visible = visible and v121 > v86[186]

if visible then
arg:ShowSearchResults(frame)
else
arg:HideSearchResults()
end
end)

arg3:Connect(textBox.FocusLost, function()
if textBox.Text == "" then
fn38()
end
end)

arg3:Connect(imageButton.MouseButton1Click, function()
textBox.Text = ""
textBox:CaptureFocus()
end)

return { Expand = fn37, Collapse = fn38 }
end

tbl18.create = function(arg, arg2, parent, arg3, text, text2)
local page = v117.get().Page
local horizontalInset = page.HorizontalInset
local headerHeight = page.HeaderHeight
local frame = Instance.new("Frame")
frame.BackgroundTransparency = 1
frame.Size = UDim2.fromScale(1, 1)
frame.BorderSizePixel = 0
frame.Parent = parent
local textLabel = nil
local frame2 = nil
local textLabel2 = nil
local v120 = nil

if page.HasTitleBlock then
frame2 = Instance.new("Frame")
frame2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
frame2.Size = UDim2.new(1, 0, v86[186], headerHeight)
frame2.BorderSizePixel = 0
frame2.Parent = frame
local uiGradient = Instance.new("UIGradient")
uiGradient.Rotation = v86[45]
v115.bindSurfaceGradient(arg2, uiGradient, { v86[134], "GradientMid", "GradientDark" })
uiGradient.Parent = frame2
local frame3 = Instance.new("Frame")
frame3.Position = UDim2.new(0, 1, 1, -1)
frame3.Size = UDim2.new(1, -1, 0, 1)
frame3.BorderSizePixel = 0
arg2:Bind(frame3, "BackgroundColor3", "Outline")
frame3.Parent = frame2
local frame4 = Instance.new("Frame")
frame4.BackgroundTransparency = v86[63]
frame4.Position = UDim2.fromOffset(horizontalInset, v86[186])
frame4.Size = UDim2.new(v86[63], -horizontalInset, 0, headerHeight)
frame4.BorderSizePixel = 0
frame4.Parent = frame2
local instance = Instance.new(v86[128])
instance.BackgroundTransparency = 1
instance.AnchorPoint = Vector2.new(0, 0.5)
instance.Position = UDim2.fromScale(v86[186], 0.5)
instance.BorderSizePixel = 0
instance.AutomaticSize = Enum.AutomaticSize.XY
instance.Parent = frame4
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
uiListLayout.Padding = UDim.new(0, 2)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = instance
textLabel = Instance.new("TextLabel")
textLabel.TextSize = page.TitleTextSize
textLabel.FontFace = v116.Bold
textLabel.Text = text
textLabel.BackgroundTransparency = 1
textLabel.BorderSizePixel = 0
textLabel.AutomaticSize = Enum.AutomaticSize.XY
arg2:Bind(textLabel, v86[167], "TextColor")
textLabel.Parent = instance
textLabel2 = Instance.new("TextLabel")
textLabel2.TextSize = page.DescriptionTextSize
textLabel2.FontFace = v116.SemiBold
textLabel2.Text = text2
textLabel2.BackgroundTransparency = 1
textLabel2.BorderSizePixel = 0
textLabel2.AutomaticSize = Enum.AutomaticSize.XY
arg2:Bind(textLabel2, "TextColor3", "Unselected")
textLabel2.Parent = instance
v120 = fn36(arg, arg2, frame4, arg3)
end

local instance = Instance.new(v86[128])
instance.Position = UDim2.fromOffset(0, headerHeight)
instance.Size = UDim2.new(v86[63], v86[186], 1, -headerHeight)
instance.BorderSizePixel = 0
instance.ZIndex = 0
arg2:Bind(instance, "BackgroundColor3", "GradientDark")
instance.Parent = frame
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.Position = UDim2.fromOffset(horizontalInset, headerHeight)
scrollingFrame.Size = UDim2.new(1, -horizontalInset * 2, 0, page.TabsHeight)
scrollingFrame.BorderSizePixel = v86[186]
scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.X
scrollingFrame.CanvasSize = UDim2.new(v86[186], 0, v86[186], v86[186])
scrollingFrame.ScrollBarImageTransparency = 1
scrollingFrame.ScrollBarThickness = 0
scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.X
scrollingFrame.ElasticBehavior = Enum.ElasticBehavior.Never
arg2:Bind(scrollingFrame, "ScrollBarImageColor3", "Accent")
scrollingFrame.Parent = frame

if not page.HasTitleBlock then
scrollingFrame.Size = UDim2.new(v86[63], -horizontalInset - page.SearchCollapsedWidth + page.SearchRightInset + page.TabGap, v86[186], page.TabsHeight)
local instance2 = Instance.new(v86[128])
instance2.BackgroundTransparency = 1
instance2.Size = UDim2.new(1, 0, 0, page.TabsHeight)
instance2.BorderSizePixel = 0
instance2.ZIndex = scrollingFrame.ZIndex + 2
instance2.Parent = frame
v120 = fn36(arg, arg2, instance2, arg3)
end

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
uiListLayout.FillDirection = Enum.FillDirection.Horizontal
uiListLayout.Padding = UDim.new(0, 4)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = scrollingFrame
v118.attachOverflowCues(arg3, arg2, scrollingFrame, frame, "X")

return {
Holder = frame,
Top = frame2,
Subtabs = scrollingFrame,
TitleLabel = textLabel,
DescriptionLabel = textLabel2,
SearchBar = assert(v120),
}
end

return tbl18
end

tbl17.ao = function()
local ao = tbl17.cache.ao

if not ao then
ao = { c = fn35() }
tbl17.cache.ao = ao
end

return ao.c
end
end
do -- ap
local function fn35()
local v115 = tbl17.g()
tbl17.k()
tbl17.r()
local v116 = tbl17.s()
local v117 = tbl17.v()
local v118 = tbl17.A()
local index2 = {}
index2.__index = index2

index2.new = function(arg, parent, arg2, arg3, arg4)
local rail = v117.get().Rail
local instance = Instance.new(v86[92])
instance.BackgroundTransparency = 1
instance.Size = UDim2.fromOffset(rail.TabSize, rail.TabSize)
instance.BorderSizePixel = 0
instance.Text = ""
instance.TextTransparency = v86[63]

if not rail.ShowLabels then
instance.Text = arg4.Label
end

instance.AutoButtonColor = false
arg3:Bind(instance, v86[5], "TabButtonSelected")
instance.Parent = parent
local imageLabel = Instance.new("ImageLabel")
imageLabel.AnchorPoint = Vector2.new(v86[101], 0.5)
imageLabel.Image = arg4.Icon
imageLabel.BackgroundTransparency = 1
imageLabel.Position = UDim2.fromScale(v86[101], 0.5)
imageLabel.Size = UDim2.fromOffset(rail.TabIconSize, rail.TabIconSize)

if rail.ShowLabels then
imageLabel.AnchorPoint = Vector2.new(0.5, v86[186])
imageLabel.Position = UDim2.new(0.5, 0, 0, 10)
end

imageLabel.BorderSizePixel = 0
imageLabel.ImageColor3 = v118.get("Unselected")
imageLabel.Parent = instance
local textLabel = Instance.new("TextLabel")
textLabel.AnchorPoint = Vector2.new(0.5, 1)
textLabel.Position = UDim2.new(0.5, v86[186], 1, -6)
textLabel.Size = UDim2.new(1, -4, 0, 14)
textLabel.Visible = rail.ShowLabels
textLabel.BackgroundTransparency = 1
textLabel.BorderSizePixel = 0
textLabel.Text = arg4.Label
textLabel.TextColor3 = v118.get("Unselected")
textLabel.TextSize = 10
textLabel.FontFace = v116.Bold
textLabel.TextTruncate = Enum.TextTruncate.AtEnd
textLabel.TextXAlignment = Enum.TextXAlignment.Center
textLabel.Parent = instance

local obj = setmetatable({
_trove = arg2,
_menu = arg,
_selected = false,
Button = instance,
Clicked = arg2:Add(v115.new()),
_icon = imageLabel,
_label = textLabel,
}, index2)

arg2:Connect(instance.MouseButton1Click, function()
obj.Clicked:Fire()
end)

if not rail.ShowLabels then
arg:AttachTooltip(arg2, instance, function()
return arg4.Label
end)
end

arg3:BindStateful("Accent", function(imageColor3)
if obj._selected then
obj._icon.ImageColor3 = imageColor3
obj._label.TextColor3 = imageColor3
end
end)

arg3:BindStateful("Unselected", function(imageColor3)
if not obj._selected then
obj._icon.ImageColor3 = imageColor3
obj._label.TextColor3 = imageColor3
end
end)

return obj
end

index2.SetSelected = function(arg, selected)
if arg._selected == selected then
return
end
arg._selected = selected
local str7 = "Unselected"

if selected then
str7 = "Accent"
end

local v119 = v118.get(str7)
arg._menu:Tween(arg._icon, { ImageColor3 = v119 })
arg._menu:Tween(arg._label, { TextColor3 = v119 })
end

return index2
end

tbl17.ap = function()
local ap = tbl17.cache.ap

if not ap then
ap = { c = fn35() }
tbl17.cache.ap = ap
end

return ap.c
end
end
do -- aq
local function fn35()
tbl17.k()
local v115 = tbl17.F()
tbl17.r()
local v116 = tbl17.v()
local v117 = tbl17.am()
local v118 = tbl17.ap()
tbl17.A()
local index2 = {}
index2.__index = index2

index2.new = function(arg, parent, arg2, arg3, image)
local rail = v116.get().Rail
local frame = Instance.new("Frame")
frame.BackgroundTransparency = v86[63]
frame.Size = UDim2.new(0, rail.Width, 1, 0)
frame.BorderSizePixel = 0
arg3:Bind(frame, "BackgroundColor3", v86[168])
frame.Parent = parent
local instance = Instance.new(v86[128])
instance.BackgroundTransparency = 0
instance.ZIndex = -1
instance.Size = UDim2.fromScale(1, v86[63])
instance.BorderSizePixel = v86[186]
instance.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
instance.Parent = frame
local uiGradient = Instance.new("UIGradient")
uiGradient.Rotation = 90
v115.bindSurfaceGradient(arg3, uiGradient, { v86[134], "GradientMid", "GradientDark" })
uiGradient.Parent = instance
local frame2 = Instance.new("Frame")
frame2.BackgroundColor3 = Color3.fromRGB(255, 255, v86[108])
frame2.Size = UDim2.new(1, v86[186], 0, rail.HeaderHeight)
frame2.BorderSizePixel = 0
frame2.Parent = frame
local instance2 = Instance.new(v86[46])
instance2.Rotation = 90
v115.bindSurfaceGradient(arg3, instance2, { "GradientTop", v86[187], "GradientDark" })
instance2.Parent = frame2
local imageLabel = Instance.new("ImageLabel")
imageLabel.AnchorPoint = Vector2.new(v86[101], 0.5)
imageLabel.Image = image
imageLabel.BackgroundTransparency = 1
imageLabel.Position = UDim2.fromScale(v86[101], v86[101])
imageLabel.Size = UDim2.fromOffset(rail.LogoSize.X, rail.LogoSize.Y)
imageLabel.BorderSizePixel = v86[186]
if image ~= nil and (image == K.CloudyIcon or image == K.LithiumLogo) then
imageLabel.ScaleType = Enum.ScaleType.Fit
end
arg3:Bind(imageLabel, v86[156], "Accent")
imageLabel.Parent = frame2
local frame3 = Instance.new("Frame")
frame3.Position = UDim2.new(0, 0, v86[63], -v86[63])
frame3.Size = UDim2.new(v86[63], 0, 0, v86[63])
frame3.BorderSizePixel = 0
arg3:Bind(frame3, v86[5], "Accent")
frame3.Parent = frame2
local uiGradient2 = Instance.new("UIGradient")
local numberSequence = NumberSequence.new
local tbl18 = {}
local v119 = NumberSequenceKeypoint.new(0, 1)
local v120 = NumberSequenceKeypoint.new(v86[48], 0)
local v121 = NumberSequenceKeypoint.new(0.7, 0)
local new = NumberSequenceKeypoint.new
tbl18[1] = v119
tbl18[2] = v120
tbl18[3] = v121

do
local values = table.pack(new(1, 1))
table.move(values, 1, values.n, 4, tbl18)
end

uiGradient2.Transparency = numberSequence(tbl18)
uiGradient2.Parent = frame3
v115.addGlow(arg3, frame3, { Amount = 2, DampingFactor = 0.78 })
local instance3 = Instance.new(v86[64])
instance3.BackgroundTransparency = v86[63]
instance3.Position = UDim2.fromOffset(0, rail.TabsTop)
instance3.Size = UDim2.new(v86[63], v86[186], v86[63], -rail.TabsTop)
instance3.BorderSizePixel = 0
instance3.AutomaticCanvasSize = Enum.AutomaticSize.Y
instance3.CanvasSize = UDim2.fromOffset(0, 0)
instance3.ScrollingDirection = Enum.ScrollingDirection.Y
instance3.ScrollBarImageTransparency = 0.25
instance3.ScrollBarThickness = 4
instance3.ScrollingEnabled = true
instance3.Active = true
instance3.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
instance3.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right
instance3.ElasticBehavior = Enum.ElasticBehavior.Never
instance3.ClipsDescendants = true
arg3:Bind(instance3, v86[154], v86[139])
instance3.Parent = frame
local frame4 = Instance.new("Frame")
frame4.BackgroundTransparency = v86[63]
frame4.Size = UDim2.fromScale(1, 0)
frame4.AutomaticSize = Enum.AutomaticSize.Y
frame4.BorderSizePixel = 0
frame4.Parent = instance3
local instance4 = Instance.new(v86[4])
instance4.Padding = UDim.new(0, rail.TabGap)
instance4.HorizontalAlignment = Enum.HorizontalAlignment.Center
instance4.SortOrder = Enum.SortOrder.LayoutOrder
instance4.Parent = frame4
local frame5 = Instance.new("Frame")
frame5.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
frame5.BorderSizePixel = 0
frame5.Size = UDim2.fromOffset(rail.TabSize, rail.TabSize)
frame5.Position = UDim2.fromScale(v86[101], v86[186])
frame5.AnchorPoint = Vector2.new(v86[101], 0)
frame5.Visible = false
frame5.ZIndex = 0
frame5.Parent = instance3
local instance5 = Instance.new(v86[46])
instance5.Rotation = v86[45]
arg3:BindGradient(instance5, { "TabHighlight", "TabButtonSelected", v86[191] }, { 0, 0.5, 1 })
instance5.Parent = frame5
local instance6 = Instance.new(v86[98])
instance6.CornerRadius = UDim.new(0, 6)
instance6.Parent = frame5
v117.attachOverflowCues(arg2, arg3, instance3, frame, v86[197])

return setmetatable({
_trove = arg2,
_menu = arg,
_batch = arg3,
Frame = frame,
_scroll = instance3,
_holder = frame4,
_indicator = frame5,
}, index2)
end

index2.AddButton = function(arg, arg2, arg3)
return v118.new(arg._menu, arg._holder, arg2, arg._batch, arg3)
end

index2.MoveIndicator = function(arg, arg2)
local indicator = arg._indicator

if not (n26 >= 4814) then
local udim2 = UDim2.new(v86[101], 0, 0, arg2.AbsolutePosition.Y - arg._holder.AbsolutePosition.Y)
v117.scrollIntoView(arg._scroll, arg2, "Y")

if not indicator.Visible then
indicator.Position = udim2
indicator.Visible = true
return
end

arg._menu:Tween(indicator, { Position = udim2 })
return
end

-- (anti-tamper freeze trap removed)
end

return index2
end

tbl17.aq = function()
local aq = tbl17.cache.aq

if not aq then
aq = { c = fn35() }
tbl17.cache.aq = aq
end

return aq.c
end
end
do -- ar
local function fn35()
local v115 = tbl17.g()
tbl17.k()
tbl17.r()
local v116 = tbl17.af()
local v117 = tbl17.v()
local v118 = tbl17.an()
local v119 = tbl17.ao()
tbl17.aq()
tbl17.ap()
local v120 = tbl17.A()
local index2 = {}
index2.__index = index2

index2.new = function(arg, arg2, arg3, arg4)
local v121 = arg3:Extend()
local v122 = v120.newBatch(v121)
local v123 = v117.get()
local outerInset = v123.Page.OuterInset
local n = v123.Rail.Width + outerInset
local v124 = arg2.Panel:AddButton(v121, { Label = arg4.Label, Icon = arg4.Icon or "rbxassetid://108815781932261" })
local canvasGroup = Instance.new("CanvasGroup")
canvasGroup.BackgroundTransparency = 1
canvasGroup.GroupTransparency = v86[186]
canvasGroup.Visible = false
canvasGroup.Position = UDim2.fromOffset(n, outerInset)
canvasGroup.Size = UDim2.new(1, -n - outerInset, 1, -outerInset * 2)
canvasGroup.BorderSizePixel = v86[186]
canvasGroup.Parent = arg2.MenuFrame

local obj = setmetatable({
_trove = v121,
_menu = arg,
_window = arg2,
_batch = v122,
Label = arg4.Label,
Description = arg4.Description or "",
_button = v124,
_page = canvasGroup,
_fadeState = { Tweening = false },
_grid = nil,
_pages = false,
_header = nil,
_subtabs = nil,
ActivePage = nil,
Opened = v121:Add(v115.new()),
_openedOnce = false,
_pendingOpen = false,
}, index2)

v121:Connect(v124.Clicked, function()
obj:Open()
end)

if arg2.ActiveTab == nil then
obj:Open()
end

return obj
end

index2.Open = function(activeTab)
local window = activeTab._window
local activeTab2 = window.ActiveTab
if activeTab2 == activeTab then
return
end
activeTab._menu:CloseOverlays(nil, v86[34])

if activeTab2 ~= nil then
activeTab2._button:SetSelected(false)
activeTab._menu:FadeCanvasGroup(activeTab2._page, v86[153], activeTab2._fadeState)

if activeTab2._pendingOpen then
activeTab2._pendingOpen = v86[153]
else
activeTab2.Opened:Fire(false)
end
end

window.Panel:MoveIndicator(activeTab._button.Button)
activeTab._button:SetSelected(true)
activeTab._menu:FadeCanvasGroup(activeTab._page, true, activeTab._fadeState)
window.ActiveTab = activeTab

if activeTab._menu.Visible then
activeTab._openedOnce = v86[34]
activeTab:_RealizeActive()
activeTab.Opened:Fire(true)
else
activeTab._pendingOpen = true
end
end

index2._FlushPendingOpen = function(arg)
if not arg._pendingOpen then
return
end
arg._pendingOpen = v86[153]
arg._openedOnce = true
arg:_RealizeActive()
arg.Opened:Fire(v86[34])
end

index2._RealizeActive = function(arg)
local grid = arg._grid
if grid ~= nil then
grid:Realize()
return
end
local activePage = arg.ActivePage

if activePage ~= nil then
activePage:_FlushPendingOpen()
activePage:_MaybeRealize()
end
end

index2.Grid = function(arg, arg2)
assert(not arg._pages, "Tab:Grid() cannot be used on a tab that has sub-tabs")
local grid = arg._grid
if grid ~= nil then
return grid
end

local function fn36()
arg:Open()
end

local v121 = v116.new(arg._menu, arg._page, arg._trove, arg._batch, arg2, { TabLabel = arg.Label, PageLabel = nil, OpenTab = fn36, Open = fn36 })
arg._grid = v121

if arg._openedOnce then
v121:Realize()
end

return v121
end

index2.AddTab = function(arg, arg2)
local v121 = arg
assert(arg._grid == nil, "Tab:AddTab() cannot be used on a tab that has a Grid")

if not arg._pages then
arg._pages = true
local width = v117.get().Rail.Width
arg._page.Size = UDim2.new(1, -width, v86[63], 0)
arg._page.Position = UDim2.fromOffset(width, 0)
local v122 = v119.create(arg._menu, arg._batch, arg._page, arg._trove, arg.Label, arg.Description)
arg._header = v122
arg._subtabs = v122.Subtabs

arg._trove:Connect(arg.Opened, function(arg3)
if arg3 then
arg._menu:SetActiveSearchBar(v122.SearchBar)
elseif true then
v122.SearchBar.Collapse()
arg._menu:SetActiveSearchBar(nil)
else
-- (anti-tamper freeze trap removed)
end
end)

if arg._window.ActiveTab == arg and arg._openedOnce then
arg._menu:SetActiveSearchBar(v122.SearchBar)
end
end

return v118.new(arg._menu, v121, function()
arg:Open()
end, arg._trove, arg2)
end

index2.OnFirstOpen = function(arg, arg2)
local function fn36()
local thread = coroutine.create(arg2)
arg._trove:Add(thread)
task.spawn(thread)
end

if arg._openedOnce then
fn36()
return
end
local connection = nil

connection = arg._trove:Connect(arg.Opened, function(arg3)
if arg3 ~= v86[34] then
return
end
connection:Disconnect()
fn36()
end)
end

index2.Destroy = function(arg)
arg._page:Destroy()
arg._trove:Destroy()
end

return index2
end

tbl17.ar = function()
local ar = tbl17.cache.ar

if not ar then
ar = { c = fn35() }
tbl17.cache.ar = ar
end

return ar.c
end
end
do -- as
local function fn35()
tbl17.g()
tbl17.k()
local v115 = tbl17.s()
local v116 = tbl17.t()
local v117 = tbl17.A()
local v118 = tbl17.w()
local userInputService = v116.UserInputService
local index2 = {}
index2.__index = index2

index2.new = function(arg, arg2, arg3)
local obj = setmetatable({
_trove = arg,
_layer = arg2,
_positionTrove = arg:Extend(),
_followTrove = arg:Extend(),
_frame = nil,
_label = nil,
_owner = nil,
_followConnection = nil,
}, index2)

arg:Connect(arg3, function(arg4)
if not arg4 then
obj:Hide(nil)
end
end)

arg:Connect(userInputService.InputBegan, function(arg4)
local userInputType = arg4.UserInputType
if userInputType ~= Enum.UserInputType.MouseButton1 and userInputType ~= Enum.UserInputType.MouseButton2 and userInputType ~= Enum.UserInputType.Touch then
return
end
obj:Hide(nil)
end)

return obj
end

local function fn36(arg)
local frame = arg._frame
local label = arg._label
if frame ~= nil and label ~= nil then
return frame, label
end
local v119 = v117.newBatch(arg._trove)
local frame2 = Instance.new("Frame")
frame2.BackgroundTransparency = 0.05
frame2.Size = UDim2.new(0, 0, 0, 0)
frame2.AutomaticSize = Enum.AutomaticSize.XY
frame2.BorderSizePixel = 0
frame2.Visible = false
frame2.ZIndex = 1000
v119:Bind(frame2, "BackgroundColor3", v86[168])
frame2.Parent = arg._layer
arg._trove:Add(frame2)
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(v86[186], 4)
uiCorner.Parent = frame2
local instance = Instance.new(v86[85])
v119:Bind(instance, v86[27], v86[120])
instance.Parent = frame2
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingTop = UDim.new(0, 5)
uiPadding.PaddingBottom = UDim.new(0, 5)
uiPadding.PaddingLeft = UDim.new(v86[186], 8)
uiPadding.PaddingRight = UDim.new(0, 8)
uiPadding.Parent = frame2
local instance2 = Instance.new(v86[135])
instance2.BackgroundTransparency = 1
instance2.AutomaticSize = Enum.AutomaticSize.XY
instance2.Text = ""
instance2.FontFace = v115.Medium
instance2.TextSize = 14
instance2.TextWrapped = v86[153]
v119:Bind(instance2, "TextColor3", v86[174])
instance2.Parent = frame2
arg._frame = frame2
arg._label = instance2
return frame2, instance2
end

local function fn37(arg, arg2, arg3)
local v119 = v118.absoluteToLayerOffset(arg._layer, arg3)
arg2.Position = UDim2.fromOffset(v119.X + 14, v119.Y + v86[72])
v118.clampGuiToViewport(arg2)
end

local function fn38(arg, arg2)
local owner = arg._owner
arg._positionTrove:Clean()

arg._positionTrove:Add(task.defer(function()
if arg._owner == owner and arg2.Parent ~= nil and arg2.Visible then
v118.clampGuiToViewport(arg2)
end
end))
end

index2.Show = function(arg, owner, text)
local v119, v120 = fn36(arg)
arg._owner = owner
v120.Text = text
v119.Visible = true
fn37(arg, v119, v118.getPointerPosition())
fn38(arg, v119)

if arg._followConnection == nil then
local connection = userInputService.InputChanged:Connect(function(input)
if input.UserInputType ~= Enum.UserInputType.MouseMovement then
return
end
fn37(arg, v119, v118.getPointerPosition())
end)

arg._followConnection = connection
arg._followTrove:Add(connection)
end
end

index2.ShowAt = function(arg, owner, text, arg2)
local v119, v120 = fn36(arg)
arg._owner = owner
v120.Text = text
v119.Visible = true
fn37(arg, v119, arg2)
fn38(arg, v119)
end

index2.Hide = function(arg, arg2)
if arg2 ~= nil and arg._owner ~= arg2 then
return
end
arg._owner = nil
arg._positionTrove:Clean()
local frame = arg._frame

if frame ~= nil and frame.Visible then
frame.Visible = false
end

arg._followTrove:Clean()
arg._followConnection = nil
end

index2.Destroy = function(arg)
arg:Hide(nil)
end

return index2
end

tbl17.as = function()
local as = tbl17.cache.as

if not as then
local as2 = { c = fn35() }
tbl17.cache.as = as2
as = as2
end

return as.c
end
end
do -- at
local function fn35()
local tweenService = tbl17.t().TweenService
local index2 = {}
index2.__index = index2

index2.new = function()
return setmetatable({
_live = false,
Speed = v86[48],
DragSpeed = 0.05,
EasingStyle = Enum.EasingStyle.Quint,
EasingDirection = Enum.EasingDirection.Out,
}, index2)
end

index2.SetLive = function(arg, live)
arg._live = live
end

index2.Snap = function(arg, arg2, arg3)
for k, v115 in arg3, nil, nil do
arg2[k] = v115
end
end

index2.Play = function(arg, arg2, arg3, arg4)
if not arg._live then
arg:Snap(arg2, arg3)
return nil
end
local tween = tweenService:Create(arg2, arg4 or TweenInfo.new(arg.Speed, arg.EasingStyle, arg.EasingDirection, 0, false, 0), arg3)
tween:Play()
return tween
end

index2.DragInfo = function(arg)
return TweenInfo.new(arg.DragSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0)
end

return index2
end

tbl17.at = function()
local at = tbl17.cache.at

if not at then
at = { c = fn35() }
tbl17.cache.at = at
end

return at.c
end
end
do -- au
local function fn35()local I,W= tbl17 .t().RunService,{};W.__index=W;W.new=function(l)return setmetatable({_onDisplay=l,_running=false,_frames=0,_smooth=60,_displayed=-1,_connection=nil,_loopToken=0},W);end;local function l(N)local P,a=N._loopToken,os.clock();task.delay(0.5,function()if N._loopToken~=P then return;end;local P=os.clock()-a;if P>0 then local a=N._frames/P;N._smooth=N._smooth+(a-N._smooth)*0.5;end;N._frames=0;P=math.floor(N._smooth+0.5);if P~=N._displayed then N._displayed=P;N._onDisplay(P);end;l(N);end);end;W.SetRunning=function(N,P)if N._running==P then return;end;N._running=P;N._loopToken=N._loopToken+1;if not P then local P_33=N._connection;if P_33~=nil then P_33:Disconnect();N._connection=nil;end;return;end;N._frames=0;N._connection=I.RenderStepped:Connect(function()N._frames=N._frames+1;end);l(N);end;W.Destroy=function(l)l:SetRunning(false);end;return W;end

tbl17.au = function()
local au = tbl17.cache.au

if not au then
local au2 = { c = fn35() }
tbl17.cache.au = au2
au = au2
end

return au.c
end
end
do -- av
local function fn35()
tbl17.k()
tbl17.r()
local v115 = tbl17.au()
local v116 = tbl17.u()
local v117 = tbl17.A()
local index2 = {}
index2.__index = index2

local function fn36(parent, layoutOrder, fontFace, arg)
local textLabel = Instance.new("TextLabel")
textLabel.LayoutOrder = layoutOrder
textLabel.FontFace = fontFace
textLabel.Text = "|"
textLabel.AnchorPoint = Vector2.new(0, 0.5)
textLabel.BackgroundTransparency = 1
textLabel.Position = UDim2.fromScale(0, 0.5)
textLabel.BorderSizePixel = 0
textLabel.AutomaticSize = Enum.AutomaticSize.XY
textLabel.TextSize = 16
arg:Bind(textLabel, v86[167], "Unselected")
textLabel.Parent = parent
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingTop = UDim.new(v86[186], 1)
uiPadding.Parent = textLabel
end

local function createTextLabel(parent, layoutOrder, text, fontFace, arg)
local textLabel = Instance.new("TextLabel")
textLabel.LayoutOrder = layoutOrder
textLabel.FontFace = fontFace
textLabel.Text = text
textLabel.AnchorPoint = Vector2.new(0, v86[101])
textLabel.BackgroundTransparency = 1
textLabel.Position = UDim2.fromScale(0, 0.5)
textLabel.BorderSizePixel = 0
textLabel.AutomaticSize = Enum.AutomaticSize.XY
textLabel.TextSize = 16
arg:Bind(textLabel, "TextColor3", "TextColor")
textLabel.Parent = parent
local instance = Instance.new(v86[113])
instance.PaddingTop = UDim.new(0, 1)
instance.Parent = textLabel
return textLabel
end

local function fn37(parent, layoutOrder, image, arg)
local instance = Instance.new(v86[146])
instance.LayoutOrder = layoutOrder
instance.Image = image
instance.BackgroundTransparency = 1
instance.Size = UDim2.fromOffset(20, 20)
instance.BorderSizePixel = 0
if image ~= nil and (image == K.CloudyIcon or image == K.LithiumLogo) then
instance.ScaleType = Enum.ScaleType.Fit
end
arg:Bind(instance, "ImageColor3", "Accent")
instance.Parent = parent
end

index2.new = function(arg, parent, arg2, arg3)
local v118 = arg2:Extend()
local v119 = v117.newBatch(v118)
local main = arg.Fonts.Main
local frame = Instance.new("Frame")
frame.BackgroundTransparency = 0.04
frame.Position = UDim2.fromOffset(50, 50)
frame.BorderSizePixel = 0
frame.AutomaticSize = Enum.AutomaticSize.XY
v119:Bind(frame, "BackgroundColor3", v86[168])
frame.Parent = parent
v118:Add(frame)
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 6)
uiCorner.Parent = frame
local uiStroke = Instance.new("UIStroke")
uiStroke.Thickness = 1
v119:Bind(uiStroke, "Color", v86[120])
uiStroke.Parent = frame
local instance = Instance.new(v86[113])
instance.PaddingTop = UDim.new(0, v86[122])
instance.PaddingBottom = UDim.new(v86[186], v86[122])
instance.PaddingRight = UDim.new(0, 11)
instance.PaddingLeft = UDim.new(0, 13)
instance.Parent = frame
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(v86[186], 10)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.FillDirection = Enum.FillDirection.Horizontal
uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
uiListLayout.Parent = frame
local scale = v116.Scale

if v116.IsMobile() then
scale = 0.8
end

if scale ~= 1 then
local uiScale = Instance.new("UIScale")
uiScale.Scale = scale
uiScale.Parent = frame
end

fn37(frame, 1, arg3.Icon, v119)
local v120 = createTextLabel(frame, v86[56], arg3.Title, main, v119)
fn36(frame, 3, main, v119)
fn37(frame, 4, "rbxassetid://83187029320661", v119)
local v121 = createTextLabel(frame, 5, arg3.Username, main, v119)
fn36(frame, 6, main, v119)
fn37(frame, 7, "rbxassetid://113103422688495", v119)
local v122 = createTextLabel(frame, 8, "60 FPS", main, v119)
v122.AutomaticSize = Enum.AutomaticSize.Y
v122.Size = UDim2.fromOffset(v86[7], 0)
local stateData = arg:GetStateData()

if stateData ~= nil then
frame.Visible = stateData.ShowWatermark ~= false
end

arg:MakeDraggable(frame, v118, { PersistKey = "WatermarkPosition" })

local v123 = v115.new(function(arg4)
v122.Text = string.format("%s FPS", tostring(arg4))
end)

v118:Add(v123)
v123:SetRunning(frame.Visible)
return setmetatable({ _trove = v118, _menu = arg, _root = frame, _title = v120, _username = v121, _fps = v122, _clock = v123 }, index2)
end

index2.SetEnabled = function(arg, visible)
if arg._root.Visible == visible then
return
end
arg._root.Visible = visible
arg._clock:SetRunning(visible)
local stateData = arg._menu:GetStateData()

if stateData ~= nil then
stateData.ShowWatermark = visible
arg._menu:SaveState()
end
end

index2.IsEnabled = function(arg)
return arg._root.Visible
end

index2.SetTitle = function(arg, text)
arg._title.Text = text
end

index2.SetUsername = function(arg, text)
arg._username.Text = text
end

index2.Destroy = function(arg)
arg._trove:Destroy()
end

return index2
end

tbl17.av = function()
local av = tbl17.cache.av

if not av then
local av2 = { c = fn35() }
tbl17.cache.av = av2
av = av2
end

return av.c
end
end
do -- aw
local function fn35()
local v115 = tbl17.u()
local v116 = tbl17.w()
local tbl18

tbl18 = {
effectiveMinSize = function(arg)
local minSize = v115.MinSize

if v115.IsMobile() then
local min = math.min
local offset = minSize.Y.Offset
local floor2 = math.floor
local n = arg.Y * v86[87]
return math.min(minSize.X.Offset, math.floor(arg.X * 0.65)), min(offset, floor2(n))
end

local min = math.min
local offset = minSize.Y.Offset
local floor2 = math.floor
local n = arg.Y * 0.8
return math.min(minSize.X.Offset, math.floor(arg.X * 0.85)), min(offset, floor2(n))
end,
resolveDefaultSize = function()
local v117 = v116.currentViewportSize()
local designSize = v115.DesignSize
local v118, v119 = tbl18.effectiveMinSize(v117)

if v115.IsMobile() then
local n = math.clamp(v117.X * v86[74], v118, designSize.X.Offset)
local n33 = math.clamp(v117.Y * v86[87], v119, designSize.Y.Offset)
local floor2 = math.floor
return UDim2.fromOffset(math.floor(n), floor2(n33))
end

local n = math.clamp(v117.X * 0.8, v118, designSize.X.Offset)
local n33 = math.clamp(v117.Y * 0.7, v119, designSize.Y.Offset)
local floor2 = math.floor
return UDim2.fromOffset(math.floor(n), floor2(n33))
end,
clampSizeToViewport = function(arg, arg2)
local v117 = v116.currentViewportSize()
local v118, v119 = tbl18.effectiveMinSize(v117)

if not (n25 < 3847) then
local n = 0.98

if v115.IsMobile() then
n = 0.75
end

local n33 = math.floor(v117.X * n)
local n34 = math.floor(v117.Y * n)
return math.clamp(arg, v118, math.max(v118, n33)), math.clamp(arg2, v119, math.max(v119, n34))
end
return nil

-- (anti-tamper freeze trap removed)
end,
menuBounds = function(arg)
local parent = arg.Parent

if parent ~= nil and parent:IsA("GuiBase2d") then
local absoluteSize = parent.AbsoluteSize
if absoluteSize.X > 0 and absoluteSize.Y > 0 then
return absoluteSize
end
end

return v116.currentViewportSize()
end,
clampPositionToParent = function(arg, arg2, arg3, arg4, arg5)
local v117 = tbl18.menuBounds(arg)
local n = math.max(0, math.floor(v117.X - arg4))
local n33 = math.max(0, math.floor(v117.Y - arg5))
return math.round(math.clamp(arg2, 0, n)), math.round(math.clamp(arg3, v86[186], n33))
end,
centeredInParent = function(arg, arg2, arg3)
local v117 = tbl18.menuBounds(arg)
return math.floor((v117.X - arg2) / v86[56]), math.floor((v117.Y - arg3) / 2)
end,
}

return tbl18
end

tbl17.aw = function()
local aw = tbl17.cache.aw

if not aw then
local aw2 = { c = fn35() }
tbl17.cache.aw = aw2
aw = aw2
end

return aw.c
end
end
do -- ax
local function fn35()
tbl17.k()
local v115 = tbl17.F()
tbl17.r()
local v116 = tbl17.v()
local v117 = tbl17.u()
local v118 = tbl17.t()
local v119 = tbl17.aq()
local v120 = tbl17.ar()
local v121 = tbl17.A()
local v122 = tbl17.w()
local v123 = tbl17.aw()
local index2 = {}
index2.__index = index2

local function fn36(arg, arg2)
local stateData = arg:GetStateData()

if stateData ~= nil then
stateData.Position = { arg2.X.Offset, arg2.Y.Offset }
arg:SaveState()
end
end

local function fn37(arg)
local menu = arg._menu
local menuFrame = arg.MenuFrame
local trove = arg._trove
local batch = arg._batch
local textButton = Instance.new("TextButton")
textButton.AnchorPoint = Vector2.new(1, 1)
textButton.Position = UDim2.fromScale(1, 1)
textButton.Size = UDim2.fromOffset(18, 18)
textButton.BackgroundTransparency = v86[63]
textButton.BorderSizePixel = 0
textButton.Text = ""
textButton.AutoButtonColor = false
textButton.ZIndex = menuFrame.ZIndex + v86[54]
textButton.Parent = menuFrame
local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(1, v86[63])
frame.Position = UDim2.new(1, -v86[26], 1, -4)
frame.Size = UDim2.fromOffset(8, 2)
frame.Rotation = -45
frame.BorderSizePixel = 0
frame.ZIndex = textButton.ZIndex
batch:Bind(frame, "BackgroundColor3", "Outline")
frame.Parent = textButton
local instance = Instance.new(v86[128])
instance.AnchorPoint = Vector2.new(1, v86[63])
instance.Position = UDim2.new(1, -2, 1, -7)
instance.Size = UDim2.fromOffset(5, 2)
instance.Rotation = -45
instance.BorderSizePixel = v86[186]
instance.ZIndex = textButton.ZIndex
batch:Bind(instance, "BackgroundColor3", v86[120])
instance.Parent = textButton
local v124 = nil
local flag19 = false
local v125 = trove:Extend()
local vector2 = nil

local function fn38(arg2)
v125:Clean()
vector2 = nil
local v126 = flag19
flag19 = false
v124 = nil

if arg2 and v126 then
local stateData = menu:GetStateData()

if stateData ~= nil then
stateData.Size = { arg.Size.X.Offset, arg.Size.Y.Offset }
menu:SaveState()
end
end
end

local function fn39(arg2)
if arg2.UserInputType ~= Enum.UserInputType.MouseButton1 and arg2.UserInputType ~= Enum.UserInputType.Touch then
return
end

if flag19 then
return
end
flag19 = true
v124 = arg2

v125:Connect(v118.UserInputService.InputChanged, function(arg3)
if not flag19 then
return
end

if not v122.matchesPointerDrag(arg3, v124, Enum.UserInputType.MouseMovement) then
return
end
vector2 = Vector2.new(arg3.Position.X, arg3.Position.Y)
end)

v125:Connect(v118.RunService.RenderStepped, function()
local v126 = vector2
if v126 == nil then
return
end
vector2 = nil
local n = v126 - menuFrame.AbsolutePosition
local v127, v128 = v123.clampSizeToViewport(math.floor(n.X + v86[101]), math.floor(n.Y + v86[101]))
local udim2 = UDim2.fromOffset(v127, v128)
if udim2 == arg.Size then
return
end
menuFrame.Size = udim2
arg.Size = udim2
end)

v125:Connect(arg2.Changed, function()
if arg2.UserInputState == Enum.UserInputState.End then
fn38(v86[34])
end
end)
end

trove:Connect(textButton.InputBegan, fn39)

if v117.IsMobile() then
local frame2 = Instance.new("Frame")
frame2.AnchorPoint = Vector2.new(1, 1)
frame2.Position = UDim2.fromScale(1, 1)
frame2.Size = UDim2.fromOffset(36, 36)
frame2.BackgroundTransparency = 1
frame2.BorderSizePixel = 0
frame2.Active = true
frame2.ZIndex = menuFrame.ZIndex + 5
frame2.Parent = menuFrame
trove:Connect(frame2.InputBegan, fn39)
end
end

index2.new = function(arg, parent, arg2, arg3)
local v124 = arg2:Extend()
local v125 = v121.newBatch(v124)
local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundTransparency = 0
frame.Position = UDim2.fromScale(v86[101], 0.5)
frame.Size = arg3.Size or v123.resolveDefaultSize()
frame.BorderSizePixel = v86[186]
frame.Active = true
frame.Visible = false
v125:Bind(frame, "BackgroundColor3", "Background")
frame.Parent = parent
local v126 = v116.get()
local instance = Instance.new(v86[92])
instance.BackgroundTransparency = 1
instance.Text = ""
instance.Size = UDim2.new(v86[63], 0, v86[186], 20)

if v126.IsCompact then
instance.Size = UDim2.fromOffset(v126.Rail.Width, v126.Rail.HeaderHeight)
end

instance.Modal = true
instance.ZIndex = 50
instance.AutoButtonColor = false
instance.Parent = frame

if v117.Scale ~= 1 then
local uiScale = Instance.new("UIScale")
uiScale.Scale = v117.Scale
uiScale.Parent = frame
end

local instance2 = Instance.new(v86[85])
instance2.Transparency = v86[84]
v125:Bind(instance2, v86[27], "Outline")
instance2.Parent = frame
v115.addGlow(v125, frame, { Amount = 5, DampingFactor = v86[84] })
local size = frame.Size
local stateData = arg:GetStateData()
local size2 = stateData and stateData.Size

if type(size2) == "table" and #size2 >= 2 then
local v127, v128 = v123.clampSizeToViewport(size2[1], size2[2])
size = UDim2.fromOffset(v127, v128)
end

local offset = size.X.Offset
local offset2 = size.Y.Offset
stateData = stateData and stateData.Position
local udim2

if type(stateData) == "table" and #stateData >= 2 then
local v127, v128 = v123.clampPositionToParent(frame, stateData[1], stateData[2], offset, offset2)
udim2 = UDim2.fromOffset(v127, v128)
else
local v127, v128 = v123.centeredInParent(frame, offset, offset2)
udim2 = UDim2.fromOffset(v127, v128)
end

frame.Size = size
frame.AnchorPoint = Vector2.new(0, 0)
frame.Position = udim2
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 6)
uiCorner.Parent = frame
local instance3 = Instance.new(v86[128])
instance3.Position = UDim2.new(0, 0, 1, -8)
instance3.Size = UDim2.new(1, v86[186], 0, 8)
instance3.BorderSizePixel = 0
instance3.BackgroundColor3 = Color3.fromRGB(v86[108], 255, v86[108])
instance3.Parent = frame
local uiGradient = Instance.new("UIGradient")
uiGradient.Rotation = v86[45]
v125:BindGradient(uiGradient, { "Background", "GradientDeep" })
uiGradient.Parent = instance3
local frame2 = Instance.new("Frame")
frame2.BackgroundTransparency = 1
frame2.Position = UDim2.new(0, 0, 0, 0)
frame2.Size = UDim2.new(1, 0, v86[186], 5)
frame2.BorderSizePixel = v86[186]
frame2.ZIndex = frame.ZIndex + 1
frame2.Parent = frame
local instance4 = Instance.new(v86[128])
instance4.BackgroundTransparency = 0.08
instance4.Position = UDim2.new(0, v86[186], 0, 0)
instance4.Size = UDim2.new(1, 0, v86[186], 1)
instance4.BorderSizePixel = 0
instance4.ZIndex = frame2.ZIndex
v125:Bind(instance4, "BackgroundColor3", "Accent")
instance4.Parent = frame2
local uiGradient2 = Instance.new("UIGradient")
local numberSequence = NumberSequence.new
local tbl18 = {}
local v127 = NumberSequenceKeypoint.new(0, 1)
local v128 = NumberSequenceKeypoint.new(0.06, 0.35)
local v129 = NumberSequenceKeypoint.new(v86[101], v86[186])
local v130 = NumberSequenceKeypoint.new(0.94, 0.35)
local new = NumberSequenceKeypoint.new
local v131 = v86[63]
local v132 = v86[63]
tbl18[1] = v127
tbl18[2] = v128
tbl18[3] = v129
tbl18[4] = v130

do
local values = table.pack(new(v131, v132))
table.move(values, 1, values.n, 5, tbl18)
end

uiGradient2.Transparency = numberSequence(tbl18)
uiGradient2.Parent = instance4
local uiStroke = Instance.new("UIStroke")
uiStroke.Transparency = 0.78
v125:Bind(uiStroke, "Color", "Outline")
uiStroke.Parent = instance4
v115.addGlow(v125, instance4, { Amount = 2, DampingFactor = 0.78 })
local v133 = v119.new(arg, frame, v124, v125, arg3.Icon)
local width = v116.get().Rail.Width
local frame3 = Instance.new("Frame")
frame3.BackgroundTransparency = 1
frame3.Position = UDim2.fromOffset(width, v86[186])
frame3.Size = UDim2.new(1, -width, 1, 0)
frame3.BorderSizePixel = 0
v125:Bind(frame3, "BackgroundColor3", "Background")
frame3.Parent = frame
-- User-supplied Cloudy artwork; uses the existing theme binding lifecycle.
if K.CloudyBackground ~= nil then
local background = Instance.new("ImageLabel")
background.Name = "CloudyBackground"
background.BackgroundTransparency = 1
background.Image = K.CloudyBackground
v125:Bind(background, "ImageColor3", "Accent")
background.ImageTransparency = 0.8
background.ScaleType = Enum.ScaleType.Fit
background.AnchorPoint = Vector2.new(0, 0.5)
background.Position = UDim2.new(0, width + 16, 0.5, 0)
background.Size = UDim2.new(1, -width - 32, 0.7, 0)
background.BorderSizePixel = 0
background.Active = false
background.Selectable = false
background.ZIndex = frame.ZIndex + 1
background.Parent = frame
end
local uiCorner2 = Instance.new("UICorner")
uiCorner2.CornerRadius = UDim.new(0, v86[12])
uiCorner2.Parent = frame3
local uiStroke2 = Instance.new("UIStroke")
uiStroke2.Parent = frame3
v125:Bind(uiStroke2, "Color", "Outline")

local obj = setmetatable({
_trove = v124,
_menu = arg,
_batch = v125,
Title = arg3.Title,
Icon = arg3.Icon,
Size = size,
Open = v86[153],
MenuFrame = frame,
Panel = v133,
PageHolder = frame3,
ActiveTab = nil,
_modalButton = instance,
_menuOpenPosition = udim2,
}, index2)

v124:Connect(arg:MakeDraggable(frame, v124, { OnDragEnd = function(arg4)
fn36(arg, arg4)
end }).DragContinue, function()
obj._menuOpenPosition = frame.Position
end)

local uiDragDetector = Instance.new("UIDragDetector")
uiDragDetector.DragStyle = Enum.UIDragDetectorDragStyle.TranslatePlane
uiDragDetector.ResponseStyle = Enum.UIDragDetectorResponseStyle.CustomOffset
uiDragDetector.Parent = instance
local position = nil

v124:Connect(uiDragDetector.DragStart, function()
position = frame.Position
end)

v124:Connect(uiDragDetector.DragContinue, function()
local v134 = position
if v134 == nil then
return
end
local dragUDim2 = uiDragDetector.DragUDim2
frame.Position = UDim2.fromOffset(math.round(v134.X.Offset + dragUDim2.X.Offset), math.round(v134.Y.Offset + dragUDim2.Y.Offset))
v122.clampGuiToViewport(frame)
obj._menuOpenPosition = frame.Position
end)

v124:Connect(uiDragDetector.DragEnd, function()
position = nil
v122.clampGuiToViewport(frame)
obj._menuOpenPosition = frame.Position
fn36(arg, frame.Position)
end)

fn37(obj)
local v134 = v124:Extend()
local v135 = nil

v122.connectCurrentCameraViewport(v124, function(arg4)
if arg4 == nil then
v134:Clean()
v135 = nil
return
end

if arg4 == v135 then
return
end
v135 = arg4
v134:Clean()

v134:Add(task.defer(function()
local size3 = frame.Size
local v136, v137 = v123.clampSizeToViewport(size3.X.Offset, size3.Y.Offset)

if v136 ~= size3.X.Offset or v137 ~= size3.Y.Offset then
local udim22 = UDim2.fromOffset(v136, v137)
frame.Size = udim22
obj.Size = udim22
end

local position2 = frame.Position
local v138, v139 = v123.clampPositionToParent(frame, position2.X.Offset, position2.Y.Offset, v136, v137)

if v138 ~= position2.X.Offset or v139 ~= position2.Y.Offset then
local udim22 = UDim2.fromOffset(v138, v139)
frame.Position = udim22
obj._menuOpenPosition = udim22
end
end))
end)

v124:Connect(arg.VisibilityChanged, function(arg4)
if not arg4 then
return
end
local activeTab = obj.ActiveTab

if activeTab ~= nil then
activeTab:_FlushPendingOpen()
end
end)

return obj
end

index2.AddTab = function(arg, arg2)
return v120.new(arg._menu, arg, arg._trove, arg2)
end

index2.SetVisible = function(arg, open)
if arg.Open == open then
return false
end
arg.Open = open
arg._modalButton.Modal = open
arg.MenuFrame.Visible = open
return true
end

index2.SetTitle = function(arg, title)
arg.Title = title
end

index2.Destroy = function(arg)
arg.MenuFrame:Destroy()
arg._trove:Destroy()
end

return index2
end

tbl17.ax = function()
local ax = tbl17.cache.ax

if not ax then
ax = { c = fn35() }
tbl17.cache.ax = ax
end

return ax.c
end
end
do -- ay
local function fn35()local I={__mode="k"};local function W(N)if type(N)=="function"then return true;end;if type(N)=="table"then local P=getmetatable(N);if P and type( v102 (P,"__call"))=="function"then return true;end;end;return false;end;local function N(P,a)local e={};for c,c_34 in ipairs(a)do e[c_34]=c_34;end;return setmetatable(e,{__index=function(a,a_35)error(string.format("%s is not in %s!",a_35,P),2);end,__newindex=function()error(string.format("Creating new members in %s is not allowed!",P),2);end});end;local P:any;P={Kind=N("Promise.Error.Kind",{"ExecutionError","AlreadyCancelled","NotResolvedInTime","TimedOut"})};P.__index=P;P.new=function(a,e)a=a or{};return setmetatable({error=tostring(a.error)or"[This error has no error text.]",trace=a.trace,context=a.context,kind=a.kind,parent=e,createdTick=os.clock(),createdTrace=debug.traceback()},P);end;P.is=function(a)if type(a)=="table"then local e=getmetatable(a);if type(e)=="table"then return  v102 (a,"error")~=nil and type( v102 (e,"extend"))=="function";end;end;return false;end;P.isKind=function(a,e)assert(e~=nil,"Argument #2 to Promise.Error.isKind must not be nil");return P.is(a)and a.kind==e;end;P.extend=function(a,e)e=e or{};e.kind=e.kind or a.kind;return P.new(e,a);end;P.getErrorChain=function(a)local e={a};while e[#e].parent do table.insert(e,e[#e].parent);end;return e;end;P.__tostring=function(a)local e={string.format("-- Promise.Error(%s) --",a.kind or"?")};for c,c_36 in ipairs(a:getErrorChain())do table.insert(e,table.concat({c_36.trace or c_36.error,c_36.context},"\10"));end;return table.concat(e,"\10");end;local function a(...)return select("#",...),{...};end;local function e(c,...)return c,select("#",...),{...};end;local function c(E)assert(E~=nil,"traceback is nil");return function(p)if type(p)=="table"then return p;end;return P.new({error=p,kind=P.Kind.ExecutionError,trace=debug.traceback(tostring(p),2),context="Promise created at:\10\10"..E});end;end;local function E(p,T,...)return e(xpcall(T,c(p),...));end;local function e_37(c,p,T,t)return function(...)local x,S,J=E(c,p,...);if x then T(unpack(J,1,S));else t(J[1]);end;end;end;local function c_38(p)return next(p)==nil;end;local p:any={Error=P,Status=N("Promise.Status",{"Started","Resolved","Rejected","Cancelled"}),_getTime=os.clock,_timeEvent=game:GetService("RunService").Heartbeat,_unhandledRejectionCallbacks={},prototype={}};p.__index=p.prototype;p._new=function(N,T,t)if t~=nil and not p.is(t)then error("Argument #2 to Promise.new must be a promise or nil",2);end;local x={_thread=nil,_source=N,_status=p.Status.Started,_values=nil,_valuesLength=-1,_unhandledRejection=true,_queuedResolve={},_queuedReject={},_queuedFinally={},_cancellationHook=nil,_parent=t,_consumers=setmetatable({},I)};if t and t._status==p.Status.Started then t._consumers[x]=true;end;setmetatable(x,p);local function I(...)x:_resolve(...);end;local function N_39(...)x:_reject(...);end;local function t_40(S)if S then if x._status==p.Status.Cancelled then S();else x._cancellationHook=S;end;end;return x._status==p.Status.Cancelled;end;x._thread=coroutine.create(function()local S,_J,J_41=E(x._source,T,I,N_39,t_40);if not S then N_39(J_41[1]);end;end);task.spawn(x._thread);return x;end;p.new=function(I)return p._new(debug.traceback(nil,2),I);end;p.__tostring=function(I)return string.format("Promise(%s)",I._status);end;p.defer=function(I)local N=debug.traceback(nil,2);return(p._new(N,function(T,t,x)local S;S=p._timeEvent:Connect(function()S:Disconnect();local S,_J_42,J_43=E(N,I,T,t,x);if not S then t(J_43[1]);end;end);end));end;p.async=p.defer;p.resolve=function(...)local I,N=a(...);return p._new(debug.traceback(nil,2),function(E)E(unpack(N,1,I));end);end;p.reject=function(...)local I,N=a(...);return p._new(debug.traceback(nil,2),function(E,E_44)E_44(unpack(N,1,I));end);end;p._try=function(I,N,...)local E,T=a(...);return p._new(I,function(I)I(N(unpack(T,1,E)));end);end;p.try=function(I,...)return p._try(debug.traceback(nil,2),I,...);end;p._all=function(I,N,E)if type(N)~="table"then error(string.format("Please pass a list of promises to %s","Promise.all"),3);end;for T,t in pairs(N)do if not p.is(t)then error(string.format("Non-promise value passed into %s at index %s","Promise.all",tostring(T)),3);end;end;if#N==0 or E==0 then return p.resolve({});end;return p._new(I,function(I,T,t)local x,S,J,B,X={},{},0,0,false;local function H()for k,k_45 in ipairs(S)do k_45:cancel();end;end;local function k(D,...)if X then return;end;J+=1;if E==nil then x[D]=...;else x[J]=...;end;if J>=(E or#N)then X=true;I(x);H();end;end;t(H);for I,t in ipairs(N)do S[I]=t:andThen(function(...)k(I,...);end,function(...)B+=1;if E==nil or#N-B<E then H();X=true;T(...);end;end);end;if X then H();end;end);end;p.all=function(I)return p._all(debug.traceback(nil,2),I);end;p.fold=function(I,N,E)assert(type(I)=="table","Bad argument #1 to Promise.fold: must be a table");assert(W(N),"Bad argument #2 to Promise.fold: must be a function");local T=p.resolve(E);return p.each(I,function(I,E)T=T:andThen(function(t)return N(t,I,E);end);end):andThen(function()return T;end);end;p.some=function(I,N)assert(type(N)=="number","Bad argument #2 to Promise.some: must be a number");return p._all(debug.traceback(nil,2),I,N);end;p.any=function(I)return p._all(debug.traceback(nil,2),I,1):andThen(function(I)return I[1];end);end;p.allSettled=function(I)if type(I)~="table"then error(string.format("Please pass a list of promises to %s","Promise.allSettled"),2);end;for N,E in pairs(I)do if not p.is(E)then error(string.format("Non-promise value passed into %s at index %s","Promise.allSettled",tostring(N)),2);end;end;if#I==0 then return p.resolve({});end;return p._new(debug.traceback(nil,2),function(N,E,E_46)local T,t,x={},{},0;local function S(J,...)x+=1;T[J]=...;if x>=#I then N(T);end;end;E_46(function()for N,N_47 in ipairs(t)do N_47:cancel();end;end);for N,E in ipairs(I)do t[N]=E:finally(function(...)S(N,...);end);end;end);end;p.race=function(I)assert(type(I)=="table",string.format("Please pass a list of promises to %s","Promise.race"));for N,E in pairs(I)do assert(p.is(E),string.format("Non-promise value passed into %s at index %s","Promise.race",tostring(N)));end;return p._new(debug.traceback(nil,2),function(N,E,T)local t,x={},false;local function S()for J,J_48 in ipairs(t)do J_48:cancel();end;end;local function J(B)return function(...)S();x=true;return B(...);end;end;if T((J(E)))then return;end;for T,B in ipairs(I)do t[T]=B:andThen(J(N),(J(E)));end;if x then S();end;end);end;p.each=function(I,N)assert(type(I)=="table",string.format("Please pass a list of promises to %s","Promise.each"));assert(W(N),string.format("Please pass a handler function to %s!","Promise.each"));return p._new(debug.traceback(nil,2),function(E,T,t)local x,S,J={},{},false;local function B()for X,X_49 in ipairs(S)do X_49:cancel();end;end;t(function()J=true;B();end);t={};for X,H in ipairs(I)do if p.is(H)then if H:getStatus()==p.Status.Cancelled then B();return T(P.new({error="Promise is cancelled",kind=P.Kind.AlreadyCancelled,context=string.format("The Promise that was part of the array at index %d passed into Promise.each was already cancelled when Promise.each began.\10\10That Promise was created at:\10\10%s",X,H._source)}));elseif H:getStatus()==p.Status.Rejected then B();return T(select(2,H:await()));end;local I=H:andThen(function(...)return...;end);table.insert(S,I);t[X]=I;else t[X]=H;end;end;for I,X in ipairs(t)do if p.is(X)then local t_50;t_50,X=X:await();if not t_50 then B();return T(X);end;end;if J then return;end;local t_51=p.resolve(N(X,I));table.insert(S,t_51);local N,S_52=t_51:await();if not N then B();return T(S_52);end;x[I]=S_52;end;E(x);return nil end);end;p.is=function(I)if type(I)~="table"then return false;end;local N=getmetatable(I);if N==p then return true;elseif N==nil then return W(I.andThen);elseif type(N)=="table"and type( v102 (N,"__index"))=="table"and(W( v102 ( v102 (N,"__index"),"andThen")))then return true;end;return false;end;p.promisify=function(l)return function(...)return p._try(debug.traceback(nil,2),l,...);end;end;do local l,I_53;p.delay=function(N)assert(type(N)=="number","Bad argument #1 to Promise.delay, must be a number.");if not(N>=0.016666666666666666)or N==math.huge then N=0.016666666666666666;end;return p._new(debug.traceback(nil,2),function(E,T,t)T=p._getTime();local x=T+N;local N={resolve=E,startTime=T,endTime=x};if I_53==nil then l=N;I_53=p._timeEvent:Connect(function()local S=p._getTime();while l~=nil and l.endTime<S do local S_54=l;local J=S_54;l=S_54.next;if l==nil then I_53:Disconnect();I_53=nil;else l.previous=nil;end;J.resolve(p._getTime()-J.startTime);end;end);elseif l.endTime<x then T=l;E=T.next;while E~=nil and E.endTime<x do E,T=E.next,E;end;T.next=N;N.previous=T;if E~=nil then N.next=E;E.previous=N;end;else N.next=l;l.previous=N;l=N;end;t(function()local E=N.next;if l==N then if E==nil then I_53:Disconnect();I_53=nil;else E.previous=nil;end;l=E;else local l=N.previous;l.next=E;if E~=nil then E.previous=l;end;end;end);end);end;end;p.prototype.timeout=function(l,I,N)local E=debug.traceback(nil,2);return p.race({p.delay(I):andThen(function()return p.reject(N==nil and(P.new({kind=P.Kind.TimedOut,error="Timed out",context=string.format("Timeout of %d seconds exceeded.\10:timeout() called at:\10\10%s",I,E)}))or N);end),l});end;p.prototype.getStatus=function(l)return l._status;end;p.prototype._andThen=function(l,I,N,E)l._unhandledRejection=false;if l._status==p.Status.Cancelled then local T=p.new(function()end);T:cancel();return T;end;return p._new(I,function(T,t,x)local S=T;if N then S=e_37(I,N,T,t);end;local N=t;if E then N=e_37(I,E,T,t);end;if l._status==p.Status.Started then table.insert(l._queuedResolve,S);table.insert(l._queuedReject,N);x(function()if l._status==p.Status.Started then table.remove(l._queuedResolve,table.find(l._queuedResolve,S));table.remove(l._queuedReject,table.find(l._queuedReject,N));end;end);elseif l._status==p.Status.Resolved then S(unpack(l._values,1,l._valuesLength));elseif l._status==p.Status.Rejected then N(unpack(l._values,1,l._valuesLength));end;end,l);end;p.prototype.andThen=function(l,I,N)assert(I==nil or(W(I)),string.format("Please pass a handler function to %s!","Promise:andThen"));assert(N==nil or(W(N)),string.format("Please pass a handler function to %s!","Promise:andThen"));return l:_andThen(debug.traceback(nil,2),I,N);end;p.prototype.catch=function(l,I)assert(I==nil or(W(I)),string.format("Please pass a handler function to %s!","Promise:catch"));return l:_andThen(debug.traceback(nil,2),nil,I);end;p.prototype.tap=function(l,I)assert(W(I),string.format("Please pass a handler function to %s!","Promise:tap"));return l:_andThen(debug.traceback(nil,2),function(...)local l=I(...);if p.is(l)then local I,N=a(...);return l:andThen(function()return unpack(N,1,I);end);end;return...;end);end;p.prototype.andThenCall=function(l,I,...)assert(W(I),string.format("Please pass a handler function to %s!","Promise:andThenCall"));local N,e=a(...);return l:_andThen(debug.traceback(nil,2),function()return I(unpack(e,1,N));end);end;p.prototype.andThenReturn=function(l,...)local I,N=a(...);return l:_andThen(debug.traceback(nil,2),function()return unpack(N,1,I);end);end;p.prototype.cancel=function(l)if l._status~=p.Status.Started then return;end;l._status=p.Status.Cancelled;if l._cancellationHook then l._cancellationHook();end;coroutine.close(l._thread);if l._parent then l._parent:_consumerCancelled(l);end;for I in pairs(l._consumers)do I:cancel();end;l:_finalize();end;p.prototype._consumerCancelled=function(l,I)if l._status~=p.Status.Started then return;end;l._consumers[I]=nil;if next(l._consumers)==nil then l:cancel();end;end;p.prototype._finally=function(l,I,N)l._unhandledRejection=false;return(p._new(I,function(I,e,E)local T;E(function()l:_consumerCancelled(l);if T then T:cancel();end;end);E=if N then function(...)local t=N(...);if p.is(t)then T=t;t:finally(function(N)if N~=p.Status.Rejected then I(l);end;end):catch(function(...)e(...);end);else I(l);end;end else I;if l._status==p.Status.Started then table.insert(l._queuedFinally,E);else E(l._status);end;end));end;p.prototype.finally=function(l,I)assert(I==nil or(W(I)),string.format("Please pass a handler function to %s!","Promise:finally"));return l:_finally(debug.traceback(nil,2),I);end;p.prototype.finallyCall=function(l,I,...)assert(W(I),string.format("Please pass a handler function to %s!","Promise:finallyCall"));local N,e=a(...);return l:_finally(debug.traceback(nil,2),function()return I(unpack(e,1,N));end);end;p.prototype.finallyReturn=function(l,...)local I,N=a(...);return l:_finally(debug.traceback(nil,2),function()return unpack(N,1,I);end);end;p.prototype.awaitStatus=function(l)l._unhandledRejection=false;if l._status==p.Status.Started then local I=coroutine.running();l:finally(function()task.spawn(I);end):catch(function()end);coroutine.yield();end;if l._status==p.Status.Resolved then return l._status,unpack(l._values,1,l._valuesLength);elseif l._status==p.Status.Rejected then return l._status,unpack(l._values,1,l._valuesLength);end;return l._status;end;local function l(I,...)return I==p.Status.Resolved,...;end;p.prototype.await=function(I)return l(I:awaitStatus());end;local function l_55(I,...)if I~=p.Status.Resolved then error(...==nil and"Expected Promise rejected with no value."or(...),3);end;return...;end;p.prototype.expect=function(I)return l_55(I:awaitStatus());end;p.prototype.awaitValue=p.prototype.expect;p.prototype._unwrap=function(l)if l._status==p.Status.Started then error("Promise has not resolved or rejected.",2);end;return l._status==p.Status.Resolved,unpack(l._values,1,l._valuesLength);end;p.prototype._resolve=function(l,...)if l._status~=p.Status.Started then if p.is(...)then(...):_consumerCancelled(l);end;return;end;if p.is(...)then if select("#",...)>1 then warn((string.format("When returning a Promise from andThen, extra arguments are discarded! See:\10\10%s",l._source)));end;local I=...;local N=I:andThen(function(...)l:_resolve(...);end,function(...)local e=I._values[1];e=if I._error then(P.new({error=I._error,kind=P.Kind.ExecutionError,context="No stack trace available as this Promise originated from an older version of the Promise library (< v2)"}))else e;if P.isKind(e,P.Kind.ExecutionError)then return l:_reject(e:extend({error="This Promise was chained to a Promise that errored.",trace="",context=string.format("The Promise at:\10\10%s\10...Rejected because it was chained to the following Promise, which encountered an error:\10",l._source)}));end;l:_reject(...);return nil end);if N._status==p.Status.Cancelled then l:cancel();elseif N._status==p.Status.Started then l._parent=N;N._consumers[l]=true;end;return;end;l._status=p.Status.Resolved;l._valuesLength,l._values=a(...);for I,I_56 in ipairs(l._queuedResolve)do coroutine.wrap(I_56)(...);end;l:_finalize();end;p.prototype._reject=function(l,...)if l._status~=p.Status.Started then return;end;l._status=p.Status.Rejected;l._valuesLength,l._values=a(...);if not c_38(l._queuedReject)then for I,I_57 in ipairs(l._queuedReject)do coroutine.wrap(I_57)(...);end;else local I=tostring(...);coroutine.wrap(function()p._timeEvent:Wait();if not l._unhandledRejection then return;end;local N=string.format("Unhandled Promise rejection:\10\10%s\10\10%s",I,l._source);for I,I_58 in ipairs(p._unhandledRejectionCallbacks)do task.spawn(I_58,l,unpack(l._values,1,l._valuesLength));end;if p.TEST then return;end;warn(N);end)();end;l:_finalize();end;p.prototype._finalize=function(l)for I,I_59 in ipairs(l._queuedFinally)do coroutine.wrap(I_59)(l._status);end;l._queuedFinally=nil;l._queuedReject=nil;l._queuedResolve=nil;if not p.TEST then l._parent=nil;l._consumers=nil;end;task.defer(coroutine.close,l._thread);end;p.prototype.now=function(l,I)local N=debug.traceback(nil,2);if l._status==p.Status.Resolved then return l:_andThen(N,function(...)return...;end);else return p.reject(I==nil and(P.new({kind=P.Kind.NotResolvedInTime,error="This Promise was not resolved in time for :now()",context=":now() was called at:\10\10"..N}))or I);end;end;p.retry=function(l,I,...)assert(W(l),"Parameter #1 to Promise.retry must be a function");assert(type(I)=="number","Parameter #2 to Promise.retry must be a number");local N,P={...},select("#",...);return p.resolve(l(...)):catch(function(...)if I>0 then return p.retry(l,I-1,unpack(N,1,P));else return p.reject(...);end;end);end;p.retryWithDelay=function(l,I,N,...)assert(W(l),"Parameter #1 to Promise.retry must be a function");assert(type(I)=="number","Parameter #2 (times) to Promise.retry must be a number");assert(type(N)=="number","Parameter #3 (seconds) to Promise.retry must be a number");local W,P={...},select("#",...);return p.resolve(l(...)):catch(function(...)if I>0 then p.delay(N):await();return p.retryWithDelay(l,I-1,N,unpack(W,1,P));else return p.reject(...);end;end);end;p.fromEvent=function(l,I)I=I or function()return true;end;return p._new(debug.traceback(nil,2),function(W,N,N_60)local P;local a=false;local function e()P:Disconnect();P=nil;end;P=l:Connect(function(...)local l=I(...);if l==true then W(...);if P then e();else a=true;end;elseif type(l)~="boolean"then error("Promise.fromEvent predicate should always return a boolean");end;end);if a and P then e();return;end;N_60(e);end);end;p.onUnhandledRejection=function(l)table.insert(p._unhandledRejectionCallbacks,l);return function()local I=table.find(p._unhandledRejectionCallbacks,l);if I then table.remove(p._unhandledRejectionCallbacks,I);end;end;end;return p;end

tbl17.ay = function()
local ay = tbl17.cache.ay

if not ay then
local ay2 = { c = fn35() }
tbl17.cache.ay = ay2
ay = ay2
end

return ay.c
end
end
do -- az
local function fn35()
local v115 = tbl17.b()
local v116 = tbl17.ay()
local v117 = tbl17.a()
local v118 = tbl17.e()
local v119 = cloneref(game:GetService(v86[182]))

local tbl18 = {
Arial = Enum.Font.Arial,
Roboto = Enum.Font.Roboto,
Ubuntu = Enum.Font.Ubuntu,
Inconsolata = Enum.Font.Code,
}

local tbl19 = {
Minecraftia = {
Url = "https://github.com/kiciahook-org/v3-assets/raw/refs/heads/main/Minecraftia-Regular.ttf",
FileName = "Minecraftia-Regular.ttf",
Weight = Enum.FontWeight.Regular,
Style = Enum.FontStyle.Normal,
},
[v86[43]] = {
Url = "https://github.com/kiciahook-org/v3-assets/raw/refs/heads/main/Proggy-Clean.ttf",
FileName = "Proggy-Clean.ttf",
Weight = Enum.FontWeight.Regular,
Style = Enum.FontStyle.Normal,
},
[v86[125]] = {
Url = "https://github.com/kiciahook-org/v3-assets/raw/refs/heads/main/Proggy-Tiny.ttf",
FileName = "Proggy-Tiny.ttf",
Weight = Enum.FontWeight.Regular,
Style = Enum.FontStyle.Normal,
},
}

local font = Font.fromEnum(Enum.Font.SourceSans)

local index2 = {
Order = { "Minecraftia", "Proggy Clean", v86[125], "Arial", v86[24], "Ubuntu", "Inconsolata" },
}

index2.__index = index2

local function fn36(arg)
return arg == Enum.FontStyle.Italic and "italic" or "normal"
end

local function fn37(arg, arg2)
return v116.new(function(arg3)
local str7 = string.format("%s/%s", "CloudyUI/fonts", tostring(arg2.FileName))

if not isfile(str7) then
local v120, v121 = v107(function()
return game:HttpGet(arg2.Url)
end)

if not v120 or type(v121) ~= "string" then
local v122 = tostring
arg3(v117.err("Fonts", "fetch", string.format("HttpGet failed for %s: %s", tostring(arg2.Url), v122(v121))))
return
end

local v122, v123 = v107(writefile, str7, v121)

if not v122 then
local v124 = tostring
arg3(v117.err("Fonts", "write", string.format("writefile failed for %s: %s", tostring(str7), v124(v123))))
return
end
end

local v120, v121 = v107(getcustomasset, str7)
local flag19 = not v120

if not flag19 then
local v122 = v86[165]
flag19 = type(v121) ~= v122
end

if flag19 then
local v122 = tostring
arg3(v117.err("Fonts", "asset", string.format("getcustomasset failed for %s: %s", tostring(str7), v122(v121))))
return
end

local tbl20 = {
name = arg,
faces = { { name = "Regular", weight = arg2.Weight.Value, style = fn36(arg2.Style), assetId = v121 } },
}

local str8 = string.format("%s/%s.json", "CloudyUI/fonts", tostring(arg))
local v122, v123 = v107(writefile, str8, v119:JSONEncode(tbl20))

if not v122 then
local v124 = tostring
arg3(v117.err("Fonts", v86[166], string.format("writefile failed for %s: %s", tostring(str8), v124(v123))))
return
end

local v124, v125 = v107(getcustomasset, str8)

if not v124 or type(v125) ~= "string" then
local v126 = tostring
arg3(v117.err(v86[104], v86[151], string.format("getcustomasset failed for %s: %s", tostring(str8), v126(v125))))
return
end

arg3(v117.ok(Font.new(v125, arg2.Weight, arg2.Style)))
end)
end

index2._New = function()
return setmetatable({ _initialized = false, _fontByName = {} }, index2)
end

index2.Initialize = function(arg)
if arg._initialized then
return v117.VoidOk
end
arg._initialized = true

for k, v120 in tbl18, nil, nil do
arg._fontByName[k] = Font.fromEnum(v120)
end

v118("CloudyUI/fonts")
local tbl20 = {}
local flag19 = true

for k, v120 in (K.DownloadFonts == false and {} or tbl19), nil, nil do
table.insert(tbl20, fn37(k, v120):andThen(function(arg2)
if arg2.Ok then
arg._fontByName[k] = arg2.Value
else
arg._fontByName[k] = font
flag19 = false
v115.get():Report(arg2.Error)
end
end))
end

v116.all(tbl20):await()
return flag19 and v117.VoidOk or v117.err("Fonts", "Initialize", "Failed to load all fonts")
end

index2.Get = function(arg, arg2)
return arg._fontByName[arg2] or font
end

return index2._New()
end

tbl17.az = function()
local az = tbl17.cache.az

if not az then
az = { c = fn35() }
tbl17.cache.az = az
end

return az.c
end
end
do -- aA
local function fn35()
local v115 = tbl17.k()
local tweenService = tbl17.t().TweenService
local index2 = {}
index2.__index = index2
local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local function fn36(arg)
return math.ceil(arg * 1.25) + 10
end

local tbl18 = { ["&"] = "&amp;", ["<"] = "&lt;", [">"] = "&gt;" }

local function fn37(arg)
return (arg:gsub("[&<>]", tbl18))
end

local function fn38(arg, arg2, arg3)
if type(arg) == "string" then
return arg
end
local v116 = table.create(#arg)

for k, v117 in arg, nil, nil do
local v118 = (v117.Accent and arg3 or v117.Color or arg2):ToHex()
local v119 = fn37(v117.Text)
v116[k] = string.format("<font color=\"#%s\">%s</font>", tostring(v118), tostring(v119))
end

return table.concat(v116, "")
end

local function fn39(arg, arg2)
return UDim2.new(arg, 0, 0.5, arg2)
end

index2.new = function(arg, arg2, arg3, arg4, arg5)
local v116 = v115.new()
local v117 = v116:Extend()
local alignX = arg.AlignX
local frame = Instance.new("Frame")
frame.BackgroundTransparency = 1
frame.BorderSizePixel = 0
frame.Size = UDim2.new(v86[63], v86[186], 0, fn36(arg3.Size))
frame.LayoutOrder = arg.Order
v116:Add(frame)
local instance = Instance.new(v86[128])
instance.BackgroundColor3 = arg3.Background
instance.BackgroundTransparency = 1
instance.BorderSizePixel = 0
instance.AnchorPoint = Vector2.new(alignX, 0.5)
instance.Position = fn39(alignX, -v86[9])
instance.Size = UDim2.fromOffset(v86[186], 0)
instance.AutomaticSize = Enum.AutomaticSize.XY
instance.Parent = frame
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, v86[26])
uiCorner.Parent = instance
local uiStroke = Instance.new("UIStroke")
uiStroke.Color = arg3.Accent
uiStroke.Transparency = 1
uiStroke.Parent = instance
local instance2 = Instance.new(v86[113])
instance2.PaddingTop = UDim.new(0, 5)
instance2.PaddingBottom = UDim.new(v86[186], 5)
instance2.PaddingLeft = UDim.new(v86[186], 10)
instance2.PaddingRight = UDim.new(v86[186], v86[133])
instance2.Parent = instance
local textLabel = Instance.new("TextLabel")
textLabel.BackgroundTransparency = 1
textLabel.BorderSizePixel = 0
textLabel.Size = UDim2.fromOffset(0, 0)
textLabel.AutomaticSize = Enum.AutomaticSize.XY
textLabel.FontFace = arg3.Font
textLabel.RichText = true
textLabel.Text = fn38(arg2, arg3.TextColor, arg3.Accent)
textLabel.TextColor3 = arg3.TextColor
textLabel.TextSize = arg3.Size
textLabel.TextTransparency = v86[63]
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.TextYAlignment = Enum.TextYAlignment.Center
textLabel.Parent = instance
frame.Parent = arg.Parent

local tbl19 = {
_trove = v116,
_motionTrove = v117,
_ghost = frame,
_bar = instance,
_stroke = uiStroke,
_label = textLabel,
_alignX = alignX,
_dismissing = false,
_destroyed = false,
_onDestroyed = arg5,
}

setmetatable(tbl19, index2)
tbl19:_AnimateIn()

if arg4 > 0 then
v116:Add(task.delay(arg4, function()
tbl19:Dismiss()
end))
end

return tbl19
end

index2._AnimateIn = function(arg)
local trove = arg._trove
local motionTrove = arg._motionTrove
local bar = arg._bar
trove:Add(tweenService:Create(bar, tweenInfo, { BackgroundTransparency = 0.4 })):Play()
trove:Add(tweenService:Create(arg._stroke, tweenInfo, { Transparency = 0.4 })):Play()
trove:Add(tweenService:Create(arg._label, tweenInfo, { TextTransparency = v86[186] })):Play()
local v116 = motionTrove:Add(tweenService:Create(bar, tweenInfo, { Position = fn39(arg._alignX, 4) }))

motionTrove:Connect(v116.Completed, function()
if arg._dismissing then
return
end
motionTrove:Add(tweenService:Create(bar, tweenInfo2, { Position = fn39(arg._alignX, v86[186]) })):Play()
end)

v116:Play()
end

index2.SetLayout = function(arg, arg2)
if arg._destroyed then
return
end
arg._motionTrove:Clean()
arg._alignX = arg2.AlignX
arg._ghost.LayoutOrder = arg2.Order
arg._bar.AnchorPoint = Vector2.new(arg2.AlignX, v86[101])

if arg._dismissing then
arg:_AnimateOut()
else
arg._bar.Position = fn39(arg2.AlignX, 0)
end
end

index2._AnimateOut = function(arg)
local v116 = arg._motionTrove:Add(tweenService:Create(arg._bar, tweenInfo3, { Position = fn39(arg._alignX, -v86[9]), BackgroundTransparency = v86[63] }))

arg._motionTrove:Connect(v116.Completed, function()
arg:Destroy()
end)

v116:Play()
end

index2.Dismiss = function(arg)
if arg._dismissing then
return
end
arg._dismissing = true
arg._trove:Add(tweenService:Create(arg._stroke, tweenInfo3, { Transparency = 1 })):Play()
-- (fix) decompiler dropped the receiver: v116 was never assigned, so this crashed on Dismiss
arg._trove:Add(tweenService:Create(arg._label, tweenInfo3, { TextTransparency = v86[63] })):Play()
arg:_AnimateOut()
end

index2.Destroy = function(arg)
if arg._destroyed then
return
end
arg._destroyed = true
arg._trove:Destroy()
arg._onDestroyed()
end

return index2
end

tbl17.aA = function()
local aa = tbl17.cache.aA

if not aa then
local aa2 = { c = fn35() }
tbl17.cache.aA = aa2
aa = aa2
end

return aa.c
end
end
do -- aB
local function fn35()
tbl17.r()
local v115 = tbl17.aA()
local v116 = tbl17.t()
local v117 = tbl17.k()
local v118 = tbl17.w()
local index2 = {}
index2.__index = index2

local function fn36()
local currentCamera = workspace.CurrentCamera
if currentCamera == nil then
return 16, 16, 16, 16
end
local insetArea = v116.GuiService:GetInsetArea(Enum.ScreenInsets.CoreUISafeInsets)
local viewportSize = currentCamera.ViewportSize
local n = v86[13] + math.max(0, insetArea.Min.X)
local n33 = v86[13] + math.max(0, insetArea.Min.Y)
local n34 = 16 + math.max(0, viewportSize.X - insetArea.Max.X)
return n33, v86[13] + math.max(v86[186], viewportSize.Y - insetArea.Max.Y), n, n34
end

local tbl18 = {
TopLeft = { AlignX = 0, Valign = Enum.VerticalAlignment.Top },
TopRight = { AlignX = 1, Valign = Enum.VerticalAlignment.Top },
BottomLeft = { AlignX = 0, Valign = Enum.VerticalAlignment.Bottom },
BottomRight = { AlignX = 1, Valign = Enum.VerticalAlignment.Bottom },
Center = { AlignX = v86[101], Valign = Enum.VerticalAlignment.Top },
Crosshair = { AlignX = 0.5, Valign = Enum.VerticalAlignment.Center, Crosshair = true },
}

index2.SideSpecs = { "TopLeft", "TopRight", "BottomLeft", v86[52], "Center", "Crosshair" }

local tbl19 = {
success = Color3.fromRGB(72, 199, v86[15]),
warning = Color3.fromRGB(255, 183, v86[109]),
error = Color3.fromRGB(v86[79], v86[58], 82),
}

local v119 = nil

index2.use = function(arg, arg2, arg3, arg4, displayOrder)
if v119 ~= nil then
return v119
end
local v120 = v117.new()
local v121 = v120:Add(Instance.new("ScreenGui"))
v121.IgnoreGuiInset = true
v121.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
v121.DisplayOrder = displayOrder
v121.Parent = K.hudParent()
local frame = Instance.new("Frame")
frame.BackgroundTransparency = 1
frame.BorderSizePixel = 0
frame.Size = UDim2.fromScale(v86[63], 1)
frame.Parent = v121
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingTop = UDim.new(v86[186], v86[13])
uiPadding.PaddingBottom = UDim.new(0, 16)
uiPadding.PaddingLeft = UDim.new(0, 16)
uiPadding.PaddingRight = UDim.new(0, 16)
uiPadding.Parent = frame
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, v86[54])
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = frame

local tbl20 = {
_trove = v120,
_config = arg,
_pathByKey = {
Enabled = v118.appendPath(arg2, "Enabled"),
Side = v118.appendPath(arg2, "Side"),
Size = v118.appendPath(arg2, "Size"),
Font = v118.appendPath(arg2, v86[59]),
Offset = v118.appendPath(arg2, "Offset"),
ThemeAccent = v118.appendPath(arg3, "Accent"),
ThemeBackground = v118.appendPath(arg3, "Background"),
ThemeText = v118.appendPath(arg3, "TextColor"),
TextColor = v118.appendPath(arg3, "TextColor"),
},
_resolveFont = arg4,
_container = frame,
_margin = uiPadding,
_list = uiListLayout,
_stack = {},
_counter = v86[186],
_destroyed = false,
}

setmetatable(tbl20, index2)

v120:Connect(arg:GetPropertyChangedSignal(tbl20._pathByKey.Side), function()
tbl20:_ApplyLayout()
end)

v120:Connect(arg:GetPropertyChangedSignal(tbl20._pathByKey.Offset), function()
tbl20:_ApplyLayout()
end)

v120:Connect(arg:GetPropertyChangedSignal(tbl20._pathByKey.Enabled), function()
if not tbl20:_ApplyLayout() then
tbl20:Clear()
end
end)

v118.connectCurrentCameraViewport(v120, function()
tbl20:_ApplyLayout()
end)

v119 = tbl20
return tbl20
end

index2.get = function()
assert(v119, "Notifications is not ready yet")
return v119
end

index2.template = function(arg, arg2)
local tbl20 = {}
local n = 1

while v86[34] do
local pos, v120, v121 = arg:find("%%(%w+)%%", n)

if not (pos == nil or v120 == nil or v121 == nil) then
if n < pos then
table.insert(tbl20, { Text = arg:sub(n, pos - 1) })
end

local v122 = arg2[v121]

if v122 ~= nil then
table.insert(tbl20, { Text = v122, Accent = v86[34] })
else
table.insert(tbl20, { Text = arg:sub(pos, v120) })
end

n = v120 + 1
continue
end

break
end

if n <= #arg then
table.insert(tbl20, { Text = arg:sub(n) })
end

return tbl20
end

index2._Get = function(arg, arg2)
local _p = arg._pathByKey[arg2]
if _p == nil then return nil end
return arg._config:Get(_p, true)
end

index2._SideSpec = function(arg)
return tbl18[arg:_Get(v86[50])] or tbl18.TopRight
end

index2._ResolveTheme = function(arg, arg2)
local color = arg2.Color
local intent = arg2.Intent

if color == nil and intent ~= nil then
color = tbl19[intent]
end

return {
Accent = color or arg:_Get("ThemeAccent"),
Background = arg:_Get("ThemeBackground"),
TextColor = arg:_Get(v86[57]),
Font = arg._resolveFont(arg:_Get("Font")),
Size = arg:_Get(v86[29]),
}
end

index2._ApplyLayout = function(arg)
local v120 = arg:_SideSpec()
local n, n33, v121, v122 = fn36()

if v120.Crosshair then
n33 = 16
n = 16
end

arg._margin.PaddingTop = UDim.new(0, n)
arg._margin.PaddingBottom = UDim.new(0, n33)
arg._margin.PaddingLeft = UDim.new(0, v121)
arg._margin.PaddingRight = UDim.new(v86[186], v122)
local visible = arg:_Get(v86[44]) == true
arg._container.Visible = visible

if v120.Crosshair then
local Offset = arg:_Get("Offset") or 0

if Offset >= 0 then
arg._list.VerticalAlignment = Enum.VerticalAlignment.Top
arg._container.Position = UDim2.new(0, v86[186], 0.5, Offset)
arg._container.Size = UDim2.new(1, 0, 0.5, -Offset)
else
arg._list.VerticalAlignment = Enum.VerticalAlignment.Bottom
arg._container.Position = UDim2.fromScale(v86[186], 0)
arg._container.Size = UDim2.new(v86[63], 0, 0.5, Offset)
end
else
arg._list.VerticalAlignment = v120.Valign
arg._container.Position = UDim2.fromScale(0, 0)
arg._container.Size = UDim2.fromScale(1, 1)
end

for k, v123 in arg._stack, nil, nil do
v123:SetLayout({
Parent = arg._container,
Order = arg._list.VerticalAlignment == Enum.VerticalAlignment.Bottom and k or -k,
AlignX = v120.AlignX,
})
end

return visible
end

index2.Notify = function(arg, arg2, arg3)
if arg._destroyed or not arg:_Get("Enabled") then
return
end
arg3 = arg3 or {}
local v120 = arg:_SideSpec()
arg._counter = arg._counter + 1

local tbl20 = {
Parent = arg._container,
Order = arg._list.VerticalAlignment == Enum.VerticalAlignment.Bottom and arg._counter or -arg._counter,
AlignX = v120.AlignX,
}

local lifetime = arg3.Lifetime or 6
local new = nil

local function fn37()
local v121 = table.find(arg._stack, new)

if v121 ~= nil then
table.remove(arg._stack, v121)
end
end

new = v115.new
new = new(tbl20, arg2, arg:_ResolveTheme(arg3), lifetime, fn37)
table.insert(arg._stack, new)

while #arg._stack > v86[160] do
arg._stack[v86[63]]:Destroy()
end
end

index2.Clear = function(arg)
if arg._destroyed then
return
end

for _, v120 in table.clone(arg._stack) do
v120:Dismiss()
end
end

index2.Destroy = function(arg)
if arg._destroyed then
return
end
arg._destroyed = true

for _, v120 in table.clone(arg._stack) do
v120:Destroy()
end

table.clear(arg._stack)
arg._trove:Destroy()

if v119 == arg then
v119 = nil
end
end

return index2
end

tbl17.aB = function()
local ab = tbl17.cache.aB

if not ab then
ab = { c = fn35() }
tbl17.cache.aB = ab
end

return ab.c
end
end
do -- aC
local function fn35()
tbl17.ab()
tbl17.r()
local v115 = tbl17.az()
tbl17.af()
local v116 = tbl17.aB()
tbl17.an()
local v117 = tbl17.u()
tbl17.ar()
local v118 = tbl17.A()
tbl17.k()
local v119 = tbl17.w()

local tbl18 = {
{ Key = v86[139], Label = "Accent" },
{ Key = "Background", Label = "Background" },
{ Key = "ElementBackground", Label = "Element Background" },
{ Key = "Outline", Label = "Outline" },
{ Key = "TabButtonSelected", Label = "Selected Tab" },
{ Key = "TextColor", Label = "Text" },
{ Key = v86[96], Label = v86[136] },
{ Key = "ToggleCircleUnselected", Label = "Toggle Circle" },
{ Key = "ToggleBackgroundUnselected", Label = "Toggle Background" },
}

local function fn36(arg, arg2, arg3)
local v120 = arg3:AddSection({ Title = "Menu", Side = "left" })
local stateData = arg:GetStateData()

if not v117.IsMobile() then
local v121 = v120:AddKeybind({
Label = v86[106],
Modes = { v86[194], v86[3] },
InKeybindList = true,
ListLabel = "Menu",
RegistrationKey = "settings/menu/keybind",
})

v121:SetFeatureEnabled(true)
v121:SetShowInList(stateData == nil or stateData.MenuKeybindInList ~= false, true)
v121:Set({ Key = arg.Keybind, Mode = v121.Value.Mode }, true)

v121:Connect(v121.ShowInListChanged, function(menuKeybindInList)
if stateData ~= nil then
stateData.MenuKeybindInList = menuKeybindInList
arg:SaveState()
end
end)

v121:OnChanged(function(arg4)
local keybind = arg4.Key
if typeof(keybind) ~= "EnumItem" then
return
end
arg.Keybind = keybind

if stateData ~= nil then
local v122 = v119.serializeKey(keybind)

if v122 ~= nil then
stateData.Keybind = v122
end

arg:SaveState()
end
end)
end

if not v117.IsMobile() then
v120:AddToggle({
Label = "Show Keybinds",
Default = arg2.IsKeybindListEnabled(),
OnChanged = arg2.SetKeybindListEnabled,
})
end

v120:AddToggle({ Label = v86[129], Default = arg2.IsWatermarkEnabled(), OnChanged = arg2.SetWatermarkEnabled })

if v117.WantsMobileButtons() then
v120:AddToggle({
Label = "Hide Floating Menu Button",
Default = stateData ~= nil and stateData.HideMobileMenuButton == true,
OnChanged = arg2.SetMenuPillHidden,
})

v120:AddButton({ Label = "Edit On-screen Keybinds", OnClick = arg2.EnterMobileButtonDragMode })
end
end

local function fn37(arg, arg2)
if arg.Ok then
return false
end
local str7 = tostring(arg.Error.Detail)
v116.get():Notify({ { Text = arg2 .. " failed: " }, { Text = str7 } })
return true
end

local function fn38(arg, arg2, arg3)
local persistence = arg:GetPersistence()
local stateData = arg:GetStateData()
local v120 = arg3:AddSection({ Title = "Whole-Menu Profiles", Side = v86[42] })
local v121 = arg3:AddSection({ Title = "Transfer", Side = "right" })
local v122 = arg3:AddSection({ Title = "Automation", Side = "right" })

local function fn39()
if persistence ~= nil then
return persistence:AllConfigs()
end
return {}
end

local v123 = fn39()
local v124 = v120:AddTextBox({ Label = "Config Name" })
local v125 = v120:AddButton({ Label = "Create Config" })
local v126 = v120:AddList({ Label = "Configs", Options = v123, Height = 140, Search = true })

local function fn40()
v126:SetOptions(fn39())
end

v125:Connect(v125.Clicked, function()
local str7 = v124.Value:gsub("%s+", "")
if str7 == "" then
return
end

if fn37(persistence:SaveToFile(str7,true), "Creating config") then
return
end
fn40()
v126:Set(str7)
end)

local v127 = v120:AddButton({ Label = "Refresh List" })

v120:AddButton({
Label = "Load Selected Config",
Confirm = true,
OnClick = function()
local value = v126.Value

if type(value) == "string" then
fn37(persistence:LoadFromFile(value), "Loading config")
end
end,
})

v120:AddButton({
Label = "Save to Selected Config",
Confirm = v86[34],
OnClick = function()
local value = v126.Value

if type(value) == "string" and value ~= "" then
fn37(persistence:SaveToFile(value), "Saving config")
end
end,
})

local v128 = v120:AddButton({ Label = "Delete Selected Config", Confirm = true })

v121:AddButton({
Label = "Export to Clipboard",
OnClick = function()
local v129 = persistence:ExportToJson()

if v129.Ok then
setclipboard(v129.Value)
v116.get():Notify("Copied your current config to the clipboard")
else
fn37(v129, "Exporting config")
end
end,
})

local v129 = v121:AddTextBox({ Label = "Import (paste config)", FocusLostOnly = true })

v121:AddButton({
Label = "Import Config",
Confirm = true,
OnClick = function()
local value = v129.Value

if value ~= "" then
fn37(persistence:LoadFromJson(value), "Importing config")
end
end,
})

local v130 = v122:AddToggle({ Label = "Auto Save" })
local v131 = v122:AddDropdown({ Label = "Profile to Auto Save", Options = v123, GetOptions = fn39, CloseOnSelect = true })
local v132 = v122:AddToggle({ Label = "Auto Load" })
local v133 = v122:AddDropdown({ Label = "Profile to Auto Load", Options = v123, GetOptions = fn39, CloseOnSelect = true })

v128:Connect(v128.Clicked, function()
local value = v126.Value
if type(value) ~= "string" then
return
end

if fn37(persistence:DeleteFile(value), "Deleting config") then
return
end

if stateData ~= nil then
if stateData.AutoSaveConfigName == value then
stateData.AutoSaveConfigName = nil
v131:Set(nil, true)
end

if stateData.AutoLoadConfigName == value then
stateData.AutoLoadConfigName = nil
v133:Set(nil, true)
end

arg:SaveState()
end

fn40()
end)

local function fn41()
if stateData == nil then
return
end
v130:Set(stateData.AutoSave, true)
v131:Set(stateData.AutoSaveConfigName, true)
v132:Set(stateData.AutoLoad, true)
v133:Set(stateData.AutoLoadConfigName, true)
local autoSaveConfigName = stateData.AutoSaveConfigName or stateData.AutoLoadConfigName

if autoSaveConfigName ~= nil then
v126:Set(autoSaveConfigName, true)
end
end

v127:Connect(v127.Clicked, function()
fn40()
fn41()
end)

fn41()

local function fn42()
if stateData == nil then
return
end
stateData.AutoSave = v130.Value
stateData.AutoLoad = v132.Value
local value = v131.Value
if v130.Value and (type(value)~="string" or value=="") then
value=v126.Value
if type(value)=="string" and value~="" then v131:Set(value,true) end
end
stateData.AutoSaveConfigName = type(value) == "string" and value ~= "" and value or nil
local value2 = v133.Value
stateData.AutoLoadConfigName = type(value2) == "string" and value2 ~= "" and value2 or nil
arg:SaveState()
end

v130:OnChanged(fn42)
v131:OnChanged(fn42)
v132:OnChanged(fn42)
v133:OnChanged(fn42)
v126:OnChanged(function()
if stateData and stateData.AutoSave and not stateData.AutoSaveConfigName then fn42() end
end)
local flag19 = v86[153]
local v134 = arg2:Extend()

arg2:Connect(persistence.Reloaded, function()
flag19 = false
v134:Clean()
end)

arg2:Connect(persistence.Changed, function()
if flag19 then
return
end
flag19 = v86[34]
v134:Clean()

v134:Add(task.delay(.75,function()
flag19 = false
if stateData == nil or not stateData.AutoSave then
return
end
local autoSaveConfigName = stateData.AutoSaveConfigName

if autoSaveConfigName ~= nil then
fn37(persistence:SaveToFile(autoSaveConfigName), "Auto-saving config")
end
end))
end)
end

local function fn39(arg, arg2, arg3, arg4, arg5)
local v120 = arg4:AddTab({ Label = "Theme" })
local v121 = v120:Grid({ Columns = 1 })
local v122 = v121:AddSection({ Title = "Theme Colors", Side = "full" })
local config = arg:GetConfig()

local function fn40(arg6, arg7)
if arg6 == "Accent" then
arg2.SetAccent(arg7)
else
v118.refresh(arg6, arg7)
end
end

for _, v123 in tbl18, nil, nil do
local v124 = v118.get(v123.Key)
local v125

if config ~= nil then
local v126 = config:Get(v119.appendPath(arg5, v123.Key))

if typeof(v126) ~= "Color3" then
v125 = v124
else
v125 = v126
end
else
v125 = v124
end

fn40(v123.Key, v125)

local v126 = v122:AddColor({
Label = v123.Label,
Default = { Rgb = v125, Alpha = 1 },
OnChanged = function(arg6)
if config ~= nil then
local rgb = arg6.Rgb
config:Set(v119.appendPath(arg5, v123.Key), rgb)
else
fn40(v123.Key, arg6.Rgb)
end
end,
})

if config ~= nil then
arg3:Connect(config:Changed(v119.appendPath(arg5, v123.Key)), function(arg6)
if typeof(arg6) ~= "Color3" then
return
end
fn40(v123.Key, arg6)
v126:Set({ Rgb = arg6, Alpha = 1 }, true)
end)
end
end

return { Page = v120, Grid = v121 }
end

local function fn40(arg, arg2, arg3)
if arg3 ~= nil then arg:AddToggle({ Label = "Auto Run", Config = arg3, Tooltip = "Run this script automatically after teleporting." }) end
local stateData = arg2:GetStateData()

arg:AddToggle({
Label = v86[142],
Default = stateData ~= nil and stateData.SilentLoad == true,
OnChanged = function(silentLoad)
if stateData ~= nil then
stateData.SilentLoad = silentLoad
arg2:SaveState()
end
end,
})
end

local function fn41(arg, arg2)
arg:AddToggle({ Label = "Enable Notifications", Config = v119.appendPath(arg2, "Enabled") })
arg:AddDropdown({ Label = v86[189], Options = v116.SideSpecs, Config = v119.appendPath(arg2, v86[50]) })

arg:AddSlider({
Label = "Crosshair Offset",
Tooltip = "Distance from screen center for the Crosshair side. Negative is above, positive below.",
Min = -500,
Max = 500,
Default = 0,
Suffix = "px",
Config = v119.appendPath(arg2, "Offset"),
})

arg:AddSlider({ Label = "Text Size", Min = v86[133], Max = 28, Config = v119.appendPath(arg2, "Size") })
arg:AddDropdown({ Label = "Font", Options = v115.Order, Config = v119.appendPath(arg2, v86[59]) })
end

return function(arg, arg2, arg3, arg4, arg5, arg6, arg7)
local v120 = arg2:AddTab({ Label = "General", Icon = "rbxassetid://106205298246017" })
local v121 = v120:Grid({ Columns = 2 })
fn36(arg, arg4, v121)
local v122 = arg2:AddTab({ Label = "Config Profiles" })
local v123 = v122:Grid({ Columns = 2 })
fn38(arg, arg3, v123)
local v124 = fn39(arg, arg4, arg3, arg2, arg5)
fn40(v121:AddSection({ Title = "Startup", Side = "left" }), arg, arg7)
fn41(v121:AddSection({ Title = "Notifications", Side = "right" }), arg6)
v121:AddSection({ Title = v86[199], Side = "right" }):AddButton({ Label = "Unload UI", Confirm = true, OnClick = arg4.Unload })
return { General = { Page = v120, Grid = v121 }, ConfigProfiles = { Page = v122, Grid = v123 }, Theme = v124 }
end
end

tbl17.aC = function()
local ac = tbl17.cache.aC

if not ac then
local ac2 = { c = fn35() }
tbl17.cache.aC = ac2
ac = ac2
end

return ac.c
end
end
do -- aD
local function fn35()
tbl17.r()
local v115 = tbl17.ag()
local v116 = tbl17.ac()
local v117 = tbl17.s()
local v118 = tbl17.ae()
local v119 = tbl17.ah()
local v120 = tbl17.ai()
local v121 = tbl17.aj()
local v122 = tbl17.ak()
local v123 = tbl17.u()
local v124 = tbl17.x()
local v125 = tbl17.al()
local v126 = tbl17.t()
local v127 = tbl17.g()
tbl17.ar()
local v128 = tbl17.A()
local v129 = tbl17.as()
local v130 = tbl17.k()
local v131 = tbl17.at()
local v132 = tbl17.w()
local v133 = tbl17.av()
local v134 = tbl17.ax()
local v135 = tbl17.aC()
local userInputService = v126.UserInputService
local runService = v126.RunService
local index2 = {}
index2.__index = index2
local semiBold = v117.SemiBold

local function fn36(arg)
local chrome = arg._chrome
assert(chrome ~= nil, "menu chrome accessed during construction")
return chrome
end

local function createScreenGui(displayOrder, enabled)
local screenGui = Instance.new("ScreenGui")
screenGui.Enabled = enabled
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = displayOrder
screenGui.OnTopOfCoreBlur = true
return screenGui
end

local function fn37(arg)
local chrome = arg._chrome
if chrome == nil then
return
end
local menuFrame = chrome.Window.MenuFrame
local v136 = v132.onScreenKeyboardTop()

if v136 == nil then
local keyboardBaseY = arg._keyboardBaseY

if keyboardBaseY ~= nil then
arg._keyboardBaseY = nil

if not arg.Dragging then
arg:Tween(menuFrame, { Position = UDim2.fromOffset(menuFrame.Position.X.Offset, keyboardBaseY) })
end
end

return
end

if arg.Dragging then
return
end
local focusedTextBox = userInputService:GetFocusedTextBox()
if focusedTextBox == nil or not focusedTextBox:IsDescendantOf(menuFrame) then
return
end
local n = v132.absoluteToLayerOffset(arg._gui, focusedTextBox.AbsolutePosition).Y + focusedTextBox.AbsoluteSize.Y + 8 - v136
if n <= v86[186] then
return
end
local offset = menuFrame.Position.Y.Offset

if arg._keyboardBaseY == nil then
arg._keyboardBaseY = offset
end

local n33 = math.max(0, math.floor(offset - n + 0.5))

if n33 ~= offset then
arg:Tween(menuFrame, { Position = UDim2.fromOffset(menuFrame.Position.X.Offset, n33) })
end
end

index2.new = function(arg)
local v136 = v130.new()
local directory = arg.Directory
v132.ensureStorageDirectories(directory)
local state = arg.State
local stateData = arg.StateData

if state == nil or stateData == nil then
state = v118.new(directory)
stateData = state:Load()
end

local v137 = createScreenGui(v86[45], v86[34])
local v138 = createScreenGui(v86[91], true)
local v139 = createScreenGui(110, false)
local v140 = v136:Add(v127.new())
local v141 = v122.new(v136, v139, v140)
local Default = semiBold

if arg.ResolveFont ~= nil then
Default = arg.ResolveFont("Default")
end

local obj = setmetatable({
_trove = v136,
Title = arg.Title or "PH",
Icon = K.CloudyIcon or arg.Icon or "rbxassetid://118838006164746",
Directory = directory,
ConfigVersion = arg.ConfigVersion or v86[63],
Fonts = { Main = Default },
Visible = false,
Dragging = false,
Keybind = Enum.KeyCode.RightShift,
AccentChanged = v136:Add(v127.new()),
FontChanged = v136:Add(v127.new()),
VisibilityChanged = v140,
_gui = v138,
_hud = v137,
_overlay = v139,
_tweener = v131.new(),
_overlays = v141,
_cursor = v136:Add(v115.new(v136)),
_chrome = nil,
_dialog = nil,
_config = arg.Config,
_colorAnimation = arg.ColorAnimation,
_persistence = arg.Persistence,
_state = state,
_stateData = stateData,
_themePath = arg.ThemePath or { "Theme" },
_notificationPath = arg.NotificationPath or { "Notifications" },
_autoExecuteEnabledPath = arg.AutoExecuteEnabledPath,
_onUnload = arg.OnUnload,
_watermarkUsername = v126.Players.LocalPlayer and v126.Players.LocalPlayer.Name or "Username",
_updateCallbackById = {},
_nextUpdateId = 0,
_updateCount = 0,
_renderConnection = nil,
_tooltip = nil,
_keybindCapture = nil,
_keybindList = nil,
_mobileButtons = nil,
_menuPill = nil,
_keyboardBaseY = nil,
}, index2)

local v142 = v132.deserializeKey(stateData and stateData.Keybind)

if typeof(v142) == "EnumItem" then
obj.Keybind = v142
end

local v143 = getthreadidentity()
setthreadidentity(8)

for _, v144 in { v137, v138, v139 }, nil, nil do
v136:Add(v144)
v144.Parent = v126.CoreGui
end

setthreadidentity(v143)
local tbl18 = { Title = obj.Title, Icon = obj.Icon, Username = obj._watermarkUsername }

obj._chrome = {
Window = v134.new(obj:View(), v138, v136, tbl18),
Watermark = v133.new(obj:View(), v137, v136, tbl18),
SearchPalette = v125.new(obj:View(), v136),
}

if not v123.IsMobile() then
obj._keybindList = v120.new(obj:View(), v137, v136)
end

if v123.WantsMobileButtons() then
local menuToggle = obj:RegisterMobileButton("menu_toggle", "Menu", "Toggle", function(arg2)
obj:SetVisible(arg2)
end)

obj._menuPill = menuToggle

if menuToggle ~= nil then
if stateData ~= nil and stateData.HideMobileMenuButton then
menuToggle:SetInvisible(v86[34])
end

v136:Connect(v140, function(arg2)
menuToggle:SetActive(arg2)
end)
end
end

v136:Connect(v140, function(enabled)
obj._cursor:Set(enabled)
obj._overlay.Enabled = enabled
end)

v136:Connect(userInputService.InputBegan, function(arg2, arg3)
if arg3 then
return
end

if obj:ShouldBlockKeybindCapture(arg2) then
return
end
local userInputType = arg2.UserInputType

if arg2.UserInputType == Enum.UserInputType.Keyboard then
userInputType = arg2.KeyCode
end

if userInputType == obj.Keybind then
obj:SetVisible(not obj.Visible)
end
end)

if v123.IsMobile() then
local function fn38()
fn37(obj)
end

v132.connectOnScreenKeyboard(v136, fn38)
v136:Connect(userInputService.TextBoxFocused, fn38)
end

return obj
end

index2.View = function(arg)
return arg
end

index2.AddTab = function(arg, arg2)
return fn36(arg).Window:AddTab(arg2)
end

index2.Dialog = function(arg, arg2, arg3)
local dialog = arg._dialog

if dialog ~= nil then
dialog:Close()
end

if not arg.Visible then
arg:SetVisible(true, true)
end

local v136 = nil
local trove = arg._trove

local v137 = v116.new(arg:View(), fn36(arg).Window.MenuFrame, trove, arg2, function()
if arg._dialog == v136 then
arg._dialog = nil
end
end)

v136 = v137
arg._dialog = v137

if arg3 ~= nil then
local v138, v139 = v107(arg3, v137)

if not v138 then
v137:Destroy()
error(v139, 2)
end
end

v137:_Open()
return v137
end

index2.AddSettingsTab = function(arg)
local v136 = arg:AddTab({
Label = "Settings",
Icon = "rbxassetid://106205298246017",
Description = "Menu preferences, config management, and theme customization.",
})

local trove = arg._trove

return v136, (v135(arg:View(), v136, trove, {
SetAccent = function(arg2)
arg:SetAccent(arg2)
end,
SetWatermarkEnabled = function(arg2)
arg:SetWatermarkEnabled(arg2)
end,
IsWatermarkEnabled = function()
return arg:IsWatermarkEnabled()
end,
SetKeybindListEnabled = function(arg2)
arg:SetKeybindListEnabled(arg2)
end,
IsKeybindListEnabled = function()
return arg:IsKeybindListEnabled()
end,
SetMenuPillHidden = function(arg2)
arg:SetMenuPillHidden(arg2)
end,
EnterMobileButtonDragMode = function()
arg:EnterMobileButtonDragMode(function()
arg:SetVisible(v86[34])
end)
end,
Unload = function()
arg:Unload()
end,
}, arg._themePath, arg._notificationPath, arg._autoExecuteEnabledPath))
end

index2.SetTitle = function(arg, title)
arg.Title = title
local v136 = fn36(arg)
v136.Window:SetTitle(title)
v136.Watermark:SetTitle(title)
return arg
end

index2.SetWatermarkUsername = function(arg, watermarkUsername)
arg._watermarkUsername = watermarkUsername
fn36(arg).Watermark:SetUsername(watermarkUsername)
return arg
end

index2.SetWatermarkEnabled = function(arg, arg2)
fn36(arg).Watermark:SetEnabled(arg2)
end

index2.IsWatermarkEnabled = function(arg)
return fn36(arg).Watermark:IsEnabled()
end

index2.SetKeybindListEnabled = function(arg, arg2)
local keybindList = arg._keybindList

if keybindList ~= nil then
keybindList:SetEnabled(arg2)
end
end

index2.IsKeybindListEnabled = function(arg)
local keybindList = arg._keybindList
return keybindList ~= nil and keybindList:IsEnabled()
end

index2.AddKeybindHudEntry = function(arg)
local keybindList = arg._keybindList
if keybindList == nil then
return nil
end
return keybindList:AddEntry()
end

local function fn38(arg)
local mobileButtons = arg._mobileButtons
if mobileButtons ~= nil then
return mobileButtons
end
local hud = arg._hud
local trove = arg._trove
local v136 = v121.new(arg:View(), hud, trove)
arg._mobileButtons = v136
return v136
end

index2.RegisterMobileButton = function(arg, arg2, arg3, arg4, arg5)
if not v123.WantsMobileButtons() then
return nil
end
return fn38(arg):Register(arg2, arg3, arg4, arg5)
end

index2.RegisterSearchSection = function(arg, arg2, arg3, arg4)
fn36(arg).SearchPalette:Register(arg2, arg3, arg4)
end

index2.InvalidateSearch = function(arg)
fn36(arg).SearchPalette:Invalidate()
end

index2.SearchQuery = function(arg, arg2)
return fn36(arg).SearchPalette:Search(arg2)
end

index2.ShowSearchResults = function(arg, arg2)
fn36(arg).SearchPalette:ShowAt(arg2)
end

index2.HideSearchResults = function(arg)
fn36(arg).SearchPalette:Hide()
end

index2.SetActiveSearchBar = function(arg, arg2)
fn36(arg).SearchPalette:SetActiveBar(arg2)
end

index2.EnterMobileButtonDragMode = function(arg, arg2)
local mobileButtons = arg._mobileButtons
if mobileButtons == nil then
return
end
arg:SetVisible(false)
mobileButtons:EnterDragMode(arg2)
end

index2.SetMenuPillHidden = function(arg, hideMobileMenuButton)
local menuPill = arg._menuPill

if menuPill ~= nil then
menuPill:SetInvisible(hideMobileMenuButton)
end

local stateData = arg._stateData

if stateData ~= nil then
stateData.HideMobileMenuButton = hideMobileMenuButton
arg:SaveState()
end
end

index2.SetVisible = function(arg, visible, arg2)
local v136 = v86[116]
assert(type(visible) == v136, "Menu.SetVisible(state) -> expected boolean")
local window = fn36(arg).Window
local flag19 = arg.Visible ~= visible

if arg2 then
window:SetVisible(visible)
arg._tweener:SetLive(v86[34])
arg.Visible = visible
arg:_SyncConfigActive(visible)

if flag19 then
arg.VisibilityChanged:Fire(visible)
end

return
end

arg._tweener:SetLive(true)
if not window:SetVisible(visible) then
return
end
arg.Visible = visible
arg:_SyncConfigActive(visible)
arg.VisibilityChanged:Fire(visible)
end

index2._SyncConfigActive = function(arg, arg2)
local config = arg._config
if config == nil then
return
end
local setActive = config.SetActive

if setActive ~= nil then
setActive(config, arg2)
end
end

index2.SetAccent = function(arg, arg2)
v128.refresh(v86[139], arg2)
arg.AccentChanged:Fire(arg2)
end

index2.GetConfig = function(arg)
return arg._config
end

index2.GetColorAnimation = function(arg)
return arg._colorAnimation
end

index2.GetPersistence = function(arg)
return arg._persistence
end

index2.GetStateData = function(arg)
return arg._stateData
end

index2.SaveState = function(arg)
local state = arg._state
local stateData = arg._stateData

if state ~= nil and stateData ~= nil then
state:Save(stateData)
end
end

index2.GetOverlayLayer = function(arg)
return arg._overlay
end

local function fn39(arg)
local keybindCapture = arg._keybindCapture
if keybindCapture ~= nil then
return keybindCapture
end
local v136 = v119.new(arg._trove)
arg._keybindCapture = v136
if not (n26 > 4823) then
return v136
end
return nil

-- (anti-tamper freeze trap removed)
end

index2.CaptureKey = function(arg, arg2)
return fn39(arg):Begin(arg2)
end

index2.ShouldBlockKeybindCapture = function(arg, arg2)
local keybindCapture = arg._keybindCapture
return keybindCapture ~= nil and keybindCapture:ShouldBlockMenuToggle(arg2)
end

local function fn40(arg)
local tooltip = arg._tooltip
if tooltip ~= nil then
return tooltip
end
local v136 = v129.new(arg._trove, arg._overlay, arg.VisibilityChanged)
arg._tooltip = v136

arg._overlays:SetBeforeOpen(function()
v136:Hide(nil)
end)

return v136
end

index2.AttachTooltip = function(arg, arg2, arg3, arg4)
local v136 = fn40(arg)

arg2:Connect(arg3.MouseEnter, function()
local v137 = arg4()

if v137 ~= nil and v137 ~= "" then
v136:Show(arg3, v137)
end
end)

arg2:Connect(arg3.MouseLeave, function()
v136:Hide(arg3)
end)

if v123.HasTouch() then
local v137 = arg2:Extend()

arg2:Connect(arg3.InputBegan, function(arg5)
if arg5.UserInputType ~= Enum.UserInputType.Touch then
return
end
local position = arg5.Position
v137:Clean()

v137:Add(task.delay(0.45, function()
if not arg.Visible or arg5.UserInputState == Enum.UserInputState.End or arg5.UserInputState == Enum.UserInputState.Cancel then
return
end
local n = arg5.Position.X - position.X
local n33 = arg5.Position.Y - position.Y
if n * n + n33 * n33 > 100 then
return
end
local v138 = arg4()

if v138 ~= nil and v138 ~= "" then
v136:ShowAt(arg3, v138, Vector2.new(arg5.Position.X, arg5.Position.Y))
v124.suppressActivation(arg5)
end
end))
end)
end
end

index2.OnPreRender = function(arg, arg2)
local nextUpdateId = arg._nextUpdateId
arg._nextUpdateId = arg._nextUpdateId + 1
arg._updateCallbackById[nextUpdateId] = arg2
arg._updateCount = arg._updateCount + 1

if arg._renderConnection == nil then
arg._renderConnection = runService.RenderStepped:Connect(function(deltaTime)
if not arg.Visible then
return
end

for _, v136 in arg._updateCallbackById, nil, nil do
v136(deltaTime)
end
end)
end

return function()
if arg._updateCallbackById[nextUpdateId] == nil then
return
end
arg._updateCallbackById[nextUpdateId] = nil
arg._updateCount = arg._updateCount - 1

if arg._updateCount <= v86[186] and arg._renderConnection ~= nil then
arg._renderConnection:Disconnect()
arg._renderConnection = nil
end
end
end

index2.Tween = function(arg, arg2, arg3, arg4)
return arg._tweener:Play(arg2, arg3, arg4)
end

index2.DragTweenInfo = function(arg)
return arg._tweener:DragInfo()
end

local tbl18 = {}
setmetatable(tbl18, { __mode = "k" })

local function fn41(arg, arg2, arg3)
local transparency = tbl18[arg2]

if transparency == nil then
transparency = arg2.Transparency
tbl18[arg2] = transparency
end

local v136 = arg._tweener:Play(arg2, { Transparency = arg3 and transparency or 1 })
if v136 == nil then
arg2.Transparency = transparency
return nil
end
arg2.Transparency = arg3 and 1 or transparency

v136.Completed:Once(function()
if arg2.Parent == nil then
return
end

if not arg3 then
arg2.Transparency = transparency
end
end)

return v136
end

index2.FadeCanvasGroup = function(arg, arg2, visible, arg3)
local tbl19 = arg3 or { Tweening = false }
tbl19._fadeToken = (tbl19._fadeToken or v86[186]) + 1
local fadeToken = tbl19._fadeToken

for _, v136 in arg2:GetChildren() do
if v136:IsA("UIStroke") then
fn41(arg, v136, visible)
end
end

if visible then
arg2.Visible = v86[34]
end

local groupTransparency = v86[63]

if visible then
groupTransparency = 0
end

local v136 = arg._tweener:Play(arg2, { GroupTransparency = groupTransparency })

if v136 == nil then
arg2.GroupTransparency = groupTransparency
arg2.Visible = visible
tbl19.Tweening = v86[153]
return
end

tbl19.Tweening = true

v136.Completed:Once(function()
if tbl19._fadeToken ~= fadeToken then
return
end
tbl19.Tweening = v86[153]
arg2.Visible = visible
end)
end

index2.RegisterOverlay = function(arg, arg2, arg3)
return arg._overlays:Register(arg2, arg3)
end

index2.UnregisterOverlay = function(arg, arg2)
arg._overlays:Unregister(arg2)
end

index2.ToggleOverlay = function(arg, arg2)
arg._overlays:Toggle(arg2)
end

index2.SetOverlayOpen = function(arg, arg2, arg3)
arg._overlays:SetOpen(arg2, arg3)
end

index2.CloseOverlays = function(arg, arg2, arg3)
arg._overlays:CloseAll(arg2, arg3)
end

index2.CloseOverlayDescendants = function(arg, arg2)
arg._overlays:CloseDescendants(arg2)
end

index2.MakeDraggable = function(arg, parent, arg2, arg3)
local persistKey = arg3 and arg3.PersistKey

local function fn42()
local stateData = arg._stateData
if stateData == nil or persistKey == nil then
return
end
local position = parent.Position
local watermarkPosition = { position.X.Offset, position.Y.Offset }

if persistKey == "WatermarkPosition" then
stateData.WatermarkPosition = watermarkPosition
else
stateData.KeybindsListPosition = watermarkPosition
end

arg:SaveState()
end

if persistKey ~= nil then
local stateData = arg._stateData

if stateData ~= nil then
local keybindsListPosition = stateData.KeybindsListPosition

if persistKey == "WatermarkPosition" then
if true then
keybindsListPosition = stateData.WatermarkPosition
else
-- (anti-tamper freeze trap removed)
end
end

if keybindsListPosition ~= nil and #keybindsListPosition >= 2 then
parent.Position = UDim2.fromOffset(math.round(keybindsListPosition[v86[63]]), math.round(keybindsListPosition[2]))
end
end

local function fn43()
if parent.Parent ~= nil and v132.clampGuiToViewport(parent) then
fn42()
end
end

arg2:Add(task.defer(fn43))
arg2:Add(task.defer(fn43))
end

local uiDragDetector = Instance.new("UIDragDetector")
uiDragDetector.DragStyle = Enum.UIDragDetectorDragStyle.TranslatePlane
uiDragDetector.ResponseStyle = Enum.UIDragDetectorResponseStyle.CustomOffset
uiDragDetector.Enabled = arg.Visible
uiDragDetector.Parent = parent

arg2:Connect(arg.VisibilityChanged, function(enabled)
uiDragDetector.Enabled = enabled
end)

local position = nil

arg2:Connect(uiDragDetector.DragStart, function()
position = parent.Position
arg.Dragging = v86[34]
local chrome = arg._chrome

if chrome ~= nil and parent == chrome.Window.MenuFrame then
arg._keyboardBaseY = nil
end

arg._overlays:CloseAll(nil, true)
end)

arg2:Connect(uiDragDetector.DragContinue, function()
local v136 = position
if v136 == nil then
return
end
local dragUDim2 = uiDragDetector.DragUDim2
parent.Position = v132.snapPosition(UDim2.new(v136.X.Scale, v136.X.Offset + dragUDim2.X.Offset, v136.Y.Scale, v136.Y.Offset + dragUDim2.Y.Offset))
v132.clampGuiToViewport(parent)
end)

arg2:Connect(uiDragDetector.DragEnd, function()
position = nil
arg.Dragging = false
v132.clampGuiToViewport(parent)
fn42()
local onDragEnd = arg3 and arg3.OnDragEnd

if onDragEnd ~= nil then
onDragEnd(parent.Position)
end
end)

local v136 = arg2:Extend()

v132.connectCurrentCameraViewport(arg2, function(arg4)
v136:Clean()
if arg4 == nil or parent.Parent == nil then
return
end

v136:Add(task.defer(function()
if parent.Parent ~= nil then
v132.clampGuiToViewport(parent)
end
end))
end)

return uiDragDetector
end

index2.Unload = function(arg)
local onUnload = arg._onUnload

if onUnload ~= nil then
onUnload()
end
end

index2.Destroy = function(arg)
arg:SaveState()
arg._cursor:Set(false)

if arg._renderConnection ~= nil then
arg._renderConnection:Disconnect()
arg._renderConnection = nil
end

arg._trove:Destroy()
end

return index2
end

tbl17.aD = function()
local ad = tbl17.cache.aD

if not ad then
local ad2 = { c = fn35() }
tbl17.cache.aD = ad2
ad = ad2
end

return ad.c
end
end
do -- aE
local function fn35()
tbl17.C()
local v115 = tbl17.N()
tbl17.M()
tbl17.ab()
tbl17.r()
tbl17.ac()
tbl17.Q()
tbl17.H()
local v116 = tbl17.ae()
tbl17.af()
tbl17.R()
tbl17.T()
tbl17.U()
tbl17.V()
local v117 = tbl17.aD()
tbl17.X()
local v118 = tbl17.aB()
tbl17.Y()
tbl17.an()
local v119 = tbl17.u()
tbl17.J()
tbl17.B()
tbl17.Z()
tbl17.K()
tbl17.ar()
tbl17._()
tbl17.S()
tbl17.aa()

return {
Menu = v117,
Notifications = v118,
GeneralState = v116,
ColorBinding = v115,
ForceMobileLayout = v119.ForceMobileLayout,
}
end

tbl17.aE = function()
local ae = tbl17.cache.aE

if not ae then
ae = { c = fn35() }
tbl17.cache.aE = ae
end

return ae.c
end
end
do -- bc
local function fn35()
local v115 = tbl17.m()
local tbl18 = { "KeyCode", "UserInputType" }
local tbl19 = {}

local function fn36(arg, arg2)
return Enum[arg][arg2]
end

local function fn37(arg)
for _, v116 in tbl18, nil, nil do
local v117, v118 = v107(fn36, v116, arg)
if v117 and v118 ~= nil then
return { __type = "EnumItem", EnumType = v116, Name = v118.Name }
end
end

return nil
end

local fn38 = nil

fn38 = function(arg, arg2)
for k, v116 in arg, nil, nil do
local flag19 = k == "Bind"

if flag19 then
local v117 = v86[165]
flag19 = type(v116) == v117
end

if flag19 then
local v117 = fn37(v116)
arg[k] = v117

if v117 == nil then
table.insert(tbl19, arg2 .. "Bind")
end
elseif type(v116) == "table" then
local v117 = v86[165]

if type(v116.__type) == v117 then
if not v107(v115.parse, { v116 }) then
arg[k] = nil
table.insert(tbl19, arg2 .. tostring(k))
end
else
fn38(v116, arg2 .. tostring(k) .. ".")
end
end
end
end

return {
deserialize = function(arg)
fn38(arg, "")
return v115.parse(arg)
end,
takeDroppedPaths = function()
tbl19 = {}
return tbl19
end,
}
end

tbl17.bc = function()
local bc = tbl17.cache.bc

if not bc then
local bc2 = { c = fn35() }
tbl17.cache.bc = bc2
bc = bc2
end

return bc.c
end
end
do -- dN
local function fn35()
return {
opposite = function(arg)
local v115, v116, v117 = arg:ToHSV()
return Color3.fromHSV((v115 + v86[101]) % 1, v116, v117)
end,
rainbow = function(arg)
return Color3.fromHSV(arg * 0.2 % 1, 1, 1)
end,
linear = function(arg, arg2, arg3)
local n = arg3 * 0.25 % v86[63]
if n > 0.5 then
return arg2:Lerp(arg, (n - 0.5) * 2)
end
return arg:Lerp(arg2, n * v86[56])
end,
oscillating = function(arg, arg2, arg3)
local n = arg3 * 0.25 % 1
if n > v86[101] then
return arg2:Lerp(arg, math.sin((n - 0.5) * 3.1415926535897931))
end
return arg:Lerp(arg2, math.sin(n * 3.1415926535897931))
end,
strobe = function(arg, arg2, arg3)
if arg3 * 0.25 % v86[63] > 0.5 then
return arg2
end
return arg
end,
sawtooth = function(arg, arg2, arg3)
return arg:Lerp(arg2, arg3 * 0.25 % 1)
end,
breathing = function(arg, arg2, arg3)
local v115 = v86[101]
return arg + (arg2 - arg) * (math.sin(arg3 * 0.5 * 3.1415926535897931 * 2) + 1) * v115
end,
}
end

tbl17.dN = function()
local dn = tbl17.cache.dN

if not dn then
local dn2 = { c = fn35() }
tbl17.cache.dN = dn2
dn = dn2
end

return dn.c
end
end
do -- dO
local function fn35()
local v115 = tbl17.dN()
local v116 = tbl17.k()

local function fn36(arg, arg2)
if arg == arg2 then
return v86[34]
end

if arg == nil or arg2 == nil or #arg ~= #arg2 then
return false
end

for i = 1, #arg do
if arg[i] ~= arg2[i] then
return false
end
end

return true
end

local function fn37(arg, arg2)
arg.RevertColor(arg2.ColorPath)

if arg2.TransparencyPath ~= nil then
arg.RevertTransparency(arg2.TransparencyPath)
end
end

local tbl18 = { None = v86[75], Rainbow = "Rainbow", Breathing = "Breathing" }
local index2 = {}
index2.__index = index2

index2.ParseMode = function(arg)
return type(arg) == "string" and tbl18[arg] or "None"
end

index2.new = function(arg)
return setmetatable({ _trove = v116.new("ColorAnimator"), _callbacks = arg, _entryByColorPathKey = {} }, index2)
end

index2.SetEntry = function(arg, arg2, transparencyPath, arg3)
local str7 = table.concat(arg2, "/")
local mode = arg3.Mode
local flag19 = mode == "Breathing" and transparencyPath == nil and v86[75] or mode
local v117 = arg._entryByColorPathKey[str7]

if flag19 == "None" then
if v117 ~= nil then
arg._entryByColorPathKey[str7] = nil
fn37(arg._callbacks, v117)
end

return
end

if v117 ~= nil and v117.Mode == flag19 then
v117.Speed = arg3.Speed

if not fn36(v117.TransparencyPath, transparencyPath) then
if v117.TransparencyPath ~= nil then
arg._callbacks.RevertTransparency(v117.TransparencyPath)
end

v117.TransparencyPath = transparencyPath
end

v117.BreathingMin = arg3.BreathingMin or v117.BreathingMin
v117.BreathingMax = arg3.BreathingMax or v117.BreathingMax
return
end

if v117 ~= nil then
fn37(arg._callbacks, v117)
else
arg._callbacks.RevertColor(arg2)

if transparencyPath ~= nil then
arg._callbacks.RevertTransparency(transparencyPath)
end
end

arg._entryByColorPathKey[str7] = {
ColorPath = arg2,
TransparencyPath = transparencyPath,
Mode = flag19,
Speed = arg3.Speed,
BreathingMin = arg3.BreathingMin or 0,
BreathingMax = arg3.BreathingMax or 1,
}
end

index2.Update = function(arg)
if next(arg._entryByColorPathKey) == nil then
return
end
local now2 = os.clock()

for _, v117 in arg._entryByColorPathKey, nil, nil do
local n = now2 * v117.Speed

if v117.Mode == "Rainbow" then
arg._callbacks.WriteColor(v117.ColorPath, v115.rainbow(n))
elseif v117.Mode == "Breathing" and v117.TransparencyPath ~= nil then
arg._callbacks.WriteTransparency(v117.TransparencyPath, v115.breathing(v117.BreathingMin, v117.BreathingMax, n))
end
end
end

index2.Destroy = function(arg)
arg._trove:Destroy()
end

return index2
end

tbl17.dO = function()
local do_ = tbl17.cache.dO

if not do_ then
local do_2 = { c = fn35() }
tbl17.cache.dO = do_2
do_ = do_2
end

return do_.c
end
end
do -- fo
local function fn35() tbl17 .h(); tbl17 .l();local I= tbl17 .g(); tbl17 .bN();local W= tbl17 .k(); tbl17 .r();local l={};l.__index=l;l.new=function(N,P,a)local e=W.new();local W=e:Add(I.new());local c=setmetatable({_trove=e,_reactiveStore=P,_active=true,_signalByKey={},_pathByKey={},_changedConnectionByKey={},_persistentKeySet={},Pins={Icon=a,CanPin=function(P)return N:CanPin(P);end,IsPinned=function(P)return N:IsPinned(P);end,Toggle=function(P)if N:IsPinned(P)then N:Unpin(P);return;end;N:Pin(P);end,Changed=W,GetContextLabel=function()return N:GetContext();end}},l);e:Connect(N.PinsChanged,function()W:Fire();end);e:Connect(N.ContextChanged,function()W:Fire();end);return c;end;l.Get=function(W,N)return W._reactiveStore:Get(N,true);end;l.GetBase=function(W,N)return W._reactiveStore:GetBase(N);end;l.Set=function(W,N,P)W._reactiveStore:Set(N,P);end;l.Changed=function(W,N,P)local a=table.concat(N,".");if P and W._persistentKeySet[a]==nil then W._persistentKeySet[a]=true;local e=W._changedConnectionByKey[a];if e~=nil and not W._active then e:Enable();end;end;P=W._signalByKey[a];if P then return P;end;local P_92,e=W._trove:Add(I.new()),table.clone(N);W._signalByKey[a]=P_92;W._pathByKey[a]=e;N=W._reactiveStore:GetPropertyChangedSignal(e):Connect(function()P_92:Fire(W:Get(e));end);W._changedConnectionByKey[a]=W._trove:Add(N);return P_92;end;l.SetActive=function(I,W)if W==I._active then return;end;I._active=W;for N,P in I._changedConnectionByKey,nil,nil do if I._persistentKeySet[N]then continue;end;if W then P:Enable();else P:Disable();end;end;if W then for W,N in I._signalByKey,nil,nil do if not I._persistentKeySet[W]then N:Fire(I:Get(I._pathByKey[W]));end;end;end;end;l.Destroy=function(I)I._trove:Destroy();end;return l;end

tbl17.fo = function()
local fo = tbl17.cache.fo

if not fo then
fo = { c = fn35() }
tbl17.cache.fo = fo
end

return fo.c
end
end
do -- j0
local function fn35()
local v115 = tbl17.dO()
local v116 = tbl17.bG()
tbl17.aE()
local index2 = {}
index2.__index = index2
local tbl18 = { "ColorAnimations", "Entries" }

local function fn36(arg, arg2)
local str7 = table.concat(arg, "/")
if arg2 == nil then
return { "ColorAnimations", "Entries", str7 }
end
return { "ColorAnimations", "Entries", str7, arg2 }
end

index2.new = function(arg)
return setmetatable({ _animator = arg }, index2)
end

index2.Get = function(arg, arg2)
local tbl19 = v116:Get(fn36(arg2))
local v117 = v86[68]
tbl19 = type(tbl19) == v117 and tbl19 or {}
local breathingMin = tbl19.BreathingMin
local breathingMax = tbl19.BreathingMax
local tbl20 = { Mode = v115.ParseMode(tbl19.Mode), Speed = type(tbl19.Speed) == "number" and tbl19.Speed or 1 }
local v118 = v86[95]
tbl20.BreathingMin = type(breathingMin) == v118 and breathingMin or nil
tbl20.BreathingMax = type(breathingMax) == "number" and breathingMax or nil
return tbl20
end

index2.SetMode = function(arg, arg2, arg3)
v116:Set(fn36(arg2, "Mode"), arg3)
end

index2.SetSpeed = function(arg, arg2, arg3)
v116:Set(fn36(arg2, "Speed"), arg3)
end

index2.SetBreathing = function(arg, arg2, arg3, arg4)
v116:Set(fn36(arg2, "BreathingMin"), arg3)
v116:Set(fn36(arg2, "BreathingMax"), arg4)
end

index2.Changed = function()
return v116:GetPropertyChangedSignal(tbl18)
end

index2.Apply = function(arg, arg2, arg3, arg4)
local n = 0

if arg3 ~= nil then
n = v116:GetBase(arg3)
local n33 = 0

if type(n) ~= "number" then
n = n33
end
end

arg._animator:SetEntry(arg2, arg3, {
Mode = arg4.Mode,
Speed = arg4.Speed,
BreathingMin = arg4.BreathingMin or n,
BreathingMax = arg4.BreathingMax or 1,
})
end

return index2
end

tbl17.j0 = function()
local j0 = tbl17.cache.j0

if not j0 then
j0 = { c = fn35() }
tbl17.cache.j0 = j0
end

return j0.c
end
end

local ARTWORK = {
    {Key="CloudyCombatIcon", Path="CloudyUI/assets/cloudy_sidebar_combat_v1.png", Data=[==[iVBORw0KGgoAAAANSUhEUgAAAGAAAABgCAYAAADimHc4AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAQASURBVHhe7d09ixRZFMZxXzDwBRONzEz0A6igBqIsguxGJgaGG2piZqKhoKCCmBrsbrDrRMri7rIbDAZu6jfwNdFEI0HomvO/cqEL2kO93FtVZ7Rvnx9MoF112nmesatvd3XNli3OOeecc8451wI4BdwEHgH/AH8lfP0NPAAuhRD26pkuEXAFmIURROQ5cFTPdj3iT76IiA50CBF5P5vNTuj7cB2AezrIMYB3XkIG4E8d4lheQoZ4INUBTsFLSBSfzejwpuIlJLAsIPISevQVAFwDzgLnFr7in38WkY96+yZeQoeEAk7pfWohhB+8hJESCjin91nkJYw0toDISxhhigIiL2GgvgJisHqfNl7CAH0FABf1Pl28hEzxpWcdzCLgbW5IXkIG4KEORRsSkpeQKIRwVQfSZEhIXkIC4ADwWgfSZEhIXkIC4LRlSF5CAuuQrOcXwTok6/lFsA7Jen4RrEOynl8E65Cs5xfBOiTr+UWwDsl6fhGsQ7KeXwTrkKznF8E6JOv5RbAOyXp+EaxDsp5fBOuQrOcXwTok6/lFsA7Jen4RrEOynl8E65Cs5xfBOiTr+UWwDsl6fhGsQ7KeXwTrkKaeP5vNjgM3gPvA5SI+9zx1SNpU8+OHUETk8+L28XPPIYTDetulM1VIbcbOB27p7Woi8jSEsGNx+6U0NqQ+A+Yfi/t1hV8Djuj7W0oDQjIrQUReAr/pv28C/Kjva2nlhGRdQgogHhcO6vtZajkhfesSgDt6fhFyQvpWJcwv27NLzy5GTkibXUIMP4SwW88sTk5IQ0qoqiqe9f1Sz+qyMuHXrEsQkSd6TpuVC79mUUIIYSvwi96/DfB4JcOvTVnC2traNhFJep4fich/wB49Z+VMUcL6+vp2Efldb99GRJ6FEPbpOStrTAnxYSfzJ/8ZsP/rf4HLLqF+vUZEftW3NwHidQr/9fA7ZJbwYn4QTQJUVVX9pO/TKTkl5BKRN03HEKdYlqCPIa6Fl/Ad8BK+A1VVnRGRVzrAKXgJiUTkDx1em/kK9wLwQd/WxEvoMb+8ftKFxhcXWTkPX15Ci5Q30GtNK9yxJRR53lCqjY2N6zqkNl0r3AEl1GdPlHveUB/gpIhUi998m5SXlHNK6Dt7opjzhroAt/U33iTnPdycEvoUc95Qm5Q3VYa8kzVVCUWdN9Sk75p2Q8KvjS2hyPOGtK5r2o0JvzamhGLPG9Lib2cC/o8vI8dvXEQ+AXdDCDv1tkMMWWHnHHOKEELYHp8RAeeBQ/r2sXJW2FP8z3ML5r+kImmFnfJU12XIWWf42RMGUtcZcYXtZ08YSFxn+MOOlZR1xko929ls1usMl8B6neESWK8znHPOOeec20RfAKIlF/NUc/nnAAAAAElFTkSuQmCC]==]},
    {Key="CloudyVisualsIcon", Path="CloudyUI/assets/cloudy_sidebar_visuals_v1.png", Data=[==[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]==]},
    {Key="CloudyWorldIcon", Path="CloudyUI/assets/cloudy_sidebar_world_v1.png", Data=[==[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]==]},
    {Key="CloudyCosmeticsIcon", Path="CloudyUI/assets/cloudy_sidebar_cosmetics_v1.png", Data=[==[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]==]},
    {Key="CloudyIcon", Path="CloudyUI/assets/cloudy_cl_theme.png", Data=[==[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]==]},
    {Key="CloudyBackground", Path="CloudyUI/assets/cloudy_wordmark_theme.png", Data=[==[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]==]},
}

--==========================================================================
--  PUBLIC API
--==========================================================================
local Library = {}
Library.Version = "1.0.0"
Library.Artwork = {}   -- filled with rbxasset:// paths of the bundled artwork

local RunService = game:GetService("RunService")

local function ensureFolder(path)
    local isf, mk = K.fn("isfolder"), K.fn("makefolder")
    if mk then
        pcall(function() if not isf or not isf(path) then mk(path) end end)
    end
end

--  base64 -> binary string (uses Luau's buffer library)
local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local B64Map = {}
for i = 1, 64 do B64Map[B64:byte(i)] = i - 1 end
local function b64decode(s)
    s = s:gsub("[^A-Za-z0-9%+/=]", "")
    local out = buffer.create(#s * 3 // 4 + 3)
    local n = 0
    for i = 1, #s, 4 do
        local a, b, c, d = s:byte(i, i + 3)
        local vc, vd = B64Map[c], B64Map[d]
        local v = B64Map[a] * 262144 + B64Map[b] * 4096 + (vc or 0) * 64 + (vd or 0)
        buffer.writeu8(out, n, bit32.rshift(v, 16)); n += 1
        if vc then buffer.writeu8(out, n, bit32.band(bit32.rshift(v, 8), 255)); n += 1 end
        if vd then buffer.writeu8(out, n, bit32.band(v, 255)); n += 1 end
    end
    return buffer.readstring(out, 0, n)
end

local artworkLoaded = false
local function loadArtwork()
    if artworkLoaded then return end
    artworkLoaded = true
    local writeAsset, loadAsset = K.fn("writefile"), K.fn("getcustomasset") or K.fn("getsynasset")
    if not (writeAsset and loadAsset) then
        warn("[CloudyUI] Bundled artwork needs writefile and getcustomasset; using plain colours instead.")
        return
    end
    ensureFolder("CloudyUI")
    ensureFolder("CloudyUI/assets")
    ensureFolder("CloudyUI/fonts")
    for _, art in ipairs(ARTWORK) do
        local ok, image = pcall(function()
            writeAsset(art.Path, b64decode(art.Data))
            return loadAsset(art.Path)
        end)
        if ok then
            K[art.Key] = image
            Library.Artwork[art.Key] = image
        else
            warn("[CloudyUI] Unable to load " .. art.Key .. ": " .. tostring(image))
        end
    end
end

local function merge(into, from)
    for k, v in pairs(from) do
        if type(v) == "table" and type(into[k]) == "table" and getmetatable(v) == nil then
            merge(into[k], v)
        else
            into[k] = v
        end
    end
    return into
end

local current

function Library.Destroy()
    local c = current
    current = nil
    if getgenv().CloudyUI == Library then getgenv().CloudyUI = nil end
    if c then
        pcall(function() c.Owner:Destroy() end)
        if c.OnUnload then task.spawn(c.OnUnload) end
    end
end

function Library.Notify(text, options)
    local ok, err = pcall(function() tbl17.aB().get():Notify(text, options) end)
    if not ok then warn("[CloudyUI] Notify failed: " .. tostring(err)) end
end

--[[
    CloudyUI.new({
        Title          = "My Hub",                  -- window title
        Icon           = "rbxassetid://123",        -- optional; default is the bundled logo
        Directory      = "MyHub",                   -- folder for saved state + configs
        DefaultConfig  = { ... },                   -- extra settings paths your controls bind to
        DownloadFonts  = true,                      -- fetch the 3 pixel fonts (GitHub) like the original
        Background     = true,                      -- bundled wordmark background
        SettingsTab    = true,                      -- add General / Config Profiles / Theme tabs
        AutoRunPath    = nil,                       -- config path ({"A","B"}) for an "Auto Run" toggle
        OnUnload       = function() end,
    })
]]
function Library.new(options)
    options = options or {}
    if getgenv().CloudyUI and getgenv().CloudyUI ~= Library and getgenv().CloudyUI.Destroy then
        pcall(getgenv().CloudyUI.Destroy)
    end
    if current then Library.Destroy() end
    getgenv().CloudyUI = Library

    local title = options.Title or "CloudyUI"
    local directory = options.Directory or "CloudyUI"
    K.DownloadFonts = options.DownloadFonts ~= false

    tbl17.w().ensureStorageDirectories(directory)
    loadArtwork()
    if options.Icon ~= nil then K.CloudyIcon = nil end
    if options.Background == false then K.CloudyBackground = nil end

    local owner = tbl17.k().new()
    current = { Owner = owner, OnUnload = options.OnUnload }

    tbl17.b().use({ Report = function(_, e)
        local detail = type(e) == "table" and (e.Detail or e.Operation) or e
        warn("[CloudyUI] " .. tostring(detail))
    end })

    --  settings store (same defaults as the original: light theme, red accent)
    local defaults = {
        ColorAnimations = { Entries = tbl17.i().atomic({}) },
        Notifications = { Enabled = true, Side = "TopLeft", Size = 15, Font = "Inconsolata", Offset = 0 },
        Theme = {
            Accent = Color3.fromRGB(197, 59, 59),
            Outline = Color3.fromRGB(210, 210, 210),
            Background = Color3.fromRGB(255, 255, 255),
            ElementBackground = Color3.fromRGB(245, 245, 245),
            TabButtonSelected = Color3.fromRGB(230, 230, 230),
            Unselected = Color3.fromRGB(215, 215, 215),
            TextColor = Color3.fromRGB(35, 35, 35),
            ToggleCircleUnselected = Color3.fromRGB(165, 165, 165),
            ToggleBackgroundUnselected = Color3.fromRGB(225, 225, 225),
        },
    }
    if options.DefaultConfig then merge(defaults, options.DefaultConfig) end

    local store = owner:Add(tbl17.l().new({
        DefaultConfig = defaults,
        CurrentVersion = 1,
        LegacyVersion = 1,
        SavePath = directory .. "/configs/",
        Migrations = {},
        Serialize = tbl17.m().normalize,
        Deserialize = tbl17.bc().deserialize,
    }))
    Library.Store = store
    tbl17.cache.bG = { c = store }   -- ColorAnimation looks the store up through bG

    --  config adapter (the original also supports per-profile pins; not needed here)
    local Signal = tbl17.g()
    local profiles = {
        PinsChanged = Signal.new(), ContextChanged = Signal.new(),
        CanPin = function() return false end, IsPinned = function() return false end,
        Pin = function() end, Unpin = function() end, GetContext = function() return nil end,
    }
    local adapter = owner:Add(tbl17.fo().new(profiles, store, options.PinIcon))

    local fonts = tbl17.az()
    owner:Add(tbl17.aB().use(store, { "Notifications" }, { "Theme" }, function(f) return fonts:Get(f) end, 10))

    --  menu state (+ optional auto-load of the chosen config)
    local reporter = owner:Add(tbl17.ad().new())
    local state = owner:Add(tbl17.ae().new(directory .. "/"))
    local stateData = state:Load()
    if stateData.AutoLoad and stateData.AutoLoadConfigName ~= nil then
        local r = reporter:ReportResult(store:LoadFromFile(stateData.AutoLoadConfigName))
        if not r.Ok then
            local text = "Failed to auto-load the selected config"
            if string.find(r.Error.Detail, "newer than current version", 1, true) ~= nil then
                text = "Your selected config was saved by a newer version - update or pick another config"
            end
            Library.Notify(text)
        elseif #tbl17.bc().takeDroppedPaths() > 0 then
            Library.Notify("Some saved settings could not be restored and were reset to defaults")
        end
    end

    local Theme = tbl17.A()
    local theme = store.Data.Theme
    if theme ~= nil then
        for k, v in next, theme do
            if Theme.Tokens[k] ~= nil and typeof(v) == "Color3" then Theme.refresh(k, v) end
        end
    end

    --  colour animation (rainbow / breathing) for colour pickers
    local animator = owner:Add(tbl17.dO().new({
        WriteColor = function(path, v) store:SetLiveOverride(path, v) end,
        WriteTransparency = function(path, v) store:SetLiveOverride(path, v) end,
        RevertColor = function(path) store:ClearLiveOverride(path) end,
        RevertTransparency = function(path) store:ClearLiveOverride(path) end,
    }))
    owner:Add(RunService.RenderStepped:Connect(function() animator:Update() end))

    local menu
    menu = tbl17.aE().Menu.new({
        Icon = options.Icon,
        Title = title,
        Directory = directory,
        Config = adapter,
        ColorAnimation = tbl17.j0().new(animator),
        Persistence = store,
        State = state,
        StateData = stateData,
        AutoExecuteEnabledPath = options.AutoRunPath,
        OnUnload = function() Library.Destroy() end,
    })
    owner:Add(menu)

    menu.Store = store
    menu.Notify = function(_, text, opts) Library.Notify(text, opts) end
    --  Call once, after you have added all of your own tabs.
    menu.Finish = function(self)
        if options.SettingsTab ~= false then self:AddSettingsTab() end
        self:SetVisible(not (stateData.SilentLoad == true), true)
        return self
    end

    current.Menu = menu
    return menu
end

Library.Theme = function() return tbl17.A() end

return Library
