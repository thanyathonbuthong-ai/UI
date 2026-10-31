-- ============================================================================
--  NovalineUI.lua  —  standalone UI library extracted from BasedHub (Novaline look)
--  Usage:  local Novaline = loadstring(game:HttpGet("..."))()
--          local Window = Novaline:CreateWindow({ Title = "My Hub", ... })
--          local Tab = Window:Tab("Combat")
--          Tab:Toggle({ Label = "Enabled", Default = true, Callback = function(v) end })
-- ============================================================================
--  Extracted sections (in dependency order, each is a `do ... end` block sharing `B`):
--    00 kernel · 01 motion · 02 theme · 03 assets · 04 ui · 05 config
--    06 controls · 07 window · 51 keys · 52 unnamed (second look) · 53 novoline (target)
--  Stripped: all Da Hood cheat modules, ESP/aimbot, film/loader, music player,
--    registry, HUD island, board, picker, void/self/sky/world sections.
-- ============================================================================
local B = (type(getgenv) == "function" and getgenv().NovalineUI_B) or {}
if not B._init then
  B._init = true

-- ---- stub block: symbols from stripped sections, referenced by kept UI code ----
--  These keep the UI visually identical while non-UI features degrade to no-ops.
B.MANIFEST     = B.MANIFEST or { files = {}, icons = { map = {} } }  -- asset manifest fallback (03_assets handles nil too)
B.Music        = nil   -- music player stripped; all call sites guarded with `B.Music and`
B.Lyrics       = nil
B.Registry     = nil   -- guarded with `B.Registry and`
B.Hud          = nil   -- guarded
B.Island       = nil   -- guarded; lyric row in island falls back
B.Card         = B.Card or { mode = "full", view = "cover", WIDE = Vector2.new(420, 260), wordColor = function(c) return c end, viewWide = function() end }
B.universalPages = nil -- guarded with `and` in 90_boot
B.pages        = B.pages or {}
B.FILM, B.BOARD, B.REEL, B.FILMS, B.SHIPPED, B.PC_HELPER = nil, nil, nil, nil, nil, nil
-- more stripped modules: all call sites guarded with `B.X and` / `if B.X then`
B.Loader, B.Picker, B.Prefs, B.Server = nil, nil, nil, nil
-- library flag: when false (default) boot builds everything but does not auto-show the window
B._autoOpen = B._autoOpen == true
-- -------------------------------------------------------------------------------

do -- 00_kernel.lua
-- ============================================================================
--  00 kernel   services, ownership, signals, error boundaries, files, helpers
-- ============================================================================
local genv = (type(getgenv) == "function" and getgenv()) or _G
B.genv = genv

-- A second execution replaces the first: the old hub unloads itself completely.
if type(genv.BASED) == "table" and type(genv.BASED.unload) == "function" then
  pcall(genv.BASED.unload, true)
end
genv.BASED = B
B.alive = true
B.bootClock = os.clock()

local cloneref = type(cloneref) == "function" and cloneref or function(x) return x end
B.cloneref = cloneref
B.S = setmetatable({}, { __index = function(t, name)
  local ok, service = pcall(game.GetService, game, name)
  if not ok or not service then error("BASED: no service " .. tostring(name), 2) end
  service = cloneref(service)
  rawset(t, name, service)
  return service
end })
local S = B.S
B.LP = S.Players.LocalPlayer

-- ---------------------------------------------------------------- signals
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
    if link.live then B.try("signal", link.fn, ...) end
  end
end
B.Signal = Signal

