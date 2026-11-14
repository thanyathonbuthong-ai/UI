--!nocheck
--!nolint
--[[
	c0caine UI Library
	A standalone Roblox (Luau) UI library extracted from the c0caine menu: the same tokens, themes,
	brushed-metal / acrylic look, motion, controls, window, toasts and watermark.

	local Library = loadstring(readfile("CocaineUI.lua"))()
	local Window  = Library:CreateWindow({ Title = "c0caine", Version = "1.0.0" })
	local Tab     = Window:AddTab("Aimbot", { Icon = "gps_fixed", Section = "Combat", Subs = { "General", "Advanced" } })
	local Group   = Tab:AddGroup("Aim", { Sub = "General", Side = "L" })
	Group:AddToggle("Enabled", "aimEnabled", { Desc = "Turns the aimbot on." })
	Group:AddSlider("FOV", "aimFov", 1, 360, 1, { Unit = "°" })
	Library:Notify("Loaded", 3, "ok")
]]

-------------------------------------------------------------------------------
-- services + executor shim
-------------------------------------------------------------------------------
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer

local function envFn(...)
	local env: any = nil
	local okG, gg = pcall(function()
		return getgenv
	end)
	if okG and type(gg) == "function" then
		local okE, e = pcall(gg)
		if okE and type(e) == "table" then
			env = e
		end
	end
	local fenv: any = nil
	pcall(function()
		fenv = getfenv(0)
	end)
	for _, name in ipairs({ ... }) do
		local v = nil
		if type(env) == "table" then
			v = env[name]
		end
		if v == nil and type(fenv) == "table" then
			v = fenv[name]
		end
		if v ~= nil then
			return v
		end
	end
	return nil
end

local EXEC = {
	isfile = envFn("isfile"),
	readfile = envFn("readfile"),
	writefile = envFn("writefile"),
	isfolder = envFn("isfolder"),
	makefolder = envFn("makefolder"),
	request = envFn("request", "http_request", "httprequest"),
	getcustomasset = envFn("getcustomasset", "getsynasset"),
	gethui = envFn("gethui", "get_hidden_gui"),
}
EXEC.caps = { files = type(EXEC.writefile) == "function" and type(EXEC.readfile) == "function" and type(EXEC.isfile) == "function" }

local function parentGui(gui: ScreenGui): boolean
	if type(EXEC.gethui) == "function" then
		local ok, h = pcall(EXEC.gethui)
		if ok and typeof(h) == "Instance" then
			gui.Parent = h
			return true
		end
	end
	if pcall(function()
		gui.Parent = game:GetService("CoreGui")
	end) and gui.Parent then
		return true
	end
	local pg = LP and LP:FindFirstChildOfClass("PlayerGui")
	if pg then
		gui.Parent = pg
		return true
	end
	return false
end

local function log(level: string, ...)
	if level == "WARN" or level == "ERROR" then
		warn("[c0caine-ui]", ...)
	end
end

local function reportError(stage: string, err: any)
	warn("[c0caine-ui] " .. stage .. ": " .. tostring(err))
end

-------------------------------------------------------------------------------
-- library state (the original script's S / cfg / Input, reduced to what the UI needs)
-------------------------------------------------------------------------------
local Library: any = {
	Version = "1.0.0",
	Flags = {}, -- every control's value, keyed by flag
	Binds = {}, -- flag -> { key = "E", mode = "Toggle" | "Hold" | "Always" | "Never" }
	Options = {}, -- flag -> control api
	Unloaded = false,
	ConfigFolder = "cocaine_ui",
}
local cfg: any = Library.Flags
cfg.binds = Library.Binds
cfg.uiMode = "Advanced"
cfg.theme = "Obsidian"
cfg.colAccent = { 157, 144, 255 }
cfg.colAccent2 = { 106, 92, 230 }
cfg.uiGlow = 45
cfg.railGlass = 14
cfg.menuScale = 1
cfg.menuKey = "RightShift"
cfg.toasts = true
cfg.hud = true

local S: any = { alive = true, menuOpen = false, ui = { tabs = {}, subTabs = {}, controls = {}, toggles = {} }, edition = "normal" }

local saveQueued = false
local function saveConfig()
	if Library.AutoSave and not saveQueued then
		saveQueued = true
		task.delay(0.5, function()
			saveQueued = false
			pcall(function()
				Library:SaveConfig(Library.AutoSave)
			end)
		end)
	end
	if Library.OnChanged then
		pcall(Library.OnChanged)
	end
end

local function rgb(t: any, fallback: Color3?): Color3
	if type(t) == "table" and type(t[1]) == "number" then
		return Color3.fromRGB(t[1], t[2] or 255, t[3] or 255)
	end
	return fallback or Color3.new(1, 1, 1)
end

-------------------------------------------------------------------------------
-- Input: key names, rebinding capture, bind engine
-------------------------------------------------------------------------------
local Input: any = { bindLabels = {}, bindTouched = {}, keyDown = {}, _capture = nil }
local KEY_SHORT = {
	LeftControl = "LCtrl", RightControl = "RCtrl", LeftShift = "LShift", RightShift = "RShift", LeftAlt = "LAlt", RightAlt = "RAlt",
	Return = "Enter", Backspace = "Bksp", Escape = "Esc", Space = "Space", Tab = "Tab", Delete = "Del", Insert = "Ins",
	PageUp = "PgUp", PageDown = "PgDn", Home = "Home", End = "End", CapsLock = "Caps", Backquote = "`",
	Zero = "0", One = "1", Two = "2", Three = "3", Four = "4", Five = "5", Six = "6", Seven = "7", Eight = "8", Nine = "9",
	MouseButton1 = "M1", MouseButton2 = "M2", MouseButton3 = "M3", MouseButton4 = "M4", MouseButton5 = "M5",
}
function Input.keyLabel(name: any): string
	if type(name) ~= "string" or name == "" or name == "None" then
		return "none"
	end
	return KEY_SHORT[name] or name
end
function Input.capturing(): boolean
	return Input._capture ~= nil
end
-- cb(name): a key / mouse button name, "" or nil = cleared (Escape / Backspace), false = cancelled
function Input.captureKey(cb: (any) -> ())
	if Input._capture then
		pcall(Input._capture, false)
	end
	Input._capture = cb
end

local function inputName(i: InputObject): string?
	if i.UserInputType == Enum.UserInputType.Keyboard then
		return i.KeyCode.Name
	elseif i.UserInputType == Enum.UserInputType.MouseButton1 then
		return "MouseButton1"
	elseif i.UserInputType == Enum.UserInputType.MouseButton2 then
		return "MouseButton2"
	elseif i.UserInputType == Enum.UserInputType.MouseButton3 then
		return "MouseButton3"
	end
	return nil
end

-------------------------------------------------------------------------------
-- §11 ui kit — tokens, themes, primitives
-------------------------------------------------------------------------------
local UI: any = {}
local C: any = {
	bg = Color3.fromRGB(15, 14, 19), -- window / content
	side = Color3.fromRGB(11, 10, 15), -- sidebar, HUD panels
	surface = Color3.fromRGB(22, 21, 27), -- inputs, buttons, dropdowns
	card = Color3.fromRGB(28, 27, 34), -- hover / pressed surface
	pop = Color3.fromRGB(20, 19, 26), -- popovers: dropdowns, the bind popup, tooltips
	hairline = Color3.fromRGB(30, 29, 36), -- separators
	edge = Color3.fromRGB(38, 37, 45), -- control borders
	text = Color3.fromRGB(236, 234, 242),
	dim = Color3.fromRGB(161, 157, 173),
	muted = Color3.fromRGB(106, 102, 116),
	faint = Color3.fromRGB(74, 71, 82),
	off = Color3.fromRGB(38, 36, 46), -- switch / slider track
	knobOff = Color3.fromRGB(119, 114, 127),
	accent = Color3.fromRGB(173, 102, 255),
	accent2 = Color3.fromRGB(103, 52, 244),
	danger = Color3.fromRGB(255, 92, 122),
	ok = Color3.fromRGB(69, 223, 160),
	warn = Color3.fromRGB(255, 181, 71),
	rage = Color3.fromRGB(255, 92, 122),
	light = false,
}
UI.C = C

UI.F = {
	body = Font.fromEnum(Enum.Font.BuilderSansExtraBold),
	medium = Font.fromEnum(Enum.Font.BuilderSansExtraBold),
	semibold = Font.fromEnum(Enum.Font.BuilderSansExtraBold),
	bold = Font.fromEnum(Enum.Font.BuilderSansExtraBold),
	black = Font.fromEnum(Enum.Font.BuilderSansExtraBold),
	code = Font.fromEnum(Enum.Font.RobotoMono),
	icon = nil, -- Material Icons ligature font once registered
}
UI.BRAND_FONT = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
UI.TEXT_MIN = 12
UI.TEXT_KEYS = { title = true, desc = true, group = true, value = true, small = true, tiny = true }
UI.M = {
	title = 14, desc = 13, group = 14, value = 13, small = 12, tiny = 12,
	row = 26, rowToggle = 26, rowDanger = 26, rowSlider = 26, rowCycle = 26, rowColor = 26, rowKeybind = 26,
	rowButton = 32, rowNote = 20, descLine = 0, listRow = 26,
	pillW = 28, pillH = 16, knob = 12, btnH = 26,
	ctrlW = 118, trackW = 100, valueW = 40, colW = 300,
}
function UI.textH(text: string, size: number, _font: any, width: number): number
	local ts = game:GetService("TextService")
	local ok, sz = pcall(ts.GetTextSize, ts, tostring(text or ""), size, Enum.Font.BuilderSansExtraBold, Vector2.new(math.max(width, 40), 4000))
	if ok and sz then
		return math.ceil(sz.Y)
	end
	return size + 4
end

-- fonts / icon font ----------------------------------------------------------------------------
UI.ASSET_DIR = "cocaine/fonts"
UI.BARLOW = "https://raw.githubusercontent.com/google/fonts/main/ofl/barlow/"
UI.FONT_FACES = {
	{ file = "Barlow-Regular.ttf", weight = 400, name = "Regular" },
	{ file = "Barlow-Medium.ttf", weight = 500, name = "Medium" },
	{ file = "Barlow-SemiBold.ttf", weight = 600, name = "SemiBold" },
	{ file = "Barlow-Bold.ttf", weight = 700, name = "Bold" },
	{ file = "Barlow-ExtraBold.ttf", weight = 800, name = "ExtraBold", optional = true },
}
UI.ICON_FONT = { file = "MaterialIconsOutlined.otf", url = "https://raw.githubusercontent.com/google/material-design-icons/master/font/MaterialIconsOutlined-Regular.otf" }
UI.assetState = "builtin" -- builtin | loading | loaded | failed
function UI.assetPath(file: string): string
	return UI.ASSET_DIR .. "/" .. file
end
function UI.haveAsset(file: string): boolean
	local ok, yes = pcall(function()
		return EXEC.isfile(UI.assetPath(file)) and #EXEC.readfile(UI.assetPath(file)) > 10000
	end)
	return ok and yes == true
end
local function mkdirs()
	pcall(function()
		for _, dir in ipairs({ "cocaine", UI.ASSET_DIR }) do
			if not (EXEC.isfolder and EXEC.isfolder(dir)) and EXEC.makefolder then
				EXEC.makefolder(dir)
			end
		end
	end)
end
function UI.fetchAsset(file: string, url: string): boolean
	if UI.haveAsset(file) then
		return true
	end
	if type(EXEC.request) ~= "function" then
		return false
	end
	local ok, res = pcall(EXEC.request, { Url = url, Method = "GET" })
	if not (ok and type(res) == "table" and res.StatusCode == 200 and type(res.Body) == "string" and #res.Body > 10000) then
		log("WARN", "font download failed:", file)
		return false
	end
	mkdirs()
	return (pcall(EXEC.writefile, UI.assetPath(file), res.Body))
end
-- registers the cached files as Roblox font families; true when Barlow is in UI.F
function UI.applyFonts(): boolean
	if type(EXEC.getcustomasset) ~= "function" then
		return false
	end
	local ok, err = pcall(function()
		local faces = {}
		local extra = false
		for _, f in ipairs(UI.FONT_FACES) do
			if UI.haveAsset(f.file) then
				table.insert(faces, { name = f.name, weight = f.weight, style = "normal", assetId = EXEC.getcustomasset(UI.assetPath(f.file)) })
				extra = extra or f.weight == 800
			elseif not f.optional then
				error("missing " .. f.file)
			end
		end
		EXEC.writefile(UI.assetPath("CocaineBarlow.json"), HttpService:JSONEncode({ name = "CocaineBarlow", faces = faces }))
		local fam = EXEC.getcustomasset(UI.assetPath("CocaineBarlow.json"))
		local heavy = if extra then Enum.FontWeight.ExtraBold else Enum.FontWeight.Bold
		UI.F.body = Font.new(fam, Enum.FontWeight.Bold)
		UI.F.medium = Font.new(fam, Enum.FontWeight.Bold)
		UI.F.semibold = Font.new(fam, heavy)
		UI.F.bold = Font.new(fam, heavy)
		UI.F.black = Font.new(fam, heavy)
		UI.fontFamily = fam
		if UI.haveAsset(UI.ICON_FONT.file) then
			EXEC.writefile(UI.assetPath("CocaineIcons.json"), HttpService:JSONEncode({ name = "CocaineIcons", faces = { { name = "Regular", weight = 400, style = "normal", assetId = EXEC.getcustomasset(UI.assetPath(UI.ICON_FONT.file)) } } }))
			UI.F.icon = Font.new(EXEC.getcustomasset(UI.assetPath("CocaineIcons.json")))
		end
	end)
	if not ok then
		log("DEBUG", "fonts: built-in (" .. tostring(err):sub(1, 60) .. ")")
		return false
	end
	UI.assetState = "loaded"
	return true
end
-- cached files load now (the menu is built with them); missing ones download in the background
-- and the menu rebuilds once they are in
function UI.loadAssets()
	if UI.applyFonts() then
		local missing = {}
		for _, f in ipairs(UI.FONT_FACES) do
			if f.optional and not UI.haveAsset(f.file) then
				table.insert(missing, f)
			end
		end
		if #missing > 0 and type(EXEC.request) == "function" then
			task.spawn(function()
				local got = false
				for _, f in ipairs(missing) do
					got = UI.fetchAsset(f.file, UI.BARLOW .. f.file) or got
				end
				if got and S.alive and UI.applyFonts() then
					task.defer(function()
						if S.alive and Library.Rebuild then
							pcall(Library.Rebuild)
						end
					end)
				end
			end)
		end
		return
	end
	if type(EXEC.request) ~= "function" or type(EXEC.getcustomasset) ~= "function" or not EXEC.caps.files then
		UI.assetState = "failed"
		return
	end
	UI.assetState = "loading"
	task.spawn(function()
		local all = true
		for _, f in ipairs(UI.FONT_FACES) do
			all = (UI.fetchAsset(f.file, UI.BARLOW .. f.file) or f.optional == true) and all
		end
		UI.fetchAsset(UI.ICON_FONT.file, UI.ICON_FONT.url)
		if not (all and S.alive and UI.applyFonts()) then
			UI.assetState = "failed"
			return
		end
		task.defer(function()
			if not S.alive then
				return
			end
			if Library.Rebuild then
				pcall(Library.Rebuild)
			end
			if Library.Hud and Library.Hud.retheme then
				pcall(Library.Hud.retheme)
			end
		end)
	end)
end

-- one accent colour per theme: bright + deep (for the gradients)
local THEMES = {
	["Neon purple"] = { Color3.fromRGB(178, 120, 255), Color3.fromRGB(120, 66, 246) },
	Ice = { Color3.fromRGB(116, 206, 255), Color3.fromRGB(58, 128, 255) },
	Rose = { Color3.fromRGB(255, 122, 182), Color3.fromRGB(238, 60, 122) },
	Mint = { Color3.fromRGB(96, 240, 190), Color3.fromRGB(22, 196, 150) },
	Gold = { Color3.fromRGB(255, 200, 112), Color3.fromRGB(250, 152, 54) },
	Mono = { Color3.fromRGB(246, 246, 250), Color3.fromRGB(150, 150, 162) },
}
-- Obsidian (default) and toxic are brushed-metal looks. The accent pair is the glow / highlight colour; the
-- metal tones in UI.THEME_METAL paint the active tab, sub-tab, switches, sliders and buttons.
THEMES.Obsidian = { Color3.fromRGB(157, 144, 255), Color3.fromRGB(106, 92, 230) }
THEMES.Toxic = { Color3.fromRGB(182, 240, 58), Color3.fromRGB(111, 158, 26) }
local THEME_ORDER = { "Obsidian", "Toxic", "Neon purple", "Ice", "Rose", "Mint", "Gold", "Mono", "Custom" }
do
	local function surf(t: { { number } }): any
		local keys = { "bg", "side", "surface", "card", "pop", "hairline", "edge", "text", "dim", "muted", "faint", "off", "knobOff" }
		local out = {}
		for i, k in ipairs(keys) do
			out[k] = Color3.fromRGB(t[i][1], t[i][2], t[i][3])
		end
		return out
	end
	UI.THEME_SURFACES = {
		Obsidian = surf({ { 13, 13, 17 }, { 10, 10, 14 }, { 20, 20, 25 }, { 28, 28, 34 }, { 20, 20, 24 }, { 31, 31, 36 }, { 41, 41, 48 }, { 242, 243, 246 }, { 180, 184, 191 }, { 124, 127, 136 }, { 85, 85, 95 }, { 32, 33, 38 }, { 141, 145, 153 } }),
		Toxic = surf({ { 14, 17, 12 }, { 11, 14, 9 }, { 21, 24, 19 }, { 29, 33, 25 }, { 20, 23, 17 }, { 32, 36, 29 }, { 43, 48, 38 }, { 243, 246, 236 }, { 184, 191, 172 }, { 126, 134, 114 }, { 86, 93, 76 }, { 30, 35, 26 }, { 140, 148, 128 } }),
		["Neon purple"] = surf({ { 14, 12, 20 }, { 10, 8, 16 }, { 22, 18, 32 }, { 30, 24, 44 }, { 18, 14, 28 }, { 32, 26, 48 }, { 44, 36, 64 }, { 248, 244, 255 }, { 196, 184, 220 }, { 140, 128, 164 }, { 96, 88, 118 }, { 48, 40, 68 }, { 160, 148, 188 } }),
		Ice = surf({ { 12, 16, 24 }, { 8, 12, 20 }, { 18, 24, 36 }, { 26, 32, 48 }, { 16, 20, 32 }, { 28, 36, 52 }, { 40, 50, 70 }, { 240, 248, 255 }, { 180, 200, 228 }, { 120, 140, 172 }, { 82, 98, 128 }, { 36, 46, 64 }, { 148, 168, 204 } }),
		Rose = surf({ { 22, 12, 18 }, { 18, 8, 14 }, { 34, 18, 28 }, { 44, 24, 38 }, { 28, 14, 22 }, { 46, 26, 40 }, { 62, 36, 54 }, { 255, 242, 248 }, { 220, 176, 198 }, { 168, 122, 148 }, { 118, 82, 104 }, { 58, 32, 48 }, { 188, 142, 168 } }),
		Mint = surf({ { 10, 18, 16 }, { 7, 14, 12 }, { 16, 28, 24 }, { 22, 38, 32 }, { 14, 24, 20 }, { 24, 42, 36 }, { 34, 58, 48 }, { 238, 255, 248 }, { 176, 214, 198 }, { 118, 158, 138 }, { 78, 108, 92 }, { 32, 52, 44 }, { 142, 182, 162 } }),
		Gold = surf({ { 18, 14, 8 }, { 14, 10, 6 }, { 28, 22, 14 }, { 38, 30, 18 }, { 24, 18, 12 }, { 42, 34, 22 }, { 58, 46, 30 }, { 255, 248, 236 }, { 220, 196, 160 }, { 168, 142, 108 }, { 118, 96, 72 }, { 52, 40, 28 }, { 188, 162, 124 } }),
		Mono = surf({ { 16, 16, 18 }, { 12, 12, 14 }, { 26, 26, 30 }, { 34, 34, 40 }, { 22, 22, 26 }, { 36, 36, 42 }, { 50, 50, 58 }, { 248, 248, 252 }, { 188, 188, 198 }, { 132, 132, 144 }, { 88, 88, 98 }, { 42, 42, 48 }, { 156, 156, 168 } }),
	}
end
-- hi → lite → mid → dark: the lit face down to the shadow of the metal; ink = text on the metal, edge = the
-- darker lip under a raised metal key
UI.THEME_METAL = {
	Obsidian = {
		hi = Color3.fromRGB(243, 240, 253), lite = Color3.fromRGB(183, 176, 212), mid = Color3.fromRGB(74, 67, 104),
		dark = Color3.fromRGB(20, 18, 29), ink = Color3.fromRGB(20, 18, 29), edge = Color3.fromRGB(111, 104, 144),
	},
	Toxic = {
		hi = Color3.fromRGB(244, 255, 214), lite = Color3.fromRGB(205, 240, 106), mid = Color3.fromRGB(111, 158, 26),
		dark = Color3.fromRGB(33, 51, 10), ink = Color3.fromRGB(22, 33, 10), edge = Color3.fromRGB(95, 140, 18),
	},
}
UI.THEME_ORDER = THEME_ORDER
UI.THEMES = THEMES
function UI.themeName(): string
	return cfg.theme
end
function UI.applyTheme()
	local name = UI.themeName()
	local pair = THEMES[name]
	UI.metal = UI.THEME_METAL[name]
	-- surfaces: the base palette, or the theme's own; kept once so switching back restores it
	UI.C_BASE = UI.C_BASE or table.clone(C)
	local surf = UI.THEME_SURFACES[name]
	for k, v in pairs(UI.C_BASE) do
		if k ~= "accent" and k ~= "accent2" and k ~= "light" then
			C[k] = if surf and surf[k] then surf[k] else v
		end
	end
	if name == "Custom" or not pair then
		pair = { rgb(cfg.colAccent), rgb(cfg.colAccent2) }
	end
	C.accent, C.accent2 = pair[1], pair[2]
	C.light = false
	S.themeApplied = name
end
function UI.themeFx(): any
	return nil
end
UI.applyTheme()

-- glow: a soft radial sprite (64 × 64 white, smoothstep falloff) written once as a PNG and loaded
-- through getcustomasset, tinted with the accent. The 9-slice shadow sprite is the fallback.
UI.GLOW_IMAGE = "rbxassetid://6014261993"
-- an N × N RGBA PNG from pixel(x, y) → r, g, b, a: one stored (uncompressed) deflate block, so
-- N * (4N + 1) must stay under 65535 bytes (N ≤ 127)
function UI.pngEncode(N: number, pixel: (number, number) -> (number, number, number, number)): string
	local bxor, band, rshift = bit32.bxor, bit32.band, bit32.rshift
	local crcTable = table.create(256)
	for i = 0, 255 do
		local c = i
		for _ = 1, 8 do
			c = if band(c, 1) == 1 then bxor(0xEDB88320, rshift(c, 1)) else rshift(c, 1)
		end
		crcTable[i + 1] = c
	end
	local function crc32(s: string): number
		local c = 0xFFFFFFFF
		for i = 1, #s do
			c = bxor(crcTable[band(bxor(c, string.byte(s, i)), 0xFF) + 1], rshift(c, 8))
		end
		return bxor(c, 0xFFFFFFFF)
	end
	local function u32(n: number): string
		return string.char(band(rshift(n, 24), 255), band(rshift(n, 16), 255), band(rshift(n, 8), 255), band(n, 255))
	end
	local rows = table.create(N)
	for y = 0, N - 1 do
		local px = table.create(N * 4 + 1)
		px[1] = 0 -- filter: none
		for x = 0, N - 1 do
			local i = x * 4 + 2
			px[i], px[i + 1], px[i + 2], px[i + 3] = pixel(x, y)
		end
		rows[y + 1] = string.char(table.unpack(px))
	end
	local raw = table.concat(rows)
	local a1, a2 = 1, 0
	for i = 1, #raw do
		a1 = (a1 + string.byte(raw, i)) % 65521
		a2 = (a2 + a1) % 65521
	end
	local len = #raw
	local nlen = bxor(len, 0xFFFF)
	local zlib = "\120\1" .. string.char(1, band(len, 255), rshift(len, 8), band(nlen, 255), rshift(nlen, 8)) .. raw .. u32(a2 * 65536 + a1)
	local function chunk(kind: string, data: string): string
		return u32(#data) .. kind .. data .. u32(crc32(kind .. data))
	end
	return "\137PNG\r\n\26\n" .. chunk("IHDR", u32(N) .. u32(N) .. "\8\6\0\0\0") .. chunk("IDAT", zlib) .. chunk("IEND", "")
end
-- a generated texture in the fonts folder, written once, loaded through getcustomasset
function UI.pngAsset(file: string, N: number, pixel: (number, number) -> (number, number, number, number)): string?
	if type(EXEC.getcustomasset) ~= "function" or not EXEC.caps.files then
		return nil
	end
	local path = UI.assetPath(file)
	local ok, id = pcall(function()
		if not (EXEC.isfile and EXEC.isfile(path)) then
			local png = UI.pngEncode(N, pixel)
			mkdirs()
			EXEC.writefile(path, png)
		end
		return EXEC.getcustomasset(path)
	end)
	return if ok and type(id) == "string" then id else nil
end
function UI.buildGlowPng(): string?
	local mid = 63 / 2
	return UI.pngAsset("glow64.png", 64, function(x: number, y: number)
		local d = math.sqrt((x - mid) ^ 2 + (y - mid) ^ 2) / 32
		local a = math.clamp(1 - d, 0, 1)
		a = a * a * (3 - 2 * a)
		return 255, 255, 255, math.floor(a * 255 + 0.5)
	end)
end
-- acrylic grain: a 96 px tile of zero-mean speckle (a seeded PRNG so the file never changes)
function UI.buildNoisePng(): string?
	local rng = Random.new(0xC0CA)
	return UI.pngAsset("acrylic96.png", 96, function()
		local c = if rng:NextNumber() < 0.5 then 0 else 255
		local a = math.floor((0.35 + 0.65 * rng:NextNumber()) * 255 + 0.5)
		return c, c, c, a
	end)
end
-- the logo mark: a round face with X eyes and a flat mouth, drawn with signed distances in white so a
-- UIGradient paints it in the accent at any size; one texture per exact pixel size
UI.faceIcons = {}
function UI.buildFacePng(N: number): string?
	N = math.clamp(math.floor(N + 0.5), 8, 127)
	if UI.faceIcons[N] ~= nil then
		return UI.faceIcons[N] or nil
	end
	local function seg(px: number, py: number, ax: number, ay: number, bx: number, by: number): number
		local dx, dy = bx - ax, by - ay
		local t = math.clamp(((px - ax) * dx + (py - ay) * dy) / (dx * dx + dy * dy), 0, 1)
		local qx, qy = ax + dx * t - px, ay + dy * t - py
		return math.sqrt(qx * qx + qy * qy)
	end
	local ringW = math.max(0.045, 0.78 / N)
	local lineW = math.max(0.036, 0.72 / N)
	local id = UI.pngAsset(("face%d.png"):format(N), N, function(x: number, y: number)
		local u, v = (x + 0.5) / N, (y + 0.5) / N
		local d = math.abs(math.sqrt((u - 0.5) ^ 2 + (v - 0.5) ^ 2) - 0.41) - ringW -- head outline
		for _, e in ipairs({ { 0.35, 0.42 }, { 0.65, 0.42 } }) do
			local s = 0.075
			d = math.min(d, seg(u, v, e[1] - s, e[2] - s, e[1] + s, e[2] + s) - lineW)
			d = math.min(d, seg(u, v, e[1] - s, e[2] + s, e[1] + s, e[2] - s) - lineW)
		end
		d = math.min(d, seg(u, v, 0.37, 0.67, 0.63, 0.67) - lineW) -- mouth
		local a = math.clamp(0.5 - d * N, 0, 1)
		return 255, 255, 255, math.floor(a * 255 + 0.5)
	end)
	UI.faceIcons[N] = id or false
	return id
end
-- a hollow soft falloff around a rounded box with the window's 12 px corners, `spread` px wide, for
-- 9-slicing at scale 1. Empty inside the box, so a shadow / aura never paints over the window.
UI.falloffTiles = {}
function UI.falloffTile(spread: number, radius: number?): (string?, Rect?)
	local rad = radius or 12
	local key = spread * 100 + rad
	local cached = UI.falloffTiles[key]
	if cached then
		return cached.id, cached.slice
	end
	local m = spread + rad
	local n = m * 2 + 4
	local c = n / 2
	local file = if rad == 12 then ("falloff%d.png"):format(spread) else ("falloff%d_%d.png"):format(spread, rad)
	local id = UI.pngAsset(file, n, function(x: number, y: number)
		local qx, qy = math.abs(x + 0.5 - c) - 2, math.abs(y + 0.5 - c) - 2
		local ox, oy = math.max(qx, 0), math.max(qy, 0)
		local d = math.sqrt(ox * ox + oy * oy) + math.min(math.max(qx, qy), 0) - rad
		if d <= 0 then
			return 255, 255, 255, 0
		end
		local t = math.clamp(1 - d / spread, 0, 1)
		return 255, 255, 255, math.floor(t * t * math.min(d, 1) * 255 + 0.5)
	end)
	local slice = Rect.new(m, m, n - m, n - m)
	UI.falloffTiles[key] = { id = id, slice = slice }
	return id, slice
end
function UI.buildAssets()
	UI.glowRadial = UI.buildGlowPng()
	UI.noiseTile = UI.buildNoisePng()
	UI.faceIcon = UI.buildFacePng(96)
end
UI.buildAssets()

function UI.glowAlpha(strength: number?): number
	local g = math.clamp((tonumber(cfg.uiGlow) or 45) / 100, 0, 1) * (strength or 1)
	return 1 - 0.8 * g
end
-- a soft light filling `parent` plus `spread` px on every side. It renders above the parent's own
-- background, so the element it lights must be a later sibling (or carry a higher ZIndex).
function UI.glow(parent: GuiObject, spread: number?, strength: number?, color: Color3?): ImageLabel
	local s = spread or 10
	local g = Instance.new("ImageLabel")
	g.Name = "Glow"
	g.BackgroundTransparency = 1
	g.ImageColor3 = color or C.accent
	if UI.glowRadial then
		g.Image = UI.glowRadial
		g.ScaleType = Enum.ScaleType.Stretch
	else
		g.Image = UI.GLOW_IMAGE
		g.ScaleType = Enum.ScaleType.Slice
		g.SliceCenter = Rect.new(49, 49, 450, 450)
		g.SliceScale = math.clamp(s / 40, 0.05, 1)
	end
	g.AnchorPoint = Vector2.new(0.5, 0.5)
	g.Position = UDim2.fromScale(0.5, 0.5)
	g.Size = UDim2.new(1, s * 2, 1, s * 2)
	g.ImageTransparency = UI.glowAlpha(strength)
	g:SetAttribute("glowStrength", strength or 1)
	g.Parent = parent
	return g
end
-- the glow slider: every glow that is lit right now follows the new strength
function UI.refreshGlows(root: Instance?)
	if not root then
		return
	end
	for _, d in ipairs(root:GetDescendants()) do
		if d.Name == "Glow" and d:IsA("ImageLabel") and d:GetAttribute("glowOff") ~= true then
			d.ImageTransparency = UI.glowAlpha(tonumber(d:GetAttribute("glowStrength")) or 1)
		end
	end
end

-- motion: 0.20–0.42 s, continuous. Quart / Cubic, not Quint (a Quint ease-out covers ~55 % of the
-- distance in its first frame). lead / trail drive the two edges of a moving indicator (UI.liquid).
local TW_OPEN = TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TW_TAB = TweenInfo.new(0.34, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TW_TOGGLE = TweenInfo.new(0.26, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TW_KNOB = TweenInfo.new(0.22, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
local TW_HOVER = TweenInfo.new(0.20, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
local TW_TOAST_IN = TweenInfo.new(0.30, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TW_TOAST_OUT = TweenInfo.new(0.26, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
UI.TW = {
	open = TW_OPEN, close = TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.In), tab = TW_TAB, toggle = TW_TOGGLE, knob = TW_KNOB, hover = TW_HOVER,
	toastIn = TW_TOAST_IN, toastOut = TW_TOAST_OUT, pop = TweenInfo.new(0.26, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	lead = TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), trail = TweenInfo.new(0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	reveal = TweenInfo.new(0.30, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
}
local function tween(obj: Instance, info: TweenInfo, props: any)
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end
UI.tween = tween

-- a whole subtree fades in to the transparencies it was built with (or out and back): the crisp way
-- to show a popup / row. UI.fadeLive[obj] keeps the transparencies the object really has while a fade runs.
UI.fadeLive = setmetatable({}, { __mode = "k" })
function UI.fadeTargets(root: Instance): { { any } }
	local out = {}
	local list = root:GetDescendants()
	table.insert(list, root)
	for _, d in ipairs(list) do
		local props: any = nil
		local live = UI.fadeLive[d]
		if live then
			props = table.clone(live.props)
		elseif d:IsA("UIStroke") then
			if d.Transparency < 1 then
				props = { Transparency = d.Transparency }
			end
		elseif d:IsA("GuiObject") and d.Visible then
			props = {}
			if d.BackgroundTransparency < 1 then
				props.BackgroundTransparency = d.BackgroundTransparency
			end
			if (d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox")) and (d :: any).TextTransparency < 1 then
				props.TextTransparency = (d :: any).TextTransparency
			end
			if (d:IsA("ImageLabel") or d:IsA("ImageButton")) and (d :: any).ImageTransparency < 1 then
				props.ImageTransparency = (d :: any).ImageTransparency
			end
			if next(props) == nil then
				props = nil
			end
		end
		if props then
			table.insert(out, { d, props })
		end
	end
	return out
end
local function fadeSet(d: Instance, props: any)
	for k, v in pairs(props) do
		pcall(function()
			(d :: any)[k] = v
		end)
	end
end
-- stops a running fade on the whole subtree and puts the real transparencies back at once
function UI.fadeReset(root: Instance)
	local list = root:GetDescendants()
	table.insert(list, root)
	for _, d in ipairs(list) do
		local live = UI.fadeLive[d]
		if live then
			UI.fadeLive[d] = nil
			pcall(live.tween.Cancel, live.tween)
			fadeSet(d, live.props)
		end
	end
end
function UI.fadeIn(root: Instance, info: TweenInfo?)
	local ti = info or UI.TW.pop
	for _, e in ipairs(UI.fadeTargets(root)) do
		local d, props = e[1], e[2]
		local live = UI.fadeLive[d]
		if live then
			pcall(live.tween.Cancel, live.tween) -- continue from where it is, toward the real values
		else
			for k in pairs(props) do
				(d :: any)[k] = 1
			end
		end
		local rec: any = { props = props }
		rec.tween = tween(d, ti, props)
		UI.fadeLive[d] = rec
		rec.tween.Completed:Connect(function(state: any)
			if state == Enum.PlaybackState.Completed and UI.fadeLive[d] == rec then
				UI.fadeLive[d] = nil
			end
		end)
	end
end
-- fades out one subtree or a list of them, runs `done`, then puts every transparency back (the
-- caller hides / destroys in `done`). Driven by a timer, not a tween's Completed.
function UI.fadeOut(root: any, info: TweenInfo?, done: (() -> ())?)
	local ti = info or UI.TW.close
	local targets = {}
	for _, r in ipairs(if typeof(root) == "Instance" then { root } else root) do
		for _, e in ipairs(UI.fadeTargets(r)) do
			table.insert(targets, e)
		end
	end
	local recs = {}
	for i, e in ipairs(targets) do
		local d, props = e[1], e[2]
		local live = UI.fadeLive[d]
		if live then
			pcall(live.tween.Cancel, live.tween)
		end
		local fade = {}
		for k in pairs(props) do
			fade[k] = 1
		end
		local rec: any = { props = props }
		rec.tween = tween(d, ti, fade)
		UI.fadeLive[d] = rec
		recs[i] = rec
	end
	task.delay(ti.Time + ti.DelayTime, function()
		for _, rec in ipairs(recs) do
			pcall(rec.tween.Cancel, rec.tween)
		end
		if done then
			local ok, err = pcall(done)
			if not ok then
				log("WARN", "fade: " .. tostring(err))
			end
		end
		for i, e in ipairs(targets) do
			local d = e[1]
			-- only what is still ours: a fade that started since owns the object now
			if UI.fadeLive[d] == recs[i] then
				UI.fadeLive[d] = nil
				fadeSet(d, e[2])
			end
		end
	end)
end
-- a moving indicator's two edges (a, b along one axis) on NumberValues parented to `holder` (they
-- die with it). `to` glides them — the leading edge on TW.lead, the trailing one on TW.trail — or
-- snaps them. `apply(a, b)` paints the indicator.
function UI.liquid(holder: Instance, apply: (number, number) -> ()): any
	local L: any = { tw = {}, placed = false }
	L.a = Instance.new("NumberValue")
	L.b = Instance.new("NumberValue")
	L.a.Parent, L.b.Parent = holder, holder
	local function paint()
		apply(L.a.Value, L.b.Value)
	end
	L.a.Changed:Connect(paint)
	L.b.Changed:Connect(paint)
	function L.to(a: number, b: number, animate: boolean?)
		for _, t in ipairs(L.tw) do
			t:Cancel()
		end
		table.clear(L.tw)
		if not animate or not L.placed then
			L.placed = true
			L.a.Value, L.b.Value = a, b
			paint()
			return
		end
		local forward = a > L.a.Value
		table.insert(L.tw, tween(L.a, if forward then UI.TW.trail else UI.TW.lead, { Value = a }))
		table.insert(L.tw, tween(L.b, if forward then UI.TW.lead else UI.TW.trail, { Value = b }))
	end
	return L
end

local order = 0
local function nextOrder(): number
	order += 1
	return order
end
UI.nextOrder = nextOrder
local function corner(p: GuiObject, r: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = p
end
local function stroke(p: GuiObject, color: Color3, tr: number): UIStroke
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = 1
	s.Transparency = tr
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.LineJoinMode = Enum.LineJoinMode.Round
	s.Parent = p
	return s
end
local function gradient(p: GuiObject, c1: Color3, c2: Color3, rotation: number?): UIGradient
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(c1, c2)
	g.Rotation = rotation or 0
	g.Parent = p
	return g
end
local function vlist(p: GuiObject, pad: number, horizontal: boolean?): UIListLayout
	local l = Instance.new("UIListLayout")
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Padding = UDim.new(0, pad)
	if horizontal then
		l.FillDirection = Enum.FillDirection.Horizontal
	end
	l.Parent = p
	return l
end
local function padding(p: GuiObject, t: number, r: number, b: number, l: number)
	local u = Instance.new("UIPadding")
	u.PaddingTop = UDim.new(0, t)
	u.PaddingRight = UDim.new(0, r)
	u.PaddingBottom = UDim.new(0, b)
	u.PaddingLeft = UDim.new(0, l)
	u.Parent = p
end
-- UI.F holds Font objects (FontFace); an Enum.Font still works for old call sites
function UI.setFont(t: any, font: any)
	if typeof(font) == "Font" then
		t.FontFace = font
	elseif typeof(font) == "EnumItem" then
		t.Font = font
	else
		t.FontFace = UI.F.body
	end
end
local function label(p: GuiObject, text: string, size: number, color: Color3, font: any?): TextLabel
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	UI.setFont(t, font or UI.F.body)
	t.TextSize = size
	t.TextColor3 = color
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.Text = text
	t.Parent = p
	return t
end
local function frame(p: GuiObject?, bg: Color3?): Frame
	local f = Instance.new("Frame")
	f.BorderSizePixel = 0
	if bg then
		f.BackgroundColor3 = bg
	else
		f.BackgroundTransparency = 1
	end
	if p then
		f.Parent = p
	end
	return f
end
local function button(p: GuiObject, text: string, size: number, color: Color3, bg: Color3?): TextButton
	local b = Instance.new("TextButton")
	b.BackgroundColor3 = bg or C.surface
	b.BorderSizePixel = 0
	UI.setFont(b, UI.F.medium)
	b.TextSize = size
	b.TextColor3 = color
	b.Text = text
	b.AutoButtonColor = false
	b.Parent = p
	return b
end
UI.corner, UI.stroke, UI.gradient, UI.vlist, UI.padding, UI.label, UI.frame, UI.button = corner, stroke, gradient, vlist, padding, label, frame, button

-- brushed metal (metal looks only): a top-lit metal gradient with a thin light along the top edge. Text and
-- icons on it take UI.metal.ink. Returns false on the accent looks, which keep their quiet selection.
function UI.brushed(f: GuiObject): boolean
	local m = UI.metal
	if not m then
		return false
	end
	f.BackgroundColor3 = Color3.new(1, 1, 1)
	local g = f:FindFirstChild("Brushed") :: UIGradient?
	if not g then
		local ng = Instance.new("UIGradient")
		ng.Name = "Brushed"
		ng.Rotation = 90
		ng.Parent = f
		g = ng
	end
	(g :: UIGradient).Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, m.hi),
		ColorSequenceKeypoint.new(0.58, m.lite),
		ColorSequenceKeypoint.new(1, m.lite:Lerp(m.mid, 0.4)),
	})
	if not f:FindFirstChild("BrushedLight") then
		local sheen = Instance.new("Frame")
		sheen.Name = "BrushedLight"
		sheen.BorderSizePixel = 0
		sheen.BackgroundColor3 = Color3.new(1, 1, 1)
		sheen.BackgroundTransparency = 0.05
		sheen.AnchorPoint = Vector2.new(0.5, 0)
		sheen.Position = UDim2.new(0.5, 0, 0, 1)
		sheen.Size = UDim2.new(1, -8, 0, 1)
		sheen.ZIndex = f.ZIndex
		sheen.Parent = f
		local sg = Instance.new("UIGradient")
		sg.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.18, 0.15), NumberSequenceKeypoint.new(0.82, 0.15), NumberSequenceKeypoint.new(1, 1) })
		sg.Parent = sheen
	end
	local lip = f:FindFirstChildOfClass("UIStroke")
	if lip then
		lip.Color = m.dark
		lip.Transparency = 0.5
	end
	return true
end
-- a key that is brushed while on and a plain surface while off (HUD keycaps, chips)
function UI.keyState(f: GuiObject, on: boolean, offColor: Color3, offAlpha: number?): boolean
	if not UI.brushed(f) then
		return false
	end
	local g = f:FindFirstChild("Brushed")
	if g then
		(g :: UIGradient).Enabled = on
	end
	local light = f:FindFirstChild("BrushedLight")
	if light then
		(light :: Frame).Visible = on
	end
	f.BackgroundColor3 = if on then Color3.new(1, 1, 1) else offColor
	f.BackgroundTransparency = if on then 0 else (offAlpha or 0)
	return true
end
-- a switch / slider fill: the same lit metal instead of the accent pair
function UI.metalFill(g: UIGradient)
	local m = UI.metal
	if not m then
		return
	end
	g.Rotation = 90
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, m.hi),
		ColorSequenceKeypoint.new(0.45, m.lite),
		ColorSequenceKeypoint.new(1, m.lite:Lerp(m.mid, 0.6)),
	})
end
-- the turning metal edge on a window-sized stroke: every stop is a tinted metal; the caller turns it
-- with Menu.loop so it only moves while the menu is open
function UI.metalEdge(s: UIStroke): UIGradient?
	local m = UI.metal
	if not m then
		return nil
	end
	local a, b, c = m.lite:Lerp(C.accent, 0.35), m.mid:Lerp(m.lite, 0.45), m.lite:Lerp(Color3.new(1, 1, 1), 0.16)
	s.Color = Color3.new(1, 1, 1)
	s.Transparency = 0
	local g = s:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, b),
		ColorSequenceKeypoint.new(0.25, a),
		ColorSequenceKeypoint.new(0.5, c),
		ColorSequenceKeypoint.new(0.75, a),
		ColorSequenceKeypoint.new(1, b),
	})
	g.Parent = s
	return g
