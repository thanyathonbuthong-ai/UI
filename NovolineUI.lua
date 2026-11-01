--[[ Novoline UI Library -- standalone Roblox UI lib
     Extracted from BasedHub (53_novoline.lua look + foundation).
     Usage: local Library = loadstring (game:HttpGet(url))()
     Toggle key: RightControl (configurable via Library:SetToggleKey("Key")).
     Cards/dock are draggable; tabs render as Novoline decks. ]]
local B = (function()
-- ============================================================================
-- BasedHub foundation.lua — self-contained Lua chunk.
-- Assembler: local B = (loadfile "foundation.lua")()
-- Copies real implementations from m00..m07 (exact logic/timings/colors/
-- signatures); hub/game-specific branches (game-specific) replaced
-- with sensible no-op/default. Stubs exist so indexing never errors.
-- ============================================================================
local B = {}

-- ---------------------------------------------------------------- kernel (m00)
B.genv = getfenv and getfenv() or _ENV
B.alive = true
B.bootClock = os.clock()
B.cloneref = (typeof and typeof(cloneref) == "function") and cloneref or function(x) return x end

-- S: lazy service table with cloneref
B.S = setmetatable({}, {
  __index = function(self, name)
    local ok, svc = pcall(function() return game:GetService(name) end)
    local value = ok and B.cloneref(svc) or svc
    self[name] = value
    return value
  end,
})
local S = B.S

B.LP = S.Players.LocalPlayer

-- Signal class (real)
local Signal = {}
Signal.__index = Signal
function Signal.new()
  return setmetatable({ connections = {}, _list = {} }, Signal)
end
function Signal:connect(fn)
  local conn = { fn = fn, connected = true, signal = self }
  function conn:disconnect()
    if not self.connected then return end
    self.connected = false
    for i, c in ipairs(self.signal._list) do if c == self then table.remove(self.signal._list, i); break end end
  end
  conn.Disconnect = conn.disconnect
  self._list[#self._list + 1] = conn
  return conn
end
Signal.Connect = Signal.connect
function Signal:fire(...)
  for _, conn in ipairs(table.clone(self._list)) do
    if conn.connected then B.try("signal", conn.fn, ...) end
  end
end
Signal.Fire = Signal.fire
B.Signal = Signal

-- fault / try / safe / connect (real)
B.faults = {}
B.onFault = Signal.new()
local lastFault = {}
function B.fault(scope, err)
  local now = os.clock()
  if lastFault[scope] and now - lastFault[scope] < 1 then return end
  lastFault[scope] = now
  local entry = { scope = scope, err = tostring(err), at = now, trace = debug and debug.traceback() or "" }
  table.insert(B.faults, entry)
  if #B.faults > 60 then table.remove(B.faults, 1) end
  B.onFault:fire(entry)
end
function B.try(scope, fn, ...)
  local args = { ... }
  local ok, err = xpcall(function() return fn(table.unpack(args)) end, function(e) return e end)
  if not ok then B.fault(scope, err); return nil end
  return err
end
function B.safe(scope, fn)
  return function(...) return B.try(scope, fn, ...) end
end
B.identity = function() if setthreadidentity then pcall(setthreadidentity, 8) end end

-- own / unload (real, simplified ownership)
B._owned = {}
function B.own(thing) table.insert(B._owned, thing); return thing end
function B.unload()
  B.alive = false
  B.onUnload:fire()
  for _, thing in ipairs(B._owned) do
    pcall(function()
      if typeof(thing) == "RBXScriptConnection" then thing:Disconnect()
      elseif thing.Destroy then thing:Destroy()
      elseif thing.Disconnect then thing:Disconnect() end
    end)
  end
  table.clear(B._owned)
end
function B.connect(signal, fn, scope)
  local conn = signal:Connect(B.safe(scope or "connect", fn))
  B.own(conn)
  return conn
end

-- fs: stubbed (no file persistence) but API exists
B.fs = {
  ok = false, root = "BasedHub",
  path = function(_, rel) return rel end,
  exists = function() return false end, isdir = function() return false end,
  mkdir = function() end, read = function() return nil end, write = function() end,
  remove = function() end, list = function() return {} end,
  readJson = function() return nil end, writeJson = function() end,
}

-- util (real, copied verbatim signatures/logic)
local util = {}
B.util = util
function util.clamp01(x) return math.clamp(x, 0, 1) end
function util.lerp(a, b, t) return a + (b - a) * t end
function util.map(v, a, b, c, d) return c + (v - a) / (b - a) * (d - c) end
function util.round(x, step) step = step or 1; return math.floor(x / step + 0.5) * step end
function util.hex(str)
  str = string.gsub(str or "", "[^%x]", "")
  if #str < 6 then return Color3.new(1, 1, 1) end
  local r = tonumber(string.sub(str, 1, 2), 16) / 255
  local g = tonumber(string.sub(str, 3, 4), 16) / 255
  local b = tonumber(string.sub(str, 5, 6), 16) / 255
  return Color3.new(r, g, b)
end
function util.toHex(c)
  return string.format("%02X%02X%02X", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end
function util.luma(c) return 0.2126 * c.R + 0.7152 * c.G + 0.0722 * c.B end
function util.mix(a, b, t) return Color3.new(util.lerp(a.R, b.R, t), util.lerp(a.G, b.G, t), util.lerp(a.B, b.B, t)) end
function util.format(value, decimals)
  if type(value) ~= "number" then return tostring(value) end
  if decimals then return string.format("%." .. decimals .. "f", value) end
  return tostring(value)
end
function util.comma(n)
  local s = tostring(math.floor(tonumber(n) or 0))
  return string.reverse(string.gsub(string.reverse(s), "(%d%d%d)", "%1,")):gsub("^,", "")
end
function util.copy(t)
  if type(t) ~= "table" then return t end
  local out = {}
  for k, v in pairs(t) do out[k] = util.copy(v) end
  return out
end
function util.keys(t)
  local out = {}
  for k in pairs(t) do out[#out + 1] = k end
  return out
end
function util.fuzzy(query, text)
  if not query or query == "" then return 0 end
  if not text then return nil end
  local ql, tl = string.lower(query), string.lower(text)
  local qi, ti, score = 1, 1, 0
  while qi <= #ql and ti <= #tl do
    if string.sub(ql, qi, qi) == string.sub(tl, ti, ti) then
      score = score + (ti == 1 and 2 or 1)
      qi = qi + 1
    else
      score = score - 0.1
    end
    ti = ti + 1
  end
  if qi <= #ql then return nil end
  return score - #tl * 0.01
end
function util.debounce(seconds, fn)
  local pending, last = false, 0
  return function(...)
    local args = { ... }
    last = os.clock()
    if pending then return end
    pending = true
    task.delay(seconds, function()
      pending = false
      if os.clock() - last >= seconds - 0.001 then fn(table.unpack(args)) end
    end)
  end
end
function util.ray(origin, dir, dist, ignore)
  local params = RaycastParams.new()
  params.FilterType = Enum.RaycastFilterType.Exclude
  params.FilterDescendantsInstances = ignore or {}
  return workspace:Raycast(origin, dir * (dist or 1000), params)
end
function util.studs(v) return v end
function util.randomName()
  local chars = "abcdefghijklmnopqrstuvwxyz0123456789"
  local out = ""
  for _ = 1, 8 do out = out .. string.sub(chars, math.random(1, #chars), math.random(1, #chars)) end
  return out
end

-- camera / viewport / character helpers (real)
function B.camera() return workspace.CurrentCamera end
function B.viewport()
  local cam = B.camera()
  return cam and cam.ViewportSize or Vector2.new(1920, 1080)
end
function B.character() return B.LP and B.LP.Character end
function B.humanoid()
  local c = B.character()
  return c and c:FindFirstChildOfClass("Humanoid")
end
function B.root()
  local c = B.character()
  return c and c:FindFirstChild("HumanoidRootPart")
end

-- clipboard (real, guarded)
function B.clipboard(text)
  if setclipboard then pcall(setclipboard, text)
  elseif toclipboard then pcall(toclipboard, text) end
end

B.executor = identifyexecutor and (identifyexecutor() or "unknown") or "unknown"
B.touch = false

-- host / screens (real, guarded)
function B.host()
  if gethui then local ok, h = pcall(gethui); if ok and h then return h end end
  return S.CoreGui or (B.LP and B.LP:FindFirstChildOfClass("PlayerGui"))
end
B.screens = {}
function B.screen(order, name)
  local gui = Instance.new("ScreenGui")
  gui.Name = name or ("Screen_" .. tostring(order))
  gui.ResetOnSpawn = false
  gui.IgnoreGuiInset = true
  gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
  gui.DisplayOrder = order or 0
  gui.Parent = B.host()
  B.own(gui)
  table.insert(B.screens, gui)
  return gui
end

B.onUnload = Signal.new()

-- fonts: B.F / B.F0 tables (must exist; Novoline has its own pickFont)
B.F = {}
B.F0 = {}
do
  local function fb(weight, style)
    local ok, f = pcall(function() return Font.fromEnum(Enum.Font.Gotham) end)
    return ok and f or Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight[weight] or Enum.FontWeight.Regular, Enum.FontStyle[style] or Enum.FontStyle.Normal)
  end
  for _, key in ipairs({ "text400", "text500", "text600", "text700", "mono400", "mono500", "serif", "serifItalic", "wideBold", "wideBlack", "craft", "proggy", "proggyTiny" }) do
    B.F[key] = fb("Regular")
  end
  B.F0 = table.clone(B.F)
end

-- ---------------------------------------------------------------- Motion (m01) — real
local Motion = { speed = 1, reduced = false, frame = 0, dt = 1 / 60, smoothDt = 1 / 60, now = os.clock() }
B.Motion = Motion
Motion.presets = {
  quick = { 0.16, 0 }, snappy = { 0.24, 0.10 }, smooth = { 0.34, 0 }, gentle = { 0.52, 0 },
  bouncy = { 0.40, 0.24 }, liquid = { 0.46, 0.30 }, lazy = { 0.90, 0 },
}
local Spring = {}
Spring.__index = Spring
local function tune(spring, preset)
  local p = Motion.presets[preset] or Motion.presets.smooth
  local duration, bounce = p[1], p[2]
  if Motion.reduced then duration = duration * 0.55; bounce = 0 end
  spring.w0 = 2 * math.pi / duration
  spring.zeta = math.clamp(1 - bounce, 0.08, 1)
end
function Motion.spring(n, preset, onStep, eps)
  local self = setmetatable({ n = n, x = {}, g = {}, v = {}, onStep = onStep, eps = eps or 0.001, _dead = false }, Spring)
  for i = 1, n do self.x[i] = 0; self.g[i] = 0; self.v[i] = 0 end
  tune(self, preset)
  self.preset = preset
  table.insert(Motion._springs, self)
  return self
end
function Spring:snap(values)
  for i = 1, self.n do self.x[i] = values[i]; self.g[i] = values[i]; self.v[i] = 0 end
  if self.onStep then self.onStep(self.x) end
end
function Spring:to(values, preset)
  if preset then tune(self, preset) end
  for i = 1, self.n do self.g[i] = values[i] end
  self._dead = false
end
function Spring:impulse(vel) for i = 1, self.n do self.v[i] = (self.v[i] or 0) + (vel[i] or 0) end end
function Spring:moving()
  for i = 1, self.n do
    if math.abs(self.g[i] - self.x[i]) > self.eps or math.abs(self.v[i]) > self.eps then return true end
  end
  return false
end
function Spring:stop() self._dead = true end
Motion._springs = {}
Motion._tweens = {}
Motion._jobs = {}

local function stepSpring(self, dt)
  if self._dead then return false end
  local w0, z = self.w0, self.zeta
  local moving = false
  for i = 1, self.n do
    local x, v, g = self.x[i], self.v[i], self.g[i]
    local a = -2 * z * w0 * v - w0 * w0 * (x - g)
    v = v + a * dt
    x = x + v * dt
    self.x[i], self.v[i] = x, v
    if math.abs(g - x) > self.eps or math.abs(v) > self.eps then moving = true end
  end
  if self.onStep then self.onStep(self.x) end
  if not moving then self._dead = true end
  return moving
end

-- packers for Motion.to
local PX, UNIT = 0.08, 0.0008
local unitProps = { BackgroundTransparency = true, TextTransparency = true, ImageTransparency = true, GroupTransparency = true, ScrollBarImageTransparency = true, PlaceholderColor3 = false }
local function pack(prop, value)
  if type(value) == "number" then return { value } end
  if typeof(value) == "UDim2" then return { value.X.Scale * UNIT, value.X.Offset * PX, value.Y.Scale * UNIT, value.Y.Offset * PX } end
  if typeof(value) == "UDim" then return { value.Scale * UNIT, value.Offset * PX } end
  if typeof(value) == "Vector2" then return { value.X * PX, value.Y * PX } end
  if typeof(value) == "Vector3" then return { value.X * PX, value.Y * PX, value.Z * PX } end
  if typeof(value) == "Color3" then return { value.R, value.G, value.B } end
  return { value }
end
local function unpack(prop, vals)
  if #vals == 1 then
    if unitProps[prop] then return util.clamp01(vals[1]) end
    return vals[1]
  end
  if #vals == 2 then return UDim.new(vals[1] / UNIT, vals[2] / PX) end
  if #vals == 3 then
    if prop == "Position" or prop == "Size" then return Vector2.new(vals[1] / PX, vals[2] / PX) end
    return Color3.new(util.clamp01(vals[1]), util.clamp01(vals[2]), util.clamp01(vals[3]))
  end
  if #vals == 4 then return UDim2.new(UDim.new(vals[1] / UNIT, vals[2] / PX), UDim.new(vals[3] / UNIT, vals[4] / PX)) end
  return vals[1]
end

local propSprings = setmetatable({}, { __mode = "k" })
function Motion.to(instance, property, target, preset, done)
  local key = tostring(instance) .. "|" .. property
  local cur = instance[property]
  local spring = propSprings[key]
  if not spring then
    spring = Motion.spring(#pack(property, cur), preset or "smooth", function(vals)
      instance[property] = unpack(property, vals)
    end)
    spring:snap(pack(property, cur))
    propSprings[key] = spring
  end
  spring._done = done
  spring:to(pack(property, target), preset)
  return spring
end
function Motion.snap(instance, property, target)
  instance[property] = target
  local key = tostring(instance) .. "|" .. property
  if propSprings[key] then propSprings[key]:snap(pack(property, target)) end
end
function Motion.kick(instance, property, vel)
  local key = tostring(instance) .. "|" .. property
  if propSprings[key] then propSprings[key]:impulse(pack(property, vel)) end
end
function Motion.target(instance, property)
  local key = tostring(instance) .. "|" .. property
  local s = propSprings[key]
  if not s then return instance[property] end
  return unpack(property, s.g)
end

-- ease functions (real)
local ease = {}
Motion.ease = ease
function ease.linear(t) return t end
function ease.outCubic(t) return 1 - (1 - t) ^ 3 end
function ease.inCubic(t) return t ^ 3 end
function ease.inOutCubic(t) return t < 0.5 and 4 * t ^ 3 or 1 - (-2 * t + 2) ^ 3 / 2 end
function ease.outQuint(t) return 1 - (1 - t) ^ 5 end
function ease.inOutQuint(t) return t < 0.5 and 16 * t ^ 5 or 1 - (-2 * t + 2) ^ 5 / 2 end
function ease.outExpo(t) return t >= 1 and 1 or 1 - 2 ^ (-10 * t) end
function ease.inExpo(t) return t <= 0 and 0 or 2 ^ (10 * t - 10) end
function ease.outBack(t, c) c = c or 1.70158; return 1 + (c + 1) * (t - 1) ^ 3 + c * (t - 1) ^ 2 end
function ease.outSine(t) return math.sin(t * math.pi / 2) end
function Motion.window(t, from, length, curve)
  local x = util.clamp01((t - from) / (length or 1))
  return (curve or ease.outCubic)(x)
end
function Motion.tween(duration, curve, step, done)
  if Motion.reduced then duration = duration * 0.5 end
  local t = { t = 0, duration = duration, curve = curve or ease.outCubic, step = step, done = done, dead = false }
  table.insert(Motion._tweens, t)
  return t
end
function Motion.every(fn, hz, scope)
  local job = { fn = fn, acc = 0, interval = 1 / (hz or 60), scope = scope or "every", dead = false }
  function job.cancel() job.dead = true end
  table.insert(Motion._jobs, job)
  return job
end
function Motion.after(seconds, fn, scope)
  return Motion.tween(seconds, ease.linear, nil, function() B.try(scope or "after", fn) end)
end

-- main loop (real, connected to RenderStepped)
B.connect(S.RunService.RenderStepped, function(dt)
  Motion.frame = Motion.frame + 1
  dt = math.min(dt, 0.1)
  Motion.dt = dt
  Motion.smoothDt = Motion.smoothDt * 0.9 + dt * 0.1
  Motion.now = os.clock()
  for i = #Motion._springs, 1, -1 do
    if not stepSpring(Motion._springs[i], dt) then
      if Motion._springs[i]._done then B.try("spring.done", Motion._springs[i]._done) end
      table.remove(Motion._springs, i)
    end
  end
  for i = #Motion._tweens, 1, -1 do
    local tw = Motion._tweens[i]
    tw.t = tw.t + dt
    local p = util.clamp01(tw.t / tw.duration)
    if tw.step then B.try("tween", tw.step, tw.curve(p)) end
    if p >= 1 then
      if tw.done then B.try("tween.done", tw.done) end
      table.remove(Motion._tweens, i)
    end
  end
  for i = #Motion._jobs, 1, -1 do
    local job = Motion._jobs[i]
    if job.dead then table.remove(Motion._jobs, i)
    else
      job.acc = job.acc + dt
      while job.acc >= job.interval do
        job.acc = job.acc - job.interval
        B.try(job.scope, job.fn)
      end
    end
  end
end, "motion.loop")
Motion.stats = function() return { springs = #Motion._springs, tweens = #Motion._tweens, jobs = #Motion._jobs } end

-- ---------------------------------------------------------------- Theme (m02) — real, minimal
local Theme = { changed = Signal.new() }
B.Theme = Theme
B.T = {}
local T = B.T
Theme.schemes = {
  dark = { base = Color3.fromRGB(16, 16, 20), ink = Color3.fromRGB(240, 240, 245), sub = Color3.fromRGB(160, 160, 170), faint = Color3.fromRGB(110, 110, 120), shadow = Color3.new(0, 0, 0), fill = { Color3.fromRGB(40, 40, 48), Color3.fromRGB(55, 55, 65), Color3.fromRGB(70, 70, 80) }, stroke = { Color3.fromRGB(80, 80, 90), Color3.fromRGB(60, 60, 70) }, dark = Color3.new(0, 0, 0) },
  midnight = { base = Color3.fromRGB(10, 10, 14), ink = Color3.fromRGB(235, 235, 245), sub = Color3.fromRGB(150, 150, 165), faint = Color3.fromRGB(100, 100, 115), shadow = Color3.new(0, 0, 0), fill = { Color3.fromRGB(30, 30, 40), Color3.fromRGB(45, 45, 58), Color3.fromRGB(60, 60, 75) }, stroke = { Color3.fromRGB(70, 70, 85), Color3.fromRGB(50, 50, 62) }, dark = Color3.new(0, 0, 0) },
  light = { base = Color3.fromRGB(245, 245, 248), ink = Color3.fromRGB(20, 20, 25), sub = Color3.fromRGB(90, 90, 100), faint = Color3.fromRGB(140, 140, 150), shadow = Color3.fromRGB(0, 0, 0), fill = { Color3.fromRGB(225, 225, 232), Color3.fromRGB(210, 210, 220), Color3.fromRGB(195, 195, 205) }, stroke = { Color3.fromRGB(180, 180, 190), Color3.fromRGB(200, 200, 210) }, dark = Color3.new(1, 1, 1) },
}
Theme.schemeOrder = { "dark", "midnight", "light" }
Theme.accents = {
  { id = "ultraviolet", color = util.hex("8E7DFF") }, { id = "azure", color = util.hex("4DA3FF") },
  { id = "mint", color = util.hex("45DDA8") }, { id = "ember", color = util.hex("FF7A45") },
  { id = "rose", color = util.hex("FF5C93") }, { id = "gold", color = util.hex("F2C14E") },
  { id = "blood", color = util.hex("FF4B4B") }, { id = "bone", color = util.hex("EDEBE4") },
}
Theme.state = { scheme = "dark", accent = util.hex("8E7DFF"), glass = 0.6, radius = 1, blur = false }
Theme.type = {
  display = { "serifItalic", 34 }, title = { "serif", 25 }, heading = { "text600", 15 }, label = { "text500", 14 },
  body = { "text400", 13 }, caption = { "text400", 12 }, eyebrow = { "wideBold", 10 }, mono = { "mono400", 12 },
  monoBold = { "mono500", 12 }, button = { "text600", 13 }, brand = { "wideBlack", 18 },
}
local bindings = setmetatable({}, { __mode = "k" })
local function resolve()
  local s = Theme.schemes[Theme.state.scheme] or Theme.schemes.dark
  local a = Theme.state.accent
  T.base, T.ink, T.sub, T.faint = s.base, s.ink, s.sub, s.faint
  T.baseA, T.panelA = 0.04, 0.55
  T.fill1A, T.fill2A, T.fill3A = 0.92, 0.86, 0.78
  T.strokeA, T.stroke2A = 0.88, 0.94
  T.shadowA = 0.55
  T.accent = a
  T.accentInk = util.luma(a) > 0.5 and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
  T.accentSoftA, T.accentDim = 0.85, util.mix(a, s.base, 0.5)
  T.ok, T.warn, T.bad = util.hex("45DDA8"), util.hex("F2C14E"), util.hex("FF4B4B")
  T.white, T.black = Color3.new(1, 1, 1), Color3.new(0, 0, 0)
  T.rim, T.rimA = Color3.new(1, 1, 1), 0.88
  T.popover = s.base
  local r = Theme.state.radius
  T.rWindow, T.rPanel, T.rCard, T.rControl, T.rSmall = 18 * r, 14 * r, 12 * r, 10 * r, 7 * r
end
function Theme.bind(instance, property, key, map)
  bindings[instance] = bindings[instance] or {}
  bindings[instance][property] = { key = key, map = map }
  local v = T[key]
  if map then v = map(v) end
  instance[property] = v
end
function Theme.unbind(instance, property)
  if bindings[instance] then bindings[instance][property] = nil end
end
function Theme.sweep()
  for inst, props in pairs(bindings) do
    if not inst.Parent then bindings[inst] = nil
    else
      for prop, spec in pairs(props) do
        local v = T[spec.key]
        if spec.map then v = spec.map(v) end
        pcall(function() inst[prop] = v end)
      end
    end
  end
end
function Theme.apply()
  resolve()
  Theme.sweep()
  Theme.changed:fire()
end
function Theme.set(changes)
  for k, v in pairs(changes) do Theme.state[k] = v end
  Theme.apply()
end
function Theme.corner(key) return T[key] or 10 end
resolve()

-- ---------------------------------------------------------------- Assets (m03) — stubbed, sound via UI.sfxId
B.Assets = { ready = false, lite = true, calls = 0 }
function B.Assets.id() return nil end
function B.Assets.frame() return nil end
function B.Assets.has() return false end
function B.Assets.icon() return nil end
function B.Assets.image() return nil end
function B.Assets.sound() return nil end
function B.Assets.preload() end
function B.Assets.init() end

-- ---------------------------------------------------------------- UI (m04) — real primitives
local UI = { fx = { canvas = true, shadow = false, innerStroke = false }, sfxVolume = 0.5, sfxOn = true, scrollbar = "always", fontKey = {} }
B.UI = UI
UI.soundHost = nil

local function applyTheme(instance, map)
  for prop, key in pairs(map) do
    if type(key) == "string" and T[key] ~= nil then
      Theme.bind(instance, prop, key)
    else
      instance[prop] = key
    end
  end
end

function UI.new(class, props, children)
  local inst = Instance.new(class)
  if props then
    for k, v in pairs(props) do
      if k == "Parent" then inst.Parent = v
      elseif k == "Theme" then applyTheme(inst, v)
      else inst[k] = v end
    end
  end
  if children then for _, c in ipairs(children) do c.Parent = inst end end
  return inst
end
function UI.frame(parent, props)
  local f = UI.new("Frame", props)
  f.BorderSizePixel = 0
  if parent then f.Parent = parent end
  return f
end
function UI.corner(instance, radius)
  local c = Instance.new("UICorner")
  if radius == true then c.CornerRadius = UDim.new(1, 0)
  elseif type(radius) == "string" then c.CornerRadius = UDim.new(0, T[radius] or 10)
  elseif type(radius) == "number" then c.CornerRadius = UDim.new(0, radius)
  else c.CornerRadius = UDim.new(0, 8) end
  c.Parent = instance
  return c
end
function UI.stroke(instance, token, alphaToken, thickness)
  local s = Instance.new("UIStroke")
  s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
  s.Thickness = thickness or 1
  if token then Theme.bind(s, "Color", token) end
  if alphaToken then
    if type(alphaToken) == "string" then Theme.bind(s, "Transparency", alphaToken) else s.Transparency = alphaToken end
  end
  s.Parent = instance
  return s
end
function UI.pad(instance, top, right, bottom, left)
  local p = Instance.new("UIPadding")
  p.PaddingTop = UDim.new(0, top or 0)
  p.PaddingRight = UDim.new(0, right or top or 0)
  p.PaddingBottom = UDim.new(0, bottom or top or 0)
  p.PaddingLeft = UDim.new(0, left or right or top or 0)
  p.Parent = instance
  return p
end
function UI.list(parent, direction, gap, align)
  local l = Instance.new("UIListLayout")
  l.FillDirection = (direction == "x" or direction == "X") and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
  l.Padding = UDim.new(0, gap or 0)
  l.SortOrder = Enum.SortOrder.LayoutOrder
  if align then l.HorizontalAlignment = align end
  l.Parent = parent
  return l
end
function UI.scaleOf(instance)
  local s = Instance.new("UIScale")
  s.Parent = instance
  return s
end
function UI.gradient(instance, props)
  local g = Instance.new("UIGradient")
  if props then for k, v in pairs(props) do g[k] = v end end
  g.Parent = instance
  return g
end
function UI.alphaSeq(...)
  local stops = { ... }
  local keypoints = {}
  for i = 1, #stops, 2 do keypoints[#keypoints + 1] = NumberSequenceKeypoint.new(stops[i], stops[i + 1]) end
  return NumberSequence.new(keypoints)
end
function UI.text(parent, text, style, color, props)
  local spec = Theme.type[style] or Theme.type.label
  local label = UI.new("TextLabel", {
    BackgroundTransparency = 1, BorderSizePixel = 0,
    FontFace = B.F[spec[1]] or B.F.text400, TextSize = spec[2],
    Text = text or "", TextXAlignment = Enum.TextXAlignment.Left,
    AutomaticSize = Enum.AutomaticSize.XY,
  })
  if color then Theme.bind(label, "TextColor3", color) end
  if props then for k, v in pairs(props) do label[k] = v end end
  if UI.fontKey then UI.fontKey[label] = spec[1] end
  if parent then label.Parent = parent end
  return label
end
function UI.icon(parent, name, size, color, props)
  local img = UI.new("ImageLabel", {
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.fromOffset(size or 16, size or 16),
    Image = "", ScaleType = Enum.ScaleType.Fit,
  })
  if color then Theme.bind(img, "ImageColor3", color) end
  if props then for k, v in pairs(props) do img[k] = v end end
  if parent then img.Parent = parent end
  return img
end
function UI.setIcon(image, name) if image then image.Image = name or "" end end
function UI.image(parent, name, props)
  local img = UI.new("ImageLabel", { BackgroundTransparency = 1, BorderSizePixel = 0, Image = name or "" })
  if props then for k, v in pairs(props) do img[k] = v end end
  if parent then img.Parent = parent end
  return img
end
function UI.glass(parent, opts)
  opts = opts or {}
  local frame = UI.frame(parent, opts.props)
  frame.BackgroundTransparency = opts.level == "window" and 0.3 or 0.5
  Theme.bind(frame, "BackgroundColor3", "base")
  UI.corner(frame, opts.radius or "rPanel")
  local rim = UI.stroke(frame, "white", "rimA", 1)
  local rimGrad = UI.gradient(rim, { Rotation = 90, Transparency = NumberSequence.new(0.5) })
  return frame, rimGrad
end
function UI.surface(parent, props, radius, fill)
  local f = UI.frame(parent, props)
  UI.corner(f, radius or "rCard")
  if fill ~= false then Theme.bind(f, "BackgroundColor3", "ink"); Theme.bind(f, "BackgroundTransparency", "fill1A") end
  return f
end
function UI.group(parent, props)
  local g = UI.new("CanvasGroup", props)
  g.BorderSizePixel = 0
  if parent then g.Parent = parent end
  return g
end
function UI.setFade(group, alpha)
  if group:IsA("CanvasGroup") then group.GroupTransparency = 1 - alpha else group.BackgroundTransparency = 1 - alpha end
end
function UI.fade(group, alpha, preset, done)
  if group:IsA("CanvasGroup") then Motion.to(group, "GroupTransparency", 1 - alpha, preset, done)
  else Motion.to(group, "BackgroundTransparency", 1 - alpha, preset, done) end
end

-- sounds (real)
local sounds = setmetatable({}, { __mode = "v" })
local lastSfx = {}
function UI.sfx(name, volume)
  if not UI.sfxOn then return end
  local id = B.Assets.sound(name)
  if not id then return end
  local now = os.clock()
  if lastSfx[name] and now - lastSfx[name] < 0.04 then return end
  lastSfx[name] = now
  local snd = sounds[name]
  if not snd or not snd.Parent then
    snd = Instance.new("Sound")
    snd.SoundId = id
    snd.Parent = UI.soundHost or B.host()
    sounds[name] = snd
  end
  snd.Volume = (volume or 1) * UI.sfxVolume * 0.5
  snd.PlaybackSpeed = 0.97 + math.random() * 0.06
  snd.TimePosition = 0
  snd:Play()
end
function UI.sfxId(id, volume, speed)
  if not UI.sfxOn or not id then return end
  local key = id .. "@" .. tostring(speed)
  local now = os.clock()
  if lastSfx[key] and now - lastSfx[key] < 0.04 then return end
  lastSfx[key] = now
  local snd = sounds[key]
  if not snd or not snd.Parent then
    snd = Instance.new("Sound")
    snd.SoundId = id
    snd.Parent = UI.soundHost or B.host()
    sounds[key] = snd
  end
  snd.Volume = math.clamp((volume or 1) * UI.sfxVolume / 0.45, 0, 2)
  snd.PlaybackSpeed = speed or 1
  snd.TimePosition = 0
  snd:Play()
end

local function isPress(input) return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch end
UI.isPress = isPress
function UI.inset() return S.GuiService:GetGuiInset() end
function UI.mouse() return S.UserInputService:GetMouseLocation() - UI.inset() end
function UI.point(input) return Vector2.new(input.Position.X, input.Position.Y) end
function UI.unit() return 1 end
function UI.inside(gui, point)
  local p, s = gui.AbsolutePosition, gui.AbsoluteSize
  return point.X >= p.X and point.X <= p.X + s.X and point.Y >= p.Y and point.Y <= p.Y + s.Y
end
function UI.wire(button, handlers)
  local pressing = false
  button.InputBegan:Connect(function(input)
    if isPress(input) then
      pressing = true
      if handlers.press then handlers.press(true) end
    end
    if input.UserInputType == Enum.UserInputType.MouseButton2 and handlers.alt then handlers.alt() end
  end)
  button.InputEnded:Connect(function(input)
    if isPress(input) then
      if pressing and handlers.click then handlers.click() end
      pressing = false
      if handlers.press then handlers.press(false) end
    end
  end)
  button.MouseEnter:Connect(function() if handlers.hover then handlers.hover(true) end end)
  button.MouseLeave:Connect(function()
    if handlers.hover then handlers.hover(false) end
    if pressing and handlers.press then handlers.press(false); pressing = false end
  end)
end
function UI.button(parent, handlers, props)
  local b = UI.new("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = (parent.ZIndex or 1) + 1 })
  if props then for k, v in pairs(props) do b[k] = v end end
  b.Parent = parent
  if handlers then UI.wire(b, handlers) end
  return b
end
function UI.pressable(parent, props, handlers)
  local b = UI.new("TextButton", { Text = "", AutoButtonColor = false, BorderSizePixel = 0 })
  if props then for k, v in pairs(props) do b[k] = v end end
  if parent then b.Parent = parent end
  if handlers then UI.wire(b, handlers) end
  return b
end
function UI.drag(handle, onStart, onMove, onEnd)
  local dragging, start, last = false, nil, nil
  handle.InputBegan:Connect(function(input)
    if not isPress(input) then return end
    local p = UI.point(input)
    if onStart then
      local r = onStart(p)
      if r == false then return end
    end
    dragging, start, last = true, p, p
  end)
  S.UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local p = UI.point(input)
    if onMove then onMove(p, p - last) end
    last = p
  end)
  S.UserInputService.InputEnded:Connect(function(input)
    if not dragging then return end
    if not isPress(input) then return end
    dragging = false
    if onEnd then onEnd(UI.point(input)) end
  end)
end

-- popovers (real, simplified)
local popovers = {}
UI.overlay = nil
function UI.mountOverlay(gui, scaleSource)
  if UI.overlay then return end
  UI.overlay = UI.frame(gui, { Name = "Overlay", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 50 })
end
function UI.closePopovers()
  for i = #popovers, 1, -1 do
    local p = popovers[i]
    if p.close then p.close(true) end
    table.remove(popovers, i)
  end
end
function UI.popoverOpen() return #popovers > 0 end
function UI.popover(anchor, opts, build)
  opts = opts or {}
  if not UI.overlay then UI.mountOverlay(anchor:FindFirstAncestorWhichIsA("ScreenGui") or B.host(), function() return 1 end) end
  local frame = UI.frame(UI.overlay, { Name = "Popover", Size = UDim2.fromOffset(opts.width or 220, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 60 })
  UI.corner(frame, "rPanel")
  Theme.bind(frame, "BackgroundColor3", "base")
  frame.BackgroundTransparency = 0.1
  UI.stroke(frame, "white", "rimA", 1)
  if build then build(frame) end
  local api = { frame = frame }
  function api.close(instant) if frame.Parent then frame:Destroy() end end
  table.insert(popovers, api)
  return api
end
function UI.menu(anchor, items, opts)
  opts = opts or {}
  return UI.popover(anchor, { width = opts.width or 220, align = opts.align or "right" }, function(content)
    UI.pad(content, 6)
    UI.list(content, "y", 2)
    for i, item in ipairs(items) do
      if item == "divider" then
        UI.divider(content, i)
      else
        local row = UI.frame(content, { Size = UDim2.new(1, 0, 0, 32), LayoutOrder = i, Theme = { BackgroundColor3 = "ink" }, BackgroundTransparency = 1 })
        UI.corner(row, "rSmall")
        UI.text(row, item.label or "", "label", item.danger and "bad" or "ink", { Position = UDim2.new(0, 10, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), TextSize = 13 })
        UI.button(row, {
          hover = function(on) Motion.to(row, "BackgroundTransparency", on and T.fill2A or 1, "quick") end,
          click = function()
            UI.sfx("click", 0.6)
            if not item.keepOpen then UI.closePopovers() end
            if item.run then B.try("menu", item.run) end
          end,
        })
      end
    end
  end)
end

-- tooltip (real, exact timings)
local TIP_W, TIP_MIN = 250, 110
local tipGui, tipCard, tipTitle, tipBody, tipFor
local tipToken, tipShown, tipGoneAt = 0, false, -math.huge
local TIP_IN = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TIP_MOVE = TweenInfo.new(0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TIP_OUT = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local function tipBuild()
  if tipCard and tipCard.Parent then return true end
  if not B.alive then return false end
  tipGui = B.screen(9950)
  tipCard = Instance.new("CanvasGroup")
  tipCard.Name = "Tip"
  tipCard.BackgroundColor3, tipCard.BackgroundTransparency, tipCard.BorderSizePixel = Color3.fromRGB(21, 21, 25), 0, 0
  tipCard.Size, tipCard.AutomaticSize = UDim2.fromOffset(TIP_W, 0), Enum.AutomaticSize.Y
  tipCard.GroupTransparency, tipCard.Visible = 1, false
  local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 10); corner.Parent = tipCard
  local rim = Instance.new("UIStroke")
  rim.ApplyStrokeMode, rim.Color, rim.Transparency, rim.Thickness = Enum.ApplyStrokeMode.Border, Color3.new(1, 1, 1), 0.86, 1
  rim.Parent = tipCard
  local padding = Instance.new("UIPadding")
  padding.PaddingTop, padding.PaddingBottom, padding.PaddingLeft, padding.PaddingRight = UDim.new(0, 8), UDim.new(0, 9), UDim.new(0, 11), UDim.new(0, 11)
  padding.Parent = tipCard
  local layout = Instance.new("UIListLayout"); layout.Padding = UDim.new(0, 2); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Parent = tipCard
  local function line(order, font, size, color)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency, label.BorderSizePixel = 1, 0
    label.Size, label.AutomaticSize = UDim2.new(1, 0, 0, 0), Enum.AutomaticSize.Y
    label.FontFace, label.TextSize, label.TextColor3 = font, size, color
    label.TextWrapped, label.TextXAlignment, label.LayoutOrder = true, Enum.TextXAlignment.Left, order
    label.Text, label.Visible = "", true
    label.Parent = tipCard
    return label
  end
  tipTitle = line(1, B.F.text600, 12, Color3.fromRGB(246, 246, 248))
  tipBody = line(2, B.F.text400, 12, Color3.fromRGB(190, 190, 198))
  tipCard.Parent = tipGui
  return true
end
local function tipHide()
  if not (tipShown and tipCard) then return end
  tipShown = false
  tipGoneAt = os.clock()
  local mine = tipToken
  S.TweenService:Create(tipCard, TIP_OUT, { GroupTransparency = 1 }):Play()
  task.delay(0.11, function() if mine == tipToken and not tipShown and tipCard then tipCard.Visible = false end end)
end
function UI.tooltip(target, text, title)
  if type(text) ~= "string" or text == "" then return end
  target.MouseEnter:Connect(function()
    tipToken = tipToken + 1
    local mine = tipToken
    tipFor = target
    local quick = tipShown or os.clock() - tipGoneAt < 0.3
    task.delay(quick and 0.02 or 0.35, function()
      if mine ~= tipToken or tipFor ~= target or not B.alive or not target.Parent then return end
      if not tipBuild() then return end
      tipTitle.Text, tipTitle.Visible = title or "", title ~= nil and title ~= ""
      tipBody.Text = text
      local width = math.clamp(math.max(#(title or "") * 7.2, #text * 6.3) + 24, TIP_MIN, TIP_W)
      tipCard.Size = UDim2.fromOffset(width, 0)
      local base, view = tipGui.AbsolutePosition, tipGui.AbsoluteSize
      local at, size = target.AbsolutePosition - base, target.AbsoluteSize
      local height = (tipTitle.Visible and 16 or 0) + math.ceil(#text * 6.3 / math.max(width - 22, 40)) * 16 + 20
      local x, y = at.X + size.X + 10, at.Y + size.Y / 2 - height / 2
      local from = Vector2.new(-8, 0)
      if x + width > view.X - 8 then
        x, from = at.X - width - 10, Vector2.new(8, 0)
        if x < 8 then
          x = math.clamp(at.X + size.X / 2 - width / 2, 8, math.max(view.X - width - 8, 8))
          y, from = at.Y + size.Y + 8, Vector2.new(0, -6)
          if y + height > view.Y - 8 then y, from = at.Y - height - 8, Vector2.new(0, 6) end
        end
      end
      y = math.clamp(y, 8, math.max(view.Y - height - 8, 8))
      local goal = UDim2.fromOffset(math.floor(x), math.floor(y))
      if tipShown and tipCard.Visible then
        S.TweenService:Create(tipCard, TIP_MOVE, { Position = goal, GroupTransparency = 0 }):Play()
      else
        tipCard.Position = goal + UDim2.fromOffset(from.X, from.Y)
        tipCard.GroupTransparency = 1
        tipCard.Visible = true
        S.TweenService:Create(tipCard, TIP_IN, { Position = goal, GroupTransparency = 0 }):Play()
      end
      tipShown = true
    end)
  end)
  target.MouseLeave:Connect(function()
    if tipFor ~= target then return end
    tipFor = nil
    tipToken = tipToken + 1
    local mine = tipToken
    task.delay(0.06, function() if mine == tipToken then tipHide() end end)
  end)
  if target:IsA("GuiButton") then target.MouseButton1Down:Connect(function() tipToken = tipToken + 1; tipFor = nil; tipHide() end) end
end
function UI.hideTip()
  tipToken = tipToken + 1
  tipFor = nil
  tipHide()
end

-- scroll (real, simplified)
function UI.scroll(parent, props)
  local scroller = Instance.new("ScrollingFrame")
  scroller.BackgroundTransparency = 1
  scroller.BorderSizePixel = 0
  scroller.ScrollBarThickness = 0
  scroller.ScrollingDirection = Enum.ScrollingDirection.Y
  scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
  scroller.CanvasSize = UDim2.new()
  scroller.ElasticBehavior = Enum.ElasticBehavior.Never
  if props then for k, v in pairs(props) do scroller[k] = v end end
  scroller.Parent = parent
  local api = { frame = scroller }
  function api.to(y, instant) scroller.CanvasPosition = Vector2.new(0, y) end
  function api.top(instant) api.to(0, instant) end
  function api.refresh() end
  return scroller, api
end
function UI.badge(parent, text, color, props)
  local badge = UI.frame(parent, { AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 18), Theme = { BackgroundColor3 = color or "accent" }, BackgroundTransparency = 0.82 })
  UI.corner(badge, 6)
  UI.pad(badge, 0, 6)
  UI.text(badge, text, "eyebrow", color or "accent", { TextSize = 9, Size = UDim2.fromScale(0, 1), AutomaticSize = Enum.AutomaticSize.X })
  if props then for k, v in pairs(props) do badge[k] = v end end
  return badge
end
function UI.divider(parent, order)
  local line = UI.frame(parent, { Name = "Divider", Size = UDim2.new(1, 0, 0, 1), LayoutOrder = order or 0, Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "strokeA" } })
  return line
end
UI.FAMILIES = { { "inter", "Inter (BASED)" } }
function UI.familyOf() return nil end
function UI.sweepFonts() end
function UI.setLetters() end

-- ---------------------------------------------------------------- Config (m05) — real in-memory flag store
local Config = { profile = "default", changed = Signal.new(), loaded = Signal.new(), saved = Signal.new(), bindsChanged = Signal.new(), values = {}, defaults = {}, binds = {}, actions = {} }
B.Config = Config
local values, defaults, listeners, binds, actions = Config.values, Config.defaults, {}, Config.binds, Config.actions
local byKey = {}
local storedBinds = {}
local PLACE = {}
Config.unshared = function(id) PLACE[id] = true end

local function isApp(id) return type(id) == "string" and id:sub(1, 4) == "app." end
local function sameType(a, b) return typeof(a) == typeof(b) end
local function isDefault(id)
  local d, v = defaults[id], values[id]
  if typeof(d) == "table" and typeof(v) == "table" then
    for k in pairs(d) do if d[k] ~= v[k] then return false end end
    for k in pairs(v) do if d[k] ~= v[k] then return false end end
    return true
  end
  return d == v
end
Config.isDefault = isDefault

-- flush/save: no-op (in-memory only)
function Config.flush() Config.saved:fire() end
function Config.save() end
function Config.touch() end

function Config.define(id, default)
  if values[id] ~= nil then return values[id] end
  defaults[id] = default
  values[id] = util.copy(default)
  if storedBinds[id] then
    binds[id] = storedBinds[id]
    byKey[storedBinds[id].key] = id
  end
  return values[id]
end
function Config.get(id)
  if values[id] == nil and defaults[id] ~= nil then return defaults[id] end
  return values[id]
end
function Config.set(id, value, quiet)
  local old = values[id]
  values[id] = value
  local fns = listeners[id]
  if fns then for _, fn in ipairs(fns) do B.try("config.on." .. id, fn, value, old) end end
  if not quiet then Config.changed:fire(id, value) end
end
function Config.reset(id)
  if defaults[id] ~= nil then Config.set(id, util.copy(defaults[id])) end
end
function Config.on(id, fn, now)
  listeners[id] = listeners[id] or {}
  table.insert(listeners[id], fn)
  if now then B.try("config.on.init." .. id, fn, values[id], values[id]) end
  return function()
    local fns = listeners[id]
    if not fns then return end
    for i, f in ipairs(fns) do if f == fn then table.remove(fns, i); break end end
  end
end
function Config.mirror(map, onChange)
  for id, default in pairs(map) do Config.define(id, default) end
  if onChange then onChange() end
end
Config.profileMode = "global"
function Config.profiles() return { "default" } end
function Config.load() end
function Config.saveAs() end
function Config.delete() end
function Config.setMode() end
function Config.resetAll() for id in pairs(values) do values[id] = util.copy(defaults[id]) end end

-- base64 (real)
local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
function Config.toBase64(str)
  return (str:gsub(".", function(x)
    local r, b = "", x:byte()
    for i = 8, 1, -1 do r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and "1" or "0") end
    return r
  end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
    if #x < 6 then return "" end
    local c = 0
    for i = 1, 6 do c = c + (x:sub(i, i) == "1" and 2 ^ (6 - i) or 0) end
    return B64:sub(c + 1, c + 1)
  end) .. ({ "", "==", "=" })[#str % 3 + 1]
end
function Config.fromBase64(data)
  data = data:gsub("[^" .. B64 .. "=]", "")
  return (data:gsub(".", function(x)
    if x == "=" then return "" end
    local r, f = "", (B64:find(x) - 1)
    for i = 6, 1, -1 do r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and "1" or "0") end
    return r
  end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
    if #x ~= 8 then return "" end
    local c = 0
    for i = 1, 8 do c = c + (x:sub(i, i) == "1" and 2 ^ (8 - i) or 0) end
    return string.char(c)
  end))
end
function Config.export() return "BASED2:" .. Config.toBase64("{}") end
function Config.import() return true, 0 end

-- keybind subsystem (real)
local SHORT = {
  LeftControl = "LCtrl", RightControl = "RCtrl", LeftShift = "LShift", RightShift = "RShift",
  LeftAlt = "LAlt", RightAlt = "RAlt", Backspace = "Bksp", CapsLock = "Caps", Escape = "Esc",
  One = "1", Two = "2", Three = "3", Four = "4", Five = "5", Six = "6", Seven = "7", Eight = "8", Nine = "9", Zero = "0",
}
function Config.keyLabel(key)
  if not key or key == "None" then return "None" end
  local s = SHORT[key]
  if s then return s end
  return (key:gsub("^Keypad", "Num"))
end
local function keyName(input)
  if input.UserInputType == Enum.UserInputType.Keyboard then return input.KeyCode.Name end
  if input.UserInputType == Enum.UserInputType.MouseButton2 then return "MouseButton2" end
  if input.UserInputType == Enum.UserInputType.MouseButton3 then return "MouseButton3" end
  return nil
end
Config.keyName = keyName
local function reindex()
  table.clear(byKey)
  for id, bind in pairs(binds) do if bind.key then byKey[bind.key] = id end end
end
Config.reindex = reindex
function Config.bind(id, key, mode)
  if key == nil then binds[id] = nil else binds[id] = { key = key, mode = mode or "toggle" } end
  reindex()
  Config.bindsChanged:fire()
end
function Config.bindOf(id) return binds[id] end
function Config.action(id, fn) actions[id] = fn end
function Config.isAction(id) return actions[id] ~= nil end
Config.ranAt = {}
Config.actionRan = Signal.new()
local actionStates = {}
function Config.actionState(id, fn) actionStates[id] = fn end
function Config.isActive(id)
  if actionStates[id] then return actionStates[id]() end
  local at = Config.ranAt[id]
  return at and (os.clock() - at < 0.6) or false
end
Config.capturing = false
Config.holdPanels = {}
local held = {}
local HOLD = 0.3
function Config.listen()
  B.connect(S.UserInputService.InputBegan, function(input, processed)
    if Config.capturing then return end
    if processed then return end
    local key = keyName(input)
    if not key then return end
    local id = byKey[key]
    if not id then return end
    if actions[id] then
      Config.ranAt[id] = os.clock()
      Config.actionRan:fire(id)
      B.try("config.action." .. id, actions[id])
      return
    end
    local v = values[id]
    if type(v) == "boolean" then
      local bind = binds[id]
      if bind and bind.mode == "hold" then
        held[id] = true
        Config.set(id, true)
      else
        Config.set(id, not v)
      end
    end
  end, "config.input")
  B.connect(S.UserInputService.InputEnded, function(input)
    local key = keyName(input)
    if not key then return end
    local id = byKey[key]
    if not id then return end
    local bind = binds[id]
    if bind and bind.mode == "hold" and held[id] then
      held[id] = false
      Config.set(id, false)
    end
  end, "config.inputend")
end
function Config.keyDown(key)
  if key == "MouseButton2" then return S.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) end
  if key == "MouseButton3" then return S.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton3) end
  local kc = Enum.KeyCode[key]
  return kc and S.UserInputService:IsKeyDown(kc) or false
end
Config.init = function() end

-- ---------------------------------------------------------------- Controls (m06) — real bindables + captureKey
local Controls = { bindables = {} }
B.Controls = Controls

function Controls.captureKey(done)
  Config.capturing = true
  local conn
  conn = S.UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.Keyboard and input.UserInputType ~= Enum.UserInputType.MouseButton2 and input.UserInputType ~= Enum.UserInputType.MouseButton3 then return end
    conn:Disconnect()
    task.delay(0.15, function() Config.capturing = false end)
    local key = keyName(input)
    if input.KeyCode == Enum.KeyCode.Escape then done(nil, true); return end
    if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then done(nil, false); return end
    done(key, false)
  end)
  B.own(conn)
end

-- makeRow (real, simplified)
function Controls.row(section, spec, controlWidth)
  local row = UI.frame(section.body, { Name = "Row", Size = UDim2.new(1, 0, 0, 40), LayoutOrder = section.count or 0 })
  section.count = (section.count or 0) + 1
  local left = UI.frame(row, { Size = UDim2.new(1, -(controlWidth or 120) - 20, 1, 0), BackgroundTransparency = 1 })
  UI.pad(left, 0, 0, 0, 12)
  UI.list(left, "y", 2)
  local label = UI.text(left, spec.label or "", "label", "ink", { TextSize = 13.5 })
  if spec.desc then UI.text(left, spec.desc, "caption", "faint", { TextSize = 11.5 }) end
  local slot = UI.frame(row, { Size = UDim2.fromOffset(controlWidth or 120, 30), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0), BackgroundTransparency = 1 })
  local wash = UI.frame(row, { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 0, Theme = { BackgroundColor3 = "ink" } })
  UI.corner(wash, "rSmall")
  local api = { frame = row, left = left, slot = slot, label = label, wash = wash }
  function api.hover(on) Motion.to(wash, "BackgroundTransparency", on and 0.965 or 1, "quick") end
  function api.flash() end
  if spec.tip then UI.tooltip(row, spec.tip) end
  return api
end
local makeRow = Controls.row

-- bindChip (real)
local function bindChip(slot, id, order)
  local chip = UI.frame(slot, { Size = UDim2.fromOffset(0, 24), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = order or 1, Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill2A" } })
  UI.corner(chip, 6)
  UI.pad(chip, 0, 8)
  local label = UI.text(chip, "", "mono", "ink", { TextSize = 11, Size = UDim2.fromScale(1, 1), AutomaticSize = Enum.AutomaticSize.X })
  local function refresh()
    local b = Config.bindOf(id)
    label.Text = b and (Config.keyLabel(b.key) .. (b.mode == "hold" and " ·hold" or "")) or ""
    chip.Visible = b ~= nil
  end
  Config.bindsChanged:connect(refresh)
  refresh()
  return chip
end

-- contextMenu (real)
local function contextMenu(anchor, spec, extra)
  local items = {}
  items[#items + 1] = { label = "Reset to default", run = function() Config.reset(spec.id) end }
  items[#items + 1] = { label = "Bind to key", run = function()
    Controls.captureKey(function(key, cancelled) if not cancelled and key then Config.bind(spec.id, key) end end)
  end }
  items[#items + 1] = { label = "Hold to activate", run = function()
    local b = Config.bindOf(spec.id)
    if b then Config.bind(spec.id, b.key, b.mode == "hold" and "toggle" or "hold") end
  end }
  items[#items + 1] = { label = "Clear key", run = function() Config.bind(spec.id, nil) end }
  return UI.menu(anchor, items, { align = "right" })
end

-- control constructors (real signatures, simplified rendering)
for _, kind in ipairs({ "toggle", "slider", "dropdown", "multi", "segmented", "color", "keybind", "button", "input", "note", "custom" }) do
  Controls[kind] = function(section, spec)
    local row = makeRow(section, spec, spec.width or 120)
    local id = spec.id
    if id then
      Config.define(id, spec.default)
      Controls.bindables[id] = { label = spec.label or id, kind = kind, page = section.page }
      if spec.bindable ~= false and (kind == "toggle" or kind == "button") then bindChip(row.slot, id, 1) end
    end
    local api = { row = row, id = id }
    function api.get() return id and Config.get(id) or spec.default end
    function api.set(v) if id then Config.set(id, v) end end
    return api
  end
end
Controls.segmentedBar = function(parent, options, initial, onPick, props)
  local bar = UI.frame(parent, { Size = UDim2.new(1, 0, 0, 30), Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill2A" } })
  UI.corner(bar, "rSmall")
  return bar, function(v) if onPick then onPick(v) end end
end
Controls.pillButton = function(parent, text, style, run, props)
  local button = UI.pressable(parent, { Size = UDim2.fromOffset(0, 28), AutomaticSize = Enum.AutomaticSize.X })
  UI.corner(button, "rSmall")
  UI.pad(button, 0, 13)
  local label = UI.text(button, text or "Run", "button", "ink", { Size = UDim2.fromScale(0, 1), AutomaticSize = Enum.AutomaticSize.X })
  UI.wire(button, { click = function() UI.sfx("click", 0.8); if run then run() end end })
  return button, label
end
Controls.field = function(parent, props, onSubmit)
  local field = UI.frame(parent, { Size = UDim2.fromOffset(150, 28), Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill2A" } })
  UI.corner(field, "rSmall")
  local box = UI.new("TextBox", { BackgroundTransparency = 1, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(10, 0), Text = "", FontFace = B.F.text400, TextSize = 13, ClearTextOnFocus = false, Parent = field })
  box.FocusLost:Connect(function(enter) if onSubmit then onSubmit(box.Text, enter) end end)
  return field, box
end
Controls.colorPopover = function(anchor, initial, onChange) return UI.popover(anchor, {}, function() end) end

-- ---------------------------------------------------------------- Window (m07) — real data model + kit
local Window = {
  open = false, built = false, pages = {}, order = {}, index = {}, scale = 1,
  onShow = Signal.new(), onPage = Signal.new(),
  startPage = nil, toastHook = nil, kit = nil, kits = {},
}
B.Window = Window
local W, H, SIDE, CONTENT_X, CONTENT_W, HEADER = 980, 624, 206, 226, 744, 84

-- Blur stub (hub-specific glass blur)
B.Blur = { enabled = false, parts = {}, visible = false, supported = function() return false end, start = function() end, update = function() end, show = function() end, set = function() end }

-- toasts (real, hookable)
local toasts = {}
local function layoutToasts()
  local y = 16
  for _, t in ipairs(toasts) do
    Motion.to(t.holder, "Position", UDim2.new(1, -16, 0, y), "smooth")
    y = y + (t.height or 62) + 10
  end
end
function Window.toast(opts)
  if Window.toastHook then
    local r = Window.toastHook(opts)
    if r then return r end
  end
  if not Window.hud then return function() end end
  opts = opts or {}
  local tone = opts.tone or "accent"
  local holder = UI.frame(Window.hud, { Name = "Toast", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 16), Size = UDim2.fromOffset(318, opts.text and 62 or 46), ZIndex = 100 })
  local sizer = Instance.new("UIScale"); sizer.Scale = Window.scale; sizer.Parent = holder
  local glass = UI.glass(holder, { level = "popover", radius = "rCard" })
  local chip = UI.frame(glass, { Size = UDim2.fromOffset(30, 30), Position = UDim2.fromOffset(12, 8), Theme = { BackgroundColor3 = tone }, BackgroundTransparency = 0.84 })
  UI.corner(chip, true)
  UI.text(glass, opts.title or "", "label", "ink", { Position = UDim2.fromOffset(54, 8), TextSize = 13.5 })
  if opts.text then UI.text(glass, opts.text, "caption", "sub", { Position = UDim2.fromOffset(54, 28), TextSize = 11.5 }) end
  local t = { holder = holder, height = opts.text and 62 or 46 }
  table.insert(toasts, 1, t)
  while #toasts > 4 do table.remove(toasts) end
  layoutToasts()
  local life = opts.time or 3.6
  local dismissed = false
  local function dismiss()
    if dismissed then return end
    dismissed = true
    for i, x in ipairs(toasts) do if x == t then table.remove(toasts, i) end end
    layoutToasts()
    Motion.to(holder, "BackgroundTransparency", 1, "quick", function() if holder.Parent then holder:Destroy() end end)
  end
  task.delay(life, dismiss)
  UI.button(glass, { click = dismiss })
  UI.sfxId(tone == "bad" and "rbxassetid://0" or "rbxassetid://0", 0.6)
  return dismiss
end

-- Page model (real)
local Page = {}
Page.__index = Page
local SectionApi = {}
for _, kind in ipairs({ "toggle", "slider", "dropdown", "multi", "segmented", "color", "keybind", "button", "input", "note", "custom" }) do
  SectionApi[kind] = function(self, spec) return Controls[kind](self.raw, spec) end
end
local function sectionApi(raw) return setmetatable({ raw = raw, body = raw.body }, SectionApi) end
function Page:section(spec)
  spec = spec or {}
  local card = UI.surface(self.body, { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = #self.sections + 1 })
  UI.stroke(card, "ink", "strokeA")
  local stack = UI.frame(card, { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 })
  UI.pad(stack, 12, 14, 12, 14)
  UI.list(stack, "y", 10)
  if spec.title then
    local head = UI.frame(stack, { Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, LayoutOrder = 0 })
    if spec.icon then UI.icon(head, spec.icon, 16, "sub", { Position = UDim2.new(0, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5) }) end
    UI.text(head, spec.title or "", "heading", "ink", { Position = UDim2.fromOffset(spec.icon and 24 or 0, 0), TextSize = 14 })
  end
  local body = UI.frame(stack, { Name = "Body", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 1 })
  UI.list(body, "y", 2)
  local raw = { body = body, count = 0, page = self, card = card }
  raw.index = function(entry)
    entry.page = self
    entry.section = spec.title or "Section"
    entry.row = { frame = body, flash = function() end }
    table.insert(Window.index, entry)
  end
  self.sections[#self.sections + 1] = raw
  return sectionApi(raw)
end
function Page:custom(height, build)
  local f = UI.frame(self.body, { Size = UDim2.new(1, 0, 0, height or 100), LayoutOrder = #self.sections + 1, BackgroundTransparency = 1 })
  if build then B.try("page.custom", build, f) end
  return f
end
function Page:empty(icon, title, text)
  local f = UI.frame(self.body, { Size = UDim2.new(1, 0, 0, 380), BackgroundTransparency = 1 })
  local orb = UI.frame(f, { Size = UDim2.fromOffset(64, 64), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 40), Theme = { BackgroundColor3 = "accent" }, BackgroundTransparency = 0.85 })
  UI.corner(orb, true)
  UI.text(f, title or "", "title", "ink", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 120), TextXAlignment = Enum.TextXAlignment.Center })
  UI.text(f, text or "", "body", "sub", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 160), TextXAlignment = Enum.TextXAlignment.Center, TextWrapped = true, Size = UDim2.new(0, 320, 0, 0) })
end

function Window.page(spec)
  spec = spec or {}
  local page = setmetatable({
    id = spec.id or util.randomName(), title = spec.title or "Page", icon = spec.icon,
    group = spec.group or "", eyebrow = spec.eyebrow, badge = spec.badge,
    hidden = spec.hidden, order = spec.order or #Window.order + 1,
    sections = {}, body = nil, ready = false, build = spec.build,
  }, Page)
  Window.pages[page.id] = page
  table.insert(Window.order, page)
  table.sort(Window.order, function(a, b) return (a.order or 0) < (b.order or 0) end)
  if Window.built then Window.rebuildNav() end
  return page
end
function Window.removePage(id)
  Window.pages[id] = nil
  for i, p in ipairs(Window.order) do if p.id == id then table.remove(Window.order, i) break end end
  if Window.built then Window.rebuildNav() end
end

local function ensureBuilt(page)
  if page.ready then return end
  page.ready = true
  if not page.body then
    page.body = UI.frame(Instance.new("Frame"), { Size = UDim2.fromScale(1, 1) })
  end
  if page.build then B.try("page.build." .. page.id, page.build, page) end
  if #page.sections == 0 then page:empty() end
end
Window.ensureBuilt = ensureBuilt
function Window.prebuild() for _, p in ipairs(Window.order) do ensureBuilt(p) end end

function Window.go(id, instant)
  local page = Window.pages[id]
  if not page then return end
  UI.closePopovers()
  UI.hideTip()
  Window.current = page
  ensureBuilt(page)
  Window.selectNav(page, instant)
  Window.setTitle(page, instant)
  Window.onPage:fire(page)
  UI.sfx("tab", 0.6)
end

-- build (real structure, simplified rendering)
Window.navItems = {}
function Window.build()
  if Window.built then return end
  Window.built = true
  local gui = B.screen(9000, "BasedHub")
  local hudGui = B.screen(9100, "Hud")
  Window.hud = UI.frame(hudGui, { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Name = "Hud" })
  UI.soundHost = UI.frame(hudGui, { Name = "Sound", BackgroundTransparency = 1 })
  Window.modal = UI.new("TextButton", { Text = "", Modal = true, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 40, Parent = gui })
  local stage = UI.frame(gui, { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 })
  Window.holder = UI.frame(stage, { Size = UDim2.fromOffset(W, H), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Visible = false, Name = "Holder" })
  Window.sizer = Instance.new("UIScale"); Window.sizer.Parent = Window.holder
  UI.unit = function() return Window.sizer.Scale end
  Window.root = UI.group(Window.holder, { Size = UDim2.fromScale(1, 1), Name = "Root" })
  UI.corner(Window.root, "rWindow")
  local glass, rim = UI.glass(Window.root, { level = "window", radius = "rWindow" })
  Window.rim = rim
  local side = UI.frame(glass, { Size = UDim2.fromOffset(SIDE, 1), Name = "Sidebar", Theme = { BackgroundColor3 = "base" }, BackgroundTransparency = 0.3 })
  local brand = UI.frame(side, { Size = UDim2.new(1, 0, 0, 56), BackgroundTransparency = 1 })
  UI.text(brand, "BASED", "brand", "ink", { Position = UDim2.fromOffset(16, 14), TextSize = 17 })
  UI.text(brand, "hub", "display", "accent", { Position = UDim2.fromOffset(86, 10), TextSize = 21 })
  Window.navHost, Window.navScroll = UI.scroll(side, { Size = UDim2.new(1, -16, 1, -128), Position = UDim2.fromOffset(8, 60), BackgroundTransparency = 1 })
  Window.navPill = UI.frame(Window.navHost, { Name = "Pill", Size = UDim2.new(1, -8, 0, 34), Position = UDim2.fromOffset(4, 0), Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill2A" }, Visible = false, ZIndex = 1 })
  UI.corner(Window.navPill, "rControl")
  UI.stroke(Window.navPill, "white", "strokeA", 1)
  local header = UI.frame(glass, { Size = UDim2.new(1, -SIDE, 0, HEADER), Position = UDim2.fromOffset(SIDE, 0), BackgroundTransparency = 1 })
  Window.eyebrow = UI.text(header, "BASED", "eyebrow", "faint", { Position = UDim2.fromOffset(CONTENT_X - SIDE, 20), TextSize = 9 })
  Window.titleClip = UI.frame(header, { Size = UDim2.new(1, -200, 0, 40), Position = UDim2.fromOffset(CONTENT_X - SIDE, 34), ClipsDescendants = true, BackgroundTransparency = 1 })
  Window.pageHost = UI.frame(glass, { Name = "Pages", Size = UDim2.new(0, CONTENT_W, 1, -(HEADER + 16)), Position = UDim2.fromOffset(CONTENT_X, HEADER + 6), ClipsDescendants = true, BackgroundTransparency = 1 })
  UI.mountOverlay(gui, function() return Window.sizer.Scale end)
  Window.position = Motion.spring(2, "snappy", function(x) Window.holder.Position = UDim2.fromOffset(x[1], x[2]) end, 0.2)
  Window.position:snap({ B.viewport().X / 2, B.viewport().Y / 2 })
  function Window.clampTo(x, y)
    local view = B.viewport()
    return math.clamp(x, 40, view.X - 40), math.clamp(y, 40, view.Y - 40)
  end
  Window.rebuildNav()
  Window.rescale()
end
function Window.rescale()
  if not Window.built then return end
  local view = B.viewport()
  Window.scale = math.clamp(math.min(view.Y / 1090, view.X / 1500), 0.55, 1.5)
  Motion.to(Window.sizer, "Scale", Window.scale, "smooth")
end
function Window.rebuildNav()
  if not Window.built then return end
  table.clear(Window.navItems)
  for _, child in ipairs(Window.navHost:GetChildren()) do if child.Name ~= "Pill" then child:Destroy() end end
  local y = 0
  local lastGroup
  for _, page in ipairs(Window.order) do
    if not page.hidden then
      if page.group ~= lastGroup then
        lastGroup = page.group
        if page.group ~= "" then
          y = y + 10
          UI.text(Window.navHost, string.upper(page.group), "eyebrow", "faint", { Name = "Group", Position = UDim2.fromOffset(12, y), TextSize = 9 })
          y = y + 22
        end
      end
      local item = UI.frame(Window.navHost, { Name = "Item", Size = UDim2.new(1, -8, 0, 34), Position = UDim2.fromOffset(4, y), Theme = { BackgroundColor3 = "ink" }, BackgroundTransparency = 1, ZIndex = 2 })
      UI.corner(item, "rControl")
      UI.icon(item, page.icon, 17, "sub", { Position = UDim2.new(0, 12, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5) })
      UI.text(item, page.title, "label", "sub", { Position = UDim2.new(0, 39, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), TextSize = 13.5 })
      local entry = { frame = item, page = page, y = y }
      table.insert(Window.navItems, entry)
      UI.button(item, { click = function() Window.go(page.id) end })
      y = y + 36
    end
  end
  if Window.current then Window.selectNav(Window.current, true) end
end
function Window.selectNav(page, instant)
  for _, entry in ipairs(Window.navItems) do
    if entry.page == page then
      if instant then
        Window.navPill.Visible = true
        Motion.snap(Window.navPill, "Position", UDim2.fromOffset(4, entry.y))
        Motion.snap(Window.navPill, "Size", UDim2.new(1, -8, 0, 34))
      else
        Motion.to(Window.navPill, "Position", UDim2.fromOffset(4, entry.y), "snappy")
        Motion.to(Window.navPill, "Size", UDim2.new(1, -8, 0, 34), "liquid")
      end
    end
  end
end
function Window.setTitle(page, instant)
  if Window.titleLabel then Window.titleLabel:Destroy() end
  Window.titleLabel = UI.text(Window.titleClip, page.title, "display", "ink", { Position = UDim2.fromOffset(0, 2), Name = "Title" })
  if Window.eyebrow then Window.eyebrow.Text = string.upper(page.eyebrow or (page.group ~= "" and page.group or "BASED")) end
end
function Window.show(on, instant)
  if not Window.built then Window.build() end
  if Window.open == on then return end
  Window.open = on
  UI.closePopovers()
  UI.hideTip()
  Window.holder.Visible = true
  if on then
    if not Window.current and Window.order[1] then Window.go(Window.startPage or Window.order[1].id, true) end
    if instant then UI.setFade(Window.root, 1)
    else
      UI.setFade(Window.root, 0)
      UI.fade(Window.root, 1, "smooth")
      UI.sfx("open", 0.8)
    end
  else
    UI.fade(Window.root, 0, "quick", function() if not Window.open then Window.holder.Visible = false end end)
    UI.sfx("close", 0.7)
  end
  Window.onShow:fire(on)
end
function Window.toggle() Window.show(not Window.open) end
function Window.anyOpen()
  return Window.open or (B.Unnamed ~= nil and B.Unnamed.open == true) or (B.Novoline ~= nil and B.Novoline.open == true)
end
function Window.showing(id)
  if Window.open and Window.current and Window.current.id == id then return true end
  return false
end
function Window.look()
  local look = Config.get("app.gui")
  if look == "unnamed" and B.Unnamed then return "unnamed" end
  if look == "novoline" and B.Novoline then return "novoline" end
  return "based"
end
function Window.showActive(on)
  local look = Window.look()
  if look == "unnamed" and B.Unnamed then B.Unnamed.show(on)
  elseif look == "novoline" and B.Novoline then B.Novoline.show(on)
  else Window.show(on) end
end
function Window.toggleActive()
  local look = Window.look()
  if look == "unnamed" and B.Unnamed then B.Unnamed.toggle()
  elseif look == "novoline" and B.Novoline then B.Novoline.toggle()
  else Window.toggle() end
end

-- kit/kits (real registration; Novoline sets Window.kits.novoline and owns())
local ROLES = {
  card = { "ink", "fill1A" }, field = { "ink", "fill2A" }, hover = { "ink", "fill3A" }, line = { "ink", "strokeA" }, back = { "base", "baseA" },
  text = { "ink" }, dim = { "sub" }, faint = { "faint" }, accent = { "accent" }, onAccent = { "accentInk" }, good = { "ok" }, bad = { "bad" },
}
local basedKit = { look = "based", radius = 14, small = 9, size = 13 }
function basedKit.color(role)
  local r = ROLES[role] or ROLES.text
  return T[r[1]], r[2] and T[r[2]] or 0
end
function basedKit.paint(instance, property, role) Theme.bind(instance, property, (ROLES[role] or ROLES.text)[1]) end
function basedKit.fill(instance, role)
  local r = ROLES[role] or ROLES.card
  Theme.bind(instance, "BackgroundColor3", r[1])
  if r[2] then Theme.bind(instance, "BackgroundTransparency", r[2]) else instance.BackgroundTransparency = 0 end
end
function basedKit.clear(instance) instance.BackgroundTransparency = 1 end
function basedKit.font(bold) return bold and B.F.text600 or B.F.text500 end
function basedKit.text(parent, value, props, bold, size)
  local label = UI.text(parent, value, bold and "heading" or "label", "ink", { TextSize = size or 13 })
  if props then for k, v in pairs(props) do label[k] = v end end
  return label
end
function basedKit.entry(parent, size)
  local entry = Instance.new("TextBox")
  entry.BackgroundTransparency, entry.BorderSizePixel = 1, 0
  entry.FontFace = B.F.text500
  entry.TextSize = size or 13
  entry.TextXAlignment, entry.ClearTextOnFocus = Enum.TextXAlignment.Left, false
  Theme.bind(entry, "TextColor3", "ink")
  entry.Parent = parent
  return entry
end
function basedKit.outline(frame) return UI.stroke(frame, "ink", "strokeA") end
function basedKit.corner(frame, radius) return UI.corner(frame, radius or basedKit.radius) end
function basedKit.menu(anchor, items) return UI.menu(anchor, items, { align = "right" }) end
Window.kits = { based = basedKit }
-- Window.kit(frame): returns the active kit for a frame (Novoline registers owns())
function Window.kit(frame)
  for name, other in pairs(Window.kits) do
    if name ~= "based" and other.owns and frame and other.owns(frame) then return other end
  end
  return basedKit
end
function Window.activeKit() return Window.kits[Window.look()] or basedKit end

-- palette (real, simplified)
function Window.palette()
  if not Window.built then return end
  if not Window.open then Window.show(true) end
  for _, p in ipairs(Window.order) do ensureBuilt(p) end
end

-- ---------------------------------------------------------------- stub tables (must exist, indexing never errors)
-- (audio stub omitted)
B.Server = {}
B.Card = {}
B.Keys = {}
B.Registry = {}
B.Island = {}
B.Hud = {}
B.Unnamed = nil
B.Novoline = nil

-- start config listener
Config.listen()

return B

end)()

-- ---------------------------------------------------------------- novoline look (inlined; B is upvalue)
-- 53_novoline.lua (inlined into final chunk; outer do..end wrapper removed)
-- ============================================================================
--  53 novoline  the third look: Novoline, as it looks with everything on
--
--  Drawn after Novoline's design (its code is PolyForm Strict, so none of it is
--  here: only how it looks and moves, read from its source, 2026-10-29: its
--  "upstream 9" layout). A pill at the bottom of the screen holds the tabs.
--  Opening it shades the game and every tab comes up as a DECK: cards of dark
--  glass (a near-black gradient, 8,8,9 to 26,26,28, a fine white rim lit at
--  the top and bottom, a soft shadow) held in the four corners of the screen,
--  40 px in from the sides, 34 from the top and 90 from the bottom:
--    Home      Novoline's own: the welcome line, the clock and the executor top
--              right; you, quick actions, what is playing and two quick commands
--              bottom left; the game, this server and your friends bottom right.
--    any other Novoline's settings deck: the tab's name, a search pill and your
--              account top right; its sections in a list card beside the card
--              that holds the chosen section's controls (one faint white group,
--              hairlines between rows); quick settings (three tinted tiles: the
--              tab's first switches) and its shortcuts on the right.
--  Cards rise out of the dock when it opens (0.56 s quint out from a 120 x 44
--  pill), sink back into it when it shuts, and change tab by gliding each card
--  into the next tab's card in the same corner (0.5 s quint out). Monochrome
--  controls: Novoline's glass switch (a white pill knob on a clear track that
--  fills when on), glass sliders, soft tile buttons, lists that open in place.
--  An island at the top shows what is playing and every message.
--  The same tabs and settings as the other looks (every control is bound to the
--  same flag); a tab that draws itself takes this look from Window.kit.
-- ============================================================================
local S, util, Motion, UI, Config, Window, Controls = B.S, B.util, B.Motion, B.UI, B.Config, B.Window, B.Controls
local UIS = S.UserInputService
local TS = S.TweenService
local N = { open = false, built = false, pages = {}, tabs = {}, current = nil }
B.Novoline = N

local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end
local P = {
  top = rgb(8, 8, 9), bottom = rgb(26, 26, 28),
  card = rgb(28, 28, 32), raised = rgb(38, 38, 43), hover = rgb(48, 48, 54), line = rgb(55, 55, 61), divider = rgb(42, 42, 48),
  text = rgb(244, 244, 246), sub = rgb(205, 205, 210), dim = rgb(158, 158, 164), faint = rgb(108, 108, 115),
  on = rgb(242, 242, 244), off = rgb(58, 58, 62), knobOn = rgb(18, 18, 20), knobOff = rgb(255, 255, 255),
  rail = rgb(52, 52, 58), fill = rgb(224, 224, 226), danger = rgb(239, 68, 68), good = rgb(82, 214, 160),
  white = Color3.new(1, 1, 1), black = Color3.new(0, 0, 0),
  -- Novoline's own names for what its cards use
  subtle = rgb(150, 150, 156), ink = rgb(18, 18, 20), placeholder = rgb(118, 118, 124),
}
N.P = P
-- the tinted tiles (Novoline's quick settings and quick actions): the plate when on, and its icon
local TINT = {
  { rgb(13, 40, 51), rgb(64, 186, 255) },    -- blue
  { rgb(38, 28, 62), rgb(168, 120, 255) },   -- purple
  { rgb(14, 46, 40), rgb(56, 224, 186) },    -- teal
  { rgb(52, 30, 12), rgb(255, 156, 64) },    -- amber (quick commands)
  { rgb(52, 18, 22), rgb(255, 96, 102) },    -- red
}
local ROW_H, COMPACT_H = 56, 40       -- a setting with its line under it, and one without
local GLIDE = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local FILL_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local ACCENT = rgb(230, 30, 30)
local function accent() return Config.get("app.novoline.accent") or ACCENT end
local W, H = 600, 480                 -- the panel, design pixels (Settings can drag it bigger)
local DOCK_H = 52
local OPEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local CLOSE_INFO = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local FADE_INFO = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local HOVER_INFO = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local SWITCH_INFO = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
-- Novoline's own sounds, as its source plays them: the menu opening (at 0.9 speed) and closing
-- (the same sound at 0.7), a change of tab on the dock, and a notification. It has none for a
-- click or a switch (its one click sound is fetched from a file host at run time: not used here),
-- so those keep the hub's own.
local NV_SOUND = {
  open = { "rbxassetid://255881176", 0.8, 0.9 },
  close = { "rbxassetid://255881176", 0.8, 0.7 },
  tab = { "rbxassetid://1180994874", 0.8, 1 },
  notify = { "rbxassetid://255881176", 0.6, 1 },
}
local function nvSound(name)
  local own = NV_SOUND[name]
  if own and UI.sfxId then UI.sfxId(own[1], own[2], own[3]) end
end
local function tween(instance, info, props)
  if Motion.reduced then
    for key, value in pairs(props) do instance[key] = value end
    return nil
  end
  local t = TS:Create(instance, info, props)
  t:Play()
  return t
end

-- ---------------------------------------------------------------- the letters
-- Gotham, as Novoline has it; Settings > Novoline font picks another.
local FONTS = {
  { "gotham", "Gotham", "rbxasset://fonts/families/GothamSSm.json", 1 },
  { "builder", "Builder Sans", "rbxasset://fonts/families/BuilderSans.json", 1.04 },
  { "montserrat", "Montserrat", "rbxasset://fonts/families/Montserrat.json", 0.98 },
  { "inter", "Inter", nil, 1 },
  { "ubuntu", "Ubuntu", "rbxasset://fonts/families/Ubuntu.json", 1.04 },
  { "nunito", "Nunito", "rbxasset://fonts/families/Nunito.json", 1.04 },
}
N.FONTS = FONTS
local family, factor = FONTS[1][3], 1
local function pickFont()
  local id = Config.get("app.novoline.font")
  local spec = FONTS[1]
  for _, entry in ipairs(FONTS) do if entry[1] == id then spec = entry end end
  family = spec[3] or ((B.F0 or B.F).text500 and (B.F0 or B.F).text500.Family) or FONTS[1][3]
  factor = spec[4]
end
local WEIGHTS = { regular = Enum.FontWeight.Regular, medium = Enum.FontWeight.Medium, bold = Enum.FontWeight.Bold, black = Enum.FontWeight.Heavy }
local faces = {}
local function face(weight)
  local key = family .. (weight or "medium")
  if not faces[key] then
    local ok, made = pcall(Font.new, family, WEIGHTS[weight or "medium"] or Enum.FontWeight.Medium)
    faces[key] = ok and made or Font.fromEnum(Enum.Font.GothamMedium)
  end
  return faces[key]
end
-- every text drawn here, kept STRONG and swept (weak tables lose labels that are still on screen)
local typed = {}
local function letters(item, size, weight)
  typed[item] = { size, weight or "medium" }
  item.FontFace = face(weight)
  item.TextSize = math.floor(size * factor + 0.5)
  return item
end
local function refont()
  pickFont()
  for item, spec in pairs(typed) do
    if item.Parent then
      item.FontFace = face(spec[2])
      item.TextSize = math.floor(spec[1] * factor + 0.5)
    else
      typed[item] = nil
    end
  end
end
function N.owns(item) return typed[item] ~= nil end
Motion.every(function() for item in pairs(typed) do if not item.Parent then typed[item] = nil end end end, 0.1, "novoline.sweep")

-- ---------------------------------------------------------------- the accent, kept on what wears it
local worn = {}
local function wear(instance, property)
  for _, entry in ipairs(worn) do if entry[1] == instance and entry[2] == property then instance[property] = accent(); return instance end end
  worn[#worn + 1] = { instance, property }
  instance[property] = accent()
  return instance
end
local function unwear(instance, property)
  for index = #worn, 1, -1 do
    local entry = worn[index]
    if entry[1] == instance and (property == nil or entry[2] == property) then table.remove(worn, index) end
  end
end
local function repaint()
  local color = accent()
  for index = #worn, 1, -1 do
    local entry = worn[index]
    if entry[1].Parent then entry[1][entry[2]] = color else table.remove(worn, index) end
  end
end

-- ---------------------------------------------------------------- pieces
local function box(parent, props)
  local frame = Instance.new("Frame")
  frame.BorderSizePixel = 0
  frame.BackgroundTransparency = 1
  if props then for key, value in pairs(props) do frame[key] = value end end
  frame.Parent = parent
  return frame
end
local function round(instance, radius)
  local corner = instance:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
  corner.CornerRadius = radius == true and UDim.new(1, 0) or UDim.new(0, radius or 12)
  corner.Parent = instance
  return corner
end
local function rim(instance, color, transparency)
  local line = Instance.new("UIStroke")
  line.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
  line.Color = color or P.white
  line.Transparency = transparency or 0.9
  line.Thickness = 1
  line.Parent = instance
  return line
end
local function text(parent, value, size, weight, props)
  local label = Instance.new("TextLabel")
  label.BackgroundTransparency, label.BorderSizePixel = 1, 0
  label.TextColor3 = P.text
  label.TextXAlignment = Enum.TextXAlignment.Left
  label.TextTruncate = Enum.TextTruncate.AtEnd
  label.Text = value or ""
  letters(label, size or 13, weight)
  if props then for key, v in pairs(props) do label[key] = v end end
  label.Parent = parent
  return label
end
local function entryBox(parent, size)
  local entry = Instance.new("TextBox")
  entry.BackgroundTransparency, entry.BorderSizePixel = 1, 0
  entry.TextColor3, entry.PlaceholderColor3 = P.text, P.faint
  entry.TextXAlignment, entry.ClearTextOnFocus, entry.ClipsDescendants = Enum.TextXAlignment.Left, false, true
  letters(entry, size or 13, "medium")
  entry.Parent = parent
  return entry
end
local function hit(parent, props)
  local button = Instance.new("TextButton")
  button.Text, button.AutoButtonColor, button.BackgroundTransparency, button.BorderSizePixel = "", false, 1, 0
  button.Size = UDim2.fromScale(1, 1)
  button.ZIndex = 8
  if props then for key, value in pairs(props) do button[key] = value end end
  button.Parent = parent
  return button
end
local function glyph(parent, name, size, color, props)
  local image = Instance.new("ImageLabel")
  image.BackgroundTransparency, image.BorderSizePixel = 1, 0
  image.Size = UDim2.fromOffset(size, size)
  image.ScaleType = Enum.ScaleType.Fit
  image.ImageColor3 = color or P.dim
  UI.setIcon(image, name)
  if props then for key, value in pairs(props) do image[key] = value end end
  image.Parent = parent
  return image
end
local function list(parent, gap, horizontal, align)
  local layout = Instance.new("UIListLayout")
  layout.FillDirection = horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
  layout.Padding = UDim.new(0, gap or 0)
  layout.SortOrder = Enum.SortOrder.LayoutOrder
  if align == "center" then
    if horizontal then layout.HorizontalAlignment = Enum.HorizontalAlignment.Center else layout.VerticalAlignment = Enum.VerticalAlignment.Center end
  end
  if horizontal then layout.VerticalAlignment = Enum.VerticalAlignment.Center end
  layout.Parent = parent
  return layout
end
local function pad(parent, top, right, bottom, left)
  local padding = Instance.new("UIPadding")
  padding.PaddingTop, padding.PaddingRight = UDim.new(0, top or 0), UDim.new(0, right or top or 0)
  padding.PaddingBottom, padding.PaddingLeft = UDim.new(0, bottom or top or 0), UDim.new(0, left or right or top or 0)
  padding.Parent = parent
  return padding
end
-- Novoline's glass: the near-black gradient, the rim lit at top and bottom, a shadow under it
local function glass(frame, radius, shadow)
  frame.BackgroundColor3 = P.white
  frame.BackgroundTransparency = 0
  round(frame, radius)
  local body = Instance.new("UIGradient")
  body.Name = "Body"
  body.Rotation = 90
  body.Color = ColorSequence.new(P.top, P.bottom)
  body.Parent = frame
  local line = rim(frame, P.white, 0)
  pcall(function() line.BorderStrokePosition = Enum.BorderStrokePosition.Inner end)
  local light = Instance.new("UIGradient")
  light.Rotation = 90
  light.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.84), NumberSequenceKeypoint.new(0.5, 0.92), NumberSequenceKeypoint.new(1, 0.78) })
  light.Parent = line
  if shadow ~= false then
    pcall(function()
      local glow = Instance.new("UIShadow")
      glow.Color = P.black
      glow.BlurRadius = UDim.new(0, 26)
      glow.Offset = UDim2.fromOffset(0, 10)
      glow.Transparency = 0.45
      glow.ZIndex = -1
      glow.Parent = frame
    end)
  end
  return line
end
N.glass = glass
-- Novoline's soft button: a dark gradient (46,46,49 to 32,32,35), a rim lit at the top, a lift under the mouse
function N.softFace(holder, radius, hover)
  local face0 = box(holder, { Name = "Face", Size = UDim2.fromScale(1, 1), BackgroundColor3 = P.white, BackgroundTransparency = 0, ZIndex = holder.ZIndex + 1 })
  round(face0, radius or 16)
  local body = Instance.new("UIGradient"); body.Rotation = 90; body.Color = ColorSequence.new(rgb(46, 46, 49), rgb(32, 32, 35)); body.Parent = face0
  local line = rim(face0, P.white, 0)
  pcall(function() line.BorderStrokePosition = Enum.BorderStrokePosition.Inner end)
  local light = Instance.new("UIGradient"); light.Rotation = 90
  light.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.86), NumberSequenceKeypoint.new(0.4, 0.96), NumberSequenceKeypoint.new(1, 0.97) })
  light.Parent = line
  local lift = box(face0, { Name = "Lift", Size = UDim2.fromScale(1, 1), BackgroundColor3 = P.white, BackgroundTransparency = 1, ZIndex = face0.ZIndex + 1 })
  round(lift, radius or 16)
  if hover then
    face0.MouseEnter:Connect(function() tween(lift, HOVER_INFO, { BackgroundTransparency = 0.95 }) end)
    face0.MouseLeave:Connect(function() tween(lift, HOVER_INFO, { BackgroundTransparency = 1 }) end)
  end
  return face0, lift
end
-- Novoline's tile: the soft button's plate without the lift (a key, an "Open", a value), its rim faint
local function tile(parent, props, radius)
  local plate = box(parent, props)
  plate.BackgroundColor3, plate.BackgroundTransparency = P.white, 0
  round(plate, radius or 14)
  local body = Instance.new("UIGradient"); body.Name = "Body"; body.Rotation = 90; body.Color = ColorSequence.new(rgb(46, 46, 49), rgb(32, 32, 35)); body.Parent = plate
  rim(plate, P.white, 0.9)
  return plate, body
end
N.tile = tile
local function lower(value) return string.lower(tostring(value or "")) end
-- a name that would be cut short on a tile shrinks to fit instead (down to `least`), measured in
-- design px (TextScaled would measure it after the look's own scale, and come out small)
local function shrink(label, most, least, width)
  local function fit()
    local room = width or ((label.Size.X.Scale == 0) and label.Size.X.Offset) or 0
    if room <= 0 then return end
    local weight = label.FontFace and label.FontFace.Weight
    local heavy = weight ~= nil and weight.Value >= Enum.FontWeight.Bold.Value
    local enum = heavy and Enum.Font.GothamBold or Enum.Font.GothamMedium
    local size = most
    while size > (least or 9) do
      local ok, bounds = pcall(S.TextService.GetTextSize, S.TextService, label.Text, size, enum, Vector2.new(4000, 200))
      -- (the look's letters set a little wider than the measure's: kept a tenth short)
      if not ok or bounds.X <= room * 0.9 then break end
      size = size -  1
    end
    label.TextSize = size
    return size
  end
  local size = fit()
  label:GetPropertyChangedSignal("Text"):Connect(fit)
  return label, size
end
local function options(spec)
  local out = {}
  for _, option in ipairs(spec or {}) do
    if type(option) == "table" then out[#out + 1] = { value = option.value or option[1], label = option.label or option[2] or tostring(option.value or option[1]) }
    else out[#out + 1] = { value = option, label = tostring(option) } end
  end
  return out
end

-- ---------------------------------------------------------------- the kit (src/07): tabs that draw themselves, in this look
local KIT = { card = P.card, field = P.raised, hover = P.hover, line = P.line, back = rgb(18, 18, 20), text = P.text, dim = P.dim, faint = P.faint,
  onAccent = P.white, good = P.good, bad = P.danger }
local kit = { look = "novoline", radius = 16, small = 10, size = 13 }
function kit.owns(frame) return N.gui ~= nil and frame:IsDescendantOf(N.gui) end
function kit.color(role)
  if role == "accent" then return accent(), 0 end
  return KIT[role] or P.text, 0
end
function kit.paint(instance, property, role)
  unwear(instance, property)
  if role == "accent" then wear(instance, property) else instance[property] = KIT[role] or P.text end
end
function kit.fill(instance, role)
  kit.paint(instance, "BackgroundColor3", role)
  instance.BackgroundTransparency = 0
end
function kit.clear(instance) instance.BackgroundTransparency = 1 end
function kit.font(bold) return face(bold and "bold" or "medium") end
function kit.text(parent, value, props, bold, size) return text(parent, value, size or 13, bold and "bold" or "medium", props) end
function kit.entry(parent, size) return entryBox(parent, size or 13) end
function kit.outline(frame) return rim(frame, P.line, 0.2) end
function kit.corner(frame, radius) return round(frame, radius or 16) end
N.kit = kit
Window.kits.novoline = kit
function N.palette() return { card = P.card, elevated = P.raised, stroke = P.line, text = P.text, dim = P.dim, faint = P.faint, accent = accent(), font = face("medium"), bold = face("bold") } end

-- ---------------------------------------------------------------- floating bits: a tip, a menu (in the overlay layer, above the panel)
local overlay
local tip, tipFor
local function hideTip()
  tipFor = nil
  if tip then tip.Visible = false end
  if UI.hideTip then UI.hideTip() end
end
-- What a control does, on hover (2026-10-30, every look): the hub's one tip, its name over what it
-- does. A row with no words of its own still says its name when the row cuts it short.
local function tooltip(button, desc, holder, title)
  if desc and desc ~= "" and UI.tooltip then
    UI.tooltip(button, desc, title)
    return
  end
  if (not desc or desc == "") and not holder then return end
  button.MouseEnter:Connect(function()
    tipFor = button
    task.delay(0.5, function()
      if tipFor ~= button or not (N.open and button.Parent and overlay) then return end
      local say = desc
      if holder then
        local cutName, cutDesc
        for _, child in ipairs(holder:GetChildren()) do
          if child:IsA("TextLabel") and child.Text ~= "" and not child.TextFits then
            if desc and child.Text == desc then cutDesc = true else cutName = child.Text end
          end
        end
        if not (cutName or cutDesc) then return end
        say = cutName and ((desc and desc ~= "") and (cutName .. ": " .. desc) or cutName) or desc
      end
      if not say or say == "" then return end
      tip.Text = say
      local scale = N.sizer and N.sizer.Scale or 1
      local at = button.AbsolutePosition - overlay.AbsolutePosition
      tip.Position = UDim2.fromOffset(at.X + 6 * scale, at.Y + button.AbsoluteSize.Y + 4)
      tip.Visible = true
      task.defer(function()
        if tipFor ~= button or not tip.Visible then return end
        local view = overlay.AbsoluteSize
        local size = tip.AbsoluteSize
        local x, y = tip.Position.X.Offset, tip.Position.Y.Offset
        if x + size.X > view.X - 8 then x = view.X - 8 - size.X end
        if y + size.Y > view.Y - 8 then y = at.Y - size.Y - 4 end
        tip.Position = UDim2.fromOffset(math.max(x, 8), math.max(y, 8))
      end)
    end)
  end)
  button.MouseLeave:Connect(function() if tipFor == button then hideTip() end end)
end
local menu
local function closeMenu()
  if menu then
    local open = menu
    menu = nil
    open.frame:Destroy()
  end
end
-- items: { label, icon?, checked?, danger?, run } | "divider"; at = a screen point, or under `anchor`
local function openMenu(items, at, anchor)
  closeMenu()
  hideTip()
  if not overlay then return end
  local scale = N.sizer and N.sizer.Scale or 1
  local frame = box(overlay, { Name = "Menu", Size = UDim2.fromOffset(210, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 90 })
  glass(frame, 14)
  local sizer = Instance.new("UIScale"); sizer.Scale = scale; sizer.Parent = frame
  local body = box(frame, { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 91 })
  pad(body, 6)
  list(body, 2)
  for index, item in ipairs(items) do
    if item == "divider" then
      box(body, { Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = P.divider, BackgroundTransparency = 0, LayoutOrder = index, ZIndex = 92 })
    else
      local row = box(body, { Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = P.white, BackgroundTransparency = 1, LayoutOrder = index, ZIndex = 92 })
      round(row, 9)
      local x = 10
      if item.icon then
        glyph(row, item.icon, 15, item.danger and P.danger or P.dim, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0), ZIndex = 93 })
        x = 33
      end
      text(row, item.label, 13, "medium", { Position = UDim2.fromOffset(x, 0), Size = UDim2.new(1, -x - 28, 1, 0), TextColor3 = item.danger and P.danger or P.text, ZIndex = 93 })
      if item.checked then
        wear(glyph(row, "check", 14, nil, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), ZIndex = 93 }), "ImageColor3")
      end
      local button = hit(row, { ZIndex = 94 })
      button.MouseEnter:Connect(function() tween(row, HOVER_INFO, { BackgroundTransparency = 0.93 }) end)
      button.MouseLeave:Connect(function() tween(row, HOVER_INFO, { BackgroundTransparency = 1 }) end)
      button.Activated:Connect(B.safe("novoline.menu", function()
        UI.sfx("click", 0.5)
        if not item.keepOpen then closeMenu() end
        if item.run then item.run() end
      end))
    end
  end
  -- (placed once its height is known: kept on screen)
  local function place()
    local view = overlay.AbsoluteSize
    local size = frame.AbsoluteSize
    local p
    if anchor then
      local a = anchor.AbsolutePosition - overlay.AbsolutePosition
      p = Vector2.new(a.X + anchor.AbsoluteSize.X - size.X, a.Y + anchor.AbsoluteSize.Y + 4)
      if p.Y + size.Y > view.Y - 8 then p = Vector2.new(p.X, a.Y - size.Y - 4) end
    else
      p = (at or UI.mouse()) - overlay.AbsolutePosition + Vector2.new(2, 2)
    end
    frame.Position = UDim2.fromOffset(math.clamp(p.X, 8, math.max(8, view.X - size.X - 8)), math.clamp(p.Y, 8, math.max(8, view.Y - size.Y - 8)))
  end
  place()
  task.defer(place)
  menu = { frame = frame, anchor = anchor }
  UI.sfx("open", 0.4)
  return frame
end
function kit.menu(anchor, items) return openMenu(items, nil, anchor) end
N.menu = openMenu

-- ---------------------------------------------------------------- an open list, a colour: they open in place, under their row
local unfolded                           -- { frame, anchor, scroller, close }
local function fold()
  if unfolded then
    local open = unfolded
    unfolded = nil
    if open.scroller and open.scroller.Parent then open.scroller.ScrollingEnabled = true end
    if open.close then B.try("novoline.fold", open.close) end
    open.frame:Destroy()
  end
end
N.fold = fold
local function pageScroller(frame)
  for _, entry in pairs(N.pages) do
    if entry.scroller and frame:IsDescendantOf(entry.scroller) then return entry.scroller end
  end
  return nil
end
-- the frame given takes the place under `row`; the page holds still while it is open
local function unfold(row, frame, closed)
  fold()
  local scroller = pageScroller(row)
  if scroller then scroller.ScrollingEnabled = false end
  unfolded = { frame = frame, anchor = row, scroller = scroller, close = closed }
end

-- ---------------------------------------------------------------- keys on a control (right click)
local function keyMenu(id, label, kind)
  if not id then return end
  local bind = Config.bindOf(id)
  local items = {
    { label = bind and bind.key and ("Change key (" .. Config.keyLabel(bind.key) .. ")") or "Bind a key", icon = "keyboard", run = function()
      Window.toast({ title = "Press a key", text = "Esc: cancel. Backspace: clear.", icon = "keyboard", time = 2.2 })
      Controls.captureKey(function(key, cancelled)
        if cancelled then return end
        Config.bind(id, key)
        Window.toast({ title = key and ("Bound to " .. Config.keyLabel(key)) or "Key cleared", text = label, icon = "keyboard", time = 2 })
      end)
    end },
  }
  if bind and bind.key then
    if kind == "toggle" then
      items[#items + 1] = { label = "Hold to use", icon = "hand", checked = bind.mode == "hold", run = function()
        Config.bind(id, bind.key, bind.mode == "hold" and "toggle" or "hold")
      end }
    end
    items[#items + 1] = { label = "Clear the key", icon = "x", run = function() Config.bind(id, nil) end }
  end
  if Config.get(id) ~= nil and kind ~= "button" then
    items[#items + 1] = "divider"
    items[#items + 1] = { label = "Back to default", icon = "rotate-ccw", run = function() Config.reset(id) end }
  end
  openMenu(items)
end
-- the small pill that shows a control's key
local function keyChip(parent, id)
  local chip = box(parent, { Name = "Key", AnchorPoint = Vector2.new(1, 0.5), Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = P.raised,
    BackgroundTransparency = 0, Visible = false, ZIndex = 6 })
  round(chip, true)
  pad(chip, 0, 8, 0, 8)
  local label = text(chip, "", 10, "bold", { Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X, TextColor3 = P.sub, ZIndex = 7 })
  local function refresh()
    local bind = id and Config.bindOf(id)
    chip.Visible = bind ~= nil and bind.key ~= nil
    if chip.Visible then label.Text = Config.keyLabel(bind.key) .. (bind.mode == "hold" and " · hold" or "") end
  end
  if id then Config.bindsChanged:connect(function(changed) if changed == id and chip.Parent then refresh() end end) end
  refresh()
  return chip, refresh
end

-- ---------------------------------------------------------------- a card and its controls
local Section = {}
Section.__index = Section
local function nextOrder(section)
  section.count = section.count +  2
  return section.count
end
-- a row of a group: Novoline's (14 in from the left, 12 from the right, a hairline over every row
-- but the first, the whole row lit faintly under the mouse)
local function row(section, height)
  local order = nextOrder(section)
  local line = box(section.body, { Name = "Row", Size = UDim2.new(1, 0, 0, height), LayoutOrder = order, BackgroundColor3 = P.white, BackgroundTransparency = 1 })
  round(line, 12)
  pad(line, 0, 12, 0, 14)
  section.made = (section.made or 0) + 1
  if section.made > 1 then
    box(line, { Name = "Line", Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, -2, 0, 1), BackgroundColor3 = P.white, BackgroundTransparency = 0.93, ZIndex = 2 })
  end
  return line
end
local function sub(section, holder)
  return setmetatable({ body = holder, count = 0, made = 0, page = section.page, card = section.card, wide = section.wide, icon = section.icon }, Section)
end
local function findable(section, frame, label, desc)
  local page = section.page
  if not (page and page.rows) then return end
  page.rows[#page.rows + 1] = { frame = frame, card = section.card, text = lower(tostring(label or "") .. " " .. tostring(desc or "")) }
end
-- a name and its one line under it (Novoline's: bold 13 at 11, the line 11 at 30); `right` is how much
-- of the row the control takes. A row with no line under it is 40 tall and its name is centred.
-- A row's line that is too long for it ends at its first full stop, whole ("Hops round your
-- target."), not cut in the next sentence ("Hops round your target...."): the tip on hover has all
-- of it (2026-10-30). Measured in the row's own width, whatever the look's scale is just then.
local function firstSentence(under, desc)
  local first = string.match(desc, "^(.-[%.!?])%s+%S")
  if not first then return end
  local lastRoom
  local function fit()
    if not under.Parent then return end
    local scale, node = 1, under
    while node do
      local sizer = node:FindFirstChildOfClass("UIScale")
      if sizer then scale = scale *  sizer.Scale end
      node = node.Parent
    end
    if scale <= 0.01 then return end
    local room = math.floor(under.AbsoluteSize.X / scale + 0.5)
    if room <= 0 or room == lastRoom then return end
    lastRoom = room
    local ok, whole = pcall(S.TextService.GetTextSize, S.TextService, desc, 11, Enum.Font.GothamMedium, Vector2.new(4000, 100))
    -- (the look's letters set a little wider than the measure's: kept a tenth short, as in shrink)
    under.Text = (ok and whole.X > room * 0.9) and first or desc
  end
  under:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
  task.defer(fit)
end
local function labels(line, label, desc, right)
  local h = line.Size.Y.Offset
  local name = text(line, label or "", 13, "bold", { Position = UDim2.fromOffset(0, desc and 11 or 0), Size = UDim2.new(1, -(right or 60), 0, desc and 16 or h),
    TextColor3 = P.text, ZIndex = 3 })
  local under
  if desc and desc ~= "" then
    under = text(line, desc, 11, "medium", { Position = UDim2.fromOffset(0, 30), Size = UDim2.new(1, -(right or 60), 0, 14), TextColor3 = P.subtle, ZIndex = 3 })
    firstSentence(under, desc)
  end
  return name, under
end
-- the row lights up a little under the mouse (Novoline's: the row itself, to 0.96)
local function washed(line)
  return function(on) tween(line, HOVER_INFO, { BackgroundTransparency = on and 0.96 or 1 }) end
end

-- Novoline's glass switch: a clear track (white at 0.86) that fills white (0.25) when on, and a
-- white pill knob with a soft shadow that glides across (0.3 s quart out)
local function switch(parent)
  local track = box(parent, { Name = "Switch", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(52, 26),
    BackgroundColor3 = P.white, BackgroundTransparency = 0.86, ZIndex = 4 })
  round(track, true)
  local fill = box(track, { Name = "Fill", Size = UDim2.fromScale(1, 1), BackgroundColor3 = P.white, BackgroundTransparency = 1, ZIndex = 4 })
  round(fill, true)
  local knob = box(track, { Name = "Knob", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 18, 0.5, 0), Size = UDim2.fromOffset(32, 22), BackgroundColor3 = P.white,
    BackgroundTransparency = 0, ZIndex = 5 })
  round(knob, true)
  pcall(function()
    local shade = Instance.new("UIShadow")
    shade.Color, shade.BlurRadius, shade.Offset, shade.Transparency = P.black, UDim.new(0, 6), UDim2.fromOffset(0, 1), 0.62
    shade.Parent = knob
  end)
  local function set(on, animate)
    local spot = UDim2.new(0, on and 34 or 18, 0.5, 0)
    if animate then
      tween(knob, GLIDE, { Position = spot })
      tween(fill, FILL_INFO, { BackgroundTransparency = on and 0.25 or 1 })
    else
      knob.Position = spot
      fill.BackgroundTransparency = on and 0.25 or 1
    end
  end
  return track, set
end

function Section:toggle(spec)
  local id = spec.id
  local bindable = spec.bindable ~= false
  local value = id and Config.define(id, spec.default == true) or (spec.default == true)
  local desc = spec.desc
  local line = row(self, desc and ROW_H or COMPACT_H)
  findable(self, line, spec.label, desc)
  local hover = washed(line)
  local label = labels(line, spec.label, desc, 120)
  local track, set = switch(line)
  local chip = keyChip(line, id)
  chip.Position = UDim2.new(1, -60, 0.5, 0)
  local children
  if spec.children then
    local order = nextOrder(self)
    children = box(self.body, { Name = "Sub", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = order, Visible = value })
    local edge = box(children, { Size = UDim2.new(0, 2, 1, -8), Position = UDim2.fromOffset(16, 4), BackgroundColor3 = P.white, BackgroundTransparency = 0.88 })
    round(edge, true)
    local inner = box(children, { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y })
    pad(inner, 0, 0, 4, 16)
    list(inner, 0)
    B.try("novoline.children", spec.children, sub(self, inner))
  end
  local function paint(animate)
    set(value, animate)
    if children then children.Visible = value end
  end
  paint(false)
  if id then
    Config.on(id, function(next)
      value = next == true
      if line.Parent then paint(true) end
      if spec.changed then spec.changed(value) end
    end)
    if bindable then Controls.bindables[id] = Controls.bindables[id] or { label = spec.label or id, kind = "toggle", page = self.page.source } end
    -- (a tab's first switches are its quick settings)
    if self.top and self.page.toggles then self.page.toggles[#self.page.toggles + 1] = { id = id, label = spec.label or id, icon = self.icon } end
  end
  local button = hit(line, { ZIndex = 8, Size = UDim2.new(1, 26, 1, 0), Position = UDim2.fromOffset(-14, 0) })
  button.MouseEnter:Connect(function() hover(true) end)
  button.MouseLeave:Connect(function() hover(false) end)
  button.Activated:Connect(B.safe("novoline.toggle", function()
    UI.sfx(value and "toggle_off" or "toggle_on", 0.5)
    if id then Config.set(id, not value) else
      value = not value
      paint(true)
      if spec.changed then B.try("toggle", spec.changed, value) end
    end
  end))
  button.MouseButton2Click:Connect(function() if bindable and id then keyMenu(id, spec.label, "toggle") end end)
  tooltip(button, spec.tip or desc, line, spec.label)
  return { row = { frame = line, label = label }, id = id, get = function() return value end, set = function(next) if id then Config.set(id, next == true) end end,
    open = function() end, track = track }
end

function Section:slider(spec)
  local id = spec.id
  local min, max, step = spec.min or 0, spec.max or 100, spec.step or 1
  local decimals = spec.decimals or (step < 1 and math.max(0, math.ceil(-math.log10(step))) or 0)
  local curve = spec.curve or 1
  local value = id and Config.define(id, spec.default or min) or (spec.default or min)
  local desc = spec.desc
  -- Novoline's glass slider: the name and the amount on one line, a clear track (white at 0.88, 10
  -- tall) under them that fills toward its white pill thumb (30 x 18, a soft shadow; held, it grows
  -- to 36 x 20 and clears to glass)
  local line = row(self, desc and 76 or 60)
  findable(self, line, spec.label, desc)
  local hover = washed(line)
  local label = labels(line, spec.label, desc, 90)
  label.Size = UDim2.new(1, -90, 0, 16)
  label.Position = UDim2.fromOffset(0, 11)
  local amount = text(line, "", 12, "bold", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 11), Size = UDim2.fromOffset(86, 16),
    TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = P.text, ZIndex = 3 })
  local rail = box(line, { Name = "Track", AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, -12), Size = UDim2.new(1, 0, 0, 10), BackgroundColor3 = P.white,
    BackgroundTransparency = 0.88, ZIndex = 3 })
  round(rail, true)
  local fill = box(rail, { Name = "Fill", Size = UDim2.fromScale(0, 1), BackgroundColor3 = P.white, BackgroundTransparency = 0, ZIndex = 4 })
  round(fill, true)
  local sheen = Instance.new("UIGradient")
  sheen.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.78), NumberSequenceKeypoint.new(1, 0) })
  sheen.Parent = fill
  local knob = box(rail, { Name = "Thumb", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(30, 18), BackgroundColor3 = P.white,
    BackgroundTransparency = 0, ZIndex = 5 })
  round(knob, true)
  local knobRim = rim(knob, P.white, 1)
  pcall(function()
    local shade = Instance.new("UIShadow")
    shade.Color, shade.BlurRadius, shade.Offset, shade.Transparency = P.black, UDim.new(0, 8), UDim2.fromOffset(0, 2), 0.62
    shade.Parent = knob
  end)
  local HOLD = TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
  local function held(on)
    tween(knob, HOLD, { Size = on and UDim2.fromOffset(36, 20) or UDim2.fromOffset(30, 18), BackgroundTransparency = on and 0.72 or 0 })
    tween(knobRim, HOLD, { Transparency = on and 0.3 or 1 })
  end
  local function shown(v) return (spec.format and spec.format(v)) or (util.format(v, decimals) .. (spec.suffix or "")) end
  -- (the thumb stays inside the track: its centre runs from 15 px in to 15 px short of the end)
  local function place(animate)
    local f = util.clamp01((value - min) / math.max(max - min, 1e-9)) ^ (1 / curve)
    local at = UDim2.new(f, 15 - f * 30, 0.5, 0)
    local filled = UDim2.new(f, 15 - f * 30, 1, 0)
    if animate then
      tween(fill, HOVER_INFO, { Size = filled })
      tween(knob, HOVER_INFO, { Position = at })
    else
      fill.Size = filled
      knob.Position = at
    end
    amount.Text = shown(value)
  end
  place(false)
  local dragging = false
  local function set(next)
    next = math.clamp(util.round(next, step), min, max)
    if decimals > 0 then next = tonumber(string.format("%." .. decimals .. "f", next)) or next end
    if next == value then return end
    if id then Config.set(id, next) else
      value = next
      place(not dragging)
      if spec.changed then B.try("slider", spec.changed, value) end
    end
  end
  if id then
    Config.on(id, function(next)
      value = next
      if line.Parent then place(not dragging) end
      if spec.changed then spec.changed(next) end
    end)
  end
  local button = hit(line, { ZIndex = 8, Size = UDim2.new(1, 26, 1, 0), Position = UDim2.fromOffset(-14, 0) })
  button.MouseEnter:Connect(function() hover(true) end)
  button.MouseLeave:Connect(function() hover(false) end)
  local function at(point)
    local width = math.max(rail.AbsoluteSize.X - 30 * (N.sizer and N.sizer.Scale or 1), 1)
    set(min + util.clamp01((point.X - rail.AbsolutePosition.X - 15 * (N.sizer and N.sizer.Scale or 1)) / width) ^ curve * (max - min))
  end
  UI.drag(button, function(point) dragging = true; held(true); at(point) end, function(point) at(point) end, function() dragging = false; held(false) end)
  -- (right click: type a number)
  button.MouseButton2Click:Connect(function()
    local field = box(line, { Size = UDim2.new(0, 120, 0, 26), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 6), BackgroundColor3 = P.white,
      BackgroundTransparency = 0.94, ZIndex = 12 })
    round(field, 10)
    rim(field, P.white, 0.7)
    local entry = entryBox(field, 12)
    entry.Size, entry.Position, entry.ZIndex = UDim2.new(1, -16, 1, 0), UDim2.fromOffset(8, 0), 13
    entry.TextXAlignment = Enum.TextXAlignment.Center
    entry.Text, entry.ClearTextOnFocus, entry.PlaceholderText = "", true, "type a number"
    entry.FocusLost:Connect(B.safe("novoline.slider.type", function()
      local typed = tonumber((string.gsub(entry.Text, "[^%d%.%-eE]", "")))
      field:Destroy()
      if typed then set(typed) end
    end))
    entry:CaptureFocus()
  end)
  tooltip(button, spec.tip or desc, line, spec.label)
  return { row = { frame = line, label = label }, id = id, get = function() return value end, set = set }
end

-- a list that opens in place under its row: one value (dropdown) or several (multi)
local function chooser(section, spec, many)
  local id = spec.id
  local choices = options(spec.options)
  local first = choices[1] and choices[1].value
  local value
  if many then value = id and Config.define(id, spec.default or {}) or (spec.default or {})
  else value = id and Config.define(id, spec.default ~= nil and spec.default or first) or (spec.default ~= nil and spec.default or first) end
  local desc = spec.desc
  local line = row(section, desc and ROW_H or COMPACT_H)
  findable(section, line, spec.label, desc)
  local hover = washed(line)
  local label = labels(line, spec.label, desc, 140)
  -- (the value on Novoline's tile, its arrow beside it)
  local field = tile(line, { Name = "Value", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(128, 28), ZIndex = 4 }, 14)
  local fieldRim = field:FindFirstChildOfClass("UIStroke")
  local shown = text(field, "", 12, "bold", { Position = UDim2.fromOffset(12, 6), Size = UDim2.new(1, -34, 1, -12), TextColor3 = P.text, ZIndex = 5 })
  shrink(shown, 12, 9, 94)
  local arrow = glyph(field, "chevron-down", 14, P.subtle, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), ZIndex = 5 })
  local function has(v) return table.find(value, v) ~= nil end
  local function summary()
    if not many then
      for _, option in ipairs(choices) do if option.value == value then return option.label end end
      return tostring(value)
    end
    if #value == 0 then return spec.empty or "None" end
    local names = {}
    for _, option in ipairs(choices) do if has(option.value) then names[#names + 1] = option.label end end
    return table.concat(names, ", ")
  end
  shown.Text = summary()
  local function set(next)
    if id then Config.set(id, next) else
      value = next
      shown.Text = summary()
      if spec.changed then B.try("chooser", spec.changed, value) end
    end
  end
  if id then
    Config.on(id, function(next)
      value = next
      if shown.Parent then shown.Text = summary() end
      if spec.changed then spec.changed(next) end
    end)
  end
  local open = false
  local function openList()
    local rows = math.min(#choices, 7)
    local order = line.LayoutOrder + 1
    local holder = box(section.body, { Name = "List", Size = UDim2.new(1, 0, 0, 0), LayoutOrder = order, ClipsDescendants = true, ZIndex = 6 })
    local panel = box(holder, { Size = UDim2.new(1, -24, 0, rows * 30 + 8), Position = UDim2.fromOffset(12, 0), BackgroundColor3 = rgb(30, 30, 34), BackgroundTransparency = 0, ZIndex = 6 })
    round(panel, 12)
    rim(panel, P.white, 0.92)
    local scroller = Instance.new("ScrollingFrame")
    scroller.BackgroundTransparency, scroller.BorderSizePixel = 1, 0
    scroller.Position, scroller.Size = UDim2.fromOffset(4, 4), UDim2.new(1, -8, 1, -8)
    scroller.CanvasSize = UDim2.fromOffset(0, #choices * 30)
    scroller.ScrollBarThickness = #choices > rows and 3 or 0
    scroller.ScrollBarImageColor3 = P.line
    scroller.ScrollingDirection = Enum.ScrollingDirection.Y
    scroller.ZIndex = 7
    scroller.Parent = panel
    for index, option in ipairs(choices) do
      local item = box(scroller, { Position = UDim2.fromOffset(0, (index - 1) * 30), Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = P.white, BackgroundTransparency = 1, ZIndex = 8 })
      round(item, 9)
      local picked = many and has(option.value) or option.value == value
      local name = text(item, option.label, 12, picked and "bold" or "medium", { Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -40, 1, 0),
        TextColor3 = picked and P.text or P.sub, ZIndex = 9 })
      local check = glyph(item, "check", 14, nil, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), ZIndex = 9, Visible = picked })
      wear(check, "ImageColor3")
      local button = hit(item, { ZIndex = 10 })
      button.MouseEnter:Connect(function() tween(item, HOVER_INFO, { BackgroundTransparency = 0.94 }) end)
      button.MouseLeave:Connect(function() tween(item, HOVER_INFO, { BackgroundTransparency = 1 }) end)
      button.Activated:Connect(B.safe("novoline.choose", function()
        UI.sfx("click", 0.4)
        if not many then
          set(option.value)
          fold()
          return
        end
        local next = table.clone(value)
        local at = table.find(next, option.value)
        if at then table.remove(next, at) else next[#next + 1] = option.value end
        local ordered = {}
        for _, o in ipairs(choices) do if table.find(next, o.value) then ordered[#ordered + 1] = o.value end end
        set(ordered)
        local on = at == nil
        check.Visible = on
        name.TextColor3 = on and P.text or P.sub
        name.FontFace = face(on and "bold" or "medium")
      end))
    end
    -- (it opens to its height: the card grows under it)
    local tall = rows * 30 + 8 + 6
    tween(holder, OPEN_INFO, { Size = UDim2.new(1, 0, 0, tall) })
    tween(arrow, HOVER_INFO, { Rotation = 180 })
    open = true
    unfold(line, holder, function()
      open = false
      if arrow.Parent then tween(arrow, HOVER_INFO, { Rotation = 0 }) end
    end)
  end
  local button = hit(line, { ZIndex = 8, Size = UDim2.new(1, 26, 1, 0), Position = UDim2.fromOffset(-14, 0) })
  button.MouseEnter:Connect(function() hover(true); if fieldRim then tween(fieldRim, HOVER_INFO, { Transparency = 0.78 }) end end)
  button.MouseLeave:Connect(function() hover(false); if fieldRim then tween(fieldRim, HOVER_INFO, { Transparency = 0.9 }) end end)
  button.Activated:Connect(B.safe("novoline.dropdown", function()
    UI.sfx("click", 0.4)
    if open then fold() else openList() end
  end))
  tooltip(button, spec.tip or desc, line, spec.label)
  return { row = { frame = line, label = label }, id = id, get = function() return value end, set = set, has = has,
    options = function(next) choices = options(next); shown.Text = summary() end,
    show = function(next) value = next; if shown.Parent then shown.Text = summary() end end }
end
function Section:dropdown(spec) return chooser(self, spec, false) end
function Section:multi(spec) return chooser(self, spec, true) end
-- a few short choices: a pill bar with the chosen one lit (more, or long ones: a list)
-- a few short choices: Novoline's chips (soft tiles, the chosen one white with dark letters), at the
-- right of the row when they fit beside its name, else on a line of their own under it; more than
-- fit on a line: a list
function Section:segmented(spec)
  local choices = options(spec.options)
  if #choices > 5 then return chooser(self, spec, false) end
  local width = self.wide and 514 or 290
  local widths, total = {}, 0
  for i, option in ipairs(choices) do
    local ok, size = pcall(S.TextService.GetTextSize, S.TextService, option.label, 12, Enum.Font.GothamBold, Vector2.new(300, 28))
    widths[i] = (ok and size.X or #option.label * 7) + 28
    total = total +  widths[i] + (i > 1 and 6 or 0)
  end
  if total > width then return chooser(self, spec, false) end
  local id = spec.id
  local value = id and Config.define(id, spec.default ~= nil and spec.default or choices[1].value) or (spec.default ~= nil and spec.default or choices[1].value)
  local desc = spec.desc
  local inline = total <= width - 100
  local line = row(self, inline and (desc and ROW_H or COMPACT_H) or ((desc and ROW_H or 40) + 36))
  tooltip(line, spec.tip or desc, nil, spec.label)
  findable(self, line, spec.label, desc)
  local label = labels(line, spec.label, desc, inline and (total + 10) or 0)
  if not inline and not desc then label.Size = UDim2.new(1, 0, 0, 40) end
  local holder = box(line, { Name = "Chips", AnchorPoint = inline and Vector2.new(1, 0.5) or Vector2.new(0, 1), Position = inline and UDim2.new(1, 0, 0.5, 0) or UDim2.new(0, 0, 1, -8),
    Size = UDim2.fromOffset(total, 28), ZIndex = 4 })
  local chips = {}
  local x = 0
  local function paint()
    for i, option in ipairs(choices) do
      local on = option.value == value
      local c = chips[i]
      c.body.Enabled = not on
      c.plate.BackgroundColor3 = on and P.on or P.white
      c.name.TextColor3 = on and P.ink or P.text
    end
  end
  for i, option in ipairs(choices) do
    local plate, body = tile(holder, { Position = UDim2.fromOffset(x, 0), Size = UDim2.fromOffset(widths[i], 28), ZIndex = 5 }, 14)
    local name = text(plate, option.label, 12, "bold", { Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 6 })
    chips[i] = { plate = plate, body = body, name = name }
    local press = Instance.new("UIScale"); press.Parent = plate
    local button = hit(plate, { ZIndex = 7 })
    button.MouseButton1Down:Connect(function() tween(press, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 0.94 }) end)
    button.MouseButton1Up:Connect(function() tween(press, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }) end)
    button.MouseLeave:Connect(function() tween(press, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }) end)
    button.Activated:Connect(B.safe("novoline.segment", function()
      UI.sfx("tab", 0.4)
      if id then Config.set(id, option.value) else
        value = option.value
        paint()
        if spec.changed then B.try("segmented", spec.changed, value) end
      end
    end))
    x = x +  widths[i] + 6
  end
  paint()
  if id then
    Config.on(id, function(next)
      value = next
      if holder.Parent then paint() end
      if spec.changed then spec.changed(next) end
    end)
  end
  return { row = { frame = line, label = label }, id = id, get = function() return value end, set = function(next) if id then Config.set(id, next) end end,
    options = function() end, show = function(next) value = next; if holder.Parent then paint() end end }
end

-- a colour: a dot; the square and the hue strip open in place
function Section:color(spec)
  local id = spec.id
  local value = id and Config.define(id, spec.default or Color3.new(1, 1, 1)) or (spec.default or Color3.new(1, 1, 1))
  local desc = spec.desc
  local line = row(self, desc and ROW_H or COMPACT_H)
  tooltip(line, spec.tip or desc, nil, spec.label)
  findable(self, line, spec.label, desc)
  local hover = washed(line)
  local label = labels(line, spec.label, desc, 80)
  local swatch = box(line, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(44, 24), BackgroundColor3 = value,
    BackgroundTransparency = 0, ZIndex = 4 })
  round(swatch, true)
  rim(swatch, P.white, 0.75)
  local function set(next)
    if id then Config.set(id, next) else value = next; swatch.BackgroundColor3 = next; if spec.changed then spec.changed(next) end end
  end
  if id then
    Config.on(id, function(next)
      value = next
      if swatch.Parent then swatch.BackgroundColor3 = next end
      if spec.changed then spec.changed(next) end
    end)
  end
  local open = false
  local function openPicker()
    local h, s, v = value:ToHSV()
    local holder = box(self.body, { Name = "Colour", Size = UDim2.new(1, 0, 0, 0), LayoutOrder = line.LayoutOrder + 1, ClipsDescendants = true, ZIndex = 6 })
    local panel = box(holder, { Size = UDim2.new(1, 0, 0, 176), BackgroundColor3 = P.raised, BackgroundTransparency = 0, ZIndex = 6 })
    round(panel, 12)
    local square = box(panel, { Position = UDim2.fromOffset(10, 10), Size = UDim2.new(1, -20, 0, 118), BackgroundColor3 = Color3.fromHSV(h, 1, 1), BackgroundTransparency = 0, ZIndex = 7 })
    round(square, 8)
    local whiteLayer = box(square, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = P.white, BackgroundTransparency = 0, ZIndex = 8 })
    round(whiteLayer, 8)
    local across = Instance.new("UIGradient"); across.Transparency = NumberSequence.new(0, 1); across.Parent = whiteLayer
    local blackLayer = box(square, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = P.black, BackgroundTransparency = 0, ZIndex = 9 })
    round(blackLayer, 8)
    local down = Instance.new("UIGradient"); down.Rotation = 90; down.Transparency = NumberSequence.new(1, 0); down.Parent = blackLayer
    local dot = box(square, { Size = UDim2.fromOffset(12, 12), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = P.white, BackgroundTransparency = 0, ZIndex = 11 })
    round(dot, true)
    rim(dot, P.black, 0.4)
    local hueBar = box(panel, { Position = UDim2.fromOffset(10, 138), Size = UDim2.new(1, -96, 0, 12), BackgroundColor3 = P.white, BackgroundTransparency = 0, ZIndex = 7 })
    round(hueBar, true)
    local stops = {}
    for i = 0, 6 do stops[#stops + 1] = ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6 % 1, 1, 1)) end
    local rainbow = Instance.new("UIGradient"); rainbow.Color = ColorSequence.new(stops); rainbow.Parent = hueBar
    local mark = box(hueBar, { Size = UDim2.fromOffset(6, 16), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = P.white, BackgroundTransparency = 0, ZIndex = 9 })
    round(mark, true)
    local hexField = box(panel, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 133), Size = UDim2.fromOffset(78, 22), BackgroundColor3 = P.hover,
      BackgroundTransparency = 0, ZIndex = 7 })
    round(hexField, true)
    local hex = entryBox(hexField, 11)
    hex.Size, hex.Position, hex.ZIndex = UDim2.new(1, -12, 1, 0), UDim2.fromOffset(6, 0), 8
    hex.TextXAlignment = Enum.TextXAlignment.Center
    local function show()
      square.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
      dot.Position = UDim2.fromScale(s, 1 - v)
      mark.Position = UDim2.fromScale(h, 0.5)
      if not hex:IsFocused() then hex.Text = "#" .. string.upper(Color3.fromHSV(h, s, v):ToHex()) end
    end
    show()
    local function emit() show(); set(Color3.fromHSV(h, s, v)) end
    local squareHit = hit(square, { ZIndex = 12 })
    local function pickSquare(point)
      s = util.clamp01((point.X - square.AbsolutePosition.X) / square.AbsoluteSize.X)
      v = 1 - util.clamp01((point.Y - square.AbsolutePosition.Y) / square.AbsoluteSize.Y)
      emit()
    end
    UI.drag(squareHit, pickSquare, pickSquare)
    local hueHit = hit(hueBar, { ZIndex = 12, Size = UDim2.new(1, 0, 1, 10), Position = UDim2.fromOffset(0, -5) })
    local function pickHue(point) h = util.clamp01((point.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X); emit() end
    UI.drag(hueHit, pickHue, pickHue)
    hex.FocusLost:Connect(function()
      local ok, color = pcall(Color3.fromHex, (string.gsub(hex.Text, "[^%x]", "")))
      if ok and color then h, s, v = color:ToHSV(); emit() else show() end
    end)
    tween(holder, OPEN_INFO, { Size = UDim2.new(1, 0, 0, 182) })
    open = true
    unfold(line, holder, function() open = false end)
  end
  local button = hit(line, { ZIndex = 8, Size = UDim2.new(1, 26, 1, 0), Position = UDim2.fromOffset(-14, 0) })
  button.MouseEnter:Connect(function() hover(true) end)
  button.MouseLeave:Connect(function() hover(false) end)
  button.Activated:Connect(B.safe("novoline.color", function()
    UI.sfx("click", 0.4)
    if open then fold() else openPicker() end
  end))
  return { row = { frame = line, label = label }, id = id, get = function() return value end, set = set }
end

function Section:keybind(spec)
  local id = spec.id
  local value = id and Config.define(id, spec.default or "None") or (spec.default or "None")
  local desc = spec.desc
  local line = row(self, desc and ROW_H or COMPACT_H)
  findable(self, line, spec.label, desc)
  local hover = washed(line)
  -- (Novoline's key: the name on a 92 x 28 tile; while it listens, the tile goes white with dark letters)
  local label = labels(line, spec.label, desc, 104)
  local chip, chipBody = tile(line, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(92, 28), ZIndex = 4 }, 14)
  local key = text(chip, "", 12, "bold", { Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = P.text, ZIndex = 5 })
  local function listening(on)
    chipBody.Enabled = not on
    chip.BackgroundColor3 = on and P.on or P.white
    key.TextColor3 = on and P.ink or P.text
  end
  local function show() key.Text = Config.keyLabel(value ~= "None" and value or nil) end
  show()
  if id then
    Config.on(id, function(next)
      value = next
      if key.Parent then show() end
      if spec.changed then spec.changed(next) end
    end)
  end
  local button = hit(line, { ZIndex = 8, Size = UDim2.new(1, 26, 1, 0), Position = UDim2.fromOffset(-14, 0) })
  button.MouseEnter:Connect(function() hover(true) end)
  button.MouseLeave:Connect(function() hover(false) end)
  button.Activated:Connect(B.safe("novoline.key", function()
    key.Text = "Press a key"
    listening(true)
    Controls.captureKey(function(pressed, cancelled)
      listening(false)
      if not cancelled then
        local next = pressed or "None"
        if id then Config.set(id, next) else value = next; if spec.changed then spec.changed(next) end end
      end
      show()
    end)
  end))
  tooltip(button, spec.tip or desc, line, spec.label)
  return { row = { frame = line, label = label }, id = id, get = function() return value end }
end

-- a pill button the width of the card
local function pillButton(parent, value, style, props)
  local holder = box(parent, props)
  holder.ZIndex = 3
  local face0, lift
  if style == "accent" then
    face0 = box(holder, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = accent(), BackgroundTransparency = 0, ZIndex = 4 })
    round(face0, 16)
    wear(face0, "BackgroundColor3")
  else
    face0, lift = N.softFace(holder, 16)
  end
  local label = text(face0, value, 13, "bold", { Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 6,
    TextColor3 = style == "danger" and P.danger or P.text })
  local button = hit(face0, { ZIndex = 8 })
  button.MouseEnter:Connect(function()
    if lift then tween(lift, HOVER_INFO, { BackgroundTransparency = 0.95 }) else tween(face0, HOVER_INFO, { BackgroundTransparency = 0.15 }) end
  end)
  button.MouseLeave:Connect(function()
    if lift then tween(lift, HOVER_INFO, { BackgroundTransparency = 1 }) else tween(face0, HOVER_INFO, { BackgroundTransparency = 0 }) end
  end)
  button.MouseButton1Down:Connect(function() tween(face0, HOVER_INFO, { Size = UDim2.new(1, -6, 1, -4), Position = UDim2.fromOffset(3, 2) }) end)
  button.MouseButton1Up:Connect(function() tween(face0, SWITCH_INFO, { Size = UDim2.fromScale(1, 1), Position = UDim2.new() }) end)
  button.MouseLeave:Connect(function() tween(face0, SWITCH_INFO, { Size = UDim2.fromScale(1, 1), Position = UDim2.new() }) end)
  return holder, button, label, face0
