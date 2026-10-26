--[[
	OPUS UI Library  v1.0.0
	UI แยกออกมาจากสคริปต์ OPUS client: หน้าต่างกระจก, sidebar แบบต้นไม้, การ์ดโมดูล,
	สไลเดอร์ / ปุ่มเลือก / จานสี, 18 ธีม (รวมธีม "Прозрачный"), toast, เสียงสวิตช์,
	Watermark, ArrayList, Custom Cursor, Preview, เอฟเฟกต์กระจกแตก, Intro, ระบบ Config

	การใช้งานแบบย่อ:
		local Library = loadstring(readfile("OpusUILib.lua"))()   -- หรือ require / loadstring(game:HttpGet(...))()
		local Window  = Library:CreateWindow({ Name = "OPUS", Subtitle = "client", Version = "v1.4" })
		local Visuals = Window:AddSection("Visuals", "Modules", "diamond")
		Visuals:AddModule({
			Name = "Hat", Description = "...", Icon = "diamond",
			Callback = function(on) end,
			Settings = function(page)
				page:AddToggle({ Name = "Rainbow", Flag = "HatRainbow" })
				page:AddSlider({ Name = "Radius", Min = 0.5, Max = 4, Default = 1.4, Flag = "HatRadius" })
			end,
		})
		Window:Init()
	ดู example.lua สำหรับตัวอย่างเต็ม
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local TextService = game:GetService("TextService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local Library = {}
Library.__index = Library
Library.Version = "1.0.0"
Library.Window = nil

--------------------------------------------------------------------
-- ข้อความทั้งหมดของ UI (แก้เป็นภาษาอื่นได้: Library.Strings.Search = "ค้นหา..." ฯลฯ)
--------------------------------------------------------------------
local S = {
	Search = "Поиск...",
	SearchCrumb = "Поиск",
	Found = "найдено: %d",
	NothingFound = "ничего не найдено",
	CounterFormat = '<font color="#FFFAFB"><b>%d</b></font> из %d включено',
	PressKey = "Нажмите клавишу… (Esc — убрать)",
	Enabled = "включено",
	Disabled = "выключено",
	Empty = "пусто",
	Applied = "Применено",
	Footer = "RightControl — меню\nПКМ по карточке — клавиша",

	NewConfig = "Новый конфиг",
	ConfigName = "Название...",
	ConfigEnterName = "Введите название",
	ConfigNameTooLong = "Слишком длинное название",
	ConfigMax = "Максимум %d конфигов",
	ConfigOverwritten = "Перезаписан",
	ConfigSaved = "Сохранён",
	ConfigSavedAt = "Сохранён %s",
	ConfigAuto = "авто",
	ConfigLoaded = "Загружен",
	ConfigLoad = "Загрузить настройки",
	ConfigLoadBtn = "Загрузить",
	ConfigOverwriteRow = "Сохранить текущие сюда",
	ConfigOverwriteBtn = "Перезаписать",
	ConfigAutoRow = "Загружать при запуске",
	ConfigAutoOn = "Включить",
	ConfigAutoOff = "Выключить",
	ConfigDeleteRow = "Удалить конфиг",
	ConfigDeleteBtn = "Удалить",

	ThemeActive = "активна",
	ThemeWord = "тема",
	GlassName = "Стекло",
	GlassDesc = "Полупрозрачное меню с размытым миром за ним.",
	GlassLevel = "Прозрачность стекла",
	PreviewName = "Предпросмотр",
	PreviewDesc = "Окно справа: ваш аватар с включёнными визуалами.",
	PreviewHint = "Тяните мышью, чтобы повернуть",
	PreviewNone = "визуалы не включены",
	ToastsName = "Уведомления",
	ToastsDesc = "Всплывающие уведомления при включении функций.",
	BlurName = "Размытие фона",
	BlurDesc = "Мир за открытым меню размывается.",

	WatermarkName = "Watermark",
	WatermarkDesc = "Логотип, FPS, пинг и время на экране.",
	WatermarkLogo = "Логотип",
	WatermarkFPS = "FPS",
	WatermarkPing = "Пинг",
	WatermarkTime = "Время",
	WatermarkSeconds = "Секунды во времени",
	Position = "Положение",

	ArrayName = "ArrayList",
	ArrayDesc = "Список включённых функций сбоку экрана.",
	ArraySuffix = "Подписи режимов",
	ArrayBackground = "Подложка",
	ArrayRainbow = "Радужная волна",

	CursorName = "Custom Cursor",
	CursorDesc = "Свой курсор вместо стандартного.",
	CursorShape = "Форма",
	CursorRainbow = "Радужный",
	CursorColor = "Цвет",
	CursorSize = "Размер",
	CursorThickness = "Толщина",
	CursorOutline = "Обводка",
	CursorSpin = "Вращение",
	CursorTransparency = "Прозрачность",
}
Library.Strings = S

--------------------------------------------------------------------
-- Цвета (активная тема). Окно, карточки и элементы читают их отсюда.
--------------------------------------------------------------------
local C = {
	bgTop = Color3.fromRGB(92, 32, 44),
	bgBottom = Color3.fromRGB(38, 14, 20),
	panel = Color3.fromRGB(30, 11, 16),
	card = Color3.fromRGB(80, 30, 40),
	cardHover = Color3.fromRGB(98, 38, 50),
	inner = Color3.fromRGB(52, 19, 27),
	accent = Color3.fromRGB(250, 90, 106),
	accentDim = Color3.fromRGB(140, 56, 70),
	off = Color3.fromRGB(104, 76, 82),
	text = Color3.fromRGB(255, 250, 251),
	sub = Color3.fromRGB(226, 204, 209),
	line = Color3.fromRGB(160, 88, 100),
}
Library.Colors = C

-- Внешний вид меню (раздел Themes). Сохраняется в конфиги.
local MENU_STYLE = {
	Theme = "Бордовый",
	Blur = true,
	Toasts = true,
	Preview = true,
	Glass = true,
	GlassLevel = 0.45,
}
Library.Style = MENU_STYLE

--------------------------------------------------------------------
-- Темы
--------------------------------------------------------------------
local THEME_KEYS = { "bgTop", "bgBottom", "panel", "card", "cardHover", "inner", "accent", "accentDim", "off", "sub", "line" }
local THEMES = {}
do
	local function rgb(t)
		return Color3.fromRGB(t[1], t[2], t[3])
	end
	local function theme(name, values)
		local entry = {}
		for index, key in ipairs(THEME_KEYS) do
			entry[key] = rgb(values[index])
		end
		THEMES[name] = entry
	end
	--         bgTop            bgBottom         panel            card             cardHover        inner            accent           accentDim        off              sub              line
	theme("Бордовый", { { 92, 32, 44 }, { 38, 14, 20 }, { 30, 11, 16 }, { 80, 30, 40 }, { 98, 38, 50 }, { 52, 19, 27 }, { 250, 90, 106 }, { 140, 56, 70 }, { 104, 76, 82 }, { 226, 204, 209 }, { 160, 88, 100 } })
	theme("Полночь", { { 36, 50, 104 }, { 14, 18, 42 }, { 12, 16, 36 }, { 38, 50, 100 }, { 48, 62, 120 }, { 22, 28, 58 }, { 118, 162, 255 }, { 62, 86, 160 }, { 74, 82, 112 }, { 206, 214, 240 }, { 88, 110, 184 } })
	theme("Аметист", { { 80, 38, 116 }, { 30, 15, 46 }, { 24, 12, 38 }, { 72, 36, 104 }, { 88, 46, 126 }, { 44, 22, 66 }, { 198, 134, 255 }, { 110, 70, 160 }, { 96, 78, 114 }, { 222, 206, 240 }, { 134, 92, 186 } })
	theme("Изумруд", { { 26, 88, 72 }, { 10, 32, 27 }, { 9, 26, 22 }, { 30, 78, 65 }, { 38, 96, 80 }, { 17, 46, 38 }, { 88, 232, 170 }, { 44, 128, 96 }, { 72, 98, 90 }, { 204, 234, 222 }, { 70, 142, 116 } })
	theme("Графит", { { 66, 66, 74 }, { 26, 26, 30 }, { 20, 20, 24 }, { 58, 58, 66 }, { 72, 72, 82 }, { 36, 36, 42 }, { 255, 176, 90 }, { 130, 96, 64 }, { 90, 90, 98 }, { 220, 220, 226 }, { 118, 118, 130 } })
	theme("Неон", { { 40, 22, 78 }, { 17, 9, 33 }, { 13, 7, 26 }, { 35, 19, 68 }, { 43, 24, 84 }, { 23, 13, 44 }, { 255, 70, 200 }, { 118, 37, 111 }, { 83, 76, 102 }, { 238, 216, 235 }, { 144, 46, 140 } })
	theme("Океан", { { 18, 64, 92 }, { 8, 27, 39 }, { 6, 21, 30 }, { 16, 56, 80 }, { 19, 69, 99 }, { 10, 36, 52 }, { 60, 205, 255 }, { 31, 107, 139 }, { 74, 93, 108 }, { 215, 232, 242 }, { 39, 133, 173 } })
	theme("Закат", { { 96, 44, 36 }, { 40, 18, 15 }, { 32, 15, 12 }, { 84, 38, 31 }, { 104, 48, 39 }, { 55, 25, 21 }, { 255, 140, 70 }, { 141, 74, 42 }, { 106, 85, 85 }, { 238, 224, 220 }, { 176, 91, 54 } })
	theme("Сакура", { { 92, 46, 72 }, { 39, 19, 30 }, { 30, 15, 24 }, { 80, 40, 63 }, { 99, 50, 78 }, { 52, 26, 41 }, { 255, 150, 200 }, { 139, 78, 109 }, { 104, 86, 100 }, { 238, 226, 235 }, { 173, 98, 136 } })
	theme("Лава", { { 70, 22, 12 }, { 29, 9, 5 }, { 23, 7, 4 }, { 61, 19, 10 }, { 76, 24, 13 }, { 40, 13, 7 }, { 255, 96, 30 }, { 130, 47, 17 }, { 95, 76, 76 }, { 238, 219, 215 }, { 161, 58, 21 } })
	theme("Лёд", { { 44, 70, 92 }, { 18, 29, 39 }, { 15, 23, 30 }, { 38, 61, 80 }, { 48, 76, 99 }, { 25, 40, 52 }, { 160, 225, 255 }, { 82, 118, 139 }, { 85, 95, 108 }, { 227, 235, 242 }, { 101, 147, 173 } })
	theme("Токсик", { { 26, 46, 20 }, { 11, 19, 8 }, { 9, 15, 7 }, { 23, 40, 17 }, { 28, 50, 22 }, { 15, 26, 11 }, { 150, 255, 60 }, { 70, 120, 32 }, { 78, 86, 79 }, { 226, 238, 218 }, { 86, 147, 40 } })
	theme("Золото", { { 58, 46, 22 }, { 24, 19, 9 }, { 19, 15, 7 }, { 50, 40, 19 }, { 63, 50, 24 }, { 33, 26, 13 }, { 245, 196, 72 }, { 122, 97, 38 }, { 90, 86, 80 }, { 237, 231, 220 }, { 149, 120, 46 } })
	theme("Лаванда", { { 66, 54, 100 }, { 28, 23, 42 }, { 22, 18, 33 }, { 57, 47, 87 }, { 71, 58, 108 }, { 38, 31, 57 }, { 190, 160, 255 }, { 102, 86, 142 }, { 94, 89, 111 }, { 230, 227, 242 }, { 128, 107, 178 } })
	theme("Мята", { { 24, 74, 66 }, { 10, 31, 28 }, { 8, 24, 22 }, { 21, 64, 57 }, { 26, 80, 71 }, { 14, 42, 38 }, { 110, 240, 200 }, { 54, 126, 106 }, { 77, 97, 97 }, { 221, 236, 235 }, { 66, 156, 132 } })
	theme("Кровь", { { 60, 8, 12 }, { 25, 3, 5 }, { 20, 3, 4 }, { 52, 7, 10 }, { 65, 9, 13 }, { 34, 5, 7 }, { 225, 30, 45 }, { 114, 15, 22 }, { 91, 70, 76 }, { 235, 211, 217 }, { 141, 19, 28 } })
	theme("Кофе", { { 70, 48, 36 }, { 29, 20, 15 }, { 23, 16, 12 }, { 61, 42, 31 }, { 76, 52, 39 }, { 40, 27, 21 }, { 225, 170, 120 }, { 118, 87, 62 }, { 95, 86, 85 }, { 235, 228, 226 }, { 147, 108, 78 } })
	-- нейтральное стекло без оттенка
	theme("Прозрачный", { { 175, 175, 180 }, { 125, 125, 130 }, { 95, 95, 100 }, { 155, 155, 160 }, { 180, 180, 186 }, { 115, 115, 120 }, { 190, 190, 197 }, { 120, 120, 126 }, { 78, 78, 84 }, { 232, 232, 236 }, { 236, 236, 240 } })
end
local THEME_ORDER = { "Прозрачный", "Бордовый", "Полночь", "Аметист", "Изумруд", "Графит", "Неон", "Океан", "Закат", "Сакура", "Лава", "Лёд", "Токсик", "Золото", "Лаванда", "Мята", "Кровь", "Кофе" }
Library.Themes = THEMES
Library.ThemeOrder = THEME_ORDER
Library.ThemeKeys = THEME_KEYS

-- ScreenGui вне окна (watermark и т.п.), которые тоже перекрашиваются при смене темы
Library._themedGuis = {}

--------------------------------------------------------------------
-- Помощники
--------------------------------------------------------------------
local function new(className, props)
	local obj = Instance.new(className)
	for key, value in pairs(props) do
		if key ~= "Parent" then
			obj[key] = value
		end
	end
	if props.Parent then
		obj.Parent = props.Parent
	end
	return obj
end

local function round(obj, radius)
	return new("UICorner", { CornerRadius = UDim.new(0, radius), Parent = obj })
end

local function outline(obj, color, transparency)
	return new("UIStroke", {
		Color = color,
		Transparency = transparency,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = obj,
	})
end

local function fire(callback, ...)
	if type(callback) == "function" then
		local ok, err = pcall(callback, ...)
		if not ok then
			warn("OPUS UI: callback error:", err)
		end
	end
end

Library.New = new
Library.Round = round
Library.Outline = outline

-- Иконки из простых фигур (без картинок). Возвращает функцию, которая перекрашивает иконку.
-- Виды: eye, ring, diamond, dots, bars, plus, x, kebab, search, chevron, square, tracer, palette, dot
local function drawIcon(parent, kind, size)
	local holder = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(size, size),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	local fills, strokes = {}, {}
	local full = UDim.new(1, 0)
	local s = size
	local thin = math.max(2, math.floor(s * 0.16 + 0.5))

	local function fill(dx, dy, w, h, radius, rotation)
		local part = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, dx, 0.5, dy),
			Size = UDim2.fromOffset(w, h),
			BorderSizePixel = 0,
			Rotation = rotation or 0,
			Parent = holder,
		})
		if radius then
			new("UICorner", { CornerRadius = radius, Parent = part })
		end
		table.insert(fills, part)
	end

	local function ring(w)
		local part = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(w, w),
			BackgroundTransparency = 1,
			Parent = holder,
		})
		new("UICorner", { CornerRadius = full, Parent = part })
		table.insert(strokes, new("UIStroke", { Thickness = math.max(1, thin - 1), Parent = part }))
	end

	if kind == "eye" then
		ring(s * 0.85)
		fill(0, 0, s * 0.34, s * 0.34, full)
	elseif kind == "ring" then
		ring(s * 0.8)
	elseif kind == "diamond" then
		fill(0, 0, s * 0.62, s * 0.62, UDim.new(0, 2), 45)
	elseif kind == "dots" then
		for _, d in ipairs({ { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } }) do
			fill(d[1] * s * 0.22, d[2] * s * 0.22, s * 0.32, s * 0.32, full)
		end
	elseif kind == "bars" then
		for i = -1, 1 do
			fill(0, i * s * 0.3, s * 0.85, thin, full)
		end
	elseif kind == "plus" then
		fill(0, 0, s * 0.85, thin, full)
		fill(0, 0, thin, s * 0.85, full)
	elseif kind == "x" then
		fill(0, 0, s * 0.85, thin, full, 45)
		fill(0, 0, s * 0.85, thin, full, -45)
	elseif kind == "kebab" then
		for i = -1, 1 do
			fill(0, i * s * 0.32, thin + 1, thin + 1, full)
		end
	elseif kind == "search" then
		local lens = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, -s * 0.1, 0.5, -s * 0.1),
			Size = UDim2.fromOffset(s * 0.58, s * 0.58),
			BackgroundTransparency = 1,
			Parent = holder,
		})
		new("UICorner", { CornerRadius = full, Parent = lens })
		table.insert(strokes, new("UIStroke", { Thickness = math.max(1, thin - 1), Parent = lens }))
		fill(s * 0.25, s * 0.25, s * 0.34, thin, full, 45)
	elseif kind == "chevron" then
		fill(-s * 0.16, 0, s * 0.5, thin, full, 45)
		fill(s * 0.16, 0, s * 0.5, thin, full, -45)
	elseif kind == "square" then
		local square = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(s * 0.62, s * 0.8),
			BackgroundTransparency = 1,
			Parent = holder,
		})
		table.insert(strokes, new("UIStroke", { Thickness = math.max(1, thin - 1), Parent = square }))
	elseif kind == "tracer" then
		fill(0, s * 0.05, s * 0.75, thin, full, -60)
		fill(s * 0.2, -s * 0.3, thin + 2, thin + 2, full)
	elseif kind == "palette" then
		fill(0, -s * 0.22, s * 0.36, s * 0.36, full)
		fill(-s * 0.22, s * 0.16, s * 0.36, s * 0.36, full)
		fill(s * 0.22, s * 0.16, s * 0.36, s * 0.36, full)
	else -- "dot"
		fill(0, 0, s * 0.5, s * 0.5, full)
	end

	return function(color)
		for _, part in ipairs(fills) do
			part.BackgroundColor3 = color
		end
		for _, stroke in ipairs(strokes) do
			stroke.Color = color
		end
	end
end
Library.DrawIcon = drawIcon