end
-- a popover's edge (bind popup, dropdowns, tooltips): the metal edge and an even accent glow on the metal
-- looks, the accent hairline elsewhere
function UI.popEdge(p: GuiObject, radius: number?)
	local s = stroke(p, C.accent, 0.6)
	local g = UI.metalEdge(s)
	if g then
		g.Rotation = 35
		UI.softShadow(p, "Aura", C.accent, UI.glowAlpha(0.45), 14, radius)
	end
	return s
end
-- acrylic, opaque: the panel's own colour (opts.tint), lit from above (a luminosity gradient,
-- opts.light), a grain layer (opts.grain = its transparency, false = none) and optionally a glass edge
function UI.acrylic(f: GuiObject, opts: any?): any
	opts = opts or {}
	local out: any = {}
	if opts.tint then
		f.BackgroundColor3 = opts.tint
	end
	local lum = if type(opts.light) == "number" then opts.light else 0.1
	if lum > 0 then
		local g = Instance.new("UIGradient")
		g.Name = "AcrylicLight"
		g.Rotation = opts.lightRotation or 90
		g.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1 - lum, 1 - lum, 1 - lum))
		g.Parent = f
		out.light = g
	end
	if UI.noiseTile and opts.grain ~= false then
		local n = Instance.new("ImageLabel")
		n.Name = "AcrylicGrain"
		n.BackgroundTransparency = 1
		n.Image = UI.noiseTile
		n.ScaleType = Enum.ScaleType.Tile
		n.TileSize = UDim2.fromOffset(96, 96)
		n.ImageTransparency = if type(opts.grain) == "number" then opts.grain else 0.955
		n.Size = opts.grainSize or UDim2.fromScale(1, 1)
		n.ZIndex = opts.z or 1
		n.Active = false
		n.Parent = f
		if opts.radius then
			corner(n, opts.radius)
		end
		out.grain = n
	end
	if type(opts.edge) == "number" then
		local s = stroke(f, opts.edgeColor or Color3.new(1, 1, 1), 0)
		s.Name = "AcrylicEdge"
		local eg = Instance.new("UIGradient")
		eg.Rotation = 90
		eg.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, opts.edge),
			NumberSequenceKeypoint.new(0.5, math.min(1, opts.edge + 0.12)),
			NumberSequenceKeypoint.new(1, math.min(1, opts.edge + 0.22)),
		})
		eg.Parent = s
		out.edge = s
	end
	return out
end
-- a soft falloff `spread` px around `parent`'s 12 px rounded box and nothing inside it; black = shadow, the accent = an aura
function UI.softShadow(parent: GuiObject, name: string, color: Color3, transparency: number, spread: number, radius: number?): ImageLabel?
	local id, slice = UI.falloffTile(spread, radius)
	if not (id and slice) then
		return nil
	end
	local sh = Instance.new("ImageLabel")
	sh.Name = name
	sh.BackgroundTransparency = 1
	sh.Image = id
	sh.ImageColor3 = color
	sh.ImageTransparency = transparency
	sh.ScaleType = Enum.ScaleType.Slice
	sh.SliceCenter = slice
	sh.SliceScale = 1
	sh.AnchorPoint = Vector2.new(0.5, 0.5)
	sh.Position = UDim2.fromScale(0.5, 0.5)
	sh.Size = UDim2.new(1, spread * 2, 1, spread * 2)
	sh.ZIndex = 0
	sh.Active = false
	sh.Parent = parent
	return sh
end

-- fallback icons (no icon font): geometric glyphs drawn from frames on a 100×100 scale canvas
local function iconFallback(parent: GuiObject, name: string): Frame
	local canvas = frame(parent)
	canvas.Name = "Icon"
	canvas.Size = UDim2.new(0, 20, 0, 20)
	canvas.AnchorPoint = Vector2.new(0.5, 0.5)
	canvas.Position = UDim2.fromScale(0.5, 0.5)
	local col = Color3.new(1, 1, 1)
	local function box(x: number, y: number, w: number, h: number, opts: any?): Frame
		opts = opts or {}
		local f = frame(canvas, col)
		f.AnchorPoint = Vector2.new(0.5, 0.5)
		f.Position = UDim2.fromScale(x, y)
		f.Size = UDim2.fromScale(w, h)
		f.Rotation = opts.rot or 0
		f.BackgroundTransparency = opts.tr or 0
		if opts.round then
			corner(f, opts.round)
		end
		f:SetAttribute("iconPart", true)
		return f
	end
	local function ring(x: number, y: number, d: number, thick: number, filled: boolean?): Frame
		local f = frame(canvas, col)
		f.AnchorPoint = Vector2.new(0.5, 0.5)
		f.Position = UDim2.fromScale(x, y)
		f.Size = UDim2.fromScale(d, d)
		f.BackgroundTransparency = if filled then 0 else 1
		corner(f, 999)
		f:SetAttribute("iconPart", true)
		if not filled then
			local s = stroke(f, col, 0)
			s.Thickness = thick or 2
			s:SetAttribute("iconStroke", true)
		end
		return f
	end
	local function outline(x: number, y: number, w: number, h: number, thick: number, roundR: number, rot: number?): Frame
		local f = frame(canvas, col)
		f.AnchorPoint = Vector2.new(0.5, 0.5)
		f.Position = UDim2.fromScale(x, y)
		f.Size = UDim2.fromScale(w, h)
		f.Rotation = rot or 0
		f.BackgroundTransparency = 1
		corner(f, roundR)
		f:SetAttribute("iconPart", true)
		local s = stroke(f, col, 0)
		s.Thickness = thick
		s:SetAttribute("iconStroke", true)
		return f
	end
	if name == "Aimbot" or name == "gps_fixed" then
		ring(0.5, 0.5, 0.8, 2)
		box(0.5, 0.5, 0.12, 0.12, { round = 999 })
		box(0.5, 0.1, 0.08, 0.26, { round = 999 })
		box(0.5, 0.9, 0.08, 0.26, { round = 999 })
		box(0.1, 0.5, 0.26, 0.08, { round = 999 })
		box(0.9, 0.5, 0.26, 0.08, { round = 999 })
	elseif name == "Rage" or name == "bolt" then
		box(0.58, 0.24, 0.2, 0.46, { rot = 28, round = 2 })
		box(0.5, 0.5, 0.42, 0.16, { rot = -20, round = 2 })
		box(0.42, 0.76, 0.2, 0.46, { rot = 28, round = 2 })
	elseif name == "Visuals" or name == "visibility" then
		outline(0.5, 0.5, 0.96, 0.58, 2, 999)
		ring(0.5, 0.5, 0.42, 2)
		box(0.5, 0.5, 0.16, 0.16, { round = 999 })
	elseif name == "World" or name == "public" then
		ring(0.5, 0.5, 0.92, 2)
		box(0.5, 0.5, 0.86, 0.07, { round = 999 })
		outline(0.5, 0.5, 0.42, 0.9, 2, 999)
	elseif name == "Interface" or name == "dashboard" then
		for _, p in ipairs({ { 0.3, 0.3 }, { 0.7, 0.3 }, { 0.3, 0.7 }, { 0.7, 0.7 } }) do
			box(p[1], p[2], 0.32, 0.32, { round = 3 })
		end
	elseif name == "Debug" or name == "terminal" then
		outline(0.5, 0.5, 0.92, 0.76, 2, 4)
		box(0.33, 0.43, 0.24, 0.07, { rot = 40, round = 999 })
		box(0.33, 0.57, 0.24, 0.07, { rot = -40, round = 999 })
		box(0.66, 0.64, 0.26, 0.07, { round = 999 })
	elseif name == "menu" then
		for _, y in ipairs({ 0.24, 0.5, 0.76 }) do
			box(0.5, y, 0.78, 0.12, { round = 999 })
		end
	elseif name == "Settings" or name == "settings" then
		for i = 0, 7 do
			local a = math.rad(i * 45)
			box(0.5 + math.cos(a) * 0.4, 0.5 + math.sin(a) * 0.4, 0.26, 0.26, { round = 2, rot = i * 45 })
		end
		ring(0.5, 0.5, 0.66, 3, true)
		local hole = ring(0.5, 0.5, 0.26, 2, true)
		hole.BackgroundColor3 = C.surface
		hole:SetAttribute("iconPart", nil)
	elseif name == "close" then
		box(0.5, 0.5, 0.8, 0.1, { rot = 45, round = 999 })
		box(0.5, 0.5, 0.8, 0.1, { rot = -45, round = 999 })
	elseif name == "check" then
		box(0.36, 0.62, 0.4, 0.1, { rot = 45, round = 999 })
		box(0.62, 0.52, 0.7, 0.1, { rot = -50, round = 999 })
	elseif name == "search" then
		ring(0.43, 0.43, 0.6, 2)
		box(0.78, 0.78, 0.3, 0.1, { rot = 45, round = 999 })
	elseif name == "expand" or name == "expand_more" then
		box(0.35, 0.45, 0.42, 0.1, { rot = 40, round = 999 })
		box(0.65, 0.45, 0.42, 0.1, { rot = -40, round = 999 })
	elseif name == "left" or name == "chevron_left" then
		box(0.42, 0.35, 0.42, 0.1, { rot = -50, round = 999 })
		box(0.42, 0.65, 0.42, 0.1, { rot = 50, round = 999 })
	elseif name == "right" or name == "chevron_right" then
		box(0.58, 0.35, 0.42, 0.1, { rot = 50, round = 999 })
		box(0.58, 0.65, 0.42, 0.1, { rot = -50, round = 999 })
	elseif name == "help" or name == "info" or name == "warn" then
		ring(0.5, 0.5, 0.9, 2)
		box(0.5, 0.36, 0.1, 0.1, { round = 999 })
		box(0.5, 0.64, 0.1, 0.28, { round = 999 })
	elseif name == "save" then
		outline(0.5, 0.5, 0.8, 0.8, 2, 3)
		box(0.5, 0.3, 0.46, 0.18, { round = 1 })
	elseif name == "keyboard" then
		outline(0.5, 0.5, 0.96, 0.6, 2, 3)
		for _, p in ipairs({ { 0.25, 0.42 }, { 0.5, 0.42 }, { 0.75, 0.42 }, { 0.5, 0.62 } }) do
			box(p[1], p[2], p[1] == 0.5 and p[2] == 0.62 and 0.5 or 0.12, 0.1, { round = 1 })
		end
	else
		box(0.5, 0.5, 0.5, 0.5, { round = 4 })
	end
	return canvas
end
local function recolourIcon(canvas: GuiObject, color: Color3)
	if canvas:IsA("TextLabel") then
		canvas.TextColor3 = color
		return
	end
	for _, ch in ipairs(canvas:GetDescendants()) do
		if ch:IsA("UIStroke") then
			ch.Color = color
		elseif ch:GetAttribute("iconPart") then
			(ch :: Frame).BackgroundColor3 = color
		end
	end
end
-- Material Icons ligature names (every one verified to render as a single glyph)
UI.ICONS = {
	Aimbot = "gps_fixed", Trigger = "my_location", Silent = "track_changes", Rage = "bolt", Misc = "widgets", Visuals = "visibility",
	World = "public", Skins = "checkroom", Interface = "dashboard", Settings = "settings", Config = "tune", Debug = "terminal",
	search = "search", save = "save", close = "close", expand = "expand_more", help = "help_outline", warn = "warning_amber",
	check = "check", keyboard = "keyboard", power = "power_settings_new", arrange = "open_with", info = "info", gem = "diamond",
	left = "chevron_left", right = "chevron_right", kill = "my_location", person = "person_outline", refresh = "refresh",
	menu = "menu",
}
-- a square icon centred in `parent` (size px); the font glyph when loaded, the frame glyph otherwise
local function icon(parent: GuiObject, name: string, size: number?): GuiObject
	local px = size or 16
	if UI.F.icon then
		local t = label(parent, UI.ICONS[name] or name, px, C.muted, UI.F.icon)
		t.Name = "Icon"
		t.Size = UDim2.fromOffset(px + 2, px + 2)
		t.AnchorPoint = Vector2.new(0.5, 0.5)
		t.Position = UDim2.fromScale(0.5, 0.5)
		t.TextXAlignment = Enum.TextXAlignment.Center
		t.TextYAlignment = Enum.TextYAlignment.Center
		return t
	end
	local canvas = iconFallback(parent, name)
	canvas.Size = UDim2.fromOffset(px, px)
	return canvas
end
UI.icon, UI.recolourIcon = icon, recolourIcon
-- a font glyph fades to its new colour; the frame-drawn fallback glyphs switch at once
function UI.tintIcon(canvas: GuiObject, color: Color3, animate: boolean?)
	if animate and canvas:IsA("TextLabel") then
		tween(canvas, TW_HOVER, { TextColor3 = color })
	else
		recolourIcon(canvas, color)
	end
end