end
N.pillButton = pillButton
-- an action: Novoline's (its name at the left, a 92 x 28 tile at the right saying what it does)
function Section:button(spec)
  local id = spec.id
  local desc = spec.desc
  local line = row(self, (desc and desc ~= "") and ROW_H or COMPACT_H)
  findable(self, line, spec.label or spec.text, desc)
  local hover = washed(line)
  local name = labels(line, spec.label or spec.text or "", (desc and desc ~= "") and desc or nil, 104)
  local accentStyle = spec.style == "accent"
  local plate, plateBody = tile(line, { Name = "Action", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(92, 28), ZIndex = 4 }, 14)
  if accentStyle then plateBody.Enabled = false; plate.BackgroundColor3 = P.on end
  local said = text(plate, spec.text or (spec.label and "Run") or "Run", 12, "bold", { Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 5,
    TextColor3 = accentStyle and P.ink or (spec.style == "danger" and P.danger or P.text) })
  local press = Instance.new("UIScale"); press.Parent = plate
  local chip = keyChip(line, id)
  chip.Position = UDim2.new(1, -100, 0.5, 0)
  if id then
    Config.action(id, function() if spec.run then spec.run() end end)
    if spec.bindable ~= false then Controls.bindables[id] = Controls.bindables[id] or { label = spec.label or id, kind = "button", page = self.page.source } end
  end
  local button = hit(line, { ZIndex = 8, Size = UDim2.new(1, 26, 1, 0), Position = UDim2.fromOffset(-14, 0) })
  button.MouseEnter:Connect(function() hover(true) end)
  button.MouseLeave:Connect(function() hover(false); tween(press, SWITCH_INFO, { Scale = 1 }) end)
  button.MouseButton1Down:Connect(function() tween(press, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 0.94 }) end)
  button.MouseButton1Up:Connect(function() tween(press, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }) end)
  button.Activated:Connect(B.safe("novoline.button", function()
    UI.sfx("click", 0.6)
    if spec.run then B.try("button." .. (spec.label or "?"), spec.run) end
  end))
  button.MouseButton2Click:Connect(function() if id and spec.bindable ~= false then keyMenu(id, spec.label, "button") end end)
  tooltip(button, spec.tip or desc, line, spec.label)
  -- (a new word: on the tile when the action has one of its own, else in place of its name)
  return { row = { frame = line, label = name }, button = plate, setText = function(value) if spec.text then said.Text = value else name.Text = value end end }
