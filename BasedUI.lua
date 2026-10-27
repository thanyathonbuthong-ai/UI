--[[
  BasedUI  ·  glass UI library
  Extracted from the BASED / ARBIX Hub script (modules 00 kernel, 01 motion, 02 theme, 03 assets,
  04 ui, 05 config, 06 controls, 07 window) and made standalone: no hub code needed.

  Quick start
    local Lib = loadstring(readfile("BasedUI.lua"))()      -- or loadstring(game:HttpGet(url))()
    local Win = Lib:CreateWindow({ Name = "ARBIX", Sub = "hub", Key = Enum.KeyCode.V })
    local Tab = Win:AddTab({ Title = "Combat", Icon = "crosshair", Group = "Main" })
    local Sec = Tab:AddSection({ Title = "Aim", Icon = "target", Desc = "Camera aim assist" })
    Sec:AddToggle({ Id = "aim.on", Label = "Enabled", Default = false, Callback = function(v) end })
    Sec:AddSlider({ Id = "aim.fov", Label = "FOV", Min = 10, Max = 360, Default = 100, Suffix = "°" })
    Win:Show(true)

  Same look as the original with the original font / icon / texture files: put the hub's
  BasedHub/ folder (fonts/, img/, sfx/) in your executor workspace and pass  AssetRoot = "BasedHub".
  Without it the library falls back to Roblox fonts and text-glyph icons.
]]

local Library = { VERSION = "1.0.0", Flags = {} }
Library.__index = Library

local genv = (type(getgenv) == "function" and getgenv()) or _G
if type(genv.BasedUI) == "table" and type(genv.BasedUI.Unload) == "function" then
  pcall(genv.BasedUI.Unload, genv.BasedUI)
end
genv.BasedUI = Library
Library.alive = true

-- ============================================================================ kernel
local cloneref = type(cloneref) == "function" and cloneref or function(x) return x end
local S = setmetatable({}, { __index = function(t, name)
  local ok, service = pcall(game.GetService, game, name)
  if not ok or not service then error("BasedUI: no service " .. tostring(name), 2) end
  service = cloneref(service)
  rawset(t, name, service)
  return service
end })
Library.S = S
local LP = S.Players.LocalPlayer
local UIS = S.UserInputService