-- the logo mark in the accent gradient, `size` px square and centred in `parent`
function UI.logoMark(parent: GuiObject, size: number, rotation: number?): GuiObject
	local m: GuiObject
	size = math.floor(size + 0.5)
	local face = if UI.faceIcon then UI.buildFacePng(size) or UI.faceIcon else nil
	if face then
		local img = Instance.new("ImageLabel")
		img.Name = "LogoMark"
		img.BackgroundTransparency = 1
		img.Image = face
		img.ImageColor3 = Color3.new(1, 1, 1)
		img.ScaleType = Enum.ScaleType.Fit
		img.Size = UDim2.fromOffset(size, size)
		img.AnchorPoint = Vector2.new(0.5, 0.5)
		img.Position = UDim2.fromScale(0.5, 0.5)
		img.Parent = parent
		m = img
	elseif UI.F.icon then
		m = label(parent, "diamond", size, Color3.new(1, 1, 1), UI.F.icon)
		m.Size = UDim2.fromOffset(size, size)
		m.AnchorPoint = Vector2.new(0.5, 0.5)
		m.Position = UDim2.fromScale(0.5, 0.5);
		(m :: TextLabel).TextXAlignment = Enum.TextXAlignment.Center
	else
		m = frame(parent, Color3.new(1, 1, 1))
		m.Size = UDim2.fromOffset(math.floor(size * 0.65), math.floor(size * 0.65))
		m.AnchorPoint = Vector2.new(0.5, 0.5)
		m.Position = UDim2.fromScale(0.5, 0.5)
		m.Rotation = 45
		corner(m, 2)
	end
	local g = gradient(m, C.accent, C.accent2, rotation or 45)
	if UI.metal then
		-- metal looks: the mark is lit metal like the wordmark (light top, a darker band, a bright line)
		g.Rotation = 90
		g.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, UI.metal.hi),
			ColorSequenceKeypoint.new(0.35, UI.metal.lite),
			ColorSequenceKeypoint.new(0.55, UI.metal.lite:Lerp(UI.metal.mid, 0.55)),
			ColorSequenceKeypoint.new(0.68, UI.metal.hi),
			ColorSequenceKeypoint.new(1, UI.metal.lite),
		})
	end
	return m
