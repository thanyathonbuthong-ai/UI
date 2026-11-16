--[[
    NovolineUI  |  Roblox UI Library (Luau)
    ------------------------------------------------------------
    UI ดึงดีไซน์มาจากสคริปต์ Novoline:
      • Pill navbar แบบกระจก (glass) ลอยล่างจอ + capsule เลื่อนตามแท็บ
      • Panel กระจกเด้งขึ้นเหนือ pill (ลากย้ายได้ด้วย grip ด้านบน)
      • หน้า Home (banner / avatar / Welcome / tiles / server + executor)
      • Components: Section, Label, Button, Toggle, Slider, Dropdown,
        Textbox, Keybind
      • Toast notifications
      • หน้า Settings แบบ deck (Categories / Options / Quick settings /
        Shortcuts / Search): Theme, Wallpaper, Menu/Pop-out opacity,
        Auto-collapse, Keybind ฯลฯ — บันทึกลงไฟล์อัตโนมัติ
      • เปิด UI ทีไรจะพาไปแท็บแรก (Home) ทุกครั้ง และ Home ใช้รูปแมพที่เล่นอยู่เป็นพื้นหลัง

    ใช้งานเร็ว ๆ:
        local Library = loadstring(readfile("NovolineUI.lua"))()
        local Window  = Library:CreateWindow({ Name = "Novoline" })
        local Tab     = Window:AddTab({ Name = "Settings", Icon = "settings" })
        Tab:AddToggle({ Name = "Hello", Callback = print })

    ดู Example.lua สำหรับตัวอย่างเต็ม
]]

--// Services ---------------------------------------------------------------
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService      = game:GetService("TextService")
local CoreGui          = game:GetService("CoreGui")
local HttpService      = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local Debris           = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer

local Library = { Version = "1.0.0", Windows = {} }
Library.__index = Library

--// Theme (ค่าสีเดียวกับ palette ของต้นฉบับ) --------------------------------
local C = {
	PANEL    = Color3.fromRGB(23, 23, 23),
	STROKE   = Color3.fromRGB(55, 55, 55),
	ACCENT   = Color3.fromRGB(226, 226, 226),
	TEXT     = Color3.fromRGB(244, 244, 244),
	DIM      = Color3.fromRGB(160, 160, 160),
	ACTION   = Color3.fromRGB(238, 238, 238),
	DANGER   = Color3.fromRGB(239, 68, 68),
	BG       = Color3.fromRGB(18, 18, 18),
	CARD     = Color3.fromRGB(30, 30, 30),
	ELEVATED = Color3.fromRGB(40, 40, 40),
	OVERLAY  = Color3.fromRGB(15, 15, 15),
	SHINE    = Color3.fromRGB(255, 255, 255),
	DIV      = Color3.fromRGB(44, 44, 44),
	SUB      = Color3.fromRGB(205, 205, 205),
	TIME     = Color3.fromRGB(190, 190, 190),
	GLOW     = Color3.fromRGB(110, 110, 110),
}
Library.Theme = C

local WHITE      = Color3.new(1, 1, 1)
local ICON_OFF   = Color3.fromRGB(150, 150, 156)
local ICON_HOVER = Color3.fromRGB(235, 235, 238)
local ICON_ON    = Color3.fromRGB(242, 242, 244)
local SUBTLE     = Color3.fromRGB(150, 150, 156)

-- สีไล่เฉดของข้อความทักทายหน้า Home (ขาว -> เทา -> ขาว)
Library.GreetingGradient = { Color3.fromRGB(255, 255, 255), Color3.fromRGB(165, 165, 172), Color3.fromRGB(255, 255, 255) }

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

--// Helpers ----------------------------------------------------------------
local function new(class, props)
	local obj = Instance.new(class)
	local parent
	for k, v in pairs(props or {}) do
		if k == "Parent" then parent = v else obj[k] = v end
	end
	if parent then obj.Parent = parent end
	return obj
end

local function tween(obj, info, goal)
	if not obj or not obj.Parent then return nil end
	local t = TweenService:Create(obj, info, goal)
	t:Play()
	return t
end

local function ti(time, style, dir)
	return TweenInfo.new(time, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
end

local function round(obj, px)
	return new("UICorner", { Parent = obj, CornerRadius = px == "full" and UDim.new(1, 0) or UDim.new(0, px) })
end

local function mountGui(gui)
	if typeof(gethui) == "function" then
		local ok = pcall(function() gui.Parent = gethui() end)
		if ok and gui.Parent then return end
	end
	local ok = pcall(function() gui.Parent = CoreGui end)
	if not ok or not gui.Parent then
		gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end
end

local function textWidth(text, size, font)
	local ok, v = pcall(function()
		return TextService:GetTextSize(text, size, font, Vector2.new(4000, 400)).X
	end)
	return ok and v or (#text * size * 0.55)
end

--// Settings store / theme / opacity ---------------------------------------
-- ค่าตั้งค่าทั้งหมดถูกเก็บในไฟล์ (ถ้า executor รองรับ writefile)
Library.Config = { Folder = "NovolineUI", File = "settings.json", Persist = true }

local Store = {
	Notifications = true,
	Welcome = true,
	UnlockFps = false,
	BgFpsCap = false,
	AutoCollapse = false,
	Theme = "Default",
	MenuOpacity = 0.92,
	PopOpacity = 0.92,
	Wallpaper = "",
	SeeThrough = 50,
	Keybind = nil, -- ชื่อ KeyCode เช่น "RightShift"
}
Library.Settings = Store

local function ensureFolder()
	pcall(function()
		if typeof(isfolder) == "function" and typeof(makefolder) == "function" and not isfolder(Library.Config.Folder) then
			makefolder(Library.Config.Folder)
		end
	end)
end

local function saveStore()
	if not Library.Config.Persist or typeof(writefile) ~= "function" then return end
	pcall(function()
		ensureFolder()
		writefile(Library.Config.Folder .. "/" .. Library.Config.File, HttpService:JSONEncode(Store))
	end)
end

do -- โหลดค่าที่บันทึกไว้
	pcall(function()
		if typeof(isfile) == "function" and typeof(readfile) == "function" then
			local path = Library.Config.Folder .. "/" .. Library.Config.File
			if isfile(path) then
				local data = HttpService:JSONDecode(readfile(path))
				for k, v in pairs(data) do
					if Store[k] ~= nil or k == "Keybind" then Store[k] = v end
				end
			end
		end
	end)
	Store.MenuOpacity = math.clamp(tonumber(Store.MenuOpacity) or 0.92, 0.35, 1)
	Store.PopOpacity = math.clamp(tonumber(Store.PopOpacity) or 0.92, 0.35, 1)
end

-- HTTP (executor request -> game:HttpGet)
local function httpGet(url)
	local req = (syn and syn.request) or (http and http.request) or http_request or request
	if req then
		local ok, res = pcall(req, { Url = url, Method = "GET" })
		if ok and type(res) == "table" and type(res.Body) == "string" and (res.StatusCode == nil or res.StatusCode == 200) then
			return res.Body
		end
	end
	local ok, body = pcall(function() return game:HttpGet(url) end)
	return ok and body or nil
end

-- แปลง id / rbxassetid / https link เป็น asset ที่ใช้งานได้ (เหมือน resolve ของต้นฉบับ)
local imageCache = {}
local function resolveImage(source)
	local id = source:match("^%d+$") or source:match("^rbxassetid://(%d+)$")
	if id then return "rbxassetid://" .. id end
	if not source:match("^https://") then return nil end
	if imageCache[source] then return imageCache[source] end
	if typeof(getcustomasset) ~= "function" or typeof(writefile) ~= "function" or typeof(isfile) ~= "function" then return nil end
	local hash = 5381
	for i = 1, #source do hash = (hash * 33 + source:byte(i)) % 4294967296 end
	local prefix = Library.Config.Folder .. "/wallpaper_" .. string.format("%08x", hash)
	for _, ext in ipairs({ "png", "jpg", "webp" }) do
		local path = prefix .. "." .. ext
		if isfile(path) then
			imageCache[source] = getcustomasset(path)
			return imageCache[source]
		end
	end
	local body = httpGet(source)
	if type(body) ~= "string" or #body > 16 * 1024 * 1024 then return nil end
	local ext = (body:sub(1, 8) == "\137PNG\r\n\26\n" and "png")
		or (body:sub(1, 3) == "\255\216\255" and "jpg")
		or ((body:sub(1, 4) == "RIFF" and body:sub(9, 12) == "WEBP") and "webp")
	if not ext then return nil end
	ensureFolder()
	local path = prefix .. "." .. ext
	writefile(path, body)
	imageCache[source] = getcustomasset(path)
	return imageCache[source]
end

-- ภาพของแมพที่กำลังเล่น: ไอคอนของ place ก่อน (เร็ว) แล้วอัปเกรดเป็น thumbnail แนวกว้างผ่านเว็บ API
local function fetchMapArt(callback)
	task.spawn(function()
		local universeId, placeId = game.GameId, game.PlaceId
		pcall(function()
			local info = MarketplaceService:GetProductInfo(placeId)
			if info then
				local icon = tonumber(info.IconImageAssetId)
				callback(icon and icon ~= 0 and ("rbxassetid://" .. icon) or nil, info.Name)
			end
		end)
		if universeId == 0 then return end
		if typeof(getcustomasset) ~= "function" or typeof(writefile) ~= "function" or typeof(isfile) ~= "function" then return end
		local file = Library.Config.Folder .. "/map_" .. universeId .. ".png"
		local ok, asset = pcall(function()
			if isfile(file) then return getcustomasset(file) end
			local body = httpGet("https://thumbnails.roblox.com/v1/games/multiget/thumbnails?universeIds=" .. universeId
				.. "&countPerUniverse=1&defaults=true&size=768x432&format=Png&isCircular=false")
			if type(body) ~= "string" then return nil end
			local data = HttpService:JSONDecode(body)
			local entry = data and data.data and data.data[1]
			local url = entry and entry.thumbnails and entry.thumbnails[1] and entry.thumbnails[1].imageUrl
			if not url then return nil end
			local img = httpGet(url)
			if type(img) ~= "string" or #img < 256 then return nil end
			ensureFolder()
			writefile(file, img)
			return getcustomasset(file)
		end)
		if ok and asset then callback(asset) end
	end)
end

-- Theme -----------------------------------------------------------------
Library.ThemeList = {
	{ "Default", false },
	{ "Ocean", Color3.fromRGB(64, 186, 255) },
	{ "Violet", Color3.fromRGB(168, 120, 255) },
	{ "Rose", Color3.fromRGB(255, 110, 160) },
	{ "Mint", Color3.fromRGB(56, 224, 186) },
	{ "Amber", Color3.fromRGB(245, 197, 66) },
	{ "Crimson", Color3.fromRGB(255, 96, 96) },
}
local accent = nil
for _, t in ipairs(Library.ThemeList) do
	if t[1] == Store.Theme then accent = t[2] or nil end
end

local toned = {}      -- สีที่ต้องย้อมตามธีม
local switchFills = {} -- fill ของ switch ทั้งหมด
local greetings = {}   -- gradient ของข้อความทักทาย

local function toneColor(base, amount)
	if not accent then return base end
	local h, s = accent:ToHSV()
	return base:Lerp(Color3.fromHSV(h, math.min(s, 0.75), 0.24), amount)
end
local function toneSeq(grad, a, b, amount)
	toned[#toned + 1] = { grad = grad, a = a, b = b, amount = amount }
	grad.Color = ColorSequence.new(toneColor(a, amount), toneColor(b, amount))
end
local function accentColor()
	if not accent then return ICON_ON end
	local h, s, v = accent:ToHSV()
	return Color3.fromHSV(h, math.min(s, 0.7), math.max(v, 0.85))
end
local function greetingSequence()
	local set = Library.GreetingGradient
	if accent then
		local h, s, v = accent:ToHSV()
		set = { WHITE, Color3.fromHSV(h, math.min(s, 0.75), math.max(v, 0.9)), WHITE }
	end
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, set[1]), ColorSequenceKeypoint.new(0.5, set[2]), ColorSequenceKeypoint.new(1, set[3]),
	})
end

local function repaintTheme(animate)
	for i = #toned, 1, -1 do
		local e = toned[i]
		if not e.grad.Parent then
			table.remove(toned, i)
		else
			e.grad.Color = ColorSequence.new(toneColor(e.a, e.amount), toneColor(e.b, e.amount))
		end
	end
	local info = TweenInfo.new(animate and 0.6 or 0)
	for fill in pairs(switchFills) do
		if fill.Parent then
			TweenService:Create(fill, info, { BackgroundColor3 = accentColor() }):Play()
		else
			switchFills[fill] = nil
		end
	end
	for i = #greetings, 1, -1 do
		local g = greetings[i]
		if g.Parent then g.Color = greetingSequence() else table.remove(greetings, i) end
	end
end

function Library:SetTheme(name, silent)
	for _, t in ipairs(Library.ThemeList) do
		if t[1] == name then
			accent = t[2] or nil
			Store.Theme = name
			repaintTheme(true)
			if not silent then saveStore() end
			return true
		end
	end
	return false
end

-- Opacity (เหมือน _nv_setUiOpacity: ปรับเฉพาะพื้นกระจก ตัวหนังสือยังชัด) --------
local bodies = {}
local function applyBody(entry)
	local op = entry.group == "pop" and Store.PopOpacity or Store.MenuOpacity
	entry.grad.Transparency = NumberSequence.new(1 - op)
end
local function registerBody(grad, group)
	local entry = { grad = grad, group = group or "main" }
	bodies[#bodies + 1] = entry
	applyBody(entry)
end

-- which = "main" | "pop", value = 0.35 .. 1
function Library:SetUiOpacity(which, value, silent)
	value = math.clamp(tonumber(value) or 1, 0.35, 1)
	if which == "pop" then Store.PopOpacity = value else Store.MenuOpacity = value end
	for i = #bodies, 1, -1 do
		local e = bodies[i]
		if not e.grad.Parent then table.remove(bodies, i) elseif e.group == which then applyBody(e) end
	end
	if not silent then saveStore() end
end

--// Glass surface (เหมือน _nv_glass) --------------------------------------
local function glass(obj, radius, noShadow, group)
	obj.BorderSizePixel = 0
	local corner = obj:FindFirstChildOfClass("UICorner") or new("UICorner", { Parent = obj })
	corner.CornerRadius = UDim.new(0, radius)

	local surface = obj
	if obj:IsA("CanvasGroup") then
		obj.BackgroundTransparency = 1
		surface = new("Frame", { Parent = obj, Name = "Surface", Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, ZIndex = 2 })
		new("UICorner", { Parent = surface, CornerRadius = UDim.new(0, radius) })
	end
	surface.BackgroundColor3 = WHITE
	surface.BackgroundTransparency = 0

	local bodyGrad = new("UIGradient", { Parent = surface, Name = "Body", Rotation = 90 })
	toneSeq(bodyGrad, Color3.fromRGB(8, 8, 9), Color3.fromRGB(26, 26, 28), 0.18)
	registerBody(bodyGrad, group or "main")
	local rim = new("UIStroke", {
		Parent = surface, Name = "Rim", ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = WHITE, Thickness = 1,
	})
	pcall(function() rim.BorderStrokePosition = Enum.BorderStrokePosition.Inner end)
	new("UIGradient", {
		Parent = rim, Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.84),
			NumberSequenceKeypoint.new(0.5, 0.92),
			NumberSequenceKeypoint.new(1, 0.78),
		}),
	})

	if not noShadow then
		pcall(function()
			local s = new("UIShadow", {
				Name = "DarkGlow", Color = Color3.new(0, 0, 0), BlurRadius = UDim.new(0, 26),
				Offset = UDim2.fromOffset(0, 10), Transparency = 0.45, ZIndex = -1, Parent = obj,
			})
			if obj:IsA("CanvasGroup") then
				local function follow() s.Transparency = 0.45 + 0.55 * obj.GroupTransparency end
				obj:GetPropertyChangedSignal("GroupTransparency"):Connect(follow)
				follow()
			end
		end)
	end
	return rim