-- Логотип: ромб, разрезанный крестом на 4 стеклянные части
local LOGO_BG = Color3.fromRGB(8, 6, 12)
local CRYSTAL_RIM = Color3.fromRGB(226, 216, 255)
local CRYSTAL_TOP = Color3.fromRGB(176, 156, 248)
local CRYSTAL_BOTTOM = Color3.fromRGB(112, 90, 204)

local function drawLogoMark(square, size)
	local markSize = math.floor(size * 0.52 + 0.5)
	local rim = math.max(1, math.floor(size * 0.025 + 0.5))
	local gap = rim * 2 + math.max(1, math.floor(size * 0.025 + 0.5))
	local tile = (markSize - gap) / 2

	local mark = new("Frame", {
		Name = "LogoMark",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(markSize, markSize),
		Rotation = 45,
		BackgroundTransparency = 1,
		Parent = square,
	})
	mark:SetAttribute("KeepColor", true)

	for row = 0, 1 do
		for column = 0, 1 do
			local corner = math.max(1, math.floor(size * 0.03))
			local piece = new("Frame", {
				Position = UDim2.fromOffset(column * (tile + gap), row * (tile + gap)),
				Size = UDim2.fromOffset(tile, tile),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 0.25,
				BorderSizePixel = 0,
				Parent = mark,
			})
			round(piece, corner)
			piece:SetAttribute("KeepColor", true)

			new("UIGradient", {
				Rotation = 45,
				Color = ColorSequence.new(CRYSTAL_TOP, CRYSTAL_BOTTOM),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.1),
					NumberSequenceKeypoint.new(0.5, 0.45),
					NumberSequenceKeypoint.new(1, 0.6),
				}),
				Parent = piece,
			})

			local stroke = new("UIStroke", {
				Color = CRYSTAL_RIM,
				Thickness = rim,
				Transparency = 0.1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Parent = piece,
			})
			stroke:SetAttribute("KeepColor", true)

			local gloss = new("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 0.45,
				BorderSizePixel = 0,
				Parent = piece,
			})
			round(gloss, corner)
			gloss:SetAttribute("KeepColor", true)
			new("UIGradient", {
				Rotation = 45,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.2),
					NumberSequenceKeypoint.new(0.42, 0.75),
					NumberSequenceKeypoint.new(0.45, 1),
					NumberSequenceKeypoint.new(1, 1),
				}),
				Parent = gloss,
			})
		end
	end

	if size >= 48 then
		for _, gem in ipairs({
			{ 0.17, 0.22, 0.05 }, { 0.24, 0.16, 0.06 }, { 0.2, 0.3, 0.04 }, { 0.28, 0.27, 0.035 },
			{ 0.8, 0.7, 0.05 }, { 0.85, 0.79, 0.06 }, { 0.75, 0.83, 0.035 },
		}) do
			local d = math.max(2, math.floor(gem[3] * size))
			local dot = new("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(gem[1], gem[2]),
				Size = UDim2.fromOffset(d, d),
				BackgroundColor3 = CRYSTAL_TOP,
				BackgroundTransparency = 0.45,
				BorderSizePixel = 0,
				Parent = square,
			})
			round(dot, d)
			local dotStroke = new("UIStroke", { Color = CRYSTAL_RIM, Thickness = 1, Transparency = 0.05, Parent = dot })
			dot:SetAttribute("KeepColor", true)
			dotStroke:SetAttribute("KeepColor", true)
		end
	end

	return mark
end
Library.DrawLogoMark = drawLogoMark

--------------------------------------------------------------------
-- Звуки переключателей
--------------------------------------------------------------------
local SOUNDS = {
	Enabled = true,
	Style = "Пинг",
	Volume = 0.5,
	OnPitch = 1.25,
	OffPitch = 0.85,
}
local SOUND_STYLES = { "Пинг", "Клик", "Кнопка" }
local SOUND_IDS = {
	["Пинг"] = "rbxasset://sounds/electronicpingshort.wav",
	["Клик"] = "rbxasset://sounds/clickfast.wav",
	["Кнопка"] = "rbxasset://sounds/button.wav",
}
Library.Sounds = SOUNDS
Library.SoundStyles = SOUND_STYLES
Library.SoundIds = SOUND_IDS

local toggleSound = Instance.new("Sound")
toggleSound.Name = "OpusUIToggleSound"
toggleSound.Parent = SoundService

local function playToggleSound(on)
	if not SOUNDS.Enabled then
		return
	end
	toggleSound.SoundId = SOUND_IDS[SOUNDS.Style] or SOUND_IDS["Пинг"]
	toggleSound.Volume = SOUNDS.Volume
	toggleSound.PlaybackSpeed = on and SOUNDS.OnPitch or SOUNDS.OffPitch
	toggleSound.TimePosition = 0
	toggleSound:Play()
end
Library.PlaySound = playToggleSound

--------------------------------------------------------------------
-- Уведомления в правом нижнем углу: Library:Notify("Hat", true)
--------------------------------------------------------------------
local toastGui, toastHolder = nil, nil
local toastCount = 0

local function ensureToastGui()
	if toastGui and toastGui.Parent then
		return
	end
	toastGui = new("ScreenGui", {
		Name = "OpusUI_Toasts",
		ResetOnSpawn = false,
		DisplayOrder = 300,
		Parent = playerGui,
	})
	toastHolder = new("Frame", {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -16, 1, -16),
		Size = UDim2.fromOffset(240, 260),
		BackgroundTransparency = 1,
		Parent = toastGui,
	})
	new("UIListLayout", {
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = toastHolder,
	})
end

-- title — заголовок, on — true/false (цвет и подпись), text — свой текст вместо «включено/выключено»
function Library:Notify(title, on, text)
	if not MENU_STYLE.Toasts then
		return
	end
	ensureToastGui()
	toastCount += 1
	if on == nil then
		on = true
	end

	local slots = {}
	for _, child in ipairs(toastHolder:GetChildren()) do
		if child:IsA("Frame") then
			table.insert(slots, child)
		end
	end
	table.sort(slots, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)
	for i = 1, #slots - 3 do
		slots[i]:Destroy()
	end

	local slot = new("Frame", {
		LayoutOrder = toastCount,
		Size = UDim2.fromOffset(230, 46),
		BackgroundTransparency = 1,
		Parent = toastHolder,
	})
	local toast = new("Frame", {
		Position = UDim2.fromOffset(260, 0),
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = C.bgBottom,
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
		Parent = slot,
	})
	round(toast, 8)
	outline(toast, on and C.accent or C.line, 0.3)

	new("Frame", {
		Position = UDim2.fromOffset(8, 9),
		Size = UDim2.new(0, 3, 1, -18),
		BackgroundColor3 = on and C.accent or C.off,
		BorderSizePixel = 0,
		Parent = toast,
	})
	new("TextLabel", {
		Position = UDim2.fromOffset(20, 6),
		Size = UDim2.new(1, -28, 0, 18),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextColor3 = C.text,
		Text = title,
		Parent = toast,
	})
	new("TextLabel", {
		Position = UDim2.fromOffset(20, 24),
		Size = UDim2.new(1, -28, 0, 16),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = on and C.accent or C.sub,
		Text = text or (on and S.Enabled or S.Disabled),
		Parent = toast,
	})

	TweenService:Create(toast, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.fromOffset(0, 0),
	}):Play()
	task.delay(1.9, function()
		if not slot.Parent then
			return
		end
		local hide = TweenService:Create(toast, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.fromOffset(260, 0),
		})
		hide:Play()
		hide.Completed:Wait()
		slot:Destroy()
	end)
end

--------------------------------------------------------------------
-- Watermark: логотип, FPS, пинг, время.   local wm = Library:CreateWatermark()
-- wm.Settings — таблица настроек; wm:AddModule(section) — карточка в меню как в оригинале.
--------------------------------------------------------------------
local watermarkClicked = Instance.new("BindableEvent")
Library._watermarkSettings = nil

function Library:CreateWatermark(opts)
	opts = opts or {}
	local WATERMARK = {
		Enabled = true,
		ShowLogo = true,
		ShowFPS = true,
		ShowPing = true,
		ShowTime = true,
		ShowSeconds = false,
		Position = "Слева сверху",
	}
	Library._watermarkSettings = WATERMARK
	local POSITIONS = { "Слева сверху", "Справа сверху", "Слева снизу", "Справа снизу" }
	local ANCHORS = {
		["Слева сверху"] = { Vector2.new(0, 0), UDim2.new(0, 12, 0, 12) },
		["Справа сверху"] = { Vector2.new(1, 0), UDim2.new(1, -12, 0, 12) },
		["Слева снизу"] = { Vector2.new(0, 1), UDim2.new(0, 12, 1, -12) },
		["Справа снизу"] = { Vector2.new(1, 1), UDim2.new(1, -12, 1, -12) },
	}

	local watermarkGui = new("ScreenGui", {
		Name = "OpusUI_Watermark",
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false,
		DisplayOrder = 90,
		Parent = playerGui,
	})
	table.insert(Library._themedGuis, watermarkGui)

	local watermarkBar = new("TextButton", {
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 28),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		Parent = watermarkGui,
	})
	round(watermarkBar, 8)
	local watermarkStroke = outline(watermarkBar, C.line, 0.35)

	watermarkBar.MouseButton1Click:Connect(function()
		watermarkClicked:Fire()
	end)
	watermarkBar.MouseEnter:Connect(function()
		watermarkStroke.Color = C.accent
		watermarkStroke.Transparency = 0.1
	end)
	watermarkBar.MouseLeave:Connect(function()
		watermarkStroke.Color = C.line
		watermarkStroke.Transparency = 0.35
	end)
	new("UIGradient", {
		Color = ColorSequence.new(C.bgTop, C.bgBottom),
		Rotation = 20,
		Parent = watermarkBar,
	})
	new("UIPadding", {
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 10),
		Parent = watermarkBar,
	})
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = watermarkBar,
	})

	local function watermarkItem(order)
		local holder = new("Frame", {
			LayoutOrder = order,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, 0),
			BackgroundTransparency = 1,
			Parent = watermarkBar,
		})
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = holder,
		})
		local divider = new("Frame", {
			LayoutOrder = 0,
			Size = UDim2.fromOffset(1, 14),
			BackgroundColor3 = C.line,
			BackgroundTransparency = 0.2,
			BorderSizePixel = 0,
			Parent = holder,
		})
		local value = new("TextLabel", {
			LayoutOrder = 1,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextColor3 = C.text,
			RichText = true,
			Text = "",
			Parent = holder,
		})
		return { holder = holder, divider = divider, value = value }
	end

	local logoItem = watermarkItem(1)
	logoItem.divider:Destroy()
	logoItem.divider = nil
	local logoSquare = new("Frame", {
		LayoutOrder = 0,
		Size = UDim2.fromOffset(18, 18),
		BackgroundColor3 = LOGO_BG,
		BorderSizePixel = 0,
		Parent = logoItem.holder,
	})
	round(logoSquare, 4)
	drawLogoMark(logoSquare, 18)
	logoItem.value.Font = Enum.Font.GothamBlack
	logoItem.value.Text = opts.Text or "opus client"

	local fpsItem = watermarkItem(2)
	local pingItem = watermarkItem(3)
	local timeItem = watermarkItem(4)

	local watermarkItems = {
		{ item = logoItem, key = "ShowLogo" },
		{ item = fpsItem, key = "ShowFPS" },
		{ item = pingItem, key = "ShowPing" },
		{ item = timeItem, key = "ShowTime" },
	}

	local function subText(text)
		return '<font color="#E2CCD1" size="11">' .. text .. "</font>"
	end

	local function speedColor(value, okLimit, badLimit, higherIsBetter)
		local isGood = higherIsBetter and value >= okLimit or (not higherIsBetter and value <= okLimit)
		local isBad = higherIsBetter and value < badLimit or (not higherIsBetter and value > badLimit)
		if isGood then
			return "#7EE2A0"
		elseif isBad then
			return "#FF6B7A"
		end
		return "#FFD27A"
	end

	local frameCount, fpsTimer, currentFps = 0, 0, 0
	local connection = RunService.RenderStepped:Connect(function(dt)
		frameCount += 1
		fpsTimer += dt
		if fpsTimer < 0.5 then
			return
		end
		currentFps = math.floor(frameCount / fpsTimer + 0.5)
		frameCount = 0
		fpsTimer = 0

		watermarkGui.Enabled = WATERMARK.Enabled
		if not WATERMARK.Enabled then
			return
		end

		local anchor = ANCHORS[WATERMARK.Position] or ANCHORS["Слева сверху"]
		watermarkBar.AnchorPoint = anchor[1]
		watermarkBar.Position = anchor[2]

		local firstVisible = true
		for _, entry in ipairs(watermarkItems) do
			local shown = WATERMARK[entry.key]
			entry.item.holder.Visible = shown
			if shown then
				if entry.item.divider then
					entry.item.divider.Visible = not firstVisible
				end
				firstVisible = false
			end
		end

		fpsItem.value.Text = string.format('<font color="%s">%d</font> %s',
			speedColor(currentFps, 50, 30, true), currentFps, subText("fps"))

		local ok, ping = pcall(function()
			return localPlayer:GetNetworkPing()
		end)
		local pingMs = ok and math.floor(ping * 1000 + 0.5) or 0
		pingItem.value.Text = string.format('<font color="%s">%d</font> %s',
			speedColor(pingMs, 80, 180, false), pingMs, subText("ms"))

		timeItem.value.Text = os.date(WATERMARK.ShowSeconds and "%H:%M:%S" or "%H:%M")
	end)

	local object = { Settings = WATERMARK, Gui = watermarkGui, Positions = POSITIONS }

	function object:AddModule(section)
		return section:AddModule({
			Name = S.WatermarkName,
			Description = S.WatermarkDesc,
			Icon = "bars",
			Source = WATERMARK,
			Key = "Enabled",
			Settings = function(page)
				page:AddToggle({ Name = S.WatermarkLogo, Source = WATERMARK, Key = "ShowLogo" })
				page:AddToggle({ Name = S.WatermarkFPS, Source = WATERMARK, Key = "ShowFPS" })
				page:AddToggle({ Name = S.WatermarkPing, Source = WATERMARK, Key = "ShowPing" })
				page:AddToggle({ Name = S.WatermarkTime, Source = WATERMARK, Key = "ShowTime" })
				page:AddToggle({ Name = S.WatermarkSeconds, Source = WATERMARK, Key = "ShowSeconds" })
				page:AddChoice({ Name = S.Position, Source = WATERMARK, Key = "Position", Options = POSITIONS })
			end,
		})
	end

	function object:Destroy()
		connection:Disconnect()
		watermarkGui:Destroy()
	end

	return object
end

--------------------------------------------------------------------
-- Custom Cursor.   local cursor = Library:CreateCursor();  cursor:AddModule(section)
--------------------------------------------------------------------
function Library:CreateCursor()
	local CURSOR = {
		Enabled = false,
		Style = "Крестик",
		Rainbow = false,
		Color = Color3.fromRGB(255, 90, 90),
		Size = 18,
		Thickness = 2,
		Outline = true,
		Spin = false,
		Transparency = 0,
	}
	local CURSOR_STYLES = { "Точка", "Крестик", "Круг", "Ромб" }

	local cursorGui = new("ScreenGui", {
		Name = "OpusUI_Cursor",
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		DisplayOrder = 500,
		Enabled = false,
		Parent = playerGui,
	})
	local cursorRoot = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Parent = cursorGui,
	})

	local cursorShapes = {}
	local cursorBuiltFor = nil
	local cursorHidDefault = false

	local function cursorFill(position, size, circle)
		local part = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = position,
			Size = size,
			BorderSizePixel = 0,
			Parent = cursorRoot,
		})
		if circle then
			new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = part })
		end
		if CURSOR.Outline then
			new("UIStroke", {
				Color = Color3.fromRGB(0, 0, 0),
				Transparency = 0.35,
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Parent = part,
			})
		end
		table.insert(cursorShapes, { object = part })
		return part
	end

	local function cursorOutlineShape(size, circle, rotation)
		if CURSOR.Outline then
			local back = new("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(size, size),
				BackgroundTransparency = 1,
				Rotation = rotation or 0,
				Parent = cursorRoot,
			})
			if circle then
				new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = back })
			end
			new("UIStroke", {
				Color = Color3.fromRGB(0, 0, 0),
				Transparency = 0.35,
				Thickness = CURSOR.Thickness + 2,
				Parent = back,
			})
		end
		local shape = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(size, size),
			BackgroundTransparency = 1,
			Rotation = rotation or 0,
			Parent = cursorRoot,
		})
		if circle then
			new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = shape })
		end
		local stroke = new("UIStroke", { Thickness = CURSOR.Thickness, Parent = shape })
		table.insert(cursorShapes, { object = shape, stroke = stroke })
	end

	local function buildCursor()
		for _, child in ipairs(cursorRoot:GetChildren()) do
			child:Destroy()
		end
		table.clear(cursorShapes)

		local size = CURSOR.Size
		local thickness = CURSOR.Thickness
		cursorRoot.Size = UDim2.fromOffset(size, size)

		if CURSOR.Style == "Точка" then
			local dot = math.max(thickness * 2, math.floor(size / 3))
			cursorFill(UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(dot, dot), true)
		elseif CURSOR.Style == "Круг" then
			cursorOutlineShape(size, true)
			local dot = thickness + 2
			cursorFill(UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(dot, dot), true)
		elseif CURSOR.Style == "Ромб" then
			cursorOutlineShape(math.floor(size * 0.7), false, 45)
		else
			local gap = math.max(2, math.floor(size * 0.18))
			local length = math.max(2, math.floor(size / 2 - gap))
			local offset = gap + length / 2
			cursorFill(UDim2.new(0.5, 0, 0.5, -offset), UDim2.fromOffset(thickness, length))
			cursorFill(UDim2.new(0.5, 0, 0.5, offset), UDim2.fromOffset(thickness, length))
			cursorFill(UDim2.new(0.5, -offset, 0.5, 0), UDim2.fromOffset(length, thickness))
			cursorFill(UDim2.new(0.5, offset, 0.5, 0), UDim2.fromOffset(length, thickness))
		end
		cursorBuiltFor = table.concat({ CURSOR.Style, size, thickness, tostring(CURSOR.Outline) }, "|")
	end

	local connection = RunService.RenderStepped:Connect(function()
		local enabled = CURSOR.Enabled and UserInputService.MouseEnabled
		cursorGui.Enabled = enabled

		if not enabled then
			if cursorHidDefault then
				UserInputService.MouseIconEnabled = true
				cursorHidDefault = false
			end
			return
		end

		UserInputService.MouseIconEnabled = false
		cursorHidDefault = true

		local key = table.concat({ CURSOR.Style, CURSOR.Size, CURSOR.Thickness, tostring(CURSOR.Outline) }, "|")
		if key ~= cursorBuiltFor then
			buildCursor()
		end

		local mouse = UserInputService:GetMouseLocation()
		cursorRoot.Position = UDim2.fromOffset(mouse.X, mouse.Y)
		cursorRoot.Rotation = CURSOR.Spin and (os.clock() * 120) % 360 or 0

		local color = CURSOR.Rainbow and Color3.fromHSV((os.clock() * 0.3) % 1, 0.8, 1) or CURSOR.Color
		for _, shape in ipairs(cursorShapes) do
			if shape.stroke then
				shape.stroke.Color = color
				shape.stroke.Transparency = CURSOR.Transparency
			else
				shape.object.BackgroundColor3 = color
				shape.object.BackgroundTransparency = CURSOR.Transparency
			end
		end
	end)

	local object = { Settings = CURSOR, Gui = cursorGui, Styles = CURSOR_STYLES }

	function object:AddModule(section)
		return section:AddModule({
			Name = S.CursorName,
			Description = S.CursorDesc,
			Icon = "plus",
			Source = CURSOR,
			Key = "Enabled",
			Settings = function(page)
				page:AddChoice({ Name = S.CursorShape, Source = CURSOR, Key = "Style", Options = CURSOR_STYLES })
				page:AddToggle({ Name = S.CursorRainbow, Source = CURSOR, Key = "Rainbow" })
				page:AddColor({ Name = S.CursorColor, Source = CURSOR, Key = "Color" })
				page:AddSlider({ Name = S.CursorSize, Source = CURSOR, Key = "Size", Min = 6, Max = 48 })
				page:AddSlider({ Name = S.CursorThickness, Source = CURSOR, Key = "Thickness", Min = 1, Max = 6 })
				page:AddToggle({ Name = S.CursorOutline, Source = CURSOR, Key = "Outline" })
				page:AddToggle({ Name = S.CursorSpin, Source = CURSOR, Key = "Spin" })
				page:AddSlider({ Name = S.CursorTransparency, Source = CURSOR, Key = "Transparency", Min = 0, Max = 0.9 })
			end,
		})
	end

	function object:Destroy()
		connection:Disconnect()
		if cursorHidDefault then
			UserInputService.MouseIconEnabled = true
		end
		cursorGui:Destroy()
	end

	return object