end
-- the HUD's type: Gotham in two weights, measured with TextService against the exact face that is drawn
UI.HUD_FONT = Font.fromEnum(Enum.Font.GothamMedium)
UI.HUD_BOLD = Font.fromEnum(Enum.Font.GothamBold)
function UI.gw(text: string, size: number, bold: boolean?): number
	local ts = game:GetService("TextService")
	local ok, sz = pcall(ts.GetTextSize, ts, tostring(text or ""), size, if bold then Enum.Font.GothamBold else Enum.Font.GothamMedium, Vector2.new(4000, 400))
	return if ok and sz then math.ceil(sz.X) else math.ceil(#tostring(text or "") * size * 0.62)
end

-------------------------------------------------------------------------------
-- registries: rows (search + Simple/Advanced), groups, toggle sync, bind tags
-------------------------------------------------------------------------------
UI.rows = {} -- { frame, text, desc, advanced, group }
UI.groups = {} -- { frame, advanced, title, rows }
UI.sync = {} -- functions walked by one Heartbeat while the menu is open
UI.lazySync = {}
function UI.syncLazy(fn: () -> ())
	table.insert(UI.sync, fn)
	UI.lazySync[fn] = true
end
UI.bindTags = {} -- flag -> refresh()
UI.searchText = ""
UI.gui = nil
UI.root = nil
UI.conns = {} -- connections owned by the current menu build (dropped on rebuild)
local tipFrame: TextLabel? = nil
function UI.conn(c: RBXScriptConnection): RBXScriptConnection
	table.insert(UI.conns, c)
	return c
end
function UI.resetRegistries()
	for _, c in ipairs(UI.conns) do
		pcall(c.Disconnect, c)
	end
	table.clear(UI.conns)
	UI.dragInstalled = false -- its two connections were just dropped with the rest
	UI.drag = nil
	table.clear(UI.rows)
	table.clear(UI.groups)
	table.clear(UI.sync)
	table.clear(UI.lazySync)
	table.clear(UI.bindTags)
	S.ui.tabs = {}
	S.ui.subTabs = {}
	S.ui.controls = {}
	S.ui.toggles = {}
	tipFrame = nil
end
-- one drag manager for every slider / colour rail: the active drag's handlers run from a single
-- pair of UserInputService connections (installed once per build) instead of two per control
UI.drag = nil
UI.dragInstalled = false
function UI.beginDrag(onMove: (Vector2) -> (), onEnd: (() -> ())?)
	local prev = UI.drag
	if prev and prev.onEnd then
		pcall(prev.onEnd)
	end
	UI.drag = { onMove = onMove, onEnd = onEnd }
	if not UI.dragInstalled then
		UI.dragInstalled = true
		UI.conn(UIS.InputChanged:Connect(function(i)
			local d = UI.drag
			if d and i.UserInputType == Enum.UserInputType.MouseMovement then
				d.onMove(Vector2.new(i.Position.X, i.Position.Y))
			end
		end))
		UI.conn(UIS.InputEnded:Connect(function(i)
			local d = UI.drag
			if d and i.UserInputType == Enum.UserInputType.MouseButton1 then
				UI.drag = nil
				if d.onEnd then
					d.onEnd()
				end
			end
		end))
	end
end
function UI.count(kind: string)
	S.ui.controls[kind] = (S.ui.controls[kind] or 0) + 1
end
local function modeAllows(advanced: boolean?): boolean
	return cfg.uiMode == "Advanced" or not advanced
end
-- Simple mode hides every row flagged `Advanced = true` (and groups flagged the same). Switching
-- modes never touches a value: a hidden Advanced row keeps working exactly as set.
function UI.isAdvanced(ropts: any, text: string?, groupOpts: any): boolean
	if ropts.advanced ~= nil then
		return ropts.advanced == true
	end
	if groupOpts and groupOpts.simple == true then
		return false
	end
	return false
end

-- switches that do nothing while another one is off: their row says so instead of looking broken.
-- need = { flag = "aimEnabled", text = "aimbot" } or a list of those
function UI.needUnmet(need: any): any
	if need == nil then
		return nil
	end
	local list = if need.flag or need.fn then { need } else need
	for _, n in ipairs(list) do
		local met = if n.fn then n.fn() == true else cfg[n.flag] == true
		if not met then
			return n
		end
	end
	return nil
end
function UI.needText(need: any): string
	return "needs " .. string.lower(tostring(need.text or need.flag or "?"))
end

local function rowMatches(r: any): boolean
	local q = UI.searchText
	if q == "" then
		return true
	end
	return string.find(string.lower(r.text), q, 1, true) ~= nil or (r.descText ~= nil and string.find(string.lower(r.descText), q, 1, true) ~= nil)
end
-- the rows under a three-line button fade in / out instead of popping; `done` runs once every row has finished
function UI.animSub(state: any, open: boolean, done: (() -> ())?)
	local rows = {}
	for _, r in ipairs(UI.rows) do
		if r.parent == state and r.frame.Visible then
			table.insert(rows, r)
		end
	end
	if #rows == 0 then
		if done then
			done()
		end
		return
	end
	state.animating = true
	if open then
		for _, r in ipairs(rows) do
			UI.fadeIn(r.frame)
		end
		task.delay(UI.TW.pop.Time, function()
			state.animating = false
			if done then
				done()
			end
		end)
		return
	end
	local frames = {}
	for _, r in ipairs(rows) do
		table.insert(frames, r.frame)
	end
	UI.fadeOut(frames, UI.TW.hover, function()
		state.animating = false
		if done then
			done()
		end
	end)
end
function UI.parentOpen(r: any): boolean
	local p = r.parent
	if p == nil then
		return true
	end
	if UI.searchText ~= "" then
		return true
	end
	return p.open == true and (p.when == nil or p.when() == true)
end
function UI.refilter()
	for _, r in ipairs(UI.rows) do
		local show = modeAllows(r.advanced) and rowMatches(r) and UI.parentOpen(r)
		r.frame.Visible = show
		if r.desc then
			local showDesc = r.descText ~= nil and r.descText ~= ""
			r.desc.Visible = showDesc
			r.frame.Size = UDim2.new(1, 0, 0, r.base + (if showDesc then (r.descH or UI.M.descLine) else 0))
		end
	end
	for _, g in ipairs(UI.groups) do
		local any, anyControl, hasControls = false, false, false
		for _, r in ipairs(g.rows) do
			if not r.isNote then
				hasControls = true
			end
			if r.frame.Visible then
				any = true
				if not r.isNote then
					anyControl = true
				end
			end
		end
		-- in Simple mode a note whose controls are all advanced would sit alone in its group
		if cfg.uiMode ~= "Advanced" and hasControls and any and not anyControl then
			for _, r in ipairs(g.rows) do
				if r.isNote and r.frame.Visible then
					r.frame.Visible = false
				end
			end
			any = false
		end
		g.frame.Visible = modeAllows(g.advanced) and (any or (#g.rows == 0 and UI.searchText == ""))
	end
	if UI.afterRefilter then
		pcall(UI.afterRefilter)
	end
end
function UI.search(text: string)
	UI.searchText = string.lower(tostring(text or ""))
	UI.refilter()
end
function UI.setMode(mode: string)
	cfg.uiMode = if mode == "Simple" then "Simple" else "Advanced"
	saveConfig()
	UI.refilter()
end

-- a typed slider value: "0.3", "x0.3", "×0.30", "15k", "20%", "1.5 s", "400st", "never" / "off" → 0
function UI.parseNumber(s: string): number?
	if type(s) ~= "string" then
		return nil
	end
	s = string.gsub(string.lower((string.gsub(s, "×", ""))), "%s+", "")
	-- "15,000" is a thousands separator, "1,5" a decimal comma
	s = if string.match(s, "^%-?%d+,%d%d%d") then string.gsub(s, ",", "") else string.gsub(s, ",", ".")
	if s == "never" or s == "off" or s == "none" then
		return 0
	end
	local num, suffix = string.match(s, "^x?([%-]?%d*%.?%d+)(%a*)")
	local n = tonumber(num)
	if n == nil or n ~= n then
		return nil
	end
	if suffix == "k" then
		n *= 1000
	end
	return n
end

-- one line of text at `size`, measured with the widest face the kit draws (chips size to it)
function UI.textW(text: string, size: number): number
	local ts = game:GetService("TextService")
	local ok, sz = pcall(ts.GetTextSize, ts, tostring(text or ""), size, Enum.Font.BuilderSansExtraBold, Vector2.new(2000, 200))
	return if ok and sz then math.ceil(sz.X) else #tostring(text or "") * (size * 0.6)
end
-- a text box sized to its text in whole, even pixels (a fractional box puts its edges and stroke on half
-- pixels, blurred across two). `extra` = the label's own padding. false while the text cannot be measured yet.
function UI.snapWidth(l: TextLabel, extra: number?): boolean
	local w = l.TextBounds.X
	if w < 1 then
		return false
	end
	local total = math.ceil(w - 0.001) + (extra or 0)
	if total % 2 == 1 then
		total += 1
	end
	if l.AutomaticSize == Enum.AutomaticSize.X then
		l.AutomaticSize = Enum.AutomaticSize.None
	elseif l.AutomaticSize == Enum.AutomaticSize.XY then
		l.AutomaticSize = Enum.AutomaticSize.Y
	end
	if l.Size.X.Scale ~= 0 or l.Size.X.Offset ~= total then
		l.Size = UDim2.new(0, total, l.Size.Y.Scale, l.Size.Y.Offset)
	end
	return true
end
-- wrapped text in whole pixels: measured at `maxW`, then sized to the longest line and the lines' height
function UI.snapWrapped(l: TextLabel, maxW: number, padX: number?, padY: number?): boolean
	local auto = l.AutomaticSize
	l.AutomaticSize = Enum.AutomaticSize.None
	l.TextWrapped = true
	l.Size = UDim2.fromOffset(maxW + (padX or 0), 2000)
	local tb = l.TextBounds
	if tb.X < 1 then
		l.AutomaticSize = auto
		return false
	end
	local w = math.ceil(tb.X - 0.001) + (padX or 0)
	if w % 2 == 1 then
		w += 1
	end
	l.Size = UDim2.fromOffset(w, math.ceil(tb.Y - 0.001) + (padY or 0))
	return true
end

-- tooltip (one per gui)
function UI.tip(target: GuiObject, text: string)
	target.MouseEnter:Connect(function()
		if not UI.gui or not text or text == "" then
			return
		end
		if not tipFrame or tipFrame.Parent == nil then
			-- wraps at 260 px and never runs off the screen (flips to the left / above the cursor)
			local t = Instance.new("TextLabel")
			t.Name = "Tooltip"
			t.AutomaticSize = Enum.AutomaticSize.XY
			t.Size = UDim2.new(0, 0, 0, 0)
			t.BackgroundColor3 = C.pop
			UI.setFont(t, UI.F.body)
			t.TextSize = UI.M.desc
			t.TextColor3 = C.text
			t.TextWrapped = true
			t.TextXAlignment = Enum.TextXAlignment.Left
			t.LineHeight = 1.1
			t.ZIndex = 200
			t.Visible = false
			t.Parent = UI.gui
			corner(t, if UI.metal then 8 else 6)
			UI.metalEdge(stroke(t, C.edge, 0))
			padding(t, 7, 10, 8, 10)
			local cap = Instance.new("UISizeConstraint")
			cap.MaxSize = Vector2.new(260, 400)
			cap.Parent = t
			tipFrame = t
		end
		local tf = tipFrame :: TextLabel
		tf.Text = text
		UI.snapWrapped(tf, 240, 20, 15)
		-- placed first, shown one frame later: it used to appear at the previous tooltip's position for a frame and then jump
		local m0 = UIS:GetMouseLocation()
		local inset0 = if UI.gui.IgnoreGuiInset then 0 else GuiService:GetGuiInset().Y
		tf.Position = UDim2.fromOffset(m0.X + 14, m0.Y - inset0 + 8)
		tf.Visible = false
		task.defer(function()
			if tipFrame ~= tf then
				return
			end
			local m = UIS:GetMouseLocation()
			local inset = if UI.gui.IgnoreGuiInset then 0 else GuiService:GetGuiInset().Y
			local vp = UI.gui.AbsoluteSize
			local sz = tf.AbsoluteSize
			local x, y = m.X + 14, m.Y - inset + 8
			if x + sz.X > vp.X - 6 then
				x = math.max(6, m.X - 14 - sz.X)
			end
			if y + sz.Y > vp.Y - 6 then
				y = math.max(6, m.Y - inset - 8 - sz.Y)
			end
			tf.Position = UDim2.fromOffset(x, y)
			tf.Visible = true
		end)
	end)
	target.MouseLeave:Connect(function()
		if tipFrame then
			tipFrame.Visible = false
		end
	end)
end

---------------------------------------------------------------------------
-- bind popup: right-click any toggle → key + mode (Toggle / Hold / Always / Never)
---------------------------------------------------------------------------
local BIND_MODES = { "Toggle", "Hold", "Always", "Never" }
local bindPopup: Frame? = nil
function UI.closeBindPopup()
	local p = bindPopup
	bindPopup = nil
	if not p then
		return
	end
	if p.Parent and S.menuOpen then
		-- fades out, inert meanwhile (a click on a fading button must not act)
		for _, d in ipairs(p:GetDescendants()) do
			if d:IsA("GuiButton") then
				d.Active = false
				pcall(function()
					(d :: any).Interactable = false
				end)
			end
		end
		UI.fadeOut(p, UI.TW.hover, function()
			p:Destroy()
		end)
	else
		p:Destroy()
	end
end
function UI.openBindPopup(cfgKey: string, title: string?, at: Vector2?)
	local root = UI.root
	if not root then
		return
	end
	UI.closeBindPopup()
	-- the bind entry is created only once the user actually sets a key or mode
	local b = cfg.binds[cfgKey]
	if type(b) ~= "table" then
		b = { key = "", mode = "Toggle" }
	end
	local function commit()
		if cfg.binds[cfgKey] ~= b then
			cfg.binds[cfgKey] = b
		end
		saveConfig()
	end
	-- the popover look every popup shares (C.pop, 10 px corners, a soft shadow with the same corners),
	-- an accent edge because it edits one row; faded in, never unrolled
	local W, H = 300, 206
	local pop = frame(root, C.pop)
	pop.Name = "BindPopup"
	pop.Size = UDim2.fromOffset(W, H)
	local rel = if at then at - root.AbsolutePosition else Vector2.new(root.AbsoluteSize.X / 2 - W / 2, root.AbsoluteSize.Y / 2 - H / 2)
	pop.Position = UDim2.fromOffset(math.floor(math.clamp(rel.X, 8, math.max(8, root.AbsoluteSize.X - W - 8))), math.floor(math.clamp(rel.Y, 8, math.max(8, root.AbsoluteSize.Y - H - 8))))
	pop.ZIndex = 50
	pop.Active = true
	corner(pop, 10)
	UI.softShadow(pop, "Shadow", Color3.new(0, 0, 0), 0.4, 18, 10)
	UI.popEdge(pop, 10)
	bindPopup = pop
	local function zl(t: any, z: number?): any
		t.ZIndex = z or 51
		return t
	end
	local cap = zl(label(pop, "keybind", UI.M.tiny, C.accent, UI.F.semibold))
	cap.Size = UDim2.new(1, -60, 0, 14)
	cap.Position = UDim2.fromOffset(16, 12)
	local head = zl(label(pop, string.lower(title or Input.bindLabels[cfgKey] or cfgKey), UI.M.title, C.text, UI.F.semibold))
	head.Size = UDim2.new(1, -60, 0, 18)
	head.Position = UDim2.fromOffset(16, 27)
	head.TextTruncate = Enum.TextTruncate.AtEnd
	local closeB = zl(button(pop, "", 10, C.text, C.card))
	closeB.Size = UDim2.fromOffset(28, 28)
	closeB.AnchorPoint = Vector2.new(1, 0)
	closeB.Position = UDim2.new(1, -10, 0, 10)
	closeB.BackgroundTransparency = 1
	corner(closeB, 7)
	local closeIc = zl(icon(closeB, "close", 16), 52)
	recolourIcon(closeIc, C.muted)
	closeB.MouseEnter:Connect(function()
		tween(closeB, TW_HOVER, { BackgroundTransparency = 0 })
		UI.tintIcon(closeIc, C.text, true)
	end)
	closeB.MouseLeave:Connect(function()
		tween(closeB, TW_HOVER, { BackgroundTransparency = 1 })
		UI.tintIcon(closeIc, C.muted, true)
	end)
	local hair = zl(frame(pop, C.hairline))
	hair.Size = UDim2.new(1, -32, 0, 1)
	hair.Position = UDim2.fromOffset(16, 56)
	for _, spec in ipairs({ { "key", 68 }, { "mode", 108 } }) do
		local l = zl(label(pop, spec[1], UI.M.title, C.dim))
		l.Size = UDim2.fromOffset(64, 30)
		l.Position = UDim2.fromOffset(16, spec[2])
	end
	-- the key: a field with a keyboard glyph; it lights up while it listens
	local keyB = zl(button(pop, "", UI.M.value, C.text, C.surface))
	keyB.Size = UDim2.fromOffset(W - 104, 30)
	keyB.Position = UDim2.fromOffset(88, 68)
	corner(keyB, 7)
	local keyStroke = stroke(keyB, C.edge, 0)
	local keyIc = zl(icon(keyB, "keyboard", 15), 52)
	keyIc.AnchorPoint = Vector2.new(0, 0.5)
	keyIc.Position = UDim2.new(0, 10, 0.5, 0)
	recolourIcon(keyIc, C.muted)
	local keyTxt = zl(label(keyB, "", UI.M.value, C.text, UI.F.medium), 52)
	keyTxt.Size = UDim2.new(1, -42, 1, 0)
	keyTxt.Position = UDim2.fromOffset(32, 0)
	keyTxt.TextTruncate = Enum.TextTruncate.AtEnd
	keyB.MouseEnter:Connect(function()
		tween(keyB, TW_HOVER, { BackgroundColor3 = C.card })
	end)
	keyB.MouseLeave:Connect(function()
		tween(keyB, TW_HOVER, { BackgroundColor3 = C.surface })
	end)
	-- the mode: a segmented control whose thumb glides to the pick
	local seg = zl(frame(pop, C.surface))
	seg.Size = UDim2.fromOffset(W - 104, 30)
	seg.Position = UDim2.fromOffset(88, 108)
	corner(seg, 7)
	stroke(seg, C.edge, 0)
	local thumb = zl(frame(seg, C.accent), 52)
	thumb.BackgroundTransparency = 0.78
	corner(thumb, 5)
	stroke(thumb, C.accent, 0.5)
	if UI.brushed(thumb) then
		thumb.BackgroundTransparency = 0
	end
	local thumbLiquid = UI.liquid(thumb, function(a: number, b2: number)
		thumb.Position = UDim2.fromOffset(a, 3)
		thumb.Size = UDim2.fromOffset(math.max(4, b2 - a), 24)
	end)
	local segW = (W - 104 - 6) / #BIND_MODES
	local segBtns: { [string]: TextButton } = {}
	local refresh: (boolean?) -> ()
	for i, m in ipairs(BIND_MODES) do
		local sb = zl(button(seg, string.lower(m), UI.M.small, C.muted, C.surface), 53)
		sb.BackgroundTransparency = 1
		sb.Position = UDim2.fromOffset(3 + math.floor((i - 1) * segW + 0.5), 3)
		sb.Size = UDim2.fromOffset(math.floor(i * segW + 0.5) - math.floor((i - 1) * segW + 0.5), 24)
		segBtns[m] = sb
		sb.MouseButton1Click:Connect(function()
			if (b.mode or "Toggle") ~= m then
				b.mode = m
				Input.bindTouched[cfgKey] = nil
				commit()
				refresh(true)
			end
		end)
	end
	-- what the key is, in words, behind a status dot
	local dot = zl(frame(pop, C.muted))
	dot.Size = UDim2.fromOffset(6, 6)
	dot.AnchorPoint = Vector2.new(0, 0.5)
	dot.Position = UDim2.fromOffset(16, 157)
	corner(dot, 3)
	local status = zl(label(pop, "", UI.M.small, C.dim, UI.F.medium))
	status.Name = "Status"
	status.Size = UDim2.fromOffset(W - 44, 18)
	status.Position = UDim2.fromOffset(28, 148)
	status.TextTruncate = Enum.TextTruncate.AtEnd
	local clearB = zl(button(pop, "clear", UI.M.value, C.danger, C.danger))
	clearB.Size = UDim2.fromOffset(76, 26)
	clearB.Position = UDim2.fromOffset(16, H - 38)
	clearB.BackgroundTransparency = 0.87
	corner(clearB, 7)
	stroke(clearB, C.danger, 0.6)
	clearB.MouseEnter:Connect(function()
		tween(clearB, TW_HOVER, { BackgroundTransparency = 0.78 })
	end)
	clearB.MouseLeave:Connect(function()
		tween(clearB, TW_HOVER, { BackgroundTransparency = 0.87 })
	end)
	local hint = zl(label(pop, "esc clears · mouse works too", UI.M.small, C.muted))
	hint.Size = UDim2.fromOffset(W - 116, 26)
	hint.Position = UDim2.fromOffset(100, H - 38)
	hint.TextXAlignment = Enum.TextXAlignment.Right
	local function paintStatus()
		local k = b.key
		if type(k) ~= "string" or k == "" then
			status.Text = if b.mode == "Always" or b.mode == "Never" then ("no key · always %s"):format(if b.mode == "Always" then "on" else "off") else "no key yet"
			status.TextColor3 = C.muted
			dot.BackgroundColor3 = if b.mode == "Always" then C.ok else C.faint
			return
		end
		status.Text = ("bound to %s · %s"):format(Input.keyLabel(k), string.lower(b.mode or "Toggle"))
		status.TextColor3 = C.dim
		dot.BackgroundColor3 = if b.mode == "Never" then C.faint else C.ok
	end
	refresh = function(animate: boolean?)
		keyTxt.Text = Input.keyLabel(b.key)
		local mode = b.mode or "Toggle"
		for m, sb in pairs(segBtns) do
			local col = if m == mode then (if UI.metal then UI.metal.ink else C.text) else C.muted
			if animate then
				tween(sb, TW_HOVER, { TextColor3 = col })
			else
				sb.TextColor3 = col
			end
			UI.setFont(sb, if m == mode then UI.F.bold else UI.F.medium)
		end
		local sb = segBtns[mode]
		if sb then
			thumbLiquid.to(sb.Position.X.Offset, sb.Position.X.Offset + sb.Size.X.Offset, animate)
		end
		paintStatus()
		local tag = UI.bindTags[cfgKey]
		if tag then
			tag()
		end
	end
	refresh(false)
	keyB.MouseButton1Click:Connect(function()
		keyTxt.Text = "Press a key…"
		keyStroke.Color = C.accent
		recolourIcon(keyIc, C.accent)
		Input.captureKey(function(name)
			if name ~= false then
				b.key = name or ""
				commit()
			end
			if pop.Parent then
				keyStroke.Color = C.edge
				recolourIcon(keyIc, C.muted)
				refresh(false)
			end
		end)
	end)
	do
		local base = pop.Position
		pop.Position = base + UDim2.fromOffset(0, 4)
		tween(pop, UI.TW.pop, { Position = base })
		UI.fadeIn(pop)
	end
	clearB.MouseButton1Click:Connect(function()
		cfg.binds[cfgKey] = nil
		Input.bindTouched[cfgKey] = nil
		saveConfig()
		local tag = UI.bindTags[cfgKey]
		if tag then
			tag()
		end
		UI.closeBindPopup()
	end)
	closeB.MouseButton1Click:Connect(UI.closeBindPopup)
end
function UI.bindPopupOpen(): boolean
	return bindPopup ~= nil
end

---------------------------------------------------------------------------
-- dropdown popover (cycle / multiselect / colour): one at a time, parented to the menu host so it
-- scales with the window; an invisible catcher over window + side panel closes it on an outside click
---------------------------------------------------------------------------
UI.popup = nil
UI.popupHost = nil -- set by Menu.build (the frame holding the window and the side panel)
function UI.closeDropdown()
	local p = UI.popup
	UI.popup = nil
	if p then
		pcall(p.catcher.Destroy, p.catcher)
		pcall(p.frame.Destroy, p.frame)
		if p.onClose then
			pcall(p.onClose)
		end
	end
end
-- build(frame) fills the list and returns its height; the list opens under the anchor (above it
-- when there is no room) and never wider than needed
function UI.openDropdown(anchor: GuiObject, width: number, build: (Frame) -> number, onClose: (() -> ())?): Frame?
	UI.closeDropdown()
	local host = UI.popupHost or UI.root
	if not host then
		return nil
	end
	local sc = 1
	local catcher = Instance.new("TextButton")
	catcher.Name = "DropdownCatcher"
	catcher.BackgroundTransparency = 1
	catcher.Text = ""
	catcher.AutoButtonColor = false
	catcher.Size = UDim2.new(1, 400, 1, 0)
	catcher.ZIndex = 58
	catcher.Parent = host
	local f = frame(host, C.pop)
	f.Name = "Dropdown"
	f.ZIndex = 60
	f.Active = true
	corner(f, 8)
	UI.softShadow(f, "Shadow", Color3.new(0, 0, 0), 0.45, 14, 8)
	if not UI.metal then
		stroke(f, C.edge, 0)
	else
		UI.popEdge(f, 8)
	end
	local h = build(f)
	local ap = (anchor.AbsolutePosition - host.AbsolutePosition) / sc
	local as = anchor.AbsoluteSize / sc
	local hostH = host.AbsoluteSize.Y / sc
	local w = math.max(width, as.X)
	local y = ap.Y + as.Y + 4
	local above = false
	if y + h > hostH - 6 and ap.Y - h - 4 > 6 then
		y = ap.Y - h - 4
		above = true
	end
	-- full size at once, fading in while it drifts 4 px out of its anchor (no unroll: see UI.fadeIn)
	local base = UDim2.fromOffset(math.floor(ap.X + as.X - w + 0.5), math.floor(y + 0.5))
	f.Size = UDim2.fromOffset(w, h)
	f.Position = base + UDim2.fromOffset(0, if above then 4 else -4)
	tween(f, UI.TW.pop, { Position = base })
	UI.fadeIn(f)
	catcher.MouseButton1Click:Connect(UI.closeDropdown)
	UI.popup = { frame = f, catcher = catcher, onClose = onClose }
	return f
end
-- one 24 px option inside a dropdown
function UI.dropdownOption(parent: Frame, y: number, text: string, selected: boolean, onPick: () -> ()): TextButton
	local b = button(parent, "", UI.M.value, C.dim, C.card)
	b.BackgroundTransparency = 1
	b.Size = UDim2.new(1, -8, 0, 24)
	b.Position = UDim2.fromOffset(4, y)
	b.ZIndex = 61
	corner(b, 5)
	local l = label(b, text, UI.M.value, if selected then C.accent else C.dim, UI.F.body)
	l.Size = UDim2.new(1, -30, 1, 0)
	l.Position = UDim2.fromOffset(8, 0)
	l.ZIndex = 62
	l.TextTruncate = Enum.TextTruncate.AtEnd
	local ic = icon(b, "check", 14)
	ic.AnchorPoint = Vector2.new(1, 0.5)
	ic.Position = UDim2.new(1, -6, 0.5, 0)
	ic.ZIndex = 62
	ic.Visible = selected
	recolourIcon(ic, C.accent)
	b:SetAttribute("selected", selected)
	-- metal looks: the picked option is a brushed key with dark ink (it keeps it through hovers)
	local keyed = selected and UI.brushed(b)
	if keyed then
		b.BackgroundTransparency = 0
		l.TextColor3 = UI.metal.ink
		UI.setFont(l, UI.F.bold)
		recolourIcon(ic, UI.metal.ink)
	end
	b.MouseEnter:Connect(function()
		if keyed then
			return
		end
		tween(b, TW_HOVER, { BackgroundTransparency = 0 })
		if not b:GetAttribute("selected") then
			tween(l, TW_HOVER, { TextColor3 = C.text })
		end
	end)
	b.MouseLeave:Connect(function()
		if keyed then
			return
		end
		tween(b, TW_HOVER, { BackgroundTransparency = 1 })
		tween(l, TW_HOVER, { TextColor3 = if b:GetAttribute("selected") then C.accent else C.dim })
	end)
	b.MouseButton1Click:Connect(onPick)
	return b
end
-- one plain sentence for a risk tag (an amber warning icon next to the label)
UI.RISK_TEXT = {
	["SERVER-CHECKED"] = "The server checks this. Push it too far and it stops counting or you get pulled back.",
	EXPERIMENTAL = "Experimental: may not work everywhere or after an update.",
	TELEPORT = "Moves your character. Other players can see it.",
	["UNTESTED VS SERVER"] = "Not yet verified against the server.",
	TRUE = "Risky: other players or the server can notice it.",
	DANGER = "Risky: other players or the server can notice it.",
}
function UI.riskText(tag: any): string
	local t = string.upper(tostring(tag))
	return UI.RISK_TEXT[t] or tostring(tag)
end

---------------------------------------------------------------------------
-- group + controls. A group is a title over a hairline; rows are 26 px, label left, control
-- right; help lives in a (?) tooltip, risk in one amber warning icon.
---------------------------------------------------------------------------
-- a group header's glyph from its title; only names already verified in UI.ICONS (Material ligatures)
UI.GROUP_ICONS = {
	{ "extra", "auto_awesome" }, { "intel", "visibility" }, { "right now", "info" }, { "stat", "info" },
	{ "farm", "refresh" }, { "esp", "visibility" }, { "cham", "visibility" }, { "info", "info" }, { "color", "tune" },
	{ "style", "tune" }, { "look", "tune" }, { "silent", "track_changes" }, { "trigger", "my_location" }, { "aim", "gps_fixed" },
	{ "target", "gps_fixed" }, { "rage", "bolt" }, { "anti", "360" }, { "world", "public" }, { "map", "public" }, { "skin", "checkroom" },
	{ "hud", "dashboard" }, { "menu", "dashboard" }, { "interface", "dashboard" }, { "bind", "keyboard" }, { "key", "keyboard" },
	{ "config", "save" }, { "cloud", "save" }, { "player", "person_outline" }, { "spoof", "person_outline" }, { "staff", "warning_amber" },
}
function UI.groupIcon(title: string): string
	local t = string.lower(title)
	for _, p in ipairs(UI.GROUP_ICONS) do
		if string.find(t, p[1], 1, true) then
			return p[2]
		end
	end
	return "tune"
end
local function colOf(key: string): Color3
	return rgb(cfg[key], C.accent)
end
function UI.group(parent: GuiObject, title: string, opts: any?): any
	opts = opts or {}
	local gf = frame(parent)
	gf.Name = "Group_" .. title
	gf.AutomaticSize = Enum.AutomaticSize.Y
	gf.Size = UDim2.new(1, 0, 0, 0)
	gf.LayoutOrder = nextOrder()
	vlist(gf, 0)
	padding(gf, 0, 0, if opts.bare then 0 else 12, 0)
	local M = UI.M
	-- a group is a boxed card (a header row over a hairline, the rows inside)
	local body: Frame = gf
	if not opts.bare then
		local card = frame(gf, C.surface:Lerp(C.bg, 0.45))
		card.Name = "Card"
		card.AutomaticSize = Enum.AutomaticSize.Y
		card.Size = UDim2.new(1, 0, 0, 0)
		corner(card, 10)
		stroke(card, C.hairline, 0)
		vlist(card, 0)
		padding(card, 0, 10, 6, 10)
		body = card
		local head = frame(card)
		head.Name = "Head"
		head.Size = UDim2.new(1, 0, 0, 32)
		head.LayoutOrder = nextOrder()
		local t = label(head, string.lower(title), M.small + 1, C.dim, UI.F.semibold)
		t.Name = "Title"
		t.Size = UDim2.new(1, 0, 1, 0)
		-- a small accent glyph before the title (the icon font only: a missing ligature would print its name)
		if UI.F.icon then
			local gi = icon(head, opts.icon or UI.groupIcon(title), 14)
			gi.AnchorPoint = Vector2.new(0, 0.5)
			gi.Position = UDim2.new(0, -1, 0.5, 0)
			recolourIcon(gi, C.accent)
			t.Position = UDim2.fromOffset(20, 0)
			t.Size = UDim2.new(1, -20, 1, 0)
		end
		local hl = frame(head, C.hairline)
		hl.Size = UDim2.new(1, 20, 0, 1)
		hl.Position = UDim2.new(0, -10, 1, -1)
		local gap = frame(card)
		gap.Size = UDim2.new(1, 0, 0, 4)
		gap.LayoutOrder = nextOrder()
	end

	local g: any = { frame = gf, rows = {}, advanced = opts.advanced == true, title = title }
	table.insert(UI.groups, g)

	local function row(h: number, text: string?, ropts: any?): Frame
		ropts = ropts or {}
		local r = frame(body)
		r.Size = UDim2.new(1, 0, 0, h)
		r.LayoutOrder = nextOrder()
		local entry: any = { frame = r, text = string.lower(text or ""), advanced = UI.isAdvanced(ropts, text, opts), base = h, descText = ropts.desc, isNote = ropts.isNote == true }
		-- a sub-option of the toggle above (its three-line button opens it): indented under a hairline, hidden until opened
		if g.subParent then
			entry.parent = g.subParent
			entry.advanced = false
			local pad = Instance.new("UIPadding")
			pad.PaddingLeft = UDim.new(0, 16)
			pad.Parent = r
			local rail = frame(r, C.hairline)
			rail.Name = "SubRail"
			rail.Size = UDim2.new(0, 1, 1, -6)
			rail.Position = UDim2.new(0, -10, 0, 3)
			r.Visible = false
		end
		table.insert(UI.rows, entry)
		table.insert(g.rows, entry)
		return r
	end
	g.row = row

	-- the row's label plus, right after its text, a (?) or amber warning icon whose tooltip holds
	-- the help; `reserve` = the width the control on the right needs
	local function rowLabel(r: Frame, text: string, ropts: any, reserve: number): TextLabel
		local l = label(r, string.lower(text), M.title, C.text, UI.F.body)
		l.Name = "Label"
		l.Size = UDim2.new(1, -(reserve + 24), 1, 0)
		l.TextTruncate = Enum.TextTruncate.AtEnd
		local warnText = if ropts.danger then UI.riskText(ropts.danger) else nil
		local helpText = if type(ropts.desc) == "string" and ropts.desc ~= "" then ropts.desc else nil
		if warnText or helpText then
			local tip = if warnText and helpText then warnText .. "\n\n" .. helpText else (warnText or helpText) :: string
			local holder = frame(r)
			holder.Name = "Hint"
			holder.Size = UDim2.fromOffset(16, 16)
			holder.AnchorPoint = Vector2.new(0, 0.5)
			holder.Position = UDim2.new(0, 0, 0.5, 0)
			local ic = icon(holder, if warnText then "warn" else "help", 14)
			recolourIcon(ic, if warnText then C.warn else C.faint)
			local function place()
				holder.Position = UDim2.new(0, math.floor(l.TextBounds.X) + 6, 0.5, 0)
			end
			place()
			l:GetPropertyChangedSignal("TextBounds"):Connect(place)
			UI.tip(holder, tip)
			UI.tip(l, tip)
			holder.MouseEnter:Connect(function()
				if not warnText then
					recolourIcon(ic, C.dim)
				end
			end)
			holder.MouseLeave:Connect(function()
				if not warnText then
					recolourIcon(ic, C.faint)
				end
			end)
		end
		return l
	end
	g.rowLabel = rowLabel

	function g.toggle(_, text: string, key: string, topts: { [string]: any })
		topts = topts or {}
		topts.cfgKey = key
		UI.count("toggle")
		Input.bindLabels[key] = text
		local r = row(M.row, text, topts)
		local l = rowLabel(r, text, topts, M.pillW + 8)
		-- the switch: a transparent hit area holding glow → track → knob
		local pill = button(r, "", 10, C.text, C.off)
		pill.Name = "Switch"
		pill.BackgroundTransparency = 1
		pill.Size = UDim2.new(0, M.pillW, 0, M.pillH)
		pill.AnchorPoint = Vector2.new(1, 0.5)
		pill.Position = UDim2.new(1, 0, 0.5, 0)
		local glow = UI.glow(pill, 7, 0.9)
		glow.ZIndex = 1
		local track = frame(pill, C.off)
		track.Size = UDim2.fromScale(1, 1)
		track.ZIndex = 2
		corner(track, M.pillH // 2)
		-- the accent fill fades over the off track while the knob travels
		local fill = frame(pill, Color3.new(1, 1, 1))
		fill.Size = UDim2.fromScale(1, 1)
		fill.ZIndex = 2
		fill.BackgroundTransparency = 1
		corner(fill, M.pillH // 2)
		UI.metalFill(gradient(fill, C.accent2, C.accent))
		local knob = frame(pill, C.knobOff)
		knob.Size = UDim2.new(0, M.knob, 0, M.knob)
		knob.AnchorPoint = Vector2.new(0, 0.5)
		knob.Position = UDim2.new(0, 2, 0.5, 0)
		knob.ZIndex = 3
		corner(knob, M.knob // 2)
		-- key chip left of the switch while a bind exists
		local tag = label(r, "", M.small, C.muted, UI.F.medium)
		tag.Name = "Bind"
		tag.Size = UDim2.new(0, 30, 0, 18)
		tag.AnchorPoint = Vector2.new(1, 0.5)
		tag.Position = UDim2.new(1, -(M.pillW + 8), 0.5, 0)
		tag.BackgroundColor3 = Color3.fromRGB(26, 25, 32)
		tag.BackgroundTransparency = 0
		tag.TextXAlignment = Enum.TextXAlignment.Center
		tag.Visible = false
		corner(tag, 4)
		stroke(tag, C.edge, 0)
		-- "needs silent aim" while the switch is on but the one it depends on is off
		local need = topts.needs
		local needTag: TextLabel? = nil
		if need then
			local first = UI.needUnmet(need) or (if need.flag or need.fn then need else need[1])
			local nt = label(r, UI.needText(first), M.small, C.warn, UI.F.medium)
			nt.Name = "Needs"
			nt.Size = UDim2.new(0, 96, 0, 18)
			nt.AnchorPoint = Vector2.new(1, 0.5)
			nt.TextXAlignment = Enum.TextXAlignment.Right
			nt.Visible = false
			needTag = nt
		end
		-- three-line button: this row has sub-options (topts.sub builds them as rows right under it,
		-- shown only while it is open; topts.subWhen can hide the button)
		local subState: any = nil
		local exp: TextButton? = nil
		local expIc: GuiObject? = nil
		if type(topts.sub) == "function" then
			subState = { open = false, when = topts.subWhen }
			local eb = button(r, "", M.small, C.text, C.card)
			eb.Name = "Expand"
			eb.BackgroundTransparency = 1
			eb.Size = UDim2.fromOffset(20, 20)
			eb.AnchorPoint = Vector2.new(1, 0.5)
			corner(eb, 5)
			expIc = icon(eb, "menu", 14)
			recolourIcon(expIc :: GuiObject, C.muted)
			exp = eb
			UI.tip(eb, "More options for " .. text)
		end
		local function expShown(): boolean
			return subState ~= nil and (subState.when == nil or subState.when() == true)
		end
		-- chips right to left: switch, key chip, sub-options, needs chip; the label gives up their width
		local function layout()
			local x = M.pillW + 8
			if tag.Visible then
				x += tag.Size.X.Offset + 6
			end
			if exp then
				local shown = expShown()
				exp.Visible = shown
				exp.Position = UDim2.new(1, -x, 0.5, 0)
				if shown then
					x += 20 + 6
				end
			end
			if needTag then
				needTag.Position = UDim2.new(1, -x, 0.5, 0)
				if needTag.Visible then
					x += needTag.Size.X.Offset + 6
				end
			end
			l.Size = UDim2.new(1, -(x + 24), 1, 0)
		end
		local function refreshTag()
			local b = cfg.binds[key]
			if type(b) == "table" and ((b.key and b.key ~= "") or b.mode == "Always" or b.mode == "Never") then
				local mode = b.mode or "Toggle"
				tag.Text = if mode == "Toggle" then Input.keyLabel(b.key) elseif mode == "Hold" then Input.keyLabel(b.key) .. " hold" else string.lower(mode)
				tag.Size = UDim2.new(0, math.max(24, UI.textW(tag.Text, M.small) + 14), 0, 18)
				-- metal looks: the key chip is a small brushed key (dark ink)
				tag.TextColor3 = if UI.brushed(tag) then UI.metal.ink else C.muted
				tag.Visible = true
			else
				tag.Text = ""
				tag.Visible = false
			end
			layout()
		end
		refreshTag()
		-- the same key can have several rows: every registered tag refreshes
		do
			local prevTag = UI.bindTags[key]
			UI.bindTags[key] = if prevTag then function()
				prevTag()
				refreshTag()
			end else refreshTag
		end
		r.Active = true
		local function onRight(input: InputObject)
			if input.UserInputType == Enum.UserInputType.MouseButton2 and topts.bind ~= false then
				UI.openBindPopup(key, text, UIS:GetMouseLocation() - Vector2.new(0, GuiService:GetGuiInset().Y))
			end
		end
		r.InputBegan:Connect(onRight)
		pill.InputBegan:Connect(onRight)
		local lastShown: boolean? = nil
		local lastNeed: any = nil
		local function refresh(animate: boolean)
			local on = cfg[key] == true
			lastShown = on
			local unmet = UI.needUnmet(need)
			local blocked = unmet ~= nil
			lastNeed = unmet
			if needTag then
				local show = on and blocked
				if unmet then
					needTag.Text = UI.needText(unmet)
				end
				if needTag.Visible ~= show then
					needTag.Visible = show
					layout()
				end
			end
			local knobGoal = if on then UDim2.new(1, -(M.knob + 2), 0.5, 0) else UDim2.new(0, 2, 0.5, 0)
			local knobCol = if on then Color3.new(1, 1, 1) else C.knobOff
			local labelCol = if on and not blocked then C.text else C.dim
			local glowTr = if on then UI.glowAlpha(0.9) else 1
			if animate then
				tween(knob, TW_TOGGLE, { Position = knobGoal, BackgroundColor3 = knobCol })
				tween(fill, TW_TOGGLE, { BackgroundTransparency = if on then 0 else 1 })
				tween(l, TW_TOGGLE, { TextColor3 = labelCol })
				tween(glow, TW_TOGGLE, { ImageTransparency = glowTr })
			else
				knob.Position = knobGoal
				knob.BackgroundColor3 = knobCol
				fill.BackgroundTransparency = if on then 0 else 1
				l.TextColor3 = labelCol
				glow.ImageTransparency = glowTr
			end
			glow:SetAttribute("glowOff", not on)
		end
		refresh(false)
		local lastExp = expShown()
		table.insert(UI.sync, function()
			if (cfg[key] == true) ~= lastShown or (need ~= nil and UI.needUnmet(need) ~= lastNeed) then
				refresh(true)
			end
			if exp and expShown() ~= lastExp then
				lastExp = expShown()
				layout()
				UI.refilter()
			end
		end)
		-- registry: S.ui.toggles[flag].shown() is what the pill currently displays. A duplicate row chains its
		-- refresh so a programmatic change repaints every pill, not only the last one built.
		do
			local prevReg = S.ui.toggles[key]
			S.ui.toggles[key] = { pill = pill, row = r, refresh = function()
				if prevReg then
					prevReg.refresh()
				end
				refresh(true)
			end, shown = function()
				return lastShown
			end }
		end
		pill.MouseEnter:Connect(function()
			if cfg[key] == true then
				tween(glow, TW_HOVER, { ImageTransparency = UI.glowAlpha(1.3) })
			else
				tween(knob, TW_HOVER, { BackgroundColor3 = C.dim })
			end
		end)
		pill.MouseLeave:Connect(function()
			if cfg[key] == true then
				tween(glow, TW_HOVER, { ImageTransparency = UI.glowAlpha(0.9) })
			else
				tween(knob, TW_HOVER, { BackgroundColor3 = C.knobOff })
			end
		end)
		pill.MouseButton1Click:Connect(function()
			cfg[key] = not cfg[key]
			refresh(true)
			-- onChange may change other keys: save AFTER it, or the derived change is lost
			if topts.onChange then
				topts.onChange(cfg[key])
			end
			saveConfig()
		end)
		if subState and exp then
			-- the sub-rows: ordinary rows of this group, indented, placed right after this one
			local prevParent = g.subParent
			g.subParent = subState
			local okSub, errSub = pcall(topts.sub, g)
			g.subParent = prevParent
			if not okSub then
				log("WARN", ("menu: the sub-options of %s failed to build: %s"):format(text, tostring(errSub)))
			end
			exp.MouseButton1Click:Connect(function()
				if subState.animating then
					return
				end
				local opening = not subState.open
				if UI.brushed(exp :: TextButton) then
					-- metal looks: an open sub-options button is a brushed key
					local light = (exp :: TextButton):FindFirstChild("BrushedLight")
					if light then
						(light :: Frame).Visible = opening
					end
					(exp :: TextButton).BackgroundTransparency = if opening then 0 else 1
					recolourIcon(expIc :: GuiObject, if opening then UI.metal.ink else C.muted)
				else
					recolourIcon(expIc :: GuiObject, if opening then C.accent else C.muted)
				end
				if opening then
					subState.open = true
					UI.refilter()
					UI.animSub(subState, true, nil)
				else
					UI.animSub(subState, false, function()
						subState.open = false
						UI.refilter()
					end)
				end
			end)
			exp.MouseEnter:Connect(function()
				if not (UI.metal and subState.open) then
					(exp :: TextButton).BackgroundTransparency = if UI.metal then 0.85 else 0
				end
			end)
			exp.MouseLeave:Connect(function()
				if not (UI.metal and subState.open) then
					(exp :: TextButton).BackgroundTransparency = 1
				end
			end)
		end
		return r
	end

	function g.slider(_, text: string, key: string, min: number, max: number, step: number?, sopts: { [string]: any })
		sopts = sopts or {}
		sopts.cfgKey = key
		UI.count("slider")
		local r = row(M.row, text, sopts)
		local trackW = sopts.trackW or M.trackW
		local reserve = trackW + 10 + M.valueW
		rowLabel(r, text, sopts, reserve)
		-- value (right): the number in text colour, the unit muted
		local v = button(r, "", M.value, C.text, C.surface)
		v.Name = "Value"
		v.BackgroundTransparency = 1
		v.Size = UDim2.new(0, M.valueW, 1, 0)
		v.AnchorPoint = Vector2.new(1, 0)
		v.Position = UDim2.new(1, 0, 0, 0)
		v.TextXAlignment = Enum.TextXAlignment.Right
		v.RichText = true
		-- outside the safe range an amber warning appears left of the track
		local warnIc: GuiObject? = nil
		if sopts.safe then
			local holder = frame(r)
			holder.Size = UDim2.fromOffset(16, 16)
			holder.AnchorPoint = Vector2.new(1, 0.5)
			holder.Position = UDim2.new(1, -(reserve + 4), 0.5, 0)
			holder.Visible = false
			local wi = icon(holder, "warn", 14)
			recolourIcon(wi, C.warn)
			UI.tip(holder, UI.riskText(sopts.safeText or "SERVER-CHECKED"))
			warnIc = holder
		end
		-- hit area (16 px tall) → track (4 px) → glow → fill → knob
		local rail = button(r, "", 10, C.text, C.off)
		rail.Name = "Rail"
		rail.BackgroundTransparency = 1
		rail.Size = UDim2.new(0, trackW, 0, 16)
		rail.AnchorPoint = Vector2.new(1, 0.5)
		rail.Position = UDim2.new(1, -(M.valueW + 10), 0.5, 0)
		local track = frame(rail, C.off)
		track.Size = UDim2.new(1, 0, 0, 4)
		track.AnchorPoint = Vector2.new(0, 0.5)
		track.Position = UDim2.new(0, 0, 0.5, 0)
		corner(track, 2)
		local fillGlow = UI.glow(track, 5, 0.7)
		fillGlow.AnchorPoint = Vector2.new(0, 0.5)
		fillGlow.Position = UDim2.new(0, -5, 0.5, 0)
		local fill = frame(track, Color3.new(1, 1, 1))
		fill.Size = UDim2.new(0, 0, 1, 0)
		corner(fill, 2)
		UI.metalFill(gradient(fill, C.accent2, C.accent))
		local knob = frame(track, Color3.new(1, 1, 1))
		knob.Size = UDim2.new(0, 10, 0, 10)
		knob.AnchorPoint = Vector2.new(0.5, 0.5)
		knob.Position = UDim2.new(0, 0, 0.5, 0)
		corner(knob, 5)
		local ring = stroke(knob, if UI.metal then UI.metal.lite else C.accent, 1)
		ring.Thickness = if UI.metal then 2 else 3
		local function fmt(n: number): string
			if sopts.fmt then
				return sopts.fmt(n)
			end
			return tostring(math.floor(n * 100 + 0.5) / 100)
		end
		local unit = if type(sopts.unit) == "string" and sopts.unit ~= "" then sopts.unit else nil
		local mutedHex = ("#%02x%02x%02x"):format(math.floor(C.muted.R * 255 + 0.5), math.floor(C.muted.G * 255 + 0.5), math.floor(C.muted.B * 255 + 0.5))
		local shownText = ""
		local function refresh(animateKnob: boolean?)
			local n = tonumber(cfg[key]) or min
			local rel = math.clamp((n - min) / math.max(max - min, 1e-6), 0, 1)
			local kp = UDim2.new(rel, 0, 0.5, 0)
			fillGlow.Visible = rel > 0.01
			-- the fill travels with the knob (a click-jump used to snap the fill and glide the knob)
			if animateKnob then
				tween(knob, TW_KNOB, { Position = kp })
				tween(fill, TW_KNOB, { Size = UDim2.new(rel, 0, 1, 0) })
				tween(fillGlow, TW_KNOB, { Size = UDim2.new(rel, 10, 1, 10) })
			else
				knob.Position = kp
				fill.Size = UDim2.new(rel, 0, 1, 0)
				fillGlow.Size = UDim2.new(rel, 10, 1, 10)
			end
			shownText = fmt(n)
			local unsafe = sopts.safe ~= nil and (n < sopts.safe[1] or n > sopts.safe[2])
			local numCol = if unsafe then ("#%02x%02x%02x"):format(math.floor(C.warn.R * 255 + 0.5), math.floor(C.warn.G * 255 + 0.5), math.floor(C.warn.B * 255 + 0.5)) else nil
			local num = if numCol then ('<font color="%s">%s</font>'):format(numCol, shownText) else shownText
			v.Text = if unit then ('%s<font color="%s">%s%s</font>'):format(num, mutedHex, if unit == "%" or unit == "°" or unit == "×" then "" else " ", unit) else num
			if warnIc then
				warnIc.Visible = unsafe
			end
		end
		local function setRing(on: boolean)
			tween(ring, TW_HOVER, { Transparency = if on then 0.72 else 1 })
		end
		rail.MouseEnter:Connect(function()
			setRing(true)
		end)
		rail.MouseLeave:Connect(function()
			if not (UI.drag and UI.drag.owner == rail) then
				setRing(false)
			end
		end)
		local lastChangeAt = 0
		local function setValue(n: number, dragging: boolean?)
			if step then
				n = math.floor(n / step + 0.5) * step
				-- kill float dust (0.1 + 0.2 → 0.30000000000000004 in the badge and the config)
				local digits = math.max(0, math.ceil(-math.log10(step)))
				local pow = 10 ^ digits
				n = math.floor(n * pow + 0.5) / pow
			end
			n = math.clamp(n, min, max)
			if cfg[key] == n then
				return
			end
			cfg[key] = n
			-- while the mouse drags: no knob tween per pixel and the change callback at ≤ 20 Hz
			-- (the release fires it once more with the final value)
			refresh(not dragging)
			if sopts.onChange then
				local now = os.clock()
				if not dragging or now - lastChangeAt > 0.05 then
					lastChangeAt = now
					sopts.onChange(n)
				end
			end
		end
		local function setFromX(x: number, dragging: boolean?)
			local rel = math.clamp((x - rail.AbsolutePosition.X) / math.max(rail.AbsoluteSize.X, 1), 0, 1)
			setValue(min + (max - min) * rel, dragging)
		end
		refresh(false)
		table.insert(UI.sync, function()
			if fmt(tonumber(cfg[key]) or min) ~= shownText then
				refresh(true)
			end
		end)
		-- one kit-level drag manager (UI.beginDrag) instead of two UserInputService connections per slider
		rail.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then
				setFromX(i.Position.X, true)
				setRing(true)
				UI.beginDrag(function(pos: Vector2)
					setFromX(pos.X, true)
				end, function()
					if sopts.onChange then
						sopts.onChange(tonumber(cfg[key]) or min)
					end
					refresh(true)
					setRing(false)
					saveConfig()
				end)
				if UI.drag then
					UI.drag.owner = rail
				end
			end
		end)
		-- click the number to type a value: Enter sets it, Esc / clicking away keeps the old one. Accepts
		-- "0.3", "x0.3", "15k", "20%", "never", and a typed value may pass the track's ends up to typeMin / typeMax.
		local tMin = if type(sopts.typeMin) == "number" then sopts.typeMin else min
		local tMax = if type(sopts.typeMax) == "number" then sopts.typeMax else max
		local typeDigits = if step and step >= 1 then 0 else 3
		local function plain(n: number): string
			local s = ("%." .. typeDigits .. "f"):format(n)
			if typeDigits > 0 then
				s = string.gsub(string.gsub(s, "0+$", ""), "%.$", "")
			end
			return s
		end
		UI.tip(v, ("Click to type a value (%s – %s)"):format(plain(tMin), plain(tMax)))
		v.MouseEnter:Connect(function()
			v.BackgroundTransparency = 0.55
		end)
		v.MouseLeave:Connect(function()
			v.BackgroundTransparency = 1
		end)
		local editing = false
		v.MouseButton1Click:Connect(function()
			if editing then
				return
			end
			editing = true
			local box = Instance.new("TextBox")
			box.Size = UDim2.new(0, math.max(M.valueW + 24, 66), 0, 22)
			box.AnchorPoint = Vector2.new(1, 0.5)
			box.Position = UDim2.new(1, 2, 0.5, 0)
			box.BackgroundColor3 = C.surface
			box.BorderSizePixel = 0
			UI.setFont(box, UI.F.medium)
			box.TextSize = M.value
			box.TextColor3 = C.text
			box.PlaceholderText = plain(tonumber(cfg[key]) or min)
			box.PlaceholderColor3 = C.muted
			box.TextXAlignment = Enum.TextXAlignment.Right
			box.Text = plain(tonumber(cfg[key]) or min)
			box.ClearTextOnFocus = false
			box.ZIndex = 5
			box.Parent = r
			corner(box, 5)
			stroke(box, C.accent, 0.2)
			padding(box, 0, 6, 0, 6)
			box:CaptureFocus()
			pcall(function()
				box.SelectionStart = 1
				box.CursorPosition = #box.Text + 1
			end)
			box.FocusLost:Connect(function(enterPressed: boolean)
				editing = false
				local n = if enterPressed then UI.parseNumber(box.Text) else nil
				box:Destroy()
				if n == nil then
					return
				end
				local pow = 10 ^ typeDigits
				n = math.clamp(math.floor(n * pow + 0.5) / pow, tMin, tMax)
				if cfg[key] ~= n then
					cfg[key] = n
					refresh(true)
					if sopts.onChange then
						sopts.onChange(n)
					end
				else
					refresh(true)
				end
				saveConfig()
			end)
		end)
		return r
	end

	function g.cycle(_, text: string, key: string, options: { string }, copts: { [string]: any })
		copts = copts or {}
		copts.cfgKey = key
		UI.count("cycle")
		local r = row(M.row, text, copts)
		rowLabel(r, text, copts, M.ctrlW)
		-- optional copts.fmt(value) → display text, so numeric options read as words;
		-- shown lowercase like every label (the stored value keeps its case)
		local function shownOf(v: any): string
			if copts.fmt then
				local okF, s = pcall(copts.fmt, v)
				if okF and s ~= nil then
					return string.lower(tostring(s))
				end
			end
			return string.lower(tostring(v))
		end
		local b = button(r, "", M.value, C.text, C.surface)
		b.Name = "Dropdown"
		b.Size = UDim2.new(0, M.ctrlW, 0, 22)
		b.AnchorPoint = Vector2.new(1, 0.5)
		b.Position = UDim2.new(1, 0, 0.5, 0)
		corner(b, 5)
		local bs = stroke(b, C.edge, 0)
		local val = label(b, "", M.value, C.text, UI.F.body)
		val.Size = UDim2.new(1, -30, 1, 0)
		val.Position = UDim2.fromOffset(9, 0)
		val.TextTruncate = Enum.TextTruncate.AtEnd
		local chev = icon(b, "expand", 16)
		chev.AnchorPoint = Vector2.new(1, 0.5)
		chev.Position = UDim2.new(1, -4, 0.5, 0)
		recolourIcon(chev, C.muted)
		local function refresh()
			val.Text = shownOf(cfg[key])
		end
		refresh()
		table.insert(UI.sync, function()
			if val.Text ~= shownOf(cfg[key]) then
				refresh()
			end
		end)
		b.MouseEnter:Connect(function()
			b.BackgroundColor3 = C.card
		end)
		b.MouseLeave:Connect(function()
			b.BackgroundColor3 = C.surface
		end)
		b.MouseButton1Click:Connect(function()
			bs.Color = C.accent
			UI.openDropdown(b, M.ctrlW, function(f: Frame): number
				for i, opt in ipairs(options) do
					UI.dropdownOption(f, 4 + (i - 1) * 24, shownOf(opt), cfg[key] == opt, function()
						cfg[key] = opt
						refresh()
						UI.closeDropdown()
						-- save AFTER onChange: it may set other keys
						if copts.onChange then
							copts.onChange(opt)
						end
						saveConfig()
					end)
				end
				return 8 + #options * 24
			end, function()
				bs.Color = C.edge
			end)
		end)
		return r
	end

	function g.color(_, text: string, key: string, copts: { [string]: any })
		copts = copts or {}
		copts.cfgKey = key
		UI.count("color")
		local r = row(M.row, text, copts)
		rowLabel(r, text, copts, 36)
		local sw = button(r, "", 10, C.text, colOf(key))
		sw.Name = "Swatch"
		sw.Size = UDim2.new(0, 28, 0, 16)
		sw.AnchorPoint = Vector2.new(1, 0.5)
		sw.Position = UDim2.new(1, 0, 0.5, 0)
		corner(sw, 4)
		stroke(sw, Color3.new(1, 1, 1), 0.82)
		local hh, ss, vv = colOf(key):ToHSV()
		local function apply(c3: Color3)
			cfg[key] = { math.floor(c3.R * 255 + 0.5), math.floor(c3.G * 255 + 0.5), math.floor(c3.B * 255 + 0.5) }
			sw.BackgroundColor3 = c3
			if copts.onChange then
				copts.onChange(c3)
			end
		end
		table.insert(UI.sync, function()
			local c = colOf(key)
			if sw.BackgroundColor3 ~= c then
				sw.BackgroundColor3 = c
			end
		end)
		sw.MouseButton1Click:Connect(function()
			hh, ss, vv = colOf(key):ToHSV()
			UI.openDropdown(sw, 206, function(f: Frame): number
				local rails: any = {}
				local function refreshRails()
					local hueKeys = {}
					for i = 0, 6 do
						table.insert(hueKeys, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV((i / 6) % 1, 1, 1)))
					end
					rails.h.grad.Color = ColorSequence.new(hueKeys)
					rails.s.grad.Color = ColorSequence.new(Color3.fromHSV(hh, 0, vv), Color3.fromHSV(hh, 1, vv))
					rails.v.grad.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.fromHSV(hh, ss, 1))
					rails.h.mark.Position = UDim2.new(hh, 0, 0.5, 0)
					rails.s.mark.Position = UDim2.new(ss, 0, 0.5, 0)
					rails.v.mark.Position = UDim2.new(vv, 0, 0.5, 0)
				end
				local function setFrom(kind: string, px: number)
					local rl = rails[kind].rail
					local rel = math.clamp((px - rl.AbsolutePosition.X) / math.max(rl.AbsoluteSize.X, 1), 0, 1)
					if kind == "h" then
						hh = rel
					elseif kind == "s" then
						ss = rel
					else
						vv = rel
					end
					apply(Color3.fromHSV(hh, ss, vv))
					refreshRails()
				end
				local function mkRail(kind: string, y: number)
					local rl = button(f, "", 10, C.text, Color3.new(1, 1, 1))
					rl.Size = UDim2.new(1, -20, 0, 10)
					rl.Position = UDim2.fromOffset(10, y)
					rl.ZIndex = 61
					corner(rl, 5)
					local grad = Instance.new("UIGradient")
					grad.Parent = rl
					local mark = frame(rl, Color3.new(1, 1, 1))
					mark.Size = UDim2.fromOffset(4, 14)
					mark.AnchorPoint = Vector2.new(0.5, 0.5)
					mark.ZIndex = 62
					corner(mark, 2)
					stroke(mark, Color3.new(0, 0, 0), 0.45)
					rails[kind] = { rail = rl, grad = grad, mark = mark }
					rl.InputBegan:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1 then
							setFrom(kind, i.Position.X)
							UI.beginDrag(function(pos: Vector2)
								setFrom(kind, pos.X)
							end, function()
								saveConfig()
							end)
						end
					end)
				end
				mkRail("h", 40)
				mkRail("s", 60)
				mkRail("v", 80)
				local presets = { C.accent, Color3.fromRGB(242, 240, 247), Color3.fromRGB(142, 138, 153), Color3.fromRGB(255, 92, 122), Color3.fromRGB(255, 150, 70), Color3.fromRGB(255, 214, 90), Color3.fromRGB(69, 223, 160), Color3.fromRGB(96, 170, 255), Color3.fromRGB(173, 102, 255) }
				for i, pc in ipairs(presets) do
					local pb = button(f, "", 10, C.text, pc)
					pb.Size = UDim2.fromOffset(18, 18)
					pb.Position = UDim2.fromOffset(10 + (i - 1) * 21, 10)
					pb.ZIndex = 61
					corner(pb, 9)
					stroke(pb, Color3.new(1, 1, 1), 0.82)
					pb.MouseButton1Click:Connect(function()
						hh, ss, vv = pc:ToHSV()
						apply(pc)
						saveConfig()
						refreshRails()
					end)
				end
				refreshRails()
				return 102
			end, copts.onClose)
		end)
		return r
	end

	-- keybind: click → press a key / mouse button / M4 / M5 (Escape or Backspace clears)
	function g.keybind(_, text: string, key: string, kopts: { [string]: any })
		kopts = kopts or {}
		kopts.cfgKey = key
		UI.count("keybind")
		local r = row(M.row, text, kopts)
		rowLabel(r, text, kopts, 90)
		local b = button(r, "", M.small, C.dim, Color3.fromRGB(26, 25, 32))
		b.Name = "Key"
		b.AutomaticSize = Enum.AutomaticSize.X
		b.Size = UDim2.new(0, 34, 0, 20)
		b.AnchorPoint = Vector2.new(1, 0.5)
		b.Position = UDim2.new(1, 0, 0.5, 0)
		UI.setFont(b, UI.F.semibold)
		corner(b, 4)
		local ks = stroke(b, C.edge, 0)
		padding(b, 0, 8, 0, 8)
		-- metal looks: the key is a brushed keycap with dark ink
		local keyed = UI.brushed(b)
		if keyed then
			b.TextColor3 = UI.metal.ink
			UI.setFont(b, UI.F.bold)
			b.BackgroundColor3 = Color3.fromRGB(228, 228, 232)
		end
		b.MouseEnter:Connect(function()
			if keyed then
				tween(b, TW_HOVER, { BackgroundColor3 = Color3.new(1, 1, 1) })
			else
				ks.Color = C.muted
			end
		end)
		b.MouseLeave:Connect(function()
			if keyed then
				tween(b, TW_HOVER, { BackgroundColor3 = Color3.fromRGB(228, 228, 232) })
			else
				ks.Color = C.edge
			end
		end)
		local function show()
			b.Text = Input.keyLabel(cfg[key])
		end
		show()
		table.insert(UI.sync, function()
			if not Input.capturing() and b.Text ~= Input.keyLabel(cfg[key]) then
				show()
			end
		end)
		b.MouseButton1Click:Connect(function()
			b.Text = "Press a key…"
			Input.captureKey(function(name)
				if name ~= false then
					cfg[key] = name or ""
					saveConfig()
					if kopts.onChange then
						kopts.onChange(cfg[key])
					end
				end
				show()
			end)
		end)
		return r
	end

	function g.button(_, text: string, fn: () -> (), tint: Color3?, bopts: any?)
		bopts = bopts or {}
		UI.count("button")
		local r = row(M.rowButton, text, bopts)
		-- neutral by default; a tint (accent / danger / warn) makes it the tinted primary style
		local base = if tint then tint else C.surface
		local b = button(r, string.lower(text), M.value, if tint then tint else C.dim, base)
		b.Size = UDim2.new(1, 0, 0, 26)
		b.AnchorPoint = Vector2.new(0, 0.5)
		b.Position = UDim2.new(0, 0, 0.5, 0)
		b.BackgroundTransparency = if tint then 0.87 else 0
		b.TextTruncate = Enum.TextTruncate.AtEnd
		corner(b, 6)
		local st = stroke(b, if tint then tint else C.edge, if tint then 0.6 else 0)
		-- metal looks: the accent (primary) button is a brushed key with dark ink; danger / warn keep their tint
		local keyed = tint == C.accent and UI.brushed(b)
		local rest = Color3.fromRGB(228, 228, 232)
		if keyed then
			b.BackgroundTransparency = 0
			b.BackgroundColor3 = rest
			b.TextColor3 = UI.metal.ink
			UI.setFont(b, UI.F.bold)
		end
		b.MouseEnter:Connect(function()
			if keyed then
				tween(b, TW_HOVER, { BackgroundColor3 = Color3.new(1, 1, 1) })
			elseif tint then
				tween(b, TW_HOVER, { BackgroundTransparency = 0.8 })
			else
				tween(b, TW_HOVER, { BackgroundColor3 = C.card, TextColor3 = C.text })
			end
		end)
		b.MouseLeave:Connect(function()
			if keyed then
				tween(b, TW_HOVER, { BackgroundColor3 = rest })
			elseif tint then
				tween(b, TW_HOVER, { BackgroundTransparency = 0.87 })
			else
				tween(b, TW_HOVER, { BackgroundColor3 = C.surface, TextColor3 = C.dim })
			end
		end)
		-- press feedback: a 1 px dip so a click is visibly acknowledged
		b.MouseButton1Down:Connect(function()
			b.Position = UDim2.new(0, 0, 0.5, 1)
			st.Transparency = 0
		end)
		b.MouseButton1Up:Connect(function()
			b.Position = UDim2.new(0, 0, 0.5, 0)
			st.Transparency = if keyed then 0.5 elseif tint then 0.6 else 0
		end)
		b.MouseButton1Click:Connect(function()
			local ok, err = pcall(fn)
			if not ok then
				reportError("button " .. text, err)
			end
		end)
		if type(bopts.desc) == "string" and bopts.desc ~= "" then
			UI.tip(b, bopts.desc)
		end
		return b
	end

	function g.note(_, text: string, nopts: { [string]: any })
		nopts = nopts or {}
		nopts.isNote = true
		UI.count("note")
		-- the row grows with its text (live notes change length); nopts.height is only a floor
		local width = opts.colW or M.colW
		local minH = if text ~= "" then UI.textH(text, M.desc, nil, width) + 8 else math.max(18, nopts.height or 18)
		local r = row(minH, text, nopts)
		r.AutomaticSize = Enum.AutomaticSize.Y
		local l = label(r, text, M.desc, nopts.color or C.muted, UI.F.body)
		l.Size = UDim2.new(1, 0, 0, 0)
		l.Position = UDim2.new(0, 0, 0, 3)
		l.AutomaticSize = Enum.AutomaticSize.Y
		l.TextWrapped = true
		l.TextYAlignment = Enum.TextYAlignment.Top
		return l
	end

	-- picker: ‹ value › over a list that can change; idxKey persists the index
	function g.picker(_, text: string, getList: () -> { string }, idxKey: string, onChange: (string) -> ())
		UI.count("picker")
		local r = row(M.row, text)
		local l = label(r, string.lower(text), M.title, C.text, UI.F.body)
		l.Size = UDim2.new(0, 70, 1, 0)
		local val = label(r, "", M.value, C.text, UI.F.medium)
		val.Size = UDim2.new(1, -140, 1, 0)
		val.Position = UDim2.new(0, 74, 0, 0)
		val.TextTruncate = Enum.TextTruncate.AtEnd
		local function mk(ic: string, x: number): TextButton
			local b = button(r, "", M.title, C.text, C.surface)
			b.Size = UDim2.new(0, 24, 0, 22)
			b.AnchorPoint = Vector2.new(0, 0.5)
			b.Position = UDim2.new(1, x, 0.5, 0)
			corner(b, 5)
			stroke(b, C.edge, 0)
			recolourIcon(icon(b, ic, 16), C.dim)
			return b
		end
		local prev, nxt = mk("left", -52), mk("right", -24)
		local function refresh()
			local list = getList()
			if #list == 0 then
				val.Text = "—"
				return
			end
			cfg[idxKey] = ((tonumber(cfg[idxKey]) or 1) - 1) % #list + 1
			val.Text = list[cfg[idxKey]]
			onChange(list[cfg[idxKey]])
		end
		prev.MouseButton1Click:Connect(function()
			cfg[idxKey] = (tonumber(cfg[idxKey]) or 1) - 1
			refresh()
			saveConfig()
		end)
		nxt.MouseButton1Click:Connect(function()
			cfg[idxKey] = (tonumber(cfg[idxKey]) or 1) + 1
			refresh()
			saveConfig()
		end)
		refresh()
		return refresh
	end

	-- multiselect: cfg[key] = { [option] = true }
	function g.multiselect(_, text: string, key: string, options: { string }, mopts: { [string]: any })
		mopts = mopts or {}
		mopts.cfgKey = key
		UI.count("multiselect")
		local r = row(M.row, text, mopts)
		rowLabel(r, text, mopts, M.ctrlW)
		if type(cfg[key]) ~= "table" then
			cfg[key] = {}
		end
		local b = button(r, "", M.value, C.text, C.surface)
		b.Name = "Multiselect"
		b.Size = UDim2.new(0, M.ctrlW, 0, 22)
		b.AnchorPoint = Vector2.new(1, 0.5)
		b.Position = UDim2.new(1, 0, 0.5, 0)
		corner(b, 5)
		local bs = stroke(b, C.edge, 0)
		local val = label(b, "", M.value, C.text, UI.F.body)
		val.Size = UDim2.new(1, -30, 1, 0)
		val.Position = UDim2.fromOffset(9, 0)
		val.TextTruncate = Enum.TextTruncate.AtEnd
		local chev = icon(b, "expand", 16)
		chev.AnchorPoint = Vector2.new(1, 0.5)
		chev.Position = UDim2.new(1, -4, 0.5, 0)
		recolourIcon(chev, C.muted)
		local function summary(): string
			local on = {}
			for _, opt in ipairs(options) do
				if cfg[key][opt] == true then
					table.insert(on, opt)
				end
			end
			if #on == 0 then
				return "None"
			elseif #on == #options then
				return "All"
			end
			return table.concat(on, ", ")
		end
		local function refresh()
			val.Text = summary()
		end
		refresh()
		-- follows changes made elsewhere (presets, a duplicate row)
		table.insert(UI.sync, function()
			if val.Text ~= summary() then
				refresh()
			end
		end)
		b.MouseEnter:Connect(function()
			b.BackgroundColor3 = C.card
		end)
		b.MouseLeave:Connect(function()
			b.BackgroundColor3 = C.surface
		end)
		b.MouseButton1Click:Connect(function()
			bs.Color = C.accent
			UI.openDropdown(b, M.ctrlW, function(f: Frame): number
				local optBtns = {}
				local function paint()
					for opt, ob in pairs(optBtns) do
						local on = cfg[key][opt] == true
						ob:SetAttribute("selected", on)
						local ic = ob:FindFirstChild("Icon")
						if ic then
							ic.Visible = on
						end
						local lb = ob:FindFirstChildOfClass("TextLabel")
						if lb and lb.Name ~= "Icon" then
							lb.TextColor3 = if on then C.accent else C.dim
						end
					end
				end
				for i, opt in ipairs(options) do
					optBtns[opt] = UI.dropdownOption(f, 4 + (i - 1) * 24, opt, cfg[key][opt] == true, function()
						cfg[key][opt] = if cfg[key][opt] then nil else true
						if mopts.onChange then
							mopts.onChange(cfg[key])
						end
						saveConfig()
						refresh()
						paint()
					end)
				end
				return 8 + #options * 24
			end, function()
				bs.Color = C.edge
			end)
		end)
		return r
	end

	function g.custom(_, hgt: number, text: string?, copts: any?): Frame
		return row(hgt, text or "", copts)
	end
	-- a short text value bound to cfg[key] (a name, a tag): typed in a field on the right, committed on
	-- Enter or when focus leaves; topts.maxLen caps it, topts.placeholder shows while empty
	function g.textbox(_, text: string, key: string, topts: { [string]: any })
		topts = topts or {}
		topts.cfgKey = key
		UI.count("textbox")
		local r = row(M.row, text, topts)
		rowLabel(r, text, topts, 150)
		local box = Instance.new("TextBox")
		box.Name = "Field"
		box.Size = UDim2.new(0, 140, 0, 22)
		box.AnchorPoint = Vector2.new(1, 0.5)
		box.Position = UDim2.new(1, 0, 0.5, 0)
		box.BackgroundColor3 = C.surface
		box.BorderSizePixel = 0
		box.ClearTextOnFocus = false
		box.FontFace = UI.F.medium
		box.TextSize = M.value
		box.TextColor3 = C.text
		box.PlaceholderColor3 = C.muted
		box.PlaceholderText = topts.placeholder or ""
		box.TextXAlignment = Enum.TextXAlignment.Left
		box.TextTruncate = Enum.TextTruncate.AtEnd
		box.Text = tostring(cfg[key] or "")
		box.Parent = r
		corner(box, 5)
		stroke(box, C.edge, 0)
		padding(box, 0, 8, 0, 8)
		local maxLen = topts.maxLen or 24
		box:GetPropertyChangedSignal("Text"):Connect(function()
			local cut = utf8.offset(box.Text, maxLen + 1)
			if utf8.len(box.Text) and cut then
				box.Text = box.Text:sub(1, cut - 1)
			end
		end)
		box.FocusLost:Connect(function()
			local v = box.Text:gsub("^%s+", ""):gsub("%s+$", "")
			cfg[key] = v
			box.Text = v
			if topts.onChange then
				topts.onChange(v)
			end
			saveConfig()
		end)
		table.insert(UI.sync, function()
			if not box:IsFocused() and box.Text ~= tostring(cfg[key] or "") then
				box.Text = tostring(cfg[key] or "")
			end
		end)
		return box
	end

	-- read-only row: label left, a live value right (the getter runs while the menu is open)
	function g.info(_, text: string, getter: () -> any, iopts: any?): TextLabel
		iopts = iopts or {}
		UI.count("info")
		local r = row(M.row, text, iopts)
		local l = label(r, string.lower(text), M.title, C.dim, UI.F.body)
		l.Size = UDim2.new(0.45, 0, 1, 0)
		l.TextTruncate = Enum.TextTruncate.AtEnd
		local v = label(r, "", M.value, C.text, UI.F.medium)
		v.Size = UDim2.new(0.55, 0, 1, 0)
		v.Position = UDim2.new(0.45, 0, 0, 0)
		v.TextXAlignment = Enum.TextXAlignment.Right
		v.TextTruncate = Enum.TextTruncate.AtEnd
		local function refresh()
			local ok, s = pcall(getter)
			local txt = if ok and s ~= nil then tostring(s) else "—"
			if v.Text ~= txt then
				v.Text = txt
			end
		end
		refresh()
		UI.syncLazy(function()
			if r.Visible then
				refresh()
			end
		end)
		return v
	end
	-- a key / value row its owner fills: the everyday row look, the value right-aligned in the value face
	function g.stat(_, text: string, sopts: any?): TextLabel
		UI.count("info")
		local r = row(M.row, text, sopts or {})
		local l = label(r, string.lower(text), M.title, C.dim, UI.F.body)
		l.Size = UDim2.new(0.34, 0, 1, 0)
		l.TextTruncate = Enum.TextTruncate.AtEnd
		local v = label(r, "—", M.value, C.text, UI.F.medium)
		v.Size = UDim2.new(0.66, -8, 1, 0)
		v.Position = UDim2.new(0.34, 8, 0, 0)
		v.TextXAlignment = Enum.TextXAlignment.Right
		v.TextTruncate = Enum.TextTruncate.AtEnd
		return v
	end
	-- a card of `n` monospace lines (logs)
	function g.logBlock(_, text: string, n: number): { TextLabel }
		local lineH = math.max(16, UI.TEXT_MIN + 5)
		local r = row(n * lineH + 18, text, {})
		local card = frame(r, C.surface)
		card.Size = UDim2.new(1, 0, 1, -6)
		card.Position = UDim2.fromOffset(0, 3)
		corner(card, 8)
		stroke(card, C.edge, 0)
		padding(card, 6, 10, 6, 10)
		vlist(card, 0)
		local out = {}
		for i = 1, n do
			local t = label(card, "", UI.TEXT_MIN, C.dim, UI.F.code)
			t.Size = UDim2.new(1, 0, 0, lineH)
			t.TextTruncate = Enum.TextTruncate.AtEnd
			t.LayoutOrder = i
			out[i] = t
		end
		return out
	end

	-- a row of equal buttons: items = { { label, fn, tint? }, ... }
	function g.buttonRow(_, text: string, items: { any }, bopts: any?): { TextButton }
		bopts = bopts or {}
		UI.count("button")
		local r = row(M.rowButton, text, bopts)
		local out = {}
		local n = #items
		for i, it in ipairs(items) do
			local tint = it[3]
			local b = button(r, string.lower(tostring(it[1])), M.value, if tint then tint else C.dim, if tint then tint else C.surface)
			b.Size = UDim2.new(1 / n, if i < n then -6 else 0, 0, 26)
			b.AnchorPoint = Vector2.new(0, 0.5)
			b.Position = UDim2.new((i - 1) / n, if i > 1 then (i - 1) * 6 / n else 0, 0.5, 0)
			b.BackgroundTransparency = if tint then 0.87 else 0
			b.TextTruncate = Enum.TextTruncate.AtEnd
			corner(b, 6)
			stroke(b, if tint then tint else C.edge, if tint then 0.6 else 0)
			-- metal looks: an accent button is a brushed key (see g.button)
			local keyed = tint == C.accent and UI.brushed(b)
			if keyed then
				b.BackgroundTransparency = 0
				b.BackgroundColor3 = Color3.fromRGB(228, 228, 232)
				b.TextColor3 = UI.metal.ink
				UI.setFont(b, UI.F.bold)
			end
			b.MouseEnter:Connect(function()
				if keyed then
					b.BackgroundColor3 = Color3.new(1, 1, 1)
				elseif tint then
					b.BackgroundTransparency = 0.8
				else
					b.BackgroundColor3 = C.card
					b.TextColor3 = C.text
				end
			end)
			b.MouseLeave:Connect(function()
				if keyed then
					b.BackgroundColor3 = Color3.fromRGB(228, 228, 232)
				elseif tint then
					b.BackgroundTransparency = 0.87
				else
					b.BackgroundColor3 = C.surface
					b.TextColor3 = C.dim
				end
			end)
			b.MouseButton1Click:Connect(function()
				local ok, err = pcall(it[2])
				if not ok then
					reportError("button " .. tostring(it[1]), err)
				end
			end)
			out[i] = b
		end
		return out
	end

	-- list: single-select scrolling list with a search box. lopts = { height, search = true,
	--   items = () -> { { id, label, sub?, color?, dim? } }, selected = () -> id?, onSelect = (id) -> () }
	-- Rows are pooled; returns refresh(). Re-renders itself when the selection changes elsewhere.
	function g.list(_, text: string, lopts: any)
		lopts = lopts or {}
		lopts.isList = true
		UI.count("list")
		-- the visible area is a whole number of rows (+ 8 px padding): no half row cut off at the bottom edge
		local RH = M.listRow
		local hdr = if lopts.search ~= false then 52 else 24
		local wanted = math.ceil((lopts.height or 200) * 1.15)
		local rowsFit = math.max(3, math.floor((wanted - hdr - 8) / RH))
		local height = hdr + rowsFit * RH + 8
		local r = row(height, text, lopts)
		local l = label(r, string.lower(text), M.title, C.text, UI.F.body)
		l.Size = UDim2.new(1, -110, 0, 22)
		local countLbl = label(r, "", M.small, C.muted, UI.F.medium)
		countLbl.Size = UDim2.new(0, 100, 0, 22)
		countLbl.Position = UDim2.new(1, -100, 0, 0)
		countLbl.TextXAlignment = Enum.TextXAlignment.Right
		local top = 24
		local query = ""
		local refresh: any
		if lopts.search ~= false then
			local box = Instance.new("TextBox")
			box.Size = UDim2.new(1, 0, 0, 24)
			box.Position = UDim2.new(0, 0, 0, 24)
			box.BackgroundColor3 = C.surface
			box.BorderSizePixel = 0
			UI.setFont(box, UI.F.body)
			box.TextSize = M.value
			box.TextColor3 = C.text
			box.PlaceholderText = lopts.placeholder or "Search"
			box.PlaceholderColor3 = C.muted
			box.Text = ""
			box.ClearTextOnFocus = false
			box.TextXAlignment = Enum.TextXAlignment.Left
			box.Parent = r
			corner(box, 6)
			local bs = stroke(box, C.edge, 0)
			padding(box, 0, 8, 0, 26)
			local sic = icon(box, "search", 14)
			sic.AnchorPoint = Vector2.new(0, 0.5)
			sic.Position = UDim2.new(0, -19, 0.5, 0)
			recolourIcon(sic, C.muted)
			box.Focused:Connect(function()
				tween(bs, TW_HOVER, { Color = C.accent })
			end)
			box.FocusLost:Connect(function()
				tween(bs, TW_HOVER, { Color = C.edge })
			end)
			box:GetPropertyChangedSignal("Text"):Connect(function()
				query = string.lower(box.Text)
				if refresh then
					refresh()
				end
			end)
			top = 52
		end
		local sc = Instance.new("ScrollingFrame")
		sc.Size = UDim2.new(1, 0, 1, -top)
		sc.Position = UDim2.new(0, 0, 0, top)
		sc.BackgroundColor3 = C.side
		sc.BackgroundTransparency = 0
		sc.BorderSizePixel = 0
		sc.ScrollBarThickness = 4
		sc.ScrollBarImageColor3 = C.faint
		sc.ScrollBarImageTransparency = 0
		sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
		sc.CanvasSize = UDim2.new(0, 0, 0, 0)
		sc.ScrollingDirection = Enum.ScrollingDirection.Y
		sc.Parent = r
		corner(sc, 6)
		stroke(sc, C.edge, 0)
		vlist(sc, 2)
		padding(sc, 4, 6, 4, 4)
		local pool: { any } = {}
		local rowId: { [Instance]: any } = {}
		local lastSel: any = nil
		local function mkRow(): any
			local b = button(sc, "", M.value, C.dim, C.accent)
			b.BackgroundTransparency = 1
			b.Size = UDim2.new(1, 0, 0, RH - 2)
			b.TextXAlignment = Enum.TextXAlignment.Left
			b.TextTruncate = Enum.TextTruncate.AtEnd
			UI.setFont(b, UI.F.body)
			corner(b, 5)
			padding(b, 0, 8, 0, 8)
			local st = stroke(b, C.accent, 1)
			local sub = label(b, "", M.small, C.muted, UI.F.medium)
			sub.Size = UDim2.new(0, 120, 1, 0)
			sub.Position = UDim2.new(1, -120, 0, 0)
			sub.TextXAlignment = Enum.TextXAlignment.Right
			local rec = { btn = b, sub = sub, stroke = st, selected = false }
			b.MouseEnter:Connect(function()
				if not rec.selected then
					tween(b, TW_HOVER, { BackgroundTransparency = 0.88 })
				end
			end)
			b.MouseLeave:Connect(function()
				if not rec.selected then
					tween(b, TW_HOVER, { BackgroundTransparency = 1 })
				end
			end)
			b.MouseButton1Click:Connect(function()
				local id = rowId[b]
				if id ~= nil and lopts.onSelect then
					local ok, err = pcall(lopts.onSelect, id)
					if not ok then
						reportError("list " .. text, err)
					end
					refresh()
				end
			end)
			return rec
		end
		local scrolledFor: any = nil
		refresh = function()
			local items = lopts.items and lopts.items() or {}
			local sel = lopts.selected and lopts.selected() or nil
			lastSel = sel
			local shown = 0
			local selIdx: number? = nil
			for _, it in ipairs(items) do
				local lab = tostring(it.label or it.id)
				if query == "" or string.find(string.lower(lab), query, 1, true) or (it.sub and string.find(string.lower(tostring(it.sub)), query, 1, true)) then
					shown += 1
					local rec = pool[shown]
					if not rec then
						rec = mkRow()
						pool[shown] = rec
					end
					local b = rec.btn
					rowId[b] = it.id
					b.Visible = true
					b.LayoutOrder = shown
					b.Text = lab
					rec.sub.Text = tostring(it.sub or "")
					rec.sub.TextColor3 = it.color or C.muted
					rec.selected = it.id == sel
					if rec.selected then
						selIdx = shown
					end
					b.TextColor3 = if rec.selected then C.text elseif it.dim then C.muted else C.dim
					b.BackgroundColor3 = C.accent
					b.BackgroundTransparency = if rec.selected then 0.82 else 1
					rec.stroke.Transparency = if rec.selected then 0.35 else 1
				end
			end
			for i = shown + 1, #pool do
				pool[i].btn.Visible = false
			end
			countLbl.Text = if shown == #items then tostring(#items) else ("%d / %d"):format(shown, #items)
			-- bring the selection into view when it changed
			if selIdx and sel ~= scrolledFor then
				scrolledFor = sel
				local visible = math.max(sc.AbsoluteWindowSize.Y, RH)
				local y = math.max(0, (selIdx - 1) * RH - visible / 2 + RH / 2)
				task.defer(function()
					if sc.Parent then
						sc.CanvasPosition = Vector2.new(0, y)
					end
				end)
			end
		end
		refresh()
		table.insert(UI.sync, function()
			local sel = lopts.selected and lopts.selected() or nil
			if sel ~= lastSel then
				refresh()
			end
		end)
		return refresh
	end

	return g
end

-------------------------------------------------------------------------------
-- §12 menu window: host, one-layer acrylic window, rail (logo, nav, user card), top bar, pages
-------------------------------------------------------------------------------
local Menu: any = { pages = {}, subs = {}, tabBtns = {}, loops = {}, s = 1, activeTab = "", tabOrder = {} }
S.menu = Menu
local MENU_W, MENU_H, RAIL_W, HEADER_H, SUBBAR_H = 820, 520, 184, 50, 32
local menuAnimToken = 0

function Menu.px(n: number): number
	return math.floor(n * Menu.s + 0.5)
end
function Menu.layout()
	local vs = if Menu.gui then Menu.gui.AbsoluteSize else Vector2.new(1920, 1080)
	if vs.X < 200 or vs.Y < 200 then
		local cam = workspace.CurrentCamera
		vs = if cam then cam.ViewportSize else Vector2.new(1920, 1080)
	end
	-- the chosen size, stepped down until the window fits the screen
	local want = tonumber(cfg.menuScale) or 1
	local s = 0.9
	for _, step in ipairs({ 1.25, 1.1, 1, 0.9 }) do
		if step <= want + 1e-6 and 820 * step <= vs.X - 24 and 520 * step <= vs.Y - 24 then
			s = step
			break
		end
	end
	Menu.s = s
	MENU_W, MENU_H = Menu.px(820), Menu.px(520)
	MENU_W -= MENU_W % 2 -- even: a centred window lands on whole pixels
	MENU_H -= MENU_H % 2
	RAIL_W, HEADER_H, SUBBAR_H = Menu.px(184), Menu.px(50), Menu.px(32)
	-- the kit's metrics follow the size (fonts and every control dimension, rounded)
	Menu.M_BASE = Menu.M_BASE or table.clone(UI.M)
	for k, v in pairs(Menu.M_BASE) do
		if type(v) == "number" and k ~= "descLine" then
			UI.M[k] = if UI.TEXT_KEYS[k] then math.max(UI.TEXT_MIN, Menu.px(v)) else Menu.px(v)
		end
	end
end

function Menu.slide(obj: GuiObject, base: UDim2, dy: number, dur: number, fade: GuiObject?, closing: boolean?, done: (() -> ())?)
	local info = TweenInfo.new(dur, Enum.EasingStyle.Quart, if closing then Enum.EasingDirection.In else Enum.EasingDirection.Out)
	obj.Position = if closing then base else base + UDim2.fromOffset(0, dy)
	local t: Tween
	if fade then
		fade.BackgroundTransparency = if closing then 1 else 0
		t = TweenService:Create(fade, info, { BackgroundTransparency = if closing then 0 else 1 })
		if dy ~= 0 then
			tween(obj, info, { Position = if closing then base + UDim2.fromOffset(0, dy) else base })
		end
	else
		t = TweenService:Create(obj, info, { Position = if closing then base + UDim2.fromOffset(0, dy) else base })
	end
	t.Completed:Connect(function(state: any)
		if state ~= Enum.PlaybackState.Completed then
			return
		end
		if closing and obj.Parent then
			obj.Position = base
		end
		if done then
			done()
		end
	end)
	t:Play()
end
-- ambient motion (the turning edge, the breathing glow, the logo): looping tweens that run only while the menu shows
function Menu.loop(obj: Instance, info: TweenInfo, props: any): Tween
	local t = TweenService:Create(obj, info, props)
	table.insert(Menu.loops, t)
	if S.menuOpen then
		t:Play()
	end
	return t
end
function Menu.runLoops(on: boolean)
	for _, t in ipairs(Menu.loops or {}) do
		if on then
			t:Play()
		else
			t:Pause()
		end
	end
end
-- the window is one layer stepped at the rail's edge: the tab list in an accent-tinted acrylic, the content solid
function Menu.applyGlass()
	local g = Menu.glassGrad
	if not g then
		return
	end
	-- metal looks: a solid rail
	local railA = if UI.metal then 0 else math.clamp((tonumber(cfg.railGlass) or 14) / 100, 0, 0.4)
	local r = math.clamp(Menu.glassSplit or 0.22, 0.01, 0.98)
	local railTint = if UI.metal then C.side:Lerp(UI.metal.mid, 0.1) else C.side:Lerp(C.accent2, 0.16)
	g.Rotation = 0
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, railTint),
		ColorSequenceKeypoint.new(r - 0.002, railTint),
		ColorSequenceKeypoint.new(r, C.bg),
		ColorSequenceKeypoint.new(1, C.bg),
	})
	g.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, railA),
		NumberSequenceKeypoint.new(r - 0.002, railA),
		NumberSequenceKeypoint.new(r, 0),
		NumberSequenceKeypoint.new(1, 0),
	})