end

function Section:input(spec)
  local id = spec.id
  local value = id and Config.define(id, spec.default or "") or (spec.default or "")
  -- (Novoline's field: its name and line over a box of faint white, 30 tall, its rim brighter while typing)
  local desc = spec.desc
  local line = row(self, (desc and desc ~= "") and 92 or 72)
  tooltip(line, spec.tip or desc, nil, spec.label)
  findable(self, line, spec.label, desc)
  local label = labels(line, spec.label or "", (desc and desc ~= "") and desc or nil, 0)
  label.Position, label.Size = UDim2.fromOffset(0, 11), UDim2.new(1, 0, 0, 16)
  local field = box(line, { Position = UDim2.fromOffset(0, (desc and desc ~= "") and 50 or 34), Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = P.white,
    BackgroundTransparency = 0.94, ZIndex = 4 })
  round(field, 10)
  local stroke = rim(field, P.white, 0.92)
  local entry = entryBox(field, 13)
  entry.Position, entry.Size, entry.ZIndex = UDim2.fromOffset(12, 0), UDim2.new(1, -24, 1, 0), 5
  entry.Text, entry.PlaceholderText = tostring(value), spec.placeholder or ""
  entry.Focused:Connect(function() tween(stroke, HOVER_INFO, { Transparency = 0.7 }) end)
  entry.FocusLost:Connect(B.safe("novoline.input", function()
    tween(stroke, HOVER_INFO, { Transparency = 0.92 })
    local typed = entry.Text
    if spec.numeric then
      local number = tonumber(typed)
      if not number then entry.Text = tostring(value); return end
      typed = number
    end
    if id then Config.set(id, typed) else
      value = typed
      if spec.changed then B.try("input", spec.changed, typed) end
    end
  end))
  if id then
    Config.on(id, function(next)
      value = next
      if entry.Parent and not entry:IsFocused() then entry.Text = tostring(next) end
      if spec.changed then spec.changed(next) end
    end)
  end
  return { row = { frame = line }, id = id, box = entry, get = function() return value end }
end

function Section:note(spec)
  local order = nextOrder(self)
  -- (Novoline's foot line: medium 11 in its quiet grey, inside the group)
  local holder = box(self.body, { Name = "Note", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = order })
  pad(holder, 9, 14, 9, spec.icon and 36 or 14)
  if spec.icon then glyph(holder, spec.icon, 14, P.subtle, { Position = UDim2.fromOffset(-22, 0) }) end
  local label = text(holder, spec.text or "", 11, "medium", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true,
    TextTruncate = Enum.TextTruncate.None, TextColor3 = P.subtle, RichText = spec.rich == true })
  return { frame = holder, set = function(value) label.Text = value end }
end
-- A view a tab draws itself. One drawn wider than the card (the keyboard on Keys is 716 across) is
-- shrunk to fit: its pieces go into a frame of their own width, scaled down as one.
local function fitWide(frame, room)
  local widest = 0
  for _, child in ipairs(frame:GetChildren()) do
    if child:IsA("GuiObject") and child.Size.X.Scale == 0 then widest = math.max(widest, child.Size.X.Offset) end
  end
  if widest <= room then return end
  local k = room / widest
  local tall = frame.Size.Y.Offset
  local inner = box(frame, { Name = "Fit", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.fromOffset(widest, tall) })
  for _, child in ipairs(frame:GetChildren()) do
    if child ~= inner and child:IsA("GuiObject") then child.Parent = inner end
  end
  local scale = Instance.new("UIScale"); scale.Scale = k; scale.Parent = inner
  if tall > 0 then frame.Size = UDim2.new(1, 0, 0, math.ceil(tall * k)) end
end
function Section:custom(spec)
  local frame = box(self.body, { Name = spec.name or "Custom", Size = UDim2.new(1, 0, 0, spec.height or 100), LayoutOrder = nextOrder(self) })
  if spec.height == nil then frame.AutomaticSize = Enum.AutomaticSize.Y end
  B.try("novoline.custom", spec.build, frame)
  -- (in a deck whose Options card is the narrow one, the Music deck's, a view is fitted to that)
  local room = (self.page and self.page.narrow) and 300 or (self.wide and 540 or 316)
  if spec.height then B.try("novoline.fit", fitWide, frame, room) end
  return frame
end
-- for a tab's own version of itself (the Unnamed ones work here too): a line, two buttons, a box
function Section:label(value)
  local line = row(self, 22)
  local label = text(line, value or "", 12, "medium", { Size = UDim2.fromScale(1, 1), TextColor3 = P.sub })
  return { frame = line, set = function(next) label.Text = next end }
end
function Section:pair(a, b)
  local line = row(self, 38)
  local out = {}
  for index, item in ipairs({ a, b }) do
    if item then
      local holder, button, label = pillButton(line, item[1], nil, { Size = UDim2.new(b and 0.5 or 1, b and -4 or 0, 0, 30), Position = UDim2.new((index - 1) * 0.5, index == 2 and 4 or 0, 0, 4) })
      button.Activated:Connect(B.safe("novoline.pair", function() UI.sfx("click", 0.5); if item[2] then item[2]() end end))
      out[index] = { field = holder, label = label }
    end
  end
  return out
end
function Section:field(placeholder, changed)
  local line = row(self, 38)
  local field = box(line, { Position = UDim2.fromOffset(0, 4), Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = P.raised, BackgroundTransparency = 0, ZIndex = 4 })
  round(field, 10)
  glyph(field, "search", 14, P.faint, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0), ZIndex = 5 })
  local entry = entryBox(field, 13)
  entry.Position, entry.Size, entry.ZIndex = UDim2.fromOffset(30, 0), UDim2.new(1, -40, 1, 0), 5
  entry.Text, entry.PlaceholderText = "", placeholder or ""
  if changed then entry:GetPropertyChangedSignal("Text"):Connect(function() changed(entry.Text) end) end
  return entry