end

--------------------------------------------------------------------
-- Library:CreateWindow(opts)
--   opts.Name ("OPUS"), opts.Subtitle ("client"), opts.Version ("v1.4"),
--   opts.MenuKey (Enum.KeyCode.RightControl), opts.Size (Vector2, 600x400),
--   opts.Theme ("Бордовый"), opts.Footer, opts.Intro (true), opts.Preview (true),
--   opts.PreviewEffectFolders ({"Aura_Local", ...}), opts.PreviewSubtitle (function -> string),
--   opts.DefaultSections (true: создаёт разделы Config и Themes в группе Settings)
--------------------------------------------------------------------
function Library:CreateWindow(opts)
	opts = opts or {}
	if Library.Window then
		pcall(function()
			Library.Window:Destroy()
		end)
	end

	local WINDOW_SIZE = opts.Size or Vector2.new(600, 400)
	local menuKey = opts.MenuKey or Enum.KeyCode.RightControl

	local connections = {}
	local function bind(signal, callback)
		local connection = signal:Connect(callback)
		table.insert(connections, connection)
		return connection
	end

	local Window = {
		Flags = {},
		Keybinds = {},
		Modules = {},
		ConfigTables = {},
		ConfigOrder = {},
		MenuKey = menuKey,
		PreviewConfig = {
			EffectFolders = opts.PreviewEffectFolders or {},
			Subtitle = opts.PreviewSubtitle,
		},
	}
	local KEYBINDS = Window.Keybinds
	local moduleRegistry = Window.Modules
	local uiRefreshers = {}
	local glassRows = {}
	local updateMenuBlur
	local sections = {}
	local groups = {}
	local sectionOrder = 0
	local groupOrder = 0
	local currentSection = nil
	local currentModule = nil
	local menuOpen = false
	local menuIsOpen = false
	local introPlaying = false
	local animationId = 0
	local initialized = false
	local destroyed = false
	local destroyers = {}
	Window.Sections = sections
	Window.Groups = groups

	--------------------------------------------------------------------
	-- Config: какие таблицы настроек сохраняются в конфиг
	--------------------------------------------------------------------
	local sourceNames = {}
	local function registerConfig(name, source)
		if sourceNames[source] then
			return
		end
		local unique = name
		local n = 1
		while Window.ConfigTables[unique] do
			n += 1
			unique = name .. "_" .. n
		end
		sourceNames[source] = unique
		Window.ConfigTables[unique] = source
		table.insert(Window.ConfigOrder, unique)
	end

	-- Явно задать имя таблицы в конфиге (переопределяет автоматическое имя)
	function Window:RegisterConfig(name, source)
		local old = sourceNames[source]
		if old then
			Window.ConfigTables[old] = nil
			local index = table.find(Window.ConfigOrder, old)
			if index then
				table.remove(Window.ConfigOrder, index)
			end
			sourceNames[source] = nil
		end
		registerConfig(name, source)
	end

	registerConfig("Flags", Window.Flags)
	registerConfig("Menu", MENU_STYLE)
	registerConfig("Sounds", SOUNDS)
	registerConfig("Binds", KEYBINDS)

	function Window:Refresh()
		for _, refresh in ipairs(uiRefreshers) do
			refresh()
		end
	end

	--------------------------------------------------------------------
	-- Каркас окна
	--------------------------------------------------------------------
	local screenGui = new("ScreenGui", {
		Name = opts.GuiName or "OpusUI_Menu",
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false,
		DisplayOrder = 100,
		Enabled = false,
		Parent = playerGui,
	})
	Window.Gui = screenGui
	table.insert(destroyers, function()
		screenGui:Destroy()
	end)

	local frame = new("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(WINDOW_SIZE.X, WINDOW_SIZE.Y),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = screenGui,
	})
	round(frame, 12)
	outline(frame, C.line, 0.35)
	Window.Frame = frame

	local windowBackground = new("Frame", {
		Name = "Background",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
		ZIndex = 0,
		Parent = frame,
	})
	round(windowBackground, 12)

	new("Frame", {
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, -28, 0, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.82,
		BorderSizePixel = 0,
		ZIndex = 0,
		Parent = frame,
	})
	local sheen = new("Frame", {
		Size = UDim2.new(1, 0, 0.45, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.94,
		BorderSizePixel = 0,
		ZIndex = 0,
		Parent = frame,
	})
	round(sheen, 12)
	new("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new(0, 1),
		Parent = sheen,
	})
	new("UIGradient", {
		Color = ColorSequence.new(C.bgTop, C.bgBottom),
		Rotation = 55,
		Parent = windowBackground,
	})

	-- Верхняя панель: логотип, поиск, профиль
	local topBar = new("Frame", {
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundTransparency = 1,
		Parent = frame,
	})
	new("Frame", {
		Position = UDim2.new(0, 0, 1, -1),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = C.line,
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		Parent = topBar,
	})

	local logo = new("Frame", {
		Position = UDim2.fromOffset(14, 11),
		Size = UDim2.fromOffset(26, 26),
		BackgroundColor3 = LOGO_BG,
		BorderSizePixel = 0,
		Parent = topBar,
	})
	round(logo, 6)
	outline(logo, C.line, 0.5)
	drawLogoMark(logo, 26)

	local brand = new("Frame", {
		Position = UDim2.fromOffset(48, 0),
		Size = UDim2.fromOffset(144, 48),
		BackgroundTransparency = 1,
		Parent = topBar,
	})
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = brand,
	})
	local brandName = new("TextLabel", {
		LayoutOrder = 1,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBlack,
		TextSize = 16,
		TextColor3 = C.text,
		Text = opts.Name or "OPUS",
		Parent = brand,
	})
	local brandSub = new("TextLabel", {
		LayoutOrder = 2,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = C.sub,
		Text = opts.Subtitle or "client",
		Parent = brand,
	})
	local brandVersion = new("TextLabel", {
		LayoutOrder = 3,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = C.accent,
		Text = opts.Version or "",
		Parent = brand,
	})

	local searchBox = new("Frame", {
		Position = UDim2.fromOffset(198, 9),
		Size = UDim2.new(1, -198 - 176, 0, 30),
		BackgroundColor3 = C.panel,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Parent = topBar,
	})
	round(searchBox, 8)
	outline(searchBox, C.line, 0.6)

	local searchIcon = new("Frame", {
		Position = UDim2.fromOffset(8, 7),
		Size = UDim2.fromOffset(16, 16),
		BackgroundTransparency = 1,
		Parent = searchBox,
	})
	drawIcon(searchIcon, "search", 14)(C.sub)

	local search = new("TextBox", {
		Position = UDim2.fromOffset(28, 0),
		Size = UDim2.new(1, -36, 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = C.text,
		PlaceholderText = S.Search,
		PlaceholderColor3 = C.sub,
		ClearTextOnFocus = false,
		Text = "",
		Parent = searchBox,
	})

	new("TextLabel", {
		Position = UDim2.new(1, -170, 0, 8),
		Size = UDim2.fromOffset(120, 18),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextColor3 = C.text,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = opts.ProfileName or localPlayer.DisplayName,
		Parent = topBar,
	})
	new("TextLabel", {
		Position = UDim2.new(1, -170, 0, 25),
		Size = UDim2.fromOffset(120, 14),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextColor3 = C.sub,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = opts.ProfileTag or ("@" .. localPlayer.Name),
		Parent = topBar,
	})

	local avatar = new("ImageLabel", {
		Position = UDim2.new(1, -44, 0, 8),
		Size = UDim2.fromOffset(32, 32),
		BackgroundColor3 = C.card,
		BorderSizePixel = 0,
		Parent = topBar,
	})
	round(avatar, 16)
	outline(avatar, C.accent, 0.3)

	task.spawn(function()
		local ok, image = pcall(function()
			return Players:GetUserThumbnailAsync(localPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
		end)
		if ok then
			avatar.Image = image
		end
	end)

	-- Перетаскивание окна за верхнюю панель
	local dragging, dragStart, startPos
	topBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	bind(UserInputService.InputChanged, function(input)
		if dragging
			and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	--------------------------------------------------------------------
	-- Боковая панель (дерево разделов)
	--------------------------------------------------------------------
	local sidebar = new("Frame", {
		Position = UDim2.fromOffset(0, 48),
		Size = UDim2.new(0, 150, 1, -48),
		BackgroundColor3 = C.panel,
		BackgroundTransparency = 0.45,
		BorderSizePixel = 0,
		Parent = frame,
	})
	round(sidebar, 12)

	new("Frame", {
		Position = UDim2.new(1, -1, 0, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundColor3 = C.line,
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		Parent = sidebar,
	})

	local sidebarList = new("Frame", {
		Size = UDim2.new(1, 0, 1, -30),
		BackgroundTransparency = 1,
		Parent = sidebar,
	})
	new("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 9),
		Parent = sidebarList,
	})
	new("UIListLayout", {
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = sidebarList,
	})

	local footerLabel = new("TextLabel", {
		Position = UDim2.new(0, 8, 1, -50),
		Size = UDim2.new(1, -16, 0, 44),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextWrapped = true,
		TextColor3 = C.sub,
		Text = opts.Footer or S.Footer,
		Parent = sidebar,
	})

	-- Группы разделов: заголовок + вложенные пункты с линией дерева
	local function createGroup(name, iconKind)
		if groups[name] then
			return groups[name]
		end
		groupOrder += 1

		local header = new("TextButton", {
			LayoutOrder = groupOrder * 2 - 1,
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundColor3 = C.accentDim,
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			Text = "",
			Parent = sidebarList,
		})
		round(header, 7)

		local iconHolder = new("Frame", {
			Position = UDim2.new(0, 8, 0.5, -9),
			Size = UDim2.fromOffset(18, 18),
			BackgroundTransparency = 1,
			Parent = header,
		})
		local setIcon = drawIcon(iconHolder, iconKind or "dot", 14)

		local label = new("TextLabel", {
			Position = UDim2.fromOffset(32, 0),
			Size = UDim2.new(1, -52, 1, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.sub,
			Text = name,
			Parent = header,
		})

		local arrow = new("Frame", {
			Position = UDim2.new(1, -22, 0.5, -7),
			Size = UDim2.fromOffset(14, 14),
			BackgroundTransparency = 1,
			Parent = header,
		})
		drawIcon(arrow, "chevron", 10)(C.sub)

		local list = new("Frame", {
			LayoutOrder = groupOrder * 2,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Parent = sidebarList,
		})
		new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })
		new("UIPadding", { PaddingBottom = UDim.new(0, 8), Parent = list })

		header.MouseButton1Click:Connect(function()
			list.Visible = not list.Visible
			arrow.Rotation = list.Visible and 0 or -90
		end)
		header.MouseEnter:Connect(function()
			label.TextColor3 = C.text
		end)
		header.MouseLeave:Connect(function()
			label.TextColor3 = groups[name].active and C.text or C.sub
		end)

		groups[name] = { header = header, label = label, setIcon = setIcon, list = list, sections = {}, active = false }
		return groups[name]
	end

	createGroup("Modules", "diamond")
	createGroup("Settings", "plus")

	-- Добавить свою группу в sidebar: Window:AddGroup("Name", "icon")
	function Window:AddGroup(name, iconKind)
		createGroup(name, iconKind)
		return groups[name]
	end

	--------------------------------------------------------------------
	-- Правая часть: хлебные крошки, сетка карточек и страницы настроек
	--------------------------------------------------------------------
	local content = new("Frame", {
		Position = UDim2.fromOffset(162, 48),
		Size = UDim2.new(1, -174, 1, -58),
		BackgroundTransparency = 1,
		Parent = frame,
	})

	local backButton = new("TextButton", {
		Position = UDim2.fromOffset(0, 6),
		Size = UDim2.fromOffset(22, 22),
		BackgroundColor3 = C.card,
		BackgroundTransparency = 0.2,
		AutoButtonColor = true,
		Text = "",
		Visible = false,
		Parent = content,
	})
	round(backButton, 6)
	local backIcon = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(12, 12),
		Rotation = 90,
		BackgroundTransparency = 1,
		Parent = backButton,
	})
	drawIcon(backIcon, "chevron", 10)(C.text)

	local breadcrumb = new("TextLabel", {
		Position = UDim2.fromOffset(2, 6),
		Size = UDim2.new(1, -2, 0, 22),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = C.sub,
		RichText = true,
		Text = "",
		Parent = content,
	})

	local counterLabel = new("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -6, 0, 6),
		Size = UDim2.fromOffset(170, 22),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextColor3 = C.sub,
		RichText = true,
		Text = "",
		Parent = content,
	})

	local function makeScroller(name)
		local scroller = new("ScrollingFrame", {
			Name = name,
			Position = UDim2.fromOffset(0, 36),
			Size = UDim2.new(1, 0, 1, -36),
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = C.accent,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = false,
			Parent = content,
		})
		new("UIPadding", {
			PaddingTop = UDim.new(0, 1),
			PaddingLeft = UDim.new(0, 1),
			PaddingRight = UDim.new(0, 7),
			PaddingBottom = UDim.new(0, 2),
			Parent = scroller,
		})
		return scroller
	end

	local function updateCounter()
		local section = sections[currentSection]
		if currentModule or not section or #section.modules == 0 then
			counterLabel.Text = ""
			return
		end
		local on = 0
		for _, def in ipairs(section.modules) do
			if def.source[def.key] then
				on += 1
			end
		end
		counterLabel.Text = string.format(S.CounterFormat, on, #section.modules)
	end

	local function crumbs(...)
		local section = sections[currentSection]
		local parts = { section and section.group or "Modules" }
		for _, part in ipairs({ ... }) do
			table.insert(parts, part)
		end
		local last = table.remove(parts)
		local text = table.concat(parts, "  /  ")
		return text .. '  /  <font color="#FFFAFB"><b>' .. last .. "</b></font>"
	end

	local function slideIn(page)
		page.Position = UDim2.fromOffset(0, 48)
		TweenService:Create(page, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = UDim2.fromOffset(0, 36),
		}):Play()
	end

	-- Поиск по всем разделам сразу
	local searchGrid = nil
	local searchQuery = ""
	local searchFound = 0

	local function showGrid()
		if currentModule then
			currentModule.page.Visible = false
			currentModule = nil
		end
		local searching = searchGrid ~= nil and searchQuery ~= ""
		for name, section in pairs(sections) do
			local visible = not searching and name == currentSection
			if visible and not section.grid.Visible then
				slideIn(section.grid)
			end
			section.grid.Visible = visible
		end
		if searchGrid then
			searchGrid.Visible = searching
		end
		backButton.Visible = false
		breadcrumb.Position = UDim2.fromOffset(2, 6)
		if searching then
			local safeQuery = searchQuery:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
			breadcrumb.Text = S.SearchCrumb .. '  /  <font color="#FFFAFB"><b>' .. safeQuery .. "</b></font>"
			counterLabel.Text = searchFound > 0 and string.format(S.Found, searchFound) or S.NothingFound
		else
			breadcrumb.Text = crumbs(currentSection)
			updateCounter()
		end
	end

	local function selectSection(name)
		if not sections[name] then
			return
		end
		if search.Text ~= "" then
			search.Text = ""
		end
		currentSection = name
		for sectionName, section in pairs(sections) do
			local active = sectionName == name
			section.nav.setIcon(active and C.accent or C.sub)
			section.nav.label.TextColor3 = active and C.text or C.sub
			section.nav.label.Font = active and Enum.Font.GothamBold or Enum.Font.Gotham
			section.nav.pill.Visible = active
		end
		for _, group in pairs(groups) do
			group.active = group.sections[name] == true
			group.header.BackgroundTransparency = group.active and 0.35 or 1
			group.label.TextColor3 = group.active and C.text or C.sub
			group.setIcon(group.active and C.accent or C.sub)
		end
		showGrid()
	end

	local function openSettings(module)
		for _, section in pairs(sections) do
			section.grid.Visible = false
		end
		if searchGrid then
			searchGrid.Visible = false
		end
		if currentModule then
			currentModule.page.Visible = false
		end
		currentModule = module
		module.page.Visible = true
		slideIn(module.page)
		backButton.Visible = true
		breadcrumb.Position = UDim2.fromOffset(30, 6)
		breadcrumb.Text = crumbs(currentSection, module.name)
		updateCounter()
	end

	backButton.MouseButton1Click:Connect(showGrid)

	searchGrid = makeScroller("SearchResults")
	new("UIGridLayout", {
		CellSize = UDim2.new(0.5, -5, 0, 66),
		CellPadding = UDim2.fromOffset(10, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = searchGrid,
	})

	local function restoreSearchCards()
		for _, section in pairs(sections) do
			for _, entry in ipairs(section.cards) do
				if entry.frame.Parent == searchGrid then
					entry.frame.Parent = section.grid
					entry.frame.LayoutOrder = entry.homeOrder or entry.frame.LayoutOrder
				end
			end
		end
	end

	search:GetPropertyChangedSignal("Text"):Connect(function()
		restoreSearchCards()
		searchQuery = search.Text:gsub("^%s+", ""):gsub("%s+$", "")
		searchFound = 0

		if searchQuery ~= "" then
			local query = searchQuery:lower()
			local ordered = {}
			for _, section in pairs(sections) do
				table.insert(ordered, section)
			end
			table.sort(ordered, function(a, b)
				return a.order < b.order
			end)
			for _, section in ipairs(ordered) do
				for _, entry in ipairs(section.cards) do
					local haystack = (entry.name .. " " .. entry.desc):lower()
					if entry.frame.Parent and haystack:find(query, 1, true) then
						searchFound += 1
						entry.homeOrder = entry.homeOrder or entry.frame.LayoutOrder
						entry.frame.Parent = searchGrid
						entry.frame.LayoutOrder = searchFound
					end
				end
			end
		end

		if currentModule then
			currentModule.page.Visible = false
			currentModule = nil
		end
		showGrid()
	end)

	local SECTION_ICONS = {
		ESP = "eye",
		Visuals = "diamond",
		Misc = "dots",
		Config = "bars",
		Themes = "palette",
	}

	-- Создаёт раздел в sidebar и сетку карточек. Возвращает внутреннюю запись (section data).
	local function createSection(name, groupName, iconKind)
		sectionOrder += 1
		groupName = groupName or "Modules"
		local group = groups[groupName] or createGroup(groupName, "dot")
		group.sections[name] = true

		local nav = new("TextButton", {
			LayoutOrder = sectionOrder,
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			Text = "",
			Parent = group.list,
		})

		local pill = new("Frame", {
			Position = UDim2.fromOffset(24, 3),
			Size = UDim2.new(1, -24, 1, -6),
			BackgroundColor3 = C.accentDim,
			BackgroundTransparency = 0.6,
			BorderSizePixel = 0,
			Visible = false,
			Parent = nav,
		})
		round(pill, 6)

		new("Frame", {
			Position = UDim2.fromOffset(16, 0),
			Size = UDim2.new(0, 1, 1, 0),
			BackgroundColor3 = C.line,
			BackgroundTransparency = 0.3,
			BorderSizePixel = 0,
			Parent = nav,
		})
		new("Frame", {
			Position = UDim2.new(0, 16, 0.5, 0),
			Size = UDim2.fromOffset(8, 1),
			BackgroundColor3 = C.line,
			BackgroundTransparency = 0.3,
			BorderSizePixel = 0,
			Parent = nav,
		})

		local iconHolder = new("Frame", {
			Position = UDim2.new(0, 28, 0.5, -7),
			Size = UDim2.fromOffset(14, 14),
			BackgroundTransparency = 1,
			Parent = nav,
		})
		local setIcon = drawIcon(iconHolder, iconKind or SECTION_ICONS[name] or "dot", 11)
		setIcon(C.sub)

		local label = new("TextLabel", {
			Position = UDim2.fromOffset(48, 0),
			Size = UDim2.new(1, -48, 1, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.sub,
			Text = name,
			Parent = nav,
		})

		local grid = makeScroller(name .. "_Grid")
		new("UIGridLayout", {
			CellSize = UDim2.new(0.5, -5, 0, 66),
			CellPadding = UDim2.fromOffset(10, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = grid,
		})

		sections[name] = {
			name = name,
			grid = grid,
			cards = {},
			modules = {},
			group = groupName,
			order = sectionOrder,
			nav = { setIcon = setIcon, label = label, pill = pill },
		}

		nav.MouseEnter:Connect(function()
			if currentSection ~= name then
				label.TextColor3 = C.text
			end
		end)
		nav.MouseLeave:Connect(function()
			if currentSection ~= name then
				label.TextColor3 = C.sub
			end
		end)
		nav.MouseButton1Click:Connect(function()
			selectSection(name)
		end)

		return sections[name]
	end

	--------------------------------------------------------------------
	-- Элементы страницы настроек
	--   page:AddToggle{ Name, Source?, Key?, Flag?, Default?, Callback? }
	--   page:AddSlider{ Name, Min, Max, Step?, ... }
	--   page:AddChoice{ Name, Options, ... }
	--   page:AddColor{ Name, Palette?, ... }
	--   page:AddTextBox{ Name, MaxLength?, ... }
	--   page:AddButton{ Name, Text, Callback }
	-- Если Source не задан, значение хранится в Window.Flags[Flag или Name].
	-- Если задан, то Source[Key] читается и пишется напрямую (как в оригинале).
	--------------------------------------------------------------------
	local COLOR_PRESETS = {
		Color3.fromRGB(255, 90, 90),
		Color3.fromRGB(255, 160, 60),
		Color3.fromRGB(255, 230, 90),
		Color3.fromRGB(90, 220, 120),
		Color3.fromRGB(90, 230, 230),
		Color3.fromRGB(90, 170, 255),
		Color3.fromRGB(150, 185, 255),
		Color3.fromRGB(50, 90, 255),
		Color3.fromRGB(30, 50, 170),
		Color3.fromRGB(170, 110, 255),
		Color3.fromRGB(255, 120, 200),
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(180, 190, 210),
		Color3.fromRGB(60, 60, 70),
		Color3.fromRGB(15, 15, 15),
	}
	Library.ColorPresets = COLOR_PRESETS

	local function resolveSource(def, hint)
		local source = def.Source
		local key = def.Key
		if not source then
			source = Window.Flags
			key = key or def.Flag or def.Name
		else
			registerConfig(hint or def.Name or "Source", source)
		end
		if source[key] == nil and def.Default ~= nil then
			source[key] = def.Default
		end
		return source, key
	end

	local function settingRow(page, labelText, height)
		local row = new("Frame", {
			LayoutOrder = #page:GetChildren(),
			Size = UDim2.new(1, 0, 0, height),
			BackgroundColor3 = C.card,
			BackgroundTransparency = 0.2,
			BorderSizePixel = 0,
			Parent = page,
		})
		round(row, 8)
		outline(row, C.line, 0.7)
		table.insert(glassRows, row)
		new("UIGradient", {
			Rotation = 90,
			Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(215, 215, 215)),
			Parent = row,
		})
		new("TextLabel", {
			Position = UDim2.fromOffset(12, 0),
			Size = UDim2.new(1, -140, 0, 38),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.text,
			Text = labelText,
			Parent = row,
		})
		return row
	end

	local function toggleSetting(page, def)
		local source, key = resolveSource(def)
		local row = settingRow(page, def.Name, 38)

		local pill = new("Frame", {
			Position = UDim2.new(1, -50, 0.5, -9),
			Size = UDim2.fromOffset(36, 18),
			BackgroundColor3 = C.off,
			BorderSizePixel = 0,
			Parent = row,
		})
		round(pill, 9)
		local knob = new("Frame", {
			Size = UDim2.fromOffset(14, 14),
			BackgroundColor3 = C.text,
			BorderSizePixel = 0,
			Parent = pill,
		})
		round(knob, 7)
		local button = new("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = "",
			Parent = row,
		})

		local function refresh()
			local on = source[key]
			pill.BackgroundColor3 = on and C.accent or C.off
			knob.Position = on and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
		end

		button.MouseButton1Click:Connect(function()
			source[key] = not source[key]
			refresh()
			playToggleSound(source[key])
			fire(def.Callback, source[key])
		end)
		refresh()
		table.insert(uiRefreshers, refresh)

		return {
			Row = row,
			Get = function()
				return source[key]
			end,
			Set = function(_, value)
				source[key] = value and true or false
				refresh()
				fire(def.Callback, source[key])
			end,
		}
	end

	local function textSetting(page, def)
		local source, key = resolveSource(def)
		if source[key] == nil then
			source[key] = ""
		end
		local maxLength = def.MaxLength or 20
		local row = settingRow(page, def.Name, 38)

		local box = new("TextBox", {
			Position = UDim2.new(1, -142, 0.5, -12),
			Size = UDim2.fromOffset(130, 24),
			BackgroundColor3 = C.inner,
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = C.text,
			PlaceholderText = def.Placeholder or S.Empty,
			PlaceholderColor3 = C.sub,
			ClearTextOnFocus = false,
			Text = tostring(source[key]),
			Parent = row,
		})
		round(box, 6)
		outline(box, C.line, 0.6)

		box.FocusLost:Connect(function()
			source[key] = string.sub(box.Text, 1, maxLength)
			box.Text = source[key]
			fire(def.Callback, source[key])
		end)

		local function refresh()
			box.Text = tostring(source[key])
		end
		table.insert(uiRefreshers, refresh)

		return {
			Row = row,
			Get = function()
				return source[key]
			end,
			Set = function(_, value)
				source[key] = string.sub(tostring(value), 1, maxLength)
				refresh()
				fire(def.Callback, source[key])
			end,
		}
	end

	local function actionSetting(page, def)
		local row = settingRow(page, def.Name, 38)
		local button = new("TextButton", {
			Position = UDim2.new(1, -122, 0.5, -12),
			Size = UDim2.fromOffset(110, 24),
			BackgroundColor3 = C.accent,
			BorderSizePixel = 0,
			AutoButtonColor = true,
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextColor3 = C.text,
			Text = def.Text or def.Name,
			Parent = row,
		})
		round(button, 6)
		button.MouseButton1Click:Connect(function()
			fire(def.Callback)
		end)
		return { Row = row, Button = button }
	end

	-- Ползунок: тяните мышью или впишите точное значение в окошко справа
	local activeSlider = nil
	bind(UserInputService.InputChanged, function(input)
		if activeSlider and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			activeSlider(input.Position.X)
		end
	end)
	bind(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			activeSlider = nil
		end
	end)

	local function numberSetting(page, def)
		local source, key = resolveSource(def)
		local minValue, maxValue = def.Min or 0, def.Max or 1
		if source[key] == nil then
			source[key] = minValue
		end
		local row = settingRow(page, def.Name, 56)
		local range = maxValue - minValue
		local step = def.Step or (range <= 5 and 0.05 or (range <= 50 and 0.5 or 1))

		local function format(value)
			if step >= 1 then
				return tostring(math.floor(value + 0.5))
			end
			return (string.format("%.2f", value):gsub("0+$", ""):gsub("%.$", ""))
		end

		local box = new("TextBox", {
			Position = UDim2.new(1, -70, 0, 8),
			Size = UDim2.fromOffset(58, 22),
			BackgroundColor3 = C.inner,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextColor3 = C.text,
			ClearTextOnFocus = false,
			Text = format(source[key]),
			Parent = row,
		})
		round(box, 6)
		outline(box, C.line, 0.6)

		local track = new("TextButton", {
			Position = UDim2.new(0, 12, 0, 40),
			Size = UDim2.new(1, -24, 0, 6),
			BackgroundColor3 = C.inner,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Text = "",
			Parent = row,
		})
		round(track, 3)

		local fill = new("Frame", {
			Size = UDim2.fromScale(0, 1),
			BackgroundColor3 = C.accent,
			BorderSizePixel = 0,
			Parent = track,
		})
		round(fill, 3)

		local knob = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromOffset(14, 14),
			BackgroundColor3 = C.text,
			BorderSizePixel = 0,
			ZIndex = 2,
			Parent = track,
		})
		round(knob, 7)
		local knobStroke = new("UIStroke", { Color = C.accent, Thickness = 2, Parent = knob })
		local knobScale = new("UIScale", { Parent = knob })

		local function refresh()
			local value = math.clamp(source[key], minValue, maxValue)
			local alpha = range > 0 and (value - minValue) / range or 0
			fill.Size = UDim2.fromScale(alpha, 1)
			knob.Position = UDim2.fromScale(alpha, 0.5)
			knobStroke.Color = C.accent
			if not box:IsFocused() then
				box.Text = format(source[key])
			end
		end

		local function setFromX(x)
			local alpha = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
			local value = minValue + alpha * range
			value = math.floor(value / step + 0.5) * step
			source[key] = math.clamp(value, minValue, maxValue)
			refresh()
			fire(def.Callback, source[key])
		end

		track.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				activeSlider = setFromX
				setFromX(input.Position.X)
			end
		end)
		track.MouseEnter:Connect(function()
			TweenService:Create(knobScale, TweenInfo.new(0.1), { Scale = 1.2 }):Play()
		end)
		track.MouseLeave:Connect(function()
			TweenService:Create(knobScale, TweenInfo.new(0.1), { Scale = 1 }):Play()
		end)

		box.FocusLost:Connect(function()
			local value = tonumber(box.Text)
			if value then
				source[key] = math.clamp(value, minValue, maxValue)
				fire(def.Callback, source[key])
			end
			refresh()
		end)

		refresh()
		table.insert(uiRefreshers, refresh)

		return {
			Row = row,
			Get = function()
				return source[key]
			end,
			Set = function(_, value)
				source[key] = math.clamp(value, minValue, maxValue)
				refresh()
				fire(def.Callback, source[key])
			end,
		}
	end

	-- Выбор варианта: все варианты видны сразу кнопками-«чипами»
	local function choiceSetting(page, def)
		local source, key = resolveSource(def)
		local options = def.Options or {}
		if source[key] == nil then
			source[key] = options[1]
		end
		local columns = math.max(1, math.min(#options, 3))
		local rows = math.ceil(#options / columns)
		local chipHeight, gap = 28, 6
		local row = settingRow(page, def.Name, 38 + rows * (chipHeight + gap) + 4)

		local grid = new("Frame", {
			Position = UDim2.fromOffset(12, 36),
			Size = UDim2.new(1, -24, 0, rows * (chipHeight + gap)),
			BackgroundTransparency = 1,
			Parent = row,
		})
		new("UIGridLayout", {
			CellSize = UDim2.new(1 / columns, -gap, 0, chipHeight),
			CellPadding = UDim2.fromOffset(gap, gap),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = grid,
		})

		local chips = {}
		local function refresh()
			for option, chip in pairs(chips) do
				local selected = source[key] == option
				chip.button.BackgroundColor3 = selected and C.accent or C.inner
				chip.button.TextColor3 = selected and C.text or C.sub
				chip.button.Font = selected and Enum.Font.GothamBold or Enum.Font.Gotham
				chip.stroke.Color = selected and C.accent or C.line
				chip.stroke.Transparency = selected and 0.2 or 0.6
			end
		end

		for index, option in ipairs(options) do
			local button = new("TextButton", {
				LayoutOrder = index,
				BackgroundColor3 = C.inner,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextColor3 = C.sub,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Text = tostring(option),
				Parent = grid,
			})
			round(button, 6)
			local stroke = outline(button, C.line, 0.6)
			chips[option] = { button = button, stroke = stroke }

			button.MouseButton1Click:Connect(function()
				if source[key] ~= option then
					source[key] = option
					refresh()
					playToggleSound(true)
					fire(def.Callback, option)
				end
			end)
			button.MouseEnter:Connect(function()
				if source[key] ~= option then
					button.TextColor3 = C.text
					stroke.Transparency = 0.3
				end
			end)
			button.MouseLeave:Connect(function()
				refresh()
			end)
		end

		refresh()
		table.insert(uiRefreshers, refresh)

		return {
			Row = row,
			Get = function()
				return source[key]
			end,
			Set = function(_, value)
				source[key] = value
				refresh()
				fire(def.Callback, value)
			end,
		}
	end

	local function colorSetting(page, def)
		local source, key = resolveSource(def)
		local palette = def.Palette or COLOR_PRESETS
		if source[key] == nil then
			source[key] = palette[1]
		end
		local row = settingRow(page, def.Name, 94)

		local grid = new("Frame", {
			Position = UDim2.fromOffset(12, 36),
			Size = UDim2.new(1, -24, 0, 52),
			BackgroundTransparency = 1,
			Parent = row,
		})
		new("UIGridLayout", {
			CellSize = UDim2.fromOffset(28, 22),
			CellPadding = UDim2.fromOffset(6, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = grid,
		})

		local function sameColor(a, b)
			if typeof(a) ~= "Color3" or typeof(b) ~= "Color3" then
				return false
			end
			return math.abs(a.R - b.R) < 0.004 and math.abs(a.G - b.G) < 0.004 and math.abs(a.B - b.B) < 0.004
		end

		local swatches = {}
		local function refresh()
			for _, swatch in ipairs(swatches) do
				local selected = sameColor(source[key], swatch.color)
				swatch.ring.Visible = selected
				swatch.ringStroke.Color = C.accent
				swatch.scale.Scale = selected and 1.08 or 1
			end
		end

		for index, color in ipairs(palette) do
			local swatch = new("TextButton", {
				LayoutOrder = index,
				AutoButtonColor = false,
				BackgroundColor3 = color,
				BorderSizePixel = 0,
				Text = "",
				Parent = grid,
			})
			round(swatch, 5)
			new("UIStroke", {
				Color = Color3.fromRGB(0, 0, 0),
				Transparency = 0.6,
				Thickness = 1,
				Parent = swatch,
			})
			local scale = new("UIScale", { Parent = swatch })

			local ring = new("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.new(1, 7, 1, 7),
				BackgroundTransparency = 1,
				Visible = false,
				Parent = swatch,
			})
			round(ring, 8)
			local ringStroke = new("UIStroke", {
				Color = C.accent,
				Thickness = 2,
				Parent = ring,
			})

			swatch:SetAttribute("KeepColor", true)
			swatches[index] = { color = color, ring = ring, ringStroke = ringStroke, scale = scale }

			swatch.MouseButton1Click:Connect(function()
				source[key] = color
				refresh()
				playToggleSound(true)
				fire(def.Callback, color)
			end)
			swatch.MouseEnter:Connect(function()
				if not sameColor(source[key], color) then
					scale.Scale = 1.05
				end
			end)
			swatch.MouseLeave:Connect(function()
				refresh()
			end)
		end
		refresh()
		table.insert(uiRefreshers, refresh)

		return {
			Row = row,
			Get = function()
				return source[key]
			end,
			Set = function(_, value)
				source[key] = value
				refresh()
				fire(def.Callback, value)
			end,
		}
	end

	-- Объект страницы: из него вызываются Add*
	local function makePageObject(pageFrame)
		local pageObject = { Frame = pageFrame }
		function pageObject:AddToggle(def)
			return toggleSetting(pageFrame, def)
		end
		function pageObject:AddSlider(def)
			return numberSetting(pageFrame, def)
		end
		function pageObject:AddChoice(def)
			return choiceSetting(pageFrame, def)
		end
		function pageObject:AddColor(def)
			return colorSetting(pageFrame, def)
		end
		function pageObject:AddTextBox(def)
			return textSetting(pageFrame, def)
		end
		function pageObject:AddButton(def)
			return actionSetting(pageFrame, def)
		end
		return pageObject
	end

	local function makeSettingsPage(name)
		local page = makeScroller(name)
		new("UIListLayout", {
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = page,
		})
		return page
	end

	--------------------------------------------------------------------
	-- Клавиши для функций: ПКМ по карточке -> нажмите клавишу (Esc/Backspace — убрать)
	--------------------------------------------------------------------
	local bindingTarget = nil

	local function finishBinding()
		if bindingTarget then
			bindingTarget.stop()
			bindingTarget = nil
		end
	end

	bind(UserInputService.InputBegan, function(input, gameProcessed)
		if bindingTarget then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				local name = bindingTarget.name
				if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
					KEYBINDS[name] = nil
				elseif input.KeyCode ~= menuKey then
					for otherName, key in pairs(KEYBINDS) do
						if key == input.KeyCode.Name then
							KEYBINDS[otherName] = nil
						end
					end
					KEYBINDS[name] = input.KeyCode.Name
				end
				finishBinding()
				for _, refresh in ipairs(uiRefreshers) do
					refresh()
				end
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
				finishBinding()
			end
			return
		end

		if gameProcessed or input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		for name, key in pairs(KEYBINDS) do
			if key == input.KeyCode.Name and moduleRegistry[name] then
				moduleRegistry[name].toggle()
			end
		end
	end)

	--------------------------------------------------------------------
	-- Карточка-модуль
	--   section:AddModule{ Name, Description, Icon, Source?, Key?, Flag?, Default?,
	--                      Callback(on)?, Settings(page)? }
	--------------------------------------------------------------------
	local function addModule(section, rawDef)
		local def = {
			name = rawDef.Name,
			desc = rawDef.Description or "",
			icon = rawDef.Icon,
			settings = rawDef.Settings,
			onToggle = rawDef.Callback or rawDef.OnToggle,
		}
		do
			local source, key = rawDef.Source, rawDef.Key
			if not source then
				source = Window.Flags
				key = rawDef.Flag or rawDef.Name
				if source[key] == nil then
					source[key] = rawDef.Default and true or false
				end
			else
				key = key or "Enabled"
				registerConfig(rawDef.Name, source)
				if source[key] == nil then
					source[key] = rawDef.Default and true or false
				end
			end
			def.source, def.key = source, key
		end

		local card = new("TextButton", {
			LayoutOrder = #section.cards + 1,
			BackgroundColor3 = C.card,
			BackgroundTransparency = 0.05,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Text = "",
			Parent = section.grid,
		})
		round(card, 8)
		local cardStroke = outline(card, C.line, 0.65)
		local cardScale = new("UIScale", { Parent = card })
		new("UIGradient", {
			Rotation = 90,
			Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(205, 205, 205)),
			Parent = card,
		})

		local switch = new("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -10, 0, 11),
			Size = UDim2.fromOffset(30, 16),
			BackgroundColor3 = C.off,
			BorderSizePixel = 0,
			Parent = card,
		})
		round(switch, 8)
		local switchKnob = new("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 2, 0.5, 0),
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = C.text,
			BorderSizePixel = 0,
			Parent = switch,
		})
		round(switchKnob, 6)

		local icon = new("Frame", {
			Position = UDim2.fromOffset(10, 8),
			Size = UDim2.fromOffset(22, 22),
			BackgroundColor3 = C.accentDim,
			BorderSizePixel = 0,
			Parent = card,
		})
		round(icon, 6)
		local setIcon = drawIcon(icon, def.icon or "dot", 12)

		local title = new("TextLabel", {
			Position = UDim2.fromOffset(40, 8),
			Size = UDim2.new(1, def.settings and -112 or -88, 0, 22),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextColor3 = C.text,
			Text = def.name,
			Parent = card,
		})

		local descLabel = new("TextLabel", {
			Position = UDim2.fromOffset(12, 32),
			Size = UDim2.new(1, -24, 0, 28),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextColor3 = C.sub,
			Text = def.desc,
			Parent = card,
		})

		local iconScale = new("UIScale", { Parent = icon })

		local badge = new("TextLabel", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, def.settings and -70 or -46, 0, 10),
			Size = UDim2.fromOffset(0, 18),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = C.inner,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			TextSize = 11,
			TextColor3 = C.text,
			Text = "",
			Visible = false,
			Parent = card,
		})
		round(badge, 5)
		new("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), Parent = badge })
		outline(badge, C.line, 0.5)

		local module = { name = def.name, page = nil }
		local moduleObject = { Name = def.name, Frame = card }

		-- Страница настроек создаётся сразу (если есть Settings) или позже, при первом module:Add*
		local pageObject = nil
		local function ensureSettings()
			if pageObject then
				return pageObject
			end
			def.settings = def.settings or function() end
			local dots = new("TextButton", {
				Position = UDim2.new(1, -64, 0, 8),
				Size = UDim2.fromOffset(22, 22),
				BackgroundTransparency = 1,
				Text = "",
				ZIndex = 2,
				Parent = card,
			})
			drawIcon(dots, "kebab", 14)(C.sub)

			local page = makeSettingsPage(def.name .. "_Settings")
			module.page = page
			pageObject = makePageObject(page)
			title.Size = UDim2.new(1, -112, 0, 22)
			badge.Position = UDim2.new(1, -70, 0, 10)

			dots.MouseButton1Click:Connect(function()
				openSettings(module)
			end)
			return pageObject
		end

		if def.settings then
			local userSettings = def.settings
			def.settings = nil
			local page = ensureSettings()
			def.settings = userSettings
			userSettings(page)
		end

		local function refresh()
			local on = def.source[def.key]
			icon.BackgroundColor3 = on and C.accent or C.accentDim
			icon.BackgroundTransparency = on and 0 or 0.25
			setIcon(on and C.text or C.sub)
			title.TextColor3 = C.text
			cardStroke.Color = on and C.accent or C.line
			cardStroke.Transparency = on and 0.3 or 0.65

			switch.BackgroundColor3 = on and C.accent or C.off
			TweenService:Create(switchKnob, TweenInfo.new(0.16, Enum.EasingStyle.Quad), {
				Position = on and UDim2.new(1, -14, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
			}):Play()

			local key = KEYBINDS[def.name]
			badge.Visible = key ~= nil
			badge.Text = key or ""
			if bindingTarget == nil or bindingTarget.name ~= def.name then
				descLabel.Text = def.desc
				descLabel.TextColor3 = C.sub
			end
		end

		local function toggle()
			def.source[def.key] = not def.source[def.key]
			refresh()
			updateCounter()
			local on = def.source[def.key]
			playToggleSound(on)
			Library:Notify(def.name, on)
			iconScale.Scale = 1.3
			TweenService:Create(iconScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
			fire(def.onToggle, on)
		end
		moduleRegistry[def.name] = { toggle = toggle, def = def, group = section.group, section = section.name }

		card.MouseButton1Click:Connect(toggle)

		-- ПКМ: назначить клавишу
		card.MouseButton2Click:Connect(function()
			finishBinding()
			descLabel.Text = S.PressKey
			descLabel.TextColor3 = C.accent
			bindingTarget = {
				name = def.name,
				stop = function()
					descLabel.Text = def.desc
					descLabel.TextColor3 = C.sub
				end,
			}
		end)

		local hoverInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		card.MouseEnter:Connect(function()
			TweenService:Create(card, hoverInfo, { BackgroundColor3 = C.cardHover }):Play()
			TweenService:Create(cardScale, hoverInfo, { Scale = 1.025 }):Play()
		end)
		card.MouseLeave:Connect(function()
			TweenService:Create(card, hoverInfo, { BackgroundColor3 = C.card }):Play()
			TweenService:Create(cardScale, hoverInfo, { Scale = 1 }):Play()
		end)

		refresh()
		table.insert(uiRefreshers, refresh)
		table.insert(uiRefreshers, updateCounter)
		table.insert(section.modules, def)
		table.insert(section.cards, { frame = card, name = def.name, desc = def.desc })

		-- API модуля
		function moduleObject:Get()
			return def.source[def.key]
		end
		function moduleObject:Set(value)
			if (def.source[def.key] and true or false) ~= (value and true or false) then
				toggle()
			end
		end
		function moduleObject:Toggle()
			toggle()
		end
		function moduleObject:GetPage()
			return ensureSettings()
		end
		function moduleObject:AddToggle(d)
			return ensureSettings():AddToggle(d)
		end
		function moduleObject:AddSlider(d)
			return ensureSettings():AddSlider(d)
		end
		function moduleObject:AddChoice(d)
			return ensureSettings():AddChoice(d)
		end
		function moduleObject:AddColor(d)
			return ensureSettings():AddColor(d)
		end
		function moduleObject:AddTextBox(d)
			return ensureSettings():AddTextBox(d)
		end
		function moduleObject:AddButton(d)
			return ensureSettings():AddButton(d)
		end
		return moduleObject
	end

	--------------------------------------------------------------------
	-- Карточка-пресет (как в разделе «Образы»): клик применяет набор значений
	--   section:AddPreset{ Name, Description, Icon, Apply = { [таблица] = { Key = value } } или function,
	--                      Notify = true }
	--------------------------------------------------------------------
	local function addPreset(section, def)
		local card = new("TextButton", {
			LayoutOrder = #section.cards + 1,
			BackgroundColor3 = C.card,
			BackgroundTransparency = 0.05,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Text = "",
			Parent = section.grid,
		})
		round(card, 8)
		local stroke = outline(card, C.line, 0.65)
		local cardScale = new("UIScale", { Parent = card })

		local icon = new("Frame", {
			Position = UDim2.fromOffset(10, 8),
			Size = UDim2.fromOffset(22, 22),
			BackgroundColor3 = C.accent,
			BorderSizePixel = 0,
			Parent = card,
		})
		round(icon, 6)
		drawIcon(icon, def.Icon or "dot", 12)(C.text)

		new("TextLabel", {
			Position = UDim2.fromOffset(40, 8),
			Size = UDim2.new(1, -50, 0, 22),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.text,
			Text = def.Name,
			Parent = card,
		})
		local descText = def.Description or ""
		local descLabel = new("TextLabel", {
			Position = UDim2.fromOffset(12, 32),
			Size = UDim2.new(1, -24, 0, 28),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextColor3 = C.sub,
			Text = descText,
			Parent = card,
		})

		local function apply()
			if type(def.Apply) == "function" then
				fire(def.Apply)
			elseif type(def.Apply) == "table" then
				for source, values in pairs(def.Apply) do
					for key, value in pairs(values) do
						source[key] = value
					end
				end
			end
			Window:Refresh()
			playToggleSound(true)
			if def.Notify ~= false then
				Library:Notify(def.Name, def.NotifyState ~= false)
			end
			descLabel.Text = S.Applied
			descLabel.TextColor3 = C.accent
			task.delay(1.4, function()
				descLabel.Text = descText
				descLabel.TextColor3 = C.sub
			end)
		end
		card.MouseButton1Click:Connect(apply)

		local hover = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		card.MouseEnter:Connect(function()
			TweenService:Create(card, hover, { BackgroundColor3 = C.cardHover }):Play()
			TweenService:Create(cardScale, hover, { Scale = 1.025 }):Play()
			stroke.Color = C.accent
			stroke.Transparency = 0.3
		end)
		card.MouseLeave:Connect(function()
			TweenService:Create(card, hover, { BackgroundColor3 = C.card }):Play()
			TweenService:Create(cardScale, hover, { Scale = 1 }):Play()
			stroke.Color = C.line
			stroke.Transparency = 0.65
		end)

		table.insert(section.cards, { frame = card, name = def.Name, desc = descText })
		return { Frame = card, Apply = apply }
	end

	--------------------------------------------------------------------
	-- Публичные методы раздела / окна
	--------------------------------------------------------------------
	local function wrapSection(data)
		local object = { Name = data.name, Data = data, Grid = data.grid }
		function object:AddModule(def)
			return addModule(data, def)
		end
		function object:AddPreset(def)
			return addPreset(data, def)
		end
		function object:Select()
			selectSection(data.name)
		end
		data.object = object
		return object
	end

	-- Window:AddSection("Visuals", "Modules", "diamond") -> объект раздела
	function Window:AddSection(name, groupName, iconKind)
		return wrapSection(createSection(name, groupName, iconKind))
	end

	function Window:SelectSection(name)
		selectSection(name)
	end

	function Window:GetSection(name)
		return sections[name] and sections[name].object
	end

	--------------------------------------------------------------------
	-- Темы
	--------------------------------------------------------------------
	local appliedTheme = "Бордовый"
	local themeCards = {}
	local themesSectionAdded = false

	local function colorKey(color)
		return string.format("%d,%d,%d",
			math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
	end

	local function recolor(root, map)
		for _, obj in ipairs(root:GetDescendants()) do
			if obj:IsA("GuiObject") and obj:GetAttribute("KeepColor") then
				continue
			end
			if obj:IsA("GuiObject") then
				local background = map[colorKey(obj.BackgroundColor3)]
				if background then
					obj.BackgroundColor3 = background
				end
				if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
					local textColor = map[colorKey(obj.TextColor3)]
					if textColor then
						obj.TextColor3 = textColor
					end
					if obj:IsA("TextBox") then
						local placeholder = map[colorKey(obj.PlaceholderColor3)]
						if placeholder then
							obj.PlaceholderColor3 = placeholder
						end
					end
				end
				if obj:IsA("ScrollingFrame") then
					local bar = map[colorKey(obj.ScrollBarImageColor3)]
					if bar then
						obj.ScrollBarImageColor3 = bar
					end
				end
			elseif obj:IsA("UIStroke") then
				local strokeColor = map[colorKey(obj.Color)]
				if strokeColor then
					obj.Color = strokeColor
				end
			elseif obj:IsA("UIGradient") then
				local changed, keypoints = false, {}
				for _, keypoint in ipairs(obj.Color.Keypoints) do
					local mapped = map[colorKey(keypoint.Value)]
					changed = changed or mapped ~= nil
					table.insert(keypoints, ColorSequenceKeypoint.new(keypoint.Time, mapped or keypoint.Value))
				end
				if changed then
					obj.Color = ColorSequence.new(keypoints)
				end
			end
		end
	end

	local function refreshThemeCards()
		for name, entry in pairs(themeCards) do
			local active = name == appliedTheme
			entry.stroke.Color = active and C.accent or C.line
			entry.stroke.Transparency = active and 0.2 or 0.65
			entry.badge.Visible = active
			entry.badge.TextColor3 = C.accent
		end
	end

	-- Тема «Прозрачный»: подложки становятся почти невидимым стеклом
	local CLEAR_THEME = "Прозрачный"
	local clearLevels = nil
	local clearConnection = nil

	local function clearObject(obj)
		if obj:GetAttribute("KeepColor") then
			return
		end
		if obj:IsA("GuiObject") then
			local level = clearLevels[colorKey(obj.BackgroundColor3)]
			if level and obj.BackgroundTransparency < 1 and obj:GetAttribute("OpusClearBg") == nil then
				obj:SetAttribute("OpusClearBg", obj.BackgroundTransparency)
				obj.BackgroundTransparency = math.max(obj.BackgroundTransparency, level)
			end
			if (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox"))
				and obj:GetAttribute("OpusClearText") == nil then
				obj:SetAttribute("OpusClearText", obj.TextStrokeTransparency)
				obj.TextStrokeTransparency = math.min(obj.TextStrokeTransparency, 0.7)
			end
		elseif obj:IsA("UIStroke") and obj:GetAttribute("OpusClearStroke") == nil and obj.Transparency < 1 then
			obj:SetAttribute("OpusClearStroke", obj.Transparency)
			obj.Transparency = obj.Transparency * 0.55
		end
	end

	local function restoreObject(obj)
		local bg = obj:GetAttribute("OpusClearBg")
		if bg ~= nil then
			obj.BackgroundTransparency = bg
			obj:SetAttribute("OpusClearBg", nil)
		end
		local text = obj:GetAttribute("OpusClearText")
		if text ~= nil then
			obj.TextStrokeTransparency = text
			obj:SetAttribute("OpusClearText", nil)
		end
		local stroke = obj:GetAttribute("OpusClearStroke")
		if stroke ~= nil then
			obj.Transparency = stroke
			obj:SetAttribute("OpusClearStroke", nil)
		end
	end

	local function setClearMode(on)
		if on then
			local theme = THEMES[CLEAR_THEME]
			clearLevels = {
				[colorKey(theme.bgTop)] = 0.9, [colorKey(theme.bgBottom)] = 0.88,
				[colorKey(theme.panel)] = 0.9, [colorKey(theme.card)] = 0.86,
				[colorKey(theme.cardHover)] = 0.82, [colorKey(theme.inner)] = 0.85,
				[colorKey(theme.off)] = 0.65, [colorKey(theme.accentDim)] = 0.55,
			}
			for _, obj in ipairs(screenGui:GetDescendants()) do
				clearObject(obj)
			end
			if not clearConnection then
				clearConnection = screenGui.DescendantAdded:Connect(function(obj)
					task.defer(function()
						if obj.Parent and clearLevels then
							clearObject(obj)
						end
					end)
				end)
				table.insert(connections, clearConnection)
			end
		else
			if clearConnection then
				clearConnection:Disconnect()
				clearConnection = nil
			end
			if clearLevels then
				clearLevels = nil
				for _, obj in ipairs(screenGui:GetDescendants()) do
					restoreObject(obj)
				end
			end
		end
	end

	local function applyTheme(name)
		local theme = THEMES[name]
		if not theme then
			return
		end
		if name ~= appliedTheme then
			local map = {}
			for _, key in ipairs(THEME_KEYS) do
				map[colorKey(C[key])] = theme[key]
			end
			recolor(screenGui, map)
			for _, gui in ipairs(Library._themedGuis) do
				if gui.Parent then
					recolor(gui, map)
				end
			end
			for _, key in ipairs(THEME_KEYS) do
				C[key] = theme[key]
			end
			appliedTheme = name
		end
		MENU_STYLE.Theme = name
		setClearMode(name == CLEAR_THEME)
		for _, refresh in ipairs(uiRefreshers) do
			refresh()
		end
		refreshThemeCards()
		if currentSection and not currentModule then
			selectSection(currentSection)
		end
	end

	function Window:SetTheme(name)
		applyTheme(name)
	end

	function Window:GetTheme()
		return appliedTheme
	end

	-- Раздел Themes: карточки тем + Стекло / Предпросмотр / Уведомления / Размытие фона
	function Window:AddThemesSection(groupName)
		if themesSectionAdded then
			return sections["Themes"] and sections["Themes"].object
		end
		themesSectionAdded = true
		local themesData = createSection("Themes", groupName or "Settings", "palette")
		local themesObject = wrapSection(themesData)

		for index, name in ipairs(THEME_ORDER) do
			local theme = THEMES[name]
			local card = new("TextButton", {
				LayoutOrder = index,
				BackgroundColor3 = C.card,
				BackgroundTransparency = 0.15,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Text = "",
				Parent = themesData.grid,
			})
			round(card, 8)
			local stroke = outline(card, C.line, 0.65)

			new("TextLabel", {
				Position = UDim2.fromOffset(12, 8),
				Size = UDim2.new(1, -80, 0, 20),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = C.text,
				Text = name,
				Parent = card,
			})

			local badge = new("TextLabel", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -10, 0, 8),
				Size = UDim2.fromOffset(70, 20),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextColor3 = C.accent,
				Text = S.ThemeActive,
				Visible = false,
				Parent = card,
			})

			for i, key in ipairs({ "bgTop", "card", "accentDim", "accent" }) do
				local swatch = new("Frame", {
					Position = UDim2.fromOffset(12 + (i - 1) * 24, 36),
					Size = UDim2.fromOffset(18, 18),
					BackgroundColor3 = theme[key],
					BorderSizePixel = 0,
					Parent = card,
				})
				round(swatch, 9)
				new("UIStroke", { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.8, Parent = swatch })
				swatch:SetAttribute("KeepColor", true)
			end

			card.MouseButton1Click:Connect(function()
				applyTheme(name)
				playToggleSound(true)
			end)
			card.MouseEnter:Connect(function()
				card.BackgroundColor3 = C.cardHover
			end)
			card.MouseLeave:Connect(function()
				card.BackgroundColor3 = C.card
			end)

			themeCards[name] = { stroke = stroke, badge = badge }
			table.insert(themesData.cards, { frame = card, name = name, desc = S.ThemeWord })
		end

		themesObject:AddModule({
			Name = S.GlassName,
			Description = S.GlassDesc,
			Icon = "diamond",
			Source = MENU_STYLE,
			Key = "Glass",
			Settings = function(page)
				page:AddSlider({ Name = S.GlassLevel, Source = MENU_STYLE, Key = "GlassLevel", Min = 0, Max = 0.8 })
			end,
		})
		themesObject:AddModule({
			Name = S.PreviewName,
			Description = S.PreviewDesc,
			Icon = "eye",
			Source = MENU_STYLE,
			Key = "Preview",
		})
		themesObject:AddModule({
			Name = S.ToastsName,
			Description = S.ToastsDesc,
			Icon = "bars",
			Source = MENU_STYLE,
			Key = "Toasts",
		})
		themesObject:AddModule({
			Name = S.BlurName,
			Description = S.BlurDesc,
			Icon = "ring",
			Source = MENU_STYLE,
			Key = "Blur",
			Callback = function()
				if updateMenuBlur then
					updateMenuBlur()
				end
			end,
		})

		refreshThemeCards()

		-- после загрузки конфига применяем сохранённую в нём тему и размытие
		table.insert(uiRefreshers, function()
			if MENU_STYLE.Theme ~= appliedTheme and THEMES[MENU_STYLE.Theme] then
				applyTheme(MENU_STYLE.Theme)
			end
			if updateMenuBlur then
				updateMenuBlur()
			end
		end)
		return themesObject
	end

	--------------------------------------------------------------------
	-- Раздел Config: свои конфиги с названиями
	--   Window:AddConfigSection{ Group = "Settings", MaxConfigs = 20, MaxNameLength = 30,
	--                            FileName = "OpusUI_configs.json",
	--                            Backend = { Load = function() return { configs = {}, autoload = nil } end,
	--                                        Save = function(configs, autoload) end } }
	-- Без Backend используется файл (writefile/readfile, если есть в экзекуторе) или память.
	--------------------------------------------------------------------
	local configSectionAdded = false

	local function serializeSettings()
		local data = {}
		for _, groupName in ipairs(Window.ConfigOrder) do
			local source = Window.ConfigTables[groupName]
			local group = {}
			for key, value in pairs(source) do
				local valueType = typeof(value)
				if valueType == "boolean" or valueType == "number" or valueType == "string" then
					group[key] = value
				elseif valueType == "Color3" then
					group[key] = {
						__color = true,
						r = math.floor(value.R * 255 + 0.5),
						g = math.floor(value.G * 255 + 0.5),
						b = math.floor(value.B * 255 + 0.5),
					}
				end
			end
			data[groupName] = group
		end
		return data
	end

	local function applySettings(data)
		if type(data.Binds) == "table" then
			table.clear(KEYBINDS)
			for name, key in pairs(data.Binds) do
				if type(name) == "string" and type(key) == "string" then
					KEYBINDS[name] = key
				end
			end
		end
		for groupName, group in pairs(data) do
			local source = groupName ~= "Binds" and Window.ConfigTables[groupName]
			if source and type(group) == "table" then
				for key, value in pairs(group) do
					local current = source[key]
					if current ~= nil then
						if typeof(current) == "Color3" and type(value) == "table" and value.__color then
							source[key] = Color3.fromRGB(value.r, value.g, value.b)
						elseif typeof(current) == typeof(value) then
							source[key] = value
						end
					elseif source == Window.Flags then
						-- флаг ещё не создан (элемент добавится позже): сохраняем значение заранее
						if type(value) == "table" and value.__color then
							source[key] = Color3.fromRGB(value.r, value.g, value.b)
						else
							source[key] = value
						end
					end
				end
			end
		end
		Window:Refresh()
	end

	function Window:Serialize()
		return serializeSettings()
	end

	function Window:Apply(data)
		applySettings(data)
	end

	local function defaultBackend(fileName)
		local memory = { configs = {}, autoload = nil }
		local hasFs = type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
		return {
			Load = function()
				if hasFs then
					local ok, data = pcall(function()
						if isfile(fileName) then
							return HttpService:JSONDecode(readfile(fileName))
						end
						return nil
					end)
					if ok and type(data) == "table" then
						memory = { configs = type(data.configs) == "table" and data.configs or {}, autoload = data.autoload }
					end
				end
				return memory
			end,
			Save = function(configs, autoload)
				memory = { configs = configs, autoload = autoload }
				if hasFs then
					pcall(function()
						writefile(fileName, HttpService:JSONEncode({ configs = configs, autoload = autoload }))
					end)
				end
			end,
		}
	end

	function Window:AddConfigSection(cfg)
		if configSectionAdded then
			return sections["Config"] and sections["Config"].object
		end
		configSectionAdded = true
		cfg = cfg or {}
		local MAX_CONFIGS = cfg.MaxConfigs or 20
		local MAX_NAME_LENGTH = cfg.MaxNameLength or 30
		local backend = cfg.Backend or defaultBackend(cfg.FileName or "OpusUI_configs.json")

		local savedConfigs = {}
		local autoloadName = nil

		local function persistConfigs()
			task.spawn(function()
				local ok, err = pcall(backend.Save, savedConfigs, autoloadName)
				if not ok then
					warn("OPUS UI: failed to save configs", err)
				end
			end)
		end

		local configData = createSection("Config", cfg.Group or "Settings", "bars")
		local configObject = wrapSection(configData)
		local configCards = {}
		local rebuildConfigCards

		local createCard = new("Frame", {
			LayoutOrder = 0,
			BackgroundColor3 = C.card,
			BackgroundTransparency = 0.15,
			BorderSizePixel = 0,
			Parent = configData.grid,
		})
		round(createCard, 8)
		outline(createCard, C.accent, 0.55)

		local createTitle = new("TextLabel", {
			Position = UDim2.fromOffset(12, 6),
			Size = UDim2.new(1, -24, 0, 20),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.text,
			Text = S.NewConfig,
			Parent = createCard,
		})

		local nameBox = new("TextBox", {
			Position = UDim2.fromOffset(12, 32),
			Size = UDim2.new(1, -58, 0, 24),
			BackgroundColor3 = C.inner,
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = C.text,
			TextXAlignment = Enum.TextXAlignment.Left,
			PlaceholderText = S.ConfigName,
			PlaceholderColor3 = C.sub,
			ClearTextOnFocus = false,
			Text = "",
			Parent = createCard,
		})
		round(nameBox, 6)
		new("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = nameBox })

		local saveButton = new("TextButton", {
			Position = UDim2.new(1, -40, 0, 32),
			Size = UDim2.fromOffset(28, 24),
			BackgroundColor3 = C.accent,
			BorderSizePixel = 0,
			AutoButtonColor = true,
			Font = Enum.Font.GothamBold,
			TextSize = 16,
			TextColor3 = C.text,
			Text = "+",
			Parent = createCard,
		})
		round(saveButton, 6)

		local flashId = 0
		local function flashTitle(text, color)
			flashId += 1
			local myId = flashId
			createTitle.Text = text
			createTitle.TextColor3 = color or C.text
			task.delay(1.6, function()
				if flashId == myId then
					createTitle.Text = S.NewConfig
					createTitle.TextColor3 = C.text
				end
			end)
		end

		local function countConfigs()
			local count = 0
			for _ in pairs(savedConfigs) do
				count += 1
			end
			return count
		end

		local function saveNewConfig()
			local name = nameBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
			if name == "" then
				flashTitle(S.ConfigEnterName, C.accent)
				return
			end
			if #name > MAX_NAME_LENGTH then
				flashTitle(S.ConfigNameTooLong, C.accent)
				return
			end
			if not savedConfigs[name] and countConfigs() >= MAX_CONFIGS then
				flashTitle(string.format(S.ConfigMax, MAX_CONFIGS), C.accent)
				return
			end

			local existed = savedConfigs[name] ~= nil
			savedConfigs[name] = { data = serializeSettings(), savedAt = os.time() }
			nameBox.Text = ""
			persistConfigs()
			rebuildConfigCards()
			playToggleSound(true)
			flashTitle(existed and S.ConfigOverwritten or S.ConfigSaved)
		end

		saveButton.MouseButton1Click:Connect(saveNewConfig)
		nameBox.FocusLost:Connect(function(enterPressed)
			if enterPressed then
				saveNewConfig()
			end
		end)

		local function removeConfigCardsFromSearch()
			for index = #configData.cards, 1, -1 do
				if configData.cards[index].isConfig then
					table.remove(configData.cards, index)
				end
			end
		end

		rebuildConfigCards = function()
			if currentModule and currentModule.isConfig then
				showGrid()
			end

			for _, entry in ipairs(configCards) do
				entry.card:Destroy()
				entry.page:Destroy()
			end
			table.clear(configCards)
			removeConfigCardsFromSearch()

			local names = {}
			for name in pairs(savedConfigs) do
				table.insert(names, name)
			end
			table.sort(names, function(a, b)
				return a:lower() < b:lower()
			end)

			for index, name in ipairs(names) do
				local entry = savedConfigs[name]
				local isAutoload = autoloadName == name
				local descText = string.format(S.ConfigSavedAt, os.date("%d.%m %H:%M", entry.savedAt or os.time()))
					.. (isAutoload and ("  ·  " .. S.ConfigAuto) or "")

				local card = new("TextButton", {
					LayoutOrder = index,
					BackgroundColor3 = C.card,
					BackgroundTransparency = 0.15,
					BorderSizePixel = 0,
					AutoButtonColor = false,
					Text = "",
					Parent = configData.grid,
				})
				round(card, 8)

				local icon = new("Frame", {
					Position = UDim2.fromOffset(12, 13),
					Size = UDim2.fromOffset(12, 12),
					BackgroundColor3 = isAutoload and C.accent or C.accentDim,
					BorderSizePixel = 0,
					Parent = card,
				})
				round(icon, 3)

				new("TextLabel", {
					Position = UDim2.fromOffset(32, 8),
					Size = UDim2.new(1, -62, 0, 22),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					TextColor3 = C.text,
					Text = name,
					Parent = card,
				})

				local desc = new("TextLabel", {
					Position = UDim2.fromOffset(12, 32),
					Size = UDim2.new(1, -24, 0, 28),
					BackgroundTransparency = 1,
					Font = Enum.Font.Gotham,
					TextSize = 11,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextColor3 = C.sub,
					Text = descText,
					Parent = card,
				})

				local dots = new("TextButton", {
					Position = UDim2.new(1, -28, 0, 6),
					Size = UDim2.fromOffset(22, 22),
					BackgroundTransparency = 1,
					Text = "",
					ZIndex = 2,
					Parent = card,
				})
				drawIcon(dots, "kebab", 14)(C.sub)

				local function loadThis()
					applySettings(entry.data)
					playToggleSound(true)
					desc.Text = S.ConfigLoaded
					desc.TextColor3 = C.accent
					task.delay(1.6, function()
						if desc.Parent then
							desc.Text = descText
							desc.TextColor3 = C.sub
						end
					end)
				end

				local page = makeSettingsPage(name .. "_Config")
				local pageObject = makePageObject(page)
				pageObject:AddButton({ Name = S.ConfigLoad, Text = S.ConfigLoadBtn, Callback = loadThis })
				pageObject:AddButton({
					Name = S.ConfigOverwriteRow,
					Text = S.ConfigOverwriteBtn,
					Callback = function()
						savedConfigs[name] = { data = serializeSettings(), savedAt = os.time() }
						persistConfigs()
						playToggleSound(true)
						rebuildConfigCards()
					end,
				})
				pageObject:AddButton({
					Name = S.ConfigAutoRow,
					Text = isAutoload and S.ConfigAutoOff or S.ConfigAutoOn,
					Callback = function()
						autoloadName = (autoloadName == name) and nil or name
						persistConfigs()
						playToggleSound(autoloadName == name)
						rebuildConfigCards()
					end,
				})
				pageObject:AddButton({
					Name = S.ConfigDeleteRow,
					Text = S.ConfigDeleteBtn,
					Callback = function()
						savedConfigs[name] = nil
						if autoloadName == name then
							autoloadName = nil
						end
						persistConfigs()
						playToggleSound(false)
						rebuildConfigCards()
					end,
				})

				local module = { name = name, page = page, isConfig = true }
				dots.MouseButton1Click:Connect(function()
					openSettings(module)
				end)

				card.MouseButton1Click:Connect(loadThis)
				card.MouseEnter:Connect(function()
					card.BackgroundColor3 = C.cardHover
				end)
				card.MouseLeave:Connect(function()
					card.BackgroundColor3 = C.card
				end)

				table.insert(configCards, { card = card, page = page })
				table.insert(configData.cards, { frame = card, name = name, desc = descText, isConfig = true })
			end
		end

		-- загрузка сохранённых конфигов и автозагрузка
		task.spawn(function()
			local ok, result = pcall(backend.Load)
			if ok and type(result) == "table" then
				savedConfigs = type(result.configs) == "table" and result.configs or {}
				autoloadName = result.autoload
			elseif not ok then
				warn("OPUS UI: failed to load configs", result)
			end

			rebuildConfigCards()

			if autoloadName and savedConfigs[autoloadName] then
				applySettings(savedConfigs[autoloadName].data)
			end
		end)

		return configObject
	end

	--------------------------------------------------------------------
	-- Анимация появления и скрытия меню
	--------------------------------------------------------------------
	local windowScale = new("UIScale", { Scale = 1, Parent = frame })

	-- Мягкое свечение цветом темы вокруг окна. Отдельный слой под меню.
	do
		local glowGui = new("ScreenGui", {
			Name = (opts.GuiName or "OpusUI") .. "_Glow",
			ResetOnSpawn = false,
			DisplayOrder = screenGui.DisplayOrder - 1,
			Enabled = false,
			Parent = playerGui,
		})
		table.insert(destroyers, function()
			glowGui:Destroy()
		end)
		local layers = {}
		for _, spec in ipairs({ { 2, 2, 0.55 }, { 8, 4, 0.82 }, { 18, 6, 0.92 } }) do
			local glow = new("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Parent = glowGui,
			})
			round(glow, 12 + spec[1] / 2)
			local stroke = new("UIStroke", { Thickness = spec[2], Parent = glow })
			table.insert(layers, {
				frame = glow,
				stroke = stroke,
				scale = new("UIScale", { Parent = glow }),
				grow = spec[1],
				transparency = spec[3],
			})
		end

		-- светлая «стеклянная» кромка по краю окна
		local glassEdge = new("UIStroke", {
			Color = Color3.fromRGB(255, 255, 255),
			Transparency = 0.82,
			Thickness = 1,
			Parent = windowBackground,
		})
		glassEdge:SetAttribute("KeepColor", true)

		-- применяет прозрачность стекла ко всем слоям меню
		local appliedGlass = nil
		local function applyGlass()
			local level = MENU_STYLE.Glass and math.clamp(MENU_STYLE.GlassLevel, 0, 0.8) or 0
			-- в ключ входит и число карточек: новые карточки конфигов тоже станут стеклянными
			local cardCount = 0
			for _, section in pairs(sections) do
				cardCount += #section.cards
			end
			local clear = MENU_STYLE.Theme == "Прозрачный"
			local key = tostring(MENU_STYLE.Glass) .. level .. "/" .. cardCount .. "/" .. tostring(clear)
			if key == appliedGlass then
				return
			end
			appliedGlass = key

			windowBackground.BackgroundTransparency = clear and 0.9 or (0.04 + level * 0.75)
			sidebar.BackgroundTransparency = clear and 0.92 or math.min(0.45 + level * 0.5, 0.92)
			glassEdge.Transparency = clear and 0.25 or (MENU_STYLE.Glass and 0.7 or 0.9)

			local cardTransparency = clear and 0.86 or (0.05 + level * 0.55)
			for _, section in pairs(sections) do
				for _, entry in ipairs(section.cards) do
					if entry.frame.Parent then
						entry.frame.BackgroundTransparency = cardTransparency
					end
				end
			end
			for _, row in ipairs(glassRows) do
				row.BackgroundTransparency = clear and 0.88 or (0.2 + level * 0.45)
			end
			if updateMenuBlur then
				updateMenuBlur()
			end
		end
		table.insert(uiRefreshers, function()
			appliedGlass = nil -- после смены темы или загрузки конфига применить заново
			applyGlass()
		end)

		bind(RunService.RenderStepped, function()
			glowGui.Enabled = screenGui.Enabled and frame.Visible
			if not glowGui.Enabled then
				return
			end
			applyGlass() -- срабатывает только если настройку стекла меняли
			for _, layer in ipairs(layers) do
				layer.frame.Position = frame.Position
				layer.frame.Size = frame.Size + UDim2.fromOffset(layer.grow, layer.grow)
				layer.scale.Scale = windowScale.Scale
				layer.stroke.Color = C.accent
				layer.stroke.Transparency = layer.transparency
			end
		end)
		applyGlass()
	end

	-- Размытие мира за открытым меню
	local menuBlur = new("BlurEffect", { Name = (opts.GuiName or "OpusUI") .. "_Blur", Size = 0, Parent = Lighting })
	table.insert(destroyers, function()
		menuBlur:Destroy()
	end)

	updateMenuBlur = function()
		local glass = MENU_STYLE.Glass and math.clamp(MENU_STYLE.GlassLevel, 0, 0.8) or 0
		local target = (menuIsOpen and MENU_STYLE.Blur) and (10 + glass * 18) or 0
		TweenService:Create(menuBlur, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { Size = target }):Play()
	end

	-- Масштаб, при котором окно целиком помещается на экран с отступами
	local SCREEN_MARGIN = 24
	local PREVIEW_WIDTH = 210
	local PREVIEW_GAP = 12

	local function previewExtra()
		return MENU_STYLE.Preview and (PREVIEW_WIDTH + PREVIEW_GAP) or 0
	end

	local function getFitScale()
		local available = screenGui.AbsoluteSize
		if available.X < 1 or available.Y < 1 then
			return 1
		end
		local scale = math.min(
			(available.X - SCREEN_MARGIN * 2) / (WINDOW_SIZE.X + previewExtra()),
			(available.Y - SCREEN_MARGIN * 2) / WINDOW_SIZE.Y
		)
		return math.clamp(scale, 0.45, 1)
	end

	-- Не даёт окну (вместе с панелью предпросмотра) уехать за край экрана
	local function clampWindow()
		local available = screenGui.AbsoluteSize
		local scale = getFitScale()
		local half = WINDOW_SIZE * scale / 2
		local extra = previewExtra() * scale
		local minX = math.min(0, -(available.X / 2 - half.X - SCREEN_MARGIN))
		local maxX = available.X / 2 - half.X - extra - SCREEN_MARGIN
		if maxX < minX then
			maxX = minX
		end
		local maxY = math.max(0, available.Y / 2 - half.Y - SCREEN_MARGIN)
		frame.Position = UDim2.new(
			0.5, math.clamp(frame.Position.X.Offset, minX, maxX),
			0.5, math.clamp(frame.Position.Y.Offset, -maxY, maxY)
		)
	end

	bind(screenGui:GetPropertyChangedSignal("AbsoluteSize"), function()
		if menuOpen then
			windowScale.Scale = getFitScale()
			clampWindow()
		end
	end)

	bind(UserInputService.InputEnded, function(input)
		if menuOpen and (input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch) then
			clampWindow()
		end
	end)

	--------------------------------------------------------------------
	-- Предпросмотр: окно справа от меню с вашим аватаром.
	--   opts.PreviewEffectFolders = { "Aura_Local", ... }  папки в workspace с деталями эффектов
	--   opts.PreviewSubtitle = function() return "Hat · Aura" end  подпись под заголовком
	--------------------------------------------------------------------
	do
		local KEEP_CHILDREN = {
			SpecialMesh = true, BlockMesh = true, CylinderMesh = true,
			Decal = true, Texture = true, SurfaceAppearance = true,
		}

		local panel = new("Frame", {
			Name = "Preview",
			AnchorPoint = Vector2.new(0, 0.5),
			Size = UDim2.fromOffset(PREVIEW_WIDTH, WINDOW_SIZE.Y),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = windowBackground.BackgroundTransparency,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Visible = false,
			Parent = screenGui,
		})
		round(panel, 12)
		outline(panel, C.line, 0.35)
		new("UIGradient", { Rotation = 55, Color = ColorSequence.new(C.bgTop, C.bgBottom), Parent = panel })
		local panelEdge = new("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Parent = panel,
		})
		round(panelEdge, 12)
		local panelEdgeStroke = new("UIStroke", {
			Color = Color3.fromRGB(255, 255, 255),
			Transparency = 0.82,
			Thickness = 1,
			Parent = panelEdge,
		})
		panelEdgeStroke:SetAttribute("KeepColor", true)
		local panelSheen = new("Frame", {
			Size = UDim2.new(1, 0, 0.45, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.94,
			BorderSizePixel = 0,
			Parent = panel,
		})
		round(panelSheen, 12)
		new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(0, 1), Parent = panelSheen })
		local panelScale = new("UIScale", { Parent = panel })

		new("TextLabel", {
			Position = UDim2.fromOffset(14, 10),
			Size = UDim2.new(1, -28, 0, 20),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.text,
			Text = S.PreviewName,
			Parent = panel,
		})
		local subtitle = new("TextLabel", {
			Position = UDim2.fromOffset(14, 30),
			Size = UDim2.new(1, -28, 0, 16),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.sub,
			Text = "",
			Parent = panel,
		})

		local viewport = new("ViewportFrame", {
			Position = UDim2.fromOffset(8, 54),
			Size = UDim2.new(1, -16, 1, -88),
			BackgroundColor3 = C.inner,
			BackgroundTransparency = 0.4,
			BorderSizePixel = 0,
			Ambient = Color3.fromRGB(150, 150, 160),
			LightColor = Color3.fromRGB(235, 235, 240),
			LightDirection = Vector3.new(-0.4, -1, -0.6),
			Parent = panel,
		})
		round(viewport, 10)
		local viewCamera = Instance.new("Camera")
		viewCamera.FieldOfView = 38
		viewCamera.Parent = viewport
		viewport.CurrentCamera = viewCamera

		new("TextLabel", {
			Position = UDim2.new(0, 14, 1, -30),
			Size = UDim2.new(1, -28, 0, 20),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextColor3 = C.sub,
			Text = S.PreviewHint,
			Parent = panel,
		})

		-- поворот персонажа: только вручную, мышью (или пальцем)
		local yaw = math.rad(200)
		local previewDragging = false
		local lastX = 0
		viewport.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				previewDragging = true
				lastX = input.Position.X
			end
		end)
		bind(UserInputService.InputChanged, function(input)
			if previewDragging and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then
				yaw -= (input.Position.X - lastX) * 0.012
				lastX = input.Position.X
			end
		end)
		bind(UserInputService.InputEnded, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				previewDragging = false
			end
		end)

		local characterCopy = nil
		local characterPairs = {} -- { source, copy }
		local characterSignature = nil
		local copiedCharacter = nil
		local effectCopies = {}   -- [деталь эффекта] = её копия
		local lastScan = 0

		local function stripCopy(copy)
			for _, child in ipairs(copy:GetChildren()) do
				if not KEEP_CHILDREN[child.ClassName] then
					child:Destroy()
				end
			end
			copy.Anchored = true
			copy.CastShadow = false
		end

		local function rebuildCharacter(character)
			if characterCopy then
				characterCopy:Destroy()
				characterCopy = nil
			end
			table.clear(characterPairs)
			if not character then
				return
			end

			-- метки совпадают у детали и её копии, поэтому копия точно находит свой оригинал
			local sourcesById = {}
			local nextId = 0
			for _, object in ipairs(character:GetDescendants()) do
				if object:IsA("BasePart") then
					nextId += 1
					object:SetAttribute("OpusPreviewId", nextId)
					sourcesById[nextId] = object
				end
			end

			-- Clone копирует только объекты с Archivable = true: временно включаем его у всего персонажа
			local restore = {}
			local function allowCopy(object)
				if not object.Archivable then
					object.Archivable = true
					table.insert(restore, object)
				end
			end
			allowCopy(character)
			for _, object in ipairs(character:GetDescendants()) do
				allowCopy(object)
			end
			local ok, copy = pcall(character.Clone, character)
			for _, object in ipairs(restore) do
				if object.Parent or object == character then
					object.Archivable = false
				end
			end
			if not ok or not copy then
				return
			end

			-- скрипты, звуки, эффекты и физика в копии не нужны
			for _, object in ipairs(copy:GetDescendants()) do
				if object:IsA("BaseScript") or object:IsA("Sound") or object:IsA("ParticleEmitter")
					or object:IsA("Trail") or object:IsA("Beam") or object:IsA("Highlight") or object:IsA("Light")
					or object:IsA("JointInstance") or object:IsA("WeldConstraint") or object:IsA("Motor6D") then
					object:Destroy()
				elseif object:IsA("BasePart") then
					object.Anchored = true
					object.CastShadow = false
					local source = sourcesById[object:GetAttribute("OpusPreviewId")]
					if source then
						table.insert(characterPairs, { source = source, copy = object })
					else
						object:Destroy()
					end
				end
			end
			local humanoid = copy:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			end
			copy.Parent = viewport
			characterCopy = copy
		end

		local function partCount(character)
			local count = 0
			for _, object in ipairs(character:GetDescendants()) do
				if object:IsA("BasePart") then
					count += 1
				end
			end
			return count
		end

		local function scan(character, root)
			-- персонаж поменялся (респавн, шляпа, одежда) — пересобираем копию
			local signature = character and partCount(character) or nil
			if character ~= copiedCharacter or signature ~= characterSignature then
				copiedCharacter = character
				characterSignature = signature
				rebuildCharacter(character)
			end

			-- детали эффектов рядом с персонажем
			local keep = {}
			for _, folderName in ipairs(Window.PreviewConfig.EffectFolders or {}) do
				for _, folder in ipairs(workspace:GetChildren()) do
					if folder.Name ~= folderName or not root then
						continue
					end
					for _, part in ipairs(folder:GetDescendants()) do
						if part:IsA("BasePart") and (part.Position - root.Position).Magnitude < 12 then
							keep[part] = true
							if not effectCopies[part] then
								local ok, copy = pcall(part.Clone, part)
								if ok and copy then
									stripCopy(copy)
									copy.Parent = viewport
									effectCopies[part] = copy
								end
							end
						end
					end
				end
			end
			for part, copy in pairs(effectCopies) do
				if not keep[part] or not part.Parent then
					copy:Destroy()
					effectCopies[part] = nil
				end
			end
		end

		local function subtitleText()
			local fn = Window.PreviewConfig.Subtitle
			if type(fn) ~= "function" then
				return ""
			end
			local ok, text = pcall(fn)
			if ok and type(text) == "string" and text ~= "" then
				return text
			end
			return S.PreviewNone
		end

		bind(RunService.RenderStepped, function()
			local visible = MENU_STYLE.Preview and screenGui.Enabled and frame.Visible
			panel.Visible = visible and true or false
			if not visible then
				return
			end

			-- прозрачность — как у окна меню (стекло, тема «Прозрачный»)
			local glass = windowBackground.BackgroundTransparency
			panel.BackgroundTransparency = glass
			viewport.BackgroundTransparency = math.clamp(glass + 0.35, 0.4, 0.97)
			panelEdgeStroke.Transparency = glass > 0.5 and 0.4 or 0.82

			-- панель «прилипает» к правому краю окна и масштабируется вместе с ним
			local scale = windowScale.Scale
			panelScale.Scale = scale
			panel.Position = frame.Position + UDim2.fromOffset((WINDOW_SIZE.X / 2 + PREVIEW_GAP) * scale, 0)

			local character = localPlayer.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			local now = os.clock()
			if now - lastScan > 0.5 then
				lastScan = now
				scan(character, root)
				subtitle.Text = subtitleText()
			end
			if not root then
				return
			end

			local look = root.CFrame.LookVector
			local reference = CFrame.new(root.Position) * CFrame.Angles(0, math.atan2(-look.X, -look.Z), 0)
			for _, pair in ipairs(characterPairs) do
				local source, copy = pair.source, pair.copy
				if source.Parent then
					copy.CFrame = reference:ToObjectSpace(source.CFrame)
					copy.Transparency = source.Transparency
					copy.Color = source.Color
					copy.Material = source.Material
					copy.Reflectance = source.Reflectance
				end
			end
			for part, copy in pairs(effectCopies) do
				if part.Parent then
					copy.CFrame = reference:ToObjectSpace(part.CFrame)
					copy.Transparency = part.Transparency
					copy.Color = part.Color
					copy.Material = part.Material
					copy.Reflectance = part.Reflectance
				end
			end

			viewCamera.CFrame = CFrame.Angles(0, yaw, 0) * CFrame.new(0, 0.6, 11.5)
			viewCamera.CFrame = CFrame.lookAt(viewCamera.CFrame.Position, Vector3.new(0, 0.4, 0))
		end)
	end

	--------------------------------------------------------------------
	-- Анимация «разбитого стекла»: закрытие — трещины и осколки с настоящим содержимым
	-- меню разлетаются; открытие — то же самое задом наперёд.
	--------------------------------------------------------------------
	local openMenu, closeMenu
	local clearShardsOnDestroy
	do
		local SHARD_COLUMNS = 2
		local SHARD_ROWS = 1
		local CRACK_TIME = 0.12
		local CRACK_GAP = 5
		local FLY_TIME = 0.6
		local MAX_DELAY = 0.07
		local SHARD_GRAVITY = 900
		local OPEN_TIME = 0.6
		local TOTAL_TIME = MAX_DELAY + CRACK_TIME + FLY_TIME

		local shardLayer = new("Frame", {
			Name = "ShardLayer",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(WINDOW_SIZE.X, WINDOW_SIZE.Y),
			BackgroundTransparency = 1,
			Visible = false,
			ZIndex = 5,
			Parent = screenGui,
		})
		local shardScale = new("UIScale", { Parent = shardLayer })

		local shardPieces = {}
		local shardConnection = nil

		local function clearShards()
			if shardConnection then
				shardConnection:Disconnect()
				shardConnection = nil
			end
			for _, piece in ipairs(shardPieces) do
				piece.shard:Destroy()
			end
			table.clear(shardPieces)
			shardLayer.Visible = false
		end
		clearShardsOnDestroy = clearShards

		local function makeSnapshot()
			local snapshot = Instance.new("Frame")
			snapshot.Size = UDim2.fromOffset(WINDOW_SIZE.X, WINDOW_SIZE.Y)
			snapshot.BackgroundTransparency = 1
			snapshot.BorderSizePixel = 0

			for _, child in ipairs(frame:GetChildren()) do
				if not child:IsA("UIScale") then
					local ok, copy = pcall(function()
						return child:Clone()
					end)
					if ok and copy then
						copy.Parent = snapshot
					end
				end
			end

			for _, descendant in ipairs(snapshot:GetDescendants()) do
				if descendant.Parent and descendant:IsA("GuiObject") and not descendant.Visible then
					descendant:Destroy()
				end
			end
			return snapshot
		end

		local function randomCuts(count, jitter)
			local cuts = { 0 }
			for i = 1, count - 1 do
				table.insert(cuts, (i + (math.random() - 0.5) * jitter) / count)
			end
			table.insert(cuts, 1)
			return cuts
		end

		local function createShards()
			clearShards()
			shardLayer.Position = frame.Position
			shardScale.Scale = windowScale.Scale
			shardLayer.Visible = true

			local snapshot = makeSnapshot()
			local center = WINDOW_SIZE / 2
			local yCuts = randomCuts(SHARD_ROWS, 0.35)
			local total = SHARD_COLUMNS * SHARD_ROWS

			for row = 1, SHARD_ROWS do
				local xCuts = randomCuts(SHARD_COLUMNS, 0.25)
				for column = 1, SHARD_COLUMNS do
					local x0 = math.floor(xCuts[column] * WINDOW_SIZE.X)
					local x1 = math.floor(xCuts[column + 1] * WINDOW_SIZE.X)
					local y0 = math.floor(yCuts[row] * WINDOW_SIZE.Y)
					local y1 = math.floor(yCuts[row + 1] * WINDOW_SIZE.Y)
					local pieceSize = Vector2.new(x1 - x0, y1 - y0)
					local home = Vector2.new(x0, y0) + pieceSize / 2

					local shard = Instance.new("CanvasGroup")
					shard.AnchorPoint = Vector2.new(0.5, 0.5)
					shard.Position = UDim2.fromOffset(home.X, home.Y)
					shard.Size = UDim2.fromOffset(pieceSize.X, pieceSize.Y)
					shard.BackgroundTransparency = 1
					shard.Parent = shardLayer

					local copy = (#shardPieces == total - 1) and snapshot or snapshot:Clone()
					copy.Position = UDim2.fromOffset(-x0, -y0)
					copy.Parent = shard

					local edge = Instance.new("UIStroke")
					edge.Color = C.accent
					edge.Thickness = 1.5
					edge.Transparency = 1
					edge.Parent = shard

					local depth = Instance.new("UIScale")
					depth.Parent = shard

					local direction = home - center
					direction = direction.Magnitude > 1 and direction.Unit or Vector2.new(0, -1)

					table.insert(shardPieces, {
						shard = shard,
						edge = edge,
						depth = depth,
						home = home,
						direction = direction,
						crackRotation = (math.random() - 0.5) * 5,
						velocity = direction * (260 + math.random() * 80)
							+ Vector2.new(0, -40 - math.random() * 60),
						spin = (direction.X < 0 and -1 or 1) * (25 + math.random() * 20),
						farScale = 0.3 + math.random() * 0.25,
						delay = math.random() * MAX_DELAY,
					})
				end
			end
		end

		local function applyShard(piece, tau)
			local t = math.max(0, tau - piece.delay)
			local crack = math.clamp(t / CRACK_TIME, 0, 1)
			local fly = math.max(0, t - CRACK_TIME)
			local flyProgress = math.clamp(fly / FLY_TIME, 0, 1)

			local offset = piece.direction * CRACK_GAP * crack
				+ piece.velocity * fly
				+ Vector2.new(0, 0.5 * SHARD_GRAVITY * fly * fly)
			local position = piece.home + offset

			piece.shard.Position = UDim2.fromOffset(position.X, position.Y)
			piece.shard.Rotation = piece.crackRotation * crack + piece.spin * fly
			piece.depth.Scale = 1 - (1 - piece.farScale) * flyProgress
			piece.edge.Transparency = 1 - 0.75 * crack
			piece.shard.GroupTransparency = math.clamp((flyProgress - 0.35) / 0.65, 0, 1)
		end

		function openMenu()
			animationId += 1
			local myId = animationId
			menuOpen = true
			menuIsOpen = true
			updateMenuBlur()

			windowScale.Scale = getFitScale()
			clampWindow()
			frame.Visible = false
			screenGui.Enabled = true

			createShards()
			for _, piece in ipairs(shardPieces) do
				applyShard(piece, TOTAL_TIME) -- осколки стартуют разлетевшимися
			end

			local started = os.clock()
			shardConnection = RunService.RenderStepped:Connect(function()
				local u = math.clamp((os.clock() - started) / OPEN_TIME, 0, 1)
				local tau = TOTAL_TIME * (1 - u) ^ 2
				for _, piece in ipairs(shardPieces) do
					applyShard(piece, tau)
				end
				if u >= 1 then
					clearShards()
					if animationId == myId then
						frame.Visible = true
					end
				end
			end)
		end

		function closeMenu()
			animationId += 1
			local myId = animationId
			menuOpen = false
			menuIsOpen = false
			updateMenuBlur()

			createShards()
			frame.Visible = false

			local started = os.clock()
			shardConnection = RunService.RenderStepped:Connect(function()
				local tau = os.clock() - started
				for _, piece in ipairs(shardPieces) do
					applyShard(piece, tau)
				end
				if tau >= TOTAL_TIME then
					clearShards()
					if animationId == myId then
						screenGui.Enabled = false
						frame.Visible = true
					end
				end
			end)
		end
	end

	--------------------------------------------------------------------
	-- Заставка: размытие, логотип, название
	--------------------------------------------------------------------
	local introGui = nil

	local function tween(object, time, props, style, direction)
		local t = TweenService:Create(
			object,
			TweenInfo.new(time, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out),
			props
		)
		t:Play()
		return t
	end

	local function playIntro()
		introPlaying = true

		introGui = new("ScreenGui", {
			Name = (opts.GuiName or "OpusUI") .. "_Intro",
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			IgnoreGuiInset = true,
			ResetOnSpawn = false,
			DisplayOrder = 200,
			Parent = playerGui,
		})
		local gui = introGui

		local holder = new("CanvasGroup", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(320, 100),
			BackgroundTransparency = 1,
			Parent = gui,
		})

		local LOGO_SHIFT = -86
		local ROW_Y = 50

		local logoFrame = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0, ROW_Y),
			Size = UDim2.fromOffset(64, 64),
			BackgroundColor3 = LOGO_BG,
			BorderSizePixel = 0,
			Rotation = -90,
			ZIndex = 2,
			Parent = holder,
		})
		round(logoFrame, 14)
		new("UIStroke", { Color = C.accent, Transparency = 0.4, Thickness = 2, Parent = logoFrame })
		local logoScale = new("UIScale", { Scale = 0, Parent = logoFrame })
		drawLogoMark(logoFrame, 64)

		local subHex = string.format("#%02X%02X%02X",
			math.floor(C.sub.R * 255 + 0.5), math.floor(C.sub.G * 255 + 0.5), math.floor(C.sub.B * 255 + 0.5))
		local TITLE_X = LOGO_SHIFT + 32 + 16
		local title = new("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0.5, TITLE_X - 26, 0, ROW_Y),
			Size = UDim2.fromOffset(200, 40),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBlack,
			TextSize = 30,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.text,
			TextTransparency = 1,
			RichText = true,
			Text = (opts.Name or "OPUS") .. ' <font face="Gotham" weight="Regular" size="24" color="' .. subHex
				.. '">' .. (opts.Subtitle or "client") .. "</font>",
			Parent = holder,
		})
		local titleReveal = new("UIGradient", {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.45, 0),
				NumberSequenceKeypoint.new(0.55, 1),
				NumberSequenceKeypoint.new(1, 1),
			}),
			Offset = Vector2.new(-1, 0),
			Parent = title,
		})

		-- 1. логотип выпрыгивает с поворотом
		tween(logoScale, 0.55, { Scale = 1 }, Enum.EasingStyle.Back)
		tween(logoFrame, 0.55, { Rotation = 0 }, Enum.EasingStyle.Back)
		task.wait(0.45)

		-- 2. логотип отъезжает влево, справа проявляется название
		task.wait(0.15)
		tween(logoFrame, 0.6, { Position = UDim2.new(0.5, LOGO_SHIFT, 0, ROW_Y) }, Enum.EasingStyle.Quint)
		title.TextTransparency = 0
		tween(title, 0.6, { Position = UDim2.new(0.5, TITLE_X, 0, ROW_Y) }, Enum.EasingStyle.Quint)
		tween(titleReveal, 0.65, { Offset = Vector2.new(1, 0) }, Enum.EasingStyle.Quad)
		task.wait(0.7)

		-- 3. короткая пауза со звуком
		playToggleSound(true)
		task.wait(0.55)

		-- 4. название уезжает обратно за логотип, логотип возвращается в центр
		local retract = TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		TweenService:Create(title, retract, { Position = UDim2.new(0.5, LOGO_SHIFT - 20, 0, ROW_Y) }):Play()
		TweenService:Create(titleReveal, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Offset = Vector2.new(-1, 0),
		}):Play()
		tween(logoFrame, 0.5, { Position = UDim2.new(0.5, 0, 0, ROW_Y) }, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
		task.wait(0.5)

		-- 5. логотип сжимается и исчезает — и только после этого появляется меню
		local shrink = tween(logoScale, 0.3, { Scale = 0 }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		tween(logoFrame, 0.3, { Rotation = 90 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		shrink.Completed:Wait()

		if gui.Parent then
			gui:Destroy()
		end
		introGui = nil
		introPlaying = false
		if not destroyed then
			openMenu()
		end
	end

	--------------------------------------------------------------------
	-- Открыть / закрыть
	--------------------------------------------------------------------
	local function toggleMenu()
		if introPlaying or destroyed then
			return
		end
		if menuOpen then
			closeMenu()
		else
			openMenu()
		end
	end

	bind(UserInputService.InputBegan, function(input, gameProcessed)
		if gameProcessed or introPlaying then
			return
		end
		if input.KeyCode == Window.MenuKey then
			toggleMenu()
		end
	end)

	bind(watermarkClicked.Event, toggleMenu)

	function Window:Open()
		if not menuOpen and not introPlaying and not destroyed then
			openMenu()
		end
	end

	function Window:Close()
		if menuOpen and not introPlaying and not destroyed then
			closeMenu()
		end
	end

	function Window:Toggle()
		toggleMenu()
	end

	function Window:IsOpen()
		return menuOpen
	end

	function Window:SetMenuKey(keyCode)
		Window.MenuKey = keyCode
	end

	function Window:SetSize(size)
		-- размер окна задаётся только при создании (CreateWindow{Size = ...})
		warn("OPUS UI: Window size is fixed at CreateWindow time")
	end

	--------------------------------------------------------------------
	-- ArrayList: список включённых функций сбоку экрана
	--   local list = Window:CreateArrayList{ Exclude = { "Sync" } }
	--   list:AddModule(section)
	--------------------------------------------------------------------
	local arrayListCreated = nil

	function Window:CreateArrayList(listOpts)
		if arrayListCreated then
			return arrayListCreated
		end
		listOpts = listOpts or {}
		local exclude = {}
		for _, name in ipairs(listOpts.Exclude or {}) do
			exclude[name] = true
		end

		local ARRAYLIST = {
			Enabled = listOpts.Enabled ~= false,
			Position = listOpts.Position or "Справа сверху",
			Suffix = true,
			Background = true,
			Rainbow = false,
		}
		local ARRAYLIST_POSITIONS = { "Справа сверху", "Слева сверху", "Справа снизу", "Слева снизу" }
		registerConfig("ArrayList", ARRAYLIST)

		local ROW_HEIGHT = 20
		local FONT = Enum.Font.GothamBold
		local TEXT_SIZE = 13

		local listGui = new("ScreenGui", {
			Name = (opts.GuiName or "OpusUI") .. "_ArrayList",
			ResetOnSpawn = false,
			DisplayOrder = 80,
			Parent = playerGui,
		})
		table.insert(destroyers, function()
			listGui:Destroy()
		end)
		local holder = new("Frame", {
			Size = UDim2.fromOffset(260, 600),
			BackgroundTransparency = 1,
			Parent = listGui,
		})

		local rows = {}
		local lastCheck = 0

		local function toHex(color)
			return string.format("#%02X%02X%02X",
				math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
		end

		local function rowText(name, def)
			local suffix = nil
			if ARRAYLIST.Suffix then
				local mode = def.source.Style or def.source.Preset
				if type(mode) == "string" and def.key == "Enabled" then
					suffix = mode
				end
			end
			local plain = suffix and (name .. "  " .. suffix) or name
			local rich = suffix and (name .. '  <font color="' .. toHex(C.sub) .. '">' .. suffix .. "</font>") or name
			return plain, rich
		end

		local function layout()
			local right = ARRAYLIST.Position:find("Справа") ~= nil
			local bottom = ARRAYLIST.Position:find("снизу") ~= nil
			holder.AnchorPoint = Vector2.new(right and 1 or 0, bottom and 1 or 0)
			local topOffset = 12
			local watermark = Library._watermarkSettings
			-- в левом верхнем углу обычно стоит Watermark — опускаемся под него
			if not right and not bottom and watermark and watermark.Enabled and watermark.Position == "Слева сверху" then
				topOffset = 50
			end
			holder.Position = UDim2.new(right and 1 or 0, right and -10 or 10, bottom and 1 or 0, bottom and -10 or topOffset)
			return right, bottom
		end

		local function removeRow(name)
			local row = rows[name]
			if not row or row.removing then
				return
			end
			row.removing = true
			local right = holder.AnchorPoint.X > 0.5
			local rowTween = TweenService:Create(row.frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Position = row.frame.Position + UDim2.fromOffset(right and 40 or -40, 0),
				BackgroundTransparency = 1,
			})
			TweenService:Create(row.label, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
			TweenService:Create(row.bar, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
			rowTween:Play()
			rowTween.Completed:Connect(function()
				row.frame:Destroy()
				if rows[name] == row then
					rows[name] = nil
				end
			end)
		end

		local function update()
			listGui.Enabled = ARRAYLIST.Enabled
			if not ARRAYLIST.Enabled then
				for name in pairs(rows) do
					removeRow(name)
				end
				return
			end
			local right, bottom = layout()

			-- какие функции сейчас включены (настройки самого меню не показываем)
			local active = {}
			for name, entry in pairs(moduleRegistry) do
				local def = entry.def
				if def and entry.group ~= "Settings" and def.source ~= ARRAYLIST and not exclude[name]
					and def.source[def.key] then
					local plain, rich = rowText(name, def)
					local width = TextService:GetTextSize(plain, TEXT_SIZE, FONT, Vector2.new(1000, 100)).X + 18
					table.insert(active, { name = name, rich = rich, width = width })
				end
			end
			-- длинные сверху, короткие снизу — «лесенка»
			table.sort(active, function(a, b)
				if a.width ~= b.width then
					return a.width > b.width
				end
				return a.name < b.name
			end)

			local wanted = {}
			for index, item in ipairs(active) do
				wanted[item.name] = true
				local row = rows[item.name]
				local targetY = bottom and (-(index - 1) * ROW_HEIGHT) or ((index - 1) * ROW_HEIGHT)
				local anchor = Vector2.new(right and 1 or 0, bottom and 1 or 0)
				local targetPosition = UDim2.new(right and 1 or 0, 0, bottom and 1 or 0, targetY)

				if not row or row.removing then
					if row then
						row.frame:Destroy()
					end
					local rowFrame = new("Frame", {
						AnchorPoint = anchor,
						Position = targetPosition + UDim2.fromOffset(right and 40 or -40, 0),
						Size = UDim2.fromOffset(item.width, ROW_HEIGHT),
						BackgroundColor3 = C.bgBottom,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Parent = holder,
					})
					local bar = new("Frame", {
						AnchorPoint = Vector2.new(right and 1 or 0, 0),
						Position = UDim2.new(right and 1 or 0, 0, 0, 0),
						Size = UDim2.new(0, 2, 1, 0),
						BackgroundColor3 = C.accent,
						BorderSizePixel = 0,
						Parent = rowFrame,
					})
					local label = new("TextLabel", {
						Position = UDim2.fromOffset(right and 6 or 10, 0),
						Size = UDim2.new(1, -16, 1, 0),
						BackgroundTransparency = 1,
						Font = FONT,
						TextSize = TEXT_SIZE,
						RichText = true,
						TextXAlignment = right and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left,
						TextColor3 = C.text,
						TextStrokeTransparency = 0.6,
						TextTransparency = 1,
						Text = item.rich,
						Parent = rowFrame,
					})
					row = { frame = rowFrame, bar = bar, label = label }
					rows[item.name] = row

					TweenService:Create(rowFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						Position = targetPosition,
						BackgroundTransparency = ARRAYLIST.Background and 0.3 or 1,
					}):Play()
					TweenService:Create(label, TweenInfo.new(0.25), { TextTransparency = 0 }):Play()
				else
					row.frame.AnchorPoint = anchor
					row.label.Text = item.rich
					row.label.TextXAlignment = right and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
					row.label.Position = UDim2.fromOffset(right and 6 or 10, 0)
					row.bar.AnchorPoint = Vector2.new(right and 1 or 0, 0)
					row.bar.Position = UDim2.new(right and 1 or 0, 0, 0, 0)
					row.frame.BackgroundTransparency = ARRAYLIST.Background and 0.3 or 1
					if row.frame.Position ~= targetPosition then
						TweenService:Create(row.frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
							Position = targetPosition,
						}):Play()
					end
					row.frame.Size = UDim2.fromOffset(item.width, ROW_HEIGHT)
				end
				row.index = index
			end

			for name in pairs(rows) do
				if not wanted[name] then
					removeRow(name)
				end
			end
		end

		bind(RunService.RenderStepped, function()
			local now = os.clock()
			if now - lastCheck > 0.15 then
				lastCheck = now
				update()
			end

			-- цвета каждый кадр (для радужной волны)
			for _, row in pairs(rows) do
				if not row.removing then
					local color = ARRAYLIST.Rainbow
						and Color3.fromHSV((now * 0.25 + (row.index or 0) * 0.06) % 1, 0.7, 1)
						or C.accent
					row.bar.BackgroundColor3 = color
					row.frame.BackgroundColor3 = C.bgBottom
					row.label.TextColor3 = ARRAYLIST.Rainbow and color or C.text
				end
			end
		end)

		local object = { Settings = ARRAYLIST, Gui = listGui, Positions = ARRAYLIST_POSITIONS }

		function object:AddModule(section)
			return section:AddModule({
				Name = S.ArrayName,
				Description = S.ArrayDesc,
				Icon = "bars",
				Source = ARRAYLIST,
				Key = "Enabled",
				Settings = function(page)
					page:AddChoice({ Name = S.Position, Source = ARRAYLIST, Key = "Position", Options = ARRAYLIST_POSITIONS })
					page:AddToggle({ Name = S.ArraySuffix, Source = ARRAYLIST, Key = "Suffix" })
					page:AddToggle({ Name = S.ArrayBackground, Source = ARRAYLIST, Key = "Background" })
					page:AddToggle({ Name = S.ArrayRainbow, Source = ARRAYLIST, Key = "Rainbow" })
				end,
			})
		end

		arrayListCreated = object
		return object
	end

	--------------------------------------------------------------------
	-- Init / Destroy
	--------------------------------------------------------------------
	function Window:Init()
		if initialized or destroyed then
			return Window
		end
		initialized = true

		if opts.Preview ~= nil then
			MENU_STYLE.Preview = opts.Preview and true or false
		end

		-- стандартные разделы настроек (после пользовательских)
		if opts.DefaultSections ~= false then
			Window:AddConfigSection(opts.Config)
			Window:AddThemesSection()
		end

		-- первый раздел по порядку
		local first, firstOrder = nil, math.huge
		for name, section in pairs(sections) do
			if section.order < firstOrder then
				first, firstOrder = name, section.order
			end
		end
		if first then
			selectSection(opts.StartSection and sections[opts.StartSection] and opts.StartSection or first)
		end

		local desired = opts.Theme or MENU_STYLE.Theme
		if not THEMES[desired] then
			desired = "Бордовый"
		end
		applyTheme(desired)
		Window:Refresh()

		screenGui.Enabled = false
		if opts.Intro ~= false then
			task.spawn(playIntro)
		elseif opts.AutoOpen ~= false then
			openMenu()
		end
		return Window
	end

	function Window:Destroy()
		if destroyed then
			return
		end
		destroyed = true
		animationId += 1
		menuOpen = false
		menuIsOpen = false
		for _, connection in ipairs(connections) do
			pcall(function()
				connection:Disconnect()
			end)
		end
		table.clear(connections)
		if clearShardsOnDestroy then
			pcall(clearShardsOnDestroy)
		end
		if introGui then
			pcall(function()
				introGui:Destroy()
			end)
			introGui = nil
		end
		for _, destroyer in ipairs(destroyers) do
			pcall(destroyer)
		end
		table.clear(destroyers)
		if Library.Window == Window then
			Library.Window = nil
		end
	end

	Library.Window = Window
	return Window
end

return Library