end

function Menu.set(open: boolean)
	S.menuOpen = open
	menuAnimToken += 1
	local token = menuAnimToken
	if Menu.mouseFree then
		Menu.mouseFree.Visible = open
	end
	if not (Menu.gui and Menu.root and Menu.backdrop and Menu.host) then
		return
	end
	local host, curtain = Menu.host, Menu.curtain
	Menu.hostBase = Menu.hostBase or host.Position
	local base = Menu.hostBase
	if open then
		Menu.gui.Enabled = true
		Menu.runLoops(true)
		Menu.backdrop.Visible = true
		Menu.backdrop.BackgroundTransparency = 1
		Menu.root.Visible = true
		host.Visible = true
		if curtain then
			curtain.Visible = true
			curtain.BackgroundTransparency = 0
		end
		-- the selection pill and sub-tab thumb measure the laid-out gui: place them once it exists
		Menu.measureSoon(false)
		-- the content fades in under a curtain of the window's colour; the window itself stays put
		Menu.slide(host, base, 0, TW_OPEN.Time, curtain, false, function()
			if token == menuAnimToken and curtain then
				curtain.Visible = false
			end
			if token == menuAnimToken and S.menuOpen and Menu.clampToScreen then
				Menu.clampToScreen()
			end
		end)
	else
		UI.closeBindPopup()
		UI.closeDropdown()
		if curtain then
			curtain.Visible = true
		end
		Menu.slide(host, base, 0, UI.TW.close.Time, curtain, true, function()
			if token == menuAnimToken and not S.menuOpen then
				host.Visible = false
				host.Position = base
				Menu.backdrop.Visible = false
				Menu.gui.Enabled = false
				Menu.runLoops(false)
			end
		end)
	end