-- ---------------------------------------------------------------- faults
-- Everything user-facing runs inside B.try: a failing feature logs here and the
-- rest of the hub keeps running. Settings > About shows this list.
B.faults = {}
B.onFault = Signal.new()
local lastFault = {}
function B.fault(scope, err)
  scope = tostring(scope)
  -- something failing every frame must not flood the log: one entry a second per scope
  local now = os.clock()
  local previous = lastFault[scope]
  if previous and now - previous.at < 1 then previous.entry.repeats = (previous.entry.repeats or 0) + 1; return end
  local entry = { scope = scope, message = tostring(err), at = now - B.bootClock }
  lastFault[scope] = { at = now, entry = entry }
  local faults = B.faults
  faults[#faults + 1] = entry
  if #faults > 60 then table.remove(faults, 1) end
  warn("[BASED] " .. entry.scope .. ": " .. entry.message)
  if B.onFault and #B.onFault.list > 0 then
    for _, link in ipairs(table.clone(B.onFault.list)) do pcall(link.fn, entry) end
  end
end
local function trace(e) return tostring(e) .. "\n" .. debug.traceback("", 2) end
function B.try(scope, fn, ...)
  local result = table.pack(xpcall(fn, trace, ...))
  if not result[1] then B.fault(scope, result[2]); return nil end
  return table.unpack(result, 2, result.n)
end
function B.safe(scope, fn)
  return function(...) return B.try(scope, fn, ...) end
end
-- Potassium: calling into game modules drops the thread's Plugin capability and
-- every gethui instance then throws. Callbacks the game invokes call this first.
function B.identity()
  if type(setthreadidentity) == "function" then pcall(setthreadidentity, 8) end
end

-- ---------------------------------------------------------------- ownership
local owned = {}
function B.own(thing)
  owned[#owned + 1] = thing
  return thing
end
-- What every hooked function costs, by name, while measuring (B.measure): nil the rest of the time,
-- and then a hook costs one look at it. Read with B.measure(seconds) -> lines, worst first.
B.prof = nil
local function charge(scope, seconds)
  local prof = B.prof
  if not prof then return end
  local entry = prof[scope]
  if not entry then entry = { 0, 0, 0 }; prof[scope] = entry end
  entry[1] += seconds
  entry[2] += 1
  if seconds > entry[3] then entry[3] = seconds end
end
B.charge = charge
function B.connect(signal, fn, scope)
  scope = scope or "event"
  local safe = B.safe(scope, fn)
  return B.own(signal:Connect(function(...)
    if not B.prof then return safe(...) end
    local started = os.clock()
    safe(...)
    charge(scope, os.clock() - started)
  end))
end
function B.measure(seconds)
  B.prof = {}
  local frames, started = 0, os.clock()
  local counter = S.RunService.Heartbeat:Connect(function() frames += 1 end)
  task.wait(seconds or 5)
  counter:Disconnect()
  local prof, span = B.prof, os.clock() - started
  B.prof = nil
  local rows = {}
  for scope, entry in pairs(prof) do rows[#rows + 1] = { scope, entry[1], entry[2], entry[3] } end
  table.sort(rows, function(a, b) return a[2] > b[2] end)
  local out = { string.format("%d frames in %.1f s (%.0f fps)", frames, span, frames / math.max(span, 1e-3)) }
  for _, row in ipairs(rows) do
    out[#out + 1] = string.format("%-28s %6.3f ms/frame  %6d calls  worst %.2f ms", row[1], row[2] * 1000 / math.max(frames, 1), row[3], row[4] * 1000)
  end
  return out
end
B.onUnload = Signal.new()
function B.unload()
  if not B.alive then return end
  B.alive = false
  pcall(function() B.onUnload:fire() end)
  for index = #owned, 1, -1 do
    local thing = owned[index]
    pcall(function()
      local kind = typeof(thing)
      if kind == "RBXScriptConnection" then thing:Disconnect()
      elseif kind == "Instance" then thing:Destroy()
      elseif kind == "function" then thing()
      elseif kind == "table" and type(thing.destroy) == "function" then thing:destroy() end
    end)
  end
  table.clear(owned)
  if genv.BASED == B then genv.BASED = nil end
end

-- ---------------------------------------------------------------- files
local fs = { root = "BasedHub" }
fs.ok = type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
  and type(makefolder) == "function" and type(isfolder) == "function"
function fs.path(relative) return fs.root .. "/" .. relative end
function fs.exists(path)
  if not fs.ok then return false end
  local ok, present = pcall(isfile, path)
  return ok and present == true
end
function fs.isdir(path)
  if not fs.ok then return false end
  local ok, present = pcall(isfolder, path)
  return ok and present == true
end
function fs.mkdir(path)
  if not fs.ok then return false end
  local built = ""
  for part in string.gmatch(path, "[^/\\]+") do
    built = built == "" and part or (built .. "/" .. part)
    if not fs.isdir(built) then pcall(makefolder, built) end
  end
  return fs.isdir(path)
end
function fs.read(path)
  if not fs.exists(path) then return nil end
  local ok, data = pcall(readfile, path)
  return ok and data or nil
end
function fs.write(path, data)
  if not fs.ok then return false end
  local folder = string.match(path, "^(.*)[/\\][^/\\]+$")
  if folder and not fs.isdir(folder) then fs.mkdir(folder) end
  local ok = pcall(writefile, path, data)
  return ok
end
function fs.remove(path)
  if type(delfile) ~= "function" or not fs.exists(path) then return false end
  return (pcall(delfile, path))
end
function fs.list(path)
  if type(listfiles) ~= "function" or not fs.isdir(path) then return {} end
  local ok, files = pcall(listfiles, path)
  if not ok or type(files) ~= "table" then return {} end
  local out = {}
  for _, file in ipairs(files) do out[#out + 1] = (string.gsub(tostring(file), "\\", "/")) end
  table.sort(out)
  return out
end
function fs.readJson(path)
  local data = fs.read(path)
  if not data or data == "" then return nil end
  local ok, value = pcall(S.HttpService.JSONDecode, S.HttpService, data)
  return ok and value or nil
end
function fs.writeJson(path, value)
  local ok, data = pcall(S.HttpService.JSONEncode, S.HttpService, value)
  return ok and fs.write(path, data) or false
end
B.fs = fs

-- ---------------------------------------------------------------- helpers
local util = {}
function util.clamp01(x) return x < 0 and 0 or (x > 1 and 1 or x) end
function util.lerp(a, b, t) return a + (b - a) * t end
function util.map(x, a, b, c, d, clamp)
  local t = (x - a) / (b - a)
  if clamp then t = util.clamp01(t) end
  return c + (d - c) * t
end
function util.round(x, step)
  step = step or 1
  return math.floor(x / step + 0.5) * step
end
function util.hex(text)
  text = string.gsub(text, "#", "")
  return Color3.fromRGB(tonumber(string.sub(text, 1, 2), 16), tonumber(string.sub(text, 3, 4), 16), tonumber(string.sub(text, 5, 6), 16))
end
function util.toHex(color)
  return string.format("%02X%02X%02X", math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
end
function util.luma(color) return 0.2126 * color.R + 0.7152 * color.G + 0.0722 * color.B end
function util.mix(a, b, t) return a:Lerp(b, t) end
function util.format(value, decimals)
  if decimals and decimals > 0 then return string.format("%." .. decimals .. "f", value) end
  return tostring(math.floor(value + 0.5))
end
function util.comma(n)
  local text = tostring(math.floor(n))
  local out = string.reverse((string.gsub(string.reverse(text), "(%d%d%d)", "%1,")))
  return (string.gsub(out, "^,", ""))
end
function util.copy(value)
  if type(value) ~= "table" then return value end
  local out = {}
  for k, v in pairs(value) do out[k] = util.copy(v) end
  return out
end
function util.keys(t)
  local out = {}
  for k in pairs(t) do out[#out + 1] = k end
  return out
end
-- Cheap fuzzy score for the command palette: every query character must appear
-- in order; contiguous runs and word starts score higher. nil = no match.
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
function util.debounce(seconds, fn)
  local token = 0
  return function(...)
    token += 1
    local mine = token
    local args = table.pack(...)
    task.delay(seconds, function()
      if mine == token and B.alive then B.try("debounce", fn, table.unpack(args, 1, args.n)) end
    end)
  end
end
-- A ray from one point to another, however far apart. Measured on the client: one ray finds
-- nothing more than 15,000 studs away however long it is asked to be, and says so with nil, not
-- an error. So a long one is cast in lengths the engine can see along. nil means the way is
-- clear (or, past `lengths` of them, further than it is worth looking).
local RAY_REACH = 14000
function util.ray(from, to, params, lengths)
  local offset = to - from
  local distance = offset.Magnitude
  if distance <= RAY_REACH then return workspace:Raycast(from, offset, params) end
  local unit = offset / distance
  local at = 0
  for _ = 1, lengths or 8 do
    local reach = math.min(RAY_REACH, distance - at)
    local hit = workspace:Raycast(from + unit * at, unit * reach, params)
    if hit then return hit end
    at += reach
    if at >= distance - 0.01 then break end
  end
  return nil
end
util.RAY_REACH = RAY_REACH
-- a distance for a label: whole studs with a comma, then thousands, then millions
function util.studs(distance)
  if distance >= 99.95e6 then return string.format("%.0fM", distance / 1e6) end
  if distance >= 999500 then return string.format("%.1fM", distance / 1e6) end
  if distance >= 99950 then return string.format("%.0fk", distance / 1000) end
  if distance >= 9995 then return string.format("%.1fk", distance / 1000) end
  return util.comma(distance + 0.5)
end
function util.randomName()
  local chars = {}
  for i = 1, 12 do chars[i] = string.char(math.random(97, 122)) end
  return table.concat(chars)
end
B.util = util

-- ---------------------------------------------------------------- environment
function B.camera() return workspace.CurrentCamera end
function B.viewport()
  local camera = workspace.CurrentCamera
  return camera and camera.ViewportSize or Vector2.new(1920, 1080)
end
function B.character(player)
  player = player or B.LP
  return player and player.Character
end
function B.humanoid(player)
  local character = B.character(player)
  return character and character:FindFirstChildOfClass("Humanoid")
end
function B.root(player)
  local character = B.character(player)
  if not character then return nil end
  return character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
end
function B.clipboard(text)
  local set = (type(setclipboard) == "function" and setclipboard) or (type(toclipboard) == "function" and toclipboard)
  if not set then return false end
  return (pcall(set, tostring(text)))
end
B.executor = "Unknown"
pcall(function()
  if type(identifyexecutor) == "function" then B.executor = tostring((identifyexecutor())) end
end)
B.touch = false
pcall(function() B.touch = S.UserInputService.TouchEnabled and not S.UserInputService.MouseEnabled end)

-- The GUI parent: the executor's hidden container when it has one.
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
  if not host and B.LP then host = B.LP:FindFirstChildOfClass("PlayerGui") or B.LP:WaitForChild("PlayerGui", 5) end
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
end

do -- 01_motion.lua
-- ============================================================================
--  01 motion   one render loop: analytic springs, timelines, jobs
--
--  Springs are described the way SwiftUI does it: a duration (how long the move
--  feels) and a bounce (0 = critically damped, 0.3 = lively). They are solved in
--  closed form, so a 20 fps hitch and a 240 fps frame land on the same curve and
--  nothing ever explodes. A spring at rest is removed from the loop: an idle hub
--  costs one empty table scan per frame.
-- ============================================================================
local S, util = B.S, B.util
local Motion = { speed = 1, reduced = false, frame = 0, dt = 1 / 60, smoothDt = 1 / 60, now = os.clock() }
B.Motion = Motion

Motion.presets = {
  quick  = { 0.16, 0 },     -- hover tints, tiny state changes
  snappy = { 0.24, 0.10 },  -- presses, toggles
  smooth = { 0.34, 0 },     -- panels, pages
  gentle = { 0.52, 0 },     -- large surfaces
  bouncy = { 0.40, 0.24 },  -- things that should feel alive
  liquid = { 0.46, 0.30 },  -- the trailing edge of a moving pill
  lazy   = { 0.90, 0 },     -- ambient drift
}

local awake = {}       -- springs that are moving
local stepping = {}    -- the ones being stepped this frame, in a list of their own (see the loop)
local jobs = {}        -- per-frame callbacks
local tweens = {}      -- fixed-duration timelines

-- ---------------------------------------------------------------- springs
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
function Spring:impulse(index, velocity)
  self.v[index] += velocity
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

-- ---------------------------------------------------------------- properties
local PX, UNIT = 0.08, 0.0008
local packers = {
  number = { 1, function(value) return { value } end, function(x) return x[1] end, UNIT },
  UDim2 = { 4, function(value) return { value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset } end,
    function(x) return UDim2.new(x[1], x[2], x[3], x[4]) end, { UNIT, PX, UNIT, PX } },
  UDim = { 2, function(value) return { value.Scale, value.Offset } end, function(x) return UDim.new(x[1], x[2]) end, { UNIT, PX } },
  Vector2 = { 2, function(value) return { value.X, value.Y } end, function(x) return Vector2.new(x[1], x[2]) end, UNIT },
  Vector3 = { 3, function(value) return { value.X, value.Y, value.Z } end, function(x) return Vector3.new(x[1], x[2], x[3]) end, UNIT },
  Color3 = { 3, function(value) return { value.R, value.G, value.B } end,
    function(x) return Color3.new(util.clamp01(x[1]), util.clamp01(x[2]), util.clamp01(x[3])) end, 0.002 },
}
-- Properties that must stay inside 0..1: a bouncy spring overshoots, the engine rejects it.
local unitProps = { BackgroundTransparency = true, TextTransparency = true, ImageTransparency = true, Transparency = true,
  GroupTransparency = true, TextStrokeTransparency = true, ScrollBarImageTransparency = true, FillTransparency = true,
  OutlineTransparency = true }

local bound = setmetatable({}, { __mode = "k" })
-- Spring `instance[property]` toward `target`. The spring is kept per
-- (instance, property) and re-aimed in flight, so interrupted motion never jumps.
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
function Motion.kick(instance, property, index, velocity)
  local map = bound[instance]
  local spring = map and map[property]
  if spring then spring:impulse(index or 1, velocity) end
end
function Motion.target(instance, property)
  local map = bound[instance]
  local spring = map and map[property]
  if not spring then return instance[property] end
  local packer = packers[typeof(instance[property])]
  return packer and packer[3](spring.g) or instance[property]
end

-- ---------------------------------------------------------------- easing + timelines
local ease = {}
function ease.linear(t) return t end
function ease.outCubic(t) return 1 - (1 - t) ^ 3 end
function ease.inCubic(t) return t * t * t end
function ease.inOutCubic(t) return t < 0.5 and 4 * t * t * t or 1 - (-2 * t + 2) ^ 3 / 2 end
function ease.outQuint(t) return 1 - (1 - t) ^ 5 end
function ease.inOutQuint(t) return t < 0.5 and 16 * t ^ 5 or 1 - (-2 * t + 2) ^ 5 / 2 end
function ease.outExpo(t) return t >= 1 and 1 or 1 - 2 ^ (-10 * t) end
function ease.inExpo(t) return t <= 0 and 0 or 2 ^ (10 * t - 10) end
function ease.outBack(t) local c = 1.70158; return 1 + (c + 1) * (t - 1) ^ 3 + c * (t - 1) ^ 2 end
function ease.outSine(t) return math.sin(t * math.pi / 2) end
Motion.ease = ease
-- progress of `t` through the window [from, from + length], eased and clamped
function Motion.window(t, from, length, curve)
  local p = util.clamp01((t - from) / length)
  return curve and curve(p) or p
end

function Motion.tween(duration, curve, step, done)
  local tween = { t = 0, duration = math.max(duration / Motion.speed, 0.001), curve = curve or ease.outCubic, step = step, done = done }
  if Motion.reduced then tween.duration *= 0.5 end
  tweens[#tweens + 1] = tween
  function tween.cancel() tween.dead = true end
  step(tween.curve(0))
  return tween
end

-- ---------------------------------------------------------------- jobs
-- fn(elapsed) every frame, or at `hz` with the time since it last ran.
function Motion.every(fn, hz, scope)
  local job = { fn = fn, interval = hz and 1 / hz or 0, acc = 0, scope = scope or "job" }
  jobs[#jobs + 1] = job
  function job.cancel() job.dead = true end
  return job
end
function Motion.after(seconds, fn, scope)
  local job
  local left = seconds
  job = Motion.every(function(dt)
    left -= dt
    if left <= 0 then job.dead = true; fn() end
  end, nil, scope or "after")
  return job
end

-- ---------------------------------------------------------------- the loop
Motion.stats = { springs = 0, jobs = 0, ms = 0 }
local function frame(dt)
  if not B.alive then return end
  local started = os.clock()
  dt = math.min(dt, 0.1)
  Motion.frame += 1
  Motion.dt = dt
  Motion.smoothDt += (dt - Motion.smoothDt) * 0.08
  Motion.now = started

  -- A spring's step runs code that may start other springs, and a table cannot be given new keys
  -- while it is being walked ("invalid key to 'next'", one frame in thousands): so this frame's
  -- springs are listed first. One started during the frame is stepped from the next; one put to
  -- rest by another before its turn is left alone.
  local measuring = B.prof ~= nil
  local springCount = 0
  for spring in pairs(awake) do
    springCount += 1
    stepping[springCount] = spring
  end
  for index = 1, springCount do
    local spring = stepping[index]
    stepping[index] = nil
    if awake[spring] then
      local ok, err = pcall(stepSpring, spring, dt)
      if not ok then awake[spring] = nil; B.fault("spring", err) end
    end
  end

  local mark = measuring and os.clock()
  if measuring then B.charge("motion.springs", mark - started) end
  local count = #tweens
  if count > 0 then
    for index = count, 1, -1 do
      local tween = tweens[index]
      if tween.dead then
        table.remove(tweens, index)
      else
        tween.t += dt
        local p = util.clamp01(tween.t / tween.duration)
        local ok, err = pcall(tween.step, tween.curve(p))
        if not ok then tween.dead = true; B.fault("tween", err) end
        if p >= 1 and not tween.dead then
          tween.dead = true
          table.remove(tweens, index)
          if tween.done then B.try("tween.done", tween.done) end
        end
      end
    end
  end

  if measuring then B.charge("motion.tweens", os.clock() - mark) end
  count = #jobs
  if count > 0 then
    for index = 1, count do
      local job = jobs[index]
      if job and not job.dead then
        local elapsed = dt
        local run = true
        if job.interval > 0 then
          job.acc += dt
          if job.acc < job.interval then run = false else elapsed = math.min(job.acc, 0.5); job.acc = 0 end
        end
        if run then
          local before = measuring and os.clock()
          local ok, err = pcall(job.fn, elapsed)
          if not ok then job.dead = true; B.fault(job.scope, err) end
          if measuring then B.charge("job." .. job.scope, os.clock() - before) end
        end
      end
    end
    for index = #jobs, 1, -1 do
      if jobs[index].dead then table.remove(jobs, index) end
    end
  end
  local stats = Motion.stats
  stats.springs, stats.jobs, stats.ms = springCount, #jobs, (os.clock() - started) * 1000
end
B.own(S.RunService.RenderStepped:Connect(frame))
Motion._frame = frame
end

do -- 02_theme.lua
-- ============================================================================
--  02 theme    tokens, live bindings
--
--  Surfaces are not solid colours: every fill is the scheme's ink at a low alpha
--  laid over glass, so one set of numbers works on a dark, a black and a light
--  scheme. B.T holds the resolved values; Theme.bind keeps an instance property
--  in step with a token, so accent, scheme and the glass slider all change the
--  whole hub live without rebuilding anything.
-- ============================================================================
local util = B.util
local hex = util.hex
local Theme = { changed = B.Signal.new() }
B.Theme = Theme
local T = {}
B.T = T

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

-- type ramp: font key (resolved in B.F by 03 assets) and size in design px
Theme.type = {
  display = { "serifItalic", 34 },
  title = { "serif", 25 },
  heading = { "text600", 15 },
  label = { "text500", 14 },
  body = { "text400", 13 },
  caption = { "text400", 12 },
  eyebrow = { "wideBold", 10 },
  mono = { "mono400", 12 },
  monoBold = { "mono500", 12 },
  button = { "text600", 13 },
  brand = { "wideBlack", 18 },
}

local function resolve()
  local state = Theme.state
  local scheme = Theme.schemes[state.scheme] or Theme.schemes.dark
  local glass = util.clamp01(state.glass)
  T.dark = scheme.dark
  T.base, T.ink, T.sub, T.faint = scheme.base, scheme.ink, scheme.sub, scheme.faint
  -- the iOS 27 control: clear glass at 0, tinted glass at 1. Without real blur
  -- behind it a clear panel is unreadable, so the range tightens.
  local alpha = state.blur and util.lerp(0.5, 0.94, glass) or util.lerp(0.84, 0.975, glass)
  T.baseA = 1 - alpha
  T.panelA = 1 - util.lerp(0.34, 0.62, glass)       -- inner panels: sidebar, popovers
  T.fill1A, T.fill2A, T.fill3A = 1 - scheme.fill[1], 1 - scheme.fill[2], 1 - scheme.fill[3]
  T.strokeA, T.stroke2A = 1 - scheme.stroke[1], 1 - scheme.stroke[2]
  T.shadowA = scheme.shadow
  T.accent = state.accent
  T.accentInk = util.luma(state.accent) > 0.62 and hex("101014") or hex("FFFFFF")
  T.accentSoftA = 0.84
  T.accentDim = state.accent:Lerp(scheme.base, 0.55)
  T.ok, T.warn, T.bad = hex("52D6A0"), hex("F4B45F"), hex("FF6577")
  T.white, T.black = Color3.new(1, 1, 1), Color3.new(0, 0, 0)
  T.rim = scheme.dark and Color3.new(1, 1, 1) or Color3.new(1, 1, 1)
  T.rimA = scheme.dark and 0.5 or 0.1
  T.popover = scheme.base:Lerp(scheme.ink, scheme.dark and 0.07 or 0.0)
  local r = state.radius
  T.rWindow, T.rPanel, T.rCard, T.rControl, T.rSmall = math.floor(26 * r), math.floor(19 * r), math.floor(16 * r), math.floor(11 * r), math.floor(7 * r)
end
resolve()

-- Strong references on purpose. A weak-keyed table of Instances loses entries whenever Lua holds
-- no other reference to that instance's wrapper, even though the instance is alive in the game:
-- measured as labels that kept their dark-scheme colour after switching to the light scheme.
-- Destroyed instances are swept out instead (their Parent is nil for good).
local bindings = {}
local boundAt = {}
-- Keep instance[property] equal to token `key` (optionally through `map`).
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
-- forget instances that were destroyed (not ones still being assembled)
function Theme.sweep()
  local now = os.clock()
  for instance in pairs(bindings) do
    if instance.Parent == nil and now - boundAt[instance] > 5 then
      bindings[instance], boundAt[instance] = nil, nil
    end
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
B.Motion.every(Theme.sweep, 1 / 20, "theme.sweep")
function Theme.set(changes)
  local state = Theme.state
  for key, value in pairs(changes) do state[key] = value end
  Theme.apply()
end
function Theme.corner(key) return UDim.new(0, T[key] or 10) end
end

do -- 03_assets.lua
-- ============================================================================
--  03 assets   files on disk -> content ids, fonts, icons, sounds
--
--  Measured on Potassium (2026-10-06): getcustomasset costs 3-5 ms per call on
--  the main thread whatever the file size, the files it copies stay in the
--  client's content folder between sessions, and the id is always
--  <prefix>/<basename>. So a file is registered ONCE, ever; after that its id is
--  built by hand for free. A sentinel is checked at boot because a client update
--  can empty that folder.
-- ============================================================================
local S, fs, util = B.S, B.fs, B.util
local Assets = { ready = false, lite = false, calls = 0 }
B.Assets = Assets
local manifest = B.MANIFEST or { files = {}, icons = { map = {} } }
Assets.manifest = manifest

local canRegister = type(getcustomasset) == "function" and fs.ok
local REGISTRY = fs.path("cache/registry.json")
local registry = { files = {}, seq = {} }
local ids = {}            -- relative path -> content id, or false when unavailable
local seqIds = {}         -- sequence prefix -> { [index] = id }
local seqKnown = {}       -- sequence prefix -> { [index] = true } registered in an earlier session
local dirty = false

local function basename(path) return string.match(path, "[^/\\]+$") or path end
local function prefixOf(id) return string.match(id, "^(rbxasset://[^/]+/)") end

local saveSoon = util.debounce(1.5, function()
  if not dirty then return end
  dirty = false
  local seq = {}
  for key, known in pairs(seqKnown) do
    -- compress the registered indices into [from, to] runs
    local runs, from, last = {}, nil, nil
    local indices = util.keys(known)
    table.sort(indices)
    for _, index in ipairs(indices) do
      if from and index == last + 1 then last = index
      else
        if from then runs[#runs + 1] = { from, last } end
        from, last = index, index
      end
    end
    if from then runs[#runs + 1] = { from, last } end
    seq[key] = runs
  end
  fs.writeJson(REGISTRY, { prefix = registry.prefix, sentinel = registry.sentinel, files = registry.files, seq = seq })
end)
local function touch() dirty = true; saveSoon() end

local function register(path)
  Assets.calls += 1
  local ok, id = pcall(getcustomasset, path)
  if not ok or type(id) ~= "string" or id == "" then return nil end
  local prefix = prefixOf(id)
  if prefix and registry.prefix ~= prefix then
    -- a different content folder: nothing registered before is reachable
    registry.prefix = prefix
    registry.files = {}
    table.clear(seqKnown)
  end
  return id
end

-- Content id for a file under BasedHub/, or nil when it is not installed.
function Assets.id(relative)
  local cached = ids[relative]
  if cached ~= nil then return cached or nil end
  if not canRegister then ids[relative] = false; return nil end
  local name = basename(relative)
  local stamp = manifest.files[relative] or "x"
  local id
  if registry.prefix and registry.files[name] == stamp then
    id = registry.prefix .. name
  else
    id = register(fs.path(relative))
    if id then
      registry.files[name] = stamp
      -- the sentinel must be something PreloadAsync can load and report on: an image
      if string.match(name, "%.png$") or string.match(name, "%.jpg$") then registry.sentinel = name end
      touch()
    end
  end
  ids[relative] = id or false
  return id
end

-- Content id for frame `index` of a numbered sequence ("film/hd/bhf1_h_", 4 digits).
function Assets.frame(pathPrefix, index, digits, extension)
  local cache = seqIds[pathPrefix]
  if not cache then cache = {}; seqIds[pathPrefix] = cache end
  local id = cache[index]
  if id ~= nil then return id or nil end
  if not canRegister then return nil end
  local file = pathPrefix .. string.format("%0" .. (digits or 4) .. "d", index) .. (extension or ".jpg")
  local known = seqKnown[pathPrefix]
  if known and known[index] and registry.prefix then
    id = registry.prefix .. basename(file)
  else
    id = register(fs.path(file))
    if id then
      if not known then known = {}; seqKnown[pathPrefix] = known end
      known[index] = true
      touch()
    end
  end
  cache[index] = id or false
  return id
end
-- true when frame `index` can be had without a getcustomasset call
function Assets.frameIsFree(pathPrefix, index)
  local cache = seqIds[pathPrefix]
  if cache and cache[index] then return true end
  local known = seqKnown[pathPrefix]
  return known ~= nil and known[index] == true and registry.prefix ~= nil
end

function Assets.has(relative) return fs.exists(fs.path(relative)) end

-- ---------------------------------------------------------------- fonts
local FONT_FILES = {
  text400 = { "Inter", "fonts/Inter-Regular.ttf", 400 }, text500 = { "Inter", "fonts/Inter-Medium.ttf", 500 },
  text600 = { "Inter", "fonts/Inter-SemiBold.ttf", 600 }, text700 = { "Inter", "fonts/Inter-Bold.ttf", 700 },
  mono400 = { "GeistMono", "fonts/GeistMono-Regular.ttf", 400 }, mono500 = { "GeistMono", "fonts/GeistMono-Medium.ttf", 500 },
  serif = { "InstrumentSerif", "fonts/InstrumentSerif-Regular.ttf", 400 },
  serifItalic = { "InstrumentSerifItalic", "fonts/InstrumentSerif-Italic.ttf", 400 },
  wideBold = { "ArchivoExpanded", "fonts/Archivo-ExpandedBold.ttf", 700 },
  wideBlack = { "ArchivoExpanded", "fonts/Archivo-ExpandedBlack.ttf", 900 },
  -- the Unnamed menu's: Monocraft (the Minecraft letters), and the two Proggy pixel fonts
  craft = { "Monocraft", "fonts/Monocraft.ttf", 400 },
  proggy = { "ProggyClean", "fonts/ProggyClean.ttf", 400 },
  proggyTiny = { "ProggyTiny", "fonts/ProggyTiny.ttf", 400 },
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
  -- (without the files, the closest Roblox has: its own pixel font, and Arial)
  craft = function() return Font.fromEnum(Enum.Font.Arcade) end,
  proggy = function() return Font.fromEnum(Enum.Font.Code) end,
  proggyTiny = function() return Font.fromEnum(Enum.Font.Code) end,
}
B.F = {}

local function loadFonts()
  -- one family file per family, listing each face's registered .ttf
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
    if ok then
      local path = fs.path(relative)
      local changed = fs.read(path) ~= json
      if changed then fs.write(path, json) end
      -- the stamp is the json itself: a new prefix or face list re-registers the family file
      manifest.files[relative] = tostring(#json) .. ":" .. tostring(registry.prefix)
      if changed then ids[relative] = nil; registry.files[basename(relative)] = nil end
      local id = Assets.id(relative)
      if id then
        for key, weight in pairs(family.keys) do
          local okFont, font = pcall(Font.new, id, Enum.FontWeight[WEIGHTS[weight] or "Regular"], Enum.FontStyle.Normal)
          if okFont then B.F[key] = font end
        end
      end
    end
  end
  local missing = 0
  for key, make in pairs(FALLBACK) do
    if not B.F[key] then B.F[key] = make(); missing += 1 end
  end
  return missing
end

-- ---------------------------------------------------------------- icons, images, sounds
-- Icons live in one atlas (a single registration): returns image, offset, size.
function Assets.icon(name)
  local atlas = manifest.icons
  local index = atlas and atlas.map and atlas.map[name]
  if not index then return nil end
  local id = Assets.id(atlas.image)
  if not id then return nil end
  local cell = atlas.cell
  return id, Vector2.new((index % atlas.cols) * cell, math.floor(index / atlas.cols) * cell), Vector2.new(cell, cell)
end
-- Images are deployed under a content-hashed file name (a changed picture gets a
-- new id, so a cached texture can never be stale); manifest.img maps name -> file.
function Assets.image(name)
  local file = manifest.img and manifest.img[name]
  return file and Assets.id(file) or nil
end
function Assets.sound(name)
  local file = manifest.sfx and manifest.sfx[name]
  return file and Assets.id(file) or nil
end
-- ---------------------------------------------------------------- text-glyph icons
-- The icon atlas is stubbed (no disk assets), so every icon name maps to a visible
-- Unicode glyph rendered as a TextLabel. Unmapped names fall back to first letter
-- uppercase — never nil/blank. Literal UTF-8 (not \u escapes) for Lua 5.1 parseability.
local GLYPHS = {
  ["settings"] = "⚙", ["eye"] = "👁", ["eye-off"] = "🚫", ["x"] = "✕",
  ["plus"] = "+", ["minus"] = "−", ["check"] = "✓", ["chevron-down"] = "⌄",
  ["search"] = "🔍", ["clock"] = "🕐", ["music"] = "🎵", ["sword"] = "⚔",
  ["zap"] = "⚡", ["shield"] = "🛡", ["power"] = "⏻", ["house"] = "🏠",
  ["home"] = "🏠", ["gamepad"] = "🎮", ["crosshair"] = "◎", ["users"] = "👥",
  ["user"] = "👤", ["globe"] = "🌐", ["layout-grid"] = "▦", ["keyboard"] = "⌨",
  ["link"] = "🔗", ["rotate-ccw"] = "↺", ["sparkles"] = "✨", ["command"] = "⌘",
  ["hand"] = "✋", ["app-window"] = "🗔", ["play"] = "▶", ["pause"] = "⏸",
  ["skip-back"] = "⏮", ["skip-forward"] = "⏭", ["copy"] = "📋", ["server"] = "🖥",
  ["circle"] = "●", ["shuffle"] = "🔀", ["key"] = "🔑", ["menu"] = "☰",
  ["gear"] = "⚙", ["star"] = "★", ["heart"] = "♥", ["bell"] = "🔔",
  ["lock"] = "🔒", ["unlock"] = "🔓", ["trash"] = "🗑", ["edit"] = "✎",
  ["save"] = "💾", ["load"] = "📂", ["info"] = "ℹ", ["warn"] = "⚠",
  ["arrow-up"] = "↑", ["arrow-down"] = "↓", ["arrow-left"] = "←", ["arrow-right"] = "→",
  ["dot"] = "●", ["square"] = "■", ["triangle"] = "▲", ["diamond"] = "◆",
}
function Assets.glyphChar(name)
  local g = GLYPHS[name]
  if g then return g end
  local letter = string.sub(tostring(name or "?"), 1, 1)
  return string.upper(letter)
end

-- ---------------------------------------------------------------- boot
function Assets.preload(list, timeout)
  local done = false
  task.spawn(function()
    pcall(function() S.ContentProvider:PreloadAsync(list) end)
    done = true
  end)
  local waited = 0
  while not done and waited < (timeout or 3) do waited += task.wait() end
  return done
end

function Assets.init()
  if not canRegister then
    Assets.lite = true
  else
    local saved = fs.readJson(REGISTRY)
    if type(saved) == "table" and type(saved.prefix) == "string" and type(saved.files) == "table" and type(saved.sentinel) == "string" then
      -- is the content folder we registered into still there?
      local status
      local finished = false
      task.spawn(function()
        pcall(function()
          S.ContentProvider:PreloadAsync({ saved.prefix .. saved.sentinel }, function(_, result) status = result end)
        end)
        finished = true
      end)
      local waited = 0
      while not finished and waited < 2 do waited += task.wait() end
      if status == Enum.AssetFetchStatus.Success then
        registry.prefix, registry.files, registry.sentinel = saved.prefix, saved.files, saved.sentinel
        for key, runs in pairs(type(saved.seq) == "table" and saved.seq or {}) do
          local known = {}
          for _, run in ipairs(runs) do
            for index = run[1], run[2] do known[index] = true end
          end
          seqKnown[key] = known
        end
      end
    end
    Assets.lite = not (manifest.icons and manifest.icons.image and Assets.id(manifest.icons.image))
  end
  Assets.fontsMissing = loadFonts()
  -- the hub's own letters, kept: Settings > Font swaps B.F, and Inter is these again
  B.F0 = table.clone(B.F)
  Assets.ready = true
  return not Assets.lite
end
function Assets.registry() return registry end
end

do -- 04_ui.lua
-- ============================================================================
--  04 ui       instance factory, glass, text, icons, input, popovers, scroll
-- ============================================================================
local S, util, Motion, Theme, T, Assets = B.S, B.util, B.Motion, B.Theme, B.T, B.Assets
local UIS = S.UserInputService
local UI = { fx = { canvas = true, shadow = false, innerStroke = false }, sfxVolume = 0.5, sfxOn = true }
B.UI = UI

-- ---------------------------------------------------------------- capabilities
pcall(function()
  local probe = Instance.new("UIShadow")
  probe.BlurRadius = UDim.new(0, 4)
  probe:Destroy()
  UI.fx.shadow = true
end)
pcall(function()
  local probe = Instance.new("UIStroke")
  probe.BorderStrokePosition = Enum.BorderStrokePosition.Inner
  probe:Destroy()
  UI.fx.innerStroke = true
end)
pcall(function()
  -- a CanvasGroup is drawn at reduced resolution on the lowest quality levels: text goes soft
  local saved = UserSettings():GetService("UserGameSettings").SavedQualityLevel
  if saved ~= Enum.SavedQualitySetting.Automatic and saved.Value <= 2 then UI.fx.canvas = false end
end)

-- ---------------------------------------------------------------- factory
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
  if children then
    for _, child in ipairs(children) do child.Parent = instance end
  end
  if parent then instance.Parent = parent end
  return instance
end
local new = UI.new

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
-- radius: a token name ("rCard"), a pixel count, or true for a full pill
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

-- ---------------------------------------------------------------- text + icons
local STYLE = Theme.type
-- style: a key of Theme.type; color: a token name
function UI.text(parent, text, style, color, props)
  local spec = STYLE[style or "body"] or STYLE.body
  local label = Instance.new("TextLabel")
  label.BackgroundTransparency = 1
  label.BorderSizePixel = 0
  label.FontFace = B.F[spec[1]]
  if UI.fontKey then UI.fontKey[label] = spec[1] end
  label.TextSize = spec[2]
  label.Text = text or ""
  label.TextXAlignment = Enum.TextXAlignment.Left
  label.TextYAlignment = Enum.TextYAlignment.Center
  label.AutomaticSize = Enum.AutomaticSize.XY
  label.Size = UDim2.new()
  Theme.bind(label, "TextColor3", color or "ink")
  if props then
    for key, value in pairs(props) do label[key] = value end
  end
  label.Parent = parent
  return label
end
function UI.icon(parent, name, size, color, props)
  -- atlas stubbed: render icon name as a text glyph (TextLabel), never blank.
  local label = Instance.new("TextLabel")
  label.BackgroundTransparency = 1
  label.BorderSizePixel = 0
  label.Size = UDim2.fromOffset(size or 18, size or 18)
  label.Font = Enum.Font.SourceSans
  label.TextSize = size or 18
  label.TextXAlignment = Enum.TextXAlignment.Center
  label.TextYAlignment = Enum.TextYAlignment.Center
  label.Text = Assets.glyphChar(name)
  Theme.bind(label, "TextColor3", color or "ink")
  if props then
    for key, value in pairs(props) do label[key] = value end
  end
  label.Parent = parent
  return label
end
function UI.setIcon(label, name)
  if label and label:IsA("TextLabel") then label.Text = Assets.glyphChar(name) end
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

-- ---------------------------------------------------------------- glass
-- A translucent surface: tinted fill, fine grain, a top sheen and a rim that
-- catches light. level: "window" (reads the glass slider), "panel", "popover".
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
  if opts.props then
    for key, value in pairs(opts.props) do frame[key] = value end
  end
  frame.Parent = parent
  return frame, rimGradient
end

-- A quiet filled surface (cards, rows): ink at a low alpha with a hairline.
function UI.surface(parent, props, radius, fill)
  local frame = Instance.new("Frame")
  frame.BorderSizePixel = 0
  Theme.bind(frame, "BackgroundColor3", "ink")
  Theme.bind(frame, "BackgroundTransparency", fill or "fill1A")
  UI.corner(frame, radius or "rCard")
  if props then
    for key, value in pairs(props) do frame[key] = value end
  end
  frame.Parent = parent
  return frame
end

-- A container that can fade as one. Falls back to a plain frame where a
-- CanvasGroup would soften text; UI.fade then just shows or hides it.
function UI.group(parent, props)
  local group = Instance.new(UI.fx.canvas and "CanvasGroup" or "Frame")
  group.BackgroundTransparency = 1
  group.BorderSizePixel = 0
  if props then
    for key, value in pairs(props) do group[key] = value end
  end
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

-- ---------------------------------------------------------------- sound
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
-- A look's own sound, by its asset id (src/53: Novoline's), at the volume and speed that look plays
-- it at when the hub's sound volume is where it starts (45 %), and louder or softer with it.
function UI.sfxId(id, volume, speed)
  if not UI.sfxOn or UI.sfxVolume <= 0 or not UI.soundHost then return end
  local key = id .. "@" .. tostring(speed or 1)
  local now = os.clock()
  local entry = sounds[key]
  if entry and now - entry.at < 0.04 then return end
  if not entry then
    local sound = Instance.new("Sound")
    sound.SoundId = id
    sound.Parent = UI.soundHost
    entry = { sound = sound, at = 0 }
    sounds[key] = entry
  end
  entry.at = now
  entry.sound.Volume = math.clamp((volume or 1) * UI.sfxVolume / 0.45, 0, 2)
  entry.sound.PlaybackSpeed = speed or 1
  entry.sound.TimePosition = 0
  entry.sound:Play()
end

-- ---------------------------------------------------------------- input
local function isPress(input)
  return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end
UI.isPress = isPress
-- One coordinate space everywhere: the one AbsolutePosition reports. Measured on the client:
-- a ScreenGui that ignores the inset sits at AbsolutePosition (0, -58), InputObject.Position is
-- in that same space, and GetMouseLocation / the camera's viewport are 58 px further down.
function UI.inset() return S.GuiService:GetGuiInset() end
function UI.mouse() return UIS:GetMouseLocation() - S.GuiService:GetGuiInset() end
function UI.point(input) return Vector2.new(input.Position.X, input.Position.Y) end
-- design units -> screen pixels for anything inside the window (set by 06 window)
function UI.unit() return 1 end
function UI.inside(gui, point)
  local p, s = gui.AbsolutePosition, gui.AbsoluteSize
  return point.X >= p.X and point.X <= p.X + s.X and point.Y >= p.Y and point.Y <= p.Y + s.Y
end

-- Attach hover / press / click / alt (right click) handlers to a GuiButton.
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
-- An invisible button laid over `parent`. Only for parents WITHOUT a list layout or automatic
-- width: a full-size child there is laid out as an item and inflates the parent (measured:
-- a 60 px dropdown pill became 550 px). Those use UI.pressable instead.
function UI.button(parent, handlers, props)
  local button = Instance.new("TextButton")
  button.Name = "Hit"
  button.Text = ""
  button.BackgroundTransparency = 1
  button.BorderSizePixel = 0
  button.AutoButtonColor = false
  button.Size = UDim2.fromScale(1, 1)
  button.ZIndex = 5
  if props then
    for key, value in pairs(props) do button[key] = value end
  end
  UI.wire(button, handlers)
  button.Parent = parent
  return button
end
-- A container that is itself the button: children (labels, icons, layouts) go inside it.
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

-- Drag with mouse or finger. onMove(position, deltaFromStart); returns nothing.
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

-- ---------------------------------------------------------------- overlay layer
-- Popovers, menus and tooltips live in one full-screen layer above the window.
local popovers = {}
function UI.mountOverlay(gui, scaleSource)
  UI.overlay = UI.frame(gui, { Name = "Overlay", Size = UDim2.fromScale(1, 1), ZIndex = 50 })
  UI.overlayScale = scaleSource
  -- a click anywhere outside the open popover closes it
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
function UI.closePopovers()
  for index = #popovers, 1, -1 do popovers[index].close(true) end
end
function UI.popoverOpen() return #popovers > 0 end

-- Open a glass panel next to `anchor`. build(content, close) fills it.
-- opts: width, align ("left" | "right" | "center"), gap, side ("below" | "above")
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
  -- place it once its height is known
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

-- A simple menu: items = { { label, icon?, hint?, danger?, checked?, run } | "divider" }
-- A long one (more than opts.rows of them, 11 unless said) scrolls, and opens on the one that is checked.
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

-- ---------------------------------------------------------------- tooltip
-- One tip for the whole hub, in every look (2026-10-30: nearly every control says what it does when
-- the mouse rests on it). It comes beside what it is about (to its right, else its left, else under
-- it, always on the screen), fades and slides in, and goes straight on to the next thing the mouse
-- rests on without going away first. On a screen of its own, above everything.
local TIP_W, TIP_MIN = 250, 110
local tipGui, tipCard, tipTitle, tipBody, tipFor
local tipToken, tipShown, tipGoneAt = 0, false, -math.huge
local function tipBuild()
  if tipCard and tipCard.Parent and tipGui and tipGui.Parent then return true end
  if not B.alive then return false end
  tipGui = B.screen(9950)
  tipCard = Instance.new("CanvasGroup")
  tipCard.Name = "Tip"
  -- (one flat colour, no UIGradient: measured live 2026-10-30, a gradient on a CanvasGroup tints all
  -- that is drawn in it, and the words came out near black on the card)
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
local TIP_IN = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TIP_MOVE = TweenInfo.new(0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TIP_OUT = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local function tipShow(target, title, text)
  if not tipBuild() then return end
  tipTitle.Text, tipTitle.Visible = title or "", title ~= nil and title ~= ""
  tipBody.Text = text
  -- (as wide as its words want, up to TIP_W: a short tip is a small card)
  local width = math.clamp(math.max(#(title or "") * 7.2, #text * 6.3) + 24, TIP_MIN, TIP_W)
  tipCard.Size = UDim2.fromOffset(width, 0)
  local base = tipGui.AbsolutePosition
  local view = tipGui.AbsoluteSize
  local at, size = target.AbsolutePosition - base, target.AbsoluteSize
  local height = (tipTitle.Visible and 16 or 0) + math.ceil(#text * 6.3 / math.max(width - 22, 40)) * 16 + 20
  local x, y = at.X + size.X + 10, at.Y + size.Y / 2 - height / 2
  local from = Vector2.new(-8, 0)
  if x + width > view.X - 8 then
    x, from = at.X - width - 10, Vector2.new(8, 0)
    if x < 8 then
      -- (no room either side: under it, or over it)
      x = math.clamp(at.X + size.X / 2 - width / 2, 8, math.max(view.X - width - 8, 8))
      y, from = at.Y + size.Y + 8, Vector2.new(0, -6)
      if y + height > view.Y - 8 then y, from = at.Y - height - 8, Vector2.new(0, 6) end
    end
  end
  y = math.clamp(y, 8, math.max(view.Y - height - 8, 8))
  local goal = UDim2.fromOffset(math.floor(x), math.floor(y))
  if tipShown and tipCard.Visible then
    -- (already showing: it moves over to the new one)
    S.TweenService:Create(tipCard, TIP_MOVE, { Position = goal, GroupTransparency = 0 }):Play()
  else
    tipCard.Position = goal + UDim2.fromOffset(from.X, from.Y)
    tipCard.GroupTransparency = 1
    tipCard.Visible = true
    S.TweenService:Create(tipCard, TIP_IN, { Position = goal, GroupTransparency = 0 }):Play()
  end
  tipShown = true
end
local function tipHide()
  if not (tipShown and tipCard) then return end
  tipShown = false
  tipGoneAt = os.clock()
  local mine = tipToken
  S.TweenService:Create(tipCard, TIP_OUT, { GroupTransparency = 1 }):Play()
  task.delay(0.11, function() if mine == tipToken and not tipShown and tipCard then tipCard.Visible = false end end)
end
-- target: the thing the mouse rests on; text: what it does; title: its name (optional)
function UI.tooltip(target, text, title)
  if type(text) ~= "string" or text == "" then return end
  target.MouseEnter:Connect(function()
    tipToken += 1
    local mine = tipToken
    tipFor = target
    -- (one tip just showing, or just gone: the next comes at once, the way a menu's tips do)
    local quick = tipShown or os.clock() - tipGoneAt < 0.3
    task.delay(quick and 0.02 or 0.35, function()
      if mine ~= tipToken or tipFor ~= target or not B.alive or not target.Parent then return end
      B.try("ui.tip", tipShow, target, title, text)
    end)
  end)
  target.MouseLeave:Connect(function()
    if tipFor ~= target then return end
    tipFor = nil
    tipToken += 1
    local mine = tipToken
    task.delay(0.06, function() if mine == tipToken then tipHide() end end)
  end)
  -- (a click: it has been read; it goes)
  if target:IsA("GuiButton") then target.MouseButton1Down:Connect(function() tipToken += 1; tipFor = nil; tipHide() end) end
end
function UI.hideTip()
  tipToken += 1
  tipFor = nil
  tipHide()
end

-- ---------------------------------------------------------------- scroll
-- A vertical scroller with a spring-driven wheel and a scrollbar: a thumb that says how far down
-- the page is, grows under the pointer, and can be dragged; a press on the track beside it goes
-- there. UI.scrollbar: "always" (it rests faint), "auto" (only while the page moves), "off".
UI.scrollbar = "always"
local scrollers = setmetatable({}, { __mode = "k" })
function UI.setScrollbar(mode)
  UI.scrollbar = mode
  for _, paint in pairs(scrollers) do B.try("ui.scrollbar", paint) end
end
local BAR_REST, BAR_WIDE, BAR_GRIP = 3, 6, 14     -- the thumb at rest and under the pointer, and the strip that takes the pointer
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
  if props then
    for key, value in pairs(props) do scroller[key] = value end
  end
  scroller.Parent = parent
  local thumb = UI.frame(parent, { Name = "Thumb", Size = UDim2.fromOffset(BAR_REST, 40), AnchorPoint = Vector2.new(1, 0), ZIndex = 8,
    Theme = { BackgroundColor3 = "ink" }, BackgroundTransparency = 1 })
  UI.corner(thumb, true)
  local grip = UI.new("TextButton", { Name = "Scrollbar", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0),
    Size = UDim2.fromOffset(BAR_GRIP, 40), ZIndex = 9, Visible = false, Parent = parent })
  local target = 0
  local spring = Motion.spring(1, "smooth", function(x)
    scroller.CanvasPosition = Vector2.new(0, x[1])
  end, 0.2)
  local function limit()
    return math.max(0, scroller.AbsoluteCanvasSize.Y - scroller.AbsoluteWindowSize.Y)
  end
  local hideToken = 0
  local hovered, dragging, flashing, width = false, false, false, BAR_REST
  local bar = { top = 0, size = 0, span = 0 }       -- the thumb as it was last laid out, in screen pixels
  -- false when there is nothing to scroll, or the bar is switched off
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
  local widen = Motion.spring(1, "snappy", function(x)
    width = x[1]
    refresh()
  end, 0.05)
  widen:snap({ BAR_REST })
  -- how solid the thumb is: held, under the pointer, while the page moves, or at rest
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
    task.delay(0.9, function()
      if mine == hideToken and thumb.Parent then flashing = false; paint() end
    end)
  end
  scroller:GetPropertyChangedSignal("CanvasPosition"):Connect(flash)
  scroller:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(function()
    if target > limit() then target = limit(); spring:to({ target }) end
    paint()
  end)
  scroller:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(paint)
  -- the thumb held: the page goes with the pointer, with no spring between them
  local grab = 0
  local function follow(y)
    local ratio = bar.span > 0 and math.clamp((y - grab - bar.top) / bar.span, 0, 1) or 0
    target = ratio * limit()
    spring:snap({ target })
  end
  UI.drag(grip, function(point)
    if not refresh() then return false end
    local at = bar.top + bar.span * (scroller.CanvasPosition.Y / math.max(1, limit()))
    -- on the thumb it is taken where it was pressed; beside it, the thumb comes to the pointer
    grab = (point.Y >= at and point.Y <= at + bar.size) and (point.Y - at) or bar.size * 0.5
    dragging = true
    follow(point.Y)
    paint()
    return true
  end, function(point) follow(point.Y) end, function()
    dragging = false
    paint()
  end)
  grip.MouseEnter:Connect(function() hovered = true; paint() end)
  grip.MouseLeave:Connect(function() hovered = false; paint() end)
  local wheel = B.safe("ui.wheel", function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseWheel or B.touch then return end
    -- An open list (any popover) holds the page under it still: the wheel over it scrolls the list
    -- alone. Before, the page went on scrolling under an open dropdown and left it behind.
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
  grip.InputChanged:Connect(wheel)        -- (the strip lies over the page's edge: the wheel works there too)
  -- (painted once it is laid out, not only when something about it changes)
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

-- ---------------------------------------------------------------- the interface's letters
-- Settings > Font: every word the BASED look writes in one family (its wordmark keeps its own).
-- Done where the letters come from: B.F's keys take the family at their own weight, so whatever is
-- drawn from now on has it, and what is on screen already is moved across once, matched by the
-- face it wore. The other looks keep their own letters (Unnamed has its own font setting).
UI.FAMILIES = {
  { "inter", "Inter (BASED)" },
  { "monocraft", "Monocraft (Minecraft)", function() return B.F0 and B.F0.craft end },
  { "builder", "Builder Sans", "BuilderSans" },
  { "gotham", "Gotham", "GothamSSm" },
  { "montserrat", "Montserrat", "Montserrat" },
  { "nunito", "Nunito", "Nunito" },
  { "ubuntu", "Ubuntu", "Ubuntu" },
  { "titillium", "Titillium", "TitilliumWeb" },
  { "jura", "Jura", "Jura" },
  { "sarpanch", "Sarpanch", "Sarpanch" },
  { "michroma", "Michroma", "Michroma" },
  { "oswald", "Oswald", "Oswald" },
  { "fredoka", "Fredoka", "FredokaOne" },
  { "roboto", "Roboto Mono", "RobotoMono" },
  { "arial", "Arial", function() return Font.fromEnum(Enum.Font.Arial) end },
  { "source", "Source Sans", "SourceSansPro" },
}
-- the keys that follow the pick (the wordmark, wideBlack, stays BASED)
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
-- Which key each text on screen was drawn from (strong, swept): told by its face the first time it
-- is seen, from the hub's own faces (all different), or from the faces in use now. The second can be
-- two keys at once (in one family Inter 400 and Geist 400 are the same face): the body text wins,
-- and texts drawn by UI.text say their key outright. (Matching by face alone turned 381 labels into
-- the serif on the way back to Inter.)
UI.fontKey = {}
function UI.sweepFonts()
  for label in pairs(UI.fontKey) do
    if not label.Parent then UI.fontKey[label] = nil end
  end
end
function UI.setLetters(id)
  if not B.F0 then return end
  local family = UI.familyOf(id)
  local own, now = {}, {}
  for _, key in ipairs(LETTER_KEYS) do
    if B.F0[key] then own[faceSig(B.F0[key])] = own[faceSig(B.F0[key])] or key end
    if B.F[key] then now[faceSig(B.F[key])] = now[faceSig(B.F[key])] or key end
  end
  for label in pairs(UI.fontKey) do
    if not label.Parent then UI.fontKey[label] = nil end
  end
  for _, key in ipairs(LETTER_KEYS) do
    local own = B.F0[key]
    if own then
      if family then
        local ok, face = pcall(Font.new, family, own.Weight, own.Style)
        B.F[key] = ok and face or own
      else
        B.F[key] = own
      end
    end
  end
  -- what is on screen now: each text moved to its key's new face
  -- (the other looks keep their own letters, also where they draw on the HUD)
  local function owns(item) return (B.Unnamed ~= nil and B.Unnamed.owns(item)) or (B.Novoline ~= nil and B.Novoline.owns(item)) end
  for _, gui in ipairs(B.screens or {}) do
    if gui.Parent and not gui:GetAttribute("OwnLetters") then
      for _, item in ipairs(gui:GetDescendants()) do
        if (item:IsA("TextLabel") or item:IsA("TextButton") or item:IsA("TextBox")) and not owns(item) then
          local key = UI.fontKey[item]
          if not key then
            local sig = faceSig(item.FontFace)
            key = own[sig] or now[sig]
            if key then UI.fontKey[item] = key end
          end
          if key and B.F[key] and item.FontFace ~= B.F[key] then item.FontFace = B.F[key] end
        end
      end
    end
  end
end

-- ---------------------------------------------------------------- misc
function UI.divider(parent, order)
  local line = UI.frame(parent, { Name = "Divider", Size = UDim2.new(1, 0, 0, 1), LayoutOrder = order or 0,
    Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "strokeA" } })
  return line
end
-- Small rounded tag: "NEW", "BETA", a key name...
function UI.badge(parent, text, color, props)
  local badge = UI.frame(parent, { AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 18), Theme = { BackgroundColor3 = color or "accent" },
    BackgroundTransparency = 0.82 })
  UI.corner(badge, 6)
  UI.pad(badge, 0, 6)
  UI.text(badge, text, "eyebrow", color or "accent", { TextSize = 9, Size = UDim2.fromScale(0, 1), AutomaticSize = Enum.AutomaticSize.X })
  if props then
    for key, value in pairs(props) do badge[key] = value end
  end
  return badge
end
end

do -- 05_config.lua
-- ============================================================================
--  05 config   flags, profiles, keybinds
--
--  Every setting is a flag with an id. Ids under "app." are the hub's own
--  preferences (theme, intro, scale) and live in prefs.json; everything else is
--  a feature setting and lives in the active profile, which can be one file for
--  every game or one per game. Writes are debounced; nothing saves per frame.
-- ============================================================================
local S, fs, util = B.S, B.fs, B.util
local UIS = S.UserInputService
local Config = { profile = "default", changed = B.Signal.new(), loaded = B.Signal.new() }
B.Config = Config

local values, defaults, listeners = {}, {}, {}
local binds = {}            -- flag id -> { key = "E", mode = "toggle" | "hold" }
local actions = {}          -- id -> function, for bindable buttons
local stored = { app = {}, profile = {} }   -- raw decoded files, kept so unknown ids survive a save
local storedBinds = {}
Config.values, Config.defaults, Config.binds = values, defaults, binds

local function isApp(id) return string.sub(id, 1, 4) == "app." end
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
local function sameType(a, b)
  return typeof(a) == typeof(b)
end

-- What the hub ships with (based/shipped.json, baked in by the build): the settings a fresh
-- executor starts from. A shipped value takes the place of the default written in the code, so
-- a setting someone has saved still wins and Reset comes back to what shipped.
local shipped = type(B.SHIPPED) == "table" and B.SHIPPED or {}
local shippedValues = type(shipped.values) == "table" and shipped.values or {}
local shippedBinds = type(shipped.binds) == "table" and shipped.binds or {}

local function profilePath(name) return fs.path("config/" .. name .. ".json") end
local PREFS = fs.path("prefs.json")

-- Saving. Only what changed here is written, onto what is on disk at that moment: every account
-- open on this PC shares these files, and writing the whole of one client's memory undid what
-- another had just saved. A change made quietly (a test, a bot starting itself) is never written.
-- Whatever is waiting goes out at once on unload and on a teleport, not 0.6 s later or never.
local dirty, dirtyBinds = {}, {}
local pending = false
local function isDefault(id)
  local a, b = values[id], defaults[id]
  if type(a) ~= "table" or type(b) ~= "table" then return a == b end
  for k, v in pairs(a) do if b[k] ~= v then return false end end
  for k, v in pairs(b) do if a[k] ~= v then return false end end
  return true
end
local function flush()
  pending = false
  if next(dirty) == nil and next(dirtyBinds) == nil then return end
  local appTouched = false
  local prefs = fs.readJson(PREFS)
  prefs = type(prefs) == "table" and prefs or {}
  local app = type(prefs.values) == "table" and prefs.values or stored.app
  local bindOut = type(prefs.binds) == "table" and prefs.binds or nil
  if not bindOut then
    -- (nothing on disk yet: every key there is, the ones that shipped too, or they would be lost)
    bindOut = {}
    for id, bind in pairs(binds) do bindOut[id] = { key = bind.key, mode = bind.mode } end
    appTouched = true
  end
  local disk = fs.readJson(profilePath(Config.profile))
  local profile = (type(disk) == "table" and type(disk.values) == "table") and disk.values or stored.profile
  local profileTouched = false
  for id in pairs(dirty) do
    local bucket = isApp(id) and app or profile
    if values[id] == nil or isDefault(id) then bucket[id] = nil else bucket[id] = encode(values[id]) end
    if isApp(id) then appTouched = true else profileTouched = true end
  end
  for id in pairs(dirtyBinds) do
    local bind = binds[id]
    bindOut[id] = bind and { key = bind.key, mode = bind.mode } or nil
    appTouched = true
  end
  table.clear(dirty)
  table.clear(dirtyBinds)
  stored.app, stored.profile = app, profile
  if appTouched or prefs.profile ~= Config.profileMode then
    fs.writeJson(PREFS, { values = app, binds = bindOut, profile = Config.profileMode })
  end
  if profileTouched then
    fs.writeJson(profilePath(Config.profile), { values = profile, game = game.GameId, saved = os.time() })
  end
  Config.saved:fire()
end
Config.saved = B.Signal.new()
local later = util.debounce(0.6, function() if pending then B.try("config.save", flush) end end)
local function save() pending = true; later() end
function Config.save() save() end
-- write what is waiting now (unload, teleport, a profile switch)
function Config.flush() if pending or next(dirty) or next(dirtyBinds) then B.try("config.flush", flush) end end
function Config.touch(id) dirty[id] = true; save() end
B.onUnload:connect(function() Config.flush() end)

-- Register a flag. Returns its current value (the saved one when there is one).
function Config.define(id, default)
  if defaults[id] ~= nil then return values[id] end
  local ships = decode(shippedValues[id])
  if ships ~= nil and sameType(ships, default) then default = ships end
  defaults[id] = default
  local bucket = isApp(id) and stored.app or stored.profile
  local saved = decode(bucket[id])
  if saved ~= nil and sameType(saved, default) then values[id] = saved else values[id] = default end
  local savedBind = storedBinds[id]
  if savedBind and savedBind.key and not binds[id] then
    binds[id] = { key = savedBind.key, mode = savedBind.mode or "toggle" }
    -- (a switch made after the keys started listening, on a tab built later: its key works at once)
    if Config.reindex then Config.reindex() end
  end
  return values[id]
end
function Config.get(id) return values[id] end
function Config.set(id, value, quiet)
  if defaults[id] == nil then defaults[id] = value end
  local old = values[id]
  if old == value and type(value) ~= "table" then return end
  values[id] = value
  local list = listeners[id]
  if list then
    for _, fn in ipairs(table.clone(list)) do B.try("config." .. id, fn, value, old) end
  end
  if not quiet then
    dirty[id] = true
    Config.changed:fire(id, value)
    save()
  end
end
function Config.reset(id) if defaults[id] ~= nil then Config.set(id, util.copy(defaults[id])) end end
function Config.isDefault(id) return isDefault(id) end
-- fn(value, old) on every change; `now` also calls it once with the current value.
function Config.on(id, fn, now)
  local list = listeners[id]
  if not list then list = {}; listeners[id] = list end
  list[#list + 1] = fn
  if now and values[id] ~= nil then B.try("config." .. id, fn, values[id], nil) end
  return function()
    local at = table.find(list, fn)
    if at then table.remove(list, at) end
  end
end
-- Mirror a set of flags into a plain table that feature loops can read for free:
--   local O = Config.mirror({ enabled = "esp.enabled", range = "esp.range" })
function Config.mirror(map, onChange)
  local out = {}
  for key, id in pairs(map) do
    out[key] = values[id]
    Config.on(id, function(value)
      out[key] = value
      if onChange then onChange(key, value) end
    end)
  end
  return out
end

-- ---------------------------------------------------------------- profiles
Config.profileMode = "global"     -- "global": one config everywhere; "game": one per game
function Config.profiles()
  local out = {}
  for _, file in ipairs(fs.list(fs.path("config"))) do
    local name = string.match(file, "([^/]+)%.json$")
    if name then out[#out + 1] = name end
  end
  if not table.find(out, "default") then table.insert(out, 1, "default") end
  return out
end
local function readProfile(name)
  local data = fs.readJson(profilePath(name))
  return type(data) == "table" and type(data.values) == "table" and data.values or {}
end
function Config.init()
  local prefs = fs.readJson(PREFS)
  if type(prefs) == "table" then
    stored.app = type(prefs.values) == "table" and prefs.values or {}
    storedBinds = type(prefs.binds) == "table" and prefs.binds or {}
    if prefs.profile == "game" then Config.profileMode = "game" end
  else
    -- nothing saved here yet: the keys that ship. Only then, or a key someone cleared would come back.
    storedBinds = shippedBinds
    -- (and the first launch on this machine: the look is picked before the hub opens, src/13_picker)
    Config.firstRun = true
  end
  Config.profile = Config.profileMode == "game" and ("game_" .. tostring(game.GameId)) or "default"
  stored.profile = readProfile(Config.profile)
  -- (a teleport ends this client: what is waiting is written as it starts)
  pcall(function()
    B.connect(B.LP.OnTeleport, function(state)
      if state == Enum.TeleportState.Started or state == Enum.TeleportState.InProgress then Config.flush() end
    end, "config.teleport")
  end)
end
-- Switch to another profile: every feature flag takes the value saved there.
function Config.load(name)
  Config.flush()                          -- (what is waiting belongs to the profile being left)
  Config.profile = name
  stored.profile = readProfile(name)
  for id, default in pairs(defaults) do
    if not isApp(id) then
      local saved = decode(stored.profile[id])
      if saved == nil or not sameType(saved, default) then saved = util.copy(default) end
      Config.set(id, saved, true)
    end
  end
  Config.loaded:fire(name)
  -- (the mode lives in prefs.json)
  local prefs = fs.readJson(PREFS)
  if type(prefs) == "table" and prefs.profile ~= Config.profileMode then
    prefs.profile = Config.profileMode
    fs.writeJson(PREFS, prefs)
  end
end
function Config.saveAs(name)
  name = string.gsub(name, "[^%w_%-]", "")
  if name == "" then return false end
  Config.flush()
  Config.profile = name
  stored.profile = {}
  for id in pairs(defaults) do
    if not isApp(id) then dirty[id] = true end
  end
  save()
  return true
end
function Config.delete(name)
  if name == "default" then return false end
  return fs.remove(profilePath(name))
end
function Config.setMode(mode)
  Config.profileMode = mode
  Config.load(mode == "game" and ("game_" .. tostring(game.GameId)) or "default")
end
function Config.resetAll(includeApp)
  for id, default in pairs(defaults) do
    if includeApp or not isApp(id) then Config.set(id, util.copy(default)) end
  end
end
-- The share code: EVERY setting (the look too: colours, font, menu style, intro) and every key,
-- as "BASED2:" and base64. Pasted in, the other hub becomes this one: what the code has is set,
-- and what it leaves out is put back to its default, so nothing of theirs is left mixed in.
-- (The first version carried feature settings only, and only ones changed from their defaults:
-- a colour, a key, or a setting the other person had changed and this one had not stayed theirs.)
local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function toBase64(data)
  return ((string.gsub(data, ".", function(x)
    local r, byte = "", string.byte(x)
    for i = 8, 1, -1 do r ..= (byte % 2 ^ i - byte % 2 ^ (i - 1) > 0 and "1" or "0") end
    return r
  end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
    if #x < 6 then return "" end
    local c = 0
    for i = 1, 6 do c += (string.sub(x, i, i) == "1" and 2 ^ (6 - i) or 0) end
    return string.sub(B64, c + 1, c + 1)
  end) .. ({ "", "==", "=" })[#data % 3 + 1])
end
local function fromBase64(data)
  data = string.gsub(data, "[^" .. B64 .. "=]", "")
  return (data:gsub(".", function(x)
    if x == "=" then return "" end
    local r, f = "", (string.find(B64, x, 1, true) - 1)
    for i = 6, 1, -1 do r ..= (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and "1" or "0") end
    return r
  end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
    if #x ~= 8 then return "" end
    local c = 0
    for i = 1, 8 do c += (string.sub(x, i, i) == "1" and 2 ^ (8 - i) or 0) end
    return string.char(c)
  end))
end
Config.toBase64, Config.fromBase64 = toBase64, fromBase64
-- where windows sit is the screen's business, not a setup's
local PLACE = { ["app.window.x"] = true, ["app.window.y"] = true, ["app.unnamed.x"] = true, ["app.unnamed.y"] = true, ["app.keyHudX"] = true, ["app.keyHudY"] = true }
-- (and some things are yours alone: a share code leaves them out, and pasting one leaves yours be)
function Config.unshared(id) PLACE[id] = true end
function Config.export()
  local out, keys = {}, {}
  for id, value in pairs(values) do
    if not PLACE[id] and defaults[id] ~= nil and not isDefault(id) then out[id] = encode(value) end
  end
  for id, bind in pairs(binds) do
    if bind.key then keys[id] = { key = bind.key, mode = bind.mode } end
  end
  local ok, json = pcall(S.HttpService.JSONEncode, S.HttpService, { based = 2, values = out, binds = keys, full = true })
  return ok and ("BASED2:" .. toBase64(json)) or nil
end
function Config.import(text)
  text = tostring(text or "")
  local json = text
  local coded = string.match(text, "BASED2:(%S+)")
  if coded then json = fromBase64(coded) end
  local ok, data = pcall(S.HttpService.JSONDecode, S.HttpService, json)
  if not ok or type(data) ~= "table" or type(data.values) ~= "table" then return false, 0 end
  local count = 0
  -- (an old code holds feature settings only, changed ones: those alone are set)
  if data.full then
    for id, default in pairs(defaults) do
      if data.values[id] == nil and not PLACE[id] and not isDefault(id) then Config.set(id, util.copy(default)) end
    end
  end
  for id, raw in pairs(data.values) do
    local default = defaults[id]
    local value = decode(raw)
    if default ~= nil and value ~= nil and sameType(value, default) and not PLACE[id] and (data.full or not isApp(id)) then
      Config.set(id, value)
      count += 1
    end
  end
  if type(data.binds) == "table" then
    for id in pairs(table.clone(binds)) do
      if data.binds[id] == nil then Config.bind(id, nil) end
    end
    for id, bind in pairs(data.binds) do
      if type(bind) == "table" and type(bind.key) == "string" then Config.bind(id, bind.key, bind.mode == "hold" and "hold" or "toggle"); count += 1 end
    end
  end
  return true, count
end

-- ---------------------------------------------------------------- keybinds
local byKey = {}
local function keyName(input)
  if input.UserInputType == Enum.UserInputType.Keyboard then return input.KeyCode.Name end
  if input.UserInputType == Enum.UserInputType.MouseButton2 then return "MouseButton2" end
  if input.UserInputType == Enum.UserInputType.MouseButton3 then return "MouseButton3" end
  return nil
end
Config.keyName = keyName
local function reindex()
  table.clear(byKey)
  for id, bind in pairs(binds) do
    if bind.key then
      local list = byKey[bind.key]
      if not list then list = {}; byKey[bind.key] = list end
      list[#list + 1] = id
    end
  end
end
Config.reindex = reindex
Config.bindsChanged = B.Signal.new()
function Config.bind(id, key, mode)
  if not key then binds[id] = nil else binds[id] = { key = key, mode = mode or (binds[id] and binds[id].mode) or "toggle" } end
  reindex()
  dirtyBinds[id] = true
  Config.bindsChanged:fire(id)
  save()
end
function Config.bindOf(id) return binds[id] end
-- A button that can be bound (an emote, mark the one looked at...). Its saved key comes back here:
-- before, only switches took theirs back (in define), and every key on a button was lost on rejoin.
function Config.action(id, fn)
  actions[id] = fn
  local savedBind = storedBinds[id]
  if savedBind and savedBind.key and not binds[id] then
    binds[id] = { key = savedBind.key, mode = savedBind.mode or "toggle" }
    reindex()
    Config.bindsChanged:fire(id)
  end
end
function Config.isAction(id) return actions[id] ~= nil end
-- Whether a button's work is going on, for the key list to light it like a switch that is on: its
-- own say if it has one (an emote: while it plays), else for a moment after its key was pressed.
local actionStates = {}
Config.ranAt = {}
Config.actionRan = B.Signal.new()
function Config.actionState(id, fn) actionStates[id] = fn end
function Config.isActive(id)
  local state = actionStates[id]
  if state then
    local ok, on = pcall(state)
    if ok and on then return true end
    if ok and on == false then return false end
  end
  local at = Config.ranAt[id]
  return at ~= nil and os.clock() - at < 0.6
end
local SHORT = { LeftControl = "LCtrl", RightControl = "RCtrl", LeftShift = "LShift", RightShift = "RShift", LeftAlt = "LAlt", RightAlt = "RAlt",
  MouseButton2 = "RMB", MouseButton3 = "MMB", Return = "Enter", Backspace = "Bksp", CapsLock = "Caps", Escape = "Esc", Delete = "Del",
  Insert = "Ins", PageUp = "PgUp", PageDown = "PgDn", Semicolon = ";", Quote = "'", Comma = ",", Period = ".", Slash = "/", BackSlash = "\\",
  LeftBracket = "[", RightBracket = "]", Minus = "-", Equals = "=", Backquote = "`", Space = "Space", Unknown = "None",
  One = "1", Two = "2", Three = "3", Four = "4", Five = "5", Six = "6", Seven = "7", Eight = "8", Nine = "9", Zero = "0" }
function Config.keyLabel(key)
  if not key then return "None" end
  return SHORT[key] or (string.gsub(key, "^Keypad", "Num"))
end
Config.capturing = false   -- true while a keybind control is listening for a key
-- A switch can have a quick panel: its key tapped flips it as always, its key HELD (0.3 s) opens the
-- panel instead and letting go closes it (the ragebot's: who to hunt). { open = fn, close = fn }
Config.holdPanels = {}
local held = {}
local HOLD = 0.3

function Config.listen()
  reindex()
  B.connect(UIS.InputBegan, function(input, processed)
    if Config.capturing then return end
    local key = keyName(input)
    if not key then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
      if UIS:GetFocusedTextBox() then return end
    elseif processed then
      return
    end
    local list = byKey[key]
    if not list then return end
    for _, id in ipairs(list) do
      local bind = binds[id]
      local panel = Config.holdPanels[id]
      if actions[id] then
        B.try("bind." .. id, actions[id])
        Config.ranAt[id] = os.clock()
        Config.actionRan:fire(id)
      elseif type(values[id]) == "boolean" and panel and bind.mode ~= "hold" then
        -- (decided when it is let go: a tap flips it, a hold opened the panel)
        local mine = { at = os.clock(), key = key }
        held[id] = mine
        task.delay(HOLD, function()
          if held[id] == mine and Config.keyDown(key) then
            mine.opened = true
            B.try("hold." .. id, panel.open, key)
          end
        end)
      elseif type(values[id]) == "boolean" then
        if bind.mode == "hold" then Config.set(id, true) else Config.set(id, not values[id]) end
      end
    end
  end, "keybinds")
  B.connect(UIS.InputEnded, function(input)
    local key = keyName(input)
    local list = key and byKey[key]
    if not list then return end
    for _, id in ipairs(list) do
      local bind = binds[id]
      local press = held[id]
      if press and press.key == key then
        held[id] = nil
        if press.opened then
          local panel = Config.holdPanels[id]
          if panel and panel.close then B.try("hold.close." .. id, panel.close) end
        elseif type(values[id]) == "boolean" then
          Config.set(id, not values[id])
        end
      elseif bind.mode == "hold" and type(values[id]) == "boolean" and not actions[id] then
        Config.set(id, false)
      end
    end
  end, "keybinds")
end
-- true while the key bound to `id` (or `key`) is physically down
function Config.keyDown(key)
  if not key then return false end
  if key == "MouseButton2" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) end
  if key == "MouseButton3" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton3) end
  local ok, code = pcall(function() return Enum.KeyCode[key] end)
  return ok and code ~= nil and UIS:IsKeyDown(code)
end
end

do -- 06_controls.lua
-- ============================================================================
--  06 controls  rows and the things on their right-hand side
--
--  A control is a row inside a card: label (and description) on the left, the
--  control on the right. Every control is backed by a Config flag, so it saves,
--  reloads with a profile, can be reset from its context menu and, for toggles
--  and buttons, bound to a key.
-- ============================================================================
local S, util, Motion, Theme, T, UI, Config = B.S, B.util, B.Motion, B.Theme, B.T, B.UI, B.Config
local UIS = S.UserInputService
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
  -- (what it does, on hover: the tip of a control with no line of its own under its name)
  if spec.tip and spec.tip ~= "" then UI.tooltip(row, spec.tip, spec.label) end
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
      B.Window.toast({ title = "Press a key", text = "Esc cancels · Backspace clears", icon = "keyboard", time = 2.2 })
      Controls.captureKey(function(key, cancelled)
        if cancelled then return end
        Config.bind(id, key)
        B.Window.toast({ title = key and ("Bound to " .. Config.keyLabel(key)) or "Key cleared", text = spec.label, icon = "keyboard" })
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
        B.try("toggle.children", spec.children, B.Window.sectionApi(sub))
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

  local field = UI.new("TextBox", { Name = "Value", Size = UDim2.fromOffset(wide, 24), BackgroundTransparency = 1, Text = text(value), FontFace = B.F.mono400,
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
        local link = UI.new("TextButton", { Text = action[1], FontFace = B.F.text500, TextSize = 12, BackgroundTransparency = 1, AutoButtonColor = false,
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
  function api.set(next, quiet)
    next = next or "None"
    if next == value then return end
    if id then Config.set(id, next, quiet) else
      value = next; show()
      if spec.changed then B.try("keybind", spec.changed, next) end
    end
  end
  return api
end

-- ---------------------------------------------------------------- text input
function Controls.field(parent, props, onSubmit)
  local field = UI.frame(parent, { Name = "Field", Size = UDim2.fromOffset(150, 28), Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill2A" } })
  UI.corner(field, "rSmall")
  local stroke = UI.stroke(field, "accent", 1, 1)
  local box = UI.new("TextBox", { Name = "Box", BackgroundTransparency = 1, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(10, 0), Text = "",
    FontFace = B.F.text400, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, ClipsDescendants = true,
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
  function api.set(next, quiet)
    if id then Config.set(id, next, quiet) else
      value = next
      if box.Parent and not box:IsFocused() then box.Text = tostring(next) end
      if spec.changed then B.try("input", spec.changed, next) end
    end
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
    hexField, hexBox = Controls.field(bottom, { Width = 96, Text = "#" .. util.toHex(initial), FontFace = B.F.mono400, TextSize = 12 }, function(text)
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

do -- 07_window.lua
-- ============================================================================
--  07 window   the shell: glass, sidebar, pages, cards, toasts, palette, blur
-- ============================================================================
local S, util, Motion, Theme, T, UI, Config, Controls = B.S, B.util, B.Motion, B.Theme, B.T, B.UI, B.Config, B.Controls
local UIS = S.UserInputService
local Window = { open = false, built = false, pages = {}, order = {}, index = {}, scale = 1, onShow = B.Signal.new(), onPage = B.Signal.new() }
B.Window = Window

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
    build = spec.build, built = false, bandCount = 0, sectionCount = 0, order = spec.order or (#Window.order + 1) * 10 }, Page)
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
  if page.sectionCount == 0 and page.bandCount == 0 then
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
      -- (under a film a tab built in one frame shows as a skipped picture: measured 2026-10-29,
      -- 57 of 887 skipped at boot against 17 with the hub idle, so they are spaced out more then)
      task.wait((B.Loader and B.Loader.active) and 0.3 or 0.05)
    end
  end
  Window.prebuilding = false
  -- (the key list on screen names each feature by its switch: they are all known now)
  if B.Keys and B.Keys.repaint then B.Keys.repaint() end
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
  UI.text(mark, "BASED", "brand", "ink", { LayoutOrder = 1, TextSize = 17 })
  UI.text(mark, "hub", "display", "accent", { LayoutOrder = 2, TextSize = 21 })
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
    BackgroundTransparency = 0, Theme = { BackgroundColor3 = "ink" }, Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(B.LP.UserId) .. "&w=150&h=150", Parent = user })
  avatar.BackgroundTransparency = 0.9
  UI.corner(avatar, true)
  UI.text(user, B.LP.DisplayName, "label", "ink", { Position = UDim2.fromOffset(50, 9), Size = UDim2.new(1, -78, 0, 17), AutomaticSize = Enum.AutomaticSize.None,
    TextTruncate = Enum.TextTruncate.AtEnd, TextSize = 13 })
  Window.userLine = UI.text(user, "@" .. B.LP.Name, "caption", "faint", { Position = UDim2.fromOffset(50, 26), Size = UDim2.new(1, -78, 0, 15),
    AutomaticSize = Enum.AutomaticSize.None, TextTruncate = Enum.TextTruncate.AtEnd, TextSize = 11 })
  local more = UI.icon(user, "ellipsis", 16, "faint", { Position = UDim2.new(1, -12, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5) })
  UI.button(user, {
    hover = function(on) Motion.to(user, "BackgroundTransparency", on and T.fill2A or 1, "quick") end,
    click = function()
      UI.menu(more, {
        { label = "Settings", icon = "settings", run = function() Window.go("settings") end },
        { label = "Search", icon = "search", hint = "Ctrl K", run = function() Window.palette() end },
        { label = "Unnamed menu", icon = "app-window", run = function() Config.set("app.gui", "unnamed") end },
        { label = "Novoline menu", icon = "layout-grid", run = function() Config.set("app.gui", "novoline") end },
        "divider",
        { label = "Hide hub", icon = "eye-off", hint = Config.keyLabel(Config.get("app.key.menu")), run = function() Window.show(false) end },
        { label = "Unload BASED", icon = "power", danger = true, run = function() B.unload() end },
      }, { side = "above", align = "left", width = 214 })
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
  Window.eyebrow.Text = string.upper(page.eyebrow or (page.group ~= "" and page.group or "BASED"))
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
-- any look of the hub is up: the BASED window, the Unnamed menu (src/52) or the Novoline one (src/53)
function Window.anyOpen()
  return Window.open or (B.Unnamed ~= nil and B.Unnamed.open == true) or (B.Novoline ~= nil and B.Novoline.open == true)
end
-- a tab on screen in any look. (Live parts of a tab asked the BASED window alone, and stood still
-- in the other looks.)
function Window.showing(id)
  if Window.open and Window.current ~= nil and Window.current.id == id then return true end
  local unnamed, novoline = B.Unnamed, B.Novoline
  if unnamed ~= nil and unnamed.open == true and unnamed.current == id then return true end
  return novoline ~= nil and novoline.open == true and novoline.current == id
end
-- which look is in use, and opening or closing it (the menu key)
function Window.look()
  local look = Config.get("app.gui")
  if look == "unnamed" and B.Unnamed then return "unnamed" end
  if look == "novoline" and B.Novoline then return "novoline" end
  return "based"
end
function Window.showActive(on)
  local look = Window.look()
  if look == "unnamed" then B.Unnamed.show(on) elseif look == "novoline" then B.Novoline.show(on) else Window.show(on) end
end
function Window.toggleActive()
  local look = Window.look()
  if look == "unnamed" then B.Unnamed.toggle() elseif look == "novoline" then B.Novoline.toggle() else Window.toggle() end
end

-- ---------------------------------------------------------------- the look kit
-- A tab that draws part of itself (the music player, a preview) takes its colours, letters and
-- corners from the look it is drawn in: Window.kit(frame). The BASED one is here; the Unnamed and
-- Novoline looks put theirs in Window.kits with an `owns(frame)` that says a frame is theirs.
--   kit.paint(instance, property, role)  set a colour and keep it in step (theme, accent)
--   kit.fill(instance, role)             a surface: colour and see-through together
--   kit.text(parent, value, props, bold, size), kit.entry(parent, size)  in the look's letters
--   kit.clear(instance)                  no surface (after a hover)
--   kit.outline(frame), kit.corner(frame, radius), kit.menu(anchor, items)
-- roles: card field hover line back text dim faint accent onAccent good bad
local ROLES = {
  card = { "ink", "fill1A" }, field = { "ink", "fill2A" }, hover = { "ink", "fill3A" }, line = { "ink", "strokeA" }, back = { "base", "baseA" },
  text = { "ink" }, dim = { "sub" }, faint = { "faint" }, accent = { "accent" }, onAccent = { "accentInk" }, good = { "ok" }, bad = { "bad" },
}
local kit = { look = "based", radius = 14, small = 9, size = 13 }
function kit.color(role)
  local r = ROLES[role] or ROLES.text
  return T[r[1]], r[2] and T[r[2]] or 0
end
function kit.paint(instance, property, role)
  Theme.bind(instance, property, (ROLES[role] or ROLES.text)[1])
end
function kit.fill(instance, role)
  local r = ROLES[role] or ROLES.card
  Theme.bind(instance, "BackgroundColor3", r[1])
  if r[2] then Theme.bind(instance, "BackgroundTransparency", r[2]) else
    Theme.unbind(instance, "BackgroundTransparency")
    instance.BackgroundTransparency = 0
  end
end
-- no surface at all (after a hover): the theme lets go of it too
function kit.clear(instance)
  Theme.unbind(instance, "BackgroundTransparency")
  instance.BackgroundTransparency = 1
end
function kit.font(bold) return bold and B.F.text600 or B.F.text500 end
function kit.text(parent, value, props, bold, size)
  local label = UI.text(parent, value, bold and "heading" or "label", "ink", { AutomaticSize = Enum.AutomaticSize.None, TextSize = size or 13 })
  if props then for key, v in pairs(props) do label[key] = v end end
  return label
end
function kit.entry(parent, size)
  local entry = Instance.new("TextBox")
  entry.BackgroundTransparency, entry.BorderSizePixel = 1, 0
  entry.FontFace = B.F.text500
  UI.fontKey[entry] = "text500"
  entry.TextSize = size or 13
  entry.TextXAlignment, entry.ClearTextOnFocus, entry.ClipsDescendants = Enum.TextXAlignment.Left, false, true
  Theme.bind(entry, "TextColor3", "ink")
  Theme.bind(entry, "PlaceholderColor3", "faint")
  entry.Parent = parent
  return entry
end
function kit.outline(frame) return UI.stroke(frame, "ink", "strokeA") end
function kit.corner(frame, radius) return UI.corner(frame, radius or kit.radius) end
function kit.menu(anchor, items) return UI.menu(anchor, items, { align = "right" }) end
Window.kits = { based = kit }
function Window.kit(frame)
  for name, other in pairs(Window.kits) do
    if name ~= "based" and other.owns and frame and other.owns(frame) then return other end
  end
  return kit
end
-- the kit of the look in use (for what sits on the HUD, outside any window)
function Window.activeKit() return Window.kits[Window.look()] or kit end

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

do -- 51_keys.lua
-- ============================================================================
--  51 keys     the keyboard, drawn, with what every key does written on it
--
--  A key can be given a feature from either side: right-click a toggle or a
--  button and press a key, or come here, click the key and pick the feature.
--  The picture is the same either way. A bound key carries its feature's name
--  and lights up while that feature is on; the keys the hub and flight already
--  use are marked; a key asked to do two things is flagged. The same list can
--  sit on screen while the hub is hidden.
-- ============================================================================
local S, util, Motion, Theme, T, UI, Config, Window, Controls = B.S, B.util, B.Motion, B.Theme, B.T, B.UI, B.Config, B.Window, B.Controls
local UIS = S.UserInputService
local Keys = { caps = {}, builtin = {} }
B.Keys = Keys
B.pages = B.pages or {}

-- An ANSI board in units of one key; every row is fifteen units wide. A unit of 48 keeps every
-- key an even number of pixels wide, which matters: a UDim offset is a whole number, and a key
-- anchored at its centre with an odd width sits half a pixel off its neighbours.
local UNIT, GAP, HEIGHT = 44, 4, 40
local function k(key, width) return { key = key, width = width or 1 } end
local function gap(width) return { width = width } end
local ROWS = {
  { k("Escape"), gap(1), k("F1"), k("F2"), k("F3"), k("F4"), gap(0.5), k("F5"), k("F6"), k("F7"), k("F8"), gap(0.5), k("F9"), k("F10"), k("F11"), k("F12") },
  { k("Backquote"), k("One"), k("Two"), k("Three"), k("Four"), k("Five"), k("Six"), k("Seven"), k("Eight"), k("Nine"), k("Zero"), k("Minus"), k("Equals"), k("Backspace", 2) },
  { k("Tab", 1.5), k("Q"), k("W"), k("E"), k("R"), k("T"), k("Y"), k("U"), k("I"), k("O"), k("P"), k("LeftBracket"), k("RightBracket"), k("BackSlash", 1.5) },
  { k("CapsLock", 1.75), k("A"), k("S"), k("D"), k("F"), k("G"), k("H"), k("J"), k("K"), k("L"), k("Semicolon"), k("Quote"), k("Return", 2.25) },
  { k("LeftShift", 2.25), k("Z"), k("X"), k("C"), k("V"), k("B"), k("N"), k("M"), k("Comma"), k("Period"), k("Slash"), k("RightShift", 2.75) },
  { k("LeftControl", 1.5), k("LeftAlt", 1.25), k("Space", 5.5), k("RightAlt", 1.25), k("RightControl", 1.5), k("Left"), k("Up"), k("Down"), k("Right") },
  { k("Insert", 1.25), k("Delete", 1.25), k("Home", 1.25), k("End", 1.25), k("PageUp", 1.25), k("PageDown", 1.25), gap(0.5), k("MouseButton2", 2.25), k("MouseButton3", 2.25) },
}
Keys.width = 15 * (UNIT + GAP) - GAP
Keys.height = #ROWS * (HEIGHT + GAP) - GAP
local LONG = { MouseButton2 = "Right click", MouseButton3 = "Middle click", Backspace = "Backspace", Return = "Enter", CapsLock = "Caps", Space = "Space",
  LeftShift = "Shift", RightShift = "Shift", LeftControl = "Ctrl", RightControl = "Ctrl", LeftAlt = "Alt", RightAlt = "Alt", Tab = "Tab", Escape = "Esc",
  Insert = "Ins", Delete = "Del", PageUp = "PgUp", PageDown = "PgDn" }
-- on the cap the two Shifts and the two Ctrls are told apart by where they sit; in a sentence they need saying
local function capLabel(key) return LONG[key] or Config.keyLabel(key) end
local function keyName(key) return Config.keyLabel(key) end

-- ---------------------------------------------------------------- what is on a key
-- the keys the hub and flight already use, read fresh: three of them can be moved
local function readBuiltins()
  local map = {}
  local function put(key, short, what, flag)
    if type(key) ~= "string" or key == "None" then return end
    map[key] = map[key] or {}
    table.insert(map[key], { short = short, what = what, flag = flag })
  end
  put(Config.get("app.key.menu"), "Menu", "opens and closes the hub", "app.key.menu")
  put(Config.get("app.key.panic"), "Panic", "unloads BASED", "app.key.panic")
  put(Config.get("fly.key.boost"), "Boost", "flight: boost", "fly.key.boost")
  put(Config.get("fly.key.down"), "Descend", "flight: come down", "fly.key.down")
  put("Space", "Climb", "flight: charge on the ground, climb in the air")
  for _, key in ipairs({ "W", "A", "S", "D" }) do put(key, "Move", "walk and steer") end
  Keys.builtin = map
  return map
end
-- (a feature whose switch has not been drawn yet is named from its id: "dahood.airJump" -> "Air jump")
local function nameFromId(id)
  local last = string.match(id, "([^%.]+)$") or id
  last = string.gsub(last, "(%l)(%u)", "%1 %2")
  return string.upper(string.sub(last, 1, 1)) .. string.lower(string.sub(last, 2))
end
local function featureOf(id)
  local entry = Controls.bindables[id]
  local kind = entry and entry.kind or (type(Config.get(id)) == "boolean" and "toggle" or "button")
  return entry and entry.label or nameFromId(id), kind, entry and entry.page and entry.page.title or nil
end
-- every feature bound to `key`, by name
function Keys.on(key)
  local list = {}
  for id, bind in pairs(Config.binds) do
    if bind.key == key then
      local label, kind, page = featureOf(id)
      list[#list + 1] = { id = id, label = label, kind = kind, page = page, mode = bind.mode, on = Config.get(id) == true or (kind == "button" and Config.isActive(id)) }
    end
  end
  table.sort(list, function(a, b) return a.label < b.label end)
  return list
end
-- every bind there is, in keyboard order
function Keys.all()
  local order, list = {}, {}
  for _, row in ipairs(ROWS) do
    for _, item in ipairs(row) do
      if item.key then order[item.key] = #list + 1; list[#list + 1] = item.key end
    end
  end
  local out = {}
  for id, bind in pairs(Config.binds) do
    if bind.key then
      local label, kind, page = featureOf(id)
      out[#out + 1] = { id = id, key = bind.key, label = label, kind = kind, page = page, mode = bind.mode, on = Config.get(id) == true or (kind == "button" and Config.isActive(id)) }
    end
  end
  table.sort(out, function(a, b)
    local ka, kb = order[a.key] or 999, order[b.key] or 999
    if ka ~= kb then return ka < kb end
    return a.label < b.label
  end)
  return out
end
function Keys.describe(key)
  local features, roles = Keys.on(key), Keys.builtin[key]
  local parts = {}
  for _, f in ipairs(features) do
    parts[#parts + 1] = f.label .. (f.kind == "toggle" and (f.mode == "hold" and " (while held" or " (toggle") .. (f.on and ", on)" or ", off)") or " (runs it)")
  end
  for _, role in ipairs(roles or {}) do parts[#parts + 1] = role.what end
  local name = keyName(key)
  if #parts == 0 then return name .. "  ·  free. Click it to give it a feature." end
  local clash = #features > 1 or (#features > 0 and roles ~= nil)
  return name .. "  ·  " .. table.concat(parts, "  +  ") .. (clash and "   — more than one thing on this key" or "")
end

-- ---------------------------------------------------------------- menus
local function menuRow(content, order, item, close)
  local row = UI.frame(content, { Name = item.name or "Item", Size = UDim2.new(1, 0, 0, 32), LayoutOrder = order, Theme = { BackgroundColor3 = "ink" } })
  UI.corner(row, "rSmall")
  local x = 10
  if item.icon then
    UI.icon(row, item.icon, 16, item.danger and "bad" or "sub", { Position = UDim2.new(0, 10, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5) })
    x = 34
  end
  UI.text(row, item.label, "label", item.danger and "bad" or "ink", { Position = UDim2.new(0, x, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), TextSize = 13,
    Size = UDim2.new(1, -(x + (item.hint and 78 or 30)), 0, 18), AutomaticSize = Enum.AutomaticSize.None, TextTruncate = Enum.TextTruncate.AtEnd })
  if item.checked then
    UI.icon(row, "check", 15, "accent", { Position = UDim2.new(1, -10, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5) })
  elseif item.hint then
    UI.text(row, item.hint, "mono", "faint", { Position = UDim2.new(1, -10, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), TextSize = 11 })
  end
  UI.button(row, {
    hover = function(on) Motion.to(row, "BackgroundTransparency", on and T.fill2A or 1, "quick") end,
    click = function()
      UI.sfx("click", 0.6)
      close()
      if item.run then B.try("keys.menu", item.run) end
    end,
  })
  return row
end
-- pick a feature for `key`: every toggle and button the hub has, searchable
function Keys.pick(anchor, key)
  local list = {}
  for id, entry in pairs(Controls.bindables) do
    local bind = Config.bindOf(id)
    if not (bind and bind.key == key) then
      list[#list + 1] = { id = id, label = entry.label, page = entry.page and entry.page.title or "", key = bind and bind.key or nil }
    end
  end
  table.sort(list, function(a, b) return a.label < b.label end)
  return UI.popover(anchor, { width = 276, align = "center", pad = 8, gap = 6 }, function(content, close)
    UI.text(content, "Give " .. keyName(key) .. " a feature", "eyebrow", "faint", { LayoutOrder = 1, TextSize = 9 })
    local _, box = Controls.field(content, { Width = 260, PlaceholderText = "Search " .. #list .. " features" }, function() end)
    box.Parent.LayoutOrder = 2
    local holder = UI.frame(content, { Name = "List", Size = UDim2.new(1, 0, 0, 238), LayoutOrder = 3, ClipsDescendants = true })
    local scroller = UI.scroll(holder, { Size = UDim2.fromScale(1, 1), Name = "Scroll" })
    local rows = UI.frame(scroller, { Name = "Rows", Size = UDim2.new(1, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y })
    UI.list(rows, "y", 2)
    local made = {}
    for index, feature in ipairs(list) do
      local row = menuRow(rows, index, { name = feature.id, label = feature.label, hint = feature.key and Config.keyLabel(feature.key) or feature.page, run = function()
        Config.bind(feature.id, key)
        Window.toast({ title = feature.label .. " is on " .. keyName(key), text = "Right-click the key to clear it.", icon = "keyboard" })
      end }, close)
      made[index] = { row = row, text = string.lower(feature.label .. " " .. feature.page) }
    end
    if #list == 0 then
      UI.text(rows, "Nothing left to bind: open the other tabs once so their switches are known.", "caption", "sub", { TextWrapped = true, Size = UDim2.new(1, -8, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y })
    end
    box:GetPropertyChangedSignal("Text"):Connect(function()
      local query = string.lower(box.Text)
      for _, item in ipairs(made) do item.row.Visible = query == "" or string.find(item.text, query, 1, true) ~= nil end
    end)
  end)
end
-- what clicking a key opens: what is on it, and what can be done about that
function Keys.menu(anchor, key)
  local features, roles = Keys.on(key), Keys.builtin[key]
  return UI.popover(anchor, { width = 252, align = "center" }, function(content, close)
    local order = 0
    local function add(item) order += 1; return menuRow(content, order, item, close) end
    local head = UI.frame(content, { Name = "Head", Size = UDim2.new(1, 0, 0, 30), LayoutOrder = 0 })
    UI.text(head, keyName(key), "heading", "ink", { Position = UDim2.new(0, 10, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5) })
    UI.text(head, #features == 0 and (roles and roles[1].short or "Free") or (#features .. (#features == 1 and " feature" or " features")), "mono", "faint",
      { Position = UDim2.new(1, -10, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), TextSize = 11 })
    for _, f in ipairs(features) do
      if f.kind == "toggle" then
        add({ name = "Hold_" .. f.id, label = f.label .. ": only while held", icon = "hand", checked = f.mode == "hold", run = function()
          Config.bind(f.id, key, f.mode == "hold" and "toggle" or "hold")
        end })
      end
      add({ name = "Unbind_" .. f.id, label = "Take " .. f.label .. " off this key", icon = "x", danger = true, run = function() Config.bind(f.id, nil) end })
    end
    for _, role in ipairs(roles or {}) do
      if role.flag then
        add({ name = "Move_" .. role.flag, label = "Move " .. string.lower(role.short) .. " to another key…", icon = "keyboard", run = function()
          Window.toast({ title = "Press a key", text = "Esc cancels · Backspace clears", icon = "keyboard", time = 2.2 })
          Controls.captureKey(function(next, cancelled)
            if not cancelled then Config.set(role.flag, next or "None") end
          end)
        end })
      end
    end
    add({ name = "Bind", label = "Bind a feature to this key…", icon = "plus", run = function() task.defer(Keys.pick, anchor, key) end })
  end)
end
function Keys.clear(key)
  local cleared = 0
  for _, f in ipairs(Keys.on(key)) do
    Config.bind(f.id, nil)
    cleared += 1
  end
  if cleared > 0 then Window.toast({ title = keyName(key) .. " is free again", text = cleared .. (cleared == 1 and " feature taken off it." or " features taken off it."), icon = "keyboard" }) end
  return cleared
end

-- ---------------------------------------------------------------- the board
local function tint(instance, property, token) Theme.bind(instance, property, token) end
local function fixed(instance, property, value)
  Theme.unbind(instance, property)
  instance[property] = value
end
local function paint(entry)
  local key = entry.key
  local features, roles = Keys.on(key), Keys.builtin[key]
  local on = false
  for _, f in ipairs(features) do on = on or f.on end
  local clash = #features > 1 or (#features > 0 and roles ~= nil)
  entry.features, entry.roles, entry.clash, entry.lit = features, roles, clash, on
  local cap, label, what, stroke = entry.cap, entry.label, entry.what, entry.stroke
  if #features > 0 then
    -- bound: the feature's name on the key, solid while it is on
    tint(cap, "BackgroundColor3", "accent")
    fixed(cap, "BackgroundTransparency", on and 0 or 0.8)
    tint(label, "TextColor3", on and "accentInk" or "ink")
    tint(what, "TextColor3", on and "accentInk" or "ink")
    what.Text = features[1].label .. (#features > 1 and ("  +" .. #features - 1) or "")
    tint(stroke, "Color", clash and "warn" or "accent")
    fixed(stroke, "Transparency", clash and 0 or 0.35)
  elseif roles then
    -- the hub's own, or flight's
    tint(cap, "BackgroundColor3", "ink")
    tint(cap, "BackgroundTransparency", "fill2A")
    tint(label, "TextColor3", "ink")
    tint(what, "TextColor3", "faint")
    what.Text = roles[1].short
    tint(stroke, "Color", "ink")
    tint(stroke, "Transparency", "stroke2A")
  else
    tint(cap, "BackgroundColor3", "ink")
    tint(cap, "BackgroundTransparency", "fill1A")
    tint(label, "TextColor3", "sub")
    what.Text = ""
    tint(stroke, "Color", "ink")
    tint(stroke, "Transparency", "strokeA")
  end
  local named = what.Text ~= ""
  what.Visible = named
  label.Position = named and UDim2.new(0.5, 0, 0, 13) or UDim2.fromScale(0.5, 0.5)
end
local repaintQueued = false
function Keys.repaint()
  if repaintQueued then return end
  repaintQueued = true
  task.defer(function()
    repaintQueued = false
    readBuiltins()
    for _, entry in pairs(Keys.caps) do
      if entry.cap.Parent then paint(entry) end
    end
    if Keys.renderList then Keys.renderList() end
    if Keys.renderHud then Keys.renderHud() end
  end)
end
local function board(frame)
  local holder = UI.frame(frame, { Name = "Board", Size = UDim2.fromOffset(Keys.width, Keys.height), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 6) })
  local legend = UI.text(frame, "", "caption", "sub", { Name = "Legend", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, Keys.height + 18), Size = UDim2.fromOffset(Keys.width, 16),
    AutomaticSize = Enum.AutomaticSize.None, TextXAlignment = Enum.TextXAlignment.Center, TextTruncate = Enum.TextTruncate.AtEnd })
  local RESTING = "Click a key to give it a feature.  Right-click a key to clear it.  Bound keys light up while their feature is on."
  legend.Text = RESTING
  Keys.legend = legend
  readBuiltins()
  for rowIndex, row in ipairs(ROWS) do
    local x = 0
    local y = (rowIndex - 1) * (HEIGHT + GAP)
    for _, item in ipairs(row) do
      local width = item.width * (UNIT + GAP) - GAP
      if item.key then
        local key = item.key
        -- anchored at its centre, so the press shrinks it in place
        local cap = UI.pressable(holder, { Name = "Cap_" .. key, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x + width / 2, y + HEIGHT / 2),
          Size = UDim2.fromOffset(width, HEIGHT) })
        UI.corner(cap, "rSmall")
        local entry = { key = key, cap = cap, scale = UI.scaleOf(cap) }
        entry.stroke = UI.stroke(cap, "ink", "strokeA")
        entry.label = UI.text(cap, capLabel(key), "mono", "sub", { Name = "Label", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), TextSize = 11 })
        entry.what = UI.text(cap, "", "caption", "ink", { Name = "What", AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -5), Size = UDim2.new(1, -6, 0, 11),
          AutomaticSize = Enum.AutomaticSize.None, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Center, TextTruncate = Enum.TextTruncate.AtEnd, Visible = false })
        Keys.caps[key] = entry
        paint(entry)
        UI.wire(cap, {
          hover = function(over)
            legend.Text = over and Keys.describe(key) or RESTING
            Theme.bind(legend, "TextColor3", over and (entry.clash and "warn" or "ink") or "sub")
            if not entry.held then Motion.to(entry.scale, "Scale", over and 1.05 or 1, "snappy") end
          end,
          click = function() UI.sfx("click", 0.6); Keys.menu(cap, key) end,
          alt = function() Keys.clear(key) end,
        })
      end
      x += item.width * (UNIT + GAP)
    end
  end
  -- a key pressed for real dips on the board: it is the quickest way to find out which one is which
  B.connect(UIS.InputBegan, function(input)
    local entry = Keys.caps[Config.keyName(input) or ""]
    if entry and entry.cap.Parent and Window.showing("keys") then
      entry.held = true
      Motion.to(entry.scale, "Scale", 0.9, "quick")
    end
  end, "keys.press")
  B.connect(UIS.InputEnded, function(input)
    local entry = Keys.caps[Config.keyName(input) or ""]
    if entry and entry.held then
      entry.held = false
      if entry.cap.Parent then Motion.to(entry.scale, "Scale", 1, "bouncy") end
    end
  end, "keys.release")
  Theme.changed:connect(function() if holder.Parent then Keys.repaint() end end)
end

-- ---------------------------------------------------------------- the list beside it
local function list(frame)
  local holder = UI.frame(frame, { Name = "Bound", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y })
  UI.list(holder, "y", 0)
  UI.pad(holder, 2, 0, 6, 0)
  function Keys.renderList()
    if not holder.Parent then return end
    for _, child in ipairs(holder:GetChildren()) do
      if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
    end
    local binds = Keys.all()
    if #binds == 0 then
      local empty = UI.frame(holder, { Name = "Empty", Size = UDim2.new(1, 0, 0, 74) })
      UI.icon(empty, "keyboard", 20, "faint", { Position = UDim2.fromOffset(14, 14) })
      UI.text(empty, "Nothing is bound yet", "label", "ink", { Position = UDim2.fromOffset(44, 12) })
      UI.text(empty, "Click a key on the board, or right-click any switch in the hub and press the key you want for it.", "caption", "sub", { Position = UDim2.fromOffset(44, 32),
        Size = UDim2.new(1, -58, 0, 30), AutomaticSize = Enum.AutomaticSize.None, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, LineHeight = 1.15 })
      return
    end
    for index, bind in ipairs(binds) do
      local row = UI.frame(holder, { Name = "Bind_" .. bind.id, Size = UDim2.new(1, 0, 0, 40), LayoutOrder = index })
      if index > 1 then
        UI.frame(row, { Name = "Rule", Size = UDim2.new(1, -28, 0, 1), Position = UDim2.fromOffset(14, 0), Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "strokeA" } })
      end
      local chip = UI.frame(row, { Name = "Chip", Position = UDim2.new(0, 14, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.fromOffset(58, 24),
        Theme = { BackgroundColor3 = "accent" }, BackgroundTransparency = bind.on and 0 or 0.8 })
      UI.corner(chip, 7)
      UI.text(chip, Config.keyLabel(bind.key), "monoBold", bind.on and "accentInk" or "ink", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), TextSize = 11 })
      UI.text(row, bind.label, "label", "ink", { Name = "Feature", Position = UDim2.new(0, 84, 0.5, bind.page and -8 or 0), AnchorPoint = Vector2.new(0, 0.5), TextSize = 13,
        Size = UDim2.new(1, -220, 0, 18), AutomaticSize = Enum.AutomaticSize.None, TextTruncate = Enum.TextTruncate.AtEnd })
      if bind.page then
        UI.text(row, bind.page, "caption", "faint", { Position = UDim2.new(0, 84, 0.5, 9), AnchorPoint = Vector2.new(0, 0.5), TextSize = 11 })
      end
      -- how the key works it: press to flip, hold to keep on, or simply run
      local mode = UI.pressable(row, { Name = "Mode", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -48, 0.5, 0), Size = UDim2.fromOffset(74, 24),
        Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill2A" } })
      UI.corner(mode, 7)
      UI.text(mode, bind.kind == "toggle" and (bind.mode == "hold" and "While held" or "Toggle") or "Runs it", "caption", bind.kind == "toggle" and "ink" or "faint",
        { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), TextSize = 11 })
      if bind.kind == "toggle" then
        UI.wire(mode, { click = function() UI.sfx("click", 0.5); Config.bind(bind.id, bind.key, bind.mode == "hold" and "toggle" or "hold") end })
      end
      local remove = UI.pressable(row, { Name = "Unbind", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(24, 24) })
      UI.corner(remove, 7)
      local cross = UI.icon(remove, "x", 14, "faint", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
      UI.wire(remove, {
        hover = function(over) Theme.bind(cross, "ImageColor3", over and "bad" or "faint") end,
        click = function() UI.sfx("click", 0.5); Config.bind(bind.id, nil) end,
      })
    end
  end
  Keys.renderList()
end

-- ---------------------------------------------------------------- a list on screen that lights smoothly
-- Rows are kept from one draw to the next: a feature switched on fades its row in (and its key
-- chip pops), switched off it fades back. Only a change of what is bound redraws the rows.
local TS = S.TweenService
local LIGHT = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
Keys.LIGHT = LIGHT
-- what the rows show, as one string: equal means only the lights may have changed
function Keys.shape(binds, moving, most)
  local parts = { moving and "m" or "-", tostring(#binds) }
  for index, bind in ipairs(binds) do
    if index > most then break end
    parts[#parts + 1] = bind.id .. "|" .. tostring(bind.key) .. "|" .. tostring(bind.mode) .. "|" .. tostring(bind.label)
  end
  return table.concat(parts, ";")
end
function Keys.basedPanel(holder)
  local glass = UI.glass(holder, { level = "popover", radius = 14, shadow = 20, shadowY = 8, grain = false, props = { Size = UDim2.fromOffset(0, 0), AutomaticSize = Enum.AutomaticSize.XY } })
  local body = UI.frame(glass, { Name = "Body", Size = UDim2.fromOffset(0, 0), AutomaticSize = Enum.AutomaticSize.XY })
  UI.pad(body, 9, 10, 10, 10)
  UI.list(body, "y", 3)
  local api = { frame = glass, rows = {}, shape = nil }
  local function light(row, on, animate)
    row.on = on
    local goal = { chip = on and 0 or 0.8, wash = on and 0.88 or 1, key = on and T.accentInk or T.ink, name = on and T.ink or T.sub }
    if animate and not Motion.reduced then
      TS:Create(row.chip, LIGHT, { BackgroundTransparency = goal.chip }):Play()
      TS:Create(row.wash, LIGHT, { BackgroundTransparency = goal.wash }):Play()
      TS:Create(row.key, LIGHT, { TextColor3 = goal.key }):Play()
      TS:Create(row.name, LIGHT, { TextColor3 = goal.name }):Play()
      if on then
        row.pop.Scale = 1.22
        Motion.to(row.pop, "Scale", 1, "bouncy")
      end
    else
      row.chip.BackgroundTransparency, row.wash.BackgroundTransparency = goal.chip, goal.wash
      row.key.TextColor3, row.name.TextColor3 = goal.key, goal.name
    end
  end
  function api.forget() api.shape = nil end
  function api.render(binds, moving)
    local shape = Keys.shape(binds, moving, 9)
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
    for _, child in ipairs(body:GetChildren()) do
      if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
    end
    UI.text(body, moving and "KEYS  ·  DRAG ME, THEN LOCK" or "KEYS", "eyebrow", moving and "accent" or "faint", { TextSize = 9, LayoutOrder = 0 })
    if #binds == 0 then UI.text(body, "Nothing is bound yet", "caption", "sub", { TextSize = 12, LayoutOrder = 1 }) end
    for index, bind in ipairs(binds) do
      if index > 9 then
        UI.text(body, "+" .. (#binds - 9) .. " more", "caption", "faint", { TextSize = 11, LayoutOrder = index })
        break
      end
      local line = UI.frame(body, { Name = "Bind_" .. bind.id, Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = index })
      local wash = UI.frame(line, { Name = "Wash", Size = UDim2.new(1, 8, 1, 0), Position = UDim2.fromOffset(-4, 0), Theme = { BackgroundColor3 = "accent" }, BackgroundTransparency = 1 })
      UI.corner(wash, 6)
      local inner = UI.frame(line, { Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X })
      UI.list(inner, "x", 8, { v = "Center" })
      -- sized from its text: a chip that sizes itself left a single letter against its left edge
      local name = Config.keyLabel(bind.key)
      local chip = UI.frame(inner, { Name = "Chip", Size = UDim2.fromOffset(math.max(28, #name * 7 + 14), 18), LayoutOrder = 1, Theme = { BackgroundColor3 = "accent" },
        BackgroundTransparency = 0.8 })
      UI.corner(chip, 5)
      local pop = Instance.new("UIScale"); pop.Parent = chip
      local key = UI.text(chip, name, "monoBold", "ink", { TextSize = 10, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
      Theme.unbind(key, "TextColor3")
      local label = UI.text(inner, bind.label, "caption", "sub", { Name = "Feature", TextSize = 12, LayoutOrder = 2 })
      Theme.unbind(label, "TextColor3")
      local row = { chip = chip, wash = wash, key = key, name = label, pop = pop }
      api.rows[bind.id] = row
      local was = before[bind.id]
      light(row, was == nil and bind.on or was, false)
      if was ~= nil and was ~= bind.on then light(row, bind.on, true) end
    end
  end
  return api
end

-- ---------------------------------------------------------------- the list on screen
-- While the hub is hidden: each bound feature with its key, lit while it is on. It sits in the
-- bottom right corner until it is put somewhere else: unlocked (Keys tab), it shows with the hub
-- open too and goes where it is dragged; locked again, it stays there.
function Keys.hud()
  if Keys.panel or not Window.hud then return end
  local holder = UI.frame(Window.hud, { Name = "KeyList", AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -16, 1, -16), Size = UDim2.fromOffset(0, 0),
    AutomaticSize = Enum.AutomaticSize.XY, Visible = false })
  local function unlocked() return Config.get("app.keyHudLock") == false end
  local function seat()
    local x, y = Config.get("app.keyHudX"), Config.get("app.keyHudY")
    if type(x) == "number" and type(y) == "number" and x >= 0 and y >= 0 then
      holder.AnchorPoint = Vector2.new(0.5, 0.5)
      holder.Position = UDim2.fromScale(math.clamp(x, 0.02, 0.98), math.clamp(y, 0.02, 0.98))
    else
      holder.AnchorPoint = Vector2.new(1, 1)
      holder.Position = UDim2.new(1, -16, 1, -16)
    end
  end
  seat()
  local sizer = Instance.new("UIScale"); sizer.Scale = Window.scale or 1; sizer.Parent = holder
  -- three looks, each with its own list: the BASED glass card, the Unnamed box, Novoline's dark card.
  -- Never one with another look's window.
  local style, panel
  local function lookNow()
    if B.Novoline ~= nil and B.Novoline.keyPanel ~= nil and B.Novoline.active() then return "novoline" end
    if B.Unnamed ~= nil and B.Unnamed.keyPanel ~= nil and B.Unnamed.active() then return "unnamed" end
    return "based"
  end
  local function dress()
    if panel then panel.frame:Destroy(); panel = nil end
    style = lookNow()
    if style == "unnamed" then panel = B.Unnamed.keyPanel(holder)
    elseif style == "novoline" then panel = B.Novoline.keyPanel(holder)
    else panel = Keys.basedPanel(holder) end
  end
  dress()
  Keys.panel = holder
  -- the hand it is moved by: over all of it, and only there while it is unlocked
  local grip = UI.new("TextButton", { Name = "Move", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 20, Visible = false, Parent = holder })
  local from
  UI.drag(grip, function(point)
    local centre = holder.AbsolutePosition + holder.AbsoluteSize / 2
    from = centre - point
    return true
  end, function(point)
    local layer = Window.hud
    local size = layer.AbsoluteSize
    if size.X < 1 or size.Y < 1 then return end
    local at = point + from - layer.AbsolutePosition
    holder.AnchorPoint = Vector2.new(0.5, 0.5)
    holder.Position = UDim2.fromScale(math.clamp(at.X / size.X, 0.02, 0.98), math.clamp(at.Y / size.Y, 0.02, 0.98))
  end, function()
    -- (both read before either is kept: keeping one seats the list again, by the other's old value)
    local x, y = holder.Position.X.Scale, holder.Position.Y.Scale
    Config.set("app.keyHudX", x)
    Config.set("app.keyHudY", y)
  end)
  local function shouldShow()
    if Config.get("app.keyHud") == false then return false end
    if unlocked() then return true end
    return not Window.anyOpen() and next(Config.binds) ~= nil
  end
  function Keys.renderHud()
    if not holder.Parent then return end
    if lookNow() ~= style then dress() end
    sizer.Scale = (style == "unnamed" and B.Unnamed.scaleNow and B.Unnamed.scaleNow())
      or (style == "novoline" and B.Novoline.scaleNow and math.clamp(B.Novoline.scaleNow(), 0.7, 1.2)) or Window.scale or 1
    local binds = Keys.all()
    local moving = unlocked()
    grip.Visible = moving
    holder.Visible = shouldShow() and (#binds > 0 or moving)
    if holder.Visible then panel.render(binds, moving) end
  end
  Window.onShow:connect(function() Keys.renderHud() end)
  -- A bound button lights too: while what it started goes on (an emote playing), or for a moment
  -- after its key. Pressed: drawn at once; then looked at five times a second, drawn only on a change.
  local lit = ""
  local function litNow()
    local parts = {}
    for id, bind in pairs(Config.binds) do
      if bind.key and Config.isAction(id) and Config.isActive(id) then parts[#parts + 1] = id end
    end
    table.sort(parts)
    return table.concat(parts, ",")
  end
  Config.actionRan:connect(function() lit = litNow(); Keys.renderHud() end)
  Motion.every(function()
    if not holder.Visible then return end
    local now = litNow()
    if now ~= lit then lit = now; Keys.renderHud() end
  end, 5, "keys.lit")
  Config.on("app.keyHud", function() Keys.renderHud() end)
  Config.on("app.keyHudLock", function() Keys.renderHud() end)
  Config.on("app.gui", function() Keys.renderHud() end)
  Config.on("app.scale", function() Keys.renderHud() end)
  Theme.changed:connect(function() if panel and panel.forget then panel.forget() end; Keys.renderHud() end)
  Config.on("app.keyHudX", seat)
  Config.on("app.keyHudY", seat)
  Keys.renderHud()
end

-- ---------------------------------------------------------------- the tab
function Keys.define()
  Config.define("app.keyHud", true)
  Config.define("app.keyHudLock", true)
  Config.define("app.keyHudX", -1)          -- where it was put, as a share of the screen; under 0: the corner
  Config.define("app.keyHudY", -1)
end
B.pages[#B.pages + 1] = function()
  Keys.define()
  -- anything that changes what a key does, or whether a bound feature is on, redraws the board
  Config.bindsChanged:connect(function() Keys.repaint() end)
  Config.changed:connect(function(id)
    if Config.binds[id] or id == "app.key.menu" or id == "app.key.panic" or id == "fly.key.boost" or id == "fly.key.down" then Keys.repaint() end
  end)
  Config.loaded:connect(function() Keys.repaint() end)
  Window.page({ id = "keys", title = "Keys", icon = "keyboard", group = "Hub", order = 890, eyebrow = "What every key does", build = function(page)
    local map = page:section({ title = "Your keyboard", icon = "keyboard", full = true, desc = "Every key the hub listens to, and what it does." })
    map:custom({ height = Keys.height + 46, name = "Keyboard", build = board })

    local bound = page:section({ title = "Bound features", icon = "link", column = 1, weight = 6 })
    bound:custom({ name = "List", build = list })

    local own = page:section({ title = "The hub's own keys", icon = "command", column = 2, weight = 6 })
    own:keybind({ tip = "The key that opens and closes the hub.", id = "app.key.menu", label = "Open / close the hub" })
    own:keybind({ id = "app.key.panic", label = "Panic", desc = "Unloads BASED instantly." })
    own:keybind({ id = "fly.key.boost", label = "Flight: boost", tip = "Hold to fly faster.", default = "LeftShift" })
    own:keybind({ id = "fly.key.down", label = "Flight: come down", tip = "Hold to go down.", default = "LeftControl" })
    own:toggle({ id = "app.keyHud", label = "Show my keys on screen", desc = "A small list while the hub is hidden, lit for whatever is on.", bindable = false })
    own:toggle({ id = "app.keyHudLock", label = "Lock where it sits", desc = "Off: drag the list anywhere on screen. On: it stays.", bindable = false })
    own:button({ label = "Back to the corner", tip = "Moves the key list back to its corner.", text = "Reset", bindable = false, run = function()
      Config.set("app.keyHudX", -1)
      Config.set("app.keyHudY", -1)
    end })
    own:button({ label = "Clear every bound key", desc = "The hub's own keys are kept.", text = "Clear", style = "danger", bindable = false, run = function()
      local cleared = 0
      for id in pairs(table.clone(Config.binds)) do Config.bind(id, nil); cleared += 1 end
      Window.toast({ title = cleared == 0 and "Nothing was bound" or "Keys cleared", text = cleared > 0 and (cleared .. " features are off their keys.") or nil, icon = "keyboard" })
    end })
  end })
end
end

do -- 52_unnamed.lua
-- ============================================================================
--  52 unnamed    the second look: the old dark menu with its tabs along the top
--
--  The same tabs and the same settings as the BASED window, drawn the way the
--  classic two-column menus are: a square to tick, a bar that fills with its
--  value written on it, a box with a coloured line on top and its title in
--  small letters. Every control here is bound to the very flag its BASED twin
--  is, so the two windows always agree and either one can be used. One is shown
--  at a time: Settings > Menu style, or the button at the top of either window.
--
--  A tab's own drawing (a custom block) can give a version of itself for this
--  window (page:custom(height, build, alt)); one that does not is drawn as it
--  is, inside a box.
-- ============================================================================
local S, util, Motion, UI, Config, Window, Controls = B.S, B.util, B.Motion, B.UI, B.Config, B.Window, B.Controls
local UIS = S.UserInputService
local U = { open = false, built = false, pages = {}, tabs = {} }
B.Unnamed = U

local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end
-- the old menu's colours: near black, one grey for boxes, one for what can be clicked, and the accent
local C = {
  back = rgb(12, 12, 12), frame = rgb(18, 18, 18), box = rgb(21, 21, 21), edge = rgb(44, 44, 44), dark = rgb(4, 4, 4),
  field = rgb(31, 31, 31), fieldHi = rgb(40, 40, 40), text = rgb(226, 226, 226), dim = rgb(152, 152, 152), faint = rgb(96, 96, 96),
  tab = rgb(16, 16, 16), tabOn = rgb(27, 27, 27),
}
U.C = C
local ACCENT = rgb(32, 98, 255)
local W, H = 566, 640                  -- design pixels; scaled with the screen
local FONT, BOLD

-- ---------------------------------------------------------------- the letters
-- Settings > Unnamed letters. Monocraft first: the Minecraft letters the old menu was drawn in.
-- `size` is how big each set is drawn against the 13 px the menu was laid out in, so each reads at
-- about the same height (measured in game: the height of "Hg" at 13 px against Arial's).
local FONTS = {
  { "monocraft", "Monocraft", function() return B.F.craft end, 1 },
  { "proggy", "Proggy Clean", function() return B.F.proggy end, 1.25 },
  { "proggytiny", "Proggy Tiny", function() return B.F.proggyTiny end, 1.35 },
  { "arial", "Arial", function() return Font.fromEnum(Enum.Font.Arial) end, 1 },
  { "roboto", "Roboto Mono", function() return Font.fromName("RobotoMono") end, 0.95 },
  { "builder", "Builder Sans", function() return Font.fromName("BuilderSans") end, 1 },
  { "gotham", "Gotham", function() return Font.fromName("GothamSSm") end, 0.95 },
  { "ubuntu", "Ubuntu", function() return Font.fromName("Ubuntu") end, 1 },
  { "inter", "Inter", function() return (B.F0 or B.F).text500 end, 0.97 },
  { "geist", "Geist Mono", function() return (B.F0 or B.F).mono400 end, 0.95 },
  { "arcade", "Arcade", function() return Font.fromEnum(Enum.Font.Arcade) end, 0.75 },
  { "michroma", "Michroma", function() return Font.fromName("Michroma") end, 0.85 },
  { "jura", "Jura", function() return Font.fromName("Jura") end, 1.05 },
  { "sarpanch", "Sarpanch", function() return Font.fromName("Sarpanch") end, 1.05 },
  { "titillium", "Titillium", function() return Font.fromName("TitilliumWeb") end, 1.02 },
}
U.FONTS = FONTS
-- Every label and box drawn here, with its size at 100%. Kept STRONG and swept: a weak-keyed table
-- of Instances loses entries while they are still on screen (their Lua handle is collected and a new
-- one made later), and those labels never took a newly picked font. That was the "fonts don't
-- change fully" bug: whatever had been collected kept the old letters.
local typed = {}
local bolded = {}
local factor = 1
U.fontChanged = B.Signal.new()
local function fontSpec(id)
  for _, spec in ipairs(FONTS) do if spec[1] == id then return spec end end
  return FONTS[1]
end
local function sizeOf(base) return math.max(6, math.floor(base * factor + 0.5)) end
local function pickFont()
  local spec = fontSpec(Config.get("app.unnamed.font"))
  local ok, face = pcall(spec[3])
  FONT = (ok and typeof(face) == "Font") and face or Font.fromEnum(Enum.Font.Arial)
  local okBold, bold = pcall(Font.new, FONT.Family, Enum.FontWeight.Bold, FONT.Style)
  BOLD = okBold and bold or FONT
  factor = spec[4] * ((Config.get("app.unnamed.textSize") or 100) / 100)
end
-- a label or a box takes the menu's letters, and keeps them when they change
local function letters(item, base, bold)
  if not FONT then pickFont() end
  typed[item] = base
  if bold then bolded[item] = true end
  item.FontFace = bold and BOLD or FONT
  item.TextSize = sizeOf(base)
  return item
end
local function refont()
  pickFont()
  for item, base in pairs(typed) do
    if item.Parent then
      item.FontFace = bolded[item] and BOLD or FONT
      item.TextSize = sizeOf(base)
    else
      typed[item], bolded[item] = nil, nil
    end
  end
  U.fontChanged:fire()
end
-- (gone ones swept now and then, so a menu rebuilt many times does not keep them all)
local function sweepTyped()
  for item in pairs(typed) do
    if not item.Parent then typed[item], bolded[item] = nil, nil end
  end
end
U.sweepTyped = sweepTyped
function U.font() if not FONT then pickFont() end return FONT, BOLD end
-- (drawn in this look's letters: the BASED font setting leaves it alone)
function U.owns(item) return typed[item] ~= nil end

-- ---------------------------------------------------------------- the accent, kept on everything that wears it
local accented = {}
local function accent() return Config.get("app.unnamed.accent") or ACCENT end
local function wear(instance, property)
  accented[#accented + 1] = { instance, property }
  instance[property] = accent()
  return instance
end
local function repaint()
  local color = accent()
  for index = #accented, 1, -1 do
    local entry = accented[index]
    if entry[1].Parent then entry[1][entry[2]] = color else table.remove(accented, index) end
  end
end

-- ---------------------------------------------------------------- pieces
local function box(parent, props)
  local frame = Instance.new("Frame")
  frame.BorderSizePixel = 0
  frame.BackgroundColor3 = C.box
  if props then
    for key, value in pairs(props) do frame[key] = value end
  end
  frame.Parent = parent
  return frame
end
-- a 1 px line round it, the way these menus draw every box
local function lined(frame, color)
  frame.BorderSizePixel = 1
  frame.BorderMode = Enum.BorderMode.Inset
  frame.BorderColor3 = color or C.edge
  return frame
end
local function text(parent, value, props, bold)
  local label = Instance.new("TextLabel")
  label.BackgroundTransparency = 1
  label.BorderSizePixel = 0
  label.TextSize = 13
  label.TextColor3 = C.text
  label.TextXAlignment = Enum.TextXAlignment.Left
  label.Text = value or ""
  if props then
    for key, v in pairs(props) do label[key] = v end
  end
  letters(label, label.TextSize, bold)
  label.Parent = parent
  return label
end
-- a box to type in, in the menu's letters
local function entryBox(parent, size)
  local entry = Instance.new("TextBox")
  entry.BackgroundTransparency, entry.BorderSizePixel = 1, 0
  entry.TextColor3, entry.PlaceholderColor3 = C.text, C.faint
  entry.TextXAlignment, entry.ClearTextOnFocus, entry.ClipsDescendants = Enum.TextXAlignment.Left, false, true
  letters(entry, size or 12)
  entry.Parent = parent
  return entry
end
local function hit(parent, props)
  local button = Instance.new("TextButton")
  button.Text = ""
  button.BackgroundTransparency = 1
  button.BorderSizePixel = 0
  button.AutoButtonColor = false
  button.Size = UDim2.fromScale(1, 1)
  button.ZIndex = 8
  if props then
    for key, value in pairs(props) do button[key] = value end
  end
  button.Parent = parent
  return button
end
local function lower(value) return string.lower(tostring(value or "")) end
local function list(parent, gap, horizontal)
  local layout = Instance.new("UIListLayout")
  layout.FillDirection = horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
  layout.Padding = UDim.new(0, gap or 0)
  layout.SortOrder = Enum.SortOrder.LayoutOrder
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
local function options(spec)
  local out = {}
  for _, option in ipairs(spec or {}) do
    if type(option) == "table" then out[#out + 1] = { value = option.value or option[1], label = option.label or option[2] or tostring(option.value or option[1]) }
    else out[#out + 1] = { value = option, label = tostring(option) } end
  end
  return out
end

-- ---------------------------------------------------------------- the floating bits: a tip, a list, a colour
-- (all inside the window, so they scale with it; placed from where the thing they belong to is)
local function within(gui)
  local scale = U.sizer and U.sizer.Scale or 1
  return (gui.AbsolutePosition - U.holder.AbsolutePosition) / scale, gui.AbsoluteSize / scale
end
local tip, tipFor
local function hideTip()
  tipFor = nil
  if tip then tip.Visible = false end
end
-- the window's size in design pixels (it can be dragged bigger)
local function frameSize()
  local scale = U.sizer and U.sizer.Scale or 1
  return U.holder and U.holder.AbsoluteSize / scale or Vector2.new(W, H)
end
-- `label`, when given: a name that may be cut short on its row; cut, the tip says it whole
local function tooltip(button, desc, label)
  if (not desc or desc == "") and not label then return end
  button.MouseEnter:Connect(function()
    tipFor = button
    task.delay(0.45, function()
      if tipFor ~= button or not (U.open and button.Parent) then return end
      local value = desc or ""
      if label and label.Parent and not label.TextFits then value = label.Text .. (value ~= "" and ("  -  " .. value) or "") end
      if value == "" then return end
      local at, size = within(button)
      tip.Text = value
      tip.Position = UDim2.fromOffset(at.X + 10, at.Y + size.Y + 4)
      tip.Visible = true
      -- (kept inside the window: moved left of a right edge, above a bottom one, once it has its size)
      task.defer(function()
        if tipFor ~= button or not tip.Visible then return end
        local scale = U.sizer and U.sizer.Scale or 1
        local tipSize, room = tip.AbsoluteSize / scale, frameSize()
        local x, y = at.X + 10, at.Y + size.Y + 4
        if x + tipSize.X > room.X - 4 then x = math.max(4, room.X - 4 - tipSize.X) end
        if y + tipSize.Y > room.Y - 4 then y = math.max(4, at.Y - tipSize.Y - 4) end
        tip.Position = UDim2.fromOffset(x, y)
      end)
    end)
  end)
  button.MouseLeave:Connect(function() if tipFor == button then hideTip() end end)
end
local popup                           -- the open list or colour picker: { frame, anchor, close }
local function closePopup()
  if popup then
    local open = popup
    popup = nil
    open.frame:Destroy()
    if open.locked and open.locked.Parent then open.locked.ScrollingEnabled = true end
    if open.closed then open.closed() end
  end
end
-- The page an open list or colour sits on stays where it is until it closes: the wheel over the
-- list scrolls the list alone. (Before, the wheel went through to the page, the page moved, and
-- moving closed the list.) A click anywhere else closes it and the page scrolls again.
local function lockPage(anchor)
  for _, entry in pairs(U.pages) do
    local scroller = entry.scroller
    if scroller and anchor and anchor:IsDescendantOf(scroller) then
      scroller.ScrollingEnabled = false
      return scroller
    end
  end
  return nil
end
U.closePopup = closePopup
-- a list under `anchor`: items = { { label, checked } }, pick(index) -> keep open?
local function openList(anchor, items, pick, multi)
  closePopup()
  local at, size = within(anchor)
  local rows = math.min(#items, 12)
  local tall = rows * 17 + 4
  -- (under it, or over it when the window ends first)
  local y = at.Y + size.Y + 1
  if y + tall > frameSize().Y - 2 and at.Y - tall - 1 >= 2 then y = at.Y - tall - 1 end
  local frame = lined(box(U.holder, { Name = "List", Position = UDim2.fromOffset(at.X, y), Size = UDim2.fromOffset(size.X, tall),
    BackgroundColor3 = C.field, ZIndex = 60 }), C.dark)
  local scroller = Instance.new("ScrollingFrame")
  scroller.BackgroundTransparency, scroller.BorderSizePixel = 1, 0
  scroller.Size, scroller.Position = UDim2.new(1, -2, 1, -4), UDim2.fromOffset(1, 2)
  scroller.CanvasSize = UDim2.fromOffset(0, #items * 17)
  scroller.ScrollBarThickness = #items > rows and 3 or 0
  scroller.ScrollingDirection = Enum.ScrollingDirection.Y
  scroller.ZIndex = 61
  wear(scroller, "ScrollBarImageColor3")
  scroller.Parent = frame
  local labels = {}
  for index, item in ipairs(items) do
    local row = box(scroller, { Position = UDim2.fromOffset(0, (index - 1) * 17), Size = UDim2.new(1, 0, 0, 17), BackgroundColor3 = C.fieldHi, BackgroundTransparency = 1, ZIndex = 62 })
    local label = text(row, item[1], { Position = UDim2.fromOffset(6, 0), Size = UDim2.new(1, -10, 1, 0), TextSize = 12, ZIndex = 63, TextTruncate = Enum.TextTruncate.AtEnd })
    labels[index] = label
    if item[2] then wear(label, "TextColor3") end
    local button = hit(row, { ZIndex = 64 })
    button.MouseEnter:Connect(function() row.BackgroundTransparency = 0 end)
    button.MouseLeave:Connect(function() row.BackgroundTransparency = 1 end)
    button.Activated:Connect(B.safe("unnamed.list", function()
      local checked = pick(index)
      if multi then
        item[2] = checked
        if checked then wear(label, "TextColor3") else label.TextColor3 = C.text end
      else
        closePopup()
      end
    end))
  end
  popup = { frame = frame, anchor = anchor, locked = lockPage(anchor) }
  return frame
end
-- a colour: a square of saturation and value, a strip of hue
local function openColor(anchor, initial, set)
  closePopup()
  local at, size = within(anchor)
  local h, s, v = initial:ToHSV()
  local y = at.Y + size.Y + 2
  if y + 166 > frameSize().Y - 2 and at.Y - 168 >= 2 then y = at.Y - 168 end
  local frame = lined(box(U.holder, { Name = "Colour", Position = UDim2.fromOffset(math.max(at.X + size.X - 150, 4), y), Size = UDim2.fromOffset(150, 166),
    BackgroundColor3 = C.field, ZIndex = 60 }), C.dark)
  local square = box(frame, { Position = UDim2.fromOffset(6, 6), Size = UDim2.fromOffset(138, 128), BackgroundColor3 = Color3.fromHSV(h, 1, 1), ZIndex = 61 })
  local white = box(square, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 62 })
  local fade = Instance.new("UIGradient"); fade.Transparency = NumberSequence.new(0, 1); fade.Parent = white
  local black = box(square, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), ZIndex = 63 })
  local down = Instance.new("UIGradient"); down.Rotation = 90; down.Transparency = NumberSequence.new(1, 0); down.Parent = black
  local dot = lined(box(square, { Size = UDim2.fromOffset(5, 5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 65 }), C.dark)
  local hue = box(frame, { Position = UDim2.fromOffset(6, 140), Size = UDim2.fromOffset(138, 10), BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 61 })
  local stops = {}
  for i = 0, 6 do stops[#stops + 1] = ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6 % 1, 1, 1)) end
  local rainbow = Instance.new("UIGradient"); rainbow.Color = ColorSequence.new(stops); rainbow.Parent = hue
  local mark = lined(box(hue, { Size = UDim2.fromOffset(3, 12), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 63 }), C.dark)
  local function show()
    square.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
    dot.Position = UDim2.fromScale(s, 1 - v)
    mark.Position = UDim2.fromScale(h, 0.5)
  end
  show()
  local function emit() show(); set(Color3.fromHSV(h, s, v)) end
  local squareHit = hit(square, { ZIndex = 66 })
  UI.drag(squareHit, function(point)
    s = util.clamp01((point.X - square.AbsolutePosition.X) / square.AbsoluteSize.X); v = 1 - util.clamp01((point.Y - square.AbsolutePosition.Y) / square.AbsoluteSize.Y); emit()
  end, function(point)
    s = util.clamp01((point.X - square.AbsolutePosition.X) / square.AbsoluteSize.X); v = 1 - util.clamp01((point.Y - square.AbsolutePosition.Y) / square.AbsoluteSize.Y); emit()
  end)
  local hueHit = hit(hue, { ZIndex = 66, Size = UDim2.new(1, 0, 1, 8), Position = UDim2.fromOffset(0, -4) })
  UI.drag(hueHit, function(point) h = util.clamp01((point.X - hue.AbsolutePosition.X) / hue.AbsoluteSize.X); emit() end,
    function(point) h = util.clamp01((point.X - hue.AbsolutePosition.X) / hue.AbsoluteSize.X); emit() end)
  popup = { frame = frame, anchor = anchor, locked = lockPage(anchor) }
end

-- ---------------------------------------------------------------- a key for a flag (right click on a control)
local function bindKey(id, label, chip, refresh)
  if not id then return end
  chip.Visible, chip.Text = true, "..."
  Controls.captureKey(function(key, cancelled)
    if not cancelled then
      Config.bind(id, key)
      Window.toast({ title = key and ("Bound to " .. Config.keyLabel(key)) or "Key cleared", text = label, icon = "keyboard", time = 2 })
    end
    refresh()
  end)
end
-- right click: a short list under the row (bind / hold to use / clear / back to default)
local function keyMenu(id, label, kind, line, chip, refresh)
  if not id then return end
  local bind = Config.bindOf(id)
  local items, runs = {}, {}
  local function add(value, run, checked) items[#items + 1] = { value, checked == true }; runs[#items] = run end
  add(bind and bind.key and ("change key (" .. lower(Config.keyLabel(bind.key)) .. ")") or "bind a key", function() bindKey(id, label, chip, refresh) end)
  if bind and bind.key then
    if kind == "toggle" then add("hold to use", function() Config.bind(id, bind.key, bind.mode == "hold" and "toggle" or "hold") end, bind.mode == "hold") end
    add("clear the key", function() Config.bind(id, nil) end)
  end
  if kind ~= "button" and Config.get(id) ~= nil then add("back to default", function() Config.reset(id) end) end
  openList(line, items, function(index)
    local run = runs[index]
    if run then task.defer(run) end
    return false
  end, false)
end
local function keyChip(row)
  return lined(text(row, "", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(34, 14), TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Center, BackgroundColor3 = C.field, BackgroundTransparency = 0, Visible = false, ZIndex = 4 }), C.dark)
end

-- ---------------------------------------------------------------- a section and its controls
local Section = {}
Section.__index = Section
local function row(section, height)
  section.count += 1
  return box(section.body, { Name = "Row", Size = UDim2.new(1, 0, 0, height), BackgroundTransparency = 1, LayoutOrder = section.count })
end
local function sub(section, holder)
  return setmetatable({ body = holder, count = 0, page = section.page, card = section.card }, Section)
end
-- a row the search box can find, by its name and what it says it does
local function findable(section, frame, label, desc)
  local page = section.page
  if not (page and page.rows) then return end
  page.rows[#page.rows + 1] = { frame = frame, card = section.card, text = lower(tostring(label or "") .. " " .. tostring(desc or "")) }
end

function Section:toggle(spec)
  local id = spec.id
  local bindable = spec.bindable ~= false
  local value = id and Config.define(id, spec.default == true) or (spec.default == true)
  local line = row(self, 16)
  findable(self, line, spec.label, spec.desc)
  local square = lined(box(line, { Size = UDim2.fromOffset(10, 10), Position = UDim2.new(0, 1, 0.5, -5), BackgroundColor3 = C.field }), C.dark)
  local fill = wear(box(square, { Size = UDim2.fromScale(1, 1), ZIndex = 2 }), "BackgroundColor3")
  local label = text(line, lower(spec.label), { Position = UDim2.fromOffset(17, 0), Size = UDim2.new(1, -56, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd })
  local chip = keyChip(line)
  local children
  local function paint()
    fill.Visible = value
    label.TextColor3 = value and C.text or C.dim
    if children then children.Visible = value end
  end
  local function showKey()
    local bind = id and Config.bindOf(id)
    chip.Visible = bind ~= nil and bind.key ~= nil
    if chip.Visible then chip.Text = Config.keyLabel(bind.key) .. (bind.mode == "hold" and "*" or "") end
    -- (the name has the whole row when there is no key on it)
    label.Size = UDim2.new(1, chip.Visible and -56 or -18, 1, 0)
  end
  if spec.children then
    self.count += 1
    children = box(self.body, { Name = "Sub", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = self.count })
    pad(children, 0, 0, 0, 14)
    list(children, 5)
    B.try("unnamed.children", spec.children, sub(self, children))
  end
  paint()
  showKey()
  if id then
    Config.on(id, function(next)
      value = next == true
      if line.Parent then paint() end
      if spec.changed then spec.changed(value) end
    end)
    Config.bindsChanged:connect(function(changed) if changed == id and chip.Parent then showKey() end end)
    if bindable then Controls.bindables[id] = Controls.bindables[id] or { label = spec.label or id, kind = "toggle", page = self.page.source } end
  end
  local button = hit(line)
  button.MouseEnter:Connect(function() label.TextColor3 = C.text end)
  button.MouseLeave:Connect(function() paint() end)
  button.Activated:Connect(B.safe("unnamed.toggle", function()
    if id then Config.set(id, not value) else
      value = not value
      paint()
      if spec.changed then B.try("toggle", spec.changed, value) end
    end
  end))
  button.MouseButton2Click:Connect(function() if bindable then keyMenu(id, spec.label, "toggle", line, chip, showKey) end end)
  tooltip(button, (spec.tip or spec.desc) and ((spec.tip or spec.desc) .. (bindable and id and "  (right click: its key)" or "")) or nil, label)
  return { row = { frame = line, label = label }, id = id, get = function() return value end, set = function(next) if id then Config.set(id, next == true) end end, open = function() end }
end

function Section:slider(spec)
  local id = spec.id
  local min, max, step = spec.min or 0, spec.max or 100, spec.step or 1
  local decimals = spec.decimals or (step < 1 and math.max(0, math.ceil(-math.log10(step))) or 0)
  local curve = spec.curve or 1
  local value = id and Config.define(id, spec.default or min) or (spec.default or min)
  local line = row(self, 16)
  findable(self, line, spec.label, spec.desc)
  local bar = lined(box(line, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.field }), C.dark)
  local fill = wear(box(bar, { Size = UDim2.fromScale(0, 1), ZIndex = 2 }), "BackgroundColor3")
  -- (its name on the left, cut short if it must be; its value on the right, always whole)
  local label = text(bar, lower(spec.label), { Position = UDim2.fromOffset(5, 0), Size = UDim2.new(0.66, -7, 1, 0), TextSize = 12, TextStrokeTransparency = 0.5,
    ZIndex = 4, TextTruncate = Enum.TextTruncate.AtEnd })
  local amount = text(bar, "", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -5, 0, 0), Size = UDim2.new(0.34, -3, 1, 0), TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Right, TextStrokeTransparency = 0.5, ZIndex = 4, TextTruncate = Enum.TextTruncate.AtEnd })
  local function shown(v) return (spec.format and spec.format(v)) or (util.format(v, decimals) .. (spec.suffix or "")) end
  local function place()
    fill.Size = UDim2.fromScale(util.clamp01((value - min) / math.max(max - min, 1e-9)) ^ (1 / curve), 1)
    amount.Text = shown(value)
  end
  place()
  local function set(next)
    next = math.clamp(util.round(next, step), min, max)
    if decimals > 0 then next = tonumber(string.format("%." .. decimals .. "f", next)) or next end
    if next == value then return end
    if id then Config.set(id, next) else
      value = next
      place()
      if spec.changed then B.try("slider", spec.changed, value) end
    end
  end
  if id then
    Config.on(id, function(next)
      value = next
      if bar.Parent then place() end
      if spec.changed then spec.changed(next) end
    end)
  end
  local button = hit(bar)
  local function at(point) set(min + util.clamp01((point.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1)) ^ curve * (max - min)) end
  UI.drag(button, function(point) at(point) end, function(point) at(point) end)
  -- (right click: type a number, for the far end of a long range)
  button.MouseButton2Click:Connect(function()
    local field = entryBox(bar, 12)
    field.BackgroundTransparency, field.BackgroundColor3 = 0, C.fieldHi
    field.Size, field.Position, field.ZIndex = UDim2.fromScale(1, 1), UDim2.new(), 9
    field.TextXAlignment = Enum.TextXAlignment.Center
    field.Text, field.ClearTextOnFocus, field.PlaceholderText = "", true, lower(spec.label) .. "..."
    field.FocusLost:Connect(B.safe("unnamed.slider.type", function()
      local typed = tonumber((string.gsub(field.Text, "[^%d%.%-eE]", "")))
      field:Destroy()
      if typed then set(typed) end
    end))
    field:CaptureFocus()
  end)
  button.MouseEnter:Connect(function() bar.BackgroundColor3 = C.fieldHi end)
  button.MouseLeave:Connect(function() bar.BackgroundColor3 = C.field end)
  tooltip(button, ((spec.tip or spec.desc) and ((spec.tip or spec.desc) .. "  ") or "") .. "(right click: type a number)", label)
  return { row = { frame = line, label = label }, id = id, get = function() return value end, set = set }
end

-- a box that opens a list: one value (dropdown, segmented) or several (multi)
local function chooser(section, spec, many)
  local id = spec.id
  local choices = options(spec.options)
  local first = choices[1] and choices[1].value
  local value
  if many then value = id and Config.define(id, spec.default or {}) or (spec.default or {})
  else value = id and Config.define(id, spec.default ~= nil and spec.default or first) or (spec.default ~= nil and spec.default or first) end
  local line = row(section, 34)
  findable(section, line, spec.label, spec.desc)
  text(line, lower(spec.label), { Size = UDim2.new(1, 0, 0, 14), TextColor3 = C.dim, TextSize = 12 })
  local field = lined(box(line, { Position = UDim2.fromOffset(0, 16), Size = UDim2.new(1, 0, 0, 18), BackgroundColor3 = C.field }), C.dark)
  local label = text(field, "", { Position = UDim2.fromOffset(6, 0), Size = UDim2.new(1, -22, 1, 0), TextSize = 12, TextTruncate = Enum.TextTruncate.AtEnd })
  local arrow = text(field, "v", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -5, 0, 0), Size = UDim2.new(0, 10, 1, 0), TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = C.dim })
  local function has(v) return table.find(value, v) ~= nil end
  local function summary()
    if not many then
      for _, option in ipairs(choices) do if option.value == value then return option.label end end
      return tostring(value)
    end
    if #value == 0 then return spec.empty or "--" end
    local names = {}
    for _, option in ipairs(choices) do if has(option.value) then names[#names + 1] = option.label end end
    return table.concat(names, ", ")
  end
  label.Text = summary()
  local function set(next)
    if id then Config.set(id, next) else
      value = next
      label.Text = summary()
      if spec.changed then B.try("chooser", spec.changed, value) end
    end
  end
  if id then
    Config.on(id, function(next)
      value = next
      if label.Parent then label.Text = summary() end
      if spec.changed then spec.changed(next) end
    end)
  end
  local button = hit(field)
  button.MouseEnter:Connect(function() field.BackgroundColor3 = C.fieldHi end)
  button.MouseLeave:Connect(function() field.BackgroundColor3 = C.field end)
  button.Activated:Connect(B.safe("unnamed.choose", function()
    if popup and popup.anchor == field then closePopup(); return end
    local items = {}
    for index, option in ipairs(choices) do items[index] = { option.label, many and has(option.value) or option.value == value } end
    openList(field, items, function(index)
      local option = choices[index]
      if not many then set(option.value); return false end
      local next = table.clone(value)
      local at = table.find(next, option.value)
      if at then table.remove(next, at) else next[#next + 1] = option.value end
      local ordered = {}
      for _, o in ipairs(choices) do if table.find(next, o.value) then ordered[#ordered + 1] = o.value end end
      set(ordered)
      return at == nil
    end, many)
    arrow.Text = "^"
    popup.closed = function() if arrow.Parent then arrow.Text = "v" end end
  end))
  tooltip(button, spec.tip or spec.desc)
  return { row = { frame = line, label = label }, id = id, get = function() return value end, set = set, has = has,
    options = function(next) choices = options(next); label.Text = summary() end,
    -- (what it shows, put from outside without a change of its own: an id-less one kept in step)
    show = function(next) value = next; if label.Parent then label.Text = summary() end end }
end
function Section:dropdown(spec) return chooser(self, spec, false) end
function Section:segmented(spec) return chooser(self, spec, false) end
function Section:multi(spec) return chooser(self, spec, true) end

function Section:color(spec)
  local id = spec.id
  local value = id and Config.define(id, spec.default or Color3.new(1, 1, 1)) or (spec.default or Color3.new(1, 1, 1))
  local line = row(self, 16)
  findable(self, line, spec.label, spec.desc)
  text(line, lower(spec.label), { Size = UDim2.new(1, -40, 1, 0), TextColor3 = C.text })
  local swatch = lined(box(line, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(26, 11), BackgroundColor3 = value }), C.dark)
  local function set(next) if id then Config.set(id, next) else value = next; swatch.BackgroundColor3 = next; if spec.changed then spec.changed(next) end end end
  if id then
    Config.on(id, function(next)
      value = next
      if swatch.Parent then swatch.BackgroundColor3 = next end
      if spec.changed then spec.changed(next) end
    end)
  end
  local button = hit(swatch)
  button.Activated:Connect(B.safe("unnamed.color", function()
    if popup and popup.anchor == swatch then closePopup(); return end
    openColor(swatch, value, set)
  end))
  tooltip(button, spec.tip or spec.desc)
  return { row = { frame = line }, id = id, get = function() return value end, set = set }
end

function Section:keybind(spec)
  local id = spec.id
  local value = id and Config.define(id, spec.default or "None") or (spec.default or "None")
  local line = row(self, 16)
  findable(self, line, spec.label, spec.desc)
  text(line, lower(spec.label), { Size = UDim2.new(1, -60, 1, 0) })
  local chip = keyChip(line)
  chip.Size = UDim2.fromOffset(52, 14)
  local function show() chip.Visible, chip.Text = true, Config.keyLabel(value ~= "None" and value or nil) end
  show()
  if id then
    Config.on(id, function(next)
      value = next
      if chip.Parent then show() end
      if spec.changed then spec.changed(next) end
    end)
  end
  local button = hit(chip)
  button.Activated:Connect(B.safe("unnamed.key", function()
    chip.Text = "..."
    Controls.captureKey(function(key, cancelled)
      if not cancelled then
        local next = key or "None"
        if id then Config.set(id, next) else value = next; if spec.changed then spec.changed(next) end end
      end
      show()
    end)
  end))
  tooltip(button, spec.tip or spec.desc)
  return { row = { frame = line }, id = id, get = function() return value end }
end

function Section:button(spec)
  local id = spec.id
  local line = row(self, 18)
  findable(self, line, spec.label or spec.text, spec.desc)
  local field = lined(box(line, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.field }), C.dark)
  local label = text(field, lower(spec.label or spec.text), { Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, TextSize = 12 })
  local chip = keyChip(field)
  chip.Position = UDim2.new(1, -2, 0.5, 0)
  local function showKey()
    local bind = id and Config.bindOf(id)
    chip.Visible = bind ~= nil and bind.key ~= nil
    if chip.Visible then chip.Text = Config.keyLabel(bind.key) end
  end
  showKey()
  if id then
    Config.action(id, function() if spec.run then spec.run() end end)
    Config.bindsChanged:connect(function(changed) if changed == id and chip.Parent then showKey() end end)
    if spec.bindable ~= false then Controls.bindables[id] = Controls.bindables[id] or { label = spec.label or id, kind = "button", page = self.page.source } end
  end
  local button = hit(field)
  button.MouseEnter:Connect(function() field.BackgroundColor3 = C.fieldHi end)
  button.MouseLeave:Connect(function() field.BackgroundColor3 = C.field end)
  button.Activated:Connect(B.safe("unnamed.button", function()
    wear(field, "BorderColor3")
    task.delay(0.12, function() if field.Parent then field.BorderColor3 = C.dark end end)
    if spec.run then B.try("button." .. (spec.label or "?"), spec.run) end
  end))
  button.MouseButton2Click:Connect(function() if id and spec.bindable ~= false then keyMenu(id, spec.label, "button", line, chip, showKey) end end)
  tooltip(button, spec.tip or spec.desc)
  return { row = { frame = line, label = label }, button = field, setText = function(value) label.Text = lower(value) end }
end

function Section:input(spec)
  local id = spec.id
  local value = id and Config.define(id, spec.default or "") or (spec.default or "")
  local line = row(self, 34)
  findable(self, line, spec.label, spec.desc)
  text(line, lower(spec.label), { Size = UDim2.new(1, 0, 0, 14), TextColor3 = C.dim, TextSize = 12 })
  local field = lined(box(line, { Position = UDim2.fromOffset(0, 16), Size = UDim2.new(1, 0, 0, 18), BackgroundColor3 = C.field }), C.dark)
  local entry = entryBox(field, 12)
  entry.Position, entry.Size = UDim2.fromOffset(6, 0), UDim2.new(1, -12, 1, 0)
  entry.Text, entry.PlaceholderText = tostring(value), lower(spec.placeholder or "")
  entry.FocusLost:Connect(B.safe("unnamed.input", function()
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
  self.count += 1
  local label = text(self.body, spec.text or "", { Name = "Note", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true, TextSize = 12,
    TextColor3 = C.dim, LayoutOrder = self.count, RichText = spec.rich == true })
  return { frame = label, set = function(value) label.Text = value end }
end
function Section:custom(spec)
  self.count += 1
  local frame = box(self.body, { Name = spec.name or "Custom", Size = UDim2.new(1, 0, 0, spec.height or 100), BackgroundTransparency = 1, LayoutOrder = self.count })
  if spec.height == nil then frame.AutomaticSize = Enum.AutomaticSize.Y end
  B.try("unnamed.custom", spec.build, frame)
  return frame
end
-- for a tab's own version of itself: a line of text, two buttons side by side, a box to type in
function Section:label(value)
  local note = self:note({ text = value })
  note.frame.TextColor3 = C.text
  return note
end
function Section:pair(a, b)
  local line = row(self, 18)
  local out = {}
  for index, item in ipairs({ a, b }) do
    if item then
      local field = lined(box(line, { Position = UDim2.new((index - 1) * 0.5, index == 2 and 3 or 0, 0, 0), Size = UDim2.new(b and 0.5 or 1, b and -3 or 0, 1, 0),
        BackgroundColor3 = C.field }), C.dark)
      local label = text(field, lower(item[1]), { Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, TextSize = 12 })
      local button = hit(field)
      button.MouseEnter:Connect(function() field.BackgroundColor3 = C.fieldHi end)
      button.MouseLeave:Connect(function() field.BackgroundColor3 = C.field end)
      button.Activated:Connect(B.safe("unnamed.pair", function() if item[2] then item[2]() end end))
      out[index] = { field = field, label = label }
    end
  end
  return out
end
function Section:field(placeholder, changed)
  local line = row(self, 18)
  local field = lined(box(line, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.field }), C.dark)
  local entry = entryBox(field, 12)
  entry.Position, entry.Size = UDim2.fromOffset(6, 0), UDim2.new(1, -12, 1, 0)
  entry.Text, entry.PlaceholderText = "", placeholder or ""
  if changed then entry:GetPropertyChangedSignal("Text"):Connect(function() changed(entry.Text) end) end
  return entry
end
U.Section = Section

-- ---------------------------------------------------------------- a tab
local Page = {}
Page.__index = Page
local function band(page, full)
  page.bands += 1
  local frame = box(page.content, { Name = full and "Full" or "Columns", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
    LayoutOrder = page.bands })
  if full then
    list(frame, 8)
    return { full = true, frame = frame }
  end
  local columns = {}
  for index = 1, 2 do
    local column = box(frame, { Name = "Column" .. index, Size = UDim2.new(0.5, -4, 0, 0), Position = UDim2.new(index == 1 and 0 or 0.5, index == 1 and 0 or 4, 0, 0),
      AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 })
    list(column, 8)
    columns[index] = { frame = column, count = 0 }
  end
  return { full = false, frame = frame, columns = columns }
end
local function host(page, spec)
  local current = page.band
  if spec.full then
    current = band(page, true)
    page.band = nil
  elseif not current or current.full then
    current = band(page, false)
    page.band = current
  end
  if current.full then return current.frame end
  local column = spec.column and current.columns[spec.column]
    or (current.columns[1].count <= current.columns[2].count and current.columns[1] or current.columns[2])
  column.count += spec.weight or 1
  return column.frame
end
-- a box with its title on the line along its top
local function group(page, spec)
  page.sections += 1
  local frame = lined(box(host(page, spec), { Name = spec.title or "Box", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = page.sections }))
  wear(box(frame, { Name = "Line", Size = UDim2.new(1, 0, 0, 2), ZIndex = 2 }), "BackgroundColor3")
  local top = spec.title and 22 or 8
  if spec.title then
    text(frame, lower(spec.title), { Position = UDim2.fromOffset(0, 4), Size = UDim2.new(1, 0, 0, 16), TextXAlignment = Enum.TextXAlignment.Center })
  end
  local body = box(frame, { Name = "Body", Position = UDim2.fromOffset(0, top), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 })
  pad(body, 0, 8, 8, 8)
  list(body, 5)
  if page.cards then page.cards[#page.cards + 1] = { frame = frame, title = lower(spec.title) } end
  return setmetatable({ body = body, count = 0, page = page, card = frame }, Section)
end
function Page:section(spec) return group(self, spec or {}) end
function Page:custom(height, build, alt)
  if alt then
    local section = group(self, { full = true })
    B.try("unnamed.alt", alt, section)
    return section.body
  end
  self.band = nil
  local section = group(self, { full = true })
  local frame = box(section.body, { Name = "Custom", Size = UDim2.new(1, 0, 0, height or 0), BackgroundTransparency = 1 })
  if not height then frame.AutomaticSize = Enum.AutomaticSize.Y end
  B.try("unnamed.custom", build, frame)
  return frame
end
function Page:empty(_, title, value)
  local section = group(self, { full = true, title = title or "nothing here yet" })
  section:note({ text = value or "" })
end

-- ---------------------------------------------------------------- the window
local function tabsWanted()
  local out = {}
  for _, page in ipairs(Window.order) do
    if not page.hidden and page.id ~= "home" and page.build then out[#out + 1] = page end
  end
  return out
end
local query = ""                      -- what the search box holds, lower case
-- Show only the rows of a tab that match the search (and the boxes they are in). Rows hidden for
-- reasons of their own are left as they are: only what the search hid is shown again.
local function filter(entry)
  if not (entry and entry.rows) then return false end
  local any, cards = false, {}
  for _, item in ipairs(entry.rows) do
    if item.frame.Parent then
      local found = query == "" or string.find(item.text, query, 1, true) ~= nil
      if found then
        if item.hidden then item.frame.Visible = true; item.hidden = nil end
        if item.card then cards[item.card] = true end
        any = true
      elseif item.frame.Visible then
        item.frame.Visible, item.hidden = false, true
      end
    end
  end
  for _, card in ipairs(entry.cards or {}) do
    local named = card.title ~= "" and string.find(card.title, query, 1, true) ~= nil
    local shown = query == "" or cards[card.frame] == true or named
    if shown and card.hidden then card.frame.Visible = true; card.hidden = nil
    elseif not shown and card.frame.Visible then card.frame.Visible, card.hidden = false, true end
    -- (a box found by its own title shows all it holds)
    if query ~= "" and named and not cards[card.frame] then
      for _, item in ipairs(entry.rows) do
        if item.card == card.frame and item.hidden then item.frame.Visible = true; item.hidden = nil end
      end
      any = true
    end
  end
  return any
end
local function buildPage(source)
  local entry = U.pages[source.id]
  if entry and entry.built then return entry end
  if not entry then
    local scroller = Instance.new("ScrollingFrame")
    scroller.Name = source.id
    scroller.BackgroundTransparency, scroller.BorderSizePixel = 1, 0
    scroller.Position, scroller.Size = UDim2.fromOffset(6, 6), UDim2.new(1, -12, 1, -12)
    scroller.CanvasSize = UDim2.new()
    scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroller.ScrollingDirection = Enum.ScrollingDirection.Y
    scroller.ScrollBarThickness = 3
    scroller.Visible = false
    wear(scroller, "ScrollBarImageColor3")
    scroller.Parent = U.body
    -- (an open list or tip belongs where it was opened: scrolled away, it goes)
    scroller:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
      if popup and popup.anchor and popup.anchor:IsDescendantOf(scroller) then closePopup() end
      hideTip()
    end)
    local content = box(scroller, { Name = "Content", Size = UDim2.new(1, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 })
    list(content, 8)
    entry = setmetatable({ source = source, scroller = scroller, content = content, bands = 0, sections = 0, rows = {}, cards = {} }, Page)
    U.pages[source.id] = entry
  end
  entry.built = true
  B.try("unnamed.page." .. source.id, source.build, entry)
  if entry.sections == 0 then entry:empty(nil, "nothing here yet", "This tab is ready for its controls.") end
  if B.Keys and B.Keys.repaint then B.Keys.repaint() end
  return entry
end
local function unwear(instance)
  for index = #accented, 1, -1 do if accented[index][1] == instance then table.remove(accented, index) end end
end
local found = nil                      -- tab id -> true, for the tabs the search finds something on
local function paintTabs()
  for _, tab in ipairs(U.tabs) do
    local on = tab.id == U.current
    tab.button.BackgroundColor3 = on and C.tabOn or C.tab
    tab.line.Visible = on
    if found and found[tab.id] and not on then wear(tab.label, "TextColor3")
    else
      unwear(tab.label)
      tab.label.TextColor3 = on and C.text or (found and C.faint or C.dim)
    end
  end
end
function U.go(id)
  local source = Window.pages[id]
  if not (source and U.built) then return end
  closePopup()
  hideTip()
  local entry = buildPage(source)
  for _, other in pairs(U.pages) do other.scroller.Visible = other == entry end
  U.current = id
  filter(entry)
  paintTabs()
end
-- the search: this tab first; if nothing here, the first tab that has it
function U.search(value)
  query = lower(value or "")
  query = string.gsub(query, "^%s+", "")
  query = string.gsub(query, "%s+$", "")
  if not U.built then return end
  found = nil
  if query ~= "" then
    found = {}
    for _, source in ipairs(tabsWanted()) do
      if filter(buildPage(source)) then found[source.id] = true end
    end
    if U.current and not found[U.current] then
      for _, source in ipairs(tabsWanted()) do
        if found[source.id] then U.go(source.id); return end
      end
    end
  else
    for _, entry in pairs(U.pages) do filter(entry) end
  end
  if U.current then U.go(U.current) end
end
function U.rebuildTabs()
  if not U.built then return end
  for _, tab in ipairs(U.tabs) do tab.button:Destroy() end
  table.clear(U.tabs)
  local wanted = tabsWanted()
  local count = math.max(#wanted, 1)
  -- (each as wide as its name wants, of the whole bar: "movement" next to "cash")
  local width = 0
  for _, page in ipairs(wanted) do width += #page.title + 2 end
  for index, page in ipairs(wanted) do
    local share = (#page.title + 2) / math.max(width, 1)
    local button = lined(box(U.tabBar, { Name = page.id, Size = UDim2.new(share, index == count and 0 or -2, 1, 0), BackgroundColor3 = C.tab, LayoutOrder = index }), C.dark)
    local label = text(button, lower(page.title), { Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, TextSize = 11, TextColor3 = C.dim,
      TextTruncate = Enum.TextTruncate.AtEnd })
    local line = wear(box(button, { Size = UDim2.new(1, 0, 0, 1), Visible = false, ZIndex = 2 }), "BackgroundColor3")
    local click = hit(button)
    click.MouseEnter:Connect(function() if U.current ~= page.id then button.BackgroundColor3 = C.tabOn end end)
    click.MouseLeave:Connect(function() if U.current ~= page.id then button.BackgroundColor3 = C.tab end end)
    click.Activated:Connect(B.safe("unnamed.tab", function() UI.sfx("tab", 0.4); U.go(page.id) end))
    U.tabs[#U.tabs + 1] = { id = page.id, button = button, label = label, line = line }
  end
  if not (U.current and Window.pages[U.current]) and wanted[1] then U.current = (Window.startPage and Window.pages[Window.startPage] and Window.startPage) or wanted[1].id end
end
local function scaleNow()
  local camera = workspace.CurrentCamera
  local tall = camera and camera.ViewportSize.Y or 900
  return math.clamp(tall / 1000, 0.75, 1.6) * ((Config.get("app.scale") or 100) / 100)
end
U.scaleNow = scaleNow
local MIN_W, MIN_H, MAX_W, MAX_H = 470, 360, 1100, 960
local function sizeWanted()
  local w, h = Config.get("app.unnamed.w"), Config.get("app.unnamed.h")
  return math.clamp(type(w) == "number" and w or W, MIN_W, MAX_W), math.clamp(type(h) == "number" and h or H, MIN_H, MAX_H)
end
local function crownOn(frame)
  local crown = wear(box(frame, { Name = "Crown", Size = UDim2.new(1, 0, 0, 2), ZIndex = 5 }), "BackgroundColor3")
  local shade = Instance.new("UIGradient")
  shade.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 0.15), NumberSequenceKeypoint.new(1, 0.55) })
  shade.Parent = crown
  return crown
end
function U.build()
  if U.built then return end
  U.built = true
  pickFont()
  local gui = B.screen(9050)
  gui:SetAttribute("OwnLetters", true)
  U.gui = gui
  U.modal = Instance.new("TextButton")
  U.modal.Text, U.modal.BackgroundTransparency, U.modal.Size, U.modal.Modal, U.modal.Visible = "", 1, UDim2.fromOffset(0, 0), true, false
  U.modal.Parent = gui
  local width, height = sizeWanted()
  local holder = lined(box(gui, { Name = "Unnamed", Size = UDim2.fromOffset(width, height), AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(Config.get("app.unnamed.x") or 0.5, Config.get("app.unnamed.y") or 0.5), BackgroundColor3 = C.back, Visible = false }), C.dark)
  U.holder = holder
  U.sizer = Instance.new("UIScale")
  U.sizer.Scale = scaleNow()
  U.sizer.Parent = holder
  -- the thin coloured rim round it all, and the bright line along its top
  wear(box(holder, { Name = "Rim", Size = UDim2.new(1, 2, 1, 2), Position = UDim2.fromOffset(-1, -1), BackgroundTransparency = 1, BorderSizePixel = 1, ZIndex = 0 }), "BorderColor3")
  crownOn(holder)
  -- the top: its name, the game, a search box, and the way back to the other look; held to drag it
  local top = box(holder, { Name = "Top", Position = UDim2.fromOffset(0, 2), Size = UDim2.new(1, 0, 0, 20), BackgroundColor3 = C.back })
  wear(text(top, "based", { Position = UDim2.fromOffset(8, 0), Size = UDim2.new(0, 50, 1, 0) }, true), "TextColor3")
  local status = B.Registry and B.Registry.status and B.Registry.status() or {}
  text(top, lower(status.name or "universal"), { Position = UDim2.fromOffset(54, 0), Size = UDim2.new(1, -330, 1, 0), TextColor3 = C.faint, TextSize = 12,
    TextTruncate = Enum.TextTruncate.AtEnd })
  local swap = lined(box(top, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -5, 0.5, 0), Size = UDim2.fromOffset(84, 14), BackgroundColor3 = C.field }), C.dark)
  text(swap, "based look", { Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, TextSize = 11, TextColor3 = C.dim })
  local swapHit = hit(swap, { ZIndex = 9 })
  swapHit.MouseEnter:Connect(function() swap.BackgroundColor3 = C.fieldHi end)
  swapHit.MouseLeave:Connect(function() swap.BackgroundColor3 = C.field end)
  swapHit.Activated:Connect(B.safe("unnamed.swap", function() Config.set("app.gui", "based") end))
  tooltip(swapHit, "Back to the BASED window. Settings has this too.")
  local seek = lined(box(top, { Name = "Search", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -95, 0.5, 0), Size = UDim2.fromOffset(150, 14),
    BackgroundColor3 = C.field }), C.dark)
  local seekBox = entryBox(seek, 11)
  seekBox.Position, seekBox.Size, seekBox.ZIndex = UDim2.fromOffset(5, 0), UDim2.new(1, -10, 1, 0), 9
  seekBox.PlaceholderText, seekBox.Text = "search...", ""
  U.seekBox = seekBox
  local seekToken = 0
  seekBox:GetPropertyChangedSignal("Text"):Connect(function()
    seekToken += 1
    local mine = seekToken
    task.delay(0.12, function() if mine == seekToken then B.try("unnamed.search", U.search, seekBox.Text) end end)
  end)
  seekBox.Focused:Connect(function() wear(seek, "BorderColor3") end)
  seekBox.FocusLost:Connect(function() unwear(seek); seek.BorderColor3 = C.dark end)
  U.tabBar = box(holder, { Name = "Tabs", Position = UDim2.fromOffset(6, 24), Size = UDim2.new(1, -12, 0, 20), BackgroundTransparency = 1 })
  list(U.tabBar, 2, true)
  U.body = lined(box(holder, { Name = "Body", Position = UDim2.fromOffset(6, 46), Size = UDim2.new(1, -12, 1, -52), BackgroundColor3 = C.frame, ClipsDescendants = true }))
  -- the tip: as wide as it needs, never wider than 260, wrapped past that
  tip = lined(text(holder, "", { Name = "Tip", Size = UDim2.fromOffset(0, 0), AutomaticSize = Enum.AutomaticSize.XY, TextSize = 12, BackgroundColor3 = C.field,
    BackgroundTransparency = 0, Visible = false, ZIndex = 80, TextWrapped = true }), C.dark)
  local tipMost = Instance.new("UISizeConstraint")
  tipMost.MaxSize = Vector2.new(260, math.huge)
  tipMost.Parent = tip
  pad(tip, 3, 6, 3, 6)
  -- dragging by the top
  local grab = hit(top, { ZIndex = 2 })
  local from, start
  UI.drag(grab, function(point)
    from, start = point, holder.AbsolutePosition + holder.AbsoluteSize / 2
  end, function(point)
    local camera = workspace.CurrentCamera
    local size = camera and camera.ViewportSize or Vector2.new(1920, 1080)
    local centre = start + (point - from)
    local inset = UI.inset()
    local x, y = util.clamp01(centre.X / size.X), util.clamp01((centre.Y + inset.Y) / size.Y)
    holder.Position = UDim2.fromScale(x, y)
  end, function()
    Config.set("app.unnamed.x", holder.Position.X.Scale)
    Config.set("app.unnamed.y", holder.Position.Y.Scale)
  end)
  -- the corner it is made bigger or smaller by (the top left stays where it is)
  local corner = box(holder, { Name = "Resize", AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -1, 1, -1), Size = UDim2.fromOffset(10, 10),
    BackgroundTransparency = 1, ZIndex = 20 })
  for index = 1, 3 do
    wear(box(corner, { AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, 0, 1, -(index - 1) * 3), Size = UDim2.fromOffset(index * 3, 1), ZIndex = 21,
      BackgroundTransparency = 0.25 }), "BackgroundColor3")
  end
  local cornerHit = hit(corner, { ZIndex = 22, Size = UDim2.new(1, 6, 1, 6), Position = UDim2.fromOffset(-3, -3) })
  local fromPoint, fromSize, fromCorner
  UI.drag(cornerHit, function(point)
    local scale = U.sizer.Scale
    fromPoint, fromSize = point, holder.AbsoluteSize / scale
    fromCorner = holder.AbsolutePosition
    closePopup()
    hideTip()
  end, function(point)
    local scale = U.sizer.Scale
    local camera = workspace.CurrentCamera
    local view = camera and camera.ViewportSize or Vector2.new(1920, 1080)
    local wanted = fromSize + (point - fromPoint) / scale
    local w = math.clamp(wanted.X, MIN_W, math.max(MIN_W, math.min(MAX_W, view.X / scale)))
    local h = math.clamp(wanted.Y, MIN_H, math.max(MIN_H, math.min(MAX_H, view.Y / scale)))
    holder.Size = UDim2.fromOffset(w, h)
    -- (held by its centre: keep the top left corner where it was)
    local inset = UI.inset()
    local centre = fromCorner + Vector2.new(w, h) * scale / 2
    holder.Position = UDim2.fromScale(util.clamp01(centre.X / view.X), util.clamp01((centre.Y + inset.Y) / view.Y))
  end, function()
    Config.set("app.unnamed.w", math.floor(holder.Size.X.Offset + 0.5))
    Config.set("app.unnamed.h", math.floor(holder.Size.Y.Offset + 0.5))
    Config.set("app.unnamed.x", holder.Position.X.Scale)
    Config.set("app.unnamed.y", holder.Position.Y.Scale)
  end)
  tooltip(cornerHit, "Drag to resize.")
  -- a click anywhere outside an open list closes it
  B.connect(UIS.InputBegan, function(input)
    if not popup then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local point = UI.point(input)
    if not (UI.inside(popup.frame, point) or (popup.anchor and popup.anchor.Parent and UI.inside(popup.anchor, point))) then closePopup() end
  end, "unnamed.outside")
  Config.on("app.unnamed.accent", repaint)
  Config.on("app.scale", function() if U.sizer then U.sizer.Scale = scaleNow() end end)
  local camera = workspace.CurrentCamera
  if camera then B.connect(camera:GetPropertyChangedSignal("ViewportSize"), function() if U.sizer then U.sizer.Scale = scaleNow() end end, "unnamed.viewport") end
  U.rebuildTabs()
end
function U.show(on)
  if on and not U.built then U.build() end
  if not U.built or U.open == on then return end
  U.open = on
  closePopup()
  hideTip()
  U.holder.Visible = on
  U.modal.Visible = on and Config.get("app.freeCursor") ~= false
  if on then
    U.rebuildTabs()
    if U.current then U.go(U.current) end
    -- (all of it on the screen: one put half off it, or kept from a bigger screen, comes back in)
    task.defer(function()
      if not (U.open and U.holder) then return end
      local camera = workspace.CurrentCamera
      local view = camera and camera.ViewportSize or Vector2.new(1920, 1080)
      local size = U.holder.AbsoluteSize
      local inset = UI.inset()
      local centre = U.holder.AbsolutePosition + size / 2 + Vector2.new(0, inset.Y)
      local x = math.clamp(centre.X, size.X / 2 + 4, math.max(size.X / 2 + 4, view.X - size.X / 2 - 4))
      local y = math.clamp(centre.Y, size.Y / 2 + 4, math.max(size.Y / 2 + 4, view.Y - size.Y / 2 - 4))
      if math.abs(x - centre.X) > 1 or math.abs(y - centre.Y) > 1 then
        U.holder.Position = UDim2.fromScale(x / view.X, y / view.Y)
      end
    end)
    -- (a small rise into place: quick, so it never gets in the way)
    if not Motion.reduced then
      local target = scaleNow()
      U.sizer.Scale = target * 0.965
      Motion.to(U.sizer, "Scale", target, "snappy")
    end
    UI.sfx("open", 0.35)
  else
    if U.seekBox and U.seekBox:IsFocused() then U.seekBox:ReleaseFocus() end
    UI.sfx("close", 0.3)
  end
  if Window.onShow then Window.onShow:fire(Window.anyOpen()) end
end
function U.toggle() U.show(not U.open) end
-- the one that is in use: this, or the BASED window
function U.active() return Config.get("app.gui") == "unnamed" end
function U.toggleActive() Window.toggleActive() end

-- ---------------------------------------------------------------- the key list, drawn this way
-- What Keys puts on screen while the hub is hidden, in this menu's look: a dark box, the line on
-- top, "keybinds" in small letters, and a row a key: [key] name, lit while it is on.
function U.keyPanel(parent)
  local panel = lined(box(parent, { Name = "KeysUnnamed", Size = UDim2.fromOffset(0, 0), AutomaticSize = Enum.AutomaticSize.XY, BackgroundColor3 = C.back }), C.dark)
  local least = Instance.new("UISizeConstraint")
  least.MinSize = Vector2.new(170, 0)
  least.Parent = panel
  crownOn(panel)
  local title = text(panel, "keybinds", { Name = "Title", Position = UDim2.fromOffset(0, 3), Size = UDim2.new(1, 0, 0, 16), TextXAlignment = Enum.TextXAlignment.Center,
    TextColor3 = C.dim, TextSize = 12 })
  local body = box(panel, { Name = "Body", Position = UDim2.fromOffset(0, 20), Size = UDim2.fromOffset(0, 0), AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1 })
  pad(body, 0, 8, 6, 8)
  list(body, 1)
  local api = { frame = panel, rows = {}, shape = nil }
  local TS = S.TweenService
  local INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
  -- (lit: the key in the accent and the name bright; the light fades in and out)
  local function light(row, on, animate)
    row.on = on
    unwear(row.key)
    local goal = { key = on and accent() or C.faint, name = on and C.text or C.dim, wash = on and 0.82 or 1 }
    if animate and not Motion.reduced then
      TS:Create(row.key, INFO, { TextColor3 = goal.key }):Play()
      TS:Create(row.name, INFO, { TextColor3 = goal.name }):Play()
      TS:Create(row.wash, INFO, { BackgroundTransparency = goal.wash }):Play()
      task.delay(0.32, function() if row.on and row.key.Parent then wear(row.key, "TextColor3") end end)
    else
      row.key.TextColor3, row.name.TextColor3, row.wash.BackgroundTransparency = goal.key, goal.name, goal.wash
      if on then wear(row.key, "TextColor3") end
    end
    if row.state then row.state.Text = row.hold and "(hold)" or (on and "(on)" or "(off)") end
  end
  function api.forget() api.shape = nil end
  function api.render(binds, moving)
    local shape = B.Keys.shape(binds, moving, 12)
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
    for _, child in ipairs(body:GetChildren()) do
      if child:IsA("GuiObject") then child:Destroy() end
    end
    title.Text = moving and "keybinds  (drag, then lock)" or "keybinds"
    if moving then wear(title, "TextColor3") else unwear(title); title.TextColor3 = C.dim end
    if #binds == 0 then
      text(body, "nothing bound yet", { Size = UDim2.fromOffset(0, 15), AutomaticSize = Enum.AutomaticSize.X, TextColor3 = C.faint, TextSize = 12, LayoutOrder = 1 })
      return
    end
    for index, bind in ipairs(binds) do
      if index > 12 then
        text(body, "+" .. (#binds - 12) .. " more", { Size = UDim2.fromOffset(0, 15), AutomaticSize = Enum.AutomaticSize.X, TextColor3 = C.faint, TextSize = 12, LayoutOrder = index })
        break
      end
      local line = box(body, { Name = "Bind_" .. bind.id, Size = UDim2.fromOffset(0, 15), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, LayoutOrder = index })
      local wash = box(line, { Name = "Wash", Size = UDim2.new(1, 6, 1, 0), Position = UDim2.fromOffset(-3, 0), BackgroundColor3 = C.fieldHi, BackgroundTransparency = 1 })
      local inner = box(line, { Size = UDim2.fromOffset(0, 15), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1 })
      list(inner, 5, true)
      local key = text(inner, "[" .. Config.keyLabel(bind.key) .. "]", { Name = "Key", Size = UDim2.fromOffset(0, 15), AutomaticSize = Enum.AutomaticSize.X, TextSize = 12, LayoutOrder = 1,
        TextColor3 = C.faint })
      local name = text(inner, lower(bind.label), { Size = UDim2.fromOffset(0, 15), AutomaticSize = Enum.AutomaticSize.X, TextSize = 12, LayoutOrder = 2, TextColor3 = C.dim })
      local state
      if bind.kind == "toggle" then
        state = text(inner, "", { Size = UDim2.fromOffset(0, 15), AutomaticSize = Enum.AutomaticSize.X, TextSize = 11, LayoutOrder = 3, TextColor3 = C.faint })
      end
      local row = { key = key, name = name, wash = wash, state = state, hold = bind.mode == "hold" }
      api.rows[bind.id] = row
      local was = before[bind.id]
      light(row, was == nil and bind.on or was, false)
      if was ~= nil and was ~= bind.on then light(row, bind.on, true) end
    end
  end
  return api
end

-- ---------------------------------------------------------------- the kit (src/07): tabs that draw themselves, in this look
local function unwearOne(instance, property)
  for index = #accented, 1, -1 do
    local entry = accented[index]
    if entry[1] == instance and entry[2] == property then table.remove(accented, index) end
  end
end
local KIT_ROLES = { card = C.box, field = C.field, hover = C.fieldHi, line = C.dark, back = C.back, text = C.text, dim = C.dim, faint = C.faint,
  onAccent = Color3.new(1, 1, 1), good = rgb(82, 214, 160), bad = rgb(255, 101, 119) }
local kit = { look = "unnamed", radius = 0, small = 0, size = 12 }
function kit.owns(frame) return U.gui ~= nil and frame:IsDescendantOf(U.gui) end
function kit.color(role)
  if role == "accent" then return accent(), 0 end
  return KIT_ROLES[role] or C.text, 0
end
function kit.paint(instance, property, role)
  unwearOne(instance, property)
  if role == "accent" then wear(instance, property) else instance[property] = KIT_ROLES[role] or C.text end
end
function kit.fill(instance, role)
  kit.paint(instance, "BackgroundColor3", role)
  instance.BackgroundTransparency = 0
end
function kit.clear(instance) instance.BackgroundTransparency = 1 end
function kit.font(bold) if not FONT then pickFont() end return bold and BOLD or FONT end
function kit.text(parent, value, props, bold, size)
  local all = { TextSize = size or 12, TextTruncate = Enum.TextTruncate.AtEnd }
  if props then for key, v in pairs(props) do all[key] = v end end
  return text(parent, value, all, bold)
end
function kit.entry(parent, size) return entryBox(parent, size or 12) end
function kit.outline(frame) return lined(frame, C.dark) end
function kit.corner() return nil end
-- a short list under `anchor` (inside this menu): items as UI.menu takes them
function kit.menu(anchor, items)
  local rows, map = {}, {}
  for _, item in ipairs(items) do
    if type(item) == "table" then
      rows[#rows + 1] = { lower(item.label), item.checked == true }
      map[#rows] = item
    end
  end
  if #rows == 0 then return end
  openList(anchor, rows, function(index)
    local item = map[index]
    if item and item.run then B.try("unnamed.menu", item.run) end
    return item ~= nil and item.keepOpen == true
  end, false)
end
U.kit = kit
Window.kits.unnamed = kit

-- ---------------------------------------------------------------- the watermark
-- This look's version of the island: top left, under the game's own buttons. The hub's name, who
-- is playing, the game, frames a second, ping and the time; a click opens the menu.
local mark
local function watermarkWanted() return U.active() and Config.get("app.unnamed.watermark") ~= false and Config.get("app.island") ~= false end
function U.watermark()
  if not Window.hud then return end
  if not watermarkWanted() then
    if mark then mark.frame.Visible = false end
    return
  end
  if not mark then
    local frame = lined(box(Window.hud, { Name = "Watermark", Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = C.back }), C.dark)
    local sizer = Instance.new("UIScale"); sizer.Parent = frame
    crownOn(frame)
    local line = box(frame, { Position = UDim2.fromOffset(0, 2), Size = UDim2.new(0, 0, 1, -2), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1 })
    pad(line, 0, 8, 0, 8)
    list(line, 0, true)
    wear(text(line, "based", { Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, TextSize = 12, LayoutOrder = 1 }, true), "TextColor3")
    local rest = text(line, "", { Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, TextSize = 12, LayoutOrder = 2 })
    local click = hit(frame, { ZIndex = 9 })
    click.Activated:Connect(B.safe("unnamed.watermark", function() U.show(true) end))
    local status = B.Registry and B.Registry.status and B.Registry.status() or {}
    local where = lower(status.name or "universal")
    local who = lower(B.LP.Name)
    local function seat()
      local inset = UI.inset()
      sizer.Scale = scaleNow()
      frame.Position = UDim2.fromOffset(12, math.max(inset.Y, 0) + 10)
    end
    seat()
    mark = { frame = frame, seat = seat }
    Motion.every(function()
      if not frame.Visible then return end
      local hud = B.Hud
      local fps = hud and hud.fps and math.floor(hud.fps() + 0.5) or 0
      local ping = hud and hud.ping and math.floor(hud.ping() + 0.5) or 0
      rest.Text = string.format("  |  %s  |  %s  |  %d fps  |  %d ms  |  %s", who, where, fps, ping, os.date("%H:%M"))
    end, 2, "unnamed.watermark")
    Config.on("app.scale", function() if mark then mark.seat() end end)
  end
  mark.frame.Visible = true
end

-- switching looks: the other one is closed and this one opened where it was
function U.start()
  Config.define("app.gui", "based")
  Config.define("app.unnamed.accent", ACCENT)
  Config.define("app.unnamed.x", 0.5)
  Config.define("app.unnamed.y", 0.5)
  Config.define("app.unnamed.w", W)
  Config.define("app.unnamed.h", H)
  Config.define("app.unnamed.font", "monocraft")
  Config.define("app.unnamed.textSize", 100)
  Config.define("app.unnamed.watermark", true)
  Config.on("app.gui", function(look)
    if look == "unnamed" then
      Window.show(false)
      U.show(true)
    else
      U.show(false)
      -- (the Novoline look opens itself: src/53)
      if look ~= "novoline" or not B.Novoline then Window.show(true) end
    end
    U.watermark()
  end)
  Config.on("app.unnamed.font", refont)
  Config.on("app.unnamed.textSize", refont)
  Motion.every(sweepTyped, 0.1, "unnamed.sweep")
  Config.on("app.unnamed.watermark", function() U.watermark() end)
  Config.on("app.island", function() U.watermark() end)
  -- a tab added or taken away later (a game's tabs) shows up here as well
  local rebuildNav = Window.rebuildNav
  Window.rebuildNav = function(...)
    rebuildNav(...)
    if U.built then U.rebuildTabs() end
  end
end
end

do -- 53_novoline.lua
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
  -- atlas stubbed: render as a text glyph (TextLabel), never blank.
  local label = Instance.new("TextLabel")
  label.BackgroundTransparency, label.BorderSizePixel = 1, 0
  label.Size = UDim2.fromOffset(size, size)
  label.Font = Enum.Font.SourceSans
  label.TextSize = size
  label.TextXAlignment = Enum.TextXAlignment.Center
  label.TextYAlignment = Enum.TextYAlignment.Center
  label.Text = Assets.glyphChar(name)
  label.TextColor3 = color or P.dim
  if props then for key, value in pairs(props) do label[key] = value end end
  label.Parent = parent
  return label
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
      size -= 1
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
        wear(glyph(row, "check", 14, nil, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), ZIndex = 93 }), "TextColor3")
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
  section.count += 2
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
      if sizer then scale *= sizer.Scale end
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
      wear(check, "TextColor3")
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
    total += widths[i] + (i > 1 and 6 or 0)
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
    x += widths[i] + 6
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
  page.sections += 1
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
    x += w + DOCK.gap
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
        { img, QUICK, { TextColor3 = selected and ICON_ON or (over and ICON_HOVER or ICON_OFF) } },
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
    x += DOCK.w + DOCK.gap
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
  image.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(B.LP.UserId) .. "&w=150&h=150"
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
    { label = "Unload BASED", icon = "power", danger = true, run = function() B.unload() end },
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
  for _, item in ipairs(entry.rows) do if item.card == frame then n += 1 end end
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
  text(account.body, B.LP.DisplayName, 13, "bold", { Position = UDim2.fromOffset(46, 6), Size = UDim2.fromOffset(122, 16), ZIndex = 22 })
  text(account.body, "@" .. B.LP.Name, 10, "medium", { Position = UDim2.fromOffset(46, 23), Size = UDim2.fromOffset(122, 14), TextColor3 = P.subtle, ZIndex = 22 })
  glyph(account.body, "chevron-down", 14, P.subtle, { Position = UDim2.fromOffset(200 - 30, 15), ZIndex = 22 })
  local accountHit = hit(account.body, { ZIndex = 24, BackgroundColor3 = P.white })
  round(accountHit, 22)
  accountHit.MouseEnter:Connect(function() tween(accountHit, HOVER_INFO, { BackgroundTransparency = 0.96 }) end)
  accountHit.MouseLeave:Connect(function() tween(accountHit, HOVER_INFO, { BackgroundTransparency = 1 }) end)
  accountHit.Activated:Connect(B.safe("novoline.account", function() UI.sfx("click", 0.5); looksMenu(account.frame) end))
  -- Music is Novoline's music deck: what is playing is the stage, bottom left (its record, the
  -- cover and the Shuffle, Library and Playlists tiles: the hub's wide card), and the tab's sections
  -- sit bottom right, the way Novoline's queue does
  local stage = source.id == "music" and B.Card ~= nil and B.Card.viewWide ~= nil
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
  if B.Keys and B.Keys.repaint then B.Keys.repaint() end
  -- its sections, beside it (a tab of one section is a stage of its own)
  d.single = #entry.list == 1 and not stage
  d.fixed = stage
  if stage then
    local size = B.Card.WIDE
    local now = addCard(d, "NowPlaying", "bl", 0, 0, STAGE_W, CARD_H)
    local k = math.min(STAGE_W / size.X, CARD_H / size.Y)
    local holder = box(now.body, { Name = "Wide", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(size.X, size.Y), ZIndex = 21 })
    local grow = Instance.new("UIScale"); grow.Scale = k; grow.Parent = holder
    B.try("novoline.music.stage", B.Card.viewWide, holder, function() return N.open and N.current == "music" end)
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
      tween(mark, QUICK, { TextColor3 = on and tint[2] or P.text })
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
    token += 1
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
    if on then count += rowsIn(entry, other.frame) end
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
  text(title.body, "Welcome back, " .. B.LP.DisplayName, 30, "black", { Size = UDim2.fromOffset(760, 36), ZIndex = 22 })
  local day = text(title.body, dayLine(), 13, "medium", { Position = UDim2.fromOffset(1, 40), Size = UDim2.fromOffset(760, 18), TextColor3 = P.sub, ZIndex = 22 })
  -- the clock and the executor, top right
  local clock = addCard(d, "Clock", "tr", 0, 0, 158, 44)
  glyph(clock.body, "clock", 16, P.subtle, { Position = UDim2.fromOffset(16, 14), ZIndex = 22 })
  local time = text(clock.body, "", 15, "bold", { Position = UDim2.fromOffset(42, 0), Size = UDim2.fromOffset(50, 44), ZIndex = 22 })
  local date = text(clock.body, "", 13, "medium", { Position = UDim2.fromOffset(94, 0), Size = UDim2.fromOffset(56, 44), TextColor3 = P.subtle, ZIndex = 22 })
  local execName = "Executor"
  pcall(function()
    local name = (identifyexecutor or getexecutorname)()
    if type(name) == "string" and name ~= "" then execName = name end
  end)
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
  text(profile.body, B.LP.DisplayName, 18, "bold", { Position = UDim2.fromOffset(18, 158), Size = UDim2.fromOffset(194, 22), ZIndex = 22 })
  text(profile.body, "@" .. B.LP.Name, 12, "medium", { Position = UDim2.fromOffset(18, 182), Size = UDim2.fromOffset(194, 16), TextColor3 = P.subtle, ZIndex = 22 })
  local stat = {}
  for n, key in ipairs({ "Friends", "Account", "Online" }) do
    local x = 18 + (n - 1) * 68
    stat[key] = text(profile.body, "", 16, "bold", { Position = UDim2.fromOffset(x, 232), Size = UDim2.fromOffset(64, 20), ZIndex = 22 })
    text(profile.body, key, 11, "medium", { Position = UDim2.fromOffset(x, 254), Size = UDim2.fromOffset(64, 14), TextColor3 = P.subtle, ZIndex = 22 })
  end
  local ageDays = tonumber(B.LP.AccountAge) or 0
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
  for n, spec in ipairs({ { "skip-back", function() local M = B.Music; if M then M.front().previous() end end },
    { "play", function()
      local M = B.Music
      local ctl = M and M.front()
      if ctl and ctl.track() then ctl.toggle() elseif M and M.openTab then M.openTab() end
    end },
    { "skip-forward", function() local M = B.Music; if M then M.front().next() end end } }) do
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
  local function refreshMusic()
    local M = B.Music
    local ctl = M and M.front()
    local track = ctl and ctl.track()
    local state = ctl and ctl.state() or "idle"
    if track and state ~= "idle" then
      songTitle.Text = track.title or "Playing"
      songArtist.Text = (ctl.status and ctl.status()) or track.artist or (state == "playing" and "Playing" or "Paused")
      if coverKey ~= track.key then
        coverKey = track.key
        cover.Image = ""
        B.try("novoline.cover", ctl.cover, track, cover)
      end
      coverMark.Visible = cover.Image == ""
    else
      songTitle.Text, songArtist.Text = "Nothing playing", "Pick a song from your library"
      cover.Image, coverMark.Visible, coverKey = "", true, nil
    end
    UI.setIcon(playIcon, state == "playing" and "pause" or "play")
    controls[1].Visible = track ~= nil
    controls[3].Visible = track ~= nil
  end
  -- two quick commands under it
  local cmd = addCard(d, "QuickCommands", "bl", 244, 360 + 14, 260, 118)
  text(cmd.body, "Quick Commands", 13, "bold", { Position = UDim2.fromOffset(16, 12), Size = UDim2.fromOffset(190, 16), ZIndex = 22 })
  glyph(cmd.body, "zap", 14, P.subtle, { Position = UDim2.fromOffset(260 - 30, 13), ZIndex = 22 })
  local cmdW = math.floor((260 - 14 * 2 - 10 * 2) / 3)
  local commands = {
    { label = "Copy ID", icon = "copy", tint = TINT[4], run = function()
      local done = B.clipboard and B.clipboard(tostring(B.LP.UserId))
      Window.toast({ title = "User ID", text = done and ("Copied " .. tostring(B.LP.UserId)) or "Clipboard unavailable.", icon = "copy", tone = done and "ok" or "warn", time = 2.4 })
    end },
    { label = "Settings", icon = "settings", tint = TINT[5], run = function()
      if Window and Window.palette then B.try("palette", Window.palette) end
      Window.toast({ title = "Settings", text = "Accent / palette opened.", icon = "settings", time = 2 })
    end },
    { label = "Theme", icon = "sparkles", tint = TINT[1], run = function()
      local order = { "novoline", "unnamed", "based" }
      local cur = Config.get("app.gui") or "novoline"
      local next = "novoline"
      for i, name in ipairs(order) do if name == cur then next = order[(i % #order) + 1] end end
      Config.set("app.gui", next)
      Window.toast({ title = "Theme", text = "Switched to " .. next, icon = "sparkles", time = 2 })
    end },
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
  local status = B.Registry and B.Registry.status and B.Registry.status() or {}
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
      local done = B.clipboard and B.clipboard(value())
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
  chip("Rejoin", "rotate-ccw", 18, 124, function()
    B.try("rejoin", function()
      local ts = S:GetService("TeleportService")
      ts:Teleport(game.PlaceId, B.LP)
    end)
    Window.toast({ title = "Rejoin", text = "Teleporting to this place…", icon = "rotate-ccw", time = 2 })
  end)
  chip("Server hop", "shuffle", 150, 132, function()
    B.try("serverhop", function()
      local ts = S:GetService("TeleportService")
      ts:Teleport(game.PlaceId, B.LP)
    end)
    Window.toast({ title = "Server hop", text = "Joining a new server…", icon = "shuffle", time = 2 })
  end)
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
  local friendsAt, totalAsked = -1e9, false
  local function loadFriends()
    if os.clock() - friendsAt < 30 then return end
    friendsAt = os.clock()
    task.spawn(function()
      local ok, list0 = pcall(function() return B.LP:GetFriendsOnline(50) end)
      if not friendLine.Parent then return end
      if not ok or type(list0) ~= "table" then friendLine.Text = "Friends could not be loaded"; return end
      local here = 0
      for _, f in ipairs(list0) do if f.PlaceId == game.PlaceId then here += 1 end end
      for n, f in ipairs(faces) do
        local friend = list0[n]
        f.Visible = friend ~= nil
        if friend then f.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(friend.VisitorId) .. "&w=48&h=48" end
      end
      local shown = math.min(#list0, #faces)
      more.Position = UDim2.fromOffset(18 + math.max(shown - 1, 0) * 27 + 36 + 10, 48)
      more.Text = #list0 > #faces and ("+" .. (#list0 - #faces)) or ""
      friendCount.Text = tostring(#list0)
      stat.Online.Text = tostring(#list0)
      if #list0 == 0 then friendLine.Text = "No friends online right now"
      elseif here == 0 then friendLine.Text = "None of them are in this game"
      else friendLine.Text = here .. (here == 1 and " of them is" or " of them are") .. " playing this game" end
    end)
    if totalAsked then return end
    totalAsked = true
    task.spawn(function()
      local count = 0
      local ok = pcall(function()
        local pages = S.Players:GetFriendsAsync(B.LP.UserId)
        while true do
          count += #pages:GetCurrentPage()
          if pages.IsFinished then break end
          pages:AdvanceToNextPageAsync()
        end
      end)
      if stat.Friends.Parent then stat.Friends.Text = ok and tostring(count) or "0" end
    end)
  end
  local function uptime(seconds)
    seconds = math.floor(seconds or 0)
    if seconds >= 3600 then return string.format("%dh %dm", seconds // 3600, (seconds % 3600) // 60) end
    return string.format("%dm", math.max(1, seconds // 60))
  end
  -- real fps/ping (B.Hud is stripped): count heartbeats, read network ping directly
  local frames, lastFps, fpsAt = 0, 60, os.clock()
  S.RunService.Heartbeat:Connect(function() frames = frames + 1 end)
  local function realFps()
    local now = os.clock()
    if now - fpsAt >= 1 then lastFps = math.floor(frames / math.max(0.001, now - fpsAt)); frames = 0; fpsAt = now end
    return lastFps
  end
  local function realPing()
    local ok, ping = pcall(function() return B.LP:GetNetworkPing() end)
    if ok and type(ping) == "number" then return math.floor(ping * 1000 + 0.5) end
    return 0
  end
  d.refresh = function()
    time.Text = os.date("%H:%M")
    date.Text = (string.gsub(os.date("%a %d"), " 0", " "))
    day.Text = dayLine()
    sv.Players.Text = #S.Players:GetPlayers() .. "/" .. S.Players.MaxPlayers
    sv.Ping.Text = tostring(realPing()) .. "ms"
    sv.Uptime.Text = uptime(workspace.DistributedGameTime)
    fpsValue.Text = tostring(realFps())
    B.try("novoline.music", refreshMusic)
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
  local gui = B.screen(9060)
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
  motionToken += 1
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
  if not (island ~= nil and island.frame.Visible and B.Music ~= nil) then return false end
  local ctl = B.Music.front()
  return ctl.track() ~= nil and ctl.state() ~= "idle"
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
  text(idle, "BASED", 12, "black", { Position = UDim2.fromOffset(30, 0), Size = UDim2.new(0, 56, 1, 0), ZIndex = 72 })
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
  local songName = B.Music and B.Music.marquee(song, kit, { Position = UDim2.fromOffset(42, 4), Size = UDim2.new(1, -96, 0, 15), ZIndex = 72 }, true, 12)
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
  local lyricRow = B.Island and B.Island.row(song, { font = face("bold"), size = 13, z = 72, accent = function()
    return B.Card and B.Card.wordColor(accent()) or accent()
  end }) or nil
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
    local M = B.Music
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
      level += (loud - level) * math.min(dt * 12, 1)
      local now = os.clock()
      for i, bar in ipairs(bars) do
        local wobble = 0.45 + 0.55 * math.abs(math.sin(now * (3.1 + i * 0.9) + i))
        bar.Size = UDim2.fromOffset(4, math.clamp(4 + level * 18 * wobble, 4, 22))
      end
    else
      shape(196, 36)
      local hud = B.Hud
      local fps = hud and hud.fps and math.floor(hud.fps() + 0.5) or 0
      local ping = hud and hud.ping and math.floor(hud.ping() + 0.5) or 0
      stats.Text = string.format("%d fps · %d ms", fps, ping)
    end
  end, nil, "novoline.island")
end
function N.island() if N.gui then makeIsland() end end
-- messages go into the island while this look is in use
Window.toastHook = function(opts)
  if not (N.built and islandWanted() and island) then return nil end
  if opts.music and Config.get("music.island") ~= false then return function() end end
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
    local shape = B.Keys.shape(binds, moving, 12)
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
-- Novoline's pieces, for the panels of other files drawn in this look (dahood_hunt's)
N.parts = { P = P, TINT = TINT, box = box, round = round, rim = rim, text = text, entryBox = entryBox, hit = hit, glyph = glyph, list = list, pad = pad,
  glass = glass, tile = tile, tween = tween, HOVER = HOVER_INFO }
function N.start()
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
end
end

do -- 90_boot.lua
-- ============================================================================
--  90 boot     order of operations
-- ============================================================================
local S, util, Motion, Theme, T, UI, Config, Window, Assets = B.S, B.util, B.Motion, B.Theme, B.T, B.UI, B.Config, B.Window, B.Assets
local UIS = S.UserInputService

local function boot()
  if not game:IsLoaded() then game.Loaded:Wait() end
  Config.init()
  Assets.init()
  if B.Prefs then B.Prefs.define() end
  if B.Prefs then B.Prefs.apply() end
  if B.Unnamed then B.Unnamed.start() end
  if B.Novoline then B.Novoline.start() end
  -- library: default to the Novoline look. define("app.gui") defaults to "based" (src/52),
  -- so this set is a CHANGE and fires both look handlers: src/52's switcher and src/53's
  -- activation (Config.on "app.gui") which builds N.gui, registers Window.kits.novoline,
  -- and paints controls in Novoline styling. Must run before Window.build() so the shared
  -- shell assembles with the novoline kit. The handler opens Novoline; we close it again
  -- immediately (synchronous, no rendered frame) so the library never auto-shows a window.
  Config.set("app.gui", "novoline")
  if B.Novoline and B.Novoline.built then
    B.Novoline.show(false)
    if B.Novoline.bar then B.Novoline.bar.Visible = false end
    if B.Novoline.shade then B.Novoline.shade.Visible = false end
  end
  Window.build()
  -- the game is looked up first: its module can ask for Universal not to be loaded at all
  if B.Registry then B.try("registry.pick", B.Registry.pick) end
  for _, register in ipairs(B.pages or {}) do
    local name = B.universalPages and B.universalPages[register]
    if not name or not B.Registry or B.Registry.keeps(name) then B.try("pages", register) end
  end
  if B.Registry then B.try("registry", B.Registry.resolve) end
  Window.rebuildNav()
  Config.listen()

  -- the menu key, the palette, and the panic key
  B.connect(UIS.InputBegan, function(input)
    if Config.capturing then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    local name = input.KeyCode.Name
    if UIS:GetFocusedTextBox() then return end
    if name == Config.get("app.key.menu") then
      if B.Loader and B.Loader.active then return end
      Window.toggleActive()
    elseif name == Config.get("app.key.panic") then
      B.unload()
    elseif input.KeyCode == Enum.KeyCode.K and (UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl)) and Window.open then
      Window.palette()
    end
  end, "boot.keys")

  local function reveal()
    -- library: never auto-show on load; open via API (Window:Show) or the menu key.
    -- Set B._autoOpen = true before load (or getgenv().NovalineUI_B._autoOpen = true) to restore hub behaviour.
    if not B._autoOpen then return end
    Window.showActive(true)
    if B.Hud then B.try("hud", B.Hud.start) end
    if B.Unnamed then B.try("unnamed.watermark", B.Unnamed.watermark) end
    if B.Novoline and B.Novoline.active() then B.try("novoline.island", B.Novoline.island) end
    if B.Keys then B.try("keys.hud", B.Keys.hud) end
    if B.Registry then B.try("registry.announce", B.Registry.announce) end
  end
  -- the other tabs are assembled a card per frame in the background: under the intro when there
  -- is one, so the hub is complete the moment it appears
  task.delay(0.7, function() if B.alive then Window.prebuild() end end)
  -- The first launch on this machine: which look to open in is asked once, when the intro is done
  -- (not when an intro is forced off for one launch: that is a test or a reload)
  local function begin()
    if Config.firstRun and B.Picker and B.genv.BASED_INTRO ~= "off" and not B.genv.BASED_NO_PICKER then
      B.Picker.show(function(look)
        if look then Config.set("app.gui", look) end
        B.try("reveal", reveal)
      end)
    else
      reveal()
    end
  end
  if B.Loader then B.Loader.run(begin) else begin() end
  B.bootMs = math.floor((os.clock() - B.bootClock) * 1000)
end

task.spawn(function()
  local ok, err = xpcall(boot, function(e) return tostring(e) .. "\n" .. debug.traceback("", 2) end)
  if not ok then
    B.fault("boot", err)
    pcall(function()
      S.StarterGui:SetCore("SendNotification", { Title = "BASED Hub", Text = "Failed to start: " .. string.sub(tostring(err), 1, 120), Duration = 8 })
    end)
  end
end)
end
-- (return B removed: the clean Library facade below is returned on every load)

end -- B._init init guard

-- ============================================================================
--  Public API facade  (clean surface over internal B; B is never leaked)
-- ============================================================================
local Library = (function()
  local Window, Config, Theme, UI, Novoline = B.Window, B.Config, B.Theme, B.UI, B.Novoline
  local counter = 0
  local function uid(prefix) counter = counter + 1; return "novalineui." .. prefix .. "." .. tostring(counter) end

  -- wrap a raw widget api (from section:toggle/slider/...) with the public method names.
  -- raw may be nil until the page is built; operations are queued and flushed then.
  local function makeWidget(tab, kind, opts, isValue)
    opts = opts or {}
    local label = opts.Label or opts.label or kind
    local listeners = {}
    if opts.Callback and type(opts.Callback) == "function" then listeners[#listeners + 1] = opts.Callback end
    local holder = { raw = nil, pending = {} }
    local function apply(fn)
      if holder.raw then fn(holder.raw) else holder.pending[#holder.pending + 1] = fn end
    end
    local w = {}
    if isValue then
      function w:SetValue(v) apply(function(r) if r.set then r.set(v) end end); return self end
      function w:GetValue()
        if holder.raw and holder.raw.get then return holder.raw.get() end
        return opts.Default
      end
      function w:OnChanged(fn)
        if type(fn) == "function" then listeners[#listeners + 1] = fn end
        return self
      end
    end
    function w:SetVisible(on)
      apply(function(r)
        local f = (r.row and r.row.frame) or r.frame or r.card
        if f then f.Visible = on == true end
      end)
      return self
    end
    function w:Destroy()
      apply(function(r)
        local f = (r.row and r.row.frame) or r.frame or r.card
        if f then f:Destroy() end
      end)
      return self
    end
    -- queue the actual construction onto the tab (runs when the page is built)
    table.insert(tab._builders, function(page, getCurrent)
      local section = getCurrent()
      local actualKind = kind
      if actualKind == "dropdown" and opts.Multi then actualKind = "multi" end
      local spec = {
        label = label,
        default = opts.Default,
        min = opts.Min, max = opts.Max, step = opts.Step,
        options = opts.Options, multi = opts.Multi,
        placeholder = opts.Placeholder, numeric = opts.Numeric,
        tip = opts.Desc or opts.Tip,
        changed = function(v)
          for _, fn in ipairs(listeners) do B.try("novalineui." .. actualKind, fn, v) end
        end,
      }
      if actualKind == "button" then
        spec.text = label
        spec.run = function()
          for _, fn in ipairs(listeners) do B.try("novalineui.button", fn) end
        end
        spec.changed = nil
      end
      if actualKind == "note" then
        spec.text = label
      end
      if actualKind == "color" and opts.Transparency ~= nil then spec.transparency = opts.Transparency end
      local raw
      local ok, err = pcall(function() raw = section[actualKind](section, spec) end)
      if not ok then
        B.fault("novalineui.widget." .. actualKind, tostring(err))
        raw = { frame = Instance.new("Frame") }
      end
      holder.raw = raw
      for _, fn in ipairs(holder.pending) do fn(raw) end
      holder.pending = {}
    end)
    return w
  end

  local Tab = {}
  Tab.__index = Tab

  local function newTab(win, spec)
    local tab = setmetatable({ _window = win, _name = spec.Name or spec.name or "Tab", _builders = {} }, Tab)
    local id = uid("tab")
    tab._id = id
    local function build(page)
      local current = page:section({ title = nil })
      for _, fn in ipairs(tab._builders) do
        B.try("novalineui.build." .. id, fn, page, function() return current end, function(title)
          current = page:section({ title = title }); return current
        end)
      end
    end
    Window.page({ id = id, title = tab._name, icon = spec.Icon or spec.icon or "circle", build = build })
    return tab
  end

  function Tab:Toggle(opts) return makeWidget(self, "toggle", opts, true) end
  function Tab:Button(opts) return makeWidget(self, "button", opts, false) end
  function Tab:Slider(opts) return makeWidget(self, "slider", opts, true) end
  function Tab:Dropdown(opts) return makeWidget(self, "dropdown", opts, true) end
  function Tab:Keybind(opts) return makeWidget(self, "keybind", opts, true) end
  function Tab:Colorpicker(opts) return makeWidget(self, "color", opts, true) end
  function Tab:Textbox(opts) return makeWidget(self, "input", opts, true) end
  function Tab:Label(text) return makeWidget(self, "note", { text = text, Label = text }, false) end
  function Tab:Section(title)
    table.insert(self._builders, function(page, getCurrent, newSection) newSection(title) end)
    local s = {}
    function s:SetVisible() return self end
    function s:Destroy() return self end
    return s
  end

  local Win = {}
  Win.__index = Win

  local function newWindow(opts)
    opts = opts or {}
    local w = setmetatable({ _tabs = {}, _title = opts.Title or opts.title or "NovalineUI" }, Win)
    if opts.Theme then pcall(function() Config.set("app.theme", opts.Theme) end) end
    if opts.SubTitle then w._subtitle = opts.SubTitle end
    return w
  end
  function Win:Tab(spec)
    if type(spec) == "string" then spec = { Name = spec } end
    local tab = newTab(self, spec or {})
    self._tabs[#self._tabs + 1] = tab
    return tab
  end
  function Win:Show()
    if Window and Config and Config.get("app.gui") ~= "novoline" then pcall(function() Config.set("app.gui", "novoline") end) end
    if Window and Window.showActive then Window.showActive(true) end
    return self
  end
  function Win:Hide() if Window and Window.showActive then Window.showActive(false) end; return self end
  function Win:Toggle() if Window and Window.toggleActive then Window.toggleActive() end; return self end
  function Win:Destroy()
    for _, t in ipairs(self._tabs) do pcall(Window.removePage, t._id) end
    return self
  end

  local Lib = {}
  function Lib:CreateWindow(opts) return newWindow(opts) end
  function Lib:SetTheme(name)
    pcall(function() if Theme and Theme.set then Theme.set(name) end end)
    pcall(function() Config.set("app.theme", name) end)
    return self
  end
  function Lib:Notify(opts)
    opts = opts or {}
    if Window and Window.toast then
      Window.toast({ title = opts.Title or opts.title, text = opts.Text or opts.text,
        icon = opts.Icon or opts.icon, time = opts.Time or opts.time or 3 })
    end
    return self
  end
  -- advanced: access internals (B) only if explicitly opted in
  Lib._internal = B
  -- register Novoline's built-in home deck as the first tab. N.go("home") is handled
  -- specially (buildHome) so build() is a no-op; order=0 puts it first in the dock.
  if Window and not Window.pages.home then
    Window.page({ id = "home", title = "Home", icon = "house", order = 0, build = function() end })
  end
  -- floating open/close button (FAB): always visible even when the menu is closed.
  -- Draggable; position persisted in Config. Toggles via Window.toggleActive (Novoline when active).
  task.spawn(function()
    local S = B.S
    if not game:IsLoaded() then pcall(function() game.Loaded:Wait() end) end
    local fabGui = B.screen(9070)
    fabGui.Name = "NovalineUI_FAB"
    fabGui.ResetOnSpawn = false
    Config.define("app.novoline.fab.x", 0.93)
    Config.define("app.novoline.fab.y", 0.08)
    local fab = Instance.new("TextButton")
    fab.Name = "FAB"
    fab.Size = UDim2.fromOffset(46, 46)
    fab.AnchorPoint = Vector2.new(0.5, 0.5)
    fab.Position = UDim2.new(Config.get("app.novoline.fab.x"), 0, Config.get("app.novoline.fab.y"), 0)
    fab.BackgroundTransparency = 0.12
    fab.BorderSizePixel = 0
    fab.Text = ""
    fab.AutoButtonColor = false
    fab.ZIndex = 200
    fab.Active = true
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(1, 0); corner.Parent = fab
    local stroke = Instance.new("UIStroke"); stroke.Thickness = 1.5; stroke.Transparency = 0.6; stroke.Parent = fab
    pcall(function()
      fab.BackgroundColor3 = Color3.fromRGB(88, 130, 255)
      stroke.Color = Color3.fromRGB(88, 130, 255)
    end)
    local icon = Instance.new("TextLabel")
    icon.BackgroundTransparency = 1
    icon.Size = UDim2.fromScale(1, 1)
    icon.Font = Enum.Font.SourceSans
    icon.TextSize = 22
    icon.Text = (B.Assets and B.Assets.glyphChar and B.Assets.glyphChar("menu")) or "☰"
    icon.TextColor3 = Color3.new(1, 1, 1)
    icon.TextXAlignment = Enum.TextXAlignment.Center
    icon.TextYAlignment = Enum.TextYAlignment.Center
    icon.ZIndex = 201
    icon.Parent = fab
    fab.Parent = fabGui
    local dragging, dragStart, startPos = false, nil, nil
    fab.InputBegan:Connect(function(input)
      if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = fab.Position
      end
    end)
    fab.InputEnded:Connect(function(input)
      if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and dragging then
        dragging = false
        Config.set("app.novoline.fab.x", fab.Position.X.Scale)
        Config.set("app.novoline.fab.y", fab.Position.Y.Scale)
      end
    end)
    S.UserInputService.InputChanged:Connect(function(input)
      if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        fab.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
      end
    end)
    fab.Activated:Connect(function()
      if Window and Window.toggleActive then B.try("fab.toggle", Window.toggleActive) end
    end)
  end)
  -- opt-in global leak (off by default)
  if _G and _G.NOVALINE_GLOBAL and type(getgenv) == "function" then
    getgenv().NovalineUI = Lib
  end
  return Lib
end)()

-- ============================================================================
--  Demo (off by default): run with  _G.NOVALINE_DEMO = true  before loadstring
-- ============================================================================
if _G and _G.NOVALINE_DEMO then
  task.spawn(function()
    local win = Library:CreateWindow({ Title = "NovalineUI Demo", SubTitle = "API smoke test" })
    local combat = win:Tab({ Name = "Combat", Icon = "sword" })
    win:Tab({ Name = "Visuals", Icon = "eye" })
    win:Tab({ Name = "Misc", Icon = "settings" })
    combat:Section("Every widget type")
    combat:Toggle({ Label = "Enabled", Default = true, Callback = function(v) print("[demo] Toggle:", v) end })
    combat:Button({ Label = "Press me", Callback = function() print("[demo] Button clicked") end })
    combat:Slider({ Label = "Amount", Min = 0, Max = 100, Default = 50, Callback = function(v) print("[demo] Slider:", v) end })
    combat:Dropdown({ Label = "Mode", Options = { "A", "B", "C" }, Default = "A", Callback = function(v) print("[demo] Dropdown:", v) end })
    combat:Keybind({ Label = "Hotkey", Default = "None", Callback = function(v) print("[demo] Keybind:", v) end })
    combat:Colorpicker({ Label = "Color", Default = Color3.new(1, 0.4, 0.2), Callback = function(v) print("[demo] Color:", v) end })
    combat:Textbox({ Label = "Name", Placeholder = "type here", Callback = function(v) print("[demo] Textbox:", v) end })
    combat:Label("This is a label / note row.")
    combat:Section("Second section")
    win:Show()
    Library:Notify({ Title = "NovalineUI", Text = "Demo loaded — all widget types wired.", Time = 4 })
  end)
end

return Library
