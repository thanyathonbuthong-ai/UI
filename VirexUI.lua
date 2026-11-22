--[[
	VirexUI - a Roblox UI library extracted from the Virex / Vyre loader (v2.8.1).
	One file, no dependencies. See Example.lua.

	  local VirexUI = loadstring(readfile("VirexUI.lua"))()
	  local Window = VirexUI:CreateWindow({ Title = "MY HUB", Footer = "My Hub" })
	  local Tab = Window:AddTab({ Title = "Main", Desc = "The main page", Icon = "grid" })
	  Tab:AddToggle({ Title = "Auto farm", Callback = function(on) print(on) end })
]]



local CONFIG = {
	Version = "2.8.1",
	Name = "VirexUI",              -- the name used in messages, the report and the names of the screens
	Title = "VYRE / LOADER",       -- the name in the title bar at the top of the window
	FooterName = "Vyre / Nexus",   -- the footer at the bottom of the window reads "<FooterName> - <tab name>"
	Registry = "__VirexUI",     -- executor-global key of the running hub (builds before 2.8.0 used __VirexHub: it is still set and read)
	GuiName = "VirexUI",
	SplashName = "VirexUISplash",
	Folder = "VirexUI",           -- the executor folder keeps its old name so saved settings, backgrounds and cache are still found
	ConfigFile = "VirexUI/config.json",
	BackgroundFolder = "VirexUI/backgrounds",
	CacheFolder = "VirexUI/cache",
	FontFolder = "VirexUI/fonts",
	SaeFile = "VirexHub/steal-an-egg.json",
	SaeSweepFlag = "VirexHub/steal-an-egg-sweep.flag",
	LegacyGuis = { "VirexStyleHub", "VirexHub", "VirexHubSplash" }, -- screens of earlier builds: removed at start
	LegacyFavorites = "Favorites.json", -- read once (never modified) to import old avatar favourites
	LegacyScriptFavorites = "VyreHub_Favorites.json", -- read once (never modified) to import script favorites from Vyre Hub
	Icons = {},                -- real Lucide icons: { Source = url | false, Map = { gear = "rbxassetid://..." }, Resolver = function(lucideName) end, Timeout = 8 }
	SearchSuggestions = {},    -- the chips under the jump search (VirexUI fills them from the card titles)
	ToggleKey = "RightShift",           -- keyboard / mouse users only

	Splash = {
		-- visible text (the brand is VYRE everywhere you can see it)
		Brand = "VYRE",                              -- title: one letter per label, slammed down one by one
		VersionChip = "V1",                          -- the small line under the typed text
		TypeText = "THANK YOU FOR USING VYRE",       -- typed out under the title
		HintText = "Tap here to continue",             -- shown when boot is done AND the intro has finished; the tap plays the outro and shows the floating logo
		-- the logo in the middle of the orb: "" = the built-in vector V (UI.icon "logo"). Otherwise an rbxassetid://... or a file inside
		-- the executor workspace (loaded through Env.customAsset). If it is empty, missing or fails to load, the V is used.
		LogoImage = "",
		-- loading music (phonk / "aura" vibe). It plays ONLY while the loading screen is up, loops until you tap, then fades.
		-- Roblox cannot play an mp3 from a string, so the file is NOT embedded. Order of sources:
		--   1. SoundFile through getcustomasset (your own mp3 in VirexHub/sounds: it always wins)
		--   2. SoundUrl (2.8.1: the intro track "Sting Intro Vyre Loader"): downloaded ONCE in the background and saved next to SoundFile as
		--      vyre_intro_<code of the link>.mp3, used from there afterwards (a different link downloads a different file)
		--   3. SoundAssetId, then SoundAssetIds: rbxassetid candidates, tried ONE BY ONE in the background (a random place in
		--      the list each launch) until one really loads on this device. Private or deleted audio is skipped.   4. silent
		SoundFile = "VirexUI/sounds/loading.mp3",
		SoundUrl = "",
		IntroDownloadSeconds = 60, -- the one-time download of SoundUrl gives up after this long (it runs in the background)
		IntroMaxMB = 25,           -- a SoundUrl file bigger than this is not saved
		SoundAssetId = "",        -- optional: tried before the list below
		-- Public Creator Store audio found on public ID lists (allthings.how, bloxodes.com; most of them re-checked on
		-- Oct 14, 2026). Roblox can make any audio private or remove it later: that is why every id is tested first.
		-- Add or remove ids freely (digits only, or the full rbxassetid:// form).
		SoundAssetIds = {
			"rbxassetid://95131770144654",  -- AURA = inf (Brazilian Phonk / Funk Epic Aura Music)  AURA x PHONK       1:34
			"rbxassetid://74793860481732",  -- 2 PHUT HON (Epic Aura Music)                         AURA x PHONK       1:55
			"rbxassetid://99979837873059",  -- +100k AURA PHONK                                     SHAKA LE TIGRE     2:33
			"rbxassetid://134289279929880", -- Aura Phonk                                           Young Kapusta      1:40
			"rbxassetid://101382134303698", -- SIGMA ENERGY PHONK (Cold Aura Edit)                  AT Musica          2:13
			"rbxassetid://126132092368935", -- MONTAGEM AURA                                        Menina de Brazil   1:40
			"rbxassetid://77701977147898",  -- SHADOW PHONK BRAZIL (Dark Atmosphere Edit)           AT Musica          1:57
			"rbxassetid://140667339171815", -- Desprezo (Aggressive Phonk), Slowed + Reverb         Alexandre Ze Musician 1:56
			"rbxassetid://140215257631273", -- Eclipse Drift                                        SynthWavesZ        2:07
			"rbxassetid://138178180069464", -- PHONK SOMBRIO                                        NOXDRIFT           2:06
			"rbxassetid://114788894326738", -- Ghost Lane                                           Khai GOD           2:14
			"rbxassetid://134434412138800", -- MEGAPHONK                                            Lowifer            3:49
			"rbxassetid://124170748342120", -- AURA SAIYAN DROP (Brazilian Phonk Music)
			"rbxassetid://14145620056",     -- The Final Phonk                                      Perfect Time Music 1:33
		},
		MusicLoop = true,         -- loop while the loading screen is open (false = play once)
		MusicCheckSeconds = 6,    -- one candidate may take this long to load before the next one is tried
		MusicMaxTries = 8,        -- at most this many candidates are tried per launch (each try is one audio download)
		SoundDownloadSeconds = 6, -- the SoundUrl download never delays start-up longer than this
		-- The intro (2.7.0, from Vyre hub v2). Everything here only changes how it looks; the boot steps, the progress line and the
		-- tap to continue are the hub's own.
		TitleFont = "LuckiestGuy", -- font of the big letters and of the typed line (any Enum.Font name; GothamBlack is used if it is missing)
		UseTheme = false,         -- false = the loading screen is always silver on black (like Vyre hub v2); true = it takes the accent colours of your theme
		Dim = 0.6,                -- how much of the game shows through behind the intro (0 = fully visible, 1 = hidden)
		-- the animated orb behind the logo: a sprite sheet (Columns x Rows cells of Size / Columns pixels). "" = a plain dark disc.
		Orb = { Image = "rbxassetid://115422258718188", Columns = 6, Rows = 6, Frames = 36, FPS = 18, Size = 1020 },
		CameraSeconds = 5,        -- how long the camera takes to drop from the sky (Settings > Loading screen can turn it off)
		CameraHeight = 340,       -- studs above your character where the drop starts
		CameraRadius = 70,        -- studs to the side where it starts (it spirals in)
		BlurSize = 8,             -- how blurred the game behind the screen is (Settings > Loading screen can turn it off)
		-- sounds of the intro: built-in Roblox sounds (no download); "" = none. They follow Settings > Sound.
		IntroSounds = {
			Open = "rbxasset://sounds/swordlunge.wav", Boom = "rbxasset://sounds/swordslash.wav", Slam = "rbxasset://sounds/swordslash.wav",
			Tick = "rbxasset://sounds/clickfast.wav", Ping = "rbxasset://sounds/electronicpingshort.wav",
		},
		-- timings (seconds)
		LettersAt = 2.1,          -- when the first letter slams down
		DropStagger = 0.13,       -- between title letters
		TypeSpeed = 0.03,         -- per typed character
		MaxSeconds = 14,          -- watchdog: forces the "tap to open" state with a warning. It never opens the hub.
		PreloadSeconds = 6,       -- cap for asset preloading
	},

	-- PRESETS: the backgrounds of Vyre hub v2 (Appearance > Customize > Static / Motion). A preset is a picture or an animated
	-- sprite sheet plus the colours that go with it. Keep every Name unique (the colour theme "vy_<name>" is made from it).
	-- Dim is only used by v2 itself: here the darkness is the "Dark overlay" slider of the Background page.
	--[[ PRESETS (taken from Vyre hub v2: its themes)
		Background: "rbxassetid://..." photo behind the menu and the intro ("" = colour gradient only)
		Gif:        "rbxassetid://..." animated background (a sprite sheet made from a GIF). Wins over Background.
		            Frames / FPS: how many pictures the sheet has and how fast they play.
		Dim:        how dark the photo is (0 = fully visible, 1 = hidden)
		Accent / Accent2 / Hot: button, glow and border colours
		Panel / Card / Card2:  window and card colours
		Copy a block to add more themes. ]]
	Presets = {
		{ Name = "Noir", Background = "rbxassetid://95845335655412", Dim = 0.12,
			Accent = Color3.fromRGB(235, 236, 240), Accent2 = Color3.fromRGB(255, 255, 255), Hot = Color3.fromRGB(120, 122, 130),
			Panel = Color3.fromRGB(9, 9, 11), Card = Color3.fromRGB(20, 20, 24), Card2 = Color3.fromRGB(32, 32, 38) },
		{ Name = "Ice", Background = "rbxassetid://95845335655412", Dim = 0.12,
			Accent = Color3.fromRGB(47, 107, 255), Accent2 = Color3.fromRGB(169, 216, 255), Hot = Color3.fromRGB(255, 92, 170),
			Panel = Color3.fromRGB(10, 13, 24), Card = Color3.fromRGB(22, 28, 46), Card2 = Color3.fromRGB(32, 40, 64) },
		{ Name = "Violet", Background = "rbxassetid://109682858333398", Dim = 0.12,
			Accent = Color3.fromRGB(138, 76, 255), Accent2 = Color3.fromRGB(214, 190, 255), Hot = Color3.fromRGB(255, 120, 220),
			Panel = Color3.fromRGB(14, 10, 26), Card = Color3.fromRGB(30, 22, 50), Card2 = Color3.fromRGB(44, 32, 70) },
		{ Name = "Crimson", Background = "rbxassetid://103964167589822", Dim = 0.12,
			Accent = Color3.fromRGB(255, 60, 92), Accent2 = Color3.fromRGB(255, 185, 195), Hot = Color3.fromRGB(255, 170, 60),
			Panel = Color3.fromRGB(20, 8, 12), Card = Color3.fromRGB(40, 16, 24), Card2 = Color3.fromRGB(58, 24, 34) },
		{ Name = "Mint", Background = "rbxassetid://80469187866764", Dim = 0.12,
			Accent = Color3.fromRGB(30, 200, 140), Accent2 = Color3.fromRGB(170, 255, 220), Hot = Color3.fromRGB(80, 180, 255),
			Panel = Color3.fromRGB(7, 18, 16), Card = Color3.fromRGB(14, 36, 31), Card2 = Color3.fromRGB(20, 50, 44) },
		{ Name = "Sunset", Background = "rbxassetid://130939890430008", Dim = 0.12,
			Accent = Color3.fromRGB(255, 120, 50), Accent2 = Color3.fromRGB(255, 212, 155), Hot = Color3.fromRGB(255, 70, 140),
			Panel = Color3.fromRGB(22, 11, 9), Card = Color3.fromRGB(42, 23, 18), Card2 = Color3.fromRGB(58, 32, 24) },
		{ Name = "Void", Background = "", Dim = 0.12,
			Accent = Color3.fromRGB(160, 175, 215), Accent2 = Color3.fromRGB(240, 244, 252), Hot = Color3.fromRGB(110, 130, 255),
			Panel = Color3.fromRGB(7, 7, 11), Card = Color3.fromRGB(20, 20, 27), Card2 = Color3.fromRGB(32, 32, 42) },

		-- Motion backgrounds (sprite sheets made from GIFs). Columns/Rows/Width/Height only when the sheet is not 4 x 6.
		{ Name = "Orb", Gif = "rbxassetid://115422258718188", Frames = 36, FPS = 18, Columns = 6, Rows = 6, Width = 1020, Height = 1020, Dim = 0.05,
			Accent = Color3.fromRGB(235, 236, 240), Accent2 = Color3.fromRGB(255, 255, 255), Hot = Color3.fromRGB(120, 122, 130),
			Panel = Color3.fromRGB(6, 6, 8), Card = Color3.fromRGB(18, 18, 22), Card2 = Color3.fromRGB(30, 30, 36) },
		{ Name = "Ocean", Gif = "rbxassetid://92203048087211", Frames = 24, FPS = 12.5, Dim = 0.1,
			Accent = Color3.fromRGB(90, 190, 255), Accent2 = Color3.fromRGB(200, 240, 255), Hot = Color3.fromRGB(40, 120, 200),
			Panel = Color3.fromRGB(4, 14, 22), Card = Color3.fromRGB(8, 26, 38), Card2 = Color3.fromRGB(14, 40, 56) },
		{ Name = "Heaven", Gif = "rbxassetid://110550227129244", Frames = 24, FPS = 12.5, Dim = 0.1,
			Accent = Color3.fromRGB(120, 200, 255), Accent2 = Color3.fromRGB(255, 255, 255), Hot = Color3.fromRGB(80, 160, 230),
			Panel = Color3.fromRGB(12, 26, 44), Card = Color3.fromRGB(20, 40, 64), Card2 = Color3.fromRGB(30, 56, 86) },
		{ Name = "Stream", Gif = "rbxassetid://125722914688906", Frames = 19, FPS = 16.7, Dim = 0.1,
			Accent = Color3.fromRGB(150, 210, 110), Accent2 = Color3.fromRGB(230, 245, 200), Hot = Color3.fromRGB(240, 200, 110),
			Panel = Color3.fromRGB(10, 16, 8), Card = Color3.fromRGB(20, 30, 16), Card2 = Color3.fromRGB(30, 44, 24) },
		{ Name = "Inferno", Gif = "rbxassetid://116811530360656", Frames = 24, FPS = 11.2, Dim = 0.1,
			Accent = Color3.fromRGB(255, 170, 50), Accent2 = Color3.fromRGB(255, 230, 160), Hot = Color3.fromRGB(255, 90, 30),
			Panel = Color3.fromRGB(22, 12, 4), Card = Color3.fromRGB(40, 22, 8), Card2 = Color3.fromRGB(58, 32, 12) },
		{ Name = "Golden", Gif = "rbxassetid://86953866218071", Frames = 24, FPS = 11.7, Dim = 0.1,
			Accent = Color3.fromRGB(255, 210, 110), Accent2 = Color3.fromRGB(255, 245, 210), Hot = Color3.fromRGB(150, 210, 90),
			Panel = Color3.fromRGB(20, 16, 6), Card = Color3.fromRGB(36, 30, 12), Card2 = Color3.fromRGB(52, 44, 18) },
		{ Name = "Night", Gif = "rbxassetid://129010370853587", Frames = 12, FPS = 14.3, Dim = 0.05,
			Accent = Color3.fromRGB(220, 222, 228), Accent2 = Color3.fromRGB(255, 255, 255), Hot = Color3.fromRGB(130, 132, 140),
			Panel = Color3.fromRGB(10, 10, 12), Card = Color3.fromRGB(22, 22, 26), Card2 = Color3.fromRGB(34, 34, 40) },
		{ Name = "Black Hole", Gif = "rbxassetid://134072355345185", Frames = 24, FPS = 20, Dim = 0.05,
			Accent = Color3.fromRGB(235, 236, 240), Accent2 = Color3.fromRGB(255, 255, 255), Hot = Color3.fromRGB(110, 112, 120),
			Panel = Color3.fromRGB(4, 4, 6), Card = Color3.fromRGB(16, 16, 20), Card2 = Color3.fromRGB(28, 28, 34) },
		{ Name = "Forest", Gif = "rbxassetid://134614395274312", Frames = 24, FPS = 14.3, Dim = 0.1,
			Accent = Color3.fromRGB(240, 190, 80), Accent2 = Color3.fromRGB(255, 235, 170), Hot = Color3.fromRGB(170, 200, 70),
			Panel = Color3.fromRGB(18, 14, 4), Card = Color3.fromRGB(34, 28, 10), Card2 = Color3.fromRGB(48, 40, 16) },
	},

	-- UI sounds. IDs come from the scripts you supplied (Multiverse click, Blyxo hover / loading /
	-- error). They could NOT be verified from the build sandbox, so every asset is preloaded at
	-- boot and anything that fails to load is skipped silently (see Settings > Sound status).
	-- Replace an id with any audio asset you own or that is public. Use "" to disable an event.
	-- Fields: id, volume (0-1), speed (pitch), chain (list of {at = seconds, speed = n}).
	Sounds = {
		click    = { id = "rbxassetid://6895079853",   volume = 0.35, speed = 1.00 },
		select   = { id = "rbxassetid://6895079853",   volume = 0.30, speed = 1.18 },
		toggleOn = { id = "rbxassetid://6895079853",   volume = 0.32, speed = 1.32 },
		toggleOff= { id = "rbxassetid://6895079853",   volume = 0.30, speed = 0.82 },
		dropdown = { id = "rbxassetid://6895079853",   volume = 0.28, speed = 1.06 },
		tab      = { id = "rbxassetid://139800881181209", volume = 0.40, speed = 1.00 },
		open     = { id = "rbxassetid://139800881181209", volume = 0.40, speed = 0.92 },
		close    = { id = "rbxassetid://139800881181209", volume = 0.40, speed = 0.74 },
		success  = { id = "rbxassetid://6895079853",   volume = 0.30, speed = 1.20,
			chain = { { at = 0.00, speed = 1.20 }, { at = 0.075, speed = 1.62 } } },
		warning  = { id = "rbxassetid://6895079853",   volume = 0.32, speed = 0.78,
			chain = { { at = 0.00, speed = 0.78 }, { at = 0.10, speed = 0.78 } } },
		error    = { id = "rbxassetid://71028126634386", volume = 0.45, speed = 1.00 },
		-- loading music: the id is filled in at start-up by Splash.resolveSound for a local file / download. An rbxassetid from
		-- CONFIG.Splash.SoundAssetIds is picked in the background instead and leaves this id empty.
		-- No maxSeconds: it loops while the loading screen is up, then fades out when the screen closes.
		loading  = { id = "", volume = 0.45, speed = 1.00 },
	},

	-- Typography. "enum" families use Roblox's built-in fonts (always available).
	-- A family can have a second face for headings: `display = {...}` (same keys as `enum`) is used for the display,
	-- title, heading and stat roles, `enum` for everything else, and `dscale` shrinks or grows the heading size so a wide
	-- face cannot push text out of its box. The entries marked `pair = true` are shown first on Appearance > Type pair.
	-- To add your own fonts later, upload them to Roblox as a Font Family asset (Creator Hub) and
	-- add an entry with  face = "rbxassetid://<family asset id>"  - nothing else has to change.
	Fonts = {
		Default = "gotham",
		Families = {
			{ id = "gotham",  name = "Gotham",       sub = "Clean and familiar", pair = true,
				enum = { regular = "Gotham", medium = "GothamMedium", bold = "GothamBold" } },
			{ id = "facet",   name = "Facet",        sub = "Cut and squared", pair = true, dscale = 1.06,
				enum = { regular = "TitilliumWeb", medium = "TitilliumWeb", bold = "TitilliumWeb" },
				display = { regular = "Sarpanch", medium = "Sarpanch", bold = "Sarpanch" } },
			{ id = "books",   name = "Books",        sub = "Serif titles, calm text", pair = true, dscale = 0.92,
				enum = { regular = "Gotham", medium = "GothamMedium", bold = "GothamBold" },
				display = { regular = "Merriweather", medium = "Merriweather", bold = "Merriweather" } },
			{ id = "wide",    name = "Wide",         sub = "Stretched and techy", pair = true, dscale = 0.78,
				enum = { regular = "Gotham", medium = "GothamMedium", bold = "GothamBold" },
				display = { regular = "Michroma", medium = "Michroma", bold = "Michroma" } },
			{ id = "deco",    name = "Deco",         sub = "Art deco and soft", pair = true, dscale = 1.06,
				enum = { regular = "Nunito", medium = "Nunito", bold = "Nunito" },
				display = { regular = "JosefinSans", medium = "JosefinSans", bold = "JosefinSans" } },
			{ id = "terminal", name = "Terminal",    sub = "All monospace", pair = true, dscale = 0.9,
				enum = { regular = "RobotoMono", medium = "RobotoMono", bold = "RobotoMono" } },
			{ id = "builder", name = "Builder Sans", sub = "One font", enum = { regular = "BuilderSans",  medium = "BuilderSansMedium",  bold = "BuilderSansBold" } },
			{ id = "source",  name = "Source Sans",  sub = "One font", enum = { regular = "SourceSans",   medium = "SourceSansSemibold", bold = "SourceSansBold" } },
			{ id = "ubuntu",  name = "Ubuntu",       sub = "One font", enum = { regular = "Ubuntu",       medium = "Ubuntu",             bold = "Ubuntu" } },
			{ id = "roboto",  name = "Roboto",       sub = "One font", enum = { regular = "Roboto",       medium = "Roboto",             bold = "Roboto" } },
			-- { id = "brand", name = "My Brand Font", face = "rbxassetid://0" },   <- example, keep commented until you have an id
		},
		-- DISPLAY FONT (Appearance > Customize > Fonts), from Vyre hub v2. One decorative font for the big text only: titles, headings,
		-- tab names and numbers. Everything else keeps the font family above, so small text stays easy to read. It overrides the
		-- heading face of a Type pair while it is on. DisplayDefault = "" keeps the 2.4.0 look until you pick one; write a name from
		-- the list (for example "LuckiestGuy", the font of Vyre hub v2) to start with that one. The list only uses built-in Roblox
		-- fonts; a name this client does not have is left out. DisplayScale shrinks the very wide ones so text still fits its box.
		DisplayDefault = "",
		Display = {
			"LuckiestGuy", "GothamBlack", "FredokaOne", "Bangers", "Michroma", "Sarpanch", "Oswald", "TitilliumWeb", "Jura", "Arcade",
			"SciFi", "Highway", "Cartoon", "PermanentMarker", "Creepster", "DenkOne", "GrenzeGotisch", "Nunito", "Ubuntu", "RobotoCondensed",
			"RobotoMono", "Merriweather", "SpecialElite", "Kalam", "PatrickHand", "IndieFlower", "AmaticSC", "Fondamento", "Bodoni", "Garamond",
			"Antique", "Fantasy", "SourceSansBold", "ArialBold",
		},
		DisplayScale = { Michroma = 0.8, Arcade = 0.85, SciFi = 0.85, Highway = 0.92, GrenzeGotisch = 0.95, Creepster = 0.95 },
	},
}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local function optionalService(name)
	local ok, service = pcall(game.GetService, game, name)
	if ok then
		return service
	end
	return nil
end

local GuiService = optionalService("GuiService")
local ContentProvider = optionalService("ContentProvider")
local SoundService = optionalService("SoundService")
local Lighting = optionalService("Lighting")
local TeleportService = optionalService("TeleportService")
local StatsService = optionalService("Stats")
local TextService = optionalService("TextService")

local Util, Maid, Env, Store, Motion, Anim, Typo, Theme, Sfx, Notify, UI, Bg, Splash, Avatar, Win, Pages, App, Scripts, Music, Runner =
	{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}

----------------------------------------------------------------------------------------------------
-- Util: small pure helpers shared by every module
----------------------------------------------------------------------------------------------------
Util.logs = {}

function Util.log(level, message)
	local logs = Util.logs
	logs[#logs + 1] = { t = os.clock(), level = level, message = tostring(message) }
	if #logs > 80 then
		table.remove(logs, 1)
	end
end

function Util.try(label, fn, ...)
	local ok, a, b, c = pcall(fn, ...)
	if not ok then
		Util.log("error", tostring(label) .. ": " .. tostring(a))
	end
	return ok, a, b, c
end

function Util.clamp(x, lo, hi)
	if x < lo then
		return lo
	elseif x > hi then
		return hi
	end
	return x
end

function Util.lerp(a, b, t)
	return a + (b - a) * t
end

function Util.round(x, step)
	step = step or 1
	return math.floor(x / step + 0.5) * step
end

function Util.percent(x)
	return math.floor(x * 100 + 0.5)
end

function Util.trim(s)
	s = tostring(s == nil and "" or s)
	return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

function Util.split(s, sep)
	local out, pos = {}, 1
	s = tostring(s)
	if sep == nil or sep == "" then
		out[1] = s
		return out
	end
	while true do
		local a, b = string.find(s, sep, pos, true)
		if not a then
			out[#out + 1] = string.sub(s, pos)
			break
		end
		out[#out + 1] = string.sub(s, pos, a - 1)
		pos = b + 1
	end
	return out
end

function Util.cap(s, n)
	s = tostring(s)
	if #s <= n then
		return s
	end
	return string.sub(s, 1, math.max(1, n - 3)) .. "..."
end

function Util.count(t)
	local n = 0
	for _ in pairs(t) do
		n = n + 1
	end
	return n
end

function Util.indexOf(list, value)
	for i = 1, #list do
		if list[i] == value then
			return i
		end
	end
	return nil
end

function Util.copy(t)
	local out = {}
	for k, v in pairs(t) do
		out[k] = v
	end
	return out
end

function Util.deepCopy(t)
	if type(t) ~= "table" then
		return t
	end
	local out = {}
	for k, v in pairs(t) do
		out[k] = Util.deepCopy(v)
	end
	return out
end

function Util.hash(s)
	local h = 5381
	for i = 1, #s do
		h = (h * 33 + string.byte(s, i)) % 4294967296
	end
	return string.format("%08x", h)
end

function Util.duration(seconds)
	seconds = math.max(0, math.floor(seconds))
	local h = math.floor(seconds / 3600)
	local m = math.floor((seconds % 3600) / 60)
	local s = seconds % 60
	if h > 0 then
		return string.format("%dh %02dm", h, m)
	end
	return string.format("%dm %02ds", m, s)
end

function Util.jsonEncode(value)
	local ok, result = pcall(HttpService.JSONEncode, HttpService, value)
	if ok then
		return result
	end
	return nil, result
end

function Util.jsonDecode(text)
	local ok, result = pcall(HttpService.JSONDecode, HttpService, text)
	if ok then
		return result
	end
	return nil, result
end

-- colour helpers ------------------------------------------------------------------------------
function Util.mix(a, b, t)
	if t <= 0 then
		return a
	elseif t >= 1 then
		return b
	end
	return Color3.new(a.R + (b.R - a.R) * t, a.G + (b.G - a.G) * t, a.B + (b.B - a.B) * t)
end

local function linearChannel(v)
	if v <= 0.04045 then
		return v / 12.92
	end
	return ((v + 0.055) / 1.055) ^ 2.4
end

function Util.lum(c)
	return 0.2126 * linearChannel(c.R) + 0.7152 * linearChannel(c.G) + 0.0722 * linearChannel(c.B)
end

function Util.contrast(a, b)
	local la, lb = Util.lum(a), Util.lum(b)
	if la < lb then
		la, lb = lb, la
	end
	return (la + 0.05) / (lb + 0.05)
end

-- text colour (dark or light) that reads best on `bg`
function Util.onColor(bg, dark, light)
	dark = dark or Color3.fromRGB(12, 14, 20)
	light = light or Color3.fromRGB(248, 250, 253)
	if Util.contrast(bg, dark) >= Util.contrast(bg, light) then
		return dark
	end
	return light
end

-- hue (degrees), saturation and lightness (0..1) <-> Color3. Same maths as the HSL sliders of the theme builder.
function Util.rgb2hsl(c)
	local r, g, b = c.R, c.G, c.B
	local mx, mn = math.max(r, g, b), math.min(r, g, b)
	local l = (mx + mn) / 2
	local h, s = 0, 0
	if mx ~= mn then
		local d = mx - mn
		if l > 0.5 then
			s = d / (2 - mx - mn)
		else
			s = d / (mx + mn)
		end
		if mx == r then
			h = (g - b) / d + (g < b and 6 or 0)
		elseif mx == g then
			h = (b - r) / d + 2
		else
			h = (r - g) / d + 4
		end
		h = h * 60
	end
	return h, s, l
end

function Util.hsl2rgb(h, s, l)
	h = ((h % 360) + 360) % 360
	s = Util.clamp(s, 0, 1)
	l = Util.clamp(l, 0, 1)
	local a = s * math.min(l, 1 - l)
	local function f(n)
		local k = (n + h / 30) % 12
		return l - a * math.max(-1, math.min(k - 3, math.min(9 - k, 1)))
	end
	return Color3.new(f(0), f(8), f(4))
end

function Util.lighten(c, t)
	return Util.mix(c, Color3.new(1, 1, 1), t)
end

function Util.darken(c, t)
	return Util.mix(c, Color3.new(0, 0, 0), t)
end

-- instance helpers (properties are assigned BEFORE parenting, which is cheaper) ----------------
function Util.new(className, props, parent)
	local inst = Instance.new(className)
	if props then
		for key, value in pairs(props) do
			inst[key] = value
		end
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

-- radius: pixels, or a UDim (UDim.new(0.5, 0) = a capsule that stays round whatever the size)
function Util.corner(parent, radius)
	local value
	if typeof(radius) == "UDim" then
		value = radius
	else
		value = UDim.new(0, radius or 10)
	end
	return Util.new("UICorner", { CornerRadius = value }, parent)
end

function Util.round_corner(parent)
	return Util.new("UICorner", { CornerRadius = UDim.new(1, 0) }, parent)
end

function Util.stroke(parent, color, thickness, transparency)
	return Util.new("UIStroke", {
		Color = color or Color3.new(1, 1, 1),
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, parent)
end

function Util.pad(parent, left, top, right, bottom)
	top = top or left
	right = right or left
	bottom = bottom or top
	return Util.new("UIPadding", {
		PaddingLeft = UDim.new(0, left or 0),
		PaddingTop = UDim.new(0, top or 0),
		PaddingRight = UDim.new(0, right or 0),
		PaddingBottom = UDim.new(0, bottom or 0),
	}, parent)
end

function Util.list(parent, padding, horizontal)
	return Util.new("UIListLayout", {
		FillDirection = horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, padding or 0),
	}, parent)
end

function Util.isInstance(v)
	return typeof(v) == "Instance"
end

function Util.alive(inst)
	return inst ~= nil and typeof(inst) == "Instance" and inst.Parent ~= nil
end

----------------------------------------------------------------------------------------------------
-- Maid: collects connections / instances / callbacks so teardown is one call
----------------------------------------------------------------------------------------------------
Maid.__index = Maid

function Maid.new()
	return setmetatable({ _items = {}, _n = 0 }, Maid)
end

local function disposeItem(item)
	local kind = typeof(item)
	if kind == "function" then
		pcall(item)
	elseif kind == "RBXScriptConnection" then
		pcall(item.Disconnect, item)
	elseif kind == "Instance" then
		if item.ClassName == "Tween" then
			pcall(item.Cancel, item)
		end
		pcall(item.Destroy, item)
	elseif kind == "thread" then
		pcall(task.cancel, item)
	elseif kind == "table" then
		if type(item.Destroy) == "function" then
			pcall(item.Destroy, item)
		elseif type(item.Disconnect) == "function" then
			pcall(item.Disconnect, item)
		elseif type(item.Cancel) == "function" then
			pcall(item.Cancel, item)
		end
	end
end

function Maid:Give(item)
	if item ~= nil then
		self._n = self._n + 1
		self._items[self._n] = item
	end
	return item
end

function Maid:Connect(signal, fn)
	return self:Give(signal:Connect(fn))
end

function Maid:Clean()
	local items, n = self._items, self._n
	self._items, self._n = {}, 0
	for i = n, 1, -1 do
		disposeItem(items[i])
	end
end

Maid.Destroy = Maid.Clean

----------------------------------------------------------------------------------------------------
-- Env: executor / platform feature detection. Every executor global is read inside pcall.
----------------------------------------------------------------------------------------------------
local function optionalGlobal(getter)
	local ok, value = pcall(getter)
	if ok and type(value) == "function" then
		return value
	end
	return nil
end

Env.fn = {}

function Env.detect()
	local fn = Env.fn
	fn.writefile = optionalGlobal(function() return writefile end)
	fn.readfile = optionalGlobal(function() return readfile end)
	fn.isfile = optionalGlobal(function() return isfile end)
	fn.makefolder = optionalGlobal(function() return makefolder end)
	fn.isfolder = optionalGlobal(function() return isfolder end)
	fn.delfile = optionalGlobal(function() return delfile end) -- 2.8.0: only used to remove the saved copy of a music link
	fn.getcustomasset = optionalGlobal(function() return getcustomasset or getsynasset end)
	fn.setclipboard = optionalGlobal(function() return setclipboard or toclipboard end)
	fn.request = optionalGlobal(function()
		return request or http_request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request)
	end)
	fn.gethui = optionalGlobal(function() return gethui end)
	fn.getgenv = optionalGlobal(function() return getgenv end)
	fn.identify = optionalGlobal(function() return identifyexecutor or getexecutorname end)
	fn.loadstring = optionalGlobal(function() return loadstring end)
	fn.httpget = optionalGlobal(function() return game.HttpGet end)
	-- 2.8.0 (Stop / undo a script): the functions the Runner uses. All optional; the Runner says what it could not do.
	fn.setfenv = optionalGlobal(function() return setfenv end)
	fn.getfenv = optionalGlobal(function() return getfenv end)
	fn.getconnections = optionalGlobal(function() return getconnections end)
	fn.hookfunction = optionalGlobal(function() return hookfunction or replaceclosure end)
	fn.hookmetamethod = optionalGlobal(function() return hookmetamethod end)
	fn.restorefunction = optionalGlobal(function() return restorefunction end)
	fn.newcclosure = optionalGlobal(function() return newcclosure end)
	fn.iscclosure = optionalGlobal(function() return iscclosure end)
	Env.drawing = nil
	local okDrawing, drawing = pcall(function() return Drawing end)
	if okDrawing and type(drawing) == "table" and type(drawing.new) == "function" then
		Env.drawing = drawing
	end

	Env.executor, Env.executorVersion = "unknown", ""
	if fn.identify then
		local ok, name, version = pcall(fn.identify)
		if ok and type(name) == "string" and name ~= "" then
			Env.executor = name
			if type(version) == "string" then
				Env.executorVersion = version
			end
		end
	end

	Env.touch = UserInputService.TouchEnabled
	Env.keyboard = UserInputService.KeyboardEnabled
	Env.mouse = UserInputService.MouseEnabled
	return Env
end

function Env.canSave()
	local fn = Env.fn
	return fn.writefile ~= nil and fn.readfile ~= nil and fn.isfile ~= nil
end

function Env.canClipboard()
	return Env.fn.setclipboard ~= nil
end

function Env.canCustomAsset()
	return Env.fn.getcustomasset ~= nil and Env.canSave()
end

function Env.canDownload()
	return Env.canCustomAsset() and (Env.fn.request ~= nil)
end

-- Some executors expose the file functions but refuse every call. A harmless folder query tells the two cases apart.
function Env.filesWork()
	local fn = Env.fn
	if not (fn.isfile and fn.isfolder) then
		return false
	end
	local ok = pcall(fn.isfolder, CONFIG.Folder)
	return ok
end

-- the table that survives re-execution (executor global environment, or _G as a fallback)
function Env.global()
	if Env.fn.getgenv then
		local ok, env = pcall(Env.fn.getgenv)
		if ok and type(env) == "table" then
			return env
		end
	end
	return _G
end

function Env.viewport()
	local camera = workspace.CurrentCamera
	if camera then
		local size = camera.ViewportSize
		if size.X > 50 and size.Y > 50 then
			return size
		end
	end
	return Vector2.new(800, 450)
end

function Env.localPlayer()
	local player = Players.LocalPlayer
	if player then
		return player
	end
	local waited = 0
	while not Players.LocalPlayer and waited < 10 do
		task.wait(0.1)
		waited = waited + 0.1
	end
	return Players.LocalPlayer
end

-- where the ScreenGui goes: hidden UI container when the executor offers one, else PlayerGui
function Env.guiParent()
	if Env.fn.gethui then
		local ok, container = pcall(Env.fn.gethui)
		if ok and typeof(container) == "Instance" then
			return container, "gethui"
		end
	end
	local player = Env.localPlayer()
	if player then
		local pg = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui", 8)
		if pg then
			return pg, "PlayerGui"
		end
	end
	return nil, "none"
end

function Env.readFile(path)
	local fn = Env.fn
	if not (fn.readfile and fn.isfile) then
		return nil, "file access unavailable"
	end
	local okExists, exists = pcall(fn.isfile, path)
	if not okExists or not exists then
		return nil, "missing"
	end
	local ok, data = pcall(fn.readfile, path)
	if ok and type(data) == "string" then
		return data
	end
	return nil, tostring(data)
end

function Env.writeFile(path, data)
	if not Env.fn.writefile then
		return false, "file access unavailable"
	end
	local ok, err = pcall(Env.fn.writefile, path, data)
	if ok then
		return true
	end
	return false, tostring(err)
end

function Env.fileExists(path)
	if not Env.fn.isfile then
		return false
	end
	local ok, exists = pcall(Env.fn.isfile, path)
	return ok and exists == true
end

-- removes one file of the hub's own cache folder (music links). false when the executor has no delfile or refuses it.
function Env.deleteFile(path)
	if not Env.fn.delfile then
		return false
	end
	local ok = pcall(Env.fn.delfile, path)
	return ok
end

function Env.ensureFolder(path)
	local fn = Env.fn
	if not (fn.makefolder and fn.isfolder) then
		return false
	end
	local built = ""
	for _, part in ipairs(Util.split(path, "/")) do
		if part ~= "" then
			built = (built == "") and part or (built .. "/" .. part)
			local okExists, exists = pcall(fn.isfolder, built)
			if okExists and not exists then
				pcall(fn.makefolder, built)
			end
		end
	end
	local okFinal, final = pcall(fn.isfolder, path)
	return okFinal and final == true
end

function Env.copy(text)
	if not Env.fn.setclipboard then
		return false
	end
	local ok = pcall(Env.fn.setclipboard, tostring(text))
	return ok
end

function Env.customAsset(path)
	if not Env.fn.getcustomasset then
		return nil, "getcustomasset unavailable"
	end
	local ok, result = pcall(Env.fn.getcustomasset, path)
	if ok and type(result) == "string" and result ~= "" then
		return result
	end
	return nil, tostring(result)
end

-- plain GET used only to download an image the user explicitly typed in (never executed as code)
function Env.httpGet(url)
	local fn = Env.fn
	if fn.request then
		local ok, res = pcall(fn.request, { Url = url, Method = "GET" })
		if not ok then
			return nil, tostring(res)
		end
		if type(res) == "table" then
			local code = tonumber(res.StatusCode or res.status_code) or 0
			if (res.Success == true or (code >= 200 and code < 300)) and type(res.Body) == "string" then
				return res.Body
			end
			return nil, "HTTP " .. tostring(code)
		end
		return nil, "unexpected response"
	end
	return nil, "request function unavailable"
end

----------------------------------------------------------------------------------------------------
-- script launcher helpers (added in 2.1.0). They are used only by the Scripts tab and the Private
-- Server Finder, and only after the user taps a button. Env.httpGet above keeps its own contract
-- (image download, never executed).
----------------------------------------------------------------------------------------------------
function Env.canRun()
	return Env.fn.loadstring ~= nil
end

function Env.canFetch()
	return Env.fn.httpget ~= nil or Env.fn.request ~= nil
end

-- One GET. order: "get" (game:HttpGet, then the request function), "request" (request function, then
-- game:HttpGet) or "request-only". The second function is tried only when the first gave no HTTP status,
-- so a real 404 or 429 is final. Returns { ok, status, body, error, via }.
function Env.fetch(url, order)
	local fn = Env.fn
	local function viaHttpGet()
		if not fn.httpget then
			return { ok = false, via = "HttpGet", error = "HttpGet is not available" }
		end
		local ok, body = pcall(fn.httpget, game, url)
		if ok and type(body) == "string" then
			return { ok = true, via = "HttpGet", body = body }
		end
		return { ok = false, via = "HttpGet", error = tostring(body) }
	end
	local function viaRequest()
		if not fn.request then
			return { ok = false, via = "request", error = "request function is not available" }
		end
		local ok, res = pcall(fn.request, { Url = url, Method = "GET" })
		if not ok then
			return { ok = false, via = "request", error = tostring(res) }
		end
		if type(res) ~= "table" then
			return { ok = false, via = "request", error = "unexpected response" }
		end
		local code = tonumber(res.StatusCode or res.status_code) or 0
		local status = code > 0 and code or nil
		local success = (code >= 200 and code < 300) or (code == 0 and res.Success == true)
		if success and type(res.Body) == "string" then
			return { ok = true, via = "request", status = status, body = res.Body }
		end
		return { ok = false, via = "request", status = status, error = status and ("HTTP " .. status) or "request failed" }
	end
	local first, second = viaHttpGet, viaRequest
	if order == "request" or order == "request-only" then
		first, second = viaRequest, viaHttpGet
	end
	local result = first()
	if result.ok or result.status or order == "request-only" then
		return result
	end
	local fallback = second()
	if fallback.ok or fallback.status then
		return fallback
	end
	result.error = tostring(result.error) .. " / " .. tostring(fallback.error)
	return result
end

-- loadstring wrapper: returns the compiled function, or nil and the reason. chunkname (optional, "=name") labels the chunk so that
-- a function written in it can be told apart later (the Runner uses this).
function Env.compile(source, chunkname)
	local compile = Env.fn.loadstring
	if not compile then
		return nil, "loadstring is not available"
	end
	local ok, chunk, err
	if chunkname then
		ok, chunk, err = pcall(compile, source, chunkname)
	else
		ok, chunk, err = pcall(compile, source)
	end
	if not ok then
		return nil, tostring(chunk)
	end
	if type(chunk) ~= "function" then
		return nil, tostring(err or "the script could not be compiled")
	end
	return chunk
end

function Env.runSummary()
	local fn = Env.fn
	local function flag(v)
		return v and "yes" or "no"
	end
	return string.format("Run scripts (loadstring) %s | HttpGet %s | request %s", flag(fn.loadstring), flag(fn.httpget), flag(fn.request))
end

function Env.summary()
	local fn = Env.fn
	local function flag(v)
		return v and "yes" or "no"
	end
	return string.format(
		"Executor %s | files %s | clipboard %s | custom assets %s | http %s | hidden ui %s | touch %s",
		Env.executor,
		flag(Env.canSave()),
		flag(Env.canClipboard()),
		flag(fn.getcustomasset ~= nil),
		flag(fn.request ~= nil),
		flag(fn.gethui ~= nil),
		flag(Env.touch)
	)
end

----------------------------------------------------------------------------------------------------
-- Store: validated settings with debounced saving (only when the executor offers file access)
----------------------------------------------------------------------------------------------------
Store.defaults = {
	version = 1,
	theme = "obsidian",
	fx = 2,
	reducedMotion = false,
	lowPower = false,
	notifications = true,
	clock = true,
	compact = false,
	scale = 1,
	sound = true,
	volume = 0.6,
	font = "gotham",
	bgMode = "solid",
	bgImage = "",
	bannerImage = "",
	bannerSize = "medium",
	bannerFit = "crop",
	bgSequence = "",
	bgVideo = "",
	bgFps = 8,
	bgCols = 4,
	bgRows = 4,
	glass = 0,
	overlay = 0.35,
	blur = false,
	splash = true,
	splashSound = true,
	favorites = {},
	bundleFavorites = {},    -- 2.8.1: favourite bundles, { id = "digits", name, kind } (kept by Reset, like the player favourites)
	scriptFavorites = {},
	lastTarget = "",
	lastBundle = "",         -- 2.8.1: the last bundle ID or link typed on the Avatar page
	logoX = -1,          -- resting spot of the floating logo as a fraction of the screen (-1 = not placed yet)
	logoY = -1,
	-- 2.4.0: pages ported from the VYRE / NEXUS design
	accentMotion = "still", -- Appearance > Colour motion: still | breathe | drift | spectrum
	accentSpeed = 1,        -- 0.5x .. 2x
	customH = 268,          -- "Make your own" theme: hue, colour strength, darkness, second-colour offset
	customS = 62,
	customD = 7,
	customO = 40,
	textSize = 100,         -- Appearance > Text size (percent); the window and buttons keep their size
	layerSparkle = false,   -- Background > Layers (they sit on top of any style)
	layerSweep = false,
	layerVignette = false,
	layerRim = false,
	parallax = "off",       -- Background > Depth: off | touch
	parallaxAmount = 55,
	notifySeconds = 5,      -- Settings > Notifications
	keepErrors = true,
	-- 2.7.0: loading screen of Vyre hub v2, the Music tab and Appearance > Customize
	splashCamera = true,    -- loading screen: the camera drops from the sky (always handed back when the screen closes)
	splashBlur = true,      -- loading screen: the game behind it is blurred
	bgFrames = 0,           -- frames used from a sprite sheet (0 = every cell of the grid)
	preset = "",            -- the background preset that is applied (marked in Appearance > Customize)
	displayFont = CONFIG.Fonts.DisplayDefault or "", -- font of the big text (titles, headings, tabs); "" = the interface font
	editBase = "",          -- Customize > Colors: the theme the edited colours were made from
	editColors = "",        -- Customize > Colors: "Role=rrggbb;Role=rrggbb"
	musicVolume = 0.5,      -- Music tab: volume of the music only
	musicRepeat = "all",    -- all | one | off
	musicShuffle = false,
	musicHideBad = true,    -- hide songs that did not load on this device
	musicLast = "",         -- the song that was played last (shown, never started by itself)
	musicCustom = {},       -- audio ids you added in the Music tab
	musicLinks = {},        -- 2.8.0: links to audio files (.mp3 / .ogg) you added in the Music tab: { id = "w<hash>", url, title }
	musicBad = {},          -- ids that did not load on this device (a "Check all" can bring them back)
	-- 2.8.0: Scripts tab (Stop / Switch)
	scriptAutoSwitch = true, -- starting a script first stops the one that is running (no piling up)
	scriptRestore = true,    -- Stop puts the game settings the script changed (walk speed, gravity, ...) back
	scriptSandbox = true,    -- 2.8.1: scripts run inside the sandbox (full Stop). Off = they run as they are
	scriptPlain = {},        -- 2.8.1: catalog ids that failed inside the sandbox and are started without it from now on
}

Store.rules = {
	version = { kind = "int", min = 1, max = 99 },
	theme = { kind = "string", max = 32 },
	fx = { kind = "int", min = 0, max = 2 },
	reducedMotion = { kind = "bool" },
	lowPower = { kind = "bool" },
	notifications = { kind = "bool" },
	clock = { kind = "bool" },
	compact = { kind = "bool" },
	scale = { kind = "number", min = 0.7, max = 1.3 },
	sound = { kind = "bool" },
	volume = { kind = "number", min = 0, max = 1 },
	font = { kind = "string", max = 32 },
	bgMode = { kind = "string", max = 16, oneOf = { "solid", "aurora", "sparkle", "facets", "ribbons", "stars", "lattice", "image", "sheet", "sequence", "video" } },
	bgImage = { kind = "string", max = 400 },
	bannerImage = { kind = "string", max = 400 },
	bannerSize = { kind = "string", max = 8, oneOf = { "small", "medium", "large" } },
	bannerFit = { kind = "string", max = 8, oneOf = { "crop", "fit" } },
	bgSequence = { kind = "string", max = 1200 },
	bgVideo = { kind = "string", max = 400 },
	bgFps = { kind = "number", min = 1, max = 30 },
	bgCols = { kind = "int", min = 1, max = 16 },
	bgRows = { kind = "int", min = 1, max = 16 },
	glass = { kind = "number", min = 0, max = 0.6 },
	overlay = { kind = "number", min = 0, max = 0.9 },
	blur = { kind = "bool" },
	splash = { kind = "bool" },
	splashSound = { kind = "bool" },
	favorites = { kind = "idlist", max = 60 },
	bundleFavorites = { kind = "bundlelist", max = 60 },
	scriptFavorites = { kind = "strlist", max = 120 },
	lastTarget = { kind = "string", max = 40 },
	lastBundle = { kind = "string", max = 60 },
	logoX = { kind = "number", min = -1, max = 1 },
	logoY = { kind = "number", min = -1, max = 1 },
	accentMotion = { kind = "string", max = 12, oneOf = { "still", "breathe", "drift", "spectrum" } },
	accentSpeed = { kind = "number", min = 0.5, max = 2 },
	customH = { kind = "int", min = 0, max = 360 },
	customS = { kind = "int", min = 0, max = 100 },
	customD = { kind = "int", min = 1, max = 14 },
	customO = { kind = "int", min = -90, max = 90 },
	textSize = { kind = "int", min = 80, max = 130 },
	layerSparkle = { kind = "bool" },
	layerSweep = { kind = "bool" },
	layerVignette = { kind = "bool" },
	layerRim = { kind = "bool" },
	parallax = { kind = "string", max = 8, oneOf = { "off", "touch" } },
	parallaxAmount = { kind = "int", min = 0, max = 100 },
	notifySeconds = { kind = "int", min = 2, max = 12 },
	keepErrors = { kind = "bool" },
	splashCamera = { kind = "bool" },
	splashBlur = { kind = "bool" },
	bgFrames = { kind = "int", min = 0, max = 256 },
	preset = { kind = "string", max = 32 },
	displayFont = { kind = "string", max = 32 },
	editBase = { kind = "string", max = 32 },
	editColors = { kind = "string", max = 200 },
	musicVolume = { kind = "number", min = 0, max = 1 },
	musicRepeat = { kind = "string", max = 8, oneOf = { "all", "one", "off" } },
	musicShuffle = { kind = "bool" },
	musicHideBad = { kind = "bool" },
	musicLast = { kind = "string", max = 20 },
	musicCustom = { kind = "strlist", max = 30 },
	musicLinks = { kind = "linklist", max = 40 },
	musicBad = { kind = "strlist", max = 400 },
	scriptAutoSwitch = { kind = "bool" },
	scriptRestore = { kind = "bool" },
	scriptSandbox = { kind = "bool" },
	scriptPlain = { kind = "strlist", max = 60 },
}

Store.data = Util.deepCopy(Store.defaults)
Store.listeners = {}
Store.persistent = false
Store.unreadable = nil -- set by Store.load() when config.json exists but cannot be parsed
Store.lastSaveOk = nil
Store.lastError = nil

function Store.clean(key, value)
	local rule = Store.rules[key]
	if not rule then
		return nil
	end
	local kind = rule.kind
	if kind == "bool" then
		if type(value) == "boolean" then
			return value
		end
		return nil
	elseif kind == "int" or kind == "number" then
		if type(value) ~= "number" or value ~= value then
			return nil
		end
		if kind == "int" then
			value = math.floor(value + 0.5)
		end
		return Util.clamp(value, rule.min, rule.max)
	elseif kind == "string" then
		if type(value) ~= "string" then
			return nil
		end
		if #value > (rule.max or 256) then
			value = string.sub(value, 1, rule.max or 256)
		end
		if rule.oneOf and not Util.indexOf(rule.oneOf, value) then
			return nil
		end
		return value
	elseif kind == "idlist" then
		if type(value) ~= "table" then
			return nil
		end
		local out, seen = {}, {}
		for _, id in ipairs(value) do
			if type(id) == "number" and id == math.floor(id) and id > 0 and id < 1e12 and not seen[id] then
				out[#out + 1] = id
				seen[id] = true
				if #out >= (rule.max or 60) then
					break
				end
			end
		end
		return out
	elseif kind == "strlist" then
		if type(value) ~= "table" then
			return nil
		end
		local out, seen = {}, {}
		for _, id in ipairs(value) do
			if type(id) == "string" and #id >= 1 and #id <= 40 and string.match(id, "^[a-z0-9][a-z0-9%-]*$") and not seen[id] then
				out[#out + 1] = id
				seen[id] = true
				if #out >= (rule.max or 60) then
					break
				end
			end
		end
		return out
	elseif kind == "linklist" then
		-- links to audio files: { id, url, title }. The id is always worked out from the link ("w" + its hash), never trusted from the file.
		if type(value) ~= "table" then
			return nil
		end
		local out, seen = {}, {}
		for _, row in ipairs(value) do
			if type(row) == "table" and type(row.url) == "string" and #row.url >= 8 and #row.url <= 400
				and string.match(row.url, "^https?://[%w%-%._~:/%?#%[%]@!%$&'%(%)%*%+,;=%%]+$") then
				local id = "w" .. Util.hash(row.url)
				if not seen[id] then
					local title = type(row.title) == "string" and string.sub(row.title, 1, 80) or ""
					out[#out + 1] = { id = id, url = row.url, title = title }
					seen[id] = true
					if #out >= (rule.max or 40) then
						break
					end
				end
			end
		end
		return out
	elseif kind == "bundlelist" then
		-- favourite bundles: { id, name, kind }. The id is kept as a string of digits (a 14-digit id is exact that way, no float
		-- or exponent surprises in the JSON file); name and kind are only labels for the list.
		if type(value) ~= "table" then
			return nil
		end
		local out, seen = {}, {}
		for _, row in ipairs(value) do
			if type(row) == "table" then
				local id = row.id
				if type(id) == "number" and id == math.floor(id) and id > 0 and id < 1e15 then
					id = string.format("%d", id)
				end
				if type(id) == "string" and #id >= 1 and #id <= 15 and string.match(id, "^[1-9]%d*$") and not seen[id] then
					local name = type(row.name) == "string" and string.sub(row.name, 1, 80) or ""
					local label = type(row.kind) == "string" and string.sub(row.kind, 1, 24) or ""
					out[#out + 1] = { id = id, name = name, kind = label }
					seen[id] = true
					if #out >= (rule.max or 60) then
						break
					end
				end
			end
		end
		return out
	end
	return nil
end

function Store.get(key)
	return Store.data[key]
end

function Store.on(key, fn)
	local list = Store.listeners[key]
	if not list then
		list = {}
		Store.listeners[key] = list
	end
	list[#list + 1] = fn
	return function()
		local current = Store.listeners[key]
		if current then
			local index = Util.indexOf(current, fn)
			if index then
				table.remove(current, index)
			end
		end
	end
end

local function fireStore(key, new, old)
	local list = Store.listeners[key]
	if not list then
		return
	end
	local snapshot = {}
	for i = 1, #list do
		snapshot[i] = list[i]
	end
	for i = 1, #snapshot do
		Util.try("store listener " .. key, snapshot[i], new, old)
	end
end

function Store.set(key, value, silent)
	local clean = Store.clean(key, value)
	if clean == nil then
		return false
	end
	local old = Store.data[key]
	Store.data[key] = clean
	if not silent then
		fireStore(key, clean, old)
	end
	Store.queueSave()
	return true
end

function Store.queueSave()
	if not Store.persistent or Store.saveToken then
		return
	end
	Store.saveToken = task.delay(0.8, function()
		Store.saveToken = nil
		Store.save()
	end)
end

function Store.save()
	if not Env.canSave() then
		Store.lastSaveOk = false
		Store.lastError = "file access unavailable"
		return false
	end
	local text, encodeError = Util.jsonEncode(Store.data)
	if not text then
		Store.lastSaveOk, Store.lastError = false, tostring(encodeError)
		return false
	end
	Env.ensureFolder(CONFIG.Folder)
	local ok, err = Env.writeFile(CONFIG.ConfigFile, text)
	Store.lastSaveOk, Store.lastError = ok, err
	return ok
end

function Store.flush()
	if Store.saveToken then
		pcall(task.cancel, Store.saveToken)
		Store.saveToken = nil
	end
	if Store.persistent then
		Store.save()
	end
end

function Store.load()
	Store.data = Util.deepCopy(Store.defaults)
	Store.loadedFromFile = false
	Store.unreadable = nil
	local text = Env.readFile(CONFIG.ConfigFile)
	if text then
		local decoded = Util.jsonDecode(text)
		if type(decoded) == "table" then
			for key in pairs(Store.defaults) do
				local clean = Store.clean(key, decoded[key])
				if clean ~= nil then
					Store.data[key] = clean
				end
			end
			Store.loadedFromFile = true
		else
			Util.log("warn", "config.json could not be parsed; defaults are in use")
			Store.unreadableConfig = text -- a copy is kept next to it before the defaults overwrite it (see below)
			Store.unreadable = "left"     -- until proven otherwise nothing touches the unreadable file
		end
	end

	Store.persistent = Env.canSave()
	if Store.persistent then
		Env.ensureFolder(CONFIG.Folder)
		local copyKept = false
		if Store.unreadableConfig then
			copyKept = Env.writeFile(CONFIG.Folder .. "/config.unreadable.json", Store.unreadableConfig) == true
			Util.log("info", copyKept and "kept the unreadable config as config.unreadable.json" or "could not keep a copy of the unreadable config")
			Store.unreadableConfig = nil
		end
		Store.persistent = Store.save() == true
		if Store.unreadable then
			-- "kept": a copy sits next to the new file | "replaced": no copy, but the broken file was overwritten | "left": nothing was written
			Store.unreadable = copyKept and "kept" or (Store.persistent and "replaced" or "left")
		end
	end
	return Store.data
end

-- restores every preference except the favourites (avatar, bundle and script) / last target
function Store.reset()
	for key, default in pairs(Store.defaults) do
		if key ~= "favorites" and key ~= "bundleFavorites" and key ~= "scriptFavorites" and key ~= "lastTarget" and key ~= "lastBundle" and key ~= "version" then
			Store.set(key, Util.deepCopy(default))
		end
	end
end


----------------------------------------------------------------------------------------------------
-- Icons: REAL Lucide icons (image based) instead of icons drawn from Frames.
--   The names used by the interface ("grid", "gear", "close" ...) are mapped to Lucide names below. The Lucide data is read
--   once at start-up from a Lucide icon pack for Roblox (CONFIG.Icons.Source, a script that returns a table with Icon(name)).
--   You can also hand over your own images:  CONFIG.Icons = { Map = { gear = "rbxassetid://123" }, Resolver = function(lucideName) ... end }
--   An icon whose image cannot be found is drawn from frames as a fallback, so the interface never loses a symbol.
--   The brand mark "logo" is not an icon: it stays the vector V of the hub.
----------------------------------------------------------------------------------------------------
local Icons = { ready = false, lib = nil, cache = {}, map = {}, source = nil, status = "not started", resolved = 0, missing = {} }

Icons.NAMES = {
	grid = "layout-grid", user = "user", sparkle = "sparkles", image = "image", sliders = "sliders-horizontal", gear = "settings",
	close = "x", minus = "minus", plus = "plus", restore = "square", chevron = "chevron-down", check = "check", bang = "circle-alert",
	info = "info", dots = "ellipsis", scripts = "code-xml", search = "search", eye = "eye", copy = "copy", home = "house",
	server = "server", bell = "bell", star = "star", play = "play", music = "music", mplay = "play", pause = "pause",
	next = "skip-forward", prev = "skip-back", shuffle = "shuffle", loop = "repeat", palette = "palette", drop = "droplet",
	target = "target", arrow = "arrow-right", sound = "volume-2", layers = "layers", bolt = "zap", clock = "clock", reset = "rotate-ccw",
}

Icons.SOURCE = "https://raw.githubusercontent.com/Footagesus/Icons/main/Main.lua"

local function asVector(v)
	if typeof(v) == "Vector2" then
		return v
	end
	if type(v) == "table" then
		local x, y = tonumber(v.X or v.x or v[1]), tonumber(v.Y or v.y or v[2])
		if x and y then
			return Vector2.new(x, y)
		end
	end
	return nil
end

-- whatever an icon pack hands back -> { Image, Size, Position } or nil
local function normalize(data)
	if type(data) == "string" or type(data) == "number" then
		local id = tostring(data)
		if not string.find(id, "rbxasset", 1, true) and string.match(id, "^%d+$") then
			id = "rbxassetid://" .. id
		end
		return { Image = id }
	end
	if type(data) ~= "table" then
		return nil
	end
	local image = data.Image or data.image or data.Id or data.id or data[1]
	local meta = data
	if type(data[2]) == "table" then
		meta = data[2]
	end
	if type(image) == "table" then
		meta = image
		image = image.Image or image.image or image[1]
	end
	if type(image) == "number" then
		image = "rbxassetid://" .. tostring(image)
	end
	if type(image) ~= "string" or image == "" then
		return nil
	end
	return {
		Image = image,
		Size = asVector(meta.ImageRectSize or meta.Size or meta.size),
		Position = asVector(meta.ImageRectPosition or meta.ImageRectOffset or meta.Position or meta.position or meta.Offset),
	}
end

function Icons.init()
	if Icons.ready then
		return Icons
	end
	Icons.ready = true
	local cfg = type(CONFIG.Icons) == "table" and CONFIG.Icons or {}
	Icons.map = type(cfg.Map) == "table" and cfg.Map or {}
	Icons.resolver = type(cfg.Resolver) == "function" and cfg.Resolver or nil
	local source = cfg.Source
	if source == nil then
		source = Icons.SOURCE
	end
	Icons.source = source
	if Icons.resolver or source == false or source == "" then
		Icons.status = Icons.resolver and "custom resolver" or "no Lucide source (drawn icons)"
		return Icons
	end
	-- the pack may be given as a ready table instead of a link
	if type(source) == "table" then
		Icons.lib = source
		Icons.status = "Lucide pack (table)"
		return Icons
	end
	local fetched = nil
	local done = false
	task.spawn(function()
		local body, err = Env.httpGet(source)
		if not body then
			local ok, res = pcall(function()
				return game:HttpGet(source)
			end)
			if ok and type(res) == "string" then
				body = res
			else
				Icons.status = "download failed: " .. tostring(err)
			end
		end
		if body then
			local chunk, compileError = Env.compile(body, "=LucideIcons")
			if chunk then
				local ok, lib = pcall(chunk)
				if ok and type(lib) == "table" then
					fetched = lib
				else
					Icons.status = "pack failed to run: " .. tostring(lib)
				end
			else
				Icons.status = "pack failed to compile: " .. tostring(compileError)
			end
		end
		done = true
	end)
	local started = os.clock()
	local limit = tonumber(cfg.Timeout) or 8
	while not done and os.clock() - started < limit do
		task.wait(0.05)
	end
	if fetched then
		Icons.lib = fetched
		pcall(function()
			if type(fetched.SetIconsType) == "function" then
				fetched.SetIconsType("lucide")
			end
		end)
		Icons.status = "Lucide pack loaded"
	elseif not done then
		Icons.status = "download timed out"
	end
	if not Icons.lib then
		Util.log("warn", "icons: " .. Icons.status .. " - drawn icons are used")
	end
	return Icons
end

-- name used by the interface -> { Image, Size, Position } or nil (then the drawn fallback is used)
function Icons.resolve(name)
	if name == nil or name == "logo" then
		return nil
	end
	local cached = Icons.cache[name]
	if cached ~= nil then
		return cached or nil
	end
	local lucide = Icons.NAMES[name] or name
	local found = nil
	if Icons.map[name] ~= nil then
		found = normalize(Icons.map[name])
	elseif Icons.map[lucide] ~= nil then
		found = normalize(Icons.map[lucide])
	end
	if not found and Icons.resolver then
		local ok, data = pcall(Icons.resolver, lucide, name)
		if ok then
			found = normalize(data)
		end
	end
	local lib = Icons.lib
	if not found and lib then
		local tries = {
			function() return lib.Icon(lucide) end,
			function() return lib.Icon(lucide, "lucide") end,
			function() return lib.GetIcon(lucide) end,
			function() return lib.Get(lucide) end,
			function() return lib[lucide] end,
			function() return lib.Icons and lib.Icons[lucide] end,
			function() return lib.Icons and lib.Icons.lucide and lib.Icons.lucide[lucide] end,
		}
		for _, attempt in ipairs(tries) do
			local ok, data = pcall(attempt)
			if ok and data ~= nil then
				found = normalize(data)
				if found then
					break
				end
			end
		end
	end
	if found then
		Icons.resolved = Icons.resolved + 1
	else
		Icons.missing[#Icons.missing + 1] = name
	end
	Icons.cache[name] = found or false
	return found
end

function Icons.summary()
	return string.format("%s | %d resolved, %d drawn instead", Icons.status, Icons.resolved, #Icons.missing)
end


do -- [02_motion_typo.lua]

----------------------------------------------------------------------------------------------------
-- Anim: one shared Heartbeat driver. Jobs can be throttled (hz) and gated (e.g. only while visible).
----------------------------------------------------------------------------------------------------
Anim.jobs = {}
Anim.byName = {}
Anim.conn = nil
Anim.seq = 0

function Anim.nextId()
	Anim.seq = Anim.seq + 1
	return Anim.seq
end

local function animStep(dt)
	local jobs = Anim.jobs
	local count = #jobs
	local now = os.clock()
	local anyDead = false
	for i = 1, count do
		local job = jobs[i]
		if job.dead then
			anyDead = true
		else
			job.acc = job.acc + dt
			if job.acc >= job.interval then
				local elapsed = job.acc
				job.acc = 0
				if job.gate == nil or job.gate() then
					local ok, err = pcall(job.fn, elapsed, now)
					if not ok then
						job.dead = true
						anyDead = true
						if Anim.byName[job.name] == job then
							Anim.byName[job.name] = nil
						end
						Util.log("error", "anim job '" .. job.name .. "' stopped: " .. tostring(err))
					end
				end
			end
		end
	end
	if anyDead then
		local alive = {}
		for i = 1, #jobs do
			if not jobs[i].dead then
				alive[#alive + 1] = jobs[i]
			end
		end
		Anim.jobs = alive
	end
	if #Anim.jobs == 0 then
		Anim.stop()
	end
end

function Anim.start()
	if not Anim.conn then
		Anim.conn = RunService.Heartbeat:Connect(animStep)
	end
end

function Anim.stop()
	if Anim.conn then
		Anim.conn:Disconnect()
		Anim.conn = nil
	end
end

-- fn(dt, now). hz = maximum calls per second (nil = every frame). gate() = false skips the call.
function Anim.add(name, fn, hz, gate)
	local existing = Anim.byName[name]
	if existing and not existing.dead then
		existing.fn = fn
		existing.interval = hz and (1 / hz) or 0
		existing.gate = gate
		return existing
	end
	local job = { name = name, fn = fn, interval = hz and (1 / hz) or 0, acc = 0, gate = gate, dead = false }
	Anim.jobs[#Anim.jobs + 1] = job
	Anim.byName[name] = job
	Anim.start()
	return job
end

function Anim.remove(name)
	local job = Anim.byName[name]
	if job then
		job.dead = true
		Anim.byName[name] = nil
	end
end

function Anim.has(name)
	local job = Anim.byName[name]
	return job ~= nil and not job.dead
end

function Anim.stopAll()
	for _, job in ipairs(Anim.jobs) do
		job.dead = true
	end
	Anim.jobs = {}
	Anim.byName = {}
	Anim.stop()
end

----------------------------------------------------------------------------------------------------
-- Motion: tweens with per-(object, property) cancellation, reduced-motion support, easing library
----------------------------------------------------------------------------------------------------
Motion.reduced = false
Motion.fast, Motion.base, Motion.slow = 0.12, 0.2, 0.34
Motion.style = Enum.EasingStyle.Quart
Motion.dir = Enum.EasingDirection.Out

Motion.ease = {
	linear = function(t) return t end,
	outQuad = function(t) return 1 - (1 - t) * (1 - t) end,
	outCubic = function(t)
		local u = 1 - t
		return 1 - u * u * u
	end,
	outQuart = function(t)
		local u = 1 - t
		return 1 - u * u * u * u
	end,
	inOutSine = function(t) return -(math.cos(math.pi * t) - 1) / 2 end,
	inOutCubic = function(t)
		if t < 0.5 then
			return 4 * t * t * t
		end
		local u = -2 * t + 2
		return 1 - u * u * u / 2
	end,
	outBack = function(t)
		local u = t - 1
		return 1 + 2.70158 * u * u * u + 1.70158 * u * u
	end,
	outQuint = function(t)
		local u = 1 - t
		return 1 - u * u * u * u * u
	end,
	inQuad = function(t) return t * t end,
	inQuint = function(t) return t * t * t * t * t end,
	outExpo = function(t)
		if t >= 1 then
			return 1
		end
		return 1 - 2 ^ (-10 * t)
	end,
	inExpo = function(t)
		if t <= 0 then
			return 0
		end
		return 2 ^ (10 * t - 10)
	end,
	inOutQuint = function(t)
		if t < 0.5 then
			return 16 * t * t * t * t * t
		end
		local u = -2 * t + 2
		return 1 - u * u * u * u * u / 2
	end,
	outSine = function(t) return math.sin(t * math.pi / 2) end,
	outElastic = function(t)
		if t <= 0 then
			return 0
		elseif t >= 1 then
			return 1
		end
		return 2 ^ (-10 * t) * math.sin((t * 10 - 0.75) * (2 * math.pi / 3)) + 1
	end,
	-- a damped spring: it overshoots a little (about 6%) and settles at 1. The "liquid" feel of the glass controls.
	spring = function(t)
		if t <= 0 then
			return 0
		elseif t >= 1 then
			return 1
		end
		return 1 - math.exp(-9 * t) * math.cos(10.4 * t)
	end,
	-- the same, softer and slower to settle (a drop landing)
	springSoft = function(t)
		if t <= 0 then
			return 0
		elseif t >= 1 then
			return 1
		end
		return 1 - math.exp(-6.5 * t) * math.cos(9 * t)
	end,
}

local activeTweens = setmetatable({}, { __mode = "k" }) -- obj -> { [prop] = { tween, group } }

local function cancelProps(obj, props)
	local entry = activeTweens[obj]
	if not entry then
		return
	end
	local function cancelRecord(key)
		local record = entry[key]
		if record then
			entry[key] = nil
			record.group.dead = true
			pcall(record.tween.Cancel, record.tween)
		end
	end
	if props then
		for key in pairs(props) do
			cancelRecord(key)
		end
	else
		for key in pairs(Util.copy(entry)) do
			cancelRecord(key)
		end
	end
end

function Motion.cancel(obj, props)
	cancelProps(obj, props)
end

-- instant assignment that also cancels any running tween on those properties
function Motion.set(obj, props)
	cancelProps(obj, props)
	for key, value in pairs(props) do
		pcall(function()
			obj[key] = value
		end)
	end
end

-- Animates `props` on `obj`. A newer call for the same property replaces the older tween.
-- onDone() runs once when every property finished (not when interrupted).
function Motion.tween(obj, props, duration, style, direction, onDone)
	if obj == nil then
		return nil
	end
	duration = duration or Motion.base
	cancelProps(obj, props)
	if Motion.reduced or duration <= 0 then
		for key, value in pairs(props) do
			pcall(function()
				obj[key] = value
			end)
		end
		if onDone then
			onDone()
		end
		return nil
	end

	local info = TweenInfo.new(duration, style or Motion.style, direction or Motion.dir)
	local entry = activeTweens[obj]
	if not entry then
		entry = {}
		activeTweens[obj] = entry
	end

	local keys = {}
	for key in pairs(props) do
		keys[#keys + 1] = key
	end
	local group = { remaining = #keys, dead = false }
	local lastTween = nil

	for _, key in ipairs(keys) do
		local ok, tween = pcall(TweenService.Create, TweenService, obj, info, { [key] = props[key] })
		if ok and tween then
			local record = { tween = tween, group = group }
			entry[key] = record
			local connection = nil
			connection = tween.Completed:Connect(function()
				if connection then
					connection:Disconnect()
				end
				if entry[key] == record then
					entry[key] = nil
				end
				if group.dead then
					return
				end
				group.remaining = group.remaining - 1
				if group.remaining <= 0 then
					group.dead = true
					if onDone then
						onDone()
					end
				end
			end)
			tween:Play()
			lastTween = tween
		else
			group.remaining = group.remaining - 1
			pcall(function()
				obj[key] = props[key]
			end)
		end
	end

	if group.remaining <= 0 and not group.dead then
		group.dead = true
		if onDone then
			onDone()
		end
	end
	return lastTween
end

-- Frame-driven animation for things TweenService cannot express (counters, driven gradients ...)
-- step(alpha 0..1 eased). Returns a handle with :Cancel().
function Motion.run(duration, step, easeFn, onDone)
	local handle = { cancelled = false }
	function handle.Cancel()
		handle.cancelled = true
	end
	if Motion.reduced or duration <= 0 then
		step(1)
		if onDone then
			onDone()
		end
		return handle
	end
	easeFn = easeFn or Motion.ease.outCubic
	local started = os.clock()
	local name = "run" .. tostring(Anim.nextId())
	Anim.add(name, function()
		if handle.cancelled then
			Anim.remove(name)
			return
		end
		local a = (os.clock() - started) / duration
		if a >= 1 then
			Anim.remove(name)
			step(1)
			if onDone then
				onDone()
			end
			return
		end
		step(easeFn(a))
	end)
	return handle
end

----------------------------------------------------------------------------------------------------
-- Typo: every text object gets its font through a role, so fonts can change in one place
----------------------------------------------------------------------------------------------------
Typo.roles = {
	display = { size = 30, weight = "bold" },
	title = { size = 20, weight = "bold" },
	heading = { size = 14, weight = "medium" },
	body = { size = 12, weight = "regular", lineHeight = 1.12 },
	caption = { size = 11, weight = "regular", lineHeight = 1.12 },
	label = { size = 11, weight = "bold" },
	button = { size = 13, weight = "medium" },
	buttonSmall = { size = 12, weight = "medium" },
	tab = { size = 13, weight = "medium" },
	stat = { size = 18, weight = "bold" },
	section = { size = 14, weight = "bold" },
}

Typo.families = {}
Typo.order = {}
Typo.family = nil
Typo.registry = {} -- strong on purpose: Roblox may drop Lua wrappers of live instances; Typo.prune() cleans dead ones
Typo.faceSupported = false
Typo.scale = 1       -- Appearance > Text size: 0.8 .. 1.3 (text only; the window and the buttons keep their size)
Typo.legacy = false  -- true while the loading screen is built: it keeps the original one-font, unscaled behaviour
-- the roles that use a family's heading face (`display`) when it has one
Typo.displayRoles = { display = true, title = true, heading = true, stat = true, section = true }
-- Display font (Appearance > Customize > Fonts, from Vyre hub v2): one decorative font for the big text. It beats the heading face of
-- a Type pair, and the body text keeps the chosen family. Typo.setDisplay("LuckiestGuy") / Typo.setDisplay("") switches it live.
Typo.display = nil -- { id = "LuckiestGuy", font = Enum.Font.LuckiestGuy, scale = 1 } or nil
Typo.overrideRoles = { display = true, title = true, heading = true, tab = true, stat = true, section = true }

local function enumFont(name, fallback)
	local ok, value = pcall(function()
		return Enum.Font[name]
	end)
	if ok and value then
		return value
	end
	return fallback
end

local function fontWeight(weight)
	local names = { regular = "Regular", medium = "Medium", bold = "Bold" }
	local ok, value = pcall(function()
		return Enum.FontWeight[names[weight] or "Regular"]
	end)
	if ok then
		return value
	end
	return nil
end

function Typo.init()
	Typo.families, Typo.order = {}, {}
	Typo.faceSupported = pcall(function()
		return Font.new("rbxasset://fonts/families/GothamSSm.json")
	end)
	for _, def in ipairs(CONFIG.Fonts.Families) do
		local family = {
			id = def.id, name = def.name, face = def.face, sub = def.sub, pair = def.pair == true, dscale = def.dscale or 1,
		}
		if def.enum then
			family.regular = enumFont(def.enum.regular, nil)
			family.medium = enumFont(def.enum.medium, family.regular)
			family.bold = enumFont(def.enum.bold, family.medium or family.regular)
		end
		if def.display and family.regular then
			local display = { regular = enumFont(def.display.regular, nil) }
			display.medium = enumFont(def.display.medium, display.regular)
			display.bold = enumFont(def.display.bold, display.medium or display.regular)
			if display.regular then
				family.display = display
			end
		end
		if family.regular or (family.face and Typo.faceSupported) then
			Typo.families[def.id] = family
			Typo.order[#Typo.order + 1] = def.id
		else
			Util.log("warn", "font family '" .. tostring(def.id) .. "' is not available in this client")
		end
	end
	if not Typo.families.gotham then
		local fallback = { id = "gotham", name = "Gotham", dscale = 1, regular = Enum.Font.Gotham, medium = Enum.Font.GothamMedium, bold = Enum.Font.GothamBold }
		Typo.families.gotham = fallback
		table.insert(Typo.order, 1, "gotham")
	end
	Typo.family = Typo.families[Store.get("font")] or Typo.families[CONFIG.Fonts.Default] or Typo.families.gotham
	Typo.scale = Util.clamp((Store.get("textSize") or 100) / 100, 0.8, 1.3)
	Typo.display = nil
	Typo.setDisplay(Store.get("displayFont"), true)
	return Typo
end

-- one text object: its font for the weight (the heading face for display roles), and TextSize with the text-size
-- setting and the family's heading factor applied. `legacy` = the loading screen: the original behaviour, untouched.
function Typo.assign(obj, weight, size, display, legacy, role)
	local family = Typo.family
	local override = (not legacy) and role and Typo.overrideRoles[role] and Typo.display
	if override then
		local ok = pcall(function()
			obj.Font = override.font
		end)
		if ok then
			if size then
				obj.TextSize = math.max(8, math.floor(size * Typo.scale * override.scale + 0.5))
			end
			return
		end
	end
	local set = family
	if display and not legacy and family.display then
		set = family.display
	end
	local done = false
	if set.face and Typo.faceSupported then
		local ok = pcall(function()
			obj.FontFace = Font.new(set.face, fontWeight(weight))
		end)
		done = ok
	end
	if not done then
		local base = Typo.families.gotham
		obj.Font = set[weight] or set.regular or family[weight] or family.regular or base[weight] or Enum.Font.Gotham
	end
	if size then
		if legacy then
			obj.TextSize = size
		else
			local factor = Typo.scale
			if set ~= family then
				factor = factor * (family.dscale or 1)
			end
			obj.TextSize = math.max(8, math.floor(size * factor + 0.5))
		end
	end
end

-- One text object in a chosen family, for the font previews. It is not tracked: it keeps that font when the family setting
-- changes, and it ignores the text-size setting (a preview is a picture). display = use the family's heading face.
function Typo.sample(obj, id, weight, size, display)
	local family = Typo.families[id] or Typo.family
	local set = family
	if display and family.display then
		set = family.display
	end
	local done = false
	if set.face and Typo.faceSupported then
		done = pcall(function()
			obj.FontFace = Font.new(set.face, fontWeight(weight))
		end)
	end
	if not done then
		local base = Typo.families.gotham
		obj.Font = set[weight] or set.regular or family[weight] or family.regular or base[weight] or Enum.Font.Gotham
	end
	if size then
		local factor = 1
		if set ~= family then
			factor = family.dscale or 1
		end
		obj.TextSize = math.max(8, math.floor(size * factor + 0.5))
	end
	obj.LineHeight = 1
	return obj
end

-- role: "display" | "title" | "heading" | "body" | "caption" | "label" | "button" | ...
function Typo.apply(obj, role, sizeOverride)
	local spec = Typo.roles[role] or Typo.roles.body
	local size = sizeOverride or spec.size
	local legacy = Typo.legacy
	Typo.registry[obj] = { role = role, size = size, legacy = legacy }
	Typo.assign(obj, spec.weight, size, Typo.displayRoles[role] == true, legacy, role)
	obj.LineHeight = spec.lineHeight or 1 -- a little air between wrapped lines of descriptive text
	return obj
end

-- writes font and size again on everything registered (a new family or text size). Loading-screen objects are skipped.
function Typo.refresh()
	for obj, info in pairs(Typo.registry) do
		if not info.legacy then
			local spec = Typo.roles[info.role] or Typo.roles.body
			pcall(Typo.assign, obj, spec.weight, info.size, Typo.displayRoles[info.role] == true, false, info.role)
		end
	end
end

function Typo.setFamily(id)
	local family = Typo.families[id]
	if not family then
		return false
	end
	Typo.family = family
	Typo.refresh()
	return true
end

-- percent: 80 .. 130
function Typo.setScale(percent)
	Typo.scale = Util.clamp((tonumber(percent) or 100) / 100, 0.8, 1.3)
	Typo.refresh()
end

-- name = an Enum.Font name from CONFIG.Fonts.Display ("" or an unknown name turns the display font off). quiet = do not refresh yet.
function Typo.setDisplay(name, quiet)
	local font = nil
	if type(name) == "string" and name ~= "" then
		font = enumFont(name, nil)
	end
	if font then
		local scales = CONFIG.Fonts.DisplayScale or {}
		Typo.display = { id = name, font = font, scale = tonumber(scales[name]) or 1 }
	else
		Typo.display = nil
	end
	if not quiet then
		Typo.refresh()
	end
	return Typo.display ~= nil
end

-- the fonts of CONFIG.Fonts.Display that this client really has
function Typo.displayList()
	local out = {}
	for _, name in ipairs(CONFIG.Fonts.Display or {}) do
		if enumFont(name, nil) then
			out[#out + 1] = name
		end
	end
	return out
end

function Typo.prune()
	for obj in pairs(Typo.registry) do
		if obj.Parent == nil then
			Typo.registry[obj] = nil
		end
	end
end

function Typo.list()
	local out = {}
	for _, id in ipairs(Typo.order) do
		out[#out + 1] = { id = id, label = Typo.families[id].name }
	end
	return out
end
end -- [02_motion_typo.lua]

do -- [03_theme.lua]

----------------------------------------------------------------------------------------------------
-- Theme: role-based palettes, live transitions, gradients and (optional) animated accents.
-- To add a theme, append one row to Theme.catalog. Only the roles you list are required:
--   Background, Panel, Card, Border, Accent, Text, Muted  (everything else is derived)
-- Optional roles: Accent2 (gradient partner), Shine (highlight), AccentSoft, Info ...
----------------------------------------------------------------------------------------------------
local function C(r, g, b)
	return Color3.fromRGB(r, g, b)
end

Theme.catalog = {
	-- the two palettes from the original VirexHub (Obsidian's accent is two steps lighter than before, so the dark text on it
	-- reaches the 4.5 : 1 contrast the built-in check asks for) ------------------------------------
	{ id = "obsidian", name = "Obsidian", group = "Classic", colors = {
		Background = C(12, 15, 22), Panel = C(19, 23, 33), Card = C(26, 31, 43), Border = C(48, 57, 75),
		Accent = C(114, 99, 255), Accent2 = C(168, 148, 255), Shine = C(226, 220, 255), AccentSoft = C(47, 42, 87),
		Text = C(240, 242, 249), Muted = C(153, 162, 180),
	} },
	{ id = "deepteal", name = "Deep Teal", group = "Classic", colors = {
		Background = C(11, 18, 23), Panel = C(17, 27, 34), Card = C(23, 37, 45), Border = C(42, 65, 71),
		Accent = C(48, 195, 177), Accent2 = C(104, 232, 214), Shine = C(206, 255, 247), AccentSoft = C(29, 67, 67),
		Text = C(237, 245, 245), Muted = C(149, 171, 175),
	} },
	-- premium metals -----------------------------------------------------------------------------
	{ id = "silver", name = "Silver", group = "Metals and gems", colors = {
		Background = C(13, 15, 19), Panel = C(20, 23, 29), Card = C(29, 33, 41), Border = C(62, 68, 80),
		Accent = C(206, 213, 226), Accent2 = C(146, 156, 176), Shine = C(255, 255, 255), AccentSoft = C(50, 55, 67),
		Text = C(238, 241, 246), Muted = C(150, 158, 172),
	} },
	{ id = "gold", name = "Gold", group = "Metals and gems", colors = {
		Background = C(15, 12, 7), Panel = C(23, 18, 10), Card = C(33, 26, 14), Border = C(78, 62, 30),
		Accent = C(230, 184, 78), Accent2 = C(176, 128, 38), Shine = C(255, 238, 176), AccentSoft = C(68, 52, 22),
		Text = C(248, 242, 228), Muted = C(178, 164, 132),
	} },
	{ id = "diamond", name = "Diamond", group = "Metals and gems", colors = {
		Background = C(5, 11, 22), Panel = C(10, 19, 33), Card = C(16, 29, 48), Border = C(36, 70, 104),
		Accent = C(96, 218, 255), Accent2 = C(36, 120, 214), Shine = C(235, 252, 255), AccentSoft = C(22, 56, 84),
		Text = C(236, 249, 255), Muted = C(138, 174, 196),
	} },
	{ id = "emerald", name = "Emerald", group = "Metals and gems", colors = {
		Background = C(6, 15, 11), Panel = C(10, 24, 18), Card = C(15, 34, 26), Border = C(32, 76, 56),
		Accent = C(46, 204, 140), Accent2 = C(16, 140, 96), Shine = C(176, 255, 214), AccentSoft = C(18, 58, 42),
		Text = C(233, 248, 240), Muted = C(136, 172, 152),
	} },
	-- two-colour combinations -------------------------------------------------------------------
	{ id = "gold_black", name = "Gold + Black", group = "Two-colour", colors = {
		Background = C(4, 4, 4), Panel = C(11, 10, 8), Card = C(19, 17, 13), Border = C(70, 56, 26),
		Accent = C(232, 182, 72), Accent2 = C(140, 104, 30), Shine = C(255, 232, 160), AccentSoft = C(52, 41, 17),
		Text = C(250, 245, 232), Muted = C(158, 148, 126),
	} },
	{ id = "silver_blue", name = "Silver + Blue", group = "Two-colour", colors = {
		Background = C(8, 12, 22), Panel = C(14, 20, 35), Card = C(21, 29, 50), Border = C(50, 68, 104),
		Accent = C(202, 212, 230), Accent2 = C(70, 120, 255), Shine = C(240, 246, 255), AccentSoft = C(28, 44, 88),
		Text = C(240, 244, 252), Muted = C(144, 160, 188), Info = C(110, 160, 255),
	} },
	{ id = "diamond_purple", name = "Diamond + Purple", group = "Two-colour", colors = {
		Background = C(10, 7, 22), Panel = C(17, 12, 35), Card = C(26, 18, 52), Border = C(70, 50, 116),
		Accent = C(176, 136, 255), Accent2 = C(120, 214, 255), Shine = C(232, 246, 255), AccentSoft = C(50, 34, 96),
		Text = C(242, 238, 252), Muted = C(158, 146, 190),
	} },
	{ id = "emerald_black", name = "Emerald + Black", group = "Two-colour", colors = {
		Background = C(3, 7, 5), Panel = C(8, 14, 11), Card = C(13, 22, 17), Border = C(28, 62, 46),
		Accent = C(44, 214, 132), Accent2 = C(14, 120, 80), Shine = C(150, 255, 204), AccentSoft = C(12, 46, 32),
		Text = C(232, 246, 238), Muted = C(128, 160, 142),
	} },
	-- 2.4.0: five more from the VYRE / NEXUS design (Ruby and Rose Gold join the metals and gems) -------
	{ id = "ruby", name = "Ruby", group = "Metals and gems", isNew = true, colors = {
		Background = C(16, 6, 9), Panel = C(26, 10, 15), Card = C(38, 15, 22), Border = C(88, 34, 48),
		Accent = C(240, 84, 106), Accent2 = C(168, 32, 60), Shine = C(255, 196, 206), AccentSoft = C(74, 24, 36),
		Text = C(252, 238, 240), Muted = C(186, 148, 156),
	} },
	{ id = "rosegold", name = "Rose Gold", group = "Metals and gems", isNew = true, colors = {
		Background = C(17, 11, 12), Panel = C(26, 17, 18), Card = C(37, 25, 26), Border = C(86, 60, 58),
		Accent = C(232, 160, 146), Accent2 = C(184, 110, 96), Shine = C(255, 226, 214), AccentSoft = C(70, 46, 44),
		Text = C(250, 240, 236), Muted = C(178, 156, 150),
	} },
	{ id = "onyx", name = "Onyx", group = "Special", isNew = true, sub = "OLED black", colors = {
		Background = C(0, 0, 0), Panel = C(8, 8, 10), Card = C(16, 16, 19), Border = C(44, 44, 52),
		Accent = C(232, 234, 240), Accent2 = C(140, 146, 160), Shine = C(255, 255, 255), AccentSoft = C(34, 34, 40),
		Text = C(244, 245, 248), Muted = C(148, 150, 160),
	} },
	{ id = "opal", name = "Opal", group = "Special", isNew = true, sub = "Suits Spectrum", suggest = "spectrum", colors = {
		Background = C(9, 10, 17), Panel = C(15, 17, 27), Card = C(22, 25, 39), Border = C(58, 64, 94),
		Accent = C(150, 206, 255), Accent2 = C(255, 170, 214), Shine = C(246, 250, 255), AccentSoft = C(44, 48, 82),
		Text = C(240, 243, 252), Muted = C(150, 158, 186),
	} },
	-- the first light theme. Its status colours are darker (see Theme.define) and its highlight is the accent
	{ id = "pearl", name = "Pearl", group = "Special", isNew = true, sub = "Light theme", light = true, colors = {
		Background = C(236, 239, 246), Panel = C(244, 246, 251), Card = C(255, 255, 255), Border = C(204, 210, 224),
		Accent = C(72, 92, 214), Accent2 = C(122, 148, 255), Shine = C(255, 255, 255), AccentSoft = C(222, 228, 252),
		Text = C(22, 26, 40), Muted = C(88, 98, 120),
	} },
	-- 2.8.0: the charcoal-and-green look of the Nexone Spotibai skin (colours only; that zip carries no music of its own)
	{ id = "spotibai", name = "Spotibai", group = "Special", isNew = true, sub = "Spotify look", colors = {
		Background = C(9, 9, 9), Panel = C(18, 18, 18), Card = C(27, 27, 27), Border = C(46, 46, 46),
		Accent = C(34, 186, 84), Accent2 = C(30, 215, 96), Shine = C(172, 255, 204), AccentSoft = C(18, 58, 34),
		Text = C(242, 242, 242), Muted = C(158, 158, 162),
	} },
}

-- Vyre presets (CONFIG.Presets, from Vyre hub v2): every preset also becomes a colour theme "vy_<name>". Appearance > Customize applies a
-- preset's background and its theme together; the theme shelves do not list them (group "Vyre").
function Theme.presetId(p)
	return "vy_" .. string.lower((string.gsub(tostring(p.Name), "[^%w]", "")))
end

function Theme.presetColors(p)
	local accent = p.Accent or C(235, 236, 240)
	local accent2 = p.Accent2 or accent
	local panel = p.Panel or C(9, 9, 11)
	local card = p.Card or C(20, 20, 24)
	local card2 = p.Card2 or card
	-- text on the accent: the usual near-black / near-white, or pure black / white when a saturated blue or violet needs the
	-- extra contrast (the readability audit asks for 4.5)
	local on = Util.onColor(accent)
	if Util.contrast(on, accent) < 4.6 then
		on = Util.onColor(accent, C(0, 0, 0), C(255, 255, 255))
	end
	return {
		OnAccent = on,
		Background = panel,
		Panel = Util.mix(panel, card, 0.5),
		Card = card,
		Border = Util.mix(card2, accent, 0.2),
		Accent = accent,
		Accent2 = accent2,
		Shine = Util.mix(accent2, Color3.new(1, 1, 1), 0.45),
		AccentSoft = Util.mix(card, accent, 0.3),
		Text = C(244, 247, 252),
		Muted = C(150, 158, 178),
		Info = p.Hot or accent,
	}
end

for _, preset in ipairs(CONFIG.Presets or {}) do
	Theme.catalog[#Theme.catalog + 1] = { id = Theme.presetId(preset), name = tostring(preset.Name), group = "Vyre", colors = Theme.presetColors(preset) }
end

Theme.defs = {}
Theme.byId = {}
Theme.cur = {}   -- the palette of the chosen theme while it crossfades (no colour motion in it)
Theme.live = {}  -- the colours the interface really shows: Theme.cur plus colour motion on the accent roles
Theme.target = nil
Theme.id = nil
Theme.light = false -- true while a light theme (Pearl) is on: highlights use the accent instead of white
Theme.glass = 0
Theme.fxLevel = 0
Theme.listeners = {}
Theme.active = function()
	return true
end

-- These registries are strong on purpose (Roblox can drop the Lua wrapper of a live Instance, which
-- would silently unbind a weak key). Theme.prune() removes entries whose instance was destroyed.
local boundProps = {}    -- inst -> { [prop] = {role, mixRole, mixT} }
local accentProps = {}   -- inst -> { [prop] = true } for the bindings that colour motion has to rewrite
local alphaProps = {}    -- inst -> { kind }
local gradientBinds = {} -- UIGradient -> builder(live) -> ColorSequence
local gradientStatic = {} -- UIGradient -> true when the builder does not use any accent role
local fxItems = {}

-- the five roles colour motion moves. Everything bound to one of them is also listed in accentProps.
local ACCENT_ROLES = { Accent = true, Accent2 = true, Shine = true, AccentSoft = true, OnAccent = true }

local function isAccentBinding(role, mixRole)
	return ACCENT_ROLES[role] == true or (mixRole ~= nil and ACCENT_ROLES[mixRole] == true)
end

-- status colours keep at least 3.2:1 against the card, even on a bright custom palette
local function fitStatus(color, card, light)
	local h, s, l = Util.rgb2hsl(color)
	local out, n = color, 0
	while Util.contrast(out, card) < 3.2 and n < 30 do
		n = n + 1
		l = Util.clamp(l + (light and -0.02 or 0.02), 0, 1)
		out = Util.hsl2rgb(h, s, l)
	end
	return out
end

function Theme.define(spec)
	local c = Util.copy(spec.colors)
	local light = spec.light == true
	c.Accent2 = c.Accent2 or Util.lighten(c.Accent, 0.25)
	c.Shine = c.Shine or Util.lighten(c.Accent, 0.55)
	c.AccentSoft = c.AccentSoft or Util.mix(c.Card, c.Accent, 0.25)
	c.Elevated = c.Elevated or Util.mix(c.Card, c.Text, 0.06)
	c.Track = c.Track or Util.mix(c.Card, c.Text, 0.17)
	c.Faint = c.Faint or Util.mix(c.Muted, c.Card, 0.5)
	c.Danger = c.Danger or fitStatus(light and C(196, 44, 62) or C(235, 87, 99), c.Card, light)
	c.Green = c.Green or fitStatus(light and C(24, 142, 94) or C(78, 202, 146), c.Card, light)
	c.Warn = c.Warn or fitStatus(light and C(170, 104, 8) or C(240, 178, 74), c.Card, light)
	c.Info = c.Info or c.Accent
	c.OnAccent = c.OnAccent or Util.onColor(c.Accent)
	c.OnDanger = c.OnDanger or Util.onColor(c.Danger)
	c.Scrim = c.Scrim or C(0, 0, 0)
	local def = {
		id = spec.id, name = spec.name, group = spec.group or "Custom", colors = c,
		light = light, isNew = spec.isNew == true, sub = spec.sub, suggest = spec.suggest,
	}
	if Theme.byId[spec.id] then
		for i, existing in ipairs(Theme.defs) do
			if existing.id == spec.id then
				Theme.defs[i] = def
			end
		end
	else
		Theme.defs[#Theme.defs + 1] = def
	end
	Theme.byId[spec.id] = def
	return def
end

-- the themes grouped by their group name, in the order the groups first appear: { {name=, items={defs}} }
function Theme.groups()
	local out, byName = {}, {}
	for _, def in ipairs(Theme.defs) do
		local g = byName[def.group]
		if not g then
			g = { name = def.group, items = {} }
			byName[def.group] = g
			out[#out + 1] = g
		end
		g.items[#g.items + 1] = def
	end
	return out
end

----------------------------------------------------------------------------------------------------
-- Make your own: four sliders become a whole coherent palette (hue, colour strength, darkness and a
-- second-colour offset). The result is checked for contrast, and shared as a short code VX1-h-s-d-o.
----------------------------------------------------------------------------------------------------
function Theme.customColors(h, s, d, o)
	local sat = Util.clamp(s, 0, 100) / 100
	local dep = Util.clamp(d, 1, 14) / 100
	local bs = 0.22 + 0.38 * sat
	local hsl = Util.hsl2rgb
	local bg, panel = hsl(h, bs, dep), hsl(h, bs * 0.95, dep + 0.035)
	local card, border = hsl(h, bs * 0.9, dep + 0.07), hsl(h, bs * 0.65, dep + 0.17)
	-- the accent has to stand out from the card (3:1) and carry button text (4.5:1), so lift it until it does
	local aSat = 0.5 + 0.42 * sat
	local darkText = Util.mix(bg, Color3.new(0, 0, 0), 0.35)
	local white = Color3.new(1, 1, 1)
	local al = 0.64
	local accent = hsl(h, aSat, al)
	while (Util.contrast(accent, card) < 3.2 or math.max(Util.contrast(white, accent), Util.contrast(darkText, accent)) < 4.6) and al < 0.94 do
		al = al + 0.02
		accent = hsl(h, aSat, al)
	end
	local accent2, shine = hsl(h + o, aSat, 0.5), hsl(h + o / 2, 0.9, 0.91)
	local soft, text = Util.mix(card, accent, 0.3), hsl(h, 0.35, 0.95)
	local ml = 0.7
	local mSat = 0.16 + 0.12 * sat
	local muted = hsl(h, mSat, ml)
	while Util.contrast(muted, card) < 4.6 and ml < 0.9 do
		ml = ml + 0.02
		muted = hsl(h, mSat, ml)
	end
	return {
		Background = bg, Panel = panel, Card = card, Border = border, Accent = accent, Accent2 = accent2,
		Shine = shine, AccentSoft = soft, Text = text, Muted = muted,
	}
end

function Theme.customCode(h, s, d, o)
	return string.format("VX1-%d-%d-%d-%d", math.floor(h + 0.5), math.floor(s + 0.5), math.floor(d + 0.5), math.floor(o + 0.5))
end

-- "VX1-268-62-7-40" -> 268, 62, 7, 40 (all four numbers range-checked), or nil
function Theme.parseCode(text)
	if type(text) ~= "string" then
		return nil
	end
	local a, b, c, d = string.match(text, "^%s*[Vv][Xx]1%-(%d%d?%d?)%-(%d%d?%d?)%-(%d%d?)%-(%-?%d%d?)%s*$")
	if not a then
		return nil
	end
	local h, s, dd, o = tonumber(a), tonumber(b), tonumber(c), tonumber(d)
	if not (h and s and dd and o) or h > 360 or s > 100 or dd < 1 or dd > 14 or o < -90 or o > 90 then
		return nil
	end
	return h, s, dd, o
end

function Theme.customDef()
	return Theme.define({
		id = "custom", name = "Your theme", group = "Custom",
		colors = Theme.customColors(Store.get("customH"), Store.get("customS"), Store.get("customD"), Store.get("customO")),
	})
end

----------------------------------------------------------------------------------------------------
-- Colour editor (Appearance > Customize > Colors, from 2.6.0): the colours you change are kept as a theme called "edited".
-- Store.editBase is the theme they were made from, Store.editColors holds the changed roles ("Accent=ff3c5c;Card=1a1a1e").
-- It is separate from "Make your own" (id "custom", four sliders): that one builds a whole palette from a hue.
----------------------------------------------------------------------------------------------------
Theme.EDIT_ID = "edited"
Theme.editRoles = { "Accent", "Accent2", "Background", "Card", "Text" }

function Theme.parseEdits(text)
	local out = {}
	for role, hex in string.gmatch(text or "", "(%a+)=(%x%x%x%x%x%x)") do
		local r = tonumber(string.sub(hex, 1, 2), 16)
		local g = tonumber(string.sub(hex, 3, 4), 16)
		local b = tonumber(string.sub(hex, 5, 6), 16)
		if r and g and b and Util.indexOf(Theme.editRoles, role) then
			out[role] = Color3.fromRGB(r, g, b)
		end
	end
	return out
end

function Theme.encodeEdits(map)
	local parts = {}
	for _, role in ipairs(Theme.editRoles) do
		local c = map[role]
		if c then
			parts[#parts + 1] = string.format("%s=%02x%02x%02x", role, math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
		end
	end
	return table.concat(parts, ";")
end

-- builds (or rebuilds) the "edited" theme from editBase + editColors; returns nil when nothing is edited
function Theme.rebuildEdited()
	local overrides = Theme.parseEdits(Store.get("editColors"))
	if next(overrides) == nil then
		return nil
	end
	local base = Theme.byId[Store.get("editBase")]
	if not base or base.id == Theme.EDIT_ID then
		base = Theme.defs[1]
	end
	local colors = Util.copy(base.colors)
	-- roles that are worked out from the others are dropped so Theme.define derives them again from the new colours
	for _, role in ipairs({ "Elevated", "Track", "Faint", "OnAccent", "OnDanger", "Danger", "Green", "Warn" }) do
		colors[role] = nil
	end
	if overrides.Accent or overrides.Card then
		colors.AccentSoft = nil
	end
	if overrides.Accent then
		colors.Shine = nil
		colors.Info = nil
	end
	for role, color in pairs(overrides) do
		colors[role] = color
	end
	if overrides.Background then
		colors.Panel = Util.mix(overrides.Background, colors.Card, 0.5)
	end
	-- an edited palette keeps a readable border and muted text next to its new window and card colours
	if overrides.Card or overrides.Background then
		colors.Border = Util.mix(colors.Card, colors.Text, 0.18)
	end
	if overrides.Text then
		colors.Muted = Util.mix(overrides.Text, colors.Card, 0.38)
	end
	return Theme.define({ id = Theme.EDIT_ID, name = "Edited colors", group = "Custom", colors = colors, light = base.light })
end

-- changes one role of the current theme (the first change starts an edited theme based on the current one)
function Theme.edit(role, color)
	if Theme.id ~= Theme.EDIT_ID then
		Store.set("editBase", Theme.id or "", true)
		Store.set("editColors", "", true)
	end
	local map = Theme.parseEdits(Store.get("editColors"))
	map[role] = color
	Store.set("editColors", Theme.encodeEdits(map), true)
	if not Theme.rebuildEdited() then
		return false
	end
	return Theme.apply(Theme.EDIT_ID, true)
end

function Theme.resetEdits()
	local base = Store.get("editBase")
	Store.set("editColors", "", true)
	Store.set("editBase", "", true)
	local target = Theme.byId[base] and base or "obsidian"
	Theme.apply(target)
end

-- the colour a role is heading for (Theme.live is still the old colour while a theme change is fading in)
function Theme.targetColor(role)
	local source = Theme.target or Theme.live
	return source[role] or Theme.live[role] or Color3.new(1, 1, 1)
end

function Theme.init()
	Theme.defs, Theme.byId = {}, {}
	for _, spec in ipairs(Theme.catalog) do
		Theme.define(spec)
	end
	Util.try("custom theme", Theme.customDef)
	Util.try("edited theme", Theme.rebuildEdited)
	Theme.cur, Theme.live = {}, {}
	for role, color in pairs(Theme.defs[1].colors) do
		Theme.cur[role] = color
		Theme.live[role] = color
	end
	return Theme
end

-- contrast report for every palette (and the extremes of the builder). Used by Information > Status and the tests.
function Theme.audit()
	local rows = {}
	local all = {}
	for _, def in ipairs(Theme.defs) do
		all[#all + 1] = { id = def.id, c = def.colors }
	end
	local function custom(id, h, s, d, o)
		local spec = Theme.customColors(h, s, d, o)
		local def = Theme.define({ id = "audit-" .. id, name = id, group = "Audit", colors = spec })
		all[#all + 1] = { id = id, c = def.colors }
		Theme.byId["audit-" .. id] = nil
		for i = #Theme.defs, 1, -1 do
			if Theme.defs[i].id == "audit-" .. id then
				table.remove(Theme.defs, i)
			end
		end
	end
	custom("custom-bright", 50, 100, 14, -60)
	custom("custom-dull", 200, 0, 1, 0)
	local need = {
		{ "textOnCard", "Text", "Card", 7 }, { "mutedOnCard", "Muted", "Card", 4.5 }, { "mutedOnBg", "Muted", "Background", 4.5 },
		{ "onAccent", "OnAccent", "Accent", 4.5 }, { "accentOnCard", "Accent", "Card", 3 }, { "accent2OnCard", "Accent2", "Card", 1.8 },
		{ "greenOnCard", "Green", "Card", 3 }, { "warnOnCard", "Warn", "Card", 3 }, { "dangerOnCard", "Danger", "Card", 3 },
	}
	for _, item in ipairs(all) do
		local fails = {}
		for _, check in ipairs(need) do
			local ratio = Util.contrast(item.c[check[2]], item.c[check[3]])
			if ratio < check[4] then
				fails[#fails + 1] = string.format("%s %.2f < %s", check[1], ratio, tostring(check[4]))
			end
		end
		rows[#rows + 1] = { id = item.id, fails = fails }
	end
	return rows
end

function Theme.color(role, mixRole, mixT)
	local live = Theme.live
	local base = live[role] or live.Text or Color3.new(1, 1, 1)
	if mixRole and mixT then
		return Util.mix(base, live[mixRole] or base, mixT)
	end
	return base
end

local function markAccent(inst, prop, role, mixRole)
	if isAccentBinding(role, mixRole) then
		local set = accentProps[inst]
		if not set then
			set = {}
			accentProps[inst] = set
		end
		set[prop] = true
	elseif accentProps[inst] then
		accentProps[inst][prop] = nil
	end
end

-- keep `inst[prop]` in sync with a theme role (optionally mixed toward a second role)
function Theme.bind(inst, prop, role, mixRole, mixT)
	local list = boundProps[inst]
	if not list then
		list = {}
		boundProps[inst] = list
	end
	list[prop] = { role = role, mixRole = mixRole, mixT = mixT }
	markAccent(inst, prop, role, mixRole)
	inst[prop] = Theme.color(role, mixRole, mixT)
	return inst
end

function Theme.unbind(inst, prop)
	local list = boundProps[inst]
	if list then
		list[prop] = nil
	end
	if accentProps[inst] then
		accentProps[inst][prop] = nil
	end
end

-- changes the role of an existing binding and animates the property to the new colour
function Theme.tweenRole(inst, prop, role, duration, mixRole, mixT)
	local list = boundProps[inst]
	if not list then
		list = {}
		boundProps[inst] = list
	end
	list[prop] = { role = role, mixRole = mixRole, mixT = mixT }
	markAccent(inst, prop, role, mixRole)
	Motion.tween(inst, { [prop] = Theme.color(role, mixRole, mixT) }, duration or Motion.base)
end

local function glassFor(kind)
	local g = Theme.glass
	if kind == "bg" then
		return g
	elseif kind == "panel" then
		return g * 0.92
	elseif kind == "card" then
		return g * 0.6
	elseif kind == "input" then
		return g * 0.45
	end
	return 0
end

-- background surface whose transparency follows the "panel transparency" setting
function Theme.surface(inst, role, kind, mixRole, mixT)
	Theme.bind(inst, "BackgroundColor3", role, mixRole, mixT)
	alphaProps[inst] = { kind = kind }
	inst.BackgroundTransparency = glassFor(kind)
	return inst
end

function Theme.setGlass(value)
	Theme.glass = Util.clamp(value, 0, 0.6)
	for inst, info in pairs(alphaProps) do
		inst.BackgroundTransparency = glassFor(info.kind)
	end
end

function Theme.gradient(gradient, builder, static)
	gradientBinds[gradient] = builder
	gradientStatic[gradient] = static == true or nil
	gradient.Color = builder(Theme.live)
	return gradient
end

local function seq(points)
	local keys = {}
	for i, p in ipairs(points) do
		keys[i] = ColorSequenceKeypoint.new(p[1], p[2])
	end
	return ColorSequence.new(keys)
end

-- the bright highlight of a gradient: white-ish on dark themes, the accent itself on a light one (Pearl)
local function highlight(l)
	if Theme.light then
		return l.Accent
	end
	return l.Shine
end

Theme.G = {
	accent = function(l)
		return seq({ { 0, l.Accent }, { 1, l.Accent2 } })
	end,
	metal = function(l)
		return seq({ { 0, highlight(l) }, { 0.42, l.Accent }, { 1, l.Accent2 } })
	end,
	stroke = function(l)
		return seq({ { 0, l.Border }, { 0.25, l.Accent }, { 0.5, l.Border }, { 0.75, l.Accent2 }, { 1, l.Border } })
	end,
	aurora = function(l)
		return seq({
			{ 0, l.Background },
			{ 0.35, Util.mix(l.Background, l.Accent, 0.28) },
			{ 0.65, Util.mix(l.Background, l.Accent2, 0.22) },
			{ 1, l.Background },
		})
	end,
	sheen = function(l)
		local hi = highlight(l)
		return seq({ { 0, l.Text }, { 0.4, l.Text }, { 0.5, hi }, { 0.6, l.Text }, { 1, l.Text } })
	end,
	glint = function(l)
		return seq({ { 0, l.Accent }, { 0.4, l.Accent }, { 0.5, highlight(l) }, { 0.6, l.Accent }, { 1, l.Accent2 } })
	end,
	-- the launcher orb: a soft accent tone at the top left fading to the window colour at the bottom right
	orb = function(l)
		return seq({ { 0, Util.mix(l.AccentSoft, l.Accent, 0.18) }, { 1, l.Background } })
	end,
	-- the specular rim of a glass surface: bright at the top left and the bottom right, quiet in between
	rim = function(l)
		local hi = Util.mix(l.Border, l.Text, Theme.light and 0.05 or 0.62)
		if Theme.light then
			hi = Util.mix(l.Border, Color3.new(1, 1, 1), 0.7)
		end
		local lo = Util.mix(l.Border, l.Card, 0.25)
		return seq({
			{ 0, hi }, { 0.2, Util.mix(hi, lo, 0.55) }, { 0.5, lo }, { 0.8, Util.mix(hi, lo, 0.55) }, { 1, hi },
		})
	end,
	-- a glass plate (the HIDE MENU button): a little lighter at the top, card colour at the bottom
	plate = function(l)
		return seq({ { 0, Util.mix(l.Card, l.Text, 0.13) }, { 1, l.Card } })
	end,
}

-- writes every bound property again (a theme change): hundreds of writes, so it is not used for colour motion
function Theme.refresh()
	for inst, props in pairs(boundProps) do
		for prop, b in pairs(props) do
			inst[prop] = Theme.color(b.role, b.mixRole, b.mixT)
		end
	end
	for gradient, builder in pairs(gradientBinds) do
		gradient.Color = builder(Theme.live)
	end
end

-- colour motion: only what depends on the five accent roles
function Theme.refreshAccent()
	for inst, set in pairs(accentProps) do
		local props = boundProps[inst]
		for prop in pairs(set) do
			local b = props and props[prop]
			if b and isAccentBinding(b.role, b.mixRole) then
				inst[prop] = Theme.color(b.role, b.mixRole, b.mixT)
			else
				set[prop] = nil
			end
		end
	end
	for gradient, builder in pairs(gradientBinds) do
		if not gradientStatic[gradient] then
			gradient.Color = builder(Theme.live)
		end
	end
end

function Theme.counts()
	local bound, accent, grads, moving = 0, 0, 0, 0
	for _, props in pairs(boundProps) do
		for _ in pairs(props) do
			bound = bound + 1
		end
	end
	for _, set in pairs(accentProps) do
		for _ in pairs(set) do
			accent = accent + 1
		end
	end
	for gradient in pairs(gradientBinds) do
		grads = grads + 1
		if not gradientStatic[gradient] then
			moving = moving + 1
		end
	end
	return { bound = bound, accent = accent, gradients = grads, movingGradients = moving }
end

local function fireTheme()
	local def = Theme.byId[Theme.id]
	local snapshot = {}
	for i, fn in ipairs(Theme.listeners) do
		snapshot[i] = fn
	end
	for _, fn in ipairs(snapshot) do
		Util.try("theme listener", fn, Theme.id, def)
	end
end

function Theme.onChange(fn)
	Theme.listeners[#Theme.listeners + 1] = fn
	return function()
		local index = Util.indexOf(Theme.listeners, fn)
		if index then
			table.remove(Theme.listeners, index)
		end
	end
end

-- Colour motion --------------------------------------------------------------------------------------
-- Breathe lifts and softens the accent, Drift swings its hue about 24 degrees each way over 28 s, Spectrum
-- walks the whole wheel in 72 s. Only Accent, Accent2, Shine, AccentSoft and OnAccent are touched.
local function shiftColor(col, hueShift, dh, dl, ds, spectrum, lMin, lMax)
	local h, s, l = Util.rgb2hsl(col)
	local sat, lig = s, l
	if spectrum then
		sat = math.max(s, 0.62)
		lig = Util.clamp(l, lMin, lMax)
	end
	local satShift = 0
	if sat > 0.05 then
		satShift = ds
	end
	return Util.hsl2rgb(h + dh * hueShift, Util.clamp(sat + satShift, 0, 1), Util.clamp(lig + dl, 0, 1))
end

-- fills Theme.live from Theme.cur (and moves the accent roles when colour motion is on)
function Theme.compose(t)
	local cur, live = Theme.cur, Theme.live
	for role, color in pairs(cur) do
		live[role] = color
	end
	local mode = Store.get("accentMotion")
	if mode == "still" or Theme.fxLevel < 1 or Motion.reduced then
		return
	end
	local sp = Store.get("accentSpeed")
	local dh, dl, ds = 0, 0, 0
	local spectrum = mode == "spectrum"
	if mode == "drift" then
		dh = 24 * math.sin(2 * math.pi * t * sp / 28)
	elseif spectrum then
		dh = (t * sp * 360 / 72) % 360
	else
		local b = math.sin(2 * math.pi * t * sp / 4.4)
		dl, ds = 0.07 * b, 0.06 * b
	end
	-- a light theme needs a darker accent than a dark one so it still stands out from the white card
	local aMin, aMax = 0.55, 0.7
	if Theme.light then
		aMin, aMax = 0.36, 0.52
	end
	live.Accent = shiftColor(cur.Accent, 1, dh, dl, ds, spectrum, aMin, aMax)
	live.Accent2 = shiftColor(cur.Accent2, 1, dh, dl, ds, spectrum, aMin - 0.13, aMax - 0.1)
	live.Shine = shiftColor(cur.Shine, 0.5, dh, dl, ds, spectrum, 0.82, 0.94)
	live.AccentSoft = Util.mix(cur.AccentSoft, live.Accent, 0.35)
	live.OnAccent = Util.onColor(live.Accent)
end

local motionRunning = false
function Theme.syncMotion()
	local on = Store.get("accentMotion") ~= "still" and Theme.fxLevel >= 1 and not Motion.reduced
	if on then
		Anim.add("thememotion", function(_, now)
			Theme.compose(now)
			Theme.refreshAccent()
		end, 10, function()
			return Theme.active()
		end)
	else
		Anim.remove("thememotion")
		if motionRunning then
			Theme.compose(os.clock())
			Theme.refresh()
		end
	end
	motionRunning = on
end

-- transient = true: show the palette without remembering it (the loading screen keeps its dark look)
function Theme.apply(id, instant, transient)
	local def = Theme.byId[id]
	if not def then
		return false
	end
	local first = Theme.id == nil
	Theme.id = id
	Theme.light = def.light == true
	if not transient then
		Store.set("theme", id, true)
	end
	local from = Util.copy(Theme.cur)
	local to = def.colors
	Theme.target = to
	if instant or first or Motion.reduced then
		Anim.remove("themelerp")
		for role, color in pairs(to) do
			Theme.cur[role] = color
		end
		Theme.compose(os.clock())
		Theme.refresh()
	else
		local started = os.clock()
		Anim.add("themelerp", function()
			local a = Util.clamp((os.clock() - started) / 0.4, 0, 1)
			local e = Motion.ease.outCubic(a)
			for role, color in pairs(to) do
				Theme.cur[role] = Util.mix(from[role] or color, color, e)
			end
			Theme.compose(os.clock())
			Theme.refresh()
			if a >= 1 then
				Anim.remove("themelerp")
			end
		end, 40)
	end
	fireTheme()
	return true
end

function Theme.prune()
	for inst in pairs(boundProps) do
		if inst.Parent == nil then
			boundProps[inst] = nil
			accentProps[inst] = nil
		end
	end
	for inst in pairs(alphaProps) do
		if inst.Parent == nil then
			alphaProps[inst] = nil
		end
	end
	for gradient in pairs(gradientBinds) do
		if gradient.Parent == nil then
			gradientBinds[gradient] = nil
			gradientStatic[gradient] = nil
		end
	end
end

function Theme.current()
	return Theme.byId[Theme.id]
end

----------------------------------------------------------------------------------------------------
-- Animated accents (spin / sweep / pulse). Level 0 = off, 1 = subtle, 2 = full.
-- Effects are time-based, throttled to 30 Hz, and pause while the hub is hidden.
----------------------------------------------------------------------------------------------------
function Theme.fxSpin(inst, degreesPerSecond, minLevel)
	fxItems[#fxItems + 1] = { kind = "spin", inst = inst, speed = degreesPerSecond, minLevel = minLevel or 2 }
	Theme.syncFx()
end

function Theme.fxSweep(inst, period, rest, minLevel, phase)
	fxItems[#fxItems + 1] = {
		kind = "sweep", inst = inst, period = period, rest = rest or 0.5, minLevel = minLevel or 1, phase = phase or 0,
	}
	Theme.syncFx()
end

function Theme.fxPulse(inst, prop, a, b, period, minLevel)
	fxItems[#fxItems + 1] = {
		kind = "pulse", inst = inst, prop = prop, a = a, b = b, period = period, minLevel = minLevel or 2,
	}
	Theme.syncFx()
end

local function fxRest(item)
	pcall(function()
		if item.kind == "spin" then
			item.inst.Rotation = 0
		elseif item.kind == "sweep" then
			item.inst.Offset = Vector2.new(1, 0)
		elseif item.kind == "pulse" then
			item.inst[item.prop] = item.a
		end
	end)
end

local function fxTick(_, now)
	local level = Theme.fxLevel
	local i = #fxItems
	while i >= 1 do
		local item = fxItems[i]
		local inst = item.inst
		if inst.Parent == nil then
			table.remove(fxItems, i)
		elseif level >= item.minLevel then
			if item.kind == "spin" then
				inst.Rotation = (now * item.speed) % 360
			elseif item.kind == "sweep" then
				local phase = (now / item.period + item.phase) % 1
				local travel = 1 - item.rest
				local a = 1
				if phase < travel then
					a = phase / travel
				end
				inst.Offset = Vector2.new(-1 + 2 * Motion.ease.inOutSine(a), 0)
			else
				local s = 0.5 + 0.5 * math.sin(now * 2 * math.pi / item.period)
				inst[item.prop] = item.a + (item.b - item.a) * s
			end
		end
		i = i - 1
	end
end

function Theme.syncFx()
	local level = Store.get("fx")
	if Store.get("reducedMotion") or Store.get("lowPower") then
		level = 0
	end
	local changed = level ~= Theme.fxLevel
	Theme.fxLevel = level
	Theme.syncMotion()
	if level == 0 then
		Anim.remove("themefx")
		if changed then
			for _, item in ipairs(fxItems) do
				fxRest(item)
			end
		end
	elseif #fxItems > 0 then
		Anim.add("themefx", fxTick, 30, function()
			return Theme.active()
		end)
	end
end

function Theme.clearFx()
	fxItems = {}
	Anim.remove("themefx")
end
end -- [03_theme.lua]

do -- [04_sfx.lua]

----------------------------------------------------------------------------------------------------
-- Sfx: short UI sounds. Every asset is preloaded; anything that fails is skipped silently.
----------------------------------------------------------------------------------------------------
Sfx.holder = nil
Sfx.records = {}   -- asset id -> { id, sound, status = "pending" | "ok" | "failed" | "unknown", length }
Sfx.last = {}      -- event -> os.clock() of the last play (rate limit)
Sfx.tracked = {}

function Sfx.init()
	Sfx.records = {}
	if not SoundService then
		return false
	end
	local ok, holder = pcall(function()
		return Util.new("Folder", { Name = "VyreLoaderSfx" }, SoundService)
	end)
	if not ok then
		Util.log("warn", "sound holder could not be created: " .. tostring(holder))
		return false
	end
	Sfx.holder = holder
	for _, def in pairs(CONFIG.Sounds) do
		local id = def.id
		if type(id) == "string" and id ~= "" and not Sfx.records[id] then
			local created, sound = pcall(function()
				return Util.new("Sound", { Name = "Sfx" .. Util.hash(id), SoundId = id, Volume = 0 }, holder)
			end)
			if created then
				Sfx.records[id] = { id = id, sound = sound, status = "pending", length = 0 }
			end
		end
	end
	return true
end

-- Preloads every sound. Yields (call from a task). onProgress(done, total) reports REAL completions.
-- Returns loaded, failed, total. Never waits longer than `timeout` seconds.
function Sfx.preload(onProgress, timeout)
	local list, byId = {}, {}
	for id, record in pairs(Sfx.records) do
		list[#list + 1] = record.sound
		byId[id] = record
	end
	local total = #list
	if total == 0 then
		return 0, 0, 0
	end
	if not ContentProvider then
		for _, record in pairs(Sfx.records) do
			record.status = "unknown"
		end
		return 0, 0, total
	end

	local done, finished = 0, false
	task.spawn(function()
		local ok, err = pcall(ContentProvider.PreloadAsync, ContentProvider, list, function(contentId, status)
			done = done + 1
			local record = byId[contentId]
			if not record then
				for id, candidate in pairs(byId) do
					if string.find(tostring(contentId), id, 1, true) then
						record = candidate
					end
				end
			end
			if record then
				if tostring(status) == "Enum.AssetFetchStatus.Success" then
					record.status = "ok"
				else
					record.status = "failed"
				end
			end
			if onProgress then
				onProgress(done, total)
			end
		end)
		if not ok then
			Util.log("warn", "sound preload unavailable: " .. tostring(err))
			for _, record in pairs(Sfx.records) do
				if record.status == "pending" then
					record.status = "unknown"
				end
			end
		end
		finished = true
	end)

	local started = os.clock()
	while not finished and os.clock() - started < (timeout or 6) do
		task.wait(0.05)
	end

	local loaded, failed = 0, 0
	for _, record in pairs(Sfx.records) do
		local ok, length = pcall(function()
			return record.sound.TimeLength
		end)
		if ok and type(length) == "number" then
			record.length = length
		end
		if record.status == "pending" then
			-- preload never reported (timed out): trust the Sound's own state if it has one
			local okLoaded, isLoaded = pcall(function()
				return record.sound.IsLoaded
			end)
			if okLoaded and isLoaded then
				record.status = "ok"
			else
				record.status = finished and "failed" or "unknown"
			end
		end
		if record.status == "ok" then
			loaded = loaded + 1
		elseif record.status == "failed" then
			failed = failed + 1
			Util.log("warn", "sound asset failed to load: " .. record.id)
		end
	end
	return loaded, failed, total
end

local function fireSound(record, def, speed, master, tracked)
	if not Sfx.holder then
		return nil -- the hub was closed while a delayed part of a sound was still pending
	end
	local clone = record.sound:Clone()
	if not clone then
		return nil
	end
	clone.Volume = Util.clamp((def.volume or 0.4) * master * 1.5, 0, 1)
	clone.PlaybackSpeed = speed
	clone.Looped = false
	clone.Parent = Sfx.holder
	local played = pcall(clone.Play, clone)
	if not played and SoundService then
		played = pcall(SoundService.PlayLocalSound, SoundService, clone)
	end
	local length = record.length
	local life = (length > 0 and (length / math.max(speed, 0.1)) or 1.5) + 0.5
	local cut = def.maxSeconds
	if not cut and length > 2.5 then
		cut = 0.9
	end
	if cut and cut < life then
		task.delay(cut, function()
			if clone.Parent then
				Motion.tween(clone, { Volume = 0 }, 0.18)
			end
		end)
		life = cut + 0.3
	end
	task.delay(life, function()
		pcall(clone.Destroy, clone)
	end)
	if tracked then
		Sfx.tracked[#Sfx.tracked + 1] = clone
	end
	return clone
end

-- Plays a named UI sound. Respects the sound toggle, the volume setting and a per-event cooldown.
function Sfx.play(event, force)
	if not force and not Store.get("sound") then
		return false
	end
	local def = CONFIG.Sounds[event]
	if not def or type(def.id) ~= "string" or def.id == "" or not Sfx.holder then
		return false
	end
	local record = Sfx.records[def.id]
	if not record or record.status == "failed" then
		return false
	end
	local master = Store.get("volume")
	if master <= 0.001 then
		return false
	end
	local now = os.clock()
	local previous = Sfx.last[event]
	if previous and now - previous < (def.cooldown or 0.045) then
		return false
	end
	Sfx.last[event] = now

	local steps = def.chain or { { at = 0, speed = def.speed or 1 } }
	for _, step in ipairs(steps) do
		local speed = step.speed or def.speed or 1
		if step.at and step.at > 0 then
			task.delay(step.at, function()
				if Sfx.holder then
					Util.try("sfx " .. event, fireSound, record, def, speed, master, false)
				end
			end)
		else
			Util.try("sfx " .. event, fireSound, record, def, speed, master, false)
		end
	end
	return true
end

-- Plays a sound that the caller wants to be able to fade out (loading music). Returns a handle.
function Sfx.playTracked(event, force)
	local handle = { clone = nil }
	function handle.Stop(fadeSeconds)
		local clone = handle.clone
		if clone and clone.Parent then
			Motion.tween(clone, { Volume = 0 }, fadeSeconds or 0.3, Enum.EasingStyle.Quad)
			task.delay((fadeSeconds or 0.3) + 0.05, function()
				pcall(clone.Destroy, clone)
			end)
		end
		handle.clone = nil
	end
	if not force and not Store.get("sound") then
		return handle
	end
	local def = CONFIG.Sounds[event]
	local record = def and Sfx.records[def.id]
	if not record or record.status == "failed" or not Sfx.holder then
		return handle
	end
	local master = Store.get("volume")
	if master <= 0.001 then
		return handle
	end
	local ok, clone = Util.try("sfx " .. event, fireSound, record, def, def.speed or 1, master, true)
	if ok then
		handle.clone = clone
	end
	return handle
end

function Sfx.stopAll()
	for _, clone in ipairs(Sfx.tracked) do
		pcall(clone.Destroy, clone)
	end
	Sfx.tracked = {}
end

-- human-readable status for Settings > Sound
function Sfx.status()
	local events, ok, failed, pending = {}, 0, 0, 0
	for event, def in pairs(CONFIG.Sounds) do
		local record = def.id ~= "" and Sfx.records[def.id] or nil
		local state = "off"
		if record then
			state = record.status
		end
		events[#events + 1] = { event = event, id = def.id, state = state }
	end
	table.sort(events, function(a, b)
		return a.event < b.event
	end)
	for _, record in pairs(Sfx.records) do
		if record.status == "ok" then
			ok = ok + 1
		elseif record.status == "failed" then
			failed = failed + 1
		else
			pending = pending + 1
		end
	end
	return { events = events, ok = ok, failed = failed, pending = pending, total = ok + failed + pending }
end

function Sfx.summary()
	local s = Sfx.status()
	if not Sfx.holder then
		return "Audio is unavailable in this environment."
	end
	if s.total == 0 then
		return "No sound assets are configured."
	end
	if s.failed == 0 and s.pending == 0 then
		return string.format("All %d sound assets loaded.", s.total)
	end
	return string.format("%d of %d sound assets loaded; %d unavailable (silent).", s.ok, s.total, s.failed + s.pending)
end

function Sfx.destroy()
	Sfx.stopAll()
	if Sfx.holder then
		pcall(Sfx.holder.Destroy, Sfx.holder)
	end
	Sfx.holder = nil
	Sfx.records = {}
end
end -- [04_sfx.lua]

do -- [05_ui_base.lua]

----------------------------------------------------------------------------------------------------
-- UI kit, part 1: input sessions, drawn icons, pressable feedback, button, toggle, slider,
-- stepper, segmented selector. Every control is built as  Hit (TextButton, transparent)  +
-- Face (Frame, scaled on press) so the touch target can be larger than what is drawn.
----------------------------------------------------------------------------------------------------
UI.metrics = { buttonH = 34, radius = 9, rowH = 58, touchMin = 36 }
UI.sessions = {}
UI.layers = {}
UI.scale = function()
	return 1
end

local function isPress(input)
	local t = input.UserInputType
	return t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch
end
UI.isPress = isPress

-- Follows ONE press until it ends. Used by sliders, window drag and press feedback so that a
-- missed InputEnded can never leave a control stuck in its pressed state.
function UI.watchInput(input, onMove, onEnd)
	local session = { done = false, conns = {} }
	local isTouch = input.UserInputType == Enum.UserInputType.Touch
	local function finish(cancelled)
		if session.done then
			return
		end
		session.done = true
		for _, connection in ipairs(session.conns) do
			connection:Disconnect()
		end
		session.conns = {}
		UI.sessions[session] = nil
		if onEnd then
			Util.try("input end", onEnd, cancelled)
		end
	end
	session.finish = finish
	session.conns[#session.conns + 1] = UserInputService.InputChanged:Connect(function(i)
		if session.done or not onMove then
			return
		end
		local t = i.UserInputType
		if i == input or (isTouch and t == Enum.UserInputType.Touch) or (not isTouch and t == Enum.UserInputType.MouseMovement) then
			onMove(i)
		end
	end)
	session.conns[#session.conns + 1] = UserInputService.InputEnded:Connect(function(i)
		local t = i.UserInputType
		if i == input or (isTouch and t == Enum.UserInputType.Touch) or (not isTouch and t == Enum.UserInputType.MouseButton1) then
			finish(false)
		end
	end)
	pcall(function()
		session.conns[#session.conns + 1] = input.Changed:Connect(function()
			local state = input.UserInputState
			if state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
				finish(false)
			end
		end)
	end)
	UI.sessions[session] = true
	return session
end

function UI.endSessions()
	local list = {}
	for session in pairs(UI.sessions) do
		list[#list + 1] = session
	end
	for _, session in ipairs(list) do
		session.finish(true)
	end
end

function UI.findScroller(inst)
	local node = inst.Parent
	while node do
		if node:IsA("ScrollingFrame") then
			return node
		end
		node = node.Parent
	end
	return nil
end

function UI.scrollIntoView(inst)
	local scroller = UI.findScroller(inst)
	if not scroller then
		return
	end
	local s = UI.scale()
	local rel = (inst.AbsolutePosition.Y - scroller.AbsolutePosition.Y) / s + scroller.CanvasPosition.Y
	Motion.tween(scroller, { CanvasPosition = Vector2.new(0, math.max(0, rel - 10)) }, 0.25)
end

-- quick horizontal nudge used for "that control is unavailable" feedback
function UI.shake(inst)
	if Motion.reduced or not inst or not inst.Parent then
		return
	end
	local home = inst.Position
	local function at(dx)
		return UDim2.new(home.X.Scale, home.X.Offset + dx, home.Y.Scale, home.Y.Offset)
	end
	Motion.tween(inst, { Position = at(4) }, 0.05, Enum.EasingStyle.Quad, nil, function()
		Motion.tween(inst, { Position = at(-4) }, 0.07, Enum.EasingStyle.Quad, nil, function()
			Motion.tween(inst, { Position = home }, 0.08, Enum.EasingStyle.Quad)
		end)
	end)
end

----------------------------------------------------------------------------------------------------
-- Liquid glass. A Frame cannot blur what is behind it, so the glass look is built from what Frames can do: the panel
-- transparency (Appearance > Liquid glass), a bright diagonal sheen, a specular rim that is brightest at the top left and
-- the bottom right, a thin highlight along the top edge and a soft stack of shadows underneath.
----------------------------------------------------------------------------------------------------
local WHITE = Color3.new(1, 1, 1)
UI.WHITE = WHITE

-- Gives a rounded Frame the glass finish. o: strength (0..1, default 1), zindex (the sheen's level; default one below the
-- frame so its own content stays on top), rim (default true), stroke (an existing UIStroke that receives the rim),
-- edge (a top highlight line, default false), angle, thickness, rimTransparency.
-- returns { Sheen, Rim, Edge }
function UI.glass(frame, o)
	o = o or {}
	local strength = o.strength or 1
	local corner = frame:FindFirstChildOfClass("UICorner")
	local radius = corner and corner.CornerRadius or UDim.new(0, o.radius or 12)
	local z = o.zindex or (frame.ZIndex - 1)
	local parts = {}
	local sheen = Util.new("Frame", {
		Name = "Sheen", Active = false, BorderSizePixel = 0, BackgroundColor3 = WHITE, Size = UDim2.fromScale(1, 1), ZIndex = z,
	}, frame)
	Util.new("UICorner", { CornerRadius = radius }, sheen)
	Util.new("UIGradient", {
		Rotation = o.angle or 62,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1 - 0.17 * strength),
			NumberSequenceKeypoint.new(0.4, 1 - 0.05 * strength),
			NumberSequenceKeypoint.new(0.62, 1),
			NumberSequenceKeypoint.new(1, 1 - 0.06 * strength),
		}),
	}, sheen)
	parts.Sheen = sheen
	if o.rim ~= false then
		local stroke = o.stroke
		if stroke then
			Theme.unbind(stroke, "Color")
			stroke.Color = WHITE
		else
			stroke = Util.new("UIStroke", {
				Thickness = o.thickness or 1, Transparency = o.rimTransparency or 0.25, ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			}, frame)
		end
		local rim = Util.new("UIGradient", { Rotation = 45 }, stroke)
		Theme.gradient(rim, Theme.G.rim, true)
		parts.Rim = stroke
	end
	if o.edge then
		local inset = radius.Scale > 0 and 14 or math.max(8, radius.Offset)
		local edge = Util.new("Frame", {
			Name = "Edge", Active = false, BorderSizePixel = 0, BackgroundColor3 = WHITE,
			Position = UDim2.fromOffset(inset, 1), Size = UDim2.new(1, -inset * 2, 0, 1), ZIndex = z,
		}, frame)
		Util.new("UIGradient", {
			Rotation = 0,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.45), NumberSequenceKeypoint.new(1, 1),
			}),
		}, edge)
		parts.Edge = edge
	end
	return parts
end

-- A soft shadow: translucent rounded rectangles stacked behind the content of `host` (a Frame that does not clip).
-- radius = the host's corner radius in pixels. o: dy (how far it falls), specs ({ grow, transparency } rows), zindex.
function UI.shadow(host, radius, o)
	o = o or {}
	local list = {}
	local specs = o.specs or { { 2, 0.9 }, { 6, 0.945 }, { 11, 0.97 }, { 17, 0.984 } }
	local dy = o.dy or 6
	for i, spec in ipairs(specs) do
		local grow = spec[1]
		local layer = Util.new("Frame", {
			Name = "Shadow" .. i, Active = false, BorderSizePixel = 0, BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = spec[2], Position = UDim2.fromOffset(-grow, -grow + dy), Size = UDim2.new(1, grow * 2, 1, grow * 2),
			ZIndex = o.zindex or 1,
		}, host)
		Util.corner(layer, radius + grow)
		list[i] = layer
	end
	return list
end

-- A shadow for a popup that is moved or resized by tweens (a dropdown list, a sheet): its layers follow `target` (they live
-- in the same parent, one level below it). Returns { Destroy }.
function UI.followShadow(target, radius, o)
	o = o or {}
	local specs = o.specs or { { 2, 0.9 }, { 7, 0.95 }, { 13, 0.975 } }
	local dy = o.dy or 6
	local layers, connections = {}, {}
	for i, spec in ipairs(specs) do
		local layer = Util.new("Frame", {
			Name = "PopupShadow" .. i, Active = false, BorderSizePixel = 0, BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = spec[2], ZIndex = target.ZIndex - 1,
		}, target.Parent)
		Util.corner(layer, radius + spec[1])
		layers[i] = { frame = layer, grow = spec[1] }
	end
	local function sync()
		local size, pos, anchor = target.Size, target.Position, target.AnchorPoint
		-- while the popup is still (nearly) flat the shadow stays out of sight and grows in with it
		local k = size.Y.Scale > 0 and 1 or Util.clamp(size.Y.Offset / 28, 0, 1)
		for _, item in ipairs(layers) do
			local g = item.grow * k
			item.frame.Visible = k > 0.02
			item.frame.AnchorPoint = anchor
			item.frame.Size = UDim2.new(size.X.Scale, size.X.Offset + g * 2, size.Y.Scale, size.Y.Offset + g * 2)
			item.frame.Position = UDim2.new(
				pos.X.Scale, pos.X.Offset + (anchor.X < 0.5 and -g or g),
				pos.Y.Scale, pos.Y.Offset + (anchor.Y < 0.5 and (-g + dy * k) or (g + dy * k))
			)
		end
	end
	sync()
	connections[1] = target:GetPropertyChangedSignal("Size"):Connect(sync)
	connections[2] = target:GetPropertyChangedSignal("Position"):Connect(sync)
	local api = {}
	function api.Destroy()
		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end
		connections = {}
		for _, item in ipairs(layers) do
			item.frame:Destroy()
		end
		layers = {}
	end
	return api
end

-- a gloss: a white band over the top half of a coloured surface (buttons, the selection pill)
function UI.gloss(frame, strength, zindex)
	local corner = frame:FindFirstChildOfClass("UICorner")
	local gloss = Util.new("Frame", {
		Name = "Gloss", Active = false, BorderSizePixel = 0, BackgroundColor3 = WHITE, Size = UDim2.fromScale(1, 1),
		ZIndex = zindex or frame.ZIndex,
	}, frame)
	Util.new("UICorner", { CornerRadius = corner and corner.CornerRadius or UDim.new(0, 10) }, gloss)
	Util.new("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1 - 0.24 * (strength or 1)), NumberSequenceKeypoint.new(0.5, 1), NumberSequenceKeypoint.new(1, 1),
		}),
	}, gloss)
	return gloss
end

----------------------------------------------------------------------------------------------------
-- icons drawn from frames (no image assets, no font glyph dependencies)
----------------------------------------------------------------------------------------------------
local ICONS = {}

ICONS.grid = function(g)
	g.box(5.5, 5.5, 7, 7, 2)
	g.box(14.5, 5.5, 7, 7, 2)
	g.box(5.5, 14.5, 7, 7, 2)
	g.box(14.5, 14.5, 7, 7, 2)
end
ICONS.user = function(g)
	g.dot(10, 6.2, 7)
	g.box(10, 15.2, 14, 6.5, 3.2)
end
ICONS.sparkle = function(g)
	g.bar(10, 10, 2, 18)
	g.bar(10, 10, 18, 2)
	g.bar(10, 10, 2, 12, 45)
	g.bar(10, 10, 2, 12, -45)
	g.dot(10, 10, 5)
end
ICONS.image = function(g)
	g.outline(10, 10, 17, 14, 3, 1.7)
	g.dot(7.4, 7.6, 3.2)
	g.bar(12.6, 12.4, 8, 1.8, -38)
end
ICONS.sliders = function(g)
	g.bar(10, 5, 16, 1.8)
	g.bar(10, 10, 16, 1.8)
	g.bar(10, 15, 16, 1.8)
	g.dot(6, 5, 4.6)
	g.dot(13.5, 10, 4.6)
	g.dot(8.5, 15, 4.6)
end
ICONS.gear = function(g)
	g.ring(10, 10, 11, 2.2)
	g.dot(10, 10, 3.2)
	for i = 0, 7 do
		local a = i * math.pi / 4
		g.bar(10 + 7 * math.sin(a), 10 - 7 * math.cos(a), 2.6, 3.4, i * 45)
	end
end
ICONS.close = function(g)
	g.bar(10, 10, 14, 2, 45)
	g.bar(10, 10, 14, 2, -45)
end
ICONS.minus = function(g)
	g.bar(10, 10, 12, 2)
end
ICONS.plus = function(g)
	g.bar(10, 10, 12, 2)
	g.bar(10, 10, 2, 12)
end
ICONS.restore = function(g)
	g.outline(10, 10, 11.5, 11.5, 2, 1.8)
end
ICONS.chevron = function(g)
	g.bar(7.6, 9.4, 7, 2, 45)
	g.bar(12.4, 9.4, 7, 2, -45)
end
ICONS.check = function(g)
	g.bar(6.5, 12.1, 5, 2.2, 45)
	g.bar(11.8, 10, 10.6, 2.2, -47)
end
ICONS.bang = function(g)
	g.bar(10, 7.4, 2.6, 8.6)
	g.dot(10, 14.8, 3)
end
ICONS.info = function(g)
	g.dot(10, 5.4, 3)
	g.bar(10, 11.8, 2.6, 7.6)
end
ICONS.dots = function(g)
	g.dot(4.5, 10, 3.2)
	g.dot(10, 10, 3.2)
	g.dot(15.5, 10, 3.2)
end
ICONS.logo = function(g)
	-- the VIREX mark: a bold "V" made of two bars with a small diamond above it
	g.bar(6.6, 9.4, 3, 12.6, -24)
	g.bar(13.4, 9.4, 3, 12.6, 24)
	g.bar(10, 3.6, 3.2, 3.2, 45)
end

ICONS.scripts = function(g)
	-- "</>": two angle brackets and a slash
	g.bar(5.4, 7.5, 6.6, 1.9, -49)
	g.bar(5.4, 12.5, 6.6, 1.9, 49)
	g.bar(14.6, 7.5, 6.6, 1.9, 49)
	g.bar(14.6, 12.5, 6.6, 1.9, -49)
	g.bar(10, 10, 1.8, 11, 20)
end
ICONS.search = function(g)
	g.ring(8.4, 8.4, 11.5, 1.9)
	g.bar(15.3, 15.3, 6.4, 2.2, 45)
end
ICONS.eye = function(g)
	g.outline(10, 10, 17.5, 10.5, 5.2, 1.7)
	g.dot(10, 10, 4.6)
end
ICONS.copy = function(g)
	g.outline(8, 8, 10.5, 11.5, 2.6, 1.7)
	g.outline(12.4, 12.2, 10.5, 11.5, 2.6, 1.7)
end
ICONS.home = function(g)
	g.bar(6.4, 7.4, 9, 2, -42)
	g.bar(13.6, 7.4, 9, 2, 42)
	g.outline(10, 13.6, 10.5, 7.2, 2, 1.7)
end
ICONS.server = function(g)
	g.outline(10, 6.2, 15.5, 5.2, 2.2, 1.6)
	g.outline(10, 13.8, 15.5, 5.2, 2.2, 1.6)
	g.dot(6.2, 6.2, 1.9)
	g.dot(6.2, 13.8, 1.9)
end
ICONS.bell = function(g)
	-- a solid bell: a knob, a dome, a wide flared rim and the clapper (an outline read as a magnifier at 16 px)
	g.dot(10, 3.4, 2.6)
	g.box(10, 9.4, 10.2, 11, 5.1)
	g.box(10, 13.6, 14.4, 3.4, 1.7)
	g.dot(10, 17.4, 3.4)
end
ICONS.star = function(g)
	-- five arms around a centre disc; the colour (Muted / Warn) tells empty from filled
	g.dot(10, 10.6, 7)
	for i = 0, 4 do
		local a = i * 2 * math.pi / 5
		g.bar(10 + 4.2 * math.sin(a), 10.6 - 4.2 * math.cos(a), 3.2, 8.4, i * 72)
	end
end
ICONS.play = function(g)
	-- a triangle outline pointing right
	g.bar(7.2, 10, 2, 11.6)
	g.bar(11.2, 7.1, 2, 8.6, -57)
	g.bar(11.2, 12.9, 2, 8.6, 57)
end
-- the Music tab (2.7.0): a beamed pair of notes and the player's controls. "mplay" is the filled triangle (play above is an outline).
ICONS.music = function(g)
	g.dot(6.1, 14.6, 5)
	g.dot(13.4, 12.8, 5)
	g.bar(7.8, 9.4, 1.8, 10.4)
	g.bar(15, 7.6, 1.8, 10.4)
	g.bar(11.4, 3.5, 9.2, 2.4, -14)
end
ICONS.mplay = function(g)
	g.tri(10.6, 10, 9.4, 12.4, 1)
end
ICONS.pause = function(g)
	g.box(7.2, 10, 3.6, 12.4, 1.4)
	g.box(12.8, 10, 3.6, 12.4, 1.4)
end
ICONS.next = function(g)
	g.tri(8.4, 10, 8.6, 10.8, 1)
	g.box(14.4, 10, 2.3, 10.8, 1)
end
ICONS.prev = function(g)
	g.box(5.6, 10, 2.3, 10.8, 1)
	g.tri(11.6, 10, 8.6, 10.8, -1)
end
ICONS.shuffle = function(g)
	g.bar(9.4, 10, 14.5, 1.9, 36)
	g.bar(9.4, 10, 14.5, 1.9, -36)
	g.tri(16.2, 5.6, 4.2, 4.8, 1)
	g.tri(16.2, 14.4, 4.2, 4.8, 1)
end
ICONS.loop = function(g)
	-- a rounded loop with an arrow head on top (the "repeat" icon; repeat is a Lua keyword)
	g.outline(10, 11, 15.5, 9.5, 4, 1.7)
	g.tri(14.4, 6.2, 4.4, 5, 1)
end
ICONS.palette = function(g)
	g.ring(10, 10, 16.5, 1.8)
	g.dot(6.9, 8.6, 2.8)
	g.dot(10.4, 6.2, 2.8)
	g.dot(13.6, 9, 2.8)
	g.dot(8.4, 12.8, 2.8)
end
ICONS.drop = function(g)
	-- a drop of liquid: a round belly and a point on top
	g.dot(10, 12.2, 10.5)
	g.box(10, 7.2, 6.6, 6.6, 1.6, 45)
end
ICONS.target = function(g)
	g.ring(10, 10, 16, 1.8)
	g.dot(10, 10, 5.4)
end
ICONS.arrow = function(g)
	g.bar(8.6, 10, 11, 2)
	g.bar(13.8, 7.2, 6.4, 2, 45)
	g.bar(13.8, 12.8, 6.4, 2, -45)
end
ICONS.sound = function(g)
	g.box(5.6, 10, 4.4, 5.6, 1)
	g.box(9.2, 10, 6.2, 6.2, 1.2, 45)
	g.bar(14.4, 10, 1.8, 6)
	g.bar(17.2, 10, 1.8, 10)
end
ICONS.layers = function(g)
	g.outline(10, 12.4, 12.5, 6.2, 2.2, 1.6)
	g.outline(10, 9.6, 12.5, 6.2, 2.2, 1.6)
	g.outline(10, 6.8, 12.5, 6.2, 2.2, 1.6)
end
ICONS.bolt = function(g)
	g.bar(11.2, 6.6, 2.4, 9.6, 24)
	g.bar(8.8, 13.4, 2.4, 9.6, 24)
	g.bar(10, 10, 6.4, 2.2, 0)
end
ICONS.clock = function(g)
	g.ring(10, 10, 16.5, 1.8)
	g.bar(10, 7.2, 1.8, 6.4)
	g.bar(12.6, 10, 5.2, 1.8)
end
ICONS.reset = function(g)
	-- a circular arrow: an open ring of short tangent bars (from the upper right, round the bottom, up the left side) with an
	-- arrowhead at its upper-left end
	local r = 6.2
	for a = 40, 320, 28 do
		local rad = math.rad(a)
		g.bar(10 + r * math.sin(rad), 10 - r * math.cos(rad), 4.2, 2.1, a)
	end
	g.bar(4.66, 4.2, 5, 2.1, 2)
	g.bar(6.81, 6.76, 5, 2.1, -82)
end

-- returns { Instance, SetRole(role, seconds) }
local function drawIcon(name, parent, size, role, o)
	o = o or {}
	local S = size or 20
	local k = S / 20
	local builder = ICONS[name] or ICONS.dots
	local root = Util.new("Frame", {
		Name = "Icon_" .. name,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(S, S),
		AnchorPoint = o.anchor or Vector2.new(0, 0),
		Position = o.position or UDim2.new(0, 0, 0, 0),
		LayoutOrder = o.order or 0,
		Rotation = o.rotation or 0,
		ZIndex = o.zindex or 1,
	}, parent)
	local pieces = {}
	local currentRole = role or "Text"

	local function register(inst, prop)
		pieces[#pieces + 1] = { inst = inst, prop = prop }
		Theme.bind(inst, prop, currentRole)
	end
	local function place(inst, cx, cy, w, h, rot)
		inst.AnchorPoint = Vector2.new(0.5, 0.5)
		inst.Position = UDim2.fromOffset(cx * k, cy * k)
		inst.Size = UDim2.fromOffset(math.max(1, w * k), math.max(1, h * k))
		inst.Rotation = rot or 0
		inst.ZIndex = root.ZIndex
	end
	local g = {}
	function g.bar(cx, cy, w, h, rot)
		local f = Util.new("Frame", { BorderSizePixel = 0 }, root)
		place(f, cx, cy, w, h, rot)
		Util.new("UICorner", { CornerRadius = UDim.new(0.5, 0) }, f)
		register(f, "BackgroundColor3")
	end
	function g.dot(cx, cy, d)
		g.bar(cx, cy, d, d, 0)
	end
	function g.box(cx, cy, w, h, r, rot)
		local f = Util.new("Frame", { BorderSizePixel = 0 }, root)
		place(f, cx, cy, w, h, rot or 0)
		Util.new("UICorner", { CornerRadius = UDim.new(0, math.max(0, r * k)) }, f)
		register(f, "BackgroundColor3")
	end
	function g.ring(cx, cy, d, thickness)
		local f = Util.new("Frame", { BorderSizePixel = 0, BackgroundTransparency = 1 }, root)
		place(f, cx, cy, d, d, 0)
		Util.new("UICorner", { CornerRadius = UDim.new(0.5, 0) }, f)
		local stroke = Util.new("UIStroke", { Thickness = math.max(1, thickness * k), ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, f)
		register(stroke, "Color")
	end
	function g.outline(cx, cy, w, h, r, thickness)
		local f = Util.new("Frame", { BorderSizePixel = 0, BackgroundTransparency = 1 }, root)
		place(f, cx, cy, w, h, 0)
		Util.new("UICorner", { CornerRadius = UDim.new(0, math.max(0, r * k)) }, f)
		local stroke = Util.new("UIStroke", { Thickness = math.max(1, thickness * k), ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, f)
		register(stroke, "Color")
	end
	-- filled triangle: dir = 1 points right, -1 points left. Frames have no diagonal edges, so it is built from thin vertical
	-- slivers of falling height (no image, no font glyph).
	function g.tri(cx, cy, w, h, dir)
		local n = 12
		local step = w / n
		for i = 0, n - 1 do
			local height = math.max(h * (1 - i / n), h / n)
			local x
			if (dir or 1) >= 0 then
				x = cx - w / 2 + (i + 0.5) * step
			else
				x = cx + w / 2 - (i + 0.5) * step
			end
			local f = Util.new("Frame", { BorderSizePixel = 0 }, root)
			place(f, x, cy, step + 0.45, height, 0)
			register(f, "BackgroundColor3")
		end
	end
	builder(g)

	local api = { Instance = root }
	function api.SetRole(newRole, seconds)
		currentRole = newRole
		for _, piece in ipairs(pieces) do
			if seconds and seconds > 0 then
				Theme.tweenRole(piece.inst, piece.prop, newRole, seconds)
			else
				Theme.bind(piece.inst, piece.prop, newRole)
			end
		end
	end
	return api
end

----------------------------------------------------------------------------------------------------
-- UI.icon: a real Lucide image when the icon pack knows the name, the frame drawing above otherwise.
-- returns { Instance, SetRole(role, seconds) }
----------------------------------------------------------------------------------------------------
function UI.icon(name, parent, size, role, o)
	local data = Icons.resolve(name)
	if not data then
		return drawIcon(name, parent, size, role, o)
	end
	o = o or {}
	local S = size or 20
	local root = Util.new("Frame", {
		Name = "Icon_" .. tostring(name),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(S, S),
		AnchorPoint = o.anchor or Vector2.new(0, 0),
		Position = o.position or UDim2.new(0, 0, 0, 0),
		LayoutOrder = o.order or 0,
		Rotation = o.rotation or 0,
		ZIndex = o.zindex or 1,
	}, parent)
	local glyph = Util.new("ImageLabel", {
		Name = "Glyph",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		Image = data.Image,
		ScaleType = Enum.ScaleType.Fit,
		ZIndex = root.ZIndex,
	}, root)
	if data.Size then
		glyph.ImageRectSize = data.Size
	end
	if data.Position then
		glyph.ImageRectOffset = data.Position
	end
	local currentRole = role or "Text"
	Theme.bind(glyph, "ImageColor3", currentRole)
	local api = { Instance = root, Glyph = glyph }
	function api.SetRole(newRole, seconds)
		currentRole = newRole
		if seconds and seconds > 0 then
			Theme.tweenRole(glyph, "ImageColor3", newRole, seconds)
		else
			Theme.bind(glyph, "ImageColor3", newRole)
		end
	end
	return api
end

----------------------------------------------------------------------------------------------------
-- pressable feedback: hover / press overlay + press scale. Returns a state table.
----------------------------------------------------------------------------------------------------
function UI.pressable(hit, face, o)
	o = o or {}
	local state = { pressed = false, hover = false, dragged = false, disabled = false }
	local overlay = Util.new("Frame", {
		Name = "Fx",
		Active = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = face.ZIndex + 4,
	}, face)
	Theme.bind(overlay, "BackgroundColor3", o.overlayRole or "Text")
	if o.radius then
		Util.corner(overlay, o.radius)
	end
	local scaler = Util.new("UIScale", { Scale = 1 }, face)

	local function render()
		local alpha, scale = 1, 1
		if state.disabled then
			alpha = 1
		elseif state.pressed then
			alpha, scale = o.pressAlpha or 0.82, o.pressScale or 0.965
		elseif state.hover then
			alpha = o.hoverAlpha or 0.92
		end
		Motion.tween(overlay, { BackgroundTransparency = alpha }, state.pressed and 0.06 or 0.18)
		if state.pressed then
			Motion.tween(scaler, { Scale = scale }, 0.09, Enum.EasingStyle.Quad)
		else
			Motion.tween(scaler, { Scale = scale }, 0.34, Enum.EasingStyle.Back)
		end
	end
	state.render = render

	hit.InputBegan:Connect(function(input)
		if state.disabled or not isPress(input) then
			return
		end
		state.pressed = true
		state.dragged = false
		local origin = input.Position
		render()
		UI.watchInput(input, function(i)
			if state.dragged then
				return
			end
			local d = i.Position - origin
			if math.abs(d.X) + math.abs(d.Y) > 14 then
				state.dragged = true
				state.pressed = false
				render()
			end
		end, function()
			state.pressed = false
			render()
		end)
	end)

	if UserInputService.MouseEnabled then
		hit.MouseEnter:Connect(function()
			state.hover = true
			render()
		end)
		hit.MouseLeave:Connect(function()
			state.hover = false
			state.pressed = false
			render()
		end)
	end

	-- true when this activation should be ignored because the finger dragged (scroll gesture)
	function state.wasDrag()
		if state.dragged then
			state.dragged = false
			return true
		end
		return false
	end
	return state
end

----------------------------------------------------------------------------------------------------
-- button
----------------------------------------------------------------------------------------------------
-- o: parent, text, kind ("primary" | "secondary" | "ghost" | "danger"), width, height, size,
--    anchor, position, order, icon, small, sound, cooldown, onClick(api)
function UI.button(o)
	local kind = o.kind or "secondary"
	local radius = o.radius or UDim.new(0.5, 0) -- capsule buttons, like iOS
	local hit = Util.new("TextButton", {
		Name = o.name or "Button",
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = o.size or UDim2.fromOffset(o.width or 100, o.height or UI.metrics.buttonH),
		AnchorPoint = o.anchor or Vector2.new(0, 0),
		Position = o.position or UDim2.new(0, 0, 0, 0),
		LayoutOrder = o.order or 0,
		ZIndex = o.zindex or 1,
	}, o.parent)
	local face = Util.new("Frame", {
		Name = "Face",
		Active = false,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BorderSizePixel = 0,
		ZIndex = hit.ZIndex,
	}, hit)
	Util.corner(face, radius)

	local textRole, overlayRole = "Text", "Text"
	if kind == "primary" then
		face.BackgroundColor3 = Color3.new(1, 1, 1)
		local gradient = Util.new("UIGradient", { Rotation = 25 }, face)
		Theme.gradient(gradient, Theme.G.accent)
		textRole, overlayRole = "OnAccent", "OnAccent"
	elseif kind == "danger" then
		Theme.bind(face, "BackgroundColor3", "Danger")
		textRole, overlayRole = "OnDanger", "OnDanger"
	elseif kind == "ghost" then
		face.BackgroundTransparency = 1
		Theme.bind(Util.stroke(face, nil, 1), "Color", "Border")
	else
		Theme.bind(face, "BackgroundColor3", "AccentSoft")
	end
	if kind ~= "ghost" then
		UI.gloss(face, kind == "primary" and 1 or 0.7, hit.ZIndex)
	end

	local label = Util.new("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = o.text or "",
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = hit.ZIndex + 1,
	}, face)
	Util.pad(label, o.icon and 30 or 10, 0, 10, 0)
	Typo.apply(label, o.small and "buttonSmall" or "button")
	Theme.bind(label, "TextColor3", textRole)

	local api = { Instance = hit, Face = face, Label = label, enabled = true, last = 0, kind = kind }

	-- icon (optional). SetIcon(name) swaps it later, e.g. minimize <-> restore. o.iconRole overrides its colour.
	local function buildIcon(name)
		if api.Icon then
			api.Icon.Instance:Destroy()
			api.Icon = nil
		end
		if not name then
			return
		end
		local iconOnly = (o.text == nil or o.text == "")
		api.Icon = UI.icon(name, face, 16, o.iconRole or textRole, {
			anchor = iconOnly and Vector2.new(0.5, 0.5) or Vector2.new(0, 0.5),
			position = iconOnly and UDim2.fromScale(0.5, 0.5) or UDim2.new(0, 10, 0.5, 0),
			zindex = hit.ZIndex + 1,
		})
	end
	buildIcon(o.icon)
	api.SetIcon = buildIcon

	local state = UI.pressable(hit, face, { radius = radius, overlayRole = overlayRole })

	function api.SetText(text)
		label.Text = tostring(text)
	end
	function api.SetEnabled(enabled, reason)
		api.enabled = enabled and true or false
		api.reason = reason
		state.disabled = not api.enabled
		Motion.tween(label, { TextTransparency = api.enabled and 0 or 0.55 }, 0.15)
		Motion.tween(face, { BackgroundTransparency = (api.enabled or kind == "ghost") and (kind == "ghost" and 1 or 0) or 0.45 }, 0.15)
		state.render()
	end
	function api.SetBusy(busy, text)
		api.busy = busy and true or false
		if busy then
			api.idleText = api.idleText or label.Text
			label.Text = text or "Working..."
			api.SetEnabled(false)
		else
			if api.idleText then
				label.Text = api.idleText
				api.idleText = nil
			end
			api.SetEnabled(true)
		end
	end

	hit.Activated:Connect(function()
		if state.wasDrag() then
			return
		end
		if not api.enabled then
			UI.shake(face)
			if api.reason and os.clock() - (api.lastReason or 0) > 2 then
				api.lastReason = os.clock()
				Notify.warn("Unavailable", api.reason)
			end
			return
		end
		local now = os.clock()
		if now - api.last < (o.cooldown or 0.2) then
			return
		end
		api.last = now
		Sfx.play(o.sound or "click")
		if o.onClick then
			Util.try("button " .. tostring(o.text), o.onClick, api)
		end
	end)
	return api
end

----------------------------------------------------------------------------------------------------
-- toggle (switch): an iOS-style capsule with a white glass knob. The knob stretches while it is held and while it travels, then
-- settles with a small spring (the liquid feel).
----------------------------------------------------------------------------------------------------
-- o: parent, value, onChange(value), anchor, position, order, name
function UI.toggle(o)
	local value = o.value and true or false
	local TW, TH, K, PAD = 50, 30, 26, 2
	local restOff, restOn = PAD + K / 2, TW - PAD - K / 2 -- knob centres (px from the track's left edge)
	local hit = Util.new("TextButton", {
		Name = o.name or "Toggle",
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(60, 40),
		AnchorPoint = o.anchor or Vector2.new(0, 0),
		Position = o.position or UDim2.new(0, 0, 0, 0),
		LayoutOrder = o.order or 0,
	}, o.parent)
	local face = Util.new("Frame", {
		Name = "Face", Active = false, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(TW, TH), BackgroundTransparency = 1, BorderSizePixel = 0,
	}, hit)
	local track = Util.new("Frame", { Name = "Track", Size = UDim2.fromScale(1, 1), BorderSizePixel = 0 }, face)
	Util.round_corner(track)
	Theme.bind(track, "BackgroundColor3", "Track")
	local trackStroke = Util.stroke(track, nil, 1, 0.35)
	Theme.bind(trackStroke, "Color", "Border")

	local fill = Util.new("Frame", {
		Name = "On", Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = value and 0 or 1, ZIndex = 2,
	}, face)
	Util.round_corner(fill)
	Theme.gradient(Util.new("UIGradient", { Rotation = 0 }, fill), Theme.G.accent)
	UI.gloss(fill, 0.8, 2)

	-- the knob: a holder (so the shadow and the disc stretch together) with a white disc on two soft shadow discs
	local knob = Util.new("Frame", {
		Name = "Knob", BackgroundTransparency = 1, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(K, K), Position = UDim2.new(0, value and restOn or restOff, 0.5, 0), ZIndex = 3,
	}, face)
	for index, spec in ipairs({ { 4, 0.9 }, { 1, 0.8 } }) do
		local shadow = Util.new("Frame", {
			Name = "Shadow" .. index, Active = false, BorderSizePixel = 0, BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = spec[2], AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 2),
			Size = UDim2.new(1, spec[1], 1, spec[1]), ZIndex = 3,
		}, knob)
		Util.round_corner(shadow)
	end
	local disc = Util.new("Frame", {
		Name = "Disc", Active = false, BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.fromScale(1, 1), ZIndex = 4,
	}, knob)
	Util.round_corner(disc)
	Theme.bind(Util.stroke(disc, nil, 1, 0.6), "Color", "Border")

	local state = UI.pressable(hit, face, { radius = UDim.new(0.5, 0), overlayRole = "Text", pressScale = 0.97, hoverAlpha = 0.95, pressAlpha = 0.9 })
	local api = { Instance = hit, enabled = true, last = 0 }

	local cx, width = value and restOn or restOff, K
	local travel = nil
	local function place()
		knob.Position = UDim2.new(0, cx, 0.5, 0)
		knob.Size = UDim2.fromOffset(width, K)
	end
	local function glide(toX, toW, seconds, easeFn, stretch)
		if travel then
			travel.Cancel()
			travel = nil
		end
		local fromX, fromW = cx, width
		if Motion.reduced or seconds <= 0 then
			cx, width = toX, toW
			place()
			return
		end
		travel = Motion.run(seconds, function(e)
			cx = fromX + (toX - fromX) * e
			width = fromW + (toW - fromW) * Util.clamp(e, 0, 1)
			if stretch then
				width = width + stretch * math.sin(math.pi * Util.clamp(e, 0, 1))
			end
			place()
		end, easeFn)
	end
	local function rest()
		return value and restOn or restOff
	end

	local function render(animate)
		Motion.tween(fill, { BackgroundTransparency = value and 0 or 1 }, animate and 0.24 or 0)
		if animate then
			glide(rest(), K, 0.42, Motion.ease.spring, 8)
		else
			glide(rest(), K, 0)
		end
	end

	function api.Get()
		return value
	end
	function api.Set(newValue, silent)
		newValue = newValue and true or false
		if newValue == value then
			return
		end
		value = newValue
		render(true)
		if not silent and o.onChange then
			Util.try("toggle onChange", o.onChange, value)
		end
	end
	function api.SetEnabled(enabled)
		api.enabled = enabled and true or false
		state.disabled = not api.enabled
		track.BackgroundTransparency = api.enabled and 0 or 0.5
		disc.BackgroundTransparency = api.enabled and 0 or 0.4
	end

	-- held: the knob stretches toward the side it will travel to
	hit.InputBegan:Connect(function(input)
		if not api.enabled or not isPress(input) then
			return
		end
		local dir = value and -1 or 1
		glide(rest() + dir * 3, K + 6, 0.16, Motion.ease.outCubic)
		UI.watchInput(input, nil, function()
			if travel and os.clock() - api.last > 0.2 then
				glide(rest(), K, 0.24, Motion.ease.spring)
			end
		end)
	end)
	hit.Activated:Connect(function()
		if state.wasDrag() then
			glide(rest(), K, 0.2, Motion.ease.outCubic)
			return
		end
		if not api.enabled then
			UI.shake(face)
			return
		end
		local now = os.clock()
		if now - api.last < 0.14 then
			return
		end
		api.last = now
		local target = not value
		Sfx.play(target and "toggleOn" or "toggleOff")
		api.Set(target, false)
	end)
	return api
end

----------------------------------------------------------------------------------------------------
-- slider
----------------------------------------------------------------------------------------------------
-- o: parent, min, max, step, value, width, format(v) -> string, onChange(value, final), anchor, position, order
function UI.slider(o)
	local min, max, step = o.min or 0, o.max or 1, o.step or 0.01
	local value = Util.clamp(o.value or min, min, max)
	local width = o.width or 200
	local format = o.format or function(v)
		return Util.percent((v - min) / (max - min)) .. "%"
	end
	local holder = Util.new("Frame", {
		Name = o.name or "Slider", BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.fromOffset(width, 38),
		AnchorPoint = o.anchor or Vector2.new(0, 0), Position = o.position or UDim2.new(0, 0, 0, 0), LayoutOrder = o.order or 0,
	}, o.parent)
	local labelWidth = 46
	local track = Util.new("Frame", {
		Name = "Track", AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 8, 0.5, 0),
		Size = UDim2.new(1, -(labelWidth + 22), 0, 6), BorderSizePixel = 0,
	}, holder)
	Util.round_corner(track)
	Theme.bind(track, "BackgroundColor3", "Track")
	local fill = Util.new("Frame", {
		Name = "Fill", Size = UDim2.fromScale(0, 1), BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1),
	}, track)
	Util.round_corner(fill)
	Theme.gradient(Util.new("UIGradient", { Rotation = 0 }, fill), Theme.G.accent)
	UI.gloss(fill, 0.7, 2)
	-- the knob is a white glass disc on two soft shadow discs; while it is held it stretches into a capsule
	local knob = Util.new("Frame", {
		Name = "Knob", BackgroundTransparency = 1, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(22, 22), ZIndex = 3,
	}, track)
	for index, spec in ipairs({ { 5, 0.9 }, { 1, 0.8 } }) do
		local shadow = Util.new("Frame", {
			Name = "Shadow" .. index, Active = false, BorderSizePixel = 0, BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = spec[2], AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 2),
			Size = UDim2.new(1, spec[1], 1, spec[1]), ZIndex = 3,
		}, knob)
		Util.round_corner(shadow)
	end
	local disc = Util.new("Frame", {
		Name = "Disc", Active = false, BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.fromScale(1, 1), ZIndex = 4,
	}, knob)
	Util.round_corner(disc)
	Theme.bind(Util.stroke(disc, nil, 1, 0.55), "Color", "Border")
	local readout = Util.new("TextLabel", {
		Name = "Value", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(labelWidth, 20), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Right, Text = "",
	}, holder)
	Typo.apply(readout, "caption")
	Theme.bind(readout, "TextColor3", "Muted")

	local hit = Util.new("TextButton", {
		Name = "Hit", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.new(1, -(labelWidth + 4), 1, 0), ZIndex = 5,
	}, holder)

	local api = { Instance = holder, enabled = true }
	local dragging = false
	local lastTick = 0

	local function render(animate)
		local alpha = (value - min) / (max - min)
		local dur = animate and 0.12 or 0
		Motion.tween(fill, { Size = UDim2.fromScale(alpha, 1) }, dur)
		Motion.tween(knob, { Position = UDim2.fromScale(alpha, 0.5) }, dur)
		readout.Text = format(value)
	end

	local function snap(raw)
		local snapped = min + Util.round(raw - min, step)
		snapped = math.floor(snapped * 10000 + 0.5) / 10000
		return Util.clamp(snapped, min, max)
	end

	local function setFromX(x, final)
		local width_ = track.AbsoluteSize.X
		if width_ <= 0 then
			return
		end
		local alpha = Util.clamp((x - track.AbsolutePosition.X) / width_, 0, 1)
		local newValue = snap(min + alpha * (max - min))
		if newValue ~= value then
			value = newValue
			render(false)
			local now = os.clock()
			if now - lastTick > 0.07 then
				lastTick = now
				Sfx.play("select")
			end
			if o.onChange then
				Util.try("slider onChange", o.onChange, value, false)
			end
		end
	end

	-- Touch gestures are disambiguated so that scrolling a page never moves a slider by accident (same idea as Android's
	-- SeekBar inside a scrolling list): a touch decides after ~8 px of movement -- sideways = slider drag, vertical = the page
	-- scrolls. Pressing ON the knob never makes it jump (it keeps its offset to the finger); pressing on the bare track and
	-- dragging sideways, or just tapping, moves the knob to that spot. A mouse press acts at once.
	hit.InputBegan:Connect(function(input)
		if not api.enabled or dragging or not isPress(input) then
			return
		end
		dragging = true
		local isTouch = input.UserInputType == Enum.UserInputType.Touch
		local scroller = UI.findScroller(holder)
		local origin = input.Position
		local decided = not isTouch
		local engaged = false
		local knobX = knob.AbsolutePosition.X + knob.AbsoluteSize.X / 2
		local grabOffset = 0
		if math.abs(origin.X - knobX) <= 20 then
			grabOffset = origin.X - knobX
		end
		local function engage()
			if engaged then
				return
			end
			engaged = true
			decided = true
			if scroller then
				scroller.ScrollingEnabled = false
			end
			Motion.tween(knob, { Size = UDim2.fromOffset(32, 24) }, 0.28, Enum.EasingStyle.Back)
		end
		if not isTouch then
			engage()
			setFromX(origin.X - grabOffset)
		end
		UI.watchInput(input, function(i)
			local delta = i.Position - origin
			if not decided then
				if math.abs(delta.X) + math.abs(delta.Y) < 8 then
					return
				end
				decided = true
				if math.abs(delta.X) >= math.abs(delta.Y) then
					engage()
					setFromX(i.Position.X - grabOffset)
				end
				return
			end
			if engaged then
				setFromX(i.Position.X - grabOffset)
			end
		end, function(cancelled)
			dragging = false
			if not decided and not cancelled then
				engage()
				setFromX(origin.X - grabOffset) -- a tap
			end
			if engaged then
				if scroller then
					scroller.ScrollingEnabled = true
				end
				Motion.tween(knob, { Size = UDim2.fromOffset(22, 22) }, 0.3, Enum.EasingStyle.Back)
				if o.onChange then
					Util.try("slider onChange", o.onChange, value, true)
				end
			end
		end)
	end)

	function api.Get()
		return value
	end
	function api.Set(newValue, silent)
		newValue = snap(newValue)
		if newValue == value then
			return
		end
		value = newValue
		render(true)
		if not silent and o.onChange then
			Util.try("slider onChange", o.onChange, value, true)
		end
	end
	function api.SetEnabled(enabled)
		api.enabled = enabled and true or false
		holder.BackgroundTransparency = 1
		track.BackgroundTransparency = api.enabled and 0 or 0.5
		disc.BackgroundTransparency = api.enabled and 0 or 0.4
	end
	render(false)
	return api
end

----------------------------------------------------------------------------------------------------
-- stepper:  [-]  value  [+]
----------------------------------------------------------------------------------------------------
-- o: parent, min, max, step, value, format(v), onChange(v), anchor, position, order
function UI.stepper(o)
	local min, max, step = o.min, o.max, o.step
	local value = Util.clamp(o.value or min, min, max)
	local format = o.format or function(v)
		return tostring(v)
	end
	local holder = Util.new("Frame", {
		Name = o.name or "Stepper", BackgroundTransparency = 1, Size = UDim2.fromOffset(150, 38),
		AnchorPoint = o.anchor or Vector2.new(0, 0), Position = o.position or UDim2.new(0, 0, 0, 0), LayoutOrder = o.order or 0,
	}, o.parent)
	local readout = Util.new("TextLabel", {
		Name = "Value", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0, 56, 0, 24), BackgroundTransparency = 1, Text = "",
	}, holder)
	Typo.apply(readout, "heading")
	Theme.bind(readout, "TextColor3", "Text")
	local api = { Instance = holder }
	local function render()
		readout.Text = format(value)
	end
	local function change(delta)
		local newValue = Util.clamp(Util.round(value + delta, step), min, max)
		newValue = Util.round(newValue * 1000) / 1000
		if newValue ~= value then
			value = newValue
			render()
			if o.onChange then
				Util.try("stepper onChange", o.onChange, value)
			end
		else
			Sfx.play("warning")
			UI.shake(holder)
		end
	end
	local minus = UI.button({
		parent = holder, text = "", icon = "minus", width = 42, height = 34, anchor = Vector2.new(0, 0.5),
		position = UDim2.new(0, 0, 0.5, 0), cooldown = 0.08, name = "Minus", onClick = function()
			change(-step)
		end,
	})
	minus.Label.Text = ""
	local plus = UI.button({
		parent = holder, text = "", icon = "plus", width = 42, height = 34, anchor = Vector2.new(1, 0.5),
		position = UDim2.new(1, 0, 0.5, 0), cooldown = 0.08, name = "Plus", onClick = function()
			change(step)
		end,
	})
	plus.Label.Text = ""
	function api.Get()
		return value
	end
	function api.Set(newValue, silent)
		newValue = Util.clamp(newValue, min, max)
		if newValue ~= value then
			value = newValue
			render()
			if not silent and o.onChange then
				Util.try("stepper onChange", o.onChange, value)
			end
		end
	end
	render()
	return api
end

----------------------------------------------------------------------------------------------------
-- segmented selector (2-4 short options): a capsule track with a glossy accent pill. When the choice changes the pill
-- stretches toward the new option and then catches up (a liquid drop sliding along a rail).
----------------------------------------------------------------------------------------------------
-- o: parent, options = { {id=, label=}, ... }, value, onChange(id), width, height, anchor, position, order
function UI.segmented(o)
	local options = o.options
	local count = #options
	local index = 1
	for i, opt in ipairs(options) do
		if opt.id == o.value then
			index = i
		end
	end
	local holder = Util.new("Frame", {
		Name = o.name or "Segmented", BorderSizePixel = 0,
		Size = o.size or UDim2.fromOffset(o.width or 220, o.height or 36),
		AnchorPoint = o.anchor or Vector2.new(0, 0), Position = o.position or UDim2.new(0, 0, 0, 0), LayoutOrder = o.order or 0,
	}, o.parent)
	Util.corner(holder, UDim.new(0.5, 0))
	Theme.bind(holder, "BackgroundColor3", "Track", "Panel", 0.4)
	Theme.bind(Util.stroke(holder, nil, 1, 0.4), "Color", "Border")

	local pill = Util.new("Frame", {
		Name = "Pill", BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 2,
		Size = UDim2.new(1 / count, -6, 1, -6), Position = UDim2.new((index - 1) / count, 3, 0, 3),
	}, holder)
	Util.corner(pill, UDim.new(0.5, 0))
	Theme.gradient(Util.new("UIGradient", { Rotation = 20 }, pill), Theme.G.accent)
	UI.gloss(pill, 0.9, 2)

	local buttons, labels = {}, {}
	local api = { Instance = holder, enabled = true, last = 0 }
	local shown = (index - 1) / count -- the pill's left edge as a fraction of the track (it moves while the pill glides)
	local glide = nil

	local function setPill(left, right)
		pill.Position = UDim2.new(left, 3, 0, 3)
		pill.Size = UDim2.new(right - left, -6, 1, -6)
	end

	local function paint(animate)
		local dur = animate and 0.22 or 0
		local target = (index - 1) / count
		if glide then
			glide.Cancel()
			glide = nil
		end
		if animate and not Motion.reduced and math.abs(target - shown) > 0.0001 then
			local from = shown
			local segment = 1 / count
			glide = Motion.run(0.44, function(p)
				-- the leading edge races ahead, the trailing edge follows a beat later (and overshoots a little)
				local lead = from + (target - from) * Motion.ease.outQuint(p)
				local trail = from + (target - from) * Motion.ease.outBack(Util.clamp((p - 0.1) / 0.9, 0, 1))
				local left, right = math.min(lead, trail), math.max(lead, trail) + segment
				setPill(left, right)
				shown = lead
			end, Motion.ease.linear, function()
				shown = target
				setPill(target, target + segment)
			end)
		else
			shown = target
			setPill(target, target + 1 / count)
		end
		for i, label in ipairs(labels) do
			Theme.tweenRole(label, "TextColor3", i == index and "OnAccent" or "Muted", dur)
		end
	end

	for i, opt in ipairs(options) do
		local hit = Util.new("TextButton", {
			Name = "Opt_" .. tostring(opt.id), Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0,
			Size = UDim2.new(1 / count, 0, 1, 0), Position = UDim2.new((i - 1) / count, 0, 0, 0), ZIndex = 3,
		}, holder)
		local label = Util.new("TextLabel", {
			BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = opt.label, ZIndex = 4,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, hit)
		Util.pad(label, 4, 0, 4, 0)
		Typo.apply(label, "buttonSmall")
		Theme.bind(label, "TextColor3", i == index and "OnAccent" or "Muted")
		buttons[i], labels[i] = hit, label
		local state = { dragged = false }
		hit.InputBegan:Connect(function(input)
			if isPress(input) then
				state.dragged = false
				local origin = input.Position
				UI.watchInput(input, function(ev)
					local d = ev.Position - origin
					if math.abs(d.X) + math.abs(d.Y) > 14 then
						state.dragged = true
					end
				end, nil)
			end
		end)
		hit.Activated:Connect(function()
			if state.dragged then
				state.dragged = false
				return
			end
			if not api.enabled then
				UI.shake(holder)
				return
			end
			if i == index then
				return
			end
			local now = os.clock()
			if now - api.last < 0.12 then
				return
			end
			api.last = now
			index = i
			Sfx.play("select")
			paint(true)
			if o.onChange then
				Util.try("segmented onChange", o.onChange, opt.id)
			end
		end)
	end

	function api.Get()
		return options[index].id
	end
	function api.Set(id, silent)
		for i, opt in ipairs(options) do
			if opt.id == id and i ~= index then
				index = i
				paint(true)
				if not silent and o.onChange then
					Util.try("segmented onChange", o.onChange, id)
				end
				return
			end
		end
	end
	-- 2.8.1: the text of one option (a count that follows a list, for instance "Online 12")
	function api.SetLabel(id, text)
		for i, opt in ipairs(options) do
			if opt.id == id and labels[i] then
				opt.label = text
				labels[i].Text = text
				return
			end
		end
	end
	function api.SetEnabled(enabled)
		api.enabled = enabled and true or false
		for _, label in ipairs(labels) do
			label.TextTransparency = api.enabled and 0 or 0.55
		end
	end
	paint(false)
	return api
end
end -- [05_ui_base.lua]

do -- [06_ui_more.lua]

----------------------------------------------------------------------------------------------------
-- UI kit, part 2: cards, sections, pages, chips, stat tiles, dropdown, text input, confirm dialog
----------------------------------------------------------------------------------------------------
function UI.prune()
	Theme.prune()
	Typo.prune()
end

-- Card with title + description on the left and an optional control area on the right. An optional icon tile (a rounded square
-- with a drawn icon, like the rows of the iOS Settings app) sits at the left.
-- o: parent, title, desc, order, control (px reserved on the right), stack (controls below the text),
--    controlHeight (stack mode), minHeight, name, icon (name of a drawn icon), iconRole (colour of the tile, default "Accent")
-- returns { Instance, Title, Desc, Controls, SetTitle, SetDesc }
function UI.card(o)
	local controlWidth = o.control or 0
	local card = Util.new("Frame", {
		Name = o.name or "Card",
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, o.minHeight or UI.metrics.rowH),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = o.order or 0,
	}, o.parent)
	Theme.surface(card, "Card", "card")
	Util.corner(card, 16)
	-- a hairline glass rim: a little brighter at the top left and the bottom right
	local stroke = Util.stroke(card, nil, 1, 0.3)
	Theme.gradient(Util.new("UIGradient", { Rotation = 45 }, stroke), Theme.G.rim, true)
	Util.pad(card, 16, 13, 14, 13)

	local indent = o.icon and 42 or 0
	local inner = Util.new("Frame", {
		Name = "Inner", BackgroundTransparency = 1, Position = UDim2.fromOffset(indent, 0), Size = UDim2.new(1, -indent, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	}, card)
	Util.list(inner, 9)
	if o.icon then
		local tile = Util.new("Frame", { Name = "IconTile", BorderSizePixel = 0, Size = UDim2.fromOffset(30, 30), BackgroundColor3 = UI.WHITE }, card)
		Util.corner(tile, 9)
		local tileRole = o.iconRole or "Accent"
		Theme.gradient(Util.new("UIGradient", { Rotation = 90 }, tile), function(l)
			local base = l[tileRole] or l.Accent
			return ColorSequence.new(Util.lighten(base, 0.18), Util.darken(base, 0.14))
		end)
		UI.gloss(tile, 0.8, 1)
		UI.icon(o.icon, tile, 18, "OnAccent", { anchor = Vector2.new(0.5, 0.5), position = UDim2.fromScale(0.5, 0.5), zindex = 3 })
	end

	local sideControls = controlWidth > 0 and not o.stack
	local textBlock = Util.new("Frame", {
		Name = "Text", BackgroundTransparency = 1, LayoutOrder = 1, AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, sideControls and -(controlWidth + 12) or 0, 0, 0),
	}, inner)
	Util.list(textBlock, 3)

	local title = Util.new("TextLabel", {
		Name = "Title", BackgroundTransparency = 1, LayoutOrder = 1, Text = o.title or "",
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
	}, textBlock)
	Typo.apply(title, "heading")
	Theme.bind(title, "TextColor3", "Text")

	local desc = Util.new("TextLabel", {
		Name = "Desc", BackgroundTransparency = 1, LayoutOrder = 2, Text = o.desc or "",
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
		Visible = (o.desc ~= nil and o.desc ~= ""),
	}, textBlock)
	Typo.apply(desc, "caption")
	Theme.bind(desc, "TextColor3", "Muted")

	local controlHeight = o.controlHeight or 38
	local controls
	if o.stack then
		controls = Util.new("Frame", {
			Name = "Controls", BackgroundTransparency = 1, LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0, controlHeight),
		}, inner)
	else
		controls = Util.new("Frame", {
			Name = "Controls", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0, controlWidth, 0, controlHeight),
		}, card)
	end

	local api = {
		Instance = card, Title = title, Desc = desc, Controls = controls,
		controlWidth = controlWidth, stacked = o.stack and true or false, indent = indent,
	}
	function api.SetTitle(text)
		title.Text = tostring(text)
	end
	function api.SetDesc(text)
		desc.Text = tostring(text)
		desc.Visible = text ~= nil and text ~= ""
	end
	-- Moves the controls below the text (narrow windows) or back to the right side (wide windows).
	function api.SetStacked(flag)
		flag = flag and true or false
		if controlWidth <= 0 or api.stacked == flag then
			return
		end
		api.stacked = flag
		if flag then
			controls.Parent = inner
			controls.LayoutOrder = 2
			controls.AnchorPoint = Vector2.new(0, 0)
			controls.Position = UDim2.new(0, 0, 0, 0)
			controls.Size = UDim2.new(1, 0, 0, controlHeight)
			textBlock.Size = UDim2.new(1, 0, 0, 0)
		else
			controls.Parent = card
			controls.AnchorPoint = Vector2.new(1, 0.5)
			controls.Position = UDim2.new(1, 0, 0.5, 0)
			controls.Size = UDim2.new(0, controlWidth, 0, controlHeight)
			textBlock.Size = UDim2.new(1, -(controlWidth + 12), 0, 0)
		end
	end
	-- a pulse of light around the card (after a jump from the search)
	function api.Flash()
		local host = Win.ui and Win.ui.pageHost
		return UI.spotlight(card, { clip = host, radius = 18 })
	end
	-- the jump search registers every card it can find (see Pages.searchIndex)
	if o.search ~= false and Pages.building then
		Pages.indexCard(api, o)
	end
	return api
end

-- a section heading: the logo's diamond, then the name in sentence case; `count` (optional) is a small number on the right
function UI.section(parent, text, order, count)
	local row = Util.new("Frame", {
		Name = "Section", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32), LayoutOrder = order or 0,
	}, parent)
	local mark = Util.new("Frame", {
		Name = "Mark", AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 5, 1, -8), Size = UDim2.fromOffset(7, 7),
		Rotation = 45, BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1),
	}, row)
	Util.corner(mark, 2)
	Theme.gradient(Util.new("UIGradient", { Rotation = 90 }, mark), Theme.G.accent)
	local label = Util.new("TextLabel", {
		Name = "Label", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 20, 1, -2),
		Size = UDim2.new(1, -60, 0, 22), Text = text, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
	}, row)
	Typo.apply(label, "section")
	Theme.bind(label, "TextColor3", "Text")
	if count ~= nil then
		local number = Util.new("TextLabel", {
			Name = "Count", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -4, 1, -2),
			Size = UDim2.fromOffset(40, 22), Text = tostring(count), TextXAlignment = Enum.TextXAlignment.Right,
		}, row)
		Typo.apply(number, "caption")
		Theme.bind(number, "TextColor3", "Muted")
	end
	return row
end

function UI.page(parent, name)
	local page = Util.new("ScrollingFrame", {
		Name = name .. "Page",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 3,
		ScrollBarImageTransparency = 0.35,
		Visible = false,
	}, parent)
	Theme.bind(page, "ScrollBarImageColor3", "Accent")
	Util.pad(page, 0, 2, 7, 16)
	Util.list(page, 10)
	return page
end

-- small status pill. o: parent, text, role ("Green" | "Warn" | "Danger" | "Accent" | "Muted"), order, anchor, position
function UI.chip(o)
	local role = o.role or "Accent"
	local chip = Util.new("Frame", {
		Name = "Chip", BorderSizePixel = 0, Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = o.order or 0, AnchorPoint = o.anchor or Vector2.new(0, 0), Position = o.position or UDim2.new(0, 0, 0, 0),
	}, o.parent)
	Util.round_corner(chip)
	Theme.bind(chip, "BackgroundColor3", "Card", role, 0.2)
	Util.pad(chip, 9, 0, 9, 0)
	local label = Util.new("TextLabel", {
		Name = "Label", BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X,
		Text = o.text or "",
	}, chip)
	Typo.apply(label, "label", 10)
	Theme.bind(label, "TextColor3", role)
	local api = { Instance = chip }
	function api.Set(text, newRole)
		label.Text = tostring(text)
		if newRole then
			Theme.bind(chip, "BackgroundColor3", "Card", newRole, 0.2)
			Theme.tweenRole(label, "TextColor3", newRole, 0.2)
		end
	end
	return api
end

-- compact value tile (FPS, ping ...). o: parent, label, value, order, size
function UI.statTile(o)
	local tile = Util.new("Frame", {
		Name = "Stat", BorderSizePixel = 0, LayoutOrder = o.order or 0, Size = o.size or UDim2.new(1 / 3, -6, 0, 62),
	}, o.parent)
	Theme.surface(tile, "Card", "card")
	Util.corner(tile, 16)
	local stroke = Util.stroke(tile, nil, 1, 0.3)
	Theme.gradient(Util.new("UIGradient", { Rotation = 45 }, stroke), Theme.G.rim, true)
	local value = Util.new("TextLabel", {
		Name = "Value", BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 9), Size = UDim2.new(1, -28, 0, 26),
		Text = o.value or "-", TextXAlignment = Enum.TextXAlignment.Left,
	}, tile)
	Typo.apply(value, "stat")
	Theme.bind(value, "TextColor3", "Text")
	local label = Util.new("TextLabel", {
		Name = "Label", BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 37), Size = UDim2.new(1, -28, 0, 16),
		Text = o.label or "", TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
	}, tile)
	Typo.apply(label, "caption")
	Theme.bind(label, "TextColor3", "Muted")
	local api = { Instance = tile }
	function api.Set(text, role)
		value.Text = tostring(text)
		if role then
			Theme.tweenRole(value, "TextColor3", role, 0.2)
		end
	end
	return api
end

-- An inset grouped list (the look of the iOS Settings app): one rounded card that holds rows separated by hairlines.
-- Returns the holder; add rows with UI.row(group, {...}).
function UI.group(parent, order, name)
	local holder = Util.new("Frame", {
		Name = name or "Group", BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = order or 0, ClipsDescendants = true,
	}, parent)
	Theme.surface(holder, "Card", "card")
	Util.corner(holder, 16)
	local stroke = Util.stroke(holder, nil, 1, 0.3)
	Theme.gradient(Util.new("UIGradient", { Rotation = 45 }, stroke), Theme.G.rim, true)
	Util.list(holder, 0)
	return holder
end

-- A row of a grouped list. o: icon (drawn icon name, shown on a gradient tile), iconRole, title, desc (one line, truncated),
-- right (small text on the right), chevron (true = a chevron on the right), onClick(), height, name, titleRole
-- returns { Instance, SetTitle, SetDesc, SetRight }
function UI.row(group, o)
	local count = 0
	for _, child in ipairs(group:GetChildren()) do
		if child:IsA("GuiObject") then
			count = count + 1
		end
	end
	local height = o.height or ((o.desc and o.desc ~= "") and 54 or 46)
	local clickable = o.onClick ~= nil
	local row = Util.new(clickable and "TextButton" or "Frame", {
		Name = o.name or "Row", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, height),
		LayoutOrder = count + 1,
	}, group)
	if clickable then
		row.Text = ""
		row.AutoButtonColor = false
	end
	local indent = o.icon and 52 or 14
	if count > 0 then
		local line = Util.new("Frame", {
			Name = "Divider", Active = false, BorderSizePixel = 0, Position = UDim2.fromOffset(indent, 0), Size = UDim2.new(1, -indent, 0, 1),
			BackgroundTransparency = 0.55, ZIndex = 2,
		}, row)
		Theme.bind(line, "BackgroundColor3", "Border")
	end
	if o.icon then
		local tile = Util.new("Frame", {
			Name = "IconTile", BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 14, 0.5, 0),
			Size = UDim2.fromOffset(28, 28), BackgroundColor3 = UI.WHITE, ZIndex = 2,
		}, row)
		Util.corner(tile, 8)
		local tileRole = o.iconRole or "Accent"
		Theme.gradient(Util.new("UIGradient", { Rotation = 90 }, tile), function(l)
			local base = l[tileRole] or l.Accent
			return ColorSequence.new(Util.lighten(base, 0.18), Util.darken(base, 0.14))
		end)
		UI.gloss(tile, 0.8, 2)
		UI.icon(o.icon, tile, 16, "OnAccent", { anchor = Vector2.new(0.5, 0.5), position = UDim2.fromScale(0.5, 0.5), zindex = 4 })
	end
	local rightWidth = 0
	local right = nil
	if o.right and o.right ~= "" then
		rightWidth = 90
		right = Util.new("TextLabel", {
			Name = "Right", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, o.chevron and -34 or -14, 0.5, 0), Size = UDim2.fromOffset(rightWidth, 20), Text = tostring(o.right),
			TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 2,
		}, row)
		Typo.apply(right, "caption", 12)
		Theme.bind(right, "TextColor3", "Muted")
	end
	local reserve = indent + 14 + (o.chevron and 22 or 0) + (rightWidth > 0 and rightWidth + 6 or 0)
	local hasDesc = o.desc ~= nil and o.desc ~= ""
	local title = Util.new("TextLabel", {
		Name = "Title", BackgroundTransparency = 1, Position = UDim2.new(0, indent, 0, hasDesc and 8 or 0),
		Size = UDim2.new(1, -reserve, 0, hasDesc and 20 or height), Text = o.title or "", TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 2, RichText = o.rich and true or false,
	}, row)
	Typo.apply(title, "heading", 13)
	Theme.bind(title, "TextColor3", o.titleRole or "Text")
	local desc = Util.new("TextLabel", {
		Name = "Desc", BackgroundTransparency = 1, Position = UDim2.new(0, indent, 0, 28), Size = UDim2.new(1, -reserve, 0, 18),
		Text = o.desc or "", TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Visible = hasDesc, ZIndex = 2,
	}, row)
	Typo.apply(desc, "caption", 11)
	Theme.bind(desc, "TextColor3", "Muted")
	if o.chevron then
		UI.icon("chevron", row, 14, "Faint", { anchor = Vector2.new(1, 0.5), position = UDim2.new(1, -14, 0.5, 0), rotation = -90, zindex = 3 })
	end
	local api = { Instance = row }
	function api.SetTitle(text)
		title.Text = tostring(text)
	end
	function api.SetDesc(text)
		desc.Text = tostring(text or "")
	end
	function api.SetRight(text)
		if right then
			right.Text = tostring(text or "")
		end
	end
	function api.SetActive()
	end
	if clickable then
		local face = Util.new("Frame", {
			Name = "Face", Active = false, BackgroundTransparency = 1, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, -10, 1, -6), ZIndex = 1,
		}, row)
		Util.corner(face, 10)
		Theme.bind(face, "BackgroundColor3", "AccentSoft")
		-- the keyboard selection of the search results
		function api.SetActive(flag)
			Motion.tween(face, { BackgroundTransparency = flag and 0 or 1 }, 0.14)
		end
		local state = UI.pressable(row, face, { radius = 10, hoverAlpha = 0.94, pressAlpha = 0.86, pressScale = 0.99 })
		row.Activated:Connect(function()
			if state.wasDrag() then
				return
			end
			Sfx.play("click")
			Util.try("row " .. tostring(o.title), o.onClick, api)
		end)
	end
	return api
end

-- A ring of light that pulses around `inst` a few times (used after a jump from the search). It lives in its own layer, so it
-- never takes part in the layout of the page; it follows the target while the page scrolls and hides when the target leaves the
-- visible page area.
function UI.spotlight(inst, o)
	o = o or {}
	local layer = UI.layers.spot
	if not layer or not Util.alive(inst) then
		return nil
	end
	local spot = Util.new("Frame", {
		Name = "Spot", Active = false, BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 2, Visible = false,
	}, layer)
	Util.corner(spot, o.radius or 20)
	local fill = Util.new("Frame", { Name = "Fill", Active = false, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }, spot)
	Util.corner(fill, o.radius or 20)
	Theme.bind(fill, "BackgroundColor3", "Accent")
	local stroke = Util.stroke(spot, nil, 2.5, 1)
	Theme.bind(stroke, "Color", "Accent")
	local clip = o.clip
	local function place()
		if not Util.alive(inst) or not Util.alive(spot) then
			return false
		end
		local s = UI.scale()
		local pos = (inst.AbsolutePosition - layer.AbsolutePosition) / s
		local size = inst.AbsoluteSize / s
		if size.X < 4 or size.Y < 4 then
			spot.Visible = false
			return true
		end
		local visible = true
		if clip and Util.alive(clip) then
			local cp, cs = clip.AbsolutePosition, clip.AbsoluteSize
			local cx, cy = inst.AbsolutePosition.X + inst.AbsoluteSize.X / 2, inst.AbsolutePosition.Y + inst.AbsoluteSize.Y / 2
			visible = cx >= cp.X and cx <= cp.X + cs.X and cy >= cp.Y and cy <= cp.Y + cs.Y
		end
		spot.Visible = visible
		spot.Position = UDim2.fromOffset(math.floor(pos.X - 4), math.floor(pos.Y - 4))
		spot.Size = UDim2.fromOffset(math.floor(size.X + 8), math.floor(size.Y + 8))
		return true
	end
	place()
	return Motion.run(o.seconds or 1.5, function(a)
		if not place() then
			return
		end
		local k = (1 - a) * (0.5 + 0.5 * math.cos(a * 4 * math.pi))
		stroke.Transparency = 1 - k
		fill.BackgroundTransparency = 1 - 0.16 * k
	end, Motion.ease.linear, function()
		if Util.alive(spot) then
			spot:Destroy()
		end
		UI.prune()
	end)
end

----------------------------------------------------------------------------------------------------
-- Covers: the look of the Apple Books library. A cover is a small "book": a soft shadow, a binding crease, a glass sheen, and a
-- ring plus a check badge when it is the chosen one (it also lifts a few pixels, on a spring). The page paints the art of each
-- cover into `Content`.
----------------------------------------------------------------------------------------------------

-- a rounded square with a soft gradient of a theme role and a drawn icon (the tiles of the iOS Settings app)
-- o: position, anchor, zindex, radius, glyph (icon size)
function UI.iconTile(parent, icon, role, size, o)
	o = o or {}
	local z = o.zindex or 1
	local tile = Util.new("Frame", {
		Name = "IconTile", Active = false, BorderSizePixel = 0, Size = UDim2.fromOffset(size, size), BackgroundColor3 = UI.WHITE,
		Position = o.position or UDim2.new(0, 0, 0, 0), AnchorPoint = o.anchor or Vector2.new(0, 0), ZIndex = z,
	}, parent)
	Util.corner(tile, o.radius or math.floor(size * 0.3))
	local tileRole = role or "Accent"
	Theme.gradient(Util.new("UIGradient", { Rotation = 90 }, tile), function(l)
		local base = l[tileRole] or l.Accent
		return ColorSequence.new(Util.lighten(base, 0.18), Util.darken(base, 0.14))
	end)
	UI.gloss(tile, 0.8, z)
	local glyph = UI.icon(icon, tile, o.glyph or math.floor(size * 0.58), "OnAccent", {
		anchor = Vector2.new(0.5, 0.5), position = UDim2.fromScale(0.5, 0.5), zindex = z + 2,
	})
	return tile, glyph
end

-- o: parent, order, name, size (UDim2), radius (default 10), onClick(api), selected, badge (a small pill, e.g. "New"),
--    fill (Color3: the cover colour, default the theme's card colour), crease (default true), sound (default "click")
-- returns { Instance, Lift, Face, Content, Ring, Check, SetSelected(flag, instant), SetBadge(text), selected }
function UI.cover(o)
	local radius = o.radius or 10
	local hit = Util.new("TextButton", {
		Name = o.name or "Cover", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = o.size or UDim2.fromOffset(100, 130), LayoutOrder = o.order or 0,
	}, o.parent)
	local lift = Util.new("Frame", {
		Name = "Lift", Active = false, BackgroundTransparency = 1, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1),
	}, hit)
	UI.shadow(lift, radius, { dy = 5, specs = { { 1, 0.84 }, { 4, 0.92 }, { 9, 0.96 }, { 14, 0.98 } }, zindex = 1 })

	local face = Util.new("Frame", { Name = "Face", Active = false, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 2 }, lift)
	Util.corner(face, radius)
	if o.fill then
		face.BackgroundColor3 = o.fill
	else
		Theme.surface(face, "Card", "card")
	end
	local content = Util.new("Frame", {
		Name = "Content", Active = false, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 2,
	}, face)

	if o.crease ~= false then
		-- the binding: a soft shadow along the left edge, a dark hairline and a light hairline (as on a real hardcover)
		local spine = Util.new("Frame", {
			Name = "Spine", Active = false, BorderSizePixel = 0, BackgroundColor3 = Color3.new(0, 0, 0), Size = UDim2.new(0, 36, 1, 0), ZIndex = 3,
		}, face)
		Util.corner(spine, radius)
		Util.new("UIGradient", {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(0.3, 0.86), NumberSequenceKeypoint.new(1, 1),
			}),
		}, spine)
		Util.new("Frame", {
			Name = "CreaseDark", Active = false, BorderSizePixel = 0, BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.72,
			Position = UDim2.fromOffset(9, 0), Size = UDim2.new(0, 1, 1, 0), ZIndex = 3,
		}, face)
		Util.new("Frame", {
			Name = "CreaseLight", Active = false, BorderSizePixel = 0, BackgroundColor3 = UI.WHITE, BackgroundTransparency = 0.86,
			Position = UDim2.fromOffset(10, 0), Size = UDim2.new(0, 1, 1, 0), ZIndex = 3,
		}, face)
	end
	UI.glass(face, { strength = 0.9, zindex = 3, edge = true })

	-- the ring of the chosen cover sits just outside the cover
	local ring = Util.new("Frame", {
		Name = "Ring", Active = false, BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(-4, -4),
		Size = UDim2.new(1, 8, 1, 8), ZIndex = 3,
	}, lift)
	Util.corner(ring, radius + 4)
	local ringStroke = Util.stroke(ring, nil, 2, 1)
	Theme.bind(ringStroke, "Color", "Accent")

	local check = Util.new("Frame", {
		Name = "Check", Active = false, BorderSizePixel = 0, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -7, 0, 7),
		Size = UDim2.fromOffset(22, 22), BackgroundColor3 = UI.WHITE, ZIndex = 6, Visible = false,
	}, face)
	Util.round_corner(check)
	Theme.gradient(Util.new("UIGradient", { Rotation = 90 }, check), Theme.G.accent)
	Util.stroke(check, UI.WHITE, 1.5, 0.45)
	local checkScale = Util.new("UIScale", { Scale = 0.2 }, check)
	UI.icon("check", check, 14, "OnAccent", { anchor = Vector2.new(0.5, 0.5), position = UDim2.fromScale(0.5, 0.5), zindex = 7 })

	local api = { Instance = hit, Lift = lift, Face = face, Content = content, Ring = ringStroke, Check = check, selected = false }
	local pill, pillLabel
	function api.SetBadge(text)
		if not text or text == "" then
			if pill then
				pill.Visible = false
			end
			return
		end
		if not pill then
			pill = Util.new("Frame", {
				Name = "Badge", Active = false, BorderSizePixel = 0, Position = UDim2.fromOffset(16, 7), Size = UDim2.fromOffset(0, 16),
				AutomaticSize = Enum.AutomaticSize.X, ZIndex = 5,
			}, face)
			Util.round_corner(pill)
			Theme.bind(pill, "BackgroundColor3", "Accent")
			Util.pad(pill, 7, 0, 7, 0)
			pillLabel = Util.new("TextLabel", {
				Name = "Label", BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 16), AutomaticSize = Enum.AutomaticSize.X, ZIndex = 6,
			}, pill)
			Typo.apply(pillLabel, "label", 9)
			Theme.bind(pillLabel, "TextColor3", "OnAccent")
		end
		pill.Visible = true
		pillLabel.Text = tostring(text)
	end

	local token = 0
	function api.SetSelected(flag, instant)
		flag = flag and true or false
		if flag == api.selected and not instant then
			return
		end
		token = token + 1
		local mine = token
		api.selected = flag
		local d = instant and 0 or 0.3
		Motion.tween(ringStroke, { Transparency = flag and 0 or 1 }, d)
		Motion.tween(lift, { Position = UDim2.new(0.5, 0, 0.5, flag and -3 or 0) }, instant and 0 or 0.36, Enum.EasingStyle.Back)
		if flag then
			check.Visible = true
			Motion.tween(checkScale, { Scale = 1 }, instant and 0 or 0.42, Enum.EasingStyle.Back)
		else
			Motion.tween(checkScale, { Scale = 0.2 }, d, Enum.EasingStyle.Quad, nil, function()
				if mine == token and not api.selected then
					check.Visible = false
				end
			end)
		end
	end
	api.SetBadge(o.badge)
	api.SetSelected(o.selected, true)

	local state = UI.pressable(hit, lift, { radius = radius, hoverAlpha = 0.95, pressAlpha = 0.88, pressScale = 0.965 })
	hit.Activated:Connect(function()
		if state.wasDrag() then
			return
		end
		if o.sound ~= false then
			Sfx.play(o.sound or "click")
		end
		if o.onClick then
			Util.try("cover " .. tostring(o.name), o.onClick, api)
		end
	end)
	return api
end

-- A wrapping grid for covers: the cells share each row evenly (at least minWidth px wide); ratio = height / width.
-- o: name, minWidth (default 96), ratio (default 1.3), gap (default 10), minColumns (default 2), maxColumns
-- returns { Instance, Grid, Resize(pageWidth), columns, cell }. It also follows the window width (Pages.gridUpdaters).
function UI.coverGrid(parent, order, o)
	o = o or {}
	local gap = o.gap or 10
	local minW = o.minWidth or 96
	local ratio = o.ratio or 1.3
	local host = Util.new("Frame", {
		Name = o.name or "Covers", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = order or 0,
	}, parent)
	-- room around the cells, so a lifted cover and its ring are never cut by the page
	Util.pad(host, 6, 7, 6, 8)
	local grid = Util.new("UIGridLayout", {
		CellSize = UDim2.fromOffset(minW, math.floor(minW * ratio)), CellPadding = UDim2.fromOffset(gap, gap),
		SortOrder = Enum.SortOrder.LayoutOrder, FillDirection = Enum.FillDirection.Horizontal,
	}, host)
	local api = { Instance = host, Grid = grid, columns = 1, cell = Vector2.new(minW, math.floor(minW * ratio)) }
	function api.Resize(width)
		local usable = width - 12
		local columns = Util.clamp(math.floor((usable + gap) / (minW + gap)), o.minColumns or 2, o.maxColumns or 8)
		local cellW = math.floor((usable - (columns - 1) * gap) / columns)
		local cellH = math.floor(cellW * ratio)
		grid.CellSize = UDim2.fromOffset(cellW, cellH)
		api.columns, api.cell = columns, Vector2.new(cellW, cellH)
	end
	api.Resize(Win.pageW or 400)
	Pages.gridUpdaters[#Pages.gridUpdaters + 1] = api.Resize
	return api
end

-- An action tile (Overview > Quick actions): an icon tile, a title and one line of live state.
-- o: parent, order, icon, iconRole, title, value, onClick(api), name
-- returns { Instance, SetValue(text), SetTitle(text) }
function UI.quickTile(o)
	local hit = Util.new("TextButton", {
		Name = o.name or "Quick", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = o.order or 0,
	}, o.parent)
	local face = Util.new("Frame", {
		Name = "Face", Active = false, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1), ZIndex = 2,
	}, hit)
	Theme.surface(face, "Card", "card")
	Util.corner(face, 16)
	local stroke = Util.stroke(face, nil, 1, 0.3)
	Theme.gradient(Util.new("UIGradient", { Rotation = 45 }, stroke), Theme.G.rim, true)
	UI.glass(face, { strength = 0.7, zindex = 2, rim = false, edge = true })
	UI.iconTile(face, o.icon or "sparkle", o.iconRole, 32, { position = UDim2.fromOffset(14, 13), zindex = 3 })
	local title = Util.new("TextLabel", {
		Name = "Title", BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 52), Size = UDim2.new(1, -28, 0, 18), ZIndex = 3,
		Text = o.title or "", TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
	}, face)
	Typo.apply(title, "heading", 13)
	Theme.bind(title, "TextColor3", "Text")
	local value = Util.new("TextLabel", {
		Name = "Value", BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 71), Size = UDim2.new(1, -28, 0, 16), ZIndex = 3,
		Text = o.value or "", TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
	}, face)
	Typo.apply(value, "caption", 11)
	Theme.bind(value, "TextColor3", "Muted")
	local api = { Instance = hit }
	function api.SetTitle(text)
		title.Text = tostring(text)
	end
	-- the new state slides in from below on a small spring
	function api.SetValue(text)
		text = tostring(text)
		if value.Text == text then
			return
		end
		value.Text = text
		if not Motion.reduced and hit.Parent and hit.AbsoluteSize.X > 0 then
			value.TextTransparency = 1
			value.Position = UDim2.fromOffset(14, 78)
			Motion.tween(value, { TextTransparency = 0 }, 0.22)
			Motion.tween(value, { Position = UDim2.fromOffset(14, 71) }, 0.4, Enum.EasingStyle.Back)
		end
	end
	local state = UI.pressable(hit, face, { radius = 16, hoverAlpha = 0.95, pressAlpha = 0.88, pressScale = 0.97 })
	hit.Activated:Connect(function()
		if state.wasDrag() then
			return
		end
		Sfx.play("click")
		if o.onClick then
			Util.try("quick " .. tostring(o.title), o.onClick, api)
		end
	end)
	return api
end

----------------------------------------------------------------------------------------------------
-- dropdown (popup lives in the window's popup layer so scrolling pages never clip it)
----------------------------------------------------------------------------------------------------
UI.openDropdown = nil

function UI.closeDropdown(immediate)
	local active = UI.openDropdown
	if active then
		UI.openDropdown = nil
		active.close(immediate)
	end
end

-- o: parent, options = { {id=, label=}, ... }, value, onChange(id), width, height, popupWidth, anchor, position, order, name
function UI.dropdown(o)
	local options = o.options
	local current = o.value
	local hit = Util.new("TextButton", {
		Name = o.name or "Dropdown", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.fromOffset(o.width or 170, o.height or 36),
		AnchorPoint = o.anchor or Vector2.new(0, 0), Position = o.position or UDim2.new(0, 0, 0, 0), LayoutOrder = o.order or 0,
	}, o.parent)
	local face = Util.new("Frame", {
		Name = "Face", Active = false, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1), BorderSizePixel = 0,
	}, hit)
	Util.corner(face, 14)
	Theme.bind(face, "BackgroundColor3", "Track", "Panel", 0.4)
	Theme.bind(Util.stroke(face, nil, 1, 0.3), "Color", "Border")
	local label = Util.new("TextLabel", {
		Name = "Label", BackgroundTransparency = 1, Size = UDim2.new(1, -36, 1, 0), Position = UDim2.fromOffset(12, 0),
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = "",
	}, face)
	Typo.apply(label, "buttonSmall")
	Theme.bind(label, "TextColor3", "Text")
	local chevron = UI.icon("chevron", face, 16, "Muted", { anchor = Vector2.new(1, 0.5), position = UDim2.new(1, -10, 0.5, 0) })
	local state = UI.pressable(hit, face, { radius = 14, hoverAlpha = 0.94, pressAlpha = 0.88 })
	local api = { Instance = hit, enabled = true, last = 0 }

	local function labelFor(id)
		for _, opt in ipairs(options) do
			if opt.id == id then
				return opt.label
			end
		end
		return o.placeholder or "Select..."
	end
	label.Text = labelFor(current)

	local function open()
		local layer = UI.layers.popup
		if not layer then
			return
		end
		local s = UI.scale()
		local lx = (hit.AbsolutePosition.X - layer.AbsolutePosition.X) / s
		local ly = (hit.AbsolutePosition.Y - layer.AbsolutePosition.Y) / s
		local bw, bh = hit.AbsoluteSize.X / s, hit.AbsoluteSize.Y / s
		local lw, lh = layer.AbsoluteSize.X / s, layer.AbsoluteSize.Y / s
		local rowHeight = 36
		local visibleRows = math.min(#options, 6)
		local listHeight = visibleRows * rowHeight + 10
		local width = math.min(math.max(bw, o.popupWidth or 170), math.max(120, lw - 12))
		local x = Util.clamp(lx + bw - width, 6, math.max(6, lw - width - 6))
		local below = ly + bh + 4
		local anchorY, y = 0, below
		if below + listHeight > lh - 6 then
			local above = ly - 4
			if above - listHeight >= 6 then
				anchorY, y = 1, above
			else
				y = Util.clamp(below, 6, math.max(6, lh - listHeight - 6))
			end
		end

		layer.Visible = true
		local catcher = Util.new("TextButton", {
			Name = "Catcher", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1), ZIndex = 1,
		}, layer)
		local list = Util.new("Frame", {
			Name = "DropdownList", AnchorPoint = Vector2.new(0, anchorY), Position = UDim2.fromOffset(x, y),
			Size = UDim2.fromOffset(width, 0), BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 2,
		}, layer)
		Util.corner(list, 16)
		Theme.bind(list, "BackgroundColor3", "Elevated")
		UI.glass(list, { strength = 0.7, zindex = 2, rimTransparency = 0.15 })
		local popupShadow = UI.followShadow(list, 16)
		local scroller = Util.new("ScrollingFrame", {
			Name = "Options", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 3,
			CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3,
			ScrollBarImageTransparency = 0.4,
		}, list)
		Theme.bind(scroller, "ScrollBarImageColor3", "Accent")
		Util.pad(scroller, 5, 5, 5, 5)
		Util.list(scroller, 0)

		for i, opt in ipairs(options) do
			local rowHit = Util.new("TextButton", {
				Name = "Opt_" .. tostring(opt.id), Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
				BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, rowHeight), LayoutOrder = i, ZIndex = 4,
			}, scroller)
			local rowFace = Util.new("Frame", {
				Name = "Face", Active = false, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.new(1, -2, 1, -4), BorderSizePixel = 0, ZIndex = 4,
				BackgroundTransparency = opt.id == current and 0 or 1,
			}, rowHit)
			Util.corner(rowFace, 11)
			Theme.bind(rowFace, "BackgroundColor3", "AccentSoft")
			local rowLabel = Util.new("TextLabel", {
				BackgroundTransparency = 1, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.fromOffset(10, 0), Text = opt.label,
				TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 5,
			}, rowFace)
			Typo.apply(rowLabel, "buttonSmall")
			Theme.bind(rowLabel, "TextColor3", opt.id == current and "Text" or "Muted")
			if opt.id == current then
				UI.icon("check", rowFace, 16, "Accent", { anchor = Vector2.new(1, 0.5), position = UDim2.new(1, -10, 0.5, 0), zindex = 5 })
			end
			local rowState = UI.pressable(rowHit, rowFace, { radius = 11, hoverAlpha = 0.93, pressAlpha = 0.85, pressScale = 0.98 })
			rowHit.Activated:Connect(function()
				if rowState.wasDrag() then
					return
				end
				Sfx.play("select")
				current = opt.id
				label.Text = opt.label
				UI.closeDropdown()
				if o.onChange then
					Util.try("dropdown onChange", o.onChange, opt.id)
				end
			end)
		end

		local closing = false
		local function close(immediate)
			if closing then
				return
			end
			closing = true
			Motion.tween(chevron.Instance, { Rotation = 0 }, 0.15)
			local function finish()
				popupShadow.Destroy()
				catcher:Destroy()
				list:Destroy()
				if not UI.openDropdown then
					layer.Visible = false
				end
				UI.prune()
			end
			if immediate then
				Motion.cancel(list)
				finish()
			else
				Motion.tween(list, { Size = UDim2.fromOffset(width, 0) }, 0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.In, finish)
			end
		end
		UI.openDropdown = { close = close, owner = api }
		catcher.Activated:Connect(function()
			Sfx.play("dropdown")
			UI.closeDropdown()
		end)
		Sfx.play("dropdown")
		Motion.tween(chevron.Instance, { Rotation = 180 }, 0.2)
		Motion.tween(list, { Size = UDim2.fromOffset(width, listHeight) }, 0.34, Enum.EasingStyle.Back)
	end

	hit.Activated:Connect(function()
		if state.wasDrag() then
			return
		end
		if not api.enabled then
			UI.shake(face)
			return
		end
		local now = os.clock()
		if now - api.last < 0.15 then
			return
		end
		api.last = now
		local active = UI.openDropdown
		if active and active.owner == api then
			Sfx.play("dropdown")
			UI.closeDropdown()
			return
		end
		UI.closeDropdown(true)
		open()
	end)

	function api.Get()
		return current
	end
	function api.Set(id, silent)
		current = id
		label.Text = labelFor(id)
		if not silent and o.onChange then
			Util.try("dropdown onChange", o.onChange, id)
		end
	end
	function api.SetOptions(newOptions, selected)
		options = newOptions
		current = selected
		label.Text = labelFor(current)
	end
	function api.SetEnabled(enabled)
		api.enabled = enabled and true or false
		label.TextTransparency = api.enabled and 0 or 0.55
	end
	return api
end

----------------------------------------------------------------------------------------------------
-- multi-select dropdown (added with the built-in Steal An Egg panel)
-- Same look and popup as UI.dropdown, but every row is a check box and the list stays open while you pick.
-- o: parent, options = { {id=, label=}, ... }, value = { id, ... }, placeholder, onChange(list of ids), width, height,
--    popupWidth, anchor, position, order, name
-- api: Get() -> selected ids in option order, Set(list, silent), SetOptions(options, list), SetEnabled(flag)
----------------------------------------------------------------------------------------------------
function UI.multiSelect(o)
	local options = o.options
	local selected = {}
	for _, id in ipairs(o.value or {}) do
		selected[id] = true
	end
	local hit = Util.new("TextButton", {
		Name = o.name or "MultiSelect", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.fromOffset(o.width or 170, o.height or 36),
		AnchorPoint = o.anchor or Vector2.new(0, 0), Position = o.position or UDim2.new(0, 0, 0, 0), LayoutOrder = o.order or 0,
	}, o.parent)
	local face = Util.new("Frame", {
		Name = "Face", Active = false, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1), BorderSizePixel = 0,
	}, hit)
	Util.corner(face, 14)
	Theme.bind(face, "BackgroundColor3", "Track", "Panel", 0.4)
	Theme.bind(Util.stroke(face, nil, 1, 0.3), "Color", "Border")
	local label = Util.new("TextLabel", {
		Name = "Label", BackgroundTransparency = 1, Size = UDim2.new(1, -36, 1, 0), Position = UDim2.fromOffset(12, 0),
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = "",
	}, face)
	Typo.apply(label, "buttonSmall")
	Theme.bind(label, "TextColor3", "Text")
	local chevron = UI.icon("chevron", face, 16, "Muted", { anchor = Vector2.new(1, 0.5), position = UDim2.new(1, -10, 0.5, 0) })
	local state = UI.pressable(hit, face, { radius = 14, hoverAlpha = 0.94, pressAlpha = 0.88 })
	local api = { Instance = hit, enabled = true, last = 0 }
	local rows = {} -- only filled while the popup is open

	local function chosen()
		local list = {}
		for _, opt in ipairs(options) do
			if selected[opt.id] then
				list[#list + 1] = opt.id
			end
		end
		return list
	end

	local function paintLabel()
		local names = {}
		for _, opt in ipairs(options) do
			if selected[opt.id] then
				names[#names + 1] = opt.label
			end
		end
		if #names == 0 then
			label.Text = o.placeholder or "Select..."
			Theme.tweenRole(label, "TextColor3", "Muted", 0.12)
		else
			label.Text = (#names <= 2) and table.concat(names, ", ") or (tostring(#names) .. " selected")
			Theme.tweenRole(label, "TextColor3", "Text", 0.12)
		end
	end
	paintLabel()

	local function paintRows()
		for _, row in ipairs(rows) do
			local on = selected[row.id] == true
			Motion.tween(row.face, { BackgroundTransparency = on and 0 or 1 }, 0.12)
			Theme.tweenRole(row.label, "TextColor3", on and "Text" or "Muted", 0.12)
			row.check.Instance.Visible = on
		end
	end

	local function open()
		local layer = UI.layers.popup
		if not layer then
			return
		end
		local s = UI.scale()
		local lx = (hit.AbsolutePosition.X - layer.AbsolutePosition.X) / s
		local ly = (hit.AbsolutePosition.Y - layer.AbsolutePosition.Y) / s
		local bw, bh = hit.AbsoluteSize.X / s, hit.AbsoluteSize.Y / s
		local lw, lh = layer.AbsoluteSize.X / s, layer.AbsoluteSize.Y / s
		local rowHeight = 36
		local visibleRows = math.min(#options, 6)
		local listHeight = visibleRows * rowHeight + 10
		local width = math.min(math.max(bw, o.popupWidth or 170), math.max(120, lw - 12))
		local x = Util.clamp(lx + bw - width, 6, math.max(6, lw - width - 6))
		local below = ly + bh + 4
		local anchorY, y = 0, below
		if below + listHeight > lh - 6 then
			local above = ly - 4
			if above - listHeight >= 6 then
				anchorY, y = 1, above
			else
				y = Util.clamp(below, 6, math.max(6, lh - listHeight - 6))
			end
		end

		layer.Visible = true
		local catcher = Util.new("TextButton", {
			Name = "Catcher", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1), ZIndex = 1,
		}, layer)
		local list = Util.new("Frame", {
			Name = "MultiSelectList", AnchorPoint = Vector2.new(0, anchorY), Position = UDim2.fromOffset(x, y),
			Size = UDim2.fromOffset(width, 0), BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 2,
		}, layer)
		Util.corner(list, 16)
		Theme.bind(list, "BackgroundColor3", "Elevated")
		UI.glass(list, { strength = 0.7, zindex = 2, rimTransparency = 0.15 })
		local popupShadow = UI.followShadow(list, 16)
		local scroller = Util.new("ScrollingFrame", {
			Name = "Options", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 3,
			CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3,
			ScrollBarImageTransparency = 0.4,
		}, list)
		Theme.bind(scroller, "ScrollBarImageColor3", "Accent")
		Util.pad(scroller, 5, 5, 5, 5)
		Util.list(scroller, 0)

		rows = {}
		for i, opt in ipairs(options) do
			local on = selected[opt.id] == true
			local rowHit = Util.new("TextButton", {
				Name = "Opt_" .. tostring(opt.id), Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
				BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, rowHeight), LayoutOrder = i, ZIndex = 4,
			}, scroller)
			local rowFace = Util.new("Frame", {
				Name = "Face", Active = false, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.new(1, -2, 1, -4), BorderSizePixel = 0, ZIndex = 4,
				BackgroundTransparency = on and 0 or 1,
			}, rowHit)
			Util.corner(rowFace, 11)
			Theme.bind(rowFace, "BackgroundColor3", "AccentSoft")
			local rowLabel = Util.new("TextLabel", {
				BackgroundTransparency = 1, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.fromOffset(10, 0), Text = opt.label,
				TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 5,
			}, rowFace)
			Typo.apply(rowLabel, "buttonSmall")
			Theme.bind(rowLabel, "TextColor3", on and "Text" or "Muted")
			local check = UI.icon("check", rowFace, 16, "Accent", { anchor = Vector2.new(1, 0.5), position = UDim2.new(1, -10, 0.5, 0), zindex = 5 })
			check.Instance.Visible = on
			local rowState = UI.pressable(rowHit, rowFace, { radius = 11, hoverAlpha = 0.93, pressAlpha = 0.85, pressScale = 0.98 })
			rows[#rows + 1] = { id = opt.id, face = rowFace, label = rowLabel, check = check }
			rowHit.Activated:Connect(function()
				if rowState.wasDrag() then
					return
				end
				Sfx.play("select")
				if selected[opt.id] then
					selected[opt.id] = nil
				else
					selected[opt.id] = true
				end
				paintLabel()
				paintRows()
				if o.onChange then
					Util.try("multiselect onChange", o.onChange, chosen())
				end
			end)
		end

		local closing = false
		local function close(immediate)
			if closing then
				return
			end
			closing = true
			rows = {}
			Motion.tween(chevron.Instance, { Rotation = 0 }, 0.15)
			local function finish()
				popupShadow.Destroy()
				catcher:Destroy()
				list:Destroy()
				if not UI.openDropdown then
					layer.Visible = false
				end
				UI.prune()
			end
			if immediate then
				Motion.cancel(list)
				finish()
			else
				Motion.tween(list, { Size = UDim2.fromOffset(width, 0) }, 0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.In, finish)
			end
		end
		UI.openDropdown = { close = close, owner = api }
		catcher.Activated:Connect(function()
			Sfx.play("dropdown")
			UI.closeDropdown()
		end)
		Sfx.play("dropdown")
		Motion.tween(chevron.Instance, { Rotation = 180 }, 0.2)
		Motion.tween(list, { Size = UDim2.fromOffset(width, listHeight) }, 0.34, Enum.EasingStyle.Back)
	end

	hit.Activated:Connect(function()
		if state.wasDrag() then
			return
		end
		if not api.enabled then
			UI.shake(face)
			return
		end
		local now = os.clock()
		if now - api.last < 0.15 then
			return
		end
		api.last = now
		local active = UI.openDropdown
		if active and active.owner == api then
			Sfx.play("dropdown")
			UI.closeDropdown()
			return
		end
		UI.closeDropdown(true)
		open()
	end)

	function api.Get()
		return chosen()
	end
	function api.Set(list, silent)
		selected = {}
		for _, id in ipairs(type(list) == "table" and list or {}) do
			selected[id] = true
		end
		if UI.openDropdown and UI.openDropdown.owner == api then
			UI.closeDropdown(true)
		end
		paintLabel()
		if not silent and o.onChange then
			Util.try("multiselect onChange", o.onChange, chosen())
		end
	end
	function api.SetOptions(newOptions, list)
		options = newOptions
		selected = {}
		for _, id in ipairs(type(list) == "table" and list or {}) do
			selected[id] = true
		end
		if UI.openDropdown and UI.openDropdown.owner == api then
			UI.closeDropdown(true)
		end
		paintLabel()
	end
	function api.SetEnabled(enabled)
		api.enabled = enabled and true or false
		label.TextTransparency = api.enabled and 0 or 0.55
	end
	return api
end

----------------------------------------------------------------------------------------------------
-- text input
----------------------------------------------------------------------------------------------------
-- o: parent, placeholder, text, width, height, size, numeric, maxLength, onSubmit(text, enter), onChange(text),
--    anchor, position, order
function UI.input(o)
	local holder = Util.new("Frame", {
		Name = o.name or "Input", BorderSizePixel = 0, ClipsDescendants = true,
		Size = o.size or UDim2.fromOffset(o.width or 200, o.height or 36),
		AnchorPoint = o.anchor or Vector2.new(0, 0), Position = o.position or UDim2.new(0, 0, 0, 0), LayoutOrder = o.order or 0,
	}, o.parent)
	Util.corner(holder, 14)
	Theme.surface(holder, "Panel", "input")
	local stroke = Util.stroke(holder, nil, 1, 0.1)
	Theme.bind(stroke, "Color", "Border")
	UI.glass(holder, { strength = 0.4, zindex = 1, rim = false })
	local box = Util.new("TextBox", {
		Name = "Box", BackgroundTransparency = 1, Size = UDim2.new(1, -24, 1, 0), Position = UDim2.fromOffset(12, 0), ZIndex = 2,
		Text = o.text or "", PlaceholderText = o.placeholder or "", ClearTextOnFocus = false, MultiLine = false,
		TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = false, ClipsDescendants = true,
	}, holder)
	Typo.apply(box, "body", 13)
	Theme.bind(box, "TextColor3", "Text")
	Theme.bind(box, "PlaceholderColor3", "Faint")
	local api = { Instance = holder, Box = box }
	local guard = false

	box:GetPropertyChangedSignal("Text"):Connect(function()
		if guard then
			return
		end
		local text = box.Text
		local cleaned = text
		if o.numeric then
			cleaned = string.gsub(cleaned, "%D", "")
		end
		if o.maxLength and #cleaned > o.maxLength then
			cleaned = string.sub(cleaned, 1, o.maxLength)
		end
		if cleaned ~= text then
			guard = true
			box.Text = cleaned
			guard = false
		end
		if o.onChange then
			Util.try("input onChange", o.onChange, cleaned)
		end
	end)
	box.Focused:Connect(function()
		Theme.tweenRole(stroke, "Color", "Accent", 0.15)
		Motion.tween(stroke, { Thickness = 1.5, Transparency = 0 }, 0.15)
		Sfx.play("select")
		UI.scrollIntoView(holder)
		if Win.onInputFocus then
			Win.onInputFocus(holder, true)
		end
	end)
	box.FocusLost:Connect(function(enter)
		Theme.tweenRole(stroke, "Color", "Border", 0.2)
		Motion.tween(stroke, { Thickness = 1, Transparency = 0.1 }, 0.2)
		if Win.onInputFocus then
			Win.onInputFocus(holder, false)
		end
		if o.onSubmit then
			Util.try("input onSubmit", o.onSubmit, Util.trim(box.Text), enter)
		end
	end)

	function api.Get()
		return Util.trim(box.Text)
	end
	function api.Set(text)
		guard = true
		box.Text = tostring(text or "")
		guard = false
	end
	function api.Focus()
		box:CaptureFocus()
	end
	function api.Flash(role)
		Theme.bind(stroke, "Color", role or "Danger")
		Motion.tween(stroke, { Thickness = 2 }, 0.1)
		task.delay(0.9, function()
			if stroke.Parent then
				Theme.tweenRole(stroke, "Color", "Border", 0.3)
				Motion.tween(stroke, { Thickness = 1 }, 0.3)
			end
		end)
		UI.shake(holder)
	end
	return api
end

----------------------------------------------------------------------------------------------------
-- iOS-style search field: a capsule with a magnifier, a text box, a clear button (shown while there is text) and, optionally,
-- a "Cancel" text button that slides in while the field has focus.
-- o: parent, placeholder, text, width, height, size, onChange(text), onSubmit(text, enter), onCancel(), cancel (true = show
--    Cancel while focused), maxLength, anchor, position, order, name
-- api: Instance, Field, Box, Get(), Set(text, silent), Focus(), Blur(), Clear()
----------------------------------------------------------------------------------------------------
function UI.searchField(o)
	local holder = Util.new("Frame", {
		Name = o.name or "SearchField", BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = o.size or UDim2.fromOffset(o.width or 220, o.height or 38),
		AnchorPoint = o.anchor or Vector2.new(0, 0), Position = o.position or UDim2.new(0, 0, 0, 0), LayoutOrder = o.order or 0,
	}, o.parent)
	local cancelWidth = 64
	local field = Util.new("Frame", { Name = "Field", BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ClipsDescendants = true }, holder)
	Util.corner(field, UDim.new(0.5, 0))
	Theme.surface(field, "Track", "input", "Panel", 0.35)
	local stroke = Util.stroke(field, nil, 1, 0.35)
	Theme.bind(stroke, "Color", "Border")
	UI.glass(field, { strength = 0.45, zindex = 1, rim = false })

	local magnifier = UI.icon("search", field, 16, "Muted", { anchor = Vector2.new(0, 0.5), position = UDim2.new(0, 12, 0.5, 0), zindex = 3 })
	local box = Util.new("TextBox", {
		Name = "Box", BackgroundTransparency = 1, Size = UDim2.new(1, -66, 1, 0), Position = UDim2.fromOffset(34, 0),
		Text = o.text or "", PlaceholderText = o.placeholder or "Search", ClearTextOnFocus = false, MultiLine = false,
		TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = false, ClipsDescendants = true, ZIndex = 3,
	}, field)
	Typo.apply(box, "body", 13)
	Theme.bind(box, "TextColor3", "Text")
	Theme.bind(box, "PlaceholderColor3", "Faint")

	-- the clear button: a small grey disc with a cross, only while there is text
	local clearHit = Util.new("TextButton", {
		Name = "Clear", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(38, 38), ZIndex = 4, Visible = false,
	}, field)
	local disc = Util.new("Frame", {
		Name = "Disc", Active = false, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(16, 16), ZIndex = 4,
	}, clearHit)
	Util.round_corner(disc)
	Theme.bind(disc, "BackgroundColor3", "Muted")
	UI.icon("close", disc, 10, "Card", { anchor = Vector2.new(0.5, 0.5), position = UDim2.fromScale(0.5, 0.5), zindex = 5 })

	local cancel = nil
	if o.cancel then
		cancel = Util.new("TextButton", {
			Name = "Cancel", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0, Text = "Cancel", TextTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 12, 0.5, 0), Size = UDim2.fromOffset(cancelWidth, 38), Visible = false,
		}, holder)
		Typo.apply(cancel, "button")
		Theme.bind(cancel, "TextColor3", "Accent")
	end

	local api = { Instance = holder, Field = field, Box = box }
	local guard, focused = false, false
	local function syncClear()
		clearHit.Visible = box.Text ~= ""
	end
	local function showCancel(on)
		if not cancel then
			return
		end
		if on then
			cancel.Visible = true
			Motion.tween(field, { Size = UDim2.new(1, -(cancelWidth + 4), 1, 0) }, 0.34, Enum.EasingStyle.Back)
			Motion.tween(cancel, { TextTransparency = 0, Position = UDim2.new(1, 0, 0.5, 0) }, 0.3, Enum.EasingStyle.Quint)
		else
			Motion.tween(field, { Size = UDim2.fromScale(1, 1) }, 0.28, Enum.EasingStyle.Quint)
			Motion.tween(cancel, { TextTransparency = 1, Position = UDim2.new(1, 12, 0.5, 0) }, 0.2, Enum.EasingStyle.Quad, nil, function()
				if not focused then
					cancel.Visible = false
				end
			end)
		end
	end

	box:GetPropertyChangedSignal("Text"):Connect(function()
		if guard then
			return
		end
		local text = box.Text
		if o.maxLength and #text > o.maxLength then
			guard = true
			text = string.sub(text, 1, o.maxLength)
			box.Text = text
			guard = false
		end
		syncClear()
		if o.onChange then
			Util.try("search onChange", o.onChange, text)
		end
	end)
	box.Focused:Connect(function()
		focused = true
		Theme.tweenRole(stroke, "Color", "Accent", 0.18)
		Motion.tween(stroke, { Thickness = 1.5, Transparency = 0 }, 0.18)
		magnifier.SetRole("Accent", 0.18)
		Sfx.play("select")
		showCancel(true)
		if Win.onInputFocus then
			Win.onInputFocus(holder, true)
		end
	end)
	box.FocusLost:Connect(function(enter)
		focused = false
		Theme.tweenRole(stroke, "Color", "Border", 0.2)
		Motion.tween(stroke, { Thickness = 1, Transparency = 0.35 }, 0.2)
		magnifier.SetRole("Muted", 0.2)
		if box.Text == "" then
			showCancel(false)
		end
		if Win.onInputFocus then
			Win.onInputFocus(holder, false)
		end
		if o.onSubmit then
			Util.try("search onSubmit", o.onSubmit, Util.trim(box.Text), enter)
		end
	end)
	local state = UI.pressable(clearHit, disc, { radius = UDim.new(0.5, 0), hoverAlpha = 0.9, pressAlpha = 0.8 })
	clearHit.Activated:Connect(function()
		if state.wasDrag() then
			return
		end
		Sfx.play("click")
		api.Clear()
		box:CaptureFocus()
	end)
	if cancel then
		cancel.Activated:Connect(function()
			Sfx.play("close")
			api.Clear()
			box:ReleaseFocus()
			focused = false
			showCancel(false)
			if o.onCancel then
				Util.try("search onCancel", o.onCancel)
			end
		end)
	end

	function api.Get()
		return Util.trim(box.Text)
	end
	function api.Set(text, silent)
		guard = silent and true or false
		box.Text = tostring(text or "")
		guard = false
		syncClear()
	end
	function api.Clear()
		box.Text = ""
	end
	function api.Focus()
		box:CaptureFocus()
	end
	function api.Blur()
		box:ReleaseFocus()
	end
	syncClear()
	return api
end

----------------------------------------------------------------------------------------------------
-- confirm dialog (one at a time, rendered in the window's modal layer): an iOS-style glass alert with a round icon badge on top
----------------------------------------------------------------------------------------------------
UI.modal = nil

function UI.closeModal(immediate)
	local modal = UI.modal
	if not modal then
		return
	end
	UI.modal = nil
	local layer = UI.layers.modal
	local function finish()
		modal.scrim:Destroy()
		modal.card:Destroy()
		if layer then
			layer.Visible = false
		end
		UI.prune()
	end
	if immediate then
		finish()
		return
	end
	Motion.tween(modal.scrim, { BackgroundTransparency = 1 }, 0.18)
	Motion.tween(modal.scale, { Scale = 0.92 }, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In, finish)
end

-- o: title, text, confirmText, cancelText, danger, onConfirm(), onCancel()
function UI.confirm(o)
	local layer = UI.layers.modal
	if not layer or UI.modal then
		return false
	end
	UI.closeDropdown(true)
	layer.Visible = true
	local s = UI.scale()
	local layerWidth = layer.AbsoluteSize.X / s
	local width = Util.clamp(layerWidth - 40, 240, 340)
	local role = o.danger and "Danger" or "Accent"

	local scrim = Util.new("TextButton", {
		Name = "Scrim", Text = "", AutoButtonColor = false, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1, ZIndex = 1,
	}, layer)
	Theme.bind(scrim, "BackgroundColor3", "Scrim")
	-- shell = transparent holder (shadow layers behind, the glass surface on top); the surface sizes itself to its content
	local shell = Util.new("Frame", {
		Name = "Confirm", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(width, 0), AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0, ZIndex = 2,
	}, layer)
	local scale = Util.new("UIScale", { Scale = 0.88 }, shell)
	UI.shadow(shell, 24, { zindex = 1, dy = 10, specs = { { 3, 0.9 }, { 9, 0.94 }, { 17, 0.97 }, { 26, 0.985 } } })
	local card = Util.new("Frame", {
		Name = "Surface", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0, ZIndex = 2,
	}, shell)
	Util.corner(card, 24)
	Theme.bind(card, "BackgroundColor3", "Elevated")
	UI.glass(card, { strength = 1, edge = true, zindex = 2, rimTransparency = 0.1 })

	local inner = Util.new("Frame", {
		Name = "Inner", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 3,
	}, card)
	Util.pad(inner, 20, 20, 20, 18)
	local innerList = Util.list(inner, 10)
	innerList.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local badge = Util.new("Frame", { Name = "Badge", BorderSizePixel = 0, Size = UDim2.fromOffset(46, 46), LayoutOrder = 1, ZIndex = 4 }, inner)
	Util.round_corner(badge)
	Theme.bind(badge, "BackgroundColor3", "Card", role, 0.22)
	Theme.bind(Util.stroke(badge, nil, 1, 0.5), "Color", role)
	UI.icon(o.danger and "bang" or "info", badge, 24, role, { anchor = Vector2.new(0.5, 0.5), position = UDim2.fromScale(0.5, 0.5), zindex = 5 })
	local title = Util.new("TextLabel", {
		Name = "Title", BackgroundTransparency = 1, LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		Text = o.title or "Are you sure?", TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 4,
	}, inner)
	Typo.apply(title, "heading", 16)
	Theme.bind(title, "TextColor3", "Text")
	local body = Util.new("TextLabel", {
		Name = "Body", BackgroundTransparency = 1, LayoutOrder = 3, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		Text = o.text or "", TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 4,
	}, inner)
	Typo.apply(body, "body")
	Theme.bind(body, "TextColor3", "Muted")
	local row = Util.new("Frame", { Name = "Buttons", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 42), LayoutOrder = 4, ZIndex = 4 }, inner)

	local modal = { scrim = scrim, card = shell, scale = scale }
	UI.modal = modal
	local decided = false
	local function decide(confirmed)
		if decided then
			return
		end
		decided = true
		UI.closeModal()
		if confirmed then
			if o.onConfirm then
				Util.try("confirm", o.onConfirm)
			end
		elseif o.onCancel then
			Util.try("cancel", o.onCancel)
		end
	end
	UI.button({
		parent = row, text = o.cancelText or "Cancel", kind = "ghost", size = UDim2.new(0.5, -5, 1, 0), name = "Cancel",
		sound = "close", onClick = function()
			decide(false)
		end,
	})
	UI.button({
		parent = row, text = o.confirmText or "Confirm", kind = o.danger and "danger" or "primary",
		size = UDim2.new(0.5, -5, 1, 0), position = UDim2.new(0.5, 5, 0, 0), name = "Confirm",
		sound = o.danger and "warning" or "success", onClick = function()
			decide(true)
		end,
	})
	scrim.Activated:Connect(function()
		decide(false)
	end)

	Sfx.play("open")
	Motion.tween(scrim, { BackgroundTransparency = 0.45 }, 0.22)
	Motion.tween(scale, { Scale = 1 }, 0.42, Enum.EasingStyle.Back)
	return true
end
end -- [06_ui_more.lua]

do -- [07_notify.lua]
----------------------------------------------------------------------------------------------------
-- Notify: liquid-drop toasts (success / warning / error / info).
--
-- A message falls from the top of the screen as a small coloured drop, squashes where it lands and spreads into a glass pill
-- (a spring, so it overshoots a little and settles). The newest pill is the top one and pushes the older ones down with a spring;
-- a repeat of the same message makes the pill wobble instead of adding another one. Tap a pill, or swipe it up, to send it away:
-- it pulls back into a drop and leaves through the top. Errors can stay until dismissed (Settings > Notifications).
----------------------------------------------------------------------------------------------------
Notify.layer = nil
Notify.items = {}        -- newest first (index 1 is the pill at the top of the stack)
Notify.max = 3
Notify.width = 320
Notify.top = 10          -- distance of the stack from the top edge of the screen
Notify.gap = 8
Notify.counter = 0
Notify.history = {}      -- newest first: { id, kind, title, text, key, count, at }
Notify.historyMax = 40
Notify.unread = 0        -- messages that arrived while the window was hidden (shown on the orb)
Notify.seq = 0
Notify.listeners = {}

local RADIUS = 28        -- corner radius; Roblox clamps it, so a short pill is a capsule and the small drop is a circle
local TEXT_X = 54        -- where the text starts (after the icon disc)
local PAD_R = 16
local PAD_TOP, PAD_BOTTOM = 11, 14 -- the bottom is taller: the timer line / grabber lives there
local MIN_H = 44
local LAND = 16          -- the drop lands this far below the pill's final top edge, then the pill blooms up and out
local DROP_W, DROP_H = 16, 22
local FALL_T, SQUASH_T, SPREAD_T = 0.2, 0.3, 0.92 -- the entrance: end of the fall, end of the squash, end of the spread (seconds)

local TOAST = {
	success = { role = "Green", icon = "check", sound = "success", duration = 3.4 },
	warning = { role = "Warn", icon = "bang", sound = "warning", duration = 4.8 },
	error = { role = "Danger", icon = "close", sound = "error", duration = 5.6 },
	info = { role = "Info", icon = "info", sound = "select", duration = 3.4 },
}

-- listener() runs whenever the history or the unread count changes. Returns a function that removes it.
function Notify.onChange(fn)
	Notify.listeners[#Notify.listeners + 1] = fn
	return function()
		local index = Util.indexOf(Notify.listeners, fn)
		if index then
			table.remove(Notify.listeners, index)
		end
	end
end

local function emit()
	local snapshot = {}
	for i, fn in ipairs(Notify.listeners) do
		snapshot[i] = fn
	end
	for _, fn in ipairs(snapshot) do
		Util.try("notify listener", fn)
	end
end

-- every message is kept in the history (even with toasts switched off); a repeat of the newest one is merged
local function record(kind, title, text, key)
	local newest = Notify.history[1]
	if newest and newest.key == key then
		newest.count = newest.count + 1
		newest.at = os.time()
	else
		Notify.seq = Notify.seq + 1
		table.insert(Notify.history, 1, { id = Notify.seq, kind = kind, title = title, text = text, key = key, count = 1, at = os.time() })
		while #Notify.history > Notify.historyMax do
			table.remove(Notify.history)
		end
	end
	if not Win.visible then
		Notify.unread = Notify.unread + 1
	end
	emit()
end

function Notify.markRead()
	if Notify.unread ~= 0 then
		Notify.unread = 0
		emit()
	end
end

function Notify.clearHistory()
	Notify.history = {}
	Notify.unread = 0
	emit()
end

-- "just now", "42s ago", "7m ago", "2h ago"
function Notify.ago(at)
	local seconds = math.max(0, math.floor(os.time() - (at or os.time())))
	if seconds < 5 then
		return "just now"
	elseif seconds < 60 then
		return string.format("%ds ago", seconds)
	elseif seconds < 3600 then
		return string.format("%dm ago", math.floor(seconds / 60))
	end
	return string.format("%dh ago", math.floor(seconds / 3600))
end

function Notify.init(gui)
	Notify.destroy()
	Notify.layer = Util.new("Frame", {
		Name = "Toasts", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 200,
	}, gui)
end

----------------------------------------------------------------------------------------------------
-- geometry: everything about a pill lives in a few numbers on the item; apply() turns them into the slot's Size / Position
--   w, h      the animated size (the drop starts at 16 x 22)
--   y         the top of the pill in the stack (animated when the stack changes)
--   fall      extra offset while the drop falls in / the pill leaves (pixels, negative = above)
--   drag      the swipe offset
--   wob       liquid wobble, -1..1 (wider and flatter at +1)
----------------------------------------------------------------------------------------------------
local function apply(item)
	local slot = item.slot
	if not slot or not slot.Parent then
		return
	end
	local wob = item.wob
	local w = item.w * (1 + 0.06 * wob)
	local h = item.h * (1 - 0.07 * wob)
	local top = item.y + item.fall + item.drag + (item.h - h) / 2
	slot.Size = UDim2.fromOffset(math.max(2, math.floor(w + 0.5)), math.max(2, math.floor(h + 0.5)))
	slot.Position = UDim2.new(0.5, 0, 0, math.floor(top + 0.5))
end

local function stopRun(item, field)
	local handle = item[field]
	if handle then
		item[field] = nil
		handle.Cancel()
	end
end

-- the pill glides to a new place in the stack with a soft spring
local function glideY(item, target)
	stopRun(item, "glide")
	local from = item.y
	if math.abs(target - from) < 0.5 then
		item.y = target
		apply(item)
		return
	end
	item.glide = Motion.run(0.55, function(a)
		item.y = from + (target - from) * a
		apply(item)
	end, Motion.ease.springSoft, function()
		item.glide = nil
	end)
end

local function relayout()
	local y = Notify.top
	for _, item in ipairs(Notify.items) do
		if item.placed then
			glideY(item, y)
		else
			item.y = y
			item.placed = true
			apply(item)
		end
		y = y + item.height + Notify.gap
	end
end

-- after the pill has spread, a change of height (text measured late, a new font) eases over
local function resizeTo(item, height)
	stopRun(item, "resize")
	local from = item.h
	if math.abs(height - from) < 0.5 then
		item.h = height
		apply(item)
		return
	end
	item.resize = Motion.run(0.45, function(a)
		item.h = from + (height - from) * a
		apply(item)
	end, Motion.ease.springSoft, function()
		item.resize = nil
	end)
end

-- the disc, the text and the bar fade in / out together
local function fadeContent(item, visible, seconds)
	local t = visible and 0 or 1
	Motion.tween(item.title, { TextTransparency = t }, seconds, Enum.EasingStyle.Quad)
	if item.hasBody then
		Motion.tween(item.body, { TextTransparency = visible and 0.12 or 1 }, seconds, Enum.EasingStyle.Quad)
	end
	Motion.tween(item.badge, { TextTransparency = t }, seconds, Enum.EasingStyle.Quad)
	Motion.tween(item.discScale, { Scale = visible and 1 or 0.01 }, visible and (seconds * 1.4) or seconds, visible and Enum.EasingStyle.Back or Enum.EasingStyle.Quad)
	Motion.tween(item.disc, { BackgroundTransparency = visible and 0 or 1 }, seconds, Enum.EasingStyle.Quad)
	local barTarget = visible and 0.35 or 1
	Motion.tween(item.bar, { BackgroundTransparency = item.sticky and 1 or barTarget }, seconds, Enum.EasingStyle.Quad)
	Motion.tween(item.grabber, { BackgroundTransparency = (item.sticky and visible) and 0.55 or 1 }, seconds, Enum.EasingStyle.Quad)
end

local function showShadow(item, visible)
	for _, layer in ipairs(item.shadows) do
		layer.Visible = visible
	end
end

-- the thin timer line along the bottom of the pill
local function startBar(item, seconds)
	local bar = item.bar
	Motion.cancel(bar)
	if item.sticky then
		return
	end
	bar.Size = UDim2.new(1, -44, 0, 2)
	Motion.tween(bar, { Size = UDim2.new(0, 0, 0, 2) }, math.max(0.1, seconds), Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
end

-- a small liquid wobble: the pill squeezes wider and flatter, then rings out
local function wobble(item)
	stopRun(item, "wobbleRun")
	if Motion.reduced then
		return
	end
	item.wobbleRun = Motion.run(0.7, function(a)
		item.wob = math.exp(-5.2 * a) * math.sin(a * 22)
		apply(item)
	end, Motion.ease.linear, function()
		item.wob = 0
		item.wobbleRun = nil
		apply(item)
	end)
end

----------------------------------------------------------------------------------------------------
-- leaving: the pill pulls back into a drop and rises out through the top of the screen
----------------------------------------------------------------------------------------------------
local function removeItem(item)
	local index = Util.indexOf(Notify.items, item)
	if index then
		table.remove(Notify.items, index)
	end
end

local function dismiss(item, instant)
	if item.closing then
		return
	end
	item.closing = true
	removeItem(item)
	stopRun(item, "glide")
	stopRun(item, "enter")
	stopRun(item, "resize")
	stopRun(item, "wobbleRun")
	stopRun(item, "settle")
	Motion.cancel(item.bar)
	relayout() -- the ones below glide up into the space
	local slot = item.slot
	if not slot or not slot.Parent then
		return
	end
	local function finish()
		slot:Destroy()
		UI.prune()
	end
	if instant or Motion.reduced then
		finish()
		return
	end
	fadeContent(item, false, 0.12)
	local w0, h0 = item.w, item.h
	local rise = item.y + item.drag + item.h + 40
	item.leave = Motion.run(0.4, function(a)
		local shrink = Motion.ease.inOutCubic(math.min(1, a / 0.55))
		local up = math.max(0, a - 0.3) / 0.7
		item.w = w0 + (34 - w0) * shrink
		item.h = h0 + (34 - h0) * shrink
		item.fall = -up * up * rise
		item.wob = 0
		apply(item)
		if a > 0.7 then
			item.pill.BackgroundTransparency = math.min(1, (a - 0.7) / 0.3)
		end
	end, Motion.ease.linear, finish)
end

local function tick()
	local now = os.clock()
	local expired = {}
	for _, item in ipairs(Notify.items) do
		if not item.closing and not item.holding and item.entered and now >= item.expires then
			expired[#expired + 1] = item
		end
	end
	for _, item in ipairs(expired) do
		dismiss(item)
	end
	if #Notify.items == 0 then
		Anim.remove("notify")
	end
end

----------------------------------------------------------------------------------------------------
-- measuring: the text decides the height. The text block has a fixed width (so it wraps the same while the pill is still a drop)
-- and sizes itself; the pill is that block plus padding.
----------------------------------------------------------------------------------------------------
local function measure(item)
	local inner = item.inner
	if item.closing or not inner or not inner.Parent then
		return
	end
	local textHeight = inner.AbsoluteSize.Y
	if textHeight <= 0 then
		return
	end
	local height = math.max(MIN_H, math.floor(textHeight + PAD_TOP + PAD_BOTTOM + 0.5))
	item.disc.Position = UDim2.new(0, 12, 0, math.min(math.floor(height / 2), 27))
	if math.abs(height - item.targetH) < 1 then
		return
	end
	item.targetH = height
	item.height = height
	if item.entered then
		resizeTo(item, height)
	end
	relayout()
end

----------------------------------------------------------------------------------------------------
-- the entrance
----------------------------------------------------------------------------------------------------
local function enter(item)
	local role = item.spec.role
	local revealed, landed = false, false
	local function finishEntrance()
		item.entered = true
		item.w, item.h, item.fall = item.targetW, item.targetH, 0
		item.enter = nil
		apply(item)
		Theme.surface(item.pill, "Elevated", "card")
		showShadow(item, true)
		if not revealed then
			revealed = true
			fadeContent(item, true, 0.01)
		end
		startBar(item, math.max(0.2, item.expires - os.clock()))
		item.expires = math.max(item.expires, os.clock() + 0.5)
	end
	if Motion.reduced then
		finishEntrance()
		return
	end
	item.enter = Motion.run(SPREAD_T, function(a)
		local t = a * SPREAD_T
		local dropColor = Theme.color(role)
		local elevated = Theme.color("Elevated") -- read every frame: a theme switch that starts with this toast must not leave a dark pill
		if t < FALL_T then
			-- falling: a tall drop, accelerating
			local u = t / FALL_T
			item.fall = -(item.y + 40) + (item.y + 40 + LAND) * u * u
			item.w, item.h = DROP_W, DROP_H
			item.pill.BackgroundColor3 = dropColor
			item.pill.BackgroundTransparency = math.max(0, 1 - t / 0.05)
		elseif t < SQUASH_T then
			-- landing: the drop flattens
			local u = (t - FALL_T) / (SQUASH_T - FALL_T)
			item.fall = LAND
			item.w = DROP_W + (34 - DROP_W) * u
			item.h = DROP_H + (12 - DROP_H) * u
			item.pill.BackgroundColor3 = dropColor
			item.pill.BackgroundTransparency = 0
			if not landed then
				landed = true
				showShadow(item, true)
			end
		else
			-- spreading into the pill (spring: overshoots a little, then settles)
			local v = math.min(1, (t - SQUASH_T) / (SPREAD_T - SQUASH_T))
			local s = Motion.ease.springSoft(v)
			item.fall = LAND * (1 - s)
			item.w = 34 + (item.targetW - 34) * s
			item.h = 12 + (item.targetH - 12) * s
			item.pill.BackgroundColor3 = Util.mix(dropColor, elevated, math.min(1, v * 2.4))
			item.pill.BackgroundTransparency = 0
			if not revealed and t > 0.42 then
				revealed = true
				fadeContent(item, true, 0.26)
			end
		end
		apply(item)
	end, Motion.ease.linear, finishEntrance)
end

----------------------------------------------------------------------------------------------------
-- pointer: press feedback, tap = dismiss, swipe up = dismiss
----------------------------------------------------------------------------------------------------
local function settleBack(item)
	stopRun(item, "settle")
	local from = item.drag
	if math.abs(from) < 0.5 then
		item.drag = 0
		apply(item)
		return
	end
	item.settle = Motion.run(0.5, function(a)
		item.drag = from * (1 - a)
		apply(item)
	end, Motion.ease.spring, function()
		item.drag = 0
		item.settle = nil
		apply(item)
	end)
end

local function attachPointer(item)
	local pill = item.pill
	pill.InputBegan:Connect(function(input)
		if item.closing or not item.entered or not UI.isPress(input) then
			return
		end
		local origin = input.Position
		local moved = false
		item.holding = true
		item.holdRemaining = item.expires - os.clock()
		Motion.cancel(item.bar)
		stopRun(item, "settle")
		Motion.tween(item.pressScale, { Scale = 0.97 }, 0.1, Enum.EasingStyle.Quad)
		UI.watchInput(input, function(i)
			local delta = i.Position - origin
			if not moved and math.abs(delta.X) + math.abs(delta.Y) > 9 then
				moved = true
			end
			if moved and not item.closing then
				local dy = delta.Y
				if dy > 0 then
					dy = dy * 0.25 -- rubber band when pulled down
				end
				item.drag = math.max(-160, dy)
				apply(item)
			end
		end, function(cancelled)
			item.holding = false
			Motion.tween(item.pressScale, { Scale = 1 }, 0.34, Enum.EasingStyle.Back)
			if item.closing then
				return
			end
			if not moved then
				if cancelled then
					return
				end
				Sfx.play("close")
				dismiss(item)
			elseif item.drag < -28 then
				Sfx.play("close")
				dismiss(item)
			else
				settleBack(item)
				local remaining = math.max(1.5, item.holdRemaining or 1.5)
				if not item.sticky then
					item.expires = os.clock() + remaining
					startBar(item, remaining)
				end
			end
		end)
	end)
end

----------------------------------------------------------------------------------------------------
-- building one pill
----------------------------------------------------------------------------------------------------
local function build(kind, title, text, spec, key, duration, sticky)
	local layerWidth = Notify.layer.AbsoluteSize.X
	if layerWidth <= 0 then
		layerWidth = Env.viewport().X
	end
	local width = Util.clamp(math.floor(layerWidth - 24), 220, 340)
	Notify.width = width
	Notify.counter = Notify.counter + 1
	local innerWidth = width - TEXT_X - PAD_R
	local hasBody = text ~= ""
	-- a first guess of the height (the real one is measured as soon as the text has been laid out)
	local k = Typo.scale or 1
	local titleLines = math.max(1, math.ceil(#title * 7.4 * k / math.max(60, innerWidth - 30)))
	local bodyLines = hasBody and math.max(1, math.ceil(#text * 6.3 * k / innerWidth)) or 0
	local guess = math.max(MIN_H, math.floor(titleLines * 17 * k + (hasBody and (2 + bodyLines * 15 * k) or 0) + PAD_TOP + PAD_BOTTOM))

	local item = {
		id = Notify.counter, key = key, kind = kind, spec = spec, count = 1, closing = false, entered = false, placed = false,
		sticky = sticky, duration = duration, hasBody = hasBody,
		expires = sticky and math.huge or (os.clock() + duration + SPREAD_T),
		w = DROP_W, h = DROP_H, targetW = width, targetH = guess, height = guess,
		y = Notify.top, fall = -(Notify.top + 40), drag = 0, wob = 0,
	}

	local slot = Util.new("Frame", {
		Name = "Slot", BackgroundTransparency = 1, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0), ZIndex = 201,
		Size = UDim2.fromOffset(DROP_W, DROP_H), Position = UDim2.new(0.5, 0, 0, -60),
	}, Notify.layer)
	item.slot = slot
	item.pressScale = Util.new("UIScale", { Scale = 1 }, slot)
	item.shadows = UI.shadow(slot, RADIUS, { zindex = 1, dy = 7, specs = { { 2, 0.9 }, { 7, 0.945 }, { 13, 0.972 }, { 20, 0.986 } } })
	showShadow(item, false)

	local pill = Util.new("TextButton", {
		Name = "Toast", Text = "", AutoButtonColor = false, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 2,
		ClipsDescendants = true, BackgroundColor3 = Theme.color(spec.role), BackgroundTransparency = 1,
	}, slot)
	Util.corner(pill, RADIUS)
	item.pill = pill

	-- a wash of the message colour on the left, then the glass finish (sheen, rim, top edge)
	local tint = Util.new("Frame", {
		Name = "Tint", Active = false, BorderSizePixel = 0, Size = UDim2.new(0.6, 0, 1, 0), ZIndex = 2,
	}, pill)
	Util.corner(tint, RADIUS)
	Theme.bind(tint, "BackgroundColor3", spec.role)
	Util.new("UIGradient", {
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(1, 1) }),
	}, tint)
	UI.glass(pill, { strength = 1, edge = true, zindex = 2, rimTransparency = 0.12 })

	-- the icon disc
	local disc = Util.new("Frame", {
		Name = "Disc", BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 12, 0, 22),
		Size = UDim2.fromOffset(30, 30), BackgroundTransparency = 1, ZIndex = 3,
	}, pill)
	Util.round_corner(disc)
	Theme.bind(disc, "BackgroundColor3", "Card", spec.role, 0.28)
	item.disc = disc
	item.discScale = Util.new("UIScale", { Scale = 0.01 }, disc)
	UI.icon(spec.icon, disc, 17, spec.role, { anchor = Vector2.new(0.5, 0.5), position = UDim2.fromScale(0.5, 0.5), zindex = 4 })

	-- the text block: a fixed width so the wrapping is the same while the pill is still spreading
	local inner = Util.new("Frame", {
		Name = "Inner", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, TEXT_X, 0.5, (PAD_TOP - PAD_BOTTOM) / 2),
		Size = UDim2.fromOffset(innerWidth, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 3,
	}, pill)
	Util.list(inner, 2)
	item.inner = inner
	local heading = Util.new("TextLabel", {
		Name = "Title", BackgroundTransparency = 1, LayoutOrder = 1, Size = UDim2.new(1, -30, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		Text = title, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
		TextTransparency = 1, ZIndex = 4,
	}, inner)
	Typo.apply(heading, "heading", 13)
	Theme.bind(heading, "TextColor3", "Text")
	item.title = heading
	local body = Util.new("TextLabel", {
		Name = "Text", BackgroundTransparency = 1, LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		Text = text, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
		Visible = hasBody, TextTransparency = 1, ZIndex = 4,
	}, inner)
	Typo.apply(body, "caption", 12)
	Theme.bind(body, "TextColor3", "Muted")
	item.body = body

	local badge = Util.new("TextLabel", {
		Name = "Count", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 11),
		Size = UDim2.fromOffset(34, 16), Text = "x2", TextXAlignment = Enum.TextXAlignment.Right, Visible = false,
		TextTransparency = 1, ZIndex = 4,
	}, pill)
	Typo.apply(badge, "label", 11)
	Theme.bind(badge, "TextColor3", spec.role)
	item.badge = badge

	-- the timer line (timed pills) or a grabber (pills that stay until dismissed)
	local bar = Util.new("Frame", {
		Name = "Timer", BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -5),
		Size = UDim2.new(1, -44, 0, 2), BackgroundTransparency = 1, ZIndex = 4,
	}, pill)
	Util.round_corner(bar)
	Theme.bind(bar, "BackgroundColor3", spec.role)
	item.bar = bar
	local grabber = Util.new("Frame", {
		Name = "Grabber", BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -5),
		Size = UDim2.fromOffset(26, 3), BackgroundTransparency = 1, ZIndex = 4,
	}, pill)
	Util.round_corner(grabber)
	Theme.bind(grabber, "BackgroundColor3", "Muted")
	item.grabber = grabber

	attachPointer(item)
	return item
end

-- kind: "success" | "warning" | "error" | "info"
-- opts: duration (seconds), key (merge key), force (show even when notifications are switched off)
function Notify.push(kind, title, text, opts)
	local spec = TOAST[kind] or TOAST.info
	opts = opts or {}
	if not Notify.layer or not Notify.layer.Parent then
		return nil
	end
	title, text = tostring(title or ""), tostring(text or "")
	local key = opts.key or (kind .. "|" .. title .. "|" .. text)
	record(kind, title, text, key)
	if not Store.get("notifications") and not opts.force then
		return nil
	end
	local sticky = (kind == "error") and Store.get("keepErrors") == true and opts.duration == nil
	local duration = opts.duration or Store.get("notifySeconds") or spec.duration

	-- a repeat of a message that is still on screen: count it, wobble, re-arm the timer
	for _, item in ipairs(Notify.items) do
		if item.key == key and not item.closing then
			item.count = item.count + 1
			item.badge.Text = "x" .. item.count
			item.badge.Visible = true
			item.duration = duration
			if not item.sticky then
				item.expires = os.clock() + duration
				if item.entered then
					startBar(item, duration)
				end
			end
			if item.entered then
				wobble(item)
			end
			Sfx.play(spec.sound)
			return item
		end
	end

	local item = build(kind, title, text, spec, key, duration, sticky)
	table.insert(Notify.items, 1, item)
	relayout()
	measure(item)
	enter(item)
	task.delay(0.06, function()
		Util.try("notify measure", measure, item)
	end)
	task.delay(0.5, function()
		Util.try("notify measure", measure, item)
	end)
	Sfx.play(spec.sound)
	Anim.add("notify", tick, 8)

	while #Notify.items > Notify.max do
		dismiss(Notify.items[#Notify.items])
	end
	return item
end

function Notify.success(title, text, opts)
	return Notify.push("success", title, text, opts)
end
function Notify.warn(title, text, opts)
	return Notify.push("warning", title, text, opts)
end
function Notify.error(title, text, opts)
	return Notify.push("error", title, text, opts)
end
function Notify.info(title, text, opts)
	return Notify.push("info", title, text, opts)
end

function Notify.clear(instant)
	local snapshot = {}
	for i, item in ipairs(Notify.items) do
		snapshot[i] = item
	end
	for _, item in ipairs(snapshot) do
		dismiss(item, instant)
	end
end

function Notify.destroy()
	Anim.remove("notify")
	for _, item in ipairs(Notify.items) do
		for _, field in ipairs({ "glide", "enter", "resize", "wobbleRun", "settle", "leave" }) do
			stopRun(item, field)
		end
	end
	Notify.items = {}
	if Notify.layer then
		pcall(Notify.layer.Destroy, Notify.layer)
		Notify.layer = nil
	end
end
end -- [07_notify.lua]

do -- [08_background.lua]

----------------------------------------------------------------------------------------------------
-- Bg: panel background system.
--   solid     flat theme colour
--   aurora    two drifting theme gradients                (procedural, no assets)
--   sparkle   slowly rising glints                        (procedural, no assets)
--   image     one static image (asset id, rbxassetid, file in VirexHub/backgrounds, or image URL)
--   sheet     sprite-sheet animation (cols x rows grid in ONE image)    <- GIF-like
--   sequence  list of images shown one after another                    <- GIF-like
--   video     Roblox VideoFrame (experimental, needs a Roblox-hosted video asset or a local webm/mp4)
-- Roblox ImageLabels cannot play GIF files and arbitrary video URLs cannot be streamed, which is why the
-- GIF-like modes use sheets / sequences. A dark overlay and a minimum darkness keep text readable.
----------------------------------------------------------------------------------------------------
Bg.layer = nil
Bg.content = nil
Bg.overlay = nil
Bg.mode = "solid"
Bg.token = 0
Bg.status = { kind = "idle", text = "Solid colour background." }
Bg.listeners = {}
Bg.blur = nil
Bg.cacheNote = nil

local MEDIA_MODES = { image = true, sheet = true, sequence = true, video = true }
Bg.MODES = {
	{ id = "facets", label = "Facets", sub = "Shards that catch light", isNew = true },
	{ id = "ribbons", label = "Ribbons", sub = "Soft light curtains", isNew = true },
	{ id = "stars", label = "Stars", sub = "Deep star field", isNew = true },
	{ id = "lattice", label = "Lattice", sub = "Gem mesh, moving light", isNew = true },
	{ id = "aurora", label = "Aurora", sub = "Two drifting gradients" },
	{ id = "sparkle", label = "Sparkle", sub = "Slowly rising glints" },
	{ id = "solid", label = "Solid", sub = "Flat theme colour" },
	{ id = "image", label = "Image", sub = "Your own picture" },
	{ id = "sheet", label = "Sprite sheet", sub = "Animated grid image" },
	{ id = "sequence", label = "Image sequence", sub = "Several pictures in turn" },
	{ id = "video", label = "Video (beta)", sub = "Roblox video asset" },
}
-- the styles that are drawn from Frames only (no files)
Bg.PROCEDURAL = { facets = true, ribbons = true, stars = true, lattice = true, aurora = true, sparkle = true }

function Bg.onStatus(fn)
	Bg.listeners[#Bg.listeners + 1] = fn
	return function()
		local index = Util.indexOf(Bg.listeners, fn)
		if index then
			table.remove(Bg.listeners, index)
		end
	end
end

function Bg.setStatus(kind, text)
	Bg.status = { kind = kind, text = text }
	for _, fn in ipairs(Util.copy(Bg.listeners)) do
		Util.try("bg status listener", fn, kind, text)
	end
end

function Bg.animated()
	return not Store.get("reducedMotion") and not Store.get("lowPower")
end

function Bg.init(layer)
	Bg.layer = layer
	Theme.G.aurora2 = function(l)
		return ColorSequence.new({
			ColorSequenceKeypoint.new(0, Util.mix(l.Background, l.Accent2, 0.22)),
			ColorSequenceKeypoint.new(0.5, l.Background),
			ColorSequenceKeypoint.new(1, Util.mix(l.Background, l.Accent, 0.26)),
		})
	end
	Bg.content = Util.new("Frame", {
		Name = "BgContent", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 1,
	}, layer)
	Bg.overlay = Util.new("Frame", {
		Name = "BgOverlay", BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1, ZIndex = 2,
	}, layer)
	Util.corner(Bg.overlay, 16)
	-- the layers (Sparkle, Light sweep, Vignette, Edge glow) sit above the style and the dark overlay
	Bg.top = Util.new("Frame", {
		Name = "BgLayers", Active = false, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 3,
	}, layer)
	Bg.px, Bg.py, Bg.tx, Bg.ty = 0, 0, 0, 0
	Bg.lastLight = Theme.light
	if Win.maid then
		Bg.watchPointer(Win.maid)
		Win.maid:Give(Theme.onChange(function()
			-- the styles pick their highlight colour when they are built (a light theme uses the accent): rebuild when that flips
			if Theme.light ~= Bg.lastLight then
				Bg.lastLight = Theme.light
				if Bg.PROCEDURAL[Bg.mode] then
					Bg.apply()
				end
				Bg.applyLayers()
			end
		end))
	end
end

function Bg.clearContent()
	Anim.remove("bg")
	if Bg.content then
		for _, child in ipairs(Bg.content:GetChildren()) do
			child:Destroy()
		end
	end
	UI.prune()
end

function Bg.updateOverlay()
	if not Bg.overlay then
		return
	end
	local amount = 0
	if MEDIA_MODES[Bg.mode] then
		amount = math.max(Store.get("overlay"), 0.2) -- never let media make the UI unreadable
	end
	Motion.tween(Bg.overlay, { BackgroundTransparency = 1 - amount }, 0.25)
end

function Bg.setOverlay(value)
	Store.set("overlay", value)
	Bg.updateOverlay()
end

function Bg.setGlass(value)
	Store.set("glass", value)
	Theme.setGlass(value)
end

----------------------------------------------------------------------------------------------------
-- source resolution (yields when it has to download)
----------------------------------------------------------------------------------------------------
local function detectImageKind(bytes)
	if type(bytes) ~= "string" or #bytes < 12 then
		return nil
	end
	local b1, b2, b3, b4 = string.byte(bytes, 1, 4)
	if b1 == 0x89 and b2 == 0x50 and b3 == 0x4E and b4 == 0x47 then
		return "png"
	elseif b1 == 0xFF and b2 == 0xD8 and b3 == 0xFF then
		return "jpg"
	elseif string.sub(bytes, 1, 4) == "RIFF" and string.sub(bytes, 9, 12) == "WEBP" then
		return "webp"
	elseif string.sub(bytes, 1, 3) == "GIF" then
		return "gif"
	end
	return nil
end

local function robloxAssetFromUrl(text)
	local id = string.match(text, "roblox%.com/asset/?%?id=(%d+)") or string.match(text, "roblox%.com/library/(%d+)")
	if id then
		return "rbxassetid://" .. id
	end
	return nil
end

local GIF_HELP = "GIF files do not animate in Roblox. Convert it to a sprite sheet (one grid image) or an image sequence."

-- width and height of a PNG or JPG from its header (nil when it cannot be read). Only used to word an error message.
local function imageSize(bytes, kind)
	if kind == "png" and #bytes >= 24 then
		local a, b, c, d, e, f, g, h = string.byte(bytes, 17, 24)
		return a * 16777216 + b * 65536 + c * 256 + d, e * 16777216 + f * 65536 + g * 256 + h
	elseif kind == "jpg" then
		local length, pos = #bytes, 3
		while pos + 8 <= length do
			if string.byte(bytes, pos) ~= 0xFF then
				pos = pos + 1
			else
				local marker = string.byte(bytes, pos + 1)
				if marker == 0xFF then
					pos = pos + 1 -- a fill byte
				elseif marker == 0xD8 or marker == 0x01 or (marker >= 0xD0 and marker <= 0xD7) then
					pos = pos + 2 -- markers that have no length
				elseif marker >= 0xC0 and marker <= 0xCF and marker ~= 0xC4 and marker ~= 0xC8 and marker ~= 0xCC then
					local h1, h2, w1, w2 = string.byte(bytes, pos + 5, pos + 8)
					return w1 * 256 + w2, h1 * 256 + h2
				else
					pos = pos + 2 + math.max(string.byte(bytes, pos + 2) * 256 + string.byte(bytes, pos + 3), 2)
				end
			end
		end
	end
	return nil
end

local function sizeText(count)
	if count >= 1048576 then
		return string.format("%.1f MB", count / 1048576)
	end
	return string.format("%d KB", math.max(1, math.floor(count / 1024 + 0.5)))
end

-- what a picture file of the workspace is, for an error message: { kind, width, height, text = "PNG 720x1612, 1.4 MB" } or nil
function Bg.fileInfo(path)
	if type(path) ~= "string" then
		return nil
	end
	local okRead, data = pcall(Env.readFile, path)
	if not okRead or type(data) ~= "string" then
		return nil
	end
	local kind = detectImageKind(data)
	if not kind then
		return nil
	end
	local width, height = imageSize(data, kind)
	local text = string.upper(kind)
	if width and height then
		text = text .. " " .. width .. "x" .. height
	end
	return { kind = kind, width = width, height = height, text = text .. ", " .. sizeText(#data) }
end

-- what Roblox answered and what the file is, in one phrase: "Roblox said: Failure; PNG 720x1612, 1.4 MB"
function Bg.loadDetail(why, info)
	local text = (why == nil or why == "no answer") and "Roblox did not answer" or ("Roblox said: " .. tostring(why))
	if info then
		text = text .. "; " .. info.text
	end
	return text
end

-- what to try when a picture file could not be shown
function Bg.loadHint(info)
	if info and info.kind == "webp" then
		return "WEBP is not on Roblox's list of image formats: use a PNG or JPG."
	end
	if info and ((info.width or 0) > 4096 or (info.height or 0) > 4096) then
		return "The picture is larger than 4096 px, which Roblox may refuse: use a smaller one."
	end
	return "This executor may not show pictures from files: a Roblox Image asset ID always works."
end

-- the message for a picture that Roblox did not load. A Roblox asset gets the advice about Image / Decal IDs; a file of the executor gets what is known about it.
function Bg.loadFailure(result, why)
	if result and result.isLocal then
		local info = Bg.fileInfo(result.path)
		return "The picture file could not be shown (" .. Bg.loadDetail(why, info) .. "). " .. Bg.loadHint(info)
	end
	return "The image could not be loaded. Check the ID (use the Image asset ID, not a Decal ID) and that the asset is public."
end

-- returns { ok = true, url = "rbxasset..." , note = "..." } or { ok = false, reason = "..." }. say(kind, text) (optional) gets the "Downloading" notice instead of the background status.
-- A picture that comes from a file of the executor (a download, the cache or a local file) also has isLocal = true and path.
function Bg.resolve(text, wantVideo, say)
	text = Util.trim(text)
	if text == "" then
		return { ok = false, reason = "Enter an asset ID, file name or image link first." }
	end
	if string.match(text, "^%d+$") then
		return { ok = true, url = "rbxassetid://" .. text, note = "Roblox asset ID" }
	end
	if string.match(text, "^rbxassetid://%d+$") or string.match(text, "^rbxthumb://") or string.match(text, "^rbxasset://") then
		return { ok = true, url = text, note = "Roblox asset" }
	end
	local lower = string.lower(text)
	if string.match(lower, "^https?://") then
		local asset = robloxAssetFromUrl(lower)
		if asset then
			return { ok = true, url = asset, note = "Roblox asset link" }
		end
		if wantVideo then
			return { ok = false, reason = "Video links cannot be streamed. Use a Roblox video asset ID or a local .webm/.mp4 file." }
		end
		if not Env.canDownload() or not Env.filesWork() then
			return { ok = false, reason = "Image links need working executor file + HTTP support, which was not available here. Use a Roblox asset ID instead." }
		end
		if string.match(lower, "%.gif[%?#]?") or string.match(lower, "%.gif$") then
			return { ok = false, reason = GIF_HELP }
		end
		-- a previous download of the same link is reused instead of downloading it again
		for _, ext in ipairs({ "png", "jpg", "webp" }) do
			local cached = CONFIG.CacheFolder .. "/bg_" .. Util.hash(text) .. "." .. ext
			if Env.fileExists(cached) then
				local cachedAsset = Env.customAsset(cached)
				if cachedAsset then
					return { ok = true, url = cachedAsset, note = "cached " .. string.upper(ext), isLocal = true, path = cached }
				end
			end
		end
		(say or Bg.setStatus)("loading", "Downloading image...")
		local body, err = Env.httpGet(text)
		if not body then
			return { ok = false, reason = "Download failed (" .. tostring(err) .. ")." }
		end
		if #body > 12 * 1024 * 1024 then
			return { ok = false, reason = "That image is larger than 12 MB." }
		end
		local kind = detectImageKind(body)
		if kind == "gif" then
			return { ok = false, reason = GIF_HELP }
		elseif not kind then
			return { ok = false, reason = "The link did not return a PNG, JPG or WEBP image." }
		end
		Env.ensureFolder(CONFIG.Folder)
		Env.ensureFolder(CONFIG.CacheFolder)
		local path = CONFIG.CacheFolder .. "/bg_" .. Util.hash(text) .. "." .. kind
		local wrote, writeErr = Env.writeFile(path, body)
		if not wrote then
			return { ok = false, reason = "Could not save the download (" .. tostring(writeErr) .. ")." }
		end
		local asset, assetErr = Env.customAsset(path)
		if not asset then
			return { ok = false, reason = "This executor could not turn the file into an asset (" .. tostring(assetErr) .. ")." }
		end
		return { ok = true, url = asset, note = "downloaded " .. kind:upper(), isLocal = true, path = path }
	end

	-- a file name / relative path inside the executor workspace
	if not Env.canCustomAsset() then
		return { ok = false, reason = "Local files need executor file + custom-asset support, which was not detected." }
	end
	if not Env.filesWork() then
		return { ok = false, reason = "This executor blocked file access, so local files cannot be used. Roblox asset IDs still work." }
	end
	local candidates = { text, CONFIG.BackgroundFolder .. "/" .. text }
	for _, path in ipairs(candidates) do
		if Env.fileExists(path) then
			local data = Env.readFile(path)
			if wantVideo then
				if not (string.match(lower, "%.webm$") or string.match(lower, "%.mp4$")) then
					return { ok = false, reason = "Video files must be .webm or .mp4." }
				end
			else
				local kind = detectImageKind(data)
				if kind == "gif" then
					return { ok = false, reason = GIF_HELP }
				elseif not kind then
					return { ok = false, reason = "'" .. text .. "' is not a PNG, JPG or WEBP image." }
				end
			end
			local asset, assetErr = Env.customAsset(path)
			if not asset then
				return { ok = false, reason = "This executor could not load that file as an asset (" .. tostring(assetErr) .. ")." }
			end
			return { ok = true, url = asset, note = "local file", isLocal = true, path = path }
		end
	end
	return { ok = false, reason = "File not found. Put it in the executor workspace folder '" .. CONFIG.BackgroundFolder .. "'." }
end

local function imageLoaded(label)
	local ok, loaded = pcall(function()
		return label.IsLoaded
	end)
	return ok and loaded == true
end

-- Waits (yields) until an ImageLabel's image is fetched or the timeout passes. Returns true, or false and what Roblox answered.
-- isLocal: the picture is a file of the executor (getcustomasset). PreloadAsync is not reliable for those, and Roblox treats a label that is fully
-- transparent as unused (it is never reported as loaded), so such a label is drawn at 99% transparency while it is checked and IsLoaded is
-- watched as well as PreloadAsync: either one is enough.
function Bg.verifyImage(label, timeout, isLocal)
	if not ContentProvider then
		return true, "unverified"
	end
	local succeeded, finished, said = false, false, nil
	local limit = timeout or 8
	local original, hidden
	if isLocal then
		limit = math.min(limit, 7)
		local okRead, value = pcall(function()
			return label.ImageTransparency
		end)
		if okRead and type(value) == "number" and value > 0.99 then
			original = value
			pcall(function()
				label.ImageTransparency = 0.99
			end)
		end
		-- a label that is not visible is not drawn either (the frames of an image sequence wait hidden)
		local okShown, shown = pcall(function()
			return label.Visible
		end)
		if okShown and shown == false then
			hidden = true
			pcall(function()
				label.Visible = true
			end)
		end
	end
	task.spawn(function()
		local ok = pcall(ContentProvider.PreloadAsync, ContentProvider, { label }, function(_, status)
			said = tostring(status)
			if said == "Enum.AssetFetchStatus.Success" then
				succeeded = true
			end
		end)
		if not ok then
			succeeded = true -- preloading unsupported: let Roblox stream it
		end
		finished = true
	end)
	local started = os.clock()
	while os.clock() - started < limit do
		if succeeded or (isLocal and imageLoaded(label)) or (finished and not isLocal) then
			break
		end
		task.wait(0.05)
	end
	local loaded = succeeded or imageLoaded(label)
	if original then
		pcall(function()
			label.ImageTransparency = original
		end)
	end
	if hidden then
		pcall(function()
			label.Visible = false
		end)
	end
	if loaded then
		return true
	end
	if said then
		return false, (string.gsub(said, "^Enum%.AssetFetchStatus%.", ""))
	end
	return false, "no answer"
end

----------------------------------------------------------------------------------------------------
-- procedural modes
----------------------------------------------------------------------------------------------------
local function gate()
	return Theme.active()
end

function Bg.buildAurora()
	local layers = {}
	local specs = { { builder = Theme.G.aurora, transparency = 0, speed = 5 }, { builder = Theme.G.aurora2, transparency = 0.45, speed = -7 } }
	for i, spec in ipairs(specs) do
		local frame = Util.new("Frame", {
			Name = "Aurora" .. i, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = spec.transparency, ZIndex = i,
		}, Bg.content)
		Util.corner(frame, 16)
		local gradient = Util.new("UIGradient", { Rotation = i == 1 and 25 or 140 }, frame)
		Theme.gradient(gradient, spec.builder)
		layers[i] = { gradient = gradient, speed = spec.speed, base = i == 1 and 25 or 140 }
	end
	if Bg.animated() then
		Anim.add("bg", function(_, now)
			for i, layer in ipairs(layers) do
				layer.gradient.Rotation = (layer.base + now * layer.speed) % 360
				layer.gradient.Offset = Vector2.new(0.22 * math.sin(now * 0.31 + i), 0.22 * math.cos(now * 0.23 + i * 2))
			end
		end, 20, gate)
	end
	Bg.setStatus("ok", "Aurora - animated theme gradient.")
end

-- slowly rising glints; `parent` is the style's content or the layers host
function Bg.sparkleInto(parent, count, job)
	local particles = {}
	local seed = 17
	local function rand()
		seed = (seed * 1103515245 + 12345) % 2147483648
		return seed / 2147483648
	end
	for i = 1, count do
		local size = 2 + math.floor(rand() * 3)
		local dot = Util.new("Frame", {
			Name = "Glint" .. i, Active = false, BorderSizePixel = 0, Size = UDim2.fromOffset(size, size), AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 0.6, ZIndex = 1, Position = UDim2.fromScale(0.04 + rand() * 0.92, 0.05 + rand() * 0.9),
		}, parent)
		Util.round_corner(dot)
		Theme.bind(dot, "BackgroundColor3", Theme.light and "Accent" or "Shine")
		particles[i] = { dot = dot, x = 0.04 + rand() * 0.92, y = rand(), speed = 0.012 + rand() * 0.02, tw = 0.8 + rand() * 1.6, ph = rand() * 6.28 }
	end
	if Bg.animated() then
		Anim.add(job, function(_, now)
			for _, p in ipairs(particles) do
				local y = (p.y - p.speed * now) % 1
				p.dot.Position = UDim2.fromScale(p.x, 0.04 + y * 0.92)
				p.dot.BackgroundTransparency = 0.45 + 0.5 * (0.5 + 0.5 * math.sin(now * p.tw + p.ph))
			end
		end, 20, gate)
	end
end

function Bg.buildSparkle()
	Bg.sparkleInto(Bg.content, Bg.animated() and 24 or 12, "bg")
	Bg.setStatus("ok", "Sparkle - slow rising glints.")
end

----------------------------------------------------------------------------------------------------
-- 2.4.0: four procedural styles from the VYRE / NEXUS design (Facets, Ribbons, Stars, Lattice), the layers that sit on top of
-- any style (Sparkle, Light sweep, Vignette, Edge glow) and the touch parallax. All of it is Frames, UIGradients and UIStrokes
-- (no images, no blur). What a style costs is counted from the instances it really made (Bg.cost).
----------------------------------------------------------------------------------------------------
Bg.px, Bg.py, Bg.tx, Bg.ty = 0, 0, 0, 0 -- parallax offset (design units) and its target (-1 .. 1)
Bg.lastLight = false
local FROZEN = 4.2 -- the moment a still frame (reduced motion, low power) is drawn at

local function rng(seed)
	local state = seed
	return function()
		state = (state * 1103515245 + 12345) % 2147483648
		return state / 2147483648
	end
end

local function smooth(a, b, x)
	local t = Util.clamp((x - a) / (b - a), 0, 1)
	return t * t * (3 - 2 * t)
end

-- the highlight of a palette (a light theme uses its accent: white would vanish on white)
local function hiColor(l)
	return Theme.light and l.Accent or l.Shine
end

-- how far (design units) the nearest layer travels with the touch parallax
function Bg.parallaxAmount()
	if Store.get("parallax") == "off" or Motion.reduced or Store.get("lowPower") then
		return 0
	end
	return Store.get("parallaxAmount") / 100 * 16
end

function Bg.stepParallax()
	local amp = Bg.parallaxAmount()
	Bg.px = Bg.px + (Bg.tx * amp - Bg.px) * 0.18
	Bg.py = Bg.py + (Bg.ty * amp - Bg.py) * 0.18
end

function Bg.setParallax(nx, ny)
	Bg.tx, Bg.ty = Util.clamp(nx, -1, 1), Util.clamp(ny, -1, 1)
end

-- draws one still frame, then keeps drawing while animation is allowed
local function run(update, hz)
	update(FROZEN)
	if Bg.animated() then
		Anim.add("bg", function(_, now)
			Bg.stepParallax()
			update(now)
		end, hz, gate)
	end
end

local function bar(parent, name, z, w, h)
	local frame = Util.new("Frame", {
		Name = name, Active = false, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(w, h),
		BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = z, Visible = false,
	}, parent)
	Theme.bind(frame, "BackgroundColor3", Theme.light and "Accent" or "Shine")
	return frame
end

function Bg.buildFacets()
	local W, H = Win.w or 640, Win.h or 510
	local m = math.min(W, H)
	local rand = rng(7)
	local content = Bg.content
	local wash = Util.new("Frame", {
		Name = "Wash", Active = false, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 1,
	}, content)
	Util.corner(wash, 16)
	local washGradient = Util.new("UIGradient", {
		Rotation = 35,
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.87), NumberSequenceKeypoint.new(0.5, 1), NumberSequenceKeypoint.new(1, 0.89) }),
	}, wash)
	Theme.gradient(washGradient, function(l)
		return ColorSequence.new({
			ColorSequenceKeypoint.new(0, l.Accent2), ColorSequenceKeypoint.new(0.5, l.Background), ColorSequenceKeypoint.new(1, l.Accent),
		})
	end)
	local shards = {}
	for i = 1, 16 do
		local s = { x = rand(), y = rand() }
		local size = (i <= 9) and Util.lerp(0.24, 0.5, rand()) or Util.lerp(0.07, 0.17, rand())
		s.ar, s.rot = Util.lerp(0.5, 1, rand()), rand() * math.pi
		s.vr, s.vx, s.vy = (rand() - 0.5) * 0.02, (rand() - 0.5) * 0.006, (rand() - 0.5) * 0.004
		s.tone, s.z = rand(), Util.lerp(0.35, 1, rand())
		s.w = math.max(10, math.floor(size * m * 1.4))
		s.h = math.max(8, math.floor(s.w * s.ar))
		local frame = Util.new("Frame", {
			Name = "Shard" .. i, Active = false, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(s.w, s.h),
			BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 1 + i,
		}, content)
		s.frame = frame
		s.gradient = Util.new("UIGradient", { Rotation = math.deg(math.atan(s.h / s.w)) }, frame)
		local tone = s.tone
		Theme.gradient(s.gradient, function(l)
			return ColorSequence.new({
				ColorSequenceKeypoint.new(0, hiColor(l)), ColorSequenceKeypoint.new(0.55, tone < 0.5 and l.Accent or l.Accent2),
				ColorSequenceKeypoint.new(1, l.Accent2),
			})
		end)
		s.stroke = Util.stroke(frame, nil, 1, 0.95)
		Theme.bind(s.stroke, "Color", Theme.light and "Accent" or "Shine")
		shards[i] = s
	end
	local glints = {}
	for i = 1, 8 do
		glints[i] = { h = bar(content, "GlintH" .. i, 30, 8, 1), v = bar(content, "GlintV" .. i, 30, 1, 8) }
	end
	local ang = -0.44
	local nx, ny = math.cos(ang), math.sin(ang)
	local pmin = math.min(0, W * nx, H * ny, W * nx + H * ny)
	local pmax = math.max(0, W * nx, H * ny, W * nx + H * ny)
	local bw = (pmax - pmin) * 0.17
	run(function(t)
		local p0 = Util.lerp(pmin - bw, pmax + bw, (t / 10) % 1.3)
		local used = 0
		for _, s in ipairs(shards) do
			local cx = ((s.x + s.vx * t) % 1.4) - 0.2
			local cy = ((s.y + s.vy * t) % 1.4) - 0.2
			local ox, oy = Bg.px * s.z, Bg.py * s.z
			local X, Y = cx * W + ox, cy * H + oy
			local rot = s.rot + s.vr * t
			local g = 1 - smooth(0, bw, math.abs(X * nx + Y * ny - p0))
			s.frame.Position = UDim2.new(cx, math.floor(ox + 0.5), cy, math.floor(oy + 0.5))
			s.frame.Rotation = math.deg(rot) % 360
			s.gradient.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1 - (0.05 + 0.16 * g + 0.04 * s.z)),
				NumberSequenceKeypoint.new(0.55, 1 - (0.05 + 0.1 * g)),
				NumberSequenceKeypoint.new(1, 1),
			})
			s.stroke.Transparency = 1 - (0.05 + 0.5 * g * g)
			if g > 0.55 and used < #glints then
				used = used + 1
				local qx = X + math.cos(rot) * (s.w / 2) + math.sin(rot) * (s.h / 2)
				local qy = Y + math.sin(rot) * (s.w / 2) - math.cos(rot) * (s.h / 2)
				local len = math.floor(3 + 6 * g)
				local glint = glints[used]
				local pos = UDim2.fromOffset(math.floor(qx), math.floor(qy))
				glint.h.Position, glint.v.Position = pos, pos
				glint.h.Size, glint.v.Size = UDim2.fromOffset(len * 2, 1), UDim2.fromOffset(1, len * 2)
				glint.h.BackgroundTransparency = 1 - 0.62 * g * g
				glint.v.BackgroundTransparency = 1 - 0.62 * g * g
				glint.h.Visible, glint.v.Visible = true, true
			end
		end
		for i = used + 1, #glints do
			glints[i].h.Visible, glints[i].v.Visible = false, false
		end
	end, 15)
	Bg.setStatus("ok", "Facets - shards that catch a travelling light.")
end

function Bg.buildRibbons()
	local W, H = Win.w or 640, Win.h or 510
	local rand = rng(11)
	local specs = {
		{ a = -0.52, y = 0.3, th = 0.5, col = "Accent", al = 0.22, sp = 0.07 },
		{ a = -0.3, y = 0.58, th = 0.42, col = "Accent2", al = 0.24, sp = 0.05 },
		{ a = -0.12, y = 0.8, th = 0.34, col = "Shine", al = 0.1, sp = 0.09 },
		{ a = 0.24, y = 0.18, th = 0.3, col = "Accent2", al = 0.13, sp = 0.06 },
	}
	local ribbons = {}
	for i, b in ipairs(specs) do
		b.ph = rand() * 6
		local th = math.floor(H * b.th)
		local frame = Util.new("Frame", {
			Name = "Ribbon" .. i, Active = false, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(2.4, 0, 0, th),
			BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = i,
		}, Bg.content)
		b.frame = frame
		b.gradient = Util.new("UIGradient", { Rotation = 90 }, frame)
		local role = b.col
		if role == "Shine" and Theme.light then
			role = "Accent"
		end
		Theme.bind(frame, "BackgroundColor3", role)
		ribbons[i] = b
	end
	run(function(t)
		for i, b in ipairs(ribbons) do
			local depth = 0.4 + i * 0.15
			b.frame.Position = UDim2.new(0.5, math.floor(Bg.px * depth + 0.5), b.y + 0.06 * math.sin(t * b.sp * 6.2832 + b.ph), math.floor(Bg.py * depth + 0.5))
			b.frame.Rotation = math.deg(b.a + 0.05 * math.sin(t * b.sp * 3 + b.ph))
			local al = b.al * (0.82 + 0.18 * math.sin(t * 0.5 + b.ph))
			b.gradient.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 1 - al), NumberSequenceKeypoint.new(1, 1),
			})
		end
	end, 12)
	Bg.setStatus("ok", "Ribbons - soft curtains of light.")
end

function Bg.buildStars()
	local W, H = Win.w or 640, Win.h or 510
	local rand = rng(23)
	local content = Bg.content
	local wash = Util.new("Frame", {
		Name = "Wash", Active = false, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 1,
	}, content)
	Util.corner(wash, 16)
	local washGradient = Util.new("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.86), NumberSequenceKeypoint.new(0.7, 1), NumberSequenceKeypoint.new(1, 0.93) }),
	}, wash)
	Theme.gradient(washGradient, function(l)
		return ColorSequence.new({
			ColorSequenceKeypoint.new(0, l.Accent2), ColorSequenceKeypoint.new(0.7, l.Background), ColorSequenceKeypoint.new(1, l.Accent),
		})
	end)
	local layers = {
		{ n = 30, size = 1, speed = 2.5, al = 0.55, z = 0.3 },
		{ n = 16, size = 2, speed = 5, al = 0.75, z = 0.7 },
		{ n = 6, size = 2, speed = 9, al = 0.95, z = 1.2, cross = true },
	}
	local stars = {}
	for li, L in ipairs(layers) do
		for i = 1, L.n do
			local s = { L = L, x = rand(), y = rand(), tw = 0.6 + rand() * 1.8, ph = rand() * 6.2832 }
			if L.cross then
				s.holder = Util.new("Frame", {
					Name = "Cross" .. i, Active = false, BackgroundTransparency = 1, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
					Size = UDim2.fromOffset(9, 9), ZIndex = 10 + li,
				}, content)
				s.parts = { bar(s.holder, "H", 1, 9, 1), bar(s.holder, "V", 1, 1, 9), bar(s.holder, "C", 2, 2, 2) }
				for _, part in ipairs(s.parts) do
					part.Position = UDim2.fromScale(0.5, 0.5)
					part.Visible = true
				end
			else
				s.dot = bar(content, "Star", 5 + li, L.size, L.size)
				s.dot.Visible = true
				s.parts = { s.dot }
			end
			stars[#stars + 1] = s
		end
	end
	-- a shooting star every nine seconds
	local trail = Util.new("Frame", {
		Name = "Shooting", Active = false, BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.fromOffset(100, 2),
		BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 20, Visible = false, Rotation = -34,
	}, content)
	Util.new("UIGradient", {
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1) }),
	}, trail)
	Theme.bind(trail, "BackgroundColor3", Theme.light and "Accent" or "Shine")
	run(function(t)
		for _, s in ipairs(stars) do
			local L = s.L
			local xs = (s.x - t * L.speed / W + Bg.px * L.z / W) % 1
			local ys = (s.y + Bg.py * L.z / H) % 1
			local a = L.al * (0.35 + 0.65 * (0.5 + 0.5 * math.sin(t * s.tw + s.ph)))
			local holder = s.holder or s.dot
			holder.Position = UDim2.fromScale(xs, ys)
			for _, part in ipairs(s.parts) do
				part.BackgroundTransparency = 1 - a
			end
		end
		local cycle = 9
		local k = math.floor(t / cycle)
		local lt = t - k * cycle
		if lt < 0.9 then
			local rr = rng(k * 97 + 5)
			local p = lt / 0.9
			local sx, sy = W * (0.45 + rr() * 0.5), H * (0.04 + rr() * 0.22)
			trail.Position = UDim2.fromOffset(math.floor(sx - p * W * 0.45), math.floor(sy + p * H * 0.36))
			trail.Visible = true
		else
			trail.Visible = false
		end
	end, 12)
	Bg.setStatus("ok", "Stars - a deep star field with an occasional shooting star.")
end

local LATTICE_STEP = 56

function Bg.buildLattice()
	local W, H = Win.w or 640, Win.h or 510
	local s = LATTICE_STEP
	local content = Bg.content
	local wash = Util.new("Frame", {
		Name = "Wash", Active = false, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 1,
	}, content)
	Util.corner(wash, 16)
	local washGradient = Util.new("UIGradient", {
		Rotation = 35, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.9), NumberSequenceKeypoint.new(1, 0.92) }),
	}, wash)
	Theme.gradient(washGradient, function(l)
		return ColorSequence.new({ ColorSequenceKeypoint.new(0, l.Accent2), ColorSequenceKeypoint.new(1, l.Accent) })
	end)
	-- every line of the mesh is one thin bar with its own gradient, so the travelling light can run along it
	local bars = {}
	local length = math.floor(H * 1.4143) + 4
	for k = -H, W + H, s do
		for dir = 1, 2 do
			local frame = Util.new("Frame", {
				Name = "Line", Active = false, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(length, 1),
				BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 2, Rotation = dir == 1 and 45 or -45,
			}, content)
			local gradient = Util.new("UIGradient", {}, frame)
			Theme.bind(frame, "BackgroundColor3", Theme.light and "Accent" or "Shine")
			bars[#bars + 1] = { frame = frame, gradient = gradient, k = k, dir = dir, lastLit = true }
		end
	end
	local glints = {}
	for i = 1, 16 do
		local glint = bar(content, "Glint" .. i, 30, 3, 3)
		glint.Rotation = 45
		glints[i] = glint
	end
	local axis = W * W + 0.49 * H * H
	local a0 = Theme.light and 0.1 or 0.07
	local function proj(x, y)
		return (x * W + y * 0.7 * H) / axis
	end
	run(function(t)
		local ph = (t / 9) % 1.5
		local p = Util.lerp(-0.25, 1.25, math.min(ph, 1))
		local ox = (Bg.px * 0.6) % s
		for _, b in ipairs(bars) do
			-- the bar runs from (x0, y0) to (x0 + H, y0 +- H); sample the band along it
			local x0 = b.k + ox
			local y0 = b.dir == 1 and 0 or H
			local dy = b.dir == 1 and H or -H
			b.frame.Position = UDim2.fromOffset(math.floor(x0 + H / 2), math.floor(H / 2))
			local keys, lit = {}, false
			for i = 0, 6 do
				local u = i / 6
				local d = math.abs(proj(x0 + H * u, y0 + dy * u) - p)
				local a = a0 + (0.6 - a0) * math.max(0, 1 - d / 0.2)
				if a > a0 + 0.01 then
					lit = true
				end
				keys[#keys + 1] = NumberSequenceKeypoint.new(u, 1 - a)
			end
			if lit or b.lastLit then
				b.gradient.Transparency = NumberSequence.new(keys)
			end
			b.lastLit = lit
		end
		-- glints sit on the mesh nodes the light is passing; a small pool is reused
		local nodes = {}
		for a = -H, W + H, s do
			for c = 0, W + H, s do
				local x, y = (a + c) / 2 + ox, (c - a) / 2
				if x >= 0 and x <= W and y >= 0 and y <= H then
					local g = smooth(0.62, 1, 1 - smooth(0, 0.2, math.abs(proj(x, y) - p)))
					if g > 0.02 then
						nodes[#nodes + 1] = { x, y, g }
					end
				end
			end
		end
		table.sort(nodes, function(u, v)
			return u[3] > v[3]
		end)
		for i, glint in ipairs(glints) do
			local node = nodes[i]
			if node then
				local q = math.floor(1.8 + 2.4 * node[3] + 0.5)
				glint.Size = UDim2.fromOffset(q, q)
				glint.Position = UDim2.fromOffset(math.floor(node[1]), math.floor(node[2]))
				glint.BackgroundTransparency = 1 - 0.62 * node[3]
				glint.Visible = true
			else
				glint.Visible = false
			end
		end
	end, 10)
	Bg.setStatus("ok", "Lattice - a gem mesh with a travelling light.")
end

----------------------------------------------------------------------------------------------------
-- layers on top of any style (Background > Layers)
----------------------------------------------------------------------------------------------------
function Bg.applyLayers()
	Anim.remove("bglayers")
	if not Bg.top then
		return
	end
	for _, child in ipairs(Bg.top:GetChildren()) do
		child:Destroy()
	end
	if Store.get("layerSparkle") then
		Bg.sparkleInto(Bg.top, 14, "bglayers")
	end
	if Store.get("layerSweep") then
		local sweep = Util.new("Frame", {
			Name = "Sweep", Active = false, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 2,
		}, Bg.top)
		Util.corner(sweep, 16)
		Theme.bind(sweep, "BackgroundColor3", Theme.light and "Accent" or "Shine")
		local gradient = Util.new("UIGradient", {
			Rotation = 20, Offset = Vector2.new(1, 0),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.4, 1), NumberSequenceKeypoint.new(0.5, 0.9),
				NumberSequenceKeypoint.new(0.6, 1), NumberSequenceKeypoint.new(1, 1),
			}),
		}, sweep)
		Theme.fxSweep(gradient, 8, 0.5, 1, 0.1)
	end
	if Store.get("layerVignette") then
		local specs = {
			{ "Top", UDim2.new(1, 0, 0, 56), UDim2.fromOffset(0, 0), Vector2.new(0, 0), 90 },
			{ "Bottom", UDim2.new(1, 0, 0, 56), UDim2.new(0, 0, 1, 0), Vector2.new(0, 1), 270 },
			{ "Left", UDim2.new(0, 56, 1, 0), UDim2.fromOffset(0, 0), Vector2.new(0, 0), 0 },
			{ "Right", UDim2.new(0, 56, 1, 0), UDim2.new(1, 0, 0, 0), Vector2.new(1, 0), 180 },
		}
		for _, spec in ipairs(specs) do
			local edge = Util.new("Frame", {
				Name = "Vignette" .. spec[1], Active = false, BorderSizePixel = 0, Size = spec[2], Position = spec[3], AnchorPoint = spec[4],
				BackgroundColor3 = Color3.new(0, 0, 0), ZIndex = 3,
			}, Bg.top)
			Util.new("UIGradient", {
				Rotation = spec[5],
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1) }),
			}, edge)
		end
	end
	if Store.get("layerRim") then
		local glow = Util.new("Frame", {
			Name = "EdgeGlow", Active = false, BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(3, 3),
			Size = UDim2.new(1, -6, 1, -6), ZIndex = 4,
		}, Bg.top)
		Util.corner(glow, 13)
		local stroke = Util.stroke(glow, nil, 3, 0.78)
		Theme.bind(stroke, "Color", "Accent")
	end
	UI.prune()
end

-- touch / pointer parallax: the pointer's place inside the window moves the layers
function Bg.watchPointer(maid)
	local function inside(position)
		local window = Win.window
		if not window or not Win.visible then
			return nil
		end
		local at, size = window.AbsolutePosition, window.AbsoluteSize
		if size.X < 10 or size.Y < 10 then
			return nil
		end
		return (position.X - (at.X + size.X / 2)) / (size.X / 2), (position.Y - (at.Y + size.Y / 2)) / (size.Y / 2)
	end
	maid:Connect(UserInputService.InputChanged, function(input)
		if Store.get("parallax") == "off" then
			return
		end
		local kind = input.UserInputType
		if kind == Enum.UserInputType.MouseMovement or kind == Enum.UserInputType.Touch then
			local nx, ny = inside(input.Position)
			if nx and math.abs(nx) <= 1.3 and math.abs(ny) <= 1.3 then
				Bg.setParallax(nx, ny)
			elseif nx then
				Bg.setParallax(0, 0)
			end
		end
	end)
	maid:Connect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			Bg.setParallax(0, 0)
		end
	end)
end

-- what the shown style costs in Roblox, counted from the instances it made
function Bg.cost()
	if not Bg.content then
		return nil
	end
	local frames, gradients, strokes, images = 0, 0, 0, 0
	for _, item in ipairs(Bg.content:GetDescendants()) do
		if item:IsA("Frame") then
			frames = frames + 1
		elseif item:IsA("UIGradient") then
			gradients = gradients + 1
		elseif item:IsA("UIStroke") then
			strokes = strokes + 1
		elseif item:IsA("ImageLabel") or item:IsA("VideoFrame") then
			images = images + 1
		end
	end
	local n = frames + gradients + strokes + images
	local weight = (n == 0 and "Free") or (n <= 40 and "Light") or (n <= 130 and "Medium") or "Heavy"
	local bits = {}
	if frames > 0 then
		bits[#bits + 1] = frames .. " Frames"
	end
	if gradients > 0 then
		bits[#bits + 1] = gradients .. " UIGradients"
	end
	if strokes > 0 then
		bits[#bits + 1] = strokes .. " UIStrokes"
	end
	if images > 0 then
		bits[#bits + 1] = images .. " image" .. (images > 1 and "s" or "")
	end
	local text = n == 0 and "No instances." or (table.concat(bits, ", ") .. " (" .. n .. " instances). " .. weight .. ".")
	return { n = n, weight = weight, text = text }
end

----------------------------------------------------------------------------------------------------
-- media modes
----------------------------------------------------------------------------------------------------
local function fail(token, message)
	if token == Bg.token then
		Bg.clearContent()
		Bg.setStatus("error", message)
	end
end

function Bg.buildImage(token)
	local source = Store.get("bgImage")
	if source == "" then
		Bg.setStatus("idle", "No image yet - enter an asset ID, file name or link, then press Apply.")
		return
	end
	Bg.setStatus("loading", "Loading image...")
	local result = Bg.resolve(source, false)
	if token ~= Bg.token then
		return
	end
	if not result.ok then
		return fail(token, result.reason)
	end
	local image = Util.new("ImageLabel", {
		Name = "BgImage", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Crop,
		Image = result.url, ImageTransparency = 1, ZIndex = 1,
	}, Bg.content)
	Util.corner(image, 16)
	local ok, why = Bg.verifyImage(image, 9, result.isLocal)
	if token ~= Bg.token or not image.Parent then
		return
	end
	if not ok then
		return fail(token, Bg.loadFailure(result, why))
	end
	Motion.tween(image, { ImageTransparency = 0 }, 0.5)
	Bg.setStatus("ok", "Image loaded (" .. tostring(result.note) .. ").")
end

local function splitList(text)
	local items = {}
	local normalized = string.gsub(text, "[\r\n;]", ",") -- gsub returns (string, count): keep only the string
	for _, piece in ipairs(Util.split(normalized, ",")) do
		piece = Util.trim(piece)
		if piece ~= "" then
			items[#items + 1] = piece
		end
	end
	return items
end

function Bg.buildSheet(token)
	local source = Store.get("bgImage")
	if source == "" then
		Bg.setStatus("idle", "Enter the sprite-sheet image first (asset ID or file), then set columns, rows and speed.")
		return
	end
	Bg.setStatus("loading", "Loading sprite sheet...")
	local result = Bg.resolve(source, false)
	if token ~= Bg.token then
		return
	end
	if not result.ok then
		return fail(token, result.reason)
	end
	local cols, rows, fps = Store.get("bgCols"), Store.get("bgRows"), Store.get("bgFps")
	local clip = Util.new("Frame", {
		Name = "SheetClip", BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true, Size = UDim2.fromScale(1, 1), ZIndex = 1,
	}, Bg.content)
	local sheet = Util.new("ImageLabel", {
		Name = "Sheet", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(cols, rows),
		Position = UDim2.fromScale(0, 0), ScaleType = Enum.ScaleType.Stretch, Image = result.url, ZIndex = 1,
	}, clip)
	local ok = Bg.verifyImage(sheet, 9, result.isLocal)
	if token ~= Bg.token or not sheet.Parent then
		return
	end
	if not ok then
		return fail(token, "The sprite sheet could not be loaded. Check the asset ID or file name.")
	end
	local total = cols * rows
	local usable = Store.get("bgFrames")
	if usable and usable > 0 and usable < total then
		total = usable -- the last cells of the grid are empty (for example 19 frames on a 4 x 6 grid)
	end
	local last = -1
	local function show(index)
		if index == last then
			return
		end
		last = index
		local col, row = index % cols, math.floor(index / cols)
		sheet.Position = UDim2.fromScale(-col, -row)
	end
	show(0)
	if Bg.animated() and total > 1 then
		Anim.add("bg", function(_, now)
			show(math.floor(now * fps) % total)
		end, math.min(fps, 24), gate)
	end
	Bg.setStatus("ok", string.format("Sprite sheet %dx%d, %d frames at %s fps%s.", cols, rows, total, tostring(fps), Bg.animated() and "" or " (paused: reduced motion / low power)"))
end

function Bg.buildSequence(token)
	local list = splitList(Store.get("bgSequence"))
	if #list == 0 then
		Bg.setStatus("idle", "Enter 2 or more image IDs or file names separated by commas.")
		return
	end
	if #list > 24 then
		list = { table.unpack(list, 1, 24) }
	end
	Bg.setStatus("loading", "Loading frames (0/" .. #list .. ")...")
	local frames, loaded, locals = {}, 0, {}
	for i, entry in ipairs(list) do
		local result = Bg.resolve(entry, false)
		if token ~= Bg.token then
			return
		end
		if not result.ok then
			return fail(token, "Frame " .. i .. ": " .. result.reason)
		end
		locals[i] = result.isLocal
		local frame = Util.new("ImageLabel", {
			Name = "Frame" .. i, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
			ScaleType = Enum.ScaleType.Crop, Image = result.url, Visible = i == 1, ZIndex = 1,
		}, Bg.content)
		Util.corner(frame, 16)
		frames[i] = frame
	end
	for i, frame in ipairs(frames) do
		if not Bg.verifyImage(frame, 8, locals[i]) then
			return fail(token, "Frame " .. i .. " could not be loaded.")
		end
		if token ~= Bg.token then
			return
		end
		loaded = loaded + 1
		Bg.setStatus("loading", "Loading frames (" .. loaded .. "/" .. #frames .. ")...")
	end
	local fps = Store.get("bgFps")
	local current = 1
	if Bg.animated() and #frames > 1 then
		Anim.add("bg", function(_, now)
			local index = (math.floor(now * fps) % #frames) + 1
			if index ~= current then
				frames[current].Visible = false
				frames[index].Visible = true
				current = index
			end
		end, math.min(fps, 24), gate)
	end
	Bg.setStatus("ok", string.format("Image sequence: %d frames at %s fps%s.", #frames, tostring(fps), Bg.animated() and "" or " (paused: reduced motion / low power)"))
end

function Bg.buildVideo(token)
	local source = Store.get("bgVideo")
	if source == "" then
		Bg.setStatus("idle", "Enter a Roblox video asset ID or a local .webm / .mp4 file name.")
		return
	end
	local created, video = pcall(Instance.new, "VideoFrame")
	if not created then
		return fail(token, "VideoFrame is not available in this Roblox client.")
	end
	Bg.setStatus("loading", "Loading video...")
	local result = Bg.resolve(source, true)
	if token ~= Bg.token then
		video:Destroy()
		return
	end
	if not result.ok then
		video:Destroy()
		return fail(token, result.reason)
	end
	local okProps = pcall(function()
		video.Name = "BgVideo"
		video.BackgroundTransparency = 1
		video.BorderSizePixel = 0
		video.Size = UDim2.fromScale(1, 1)
		video.Looped = true
		video.Volume = 0
		video.Video = result.url
		video.ZIndex = 1
		video.Parent = Bg.content
	end)
	if not okProps then
		video:Destroy()
		return fail(token, "This client rejected the video settings.")
	end
	local started, ready = os.clock(), false
	while os.clock() - started < 12 and token == Bg.token and video.Parent do
		local okLoaded, isLoaded = pcall(function()
			return video.IsLoaded
		end)
		if okLoaded and isLoaded then
			ready = true
			break
		end
		task.wait(0.1)
	end
	if token ~= Bg.token or not video.Parent then
		return
	end
	if not ready then
		return fail(token, "The video did not load in time. It must be a Roblox-hosted video asset (or a valid local webm/mp4).")
	end
	pcall(function()
		video.Playing = Bg.animated()
	end)
	Bg.setStatus("ok", "Video playing (experimental)." .. (Bg.animated() and "" or " Paused: reduced motion / low power."))
end

----------------------------------------------------------------------------------------------------
-- apply / public setters
----------------------------------------------------------------------------------------------------
function Bg.apply()
	if not Bg.content then
		return
	end
	Bg.token = Bg.token + 1
	local token = Bg.token
	Bg.clearContent()
	Bg.mode = Store.get("bgMode")
	if Bg.mode == "solid" then
		Bg.setStatus("idle", "Solid colour background.")
	elseif Bg.mode == "aurora" then
		Bg.buildAurora()
	elseif Bg.mode == "sparkle" then
		Bg.buildSparkle()
	elseif Bg.mode == "facets" then
		Bg.buildFacets()
	elseif Bg.mode == "ribbons" then
		Bg.buildRibbons()
	elseif Bg.mode == "stars" then
		Bg.buildStars()
	elseif Bg.mode == "lattice" then
		Bg.buildLattice()
	elseif Bg.mode == "image" then
		task.spawn(Bg.buildImage, token)
	elseif Bg.mode == "sheet" then
		task.spawn(Bg.buildSheet, token)
	elseif Bg.mode == "sequence" then
		task.spawn(Bg.buildSequence, token)
	elseif Bg.mode == "video" then
		task.spawn(Bg.buildVideo, token)
	end
	Bg.updateOverlay()
	Bg.applyLayers()
end

function Bg.setMode(mode)
	if Store.set("bgMode", mode) then
		Bg.apply()
	end
end

-- Saves the text for a media mode and applies it. The new value is only kept when it really loads;
-- otherwise the previous background is restored. onResult(ok, message) reports the outcome.
function Bg.useSource(mode, text, onResult, keepFrames)
	text = Util.trim(text)
	local key = (mode == "sequence") and "bgSequence" or (mode == "video") and "bgVideo" or "bgImage"
	local previousValue, previousMode = Store.get(key), Store.get("bgMode")
	local previousFrames, previousPreset = Store.get("bgFrames"), Store.get("preset")
	if not keepFrames then
		Store.set("bgFrames", 0, true) -- a sheet you type in yourself uses every cell of its grid
		Store.set("preset", "")        -- and it is no longer one of the Customize presets
	end
	Store.set(key, text, true)
	Store.set("bgMode", mode, true)
	Bg.apply()
	local token = Bg.token
	task.spawn(function()
		local waited = 0
		while Bg.status.kind == "loading" and token == Bg.token and waited < 45 do
			task.wait(0.1)
			waited = waited + 0.1
		end
		if token ~= Bg.token then
			if onResult then
				onResult(nil, "A newer background change replaced this one.")
			end
			return
		end
		if Bg.status.kind == "ok" then
			if onResult then
				onResult(true, Bg.status.text)
			end
		else
			local message = Bg.status.text
			Store.set(key, previousValue, true)
			Store.set("bgMode", previousMode, true)
			if not keepFrames then
				Store.set("bgFrames", previousFrames, true)
				Store.set("preset", previousPreset)
			end
			Bg.apply()
			if onResult then
				onResult(false, message)
			end
		end
	end)
end

----------------------------------------------------------------------------------------------------
-- Presets (Appearance > Customize): a background from CONFIG.Presets plus the colour theme that goes with it
----------------------------------------------------------------------------------------------------
Bg.presetBusy = false

-- "motion" = an animated sprite sheet (Gif), "static" = one picture (Background), "plain" = colours only
function Bg.presetKind(p)
	if (p.Gif or "") ~= "" then
		return "motion"
	elseif (p.Background or "") ~= "" then
		return "static"
	end
	return "plain"
end

-- onResult(ok, message): ok = true (applied), false (the picture could not be loaded; the old one is back), nil (replaced by a newer change)
function Bg.applyPreset(p, onResult)
	if Bg.presetBusy then
		return false
	end
	Bg.presetBusy = true
	local kind = Bg.presetKind(p)
	local previous = {
		cols = Store.get("bgCols"), rows = Store.get("bgRows"), frames = Store.get("bgFrames"), fps = Store.get("bgFps"),
		overlay = Store.get("overlay"),
	}
	-- the colours of the preset (and a little glass, like v2) are applied when the picture is ready, so a picture that
	-- cannot be loaded changes nothing at all
	local function applyColours()
		Store.set("editColors", "", true)
		Store.set("editBase", "", true)
		local themeId = Theme.presetId(p)
		if Theme.byId[themeId] then
			Theme.apply(themeId)
		end
		Store.set("glass", math.max(Store.get("glass"), 0.3))
		Theme.setGlass(Store.get("glass"))
		Store.set("preset", p.Name)
	end

	local function finish(ok, message)
		Bg.presetBusy = false
		if ok == false then
			-- Bg.useSource already put the old source back; now the old grid and darkness come back too
			Store.set("bgCols", previous.cols)
			Store.set("bgRows", previous.rows)
			Store.set("bgFrames", previous.frames)
			Store.set("bgFps", previous.fps)
			Store.set("overlay", previous.overlay)
			Bg.apply()
		elseif ok then
			applyColours()
		end
		Pages.syncAll()
		if onResult then
			Util.try("preset result", onResult, ok, message)
		end
	end

	if kind == "plain" then
		Store.set("bgMode", "solid", true)
		Store.set("overlay", 0.3)
		Bg.apply()
		finish(true, tostring(p.Name) .. " applied.")
		return true
	end
	local mode, source
	if kind == "motion" then
		Store.set("bgCols", p.Columns or 4)
		Store.set("bgRows", p.Rows or 6)
		Store.set("bgFrames", p.Frames or 0)
		Store.set("bgFps", p.FPS or 12)
		Store.set("overlay", 0.5) -- moving pictures get a darker veil so text always reads (like v2)
		mode, source = "sheet", p.Gif
	else
		Store.set("overlay", 0.3)
		mode, source = "image", p.Background
	end
	Bg.useSource(mode, source, finish, true)
	return true
end

function Bg.syncBlur()
	local wanted = Store.get("blur") and Win.visible and not Win.minimized
	if wanted and not Bg.blur then
		local parent = Lighting or workspace.CurrentCamera
		if not parent then
			return
		end
		local ok, effect = pcall(function()
			return Util.new("BlurEffect", { Name = "VyreLoaderBlur", Size = 0 }, parent)
		end)
		if ok then
			Bg.blur = effect
		end
	end
	if Bg.blur then
		if wanted then
			Motion.tween(Bg.blur, { Size = 14 }, 0.35)
		else
			local effect = Bg.blur
			if not Store.get("blur") then
				Bg.blur = nil
			end
			Motion.tween(effect, { Size = 0 }, 0.25, nil, nil, function()
				if not Bg.blur then
					pcall(effect.Destroy, effect)
				end
			end)
		end
	end
end

-- the window changed size (compact, UI scale, rotation): the styles that are drawn in design units are drawn again
function Bg.onResize()
	if not Bg.PROCEDURAL[Bg.mode] or Bg.mode == "aurora" or Bg.mode == "sparkle" then
		return
	end
	Bg.resizeToken = (Bg.resizeToken or 0) + 1
	local token = Bg.resizeToken
	task.delay(0.35, function()
		if token == Bg.resizeToken and Bg.content and Bg.mode == Store.get("bgMode") then
			Bg.apply()
		end
	end)
end

function Bg.destroy()
	Anim.remove("bg")
	Anim.remove("bglayers")
	Bg.token = Bg.token + 1
	if Bg.blur then
		pcall(Bg.blur.Destroy, Bg.blur)
		Bg.blur = nil
	end
	Bg.layer, Bg.content, Bg.overlay, Bg.top = nil, nil, nil, nil
	Bg.listeners = {}
end
end -- [08_background.lua]

do -- [09_splash.lua]

----------------------------------------------------------------------------------------------------
-- Splash: the VYRE loading screen (the cinematic intro of Vyre hub v2, drawn with the VYRE name and logo) and the loading sound.
--
--   * The intro is a pure function of time: every effect is fx(t, o) with t = seconds since it started and o = seconds since the
--     outro started. ONE Anim job ("splash") drives it, so it can be skipped at any moment (reduced motion, a tap, failures, the
--     watchdog) by drawing its final state. Sounds and camera kicks are separate timed events (Splash.makeEvents).
--   * NOTHING here closes the screen or opens the hub by itself. The floating logo appears when the user taps the bottom bar once
--     it says so. Splash.ready only records "boot finished".
--   * HONESTY RULE (unchanged): the thin progress line in the bottom bar moves only when a real boot step finished.
--   * FAILURE POLICY: an effect that fails is switched off alone; if the animated screen cannot be built, a plain one is built; if
--     that fails too, App.boot opens the hub directly. A failing animation frame can never block the "tap" state.
--   * The camera drop and the blur are Settings options (default on). They are skipped with reduced motion and every exit
--     (tap, failure, destroy) hands the camera and the lighting back (Splash.camStop / Splash.blurOff).
--   * Everything is stored in the Splash table (no new top-level locals: Luau 200-local / 60-upvalue limits).
----------------------------------------------------------------------------------------------------
Splash.gui = nil
Splash.isOpen = false
Splash.closing = false
Splash.createdAt = 0
Splash.fraction = 0
Splash.parts = {}
Splash.handoff = nil      -- App.boot's handoff(): shows the floating logo the first time
Splash.onClosed = nil
Splash.soundState = { id = "", source = "none", note = "" }
Splash.pick = { done = true, id = "", sound = nil, tried = 0, length = 0 } -- the rbxassetid chosen in the background
Splash.FINAL = 1e6        -- "time" that draws the finished intro

local function snapshotFade(root)
	local list = {}
	local function add(obj, prop)
		list[#list + 1] = { obj = obj, prop = prop, rest = obj[prop] }
	end
	local function visit(obj)
		if obj:IsA("GuiObject") then
			add(obj, "BackgroundTransparency")
			if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
				add(obj, "TextTransparency")
			end
			if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
				add(obj, "ImageTransparency")
			end
		elseif obj:IsA("UIStroke") then
			add(obj, "Transparency")
		end
	end
	visit(root)
	for _, descendant in ipairs(root:GetDescendants()) do
		visit(descendant)
	end
	return list
end

local function fadeTo(list, hidden, duration, style)
	for _, entry in ipairs(list) do
		Motion.tween(entry.obj, { [entry.prop] = hidden and 1 or entry.rest }, duration, style or Enum.EasingStyle.Quad)
	end
end

local function setStatusText(label, text)
	if label.Text == text then
		return
	end
	label.Text = text
	if Splash.parts.drawn and not Motion.reduced then
		label.TextTransparency = 0.7
		Motion.tween(label, { TextTransparency = 0 }, 0.3)
	end
end

----------------------------------------------------------------------------------------------------
-- loading sound: the source is chosen BEFORE Sfx.init so the normal preload / status code sees it
----------------------------------------------------------------------------------------------------
function Splash.looksLikeMp3(body)
	if type(body) ~= "string" or #body < 2048 then
		return false
	end
	if string.sub(body, 1, 3) == "ID3" then
		return true
	end
	local first, second = string.byte(body, 1, 2)
	return first == 255 and second ~= nil and second >= 224
end

-- one bounded download of CONFIG.Splash.SoundUrl into `path`. Returns true when a valid file was written.
function Splash.downloadSound(url, path)
	local job = { done = false, ok = false }
	task.spawn(function()
		pcall(function()
			local result = Env.fetch(url, "request")
			if result and result.ok and Splash.looksLikeMp3(result.body) then
				local folder = string.match(path, "^(.*)/[^/]*$")
				if folder and folder ~= "" then
					Env.ensureFolder(folder)
				end
				job.ok = Env.writeFile(path, result.body) == true
			end
		end)
		job.done = true
	end)
	local limit = tonumber(CONFIG.Splash.SoundDownloadSeconds) or 6
	local started = os.clock()
	while not job.done and os.clock() - started < limit do
		task.wait(0.05)
	end
	return job.done and job.ok
end

-- 2.8.1: the intro track. CONFIG.Splash.SoundUrl is downloaded ONCE and saved as vyre_intro_<link code>.mp3 (a new link downloads a
-- new file); after that the saved copy is used. The download runs in the background while the loading screen is already up, so
-- start-up is never delayed: the music starts as soon as Roblox has loaded the file (playMusic waits for Splash.pick).
function Splash.introPath(url)
	local folder = string.match(tostring(CONFIG.Splash.SoundFile or ""), "^(.*)/[^/]*$") or (CONFIG.Folder .. "/sounds")
	return folder .. "/vyre_intro_" .. tostring(Util.hash(url)) .. ".mp3"
end

-- the rbxassetid candidates (SoundAssetId, then SoundAssetIds from a random place in the list) as full rbxassetid:// strings
function Splash.assetPool()
	local cfg = CONFIG.Splash
	local pool, seen = {}, {}
	local function add(asset)
		if type(asset) == "number" then
			asset = tostring(asset)
		end
		if type(asset) ~= "string" or asset == "" then
			return
		end
		if string.find(asset, "^%d+$") then
			asset = "rbxassetid://" .. asset
		end
		if not seen[asset] then
			seen[asset] = true
			pool[#pool + 1] = asset
		end
	end
	add(cfg.SoundAssetId)
	local list = cfg.SoundAssetIds
	if type(list) == "table" and #list > 0 then
		local first = math.random(1, #list) -- a different track can start each launch
		for step = 0, #list - 1 do
			add(list[((first - 1 + step) % #list) + 1])
		end
	end
	return pool
end

-- downloads the intro track into `path`. Returns true, or false and the reason.
function Splash.fetchIntro(url, path)
	local cfg = CONFIG.Splash
	local limit = tonumber(cfg.IntroDownloadSeconds) or 60
	local maxBytes = (tonumber(cfg.IntroMaxMB) or 25) * 1024 * 1024
	local job = { done = false }
	task.spawn(function()
		local ok, result = pcall(Env.fetch, url, "request")
		job.result = ok and result or { ok = false, error = tostring(result) }
		job.done = true
	end)
	local started = os.clock()
	while not job.done and os.clock() - started < limit and not App.destroyed do
		task.wait(0.1)
	end
	local result = job.result
	if not job.done or not result then
		return false, "the download took longer than " .. limit .. " seconds"
	end
	if not result.ok then
		return false, "the download failed (" .. Util.cap(tostring(result.error), 60) .. ")"
	end
	local body = result.body
	if type(body) ~= "string" or #body == 0 then
		return false, "the download was empty"
	end
	if #body > maxBytes then
		return false, "the file is larger than " .. math.floor(maxBytes / 1048576) .. " MB"
	end
	if not Splash.looksLikeMp3(body) then
		local head = string.lower(string.sub(body, 1, 300))
		if string.find(head, "<html", 1, true) or string.find(head, "<!doctype", 1, true) then
			return false, "the link opens a web page, not the mp3 file (a Dropbox link must end in dl=1)"
		end
		return false, "the link did not give an mp3 file"
	end
	Env.ensureFolder(CONFIG.Folder)
	local folder = string.match(path, "^(.*)/[^/]*$")
	if folder and folder ~= "" then
		Env.ensureFolder(folder)
	end
	if Env.writeFile(path, body) ~= true then
		return false, "the file could not be saved on this device"
	end
	return true
end

-- Background job (started by resolveSound; it never blocks start-up). Makes the intro track ready (the saved copy, or a download),
-- checks that Roblox can load it and leaves the Sound in Splash.pick for playMusic. If it cannot be used, the old list of audio ids
-- takes over, so the screen is not silent by accident.
function Splash.pickIntro()
	local pick, state, cfg = Splash.pick, Splash.soundState, CONFIG.Splash
	local url = cfg.SoundUrl
	local path = Splash.introPath(url)
	local function attempt(download)
		if download or not Env.fileExists(path) then
			local saved, why = Splash.fetchIntro(url, path)
			if not saved then
				return nil, why
			end
		end
		if App.destroyed then
			return nil, "the hub was closed"
		end
		local asset, whyAsset = Env.customAsset(path)
		if not asset then
			return nil, "getcustomasset failed: " .. tostring(whyAsset), true
		end
		local created, sound = pcall(Util.new, "Sound", { Name = "VirexHubMusicTest", SoundId = asset, Volume = 0 }, SoundService)
		if not (created and sound) then
			return nil, "the sound could not be created", true
		end
		if not ContentProvider then
			return sound, nil, false, 0, asset -- nothing to check it with: it is tried when the music starts
		end
		local job = { done = false, success = false }
		task.spawn(function()
			local okPreload = pcall(ContentProvider.PreloadAsync, ContentProvider, { sound }, function(_, status)
				job.success = tostring(status) == "Enum.AssetFetchStatus.Success"
			end)
			if not okPreload then
				job.success = false
			end
			job.done = true
		end)
		local started = os.clock()
		while not job.done and os.clock() - started < (tonumber(cfg.MusicCheckSeconds) or 6) do
			task.wait(0.05)
		end
		local length, loaded = 0, false
		pcall(function()
			length, loaded = sound.TimeLength, sound.IsLoaded
		end)
		if job.success and (length > 0.2 or loaded) then
			return sound, nil, false, length, asset
		end
		pcall(sound.Destroy, sound)
		return nil, "Roblox could not load the saved file", true
	end
	local sound, why, damaged, length, asset = attempt(false)
	if not sound and damaged and not App.destroyed then
		sound, why, damaged, length, asset = attempt(true) -- a damaged saved copy: downloaded once more
	end
	if sound then
		pick.sound, pick.id, pick.length, pick.done = sound, asset, length, true
		if Splash.closing or App.destroyed then
			Splash.dropPick() -- the screen was closed while this was loading; the saved copy is ready for the next start
			return
		end
		Util.log("info", string.format("intro music: ready (%s, %d s)", tostring(path), math.floor(length or 0)))
		return
	end
	state.note = tostring(why)
	Util.log("warn", "intro music: " .. tostring(why) .. " - the old list of tracks is used instead")
	if App.destroyed or Splash.closing then
		pick.done = true
		return
	end
	state.pool = Splash.assetPool()
	if #state.pool > 0 then
		Splash.pickMusic() -- sets pick.done when it is through
	else
		pick.done = true
	end
end

-- Source order: 1) local file via getcustomasset  2) CONFIG.Splash.SoundUrl, downloaded once (in the background, see Splash.pickIntro)
-- 3) the rbxassetid candidates (SoundAssetId, then SoundAssetIds from a random place in the list): they are tested
-- ONE BY ONE in a background job (Splash.pickMusic) so start-up is never delayed  4) silent. It never throws and never
-- prints an error. A file / download fills CONFIG.Sounds.loading.id so Sfx.init / Sfx.preload / Sound status treat it
-- like every other sound; the rbxassetid list leaves it empty and is played straight from Splash.pick.
function Splash.resolveSound()
	local def = CONFIG.Sounds.loading
	local cfg = CONFIG.Splash
	local state = { id = "", source = "none", note = "" }
	Splash.soundState = state
	if type(def) ~= "table" then
		return state.id, state.source
	end
	local resolved, problem = pcall(function()
		local path = cfg.SoundFile
		if type(path) == "string" and path ~= "" and Env.canCustomAsset() then
			local folder = string.match(path, "^(.*)/[^/]*$")
			if folder and folder ~= "" then
				Env.ensureFolder(folder) -- so the folder exists for the user to drop the file into
			end
			local function useFile()
				local asset, why = Env.customAsset(path)
				if asset then
					state.id, state.source = asset, "file"
				else
					state.note = "getcustomasset failed: " .. tostring(why)
				end
			end
			local data = Env.readFile(path)
			local haveFile = data ~= nil and Splash.looksLikeMp3(data)
			if haveFile then
				useFile()
			end
			if not haveFile and type(cfg.SoundUrl) == "string" and cfg.SoundUrl ~= "" and Env.canFetch() then
				state.source = "intro" -- 2.8.1: fetched in the background (Splash.pickIntro), never while start-up waits
			end
		end
	end)
	if not resolved then
		state.note = "unexpected: " .. tostring(problem)
	end
	if state.source == "intro" then
		Splash.pick = { done = false, id = "", sound = nil, tried = 0, length = 0 }
		task.spawn(Splash.pickIntro) -- background: never delays start-up
	elseif state.id == "" then
		local pool = Splash.assetPool()
		if #pool > 0 then
			state.source, state.pool = "assetlist", pool
			Splash.pick = { done = false, id = "", sound = nil, tried = 0, length = 0 }
			task.spawn(Splash.pickMusic) -- background: never delays start-up
		end
	end
	def.id = state.id
	Util.log("info", "loading sound source: " .. state.source .. (state.pool and (" (" .. #state.pool .. " candidates)") or "") .. (state.note ~= "" and (" (" .. state.note .. ")") or ""))
	return state.id, state.source
end

-- An rbxassetid Sound that was picked but never started (music off, volume 0, screen closed early) must not stay
-- behind in SoundService. A Sound that is playing lives in Sfx.holder and is removed by its handle's Stop instead.
function Splash.dropPick()
	local sound = Splash.pick.sound
	Splash.pick.sound = nil
	if sound and (not Sfx.holder or sound.Parent ~= Sfx.holder) then
		pcall(sound.Destroy, sound)
	end
end

-- Background job (started by resolveSound; it never blocks start-up). Tries the rbxassetid candidates ONE BY ONE, so in
-- the usual case only a single audio file is downloaded, and keeps the first one Roblox really loads on this device.
-- Private, deleted or blocked audio fails the preload and is skipped. Result: Splash.pick.sound / .id, or nothing.
function Splash.pickMusic()
	local pick, state, cfg = Splash.pick, Splash.soundState, CONFIG.Splash
	local pool = state.pool or {}
	local checkSeconds = tonumber(cfg.MusicCheckSeconds) or 6
	local maxTries = tonumber(cfg.MusicMaxTries) or 8
	if not ContentProvider then
		pick.done = true
		state.note = "audio preload is not available"
		return
	end
	local tried = 0
	for index, asset in ipairs(pool) do
		if tried >= maxTries or App.destroyed or Splash.closing then
			break
		end
		tried = tried + 1
		pick.tried = tried
		local created, sound = pcall(Util.new, "Sound", { Name = "VirexHubMusicTest", SoundId = asset, Volume = 0 }, SoundService)
		if created and sound then
			local job = { done = false, success = false }
			task.spawn(function()
				local okPreload = pcall(ContentProvider.PreloadAsync, ContentProvider, { sound }, function(_, status)
					job.success = tostring(status) == "Enum.AssetFetchStatus.Success"
				end)
				if not okPreload then
					job.success = false
				end
				job.done = true
			end)
			local started = os.clock()
			while not job.done and os.clock() - started < checkSeconds do
				task.wait(0.05)
			end
			local length, loaded = 0, false
			pcall(function()
				length, loaded = sound.TimeLength, sound.IsLoaded
			end)
			if job.success and (length >= 2 or loaded) then
				pick.sound, pick.id, pick.length, pick.done = sound, asset, length, true
				if Splash.closing or App.destroyed then
					Splash.dropPick() -- the screen was closed while this was loading
					return
				end
				Util.log("info", string.format("loading music: %s loaded (candidate %d of %d, %d s)", asset, index, #pool, math.floor(length)))
				return
			end
			pcall(sound.Destroy, sound)
		end
		Util.log("info", "loading music: candidate not available: " .. tostring(asset))
	end
	pick.done = true
	state.note = "none of the " .. tried .. " rbxassetid candidates that were tried could be loaded"
	Util.log("warn", "loading music: " .. state.note)
end

-- Starts the loading music (it loops while the loading screen is up unless CONFIG.Splash.MusicLoop is false).
-- Returns a handle with Stop(fadeSeconds), like Sfx.playTracked. It does not use Sfx.play / Sfx.playTracked because
-- those cut long sounds after 0.9 s unless maxSeconds is set, and a clone is destroyed after ~2 s when the sound's
-- length is still unknown (not preloaded yet).
function Splash.playMusic()
	local handle = { clone = nil, stopped = false }
	function handle.Stop(fadeSeconds)
		handle.stopped = true
		local clone = handle.clone
		handle.clone = nil
		if clone and clone.Parent then
			local fade = fadeSeconds or 0.45
			Motion.tween(clone, { Volume = 0 }, fade, Enum.EasingStyle.Quad)
			task.delay(fade + 0.05, function()
				pcall(clone.Destroy, clone)
			end)
		end
	end
	local def = CONFIG.Sounds.loading
	if type(def) ~= "table" or not Sfx.holder then
		return handle
	end
	if not (Store.get("splashSound") and Store.get("sound")) then
		return handle
	end
	local master = Store.get("volume")
	if master <= 0.001 then
		return handle
	end
	local volume = Util.clamp((def.volume or 0.45) * master * 1.5, 0, 1)
	local loop = CONFIG.Splash.MusicLoop ~= false

	-- starts a Sound that is not playing yet and hands it to the handle
	local function start(sound, fadeIn)
		local ok, problem = pcall(function()
			sound.Volume = fadeIn and 0 or volume
			sound.PlaybackSpeed = def.speed or 1
			sound.Looped = loop
			sound.Parent = Sfx.holder
			sound:Play()
		end)
		if not ok then
			Util.log("warn", "loading sound could not start: " .. tostring(problem))
			pcall(sound.Destroy, sound)
			return
		end
		if fadeIn then
			Motion.tween(sound, { Volume = volume }, 0.9, Enum.EasingStyle.Quad)
		end
		handle.clone = sound
		Sfx.tracked[#Sfx.tracked + 1] = sound
		if not loop then
			pcall(function()
				sound.Ended:Connect(function()
					pcall(sound.Destroy, sound)
				end)
			end)
		end
		task.delay(loop and 1800 or 90, function() -- safety net only; the screen closing normally stops it long before
			pcall(sound.Destroy, sound)
		end)
	end

	-- the rbxassetid list: the track is chosen in the background (Splash.pickMusic); wait for it if it is not ready yet
	if Splash.soundState.source == "assetlist" or Splash.soundState.source == "intro" then
		local pick = Splash.pick
		task.spawn(function()
			local waited = 0
			while not pick.done and waited < 25 and not handle.stopped and not Splash.closing do
				task.wait(0.1)
				waited = waited + 0.1
			end
			if handle.stopped or Splash.closing or not Splash.isOpen or not Sfx.holder or not pick.sound then
				return
			end
			start(pick.sound, true)
		end)
		return handle
	end

	-- a local file / download: played through its preloaded Sfx record
	if type(def.id) ~= "string" or def.id == "" then
		return handle
	end
	local record = Sfx.records[def.id]
	if not record or record.status == "failed" then
		return handle
	end
	local ok, copy = pcall(function()
		return record.sound:Clone()
	end)
	if not ok or not copy then
		Util.log("warn", "loading sound could not start: " .. tostring(copy))
		return handle
	end
	start(copy, false)
	return handle
end

-- Called by the intro at the first letter drop (or at once with reduced motion). Plays at most once.
function Splash.startMusic()
	local parts = Splash.parts
	if parts.musicStarted or parts.failed or Splash.closing or not Splash.isOpen then
		return
	end
	parts.musicStarted = true
	local ok, handle = pcall(Splash.playMusic)
	if ok then
		parts.music = handle
	else
		Util.log("warn", "loading sound: " .. tostring(handle))
	end
end

----------------------------------------------------------------------------------------------------
-- small helpers
----------------------------------------------------------------------------------------------------
function Splash.font(name, fallback)
	local ok, value = pcall(function()
		return Enum.Font[name]
	end)
	if ok and value then
		return value
	end
	return fallback
end

-- splits a string into UTF-8 characters
function Splash.chars(text)
	local list = {}
	for ch in string.gmatch(tostring(text or ""), utf8.charpattern) do
		list[#list + 1] = ch
	end
	return list
end

local WHITE, BLACK = Color3.new(1, 1, 1), Color3.new(0, 0, 0)
local E = Motion.ease

-- 0..1 progress of the stretch [t0, t0 + dur] of the timeline at time t
local function seg(t, t0, dur)
	return Util.clamp((t - t0) / dur, 0, 1)
end

local function mixn(a, b, e)
	return a + (b - a) * e
end

local function frame(parent, props)
	if props.BorderSizePixel == nil then
		props.BorderSizePixel = 0
	end
	return Util.new("Frame", props, parent)
end

local function grad(parent, props)
	return Util.new("UIGradient", props, parent)
end

local function ns(list)
	local keys = {}
	for i, p in ipairs(list) do
		keys[i] = NumberSequenceKeypoint.new(p[1], p[2])
	end
	return NumberSequence.new(keys)
end

local function cs(colors)
	local keys = {}
	for i, c in ipairs(colors) do
		keys[i] = ColorSequenceKeypoint.new((i - 1) / (#colors - 1), c)
	end
	return ColorSequence.new(keys)
end

local function atan2(y, x)
	if x > 0 then
		return math.atan(y / x)
	elseif x < 0 then
		return math.atan(y / x) + (y >= 0 and math.pi or -math.pi)
	elseif y > 0 then
		return math.pi / 2
	elseif y < 0 then
		return -math.pi / 2
	end
	return 0
end

-- the colours of the intro. Default = chrome / silver on black: the Noir look of Vyre hub v2 and the black-and-white VYRE of the
-- 2.4.0 loading screen. CONFIG.Splash.UseTheme = true takes the accent colours of the theme in use instead.
function Splash.palette()
	local p = { accent = Color3.fromRGB(235, 236, 240), accent2 = WHITE, hot = Color3.fromRGB(120, 122, 130) }
	if CONFIG.Splash.UseTheme then
		local live = Theme.live
		p.accent = live.Accent or p.accent
		p.accent2 = live.Accent2 or live.Accent or p.accent2
		p.hot = live.Info or live.Accent or p.hot
	end
	return p
end

-- width and height of one line of text (TextService can be missing or fail in an executor: then a rough guess for wide capitals)
function Splash.measure(text, size, font)
	local ok, bounds = pcall(function()
		return TextService:GetTextSize(text, size, font, Vector2.new(10000, 10000))
	end)
	if ok and bounds and bounds.X > 0 then
		return bounds.X, bounds.Y
	end
	return math.max(1, #text) * size * 0.62, size * 1.2
end

-- when everything happens (seconds after the intro started). Taken from the intro of Vyre hub v2.
function Splash.plan()
	local cfg = CONFIG.Splash
	local gap = tonumber(cfg.DropStagger) or 0.13
	local speed = tonumber(cfg.TypeSpeed) or 0.03
	local letters = math.max(#Splash.chars(cfg.Brand), 1)
	local tl = {
		bars = 1.0,      -- the letterbox bars slide in
		lids = 0.4,      -- the screen splits open along the line of light
		implode = 0.8,   -- streaks of light are sucked into the middle
		orb = 0.4,       -- the orb opens like a portal
		ghosts = 0.6,    -- four ghost copies of the logo rush in
		impact = 1.35,   -- the logo lands
		lettersAt = tonumber(cfg.LettersAt) or 2.1,
		gap = gap, speed = speed, letters = letters,
	}
	tl.lastLetter = tl.lettersAt + (letters - 1) * gap
	tl.shock = tl.lastLetter + gap + 0.25 -- the wave after the last letter; the underline grows with it
	tl.typeStart = tl.shock + 0.35
	tl.typeEnd = tl.typeStart + #Splash.chars(cfg.TypeText) * speed
	tl.done = tl.typeEnd + 1.0             -- the pop, the sweeps and the fade-in of the small text are finished
	return tl
end

----------------------------------------------------------------------------------------------------
-- building blocks
----------------------------------------------------------------------------------------------------
-- Epic text: a chrome face with a dark solid extrusion behind it, a crisp black edge and a light that sweeps down the face.
-- Every piece sits in a CanvasGroup so the whole word can fade (GroupTransparency).
function Splash.epicText(parent, text, size, z, font)
	local width, height = Splash.measure(text, size, font)
	local depth = math.max(2, math.floor(size * 0.06))
	local padX, padY = math.floor(size * 0.12) + depth, math.floor(size * 0.1) + depth
	local group = Util.new("CanvasGroup", {
		Name = "Epic", BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.fromOffset(width + padX * 2, height + padY * 2), ZIndex = z,
	}, parent)
	local labels = {}
	local function layer(zz, d, color)
		local label = Util.new("TextLabel", {
			BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(padX + d, padY + d),
			Size = UDim2.fromOffset(width, height), Font = font, Text = text, TextSize = size, TextColor3 = color, ZIndex = zz,
		}, group)
		labels[#labels + 1] = label
		return label
	end
	local function edge(label)
		local stroke = Util.new("UIStroke", { Color = BLACK, Thickness = math.max(1.5, size * 0.035) }, label)
		pcall(function()
			stroke.LineJoinMode = Enum.LineJoinMode.Round
		end)
	end
	-- solid extrusion: stacked dark copies give the letters real-looking depth
	for d = depth, 1, -1 do
		local shade = math.floor(14 + (depth - d) / depth * 46)
		edge(layer(z, d, Color3.fromRGB(shade, shade, shade + 3)))
	end
	-- face: white-to-silver chrome with a crisp black edge
	local main = layer(z + 1, 0, WHITE)
	local fill = grad(main, {
		Rotation = 90, Color = cs({ WHITE, Color3.fromRGB(236, 237, 241), Color3.fromRGB(168, 170, 178), Color3.fromRGB(246, 246, 249) }),
	})
	edge(main)
	local scale = Util.new("UIScale", {}, group)
	return {
		group = group, labels = labels, main = main, fill = fill, scale = scale, padX = padX, padY = padY,
		width = width + padX * 2, height = height + padY * 2,
	}
end

-- the light sweep: the chrome highlight slides down the face. u = 0..1 (nil = rest)
function Splash.sweep(item, u)
	if u == nil or u <= 0 or u >= 1 then
		item.fill.Offset = Vector2.new(0, 0)
	else
		item.fill.Offset = Vector2.new(0, -0.8 * (1 - E.outQuint(u)))
	end
end

-- the VYRE logo, as many times as needed: the built-in vector V (UI.icon "logo", the same mark as the floating logo and the hub)
-- or CONFIG.Splash.LogoImage when that picture really loaded. The pieces are painted by hand (silver), not by the theme, so the
-- loading screen keeps its own chrome look whatever theme is on. Returns { root, pieces, set(color) }.
function Splash.makeLogo(parent, size, z, color)
	local icon = UI.icon("logo", parent, size, "Text", { anchor = Vector2.new(0.5, 0.5), position = UDim2.fromScale(0.5, 0.5), zindex = z })
	local pieces = {}
	for _, piece in ipairs(icon.Instance:GetChildren()) do
		if piece:IsA("Frame") then
			pcall(Theme.unbind, piece, "BackgroundColor3")
			piece.BackgroundColor3 = color
			-- where the piece sits across the mark (-1 .. 1), so a band of light can cross it
			local x = (piece.Position.X.Offset / size - 0.5) * 2
			local y = (piece.Position.Y.Offset / size - 0.5) * 2
			pieces[#pieces + 1] = { frame = piece, x = x, y = y }
		end
	end
	local logo = { root = icon.Instance, pieces = pieces, base = color, lit = false }
	function logo.paint(band)
		-- band = nil: plain silver. Otherwise a number: where the band of light is (about -1.4 .. 1.4)
		if band == nil then
			if not logo.lit then
				return
			end
			logo.lit = false
		else
			logo.lit = true
		end
		for _, piece in ipairs(logo.pieces) do
			local k = 0
			if band then
				k = Util.clamp(1 - math.abs((piece.x + piece.y * 0.45) - band) / 0.55, 0, 1)
			end
			piece.frame.BackgroundColor3 = logo.base:Lerp(WHITE, k)
		end
	end
	return logo
end

----------------------------------------------------------------------------------------------------
-- the cinematic. Every effect is a function of time: fx(t, o) with t = seconds since the intro started and o = seconds since
-- the outro started (nil before). That is what lets the whole intro be skipped by drawing its final state.
----------------------------------------------------------------------------------------------------
-- dim backdrop, colour wash and the letterbox bars
function Splash.fxFrame(parts)
	local P, vp = parts.pal, parts.vp
	local intro, stage = parts.intro, parts.stage
	local wash = frame(stage, { Name = "Wash", Size = UDim2.fromScale(1, 1), BackgroundColor3 = P.accent, BackgroundTransparency = 1, ZIndex = 100 })
	grad(wash, { Rotation = 90, Transparency = ns({ { 0, 0.5 }, { 0.5, 1 }, { 1, 0.4 } }) })
	local barH = math.max(44, math.floor(vp.Y * 0.11))
	parts.barH = barH
	local function bar(top)
		local b = frame(intro, {
			Name = top and "BarTop" or "BarBottom", AnchorPoint = Vector2.new(0, top and 0 or 1),
			Position = top and UDim2.fromOffset(0, -barH) or UDim2.new(0, 0, 1, barH), Size = UDim2.new(1, 0, 0, barH),
			BackgroundColor3 = BLACK, ZIndex = 125,
		})
		local edge = frame(b, {
			Name = "Edge", AnchorPoint = Vector2.new(0, top and 1 or 0), Position = top and UDim2.fromScale(0, 1) or UDim2.fromScale(0, 0),
			Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = P.accent2, ZIndex = 126,
		})
		grad(edge, { Transparency = ns({ { 0, 1 }, { 0.5, 0 }, { 1, 1 } }) })
		return b
	end
	local top, bottom = bar(true), bar(false)
	parts.barTop, parts.barBottom = top, bottom
	local rest = parts.dimRest
	return function(t, o)
		local fadeOut = o and (1 - E.outQuint(seg(o, 0.55, 0.7))) or 1
		intro.BackgroundTransparency = 1 - (1 - rest) * E.outQuint(seg(t, 0, 0.9)) * fadeOut
		wash.BackgroundTransparency = 1 - 0.5 * E.outQuint(seg(t, 0, 1.4)) * fadeOut
		local slide = 1 - E.outExpo(seg(t, 0, parts.tl.bars))
		if o then
			slide = E.inExpo(seg(o, 0, 0.7))
		end
		top.Position = UDim2.fromOffset(0, -barH * slide)
		bottom.Position = UDim2.new(0, 0, 1, barH * slide)
	end
end

-- opening: a line of light draws across the middle, then the screen splits open along it
function Splash.fxLids(parts)
	local vp, intro = parts.vp, parts.intro
	local lidTop = frame(intro, { Name = "LidTop", AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromScale(1, 0.5), BackgroundColor3 = BLACK, ZIndex = 120 })
	local lidBottom = frame(intro, { Name = "LidBottom", Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromScale(1, 0.5), BackgroundColor3 = BLACK, ZIndex = 120 })
	local seam = frame(intro, {
		Name = "Seam", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(0, 2),
		BackgroundColor3 = WHITE, ZIndex = 122,
	})
	grad(seam, { Transparency = ns({ { 0, 1 }, { 0.2, 0.4 }, { 0.5, 0 }, { 0.8, 0.4 }, { 1, 1 } }) })
	local glow = frame(intro, {
		Name = "SeamGlow", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(0, 24),
		BackgroundColor3 = WHITE, BackgroundTransparency = 0.8, ZIndex = 121,
	})
	Util.round_corner(glow)
	grad(glow, { Transparency = ns({ { 0, 1 }, { 0.5, 0.2 }, { 1, 1 } }) })
	local at = parts.tl.lids
	return function(t)
		local alive = t < at + 1.0
		lidTop.Visible, lidBottom.Visible, seam.Visible, glow.Visible = alive, alive, alive, alive
		if not alive then
			return
		end
		local open = E.inOutQuint(seg(t, at, 0.95))
		lidTop.Position = UDim2.fromScale(0, 0.5 - 0.5 * open)
		lidBottom.Position = UDim2.fromScale(0, 0.5 + 0.5 * open)
		-- the line draws out, then (a little after the lids start to move) fades while it widens
		local grow = E.outExpo(seg(t, 0, 0.45))
		local fade = E.outQuint(seg(t, at + 0.15, 0.5))
		seam.Size = UDim2.fromOffset(mixn(vp.X * grow, vp.X * 1.3, fade), mixn(2, 1, fade))
		seam.BackgroundTransparency = fade
		local glowGrow = E.outExpo(seg(t, 0, 0.6))
		local glowFade = E.outQuint(seg(t, at, 0.6))
		glow.Size = UDim2.fromOffset(mixn(vp.X * 0.8 * glowGrow, vp.X * 1.3, glowFade), mixn(24, 120, glowFade))
		glow.BackgroundTransparency = mixn(0.8, 1, glowFade)
	end
end

-- soft white puffs rush past the camera while it falls through the clouds
function Splash.fxClouds(parts)
	local vp, stage = parts.vp, parts.stage
	local list = {}
	for k = 1, 9 do
		local a = math.random() * math.pi * 2
		local size = math.random(260, 520)
		local cloud = frame(stage, {
			Name = "Cloud", AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(size, size * 0.6), BackgroundColor3 = WHITE,
			BackgroundTransparency = 1, ZIndex = 118, Visible = false,
		})
		Util.round_corner(cloud)
		grad(cloud, { Transparency = ns({ { 0, 1 }, { 0.3, 0.5 }, { 0.5, 0.2 }, { 0.7, 0.5 }, { 1, 1 } }) })
		local scale = Util.new("UIScale", { Scale = 0.5 }, cloud)
		list[k] = { cloud = cloud, scale = scale, a = a, t0 = 0.35 + k * 0.17 }
	end
	return function(t)
		for _, item in ipairs(list) do
			local u = seg(t, item.t0, 1.1)
			local on = u > 0 and u < 1
			item.cloud.Visible = on
			if on then
				local e = E.inQuad(u)
				item.cloud.Position = UDim2.new(0.5, math.cos(item.a) * mixn(60, vp.X * 0.9, e), 0.45, math.sin(item.a) * mixn(40, vp.Y * 0.9, e))
				item.cloud.BackgroundTransparency = mixn(0.35, 1, e)
				item.scale.Scale = mixn(0.5, 3, e)
			end
		end
	end
end

-- streaks of light are sucked into the middle right before the logo lands
function Splash.fxImplosion(parts)
	local vp, stage, P = parts.vp, parts.stage, parts.pal
	local cx, cy = vp.X / 2, vp.Y * 0.37
	local R = math.max(vp.X, vp.Y) * 0.75
	local list = {}
	for k = 1, 30 do
		local a = math.random() * math.pi * 2
		local ring = R * (0.7 + math.random() * 0.4)
		local line = frame(stage, {
			Name = "Pull", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = (k % 4 == 0) and P.accent2 or WHITE,
			BackgroundTransparency = 1, Rotation = math.deg(a), ZIndex = 105, Visible = false,
		})
		grad(line, { Transparency = ns({ { 0, 0 }, { 1, 1 } }) })
		list[k] = {
			line = line, sx = cx + math.cos(a) * ring, sy = cy + math.sin(a) * ring, len = math.random(40, 110), thick = math.random(1, 3),
			t0 = parts.tl.implode + k * 0.004, dur = 0.45 + math.random() * 0.12,
		}
	end
	return function(t)
		for _, item in ipairs(list) do
			local u = seg(t, item.t0, item.dur)
			local on = u > 0 and u < 1
			item.line.Visible = on
			if on then
				local e = E.inQuad(u)
				item.line.Position = UDim2.fromOffset(mixn(item.sx, cx, e), mixn(item.sy, cy, e))
				item.line.Size = UDim2.fromOffset(mixn(item.len, 8, e), mixn(item.thick, 1, e))
				item.line.BackgroundTransparency = mixn(0.15, 0.6, e)
			end
		end
	end
end

-- the animated orb, opening like a portal behind the logo. A dark disc sits under the sprite sheet, so a sheet that cannot
-- be loaded still leaves a clean black orb.
function Splash.fxOrb(parts)
	local cfg = CONFIG.Splash.Orb or {}
	local stage, P = parts.stage, parts.pal
	local size = math.floor(380 * parts.fit)
	local orb = Util.new("CanvasGroup", {
		Name = "Orb", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.37), Size = UDim2.fromOffset(size, size),
		BackgroundTransparency = 1, BorderSizePixel = 0, GroupTransparency = 1, ZIndex = 102,
	}, stage)
	Util.round_corner(orb)
	local disc = frame(orb, { Name = "Disc", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(6, 6, 8), ZIndex = 102 })
	grad(disc, { Rotation = 40, Color = ColorSequence.new(Color3.fromRGB(30, 30, 36), Color3.fromRGB(3, 3, 4)) })
	local sprite = nil
	local columns, rows = tonumber(cfg.Columns) or 1, tonumber(cfg.Rows) or 1
	local frames = math.max(1, tonumber(cfg.Frames) or columns * rows)
	local cell = (tonumber(cfg.Size) or 1024) / math.max(columns, 1)
	if type(cfg.Image) == "string" and cfg.Image ~= "" then
		sprite = Util.new("ImageLabel", {
			Name = "Sprite", BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromScale(-0.06, -0.06), Size = UDim2.fromScale(1.12, 1.12),
			Image = cfg.Image, ImageRectSize = Vector2.new(cell, cell), ImageRectOffset = Vector2.new(0, 0), ZIndex = 103,
		}, orb)
	end
	local scale = Util.new("UIScale", { Scale = 0.2 }, orb)
	local rim = Util.new("UIStroke", { Color = WHITE, Thickness = 3, Transparency = 0.2 }, orb)
	local rimGradient = grad(rim, {
		Color = cs({ P.accent2, P.accent, P.hot, P.accent2 }), Transparency = ns({ { 0, 0 }, { 0.5, 0.8 }, { 1, 0 } }),
	})
	parts.orb = { group = orb, sprite = sprite, rim = rimGradient, columns = columns, frames = frames, cell = cell, fps = tonumber(cfg.FPS) or 12 }
	local at = parts.tl.orb
	return function(t, o)
		local fadeOut = o and E.outQuint(seg(o, 0, 0.7)) or 0
		orb.GroupTransparency = mixn(1 - 0.92 * E.outQuint(seg(t, at, 1.2)), 1, fadeOut)
		local grow = mixn(0.2, 1, E.outExpo(seg(t, at, 1.6)))
		if o then
			grow = mixn(1, 2.6, E.inQuint(seg(o, 0, 0.8)))
		end
		scale.Scale = grow
	end
end

-- the logo: a spinning ring of light, a dark disc, the V (or the picture) and a band of light that crosses it. It lands with a bang
-- (a elastic pop), four ghost copies rush in from the corners and fuse into it, two more snap together from the sides.
function Splash.fxLogo(parts)
	local stage, P, fit = parts.stage, parts.pal, parts.fit
	local L = math.floor(210 * fit)
	local silver = Color3.fromRGB(214, 217, 226)
	local rig = frame(stage, { Name = "LogoRig", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.37), Size = UDim2.fromOffset(L, L), BackgroundTransparency = 1, ZIndex = 104 })
	local rigScale = Util.new("UIScale", { Scale = 0 }, rig)
	-- spinning ring of light
	local ring = frame(rig, { Name = "Ring", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.52), Size = UDim2.fromScale(1.22, 1.22), BackgroundTransparency = 1, ZIndex = 104 })
	Util.round_corner(ring)
	local ringStroke = Util.new("UIStroke", { Color = WHITE, Thickness = math.max(1, L / 70) }, ring)
	local ringGradient = grad(ringStroke, { Color = cs({ WHITE, Color3.fromRGB(110, 112, 120), WHITE, Color3.fromRGB(46, 48, 54), WHITE }) })
	parts.ringStroke = ringStroke
	-- dark disc behind the mark, so it reads on any picture of the orb
	local disc = frame(rig, { Name = "Disc", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.86, 0.86), BackgroundColor3 = Color3.fromRGB(6, 6, 8), ZIndex = 104 })
	Util.round_corner(disc)
	grad(disc, { Rotation = 40, Color = ColorSequence.new(Color3.fromRGB(28, 28, 34), Color3.fromRGB(3, 3, 4)) })
	local size = math.floor(L * 0.68)
	local logo = Splash.makeLogo(rig, size, 105, silver)
	parts.logo = logo
	parts.logoImage = nil
	-- the optional picture (CONFIG.Splash.LogoImage) is loaded in the background and replaces the V only when it really loads
	local pic = Util.new("ImageLabel", {
		Name = "LogoImage", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.86, 0.86),
		BackgroundTransparency = 1, BorderSizePixel = 0, Image = "", ScaleType = Enum.ScaleType.Fit, ZIndex = 106, Visible = false,
	}, rig)
	parts.pic = pic
	local shine = Util.new("ImageLabel", {
		Name = "Shine", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Image = "", ImageColor3 = WHITE,
		ScaleType = Enum.ScaleType.Fit, ZIndex = 107,
	}, pic)
	local shineGradient = grad(shine, {
		Rotation = 25, Offset = Vector2.new(-1, 0), Transparency = ns({ { 0, 1 }, { 0.4, 1 }, { 0.5, 0.1 }, { 0.6, 1 }, { 1, 1 } }),
	})
	parts.rig = { frame = rig, scale = rigScale, ringGradient = ringGradient, shineGradient = shineGradient, size = size, L = L }

	-- ghosts: copies of the mark that rush in from the corners (and two that snap together from the sides)
	local ghosts = {}
	local function ghost(color)
		local holder = Util.new("CanvasGroup", {
			Name = "Ghost", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromOffset(L, L),
			GroupTransparency = 1, ZIndex = 103, Visible = false,
		}, stage)
		local copy = Splash.makeLogo(holder, size, 103, color)
		copy.paint(nil)
		local scale = Util.new("UIScale", { Scale = 1 }, holder)
		return { holder = holder, scale = scale }
	end
	local corners = { { -0.45, -0.4 }, { 0.45, -0.4 }, { -0.45, 0.4 }, { 0.45, 0.4 } }
	for k, c in ipairs(corners) do
		local g = ghost((k % 2 == 0) and P.accent2 or P.hot)
		g.cx, g.cy, g.kind = c[1], c[2], "corner"
		ghosts[#ghosts + 1] = g
	end
	for _, side in ipairs({ -1, 1 }) do
		local g = ghost(side < 0 and WHITE or Color3.fromRGB(140, 142, 150))
		g.side, g.kind = side, "side"
		ghosts[#ghosts + 1] = g
	end

	local tl = parts.tl
	local discBase = disc.BackgroundTransparency
	return function(t, o)
		-- the pop (elastic), then the outro: it rushes at the camera and fades
		local pop = E.outElastic(seg(t, tl.impact, 1))
		local scaleNow = pop
		local gone = 1
		if o then
			scaleNow = mixn(1, 5, E.inQuint(seg(o, 0, 0.7)))
			gone = 1 - E.inQuint(seg(o, 0, 0.6))
			disc.BackgroundTransparency = 1 - gone
			ringStroke.Transparency = 1 - gone
			pic.ImageTransparency = 1 - gone
		else
			disc.BackgroundTransparency = discBase
			ringStroke.Transparency = 0
		end
		-- the V is drawn by hand; a real picture (CONFIG.Splash.LogoImage that loaded) takes its place
		local shown = gone > 0.02
		logo.root.Visible = shown and not parts.logoImage
		pic.Visible = shown and parts.logoImage == true
		-- the band of light that crosses the mark just after the landing
		local band, sheen = nil, -1
		if not o then
			local u = seg(t, tl.impact + 0.6, 0.9)
			if u > 0 and u < 1 then
				band = mixn(-1.5, 1.5, E.inOutSine(u))
				sheen = mixn(-1, 1, E.inOutSine(u))
			end
		end
		logo.paint(band)
		shineGradient.Offset = Vector2.new(sheen, 0)
		rigScale.Scale = math.max(scaleNow, 0.001)
		rig.Visible = scaleNow > 0.001
		for _, g in ipairs(ghosts) do
			if g.kind == "corner" then
				local u = seg(t, tl.ghosts, 0.75)
				local e = E.inQuint(u)
				local on = t >= tl.ghosts and t < tl.ghosts + 1.1
				g.holder.Visible = on
				if on then
					g.holder.Position = UDim2.fromScale(mixn(0.5 + g.cx, 0.5, e), mixn(0.37 + g.cy, 0.37, e))
					g.holder.Rotation = g.cx * 80 * (1 - e)
					g.scale.Scale = mixn(1.4, 1, e)
					local appear = E.outQuint(seg(t, tl.ghosts, 0.25))
					local vanish = seg(t, tl.ghosts + 0.75, 0.3)
					g.holder.GroupTransparency = mixn(1 - 0.65 * appear, 1, vanish)
				end
			else
				local u = seg(t, tl.impact, 0.45)
				local on = t >= tl.impact and t < tl.impact + 0.5
				g.holder.Visible = on
				if on then
					local e = E.outQuint(u)
					g.holder.Position = UDim2.new(mixn(0.5, 0.5, e), mixn(g.side * 26, 0, e), 0.37, 0)
					g.holder.GroupTransparency = mixn(0.3, 1, e)
				end
			end
		end
	end
end

-- god rays turning slowly behind the logo; the flare that opens when the logo lands, the blades of light and the sparks
function Splash.fxLight(parts)
	local vp, stage, P = parts.vp, parts.stage, parts.pal
	local tl = parts.tl
	local rays = frame(stage, { Name = "Rays", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.37), Size = UDim2.fromOffset(10, 10), BackgroundTransparency = 1, ZIndex = 101 })
	local rayList = {}
	for i = 1, 8 do
		local len = math.floor(math.max(vp.X, vp.Y) * (i % 2 == 0 and 1.1 or 0.8))
		local ray = frame(rays, {
			Name = "Ray", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(i % 2 == 0 and 10 or 4, len),
			Rotation = i * 22.5, BackgroundColor3 = (i % 3 == 0) and P.hot or P.accent2, BackgroundTransparency = 1, ZIndex = 101,
		})
		grad(ray, { Rotation = 90, Transparency = ns({ { 0, 1 }, { 0.42, 0.55 }, { 0.5, 0.85 }, { 0.58, 0.55 }, { 1, 1 } }) })
		rayList[i] = ray
	end
	parts.rays = rays

	-- flare: a bright line and its haze open across the screen when the logo lands
	local core = frame(stage, { Name = "FlareCore", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.37), Size = UDim2.fromOffset(0, 3), BackgroundColor3 = WHITE, ZIndex = 110, Visible = false })
	grad(core, { Color = cs({ P.accent, P.accent2, WHITE, P.accent2, P.accent }), Transparency = ns({ { 0, 1 }, { 0.5, 0 }, { 1, 1 } }) })
	local haze = frame(stage, { Name = "FlareHaze", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.37), Size = UDim2.fromOffset(0, 26), BackgroundColor3 = P.accent2, BackgroundTransparency = 0.6, ZIndex = 109, Visible = false })
	Util.round_corner(haze)
	grad(haze, { Transparency = ns({ { 0, 1 }, { 0.5, 0.2 }, { 1, 1 } }) })

	-- blades of light: three when the logo lands, one after the last letter
	local blades = {}
	local function blade(at, color, cy, maxSize, inOutro)
		local w = math.max(vp.X * 1.4, maxSize or 0)
		local line = frame(stage, { Name = "Blade", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, cy), Size = UDim2.fromOffset(40, 2), BackgroundColor3 = color, ZIndex = 108, Visible = false })
		grad(line, { Transparency = ns({ { 0, 1 }, { 0.5, 0 }, { 1, 1 } }) })
		local mist = frame(stage, { Name = "BladeHaze", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, cy), Size = UDim2.fromOffset(40, 60), BackgroundColor3 = color, BackgroundTransparency = 0.75, ZIndex = 103, Visible = false })
		Util.round_corner(mist)
		grad(mist, { Transparency = ns({ { 0, 1 }, { 0.5, 0.3 }, { 1, 1 } }) })
		blades[#blades + 1] = { line = line, mist = mist, at = at, w = w, outro = inOutro == true }
	end
	blade(tl.impact, WHITE, 0.37)
	blade(tl.impact + 0.1, P.hot, 0.37)
	blade(tl.impact + 0.2, P.accent2, 0.37)
	blade(tl.shock, P.accent2, 0.65, 800)
	blade(0.55, WHITE, 0.5, 1800, true) -- the white blade that cuts across the screen in the outro (time = seconds since the outro began)

	-- two flashes of white (the landing, and the outro) and the sparks that burst from the logo
	local flash = frame(parts.intro, { Name = "Flash", Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BackgroundTransparency = 1, ZIndex = 124, Visible = false })
	local sparks = {}
	for i = 1, 24 do
		local a = (i / 24) * math.pi * 2 + math.random() * 0.4
		local spark = frame(stage, { Name = "Spark", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = P.accent2, ZIndex = 108, Visible = false })
		Util.round_corner(spark)
		sparks[i] = { frame = spark, a = a, d = math.random(18, 34) * parts.fit + 6, s = math.random(3, 5) }
	end
	local cx, cy = vp.X / 2, vp.Y * 0.37
	return function(t, o)
		-- rays fade in with the landing, one after another, and go in the outro
		for k, ray in ipairs(rayList) do
			local e = 1 - 0.75 * E.outQuint(seg(t, tl.impact + k * 0.04, 1.2))
			if o then
				e = mixn(e, 1, seg(o, 0, 0.5))
			end
			ray.BackgroundTransparency = e
		end
		-- flare
		local fOn = t >= tl.impact and t < tl.impact + 1.3
		core.Visible, haze.Visible = fOn, fOn
		if fOn then
			local open = E.outExpo(seg(t, tl.impact, 0.35))
			local fade = E.outQuint(seg(t, tl.impact + 0.35, 0.9))
			core.Size = UDim2.fromOffset(mixn(vp.X * 1.3 * open, vp.X * 1.5, fade), mixn(3, 1, fade))
			core.BackgroundTransparency = fade
			haze.Size = UDim2.fromOffset(vp.X * 0.9 * E.outExpo(seg(t, tl.impact, 0.45)), 26)
			haze.BackgroundTransparency = mixn(0.6, 1, fade)
		end
		-- blades
		for _, b in ipairs(blades) do
			local clock = t
			if b.outro then
				clock = o or -1
			end
			local on = clock >= b.at and clock < b.at + 1.0 and not (o and not b.outro)
			b.line.Visible, b.mist.Visible = on, on
			if on then
				b.line.Size = UDim2.fromOffset(mixn(40, b.w, E.outExpo(seg(clock, b.at, 0.5))), 2)
				b.mist.Size = UDim2.fromOffset(mixn(40, b.w * 0.8, E.outExpo(seg(clock, b.at, 0.6))), mixn(60, 6, E.outExpo(seg(clock, b.at, 0.6))))
				b.line.BackgroundTransparency = E.outQuint(seg(clock, b.at + 0.3, 0.6))
				b.mist.BackgroundTransparency = mixn(0.75, 1, E.outQuint(seg(clock, b.at + 0.3, 0.5)))
			end
		end
		-- flashes: the landing (35 % white), the outro (15 %)
		local alpha = 1
		if t >= tl.impact and t < tl.impact + 0.65 then
			alpha = mixn(0.35, 1, E.outQuint(seg(t, tl.impact, 0.6)))
		end
		if o and o >= 0.55 and o < 1.2 then
			alpha = math.min(alpha, mixn(0.15, 1, E.outQuint(seg(o, 0.55, 0.6))))
		end
		flash.Visible = alpha < 0.999
		flash.BackgroundTransparency = alpha
		-- sparks
		local sOn = t >= tl.impact and t < tl.impact + 0.6
		for _, s in ipairs(sparks) do
			s.frame.Visible = sOn
			if sOn then
				local e = E.outQuint(seg(t, tl.impact, 0.55))
				s.frame.Position = UDim2.fromOffset(cx + math.cos(s.a) * s.d * (0.5 + 2.2 * e), cy + math.sin(s.a) * s.d * (0.5 + 2.2 * e))
				s.frame.Size = UDim2.fromOffset(s.s * (1 - e), s.s * (1 - e))
				s.frame.BackgroundTransparency = e
			end
		end
	end
end

-- the wordmark (V Y R E slam down one by one), the line under it, the typed thank-you and the small version line
function Splash.fxWord(parts)
	local vp, stage, P, fit, cfg = parts.vp, parts.stage, parts.pal, parts.fit, CONFIG.Splash
	local tl = parts.tl
	local font = Splash.font(cfg.TitleFont or "LuckiestGuy", Enum.Font.GothamBlack)
	parts.font = font
	local letterSize = math.min(100, math.max(24, math.floor(112 * fit)))
	local chars = Splash.chars(cfg.Brand)
	local depth = math.max(2, math.floor(letterSize * 0.06))
	local padX = math.floor(letterSize * 0.12) + depth
	local step = -padX * 2 + 6 -- the letter groups overlap by their padding, leaving a small gap between the letters themselves
	local wordH = math.floor(200 * fit)
	local word = frame(stage, { Name = "Word", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.65), Size = UDim2.fromOffset(10, wordH), BackgroundTransparency = 1, ZIndex = 106 })
	local wordScale = Util.new("UIScale", { Scale = 1 }, word)
	local letters, cursor = {}, 0
	for index, ch in ipairs(chars) do
		local item = Splash.epicText(word, ch, letterSize, 107, font)
		item.group.AnchorPoint = Vector2.new(0.5, 0.5)
		item.group.GroupTransparency = 1
		item.scale.Scale = 2.8
		item.cx = cursor + item.width / 2
		item.group.Position = UDim2.fromOffset(item.cx, wordH / 2)
		item.dir = (index % 2 == 0) and 16 or -16
		item.at = tl.lettersAt + (index - 1) * tl.gap
		cursor = cursor + item.width + step
		letters[index] = item
	end
	local total = math.max(cursor - step, 1)
	word.Size = UDim2.fromOffset(total, wordH)
	wordScale.Scale = math.min(1, (vp.X - 30) / total)
	parts.word = { frame = word, letters = letters }

	local underline = frame(stage, { Name = "Underline", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.735), Size = UDim2.fromOffset(0, 3), BackgroundColor3 = P.accent2, ZIndex = 106 })
	grad(underline, { Color = cs({ P.accent, WHITE, P.accent }), Transparency = ns({ { 0, 1 }, { 0.5, 0 }, { 1, 1 } }) })

	local thanksSize = math.min(100, math.max(12, math.floor(30 * fit)))
	local thanks = Splash.epicText(stage, tostring(cfg.TypeText), thanksSize, 106, font)
	thanks.group.AnchorPoint = Vector2.new(0.5, 0.5)
	thanks.group.Position = UDim2.fromScale(0.5, 0.79)
	local thanksBase = math.min(1, (vp.X - 20) / thanks.width)
	thanks.scale.Scale = thanksBase
	local typed = Splash.chars(cfg.TypeText)
	parts.typed = typed
	for _, label in ipairs(thanks.labels) do
		label.MaxVisibleGraphemes = 0
	end
	parts.thanks = thanks
	local sub = Util.new("TextLabel", {
		Name = "Version", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.845), Size = UDim2.new(1, -40, 0, 18),
		BackgroundTransparency = 1, BorderSizePixel = 0, Font = font, TextSize = math.max(10, math.floor(12 * fit + 0.5)), TextColor3 = WHITE,
		TextTransparency = 1, Text = string.upper(tostring(cfg.VersionChip)), ZIndex = 106,
	}, stage)
	local underlineW = math.floor(480 * fit)

	return function(t, o)
		-- letters
		for index, item in ipairs(letters) do
			local u = seg(t, item.at, 0.55)
			local back = E.outBack(u)
			local out = o and seg(o, (index - 1) * 0.04, 0.5) or 0
			local alpha = 1 - E.outQuint(seg(t, item.at, 0.25))
			if o then
				alpha = mixn(alpha, 1, out)
			end
			item.group.GroupTransparency = alpha
			item.group.Visible = alpha < 0.999
			local s = mixn(2.8, 1, back)
			local rot = item.dir * (1 - back)
			if o then
				s = mixn(1, 3, E.inQuint(out))
				rot = (index % 2 == 0 and 25 or -25) * E.inQuad(out)
			end
			item.scale.Scale = s
			item.group.Rotation = rot
			Splash.sweep(item, nil)
			if t >= item.at + 0.3 and not o then
				local sweepU = seg(t, item.at + 0.3, 0.7)
				if sweepU < 1 then
					Splash.sweep(item, sweepU)
				end
			end
		end
		-- the second sweep over every letter and the typed line, when the typing is finished
		if t >= tl.typeEnd and not o then
			local u = seg(t, tl.typeEnd, 0.9)
			if u < 1 then
				for _, item in ipairs(letters) do
					Splash.sweep(item, u)
				end
			end
		end
		-- underline
		local width = underlineW * E.outExpo(seg(t, tl.shock, 0.9))
		if o then
			width = width * (1 - E.inQuad(seg(o, 0, 0.5)))
		end
		underline.Size = UDim2.fromOffset(width, 3)
		-- the typed line
		local count = 0
		if t >= tl.typeStart then
			count = math.min(#typed, math.floor((t - tl.typeStart) / tl.speed) + 1)
		end
		local full = t >= tl.typeEnd
		for _, label in ipairs(thanks.labels) do
			label.MaxVisibleGraphemes = full and -1 or count
		end
		local pop = seg(t, tl.typeEnd, 0.7)
		local scaleNow = thanksBase * (full and mixn(1.2, 1, E.outElastic(pop)) or 1)
		local thanksAlpha = 0
		if o then
			scaleNow = thanksBase * mixn(1, 1.6, E.inQuint(seg(o, 0, 0.5)))
			thanksAlpha = E.outQuint(seg(o, 0, 0.5))
		end
		thanks.scale.Scale = scaleNow
		thanks.group.GroupTransparency = thanksAlpha
		if full and not o then
			local u = seg(t, tl.typeEnd, 1)
			Splash.sweep(thanks, u < 1 and u or nil)
		else
			Splash.sweep(thanks, nil)
		end
		-- the small line under it
		local subAlpha = 1 - E.outQuint(seg(t, tl.typeEnd, 0.7))
		if o then
			subAlpha = mixn(subAlpha, 1, seg(o, 0, 0.5))
		end
		sub.TextTransparency = subAlpha
	end
end

-- streaks and particles that keep passing through the picture until the outro (a small fixed pool; each slot starts over with new random numbers)
function Splash.buildPools(parts)
	local stage, P = parts.stage, parts.pal
	local streaks, motes = {}, {}
	for i = 1, 8 do
		local streak = frame(stage, { Name = "Streak", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = WHITE, Rotation = -8, ZIndex = 101, Visible = false })
		grad(streak, { Color = cs({ P.accent, P.accent2, WHITE }), Transparency = ns({ { 0, 1 }, { 0.8, 0.2 }, { 1, 0 } }) })
		streaks[i] = { frame = streak, t0 = 0, dur = 0, next = math.random() * 0.6 }
	end
	for i = 1, 26 do
		local mote = frame(stage, { Name = "Mote", BackgroundColor3 = P.accent2, ZIndex = 101, Visible = false })
		Util.round_corner(mote)
		motes[i] = { frame = mote, t0 = 0, dur = 0, next = math.random() * 2.2 }
	end
	parts.pools = { streaks = streaks, motes = motes }
end

function Splash.stepPools(parts, now, running)
	local pools, vp, P = parts.pools, parts.vp, parts.pal
	if not pools then
		return
	end
	for _, s in ipairs(pools.streaks) do
		local active = s.dur > 0 and now < s.t0 + s.dur
		if active then
			local e = E.inQuad((now - s.t0) / s.dur)
			s.frame.Position = UDim2.fromScale(mixn(-0.3, 1.3, e), mixn(s.y, s.y - 0.12, e))
		elseif s.dur > 0 then
			s.dur = 0
			s.frame.Visible = false
			s.next = now + math.random(6, 18) / 100
		elseif running and now >= s.next then
			s.y = math.random(15, 85) / 100
			s.t0, s.dur = now, math.random(5, 9) / 10
			s.frame.Size = UDim2.fromOffset(math.random(200, 520), math.random(1, 3))
			s.frame.Position = UDim2.fromScale(-0.3, s.y)
			s.frame.Visible = true
		end
	end
	for _, m in ipairs(pools.motes) do
		local active = m.dur > 0 and now < m.t0 + m.dur
		if active then
			local u = (now - m.t0) / m.dur
			local e = E.outSine(u)
			m.frame.Position = UDim2.fromOffset(mixn(m.x0, m.x1, e), mixn(vp.Y + 10, m.y1, e))
			m.frame.BackgroundTransparency = mixn(0.1, 1, e)
		elseif m.dur > 0 then
			m.dur = 0
			m.frame.Visible = false
			m.next = now + math.random() * 0.5
		elseif running and now >= m.next then
			local size = math.random(2, 6)
			m.x0 = math.random(0, math.floor(vp.X))
			m.x1 = m.x0 + math.random(-90, 90)
			m.y1 = math.random(-40, math.floor(vp.Y * 0.5))
			m.t0, m.dur = now, math.random(16, 30) / 10
			m.frame.Size = UDim2.fromOffset(size, size)
			m.frame.BackgroundColor3 = (math.random() < 0.3) and P.hot or P.accent2
			m.frame.Position = UDim2.fromOffset(m.x0, vp.Y + 10)
			m.frame.Visible = true
		end
	end
end

-- the stage shakes a little: when the logo lands and each time a letter slams down
function Splash.fxShake(parts)
	local stage, tl = parts.stage, parts.tl
	local moved = false
	return function(t, o)
		local px, py = 0, 0
		if not o and not Motion.reduced then
			local power = 0
			if t >= tl.impact and t < tl.impact + 0.4 then
				power = 10
			end
			for index = 1, tl.letters do
				local at = tl.lettersAt + (index - 1) * tl.gap + 0.18
				if t >= at and t < at + 0.12 then
					power = math.max(power, 4)
				end
			end
			if power > 0 then
				px, py = math.random(-power, power), math.random(-power, power)
			end
		end
		if px ~= 0 or py ~= 0 or moved then
			stage.Position = UDim2.fromOffset(px, py)
			moved = px ~= 0 or py ~= 0
		end
	end
end

----------------------------------------------------------------------------------------------------
-- sounds of the intro: built-in Roblox sounds (CONFIG.Splash.IntroSounds), nothing to download. They follow
-- Settings > Sound, the volume and "Loading screen sound".
----------------------------------------------------------------------------------------------------
-- They are part of the Roblox client, so they are expected to work. A quick check when the screen is created marks the ones this
-- client cannot load, and Splash.sfx never plays those (the rule of the hub's own sounds: nothing known to be broken is played).
-- Splash.soundStatus[id] = "ok" | "failed"; an id that has not been checked yet is played.
Splash.soundStatus = {}

function Splash.checkIntroSounds()
	local list = CONFIG.Splash.IntroSounds
	if not ContentProvider or type(list) ~= "table" or not (Store.get("sound") and Store.get("splashSound")) then
		return
	end
	local seen = {}
	for _, id in pairs(list) do
		if type(id) == "string" and id ~= "" and not seen[id] and Splash.soundStatus[id] == nil then
			seen[id] = true
			task.spawn(function()
				local created, sound = pcall(Util.new, "Sound", { Name = "VyreIntroTest", SoundId = id, Volume = 0 }, SoundService)
				if not created or not sound then
					return
				end
				local job = { done = false, status = nil }
				task.spawn(function()
					pcall(ContentProvider.PreloadAsync, ContentProvider, { sound }, function(_, status)
						job.status = tostring(status)
					end)
					job.done = true
				end)
				local started = os.clock()
				while not job.done and os.clock() - started < 3 do
					task.wait(0.05)
				end
				if job.status == "Enum.AssetFetchStatus.Failure" or job.status == "Enum.AssetFetchStatus.TimedOut" then
					Splash.soundStatus[id] = "failed"
					Util.log("warn", "intro sound is not available: " .. id)
				elseif job.status ~= nil then
					Splash.soundStatus[id] = "ok"
				end
				pcall(sound.Destroy, sound)
			end)
		end
	end
end

function Splash.sfx(name, speed, volume)
	if not (Store.get("sound") and Store.get("splashSound")) then
		return false
	end
	local list = CONFIG.Splash.IntroSounds
	local id = list and list[name]
	local master = Store.get("volume")
	if type(id) ~= "string" or id == "" or master <= 0.001 or Splash.soundStatus[id] == "failed" then
		return false
	end
	local parent = Splash.gui or SoundService
	if not parent then
		return false
	end
	local ok, sound = pcall(function()
		return Util.new("Sound", {
			Name = "VyreIntro" .. tostring(name), SoundId = id, Volume = math.min(1, (volume or 1) * master), PlaybackSpeed = speed or 1,
		}, parent)
	end)
	if not ok or not sound then
		return false
	end
	pcall(function()
		sound:Play()
	end)
	task.delay(4, function()
		pcall(sound.Destroy, sound)
	end)
	return true
end

-- what happens at which moment (sounds and camera kicks). Fired from the tick, never from a skip, so a skipped
-- intro does not play every sound at once. Each entry: { at = seconds, fn = function() }
function Splash.makeEvents(tl)
	local list = {}
	local function add(at, fn)
		list[#list + 1] = { at = at, fn = fn }
	end
	local function sound(at, name, speed, volume)
		add(at, function()
			Splash.sfx(name, speed, volume)
		end)
	end
	local function kick(at, amount)
		add(at, function()
			Splash.camPunch(amount)
		end)
	end
	sound(0.12, "Open", 0.55, 1) -- a moment after the start, so the check of the intro sounds has an answer
	sound(tl.lids, "Boom", 0.4, 0.7)
	kick(tl.lids, 8)
	sound(tl.impact, "Boom", 0.5, 1)
	sound(tl.impact, "Slam", 0.6, 0.8)
	kick(tl.impact, 14)
	for index = 1, tl.letters do
		local at = tl.lettersAt + (index - 1) * tl.gap
		sound(at, "Slam", 0.85 + index * 0.1, 0.6)
		kick(at + 0.18, 4)
	end
	sound(tl.shock, "Boom", 0.8, 0.6)
	local total = #Splash.chars(CONFIG.Splash.TypeText)
	for k = 3, total, 3 do
		sound(tl.typeStart + (k - 1) * tl.speed, "Tick", 1.9, 0.25)
	end
	sound(tl.typeEnd, "Ping", 1, 0.6)
	table.sort(list, function(a, b)
		return a.at < b.at
	end)
	return list
end

function Splash.fire(parts, t)
	local list = parts.events
	if not list then
		return
	end
	local index = parts.eventIndex or 1
	while index <= #list and list[index].at <= t do
		local entry = list[index]
		index = index + 1
		parts.eventIndex = index
		if t - entry.at <= 0.6 then -- an event that is already long past (a stalled frame) is dropped, not played late
			local ok, err = pcall(entry.fn)
			if not ok then
				Util.log("warn", "splash event: " .. tostring(err))
			end
		end
	end
	parts.eventIndex = index
end

----------------------------------------------------------------------------------------------------
-- the camera drop (GTA style): the camera starts high above your character looking down, spirals in as it falls, banks like a
-- plane and lands right behind your back looking where you look. EVERY exit hands the camera back exactly as it was
-- (type, field of view, and the position when the game had its own scripted camera): Splash.camStop.
----------------------------------------------------------------------------------------------------
Splash.cam = nil   -- state of the drop in progress
Splash.blur = nil  -- the BlurEffect made for the intro

function Splash.camStart(parts)
	if Splash.cam or Motion.reduced or parts.plain or not Store.get("splashCamera") then
		return
	end
	local camera = workspace.CurrentCamera
	local player = Players.LocalPlayer
	if not camera or not player then
		return
	end
	local state = { dead = false, kicks = {}, start = 0, duration = math.max(1, tonumber(CONFIG.Splash.CameraSeconds) or 5), faults = 0 }
	Splash.cam = state
	task.spawn(function()
		-- the character may still be loading: wait for it, but never longer than 5 seconds
		local waited, root = 0, nil
		while not state.dead and waited < 5 do
			local character = player.Character
			root = character and character:FindFirstChild("HumanoidRootPart")
			if root then
				break
			end
			task.wait(0.1)
			waited = waited + 0.1
		end
		if state.dead or Splash.cam ~= state or Splash.parts ~= parts or not Splash.isOpen or Splash.closing then
			if Splash.cam == state then
				Splash.cam = nil
			end
			return
		end
		if not root then
			Splash.cam = nil
			Util.log("info", "camera drop skipped: the character was not ready")
			return
		end
		local ok, err = pcall(function()
			state.root = root
			state.oldType, state.oldFov, state.oldCFrame = camera.CameraType, camera.FieldOfView, camera.CFrame
			local look = root.CFrame.LookVector
			local flat = Vector3.new(look.X, 0, look.Z)
			if flat.Magnitude > 0.01 then
				flat = flat.Unit
			else
				flat = Vector3.new(0, 0, -1)
			end
			state.flat = flat
			state.backAngle = atan2(-flat.Z, -flat.X)
			state.turns = 1.25 * math.pi * 2
			local found, lookAt = pcall(function()
				return CFrame.lookAt
			end)
			state.lookAt = (found and lookAt) or function(from, to)
				return CFrame.new(from, to)
			end
			state.start = os.clock()
			state.restore = true -- from here on camStop puts everything back
			camera.CameraType = Enum.CameraType.Scriptable
			camera.FieldOfView = 90
			state.conn = RunService.RenderStepped:Connect(function()
				Splash.camStep(state, camera)
			end)
		end)
		if not ok then
			Util.log("warn", "camera drop: " .. tostring(err))
			Splash.camStop(true)
		end
	end)
end

function Splash.camStep(state, camera)
	if state.dead then
		return
	end
	local root = state.root
	if not root or not root.Parent then
		return -- the character is gone (respawn): the camera simply stays where it is until the screen closes
	end
	local ok, err = pcall(function()
		local cfg = CONFIG.Splash
		local now = os.clock()
		local p = Util.clamp((now - state.start) / state.duration, 0, 1)
		local fall = (1 - p) ^ 3 -- 1 high in the sky, 0 landed: it drops fast and lands soft
		local center = root.Position + Vector3.new(0, 1.5, 0)
		local angle = state.backAngle + fall * state.turns
		local height = 3.5 + (tonumber(cfg.CameraHeight) or 340) * fall ^ 1.15
		local radius = 9 + (tonumber(cfg.CameraRadius) or 70) * fall
		local position = center + Vector3.new(math.cos(angle) * radius, height, math.sin(angle) * radius)
		-- from looking straight down at you to looking over your shoulder
		local settle = (1 - fall) ^ 6
		local target = center:Lerp(center + state.flat * 30 + Vector3.new(0, 1, 0), settle)
		-- it banks into the spin like a plane and levels out at the end
		camera.CFrame = state.lookAt(position, target) * CFrame.Angles(0, 0, fall * 0.45)
		-- field of view: wide at the start, 60 when landed, minus the kicks of the slams
		local fov = mixn(90, 60, E.outQuad(p))
		for i = #state.kicks, 1, -1 do
			local kick = state.kicks[i]
			local dt = now - kick.at
			if dt < 0.07 then
				fov = fov - kick.amount * (dt / 0.07)
			elseif dt < 0.67 then
				fov = fov - kick.amount * (1 - E.outBack((dt - 0.07) / 0.6))
			else
				table.remove(state.kicks, i)
			end
		end
		camera.FieldOfView = Util.clamp(fov, 20, 120)
	end)
	if not ok then
		state.faults = state.faults + 1
		if state.faults == 1 then
			Util.log("warn", "camera drop frame: " .. tostring(err))
		end
		if state.faults >= 3 then
			Splash.camStop(true)
		end
	end
end

-- a short dip of the field of view (a punch), used on the slams
function Splash.camPunch(amount)
	local state = Splash.cam
	if state and not state.dead and state.restore then
		state.kicks[#state.kicks + 1] = { at = os.clock(), amount = amount or 10 }
	end
end

-- hands the camera back. instant = false lets the field of view glide back (the outro); true restores at once (errors, destroy)
function Splash.camStop(instant)
	local state = Splash.cam
	if not state then
		return
	end
	Splash.cam = nil
	state.dead = true
	if state.conn then
		pcall(state.conn.Disconnect, state.conn)
		state.conn = nil
	end
	if not state.restore then
		return
	end
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	pcall(function()
		camera.CameraType = state.oldType
		if state.oldType == Enum.CameraType.Scriptable and state.oldCFrame then
			camera.CFrame = state.oldCFrame -- the game had its own scripted camera: put it back where it was
		end
	end)
	if instant or Motion.reduced then
		pcall(function()
			camera.FieldOfView = state.oldFov
		end)
	else
		local ok = pcall(Motion.tween, camera, { FieldOfView = state.oldFov }, 0.9, Enum.EasingStyle.Quint)
		if not ok then
			pcall(function()
				camera.FieldOfView = state.oldFov
			end)
		end
	end
end

-- the blur of the game behind the screen (a BlurEffect in Lighting; Roblox has no other way). Always removed again.
function Splash.blurOn(parts)
	if Splash.blur or Motion.reduced or parts.plain or not Lighting or not Store.get("splashBlur") then
		return
	end
	local ok, effect = pcall(function()
		local old = Lighting:FindFirstChild("VyreIntroBlur") -- left over from a run that was cut short
		if old then
			old:Destroy()
		end
		return Util.new("BlurEffect", { Name = "VyreIntroBlur", Size = 0 }, Lighting)
	end)
	if not ok or not effect then
		return
	end
	Splash.blur = effect
	pcall(Motion.tween, effect, { Size = tonumber(CONFIG.Splash.BlurSize) or 8 }, 0.6, Enum.EasingStyle.Quad)
end

function Splash.blurOff(instant)
	local effect = Splash.blur
	if not effect then
		return
	end
	Splash.blur = nil
	if instant or Motion.reduced then
		pcall(effect.Destroy, effect)
		return
	end
	pcall(Motion.tween, effect, { Size = 0 }, 0.6, Enum.EasingStyle.Quad)
	task.delay(0.8, function()
		pcall(effect.Destroy, effect)
	end)
end

----------------------------------------------------------------------------------------------------
-- building the screen
----------------------------------------------------------------------------------------------------
-- the real status of the boot lives in the bottom letterbox bar: the step name, the thin progress line (only a real finished
-- boot step moves it) and, as the "tap" target once boot is done, the whole bar.
function Splash.buildStatus(parts)
	local bar, intro, fit = parts.barBottom, parts.intro, parts.fit
	local barH = parts.barH
	local block = 25
	local y0 = math.max(4, math.floor((barH - block) / 2))
	local trackW = math.floor(236 * math.max(fit, 0.7))
	parts.status = Util.new("TextLabel", {
		Name = "Status", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, y0), Size = UDim2.new(1, -40, 0, 16),
		BackgroundTransparency = 1, BorderSizePixel = 0, Text = parts.stepText, TextColor3 = Color3.fromRGB(228, 231, 238),
		TextXAlignment = Enum.TextXAlignment.Center, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 127,
	}, bar)
	Typo.apply(parts.status, "heading", 13)
	parts.track = Util.new("Frame", {
		Name = "Track", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, y0 + 22), Size = UDim2.fromOffset(trackW, 3),
		BorderSizePixel = 0, BackgroundColor3 = WHITE, BackgroundTransparency = 0.82, ZIndex = 127,
	}, bar)
	Util.round_corner(parts.track)
	parts.fill = Util.new("Frame", { Name = "Fill", Size = UDim2.fromScale(0, 1), BorderSizePixel = 0, BackgroundColor3 = WHITE, ZIndex = 128 }, parts.track)
	Util.round_corner(parts.fill)
	-- a problem line (only for warnings and failures), just above the bar
	parts.detail = Util.new("TextLabel", {
		Name = "Detail", AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -(barH + 4)), Size = UDim2.new(1, -40, 0, 14),
		BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", TextXAlignment = Enum.TextXAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd, TextStrokeTransparency = 0.5, TextStrokeColor3 = BLACK, ZIndex = 127,
	}, intro)
	Typo.apply(parts.detail, "caption", 11)
	Theme.bind(parts.detail, "TextColor3", "Faint")
	-- skip: a tap during the intro shows its finished state at once
	parts.skipBtn = Util.new("TextButton", {
		Name = "Skip", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 2,
	}, intro)
	parts.skipBtn.Activated:Connect(function()
		local current = Splash.parts
		if current == parts and current.t0 and os.clock() - current.t0 > 1 then
			Splash.skipIntro()
		end
	end)
	-- the tap target over the whole bottom bar; only visible (and therefore only tappable) once the screen says "tap"
	parts.tap = Util.new("TextButton", {
		Name = "Continue", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, barH + 14), ZIndex = 140, Visible = false,
	}, intro)
	parts.tap.Activated:Connect(function()
		Splash.activate()
	end)
end

-- Builds the whole screen. plain = true builds the simple fallback (a title and the bottom bar, no animation).
function Splash.build(container, plain)
	local parts = Splash.parts
	local cfg = CONFIG.Splash
	local vp = Env.viewport()
	local fit = Util.clamp(math.min((vp.X - 30) / 520, (vp.Y - 40) / 640), 0.45, 1)
	parts.plain, parts.fit, parts.vp = plain and true or false, fit, vp
	parts.tl = Splash.plan()
	parts.pal = Splash.palette()
	parts.stepText = "Starting..."
	parts.dimRest = Util.clamp(tonumber(cfg.Dim) or 0.6, 0, 0.95)
	parts.fx = {}

	local gui = Util.new("ScreenGui", {
		Name = CONFIG.SplashName, DisplayOrder = 1000, IgnoreGuiInset = true, ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, nil)
	Splash.gui = gui -- registered early so a failed build can still be cleaned up
	parts.gui = gui
	local background = BLACK
	if cfg.UseTheme and Theme.live.Background then
		background = Theme.live.Background
	end
	local intro = Util.new("Frame", {
		Name = "Intro", Size = UDim2.fromScale(1, 1), BackgroundColor3 = background, BackgroundTransparency = 1, BorderSizePixel = 0,
		Active = true, ZIndex = 1,
	}, gui)
	parts.intro = intro
	parts.stage = Util.new("Frame", { Name = "Stage", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 100 }, intro)

	local function add(name, builder, essential)
		local ok, result = pcall(builder, parts)
		if ok and type(result) == "function" then
			parts.fx[#parts.fx + 1] = { name = name, fn = result, faults = 0 }
		elseif essential then
			error(result, 0)
		else
			Util.log("warn", "splash effect '" .. name .. "' could not be built: " .. tostring(result))
		end
	end
	add("frame", Splash.fxFrame, true)
	if plain then
		local title = Util.new("TextLabel", {
			Name = "Title", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.42), Size = UDim2.fromOffset(420, 90),
			BackgroundTransparency = 1, BorderSizePixel = 0, Text = tostring(cfg.Brand), TextColor3 = WHITE, ZIndex = 110,
		}, parts.stage)
		Typo.apply(title, "display", 64)
	else
		pcall(Splash.buildPools, parts)
		add("lids", Splash.fxLids)
		add("clouds", Splash.fxClouds)
		add("implosion", Splash.fxImplosion)
		add("orb", Splash.fxOrb)
		add("logo", Splash.fxLogo)
		add("light", Splash.fxLight)
		add("word", Splash.fxWord)
		add("shake", Splash.fxShake)
	end
	Splash.buildStatus(parts)

	if plain then
		parts.fade = snapshotFade(intro)
	end
	Splash.draw(parts, plain and Splash.FINAL or 0) -- the opening look is drawn BEFORE the gui is shown, so nothing flashes
	gui.Parent = container
	Splash.isOpen = true

	task.defer(Splash.begin, parts)
	-- safety net: the intro can never keep the "tap" state waiting
	task.delay(parts.tl.done + 5, function()
		if Splash.parts == parts and Splash.isOpen and not parts.introDone then
			Splash.skipIntro()
		end
	end)
	return gui
end

-- Creates the loading screen. If the animated one cannot be built a plain one is built instead;
-- if that fails too the error reaches App.boot, which opens the hub directly.
function Splash.create(container)
	Splash.destroy()
	local lastError = nil
	for attempt = 1, 2 do
		Splash.createdAt = os.clock()
		Splash.fraction = 0
		Splash.closing = false
		Splash.parts = {}
		local ok, err = pcall(Splash.build, container, attempt == 2)
		if ok then
			Splash.checkIntroSounds()
			return Splash.gui
		end
		lastError = err
		Util.log("error", (attempt == 1 and "splash (animated): " or "splash (plain): ") .. tostring(err))
		Splash.destroy()
	end
	error(lastError, 0)
end

----------------------------------------------------------------------------------------------------
-- animation
----------------------------------------------------------------------------------------------------
-- Draws the intro at time t (seconds since it started; Splash.FINAL = the finished intro). o = seconds since the outro began
-- (nil before). Idempotent: any t can be drawn at any moment. One effect that fails cannot stop the others.
function Splash.draw(parts, t, o)
	local list = parts.fx
	if not list then
		return
	end
	for _, entry in ipairs(list) do
		if entry.fn then
			local ok, err = pcall(entry.fn, t, o)
			if not ok then
				entry.faults = entry.faults + 1
				if entry.faults == 1 then
					Util.log("error", "splash effect '" .. entry.name .. "': " .. tostring(err))
				end
				if entry.faults >= 3 then
					entry.fn = nil -- this effect stays as it is; the others go on
				end
			end
		end
	end
	if t >= parts.tl.lettersAt then
		Splash.startMusic() -- the loading music starts with the first letter
	end
end

-- everything that keeps moving after the intro: the rays and the ring turn, the orb plays, the logo floats, streaks and
-- particles pass by, the light crosses the mark every few seconds, the hint pulses. Skipped with reduced motion.
function Splash.idle(parts, now, o)
	if Motion.reduced then
		return
	end
	local elapsed = now - (parts.t0 or now)
	local rig = parts.rig
	if rig then
		rig.ringGradient.Rotation = (now * 140) % 360
		rig.frame.Rotation = math.sin(elapsed * 1.4) * 4
		rig.frame.Position = UDim2.new(0.5, 0, 0.37, math.sin(elapsed * 2) * 6)
	end
	if parts.rays then
		parts.rays.Rotation = (elapsed * 12) % 360
	end
	local orb = parts.orb
	if orb then
		orb.rim.Rotation = (now * 160) % 360
		if orb.sprite then
			local number = math.floor(now * orb.fps) % orb.frames
			if number ~= orb.shown then
				orb.shown = number
				orb.sprite.ImageRectOffset = Vector2.new((number % orb.columns) * orb.cell, math.floor(number / orb.columns) * orb.cell)
			end
		end
	end
	Splash.stepPools(parts, now, o == nil and elapsed > 0.2)
	-- once the intro is over the light crosses the mark again every few seconds
	local logo = parts.logo
	if logo and parts.introDone and o == nil then
		if not parts.shineAt and now >= (parts.nextShine or now + 1.5) then
			parts.shineAt, parts.nextShine = now, now + 5
		end
		if parts.shineAt then
			local u = (now - parts.shineAt) / 0.9
			local shine = parts.rig and parts.rig.shineGradient
			if u >= 1 then
				parts.shineAt = nil
				logo.paint(nil)
				if shine then
					shine.Offset = Vector2.new(-1, 0)
				end
			else
				logo.paint(mixn(-1.5, 1.5, E.inOutSine(u)))
				if shine then
					shine.Offset = Vector2.new(mixn(-1, 1, E.inOutSine(u)), 0)
				end
			end
		end
	end
	if parts.isReady and not Splash.closing and not parts.failed and parts.readyAt and now - parts.readyAt > 0.4 then
		parts.status.TextTransparency = 0.04 + 0.34 * (0.5 + 0.5 * math.sin((now - parts.readyAt) * 3.2))
	end
end

-- the Anim job: never lets one bad frame stop the screen from reaching its "tap" state
function Splash.tick(now)
	local parts = Splash.parts
	if not Splash.isOpen or not parts.t0 then
		return
	end
	local ok, err = pcall(function()
		local o = parts.outroAt and (now - parts.outroAt) or nil
		if not parts.introDone then
			local t = now - parts.t0
			Splash.fire(parts, t)
			Splash.draw(parts, t)
			if t >= parts.tl.done then
				Splash.skipIntro()
			end
		elseif o then
			Splash.draw(parts, Splash.FINAL, o)
			Splash.outroStep(parts, o)
			if Splash.parts ~= parts then
				return -- the outro finished and the screen is gone
			end
		end
		Splash.idle(parts, now, o)
	end)
	if not ok then
		parts.faults = (parts.faults or 0) + 1
		Util.log("error", "splash frame: " .. tostring(err))
		if parts.faults >= 3 then
			Anim.remove("splash")
			if parts.outroAt then
				Splash.endOutro(parts) -- the animation job is gone: do not wait for it
			else
				parts.t0 = nil
				Splash.skipIntro()
			end
		end
	end
end

Splash.tickFn = function(_, now)
	Splash.tick(now)
end

-- Shows the finished intro at once. Used by reduced motion, by failures, by the watchdog and by a tap on the intro.
function Splash.skipIntro()
	local parts = Splash.parts
	if not Splash.isOpen or parts.introDone then
		return
	end
	parts.introDone = true -- first, so a failing draw can never block the hint
	local ok, err = pcall(Splash.draw, parts, Splash.FINAL, nil)
	if not ok then
		Util.log("error", "splash final state: " .. tostring(err))
	end
	Splash.startMusic() -- idempotent; covers the plain screen and reduced motion
	if parts.t0 and not Motion.reduced and not parts.outroAt then
		Anim.add("splash", Splash.tickFn, 30) -- keep the ambient motion going, cheaper
	end
	Splash.refresh()
end

-- first frame after the gui is shown
function Splash.begin(parts)
	if Splash.parts ~= parts or not Splash.isOpen or Splash.closing or parts.begun then
		return
	end
	parts.begun = true
	parts.drawn = true
	task.spawn(function()
		local ok, err = pcall(Splash.loadLogo, parts)
		if not ok then
			Util.log("warn", "logo image: " .. tostring(err))
		end
	end)
	if parts.plain or Motion.reduced or #parts.fx < 2 then
		Splash.skipIntro()
		return
	end
	parts.t0 = os.clock()
	parts.events, parts.eventIndex = Splash.makeEvents(parts.tl), 1
	Splash.blurOn(parts)
	Splash.camStart(parts)
	Anim.add("splash", Splash.tickFn)
end

-- CONFIG.Splash.LogoImage: "" = the built-in VYRE V. An rbxassetid, or a file in the executor workspace (Env.customAsset).
-- The picture replaces the V only after it has really loaded; otherwise the V stays.
function Splash.loadLogo(parts)
	local pic = parts.pic
	local source = CONFIG.Splash.LogoImage
	if not pic or type(source) ~= "string" or source == "" then
		return
	end
	local content = nil
	if string.find(source, "^rbxassetid://") or string.find(source, "^rbxasset://") or string.find(source, "^rbxthumb://") then
		content = source
	elseif string.find(source, "^%d+$") then
		content = "rbxassetid://" .. source
	elseif Env.canCustomAsset() and Env.fileExists(source) then
		content = Env.customAsset(source)
	end
	if not content then
		Util.log("warn", "logo image is not available, the built-in V is used: " .. source)
		return
	end
	pic.Image = content
	local shine = pic:FindFirstChild("Shine")
	if shine then
		shine.Image = content
	end
	local waited = 0
	while waited < 4 and Splash.parts == parts and Splash.isOpen do
		local ok, loaded = pcall(function()
			return pic.IsLoaded
		end)
		if ok and loaded then
			parts.logoImage = true -- fxLogo shows the picture and hides the V from the next frame on
			return
		end
		task.wait(0.1)
		waited = waited + 0.1
	end
	pic.Image = ""
	Util.log("warn", "logo image did not load in time, the built-in V is used: " .. source)
end

----------------------------------------------------------------------------------------------------
-- reporting from App.boot
----------------------------------------------------------------------------------------------------
-- Reports REAL progress. text = stage name, done / total = completed boot steps, partial = 0..1 of the current one
function Splash.step(text, done, total, partial)
	local parts = Splash.parts
	if not Splash.isOpen or Splash.closing or not parts.status or parts.isReady or parts.failed then
		return
	end
	if text then
		parts.stepText = text
		setStatusText(parts.status, text)
	end
	local fraction = Util.clamp((done + (partial or 0)) / math.max(total, 1), 0, 1)
	if fraction > Splash.fraction then
		Splash.fraction = fraction
		Motion.tween(parts.fill, { Size = UDim2.fromScale(fraction, 1) }, 0.4, Enum.EasingStyle.Quart)
	end
end

-- a short problem line above the bar; ordinary "all fine" details stay hidden
function Splash.detail(text, role)
	local parts = Splash.parts
	if not parts.detail then
		return
	end
	if role == "Warn" or role == "Danger" then
		parts.detail.Text = tostring(text or "")
		Theme.bind(parts.detail, "TextColor3", role)
	else
		parts.detail.Text = ""
	end
end

local function finishClose(onClosed)
	Anim.remove("splash")
	Splash.dropPick()
	Splash.camStop(true)
	Splash.blurOff(true)
	local gui = Splash.gui
	Splash.gui, Splash.isOpen = nil, false
	Splash.parts = {}
	if gui then
		pcall(gui.Destroy, gui)
	end
	UI.prune()
	if onClosed then
		Util.try("splash onClosed", onClosed)
	end
end

-- The screen says "tap": boot is done (or forced) AND the intro has finished. Nothing closes by itself.
function Splash.refresh()
	local parts = Splash.parts
	if not Splash.isOpen or Splash.closing or parts.isReady or parts.failed then
		return
	end
	if parts.introDone and (parts.bootDone or parts.forced) then
		Splash.enterReady()
	end
end

function Splash.enterReady()
	local parts = Splash.parts
	parts.isReady = true
	parts.readyAt = os.clock()
	setStatusText(parts.status, tostring(CONFIG.Splash.HintText))
	Motion.tween(parts.track, { BackgroundTransparency = 1 }, 0.4)
	Motion.tween(parts.fill, { BackgroundTransparency = 1 }, 0.4)
	parts.tap.Visible = true
	Sfx.play("success")
end

-- All real work finished. Records it; the hand-off happens only when the user taps.
function Splash.ready(onHandoff, onClosed)
	local parts = Splash.parts
	if not Splash.isOpen or Splash.closing then
		return
	end
	if onHandoff then
		Splash.handoff = onHandoff
	end
	if onClosed then
		Splash.onClosed = onClosed
	end
	parts.bootDone = true
	if Splash.fraction < 1 and not parts.isReady then
		Splash.fraction = 1
		Motion.tween(parts.fill, { Size = UDim2.fromScale(1, 1) }, 0.35, Enum.EasingStyle.Quart)
	end
	Splash.refresh()
end

-- Watchdog (MaxSeconds): only moves the screen to its "tap to open" state. It never opens the hub.
function Splash.force(onHandoff)
	local parts = Splash.parts
	if not Splash.isOpen or Splash.closing or parts.failed then
		return
	end
	if onHandoff then
		Splash.handoff = onHandoff
	end
	parts.forced = true
	Splash.skipIntro()
	Splash.refresh()
end

function Splash.setHandoff(onHandoff, onClosed)
	Splash.handoff = onHandoff
	Splash.onClosed = onClosed
end

-- tap on the bottom bar
function Splash.activate()
	local parts = Splash.parts
	if not Splash.isOpen or Splash.closing or not parts.isReady then
		return
	end
	Splash.close(Splash.handoff, Splash.onClosed)
end

-- the outro (seconds after the tap): everything rushes at the camera, the bars open, a flash, and the game is back.
-- The hub is handed over at the flash, so its logo appears under the fading screen.
Splash.OUTRO = { handoff = 0.55, camera = 0.55, finish = 1.5 }

function Splash.endOutro(parts)
	if parts.finished then
		return
	end
	parts.finished = true
	if not parts.handedOff then
		parts.handedOff = true
		if parts.outroHandoff then
			Util.try("splash handoff", parts.outroHandoff)
		end
	end
	finishClose(parts.outroClosed)
end

function Splash.outroStep(parts, o)
	local plan = Splash.OUTRO
	if o >= plan.handoff and not parts.handedOff then
		parts.handedOff = true
		if parts.outroHandoff then
			Util.try("splash handoff", parts.outroHandoff)
		end
	end
	if o >= plan.camera and not parts.cameraBack then
		parts.cameraBack = true
		Splash.camStop(false)
		Splash.blurOff(false)
	end
	if o >= plan.finish then
		Splash.endOutro(parts)
	end
end

-- Closes the screen. onHandoff() runs at the flash of the outro (the hub window opens under it).
function Splash.close(onHandoff, onClosed)
	if Splash.closing or not Splash.isOpen then
		if onClosed and not Splash.isOpen then
			Util.try("splash onClosed", onClosed)
		end
		return
	end
	Splash.closing = true
	local parts = Splash.parts
	if parts.music then
		parts.music.Stop(1.1)
	end
	if parts.tap then
		parts.tap.Visible = false
	end
	if parts.skipBtn then
		parts.skipBtn.Visible = false
	end
	if parts.detail then
		parts.detail.Visible = false
	end
	-- no outro: reduced motion, the plain screen, or an animation that never started
	if Motion.reduced or parts.plain or not parts.t0 then
		Sfx.play("open")
		if onHandoff then
			Util.try("splash handoff", onHandoff)
		end
		if Motion.reduced or not parts.fade then
			finishClose(onClosed)
			return
		end
		Splash.camStop(false)
		Splash.blurOff(false)
		fadeTo(parts.fade, true, 0.32, Enum.EasingStyle.Quad)
		task.delay(0.42, function()
			if Splash.parts == parts then
				finishClose(onClosed)
			end
		end)
		return
	end
	parts.outroAt = os.clock()
	parts.outroHandoff, parts.outroClosed = onHandoff, onClosed
	Splash.sfx("Open", 1.1, 0.9)
	Anim.add("splash", Splash.tickFn) -- back to the full frame rate for the outro
	-- safety net: whatever happens to the animation job, the screen is gone shortly after the outro should have ended
	task.delay(Splash.OUTRO.finish + 1, function()
		if Splash.parts == parts and Splash.isOpen then
			Splash.endOutro(parts)
		end
	end)
end

-- Something essential failed: say so honestly, then close.
function Splash.fail(message, onClosed)
	local parts = Splash.parts
	if not Splash.isOpen or Splash.closing then
		return
	end
	parts.failed = true
	if parts.music then
		parts.music.Stop(0.45)
	end
	Splash.skipIntro()
	Splash.camStop(false)
	Splash.blurOff(false)
	Sfx.play("error")
	setStatusText(parts.status, "Startup problem")
	Theme.bind(parts.status, "TextColor3", "Danger")
	Theme.bind(parts.detail, "TextColor3", "Danger")
	parts.detail.Text = Util.cap(tostring(message or "Unknown error"), 90)
	if parts.ringStroke then
		Theme.bind(parts.ringStroke, "Color", "Danger")
	end
	Theme.bind(parts.fill, "BackgroundColor3", "Danger")
	Motion.tween(parts.fill, { Size = UDim2.fromScale(1, 1) }, 0.3)
	task.delay(2.6, function()
		if Splash.parts == parts then
			Splash.close(nil, onClosed)
		end
	end)
end

function Splash.destroy()
	Anim.remove("splash")
	if Splash.parts.music then
		Splash.parts.music.Stop(0)
	end
	Splash.dropPick()
	Splash.camStop(true)
	Splash.blurOff(true)
	if Splash.gui then
		pcall(Splash.gui.Destroy, Splash.gui)
	end
	Splash.gui, Splash.isOpen, Splash.closing, Splash.parts = nil, false, false, {}
	Splash.handoff, Splash.onClosed = nil, nil
end
end -- [09_splash.lua]

do -- [11_window.lua]

----------------------------------------------------------------------------------------------------
-- Win: the hub window and its floating logo.
--   Window    positioning container (top-centre anchored, UIScale = user scale x fit), holds the shadow
--   Surface   the visible rounded panel (clips everything)
--     BgLayer / Body (header + page title + pages + footer) / popup layer / modal layer   (no sidebar)
--   Launcher  the draggable logo, an orb. Tap it and ONLY the ring of tab chips opens around it (tap it again to
--             close the ring). The window, that tab's menu, opens when a chip in the ring is tapped.
--             HIDE MENU (top right of the window) hides the window; orb -> tab brings it back.
-- The window pours out of the orb when it opens and is drawn back into it when it closes (2.4.0), by tweening Position,
-- Size and Scale together with identical easing. Without an orb it opens and closes around its own centre.
----------------------------------------------------------------------------------------------------
Win.TITLE_H = 0               -- height of a collapsed window (the window is hidden now, never collapsed)
Win.GENIE_SCALE = 0.07          -- the window shrinks to this share of its size when it goes into (or comes out of) the orb
Win.HEADER_H = 44             -- the draggable title bar: keeps the window grabbable when it is dragged near an edge

-- SIZES (1 = the size of v2.1.0). Lower a number to make that part smaller, raise it to make it bigger.
Win.SHRINK = 0.8              -- window size multiplier (on top of Settings > UI scale)
Win.MAX_W_FRAC = 0.8          -- the window never takes more than this share of the screen width ...
Win.MAX_H_FRAC = 0.84         -- ... or height, so the logo and the game stay visible around it
Win.LOGO_SCALE = 0.84         -- logo + tab ring size multiplier (it was 1.05 in v2.1.0)
Win.CLOSE_RING_ON_PICK = true -- close the tab ring after a tab is tapped, so the ring never covers the menu
Win.COLLAPSED_W = 320
Win.visible = false
Win.minimized = false
Win.x, Win.top = 0, 0         -- top-centre of the window in screen pixels (canonical target)
Win.w, Win.h, Win.s = 760, 510, 1
Win.rail, Win.short = false, false
Win.itemH, Win.gap = 40, 6
Win.ui = {}
Win.nav = {}
Win.pages = {}
Win.currentTab = nil
Win.layoutListeners = {}
Win.focusToken = 0
Win.kbShift = 0
Win.userMoved = false         -- true once the player has dragged the window; until then it stays centred
Win.lastViewport = nil
Win.ringOpen = false         -- the radial tab ring around the logo is open
Win.launcher = nil            -- { root, scale, ring, pop, hub, shown }: the draggable logo
Win.radial = nil              -- { wedges }: nil when the ring could not be built

Win.tabList = {}  -- filled by Window:AddTab
Win.tabById, Win.tabIndex = {}, {}

----------------------------------------------------------------------------------------------------
-- Tab ring geometry (plain maths, no Roblox objects).
-- The tabs are pill-shaped chips (icon + name on a rounded plate; the chosen tab filled with the accent gradient: the
-- tab design of the index). They sit in two curved columns that wrap the orb, one on each side: the first half of the
-- tabs run down the right side, the rest run up the left side, so the order is clockwise from the top like before.
-- All numbers are "design units": the launcher is designed at this size and scaled to fit the screen.
----------------------------------------------------------------------------------------------------
Win.RING = {
	hubR = 29,            -- radius of the orb (58 wide, like the index orb)
	arcR = 104,           -- the chips' centres lie on a circle of this radius around the orb ...
	pitch = 44,           -- ... this far apart, top to bottom
	chipW = 112, chipH = 30,
	iconSize = 16,
	margin = 6,           -- free room kept around the ring when it is kept on screen
	stagger = 0.02,       -- seconds between two chips popping out of the orb
}

-- chip centres, as offsets from the orb's centre (y down): { { x, y }, ... } in tab order
function Win.ringPlan(count)
	local R = Win.RING
	local right = math.ceil(count / 2)
	local left = count - right
	local plan = {}
	local function place(index, rows, row, side)
		local y = (row - (rows - 1) / 2) * R.pitch
		local x = math.sqrt(math.max(0, R.arcR * R.arcR - y * y))
		plan[index] = { math.floor(side * x + 0.5), math.floor(y + 0.5) }
	end
	for k = 1, right do
		place(k, right, k - 1, 1) -- right column, top to bottom
	end
	for j = 1, left do
		place(right + j, left, left - j, -1) -- left column, bottom to top
	end
	return plan
end

-- half width / half height of the whole ring (the chips included)
function Win.ringExtent()
	local R = Win.RING
	local halfW, halfH = 0, 0
	for _, spot in ipairs(Win.ringPlan(#Win.tabList)) do
		halfW = math.max(halfW, math.abs(spot[1]))
		halfH = math.max(halfH, math.abs(spot[2]))
	end
	return halfW + R.chipW / 2, halfH + R.chipH / 2
end

-- popups convert screen pixels to layout units with the window's live scale
UI.scale = function()
	local scaler = Win.scaler
	if scaler and scaler.Parent then
		return scaler.Scale
	end
	return 1
end

----------------------------------------------------------------------------------------------------
-- geometry
----------------------------------------------------------------------------------------------------
-- layout size (in layout units) and total scale for the current viewport / user scale / compact mode
function Win.computeLayout()
	local viewport = Env.viewport()
	local user = Store.get("scale") * Win.SHRINK
	local baseW, baseH = 640, 510 -- one column now (the sidebar is gone), so the window is narrower
	if Store.get("compact") then
		baseW, baseH = 580, 470
	end
	-- the window keeps to a share of the screen, so the logo and the game stay visible around it
	local availW = (viewport.X * Win.MAX_W_FRAC) / user
	local availH = (viewport.Y * Win.MAX_H_FRAC) / user
	local w, h = math.min(baseW, availW), math.min(baseH, availH)
	local minW, minH = 300, 270
	local fit = 1
	if w < minW or h < minH then
		fit = math.min(w / minW, h / minH)
		w, h = math.max(w, minW), math.max(h, minH)
	end
	return math.floor(w + 0.5), math.floor(h + 0.5), user * fit
end

-- size the window should have right now (collapsed to its title bar, or full)
function Win.currentTarget()
	if Win.minimized then
		return math.min(Win.w, Win.COLLAPSED_W), Win.TITLE_H
	end
	return Win.w, Win.h
end

-- keeps the window reachable. widthPx / heightPx are screen pixels.
-- Dragging may push part of the window off screen, but never so far that its title bar can't be grabbed again.
-- `strict` (after a rotation / scale change, on restore and on recentre) pulls the WHOLE window back inside the screen
-- whenever it fits, so a window that nearly fills the screen can't be left hanging over an edge.
function Win.clampPx(x, top, widthPx, heightPx, strict)
	local viewport = Env.viewport()
	local nx, maxTop
	if strict and widthPx <= viewport.X then
		nx = Util.clamp(x, widthPx / 2, viewport.X - widthPx / 2)
	else
		local keep = math.min(220, widthPx - 8)
		nx = Util.clamp(x, keep - widthPx / 2, viewport.X + widthPx / 2 - keep)
	end
	if strict and heightPx <= viewport.Y then
		maxTop = viewport.Y - heightPx
	else
		maxTop = viewport.Y - math.min(heightPx, Win.HEADER_H * Win.s)
	end
	local ny = Util.clamp(top, 0, math.max(0, maxTop))
	return nx, ny
end

-- animates position, size and scale together (same TweenInfo => same progress every frame)
function Win.glide(x, top, width, height, scale, duration, style, direction, onDone)
	local window, scaler = Win.window, Win.scaler
	if not window then
		return
	end
	Motion.tween(window, { Position = UDim2.fromOffset(x, top), Size = UDim2.fromOffset(width, height) }, duration, style, direction)
	Motion.tween(scaler, { Scale = scale }, duration, style, direction, onDone)
end

----------------------------------------------------------------------------------------------------
-- responsive layout: positions every region from (w, h). Immediate, no tweening.
----------------------------------------------------------------------------------------------------
function Win.refreshChrome()
	local ui = Win.ui
	if not ui.clock or not ui.brand then
		return
	end
	local clockOn = Store.get("clock") and Win.w >= 440
	ui.clock.Visible = clockOn
	-- the name in the title bar stops short of the clock, the search button and HIDE MENU
	local reserve = (Win.rail and 108 or 124) + 10 + 44 + (clockOn and 54 or 0)
	local brandWidth = (Win.w - 24) - (26 + reserve + 6)
	ui.brand.Size = UDim2.new(1, -(26 + reserve + 6), 0, 22)
	ui.brand.Visible = brandWidth >= 96
	ui.pageTitle.Size = UDim2.new(1, -4, 0, Win.short and 22 or 24)
	ui.pageSub.Size = UDim2.new(1, -4, 0, 18)
end

function Win.applyLayout()
	local ui = Win.ui
	if not ui.body then
		return
	end
	local w, h = Win.w, Win.h
	local rail = w < 520 -- narrow window: smaller HIDE MENU button, no clock
	local short = h < 430
	Win.rail, Win.short = rail, short
	ui.body.Position = UDim2.fromOffset(0, 0)
	ui.body.Size = UDim2.fromOffset(w, h)

	-- one column, top to bottom: title bar (name, clock, HIDE MENU), page title, the page itself, footer
	local pad = 12
	local padTop = short and 6 or 8
	local barH = short and 28 or 32
	local titleH = short and 24 or 44
	local footerH = short and 20 or 24
	local headerH = barH + titleH
	ui.content.Position = UDim2.fromOffset(pad, padTop)
	ui.content.Size = UDim2.fromOffset(math.max(120, w - pad * 2), math.max(60, h - padTop - 5))
	Win.pageW = math.max(120, w - pad * 2) - 7 -- usable width of a page (its scroll bar padding removed)
	ui.handle.Size = UDim2.new(1, 0, 0, headerH)

	-- title bar: the name on the left, clock and HIDE MENU on the right
	ui.logoMark.Instance.Position = UDim2.fromOffset(2, barH / 2)
	ui.brand.Position = UDim2.fromOffset(26, barH / 2)
	Typo.apply(ui.brand, "title", short and 14 or 16)
	local hideW = rail and 108 or 124
	ui.hideButton.Instance.Size = UDim2.fromOffset(hideW, 38)
	ui.hideButton.Instance.Position = UDim2.new(1, 0, 0, (barH - 38) / 2)
	ui.searchButton.Instance.Position = UDim2.new(1, -(hideW + 4), 0, (barH - 40) / 2)
	ui.clock.Position = UDim2.new(1, -(hideW + 4 + 40 + 6), 0, barH / 2)

	-- page title (its description only when there is room)
	Typo.apply(ui.pageTitle, "title", short and 16 or 20)
	ui.pageTitle.Position = UDim2.fromOffset(2, barH + (short and 1 or 2))
	ui.pageSub.Position = UDim2.fromOffset(2, barH + 26)
	ui.pageSub.Visible = not short

	-- the page itself and the footer under it
	ui.pageHost.Position = UDim2.fromOffset(0, headerH)
	ui.pageHost.Size = UDim2.new(1, 0, 1, -(headerH + footerH))
	ui.footer.Size = UDim2.new(1, 0, 0, footerH)

	Win.refreshChrome()
	for _, listener in ipairs(Util.copy(Win.layoutListeners)) do
		Util.try("layout listener", listener, w, h, rail, short)
	end
	if Bg.onResize and (Win.lastBgW ~= w or Win.lastBgH ~= h) then
		Win.lastBgW, Win.lastBgH = w, h
		Bg.onResize()
	end
end

-- A page's scroll offset is in screen pixels, so a new scale would slide its content under the finger (the "+" of the scale
-- stepper would run away from the thumb and end up under the footer). Before the layout changes, note which page is open,
-- how far it is scrolled and where the card at its top edge sits ...
function Win.scrollSnapshot()
	local page = Win.pages[Win.currentTab]
	if not page or not page.Parent or not page:IsA("ScrollingFrame") or page.CanvasPosition.Y <= 1 then
		return nil
	end
	local edge = page.AbsolutePosition.Y
	local anchor, anchorTop
	for _, child in ipairs(page:GetChildren()) do
		if child:IsA("GuiObject") and child.Visible then
			local top = child.AbsolutePosition.Y
			if top + child.AbsoluteSize.Y > edge + 6 and (not anchorTop or top < anchorTop) then
				anchor, anchorTop = child, top
			end
		end
	end
	return { page = page, y = page.CanvasPosition.Y, anchor = anchor, offset = anchor and (anchorTop - edge) or 0 }
end

-- ... then let the offset follow the scale in step with the window glide, and once everything has settled check that the
-- card really is where it should be (fixing what is left, whichever way the engine counts that offset).
function Win.keepScroll(snap, newS, duration)
	local scaler = Win.scaler
	if not snap or not scaler or not snap.page.Parent then
		return
	end
	local liveS = scaler.Scale -- the scale the page is drawn with right now (a glide may still be running)
	if liveS <= 0 or math.abs(newS - liveS) < 1e-4 then
		return
	end
	local ratio = newS / liveS
	Win.scrollToken = (Win.scrollToken or 0) + 1
	local token = Win.scrollToken
	Motion.tween(snap.page, { CanvasPosition = Vector2.new(0, snap.y * ratio) }, duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	if snap.anchor then
		task.delay(duration + 0.12, function()
			if App.destroyed or token ~= Win.scrollToken or not snap.page.Parent or not snap.anchor.Parent then
				return
			end
			local drift = (snap.anchor.AbsolutePosition.Y - snap.page.AbsolutePosition.Y) - snap.offset * ratio
			if math.abs(drift) > 4 and snap.page.CanvasPosition.Y > 1 then
				snap.page.CanvasPosition = Vector2.new(0, math.max(0, snap.page.CanvasPosition.Y + drift))
			end
		end)
	end
end

-- recompute everything for the current viewport / scale / compact setting
function Win.relayout(animate)
	local window = Win.window
	if not window then
		return
	end
	local snap = animate and Win.visible and Win.scrollSnapshot() or nil
	local w, h, s = Win.computeLayout()
	Win.w, Win.h, Win.s = w, h, s
	Win.applyLayout()
	local cw, ch = Win.currentTarget()
	local viewport = Env.viewport()
	local last = Win.lastViewport
	Win.lastViewport = viewport
	if not Win.userMoved then
		-- never dragged: stay centred whatever the screen / scale does (a collapsed window keeps its title bar's height)
		Win.x = viewport.X / 2
		if not Win.minimized then
			Win.top = math.max(10, (viewport.Y - ch * s) / 2)
		end
	elseif last and last.X > 0 and last.Y > 0 and (last.X ~= viewport.X or last.Y ~= viewport.Y) then
		-- dragged somewhere: keep the same relative spot after a rotation / resize
		Win.x = Win.x * viewport.X / last.X
		Win.top = Win.top * viewport.Y / last.Y
	end
	Win.x, Win.top = Win.clampPx(Win.x, Win.top, cw * s, ch * s, true)
	if animate and Win.visible then
		Util.try("keep scroll", Win.keepScroll, snap, s, 0.3)
		Win.glide(Win.x, Win.top, cw, ch, s, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	else
		Motion.set(window, { Position = UDim2.fromOffset(Win.x, Win.top), Size = UDim2.fromOffset(cw, ch) })
		Motion.set(Win.scaler, { Scale = s })
	end
	Win.placeLauncher(animate)
end

function Win.scheduleRelayout()
	Win.relayoutToken = (Win.relayoutToken or 0) + 1
	local token = Win.relayoutToken
	task.delay(0.12, function()
		if token == Win.relayoutToken then
			Win.relayout(true)
		end
	end)
end

function Win.onLayout(listener)
	Win.layoutListeners[#Win.layoutListeners + 1] = listener
end

----------------------------------------------------------------------------------------------------
-- tabs
----------------------------------------------------------------------------------------------------
-- the footer under the page: "<FooterName> - <tab name>"
function Win.updateFooter(title)
	local text = Win.ui.footerText
	if text then
		text.Text = CONFIG.FooterName .. (title and (" - " .. title) or "")
	end
end

function Win.selectTab(id, instant)
	local def, page = Win.tabById[id], Win.pages[id]
	if not def or not page or Win.currentTab == id then
		return false
	end
	UI.closeDropdown(true)
	if Pages.search and Pages.search.isOpen then
		Pages.search.close(false)
	end
	local previous = Win.currentTab
	Win.currentTab = id
	local animate = (not instant) and (not Motion.reduced) and Win.visible
	Util.try("radial tab ring", Win.paintRadial, id, animate)

	local old = previous and Win.pages[previous]
	if old and old ~= page then
		Motion.cancel(old)
		old.Visible = false
		old.Position = UDim2.fromScale(0, 0)
	end
	page.Visible = true
	if animate then
		page.Position = UDim2.fromOffset(0, 16)
		Motion.tween(page, { Position = UDim2.fromScale(0, 0) }, 0.28, Enum.EasingStyle.Quart)
	else
		Motion.set(page, { Position = UDim2.fromScale(0, 0) })
	end

	local ui = Win.ui
	ui.pageTitle.Text = def.title
	ui.pageSub.Text = def.desc
	Win.updateFooter(def.title)
	if animate then
		ui.pageTitle.TextTransparency = 0.8
		ui.pageSub.TextTransparency = 0.8
		Motion.tween(ui.pageTitle, { TextTransparency = 0 }, 0.25)
		Motion.tween(ui.pageSub, { TextTransparency = 0 }, 0.32)
	end
	if previous then
		Sfx.play("tab")
	end
	return true
end

function Win.addPage(id)
	local page = UI.page(Win.ui.pageHost, id)
	Win.pages[id] = page
	return page
end

----------------------------------------------------------------------------------------------------
-- show / hide / minimize / recenter
----------------------------------------------------------------------------------------------------
function Win.show(instant)
	local window, scaler = Win.window, Win.scaler
	if not window or Win.visible then
		return
	end
	Win.visible = true
	window.Visible = true
	Notify.markRead() -- whatever came in while the window was hidden is on the Overview page now
	Win.updateOrb()
	local cw, ch = Win.currentTarget()
	if instant or Motion.reduced then
		Motion.set(window, { Position = UDim2.fromOffset(Win.x, Win.top), Size = UDim2.fromOffset(cw, ch) })
		Motion.set(scaler, { Scale = Win.s })
	else
		local ox, oy = Win.orbSpot(true)
		if ox then
			-- the window pours out of the logo: it starts tiny, right under the orb, and grows with a small spring
			local fromScale = Win.s * Win.GENIE_SCALE
			Motion.set(scaler, { Scale = fromScale })
			Motion.set(window, { Position = UDim2.fromOffset(ox, oy - ch * fromScale / 2), Size = UDim2.fromOffset(cw, ch) })
			Win.glide(Win.x, Win.top, cw, ch, Win.s, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		else
			local fromScale = Win.s * 0.9
			Motion.set(scaler, { Scale = fromScale })
			Motion.set(window, {
				Position = UDim2.fromOffset(Win.x, Win.top + ch * (Win.s - fromScale) / 2 + 10),
				Size = UDim2.fromOffset(cw, ch),
			})
			Win.glide(Win.x, Win.top, cw, ch, Win.s, 0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		end
	end
	Sfx.play("open")
	Bg.syncBlur()
end

function Win.hide(instant)
	local window = Win.window
	if not window or not Win.visible then
		return
	end
	Win.visible = false
	Win.closeRing(instant, true)
	Win.updateOrb()
	UI.closeDropdown(true)
	UI.closeModal(true)
	if Pages.search and Pages.search.isOpen then
		Pages.search.close(true)
	end
	UI.endSessions()
	Sfx.play("close")
	local function finish()
		if not Win.visible and Win.window then
			Win.window.Visible = false
		end
	end
	if instant or Motion.reduced then
		finish()
	else
		local cw, ch = Win.currentTarget()
		local ox, oy = Win.orbSpot(false)
		if ox then
			-- the window is drawn into the logo (it shrinks to a speck under the orb) and the orb gives a small pulse
			local toScale = Win.s * Win.GENIE_SCALE
			-- Back/In: a small breath outward first, then it collapses into the logo
			Win.glide(ox, oy - ch * toScale / 2, cw, ch, toScale, 0.34, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
				finish()
				if not Win.visible then
					Win.pulseOrb()
				end
			end)
		else
			local toScale = Win.s * 0.92
			Win.glide(Win.x, Win.top + ch * (Win.s - toScale) / 2 + 8, cw, ch, toScale, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In, finish)
		end
	end
	Bg.syncBlur()
end

-- Where the orb is, in screen pixels: its centre right now (current = true) or the spot where it rests while the ring is closed.
-- nil when there is no orb (the window then shows and hides around its own centre).
function Win.orbSpot(current)
	local launcher = Win.launcher
	if not launcher or not launcher.root or not launcher.root.Parent or not launcher.shown then
		return nil
	end
	if current then
		local position = launcher.root.Position
		return position.X.Offset, position.Y.Offset
	end
	local x, y = Win.launcherRest()
	return Win.clampLauncher(x, y, false)
end

-- a small jelly pulse of the orb when the window has been drawn into it
function Win.pulseOrb()
	local launcher = Win.launcher
	if not launcher or not launcher.root or not launcher.root.Parent or Motion.reduced then
		return
	end
	local k = Win.launcherScale()
	Motion.tween(launcher.scale, { Scale = k * 1.18 }, 0.09, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, function()
		if launcher.root.Parent then
			Motion.tween(launcher.scale, { Scale = k }, 0.55, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
		end
	end)
end

function Win.toggle()
	if Win.visible then
		Win.hideMenu()
	else
		Win.show()
	end
end

-- HIDE MENU: hides the window (and closes the tab ring). Tap the logo to bring the menu back.
function Win.hideMenu()
	Win.hide()
end

-- older callers asked for a collapsed window; the window is now simply hidden or shown
function Win.setMinimized(flag, instant)
	if flag then
		Win.hide(instant)
	else
		Win.show(instant)
	end
end

function Win.recenter()
	if not Win.window then
		return
	end
	local viewport = Env.viewport()
	local cw, ch = Win.currentTarget()
	Win.userMoved = false
	Win.lastViewport = viewport
	local x = viewport.X / 2
	local top = math.max(10, (viewport.Y - ch * Win.s) / 2)
	Win.x, Win.top = Win.clampPx(x, top, cw * Win.s, ch * Win.s, true)
	Win.kbShift = 0
	Win.glide(Win.x, Win.top, cw, ch, Win.s, 0.42, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	Win.resetLauncher()
end

-- there is no footer card any more; the notices are listed on the Information page
function Win.setStatus(text, role)
	Win.statusText, Win.statusRole = text, role
end

function Win.applyPerformance()
	local lowPower = Store.get("lowPower")
	for _, shadow in ipairs(Win.ui.shadows or {}) do
		shadow.Visible = not lowPower
	end
	local launcher = Win.launcher
	if launcher and launcher.shadows then
		for _, shadow in ipairs(launcher.shadows) do
			shadow.Visible = not lowPower
		end
	end
end

----------------------------------------------------------------------------------------------------
-- on-screen keyboard (Android): keep the focused text box visible
----------------------------------------------------------------------------------------------------
function Win.avoidKeyboard(holder)
	local visible = false
	pcall(function()
		visible = UserInputService.OnScreenKeyboardVisible
	end)
	if not visible or not Win.window then
		return
	end
	local ok, position = pcall(function()
		return UserInputService.OnScreenKeyboardPosition
	end)
	if not ok or typeof(position) ~= "Vector2" then
		return
	end
	local bottom = holder.AbsolutePosition.Y + holder.AbsoluteSize.Y + 14
	local overshoot = bottom - position.Y
	if overshoot <= 0 then
		return
	end
	local shift = math.min(overshoot, math.max(0, Win.top))
	if shift <= 0 then
		return
	end
	Win.kbShift = shift
	Motion.tween(Win.window, { Position = UDim2.fromOffset(Win.x, Win.top - shift) }, 0.24, Enum.EasingStyle.Quart)
end

function Win.releaseKeyboard()
	if Win.kbShift > 0 and Win.window then
		Win.kbShift = 0
		Motion.tween(Win.window, { Position = UDim2.fromOffset(Win.x, Win.top) }, 0.24, Enum.EasingStyle.Quart)
	end
end

-- called by UI.input
function Win.onInputFocus(holder, focused)
	if not Env.touch or not Win.window then
		return
	end
	Win.focusToken = Win.focusToken + 1
	local token = Win.focusToken
	if focused then
		task.delay(0.45, function()
			if token == Win.focusToken and holder.Parent then
				Win.avoidKeyboard(holder)
			end
		end)
	else
		Win.releaseKeyboard()
	end
end

----------------------------------------------------------------------------------------------------
-- construction
----------------------------------------------------------------------------------------------------
local function label(parent, props, role, size, color)
	local obj = Util.new("TextLabel", props, parent)
	Typo.apply(obj, role, size)
	if color then
		Theme.bind(obj, "TextColor3", color)
	end
	return obj
end

-- HIDE MENU: a glass pill with a slowly turning accent edge, a danger-tinted chevron badge and a soft glow.
-- It hides the window; the orb (the draggable logo) brings it back.
local function buildHideButton(content)
	local hit = Util.new("TextButton", {
		Name = "HideMenu", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.fromOffset(124, 38), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, -3), ZIndex = 4,
	}, content)

	-- soft glow: two translucent accent pills behind the plate (no image assets, no blur)
	for index, spec in ipairs({ { 8, 0.92 }, { 16, 0.96 } }) do
		local glow = Util.new("Frame", {
			Name = "Glow" .. index, Active = false, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 2), Size = UDim2.new(1, spec[1], 0, 30 + spec[1]),
			BackgroundTransparency = spec[2], ZIndex = 3,
		}, hit)
		Util.round_corner(glow)
		Theme.bind(glow, "BackgroundColor3", "Accent")
	end

	-- the plate: a light-to-dark glass gradient inside a turning accent edge
	local face = Util.new("Frame", {
		Name = "Face", Active = false, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, 0, 0, 30), BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 5,
	}, hit)
	Util.round_corner(face)
	Theme.gradient(Util.new("UIGradient", { Rotation = 90 }, face), Theme.G.plate)
	local edge = Util.stroke(face, nil, 1.5, 0.1)
	local edgeGradient = Util.new("UIGradient", { Rotation = 0 }, edge)
	Theme.gradient(edgeGradient, Theme.G.stroke)
	Theme.fxSpin(edgeGradient, 40, 2)

	-- chevron badge (danger tint: this button closes the window)
	local badge = Util.new("Frame", {
		Name = "Badge", Active = false, BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 5, 0.5, 0),
		Size = UDim2.fromOffset(20, 20), BackgroundTransparency = 0.78, ZIndex = 6,
	}, face)
	Util.round_corner(badge)
	Theme.bind(badge, "BackgroundColor3", "Danger")
	Theme.bind(Util.stroke(badge, nil, 1, 0.55), "Color", "Danger")
	UI.icon("chevron", badge, 14, "Danger", { anchor = Vector2.new(0.5, 0.5), position = UDim2.fromScale(0.5, 0.5), zindex = 7 })

	local caption = label(face, {
		Name = "Label", BackgroundTransparency = 1, Position = UDim2.fromOffset(31, 0), Size = UDim2.new(1, -37, 1, 0),
		Text = "HIDE MENU", TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 6,
	}, "label", 11, "Text")

	-- a thin light band that sweeps across now and then (accent motion "full" only)
	local glint = Util.new("Frame", {
		Name = "Glint", Active = false, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1),
		ZIndex = 7,
	}, face)
	Util.round_corner(glint)
	Theme.bind(glint, "BackgroundColor3", "Shine")
	local glintGradient = Util.new("UIGradient", {
		Rotation = 20,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.4, 1), NumberSequenceKeypoint.new(0.5, 0.82),
			NumberSequenceKeypoint.new(0.6, 1), NumberSequenceKeypoint.new(1, 1),
		}),
	}, glint)
	Theme.fxSweep(glintGradient, 7, 0.55, 2, 0.3)

	local state = UI.pressable(hit, face, { radius = 15, overlayRole = "Text", pressScale = 0.96, hoverAlpha = 0.93, pressAlpha = 0.84 })
	local last = 0
	hit.Activated:Connect(function()
		if state.wasDrag() then
			return
		end
		local now = os.clock()
		if now - last < 0.3 then
			return
		end
		last = now
		Win.hideMenu() -- Win.hide plays the close sound
	end)
	return { Instance = hit, Face = face, Label = caption }
end

-- The jump search button: a small glass circle with a magnifier, left of HIDE MENU. It opens the search sheet.
local function buildSearchButton(content)
	local hit = Util.new("TextButton", {
		Name = "SearchButton", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.fromOffset(40, 40), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -132, 0, -4), ZIndex = 4,
	}, content)
	-- the touch area is a little larger than the circle you see
	local face = Util.new("Frame", {
		Name = "Face", Active = false, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(32, 32), BorderSizePixel = 0, ZIndex = 5,
	}, hit)
	Util.round_corner(face)
	Theme.surface(face, "Card", "card")
	local stroke = Util.stroke(face, nil, 1, 0.3)
	UI.glass(face, { strength = 0.8, zindex = 6, edge = true, stroke = stroke })
	local icon = UI.icon("search", face, 17, "Text", {
		anchor = Vector2.new(0.5, 0.5), position = UDim2.fromScale(0.5, 0.5), zindex = 7,
	})
	local state = UI.pressable(hit, face, { radius = UDim.new(0.5, 0), hoverAlpha = 0.92, pressAlpha = 0.82, pressScale = 0.92 })
	local last = 0
	hit.Activated:Connect(function()
		if state.wasDrag() then
			return
		end
		local now = os.clock()
		if now - last < 0.3 then
			return
		end
		last = now
		if Pages.search then
			Pages.search.toggle()
		end
	end)
	return { Instance = hit, Face = face, Icon = icon }
end

-- The page header: drag handle (move the window), clock, search button and HIDE MENU. The page title and subtitle are
-- created next to it in Win.create.
local function buildHeader(content)
	local ui = Win.ui
	local handle = Util.new("TextButton", {
		Name = "DragHandle", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 58), ZIndex = 2,
	}, content)
	ui.handle = handle

	-- the name, top left (the old title bar's "VIREX / HUB"): a small logo mark and the text.
	-- They sit above the drag handle, so dragging them still moves the window.
	ui.logoMark = UI.icon("logo", content, 18, "Accent", {
		anchor = Vector2.new(0, 0.5), position = UDim2.fromOffset(2, 14), zindex = 3,
	})
	ui.brand = label(content, {
		Name = "Brand", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromOffset(26, 14),
		Size = UDim2.new(1, -150, 0, 22), Text = CONFIG.Title, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3,
	}, "title", 16, "Text")

	ui.clock = label(content, {
		Name = "Clock", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -134, 0, 16),
		Size = UDim2.fromOffset(52, 20), Text = os.date("%H:%M"), TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 4,
	}, "buttonSmall", 12, "Muted")

	ui.hideButton = buildHideButton(content)
	ui.searchButton = buildSearchButton(content)

	-- dragging the header moves the window: threshold first, so a tap never moves it
	handle.InputBegan:Connect(function(input)
		if not UI.isPress(input) or not Win.window then
			return
		end
		Motion.cancel(Win.window, { Position = true })
		Win.releaseKeyboard()
		local startX, startTop = Win.window.Position.X.Offset, Win.window.Position.Y.Offset
		local origin = input.Position
		local moved = false
		UI.watchInput(input, function(i)
			local dx, dy = i.Position.X - origin.X, i.Position.Y - origin.Y
			if not moved then
				if math.abs(dx) + math.abs(dy) < 6 then
					return
				end
				moved = true
				Win.userMoved = true
				UI.closeDropdown(true)
			end
			local size = Win.window.AbsoluteSize
			local nx, ny = Win.clampPx(startX + dx, startTop + dy, size.X, size.Y)
			Win.x, Win.top = nx, ny
			Win.window.Position = UDim2.fromOffset(nx, ny)
		end)
	end)
end

----------------------------------------------------------------------------------------------------
-- The launcher: the draggable logo (an orb) and the tab ring around it.
--   tap the orb    opens the ring of tab chips around it (tap it again to close the ring)
--   tap a chip     shows that tab's page in the window
--   drag the orb   moves it (and the ring with it); the spot is remembered
-- If the ring cannot be built for any reason, the orb steps through the tabs instead, so the hub stays usable.
----------------------------------------------------------------------------------------------------
-- one chip: plate colour, ink colour (icon + name), the accent fill / diamond / glow of the chosen tab, press scale
local function paintChip(chip, animate)
	local seconds = animate and 0.18 or 0
	local selected = chip.selected
	local ink, mixT = "Muted", nil
	if selected then
		ink = "OnAccent"
	elseif chip.pressed then
		ink, mixT = "Text", 0.16
	elseif chip.hover > 0 then
		ink, mixT = "Text", 0.08
	end
	Theme.tweenRole(chip.plate, "BackgroundColor3", "Card", seconds, mixT and "Text" or nil, mixT)
	Motion.tween(chip.fill, { BackgroundTransparency = selected and 0 or 1 }, seconds)
	Motion.tween(chip.top, { BackgroundTransparency = selected and 0.62 or 1 }, seconds)
	Motion.tween(chip.mark, { BackgroundTransparency = selected and 0.45 or 1 }, seconds)
	Motion.tween(chip.glowNear, { BackgroundTransparency = selected and 0.9 or 1 }, seconds)
	Motion.tween(chip.glowFar, { BackgroundTransparency = selected and 0.955 or 1 }, seconds)
	chip.glint.Visible = selected
	chip.icon.SetRole(ink, seconds)
	Theme.tweenRole(chip.label, "TextColor3", ink, seconds)
	if chip.pressed then
		Motion.tween(chip.press, { Scale = 0.95 }, 0.07)
	else
		Motion.tween(chip.press, { Scale = 1 }, 0.2, Enum.EasingStyle.Back)
	end
end

-- screen pixels per design unit: the ring must fit the screen, and follows the UI scale setting
function Win.launcherScale()
	local viewport = Env.viewport()
	local halfW, halfH = Win.ringExtent()
	local fit = math.min((viewport.X - 12) / (halfW * 2 + 8), (viewport.Y - 12) / (halfH * 2 + 8))
	return math.max(0.5, math.min(Win.LOGO_SCALE * Store.get("scale"), fit))
end

-- keeps the orb (or, while the ring is open, the whole ring) on screen
function Win.clampLauncher(x, y, withRing)
	local viewport = Env.viewport()
	local R = Win.RING
	local k = Win.launcherScale()
	local reachX, reachY
	if withRing then
		local halfW, halfH = Win.ringExtent()
		reachX, reachY = (halfW + R.margin) * k, (halfH + R.margin) * k
	else
		reachX = (R.hubR + 8) * k
		reachY = reachX
	end
	reachX = math.min(reachX, viewport.X / 2)
	reachY = math.min(reachY, viewport.Y / 2)
	return Util.clamp(x, reachX, viewport.X - reachX), Util.clamp(y, reachY, viewport.Y - reachY)
end

-- where the orb rests while the ring is closed (screen pixels)
function Win.launcherRest()
	local viewport = Env.viewport()
	local fx, fy = Store.get("logoX"), Store.get("logoY")
	if fx >= 0 and fy >= 0 then
		return fx * viewport.X, fy * viewport.Y
	end
	-- not placed yet: top right corner (the Roblox menu buttons are on the left)
	local hubR = Win.RING.hubR * Win.launcherScale()
	return viewport.X - hubR - 16, hubR + 14
end

function Win.placeLauncher(animate)
	local launcher = Win.launcher
	if not launcher or not launcher.root.Parent then
		return
	end
	local x, y = Win.launcherRest()
	x, y = Win.clampLauncher(x, y, Win.ringOpen)
	local seconds = animate and 0.25 or 0
	Motion.tween(launcher.scale, { Scale = Win.launcherScale() }, launcher.shown and seconds or 0)
	Motion.tween(launcher.root, { Position = UDim2.fromOffset(x, y) }, seconds, Enum.EasingStyle.Quart)
end

function Win.showLauncher()
	local launcher = Win.launcher
	if not launcher or launcher.shown then
		return
	end
	Win.placeLauncher(false)
	launcher.shown = true
	launcher.root.Visible = true
	local k = launcher.scale.Scale
	Motion.set(launcher.scale, { Scale = k * 0.5 })
	Motion.tween(launcher.scale, { Scale = k }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

function Win.saveLauncher()
	local launcher = Win.launcher
	if not launcher then
		return
	end
	local viewport = Env.viewport()
	Store.set("logoX", Util.clamp(launcher.root.Position.X.Offset / viewport.X, 0, 1))
	Store.set("logoY", Util.clamp(launcher.root.Position.Y.Offset / viewport.Y, 0, 1))
end

function Win.resetLauncher()
	Store.set("logoX", -1)
	Store.set("logoY", -1)
	Win.placeLauncher(true)
end

-- the chips pop out of the orb one after another (and slide back into it when the ring closes)
function Win.openRing(silent)
	local launcher = Win.launcher
	if not launcher or not launcher.ring or Win.ringOpen then
		return
	end
	Win.ringOpen = true
	launcher.ringToken = launcher.ringToken + 1
	local token = launcher.ringToken
	Win.placeLauncher(true) -- slides the orb inwards when the ring would hang over a screen edge
	launcher.ring.Visible = true
	for index, chip in ipairs(Win.radial.chips) do
		Motion.set(chip.slot, { Position = launcher.centre })
		Motion.set(chip.pop, { Scale = 0.3 })
		local function out()
			if token ~= launcher.ringToken or not Win.ringOpen or not chip.slot.Parent then
				return
			end
			Motion.tween(chip.slot, { Position = chip.home }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			Motion.tween(chip.pop, { Scale = 1 }, 0.26, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		end
		local delay = (index - 1) * Win.RING.stagger
		if delay > 0 and not Motion.reduced then
			task.delay(delay, out)
		else
			out()
		end
	end
	if not silent then
		Sfx.play("open")
	end
end

function Win.closeRing(instant, silent)
	local launcher = Win.launcher
	if not launcher or not launcher.ring or not Win.ringOpen then
		return
	end
	Win.ringOpen = false
	launcher.ringToken = launcher.ringToken + 1
	local token = launcher.ringToken
	local ring = launcher.ring
	local function finish()
		if token == launcher.ringToken and not Win.ringOpen and ring.Parent then
			ring.Visible = false
		end
	end
	if instant or Motion.reduced then
		finish()
	else
		local chips = Win.radial.chips
		for index, chip in ipairs(chips) do
			Motion.tween(chip.slot, { Position = launcher.centre }, 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
			Motion.tween(chip.pop, { Scale = 0.3 }, 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.In, index == #chips and finish or nil)
		end
	end
	Win.placeLauncher(not instant) -- back to where the orb was resting
	if not silent then
		Sfx.play("close")
	end
end

function Win.toggleRing()
	if Win.ringOpen then
		Win.closeRing()
	else
		Win.openRing()
	end
end

-- A tap on the orb ONLY opens or closes the tab ring. It never opens the window: the window (the menu of a tab)
-- comes out when a tab in the ring is tapped (see buildLauncher).
function Win.tapLogo()
	if not Win.window then
		return
	end
	if not Win.radial then
		-- the ring could not be built: the orb steps through the tabs instead, so the hub stays usable
		local index = (Win.tabIndex[Win.currentTab] or 0) % #Win.tabList + 1
		Win.show()
		Win.selectTab(Win.tabList[index].id)
		return
	end
	Win.toggleRing()
end

function Win.paintRadial(id, animate)
	local radial = Win.radial
	if not radial then
		return
	end
	for _, chip in ipairs(radial.chips) do
		local selected = chip.id == id
		if chip.selected ~= selected then
			chip.selected = selected
			paintChip(chip, animate)
		end
	end
end

-- the badge on the orb counts what arrived while the window was hidden; the ring around it pulses (accent motion on)
function Win.updateOrb()
	local launcher = Win.launcher
	if not launcher or not launcher.badge or not launcher.root.Parent then
		return
	end
	local unread = Notify.unread or 0
	local show = unread > 0 and not Win.visible
	launcher.badge.Visible = show
	if show then
		local text = unread > 9 and "9+" or tostring(unread)
		launcher.badgeText.Text = text
		launcher.badge.Size = UDim2.fromOffset(#text > 1 and 24 or 18, 18)
	end
	local lively = show and Store.get("fx") > 0 and not Store.get("reducedMotion") and not Store.get("lowPower")
	if lively then
		if not Anim.has("orbPulse") then
			launcher.pulse.Visible = true
			Anim.add("orbPulse", function(_, now)
				local phase = (now % 1.8) / 1.8
				launcher.pulseScale.Scale = 0.82 + 0.53 * phase
				launcher.pulseStroke.Transparency = 0.2 + 0.8 * phase
			end, 30)
		end
	else
		Anim.remove("orbPulse")
		launcher.pulse.Visible = false
	end
end

local function buildLauncher(gui)
	local R = Win.RING
	local hubD = R.hubR * 2
	local function at(x, y)
		return UDim2.new(0.5, x, 0.5, y)
	end

	local root = Util.new("Frame", {
		Name = "Launcher", BackgroundTransparency = 1, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(300, 60), Size = UDim2.fromOffset(hubD, hubD), ZIndex = 20, Visible = false,
	}, gui)
	local launcher = { root = root, scale = Util.new("UIScale", { Scale = 1 }, root), shown = false, ringToken = 0, centre = at(0, 0) }
	Win.launcher = launcher

	-- the ring: one chip per tab around the orb, hidden until the orb is tapped
	local ring
	local ok, err = pcall(function()
		local plan = Win.ringPlan(#Win.tabList)
		ring = Util.new("Frame", {
			Name = "Ring", BackgroundTransparency = 1, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(hubD, hubD), ZIndex = 1, Visible = false,
		}, root)
		local glint = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.38, 1), NumberSequenceKeypoint.new(0.5, 0.45),
			NumberSequenceKeypoint.new(0.62, 1), NumberSequenceKeypoint.new(1, 1),
		})

		local chips = {}
		for index, def in ipairs(Win.tabList) do
			local home = at(plan[index][1], plan[index][2])
			local slot = Util.new("Frame", {
				Name = def.title .. "Slot", BackgroundTransparency = 1, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
				Position = home, Size = UDim2.fromOffset(R.chipW, R.chipH), ZIndex = 4,
			}, ring)
			local chip = { id = def.id, slot = slot, home = home, selected = false, pressed = false, hover = 0 }
			chip.pop = Util.new("UIScale", { Scale = 1 }, slot)

			-- glow of the chosen chip: two translucent accent pills behind the plate
			local function glow(name, grow)
				local frame = Util.new("Frame", {
					Name = name, Active = false, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.5, 0, 0.5, 3), Size = UDim2.new(1, grow, 1, grow), BackgroundTransparency = 1, ZIndex = 3,
				}, slot)
				Util.corner(frame, (R.chipH + grow) / 2)
				Theme.bind(frame, "BackgroundColor3", "Accent")
				return frame
			end
			chip.glowFar = glow("GlowFar", 14)
			chip.glowNear = glow("GlowNear", 7)

			-- the plate: what you see
			local plate = Util.new("Frame", {
				Name = def.title .. "Plate", Active = false, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 0.14,
				ZIndex = 5,
			}, slot)
			Util.corner(plate, 10)
			Theme.bind(plate, "BackgroundColor3", "Card")
			Theme.bind(Util.stroke(plate, nil, 1, 0.3), "Color", "Border")
			chip.press = Util.new("UIScale", { Scale = 1 }, plate)
			chip.plate = plate

			-- the chosen tab: accent gradient, a thin highlight along the top, a diamond marker, a light sweep
			chip.fill = Util.new("Frame", {
				Name = "Fill", Active = false, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 1, ZIndex = 6,
			}, plate)
			Util.corner(chip.fill, 10)
			Theme.gradient(Util.new("UIGradient", { Rotation = 30 }, chip.fill), Theme.G.accent)
			chip.top = Util.new("Frame", {
				Name = "Top", Active = false, BorderSizePixel = 0, Position = UDim2.new(0, 8, 0, 1), Size = UDim2.new(1, -16, 0, 1),
				BackgroundTransparency = 1, ZIndex = 7,
			}, plate)
			Theme.bind(chip.top, "BackgroundColor3", "Shine")
			chip.mark = Util.new("Frame", {
				Name = "Mark", Active = false, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 10, 0.5, 0),
				Size = UDim2.fromOffset(5, 5), Rotation = 45, BackgroundTransparency = 1, ZIndex = 7,
			}, plate)
			Util.corner(chip.mark, 1)
			Theme.bind(chip.mark, "BackgroundColor3", "OnAccent")
			chip.glint = Util.new("Frame", {
				Name = "Glint", Active = false, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1),
				ZIndex = 7, Visible = false,
			}, plate)
			Util.corner(chip.glint, 10)
			Theme.bind(chip.glint, "BackgroundColor3", "Shine")
			local sweep = Util.new("UIGradient", { Rotation = 20, Transparency = glint }, chip.glint)
			Theme.fxSweep(sweep, 5.5, 0.5, 1, (index - 1) * 0.13)

			chip.icon = UI.icon(def.icon, plate, R.iconSize, "Muted", {
				anchor = Vector2.new(0.5, 0.5), position = UDim2.new(0, 26, 0.5, 0), zindex = 8,
			})
			chip.label = label(plate, {
				Name = def.title .. "Label", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 38, 0.5, 0), Size = UDim2.new(1, -42, 0, 16), Text = def.title,
				TextXAlignment = Enum.TextXAlignment.Left, TextScaled = true, TextWrapped = false, ZIndex = 8,
			}, "tab", 11, "Muted")
			Util.new("UITextSizeConstraint", { MinTextSize = 7, MaxTextSize = 11 }, chip.label)

			-- the touch target: a little bigger than the plate, so a thumb does not have to be exact
			local button = Util.new("TextButton", {
				Name = def.title .. "Tab", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, 8, 1, 10), ZIndex = 9,
			}, slot)
			chip.button = button

			button.Activated:Connect(function()
				-- the tab's menu comes out now, not when the orb was tapped
				if not Win.visible then
					Win.show()
				end
				Win.selectTab(def.id)
				if Win.CLOSE_RING_ON_PICK then
					Win.closeRing(false, true) -- silent: the tab sound already played
				end
			end)
			button.InputBegan:Connect(function(input)
				if not UI.isPress(input) then
					return
				end
				chip.pressed = true
				paintChip(chip, true)
				UI.watchInput(input, nil, function()
					chip.pressed = false
					paintChip(chip, true)
				end)
			end)
			if UserInputService.MouseEnabled then
				button.MouseEnter:Connect(function()
					chip.hover = chip.hover + 1
					paintChip(chip, true)
				end)
				button.MouseLeave:Connect(function()
					chip.hover = math.max(0, chip.hover - 1)
					paintChip(chip, true)
				end)
			end
			chips[index] = chip
			paintChip(chip, false)
		end
		launcher.ring = ring
		Win.radial = { chips = chips }
	end)
	if not ok then
		Util.log("error", "tab ring: " .. tostring(err))
		if ring then
			pcall(ring.Destroy, ring)
		end
		launcher.ring, Win.radial = nil, nil
	end

	-- the orb: the draggable logo, in the look of the index orb (a soft-to-dark disc, an accent ring, a sheen and the mark)
	launcher.shadows = {}
	for index, spec in ipairs({ { 8, 0.8, 4 }, { 18, 0.88, 6 }, { 30, 0.94, 8 } }) do
		local shadow = Util.new("Frame", {
			Name = "OrbShadow" .. index, Active = false, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
			Position = at(0, spec[3]), Size = UDim2.fromOffset(hubD + spec[1], hubD + spec[1]),
			BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = spec[2], ZIndex = 6,
		}, root)
		Util.round_corner(shadow)
		launcher.shadows[index] = shadow
	end

	-- pulse ring (shown while notifications wait for you)
	launcher.pulse = Util.new("Frame", {
		Name = "OrbPulse", Active = false, BackgroundTransparency = 1, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = at(0, 0), Size = UDim2.fromOffset(hubD + 12, hubD + 12), ZIndex = 6, Visible = false,
	}, root)
	Util.round_corner(launcher.pulse)
	launcher.pulseStroke = Util.stroke(launcher.pulse, nil, 2, 1)
	Theme.bind(launcher.pulseStroke, "Color", "Accent")
	launcher.pulseScale = Util.new("UIScale", { Scale = 1 }, launcher.pulse)

	local hub = Util.new("TextButton", {
		Name = "Hub", Text = "", AutoButtonColor = false, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = at(0, 0), Size = UDim2.fromOffset(hubD, hubD), BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 7,
	}, root)
	Util.round_corner(hub)
	Theme.gradient(Util.new("UIGradient", { Rotation = 55 }, hub), Theme.G.orb)
	Theme.bind(Util.stroke(hub, nil, 1.5, 0.35), "Color", "Accent")
	local hubPress = Util.new("UIScale", { Scale = 1 }, hub)
	-- sheen: a faint light lens across the top half of the disc
	local sheen = Util.new("Frame", {
		Name = "Sheen", Active = false, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 3),
		Size = UDim2.new(0.74, 0, 0.42, 0), BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 8,
	}, hub)
	Util.round_corner(sheen)
	Theme.bind(sheen, "BackgroundColor3", "Shine")
	Util.new("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.88), NumberSequenceKeypoint.new(1, 1) }),
	}, sheen)
	UI.icon("logo", hub, 32, "Shine", {
		anchor = Vector2.new(0.5, 0.5), position = UDim2.fromScale(0.5, 0.5), zindex = 9,
	})
	launcher.hub = hub

	-- unread badge
	launcher.badge = Util.new("Frame", {
		Name = "OrbBadge", Active = false, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Position = at(21, -21),
		Size = UDim2.fromOffset(18, 18), ZIndex = 12, Visible = false,
	}, root)
	Util.round_corner(launcher.badge)
	Theme.bind(launcher.badge, "BackgroundColor3", "Accent")
	Theme.bind(Util.stroke(launcher.badge, nil, 2, 0), "Color", "Background")
	launcher.badgeText = label(launcher.badge, {
		Name = "Count", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "1", ZIndex = 13,
	}, "label", 10, "OnAccent")

	-- drag to move (threshold first), tap to open / close the ring
	hub.InputBegan:Connect(function(input)
		if not UI.isPress(input) then
			return
		end
		Motion.cancel(root, { Position = true })
		Motion.tween(hubPress, { Scale = 0.92 }, 0.07)
		local origin = input.Position
		local startX, startY = root.Position.X.Offset, root.Position.Y.Offset
		local moved = false
		UI.watchInput(input, function(i)
			local dx, dy = i.Position.X - origin.X, i.Position.Y - origin.Y
			if not moved then
				if math.abs(dx) + math.abs(dy) < 8 then
					return
				end
				moved = true
			end
			local nx, ny = Win.clampLauncher(startX + dx, startY + dy, Win.ringOpen)
			root.Position = UDim2.fromOffset(nx, ny)
		end, function(cancelled)
			Motion.tween(hubPress, { Scale = 1 }, 0.22, Enum.EasingStyle.Back)
			if moved then
				Win.saveLauncher()
			elseif not cancelled then
				Win.tapLogo()
			end
		end)
	end)
end

-- (VirexUI) the launcher is built from Win.tabList, so it is built again when tabs are added after the window exists
function Win.rebuildLauncher()
	if not Win.gui or not Win.window then
		return
	end
	local old = Win.launcher
	local wasShown = old and old.shown
	local wasOpen = Win.ringOpen
	if old and old.root then
		pcall(old.root.Destroy, old.root)
	end
	Anim.remove("orbPulse")
	Win.launcher, Win.radial, Win.ringOpen = nil, nil, false
	buildLauncher(Win.gui)
	local launcher = Win.launcher
	if launcher then
		Win.placeLauncher(false)
		if wasShown then
			launcher.shown = true
			launcher.root.Visible = true
		end
		Win.paintRadial(Win.currentTab, false)
		Win.updateOrb()
		if wasOpen and launcher.ring then
			Win.openRing(true)
		end
	end
	if Win.applyPerformance then
		pcall(Win.applyPerformance)
	end
end

-- Builds the whole window inside `gui` (a ScreenGui). Pages are added later with Win.addPage.
function Win.create(gui)
	Win.destroy()
	local maid = Maid.new()
	Win.maid = maid
	Win.gui = gui
	local ui = {}
	Win.ui = ui
	Win.nav, Win.pages, Win.currentTab = {}, {}, nil
	Win.radial, Win.launcher = nil, nil
	Win.visible, Win.minimized, Win.ringOpen = false, false, false

	local w, h, s = Win.computeLayout()
	Win.w, Win.h, Win.s = w, h, s
	local viewport = Env.viewport()
	Win.x, Win.top = Win.clampPx(viewport.X / 2, math.max(10, (viewport.Y - h * s) / 2), w * s, h * s, true)
	Win.userMoved, Win.lastViewport = false, viewport

	local window = Util.new("Frame", {
		Name = "Window", AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.fromOffset(Win.x, Win.top), Size = UDim2.fromOffset(w, h), Visible = false, ZIndex = 1,
	}, gui)
	Win.window = window
	Win.scaler = Util.new("UIScale", { Scale = s }, window)

	-- soft shadow: a few translucent rounded rectangles behind the surface (no image assets needed)
	ui.shadows = {}
	for i, spec in ipairs({ { 3, 0.92 }, { 8, 0.95 }, { 14, 0.968 }, { 22, 0.982 } }) do
		local grow = spec[1]
		local shadow = Util.new("Frame", {
			Name = "Shadow" .. i, BorderSizePixel = 0, BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = spec[2],
			Position = UDim2.fromOffset(-grow, -grow + 8), Size = UDim2.new(1, grow * 2, 1, grow * 2), ZIndex = i,
		}, window)
		Util.corner(shadow, 16 + grow)
		ui.shadows[i] = shadow
	end

	local surface = Util.new("Frame", {
		Name = "Surface", BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ClipsDescendants = true, Active = true, ZIndex = 10,
	}, window)
	Theme.surface(surface, "Background", "bg")
	Util.corner(surface, 16)
	local stroke = Util.new("UIStroke", { Thickness = 1.5, Transparency = 0.1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, surface)
	local strokeGradient = Util.new("UIGradient", { Rotation = 0 }, stroke)
	Theme.gradient(strokeGradient, Theme.G.stroke)
	Theme.fxSpin(strokeGradient, 24, 2)
	ui.surface = surface

	local bgLayer = Util.new("Frame", {
		Name = "BgLayer", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 1,
	}, surface)
	Bg.init(bgLayer)

	local body = Util.new("Frame", {
		Name = "Body", BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromOffset(w, h), ZIndex = 5,
	}, surface)
	ui.body = body

	local content = Util.new("Frame", { Name = "Content", BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 2 }, body)
	ui.content = content
	buildHeader(content)
	ui.pageTitle = label(content, {
		Name = "PageTitle", BackgroundTransparency = 1, Position = UDim2.fromOffset(2, 4), Size = UDim2.new(1, -4, 0, 28),
		Text = "", TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3,
	}, "title", 21, "Text")
	ui.pageSub = label(content, {
		Name = "PageSubtitle", BackgroundTransparency = 1, Position = UDim2.fromOffset(2, 33), Size = UDim2.new(1, -4, 0, 18),
		Text = "", TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3,
	}, "caption", 11, "Muted")
	ui.pageHost = Util.new("Frame", {
		Name = "Pages", BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 2,
	}, content)

	-- footer: "<FooterName> - <tab name>" (the text is updated by Win.selectTab)
	ui.footer = Util.new("Frame", {
		Name = "Footer", BackgroundTransparency = 1, BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 22), ZIndex = 3,
	}, content)
	local footerRule = Util.new("Frame", {
		Name = "Rule", BorderSizePixel = 0, BackgroundTransparency = 0.55, Size = UDim2.new(1, 0, 0, 1), ZIndex = 3,
	}, ui.footer)
	Theme.bind(footerRule, "BackgroundColor3", "Border")
	ui.footerText = label(ui.footer, {
		Name = "FooterText", BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 2), Size = UDim2.new(1, 0, 1, -2),
		Text = CONFIG.FooterName, TextXAlignment = Enum.TextXAlignment.Center, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3,
	}, "caption", 11, "Muted")

	-- popup (dropdown) and modal (confirm) layers sit above everything inside the surface
	ui.popupLayer = Util.new("Frame", {
		Name = "Popups", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 50,
	}, surface)
	-- the spotlight pulses above the popups; the search sheet sits above those; confirm dialogs above all of it
	ui.spotLayer = Util.new("Frame", {
		Name = "Spotlights", Active = false, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 55,
	}, surface)
	ui.searchLayer = Util.new("Frame", {
		Name = "SearchLayer", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 58,
	}, surface)
	ui.modalLayer = Util.new("Frame", {
		Name = "Modals", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 60,
	}, surface)
	UI.layers.popup, UI.layers.modal = ui.popupLayer, ui.modalLayer
	UI.layers.spot, UI.layers.search = ui.spotLayer, ui.searchLayer

	Win.applyLayout()
	Win.applyPerformance()

	-- the floating logo (and its tab ring) lives in the ScreenGui, above the window
	buildLauncher(gui)
	Win.placeLauncher(false)
	Win.applyPerformance()
	maid:Give(Notify.onChange(function()
		Win.updateOrb()
	end))
	for _, key in ipairs({ "fx", "reducedMotion", "lowPower" }) do
		maid:Give(Store.on(key, function()
			Win.updateOrb()
		end))
	end

	-- clock (1 Hz, only while the window is shown)
	Anim.add("clock", function()
		local text = os.date("%H:%M")
		if ui.clock.Text ~= text then
			ui.clock.Text = text
		end
	end, 1, function()
		return Win.visible and ui.clock.Visible
	end)

	-- keyboard shortcut (keyboard / mouse devices only)
	local keyOk, keyCode = pcall(function()
		return Enum.KeyCode[CONFIG.ToggleKey]
	end)
	if keyOk and keyCode then
		maid:Connect(UserInputService.InputBegan, function(input, processed)
			if not processed and input.KeyCode == keyCode then
				Win.toggle()
			end
		end)
	end
	-- "/" opens the jump search (not while typing somewhere)
	maid:Connect(UserInputService.InputBegan, function(input, processed)
		if processed or not Win.visible or input.KeyCode ~= Enum.KeyCode.Slash or not Pages.search then
			return
		end
		local typing = false
		pcall(function()
			typing = UserInputService:GetFocusedTextBox() ~= nil
		end)
		if not typing then
			Pages.search.open(true)
		end
	end)

	-- viewport changes (rotation, window resize)
	local cameraConnection = nil
	local function watchCamera()
		if cameraConnection then
			cameraConnection:Disconnect()
			cameraConnection = nil
		end
		local camera = workspace.CurrentCamera
		if camera then
			cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(Win.scheduleRelayout)
		end
	end
	watchCamera()
	maid:Give(function()
		if cameraConnection then
			cameraConnection:Disconnect()
		end
	end)
	maid:Connect(workspace:GetPropertyChangedSignal("CurrentCamera"), function()
		watchCamera()
		Win.scheduleRelayout()
	end)

	maid:Give(Store.on("scale", function()
		Win.relayout(true)
	end))
	maid:Give(Store.on("compact", function()
		Win.relayout(true)
	end))
	maid:Give(Store.on("clock", function()
		Win.refreshChrome()
	end))
	maid:Give(Store.on("lowPower", function()
		Win.applyPerformance()
	end))
	return window
end

function Win.destroy()
	Anim.remove("clock")
	Anim.remove("orbPulse")
	if Win.maid then
		Win.maid:Clean()
		Win.maid = nil
	end
	if Win.window then
		pcall(Win.window.Destroy, Win.window)
	end
	if Win.launcher and Win.launcher.root then
		pcall(Win.launcher.root.Destroy, Win.launcher.root)
	end
	Win.launcher, Win.radial, Win.ringOpen = nil, nil, false
	Win.window, Win.scaler, Win.gui = nil, nil, nil
	Win.ui = {}
	Win.nav, Win.pages, Win.currentTab = {}, {}, nil
	Win.visible, Win.minimized = false, false
	Win.layoutListeners = {}
	UI.layers.popup, UI.layers.modal, UI.layers.spot, UI.layers.search = nil, nil, nil, nil
	UI.openDropdown, UI.modal = nil, nil
end
end -- [11_window.lua]

do -- [pages core]
Pages.cards = {}
Pages.syncers = {}
Pages.disposers = {}
Pages.gridUpdaters = {}
Pages.build = {}
Pages.building = nil    -- id of the page that is being built (App.boot sets it); every UI.card files itself in the search index
Pages.searchIndex = {}  -- { page, title, desc, kw, target, flash, icon, order, run }
Pages.searchOrder = 0

-- Files something in the jump search. page: tab id, target: the Instance to scroll to, o.flash: function that lights it up,
-- o.icon: icon name for the result row, o.run: function that runs when the result is chosen (instead of only jumping).
function Pages.addSearch(page, title, desc, kw, target, o)
	if not page or not title or title == "" then
		return nil
	end
	o = o or {}
	Pages.searchOrder = Pages.searchOrder + 1
	local entry = {
		page = page, title = tostring(title), desc = tostring(desc or ""), kw = tostring(kw or ""), target = target,
		flash = o.flash, icon = o.icon, order = Pages.searchOrder, run = o.run,
	}
	Pages.searchIndex[#Pages.searchIndex + 1] = entry
	return entry
end

function Pages.indexCard(api, o)
	if o.title and o.title ~= "" and Pages.building then
		Pages.addSearch(Pages.building, o.title, o.desc, o.kw, api.Instance, { flash = api.Flash, icon = o.icon })
	end
end

-- opens the page of a search result, scrolls to its card and lights it up
function Pages.go(entry)
	if not entry then
		return false
	end
	if entry.page and Win.tabById[entry.page] then
		Win.selectTab(entry.page)
	end
	local target = entry.target
	if target then
		task.delay(0.18, function()
			if Util.alive(target) then
				UI.scrollIntoView(target)
				if entry.flash then
					task.delay(Motion.reduced and 0.05 or 0.32, function()
						if Util.alive(target) then
							Util.try("search flash", entry.flash)
						end
					end)
				end
			end
		end)
	end
	if entry.run then
		Util.try("search action", entry.run)
	end
	return true
end

function Pages.watch(key, fn)
	Pages.disposers[#Pages.disposers + 1] = Store.on(key, fn)
end

function Pages.sync(fn)
	Pages.syncers[#Pages.syncers + 1] = fn
end

function Pages.syncAll()
	for _, fn in ipairs(Util.copy(Pages.syncers)) do
		Util.try("page sync", fn)
	end
end

function Pages.register(card, controlWidth)
	Pages.cards[#Pages.cards + 1] = { card = card, width = controlWidth }
end

-- cards whose controls would squeeze the text too much drop them below it
function Pages.syncCards()
	local width = Win.pageW or 400
	local alive = {}
	for _, entry in ipairs(Pages.cards) do
		if entry.card.Instance.Parent then
			alive[#alive + 1] = entry
			entry.card.SetStacked(width - (entry.width + 42 + (entry.card.indent or 0)) < 170)
		end
	end
	Pages.cards = alive
	for _, update in ipairs(Pages.gridUpdaters) do
		Util.try("grid update", update, width)
	end
end

function Pages.init()
	Pages.destroy()
	Win.onLayout(function()
		Pages.syncCards()
	end)
end

function Pages.destroy()
	for _, dispose in ipairs(Pages.disposers) do
		pcall(dispose)
	end
	Pages.cards, Pages.syncers, Pages.disposers, Pages.gridUpdaters = {}, {}, {}, {}
	Pages.searchIndex, Pages.searchOrder, Pages.building = {}, 0, nil
	if Pages.search and Pages.search.reset then
		pcall(Pages.search.reset)
	end
	Anim.remove("fps")
	Anim.remove("overview")
	Anim.remove("presetprev") -- the animated covers of Appearance > Customize > Motion
	Pages.motionPreviews, Pages.customizeMode = {}, nil
end
end -- [pages core]

do -- [15_search.lua]

----------------------------------------------------------------------------------------------------
-- Jump search: an iOS-style sheet. A glass panel drops over the window with a search field (and Cancel), the pages as a list
-- and a few suggestions. Typing ranks every settings card of every page (Pages.searchIndex) and the pages themselves;
-- choosing a result opens its page, scrolls to the card and pulses it.
--   Enter opens the top result, the arrow keys move the selection, Esc closes. "/" opens it from the keyboard.
-- The sheet is built when it opens and destroyed when it closes, so it costs nothing while it is shut.
----------------------------------------------------------------------------------------------------
local Search = {}
Pages.search = Search
Search.isOpen = false
Search.state = nil

local SUGGESTIONS = CONFIG.SearchSuggestions
local MAX_RESULTS = 24
local LQ, RQ = "\226\128\156", "\226\128\157"

local function lower(text)
	return string.lower(tostring(text or ""))
end

----------------------------------------------------------------------------------------------------
-- ranking
----------------------------------------------------------------------------------------------------
-- everything that can be found: the pages themselves, then the cards of every page
local function corpus()
	local list = {}
	for index, def in ipairs(Win.tabList) do
		list[#list + 1] = {
			page = def.id, title = def.title, desc = def.desc, kw = "page tab open go", icon = def.icon, isPage = true, order = index - 100,
		}
	end
	for _, entry in ipairs(Pages.searchIndex) do
		list[#list + 1] = entry
	end
	return list
end

local function prepare(entry)
	if not entry.lt then
		entry.lt = lower(entry.title)
		entry.lk = lower(entry.kw)
		entry.ld = lower(entry.desc)
		local def = Win.tabById[entry.page]
		entry.pageTitle = def and def.title or ""
		entry.lp = lower(entry.pageTitle)
	end
end

-- true when `token` begins a word of `text`
local function wordStart(text, token)
	local from = 1
	while true do
		local a = string.find(text, token, from, true)
		if not a then
			return false
		end
		if a == 1 or string.sub(text, a - 1, a - 1) == " " then
			return true
		end
		from = a + 1
	end
end

-- 0 = no match. Every word of the query has to be found somewhere (title, keywords, description or page name).
function Search.score(entry, tokens, whole)
	prepare(entry)
	local score = 0
	if entry.lt == whole then
		score = 200
	elseif string.sub(entry.lt, 1, #whole) == whole then
		score = 150
	elseif string.find(entry.lt, whole, 1, true) then
		score = 110
	end
	for _, token in ipairs(tokens) do
		local hit = 0
		if string.find(entry.lt, token, 1, true) then
			hit = wordStart(entry.lt, token) and 40 or 28
		elseif string.find(entry.lk, token, 1, true) then
			hit = wordStart(entry.lk, token) and 30 or 20
		elseif string.find(entry.ld, token, 1, true) then
			hit = 12
		elseif string.find(entry.lp, token, 1, true) then
			hit = 6
		end
		if hit == 0 then
			return 0
		end
		score = score + hit
	end
	if entry.isPage then
		score = score + 5
	end
	return score
end

-- returns the best entries (at most MAX_RESULTS), the query words and how many entries matched in all
function Search.query(text)
	local whole = lower(Util.trim(text or ""))
	local tokens = {}
	for word in string.gmatch(whole, "%S+") do
		tokens[#tokens + 1] = word
	end
	if #tokens == 0 then
		return {}, tokens, 0
	end
	local found = {}
	for _, entry in ipairs(corpus()) do
		local score = Search.score(entry, tokens, whole)
		if score > 0 then
			found[#found + 1] = { entry = entry, score = score }
		end
	end
	table.sort(found, function(a, b)
		if a.score ~= b.score then
			return a.score > b.score
		end
		return (a.entry.order or 0) < (b.entry.order or 0)
	end)
	local out = {}
	for i = 1, math.min(#found, MAX_RESULTS) do
		out[i] = found[i].entry
	end
	return out, tokens, #found
end

----------------------------------------------------------------------------------------------------
-- rich text: the matched words in the accent colour
----------------------------------------------------------------------------------------------------
local function escape(text)
	text = string.gsub(text, "&", "&amp;")
	text = string.gsub(text, "<", "&lt;")
	text = string.gsub(text, ">", "&gt;")
	text = string.gsub(text, '"', "&quot;")
	text = string.gsub(text, "'", "&apos;")
	return text
end

local function hex(color)
	return string.format("#%02X%02X%02X", math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
end

function Search.highlight(text, tokens)
	text = tostring(text or "")
	local low = lower(text)
	local marks = {}
	for _, token in ipairs(tokens) do
		local a, b = string.find(low, token, 1, true)
		if a then
			marks[#marks + 1] = { a, b }
		end
	end
	table.sort(marks, function(x, y)
		return x[1] < y[1]
	end)
	local merged = {}
	for _, m in ipairs(marks) do
		local last = merged[#merged]
		if last and m[1] <= last[2] + 1 then
			if m[2] > last[2] then
				last[2] = m[2]
			end
		else
			merged[#merged + 1] = { m[1], m[2] }
		end
	end
	local color = hex(Theme.color("Accent"))
	local out, cursor = {}, 1
	for _, m in ipairs(merged) do
		out[#out + 1] = escape(string.sub(text, cursor, m[1] - 1))
		out[#out + 1] = '<font color="' .. color .. '">' .. escape(string.sub(text, m[1], m[2])) .. "</font>"
		cursor = m[2] + 1
	end
	out[#out + 1] = escape(string.sub(text, cursor))
	return table.concat(out)
end

----------------------------------------------------------------------------------------------------
-- the sheet
----------------------------------------------------------------------------------------------------
-- one line of a description for a result row: no line breaks, no bullet marks, not longer than a row can show
local function snippet(text)
	text = tostring(text or "")
	text = string.gsub(text, "[\r\n\t]+", " ")
	text = string.gsub(text, "\226\128\162%s*", "")
	text = string.gsub(text, "%s%s+", " ")
	text = Util.trim(text)
	return Util.cap(text, 96)
end

local function tabIcon(page)
	local def = Win.tabById[page]
	return def and def.icon or "search"
end

local function clearResults(state)
	for _, child in ipairs(state.scroller:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
	state.rows, state.selected, state.entries = {}, 0, {}
	UI.prune()
end

-- a small upper-case label above a group
local function groupLabel(state, text, order)
	local label = Util.new("TextLabel", {
		Name = "GroupTitle", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), LayoutOrder = order, Text = string.upper(tostring(text)),
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3,
	}, state.scroller)
	Typo.apply(label, "label", 10)
	Theme.bind(label, "TextColor3", "Muted")
	local pad = Util.new("UIPadding", {}, label)
	pad.PaddingLeft = UDim.new(0, 8)
	return label
end

-- groups fade-scale in one after the other
local function cascade(state, holders)
	for index, holder in ipairs(holders) do
		if Motion.reduced then
			break
		end
		local scale = Util.new("UIScale", { Scale = 0.94 }, holder)
		task.delay(math.min(index - 1, 6) * 0.035, function()
			if Util.alive(scale) and Search.state == state then
				Motion.tween(scale, { Scale = 1 }, 0.38, Enum.EasingStyle.Back)
			end
		end)
	end
end

function Search.select(index, silent)
	local state = Search.state
	if not state or #state.rows == 0 then
		return
	end
	index = Util.clamp(index, 1, #state.rows)
	local old = state.rows[state.selected]
	if old then
		old.api.SetActive(false)
	end
	state.selected = index
	local row = state.rows[index]
	row.api.SetActive(true)
	if not silent then
		-- keep the selected row inside the list
		local sc = state.scroller
		local s = UI.scale()
		local top = (row.api.Instance.AbsolutePosition.Y - sc.AbsolutePosition.Y) / s
		local bottom = top + row.api.Instance.AbsoluteSize.Y / s
		local view = sc.AbsoluteSize.Y / s
		local y = sc.CanvasPosition.Y
		local target = nil
		if top < 8 then
			target = y + top - 8
		elseif bottom > view - 8 then
			target = y + bottom - view + 8
		end
		if target then
			Motion.tween(sc, { CanvasPosition = Vector2.new(0, math.max(0, target)) }, 0.18)
		end
	end
end

function Search.choose(entry)
	local state = Search.state
	if not state or not entry then
		return
	end
	Search.close(false)
	Pages.go(entry)
end

-- the list for an empty field: the pages, then a few words to try
local function renderHome(state)
	clearResults(state)
	local holders = {}
	groupLabel(state, "Pages", 1)
	local group = UI.group(state.scroller, 2, "PagesGroup")
	holders[#holders + 1] = group
	for _, def in ipairs(Win.tabList) do
		local entry = { page = def.id, title = def.title, desc = def.desc, icon = def.icon, isPage = true }
		local api = UI.row(group, {
			icon = def.icon, title = def.title, desc = def.desc, chevron = true, name = "Result",
			onClick = function()
				Search.choose(entry)
			end,
		})
		state.rows[#state.rows + 1] = { api = api, entry = entry }
	end
	groupLabel(state, "Try searching for", 3)
	local width = state.contentW
	local chips = Util.new("Frame", { Name = "Suggestions", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), LayoutOrder = 4, ZIndex = 3 }, state.scroller)
	local x, y, rowH, gap = 4, 0, 32, 8
	for _, word in ipairs(SUGGESTIONS) do
		local w = Util.clamp(math.floor(26 + #word * 7.4), 64, 150)
		if x + w > width and x > 4 then
			x, y = 4, y + rowH + gap
		end
		local chip = Util.new("TextButton", {
			Name = "Suggestion", Text = "", AutoButtonColor = false, BorderSizePixel = 0, Position = UDim2.fromOffset(x, y),
			Size = UDim2.fromOffset(w, rowH), ZIndex = 3,
		}, chips)
		Util.round_corner(chip)
		Theme.surface(chip, "Card", "card")
		local stroke = Util.stroke(chip, nil, 1, 0.35)
		Theme.bind(stroke, "Color", "Border")
		local text = Util.new("TextLabel", {
			Name = "Label", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = word, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4,
		}, chip)
		Typo.apply(text, "buttonSmall", 12)
		Theme.bind(text, "TextColor3", "Text")
		local press = UI.pressable(chip, chip, { radius = UDim.new(0.5, 0), hoverAlpha = 0.92, pressAlpha = 0.82, pressScale = 0.95 })
		chip.Activated:Connect(function()
			if press.wasDrag() then
				return
			end
			Sfx.play("select")
			state.field.Set(word)
			state.field.Focus()
		end)
		x = x + w + gap
	end
	chips.Size = UDim2.new(1, 0, 0, y + rowH + 4)
	holders[#holders + 1] = chips
	cascade(state, holders)
	if #state.rows > 0 then
		-- no selection while nothing has been typed
		state.selected = 0
	end
end

local function renderEmpty(state, text)
	clearResults(state)
	local box = Util.new("Frame", { Name = "Empty", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 170), LayoutOrder = 1, ZIndex = 3 }, state.scroller)
	local badge = Util.new("Frame", {
		Name = "Badge", BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 18), Size = UDim2.fromOffset(56, 56), ZIndex = 4,
	}, box)
	Util.round_corner(badge)
	Theme.bind(badge, "BackgroundColor3", "Card", "Accent", 0.12)
	Theme.bind(Util.stroke(badge, nil, 1, 0.5), "Color", "Border")
	UI.icon("search", badge, 26, "Muted", { anchor = Vector2.new(0.5, 0.5), position = UDim2.fromScale(0.5, 0.5), zindex = 5 })
	local title = Util.new("TextLabel", {
		Name = "Title", BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 84), Size = UDim2.new(1, 0, 0, 22),
		Text = "No results for " .. LQ .. Util.cap(text, 28) .. RQ, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4,
	}, box)
	Typo.apply(title, "heading", 15)
	Theme.bind(title, "TextColor3", "Text")
	local hint = Util.new("TextLabel", {
		Name = "Hint", BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 110), Size = UDim2.new(1, 0, 0, 36),
		Text = "Check the spelling or try a shorter word, like " .. LQ .. "theme" .. RQ .. ", " .. LQ .. "sound" .. RQ .. " or " .. LQ .. "glass" .. RQ .. ".",
		TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 4,
	}, box)
	Typo.apply(hint, "caption", 12)
	Theme.bind(hint, "TextColor3", "Muted")
	cascade(state, { box })
end

local function renderResults(state, text)
	local results, tokens, total = Search.query(text)
	state.lastResults, state.lastTotal = results, total
	if #results == 0 then
		renderEmpty(state, Util.trim(text))
		return
	end
	clearResults(state)
	-- one group per page, the page of the best result first
	local groups, order = {}, {}
	for _, entry in ipairs(results) do
		if not groups[entry.page] then
			groups[entry.page] = {}
			order[#order + 1] = entry.page
		end
		local list = groups[entry.page]
		list[#list + 1] = entry
	end
	local holders, layout = {}, 0
	for _, page in ipairs(order) do
		local def = Win.tabById[page]
		layout = layout + 1
		groupLabel(state, def and def.title or page, layout)
		layout = layout + 1
		local group = UI.group(state.scroller, layout, "ResultGroup")
		holders[#holders + 1] = group
		for _, entry in ipairs(groups[page]) do
			local api = UI.row(group, {
				icon = entry.icon or tabIcon(entry.page), title = Search.highlight(entry.title, tokens), rich = true, chevron = true,
				desc = (entry.desc ~= "" and snippet(entry.desc)) or nil, name = "Result",
				onClick = function()
					Search.choose(entry)
				end,
			})
			state.rows[#state.rows + 1] = { api = api, entry = entry }
		end
	end
	if total > #results then
		layout = layout + 1
		local more = Util.new("TextLabel", {
			Name = "More", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = layout, ZIndex = 3,
			Text = string.format("Showing the best %d of %d. Type a little more to narrow it down.", #results, total),
		}, state.scroller)
		Typo.apply(more, "caption", 11)
		Theme.bind(more, "TextColor3", "Faint")
	end
	cascade(state, holders)
	Search.select(1, true)
end

function Search.render(state, text)
	if Search.state ~= state or not Util.alive(state.scroller) then
		return
	end
	state.scroller.CanvasPosition = Vector2.new(0, 0)
	if Util.trim(text or "") == "" then
		state.lastResults, state.lastTotal = nil, 0
		renderHome(state)
	else
		renderResults(state, text)
	end
end

function Search.close(immediate)
	local state = Search.state
	if not state then
		Search.isOpen = false
		return
	end
	Search.state = nil
	Search.isOpen = false
	state.maid:Clean()
	pcall(state.field.Blur)
	Win.releaseKeyboard()
	local layer = UI.layers.search
	local function finish()
		if Util.alive(state.scrim) then
			state.scrim:Destroy()
		end
		if Util.alive(state.shell) then
			state.shell:Destroy()
		end
		if layer and Util.alive(layer) and not Search.state then
			layer.Visible = false
		end
		UI.prune()
	end
	if immediate or Motion.reduced or not Util.alive(state.shell) then
		finish()
		return
	end
	Sfx.play("close")
	Motion.tween(state.scrim, { BackgroundTransparency = 1 }, 0.2)
	Motion.tween(state.shell, { Position = UDim2.new(0.5, 0, 0, 2) }, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	Motion.tween(state.scale, { Scale = 0.95 }, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, finish)
end

function Search.open(fromKey)
	if Search.isOpen then
		if Search.state then
			Search.state.field.Focus()
		end
		return
	end
	local layer = UI.layers.search
	if not layer or not Win.window or not Win.visible or UI.modal then
		return
	end
	UI.closeDropdown(true)
	layer.Visible = true
	local s = UI.scale()
	local lw, lh = layer.AbsoluteSize.X / s, layer.AbsoluteSize.Y / s
	if lw < 60 or lh < 60 then
		lw, lh = Win.w, Win.h
	end
	local width = Util.clamp(math.floor(lw - 24), 250, 520)
	local height = Util.clamp(math.floor(lh - 26), 220, 440)

	local maid = Maid.new()
	local scrim = Util.new("TextButton", {
		Name = "Scrim", Text = "", AutoButtonColor = false, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 1,
	}, layer)
	Theme.bind(scrim, "BackgroundColor3", "Scrim")
	-- shell = transparent holder (the shadow layers behind, the glass surface on top)
	local shell = Util.new("Frame", {
		Name = "SearchSheet", BackgroundTransparency = 1, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, -8), Size = UDim2.fromOffset(width, height), ZIndex = 2,
	}, layer)
	local scale = Util.new("UIScale", { Scale = 0.93 }, shell)
	UI.shadow(shell, 24, { zindex = 1, dy = 10, specs = { { 3, 0.9 }, { 9, 0.94 }, { 17, 0.97 }, { 26, 0.985 } } })
	local surface = Util.new("Frame", {
		Name = "Surface", BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 2, ClipsDescendants = true,
	}, shell)
	Util.corner(surface, 24)
	Theme.bind(surface, "BackgroundColor3", "Elevated")
	UI.glass(surface, { strength = 1, edge = true, zindex = 2, rimTransparency = 0.1 })

	local state = {
		scrim = scrim, shell = shell, scale = scale, surface = surface, maid = maid, rows = {}, selected = 0, entries = {},
		contentW = width - 24,
	}
	Search.state = state
	Search.isOpen = true

	local pending = 0
	state.field = UI.searchField({
		parent = surface, name = "Field", placeholder = "Search settings, themes and pages", cancel = true,
		size = UDim2.new(1, -28, 0, 38), position = UDim2.fromOffset(14, 14),
		onChange = function(text)
			if Util.trim(text) == "" then
				pending = pending + 1
				Search.render(state, "")
				return
			end
			pending = pending + 1
			local token = pending
			task.delay(Motion.reduced and 0 or 0.09, function()
				if token == pending then
					Search.render(state, text)
				end
			end)
		end,
		onSubmit = function(text, enter)
			if enter and Search.state == state and text ~= "" then
				-- make sure the list is up to date, then open the selected (or the top) result
				pending = pending + 1
				Search.render(state, text)
				local row = state.rows[state.selected > 0 and state.selected or 1]
				if row then
					Search.choose(row.entry)
				end
			end
		end,
		onCancel = function()
			Search.close(false)
		end,
	})
	state.field.Instance.ZIndex = 3
	local rule = Util.new("Frame", {
		Name = "Rule", Active = false, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 64), Size = UDim2.new(1, 0, 0, 1),
		BackgroundTransparency = 0.6, ZIndex = 3,
	}, surface)
	Theme.bind(rule, "BackgroundColor3", "Border")
	local scroller = Util.new("ScrollingFrame", {
		Name = "Results", BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 66), Size = UDim2.new(1, 0, 1, -66),
		CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 3, ScrollBarImageTransparency = 0.4, ZIndex = 3,
	}, surface)
	Theme.bind(scroller, "ScrollBarImageColor3", "Accent")
	Util.pad(scroller, 12, 8, 12, 14)
	Util.list(scroller, 8)
	state.scroller = scroller

	scrim.Activated:Connect(function()
		Search.close(false)
	end)
	-- Esc closes, the arrow keys move the selection (they also work while the text box has focus)
	maid:Connect(UserInputService.InputBegan, function(input)
		if Search.state ~= state then
			return
		end
		if input.KeyCode == Enum.KeyCode.Escape then
			Search.close(false)
		elseif input.KeyCode == Enum.KeyCode.Down then
			Search.select((state.selected or 0) + 1)
		elseif input.KeyCode == Enum.KeyCode.Up then
			Search.select((state.selected or 1) - 1)
		end
	end)

	Search.render(state, "")

	Sfx.play("open")
	if Motion.reduced then
		scrim.BackgroundTransparency = 0.5
		shell.Position = UDim2.new(0.5, 0, 0, 12)
		scale.Scale = 1
	else
		Motion.tween(scrim, { BackgroundTransparency = 0.5 }, 0.26)
		Motion.tween(shell, { Position = UDim2.new(0.5, 0, 0, 12) }, 0.46, Enum.EasingStyle.Quint)
		Motion.tween(scale, { Scale = 1 }, 0.5, Enum.EasingStyle.Back)
	end
	-- the keyboard goes straight to the field on a computer; on a touch screen the field is tapped, so the on-screen keyboard
	-- does not cover the list the moment it opens
	if fromKey or not Env.touch then
		task.delay(0.06, function()
			if Search.state == state then
				state.field.Focus()
				-- the "/" that opened the sheet must not end up in the field
				task.delay(0.03, function()
					if Search.state == state and state.field.Get() == "/" then
						state.field.Set("", true)
					end
				end)
			end
		end)
	end
end

function Search.toggle()
	if Search.isOpen then
		Search.close(false)
	else
		Search.open(false)
	end
end

function Search.reset()
	Search.close(true)
	Search.state, Search.isOpen = nil, false
end

----------------------------------------------------------------------------------------------------
-- a capsule that looks like the search field but only opens the sheet (the Overview page and the Scripts page use it)
----------------------------------------------------------------------------------------------------
function Search.capsule(parent, order, text)
	local hit = Util.new("TextButton", {
		Name = "SearchCapsule", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 42), LayoutOrder = order or 0,
	}, parent)
	local face = Util.new("Frame", { Name = "Face", Active = false, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 2 }, hit)
	Util.round_corner(face)
	Theme.surface(face, "Track", "input", "Panel", 0.35)
	local stroke = Util.stroke(face, nil, 1, 0.35)
	Theme.bind(stroke, "Color", "Border")
	UI.glass(face, { strength = 0.5, zindex = 2, rim = false })
	UI.icon("search", face, 17, "Muted", { anchor = Vector2.new(0, 0.5), position = UDim2.new(0, 14, 0.5, 0), zindex = 4 })
	local label = Util.new("TextLabel", {
		Name = "Placeholder", BackgroundTransparency = 1, Position = UDim2.fromOffset(40, 0), Size = UDim2.new(1, -90, 1, 0),
		Text = text or "Search settings, themes and pages", TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4,
	}, face)
	Typo.apply(label, "body", 13)
	Theme.bind(label, "TextColor3", "Faint")
	if not Env.touch then
		-- the key that opens the search from the keyboard
		local cap = Util.new("Frame", {
			Name = "KeyCap", BorderSizePixel = 0, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(24, 22), ZIndex = 4,
		}, face)
		Util.corner(cap, 7)
		Theme.bind(cap, "BackgroundColor3", "Card", "Text", 0.08)
		Theme.bind(Util.stroke(cap, nil, 1, 0.4), "Color", "Border")
		local key = Util.new("TextLabel", { Name = "Key", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "/", ZIndex = 5 }, cap)
		Typo.apply(key, "label", 12)
		Theme.bind(key, "TextColor3", "Muted")
	end
	local state = UI.pressable(hit, face, { radius = UDim.new(0.5, 0), hoverAlpha = 0.95, pressAlpha = 0.88, pressScale = 0.985 })
	hit.Activated:Connect(function()
		if state.wasDrag() then
			return
		end
		Sfx.play("click")
		Search.open(false)
	end)
	return hit
end
end -- [15_search.lua]

----------------------------------------------------------------------------------------------------
-- VirexUI public API
--   local VirexUI = loadstring(game:HttpGet("..."))()          -- or readfile
--   local Window  = VirexUI:CreateWindow({ Title = "MY HUB", Footer = "My Hub", Splash = true })
--   local Tab     = Window:AddTab({ Title = "Main", Desc = "The main page", Icon = "grid" })
--   Tab:AddSection("Combat")
--   Tab:AddToggle({ Title = "Auto farm", Description = "Farms for you", Default = false, Callback = function(on) end })
--   See Example.lua for every control.
----------------------------------------------------------------------------------------------------
local VirexUI = {}
VirexUI.Version = CONFIG.Version
VirexUI.Config = CONFIG
VirexUI.Util, VirexUI.Maid, VirexUI.Env, VirexUI.Store, VirexUI.Motion, VirexUI.Typo = Util, Maid, Env, Store, Motion, Typo
VirexUI.Theme, VirexUI.Sfx, VirexUI.Notify, VirexUI.UI, VirexUI.Bg, VirexUI.Icons, VirexUI.Win = Theme, Sfx, Notify, UI, Bg, Icons, Win

local Window, Tab = {}, {}
Window.__index, Tab.__index = Window, Tab
local current = nil

----------------------------------------------------------------------------------------------------
-- Flags: values of controls that have a Flag name, kept in <Folder>/flags.json when the executor can write files
----------------------------------------------------------------------------------------------------
local Flags = { data = {}, persist = true, token = nil }

function Flags.file()
	return CONFIG.Folder .. "/flags.json"
end

function Flags.load()
	Flags.data = {}
	if not Flags.persist or not Env.canSave() then
		return
	end
	local text = Env.readFile(Flags.file())
	if text then
		local decoded = Util.jsonDecode(text)
		if type(decoded) == "table" then
			Flags.data = decoded
		end
	end
end

function Flags.save()
	if not Flags.persist or not Env.canSave() then
		return false
	end
	local text = Util.jsonEncode(Flags.data)
	if not text then
		return false
	end
	Env.ensureFolder(CONFIG.Folder)
	return Env.writeFile(Flags.file(), text) == true
end

function Flags.queue()
	if not Flags.persist or Flags.token then
		return
	end
	Flags.token = task.delay(0.8, function()
		Flags.token = nil
		Flags.save()
	end)
end

function Flags.flush()
	if Flags.token then
		pcall(task.cancel, Flags.token)
		Flags.token = nil
	end
	Flags.save()
end

----------------------------------------------------------------------------------------------------
-- options -> CONFIG
----------------------------------------------------------------------------------------------------
local function applyOptions(opts)
	if opts.Title then
		CONFIG.Title = tostring(opts.Title)
	end
	local footer = opts.Footer or opts.FooterName
	if footer then
		CONFIG.FooterName = tostring(footer)
	end
	local name = opts.Name or opts.GuiName
	if name then
		name = string.gsub(tostring(name), "[^%w_]", "")
		CONFIG.Name, CONFIG.GuiName, CONFIG.SplashName = name, name, name .. "Splash"
		CONFIG.Registry = "__" .. name
	end
	local folder = opts.Folder
	if folder then
		folder = string.gsub(tostring(folder), "[^%w_%-%. ]", "")
		CONFIG.Folder = folder
		CONFIG.ConfigFile = folder .. "/config.json"
		CONFIG.BackgroundFolder = folder .. "/backgrounds"
		CONFIG.CacheFolder = folder .. "/cache"
		CONFIG.FontFolder = folder .. "/fonts"
		CONFIG.Splash.SoundFile = folder .. "/sounds/loading.mp3"
	end
	local key = opts.ToggleKey
	if typeof(key) == "EnumItem" then
		CONFIG.ToggleKey = key.Name
	elseif type(key) == "string" and key ~= "" then
		CONFIG.ToggleKey = key
	end
	if type(opts.Splash) == "table" then
		for k, v in pairs(opts.Splash) do
			CONFIG.Splash[k] = v
		end
	end
	if type(opts.Icons) == "table" then
		CONFIG.Icons = opts.Icons
	end
	if type(opts.Presets) == "table" then
		CONFIG.Presets = opts.Presets
	end
end

----------------------------------------------------------------------------------------------------
-- start-up helpers (from the original boot sequence)
----------------------------------------------------------------------------------------------------
local function removeLeftovers()
	local names = { CONFIG.GuiName, CONFIG.SplashName }
	local parents = {}
	if Env.fn.gethui then
		local ok, container = pcall(Env.fn.gethui)
		if ok and typeof(container) == "Instance" then
			parents[#parents + 1] = container
		end
	end
	local player = Players.LocalPlayer
	local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
	if playerGui then
		parents[#parents + 1] = playerGui
	end
	for _, parent in ipairs(parents) do
		for _, name in ipairs(names) do
			local guard = 0
			local found = parent:FindFirstChild(name)
			while found and guard < 8 do
				pcall(found.Destroy, found)
				guard = guard + 1
				found = parent:FindFirstChild(name)
			end
		end
	end
end

-- settings side effects (one place). Widgets only call Store.set; these listeners do the rest.
local function wire(self)
	local maid = self.maid
	local function on(key, fn)
		maid:Give(Store.on(key, fn))
	end
	on("reducedMotion", function(value)
		Motion.reduced = value
		Theme.syncFx()
		Bg.apply()
	end)
	on("lowPower", function()
		Theme.syncFx()
		Bg.apply()
	end)
	on("fx", function()
		Theme.syncFx()
	end)
	on("theme", function(id)
		if id ~= Theme.EDIT_ID then
			Store.set("editColors", "", true)
			Store.set("editBase", "", true)
			Store.set("preset", "")
		end
		Theme.apply(id)
	end)
	on("accentMotion", function()
		Theme.syncMotion()
	end)
	on("glass", function(value)
		Theme.setGlass(value)
	end)
	on("overlay", function()
		Bg.updateOverlay()
	end)
	on("blur", function()
		Bg.syncBlur()
	end)
	on("font", function(id)
		Typo.setFamily(id)
	end)
	on("displayFont", function(name)
		Typo.setDisplay(name)
	end)
	local customPending = false
	for _, key in ipairs({ "customH", "customS", "customD", "customO" }) do
		on(key, function()
			if customPending then
				return
			end
			customPending = true
			task.delay(0.1, function()
				customPending = false
				if self.destroyed then
					return
				end
				Theme.customDef()
				if Theme.id == "custom" then
					Theme.apply("custom", true)
				end
			end)
		end)
	end
	for _, key in ipairs({ "layerSparkle", "layerSweep", "layerVignette", "layerRim" }) do
		on(key, function()
			Bg.applyLayers()
		end)
	end
	on("parallax", function(value)
		if value == "off" then
			Bg.setParallax(0, 0)
		end
	end)
	on("textSize", function(value)
		Typo.setScale(value)
	end)
end

-- the launcher is built from Win.tabList: it is built again whenever the list changes
local function scheduleLauncher(self)
	if self.launcherToken then
		return
	end
	self.launcherToken = true
	task.defer(function()
		self.launcherToken = nil
		if self.destroyed or not Win.gui then
			return
		end
		Win.rebuildLauncher()
	end)
end

local function slug(text)
	local s = string.lower(tostring(text or "tab"))
	s = string.gsub(s, "[^%w]+", "-")
	s = string.gsub(s, "^%-+", "")
	s = string.gsub(s, "%-+$", "")
	if s == "" then
		s = "tab"
	end
	return s
end



----------------------------------------------------------------------------------------------------
-- VirexUI:CreateWindow(options)
--   Title, Footer, Name (ScreenGui name), Folder (settings folder in the executor workspace), ToggleKey (Enum.KeyCode),
--   Theme (default theme id, used until the player picks one), ForceTheme, Splash (false = no loading screen, or a table
--   that overrides CONFIG.Splash: Brand, TypeText, HintText, VersionChip, LogoImage, SoundUrl, SoundAssetIds ...),
--   Ready (false = no "Hub ready" toast, or { Title, Text }), SaveFlags (false = control values are not kept),
--   DisplayOrder, Icons ({ Map = {}, Resolver = fn, Source = url | false }), Presets (list of background presets)
----------------------------------------------------------------------------------------------------
function VirexUI:CreateWindow(opts)
	opts = type(opts) == "table" and opts or {}
	if current then
		pcall(current.Destroy, current, "replaced by a newer window")
	end
	applyOptions(opts)
	App.destroyed = false
	local self = setmetatable({
		Options = opts, Tabs = {}, TabById = {}, Elements = {}, Flags = Flags, maid = Maid.new(),
		destroyed = false, booted = false, handedOff = false, startedAt = os.clock(),
	}, Window)
	current = self

	Env.detect()
	-- a previous run of the same hub is asked to tear down first
	local global = Env.global()
	local previous = global[CONFIG.Registry]
	if type(previous) == "table" and type(previous.destroy) == "function" then
		pcall(previous.destroy, "replaced by a newer run")
		App.destroyed = false
	end
	removeLeftovers()
	self.registry = {
		version = CONFIG.Version, token = self,
		destroy = function(reason)
			self:Destroy(reason or "api")
		end,
		toggle = function()
			Win.toggle()
		end,
	}
	global[CONFIG.Registry] = self.registry

	Flags.persist = opts.SaveFlags ~= false
	Store.load()
	Flags.load()
	Motion.reduced = Store.get("reducedMotion")
	Theme.init()
	Typo.init()
	Icons.init()
	if opts.Theme and Theme.byId[opts.Theme] and (opts.ForceTheme or not Store.loadedFromFile) then
		Store.set("theme", opts.Theme, true)
	end

	local useSplash = opts.Splash ~= false and Store.get("splash") == true
	-- the loading screen was drawn for dark palettes: with a light theme saved it is shown on Obsidian and the saved theme fades
	-- in at the hand-off (nothing is written to the settings meanwhile)
	self.savedTheme = Store.get("theme")
	local savedDef = Theme.byId[self.savedTheme]
	if savedDef and savedDef.light and useSplash then
		Theme.apply("obsidian", true, true)
	elseif not Theme.apply(self.savedTheme, true) then
		Theme.apply("obsidian", true)
	end
	Theme.setGlass(Store.get("glass"))
	Theme.active = function()
		return Win.visible or Win.ringOpen
	end
	if useSplash then
		pcall(Splash.resolveSound)
	end
	Sfx.init()

	local parent, parentKind = Env.guiParent()
	self.parentKind = parentKind
	if not parent then
		Util.log("error", "no place to put the interface (PlayerGui / gethui unavailable)")
		warn("[" .. CONFIG.Name .. "] could not find a place to show the interface.")
		self:Destroy("no gui parent")
		return nil
	end

	if useSplash then
		Typo.legacy = true -- the loading screen keeps its original fonts and sizes
		local ok, err = pcall(Splash.create, parent)
		Typo.legacy = false
		if not ok then
			useSplash = false
			Util.log("error", "splash: " .. tostring(err))
		end
	end
	local total = 5
	local function step(text, done, partial)
		if useSplash then
			Splash.step(text, done, total, partial)
		end
	end
	local function fatal(message)
		Util.log("error", message)
		warn("[" .. CONFIG.Name .. "] " .. message)
		if useSplash and Splash.isOpen then
			Splash.fail(message, function()
				self:Destroy("startup failed")
			end)
		else
			self:Destroy("startup failed")
		end
	end

	-- hand-off: runs when the player taps "Tap here to continue" on the loading screen, or at once without a loading screen
	local function handoff()
		if self.handedOff or self.destroyed then
			return
		end
		self.handedOff = true
		if Theme.id ~= self.savedTheme and Theme.byId[self.savedTheme] then
			Theme.apply(self.savedTheme)
		end
		Win.showLauncher()
		if opts.Ready ~= false then
			local ready = type(opts.Ready) == "table" and opts.Ready or {}
			task.delay(0.6, function()
				if self.destroyed then
					return
				end
				Notify.success(ready.Title or "Hub ready", ready.Text or "Tap the logo to open the tab ring.")
			end)
		end
	end
	Splash.setHandoff(handoff, nil)
	task.delay(CONFIG.Splash.MaxSeconds, function()
		if self.destroyed or self.handedOff then
			return
		end
		if Win.window and useSplash and Splash.isOpen then
			Splash.force(handoff)
		elseif Win.window then
			handoff()
		else
			fatal("Startup timed out before the window was ready.")
		end
	end)

	step("Building window", 0, 0)
	local gui = Util.new("ScreenGui", {
		Name = CONFIG.GuiName, ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = tonumber(opts.DisplayOrder) or 100,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, nil)
	gui.Parent = parent
	self.Gui = gui
	local okWindow, windowError = pcall(function()
		Win.create(gui)
		Notify.init(gui)
		Pages.init()
	end)
	if not okWindow then
		fatal("The window could not be built: " .. Util.cap(tostring(windowError), 80))
		return nil
	end

	-- the rest runs after the script that called CreateWindow has added its tabs (it yields once or twice first)
	task.spawn(function()
		task.wait()
		task.wait()
		if self.destroyed then
			return
		end
		step("Building pages", 1, 0)
		if not Win.currentTab and Win.tabList[1] then
			Win.selectTab(Win.tabList[1].id, true)
		end
		Win.rebuildLauncher()
		Pages.syncCards()
		Win.applyLayout()

		Bg.apply()
		step("Loading sounds", 2, 0)
		local loaded, failed, soundCount = Sfx.preload(function(done, n)
			step("Loading sounds", 2, done / math.max(n, 1))
		end, CONFIG.Splash.PreloadSeconds)
		if self.destroyed then
			return
		end
		if useSplash then
			Splash.detail(Sfx.summary(), failed > 0 and "Warn" or "Faint")
		end
		Pages.syncAll()

		step("Preparing background", 3, 0)
		local waited = 0
		while Bg.status.kind == "loading" and waited < 10 and not self.destroyed do
			task.wait(0.1)
			waited = waited + 0.1
		end
		if self.destroyed then
			return
		end

		step("Almost ready", 4, 0)
		wire(self)
		Theme.syncFx()
		self.booted = true
		if self.OnReady then
			Util.try("OnReady", self.OnReady, self)
		end
		if useSplash and Splash.isOpen then
			Splash.ready(handoff)
		else
			handoff()
		end
	end)
	return self
end

function VirexUI:GetWindow()
	return current
end

function VirexUI:Destroy()
	if current then
		current:Destroy("api")
	end
end

----------------------------------------------------------------------------------------------------
-- Window
----------------------------------------------------------------------------------------------------
function Window:Destroy(reason)
	if self.destroyed then
		return
	end
	self.destroyed = true
	App.destroyed = true
	Util.log("info", "destroy: " .. tostring(reason))
	pcall(Store.flush)
	pcall(Flags.flush)
	pcall(UI.endSessions)
	pcall(UI.closeDropdown, true)
	pcall(UI.closeModal, true)
	pcall(Pages.destroy)
	pcall(Splash.destroy)
	pcall(Notify.destroy)
	pcall(Win.destroy)
	pcall(Bg.destroy)
	pcall(Sfx.destroy)
	pcall(Theme.clearFx)
	Anim.stopAll()
	if self.maid then
		pcall(self.maid.Clean, self.maid)
	end
	Store.listeners = {}
	if self.Gui then
		pcall(self.Gui.Destroy, self.Gui)
		self.Gui = nil
	end
	local global = Env.global()
	local registered = global[CONFIG.Registry]
	if type(registered) == "table" and registered.token == self then
		global[CONFIG.Registry] = nil
	end
	if current == self then
		current = nil
	end
	if self.OnDestroy then
		pcall(self.OnDestroy)
	end
end

function Window:AddTab(def)
	if type(def) == "string" then
		def = { Title = def }
	end
	def = def or {}
	local title = tostring(def.Title or def.Name or "Tab")
	local id = def.Id and tostring(def.Id) or slug(title)
	local base, n = id, 1
	while Win.tabById[id] do
		n = n + 1
		id = base .. "-" .. n
	end
	local entry = { id = id, title = title, desc = tostring(def.Desc or def.Description or ""), icon = def.Icon or "grid" }
	Win.tabList[#Win.tabList + 1] = entry
	Win.tabById[id] = entry
	Win.tabIndex[id] = #Win.tabList
	local page = Win.addPage(id)
	local tab = setmetatable({ id = id, Window = self, Page = page, Title = title, Entry = entry, order = 0, listOrder = nil }, Tab)
	self.Tabs[#self.Tabs + 1] = tab
	self.TabById[id] = tab
	if not Win.currentTab then
		Win.selectTab(id, true)
	end
	scheduleLauncher(self)
	task.defer(function()
		if not self.destroyed and Win.window then
			Pages.syncCards()
		end
	end)
	return tab
end

function Window:SelectTab(tab)
	local id = type(tab) == "table" and tab.id or tab
	return Win.selectTab(id)
end

function Window:Show(instant)
	Win.show(instant)
end

function Window:Hide(instant)
	Win.hide(instant)
end

function Window:Toggle()
	Win.toggle()
end

function Window:IsVisible()
	return Win.visible == true
end

function Window:Recenter()
	Win.recenter()
end

function Window:SetTitle(text)
	CONFIG.Title = tostring(text)
	if Win.ui and Win.ui.brand then
		Win.ui.brand.Text = CONFIG.Title
	end
end

function Window:SetFooter(text)
	CONFIG.FooterName = tostring(text)
	local entry = Win.tabById[Win.currentTab]
	Win.updateFooter(entry and entry.title or nil)
end

-- Window:Notify({ Type = "success" | "warn" | "error" | "info", Title = "", Text = "", Duration = 5, Key = "", Force = false })
function Window:Notify(o)
	if type(o) ~= "table" then
		o = { Text = tostring(o) }
	end
	return Notify.push(o.Type or o.Kind or "info", o.Title or "", o.Text or o.Content or "", {
		duration = o.Duration, key = o.Key, force = o.Force,
	})
end

function Window:Success(title, text, o)
	return Notify.success(title, text, o)
end

function Window:Warn(title, text, o)
	return Notify.warn(title, text, o)
end

function Window:Error(title, text, o)
	return Notify.error(title, text, o)
end

function Window:Info(title, text, o)
	return Notify.info(title, text, o)
end

-- Window:Confirm({ Title, Text, ConfirmText, CancelText, Danger = true, Callback = function() end, OnCancel = function() end })
function Window:Confirm(o)
	o = o or {}
	return UI.confirm({
		title = o.Title, text = o.Text or o.Description, confirmText = o.ConfirmText, cancelText = o.CancelText, danger = o.Danger,
		onConfirm = o.Callback or o.OnConfirm, onCancel = o.OnCancel,
	})
end

function Window:SetTheme(id)
	if Theme.byId[id] then
		return Store.set("theme", id)
	end
	return false
end

function Window:GetThemes()
	local out = {}
	for _, def in ipairs(Theme.defs) do
		if def.group ~= "Vyre" and def.id ~= "custom" and def.id ~= Theme.EDIT_ID then
			out[#out + 1] = { Id = def.id, Name = def.name, Group = def.group, Light = def.light }
		end
	end
	return out
end

-- Window:SetBackground("aurora" | "sparkle" | "facets" | "ribbons" | "stars" | "lattice" | "solid")
-- Window:SetBackground("image" | "sheet" | "sequence" | "video", source, function(ok, message) end)
function Window:SetBackground(mode, source, onResult)
	if source ~= nil then
		return Bg.useSource(mode, source, onResult)
	end
	return Bg.setMode(mode)
end

function Window:SetFont(id)
	return Store.set("font", id)
end

function Window:SetScale(value)
	return Store.set("scale", value)
end

function Window:GetFlag(name)
	return Flags.data[name]
end

function Window:SetFlag(name, value)
	local element = self.Elements[name]
	if element and element.Set then
		element.Set(value)
	else
		Flags.data[name] = value
		Flags.queue()
	end
end



----------------------------------------------------------------------------------------------------
-- Tab: every Add... call builds a card in the look of the original pages (icon tile, title, description, control on the right;
-- the control drops under the text when the window is narrow). Common options of the cards:
--   Title, Description, Icon (a name from the icon list), IconRole ("Accent" | "Accent2" | "Info" | "Warn" | "Danger" | "Green"),
--   Keywords (extra words for the jump search), Flag (name under which the value is kept between runs),
--   StoreKey (bind to one of the window's own settings, see Window:AddSettingsTab), Callback
----------------------------------------------------------------------------------------------------
local function nextOrder(tab)
	tab.order = tab.order + 1
	return tab.order
end

-- cards made while Pages.building is set file themselves in the jump search
local function indexed(tab, fn)
	local previous = Pages.building
	Pages.building = tab.id
	local ok, result = pcall(fn)
	Pages.building = previous
	if not ok then
		error(result, 0)
	end
	return result
end

local function suggest(title)
	local list = CONFIG.SearchSuggestions
	if type(list) ~= "table" or type(title) ~= "string" or title == "" or #list >= 9 then
		return
	end
	local word = Util.cap(title, 18)
	for _, existing in ipairs(list) do
		if existing == word then
			return
		end
	end
	list[#list + 1] = word
end

local function normalizeOptions(list)
	local out = {}
	if type(list) ~= "table" then
		return out
	end
	for _, opt in ipairs(list) do
		if type(opt) == "table" then
			local id = opt.id
			if id == nil then
				id = opt.Id
			end
			if id == nil then
				id = opt.Value
			end
			if id == nil then
				id = opt.Name
			end
			local label = opt.label or opt.Label or opt.Name or tostring(id)
			out[#out + 1] = { id = id, label = tostring(label) }
		else
			out[#out + 1] = { id = opt, label = tostring(opt) }
		end
	end
	return out
end

local function hasOption(options, id)
	for _, opt in ipairs(options) do
		if opt.id == id then
			return true
		end
	end
	return false
end

-- the value a control starts with: its own setting (StoreKey), then the saved flag, then Default
local function startValue(o, default, check)
	local value, restored = nil, false
	if o.StoreKey then
		value = Store.get(o.StoreKey)
	end
	if value == nil and o.Flag and Flags.data[o.Flag] ~= nil then
		value, restored = Flags.data[o.Flag], true
	end
	if value == nil then
		value = o.Default
		if value == nil then
			value = o.Value
		end
	end
	if value == nil or (check and not check(value)) then
		value, restored = default, false
	end
	return value, restored
end

local function commit(o, value)
	if o.StoreKey then
		Store.set(o.StoreKey, value)
	end
	if o.Flag then
		Flags.data[o.Flag] = value
		Flags.queue()
	end
end

local function fire(o, name, ...)
	if o.Callback then
		Util.try(name .. " " .. tostring(o.Title or o.Name or ""), o.Callback, ...)
	end
end

local function finish(tab, o, api, value, restored)
	api.Instance = api.Card and api.Card.Instance or api.Instance
	if o.Flag then
		tab.Window.Elements[o.Flag] = api
		Flags.data[o.Flag] = value
	end
	-- a value that came back from the saved flags is handed to the callback once, so the feature is switched on again
	if restored and o.Callback then
		local callback = o.Callback
		task.defer(function()
			if not tab.Window.destroyed then
				Util.try("restore " .. tostring(o.Title or o.Name or ""), callback, value, true)
			end
		end)
	end
	return api
end

local function makeCard(tab, o, extra)
	local title = tostring(o.Title or o.Name or "")
	local spec = {
		parent = tab.Page, order = nextOrder(tab), title = title, desc = o.Description or o.Desc, name = title ~= "" and title or "Card",
		icon = o.Icon, iconRole = o.IconRole, kw = o.Keywords,
	}
	for key, value in pairs(extra or {}) do
		spec[key] = value
	end
	local card = indexed(tab, function()
		return UI.card(spec)
	end)
	suggest(title)
	return card
end

local function controlAnchor(instance)
	instance.AnchorPoint = Vector2.new(0, 0.5)
	instance.Position = UDim2.fromScale(0, 0.5)
end

-- Tab:AddSection("Combat") - a heading with the accent diamond
function Tab:AddSection(text, count)
	return UI.section(self.Page, tostring(text or ""), nextOrder(self), count)
end

-- Tab:AddParagraph({ Title = "About", Description = "Text", Icon = "info" })  or  Tab:AddParagraph("Title", "Text")
function Tab:AddParagraph(o, text)
	if type(o) ~= "table" then
		o = { Title = o, Description = text }
	end
	local card = makeCard(self, o, {})
	return { Card = card, Instance = card.Instance, SetTitle = card.SetTitle, SetDesc = card.SetDesc }
end

-- Tab:AddButton({ Title, Description, Text = "Run", ButtonIcon, Kind = "secondary" | "primary" | "danger" | "ghost", Width, Callback })
function Tab:AddButton(o)
	o = o or {}
	local width = o.Width or 124
	local card = makeCard(self, o, { control = width })
	local button = UI.button({
		parent = card.Controls, text = o.Text or o.ButtonText or "Run", icon = o.ButtonIcon, kind = o.Kind, small = true, name = "Action",
		sound = o.Sound, size = UDim2.new(1, 0, 0, 34), anchor = Vector2.new(0, 0.5), position = UDim2.fromScale(0, 0.5),
		onClick = function(api)
			fire(o, "button", api)
		end,
	})
	Pages.register(card, width)
	return {
		Card = card, Instance = card.Instance, Button = button, SetText = button.SetText, SetEnabled = button.SetEnabled,
		SetBusy = button.SetBusy, SetTitle = card.SetTitle, SetDesc = card.SetDesc,
	}
end

-- Tab:AddToggle({ Title, Description, Default = false, Flag, Callback = function(on) end })
function Tab:AddToggle(o)
	o = o or {}
	local value, restored = startValue(o, false, function(v)
		return type(v) == "boolean"
	end)
	local card = makeCard(self, o, { control = 62 })
	local toggle = UI.toggle({
		parent = card.Controls, value = value, anchor = Vector2.new(1, 0.5), position = UDim2.fromScale(1, 0.5), name = "Toggle",
		onChange = function(v)
			commit(o, v)
			fire(o, "toggle", v)
		end,
	})
	if o.StoreKey then
		Pages.watch(o.StoreKey, function(v)
			toggle.Set(v, true)
		end)
	end
	Pages.register(card, 62)
	local api = {
		Card = card, Toggle = toggle, Get = toggle.Get, SetEnabled = toggle.SetEnabled, SetTitle = card.SetTitle, SetDesc = card.SetDesc,
		Set = function(v, silent)
			toggle.Set(v and true or false, silent)
		end,
	}
	return finish(self, o, api, value, restored)
end

-- Tab:AddSlider({ Title, Description, Min = 0, Max = 100, Step = 1, Default, Suffix = "%", Format = function(v) return "..." end,
--                 Callback = function(value, final) end })
function Tab:AddSlider(o)
	o = o or {}
	local min, max, step = tonumber(o.Min) or 0, tonumber(o.Max) or 100, tonumber(o.Step) or 1
	local value, restored = startValue(o, min, function(v)
		return type(v) == "number"
	end)
	value = Util.clamp(value, min, max)
	local format = o.Format
	if not format and (o.Suffix or o.Prefix) then
		local prefix, suffix = o.Prefix or "", o.Suffix or ""
		format = function(v)
			return prefix .. tostring(v) .. suffix
		end
	end
	local card = makeCard(self, o, { stack = true, controlHeight = 38 })
	local slider = UI.slider({
		parent = card.Controls, min = min, max = max, step = step, value = value, format = format, name = "Slider",
		onChange = function(v, final)
			commit(o, v)
			fire(o, "slider", v, final)
		end,
	})
	slider.Instance.Size = UDim2.new(1, 0, 0, 38)
	if o.StoreKey then
		Pages.watch(o.StoreKey, function(v)
			slider.Set(v, true)
		end)
	end
	local api = {
		Card = card, Slider = slider, Get = slider.Get, SetEnabled = slider.SetEnabled, SetTitle = card.SetTitle, SetDesc = card.SetDesc,
		Set = function(v, silent)
			slider.Set(v, silent)
		end,
	}
	return finish(self, o, api, value, restored)
end

-- Tab:AddStepper({ Title, Description, Min, Max, Step, Default, Format = function(v) return "..." end, Callback = function(value) end })
function Tab:AddStepper(o)
	o = o or {}
	local min, max, step = tonumber(o.Min) or 0, tonumber(o.Max) or 10, tonumber(o.Step) or 1
	local value, restored = startValue(o, min, function(v)
		return type(v) == "number"
	end)
	value = Util.clamp(value, min, max)
	local card = makeCard(self, o, { control = 150 })
	local stepper = UI.stepper({
		parent = card.Controls, min = min, max = max, step = step, value = value, anchor = Vector2.new(1, 0.5),
		position = UDim2.fromScale(1, 0.5), name = "Stepper", format = o.Format,
		onChange = function(v)
			commit(o, v)
			fire(o, "stepper", v)
		end,
	})
	if o.StoreKey then
		Pages.watch(o.StoreKey, function(v)
			stepper.Set(v, true)
		end)
	end
	Pages.register(card, 150)
	local api = { Card = card, Stepper = stepper, Get = stepper.Get, Set = stepper.Set, SetTitle = card.SetTitle, SetDesc = card.SetDesc }
	return finish(self, o, api, value, restored)
end

-- Tab:AddSegmented({ Title, Description, Options = { "Easy", "Hard" } or { { id = "a", label = "A" } }, Default, Callback = function(id) end })
function Tab:AddSegmented(o)
	o = o or {}
	local options = normalizeOptions(o.Options)
	local first = options[1] and options[1].id
	local value, restored = startValue(o, first, function(v)
		return hasOption(options, v)
	end)
	local width = o.Width or math.max(150, #options * 72 + 8)
	local card = makeCard(self, o, { control = width })
	local control = UI.segmented({
		parent = card.Controls, size = UDim2.new(1, 0, 0, 36), anchor = Vector2.new(0, 0.5), position = UDim2.fromScale(0, 0.5),
		options = options, value = value, name = "Segmented",
		onChange = function(id)
			commit(o, id)
			fire(o, "segmented", id)
		end,
	})
	if o.StoreKey then
		Pages.watch(o.StoreKey, function(v)
			control.Set(v, true)
		end)
	end
	Pages.register(card, width)
	local api = { Card = card, Control = control, Get = control.Get, Set = control.Set, SetEnabled = control.SetEnabled, SetTitle = card.SetTitle, SetDesc = card.SetDesc }
	return finish(self, o, api, value, restored)
end

-- Tab:AddDropdown({ Title, Description, Options = { "A", "B" }, Default, Placeholder, Callback = function(id) end })
function Tab:AddDropdown(o)
	o = o or {}
	local options = normalizeOptions(o.Options)
	local first = options[1] and options[1].id
	local value, restored = startValue(o, o.AllowEmpty and nil or first, function(v)
		return hasOption(options, v)
	end)
	local width = o.Width or 200
	local card = makeCard(self, o, { control = width })
	local dropdown = UI.dropdown({
		parent = card.Controls, options = options, value = value, placeholder = o.Placeholder, name = "Dropdown", popupWidth = o.PopupWidth,
		onChange = function(id)
			commit(o, id)
			fire(o, "dropdown", id)
		end,
	})
	dropdown.Instance.Size = UDim2.new(1, 0, 0, 36)
	controlAnchor(dropdown.Instance)
	if o.StoreKey then
		Pages.watch(o.StoreKey, function(v)
			dropdown.Set(v, true)
		end)
	end
	Pages.register(card, width)
	local api = {
		Card = card, Dropdown = dropdown, Get = dropdown.Get, Set = dropdown.Set, SetEnabled = dropdown.SetEnabled,
		SetTitle = card.SetTitle, SetDesc = card.SetDesc,
		SetOptions = function(list, selected)
			dropdown.SetOptions(normalizeOptions(list), selected)
		end,
	}
	return finish(self, o, api, value, restored)
end

-- Tab:AddMultiDropdown({ Title, Description, Options = { "A", "B" }, Default = { "A" }, Callback = function(list) end })
function Tab:AddMultiDropdown(o)
	o = o or {}
	local options = normalizeOptions(o.Options)
	local value, restored = startValue(o, {}, function(v)
		return type(v) == "table"
	end)
	local width = o.Width or 200
	local card = makeCard(self, o, { control = width })
	local picker = UI.multiSelect({
		parent = card.Controls, options = options, value = value, placeholder = o.Placeholder, name = "MultiDropdown", popupWidth = o.PopupWidth,
		onChange = function(list)
			commit(o, list)
			fire(o, "multi dropdown", list)
		end,
	})
	picker.Instance.Size = UDim2.new(1, 0, 0, 36)
	controlAnchor(picker.Instance)
	Pages.register(card, width)
	local api = {
		Card = card, Dropdown = picker, Get = picker.Get, Set = picker.Set, SetEnabled = picker.SetEnabled,
		SetTitle = card.SetTitle, SetDesc = card.SetDesc,
		SetOptions = function(list, selected)
			picker.SetOptions(normalizeOptions(list), selected)
		end,
	}
	return finish(self, o, api, value, restored)
end

-- Tab:AddInput({ Title, Description, Placeholder, Default = "", Numeric = false, MaxLength, OnChange = function(text) end,
--                Callback = function(text, enterPressed) end })   (Callback runs when the box loses focus)
function Tab:AddInput(o)
	o = o or {}
	local value, restored = startValue(o, "", function(v)
		return type(v) == "string"
	end)
	local width = o.Width or 220
	local card = makeCard(self, o, { control = width })
	local input = UI.input({
		parent = card.Controls, size = UDim2.new(1, 0, 0, 36), anchor = Vector2.new(0, 0.5), position = UDim2.fromScale(0, 0.5),
		placeholder = o.Placeholder, text = value, numeric = o.Numeric, maxLength = o.MaxLength, name = "Input",
		onChange = function(text)
			if o.OnChange then
				Util.try("input change", o.OnChange, text)
			end
		end,
		onSubmit = function(text, enter)
			commit(o, text)
			fire(o, "input", text, enter)
		end,
	})
	Pages.register(card, width)
	local api = {
		Card = card, Input = input, Get = input.Get, Focus = input.Focus, Flash = input.Flash, SetTitle = card.SetTitle, SetDesc = card.SetDesc,
		Set = function(text)
			input.Set(text)
			commit(o, tostring(text or ""))
		end,
	}
	return finish(self, o, api, value, restored)
end

-- Tab:AddCard({ Title, Description, Icon, ControlWidth, ControlHeight, Stack }) -> { Card, Controls }: put your own objects in Controls
function Tab:AddCard(o)
	o = o or {}
	local card = makeCard(self, o, { control = o.ControlWidth or 0, controlHeight = o.ControlHeight, stack = o.Stack })
	if o.ControlWidth then
		Pages.register(card, o.ControlWidth)
	end
	return { Card = card, Instance = card.Instance, Controls = card.Controls, SetTitle = card.SetTitle, SetDesc = card.SetDesc }
end

-- Tab:AddList() -> list; list:AddRow({ Title, Description, Icon, Chevron = true, Right = "text", Callback = function() end })
function Tab:AddList(o)
	o = o or {}
	local group = UI.group(self.Page, nextOrder(self), o.Name or "List")
	local list = { Instance = group, Tab = self }
	function list:AddRow(r)
		r = r or {}
		suggest(r.Title)
		return UI.row(group, {
			icon = r.Icon, iconRole = r.IconRole, title = r.Title, desc = r.Description, chevron = r.Chevron, right = r.Right,
			height = r.Height, name = r.Name or r.Title or "Row",
			onClick = r.Callback and function(api)
				Util.try("row " .. tostring(r.Title), r.Callback, api)
			end or nil,
		})
	end
	return list
end

-- Tab:AddStats({ { Label = "Ping", Value = "42 ms" }, ... }) - a row of stat tiles
function Tab:AddStats(items)
	local row = Util.new("Frame", { Name = "Stats", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 62), LayoutOrder = nextOrder(self) }, self.Page)
	Util.list(row, 8, true)
	local tiles = {}
	local count = math.max(1, #items)
	for index, item in ipairs(items) do
		local tile = UI.statTile({ parent = row, label = item.Label, value = item.Value, order = index, size = UDim2.new(1 / count, -8 * (count - 1) / count, 1, 0) })
		tiles[item.Label or index] = tile
	end
	return { Instance = row, Tiles = tiles }
end



----------------------------------------------------------------------------------------------------
-- Window:AddSettingsTab() - the hub's own settings built from the same controls (theme, motion, glass, type, window, background,
-- notifications, sound). Every control is bound to a Store key, so "Reset preferences" updates all of them at once.
----------------------------------------------------------------------------------------------------
local function percentText(value)
	return Util.percent(value) .. "%"
end

function Window:AddSettingsTab(def)
	def = def or {}
	local tab = self:AddTab({
		Id = def.Id or "settings", Title = def.Title or "Settings", Icon = def.Icon or "gear",
		Desc = def.Desc or def.Description or "Themes, glass, motion, type, window and sound.",
	})
	local themeOptions = {}
	for _, theme in ipairs(self:GetThemes()) do
		themeOptions[#themeOptions + 1] = { id = theme.Id, label = theme.Name }
	end
	local fontOptions = {}
	for _, item in ipairs(Typo.list()) do
		fontOptions[#fontOptions + 1] = { id = item.id, label = item.label }
	end

	tab:AddSection("Appearance")
	tab:AddDropdown({
		Title = "Theme", Description = "Colours of the window, cards and accents.", Icon = "palette", Options = themeOptions, StoreKey = "theme",
		Keywords = "colour color dark light obsidian gold silver emerald ruby",
	})
	tab:AddSegmented({
		Title = "Accent motion", Icon = "sparkle", IconRole = "Info", StoreKey = "accentMotion", Keywords = "colour color animate breathe drift spectrum rainbow",
		Description = "The accent colour moves slowly. Breathe pulses, Drift slides along the palette, Spectrum travels around the colour wheel.",
		Options = { { id = "still", label = "Still" }, { id = "breathe", label = "Breathe" }, { id = "drift", label = "Drift" }, { id = "spectrum", label = "Spectrum" } },
		Width = 292,
	})
	tab:AddSlider({
		Title = "Motion speed", Description = "How fast the colour moves (Breathe, Drift and Spectrum).", Icon = "clock", StoreKey = "accentSpeed",
		Min = 0.5, Max = 2, Step = 0.1, Keywords = "speed fast slow tempo",
		Format = function(value)
			return string.format("%.1fx", value)
		end,
	})
	tab:AddSegmented({
		Title = "Animated accents", Icon = "layers", IconRole = "Accent2", StoreKey = "fx", Keywords = "fx effects shimmer sweep animation level",
		Description = "Moving highlights on the window border, title and selection (premium themes look best on Full).",
		Options = { { id = 0, label = "Off" }, { id = 1, label = "Subtle" }, { id = 2, label = "Full" } },
	})
	tab:AddToggle({
		Title = "Reduced motion", Description = "Turn off interface tweens and animated accents; changes become immediate.", Icon = "eye", StoreKey = "reducedMotion",
		Keywords = "animation accessibility instant tweens",
		Callback = function(value)
			Notify.info("Reduced motion", value and "Animations are off." or "Animations are on.", { key = "motion", force = true })
		end,
	})
	tab:AddToggle({
		Title = "Low power mode", Description = "Removes shadows, animated accents and animated backgrounds to save battery and keep the frame rate steady.",
		Icon = "bolt", IconRole = "Warn", StoreKey = "lowPower", Keywords = "battery performance fps smooth lag",
	})

	tab:AddSection("Liquid glass")
	tab:AddSlider({
		Title = "Glass", Description = "How see-through the window and its cards are.", Icon = "drop", StoreKey = "glass", Min = 0, Max = 0.6, Step = 0.02,
		Format = percentText, Keywords = "transparent transparency panel blur",
	})

	tab:AddSection("Typography")
	if #fontOptions > 0 then
		tab:AddDropdown({ Title = "Font", Description = "The typeface of the whole interface.", Icon = "scripts", Options = fontOptions, StoreKey = "font", Keywords = "typeface type text" })
	end
	tab:AddSlider({
		Title = "Text size", Description = "Text only; the window and the buttons keep their size.", Icon = "eye", StoreKey = "textSize", Min = 80, Max = 130, Step = 5,
		Suffix = "%", Keywords = "font bigger smaller zoom",
	})

	tab:AddSection("Window")
	tab:AddSlider({
		Title = "UI scale", Description = "Makes the whole window and the floating logo bigger or smaller.", Icon = "sliders", StoreKey = "scale", Min = 0.7, Max = 1.3, Step = 0.05,
		Format = percentText, Keywords = "size zoom",
	})
	tab:AddToggle({ Title = "Compact window", Description = "A slightly smaller window.", Icon = "grid", StoreKey = "compact" })
	tab:AddToggle({ Title = "Clock", Description = "Shows the time in the title bar.", Icon = "clock", StoreKey = "clock" })
	tab:AddButton({
		Title = "Recenter", Description = "Puts the window and the floating logo back where they started.", Icon = "target", Text = "Recenter",
		Callback = function()
			Win.recenter()
		end,
	})

	tab:AddSection("Background")
	tab:AddDropdown({
		Title = "Style", Description = "The animated picture behind the window.", Icon = "image", StoreKey = "bgMode", Keywords = "background wallpaper aurora stars lattice",
		Options = {
			{ id = "solid", label = "Solid" }, { id = "aurora", label = "Aurora" }, { id = "sparkle", label = "Sparkle" }, { id = "facets", label = "Facets" },
			{ id = "ribbons", label = "Ribbons" }, { id = "stars", label = "Stars" }, { id = "lattice", label = "Lattice" },
		},
		Callback = function()
			Bg.apply()
		end,
	})
	tab:AddSlider({ Title = "Dark overlay", Description = "Darkens the background so the text stays easy to read.", Icon = "layers", StoreKey = "overlay", Min = 0, Max = 0.9, Step = 0.05, Format = percentText })
	tab:AddToggle({ Title = "Sparkle layer", Icon = "sparkle", StoreKey = "layerSparkle" })
	tab:AddToggle({ Title = "Light sweep layer", Icon = "bolt", StoreKey = "layerSweep" })
	tab:AddToggle({ Title = "Vignette layer", Icon = "eye", StoreKey = "layerVignette" })
	tab:AddToggle({ Title = "Edge glow layer", Icon = "layers", StoreKey = "layerRim" })

	tab:AddSection("Notifications and sound")
	tab:AddToggle({ Title = "Notifications", Description = "Toasts in the corner of the screen.", Icon = "bell", StoreKey = "notifications" })
	tab:AddSlider({ Title = "Show for", Description = "How long a toast stays.", Icon = "clock", StoreKey = "notifySeconds", Min = 2, Max = 12, Step = 1, Suffix = " s" })
	tab:AddToggle({ Title = "Keep errors", Description = "Error toasts stay until you close them.", Icon = "bang", IconRole = "Danger", StoreKey = "keepErrors" })
	tab:AddToggle({ Title = "Sound", Description = "Clicks and other interface sounds.", Icon = "sound", StoreKey = "sound" })
	tab:AddSlider({ Title = "Volume", Icon = "sound", StoreKey = "volume", Min = 0, Max = 1, Step = 0.05, Format = percentText })
	tab:AddToggle({ Title = "Loading screen", Description = "Shows the intro the next time the hub starts.", Icon = "play", StoreKey = "splash" })

	tab:AddSection("Reset")
	tab:AddButton({
		Title = "Reset preferences", Description = "Puts every setting on this page back to its default.", Icon = "reset", IconRole = "Danger", Text = "Reset", Kind = "danger",
		Callback = function()
			self:Confirm({
				Title = "Reset preferences?", Text = "Every setting goes back to its default.", ConfirmText = "Reset", Danger = true,
				Callback = function()
					Store.reset()
					Bg.apply()
					Pages.syncAll()
					Win.recenter()
					Notify.success("Preferences reset", "The hub is back to its default settings.")
				end,
			})
		end,
	})
	return tab
end

----------------------------------------------------------------------------------------------------
-- a short summary for bug reports
----------------------------------------------------------------------------------------------------
function Window:Report()
	local lines = {}
	lines[#lines + 1] = (CONFIG.Name or "VirexUI") .. " " .. CONFIG.Version
	lines[#lines + 1] = Env.summary()
	lines[#lines + 1] = "Interface parent: " .. tostring(self.parentKind)
	lines[#lines + 1] = "Settings: " .. (Store.persistent and ("saved to " .. CONFIG.ConfigFile) or "session only")
	lines[#lines + 1] = "Sound: " .. Sfx.summary()
	lines[#lines + 1] = "Icons: " .. Icons.summary()
	lines[#lines + 1] = string.format("Theme %s | font %s | scale %d%%", tostring(Theme.id), tostring(Store.get("font")), Util.percent(Store.get("scale")))
	for index = math.max(1, #Util.logs - 15), #Util.logs do
		local entry = Util.logs[index]
		lines[#lines + 1] = string.format("  [%.1fs] %s: %s", entry.t - self.startedAt, entry.level, entry.message)
	end
	return table.concat(lines, "\n")
end

return VirexUI