end
function Menu.toggle()
	Menu.set(not S.menuOpen)
end

-- page / sub-page change: a sheet of the window's colour over the new content lifts away, so the old
-- content never cuts to the new in one frame; the pill / thumb carry the motion
Menu.revealTw = setmetatable({}, { __mode = "k" })
function Menu.settle(obj: GuiObject, base: UDim2)
	local t = Menu.revealTw[obj]
	if t then
		t:Cancel()
		Menu.revealTw[obj] = nil
	end
	if obj.Position ~= base then
		obj.Position = base
	end
end
function Menu.reveal(obj: GuiObject, base: UDim2, _dx: number, _dy: number, cover: number)
	Menu.settle(obj, base)
	local sheet = Menu.pageCurtain
	if not sheet then
		return
	end
	Menu.revealToken = (Menu.revealToken or 0) + 1
	local token = Menu.revealToken
	sheet.Position = UDim2.fromOffset(0, cover)
	sheet.Size = UDim2.new(1, 0, 1, -cover)
	sheet.BackgroundTransparency = 0.12
	sheet.Visible = true
	tween(sheet, UI.TW.reveal, { BackgroundTransparency = 1 }).Completed:Connect(function(state: any)
		if state == Enum.PlaybackState.Completed and token == Menu.revealToken then
			sheet.Visible = false
		end
	end)
end
function Menu.showTab(name: string)
	if not Menu.pages[name] then
		return
	end
	local was = Menu.activeTab
	Menu.activeTab = name
	UI.closeDropdown()
	local changed = was ~= name
	local animate = changed and was ~= "" and S.menuOpen == true
	local dir = 1
	if animate and (table.find(Menu.tabOrder, name) or 0) < (table.find(Menu.tabOrder, was) or 0) then
		dir = -1
	end
	for n, page in pairs(Menu.pages) do
		local show = n == name
		if show and animate then
			Menu.reveal(page, UDim2.new(), 0, dir * Menu.px(18), 0)
		elseif changed then
			Menu.settle(page, UDim2.new())
		end
		page.Visible = show
	end
	for n, d in pairs(Menu.tabBtns) do
		if d.paint and (not changed or n == name or n == was or not animate) then
			d.paint(n == name, animate)
		end
	end
	Menu.measureSoon(animate)
end
-- the pill and the thumb read AbsolutePosition: measured after this frame's layout
function Menu.measureSoon(animate: boolean?)
	if Menu.measurePending then
		Menu.measureAnimate = Menu.measureAnimate or animate
		return
	end
	Menu.measurePending = true
	Menu.measureAnimate = animate
	local function run()
		Menu.measurePending = false
		local anim = Menu.measureAnimate
		Menu.measureAnimate = nil
		if Menu.placeNav then
			Menu.placeNav(anim)
		end
		Menu.placeSubThumb(Menu.activeTab, false)
	end
	local ok = pcall(function()
		RunService.Heartbeat:Once(run)
	end)
	if not ok then
		task.defer(run)
	end
end
function Menu.placeSubThumb(tab: string, animate: boolean?)
	local st = Menu.subs[tab]
	if not (st and st.liquid and st.track) then
		return
	end
	local b = st.btns[st.active]
	local btn = b and b.btn
	if not (btn and btn.Visible) then
		st.thumb.Visible = false
		return
	end
	local w = btn.AbsoluteSize.X
	if w < 1 then
		return -- not laid out yet: the list's AbsoluteSize signal places it
	end
	st.thumb.Visible = true
	local x = btn.AbsolutePosition.X - st.track.AbsolutePosition.X
	st.liquid.to(x, x + w, animate and S.menuOpen == true)
end
function Menu.showSub(tab: string, sub: string)
	local st = Menu.subs[tab]
	if not st then
		return
	end
	UI.closeDropdown()
	local was = st.active
	st.active = sub
	local changed = was ~= sub
	if st.crumb then
		st.crumb.Text = string.lower(tab .. " / " .. sub)
	end
	local animate = changed and st.built == true and S.menuOpen == true and Menu.activeTab == tab
	local dir = 1
	if animate and (table.find(st.order, sub) or 0) < (table.find(st.order, was) or 0) then
		dir = -1
	end
	for n, fr in pairs(st.frames) do
		local show = n == sub
		if show and animate then
			Menu.reveal(fr, st.base, dir * Menu.px(22), 0, st.top)
		elseif changed then
			Menu.settle(fr, st.base)
		end
		fr.Visible = show
	end
	for n, b in pairs(st.btns) do
		local on = n == sub
		local col = if on and UI.metal then UI.metal.ink elseif on then C.text else C.muted
		if animate then
			tween(b.lbl, TW_HOVER, { TextColor3 = col })
		else
			b.lbl.TextColor3 = col
		end
		UI.setFont(b.lbl, if on then UI.F.medium else UI.F.body)
	end
	if animate then
		local ok = pcall(function()
			RunService.Heartbeat:Once(function()
				Menu.placeSubThumb(tab, true)
			end)
		end)
		if not ok then
			Menu.placeSubThumb(tab, true)
		end
	else
		Menu.placeSubThumb(tab, false)
	end
end
-- a sub-tab whose every group is hidden (Simple mode, or a search) hides its button too and hands the page to the first one that still shows something
function Menu.hideEmptySubs()
	for tab, st in pairs(Menu.subs) do
		if #st.order > 1 then
			local firstShown: string? = nil
			for _, sub in ipairs(st.order) do
				local sc = st.frames[sub]
				local any = false
				for _, g in ipairs(UI.groups) do
					local p = g.frame.Parent
					if g.frame.Visible and p and p.Parent == sc then
						any = true
						break
					end
				end
				st.btns[sub].btn.Visible = any
				if any and not firstShown then
					firstShown = sub
				end
			end
			if firstShown and not (st.btns[st.active] and st.btns[st.active].btn.Visible) then
				Menu.showSub(tab, firstShown)
			end
		end
	end
end

function Menu.addTab(name: string, subs: { string }): any
	local content = Menu.content
	local page = frame(content)
	page.Name = "Page_" .. name
	page.Size = UDim2.new(1, 0, 1, 0)
	page.Visible = false
	Menu.pages[name] = page
	S.ui.tabs[name] = page
	S.ui.subTabs[name] = {}
	local multi = #subs > 1
	-- sub-tabs: a segmented control on a track; the active segment is a thumb that glides between segments
	local bar = frame(page)
	bar.Name = "SubBar"
	bar.Size = UDim2.new(1, -36, 0, SUBBAR_H)
	bar.Position = UDim2.new(0, 18, 0, 4)
	bar.Visible = multi
	local track = frame(bar, C.surface)
	track.Name = "Track"
	track.AutomaticSize = Enum.AutomaticSize.X
	track.Size = UDim2.new(0, 0, 1, -2)
	track.AnchorPoint = Vector2.new(0, 0.5)
	track.Position = UDim2.new(0, 0, 0.5, 0)
	corner(track, 8)
	stroke(track, C.edge, 0.2)
	local thumb = frame(track, Color3.new(1, 1, 1))
	thumb.Name = "Thumb"
	thumb.BackgroundTransparency = 0.91
	thumb.ZIndex = 2
	thumb.Visible = false
	corner(thumb, 6)
	stroke(thumb, Color3.new(1, 1, 1), 0.9)
	if UI.brushed(thumb) then
		thumb.BackgroundTransparency = 0
	end
	local list = frame(track)
	list.Name = "Segments"
	list.AutomaticSize = Enum.AutomaticSize.X
	list.Size = UDim2.new(0, 0, 1, 0)
	list.ZIndex = 3
	vlist(list, 2, true)
	padding(list, 3, 3, 3, 3)
	local st: any = { frames = {}, btns = {}, active = subs[1], order = subs, track = track, thumb = thumb }
	Menu.subs[name] = st
	-- where you are, right of the sub-tabs ("players / esp")
	local crumb = label(bar, "", UI.M.small, C.muted, UI.F.body)
	crumb.Name = "Crumb"
	crumb.AnchorPoint = Vector2.new(1, 0)
	crumb.Position = UDim2.new(1, 0, 0, 0)
	crumb.Size = UDim2.new(0.4, 0, 1, 0)
	crumb.TextXAlignment = Enum.TextXAlignment.Right
	crumb.TextTruncate = Enum.TextTruncate.AtEnd
	st.crumb = crumb
	st.liquid = UI.liquid(thumb, function(a: number, b: number)
		thumb.Position = UDim2.new(0, a, 0, 3)
		thumb.Size = UDim2.new(0, math.max(4, b - a), 1, -6)
	end)
	UI.conn(list:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		Menu.placeSubThumb(name, false)
	end))
	local top = if multi then SUBBAR_H + 6 else 0
	st.top = top
	st.base = UDim2.new(0, 0, 0, top)
	for i, sub in ipairs(subs) do
		local b = button(list, "", UI.M.value, C.muted, C.surface)
		b.BackgroundTransparency = 1
		b.AutomaticSize = Enum.AutomaticSize.X
		b.Size = UDim2.new(0, 0, 1, 0)
		b.LayoutOrder = i
		b.ZIndex = 3
		local lbl = label(b, string.lower(sub), UI.M.value + 1, C.muted, UI.F.body)
		lbl.Size = UDim2.new(0, 0, 1, 0)
		lbl.AutomaticSize = Enum.AutomaticSize.X
		lbl.TextYAlignment = Enum.TextYAlignment.Center
		lbl.ZIndex = 3
		padding(lbl, 0, Menu.px(12), 0, Menu.px(12))
		-- whole-pixel segments, so the thumb that glides onto them rests on whole pixels
		UI.snapWidth(lbl, Menu.px(12) * 2)
		st.btns[sub] = { lbl = lbl, btn = b }
		b.MouseEnter:Connect(function()
			if st.active ~= sub then
				tween(lbl, TW_HOVER, { TextColor3 = C.dim })
			end
		end)
		b.MouseLeave:Connect(function()
			if st.active ~= sub then
				tween(lbl, TW_HOVER, { TextColor3 = C.muted })
			end
		end)
		b.MouseButton1Click:Connect(function()
			Menu.showSub(name, sub)
		end)
		local scroll = Instance.new("ScrollingFrame")
		scroll.Name = "Sub_" .. sub
		scroll.Size = UDim2.new(1, 0, 1, -top)
		scroll.Position = UDim2.new(0, 0, 0, top)
		scroll.BackgroundTransparency = 1
		scroll.BorderSizePixel = 0
		scroll.ScrollBarThickness = 4
		scroll.ScrollBarImageColor3 = C.faint
		scroll.ScrollBarImageTransparency = 0.1
		scroll.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
		scroll.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
		scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		scroll.Visible = i == 1
		scroll.Parent = page
		padding(scroll, 14, 18, 10, 18)
		-- an open dropdown would stay where its control used to be
		scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(UI.closeDropdown)
		-- two columns with a 24 px gutter. Inside a padded ScrollingFrame a child's Size scale is
		-- measured against the full frame while its Position scale is measured against the padded
		-- box: half the padding (36 → 18) and half the gutter (12) come off each width; the right
		-- column starts 12 px past the padded midpoint.
		local left = frame(scroll)
		left.Name = "L"
		left.Size = UDim2.new(0.5, -30, 0, 0)
		left.AutomaticSize = Enum.AutomaticSize.Y
		vlist(left, 0)
		local right = frame(scroll)
		right.Name = "R"
		right.Size = UDim2.new(0.5, -30, 0, 0)
		right.Position = UDim2.new(0.5, 12, 0, 0)
		right.AutomaticSize = Enum.AutomaticSize.Y
		vlist(right, 0)
		st.frames[sub] = scroll
		S.ui.subTabs[name][sub] = scroll
		scroll:SetAttribute("Sub", sub)
		st[sub] = { L = left, R = right, scroll = scroll }
	end
	Menu.showSub(name, subs[1])
	st.built = true
	return st
end

function Menu.groupHeight(g: any): number
	local h = 32 + 4 + 6 + 12 -- card header, gap under it, card bottom padding, spacing under the group
	for _, r in ipairs(g.rows) do
		if r.frame.Visible then
			h += math.max(r.base, if r.frame.AbsoluteSize.Y > 0 and r.isNote then r.frame.AbsoluteSize.Y else 0)
		end
	end
	return h
end
function Menu.balanceColumns()
	local byOrder = function(a: any, b: any)
		return a.frame.LayoutOrder < b.frame.LayoutOrder
	end
	local function height(list: { any }): number
		local h = 0
		for _, g in ipairs(list) do
			h += Menu.groupHeight(g)
		end
		return h
	end
	for _, st in pairs(Menu.subs) do
		for _, sc in pairs(st.frames) do
			local L, R = sc:FindFirstChild("L"), sc:FindFirstChild("R")
			if L and R then
				local cols: { [Instance]: { any } } = { [L] = {}, [R] = {} }
				for _, g in ipairs(UI.groups) do
					local p = g.frame.Parent
					if (p == L or p == R) and g.frame.Visible then
						table.insert(cols[p], g)
					end
				end
				table.sort(cols[L], byOrder)
				table.sort(cols[R], byOrder)
				local guard = 0
				while guard < 12 do
					guard += 1
					local hl, hr = height(cols[L]), height(cols[R])
					local tall, short = if hl >= hr then L else R, if hl >= hr then R else L
					local list = cols[tall]
					if #list < 2 then
						break
					end
					-- the group whose move brings the columns closest; trailing groups append to the
					-- short column, the lead group goes to its top so it stays where the eye lands first
					local diff = math.abs(hl - hr)
					local bestIdx, bestDiff = nil, diff - 24
					for i = 1, #list do
						local gh = Menu.groupHeight(list[i])
						local after = math.abs(diff - 2 * gh)
						if after < bestDiff then
							bestIdx, bestDiff = i, after
						end
					end
					if not bestIdx then
						break -- nothing would clearly help
					end
					local g = table.remove(list, bestIdx)
					local minOrder, maxOrder = math.huge, 0
					for _, other in ipairs(cols[short]) do
						minOrder = math.min(minOrder, other.frame.LayoutOrder)
						maxOrder = math.max(maxOrder, other.frame.LayoutOrder)
					end
					if bestIdx == 1 then
						table.insert(cols[short], 1, g)
						g.frame.LayoutOrder = if minOrder == math.huge then 1 else minOrder - 1
					else
						table.insert(cols[short], g)
						g.frame.LayoutOrder = maxOrder + 1
					end
					g.frame.Parent = short
				end
			end
		end
	end
end
UI.afterRefilter = function()
	Menu.hideEmptySubs()
	Menu.measureSoon(false)
end

function Menu.destroy()
	UI.closeBindPopup()
	UI.closeDropdown()
	for _, t in ipairs(Menu.loops or {}) do
		pcall(t.Cancel, t)
	end
	Menu.loops = {}
	Menu.glassGrad = nil
	for _, c in ipairs(UI.conns) do
		pcall(c.Disconnect, c)
	end
	table.clear(UI.conns)
	if Menu.gui then
		pcall(Menu.gui.Destroy, Menu.gui)
	end
	Menu.gui, Menu.root, Menu.host, Menu.backdrop, Menu.curtain, Menu.content = nil, nil, nil, nil, nil, nil
	Menu.pages, Menu.subs, Menu.tabBtns = {}, {}, {}
	Menu.placeNav = nil
	UI.gui, UI.root, UI.popupHost = nil, nil, nil
end

