-- PulseHub ESP — standalone extracted version
-- extracted from PulseHub.luau (EspSettings / EspText / EspColor / EspBox / EspRole /
-- EspProjection / EspLabel / EspLine / EspTracer / EspSkeleton / EspHead / EspChams /
-- EspChamModel / EspRadar / EspGhost / EspFeature), wrapped with a minimal bootstrap
-- so it runs on its own. UI menu is stubbed — tweak USER_CONFIG below instead.
-- Stop: getgenv().PulseEspStop()

-- ===== USER CONFIG (แก้ตรงนี้ได้เลย) =====
local USER_CONFIG = {
	on        = true,   -- เปิด/ปิด ESP
	box       = true,   -- กล่องล้อมตัวละคร
	name      = true,   -- ชื่อผู้เล่น
	roleText  = true,   -- บทบาท (M/S/H/I) — จะเป็น Innocent หมดถ้าไม่มีข้อมูล MM2
	distance  = true,   -- ระยะห่าง
	health    = false,  -- แถบเลือด
	skeleton  = false,  -- โครงกระดูก
	chams     = false,  -- Highlight ส่องผนัง (กิน performance)
	tracer    = false,  -- เส้นลากจากขอบจอ
	headDot   = false,  -- จุดหัว
	lookLine  = false,  -- เส้นทิศทางการมอง
	maxDist   = 1000,   -- แสดงแค่ผู้เล่นในระยะนี้ (stud)
}
-- =========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")

local environment = {
	UDim2 = UDim2, UDim = UDim, Enum = Enum, os = os, time = time, tick = tick,
	Vector2 = Vector2, Vector3 = Vector3, Color3 = Color3, CFrame = CFrame,
	ColorSequence = ColorSequence, NumberSequence = NumberSequence,
	NumberSequenceKeypoint = NumberSequenceKeypoint, RaycastParams = RaycastParams,
	Instance = Instance, Font = Enum.Font, game = game, workspace = workspace,
	typeof = typeof, type = type, tonumber = tonumber, tostring = tostring,
	math = math, string = string, table = table, task = task,
	pcall = pcall, xpcall = xpcall, error = error, assert = assert,
	print = print, warn = warn, pairs = pairs, ipairs = ipairs, next = next,
	select = select, unpack = unpack or table.unpack,
	setmetatable = setmetatable, getmetatable = getmetatable, rawget = rawget, rawset = rawset,
	wait = wait, delay = delay, spawn = spawn,
	getgenv = (typeof(getgenv) == "function" and getgenv) or function() return getfenv(0) end,
	writefile = (typeof(writefile) == "function" and writefile) or function() end,
	makefolder = (typeof(makefolder) == "function" and makefolder) or function() end,
	isfolder = (typeof(isfolder) == "function" and isfolder) or function() return false end,
	isfile = (typeof(isfile) == "function" and isfile) or function() return false end,
	getcustomasset = (typeof(getcustomasset) == "function" and getcustomasset) or function() return nil end,
}

-- stub UI section — คอนโทรลทั้งหมดในตัว script จะ return handle เปล่าๆ (ไม่มีเมนู)
local handle = {Set = function() end, Get = function() return nil end, Refresh = function() end}
local section = {}
function section:Toggle() return handle end
function section:Slider() return handle end
function section:Dropdown() return handle end
function section:Colorpicker() return handle end
function section:Group() return section end
function section:Note() return {Text = ""} end
function section:Header() end
function section:Sub() end

local context = {
	environment = environment,
	section = section,
	configuration = {rolesp = {on = true}},
	workspace = workspace,
	players = Players,
	player = Players.LocalPlayer,
	roles = {}, -- ไม่มีข้อมูลบทบาท MM2 → ทุกคนเป็นสี Innocent/no-role
	runService = RunService,
	coreGui = CoreGui,
	textService = TextService,
	nova = {Icons = {apply = function() end}, U = {hostGui = CoreGui}},
	inputService = UserInputService,
	translation = {tr = function(text) return text end, bind = function() end},
	connect = function(event, callback) return event:Connect(callback) end,
}

-- ===== BEGIN extracted PulseHub ESP module (verbatim from PulseHub.luau) =====
local EspSettings = {}

function EspSettings.create(environment, configuration)
	local color = environment.Color3
	local settings = {
		on = false, style = "Box", maxDist = 1000, murderer = true, sheriff = true, hero = true, innocent = true,
		noRole = false, visCheck = false, dimHidden = true, hiddenStyle = "Fade", smooth = 40, fade = true, fadeFrom = 60,
		box = true, boxStyle = "Corners", boxThickness = 1, cornerSize = 22, boxRound = 4, outline = true, boxFill = false,
		boxFillAlpha = 8, boxGlow = false, glowStrength = 25, gradient = false,
		gradientColour = color.fromRGB(255, 255, 255), pulse = false, pulseSpeed = 1.2, colorMode = "Role",
		customColour = color.fromRGB(245, 245, 245), hiddenColour = color.fromRGB(150, 155, 170),
		murdererColour = color.fromRGB(255, 64, 64), sheriffColour = color.fromRGB(80, 150, 255),
		heroColour = color.fromRGB(255, 210, 60), innocentColour = color.fromRGB(90, 230, 130),
		noRoleColour = color.fromRGB(176, 182, 204), skeleton = false, boneThick = 1.5, boneRole = true,
		boneColour = color.fromRGB(235, 235, 235), boneHidden = color.fromRGB(170, 140, 255), headDot = false,
		headScale = 80, lookLine = false, lookLength = 10, health = false, healthPosition = "Left", healthStyle = "Solid",
		barThickness = 2, barGap = 3, healthNum = false, smoothHealth = true, healthLow = color.fromRGB(235, 60, 60),
		healthHigh = color.fromRGB(90, 225, 120), name = true, nameMode = "Display name", roleText = true,
		weaponIcon = true, distance = false, textFont = "GothamSSm", textSize = 12, infoSize = 10, textOutline = true,
		textMatch = false, hideGameNames = true, textGrad = false, textGradStyle = "ESP Color",
		textGradA = color.fromRGB(255, 94, 160), textGradB = color.fromRGB(90, 200, 255), textGradAnim = true,
		textGradSpeed = 1, textGradAngle = 0, nameColour = color.fromRGB(250, 250, 250),
		infoColour = color.fromRGB(200, 205, 215), nameOffset = 3, labelWidth = 240, plate = false, plateStyle = "Flat",
		plateAlpha = 70, plateColour = color.fromRGB(20, 20, 24), chams = false, chamsStyle = "Soft", chamsAlpha = 45,
		chamsThrough = false, chamsRange = 60, chamsOutline = true, chamsEdgeAlpha = 85, chamsRole = true,
		chamsColour = color.fromRGB(255, 70, 70), chamsHidden = color.fromRGB(150, 110, 255),
		chamsEdge = color.fromRGB(255, 255, 255), chamsEdgeHidden = color.fromRGB(200, 180, 255), chamsAnim = "None",
		chamsSpeed = 1, chamsFlow = color.fromRGB(255, 200, 80), chamsFlash = true, chamsMaterial = "Flat", tracer = false,
		tracerFrom = "Bottom", tracerThickness = 1, tracerAlpha = 60, tracerRole = true,
		tracerColour = color.fromRGB(235, 235, 235), offscreen = false, radarStyle = "Arrow", ringRadius = 170,
		arrowSize = 9, ringText = false, fxTargets = "All", glowHalo = 60, glowCore = 85, sparkles = false,
		sparkleStyle = "Sparkles", sparkleRate = 14, skyBeam = false, murderBeam = false, brightness = 100,
		saturation = 100, opacity = 100, lineScale = 100, textScale = 100, rainbowSpeed = 1, rainbowSat = 65,
		murdererFocus = false, focusScale = 160, nearColour = color.fromRGB(255, 107, 107),
		farColour = color.fromRGB(116, 170, 255), seenColour = color.fromRGB(125, 222, 170), boxWidth = 50, boxPad = 0,
		boxColMode = "ESP", boxCol = color.fromRGB(255, 255, 255), boxAnim = "None", boxAnimSpeed = 1,
		boxGradStyle = "Two Color", boxGradAngle = 90, fillStyle = "Solid", fillColMode = "ESP",
		fillCol = color.fromRGB(255, 255, 255), glowSize = 5, glowColMode = "ESP", glowCol = color.fromRGB(255, 255, 255),
		outlineCol = color.fromRGB(0, 0, 0), outlineAlpha = 65, outlineSize = 2, nameWeight = "SemiBold",
		nameCase = "Normal", namePos = "Above", strokeSize = 0, strokeCol = color.fromRGB(5, 8, 13), distUnit = "Studs",
		roleStyle = "Full", plateRadius = 5, plateBorder = 1, plateGrad = false, chamsBright = 100, chamsShell = 100,
		chamsGradA = color.fromRGB(255, 120, 150), chamsGradB = color.fromRGB(110, 160, 255), chamsGradScroll = false,
		boneStyle = "Line", boneAlpha = 100, joints = false, jointSize = 3, boneGrad = false,
		boneTop = color.fromRGB(255, 255, 255), boneBottom = color.fromRGB(160, 170, 190), headStyle = "Ring",
		headFill = 25, headColMode = "ESP", headCol = color.fromRGB(255, 255, 255), lookThick = 1.5, lookColMode = "ESP",
		lookCol = color.fromRGB(255, 255, 255), tracerTo = "Feet", tracerStyle = "Line", tracerMurderer = false,
		arrowPulse = false, arrowName = false, trail = false, trailLife = 0.8, trailWidth = 1, trailStyle = "Fade",
		murdMat = "Same", sheriffMat = "Same", murdBox = "Same", limits = false, boxMaxDist = 0, nameMaxDist = 0,
		chamsMaxDist = 0, skelMaxDist = 0, distScale = false, nameIcon = false, weaponStyle = "Icon", infoBg = false,
		infoBgAlpha = 55, chamsEdgeRole = true, infoLayout = "Under Box", infoFont = "Same", infoCase = "Normal",
		textShadow = false, textOutlineAlpha = 60, outlineInner = false, chamsOverlay = false, markerPos = "Around Center",
		chamsHiddenDark = 30,
	}
	settings.on = configuration.rolesp and configuration.rolesp.on and true or false
	return settings
end

local EspText = {}
local ESP_ROLE_SHORT = {Murderer = "M", Sheriff = "S", Hero = "H", Innocent = "I"}

function EspText.create()
	return {upper = {}, upperCount = 0, distances = {}, distanceCount = 0,
		names = setmetatable({}, {__mode = "k"})}
end

function EspText.upper(state, value)
	if state.upperCount > 3000 then state.upper, state.upperCount = {}, 0 end
	local cached = state.upper[value]
	if cached then return cached end

	local result = string.upper(value)
	if string.find(result, "[\208\209]") then
		local characters = {}
		for _, code in utf8.codes(result) do
			if code >= 1072 and code <= 1103 then code -= 32 end
			if code == 1105 then code = 1025 end
			table.insert(characters, utf8.char(code))
		end
		result = table.concat(characters)
	end
	state.upper[value] = result
	state.upperCount += 1
	return result
end

function EspText.case(state, value, mode)
	if mode == "UPPER" then return EspText.upper(state, value) end
	if mode == "lower" then return string.lower(value) end
	return value
end

function EspText.role(state, role, mode, translate)
	local label = translate(role)
	if mode == "Short" then return ESP_ROLE_SHORT[role] or label:sub(1, 1) end
	if mode == "Upper" then return EspText.upper(state, label) end
	return label
end

function EspText.distance(state, distance, unit)
	local value = math.max(tonumber(distance) or 0, 0)
	local key = math.floor(value + 0.5)
	if unit == "Meters" then
		local meters = value * 0.28
		key = meters < 10 and -(math.floor(meters * 10 + 0.5) + 1) or math.floor(meters + 0.5) + 1000000
	end
	if state.distanceCount > 4000 then state.distances, state.distanceCount = {}, 0 end
	if state.distances[key] then return state.distances[key] end

	local text = tostring(math.floor(value + 0.5)) .. " st"
	if unit == "Meters" then
		local meters = value * 0.28
		text = meters < 10 and string.format("%.1f m", meters) or tostring(math.floor(meters + 0.5)) .. " m"
	end
	state.distances[key] = text
	state.distanceCount += 1
	return text
end

function EspText.clean(value)
	if type(value) ~= "string" then return "" end
	return (value:gsub("[%z\1-\31\127]", " "):gsub("^%s+", ""):gsub("%s+$", ""))
end

function EspText.name(state, player, mode)
	local name, display = player.Name, player.DisplayName
	local cached = state.names[player]
	if cached and cached.name == name and cached.display == display and cached.mode == mode then
		return cached.main, cached.second
	end

	local username, displayName = EspText.clean(name), EspText.clean(display)
	if username == "" then username = displayName end
	if username == "" then username = "Player" end
	if displayName == "" then displayName = username end
	local main, second = username, ""
	if mode == "Display name" then main = displayName end
	if mode == "Both" then
		main = displayName
		if displayName ~= username then second = "@" .. username end
	end
	state.names[player] = {name = name, display = display, mode = mode, main = main, second = second}
	return main, second
end

local EspColor = {}
local ESP_ROLE_COLORS = {Murderer = "murdererColour", Sheriff = "sheriffColour", Hero = "heroColour", Innocent = "innocentColour"}

function EspColor.create(environment, settings)
	return {environment = environment, settings = settings, white = environment.Color3.new(1, 1, 1),
		black = environment.Color3.new(0, 0, 0)}
end

function EspColor.key(color)
	return math.floor(color.R * 255 + 0.5) * 65536 + math.floor(color.G * 255 + 0.5) * 256 + math.floor(color.B * 255 + 0.5)
end

function EspColor.tone(state, color)
	local settings = state.settings
	local brightness, saturation = (settings.brightness or 100) / 100, (settings.saturation or 100) / 100
	if brightness == 1 and saturation == 1 then return color end
	if not state.tones or state.brightness ~= brightness or state.saturation ~= saturation then
		state.tones, state.brightness, state.saturation, state.count = {}, brightness, saturation, 0
	end

	local cache, key = state.tones, EspColor.key(color)
	if cache[key] then return cache[key] end
	local hue, sat, value = color:ToHSV()
	local adjusted = value * brightness
	local result = state.environment.Color3.fromHSV(hue, math.clamp(sat * saturation, 0, 1), math.clamp(adjusted, 0, 1))
	if adjusted > 1 then result = result:Lerp(state.white, math.clamp((adjusted - 1) * 0.6, 0, 0.6)) end
	state.count += 1
	if state.count > 4096 then state.tones = nil end
	cache[key] = result
	return result
end

function EspColor.ink(state, source, custom, color)
	if source == "Custom" then return EspColor.tone(state, custom or state.white) end
	if source == "White" then return EspColor.tone(state, state.white) end
	if source == "Light" then return color:Lerp(state.white, 0.45) end
	if source == "Dark" then return color:Lerp(state.black, 0.5) end
	return color
end

function EspColor.roleBase(state, role)
	return state.settings[ESP_ROLE_COLORS[role] or "noRoleColour"]
end

function EspColor.role(state, role)
	return EspColor.tone(state, EspColor.roleBase(state, role))
end

function EspColor.select(state, role, isVisible, distance)
	local settings, environment = state.settings, state.environment
	local color = EspColor.roleBase(state, role)
	if settings.colorMode == "Rainbow" then
		local hue = environment.os.clock() * 0.09 * (settings.rainbowSpeed or 1) % 1
		color = environment.Color3.fromHSV(hue, math.clamp((settings.rainbowSat or 65) / 100, 0, 1), 1)
	end
	if settings.colorMode == "Custom" then color = settings.customColour end
	if settings.colorMode == "Distance" then
		color = settings.nearColour:Lerp(settings.farColour, math.clamp((distance or 0) / math.max(settings.maxDist, 1), 0, 1))
	end
	if settings.colorMode == "Visibility" then color = isVisible and settings.seenColour or settings.hiddenColour end
	if settings.visCheck and settings.dimHidden and not isVisible and settings.hiddenStyle == "Grey" then color = settings.hiddenColour end
	return EspColor.tone(state, color)
end

function EspColor.cham(state, color)
	local brightness = (state.settings.chamsBright or 100) / 100
	if brightness > 1 then return color:Lerp(state.white, math.clamp((brightness - 1) * 0.6, 0, 0.6)) end
	if brightness < 1 then return color:Lerp(state.black, math.clamp(1 - brightness, 0, 0.85)) end
	return color
end

function EspColor.health(state, ratio)
	return state.settings.healthLow:Lerp(state.settings.healthHigh, math.clamp(ratio, 0, 1))
end

local EspBox = {}

function EspBox.create(context, parent, playerId)
	local environment = context.environment
	local function create(class, properties, owner)
		local object = environment.Instance.new(class)
		for key, value in properties do object[key] = value end
		object.Parent = owner
		return object
	end
	local function frame(owner, name, level)
		return create("Frame", {Name = name, BackgroundTransparency = 1, BorderSizePixel = 0,
			Active = false, Visible = false, ZIndex = level}, owner)
	end
	local function stroke(owner, thickness)
		return create("UIStroke", {Thickness = thickness, Color = environment.Color3.new(0, 0, 0),
			ApplyStrokeMode = environment.Enum.ApplyStrokeMode.Border, Transparency = 1}, owner)
	end
	local layer = frame(parent, "Player_" .. tostring(playerId), 2)
	layer.Size = environment.UDim2.fromScale(1, 1)
	local box, glow, outer = frame(layer, "Box", 3), frame(layer, "Glow", 2), frame(layer, "BoxOutline", 2)
	local edge = stroke(box, 1.5)
	local result = {layer = layer, box = box, edge = edge, glow = glow, outer = outer,
		fillGradient = create("UIGradient", {Rotation = 90}, box),
		edgeGradient = create("UIGradient", {Rotation = 90}, edge),
		round = create("UICorner", {CornerRadius = environment.UDim.new(0, 0)}, box),
		glowStroke = stroke(glow, 6), glowRound = create("UICorner", {}, glow),
		outerStroke = stroke(outer, 3.5), outerRound = create("UICorner", {}, outer),
		corners = {}, cornerGlow = {}, cornerEdge = {}}
	result.make = create
	result.frame = frame
	result.stroke = stroke
	EspBox.grow(context, result, 8)
	return result
end

function EspBox.grow(context, box, count)
	for index = #box.corners + 1, count do
		local function line(name, level)
			local frame = box.frame(box.layer, name, level)
			frame.AnchorPoint = context.environment.Vector2.new(0.5, 0.5)
			return {frame = frame, stroke = box.stroke(frame, 1)}
		end
		box.corners[index] = line("Corner" .. index, 4)
		box.cornerGlow[index] = line("CornerGlow" .. index, 2)
		box.cornerEdge[index] = box.frame(box.layer, "CornerEdge" .. index, 3)
	end
end

function EspBox.hideSegments(box, first)
	for index = first, #box.corners do
		box.corners[index].frame.Visible = false
		box.cornerGlow[index].frame.Visible = false
		box.cornerEdge[index].Visible = false
	end
end

function EspBox.sequence(context, first, second)
	local state, settings = context.colors, context.settings
	local isRoleFade = settings.boxGradStyle == "Role Fade"
	local key = isRoleFade and -EspColor.key(first) - 1 or EspColor.key(first) * 16777216 + EspColor.key(second)
	context.boxSequences = context.boxSequences or {}
	if context.boxSequences[key] then return context.boxSequences[key] end

	local colorSequence = context.environment.ColorSequence
	local result = isRoleFade and colorSequence.new(first:Lerp(state.white, 0.25), first) or colorSequence.new(first, second)
	context.boxSequenceCount = (context.boxSequenceCount or 0) + 1
	if context.boxSequenceCount > 512 then context.boxSequences, context.boxSequenceCount = {}, 0 end
	context.boxSequences[key] = result
	return result
end

function EspBox.animation(context, player)
	local settings = context.settings
	if settings.boxAnim ~= "Pulse" and settings.boxAnim ~= "Breathe" then return 1, 0 end
	local time = context.environment.os.clock() * (settings.boxAnimSpeed or 1) + (player and player.UserId % 89 * 0.37 or 0)
	if settings.boxAnim == "Pulse" then return 0.7 + 0.3 * (0.5 + 0.5 * math.sin(time * 4.2)), 0 end
	return 1, 0.5 + 0.5 * math.sin(time * 2.6)
end

function EspBox.inner(context, box)
	if box.inner then return box.inner end
	box.inner = box.frame(box.layer, "BoxInner", 3)
	box.innerStroke = box.stroke(box.inner, 1)
	box.innerRound = box.make("UICorner", {}, box.inner)
	box.innerGrad = box.make("UIGradient", {Rotation = 90}, box.innerStroke)
	return box.inner