end
N.Section = Section

-- ---------------------------------------------------------------- a tab: its sections, as Novoline's groups
-- A section is one of Novoline's settings groups: a plate of faint white (0.955, 14 round) with
-- hairlines between its rows. The tab's deck shows one section at a time in its Options card (the
-- Sections card beside it picks which); a search shows every section with something that matches,
-- each under its name.
local TextService = S.TextService
local Page = {}
Page.__index = Page
local function card(page, spec)
  page.sections = page.sections +  1
  local frame = box(page.content, { Name = spec.title or "Section", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = page.sections,
    Visible = false, ZIndex = 21 })
  list(frame, 0)
  local head = box(frame, { Name = "Group", Size = UDim2.new(1, 0, 0, 24), LayoutOrder = 0, Visible = false, ZIndex = 21 })
  text(head, spec.title or page.source.title or "", 12, "bold", { Position = UDim2.fromOffset(6, 0), Size = UDim2.new(1, -12, 0, 16), TextColor3 = P.subtle, ZIndex = 22 })
  local body = box(frame, { Name = "Body", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = P.white, BackgroundTransparency = 0.955,
    LayoutOrder = 1, ZIndex = 21 })
  round(body, 14)
  list(body, 0)
  local wide = spec.full == true
  local section = setmetatable({ body = body, count = 0, made = 0, page = page, card = frame, wide = wide, icon = spec.icon or page.source.icon, top = true }, Section)
  page.list[#page.list + 1] = { title = spec.title or page.source.title or page.source.id, icon = spec.icon or page.source.icon or "circle", desc = spec.desc,
    frame = frame, head = head, wide = wide, section = section, stage = spec.stage == true }
  page.cards[#page.cards + 1] = { frame = frame, title = lower(spec.title) }
  return section
end
function Page:section(spec) return card(self, spec or {}) end
function Page:custom(height, build, alt)
  local section = card(self, { full = true })
  if alt then
    B.try("novoline.alt", alt, section)
    return section.body
  end
  local frame = box(section.body, { Name = "Custom", Size = UDim2.new(1, 0, 0, height or 0), LayoutOrder = nextOrder(section) })
  if not height then frame.AutomaticSize = Enum.AutomaticSize.Y end
  B.try("novoline.custom", build, frame)
  return frame
end
function Page:empty(icon, title, value)
  local section = card(self, {})
  local holder = box(section.body, { Size = UDim2.new(1, 0, 0, 160), LayoutOrder = nextOrder(section) })
  glyph(holder, icon or "package", 30, P.faint, { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 26), ZIndex = 22 })
  text(holder, title or "Nothing here yet", 16, "bold", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 70), Size = UDim2.new(1, 0, 0, 22),
    TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 22 })
  text(holder, value or "", 12, "medium", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 96), Size = UDim2.new(1, -40, 0, 32),
    TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = P.subtle, TextWrapped = true, ZIndex = 22 })
