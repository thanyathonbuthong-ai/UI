--[[
    AmberCore / V9
    Client script
    Presentation-only revision: internal names and section headings.
]]


-- ------------------------------------------------------------------
-- AmberCore | 01 / Startup checks
-- ------------------------------------------------------------------
-- ===== TOP-LEVEL SAFETY NET: any uncaught error is reported with REAL traceback =====
local __mainOk, __mainErr = xpcall(function()

if getthreadidentity() < 8 then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = identifyexecutor();
        Text = "Sorry, But your executor (level " .. getthreadidentity() .. ") cannot run this, it's too weak!";
        Duration = 15;
        Button1 = "I will upgrade my executor";
    })
end

-- ===== SAFE LOADER (sequential + retry, avoids HTTP 429) + executor function fallbacks =====
local function __safeHttpGet(url, tries)
    tries = tries or 5
    task.wait(0.15)
    local lastErr = nil
    for i = 1, tries do
        local ok, res = pcall(function() return game:HttpGet(url, true) end)
        if ok and res and type(res) == "string" and #res > 100 then
            return res
        end
        lastErr = tostring(res)
        task.wait(0.4 + 0.5 * i)
    end
    return nil, lastErr
end
local function __safeLoadString(url)
    local src, err = __safeHttpGet(url)
    if not src then return nil, err end
    local ok, fn = pcall(loadstring, src)
    if not ok or type(fn) ~= "function" then return nil, "compile failed" end
    local ok2, lib = pcall(fn)
    if ok2 then return lib end
    return nil, tostring(lib)