end

function EspBox.quantize(value)
	return math.floor(value * 200 + 0.5) / 200
end

function EspBox.fill(context, box, base, gradient, opacity)
	local environment, settings = context.environment, context.settings
	local color = EspColor.ink(context.colors, settings.fillColMode, settings.fillCol, base)
	local second = settings.gradient and gradient or color
	local key = (settings.gradient and 1 or 2) * 1000000000000000 + EspColor.key(color) * 16777216 + EspColor.key(second)
	if box.fillKey ~= key or box.fillGS ~= settings.boxGradStyle then
		box.fillKey, box.fillGS = key, settings.boxGradStyle
		box.fillGradient.Color = settings.gradient and EspBox.sequence(context, color, second) or environment.ColorSequence.new(color)
	end
	local style = settings.fillStyle or "Solid"
	if box.fillStyleOn == style then return end
	box.fillStyleOn = style
	local sequence = environment.NumberSequence
	local fills = {Solid = function() return sequence.new(0) end,
		["Fade Down"] = function() return sequence.new(0, 1) end,
		["Fade Up"] = function() return sequence.new(1, 0) end}
	box.fillGradient.Transparency = (fills[style] or fills.Solid)()
	box.fillGradient.Rotation = 90
end

function EspBox.edge(context, box, base, gradient, opacity, thickness, rotation)
	local environment, settings = context.environment, context.settings
	local key = EspColor.key(base) * 16777216 + EspColor.key(gradient)
	if box.edgeKey ~= key or box.edgeGS ~= settings.boxGradStyle or box.edgeG ~= settings.gradient then
		box.edgeKey, box.edgeGS, box.edgeG = key, settings.boxGradStyle, settings.gradient
		box.edgeGradient.Color = settings.gradient and EspBox.sequence(context, base, gradient) or environment.ColorSequence.new(base)
		if box.innerGrad then box.innerGrad.Color = box.edgeGradient.Color end
	end
	local fade = settings.gradient and settings.boxGradStyle == "Role Fade"
	if box.edgeFade ~= fade then
		box.edgeFade = fade
		box.edgeGradient.Transparency = fade and environment.NumberSequence.new(0, 0.7) or environment.NumberSequence.new(0)
	end
	box.edgeGradient.Rotation = rotation
	box.edge.Color = context.colors.white
	box.edge.Thickness = math.clamp(thickness, 0.5, 8)
	box.edge.Transparency = EspBox.quantize(1 - opacity)
end

function EspBox.innerStyle(context, box, rect, style, opacity, thickness, rotation, hasOutline)
	local environment, settings = context.environment, context.settings
	local offset, stroke = 0, box.innerStroke
	if style == "Double" then
		EspBox.inner(context, box)
		stroke = box.innerStroke
		box.innerGrad.Color = box.edgeGradient.Color
		offset = math.floor(thickness + 2.5)
		box.innerRound.CornerRadius = environment.UDim.new(0, math.max(0, math.clamp(settings.boxRound, 0, 20) - offset))
		stroke.Color = context.colors.white
		stroke.Thickness = math.max(1, thickness * 0.6)
		stroke.Transparency = EspBox.quantize(1 - opacity * 0.45)
		box.innerGrad.Rotation = rotation
	end
	if style ~= "Double" and hasOutline then
		EspBox.inner(context, box)
		stroke = box.innerStroke
		box.innerGrad.Color = environment.ColorSequence.new(context.colors.white)
		offset = math.max(1, math.floor((settings.outlineSize or 1) * 0.5 + 0.5))
		local radius = style == "Rounded" and math.max(0, math.clamp(settings.boxRound, 0, 20) - offset) or 0
		box.innerRound.CornerRadius = environment.UDim.new(0, radius)
		stroke.Color = settings.outlineCol or context.colors.black
		stroke.Thickness = offset
		stroke.Transparency = EspBox.quantize(1 - opacity * math.clamp((settings.outlineAlpha or 65) / 100, 0, 1))
	end
	box.inner.Position = environment.UDim2.fromOffset(rect.x + offset, rect.y + offset)
	box.inner.Size = environment.UDim2.fromOffset(math.max(2, rect.w - offset * 2), math.max(2, rect.h - offset * 2))
	box.inner.Visible = true
end