end

--// Page surface (การ์ดเนื้อหา, เหมือน _nv_pageSurface) -------------------
local function pageSurface(frame, interactive)
	frame.BorderSizePixel = 0
	frame.BackgroundColor3 = WHITE
	frame.BackgroundTransparency = 0.965
	local corner = frame:FindFirstChildOfClass("UICorner") or new("UICorner", { Parent = frame })
	corner.CornerRadius = UDim.new(0, 12)
	local stroke = frame:FindFirstChildOfClass("UIStroke") or new("UIStroke", { Parent = frame })
	stroke.Color = WHITE
	stroke.Thickness = 1
	stroke.Transparency = 0.94
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	if interactive then
		if frame:IsA("GuiButton") then frame.AutoButtonColor = false end
		frame.MouseEnter:Connect(function()
			tween(frame, TweenInfo.new(0.14), { BackgroundTransparency = 0.92 })
			tween(stroke, TweenInfo.new(0.14), { Transparency = 0.86 })
		end)
		frame.MouseLeave:Connect(function()
			tween(frame, TweenInfo.new(0.18), { BackgroundTransparency = 0.965 })
			tween(stroke, TweenInfo.new(0.18), { Transparency = 0.94 })
		end)
	end
	return stroke
end

-- กดแล้วย่อเล็กน้อย (เหมือน _nv_pressable)
local function pressable(obj, scale)
	scale = scale or 0.96
	local s = new("UIScale", { Parent = obj, Name = "Press" })
	local function down() tween(s, ti(0.12), { Scale = scale }) end
	local function up() tween(s, ti(0.2), { Scale = 1 }) end
	obj.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then down() end
	end)
	obj.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then up() end
	end)
	obj.MouseLeave:Connect(up)
end

local function label(props)
	local l = new("TextLabel", {
		BackgroundTransparency = 1, BorderSizePixel = 0, TextStrokeTransparency = 1,
		Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Color3.fromRGB(235, 235, 235),
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
	})
	for k, v in pairs(props) do if k ~= "Parent" then l[k] = v end end
	l.Parent = props.Parent
	return l
end

--// Icons (วาดด้วย Frame ล้วน ไม่ต้องใช้ asset) ---------------------------
-- ใช้ชื่อ เช่น "home","apps","people","note","code","settings","sparkle",
-- "plus","search","discord","info","check","cross","warn"
-- หรือส่ง "rbxassetid://123" เพื่อใช้รูปของตัวเอง
Library.Icons = {}