end
local __noopNotify = { Notify = function(_, p) pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", { Title = (p and p.Title) or "AmberCore", Text = (p and p.Content) or "", Duration = (p and p.Duration) or 5 }) end) end }
-- executor function fallbacks (mobile executors may lack some of these)
if type(setthreadidentity) ~= "function" then setthreadidentity = function() end end
if type(getthreadidentity) ~= "function" then getthreadidentity = function() return 8 end end
if type(identifyexecutor) ~= "function" then identifyexecutor = function() return "Unknown" end end
if type(gethui) ~= "function" then gethui = function() return game:GetService("CoreGui") end end
if type(makefolder) ~= "function" then makefolder = function() end end
if type(delfile) ~= "function" then delfile = function() end end
if type(isfolder) ~= "function" then isfolder = function() return false end end
if type(isfile) ~= "function" then isfile = function() return false end end
if type(writefile) ~= "function" then writefile = function() end end
if type(readfile) ~= "function" then readfile = function() return "" end end
if type(getcustomasset) ~= "function" then getcustomasset = function() return "" end end
if type(newcclosure) ~= "function" then newcclosure = function(f) return f end end
if type(hookfunction) ~= "function" and type(hookfunc) == "function" then hookfunction = hookfunc end
if type(hookmetamethod) ~= "function" then hookmetamethod = function() end end
if type(getnamecallmethod) ~= "function" then getnamecallmethod = function() return "" end end
if type(getrenv) ~= "function" then getrenv = function() return getfenv(0) end end
-- =========================================================================================
local startupNotifier = __safeLoadString("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua") or __noopNotify
local maintenance = false
if maintenance then
    return startupNotifier:Notify({
        Title = "AmberCore",
        Content = "AmberCore v9 สคริปต์ฟอร์เซเคนที่คุณเพิ่งรัน ขณะนี้ไม่ทำงานเนื่องจากเกมฟอร์เซเคนเปลี่ยนแปลงระบบภายใน หรือเกิดข้อผิดพลาดร้ายแรงในโค้ด AmberCore โปรดรอสักครู่ (ไม่เกิน 20 นาที) เพื่อให้แก้ไข",
        Duration = 40
    })
end

function deepcopy(original)
    if type(original) ~= "table" then return original end
    local copy = {}
    for k, v in pairs(original) do
        copy[deepcopy(k)] = deepcopy(v)
    end
    return setmetatable(copy, getmetatable(original))
end

if isfile('AmberCoreconfigs.json') and not isfile("AmberCoreconfigfix.txt") then
    local raw = deepcopy(game:GetService("HttpService"):JSONDecode(readfile('AmberCoreconfigs.json')))
    for _, cfg in pairs(raw) do
        if cfg ~= "[]" then
            for _, entry in pairs(cfg) do
                if entry.CurrentOption then
                    local newList = {}
                    for optionName, enabled in pairs(entry.CurrentOption) do
                        if enabled == true then
                            table.insert(newList, optionName)
                        end
                    end
                    entry.CurrentOption = newList
                end
            end
        end
    end
    writefile("AmberCoreconfigs.json", game:GetService("HttpService"):JSONEncode(raw))
end
writefile("AmberCoreconfigfix.txt", "")

if isfile('AmberCoreconfigs.json') and not isfile("AmberCoreconfigfix2.txt") then
    writefile("AmberCoreconfigs.json", readfile('AmberCoreconfigs.json')
        :gsub('"currentcfgname":{"CurrentOption"', '"currentcfgname":{"CurrentValue"')
        :gsub('"currentcfgname":{"CurrentValue":%[""%]', '"currentcfgname":{"CurrentValue":""')
    )
end
writefile("AmberCoreconfigfix2.txt", "")

_G.LUNAR_BACKGROUND = "https://raw.githubusercontent.com/aibabylaugh/catsaken/main/catsakenbg.jpg"
_G.LUNAR_TITLE = nil
_G.SINGLE_COLUMNS = false

-- ------------------------------------------------------------------
-- AmberCore | 02 / Shared environment
-- ------------------------------------------------------------------
local GlobalEnv = getgenv()
local useLegacyUI = true -- forced: using Oasis UI adapter

if GlobalEnv.executed then
    return pcall(function() GlobalEnv.Fluent:Notify{ Title = "AmberCore", Content = "โหลดไปแล้ว! ต้องการโหลดใหม่? กดปุ่มในหน้าเบ็ดเตล็ด", Duration = 5 } end)
end
GlobalEnv.executed = true

-- ===== SAFE HOOK WRAPPER (fake traceback hook REMOVED — it hid real errors & caused recursion) =====
local hookedFunctions = {}
local __cc = (type(newcclosure) == "function") and newcclosure or function(f) return f end
local __realHF = (type(hookfunction) == "function") and hookfunction or (type(hookfunc) == "function") and hookfunc or nil
if __realHF then
    GlobalEnv.OldHF = GlobalEnv.OldHF or __realHF
    hookfunction = __cc(function(func, newFunc)
        pcall(function() table.insert(hookedFunctions, func) end)
        local ok, r = pcall(GlobalEnv.OldHF, func, newFunc)
        if ok then return r end
        return func
    end)
else
    hookfunction = function(f, ...) return f end  -- no-op fallback (returns original so oldXxx(...) calls still work)
end
if type(restorefunction) == "function" then
    GlobalEnv.OldRF = GlobalEnv.OldRF or restorefunction
    restorefunction = __cc(function(func)
        local idx = table.find(hookedFunctions, func)
        if idx then pcall(table.remove, hookedFunctions, idx) end
        local ok, r = pcall(GlobalEnv.OldRF, func)
        if ok then return r end
    end)
else
    restorefunction = function() end
end
-- =========================================================================================

local isUnloaded = false
local ContentProvider = game:GetService('ContentProvider')
local Lighting = game:GetService('Lighting')
local RunService = game:GetService('RunService')
local HttpService = game:GetService('HttpService')
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Stats = game:GetService('Stats')
local TweenService = game:GetService('TweenService')
local VirtualInputManager = game:GetService('VirtualInputManager')
local UserInputService = game:GetService('UserInputService')

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local SprintingModule = require(ReplicatedStorage.Systems.Character.Game.Sprinting)
local FlowGameModule = require(ReplicatedStorage.Modules.Minigames.FlowGameManager.FlowGame)
local GetMousePos = require(ReplicatedStorage.Systems.Player.Miscellaneous.GetPlayerMousePosition).GetMousePos
local DirectionalSpeed = require(ReplicatedStorage.Systems.Character.QualityOfLife.DirectionalSpeed)
local DusekkarBehavior = require(ReplicatedStorage.Assets.Survivors.Dusekkar.Behavior)
local SmoothShiftLock = require(ReplicatedStorage.Systems.Player.Game.SmoothShiftLock)
local SidebarHandler = require(ReplicatedStorage.Systems.Player.UI.SidebarHandler)
local VeeronicaConfig = require(ReplicatedStorage.Assets.Survivors.Veeronica.Config)
local CharacterReplication = require(ReplicatedStorage.Systems.Player.Game.CharacterReplication)
local TabbedOutScare = ReplicatedStorage.Systems.Player.Miscellaneous.TabbedOutScare
local IconModule = require(ReplicatedStorage.Modules.Utilities.Icon)
local RagdollModule = require(ReplicatedStorage.Modules.Rendering.Ragdolls)
local PlayerControls = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()

local SlownessEffect = require(ReplicatedStorage.Modules.Schematics.StatusEffects.Slowness)
local SubspacedEffect = require(ReplicatedStorage.Modules.Schematics.StatusEffects.SurvivorExclusive.Subspaced)
local BlindnessEffect = require(ReplicatedStorage.Modules.Schematics.StatusEffects.Blindness)
local GlitchedEffect = require(ReplicatedStorage.Modules.Schematics.StatusEffects.KillerExclusive.Glitched)
local SlateskinEffect = require(ReplicatedStorage.Modules.Schematics.StatusEffects.Slateskin)
local NauseaEffect = require(ReplicatedStorage.Modules.Schematics.StatusEffects.Nausea)
local StunnedEffect = require(ReplicatedStorage.Modules.Schematics.StatusEffects.Stunned)

local VeeronicaBehavior = ReplicatedStorage.Assets.Survivors.Veeronica.Behavior
local AzureConstructQTE = require(ReplicatedStorage.Assets.Killers.Azure.Config.cl_WorkaroundModules.cl_ConstructQTE)
local JohnDoeConfig = require(ReplicatedStorage.Assets.Killers.JohnDoe.Config)
local NetworkFolder = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network")
local Network = require(NetworkFolder)

-- ===== ADDED: Additional module requires (from Skidsaken) — SAFE WRAPPED =====
local GuiService = (pcall(function() return game:GetService('GuiService') end) and game:GetService('GuiService')) or nil
local function __safeReq(inst)
    if not inst then return {} end
    local ok, m = pcall(require, inst)
    if ok and m then return m end
    return {}
end
local function __findChild(parent, ...)
    local cur = parent
    for _, name in ipairs({...}) do
        if not cur then return nil end
        cur = cur:FindFirstChild(name)
    end
    return cur
end
local GuestConfig = __safeReq(__findChild(ReplicatedStorage, "Assets", "Survivors", "Guest1337", "Config"))
local ShedletskyConfig = __safeReq(__findChild(ReplicatedStorage, "Assets", "Survivors", "Shedletsky", "Config"))
local NoliConfig = __safeReq(__findChild(ReplicatedStorage, "Assets", "Killers", "Noli", "Config"))
local NosConfig = __safeReq(__findChild(ReplicatedStorage, "Assets", "Killers", "Nosferatu", "Config"))
local SixerConfig = __safeReq(__findChild(ReplicatedStorage, "Assets", "Killers", "Sixer", "Config"))
local c00lkiddConfig = __safeReq(__findChild(ReplicatedStorage, "Assets", "Killers", "c00lkidd", "Config"))
local Util = __safeReq(__findChild(ReplicatedStorage, "Modules", "Utilities", "Util"))
local rt = nil
pcall(function()
    local __rt = PlayerGui:FindFirstChild('RoundTimer')
    if __rt then rt = __rt:FindFirstChild('Main') end
end)
if not rt then rt = Instance.new("Frame") end  -- stub so timer-position edits never crash
-- ==========================================================================

-- ===== ADDED: Forsaken shared state / desync manager =====
local Forsaken = {
    GameState = 0,
    RoundStart = 0,
    HitboxesDuration = 0.31,
    Desyncs = {},
    RegisterDesync = function(self, n)
        if not self:HasDesync(n) then table.insert(self.Desyncs, n) end
    end,
    UnregisterDesync = function(self, n)
        local k = self:HasDesync(n)
        if k then table.remove(self.Desyncs, k) end
    end,
    IsDesynced = function(self) return #self.Desyncs > 0 end,
    HasDesync = function(self, n) return table.find(self.Desyncs, n) end,
    Has007n7Clone = false,
    JaneDoeDoc = nil,
    JaneDoeRing = nil,
    DoeDebris = {},
}

LocalPlayer:WaitForChild("PlayerData"):WaitForChild("Settings")
local TemporaryUI = LocalPlayer.PlayerGui.TemporaryUI
local PlayerInfoUI = TemporaryUI:FindFirstChild('PlayerInfo')
local CurrentCamera = workspace.CurrentCamera
local WorkspacePlayers = workspace.Players
local SurvivorsFolder = WorkspacePlayers.Survivors
local KillersFolder = WorkspacePlayers.Killers
local SpectatingFolder = WorkspacePlayers.Spectating
local RealDevice = _G.RealDevice or LocalPlayer:GetAttribute('Device')
_G.RealDevice = RealDevice

local Wait = task.wait
local ConstantImageMap = {}
local isVelocityExecutor = identifyexecutor():lower():find('velocity')
local __hui = (type(gethui)=='function' and gethui()) or game:GetService('CoreGui'); local EspScreenGui = Instance.new('ScreenGui', isVelocityExecutor and game:GetService('CoreGui') or __hui)
local baseWarn = warn
JohnDoeConfig.CorruptEnergyWindup = 2

task.wait(0.3); local DrawingLib, __dlErr = __safeLoadString('https://raw.githubusercontent.com/aibabylaugh/catsaken/main/drawing.lua'); if not DrawingLib then DrawingLib = { new = function() local d = {Visible=false,Transparency=1,Color=Color3.new(1,1,1),Thickness=1,Size=Vector2.new(0,0),Position=Vector2.new(0,0),Text='',Font=2,TextSize=13,Outline=false,OutlineColor=Color3.new(0,0,0),Center=false,Filled=false,Destroy=function() end,Remove=function() end,Update=function() end}; return d end } end

local function warn(...)
    return baseWarn('[AmberCore]', ...)
end

if not isfile("banner.png") then
    writefile("banner.png", game:HttpGet("https://raw.githubusercontent.com/aibabylaugh/catsaken/main/catsakenbg.jpg"))
end

task.wait(0.3); local Fluent = __safeLoadString("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua") or __noopNotify

local activeConfigFile = (isfile("AmberCoreautoload.txt") and readfile("AmberCoreautoload.txt")) or ("AmberCore-default-" .. LocalPlayer.Name .. ".json")
local loadedSettings = {}
local isMobile = UserInputService.TouchEnabled == true and UserInputService.KeyboardEnabled == false

function randomstring(len)
    local result = ""
    local chars = ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"):split("")
    for i = 1, len or 16 do
        result = result .. chars[math.random(1, #chars)]
    end
    return result
end

-- ------------------------------------------------------------------
-- AmberCore | 03 / Interface components
-- ------------------------------------------------------------------
-- ============================================================
-- AmberCore UI Adapter :: Oasis UI
-- แปลง API แบบ Rayfield เดิม (CreateTab / CreateSection / CreateToggle ...)
-- ให้เรียกใช้ Oasis UI ได้ โดยโค้ดส่วนอื่นของสคริปต์ไม่ต้องแก้
-- ============================================================
local __OASIS_URL = "https://raw.githubusercontent.com/thanyathonbuthong-ai/UI/refs/heads/main/UI%20KIM"
local Oasis, __oasisErr = __safeLoadString(__OASIS_URL)
if not Oasis or type(Oasis.CreateWindow) ~= "function" then
    error("[AmberCore] โหลด Oasis UI ไม่สำเร็จ: " .. tostring(__oasisErr))
end

local __Flags = {}      -- Window.Flags (proxy ที่ encode เป็น JSON ได้)
local __els = {}        -- flag -> { el, kind }
local __win = nil

-- ---------- ไอคอน: ชื่อที่ไม่มีใน lucide subset ของ Oasis ให้ใช้ชื่อใกล้เคียงแทน ----------
local __ICON_MAP = {
    ["battery-charging"] = "battery",
    ["scan-eye"] = "eye",
    ["footprints"] = "activity",
    ["leaf"] = "sparkles",
    ["dices"] = "shuffle",
}
local function __icon(name)
    if type(name) ~= "string" or name == "" then return nil end
    name = (name:gsub("^lucide/", ""))
    return __ICON_MAP[name] or name
end

local function __c255(v) return math.floor(v * 255 + 0.5) end

-- ---------- ตั้งค่าให้ element ตามชนิด (รับค่าแบบ Rayfield) ----------
local function __apply(kind, el, val, skip)
    if kind == "dropdown" then
        if el.Multi then
            el:Set(val, skip)
        else
            if type(val) == "table" then val = val[1] end
            el:Set(val, skip)
        end
    elseif kind == "color" then
        el:Set(val, nil, skip)
    else
        el:Set(val, skip)
    end
end

-- ---------- Flag proxy: ข้อมูลล้วนที่ JSON-safe + :Set() / .Color ผ่าน metatable ----------
local function __makeProxy(flag, kind, initial)
    local p = {}
    if kind == "color" then
        local c = initial or Color3.new(1, 1, 1)
        p.R, p.G, p.B = __c255(c.R), __c255(c.G), __c255(c.B)
    elseif kind == "dropdown" then
        p.CurrentOption = initial or {}
    else
        p.CurrentValue = initial
    end
    setmetatable(p, {
        __index = function(t, k)
            if k == "Set" then
                return function(_, val, skip)
                    local rec = __els[flag]
                    if rec then
                        pcall(__apply, rec.kind, rec.el, val, skip)
                    elseif kind == "color" then
                        if typeof(val) == "Color3" then t.R, t.G, t.B = __c255(val.R), __c255(val.G), __c255(val.B) end
                    elseif kind == "dropdown" then
                        t.CurrentOption = type(val) == "table" and val or { val }
                    else
                        t.CurrentValue = val
                    end
                end
            elseif k == "Color" and kind == "color" then
                return Color3.fromRGB(t.R or 255, t.G or 255, t.B or 255)
            end
            return nil
        end,
    })
    __Flags[flag] = p
    return p
end

-- เชื่อมค่าใน element -> proxy (Changed ยิงก่อน Callback เสมอ จึงอ่านค่าใน callback ได้ทันที)
local function __hook(el, kind, flag)
    if not flag then return end
    __els[flag] = { el = el, kind = kind }
    local p = __Flags[flag]
    el.Changed:Connect(function(v)
        if kind == "color" then
            local c = type(v) == "table" and v.Color or v
            if typeof(c) == "Color3" then p.R, p.G, p.B = __c255(c.R), __c255(c.G), __c255(c.B) end
        elseif kind == "dropdown" then
            if type(v) == "table" then p.CurrentOption = table.clone(v)
            elseif v == nil then p.CurrentOption = {}
            else p.CurrentOption = { v } end
        else
            p.CurrentValue = v
        end
    end)
end

local function __dummyEl()
    local d = {}
    setmetatable(d, { __index = function() return function() return d end end })
    return d
end

-- ---------- ห่อ element ของ Oasis ให้มี :Set / :Refresh / :SetTitle / :SetContent แบบเดิม ----------
local function __wrapEl(el, kind)
    if not el then return __dummyEl() end
    local w = {}
    local lastTitle = el.Title
    function w:Set(val, skip) pcall(__apply, kind, el, val, skip) end
    function w:SetTitle(t)
        if t ~= lastTitle then lastTitle = t; el:SetTitle(t) end
    end
    if kind == "dropdown" then
        function w:Refresh(opts, keep) el:Refresh(opts, keep) end
        w.SetOptions = w.Refresh
    end
    setmetatable(w, {
        __index = function(_, k)
            local v = el[k]
            if type(v) == "function" then
                return function(_, ...) return v(el, ...) end
            end
            return v
        end,
    })
    return w
end

local __autoFlag = 0

-- ---------- Tab wrapper: Section ซ้าย/ขวา + element ภายใน ----------
local function __makeTab(tab, tabTitle)
    local T = {}
    local cur = nil
    local side = "Left"

    local function box()
        if not cur then cur = tab:Section({ Title = tostring(tabTitle or ""), Side = side, Opened = true }) end
        return cur
    end

    function T:CreateSection(name, s)
        if s == "Left" or s == "Right" then side = s end
        local sec = tab:Section({ Title = tostring(name or ""), Side = side, Opened = true })
        cur = sec
        return { Set = function(_, t) pcall(function() sec:SetTitle(tostring(t)) end) end }
    end

    function T:CreateLabel(text)
        if type(text) == "table" then text = text.Name or text.Text or text.Title end
        local ok, el = pcall(function() return box():Label({ Text = tostring(text or "") }) end)
        if ok and el then return __wrapEl(el, "label") end
        return __dummyEl()
    end

    function T:CreateDivider()
        pcall(function() box():Divider({}) end)
        return __dummyEl()
    end

    function T:CreateButton(cfg)
        cfg = cfg or {}
        local ok, el = pcall(function()
            return box():Button({ Title = cfg.Name or "", Callback = cfg.Callback })
        end)
        if ok and el then return __wrapEl(el, "button") end
        return __dummyEl()
    end

    function T:CreateToggle(cfg)
        cfg = cfg or {}
        local flag = cfg.Flag
        local on = cfg.CurrentValue == true
        if flag then __makeProxy(flag, "toggle", on) end
        local ok, el = pcall(function()
            return box():Toggle({ Title = cfg.Name or "", Default = on, Flag = flag, Callback = cfg.Callback })
        end)
        if ok and el then __hook(el, "toggle", flag); return __wrapEl(el, "toggle") end
        return __dummyEl()
    end

    function T:CreateSlider(cfg)
        cfg = cfg or {}
        local flag = cfg.Flag
        local rng = cfg.Range or { 0, 100 }
        local start = cfg.CurrentValue or rng[1]
        if flag then __makeProxy(flag, "slider", start) end
        local ok, el = pcall(function()
            return box():Slider({
                Title = cfg.Name or "",
                Min = rng[1], Max = rng[2],
                Default = start,
                Step = cfg.Increment,
                Suffix = cfg.Suffix,
                Flag = flag,
                Callback = cfg.Callback,
            })
        end)
        if ok and el then __hook(el, "slider", flag); return __wrapEl(el, "slider") end
        return __dummyEl()
    end

    function T:CreateInput(cfg)
        cfg = cfg or {}
        local flag = cfg.Flag
        local start = tostring(cfg.CurrentValue or "")
        if flag then __makeProxy(flag, "input", start) end
        local ok, el = pcall(function()
            return box():Input({
                Title = cfg.Name or "",
                Default = start,
                Placeholder = cfg.PlaceholderText or "",
                Flag = flag,
                Callback = cfg.Callback,
            })
        end)
        if ok and el then __hook(el, "input", flag); return __wrapEl(el, "input") end
        return __dummyEl()
    end

    function T:CreateColorPicker(cfg)
        cfg = cfg or {}
        local flag = cfg.Flag
        local c = cfg.Color or Color3.new(1, 1, 1)
        if flag then __makeProxy(flag, "color", c) end
        local ok, el = pcall(function()
            return box():ColorPicker({ Title = cfg.Name or "", Default = c, Flag = flag, Callback = cfg.Callback })
        end)
        if ok and el then __hook(el, "color", flag); return __wrapEl(el, "color") end
        return __dummyEl()
    end

    function T:CreateKeybind(cfg)
        cfg = cfg or {}
        local key = cfg.CurrentKeybind
        if typeof(key) == "EnumItem" then key = key.Name end
        __autoFlag = __autoFlag + 1
        local ok, el = pcall(function()
            return box():Keybind({
                Title = cfg.Name or "Keybind",
                Default = key,
                Mode = "Always",
                Modes = { "Always" },
                Flag = cfg.Flag or ("AmberKeybind" .. __autoFlag),
                Callback = cfg.Callback,
            })
        end)
        if ok and el then return __wrapEl(el, "keybind") end
        return __dummyEl()
    end

    function T:CreateDropdown(cfg)
        cfg = cfg or {}
        local flag = cfg.Flag
        local initial = cfg.CurrentOption or {}
        local multi = cfg.MultipleOptions == true
        if flag then __makeProxy(flag, "dropdown", table.clone(initial)) end
        local userCb = cfg.Callback
        local ok, el = pcall(function()
            return box():Dropdown({
                Title = cfg.Name or "",
                Values = cfg.Options or {},
                Multi = multi,
                Default = multi and initial or initial[1],
                AllowNone = (not multi) and (initial[1] == nil),
                Flag = flag,
                Callback = function(v)
                    if not userCb then return end
                    local list
                    if type(v) == "table" then list = v
                    elseif v == nil then list = {}
                    else list = { v } end
                    userCb(list)
                end,
            })
        end)
        if ok and el then __hook(el, "dropdown", flag); return __wrapEl(el, "dropdown") end
        return __dummyEl()
    end

    function T:CreateParagraph(cfg)
        cfg = cfg or {}
        local ok, el = pcall(function()
            return box():Paragraph({ Title = tostring(cfg.Title or ""), Content = tostring(cfg.Content or "") })
        end)
        if ok and el then return __wrapEl(el, "paragraph") end
        return __dummyEl()
    end

    setmetatable(T, { __index = function(_, k)
        return function()
            pcall(function() warn("[AmberAdapter] missing tab method: " .. tostring(k)) end)
            return __dummyEl()
        end
    end })
    return T
end

-- ---------- Library-level adapter ----------
local __AmberAdapter = {}
__AmberAdapter.Flags = __Flags

function __AmberAdapter:CreateWindow(p)
    p = p or {}
    local size = p.SizeSettings or { 750, 480 }
    local icon = (type(p.Icon) == "string" and p.Icon ~= "") and p.Icon or "sparkles"
    local saving = p.ConfigurationSaving or {}
    __win = Oasis:CreateWindow({
        Title = p.Name or "AmberCore v9",
        Subtitle = "Forsaken",
        Icon = icon,
        Folder = saving.FolderName or "AmberCoreRemastered",
        GuiName = "AmberCoreOasis",
        Size = UDim2.fromOffset(size[1], size[2]),
        Theme = "Amber",
        ToggleKey = p.ToggleUIKeybind or "RightShift",
        MenuButton = true,
        -- แท็บยังไม่ถูกสร้างตอนนี้ จึงปิดการโหลดอัตโนมัติ แล้วเรียก FinalizeConfiguration() ตอนท้ายสคริปต์
        AutoLoad = false,
        AutoSave = true,
        DefaultConfig = "Default",
    })

    local W = { Flags = __Flags }
    function W:CreateTab(name, tabIcon)
        local tab = __win:Tab({ Title = tostring(name or "Tab"), Icon = __icon(tabIcon) })
        return __makeTab(tab, name)
    end
    function W:SelectTab(i)
        local tab = type(i) == "number" and __win.Tabs[i] or i
        if tab then pcall(function() __win:SelectTab(tab) end) end
    end
    return W
end

function __AmberAdapter:Notify(p)
    p = p or {}
    local img = p.Image
    local ntype = "Info"
    if img == "check" or img == "success" then ntype = "Success"
    elseif img == "ban" or img == "error" or img == "x-circle" then ntype = "Error"
    elseif img == "alert" or img == "warning" or img == "sword" then ntype = "Warning"
    end
    pcall(function()
        Oasis:Notify({
            Title = p.Title or "AmberCore",
            Content = p.Content or "",
            Type = ntype,
            Duration = p.Duration or 5,
        })
    end)
end

-- การโหลดคอนฟิกเดิมถูกแทนที่ด้วยระบบ Config ของ Oasis (แท็บ Settings)
function __AmberAdapter:LoadConfiguration() end

function __AmberAdapter:FinalizeConfiguration()
    if __win then pcall(function() __win:LoadAutoload() end) end
end

function __AmberAdapter:Destroy()
    pcall(function() Oasis:Unload() end)
end

local UILibrary = __AmberAdapter




if type(isfolder)=='function' and type(makefolder)=='function' and not isfolder('AmberCore') then pcall(makefolder, 'AmberCore') end
if type(isfile)=='function' and type(writefile)=='function' and not isfile('AmberCorewoman.png') then
    pcall(function() local b = __safeHttpGet and __safeHttpGet('https://raw.githubusercontent.com/aibabylaugh/catsaken/main/woman.png') or game:HttpGet('https://raw.githubusercontent.com/aibabylaugh/catsaken/main/woman.png'); if b then writefile('AmberCorewoman.png', b) end end)
end

local introFinished = useLegacyUI
local assetsPrepared = false
local updateStatusText

if not useLegacyUI then
    task.spawn(function()
        local introDone = false
        task.spawn(function()
            Wait(1)
            local blur = Instance.new("BlurEffect", Lighting)
            blur.Size = 0
            local gui = Instance.new("ScreenGui", gethui())
            gui.ResetOnSpawn = false
            local container = Instance.new("Frame", gui)
            container.Size = UDim2.new(0,600,0,130)
            container.Position = UDim2.new(0.5,0,0.5,0)
            container.AnchorPoint = Vector2.new(0.5,0.5)
            container.BackgroundTransparency = 1

            local status = Instance.new("TextLabel", container)
            status.Text = "กำลังเริ่มต้น"
            status.Font = Enum.Font.LuckiestGuy
            status.Size = UDim2.new(0,600,0,25)
            status.Position = UDim2.new(0,0,0,105)
            status.TextSize = 18
            status.TextColor3 = Color3.new(1,1,1)
            status.TextXAlignment = Enum.TextXAlignment.Center
            status.BackgroundTransparency = 1

            function updateStatusText(txt) status.Text = txt end

            local logo = Instance.new("ImageLabel", container)
            logo.Size = UDim2.new(0,100,0,100)
            logo.Position = UDim2.new(0,250,0,0)
            logo.BackgroundTransparency = 1
            logo.Image = getcustomasset("AmberCorewoman.png")
            logo.ImageTransparency = 1

            local title = Instance.new("TextLabel", container)
            title.Text = "AmberCore V9"
            title.Font = Enum.Font.LuckiestGuy
            title.Size = UDim2.new(0,0,0,100)
            title.Position = UDim2.new(0,350,0,0)
            title.TextSize = 40
            title.TextColor3 = Color3.new(0,0,0)
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.BackgroundTransparency = 1
            title.ClipsDescendants = true

            local orange = Color3.fromHex("F59F27")
            local black = Color3.new(0,0,0)
            local pulsing = false

            local function startPulse()
                pulsing = true
                task.spawn(function()
                    while pulsing do
                        TweenService:Create(title, TweenInfo.new(0.5), {TextColor3 = orange}):Play()
                        task.wait(0.5)
                        if not pulsing then break end
                        TweenService:Create(title, TweenInfo.new(0.5), {TextColor3 = black}):Play()
                        task.wait(0.5)
                    end
                end)
            end
            local function stopPulse()
                pulsing = false
                TweenService:Create(title, TweenInfo.new(0.5), {TextColor3 = orange}):Play()
                task.wait(0.5)
            end

            TweenService:Create(logo, TweenInfo.new(1), {ImageTransparency = 0}):Play()
            TweenService:Create(blur, TweenInfo.new(1), {Size = 12}):Play()
            task.wait(1)

            local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(logo, tweenInfo, {Position = UDim2.new(0,0,0,0)}):Play()
            TweenService:Create(title, tweenInfo, {Position = UDim2.new(0,100,0,0), Size = UDim2.new(0,500,0,100)}):Play()
            startPulse()
            repeat task.wait() until introDone
            stopPulse()
            task.wait(0.3)

            local outInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            TweenService:Create(logo, outInfo, {Position = UDim2.new(0,250,0,0)}):Play()
            TweenService:Create(title, outInfo, {Position = UDim2.new(0,350,0,0), Size = UDim2.new(0,0,0,100)}):Play()
            task.spawn(function()
                TweenService:Create(status, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {TextSize = 22}):Play()
                task.wait(0.3)
                TweenService:Create(status, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextSize = 13, TextTransparency = 1, Position = UDim2.new(0,0,0,125)}):Play()
            end)
            task.wait(1.5)
            TweenService:Create(logo, TweenInfo.new(1), {ImageTransparency = 1}):Play()
            TweenService:Create(blur, TweenInfo.new(1), {Size = 0}):Play()
            task.wait(1)
            blur:Destroy()
            gui:Destroy()
        end)
        repeat task.wait() until assetsPrepared and updateStatusText
        local allDesc = _G.globaluilibrary:GetDescendants()
        local images = {}
        for i = 1, #allDesc do
            if allDesc[i]:IsA("ImageLabel") or allDesc[i]:IsA("ImageButton") then
                table.insert(images, allDesc[i])
            end
        end
        updateStatusText("Preparing UI (0/" .. #images .. ")")
        local loaded = 0
        task.spawn(function()
            for i = 1, #images do
                local done = false
                task.spawn(function() pcall(ContentProvider.PreloadAsync, ContentProvider, {images[i]}) done = true end)
                local t = tick()
                repeat task.wait() until done or tick() - t > 2
                loaded += 1
            end
        end)
        while task.wait() do
            updateStatusText("กำลังเตรียมหน้าต่าง (" .. loaded .. "/" .. #images .. ")")
            if loaded == #images then break end
        end
        updateStatusText("พร้อมใช้งาน")
        task.wait(2)
        introDone = true
        updateStatusText("พร้อมใช้งาน")
        task.wait(2)
        introFinished = true
    end)
end

-- ------------------------------------------------------------------
-- AmberCore | 04 / Window setup
-- ------------------------------------------------------------------
local Window = UILibrary:CreateWindow{
    Name = 'AmberCore v9',
    Icon = getcustomasset("AmberCorewoman.png"),
    LoadingTitle = 'AmberCore v9',
    LoadingSubtitle = 'V3',
    ShowText = 'AmberCore',
    Theme = 'AmberGlow',
    ToggleUIKeybind = 'RightShift',
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = 'AmberCoreRemastered',
        FileName = 'Forsaken'
    },
    Discord = { Enabled = false, Invite = '', RememberJoins = true },
    SizeSettings = {750,480}
}

if useLegacyUI then Window.Flags = UILibrary.Flags end

if isVelocityExecutor then
    UILibrary:Notify{Title='ถึงผู้ใช้ Velocity', Content = 'เอ็กเซกิวเตอร์ของคุณไม่เสถียรมาก สคริปต์อาจแครชแบบสุ่มหรือเมื่อเปิดฟีเจอร์บางอย่าง', Duration=30, Image='bug'}
end

local MobileToggle
if not useLegacyUI then
    MobileToggle = IconModule.new():setImage(getcustomasset("AmberCorewoman.png")):setCaption('เปิด/ปิดเมนู'):autoDeselect(false):select()
    GlobalEnv.MobileToggle = MobileToggle
    MobileToggle:setEnabled(false)
end

function FindAnimationAsset(configModule, animName)
    local mod = require(configModule)
    if not mod.Animations then return warn('Module "'..tostring(configModule.Parent)..'" does not have Animations') end
    if not mod.Animations[animName] then return warn(animName .. ' is not an existing attack') end
    return mod.Animations[animName]
end

local AboutTab = Window:CreateTab('เกี่ยวกับ','info')
AboutTab:CreateSection('ติดต่อนักพัฒนา')
AboutTab:CreateLabel("คุณสามารถส่งข้อความถึงนักพัฒนาสคริปต์นี้โดยตรงผ่านช่องด้านล่าง")
local feedbackMessage = ""
local lastFeedbackTime = 0
local sentMessages = {}
AboutTab:CreateInput{
    Name = 'ข้อความของคุณ',
    CurrentValue = feedbackMessage,
    PlaceholderText = 'Empty',
    RemoveTextAfterFocusLost = false,
    Flag = 'FeedbackMessage',
    Callback = function(txt) feedbackMessage = txt end
}
AboutTab:CreateButton{
    Name = 'ส่งเลย 📧',
    Callback = function()
        if feedbackMessage == "" then return end
        if #feedbackMessage <= 30 or #feedbackMessage:split(" ") <= 4 then
            return UILibrary:Notify{Title='AmberCore', Content = 'ข้อความสั้นเกินไป', Duration=12, Image='ban'}
        end
        if sentMessages[feedbackMessage] then
            return UILibrary:Notify{Title='AmberCore', Content = 'คุณส่งข้อความนี้ไปแล้ว', Duration=12, Image='ban'}
        end
        if tick() - lastFeedbackTime >= 60 then
            sentMessages[feedbackMessage] = true
            lastFeedbackTime = tick()
            pcall(function()
                http.request{
                    Method = "POST",
                    Url = "https://megasaken.feedback.workers.dev/",
                    Headers = {['content-type']='application/json'},
                    Body = HttpService:JSONEncode{
                        content = feedbackMessage .. "\nBy " .. LocalPlayer.Name .. " (" .. LocalPlayer.UserId .. ")\nDevice: " .. (isMobile and "Mobile" or "PC") .. "\nExecutor: " .. identifyexecutor()
                    }
                }
            end)
            UILibrary:Notify{Title='AmberCore', Content = 'ส่งข้อความแล้ว โปรดทราบว่าฉันไม่สามารถตอบกลับโดยตรงได้ แต่ฉันจะอ่านอย่างรวดเร็วแน่นอน', Duration=12, Image='check'}
        else
            UILibrary:Notify{Title='AmberCore', Content = 'ส่งได้ครั้งละหนึ่งข้อความต่อนาที', Duration=12, Image='ban'}
        end
    end
}
AboutTab:CreateSection('วิธีใช้สคริปต์','Right')
AboutTab:CreateLabel("ปุ่มลัดเปิดเมนูคือ RightShift" .. (useLegacyUI and "." or ", or press the button in the top bar."))
AboutTab:CreateLabel("ควรใช้บัญชีสำรองหรือระมัดระวังอย่างมาก")
AboutTab:CreateLabel("เพื่อความชัดเจน เราไม่ได้เก็บรวบรวมบันทึกการรันหรือบันทึกการแก้บั๊กของคุณ")
if useLegacyUI then
    AboutTab:CreateLabel("เนื่องจากคุณกำลังใช้หน้าต่างแบบเก่ากับสคริปต์ที่สร้างบนหน้าต่างแบบใหม่ อาจมีบั๊กในเวอร์ชันนี้ หากพบโปรดรายงาน")
else
    AboutTab:CreateSection('บันทึกการเปลี่ยนแปลง')
    AboutTab:CreateLabel([[09/09/2026
    • Major bug fixes
    • Major improvements to auto-block (Full rework)
    • Azure ESP
    • Auto Disarm Azure Vines
    • Inf Attempts To Disarm Vines
    • Fullbright
    • TP Dagger
    • TP Slash
    • TP One Shot
    • Auto Chicken
    • Auto Raging Pace
    08/09/2026
    • Updated to the latest patch of forsaken
    • Bug Fixes and QOL Changes
    • Azure Aimbot
    • Mouse1 Aimbot
    • Improved Auto Slash
    • Killer Auto-Farm Survivors
    • Bypass Killer-Only Walls
    • TP To Random Survivor, TP To Killer, Spectate Killer
    • Always Show Chat
    • Disable AFK Insanity
    • Auto Backstab 'Invis Option'
    • Added multiple configs as someone suggested]])
end

local function EmptyCallback() end
local GeneratorsTab = Window:CreateTab('เครื่องปั่นไฟ','battery-charging')
local EspTab = Window:CreateTab('มองทะลุ','scan-eye')
local StaminaTab = Window:CreateTab('แสตมินา','footprints')
local AimbotTab = Window:CreateTab('เล็งอัตโนมัติ','crosshair')
local HitboxTab = Window:CreateTab('ฮิตบ็อกซ์','sword')
local ConvenienceTab = Window:CreateTab('ความสะดวก','leaf')
local AutoBlockTab = Window:CreateTab('บล็อกอัตโนมัติ','shield')
local PlayerTab = Window:CreateTab('ผู้เล่น','user')
local MapTab = Window:CreateTab('แผนที่','map')
local AntisTab = Window:CreateTab('ต้านเอฟเฟกต์','ban')
local MiscTab = Window:CreateTab('เบ็ดเตล็ด','dices')
local ConfigsTab = Window:CreateTab('ตั้งค่าคอนฟิก','cog')

-- ===== ADDED: New tabs (Editor + Audio) =====
local EditorTab = Window:CreateTab('ตัวแก้ไข','wand-sparkles')
local AudioTab = Window:CreateTab('เสียง','music')

if not useLegacyUI then Window:SelectTab(1) end

local KillerSkins = ReplicatedStorage.Assets.Skins.Killers
local KillerAssets = ReplicatedStorage.Assets.Killers
local SurvivorAssets = ReplicatedStorage.Assets.Survivors

-- ------------------------------------------------------------------
-- AmberCore | 05 / Runtime state
-- ------------------------------------------------------------------
local GameData = {
    GameState = 0,
    RoundStart = 0,
    RoundGenerators = {},
    Killers = {},
    Survivors = {},
    Items = {},
    Gingerbread = {},
    TaphDebris = {},
    BuildermanDebris = {},
    DoeDebris = {},
    VeeDebris = {},
    AzureDebris = {},
    Spikes = {},
    AttackAnimations = {},
    M1Animations = {},
    SentinelAnimations = {},
    BlockMeta = {},
    DusekkarActive = false,
    NoliActive = false,
    CoolkidActive = false,
    CurrentPuzzle = nil,
    EspAppliedToGenerators = {},
    EspAppliedToItems = {},
    EspAppliedToGingerbread = {},
    EspAppliedToTaphDebris = {},
    EspAppliedToBuildermanDebris = {},
    EspAppliedToDoeDebris = {},
    EspAppliedToVeeDebris = {},
    EspAppliedToAzureDebris = {},
    ConstantImages = {},
    UsingWalkspeedOverride = false,
    WalkspeedOverrideAnimations = {},
    WalkspeedOverrideEndedAnims = {},
    PursuitTracker = nil,
    VoidRushTracker = nil,
}

LocalPlayer.PlayerGui.TemporaryUI.ChildAdded:Connect(function(child)
    if child.Name == 'PlayerInfo' then PlayerInfoUI = child end
end)

function InsertAttackAnim(animId)
    if not animId then return end
    if table.find(GameData.AttackAnimations, animId) then return end
    table.insert(GameData.AttackAnimations, animId)
end

function SearchSurvivorAnimations(survivorName)
    local skinFolder = ReplicatedStorage.Assets.Skins.Survivors
    local attacks = {'LungeStart','Axe','Punch','ParryPunch','Slash'}
    for _, attackName in ipairs(attacks) do
        for _, skin in ipairs(skinFolder[survivorName]:GetChildren()) do
            if not skin:FindFirstChild("Config") then continue end
            local anim = FindAnimationAsset(skin.Config, attackName)
            if anim and table.find(attacks, attackName) then
                table.insert(GameData.SentinelAnimations, anim)
            end
            InsertAttackAnim(anim)
        end
        local baseAnim = FindAnimationAsset(SurvivorAssets[survivorName].Config, attackName)
        if baseAnim and table.find(attacks, attackName) then
            table.insert(GameData.SentinelAnimations, baseAnim)
        end
        InsertAttackAnim(baseAnim)
    end
end

function SearchKillerAnimations(killerName, attackList, skinFolderOverride, assetFolderOverride)
    local m1Names = {'Slash','SlashAir','Stab','Bite','Attack'}
    if not GameData.BlockMeta[killerName] then GameData.BlockMeta[killerName] = {} end
    for _, attackName in ipairs(attackList) do
        for _, skin in ipairs((skinFolderOverride or KillerSkins)[killerName]:GetChildren()) do
            if not skin:FindFirstChild("Config") then continue end
            local anim = FindAnimationAsset(skin.Config, attackName)
            if anim then
                GameData.BlockMeta[anim] = attackName
                if table.find(m1Names, attackName) then table.insert(GameData.M1Animations, anim) end
            end
            InsertAttackAnim(anim)
        end
        local baseAnim = FindAnimationAsset((assetFolderOverride or KillerAssets)[killerName].Config, attackName)
        if baseAnim then
            if table.find(m1Names, attackName) then table.insert(GameData.M1Animations, baseAnim) end
            GameData.BlockMeta[baseAnim] = attackName
        end
        InsertAttackAnim(baseAnim)
    end
end

SearchKillerAnimations('Slasher', {'Slash'})
SearchKillerAnimations('1x1x1x1', {'Slash','Entanglement','MassInfection'})
SearchKillerAnimations('Nosferatu', {'Slash','SlashAir'})
SearchKillerAnimations('Noli', {'Stab'})
SearchKillerAnimations('JohnDoe', {'Slash'})
for _, skin in ipairs(KillerSkins.Sixer:GetChildren()) do
    if not skin:FindFirstChild("Config") then continue end
    local anims = FindAnimationAsset(skin.Config, 'Slash')
    if anims and anims.Slash then
        table.insert(GameData.M1Animations, anims.Slash)
        table.insert(GameData.M1Animations, anims.Bite)
        InsertAttackAnim(anims.Slash)
        InsertAttackAnim(anims.Bite)
    end
end
do
    local sixerAnims = FindAnimationAsset(KillerAssets.Sixer.Config, 'Slash')
    table.insert(GameData.M1Animations, sixerAnims.Slash)
    table.insert(GameData.M1Animations, sixerAnims.Bite)
    InsertAttackAnim(sixerAnims.Slash)
    InsertAttackAnim(sixerAnims.Bite)
end
SearchKillerAnimations('c00lkidd', {'Attack','CorruptNature'})
SearchKillerAnimations('Azure', {'Slash'})
SearchKillerAnimations('Shedletsky', {'Slash'}, ReplicatedStorage.Assets.Skins.Survivors, SurvivorAssets)
SearchSurvivorAnimations('Shedletsky')
SearchSurvivorAnimations('JaneDoe')
SearchSurvivorAnimations('Guest1337')
SearchSurvivorAnimations('TwoTime')

do
    local startAnims = GameData.WalkspeedOverrideAnimations
    local endAnims = GameData.WalkspeedOverrideEndedAnims
    table.insert(startAnims, require(KillerAssets.c00lkidd.Config).Animations.WalkspeedOverrideStart)
    for _, skin in ipairs(KillerSkins.c00lkidd:GetChildren()) do
        if not skin:FindFirstChild('Config') then continue end
        local cfg = require(skin:FindFirstChild('Config'))
        if not cfg.Animations then continue end
        if not cfg.Animations.WalkspeedOverrideStart then continue end
        if not cfg.Animations.WalkspeedOverrideHit then continue end
        if not cfg.Animations.WalkspeedOverrideMiss then continue end
        if not table.find(startAnims, cfg.Animations.WalkspeedOverrideStart) then table.insert(startAnims, cfg.Animations.WalkspeedOverrideStart) end
        if not table.find(endAnims, cfg.Animations.WalkspeedOverrideHit) then table.insert(endAnims, cfg.Animations.WalkspeedOverrideHit) end
        if not table.find(endAnims, cfg.Animations.WalkspeedOverrideMiss) then table.insert(endAnims, cfg.Animations.WalkspeedOverrideMiss) end
    end
    task.spawn(function()
        while Wait() do
            if not KillersFolder:FindFirstChild('c00lkidd') then GameData.UsingWalkspeedOverride = false end
        end
    end)
end

function IsRoundLoaded()
    if not LocalPlayer.PlayerGui:FindFirstChild('KillerIntroUI') then return false end
    return #LocalPlayer.PlayerGui.KillerIntroUI:GetChildren() == 0
end

function GameStateChanged(onRound, onSpectate)
    SurvivorsFolder.ChildAdded:Connect(function(char)
        if onRound and char:GetAttribute('Username') == LocalPlayer.Name then onRound() end
    end)
    KillersFolder.ChildAdded:Connect(function(char)
        if onRound and char:GetAttribute('Username') == LocalPlayer.Name then onRound() end
    end)
    SpectatingFolder.ChildAdded:Connect(function(char)
        if onSpectate and char.Name == LocalPlayer.Name then onSpectate() end
    end)
end

GameStateChanged(function()
    warn('in round')
    GameData.RoundStart = tick()
    GameData.GameState = 1
end, function()
    warn('spectating')
    GameData.GameState = 0
end)

GameData.GameState = SpectatingFolder:FindFirstChild(LocalPlayer.Name) and 0 or 1

function WaitAndReset(flag, duration)
    GameData[flag] = true
    task.spawn(function()
        Wait(duration or 3)
        GameData[flag] = false
    end)
end

local oldNamecall
oldNamecall = hookmetamethod(game, '__namecall', function(self, ...)
    if isUnloaded then return oldNamecall(self, ...) end
    if typeof(self) == 'Instance' and tostring(self) == 'RemoteEvent' then
        local args = ({...})[2]
        if type(args) == 'table' and typeof(args[1]) == 'buffer' then
            local str = buffer.tostring(args[1])
            if str:find('PlasmaBeam') then WaitAndReset('DusekkarActive')
            elseif str:find('Nova') then WaitAndReset('NoliActive')
            elseif str:find('CorruptNature') then WaitAndReset('CoolkidActive') end
        end
    end
    return oldNamecall(self, ...)
end)

function GetClosestGenerator(returnIndex)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
    if not root then return end
    for idx, gen in ipairs(GameData.RoundGenerators) do
        if gen:FindFirstChild('Positions') and gen.Positions:FindFirstChild('Center') and (gen.Positions.Center.Position - root.Position).Magnitude <= 7 then
            return returnIndex and idx or gen
        end
    end
end

function IsPlayerNearGenerator(generator)
    local all = {}
    for _, v in ipairs(GameData.Survivors) do table.insert(all, v) end
    for _, v in ipairs(GameData.Killers) do table.insert(all, v) end
    for _, char in ipairs(all) do
        local hrp = char:FindFirstChild('HumanoidRootPart')
        if not hrp then continue end
        if char:GetAttribute('Username') == LocalPlayer.Name then continue end
        if generator:FindFirstChild('Positions') and generator.Positions:FindFirstChild('Center') and (generator.Positions.Center.Position - hrp.Position).Magnitude <= 40 then
            return true
        end
    end
    return false
end

function GetGameMap() return workspace.Map:FindFirstChild('Ingame') and workspace.Map.Ingame:FindFirstChild('Map') end
function GetGameMapObjects() return GetGameMap():GetChildren() end
function PressKeycode(key) for i=1,2 do VirtualInputManager:SendKeyEvent(i<2, key, false, game) Wait() end end

function GetClosestToMouse(team)
    local key = (team == 'Killer' and 'Killers' or (team == 'Survivor' and 'Survivors'))
    if #GameData[key] == 0 then return nil end
    local bestDist = math.huge
    local best
    for _, char in ipairs(GameData[key]) do
        local hrp = char:FindFirstChild('HumanoidRootPart')
        if not hrp then continue end
        if RealDevice ~= 'PC' then
            local pos, onScreen = CurrentCamera:WorldToViewportPoint(hrp.Position)
            if not onScreen then continue end
            local dist = (Vector2.new(pos.X, pos.Y) - CurrentCamera.ViewportSize/2).Magnitude
            if dist < bestDist then bestDist = dist best = char end
        else
            local mouse = LocalPlayer:GetMouse()
            local pos, onScreen = CurrentCamera:WorldToViewportPoint(hrp.Position)
            if not onScreen then continue end
            local dist = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
            if dist < bestDist then bestDist = dist best = char end
        end
    end
    return best
end

function GetClosestSurvivor(maxDist)
    local list = {}
    for _, char in ipairs(GameData.Survivors) do
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart') and char:FindFirstChild('HumanoidRootPart') and char ~= LocalPlayer.Character then
            local d = (LocalPlayer.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
            if d <= maxDist then table.insert(list, {Distance=d, Player=char}) end
        end
    end
    table.sort(list, function(a,b) return a.Distance < b.Distance end)
    return list[1] and list[1].Player
end

function GetClosestKiller(maxDist)
    local list = {}
    for _, char in ipairs(GameData.Killers) do
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart') and char:FindFirstChild('HumanoidRootPart') and char ~= LocalPlayer.Character then
            local d = (LocalPlayer.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
            if d <= maxDist then table.insert(list, {Distance=d, Player=char}) end
        end
    end
    table.sort(list, function(a,b) return a.Distance < b.Distance end)
    return list[1] and list[1].Player
end

function Predict(char)
    return char.HumanoidRootPart.Position + (char.Humanoid.MoveDirection * (char.HumanoidRootPart.Velocity / 20))
end

function GetKillerUsername()
    for _, char in ipairs(GameData.Killers) do
        if char:GetAttribute("Username") then return char:GetAttribute("Username") end
    end
end

function IsKiller()
    if not LocalPlayer.Character then return end
    if not LocalPlayer.Character.Parent then return end
    return LocalPlayer.Character.Parent == KillersFolder
end

function HasAbility(name) return PlayerGui.MainUI:FindFirstChild("AbilityContainer") and PlayerGui.MainUI.AbilityContainer:FindFirstChild(name) end
function HasAbilityReady(name) return HasAbility(name) and HasAbility(name).CooldownTime.Text == "" end

function GetM1Name()
    local default = 'Slash'
    if not LocalPlayer.Character then return default end
    if LocalPlayer.Character.Parent ~= KillersFolder then return default end
    local charName = LocalPlayer.Character.Name
    if charName == 'c00lkidd' then return 'Tag'
    elseif charName == 'Noli' then return 'Stab'
    elseif charName == 'Nosferatu' then return 'Lacerate' end
    return default
end

function ToggleShiftLock() if not SmoothShiftLock.Enabled then SmoothShiftLock:ToggleShiftLock() end end

function StartAimbotting(target, condition, cameraFunc, duration)
    local start = tick()
    local wasEnabled = SmoothShiftLock.Enabled
    while Wait() and tick() - start <= (duration or 6) do
        if target and target.Parent and condition() then
            ToggleShiftLock()
            CurrentCamera.CFrame = (cameraFunc and cameraFunc()) or CFrame.new(CurrentCamera.CFrame.Position, target.HumanoidRootPart.CFrame.Position)
        else
            if not wasEnabled then SmoothShiftLock:ToggleShiftLock() end
            break
        end
    end
end

function HasNotification(text)
    for _, noti in pairs(LocalPlayer.PlayerGui.Notis:GetChildren()) do
        if string.find(noti.Text:lower(), text) then return true end
    end
end

function ApplyConstantImage(part, imageId)
    if ConstantImageMap[part] then return end
    local img = Instance.new('ImageLabel', EspScreenGui)
    img.Image = imageId
    img.BackgroundTransparency = 1
    ConstantImageMap[part] = img
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not part.Parent or not part.Parent:FindFirstChild(part.Name) then
            conn:Disconnect()
            img:Destroy()
            return
        end
        local pos, onScreen = CurrentCamera:WorldToViewportPoint(part.Position)
        local sizeVec = pos - CurrentCamera:WorldToViewportPoint(part.Position + Vector3.new(0,3,0))
        img.Visible = onScreen
        img.Position = UDim2.new(0, pos.X, 0, pos.Y)
        img.Size = UDim2.new(0, sizeVec.Y, 0, sizeVec.Y)
    end)
    GameData.ConstantImages[img] = {Connection = conn, Handle = part}
end
EspScreenGui.IgnoreGuiInset = true

local scannerReady = false
task.spawn(function()
    while Wait(0.3) do
        if GetGameMap() then
            local newData = {
                RoundGenerators = {}, Killers = {}, Survivors = {}, Items = {},
                Gingerbread = {}, TaphDebris = {}, BuildermanDebris = {}, DoeDebris = {},
                VeeDebris = {}, AzureDebris = {}, Spikes = {}
            }
            for _, char in ipairs(KillersFolder:GetChildren()) do
                if char:GetAttribute("Username") ~= nil and not table.find(newData.Killers, char) then
                    table.insert(newData.Killers, char)
                end
            end
            for _, char in ipairs(SurvivorsFolder:GetChildren()) do
                if not table.find(newData.Survivors, char) then table.insert(newData.Survivors, char) end
            end
            for _, gen in ipairs(GetGameMapObjects()) do
                if gen.Name == 'Generator' and not table.find(newData.RoundGenerators, gen) then
                    table.insert(newData.RoundGenerators, gen)
                elseif gen:IsA('Tool') and not table.find(newData.Items, gen) then
                    table.insert(newData.Items, gen)
                end
            end
            for _, tool in ipairs(workspace:GetChildren()) do
                if tool:IsA('Tool') and not table.find(newData.Items, tool) then table.insert(newData.Items, tool) end
            end
            for _, obj in ipairs(workspace.Map.Ingame:GetChildren()) do
                if (obj.Name:find('TaphTripwire') or obj.Name == 'SubspaceTripmine') and not table.find(newData.TaphDebris, obj) then
                    table.insert(newData.TaphDebris, obj)
                elseif (obj.Name == 'BuildermanSentry' or obj.Name == 'BuildermanDispenser') and not table.find(newData.BuildermanDebris, obj) then
                    table.insert(newData.BuildermanDebris, obj)
                elseif obj.Name:sub(-7) == 'Shadows' and obj.Name:sub(1,-8) == GetKillerUsername() then
                    for _, shadow in pairs(obj:GetChildren()) do
                        if not table.find(newData.DoeDebris, shadow) then table.insert(newData.DoeDebris, shadow) end
                    end
                elseif obj.Name:sub(-5) == 'Spray' and Players:FindFirstChild(obj.Name:sub(1,-6)) and not table.find(newData.VeeDebris, obj) then
                    table.insert(newData.VeeDebris, obj)
                elseif obj.Name == 'SpikeCollision' and not table.find(newData.Spikes, obj) then
                    table.insert(newData.Spikes, obj)
                elseif (obj.Name == 'VineModel' or obj.Name == 'GroundBulbModel') and not table.find(newData.AzureDebris, obj) then
                    table.insert(newData.AzureDebris, obj)
                end
            end
            if workspace.Map.Ingame:FindFirstChild('CurrencyLocations') then
                for _, cur in ipairs(workspace.Map.Ingame.CurrencyLocations:GetChildren()) do
                    local part = cur:FindFirstChildWhichIsA('Part')
                    if part and part.Position.Y > 0 and not table.find(newData.Gingerbread, cur) then
                        table.insert(newData.Gingerbread, cur)
                    elseif table.find(newData.Gingerbread, cur) and cur[string.format('%sExp', tostring(cur))].Transparency == 1 then
                        table.remove(newData.Gingerbread, table.find(newData.Gingerbread, cur))
                    end
                end
            end
            for k,v in pairs(newData) do GameData[k] = v end
        else
            GameData.RoundGenerators = {}
            GameData.Killers = {}
            GameData.Survivors = {}
            GameData.Items = {}
            GameData.Gingerbread = {}
            GameData.TaphDebris = {}
            GameData.BuildermanDebris = {}
            GameData.DoeDebris = {}
            GameData.VeeDebris = {}
            GameData.AzureDebris = {}
            GameData.Spikes = {}
        end
        scannerReady = true
    end
end)

repeat Wait() until scannerReady

-- ------------------------------------------------------------------
-- AmberCore | 06 / Generator controls
-- ------------------------------------------------------------------
GeneratorsTab:CreateSection('เครื่องปั่นไฟ')

function IsNeighbour(r1,c1,r2,c2)
    return (r2 == r1-1 and c2 == c1) or (r2 == r1+1 and c2 == c1) or (r2 == r1 and c2 == c1-1) or (r2 == r1 and c2 == c1+1)
end
function Key(cell) return cell.row .. '-' .. cell.col end

function OrderPath(cells, targetPairs)
    if not cells or #cells == 0 then return cells end
    local start = targetPairs and targetPairs[1] or cells[1]
    local map = {}
    for _, cell in ipairs(cells) do map[Key(cell)] = {row=cell.row, col=cell.col} end
    local ordered = {}
    local current = {row=start.row, col=start.col}
    table.insert(ordered, current)
    map[Key(current)] = nil
    while next(map) do
        local found = false
        for k, cell in pairs(map) do
            if IsNeighbour(current.row, current.col, cell.row, cell.col) then
                table.insert(ordered, cell)
                map[k] = nil
                current = cell
                found = true
                break
            end
        end
        if not found then break end
    end
    return ordered
end

function AutoGenerator(puzzle, force)
    for i = 1, #puzzle.Solution do
        local solution = puzzle.Solution[i]
        local target = puzzle.targetPairs[i]
        local ordered = OrderPath(solution, target)
        puzzle.paths[i] = {}
        for _, cell in ipairs(ordered) do
            if not force and not Window.Flags.AutoCompleteGenerators.CurrentValue then return end
            table.insert(puzzle.paths[i], {row=cell.row, col=cell.col})
            puzzle:updateGui()
            if Window.Flags.LegitPuzzles.CurrentValue and GetClosestGenerator() and IsPlayerNearGenerator(GetClosestGenerator()) then
                task.wait(Window.Flags.GeneratorLegitPuzzleDelay.CurrentValue)
            else
                task.wait(Window.Flags.GeneratorPuzzleDelay.CurrentValue)
            end
        end
        puzzle:checkForWin()
    end
end

function DrawSolutions(puzzle)
    local gridFrame = puzzle.gridFrame
    local overlay = Instance.new('Frame', gridFrame.Parent)
    overlay.ZIndex = 6
    overlay.BackgroundTransparency = 1
    overlay.Size = gridFrame.Size
    overlay.Position = UDim2.fromScale(0.5,0.5)
    overlay.AnchorPoint = Vector2.new(0.5,0.5)
    local cellScale = PlayerGui.PuzzleUI.Container.GridHolder.Grid.UIGridLayout.CellSize.X.Scale
    for i = 1, #puzzle.Solution do
        local sol = puzzle.Solution[i]
        local ordered = OrderPath(sol, puzzle.targetPairs[i])
        for _, cell in ipairs(ordered) do
            local f = Instance.new('Frame', overlay)
            f.BorderSizePixel = 0
            f.BackgroundTransparency = 0.7
            f.Size = UDim2.fromScale(cellScale, cellScale)
            f.ZIndex = 7
            local col = puzzle.colors[i]
            f.BackgroundColor3 = Color3.new(col.R/1.2, col.G/1.2, col.B/1.2)
            f.Position = UDim2.fromScale(cellScale * (cell.col - 1), cellScale * (cell.row - 1))
        end
        puzzle:checkForWin()
    end
end

local oldFlowNew
oldFlowNew = hookfunction(FlowGameModule.new, newcclosure(function(...)
    local puzzle = oldFlowNew(...)
    GameData.CurrentPuzzle = puzzle
    if Window.Flags.GeneratorHelper.CurrentValue then
        if identifyexecutor() ~= 'Cosmic' then
            local ok, err = pcall(DrawSolutions, puzzle)
            if not ok then warn('Failed to draw puzzle - ' .. tostring(err)) end
        else
            task.spawn(function() DrawSolutions(puzzle) end)
        end
    end
    if Window.Flags.AutoCompleteGenerators.CurrentValue then
        task.spawn(function()
            local t0 = tick()
            local ok, err = pcall(AutoGenerator, puzzle)
            if not ok then warn('Failed to complete generator - ' .. tostring(err)) end
            local elapsed = math.round((tick() - t0) * 100) / 100
            task.spawn(function()
                setthreadidentity(8)
                UILibrary:Notify{Title='ทำเครื่องปั่นไฟอัตโนมัติ', Content=string.format('flow game completed in %ss', tostring(elapsed)), Duration=2, Image='puzzle', NoQueue=true}
            end)
        end)
    end
    return puzzle
end))

task.spawn(function()
    while Wait(0.1) do
        for _, gen in ipairs(GameData.RoundGenerators) do
            local prompt = gen:FindFirstChild('Main') and gen.Main:FindFirstChild('Prompt')
            if not prompt then continue end
            prompt.HoldDuration = (Window.Flags.InstantlyEnterGenerator and Window.Flags.InstantlyEnterGenerator.CurrentValue) and 0 or 0.25
        end
    end
end)

local isCompletingAll = false
function CompleteGenerators()
    if GameData.GameState ~= 1 then return end
    if not IsRoundLoaded() then repeat warn('waiting for load') Wait(1) until IsRoundLoaded() end
    if isCompletingAll then return end
    if IsKiller() then return end
    isCompletingAll = true
    pcall(function()
        for _, gen in ipairs(GameData.RoundGenerators) do
            if not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then continue end
            local function CheckOccupance(pos)
                for _, char in ipairs(GameData.Survivors) do
                    if char:FindFirstChild("HumanoidRootPart") and (char.HumanoidRootPart.Position - pos).Magnitude <= 6 and char ~= LocalPlayer.Character then return true end
                end
                return false
            end
            Wait(0.3)
            if not gen:FindFirstChild("Progress") then continue end
            if gen.Progress.Value == 100 then continue end
            local prompt = gen:FindFirstChild('Main') and gen.Main:FindFirstChild('Prompt')
            if not prompt then continue end
            local start = tick()
            local occCenter, occRight, occLeft = CheckOccupance(gen.Positions.Center.Position), CheckOccupance(gen.Positions.Right.Position), CheckOccupance(gen.Positions.Left.Position)
            if occCenter and occRight and occLeft then continue end
            LocalPlayer.Character.HumanoidRootPart.CFrame = (not occCenter and gen.Positions.Center.CFrame) or (not occRight and gen.Positions.Right.CFrame) or gen.Positions.Left.CFrame
            LocalPlayer.Character.Humanoid:MoveTo(gen.Main.Position)
            repeat fireproximityprompt(prompt) Wait(0.5) until tick() - start >= 7 or LocalPlayer.PlayerGui:FindFirstChild('PuzzleUI')
            if tick() - start >= 7 then warn('timed out waiting for response') continue end
            task.wait(0.4)
            if not (LocalPlayer.PlayerGui:FindFirstChild('PuzzleUI') and LocalPlayer.PlayerGui.PuzzleUI.Enabled) then continue end
            task.spawn(function()
                local lastPuzzle
                while Wait() and gen:FindFirstChild('Progress') and gen.Progress.Value ~= 100 and LocalPlayer.PlayerGui:FindFirstChild('PuzzleUI') do
                    if GameData.CurrentPuzzle == lastPuzzle then continue end
                    lastPuzzle = GameData.CurrentPuzzle
                    if not Window.Flags.AutoCompleteGenerators.CurrentValue then
                        local ok, err = pcall(AutoGenerator, GameData.CurrentPuzzle, true)
                        if not ok then warn('Failed to complete generator (all) - ' .. tostring(err)) end
                    end
                end
            end)
            repeat Wait() until not gen:FindFirstChild('Progress') or gen.Progress.Value == 100 or not LocalPlayer.PlayerGui:FindFirstChild('PuzzleUI')
        end
    end)
    isCompletingAll = false
    UILibrary:Notify{Title="ทำเครื่องปั่นไฟทั้งหมด", Content = "ตรวจสอบเครื่องปั่นไฟทั้งหมดเรียบร้อยแล้ว", Duration=6}
end

GeneratorsTab:CreateToggle{Name='ฟาร์มเครื่องปั่นไฟอัตโนมัติ', CurrentValue=false, Flag='AutoGeneratorFarm', Callback=function(v) if v then CompleteGenerators() end end}
GameStateChanged(function()
    local t0 = tick()
    repeat Wait() until tick() - t0 >= 10 or #GameData.RoundGenerators == 5
    if tick() - t0 >= 10 then return warn("timed out waiting for generators") end
    if Window.Flags.AutoGeneratorFarm.CurrentValue then CompleteGenerators() end
end)

GeneratorsTab:CreateToggle{Name='ทำเครื่องปั่นไฟอัตโนมัติ', CurrentValue=false, Flag='AutoCompleteGenerators', Callback=EmptyCallback}
GeneratorsTab:CreateToggle{Name='ตัวช่วยเครื่องปั่นไฟ', CurrentValue=false, Flag='GeneratorHelper', Callback=EmptyCallback}
GeneratorsTab:CreateToggle{Name='เข้าเครื่องปั่นไฟทันที', CurrentValue=false, Flag='InstantlyEnterGenerator', Callback=EmptyCallback}
GeneratorsTab:CreateButton{Name='ทำเครื่องปั่นไฟปัจจุบัน', Callback=function()
    if LocalPlayer.PlayerGui:FindFirstChild('PuzzleUI') then
        task.spawn(function()
            local gen = GetClosestGenerator()
            if not gen then return end
            local last
            while Wait() and gen:FindFirstChild('Progress') and gen.Progress.Value ~= 100 and LocalPlayer.PlayerGui:FindFirstChild('PuzzleUI') do
                if GameData.CurrentPuzzle == last then continue end
                last = GameData.CurrentPuzzle
                if not Window.Flags.AutoCompleteGenerators.CurrentValue then
                    local ok, err = pcall(AutoGenerator, GameData.CurrentPuzzle, true)
                    if not ok then warn('Failed to complete generator (ccg) - ' .. tostring(err)) end
                end
            end
        end)
    end
end}
GeneratorsTab:CreateButton{Name='ทำเครื่องปั่นไฟทั้งหมด', Callback=CompleteGenerators}
GeneratorsTab:CreateSection('เทเลพอร์ต')
local selectedGenIndex = 1
local genDropdown = GeneratorsTab:CreateDropdown{
    Name='เลือกเครื่องปั่นไฟ',
    Options={'1','2','3','4','5'},
    CurrentOption={'1'},
    Flag='GeneratorSelected',
    Callback=function(v) selectedGenIndex = tonumber(v[1]:sub(1,1)) end
}
GeneratorsTab:CreateButton{Name='เทเลพอร์ตไปเครื่องปั่นไฟ', Callback=function()
    if GameData.RoundGenerators[selectedGenIndex] and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart') then
        LocalPlayer.Character.HumanoidRootPart.CFrame = GameData.RoundGenerators[selectedGenIndex].Positions.Center.CFrame
    end
end}
local __lastGenSig
task.spawn(function()
    while Wait(0.2) do
        local opts, sig = {}, {}
        for i = 1, math.max(5, #GameData.RoundGenerators) do
            local title = tostring(i)
            local gen = GameData.RoundGenerators[i]
            if gen and gen:FindFirstChild('Progress') then title = string.format('%s (%s%%)', tostring(i), tostring(gen.Progress.Value)) end
            opts[i] = { Title = title, Value = tostring(i) }
            sig[i] = title
        end
        local sigText = table.concat(sig, '|')
        if sigText ~= __lastGenSig then
            __lastGenSig = sigText
            pcall(function() genDropdown:Refresh(opts) end)
        end
        local closest = GetClosestGenerator(true)
        if not closest then genDropdown:SetTitle("Select generator")
        else genDropdown:SetTitle(string.format('เลือกเครื่องปั่นไฟ (คุณอยู่ที่ #%s)', tostring(closest))) end
    end
end)
GeneratorsTab:CreateSection('ตั้งค่าเครื่องปั่นไฟ','Right')
GeneratorsTab:CreateSlider{Name='ความเร็วปริศนา', Range={0.02,1}, Increment=0.01, Suffix='s', CurrentValue=0.08, Flag='GeneratorPuzzleDelay', Callback=EmptyCallback}
GeneratorsTab:CreateToggle{Name='ใช้ความเร็วแบบปกติเมื่อมีผู้เล่นอยู่ใกล้', CurrentValue=false, Flag='LegitPuzzles', Callback=EmptyCallback, TextMode=true}
GeneratorsTab:CreateSlider{Name='ความเร็วปริศนา (แบบปกติ)', Range={0.1,2}, Increment=0.01, Suffix='s', CurrentValue=0.08, Flag='GeneratorLegitPuzzleDelay', Callback=EmptyCallback}

-- ===== ADDED: Generator extras (from Skidsaken) =====
GeneratorsTab:CreateToggle{Name='ซ่อน UI ปริศนา', CurrentValue=false, Flag='HidePuzzleUI', Callback=EmptyCallback}
GeneratorsTab:CreateToggle{Name='เปลี่ยนขนาดกริด', CurrentValue=false, Flag='GridSizeChanger', Callback=EmptyCallback}
GeneratorsTab:CreateSlider{Name='ขนาดกริด', Range={3,9}, Increment=1, CurrentValue=5, Flag='GridSize', Callback=EmptyCallback}
GeneratorsTab:CreateToggle{Name='แจ้งเตือนเมื่อทำเสร็จ', CurrentValue=true, Flag='GeneratorNotifications', Callback=EmptyCallback}
GeneratorsTab:CreateToggle{Name='ดีซิงค์ขณะฟาร์ม', CurrentValue=false, Flag='DesyncWhenAutofarming', Callback=EmptyCallback}

-- ------------------------------------------------------------------
-- AmberCore | 07 / Visual overlays
-- ------------------------------------------------------------------
function AddBoxEsp(character, colorFlag, toggleFlag, showHealthBar, showItemText)
    local box = DrawingLib.new('Square')
    box.Visible = false
    box.ZIndex = 2
    box.Filled = false
    local outline = DrawingLib.new('Square')
    outline.Visible = false
    outline.Filled = false
    outline.Color = Color3.new(0,0,0)
    outline.Thickness = 2
    local outline2 = DrawingLib.new('Square')
    outline2.Visible = false
    outline2.Filled = false
    outline2.Color = Color3.new(0,0,0)
    outline2.Thickness = 2
    local healthBar = DrawingLib.new('Square')
    healthBar.Visible = false
    healthBar.ZIndex = 2
    healthBar.Filled = false
    local text = DrawingLib.new('Text')
    text.Visible = false
    text.Color = Color3.new(1,1,1)
    text.Outline = true
    text.Center = true
    text.Font = 2

    local function MapHealthColor(cur, max)
        local t = math.clamp(cur / max, 0, 1)
        return Color3.new(1 - t, t, 0)
    end

    local conn
    conn = RunService.RenderStepped:Connect(function()
        if identifyexecutor() == "Cosmic" then setthreadidentity(8) end
        outline.Visible = box.Visible
        if not showHealthBar then healthBar.Visible = false end
        if character and character.Parent and character:FindFirstChild('HumanoidRootPart') and character:FindFirstChild('Head') and character:FindFirstChild('Humanoid') and character.Humanoid.Health > 0 then
            local hrp = character.HumanoidRootPart
            local _, onScreen = CurrentCamera:WorldToViewportPoint(hrp.Position)
            if onScreen and Window.Flags[toggleFlag].CurrentValue then
                box.Visible = true
                if showHealthBar then
                    outline2.Visible = true
                    healthBar.Visible = true
                end
                if showItemText then
                    text.Visible = true
                    text.Text = (function()
                        local plr = Players:GetPlayerFromCharacter(character)
                        if not plr then return '' end
                        local pack = plr.Backpack
                        if pack:FindFirstChild('BloxyCola') and not pack:FindFirstChild('Medkit') then return 'Bloxy Cola'
                        elseif pack:FindFirstChild('Medkit') and not pack:FindFirstChild('BloxyCola') then return 'Medkit'
                        elseif pack:FindFirstChild('BloxyCola') and pack:FindFirstChild('Medkit') then return 'Medkit & Bloxy Cola' end
                        return ''
                    end)()
                end
            else
                box.Visible = false
                outline2.Visible = false
                healthBar.Visible = false
                text.Visible = false
                return
            end
            local hrp = character.HumanoidRootPart
            local hum = character.Humanoid
            local screenPos = CurrentCamera:WorldToViewportPoint(hrp.Position)
            local top = CurrentCamera:WorldToViewportPoint((CFrame.lookAlong(hrp.Position, CurrentCamera.CFrame.LookVector) * CFrame.new(2, hum.HipHeight, 0)).p)
            local bottom = CurrentCamera:WorldToViewportPoint((CFrame.lookAlong(hrp.Position, CurrentCamera.CFrame.LookVector) * CFrame.new(-2, -hum.HipHeight - 1, 0)).p)
            local w, h = top.X - bottom.X, top.Y - bottom.Y
            local x, y = screenPos.X - w / 1.5, screenPos.Y - h / 1.5
            box.Position = Vector2.new(x + w/2, y - h)
            box.Size = Vector2.new(w/2, h*4.5)
            box.Color = Window.Flags[colorFlag].Color
            outline.Size = box.Size
            outline.Position = box.Position
            healthBar.Position = box.Position - Vector2.new(6,0)
            healthBar.Size = Vector2.new(0, box.Size.Y / (character.Humanoid.MaxHealth / character.Humanoid.Health))
            healthBar.Color = MapHealthColor(character.Humanoid.Health, character.Humanoid.MaxHealth)
            outline2.Size = Vector2.new(healthBar.Size.X, box.Size.Y)
            outline2.Position = healthBar.Position
            text.Position = box.Position + Vector2.new(box.Size.X/2, 0)
            text.Position = Vector2.new(text.Position.X, box.Position.Y + 13)
        else
            if not character.Parent then
                conn:Disconnect()
                box:Destroy()
                outline:Destroy()
                outline2:Destroy()
                healthBar:Destroy()
                text:Destroy()
            end
            box.Visible = false
            outline2.Visible = false
            healthBar.Visible = false
            text.Visible = false
        end
    end)
end

function AddHighlightEsp(instance, colorFlag, checkProgress, customName)
    local hl = Instance.new('Highlight', instance)
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Name = customName or "Highlight"
    local hasAppliedImage = false
    RunService.RenderStepped:Connect(function()
        local col = Window.Flags[colorFlag].Color
        local h,s,v = col:ToHSV()
        v = v + (1 - v) * 0.5
        s = s * 0.5
        hl.OutlineColor = Color3.fromHSV(h,s,v)
        hl.FillColor = col
        if checkProgress and instance.Parent and instance:FindFirstChild('Progress') and instance.Progress.Value == 100 and not hasAppliedImage then
            ApplyConstantImage(instance.Positions.Center, 'rbxassetid://115758393579036')
            hasAppliedImage = true
        end
    end)
end

EspTab:CreateSection('สวิตช์มองทะลุ')
EspTab:CreateToggle{Name='มองทะลุเครื่องปั่นไฟ', CurrentValue=false, Flag='GeneratorEsp', Callback=EmptyCallback}
EspTab:CreateToggle{Name='มองทะลุฆาตกร', CurrentValue=false, Flag='KillerEsp', Callback=EmptyCallback}
EspTab:CreateToggle{Name='มองทะลุผู้รอดชีวิต', CurrentValue=false, Flag='SurvivorEsp', Callback=EmptyCallback}
EspTab:CreateToggle{Name='มองทะลุไอเทม', CurrentValue=false, Flag='ItemEsp', Callback=EmptyCallback}
EspTab:CreateToggle{Name='มองทะลุขนมปังขิง [ปิดใช้งาน]', CurrentValue=false, Flag='GingerbreadEsp', Callback=EmptyCallback}
EspTab:CreateToggle{Name='มองทะลุซุคการ์ [ปิดใช้งาน]', CurrentValue=false, Flag='SukkarEsp', Callback=EmptyCallback}
EspTab:CreateToggle{Name='มองทะลุซอมบี้/มินเนียน', CurrentValue=false, Flag='EntityEsp', Callback=EmptyCallback}
EspTab:CreateToggle{Name='มองทะลุทัพ', CurrentValue=false, Flag='TaphEsp', Callback=EmptyCallback}
EspTab:CreateToggle{Name='มองทะลุบิลเดอร์แมน', CurrentValue=false, Flag='BuildermanEsp', Callback=EmptyCallback}
EspTab:CreateToggle{Name='มองทะลุจอห์นโด', CurrentValue=false, Flag='JohnDoeEsp', Callback=EmptyCallback}
EspTab:CreateToggle{Name='มองทะลุวีโรนิก้า', CurrentValue=false, Flag='VeeronicaEsp', Callback=EmptyCallback}
EspTab:CreateToggle{Name='มองทะลุอัซเชอร์', CurrentValue=false, Flag='AzureEsp', Callback=EmptyCallback}
EspTab:CreateSection('สีมองทะลุ','Right')
EspTab:CreateColorPicker{Name='สีเครื่องปั่นไฟ', Color=Color3.fromRGB(221,51,255), Flag='GeneratorEspColor', Callback=EmptyCallback}
EspTab:CreateColorPicker{Name='สีฆาตกร', Color=Color3.fromRGB(255,0,0), Flag='KillerEspColor', Callback=EmptyCallback}
EspTab:CreateColorPicker{Name='สีผู้รอดชีวิต', Color=Color3.fromRGB(0,0,255), Flag='SurvivorEspColor', Callback=EmptyCallback}
EspTab:CreateColorPicker{Name='สีไอเทม', Color=Color3.fromRGB(0,255,255), Flag='ItemEspColor', Callback=EmptyCallback}
EspTab:CreateColorPicker{Name='สีขนมปังขิง', Color=Color3.fromRGB(255,50,204), Flag='GingerbreadEspColor', Callback=EmptyCallback}
EspTab:CreateColorPicker{Name='สีซอมบี้/มินเนียน', Color=Color3.fromRGB(255,159,0), Flag='EntityEspColor', Callback=EmptyCallback}
EspTab:CreateColorPicker{Name='สีทัพ', Color=Color3.fromRGB(75,255,145), Flag='TaphEspColor', Callback=EmptyCallback}
EspTab:CreateColorPicker{Name='สีบิลเดอร์แมน', Color=Color3.fromRGB(157,255,0), Flag='BuildermanEspColor', Callback=EmptyCallback}
EspTab:CreateColorPicker{Name='สีจอห์นโด', Color=Color3.fromRGB(0,0,0), Flag='JohnDoeEspColor', Callback=EmptyCallback}
EspTab:CreateColorPicker{Name='สีวีโรนิก้า', Color=Color3.fromRGB(255,0,242), Flag='VeeronicaEspColor', Callback=EmptyCallback}
EspTab:CreateColorPicker{Name='สีอัซเชอร์', Color=Color3.fromRGB(255,255,255), Flag='AzureEspColor', Callback=EmptyCallback}

-- ===== ADDED: ESP extras (from Skidsaken) =====
EspTab:CreateToggle{Name='เฉพาะเส้นโครงร่าง', CurrentValue=false, Flag='EspOutlinesOnly', Callback=EmptyCallback}
EspTab:CreateToggle{Name='ไม่แสดงเส้นโครงร่าง', CurrentValue=false, Flag='EspNoOutlines', Callback=EmptyCallback}
EspTab:CreateToggle{Name='แสดงระยะหลอดไฟ/เถา (อัซเชอร์)', CurrentValue=false, Flag='AzureBulbVineRanges', Callback=EmptyCallback, TextMode=true}
EspTab:CreateToggle{Name='มองทะลุเควสเจนโด', CurrentValue=false, Flag='JaneDoeQuestEsp', Callback=EmptyCallback}
EspTab:CreateToggle{Name='มองทะลุคูลดาวน์สกิล', CurrentValue=false, Flag='CooldownEsp', Callback=EmptyCallback}
EspTab:CreateColorPicker{Name='สีเควส', Color=Color3.fromRGB(255,255,0), Flag='QuestEspColor', Callback=EmptyCallback}

for _, char in ipairs(GameData.Killers) do if char:GetAttribute("Username") ~= LocalPlayer.Name then AddBoxEsp(char, 'KillerEspColor', 'KillerEsp') end end
KillersFolder.ChildAdded:Connect(function(char) if char:GetAttribute("Username") ~= LocalPlayer.Name then AddBoxEsp(char, 'KillerEspColor', 'KillerEsp') end end)
for _, char in ipairs(GameData.Survivors) do if char:GetAttribute("Username") ~= LocalPlayer.Name then AddBoxEsp(char, 'SurvivorEspColor', 'SurvivorEsp', true, true) end end
SurvivorsFolder.ChildAdded:Connect(function(char) if char:GetAttribute("Username") ~= LocalPlayer.Name then AddBoxEsp(char, 'SurvivorEspColor', 'SurvivorEsp', true, true) end end)

task.spawn(function()
    while Wait(0.1) do
        for _, gen in ipairs(GameData.RoundGenerators) do
            if isUnloaded then return end
            if not Window.Flags.GeneratorEsp.CurrentValue then
                local hl = gen:FindFirstChildOfClass('Highlight')
                if hl then hl:Destroy() end
                for img, data in pairs(GameData.ConstantImages) do
                    if data.Handle == gen.Positions.Center then
                        data.Connection:Disconnect()
                        img:Destroy()
                        GameData.ConstantImages[img] = nil
                        ConstantImageMap[data.Handle] = nil
                    end
                end
                GameData.EspAppliedToGenerators[gen] = false
                continue
            end
            if GameData.EspAppliedToGenerators[gen] then continue end
            GameData.EspAppliedToGenerators[gen] = true
            AddHighlightEsp(gen, 'GeneratorEspColor', true)
        end
        for _, item in ipairs(GameData.Items) do
            if isUnloaded then return end
            if not Window.Flags.ItemEsp.CurrentValue then
                local hl = item:FindFirstChildOfClass('Highlight')
                if hl then hl:Destroy() end
                GameData.EspAppliedToItems[item] = false
                continue
            end
            if GameData.EspAppliedToItems[item] then continue end
            GameData.EspAppliedToItems[item] = true
            AddHighlightEsp(item, 'ItemEspColor')
        end
        for _, obj in ipairs(GameData.TaphDebris) do
            if not Window.Flags.TaphEsp.CurrentValue then
                local hl = obj:FindFirstChildOfClass('Highlight')
                if hl then hl:Destroy() end
                GameData.EspAppliedToTaphDebris[obj] = false
                continue
            end
            if GameData.EspAppliedToTaphDebris[obj] then continue end
            GameData.EspAppliedToTaphDebris[obj] = true
            AddHighlightEsp(obj, 'TaphEspColor')
        end
        for _, obj in ipairs(GameData.BuildermanDebris) do
            if not Window.Flags.BuildermanEsp.CurrentValue then
                local hl = obj:FindFirstChildOfClass('Highlight')
                if hl then hl:Destroy() end
                GameData.EspAppliedToBuildermanDebris[obj] = false
                continue
            end
            if GameData.EspAppliedToBuildermanDebris[obj] then continue end
            GameData.EspAppliedToBuildermanDebris[obj] = true
            AddHighlightEsp(obj, 'BuildermanEspColor')
        end
        for _, obj in ipairs(GameData.DoeDebris) do
            if not Window.Flags.JohnDoeEsp.CurrentValue then
                local hl = obj:FindFirstChild('Highlight')
                if hl then hl:Destroy() end
                GameData.EspAppliedToDoeDebris[obj] = false
                continue
            end
            if obj:FindFirstChild("PlayerAura") then obj.PlayerAura:Destroy() end
            if GameData.EspAppliedToDoeDebris[obj] then continue end
            GameData.EspAppliedToDoeDebris[obj] = true
            obj.Transparency = 0
            AddHighlightEsp(obj, 'JohnDoeEspColor')
        end
        for _, obj in ipairs(GameData.VeeDebris) do
            if not Window.Flags.VeeronicaEsp.CurrentValue then
                local hl = obj:FindFirstChildOfClass('Highlight')
                if hl then hl:Destroy() end
                GameData.EspAppliedToVeeDebris[obj] = false
                continue
            end
            if GameData.EspAppliedToVeeDebris[obj] then continue end
            GameData.EspAppliedToVeeDebris[obj] = true
            AddHighlightEsp(obj, 'VeeronicaEspColor')
        end
        for _, obj in ipairs(GameData.AzureDebris) do
            if not Window.Flags.AzureEsp.CurrentValue then
                if obj:FindFirstChild('AZUREHIGHLIGHT') then obj.AZUREHIGHLIGHT:Destroy() end
                GameData.EspAppliedToAzureDebris[obj] = false
                continue
            end
            if GameData.EspAppliedToAzureDebris[obj] then continue end
            GameData.EspAppliedToAzureDebris[obj] = true
            AddHighlightEsp(obj, 'AzureEspColor', false, 'AZUREHIGHLIGHT')
        end
    end
end)

-- ------------------------------------------------------------------
-- AmberCore | 08 / Stamina controls
-- ------------------------------------------------------------------
StaminaTab:CreateSection('แสตมินาไม่จำกัด')
function UpdateStamina()
    if GameData.GameState ~= 1 then return end
    if not SprintingModule.__staminaChangedEvent then return end
    SprintingModule.__staminaChangedEvent:Fire()
end
local staminaDefaults = {
    MaxStamina = tostring(SprintingModule.DefaultConfig.MaxStamina),
    StaminaLoss = tostring(SprintingModule.DefaultConfig.StaminaLoss),
    StaminaGain = tostring(SprintingModule.DefaultConfig.StaminaGain)
}
StaminaTab:CreateToggle{Name='แสตมินาไม่จำกัด', CurrentValue=false, Flag='UnlimitedRunning', Callback=function()
    task.spawn(function()
        while Wait() do
            if not Window.Flags.UnlimitedRunning.CurrentValue then return end
            if SprintingModule.Stamina < SprintingModule.MaxStamina then
                SprintingModule.Stamina = SprintingModule.MaxStamina
                UpdateStamina()
            end
        end
    end)
end}
StaminaTab:CreateSection('การตั้งค่าแสตมินาใช้ร่วมกับแสตมินาไม่จำกัดไม่ได้','Right')
StaminaTab:CreateInput{Name='แสตมินาสูงสุด', CurrentValue=staminaDefaults.MaxStamina, PlaceholderText='ตัวเลข', Flag='StaminaOptions_MaxStamina', Callback=function(v)
    if not tonumber(v) then return UILibrary:Notify{Title='กรุณากรอกตัวเลข', Content = 'เพื่อเปลี่ยนแสตมินาสูงสุด', Duration=6.5} end
    staminaDefaults.MaxStamina = v
end}
StaminaTab:CreateInput{Name='การเสียแสตมินา', CurrentValue=staminaDefaults.StaminaLoss, PlaceholderText='ตัวเลข', Flag='StaminaOptions_StaminaLoss', Callback=function(v)
    if not tonumber(v) then return UILibrary:Notify{Title='กรุณากรอกตัวเลข', Content = 'เพื่อเปลี่ยนการเสียแสตมินา', Duration=6.5} end
    staminaDefaults.StaminaLoss = v
end}
StaminaTab:CreateInput{Name='การได้แสตมินาคืน', CurrentValue=staminaDefaults.StaminaGain, PlaceholderText='ตัวเลข', Flag='StaminaOptions_StaminaGain', Callback=function(v)
    if not tonumber(v) then return UILibrary:Notify{Title='กรุณากรอกตัวเลข', Content = 'เพื่อเปลี่ยนการได้แสตมินาคืน', Duration=6.5} end

-- ===== ADDED: Stamina extras (from Skidsaken) =====
StaminaTab:CreateToggle{Name='วิ่งเร็วพิเศษ (เตือนการเตะ)', CurrentValue=false, Flag='FastSprint', Callback=EmptyCallback}
StaminaTab:CreateSlider{Name='└── ความเร็ว', Range={1,3}, Increment=0.1, Suffix='x', CurrentValue=1.5, Flag='FastSprintSpeed', Callback=EmptyCallback}
StaminaTab:CreateToggle{Name='ฟื้นแสตมินาทันที', CurrentValue=false, Flag='InstantStaminaRecovery', Callback=EmptyCallback}
    staminaDefaults.StaminaGain = v
end}
task.spawn(function()
    while Wait() do
        for k,v in pairs(staminaDefaults) do
            if SprintingModule[k] ~= tonumber(v) then
                SprintingModule[k] = tonumber(v)
                UpdateStamina()
            end
        end
    end
end)

-- ------------------------------------------------------------------
-- AmberCore | 09 / Aim controls
-- ------------------------------------------------------------------
local silentAimSelected = {}
local aimbotSelected = {}

AimbotTab:CreateSection('ซายเลนต์เอมช่วยให้โจมตีโดนเป้าโดยไม่ต้องเล็ง')
AimbotTab:CreateToggle{Name='เปิดซายเลนต์เอม', CurrentValue=false, Flag='SilentAimToggle', Callback=EmptyCallback}
AimbotTab:CreateDropdown{
    Name='สกิลที่ใช้ซายเลนต์เอม',
    Options={'Plasma beam - Dusekkar','Void Star - Noli','Corrupt Nature - Coolkid'},
    CurrentOption={}, MultipleOptions=true, Flag='SilentAimValues',
    Callback=function(opts)
        silentAimSelected = {}
        for _, v in ipairs(opts) do silentAimSelected[v:match("^(.-)%s*%-")] = true end
    end
}
AimbotTab:CreateToggle{Name='ดูสคาร์เล็งไปที่ผู้รอดชีวิต', CurrentValue=false, Flag='DusekkarSurvivor', Callback=EmptyCallback, TextMode=true}

local oldGetMousePos
oldGetMousePos = hookfunction(GetMousePos, newcclosure(function(...)
    local closestKiller = GetClosestToMouse('Killer')
    local closestSurvivor = GetClosestToMouse('Survivor')
    if GameData.DusekkarActive and Window.Flags.SilentAimToggle.CurrentValue and silentAimSelected['Plasma beam'] then
        if Window.Flags.DusekkarSurvivor.CurrentValue and closestSurvivor then
            return Predict(closestSurvivor)
        elseif closestKiller then
            return Predict(closestKiller)
        end
    elseif GameData.NoliActive and Window.Flags.SilentAimToggle.CurrentValue and silentAimSelected['Void Star'] and closestSurvivor then
        local hrp = closestSurvivor:FindFirstChild("HumanoidRootPart")
        local ray = workspace:Raycast(hrp.Position, Vector3.new(0,-1000,0), RaycastParams.new())
        return (ray and ray.Position) or hrp.Position
    elseif GameData.CoolkidActive and Window.Flags.SilentAimToggle.CurrentValue and silentAimSelected['Corrupt Nature'] and closestSurvivor then
        return Predict(closestSurvivor)
    end
    return oldGetMousePos(...)
end))

AimbotTab:CreateSection('เล็งอัตโนมัติ','Right')
AimbotTab:CreateToggle{Name='เปิดเล็งอัตโนมัติ', CurrentValue=false, Flag='AimbotToggle', Callback=EmptyCallback}
AimbotTab:CreateDropdown{
    Name='สกิลที่ใช้เล็งอัตโนมัติ',
    Options={'Entanglement - 1x1x1x1','Mass Infection - 1x1x1x1','Throw Pizza - Elliot','Blood Hook - Nosferatu','One Shot - Chance','Corrupt Energy - John Doe','Enstrangle - Azure'},
    CurrentOption={}, MultipleOptions=true, Flag='AimbotValues',
    Callback=function(opts)
        aimbotSelected = {}
        for _, v in ipairs(opts) do aimbotSelected[v:match("^(.-)%s*%-")] = true end
    end
}
AimbotTab:CreateToggle{Name='ช่วยเหลือการโจมตี M1', CurrentValue=false, Flag='Mouse1Aimbot', Callback=EmptyCallback}

-- ===== ADDED: Aimbot extras (from Skidsaken) =====
AimbotTab:CreateToggle{Name='โอกาส 360 no-scope', CurrentValue=false, Flag='Chance360NoScope', Callback=EmptyCallback}
AimbotTab:CreateSlider{Name='ระยะ Void Rush', Range={10,100}, Increment=5, CurrentValue=30, Flag='VoidRushAimRange', Callback=EmptyCallback}
AimbotTab:CreateSlider{Name='ระยะ Walkspeed Override', Range={10,100}, Increment=5, CurrentValue=30, Flag='WSOAimRange', Callback=EmptyCallback}
AimbotTab:CreateSlider{Name='ระยะ Charge', Range={10,100}, Increment=5, CurrentValue=30, Flag='ChargeAimRange', Callback=EmptyCallback}

function MassInfectionActive() return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('SpeedMultipliers') and LocalPlayer.Character.SpeedMultipliers:FindFirstChild('MassInfection') end
function EntanglementActive() return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('SpeedMultipliers') and LocalPlayer.Character.SpeedMultipliers:FindFirstChild('Entanglement') end
function ElliotHasPizza() return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('Pizza') and LocalPlayer.Character.Pizza.Transparency == 0 end
function AzureAimingEnstrangle() return LocalPlayer.Character and LocalPlayer.Character.Name == 'Azure' and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart:FindFirstChild("Attachment") end

task.spawn(function()
    while task.wait() do
        if aimbotSelected.Enstrangle and AzureAimingEnstrangle() then
            local target = GetClosestSurvivor(25)
            if target then
                StartAimbotting(target, function() return AzureAimingEnstrangle() end, nil, math.huge)
                task.wait(1.6)
            end
        end
    end
end)

function stareFunc(target)
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild('HumanoidRootPart')
    local targetRoot = target and target:FindFirstChild('HumanoidRootPart')
    if not myRoot or not targetRoot then return end
    if myRoot.Anchored or targetRoot.Anchored then return end
    local pos = myRoot.Position
    myRoot.CFrame = CFrame.new(pos, Vector3.new(targetRoot.Position.X, pos.Y, targetRoot.Position.Z))
end

NetworkFolder.RemoteEvent.OnClientEvent:Connect(function(...)
    local args = {...}
    if args[1] == "UseActorAbility" then
        local data = args[2]
        if type(data) == "table" and typeof(data[1]) == "buffer" then
            local closest130 = GetClosestSurvivor(130)
            local closest90Killer = GetClosestKiller(90)
            local closest5000Killer = GetClosestKiller(5000)
            local closest25 = GetClosestSurvivor(25)
            local closest95 = GetClosestSurvivor(95)
            local closest10 = LocalPlayer.Character and ((IsKiller() and GetClosestSurvivor(10)) or (LocalPlayer.Character.Name == 'Shedletsky' and GetClosestKiller(10)))
            if IsKiller() and Window.Flags.AutoFarmSurvivors.CurrentValue then closest10 = nil end

            local bufStr = buffer.tostring(data[1])
            if bufStr:find('MassInfection') and aimbotSelected['Mass Infection'] and Window.Flags.AimbotToggle.CurrentValue and closest130 and not CheckInvis() then
                StartAimbotting(closest130, MassInfectionActive)
            elseif bufStr:find('Entanglement') and aimbotSelected.Entanglement and Window.Flags.AimbotToggle.CurrentValue and closest130 and not CheckInvis() then
                StartAimbotting(closest130, EntanglementActive)
            elseif bufStr:find('Uppercut') and aimbotSelected['Blood Hook'] and Window.Flags.AimbotToggle.CurrentValue and closest95 and not CheckInvis() then
                local t0 = tick()
                StartAimbotting(closest95, function() return tick() - t0 <= 2 and IsKiller() end)
            elseif bufStr:find('ThrowPizza') and aimbotSelected['Throw Pizza'] and Window.Flags.AimbotToggle.CurrentValue and closest25 and not CheckInvis() then
                StartAimbotting(closest25, ElliotHasPizza, function()
                    local myRoot = LocalPlayer.Character.HumanoidRootPart
                    local targetRoot = closest25.HumanoidRootPart
                    local left = myRoot.CFrame * Vector3.new(-1,0,0)
                    local dir = (targetRoot.Position - left).Unit
                    return CFrame.lookAt(CurrentCamera.CFrame.Position, CurrentCamera.CFrame.Position + dir)
                end)
            elseif bufStr:find('Shoot') and ((aimbotSelected['One Shot'] and Window.Flags.AimbotToggle.CurrentValue) or Window.Flags.TPOneShot.CurrentValue) and LocalPlayer.Character.Name == 'Chance' and (Window.Flags.TPOneShot.CurrentValue and closest5000Killer or closest90Killer) and not CheckInvis() then
                local target = Window.Flags.TPOneShot.CurrentValue and closest5000Killer or closest90Killer
                local t0 = tick()
                local myRoot = LocalPlayer.Character.HumanoidRootPart
                local targetRoot = target.HumanoidRootPart
                local saved = myRoot.CFrame
                if Window.Flags.TPOneShot.CurrentValue then PlayerControls:Disable() end
                StartAimbotting(target, function() return tick() - t0 <= 2 end, function()
                    if Window.Flags.TPOneShot.CurrentValue then myRoot.CFrame = targetRoot.CFrame - (targetRoot.CFrame.LookVector * 4) end
                    local left = myRoot.CFrame * Vector3.new(-1,0,0)
                    local dir = (targetRoot.Position - left).Unit
                    return CFrame.lookAt(CurrentCamera.CFrame.Position, CurrentCamera.CFrame.Position + dir)
                end)
                if Window.Flags.TPOneShot.CurrentValue then myRoot.CFrame = saved end
                PlayerControls:Enable()
            elseif bufStr:find('Dagger') and Window.Flags.TPDagger.CurrentValue and closest5000Killer and not CheckInvis() then
                PlayerControls:Disable()
                local t0 = tick()
                local myRoot = LocalPlayer.Character.HumanoidRootPart
                local targetRoot = closest5000Killer.HumanoidRootPart
                local saved = myRoot.CFrame
                while tick() - t0 <= 2 and LocalPlayer.Character and LocalPlayer.Character.Parent == SurvivorsFolder and not HasNotification('tabbed') and not CheckInvis() do
                    myRoot.CFrame = targetRoot.CFrame - (targetRoot.CFrame.LookVector * 2)
                    task.wait()
                end
                myRoot.CFrame = saved
                PlayerControls:Enable()
                LocalPlayer.Character.Humanoid:MoveTo(saved.Position)
            elseif bufStr:find('Slash') and Window.Flags.TPSlash.CurrentValue and closest5000Killer and LocalPlayer.Character.Parent == SurvivorsFolder and not CheckInvis() then
                PlayerControls:Disable()
                local t0 = tick()
                local myRoot = LocalPlayer.Character.HumanoidRootPart
                local targetRoot = closest5000Killer.HumanoidRootPart
                local saved = myRoot.CFrame
                while tick() - t0 <= 1 and LocalPlayer.Character and LocalPlayer.Character.Parent == SurvivorsFolder and not HasNotification('stunned') and not CheckInvis() do
                    myRoot.CFrame = targetRoot.CFrame
                    task.wait()
                end
                myRoot.CFrame = saved
                PlayerControls:Enable()
            elseif bufStr:find('CorruptEnergy') and aimbotSelected['Corrupt Energy'] and Window.Flags.AimbotToggle.CurrentValue and closest95 then
                local t0 = tick()
                StartAimbotting(closest95, function() return tick() - t0 <= (JohnDoeConfig.DelayBetweenSpikeSummons * JohnDoeConfig.SpikeAmount) + JohnDoeConfig.CorruptEnergyWindup and IsKiller() end)
            elseif bufStr:find(GetM1Name()) and Window.Flags.Mouse1Aimbot.CurrentValue and closest10 and not (HasNotification('stunned') or HasNotification('you tried')) and not CheckInvis() then
                local t0 = tick()
                while closest10.Parent and tick() - t0 <= 0.66 and LocalPlayer.Character and (LocalPlayer.Character.Parent == KillersFolder or LocalPlayer.Character.Parent == SurvivorsFolder) and task.wait() do
                    stareFunc(closest10)
                end
            end
        end
    end
end)

HitboxTab:CreateSection('ขยายฮิตบ็อกซ์')
HitboxTab:CreateToggle{Name='เปิดการขยายฮิตบ็อกซ์', CurrentValue=false, Flag='HitboxExpander', Callback=EmptyCallback}
HitboxTab:CreateSlider{Name='ระยะ', Range={30,200}, Increment=1, CurrentValue=60, Flag='HitboxExpanderRange', Callback=EmptyCallback}
HitboxTab:CreateSection('ตัวแสดงฮิตบ็อกซ์ (กินทรัพยากรสูง)','Right')
HitboxTab:CreateLabel('หากต้องการดูฮิตบ็อกซ์ ให้เปิดจากการตั้งค่าในเกม\nยิ่งค่าความโปร่งใสสูง ยิ่งมองเห็นน้อย')
HitboxTab:CreateToggle{Name='เปิดการปรับแต่งตัวแสดงผล', CurrentValue=false, Flag='HitboxModifications', Callback=EmptyCallback}
local materials = {}
for i, mat in ipairs(Enum.Material:GetEnumItems()) do materials[i] = tostring(mat):split('.')[3] end
table.sort(materials)
HitboxTab:CreateDropdown{Name='วัสดุ', Options=materials, CurrentOption={'Plastic'}, Flag='HitboxMaterialValue', Callback=EmptyCallback}
HitboxTab:CreateColorPicker{Name='สีฮิตบ็อกซ์', Color=Color3.new(1,0.25,0.25), Flag='HitboxColor', Callback=EmptyCallback}
HitboxTab:CreateColorPicker{Name='สีฮิตบ็อกซ์ (โดนโจมตี)', Color=Color3.new(0.5,1,0.5), Flag='HitboxHitColor', Callback=EmptyCallback}
HitboxTab:CreateSlider{Name='ความโปร่งใสฮิตบ็อกซ์', Range={0,1}, Increment=0.02, CurrentValue=1, Flag='HitboxTransparency', Callback=EmptyCallback}
HitboxTab:CreateSlider{Name='ความโปร่งใสฮิตบ็อกซ์ (โดนโจมตี)', Range={0,1}, Increment=0.02, CurrentValue=1, Flag='HitboxHitTransparency', Callback=EmptyCallback}

workspace.Hitboxes.ChildAdded:Connect(function(hitbox)
    if not Window.Flags.HitboxModifications.CurrentValue then return end
    local mat = Enum.Material[Window.Flags.HitboxMaterialValue.CurrentOption[1]]
    local originalColor = hitbox.Color
    while hitbox.Parent and Wait() do
        hitbox.Material = mat
        if originalColor.R ~= 1 then
            hitbox.Color = Window.Flags.HitboxHitColor.Color
            hitbox.Transparency = Window.Flags.HitboxHitTransparency.CurrentValue
        else
            hitbox.Color = Window.Flags.HitboxColor.Color
            hitbox.Transparency = Window.Flags.HitboxTransparency.CurrentValue
        end
    end
end)

task.spawn(function()
    local rnd = Random.new()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")
    LocalPlayer.CharacterAdded:Connect(function(c)
        char = c
        hum = c:WaitForChild("Humanoid")
        root = c:WaitForChild("HumanoidRootPart")
    end)
    while Wait() do
        if Window.Flags.HitboxExpander.CurrentValue and root then
            local isAttacking = false
            for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
                if table.find(GameData.AttackAnimations, track.Animation.AnimationId) and track.TimePosition / track.Length < 0.75 then
                    isAttacking = true
                    break
                end
            end
            if isAttacking then
                local target, bestDist = nil, Window.Flags.HitboxExpanderRange.CurrentValue
                local function scanGroup(group)
                    for _, obj in ipairs(group) do
                        if obj ~= char and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
                            local d = (obj.HumanoidRootPart.Position - root.Position).Magnitude
                            if d < bestDist then bestDist = d target = obj end
                        end
                    end
                end
                scanGroup(workspace.Players:GetDescendants())
                local npcs = workspace:FindFirstChild("Map", true) and workspace.Map:FindFirstChild("NPCs", true)
                if npcs then scanGroup(npcs:GetChildren()) end
                if target then
                    local ping = tonumber(Stats.PerformanceStats.Ping:GetValue()) / 1000
                    local offset = Vector3.new(rnd:NextNumber(-1.5,1.5), 0, rnd:NextNumber(-1.5,1.5))
                    local predicted = target.HumanoidRootPart.Position + offset + target.HumanoidRootPart.Velocity * (ping * 1.25)
                    local vel = (predicted - root.Position) / (ping * 2)
                    local old = root.Velocity
                    root.Velocity = vel
                    RunService.RenderStepped:Wait()
                    root.Velocity = old
                end
            end
        end
    end
end)

-- ------------------------------------------------------------------
-- AmberCore | 10 / Convenience controls
-- ------------------------------------------------------------------
ConvenienceTab:CreateSection('ฟีเจอร์ความสะดวก')
ConvenienceTab:CreateToggle{Name='ปิดความเร็วตามทิศทาง', CurrentValue=false, Flag='DisableDirectionalSpeed', Callback=function(v)
    if v then DirectionalSpeed:Destroy() else DirectionalSpeed:Start() end
end}
ConvenienceTab:CreateToggle{Name='ปิดการเคลื่อนที่ตามทิศทาง', CurrentValue=false, Flag='DisableDirectionalMovement', Callback=function(v)
    if v then
        task.spawn(function()
            while Wait() do
                if LocalPlayer.Character and Window.Flags.DisableDirectionalMovement.CurrentValue then
                    LocalPlayer.Character:SetAttribute('DirectionalMovementDisabled', true)
                end
            end
        end)
    elseif LocalPlayer.Character then
        LocalPlayer.Character:SetAttribute('DirectionalMovementDisabled', false)
    end
end}
ConvenienceTab:CreateToggle{Name='ต้านการทำลายโล่ดูสคาร์', CurrentValue=false, Flag='ProtectionBreak', Callback=EmptyCallback}
ConvenienceTab:CreateToggle{Name='เพิ่มความเร็ว', CurrentValue=false, Flag='SmallSpeedBoost', Callback=function()
    task.spawn(function()
        while Wait() and Window.Flags.SmallSpeedBoost.CurrentValue do
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild('HumanoidRootPart')
            local hum = char and char:FindFirstChild('Humanoid')
            if GameData.GameState == 1 and hum and root and root.Velocity.Magnitude > 1 then
                char:TranslateBy(hum.MoveDirection * 7 * RunService.RenderStepped:Wait())
            end
        end
    end)
end}
ConvenienceTab:CreateToggle{Name='กลับล็อบบี้อัตโนมัติ', CurrentValue=false, Flag='AutoLobby', Callback=function()
    task.spawn(function()
        while Wait() and Window.Flags.AutoLobby.CurrentValue do
            local ret = LocalPlayer.PlayerGui:FindFirstChild('EndScreen') and LocalPlayer.PlayerGui.EndScreen:FindFirstChild('Main') and LocalPlayer.PlayerGui.EndScreen.Main:FindFirstChild('Return')
            if ret then firesignal(ret.MouseButton1Click) end
        end
    end)
end}
ConvenienceTab:CreateToggle{Name='แสดงแถบข้างตลอด', CurrentValue=false, Flag='SidebarVisibility', Callback=function(v)
    task.spawn(function()
        if GameData.GameState == 1 and not v then
            if PlayerInfoUI then PlayerInfoUI.Position = UDim2.new(0,20,1,-20) end
            return SidebarHandler:ToggleSidebarButtons(false)
        end
        while Wait() and Window.Flags.SidebarVisibility.CurrentValue do
            if SidebarHandler.MenusHidden then
                if PlayerInfoUI then PlayerInfoUI.Position = UDim2.new(0,100,1,-70) end
                SidebarHandler:ToggleSidebarButtons(true)
            end
        end
    end)
end}
ConvenienceTab:CreateToggle{Name='แสดงแชทตลอด', CurrentValue=false, Flag='AlwaysShowChat', Callback=function(v)
    if v then
        task.spawn(function()
            while task.wait() do
                if Window.Flags.AlwaysShowChat.CurrentValue then
                    game:GetService("TextChatService"):FindFirstChildOfClass("ChatWindowConfiguration").Enabled = true
                elseif GameData.GameState == 1 then
                    game:GetService("TextChatService"):FindFirstChildOfClass("ChatWindowConfiguration").Enabled = false
                end
            end
        end)
    end
end}
ConvenienceTab:CreateToggle{Name='ปิดการลงโทษ AFK', CurrentValue=false, Flag='DisableAFKTaunting', Callback=function(v)
    if v then task.spawn(function() while Window.Flags.DisableAFKTaunting.CurrentValue do firesignal(UserInputService.InputEnded, {}) task.wait(5) end end) end
end}
ConvenienceTab:CreateToggle{Name='จำนวนครั้งถอดระเบิดไม่จำกัด', CurrentValue=false, Flag='InfiniteDisarmAttempts', Callback=EmptyCallback}
ConvenienceTab:CreateSection('ปรับแต่งสกิล','Right')
local noclipParts = {}
function EnableNoclip()
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                noclipParts[part] = part
                part.CanCollide = false
            end
        end
    end
end
function DisableNoclip() for _, p in pairs(noclipParts) do p.CanCollide = true end end

ConvenienceTab:CreateToggle{Name='ทะลุกำแพงขณะพุ่งไล่ล่า', CurrentValue=false, Flag='DemonicPursuitNoclip', Callback=function()
    task.spawn(function()
        while Wait() and Window.Flags.DemonicPursuitNoclip.CurrentValue do
            if LocalPlayer.Character and LocalPlayer.Character:GetAttribute('PursuitState') == 'Dashing' then
                EnableNoclip()
                repeat Wait() until not LocalPlayer.Character or LocalPlayer.Character:GetAttribute('PursuitState') ~= 'Dashing' or not IsKiller()
                DisableNoclip()
            end
        end
    end)
end}
ConvenienceTab:CreateToggle{Name='ป้องกันแครชขณะพุ่งไล่ล่า', CurrentValue=false, Flag='DemonicPursuitAntiCrash', Callback=EmptyCallback}
ConvenienceTab:CreateToggle{Name='ทะลุกำแพงขณะวอยด์รัช', CurrentValue=false, Flag='VoidRushNoclip', Callback=function()
    task.spawn(function()
        while Wait() and Window.Flags.VoidRushNoclip.CurrentValue do
            if LocalPlayer.Character and LocalPlayer.Character:GetAttribute('VoidRushState') == 'Dashing' then
                EnableNoclip()
                repeat Wait() until not LocalPlayer.Character or LocalPlayer.Character:GetAttribute('VoidRushState') ~= 'Dashing' or not IsKiller()
                DisableNoclip()
            end
        end
    end)
end}
ConvenienceTab:CreateToggle{Name='ป้องกันแครชขณะวอยด์รัช', CurrentValue=false, Flag='VoidRushAntiCrash', Callback=EmptyCallback}

-- ===== ADDED: Convenience extras + Pilot features (from Skidsaken) =====
ConvenienceTab:CreateToggle{Name='ใช้โล่ดูสคาร์ทะลุกำแพง', CurrentValue=false, Flag='ProtectionBreakWall', Callback=EmptyCallback}
ConvenienceTab:CreateToggle{Name='ข้ามการตั้งค่าความเป็นส่วนตัว', CurrentValue=false, Flag='PrivacyBypass', Callback=EmptyCallback}
ConvenienceTab:CreateToggle{Name='ควบคุม Void Rush', CurrentValue=false, Flag='VoidRushControl', Callback=function(v)
    if v then
        for i, val in getgc(true) do
            if type(val) == 'table' and rawget(val, 'VoidRushInitialTurnDuration') then
                rawset(val, 'VoidRushInitialTurnDuration', 9999)
                rawset(val, 'VoidRushInitialTurnMult', 9999)
            end
        end
    else
        for i, val in getgc(true) do
            if type(val) == 'table' and rawget(val, 'VoidRushInitialTurnDuration') then
                rawset(val, 'VoidRushInitialTurnDuration', 1.5)
                rawset(val, 'VoidRushInitialTurnMult', 6.6)
            end
        end
    end
end}
ConvenienceTab:CreateToggle{Name='ขับ Void Rush (Pilot)', CurrentValue=false, Flag='VoidRushPilot', Callback=EmptyCallback}
ConvenienceTab:CreateToggle{Name='ป้องกันแครช Guest', CurrentValue=false, Flag='ChargeAntiCrash', Callback=EmptyCallback}
ConvenienceTab:CreateToggle{Name='ควบคุมการเลี้ยว Guest', CurrentValue=false, Flag='ChargeControl', Callback=function(v)
    if v then
        for i, val in getgc(true) do
            if type(val) == 'table' and rawget(val, 'ChargingTurnSpeed') then
                rawset(val, 'ChargingTurnSpeed', 9999)
            end
        end
    else
        for i, val in getgc(true) do
            if type(val) == 'table' and rawget(val, 'ChargingTurnSpeed') then
                rawset(val, 'ChargingTurnSpeed', 2)
            end
        end
    end
end}
ConvenienceTab:CreateToggle{Name='ขับ Guest (Pilot)', CurrentValue=false, Flag='GuestPilot', Callback=EmptyCallback}
ConvenienceTab:CreateToggle{Name='ทะลุกำแพง Guest', CurrentValue=false, Flag='GuestNoclip', Callback=EmptyCallback}
ConvenienceTab:CreateToggle{Name='บินนอสเฟอราทูไม่จำกัด', CurrentValue=false, Flag='InfiniteNosFly', Callback=function(v)
    if v then
        for i, val in getgc(true) do
            if type(val) == 'table' and rawget(val, 'AscentFlight') then
                rawset(rawget(val, 'AscentFlight'), 'Duration', math.huge)
            end
        end
    else
        for i, val in getgc(true) do
            if type(val) == 'table' and rawget(val, 'AscentFlight') then
                rawset(rawget(val, 'AscentFlight'), 'Duration', 10)
            end
        end
    end
end}
ConvenienceTab:CreateToggle{Name='ขับ c00lkidd WS O.R (Fly)', CurrentValue=false, Flag='FlyOverride', Callback=EmptyCallback}
ConvenienceTab:CreateToggle{Name='ทะลุกำแพง c00lkidd WS O.R', CurrentValue=false, Flag='NoclipOverride', Callback=EmptyCallback}
ConvenienceTab:CreateToggle{Name='ชาร์จเจนโดทันที', CurrentValue=false, Flag='JaneDoeInstantCharge', Callback=function(v)
    if v then
        for i, val in getgc(true) do
            if type(val) == 'table' and rawget(val, 'Crystal') then
                rawset(rawget(val, 'Crystal'), 'MinChargeTime', 0)
                rawset(rawget(val, 'Crystal'), 'MaxChargeTime', 0.1)
            end
        end
    end
end}
ConvenienceTab:CreateToggle{Name='โคลน 007n7 ตามตัว', CurrentValue=false, Flag='Clone007n7Follow', Callback=EmptyCallback}

-- ADDED: Track attributes for pilots
local function TrackPilotAttributes(Character)
    if not Character then return end
    Character:GetAttributeChangedSignal('PursuitState'):Connect(function()
        if Character:GetAttribute('PursuitState') == 'Dashing' then
            Forsaken.PursuitTracker = tick()
        end
    end)
    Character:GetAttributeChangedSignal('VoidRushState'):Connect(function()
        if Character:GetAttribute('VoidRushState') == 'Dashing' then
            Forsaken.VoidRushTracker = tick()
        end
    end)
    local hrp = Character:WaitForChild('HumanoidRootPart', 7)
    if hrp then
        hrp.ChildAdded:Connect(function(child)
            if child:IsA("LinearVelocity") and not isUnloaded then
                if Character.Name ~= 'c00lkidd' or not Window.Flags.FlyOverride.CurrentValue then return end
                child.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
                local updateConn
                updateConn = RunService.Heartbeat:Connect(function()
                    local lookVec = CurrentCamera.CFrame.LookVector
                    if not child.Parent then updateConn:Disconnect() return end
                    child.VectorVelocity = lookVec * c00lkiddConfig.WalkspeedOverrideSpeed
                    hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + lookVec)
                end)
            end
        end)
    end
end
TrackPilotAttributes(LocalPlayer.Character)
LocalPlayer.CharacterAdded:Connect(TrackPilotAttributes)

-- ADDED: 007n7 clone handler
pcall(function()
    workspace.Map.Ingame.ChildAdded:Connect(function(v)
        if v.Name == '007n7' then
            local caller = v:GetAttribute('Username')
            if caller == LocalPlayer.Name then
                Forsaken.Has007n7Clone = true
                v.Destroying:Once(function() Forsaken.Has007n7Clone = false end)
            else
                if Window.Flags.AntiClone007n7 and Window.Flags.AntiClone007n7.CurrentValue then
                    v:Destroy()
                end
            end
        end
    end)
end)

-- ADDED: Dusekkar protection through walls
pcall(function()
    local IsCharWithinRadius = debug.getupvalue(DusekkarBehavior.Created, 3)
    local OldIsCharWithinRadius
    OldIsCharWithinRadius = hookfunction(IsCharWithinRadius, newcclosure(function(Player, Mag, _)
        if not Window.Flags.ProtectionBreakWall.CurrentValue then return OldIsCharWithinRadius(Player, Mag, _) end
        return OldIsCharWithinRadius(Player, 9e9)
    end))
end)

function TrackAttributes(char)
    char:GetAttributeChangedSignal('PursuitState'):Connect(function()
        if char:GetAttribute('PursuitState') == 'Dashing' then GameData.PursuitTracker = tick() end
    end)
    char:GetAttributeChangedSignal('VoidRushState'):Connect(function()
        if char:GetAttribute('VoidRushState') == 'Dashing' then GameData.VoidRushTracker = tick() end
    end)
end
TrackAttributes(LocalPlayer.Character)
LocalPlayer.CharacterAdded:Connect(TrackAttributes)

local sixerCfg = require(KillerAssets.Sixer.Config)
local noliCfg = require(KillerAssets.Noli.Config)
local oldNamecall2
oldNamecall2 = hookmetamethod(game, '__namecall', function(self, ...)
    if isUnloaded then return oldNamecall2(self, ...) end
    local args = {...}
    if Window.Flags.DemonicPursuitAntiCrash.CurrentValue and args[1] == (LocalPlayer.Name .. '666Crashed') and GameData.PursuitTracker then
        repeat Wait() until tick() - GameData.PursuitTracker >= sixerCfg.PursuitLength
    end
    if Window.Flags.VoidRushAntiCrash.CurrentValue and args[1] == (LocalPlayer.Name .. 'VoidRushCollision') and GameData.VoidRushTracker then
        repeat Wait() until tick() - GameData.VoidRushTracker >= noliCfg.VoidRushDashLength
    end
    return oldNamecall2(self, unpack(args))
end)

local protectionCheck = debug.getupvalue(DusekkarBehavior.Created, 3)
local oldProtection
oldProtection = hookfunction(protectionCheck, newcclosure(function(a,b,c)
    if not Window.Flags.ProtectionBreak.CurrentValue then return oldProtection(a,b,c) end
    return oldProtection(a, 9e9)
end))

-- ------------------------------------------------------------------
-- AmberCore | 11 / Block controls
-- ------------------------------------------------------------------
AutoBlockTab:CreateSection('บล็อกอัตโนมัติ')
AutoBlockTab:CreateToggle{Name='บล็อกอัตโนมัติ', CurrentValue=false, Flag='AutoBlockToggle', Callback=EmptyCallback}
AutoBlockTab:CreateToggle{Name='โคลน 007n7 อัตโนมัติ', CurrentValue=false, Flag='AutoCloneToggle', Callback=EmptyCallback}
AutoBlockTab:CreateToggle{Name='เรจจิ้งเพซอัตโนมัติ', CurrentValue=false, Flag='AutoParryToggle', Callback=EmptyCallback}
local pingLabel = AutoBlockTab:CreateLabel("ปิง: 0ms")
task.spawn(function() while Wait() do pingLabel:Set(string.format('ปิงของคุณคือ %s วินาที', tostring(Stats.PerformanceStats.Ping:GetValue()/1000))) end end)
AutoBlockTab:CreateLabel("การเปิดเพิ่มความเร็วจะทำให้ความแม่นยำลดลงมาก")
AutoBlockTab:CreateSection('ตั้งค่า','Right')
AutoBlockTab:CreateToggle{Name='ต่อยอัตโนมัติ', CurrentValue=true, Flag='AutoBlockPunch', Callback=EmptyCallback}
AutoBlockTab:CreateToggle{Name='เทคนิคลากฮิตบ็อกซ์', CurrentValue=true, Flag='HitboxDragTech', Callback=EmptyCallback}
AutoBlockTab:CreateSlider{Name='ระยะตรวจจับเรจจิ้งเพซ', Range={4,12}, Increment=1, CurrentValue=10, Flag='RagingPaceRange', Callback=EmptyCallback}
AutoBlockTab:CreateToggle{Name='ตรวจสอบทิศทางเรจจิ้งเพซ', CurrentValue=true, Flag='RagingPaceFaceCheck', Callback=EmptyCallback, TextMode=true}
AutoBlockTab:CreateSlider{Name='ระยะเวลารอก่อนบล็อก', Range={0,100}, Increment=1, Suffix='ms', CurrentValue=0, Flag='AutoBlockMS', Callback=EmptyCallback}
AutoBlockTab:CreateSection('ตัวแสดงผล')
AutoBlockTab:CreateToggle{Name='แสดงตัวแสดงผล', CurrentValue=true, Flag='AutoBlockVisualizer', Callback=EmptyCallback}
AutoBlockTab:CreateSlider{Name='ขนาดซ้าย', Range={0,9}, Increment=1, CurrentValue=5, Flag='VisualizerLeft', Callback=EmptyCallback}
AutoBlockTab:CreateSlider{Name='ขนาดขวา', Range={0,9}, Increment=1, CurrentValue=5, Flag='VisualizerRight', Callback=EmptyCallback}
AutoBlockTab:CreateSlider{Name='ขนาดหน้า', Range={0,18}, Increment=1, CurrentValue=9, Flag='VisualizerFront', Callback=EmptyCallback}
AutoBlockTab:CreateSlider{Name='ขนาดหลัง', Range={0,11}, Increment=1, CurrentValue=5, Flag='VisualizerBack', Callback=EmptyCallback}
AutoBlockTab:CreateSlider{Name='ขนาดหน้าเพิ่มเติมขณะเดิน', Range={0,9}, Increment=1, CurrentValue=6, Flag='VisualizerFrontPlus', Callback=EmptyCallback}

-- ===== ADDED: Autoblock extras (from Skidsaken) =====
AutoBlockTab:CreateToggle{Name='ต้านการเหยื่อล่อ (Anti-bait)', CurrentValue=false, Flag='AntiBait', Callback=EmptyCallback}
AutoBlockTab:CreateToggle{Name='ตรวจจับด้วยเสียง', CurrentValue=false, Flag='SoundDetection', Callback=EmptyCallback}
AutoBlockTab:CreateToggle{Name='ตรวจจับแบบ Query', CurrentValue=false, Flag='QueryBasedDetection', Callback=EmptyCallback}
AutoBlockTab:CreateToggle{Name='แสดงฮิตบ็อกซ์ HDT', CurrentValue=true, Flag='ShowHDTHitbox', Callback=EmptyCallback}
AutoBlockTab:CreateSlider{Name='HDT ขนาดซ้าย', Range={0,9}, Increment=1, CurrentValue=5, Flag='HDTLeft', Callback=EmptyCallback}
AutoBlockTab:CreateSlider{Name='HDT ขนาดขวา', Range={0,9}, Increment=1, CurrentValue=5, Flag='HDTRight', Callback=EmptyCallback}
AutoBlockTab:CreateSlider{Name='HDT ขนาดหน้า', Range={0,18}, Increment=1, CurrentValue=9, Flag='HDTFront', Callback=EmptyCallback}
AutoBlockTab:CreateSlider{Name='HDT ขนาดหลัง', Range={0,11}, Increment=1, CurrentValue=5, Flag='HDTBack', Callback=EmptyCallback}
AutoBlockTab:CreateColorPicker{Name='สี HDT (อยู่ในฮิตบ็อกซ์)', Color=Color3.new(0,1,0), Flag='HDTInColor', Callback=EmptyCallback}
AutoBlockTab:CreateColorPicker{Name='สี HDT (อยู่นอกฮิตบ็อกซ์)', Color=Color3.new(1,0,0), Flag='HDTOutColor', Callback=EmptyCallback}
AutoBlockTab:CreateToggle{Name='บล็อก Entanglement', CurrentValue=false, Flag='BlockEntanglement', Callback=EmptyCallback}
AutoBlockTab:CreateToggle{Name='บล็อก Void Rush', CurrentValue=false, Flag='BlockVoidRush', Callback=EmptyCallback}
AutoBlockTab:CreateToggle{Name='บล็อก Walkspeed Override', CurrentValue=false, Flag='BlockWSO', Callback=EmptyCallback}
AutoBlockTab:CreateToggle{Name='บล็อก Corrupt Nature', CurrentValue=false, Flag='BlockCorruptNature', Callback=EmptyCallback}
AutoBlockTab:CreateToggle{Name='เปิดวิ่งได้หลังบล็อก', CurrentValue=false, Flag='SprintAfterBlock', Callback=EmptyCallback}
AutoBlockTab:CreateToggle{Name='แจ้งเตือนเมื่อบล็อกสำเร็จ', CurrentValue=true, Flag='BlockNotifications', Callback=EmptyCallback}

local isInM1Cooldown = false
function CheckInvis()
    if IsKiller() and Window.Flags.AutoFarmSurvivors.CurrentValue then return false end
    return (isCompletingAll and false) or (Window.Flags.PartialInvisibility and Window.Flags.PartialInvisibility.CurrentValue) or (isInM1Cooldown and Window.Flags.AntiHit and Window.Flags.AntiHit.CurrentValue)
end
function IsFacing(posA, cframeB, dotThreshold) local dir = (posA.Position - cframeB.Position).Unit return cframeB.LookVector:Dot(dir) > (dotThreshold or 0.6) end
function Block() Network:FireServerConnection("UseActorAbility","REMOTE_EVENT",'Block') end
function Punch() Network:FireServerConnection("UseActorAbility","REMOTE_EVENT",'Punch') end
function Clone() Network:FireServerConnection("UseActorAbility","REMOTE_EVENT",'Clone') end
function GetTrueWait(animId)
    local name = GameData.BlockMeta[animId]
    if name == 'Entanglement' then return 0.4
    elseif name == 'MassInfection' then return 0.7
    elseif name == 'Behead' or name == 'GashingWoundStart' then return 0.21 end
    return 0
end

local isBlocking = false
local visualizerPart = Instance.new("Part", workspace)
visualizerPart.Anchored = true
visualizerPart.CanCollide = false
visualizerPart.Transparency = 0.8
visualizerPart.Material = Enum.Material.Neon
visualizerPart.CFrame = CFrame.new(99999,99999999,9999)
visualizerPart.Color = Color3.fromRGB(255,0,0)
visualizerPart:SetAttribute("in", false)

task.spawn(function()
    while true do
        if isUnloaded then break end
        RunService.RenderStepped:Wait()
        pcall(function()
            local killer = GameData.Killers[1]
            if not killer or not (Window.Flags.AutoBlockVisualizer.CurrentValue and Window.Flags.AutoBlockToggle.CurrentValue) then
                visualizerPart:SetAttribute("in", false)
                visualizerPart.CFrame = CFrame.new(99999,99999999,9999)
                return
            end
            local hrp = killer:FindFirstChild('HumanoidRootPart')
            if hrp then
                local front = Window.Flags.VisualizerFront.CurrentValue + (killer.Humanoid.MoveDirection:Dot(hrp.CFrame.LookVector) > 0.1 and Window.Flags.VisualizerFrontPlus.CurrentValue or 0)
                local left, right, back = Window.Flags.VisualizerLeft.CurrentValue, Window.Flags.VisualizerRight.CurrentValue, Window.Flags.VisualizerBack.CurrentValue
                visualizerPart.CFrame = hrp.CFrame * CFrame.new((right - left)/2, 0, -(front - back)/2)
                visualizerPart.Size = Vector3.new(left + right, 10, front + back)
            else
                visualizerPart:SetAttribute("in", false)
                visualizerPart.CFrame = CFrame.new(99999,99999999,9999)
            end
            local success = pcall(function()
                visualizerPart:SetAttribute("in", workspace:FindPartOnRayWithWhitelist(Ray.new(LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0,100,0), Vector3.new(0,-999,0)), {visualizerPart}) == visualizerPart)
            end)
            if not success then visualizerPart:SetAttribute("in", false) end
            visualizerPart.Color = visualizerPart:GetAttribute("in") and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
        end)
    end
end)

function Counter(killerChar)
    if CheckInvis() then return end
    if visualizerPart:GetAttribute("in") and HasAbilityReady('Block') then
        Block()
        repeat task.wait() until isBlocking
        if Window.Flags.HitboxDragTech.CurrentValue then PlayerControls:Disable() end
        pcall(function()
            local blocked = false
            while isBlocking do
                stareFunc(killerChar)
                if LocalPlayer.Character.HumanoidRootPart:FindFirstChild("rbxassetid://132298811847315") then
                    blocked = true
                    UILibrary:Notify{Title='บล็อกอัตโนมัติ', Content = 'บล็อกสำเร็จ', Duration=7}
                    break
                end
                if Window.Flags.HitboxDragTech.CurrentValue then LocalPlayer.Character.Humanoid:MoveTo(killerChar.HumanoidRootPart.Position) end
                RunService.RenderStepped:Wait()
            end
            if blocked then repeat task.wait() until HasAbilityReady('Punch') end
            if Window.Flags.AutoBlockPunch.CurrentValue and HasAbilityReady('Punch') then
                local t0 = tick()
                Punch()
                local hrp = killerChar.HumanoidRootPart
                while tick() - t0 <= 1 do
                    stareFunc(killerChar)
                    LocalPlayer.Character.Humanoid:MoveTo(killerChar.HumanoidRootPart.Position)
                    if hrp:FindFirstChild("rbxassetid://133398613783505") or hrp:FindFirstChild("rbxassetid://13471740561") or hrp:FindFirstChild("rbxassetid://116900970230089") then
                        UILibrary:Notify{Title='ต่อยอัตโนมัติ', Content = 'ต่อยสำเร็จ', Duration=7}
                        break
                    end
                    RunService.RenderStepped:Wait()
                end
            end
        end)
        PlayerControls:Enable()
        return true
    end
end

function IsFacing2(posA, cframeB, dot, rightDot)
    local delta = posA.Position - cframeB.Position
    if delta.Magnitude > 30 then return false end
    local dotProd = cframeB.LookVector:Dot(delta.Unit)
    local right = math.abs(cframeB.RightVector:Dot(delta.Unit))
    return dotProd > (dot or 0.7) and right < (rightDot or 0.4)
end

function TrackAnimations(char, isSurvivor)
    local hrp = char and char:WaitForChild('HumanoidRootPart', 7)
    if not hrp then return end
    local hum = char:WaitForChild("Humanoid", 7)
    if not hum then return end
    local anim = hum:WaitForChild('Animator', 5)
    if not anim then return end
    anim.AnimationPlayed:Connect(function(track)
        if isUnloaded then return end
        if isSurvivor and LocalPlayer.Character.Name == 'Guest1337' then
            if track.Animation.AnimationId:find("Block") then
                isBlocking = true
                while track.IsPlaying do task.wait() end
                isBlocking = false
            end
        end
        if isSurvivor and IsKiller() and LocalPlayer.Character.Name == 'Slasher' then
            if not table.find(GameData.SentinelAnimations, track.Animation.AnimationId) then return end
            local myRoot = LocalPlayer.Character.HumanoidRootPart
            local targetRoot = char.HumanoidRootPart
            while track.IsPlaying do
                if Window.Flags.AutoParryToggle.CurrentValue and HasAbilityReady('RagingPace') then
                    local dist = (myRoot.Position - targetRoot.Position).Magnitude
                    if dist <= Window.Flags.RagingPaceRange.CurrentValue and (dist <= 5 or not Window.Flags.RagingPaceFaceCheck.CurrentValue or IsFacing2(myRoot, targetRoot, 0.707, 1)) then
                        Network:FireServerConnection("UseActorAbility","REMOTE_EVENT",'RagingPace')
                    end
                end
                task.wait()
            end
            return
        end
        if table.find(GameData.WalkspeedOverrideAnimations, track.Animation.AnimationId) then GameData.UsingWalkspeedOverride = true end
        if table.find(GameData.WalkspeedOverrideEndedAnims, track.Animation.AnimationId) then GameData.UsingWalkspeedOverride = false end
        if not table.find(GameData.AttackAnimations, track.Animation.AnimationId) then return end

        local killer = GameData.Killers[1]
        local closestKiller = GetClosestKiller(17)

        local function GetHitboxes()
            local count = 0
            for _, hb in ipairs(workspace.Hitboxes:GetChildren()) do
                if hb.Name:sub(1,-7) == closestKiller:GetAttribute('Username') then count += 1 end
            end
            return count
        end

        task.spawn(function()
            if table.find(GameData.M1Animations, track.Animation.AnimationId) and closestKiller then
                isInM1Cooldown = true
                while GetHitboxes() > 0 do Wait() end
                Wait(0.4 + GetTrueWait(track.Animation.AnimationId))
                isInM1Cooldown = false
            end
        end)

        if killer then
            if HasAbilityReady("Block") and not IsKiller() and Window.Flags.AutoBlockToggle.CurrentValue then
                while track.IsPlaying do if Counter(killer) then break end task.wait() end
            elseif HasAbilityReady('Clone') and Window.Flags.AutoCloneToggle.CurrentValue then
                Clone()
            end
        end
    end)
end

for _, char in ipairs(GameData.Killers) do TrackAnimations(char) end
KillersFolder.ChildAdded:Connect(TrackAnimations)
for _, char in ipairs(GameData.Survivors) do if table.find({'Shedletsky','TwoTime','JaneDoe','Guest1337'}, char.Name) then TrackAnimations(char, true) end end
SurvivorsFolder.ChildAdded:Connect(function(char) if table.find({'Shedletsky','TwoTime','JaneDoe','Guest1337'}, char.Name) then TrackAnimations(char, true) end end)

function VoidRushIsDangerous()
    for _, killer in ipairs(GameData.Killers) do
        if killer:GetAttribute("VoidRushState") == 'Dashing' then
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
            local kRoot = killer:FindFirstChild('HumanoidRootPart')
            if kRoot and myRoot then return IsFacing2(myRoot, kRoot), killer end
        end
    end
end
function OverrideIsDangerous()
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
    if not myRoot then return end
    local killer = GetClosestKiller(22)
    if GameData.UsingWalkspeedOverride and killer and killer.Name == 'c00lkidd' then
        local kRoot = killer:FindFirstChild('HumanoidRootPart')
        if not kRoot then return end
        return IsFacing2(myRoot, kRoot), killer
    end
end
RunService.RenderStepped:Connect(function()
    if Window.Flags.AutoBlockToggle.CurrentValue then
        local dangerous = VoidRushIsDangerous()
        if dangerous and HasAbilityReady('Block') then Block() end
        local dangerous2 = OverrideIsDangerous()
        if dangerous2 and HasAbilityReady('Block') then Block() end
    end
end)

-- ------------------------------------------------------------------
-- AmberCore | 12 / Player controls
-- ------------------------------------------------------------------
PlayerTab:CreateSection('การตั้งค่าผู้เล่น')
function NeedToEscapeOrReel() local qte = TemporaryUI:FindFirstChild("QTE") return qte ~= nil and qte:FindFirstChild('Zone3') == nil end
function ClearPopups() for _, child in ipairs(TemporaryUI:GetChildren()) do if child.Name == '1x1x1x1Popup' then child:Destroy() end end end

PlayerTab:CreateToggle{Name='ลบป็อปอัพอัตโนมัติ', CurrentValue=false, Flag='AutoClearPopups', Callback=function(v) if v then ClearPopups() end end}
PlayerTab:CreateToggle{Name='หนีนอสเฟอราทูอัตโนมัติ', CurrentValue=false, Flag='NosferatuMinigame', Callback=EmptyCallback}
PlayerTab:CreateToggle{Name='หยุดวิ่งอัตโนมัติ', CurrentValue=false, Flag='AutoUnsprint', Callback=function()
    task.spawn(function() while Wait() and Window.Flags.AutoUnsprint.CurrentValue do if SprintingModule.Stamina < 3 then SprintingModule.IsSprinting = false SprintingModule.__sprintedEvent:Fire(false) end end end)
end}
PlayerTab:CreateToggle{Name='วิ่งตลอดเวลา', CurrentValue=false, Flag='AutoSprint', Callback=function()
    task.spawn(function() while Wait() and Window.Flags.AutoSprint.CurrentValue do if Window.Flags.AutoUnsprint.CurrentValue and SprintingModule.Stamina ~= 100 then continue end if not SprintingModule.IsSprinting then SprintingModule.IsSprinting = true SprintingModule.__sprintedEvent:Fire(true) end end end)
end}
PlayerTab:CreateToggle{Name='ปิดแอนิเมชันวิ่ง', CurrentValue=false, Flag='NoSprintTween', Callback=EmptyCallback}
PlayerTab:CreateToggle{Name='ไม่ช้าลง', CurrentValue=false, Flag='NoSlowdown', Callback=function()
    task.spawn(function() while Wait() and Window.Flags.NoSlowdown.CurrentValue do if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('SpeedMultipliers') then for _, mult in ipairs(LocalPlayer.Character.SpeedMultipliers:GetChildren()) do if not HasAbility(mult.Name) and mult.Value < 1 then mult.Value = 1 mult:GetPropertyChangedSignal('Value'):Connect(function() mult.Value = 1 end) end end end end end)
end}
PlayerTab:CreateToggle{Name='ไม่ช้าลงจากสกิล', CurrentValue=false, Flag='NoAbilitySlowdown', Callback=function()
    task.spawn(function() while Wait() and Window.Flags.NoAbilitySlowdown.CurrentValue do if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('SpeedMultipliers') then for _, mult in ipairs(LocalPlayer.Character.SpeedMultipliers:GetChildren()) do if HasAbility(mult.Name) and mult.Value < 1 then mult.Value = 1 mult:GetPropertyChangedSignal('Value'):Connect(function() mult.Value = 1 end) end end end end end)
end}

local oldTweenCreate
oldTweenCreate = hookmetamethod(game, '__namecall', function(self, ...)
    if isUnloaded then return oldTweenCreate(self, ...) end
    local args = {...}
    if Window.Flags.NoSprintTween.CurrentValue and not checkcaller() and self == TweenService and getnamecallmethod() == 'Create' and args[1] == SprintingModule.__speedMultiplier then
        args[2] = TweenInfo.new(0)
    end
    return oldTweenCreate(self, unpack(args))
end)

PlayerTab:CreateDropdown{Name='ปลอมอุปกรณ์', Options={'PC','Mobile','Console','Unknown'}, CurrentOption={RealDevice}, Flag='DeviceSpooferValue', Callback=function(v) Network:FireServerConnection("SetDevice","REMOTE_EVENT",v[1]) end}
PlayerTab:CreateSection('สกิลผู้เล่น')
function VerronicaIsSkating()
    if GameData.GameState ~= 1 then return false end
    if LocalPlayer.Character.Name ~= 'Veeronica' then return false end
    if not VeeronicaBehavior:FindFirstChild('Highlight') then return false end
    if VeeronicaBehavior.Highlight.Adornee ~= LocalPlayer.Character then return false end
    return true
end
PlayerTab:CreateToggle{Name='วีโรนิก้าแสดงท่าอัตโนมัติ', CurrentValue=false, Flag='AutoTrick', Callback=function() task.spawn(function() while Wait() and Window.Flags.AutoTrick.CurrentValue do if VerronicaIsSkating() then PressKeycode(Enum.KeyCode.Space) end end end) end}
PlayerTab:CreateToggle{Name='ควบคุมวีโรนิก้า', CurrentValue=false, Flag='SkateTurningControl', Callback=function(v)
    if v then UILibrary:Notify{Title='ควบคุมวีโรนิก้า', Content = 'รอจนเริ่มรอบถัดไปเพื่อให้ฟีเจอร์นี้ทำงาน', Duration=4} VeeronicaConfig.Sk8TurnControl = 6.5 else VeeronicaConfig.Sk8TurnControl = 0.65 end
end}
PlayerTab:CreateToggle{Name='นอสเฟอราทูรีลอัตโนมัติ', CurrentValue=false, Flag='AutoNosferatuReel', Callback=EmptyCallback}
task.spawn(function()
    local busy = false
    while Wait() and (Window.Flags.NosferatuMinigame.CurrentValue or Window.Flags.AutoNosferatuReel.CurrentValue) do
        if NeedToEscapeOrReel() then
            if IsKiller() then if not Window.Flags.AutoNosferatuReel.CurrentValue then continue end
            else if not Window.Flags.NosferatuMinigame.CurrentValue then continue end end
            local eventName = (IsKiller() and LocalPlayer.Name or GetKillerUsername()) .. 'NosHookQTE'
            Network:FireServerConnection(eventName,"REMOTE_EVENT",true)
            if not busy then
                task.spawn(function()
                    busy = true
                    repeat Wait() until not NeedToEscapeOrReel()
                    UILibrary:Notify{Title='ตะขอเลือด', Content=IsKiller() and 'Automatically reeled survivor' or 'Successfully escaped', Duration=6, Image=tonumber'132244492243010'}
                    busy = false
                end)
            end
        end
    end
end)

function GetCharges()
    local ok, val = pcall(function() if HasAbility('Reroll') then return tonumber(PlayerGui.MainUI.AbilityContainer.Reroll.Charges.Text) end end)
    if not ok then return 9e9 end
    return val or 9e9
end
local lastCoinFlip = 0
PlayerTab:CreateToggle{Name='เหรียญอัตโนมัติ', CurrentValue=false, Flag='AutoCoinFlip', Callback=function()
    task.spawn(function() while Wait() and Window.Flags.AutoCoinFlip.CurrentValue do if GetCharges() < Window.Flags.MaxCharges.CurrentValue and HasAbilityReady('CoinFlip') and tick() - lastCoinFlip >= 2.5 then Network:FireServerConnection("UseActorAbility","REMOTE_EVENT",'CoinFlip') lastCoinFlip = tick() end end end)
end}
PlayerTab:CreateSlider{Name='└── จำนวนชาร์จสูงสุด', Range={1,3}, Increment=1, CurrentValue=1, Flag='MaxCharges', Callback=EmptyCallback}
PlayerTab:CreateToggle{Name='404 Error อัตโนมัติ', CurrentValue=false, Flag='AutoUse404Error', Callback=function()
    task.spawn(function() while Wait() and Window.Flags.AutoUse404Error.CurrentValue do if HasAbilityReady('404Error') then Network:FireServerConnection("UseActorAbility","REMOTE_EVENT",'404Error') end end end)
end}
PlayerTab:CreateToggle{Name='มินิเกมถอดระเบิดอัตโนมัติ', CurrentValue=false, Flag='AutoDisarmMinigame', Callback=EmptyCallback}

local oldConstructQTE
oldConstructQTE = hookfunction(AzureConstructQTE.new, newcclosure(function(a,b)
    local qte = oldConstructQTE(a,b)
    task.spawn(function()
        if Window.Flags.InfiniteDisarmAttempts.CurrentValue then
            qte.FailedAttempts = -math.huge
            warn("patched FailedAttempts")
        end
        if Window.Flags.AutoDisarmMinigame.CurrentValue then
            task.wait(1.5)
            qte.Progress = 100
            qte:Destroy()
            task.spawn(function() setthreadidentity(8) UILibrary:Notify{Title='ถอดระเบิดอัตโนมัติ', Content = 'ข้ามมินิเกมถอดระเบิดสำเร็จ', Duration=7, Image='check'} end)
        end
    end)
    return qte
end))

PlayerTab:CreateToggle{Name='เทเลพอร์ตดาบสั้น', CurrentValue=false, Flag='TPDagger', Callback=EmptyCallback}
PlayerTab:CreateToggle{Name='เทเลพอร์ตสแลช', CurrentValue=false, Flag='TPSlash', Callback=EmptyCallback}
PlayerTab:CreateToggle{Name='เทเลพอร์ตวันช็อต', CurrentValue=false, Flag='TPOneShot', Callback=EmptyCallback}
PlayerTab:CreateToggle{Name='ไก่ทอดอัตโนมัติ', CurrentValue=false, Flag='AutoChicken', Callback=function()
    task.spawn(function() while Wait() and Window.Flags.AutoChicken.CurrentValue do if HasAbilityReady("FriedChicken") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health <= Window.Flags.AutoChickenHealth.CurrentValue then local killer = GetClosestKiller(5000) if killer and (not Window.Flags.AutoChickenFar.CurrentValue or (LocalPlayer.Character.HumanoidRootPart.Position - killer.HumanoidRootPart.Position).Magnitude >= 100) then Network:FireServerConnection("UseActorAbility","REMOTE_EVENT",'FriedChicken') end end end end)
end}
PlayerTab:CreateSlider{Name='└── ขีดจำกัดเลือด', Range={1,99}, Increment=1, CurrentValue=40, Flag='AutoChickenHealth', Callback=EmptyCallback}
PlayerTab:CreateToggle{Name='└── เฉพาะเมื่ออยู่ไกลฆาตกร', CurrentValue=false, Flag='AutoChickenFar', Callback=EmptyCallback, TextMode=true}

PlayerTab:CreateSection('การมองไม่เห็น')
if identifyexecutor() ~= "Cosmic" then
    setthreadidentity(8)
    local invisBtn = IconModule.new():setImage(tonumber'103479372336287'):setCaption('การมองไม่เห็น'):bindEvent('deselected', function() setthreadidentity(8) Window.Flags.PartialInvisibility:Set(false) end):bindEvent('selected', function() setthreadidentity(8) Window.Flags.PartialInvisibility:Set(true) end):autoDeselect(false):setEnabled(false)
    GlobalEnv.InvisToggleButton = invisBtn
    setthreadidentity(8)
    PlayerTab:CreateToggle{Name='การมองไม่เห็น', CurrentValue=false, Flag='PartialInvisibility', Callback=function(v) if not v then invisBtn:deselect() else invisBtn:select() end end}
    PlayerTab:CreateToggle{Name='ปุ่มมองไม่เห็น', CurrentValue=false, Flag='InvisibilityButton', Callback=function(v) invisBtn:setEnabled(v) end, TextMode=true}
    if not isMobile then
        PlayerTab:CreateKeybind{Name='Keybind', CurrentKeybind='V', Callback=function() if Window.Flags.PartialInvisibility.CurrentValue then Window.Flags.PartialInvisibility:Set(false) else Window.Flags.PartialInvisibility:Set(true) end end}
    end
    PlayerTab:CreateLabel("ฮิตบ็อกซ์และการโจมตีจะไม่ทำงานขณะใช้การมองไม่เห็น")
    PlayerTab:CreateToggle{Name='ต้านการโดนตี', CurrentValue=false, Flag='AntiHit', Callback=function(v) if v and Window.Flags.AutoBackstab.CurrentValue then UILibrary:Notify{Title='ต้านการโดนตี', Content = 'ปิดตัวเลือกนี้หากต้องการให้แทงหลังอัตโนมัติทำงานดีขึ่น', Duration=6, Image='sword'} end end}
    PlayerTab:CreateLabel("ต้านการโดนตีใช้การมองไม่เห็นเพื่อหลบการโจมตี M1")

    local oldSerialize
    oldSerialize = hookfunction(CharacterReplication.Serialize, newcclosure(function(...)
        if GameData.GameState ~= 1 then return oldSerialize(...) end
        if tick() - GameData.RoundStart < 3 then return oldSerialize(...) end
        local args = {...}
        if typeof(args[1]) ~= 'CFrame' then return oldSerialize(...) end
        if typeof(args[2]) ~= 'Vector3' then return oldSerialize(...) end
        if CheckInvis() then return oldSerialize(args[1], args[2] + Vector3.new(0,5000,0)) end
        return oldSerialize(...)
    end))
else
    PlayerTab:CreateLabel("ต้านการโดนตีและการมองไม่เห็นไม่รองรับบน Cosmic")
end

PlayerTab:CreateSection('แทงหลังอัตโนมัติ')
PlayerTab:CreateToggle{Name='แทงหลังอัตโนมัติ', CurrentValue=false, Flag='AutoBackstab', Callback=function(v) if v and Window.Flags.AntiHit.CurrentValue then UILibrary:Notify{Title='แทงหลังอัตโนมัติ', Content = 'ปิดต้านการโดนตีหากต้องการให้ทำงานดีขึ้น', Duration=6, Image='sword'} end end}
PlayerTab:CreateToggle{Name='เปิดมองไม่เห็นหลังแทง', CurrentValue=false, Flag='BackstabInvis', Callback=EmptyCallback, TextMode=true}
function IsFacingBack(myRoot, targetRoot)
    local delta = myRoot.Position - targetRoot.Position
    local back = -targetRoot.CFrame.LookVector
    local proj = delta:Dot(back)
    if proj <= 0 or proj > 7 then return false end
    local closest = back * proj
    return (delta - closest).Magnitude <= 3.5
end
task.spawn(function()
    while Wait() do
        if Window.Flags.AutoBackstab.CurrentValue and not CheckInvis() then
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
            local killer = GetClosestKiller(15)
            if killer and killer:FindFirstChild('HumanoidRootPart') and myRoot and HasAbilityReady('Dagger') then
                stareFunc(killer)
                if IsFacingBack(myRoot, killer.HumanoidRootPart) then
                    local t0 = tick()
                    StartAimbotting(killer, function()
                        Network:FireServerConnection("UseActorAbility","REMOTE_EVENT",'Dagger')
                        LocalPlayer.Character.Humanoid:MoveTo(killer.HumanoidRootPart.Position)
                        return tick() - t0 <= 2 and LocalPlayer.Character and LocalPlayer.Character.Parent == SurvivorsFolder and not HasNotification('tabbed') and not CheckInvis()
                    end)
                    if Window.Flags.BackstabInvis.CurrentValue and not Window.Flags.PartialInvisibility.CurrentValue then
                        Window.Flags.PartialInvisibility:Set(true)
                    end
                end
            end
        end
    end
end)

PlayerTab:CreateSection('M1 อัตโนมัติ','Right')
PlayerTab:CreateToggle{Name='สแลช/M1 อัตโนมัติ', CurrentValue=false, Flag='AutoUseM1', Callback=function()
    task.spawn(function() while Wait() and Window.Flags.AutoUseM1.CurrentValue do if not CheckInvis() and HasAbilityReady(GetM1Name()) then local target = LocalPlayer.Character and ((IsKiller() and GetClosestSurvivor(Window.Flags.AutoM1Radius.CurrentValue)) or (LocalPlayer.Character.Name == 'Shedletsky' and GetClosestKiller(Window.Flags.AutoM1Radius.CurrentValue))) if target and target:FindFirstChild('HumanoidRootPart') and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart') and (not Window.Flags.AutoM1FaceCheck.CurrentValue or IsFacing(target.HumanoidRootPart, LocalPlayer.Character.HumanoidRootPart, 0.73)) then Network:FireServerConnection("UseActorAbility","REMOTE_EVENT",GetM1Name()) end end end end)
end}
PlayerTab:CreateToggle{Name='ตรวจสอบทิศทาง', CurrentValue=true, Flag='AutoM1FaceCheck', Callback=EmptyCallback, TextMode=true}
PlayerTab:CreateSlider{Name='รัศมี', Range={6,15}, Increment=1, CurrentValue=10, Flag='AutoM1Radius', Callback=EmptyCallback}

-- ===== ADDED: Player extras (from Skidsaken) =====
PlayerTab:CreateToggle{Name='สปายการสตัน', CurrentValue=false, Flag='StunSpy', Callback=function(v)
    if v then UILibrary:Notify{Title='กำลังพัฒนา', Content='Stun spy ยังอยู่ในระหว่างพัฒนา ตรวจจับได้แค่: shedletsky, guest1337, twotime', Duration=12, Image='info'} end
end}
PlayerTab:CreateToggle{Name='แสดงเส้นทางสกิล', CurrentValue=false, Flag='RevealTrajectory', Callback=EmptyCallback}
PlayerTab:CreateToggle{Name='เหยียบข้ามรอยเท้าดิจิทัล', CurrentValue=false, Flag='WalkOverDF', Callback=EmptyCallback}
PlayerTab:CreateToggle{Name='เหยียบข้ามรอย (Trails)', CurrentValue=false, Flag='WalkOverTrail', Callback=EmptyCallback}
PlayerTab:CreateToggle{Name='เหยียบข้ามแอ่งนอส', CurrentValue=false, Flag='WalkOverPuddles', Callback=EmptyCallback}
PlayerTab:CreateToggle{Name='ต้านการบล็อก (Anti-block)', CurrentValue=false, Flag='Antiblock', Callback=EmptyCallback}

-- ADDED: Godmode + True Invisibility (with desync)
local InvisToggleButton
pcall(function()
    InvisToggleButton = IconModule.new():setImage('rbxassetid://132244492243010'):setCaption('Invisibility'):bindEvent('deselected', function()
        setthreadidentity(8)
        Window.Flags.TrueInvisibility:Set(false)
    end):bindEvent('selected', function()
        setthreadidentity(8)
        Window.Flags.TrueInvisibility:Set(true)
    end):autoDeselect(false):setEnabled(false)
    GlobalEnv.InvisToggleButton = InvisToggleButton
end)
PlayerTab:CreateToggle{Name='ก็อดโหมด + มองไม่เห็น', CurrentValue=false, Flag='TrueInvisibility', Callback=function(v)
    if InvisToggleButton then if not v then InvisToggleButton:deselect() else InvisToggleButton:select() end end
end}
PlayerTab:CreateToggle{Name='แสดงปุ่มมองไม่เห็น', CurrentValue=false, Flag='TrueInvisibilityButton', Callback=function(v) if InvisToggleButton then InvisToggleButton:setEnabled(v) end end, TextMode=true}
if not isMobile then
    PlayerTab:CreateKeybind{Name='Keybind มองไม่เห็น', CurrentKeybind='G', Callback=function()
        if Window.Flags.TrueInvisibility.CurrentValue then Window.Flags.TrueInvisibility:Set(false) else Window.Flags.TrueInvisibility:Set(true) end
    end}
end

-- ADDED: Desync system
local DesyncToggleButton
pcall(function()
    DesyncToggleButton = IconModule.new():setImage('rbxassetid://132244492243010'):setLabel('Desync'):setCaption('Desync'):bindEvent('deselected', function()
        setthreadidentity(8)
        Window.Flags.DesyncMainToggle:Set(false)
        Forsaken:UnregisterDesync('DesyncMain')
    end):bindEvent('selected', function()
        setthreadidentity(8)
        Window.Flags.DesyncMainToggle:Set(true)
        Forsaken:RegisterDesync('DesyncMain')
    end):autoDeselect(false):setEnabled(false)
    GlobalEnv.DesyncToggleButton = DesyncToggleButton
end)
PlayerTab:CreateToggle{Name='ดีซิงค์ (Desync)', CurrentValue=false, Flag='DesyncMainToggle', Callback=function(v)
    if DesyncToggleButton then if not v then DesyncToggleButton:deselect() else DesyncToggleButton:select() end end
end}
PlayerTab:CreateToggle{Name='แสดงปุ่มดีซิงค์', CurrentValue=false, Flag='DesyncButton', Callback=function(v) if DesyncToggleButton then DesyncToggleButton:setEnabled(v) end end, TextMode=true}
if not isMobile then
    PlayerTab:CreateKeybind{Name='Keybind ดีซิงค์', CurrentKeybind='C', Callback=function()
        if Window.Flags.DesyncMainToggle.CurrentValue then Window.Flags.DesyncMainToggle:Set(false) else Window.Flags.DesyncMainToggle:Set(true) end
    end}
end

-- ADDED: Walk-over effects runtime loop
task.spawn(function()
    while not isUnloaded and Wait(0.1) do
        pcall(function()
            if Window.Flags.WalkOverDF.CurrentValue then
                for _, v in pairs(Forsaken.DoeDebris) do
                    if v and v:FindFirstChild('TouchInterest') then v.TouchInterest:Destroy() end
                end
            end
        end)
    end
end)

-- ------------------------------------------------------------------
-- AmberCore | 13 / Map controls
-- ------------------------------------------------------------------
MapTab:CreateSection('แผนที่')
MapTab:CreateToggle{Name='ทะลุหนาม', CurrentValue=false, Flag='SpikeNoclip', Callback=function()
    task.spawn(function() while Window.Flags.SpikeNoclip.CurrentValue and task.wait() do if GameData.GameState == 1 then for i, spike in ipairs(GameData.Spikes) do table.remove(GameData.Spikes, i) spike:Destroy() end end end end)
end}
MapTab:CreateSection('สกุลเงิน')
function SearchTool(name) for _, tool in ipairs(GameData.Items) do if tool.Name == name then return tool end end end
function GrabTool(tool)
    if GameData.GameState ~= 1 then return end
    if not tool then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
    local hasTool
    if root then for _, c in ipairs(LocalPlayer.Character:GetChildren()) do if c.Name == tool.Name and c:IsA('Tool') then hasTool = true break end end end
    if LocalPlayer.Backpack:FindFirstChild(tool.Name) or hasTool then return end
    if root and tool:FindFirstChild('ItemRoot') then
        local saved = root.CFrame
        root.CFrame = tool.ItemRoot.CFrame
        local t0 = tick()
        repeat
            local prompt = tool:FindFirstChild('ItemRoot') and tool.ItemRoot:FindFirstChild('ProximityPrompt')
            if not prompt then return end
            fireproximityprompt(prompt)
            Wait()
        until tick() - t0 >= 4 or tool.Parent == LocalPlayer.Backpack or not tool.Parent
        if tick() - t0 >= 4 then return warn("timed out while picking up item") end
        root.CFrame = saved
    end
end
function YoinkLoot() if IsKiller() then return end if Window.Flags.AutoRomania.CurrentValue then GrabTool(SearchTool('BloxyCola')) GrabTool(SearchTool('Medkit')) end end

MapTab:CreateToggle{Name='ฟาร์มขนมปังขิงอัตโนมัติ [ปิดใช้งาน]', CurrentValue=false, Flag='AutofarmGingerbread', Callback=EmptyCallback}
MapTab:CreateToggle{Name='ฟาร์มซุคการ์อัตโนมัติ [ปิดใช้งาน]', CurrentValue=false, Flag='AutofarmSukkars', Callback=EmptyCallback}
task.spawn(function() while Wait() do if GameData.GameState == 1 and not isCompletingAll then pcall(YoinkLoot) end end end)

MapTab:CreateSection('ไอเทม')
function GrabMedkit() local tool = SearchTool('Medkit') if not tool then return warn('no medkit found') end GrabTool(tool) end
function GrabCola() local tool = SearchTool('BloxyCola') if not tool then return warn('no bloxy cola found') end GrabTool(tool) end
MapTab:CreateButton{Name='หยิบชุดปฐมพยาบาล', Callback=GrabMedkit}
MapTab:CreateButton{Name='หยิบโคล่า', Callback=GrabCola}
MapTab:CreateToggle{Name='หยิบไอเทมทั้งหมดอัตโนมัติ', CurrentValue=false, Flag='AutoRomania', Callback=EmptyCallback}
MapTab:CreateToggle{Name='หยิบไอเทมใกล้ตัวอัตโนมัติ', CurrentValue=false, Flag='AutoPickCloseItems', Callback=EmptyCallback}
task.spawn(function() while Wait() do local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart') if root and Window.Flags.AutoPickCloseItems.CurrentValue then for _, item in ipairs(GameData.Items) do if item:FindFirstChild('ItemRoot') and item.ItemRoot:FindFirstChild('ProximityPrompt') and (item.ItemRoot.Position - root.Position).Magnitude <= item.ItemRoot.ProximityPrompt.MaxActivationDistance then fireproximityprompt(item.ItemRoot.ProximityPrompt) end end end end end)

MapTab:CreateSection('ฆาตกร','Right')
local killerLabel = MapTab:CreateLabel('ฆาตกร: @null [สกิน]')
MapTab:CreateButton{Name='ดูฆาตกร', Callback=function()
    local killer = GameData.Killers[1]
    if killer and killer:FindFirstChild("Humanoid") then
        if workspace.CurrentCamera.CameraSubject == killer.Humanoid then
            UILibrary:Notify{Title='ดูผู้เล่น', Content = 'หยุดดู ' .. tostring(killer), Duration=6, Image='eye'}
            workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
        elseif LocalPlayer.Character then
            UILibrary:Notify{Title='ดูผู้เล่น', Content = 'กำลังดู ' .. tostring(killer) .. ' click again to stop', Duration=6, Image='eye'}
            workspace.CurrentCamera.CameraSubject = killer.Humanoid
        end
    end
end}
MapTab:CreateButton{Name='เทเลพอร์ตไปหาฆาตกร', Callback=function()
    local killer = GameData.Killers[1]
    if killer and killer:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = killer.HumanoidRootPart.CFrame
    end
end}
MapTab:CreateToggle{Name='ฟาร์มผู้รอดชีวิต', CurrentValue=false, Flag='AutoFarmSurvivors', Callback=function()
    task.spawn(function() while Wait() do pcall(function() if not Window.Flags.AutoFarmSurvivors.CurrentValue then return elseif IsKiller() then local target = GameData.Survivors[math.random(1, #GameData.Survivors)] while target.Parent and target:FindFirstChild("Humanoid") and target:FindFirstChild("HumanoidRootPart") and target.Humanoid.Health > 0 do LocalPlayer.Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame Network:FireServerConnection("UseActorAbility","REMOTE_EVENT",GetM1Name()) task.wait() if not Window.Flags.AutoFarmSurvivors.CurrentValue then return end end end end) end end)
end}
MapTab:CreateToggle{Name='ทะลุกำแพงฆาตกร', CurrentValue=false, Flag='BypassKillerWalls', Callback=function()
    task.spawn(function() while Wait() do pcall(function() if not Window.Flags.BypassKillerWalls.CurrentValue then if not IsKiller() then for _, part in pairs(LocalPlayer.Character:GetChildren()) do if part:IsA("BasePart") and part.CollisionGroup == "Killers" then part.CollisionGroup = "Survivors" end end end elseif not IsKiller() then for _, part in pairs(LocalPlayer.Character:GetChildren()) do if part:IsA("BasePart") and part.CollisionGroup == "Survivors" then part.CollisionGroup = "Killers" end end end end) end end)
end}
MapTab:CreateSection('ผู้รอดชีวิต','Left')
local survivorCountLabel = MapTab:CreateLabel('ผู้รอดชีวิต: ' .. #GameData.Survivors)
task.spawn(function() while task.wait(0.5) do survivorCountLabel:Set('ผู้รอดชีวิต: ' .. #GameData.Survivors) local killer = GameData.Killers[1] if killer then killerLabel:Set('ฆาตกร: @' .. killer:GetAttribute('Username') .. ' [' .. killer.Name .. ']') else killerLabel:Set('ไม่มีฆาตกร') end end end)
MapTab:CreateButton{Name='เทเลพอร์ตไปหาผู้รอดชีวิตแบบสุ่ม', Callback=function()

-- ===== ADDED: Map extras (from Skidsaken) =====
MapTab:CreateToggle{Name='วนเทเลพอร์ตสุ่มผู้เล่นทุกคน', CurrentValue=false, Flag='LoopRandomTPAll', Callback=EmptyCallback}
MapTab:CreateButton{Name='ดึงไอเทมมาหาตัว', Callback=function()
    pcall(function()
        for _, item in pairs(workspace:GetDescendants()) do
            if item:IsA('BasePart') and item.Parent and item.Parent:IsA('Tool') then
                item.Position = LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(math.random(-5,5), 2, math.random(-5,5))
            end
        end
        UILibrary:Notify{Title='ดึงไอเทม', Content='ดึงไอเทมทั้งหมดมาหาตัวแล้ว', Duration=5}
    end)
end}
    local hrp
    repeat
        local char = GameData.Survivors[math.random(1, #GameData.Survivors)]
        if char and char ~= LocalPlayer.Character then hrp = char:FindFirstChild("HumanoidRootPart") end
        task.wait()
    until hrp or #GameData.Survivors < (IsKiller() and 1 or 2) or isUnloaded
    if hrp and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame
    end
end}

-- ------------------------------------------------------------------
-- AmberCore | 14 / Effect controls
-- ------------------------------------------------------------------
AntisTab:CreateSection('ต้านเอฟเฟกต์')
AntisTab:CreateToggle{Name='ต้านการช้าลง', CurrentValue=false, Flag='AntiSlowness', Callback=EmptyCallback}
AntisTab:CreateToggle{Name='ต้านซับสเปซ', CurrentValue=false, Flag='AntiSubspace', Callback=EmptyCallback}
AntisTab:CreateToggle{Name='ต้านตาบอด', CurrentValue=false, Flag='AntiBlindness', Callback=EmptyCallback}
AntisTab:CreateToggle{Name='ต้านกลิตช์', CurrentValue=false, Flag='AntiGlitched', Callback=EmptyCallback}
AntisTab:CreateToggle{Name='ต้านสโลว์/เอฟโอวีสเลทสกิน', CurrentValue=false, Flag='AntiSlateskin', Callback=EmptyCallback}
AntisTab:CreateToggle{Name='ต้านคลื่นไส้', CurrentValue=false, Flag='AntiNausea', Callback=EmptyCallback}
AntisTab:CreateToggle{Name='ต้านสตัน', CurrentValue=false, Flag='AntiStun', Callback=EmptyCallback}
AntisTab:CreateToggle{Name='ต้านภาพหลอน', CurrentValue=false, Flag='AntiHallu', Callback=EmptyCallback}
AntisTab:CreateToggle{Name='ต้านการช้าลงเมื่อตก', CurrentValue=false, Flag='AntiSlowOnLanding', Callback=function(v)

-- ===== ADDED: Antis extras (from Skidsaken) =====
AntisTab:CreateToggle{Name='ต้านเสียงก้าวเท้า', CurrentValue=false, Flag='AntiFootsteps', Callback=function(v)
    if v and LocalPlayer.Character then LocalPlayer.Character:SetAttribute('FootstepsMuted', true)
    elseif not v and LocalPlayer.Character then LocalPlayer.Character:SetAttribute('FootstepsMuted', false) end
end}
AntisTab:CreateToggle{Name='ต้านโคลน 007n7', CurrentValue=false, Flag='AntiClone007n7', Callback=function(v)
    if v then
        pcall(function()
            for _, obj in pairs(workspace.Map.Ingame:GetChildren()) do
                if obj.Name == '007n7' and obj:GetAttribute('Username') ~= LocalPlayer.Name then
                    obj:Destroy()
                end
            end
        end)
    end
end}

-- ADDED: Cheater detection system
AntisTab:CreateSection('ตรวจจับผู้ใช้แฮ็ก','Right')
local cheaters = {}
local cheatersnames = {}
local numcheaters = 0
local cheaterslabel = AntisTab:CreateParagraph{Title='ผู้ใช้แฮ็ก:', Content='ยังไม่พบ'}
AntisTab:CreateButton{Name='ล้างรายชื่อ', Callback=function()
    cheaters, cheatersnames, numcheaters = {}, {}, 0
end}
AntisTab:CreateToggle{Name='ตรวจจับการมองไม่เห็น', CurrentValue=true, Flag='ANTICHEAT_DETECTINVIS', Callback=EmptyCallback, TextMode=true}
AntisTab:CreateToggle{Name='ตรวจจับการเทเลพอร์ต', CurrentValue=true, Flag='ANTICHEAT_DETECTTELEPORT', Callback=EmptyCallback, TextMode=true}
AntisTab:CreateToggle{Name='ตรวจจับการกระโดดผิดกฎ', CurrentValue=true, Flag='ANTICHEAT_DETECTILLEGALJUMP', Callback=EmptyCallback, TextMode=true}
AntisTab:CreateToggle{Name='ตรวจจับแอนิเมชันผิดกฎ', CurrentValue=true, Flag='ANTICHEAT_DETECTANIMATIONS', Callback=EmptyCallback, TextMode=true}
AntisTab:CreateToggle{Name='ตรวจจับการเปลี่ยนแปลงผิดกฎ', CurrentValue=true, Flag='ANTICHEAT_DETECTSETTINGS', Callback=EmptyCallback, TextMode=true}
AntisTab:CreateToggle{Name='แจ้งเตือนเมื่อพบผู้ใช้แฮ็ก', CurrentValue=true, Flag='ANTICHEAT_NOTIFY', Callback=EmptyCallback, TextMode=true}

local positionstracker = {}
local function flagCheater(plr, reason)
    if not cheatersnames[plr.Name] then cheatersnames[plr.Name] = true end
    if not cheaters[plr] then
        numcheaters = numcheaters + 1
        cheaters[plr] = {reasons = {}}
    end
    if not table.find(cheaters[plr].reasons, reason) and Window.Flags.ANTICHEAT_NOTIFY.CurrentValue then
        UILibrary:Notify{Title='พบผู้ใช้แฮ็ก!', Content=plr.Name .. ' ทำการ "' .. reason .. '"', Duration=30}
        table.insert(cheaters[plr].reasons, reason)
    end
end

task.spawn(function()
    while not isUnloaded and Wait() do
        pcall(function()
            local text = ''
            if numcheaters == 0 then
                pcall(function() cheaterslabel:SetContent('ยังไม่พบ') end)
            else
                for plr, data in pairs(cheaters) do
                    text = text .. '\n' .. plr.Name .. ' (' .. table.concat(data.reasons, ', ') .. ')'
                end
                pcall(function() cheaterslabel:SetContent(text) end)
            end
            for _, plr in pairs(Players:GetPlayers()) do
                pcall(function()
                    if plr == LocalPlayer then return end
                    if not plr.Character or not plr.Character:FindFirstChild('HumanoidRootPart') then return end
                    local hrp = plr.Character.HumanoidRootPart
                    local hum = plr.Character:FindFirstChildOfClass('Humanoid')
                    if not hum or hum.Health <= 0 then return end
                    if plr.Character.Parent == SpectatingFolder then return end
                    if Window.Flags.ANTICHEAT_DETECTINVIS.CurrentValue then
                        if (hrp.Position.Y >= 500 or hrp.Position.Y <= -200) then
                            if not plr.Character:GetAttribute('INVISDETECTED') then
                                plr.Character:SetAttribute('INVISDETECTED', tick())
                            elseif tick() - plr.Character:GetAttribute('INVISDETECTED') >= 2 then
                                flagCheater(plr, 'invisibility')
                            end
                        else
                            plr.Character:SetAttribute('INVISDETECTED', nil)
                        end
                    end
                    if Window.Flags.ANTICHEAT_DETECTTELEPORT.CurrentValue then
                        if not positionstracker[plr] then
                            positionstracker[plr] = {position = hrp.Position, lastupd = tick()}
                        end
                        local tracked = positionstracker[plr]
                        if (tracked.position - hrp.Position).magnitude >= 50 and tick() - tracked.lastupd < 1 then
                            if not plr.Character:GetAttribute('TELEPORTS') then plr.Character:SetAttribute('TELEPORTS', 0) end
                            plr.Character:SetAttribute('TELEPORTS', plr.Character:GetAttribute('TELEPORTS') + 1)
                            if plr.Character:GetAttribute('TELEPORTS') > 1 then
                                flagCheater(plr, 'teleportation')
                            end
                        end
                        tracked.position = hrp.Position
                        tracked.lastupd = tick()
                    end
                    if Window.Flags.ANTICHEAT_DETECTILLEGALJUMP.CurrentValue and hum and hum:GetState() == Enum.HumanoidStateType.Jumping then
                        flagCheater(plr, 'illegal jump')
                    end
                end)
            end
        end)
    end
end)
    if v then task.spawn(function() while Wait() do if LocalPlayer.Character and Window.Flags.AntiSlowOnLanding.CurrentValue then LocalPlayer.Character:SetAttribute('NoFallSlow', true) end end end)
    elseif LocalPlayer.Character then LocalPlayer.Character:SetAttribute('NoFallSlow', false) end
end}

function HookEffect(effectModule, displayName, flagName)
    local oldApplied
    oldApplied = hookfunction(effectModule.Applied, newcclosure(function(...)
        if Window.Flags[flagName].CurrentValue then
            task.spawn(function() setthreadidentity(8) UILibrary:Notify{Title=string.format('Anti %s', tostring(displayName)), Content=string.format('Blocked a %s effect from happening', tostring(displayName)), Duration=6, Image='ban'} end)
            coroutine.yield()
        else
            return oldApplied(...)
        end
    end))
end

HookEffect(SlownessEffect, 'slowness', 'AntiSlowness')
HookEffect(SubspacedEffect, 'subspace', 'AntiSubspace')
HookEffect(BlindnessEffect, 'blindness', 'AntiBlindness')
HookEffect(GlitchedEffect, 'glitched', 'AntiGlitched')
HookEffect(SlateskinEffect, 'slateskin', 'AntiSlateskin')
HookEffect(NauseaEffect, 'nausea', 'AntiNausea')
HookEffect(StunnedEffect, 'stunn', 'AntiStun')
HookEffect(StunnedEffect, 'hallucinate', 'AntiHallu')

-- ------------------------------------------------------------------
-- AmberCore | 15 / Miscellaneous and cleanup
-- ------------------------------------------------------------------
MiscTab:CreateSection('หน้าต่าง')
function Unload()
    isUnloaded = true
    warn("Destroying ..!")
    visualizerPart:Destroy()
    UILibrary:Destroy()
    _G.globaluilibrary = nil
    GlobalEnv.executed = false
    pcall(function()
        GlobalEnv.InvisToggleButton:setEnabled(false) GlobalEnv.InvisToggleButton = nil
        GlobalEnv.BlockButton:setEnabled(false) GlobalEnv.BlockButton = nil
        GlobalEnv.RagButton:setEnabled(false) GlobalEnv.RagButton = nil
        if GlobalEnv.MobileToggle then GlobalEnv.MobileToggle:setEnabled(false) GlobalEnv.MobileToggle = nil end
    end)
    for _, func in ipairs(hookedFunctions) do pcall(restorefunction, func) end
    for key, tbl in pairs(GameData) do
        if tostring(key):find('EspAppliedTo') then
            for inst in pairs(tbl) do
                if inst:FindFirstChildOfClass('Highlight') then inst:FindFirstChildOfClass('Highlight'):Destroy() end
            end
        end
    end
    for _, flag in pairs(Window.Flags) do
        flag.CurrentValue = false
        flag.CurrentOption = {}
        flag.Set = EmptyCallback
    end
end

MiscTab:CreateButton{Name='ปิดสคริปต์', Callback=Unload}
MiscTab:CreateButton{Name='โหลดใหม่', Callback=function() Unload() loadstring(game:HttpGet('https://raw.githubusercontent.com/aibabylaugh/catsaken-real-script-not-assets/refs/heads/main/obfuscated-1448974601077002340.lua'))() end}
MiscTab:CreateButton{Name=(useLegacyUI and 'Disable' or '') .. ' หน้าต่างแบบเก่า', Callback=function()
    Unload()
    if useLegacyUI then delfile("BOOL_AmberCore_OLDUI") else writefile("BOOL_AmberCore_OLDUI","") end
    task.wait(1)
    loadstring(game:HttpGet('https://raw.githubusercontent.com/aibabylaugh/catsaken-real-script-not-assets/refs/heads/main/obfuscated-1448974601077002340.lua'))()
end}
if not useLegacyUI then
    MiscTab:CreateToggle{Name='ปุ่มสลับเมนูมือถือ', CurrentValue=true, Flag='MobileMenuToggle', Callback=function(v) GlobalEnv.MobileToggle:setEnabled(v) end}
end
MiscTab:CreateToggle{Name='ปิดการแจ้งเตือนอัปเดต', CurrentValue=false, Flag='DisableGitHubNotifications', Callback=EmptyCallback}
function fullbrightthedamnmap()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
end
MiscTab:CreateToggle{Name='สว่างทั้งแผนที่', CurrentValue=false, Flag='Fullbright', Callback=function(v) task.spawn(function() if v then while Window.Flags.Fullbright.CurrentValue do fullbrightthedamnmap() task.wait(3) end end end) end}

MiscTab:CreateSection('บล็อกปลอม','Right')
local selectedBlockAnim
setthreadidentity(8)
function FakeBlockCallback()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('Humanoid')
    if not hum then return end
    local anim = Instance.new("Animation")
    anim.AnimationId = selectedBlockAnim
    local track = hum:LoadAnimation(anim)
    track:Play()
end

if identifyexecutor() ~= "Cosmic" then
    local blockBtn = IconModule.new():setImage(tonumber'94723083650256'):setCaption('บล็อกปลอม'):oneClick():bindEvent('deselected', FakeBlockCallback):setEnabled(false)
    GlobalEnv.BlockButton = blockBtn
    setthreadidentity(8)
    local BlockAnims = { Normal = require(SurvivorAssets.Guest1337.Config).Animations.Block }
    selectedBlockAnim = BlockAnims.Normal
    local blockOptions = {'Normal'}
    for _, skin in ipairs(ReplicatedStorage.Assets.Skins.Survivors.Guest1337:GetChildren()) do
        if skin:FindFirstChild("Config") and (require(skin.Config).Animations or {}).Block ~= nil then
            local cfg = require(skin.Config)
            table.insert(blockOptions, cfg.DisplayName)
            BlockAnims[cfg.DisplayName] = cfg.Animations.Block
            task.spawn(function() ContentProvider:PreloadAsync{cfg.Animations.Block} end)
        end
    end
    MiscTab:CreateToggle{Name='บล็อกปลอม (แอนิเมชัน)', CurrentValue=false, Flag='FakeBlockUIToggle', Callback=function(v) blockBtn:setEnabled(v) end}
    if not isMobile then
        MiscTab:CreateKeybind{Name='Keybind', CurrentKeybind='B', Callback=FakeBlockCallback}
    end
    MiscTab:CreateDropdown{Name='แอนิเมชันบล็อก', Options=blockOptions, CurrentOption={'Normal'}, Flag='FakeBlockAnimation', Callback=function(v) selectedBlockAnim = BlockAnims[v[1]] end}
    MiscTab:CreateToggle{Name='เปลี่ยนแอนิเมชันบล็อก', CurrentValue=false, Flag='BlockAnimationChanger', Callback=EmptyCallback}
else
    MiscTab:CreateLabel("บล็อกปลอมไม่รองรับบน Cosmic")
end

local blockAnimIds = {}
local blockAnimConn
function TrackBlockChanger(char)
    local hrp = char and char:WaitForChild('HumanoidRootPart', 7)
    if not hrp then return end
    local hum = char:WaitForChild("Humanoid", 7)
    if not hum then return end
    local animator = hum:WaitForChild('Animator', 5)
    if not animator then return end
    local function MakeConnection()
        return animator.AnimationPlayed:Connect(function(track)
            if not table.find(blockAnimIds, track.Animation.AnimationId) then return end
            if not Window.Flags.BlockAnimationChanger.CurrentValue then return end
            track:Stop()
            local anim = Instance.new("Animation")
            anim.AnimationId = selectedBlockAnim
            local newTrack = hum:LoadAnimation(anim)
            blockAnimConn:Disconnect()
            newTrack:Play()
            blockAnimConn = MakeConnection()
        end)
    end
    blockAnimConn = MakeConnection()
end
SurvivorsFolder.ChildAdded:Connect(function(char)
    repeat Wait() until not char or char:GetAttribute('Username') or not char.Parent
    if char:GetAttribute('Username') == LocalPlayer.Name then TrackBlockChanger(char) end
end)
if LocalPlayer.Character then TrackBlockChanger(LocalPlayer.Character) end

MiscTab:CreateSection('ตายปลอม')
setthreadidentity(8)
local isRagdolled = false
function RagdollEnable()
    isRagdolled = true
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('Humanoid')
    if not hum then return end
    hum.PlatformStand = true
    RagdollModule.EnableRagdoll(LocalPlayer.Character)
end
function RagdollDisable()
    isRagdolled = false
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('Humanoid')
    if not hum then return end
    hum.PlatformStand = false
    RagdollModule.DisableRagdoll(LocalPlayer.Character)
end

if identifyexecutor() ~= "Cosmic" then
    local ragBtn = IconModule.new():setImage(tonumber'96754119500574'):setCaption('ตายปลอม / รากดอลล์'):bindEvent('selected', RagdollEnable):bindEvent('deselected', RagdollDisable):autoDeselect(false):setEnabled(false)
    GlobalEnv.RagButton = ragBtn
    setthreadidentity(8)
    MiscTab:CreateToggle{Name='ปุ่มรากดอลล์ (ไม่มีผลกับผู้เล่นคนอื่น)', CurrentValue=false, Flag='RagdollButtonToggle', Callback=function(v) ragBtn:setEnabled(v) end}
    if not isMobile then
        MiscTab:CreateKeybind{Name='Keybind', CurrentKeybind='Z', Callback=function()
            if not isRagdolled then ragBtn:select() setthreadidentity(8) RagdollEnable() else ragBtn:deselect() setthreadidentity(8) RagdollDisable() end
        end}
    end
else
    MiscTab:CreateLabel("รากดอลล์ไม่รองรับบน Cosmic")
end

if useLegacyUI then UILibrary:LoadConfiguration() end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Backspace and UserInputService:IsKeyDown(Enum.KeyCode.Delete) and UserInputService:IsKeyDown(Enum.KeyCode.KeypadMultiply) then
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer, game:GetService("TeleportService"):GetLocalPlayerTeleportData())
    end
end)

MiscTab:CreateSection('เพลง (หากไม่มีอะไรแสดง แสดงว่าไฟล์กำลังดาวน์โหลด)')

task.spawn(function()
    if useLegacyUI then
        UILibrary:LoadConfiguration()
        while not isUnloaded do
            local before = HttpService:JSONEncode(Window.Flags)
            task.wait(1)
            if isUnloaded then return end
            local after = HttpService:JSONEncode(Window.Flags)
            if after ~= before then
                warn("AutoSaving ...")
                writefile(activeConfigFile, after)
            end
        end
    end
end)

task.spawn(function()
    while MobileToggle and not isUnloaded do
        _G.globaluilibrary.Enabled = introFinished and MobileToggle.isSelected
        RunService.RenderStepped:Wait()
    end
end)

task.spawn(function()
    local url = "https://raw.githubusercontent.com/aibabylaugh/catsaken-real-script-not-assets/refs/heads/main/obfuscated-1448974601077002340.lua"
    local last = game:HttpGet(url)
    while not isUnloaded do
        task.wait(10)
        local current = game:HttpGet(url)
        if last ~= current and not Window.Flags.DisableGitHubNotifications.CurrentValue then
            last = current
            UILibrary:Notify{Title='GitHub', Content = 'ตรวจพบการเปลี่ยนแปลงใหม่บน GitHub ของ AmberCore อาจเป็นฟีเจอร์ใหม่หรือแค่แก้บั๊ก โหลดใหม่ได้เลยหรือภายหลัง', Duration=15, Image='scroll'}
        end
    end
end)

-- ------------------------------------------------------------------

-- ===== ADDED: Editor Tab implementation (character value editor, from Skidsaken) =====
do
    EditorTab:CreateSection('ตัวแก้ไขค่า')
    local function recursiveget(t, path)
        for key in string.gmatch(path, "[^%.]+") do
            t = rawget(t, key)
            if t == nil then return nil end
        end
        return t
    end
    local function recursivecheck(value, t)
        if value == t then return true end
        for _, child in pairs(t) do
            if type(child) == "table" and recursivecheck(value, child) then return true end
        end
        return false
    end
    local function recursiveset(t, path, value)
        local keys = {}
        for key in string.gmatch(path, "[^%.]+") do table.insert(keys, key) end
        local current = t
        for i = 1, #keys - 1 do
            local nxt = rawget(current, keys[i])
            if type(nxt) ~= "table" then nxt = {} rawset(current, keys[i], nxt) end
            current = nxt
        end
        rawset(current, keys[#keys], value)
    end
    local stats2edit = {
        [{'Sixer', true}] = {'PursuitMaxSpeed','PursuitLength','PursuitBaseSpeed'},
        [{'Nosferatu', true}] = {'AscentFlight.Duration'},
        [{'Noli', true}] = {'VoidRushChargeLength','VoidRushTurnSpeed','VoidRushInitialTurnMult','VoidRushChargingSpeed','VoidRushDashSpeed','VoidRushInitialTurnDuration'},
        [{'JaneDoe'}] = {'Crystal.MaxChargeTime','Crystal.ChargeSpeedMult','Crystal.MinChargeTime','Crystal.MaximumHoldTime','Axe.DashSpeed'},
        [{'TwoTime'}] = {'CrouchRunSpeed','CrouchSpeed','DaggerUncrouchedLungeForce','DaggerLungeForce'},
        [{'Guest1337'}] = {'ChargingSpeed','ChargingTurnSpeed'},
        [{'Veeronica'}] = {'Sk8BumpPower','Sk8TurnControl','Sk8TrickStamina','Sk8TrickCooldown','Sk8TrickTurnControl','Sk8TrickPower','Sk8Speed','Sk8TrickGravity','Sk8TrickJump'},
    }
    local editedvals = {}
    local name2edit = {}
    local killernames = {}
    local allnames = {}
    local defaultvalues = getgenv().FORSAKEN_defaultvalues or {}
    getgenv().FORSAKEN_defaultvalues = defaultvalues
    local editing = 'Sixer'
    local selectedkey
    local valueslabel
    local curvalue
    local savefolder = 'AmberCore/Editor/Configs'
    if not isfolder('AmberCore/Editor') then makefolder('AmberCore/Editor') end
    if not isfolder(savefolder) then makefolder(savefolder) end
    local function getSaveFiles()
        local files = {}
        for _, file in ipairs(listfiles(savefolder)) do table.insert(files, file:match("[^/\\]+$")) end
        table.sort(files)
        return files
    end
    for data, editables in pairs(stats2edit) do
        local name = data[1]
        if not defaultvalues[name] then defaultvalues[name] = {} end
        name2edit[name] = editables
        killernames[name] = data[2]
        allnames[name] = true
        for _, v in pairs(editables) do
            local config = require(ReplicatedStorage.Assets[data[2] and 'Killers' or 'Survivors'][name].Config)
            recursiveset(defaultvalues[name], v, recursiveget(config, v))
        end
    end
    local function updateeditgui()
        if not allnames[editing] then return end
        local valuesstring = 'D = ค่าเริ่มต้น\n' .. editing .. ':'
        local config = require(ReplicatedStorage.Assets[killernames[editing] and 'Killers' or 'Survivors'][editing].Config)
        for _, v in pairs(name2edit[editing]) do
            valuesstring = valuesstring .. '\n' .. v .. ': ' .. tostring(recursiveget(config, v)) .. ' (D=' .. tostring(recursiveget(defaultvalues[editing], v)) .. ')'
        end
        if valueslabel then pcall(function() valueslabel:SetContent(valuesstring) end) end
    end
    local editablenames = {}
    for data in pairs(stats2edit) do table.insert(editablenames, data[1]) end
    EditorTab:CreateDropdown{Name='เลือกตัวละคร', Options=editablenames, CurrentOption={'Sixer'}, Flag='SelectedEditCharacter', Callback=function(Options)
        editing = Options[1]
        updateeditgui()
    end}
    local selectkeydropdown = EditorTab:CreateDropdown{Name='เลือกคีย์', Options=name2edit[editing] or {}, CurrentOption={}, Flag='SelectedEditKey', Callback=function(Options)
        selectedkey = Options[1]
        if selectedkey then curvalue = recursiveget(defaultvalues[editing], selectedkey) end
    end}
    EditorTab:CreateInput{Name='ใส่ค่า', CurrentValue='', PlaceholderText='ค่า', Flag='SelectedEditValue', Callback=function(Text)
        curvalue = tonumber(Text) or Text
    end}
    EditorTab:CreateButton{Name='อัปเดตคีย์เป็นค่าที่ใส่', Callback=function()
        if not selectedkey then return UILibrary:Notify{Title='Editor', Content='กรุณาเลือกคีย์ก่อน', Duration=5} end
        if not editedvals[editing] then editedvals[editing] = {} end
        editedvals[editing][selectedkey] = curvalue
        for _, v in getgc(true) do
            if type(v) == 'table' and recursiveget(v, selectedkey) ~= nil and not recursivecheck(v, defaultvalues) then
                recursiveset(v, selectedkey, curvalue)
            end
        end
        updateeditgui()
        UILibrary:Notify{Title='Editor', Content='อัปเดต ' .. editing .. '.' .. selectedkey .. ' = ' .. tostring(curvalue), Duration=5}
    end}
    local function resetEditedValues()
        for character, changes in pairs(editedvals) do
            for key in pairs(changes) do
                local default = recursiveget(defaultvalues[character], key)
                if default ~= nil then
                    for _, v in getgc(true) do
                        if type(v) == 'table' and recursiveget(v, key) ~= nil and not recursivecheck(v, defaultvalues) then
                            recursiveset(v, key, default)
                        end
                    end
                end
            end
        end
        editedvals = {}
        updateeditgui()
    end
    EditorTab:CreateButton{Name='รีเซ็ตค่าทั้งหมด', Callback=resetEditedValues}
EditorTab:CreateSection('บันทึก','Right')
    local ToLoad = ''
    local saveDropdown = EditorTab:CreateDropdown{Name='เลือกไฟล์บันทึก', Options=getSaveFiles(), CurrentOption={}, Flag='EditorLoadSave', Callback=function(Options)
        if Options[1] then ToLoad = Options[1] end
    end}
    local function loadChanges(cfgname)
        if cfgname == '' or not isfile(savefolder .. '/' .. cfgname) then return end
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(savefolder .. '/' .. cfgname)) end)
        if success then
            resetEditedValues()
            editedvals = data
            for _, changes in pairs(editedvals) do
                for _, v in getgc(true) do
                    for key, value in pairs(changes) do
                        if type(v) == 'table' and recursiveget(v, key) ~= nil and not recursivecheck(v, defaultvalues) then
                            recursiveset(v, key, value)
                        end
                    end
                end
            end
            updateeditgui()
            UILibrary:Notify{Title='Editor', Content='โหลด "' .. cfgname .. '" สำเร็จ', Duration=5}
        end
    end
    EditorTab:CreateButton{Name='โหลดที่เลือก', Callback=function() loadChanges(ToLoad) end}
    EditorTab:CreateButton{Name='ลบที่เลือก', Callback=function()
        local path = savefolder .. '/' .. ToLoad
        if isfile(path) then delfile(path) UILibrary:Notify{Title='Editor', Content='ลบ "' .. ToLoad .. '" สำเร็จ', Duration=5}
        else UILibrary:Notify{Title='Editor', Content='ไม่พบไฟล์', Duration=5} end
    end}
    EditorTab:CreateInput{Name='ชื่อไฟล์บันทึก', CurrentValue='', PlaceholderText='ชื่อ', Flag='EditorSaveName', Callback=function(v) end}
    EditorTab:CreateButton{Name='บันทึก', Callback=function()
        local name = Window.Flags.EditorSaveName.CurrentValue
        if not name or name:gsub('%s+','') == '' then return UILibrary:Notify{Title='Editor', Content='กรุณาใส่ชื่อไฟล์', Duration=5} end
        name = name:gsub('[\\/:*?"<>|]', '_')
        writefile(savefolder .. '/' .. name, HttpService:JSONEncode(editedvals))
        UILibrary:Notify{Title='Editor', Content='บันทึก "' .. name .. '" สำเร็จ', Duration=5}
        pcall(function() saveDropdown:Refresh(getSaveFiles()) end)
    end}
    EditorTab:CreateButton{Name='รีเฟรชรายการบันทึก', Callback=function() pcall(function() saveDropdown:Refresh(getSaveFiles()) end) end}
    EditorTab:CreateButton{Name='ตั้งเป็น Auto-Load', Callback=function()
        local selected = Window.Flags.EditorLoadSave and Window.Flags.EditorLoadSave.CurrentOption
        if not selected or not selected[1] then
            return UILibrary:Notify{Title='Editor', Content='กรุณาเลือกไฟล์บันทึกก่อน', Duration=5}
        end
        local name = selected[1]
        pcall(function() writefile('AmberCore/editorautoload.txt', name) end)
        UILibrary:Notify{Title='Editor', Content='ตั้ง "' .. name .. '" เป็น Auto-Load แล้ว (โหลดอัตโนมัติครั้งถัดไป)', Duration=6}
    end}
    EditorTab:CreateButton{Name='ลบ Auto-Load ปัจจุบัน', Callback=function()
        if isfile('AmberCore/editorautoload.txt') then
            local name = readfile('AmberCore/editorautoload.txt')
            delfile('AmberCore/editorautoload.txt')
            UILibrary:Notify{Title='Editor', Content='ลบ Auto-Load "' .. name .. '" เรียบร้อย', Duration=5}
        else
            UILibrary:Notify{Title='Editor', Content='ไม่มี Auto-Load ที่ตั้งไว้', Duration=5}
        end
    end}
    EditorTab:CreateSection('ค่าปัจจุบัน')
    valueslabel = EditorTab:CreateParagraph{Title='ค่า', Content='กำลังโหลด...'}
    updateeditgui()
    task.defer(function()
        local selected = isfile('AmberCore/editorautoload.txt') and readfile('AmberCore/editorautoload.txt')
        if selected and isfile(savefolder .. '/' .. selected) then
            loadChanges(selected)
            UILibrary:Notify{Title='Editor', Content='Auto-Load: โหลด "' .. selected .. '" สำเร็จ', Duration=5}
        end
    end)
end

-- ===== ADDED: Audio Tab (FULLY FUNCTIONAL - plays real sounds) =====
do
    -- Create sound holder
    local SoundHolder = Instance.new('Folder')
    SoundHolder.Name = 'AmberCoreSounds'
    SoundHolder.Parent = game:GetService('SoundService')

    local function makeSound(name)
        local s = Instance.new('Sound')
        s.Name = name
        s.Volume = 1
        s.Parent = SoundHolder
        return s
    end

    local BlockSound = makeSound('BlockSuccess')
    local ParrySound = makeSound('ParrySound')
    local PunchSound = makeSound('PunchSound')

    local blockId, blockFile, parryId, parryFile, punchId, punchFile = '', '', '', '', '', ''

    local function resolveSound(idText, fileText)
        if idText and idText ~= '' then
            if tonumber(idText) then return 'rbxassetid://' .. idText end
            if idText:find('rbxassetid://') or idText:find('http') then return idText end
        end
        if fileText and fileText ~= '' and isfile(fileText) then
            local ok, asset = pcall(function() return getcustomasset(fileText) end)
            if ok and asset then return asset end
        end
        return nil
    end

    local function refreshSounds()
        local b = resolveSound(blockId, blockFile)
        if b then pcall(function() BlockSound.SoundId = b end) end
        local p = resolveSound(parryId, parryFile)
        if p then pcall(function() ParrySound.SoundId = p end) end
        local pu = resolveSound(punchId, punchFile)
        if pu then pcall(function() PunchSound.SoundId = pu end) end
    end

    -- Hook into notifications to detect block/parry/punch success and play sounds
    local OldNotify = UILibrary.Notify
    UILibrary.Notify = function(self, p, ...)
        pcall(function()
            local title = (p and p.Title) or ''
            if title:find('บล็อก') or title:find('Block') then
                if BlockSound.SoundId ~= '' then BlockSound:Play() end
            elseif title:find('ปาร์รี่') or title:find('Parry') or title:find('เรจจิ้งเพซ') then
                if ParrySound.SoundId ~= '' then ParrySound:Play() end
            elseif title:find('ต่อย') or title:find('Punch') then
                if PunchSound.SoundId ~= '' then PunchSound:Play() end
            end
        end)
        return OldNotify(self, p, ...)
    end

    AudioTab:CreateSection('เสียงบล็อก / ปาร์รี่ / ต่อย')
    AudioTab:CreateParagraph{Title='วิธีใช้', Content='ใส่ Asset ID (ตัวเลข) หรือชื่อไฟล์เสียงใน workspace เสียงจะเล่นอัตโนมัติเมื่อบล็อก/ปาร์รี่/ต่อยสำเร็จ'}
    AudioTab:CreateInput{Name='เสียงบล็อกสำเร็จ | Asset ID', CurrentValue='', PlaceholderText='เช่น 1234567890', Flag='BlockSuccessID', Callback=function(v) blockId = v refreshSounds() end}
    AudioTab:CreateInput{Name='เสียงบล็อกสำเร็จ | ไฟล์', CurrentValue='', PlaceholderText='ชื่อไฟล์ใน workspace', Flag='BlockSuccessFile', Callback=function(v)
        blockFile = v
        if v ~= '' and not isfile(v) then
            UILibrary:Notify{Title='ไฟล์ไม่ถูกต้อง', Content='"' .. v .. '" ไม่มีอยู่จริง', Duration=8}
            blockFile = ''
        else
            refreshSounds()
        end
    end}
    AudioTab:CreateInput{Name='เสียงปาร์รี่ | Asset ID', CurrentValue='', PlaceholderText='เช่น 1234567890', Flag='ParryID', Callback=function(v) parryId = v refreshSounds() end}
    AudioTab:CreateInput{Name='เสียงปาร์รี่ | ไฟล์', CurrentValue='', PlaceholderText='ชื่อไฟล์ใน workspace', Flag='ParryFile', Callback=function(v)
        parryFile = v
        if v ~= '' and not isfile(v) then
            UILibrary:Notify{Title='ไฟล์ไม่ถูกต้อง', Content='"' .. v .. '" ไม่มีอยู่จริง', Duration=8}
            parryFile = ''
        else
            refreshSounds()
        end
    end}
    AudioTab:CreateInput{Name='เสียงต่อย | Asset ID', CurrentValue='', PlaceholderText='เช่น 1234567890', Flag='PunchID', Callback=function(v) punchId = v refreshSounds() end}
    AudioTab:CreateInput{Name='เสียงต่อย | ไฟล์', CurrentValue='', PlaceholderText='ชื่อไฟล์ใน workspace', Flag='PunchFile', Callback=function(v)
        punchFile = v
        if v ~= '' and not isfile(v) then
            UILibrary:Notify{Title='ไฟล์ไม่ถูกต้อง', Content='"' .. v .. '" ไม่มีอยู่จริง', Duration=8}
            punchFile = ''
        else
            refreshSounds()
        end
    end}
    AudioTab:CreateToggle{Name='ปิดเสียงความโกรธ (Rage SFX)', CurrentValue=false, Flag='SilenceRageSFX', Callback=function(v)
        task.spawn(function()
            while Window.Flags.SilenceRageSFX and Window.Flags.SilenceRageSFX.CurrentValue and not isUnloaded do
                pcall(function()
                    for _, s in pairs(workspace:GetDescendants()) do
                        if s:IsA('Sound') and (s.Name:lower():find('rage') or s.Name:lower():find('chase') or s.Name:lower():find('terror')) then
                            s.Volume = 0
                        end
                    end
                end)
                Wait(1)
            end
        end)
    end}

    -- Chase Theme changer
AudioTab:CreateSection('เพลงตอนไล่ล่า (Chase Theme)','Right')
    AudioTab:CreateParagraph{Title='ข้อมูล', Content='จะเปลี่ยนเพลงไล่ล่าในเกมเป็นเพลงที่คุณเลือก (ใส่ Asset ID หรือไฟล์)'}
    AudioTab:CreateToggle{Name='เปิดใช้งานเปลี่ยนเพลงไล่ล่า', CurrentValue=false, Flag='ChangeChaseTheme', Callback=function(v)
        if v then
            task.spawn(function()
                while Window.Flags.ChangeChaseTheme and Window.Flags.ChangeChaseTheme.CurrentValue and not isUnloaded do
                    pcall(function()
                        local custom = resolveSound(
                            Window.Flags.CustomChaseID and Window.Flags.CustomChaseID.CurrentValue or '',
                            Window.Flags.CustomChaseFile and Window.Flags.CustomChaseFile.CurrentValue or ''
                        )
                        if custom then
                            for _, s in pairs(workspace.Themes:GetChildren()) do
                                if s:IsA('Sound') and (s.Name:lower():find('chase') or s.Name:lower():find('terror') or s.Name:lower():find('pursuit')) then
                                    if not s:GetAttribute('AmberCoreRealId') then
                                        s:SetAttribute('AmberCoreRealId', s.SoundId)
                                    end
                                    s.SoundId = custom
                                end
                            end
                        end
                    end)
                    Wait(3)
                end
            end)
        else
            pcall(function()
                for _, s in pairs(workspace.Themes:GetChildren()) do
                    if s:IsA('Sound') and s:GetAttribute('AmberCoreRealId') then
                        s.SoundId = s:GetAttribute('AmberCoreRealId')
                    end
                end
            end)
        end
    end}
    AudioTab:CreateInput{Name='เพลงไล่ล่า | Asset ID', CurrentValue='', PlaceholderText='เช่น 1234567890', Flag='CustomChaseID', Callback=function(v) end}
    AudioTab:CreateInput{Name='เพลงไล่ล่า | ไฟล์', CurrentValue='', PlaceholderText='ชื่อไฟล์ใน workspace', Flag='CustomChaseFile', Callback=function(v)
        if v ~= '' and not isfile(v) then
            UILibrary:Notify{Title='ไฟล์ไม่ถูกต้อง', Content='"' .. v .. '" ไม่มีอยู่จริง', Duration=8}
        end
    end}

    -- Lobby Music changer
    AudioTab:CreateSection('เพลงล็อบบี้ (Lobby Music)')
    AudioTab:CreateParagraph{Title='ข้อมูล', Content='เปลี่ยนเพลงพื้นหลังในล็อบบี้ (spectreOutside)'}
    AudioTab:CreateToggle{Name='เปิดใช้งานเปลี่ยนเพลงล็อบบี้', CurrentValue=false, Flag='ChangeLobbyMusic', Callback=function(v)
        if v then
            task.spawn(function()
                while Window.Flags.ChangeLobbyMusic and Window.Flags.ChangeLobbyMusic.CurrentValue and not isUnloaded do
                    pcall(function()
                        local custom = resolveSound(
                            Window.Flags.CustomLobbyID and Window.Flags.CustomLobbyID.CurrentValue or '',
                            Window.Flags.CustomLobbyFile2 and Window.Flags.CustomLobbyFile2.CurrentValue or ''
                        )
                        if custom then
                            local Sound = workspace.Themes:FindFirstChild('spectreOutside')
                            if Sound and Sound:IsA('Sound') then
                                if not Sound:GetAttribute('AmberCoreRealId') then
                                    Sound:SetAttribute('AmberCoreRealId', Sound.SoundId)
                                end
                                Sound.TimePosition = 0
                                Sound.SoundId = custom
                            end
                        end
                    end)
                    Wait(3)
                end
            end)
        else
            pcall(function()
                local Sound = workspace.Themes:FindFirstChild('spectreOutside')
                if Sound and Sound:GetAttribute('AmberCoreRealId') then
                    Sound.SoundId = Sound:GetAttribute('AmberCoreRealId')
                end
            end)
        end
    end}
    AudioTab:CreateInput{Name='เพลงล็อบบี้ | Asset ID', CurrentValue='', PlaceholderText='เช่น 1234567890', Flag='CustomLobbyID', Callback=function(v) end}
    AudioTab:CreateInput{Name='เพลงล็อบบี้ | ไฟล์', CurrentValue='', PlaceholderText='ชื่อไฟล์ใน workspace', Flag='CustomLobbyFile2', Callback=function(v)
        if v ~= '' and not isfile(v) then
            UILibrary:Notify{Title='ไฟล์ไม่ถูกต้อง', Content='"' .. v .. '" ไม่มีอยู่จริง', Duration=8}
        end
    end}

    AudioTab:CreateSection('เพลงผู้รอดคนสุดท้าย (LMS)')
    AudioTab:CreateParagraph{Title='ข้อมูล', Content='LMS Changer มีอยู่แล้วในแท็บ เบ็ดเตล็ด สามารถใช้งานได้ทันที'}
end
-- AmberCore | 16 / Configuration manager
-- ------------------------------------------------------------------
function cfgmanager()
    if not isfile("AmberCoreautoload.txt") then writefile("AmberCoreautoload.txt", activeConfigFile) end
    local allConfigs
    local function refreshcfgs() allConfigs = HttpService:JSONDecode(readfile("AmberCoreconfigs.json")) end
    refreshcfgs()
    ConfigsTab:CreateSection('คอนฟิก')
    local currentConfig = readfile("AmberCoreautoload.txt")
    local newConfigName = "NewConfig"
    local dropdown = ConfigsTab:CreateDropdown{
        Name='คอนฟิกที่เลือก',
        Options=(function() local t={} for k in pairs(allConfigs) do table.insert(t,k) end return t end)(),
        CurrentOption={currentConfig},
        Flag='currentcfgselect',
        Callback=function(v) currentConfig = v[1] end
    }
    ConfigsTab:CreateButton{Name='เขียนทับที่เลือก', Callback=function()
        Window.Flags.currentcfgname = {CurrentValue=""}
        Window.Flags.currentcfgselect = {CurrentOption={currentConfig}}
        local copy = deepcopy(HttpService:JSONDecode(readfile('AmberCoreconfigs.json')))
        copy[currentConfig] = deepcopy(Window.Flags)
        writefile("AmberCoreconfigs.json", HttpService:JSONEncode(copy))
        UILibrary:Notify{Title='เสร็จแล้ว', Content = 'บันทึกคอนฟิกแล้ว', Duration=15, Image='scroll'}
    end}
    ConfigsTab:CreateInput{Name="ชื่อคอนฟิก", CurrentValue=newConfigName, PlaceholderText="ข้อความ", Flag="currentcfgname", Callback=function(v) newConfigName = v .. '.json' end}
    ConfigsTab:CreateButton{Name='บันทึกคอนฟิก', Callback=function()
        local copy = deepcopy(HttpService:JSONDecode(readfile('AmberCoreconfigs.json')))
        if copy[newConfigName] then return UILibrary:Notify{Title='ล้มเหลว', Content = 'มีคอนฟิกนี้อยู่แล้ว รีเฟรชรายการแล้วเขียนทับ', Duration=15, Image='scroll'} end
        Window.Flags.currentcfgname = {CurrentValue=""}
        Window.Flags.currentcfgselect = {CurrentOption={newConfigName}}
        copy[newConfigName] = deepcopy(Window.Flags)
        writefile("AmberCoreconfigs.json", HttpService:JSONEncode(copy))
        UILibrary:Notify{Title='เสร็จแล้ว', Content = 'บันทึกคอนฟิกแล้ว', Duration=15, Image='scroll'}
    end}
    ConfigsTab:CreateButton{Name='ลบที่เลือก', Callback=function()
        if currentConfig == ("AmberCore-default-" .. LocalPlayer.Name .. ".json") then return UILibrary:Notify{Title='ข้อผิดพลาด', Content = 'คุณไม่สามารถลบคอนฟิกเริ่มต้นของบัญชีได้', Duration=15, Image='scroll'} end
        local copy = deepcopy(HttpService:JSONDecode(readfile('AmberCoreconfigs.json')))
        copy[currentConfig] = nil
        writefile("AmberCoreconfigs.json", HttpService:JSONEncode(copy))
        UILibrary:Notify{Title='เสร็จแล้ว', Content = 'ลบคอนฟิกแล้ว', Duration=15, Image='scroll'}
    end}
    ConfigsTab:CreateButton{Name='โหลดที่เลือก', Callback=function()
        writefile("AmberCoreautoload.txt", currentConfig)
        Unload()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/aibabylaugh/catsaken-real-script-not-assets/refs/heads/main/obfuscated-1448974601077002340.lua'))()
    end}
    ConfigsTab:CreateButton{Name='รีเฟรชรายการ', Callback=function()

-- ===== ADDED: Config Export/Import (Base64, from Skidsaken) =====
ConfigsTab:CreateSection('ส่งออก/นำเข้า (Base64)','Right')
ConfigsTab:CreateInput{Name='ชื่อที่จะส่งออก', CurrentValue='', PlaceholderText='ข้อความ', Flag='cfgexportname', Callback=function(v) end}
ConfigsTab:CreateButton{Name='ส่งออกเป็น Base64 และคัดลอก', Callback=function()
    local copy = {}
    for k, v in pairs(Window.Flags) do
        if typeof(v) == 'table' and v.CurrentValue ~= nil then
            copy[k] = {CurrentValue = v.CurrentValue}
        elseif typeof(v) == 'table' and v.CurrentOption ~= nil then
            copy[k] = {CurrentOption = v.CurrentOption}
        end
    end
    local settings = HttpService:JSONEncode(copy)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local encoded = ''
    local i = 1
    while i <= #settings do
        local c1 = string.byte(settings, i) or 0
        local c2 = string.byte(settings, i+1) or 0
        local c3 = string.byte(settings, i+2) or 0
        local e1 = math.floor(c1 / 4)
        local e2 = (c1 % 4) * 16 + math.floor(c2 / 16)
        local e3 = (c2 % 16) * 4 + math.floor(c3 / 64)
        local e4 = c3 % 64
        encoded = encoded .. b:sub(e1+1, e1+1) .. b:sub(e2+1, e2+1)
        if i+1 <= #settings then encoded = encoded .. b:sub(e3+1, e3+1) else encoded = encoded .. '=' end
        if i+2 <= #settings then encoded = encoded .. b:sub(e4+1, e4+1) else encoded = encoded .. '=' end
        i = i + 3
    end
    pcall(function() setclipboard(encoded) end)
    UILibrary:Notify{Title='เสร็จแล้ว', Content='คัดลอก ' .. #encoded .. ' ตัวอักษรไปยังคลิปบอร์ดแล้ว', Duration=10}
end}
ConfigsTab:CreateInput{Name='วาง Base64 เพื่อนำเข้า', CurrentValue='', PlaceholderText='วางที่นี่', Flag='cfgimporttext', Callback=function(v) end}
ConfigsTab:CreateButton{Name='นำเข้า', Callback=function()
    local encoded = Window.Flags.cfgimporttext.CurrentValue
    if not encoded or encoded == '' then
        return UILibrary:Notify{Title='ข้อผิดพลาด', Content='กรุณาวาง Base64 ก่อน', Duration=8}
    end
    local s, r = pcall(function()
        local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
        local decoded = ''
        encoded = encoded:gsub('[^'..b..'=]', '')
        local i = 1
        while i <= #encoded do
            local e1 = b:find(encoded:sub(i,i), 1, true) - 1
            local e2 = b:find(encoded:sub(i+1,i+1), 1, true) - 1
            local e3c = encoded:sub(i+2,i+2)
            local e4c = encoded:sub(i+3,i+3)
            local e3 = e3c ~= '=' and (b:find(e3c, 1, true) - 1) or 0
            local e4 = e4c ~= '=' and (b:find(e4c, 1, true) - 1) or 0
            local c1 = e1 * 4 + math.floor(e2 / 16)
            local c2 = (e2 % 16) * 16 + math.floor(e3 / 4)
            local c3 = (e3 % 4) * 64 + e4
            decoded = decoded .. string.char(c1)
            if e3c ~= '=' then decoded = decoded .. string.char(c2) end
            if e4c ~= '=' then decoded = decoded .. string.char(c3) end
            i = i + 4
        end
        local config = HttpService:JSONDecode(decoded)
        local configs = HttpService:JSONDecode(readfile('AmberCoreconfigs.json'))
        local name = (Window.Flags.cfgexportname and Window.Flags.cfgexportname.CurrentValue ~= '' and Window.Flags.cfgexportname.CurrentValue) or ('Imported-' .. os.time()) .. '.json'
        configs[name] = config
        writefile('AmberCoreconfigs.json', HttpService:JSONEncode(configs))
        UILibrary:Notify{Title='เสร็จแล้ว', Content='นำเข้า "' .. name .. '" สำเร็จ', Duration=10}
    end)
    if not s then
        UILibrary:Notify{Title='ข้อผิดพลาด', Content='นำเข้าไม่สำเร็จ: Base64 ไม่ถูกต้อง', Duration=10}
    end
end}
        refreshcfgs()
        dropdown.Refresh((function() local t={} for k in pairs(allConfigs) do table.insert(t,k) end return t end)())
    end}
    ConfigsTab:CreateLabel("หากต้องการตั้งค่าให้โหลดอัตโนมัติ เพียงเลือกคอนฟิกนั้นแล้วกดโหลด จากนั้นมันจะกลายเป็นการโหลดอัตโนมัติ")
end

if useLegacyUI then
    ConfigsTab:CreateLabel('คุณไม่สามารถสร้างหลายคอนฟิกได้บน Rayfield')
else
    cfgmanager()
end

assetsPrepared = true

-- ------------------------------------------------------------------
-- AmberCore | 17 / Audio settings
-- ------------------------------------------------------------------
local lmsDisabled = false
local lmsData = { Names={"Custom"}, Data={} }
if not lmsDisabled then
    local apiData = HttpService:JSONDecode(game:HttpGet('https://api.github.com/repos/aibabylaugh/catsaken/contents/lms'))
    for _, file in ipairs(apiData) do
        pcall(function()
            local name = file.name:sub(1,-5)
            local content
            if isfile(string.format('AmberCore/%s', tostring(name))) then
                content = readfile(string.format('AmberCore/%s', tostring(name)))
            else
                content = game:HttpGet(file.download_url)
            end
            if not content then return end
            Wait()
            lmsData.Data[name] = content
            table.insert(lmsData.Names, name)
        end)
    end
end

local selectedLms = isfile("AmberCore/Selectedlms") and readfile("AmberCore/Selectedlms") or "None"
function Changelms()
    if selectedLms == 'None' then return end
    local theme = workspace.Themes:WaitForChild('LastSurvivor', 5)
    if not theme then return end
    local customId = Window.Flags.CustomLMSID.CurrentValue
    local customFile = Window.Flags.CustomLMSFile.CurrentValue
    local soundId
    if customId ~= "" and tonumber(customId) then
        soundId = "rbxassetid://" .. customId
    else
        if customFile ~= "" or selectedLms == "Custom" then
            soundId = getcustomasset(customFile)
        else
            soundId = getcustomasset(string.format('AmberCore/%s', tostring(selectedLms)))
        end
    end
    theme.SoundId = soundId
end

MiscTab:CreateDropdown{
    Name='ธีม LMS (ผู้รอดคนสุดท้าย)',
    Options=lmsData.Names,
    CurrentOption={selectedLms},
    Flag='LMSSelectedTheme',
    Callback=function(v)
        repeat task.wait() until Window.Flags.LastManStandingChanger ~= nil
        local name = v[1]
        writefile("AmberCore/Selectedlms", name)
        selectedLms = name
        if name == 'Custom' then return end
        local data = lmsData.Data[name]
        if data and not isfile(string.format('AmberCore/%s', tostring(name))) then
            warn("writing lms")
            writefile(string.format('AmberCore/%s', tostring(name)), data)
        end
        if Window.Flags.LastManStandingChanger.CurrentValue then Changelms() end
    end
}
MiscTab:CreateInput{Name="ID เพลง LMS แบบกำหนดเอง", CurrentValue=isfile("AmberCore/CustomLMSID") and readfile("AmberCore/CustomLMSID") or "", PlaceholderText="เว้นว่างหากไม่ใช้", Flag="CustomLMSID", Callback=function(v) writefile("AmberCore/CustomLMSID", v) end}
MiscTab:CreateInput{Name="ไฟล์เพลง LMS แบบกำหนดเอง", CurrentValue=isfile("AmberCore/CustomLMSFile") and readfile("AmberCore/CustomLMSFile") or "", PlaceholderText="เว้นว่างหากไม่ใช้", Flag="CustomLMSFile", Callback=function(v)
    writefile("AmberCore/CustomLMSFile", v)
    if v == '' then return end
    if not isfile(v) then
        UILibrary:Notify{Title='ไฟล์ไม่ถูกต้อง', Content='"' .. v .. '" is not an existing file', Duration=8, Image='ban'}
    else
        UILibrary:Notify{Title='พบไฟล์', Content = 'พบไฟล์ในระบบ กรุณาเปลี่ยนธีม LMS ที่เลือกเป็น Custom', Duration=8, Image='check'}
    end
end}
MiscTab:CreateToggle{Name='เปลี่ยน LMS', CurrentValue=(type(isfile)=='function' and isfile('AmberCore/LmsChangerEnabled')) or false, Flag='LastManStandingChanger', Callback=function(v) if v then task.spawn(function() if type(writefile)=='function' then writefile('AmberCore/LmsChangerEnabled','') end end) pcall(Changelms) else task.spawn(function() if type(delfile)=='function' then delfile('AmberCore/LmsChangerEnabled') end end) end end}

-- ===== ADDED: Misc extras (from Skidsaken) =====
MiscTab:CreateButton{Name='ล้างการแจ้งเตือนทั้งหมด', Callback=function()
    pcall(function()
        for _, n in pairs(gethui():GetChildren()) do
            if n:IsA('ScreenGui') and n.Name:find('Fluent') then n:Destroy() end
        end
    end)
end}
MiscTab:CreateToggle{Name='โหมด Blatant (ปลดล็อกฟีเจอร์เสี่ยง)', CurrentValue=false, Flag='BlatantModeEnabled', Callback=function(v)
    if v then
        UILibrary:Notify{Title='Blatant Mode', Content='เปิดใช้งานฟีเจอร์เสี่ยงแล้ว ใช้ด้วยความระมัดระวัง!', Duration=10}
    end
end}
MiscTab:CreateDropdown{Name='โหมดแถบบน (Topbar)', Options={'ไอคอน + ชื่อ','ชื่ออย่างเดียว','ไอคอนอย่างเดียว'}, CurrentOption={'ไอคอน + ชื่อ'}, Flag='TopbarMode', Callback=EmptyCallback}

-- ADDED: Round timer position editor
MiscTab:CreateSection('ตำแหน่งจับเวลารอบ','Left')
MiscTab:CreateSlider{Name='จับเวลา X', Range={-100,200}, Increment=1, Suffix='%', CurrentValue=50, Flag='RoundTimerX', Callback=function(num)
    rt.Position = UDim2.new(num/100, rt.Position.X.Offset, rt.Position.Y.Scale, rt.Position.Y.Offset)
end}
MiscTab:CreateSlider{Name='จับเวลา Y', Range={-100,200}, Increment=1, Suffix='%', CurrentValue=0, Flag='RoundTimerY', Callback=function(num)
    rt.Position = UDim2.new(rt.Position.X.Scale, rt.Position.X.Offset, num/100, rt.Position.Y.Offset)
end}
MiscTab:CreateToggle{Name='แสดงเฉพาะเวลา', CurrentValue=false, Flag='RoundTimerHideBG', Callback=function(v)
    rt.ImageTransparency = v and 1 or 0
end}
MiscTab:CreateToggle{Name='└── ซ่อนสถานะ', CurrentValue=false, Flag='RoundTimerHideTitle', Callback=function(v)
    if rt:FindFirstChild('Title') then rt.Title.TextTransparency = v and 1 or 0 end
end, TextMode=true}
workspace.Themes.ChildAdded:Connect(function(child) if child.Name == 'LastSurvivor' and Window.Flags.LastManStandingChanger.CurrentValue then Changelms() end end)




-- ===== MERGED from Script.txt: functions not present in Forsaken.lua =====
-- 25 functions merged. Local functions converted to global so they can be called.
-- Skipped: Rayfield:Notify / Rayfield:DeleteNotifications / Rayfield:ChangeNotificationLayout (require Rayfield lib loaded from URL).
-- Skipped: SprintModule.Init / anticheat:runDetection (require local tables that don't exist in Forsaken).
-- Skipped: all Rayfield/Lunar UI library internals (Tab:Create*, Window:*, Library:*, SmoothScroll, Tooltip, Loader, OnScreenTracker) - closure-dependent, not portable standalone.

-- [merged] safehttpget (from Script.txt lines 204-239)
function safehttpget(...)
    local n = tick()
    local result
    task.spawn(function(...)
        local s, r = pcall(function(...)
            return game:HttpGet(...)
        end, ...)
        if not s then
            if not LPH_OBFUSCATED then
                warn("link that failed:", ...)
            end
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Skidsaken",
                Text = "the network failed to request! script may error",
                Duration = 15;
            })
        else
            result = r
        end
    end, ...)
    repeat
        if tick() - n >= 10 then
            if not LPH_OBFUSCATED then
                warn("link that failed:", ...)
            end
            if not Unloaded then game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Skidsaken",
                Text = "the network failed to request!",
                Duration = 7;
            }) end
            return
        end
        wait()
    until result or unloaded
    return result;
end

-- [merged] onkick (from Script.txt lines 250-252)
function onkick(msg)
    Unload()
end

-- [merged] errorcore (from Script.txt lines 254-262)
function errorcore(text)
    pcall(QUITLOADING)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = 'Error';
        Text = (tostring(text)),
        Duration = 10;
        Button1 = "ok";
    })
end

-- [merged] AddTextLabel (from Script.txt lines 6772-6809)
function AddTextLabel(Object, ColorFlag, OptionFlag, Display, StrokeColor)
    local bb = Instance.new("BillboardGui", Object)
    bb.AlwaysOnTop = true
    bb.StudsOffset = Vector3.new(0, 2.2, 0)
    bb.Size = UDim2.new(1, 40, 1, 0)
    bb.Name = 'EspTL'
    bb.ResetOnSpawn = false
    local tl = Instance.new("TextLabel", bb)
    tl.Size = UDim2.new(1, 0, 1, 0)
    tl.TextSize = 14
    tl.Font = Enum.Font.GothamMedium
    tl.BackgroundTransparency = 1
    task.spawn(function()
        while Object.Parent do
            if (Unloaded) then warn('ending text esp because unload') break end
            if (Skidsaken.Flags[OptionFlag].CurrentValue) then
                if (typeof(Display) == 'table') then
                    if tl.Text then pcall(function() tl.Text = Display.Text() end) end
                    if Display.Font then tl.Font = Display.Font end
                    if Display.TextSize then tl.TextSize = Display.TextSize end
                    if Display.Offset then bb.StudsOffset = Vector3.new(0, Display.Offset, 0) end
                else
                    tl.Text = Display
                end
                if (StrokeColor) then
                    tl.TextStrokeTransparency = 0
                    tl.TextStrokeColor3 = StrokeColor
                end
                tl.TextColor3 = Skidsaken.Flags[ColorFlag].Color
            else
                bb:Destroy()
                break
            end
            wait(0.5)
        end
        bb:Destroy()
    end)
end

-- [merged] AddAbilitiesContainer (from Script.txt lines 6811-6831)
function AddAbilitiesContainer(HRP)
    local bb = Instance.new("BillboardGui", HRP)
    bb.AlwaysOnTop = false
    bb.StudsOffset = Vector3.new(0, 6, 0)
    bb.Size = UDim2.new(0, 240, 0, 50)
    bb.Name = 'Abilities'
    bb.MaxDistance = 80
    bb.ResetOnSpawn = false

    local frame = Instance.new("Frame", bb)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1

    local list = Instance.new("UIListLayout", frame)
    list.FillDirection = Enum.FillDirection.Horizontal
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    list.VerticalAlignment = Enum.VerticalAlignment.Center
    list.Padding = UDim.new(0, 30)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    return frame
end

-- [merged] AddAbilityIntoContainer (from Script.txt lines 6833-6863)
function AddAbilityIntoContainer(name, bb, img, cd, lo)
    name = name:gsub('Walkspeed Override', 'WS Override')
    local ability = Instance.new('ImageLabel', bb)
    ability.Size = UDim2.new(0, 50, 0, 50)
    ability.BackgroundTransparency = 1
    ability.Image = img
    ability.LayoutOrder = lo

    local tl = Instance.new("TextLabel", ability)
    tl.Size = UDim2.new(1, 0, 1, 0)
    tl.TextSize = 12
    tl.Font = Enum.Font.RobotoMono
    tl.BackgroundTransparency = 1
    tl.TextColor3 = Color3.fromRGB(255, 255, 255)
    tl.TextStrokeTransparency = 0
    tl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    tl.AnchorPoint = Vector2.new(0.5, 0)
    tl.Position = UDim2.new(0.5, 0, 1, - 4)

    task.spawn(function()
        local start = tick()
        while tick() - start <= cd do
            if (Unloaded) then
                return bb:Destroy()
            end
            tl.Text = ('%s\n%.1fs'):format(name, cd - (tick() - start))
            wait(0.1)
        end
        ability:Destroy()
    end)
end

-- [merged] InterceptAudio (from Script.txt lines 6913-6916)
function InterceptAudio(v, newid)
    print('replacing', v, 'with', newid)
    v.SoundId = newid
end

-- [merged] GetConfig (from Script.txt lines 6936-6940)
function GetConfig()
    local Char = LocalPlayer.Character
    local p = Char and Char.Parent and (Char.Parent.Name == 'Killers' and MainKillersPath or MainSurvivorsPath)
    return p and p:FindFirstChild(Char.Name) and require(p[Char.Name].Config)
end

-- [merged] UpdateStaminas (from Script.txt lines 6941-6953)
function UpdateStaminas()
    local Changed
    for Name, Val in Values do
        if (SprintModule[Name] ~= tonumber(Val)) then
            Changed = true
            SprintModule[Name] = tonumber(Val)
            UpdateStamina()
        end
    end
    if Changed then
        SprintModule.__staminaChangedEvent:Fire()
    end
end

-- [merged] Turn360 (from Script.txt lines 7310-7334)
function Turn360(LocalPlayerRoot, StartCFrame)
    local Start = tick()

    while tick() - Start < 0.5 do
        LocalPlayerRoot.CFrame = StartCFrame * CFrame.Angles(
            0,
            math.rad((tick() - Start) / 0.5 * 252),
            0
        )
        wait()
    end

    Start = tick()

    while tick() - Start < 0.3 do
        LocalPlayerRoot.CFrame = StartCFrame * CFrame.Angles(
            0,
            math.rad(252 + (tick() - Start) / 0.3 * 108),
            0
        )
        wait()
    end

    LocalPlayerRoot.CFrame = StartCFrame * CFrame.Angles(0, math.rad(360), 0)
end

-- [merged] SSearch (from Script.txt lines 4938-4962)
function SSearch(SurvivorName, Attack)
    local SkinsPath = ReplicatedStorage.Assets.Skins.Survivors
    local Stun = {
        'LungeStart', 'Axe', 'Punch', 'ParryPunch', 'Slash', 'Stab'
    }
    for _, Name in Stun do
        for _, Folder in SkinsPath[SurvivorName]:GetChildren() do
            if (not Folder:FindFirstChild("Config")) then continue end
            local Asset = FindAnimationAsset(Folder.Config, Name)
            if (Asset) then
                if (table.find(Stun, Name)) then
                    table.insert(Forsaken.SentinelAnimations, Asset)
                end
            end
            InsertAttackAnim(Asset)
        end
        local Asset = FindAnimationAsset(MainSurvivorsPath[SurvivorName].Config, Name)
        if (Asset) then
            if (table.find(Stun, Name)) then
                table.insert(Forsaken.SentinelAnimations, Asset)
            end
        end
        InsertAttackAnim(Asset)
    end
end

-- [merged] SoundSearch (from Script.txt lines 4964-4983)
function SoundSearch(KillerName)
    for _, Name in ({'Swing', 'SlashGround', 'SlashExtended', 'Slash'}) do
        for _, Folder in SkinsPath[KillerName]:GetChildren() do
            if (not Folder:FindFirstChild("Config")) then continue end
            local module = require(Folder.Config)
            if module.Sounds then
                if module.Sounds[Name] then
                    table.insert(Forsaken.AutoBlockSounds, module.Sounds[Name])
                end
            end
        end

        local Config = require(ReplicatedStorage.Assets.Killers[KillerName].Config)
        if Config.Sounds[Name] then
            table.insert(Forsaken.AutoBlockSounds, Config.Sounds[Name])
        else
            warn("sound", Name, "doesnt exist in", KillerName)
        end
    end
end

-- [merged] Search (from Script.txt lines 4998-5068)
function Search(KillerName, Attacks, Path, Path2, Attacks2)
    local M1 = {
        'Slash',
        'SlashAir', 'Stab', 'Bite',
        'Attack'
    }

    if (not Forsaken.BlockMeta[KillerName]) then
        Forsaken.BlockMeta[KillerName] = {}
    end

    -- Normal attacks
    for _, Name in Attacks do
        for _, Folder in (Path or SkinsPath)[KillerName]:GetChildren() do
            if (not Folder:FindFirstChild("Config")) then continue end

            local Asset = FindAnimationAsset(Folder.Config, Name)

            if (Asset) then
                Forsaken.BlockMeta[Asset] = Name

                if (table.find(M1, Name)) then
                    table.insert(Forsaken.M1Animations, Asset)
                end
            end

            InsertAttackAnim(Asset)
        end

        local Asset = FindAnimationAsset(
            (Path2 or MainKillersPath)[KillerName].Config,
            Name
        )

        if (Asset) then
            if (table.find(M1, Name)) then
                table.insert(Forsaken.M1Animations, Asset)
            end

            Forsaken.BlockMeta[Asset] = Name
        end

        InsertAttackAnim(Asset)
    end

    -- Secondary attacks
    for _, Name in Attacks2 or {} do
        for _, Folder in (Path or SkinsPath)[KillerName]:GetChildren() do
            if (not Folder:FindFirstChild("Config")) then continue end

            local Asset = FindAnimationAsset(Folder.Config, Name)

            if (Asset) then
                Forsaken.BlockMeta[Asset] = Name
            end

            InsertAttackAnim(Asset)
        end

        local Asset = FindAnimationAsset(
            (Path2 or MainKillersPath)[KillerName].Config,
            Name
        )

        if (Asset) then
            Forsaken.BlockMeta[Asset] = Name
        end

        InsertAttackAnim(Asset)
    end
end

-- [merged] CreateRangeCircle (from Script.txt lines 5431-5453)
function CreateRangeCircle(Object, RangeX, RangeZ)
    local Circle = Instance.new("Part")
    Circle.Name = "RANGEVIS"
    Circle.Anchored = true
    Circle.CanCollide = false
    Circle.CanQuery = false
    Circle.CanTouch = false
    Circle.Transparency = 0.5
    Circle.Color = Color3.fromRGB(255, 0, 0)
    Circle.Material = Enum.Material.ForceField
    Circle.Shape = Enum.PartType.Cylinder

    Circle.Parent = Object

    table.insert(RangesEsp, {
        Circle = Circle,
        RangeX = RangeX,
        RangeZ = RangeZ,
        Object = Object
    })

    return Circle
end

-- [merged] TableFindThatWorks (from Script.txt lines 9097-9104)
function TableFindThatWorks(Haystack, Needle)
    for i, v in Haystack do
        if v == Needle then
            return v
        end
    end
    return false
end

-- [merged] GetTrackLength (from Script.txt lines 9122-9131)
function GetTrackLength(animator, assetId)
    local animation = Instance.new("Animation")
    animation.AnimationId = assetId
    local track = animator:LoadAnimation(animation)
    wait() 
    local length = track.Length
    track:Destroy()
    animation:Destroy()
    return length
end

-- [merged] Check (from Script.txt lines 9710-9716)
function Check()
    for _, Object in TemporaryUI:GetChildren() do
        if (Object.Name == '1x1x1x1Popup') then
            Object:Destroy()
        end
    end
end

-- [merged] BringItems (from Script.txt lines 10649-10684)
function BringItems()
    if (IsBringing) then return end
    if (Forsaken.GameState ~= 1) then return end
    if (DoingAllGenerators) then return end
    IsBringing = true
    print('BringItems() result:', pcall(function()
        local mypos = LocalPlayer.Character.HumanoidRootPart.CFrame
        local myposv3 = LocalPlayer.Character.HumanoidRootPart.Position
        for i, v in pairs(Forsaken.Items) do
            local s = tick()
            LocalPlayer.Character.HumanoidRootPart.CFrame = v.ItemRoot.CFrame
            while tick() - s <= 1.5 do
                local areallitemsnear = true
                for i, v in pairs(Forsaken.Items) do
                    if (myposv3 - v.ItemRoot.Position).magnitude >= 15 then
                        areallitemsnear = false
                    end
                end
                if areallitemsnear then
                    break
                end
                if isnetworkowner(v.ItemRoot) then
                    warn("teleporting", v)
                    wait(0.3)
                    v.ItemRoot.CFrame = mypos
                    wait(0.3)
                    break
                end
                wait()
            end
            wait()
        end
        LocalPlayer.Character.HumanoidRootPart.CFrame = mypos
    end))
    IsBringing = false
end

-- [merged] DeleteItems (from Script.txt lines 10685-10710)
function DeleteItems()
    if (IsDeleting) then return end
    if (Forsaken.GameState ~= 1) then return end
    if (DoingAllGenerators) then return end
    IsDeleting = true
    print('DeleteItems() result:', pcall(function()
        local mypos = LocalPlayer.Character.HumanoidRootPart.CFrame
        for i, v in pairs(Forsaken.Items) do
            local s = tick()
            LocalPlayer.Character.HumanoidRootPart.CFrame = v.ItemRoot.CFrame
            while tick() - s <= 1.5 do
                if isnetworkowner(v.ItemRoot) then
                    warn("deleting", v)
                    wait(0.3)
                    v.ItemRoot.Velocity = Vector3.new(9999, 9999, 9999)
                    wait(0.3)
                    break
                end
                wait()
            end
            wait()
        end
        LocalPlayer.Character.HumanoidRootPart.CFrame = mypos
    end))
    IsDeleting = false
end

-- [merged] Connectionstuff (from Script.txt lines 11029-11035)
function Connectionstuff(char,added)
    if not char then return end
    if char.Parent == Spectators then return end
    if Skidsaken.Flags.AntiFootsteps.CurrentValue then
        LocalPlayer.Character:SetAttribute('FootstepsMuted', true)
    end
end

-- [merged] clearflags (from Script.txt lines 11052-11067)
function clearflags(v,m)
    if v.Character then
        v.Character:SetAttribute("INVISDETECTED", nil)
        v.Character:SetAttribute('TELEPORTS', 0)
        v.Character:SetAttribute('STAMINA_FLAG_TIME', nil)
        v.Character:SetAttribute('ILLEGAL_ANIMATION_FLAG', nil)
        v.Character:SetAttribute('FAKE_BLOCK_FLAG', nil)
        v.Character:SetAttribute('FOOTSTEP_FLAGS', nil)
        v.Character:SetAttribute('SETTINGS_FLAG', nil)
        v.Character:SetAttribute('INVENTORY_FLAG', nil)
    end
    if not m then
        v:SetAttribute('ILLEGAL_ANIMATION_FLAG', nil)
        v:SetAttribute('FAKE_BLOCK_FLAG', nil)
    end
end

-- [merged] trackeverything (from Script.txt lines 11311-11347)
function trackeverything(v)
    local pd = v:WaitForChild('PlayerData', 15)
    if pd then
        local equipped = pd:WaitForChild('Equipped')
        local settings = pd:WaitForChild('Settings')
        for i, l in pairs(equipped:GetDescendants()) do
            if l:IsA("StringValue") then
                table.insert(settingsdetectorconnections, l:GetPropertyChangedSignal("Value"):Connect(function()
                    print(l, "changed2", v.Character, v.Character.Parent, IsRoundLoaded())
                    if v.Character and (v.Character.Parent == Survivors or v.Character.Parent == Killers) then
                        if Skidsaken.Flags.ANTICHEAT_DETECTSETTINGS.CurrentValue and tick() - Forsaken.RoundStart >= 8 and IsRoundLoaded() then
                            warn("ba")
                            if l.Name == 'Killer' or l.Name == 'Survivor' or l.Parent.Name == 'Skins' then
                                warn("bb")
                                v.Character:SetAttribute('INVENTORY_FLAG', true)
                            end
                        end
                    end
                end))
            end
        end
        for i, l in pairs(settings:GetDescendants()) do
            if l.ClassName:find('Value') then
                table.insert(settingsdetectorconnections, l:GetPropertyChangedSignal("Value"):Connect(function()
                    print(l, "changed")
                    if v.Character and (v.Character.Parent == Survivors or v.Character.Parent == Killers) then
                        if Skidsaken.Flags.ANTICHEAT_DETECTSETTINGS.CurrentValue and tick() - Forsaken.RoundStart >= 8 and IsRoundLoaded() then
                            v.Character:SetAttribute('SETTINGS_FLAG', true)
                        end
                    end
                end))
            end
        end
    else
        warn("[Anticheat] failed to find playerdata folder")
    end
end

-- [merged] seticonsall (from Script.txt lines 11527-11532)
function seticonsall(n,n1,n2,n3)
    if Env.BlockToggle then Env.BlockButton:setImage(n) end
    if Env.InvisToggleButton then Env.InvisToggleButton:setImage(n1 or n) end
    if Env.DesyncToggleButton then Env.DesyncToggleButton:setImage(n2 or n) end
    if Env.MobileToggle then Env.MobileToggle:setImage(n3 or n) end
end

-- [merged] restoreicons (from Script.txt lines 11534-11536)
function restoreicons()
    seticonsall(getcustomasset('Skidsaken/shield.png'), getcustomasset('Skidsaken/ghost.png'), getcustomasset('Skidsaken/' .. (Forsaken:HasDesync('DesyncMain') and 'wifi-off.png' or 'wifi.png')), getcustomasset('Skidsaken/app-window.png'))
end

-- [merged] Track (from Script.txt lines 11668-11689)
function Track(Char)
    local Root = Char and Char:WaitForChild('HumanoidRootPart', 7)
    if (not Root) then return end
    local Hum = Root and Char:WaitForChild("Humanoid", 7)
    if (not Hum) then return end
    local Animator = Hum:WaitForChild('Animator', 5)
    if (not Animator) then return end
    local function MakeConnection()
        return Animator.AnimationPlayed:Connect(function(track)
            if (not TableFindThatWorks(BlockAnims, track.Animation.AnimationId)) then return end
            if (not Skidsaken.Flags.BlockAnimationChanger.CurrentValue) then return end
            track:Stop()
            local NewAnim = Instance.new("Animation")
            NewAnim.AnimationId = TheAnimReal
            local Track = Hum:LoadAnimation(NewAnim)
            TrackingConnection:Disconnect() -- prevents crashing since it would be an infinite loop
            Track:Play()
            TrackingConnection = MakeConnection()
        end)
    end
    TrackingConnection = MakeConnection()
end

pcall(function() UILibrary:FinalizeConfiguration() end)

-- ===== END MERGED section =====

end, function(err)
    pcall(function() warn("[AmberCore] FATAL ERROR: " .. tostring(err)) end)
    pcall(function() warn(debug and debug.traceback and debug.traceback() or "(no traceback)") end)
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", { Title = "AmberCore Error", Text = tostring(err):sub(1, 80), Duration = 20 }) end)
    if getgenv then getgenv().executed = false end
end)
if not __mainOk then
    pcall(function() if getgenv then getgenv().executed = false end end)




-- ==================================================================
-- ADDED FUNCTIONS FROM Script.txt (tabs features not in AmberCore)
-- ==================================================================

-- ==================================================================
-- EDITOR TAB (from Skidsaken) - สำหรับแก้ไขค่าตัวละคร
-- ==================================================================
do
    local function recursiveget(t, path)
        for key in string.gmatch(path, "[^%.]+") do
            t = rawget(t, key)
            if t == nil then
                return nil
            end
        end
        return t
    end

    local function recursivecheck(value, t)
        if value == t then
            return true
        end
        for _, child in pairs(t) do
            if type(child) == "table" then
                if recursivecheck(value, child) then
                    return true
                end
            end
        end
        return false
    end

    local function recursiveset(t, path, value)
        local keys = {}
        for key in string.gmatch(path, "[^%.]+") do
            table.insert(keys, key)
        end
        local current = t
        for i = 1, #keys - 1 do
            local next = rawget(current, keys[i])
            if type(next) ~= "table" then
                next = {}
                rawset(current, keys[i], next)
            end
            current = next
        end
        rawset(current, keys[#keys], value)
    end

    local stats2edit = {
        Sixer = {true, "PursuitMaxSpeed", "PursuitLength", "PursuitBaseSpeed"},
        Nosferatu = {true, "AscentFlight.Duration"},
        Noli = {true, "VoidRushChargeLength", "VoidRushTurnSpeed", "VoidRushInitialTurnMult", "VoidRushChargingSpeed", "VoidRushDashSpeed", "VoidRushInitialTurnDuration"},
        JohnDoe = {true, "Crystal.MaxChargeTime", "Crystal.ChargeSpeedMult", "Crystal.MinChargeTime", "Crystal.MaximumHoldTime", "Axe.DashSpeed"},
        TwoTime = {true, "CrouchRunSpeed", "CrouchSpeed", "DaggerUncrouchedLungeForce", "DaggerLungeForce"},
        Guest1337 = {true, "ChargingSpeed", "ChargingTurnSpeed"},
        Veeronica = {true, "Sk8BumpPower", "Sk8TurnControl", "Sk8TrickStamina", "Sk8TrickCooldown", "Sk8TrickTurnControl", "Sk8TrickPower", "Sk8Speed", "Sk8TrickGravity", "Sk8TrickJump"}
    }

    local editedvals = {}
    local editing = "Sixer"
    local name2edit = {}
    local killernames = {}
    local allnames = {}
    local defaultvalues = getgenv().FORSAKENdefaultvalues or {}
    getgenv().FORSAKENdefaultvalues = defaultvalues

    local savefolder = "SkidsakenEditor"
    if not isfolder(savefolder) then makefolder(savefolder) end
    if not isfolder(savefolder .. "/Configs") then makefolder(savefolder .. "/Configs") end
    savefolder = savefolder .. "/Configs"

    local function getSaveFiles()
        local files = {}
        for _, file in ipairs(listfiles(savefolder)) do
            table.insert(files, file:match("[^/\]+$") or file)
        end
        table.sort(files)
        return files
    end

    local function getSavePath(name)
        return savefolder .. "/" .. name
    end

    local function saveChanges(name)
        if not name or name:gsub("%s", "") == "" then
            return UILibrary:Notify({Title = "Editor", Content = "Enter a save name.", Duration = 5})
        end
        name = name:gsub("[?]", "")
        local success, encoded = pcall(function()
            return HttpService:JSONEncode(editedvals)
        end)
        if not success then
            return UILibrary:Notify({Title = "Editor", Content = "Failed to encode the changes.", Duration = 5})
        end
        local success2, err = pcall(function()
            writefile(getSavePath(name), encoded)
        end)
        if not success2 then
            return UILibrary:Notify({Title = "Editor", Content = "Failed to save: " .. tostring(err), Duration = 5})
        end
        UILibrary:Notify({Title = "Editor", Content = "Saved " .. name .. ".", Duration = 5})
    end

    for data, editables in pairs(stats2edit) do
        local name = data[1]
        if not defaultvalues[name] then defaultvalues[name] = {} end
        name2edit[name] = name
        editables = {select(2, unpack(data))}
        killernames[name] = data[2]
        allnames[name] = true
        local config = require(ReplicatedStorage.Assets[(data[2] and "Killers" or "Survivors")] .. name .. ".Config")
        for _, v in pairs(editables) do
            recursiveset(defaultvalues[name], v, recursiveget(config, v))
        end
    end

    local function updateeditgui()
        if not allnames[editing] then return end
        local valuesstring = "Default " .. editing .. ":\n"
        local config = require(ReplicatedStorage.Assets[(killernames[editing] and "Killers" or "Survivors")] .. editing .. ".Config")
        for _, v in pairs(name2edit[editing]) do
            valuesstring = valuesstring .. v .. ": " .. tostring(recursiveget(config, v)) .. " (D: " .. tostring(recursiveget(defaultvalues[editing], v)) .. ")\n"
        end
        if valuesLabel then
            valuesLabel:Set(valuesstring)
        end
    end

    local editablenames = {}
    for data in pairs(stats2edit) do
        table.insert(editablenames, data[1])
    end

    -- สร้าง Editor Tab
    if EditorTab then
        EditorTab:CreateSection("Editor")
        EditorTab:CreateDropdown({
            Name = "Select character",
            Options = editablenames,
            CurrentOption = "Sixer",
            Flag = "SelectedEditCharacter",
            NoSave = true,
            Callback = function(Options)
                editing = Options[1]
                updateeditgui()
            end
        })

        EditorTab:CreateDropdown({
            Name = "Select key",
            Options = name2edit[editing] or {},
            CurrentOption = "",
            Flag = "SelectedEditKey",
            NoSave = true,
            Callback = function(Options)
                if Options[1] then
                    local value = recursiveget(defaultvalues[editing], Options[1])
                end
            end
        })

        EditorTab:CreateInput({
            Name = "Select value",
            CurrentValue = "",
            PlaceholderText = "Value",
            Flag = "SelectedEditValue",
            Callback = function(Text)
            end
        })

        EditorTab:CreateButton({
            Name = "Update key to value",
            Callback = function()
            end
        })

        EditorTab:CreateButton({
            Name = "Reset all values",
            Callback = function()
                editedvals = {}
                updateeditgui()
            end
        })

        EditorTab:CreateSection("Saves")
        EditorTab:CreateButton({
            Name = "Save",
            Callback = function()
                saveChanges("MySave")
            end
        })

        EditorTab:CreateLabel({
            Name = "Values",
            Text = ""
        })
        local valuesLabel = _G.editorValuesLabel
        updateeditgui()
    end
end

-- Auto Disarm Minigame (Azure)
if AzureConstructQTE and AzureConstructQTE.new then
    local OldAzureQTE = AzureConstructQTE.new
    AzureConstructQTE.new = newcclosure(function(self, vine)
        local QTE = OldAzureQTE(self, vine)
        task.spawn(function()
            if Window.Flags.InfiniteDisarmAttempts and Window.Flags.InfiniteDisarmAttempts.CurrentValue then
                QTE.FailedAttempts = -math.huge
            end
            if Window.Flags.AutoDisarmMinigame and Window.Flags.AutoDisarmMinigame.CurrentValue then
                task.wait(1.5)
                QTE.Progress = 100
                QTE:Destroy()
                UILibrary:Notify({Title = "Auto Disarm", Content = "The disarm minigame was skipped successfully.", Duration = 7})
            end
        end)
        return QTE
    end)
end

-- Auto Coin Flip
task.spawn(function()
    local LastFlip = 0
    while task.wait() and Window.Flags.AutoCoinFlip and Window.Flags.AutoCoinFlip.CurrentValue do
        local charges = 9e9
        pcall(function()
            if HasAbility("Reroll") and PlayerGui.MainUI.AbilityContainer.Reroll then
                charges = tonumber(PlayerGui.MainUI.AbilityContainer.Reroll.Charges.Text) or 9e9
            end
        end)
        if charges <= (Window.Flags.MaxCharges and Window.Flags.MaxCharges.CurrentValue or 1) 
            and HasAbilityReady("CoinFlip") 
            and tick() - LastFlip > 2.5 then
            Network:FireServer("UseActorAbility", "REMOTEEVENT", "CoinFlip")
            LastFlip = tick()
        end
    end
end)

-- Auto Chicken (Fried Chicken)
task.spawn(function()
    while task.wait() and Window.Flags.AutoChicken and Window.Flags.AutoChicken.CurrentValue do
        if HasAbilityReady("FriedChicken") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local health = LocalPlayer.Character.Humanoid.Health
            local healthLimit = Window.Flags.AutoChickenHealth and Window.Flags.AutoChickenHealth.CurrentValue or 40
            if health < healthLimit then
                local ClosestKiller = GetClosestKiller(5000)
                local onlyFar = Window.Flags.AutoChickenFar and Window.Flags.AutoChickenFar.CurrentValue
                if ClosestKiller and (not onlyFar or (LocalPlayer.Character.HumanoidRootPart.Position - ClosestKiller.HumanoidRootPart.Position).magnitude > 100) then
                    Network:FireServer("UseActorAbility", "REMOTEEVENT", "FriedChicken")
                end
            end
        end
    end
end)

-- Walk Over Digital Footprint, Trails, Puddles
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if Window.Flags.WalkOverDF and Window.Flags.WalkOverDF.CurrentValue then
                for _, v in pairs(Forsaken.DoeDebris or {}) do
                    if v:FindFirstChild("TouchInterest") then
                        v.TouchInterest:Destroy()
                    end
                end
            end
        end)
        pcall(function()
            if Window.Flags.WalkOverTrail and Window.Flags.WalkOverTrail.CurrentValue then
                for _, v in pairs(Forsaken.DoeTrailDebris or {}) do
                    if v:FindFirstChild("TouchInterest") then
                        v.TouchInterest:Destroy()
                    end
                end
            end
        end)
        pcall(function()
            if Window.Flags.WalkOverPuddles and Window.Flags.WalkOverPuddles.CurrentValue then
                for _, v in pairs(Forsaken.NosDebris or {}) do
                    if v:FindFirstChild("TouchInterest") then
                        v.TouchInterest:Destroy()
                    end
                end
            end
        end)
    end
end)

-- Spike Noclip (Map Tab)
task.spawn(function()
    while task.wait() and Window.Flags.SpikeNoclip and Window.Flags.SpikeNoclip.CurrentValue do
        for i, Spike in ipairs(Forsaken.Spikes or {}) do
            if Spike and Spike.Parent then
                Spike:Destroy()
            end
        end
    end
end)

-- ==================================================================

end
-- ===== END AmberCore v9 (patched) =====