end

-- ---------------------------------------------------------------- the tabs
local function tabsWanted()
  local out = {}
  for _, page in ipairs(Window.order) do
    if not page.hidden and page.build then out[#out + 1] = page end
  end
  return out
end
-- which rows a search keeps: { found anything, which groups show }. The hairline over the first row
-- still showing in each group goes, so a group never starts with a line.
local function filter(entry, query)
  local any, keep = false, {}
  for _, item in ipairs(entry.rows) do
    if item.frame.Parent then
      local found = query == "" or string.find(item.text, query, 1, true) ~= nil
      if found then
        if item.hidden then item.frame.Visible = true; item.hidden = nil end
        keep[item.card] = true
        any = true
      elseif item.frame.Visible then
        item.frame.Visible = false
        item.hidden = true
      end
    end
  end
  local shown = {}
  for _, c in ipairs(entry.cards) do
    local named = query ~= "" and c.title ~= "" and string.find(c.title, query, 1, true) ~= nil
    if named and not keep[c.frame] then
      for _, item in ipairs(entry.rows) do
        if item.card == c.frame and item.hidden then item.frame.Visible = true; item.hidden = nil end
      end
      any = true
    end
    shown[c.frame] = query == "" or keep[c.frame] == true or named
  end
  for _, c in ipairs(entry.cards) do
    local body = c.frame:FindFirstChild("Body")
    if body then
      local rows = {}
      for _, child in ipairs(body:GetChildren()) do
        if child:IsA("GuiObject") and child.Name == "Row" then rows[#rows + 1] = child end
      end
      table.sort(rows, function(a, b) return a.LayoutOrder < b.LayoutOrder end)
      local first = true
      for _, r in ipairs(rows) do
        if r.Visible then
          local line = r:FindFirstChild("Line")
          if line then line.Visible = not first end
          first = false
        end
      end
    end
  end
  return any, shown
end

-- ---------------------------------------------------------------- the dock (Novoline's: 52 tall, 40 px items, a capsule behind the chosen one)
local DOCK = { pad = 6, h = 40, w = 40, gap = 2 }
local ICON_OFF, ICON_HOVER, ICON_ON = rgb(150, 150, 156), rgb(235, 235, 238), rgb(242, 242, 244)
local QUICK = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local SLIDE = TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
function N.paintNav(instant)
  if not N.bar then return end
  local x, selX, selW = DOCK.pad, nil, nil
  for _, tab in ipairs(N.tabs) do
    local selected = tab.id == N.current and N.open
    local w = selected and tab.wide or DOCK.w
    local goal = { Size = UDim2.fromOffset(w, DOCK.h), Position = UDim2.fromOffset(x, DOCK.pad) }
    if instant then tab.button.Size, tab.button.Position = goal.Size, goal.Position else tween(tab.button, SLIDE, goal) end
    if selected then selX, selW = x, w end
    tab.select(selected, instant)
    x = x +  w + DOCK.gap
  end
  local barSize = UDim2.fromOffset(x - DOCK.gap + DOCK.pad, DOCK_H)
  if instant then N.bar.Size = barSize else tween(N.bar, SLIDE, { Size = barSize }) end
  local capsule = N.capsule
  if selX then
    local goal = { Position = UDim2.fromOffset(selX, DOCK.pad), Size = UDim2.fromOffset(selW, DOCK.h), BackgroundTransparency = 0 }
    if instant or capsule.BackgroundTransparency > 0.99 then
      capsule.Position, capsule.Size = goal.Position, UDim2.fromOffset(DOCK.w, DOCK.h)
      if instant then capsule.Size, capsule.BackgroundTransparency, N.capsuleRim.Transparency = goal.Size, 0, 0; return end
    end
    tween(capsule, SLIDE, goal)
    tween(N.capsuleRim, SLIDE, { Transparency = 0 })
  else
    tween(capsule, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 })
    tween(N.capsuleRim, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 1 })
  end
end
function N.rebuildTabs()
  if not N.built then return end
  for _, tab in ipairs(N.tabs) do tab.button:Destroy() end
  table.clear(N.tabs)
  local x = DOCK.pad
  for _, page in ipairs(tabsWanted()) do
    local label = page.title or page.id
    local ok, size = pcall(TextService.GetTextSize, TextService, label, 12, Enum.Font.GothamBold, Vector2.new(300, 20))
    local textW = ok and size.X or #label * 7
    local item = Instance.new("TextButton")
    item.Name, item.Text, item.AutoButtonColor = page.id, "", false
    item.Position, item.Size = UDim2.fromOffset(x, DOCK.pad), UDim2.fromOffset(DOCK.w, DOCK.h)
    item.BackgroundColor3, item.BackgroundTransparency, item.BorderSizePixel = P.white, 1, 0
    item.ZIndex, item.ClipsDescendants = 53, true
    item.Parent = N.bar
    round(item, true)
    local press = Instance.new("UIScale"); press.Parent = item
    local img = glyph(item, page.icon or "circle", 20, ICON_OFF, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(DOCK.w / 2, DOCK.h / 2), ZIndex = 54 })
    local name = text(item, label, 12, "bold", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 36, 0.5, 0), Size = UDim2.fromOffset(textW + 4, 16),
      TextColor3 = ICON_ON, TextTransparency = 1, TextTruncate = Enum.TextTruncate.None, ZIndex = 54 })
    local selected, hovered = false, false
    local function paint(instant)
      local over = hovered and not selected
      local goals = {
        { item, QUICK, { BackgroundTransparency = over and 0.92 or 1 } },
        { img, QUICK, { ImageColor3 = selected and ICON_ON or (over and ICON_HOVER or ICON_OFF) } },
        { img, SLIDE, { Position = UDim2.fromOffset(selected and 24 or DOCK.w / 2, DOCK.h / 2) } },
        { name, TweenInfo.new(selected and 0.3 or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, selected and 0.08 or 0), { TextTransparency = selected and 0 or 1 } },
      }
      for _, g in ipairs(goals) do
        if instant then for key, value in pairs(g[3]) do g[1][key] = value end else tween(g[1], g[2], g[3]) end
      end
    end
    item.MouseEnter:Connect(function()
      hovered = true
      paint()
      if not selected then N.showLabel(item, label) end
    end)
    item.MouseLeave:Connect(function() hovered = false; paint(); N.showLabel(nil) end)
    item.MouseButton1Down:Connect(function() tween(press, QUICK, { Scale = 0.94 }) end)
    item.MouseButton1Up:Connect(function() tween(press, SWITCH_INFO, { Scale = 1 }) end)
    item.MouseLeave:Connect(function() tween(press, SWITCH_INFO, { Scale = 1 }) end)
    item.Activated:Connect(B.safe("novoline.tab", function()
      if os.clock() - (N.tabAt or 0) < 0.25 then return end
      N.tabAt = os.clock()
      N.showLabel(nil)
      if N.open and N.current == page.id then N.show(false)
      elseif not N.open then N.current = page.id; N.show(true)
      else N.go(page.id) end
    end))
    N.tabs[#N.tabs + 1] = { id = page.id, button = item, wide = 14 + 20 + 6 + textW + 16, select = function(on, instant) selected = on; paint(instant) end }
    paint(true)
    x = x +  DOCK.w + DOCK.gap
  end
  if not (N.current and Window.pages[N.current]) then
    -- (Novoline opens on its Home deck, the way Novoline does: a game's own tab, the ragebot,
    -- is a click away on the dock, never what the hub opens on)
    local wanted = tabsWanted()
    N.current = (Window.pages.home and "home") or (Window.startPage and Window.pages[Window.startPage] and Window.startPage) or (wanted[1] and wanted[1].id) or nil
  end
  N.paintNav(true)
end

-- ---------------------------------------------------------------- where the cards sit, and how they come and go
-- Novoline's scale: never past 1, and the whole layout (1280 x 712 design px) always on screen;
-- then the hub's own size settings.
local FULL_W, FULL_H = 1280, 712
local MARGIN, TOP, BOTTOM = 40, 34, 90
local function scaleNow()
  local camera = workspace.CurrentCamera
  local view = camera and camera.ViewportSize or Vector2.new(1280, 720)
  local fit = math.min(1, view.X / FULL_W, view.Y / FULL_H)
  return math.max(0.45, fit) * ((Config.get("app.scale") or 100) / 100) * ((Config.get("app.novoline.size") or 100) / 100)
end
N.scaleNow = scaleNow
local function screen()
  return N.gui.AbsoluteSize
end
-- the dock's bottom centre (dragged there, or Novoline's spot)
local function seat()
  if not N.bar then return end
  local x, y = Config.get("app.novoline.x"), Config.get("app.novoline.y")
  if type(x) == "number" and x >= 0 then N.bar.Position = UDim2.fromScale(x, y) else N.bar.Position = UDim2.new(0.5, 0, 1, -24) end