local function createIcon(name, parent, color, z, size)
	size = size or 20
	z = z or 1
	local box = new("Frame", {
		Parent = parent, Name = "Icon", BackgroundTransparency = 1, BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(size, size), ZIndex = z,
	})
	local parts = {} -- {obj, prop}

	if type(name) == "string" and (name:find("rbxasset") or name:find("rbxthumb")) then
		local img = new("ImageLabel", {
			Parent = box, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
			ScaleType = Enum.ScaleType.Fit, Image = name, ImageColor3 = color, ZIndex = z,
		})
		parts[#parts + 1] = { img, "ImageColor3" }
	else
		-- ระบบพิกัด 20x20 ถูกย่อ/ขยายด้วย UIScale ให้ตรงกับ size
		local canvas = new("Frame", {
			Parent = box, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(20, 20), ZIndex = z,
		})
		if size ~= 20 then new("UIScale", { Parent = canvas, Scale = size / 20 }) end

		local function block(x, y, w, h, rot, radius, filled, thick)
			local f = new("Frame", {
				Parent = canvas, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x, y),
				Size = UDim2.fromOffset(w, h), Rotation = rot or 0, BorderSizePixel = 0,
				BackgroundTransparency = filled and 0 or 1, BackgroundColor3 = color, ZIndex = z,
			})
			if radius then round(f, radius) end
			if filled then
				parts[#parts + 1] = { f, "BackgroundColor3" }
			else
				local s = new("UIStroke", { Parent = f, Color = color, Thickness = thick or 1.6, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
				parts[#parts + 1] = { s, "Color" }
			end
			return f
		end

		local custom = Library.Icons[name]
		if custom then
			custom(block, canvas, color, z, parts)
		elseif name == "home" then
			block(6.5, 7, 10, 2, -40, 1, true)
			block(13.5, 7, 10, 2, 40, 1, true)
			block(10, 13.5, 11, 7, 0, 2, false)
			block(10, 15.5, 3, 4, 0, 1, true)
		elseif name == "apps" then
			block(5.5, 5.5, 7, 7, 0, 2, false); block(14.5, 5.5, 7, 7, 0, 2, false)
			block(5.5, 14.5, 7, 7, 0, 2, false); block(14.5, 14.5, 7, 7, 0, 2, false)
		elseif name == "people" then
			block(10, 6.5, 7, 7, 0, 99, false)
			block(10, 15.5, 14, 7, 0, 99, false)
		elseif name == "note" then
			block(6.5, 15, 6, 5, -20, 99, true)
			block(9.5, 9.5, 2, 10, 0, 1, true)
			block(13.5, 4.8, 8, 2, 25, 1, true)
		elseif name == "code" then
			local t = new("TextLabel", {
				Parent = canvas, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "</>",
				Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = color, ZIndex = z,
			})
			parts[#parts + 1] = { t, "TextColor3" }
		elseif name == "settings" then
			block(10, 10, 10, 10, 0, 99, false, 2)
			block(10, 10, 3, 3, 0, 99, true)
			for i = 0, 7 do
				local a = math.rad(i * 45)
				block(10 + 8.6 * math.sin(a), 10 - 8.6 * math.cos(a), 2, 3, i * 45, 1, true)
			end
		elseif name == "sparkle" then
			block(10, 10, 2, 17, 0, 1, true); block(10, 10, 17, 2, 0, 1, true)
			block(10, 10, 2, 10, 45, 1, true); block(10, 10, 2, 10, -45, 1, true)
		elseif name == "plus" then
			block(10, 10, 12, 2, 0, 1, true); block(10, 10, 2, 12, 0, 1, true)
		elseif name == "search" then
			block(8.5, 8.5, 11, 11, 0, 99, false, 2)
			block(15.5, 15.5, 6, 2, 45, 1, true)
		elseif name == "discord" then
			block(10, 9.5, 16, 12, 0, 5, false)
			block(7, 16.5, 4, 2, -40, 1, true)
			block(7.5, 9.5, 2.5, 2.5, 0, 99, true); block(12.5, 9.5, 2.5, 2.5, 0, 99, true)
		elseif name == "info" then
			block(10, 10, 16, 16, 0, 99, false, 1.8)
			block(10, 6.6, 2, 2, 0, 99, true); block(10, 11.8, 2, 5, 0, 1, true)
		elseif name == "warn" then
			block(10, 10, 16, 16, 0, 99, false, 1.8)
			block(10, 8.6, 2, 6, 0, 1, true); block(10, 14, 2, 2, 0, 99, true)
		elseif name == "check" then
			block(6.4, 11.6, 6, 2.2, 45, 1, true)
			block(12, 9.8, 11, 2.2, -50, 1, true)
		elseif name == "cross" then
			block(10, 10, 14, 2.2, 45, 1, true); block(10, 10, 14, 2.2, -45, 1, true)
		elseif name == "person" then
			block(10, 6.5, 7, 7, 0, 99, false)
			block(10, 15.5, 14, 7, 0, 99, false)
		elseif name == "bell" then
			block(10, 9, 11, 10, 0, 5, false)
			block(10, 16.8, 4, 2, 0, 99, true)
			block(10, 3.6, 2, 2, 0, 99, true)
		elseif name == "speed" then
			block(10, 10, 16, 16, 0, 99, false, 1.8)
			block(12.2, 7.8, 2, 7, 40, 1, true)
			block(10, 10, 3, 3, 0, 99, true)
		elseif name == "keyboard" then
			block(10, 10, 18, 12, 0, 3, false, 1.6)
			block(6, 7.6, 2, 2, 0, 0, true); block(10, 7.6, 2, 2, 0, 0, true); block(14, 7.6, 2, 2, 0, 0, true)
			block(10, 12.4, 8, 2, 0, 1, true)
		elseif name == "brush" then
			block(10, 10, 16, 16, 0, 99, false, 1.8)
			block(7, 8, 2.4, 2.4, 0, 99, true); block(11.5, 6.6, 2.4, 2.4, 0, 99, true); block(13.6, 11, 2.4, 2.4, 0, 99, true)
		elseif name == "dock" then
			block(10, 10, 16, 12, 0, 3, false, 1.6)
			block(10, 13.4, 10, 2, 0, 1, true)
		elseif name == "chevron" then
			block(8.6, 7.2, 8, 2, 45, 1, true)
			block(8.6, 12.8, 8, 2, -45, 1, true)
		else -- fallback: จุดวงกลม
			block(10, 10, 8, 8, 0, 99, true)
		end
	end

	local api = { Frame = box }
	function api.set(c)
		for _, p in ipairs(parts) do p[1][p[2]] = c end
	end
	function api.tween(info, c)
		for _, p in ipairs(parts) do tween(p[1], info, { [p[2]] = c }) end
	end
	return api
end
Library.CreateIcon = createIcon

function Library:AddIcon(name, builder)
	-- builder(block, canvas, color, z, parts); block(x,y,w,h,rot,radius,filled,thick) บนพื้นที่ 20x20
	Library.Icons[name] = builder
end

--// Toast notifications ----------------------------------------------------
local Toast = { list = {}, GAP = 10, MAX = 4, MIN_W = 260, MAX_W = 420, TEXT_X = 58, PAD_R = 18 }
local TINTS = {
	info    = { Color3.fromRGB(13, 40, 51), Color3.fromRGB(64, 186, 255), "info" },
	success = { Color3.fromRGB(14, 46, 40), Color3.fromRGB(56, 224, 186), "check" },
	purple  = { Color3.fromRGB(38, 28, 62), Color3.fromRGB(168, 120, 255), "sparkle" },
	orange  = { Color3.fromRGB(62, 36, 16), Color3.fromRGB(255, 150, 50), "sparkle" },
	error   = { Color3.fromRGB(62, 20, 24), Color3.fromRGB(255, 96, 96), "cross" },
	warning = { Color3.fromRGB(56, 46, 12), Color3.fromRGB(245, 197, 66), "warn" },
	gray    = { Color3.fromRGB(44, 44, 48), Color3.fromRGB(235, 235, 238), "sparkle" },
}

function Toast.holder()
	if Toast.sg and Toast.sg.Parent then return Toast.stack end
	local sg = new("ScreenGui", {
		Name = "NV_Toasts", ResetOnSpawn = false, IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 58,
	})
	mountGui(sg)
	Toast.stack = new("Frame", { Parent = sg, Name = "Stack", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, Active = false })
	Toast.sg = sg
	return Toast.stack
end

function Toast.layout()
	local y = 90 -- 24 + 52 + 14 (เหนือ pill)
	for i = #Toast.list, 1, -1 do
		local o = Toast.list[i]
		o.y = y
		tween(o.frame, ti(0.4), { Position = UDim2.new(0.5, 0, 1, -y) })
		y = y + o.H + Toast.GAP
	end
end

function Toast.remove(o)
	if o.gone then return end
	o.gone = true
	local idx = table.find(Toast.list, o)
	if idx then table.remove(Toast.list, idx) end
	tween(o.body, ti(0.15, Enum.EasingStyle.Quad), { GroupTransparency = 1 })
	tween(o.frame, ti(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		GroupTransparency = 1, Size = UDim2.fromOffset(math.min(o.W, 132), 30),
		Position = UDim2.new(0.5, 0, 1, -(o.y - 24)),
	})
	Debris:AddItem(o.frame, 0.4)
	Toast.layout()
end

function Toast.push(spec)
	local holder = Toast.holder()
	local title = tostring(spec.Title or "Novoline")
	local text = tostring(spec.Text or "")
	local tint = TINTS[spec.Type or "gray"] or TINTS.gray
	local side = Toast.TEXT_X + Toast.PAD_R
	local widest = math.max(textWidth(title, 13, Enum.Font.GothamBold), textWidth(text, 12, Enum.Font.GothamMedium))
	local textW = math.clamp(math.ceil(widest) + 4, Toast.MIN_W - side, Toast.MAX_W - side)

	local lh, lines = 14, 0
	if text ~= "" then
		lines = 1
		pcall(function()
			lh = math.max(TextService:GetTextSize("Ag", 12, Enum.Font.GothamMedium, Vector2.new(400, 200)).Y, 12)
			local h = TextService:GetTextSize(text, 12, Enum.Font.GothamMedium, Vector2.new(textW, 4000)).Y
			lines = math.clamp(math.floor(h / lh + 0.5), 1, 2)
		end)
	end
	local contentH = 16 + (lines > 0 and (3 + lines * lh) or 0)
	local W, H = side + textW, math.max(58, contentH + 24)
	local top = math.floor((H - contentH) / 2)

	local o = { W = W, H = H, gone = false, y = 90 }
	local f = new("CanvasGroup", {
		Name = "Toast", AnchorPoint = Vector2.new(0.5, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
		GroupTransparency = 1, ZIndex = 10, Size = UDim2.fromOffset(math.min(W, 132), 30),
		Position = UDim2.new(0.5, 0, 1, -(90 - 46)), Parent = holder,
	})
	glass(f, 15, false, "pop")
	o.frame = f

	local body = new("CanvasGroup", {
		Parent = f, Name = "Content", BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 5,
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(W, H), GroupTransparency = 1,
	})
	o.body = body

	local tile = new("Frame", {
		Parent = body, Name = "Tile", Size = UDim2.fromOffset(34, 34),
		Position = UDim2.fromOffset(12, math.floor((H - 34) / 2)),
		BackgroundColor3 = tint[1], BorderSizePixel = 0, ZIndex = 6,
	})
	round(tile, "full")
	new("UIStroke", { Parent = tile, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = WHITE, Transparency = 0.9, Thickness = 1 })
	local ic = createIcon(spec.Icon or tint[3], tile, tint[2], 7, 18)
	ic.Frame.Position = UDim2.fromScale(0.5, 0.5)

	local t1 = label({ Parent = body, Text = title, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = C.TEXT,
		Position = UDim2.fromOffset(Toast.TEXT_X, top), Size = UDim2.fromOffset(textW, 16), TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 8 })
	t1.RichText = true
	if lines > 0 then
		local d = label({ Parent = body, Text = text, Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = SUBTLE,
			Position = UDim2.fromOffset(Toast.TEXT_X, top + 19), Size = UDim2.fromOffset(textW, lines * lh + 2),
			TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 8 })
		d.TextWrapped = true
	end

	local hit = new("TextButton", { Parent = body, Name = "Hit", Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 12, AutoButtonColor = false })
	hit.Activated:Connect(function() Toast.remove(o) end)

	-- ดัน toast เก่าขึ้น
	table.insert(Toast.list, o)
	while #Toast.list > Toast.MAX do Toast.remove(Toast.list[1]) end
	Toast.layout()

	tween(f, ti(0.25, Enum.EasingStyle.Quad), { GroupTransparency = 0 })
	tween(f, ti(0.5), { Size = UDim2.fromOffset(W, H) })
	task.delay(0.12, function() tween(body, ti(0.3, Enum.EasingStyle.Quad), { GroupTransparency = 0 }) end)

	local duration = tonumber(spec.Duration) or math.min(math.max(#text * 0.1 + 2.5, 3), 10)
	task.delay(duration, function() Toast.remove(o) end)
	return o
end

-- Library:Notify({ Title, Text, Duration, Type = "info|success|warning|error|purple|orange|gray", Icon })
function Library:Notify(spec)
	if type(spec) == "string" then spec = { Title = spec } end
	if not Store.Notifications and not spec.Force then return nil end
	return Toast.push(spec)
end

--// Tab (components) -------------------------------------------------------
local Tab = {}
Tab.__index = Tab

local function newCard(tab, height, interactive, class)
	tab._order = tab._order + 1
	local f = new(class or "Frame", {
		Parent = tab.Scroll, Name = "Card", LayoutOrder = tab._order,
		Size = UDim2.new(1, -6, 0, height),
	})
	if class == "TextButton" then f.Text = "" end
	pageSurface(f, interactive)
	return f
end

function Tab:AddSection(title)
	self._order = self._order + 1
	local holder = new("Frame", { Parent = self.Scroll, Name = "Section", LayoutOrder = self._order, BackgroundTransparency = 1, Size = UDim2.new(1, -6, 0, 22) })
	label({ Parent = holder, Text = string.upper(title), Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = C.DIM,
		Position = UDim2.fromOffset(4, 4), Size = UDim2.new(1, -8, 0, 16) })
	return { SetText = function(_, t) holder:FindFirstChildOfClass("TextLabel").Text = string.upper(t) end }
end

function Tab:AddLabel(text)
	self._order = self._order + 1
	local l = label({ Parent = self.Scroll, Name = "Label", LayoutOrder = self._order, Text = text, TextWrapped = true,
		TextTruncate = Enum.TextTruncate.None, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = C.SUB,
		Size = UDim2.new(1, -6, 0, 18), TextYAlignment = Enum.TextYAlignment.Top })
	local function fit()
		local h = TextService:GetTextSize(l.Text, 12, Enum.Font.Gotham, Vector2.new(self.Window.ContentSize.X - 12, 4000)).Y
		l.Size = UDim2.new(1, -6, 0, math.max(18, h + 4))
	end
	task.defer(fit)
	return { SetText = function(_, t) l.Text = t fit() end }
end

function Tab:AddButton(o)
	local card = newCard(self, 44, true, "TextButton")
	pressable(card, 0.98)
	label({ Parent = card, Text = o.Name or "Button", Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -60, 1, 0) })
	local arrow = createIcon("plus", card, ICON_OFF, 3, 14)
	arrow.Frame.AnchorPoint = Vector2.new(1, 0.5)
	arrow.Frame.Position = UDim2.new(1, -14, 0.5, 0)
	card.MouseEnter:Connect(function() arrow.tween(ti(0.15), ICON_HOVER) end)
	card.MouseLeave:Connect(function() arrow.tween(ti(0.2), ICON_OFF) end)
	card.Activated:Connect(function() if o.Callback then task.spawn(o.Callback) end end)
	return { Card = card, SetText = function(_, t) card:FindFirstChildOfClass("TextLabel").Text = t end }
end

-- Switch (เหมือน _nv_switch: track 52x26, knob 32x22, กดค้างเป็น "lens" 44x30)
local function makeSwitch(parent, on, z, onToggle, pos)
	local W, H, KW, KH, PW, PH = 52, 26, 32, 22, 44, 30
	local GLIDE = ti(0.3, Enum.EasingStyle.Quart)
	local SETTLE = ti(0.16, Enum.EasingStyle.Quad)
	local FILL = ti(0.3, Enum.EasingStyle.Quad)
	local ON_FILL = 0.25

	local track = new("TextButton", {
		Parent = parent, Name = "Switch", Text = "", AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 0.5), Position = pos or UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(W, H),
		BorderSizePixel = 0, ZIndex = z, BackgroundColor3 = WHITE, BackgroundTransparency = 0.86,
	})
	round(track, "full")
	local fill = new("Frame", { Parent = track, Name = "Fill", Size = UDim2.fromScale(1, 1), BackgroundColor3 = accentColor(), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = z })
	round(fill, "full")
	switchFills[fill] = true
	local knob = new("Frame", {
		Parent = track, Name = "Knob", AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(KW, KH),
		BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = z + 1,
	})
	round(knob, "full")
	local rim = new("UIStroke", { Parent = knob, Name = "GlassRim", Color = WHITE, Thickness = 1, Transparency = 1 })
	pcall(function()
		new("UIShadow", { Parent = knob, Name = "KnobShadow", Color = Color3.new(0, 0, 0), BlurRadius = UDim.new(0, 6), Offset = UDim2.fromOffset(0, 1), Transparency = 0.62 })
	end)

	local state = on and true or false
	local function knobX(v) return v and (W - 2 - KW / 2) or (2 + KW / 2) end
	knob.Position = UDim2.new(0, knobX(state), 0.5, 0)
	fill.BackgroundTransparency = state and ON_FILL or 1

	local function settle()
		tween(knob, GLIDE, { Position = UDim2.new(0, knobX(state), 0.5, 0) })
		tween(knob, SETTLE, { Size = UDim2.fromOffset(KW, KH), BackgroundTransparency = 0 })
		tween(rim, SETTLE, { Transparency = 1 })
		tween(fill, FILL, { BackgroundTransparency = state and ON_FILL or 1 })
	end

	track.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			tween(knob, SETTLE, { Size = UDim2.fromOffset(PW, PH), BackgroundTransparency = 0.82 })
			tween(rim, SETTLE, { Transparency = 0.25 })
		end
	end)
	track.MouseLeave:Connect(function() settle() end)
	track.Activated:Connect(function()
		state = not state
		settle()
		if onToggle then onToggle(state) end
	end)

	return {
		Track = track,
		Set = function(v, silent)
			v = v and true or false
			if v == state then return end
			state = v
			settle()
			if not silent and onToggle then onToggle(state) end
		end,
		Get = function() return state end,
	}
end

function Tab:AddToggle(o)
	local card = newCard(self, 48, false)
	local title = label({ Parent = card, Text = o.Name or "Toggle", Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -90, 1, 0) })
	local value = o.Default and true or false
	local sw
	sw = makeSwitch(card, value, 4, function(v)
		value = v
		if o.Callback then task.spawn(o.Callback, v) end
	end)
	if value and o.Callback and o.CallOnInit then task.spawn(o.Callback, value) end
	return {
		Card = card,
		Set = function(_, v, silent) sw.Set(v, silent) value = sw.Get() end,
		Get = function() return sw.Get() end,
		SetText = function(_, t) title.Text = t end,
	}
end

-- Slider (เหมือน _nv_glassSlider: track สูง 10, thumb 30x18, กดค้าง 36x20)
local TRACK_H, THUMB, HELD = 10, Vector2.new(30, 18), Vector2.new(36, 20)
local HOLD_T = TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local MOVE_T = TweenInfo.new(0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local JUMP_T = TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

local function makeSlider(o)
	local minimum, maximum = o.min or 0, o.max or 100
	local inc = o.increment or 1
	local function snap(v)
		v = tonumber(v) or minimum
		v = math.floor(v / inc + 0.5) * inc
		if inc < 1 then v = tonumber(string.format("%.3f", v)) end
		return math.clamp(v, minimum, maximum)
	end
	local value = snap(o.value)
	local z = o.z or 20

	local track = new("Frame", {
		Parent = o.parent, Name = "Track", AnchorPoint = Vector2.new(0, 0.5), Position = o.position or UDim2.fromScale(0, 0.5),
		Size = UDim2.new(o.width.Scale, o.width.Offset, 0, TRACK_H), BackgroundColor3 = WHITE, BackgroundTransparency = 0.88,
		BorderSizePixel = 0, ZIndex = z,
	})
	round(track, "full")
	local fill = new("Frame", { Parent = track, Name = "Fill", BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = z + 1 })
	round(fill, "full")
	new("UIGradient", { Parent = fill, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.78), NumberSequenceKeypoint.new(1, 0) }) })

	local thumb = new("Frame", {
		Parent = track, Name = "Thumb", AnchorPoint = Vector2.new(0.5, 0.5), BorderSizePixel = 0, ZIndex = z + 2,
		Size = UDim2.fromOffset(THUMB.X, THUMB.Y), BackgroundColor3 = WHITE,
	})
	round(thumb, "full")
	local rim = new("UIStroke", { Parent = thumb, Name = "GlassRim", Color = WHITE, Thickness = 1, Transparency = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
	pcall(function()
		new("UIShadow", { Parent = thumb, Name = "KnobShadow", Color = Color3.new(0, 0, 0), BlurRadius = UDim.new(0, 8), Offset = UDim2.fromOffset(0, 2), Transparency = 0.62 })
	end)
	local function setHeld(on)
		local s = on and HELD or THUMB
		tween(thumb, HOLD_T, { Size = UDim2.fromOffset(s.X, s.Y), BackgroundTransparency = on and 0.72 or 0 })
		tween(rim, HOLD_T, { Transparency = on and 0.3 or 1 })
	end

	local hit = new("TextButton", {
		Parent = track, Name = "Adjust", Text = "", BackgroundTransparency = 1, AutoButtonColor = false,
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, THUMB.X, 0, 32), ZIndex = z + 3,
	})

	local held, dragging, pointer = false, false, nil
	local function render(info)
		local r = maximum == minimum and 0 or (value - minimum) / (maximum - minimum)
		local hw = held and HELD.X or THUMB.X
		local sc, off = r, hw / 2 - r * hw
		local fg = { Size = UDim2.new(sc, off, 1, 0) }
		local tg = { Position = UDim2.new(sc, off, 0.5, 0) }
		if info then
			tween(fill, info, fg); tween(thumb, info, tg)
		else
			fill.Size = fg.Size; thumb.Position = tg.Position
		end
	end
	local function fromX(x)
		local w, hw = track.AbsoluteSize.X, thumb.AbsoluteSize.X
		if w <= hw then return value end
		local r = math.clamp((x - track.AbsolutePosition.X - hw / 2) / (w - hw), 0, 1)
		return snap(minimum + r * (maximum - minimum))
	end
	local function update(x, info)
		local v = fromX(x)
		if v == value then return end
		value = v
		render(info or MOVE_T)
		if o.onChange then o.onChange(value) end
	end
	local function stop()
		if not dragging then return end
		dragging, pointer, held = false, nil, false
		setHeld(false); render(HOLD_T)
		tween(track, MOVE_T, { BackgroundTransparency = 0.88 })
		if o.onRelease then o.onRelease(value) end
	end

	hit.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
		dragging, pointer, held = true, input, true
		setHeld(true)
		update(input.Position.X, JUMP_T)
		render(HOLD_T)
	end)
	hit.MouseEnter:Connect(function() tween(track, MOVE_T, { BackgroundTransparency = 0.82 }) end)
	hit.MouseLeave:Connect(function() if not dragging then tween(track, MOVE_T, { BackgroundTransparency = 0.88 }) end end)

	local conns = {}
	conns[1] = UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input == pointer or (pointer and pointer.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement) then
			update(input.Position.X)
		end
	end)
	conns[2] = UserInputService.InputEnded:Connect(function(input)
		if input == pointer or (pointer and pointer.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1) then stop() end
	end)
	conns[3] = UserInputService.WindowFocusReleased:Connect(stop)
	track.Destroying:Connect(function()
		stop()
		for _, c in ipairs(conns) do c:Disconnect() end
	end)

	render(nil)
	return {
		Track = track, Fill = fill, Thumb = thumb,
		Set = function(v, animate) value = snap(v) render(animate and JUMP_T or nil) end,
		Get = function() return value end,
		Dragging = function() return dragging end,
	}
end

function Tab:AddSlider(o)
	local minimum, maximum = o.Min or 0, o.Max or 100
	local suffix = o.Suffix or ""
	local card = newCard(self, 56, false)
	local title = label({ Parent = card, Text = o.Name or "Slider", Position = UDim2.fromOffset(14, 9), Size = UDim2.fromOffset(100, 20) })
	local info = label({ Parent = card, Text = "", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Color3.fromRGB(158, 158, 158),
		Position = UDim2.fromOffset(14, 29), Size = UDim2.fromOffset(100, 16) })
	local value = o.Default or minimum
	local function fmt(v) return (o.Format and o.Format(v)) or (tostring(v) .. suffix) end
	local engine
	engine = makeSlider({
		parent = card, position = UDim2.new(0, 124, 0.5, 0), width = UDim.new(1, -140), z = 5,
		min = minimum, max = maximum, value = value, increment = o.Increment or 1,
		onChange = function(v)
			value = v
			info.Text = fmt(v)
			if o.Callback then task.spawn(o.Callback, v) end
		end,
	})
	value = engine.Get()
	info.Text = fmt(value)
	return {
		Card = card,
		Set = function(_, v, silent)
			engine.Set(v, true)
			value = engine.Get()
			info.Text = fmt(value)
			if not silent and o.Callback then task.spawn(o.Callback, value) end
		end,
		Get = function() return engine.Get() end,
		SetText = function(_, t) title.Text = t end,
	}
end

function Tab:AddDropdown(o)
	local options = o.Options or {}
	local selected = o.Default
	local open = false
	local HEAD, ITEM = 44, 30
	local card = newCard(self, HEAD, false)
	card.ClipsDescendants = true

	local head = new("TextButton", { Parent = card, Name = "Head", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, HEAD), ZIndex = 3 })
	label({ Parent = head, Text = o.Name or "Dropdown", Position = UDim2.fromOffset(14, 0), Size = UDim2.new(0.5, -14, 1, 0), ZIndex = 4 })
	local val = label({ Parent = head, Text = selected and tostring(selected) or (o.Placeholder or "Select"), Font = Enum.Font.Gotham, TextSize = 12,
		TextColor3 = C.DIM, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -40, 0, 0), Size = UDim2.new(0.5, -40, 1, 0), ZIndex = 4 })

	local chev = new("Frame", { Parent = head, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -22, 0, HEAD / 2), Size = UDim2.fromOffset(12, 12), ZIndex = 4 })
	local b1 = new("Frame", { Parent = chev, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(3.5, 6), Size = UDim2.fromOffset(7, 2), Rotation = 45, BackgroundColor3 = ICON_OFF, BorderSizePixel = 0, ZIndex = 4 })
	local b2 = new("Frame", { Parent = chev, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(8.5, 6), Size = UDim2.fromOffset(7, 2), Rotation = -45, BackgroundColor3 = ICON_OFF, BorderSizePixel = 0, ZIndex = 4 })
	round(b1, 1); round(b2, 1)

	local list = new("Frame", { Parent = card, Name = "List", BackgroundTransparency = 1, Position = UDim2.fromOffset(8, HEAD), Size = UDim2.new(1, -16, 0, 0), ZIndex = 3 })
	new("UIListLayout", { Parent = list, Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder })
	local buttons = {}

	local function listHeight() return #options * ITEM + math.max(#options - 1, 0) * 2 + 8 end
	local function paint()
		for name, b in pairs(buttons) do
			local on = (name == tostring(selected))
			tween(b, ti(0.15), { BackgroundTransparency = on and 0.9 or 1 })
			b.TextColor3 = on and C.TEXT or C.SUB
		end
		val.Text = selected ~= nil and tostring(selected) or (o.Placeholder or "Select")
	end
	local function setOpen(v)
		open = v
		tween(card, ti(0.3), { Size = UDim2.new(1, -6, 0, open and (HEAD + listHeight()) or HEAD) })
		tween(chev, ti(0.3), { Rotation = open and 180 or 0 })
	end
	local function set(v, silent)
		selected = v
		paint()
		if not silent and o.Callback then task.spawn(o.Callback, v) end
	end
	local function build()
		for _, b in pairs(buttons) do b:Destroy() end
		buttons = {}
		for i, opt in ipairs(options) do
			local b = new("TextButton", {
				Parent = list, Name = tostring(opt), LayoutOrder = i, Text = tostring(opt), AutoButtonColor = false,
				Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = C.SUB, BackgroundColor3 = WHITE, BackgroundTransparency = 1,
				BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, ITEM), ZIndex = 4, TextXAlignment = Enum.TextXAlignment.Left,
			})
			new("UIPadding", { Parent = b, PaddingLeft = UDim.new(0, 10) })
			round(b, 8)
			b.MouseEnter:Connect(function() if tostring(selected) ~= b.Name then tween(b, ti(0.12), { BackgroundTransparency = 0.95 }) end end)
			b.MouseLeave:Connect(function() if tostring(selected) ~= b.Name then tween(b, ti(0.15), { BackgroundTransparency = 1 }) end end)
			b.Activated:Connect(function() set(opt) setOpen(false) end)
			buttons[tostring(opt)] = b
		end
		paint()
	end
	build()
	head.Activated:Connect(function() setOpen(not open) end)
	head.MouseEnter:Connect(function() b1.BackgroundColor3 = ICON_HOVER b2.BackgroundColor3 = ICON_HOVER end)
	head.MouseLeave:Connect(function() b1.BackgroundColor3 = ICON_OFF b2.BackgroundColor3 = ICON_OFF end)

	return {
		Card = card,
		Set = function(_, v, silent) set(v, silent) end,
		Get = function() return selected end,
		Refresh = function(_, newOptions) options = newOptions or {} build() if open then setOpen(true) end end,
	}