function EspBox.segments(context, box, rectangle, thickness, style)
	local x, y, width, height = rectangle.x, rectangle.y, rectangle.w, rectangle.h
	local line = math.max(1, math.floor(thickness + 0.5))
	local length = math.min(math.max(math.min(width, height) * math.clamp(context.settings.cornerSize, 5, 50) / 100, 4), math.min(width, height) * 0.45)
	length = math.max(line + 1, math.floor(length + 0.5))
	local segments
	if style == "Corners" then
		segments = {{x, y, length, line}, {x, y, line, length}, {x + width - length, y, length, line},
			{x + width - line, y, line, length}, {x, y + height - line, length, line}, {x, y + height - length, line, length},
			{x + width - length, y + height - line, length, line}, {x + width - line, y + height - length, line, length}}
	end
	if style == "Brackets" then
		local endWidth = math.max(line + 1, math.floor(math.min(length, width * 0.3) + 0.5))
		segments = {{x, y, line, height}, {x, y, endWidth, line}, {x, y + height - line, endWidth, line},
			{x + width - line, y, line, height}, {x + width - endWidth, y, endWidth, line},
			{x + width - endWidth, y + height - line, endWidth, line}}
	end
	box.segs = box.segs or {}
	for index, values in segments do
		local entry = box.segs[index] or {}
		entry[1], entry[2], entry[3], entry[4] = values[1], values[2], values[3], values[4]
		box.segs[index] = entry
	end
	EspBox.grow(context, box, #segments)
	EspBox.hideSegments(box, #segments + 1)
end

function EspBox.draw(context, box, rectangle, color, alpha, player, focus)
	local environment, settings = context.environment, context.settings
	local style = settings.boxStyle or "Corners"
	if box.role == "Murderer" and settings.murdBox and settings.murdBox ~= "Same" then style = settings.murdBox end
	local isVisible = settings.box == true and not box.boxOff
	local segmented = style == "Corners" or style == "Brackets"
	local full = isVisible and not segmented
	local glow = settings.boxGlow == true or focus == true
	local innerOutline = full and style ~= "Double" and settings.outline == true and settings.outlineInner == true
	if not isVisible or not segmented then EspBox.hideSegments(box, 1) end
	if box.inner and not (full and (style == "Double" or innerOutline)) then box.inner.Visible = false end
	box.box.Visible, box.glow.Visible, box.outer.Visible = isVisible, full and glow, full and settings.outline
	if not isVisible then return end

	local animation, expansion = EspBox.animation(context, player)
	local extra = expansion > 0 and math.floor(expansion * 2 + 0.5) or 0
	local padding = math.floor(tonumber(settings.boxPad) or 0)
	local rect = {x = rectangle.x - extra, y = rectangle.y - extra, w = rectangle.w + extra * 2, h = rectangle.h + extra * 2}
	if padding ~= 0 then
		rect = {x = rect.x - padding, y = rect.y - padding, w = math.max(4, rect.w + padding * 2), h = math.max(4, rect.h + padding * 2)}
	end
	local opacity = alpha * animation
	local base = EspColor.ink(context.colors, settings.boxColMode, settings.boxCol, color)
	local gradient = settings.gradient and EspColor.tone(context.colors, settings.gradientColour) or base
	local thickness = (tonumber(settings.boxThickness) or 1) * (settings.lineScale or 100) / 100 * (context.lineWidthFactor or 1)
	if focus then thickness *= (settings.focusScale or 160) / 100 end
	local position, size = environment.UDim2.fromOffset(rect.x, rect.y), environment.UDim2.fromOffset(rect.w, rect.h)
	box.box.Position, box.box.Size = position, size
	local radius = (style == "Rounded" or style == "Double") and math.clamp(settings.boxRound, 0, 20) or 0
	local corner = environment.UDim.new(0, radius)
	box.round.CornerRadius, box.glowRound.CornerRadius, box.outerRound.CornerRadius = corner, corner, corner
	local rotation = math.floor(settings.boxGradAngle or 90) % 360
	if full and settings.outline then
		box.outer.Position, box.outer.Size = position, size
		box.outerStroke.Color = settings.outlineCol or context.colors.black
		box.outerStroke.Thickness = thickness + (settings.outlineSize or 2)
		box.outerStroke.Transparency = EspBox.quantize(1 - opacity * math.clamp((settings.outlineAlpha or 65) / 100, 0, 1))
	end
	box.box.BackgroundColor3 = context.colors.white
	box.box.BackgroundTransparency = settings.boxFill and EspBox.quantize(1 - math.clamp(settings.boxFillAlpha / 100, 0, 1) * opacity) or 1
	if settings.boxFill then EspBox.fill(context, box, base, gradient, opacity) end
	if full then EspBox.edge(context, box, base, gradient, opacity, thickness, rotation) end
	if not full then box.edge.Transparency = 1 end
	if full and glow then EspBox.glow(context, box, position, size, base, opacity, thickness, focus) end
	if full and (style == "Double" or innerOutline) then EspBox.innerStyle(context, box, rect, style, opacity, thickness, rotation, innerOutline) end
	if segmented then EspBox.segments(context, box, rect, thickness, style) end
end

function EspBox.glow(context, box, position, size, base, opacity, thickness, focus)
	local settings = context.settings
	local pulse = settings.pulse and 0.72 + math.sin(context.environment.os.clock() * settings.pulseSpeed * math.pi * 2) * 0.28 or 1
	if focus and not settings.pulse then pulse = 0.75 + math.sin(context.environment.os.clock() * 5) * 0.25 end
	local strength = math.clamp(settings.glowStrength / 100, 0, 0.6)
	if focus and not settings.boxGlow then strength = 0.3 end
	box.glow.Position, box.glow.Size = position, size
	box.glowStroke.Color = EspColor.ink(context.colors, settings.glowColMode, settings.glowCol, base)
	box.glowStroke.Thickness = thickness + (settings.glowSize or 5) * (settings.lineScale or 100) / 100 * (context.lineWidthFactor or 1)
	box.glowStroke.Transparency = EspBox.quantize(1 - opacity * strength * pulse)
end

local EspRole = {}
local ESP_ROLE_MAP = {
	Zombie = "Murderer", Vampire = "Murderer", Freezer = "Murderer",
	Survivor = "Innocent", Hunter = "Innocent", Villager = "Innocent", Runner = "Innocent",
}
local ESP_UNDEAD = {Zombie = true, Vampire = true, Freezer = true}
local ESP_ROLE_FIELDS = {Murderer = "murderer", Sheriff = "sheriff", Hero = "hero", Innocent = "innocent"}

function EspRole.create(clock)
	return {clock = clock, heroes = setmetatable({}, {__mode = "k"}), weapons = setmetatable({}, {__mode = "k"}),
		parts = setmetatable({}, {__mode = "k"})}
end

function EspRole.of(state, player, roles)
	if type(player) == "table" then return player.FakeRole end

	local data = roles and roles[player.Name]
	local role = data and data.Role
	if data and (data.Dead == true or data.Killed == true) and not ESP_UNDEAD[role] then role = nil end
	role = ESP_ROLE_MAP[role] or role
	if role == "Innocent" and EspRole.hasHeroGun(state, player) then role = "Hero" end
	if not ESP_ROLE_FIELDS[role] then return nil end
	return role
end

function EspRole.hasHeroGun(state, player)
	local now, hero = state.clock(), state.heroes[player]
	if not hero then
		hero = {at = -1, hasGun = false}
		state.heroes[player] = hero
	end
	if now - hero.at > 0.12 then
		hero.at = now
		local character, backpack = player.Character, player:FindFirstChild("Backpack")
		hero.hasGun = not not (character and character:FindFirstChild("Gun") or backpack and backpack:FindFirstChild("Gun"))
	end
	return hero.hasGun
end

function EspRole.shown(settings, role)
	return settings[ESP_ROLE_FIELDS[role] or "noRole"]
end

function EspRole.weaponScan(player, role)
	local character, backpack = player.Character, player:FindFirstChild("Backpack")
	if character and character:FindFirstChild("Knife") then return "Knife", true end
	if character and character:FindFirstChild("Gun") then return "Gun", true end
	if backpack and backpack:FindFirstChild("Knife") then return "Knife", false end
	if backpack and backpack:FindFirstChild("Gun") then return "Gun", false end
	if role == "Murderer" then return "Knife", false end
	if role == "Sheriff" or role == "Hero" then return "Gun", false end
	return nil, false
end

function EspRole.weaponOf(state, player, role)
	local now, cached, character = state.clock(), state.weapons[player], player.Character
	if cached and now - cached.at < 0.15 and cached.role == role and cached.character == character then
		return cached.name, cached.equipped
	end

	local name, equipped = EspRole.weaponScan(player, role)
	state.weapons[player] = {at = now, role = role, character = character, name = name, equipped = equipped}
	return name, equipped
end

function EspRole.partsOf(state, character)
	local now, parts = state.clock(), state.parts[character]
	if parts and parts.root and parts.hum then
		if now - parts.at < 1 and parts.root.Parent == character and parts.hum.Parent == character then return parts end
	end
	if parts and (not parts.root or not parts.hum) and now - parts.at < 0.25 then return parts end
	parts = parts or {}
	parts.at = now
	parts.hum = character:FindFirstChildOfClass("Humanoid")
	parts.root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	parts.head = character:FindFirstChild("Head") or parts.root
	state.parts[character] = parts
	return parts
end

local EspProjection = {}

function EspProjection.create(environment)
	return {environment = environment, bounds = setmetatable({}, {__mode = "k"}), partKinds = {}}
end

function EspProjection.bounds(state, character, root)
	local now, bounds = state.environment.os.clock(), state.bounds[character]
	if bounds and now - bounds.at <= 0.15 then return bounds.top, bounds.bottom end

	local top, bottom
	for _, part in character:GetChildren() do
		local isPart = state.partKinds[part.ClassName]
		if isPart == nil then
			isPart = part:IsA("BasePart")
			state.partKinds[part.ClassName] = isPart
		end
		if not isPart then continue end
		local half, position = part.Size.Y * 0.5, part.Position.Y
		local high, low = position + half, position - half
		top = top and math.max(top, high) or high
		bottom = bottom and math.min(bottom, low) or low
	end

	local y = root.Position.Y
	bounds = {at = now, top = (top or y + 3) - y, bottom = (bottom or y - 3) - y}
	state.bounds[character] = bounds
	return bounds.top, bounds.bottom
end

function EspProjection.point(state, camera, position)
	local projection = state.projection
	if projection and projection.enabled then
		local point = projection.frame:PointToObjectSpace(position)
		local depth = -point.Z
		if depth > 0.08 then
			return state.environment.Vector3.new(projection.centerX + point.X / depth * projection.focal,
				projection.centerY - point.Y / depth * projection.focal, depth)
		end
	end
	return camera:WorldToViewportPoint(position)
end

function EspProjection.project(state, character, root, camera, boxWidth)
	local top, bottom = EspProjection.bounds(state, character, root)
	local position = root.Position
	local vector = state.environment.Vector3
	local upper = EspProjection.point(state, camera, vector.new(position.X, position.Y + top + 0.12, position.Z))
	local lower = EspProjection.point(state, camera, vector.new(position.X, position.Y + bottom - 0.08, position.Z))
	if upper.Z <= 0.08 or lower.Z <= 0.08 then return nil end

	local viewport = camera.ViewportSize
	local height = math.abs(lower.Y - upper.Y)
	if height < 2 or height > viewport.Y * 4 then return nil end
	local width = height * math.clamp((boxWidth or 50) / 100, 0.2, 1)
	local x, y = (upper.X + lower.X) * 0.5 - width * 0.5, math.min(upper.Y, lower.Y)
	if x + width < 0 or x > viewport.X or y + height < 0 or y > viewport.Y then return nil end
	if width < 12 then x, width = x - (12 - width) * 0.5, 12 end
	if height < 22 then y, height = y - (22 - height) * 0.5, 22 end
	return {x = x, y = y, w = width, h = height}
end

function EspProjection.smooth(record, rectangle, viewport, smooth, delta, center)
	local factor = math.clamp(smooth, 0, 95) / 100
	local alpha = factor > 0 and 1 - factor ^ (math.clamp(delta or 1 / 60, 0.001, 0.1) * 60) or 1
	center = center or {X = rectangle.x + rectangle.w * 0.5, Y = rectangle.y + rectangle.h * 0.5}
	local relative = {x = rectangle.x - center.X, y = rectangle.y - center.Y, w = rectangle.w, h = rectangle.h}
	local previous = record.rect and record.rel
	if previous then
		local difference = math.abs(relative.x - previous.x) + math.abs(relative.y - previous.y)
			+ math.abs(relative.w - previous.w) + math.abs(relative.h - previous.h)
		if difference < math.max(viewport.X, viewport.Y) * 0.35 then
			for _, key in {"x", "y", "w", "h"} do relative[key] = previous[key] + (relative[key] - previous[key]) * alpha end
		end
	end

	record.rel = relative
	record.rect = {x = center.X + relative.x, y = center.Y + relative.y, w = relative.w, h = relative.h}
	local value = record.rect
	return {x = math.floor(value.x + 0.5), y = math.floor(value.y + 0.5),
		w = math.max(1, math.floor(value.w + 0.5)), h = math.max(1, math.floor(value.h + 0.5))}
end

function EspProjection.inView(state, camera, position)
	if (position - camera.CFrame.Position).Magnitude <= 12 then return true end
	local point, viewport = EspProjection.point(state, camera, position), camera.ViewportSize
	local marginX, marginY = viewport.X * 0.35, viewport.Y * 0.35
	return not (point.Z < -6 or point.X < -marginX or point.X > viewport.X + marginX
		or point.Y < -marginY or point.Y > viewport.Y + marginY), point
end

function EspProjection.alpha(settings, distance, isVisible)
	local alpha = settings.visCheck and settings.dimHidden and not isVisible and settings.hiddenStyle ~= "Grey" and 0.72 or 1
	if settings.fade then
		local start = settings.maxDist * math.clamp(settings.fadeFrom, 10, 95) / 100
		if distance > start then alpha *= math.clamp(1 - (distance - start) / math.max(settings.maxDist - start, 1), 0.45, 1) end
	end
	return alpha * math.clamp((settings.opacity or 100) / 100, 0.05, 1)
end

function EspProjection.visible(context, origin, target, character)
	local environment, workspace = context.environment, context.workspace
	local parameters = environment.RaycastParams.new()
	parameters.FilterType = environment.Enum.RaycastFilterType.Exclude
	local ignored = {character, workspace.CurrentCamera}
	if context.player.Character then table.insert(ignored, context.player.Character) end
	parameters.FilterDescendantsInstances = ignored
	parameters.IgnoreWater = true
	local direction = target.Position - origin
	if direction.Magnitude < 0.05 then return true end

	for _ = 1, 6 do
		local hit = workspace:Raycast(origin, direction, parameters)
		if not hit then return true end
		if hit.Instance.Transparency < 0.3 then return false end
		table.insert(ignored, hit.Instance)
		parameters.FilterDescendantsInstances = ignored
	end
	return false
end

local EspLabel = {}
local ESP_FONT_ENUM = {
	Fredoka = "FredokaOne", ["Luckiest Guy"] = "LuckiestGuy", Bangers = "Bangers", Cartoon = "Cartoon", Arcade = "Arcade",
	["Sci-Fi"] = "SciFi", Michroma = "Michroma", Jura = "Jura", Sarpanch = "Sarpanch", Oswald = "Oswald", Ubuntu = "Ubuntu",
	Nunito = "Nunito", Roboto = "Roboto", ["Roboto Condensed"] = "RobotoCondensed", Titillium = "TitilliumWeb",
	["Builder Sans"] = "BuilderSans", Arimo = "Arimo", Highway = "Highway", ["Denk One"] = "DenkOne", Creepster = "Creepster",
	["Permanent Marker"] = "PermanentMarker", Kalam = "Kalam", ["Indie Flower"] = "IndieFlower", ["Patrick Hand"] = "PatrickHand",
	Amatic = "AmaticSC", ["Special Elite"] = "SpecialElite", ["Grenze Gotisch"] = "GrenzeGotisch", Bodoni = "Bodoni",
	Merriweather = "Merriweather", Garamond = "Garamond", Antique = "Antique", Fantasy = "Fantasy", Montserrat = "Montserrat",
	Code = "RobotoMono", ["Source Sans"] = "SourceSans",
}

function EspLabel.root(state)
	if state.labelGui and state.labelGui.Parent then return state.labelGui end
	local context, environment = state.context, state.context.environment
	local holder = context.coreGui
	if not holder or not holder.Parent then holder = context.player:FindFirstChildOfClass("PlayerGui") end
	if not holder then return nil end
	local gui = environment.Instance.new("ScreenGui")
	gui.Name, gui.IgnoreGuiInset, gui.ResetOnSpawn = "PulseESP2Text", true, false
	gui.DisplayOrder, gui.ZIndexBehavior = 10, environment.Enum.ZIndexBehavior.Sibling
	gui.Parent = holder
	state.labelGui, state.labels = gui, {}
	return gui
end

function EspLabel.create(state, player)
	local gui = EspLabel.root(state)
	if not gui then return nil end
	local environment = state.context.environment
	local function create(class, properties, parent)
		local object = environment.Instance.new(class)
		for key, value in properties do object[key] = value end
		object.Parent = parent
		return object
	end
	local function frame(name)
		return create("Frame", {Name = name, BorderSizePixel = 0, BackgroundTransparency = 1,
			Active = false, Visible = false}, gui)
	end
	local function label(parent, name)
		local enum = environment.Enum
		return create("TextLabel", {Name = name, BackgroundTransparency = 1, BorderSizePixel = 0, Active = false,
			RichText = false, TextScaled = false, TextWrapped = false, TextTruncate = enum.TextTruncate.AtEnd,
			TextXAlignment = enum.TextXAlignment.Center, TextYAlignment = enum.TextYAlignment.Center,
			TextStrokeColor3 = environment.Color3.fromRGB(5, 8, 13), Text = "", ZIndex = 3}, parent)
	end
	local top, bottom = frame("Name_" .. tostring(player.UserId)), frame("Info_" .. tostring(player.UserId))
	local weaponShadow = create("ImageLabel", {Name = "WeaponShadow", BackgroundTransparency = 1, BorderSizePixel = 0,
		ScaleType = environment.Enum.ScaleType.Fit, ImageColor3 = state.colors.black, Visible = false, ZIndex = 2}, bottom)
	local weapon = create("ImageLabel", {Name = "Weapon", BackgroundTransparency = 1, BorderSizePixel = 0,
		ScaleType = environment.Enum.ScaleType.Fit, Visible = false, ZIndex = 3}, bottom)
	local result = {top = top, bottom = bottom, name = label(top, "Name"), handle = label(top, "Username"),
		role = label(bottom, "Role"), distance = label(bottom, "Distance"), weaponText = label(bottom, "wtext"),
		weapon = weapon, weaponShadow = weaponShadow,
		measures = {}, createLabel = label}
	state.labels[player] = result
	return result
end

function EspLabel.font(state, name, weight)
	local environment = state.context.environment
	local enum, font = environment.Enum, environment.Font
	state.fontFaces = state.fontFaces or {}
	state.fontFaces[name] = state.fontFaces[name] or {}
	local key = weight or enum.FontWeight.Medium
	if state.fontFaces[name][key] then return state.fontFaces[name][key] end

	local families = {Gotham = "GothamSSm", GothamSSm = "GothamSSm", Code = "RobotoMono",
		["Source Sans"] = "SourceSansPro", Montserrat = "Montserrat"}
	local family, result = families[name], nil
	if not family and ESP_FONT_ENUM[name] then
		local ok, face = pcall(function() return font.fromEnum(enum.Font[ESP_FONT_ENUM[name]]) end)
		if ok and face then
			result = face
			if weight then
				local made, weighted = pcall(font.new, face.Family, weight)
				if made and weighted then result = weighted end
			end
		end
	end
	if not result and (family or not ESP_FONT_ENUM[name]) then
		local ok, face = pcall(font.new, "rbxasset://fonts/families/" .. (family or "GothamSSm") .. ".json", key)
		if ok then result = face end
	end
	result = result or font.fromEnum(enum.Font.GothamMedium)
	state.fontFaces[name][key] = result
	return result
end

function EspLabel.metricFont(state, name)
	local enum = state.context.environment.Enum
	local ok, value = pcall(function()
		local id = ESP_FONT_ENUM[name]
		return id and enum.Font[id]
	end)
	return ok and value or enum.Font.GothamMedium
end

function EspLabel.measure(state, labels, key, text, size, font, limit)
	local cached = labels.measures[key]
	if cached and cached.text == text and cached.size == size and cached.font == font and cached.limit == limit then
		return cached.width, cached.height
	end
	local context, environment = state.context, state.context.environment
	local ok, result = pcall(function()
		return context.textService:GetTextSize(text, size, font, environment.Vector2.new(100000, 100000))
	end)
	local width = ok and math.ceil(result.X) or math.min(limit, #text * size * 0.55)
	local height = ok and math.ceil(result.Y) or size + 3
	width, height = math.min(math.max(width + 2, 1), limit), math.max(height + 2, size + 3)
	labels.measures[key] = {text = text, size = size, font = font, limit = limit, width = width, height = height}
	return width, height
end

function EspLabel.position(state, frame, rect, width, height, y)
	local environment = state.context.environment
	local viewport = state.viewport
	local center = rect.x + rect.w * 0.5
	local x = math.clamp(center - width * 0.5, 4, math.max(4, viewport.X - 4 - width))
	y = math.clamp(y, 4, math.max(4, viewport.Y - 4 - height))
	frame.Position = environment.UDim2.fromOffset(math.floor(x + 0.5), math.floor(y + 0.5))
	frame.Size, frame.Visible = environment.UDim2.fromOffset(width, height), true
	return y
end

function EspLabel.text(state, label, options)
	local environment, settings = state.context.environment, state.settings
	label.Visible = options.text ~= ""
	if options.text == "" then return end
	label.Text, label.FontFace, label.TextSize = options.text, options.font, options.size
	label.TextColor3, label.TextTransparency = options.color, 1 - options.opacity
	local outline = settings.textOutline == false and 1 or EspBox.quantize(1 - options.opacity * math.clamp((tonumber(settings.textOutlineAlpha) or 60) / 100, 0, 1))
	label.TextStrokeTransparency = outline
	label.Position = environment.UDim2.fromOffset(options.x, options.y)
	label.Size = environment.UDim2.fromOffset(options.width, options.height)
end

function EspLabel.name(state, labels, player, rectangle, infoY, style)
	local settings, environment = state.settings, state.context.environment
	if not settings.name then labels.top.Visible = false; return infoY end
	local main, handle = EspText.name(state.text, player, settings.nameMode)
	main = EspText.case(state.text, main, settings.nameCase)
	if handle ~= "" then handle = EspText.case(state.text, handle, settings.nameCase) end
	local available = math.max(1, style.limit - 4)
	local nameWidth, nameHeight = EspLabel.measure(state, labels, "name", main, style.nameSize, style.metricFont, available)
	local handleWidth, handleHeight = 0, 0
	if handle ~= "" then handleWidth, handleHeight = EspLabel.measure(state, labels, "handle", handle, style.infoSize, style.metricFont, available) end
	local width, height = math.min(style.limit, math.max(nameWidth, handleWidth) + 4), nameHeight + handleHeight
	local y = rectangle.y - (tonumber(settings.nameOffset) or 3) - height
	if settings.namePos == "Below" then y = infoY end
	local placed = EspLabel.position(state, labels.top, rectangle, width, height, y)
	labels.top.BackgroundColor3 = EspColor.tone(state.colors, settings.plateColour)
	labels.top.BackgroundTransparency = 1
	local weights = environment.Enum.FontWeight
	local font = EspLabel.font(state, settings.textFont, weights[settings.nameWeight or "SemiBold"] or weights.SemiBold)
	EspLabel.text(state, labels.name, {text = main, font = font, size = style.nameSize, color = style.nameColor,
		opacity = style.opacity, x = 2, y = 0, width = math.max(1, width - 4), height = nameHeight})
	EspLabel.text(state, labels.handle, {text = handle, font = EspLabel.font(state, settings.textFont, weights.Medium),
		size = style.infoSize, color = style.infoColor, opacity = style.opacity, x = 2, y = nameHeight,
		width = math.max(1, width - 4), height = handleHeight})
	if settings.namePos == "Below" then return placed + height + 2 end
	return infoY
end

function EspLabel.info(state, labels, rectangle, infoY, data, style)
	local settings, environment = state.settings, state.context.environment
	local scale = math.clamp(rectangle.h / 110, 0.75, 1)
	local textSize = math.max(math.floor((style.infoSize + 1) * scale + 0.5), 9)
	local iconSize, gap = math.max(math.floor((style.infoSize + 4) * scale + 0.5), 11), math.max(math.floor(5 * scale + 0.5), 3)
	local entries = {}
	if data.ghostTag then
		if not labels.ghost then labels.ghost = labels.createLabel(labels.bottom, "ghost") end
		local ghost = data.ghostTag
		if settings.infoCase == "UPPER" then ghost = EspText.upper(state.text, ghost) end
		table.insert(entries, {kind = "ghost", text = ghost, color = data.roleColor:Lerp(state.colors.white, 0.2), padding = 12})
	end
	if settings.roleText and data.role then
		local role = EspText.role(state.text, data.role, settings.roleStyle, state.context.translation.tr)
		if settings.infoCase == "UPPER" then role = EspText.upper(state.text, role) end
		table.insert(entries, {kind = "role", text = role, color = data.roleColor:Lerp(state.colors.white, 0.2)})
	end
	if settings.weaponIcon and data.weapon and settings.weaponStyle ~= "Text" then
		table.insert(entries, {kind = "weapon", icon = data.weapon == "Knife" and "sword" or "crosshair", color = data.roleColor, dim = not data.equipped})
	end
	if settings.weaponIcon and data.weapon and settings.weaponStyle ~= "Icon" then
		local weapon = state.context.translation.tr(data.weapon)
		if settings.infoCase == "UPPER" then weapon = EspText.upper(state.text, weapon) end
		local color = data.equipped and data.roleColor:Lerp(state.colors.white, 0.2)
			or data.roleColor:Lerp(environment.Color3.fromRGB(188, 188, 188), 0.5)
		table.insert(entries, {kind = "weaponText", text = weapon, color = color})
	end
	if settings.distance and type(data.distance) == "number" then
		local distance = EspText.distance(state.text, data.distance, settings.distUnit)
		if settings.infoCase == "UPPER" then distance = EspText.upper(state.text, distance) end
		table.insert(entries, {kind = "distance", text = distance, color = style.infoColor})
	end
	local total, height = 0, 0
	for index, entry in entries do
		if entry.text then
			entry.width, entry.height = EspLabel.measure(state, labels, entry.kind, entry.text, textSize, style.metricFont, style.limit)
			if entry.padding then entry.width = math.min(entry.width + entry.padding, style.limit) end
		end
		if entry.icon then entry.width, entry.height = iconSize, iconSize end
		total += entry.width + (index > 1 and gap or 0)
		height = math.max(height, entry.height)
	end
	labels.role.Visible, labels.distance.Visible, labels.weaponText.Visible = false, false, false
	labels.weapon.Visible, labels.weaponShadow.Visible = false, false
	if labels.ghost then labels.ghost.Visible = false end
	if total <= 0 or height <= 0 then labels.bottom.Visible = false; return end
	EspLabel.position(state, labels.bottom, rectangle, total, height, infoY - 1)
	local x = 0
	for _, entry in entries do
		local y = math.floor((height - entry.height) * 0.5 + 0.5)
		if entry.text then
			local label = labels[entry.kind]
			EspLabel.text(state, label, {text = entry.text, font = EspLabel.font(state, settings.textFont, environment.Enum.FontWeight.SemiBold),
				size = textSize, color = entry.color, opacity = style.opacity, x = x, y = y, width = entry.width, height = entry.height})
		end
		if entry.icon then EspLabel.icon(state, labels, entry, style.opacity, x, y) end
		x += entry.width + gap
	end
end

function EspLabel.icon(state, labels, entry, opacity, x, y)
	local environment = state.context.environment
	local icon, shadow = labels.weapon, labels.weaponShadow
	if labels.icon ~= entry.icon then
		labels.icon = entry.icon
		pcall(function() state.context.nova.Icons.apply(icon, entry.icon) end)
		shadow.Image, shadow.ImageRectOffset, shadow.ImageRectSize = icon.Image, icon.ImageRectOffset, icon.ImageRectSize
	end
	local strength = entry.dim and 0.72 or 1
	icon.Position, icon.Size = environment.UDim2.fromOffset(x, y), environment.UDim2.fromOffset(entry.width, entry.height)
	icon.ImageColor3, icon.ImageTransparency, icon.Visible = entry.color, EspBox.quantize(1 - opacity * strength), true
	shadow.Position, shadow.Size = environment.UDim2.fromOffset(x + 1, y + 1), environment.UDim2.fromOffset(entry.width, entry.height)
	shadow.ImageTransparency, shadow.Visible = EspBox.quantize(1 - opacity * 0.7 * strength), state.settings.textOutline ~= false
end

function EspLabel.update(state, player, rectangle, data)
	if data.alpha <= 0 or state.viewport.X < 12 or state.viewport.Y < 12 then EspLabel.hide(state, player); return end
	local labels = state.labels[player]
	if not labels or not labels.top.Parent then labels = EspLabel.create(state, player) end
	if not labels then return end
	local settings, environment = state.settings, state.context.environment
	local opacity = EspBox.quantize(math.clamp(0.35 + math.clamp(data.alpha, 0, 1) * 0.65, 0, 1))
	local function textSize(value) return math.max(6, math.floor(value * (settings.textScale or 100) / 100 + 0.5)) end
	local style = {opacity = opacity, nameSize = textSize(math.clamp(tonumber(settings.textSize) or 12, 9, 28)) + (data.focus and 2 or 0),
		infoSize = textSize(math.clamp(tonumber(settings.infoSize) or 10, 8, 24)),
		limit = math.min(math.max(tonumber(settings.labelWidth) or 240, 40), math.max(1, state.viewport.X - 8)),
		metricFont = EspLabel.metricFont(state, settings.textFont)}
	style.nameColor = settings.textMatch and data.color or EspColor.tone(state.colors, settings.nameColour)
	style.infoColor = settings.textMatch and data.color or EspColor.tone(state.colors, settings.infoColour)
	local infoY = EspLabel.name(state, labels, player, rectangle, rectangle.y + rectangle.h + 5, style)
	EspLabel.info(state, labels, rectangle, infoY, data, style)
end

function EspLabel.gameNames(state)
	local player, settings = state.context.player, state.settings
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if settings.on and settings.name and settings.hideGameNames then
		if state.savedNameDistance == nil then
			local distance = humanoid and humanoid.NameDisplayDistance or player.NameDisplayDistance
			state.savedNameDistance = distance and distance > 0 and distance or 100
		end
		if player.NameDisplayDistance ~= 0 then pcall(function() player.NameDisplayDistance = 0 end) end
		if humanoid and humanoid.NameDisplayDistance ~= 0 then pcall(function() humanoid.NameDisplayDistance = 0 end) end
		return
	end
	EspLabel.restoreNames(state)
end

function EspLabel.restoreNames(state)
	if state.savedNameDistance == nil then return end
	local player, distance = state.context.player, state.savedNameDistance
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	pcall(function() player.NameDisplayDistance = distance end)
	if humanoid then pcall(function() humanoid.NameDisplayDistance = distance end) end
	state.savedNameDistance = nil
end

function EspLabel.hide(state, player)
	local labels = state.labels[player]
	if not labels then return end
	labels.top.Visible, labels.bottom.Visible = false, false
end

function EspLabel.release(state, player)
	local labels = state.labels[player]
	if not labels then return end
	pcall(function() labels.top:Destroy() end)
	pcall(function() labels.bottom:Destroy() end)
	state.labels[player] = nil
end

local EspLine = {}

function EspLine.create(context, object, name, level)
	local frame = object.frame(object.layer, name, level or 4)
	frame.AnchorPoint = context.environment.Vector2.new(0.5, 0.5)
	return {frame = frame, stroke = object.stroke(frame, 1)}
end

function EspLine.draw(context, line, options)
	local environment, settings = context.environment, context.settings
	local from, to = options.from, options.to
	local dx, dy = to.X - from.X, to.Y - from.Y
	local length = math.sqrt(dx * dx + dy * dy)
	local precision = length < 60 and 1 or 4
	line.frame.Position = environment.UDim2.fromOffset(math.floor((from.X + to.X) * 0.5 + 0.5), math.floor((from.Y + to.Y) * 0.5 + 0.5))
	line.frame.Size = environment.UDim2.fromOffset(math.max(math.floor(length + 0.5), 1), math.max(1, math.floor(options.width + 0.5)))
	line.frame.Rotation = math.floor(math.deg(math.atan2(dy, dx)) * precision + 0.5) / precision
	line.frame.BackgroundColor3, line.frame.BackgroundTransparency = options.color, EspBox.quantize(1 - options.alpha)
	line.stroke.Enabled, line.stroke.Transparency = not not options.outline, 1
	if options.outline then
		line.stroke.Color = settings.outlineCol or context.colors.black
		line.stroke.Transparency = EspBox.quantize(1 - math.min(options.alpha * 1.15 * math.clamp((settings.outlineAlpha or 65) / 65, 0, 1.5), 1))
	end
	line.frame.Visible = true
end

local EspTracer = {}

function EspTracer.create(context, box)
	return EspLine.create(context, box, "Tracer")
end

function EspTracer.origin(state, camera)
	local environment, settings = state.context.environment, state.settings
	local viewport = camera.ViewportSize
	if settings.tracerFrom == "Top" then return environment.Vector2.new(viewport.X * 0.5, 2) end
	if settings.tracerFrom == "Middle" then return environment.Vector2.new(viewport.X * 0.5, viewport.Y * 0.5) end
	if settings.tracerFrom == "Mouse" then return state.context.inputService:GetMouseLocation() end
	if settings.tracerFrom == "Character" then
		local character = state.context.player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root then
			local position = camera:WorldToViewportPoint(root.Position - environment.Vector3.new(0, 2.6, 0))
			if position.Z > 0.08 then return environment.Vector2.new(position.X, position.Y) end
		end
	end
	return environment.Vector2.new(viewport.X * 0.5, viewport.Y - 2)
end

function EspTracer.point(state, camera, position)
	local environment, settings = state.context.environment, state.settings
	local viewport = camera.ViewportSize
	local point = camera.CFrame:PointToObjectSpace(position)
	local magnitude = math.sqrt(point.X * point.X + point.Z * point.Z)
	local x, y = 0, -1
	if magnitude >= 0.001 then x, y = point.X / magnitude, point.Z / magnitude end
	local avatar = settings.radarStyle == "Avatar"
	local half = math.clamp(settings.arrowSize, 5, 26) * (avatar and 3 or 2) * 0.5 * (avatar and 1 or math.sqrt(2))
	local marginX, marginY = math.max(half, settings.ringText and 36 or 0) + 4, half + (settings.ringText and 19 or 0) + 4
	local available = math.max(0, math.min(viewport.X * 0.5 - marginX, viewport.Y * 0.5 - marginY))
	local radius = math.clamp(settings.ringRadius, math.min(60, available), available)
	if settings.markerPos == "Screen Edge" then
		local width = math.max(20, viewport.X * 0.5 - marginX - 26)
		local height = math.max(20, viewport.Y * 0.5 - marginY - 26)
		radius = math.min(width / math.max(math.abs(x), 0.0001), height / math.max(math.abs(y), 0.0001))
	end
	return environment.Vector2.new(viewport.X * 0.5 + x * radius, viewport.Y * 0.5 + y * radius), math.deg(math.atan2(y, x)) + 90
end

function EspTracer.draw(state, object, origin, target, color, alpha, role)
	local environment, settings, context = state.context.environment, state.settings, state.boxContext
	local line = object.tracer
	if settings.tracerMurderer and role ~= "Murderer" then line.frame.Visible = false; return end
	local tint = settings.tracerRole and color or EspColor.tone(state.colors, settings.tracerColour)
	local fade = settings.tracerStyle == "Fade"
	local width = (tonumber(settings.tracerThickness) or 1) * (settings.lineScale or 100) / 100 * (context.lineWidthFactor or 1)
	EspLine.draw(context, line, {from = origin, to = target, width = width, color = tint,
		alpha = alpha * settings.tracerAlpha / 100, outline = settings.outline and not fade})
	if not fade and not object.tracerGrad then return end
	if not object.tracerGrad then
		local keypoint = environment.NumberSequenceKeypoint
		object.tracerGrad = object.make("UIGradient", {Transparency = environment.NumberSequence.new({keypoint.new(0, 0.95),
			keypoint.new(0.6, 0.4), keypoint.new(1, 0)})}, line.frame)
	end
	object.tracerGrad.Enabled = fade
end

local EspSkeleton = {}
local ESP_RIGS = {
	R15 = {
		points = {{"Head"}, {"UpperTorso", "NeckRigAttachment", joint = true}, {"UpperTorso", "WaistRigAttachment"},
			{"LowerTorso", "LeftHipRigAttachment", "RightHipRigAttachment", joint = true},
			{"LeftUpperArm", "LeftShoulderRigAttachment", joint = true}, {"LeftLowerArm", "LeftElbowRigAttachment", joint = true},
			{"LeftHand", "LeftGripAttachment"}, {"RightUpperArm", "RightShoulderRigAttachment", joint = true},
			{"RightLowerArm", "RightElbowRigAttachment", joint = true}, {"RightHand", "RightGripAttachment"},
			{"LeftUpperLeg", "LeftHipRigAttachment", joint = true}, {"LeftLowerLeg", "LeftKneeRigAttachment", joint = true},
			{"LeftFoot", "LeftFootAttachment"}, {"RightUpperLeg", "RightHipRigAttachment", joint = true},
			{"RightLowerLeg", "RightKneeRigAttachment", joint = true}, {"RightFoot", "RightFootAttachment"}},
		bones = {{1, 2}, {2, 3}, {3, 4}, {2, 5}, {5, 6}, {6, 7}, {2, 8}, {8, 9}, {9, 10}, {4, 11}, {11, 12}, {12, 13}, {4, 14}, {14, 15}, {15, 16}},
	},
	R6 = {
		points = {{"Head"}, {"Torso", 0, 0.5, joint = true}, {"Torso", 0, -0.5, joint = true},
			{"Left Arm", 0, 0.25, joint = true}, {"Left Arm", 0, -0.5}, {"Right Arm", 0, 0.25, joint = true},
			{"Right Arm", 0, -0.5}, {"Left Leg", 0, 0.5, joint = true}, {"Left Leg", 0, -0.5},
			{"Right Leg", 0, 0.5, joint = true}, {"Right Leg", 0, -0.5}},
		bones = {{1, 2}, {2, 3}, {2, 4}, {4, 5}, {2, 6}, {6, 7}, {3, 8}, {8, 9}, {3, 10}, {10, 11}},
	},
}

function EspSkeleton.references(character, rig)
	local result = {}
	for index, point in rig.points do
		local part = character:FindFirstChild(point[1])
		local reference = false
		if part and part:IsA("BasePart") then
			reference = {part = part}
			if type(point[2]) == "number" then reference.x, reference.y = point[2], point[3] end
			if type(point[2]) == "string" then
				local attachment = part:FindFirstChild(point[2])
				local other = point[3] and part:FindFirstChild(point[3])
				if attachment and attachment:IsA("Attachment") then
					reference = {att = attachment, att2 = other and other:IsA("Attachment") and other or nil}
				end
			end
		end
		result[index] = reference
	end
	return result
end

function EspSkeleton.position(environment, reference)
	if reference.att then
		if reference.att2 then return (reference.att.WorldPosition + reference.att2.WorldPosition) * 0.5 end
		return reference.att.WorldPosition
	end
	local part = reference.part
	if reference.x then
		return part.CFrame:PointToWorldSpace(environment.Vector3.new(part.Size.X * reference.x, part.Size.Y * reference.y, 0))
	end
	return part.Position
end

function EspSkeleton.baseColor(state, object, color)
	if object.seen == false then return EspColor.tone(state.colors, state.settings.boneHidden) end
	if state.settings.boneRole then return color end
	return EspColor.tone(state.colors, state.settings.boneColour)
end

function EspSkeleton.perf(state)
	if state.settings.perfMode == false then return false end
	if state.settings.perfMode == true then return true end
	if state.touchPerf ~= nil then return state.touchPerf end
	local isTouch = false
	pcall(function()
		local input, globals = state.context.inputService, state.context.environment.getgenv()
		isTouch = input.TouchEnabled and not input.KeyboardEnabled or globals.NOVA_FORCE_TOUCH == true
	end)
	state.touchPerf = isTouch
	return isTouch
end

function EspSkeleton.line(state, object, field, index)
	object[field] = object[field] or {}
	local line = object[field][index]
	if line then return line end
	local isGlow = field == "boneGlows"
	local name = (isGlow and "BoneGlow" or "Bone") .. index
	line = EspLine.create(state.context, object, name, isGlow and 3 or 4)
	object.make("UICorner", {CornerRadius = state.context.environment.UDim.new(1, 0)}, line.frame)
	object[field][index] = line
	return line
end

function EspSkeleton.joint(state, object, index, position, color, alpha)
	local environment, settings = state.context.environment, state.settings
	object.joints = object.joints or {}
	local joint = object.joints[index]
	if not joint then
		local frame = object.frame(object.layer, "Joint" .. index, 5)
		frame.AnchorPoint = environment.Vector2.new(0.5, 0.5)
		object.make("UICorner", {CornerRadius = environment.UDim.new(1, 0)}, frame)
		joint = {frame = frame, stroke = object.stroke(frame, 1)}
		object.joints[index] = joint
	end
	local width = (tonumber(settings.jointSize or 3) or 1) * (settings.lineScale or 100) / 100 * (state.boxContext.lineWidthFactor or 1)
	local size = math.max(2, math.floor(width + 0.5))
	joint.frame.Position = environment.UDim2.fromOffset(math.floor(position.X + 0.5), math.floor(position.Y + 0.5))
	joint.frame.Size = environment.UDim2.fromOffset(size, size)
	joint.frame.BackgroundColor3, joint.frame.BackgroundTransparency = color, EspBox.quantize(1 - alpha)
	joint.stroke.Enabled, joint.stroke.Transparency = settings.outline == true, 1
	if settings.outline then
		joint.stroke.Color = settings.outlineCol or state.colors.black
		joint.stroke.Transparency = EspBox.quantize(1 - alpha * 0.5)
	end
	joint.frame.Visible = true
end

function EspSkeleton.hide(object)
	for _, field in {"bones", "boneGlows", "joints"} do
		for _, item in object[field] or {} do item.frame.Visible = false end
	end
end

function EspSkeleton.draw(state, object, character, rectangle, color, alpha, camera)
	local settings, environment = state.settings, state.context.environment
	if not settings.skeleton or object.skelOff then EspSkeleton.hide(object); return end
	local rig = character:FindFirstChild("UpperTorso") and ESP_RIGS.R15 or ESP_RIGS.R6
	local now, cache = environment.os.clock(), object.skeletonCache
	if not cache or cache.character ~= character or cache.rig ~= rig or now - cache.at > 2 then
		cache = {character = character, rig = rig, at = now, references = EspSkeleton.references(character, rig)}
		object.skeletonCache = cache
	end
	local points = {}
	for index, reference in cache.references do
		if not reference then continue end
		local point = EspProjection.point(state.projection, camera, EspSkeleton.position(environment, reference))
		if point.Z > 0.08 then points[index] = point end
	end
	local base = EspSkeleton.baseColor(state, object, color)
	local scale = (settings.lineScale or 100) / 100 * (state.boxContext.lineWidthFactor or 1)
	local width = math.max(1, math.floor((tonumber(settings.boneThick) or 1) * scale + 0.5))
	local opacity = alpha * math.clamp((settings.boneAlpha or 100) / 100, 0, 1)
	local glow = settings.boneStyle == "Soft Glow" and not EspSkeleton.perf(state)
	local glowWidth = math.floor(width * 2.6 + 1.5)
	local trim = EspSkeleton.headTrim(state, rectangle, scale)
	local count, glowCount = 0, 0
	for _, bone in rig.bones do
		local first, second = points[bone[1]], points[bone[2]]
		if not first or not second then continue end
		local dx, dy = second.X - first.X, second.Y - first.Y
		local length = math.sqrt(dx * dx + dy * dy)
		local headTrim = bone[1] == 1 and trim or 0
		if length <= headTrim + 0.75 then continue end
		local unitX, unitY = dx / length, dy / length
		local startOffset = headTrim > 0 and headTrim or -width * 0.5
		local from = {X = first.X + unitX * startOffset, Y = first.Y + unitY * startOffset}
		local to = {X = second.X + unitX * width * 0.5, Y = second.Y + unitY * width * 0.5}
		local tint = EspSkeleton.color(state, rectangle, base, (first.Y + second.Y) * 0.5)
		count += 1
		EspLine.draw(state.boxContext, EspSkeleton.line(state, object, "bones", count),
			{from = from, to = to, color = tint, width = width, alpha = opacity, outline = settings.outline and not glow and width >= 2})
		if not glow then continue end
		glowCount += 1
		local glowStart = headTrim > 0 and headTrim or -glowWidth * 0.5
		EspLine.draw(state.boxContext, EspSkeleton.line(state, object, "boneGlows", glowCount), {
			from = {X = first.X + unitX * glowStart, Y = first.Y + unitY * glowStart},
			to = {X = second.X + unitX * glowWidth * 0.5, Y = second.Y + unitY * glowWidth * 0.5},
			color = tint, width = glowWidth, alpha = opacity * 0.16, outline = false,
		})
	end
	local jointCount = 0
	if settings.joints then
		for index, point in rig.points do
			if not point.joint or not points[index] then continue end
			jointCount += 1
			local tint = EspSkeleton.color(state, rectangle, base, points[index].Y)
			EspSkeleton.joint(state, object, jointCount, points[index], tint, opacity)
		end
	end
	for _, entry in {{"bones", count}, {"boneGlows", glowCount}, {"joints", jointCount}} do
		local items = object[entry[1]] or {}
		for index = entry[2] + 1, #items do items[index].frame.Visible = false end
	end
end

function EspSkeleton.headTrim(state, rectangle, scale)
	local settings = state.settings
	if not settings.headDot then return 0 end
	local size = math.floor(math.clamp(rectangle.w * 0.28 * (settings.headScale or 100) / 100, 3, 120) + 0.5)
	if settings.headStyle == "Dot" then size = math.max(4, math.floor(size * 0.35 + 0.5)) end
	return size * 0.5 + (settings.headStyle == "Dot" and 0.5 or 1.5 * scale * 0.5)
end

function EspSkeleton.color(state, rectangle, base, y)
	if not state.settings.boneGrad then return base end
	local top, bottom = EspColor.tone(state.colors, state.settings.boneTop), EspColor.tone(state.colors, state.settings.boneBottom)
	local cache = state.skeletonGradient
	if not cache or cache.top ~= top or cache.bottom ~= bottom then
		cache = {top = top, bottom = bottom, values = {}}
		state.skeletonGradient = cache
	end
	local index = math.floor(math.clamp((y - rectangle.y) / math.max(rectangle.h, 1), 0, 1) * 40 + 0.5)
	if not cache.values[index] then cache.values[index] = top:Lerp(bottom, index / 40) end
	return cache.values[index]
end

local EspHead = {}

function EspHead.create(state, object)
	local environment = state.context.environment
	local head = object.frame(object.layer, "Head", 4)
	head.AnchorPoint = environment.Vector2.new(0.5, 0.5)
	object.make("UICorner", {CornerRadius = environment.UDim.new(1, 0)}, head)
	object.head, object.headStroke = head, object.stroke(head, 1.5)
end

function EspHead.draw(state, object, head, rectangle, color, alpha, camera)
	local environment, settings = state.context.environment, state.settings
	if not settings.headDot then
		if object.head then object.head.Visible = false end
		return
	end
	local point = EspProjection.point(state.projection, camera, head.Position)
	if point.Z <= 0.08 then
		if object.head then object.head.Visible = false end
		return
	end
	if not object.head then EspHead.create(state, object) end
	local style = settings.headStyle or "Ring"
	local size = math.floor(math.clamp(rectangle.w * 0.28 * (settings.headScale or 100) / 100, 3, 120) + 0.5)
	if style == "Dot" then size = math.max(4, math.floor(size * 0.35 + 0.5)) end
	local base = settings.skeleton and EspSkeleton.baseColor(state, object, color) or color
	local tint = EspColor.ink(state.colors, settings.headColMode, settings.headCol, base)
	object.head.Position = environment.UDim2.fromOffset(math.floor(point.X + 0.5), math.floor(point.Y + 0.5))
	object.head.Size = environment.UDim2.fromOffset(size, size)
	object.head.BackgroundColor3 = tint
	local fill = style == "Filled" and math.clamp((settings.headFill or 25) / 100, 0, 1) or (style == "Dot" and 1 or 0)
	object.head.BackgroundTransparency = fill > 0 and EspBox.quantize(1 - alpha * fill) or 1
	object.headStroke.Color = style == "Dot" and (settings.outlineCol or state.colors.black) or tint
	object.headStroke.Thickness = style == "Dot" and 1 or 1.5 * (settings.lineScale or 100) / 100 * (state.boxContext.lineWidthFactor or 1)
	object.headStroke.Transparency = style == "Dot" and (settings.outline and EspBox.quantize(1 - alpha * 0.5) or 1) or EspBox.quantize(1 - alpha)
	object.head.Visible = true
end

function EspHead.look(state, object, head, color, alpha, camera)
	local settings, environment = state.settings, state.context.environment
	if not settings.lookLine then
		if object.look then object.look.frame.Visible = false end
		return
	end
	local from = EspProjection.point(state.projection, camera, head.Position)
	local to = EspProjection.point(state.projection, camera, head.Position + head.CFrame.LookVector * settings.lookLength)
	if from.Z <= 0.08 or to.Z <= 0.08 then
		if object.look then object.look.frame.Visible = false end
		return
	end
	if not object.look then object.look = EspLine.create(state.context, object, "Look") end
	local width = (tonumber(settings.lookThick or 1.5) or 1) * (settings.lineScale or 100) / 100 * (state.boxContext.lineWidthFactor or 1)
	local tint = EspColor.ink(state.colors, settings.lookColMode, settings.lookCol, color)
	EspLine.draw(state.boxContext, object.look, {from = from, to = to, color = tint, width = width, alpha = alpha, outline = settings.outline})
end

local EspChams = {}

function EspChams.materials(environment)
	local material = environment.Enum.Material
	return {
		Shaded = {material.SmoothPlastic, 1.02, 0.95, 0}, Glow = {material.Neon, 1.02, 0.7, 0},
		["Glow Outline"] = {material.Neon, 1.05, 0.3, 0}, Iridescent = {material.ForceField, 1.03, 0.9, 0},
		["Water Flow"] = {material.ForceField, 1.03, 0.9, 0}, Glossy = {material.SmoothPlastic, 1.02, 0.95, 0.65},
		Glass = {material.Glass, 1.03, 0.8, 0.25}, ForceField = {material.ForceField, 1.03, 0.95, 0},
		Gradient = {material.SmoothPlastic, 1.02, 0.85, 0}, Ghost = {material.SmoothPlastic, 1.03, 0.4, 0.15},
		Metallic = {material.Foil, 1.02, 0.95, 0.3}, Metal = {material.Metal, 1.02, 0.95, 0.15},
		Chrome = {material.SmoothPlastic, 1.02, 0.95, 0.55}, Crystal = {material.Glass, 1.04, 0.7, 0.5},
		Ice = {material.Ice, 1.03, 0.85, 0.25}, Lava = {material.CrackedLava, 1.02, 0.95, 0},
		Wireframe = {material.SmoothPlastic, 1.01, 1, 0},
	}
end

function EspChams.close(color, target)
	if math.abs(color.R - target.R) + math.abs(color.G - target.G) + math.abs(color.B - target.B) < 0.004 then return target end
	return color
end

function EspChams.targets(state, options)
	local settings = state.settings
	local role = EspColor.role(state.colors, options.role)
	local darkness = math.clamp((tonumber(settings.chamsHiddenDark) or 30) / 100, 0, 0.9)
	local fill = settings.chamsColour
	if not options.seen then fill = settings.chamsHidden end
	if settings.chamsRole then
		fill = role
		if not options.seen then fill = role:Lerp(state.colors.black, darkness) end
	end
	local edge = options.seen and settings.chamsEdge or settings.chamsEdgeHidden
	if settings.chamsRole and settings.chamsEdgeRole ~= false then
		edge = role:Lerp(state.colors.white, 0.25)
		if not options.seen then edge = role:Lerp(state.colors.black, darkness * 0.6) end
	end
	return fill, edge
end

function EspChams.animate(state, options, previous)
	local settings = state.settings
	local now = state.context.environment.os.clock()
	local fill, edge = EspChams.targets(state, options)
	local saved = previous or {fill = fill, edge = edge, seen = options.seen, flash = 0, born = now, at = now}
	local elapsed = math.clamp(now - saved.at, 0, 0.1)
	saved.at = now
	local blend = 1 - math.exp(-10 * elapsed)
	saved.fill = EspChams.close(saved.fill:Lerp(fill, blend), fill)
	saved.edge = EspChams.close(saved.edge:Lerp(edge, blend), edge)
	if options.seen and not saved.seen and settings.chamsFlash then saved.flash = 1 end
	saved.seen = options.seen
	saved.flash = math.max(0, saved.flash - elapsed * 2.2)

	local phase = settings.chamsAnim ~= "None" and 0.5 + 0.5 * math.sin(now * settings.chamsSpeed * math.pi * 2 + options.player.UserId % 89 * 0.41) or 0
	local fillFactor, edgeFactor, color = 1, 1, saved.fill
	if settings.chamsAnim == "Pulse" then fillFactor = 0.45 + 0.55 * phase end
	if settings.chamsAnim == "Breathe" then edgeFactor = 0.3 + 0.7 * phase end
	if settings.chamsAnim == "Flow" then color = color:Lerp(settings.chamsFlow, phase) end
	if saved.flash > 0 then color = color:Lerp(state.colors.white, saved.flash * 0.55) end
	color = EspColor.cham(state.colors, color)
	return saved, {fill = color, edge = saved.edge, fillFactor = fillFactor, edgeFactor = edgeFactor,
		born = math.clamp((now - saved.born) / 0.35, 0, 1), now = now}
end

function EspChams.material(state, role)
	local settings = state.settings
	local name = settings.chamsMaterial
	if role == "Murderer" and settings.murdMat and settings.murdMat ~= "Same" then name = settings.murdMat end
	if (role == "Sheriff" or role == "Hero") and settings.sheriffMat and settings.sheriffMat ~= "Same" then name = settings.sheriffMat end
	local specification = state.chamsMaterials[name]
	if settings.chamsStyle == "Glow" then
		name = "Core"
		specification = {state.context.environment.Enum.Material.Neon, 1.02, 0.85, 0}
	end
	if not specification then return nil, nil, nil end
	local scale = math.clamp((settings.chamsShell or 100) / 100, 1, 1.4)
	if scale ~= 1 then
		return name .. "@" .. tostring(math.floor(scale * 100 + 0.5)),
			{specification[1], specification[2] * scale, specification[3], specification[4]}, name
	end
	return name, specification, name
end

function EspChams.plan(state, options, saved)
	local settings, environment = state.settings, state.context.environment
	local through = settings.chamsThrough
	if through and (settings.chamsRange or 60) < 300 then
		local root = options.character:FindFirstChild("HumanoidRootPart")
		through = root ~= nil and (root.Position - options.cameraPosition).Magnitude <= (settings.chamsRange or 60)
	end
	local animation
	saved, animation = EspChams.animate(state, options, saved)
	local opacity = math.clamp(settings.chamsAlpha / 100, 0, 1)
	if settings.chamsStyle == "Outline" then opacity = 0 end
	if settings.chamsStyle == "Soft" then opacity *= 0.65 end
	local material, spec, kind = EspChams.material(state, options.role)
	local isGlow = settings.chamsStyle == "Glow"
	local showModel = (options.seen or through) and options.inView ~= false
	local modelColor = animation.fill
	if isGlow then modelColor = modelColor:Lerp(state.colors.white, 0.08) end
	if not isGlow and (kind == "Glow" or kind == "Glow Outline") then modelColor = modelColor:Lerp(state.colors.black, 0.42) end
	local modelAlpha = options.alpha * animation.born * animation.fillFactor
	if isGlow then modelAlpha *= math.clamp((settings.glowCore or 85) / 100, 0, 1) end

	local edge = animation.edge
	local edgeTransparency = settings.chamsOutline and 1 - options.alpha * animation.born * settings.chamsEdgeAlpha / 100 * animation.edgeFactor or 1
	if kind == "Glow Outline" then edge, edgeTransparency = animation.fill, 1 - options.alpha * animation.born * animation.edgeFactor end
	if isGlow then
		edge = animation.fill:Lerp(state.colors.white, 0.45)
		edgeTransparency = 1 - options.alpha * animation.born * 0.55 * animation.edgeFactor
	end
	local fillTransparency = material and 1 or EspBox.quantize(1 - math.clamp(opacity * animation.fillFactor + saved.flash * 0.35, 0, 1) * options.alpha * animation.born)
	edgeTransparency = EspBox.quantize(edgeTransparency)
	local haloStrength = math.clamp(settings.glowHalo / 100, 0, 1)
	local haloPulse = 0.8 + 0.2 * math.sin(animation.now * 2.2 + options.player.UserId % 89 * 0.41)
	return saved, {
		through = through, fill = animation.fill, edge = edge, fillTransparency = fillTransparency,
		edgeTransparency = edgeTransparency, enabled = options.inView ~= false and not (fillTransparency >= 0.995 and edgeTransparency >= 0.995),
		material = material, specification = spec, showModel = showModel, modelColor = modelColor, modelAlpha = modelAlpha,
		showHalo = (isGlow or settings.chamsOverlay) and showModel and haloStrength * 0.44 >= 0.07 and (haloStrength >= 0.28 or (options.distance or 0) <= 110),
		haloAlpha = options.alpha * animation.born * haloStrength * haloPulse * 2.2,
	}
end

local EspChamModel = {}

function EspChamModel.root(state)
	local environment, camera = state.context.environment, state.context.workspace.CurrentCamera
	if not camera then return nil end
	if state.modelFolder and state.modelFolder.Parent == camera then return state.modelFolder end
	if state.modelFolder then pcall(function() state.modelFolder:Destroy() end) end
	for _, object in camera:GetChildren() do
		if object.Name == "PulseESPModels" then pcall(function() object:Destroy() end) end
	end
	local folder = environment.Instance.new("Folder")
	folder.Name, folder.Parent = "PulseESPModels", camera
	state.modelFolder = folder
	return folder
end

function EspChamModel.pool(state, store, player)
	state.modelPool = state.modelPool or setmetatable({}, {__mode = "k"})
	state.modelPool[store] = state.modelPool[store] or {}
	local group = state.modelPool[store]
	group[player] = group[player] or {at = state.context.environment.os.clock(), items = {}}
	return group[player]
end

function EspChamModel.poolKey(part)
	local size = part.Size
	local key = part.Name .. "|" .. part.ClassName .. "|" .. string.format("%.3f,%.3f,%.3f", size.X, size.Y, size.Z)
	if part.ClassName == "MeshPart" then return key .. "|" .. tostring(part.MeshId) end
	local mesh = part:FindFirstChildWhichIsA("SpecialMesh")
	if not mesh then return key end
	local scale = mesh.Scale
	return key .. "|" .. tostring(mesh.MeshId) .. "|" .. mesh.MeshType.Name .. "|" .. string.format("%.3f,%.3f,%.3f", scale.X, scale.Y, scale.Z)
end

function EspChamModel.purge(state, player)
	for _, group in state.modelPool or {} do
		for owner, pool in group do
			if player and owner ~= player then continue end
			for _, items in pool.items do
				for _, item in items do pcall(function() item:Destroy() end) end
			end
			group[owner] = nil
		end
	end
end

function EspChamModel.sweep(state)
	local now = state.context.environment.os.clock()
	for _, group in state.modelPool or {} do
		for player, pool in group do
			if not (type(player) ~= "table" and player.Parent == nil or now - pool.at > 45) then continue end
			for _, items in pool.items do
				for _, item in items do pcall(function() item:Destroy() end) end
			end
			group[player] = nil
		end
	end
end

function EspChamModel.drop(state, store, player)
	local model = store[player]
	if not model then return end
	for _, connection in model.connections do pcall(function() connection:Disconnect() end) end
	local pool = model.kind ~= "Wireframe" and model.keys and EspChamModel.pool(state, store, player) or nil
	for index, clone in model.clones do
		local key = pool and model.keys[index]
		if not key or not clone.Parent then pcall(function() clone:Destroy() end); continue end
		pcall(function() clone.Transparency = 1 end)
		pool.items[key] = pool.items[key] or {}
		table.insert(pool.items[key], clone)
	end
	if pool then pool.at = state.context.environment.os.clock() end
	store[player] = nil
end

function EspChamModel.cloneable(part)
	if not part:IsA("BasePart") or part.Name == "HumanoidRootPart" then return false end
	if part.Transparency >= 0.95 or part.LocalTransparencyModifier >= 0.95 then return false end
	if part:FindFirstChildWhichIsA("WrapLayer") then return false end
	local accessory = part:FindFirstAncestorWhichIsA("Accessory")
	if accessory and accessory:FindFirstChildWhichIsA("WrapLayer", true) then return false end
	return true
end

function EspChamModel.clone(state, source, specification, folder, pool)
	local environment = state.context.environment
	local key = pool and EspChamModel.poolKey(source)
	local items = key and pool.items[key]
	local clone = items and table.remove(items)
	while clone and clone.Parent ~= folder do
		pcall(function() clone:Destroy() end)
		clone = table.remove(items)
	end
	local mesh, meshScale
	if clone then
		mesh = clone:FindFirstChildWhichIsA("SpecialMesh")
		if mesh then
			local sourceMesh = source:FindFirstChildWhichIsA("SpecialMesh")
			meshScale = sourceMesh and sourceMesh.Scale or mesh.Scale
		end
	end
	if not clone then
		local archivable = source.Archivable
		source.Archivable = true
		local ok, result = pcall(function() return source:Clone() end)
		source.Archivable = archivable
		if not ok or not result then return nil end
		clone = result
		if clone:FindFirstChildWhichIsA("SpecialMesh") then
			for _, child in clone:GetChildren() do
				if child:IsA("SpecialMesh") then
					child.TextureId = ""
					mesh = child
					continue
				end
				child:Destroy()
			end
		end
		if not mesh then clone:ClearAllChildren() end
		if mesh then meshScale = mesh.Scale end
		if clone:IsA("MeshPart") then pcall(function() clone.TextureID = "" end) end
		clone.Name = "M"
	end

	local scale, size
	if mesh and mesh.MeshType == environment.Enum.MeshType.FileMesh then
		scale = meshScale * specification[2]
		mesh.Scale = scale
	end
	if not scale then
		size = source.Size * specification[2]
		clone.Size = size
	end
	clone.Anchored, clone.CanCollide, clone.CanQuery, clone.CanTouch, clone.CastShadow = true, false, false, false, false
	clone.Material, clone.Reflectance, clone.Transparency = specification[1], specification[4], 1
	if clone.Parent ~= folder then clone.Parent = folder end
	return {clone = clone, mesh = mesh and scale and mesh or nil, scale = scale, size = size, key = key}
end

function EspChamModel.build(state, character, material, specification, folder, pool)
	local environment = state.context.environment
	local kind = tostring(material):match("^[^@]+")
	local model = {material = material, kind = kind, specification = specification, character = character,
		root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso"),
		sources = {}, clones = {}, sizes = {}, meshes = {}, scales = {}, cframes = {}, boxes = {}, keys = {}, scale = 1, connections = {}}
	if kind == "Wireframe" then pool = nil end
	for _, source in character:GetDescendants() do
		if not EspChamModel.cloneable(source) then continue end
		local result = EspChamModel.clone(state, source, specification, folder, pool)
		if not result then continue end
		local index = #model.clones + 1
		model.sources[index], model.clones[index], model.keys[index] = source, result.clone, result.key
		model.sizes[index], model.meshes[index], model.scales[index] = result.size, result.mesh, result.scale
		if kind == "Wireframe" and source.Parent == character and source.Name ~= "HumanoidRootPart" then
			local outline = environment.Instance.new("SelectionBox")
			outline.Adornee, outline.LineThickness, outline.SurfaceTransparency, outline.Transparency = result.clone, 0.02, 1, 1
			outline.Parent, model.boxes[index] = result.clone, outline
		end
	end
	local function dirty(object)
		if (object:IsA("BasePart") or object:IsA("Accessory") or object:IsA("WrapLayer") or object:IsA("SpecialMesh")) and not model.dirty then
			model.dirty = environment.os.clock()
		end
	end
	table.insert(model.connections, character.DescendantAdded:Connect(dirty))
	table.insert(model.connections, character.DescendantRemoving:Connect(dirty))
	return model
end

function EspChamModel.resize(model, scale)
	model.scale = scale
	for index, clone in model.clones do
		local mesh = model.meshes[index]
		if mesh then mesh.Scale = model.scales[index] * scale end
		if not mesh then clone.Size = model.sizes[index] * scale end
	end
	for _, box in model.boxes do box.LineThickness = 0.02 * scale end
end

function EspChamModel.paint(state, model, color, transparency, now)
	local settings, environment = state.settings, state.context.environment
	local rootY = model.root and model.root.Parent and model.root.Position.Y or 0
	local top, bottom
	if model.kind == "Gradient" then
		top = EspColor.cham(state.colors, EspColor.tone(state.colors, settings.chamsGradA))
		bottom = EspColor.cham(state.colors, EspColor.tone(state.colors, settings.chamsGradB))
	end
	for index, clone in model.clones do
		local tint = color
		if model.kind == "Iridescent" then tint = environment.Color3.fromHSV((now * 0.12 * (settings.chamsSpeed or 1) + index * 0.012) % 1, 0.38, 1) end
		if model.kind == "Gradient" then
			local source = model.sources[index]
			local fraction = source and source.Parent and math.clamp((source.Position.Y - (rootY - 3)) / 5.6, 0, 1) or 0.5
			if settings.chamsGradScroll then fraction = math.abs((fraction + now * 0.2 * (settings.chamsSpeed or 1)) % 1 * 2 - 1) end
			tint = bottom:Lerp(top, fraction)
		end
		clone.Color, clone.Transparency = tint, transparency
	end
end

function EspChamModel.show(state, model, visible, color, alpha)
	if not visible then
		if model.shown == false then return end
		for _, clone in model.clones do clone.Transparency = 1 end
		for _, box in model.boxes do box.Transparency = 1 end
		model.shown = false
		return
	end
	local now, wasShown = state.context.environment.os.clock(), model.shown == true
	if wasShown and now - (model.propertiesAt or 0) < 1 / 30 then return end
	model.propertiesAt = now
	local transparency = 1 - math.clamp(model.specification[3] * alpha, 0, 1)
	if model.kind == "Wireframe" then
		model.shown = true
		if not wasShown or model.lastTint ~= color or math.abs((model.lastTransparency or -1) - transparency) >= 0.01 then
			model.lastTint, model.lastTransparency = color, transparency
			for _, box in model.boxes do box.Color3, box.Transparency = color, transparency end
		end
		return
	end
	if model.kind == "Iridescent" or model.kind == "Gradient" then
		model.shown, model.lastTint, model.lastTransparency = true, nil, nil
		EspChamModel.paint(state, model, color, transparency, now)
		return
	end
	local colorChanged = not wasShown or model.lastTint ~= color
	local transparencyChanged = not wasShown or math.abs((model.lastTransparency or -1) - transparency) >= 0.01
	if not colorChanged and not transparencyChanged then return end
	model.shown = true
	if colorChanged then
		model.lastTint = color
		for _, clone in model.clones do clone.Color = color end
	end
	if transparencyChanged then
		model.lastTransparency = transparency
		for _, clone in model.clones do clone.Transparency = transparency end
	end
end

function EspChamModel.step(state, options)
	local store, player = options.store, options.player
	local model, now = store[player], state.context.environment.os.clock()
	local stale = not model or model.character ~= options.character or model.material ~= options.material or not model.character.Parent
		or model.dirty ~= nil and now - model.dirty > 0.35
	if stale then
		if not options.visible then EspChamModel.drop(state, store, player); return end
		if (state.modelBudget or 0) <= 0 then
			if model and model.character == options.character then
				model.view = options.inView
				EspChamModel.show(state, model, options.visible, options.color, options.alpha)
			end
			return
		end
		state.modelBudget -= 1
		EspChamModel.drop(state, store, player)
		local folder = EspChamModel.root(state)
		if not folder or not options.material or not options.specification then return end
		model = EspChamModel.build(state, options.character, options.material, options.specification, folder, EspChamModel.pool(state, store, player))
		store[player] = model
		EspChamModel.bind(state)
	end
	model.view = options.inView
	EspChamModel.show(state, model, options.visible, options.color, options.alpha)
end

function EspChamModel.placeStore(state, store, camera)
	local environment, workspace = state.context.environment, state.context.workspace
	local position, viewport = camera.CFrame.Position, camera.ViewportSize
	for _, model in store do
		local root = model.root
		local parked = not (root and root.Parent)
		if model.shown and not parked then
			if model.view ~= nil then parked = model.view == false end
			if model.view == nil and (root.Position - position).Magnitude > 12 then
				local point = camera:WorldToViewportPoint(root.Position)
				local marginX, marginY = viewport.X * 0.35, viewport.Y * 0.35
				parked = point.Z < -6 or point.X < -marginX or point.X > viewport.X + marginX or point.Y < -marginY or point.Y > viewport.Y + marginY
			end
		end
		if model.shown and parked and not model.parked then
			model.parked = true
			local frames, frame = {}, environment.CFrame.new(0, 30000, 0)
			for index = 1, #model.clones do frames[index] = frame end
			pcall(function() workspace:BulkMoveTo(model.clones, frames, environment.Enum.BulkMoveMode.FireCFrameChanged) end)
		end
		if not model.shown or parked then continue end
		model.parked = nil
		if state.settings.chamsThrough and root and root.Parent then
			local distance = math.max((root.Position - position).Magnitude, 0.01)
			local scale = math.min(1, 2.5 / distance)
			if scale >= 1 and model.scale < 1 then EspChamModel.resize(model, 1) end
			if scale < 1 and (model.scale >= 1 or distance * model.scale < 1.9 or distance * model.scale > 3.25) then EspChamModel.resize(model, scale) end
		end
		if not state.settings.chamsThrough and model.scale ~= 1 then EspChamModel.resize(model, 1) end
		for index, source in model.sources do
			local frame = source.CFrame
			if model.scale < 1 then frame = frame.Rotation + (frame.Position * model.scale + position * (1 - model.scale)) end
			model.cframes[index] = frame
		end
		pcall(workspace.BulkMoveTo, workspace, model.clones, model.cframes, environment.Enum.BulkMoveMode.FireCFrameChanged)
	end
end

function EspChamModel.bind(state)
	if state.modelsBound then return end
	local runService, environment = state.context.runService, state.context.environment
	local name = "PulseESP2ModelPlace"
	state.modelsBound = name
	pcall(function() runService:UnbindFromRenderStep(name) end)
	runService:BindToRenderStep(name, environment.Enum.RenderPriority.Last.Value, function()
		pcall(function()
			local camera = state.context.workspace.CurrentCamera
			if not camera then return end
			EspChamModel.placeStore(state, state.models, camera)
			EspChamModel.placeStore(state, state.halos, camera)
		end)
	end)
end

function EspChamModel.unbind(state)
	if not state.modelsBound then return end
	pcall(function() state.context.runService:UnbindFromRenderStep(state.modelsBound) end)
	state.modelsBound = nil
end

function EspChams.drop(state, player)
	local highlight = state.highlights[player]
	if highlight then pcall(function() highlight:Destroy() end) end
	state.highlights[player], state.chamStates[player] = nil, nil
	EspChamModel.drop(state, state.models, player)
	EspChamModel.drop(state, state.halos, player)
end

function EspChams.clear(state)
	for player in state.highlights do EspChams.drop(state, player) end
	for player in state.models do EspChamModel.drop(state, state.models, player) end
	for player in state.halos do EspChamModel.drop(state, state.halos, player) end
end

function EspChams.apply(state, options)
	if not state.settings.chams then EspChams.drop(state, options.player); return end
	local context, environment = state.context, state.context.environment
	local remote = environment.getgenv().__pulseRemoteSkin
	local replacement = remote and remote.list[options.player] and remote.list[options.player].model
	if replacement and replacement.Parent then options.character = replacement end
	local highlight = state.highlights[options.player]
	if not highlight or not highlight.Parent then
		highlight = environment.Instance.new("Highlight")
		highlight.Name, highlight.Enabled = "PulseESP2Cham", false
		local holder = context.coreGui
		if not holder or not holder.Parent then holder = context.player:FindFirstChildOfClass("PlayerGui") end
		highlight.Parent = holder or options.character
		state.highlights[options.player], state.chamStates[options.player] = highlight, nil
	end
	local previous = state.chamStates[options.player]
	if options.inView == false and previous and previous.adorned == nil then
		local model, halo = state.models[options.player], state.halos[options.player]
		if not (model and model.shown or halo and halo.shown) then return end
	end
	local saved, plan = EspChams.plan(state, options, previous)
	state.chamStates[options.player] = saved
	if plan.material then
		EspChamModel.step(state, {store = state.models, player = options.player, character = options.character,
			visible = plan.showModel, color = plan.modelColor, alpha = plan.modelAlpha, material = plan.material,
			specification = plan.specification, inView = options.inView})
	end
	if not plan.material and state.models[options.player] then EspChamModel.drop(state, state.models, options.player) end
	if state.settings.chamsStyle == "Glow" or state.settings.chamsOverlay then
		EspChamModel.step(state, {store = state.halos, player = options.player, character = options.character,
			visible = plan.showHalo, color = plan.fill, alpha = plan.haloAlpha, material = "Halo",
			specification = {environment.Enum.Material.Neon, 1.16, 0.2, 0}, inView = options.inView})
	end
	if state.settings.chamsStyle ~= "Glow" and not state.settings.chamsOverlay and state.halos[options.player] then
		EspChamModel.drop(state, state.halos, options.player)
	end
	if not plan.enabled then
		if saved.adorned ~= nil then highlight.Adornee, saved.adorned = nil, nil end
		highlight.Enabled = false
		return
	end
	if saved.adorned ~= options.character then highlight.Adornee, saved.adorned = options.character, options.character end
	highlight.FillColor, highlight.OutlineColor = plan.fill, plan.edge
	highlight.FillTransparency, highlight.OutlineTransparency = plan.fillTransparency, plan.edgeTransparency
	highlight.DepthMode = plan.through and environment.Enum.HighlightDepthMode.AlwaysOnTop or environment.Enum.HighlightDepthMode.Occluded
	highlight.Enabled = true
end

local EspRadar = {}
local ESP_ARROW_ASSETS = {
	fill = "iVBORw0KGgoAAAANSUhEUgAAAGAAAABgCAYAAADimHc4AAADKklEQVR42u3dL1BiURTHccexOAZng2OiSHEMjsGhSJHiUKRIkSJJihQpazKtZSmSSCQtmkgkGolEIrGJtImkxZmzj/Eyssif9+fee+6973dmvs2Z97yfDSy8g2tEtIb4wiEAAAAIAABAAAAAAgAAEAAAYFNbIgAwdScCAEMbXn9FGwDQX4W+pgIA/Q2nAIYA0FuZvk8ZAPoazAEYAEBPJVo8JQCor78EoA8AtRVp9RQBoK6eD4AeANRUIP9TAID8ugEAugCQW56CTx4A8uqEAOgAQE45Cj85AESvHQGgDYBoZSn6ZAEQvpYEgBYAwpUheZMBQPCaEgGaAAhWmuRPGgD+e1UA8AoAf6VI3aQAsLpnhQDPAFjeEamfIwAsrqEBoAGA+R2QvjkAwPfqGgHqAPi/JOmfJAC+qjEA1ADwWYL4JgEAoiojQDXuALteH4wAH+IeYgvwQPzzEFeAH15vBgC8iXuJHcA9mTP3cQMYL9aNDAIYcS37cS7XmTZ3cQGYLNeZNizLftzLdaZNJQ4AQ4MBhq4DlMn8KbsMMLAAYOAqQInsmZKLAH2LAPquARTJvim6BNCzEKDnCkCB7J2CCwBdiwG6tgPkyf7J2wzQcQCgYytAjtyZnI0AbQ0H8yhSPW3bALKk/vnO/anr7Wt4rjRrE0BL0SG8eB0vue6x+BkV07IFIKPolz8NcA+niv4RZGwAaEp+BXIe4V7OJb8Sa5oOkJb4NsClxPu6lPh2SNpkgKjLdX+8rhW+MrsW1yBTlv1MWa4bfyB+q/Gt8duIDwakTAQIs1z3Tp8PRW0yfDa9Ka79TozLfpzLdb+9dgx4OntH3AtxLPtxLNeN14P2DFyP3Qu4JtUwBcDvct2T16EF3090KO6VdCz76ViuG792PrHwC2JPfPyfps4NkFzxBtaZxd/OPulsxRuLSU6A2oJPkS4cOPjZLhZ8ulfjAkjMeZTjysGDn+1qziM2CQ6A6tTzlDcxOPjZbqaec63qBtgVSw0/vdZjePiT1sUZjMIu+4W98C+v7Rgf/Gzb4kzwh9wIfz8AAQAACAAAQAAAAAIAABAAAIAAYCjAP5FhtP24QRzDAAAAAElFTkSuQmCC",
	rim = "iVBORw0KGgoAAAANSUhEUgAAAGAAAABgCAYAAADimHc4AAADhUlEQVR42u2dMUgbYRTHxaE4FIduxUEcxCFFCCgEh4AQEAJCwCEgBoSAICgOghBwEgoixaEgFBxKhpKhZChkKBFKhpKhZGkGS8DiUJxcdHMQXx/0Qdu06l3uu/ve+773h98SYu7d+ymGcP/LEAAMKfbQJagAFaCoABWgqIBQvEAOkBPigB5TAQmwDfdnWwXEywo8nhUVEB+9AAJ6KiAeyhA8ZRVgnm4IAV0VYJYShE9JBZijM4CAjgowQxEGT1EFRKcdQUBbBUSjANFTUAGD0zIgoKUCBiMP5pJXAeFpGhTQVAHhyIH55FRAcBoxCGiogGBkIb5kVcDj1GMUUFcBD5OB+JNRAfdTS0BATQX8nzQkl7QK+JdqggKqKuBvUpB8UirgN8cWBByrgF9Mgr1MqgCAI4sCjnwXMA72M+6zgEMGAg59FfAcuWMg4I5m8U7APvDJvm8CniE3jATc0EzeCNgDftnzRcBT5JqhgGuazXkBu8A3u64LeIJcMhZwSTM6K2AH+GfHZQEXAgRcuCpgC+Rky0UB54IEnLsmYB3kZd0lAT2BAnquCCiD3JRdENAVLKArXUAJ5KckWUDHAQEdqQKK4E6KEgW0HRLQliagAO6lIElAy0EBLSkC8uBu8hIENB0W0OQuIAfuJ8dZQMMDAQ2uArLgT7IcBdQ9ElDnJiAD/iXDSUDNQwE1LgLS4G/SHARUPRZQtS0gBZqUTQHHuv9oZT+p5TpumbQh4Ej3DpHLfpLLddwynqSAQyYn/YoAqWU/qeW6N8jEHzNN0GMgrewnrVz3Dpl+YLZpeg5IKftJKdd9QOZCzDlHPwPcy37cy3WfkIUI79QW6DWAa9mPa7nuC7Jk8KPyJXpN4Fb241au+4asxnit0iodA7iU/biU634gGwmWRTbomGC77Ge7XHeFVJBhC3XZYTr2FVgs+9kq190iL5FRBvcrGqVZbsFC2S/IgJuGB3uNjDG8YewYzWYymyYEmLrQ6i0yJeAbO6ZoVkjiQq4gA51GHOI9MiPwKxNnaPYoOTUhYNALbT8i8wIX3888nQvEcUFvkAEqIQ/6GVl0YPH9LNK5hUnFhIAR5CzAwb4iyw4uvp9lOtfHcka7M/I2dPYBCd+RNQ8W388anft9y581/VHECP1JteifSzPI2ywP2KRdnNJuKkF+8/UrzfXm3YoKUAGKLkEFqABFBfgr4CdsheUuxgSmnQAAAABJRU5ErkJggg==",
	shade = "iVBORw0KGgoAAAANSUhEUgAAAGAAAABgCAYAAADimHc4AAANZklEQVR42u2d93cV1RbHIXBJkAcmIaQAob8gwUcNQSCQUBRQihjKIzQpgjTBCNKbCAKBgEoXUBIFpBuQLlWKFEGk5P01vH3X+pz3zjrr3pt2Z+YE8sN3icOcvffs8/3OnX3mbKbaixcvqlUiVBfUEPgEkYIoEMmxGpxTaa6pMiW+pqC2oK4gRhAniAdxHKvLOTUry0RUhuRHwPB6ggaCxoIWghTBGyCFY405px5jIqomoGKoAaP97G4k+KegvSBdkCHIBBkca885jRhTGxtVE1BO5vvv77GCJoK2grcE/QSDBcMF/wbDOdaPc9oyJhYbEVUTUPZ7fi1BtCBZ8CYsHyTIEXwkmC3IBbM5lsM5GYxJxkYtW38TbL711BEkCtoIesDwCYK5gmWCtYI8sJZjczlnMGPaYKOOrbcim9nvv300F6QJBgjGw/YvBd8K9gkKwT6Ofck54xmTho1YW1VgM/uTBKmCXtzjZwq+EGwXHBAUCc6BIo5t55yZjOmFjSRbVWAr+2NgbmfBQMGHggWCfBj/q+C64A9wnWOFnLOAMQOx0Ryb1qnA9nu/yf5dgmOCK4L7gifgPseOcY6pAmt/C2ybAMX+ZjB3AD+qnws2wfAzgluCx4Ji8JhjZzhnE2MmYKMzNpUKqiYgyHO/zv6egmzBDBi9E4ZfhvFPBf8BTzl2mXN2MmYGNnoaKoiomoDA7I+GqZ20Jx/F/gKN/X/BfDUBxRxTKijQVKCeiDphO9omFdjE/tcECaztZGjsXwWjjwZhfyAVHGXMKk0FGdhOwFdE1QT8Hz6Y2RSm9oe58wUbYbT/KedmAPabKrjJuQWMnY+t/thuii9f1QQEZ/8HgumClYIdpWB/MBXswMZ0bFqnAtvY31HwjmCcxv79pWB/MBXs11QwDtsdbVKBTexvzfrNMI39/sr2iOA3wb0S2K+r4B5jjmBDqWAYPlrbogIb2P86S8c6++exyOZn8GmN/c9LMQHPNRWcxkYeNnUVNMG371WdgAhemMQb7P9YsKKc7A+lghXY1lUQTwwRr+IE6OzvIHhbMFbwmWCD4AcY/LvgUSnZr6vgEWNPY2sDtsfiq4MNKrCB/f73ud0F7wumwdRtgsOCSzD5SRmSr/CEsZewtQ3b0/DVHd+eqsBr9idr7B9jsP9UOdkfSAWnDBWM0VSQ7KUKvGR/A439Q2HmcoP9d8vJfl0Fdw0VLMfXUE0FDbxSgRcTUJNtI8nsYugHI/1vstYLvoexNyrAflMFN7D5PT5y8dmPGJKJqebLPgHVNfb7t490g4lTeae7VfCz4GIY2G+q4CK2t+JrKr67EYtSQfWXeQIU+xvDvL7sZPgUZu7j9WI42B9IBUX4WI/PHGJoT0yuq8Bt9kdp7Pfv3xnCdpJlvFQ/FGb2B1LBIXwtw/cQYlEqiHJTBV6xvx3MGw0T1xnsfxgm9usqeGioYB2+RxNLOy9U4Db7/ZtoWxnsX6qx/wIv2cPJfl0Ff+BDqWCpoYJWxOiaCtxkf12N/X1gnn8j1VeCvYJf2N0QbvabKriOr734nkssfTQV1HVLBV6wvys716YIlgi+ERzU2P93CUvO5UUxtpUKDuJ7CbEMJjZXVeAm+/07lv8F0/wbaue4yP6SVDCHmPoQYyO3VOAW++sLWsIw/+bZyQb7zzvM/kAqOG+oYDKxdSXW+m6owI2NVor9/t3KvTX2+zfU7hGcFFwT/Cl45mDyFZ7h6xq+9xCLUkFvYlUqqFFZJ6A6XSqK/eka+xcLvmY/p5+Jd1xgv6mCO/g+QCyLNRWkayqIdFIFTrP/H4KGGvtHCT4RrPGI/aFUsIbYRmkqaMg11KhsE6CzvwWMek8wCaZt8Yj9oVSwhdgmEWs6sTuqAjfY728XyhKM1Nj/neCE4KoH7DdVcJVYvtNUMJKY2zqtAifZHwuDumjsXwTTfmJfvxfsD6SCc8S0hRiVCrpwDbFOqcBJ9ifBoEwYNZsOlt0WsD+YCnYT42xizuQakpxSgRvsf1cwUbBQsFlj/21ti7lXE6C2tt/WVLCZWCcSu6MqcLq9yM+gEYJZGvuPw7gHHrNfV8EDYjquqWAWsWc62ebkdHOdai9S7P9RcNYS9gdSwVliVCpQbU6ONfu50VznZ9JqWoeO00pkC/tNFVwhxl3EPMvpZj83m+sU+29ZxH5TBbc0FbjS7OdFc51t7A+kAtea/bxsrrNtAjxp9vO6uc42uN7s53VznY0qcLXZz4bmOptV4Hiznw3NdbaqwJVmP1ua62xXgWPNfrY019muAsea/WxqrrNRBY43+9nUXGcbXGn2s625rjKoIKzNfrY119moAkeb/WxsrrMNjjb72dhcZ7MKwt7sZ2tznY0qcKTZz9bmOltVEPZmP5ub62xVQVib/WxurrNZBWFr9rO9ua6k5YJnoNgDFYSl2c/25rpQif+bTVV/8mc3JiLszX6VobnOTIBK/B12N1/jz2oinruggrA1+1WG5jqV+Cf4UP9U8Xm2lp/kz+qfMn7Iuc9dbnMqV7Of7c11KvGPuPdex98v+N4DDnLsAufcZYwTExHWZj9bm+uesxCmEn+DH74iZL+Xi14LvuHYIc65yBg1EU8davyucLOfbc11xSTrL9Zffqf6PMWzt/pOwDruu3PBUo6p7wr8zJhL2LiHzadhjDMszX62NNfpib/PGvxvrEAeZv1lK8/dy3jq+Ih77mj+/Cl/t55zf2DsaWzdxHa4JiIszX5eN9epR8rHJOcW72F/Zf19P2vwG1h7yaXyzOGJoy8YwrGpnLOcMduxcQSbl/FxH5/PKhh7hZv9vGqu0xP/gKRcYS/OUXYi7OAN1EpWHqex7jKUtZduPG2048/9+LsxnPsZY/OwVYDtM/i6he+KTESFm/3cbq4zi6jb7Ms/y060QvbhbGIvznzewY7lDdTbrDyq74U1Bur7Yt05ZxhjpmNjFTZ34uMYPq8SQ3mLuQo3+7nVXFccoIi6SlfKcXYj72JH8hfsRJvBPpwPeP/ag3X3FFYd1Rfz1Bf2kvm7Dpz7DmPHY+tzbOfj60d8nyMWs5grdqPZz43mOrOIugZbTmBvNw0Rq9kOPpPNsNlsgsrg5XdrXv3F8+JDfTNSfWPydf6uCed2ZGx/bE3A9gJ8bcb3T8RyntjKWsxVqNnPyea6QNXrBe6VB7hfboEti2iG+JCt4APZCNuJDVBN2f6hEu8zXnpEcExNRAJj3sBGT2wOx8csfK4hhj3EdFIr5soyEeVu9gu00aoZLTnlba4zq1dVRKnqdS9PC2u5V34CU0bisxf+2xBLInG9FiDxgd7a+Tg3mrHNsJWG7XfxNQnfi4nla2JTVbVZzIWaiNI0+6Vpm3p95gSo208c99EeyHYmci1Nc12xVr3qRVSRUUR9RcEyh8e1Ucg0C6mm0omSyD78OuxCjijj69NajI3BVnNsd8HXe/ieTCxLiE0v5oqMYu5RiBoiULPfanKYTU5TyPH/bkPmG6942JJJMZHLY1xBiOa6UNXrYV7fbTWq1ynYH8SjWjoSbYFMY8uZ+FATEYvtFvhKx/cgYpliVNVbif1wKatqs9mvgNzlYj+T3Mbrb8zMCUiAJb0pbObx1HCAe6O+0SpU9XqESnSbUUSp6nUw6yVdeU5uyVNCLPfIyDB+HVt9hTsS27H4aonvrsQyWKuq9WJuG9dypBRVtdrIdYGc5ZPDHHKaSo5DTkAbJDqaQDby7Kyefh7jSC+iVPV6VKte89g/YxZRfVkzb8eKYSOekcOd+JImoj6+WxHLW8RmFnMruBZVVR81quoHRk7U01Ahucsll1nkNugE6L8BqtFCNVir5//LOLiH1FT1ekyrXjdSgc5jC99YNjCp6lUvouJYJ4ly8XvwaiKi8B1nFHOqqn6f2D/mWlZybaqqPqZV1bfJyR1ypOoB1fCtGjuC/gaopyDVZmrWAPnM/glm9wL3Ob2IMqvXcUb1GqiIinrh3fff1Xfqo4IUc3pVPS5AVa0Xc2fJyTlytJ+cmbWAanP1haoD1BpQFq36M7gf5jOrhdzfCvilz9eKKL167c8vv15EqcTX9jDxwSaitjYRejHXg2vRq2pVzOWTgwJyUkiO8snZDHKYFWxNKNQ6UBrl/GgMLUJSG3GQRxALjSJqQIAiKj5EEWXTx+R8RlVtFnMDjGJuITnIIycbydEicjaaHKYFWw8KthaUiBTTMTACKc3iR2Ue/51JoTGCSrMXvbSqiEooQxFl20SoYi5BK+Y6c40DueaJ5EDPySxyNYLcpZPLxJLWgpQKfEgxiYFpWuGSzazm8GybTZWXyXmpWvUaU8kSH2oiYrSqOpVrzeTas8lFDrnJ1grLNHKYRE59Ja2G6v/uQz2ctuD+1YVf8iyeaTO5P6ZR2DTHUUyYiiibJkKvqpO41rZcew9y0ZvcZJCrN8ldIrmsVdoXMroS1PNyQ5ymIMVU/psCK5K0IqqWjZ8OfxGefw+jllbMJXHtgXLSnJyp+sZX1nfCgQqXGJ5hE0A8/x/tQhFl0yfX9ZxEk4N4LS9x5KpUOSmLUx8Ga2uI5PjLnnjHclIexyaqveKoUE6qVSXQ26+p/hcoIQAYkehx5QAAAABJRU5ErkJggg==",
}

function EspRadar.texture(state, name)
	state.arrowTextures = state.arrowTextures or {}
	local cached = state.arrowTextures[name]
	if cached ~= nil then return cached or nil end
	state.arrowTextures[name] = false
	local environment, encoded = state.context.environment, ESP_ARROW_ASSETS[name]
	if not encoded or type(environment.getcustomasset) ~= "function" or type(environment.writefile) ~= "function" then return nil end
	local ok, asset = pcall(function()
		local bytes = buffer.tostring(OfflineFiles._decodeBuffer(encoded))
		if #bytes < 60 then return nil end
		if type(environment.makefolder) == "function" then
			if type(environment.isfolder) ~= "function" or not environment.isfolder("PulseHub") then pcall(environment.makefolder, "PulseHub") end
		end
		local path = "PulseHub/esp-arrow-" .. name .. "-" .. tostring(#bytes) .. ".png"
		if type(environment.isfile) ~= "function" or not environment.isfile(path) then environment.writefile(path, bytes) end
		return environment.getcustomasset(path)
	end)
	if ok and type(asset) == "string" and asset ~= "" then state.arrowTextures[name] = asset; return asset end
	return nil
end

function EspRadar.layers(state, frame, create)
	local environment = state.context.environment
	local shade, rim, fill = EspRadar.texture(state, "shade"), EspRadar.texture(state, "rim"), EspRadar.texture(state, "fill")
	if not shade or not rim or not fill then return nil end
	local function image(name, asset, level, color)
		return create("ImageLabel", {Name = name, BackgroundTransparency = 1, Image = asset, ImageColor3 = color,
			AnchorPoint = environment.Vector2.new(0.5, 0.5), Position = environment.UDim2.fromScale(0.5, 0.5),
			Size = environment.UDim2.fromScale(1.45, 1.45), ScaleType = environment.Enum.ScaleType.Stretch,
			ZIndex = level, Visible = false}, frame)
	end
	local shadow = image("ArrowShade", shade, 11, state.colors.black)
	shadow.Position = environment.UDim2.new(0.5, 0, 0.5, 1)
	local outline, body = image("ArrowRim", rim, 12, state.colors.black), image("ArrowFill", fill, 13, state.colors.white)
	create("UIGradient", {Rotation = 90, Color = environment.ColorSequence.new(state.colors.white, environment.Color3.fromRGB(184, 184, 184))}, body)
	return {shade = shadow, rim = outline, fill = body}
end

function EspRadar.create(state, player)
	local environment, parent = state.context.environment, state.createGui()
	local function create(class, properties, owner)
		local object = environment.Instance.new(class)
		for key, value in properties do object[key] = value end
		object.Parent = owner
		return object
	end
	local function stroke(owner, thickness)
		return create("UIStroke", {Thickness = thickness, Color = state.colors.black,
			ApplyStrokeMode = environment.Enum.ApplyStrokeMode.Border, Transparency = 1}, owner)
	end
	local frame = create("Frame", {Name = "Radar_" .. tostring(player.UserId), BackgroundTransparency = 1,
		BorderSizePixel = 0, Active = false, Visible = false, ZIndex = 10, AnchorPoint = environment.Vector2.new(0.5, 0.5),
		BackgroundColor3 = environment.Color3.fromRGB(28, 30, 38)}, parent)
	create("UICorner", {CornerRadius = environment.UDim.new(1, 0)}, frame)
	local dotStroke = stroke(frame, 1)
	local image = create("ImageLabel", {Name = "Avatar", BackgroundTransparency = 1, Size = environment.UDim2.fromScale(1, 1),
		Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(player.UserId) .. "&w=60&h=60", ZIndex = 11}, frame)
	create("UICorner", {CornerRadius = environment.UDim.new(1, 0)}, image)
	local edge = stroke(image, 1.5)
	local arrow = create("TextLabel", {BackgroundTransparency = 1, Size = environment.UDim2.fromScale(1, 1), Text = "▲",
		RichText = false, Font = environment.Enum.Font.GothamBlack, TextScaled = true, TextStrokeTransparency = 0, ZIndex = 11}, frame)
	local text = create("TextLabel", {BackgroundTransparency = 1, AnchorPoint = environment.Vector2.new(0.5, 0),
		Position = environment.UDim2.new(0.5, 0, 1, 3), Size = environment.UDim2.fromOffset(150, 16), TextSize = 11,
		Font = environment.Enum.Font.GothamBold, RichText = false, TextStrokeTransparency = 0.3, ZIndex = 11}, frame)
	local radar = {frame = frame, image = image, edge = edge, arrow = arrow, text = text, dotStroke = dotStroke,
		layers = EspRadar.layers(state, frame, create)}
	state.radars[player] = radar
	return radar
end

function EspRadar.show(state, options)
	local environment, settings = state.context.environment, state.settings
	local radar = state.radars[options.player]
	if not radar or not radar.frame.Parent then radar = EspRadar.create(state, options.player) end
	local style = settings.radarStyle or "Arrow"
	local isAvatar, isDot = style == "Avatar", style == "Dot"
	local isArrow = not isAvatar and not isDot
	local size = math.clamp(settings.arrowSize, 5, 26) * (isAvatar and 3 or 2)
	if isDot then size *= 0.5 end
	if settings.arrowPulse then size *= 1 + 0.12 * math.sin(environment.os.clock() * 4 + options.player.UserId % 89 * 0.4) end
	size = math.max(4, math.floor(size + 0.5))
	local opacity = EspBox.quantize(1 - options.alpha)
	local rotation = math.floor(options.angle * 2 + 0.5) / 2
	radar.frame.Position = environment.UDim2.fromOffset(math.floor(options.position.X + 0.5), math.floor(options.position.Y + 0.5))
	radar.frame.Size = environment.UDim2.fromOffset(size, size)
	radar.image.Visible, radar.arrow.Visible = isAvatar, isArrow and not radar.layers
	if radar.layers then
		local layers = radar.layers
		layers.shade.Visible, layers.rim.Visible, layers.fill.Visible = isArrow, isArrow, isArrow
		if isArrow then
			layers.fill.ImageColor3, layers.fill.ImageTransparency = options.color, opacity
			layers.rim.ImageTransparency = EspBox.quantize(1 - options.alpha * 0.85)
			layers.shade.ImageTransparency = EspBox.quantize(1 - options.alpha * 0.5)
			layers.shade.Rotation, layers.rim.Rotation, layers.fill.Rotation = rotation, rotation, rotation
		end
	end
	radar.image.ImageTransparency = opacity
	if isDot then
		radar.frame.BackgroundColor3, radar.frame.BackgroundTransparency = options.color, opacity
		radar.dotStroke.Color = settings.outlineCol or state.colors.black
		radar.dotStroke.Transparency = EspBox.quantize(1 - options.alpha * 0.5)
	end
	if not isDot then
		radar.frame.BackgroundColor3 = environment.Color3.fromRGB(28, 30, 38)
		radar.frame.BackgroundTransparency = isAvatar and EspBox.quantize(1 - options.alpha * 0.92) or 1
		radar.dotStroke.Transparency = 1
	end
	radar.edge.Color, radar.edge.Transparency = options.color, opacity
	if isArrow and not radar.layers then
		radar.arrow.TextColor3, radar.arrow.TextTransparency, radar.arrow.Rotation = options.color, opacity, rotation
	end
	radar.text.Visible = settings.ringText or settings.arrowName
	if radar.text.Visible then
		radar.text.TextColor3, radar.text.TextTransparency = options.color, opacity
		local name = settings.arrowName and EspText.name(state.text, options.player, settings.nameMode) or ""
		local distance = settings.ringText and EspText.distance(state.text, options.distance, settings.distUnit) or ""
		radar.text.Text = name ~= "" and distance ~= "" and name .. "  " .. distance or name .. distance
	end
	radar.frame.Visible = true
end

function EspRadar.hide(state, player)
	local radar = state.radars[player]
	if radar then radar.frame.Visible = false end
end

function EspRadar.drop(state, player)
	local radar = state.radars[player]
	if radar then pcall(function() radar.frame:Destroy() end) end
	state.radars[player] = nil
end

function EspRadar.clear(state)
	for player in state.radars do EspRadar.drop(state, player) end
end

local EspGhost = {}

function EspGhost.install(state)
	local context, environment = state.context, state.context.environment
	local ghost = {by = {}, last = {}, leak = {}, far = 1000000, keep = 20}
	state.ghost = ghost
	environment.getgenv().__pulseDesyncGhost = ghost
	context.connect(context.runService.Heartbeat, function() EspGhost.update(state) end)
	environment.task.spawn(function()
		local storage = environment.game:GetService("ReplicatedStorage")
		local services = storage:WaitForChild("ClientServices", 30)
		local weapons = services and services:WaitForChild("WeaponService", 30)
		local fired = weapons and weapons:WaitForChild("GunFired", 30)
		if fired then context.connect(fired.OnClientEvent, function(...) EspGhost.fired(state, ...) end) end
	end)
end

function EspGhost.invalid(position, far)
	return position.X ~= position.X or position.Y ~= position.Y or position.Z ~= position.Z or position.Magnitude > far
end

function EspGhost.model(environment)
	local model = environment.Instance.new("Model")
	model.Name = "PulseGhost"
	local function part(name, size, height)
		local object = environment.Instance.new("Part")
		object.Name, object.Size = name, size
		object.Anchored, object.CanCollide, object.CanQuery, object.CanTouch, object.Transparency = true, false, false, false, 1
		object.CFrame, object.Parent = environment.CFrame.new(0, height, 0), model
		return object
	end
	local root = part("HumanoidRootPart", environment.Vector3.new(2, 2, 1), 0)
	part("Head", environment.Vector3.new(1.2, 1.2, 1.2), 2.25)
	part("Feet", environment.Vector3.new(2, 1, 1), -2.5)
	local humanoid = environment.Instance.new("Humanoid")
	humanoid.DisplayDistanceType = environment.Enum.HumanoidDisplayDistanceType.None
	humanoid.HealthDisplayType = environment.Enum.HumanoidHealthDisplayType.AlwaysOff
	humanoid.Parent = model
	model.PrimaryPart = root
	return model
end

function EspGhost.get(state, player)
	local ghost = state.ghost
	if ghost.by[player] then return ghost.by[player] end
	local model = EspGhost.model(state.context.environment)
	local record = {model = model, fake = {Name = player.Name, DisplayName = player.DisplayName, UserId = player.UserId,
		Character = model, Ghost = true, FindFirstChild = function(_, name) return player:FindFirstChild(name) end}}
	ghost.by[player] = record
	return record
end

function EspGhost.drop(state, player)
	local record = state.ghost.by[player]
	if record then pcall(function() record.model:Destroy() end) end
	state.ghost.by[player] = nil
end

function EspGhost.playerFrom(state, instance)
	for _ = 1, 6 do
		if not instance then return nil end
		local player = state.context.players:GetPlayerFromCharacter(instance)
		if player then return player, instance end
		instance = instance.Parent
	end
	return nil
end

function EspGhost.fired(state, instance, start, finish)
	local context, environment, ghost = state.context, state.context.environment, state.ghost
	if environment.typeof(instance) ~= "Instance" then return end
	if environment.typeof(start) == "CFrame" then start = start.Position end
	if environment.typeof(finish) == "CFrame" then finish = finish.Position end
	if environment.typeof(start) ~= "Vector3" or EspGhost.invalid(start, ghost.far) then return end
	local player, character = EspGhost.playerFrom(state, instance)
	if not player or player == context.player then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root or not EspGhost.invalid(root.Position, ghost.far) then return end
	local position = start - environment.Vector3.new(0, 1.25, 0)
	if environment.typeof(finish) == "Vector3" then
		local direction = environment.Vector3.new(finish.X - start.X, 0, finish.Z - start.Z)
		if direction.Magnitude > 0.1 then
			direction = direction.Unit
			position = position - direction * 3.45 - direction:Cross(environment.Vector3.yAxis) * 1.4
		end
	end
	ghost.leak[player] = {p = position, t = environment.os.clock(), ch = character}
end

function EspGhost.update(state)
	local context, environment, ghost = state.context, state.context.environment, state.ghost
	if not state.settings.on then state.settings.extraPlayers = nil; return end
	local now, roles, extras, active = environment.os.clock(), nil, nil, nil
	for _, player in context.players:GetPlayers() do
		if player == context.player then continue end
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = root and character:FindFirstChildOfClass("Humanoid")
		if not root or not humanoid or humanoid.Health <= 0 then continue end
		local position, last = root.Position, ghost.last[player]
		if not EspGhost.invalid(position, ghost.far) then
			last = last or {}
			last.p, last.t, last.ch = position, now, character
			ghost.last[player] = last
			continue
		end
		local saved, savedAt
		if last and last.ch == character then saved, savedAt = last.p, last.t end
		local leak = ghost.leak[player]
		if leak and leak.ch == character and (not savedAt or leak.t > savedAt) then saved, savedAt = leak.p, leak.t end
		if not saved or now - savedAt >= ghost.keep then continue end
		roles, extras, active = roles or context.roles() or {}, extras or {}, active or {}
		local record = EspGhost.get(state, player)
		local age = math.floor(now - savedAt)
		record.fake.Name, record.fake.DisplayName = player.Name, player.DisplayName
		record.fake.GhostTag = age >= 1 and "DESYNC " .. age .. "s" or "DESYNC"
		record.fake.FakeRole = EspRole.of(state.role, player, roles)
		if record.at ~= saved then
			record.at = saved
			pcall(function() record.model:PivotTo(environment.CFrame.new(saved)) end)
		end
		active[player] = true
		table.insert(extras, record.fake)
	end
	for player in ghost.by do if not active or not active[player] then EspGhost.drop(state, player) end end
	if now - (ghost.gcAt or 0) > 1 then
		ghost.gcAt = now
		for player in ghost.last do
			if not player.Parent then ghost.last[player], ghost.leak[player] = nil, nil end
		end
	end
	state.settings.extraPlayers = extras
end

function EspGhost.stop(state)
	state.settings.extraPlayers = nil
	for player in state.ghost.by do EspGhost.drop(state, player) end
end

local EspFeature = {}

function EspFeature.create(context)
	local environment, globals = context.environment, context.environment.getgenv()
	if globals.__pulseESP2Stop then pcall(globals.__pulseESP2Stop) end
	local settings = EspSettings.create(environment, context.configuration)
	local state = {context = context, settings = settings, role = EspRole.create(environment.os.clock),
		projection = EspProjection.create(environment), objects = {}, labels = {}, retryAt = {}, colorHandles = {}, text = EspText.create(),
		highlights = {}, chamStates = {}, models = {}, halos = {}, radars = {}, skipDelta = setmetatable({}, {__mode = "k"}),
		chamsMaterials = EspChams.materials(environment)}
	state.createGui = function() return EspFeature.root(state) end
	state.colors = EspColor.create(environment, settings)
	state.boxContext = {environment = environment, settings = settings, colors = state.colors}
	settings.I = state
	settings.onChange = function(key)
		if key == "on" and not settings.on then EspFeature.hideAll(state) end
		if key == "offscreen" and not settings.offscreen or key == "radarStyle" then EspRadar.clear(state) end
		if key == "chams" and not settings.chams or key == "chamsMaterial" or key == "chamsStyle" or key == "chamsShell" then
			EspChams.clear(state)
		end
	end
	settings.stop = function() EspFeature.stop(state) end
	globals.__pulseESP2, globals.__pulseESP2Stop = settings, settings.stop

	local event = context.runService.PreRender or context.runService.RenderStepped
	state.connection = context.connect(event, function(delta)
		local ok, raised = pcall(EspFeature.step, state, delta)
		if not ok then state.lastError = tostring(raised) end
	end)
	context.connect(context.players.PlayerRemoving, function(player) EspFeature.release(state, player) end)
	EspGhost.install(state)
	return state
end

function EspFeature.root(state)
	if state.gui and state.gui.Parent then return state.gui end
	local context, environment = state.context, state.context.environment
	local holder = context.coreGui
	if not holder or not holder.Parent then holder = context.player:FindFirstChildOfClass("PlayerGui") end
	local gui = environment.Instance.new("ScreenGui")
	gui.Name, gui.ResetOnSpawn, gui.IgnoreGuiInset = "PulseESP2", false, true
	gui.DisplayOrder, gui.ZIndexBehavior = 9, environment.Enum.ZIndexBehavior.Sibling
	gui.Parent = holder
	state.gui = gui
	return gui
end

function EspFeature.release(state, player)
	local object = state.objects[player]
	if object then pcall(function() object.layer:Destroy() end) end
	state.objects[player], state.retryAt[player] = nil, nil
	EspChams.drop(state, player)
	EspChamModel.purge(state, player)
	EspRadar.drop(state, player)
	EspLabel.release(state, player)
end

function EspFeature.hide(state, player)
	local object = state.objects[player]
	if not object then return end
	object.layer.Visible = false
	EspLabel.hide(state, player)
	EspRadar.hide(state, player)
	object.rect, object.rel, object.hpRatio, object.drawState = nil, nil, nil, nil
end

function EspFeature.hideAll(state)
	EspChams.clear(state)
	for player in state.objects do EspFeature.hide(state, player) end
end

function EspFeature.stop(state)
	EspGhost.stop(state)
	pcall(EspLabel.restoreNames, state)
	EspChams.clear(state)
	EspChamModel.purge(state)
	EspChamModel.unbind(state)
	EspRadar.clear(state)
	if state.modelFolder then pcall(function() state.modelFolder:Destroy() end) end
	if state.connection then pcall(function() state.connection:Disconnect() end) end
	for player in state.objects do EspFeature.release(state, player) end
	if state.gui then pcall(function() state.gui:Destroy() end) end
	if state.labelGui then pcall(function() state.labelGui:Destroy() end) end
	state.gui, state.labelGui = nil, nil
end

function EspFeature.prepareProjection(state, camera)
	local frame, viewport = camera.CFrame, camera.ViewportSize
	local centerX, centerY = viewport.X * 0.5, viewport.Y * 0.5
	local focal = centerY / math.tan(math.rad(camera.FieldOfView) * 0.5)
	local point = frame.Position + frame.LookVector * 20 + frame.RightVector * 3 + frame.UpVector * 2
	local projected, localPoint = camera:WorldToViewportPoint(point), frame:PointToObjectSpace(point)
	local depth = -localPoint.Z
	local enabled = false
	if depth > 0.08 then
		local x, y = centerX + localPoint.X / depth * focal, centerY - localPoint.Y / depth * focal
		enabled = math.abs(x - projected.X) < 0.5 and math.abs(y - projected.Y) < 0.5 and math.abs(depth - projected.Z) < 0.05
	end
	state.projection.projection = {frame = frame, centerX = centerX, centerY = centerY, focal = focal, enabled = enabled}
end

function EspFeature.update(state, player, roles, camera, delta)
	local context, settings = state.context, state.settings
	local character = player.Character
	local parts = character and EspRole.partsOf(state.role, character)
	local humanoid, root = parts and parts.hum, parts and parts.root
	local role = EspRole.of(state.role, player, roles)
	if not character or not root or not humanoid or humanoid.Health <= 0 or not EspRole.shown(settings, role) then
		EspFeature.hide(state, player)
		EspChams.drop(state, player)
		return
	end

	local distance = (root.Position - camera.CFrame.Position).Magnitude
	if distance > settings.maxDist then EspFeature.hide(state, player); EspChams.drop(state, player); return end
	local object = state.objects[player]
	if not object or not object.layer.Parent then
		object = EspBox.create(state.boxContext, EspFeature.root(state), player.UserId)
		object.tracer = EspTracer.create(state.context, object)
		state.objects[player] = object
	end
	if object.character ~= character then
		object.character, object.rect, object.rel, object.hpRatio = character, nil, nil, nil
	end
	local now = context.environment.os.clock()
	local inView, viewPoint = EspProjection.inView(state.projection, camera, root.Position)
	if (settings.visCheck or (settings.chams or settings.skeleton) and inView) and (not object.seenAt or now - object.seenAt > 0.12) then
		object.seen = EspProjection.visible(context, camera.CFrame.Position, parts.head or root, character)
		object.seenAt = now
	end
	local isVisible = not settings.visCheck or object.seen ~= false
	local color = EspColor.select(state.colors, role, isVisible, distance)
	local alpha = EspProjection.alpha(settings, distance, isVisible)
	object.role = role
	object.boxOff = settings.limits and (tonumber(settings.boxMaxDist) or 0) > 0 and distance > settings.boxMaxDist
	object.skelOff = settings.limits and (tonumber(settings.skelMaxDist) or 0) > 0 and distance > settings.skelMaxDist
	state.boxContext.lineWidthFactor = settings.distScale and math.clamp(90 / math.max(distance, 1), 0.55, 1.6) or 1
	local isGhost = type(player) == "table" and player.Ghost == true
	local exceedsChamLimit = settings.limits and (tonumber(settings.chamsMaxDist) or 0) > 0 and distance > settings.chamsMaxDist
	if isGhost or exceedsChamLimit then EspChams.drop(state, player) end
	if not isGhost and not exceedsChamLimit then
		EspChams.apply(state, {player = player, character = character, role = role, seen = object.seen ~= false,
			alpha = alpha, inView = inView, distance = distance, cameraPosition = camera.CFrame.Position})
	end
	local rectangle = EspProjection.project(state.projection, character, root, camera, settings.boxWidth)
	if not rectangle then
		EspLabel.hide(state, player)
		object.rect, object.rel, object.drawState = nil, nil, nil
		local target, angle = EspTracer.point(state, camera, root.Position)
		if settings.offscreen then
			EspRadar.show(state, {player = player, position = target, angle = angle, color = color, distance = distance, alpha = alpha})
		end
		if not settings.offscreen then EspRadar.hide(state, player) end
		if not settings.tracer then
			object.layer.Visible = false
			return
		end
		object.box.Visible, object.glow.Visible, object.outer.Visible = false, false, false
		if object.inner then object.inner.Visible = false end
		if object.head then object.head.Visible = false end
		if object.look then object.look.frame.Visible = false end
		EspSkeleton.hide(object)
		EspBox.hideSegments(object, 1)
		state.boxContext.lineWidthFactor = settings.distScale and math.clamp(90 / math.max(distance, 1), 0.55, 1.6) or 1
		EspTracer.draw(state, object, EspTracer.origin(state, camera), target, color, alpha, role)
		object.layer.Visible = true
		return
	end
	EspRadar.hide(state, player)
	local point = viewPoint or EspProjection.point(state.projection, camera, root.Position)
	local focus = settings.murdererFocus == true and role == "Murderer"
	local frame = {character = character, rectangle = rectangle, point = point, color = color, alpha = alpha, focus = focus, delta = delta}
	if EspFeature.shouldSkip(state, object, frame) then return end
	local elapsed = EspFeature.rememberFrame(object, frame)
	local center = point.Z > 0.08 and {X = point.X, Y = point.Y} or nil
	rectangle = EspProjection.smooth(object, rectangle, camera.ViewportSize, settings.smooth, elapsed, center)
	object.layer.Visible = true
	EspBox.draw(state.boxContext, object, rectangle, color, alpha, player, focus)
	if rectangle.h < (EspSkeleton.perf(state) and 48 or 26) then object.skelOff = true end
	EspSkeleton.draw(state, object, character, rectangle, color, alpha, camera)
	EspHead.draw(state, object, parts.head or root, rectangle, color, alpha, camera)
	EspHead.look(state, object, parts.head or root, color, alpha, camera)
	if settings.tracer then
		local targetY = rectangle.y + rectangle.h
		if settings.tracerTo == "Center" then targetY = rectangle.y + rectangle.h * 0.5 end
		if settings.tracerTo == "Head" then targetY = rectangle.y end
		local target = context.environment.Vector2.new(rectangle.x + rectangle.w * 0.5, targetY)
		EspTracer.draw(state, object, EspTracer.origin(state, camera), target, color, alpha, role)
	end
	if not settings.tracer then object.tracer.frame.Visible = false end
	local exceedsNameLimit = settings.limits and (tonumber(settings.nameMaxDist) or 0) > 0 and distance > settings.nameMaxDist
	if exceedsNameLimit then EspLabel.hide(state, player); return end
	local weapon, equipped = EspRole.weaponOf(state.role, player, role)
	EspLabel.update(state, player, rectangle, {alpha = alpha, color = color, role = role,
		roleColor = EspColor.role(state.colors, role), weapon = weapon, equipped = equipped, distance = distance, focus = focus,
		ghostTag = isGhost and player.GhostTag or nil})
end

function EspFeature.shouldSkip(state, object, options)
	local previous = object.drawState
	if not previous or state.settings.skipFrames == false or previous.n >= 1 or previous.character ~= options.character then return false end
	if options.rectangle.h >= 160 or previous.color ~= options.color or previous.alpha ~= options.alpha or previous.focus ~= options.focus then return false end
	if math.abs(options.point.X - previous.x) >= 1 or math.abs(options.point.Y - previous.y) >= 1 then return false end
	if math.abs(options.rectangle.h - previous.height) >= 1 or math.abs(options.rectangle.w - previous.width) >= 1 then return false end
	previous.n, previous.delta = previous.n + 1, previous.delta + options.delta
	return true
end

function EspFeature.rememberFrame(object, options)
	local previous = object.drawState
	local elapsed = options.delta + (previous and previous.delta or 0)
	object.drawState = {n = 0, delta = 0, character = options.character, x = options.point.X, y = options.point.Y,
		height = options.rectangle.h, width = options.rectangle.w, color = options.color, alpha = options.alpha, focus = options.focus}
	return elapsed
end

function EspFeature.step(state, delta)
	pcall(EspLabel.gameNames, state)
	if not state.settings.on then EspFeature.hideAll(state); return end
	local context = state.context
	local camera = context.workspace.CurrentCamera
	if not camera then EspFeature.hideAll(state); return end
	state.viewport = camera.ViewportSize
	state.projection.projection = nil
	pcall(EspFeature.prepareProjection, state, camera)

	local roles, present, now = context.roles(), {}, context.environment.os.clock()
	state.modelBudget = 1
	if not state.poolSweepAt or now >= state.poolSweepAt then
		state.poolSweepAt = now + 5
		pcall(EspChamModel.sweep, state)
	end
	state.frameNumber = (state.frameNumber or 0) + 1
	local index, performance = 0, EspSkeleton.perf(state)
	for _, player in context.players:GetPlayers() do
		if player == context.player then continue end
		present[player] = true
		index += 1
		if performance and (index + state.frameNumber) % 2 == 1 and state.objects[player] then
			state.skipDelta[player] = (state.skipDelta[player] or 0) + delta
			continue
		end
		if state.retryAt[player] and now < state.retryAt[player] then continue end
		local elapsed = delta + (state.skipDelta[player] or 0)
		state.skipDelta[player] = nil
		local ok, raised = pcall(EspFeature.update, state, player, roles, camera, elapsed)
		if not ok then
			state.lastError, state.retryAt[player] = tostring(raised), now + 0.5
			EspFeature.hide(state, player)
			EspChams.drop(state, player)
		end
		if ok then state.retryAt[player] = nil end
	end
	for _, player in state.settings.extraPlayers or {} do
		present[player] = true
		local ok, raised = pcall(EspFeature.update, state, player, roles, camera, delta)
		if not ok then state.lastError = tostring(raised) end
	end
	for player in state.objects do if not present[player] then EspFeature.release(state, player) end end
end

function EspFeature.toggle(state, field, text, children)
	local section, settings = state.context.section, state.settings
	section:Toggle({Text = text, Default = settings[field] == true, Settings = children, Callback = function(value)
		settings[field] = not not value
		settings.onChange(field)
	end})
end

function EspFeature.slider(state, options)
	local section, settings, field = state.context.section, state.settings, options.field
	section:Slider({Text = options.text, Min = options.min, Max = options.max, Default = settings[field],
		Decimals = options.decimals or 0, Suffix = options.suffix or "", Callback = function(value)
			settings[field] = value
			settings.onChange(field)
		end})
end

function EspFeature.dropdown(state, field, text, values)
	local section, settings, options = state.context.section, state.settings, {}
	for _, value in values do table.insert(options, {code = value, label = value}) end
	section:Dropdown({Text = text, Options = options, Default = settings[field], Callback = function(value)
		if value == nil then return end
		settings[field] = value
		settings.onChange(field)
	end})
end

function EspFeature.colorpicker(state, field, text)
	local section, settings = state.context.section, state.settings
	state.colorHandles[field] = section:Colorpicker({Text = text, Default = settings[field], Callback = function(value)
		if state.context.environment.typeof(value) == "Color3" then settings[field] = value end
	end})
end

function EspFeature.mainControls(state)
	local section = state.context.section
	section:Group({Title = "ESP", Side = "Left"})
	EspFeature.toggle(state, "on", "Enable ESP")
	for _, option in {{"murderer", "Show Murderer"}, {"sheriff", "Show Sheriff"}, {"hero", "Show Hero"},
		{"innocent", "Show Innocent"}, {"noRole", "Show No Role"}} do
		EspFeature.toggle(state, option[1], option[2])
	end
	EspFeature.slider(state, {field = "maxDist", text = "Max Distance", min = 50, max = 2000, decimals = 0, suffix = " st"})
	EspFeature.toggle(state, "visCheck", "Visibility Check", function()
		EspFeature.toggle(state, "dimHidden", "Dim Hidden")
		EspFeature.dropdown(state, "hiddenStyle", "Hidden Style", {"Fade", "Grey"})
	end)
end

function EspFeature.boxControls(state)
	local section = state.context.section
	local sources = {"ESP", "Custom", "White", "Light", "Dark"}
	local styles = {"Corners", "Full", "Rounded", "Double", "Brackets"}
	section:Group({Title = "ESP Box", Side = "Right"})
	EspFeature.toggle(state, "box", "Player Box", function()
		EspFeature.dropdown(state, "boxStyle", "Frame Style", styles)
		EspFeature.slider(state, {field = "boxThickness", text = "Line Thickness", min = 0.5, max = 5, decimals = 1})
		EspFeature.slider(state, {field = "cornerSize", text = "Corner Length", min = 8, max = 50, decimals = 0, suffix = "%"})
		EspFeature.slider(state, {field = "boxRound", text = "Corner Radius", min = 0, max = 20, decimals = 0})
		EspFeature.slider(state, {field = "boxWidth", text = "Box Width", min = 30, max = 90, decimals = 0, suffix = "%"})
		EspFeature.slider(state, {field = "boxPad", text = "Box Padding", min = -6, max = 20, decimals = 0})
		EspFeature.dropdown(state, "boxColMode", "Box Color Source", sources)
		EspFeature.colorpicker(state, "boxCol", "Box Custom Color")
		EspFeature.dropdown(state, "boxAnim", "Box Animation", {"None", "Pulse", "Breathe"})
		EspFeature.slider(state, {field = "boxAnimSpeed", text = "Box Animation Speed", min = 0.2, max = 4, decimals = 1})
		EspFeature.dropdown(state, "murdBox", "Murderer Box Style", {"Same", "Corners", "Full", "Rounded", "Double", "Brackets"})
	end)
	EspFeature.toggle(state, "outline", "Dark Outline", function()
		EspFeature.toggle(state, "outlineInner", "Inner Outline")
		EspFeature.colorpicker(state, "outlineCol", "Outline Color")
		EspFeature.slider(state, {field = "outlineAlpha", text = "Outline Opacity", min = 0, max = 100, decimals = 0, suffix = "%"})
		EspFeature.slider(state, {field = "outlineSize", text = "Outline Size", min = 1, max = 6, decimals = 0})
	end)
	EspFeature.toggle(state, "boxFill", "Filled Box", function()
		EspFeature.slider(state, {field = "boxFillAlpha", text = "Fill Strength", min = 0, max = 100, decimals = 0, suffix = "%"})
		EspFeature.dropdown(state, "fillStyle", "Fill Style", {"Solid", "Fade Down", "Fade Up"})
		EspFeature.dropdown(state, "fillColMode", "Fill Color Source", sources)
		EspFeature.colorpicker(state, "fillCol", "Fill Custom Color")
	end)
	EspFeature.toggle(state, "boxGlow", "Soft Glow", function()
		EspFeature.slider(state, {field = "glowStrength", text = "Glow Strength", min = 0, max = 60, decimals = 0, suffix = "%"})
		EspFeature.slider(state, {field = "glowSize", text = "Glow Size", min = 2, max = 20, decimals = 0})
		EspFeature.toggle(state, "pulse", "Gentle Pulse")
		EspFeature.slider(state, {field = "pulseSpeed", text = "Pulse Speed", min = 0.2, max = 4, decimals = 1})
		EspFeature.dropdown(state, "glowColMode", "Glow Color Source", sources)
		EspFeature.colorpicker(state, "glowCol", "Glow Custom Color")
	end)
	EspFeature.toggle(state, "gradient", "Gradient", function()
		EspFeature.colorpicker(state, "gradientColour", "Second Color")
		EspFeature.dropdown(state, "boxGradStyle", "Box Gradient Style", {"Two Color", "Role Fade"})
		EspFeature.slider(state, {field = "boxGradAngle", text = "Box Gradient Angle", min = 0, max = 360, decimals = 0, suffix = "°"})
	end)
end

function EspFeature.colorControls(state)
	local section, environment = state.context.section, state.context.environment
	section:Group({Title = "ESP Colors", Side = "Left"})
	EspFeature.dropdown(state, "colorMode", "Color Mode", {"Role", "Rainbow", "Custom", "Distance", "Visibility"})
	local palettes = {
		Classic = {{255, 64, 64}, {80, 150, 255}, {255, 210, 60}, {90, 230, 130}, {176, 182, 204}},
		Soft = {{255, 107, 107}, {116, 170, 255}, {255, 205, 112}, {125, 222, 170}, {190, 196, 212}},
		Muted = {{224, 102, 102}, {110, 150, 210}, {214, 180, 106}, {120, 190, 150}, {168, 172, 184}},
		Pastel = {{255, 150, 160}, {160, 196, 255}, {255, 226, 160}, {170, 234, 196}, {210, 212, 224}},
		Mono = {{255, 92, 92}, {232, 232, 236}, {232, 232, 236}, {190, 192, 200}, {150, 152, 160}},
		Ocean = {{255, 110, 120}, {90, 170, 255}, {120, 220, 230}, {150, 205, 255}, {170, 185, 205}},
	}
	local options, ready = {}, false
	for _, name in {"Classic", "Soft", "Muted", "Pastel", "Mono", "Ocean"} do table.insert(options, {code = name, label = name}) end
	section:Dropdown({Text = "Role Palette", NoSave = true, Options = options, Default = "Classic", Callback = function(name)
		if not ready or not palettes[name] then return end
		for index, field in {"murdererColour", "sheriffColour", "heroColour", "innocentColour", "noRoleColour"} do
			local rgb = palettes[name][index]
			local color = environment.Color3.fromRGB(rgb[1], rgb[2], rgb[3])
			state.settings[field] = color
			local handle = state.colorHandles[field]
			if handle and handle.Set then pcall(handle.Set, color) end
		end
	end})
	ready = true
	for _, option in {{"murdererColour", "Murderer Color"}, {"sheriffColour", "Sheriff Color"},
		{"heroColour", "Hero Color"}, {"innocentColour", "Innocent Color"}, {"noRoleColour", "No Role Color"},
		{"nameColour", "Name Color"}, {"infoColour", "Detail Color"}, {"customColour", "Custom Color"},
		{"nearColour", "Near Color"}, {"farColour", "Far Color"}, {"seenColour", "Seen Color"}, {"hiddenColour", "Hidden Color"}} do
		EspFeature.colorpicker(state, option[1], option[2])
	end
end

function EspFeature.lookControls(state)
	state.context.section:Group({Title = "ESP Look", Side = "Right"})
	for _, option in {{"brightness", "ESP Brightness", 20, 200}, {"saturation", "ESP Saturation", 0, 200},
		{"opacity", "ESP Opacity", 10, 100}, {"lineScale", "Line Scale", 50, 300}, {"smooth", "Smoothing", 0, 90}} do
		EspFeature.slider(state, {field = option[1], text = option[2], min = option[3], max = option[4], suffix = "%"})
	end
	EspFeature.toggle(state, "fade", "Distance Fade", function()
		EspFeature.slider(state, {field = "fadeFrom", text = "Fade Start", min = 10, max = 95, suffix = "%"})
	end)
	EspFeature.toggle(state, "distScale", "Scale Lines With Distance")
	EspFeature.toggle(state, "limits", "Element Limits", function()
		EspFeature.slider(state, {field = "boxMaxDist", text = "Box Max Distance", min = 0, max = 2000, suffix = " st"})
		EspFeature.slider(state, {field = "nameMaxDist", text = "Name Max Distance", min = 0, max = 2000, suffix = " st"})
		EspFeature.slider(state, {field = "chamsMaxDist", text = "Chams Max Distance", min = 0, max = 2000, suffix = " st"})
		EspFeature.slider(state, {field = "skelMaxDist", text = "Skeleton Max Distance", min = 0, max = 2000, suffix = " st"})
	end)
	EspFeature.toggle(state, "murdererFocus", "Murderer Focus", function()
		EspFeature.slider(state, {field = "focusScale", text = "Focus Thickness", min = 100, max = 300, suffix = "%"})
	end)
end

function EspFeature.textControls(state)
	state.context.section:Group({Title = "ESP Text", Side = "Left"})
	EspFeature.toggle(state, "name", "Player Name", function()
		EspFeature.dropdown(state, "nameMode", "Name Format", {"Display name", "Username", "Both"})
		EspFeature.slider(state, {field = "textSize", text = "Name Size", min = 9, max = 22})
		EspFeature.dropdown(state, "nameWeight", "Name Weight", {"Regular", "Medium", "SemiBold", "Bold", "Heavy"})
		EspFeature.dropdown(state, "nameCase", "Name Case", {"Normal", "UPPER", "lower"})
		EspFeature.dropdown(state, "namePos", "Name Position", {"Above", "Below"})
		EspFeature.toggle(state, "textMatch", "Colored Name")
		EspFeature.toggle(state, "hideGameNames", "Hide Game Names")
	end)
	EspFeature.toggle(state, "roleText", "Role Text", function()
		EspFeature.dropdown(state, "roleStyle", "Role Style", {"Full", "Short", "Upper"})
	end)
	EspFeature.toggle(state, "weaponIcon", "Weapon Icon", function()
		EspFeature.dropdown(state, "weaponStyle", "Weapon Display", {"Icon", "Text", "Both"})
	end)
	EspFeature.toggle(state, "distance", "Distance", function()
		EspFeature.dropdown(state, "distUnit", "Distance Unit", {"Studs", "Meters"})
	end)
	EspFeature.dropdown(state, "textFont", "Font", {"GothamSSm", "Gotham", "Montserrat", "Code", "Source Sans", "Fredoka",
		"Luckiest Guy", "Bangers", "Cartoon", "Arcade", "Sci-Fi", "Michroma", "Jura", "Sarpanch", "Oswald", "Ubuntu", "Nunito",
		"Roboto", "Roboto Condensed", "Titillium", "Builder Sans", "Arimo", "Highway", "Denk One", "Creepster", "Permanent Marker",
		"Kalam", "Indie Flower", "Patrick Hand", "Amatic", "Special Elite", "Grenze Gotisch", "Bodoni", "Merriweather", "Garamond",
		"Antique", "Fantasy"})
	EspFeature.slider(state, {field = "infoSize", text = "Detail Size", min = 9, max = 20})
	EspFeature.dropdown(state, "infoCase", "Detail Case", {"Normal", "UPPER"})
	EspFeature.toggle(state, "textOutline", "Text Outline", function()
		EspFeature.slider(state, {field = "textOutlineAlpha", text = "Text Outline Opacity", min = 0, max = 100, suffix = "%"})
	end)
end

function EspFeature.tracerControls(state)
	state.context.section:Group({Title = "ESP Extras", Side = "Right"})
	EspFeature.toggle(state, "skeleton", "Skeleton", function()
		EspFeature.slider(state, {field = "boneThick", text = "Bone Thickness", min = 0.5, max = 6, decimals = 1})
		EspFeature.dropdown(state, "boneStyle", "Bone Style", {"Line", "Soft Glow"})
		EspFeature.slider(state, {field = "boneAlpha", text = "Bone Opacity", min = 10, max = 100, suffix = "%"})
		EspFeature.toggle(state, "boneRole", "Role Bones")
		EspFeature.colorpicker(state, "boneColour", "Bone Color")
		EspFeature.colorpicker(state, "boneHidden", "Hidden Bones")
		EspFeature.toggle(state, "joints", "Joints")
		EspFeature.slider(state, {field = "jointSize", text = "Joint Size", min = 2, max = 12})
		EspFeature.toggle(state, "boneGrad", "Bone Gradient")
		EspFeature.colorpicker(state, "boneTop", "Bone Top Color")
		EspFeature.colorpicker(state, "boneBottom", "Bone Bottom Color")
	end)
	EspFeature.toggle(state, "headDot", "Head Circle", function()
		EspFeature.dropdown(state, "headStyle", "Head Style", {"Ring", "Filled", "Dot"})
		EspFeature.slider(state, {field = "headScale", text = "Head Size", min = 40, max = 250, suffix = "%"})
		EspFeature.slider(state, {field = "headFill", text = "Head Fill", min = 0, max = 100, suffix = "%"})
		EspFeature.dropdown(state, "headColMode", "Head Color Source", {"ESP", "Custom", "White", "Light", "Dark"})
		EspFeature.colorpicker(state, "headCol", "Head Custom Color")
	end)
	EspFeature.toggle(state, "lookLine", "View Direction", function()
		EspFeature.slider(state, {field = "lookLength", text = "Line Length", min = 3, max = 40})
		EspFeature.slider(state, {field = "lookThick", text = "View Line Width", min = 0.5, max = 5, decimals = 1})
		EspFeature.dropdown(state, "lookColMode", "View Line Color Source", {"ESP", "Custom", "White", "Light", "Dark"})
		EspFeature.colorpicker(state, "lookCol", "View Line Color")
	end)
	EspFeature.toggle(state, "tracer", "Tracers", function()
		EspFeature.dropdown(state, "tracerFrom", "Tracer Origin", {"Bottom", "Middle", "Top", "Mouse", "Character"})
		EspFeature.dropdown(state, "tracerTo", "Tracer Target", {"Feet", "Center", "Head"})
		EspFeature.dropdown(state, "tracerStyle", "Tracer Style", {"Line", "Fade"})
		EspFeature.slider(state, {field = "tracerThickness", text = "Tracer Width", min = 0.5, max = 4, decimals = 1})
		EspFeature.slider(state, {field = "tracerAlpha", text = "Tracer Opacity", min = 0, max = 100, suffix = "%"})
		EspFeature.toggle(state, "tracerRole", "Role Tracers")
		EspFeature.colorpicker(state, "tracerColour", "Tracer Color")
		EspFeature.toggle(state, "tracerMurderer", "Murderer Tracer Only")
	end)
	EspFeature.toggle(state, "offscreen", "Offscreen Arrows", function()
		EspFeature.dropdown(state, "radarStyle", "Marker Style", {"Arrow", "Avatar", "Dot"})
		EspFeature.dropdown(state, "markerPos", "Marker Position", {"Around Center", "Screen Edge"})
		EspFeature.slider(state, {field = "ringRadius", text = "Radar Spread", min = 60, max = 420})
		EspFeature.slider(state, {field = "arrowSize", text = "Marker Size", min = 5, max = 26})
		EspFeature.toggle(state, "ringText", "Marker Distance")
		EspFeature.toggle(state, "arrowPulse", "Marker Pulse")
		EspFeature.toggle(state, "arrowName", "Marker Name")
	end)
end

function EspFeature.chamsControls(state)
	local section = state.context.section
	local materials = {"Flat", "Shaded", "Metallic", "Metal", "Chrome", "Glossy", "Glass", "Crystal", "Ice", "Lava", "Glow",
		"Glow Outline", "Iridescent", "Water Flow", "ForceField", "Gradient", "Ghost", "Wireframe"}
	local overrides = {"Same"}
	for _, material in materials do table.insert(overrides, material) end
	section:Group({Title = "ESP Chams", Side = "Left"})
	EspFeature.toggle(state, "chams", "Chams", function()
		EspFeature.toggle(state, "chamsThrough", "Through Walls")
		EspFeature.slider(state, {field = "chamsRange", text = "Through Range", min = 20, max = 300})
		EspFeature.slider(state, {field = "chamsHiddenDark", text = "Hidden Darkness", min = 0, max = 80, suffix = "%"})
		EspFeature.slider(state, {field = "chamsAlpha", text = "Fill Strength", min = 0, max = 100, suffix = "%"})
		EspFeature.slider(state, {field = "glowCore", text = "Glow Core", min = 20, max = 100, suffix = "%"})
		EspFeature.slider(state, {field = "glowHalo", text = "Glow Halo", min = 0, max = 100, suffix = "%"})
		EspFeature.slider(state, {field = "chamsBright", text = "Chams Brightness", min = 30, max = 200, suffix = "%"})
		EspFeature.slider(state, {field = "chamsShell", text = "Shell Size", min = 100, max = 130, suffix = "%"})
		EspFeature.slider(state, {field = "chamsSpeed", text = "Animation Speed", min = 0.2, max = 3, decimals = 1})
		EspFeature.colorpicker(state, "chamsFlow", "Flow Color")
		EspFeature.colorpicker(state, "chamsGradA", "Body Gradient Top")
		EspFeature.colorpicker(state, "chamsGradB", "Body Gradient Bottom")
		EspFeature.toggle(state, "chamsGradScroll", "Scroll Body Gradient")
		EspFeature.dropdown(state, "murdMat", "Murderer Material", overrides)
		EspFeature.dropdown(state, "sheriffMat", "Sheriff Material", overrides)
	end)
	EspFeature.dropdown(state, "chamsStyle", "Chams Style", {"Soft", "Outline", "Solid", "Glow"})
	EspFeature.dropdown(state, "chamsMaterial", "Material", materials)
	EspFeature.toggle(state, "chamsOutline", "Chams Outline", function()
		EspFeature.slider(state, {field = "chamsEdgeAlpha", text = "Edge Strength", min = 0, max = 100, suffix = "%"})
		EspFeature.toggle(state, "chamsEdgeRole", "Role Edge")
		EspFeature.colorpicker(state, "chamsEdge", "Visible Edge")
		EspFeature.colorpicker(state, "chamsEdgeHidden", "Hidden Edge")
	end)
	EspFeature.toggle(state, "chamsRole", "Role Colors", function()
		EspFeature.colorpicker(state, "chamsColour", "Visible Fill")
		EspFeature.colorpicker(state, "chamsHidden", "Hidden Fill")
	end)
	EspFeature.toggle(state, "chamsOverlay", "Glow Overlay")
	EspFeature.dropdown(state, "chamsAnim", "Animation", {"None", "Pulse", "Breathe", "Flow"})
	EspFeature.toggle(state, "chamsFlash", "Flash On Sight")
end
-- ===== END extracted ESP module =====

local esp = EspFeature.create(context)
EspFeature.mainControls(esp)
EspFeature.boxControls(esp)
EspFeature.textControls(esp)
EspFeature.chamsControls(esp)
EspFeature.tracerControls(esp)
EspFeature.colorControls(esp)
EspFeature.lookControls(esp)

-- ใช้ USER_CONFIG override ค่า default
if esp and esp.settings then
	for k, v in pairs(USER_CONFIG) do esp.settings[k] = v end
end

local g = environment.getgenv()
g.PulseEspStop = function()
	if esp and esp.settings and esp.settings.stop then esp.settings.stop() end
end

print("[PulseHub ESP] standalone loaded. Stop: getgenv().PulseEspStop()")