-- the window chrome: everything but the pages
function Menu.buildChrome(opts: any)
	UI.resetRegistries()
	Menu.pages, Menu.subs, Menu.tabBtns = {}, {}, {}
	local gui = Instance.new("ScreenGui")
	gui.Name = opts.GuiName or "CocaineUI"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder = 1000
	gui.Enabled = false
	if not parentGui(gui) then
		error("could not parent the menu (PlayerGui, gethui and CoreGui all refused)")
	end
	Menu.gui = gui
	UI.gui = gui

	-- invisible and inert: clicks beside the window go to the game (only the window captures input)
	local backdrop = frame(gui)
	backdrop.Name = "Backdrop"
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.BackgroundTransparency = 1
	backdrop.Active = false
	backdrop.Visible = false
	backdrop.ZIndex = 1
	Menu.backdrop = backdrop

	-- 820 × 520 at 100 %; Menu size re-lays everything out in whole pixels
	Menu.layout()
	local px = Menu.px
	UI.M.colW = math.floor((MENU_W - RAIL_W) / 2) - 30
	local host = frame(gui)
	host.Name = "Host"
	host.AnchorPoint = Vector2.new(0.5, 0.5)
	host.Size = UDim2.new(0, MENU_W, 0, MENU_H)
	host.Position = UDim2.fromScale(0.5, 0.5)
	host.Visible = false
	host.ZIndex = 2
	Menu.host = host
	Menu.hostBase = nil
	UI.popupHost = host

	-- the window is ONE layer: a hard-stepped gradient paints the tab list in its acrylic tint and the content solid (Menu.applyGlass).
	-- Outside it: an accent edge, a hollow shadow and an accent aura — all static.
	local root = frame(host, Color3.new(1, 1, 1))
	root.Name = "Root"
	root.Size = UDim2.fromScale(1, 1)
	root.ZIndex = 1
	root.Active = true
	root.ClipsDescendants = false
	corner(root, 12)
	Menu.root = root
	UI.root = root
	Menu.loops = {}
	Menu.glassSplit = RAIL_W / MENU_W
	Menu.glassGrad = gradient(root, C.side, C.bg)
	do
		local edge = stroke(root, Color3.new(1, 1, 1), 0)
		local eg = Instance.new("UIGradient")
		eg.Rotation = 35
		eg.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, C.accent),
			ColorSequenceKeypoint.new(0.35, C.edge),
			ColorSequenceKeypoint.new(0.7, C.edge),
			ColorSequenceKeypoint.new(1, C.accent2),
		})
		eg.Parent = edge
		if UI.metalEdge(edge) then
			Menu.loop(eg, TweenInfo.new(30, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), { Rotation = 395 })
		end
		UI.softShadow(root, "Shadow", Color3.new(0, 0, 0), 0.45, 22)
		UI.softShadow(root, "Aura", C.accent, UI.glowAlpha(0.4), 20)
	end
	-- a visible Modal button frees the cursor even while the game locks it
	local mouseFree = Instance.new("TextButton")
	mouseFree.Name = "MouseFree"
	mouseFree.Modal = true
	mouseFree.Text = ""
	mouseFree.AutoButtonColor = false
	mouseFree.BackgroundTransparency = 1
	mouseFree.Size = UDim2.fromOffset(1, 1)
	mouseFree.Visible = S.menuOpen == true
	mouseFree.Parent = root
	Menu.mouseFree = mouseFree
	-- open / close fade: a sheet of the window's own colour over everything, faded by Menu.slide
	local curtain = frame(root, C.bg)
	curtain.Name = "Curtain"
	curtain.Size = UDim2.fromScale(1, 1)
	curtain.ZIndex = 60
	curtain.Visible = false
	corner(curtain, 12)
	Menu.curtain = curtain

	-- sidebar: logo, pages by section, user card
	local side = frame(root)
	side.Name = "Sidebar"
	side.Size = UDim2.new(0, RAIL_W, 1, 0)
	side.ZIndex = 2
	side.ClipsDescendants = true
	corner(side, 12)
	do
		local wash = frame(side, Color3.new(1, 1, 1))
		wash.Name = "AcrylicWash"
		wash.Size = UDim2.new(1, 12, 1, 0)
		wash.ZIndex = 2
		wash.Active = false
		corner(wash, 12)
		local wg = gradient(wash, C.accent, C.accent2, 90)
		if UI.metal then
			wg.Color = ColorSequence.new(UI.metal.lite, UI.metal.mid)
		end
		wg.Transparency = if UI.metal
			then NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.9),
				NumberSequenceKeypoint.new(0.45, 0.975),
				NumberSequenceKeypoint.new(1, 0.93),
			})
			else NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.8),
				NumberSequenceKeypoint.new(0.45, 0.94),
				NumberSequenceKeypoint.new(1, 0.84),
			})
		UI.acrylic(wash, { light = 0, grain = 0.96, radius = 12, z = 2 })
		-- the lights sit far enough in that their falloff ends before the window's rounded corners
		if UI.glowRadial then
			for _, spec in ipairs({
				{ C.accent, 0.72, math.floor(RAIL_W * 0.55), px(80), px(240), px(190) },
				{ C.accent2, 0.8, px(170), MENU_H - px(90), px(260), px(260) },
			}) do
				local bleed = Instance.new("ImageLabel")
				bleed.Name = "AcrylicBleed"
				bleed.BackgroundTransparency = 1
				bleed.Image = UI.glowRadial
				bleed.ImageColor3 = spec[1]
				bleed.ImageTransparency = spec[2]
				bleed.AnchorPoint = Vector2.new(0.5, 0.5)
				bleed.Position = UDim2.fromOffset(spec[3], spec[4])
				bleed.Size = UDim2.fromOffset(spec[5], spec[6])
				bleed.ZIndex = 3
				bleed.Parent = side
			end
		end
	end
	local sideHair = frame(root, Color3.new(1, 1, 1))
	sideHair.Size = UDim2.new(0, 1, 1, 0)
	sideHair.Position = UDim2.new(0, RAIL_W, 0, 0)
	sideHair.ZIndex = 4
	gradient(sideHair, C.accent, C.hairline, 90).Transparency = NumberSequence.new(0.2, 0)
	local LOGO_H = px(58)
	local logo = frame(side)
	logo.Name = "Logo"
	logo.Size = UDim2.new(1, 0, 0, LOGO_H)
	logo.ZIndex = 4
	logo.Active = true
	local gemPx = px(20)
	local gemHolder = frame(logo)
	gemHolder.Size = UDim2.fromOffset(gemPx, gemPx)
	gemHolder.AnchorPoint = Vector2.new(0, 0.5)
	gemHolder.Position = UDim2.new(0, px(18), 0.5, 0)
	gemHolder.ZIndex = 5
	-- a soft halo behind the face, kept low so the mark itself reads over it
	local gemGlow = UI.glow(gemHolder, 9, 0.45)
	gemGlow.ZIndex = 5
	Menu.loop(gemGlow, TweenInfo.new(2.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { ImageTransparency = math.min(1, gemGlow.ImageTransparency + 0.15) })
	local gem = UI.logoMark(gemHolder, gemPx + 2, 45)
	gem.ZIndex = 6
	-- the wordmark: the 0 in the accent (when the title has one)
	local title = tostring(opts.Title or "c0caine")
	local brandRow = frame(logo)
	brandRow.Name = "Brand"
	brandRow.Size = UDim2.new(1, -px(50), 1, 0)
	brandRow.Position = UDim2.new(0, px(46), 0, 0)
	brandRow.ZIndex = 5
	local brl = vlist(brandRow, px(7), true)
	brl.VerticalAlignment = Enum.VerticalAlignment.Center
	local wordSize = px(21)
	local zeroAt = string.find(title, "0", 1, true)
	local richTitle = if zeroAt then title:sub(1, zeroAt - 1) .. ('<font color="#%s">0</font>'):format(C.accent:ToHex()) .. title:sub(zeroAt + 1) else title
	local word = label(brandRow, richTitle, wordSize, C.text, UI.HUD_BOLD)
	word.RichText = true
	word.AutomaticSize = Enum.AutomaticSize.None
	word.Size = UDim2.new(0, UI.gw(title, wordSize, true) + 2, 1, 0)
	word.LayoutOrder = 1
	word.ZIndex = 5
	-- a band of the accent sweeps across the wordmark every few seconds
	do
		local shimmer = Instance.new("UIGradient")
		shimmer.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(0.42, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(0.5, C.accent),
			ColorSequenceKeypoint.new(0.58, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
		})
		if UI.metal then
			-- metal looks: the wordmark is lit metal and the band drifts slowly up and down
			word.Text = title
			word.TextColor3 = Color3.new(1, 1, 1)
			shimmer.Rotation = 90
			shimmer.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, UI.metal.hi),
				ColorSequenceKeypoint.new(0.34, UI.metal.hi:Lerp(UI.metal.lite, 0.6)),
				ColorSequenceKeypoint.new(0.48, UI.metal.lite:Lerp(UI.metal.mid, 0.3)),
				ColorSequenceKeypoint.new(0.58, UI.metal.hi),
				ColorSequenceKeypoint.new(0.78, UI.metal.hi:Lerp(UI.metal.lite, 0.5)),
				ColorSequenceKeypoint.new(1, UI.metal.hi),
			})
			shimmer.Offset = Vector2.new(0, -0.14)
			shimmer.Parent = word
			Menu.loop(shimmer, TweenInfo.new(6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Offset = Vector2.new(0, 0.14) })
		else
			shimmer.Offset = Vector2.new(-1, 0)
			shimmer.Parent = word
			Menu.loop(shimmer, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, false, 3.2), { Offset = Vector2.new(1, 0) })
		end
	end

	-- top bar (over the content): config picker + save on the left, search / settings / close right
	local top = frame(root)
	top.Name = "TopBar"
	top.Size = UDim2.new(1, -RAIL_W, 0, HEADER_H)
	top.Position = UDim2.new(0, RAIL_W, 0, 0)
	top.ZIndex = 3
	top.Active = true
	local topHair = frame(top, C.hairline)
	topHair.Size = UDim2.new(1, 0, 0, 1)
	topHair.Position = UDim2.new(0, 0, 1, -1)
	topHair.ZIndex = 3
	local function topButton(w: number, x: number, anchorRight: boolean): TextButton
		local b = button(top, "", UI.M.value, C.dim, C.surface)
		b.Size = UDim2.fromOffset(px(w), px(28))
		b.AnchorPoint = Vector2.new(if anchorRight then 1 else 0, 0.5)
		b.Position = UDim2.new(if anchorRight then 1 else 0, px(x), 0.5, 0)
		b.ZIndex = 4
		corner(b, 6)
		stroke(b, C.edge, 0)
		return b
	end
	-- config picker: the active config, a quick load list
	local cfgBtn = topButton(140, 16, false)
	local cfgLbl = label(cfgBtn, "", UI.M.value, C.text, UI.F.body)
	cfgLbl.Size = UDim2.new(1, -30, 1, 0)
	cfgLbl.Position = UDim2.fromOffset(10, 0)
	cfgLbl.TextTruncate = Enum.TextTruncate.AtEnd
	cfgLbl.ZIndex = 5
	local cfgChev = icon(cfgBtn, "expand", 16)
	cfgChev.AnchorPoint = Vector2.new(1, 0.5)
	cfgChev.Position = UDim2.new(1, -5, 0.5, 0)
	cfgChev.ZIndex = 5
	recolourIcon(cfgChev, C.muted)
	local function syncCfgLabel()
		local active = Library.ActiveConfig or ""
		local t2 = if active ~= "" then active else "No config"
		if cfgLbl.Text ~= t2 then
			cfgLbl.Text = t2
		end
		cfgLbl.TextColor3 = if active ~= "" then C.text else C.muted
	end
	syncCfgLabel()
	table.insert(UI.sync, syncCfgLabel)
	cfgBtn.MouseButton1Click:Connect(function()
		local names = Library:ListConfigs()
		local shown = math.min(#names, 8)
		if shown == 0 then
			Library:Notify(if EXEC.caps.files then "No saved configs yet" else "This executor can't read or write files", 3, "info")
			return
		end
		UI.openDropdown(cfgBtn, 180, function(f: Frame): number
			for i = 1, shown do
				local nm = names[i]
				UI.dropdownOption(f, 4 + (i - 1) * 24, nm, nm == Library.ActiveConfig, function()
					UI.closeDropdown()
					local ok, res = Library:LoadConfig(nm)
					Library:Notify(if ok then "Loaded " .. nm else tostring(res), if ok then 2 else 3, if ok then "ok" else "warn")
				end)
			end
			return 8 + shown * 24
		end)
	end)
	UI.tip(cfgBtn, "The config your settings came from. Pick another to load it.")
	local saveBtn = topButton(76, 164, false)
	local saveIc = icon(saveBtn, "save", 15)
	saveIc.AnchorPoint = Vector2.new(0, 0.5)
	saveIc.Position = UDim2.new(0, 10, 0.5, 0)
	saveIc.ZIndex = 5
	recolourIcon(saveIc, C.dim)
	local saveLbl = label(saveBtn, "save", UI.M.value, C.dim, UI.F.medium)
	saveLbl.Size = UDim2.new(1, -32, 1, 0)
	saveLbl.Position = UDim2.fromOffset(31, 0)
	saveLbl.ZIndex = 5
	-- unsaved-changes dot: it flashes, a solid core and a ring that swells and fades
	local dirtyDot = frame(saveBtn, C.accent)
	dirtyDot.Size = UDim2.fromOffset(9, 9)
	dirtyDot.AnchorPoint = Vector2.new(0.5, 0.5)
	dirtyDot.Position = UDim2.new(1, -2, 0, 2)
	dirtyDot.ZIndex = 6
	dirtyDot.Visible = false
	corner(dirtyDot, 5)
	local dirtyRing = stroke(dirtyDot, C.accent, 0)
	table.insert(UI.sync, function()
		local d = Library:IsDirty()
		if dirtyDot.Visible ~= d then
			dirtyDot.Visible = d
		end
		if d then
			local wave = 0.5 + 0.5 * math.sin(os.clock() * math.pi * 3)
			dirtyDot.BackgroundTransparency = 0.45 * (1 - wave)
			dirtyRing.Color = dirtyDot.BackgroundColor3
			dirtyRing.Thickness = 1 + 4 * wave
			dirtyRing.Transparency = 0.25 + 0.75 * wave
		end
	end)
	saveBtn.MouseButton1Click:Connect(function()
		local name = Library.ActiveConfig
		if not name or name == "" then
			name = opts.DefaultConfig or "default"
		end
		local ok, res = Library:SaveConfig(name)
		Library:Notify(if ok then "Saved into " .. name else tostring(res), if ok then 2 else 3, if ok then "ok" else "warn")
	end)
	UI.tip(saveBtn, "Writes your current settings into the active config. The dot means there are changes it doesn't have yet.")
	-- metal looks: Save is a brushed key (dark ink); its hover lifts the metal's brightness
	if UI.brushed(saveBtn) then
		saveLbl.TextColor3 = UI.metal.ink
		recolourIcon(saveIc, UI.metal.ink)
		UI.setFont(saveLbl, UI.F.bold)
		saveBtn.BackgroundColor3 = Color3.fromRGB(228, 228, 232)
	end
	for _, b in ipairs({ cfgBtn, saveBtn }) do
		b.MouseEnter:Connect(function()
			tween(b, TW_HOVER, { BackgroundColor3 = if b == saveBtn and UI.metal then Color3.new(1, 1, 1) else C.card })
		end)
		b.MouseLeave:Connect(function()
			tween(b, TW_HOVER, { BackgroundColor3 = if b == saveBtn and UI.metal then Color3.fromRGB(228, 228, 232) else C.surface })
		end)
	end
	local function iconButton(name: string, x: number, hoverColor: Color3?): TextButton
		local b = button(top, "", 10, C.text, C.card)
		b.Size = UDim2.fromOffset(px(28), px(28))
		b.AnchorPoint = Vector2.new(1, 0.5)
		b.Position = UDim2.new(1, px(x), 0.5, 0)
		b.BackgroundTransparency = 1
		b.ZIndex = 4
		corner(b, 6)
		local ic = icon(b, name, px(17))
		ic.ZIndex = 5
		recolourIcon(ic, C.muted)
		b.MouseEnter:Connect(function()
			tween(b, TW_HOVER, { BackgroundTransparency = 0 })
			UI.tintIcon(ic, hoverColor or C.text, true)
		end)
		b.MouseLeave:Connect(function()
			tween(b, TW_HOVER, { BackgroundTransparency = 1 })
			UI.tintIcon(ic, C.muted, true)
		end)
		return b
	end
	local closeBtn = iconButton("close", -14)
	closeBtn.MouseButton1Click:Connect(function()
		Menu.set(false)
	end)
	UI.tip(closeBtn, "Close the menu (" .. Input.keyLabel(cfg.menuKey) .. ")")
	local settingsBtn = iconButton("Settings", -46)
	settingsBtn.MouseButton1Click:Connect(function()
		Menu.showTab(opts.SettingsTabName or "Interface")
	end)
	UI.tip(settingsBtn, "Interface: Simple / Advanced mode, theme, menu size")
	local searchBox = frame(top, C.surface)
	searchBox.Size = UDim2.fromOffset(px(176), px(28))
	searchBox.AnchorPoint = Vector2.new(1, 0.5)
	searchBox.Position = UDim2.new(1, -px(82), 0.5, 0)
	searchBox.ZIndex = 4
	corner(searchBox, 6)
	local searchStroke = stroke(searchBox, C.edge, 0)
	local sIc = icon(searchBox, "search", 15)
	sIc.AnchorPoint = Vector2.new(0, 0.5)
	sIc.Position = UDim2.new(0, 9, 0.5, 0)
	sIc.ZIndex = 5
	recolourIcon(sIc, C.muted)
	local search = Instance.new("TextBox")
	search.Name = "Search"
	search.Size = UDim2.new(1, -38, 1, 0)
	search.Position = UDim2.fromOffset(30, 0)
	search.BackgroundTransparency = 1
	search.BorderSizePixel = 0
	UI.setFont(search, UI.F.body)
	search.TextSize = UI.M.value
	search.TextColor3 = C.text
	search.PlaceholderText = "search settings"
	search.PlaceholderColor3 = C.muted
	search.Text = ""
	search.ClearTextOnFocus = false
	search.TextXAlignment = Enum.TextXAlignment.Left
	search.ZIndex = 5
	search.Parent = searchBox
	search:GetPropertyChangedSignal("Text"):Connect(function()
		UI.search(search.Text)
	end)
	search.Focused:Connect(function()
		tween(searchStroke, TW_HOVER, { Color = C.accent })
	end)
	search.FocusLost:Connect(function()
		tween(searchStroke, TW_HOVER, { Color = C.edge })
	end)
	Menu.search = search

	-- content area (pages live here)
	local content = frame(root)
	content.Name = "Content"
	content.Size = UDim2.new(1, -RAIL_W, 1, -HEADER_H)
	content.Position = UDim2.new(0, RAIL_W, 0, HEADER_H)
	content.ClipsDescendants = true
	content.ZIndex = 3
	Menu.content = content
	do
		local pageCurtain = frame(content, C.bg)
		pageCurtain.Name = "PageCurtain"
		pageCurtain.Size = UDim2.fromScale(1, 1)
		pageCurtain.ZIndex = 40
		pageCurtain.Visible = false
		pageCurtain.Active = false
		corner(pageCurtain, 12)
		Menu.pageCurtain = pageCurtain
	end

	-- sidebar navigation: a scrolling list that ends above the user card
	local CARD_H = px(56)
	local nav = Instance.new("ScrollingFrame")
	nav.Name = "Nav"
	nav.Position = UDim2.new(0, 0, 0, LOGO_H)
	nav.Size = UDim2.new(1, 0, 1, -LOGO_H - CARD_H)
	nav.BackgroundTransparency = 1
	nav.BorderSizePixel = 0
	nav.ScrollBarThickness = 2
	nav.ScrollBarImageColor3 = C.faint
	nav.ScrollingDirection = Enum.ScrollingDirection.Y
	nav.AutomaticCanvasSize = Enum.AutomaticSize.Y
	nav.CanvasSize = UDim2.new(0, 0, 0, 0)
	nav.ZIndex = 4
	nav.Parent = side
	vlist(nav, 1)
	padding(nav, 0, 8, px(6), 8)
	Menu.nav = nav
	-- the selection: one pill under the nav, on a layer clipped to the nav's box. It glides between items with a stretch (UI.liquid).
	do
		local navClip = frame(side)
		navClip.Name = "NavSelection"
		navClip.Position = nav.Position
		navClip.Size = nav.Size
		navClip.ClipsDescendants = true
		navClip.ZIndex = 3
		local sel = frame(navClip, Color3.new(1, 1, 1))
		sel.Name = "Pill"
		sel.BackgroundTransparency = 0.93
		sel.Visible = false
		sel.ZIndex = 3
		corner(sel, 6)
		stroke(sel, Color3.new(1, 1, 1), 0.92)
		if UI.brushed(sel) then
			sel.BackgroundTransparency = 0
		end
		Menu.navSel = sel
		Menu.navLiquid = UI.liquid(sel, function(a: number, b: number)
			sel.Position = UDim2.fromOffset(Menu.navSelX or 8, a)
			sel.Size = UDim2.fromOffset(Menu.navSelW or (RAIL_W - 16), math.max(4, b - a))
		end)
		function Menu.placeNav(animate: boolean?)
			local d = Menu.tabBtns[Menu.activeTab]
			local item = d and d.item
			if not (item and item.Parent and item.Visible) then
				sel.Visible = false
				return
			end
			local rel = item.AbsolutePosition - navClip.AbsolutePosition
			local size = item.AbsoluteSize
			if size.Y < 1 then
				return -- not laid out yet (the gui is still disabled): Menu.set places it on open
			end
			Menu.navSelX, Menu.navSelW = rel.X, size.X
			sel.Visible = true
			Menu.navLiquid.to(rel.Y, rel.Y + size.Y, animate and S.menuOpen == true)
		end
		UI.conn(nav:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			if Menu.placeNav then
				Menu.placeNav(false)
			end
		end))
	end
	Menu.sectionCaps = {}
	Menu.lastSection = nil
	Menu.navOrder = 0

	-- 1–9 jump to the tabs in sidebar order while the menu is open (never while typing in a field)
	local DIGITS = { One = 1, Two = 2, Three = 3, Four = 4, Five = 5, Six = 6, Seven = 7, Eight = 8, Nine = 9 }
	UI.conn(UIS.InputBegan:Connect(function(input: InputObject)
		if not S.menuOpen or input.UserInputType ~= Enum.UserInputType.Keyboard or UIS:GetFocusedTextBox() then
			return
		end
		local n = DIGITS[input.KeyCode.Name]
		if not n then
			return
		end
		local items = {}
		for tabName, d in pairs(Menu.tabBtns) do
			if d.item and d.item.Parent and d.item.Visible then
				table.insert(items, { name = tabName, order = d.item.LayoutOrder })
			end
		end
		table.sort(items, function(a, b)
			return a.order < b.order
		end)
		if items[n] then
			Menu.showTab(items[n].name)
		end
	end))

	-- user card at the bottom of the sidebar, on the rail's acrylic
	local card = frame(side)
	card.Name = "UserCard"
	card.Size = UDim2.new(1, 0, 0, CARD_H)
	card.Position = UDim2.new(0, 0, 1, -CARD_H)
	card.ZIndex = 8
	card.Active = true
	corner(card, 12)
	local cardHair = frame(card, C.hairline)
	cardHair.Size = UDim2.new(1, 0, 0, 1)
	cardHair.ZIndex = 8
	local avPx = px(28)
	local avatar = Instance.new("ImageLabel")
	avatar.Size = UDim2.fromOffset(avPx, avPx)
	avatar.AnchorPoint = Vector2.new(0, 0.5)
	avatar.Position = UDim2.new(0, px(14), 0.5, 0)
	avatar.BackgroundColor3 = C.card
	avatar.Image = ("rbxthumb://type=AvatarHeadShot&id=%d&w=48&h=48"):format(LP.UserId)
	avatar.ZIndex = 9
	avatar.Parent = card
	corner(avatar, avPx // 2)
	do
		-- metal looks: a metal ring round the headshot
		local ring = stroke(avatar, C.accent, 0.55)
		if UI.metalEdge(ring) then
			ring.Thickness = 1.5
		end
	end
	local online = frame(avatar, C.ok)
	online.Size = UDim2.fromOffset(8, 8)
	online.AnchorPoint = Vector2.new(1, 1)
	online.Position = UDim2.new(1, 1, 1, 1)
	online.ZIndex = 10
	corner(online, 4)
	local onStroke = stroke(online, C.side, 0)
	onStroke.Thickness = 2
	local nameL = label(card, LP.DisplayName, UI.M.title, C.text, UI.F.medium)
	nameL.Size = UDim2.new(1, -px(60), 0, px(16))
	nameL.Position = UDim2.new(0, px(50), 0, px(11))
	nameL.TextTruncate = Enum.TextTruncate.AtEnd
	nameL.ZIndex = 9
	local execName = "roblox"
	pcall(function()
		local ie = envFn("identifyexecutor", "getexecutorname")
		if ie then
			execName = tostring((ie()))
		end
	end)
	local subL = label(card, opts.Subtitle or ("%s · v%s"):format(string.lower(execName), tostring(opts.Version or Library.Version)), UI.M.small, C.muted, UI.F.body)
	subL.Name = "SubLine"
	subL.Size = UDim2.new(1, -px(60), 0, px(14))
	subL.Position = UDim2.new(0, px(50), 0, px(28))
	subL.ZIndex = 9
	UI.tip(avatar, "@" .. LP.Name)
	Menu.applyGlass()
end

-- one nav item (and its section caption) for a tab; called in tab order
function Menu.addNav(name: string, section: string?, iconName: string?)
	local nav, px = Menu.nav, Menu.px
	if section and section ~= Menu.lastSection then
		Menu.navOrder += 1
		local cap = label(nav, string.lower(section), UI.M.tiny, C.muted, UI.F.body)
		cap.Size = UDim2.new(1, 0, 0, px(26))
		cap.TextYAlignment = Enum.TextYAlignment.Bottom
		cap.LayoutOrder = Menu.navOrder
		cap.ZIndex = 5
		padding(cap, 0, 0, 5, 10)
		Menu.sectionCaps[section] = cap
		Menu.lastSection = section
	end
	Menu.navOrder += 1
	local item = button(nav, "", 10, C.text, Color3.new(1, 1, 1))
	item.Name = "Nav_" .. name
	item.BackgroundTransparency = 1
	item.Size = UDim2.new(1, 0, 0, px(30))
	item.LayoutOrder = Menu.navOrder
	item.ZIndex = 5
	corner(item, 6)
	local ic = icon(item, iconName or name, px(17))
	ic.AnchorPoint = Vector2.new(0, 0.5)
	ic.Position = UDim2.new(0, px(11), 0.5, 0)
	ic.ZIndex = 7
	local lbl = label(item, string.lower(name), UI.M.title, C.dim, UI.F.body)
	lbl.Size = UDim2.new(1, -px(46), 1, 0)
	lbl.Position = UDim2.new(0, px(38), 0, 0)
	lbl.ZIndex = 7
	local hovered = false
	-- the pill marks the active page; colours and the hover wash fade
	local function paint(on: boolean, animate: boolean?)
		local icCol = if on and UI.metal then UI.metal.ink elseif on then C.accent elseif hovered then C.dim else C.muted
		local txtCol = if on and UI.metal then UI.metal.ink elseif on or hovered then C.text else C.dim
		local bgTr = if hovered and not on then 0.96 else 1
		UI.tintIcon(ic, icCol, animate)
		if animate then
			tween(lbl, TW_HOVER, { TextColor3 = txtCol })
			tween(item, TW_HOVER, { BackgroundTransparency = bgTr })
		else
			lbl.TextColor3 = txtCol
			item.BackgroundTransparency = bgTr
		end
		UI.setFont(lbl, if on then UI.F.medium else UI.F.body)
	end
	item.MouseEnter:Connect(function()
		hovered = true
		paint(Menu.activeTab == name, true)
	end)
	item.MouseLeave:Connect(function()
		hovered = false
		paint(Menu.activeTab == name, true)
	end)
	item.MouseButton1Click:Connect(function()
		Menu.showTab(name)
	end)
	Menu.tabBtns[name] = { item = item, paint = paint, glyph = ic, cap = lbl }
	paint(false)
end

-- drag by the top bar or the logo; window always stays on screen
function Menu.installDrag()
	local gui, host = Menu.gui, Menu.host
	local top = Menu.root:FindFirstChild("TopBar")
	local logo = Menu.root:FindFirstChild("Logo", true)
	local dragging, dragStart, startPos = false, Vector2.zero, UDim2.new()
	function Menu.clampToScreen()
		local vp = gui.AbsoluteSize
		if vp.X < 100 or vp.Y < 100 then
			return
		end
		local half = host.AbsoluteSize * 0.5
		local center = host.AbsolutePosition + half
		-- with IgnoreGuiInset the reported AbsolutePosition is the screen position minus the inset
		local inset = if gui.IgnoreGuiInset then GuiService:GetGuiInset().Y else 0
		local cx = math.clamp(center.X, half.X, math.max(half.X, vp.X - half.X))
		local cy = math.clamp(center.Y, half.Y - inset, math.max(half.Y - inset, vp.Y - half.Y - inset))
		-- whole pixels: a centred window on an odd viewport sat on a half pixel and every hairline blurred
		local nx = math.floor(cx + 0.5)
		local ny = math.floor(cy + inset + 0.5)
		if host.Position.X.Scale ~= 0 or host.Position.Y.Scale ~= 0 or math.abs(cx - center.X) > 0.01 or math.abs(cy - center.Y) > 0.01 then
			host.Position = UDim2.fromOffset(nx, ny)
		end
		Menu.hostBase = host.Position
	end
	for _, handle in ipairs({ top, logo }) do
		if handle then
			handle.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					dragStart = i.Position
					startPos = host.Position
				end
			end)
			handle.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
					Menu.applyDrag()
					Menu.clampToScreen()
				end
			end)
		end
	end
	-- a mouse reports many moves per frame: each move only records where the window should go and
	-- the heartbeat moves it once per frame
	UI.conn(UIS.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			local d = i.Position - dragStart
			Menu.dragTo = UDim2.new(startPos.X.Scale, startPos.X.Offset + math.floor(d.X + 0.5), startPos.Y.Scale, startPos.Y.Offset + math.floor(d.Y + 0.5))
		end
	end))
	function Menu.applyDrag()
		local to = Menu.dragTo
		if to then
			Menu.dragTo = nil
			if host.Position ~= to then
				host.Position = to
			end
			Menu.hostBase = to
		end
	end
	UI.conn(gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		task.defer(Menu.clampToScreen)
	end))
end

-------------------------------------------------------------------------------
-- HUD: toasts (right edge) and the watermark (top left)
-------------------------------------------------------------------------------
local HUD: any = {}
Library.Hud = HUD
function HUD.card(parent: GuiObject, name: string): Frame
	local f = frame(parent, C.side)
	f.Name = name
	f.BackgroundTransparency = 0.06
	f.Active = true
	corner(f, if UI.metal then 8 else 6)
	local s = stroke(f, C.edge, 0.15)
	UI.metalEdge(s)
	return f
end
function HUD.destroy()
	if HUD.conn then
		pcall(HUD.conn.Disconnect, HUD.conn)
		HUD.conn = nil
	end
	if HUD.gui then
		pcall(HUD.gui.Destroy, HUD.gui)
	end
	HUD.gui, HUD.toasts, HUD.wm, HUD.wmStats, HUD.pingBars = nil, nil, nil, nil, nil