end

function Tab:AddTextbox(o)
	local card = newCard(self, 48, false)
	label({ Parent = card, Text = o.Name or "Textbox", Position = UDim2.fromOffset(14, 0), Size = UDim2.new(0.5, -20, 1, 0) })
	local field = new("Frame", { Parent = card, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.new(0.5, -10, 0, 30), ZIndex = 4 })
	local stroke = pageSurface(field, false)
	field.BackgroundTransparency = 0.955
	field:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0, 9)
	local box = new("TextBox", {
		Parent = field, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(10, 0),
		Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Color3.fromRGB(235, 235, 235), PlaceholderColor3 = Color3.fromRGB(120, 120, 126),
		PlaceholderText = o.Placeholder or "Type here...", Text = o.Default or "", TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false, ClipsDescendants = true, ZIndex = 5,
	})
	box.Focused:Connect(function() tween(stroke, TweenInfo.new(0.14), { Transparency = 0.7 }) end)
	box.FocusLost:Connect(function(enter)
		tween(stroke, TweenInfo.new(0.18), { Transparency = 0.94 })
		if o.Callback and (enter or not o.EnterOnly) then task.spawn(o.Callback, box.Text, enter) end
	end)
	return { Card = card, Set = function(_, t) box.Text = t end, Get = function() return box.Text end }
end

function Tab:AddKeybind(o)
	local key = o.Default
	local listening = false
	local card = newCard(self, 48, false)
	label({ Parent = card, Text = o.Name or "Keybind", Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -120, 1, 0) })
	local btn = new("TextButton", {
		Parent = card, AutoButtonColor = false, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(84, 30), Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = C.TEXT, ZIndex = 4, Text = "",
	})
	pageSurface(btn, true)
	btn.BackgroundTransparency = 0.955
	btn:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0, 9)
	pressable(btn, 0.95)
	local function paint() btn.Text = listening and "..." or (key and key.Name or "None") end
	paint()
	btn.Activated:Connect(function() listening = true paint() end)
	UserInputService.InputBegan:Connect(function(input, gp)
		if listening and input.UserInputType == Enum.UserInputType.Keyboard then
			listening = false
			if input.KeyCode ~= Enum.KeyCode.Escape then
				key = input.KeyCode
				if o.Changed then task.spawn(o.Changed, key) end
			end
			paint()
		elseif not gp and key and input.KeyCode == key and not listening then
			if o.Callback then task.spawn(o.Callback, key) end
		end
	end)
	return { Card = card, Set = function(_, k) key = k paint() end, Get = function() return key end }
end

--// Window -----------------------------------------------------------------
local Window = {}
Window.__index = Window

local DOCK = { pad = 6, h = 40, w = 40, gap = 2 }
local CLOSED_H = 52
local OPEN_W, OPEN_H = 880, 500   -- ขนาดอ้างอิงตอนคำนวณ scale (กว้างพอสำหรับหน้า Settings)
local PANEL_GAP = 10
local DECK_W, DECK_H = 870, 416

local function keyFromName(name)
	if type(name) ~= "string" then return nil end
	local ok, kc = pcall(function() return Enum.KeyCode[name] end)
	return ok and kc or nil
end

--[[ Library:CreateWindow({
	Name         = "Novoline",
	Keybind      = Enum.KeyCode.RightShift,
	ContentSize  = Vector2.new(540, 350),
	StartVisible = true,
	RememberTab  = false,   -- false = เปิด UI ทีไรไปแท็บแรก (Home) ทุกครั้ง
	Home         = { ... } | false,
	Settings     = true | false,
}) ]]
function Library:CreateWindow(opts)
	opts = opts or {}
	local self = setmetatable({}, Window)
	self.Name = opts.Name or "Novoline"
	self.Keybind = keyFromName(Store.Keybind) or opts.Keybind or Enum.KeyCode.RightShift
	self.ContentSize = opts.ContentSize or Vector2.new(540, 350)
	self.RememberTab = opts.RememberTab == true
	self.Tabs = {}
	self.ActiveIndex = 0
	self.Expanded = false
	self.Visible = false
	self._token = 0
	self._conns = {}
	self._hoverToken = 0

	-- ScreenGui + pill
	local sg = new("ScreenGui", {
		Name = "NV_WrapBar", IgnoreGuiInset = true, ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 55,
	})
	mountGui(sg)
	self.Gui = sg

	local wrap = new("Frame", {
		Parent = sg, Name = "Wrap", AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -24),
		Size = UDim2.fromOffset(DOCK.pad * 2, CLOSED_H), BackgroundColor3 = WHITE, BackgroundTransparency = 0,
		BorderSizePixel = 0, ClipsDescendants = false, Active = true, ZIndex = 11, Visible = false,
	})
	glass(wrap, 26)
	local uiScale = new("UIScale", { Parent = wrap })
	self.Wrap, self.UIScale = wrap, uiScale

	local navbar = new("Frame", {
		Parent = wrap, Name = "Navbar", AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, 0),
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 50,
	})
	self.Navbar = navbar

	-- capsule (ตัวบอกแท็บที่เลือก)
	local capsule = new("Frame", {
		Parent = navbar, Name = "Capsule", BackgroundColor3 = WHITE, BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.fromOffset(DOCK.w, DOCK.h), Position = UDim2.fromOffset(DOCK.pad, DOCK.pad), ZIndex = 52,
	})
	round(capsule, "full")
	local capGrad = new("UIGradient", { Parent = capsule, Rotation = 90 })
	toneSeq(capGrad, Color3.fromRGB(46, 46, 49), Color3.fromRGB(32, 32, 35), 0.22)
	local capRim = new("UIStroke", { Parent = capsule, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = WHITE, Thickness = 1, Transparency = 1 })
	pcall(function() capRim.BorderStrokePosition = Enum.BorderStrokePosition.Inner end)
	new("UIGradient", {
		Parent = capRim, Rotation = 90,
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.86), NumberSequenceKeypoint.new(0.4, 0.96), NumberSequenceKeypoint.new(1, 0.97) }),
	})
	self.Capsule, self.CapsuleRim = capsule, capRim

	-- panel (CanvasGroup เหนือ pill) ใช้กับหน้า Home และแท็บทั่วไป
	local cw, ch = self.ContentSize.X, self.ContentSize.Y
	local panel = new("CanvasGroup", {
		Parent = wrap, Name = "ContentPanel", AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 0, -PANEL_GAP),
		Size = UDim2.fromOffset(cw + 40, ch + 42), BackgroundColor3 = WHITE, BackgroundTransparency = 1,
		GroupTransparency = 1, Visible = false, ZIndex = 12,
	})
	glass(panel, 32)
	panel.ClipsDescendants = true
	self.Panel = panel

	-- wallpaper (ตั้งค่าได้ใน Settings > Appearance)
	local wall = new("ImageLabel", {
		Parent = panel, Name = "Wallpaper", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
		ScaleType = Enum.ScaleType.Crop, ImageTransparency = 0.5, ZIndex = 3, Visible = false, Image = "",
	})
	round(wall, 32)
	self.Wallpaper = wall

	local area = new("Frame", {
		Parent = panel, Name = "ContentArea", Position = UDim2.fromOffset(20, 22), Size = UDim2.fromOffset(cw, ch),
		BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 16,
	})
	self.Area = area

	-- deck: ชุดการ์ดกระจกลอย ใช้กับหน้า Settings
	self.Deck = new("Frame", {
		Parent = wrap, Name = "Deck", AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 0, -PANEL_GAP),
		Size = UDim2.fromOffset(DECK_W, DECK_H), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 12,
	})

	-- grip สำหรับลาก
	local drag = new("TextButton", {
		Parent = panel, Name = "WindowDragHandle", Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -24, 0, 32), ZIndex = 20,
	})
	local grip = new("Frame", {
		Parent = drag, Name = "Grip", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(34, 3), BackgroundColor3 = Color3.fromRGB(165, 170, 181), BackgroundTransparency = 0.58,
		BorderSizePixel = 0, ZIndex = 21,
	})
	round(grip, "full")

	self:_setupDrag()
	self:_bindDrag(drag)
	self:_setupScale()
	self:_setupInput()
	self:_hoverWatch(wrap)
	self:_hoverWatch(panel)
	if isMobile then self:_setupFab() end
	Library._hookFps()

	table.insert(Library.Windows, self)

	-- แท็บมาตรฐานของต้นฉบับ: Home (แรกสุด) และ Settings (ท้ายสุดเสมอ)
	if opts.Home ~= false then
		self:AddHome(type(opts.Home) == "table" and opts.Home or {})
	end
	if opts.Settings ~= false then
		self:AddSettings()
	end

	self:_applyStore()

	if opts.StartVisible ~= false then
		self:SetVisible(true, true)
	end

	if Store.Welcome then
		task.delay(0.8, function()
			Library:Notify({
				Title = self.Name,
				Text = "Loaded. Press " .. self.Keybind.Name .. " to open or close the interface.",
				Type = "info", Duration = 5,
			})
		end)
	end
	return self
end

-- นำค่าที่บันทึกไว้มาใช้ (wallpaper / FPS)
function Window:_applyStore()
	if Store.Wallpaper ~= "" then self:SetWallpaper(Store.Wallpaper, true) end
	Library._applyFps()
end

--// FPS (Unlock FPS / Cap FPS in background) -------------------------------
local fpsCapped = false
local function fpsCap(n)
	if not isMobile and typeof(setfpscap) == "function" then pcall(setfpscap, n) end
end
-- เรียกเมื่อสวิตช์ Unlock FPS เปลี่ยน (ไม่แตะค่า FPS ของผู้ใช้ถ้าไม่เคยเปิดฟีเจอร์นี้)
function Library._applyFps(changed)
	if Store.UnlockFps then
		fpsCap(0)
	elseif changed then
		fpsCap(60)
	end
end
function Library._hookFps()
	if Library._fpsHooked then return end
	Library._fpsHooked = true
	local token = 0
	UserInputService.WindowFocusReleased:Connect(function()
		if not Store.BgFpsCap then return end
		token = token + 1
		local t = token
		task.delay(0.35, function()
			if t == token and Store.BgFpsCap then
				fpsCapped = true
				fpsCap(24)
			end
		end)
	end)
	UserInputService.WindowFocused:Connect(function()
		token = token + 1
		if fpsCapped then
			fpsCapped = false
			fpsCap(Store.UnlockFps and 0 or 60)
		end
	end)
end

--// auto-collapse (Auto-collapse contents) --------------------------------
function Window:_armIdle()
	self._hoverToken = self._hoverToken + 1
	local token = self._hoverToken
	if isMobile or not Store.AutoCollapse then return end
	task.delay(5.3, function()
		if token ~= self._hoverToken or not Store.AutoCollapse or not self.Visible then return end
		if self._dragging or UserInputService:GetFocusedTextBox() then return end
		if self.Expanded then self:SetExpanded(false) end
	end)