local Signal = {}
Signal.__index = Signal
function Signal.new() return setmetatable({ list = {} }, Signal) end
function Signal:connect(fn)
  local link = { fn = fn, live = true }
  local list = self.list
  list[#list + 1] = link
  return { disconnect = function()
    if not link.live then return end
    link.live = false
    local at = table.find(list, link)
    if at then table.remove(list, at) end
  end }
end
function Signal:fire(...)
  local list = self.list
  if #list == 0 then return end
  for _, link in ipairs(table.clone(list)) do
    if link.live then Library.try("signal", link.fn, ...) end
  end
end

Library.faults = {}
function Library.fault(scope, err)
  local faults = Library.faults
  faults[#faults + 1] = { scope = tostring(scope), message = tostring(err) }
  if #faults > 60 then table.remove(faults, 1) end
  warn("[BasedUI] " .. tostring(scope) .. ": " .. tostring(err))
end
local function trace(e) return tostring(e) .. "\n" .. debug.traceback("", 2) end
function Library.try(scope, fn, ...)
  local result = table.pack(xpcall(fn, trace, ...))
  if not result[1] then Library.fault(scope, result[2]); return nil end
  return table.unpack(result, 2, result.n)
end
function Library.safe(scope, fn)
  return function(...) return Library.try(scope, fn, ...) end
end
local B = Library          -- (the original code calls these B.try / B.safe / B.own ...)

local owned = {}
function Library.own(thing) owned[#owned + 1] = thing; return thing end
function Library.connect(signal, fn, scope)
  return Library.own(signal:Connect(Library.safe(scope or "event", fn)))
end
Library.onUnload = Signal.new()
function Library:Unload()
  if not Library.alive then return end
  Library.alive = false
  pcall(function() Library.onUnload:fire() end)
  for index = #owned, 1, -1 do
    local thing = owned[index]
    pcall(function()
      local kind = typeof(thing)
      if kind == "RBXScriptConnection" then thing:Disconnect()
      elseif kind == "Instance" then thing:Destroy()
      elseif kind == "function" then thing() end
    end)
  end
  table.clear(owned)
  if genv.BasedUI == Library then genv.BasedUI = nil end
end

-- files (optional: config profiles and the original asset folder)
local fs = {}
fs.ok = type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
  and type(makefolder) == "function" and type(isfolder) == "function"
function fs.exists(path) if not fs.ok then return false end local ok, v = pcall(isfile, path); return ok and v == true end
function fs.isdir(path) if not fs.ok then return false end local ok, v = pcall(isfolder, path); return ok and v == true end
function fs.mkdir(path)
  if not fs.ok then return false end
  local built = ""
  for part in string.gmatch(path, "[^/\\]+") do
    built = built == "" and part or (built .. "/" .. part)
    if not fs.isdir(built) then pcall(makefolder, built) end
  end
  return fs.isdir(path)
end
function fs.read(path) if not fs.exists(path) then return nil end local ok, d = pcall(readfile, path); return ok and d or nil end
function fs.write(path, data)
  if not fs.ok then return false end
  local folder = string.match(path, "^(.*)[/\\][^/\\]+$")
  if folder and not fs.isdir(folder) then fs.mkdir(folder) end
  return (pcall(writefile, path, data))
end

-- helpers
local util = {}
function util.clamp01(x) return x < 0 and 0 or (x > 1 and 1 or x) end
function util.lerp(a, b, t) return a + (b - a) * t end
function util.round(x, step) step = step or 1; return math.floor(x / step + 0.5) * step end
function util.hex(text)
  text = string.gsub(text, "#", "")
  return Color3.fromRGB(tonumber(string.sub(text, 1, 2), 16), tonumber(string.sub(text, 3, 4), 16), tonumber(string.sub(text, 5, 6), 16))
end
function util.toHex(color)
  return string.format("%02X%02X%02X", math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
end
function util.luma(color) return 0.2126 * color.R + 0.7152 * color.G + 0.0722 * color.B end
function util.format(value, decimals)
  if decimals and decimals > 0 then return string.format("%." .. decimals .. "f", value) end
  return tostring(math.floor(value + 0.5))
end
function util.keys(t) local out = {}; for k in pairs(t) do out[#out + 1] = k end; return out end
function util.fuzzy(query, text)
  query, text = string.lower(query), string.lower(text)
  if query == "" then return 0 end
  local score, at, run = 0, 1, 0
  for i = 1, #query do
    local ch = string.sub(query, i, i)
    local found = string.find(text, ch, at, true)
    if not found then return nil end
    if found == at then run += 1; score += 2 + run else run = 0 end
    if found == 1 or string.find(string.sub(text, found - 1, found - 1), "[%s%p]") then score += 3 end
    score -= (found - at) * 0.05
    at = found + 1
  end
  return score - #text * 0.01
end
function util.randomName()
  local chars = {}
  for i = 1, 12 do chars[i] = string.char(math.random(97, 122)) end
  return table.concat(chars)
end
Library.util = util

B.touch = false
pcall(function() B.touch = UIS.TouchEnabled and not UIS.MouseEnabled end)
function B.viewport()
  local camera = workspace.CurrentCamera
  return camera and camera.ViewportSize or Vector2.new(1920, 1080)
end
function B.host()
  if B._host and B._host.Parent then return B._host end
  local host
  if type(gethui) == "function" then
    local ok, hidden = pcall(gethui)
    if ok and typeof(hidden) == "Instance" then host = hidden end
  end
  if not host then
    local ok, core = pcall(function() return cloneref(game:GetService("CoreGui")) end)
    if ok and core and pcall(function() return core.Name end) then host = core end
  end
  if not host and LP then host = LP:FindFirstChildOfClass("PlayerGui") or LP:WaitForChild("PlayerGui", 5) end
  B._host = host
  return host
end
B.screens = {}
function B.screen(order, name)
  local gui = Instance.new("ScreenGui")
  table.insert(B.screens, gui)
  gui.Name = name or util.randomName()
  gui.ResetOnSpawn = false
  gui.IgnoreGuiInset = true
  gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
  gui.DisplayOrder = order or 9000
  pcall(function() gui.ScreenInsets = Enum.ScreenInsets.None end)
  pcall(function() gui.ClipToDeviceSafeArea = false end)
  gui.Parent = B.host()
  return B.own(gui)
end

-- ============================================================================ motion
-- One render loop: analytic springs, timelines, jobs (01_motion).
local Motion = { speed = 1, reduced = false }
Library.Motion = Motion
Motion.presets = {
  quick = { 0.16, 0 }, snappy = { 0.24, 0.10 }, smooth = { 0.34, 0 }, gentle = { 0.52, 0 },
  bouncy = { 0.40, 0.24 }, liquid = { 0.46, 0.30 }, lazy = { 0.90, 0 },
}
local awake, stepping, jobs, tweens = {}, {}, {}, {}

local Spring = {}
Spring.__index = Spring
local function tune(spring, preset)
  local p = type(preset) == "table" and preset or Motion.presets[preset or "smooth"] or Motion.presets.smooth
  local duration, bounce = p[1], p[2] or 0
  if Motion.reduced then duration, bounce = duration * 0.55, 0 end
  duration = math.max(duration / Motion.speed, 0.02)
  spring.w0 = 2 * math.pi / duration
  spring.zeta = math.clamp(1 - bounce, 0.08, 1)
end
function Motion.spring(n, preset, onStep, eps)
  local spring = setmetatable({ n = n, x = table.create(n, 0), v = table.create(n, 0), g = table.create(n, 0),
    onStep = onStep, eps = eps or 0.001 }, Spring)
  tune(spring, preset)
  return spring
end
function Spring:snap(values)
  for i = 1, self.n do self.x[i], self.g[i], self.v[i] = values[i], values[i], 0 end
  awake[self] = nil
  if self.onStep then self.onStep(self.x) end
end
function Spring:to(values, preset)
  if preset then tune(self, preset) end
  local g = self.g
  for i = 1, self.n do g[i] = values[i] end
  awake[self] = true
end
function Spring:moving() return awake[self] == true end
function Spring:stop() awake[self] = nil end

local function stepSpring(spring, dt)
  local w0, zeta, eps = spring.w0, spring.zeta, spring.eps
  local x, v, g = spring.x, spring.v, spring.g
  local rest = true
  if zeta < 0.999 then
    local wd = w0 * math.sqrt(1 - zeta * zeta)
    local decay = math.exp(-zeta * w0 * dt)
    local c, s = math.cos(wd * dt), math.sin(wd * dt)
    for i = 1, spring.n do
      local a = x[i] - g[i]
      local b = (v[i] + zeta * w0 * a) / wd
      local y = decay * (a * c + b * s)
      local nv = decay * ((b * wd - a * zeta * w0) * c - (a * wd + b * zeta * w0) * s)
      x[i], v[i] = g[i] + y, nv
      local tolerance = type(eps) == "table" and eps[i] or eps
      if rest and (math.abs(y) > tolerance or math.abs(nv) > tolerance * 20) then rest = false end
    end
  else
    local decay = math.exp(-w0 * dt)
    for i = 1, spring.n do
      local a = x[i] - g[i]
      local k = v[i] + w0 * a
      local y = decay * (a + k * dt)
      local nv = decay * (v[i] - k * w0 * dt)
      x[i], v[i] = g[i] + y, nv
      local tolerance = type(eps) == "table" and eps[i] or eps
      if rest and (math.abs(y) > tolerance or math.abs(nv) > tolerance * 20) then rest = false end
    end
  end
  if rest then
    for i = 1, spring.n do x[i], v[i] = g[i], 0 end
    awake[spring] = nil
  end
  if spring.onStep then spring.onStep(x) end
  if rest and spring.onRest then
    local done = spring.onRest
    spring.onRest = nil
    done()
  end
end

local PX, UNIT = 0.08, 0.0008
local packers = {
  number = { 1, function(value) return { value } end, function(x) return x[1] end, UNIT },
  UDim2 = { 4, function(value) return { value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset } end,
    function(x) return UDim2.new(x[1], x[2], x[3], x[4]) end, { UNIT, PX, UNIT, PX } },
  UDim = { 2, function(value) return { value.Scale, value.Offset } end, function(x) return UDim.new(x[1], x[2]) end, { UNIT, PX } },
  Vector2 = { 2, function(value) return { value.X, value.Y } end, function(x) return Vector2.new(x[1], x[2]) end, UNIT },
  Color3 = { 3, function(value) return { value.R, value.G, value.B } end,
    function(x) return Color3.new(util.clamp01(x[1]), util.clamp01(x[2]), util.clamp01(x[3])) end, 0.002 },
}
local unitProps = { BackgroundTransparency = true, TextTransparency = true, ImageTransparency = true, Transparency = true,
  GroupTransparency = true, TextStrokeTransparency = true, ScrollBarImageTransparency = true }

local bound = setmetatable({}, { __mode = "k" })
function Motion.to(instance, property, target, preset, done)
  local packer = packers[typeof(target)]
  if not packer then instance[property] = target; if done then done() end; return nil end
  local map = bound[instance]
  if not map then map = {}; bound[instance] = map end
  local spring = map[property]
  if not spring then
    local unpack, clampUnit = packer[3], unitProps[property]
    spring = Motion.spring(packer[1], preset, function(x)
      local value = unpack(x)
      if clampUnit then value = util.clamp01(value) end
      instance[property] = value
    end, packer[4])
    local current = packer[2](instance[property])
    for i = 1, spring.n do spring.x[i], spring.g[i] = current[i], current[i] end
    map[property] = spring
  end
  spring.onRest = done
  spring:to(packer[2](target), preset)
  return spring
end
function Motion.snap(instance, property, value)
  local map = bound[instance]
  local spring = map and map[property]
  local packer = packers[typeof(value)]
  if spring and packer then
    spring.onRest = nil
    spring:snap(packer[2](value))
  else
    instance[property] = value
  end
end

local ease = {}
function ease.linear(t) return t end
function ease.outCubic(t) return 1 - (1 - t) ^ 3 end
Motion.ease = ease
function Motion.tween(duration, curve, step, done)
  local tween = { t = 0, duration = math.max(duration / Motion.speed, 0.001), curve = curve or ease.outCubic, step = step, done = done }
  tweens[#tweens + 1] = tween
  function tween.cancel() tween.dead = true end
  step(tween.curve(0))
  return tween
end
function Motion.every(fn, hz, scope)
  local job = { fn = fn, interval = hz and 1 / hz or 0, acc = 0, scope = scope or "job" }
  jobs[#jobs + 1] = job
  function job.cancel() job.dead = true end
  return job
end

local function frame(dt)
  if not Library.alive then return end
  dt = math.min(dt, 0.1)
  local springCount = 0
  for spring in pairs(awake) do springCount += 1; stepping[springCount] = spring end
  for index = 1, springCount do
    local spring = stepping[index]
    stepping[index] = nil
    if awake[spring] then
      local ok, err = pcall(stepSpring, spring, dt)
      if not ok then awake[spring] = nil; Library.fault("spring", err) end
    end
  end
  local count = #tweens
  for index = count, 1, -1 do
    local tween = tweens[index]
    if tween.dead then
      table.remove(tweens, index)
    else
      tween.t += dt
      local p = util.clamp01(tween.t / tween.duration)
      local ok, err = pcall(tween.step, tween.curve(p))
      if not ok then tween.dead = true; Library.fault("tween", err) end
      if p >= 1 and not tween.dead then
        tween.dead = true
        table.remove(tweens, index)
        if tween.done then Library.try("tween.done", tween.done) end
      end
    end
  end
  count = #jobs
  for index = 1, count do
    local job = jobs[index]
    if job and not job.dead then
      local elapsed, run = dt, true
      if job.interval > 0 then
        job.acc += dt
        if job.acc < job.interval then run = false else elapsed = math.min(job.acc, 0.5); job.acc = 0 end
      end
      if run then
        local ok, err = pcall(job.fn, elapsed)
        if not ok then job.dead = true; Library.fault(job.scope, err) end
      end
    end
  end
  for index = #jobs, 1, -1 do
    if jobs[index].dead then table.remove(jobs, index) end
  end
end
B.own(S.RunService.RenderStepped:Connect(frame))

-- ============================================================================ theme
-- Surfaces are the scheme's ink at a low alpha over glass; Theme.bind keeps a property on a token.
local hex = util.hex
local Theme = { changed = Signal.new() }
Library.Theme = Theme
local T = {}
Library.T = T
Theme.schemes = {
  dark = { label = "Graphite", base = hex("0B0B0F"), ink = hex("F5F4EF"), sub = hex("A9A8B4"), faint = hex("6C6B77"),
    shadow = 0.42, fill = { 0.045, 0.075, 0.115 }, stroke = { 0.085, 0.16 }, dark = true },
  midnight = { label = "Midnight", base = hex("000000"), ink = hex("F5F4EF"), sub = hex("9E9DA9"), faint = hex("62616C"),
    shadow = 0.3, fill = { 0.055, 0.09, 0.13 }, stroke = { 0.10, 0.18 }, dark = true },
  light = { label = "Porcelain", base = hex("F3F2EE"), ink = hex("121216"), sub = hex("56555F"), faint = hex("8C8B95"),
    shadow = 0.72, fill = { 0.05, 0.08, 0.12 }, stroke = { 0.10, 0.18 }, dark = false },
}
Theme.schemeOrder = { "dark", "midnight", "light" }
Theme.accents = {
  { id = "ultraviolet", label = "Ultraviolet", color = hex("8E7DFF") },
  { id = "azure", label = "Azure", color = hex("4DA3FF") },
  { id = "mint", label = "Mint", color = hex("45DDA8") },
  { id = "ember", label = "Ember", color = hex("FF7A45") },
  { id = "rose", label = "Rose", color = hex("FF5C93") },
  { id = "gold", label = "Gold", color = hex("F2C14E") },
  { id = "blood", label = "Blood", color = hex("FF4B4B") },
  { id = "bone", label = "Bone", color = hex("EDEBE4") },
}
Theme.state = { scheme = "dark", accent = hex("8E7DFF"), glass = 0.6, radius = 1, blur = false }
-- type ramp: font key (resolved in Library.F) and size
Theme.type = {
  display = { "serifItalic", 34 }, title = { "serif", 25 }, heading = { "text600", 15 }, label = { "text500", 14 },
  body = { "text400", 13 }, caption = { "text400", 12 }, eyebrow = { "wideBold", 10 }, mono = { "mono400", 12 },
  monoBold = { "mono500", 12 }, button = { "text600", 13 }, brand = { "wideBlack", 18 },
}
local function resolve()
  local state = Theme.state
  local scheme = Theme.schemes[state.scheme] or Theme.schemes.dark
  local glass = util.clamp01(state.glass)
  T.dark = scheme.dark
  T.base, T.ink, T.sub, T.faint = scheme.base, scheme.ink, scheme.sub, scheme.faint
  local alpha = state.blur and util.lerp(0.5, 0.94, glass) or util.lerp(0.84, 0.975, glass)
  T.baseA = 1 - alpha
  T.panelA = 1 - util.lerp(0.34, 0.62, glass)
  T.fill1A, T.fill2A, T.fill3A = 1 - scheme.fill[1], 1 - scheme.fill[2], 1 - scheme.fill[3]
  T.strokeA, T.stroke2A = 1 - scheme.stroke[1], 1 - scheme.stroke[2]
  T.shadowA = scheme.shadow
  T.accent = state.accent
  T.accentInk = util.luma(state.accent) > 0.62 and hex("101014") or hex("FFFFFF")
  T.accentSoftA = 0.84
  T.accentDim = state.accent:Lerp(scheme.base, 0.55)
  T.ok, T.warn, T.bad = hex("52D6A0"), hex("F4B45F"), hex("FF6577")
  T.white, T.black = Color3.new(1, 1, 1), Color3.new(0, 0, 0)
  T.rim = Color3.new(1, 1, 1)
  T.rimA = scheme.dark and 0.5 or 0.1
  T.popover = scheme.base:Lerp(scheme.ink, scheme.dark and 0.07 or 0.0)
  local r = state.radius
  T.rWindow, T.rPanel, T.rCard, T.rControl, T.rSmall = math.floor(26 * r), math.floor(19 * r), math.floor(16 * r), math.floor(11 * r), math.floor(7 * r)
end
resolve()

local bindings, boundAt = {}, {}
function Theme.bind(instance, property, key, map)
  local list = bindings[instance]
  if not list then list = {}; bindings[instance] = list; boundAt[instance] = os.clock() end
  list[property] = { key, map }
  local value = T[key]
  if map then value = map(value, T) end
  instance[property] = value
  return instance
end
function Theme.unbind(instance, property)
  local list = bindings[instance]
  if list then list[property] = nil end
end
function Theme.sweep()
  local now = os.clock()
  for instance in pairs(bindings) do
    if instance.Parent == nil and now - boundAt[instance] > 5 then bindings[instance], boundAt[instance] = nil, nil end
  end
end
function Theme.apply()
  resolve()
  Theme.sweep()
  for instance, list in pairs(bindings) do
    for property, binding in pairs(list) do
      local value = T[binding[1]]
      if binding[2] then value = binding[2](value, T) end
      pcall(function() instance[property] = value end)
    end
  end
  Theme.changed:fire()
end
Motion.every(Theme.sweep, 1 / 20, "theme.sweep")
function Theme.set(changes)
  for key, value in pairs(changes) do Theme.state[key] = value end
  Theme.apply()
end

-- ============================================================================ assets
-- Optional: the hub's own files (BasedHub/fonts, img, sfx). Without them: Roblox fonts, glyph icons.
local Assets = { root = nil, ready = false }
Library.Assets = Assets
local FILE = {
  icons = "img/icons_aed91083.png",
  noise = "img/noise_b6e30457.png",
  sfx = { click = "sfx/bh_click.ogg", close = "sfx/bh_close.ogg", hover = "sfx/bh_hover.ogg", open = "sfx/bh_open.ogg",
    saved = "sfx/bh_saved.ogg", tab = "sfx/bh_tab.ogg", toggle_off = "sfx/bh_toggle_off.ogg", toggle_on = "sfx/bh_toggle_on.ogg" },
}
local ICON_CELL, ICON_COLS = 48, 20
local ICON_MAP = {
  ["house"]=0, ["layout-dashboard"]=1, ["gamepad-2"]=2, ["crosshair"]=3, ["eye"]=4, ["eye-off"]=5,
  ["wind"]=6, ["users"]=7, ["user"]=8, ["globe"]=9, ["earth"]=10, ["settings"]=11,
  ["settings-2"]=12, ["search"]=13, ["x"]=14, ["minus"]=15, ["plus"]=16, ["check"]=17,
  ["chevron-down"]=18, ["chevron-up"]=19, ["chevron-right"]=20, ["chevron-left"]=21, ["chevrons-up-down"]=22, ["ellipsis"]=23,
  ["sliders-horizontal"]=24, ["palette"]=25, ["keyboard"]=26, ["bell"]=27, ["save"]=28, ["download"]=29,
  ["upload"]=30, ["trash-2"]=31, ["copy"]=32, ["refresh-cw"]=33, ["rotate-ccw"]=34, ["power"]=35,
  ["shield"]=36, ["shield-check"]=37, ["zap"]=38, ["sparkles"]=39, ["film"]=40, ["clapperboard"]=41,
  ["volume-2"]=42, ["volume-x"]=43, ["play"]=44, ["pause"]=45, ["skip-forward"]=46, ["user-check"]=47,
  ["user-x"]=48, ["map-pin"]=49, ["navigation"]=50, ["target"]=51, ["scan"]=52, ["bone"]=53,
  ["heart-pulse"]=54, ["ruler"]=55, ["tag"]=56, ["plane"]=57, ["footprints"]=58, ["arrow-up"]=59,
  ["arrow-down"]=60, ["arrow-right"]=61, ["arrow-left"]=62, ["ghost"]=63, ["mouse-pointer-click"]=64, ["mouse-pointer-2"]=65,
  ["sun"]=66, ["moon"]=67, ["cloud-fog"]=68, ["clock"]=69, ["camera"]=70, ["monitor"]=71,
  ["gauge"]=72, ["wifi"]=73, ["server"]=74, ["link"]=75, ["log-out"]=76, ["shuffle"]=77,
  ["lock"]=78, ["lock-open"]=79, ["info"]=80, ["triangle-alert"]=81, ["circle-alert"]=82, ["circle-check"]=83,
  ["circle"]=84, ["star"]=85, ["pin"]=86, ["command"]=87, ["corner-down-left"]=88, ["hand"]=89,
  ["maximize-2"]=90, ["minimize-2"]=91, ["panel-left"]=92, ["layers"]=93, ["box"]=94, ["package"]=95,
  ["puzzle"]=96, ["code"]=97, ["terminal"]=98, ["flask-conical"]=99, ["wand-sparkles"]=100, ["swords"]=101,
  ["sword"]=102, ["rocket"]=103, ["flame"]=104, ["contrast"]=105, ["droplet"]=106, ["droplets"]=107,
  ["blend"]=108, ["type"]=109, ["history"]=110, ["folder"]=111, ["file-json"]=112, ["clipboard"]=113,
  ["clipboard-paste"]=114, ["external-link"]=115, ["grip-vertical"]=116, ["filter"]=117, ["list"]=118, ["grid-2x2"]=119,
  ["image"]=120, ["music"]=121, ["timer"]=122, ["activity"]=123, ["radar"]=124, ["focus"]=125,
  ["aperture"]=126, ["scan-eye"]=127, ["view"]=128, ["binoculars"]=129, ["locate"]=130, ["locate-fixed"]=131,
  ["route"]=132, ["compass"]=133, ["anchor"]=134, ["feather"]=135, ["square"]=136, ["square-dashed"]=137,
  ["person-standing"]=138, ["move"]=139, ["move-3d"]=140, ["orbit"]=141, ["trees"]=142, ["mountain"]=143,
  ["lightbulb"]=144, ["sunrise"]=145, ["bug"]=146, ["wrench"]=147, ["hammer"]=148, ["cpu"]=149,
  ["hard-drive"]=150, ["database"]=151, ["cloud"]=152, ["cloud-download"]=153, ["circle-dot"]=154, ["dot"]=155,
  ["badge-check"]=156, ["crown"]=157, ["gem"]=158, ["trophy"]=159, ["flag"]=160, ["bookmark"]=161,
  ["heart"]=162, ["skull"]=163, ["axe"]=164, ["bomb"]=165, ["car"]=166, ["leaf"]=167,
  ["snowflake"]=168, ["plug"]=169, ["radio"]=170, ["signal"]=171, ["fingerprint"]=172, ["key-round"]=173,
  ["key"]=174, ["door-open"]=175, ["app-window"]=176, ["fullscreen"]=177, ["expand"]=178, ["shrink"]=179,
  ["rotate-3d"]=180, ["scaling"]=181, ["pipette"]=182, ["paintbrush"]=183, ["brush"]=184, ["eraser"]=185,
  ["wand"]=186, ["magnet"]=187, ["waypoints"]=188, ["git-branch"]=189, ["share-2"]=190, ["send"]=191,
  ["message-circle"]=192, ["at-sign"]=193, ["hash"]=194, ["circle-user"]=195, ["user-round"]=196, ["users-round"]=197,
  ["id-card"]=198, ["megaphone"]=199, ["apple"]=200, ["tree-pine"]=201, ["sprout"]=202, ["glasses"]=203,
  ["scan-line"]=204, ["vibrate"]=205, ["proportions"]=206, ["ratio"]=207, ["spline"]=208, ["arrow-up-right"]=209,
  ["circle-play"]=210, ["circle-pause"]=211, ["circle-x"]=212, ["circle-plus"]=213, ["circle-minus"]=214, ["toggle-left"]=215,
  ["toggle-right"]=216, ["text-cursor-input"]=217, ["align-left"]=218, ["monitor-smartphone"]=219, ["smartphone"]=220, ["tablet"]=221,
  ["laptop"]=222, ["mouse"]=223, ["joystick"]=224, ["dices"]=225, ["swatch-book"]=226, ["sun-moon"]=227,
  ["paint-bucket"]=228, ["square-mouse-pointer"]=229, ["baseline"]=230, ["skip-back"]=231, ["repeat"]=232, ["repeat-1"]=233,
  ["list-plus"]=234, ["list-music"]=235, ["list-x"]=236, ["headphones"]=237, ["disc-3"]=238, ["library"]=239,
  ["layout-grid"]=240, ["audio-lines"]=241, ["folder-open"]=242, ["file-music"]=243, ["pencil"]=244, ["heart-off"]=245,
}

local ids = {}
local canRegister = type(getcustomasset) == "function" and fs.ok
function Assets.id(relative)
  local cached = ids[relative]
  if cached ~= nil then return cached or nil end
  if not Assets.root or not canRegister then ids[relative] = false; return nil end
  local path = Assets.root .. "/" .. relative
  if not fs.exists(path) then ids[relative] = false; return nil end
  local ok, id = pcall(getcustomasset, path)
  if not ok or type(id) ~= "string" or id == "" then ids[relative] = false; return nil end
  ids[relative] = id
  return id
end
function Assets.icon(name)
  local index = ICON_MAP[name]
  if not index then return nil end
  local id = Assets.id(FILE.icons)
  if not id then return nil end
  return id, Vector2.new((index % ICON_COLS) * ICON_CELL, math.floor(index / ICON_COLS) * ICON_CELL), Vector2.new(ICON_CELL, ICON_CELL)
end
function Assets.image(name) return name == "noise" and Assets.id(FILE.noise) or nil end
function Assets.sound(name) local file = FILE.sfx[name]; return file and Assets.id(file) or nil end

-- fonts: the hub's (Inter, Geist Mono, Instrument Serif, Archivo Expanded) when its files are there
local FONT_FILES = {
  text400 = { "Inter", "fonts/Inter-Regular.ttf", 400 }, text500 = { "Inter", "fonts/Inter-Medium.ttf", 500 },
  text600 = { "Inter", "fonts/Inter-SemiBold.ttf", 600 }, text700 = { "Inter", "fonts/Inter-Bold.ttf", 700 },
  mono400 = { "GeistMono", "fonts/GeistMono-Regular.ttf", 400 }, mono500 = { "GeistMono", "fonts/GeistMono-Medium.ttf", 500 },
  serif = { "InstrumentSerif", "fonts/InstrumentSerif-Regular.ttf", 400 },
  serifItalic = { "InstrumentSerifItalic", "fonts/InstrumentSerif-Italic.ttf", 400 },
  wideBold = { "ArchivoExpanded", "fonts/Archivo-ExpandedBold.ttf", 700 },
  wideBlack = { "ArchivoExpanded", "fonts/Archivo-ExpandedBlack.ttf", 900 },
}
local WEIGHTS = { [400] = "Regular", [500] = "Medium", [600] = "SemiBold", [700] = "Bold", [900] = "Heavy" }
local function builtin(name, weight, style)
  local ok, font = pcall(Font.fromName, name, weight or Enum.FontWeight.Regular, style or Enum.FontStyle.Normal)
  if ok and font then return font end
  return Font.fromEnum(Enum.Font.Gotham)
end
local FALLBACK = {
  text400 = function() return builtin("BuilderSans", Enum.FontWeight.Regular) end,
  text500 = function() return builtin("BuilderSans", Enum.FontWeight.Medium) end,
  text600 = function() return builtin("BuilderSans", Enum.FontWeight.SemiBold) end,
  text700 = function() return builtin("BuilderSans", Enum.FontWeight.Bold) end,
  mono400 = function() return builtin("RobotoMono", Enum.FontWeight.Regular) end,
  mono500 = function() return builtin("RobotoMono", Enum.FontWeight.Medium) end,
  serif = function() return builtin("Merriweather", Enum.FontWeight.Regular) end,
  serifItalic = function() return builtin("Merriweather", Enum.FontWeight.Regular, Enum.FontStyle.Italic) end,
  wideBold = function() return builtin("BuilderExtended", Enum.FontWeight.Bold) end,
  wideBlack = function() return builtin("BuilderExtended", Enum.FontWeight.Heavy) end,
}
Library.F = {}
local function loadFonts()
  local families = {}
  for key, spec in pairs(FONT_FILES) do
    local ttf = Assets.id(spec[2])
    if ttf then
      local family = families[spec[1]]
      if not family then family = { name = spec[1], faces = {}, keys = {} }; families[spec[1]] = family end
      family.faces[#family.faces + 1] = { name = WEIGHTS[spec[3]] or "Regular", weight = spec[3], style = "normal", assetId = ttf }
      family.keys[key] = spec[3]
    end
  end
  for name, family in pairs(families) do
    table.sort(family.faces, function(a, b) return a.weight < b.weight end)
    local relative = "fonts/" .. name .. ".json"
    local ok, json = pcall(S.HttpService.JSONEncode, S.HttpService, { name = name, faces = family.faces })
    if ok and Assets.root then
      fs.write(Assets.root .. "/" .. relative, json)
      ids[relative] = nil
      local id = Assets.id(relative)
      if id then
        for key, weight in pairs(family.keys) do
          local okFont, font = pcall(Font.new, id, Enum.FontWeight[WEIGHTS[weight] or "Regular"], Enum.FontStyle.Normal)
          if okFont then Library.F[key] = font end
        end
      end
    end
  end
  for key, make in pairs(FALLBACK) do
    if not Library.F[key] then Library.F[key] = make() end
  end
end
function Assets.init(root)
  Assets.root = root
  table.clear(ids)
  table.clear(Library.F)
  loadFonts()
  Library.F0 = table.clone(Library.F)
  Assets.ready = true
end
Assets.init(nil)

-- ============================================================================ ui toolkit (04_ui)
local UI = { fx = { canvas = true, shadow = false, innerStroke = false }, sfxVolume = 0.5, sfxOn = true }
Library.UI = UI
pcall(function() local p = Instance.new("UIShadow"); p.BlurRadius = UDim.new(0, 4); p:Destroy(); UI.fx.shadow = true end)
pcall(function() local p = Instance.new("UIStroke"); p.BorderStrokePosition = Enum.BorderStrokePosition.Inner; p:Destroy(); UI.fx.innerStroke = true end)
pcall(function()
  local saved = UserSettings():GetService("UserGameSettings").SavedQualityLevel
  if saved ~= Enum.SavedQualitySetting.Automatic and saved.Value <= 2 then UI.fx.canvas = false end
end)

local function applyTheme(instance, map)
  for property, spec in pairs(map) do
    if type(spec) == "table" then Theme.bind(instance, property, spec[1], spec[2]) else Theme.bind(instance, property, spec) end
  end
end
function UI.new(class, props, children)
  local instance = Instance.new(class)
  local parent
  if props then
    for key, value in pairs(props) do
      if key == "Parent" then parent = value
      elseif key == "Theme" then applyTheme(instance, value)
      else instance[key] = value end
    end
  end
  if children then for _, child in ipairs(children) do child.Parent = instance end end
  if parent then instance.Parent = parent end
  return instance
end
function UI.frame(parent, props)
  local frame = Instance.new("Frame")
  frame.BackgroundTransparency = 1
  frame.BorderSizePixel = 0
  if props then
    for key, value in pairs(props) do
      if key == "Theme" then applyTheme(frame, value) else frame[key] = value end
    end
  end
  frame.Parent = parent
  return frame
end
function UI.corner(instance, radius)
  local corner = Instance.new("UICorner")
  if radius == true then corner.CornerRadius = UDim.new(1, 0)
  elseif type(radius) == "string" then Theme.bind(corner, "CornerRadius", radius, function(value) return UDim.new(0, value) end)
  else corner.CornerRadius = UDim.new(0, radius or 8) end
  corner.Parent = instance
  return corner
end
function UI.stroke(instance, token, alphaToken, thickness)
  local stroke = Instance.new("UIStroke")
  stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
  stroke.Thickness = thickness or 1
  Theme.bind(stroke, "Color", token or "ink")
  if type(alphaToken) == "number" then stroke.Transparency = alphaToken else Theme.bind(stroke, "Transparency", alphaToken or "strokeA") end
  if UI.fx.innerStroke then stroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner end
  stroke.Parent = instance
  return stroke
end
function UI.pad(instance, top, right, bottom, left)
  local pad = Instance.new("UIPadding")
  right = right or top
  bottom = bottom or top
  left = left or right
  pad.PaddingTop, pad.PaddingRight, pad.PaddingBottom, pad.PaddingLeft = UDim.new(0, top), UDim.new(0, right), UDim.new(0, bottom), UDim.new(0, left)
  pad.Parent = instance
  return pad
end
function UI.list(instance, direction, gap, align)
  local layout = Instance.new("UIListLayout")
  layout.FillDirection = direction == "x" and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
  layout.Padding = UDim.new(0, gap or 0)
  layout.SortOrder = Enum.SortOrder.LayoutOrder
  if align then
    if align.h then layout.HorizontalAlignment = Enum.HorizontalAlignment[align.h] end
    if align.v then layout.VerticalAlignment = Enum.VerticalAlignment[align.v] end
  end
  layout.Parent = instance
  return layout
end
function UI.scaleOf(instance)
  local scale = instance:FindFirstChildOfClass("UIScale")
  if not scale then scale = Instance.new("UIScale"); scale.Parent = instance end
  return scale
end
function UI.gradient(instance, props)
  local gradient = Instance.new("UIGradient")
  for key, value in pairs(props) do gradient[key] = value end
  gradient.Parent = instance
  return gradient
end
function UI.alphaSeq(...)
  local points, args = {}, { ... }
  for i = 1, #args, 2 do points[#points + 1] = NumberSequenceKeypoint.new(args[i], args[i + 1]) end
  return NumberSequence.new(points)
end

-- text + icons
local STYLE = Theme.type
UI.fontKey = {}
function UI.text(parent, text, style, color, props)
  local spec = STYLE[style or "body"] or STYLE.body
  local label = Instance.new("TextLabel")
  label.BackgroundTransparency = 1
  label.BorderSizePixel = 0
  label.FontFace = Library.F[spec[1]]
  UI.fontKey[label] = spec[1]
  label.TextSize = spec[2]
  label.Text = text or ""
  label.TextXAlignment = Enum.TextXAlignment.Left
  label.TextYAlignment = Enum.TextYAlignment.Center
  label.AutomaticSize = Enum.AutomaticSize.XY
  label.Size = UDim2.new()
  Theme.bind(label, "TextColor3", color or "ink")
  if props then for key, value in pairs(props) do label[key] = value end end
  label.Parent = parent
  return label
end

-- Without the icon atlas a glyph label stands in, kept in step with the image's colour and fade.
local GLYPH = {
  ["x"] = "✕", ["minus"] = "–", ["plus"] = "+", ["check"] = "✓", ["chevron-down"] = "▾", ["chevron-up"] = "▴",
  ["chevron-right"] = "▸", ["chevron-left"] = "◂", ["chevrons-up-down"] = "⇅", ["ellipsis"] = "⋯", ["search"] = "⌕",
  ["settings"] = "⚙", ["rotate-ccw"] = "↺", ["keyboard"] = "⌨", ["hand"] = "☛", ["eye"] = "◉", ["eye-off"] = "◌",
  ["power"] = "⏻", ["sparkles"] = "✦", ["star"] = "★", ["heart"] = "♥", ["bell"] = "◔", ["info"] = "ⓘ",
  ["triangle-alert"] = "⚠", ["circle-check"] = "✔", ["circle-alert"] = "!", ["arrow-up"] = "↑", ["arrow-down"] = "↓",
  ["arrow-left"] = "←", ["arrow-right"] = "→", ["play"] = "▶", ["pause"] = "⏸", ["zap"] = "⚡", ["crosshair"] = "⌖",
  ["target"] = "◎", ["house"] = "⌂", ["user"] = "☺", ["users"] = "☺", ["globe"] = "◍", ["palette"] = "◐",
  ["layout-dashboard"] = "▦", ["layout-grid"] = "▦", ["package"] = "▣", ["circle"] = "○", ["app-window"] = "▭",
  ["save"] = "⬇", ["download"] = "⬇", ["upload"] = "⬆", ["trash-2"] = "✖", ["copy"] = "⧉", ["lock"] = "▣",
  ["flame"] = "♨", ["swords"] = "⚔", ["sword"] = "⚔", ["shield"] = "⛨", ["wind"] = "≋", ["music"] = "♪",
}
local function glyphFor(name) return GLYPH[name] or "•" end
function UI.icon(parent, name, size, color, props)
  local image = Instance.new("ImageLabel")
  image.BackgroundTransparency = 1
  image.BorderSizePixel = 0
  image.Size = UDim2.fromOffset(size or 18, size or 18)
  image.ScaleType = Enum.ScaleType.Fit
  Theme.bind(image, "ImageColor3", color or "ink")
  local id, offset, rect = Assets.icon(name)
  if id then
    image.Image, image.ImageRectOffset, image.ImageRectSize = id, offset, rect
  else
    local glyph = Instance.new("TextLabel")
    glyph.Name = "Glyph"
    glyph.BackgroundTransparency = 1
    glyph.BorderSizePixel = 0
    glyph.Size = UDim2.fromScale(1, 1)
    glyph.FontFace = Library.F.text600
    glyph.TextScaled = false
    glyph.TextSize = math.floor((size or 18) * 0.92)
    glyph.Text = glyphFor(name)
    glyph.TextColor3 = image.ImageColor3
    glyph.TextTransparency = image.ImageTransparency
    glyph.Parent = image
    image:GetPropertyChangedSignal("ImageColor3"):Connect(function() glyph.TextColor3 = image.ImageColor3 end)
    image:GetPropertyChangedSignal("ImageTransparency"):Connect(function() glyph.TextTransparency = image.ImageTransparency end)
  end
  if props then for key, value in pairs(props) do image[key] = value end end
  image.Parent = parent
  return image
end
function UI.setIcon(image, name)
  local id, offset, rect = Assets.icon(name)
  if id then image.Image, image.ImageRectOffset, image.ImageRectSize = id, offset, rect
  else
    local glyph = image:FindFirstChild("Glyph")
    if glyph then glyph.Text = glyphFor(name) end
  end
end
function UI.image(parent, name, props)
  local image = Instance.new("ImageLabel")
  image.BackgroundTransparency = 1
  image.BorderSizePixel = 0
  image.Image = Assets.image(name) or ""
  if props then
    for key, value in pairs(props) do
      if key == "Theme" then applyTheme(image, value) else image[key] = value end
    end
  end
  image.Parent = parent
  return image
end

-- glass: tinted fill, fine grain, a top sheen and a rim that catches light
function UI.glass(parent, opts)
  opts = opts or {}
  local level = opts.level or "panel"
  local radius = opts.radius or "rPanel"
  local frame = Instance.new("Frame")
  frame.BorderSizePixel = 0
  frame.Name = opts.name or "Glass"
  if level == "window" then
    Theme.bind(frame, "BackgroundColor3", "base")
    Theme.bind(frame, "BackgroundTransparency", "baseA")
  elseif level == "popover" then
    Theme.bind(frame, "BackgroundColor3", "popover")
    frame.BackgroundTransparency = 0.04
  else
    Theme.bind(frame, "BackgroundColor3", "ink")
    Theme.bind(frame, "BackgroundTransparency", opts.fill or "fill1A")
  end
  UI.corner(frame, radius)
  if opts.grain ~= false and Assets.image("noise") then
    local grain = UI.image(frame, "noise", { Name = "Grain", Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Tile,
      TileSize = UDim2.fromOffset(128, 128), ImageTransparency = opts.grainAlpha or 0.955, ZIndex = 0, Interactable = false })
    UI.corner(grain, radius)
  end
  if opts.sheen ~= false then
    local sheen = Instance.new("Frame")
    sheen.Name = "Sheen"
    sheen.BorderSizePixel = 0
    sheen.BackgroundColor3 = Color3.new(1, 1, 1)
    sheen.Size = UDim2.fromScale(1, 1)
    sheen.ZIndex = 0
    sheen.Interactable = false
    UI.corner(sheen, radius)
    UI.gradient(sheen, { Rotation = 90, Transparency = UI.alphaSeq(0, opts.sheenAlpha or 0.93, 0.45, 1, 1, 1) })
    sheen.Parent = frame
  end
  local rim = Instance.new("UIStroke")
  rim.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
  rim.Thickness = 1
  rim.Color = Color3.new(1, 1, 1)
  if UI.fx.innerStroke then rim.BorderStrokePosition = Enum.BorderStrokePosition.Inner end
  local rimGradient = UI.gradient(rim, { Rotation = 52,
    Transparency = UI.alphaSeq(0, opts.rimHi or 0.55, 0.32, 0.9, 0.68, 0.93, 1, opts.rimLo or 0.72) })
  rim.Parent = frame
  if opts.shadow and UI.fx.shadow then
    local shadow = Instance.new("UIShadow")
    shadow.BlurRadius = UDim.new(0, opts.shadow == true and 56 or opts.shadow)
    shadow.Offset = UDim2.fromOffset(0, opts.shadowY or 22)
    shadow.Color = Color3.new(0, 0, 0)
    Theme.bind(shadow, "Transparency", "shadowA")
    pcall(function() shadow.ShowBehindParent = false end)
    shadow.Parent = frame
  end
  if opts.props then for key, value in pairs(opts.props) do frame[key] = value end end
  frame.Parent = parent
  return frame, rimGradient
end
function UI.surface(parent, props, radius, fill)
  local frame = Instance.new("Frame")
  frame.BorderSizePixel = 0
  Theme.bind(frame, "BackgroundColor3", "ink")
  Theme.bind(frame, "BackgroundTransparency", fill or "fill1A")
  UI.corner(frame, radius or "rCard")
  if props then for key, value in pairs(props) do frame[key] = value end end
  frame.Parent = parent
  return frame
end
function UI.group(parent, props)
  local group = Instance.new(UI.fx.canvas and "CanvasGroup" or "Frame")
  group.BackgroundTransparency = 1
  group.BorderSizePixel = 0
  if props then for key, value in pairs(props) do group[key] = value end end
  group.Parent = parent
  return group
end
function UI.fade(group, alpha, preset, done)
  if group:IsA("CanvasGroup") then
    if alpha > 0 then group.Visible = true end
    Motion.to(group, "GroupTransparency", 1 - alpha, preset or "quick", function()
      if alpha <= 0 then group.Visible = false end
      if done then done() end
    end)
  else
    group.Visible = alpha > 0
    if done then done() end
  end
end
function UI.setFade(group, alpha)
  if group:IsA("CanvasGroup") then Motion.snap(group, "GroupTransparency", 1 - alpha) end
  group.Visible = alpha > 0
end

-- sound (only with the hub's sfx files)
local sounds = {}
function UI.sfx(name, volume)
  if not UI.sfxOn or UI.sfxVolume <= 0 or not UI.soundHost then return end
  local id = Assets.sound(name)
  if not id then return end
  local now = os.clock()
  local entry = sounds[name]
  if entry and now - entry.at < 0.04 then return end
  if not entry then
    local sound = Instance.new("Sound")
    sound.SoundId = id
    sound.Parent = UI.soundHost
    entry = { sound = sound, at = 0 }
    sounds[name] = entry
  end
  entry.at = now
  entry.sound.Volume = (volume or 1) * UI.sfxVolume * 0.5
  entry.sound.PlaybackSpeed = 0.97 + math.random() * 0.06
  entry.sound:Play()
end

-- input
local function isPress(input)
  return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end
UI.isPress = isPress
function UI.mouse() return UIS:GetMouseLocation() - S.GuiService:GetGuiInset() end
function UI.point(input) return Vector2.new(input.Position.X, input.Position.Y) end
function UI.unit() return 1 end
function UI.inside(gui, point)
  local p, s = gui.AbsolutePosition, gui.AbsoluteSize
  return point.X >= p.X and point.X <= p.X + s.X and point.Y >= p.Y and point.Y <= p.Y + s.Y
end
function UI.wire(button, handlers)
  local pressing = false
  if handlers.hover then
    button.MouseEnter:Connect(B.safe("ui.hover", function() handlers.hover(true) end))
    button.MouseLeave:Connect(B.safe("ui.hover", function()
      handlers.hover(false)
      if pressing and handlers.press then pressing = false; handlers.press(false) end
    end))
  end
  button.InputBegan:Connect(B.safe("ui.press", function(input)
    if isPress(input) then
      pressing = true
      if handlers.press then handlers.press(true) end
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 and handlers.alt then
      handlers.alt(input)
    end
  end))
  button.InputEnded:Connect(B.safe("ui.press", function(input)
    if isPress(input) and pressing then
      pressing = false
      if handlers.press then handlers.press(false) end
    end
  end))
  if handlers.click then button.Activated:Connect(B.safe("ui.click", function(input) handlers.click(input) end)) end
  return button
end
-- an invisible button laid over `parent` (not for parents with a list layout or automatic width)
function UI.button(parent, handlers, props)
  local button = Instance.new("TextButton")
  button.Name = "Hit"
  button.Text = ""
  button.BackgroundTransparency = 1
  button.BorderSizePixel = 0
  button.AutoButtonColor = false
  button.Size = UDim2.fromScale(1, 1)
  button.ZIndex = 5
  if props then for key, value in pairs(props) do button[key] = value end end
  UI.wire(button, handlers)
  button.Parent = parent
  return button
end
-- a container that is itself the button
function UI.pressable(parent, props, handlers)
  local button = Instance.new("TextButton")
  button.Text = ""
  button.AutoButtonColor = false
  button.BorderSizePixel = 0
  button.BackgroundTransparency = 1
  if props then
    for key, value in pairs(props) do
      if key == "Theme" then applyTheme(button, value) else button[key] = value end
    end
  end
  if handlers then UI.wire(button, handlers) end
  button.Parent = parent
  return button
end
function UI.drag(handle, onStart, onMove, onEnd)
  handle.InputBegan:Connect(B.safe("ui.drag", function(input)
    if not isPress(input) then return end
    local start = UI.point(input)
    if onStart and onStart(start) == false then return end
    local touch = input.UserInputType == Enum.UserInputType.Touch
    local moved, ended
    local function finish()
      if moved then moved:Disconnect() end
      if ended then ended:Disconnect() end
      moved, ended = nil, nil
      if onEnd then B.try("ui.drag.end", onEnd) end
    end
    moved = UIS.InputChanged:Connect(B.safe("ui.drag.move", function(change)
      if (touch and change == input) or (not touch and change.UserInputType == Enum.UserInputType.MouseMovement) then
        local p = UI.point(change)
        onMove(p, p - start)
      end
    end))
    ended = UIS.InputEnded:Connect(function(finished)
      if finished == input or (not touch and finished.UserInputType == Enum.UserInputType.MouseButton1) then finish() end
    end)
  end))
end

-- overlay layer: popovers, menus and tooltips
local popovers = {}
function UI.mountOverlay(gui, scaleSource)
  UI.overlay = UI.frame(gui, { Name = "Overlay", Size = UDim2.fromScale(1, 1), ZIndex = 50 })
  UI.overlayScale = scaleSource
  B.connect(UIS.InputBegan, function(input)
    if #popovers == 0 then return end
    if isPress(input) or input.UserInputType == Enum.UserInputType.MouseButton2 then
      local point = UI.point(input)
      for index = #popovers, 1, -1 do
        local pop = popovers[index]
        if not UI.inside(pop.frame, point) and not (pop.anchor and UI.inside(pop.anchor, point)) then pop.close() else break end
      end
    elseif input.KeyCode == Enum.KeyCode.Escape then
      popovers[#popovers].close()
    end
  end, "ui.overlay")
end
function UI.closePopovers() for index = #popovers, 1, -1 do popovers[index].close(true) end end
function UI.popoverOpen() return #popovers > 0 end

function UI.popover(anchor, opts, build)
  opts = opts or {}
  local scale = UI.overlayScale and UI.overlayScale() or 1
  local width = opts.width or 220
  local pop = { anchor = anchor }
  local holder = UI.frame(UI.overlay, { Name = "Popover", Size = UDim2.fromOffset(width, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 60 })
  local sizer = Instance.new("UIScale")
  sizer.Scale = scale * 0.92
  sizer.Parent = holder
  local glass = UI.glass(holder, { level = "popover", radius = "rCard", shadow = 34, shadowY = 14, rimHi = 0.62, name = "Panel",
    props = { Size = UDim2.fromScale(1, 0), AutomaticSize = Enum.AutomaticSize.Y } })
  local group = UI.group(glass, { Size = UDim2.fromScale(1, 0), AutomaticSize = Enum.AutomaticSize.Y })
  UI.pad(group, opts.pad or 6)
  UI.list(group, "y", opts.gap or 2)
  pop.frame = holder
  local closed = false
  function pop.close(instant)
    if closed then return end
    closed = true
    local at = table.find(popovers, pop)
    if at then table.remove(popovers, at) end
    if opts.onClose then B.try("popover.close", opts.onClose) end
    if instant then holder:Destroy(); return end
    Motion.to(sizer, "Scale", scale * 0.94, "quick")
    UI.fade(group, 0, "quick")
    Motion.to(glass, "BackgroundTransparency", 1, "quick", function() holder:Destroy() end)
  end
  B.try("popover.build", build, group, pop.close)
  local function place()
    local view = B.viewport()
    local a, s = anchor.AbsolutePosition, anchor.AbsoluteSize
    local size = holder.AbsoluteSize
    local w, h = width * scale, math.max(size.Y, 1)
    local x
    if opts.align == "left" then x = a.X elseif opts.align == "center" then x = a.X + s.X / 2 - w / 2 else x = a.X + s.X - w end
    local y = a.Y + s.Y + 6 * scale
    local above = opts.side == "above" or (y + h > view.Y - 8 and a.Y - h - 6 * scale > 8)
    if above then y = a.Y - h - 6 * scale end
    local origin = UI.overlay.AbsolutePosition
    x = math.clamp(x - origin.X, 8, math.max(8, view.X - w - 8))
    y = math.clamp(y - origin.Y, 8, math.max(8, view.Y - h - 8))
    holder.Position = UDim2.fromOffset(x, y)
    return above
  end
  place()
  holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() if not closed then place() end end)
  UI.setFade(group, 0)
  UI.fade(group, 1, "quick")
  Motion.to(sizer, "Scale", scale, "snappy")
  popovers[#popovers + 1] = pop
  UI.sfx("open", 0.5)
  return pop
end

-- items = { { label, icon?, hint?, danger?, checked?, run } | "divider" }
function UI.menu(anchor, items, opts)
  opts = opts or {}
  return UI.popover(anchor, { width = opts.width or 208, align = opts.align, side = opts.side }, function(content, close)
    local rows = opts.rows or 11
    if #items > rows then
      local holder = UI.frame(content, { Name = "Long", Size = UDim2.new(1, 0, 0, rows * 34 - 2) })
      local scroller, scroll = UI.scroll(holder, { Size = UDim2.fromScale(1, 1), Name = "Scroll" })
      content = UI.frame(scroller, { Name = "Rows", Size = UDim2.new(1, -9, 0, 0), AutomaticSize = Enum.AutomaticSize.Y })
      UI.list(content, "y", 2)
      for index, item in ipairs(items) do
        if type(item) == "table" and item.checked then
          task.defer(function() if holder.Parent then scroll.to((index - 4) * 34, true) end end)
          break
        end
      end
    end
    for index, item in ipairs(items) do
      if item == "divider" then
        local line = UI.frame(content, { Size = UDim2.new(1, -12, 0, 1), LayoutOrder = index, Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "strokeA" } })
        line.Position = UDim2.fromOffset(6, 0)
      else
        local row = UI.frame(content, { Size = UDim2.new(1, 0, 0, 32), LayoutOrder = index, Theme = { BackgroundColor3 = "ink" } })
        UI.corner(row, "rSmall")
        local x = 10
        if item.icon then
          UI.icon(row, item.icon, 16, item.danger and "bad" or "sub", { Position = UDim2.new(0, 10, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5) })
          x = 34
        end
        UI.text(row, item.label, "label", item.danger and "bad" or "ink", { Position = UDim2.new(0, x, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), TextSize = 13 })
        if item.checked then
          UI.icon(row, "check", 15, "accent", { Position = UDim2.new(1, -10, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5) })
        elseif item.hint then
          UI.text(row, item.hint, "mono", "faint", { Position = UDim2.new(1, -10, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), TextSize = 11 })
        end
        UI.button(row, {
          hover = function(on) Motion.to(row, "BackgroundTransparency", on and T.fill2A or 1, "quick") end,
          click = function()
            UI.sfx("click", 0.6)
            if not item.keepOpen then close() end
            if item.run then item.run() end
          end,
        })
      end
    end
  end)
end

-- tooltip
local tip
function UI.tooltip(target, text)
  if not text or text == "" then return end
  local token = 0
  target.MouseEnter:Connect(function()
    token += 1
    local mine = token
    task.delay(0.55, function()
      if mine ~= token or not Library.alive or not UI.overlay or not target:IsDescendantOf(game) then return end
      if tip then tip:Destroy() end
      local scale = UI.overlayScale and UI.overlayScale() or 1
      local holder = UI.frame(UI.overlay, { Name = "Tip", AutomaticSize = Enum.AutomaticSize.XY, ZIndex = 80 })
      local sizer = Instance.new("UIScale"); sizer.Scale = scale; sizer.Parent = holder
      local body = UI.glass(holder, { level = "popover", radius = "rSmall", sheen = false, grain = false, props = { AutomaticSize = Enum.AutomaticSize.XY } })
      UI.pad(body, 6, 9)
      local label = UI.text(body, text, "caption", "sub", { TextWrapped = true, AutomaticSize = Enum.AutomaticSize.XY })
      local limit = Instance.new("UISizeConstraint"); limit.MaxSize = Vector2.new(260, math.huge); limit.Parent = label
      local mouse = UIS:GetMouseLocation()
      local view = B.viewport()
      holder.Position = UDim2.fromOffset(math.clamp(mouse.X + 14, 8, view.X - 280 * scale), math.clamp(mouse.Y + 18, 8, view.Y - 60))
      tip = holder
    end)
  end)
  target.MouseLeave:Connect(function()
    token += 1
    if tip then tip:Destroy(); tip = nil end
  end)
end
function UI.hideTip() if tip then tip:Destroy(); tip = nil end end

-- scroll: spring-driven wheel and a scrollbar that grows under the pointer and can be dragged
UI.scrollbar = "always"
local scrollers = setmetatable({}, { __mode = "k" })
function UI.setScrollbar(mode)
  UI.scrollbar = mode
  for _, paint in pairs(scrollers) do B.try("ui.scrollbar", paint) end
end
local BAR_REST, BAR_WIDE, BAR_GRIP = 3, 6, 14
function UI.scroll(parent, props)
  local scroller = Instance.new("ScrollingFrame")
  scroller.BackgroundTransparency = 1
  scroller.BorderSizePixel = 0
  scroller.ScrollBarThickness = 0
  scroller.ScrollingDirection = Enum.ScrollingDirection.Y
  scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
  scroller.CanvasSize = UDim2.new()
  scroller.ElasticBehavior = Enum.ElasticBehavior.Never
  scroller.ScrollingEnabled = B.touch
  if props then for key, value in pairs(props) do scroller[key] = value end end
  scroller.Parent = parent
  local thumb = UI.frame(parent, { Name = "Thumb", Size = UDim2.fromOffset(BAR_REST, 40), AnchorPoint = Vector2.new(1, 0), ZIndex = 8,
    Theme = { BackgroundColor3 = "ink" }, BackgroundTransparency = 1 })
  UI.corner(thumb, true)
  local grip = UI.new("TextButton", { Name = "Scrollbar", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0),
    Size = UDim2.fromOffset(BAR_GRIP, 40), ZIndex = 9, Visible = false, Parent = parent })
  local target = 0
  local spring = Motion.spring(1, "smooth", function(x) scroller.CanvasPosition = Vector2.new(0, x[1]) end, 0.2)
  local function limit() return math.max(0, scroller.AbsoluteCanvasSize.Y - scroller.AbsoluteWindowSize.Y) end
  local hideToken = 0
  local hovered, dragging, flashing, width = false, false, false, BAR_REST
  local bar = { top = 0, size = 0, span = 0 }
  local function refresh()
    local window, canvas = scroller.AbsoluteWindowSize.Y, scroller.AbsoluteCanvasSize.Y
    local needed = canvas > window + 1 and window > 0 and UI.scrollbar ~= "off"
    if grip.Visible ~= needed then grip.Visible = needed end
    if not needed then thumb.BackgroundTransparency = 1; return false end
    local track = scroller.AbsoluteSize.Y - 12
    local size = math.max(28, track * window / canvas)
    local ratio = scroller.CanvasPosition.Y / math.max(1, canvas - window)
    local unit = UI.unit()
    local right = (scroller.AbsolutePosition.X - parent.AbsolutePosition.X + scroller.AbsoluteSize.X) / unit
    local top = scroller.AbsolutePosition.Y - parent.AbsolutePosition.Y
    thumb.Size = UDim2.fromOffset(width, size / unit)
    thumb.Position = UDim2.new(0, right - 3, 0, (top + 6 + (track - size) * ratio) / unit)
    grip.Size = UDim2.fromOffset(BAR_GRIP, scroller.AbsoluteSize.Y / unit)
    grip.Position = UDim2.new(0, right, 0, top / unit)
    bar.top, bar.size, bar.span = scroller.AbsolutePosition.Y + 6, size, track - size
    return true
  end
  local widen = Motion.spring(1, "snappy", function(x) width = x[1]; refresh() end, 0.05)
  widen:snap({ BAR_REST })
  local function paint()
    if not refresh() then return end
    local alpha = dragging and 0.35 or hovered and 0.5 or flashing and 0.62 or (UI.scrollbar == "always" and 0.82 or 1)
    Motion.to(thumb, "BackgroundTransparency", alpha, alpha >= 0.8 and "gentle" or "quick")
    widen:to({ (dragging or hovered) and BAR_WIDE or BAR_REST })
  end
  scrollers[scroller] = paint
  local function flash()
    flashing = true
    paint()
    hideToken += 1
    local mine = hideToken
    task.delay(0.9, function() if mine == hideToken and thumb.Parent then flashing = false; paint() end end)
  end
  scroller:GetPropertyChangedSignal("CanvasPosition"):Connect(flash)
  scroller:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(function()
    if target > limit() then target = limit(); spring:to({ target }) end
    paint()
  end)
  scroller:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(paint)
  local grab = 0
  local function follow(y)
    local ratio = bar.span > 0 and math.clamp((y - grab - bar.top) / bar.span, 0, 1) or 0
    target = ratio * limit()
    spring:snap({ target })
  end
  UI.drag(grip, function(point)
    if not refresh() then return false end
    local at = bar.top + bar.span * (scroller.CanvasPosition.Y / math.max(1, limit()))
    grab = (point.Y >= at and point.Y <= at + bar.size) and (point.Y - at) or bar.size * 0.5
    dragging = true
    follow(point.Y)
    paint()
    return true
  end, function(point) follow(point.Y) end, function() dragging = false; paint() end)
  grip.MouseEnter:Connect(function() hovered = true; paint() end)
  grip.MouseLeave:Connect(function() hovered = false; paint() end)
  local wheel = B.safe("ui.wheel", function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseWheel or B.touch then return end
    local top = popovers[#popovers]
    if top and not (top.frame and scroller:IsDescendantOf(top.frame)) then return end
    if not spring:moving() then
      spring.x[1], spring.g[1] = scroller.CanvasPosition.Y, scroller.CanvasPosition.Y
      target = scroller.CanvasPosition.Y
    end
    target = math.clamp(target - input.Position.Z * 92, 0, limit())
    spring:to({ target })
  end)
  scroller.InputChanged:Connect(wheel)
  grip.InputChanged:Connect(wheel)
  task.defer(function() if scroller.Parent then B.try("ui.scrollbar", paint) end end)
  local api = { frame = scroller, thumb = thumb, grip = grip }
  function api.to(y, instant)
    target = math.clamp(y, 0, limit())
    if instant then spring:snap({ target }) else
      spring.x[1] = scroller.CanvasPosition.Y
      spring:to({ target })
    end
  end
  function api.top(instant) api.to(0, instant) end
  return scroller, api
end

-- letters: every word of the interface in one family
UI.FAMILIES = {
  { "inter", "Inter (BASED)" },
  { "builder", "Builder Sans", "BuilderSans" }, { "gotham", "Gotham", "GothamSSm" },
  { "montserrat", "Montserrat", "Montserrat" }, { "nunito", "Nunito", "Nunito" }, { "ubuntu", "Ubuntu", "Ubuntu" },
  { "titillium", "Titillium", "TitilliumWeb" }, { "jura", "Jura", "Jura" }, { "oswald", "Oswald", "Oswald" },
  { "roboto", "Roboto Mono", "RobotoMono" }, { "source", "Source Sans", "SourceSansPro" },
  { "arial", "Arial", function() return Font.fromEnum(Enum.Font.Arial) end },
}
local LETTER_KEYS = { "text400", "text500", "text600", "mono400", "mono500", "wideBold", "serif", "serifItalic" }
local function faceSig(face) return tostring(face.Family) .. "|" .. tostring(face.Weight) .. "|" .. tostring(face.Style) end
function UI.familyOf(id)
  for _, spec in ipairs(UI.FAMILIES) do
    if spec[1] == id then
      local source = spec[3]
      if source == nil then return nil end
      local ok, face = pcall(function()
        if type(source) == "function" then return source() end
        return Font.fromName(source)
      end)
      return ok and typeof(face) == "Font" and face.Family or nil
    end
  end
  return nil
end
function UI.setLetters(id)
  local F0 = Library.F0
  if not F0 then return end
  local family = UI.familyOf(id)
  local own, now = {}, {}
  for _, key in ipairs(LETTER_KEYS) do
    if F0[key] then own[faceSig(F0[key])] = own[faceSig(F0[key])] or key end
    if Library.F[key] then now[faceSig(Library.F[key])] = now[faceSig(Library.F[key])] or key end
  end
  for label in pairs(UI.fontKey) do if not label.Parent then UI.fontKey[label] = nil end end
  for _, key in ipairs(LETTER_KEYS) do
    local base = F0[key]
    if base then
      if family then
        local ok, face = pcall(Font.new, family, base.Weight, base.Style)
        Library.F[key] = ok and face or base
      else
        Library.F[key] = base
      end
    end
  end
  for _, gui in ipairs(B.screens) do
    if gui.Parent then
      for _, item in ipairs(gui:GetDescendants()) do
        if item:IsA("TextLabel") or item:IsA("TextButton") or item:IsA("TextBox") then
          local key = UI.fontKey[item]
          if not key then
            local sig = faceSig(item.FontFace)
            key = own[sig] or now[sig]
            if key then UI.fontKey[item] = key end
          end
          if key and Library.F[key] and item.FontFace ~= Library.F[key] then item.FontFace = Library.F[key] end
        end
      end
    end
  end
end

function UI.divider(parent, order)
  return UI.frame(parent, { Name = "Divider", Size = UDim2.new(1, 0, 0, 1), LayoutOrder = order or 0,
    Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "strokeA" } })
end
function UI.badge(parent, text, color, props)
  local badge = UI.frame(parent, { AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 18), Theme = { BackgroundColor3 = color or "accent" },
    BackgroundTransparency = 0.82 })
  UI.corner(badge, 6)
  UI.pad(badge, 0, 6)
  UI.text(badge, text, "eyebrow", color or "accent", { TextSize = 9, Size = UDim2.fromScale(0, 1), AutomaticSize = Enum.AutomaticSize.X })
  if props then for key, value in pairs(props) do badge[key] = value end end
  return badge
end

-- ============================================================================ config (05_config, trimmed)
-- Every control is backed by a flag: it saves, reloads, resets, and toggles / buttons can take a key.
local Config = { changed = Signal.new(), bindsChanged = Signal.new(), capturing = false, folder = "BasedUI", profile = "default" }
Library.Config = Config
local values, defaults, listeners, binds, actions = {}, {}, {}, {}, {}
Config.values, Config.defaults, Config.binds = values, defaults, binds

local function copyValue(value)
  if type(value) ~= "table" then return value end
  local out = {}
  for k, v in pairs(value) do out[k] = copyValue(v) end
  return out
end
local function same(a, b)
  if type(a) ~= "table" or type(b) ~= "table" then return a == b end
  for k, v in pairs(a) do if not same(v, b[k]) then return false end end
  for k, v in pairs(b) do if not same(v, a[k]) then return false end end
  return true
end

-- the window's own preferences live under "app."
values["app.scale"], defaults["app.scale"] = 100, 100
values["app.window.x"], defaults["app.window.x"] = 0.5, 0.5
values["app.window.y"], defaults["app.window.y"] = 0.5, 0.5
values["app.freeCursor"], defaults["app.freeCursor"] = true, true
values["app.key.menu"], defaults["app.key.menu"] = "V", "V"

function Config.define(id, default)
  if defaults[id] == nil then defaults[id] = copyValue(default) end
  if values[id] == nil then values[id] = copyValue(default) end
  Library.Flags[id] = values[id]
  return values[id]
end
function Config.get(id) return values[id] end
function Config.on(id, fn)
  local list = listeners[id]
  if not list then list = {}; listeners[id] = list end
  list[#list + 1] = fn
end
function Config.set(id, value, quiet)
  if same(values[id], value) then return end
  values[id] = copyValue(value)
  Library.Flags[id] = values[id]
  local list = listeners[id]
  if list then
    for _, fn in ipairs(table.clone(list)) do B.try("flag." .. id, fn, values[id]) end
  end
  if not quiet then Config.changed:fire(id, values[id]) end
end
function Config.reset(id)
  if defaults[id] ~= nil then Config.set(id, copyValue(defaults[id])) end
end
function Config.action(id, fn) actions[id] = fn end

-- keys
local SHORT = { LeftShift = "LShift", RightShift = "RShift", LeftControl = "LCtrl", RightControl = "RCtrl", LeftAlt = "LAlt", RightAlt = "RAlt",
  Return = "Enter", Backspace = "Back", Escape = "Esc", Space = "Space", Insert = "Ins", Delete = "Del", PageUp = "PgUp", PageDown = "PgDn",
  MouseButton3 = "MB3", Zero = "0", One = "1", Two = "2", Three = "3", Four = "4", Five = "5", Six = "6", Seven = "7", Eight = "8", Nine = "9",
  Backquote = "`", LeftBracket = "[", RightBracket = "]", Semicolon = ";", Quote = "'", Comma = ",", Period = ".", Slash = "/", Minus = "-", Equals = "=" }
function Config.keyName(input)
  if input.UserInputType == Enum.UserInputType.Keyboard then return input.KeyCode.Name end
  if input.UserInputType == Enum.UserInputType.MouseButton3 then return "MouseButton3" end
  return nil
end
function Config.keyLabel(key)
  if not key or key == "None" then return "None" end
  return SHORT[key] or key
end
function Config.bindOf(id) return binds[id] end
function Config.bind(id, key, mode)
  if not key then binds[id] = nil else binds[id] = { key = key, mode = mode or (binds[id] and binds[id].mode) or "toggle" } end
  Config.bindsChanged:fire(id)
  Config.changed:fire("bind:" .. id, binds[id])
end

B.connect(UIS.InputBegan, function(input)
  if Config.capturing or UIS:GetFocusedTextBox() then return end
  local name = Config.keyName(input)
  if not name then return end
  for id, bind in pairs(binds) do
    if bind.key == name then
      if actions[id] then
        B.try("bind." .. id, actions[id])
      elseif type(values[id]) == "boolean" then
        if bind.mode == "hold" then Config.set(id, true) else Config.set(id, not values[id]) end
      end
    end
  end
end, "config.keys")
B.connect(UIS.InputEnded, function(input)
  local name = Config.keyName(input)
  if not name then return end
  for id, bind in pairs(binds) do
    if bind.key == name and bind.mode == "hold" and type(values[id]) == "boolean" then Config.set(id, false) end
  end
end, "config.keysUp")

-- profiles (JSON on disk, when the executor has file access)
local function encode(value)
  local kind = typeof(value)
  if kind == "Color3" then return { __c = util.toHex(value) } end
  if kind == "EnumItem" then return { __e = tostring(value.EnumType), v = value.Name } end
  if kind == "table" then
    local out = {}
    for k, v in pairs(value) do out[k] = encode(v) end
    return out
  end
  return value
end
local function decode(value)
  if type(value) ~= "table" then return value end
  if type(value.__c) == "string" then
    local ok, color = pcall(util.hex, value.__c)
    return ok and color or nil
  end
  if value.__e then
    local ok, item = pcall(function() return Enum[value.__e][value.v] end)
    return ok and item or nil
  end
  local out = {}
  for k, v in pairs(value) do out[k] = decode(v) end
  return out
end
local function profilePath(name) return Config.folder .. "/" .. (name or Config.profile) .. ".json" end
function Config.save(name)
  if not fs.ok then return false end
  local data, keys = { values = {}, binds = {} }, {}
  for id, value in pairs(values) do data.values[id] = encode(value) end
  for id, bind in pairs(binds) do data.binds[id] = { key = bind.key, mode = bind.mode } end
  local ok, json = pcall(S.HttpService.JSONEncode, S.HttpService, data)
  return ok and fs.write(profilePath(name), json) or false
end
function Config.load(name)
  local raw = fs.read(profilePath(name))
  if not raw or raw == "" then return false end
  local ok, data = pcall(S.HttpService.JSONDecode, S.HttpService, raw)
  if not ok or type(data) ~= "table" then return false end
  for id, value in pairs(type(data.values) == "table" and data.values or {}) do
    local decoded = decode(value)
    if decoded ~= nil and (values[id] == nil or typeof(decoded) == typeof(values[id])) then Config.set(id, decoded, true) end
  end
  for id, bind in pairs(type(data.binds) == "table" and data.binds or {}) do
    if type(bind) == "table" and bind.key then Config.bind(id, bind.key, bind.mode) end
  end
  return true
end

-- the window table is declared here so the controls can reach it; section 07 fills it in
local Window = { open = false, built = false, pages = {}, order = {}, index = {}, scale = 1, onShow = Signal.new(), onPage = Signal.new(),
  brand = { text = "ARBIX", sub = "hub" } }
Library.Window = Window
-- ============================================================================ controls (06_controls)
do
-- ============================================================================
--  06 controls  rows and the things on their right-hand side
--
--  A control is a row inside a card: label (and description) on the left, the
--  control on the right. Every control is backed by a Config flag, so it saves,
--  reloads with a profile, can be reset from its context menu and, for toggles
--  and buttons, bound to a key.
-- ============================================================================
local Controls = { bindables = {} }   -- bindables: flag id -> { label, kind, page }, everything a key can be given
B.Controls = Controls

-- ---------------------------------------------------------------- key capture
function Controls.captureKey(done)
  if Config.capturing then return end
  Config.capturing = true
  local connection
  connection = UIS.InputBegan:Connect(function(input)
    local key = Config.keyName(input)
    if not key then return end
    connection:Disconnect()
    -- the press that sets a key must not also fire the bind it just made
    task.delay(0.15, function() Config.capturing = false end)
    if key == "Escape" then B.try("capture", done, nil, true)
    elseif key == "Backspace" or key == "Delete" then B.try("capture", done, nil, false)
    else B.try("capture", done, key, false) end
  end)
  B.own(connection)
end

-- ---------------------------------------------------------------- row
-- section: { body = Frame, count = number, index = function(entry) }
local function makeRow(section, spec, controlWidth)
  section.count = (section.count or 0) + 1
  local row = UI.frame(section.body, { Name = spec.label or "Row", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
    LayoutOrder = section.count })
  if section.count > 1 then
    UI.frame(row, { Name = "Rule", Size = UDim2.new(1, -28, 0, 1), Position = UDim2.fromOffset(14, 0),
      Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "strokeA" } })
  end
  local wash = UI.frame(row, { Name = "Wash", Size = UDim2.new(1, -8, 1, -6), Position = UDim2.fromOffset(4, 3), Theme = { BackgroundColor3 = "ink" },
    BackgroundTransparency = 1, ZIndex = 0 })
  UI.corner(wash, "rSmall")
  local left = UI.frame(row, { Name = "Left", Size = UDim2.new(1, -((controlWidth or 150) + 30), 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
    Position = UDim2.fromOffset(0, 0) })
  UI.pad(left, 12, 0, 12, spec.icon and 42 or 14)
  UI.list(left, "y", 2)
  if spec.icon then
    UI.icon(row, spec.icon, 17, "sub", { Position = UDim2.fromOffset(14, 13), Name = "Icon" })
  end
  local titleLine = UI.frame(left, { Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 1 })
  UI.list(titleLine, "x", 7, { v = "Center" })
  local label = UI.text(titleLine, spec.label or "", "label", "ink", { TextTruncate = Enum.TextTruncate.AtEnd, LayoutOrder = 1,
    AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 20) })
  if spec.badge then UI.badge(titleLine, spec.badge, spec.badgeColor, { LayoutOrder = 2 }) end
  if spec.desc and spec.desc ~= "" then
    UI.text(left, spec.desc, "caption", "sub", { TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0),
      LayoutOrder = 2, LineHeight = 1.15 })
  end
  local slot = UI.frame(row, { Name = "Slot", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 0), Size = UDim2.fromOffset(0, 44),
    AutomaticSize = Enum.AutomaticSize.X, ZIndex = 6 })
  UI.list(slot, "x", 8, { h = "Right", v = "Center" })
  local api = { frame = row, left = left, slot = slot, label = label, wash = wash }
  function api.hover(on) Motion.to(wash, "BackgroundTransparency", on and 0.965 or 1, "quick") end
  function api.flash()
    wash.BackgroundTransparency = 0.86
    Theme.unbind(wash, "BackgroundColor3")
    wash.BackgroundColor3 = T.accent
    Motion.to(wash, "BackgroundTransparency", 1, "lazy", function() Theme.bind(wash, "BackgroundColor3", "ink") end)
  end
  if section.index then
    section.index({ label = spec.label or "", desc = spec.desc or "", row = api, id = spec.id })
  end
  return api
end
Controls.row = makeRow

-- the small chip showing which key a flag is bound to
local function bindChip(slot, id, order)
  local chip = UI.frame(slot, { Name = "Bind", Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = order or 1,
    Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill2A" }, Visible = false })
  UI.corner(chip, 6)
  UI.pad(chip, 0, 6)
  local text = UI.text(chip, "", "mono", "sub", { TextSize = 11, Size = UDim2.fromScale(0, 1), AutomaticSize = Enum.AutomaticSize.X })
  local function refresh()
    local bind = Config.bindOf(id)
    chip.Visible = bind ~= nil and bind.key ~= nil
    if bind and bind.key then text.Text = Config.keyLabel(bind.key) .. (bind.mode == "hold" and " ·hold" or "") end
  end
  Config.bindsChanged:connect(function(changed) if changed == id and chip.Parent then refresh() end end)
  refresh()
  return chip
end

local function contextMenu(anchor, spec, extra)
  local items = {}
  local id = spec.id
  if id then
    items[#items + 1] = { label = "Reset to default", icon = "rotate-ccw", run = function() Config.reset(id) end }
  end
  if spec.bindable and id then
    local bind = Config.bindOf(id)
    items[#items + 1] = { label = bind and "Change key…" or "Bind to a key…", icon = "keyboard", run = function()
      Window.toast({ title = "Press a key", text = "Esc cancels · Backspace clears", icon = "keyboard", time = 2.2 })
      Controls.captureKey(function(key, cancelled)
        if cancelled then return end
        Config.bind(id, key)
        Window.toast({ title = key and ("Bound to " .. Config.keyLabel(key)) or "Key cleared", text = spec.label, icon = "keyboard" })
      end)
    end }
    if bind then
      if spec.kind == "toggle" then
        items[#items + 1] = { label = "Hold to activate", icon = "hand", checked = bind.mode == "hold", run = function()
          Config.bind(id, bind.key, bind.mode == "hold" and "toggle" or "hold")
        end }
      end
      items[#items + 1] = { label = "Clear key", icon = "x", run = function() Config.bind(id, nil) end }
    end
  end
  if extra then
    for _, item in ipairs(extra) do items[#items + 1] = item end
  end
  if #items > 0 then UI.menu(anchor, items, { align = "right" }) end
end

-- ---------------------------------------------------------------- toggle
function Controls.toggle(section, spec)
  spec.kind = "toggle"
  spec.bindable = spec.bindable ~= false
  local id = spec.id
  local value = id and Config.define(id, spec.default == true) or (spec.default == true)
  local row = makeRow(section, spec, spec.children and 92 or 62)
  if id and spec.bindable then
    bindChip(row.slot, id, 1)
    Controls.bindables[id] = { label = spec.label or id, kind = "toggle", page = section.page }
  end

  local track = UI.frame(row.slot, { Name = "Switch", Size = UDim2.fromOffset(42, 24), LayoutOrder = 3, BackgroundTransparency = 0 })
  UI.corner(track, true)
  local knob = UI.frame(track, { Name = "Knob", Size = UDim2.fromOffset(18, 18), Position = UDim2.new(0, 3, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
    BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0 })
  UI.corner(knob, true)
  if UI.fx.shadow then
    local shadow = Instance.new("UIShadow")
    shadow.BlurRadius = UDim.new(0, 5); shadow.Offset = UDim2.fromOffset(0, 1); shadow.Transparency = 0.7
    shadow.Parent = knob
  end
  local pressed = false
  local function paint(instant)
    local on = value
    local color = on and T.accent or T.ink
    local alpha = on and 0 or T.fill3A - 0.05
    local width = pressed and 23 or 18
    local x = on and (42 - 3 - width) or 3
    if instant then
      track.BackgroundColor3, track.BackgroundTransparency = color, alpha
      Motion.snap(knob, "Position", UDim2.new(0, x, 0.5, 0)); Motion.snap(knob, "Size", UDim2.fromOffset(width, 18))
    else
      Motion.to(track, "BackgroundColor3", color, "quick")
      Motion.to(track, "BackgroundTransparency", alpha, "quick")
      Motion.to(knob, "Position", UDim2.new(0, x, 0.5, 0), pressed and "quick" or "bouncy")
      Motion.to(knob, "Size", UDim2.fromOffset(width, 18), "snappy")
    end
  end
  paint(true)
  Theme.changed:connect(function() if track.Parent then paint(true) end end)

  local api = { row = row, id = id }
  function api.get() return value end
  function api.set(next, quiet)
    next = next == true
    if next == value then return end
    if id then Config.set(id, next, quiet) else
      value = next
      paint()
      if spec.changed then B.try("toggle", spec.changed, value) end
    end
  end
  if id then
    Config.on(id, function(next)
      value = next == true
      if track.Parent then paint() end
      if spec.changed then spec.changed(value) end
    end)
    if spec.changed and value then task.defer(B.safe("toggle.init", function() spec.changed(value) end)) end
  end

  -- nested options that only matter when the toggle is on
  local sub
  if spec.children then
    local chevron = UI.frame(row.slot, { Name = "More", Size = UDim2.fromOffset(22, 22), LayoutOrder = 2 })
    local icon = UI.icon(chevron, "chevron-down", 15, "faint", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
    local holder = UI.frame(section.body, { Name = "Sub", Size = UDim2.new(1, 0, 0, 0), ClipsDescendants = true, LayoutOrder = section.count })
    section.count += 1
    holder.LayoutOrder = section.count
    local inner = UI.frame(holder, { Name = "Inner", Size = UDim2.new(1, -18, 0, 0), Position = UDim2.fromOffset(18, 0), AutomaticSize = Enum.AutomaticSize.Y })
    UI.list(inner, "y", 0)
    UI.frame(holder, { Name = "Guide", Size = UDim2.new(0, 1, 1, -12), Position = UDim2.fromOffset(22, 2),
      Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "strokeA" } })
    sub = { body = inner, count = 0, index = section.index, page = section.page, nested = true }
    local open = false
    local built = false
    local function size(instant)
      local h = open and (inner.AbsoluteSize.Y / UI.unit()) or 0
      if instant then Motion.snap(holder, "Size", UDim2.new(1, 0, 0, h)) else Motion.to(holder, "Size", UDim2.new(1, 0, 0, h), "smooth") end
      Motion.to(icon, "Rotation", open and 180 or 0, "snappy")
    end
    local function setOpen(next)
      open = next
      if open and not built then
        built = true
        B.try("toggle.children", spec.children, Window.sectionApi(sub))
      end
      size()
    end
    inner:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() if open then size(true) end end)
    UI.button(chevron, {
      hover = function(on) Theme.bind(icon, "ImageColor3", on and "ink" or "faint") end,
      click = function() UI.sfx("click", 0.5); setOpen(not open) end,
    })
    api.open = setOpen
  end

  UI.button(row.frame, {
    hover = row.hover,
    press = function(on) pressed = on; paint() end,
    click = function()
      UI.sfx(value and "toggle_off" or "toggle_on", 0.7)
      api.set(not value)
    end,
    alt = function() contextMenu(track, spec) end,
  })
  if spec.tip then UI.tooltip(row.frame, spec.tip) end
  return api
end

-- ---------------------------------------------------------------- slider
function Controls.slider(section, spec)
  local id = spec.id
  local min, max, step = spec.min or 0, spec.max or 100, spec.step or 1
  local decimals = spec.decimals or (step < 1 and math.max(0, math.ceil(-math.log10(step))) or 0)
  -- curve: 1 is a straight track. Above 1 the low end of the range gets most of it
  -- (value = min + t ^ curve * span), for a range too wide to set by hand otherwise.
  local curve = spec.curve or 1
  local wide = spec.valueWidth or 64
  local value = id and Config.define(id, spec.default or min) or (spec.default or min)
  local row = makeRow(section, spec, wide + 12)
  row.frame.Name = "Slider"
  local suffix = spec.suffix or ""
  local function text(v) return (spec.format and spec.format(v)) or (util.format(v, decimals) .. suffix) end

  local field = UI.new("TextBox", { Name = "Value", Size = UDim2.fromOffset(wide, 24), BackgroundTransparency = 1, Text = text(value), FontFace = Library.F.mono400,
    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, ClearTextOnFocus = true, LayoutOrder = 2, Theme = { TextColor3 = "sub" },
    PlaceholderText = "", Parent = row.slot })

  -- the track sits under the label, the full width of the row
  local bar = UI.frame(row.left, { Name = "Bar", Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 5 })
  row.left.Size = UDim2.new(1, 0, 0, 0)
  UI.pad(bar, 0, 14, 0, 0)
  local track = UI.frame(bar, { Name = "Track", Size = UDim2.new(1, 0, 0, 4), Position = UDim2.new(0, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
    Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill3A" } })
  UI.corner(track, true)
  local fill = UI.frame(track, { Name = "Fill", Size = UDim2.fromScale(0, 1), Theme = { BackgroundColor3 = "accent" }, BackgroundTransparency = 0 })
  UI.corner(fill, true)
  local knob = UI.frame(track, { Name = "Knob", Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5),
    BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0, ZIndex = 3 })
  UI.corner(knob, true)
  if UI.fx.shadow then
    local shadow = Instance.new("UIShadow")
    shadow.BlurRadius = UDim.new(0, 6); shadow.Offset = UDim2.fromOffset(0, 1); shadow.Transparency = 0.62
    shadow.Parent = knob
  end

  local dragging = false
  local function place(instant)
    local alpha = util.clamp01((value - min) / (max - min)) ^ (1 / curve)
    if instant then
      Motion.snap(fill, "Size", UDim2.fromScale(alpha, 1)); Motion.snap(knob, "Position", UDim2.fromScale(alpha, 0.5))
    else
      Motion.to(fill, "Size", UDim2.fromScale(alpha, 1), "quick"); Motion.to(knob, "Position", UDim2.fromScale(alpha, 0.5), "quick")
    end
    if not field:IsFocused() then field.Text = text(value) end
  end
  place(true)

  local api = { row = row, id = id }
  function api.get() return value end
  function api.set(next, quiet)
    next = math.clamp(util.round(next, step), min, max)
    if decimals > 0 then next = tonumber(string.format("%." .. decimals .. "f", next)) or next end
    if next == value then return end
    if id then Config.set(id, next, quiet) else
      value = next; place()
      if spec.changed then B.try("slider", spec.changed, value) end
    end
  end
  if id then
    Config.on(id, function(next)
      value = next
      if track.Parent then place(dragging) end
      if spec.changed then spec.changed(value) end
    end)
    if spec.changed then task.defer(B.safe("slider.init", function() spec.changed(value) end)) end
  end

  local hit = UI.new("TextButton", { Name = "Hit", Text = "", BackgroundTransparency = 1, AutoButtonColor = false, Size = UDim2.new(1, 14, 1, 0),
    Position = UDim2.fromOffset(-7, 0), ZIndex = 6, Parent = bar })
  local function at(point)
    local x = track.AbsolutePosition.X
    local w = math.max(1, track.AbsoluteSize.X)
    api.set(min + util.clamp01((point.X - x) / w) ^ curve * (max - min))
  end
  UI.drag(hit, function(point)
    dragging = true
    Motion.to(knob, "Size", UDim2.fromOffset(20, 16), "snappy")
    at(point)
  end, function(point) at(point) end, function()
    dragging = false
    Motion.to(knob, "Size", UDim2.fromOffset(14, 14), "bouncy")
    UI.sfx("click", 0.35)
  end)
  hit.MouseEnter:Connect(function() if not dragging then Motion.to(knob, "Size", UDim2.fromOffset(16, 16), "quick") end; row.hover(true) end)
  hit.MouseLeave:Connect(function() if not dragging then Motion.to(knob, "Size", UDim2.fromOffset(14, 14), "quick") end; row.hover(false) end)
  hit.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then contextMenu(knob, spec) end
  end)
  field.FocusLost:Connect(B.safe("slider.field", function()
    local typed = tonumber((string.gsub(field.Text, "[^%d%.%-]", "")))
    if typed then api.set(typed) end
    field.Text = text(value)
    Theme.bind(field, "TextColor3", "sub")
  end))
  field.Focused:Connect(function() Theme.bind(field, "TextColor3", "ink") end)
  return api
end

-- ---------------------------------------------------------------- dropdown / multi-select
local function optionList(options)
  local out = {}
  for _, option in ipairs(options) do
    if type(option) == "table" then out[#out + 1] = { value = option.value or option[1], label = option.label or option[2] or tostring(option.value or option[1]), icon = option.icon }
    else out[#out + 1] = { value = option, label = tostring(option) } end
  end
  return out
end
local function pill(slot, order)
  local button = UI.pressable(slot, { Name = "Select", Size = UDim2.fromOffset(0, 28), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = order or 3,
    Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill2A" } })
  UI.corner(button, "rSmall")
  UI.pad(button, 0, 9, 0, 11)
  UI.list(button, "x", 6, { v = "Center" })
  local label = UI.text(button, "", "label", "ink", { TextSize = 13, LayoutOrder = 1, TextTruncate = Enum.TextTruncate.AtEnd })
  local limit = Instance.new("UISizeConstraint"); limit.MaxSize = Vector2.new(132, 28); limit.Parent = label
  local chevron = UI.icon(button, "chevrons-up-down", 13, "faint", { LayoutOrder = 2 })
  return button, label, chevron
end

function Controls.dropdown(section, spec)
  local id = spec.id
  local options = optionList(spec.options)
  local value = id and Config.define(id, spec.default ~= nil and spec.default or options[1].value) or (spec.default ~= nil and spec.default or options[1].value)
  local row = makeRow(section, spec, 150)
  local button, label = pill(row.slot)
  local function labelOf(v)
    for _, option in ipairs(options) do if option.value == v then return option.label end end
    return tostring(v)
  end
  label.Text = labelOf(value)
  local api = { row = row, id = id }
  function api.get() return value end
  function api.set(next, quiet)
    if next == value then return end
    if id then Config.set(id, next, quiet) else
      value = next; label.Text = labelOf(value)
      if spec.changed then B.try("dropdown", spec.changed, value) end
    end
  end
  function api.options(list)
    options = optionList(list)
    label.Text = labelOf(value)
  end
  if id then
    Config.on(id, function(next)
      value = next
      if label.Parent then label.Text = labelOf(value) end
      if spec.changed then spec.changed(value) end
    end)
    if spec.changed then task.defer(B.safe("dropdown.init", function() spec.changed(value) end)) end
  end
  local function open()
    local items = {}
    for _, option in ipairs(options) do
      items[#items + 1] = { label = option.label, icon = option.icon, checked = option.value == value, run = function() api.set(option.value) end }
    end
    UI.menu(button, items, { align = "right", width = spec.menuWidth })
  end
  UI.wire(button, {
    hover = function(on) Motion.to(button, "BackgroundTransparency", on and T.fill3A or T.fill2A, "quick"); row.hover(on) end,
    click = function() UI.sfx("click", 0.6); open() end,
    alt = function() contextMenu(button, spec) end,
  })
  return api
end

-- value is a set stored as an array of the selected option values
function Controls.multi(section, spec)
  local id = spec.id
  local options = optionList(spec.options)
  local value = id and Config.define(id, spec.default or {}) or (spec.default or {})
  local row = makeRow(section, spec, 150)
  local button, label = pill(row.slot)
  local function has(v) return table.find(value, v) ~= nil end
  local function summary()
    if #value == 0 then return spec.empty or "None" end
    if #value == #options then return "All" end
    if #value <= 2 then
      local names = {}
      for _, option in ipairs(options) do if has(option.value) then names[#names + 1] = option.label end end
      return table.concat(names, ", ")
    end
    return #value .. " selected"
  end
  label.Text = summary()
  local api = { row = row, id = id }
  function api.get() return value end
  function api.has(v) return has(v) end
  function api.set(next, quiet)
    if id then Config.set(id, next, quiet) else
      value = next; label.Text = summary()
      if spec.changed then B.try("multi", spec.changed, value) end
    end
  end
  if id then
    Config.on(id, function(next)
      value = next
      if label.Parent then label.Text = summary() end
      if spec.changed then spec.changed(value) end
    end)
    if spec.changed then task.defer(B.safe("multi.init", function() spec.changed(value) end)) end
  end
  local function flip(v)
    local next = table.clone(value)
    local at = table.find(next, v)
    if at then table.remove(next, at) else next[#next + 1] = v end
    -- keep option order, so two identical selections compare equal
    local ordered = {}
    for _, option in ipairs(options) do if table.find(next, option.value) then ordered[#ordered + 1] = option.value end end
    api.set(ordered)
  end
  local function open()
    UI.popover(button, { width = spec.menuWidth or 212, align = "right" }, function(content)
      local checks = {}
      local function refresh()
        for v, icon in pairs(checks) do icon.ImageTransparency = has(v) and 0 or 1 end
      end
      for index, option in ipairs(options) do
        local item = UI.frame(content, { Size = UDim2.new(1, 0, 0, 32), LayoutOrder = index, Theme = { BackgroundColor3 = "ink" } })
        UI.corner(item, "rSmall")
        local x = 10
        if option.icon then
          UI.icon(item, option.icon, 16, "sub", { Position = UDim2.new(0, 10, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5) })
          x = 34
        end
        UI.text(item, option.label, "label", "ink", { Position = UDim2.new(0, x, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), TextSize = 13 })
        local box = UI.frame(item, { Size = UDim2.fromOffset(16, 16), Position = UDim2.new(1, -10, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5),
          Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill3A" } })
        UI.corner(box, 5)
        checks[option.value] = UI.icon(box, "check", 13, "accent", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
        UI.button(item, {
          hover = function(on) Motion.to(item, "BackgroundTransparency", on and T.fill2A or 1, "quick") end,
          click = function() UI.sfx("click", 0.6); flip(option.value); refresh() end,
        })
      end
      UI.divider(content, #options + 1)
      local footer = UI.frame(content, { Size = UDim2.new(1, 0, 0, 30), LayoutOrder = #options + 2 })
      for index, action in ipairs({ { "All", function() local all = {}; for _, o in ipairs(options) do all[#all + 1] = o.value end; api.set(all) end },
        { "None", function() api.set({}) end } }) do
        local link = UI.new("TextButton", { Text = action[1], FontFace = Library.F.text500, TextSize = 12, BackgroundTransparency = 1, AutoButtonColor = false,
          AutomaticSize = Enum.AutomaticSize.XY, Position = UDim2.new(index == 1 and 0 or 1, index == 1 and 10 or -10, 0.5, 0),
          AnchorPoint = Vector2.new(index == 1 and 0 or 1, 0.5), Theme = { TextColor3 = "sub" }, Parent = footer })
        UI.wire(link, { click = function() UI.sfx("click", 0.5); action[2](); refresh() end,
          hover = function(on) Theme.bind(link, "TextColor3", on and "ink" or "sub") end })
      end
      refresh()
    end)
  end
  UI.wire(button, {
    hover = function(on) Motion.to(button, "BackgroundTransparency", on and T.fill3A or T.fill2A, "quick"); row.hover(on) end,
    click = function() UI.sfx("click", 0.6); open() end,
    alt = function() contextMenu(button, spec) end,
  })
  return api
end

-- ---------------------------------------------------------------- segmented
-- A row of mutually exclusive choices with a pill that slides like liquid:
-- its leading edge arrives first, the trailing edge catches up.
function Controls.segmentedBar(parent, options, initial, onPick, props)
  options = optionList(options)
  local bar = UI.frame(parent, { Name = "Segmented", Size = UDim2.new(1, 0, 0, 30), Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill2A" } })
  UI.corner(bar, "rSmall")
  if props then
    for key, value in pairs(props) do bar[key] = value end
  end
  local count = #options
  local thumb = UI.frame(bar, { Name = "Thumb", Size = UDim2.new(1 / count, -4, 1, -4), Position = UDim2.new(0, 2, 0, 2),
    Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill3A" } })
  UI.corner(thumb, "rSmall")
  local labels = {}
  local current
  -- left and right edges are separate springs (scale units)
  local edges = Motion.spring(2, "snappy", function(x)
    local a, b = math.min(x[1], x[2]), math.max(x[1], x[2])
    thumb.Position = UDim2.new(a, 2, 0, 2)
    thumb.Size = UDim2.new(b - a, -4, 1, -4)
  end, 0.0004)
  local function select(index, instant)
    local previous = current
    current = index
    for i, label in ipairs(labels) do Theme.bind(label, "TextColor3", i == index and "ink" or "sub") end
    local a, b = (index - 1) / count, index / count
    if instant or not previous then edges:snap({ a, b }); return end
    -- the edge in the direction of travel leads
    if index > previous then
      edges.g[2] = b; edges:to({ edges.g[1], b }, "snappy")
      task.delay(0.045, function() edges:to({ a, b }, "liquid") end)
    else
      edges.g[1] = a; edges:to({ a, edges.g[2] }, "snappy")
      task.delay(0.045, function() edges:to({ a, b }, "liquid") end)
    end
  end
  for index, option in ipairs(options) do
    local cell = UI.frame(bar, { Size = UDim2.new(1 / count, 0, 1, 0), Position = UDim2.fromScale((index - 1) / count, 0), ZIndex = 2 })
    labels[index] = UI.text(cell, option.label, "label", "sub", { TextSize = 12.5, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
    UI.button(cell, { click = function()
      if current == index then return end
      UI.sfx("tab", 0.6)
      select(index)
      onPick(option.value, index)
    end })
  end
  local startIndex = 1
  for index, option in ipairs(options) do if option.value == initial then startIndex = index end end
  select(startIndex, true)
  return bar, function(v)
    for index, option in ipairs(options) do if option.value == v then select(index) end end
  end
end

function Controls.segmented(section, spec)
  local id = spec.id
  local options = optionList(spec.options)
  local value = id and Config.define(id, spec.default ~= nil and spec.default or options[1].value) or (spec.default ~= nil and spec.default or options[1].value)
  local width = spec.width or math.min(64 * #options, 220)
  local row = makeRow(section, spec, width)
  local holder = UI.frame(row.slot, { Size = UDim2.fromOffset(width, 30), LayoutOrder = 3 })
  local api = { row = row, id = id }
  local _, show = Controls.segmentedBar(holder, options, value, function(v)
    if id then Config.set(id, v) else
      value = v
      if spec.changed then B.try("segmented", spec.changed, v) end
    end
  end)
  function api.get() return value end
  function api.set(v) if id then Config.set(id, v) else value = v; show(v) end end
  if id then
    Config.on(id, function(next)
      value = next
      if holder.Parent then show(next) end
      if spec.changed then spec.changed(next) end
    end)
    if spec.changed then task.defer(B.safe("segmented.init", function() spec.changed(value) end)) end
  end
  return api
end

-- ---------------------------------------------------------------- button
function Controls.pillButton(parent, text, style, run, props)
  local primary, danger = style == "primary", style == "danger"
  local button = UI.pressable(parent, { Name = "Button", Size = UDim2.fromOffset(0, 28), AutomaticSize = Enum.AutomaticSize.X })
  local function rest() return primary and 0 or (danger and 0.84 or T.fill2A) end
  Theme.bind(button, "BackgroundColor3", primary and "accent" or (danger and "bad" or "ink"))
  button.BackgroundTransparency = rest()
  if not primary and not danger then Theme.bind(button, "BackgroundTransparency", "fill2A") end
  UI.corner(button, "rSmall")
  UI.pad(button, 0, 13)
  local label = UI.text(button, text, "button", primary and "accentInk" or (danger and "bad" or "ink"),
    { Size = UDim2.fromScale(0, 1), AutomaticSize = Enum.AutomaticSize.X })
  local scale = UI.scaleOf(button)
  if props then
    for key, value in pairs(props) do button[key] = value end
  end
  UI.wire(button, {
    hover = function(on)
      local base = rest()
      Motion.to(button, "BackgroundTransparency", on and (primary and 0.14 or math.max(0, base - 0.06)) or base, "quick")
    end,
    press = function(on) Motion.to(scale, "Scale", on and 0.95 or 1, on and "quick" or "bouncy") end,
    click = function() UI.sfx("click", 0.8); if run then run() end end,
  })
  return button, label
end

function Controls.button(section, spec)
  local row = makeRow(section, spec, 110)
  local id = spec.id
  if id then
    Config.action(id, function() if spec.run then spec.run() end end)
    spec.bindable = spec.bindable ~= false
    if spec.bindable then
      bindChip(row.slot, id, 1)
      Controls.bindables[id] = { label = spec.label or id, kind = "button", page = section.page }
    end
  end
  local button, label = Controls.pillButton(row.slot, spec.text or "Run", spec.style, function()
    if spec.run then B.try("button." .. (spec.label or "?"), spec.run) end
  end, { LayoutOrder = 3 })
  button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and id then contextMenu(button, { id = id, bindable = spec.bindable, label = spec.label, kind = "button" }) end
  end)
  return { row = row, button = button, setText = function(text) label.Text = text end }
end

-- ---------------------------------------------------------------- keybind
function Controls.keybind(section, spec)
  local id = spec.id
  local value = id and Config.define(id, spec.default or "None") or (spec.default or "None")
  local row = makeRow(section, spec, 100)
  local chip = UI.pressable(row.slot, { Name = "Key", Size = UDim2.fromOffset(0, 28), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 3,
    Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill2A" } })
  UI.corner(chip, "rSmall")
  UI.pad(chip, 0, 11)
  local floor = Instance.new("UISizeConstraint"); floor.MinSize = Vector2.new(46, 28); floor.Parent = chip
  local label = UI.text(chip, Config.keyLabel(value ~= "None" and value or nil), "monoBold", "ink", { Size = UDim2.fromScale(1, 1),
    AutomaticSize = Enum.AutomaticSize.X, TextXAlignment = Enum.TextXAlignment.Center })
  local stroke = UI.stroke(chip, "accent", 1, 1)
  local api = { row = row, id = id }
  function api.get() return value end
  local function show() label.Text = Config.keyLabel(value ~= "None" and value or nil) end
  if id then
    Config.on(id, function(next)
      value = next
      if label.Parent then show() end
      if spec.changed then spec.changed(next) end
    end)
    if spec.changed then task.defer(B.safe("keybind.init", function() spec.changed(value) end)) end
  end
  UI.wire(chip, {
    hover = function(on) Motion.to(chip, "BackgroundTransparency", on and T.fill3A or T.fill2A, "quick"); row.hover(on) end,
    click = function()
      UI.sfx("click", 0.6)
      label.Text = "…"
      Motion.to(stroke, "Transparency", 0, "quick")
      Controls.captureKey(function(key, cancelled)
        Motion.to(stroke, "Transparency", 1, "smooth")
        if not cancelled then
          local next = key or "None"
          if id then Config.set(id, next) else value = next; if spec.changed then spec.changed(next) end end
        end
        show()
      end)
    end,
    alt = function() contextMenu(chip, spec) end,
  })
  return api
end

-- ---------------------------------------------------------------- text input
function Controls.field(parent, props, onSubmit)
  local field = UI.frame(parent, { Name = "Field", Size = UDim2.fromOffset(150, 28), Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill2A" } })
  UI.corner(field, "rSmall")
  local stroke = UI.stroke(field, "accent", 1, 1)
  local box = UI.new("TextBox", { Name = "Box", BackgroundTransparency = 1, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(10, 0), Text = "",
    FontFace = Library.F.text400, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, ClipsDescendants = true,
    Theme = { TextColor3 = "ink", PlaceholderColor3 = "faint" }, Parent = field })
  if props then
    for key, value in pairs(props) do
      if key == "Width" then field.Size = UDim2.fromOffset(value, 28) else box[key] = value end
    end
  end
  box.Focused:Connect(function() Motion.to(stroke, "Transparency", 0.25, "quick") end)
  box.FocusLost:Connect(B.safe("field", function(enter)
    Motion.to(stroke, "Transparency", 1, "smooth")
    if onSubmit then onSubmit(box.Text, enter) end
  end))
  return field, box
end

function Controls.input(section, spec)
  local id = spec.id
  local value = id and Config.define(id, spec.default or "") or (spec.default or "")
  local row = makeRow(section, spec, spec.width or 150)
  local api = { row = row, id = id }
  local _, box = Controls.field(row.slot, { Width = spec.width or 150, PlaceholderText = spec.placeholder or "", Text = tostring(value) }, function(text)
    if spec.numeric then
      local n = tonumber(text)
      if not n then api.box.Text = tostring(value); return end
      text = n
    end
    if id then Config.set(id, text) else
      value = text
      if spec.changed then B.try("input", spec.changed, text) end
    end
  end)
  api.box = box
  function api.get() return value end
  if id then
    Config.on(id, function(next)
      value = next
      if box.Parent and not box:IsFocused() then box.Text = tostring(next) end
      if spec.changed then spec.changed(next) end
    end)
  end
  return api
end

-- ---------------------------------------------------------------- colour
local function hueColor(h) return Color3.fromHSV(h, 1, 1) end
function Controls.colorPopover(anchor, initial, onChange)
  local h, s, v = initial:ToHSV()
  return UI.popover(anchor, { width = 224, align = "right", pad = 10, gap = 10 }, function(content)
    local square = UI.frame(content, { Name = "SV", Size = UDim2.new(1, 0, 0, 132), BackgroundTransparency = 0, BackgroundColor3 = hueColor(h), LayoutOrder = 1 })
    UI.corner(square, 9)
    local white = UI.frame(square, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0 })
    UI.corner(white, 9)
    UI.gradient(white, { Transparency = UI.alphaSeq(0, 0, 1, 1) })
    local black = UI.frame(square, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0, ZIndex = 2 })
    UI.corner(black, 9)
    UI.gradient(black, { Rotation = 90, Transparency = UI.alphaSeq(0, 1, 1, 0) })
    local dot = UI.frame(square, { Size = UDim2.fromOffset(12, 12), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 4, BackgroundTransparency = 1 })
    UI.corner(dot, true)
    local ring = Instance.new("UIStroke"); ring.Color = Color3.new(1, 1, 1); ring.Thickness = 2; ring.Parent = dot

    local hueBar = UI.frame(content, { Name = "Hue", Size = UDim2.new(1, 0, 0, 12), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0, LayoutOrder = 2 })
    UI.corner(hueBar, true)
    local stops = {}
    for i = 0, 6 do stops[#stops + 1] = ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6 % 1, 1, 1)) end
    UI.gradient(hueBar, { Color = ColorSequence.new(stops) })
    local hueKnob = UI.frame(hueBar, { Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.new(1, 1, 1),
      BackgroundTransparency = 0, ZIndex = 3 })
    UI.corner(hueKnob, true)
    local hueRing = Instance.new("UIStroke"); hueRing.Color = Color3.new(0, 0, 0); hueRing.Transparency = 0.7; hueRing.Parent = hueKnob

    local bottom = UI.frame(content, { Size = UDim2.new(1, 0, 0, 28), LayoutOrder = 3 })
    local preview = UI.frame(bottom, { Size = UDim2.fromOffset(28, 28), BackgroundTransparency = 0, BackgroundColor3 = initial })
    UI.corner(preview, 8)
    local hexField, hexBox
    local function emit(fromHex)
      local color = Color3.fromHSV(h, s, v)
      square.BackgroundColor3 = hueColor(h)
      dot.Position = UDim2.fromScale(s, 1 - v)
      hueKnob.Position = UDim2.fromScale(h, 0.5)
      preview.BackgroundColor3 = color
      if hexBox and not fromHex and not hexBox:IsFocused() then hexBox.Text = "#" .. util.toHex(color) end
      onChange(color)
    end
    hexField, hexBox = Controls.field(bottom, { Width = 96, Text = "#" .. util.toHex(initial), FontFace = Library.F.mono400, TextSize = 12 }, function(text)
      local clean = string.gsub(text, "[^%x]", "")
      if #clean == 6 then
        h, s, v = util.hex(clean):ToHSV()
        emit(true)
      end
      hexBox.Text = "#" .. util.toHex(Color3.fromHSV(h, s, v))
    end)
    hexField.Position = UDim2.fromOffset(36, 0)
    -- quick picks: the accent family
    local picks = UI.frame(content, { Size = UDim2.new(1, 0, 0, 18), LayoutOrder = 4 })
    UI.list(picks, "x", 7)
    for index, accent in ipairs(Theme.accents) do
      local swatch = UI.frame(picks, { Size = UDim2.fromOffset(18, 18), BackgroundTransparency = 0, BackgroundColor3 = accent.color, LayoutOrder = index })
      UI.corner(swatch, true)
      UI.button(swatch, { click = function() h, s, v = accent.color:ToHSV(); emit() end })
    end
    local svHit = UI.new("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 6, AutoButtonColor = false, Parent = square })
    local function sv(point)
      local p, size = square.AbsolutePosition, square.AbsoluteSize
      s = util.clamp01((point.X - p.X) / size.X)
      v = 1 - util.clamp01((point.Y - p.Y) / size.Y)
      emit()
    end
    UI.drag(svHit, sv, sv)
    local hueHit = UI.new("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 12), Position = UDim2.fromOffset(0, -6), ZIndex = 6,
      AutoButtonColor = false, Parent = hueBar })
    local function hue(point)
      h = util.clamp01((point.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X)
      emit()
    end
    UI.drag(hueHit, hue, hue)
    dot.Position = UDim2.fromScale(s, 1 - v)
    hueKnob.Position = UDim2.fromScale(h, 0.5)
  end)
end

function Controls.color(section, spec)
  local id = spec.id
  local value = id and Config.define(id, spec.default or Color3.new(1, 1, 1)) or (spec.default or Color3.new(1, 1, 1))
  local row = makeRow(section, spec, 60)
  local swatch = UI.frame(row.slot, { Name = "Swatch", Size = UDim2.fromOffset(34, 22), BackgroundTransparency = 0, BackgroundColor3 = value, LayoutOrder = 3 })
  UI.corner(swatch, 7)
  UI.stroke(swatch, "ink", "stroke2A")
  local api = { row = row, id = id }
  function api.get() return value end
  function api.set(next, quiet)
    if id then Config.set(id, next, quiet) else
      value = next; swatch.BackgroundColor3 = next
      if spec.changed then B.try("color", spec.changed, next) end
    end
  end
  if id then
    Config.on(id, function(next)
      value = next
      if swatch.Parent then swatch.BackgroundColor3 = next end
      if spec.changed then spec.changed(next) end
    end)
    if spec.changed then task.defer(B.safe("color.init", function() spec.changed(value) end)) end
  end
  local scale = UI.scaleOf(swatch)
  UI.button(swatch, {
    hover = function(on) Motion.to(scale, "Scale", on and 1.08 or 1, "snappy"); row.hover(on) end,
    click = function() UI.sfx("click", 0.6); Controls.colorPopover(swatch, value, function(color) api.set(color) end) end,
    alt = function() contextMenu(swatch, spec) end,
  })
  return api
end

-- ---------------------------------------------------------------- static rows
function Controls.note(section, spec)
  section.count = (section.count or 0) + 1
  local tone = spec.tone or "sub"
  local box = UI.frame(section.body, { Name = "Note", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = section.count })
  UI.pad(box, 10, 14, 12, 14)
  local inner = UI.frame(box, { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y })
  UI.list(inner, "x", 9)
  if spec.icon then UI.icon(inner, spec.icon, 15, tone, { LayoutOrder = 1 }) end
  local text = UI.text(inner, spec.text or "", "caption", tone, { TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2,
    Size = UDim2.new(1, spec.icon and -24 or 0, 0, 0), LineHeight = 1.2, RichText = spec.rich == true })
  return { frame = box, set = function(value) text.Text = value end }
end
function Controls.custom(section, spec)
  section.count = (section.count or 0) + 1
  local frame = UI.frame(section.body, { Name = spec.name or "Custom", Size = UDim2.new(1, 0, 0, spec.height or 100), LayoutOrder = section.count })
  if spec.height == nil then frame.AutomaticSize = Enum.AutomaticSize.Y end
  B.try("custom", spec.build, frame)
  return frame
end
end
-- ============================================================================ window (07_window)
do
-- ============================================================================
--  07 window   the shell: glass, sidebar, pages, cards, toasts, palette, blur
-- ============================================================================
local Controls = Library.Controls

local W, H = 980, 624
local SIDE = 206
local CONTENT_X = SIDE + 20
local CONTENT_W = W - CONTENT_X - 10
local HEADER = 84

-- ---------------------------------------------------------------- real blur
-- Measured: a Glass part a hair in front of the camera plus a DepthOfField with
-- nothing in its focus range blurs the 3D scene inside the part's rectangle only.
-- A rounded window is five rectangles: the body and two steps per end.
local Blur = { enabled = false, parts = {}, visible = false }
B.Blur = Blur
local DEPTH = 0.012
local function blurPart()
  local part = Instance.new("Part")
  part.Name = util.randomName()
  part.Anchored, part.CanCollide, part.CanQuery, part.CanTouch = true, false, false, false
  part.CastShadow = false
  part.Locked = true
  part.Material = Enum.Material.Glass
  part.Color = Color3.new(0, 0, 0)
  part.Transparency = 0.98
  part.Size = Vector3.new(1, 1, 0.001)
  local mesh = Instance.new("SpecialMesh")
  mesh.MeshType = Enum.MeshType.Brick
  mesh.Offset = Vector3.new(0, 0, -0.000001)
  mesh.Parent = part
  return part, mesh
end
function Blur.supported()
  local ok, level = pcall(function() return settings().Rendering.QualityLevel.Value end)
  -- level 0 is Automatic; the effect needs the post-processing tiers
  return ok and (level == 0 or level >= 8)
end
function Blur.start()
  if Blur.dof then return end
  local dof = Instance.new("DepthOfFieldEffect")
  dof.Name = util.randomName()
  dof.FarIntensity, dof.NearIntensity, dof.InFocusRadius, dof.FocusDistance = 0, 1, 0.1, 0.05
  dof.Enabled = false
  dof.Parent = S.Lighting
  Blur.dof = B.own(dof)
  for index = 1, 5 do
    local part, mesh = blurPart()
    Blur.parts[index] = { part = B.own(part), mesh = mesh }
  end
  -- runs after the camera has moved this frame, so the glass never trails it
  S.RunService:BindToRenderStep("BasedBlur", Enum.RenderPriority.Camera.Value + 2, function()
    if not Blur.visible or not B.alive then return end
    B.try("blur", Blur.update)
  end)
  B.own(function() pcall(function() S.RunService:UnbindFromRenderStep("BasedBlur") end) end)
end
local function placePart(camera, slot, x, y, w, h)
  if w < 1 or h < 1 then slot.part.Parent = nil; return end
  local a = camera:ViewportPointToRay(x, y)
  local b = camera:ViewportPointToRay(x + w, y + h)
  local c = camera:ViewportPointToRay(x + w, y)
  local p1, p2, p3 = a.Origin + a.Direction * DEPTH, b.Origin + b.Direction * DEPTH, c.Origin + c.Direction * DEPTH
  local cf = camera.CFrame
  -- A game that clears the camera's children takes the glass with them (Da Hood's own client calls
  -- ClearAllChildren on the camera), and a destroyed part cannot be parented again: make it anew.
  if slot.part.Parent ~= camera and not pcall(function() slot.part.Parent = camera end) then
    local part, mesh = blurPart()
    slot.part, slot.mesh = B.own(part), mesh
    part.Parent = camera
  end
  slot.part.CFrame = CFrame.fromMatrix((p1 + p2) / 2, cf.XVector, cf.YVector, cf.ZVector)
  slot.mesh.Scale = Vector3.new((p3 - p1).Magnitude, (p3 - p2).Magnitude, 0) / slot.part.Size
end
function Blur.update()
  local camera = workspace.CurrentCamera
  local holder = Window.holder
  if not camera or not holder then return end
  -- read the rectangle this frame: a dragged window must not outrun its blur
  local p, s = holder.AbsolutePosition, holder.AbsoluteSize
  local inset = S.GuiService:GetGuiInset()
  local x, y, w, h, r = p.X + inset.X, p.Y + inset.Y, s.X, s.Y, T.rWindow * Window.sizer.Scale
  local parts = Blur.parts
  placePart(camera, parts[1], x, y + r, w, h - 2 * r)
  placePart(camera, parts[2], x + 0.063 * r, y + 0.30 * r, w - 0.126 * r, 0.70 * r)
  placePart(camera, parts[3], x + 0.42 * r, y + 0.07 * r, w - 0.84 * r, 0.23 * r)
  placePart(camera, parts[4], x + 0.063 * r, y + h - r, w - 0.126 * r, 0.70 * r)
  placePart(camera, parts[5], x + 0.42 * r, y + h - 0.30 * r, w - 0.84 * r, 0.23 * r)
end
function Blur.show(on)
  Blur.visible = on and Blur.enabled
  if Blur.dof then Blur.dof.Enabled = Blur.visible end
  if not Blur.visible then
    for _, slot in ipairs(Blur.parts) do slot.part.Parent = nil end
  end
end
function Blur.set(on)
  on = on and Blur.supported()
  Blur.enabled = on
  if on then Blur.start() end
  Theme.set({ blur = on })
  Blur.show(Window.open)
end

-- ---------------------------------------------------------------- toasts
local toasts = {}
local function layoutToasts()
  local y = 0
  for _, toast in ipairs(toasts) do
    Motion.to(toast.holder, "Position", UDim2.new(1, -18, 0, 18 + y), "smooth")
    y += toast.height + 10
  end
end
-- opts: title, text, icon, tone ("accent" | "ok" | "warn" | "bad"), time
function Window.toast(opts)
  if Window.toastHook then
    local taken = Window.toastHook(opts)
    if taken then return taken end
  end
  if not Window.hud then return end
  local tone = opts.tone or "accent"
  local hasText = opts.text ~= nil and opts.text ~= ""
  local toast = { height = hasText and 62 or 46 }
  local holder = UI.frame(Window.hud, { Name = "Toast", AnchorPoint = Vector2.new(1, 0), Size = UDim2.fromOffset(318, toast.height),
    Position = UDim2.new(1, 360, 0, 18) })
  local sizer = Instance.new("UIScale"); sizer.Scale = Window.scale; sizer.Parent = holder
  local glass = UI.glass(holder, { level = "popover", radius = "rCard", shadow = 30, shadowY = 12, props = { Size = UDim2.fromScale(1, 1) } })
  local chip = UI.frame(glass, { Size = UDim2.fromOffset(30, 30), Position = UDim2.new(0, 10, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
    Theme = { BackgroundColor3 = tone }, BackgroundTransparency = 0.84 })
  UI.corner(chip, 9)
  UI.icon(chip, opts.icon or "sparkles", 16, tone, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
  UI.text(glass, opts.title or "", "heading", "ink", { TextSize = 13.5, Position = UDim2.fromOffset(50, hasText and 12 or 14), Size = UDim2.new(1, -64, 0, 18),
    AutomaticSize = Enum.AutomaticSize.None, TextTruncate = Enum.TextTruncate.AtEnd })
  if hasText then
    UI.text(glass, opts.text, "caption", "sub", { Position = UDim2.fromOffset(50, 31), Size = UDim2.new(1, -64, 0, 18), AutomaticSize = Enum.AutomaticSize.None,
      TextTruncate = Enum.TextTruncate.AtEnd })
  end
  local timer = UI.frame(glass, { Size = UDim2.new(1, -28, 0, 2), Position = UDim2.new(0, 14, 1, -5), Theme = { BackgroundColor3 = tone }, BackgroundTransparency = 0.45 })
  UI.corner(timer, true)
  toast.holder = holder
  table.insert(toasts, 1, toast)
  while #toasts > 4 do
    local old = table.remove(toasts)
    old.holder:Destroy()
  end
  layoutToasts()
  local life = opts.time or 3.6
  Motion.tween(life, Motion.ease.linear, function(p) timer.Size = UDim2.new(1 - p, -28 * (1 - p), 0, 2) end)
  local function dismiss()
    if toast.gone then return end
    toast.gone = true
    local at = table.find(toasts, toast)
    if at then table.remove(toasts, at) end
    Motion.to(holder, "Position", UDim2.new(1, 380, 0, holder.Position.Y.Offset), "smooth", function() holder:Destroy() end)
    layoutToasts()
  end
  task.delay(life, function() if B.alive then dismiss() end end)
  UI.button(glass, { click = dismiss })
  UI.sfx(tone == "bad" and "close" or "saved", 0.6)
  return dismiss
end

-- ---------------------------------------------------------------- sections
local SectionApi = {}
SectionApi.__index = SectionApi
for _, kind in ipairs({ "toggle", "slider", "dropdown", "multi", "segmented", "color", "keybind", "button", "input", "note", "custom" }) do
  SectionApi[kind] = function(self, spec) return Controls[kind](self.raw, spec) end
end
function Window.sectionApi(raw) return setmetatable({ raw = raw, body = raw.body }, SectionApi) end

local Page = {}
Page.__index = Page
local function band(page, full)
  page.bandCount += 1
  local frame = UI.frame(page.content, { Name = full and "Full" or "Columns", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
    LayoutOrder = page.bandCount })
  if full then
    UI.list(frame, "y", 12)
    return { full = true, frame = frame }
  end
  local columns = {}
  for i = 1, 2 do
    local column = UI.frame(frame, { Name = "Column" .. i, Size = UDim2.new(0.5, -6, 0, 0), Position = UDim2.new(i == 1 and 0 or 0.5, i == 1 and 0 or 6, 0, 0),
      AutomaticSize = Enum.AutomaticSize.Y })
    UI.list(column, "y", 12)
    columns[i] = { frame = column, count = 0 }
  end
  return { full = false, frame = frame, columns = columns }
end
-- spec: title, desc, icon, full (span both columns), column (1 | 2)
function Page:section(spec)
  spec = spec or {}
  -- built in the background, a tab is assembled one card per frame (see Window.prebuild)
  if self.slicing then task.wait() end
  local current = self.band
  if spec.full then
    current = band(self, true)
    self.band = nil
  elseif not current or current.full then
    current = band(self, false)
    self.band = current
  end
  local host
  if current.full then host = current.frame else
    local column = spec.column and current.columns[spec.column]
      or (current.columns[1].count <= current.columns[2].count and current.columns[1] or current.columns[2])
    column.count += spec.weight or 1
    host = column.frame
  end
  self.sectionCount += 1
  local card = UI.surface(host, { Name = spec.title or "Card", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = self.sectionCount })
  UI.stroke(card, "ink", "strokeA")
  local stack = UI.frame(card, { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y })
  UI.list(stack, "y", 0)
  UI.pad(stack, 0, 0, 4, 0)
  if spec.title then
    local head = UI.frame(stack, { Name = "Head", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 0 })
    UI.pad(head, 14, 14, 8, 14)
    UI.list(head, "y", 3)
    local line = UI.frame(head, { Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 1 })
    UI.list(line, "x", 8, { v = "Center" })
    if spec.icon then UI.icon(line, spec.icon, 16, "accent", { LayoutOrder = 1 }) end
    UI.text(line, spec.title, "heading", "ink", { LayoutOrder = 2 })
    if spec.badge then UI.badge(line, spec.badge, spec.badgeColor, { LayoutOrder = 3 }) end
    if spec.desc then
      UI.text(head, spec.desc, "caption", "sub", { TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 2, LineHeight = 1.15 })
    end
  end
  local body = UI.frame(stack, { Name = "Body", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1 })
  UI.list(body, "y", 0)
  local page = self
  local raw = { body = body, count = spec.title and 1 or 0, page = self, card = card }
  function raw.index(entry)
    entry.page, entry.section = page, spec.title or page.title
    Window.index[#Window.index + 1] = entry
  end
  local api = Window.sectionApi(raw)
  api.card = card
  return api
end
-- a full-width block the caller draws itself
function Page:custom(height, build)
  if self.slicing then task.wait() end
  local current = band(self, true)
  self.band = nil
  local frame = UI.frame(current.frame, { Name = "Custom", Size = UDim2.new(1, 0, 0, height or 0) })
  if not height then frame.AutomaticSize = Enum.AutomaticSize.Y end
  B.try("page.custom", build, frame)
  return frame
end
function Page:empty(icon, title, text)
  return self:custom(380, function(frame)
    local box = UI.frame(frame, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.46), Size = UDim2.fromOffset(420, 0),
      AutomaticSize = Enum.AutomaticSize.Y })
    UI.list(box, "y", 10, { h = "Center" })
    local orb = UI.frame(box, { Size = UDim2.fromOffset(64, 64), Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill2A" }, LayoutOrder = 1 })
    UI.corner(orb, true)
    UI.stroke(orb, "ink", "strokeA")
    UI.icon(orb, icon or "package", 26, "sub", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
    UI.text(box, title or "Nothing here yet", "title", "ink", { LayoutOrder = 2, TextXAlignment = Enum.TextXAlignment.Center })
    UI.text(box, text or "", "body", "sub", { LayoutOrder = 3, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 0),
      AutomaticSize = Enum.AutomaticSize.Y, LineHeight = 1.25 })
  end)
end

-- ---------------------------------------------------------------- pages
-- spec: id, title, icon, group, eyebrow, build(page), order
function Window.page(spec)
  local page = setmetatable({ id = spec.id, title = spec.title, icon = spec.icon or "circle", group = spec.group or "", eyebrow = spec.eyebrow,
    build = spec.build, badge = spec.badge, manual = spec.manual, built = false, bandCount = 0, sectionCount = 0, order = spec.order or (#Window.order + 1) * 10 }, Page)
  Window.pages[spec.id] = page
  Window.order[#Window.order + 1] = page
  table.sort(Window.order, function(a, b) return a.order < b.order end)
  if Window.built then Window.rebuildNav() end
  return page
end
function Window.removePage(id)
  local page = Window.pages[id]
  if not page then return end
  Window.pages[id] = nil
  table.remove(Window.order, table.find(Window.order, page))
  if page.frame then page.holder:Destroy() end
  for index = #Window.index, 1, -1 do
    if Window.index[index].page == page then table.remove(Window.index, index) end
  end
  if Window.built then Window.rebuildNav() end
end
-- background = true builds the tab a card at a time across frames. Measured: built in one go a
-- tab costs 5-25 ms, which is a visible hitch; sliced, no frame carries more than one card.
local function ensureBuilt(page, background)
  if page.built then return end
  page.built = true
  page.slicing = background == true
  local holder = UI.group(Window.pageHost, { Name = page.id, Size = UDim2.fromScale(1, 1), Visible = false })
  local scroller, api = UI.scroll(holder, { Size = UDim2.new(1, 0, 1, 0), Name = "Scroll" })
  local content = UI.frame(scroller, { Name = "Content", Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y })
  UI.list(content, "y", 12)
  UI.pad(content, 2, 0, 18, 0)
  page.holder, page.frame, page.scroll, page.content = holder, scroller, api, content
  local started = os.clock()
  if page.build then B.try("page." .. page.id, page.build, page) end
  if page.sectionCount == 0 and page.bandCount == 0 and not page.manual then
    page:empty("package", "Nothing here yet", "This tab is ready for its controls.")
  end
  page.slicing = false
  page.ready = true
  page.buildMs = (os.clock() - started) * 1000
end
-- Build every tab that has not been opened yet, quietly, so the first visit never stutters and
-- search can find every control. Runs during the intro when there is one.
function Window.prebuild()
  if Window.prebuilding then return end
  Window.prebuilding = true
  for _, page in ipairs(table.clone(Window.order)) do
    if not B.alive then return end
    if Window.pages[page.id] == page and not page.built then
      B.try("page.prebuild", ensureBuilt, page, true)
      task.wait(0.05)
    end
  end
  Window.prebuilding = false
end
Window.ensureBuilt = ensureBuilt

function Window.go(id, instant)
  local page = Window.pages[id]
  if not page or not Window.built then return end
  local previous = Window.current
  if previous == page then return end
  ensureBuilt(page)
  Window.current = page
  UI.closePopovers()
  UI.hideTip()
  if previous and previous.holder then
    local old = previous.holder
    UI.fade(old, 0, "quick")
    Motion.to(old, "Position", UDim2.fromOffset(0, -8), "quick")
  end
  page.holder.Visible = true
  if instant then
    UI.setFade(page.holder, 1)
    page.holder.Position = UDim2.new()
  else
    UI.setFade(page.holder, 0)
    Motion.snap(page.holder, "Position", UDim2.fromOffset(0, 14))
    UI.fade(page.holder, 1, "smooth")
    Motion.to(page.holder, "Position", UDim2.new(), "smooth")
  end
  Window.setTitle(page, instant)
  Window.selectNav(page, instant)
  Window.onPage:fire(page)
  if not instant then UI.sfx("tab", 0.6) end
end

-- ---------------------------------------------------------------- build
local navItems = {}
function Window.build()
  if Window.built then return end
  Window.built = true
  local gui = B.screen(9000)
  local hudGui = B.screen(9100)
  Window.gui, Window.hudGui = gui, hudGui
  Window.hud = UI.frame(hudGui, { Name = "Hud", Size = UDim2.fromScale(1, 1) })
  UI.soundHost = UI.frame(hudGui, { Name = "Sound" })

  -- frees the cursor in first person while the hub is open
  Window.modal = UI.new("TextButton", { Name = "Modal", Text = "", BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 0), Modal = true, Visible = false, Parent = gui })

  local stage = UI.frame(gui, { Name = "Stage", Size = UDim2.fromScale(1, 1) })
  local holder = UI.frame(stage, { Name = "Window", Size = UDim2.fromOffset(W, H), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Visible = false })
  local sizer = Instance.new("UIScale")
  sizer.Parent = holder
  Window.holder, Window.sizer = holder, sizer
  UI.unit = function() return sizer.Scale end

  -- shadow lives outside the canvas: a canvas clips whatever leaves its bounds
  local shadowHost = UI.frame(holder, { Name = "Shadow", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 })
  UI.corner(shadowHost, "rWindow")
  if UI.fx.shadow then
    local shadow = Instance.new("UIShadow")
    shadow.BlurRadius = UDim.new(0, 70)
    shadow.Offset = UDim2.fromOffset(0, 28)
    shadow.Color = Color3.new(0, 0, 0)
    shadow.Transparency = 1
    pcall(function() shadow.ShowBehindParent = false end)
    shadow.Parent = shadowHost
    Window.shadow = shadow
  end

  local root = UI.group(holder, { Name = "Root", Size = UDim2.fromScale(1, 1) })
  UI.corner(root, "rWindow")
  Window.root = root
  local glass, rim = UI.glass(root, { level = "window", radius = "rWindow", name = "Glass", props = { Size = UDim2.fromScale(1, 1), Active = true },
    rimHi = 0.42, rimLo = 0.7, sheenAlpha = 0.95 })
  Window.glass, Window.rim = glass, rim

  -- ---- sidebar
  local side = UI.glass(glass, { level = "panel", radius = "rPanel", name = "Sidebar", fill = "fill1A",
    props = { Size = UDim2.new(0, SIDE, 1, -20), Position = UDim2.fromOffset(10, 10) }, rimHi = 0.72, rimLo = 0.9 })
  Window.side = side
  local brand = UI.frame(side, { Name = "Brand", Size = UDim2.new(1, 0, 0, 58) })
  local mark = UI.frame(brand, { Size = UDim2.fromOffset(0, 26), Position = UDim2.fromOffset(18, 18), AutomaticSize = Enum.AutomaticSize.X })
  UI.list(mark, "x", 3, { v = "Bottom" })
  UI.text(mark, Window.brand.text, "brand", "ink", { LayoutOrder = 1, TextSize = 17 })
  if Window.brand.sub and Window.brand.sub ~= "" then UI.text(mark, Window.brand.sub, "display", "accent", { LayoutOrder = 2, TextSize = 21 }) end
  -- The tabs scroll, between the brand and the user chip (a game with tabs of its own, Music and the
  -- rest of the hub ran past the bottom: Keys sat under the chip and Settings could not be reached).
  local navHost, navScroll = UI.scroll(side, { Name = "Nav", Size = UDim2.new(1, -16, 1, -128), Position = UDim2.fromOffset(8, 60),
    AutomaticCanvasSize = Enum.AutomaticSize.None, ClipsDescendants = true })
  Window.navHost, Window.navScroll = navHost, navScroll
  Window.navPill = UI.frame(Window.navHost, { Name = "Pill", Size = UDim2.new(1, 0, 0, 34), Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill2A" }, Visible = false })
  UI.corner(Window.navPill, "rControl")
  UI.stroke(Window.navPill, "ink", "strokeA")

  -- user chip
  local user = UI.frame(side, { Name = "User", Size = UDim2.new(1, -16, 0, 50), Position = UDim2.new(0, 8, 1, -58), Theme = { BackgroundColor3 = "ink" }, BackgroundTransparency = 1 })
  UI.corner(user, "rControl")
  local avatar = UI.new("ImageLabel", { Name = "Avatar", Size = UDim2.fromOffset(32, 32), Position = UDim2.new(0, 9, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
    BackgroundTransparency = 0, Theme = { BackgroundColor3 = "ink" }, Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LP.UserId) .. "&w=150&h=150", Parent = user })
  avatar.BackgroundTransparency = 0.9
  UI.corner(avatar, true)
  UI.text(user, LP.DisplayName, "label", "ink", { Position = UDim2.fromOffset(50, 9), Size = UDim2.new(1, -78, 0, 17), AutomaticSize = Enum.AutomaticSize.None,
    TextTruncate = Enum.TextTruncate.AtEnd, TextSize = 13 })
  Window.userLine = UI.text(user, "@" .. LP.Name, "caption", "faint", { Position = UDim2.fromOffset(50, 26), Size = UDim2.new(1, -78, 0, 15),
    AutomaticSize = Enum.AutomaticSize.None, TextTruncate = Enum.TextTruncate.AtEnd, TextSize = 11 })
  local more = UI.icon(user, "ellipsis", 16, "faint", { Position = UDim2.new(1, -12, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5) })
  UI.button(user, {
    hover = function(on) Motion.to(user, "BackgroundTransparency", on and T.fill2A or 1, "quick") end,
    click = function()
      local items = {}
      if Window.pages.settings then items[#items + 1] = { label = "Settings", icon = "settings", run = function() Window.go("settings") end } end
      items[#items + 1] = { label = "Search", icon = "search", hint = "Ctrl K", run = function() Window.palette() end }
      items[#items + 1] = "divider"
      items[#items + 1] = { label = "Hide", icon = "eye-off", hint = Config.keyLabel(Config.get("app.key.menu")), run = function() Window.show(false) end }
      items[#items + 1] = { label = "Unload " .. Window.brand.text, icon = "power", danger = true, run = function() Library:Unload() end }
      UI.menu(more, items, { side = "above", align = "left", width = 214 })
    end,
  })

  -- ---- header
  local header = UI.frame(glass, { Name = "Header", Size = UDim2.new(0, CONTENT_W, 0, HEADER), Position = UDim2.fromOffset(CONTENT_X, 6) })
  Window.header = header
  Window.eyebrow = UI.text(header, "", "eyebrow", "faint", { Position = UDim2.fromOffset(2, 13) })
  local titleClip = UI.frame(header, { Name = "TitleClip", Size = UDim2.new(1, -250, 0, 46), Position = UDim2.fromOffset(0, 27), ClipsDescendants = true })
  Window.titleClip = titleClip
  -- search pill
  local search = UI.frame(header, { Name = "Search", Size = UDim2.fromOffset(170, 32), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -78, 0, 22),
    Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill1A" } })
  UI.corner(search, true)
  UI.stroke(search, "ink", "strokeA")
  UI.icon(search, "search", 15, "faint", { Position = UDim2.new(0, 12, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5) })
  UI.text(search, "Search", "body", "faint", { Position = UDim2.new(0, 34, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5) })
  local hint = UI.frame(search, { Size = UDim2.fromOffset(0, 18), AutomaticSize = Enum.AutomaticSize.X, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
    Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill2A" } })
  UI.corner(hint, 6); UI.pad(hint, 0, 6)
  UI.text(hint, "Ctrl K", "mono", "faint", { TextSize = 10.5, Size = UDim2.fromScale(0, 1), AutomaticSize = Enum.AutomaticSize.X })
  UI.button(search, {
    hover = function(on) Motion.to(search, "BackgroundTransparency", on and T.fill2A or T.fill1A, "quick") end,
    click = function() Window.palette() end,
  })
  -- window buttons
  local function roundButton(icon, x, tone, run, tip)
    local button = UI.frame(header, { Size = UDim2.fromOffset(30, 30), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, x, 0, 23),
      Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill1A" } })
    UI.corner(button, true)
    local glyph = UI.icon(button, icon, 15, "sub", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
    local scale = UI.scaleOf(button)
    local hit = UI.button(button, {
      hover = function(on)
        Motion.to(button, "BackgroundTransparency", on and (tone and 0.8 or T.fill3A) or T.fill1A, "quick")
        Theme.bind(button, "BackgroundColor3", on and tone or "ink")
        Theme.bind(glyph, "ImageColor3", on and (tone or "ink") or "sub")
      end,
      press = function(on) Motion.to(scale, "Scale", on and 0.9 or 1, on and "quick" or "bouncy") end,
      click = run,
    })
    UI.tooltip(hit, tip)
  end
  roundButton("x", -4, "bad", function() Window.show(false) end, "Hide (" .. Config.keyLabel(Config.get("app.key.menu")) .. ")")
  roundButton("minus", -40, nil, function() Window.show(false) end, "Minimise to the island")

  -- ---- pages
  Window.pageHost = UI.frame(glass, { Name = "Pages", Size = UDim2.new(0, CONTENT_W, 1, -(HEADER + 16)), Position = UDim2.fromOffset(CONTENT_X, HEADER + 6), ClipsDescendants = true })
  -- soft edge where content scrolls under the header
  local fade = UI.frame(glass, { Name = "EdgeTop", Size = UDim2.new(0, CONTENT_W, 0, 14), Position = UDim2.fromOffset(CONTENT_X, HEADER + 6), ZIndex = 7,
    Theme = { BackgroundColor3 = "base" }, BackgroundTransparency = 0, Interactable = false })
  UI.gradient(fade, { Rotation = 90, Transparency = UI.alphaSeq(0, 0.25, 1, 1) })
  Window.edgeTop = fade

  UI.mountOverlay(gui, function() return sizer.Scale end)

  -- ---- drag (header and sidebar brand), spring-followed
  local position = Motion.spring(2, "snappy", function(x) holder.Position = UDim2.fromOffset(x[1], x[2]) end, 0.2)
  Window.position = position
  local function clampTo(x, y)
    local view = B.viewport()
    local hw, hh = W * sizer.Scale / 2, H * sizer.Scale / 2
    return math.clamp(x, 140 - hw, view.X + hw - 140), math.clamp(y, hh * 0.25, view.Y + hh - 80)
  end
  Window.clampTo = clampTo
  local startX, startY
  local function dragFrom(handle)
    UI.drag(handle, function()
      UI.closePopovers()
      startX, startY = position.g[1], position.g[2]
    end, function(_, delta)
      local x, y = clampTo(startX + delta.X, startY + delta.Y)
      position:to({ x, y }, "quick")
    end, function()
      local view = B.viewport()
      Config.set("app.window.x", position.g[1] / view.X)
      Config.set("app.window.y", position.g[2] / view.Y)
    end)
  end
  local grip = UI.new("TextButton", { Name = "Grip", Text = "", BackgroundTransparency = 1, AutoButtonColor = false, Size = UDim2.new(1, -260, 1, 0), ZIndex = 2, Parent = header })
  dragFrom(grip)
  local grip2 = UI.new("TextButton", { Name = "Grip", Text = "", BackgroundTransparency = 1, AutoButtonColor = false, Size = UDim2.fromScale(1, 1), ZIndex = 2, Parent = brand })
  dragFrom(grip2)

  -- the rim highlight leans toward the pointer: glass catching a light
  local rimAngle = Motion.spring(1, "gentle", function(x) rim.Rotation = x[1] end, 0.05)
  rimAngle:snap({ 52 })
  Motion.every(function()
    if not Window.open then return end
    local mouse = UI.mouse()
    local p, s = holder.AbsolutePosition, holder.AbsoluteSize
    local dx, dy = mouse.X - (p.X + s.X / 2), mouse.Y - (p.Y + s.Y / 2)
    -- the gradient's bright end sits at angle+180: point it at the cursor
    local angle = math.deg(math.atan2(dy, dx)) + 180
    local current = rimAngle.g[1]
    local diff = (angle - current + 180) % 360 - 180
    if math.abs(diff) > 1.5 then rimAngle:to({ current + diff }) end
  end, 30, "window.rim")

  Window.rebuildNav()
  Window.rescale()
  B.connect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function() Window.rescale() end, "window.viewport")
end

function Window.rescale()
  if not Window.built then return end
  local view = B.viewport()
  local auto = math.clamp(math.min(view.Y / 1090, view.X / 1500), 0.55, 1.5)
  local user = (Config.get("app.scale") or 100) / 100
  local scale = math.min(auto * user, (view.X - 24) / W, (view.Y - 24) / H)
  Window.scale = scale
  Motion.to(Window.sizer, "Scale", scale * (Window.open and 1 or 0.95), "smooth")
  local fx, fy = Config.get("app.window.x") or 0.5, Config.get("app.window.y") or 0.5
  local x, y = Window.clampTo(fx * view.X, fy * view.Y)
  Window.position:snap({ x, y })
end

-- ---------------------------------------------------------------- nav
local selected = Motion.spring(2, "snappy", function(x)
  local pill = Window.navPill
  if not pill then return end
  local a, b = math.min(x[1], x[2]), math.max(x[1], x[2])
  pill.Position = UDim2.fromOffset(0, a)
  pill.Size = UDim2.new(1, 0, 0, math.max(8, b - a))
end, 0.15)
function Window.rebuildNav()
  local host = Window.navHost
  for _, item in ipairs(navItems) do item.frame:Destroy() end
  for _, child in ipairs(host:GetChildren()) do
    if child.Name == "Group" then child:Destroy() end
  end
  table.clear(navItems)
  local y = 0
  local lastGroup
  for _, page in ipairs(Window.order) do
    if not page.hidden then
      if page.group ~= lastGroup then
        lastGroup = page.group
        if page.group ~= "" then
          y += 10
          local label = UI.text(host, string.upper(page.group), "eyebrow", "faint", { Name = "Group", Position = UDim2.fromOffset(12, y), TextSize = 9 })
          label.Name = "Group"
          y += 22
        end
      end
      local item = UI.frame(host, { Name = "Item", Size = UDim2.new(1, 0, 0, 34), Position = UDim2.fromOffset(0, y), Theme = { BackgroundColor3 = "ink" }, ZIndex = 2 })
      UI.corner(item, "rControl")
      local icon = UI.icon(item, page.icon, 17, "sub", { Position = UDim2.new(0, 12, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5) })
      local label = UI.text(item, page.title, "label", "sub", { Position = UDim2.new(0, 39, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), TextSize = 13.5 })
      if page.badge then UI.badge(item, page.badge, "accent", { Position = UDim2.new(1, -10, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5) }) end
      local entry = { frame = item, icon = icon, label = label, page = page, y = y }
      navItems[#navItems + 1] = entry
      UI.button(item, {
        hover = function(on)
          if Window.current == page then return end
          Motion.to(item, "BackgroundTransparency", on and 0.955 or 1, "quick")
        end,
        click = function() Window.go(page.id) end,
      })
      y += 36
    end
  end
  host.CanvasSize = UDim2.fromOffset(0, y + 6)
  if Window.current then Window.selectNav(Window.current, true) end
end
function Window.selectNav(page, instant)
  local target
  for _, entry in ipairs(navItems) do
    local on = entry.page == page
    Theme.bind(entry.icon, "ImageColor3", on and "accent" or "sub")
    Theme.bind(entry.label, "TextColor3", on and "ink" or "sub")
    Motion.to(entry.frame, "BackgroundTransparency", 1, "quick")
    if on then target = entry end
  end
  if not target then Window.navPill.Visible = false; return end
  local a, b = target.y, target.y + 34
  -- (scrolled so the chosen tab is in view)
  local host, scroll = Window.navHost, Window.navScroll
  if host and scroll then
    local view = host.AbsoluteWindowSize.Y / math.max(UI.unit(), 0.01)
    local at = host.CanvasPosition.Y / math.max(UI.unit(), 0.01)
    if a < at + 4 then scroll.to((a - 12) * UI.unit(), instant) elseif b > at + view - 4 then scroll.to((b - view + 12) * UI.unit(), instant) end
  end
  if instant or not Window.navPill.Visible then
    Window.navPill.Visible = true
    selected:snap({ a, b })
    return
  end
  -- liquid: the edge facing the destination moves first, the other one follows
  local down = a > selected.g[1]
  if down then selected:to({ selected.g[1], b }, "snappy") else selected:to({ a, selected.g[2] }, "snappy") end
  task.delay(0.05, function() if Window.current == page then selected:to({ a, b }, "liquid") end end)
end

-- title: the old one slides up out of a mask, the new one rises into it
function Window.setTitle(page, instant)
  local clip = Window.titleClip
  local old = Window.titleLabel
  local label = UI.text(clip, page.title, "display", "ink", { Position = UDim2.fromOffset(0, instant and 2 or 46), Name = "Title" })
  Window.titleLabel = label
  Window.eyebrow.Text = string.upper(page.eyebrow or (page.group ~= "" and page.group or Window.brand.text))
  if instant then
    if old then old:Destroy() end
    return
  end
  Motion.to(label, "Position", UDim2.fromOffset(0, 2), "smooth")
  if old then Motion.to(old, "Position", UDim2.fromOffset(0, -46), "smooth", function() old:Destroy() end) end
end

-- ---------------------------------------------------------------- show / hide
function Window.show(on, instant)
  if not Window.built or Window.open == on then return end
  Window.open = on
  UI.closePopovers()
  UI.hideTip()
  local holder, root, sizer = Window.holder, Window.root, Window.sizer
  Window.modal.Visible = on and Config.get("app.freeCursor") ~= false
  if on then
    holder.Visible = true
    if not Window.current and Window.order[1] then Window.go(Window.startPage or Window.order[1].id, true) end
    if instant then
      UI.setFade(root, 1); Motion.snap(sizer, "Scale", Window.scale)
      if Window.shadow then Window.shadow.Transparency = T.shadowA end
    else
      UI.setFade(root, 0)
      Motion.snap(sizer, "Scale", Window.scale * 0.94)
      UI.fade(root, 1, "smooth")
      Motion.to(sizer, "Scale", Window.scale, "bouncy")
      if Window.shadow then Motion.to(Window.shadow, "Transparency", T.shadowA, "gentle") end
      UI.sfx("open", 0.8)
    end
    Blur.show(true)
  else
    if Window.shadow then Motion.to(Window.shadow, "Transparency", 1, "quick") end
    Motion.to(sizer, "Scale", Window.scale * 0.96, "quick")
    Blur.show(false)
    UI.fade(root, 0, "quick", function() if not Window.open then holder.Visible = false end end)
    if not root:IsA("CanvasGroup") then holder.Visible = false end
    UI.sfx("close", 0.7)
  end
  Window.onShow:fire(on)
end
function Window.toggle() Window.show(not Window.open) end
function Window.anyOpen() return Window.open end
function Window.showing(id) return Window.open and Window.current ~= nil and Window.current.id == id end

-- ---------------------------------------------------------------- command palette
local palette
function Window.palette()
  if palette then palette.close(); return end
  if not Window.built then return end
  if not Window.open then Window.show(true) end
  -- everything has to exist before it can be found
  for _, page in ipairs(Window.order) do ensureBuilt(page) end
  local scale = Window.scale
  local view = B.viewport()
  local veil = UI.new("TextButton", { Name = "Veil", Text = "", AutoButtonColor = false, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = 1, ZIndex = 70, Parent = UI.overlay })
  Motion.to(veil, "BackgroundTransparency", 0.62, "smooth")
  -- over the hub, wherever the hub has been dragged to
  local at, size = Window.holder.AbsolutePosition - UI.overlay.AbsolutePosition, Window.holder.AbsoluteSize
  local half = 270 * scale
  local holder = UI.frame(veil, { Name = "Palette", Size = UDim2.fromOffset(540, 0), AutomaticSize = Enum.AutomaticSize.Y, AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.fromOffset(math.clamp(at.X + size.X * 0.5, half + 12, math.max(half + 12, view.X - half - 12)), math.clamp(at.Y + 72 * scale, 16, math.max(16, view.Y - 420 * scale))),
    ZIndex = 71 })
  local sizer = Instance.new("UIScale"); sizer.Scale = scale * 0.95; sizer.Parent = holder
  Motion.to(sizer, "Scale", scale, "bouncy")
  local glass = UI.glass(holder, { level = "popover", radius = "rPanel", shadow = 60, shadowY = 26, props = { Size = UDim2.fromScale(1, 0), AutomaticSize = Enum.AutomaticSize.Y, Active = true } })
  local stack = UI.frame(glass, { Size = UDim2.fromScale(1, 0), AutomaticSize = Enum.AutomaticSize.Y })
  UI.list(stack, "y", 0)
  local top = UI.frame(stack, { Size = UDim2.new(1, 0, 0, 54), LayoutOrder = 1 })
  UI.icon(top, "search", 18, "sub", { Position = UDim2.new(0, 18, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5) })
  local box = UI.new("TextBox", { BackgroundTransparency = 1, Size = UDim2.new(1, -110, 1, 0), Position = UDim2.fromOffset(48, 0), Text = "", PlaceholderText = "Search every setting and tab",
    FontFace = B.F.text500, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Theme = { TextColor3 = "ink", PlaceholderColor3 = "faint" }, Parent = top })
  UI.text(top, "esc", "mono", "faint", { Position = UDim2.new(1, -18, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), TextSize = 11 })
  UI.divider(stack, 2)
  local list = UI.frame(stack, { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 3 })
  UI.pad(list, 6)
  UI.list(list, "y", 2)
  local rows, results, cursor = {}, {}, 1
  local connection
  local api = {}
  function api.close()
    if not palette then return end
    palette = nil
    if connection then connection:Disconnect() end
    Motion.to(veil, "BackgroundTransparency", 1, "quick", function() veil:Destroy() end)
    holder:Destroy()
  end
  local function highlight()
    for index, row in ipairs(rows) do
      Motion.to(row, "BackgroundTransparency", index == cursor and T.fill2A or 1, "quick")
    end
  end
  local function run(result)
    if not result then return end
    api.close()
    if result.kind == "page" then Window.go(result.page.id); return end
    Window.go(result.page.id)
    task.delay(0.12, function()
      local entry = result.entry
      if not entry.row.frame.Parent then return end
      local scroller = result.page.frame
      local offset = (entry.row.frame.AbsolutePosition.Y - scroller.AbsolutePosition.Y + scroller.CanvasPosition.Y) - 90 * Window.scale
      result.page.scroll.to(offset)
      entry.row.flash()
    end)
  end
  local function refresh()
    for _, row in ipairs(rows) do row:Destroy() end
    table.clear(rows); table.clear(results)
    local query = box.Text
    local scored = {}
    for _, page in ipairs(Window.order) do
      local score = util.fuzzy(query, page.title)
      if score then scored[#scored + 1] = { kind = "page", page = page, label = page.title, sub = "Tab", icon = page.icon, score = score + 1.5 } end
    end
    for _, entry in ipairs(Window.index) do
      local score = util.fuzzy(query, entry.label)
      if not score and query ~= "" and entry.desc ~= "" then
        local other = util.fuzzy(query, entry.desc)
        score = other and other - 4 or nil
      end
      if score then
        scored[#scored + 1] = { kind = "control", page = entry.page, entry = entry, label = entry.label, sub = entry.page.title .. "  ›  " .. tostring(entry.section),
          icon = entry.page.icon, score = score }
      end
    end
    table.sort(scored, function(a, b) return a.score > b.score end)
    for index = 1, math.min(8, #scored) do
      local result = scored[index]
      results[index] = result
      local row = UI.frame(list, { Size = UDim2.new(1, 0, 0, 40), LayoutOrder = index, Theme = { BackgroundColor3 = "ink" } })
      UI.corner(row, "rSmall")
      UI.icon(row, result.icon, 16, result.kind == "page" and "accent" or "sub", { Position = UDim2.new(0, 12, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5) })
      UI.text(row, result.label, "label", "ink", { Position = UDim2.new(0, 40, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), TextSize = 13.5 })
      UI.text(row, result.sub, "caption", "faint", { Position = UDim2.new(1, -12, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), TextSize = 11.5 })
      UI.button(row, { hover = function(on) if on then cursor = index; highlight() end end, click = function() run(result) end })
      rows[index] = row
    end
    if #scored == 0 then
      local row = UI.frame(list, { Size = UDim2.new(1, 0, 0, 56) })
      UI.text(row, "No setting matches “" .. query .. "”", "body", "faint", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
      rows[1] = row
    end
    cursor = 1
    highlight()
  end
  box:GetPropertyChangedSignal("Text"):Connect(B.safe("palette", refresh))
  connection = UIS.InputBegan:Connect(B.safe("palette.key", function(input)
    if input.KeyCode == Enum.KeyCode.Down then cursor = math.min(#results, cursor + 1); highlight()
    elseif input.KeyCode == Enum.KeyCode.Up then cursor = math.max(1, cursor - 1); highlight()
    elseif input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then run(results[cursor])
    elseif input.KeyCode == Enum.KeyCode.Escape then api.close() end
  end))
  veil.Activated:Connect(function() api.close() end)
  palette = api
  refresh()
  box:CaptureFocus()
  UI.sfx("open", 0.6)
end
end

-- ============================================================================ preferences (the "app." flags)
local Controls = Library.Controls
local Blur = Library.Blur
local function definePrefs()
  Config.define("app.scheme", "dark")
  Config.define("app.accent", Theme.accents[1].color)
  Config.define("app.glass", 60)
  Config.define("app.blur", false)
  Config.define("app.radius", 100)
  Config.define("app.motionSpeed", 100)
  Config.define("app.sfx", true)
  Config.define("app.sfxVolume", 45)
  Config.define("app.scrollbar", "always")
  Config.define("app.font", "inter")
end
local function applyPrefs()
  Theme.state.scheme = Config.get("app.scheme")
  Theme.state.accent = Config.get("app.accent")
  Theme.state.glass = Config.get("app.glass") / 100
  Theme.state.radius = Config.get("app.radius") / 100
  Theme.apply()
  Motion.speed = Config.get("app.motionSpeed") / 100
  UI.sfxOn = Config.get("app.sfx")
  UI.sfxVolume = Config.get("app.sfxVolume") / 100
  UI.setScrollbar(Config.get("app.scrollbar"))
  Blur.set(Config.get("app.blur") == true)
  if Config.get("app.font") ~= "inter" then UI.setLetters(Config.get("app.font")) end
  Config.on("app.scheme", function(v) Theme.set({ scheme = v }) end)
  Config.on("app.accent", function(v) Theme.set({ accent = v }) end)
  Config.on("app.glass", function(v) Theme.set({ glass = v / 100 }) end)
  Config.on("app.radius", function(v) Theme.set({ radius = v / 100 }) end)
  Config.on("app.blur", function(v) Blur.set(v == true) end)
  Config.on("app.scale", function() if Window.built then Window.rescale() end end)
  Config.on("app.motionSpeed", function(v) Motion.speed = v / 100 end)
  Config.on("app.sfx", function(v) UI.sfxOn = v end)
  Config.on("app.sfxVolume", function(v) UI.sfxVolume = v / 100 end)
  Config.on("app.scrollbar", function(v) UI.setScrollbar(v) end)
  Config.on("app.font", function(v) UI.setLetters(v) end)
  Config.on("app.freeCursor", function(v) if Window.modal then Window.modal.Visible = Window.open and v end end)
end

-- ============================================================================ public api
local function lowerFirst(key) return string.lower(string.sub(key, 1, 1)) .. string.sub(key, 2) end
-- accept both the original lower-case spec (label, desc, id, default, changed) and Capitalised names
local function normalize(kind, spec)
  local out = {}
  for key, value in pairs(spec or {}) do
    out[key] = value
    if type(key) == "string" then
      local lowered = lowerFirst(key)
      if out[lowered] == nil then out[lowered] = value end
    end
  end
  out.label = out.label or out.name or out.title
  out.desc = out.desc or out.description
  out.id = out.id or out.flag
  if out.default == nil and out.value ~= nil then out.default = out.value end
  out.options = out.options or out.values
  if kind == "button" then
    out.run = out.run or out.callback
    out.text = out.text or out.buttonText or "Run"
  elseif kind == "keybind" then
    out.changed = out.changed or out.callback
    if typeof(out.default) == "EnumItem" then out.default = out.default.Name end
  elseif kind ~= "section" and kind ~= "tab" then
    out.changed = out.changed or out.callback
  end
  if kind == "section" then out.title = out.title or out.name or out.label end
  return out
end

local Section = {}
Section.__index = Section
local function wrapSection(api) return setmetatable({ api = api, card = api.card }, Section) end
local KINDS = { Toggle = "toggle", Slider = "slider", Dropdown = "dropdown", Multi = "multi", Segmented = "segmented", Color = "color",
  Keybind = "keybind", Button = "button", Input = "input", Note = "note", Custom = "custom" }
for method, kind in pairs(KINDS) do
  Section["Add" .. method] = function(self, spec)
    spec = normalize(kind, spec)
    if kind == "toggle" and spec.children then
      local user = spec.children
      spec.children = function(sub) user(wrapSection(sub)) end
    end
    local control = self.api[kind](self.api, spec)
    if type(control) == "table" then control.Get, control.Set = control.get, control.set end
    return control
  end
end
Section.AddMultiDropdown = Section.AddMulti

local Tab = {}
Tab.__index = Tab
function Tab:AddSection(spec)
  Window.ensureBuilt(self.page)
  return wrapSection(self.page:section(normalize("section", spec)))
end
function Tab:AddCustom(height, build)
  Window.ensureBuilt(self.page)
  return self.page:custom(height, build)
end
function Tab:AddEmpty(icon, title, text)
  Window.ensureBuilt(self.page)
  return self.page:empty(icon, title, text)
end
function Tab:Select() Window.go(self.page.id) end

local WinObj = {}
WinObj.__index = WinObj
local slugs = 0
function WinObj:AddTab(spec)
  spec = normalize("tab", spec)
  local title = spec.title or "Tab"
  local id = spec.id or string.lower((string.gsub(title, "%W", "")))
  if id == "" or Window.pages[id] then slugs += 1; id = id .. slugs end
  local tab = setmetatable({}, Tab)
  local lazy = spec.build
  tab.page = Window.page({ id = id, title = title, icon = spec.icon or "circle", group = spec.group, eyebrow = spec.eyebrow, order = spec.order,
    badge = spec.badge, manual = true, build = lazy and function() lazy(tab) end or nil })
  tab.Id = id
  if Window.open and not Window.current then Window.go(id, true) end
  return tab
end
function WinObj:Show(on, instant) Window.show(on ~= false, instant) end
function WinObj:Toggle() Window.toggle() end
function WinObj:Select(tab) Window.go(type(tab) == "table" and tab.Id or tostring(tab)) end
function WinObj:Search() Window.palette() end
function WinObj:Notify(opts) return Library:Notify(opts) end
function WinObj:SetKey(key)
  if typeof(key) == "EnumItem" then key = key.Name end
  Config.set("app.key.menu", key)
end
function WinObj:Destroy() Library:Unload() end

-- the accent row: a swatch per preset, then any colour
local function accentPicker(frame)
  local row = UI.frame(frame, { Size = UDim2.new(1, -28, 0, 30), Position = UDim2.fromOffset(14, 8) })
  UI.list(row, "x", 9, { v = "Center" })
  local rings = {}
  local function mark()
    local current = Config.get("app.accent")
    for color, ring in pairs(rings) do
      Motion.to(ring, "Transparency", util.toHex(color) == util.toHex(current) and 0 or 1, "quick")
    end
  end
  for index, accent in ipairs(Theme.accents) do
    local swatch = UI.frame(row, { Size = UDim2.fromOffset(24, 24), BackgroundTransparency = 0, BackgroundColor3 = accent.color, LayoutOrder = index })
    UI.corner(swatch, true)
    local ring = Instance.new("UIStroke")
    ring.Thickness = 2
    ring.Transparency = 1
    pcall(function() ring.BorderStrokePosition = Enum.BorderStrokePosition.Outer end)
    pcall(function() ring.BorderOffset = UDim.new(0, 2) end)
    Theme.bind(ring, "Color", "ink")
    ring.Parent = swatch
    rings[accent.color] = ring
    local scale = UI.scaleOf(swatch)
    local hit = UI.button(swatch, {
      hover = function(on) Motion.to(scale, "Scale", on and 1.12 or 1, "snappy") end,
      click = function() UI.sfx("click", 0.6); Config.set("app.accent", accent.color) end,
    })
    UI.tooltip(hit, accent.label)
  end
  local custom = UI.frame(row, { Size = UDim2.fromOffset(24, 24), LayoutOrder = 99, Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill2A" } })
  UI.corner(custom, true)
  UI.icon(custom, "pipette", 13, "sub", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
  local hit = UI.button(custom, { click = function()
    Controls.colorPopover(custom, Config.get("app.accent"), function(color) Config.set("app.accent", color) end)
  end })
  UI.tooltip(hit, "Any colour")
  Config.on("app.accent", function() if row.Parent then mark() end end)
  mark()
end

-- a ready-made Settings tab: scheme, accent, glass, shape, scale, motion, menu key, profiles
function WinObj:AddSettingsTab(spec)
  spec = spec or {}
  local tab = self:AddTab({ Id = "settings", Title = "Settings", Icon = "settings", Group = spec.Group or "System", Order = 9999, Eyebrow = "PREFERENCES" })
  local look = tab:AddSection({ Title = "Appearance", Icon = "palette", Desc = "Colour, glass and shape of the window.", Column = 1 })
  look:AddSegmented({ Id = "app.scheme", Label = "Scheme", Width = 228, Default = "dark",
    Options = { { "dark", "Graphite" }, { "midnight", "Midnight" }, { "light", "Porcelain" } } })
  look:AddCustom({ Height = 46, Build = function(frame) accentPicker(frame) end })
  look:AddSlider({ Id = "app.glass", Label = "Glass", Min = 0, Max = 100, Default = 60, Suffix = "%" })
  look:AddSlider({ Id = "app.radius", Label = "Corner radius", Min = 40, Max = 140, Step = 5, Default = 100, Suffix = "%" })
  look:AddSlider({ Id = "app.scale", Label = "Interface size", Min = 60, Max = 150, Step = 5, Default = 100, Suffix = "%" })
  look:AddToggle({ Id = "app.blur", Label = "Background blur", Desc = "Blurs the game behind the window. Needs a higher graphics level.", Default = false })
  local fonts = {}
  for _, family in ipairs(UI.FAMILIES) do fonts[#fonts + 1] = { family[1], family[2] } end
  look:AddDropdown({ Id = "app.font", Label = "Font", Options = fonts, Default = "inter", MenuWidth = 220 })
  look:AddDropdown({ Id = "app.scrollbar", Label = "Scrollbar", Default = "always", Options = { { "always", "Always" }, { "auto", "While scrolling" }, { "off", "Off" } } })

  local feel = tab:AddSection({ Title = "Interface", Icon = "sliders-horizontal", Desc = "Keys, cursor and motion.", Column = 2 })
  feel:AddKeybind({ Id = "app.key.menu", Label = "Menu key", Desc = "Shows and hides the window.", Default = "V" })
  feel:AddToggle({ Id = "app.freeCursor", Label = "Free the cursor", Desc = "Unlocks the mouse in first person while the window is open.", Default = true })
  feel:AddSlider({ Id = "app.motionSpeed", Label = "Animation speed", Min = 50, Max = 200, Step = 5, Default = 100, Suffix = "%" })
  feel:AddToggle({ Id = "app.sfx", Label = "Sounds", Desc = "Click and toggle sounds (needs the hub's sfx files).", Default = true })
  feel:AddSlider({ Id = "app.sfxVolume", Label = "Sound volume", Min = 0, Max = 100, Default = 45, Suffix = "%" })

  local data = tab:AddSection({ Title = "Profile", Icon = "save", Desc = "Saved to " .. Config.folder .. "/" .. Config.profile .. ".json (needs file access).", Column = 2 })
  data:AddButton({ Label = "Save settings", Text = "Save", Style = "primary", Callback = function()
    local ok = Config.save()
    Library:Notify({ Title = ok and "Settings saved" or "Could not save", Text = ok and Config.profile or "This executor has no file access", Icon = "save", Tone = ok and "ok" or "bad" })
  end })
  data:AddButton({ Label = "Load settings", Text = "Load", Callback = function()
    local ok = Config.load()
    Library:Notify({ Title = ok and "Settings loaded" or "Nothing saved yet", Icon = "download", Tone = ok and "ok" or "warn" })
  end })
  data:AddButton({ Label = "Unload", Desc = "Removes the window and every connection.", Text = "Unload", Style = "danger", Callback = function() Library:Unload() end })
  return tab
end

-- ============================================================================ entry points
function Library:Notify(opts)
  if not Window.built then return end
  return Window.toast(type(opts) == "table" and normalize("toast", opts) or { title = tostring(opts) })
end
-- Library:SetTheme({ Scheme = "dark" | "midnight" | "light", Accent = Color3, Glass = 0..100, Radius = 40..140 })
function Library:SetTheme(opts)
  opts = opts or {}
  if opts.Scheme then Config.set("app.scheme", opts.Scheme, true) end
  if opts.Accent then Config.set("app.accent", opts.Accent, true) end
  if opts.Glass then Config.set("app.glass", opts.Glass, true) end
  if opts.Radius then Config.set("app.radius", opts.Radius, true) end
end
function Library:SetBlur(on) Config.set("app.blur", on == true) end
function Library:SetFont(id) Config.set("app.font", id) end
function Library:SetScale(percent) Config.set("app.scale", percent) end
function Library:GetFlag(id) return Config.get(id) end
function Library:SetFlag(id, value) Config.set(id, value) end
function Library:SaveConfig(name) return Config.save(name) end
function Library:LoadConfig(name) return Config.load(name) end

--[[ Library:CreateWindow({
       Name = "ARBIX", Sub = "hub",          -- the wordmark in the sidebar (Sub is the italic accent word)
       Key = Enum.KeyCode.V,                  -- menu key
       AssetRoot = "BasedHub",                -- optional: the hub's fonts / icons / textures / sounds folder
       Accent = Color3, Scheme = "dark", Glass = 60, Scale = 100, Blur = false,
       ConfigFolder = "BasedUI", StartTab = "combat", Show = true }) ]]
function Library:CreateWindow(opts)
  opts = opts or {}
  if Window.built then return setmetatable({}, WinObj) end
  if opts.AssetRoot then Assets.init(opts.AssetRoot) end
  if opts.ConfigFolder then Config.folder = opts.ConfigFolder end
  if opts.Name or opts.Sub then Window.brand = { text = opts.Name or "ARBIX", sub = opts.Sub or "" } end
  local key = opts.Key
  if typeof(key) == "EnumItem" then key = key.Name end
  if key then Config.set("app.key.menu", key, true) end
  if opts.Scale then Config.set("app.scale", opts.Scale, true) end
  definePrefs()
  if opts.Scheme then Config.set("app.scheme", opts.Scheme, true) end
  if opts.Accent then Config.set("app.accent", opts.Accent, true) end
  if opts.Glass then Config.set("app.glass", opts.Glass, true) end
  if opts.Blur ~= nil then Config.set("app.blur", opts.Blur == true, true) end
  Window.startPage = opts.StartTab
  applyPrefs()
  Window.build()

  -- the menu key, and Ctrl+K for search
  B.connect(UIS.InputBegan, function(input)
    if Config.capturing then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if UIS:GetFocusedTextBox() then return end
    if input.KeyCode.Name == Config.get("app.key.menu") then
      Window.toggle()
    elseif input.KeyCode == Enum.KeyCode.K and (UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl)) and Window.open then
      Window.palette()
    end
  end, "window.keys")

  local win = setmetatable({}, WinObj)
  if opts.Show then task.defer(function() if Library.alive then Window.show(true) end end) end
  return win
end

return Library