end
local function dockCentre()
  local bar = N.bar
  local at = bar.AbsolutePosition - N.gui.AbsolutePosition
  if not bar.Visible or bar.AbsoluteSize.X < 1 then
    local view = screen()
    return Vector2.new(view.X / 2, view.Y - 24 - DOCK_H / 2)
  end
  return at + bar.AbsoluteSize / 2
end
-- where a card rests: its corner, and how far in from it (design px); its centre and size in pixels
local function cardRest(item)
  local s = N.sizer.Scale
  local view = screen()
  local w, h = item.w * s, item.h * s
  local left = item.corner == "tl" or item.corner == "bl"
  local top = item.corner == "tl" or item.corner == "tr"
  local x = left and (MARGIN + item.x) * s + w / 2 or view.X - (MARGIN + item.x) * s - w / 2
  -- (the top row starts under Roblox's own buttons, which sit in the first 58 pixels)
  local topStart = math.max(TOP * s, UI.inset().Y + 14)
  local y = top and topStart + item.y * s + h / 2 or view.Y - (BOTTOM + item.y) * s - h / 2
  return Vector2.new(x, y), Vector2.new(w, h)
end
-- a card: dark glass whose body fades as one and never reflows while the card's frame grows round it
local function floating(name, w, h, radius, bare)
  local frame = box(N.gui, { Name = name, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(w, h), Visible = false, ZIndex = 20, ClipsDescendants = true })
  if not bare then glass(frame, radius or 28) end
  local scale = Instance.new("UIScale"); scale.Parent = frame
  local body = Instance.new("CanvasGroup")
  body.Name = "Body"
  body.BackgroundTransparency, body.BorderSizePixel = 1, 0
  body.AnchorPoint, body.Position, body.Size = Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(w, h)
  body.ZIndex = 21
  body.Parent = frame
  return { frame = frame, body = body, scale = scale, w = w, h = h, bare = bare == true }
end
local function settle(item)
  local centre = cardRest(item)
  item.frame.Position = UDim2.fromOffset(centre.X, centre.Y)
  item.frame.Size = UDim2.fromOffset(item.w, item.h)
end
-- out of the dock: from a 120 x 44 pill where the dock is, to its place (0.56 s quint out)
local function rise(item, delay)
  local frame, body = item.frame, item.body
  item.sinking = false
  frame.Visible = true
  local centre = cardRest(item)
  if Motion.reduced then settle(item); body.GroupTransparency = 0; return end
  local dock = dockCentre()
  frame.Position = UDim2.fromOffset(dock.X, dock.Y)
  frame.Size = UDim2.fromOffset(120, 44)
  body.GroupTransparency = 1
  tween(frame, TweenInfo.new(0.56, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, delay or 0), { Position = UDim2.fromOffset(centre.X, centre.Y), Size = UDim2.fromOffset(item.w, item.h) })
  tween(body, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, delay or 0), { GroupTransparency = 0 })
end
-- a title has no glass: it comes up a little and fades in
local function lift(item, delay, from)
  local frame, body = item.frame, item.body
  item.sinking = false
  frame.Visible = true
  local centre = cardRest(item)
  frame.Size = UDim2.fromOffset(item.w, item.h)
  if Motion.reduced then frame.Position = UDim2.fromOffset(centre.X, centre.Y); body.GroupTransparency = 0; return end
  frame.Position = UDim2.fromOffset(centre.X, centre.Y + (from or 14) * N.sizer.Scale)
  body.GroupTransparency = 1
  tween(frame, TweenInfo.new(0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, delay or 0), { Position = UDim2.fromOffset(centre.X, centre.Y) })
  tween(body, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, delay or 0), { GroupTransparency = 0 })
end
-- from where another card is (a tab change: the card in the same corner turns into this one)
local function morph(item, fromPosition, fromSize, delay)
  local frame, body = item.frame, item.body
  item.sinking = false
  frame.Visible = true
  local centre = cardRest(item)
  if Motion.reduced then settle(item); body.GroupTransparency = 0; return end
  frame.Position, frame.Size = fromPosition, fromSize
  body.GroupTransparency = 1
  tween(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, delay or 0), { Position = UDim2.fromOffset(centre.X, centre.Y), Size = UDim2.fromOffset(item.w, item.h) })
  tween(body, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, delay or 0), { GroupTransparency = 0 })
end
local function fadeAway(item)
  if not item.frame.Visible then return end
  item.sinking = true
  tween(item.body, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { GroupTransparency = 1 })
  task.delay(0.16, function() if item.sinking then item.frame.Visible = false end end)
end
-- back into the dock (0.28 s quint in, most of the way, and gone)
local function sink(item, delay)
  local frame, body = item.frame, item.body
  if not frame.Visible then return end
  item.sinking = true
  if Motion.reduced then frame.Visible = false; return end
  if item.bare then
    tween(frame, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Position = frame.Position + UDim2.fromOffset(0, 10) })
    tween(body, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { GroupTransparency = 1 })
  else
    local dock = dockCentre()
    local at = Vector2.new(frame.Position.X.Offset, frame.Position.Y.Offset)
    local goal = at:Lerp(dock, 0.45)
    tween(frame, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In, 0, false, delay or 0),
      { Position = UDim2.fromOffset(goal.X, goal.Y), Size = UDim2.fromOffset(frame.Size.X.Offset * 0.6, frame.Size.Y.Offset * 0.6) })
    tween(body, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, (delay or 0) + 0.15), { GroupTransparency = 1 })
  end
  task.delay((delay or 0) + 0.34, function() if item.sinking then frame.Visible = false end end)
end
local labelTip
function N.showLabel(anchor, value)
  if not labelTip then return end
  if not anchor then labelTip.Visible = false; return end
  labelTip.Text = value
  local at = anchor.AbsolutePosition - overlay.AbsolutePosition
  labelTip.Position = UDim2.fromOffset(at.X + anchor.AbsoluteSize.X / 2, at.Y - 10)
  labelTip.Visible = true
end
-- a soft button on a card (Novoline's: the dark plate, its rim lit at the top, a lift under the mouse,
-- pressed to 95%); `tint` makes it a coloured tile instead
local function soft(parent, x, y, w, h, radius, tint, run)
  local holder = box(parent, { Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h), ZIndex = 22 })
  local plate, liftFrame
  if tint then
    plate = box(holder, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = tint, BackgroundTransparency = 0, ZIndex = 23 })
    round(plate, radius)
    local line = rim(plate, P.white, 0)
    pcall(function() line.BorderStrokePosition = Enum.BorderStrokePosition.Inner end)
    local light = Instance.new("UIGradient"); light.Rotation = 90
    light.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.86), NumberSequenceKeypoint.new(0.4, 0.96), NumberSequenceKeypoint.new(1, 0.97) })
    light.Parent = line
    liftFrame = box(plate, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = P.white, BackgroundTransparency = 1, ZIndex = 24 })
    round(liftFrame, radius)
  else
    plate, liftFrame = N.softFace(holder, radius)
  end
  local press = Instance.new("UIScale"); press.Parent = holder
  local button = hit(holder, { ZIndex = 30 })
  button.MouseEnter:Connect(function() tween(liftFrame, TweenInfo.new(0.18), { BackgroundTransparency = 0.95 }) end)
  button.MouseLeave:Connect(function() tween(liftFrame, TweenInfo.new(0.18), { BackgroundTransparency = 1 }); tween(press, SWITCH_INFO, { Scale = 1 }) end)
  button.MouseButton1Down:Connect(function() tween(press, QUICK, { Scale = 0.95 }) end)
  button.MouseButton1Up:Connect(function() tween(press, SWITCH_INFO, { Scale = 1 }) end)
  if run then button.Activated:Connect(B.safe("novoline.soft", function() UI.sfx("click", 0.5); run() end)) end
  return holder, plate, button
end
-- a card's own name (Novoline's: bold 14 at 18, 16) and its icon at the right
local function header(item, title, icon)
  text(item.body, title, 14, "bold", { Position = UDim2.fromOffset(18, 16), Size = UDim2.fromOffset(item.w - 70, 18), ZIndex = 22 })
  if icon then glyph(item.body, icon, 16, P.subtle, { Position = UDim2.fromOffset(item.w - 34, 17), ZIndex = 22 }) end
end
local function headshot(parent, x, y, size)
  local image = Instance.new("ImageLabel")
  image.BackgroundColor3, image.BorderSizePixel = rgb(40, 40, 44), 0
  image.Size, image.Position = UDim2.fromOffset(size, size), UDim2.fromOffset(x, y)
  image.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(S.Players.LocalPlayer.UserId) .. "&w=150&h=150"
  image.ZIndex = 22
  image.Parent = parent
  round(image, true)
  return image
end
-- the looks, Settings and Unload, under the account card
local function looksMenu(anchor)
  openMenu({
    { label = "BASED look", icon = "sparkles", run = function() Config.set("app.gui", "based") end },
    { label = "Unnamed look", icon = "app-window", run = function() Config.set("app.gui", "unnamed") end },
    { label = "Novoline look", icon = "layout-grid", checked = true, run = function() end },
    "divider",
    { label = "Settings", icon = "settings", run = function() N.go("settings") end },
    { label = "Keys", icon = "keyboard", run = function() N.go("keys") end },
    { label = "Close", icon = "x", run = function() N.show(false) end },
    { label = "Close menu", icon = "power", danger = true, run = function() N.show(false) end },
  }, nil, anchor)
end