end

function Window:_hoverWatch(obj)
	obj.MouseEnter:Connect(function() self._hoverToken = self._hoverToken + 1 end)
	obj.MouseLeave:Connect(function() self:_armIdle() end)
end

--// scale + clamp ---------------------------------------------------------
function Window:_computeScale()
	local camera = workspace.CurrentCamera
	local vp = camera and camera.ViewportSize or Vector2.new(1280, 720)
	return math.max(0.1, math.min(1, (vp.X - 24) / OPEN_W, (vp.Y - 116) / OPEN_H))
end

function Window:_clamp()
	local camera = workspace.CurrentCamera
	local vp = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local s = self._base or self.UIScale.Scale
	local w, h = OPEN_W * s, OPEN_H * s
	local pos = self.Wrap.Position
	local x = pos.X.Scale * vp.X + pos.X.Offset
	local y = pos.Y.Scale * vp.Y + pos.Y.Offset
	x = math.clamp(x, w / 2 + 8, math.max(w / 2 + 8, vp.X - w / 2 - 8))
	y = math.clamp(y, h + 8, math.max(h + 8, vp.Y - 8))
	self.Wrap.Position = UDim2.new(pos.X.Scale, x - pos.X.Scale * vp.X, pos.Y.Scale, y - pos.Y.Scale * vp.Y)
end

function Window:_setupScale()
	local function update()
		self._base = self:_computeScale()
		if self.Visible or not self._popTween then self.UIScale.Scale = self._base end
		self:_clamp()
	end
	update()
	local cam = workspace.CurrentCamera
	if cam then table.insert(self._conns, cam:GetPropertyChangedSignal("ViewportSize"):Connect(update)) end
end

function Window:_setupDrag()
	local pointer, origin, startPos
	self._beginDrag = function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
		pointer = input
		origin = Vector2.new(input.Position.X, input.Position.Y)
		startPos = self.Wrap.Position
		self._dragging = true
		self._hoverToken = self._hoverToken + 1
	end
	table.insert(self._conns, UserInputService.InputChanged:Connect(function(input)
		if not pointer then return end
		if pointer.UserInputType == Enum.UserInputType.Touch then
			if input ~= pointer then return end
		elseif input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end
		local d = Vector2.new(input.Position.X, input.Position.Y) - origin
		self.Wrap.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		self:_clamp()
	end))
	table.insert(self._conns, UserInputService.InputEnded:Connect(function(input)
		if input == pointer or (pointer and pointer.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1) then
			pointer = nil
			self._dragging = false
		end
	end))
end

-- ให้ element ใดก็ได้เป็นที่จับลากหน้าต่าง
function Window:_bindDrag(handle)
	handle.InputBegan:Connect(function(input) self._beginDrag(input) end)
end

function Window:_setupInput()
	table.insert(self._conns, UserInputService.InputBegan:Connect(function(input, gp)
		if gp or self._listening or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
		if input.KeyCode == self.Keybind then
			if os.clock() - (self._toggleAt or 0) < 0.35 then return end
			self._toggleAt = os.clock()
			self:SetVisible(not self.Visible)
		elseif input.KeyCode == Enum.KeyCode.Escape and self.Visible then
			if self.Expanded then self:SetExpanded(false) else self:SetVisible(false) end
		end
	end))
end

function Window:_setupFab()
	local fabGui = new("ScreenGui", { Name = "NV_FAB", IgnoreGuiInset = true, ResetOnSpawn = false, DisplayOrder = 99999, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
	mountGui(fabGui)
	local fab = new("TextButton", {
		Parent = fabGui, Name = "MobileToggle", Text = self.Name, AutoButtonColor = false, Font = Enum.Font.GothamBold, TextSize = 13,
		TextColor3 = WHITE, BackgroundColor3 = C.CARD, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 10),
		Size = UDim2.fromOffset(118, 32), ZIndex = 200,
	})
	glass(fab, 16)
	pressable(fab, 0.94)
	fab.Activated:Connect(function() self:SetVisible(not self.Visible) end)
	self.Fab = fabGui
end

--// navbar layout ---------------------------------------------------------
function Window:_layout(instant)
	local motion = ti(0.38)
	local x, selX, selW, actX = DOCK.pad, nil, nil, nil
	for i, tab in ipairs(self.Tabs) do
		local nav = tab.Nav
		local selected = (i == self.ActiveIndex) and self.Expanded
		local w = selected and nav.wide or DOCK.w
		if nav.layoutTween then nav.layoutTween:Cancel() end
		local goal = { Size = UDim2.fromOffset(w, DOCK.h), Position = UDim2.fromOffset(x, DOCK.pad) }
		if instant then
			nav.button.Size, nav.button.Position = goal.Size, goal.Position
		else
			nav.layoutTween = tween(nav.button, motion, goal)
		end
		if selected then selX, selW = x, w end
		if i == self.ActiveIndex then actX = x end
		nav.select(selected, instant)
		x = x + w + DOCK.gap
	end

	local barSize = UDim2.fromOffset(x - DOCK.gap + DOCK.pad, CLOSED_H)
	if self._barTween then self._barTween:Cancel() end
	if instant then self.Wrap.Size = barSize else self._barTween = tween(self.Wrap, motion, { Size = barSize }) end

	local ind, rim = self.Capsule, self.CapsuleRim
	if self._indTween then self._indTween:Cancel() end
	local fade = ti(0.22, Enum.EasingStyle.Quad)
	if selX then
		local goal = { Position = UDim2.fromOffset(selX, DOCK.pad), Size = UDim2.fromOffset(selW, DOCK.h), BackgroundTransparency = 0 }
		if instant then
			ind.Position, ind.Size, ind.BackgroundTransparency = goal.Position, goal.Size, 0
			rim.Transparency = 0
		else
			if ind.BackgroundTransparency > 0.99 then
				-- โผล่ขึ้นมาจากไอคอนที่เลือก ก่อนยืดเป็นแคปซูล
				ind.Position = goal.Position
				ind.Size = UDim2.fromOffset(DOCK.w, DOCK.h)
			end
			self._indTween = tween(ind, motion, goal)
			tween(rim, motion, { Transparency = 0 })
		end
	else
		local shape = { Size = UDim2.fromOffset(DOCK.w, DOCK.h) }
		if actX then shape.Position = UDim2.fromOffset(actX, DOCK.pad) end
		if instant then
			ind.Size = shape.Size
			if shape.Position then ind.Position = shape.Position end
			ind.BackgroundTransparency = 1
			rim.Transparency = 1
		else
			tween(ind, motion, shape)
			self._indTween = tween(ind, fade, { BackgroundTransparency = 1 })
			tween(rim, fade, { Transparency = 1 })
		end
	end
end

function Window:_addNav(tab)
	local text = tab.Name
	local textW = textWidth(text, 12, Enum.Font.GothamBold)
	local quick = ti(0.22)
	local slide = ti(0.38)

	local item = new("TextButton", {
		Parent = self.Navbar, Name = text, Text = "", AutoButtonColor = false,
		Position = UDim2.fromOffset(DOCK.pad, DOCK.pad), Size = UDim2.fromOffset(DOCK.w, DOCK.h),
		BackgroundColor3 = WHITE, BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 53, ClipsDescendants = true,
	})
	round(item, "full")
	pressable(item, 0.94)

	local ic = createIcon(tab.Icon, item, ICON_OFF, 54, 20)
	ic.Frame.Position = UDim2.fromOffset(DOCK.w / 2, DOCK.h / 2)

	local name = label({
		Parent = item, Text = text, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = ICON_ON, TextTransparency = 1,
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 36, 0.5, 0), Size = UDim2.fromOffset(textW + 4, 16),
		TextTruncate = Enum.TextTruncate.None, ZIndex = 54,
	})

	local selected, hovered = false, false
	local anims = {}
	local function animate(key, obj, info, goal, instant)
		if anims[key] then anims[key]:Cancel() end
		if instant then
			for k, v in pairs(goal) do obj[k] = v end
		else
			anims[key] = tween(obj, info, goal)
		end
	end
	local function paint(instant)
		local over = hovered and not selected
		animate("fill", item, quick, { BackgroundTransparency = over and 0.92 or 1 }, instant)
		local col = selected and ICON_ON or (over and ICON_HOVER or ICON_OFF)
		if instant then ic.set(col) else ic.tween(quick, col) end
		animate("iconPos", ic.Frame, slide, { Position = UDim2.fromOffset(selected and 24 or DOCK.w / 2, DOCK.h / 2) }, instant)
		animate("name", name, TweenInfo.new(selected and 0.3 or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, selected and 0.08 or 0),
			{ TextTransparency = selected and 0 or 1 }, instant)
	end
	item.MouseEnter:Connect(function() hovered = true paint() end)
	item.MouseLeave:Connect(function() hovered = false paint() end)

	local nav = {
		button = item, wide = 14 + 20 + 6 + textW + 16,
		select = function(on, instant) selected = on paint(instant) end,
	}
	item.Activated:Connect(function()
		if os.clock() - (self._tabAt or 0) < 0.25 then return end
		self._tabAt = os.clock()
		local idx = table.find(self.Tabs, tab)
		if self.ActiveIndex == idx and self.Expanded then
			self:SetExpanded(false)
		else
			self:SelectTab(idx)
		end
	end)
	paint(true)
	return nav
end

--// pages / tabs ----------------------------------------------------------
function Window:_newPage(name)
	local page = new("CanvasGroup", {
		Parent = self.Area, Name = "Content_" .. name, BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1), Visible = false, GroupTransparency = 1, ZIndex = 20,
	})
	return page
end

-- ใส่แท็บใหม่: Home อยู่หน้าสุด, Settings อยู่ท้ายสุดเสมอ
function Window:_insertTab(tab, index)
	if not index and self.SettingsTab and tab ~= self.SettingsTab then
		index = table.find(self.Tabs, self.SettingsTab)
	end
	if index then table.insert(self.Tabs, index, tab) else table.insert(self.Tabs, tab) end
	tab.Nav = self:_addNav(tab)
	if self._activeRef then self.ActiveIndex = table.find(self.Tabs, self._activeRef) or self.ActiveIndex end
	self:_layout(true)
end