end
function HUD.build(opts: any)
	HUD.destroy()
	local gui = Instance.new("ScreenGui")
	gui.Name = (opts and opts.HudName) or "CocaineUIHUD"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 999
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Enabled = true
	if not parentGui(gui) then
		return
	end
	HUD.gui = gui
	HUD.title = (opts and opts.Title) or HUD.title or "c0caine"
	local inset = GuiService:GetGuiInset().Y
	local topY = math.max(inset, 36) + 10 -- never under the Roblox topbar

	-- watermark: face, name, version | fps, ping, signal, clock
	local wm = HUD.card(gui, "Watermark")
	wm.AutomaticSize = Enum.AutomaticSize.X
	wm.AnchorPoint = Vector2.new(0, 0)
	wm.Size = UDim2.fromOffset(0, 28)
	wm.Position = UDim2.fromOffset(14, topY)
	wm.Visible = cfg.hud ~= false
	padding(wm, 0, 11, 0, 9)
	local wl = vlist(wm, 7, true)
	wl.VerticalAlignment = Enum.VerticalAlignment.Center
	local gemBox = frame(wm)
	gemBox.Size = UDim2.fromOffset(14, 14)
	gemBox.LayoutOrder = 1
	UI.logoMark(gemBox, 14, 90)
	local title = HUD.title
	local zeroAt = string.find(title, "0", 1, true)
	local rich = if zeroAt then title:sub(1, zeroAt - 1) .. ('<font color="#%s">0</font>'):format(C.accent:ToHex()) .. title:sub(zeroAt + 1) else title
	local brand = label(wm, rich, 13, C.text, UI.HUD_BOLD)
	brand.RichText = true
	if UI.metal then
		-- metal looks: the lit-metal wordmark, like the menu's (static here)
		brand.Text = title
		brand.TextColor3 = Color3.new(1, 1, 1)
		local bg = gradient(brand, UI.metal.hi, UI.metal.lite, 90)
		bg.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, UI.metal.hi),
			ColorSequenceKeypoint.new(0.45, UI.metal.lite),
			ColorSequenceKeypoint.new(0.6, UI.metal.hi),
			ColorSequenceKeypoint.new(1, UI.metal.lite),
		})
	end
	brand.Size = UDim2.new(0, UI.gw(title, 13, true) + 1, 1, 0)
	brand.LayoutOrder = 2
	local verTxt = "v" .. tostring((opts and opts.Version) or HUD.version or Library.Version)
	HUD.version = verTxt:sub(2)
	local ver = label(wm, verTxt, 12, C.muted, UI.HUD_FONT)
	ver.Size = UDim2.new(0, UI.gw(verTxt, 12) + 1, 1, 0)
	ver.LayoutOrder = 4
	local sep = frame(wm, C.edge)
	sep.Size = UDim2.fromOffset(1, 12)
	sep.LayoutOrder = 5
	HUD.wm = wm
	HUD.wmStats = label(wm, "", 12, C.dim, UI.HUD_FONT)
	HUD.wmStats.Size = UDim2.new(0, 10, 1, 0)
	HUD.wmStats.RichText = true
	HUD.wmStats.LayoutOrder = 6
	-- signal: four rising bars coloured by the connection's quality
	local bars = frame(wm)
	bars.Name = "PingBars"
	bars.Size = UDim2.fromOffset(4 * 3 + 3 * 2, 12)
	bars.LayoutOrder = 7
	HUD.pingBars = {}
	for i = 1, 4 do
		local b = frame(bars, C.edge)
		local h = 3 + i * 2
		b.Size = UDim2.fromOffset(3, h)
		b.AnchorPoint = Vector2.new(0, 1)
		b.Position = UDim2.new(0, (i - 1) * 5, 1, 0)
		corner(b, 1)
		HUD.pingBars[i] = b
	end

	-- messages: right edge, raised above the game's HUD
	local toasts = frame(gui)
	toasts.Name = "Toasts"
	toasts.AnchorPoint = Vector2.new(1, 1)
	toasts.AutomaticSize = Enum.AutomaticSize.Y
	toasts.Size = UDim2.new(0, 300, 0, 20)
	toasts.Position = UDim2.new(1, -14, 0.72, 0)
	toasts.Active = true
	local tl = vlist(toasts, 6)
	tl.VerticalAlignment = Enum.VerticalAlignment.Bottom
	tl.HorizontalAlignment = Enum.HorizontalAlignment.Right
	HUD.toasts = toasts

	-- fps / ping / clock, twice a second
	local acc, frames, fps = 0, 0, 60
	HUD.conn = RunService.Heartbeat:Connect(function(dt)
		acc += dt
		frames += 1
		if acc < 0.5 then
			return
		end
		fps = math.floor(frames / acc + 0.5)
		acc, frames = 0, 0
		local ping = 0
		pcall(function()
			ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)
		end)
		local function hex(c: Color3): string
			return c:ToHex()
		end
		local function stat(num: any, unit: string): string
			return ('<font color="#%s">%s</font><font color="#%s"> %s</font>'):format(hex(C.text), tostring(num), hex(C.muted), unit)
		end
		if HUD.wmStats then
			HUD.wmStats.Text = stat(fps, "fps") .. "   " .. stat(ping, "ms") .. "   " .. ('<font color="#%s">%s</font>'):format(hex(C.text), os.date("%H:%M"))
			HUD.wmStats.AutomaticSize = Enum.AutomaticSize.X
			HUD.wmStats.Size = UDim2.new(0, 0, 1, 0)
		end
		local lit = if ping < 60 then 4 elseif ping < 120 then 3 elseif ping < 200 then 2 else 1
		local col = if lit >= 3 then C.ok elseif lit == 2 then C.warn else C.danger
		for i, b in ipairs(HUD.pingBars or {}) do
			b.BackgroundColor3 = if i <= lit then col else C.edge
		end
	end)
end
function HUD.retheme()
	HUD.build({ Title = HUD.title, Version = HUD.version })
end
function HUD.setVisible(on: boolean)
	if HUD.wm then
		HUD.wm.Visible = on
	end
end

local toastOrder = 0
-- Library:Notify(text, duration?, kind?) — kind = "info" | "ok" | "warn" | "error"
function Library:Notify(text: string, duration: number?, kind: string?)
	local toasts = HUD.toasts
	if not toasts then
		return
	end
	-- confirmations follow "Pop-up messages"; warnings and errors always show
	if cfg.toasts == false and kind ~= "warn" and kind ~= "error" then
		return
	end
	local KIND = { info = C.accent, ok = C.ok, warn = C.warn, error = C.danger, rage = C.accent }
	toastOrder += 1
	local tint = KIND[kind or "info"] or C.accent
	local alert = kind == "warn" or kind == "error"
	local t = frame(toasts, C.side)
	t.Name = "Toast"
	t.AutomaticSize = Enum.AutomaticSize.XY
	t.Size = UDim2.fromOffset(0, 0)
	t.BackgroundTransparency = 0.06
	t.LayoutOrder = toastOrder
	corner(t, if UI.metal then 8 else 6)
	-- metal looks: the metal edge (warnings keep a plain edge so their icon carries the colour)
	local te = stroke(t, C.edge, 0.15)
	if not alert then
		UI.metalEdge(te)
	end
	padding(t, 9, 12, 9, if alert then 32 else 12)
	if alert then
		local glyph = icon(t, "warn", 14)
		glyph.AnchorPoint = Vector2.new(0, 0)
		glyph.Position = UDim2.fromOffset(-21, 0)
		recolourIcon(glyph, tint)
	end
	local body = label(t, tostring(text), 13, if alert then C.text else C.dim:Lerp(C.text, 0.5), UI.HUD_FONT)
	body.AutomaticSize = Enum.AutomaticSize.XY
	body.Size = UDim2.fromOffset(0, 0)
	body.TextWrapped = true
	body.LineHeight = 1.1
	if not UI.snapWrapped(body, 280) then
		local cap = Instance.new("UISizeConstraint")
		cap.MaxSize = Vector2.new(280, math.huge)
		cap.Parent = body
	end
	UI.fadeIn(t, TW_TOAST_IN)
	task.delay(duration or 3, function()
		if not t.Parent then
			return
		end
		UI.fadeOut(t, TW_TOAST_OUT, function()
			t:Destroy()
		end)
	end)
	local kids = {}
	for _, k in ipairs(toasts:GetChildren()) do
		if k:IsA("Frame") then
			table.insert(kids, k)
		end
	end
	if #kids > 5 then
		table.sort(kids, function(a, b)
			return a.LayoutOrder < b.LayoutOrder
		end)
		kids[1]:Destroy()
	end
end

-------------------------------------------------------------------------------
-- config files
-------------------------------------------------------------------------------
local function cfgPath(name: string): string
	return Library.ConfigFolder .. "/" .. name .. ".json"
end
local function jsonSafe(v: any, depth: number?): any
	local d = depth or 0
	if d > 6 then
		return nil
	end
	local t = type(v)
	if t == "number" or t == "string" or t == "boolean" then
		return v
	elseif t == "table" then
		local out = {}
		for k, x in pairs(v) do
			local sk = if type(k) == "number" then k else tostring(k)
			local sv = jsonSafe(x, d + 1)
			if sv ~= nil then
				out[sk] = sv
			end
		end
		return out
	end
	return nil
end
function Library:Snapshot(): string
	local ok, s = pcall(function()
		return HttpService:JSONEncode(jsonSafe(Library.Flags))
	end)
	return if ok then s else ""
end
function Library:IsDirty(): boolean
	if not Library.ActiveConfig or Library.ActiveConfig == "" or not Library._savedSnap then
		return false
	end
	local now = os.clock()
	if now - (Library._dirtyAt or 0) > 0.5 then
		Library._dirtyAt = now
		Library._dirty = Library:Snapshot() ~= Library._savedSnap
	end
	return Library._dirty == true
end
function Library:ListConfigs(): { string }
	local out = {}
	local listfiles = envFn("listfiles")
	if type(listfiles) ~= "function" then
		return out
	end
	pcall(function()
		for _, p in ipairs(listfiles(Library.ConfigFolder)) do
			local n = tostring(p):match("([^/\\]+)%.json$")
			if n then
				table.insert(out, n)
			end
		end
	end)
	table.sort(out)
	return out
end
function Library:SaveConfig(name: string): (boolean, string?)
	if not EXEC.caps.files then
		return false, "This executor can't write files"
	end
	local ok, err = pcall(function()
		for _, dir in ipairs({ Library.ConfigFolder }) do
			if EXEC.isfolder and not EXEC.isfolder(dir) and EXEC.makefolder then
				EXEC.makefolder(dir)
			end
		end
		EXEC.writefile(cfgPath(name), HttpService:JSONEncode(jsonSafe(Library.Flags)))
	end)
	if not ok then
		return false, tostring(err)
	end
	Library.ActiveConfig = name
	Library._savedSnap = Library:Snapshot()
	Library._dirty = false
	return true
end
function Library:LoadConfig(name: string): (boolean, string?)
	if not EXEC.caps.files then
		return false, "This executor can't read files"
	end
	local data
	local ok, err = pcall(function()
		if not EXEC.isfile(cfgPath(name)) then
			error("no config called " .. name)
		end
		data = HttpService:JSONDecode(EXEC.readfile(cfgPath(name)))
	end)
	if not ok or type(data) ~= "table" then
		return false, tostring(err or "bad config file")
	end
	local themeBefore = cfg.theme
	for k, v in pairs(data) do
		if k == "binds" and type(v) == "table" then
			table.clear(Library.Binds)
			for fk, b in pairs(v) do
				Library.Binds[fk] = b
			end
		else
			Library.Flags[k] = v
		end
	end
	Library.ActiveConfig = name
	Library._savedSnap = Library:Snapshot()
	Library._dirty = false
	for flag, fn in pairs(Library.Callbacks) do
		if data[flag] ~= nil then
			pcall(fn, Library.Flags[flag])
		end
	end
	for _, tag in pairs(UI.bindTags) do
		pcall(tag)
	end
	if cfg.theme ~= themeBefore then
		Library:SetTheme(cfg.theme)
	elseif Library._window and Library._window._built then
		Library._window:_scheduleRebuild() -- controls read their values when they are built
	end
	return true
end
Library.Callbacks = {}

-------------------------------------------------------------------------------
-- public API: window → tabs → groups → controls
-------------------------------------------------------------------------------
local function toColorTable(c: any): any
	if typeof(c) == "Color3" then
		return { math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5) }
	end
	return c
end
local TINTS = { accent = "accent", danger = "danger", warn = "warn", ok = "ok" }
local function tintOf(t: any): Color3?
	if t == nil then
		return nil
	end
	if typeof(t) == "Color3" then
		return t
	end
	if type(t) == "string" and C[t] then
		return C[t]
	end
	return nil
end
local function lowerKeys(o: any): any
	if type(o) ~= "table" then
		return {}
	end
	local out = {}
	for k, v in pairs(o) do
		local lk = if type(k) == "string" then (k:sub(1, 1):lower() .. k:sub(2)) else k
		out[lk] = v
	end
	return out
end

-- A "builder" is the Add* surface of a group. Recording builders remember the calls (so the whole
-- window can be rebuilt on a theme / size change); live builders call straight into a built UI.group.
local Builder = {}
Builder.__index = Builder
local function newBuilder(live: any, ops: any): any
	return setmetatable({ _live = live, _ops = ops }, Builder)
end
function Builder:_emit(fn: string, args: { any })
	if self._live then
		local g = self._live
		return g[fn](g, table.unpack(args, 1, args.n))
	end
	table.insert(self._ops, { fn = fn, args = args })
end
local function pack(...)
	return table.pack(...)
end
local function handle(flag: string, kind: string): any
	local h: any = { Flag = flag }
	function h:Get()
		local v = cfg[flag]
		if kind == "color" then
			return rgb(v)
		end
		return v
	end
	function h:Set(v: any)
		if kind == "color" then
			v = toColorTable(v)
		end
		cfg[flag] = v
		local cb = Library.Callbacks[flag]
		if cb then
			pcall(cb, if kind == "color" then rgb(v) else v)
		end
		saveConfig()
	end
	function h:GetBind()
		return Library.Binds[flag]
	end
	function h:SetBind(key: string?, mode: string?)
		Library.Binds[flag] = { key = key or "", mode = mode or "Toggle" }
		local tag = UI.bindTags[flag]
		if tag then
			tag()
		end
	end
	Library.Options[flag] = h
	return h
end
local function setDefault(flag: string, default: any)
	if cfg[flag] == nil then
		cfg[flag] = default
	end
end
local function hookCallback(flag: string, o: any, kind: string?)
	if o.onChange then
		local user = o.onChange
		if kind == "color" then
			Library.Callbacks[flag] = function(v)
				user(if typeof(v) == "Color3" then v else rgb(v))
			end
		else
			Library.Callbacks[flag] = user
		end
	end
end

function Builder:AddToggle(text: string, flag: string, opts: any?)
	local o = lowerKeys(opts)
	setDefault(flag, o.default == true)
	hookCallback(flag, o)
	if o.bind == nil then
		o.bind = true
	end
	o.cfgKey = flag
	local sub = o.sub
	if type(sub) == "function" then
		o.sub = function(g)
			local b = newBuilder(g, nil)
			sub(b)
		end
	end
	local needs = o.needs
	if type(needs) == "table" then
		local function norm(n: any): any
			local nn = lowerKeys(n)
			return nn
		end
		if needs.Flag or needs.flag or needs.Fn or needs.fn then
			o.needs = norm(needs)
		else
			local list = {}
			for _, n in ipairs(needs) do
				table.insert(list, norm(n))
			end
			o.needs = list
		end
	end
	self:_emit("toggle", pack(text, flag, o))
	return handle(flag, "toggle")
end
function Builder:AddSlider(text: string, flag: string, min: number, max: number, step: number?, opts: any?)
	local o = lowerKeys(opts)
	setDefault(flag, if o.default ~= nil then o.default else min)
	hookCallback(flag, o)
	self:_emit("slider", pack(text, flag, min, max, step, o))
	return handle(flag, "slider")
end
function Builder:AddDropdown(text: string, flag: string, options: { any }, opts: any?)
	local o = lowerKeys(opts)
	setDefault(flag, if o.default ~= nil then o.default else options[1])
	hookCallback(flag, o)
	self:_emit("cycle", pack(text, flag, options, o))
	return handle(flag, "dropdown")
end
function Builder:AddMultiDropdown(text: string, flag: string, options: { string }, opts: any?)
	local o = lowerKeys(opts)
	setDefault(flag, if type(o.default) == "table" then o.default else {})
	hookCallback(flag, o)
	self:_emit("multiselect", pack(text, flag, options, o))
	return handle(flag, "multi")
end
function Builder:AddColorPicker(text: string, flag: string, opts: any?)
	local o = lowerKeys(opts)
	setDefault(flag, toColorTable(o.default or C.accent))
	if typeof(cfg[flag]) == "Color3" then
		cfg[flag] = toColorTable(cfg[flag])
	end
	hookCallback(flag, o, "color")
	local user = o.onChange
	if user then
		o.onChange = function(c3)
			user(c3)
		end
	end
	self:_emit("color", pack(text, flag, o))
	return handle(flag, "color")
end
function Builder:AddKeybind(text: string, flag: string, opts: any?)
	local o = lowerKeys(opts)
	setDefault(flag, o.default or "")
	hookCallback(flag, o)
	self:_emit("keybind", pack(text, flag, o))
	return handle(flag, "keybind")
end
function Builder:AddTextbox(text: string, flag: string, opts: any?)
	local o = lowerKeys(opts)
	setDefault(flag, o.default or "")
	hookCallback(flag, o)
	self:_emit("textbox", pack(text, flag, o))
	return handle(flag, "textbox")
end
function Builder:AddButton(text: string, callback: () -> (), opts: any?)
	local o = lowerKeys(opts)
	self:_emit("button", pack(text, callback, tintOf(o.tint), o))
end
-- items = { { "label", fn, tint? }, ... }
function Builder:AddButtonRow(text: string, items: { any }, opts: any?)
	local list = {}
	for i, it in ipairs(items) do
		list[i] = { it[1], it[2], tintOf(it[3]) }
	end
	self:_emit("buttonRow", pack(text, list, lowerKeys(opts)))
end
function Builder:AddLabel(text: string, opts: any?)
	self:_emit("note", pack(text, lowerKeys(opts)))
end
-- getter runs while the menu is open: AddInfo("Ping", function() return "42 ms" end)
function Builder:AddInfo(text: string, getter: () -> any, opts: any?)
	self:_emit("info", pack(text, getter, lowerKeys(opts)))
end
-- list: { Height?, Search?, Items = () -> { { id, label, sub?, color?, dim? } }, Selected = () -> id?, OnSelect = (id) -> () }
function Builder:AddList(text: string, opts: any?)
	self:_emit("list", pack(text, lowerKeys(opts)))
end

local Tab = {}
Tab.__index = Tab
function Tab:AddGroup(title: string, opts: any?)
	local o = lowerKeys(opts)
	local spec = { title = title, opts = o, sub = o.sub or self._subs[1], side = o.side, ops = {} }
	table.insert(self._groups, spec)
	self._window._dirtyTabs = true
	return newBuilder(nil, spec.ops)
end

local Window = {}
Window.__index = Window
function Window:AddTab(name: string, opts: any?)
	local o = lowerKeys(opts)
	local subs = o.subs
	if type(subs) ~= "table" or #subs == 0 then
		subs = { "General" }
	end
	local tab = setmetatable({ _window = self, name = name, icon = o.icon, section = o.section, _subs = subs, _groups = {} }, Tab)
	table.insert(self._tabs, tab)
	self._dirtyTabs = true
	if self._built then
		self:_scheduleRebuild()
	end
	return tab
end
function Window:Open()
	Menu.set(true)
end
function Window:Close()
	Menu.set(false)
end
function Window:Toggle()
	Menu.toggle()
end
function Window:SelectTab(name: string)
	Menu.showTab(name)
end
function Window:IsOpen(): boolean
	return S.menuOpen == true
end
function Window:SetTitle(t: string)
	self._opts.Title = t
	self:_scheduleRebuild()
end

-- replay the recorded tree into a fresh gui
function Window:_build()
	local opts = self._opts
	local wasOpen = S.menuOpen == true
	local active = Menu.activeTab
	local subsActive = {}
	for n, st in pairs(Menu.subs) do
		subsActive[n] = st.active
	end
	Menu.destroy()
	UI.applyTheme()
	Menu.activeTab = ""
	Menu.buildChrome(opts)
	table.clear(Menu.tabOrder)
	local sideCount: { [string]: number } = {}
	for _, tab in ipairs(self._tabs) do
		table.insert(Menu.tabOrder, tab.name)
	end
	for _, tab in ipairs(self._tabs) do
		Menu.addNav(tab.name, tab.section, tab.icon)
		local st = Menu.addTab(tab.name, tab._subs)
		for _, gs in ipairs(tab._groups) do
			local colSet = st[gs.sub] or st[tab._subs[1]]
			local key = tab.name .. "/" .. tostring(gs.sub)
			sideCount[key] = (sideCount[key] or 0) + 1
			local side = gs.side
			if side ~= "L" and side ~= "R" and side ~= "Left" and side ~= "Right" then
				side = if sideCount[key] % 2 == 1 then "L" else "R"
			end
			if side == "Left" then
				side = "L"
			elseif side == "Right" then
				side = "R"
			end
			local g = UI.group(colSet[side], gs.title, gs.opts)
			for _, op in ipairs(gs.ops) do
				local ok, err = pcall(function()
					g[op.fn](g, table.unpack(op.args, 1, op.args.n))
				end)
				if not ok then
					reportError("control " .. tostring(op.args[1]), err)
				end
			end
		end
	end
	local first = if Menu.pages[active] then active else (self._tabs[1] and self._tabs[1].name)
	if first then
		Menu.showTab(first)
	end
	for n, sub in pairs(subsActive) do
		local st = Menu.subs[n]
		if st and st.btns[sub] then
			Menu.showSub(n, sub)
		end
	end
	UI.refilter()
	Menu.balanceColumns()
	Menu.installDrag()
	self._built = true
	if wasOpen then
		Menu.set(true)
	end
end
function Window:_scheduleRebuild()
	if self._rebuildQueued then
		return
	end
	self._rebuildQueued = true
	task.defer(function()
		self._rebuildQueued = false
		if S.alive and not Library.Unloaded then
			local ok, err = pcall(self._build, self)
			if not ok then
				reportError("menu build", err)
			end
			HUD.retheme()
		end
	end)
end
-- builds the window now (otherwise it builds right after the current script yields)
function Window:Init()
	if self._rebuildQueued or not self._built then
		self._rebuildQueued = false
		self:_build()
	end
end

-- the built-in "Interface" page: Simple / Advanced, theme, glow, menu size, menu key, pop-ups, watermark
function Window:_addInterfaceTab()
	local name = self._opts.SettingsTabName or "Interface"
	local tab = self:AddTab(name, { Icon = "Interface", Section = "Other", Subs = { "Menu" } })
	local look = tab:AddGroup("Look", { Sub = "Menu" })
	look:AddDropdown("Mode", "uiMode", { "Simple", "Advanced" }, {
		Default = "Advanced",
		Desc = "Simple hides every option flagged advanced. Nothing is turned off: a hidden option keeps working exactly as set.",
		OnChange = function()
			UI.refilter()
		end,
	})
	look:AddDropdown("Theme", "theme", UI.THEME_ORDER, {
		Default = "Obsidian",
		OnChange = function(t)
			Library:SetTheme(t)
		end,
	})
	local function recolour()
		if cfg.theme == "Custom" then
			Library:SetTheme("Custom")
		end
	end
	look:AddColorPicker("Accent", "colAccent", { Desc = "Used by the Custom theme.", OnClose = recolour })
	look:AddColorPicker("Accent 2", "colAccent2", { Desc = "The deeper accent of the Custom theme.", OnClose = recolour })
	look:AddSlider("Glow", "uiGlow", 0, 100, 1, {
		Default = 45,
		Unit = "%",
		OnChange = function()
			UI.refreshGlows(Menu.gui)
		end,
	})
	look:AddSlider("Rail glass", "railGlass", 0, 40, 1, {
		Default = 14,
		Unit = "%",
		Advanced = true,
		Desc = "How much the game shows through the tab list. Metal themes keep a solid rail.",
		OnChange = function()
			Menu.applyGlass()
		end,
	})
	look:AddDropdown("Menu size", "menuScale", { 0.9, 1, 1.1, 1.25 }, {
		Default = 1,
		Fmt = function(v)
			return ("%d%%"):format(math.floor(v * 100 + 0.5))
		end,
		OnChange = function()
			self:_scheduleRebuild()
		end,
	})
	local misc = tab:AddGroup("Behaviour", { Sub = "Menu" })
	misc:AddKeybind("Menu key", "menuKey", { Default = "RightShift" })
	misc:AddToggle("Pop-up messages", "toasts", { Default = true, Bind = false, Desc = "Confirmations. Warnings and errors always show." })
	misc:AddToggle("Watermark", "hud", {
		Default = true,
		Bind = false,
		OnChange = function(v)
			HUD.setVisible(v)
		end,
	})
	misc:AddButton("Unload UI", function()
		Library:Unload()
	end, "danger", { Desc = "Removes the menu and everything it created." })
end

-------------------------------------------------------------------------------
-- Library:CreateWindow / SetTheme / Unload
-------------------------------------------------------------------------------
function Library:CreateWindow(opts: any?)
	opts = opts or {}
	if Library._window then
		return Library._window
	end
	Library.Version = opts.Version or Library.Version
	Library.ConfigFolder = opts.ConfigFolder or Library.ConfigFolder
	Library.AutoSave = opts.AutoSave
	if opts.Theme then
		cfg.theme = opts.Theme
	end
	if opts.Scale then
		cfg.menuScale = opts.Scale
	end
	if opts.MenuKey then
		cfg.menuKey = opts.MenuKey
	end
	local win: any = setmetatable({ _opts = opts, _tabs = {}, _built = false }, Window)
	Library._window = win
	Library.Rebuild = function()
		win:_scheduleRebuild()
	end
	UI.loadAssets()
	UI.applyTheme()
	HUD.title = opts.Title or "c0caine"
	HUD.version = Library.Version
	HUD.build({ Title = HUD.title, Version = HUD.version })
	-- the window builds once the script that defined it has finished
	task.defer(function()
		if not Library.Unloaded then
			if opts.SettingsTab ~= false then
				win:_addInterfaceTab()
			end
			win._rebuildQueued = false
			local ok, err = pcall(win._build, win)
			if not ok then
				reportError("menu build", err)
			end
			if opts.AutoShow ~= false then
				Menu.set(true)
			end
		end
	end)
	return win
end
function Library:SetTheme(name: string)
	if name == nil then
		return
	end
	cfg.theme = name
	UI.applyTheme()
	if Library._window and Library._window._built then
		Library._window:_scheduleRebuild()
	end
end
function Library:Get(flag: string): any
	return cfg[flag]
end
function Library:Set(flag: string, value: any)
	local h = Library.Options[flag]
	if h then
		h:Set(value)
	else
		cfg[flag] = value
	end
end
function Library:Toggle()
	Menu.toggle()
end
function Library:Unload()
	if Library.Unloaded then
		return
	end
	Library.Unloaded = true
	S.alive = false
	for _, c in ipairs(Library._conns) do
		pcall(c.Disconnect, c)
	end
	table.clear(Library._conns)
	Menu.destroy()
	HUD.destroy()
	if Library.OnUnload then
		pcall(Library.OnUnload)
	end
	pcall(function()
		local gg = envFn("getgenv")
		if gg and type(gg) == "function" then
			gg().CocaineUILibrary = nil
		end
	end)
end

-------------------------------------------------------------------------------
-- input: key capture (rebinding), menu key, bind engine (Toggle / Hold / Always / Never), per-frame sync
-------------------------------------------------------------------------------
Library._conns = {}
local function fireFlag(flag: string, value: any)
	if cfg[flag] == value then
		return
	end
	cfg[flag] = value
	local cb = Library.Callbacks[flag]
	if cb then
		pcall(cb, value)
	end
	saveConfig()
end
table.insert(Library._conns, UIS.InputBegan:Connect(function(input: InputObject, processed: boolean)
	local name = inputName(input)
	-- the key a rebind popup / keybind row is waiting for
	if Input._capture and name then
		local cb = Input._capture
		Input._capture = nil
		if input.UserInputType == Enum.UserInputType.Keyboard and (name == "Escape" or name == "Backspace") then
			pcall(cb, "")
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			pcall(cb, false) -- a click elsewhere cancels the rebind
		else
			pcall(cb, name)
		end
		return
	end
	if not name or UIS:GetFocusedTextBox() then
		return
	end
	if name == cfg.menuKey then
		Menu.toggle()
		return
	end
	if processed and input.UserInputType == Enum.UserInputType.Keyboard then
		return
	end
	for flag, b in pairs(Library.Binds) do
		if type(b) == "table" and b.key == name and b.key ~= "" then
			local mode = b.mode or "Toggle"
			if mode == "Toggle" then
				fireFlag(flag, not cfg[flag])
			elseif mode == "Hold" then
				Input.keyDown[name] = true
				fireFlag(flag, true)
			end
		end
	end
end))
table.insert(Library._conns, UIS.InputEnded:Connect(function(input: InputObject)
	local name = inputName(input)
	if not name or not Input.keyDown[name] then
		return
	end
	Input.keyDown[name] = nil
	for flag, b in pairs(Library.Binds) do
		if type(b) == "table" and b.key == name and b.mode == "Hold" then
			fireFlag(flag, false)
		end
	end
end))
do
	local lazyT = 0
	table.insert(Library._conns, RunService.Heartbeat:Connect(function(dt: number)
		if Menu.dragTo and Menu.applyDrag then
			Menu.applyDrag()
		end
		-- Always / Never keep the switch pinned
		for flag, b in pairs(Library.Binds) do
			if type(b) == "table" then
				if b.mode == "Always" then
					fireFlag(flag, true)
				elseif b.mode == "Never" then
					fireFlag(flag, false)
				end
			end
		end
		if S.menuOpen then
			lazyT += dt
			local doLazy = lazyT > 0.25
			if doLazy then
				lazyT = 0
			end
			for _, fn in ipairs(UI.sync) do
				if doLazy or not UI.lazySync[fn] then
					local ok = pcall(fn)
					if not ok then
						-- a dead control must not stop the others
					end
				end
			end
		end
	end))
end

Library.UI = UI
Library.Theme = C
Library.Menu = Menu
Library.Input = Input

local okG, gg = pcall(function()
	return envFn("getgenv")
end)
if okG and type(gg) == "function" then
	pcall(function()
		gg().CocaineUILibrary = Library
	end)
end

return Library