-- ---------------------------------------------------------------- a tab's deck: Novoline's settings deck
-- tl  the tab's name (black 30) and its line (medium 13)
-- tr  a search pill (260 x 44) and your account beside it (200 x 44)
-- bl  the Sections card (210 x 360) beside the Options card (296 x 360) that holds the chosen section;
--     a wide section (a view of its own, the keyboard, the music) widens Options to 520. A tab of one
--     section has no Sections card: Options is a 520 stage from the corner.
-- br  Quick settings (330 x 173: the tab's first three switches as tinted tiles) over Shortcuts
--     (330 x 173: the keys on this tab)
-- (Options is 340 across, not Novoline's 296: the hub's settings have longer names and lines)
local SECTIONS_W, OPTIONS_W, STAGE_W, CARD_H, SIDE_W = 210, 340, 564, 360, 330
local decks = {}
N.decks = decks
local pick
local function addCard(d, name, corner, x, y, w, h, bare)
  local item = floating(name, w, h, h <= 60 and math.floor(h / 2) or 28, bare)
  item.corner, item.x, item.y = corner, x, y
  item.scale.Scale = N.sizer.Scale
  d.cards[#d.cards + 1] = item
  return item
end
-- the Options card at the width the chosen section wants
local function shape(d, wide, instant)
  if d.fixed then return end
  local item = d.options
  local w = (d.single or wide) and STAGE_W or OPTIONS_W
  if item.w == w then return end
  item.w = w
  item.body.Size = UDim2.fromOffset(w, item.h)
  d.heroTile.Position = UDim2.fromOffset(w - 16 - 36, 14)
  d.heroTitle.Size, d.heroDesc.Size = UDim2.fromOffset(w - 18 - 60, 20), UDim2.fromOffset(w - 18 - 60, 28)
  if not item.frame.Visible or instant or Motion.reduced then
    if item.frame.Visible then settle(item) end
    return
  end
  local centre = cardRest(item)
  tween(item.frame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.fromOffset(centre.X, centre.Y), Size = UDim2.fromOffset(w, item.h) })
end
local function rowsIn(entry, frame)
  local n = 0
  for _, item in ipairs(entry.rows) do if item.card == frame then n = n +  1 end end
  return n
end
local function tabDeck(source)
  local d = decks[source.id]
  if d then return d end
  d = { id = source.id, source = source, cards = {}, query = "", catRows = {} }
  decks[source.id] = d
  -- the name, top left
  local title = addCard(d, "Title", "tl", 0, 0, 760, 72, true)
  text(title.body, source.title or source.id, 30, "black", { Size = UDim2.fromOffset(760, 36), ZIndex = 22 })
  d.subtitle = text(title.body, source.eyebrow or source.desc or "", 13, "medium", { Position = UDim2.fromOffset(1, 40), Size = UDim2.fromOffset(760, 18), TextColor3 = P.sub, ZIndex = 22 })
  -- the search pill, top right
  local search = addCard(d, "Search", "tr", 0, 0, 260, 44)
  glyph(search.body, "search", 16, P.subtle, { Position = UDim2.fromOffset(16, 14), ZIndex = 22 })
  local seek = entryBox(search.body, 13)
  seek.Position, seek.Size, seek.ZIndex = UDim2.fromOffset(42, 0), UDim2.fromOffset(176, 44), 22
  seek.PlaceholderText, seek.PlaceholderColor3, seek.Text = "Search " .. lower(source.title or source.id), P.placeholder, ""
  d.seek = seek
  local clear = hit(search.body, { Position = UDim2.fromOffset(260 - 36, 10), Size = UDim2.fromOffset(24, 24), ZIndex = 23, Visible = false })
  glyph(clear, "x", 14, P.subtle, { Position = UDim2.fromOffset(5, 5), ZIndex = 24 })
  clear.Activated:Connect(function() seek.Text = "" end)
  -- you, beside it: a click opens the looks and the rest
  local account = addCard(d, "Account", "tr", 270, 0, 200, 44)
  headshot(account.body, 7, 7, 30)
  text(account.body, S.Players.LocalPlayer.DisplayName, 13, "bold", { Position = UDim2.fromOffset(46, 6), Size = UDim2.fromOffset(122, 16), ZIndex = 22 })
  text(account.body, "@" .. S.Players.LocalPlayer.Name, 10, "medium", { Position = UDim2.fromOffset(46, 23), Size = UDim2.fromOffset(122, 14), TextColor3 = P.subtle, ZIndex = 22 })
  glyph(account.body, "chevron-down", 14, P.subtle, { Position = UDim2.fromOffset(200 - 30, 15), ZIndex = 22 })
  local accountHit = hit(account.body, { ZIndex = 24, BackgroundColor3 = P.white })
  round(accountHit, 22)
  accountHit.MouseEnter:Connect(function() tween(accountHit, HOVER_INFO, { BackgroundTransparency = 0.96 }) end)
  accountHit.MouseLeave:Connect(function() tween(accountHit, HOVER_INFO, { BackgroundTransparency = 1 }) end)
  accountHit.Activated:Connect(B.safe("novoline.account", function() UI.sfx("click", 0.5); looksMenu(account.frame) end))
  -- Music is Novoline's music deck: what is playing is the stage, bottom left (its record, the
  -- cover and the Shuffle, Library and Playlists tiles: the hub's wide card), and the tab's sections
  -- sit bottom right, the way Novoline's queue does
  local stage = false -- (music wide-card stage stubbed out)
  -- the Options card first: the tab builds into it
  local optionsW = stage and SIDE_W or OPTIONS_W
  local options = addCard(d, "Options", stage and "br" or "bl", stage and 0 or 224, 0, optionsW, CARD_H)
  d.options = options
  d.heroTitle = text(options.body, "", 16, "bold", { Position = UDim2.fromOffset(18, 14), Size = UDim2.fromOffset(optionsW - 18 - 60, 20), ZIndex = 22 })
  d.heroDesc = text(options.body, "", 11, "medium", { Position = UDim2.fromOffset(18, 35), Size = UDim2.fromOffset(optionsW - 18 - 60, 28), TextColor3 = P.subtle, ZIndex = 22,
    TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top })
  local heroTile = tile(options.body, { Position = UDim2.fromOffset(optionsW - 16 - 36, 14), Size = UDim2.fromOffset(36, 36), ZIndex = 21 }, 12)
  d.heroTile = heroTile
  d.heroIcon = glyph(heroTile, source.icon or "circle", 18, P.text, { Position = UDim2.fromOffset(9, 9), ZIndex = 22 })
  local scroller = Instance.new("ScrollingFrame")
  scroller.Name = source.id
  scroller.BackgroundTransparency, scroller.BorderSizePixel = 1, 0
  scroller.Position, scroller.Size = UDim2.fromOffset(0, 68), UDim2.new(1, 0, 1, -68)
  scroller.CanvasSize = UDim2.new()
  scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
  scroller.ScrollingDirection = Enum.ScrollingDirection.Y
  scroller.ScrollBarThickness = 0
  scroller.ZIndex = 21
  scroller.Parent = options.body
  scroller:GetPropertyChangedSignal("CanvasPosition"):Connect(function() hideTip() end)
  local content = box(scroller, { Name = "Content", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 21 })
  pad(content, 4, 12, 18, 12)
  list(content, 20)
  -- the tab, built into it
  local entry = setmetatable({ source = source, scroller = scroller, content = content, sections = 0, rows = {}, cards = {}, list = {}, toggles = {}, narrow = stage }, Page)
  N.pages[source.id] = entry
  d.entry = entry
  B.try("novoline.page." .. source.id, source.build, entry)
  -- (what the stage already shows is not a section of its own as well: Music's "Now playing" was
  -- the wide player squeezed into the narrow card beside the same player, 2026-10-30)
  if stage then
    for index = #entry.list, 1, -1 do
      local item = entry.list[index]
      if item.stage then
        item.frame.Visible = false
        table.remove(entry.list, index)
      end
    end
  end
  if #entry.list == 0 then entry:empty(nil, "Nothing here yet", "This tab is ready for its controls.") end
  -- (B.Keys.repaint stub: key list repaint is kernel-driven)
  -- its sections, beside it (a tab of one section is a stage of its own)
  d.single = #entry.list == 1 and not stage
  d.fixed = stage
  if stage then
    local size = Vector2.new(420, 300) -- (B.Card.WIDE stub)
    local now = addCard(d, "NowPlaying", "bl", 0, 0, STAGE_W, CARD_H)
    local k = math.min(STAGE_W / size.X, CARD_H / size.Y)
    local holder = box(now.body, { Name = "Wide", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(size.X, size.Y), ZIndex = 21 })
    local grow = Instance.new("UIScale"); grow.Scale = k; grow.Parent = holder
    -- (B.Card.viewWide stub: wide music card disabled)
  end
  if d.single then
    options.x = 0
  else
    local cats = addCard(d, "Sections", stage and "br" or "bl", stage and (SIDE_W + 14) or 0, 0, SECTIONS_W, CARD_H)
    text(cats.body, "Sections", 14, "bold", { Position = UDim2.fromOffset(18, 16), Size = UDim2.fromOffset(160, 18), ZIndex = 22 })
    local many = #entry.list > 8
    local step = many and 35 or 38
    local tall = step - 4
    local holder = Instance.new("ScrollingFrame")
    holder.BackgroundTransparency, holder.BorderSizePixel = 1, 0
    holder.Position, holder.Size = UDim2.fromOffset(0, many and 38 or 40), UDim2.new(1, 0, 1, -(many and 38 or 40) - 8)
    holder.CanvasSize = UDim2.fromOffset(0, #entry.list * step)
    holder.ScrollBarThickness = 0
    holder.ScrollingDirection = Enum.ScrollingDirection.Y
    holder.ZIndex = 21
    holder.Parent = cats.body
    local glide = box(holder, { Name = "Glide", BackgroundColor3 = P.white, BackgroundTransparency = 0.9, ZIndex = 21 })
    round(glide, 12)
    d.glide = glide
    for n, item in ipairs(entry.list) do
      local line = hit(holder, { Name = item.title, Position = UDim2.fromOffset(12, (n - 1) * step), Size = UDim2.fromOffset(186, tall), ZIndex = 22 })
      local mark = tile(line, { Position = UDim2.fromOffset(5, math.floor((tall - 24) / 2)), Size = UDim2.fromOffset(24, 24), ZIndex = 23 }, 8)
      glyph(mark, item.icon, 14, P.text, { Position = UDim2.fromOffset(5, 5), ZIndex = 24 })
      local name, fits = shrink(text(line, item.title, 13, "bold", { Position = UDim2.fromOffset(38, 0), Size = UDim2.fromOffset(112, tall), TextTransparency = 0.35, ZIndex = 23 }), 13, 11)
      d.catSize = math.min(d.catSize or 13, fits or 13)
      local held = rowsIn(entry, item.frame)
      text(line, held > 0 and tostring(held) or "", 11, "medium", { Position = UDim2.fromOffset(186 - 10 - 28, 0), Size = UDim2.fromOffset(28, tall), TextColor3 = P.subtle,
        TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 23 })
      d.catRows[item] = { line = line, name = name }
      line.MouseEnter:Connect(function() if item ~= d.current or d.query ~= "" then tween(name, QUICK, { TextTransparency = 0.1 }) end end)
      line.MouseLeave:Connect(function() if item ~= d.current or d.query ~= "" then tween(name, QUICK, { TextTransparency = 0.35 }) end end)
      line.Activated:Connect(B.safe("novoline.section", function()
        UI.sfx("tab", 0.35)
        if d.query ~= "" then seek.Text = "" end
        pick(d, item)
      end))
    end
  end
  -- (the list reads as one: every name at the size the longest one fits)
  for _, r in pairs(d.catRows) do r.name.TextSize = d.catSize or 13 end
  -- quick settings, bottom right: the tab's first three switches as Novoline's tinted tiles
  -- (Music has none of these two: its sections are where they would be)
  local quick = addCard(stage and { cards = {} } or d, "Quick", "br", 0, 187, SIDE_W, 173)
  text(quick.body, "Quick settings", 14, "bold", { Position = UDim2.fromOffset(18, 16), Size = UDim2.fromOffset(200, 18), ZIndex = 22 })
  if #entry.toggles == 0 then
    text(quick.body, "No switches on this tab.", 12, "medium", { Position = UDim2.fromOffset(18, 48), Size = UDim2.fromOffset(SIDE_W - 36, 16), TextColor3 = P.subtle, ZIndex = 22 })
  end
  for n = 1, math.min(3, #entry.toggles) do
    local t = entry.toggles[n]
    local tint = TINT[n]
    local holder, plate = soft(quick.body, 16 + (n - 1) * 102, 40, 94, 117, 18, nil, function() Config.set(t.id, not (Config.get(t.id) == true)) end)
    local plateBody = plate:FindFirstChildOfClass("UIGradient")
    local mark = glyph(holder, t.icon or source.icon or "zap", 20, P.text, { Position = UDim2.fromOffset(14, 14), ZIndex = 26 })
    shrink(text(holder, t.label, 12, "bold", { Position = UDim2.fromOffset(14, 74), Size = UDim2.fromOffset(74, 16), ZIndex = 26 }), 12, 8)
    local state = text(holder, "", 11, "medium", { Position = UDim2.fromOffset(14, 92), Size = UDim2.fromOffset(74, 14), TextColor3 = P.subtle, ZIndex = 26 })
    local function paint()
      local on = Config.get(t.id) == true
      if plateBody then plateBody.Enabled = not on end
      plate.BackgroundColor3 = on and tint[1] or P.white
      tween(mark, QUICK, { ImageColor3 = on and tint[2] or P.text })
      state.Text = on and "On" or "Off"
    end
    paint()
    Config.on(t.id, function() if holder.Parent then paint() end end)
  end
  -- its keys, under that
  local keys = addCard(stage and { cards = {} } or d, "Shortcuts", "br", 0, 0, SIDE_W, 173)
  header(keys, "Shortcuts", "keyboard")
  local keyRows = box(keys.body, { Size = UDim2.fromScale(1, 1), ZIndex = 22 })
  local function drawKeys()
    for _, child in ipairs(keyRows:GetChildren()) do child:Destroy() end
    local bound = {}
    for id, info in pairs(Controls.bindables) do
      local bind = Config.bindOf(id)
      if bind and bind.key and info.page == source then bound[#bound + 1] = { id = id, label = info.label, kind = info.kind, bind = bind } end
    end
    table.sort(bound, function(a, b) return a.label < b.label end)
    if #bound == 0 then
      text(keyRows, "Nothing on this tab has a key yet. Right-click a switch to give it one.", 12, "medium", { Position = UDim2.fromOffset(18, 48), Size = UDim2.fromOffset(SIDE_W - 36, 34),
        TextWrapped = true, TextTruncate = Enum.TextTruncate.None, TextColor3 = P.subtle, ZIndex = 23 })
      local open = soft(keyRows, 18, 104, 132, 34, 17, nil, function() N.go("keys") end)
      glyph(open, "keyboard", 14, P.text, { Position = UDim2.fromOffset(14, 10), ZIndex = 26 })
      text(open, "All your keys", 12, "bold", { Position = UDim2.fromOffset(36, 0), Size = UDim2.fromOffset(90, 34), ZIndex = 26 })
      return
    end
    for n = 1, math.min(2, #bound) do
      local b = bound[n]
      local y = 44 + (n - 1) * ROW_H
      shrink(text(keyRows, b.label, 13, "bold", { Position = UDim2.fromOffset(18, y + 11), Size = UDim2.fromOffset(SIDE_W - 36 - 104, 16), ZIndex = 23 }), 13, 10)
      local how = b.kind == "button" and "Press to run" or (b.bind.mode == "hold" and "Hold to use" or "Press to switch")
      text(keyRows, how, 11, "medium", { Position = UDim2.fromOffset(18, y + 30), Size = UDim2.fromOffset(SIDE_W - 36 - 104, 14), TextColor3 = P.subtle, ZIndex = 23 })
      local plate = tile(keyRows, { Position = UDim2.fromOffset(SIDE_W - 18 - 92, y + 14), Size = UDim2.fromOffset(92, 28), ZIndex = 23 }, 14)
      text(plate, Config.keyLabel(b.bind.key), 12, "bold", { Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 24 })
      if n < math.min(2, #bound) then
        box(keyRows, { Position = UDim2.fromOffset(18, y + ROW_H - 1), Size = UDim2.fromOffset(SIDE_W - 36, 1), BackgroundColor3 = P.white, BackgroundTransparency = 0.94, ZIndex = 23 })
      end
    end
    if #bound > 2 then
      text(keyRows, "+" .. (#bound - 2) .. " more on Keys", 11, "medium", { Position = UDim2.fromOffset(18, 173 - 22), Size = UDim2.fromOffset(SIDE_W - 36, 14), TextColor3 = P.subtle, ZIndex = 23 })
    end
  end
  drawKeys()
  Config.bindsChanged:connect(function() if keyRows.Parent then drawKeys() end end)
  -- searching
  local token = 0
  seek:GetPropertyChangedSignal("Text"):Connect(function()
    clear.Visible = seek.Text ~= ""
    token = token +  1
    local mine = token
    task.delay(0.12, function()
      if mine ~= token then return end
      d.query = string.match(lower(seek.Text), "^%s*(.-)%s*$")
      B.try("novoline.search", pick, d, d.current)
    end)
  end)
  pick(d, entry.list[1], true)
  return d
end
-- show one section (or, while searching, every section that has a match)
pick = function(d, item, instant)
  local entry = d.entry
  if not item then return end
  fold()
  closeMenu()
  d.current = item
  local searching = d.query ~= ""
  local any, shown = filter(entry, d.query)
  local count = 0
  for _, other in ipairs(entry.list) do
    local on
    if searching then on = shown[other.frame] == true else on = other == item end
    other.frame.Visible = on
    other.head.Visible = searching and on
    if on then count = count +  rowsIn(entry, other.frame) end
  end
  if searching then
    d.heroTitle.Text = any and "Results" or "Nothing found"
    d.heroDesc.Text = any and (count == 1 and "1 setting matches" or (count .. " settings match")) or "Try another word."
    UI.setIcon(d.heroIcon, "search")
  else
    d.heroTitle.Text = item.title
    local held = rowsIn(entry, item.frame)
    d.heroDesc.Text = item.desc or (held > 0 and (held == 1 and "1 setting" or (held .. " settings")) or "")
    UI.setIcon(d.heroIcon, item.icon or "circle")
  end
  shape(d, (not searching) and item.wide, instant)
  -- the Sections card: the glide sits under the chosen one, the others dimmed
  if d.glide then
    local at = d.catRows[item]
    if at then
      local goal = { Position = at.line.Position, Size = at.line.Size, BackgroundTransparency = searching and 1 or 0.9 }
      if instant or d.glide.Size.Y.Offset <= 0 then
        d.glide.Position, d.glide.Size, d.glide.BackgroundTransparency = goal.Position, goal.Size, goal.BackgroundTransparency
      else
        tween(d.glide, TweenInfo.new(0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), goal)
      end
    end
    for other, r in pairs(d.catRows) do
      tween(r.name, QUICK, { TextTransparency = (other == item and not searching) and 0 or 0.35 })
    end
  end
  if not searching then d.entry.scroller.CanvasPosition = Vector2.zero end
end

-- ---------------------------------------------------------------- the Home deck: Novoline's own
local DAY = {
  { 5, "It's the middle of the night, night owl" }, { 7, "It's sunrise, the day is just getting started" }, { 11, "Good morning, have a good one" },
  { 14, "It's midday, sun's at the top" }, { 17, "Good afternoon, hope it's going well" }, { 19, "It's golden hour" }, { 21, "It's sunset, wind down a little" },
  { 24, "Good evening, the night is yours" },
}
local function dayLine()
  local hour = tonumber(os.date("%H")) or 12
  for _, step in ipairs(DAY) do if hour < step[1] then return step[2] end end
  return DAY[#DAY][2]
end
local homeDeck = nil
local function buildHome()
  if homeDeck then return homeDeck end
  local d = { id = "home", cards = {} }
  homeDeck = d
  -- the welcome, top left
  local title = addCard(d, "Title", "tl", 0, 0, 760, 72, true)
  text(title.body, "Welcome, " .. S.Players.LocalPlayer.DisplayName, 30, "black", { Size = UDim2.fromOffset(760, 36), ZIndex = 22 })
  local day = text(title.body, dayLine(), 13, "medium", { Position = UDim2.fromOffset(1, 40), Size = UDim2.fromOffset(760, 18), TextColor3 = P.sub, ZIndex = 22 })
  -- the clock and the executor, top right
  local clock = addCard(d, "Clock", "tr", 0, 0, 158, 44)
  glyph(clock.body, "clock", 16, P.subtle, { Position = UDim2.fromOffset(16, 14), ZIndex = 22 })
  local time = text(clock.body, "", 15, "bold", { Position = UDim2.fromOffset(42, 0), Size = UDim2.fromOffset(50, 44), ZIndex = 22 })
  local date = text(clock.body, "", 13, "medium", { Position = UDim2.fromOffset(94, 0), Size = UDim2.fromOffset(56, 44), TextColor3 = P.subtle, ZIndex = 22 })
  local execName = "Script Hub" -- (executor detection removed: generic label)
  local okW, size = pcall(TextService.GetTextSize, TextService, execName, 13, Enum.Font.GothamBold, Vector2.new(400, 44))
  local execW = math.min(okW and size.X or 80, 160) + 58
  local exec = addCard(d, "Executor", "tr", 158 + 10, 0, execW, 44)
  glyph(exec.body, "shield", 16, P.subtle, { Position = UDim2.fromOffset(16, 14), ZIndex = 22 })
  text(exec.body, execName, 13, "bold", { Position = UDim2.fromOffset(40, 0), Size = UDim2.fromOffset(execW - 54, 44), ZIndex = 22 })
  -- you, bottom left
  local profile = addCard(d, "Profile", "bl", 0, 0, 230, 360)
  local banner = box(profile.body, { Name = "Banner", Size = UDim2.fromOffset(230, 110), BackgroundColor3 = P.white, BackgroundTransparency = 0, ZIndex = 21 })
  local bannerFade = Instance.new("UIGradient")
  bannerFade.Rotation = 90
  bannerFade.Color = ColorSequence.new(rgb(46, 46, 50), rgb(16, 16, 18))
  bannerFade.Transparency = NumberSequence.new(0, 1)
  bannerFade.Parent = banner
  local avatar = headshot(profile.body, 18, 70, 76)
  local ring = Instance.new("UIStroke"); ring.Color, ring.Thickness = rgb(12, 12, 14), 4; ring.Parent = avatar
  text(profile.body, S.Players.LocalPlayer.DisplayName, 18, "bold", { Position = UDim2.fromOffset(18, 158), Size = UDim2.fromOffset(194, 22), ZIndex = 22 })
  text(profile.body, "@" .. S.Players.LocalPlayer.Name, 12, "medium", { Position = UDim2.fromOffset(18, 182), Size = UDim2.fromOffset(194, 16), TextColor3 = P.subtle, ZIndex = 22 })
  local stat = {}
  for n, key in ipairs({ "Friends", "Account", "Online" }) do
    local x = 18 + (n - 1) * 68
    stat[key] = text(profile.body, "", 16, "bold", { Position = UDim2.fromOffset(x, 232), Size = UDim2.fromOffset(64, 20), ZIndex = 22 })
    text(profile.body, key, 11, "medium", { Position = UDim2.fromOffset(x, 254), Size = UDim2.fromOffset(64, 14), TextColor3 = P.subtle, ZIndex = 22 })
  end
  local ageDays = tonumber(S.Players.LocalPlayer.AccountAge) or 0
  stat.Account.Text = ageDays >= 365 and (math.floor(ageDays / 365) .. "y") or (ageDays .. "d")
  stat.Friends.Text, stat.Online.Text = "...", "..."
  box(profile.body, { Position = UDim2.fromOffset(18, 288), Size = UDim2.fromOffset(194, 1), BackgroundColor3 = P.white, BackgroundTransparency = 0.93, ZIndex = 22 })
  text(profile.body, os.date("Joined Roblox in %B %Y", os.time() - ageDays * 86400), 11, "medium", { Position = UDim2.fromOffset(18, 304), Size = UDim2.fromOffset(194, 14),
    TextColor3 = P.subtle, ZIndex = 22 })
  text(profile.body, "Account " .. (ageDays >= 365 and (math.floor(ageDays / 365) .. " years") or (ageDays .. " days")) .. " old", 11, "medium",
    { Position = UDim2.fromOffset(18, 324), Size = UDim2.fromOffset(194, 14), TextColor3 = P.subtle, ZIndex = 22 })
  -- over it, Novoline's own first widget: its name and the frames a second
  local widget = addCard(d, "Widget", "bl", 0, 360 + 14, 230, 118)
  text(widget.body, "BASED", 15, "bold", { Position = UDim2.fromOffset(18, 18), Size = UDim2.fromOffset(194, 20), ZIndex = 22 })
  local fpsValue = text(widget.body, "-", 28, "black", { Position = UDim2.fromOffset(18, 48), Size = UDim2.fromOffset(194, 34), ZIndex = 22 })
  text(widget.body, "FPS", 11, "medium", { Position = UDim2.fromOffset(18, 84), Size = UDim2.fromOffset(194, 14), TextColor3 = P.subtle, ZIndex = 22 })
  -- quick actions: the first three tabs, as Novoline's tinted tiles
  local quick = addCard(d, "Quick", "bl", 244, 0, 260, 173)
  header(quick, "Quick actions", "zap")
  local picks = {}
  for _, page in ipairs(tabsWanted()) do
    if page.id ~= "home" and #picks < 3 then picks[#picks + 1] = page end
  end
  for n, page in ipairs(picks) do
    local tint = TINT[n]
    local holder = soft(quick.body, 18 + (n - 1) * 78, 46, 68, 109, 18, tint[1], function() N.go(page.id) end)
    glyph(holder, page.icon or "circle", 20, tint[2], { Position = UDim2.fromOffset(12, 14), ZIndex = 26 })
    shrink(text(holder, page.title or page.id, 13, "bold", { Position = UDim2.fromOffset(9, 109 - 14 - 16), Size = UDim2.fromOffset(56, 16), ZIndex = 26 }), 13, 8)
  end
  -- what is playing
  local music = addCard(d, "NowPlaying", "bl", 244, 187, 260, 173)
  header(music, "Now playing", "music")
  local cover = Instance.new("ImageLabel")
  cover.BackgroundColor3, cover.BorderSizePixel = rgb(40, 40, 44), 0
  cover.Position, cover.Size, cover.ScaleType, cover.ZIndex = UDim2.fromOffset(18, 46), UDim2.fromOffset(56, 56), Enum.ScaleType.Crop, 22
  cover.Parent = music.body
  round(cover, 12)
  local coverMark = glyph(cover, "music", 22, P.subtle, { Position = UDim2.fromOffset(17, 17), ZIndex = 23 })
  local songTitle = text(music.body, "Nothing playing", 14, "bold", { Position = UDim2.fromOffset(86, 54), Size = UDim2.fromOffset(156, 18), ZIndex = 22 })
  local songArtist = shrink(text(music.body, "Pick a song from your library", 12, "medium", { Position = UDim2.fromOffset(86, 73), Size = UDim2.fromOffset(156, 16), TextColor3 = P.subtle, ZIndex = 22 }), 12, 9)
  local playIcon
  local controls = {}
  for n, spec in ipairs({ { "skip-back", function() Window.toast({ title = "Music", text = "Not available in this build.", icon = "music", time = 2 }) end },
    { "play", function() Window.toast({ title = "Music", text = "Not available in this build.", icon = "music", time = 2 }) end },
    { "skip-forward", function() Window.toast({ title = "Music", text = "Not available in this build.", icon = "music", time = 2 }) end } }) do
    local main = n == 2
    local dim = main and 40 or 34
    local x = ({ 64, 110, 162 })[n]
    local holder, plate = soft(music.body, x, 173 - 18 - 20 - dim / 2, dim, dim, dim / 2, main and P.on or nil, spec[2])
    local isz = main and 16 or 14
    local mark = glyph(holder, spec[1], isz, main and P.ink or P.text, { Position = UDim2.fromOffset((dim - isz) / 2, (dim - isz) / 2), ZIndex = 26 })
    if main then playIcon = mark end
    controls[n] = holder
    local _ = plate
  end
  local coverKey
  -- (audio stub: "Now playing" card shows the latest notify message instead)
  local function refreshMusic()
    local msg = island and island.showing
    if msg and not msg.gone then
      songTitle.Text = msg.title or "Notification"
      songArtist.Text = msg.text or ""
    else
      songTitle.Text, songArtist.Text = "Ready", "No notifications"
    end
    cover.Image, coverMark.Visible, coverKey = "", true, nil
    UI.setIcon(playIcon, "bell")
    controls[1].Visible = false
    controls[3].Visible = false
  end
  -- two quick commands under it
  local cmd = addCard(d, "QuickCommands", "bl", 244, 360 + 14, 260, 118)
  text(cmd.body, "Quick Commands", 13, "bold", { Position = UDim2.fromOffset(16, 12), Size = UDim2.fromOffset(190, 16), ZIndex = 22 })
  glyph(cmd.body, "zap", 14, P.subtle, { Position = UDim2.fromOffset(260 - 30, 13), ZIndex = 22 })
  local cmdW = math.floor((260 - 14 * 2 - 10) / 2)
  local commands = {
    { label = "Settings", icon = "settings", tint = TINT[4], run = function() N.go("settings") end },
    { label = "Keys", icon = "keyboard", tint = TINT[5], run = function() N.go("keys") end },
  }
  for n, c in ipairs(commands) do
    local holder = soft(cmd.body, 14 + (n - 1) * (cmdW + 10), 36, cmdW, 70, 16, c.tint[1], c.run)
    glyph(holder, c.icon, 22, c.tint[2], { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0, 24), ZIndex = 26 })
    text(holder, c.label, 12, "bold", { Position = UDim2.fromOffset(0, 70 - 8 - 14), Size = UDim2.fromOffset(cmdW, 14), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 26 })
  end
  -- the game, bottom right
  local gameCard = addCard(d, "Game", "br", 314, 0, 230, 360)
  local shot = Instance.new("ImageLabel")
  shot.Name, shot.BackgroundColor3, shot.BorderSizePixel = "Thumbnail", rgb(30, 30, 33), 0
  shot.Size, shot.ScaleType, shot.ZIndex = UDim2.fromOffset(230, 128), Enum.ScaleType.Crop, 21
  shot.Image = "rbxthumb://type=Asset&id=" .. tostring(game.PlaceId) .. "&w=768&h=432"
  shot.Parent = gameCard.body
  local shotFade = Instance.new("UIGradient")
  shotFade.Rotation = 90
  shotFade.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.6, 0.15), NumberSequenceKeypoint.new(1, 1) })
  shotFade.Parent = shot
  local gameIcon = Instance.new("ImageLabel")
  gameIcon.BackgroundColor3, gameIcon.BorderSizePixel = rgb(40, 40, 44), 0
  gameIcon.Position, gameIcon.Size, gameIcon.ZIndex = UDim2.fromOffset(18, 96), UDim2.fromOffset(52, 52), 22
  gameIcon.Image = "rbxthumb://type=GameIcon&id=" .. tostring(game.GameId) .. "&w=150&h=150"
  gameIcon.Parent = gameCard.body
  round(gameIcon, 14)
  local iconRing = Instance.new("UIStroke"); iconRing.Color, iconRing.Thickness = rgb(12, 12, 14), 3; iconRing.Parent = gameIcon
  local status = {} -- (B.Registry.status stub: no hub registry)
  local gameName = text(gameCard.body, status.name or "This game", 16, "bold", { Position = UDim2.fromOffset(18, 158), Size = UDim2.fromOffset(194, 20), ZIndex = 22 })
  local gameBy = text(gameCard.body, "", 12, "medium", { Position = UDim2.fromOffset(18, 180), Size = UDim2.fromOffset(194, 16), TextColor3 = P.subtle, ZIndex = 22 })
  text(gameCard.body, status.engineered and "BASED is engineered for it" or ("Place " .. tostring(game.PlaceId)), 12, "medium",
    { Position = UDim2.fromOffset(18, 214), Size = UDim2.fromOffset(194, 16), TextColor3 = P.sub, ZIndex = 22 })
  task.spawn(function()
    local ok, info = pcall(function() return S.MarketplaceService:GetProductInfo(game.PlaceId) end)
    if ok and type(info) == "table" and gameName.Parent then
      if not status.name then gameName.Text = tostring(info.Name or "This game") end
      local creator = type(info.Creator) == "table" and info.Creator.Name
      gameBy.Text = creator and ("By " .. tostring(creator)) or ""
    end
  end)
  local function copy(label, icon, x, value)
    local holder = soft(gameCard.body, x, 252, 94, 32, 16, nil, function()
      local ok = pcall(function() setclipboard(value()) end); local done = ok and setclipboard ~= nil
      Window.toast({ title = label, text = done and "Copied" or "This executor has no clipboard access.", icon = icon, tone = done and "ok" or "warn", time = 2.4 })
    end)
    glyph(holder, icon, 14, P.text, { Position = UDim2.fromOffset(12, 9), ZIndex = 26 })
    shrink(text(holder, label, 12, "bold", { Position = UDim2.fromOffset(31, 8), Size = UDim2.fromOffset(94 - 36, 16), ZIndex = 26 }), 12, 9)
  end
  copy("Copy link", "link", 18, function() return "https://www.roblox.com/games/" .. tostring(game.PlaceId) end)
  copy("Job ID", "copy", 118, function() return game.JobId end)
  -- this server
  local server = addCard(d, "Server", "br", 0, 187, 300, 173)
  header(server, "This server", "server")
  local sv = {}
  for n, key in ipairs({ "Players", "Ping", "Uptime" }) do
    local x = 18 + (n - 1) * 94
    sv[key] = text(server.body, "", 20, "bold", { Position = UDim2.fromOffset(x, 44), Size = UDim2.fromOffset(90, 24), ZIndex = 22 })
    text(server.body, key, 11, "medium", { Position = UDim2.fromOffset(x, 68), Size = UDim2.fromOffset(90, 14), TextColor3 = P.subtle, ZIndex = 22 })
  end
  local function chip(label, icon, x, w, run)
    local holder = soft(server.body, x, 97, w, 30, 15, nil, run)
    glyph(holder, icon, 14, P.text, { Position = UDim2.fromOffset(12, 8), ZIndex = 26 })
    text(holder, label, 12, "bold", { Position = UDim2.fromOffset(32, 0), Size = UDim2.fromOffset(w - 38, 30), ZIndex = 26 })
  end
  chip("Rejoin", "rotate-ccw", 18, 124, function() pcall(function() S.TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, S.Players.LocalPlayer) end) end)
  chip("Server hop", "shuffle", 150, 132, function() Window.toast({ title = "Server hop", text = "Not available in this build.", icon = "shuffle", time = 2 }) end)
  -- your friends
  local friends = addCard(d, "Friends", "br", 0, 0, 300, 173)
  text(friends.body, "Friends online", 14, "bold", { Position = UDim2.fromOffset(18, 16), Size = UDim2.fromOffset(200, 18), ZIndex = 22 })
  local friendCount = text(friends.body, "", 14, "bold", { Position = UDim2.fromOffset(200, 16), Size = UDim2.fromOffset(82, 18), TextColor3 = P.subtle,
    TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 22 })
  local faces = {}
  for n = 1, 6 do
    local f = Instance.new("ImageLabel")
    f.BackgroundColor3, f.BorderSizePixel = rgb(40, 40, 44), 0
    f.Position, f.Size, f.ZIndex, f.Visible = UDim2.fromOffset(18 + (n - 1) * 27, 48), UDim2.fromOffset(36, 36), 22 + (7 - n), false
    f.Parent = friends.body
    round(f, true)
    local r = Instance.new("UIStroke"); r.Color, r.Thickness = rgb(14, 14, 16), 3; r.Parent = f
    faces[n] = f
  end
  local more = text(friends.body, "", 12, "bold", { Position = UDim2.fromOffset(0, 48), Size = UDim2.fromOffset(70, 36), TextColor3 = P.subtle, ZIndex = 22 })
  local friendLine = text(friends.body, "Looking for your friends", 12, "medium", { Position = UDim2.fromOffset(18, 104), Size = UDim2.fromOffset(264, 16), TextColor3 = P.sub, ZIndex = 22 })
  -- (friends list stubbed: B.LP:GetFriendsOnline / GetFriendsAsync removed)
  local friendsAt, totalAsked = -1e9, false
  local function loadFriends()
    if os.clock() - friendsAt < 30 then return end
    friendsAt = os.clock()
    friendCount.Text = "—"
    stat.Online.Text = "—"
    stat.Friends.Text = "—"
    for _, f in ipairs(faces) do f.Visible = false end
    more.Text = ""
    friendLine.Text = "Friends are not available in this build"
  end
  local function uptime(seconds)
    seconds = math.floor(seconds or 0)
    if seconds >= 3600 then return string.format("%dh %dm", seconds // 3600, (seconds % 3600) // 60) end
    return string.format("%dm", math.max(1, seconds // 60))
  end
  d.refresh = function()
    time.Text = os.date("%H:%M")
    date.Text = (string.gsub(os.date("%a %d"), " 0", " "))
    day.Text = dayLine()
    sv.Players.Text = #S.Players:GetPlayers() .. "/" .. S.Players.MaxPlayers
    sv.Ping.Text = "—ms" -- (B.Hud.ping stub: no hub hud)
    sv.Uptime.Text = uptime(workspace.DistributedGameTime)
    fpsValue.Text = tostring(math.floor(workspace:GetRealPhysicsFPS() + 0.5))
    refreshMusic() -- (was B.try("novoline.music", refreshMusic))
    loadFriends()
  end
  Motion.every(function()
    if N.open and N.current == "home" then d.refresh() end
  end, 2, "novoline.home")
  return d
end

-- ---------------------------------------------------------------- showing a deck, and changing decks
local shown = nil
-- opening: every card rises out of the dock, in a shuffled order, a moment apart (Novoline's);
-- changing tab: each card glides out of the card that was in its corner, the rest fade
local function showDeck(d, opening, from)
  shown = d
  if d.refresh then B.try("novoline.refresh", d.refresh) end
  local count = #d.cards
  local order = {}
  for i = 1, count do order[i] = i end
  if opening then for i = count, 2, -1 do local j = math.random(i); order[i], order[j] = order[j], order[i] end end
  local used = {}
  for n, item in ipairs(d.cards) do
    item.scale.Scale = N.sizer.Scale
    local delay = math.min((order[n] - 1) * (opening and 0.04 or 0.018), opening and 0.22 or 0.12)
    if item.bare then
      lift(item, delay, opening and 14 or 6)
    elseif opening or not from then
      rise(item, delay)
    else
      local partner
      for _, other in ipairs(from.cards) do
        if not used[other] and not other.bare and other.corner == item.corner and other.frame.Visible and not other.sinking then
          partner, used[other] = other, true
          break
        end
      end
      if partner then
        morph(item, partner.frame.Position, partner.frame.Size, 0)
      else
        local centre = cardRest(item)
        morph(item, UDim2.fromOffset(centre.X, centre.Y), UDim2.fromOffset(item.w * 0.96, item.h * 0.96), delay)
      end
    end
  end
  if from and from ~= d then
    for _, other in ipairs(from.cards) do fadeAway(other) end
  end
end
local function hideDeck(d)
  if not d then return end
  for n, item in ipairs(d.cards) do sink(item, (n - 1) * 0.012) end
end
function N.go(id)
  local source = Window.pages[id]
  if not (source and N.built) then return end
  fold()
  closeMenu()
  hideTip()
  N.current = id
  N.paintNav()
  if not N.open then return end
  local d
  if id == "home" then d = buildHome() else
    local ok, made = pcall(tabDeck, source)
    if not ok then B.fault("novoline.deck." .. tostring(id), made); return end
    d = made
  end
  if shown == d and not N.opening then return end
  local from = (not N.opening) and shown or nil
  -- (Novoline's tab sound on a change of tab, from the dock or anywhere; opening has its own)
  if from and from ~= d then nvSound("tab") end
  showDeck(d, N.opening, from ~= d and from or nil)
end
-- (for a test, or a tab that wants to point at one of its sections: the n-th section of a tab)
function N.pickSection(id, n)
  local d = decks[id]
  if d and d.entry and d.entry.list[n] then pick(d, d.entry.list[n]) end
end
-- a search from elsewhere (the palette): it goes into the deck the tab has
function N.search(value)
  if not (N.built and N.current and N.current ~= "home") then return end
  local d = decks[N.current]
  if d and d.seek then d.seek.Text = value or "" end
end

-- ---------------------------------------------------------------- the window
function N.build()
  if N.built then return end
  N.built = true
  N.since = os.clock()
  pickFont()
  local gui = Instance.new("ScreenGui") -- (B.screen stub: create directly)
  gui.Name, gui.ZIndexBehavior, gui.ResetOnSpawn, gui.DisplayOrder = "Novoline", Enum.ZIndexBehavior.Sibling, false, 9060
  gui.Parent = game:GetService("CoreGui") or S.Players.LocalPlayer:WaitForChild("PlayerGui")
  gui:SetAttribute("OwnLetters", true)
  N.gui = gui
  N.modal = Instance.new("TextButton")
  N.modal.Text, N.modal.BackgroundTransparency, N.modal.Size, N.modal.Modal, N.modal.Visible = "", 1, UDim2.fromOffset(0, 0), true, false
  N.modal.Parent = gui
  -- the shade over the game while it is open (Novoline's: darker at the top and the bottom); a click on it closes
  local shade = Instance.new("TextButton")
  shade.Name, shade.Text, shade.AutoButtonColor = "Shade", "", false
  shade.Size, shade.BackgroundColor3, shade.BackgroundTransparency, shade.BorderSizePixel, shade.ZIndex = UDim2.fromScale(1, 1), P.black, 1, 0, 1
  shade.Visible = false
  shade.Parent = gui
  local shadeFade = Instance.new("UIGradient")
  shadeFade.Rotation = 90
  shadeFade.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.18), NumberSequenceKeypoint.new(0.16, 0.48), NumberSequenceKeypoint.new(0.45, 0.6),
    NumberSequenceKeypoint.new(1, 0.2) })
  shadeFade.Parent = shade
  shade.Activated:Connect(B.safe("novoline.shade", function() if N.open then N.show(false) end end))
  N.shade = shade
  N.sizer = { Scale = scaleNow() }
  -- the dock: Novoline's pill, its capsule, a tab an item
  local bar = box(gui, { Name = "Dock", AnchorPoint = Vector2.new(0.5, 1), Size = UDim2.fromOffset(304, DOCK_H), Visible = false, ZIndex = 40 })
  glass(bar, DOCK_H / 2)
  bar:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(1, 0)
  N.bar = bar
  N.barScale = Instance.new("UIScale"); N.barScale.Parent = bar
  local capsule = box(bar, { Name = "Capsule", BackgroundColor3 = P.white, BackgroundTransparency = 1, Size = UDim2.fromOffset(DOCK.w, DOCK.h),
    Position = UDim2.fromOffset(DOCK.pad, DOCK.pad), ZIndex = 52 })
  round(capsule, true)
  local capsuleBody = Instance.new("UIGradient"); capsuleBody.Rotation = 90; capsuleBody.Color = ColorSequence.new(rgb(46, 46, 49), rgb(32, 32, 35)); capsuleBody.Parent = capsule
  local capsuleRim = rim(capsule, P.white, 1)
  pcall(function() capsuleRim.BorderStrokePosition = Enum.BorderStrokePosition.Inner end)
  local capsuleLight = Instance.new("UIGradient"); capsuleLight.Rotation = 90
  capsuleLight.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.86), NumberSequenceKeypoint.new(0.4, 0.96), NumberSequenceKeypoint.new(1, 0.97) })
  capsuleLight.Parent = capsuleRim
  N.capsule, N.capsuleRim = capsule, capsuleRim
  seat()
  -- (held on its empty parts, the dock moves)
  local barGrip = hit(bar, { ZIndex = 51 })
  local barFrom, barStart
  UI.drag(barGrip, function(point)
    barFrom, barStart = point, Vector2.new(bar.AbsolutePosition.X + bar.AbsoluteSize.X / 2, bar.AbsolutePosition.Y + bar.AbsoluteSize.Y)
  end, function(point)
    local view = screen()
    local inset = UI.inset()
    local bottom = barStart + (point - barFrom)
    bar.Position = UDim2.fromScale(util.clamp01(bottom.X / view.X), util.clamp01((bottom.Y + inset.Y) / view.Y))
  end, function()
    Config.set("app.novoline.x", bar.Position.X.Scale)
    Config.set("app.novoline.y", bar.Position.Y.Scale)
  end)
  -- the overlay: menus, tips, the tab names over the dock
  overlay = box(gui, { Name = "Overlay", Size = UDim2.fromScale(1, 1), ZIndex = 80 })
  tip = text(overlay, "", 12, "medium", { Name = "Tip", Size = UDim2.fromOffset(0, 0), AutomaticSize = Enum.AutomaticSize.XY, TextWrapped = true,
    TextTruncate = Enum.TextTruncate.None, BackgroundColor3 = P.raised, BackgroundTransparency = 0, Visible = false, ZIndex = 95 })
  round(tip, 8)
  pad(tip, 6, 10, 6, 10)
  local tipMost = Instance.new("UISizeConstraint"); tipMost.MaxSize = Vector2.new(280, math.huge); tipMost.Parent = tip
  labelTip = text(overlay, "", 11, "bold", { Name = "Label", AnchorPoint = Vector2.new(0.5, 1), Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X,
    TextXAlignment = Enum.TextXAlignment.Center, TextTruncate = Enum.TextTruncate.None, BackgroundColor3 = P.raised, BackgroundTransparency = 0, Visible = false, ZIndex = 96 })
  round(labelTip, true)
  pad(labelTip, 0, 10, 0, 10)
  -- a click outside an open list or menu closes it
  B.connect(UIS.InputBegan, function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.MouseButton2 and input.UserInputType ~= Enum.UserInputType.Touch then
      if input.KeyCode == Enum.KeyCode.Escape then closeMenu(); fold() end
      return
    end
    local point = UI.point(input)
    if menu and not UI.inside(menu.frame, point) and not (menu.anchor and menu.anchor.Parent and UI.inside(menu.anchor, point)) then closeMenu() end
    if unfolded and input.UserInputType ~= Enum.UserInputType.MouseButton2 then
      if not (UI.inside(unfolded.frame, point) or (unfolded.anchor and unfolded.anchor.Parent and UI.inside(unfolded.anchor, point))) then fold() end
    end
  end, "novoline.outside")
  -- the screen's size or the hub's scale changes: everything follows
  local function rescale()
    if not N.sizer then return end
    local s = scaleNow()
    N.sizer.Scale = s
    N.barScale.Scale = s
    local all = { homeDeck }
    for _, d in pairs(decks) do all[#all + 1] = d end
    for _, d in ipairs(all) do
      for _, item in ipairs(d.cards) do
        item.scale.Scale = s
        if N.open and d == shown and item.frame.Visible and not item.sinking then settle(item) end
      end
    end
  end
  N.rescale = rescale
  rescale()
  local camera = workspace.CurrentCamera
  if camera then B.connect(camera:GetPropertyChangedSignal("ViewportSize"), rescale, "novoline.viewport") end
  N.rebuildTabs()
end
-- open: the dock pops up, the tab's deck rises out of it, the shade comes down; shut: all of it goes back
local motionToken = 0
function N.show(on)
  if on and not N.built then N.build() end
  if not N.built or N.open == on then
    if N.built and not on then N.bar.Visible = N.active() and Config.get("app.novoline.dock") == true end
    return
  end
  N.open = on
  motionToken = motionToken +  1
  local mine = motionToken
  closeMenu()
  fold()
  hideTip()
  N.showLabel(nil)
  N.modal.Visible = on and Config.get("app.freeCursor") ~= false
  if on then
    N.rescale()
    N.rebuildTabs()
    local bar = N.bar
    if not bar.Visible then
      bar.Visible = true
      seat()
      if not Motion.reduced then
        N.barScale.Scale = N.sizer.Scale * 0.86
        tween(N.barScale, TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = N.sizer.Scale })
      end
    end
    N.shade.Visible = true
    N.shade.BackgroundTransparency = 1
    tween(N.shade, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 - (Config.get("app.novoline.shade") or 100) / 100 })
    local id = N.current or "home"
    shown = nil
    N.opening = true
    local ok, err = pcall(N.go, id)
    N.opening = false
    if not ok then B.fault("novoline.open", err) end
    nvSound("open")
  else
    for _, d in pairs(decks) do if d.seek and d.seek:IsFocused() then d.seek:ReleaseFocus() end end
    hideDeck(shown)
    N.paintNav()
    tween(N.shade, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 })
    task.delay(0.36, function()
      if mine ~= motionToken then return end
      N.shade.Visible = false
      -- (the dock goes too, unless it is kept on screen)
      if Config.get("app.novoline.dock") ~= true and not N.open then
        if Motion.reduced then N.bar.Visible = false; return end
        tween(N.barScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = N.sizer.Scale * 0.86 })
        task.delay(0.2, function() if mine == motionToken and not N.open then N.bar.Visible = false; N.barScale.Scale = N.sizer.Scale end end)
      end
    end)
    nvSound("close")
  end
  if Window.onShow then Window.onShow:fire(Window.anyOpen()) end
end
function N.toggle() N.show(not N.open) end
function N.active() return Config.get("app.gui") == "novoline" end

-- ---------------------------------------------------------------- the island: what is playing, every message
local island
function N.islandHasMusic()
  return false -- (audio stub: island never shows music)
end
local function islandWanted() return N.active() and Config.get("app.novoline.island") ~= false and Config.get("app.island") ~= false end
local function makeIsland()
  if island or not N.gui then return end
  local frame = box(N.gui, { Name = "Island", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 10), Size = UDim2.fromOffset(196, 36), ZIndex = 70 })
  frame.BackgroundColor3 = P.black
  frame.BackgroundTransparency = 0.02
  round(frame, true)
  rim(frame, P.white, 0.9)
  pcall(function()
    local glow = Instance.new("UIShadow")
    glow.Color, glow.BlurRadius, glow.Offset, glow.Transparency, glow.ZIndex = P.black, UDim.new(0, 18), UDim2.fromOffset(0, 6), 0.5, -1
    glow.Parent = frame
  end)
  local sizer = Instance.new("UIScale"); sizer.Parent = frame
  frame.ClipsDescendants = true
  -- what it shows when nothing else is: the name, frames a second, ping
  local idle = box(frame, { Name = "Idle", Size = UDim2.fromScale(1, 1), ZIndex = 71 })
  local dot = box(idle, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 16, 0.5, 0), Size = UDim2.fromOffset(7, 7), BackgroundTransparency = 0, ZIndex = 72 })
  round(dot, true)
  wear(dot, "BackgroundColor3")
  text(idle, "Ready", 12, "black", { Position = UDim2.fromOffset(30, 0), Size = UDim2.new(0, 56, 1, 0), ZIndex = 72 })
  local stats = text(idle, "", 11, "medium", { Position = UDim2.fromOffset(86, 0), Size = UDim2.new(1, -102, 1, 0), TextColor3 = P.dim, ZIndex = 72,
    TextXAlignment = Enum.TextXAlignment.Right })
  -- the song: a turning cover, its name, bars that move with it
  local song = box(frame, { Name = "Song", Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 71 })
  local art = Instance.new("ImageLabel")
  art.BackgroundColor3, art.BorderSizePixel = P.raised, 0
  art.AnchorPoint, art.Position, art.Size = Vector2.new(0, 0.5), UDim2.new(0, 6, 0.5, 0), UDim2.fromOffset(28, 28)
  art.ScaleType, art.ZIndex = Enum.ScaleType.Crop, 72
  art.Parent = song
  round(art, true)
  -- (audio.marquee stub: plain text label instead of scrolling marquee)
  local songNameLabel = text(song, "", 12, "bold", { Position = UDim2.fromOffset(42, 4), Size = UDim2.new(1, -96, 0, 15), ZIndex = 72 })
  local songName = { holder = songNameLabel, set = function(t) songNameLabel.Text = t or "" end, step = function() end }
  local songWho = text(song, "", 10, "medium", { Position = UDim2.fromOffset(42, 19), Size = UDim2.new(1, -96, 0, 13), TextColor3 = P.dim, ZIndex = 72 })
  local bars = {}
  for i = 1, 5 do
    local bar = box(song, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(1, -46 + (i - 1) * 7, 0.5, 0), Size = UDim2.fromOffset(4, 6), BackgroundTransparency = 0, ZIndex = 72 })
    round(bar, true)
    wear(bar, "BackgroundColor3")
    bars[i] = bar
  end
  -- the line being sung, word by word (src/49): it takes the song's place while there is one
  local plainParts = { art, songWho, bars[1], bars[2], bars[3], bars[4], bars[5] }
  if songName then plainParts[#plainParts + 1] = songName.holder end
  local lyricRow = nil -- (B.Island.row / B.Card.wordColor stubbed: no lyric row)
  if lyricRow then lyricRow.frame.Visible = false end
  -- a message: its icon, title and text
  local note = box(frame, { Name = "Note", Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 71 })
  local chip = box(note, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 8, 0.5, 0), Size = UDim2.fromOffset(32, 32), BackgroundTransparency = 0, ZIndex = 72 })
  round(chip, true)
  local chipIcon = glyph(chip, "sparkles", 16, P.white, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ZIndex = 73 })
  local noteTitle = text(note, "", 13, "bold", { Position = UDim2.fromOffset(50, 9), Size = UDim2.new(1, -62, 0, 17), ZIndex = 72 })
  local noteText = text(note, "", 11, "medium", { Position = UDim2.fromOffset(50, 27), Size = UDim2.new(1, -62, 0, 14), TextColor3 = P.dim, ZIndex = 72 })
  local click = hit(frame, { ZIndex = 75 })
  click.Activated:Connect(B.safe("novoline.island", function()
    if island.showing then island.showing.gone = true end
    N.show(true)
  end))
  island = { frame = frame, idle = idle, song = song, note = note, queue = {}, sizer = sizer }
  local level, peak = 0, 4
  local spin = 0
  local coverKey
  local function shape(width, height)
    if island.width ~= width or island.height ~= height then
      island.width, island.height = width, height
      tween(frame, OPEN_INFO, { Size = UDim2.fromOffset(width, height) })
    end
  end
  Motion.every(function(dt)
    local wanted = islandWanted()
    frame.Visible = wanted
    if not wanted then return end
    local camera = workspace.CurrentCamera
    sizer.Scale = math.clamp((camera and camera.ViewportSize.Y or 900) / 1080, 0.8, 1.1) * ((Config.get("app.scale") or 100) / 100)
    frame.Position = UDim2.new(0.5, 0, 0, 10)
    local M = nil -- (audio stub: no music controller)
    local message = island.showing
    if message and (message.gone or os.clock() > message.till) then island.showing = nil; message = nil end
    if not message and #island.queue > 0 then
      message = table.remove(island.queue, 1)
      message.till = os.clock() + (message.time or 3)
      island.showing = message
      noteTitle.Text, noteText.Text = message.title or "", message.text or ""
      UI.setIcon(chipIcon, message.icon or "sparkles")
      local tone = message.tone
      chip.BackgroundColor3 = tone == "bad" and P.danger or (tone == "warn" and rgb(244, 180, 95) or (tone == "ok" and P.good or accent()))
    end
    local ctl = M and M.front()
    local playing = ctl ~= nil and ctl.track() ~= nil and ctl.state() ~= "idle" and Config.get("music.island") ~= false
    idle.Visible = not message and not playing
    song.Visible = not message and playing == true
    note.Visible = message ~= nil
    if message then
      shape(math.clamp(64 + math.max(#(message.title or ""), #(message.text or "")) * 6.4, 240, 380), (message.text and message.text ~= "") and 48 or 40)
    elseif playing then
      local track = ctl.track()
      -- a line being sung: the row of words (it says how wide it wants the island)
      local want, singing = 300, false
      if lyricRow then want, singing = lyricRow.step(dt, ctl) end
      if lyricRow then lyricRow.frame.Visible = singing end
      for _, part in ipairs(plainParts) do part.Visible = not singing end
      shape(singing and math.floor(want + 0.5) or 300, 40)
      if songName then songName.set(track.title); songName.step(dt) end
      songWho.Text = ctl.status() or track.artist
      if coverKey ~= track.key then coverKey = track.key; ctl.cover(track, art) end
      local live = ctl.state() == "playing"
      if live then spin = (spin + dt * 120) % 360 end
      art.Rotation = spin
      local raw = live and ctl.loudness() or 0
      peak = math.max(peak * (1 - math.min(dt * 0.35, 1)), raw, 4)
      local loud = live and math.clamp(raw / peak * 1.05, 0, 1.15) or 0
      level = level +  (loud - level) * math.min(dt * 12, 1)
      local now = os.clock()
      for i, bar in ipairs(bars) do
        local wobble = 0.45 + 0.55 * math.abs(math.sin(now * (3.1 + i * 0.9) + i))
        bar.Size = UDim2.fromOffset(4, math.clamp(4 + level * 18 * wobble, 4, 22))
      end
    else
      shape(196, 36)
      local fps = math.floor(workspace:GetRealPhysicsFPS() + 0.5) -- (B.Hud stub)
      stats.Text = string.format("%d fps · — ms", fps)
    end
  end, nil, "novoline.island")
end
function N.island() if N.gui then makeIsland() end end
-- messages go into the island while this look is in use
Window.toastHook = function(opts)
  if not (N.built and islandWanted() and island) then return nil end
  -- (opts.music special-case removed: no music module)
  local message = { title = opts.title, text = opts.text, icon = opts.icon, tone = opts.tone, time = opts.time or 3.2 }
  island.queue[#island.queue + 1] = message
  while #island.queue > 4 do table.remove(island.queue, 1) end
  nvSound("notify")
  return function() message.gone = true end
end
-- ---------------------------------------------------------------- notify entry point (clean signature)
-- B.Island:Notify({ title = "...", text = "...", icon = "...", tone = "ok|warn|bad", time = seconds })
-- Pushes a message directly into the island queue (same path as Window.toast).
B.Island = B.Island or {}
function B.Island.Notify(opts)
  if not (island and islandWanted()) then return function() end end
  local message = { title = opts.title, text = opts.text, icon = opts.icon, tone = opts.tone, time = opts.time or 3.2 }
  island.queue[#island.queue + 1] = message
  while #island.queue > 4 do table.remove(island.queue, 1) end
  nvSound("notify")
  return function() message.gone = true end
end

-- ---------------------------------------------------------------- the key list, drawn this way
function N.keyPanel(parent)
  local panel = box(parent, { Name = "KeysNovoline", Size = UDim2.fromOffset(0, 0), AutomaticSize = Enum.AutomaticSize.XY })
  glass(panel, 18)
  local least = Instance.new("UISizeConstraint"); least.MinSize = Vector2.new(200, 0); least.Parent = panel
  local stack = box(panel, { Size = UDim2.fromOffset(0, 0), AutomaticSize = Enum.AutomaticSize.XY, ZIndex = 2 })
  pad(stack, 12, 14, 12, 14)
  list(stack, 6)
  local head = box(stack, { Size = UDim2.fromOffset(0, 18), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 0, ZIndex = 2 })
  local title = text(head, "Keybinds", 13, "bold", { Size = UDim2.fromOffset(0, 18), AutomaticSize = Enum.AutomaticSize.X, ZIndex = 3 })
  local body = box(stack, { Size = UDim2.fromOffset(0, 0), AutomaticSize = Enum.AutomaticSize.XY, LayoutOrder = 1, ZIndex = 2 })
  list(body, 4)
  local api = { frame = panel, rows = {}, shape = nil }
  -- (lit: the key chip turns white, the name bright, a soft wash behind the row; all of it fades)
  local function light(row, on, animate)
    row.on = on
    local goal = { chip = on and P.on or P.raised, key = on and P.knobOn or P.sub, name = on and P.text or P.dim, wash = on and 0.93 or 1 }
    if animate and not Motion.reduced then
      tween(row.chip, SWITCH_INFO, { BackgroundColor3 = goal.chip })
      tween(row.key, SWITCH_INFO, { TextColor3 = goal.key })
      tween(row.name, SWITCH_INFO, { TextColor3 = goal.name })
      tween(row.wash, SWITCH_INFO, { BackgroundTransparency = goal.wash })
      if on then
        row.pop.Scale = 1.2
        Motion.to(row.pop, "Scale", 1, "bouncy")
      end
    else
      row.chip.BackgroundColor3, row.key.TextColor3, row.name.TextColor3, row.wash.BackgroundTransparency = goal.chip, goal.key, goal.name, goal.wash
    end
  end
  function api.forget() api.shape = nil end
  function api.render(binds, moving)
    -- (B.Keys.shape stub: compute a simple signature of the binds list)
    local sigParts = {}
    for _, b in ipairs(binds) do sigParts[#sigParts + 1] = tostring(b.id) .. ":" .. tostring(b.key) .. ":" .. tostring(b.on) .. ":" .. tostring(b.mode) end
    local shape = tostring(moving) .. "|" .. table.concat(sigParts, ",")
    if shape == api.shape then
      for _, bind in ipairs(binds) do
        local row = api.rows[bind.id]
        if row and row.on ~= bind.on then light(row, bind.on, true) end
      end
      return
    end
    api.shape = shape
    local before = {}
    for id, row in pairs(api.rows) do before[id] = row.on end
    table.clear(api.rows)
    for _, child in ipairs(body:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
    title.Text = moving and "Keybinds  ·  drag, then lock" or "Keybinds"
    if #binds == 0 then
      text(body, "Nothing bound yet", 12, "medium", { Size = UDim2.fromOffset(0, 16), AutomaticSize = Enum.AutomaticSize.X, TextColor3 = P.faint, LayoutOrder = 1, ZIndex = 3 })
      return
    end
    for index, bind in ipairs(binds) do
      if index > 12 then
        text(body, "+" .. (#binds - 12) .. " more", 11, "medium", { Size = UDim2.fromOffset(0, 16), AutomaticSize = Enum.AutomaticSize.X, TextColor3 = P.faint, LayoutOrder = index, ZIndex = 3 })
        break
      end
      local line = box(body, { Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = index, ZIndex = 3 })
      local wash = box(line, { Size = UDim2.new(1, 10, 1, 2), Position = UDim2.fromOffset(-5, -1), BackgroundColor3 = P.white, BackgroundTransparency = 1, ZIndex = 2 })
      round(wash, 8)
      local inner = box(line, { Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X, ZIndex = 3 })
      list(inner, 8, true)
      local chip = box(inner, { Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = P.raised, BackgroundTransparency = 0, LayoutOrder = 1, ZIndex = 3 })
      round(chip, true)
      pad(chip, 0, 7, 0, 7)
      local pop = Instance.new("UIScale"); pop.Parent = chip
      local key = text(chip, Config.keyLabel(bind.key), 10, "bold", { Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X, TextColor3 = P.sub, ZIndex = 4 })
      local name = text(inner, bind.label, 12, "medium", { Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 2, TextColor3 = P.dim, ZIndex = 3 })
      if bind.kind == "toggle" and bind.mode == "hold" then
        text(inner, "hold", 10, "medium", { Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 3, TextColor3 = P.faint, ZIndex = 3 })
      end
      local row = { chip = chip, key = key, name = name, wash = wash, pop = pop }
      api.rows[bind.id] = row
      local was = before[bind.id]
      light(row, was == nil and bind.on or was, false)
      if was ~= nil and was ~= bind.on then light(row, bind.on, true) end
    end
  end
  return api
end

-- ---------------------------------------------------------------- switching to it, and back
-- Novoline's pieces, for the panels of other files drawn in this look (another file's)
N.parts = { P = P, TINT = TINT, box = box, round = round, rim = rim, text = text, entryBox = entryBox, hit = hit, glyph = glyph, list = list, pad = pad,
  glass = glass, tile = tile, tween = tween, HOVER = HOVER_INFO }
function N.start()
  Config.define("app.novoline.toggleKey", "RightControl") -- toggle key (configurable)
  Config.define("app.novoline.accent", ACCENT)
  Config.define("app.novoline.font", "gotham")
  Config.define("app.novoline.size", 100)
  Config.define("app.novoline.dock", false)
  Config.define("app.novoline.island", true)
  Config.define("app.novoline.shade", 100)
  Config.define("app.novoline.x", -1)
  Config.define("app.novoline.y", -1)
  Config.define("app.novoline.px", -1)
  Config.define("app.novoline.py", -1)
  Config.define("app.novoline.w", W)
  Config.define("app.novoline.h", H)
  for _, id in ipairs({ "app.novoline.x", "app.novoline.y", "app.novoline.px", "app.novoline.py", "app.novoline.w", "app.novoline.h" }) do Config.unshared(id) end
  Config.on("app.gui", function(look)
    if look == "novoline" then
      Window.show(false)
      N.show(true)
      N.island()
    elseif N.built then
      N.show(false)
      if N.bar then N.bar.Visible = false end
    end
  end)
  Config.on("app.novoline.accent", repaint)
  Config.on("app.novoline.font", function() refont() end)
  Config.on("app.novoline.size", function() if N.rescale then N.rescale() end end)
  Config.on("app.scale", function() if N.rescale then N.rescale() end end)
  Config.on("app.novoline.dock", function(keep)
    if not N.built or N.open or not N.active() then return end
    N.bar.Visible = keep == true
    if keep then N.paintNav(true) end
  end)
  -- a tab added or taken away later (a game's tabs) shows up here as well
  local rebuildNav = Window.rebuildNav
  Window.rebuildNav = function(...)
    rebuildNav(...)
    if N.built then N.rebuildTabs() end
  end
  -- toggle key (RightControl by default; configurable via app.novoline.toggleKey)
  B.connect(UIS.InputBegan, function(input, gpe)
    if gpe or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if not N.active() then return end
    local want = Config.get("app.novoline.toggleKey") or "RightControl"
    if tostring(input.KeyCode) == "Enum.KeyCode." .. want then N.toggle() end
  end)
end


-- ============================================================================
--  activation + public API wrapper
--  Novoline's kit (Window.kits.novoline) renders every control with full
--  fidelity; this wrapper only creates the data-model entries and replays
--  them inside each page's build(entry) hook.
-- ============================================================================
local N = B.Novoline
local Config = B.Config
local Window = B.Window

-- wire input (toggle key) + config listeners once
if not N._started then
  N._started = true
  N.start()
end

-- active look resolves to novoline (Window.activeKit() returns
-- Window.kits[Window.look()] == Window.kits.novoline once app.gui is set)
local function activateLook()
  if Config.get("app.gui") ~= "novoline" then
    Config.set("app.gui", "novoline") -- N.start's listener: N.show(true) + N.island()
  end
  if N.built then
    N.rebuildTabs()
    N.island()
  end
end

-- small helpers
local _uid = 0
local function uid()
  _uid = _uid + 1
  return "u" .. tostring(_uid)
end
local function slug(name)
  local s = string.gsub(tostring(name or "tab"), "[^%w]+", "_"):lower()
  if s == "" or string.match(s, "^%d") then s = "tab_" .. s end
  return s
end
local function flagOf(opts, prefix)
  if opts and opts.Flag then return tostring(opts.Flag) end
  return prefix .. "_" .. uid()
end
local function toColor3(v)
  if typeof and typeof(v) == "Color3" then return v end
  if type(v) == "table" and v.r ~= nil then
    return Color3.fromRGB((v.r or 255), (v.g or 255), (v.b or 255))
  end
  if type(v) == "table" and v[1] ~= nil then
    return Color3.fromRGB(v[1], v[2], v[3])
  end
  return Color3.new(1, 1, 1)
end
local function toKeyName(v)
  if v == nil then return "None" end
  if typeof and typeof(v) == "EnumItem" then return string.gsub(tostring(v), "^Enum%.KeyCode%.", "") end
  return tostring(v)
end

-- a recorded control holds its spec + the proxy handed to the user; when the
-- page is built (replay), the real Novoline control api is stored on proxy._b
-- so Set/Get/SetText keep working afterwards.
local function controlProxy(id, kind)
  local p = { _b = nil, id = id, kind = kind }
  function p:Get()
    if p._b and p._b.get then return p._b.get() end
    if id then return Config.get(id) end
    return nil
  end
  function p:Set(v)
    if p._b and p._b.set then p._b.set(v); return end
    if id then Config.set(id, v) end
  end
  function p:OnChanged(fn)
    if id then Config.on(id, fn) end
  end
  function p:SetText(t)
    if p._b and p._b.setText then p._b.setText(t) end
  end
  return p
end

local function makeSectionProxy()
  local sec = { name = "", controls = {} }
  local function record(method, spec, id, kind)
    local proxy = controlProxy(id, kind)
    table.insert(sec.controls, { method = method, spec = spec, proxy = proxy })
    return proxy
  end

  function sec:CreateToggle(opts)
    opts = opts or {}
    local id = flagOf(opts, "toggle")
    local def = opts.Default == true
    Config.define(id, def)
    return record("toggle", { id = id, label = opts.Name or "Toggle", default = def,
      desc = opts.Desc, tip = opts.Tip, changed = opts.Callback }, id, "toggle")
  end

  function sec:CreateButton(opts)
    opts = opts or {}
    local id = opts.Flag and flagOf(opts, "button") or nil
    if id then Config.define(id, false) end
    return record("button", { id = id, label = opts.Name or "Button", text = opts.Text,
      desc = opts.Desc, tip = opts.Tip, style = opts.Style, run = opts.Callback }, id, "button")
  end

  function sec:CreateSlider(opts)
    opts = opts or {}
    local id = flagOf(opts, "slider")
    local minV = opts.Min or 0
    local maxV = opts.Max or 100
    local def = opts.Default or minV
    Config.define(id, def)
    return record("slider", { id = id, label = opts.Name or "Slider", min = minV, max = maxV,
      step = opts.Step or 1, default = def, suffix = opts.Suffix, format = opts.Format,
      desc = opts.Desc, tip = opts.Tip, changed = opts.Callback }, id, "slider")
  end

  function sec:CreateDropdown(opts)
    opts = opts or {}
    local id = flagOf(opts, "dropdown")
    local multi = opts.Multi == true
    local def = multi and (opts.Default or {}) or opts.Default
    Config.define(id, def)
    local method = multi and "multi" or "dropdown"
    return record(method, { id = id, label = opts.Name or "Dropdown", options = opts.Options or {},
      default = def, empty = opts.Empty or "None", desc = opts.Desc, tip = opts.Tip,
      changed = opts.Callback }, id, method)
  end

  function sec:CreateColorPicker(opts)
    opts = opts or {}
    local id = flagOf(opts, "color")
    local def = toColor3(opts.Default)
    Config.define(id, def)
    return record("color", { id = id, label = opts.Name or "Colour", default = def,
      desc = opts.Desc, tip = opts.Tip, changed = opts.Callback }, id, "color")
  end

  function sec:CreateKeybind(opts)
    opts = opts or {}
    local id = flagOf(opts, "keybind")
    local def = toKeyName(opts.Default)
    Config.define(id, def)
    return record("keybind", { id = id, label = opts.Name or "Keybind", default = def,
      desc = opts.Desc, tip = opts.Tip, changed = opts.Callback }, id, "keybind")
  end

  function sec:CreateTextbox(opts)
    opts = opts or {}
    local id = flagOf(opts, "textbox")
    local def = opts.Default ~= nil and tostring(opts.Default) or ""
    Config.define(id, def)
    return record("input", { id = id, label = opts.Name or "Text", default = def,
      placeholder = opts.Placeholder, numeric = opts.Numeric == true, desc = opts.Desc,
      tip = opts.Tip, changed = opts.Callback }, id, "input")
  end

  function sec:CreateLabel(text)
    return record("label", { text = tostring(text or "") }, nil, "label")
  end

  return sec
end

local function makeTabProxy(name)
  local tab = { name = name, sections = {} }
  tab.id = slug(name) .. "_" .. uid()

  -- replay: called by Novoline's tabDeck (entry = novoline Page) and, if the
  -- based look were ever active, by foundation's ensureBuilt (entry = page).
  local function replay(entry)
    for _, secRec in ipairs(tab.sections) do
      local entrySec = entry:section({ title = secRec.name, icon = secRec.icon })
      for _, cop in ipairs(secRec.controls) do
        local built
        if cop.method == "label" then
          if entrySec.label then
            built = entrySec:label(cop.spec.text)
          elseif entrySec.note then
            built = entrySec:note({ text = cop.spec.text })
          end
        elseif entrySec[cop.method] then
          built = entrySec[cop.method](entrySec, cop.spec)
        end
        cop.proxy._b = built
      end
    end
  end

  Window.page({
    id = tab.id,
    title = name,
    icon = tab.icon,
    build = replay,
  })
  if not Window.startPage then
    Window.startPage = tab.id
  end
  if N.built then
    N.rebuildTabs()
  end

  function tab:CreateSection(name)
    local sec = makeSectionProxy()
    sec.name = name or "Section"
    table.insert(tab.sections, sec)
    return sec
  end
  return tab
end

-- ============================================================================
--  PUBLIC API
-- ============================================================================
local Library = {}
local _window = nil

function Library:CreateWindow(opts)
  opts = opts or {}
  if _window then return _window end
  local window = { Name = opts.Name or "Menu", tabs = {} }

  function window:CreateTab(name)
    local tab = makeTabProxy(name)
    table.insert(self.tabs, tab)
    return tab
  end
  function window:Toggle() N.toggle() end
  function window:Show(on) N.show(on == true) end
  function window:SetToggleKey(key) Config.set("app.novoline.toggleKey", tostring(key or "RightControl")) end
  function window:SetAccent(color) Config.set("app.novoline.accent", toColor3(color)) end

  _window = window
  -- open shortly after: the caller creates tabs/sections synchronously, so a
  -- short delay lets the dock show every tab on first build.
  task.delay(0.15, function()
    if #window.tabs > 0 then
      activateLook()
      if not N.open then N.show(true) end
    end
  end)
  return window
end

function Library:Notify(opts)
  opts = opts or {}
  local wasOpen = N.open
  activateLook() -- first call builds the GUI + island (and opens the menu)
  if not wasOpen and N.open then
    N.show(false) -- keep the menu closed; the island stays visible for messages
  end
  if B.Island and B.Island.Notify then
    return B.Island.Notify({
      title = opts.Title,
      text = opts.Text,
      icon = opts.Icon,
      tone = opts.Tone or "ok",
      time = opts.Duration or 3.2,
    })
  end
  if Window.toast then
    return Window.toast({ title = opts.Title, text = opts.Text, tone = opts.Tone, time = opts.Duration })
  end
  return function() end
end

function Library:SetToggleKey(key) Config.set("app.novoline.toggleKey", tostring(key or "RightControl")) end
function Library:Toggle() N.toggle() end
function Library:Show(on) N.show(on == true) end

return Library