function Window:AddTab(opts)
	opts = type(opts) == "string" and { Name = opts } or opts
	local tab = setmetatable({
		Name = opts.Name or ("Tab " .. (#self.Tabs + 1)), Icon = opts.Icon or "apps",
		Height = opts.Height or self.ContentSize.Y, Window = self, _order = 0,
	}, Tab)
	tab.Page = self:_newPage(tab.Name)
	local scroll = new("ScrollingFrame", {
		Parent = tab.Page, Name = "Scroll", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
		ScrollBarThickness = 3, ScrollBarImageColor3 = Color3.fromRGB(90, 90, 90), ScrollBarImageTransparency = 0.4,
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y,
		ElasticBehavior = Enum.ElasticBehavior.Never, ZIndex = 21, TopImage = "", BottomImage = "",
	})
	new("UIListLayout", { Parent = scroll, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })
	new("UIPadding", { Parent = scroll, PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6) })
	tab.Scroll = scroll
	self:_insertTab(tab, opts._index)
	return tab
end

-- แท็บแบบ "deck" (การ์ดกระจกลอยหลายใบ เหมือนหน้า Settings ของต้นฉบับ)
function Window:AddDeckTab(opts)
	opts = type(opts) == "string" and { Name = opts } or opts
	local tab = setmetatable({
		Name = opts.Name or ("Tab " .. (#self.Tabs + 1)), Icon = opts.Icon or "apps",
		IsDeck = true, Cards = {}, Window = self, _order = 0,
	}, Tab)
	self:_insertTab(tab, opts._index)
	return tab
end

-- corner: "tl" | "tr" | "bl" | "br" ; x,y = ระยะจากมุมนั้น
function Window:_deckCard(tab, corner, x, y, w, h)
	local right = corner == "tr" or corner == "br"
	local bottom = corner == "bl" or corner == "br"
	local rest = UDim2.new(right and 1 or 0, right and -x or x, bottom and 1 or 0, bottom and -y or y)
	local c = new("CanvasGroup", {
		Parent = self.Deck, Name = "Card", AnchorPoint = Vector2.new(right and 1 or 0, bottom and 1 or 0),
		Position = rest, Size = UDim2.fromOffset(w, h), BackgroundTransparency = 1, BorderSizePixel = 0,
		GroupTransparency = 1, Visible = false, ZIndex = 14,
	})
	glass(c, h <= 60 and math.floor(h / 2) or 28)
	self:_hoverWatch(c)
	tab.Cards[#tab.Cards + 1] = { frame = c, rest = rest }
	return c
end

function Tab:Card(corner, x, y, w, h)
	return self.Window:_deckCard(self, corner, x, y, w, h)
end

function Window:GetTab(nameOrIndex)
	if type(nameOrIndex) == "number" then return self.Tabs[nameOrIndex], nameOrIndex end
	for i, t in ipairs(self.Tabs) do if t.Name == nameOrIndex then return t, i end end
end

--// panel + deck show/hide ------------------------------------------------
function Window:_fadePanel(show, animate)
	local panel = self.Panel
	self._panelTok = (self._panelTok or 0) + 1
	local tok = self._panelTok
	local rest = UDim2.new(0.5, 0, 0, -PANEL_GAP)
	if show then
		panel.Visible = true
		if animate then
			if panel.GroupTransparency > 0.99 then panel.Position = UDim2.new(0.5, 0, 0, -PANEL_GAP + 16) end
			tween(panel, ti(0.38), { GroupTransparency = 0, Position = rest })
		else
			panel.GroupTransparency = 0
			panel.Position = rest
		end
	else
		if not panel.Visible then return end
		if animate then
			local t = tween(panel, ti(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
				{ GroupTransparency = 1, Position = UDim2.new(0.5, 0, 0, -PANEL_GAP + 12) })
			if t then t.Completed:Connect(function() if tok == self._panelTok then panel.Visible = false end end) end
		else
			panel.GroupTransparency = 1
			panel.Visible = false
		end
	end
end

function Window:_riseCards(tab, animate)
	tab._tok = (tab._tok or 0) + 1
	local tok = tab._tok
	for i, card in ipairs(tab.Cards) do
		local f = card.frame
		f.Visible = true
		if animate then
			f.GroupTransparency = 1
			f.Position = card.rest + UDim2.fromOffset(0, 14)
			task.delay((i - 1) * 0.035, function()
				if f.Parent and tok == tab._tok then
					tween(f, ti(0.4), { GroupTransparency = 0, Position = card.rest })
				end
			end)
		else
			f.GroupTransparency = 0
			f.Position = card.rest
		end
	end
end

function Window:_hideCards(tab, instant)
	tab._tok = (tab._tok or 0) + 1
	local tok = tab._tok
	for _, card in ipairs(tab.Cards) do
		local f = card.frame
		if f.Visible then
			if instant then
				f.GroupTransparency = 1
				f.Visible = false
			else
				local t = tween(f, ti(0.2, Enum.EasingStyle.Quad), { GroupTransparency = 1 })
				if t then t.Completed:Connect(function() if tok == tab._tok then f.Visible = false end end) end
			end
		end
	end
end

function Window:_showPage(tab, animate)
	for _, t in ipairs(self.Tabs) do
		if t ~= tab then
			if t.IsDeck then
				self:_hideCards(t, not animate)
			else
				t.Page.Visible = false
				t.Page.GroupTransparency = 1
			end
			if t.OnHide then t.OnHide() end
		end
	end
	if tab.IsDeck then
		self:_fadePanel(false, animate)
		self:_riseCards(tab, animate)
	else
		self:_fadePanel(true, animate)
		tab.Page.Visible = true
		if animate then
			tab.Page.GroupTransparency = 1
			tween(tab.Page, ti(0.3, Enum.EasingStyle.Quad), { GroupTransparency = 0 })
		else
			tab.Page.GroupTransparency = 0
		end
		-- ปรับความสูงของ panel ตามแท็บ
		local h = tab.Height
		tween(self.Area, ti(0.3), { Size = UDim2.fromOffset(self.ContentSize.X, h) })
		tween(self.Panel, ti(0.3), { Size = UDim2.fromOffset(self.ContentSize.X + 40, h + 42) })
	end
	if tab.OnShow then tab.OnShow(animate) end
end

function Window:SetExpanded(expanded, instant)
	self.Expanded = expanded
	self._token = self._token + 1
	self:_layout(instant)
	local tab = self.Tabs[self.ActiveIndex]
	if expanded and tab then
		self:_showPage(tab, not instant)
	else
		self:_fadePanel(false, not instant)
		for _, t in ipairs(self.Tabs) do
			if t.IsDeck then self:_hideCards(t, instant) end
			if t.OnHide then t.OnHide() end
		end
	end
end

function Window:SelectTab(nameOrIndex, instant)
	local tab, idx = self:GetTab(nameOrIndex)
	if not tab then return end
	local changed = self._activeRef ~= tab
	self.ActiveIndex = idx
	self._activeRef = tab
	if self.Expanded then
		self:_layout(instant)
		if changed then self:_showPage(tab, not instant) end
	else
		self:SetExpanded(true, instant)
	end
end

function Window:SetVisible(visible, instant)
	self.Visible = visible and true or false
	local wrap, sc = self.Wrap, self.UIScale
	local base = self._base or self:_computeScale()
	if self._popTween then self._popTween:Cancel() end
	if self.Visible then
		wrap.Visible = true
		self:_clamp()
		if instant then
			sc.Scale = base
		else
			-- เด้งเปิด (popIn)
			sc.Scale = base * 0.86
			self._popTween = tween(sc, TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = base })
		end
		self:_layout(true)
		-- เปิด UI ทีไร พาไปแท็บแรกทุกครั้ง (หรือแท็บล่าสุดถ้า RememberTab = true)
		local target = 1
		if self.RememberTab and self._activeRef then target = table.find(self.Tabs, self._activeRef) or 1 end
		self:SelectTab(target, instant)
	else
		if self.Expanded then self:SetExpanded(false, instant) end
		if instant then
			wrap.Visible = false
			sc.Scale = base
		else
			-- ย่อปิด (popOut)
			self._popTween = tween(sc, ti(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Scale = base * 0.82 })
			task.delay(0.24, function()
				if not self.Visible and wrap.Parent then
					wrap.Visible = false
					sc.Scale = self._base or base
				end
			end)
		end
	end
end

function Window:Toggle() self:SetVisible(not self.Visible) end

function Window:SetKeybind(keyCode)
	self.Keybind = keyCode
	Store.Keybind = keyCode.Name
	saveStore()
end

function Window:SetWallpaper(source, silent)
	source = tostring(source or ""):match("^%s*(.-)%s*$")
	Store.Wallpaper = source
	if not silent then saveStore() end
	local wall = self.Wallpaper
	if source == "" then
		wall.Image = ""
		wall.Visible = false
		return
	end
	task.spawn(function()
		local ok, asset = pcall(resolveImage, source)
		if ok and asset and wall.Parent then
			wall.Image = asset
			wall.ImageTransparency = math.clamp(Store.SeeThrough / 100, 0, 1)
			wall.Visible = true
		else
			Library:Notify({ Title = "Wallpaper", Text = "Couldn't load that image.", Type = "error" })
		end
	end)
end

function Window:SetWallpaperOpacity(value, silent)
	Store.SeeThrough = math.clamp(tonumber(value) or 50, 0, 100)
	if not silent then saveStore() end
	if self.Wallpaper.Image ~= "" then
		self.Wallpaper.ImageTransparency = Store.SeeThrough / 100
	end
end

function Window:Destroy()
	for _, c in ipairs(self._conns) do c:Disconnect() end
	if self.Gui then self.Gui:Destroy() end
	if self.Fab then self.Fab:Destroy() end
	local i = table.find(Library.Windows, self)
	if i then table.remove(Library.Windows, i) end
end

function Window:Notify(spec) return Library:Notify(spec) end

--// Home page --------------------------------------------------------------
-- opts = {
--   Banner    = "rbxassetid://..."  (ถ้าใส่ จะใช้รูปนี้แทนรูปแมพ)
--   MapArt    = true                (ใช้รูปของแมพที่เล่นอยู่เป็นพื้นหลัง — ค่าเริ่มต้น เปิด)
--   Greeting  = "Welcome, %s"
--   Tiles     = { { Title, Subtitle, Icon, Width(0..1), Badge, Tab = "ชื่อแท็บ", Callback, Discord = true } }
--   Discord   = "https://discord.gg/xxxx"
--   Server    = true/false, Executor = true/false, ServerTab = "ชื่อแท็บ"
-- }
function Window:AddHome(opts)
	opts = opts or {}
	local tab = self:AddTab({ Name = "Home", Icon = "home", Height = self.ContentSize.Y, _index = 1 })
	tab.Scroll.Visible = false
	local page = tab.Page

	-- รูปพื้นหลังหัวหน้า Home ยาวเต็ม panel (เหมือน Panoramic Home ของต้นฉบับ)
	local art = new("Frame", {
		Parent = self.Panel, Name = "HomeHeaderArtwork", BackgroundTransparency = 1, BorderSizePixel = 0,
		ClipsDescendants = true, Size = UDim2.new(1, 0, 0, 270), ZIndex = 13, Visible = false,
	})
	local img = new("ImageLabel", {
		Parent = art, Name = "Artwork", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
		ScaleType = Enum.ScaleType.Crop, ImageTransparency = 1, ZIndex = 13, Image = "",
	})
	new("UIGradient", {
		Parent = img, Name = "ArtworkEdgeFade", Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(0.72, 0.25),
			NumberSequenceKeypoint.new(0.88, 0.7), NumberSequenceKeypoint.new(1, 1),
		}),
	})
	-- เงาจาง ๆ ให้ตัวหนังสืออ่านง่ายบนรูปแมพที่สว่างหรือลายเยอะ
	local scrim = new("Frame", {
		Parent = art, Name = "TextScrim", BackgroundColor3 = Color3.fromRGB(12, 12, 12), BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1), ZIndex = 14,
	})
	new("UIGradient", {
		Parent = scrim, Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.45, 1),
			NumberSequenceKeypoint.new(0.7, 0.72), NumberSequenceKeypoint.new(1, 0.45),
		}),
	})

	local function setArt(asset)
		if not img.Parent or not asset then return end
		img.Image = asset
		if art.Visible then tween(img, ti(0.5, Enum.EasingStyle.Quad), { ImageTransparency = 0.06 }) end
	end
	local mapName = nil
	if opts.Banner and opts.Banner ~= "" then
		img.Image = opts.Banner
	elseif opts.MapArt ~= false then
		fetchMapArt(function(asset, name)
			if name then mapName = name end
			setArt(asset)
		end)
	end

	local landing = new("Frame", {
		Parent = page, Name = "HomeLanding", BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1), ClipsDescendants = true, ZIndex = 30,
	})

	-- banner (โปร่งใส: ใช้เป็นที่วาง avatar / ชื่อ)
	local banner = new("Frame", {
		Parent = landing, Name = "HomeBanner", Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, 0, 0, 210),
		ZIndex = 31, BorderSizePixel = 0, BackgroundTransparency = 1,
	})

	local avatar = new("ImageLabel", {
		Parent = banner, Name = "ProfileAvatar", BorderSizePixel = 0, BackgroundTransparency = 0.4, BackgroundColor3 = C.CARD,
		Position = UDim2.fromOffset(12, 150), Size = UDim2.fromOffset(44, 44), ZIndex = 35,
		Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150",
	})
	round(avatar, "full")

	local greeting = label({
		Parent = banner, Name = "Greeting", Text = string.format(opts.Greeting or "Welcome, %s", LocalPlayer.DisplayName),
		Font = Enum.Font.GothamBold, TextSize = 22, TextColor3 = WHITE, TextYAlignment = Enum.TextYAlignment.Top,
		Position = UDim2.fromOffset(70, 149), Size = UDim2.new(1, -132, 0, 24), ZIndex = 39,
	})
	do -- ข้อความไล่เฉดเคลื่อนไหว (gradientText)
		local g = new("UIGradient", { Parent = greeting, Name = "LiveGradient", Offset = Vector2.new(-0.45, 0), Color = greetingSequence() })
		greetings[#greetings + 1] = g
		TweenService:Create(g, TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Offset = Vector2.new(0.45, 0) }):Play()
	end
	label({
		Parent = banner, Name = "Identity", Text = "@" .. LocalPlayer.Name, TextSize = 13, TextColor3 = Color3.fromRGB(211, 211, 211),
		TextYAlignment = Enum.TextYAlignment.Top, Position = UDim2.fromOffset(70, 175), Size = UDim2.new(1, -132, 0, 16), ZIndex = 39,
	})

	-- tiles
	local tilesHolder = new("Frame", {
		Parent = landing, Name = "HomeTiles", BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.fromOffset(1, 222), Size = UDim2.new(1, -2, 0, 80), ZIndex = 32,
	})
	local tiles = opts.Tiles or {
		{ Title = "Commands", Subtitle = "Browse all commands", Icon = "code", Width = 0.6, Tab = "Commands" },
		{ Title = "Discord", Subtitle = "Join our community", Icon = "discord", Width = 0.4, Discord = true },
	}
	self.HomeBadges = {}
	local x = 0
	for index, spec in ipairs(tiles) do
		local width = spec.Width or (1 / #tiles)
		local button = new("TextButton", {
			Parent = tilesHolder, Name = "Tile_" .. (spec.Title or index), Text = "", AutoButtonColor = false,
			Position = UDim2.new(x, x > 0 and 5 or 0, 0, 0), Size = UDim2.new(width, -5, 1, 0), BorderSizePixel = 0,
			ClipsDescendants = true, ZIndex = 33,
		})
		pageSurface(button, false)
		button:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0, 16)
		pressable(button, 0.97)
		local icon = createIcon(spec.Icon or "apps", button, WHITE, 35, 24)
		icon.Frame.Position = UDim2.fromOffset(28, 40)
		local badgeW = spec.Badge ~= nil and 70 or 0
		label({ Parent = button, Name = "Title", Text = spec.Title or "", Font = Enum.Font.GothamBold, TextSize = 17, TextColor3 = C.TEXT,
			Position = UDim2.fromOffset(52, 16), Size = UDim2.new(1, -64 - badgeW, 0, 24), ZIndex = 37 })
		label({ Parent = button, Name = "Subtitle", Text = spec.Subtitle or "", TextSize = 12, TextColor3 = C.SUB,
			Position = UDim2.fromOffset(52, 45), Size = UDim2.new(1, -64, 0, 18), ZIndex = 37 })
		if spec.Badge ~= nil then
			self.HomeBadges[index] = label({ Parent = button, Name = "Badge", Text = tostring(spec.Badge), Font = Enum.Font.GothamBold, TextSize = 22,
				TextColor3 = C.TEXT, TextXAlignment = Enum.TextXAlignment.Right, Position = UDim2.new(1, -82, 0, 16), Size = UDim2.fromOffset(68, 26), ZIndex = 37 })
		end

		local function hover(on)
			tween(button, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = on and 0.92 or 0.965 })
		end
		button.MouseEnter:Connect(function() hover(true) end)
		button.MouseLeave:Connect(function() hover(false) end)
		button.Activated:Connect(function()
			if spec.Callback then
				task.spawn(spec.Callback)
			elseif spec.Tab then
				self:SelectTab(spec.Tab, true)
			elseif spec.Discord then
				local copy = type(setclipboard) == "function" and setclipboard or (type(toclipboard) == "function" and toclipboard)
				local invite = opts.Discord or "https://discord.gg/"
				local ok = copy and pcall(copy, invite)
				Library:Notify({ Title = "Discord", Text = ok and "Invite copied to clipboard." or ("Join at " .. invite), Type = "success", Duration = 5 })
			end
		end)
		x = x + width
	end

	-- info row
	local function info(name, iconName, px, interactive, callback)
		local item = new(interactive and "TextButton" or "Frame", {
			Parent = landing, Name = "Info_" .. name, BackgroundTransparency = 1, BorderSizePixel = 0,
			Position = UDim2.new(px, px > 0 and 5 or 1, 0, 314), Size = UDim2.new(0.5, -6, 0, 30), ZIndex = 33,
		})
		if interactive then
			item.Text = ""
			item.AutoButtonColor = false
			item.Activated:Connect(callback)
		end
		local ic = createIcon(iconName, item, C.SUB, 35, 16)
		ic.Frame.Position = UDim2.fromOffset(18, 15)
		return label({ Parent = item, Name = "Value", Text = "", TextSize = 12, TextColor3 = C.SUB, Position = UDim2.fromOffset(34, 0), Size = UDim2.new(1, -44, 1, 0), ZIndex = 37 })
	end

	local serverInfo, executorInfo
	local function refreshServer()
		if serverInfo and serverInfo.Parent then
			serverInfo.Text = tostring(#Players:GetPlayers()) .. " / " .. tostring(Players.MaxPlayers) .. " players"
		end
	end
	if opts.Server ~= false then
		serverInfo = info("Server", "people", 0, opts.ServerTab ~= nil, function()
			if opts.ServerTab then self:SelectTab(opts.ServerTab, true) end
		end)
		refreshServer()
		table.insert(self._conns, Players.PlayerAdded:Connect(refreshServer))
		table.insert(self._conns, Players.PlayerRemoving:Connect(function() task.defer(refreshServer) end))
	end
	if opts.Executor ~= false then
		executorInfo = info("Executor", "search", 0.5, false)
		local name = "Unknown executor"
		local detector = (type(identifyexecutor) == "function" and identifyexecutor) or (type(getexecutorname) == "function" and getexecutorname)
		if detector then
			local ok, n = pcall(detector)
			if ok and type(n) == "string" and n:match("%S") then name = n:match("^%s*(.-)%s*$") end
		end
		executorInfo.Text = name
	end

	-- รูปพื้นหลังโชว์เฉพาะตอนอยู่หน้า Home
	tab.OnShow = function(animate)
		art.Visible = true
		if img.Image ~= "" then
			if animate then
				img.ImageTransparency = 1
				tween(img, ti(0.5, Enum.EasingStyle.Quad), { ImageTransparency = 0.06 })
			else
				img.ImageTransparency = 0.06
			end
		end
		refreshServer()
	end
	tab.OnHide = function() art.Visible = false end

	self.Home = {
		Tab = tab, Artwork = img, Greeting = greeting,
		GetMapName = function() return mapName end,
		SetBadge = function(_, index, text) if self.HomeBadges[index] then self.HomeBadges[index].Text = tostring(text) end end,
		SetBanner = function(_, image) setArt(image) end,
	}
	return self.Home
end

--// Settings (deck) --------------------------------------------------------
-- การ์ด: Account / Search / Categories / Options / Quick settings / Shortcuts
function Window:AddSettings()
	local window = self
	local tab = self:AddDeckTab({ Name = "Settings", Icon = "settings" })
	self.SettingsTab = tab

	local SUB = SUBTLE
	local ROW_H, GAP = 56, 16
	local quick = ti(0.2)
	local KEY_SHORT = {
		Semicolon = ";", RightAlt = "RAlt", LeftAlt = "LAlt", RightControl = "RCtrl", LeftControl = "LCtrl",
		RightShift = "RShift", LeftShift = "LShift", Return = "Enter", CapsLock = "Caps", Insert = "Ins",
		Delete = "Del", PageUp = "PgUp", PageDown = "PgDn",
	}
	local function keyName(k)
		k = tostring(k or "None")
		return KEY_SHORT[k] or (#k <= 8 and k or k:sub(1, 7))
	end

	local CATS = { { "General", "settings" }, { "Performance", "speed" }, { "Keybinds", "keyboard" }, { "Appearance", "brush" } }
	local CAT_ICON = {}
	for _, c in ipairs(CATS) do CAT_ICON[c[1]] = c[2] end
	local CAT_DESC = {
		General = "Alerts and how the interface behaves",
		Performance = "Frame rate and background behavior",
		Keybinds = "Shortcuts for the interface",
		Appearance = "Theme, wallpaper, transparency and layout",
	}

	local function pct(v) return v .. "%" end
	local function flag(cat, group, lbl, desc, keys, get, set)
		return { cat = cat, group = group, kind = "toggle", label = lbl, desc = desc, keys = keys, get = get, set = set }
	end

	local SPECS = {
		flag("General", "Alerts", "Notifications", "Show alerts on screen", "toast notify",
			function() return Store.Notifications end,
			function(v) Store.Notifications = v saveStore() end),
		flag("General", "Alerts", "Welcome message", "Greet me when the interface loads", "hello greet",
			function() return Store.Welcome end,
			function(v) Store.Welcome = v saveStore() end),
		flag("Performance", "Frame rate", "Unlock FPS", "Go past the 60 FPS limit", "fps frame rate uncap",
			function() return Store.UnlockFps end,
			function(v) Store.UnlockFps = v saveStore() Library._applyFps(true) end),
		flag("Performance", "Background", "Cap FPS in background", "Lower FPS while the game is unfocused", "fps frame rate battery power",
			function() return Store.BgFpsCap end,
			function(v) Store.BgFpsCap = v saveStore() end),
		{ cat = "Keybinds", group = "Interface", kind = "key", label = "Toggle interface", desc = "Open or close the interface",
			keys = "keybind hotkey menu",
			foot = "Click a key, then press the new one. Esc cancels. Changes apply right away and are saved.",
			get = function() return window.Keybind.Name end,
			set = function(k) local kc = keyFromName(k) if kc then window:SetKeybind(kc) end end },
		{ cat = "Appearance", group = "Theme", kind = "theme", label = "Theme", desc = "Colors the interface accent.",
			keys = "theme color colour picker tint accent",
			get = function() return Store.Theme end,
			set = function(name) Library:SetTheme(name) end },
		{ cat = "Appearance", group = "Wallpaper", kind = "text", label = "Wallpaper",
			desc = "Paste an image id or link. Leave empty to show the game.",
			keys = "wallpaper background image id link decal", placeholder = "Image id or https link",
			get = function() return Store.Wallpaper end,
			set = function(v) window:SetWallpaper(v) end },
		{ cat = "Appearance", group = "Wallpaper", kind = "slider", label = "See-through",
			desc = "How much of the game shows through the wallpaper", keys = "wallpaper transparency opacity see through",
			min = 0, max = 100, fmt = pct,
			get = function() return math.floor(Store.SeeThrough + 0.5) end,
			live = function(v) window:SetWallpaperOpacity(v, true) end,
			set = function(v) window:SetWallpaperOpacity(v) end },
		{ cat = "Appearance", group = "Transparency", kind = "slider", label = "Menu opacity",
			desc = "How solid the menu is. Text stays fully visible.", keys = "transparency opacity see through menu main ui glass",
			min = 35, max = 100, fmt = pct,
			get = function() return math.floor(Store.MenuOpacity * 100 + 0.5) end,
			live = function(v) Library:SetUiOpacity("main", v / 100, true) end,
			set = function(v) Library:SetUiOpacity("main", v / 100) end },
		{ cat = "Appearance", group = "Transparency", kind = "slider", label = "Pop-out opacity",
			desc = "How solid notifications are", keys = "transparency opacity see through popout pop-out notification toast",
			min = 35, max = 100, fmt = pct,
			get = function() return math.floor(Store.PopOpacity * 100 + 0.5) end,
			live = function(v) Library:SetUiOpacity("pop", v / 100, true) end,
			set = function(v) Library:SetUiOpacity("pop", v / 100) end },
	}
	if not isMobile then
		SPECS[#SPECS + 1] = flag("Appearance", "Behavior", "Auto-collapse contents", "Fold the dashboard when the pointer leaves",
			"navbar hide dock",
			function() return Store.AutoCollapse end,
			function(v) Store.AutoCollapse = v saveStore() end)
	end
	local function specByLabel(l)
		for _, s in ipairs(SPECS) do if s.label == l then return s end end
	end

	-- helpers --------------------------------------------------------------
	local paints = {}
	local function live(inst, fn) paints[#paints + 1] = { inst = inst, fn = fn } end
	local function repaint()
		for i = #paints, 1, -1 do
			local p = paints[i]
			if not p.inst:IsDescendantOf(window.Gui) then table.remove(paints, i) else pcall(p.fn) end
		end
	end
	local function commit(spec, v)
		local ok, err = pcall(spec.set, v)
		if not ok then warn("NovolineUI settings " .. tostring(spec.label) .. ": " .. tostring(err)) end
		repaint()
	end
	local function text(parent, value, font, size, color, x, y, w, h, align)
		return label({
			Parent = parent, Text = value, Font = font, TextSize = size, TextColor3 = color,
			Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h),
			TextXAlignment = align or Enum.TextXAlignment.Left, ZIndex = 22,
		})
	end
	local function tile(parent, x, y, w, h, r)
		local f = new("Frame", {
			Parent = parent, Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h), BorderSizePixel = 0,
			ZIndex = 21, BackgroundColor3 = WHITE,
		})
		round(f, r)
		local g = new("UIGradient", { Parent = f, Rotation = 90 })
		toneSeq(g, Color3.fromRGB(46, 46, 49), Color3.fromRGB(32, 32, 35), 0.22)
		new("UIStroke", { Parent = f, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = WHITE, Transparency = 0.9 })
		return f
	end
	local function dragStrip(card, h)
		local s = new("TextButton", { Parent = card, Name = "DragStrip", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, h), ZIndex = 19 })
		window:_bindDrag(s)
	end
	local function row(parent, spec, x, y, w, h, labelW, clickable, wrap)
		local r = new(clickable and "TextButton" or "Frame", {
			Parent = parent, Name = spec.label, BackgroundColor3 = WHITE, BackgroundTransparency = 1, BorderSizePixel = 0,
			Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h), ZIndex = 21,
		})
		if clickable then r.Text = "" r.AutoButtonColor = false end
		round(r, 12)
		text(r, spec.label, Enum.Font.GothamBold, 13, C.TEXT, 14, 11, labelW, 16)
		local desc = text(r, spec.desc or "", Enum.Font.GothamMedium, 11, SUB, 14, 30, labelW, wrap and math.max(14, h - 42) or 14)
		if wrap and h - 42 > 14 then desc.TextWrapped = true desc.TextYAlignment = Enum.TextYAlignment.Top end
		if clickable then
			r.MouseEnter:Connect(function() tween(r, TweenInfo.new(0.15), { BackgroundTransparency = 0.96 }) end)
			r.MouseLeave:Connect(function() tween(r, TweenInfo.new(0.15), { BackgroundTransparency = 1 }) end)
		end
		return r, desc
	end
	local function height(spec, labelW)
		local d = spec.desc or ""
		if d == "" then return ROW_H end
		local th = TextService:GetTextSize(d, 11, Enum.Font.GothamMedium, Vector2.new(math.max(1, labelW), 1000)).Y
		return ROW_H + (math.clamp(math.ceil(th / 14 - 0.05), 1, 3) - 1) * 14
	end

	-- row kinds ------------------------------------------------------------
	local kinds = {}

	kinds.toggle = function(parent, spec, x, y, W)
		local lw = W - 94
		local h = height(spec, lw)
		local r = row(parent, spec, x, y, W, h, lw, true, true)
		local sw = makeSwitch(r, spec.get() == true, 22, function(v) commit(spec, v) end, UDim2.new(1, -12, 0.5, 0))
		r.Activated:Connect(function() sw.Set(not sw.Get()) end)
		live(r, function() sw.Set(spec.get() == true, true) end)
		return h
	end

	kinds.slider = function(parent, spec, x, y, W)
		local VW = 52
		local lw = W - 28 - VW - 8
		local d = spec.desc or ""
		local dh = 0
		if d ~= "" then
			local th = TextService:GetTextSize(d, 11, Enum.Font.GothamMedium, Vector2.new(lw, 1000)).Y
			dh = math.clamp(math.ceil(th / 14 - 0.05), 1, 3) * 14
		end
		local sy = dh > 0 and (30 + dh + 15) or 41
		local h = sy + 18
		local r, desc = row(parent, spec, x, y, W, h, lw, false, false)
		if desc then
			desc.Size = UDim2.fromOffset(lw, math.max(14, dh))
			if dh > 14 then desc.TextWrapped = true desc.TextYAlignment = Enum.TextYAlignment.Top end
		end
		local value = text(r, "", Enum.Font.GothamBold, 12, C.TEXT, W - 14 - VW, 11, VW, 16, Enum.TextXAlignment.Right)
		local fmt = spec.fmt or tostring
		local engine
		engine = makeSlider({
			parent = r, position = UDim2.fromOffset(14, sy), width = UDim.new(0, W - 28), z = 23,
			min = spec.min, max = spec.max, value = spec.get(),
			onChange = function(v) value.Text = fmt(v) if spec.live then spec.live(v) end end,
			onRelease = function(v) commit(spec, v) end,
		})
		value.Text = fmt(engine.Get())
		live(r, function()
			if not engine.Dragging() then
				engine.Set(spec.get(), false)
				value.Text = fmt(engine.Get())
			end
		end)
		return h
	end

	kinds.key = function(parent, spec, x, y, W)
		local lw = W - 12 - 92 - GAP - 14
		local h = height(spec, lw)
		local r = row(parent, spec, x, y, W, h, lw, true, true)
		local pill = tile(r, W - 12 - 92, (h - 28) / 2, 92, 28, 14)
		local lbl = text(pill, "", Enum.Font.GothamBold, 12, C.TEXT, 0, 0, 92, 28, Enum.TextXAlignment.Center)
		lbl.ZIndex = 23
		local function paint()
			lbl.Text = (window._listening == spec) and "Press a key" or keyName(spec.get())
		end
		r.Activated:Connect(function()
			if window._listening then return end
			window._listening = spec
			paint()
			local conn
			conn = UserInputService.InputBegan:Connect(function(input)
				if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
				conn:Disconnect()
				task.defer(function() window._listening = nil paint() end)
				if input.KeyCode ~= Enum.KeyCode.Escape then commit(spec, input.KeyCode.Name) end
			end)
		end)
		live(r, paint)
		paint()
		return h
	end

	kinds.theme = function(parent, spec, x, y, W)
		local h = ROW_H + 40
		local r = row(parent, spec, x, y, W, h, W - 28, false, false)
		local rings = {}
		for i, t in ipairs(Library.ThemeList) do
			local b = new("TextButton", {
				Parent = r, Name = t[1], Text = "", AutoButtonColor = false, Position = UDim2.fromOffset(14 + (i - 1) * 34, 62),
				Size = UDim2.fromOffset(26, 26), BackgroundColor3 = t[2] or ICON_ON, BorderSizePixel = 0, ZIndex = 23,
			})
			round(b, "full")
			rings[t[1]] = new("UIStroke", { Parent = b, Color = WHITE, Thickness = 2, Transparency = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
			pressable(b, 0.9)
			b.Activated:Connect(function() commit(spec, t[1]) end)
		end
		local function paint()
			for name, ring in pairs(rings) do
				tween(ring, TweenInfo.new(0.15), { Transparency = (name == spec.get()) and 0 or 1 })
			end
		end
		live(r, paint)
		paint()
		return h
	end

	kinds.text = function(parent, spec, x, y, W)
		local h = 94
		local r = row(parent, spec, x, y, W, h, W - 28, false, false)
		local bg = new("Frame", {
			Parent = r, Position = UDim2.fromOffset(14, 52), Size = UDim2.fromOffset(W - 28, 30), BorderSizePixel = 0, ZIndex = 22,
			BackgroundColor3 = WHITE, BackgroundTransparency = 0.94, ClipsDescendants = true,
		})
		round(bg, 10)
		local stroke = new("UIStroke", { Parent = bg, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = WHITE, Transparency = 0.92 })
		local box = new("TextBox", {
			Parent = bg, BackgroundTransparency = 1, BorderSizePixel = 0, Font = Enum.Font.GothamMedium, TextSize = 12,
			TextColor3 = C.TEXT, PlaceholderColor3 = Color3.fromRGB(110, 110, 116), PlaceholderText = spec.placeholder or "",
			Text = tostring(spec.get() or ""), ClearTextOnFocus = false, MultiLine = false, TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(10, 0), Size = UDim2.fromOffset(W - 48, 30), ZIndex = 23,
		})
		box.Focused:Connect(function() tween(stroke, TweenInfo.new(0.15), { Transparency = 0.7 }) end)
		box.FocusLost:Connect(function()
			tween(stroke, TweenInfo.new(0.15), { Transparency = 0.92 })
			local val = box.Text:match("^%s*(.-)%s*$")
			if val ~= spec.get() then commit(spec, val) end
			box.Text = tostring(spec.get() or "")
		end)
		live(r, function()
			if UserInputService:GetFocusedTextBox() ~= box then box.Text = tostring(spec.get() or "") end
		end)
		return h
	end

	-- cards ----------------------------------------------------------------
	local current, query = "General", ""
	local render, pickCategory
	local OPT_W, PAD = 296, 12
	local COL_W = OPT_W - PAD * 2

	-- Account (บนขวา)
	local account = tab:Card("tr", 270, 0, 200, 44)
	local face = new("ImageLabel", {
		Parent = account, Position = UDim2.fromOffset(7, 7), Size = UDim2.fromOffset(30, 30), BorderSizePixel = 0, ZIndex = 21,
		BackgroundColor3 = Color3.fromRGB(40, 40, 44),
		Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150",
	})
	round(face, "full")
	text(account, LocalPlayer.DisplayName, Enum.Font.GothamBold, 13, C.TEXT, 46, 6, 122, 16)
	text(account, "@" .. LocalPlayer.Name, Enum.Font.GothamMedium, 10, SUB, 46, 23, 122, 14)
	createIcon("chevron", account, SUB, 21, 14).Frame.Position = UDim2.fromOffset(177, 22)
	dragStrip(account, 44)

	-- Search (บนขวา)
	local search = tab:Card("tr", 0, 0, 260, 44)
	createIcon("search", search, SUB, 21, 16).Frame.Position = UDim2.fromOffset(24, 22)
	local searchBox = new("TextBox", {
		Parent = search, BackgroundTransparency = 1, BorderSizePixel = 0, Font = Enum.Font.GothamMedium, TextSize = 13,
		TextColor3 = C.TEXT, PlaceholderColor3 = Color3.fromRGB(110, 110, 116), PlaceholderText = "Search settings", Text = "",
		ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.fromOffset(42, 0), Size = UDim2.fromOffset(176, 44), ZIndex = 21,
	})
	local clearBtn = new("TextButton", {
		Parent = search, Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.fromOffset(260 - 36, 10), Size = UDim2.fromOffset(24, 24), ZIndex = 22, Visible = false,
	})
	createIcon("cross", clearBtn, SUB, 23, 14).Frame.Position = UDim2.fromOffset(12, 12)

	-- Categories (ล่างซ้าย)
	local catCard = tab:Card("bl", 0, 0, 210, 360)
	text(catCard, "Categories", Enum.Font.GothamBold, 14, C.TEXT, 18, 16, 160, 18)
	dragStrip(catCard, 38)
	local glide = new("Frame", { Parent = catCard, Name = "Glide", BackgroundColor3 = WHITE, BackgroundTransparency = 0.9, BorderSizePixel = 0, ZIndex = 19 })
	round(glide, 12)
	local catRows, catLabels = {}, {}
	local function countIn(cat)
		local n = 0
		for _, s in ipairs(SPECS) do if s.cat == cat then n = n + 1 end end
		return n
	end
	local function moveGlide(rowBtn, instant)
		if not (glide.Parent and rowBtn) then return end
		local goal = { Position = rowBtn.Position, Size = rowBtn.Size }
		if instant or glide.Size.Y.Offset <= 0 then
			glide.Position, glide.Size = goal.Position, goal.Size
		else
			tween(glide, ti(0.3), goal)
		end
	end
	local function paintCats(instant)
		moveGlide(catRows[current], instant)
		local searching = query ~= ""
		tween(glide, quick, { BackgroundTransparency = searching and 1 or 0.9 })
		for name, l in pairs(catLabels) do
			tween(l, quick, { TextTransparency = (name == current and not searching) and 0 or 0.35 })
		end
	end
	local CAT_STEP, CAT_H = 38, 34
	for n, c in ipairs(CATS) do
		local rowBtn = new("TextButton", {
			Parent = catCard, Name = c[1], Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0,
			Position = UDim2.fromOffset(12, 40 + (n - 1) * CAT_STEP), Size = UDim2.fromOffset(186, CAT_H), ZIndex = 20,
		})
		local t = tile(rowBtn, 5, math.floor((CAT_H - 24) / 2), 24, 24, 8)
		createIcon(c[2], t, C.TEXT, 22, 14).Frame.Position = UDim2.fromOffset(12, 12)
		local l = text(rowBtn, c[1], Enum.Font.GothamBold, 13, C.TEXT, 38, 0, 104, CAT_H)
		l.TextTransparency = 0.35
		text(rowBtn, tostring(countIn(c[1])), Enum.Font.GothamMedium, 11, SUB, 186 - 10 - 28, 0, 28, CAT_H, Enum.TextXAlignment.Right)
		catRows[c[1]], catLabels[c[1]] = rowBtn, l
		rowBtn.MouseEnter:Connect(function() if c[1] ~= current or query ~= "" then tween(l, quick, { TextTransparency = 0.1 }) end end)
		rowBtn.MouseLeave:Connect(function() if c[1] ~= current or query ~= "" then tween(l, quick, { TextTransparency = 0.35 }) end end)
		rowBtn.Activated:Connect(function() pickCategory(c[1]) end)
	end

	-- Options (ล่างกลาง)
	local optCard = tab:Card("bl", 224, 0, OPT_W, 360)
	dragStrip(optCard, 62)
	local heroTitle = text(optCard, "", Enum.Font.GothamBold, 16, C.TEXT, 18, 14, OPT_W - 18 - 60, 20)
	local heroDesc = text(optCard, "", Enum.Font.GothamMedium, 11, SUB, 18, 36, OPT_W - 18 - 60, 14)
	local heroTile = tile(optCard, OPT_W - 16 - 36, 14, 36, 36, 12)
	local heroIcon
	local function setHeroIcon(name)
		if heroIcon then heroIcon.Frame:Destroy() end
		heroIcon = createIcon(name, heroTile, C.TEXT, 22, 18)
		heroIcon.Frame.Position = UDim2.fromOffset(18, 18)
	end
	setHeroIcon(CAT_ICON[current])
	local content = new("ScrollingFrame", {
		Parent = optCard, Name = "OptionsList", BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 62), Size = UDim2.fromOffset(OPT_W, 360 - 62), ScrollBarThickness = 0,
		CanvasSize = UDim2.new(), ZIndex = 20, ScrollingDirection = Enum.ScrollingDirection.Y,
		ElasticBehavior = Enum.ElasticBehavior.Never,
	})
	new("UIPadding", { Parent = content, PaddingLeft = UDim.new(0, PAD), PaddingRight = UDim.new(0, PAD), PaddingTop = UDim.new(0, 4) })

	local function clearContent()
		for _, child in ipairs(content:GetChildren()) do
			if child:IsA("GuiObject") then child:Destroy() end
		end
	end
	local function groupLabel(value, x, y, w)
		local l = text(content, value, Enum.Font.GothamBold, 12, SUB, x, y, w, 16)
		l.TextYAlignment = Enum.TextYAlignment.Top
		return l
	end
	local function matches(spec, q)
		local hay = (spec.label .. " " .. (spec.desc or "") .. " " .. spec.group .. " " .. spec.cat .. " " .. (spec.keys or "")):lower()
		for word in q:gmatch("%S+") do
			if not hay:find(word, 1, true) then return false end
		end
		return true
	end
	local function placeGroup(key, rows, y)
		groupLabel(key, 6, y, COL_W - 12)
		y = y + 24
		local panel = new("Frame", {
			Parent = content, Name = key, BackgroundColor3 = WHITE, BackgroundTransparency = 0.955, BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, y), ZIndex = 20,
		})
		round(panel, 14)
		local h = 0
		for n, spec in ipairs(rows) do
			if n > 1 then
				new("Frame", {
					Parent = panel, Position = UDim2.fromOffset(14, h), Size = UDim2.fromOffset(COL_W - 28, 1), BorderSizePixel = 0,
					BackgroundColor3 = WHITE, BackgroundTransparency = 0.93, ZIndex = 22,
				})
			end
			local ok, rh = pcall(kinds[spec.kind], panel, spec, 0, h, COL_W)
			if not ok then warn("NovolineUI settings row " .. tostring(spec.label) .. ": " .. tostring(rh)) end
			h = h + ((ok and tonumber(rh)) or ROW_H)
		end
		panel.Size = UDim2.fromOffset(COL_W, h)
		y = y + h
		local foot = query == "" and rows[#rows].foot
		if foot then
			local fh = TextService:GetTextSize(foot, 11, Enum.Font.GothamMedium, Vector2.new(COL_W - 12, 200)).Y
			local l = groupLabel(foot, 6, y + 8, COL_W - 12)
			l.Font = Enum.Font.GothamMedium
			l.TextSize = 11
			l.TextWrapped = true
			l.TextTruncate = Enum.TextTruncate.None
			l.Size = UDim2.fromOffset(COL_W - 12, fh + 2)
			y = y + 8 + fh
		end
		return y
	end

	render = function(keepScroll)
		local scrollY = content.CanvasPosition.Y
		clearContent()
		local list = {}
		for _, spec in ipairs(SPECS) do
			if (query == "" and spec.cat == current) or (query ~= "" and matches(spec, query)) then list[#list + 1] = spec end
		end
		if query == "" then
			heroTitle.Text = current
			heroDesc.Text = CAT_DESC[current] or ""
		else
			heroTitle.Text = "Results"
			heroDesc.Text = #list == 1 and "1 setting matches your search" or (#list .. " settings match your search")
		end
		setHeroIcon(query == "" and CAT_ICON[current] or "search")

		local y, i = 0, 1
		while i <= #list do
			local function keyOf(s) return query == "" and s.group or s.cat end
			local key = keyOf(list[i])
			local rows = { list[i] }
			while list[i + #rows] and keyOf(list[i + #rows]) == key do rows[#rows + 1] = list[i + #rows] end
			y = placeGroup(key, rows, y > 0 and y + 20 or 0)
			i = i + #rows
		end
		if #list == 0 then
			local empty = groupLabel("Nothing matches that. Try another word.", 6, 4, COL_W - 12)
			empty.Font = Enum.Font.GothamMedium
			empty.TextSize = 12
			empty.TextWrapped = true
			y = 40
		end
		content.CanvasSize = UDim2.fromOffset(0, y + 24)
		if keepScroll then
			task.defer(function() content.CanvasPosition = Vector2.new(0, scrollY) end)
		else
			content.CanvasPosition = Vector2.zero
		end
	end

	pickCategory = function(name)
		local wasSearching = query ~= ""
		if wasSearching then query = "" searchBox.Text = "" end
		if current == name and not wasSearching then return end
		current = name
		paintCats()
		render()
	end

	-- Quick settings (ขวา)
	local quickCard = tab:Card("br", 0, 187, 330, 173)
	text(quickCard, "Quick settings", Enum.Font.GothamBold, 14, C.TEXT, 18, 16, 200, 18)
	dragStrip(quickCard, 38)
	local QUICK = {
		{ "Unlock FPS", "Unlock FPS", "speed", TINTS.info, "On", "Off" },
		{ "Notifications", "Alerts", "bell", TINTS.purple, "On", "Off" },
		{ "Auto-collapse contents", "Auto-collapse", "dock", TINTS.success, "On", "Off" },
	}
	local qn = 0
	for _, q in ipairs(QUICK) do
		local spec = specByLabel(q[1])
		if spec then
			qn = qn + 1
			local tint = q[4]
			local b = new("TextButton", {
				Parent = quickCard, Name = q[2], Text = "", AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 21,
				Position = UDim2.fromOffset(16 + (qn - 1) * 102, 40), Size = UDim2.fromOffset(94, 117), BackgroundColor3 = WHITE,
			})
			round(b, 18)
			local g = new("UIGradient", { Parent = b, Rotation = 90 })
			toneSeq(g, Color3.fromRGB(46, 46, 49), Color3.fromRGB(32, 32, 35), 0.22)
			new("UIStroke", { Parent = b, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = WHITE, Transparency = 0.9 })
			pressable(b, 0.96)
			local ic = createIcon(q[3], b, C.TEXT, 22, 20)
			ic.Frame.Position = UDim2.fromOffset(24, 24)
			text(b, q[2], Enum.Font.GothamBold, 12, C.TEXT, 14, 74, 74, 16)
			local state = text(b, "", Enum.Font.GothamMedium, 11, SUB, 14, 92, 74, 14)
			local function paint()
				local on = spec.get() == true
				g.Enabled = not on
				b.BackgroundColor3 = on and tint[1] or WHITE
				ic.tween(quick, on and tint[2] or C.TEXT)
				state.Text = on and q[5] or q[6]
			end
			b.Activated:Connect(function() commit(spec, not (spec.get() == true)) end)
			live(b, paint)
			paint()
		end
	end

	-- Shortcuts (ขวา)
	local shortcuts = tab:Card("br", 0, 0, 330, 173)
	text(shortcuts, "Shortcuts", Enum.Font.GothamBold, 14, C.TEXT, 18, 16, 200, 18)
	createIcon("keyboard", shortcuts, SUB, 21, 18).Frame.Position = UDim2.fromOffset(330 - 30, 25)
	dragStrip(shortcuts, 38)
	for n, name in ipairs({ "Toggle interface", "Notifications" }) do
		local spec = specByLabel(name)
		if spec then
			local y = 44 + (n - 1) * ROW_H
			local ok, err = pcall(kinds[spec.kind], shortcuts, spec, 4, y, 322)
			if not ok then warn("NovolineUI settings shortcut " .. name .. ": " .. tostring(err)) end
			if n == 1 then
				new("Frame", {
					Parent = shortcuts, Position = UDim2.fromOffset(18, y + ROW_H - 1), Size = UDim2.fromOffset(330 - 36, 1),
					BorderSizePixel = 0, BackgroundColor3 = WHITE, BackgroundTransparency = 0.94, ZIndex = 20,
				})
			end
		end
	end

	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local q = (searchBox.Text:match("^%s*(.-)%s*$") or ""):lower()
		clearBtn.Visible = searchBox.Text ~= ""
		if q == query then return end
		query = q
		paintCats()
		render()
	end)
	clearBtn.Activated:Connect(function() searchBox.Text = "" end)

	paintCats(true)
	render()
	self.Settings = { Tab = tab, Specs = SPECS, Refresh = repaint }
	return self.Settings
end

Library.Window = Window
Library.Tab = Tab
Library.Glass = glass
Library.PageSurface = pageSurface

return Library
