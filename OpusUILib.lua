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
	Locked = "заблокировано",
	DropdownNone = "нет",
	Copy = "Копировать",
	Copied = "Скопировано",
	KeyNone = "None",
	KeyPick = "...",
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
	elseif kind == "check" then
		fill(-s * 0.2, s * 0.1, s * 0.32, thin, full, 45)
		fill(s * 0.1, 0, s * 0.62, thin, full, -50)
	elseif kind == "copy" then
		local back = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, s * 0.12, 0.5, -s * 0.12),
			Size = UDim2.fromOffset(s * 0.55, s * 0.62),
			BackgroundTransparency = 1,
			Parent = holder,
		})
		table.insert(strokes, new("UIStroke", { Thickness = math.max(1, thin - 1), Parent = back }))
		local front = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, -s * 0.1, 0.5, s * 0.1),
			Size = UDim2.fromOffset(s * 0.55, s * 0.62),
			BackgroundTransparency = 1,
			Parent = holder,
		})
		table.insert(strokes, new("UIStroke", { Thickness = math.max(1, thin - 1), Parent = front }))
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

local function drawDefaultLogo(square, size)
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
			dot:SetAttribute("OpusLogo", true)
			dotStroke:SetAttribute("KeepColor", true)
		end
	end

	return mark
end

-- Свой логотип: Library:SetLogo("rbxassetid://123456") — заменяет знак в шапке меню, в Watermark
-- (кнопка открытия/закрытия меню) и в заставке. Library:SetLogo(nil) — вернуть стандартный.
local logoImage = nil
local logoSlots = {} -- { square, size }

local function drawLogoMark(square, size)
	table.insert(logoSlots, { square = square, size = size })
	if logoImage then
		local image = new("ImageLabel", {
			Name = "LogoMark",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(math.floor(size * 0.72), math.floor(size * 0.72)),
			BackgroundTransparency = 1,
			Image = logoImage,
			ScaleType = Enum.ScaleType.Fit,
			Parent = square,
		})
		image:SetAttribute("KeepColor", true)
		return image
	end
	return drawDefaultLogo(square, size)
end

function Library:SetLogo(image)
	if type(image) == "number" then
		image = "rbxassetid://" .. image
	end
	logoImage = (type(image) == "string" and image ~= "") and image or nil
	for index = #logoSlots, 1, -1 do
		local slot = logoSlots[index]
		if slot.square.Parent then
			for _, child in ipairs(slot.square:GetChildren()) do
				if child.Name == "LogoMark" or child:GetAttribute("OpusLogo") then
					child:Destroy()
				end
			end
			if logoImage then
				local size = slot.size
				local imageLabel = new("ImageLabel", {
					Name = "LogoMark",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromOffset(math.floor(size * 0.72), math.floor(size * 0.72)),
					BackgroundTransparency = 1,
					Image = logoImage,
					ScaleType = Enum.ScaleType.Fit,
					Parent = slot.square,
				})
				imageLabel:SetAttribute("KeepColor", true)
			else
				drawDefaultLogo(slot.square, slot.size)
			end
		else
			table.remove(logoSlots, index)
		end
	end
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
	if opts.Logo ~= nil then
		Library:SetLogo(opts.Logo)
	end
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
--   opts.Logo ("rbxassetid://..." — свой логотип вместо стандартного),
--   opts.DefaultSections (true: создаёт разделы Config и Themes в группе Settings)
--------------------------------------------------------------------
function Library:CreateWindow(opts)
	opts = opts or {}
	if opts.Logo ~= nil then
		Library:SetLogo(opts.Logo)
	end
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
			Name = "Title",
			Position = UDim2.fromOffset(12, 0),
			Size = UDim2.new(1, -140, 0, 38),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextColor3 = C.text,
			Text = labelText,
			Parent = row,
		})
		return row
	end

	local function toggleSetting(page, def)
		local source, key = resolveSource(def)
		local row = settingRow(page, def.Name, 38)

		local checkbox = def.Type == "Checkbox"
		local pill = new("Frame", {
			Position = checkbox and UDim2.new(1, -34, 0.5, -10) or UDim2.new(1, -50, 0.5, -9),
			Size = checkbox and UDim2.fromOffset(20, 20) or UDim2.fromOffset(36, 18),
			BackgroundColor3 = C.off,
			BorderSizePixel = 0,
			Parent = row,
		})
		round(pill, checkbox and 5 or 9)
		local knob, checkMark = nil, nil
		if checkbox then
			checkMark = new("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Visible = false,
				Parent = pill,
			})
			drawIcon(checkMark, "check", 14)(C.text)
		else
			knob = new("Frame", {
				Size = UDim2.fromOffset(14, 14),
				BackgroundColor3 = C.text,
				BorderSizePixel = 0,
				Parent = pill,
			})
			round(knob, 7)
		end
		local button = new("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = "",
			Parent = row,
		})

		local function refresh()
			local on = source[key]
			pill.BackgroundColor3 = on and C.accent or C.off
			if checkbox then
				checkMark.Visible = on and true or false
			else
				knob.Position = on and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
			end
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
			ClearTextOnFocus = def.ClearTextOnFocus == true,
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

	-- Стили кнопок: Primary / Secondary / Tertiary / White / Danger (как Variant в WindUI)
	local function variantStyle(variant, color)
		if color then
			return color, C.text, 1
		end
		if variant == "Secondary" then
			return C.inner, C.text, 0.5
		elseif variant == "Tertiary" then
			return C.card, C.sub, 0.55
		elseif variant == "White" then
			return Color3.fromRGB(245, 245, 248), Color3.fromRGB(20, 20, 24), 1
		elseif variant == "Danger" then
			return Color3.fromRGB(214, 64, 72), Color3.fromRGB(255, 255, 255), 1
		end
		return C.accent, C.text, 1
	end

	local function actionSetting(page, def)
		local center = def.Justify == "Center" or def.Full == true
		local bg, fg, strokeTransparency = variantStyle(def.Variant, def.Color)
		local row = settingRow(page, def.Name, 38)

		if center then
			-- кнопка на всю ширину строки, текст по центру
			local title = row:FindFirstChild("Title")
			if title then
				title:Destroy()
			end
			local button = new("TextButton", {
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = bg,
				BorderSizePixel = 0,
				AutoButtonColor = true,
				Font = Enum.Font.GothamBold,
				TextSize = 13,
				TextColor3 = fg,
				Text = "",
				Parent = row,
			})
			round(button, 8)
			if strokeTransparency < 1 then
				outline(button, C.line, strokeTransparency)
			end
			local label = new("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Font = Enum.Font.GothamBold,
				TextSize = 13,
				TextColor3 = fg,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Text = def.Text or def.Name,
				Parent = button,
			})
			if def.Icon then
				label.Size = UDim2.new(1, -52, 1, 0)
				label.Position = UDim2.fromOffset(26, 0)
				local holder = new("Frame", {
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, 12, 0.5, 0),
					Size = UDim2.fromOffset(16, 16),
					BackgroundTransparency = 1,
					Parent = button,
				})
				drawIcon(holder, def.Icon, 12)(fg)
			end
			button.MouseButton1Click:Connect(function()
				fire(def.Callback)
			end)
			return { Row = row, Button = button }
		end

		local button = new("TextButton", {
			Position = UDim2.new(1, -122, 0.5, -12),
			Size = UDim2.fromOffset(110, 24),
			BackgroundColor3 = bg,
			BorderSizePixel = 0,
			AutoButtonColor = true,
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextColor3 = fg,
			Text = def.Text or def.Name,
			Parent = row,
		})
		round(button, 6)
		if strokeTransparency < 1 then
			outline(button, C.line, strokeTransparency)
		end
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

		if def.IsTextbox == false then
			box.Visible = false
		end

		local trackLeft, trackRight = 12, 12
		local function iconAsset(icon)
			if type(icon) == "number" then
				return "rbxassetid://" .. icon
			end
			return type(icon) == "string" and icon or nil
		end
		if def.Icons then
			local fromAsset, toAsset = iconAsset(def.Icons.From), iconAsset(def.Icons.To)
			if fromAsset then
				trackLeft = 34
				new("ImageLabel", {
					Position = UDim2.fromOffset(12, 36),
					Size = UDim2.fromOffset(16, 16),
					BackgroundTransparency = 1,
					Image = fromAsset,
					Parent = row,
				})
			end
			if toAsset then
				trackRight = 34
				new("ImageLabel", {
					Position = UDim2.new(1, -28, 0, 36),
					Size = UDim2.fromOffset(16, 16),
					BackgroundTransparency = 1,
					Image = toAsset,
					Parent = row,
				})
			end
		end

		local track = new("TextButton", {
			Position = UDim2.new(0, trackLeft, 0, 40),
			Size = UDim2.new(1, -(trackLeft + trackRight), 0, 6),
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
		local tooltip = nil
		if def.IsTooltip then
			tooltip = new("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0.5, 0, 0, -6),
				Size = UDim2.fromOffset(0, 18),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundColor3 = C.accent,
				BorderSizePixel = 0,
				Font = Enum.Font.GothamBold,
				TextSize = 11,
				TextColor3 = C.text,
				Text = "",
				Visible = false,
				ZIndex = 5,
				Parent = knob,
			})
			round(tooltip, 5)
			new("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), Parent = tooltip })
		end

		local function refresh()
			local value = math.clamp(source[key], minValue, maxValue)
			local alpha = range > 0 and (value - minValue) / range or 0
			fill.Size = UDim2.fromScale(alpha, 1)
			knob.Position = UDim2.fromScale(alpha, 0.5)
			knobStroke.Color = C.accent
			if tooltip then
				tooltip.Text = format(source[key])
			end
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
			if tooltip then
				tooltip.Visible = true
			end
		end)
		track.MouseLeave:Connect(function()
			TweenService:Create(knobScale, TweenInfo.new(0.1), { Scale = 1 }):Play()
			if tooltip then
				tooltip.Visible = false
			end
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

	--------------------------------------------------------------------
	-- Расширенный набор элементов (по аналогии с WindUI), в стиле этого меню.
	-- Доступны на странице настроек (page:...), на модуле (module:...), внутри Section/Group/VStack.
	--   Toggle (Type = "Toggle" | "Checkbox"), Slider (Value = {Min, Max, Default}, Step, IsTextbox, IsTooltip, Icons),
	--   Button (Variant, Color, Icon, Justify = "Center"), Input (Type = "Input" | "Textarea"),
	--   Dropdown (Values, Value, Multi, AllowNone, SearchBarEnabled, MenuWidth), Keybind, Colorpicker (Transparency),
	--   ProgressBar, Paragraph (Buttons), Code, Divider, Space, Section, Image, Group / HStack / VStack, Viewport
	-- Названия полей WindUI поддерживаются: Title, Desc, Value, Callback, Locked, LockedTitle.
	-- Методы почти у каждого элемента: Get / Set / Lock / Unlock / SetTitle / SetDesc / Destroy.
	--------------------------------------------------------------------
	local GuiService = game:GetService("GuiService")
	local elementListening = false -- идёт назначение клавиши в элементе Keybind
	local makePageObject
	local closePopup
	local ELEMENT_DEFS

	-- Позиция указателя в тех же координатах, что и AbsolutePosition
	local function pointerPosition(input)
		local position = Vector2.new(input.Position.X, input.Position.Y)
		if not screenGui.IgnoreGuiInset then
			position += GuiService:GetGuiInset()
		end
		return position
	end

	local function normalizeDef(def, rawValue)
		local d = {}
		for k, v in pairs(def or {}) do
			d[k] = v
		end
		d.Name = d.Name or d.Title or "Element"
		d.Desc = d.Desc or d.Description
		if not rawValue and d.Default == nil and d.Value ~= nil then
			d.Default = d.Value
		end
		return d
	end

	local function hexOf(color)
		return string.format("#%02X%02X%02X",
			math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
	end

	-- Иконка: имя встроенной (eye, ring, diamond, ...) либо rbxassetid:// / число
	local function placeIcon(parent, icon, size, color)
		if icon == nil or icon == false then
			return nil
		end
		local asset = nil
		if type(icon) == "number" then
			asset = "rbxassetid://" .. icon
		elseif type(icon) == "string" and (icon:find("rbxasset") or icon:find("http")) then
			asset = icon
		end
		if asset then
			local image = new("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(size, size),
				BackgroundTransparency = 1,
				Image = asset,
				Parent = parent,
			})
			return function(c)
				image.ImageColor3 = c
			end
		end
		local setColor = drawIcon(parent, icon, size)
		if color then
			setColor(color)
		end
		return setColor
	end

	-- Карточка для составных элементов (высота подстраивается под содержимое)
	local function cardFrame(page, autoY, height)
		local row = new("Frame", {
			LayoutOrder = #page:GetChildren(),
			Size = UDim2.new(1, 0, 0, height or 0),
			AutomaticSize = autoY and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
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
		return row
	end

	-- Общие методы элемента: описание, блокировка, SetTitle/SetDesc, Destroy
	local function decorate(object, def)
		object = object or {}
		local row = object.Row or object.Frame
		if not row then
			return object
		end
		object.Frame = object.Frame or row

		local descLabel = nil
		local function ensureDesc(text)
			if descLabel then
				descLabel.Text = text
				descLabel.Visible = text ~= ""
				return
			end
			if text == "" then
				return
			end
			if row.AutomaticSize ~= Enum.AutomaticSize.None then
				return -- составные элементы сами показывают описание
			end
			local height = row.Size.Y.Offset
			local single = height <= 40
			descLabel = new("TextLabel", {
				Name = "Desc",
				Position = UDim2.fromOffset(12, single and 30 or (height - 4)),
				Size = UDim2.new(1, -24, 0, 14),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextColor3 = C.sub,
				Text = text,
				Parent = row,
			})
			row.Size = UDim2.new(row.Size.X.Scale, row.Size.X.Offset, 0, height + 16)
			if single then
				for _, child in ipairs(row:GetChildren()) do
					if child:IsA("GuiObject") and child ~= descLabel and child.Position.Y.Scale == 0.5
						and child.AnchorPoint.Y == 0 then
						child.Position = child.Position - UDim2.fromOffset(0, 8)
					end
				end
			end
		end

		local overlay, overlayLabel = nil, nil
		local function setLocked(on)
			if on and not overlay then
				overlay = new("TextButton", {
					Size = UDim2.fromScale(1, 1),
					BackgroundColor3 = C.panel,
					BackgroundTransparency = 0.35,
					BorderSizePixel = 0,
					AutoButtonColor = false,
					Text = "",
					ZIndex = 20,
					Parent = row,
				})
				round(overlay, 8)
				overlayLabel = new("TextLabel", {
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					TextSize = 12,
					TextColor3 = C.sub,
					Text = def.LockedTitle or S.Locked,
					ZIndex = 21,
					Parent = overlay,
				})
			end
			if overlay then
				overlay.Visible = on
				overlayLabel.Text = def.LockedTitle or S.Locked
			end
			object.IsLocked = on
			def.Locked = on
		end

		object.Lock = object.Lock or function()
			setLocked(true)
		end
		object.Unlock = object.Unlock or function()
			setLocked(false)
		end
		object.SetTitle = object.SetTitle or function(_, text)
			def.Name = text
			local label = row:FindFirstChild("Title", true)
			if label then
				label.Text = text
			end
		end
		object.SetDesc = object.SetDesc or function(_, text)
			ensureDesc(text or "")
		end
		object.Destroy = object.Destroy or function()
			if object.OnDestroy then
				object.OnDestroy()
			end
			row:Destroy()
		end

		ensureDesc(def.Desc or "")
		if def.Locked then
			setLocked(true)
		end
		return object
	end

	--------------------------------------------------------------------
	-- Всплывающее окно (список Dropdown, палитра Colorpicker)
	--------------------------------------------------------------------
	local activePopup = nil

	closePopup = function()
		if activePopup then
			local popup = activePopup
			activePopup = nil
			if popup.follow then
				popup.follow:Disconnect()
			end
			if popup.backdrop then
				popup.backdrop:Destroy()
			end
			if popup.frame then
				popup.frame:Destroy()
			end
			if popup.onClose then
				popup.onClose()
			end
		end
	end
	table.insert(destroyers, closePopup)

	local function openPopup(anchor, width, height, onClose)
		closePopup()

		-- прозрачная подложка ловит клик вне окошка и закрывает его
		local backdrop = new("TextButton", {
			Name = "PopupBackdrop",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			Text = "",
			ZIndex = 29,
			Parent = screenGui,
		})
		local popupFrame = new("Frame", {
			Name = "Popup",
			BackgroundColor3 = C.panel,
			BackgroundTransparency = 0.02,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(width, height),
			ZIndex = 30,
			Parent = screenGui,
		})
		round(popupFrame, 8)
		outline(popupFrame, C.accent, 0.5)
		local uiScale = new("UIScale", { Parent = popupFrame })

		local popup = { frame = popupFrame, backdrop = backdrop, anchor = anchor, onClose = onClose }
		activePopup = popup
		backdrop.MouseButton1Click:Connect(closePopup)

		local function place()
			local s = math.max(frame.AbsoluteSize.X / WINDOW_SIZE.X, 0.1)
			uiScale.Scale = s
			local anchorPosition, anchorSize = anchor.AbsolutePosition, anchor.AbsoluteSize
			local d = anchorPosition - frame.AbsolutePosition
			local framePosition = frame.Position
			local below = anchorPosition.Y + anchorSize.Y + (4 + height) * s <= screenGui.AbsoluteSize.Y + 36
			local x = framePosition.X.Offset - WINDOW_SIZE.X * s / 2 + d.X + anchorSize.X - width * s
			local y = framePosition.Y.Offset - WINDOW_SIZE.Y * s / 2 + d.Y
			if below then
				y += anchorSize.Y + 4 * s
			else
				y -= (height + 4) * s
			end
			popupFrame.Position = UDim2.new(framePosition.X.Scale, x, framePosition.Y.Scale, y)
		end
		place()

		popup.follow = RunService.RenderStepped:Connect(function()
			if not popupFrame.Parent or not screenGui.Enabled or not frame.Visible then
				closePopup()
				return
			end
			local scroller = anchor:FindFirstAncestorWhichIsA("ScrollingFrame")
			if scroller then
				local top, bottom = scroller.AbsolutePosition.Y, scroller.AbsolutePosition.Y + scroller.AbsoluteSize.Y
				local anchorY = anchor.AbsolutePosition.Y
				if not scroller.Visible or anchorY < top - 4 or anchorY + anchor.AbsoluteSize.Y > bottom + 4 then
					closePopup()
					return
				end
			end
			place()
		end)
		return popupFrame
	end

	-- Перетаскивание на палитре (нужны обе координаты указателя)
	local activeDrag = nil
	bind(UserInputService.InputChanged, function(input)
		if activeDrag and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			activeDrag(pointerPosition(input))
		end
	end)
	bind(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			activeDrag = nil
		end
	end)

	--------------------------------------------------------------------
	-- Dropdown (один вариант или несколько)
	--   page:AddDropdown{ Title, Values = {"A", {Title="B", Desc="...", Icon="eye", Locked=true}},
	--                     Value = "A" | {"A","B"} | 1, Multi, AllowNone, SearchBarEnabled, MenuWidth, Callback }
	--------------------------------------------------------------------
	local function dropdownSetting(page, def)
		local multi = def.Multi == true
		local values = def.Values or def.Options or {}

		local function titleOf(item)
			if type(item) == "table" then
				return tostring(item.Title or item.Name or "")
			end
			return tostring(item)
		end

		local initial = def.Default
		if multi then
			local list = {}
			if type(initial) == "table" then
				for _, v in ipairs(initial) do
					table.insert(list, titleOf(v))
				end
			elseif type(initial) == "string" then
				table.insert(list, initial)
			end
			def.Default = list
		else
			if type(initial) == "number" and values[initial] ~= nil then
				initial = titleOf(values[initial])
			elseif type(initial) == "table" then
				initial = titleOf(initial)
			end
			if initial == nil and not def.AllowNone and values[1] ~= nil then
				initial = titleOf(values[1])
			end
			def.Default = initial
		end

		local source, key = resolveSource(def)
		if multi and type(source[key]) ~= "table" then
			source[key] = {}
		end

		local function displayText()
			local v = source[key]
			if multi then
				if type(v) ~= "table" or #v == 0 then
					return S.DropdownNone
				end
				return table.concat(v, ", ")
			end
			if v == nil or v == "" then
				return S.DropdownNone
			end
			return tostring(v)
		end

		local width = def.Width or 150
		local row = settingRow(page, def.Name, 38)
		local titleLabel = row:FindFirstChild("Title")
		if titleLabel then
			titleLabel.Size = UDim2.new(1, -(width + 28), 0, 38)
		end

		local button = new("TextButton", {
			Position = UDim2.new(1, -(width + 12), 0.5, -13),
			Size = UDim2.fromOffset(width, 26),
			BackgroundColor3 = C.inner,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Text = "",
			Parent = row,
		})
		round(button, 6)
		local buttonStroke = outline(button, C.line, 0.6)
		local valueLabel = new("TextLabel", {
			Position = UDim2.fromOffset(8, 0),
			Size = UDim2.new(1, -28, 1, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextColor3 = C.text,
			Text = displayText(),
			Parent = button,
		})
		local arrow = new("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -8, 0.5, 0),
			Size = UDim2.fromOffset(12, 12),
			BackgroundTransparency = 1,
			Parent = button,
		})
		drawIcon(arrow, "chevron", 10)(C.sub)

		local lockedValues = {}
		local menuState = nil -- { update = fn }

		local function getValue()
			if multi then
				local copy = {}
				for _, v in ipairs(source[key] or {}) do
					table.insert(copy, v)
				end
				return copy
			end
			return source[key]
		end

		local function orderList(list)
			local index = {}
			for i, item in ipairs(values) do
				index[titleOf(item)] = i
			end
			table.sort(list, function(a, b)
				return (index[a] or 1e9) < (index[b] or 1e9)
			end)
			return list
		end

		local function isSelected(title)
			local v = source[key]
			if multi then
				return type(v) == "table" and table.find(v, title) ~= nil
			end
			return v == title
		end

		local function refresh()
			valueLabel.Text = displayText()
			buttonStroke.Color = C.line
			if menuState then
				menuState.update()
			end
		end

		local function choose(title)
			if multi then
				local list = getValue()
				local index = table.find(list, title)
				if index then
					if not def.AllowNone and #list <= 1 then
						return
					end
					table.remove(list, index)
				else
					table.insert(list, title)
				end
				source[key] = orderList(list)
			else
				if source[key] == title then
					if not def.AllowNone then
						return
					end
					source[key] = nil
				else
					source[key] = title
				end
			end
			refresh()
			playToggleSound(true)
			fire(def.Callback, getValue())
			if not multi then
				closePopup()
			end
		end

		local function openMenu()
			if def.Locked then
				return
			end
			local count = #values
			local searchHeight = def.SearchBarEnabled and 32 or 0
			local menuWidth = def.MenuWidth or math.max(width, 150)
			local rowsHeight = 0
			for _, item in ipairs(values) do
				rowsHeight += (type(item) == "table" and item.Desc) and 44 or 30
			end
			local listHeight = math.min(math.max(rowsHeight, 30), 176)
			local height = listHeight + 8 + searchHeight

			local popup = openPopup(button, menuWidth, height, function()
				menuState = nil
				arrow.Rotation = 0
			end)
			arrow.Rotation = 180

			local searchBox = nil
			if def.SearchBarEnabled then
				searchBox = new("TextBox", {
					Position = UDim2.fromOffset(4, 4),
					Size = UDim2.new(1, -8, 0, 26),
					BackgroundColor3 = C.inner,
					BorderSizePixel = 0,
					Font = Enum.Font.Gotham,
					TextSize = 12,
					TextColor3 = C.text,
					TextXAlignment = Enum.TextXAlignment.Left,
					PlaceholderText = S.Search,
					PlaceholderColor3 = C.sub,
					ClearTextOnFocus = false,
					ZIndex = 31,
					Text = "",
					Parent = popup,
				})
				round(searchBox, 6)
				new("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = searchBox })
			end

			local list = new("ScrollingFrame", {
				Position = UDim2.fromOffset(4, 4 + searchHeight),
				Size = UDim2.new(1, -8, 0, listHeight),
				CanvasSize = UDim2.new(),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarThickness = 3,
				ScrollBarImageColor3 = C.accent,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 31,
				Parent = popup,
			})
			new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })
			new("UIPadding", { PaddingRight = UDim.new(0, 4), Parent = list })

			local items = {}
			for index, item in ipairs(values) do
				local title = titleOf(item)
				local desc = type(item) == "table" and item.Desc or nil
				local itemLocked = (type(item) == "table" and item.Locked) or lockedValues[title]
				local button2 = new("TextButton", {
					LayoutOrder = index,
					Size = UDim2.new(1, 0, 0, desc and 42 or 28),
					BackgroundColor3 = C.accentDim,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					AutoButtonColor = false,
					Text = "",
					ZIndex = 32,
					Parent = list,
				})
				round(button2, 6)

				local textX = 10
				local box = nil
				if multi then
					box = new("Frame", {
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(0, 8, 0.5, 0),
						Size = UDim2.fromOffset(14, 14),
						BackgroundColor3 = C.off,
						BorderSizePixel = 0,
						ZIndex = 33,
						Parent = button2,
					})
					round(box, 4)
					textX = 30
				end
				local iconSet = nil
				if type(item) == "table" and item.Icon then
					local holder = new("Frame", {
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(0, textX - 2, 0.5, 0),
						Size = UDim2.fromOffset(16, 16),
						BackgroundTransparency = 1,
						ZIndex = 33,
						Parent = button2,
					})
					iconSet = placeIcon(holder, item.Icon, 12, C.sub)
					textX += 20
				end
				local label = new("TextLabel", {
					Position = UDim2.fromOffset(textX, desc and 4 or 0),
					Size = UDim2.new(1, -(textX + 8), 0, desc and 18 or 28),
					BackgroundTransparency = 1,
					Font = Enum.Font.Gotham,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					TextColor3 = C.sub,
					Text = title,
					ZIndex = 33,
					Parent = button2,
				})
				if desc then
					new("TextLabel", {
						Position = UDim2.fromOffset(textX, 22),
						Size = UDim2.new(1, -(textX + 8), 0, 14),
						BackgroundTransparency = 1,
						Font = Enum.Font.Gotham,
						TextSize = 10,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextColor3 = C.sub,
						TextTransparency = 0.25,
						Text = desc,
						ZIndex = 33,
						Parent = button2,
					})
				end

				items[title] = { button = button2, label = label, box = box, iconSet = iconSet, locked = itemLocked }

				button2.MouseButton1Click:Connect(function()
					if not items[title].locked then
						choose(title)
					end
				end)
				button2.MouseEnter:Connect(function()
					if not isSelected(title) and not items[title].locked then
						button2.BackgroundTransparency = 0.75
					end
				end)
				button2.MouseLeave:Connect(function()
					if not isSelected(title) then
						button2.BackgroundTransparency = 1
					end
				end)
			end

			local function update()
				for title, entry in pairs(items) do
					local selected = isSelected(title)
					entry.button.BackgroundTransparency = selected and 0.45 or 1
					entry.label.TextColor3 = selected and C.text or C.sub
					entry.label.Font = selected and Enum.Font.GothamBold or Enum.Font.Gotham
					entry.label.TextTransparency = entry.locked and 0.6 or 0
					if entry.box then
						entry.box.BackgroundColor3 = selected and C.accent or C.off
					end
					if entry.iconSet then
						entry.iconSet(selected and C.accent or C.sub)
					end
				end
			end
			menuState = { update = update }
			update()

			if searchBox then
				searchBox:GetPropertyChangedSignal("Text"):Connect(function()
					local query = searchBox.Text:lower()
					for title, entry in pairs(items) do
						entry.button.Visible = query == "" or title:lower():find(query, 1, true) ~= nil
					end
				end)
			end
			if count == 0 then
				new("TextLabel", {
					Size = UDim2.new(1, 0, 0, 28),
					BackgroundTransparency = 1,
					Font = Enum.Font.Gotham,
					TextSize = 12,
					TextColor3 = C.sub,
					Text = S.Empty,
					ZIndex = 32,
					Parent = list,
				})
			end
		end

		button.MouseButton1Click:Connect(openMenu)
		refresh()
		table.insert(uiRefreshers, refresh)

		local object = { Row = row, Multi = multi }
		function object:Get()
			return getValue()
		end
		function object:Select(value)
			if multi then
				local list = {}
				if type(value) == "table" then
					for _, v in ipairs(value) do
						table.insert(list, titleOf(v))
					end
				elseif value ~= nil then
					table.insert(list, titleOf(value))
				end
				source[key] = orderList(list)
			else
				if type(value) == "number" and values[value] ~= nil then
					value = titleOf(values[value])
				end
				source[key] = value ~= nil and titleOf(value) or nil
			end
			refresh()
			fire(def.Callback, getValue())
		end
		object.Set = object.Select
		function object:Refresh(newValues)
			values = newValues or {}
			if multi then
				local kept = {}
				for _, v in ipairs(source[key] or {}) do
					for _, item in ipairs(values) do
						if titleOf(item) == v then
							table.insert(kept, v)
							break
						end
					end
				end
				source[key] = kept
			else
				local found = false
				for _, item in ipairs(values) do
					if titleOf(item) == source[key] then
						found = true
					end
				end
				if not found then
					source[key] = (not def.AllowNone and values[1] ~= nil) and titleOf(values[1]) or nil
				end
			end
			closePopup()
			refresh()
		end
		function object:LockValues(list)
			lockedValues = {}
			for _, title in ipairs(list or {}) do
				lockedValues[title] = true
			end
			closePopup()
		end
		function object:Open()
			openMenu()
		end
		function object:Close()
			closePopup()
		end
		object.OnDestroy = closePopup
		return object
	end

	--------------------------------------------------------------------
	-- Keybind: назначаемая клавиша; Callback срабатывает при её нажатии
	--   page:AddKeybind{ Title, Value = "F" | Enum.KeyCode.F, Callback(key), CanChange, Blacklist = {"W"} }
	--------------------------------------------------------------------
	local function keybindSetting(page, def)
		local function keyName(value)
			if typeof(value) == "EnumItem" then
				return value.Name
			end
			return type(value) == "string" and value or nil
		end
		def.Default = keyName(def.Default) or "F"
		local source, key = resolveSource(def)

		local blacklist = { Escape = true }
		for _, name in ipairs(def.Blacklist or {}) do
			blacklist[keyName(name) or ""] = true
		end

		local row = settingRow(page, def.Name, 38)
		local button = new("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.fromOffset(0, 26),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = C.inner,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextColor3 = C.text,
			Text = "",
			Parent = row,
		})
		round(button, 6)
		local stroke = outline(button, C.line, 0.6)
		new("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = button })

		local picking = false
		local function refresh()
			if picking then
				button.Text = S.KeyPick
				stroke.Color = C.accent
				stroke.Transparency = 0.2
			else
				button.Text = source[key] or S.KeyNone
				stroke.Color = C.line
				stroke.Transparency = 0.6
			end
		end

		local function stopPicking()
			picking = false
			task.defer(function()
				elementListening = false
			end)
			refresh()
		end

		button.MouseButton1Click:Connect(function()
			if def.Locked or def.CanChange == false then
				return
			end
			picking = true
			elementListening = true
			refresh()
		end)

		bind(UserInputService.InputBegan, function(input, gameProcessed)
			if picking then
				local name = nil
				if input.UserInputType == Enum.UserInputType.Keyboard then
					if input.KeyCode == Enum.KeyCode.Escape then
						stopPicking()
						return
					elseif input.KeyCode == Enum.KeyCode.Backspace then
						source[key] = nil
						stopPicking()
						return
					end
					name = input.KeyCode.Name
				elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
					name = "MouseRight"
				elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
					name = "MouseMiddle"
				elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
					stopPicking()
					return
				end
				if name and not blacklist[name] then
					source[key] = name
					stopPicking()
				end
				return
			end
			if gameProcessed or def.Locked or elementListening or source[key] == nil then
				return
			end
			local pressed = nil
			if input.UserInputType == Enum.UserInputType.Keyboard then
				pressed = input.KeyCode.Name
			elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
				pressed = "MouseRight"
			elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
				pressed = "MouseMiddle"
			end
			if pressed and pressed == source[key] then
				fire(def.Callback, pressed)
			end
		end)

		refresh()
		table.insert(uiRefreshers, refresh)

		local object = { Row = row }
		function object:Get()
			return source[key]
		end
		function object:Set(value)
			source[key] = keyName(value)
			refresh()
		end
		return object
	end

	--------------------------------------------------------------------
	-- Input в виде многострочного поля (Type = "Textarea")
	--------------------------------------------------------------------
	local function areaSetting(page, def)
		local source, key = resolveSource(def)
		if source[key] == nil then
			source[key] = ""
		end
		local maxLength = def.MaxLength or 2000
		local areaHeight = def.Height or 84
		local row = settingRow(page, def.Name, 44 + areaHeight)

		local box = new("TextBox", {
			Position = UDim2.fromOffset(12, 36),
			Size = UDim2.new(1, -24, 0, areaHeight),
			BackgroundColor3 = C.inner,
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = C.text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			MultiLine = true,
			PlaceholderText = def.Placeholder or S.Empty,
			PlaceholderColor3 = C.sub,
			ClearTextOnFocus = def.ClearTextOnFocus == true,
			Text = tostring(source[key]),
			Parent = row,
		})
		round(box, 6)
		outline(box, C.line, 0.6)
		new("UIPadding", {
			PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
			Parent = box,
		})

		box.FocusLost:Connect(function()
			source[key] = string.sub(box.Text, 1, maxLength)
			box.Text = source[key]
			fire(def.Callback, source[key])
		end)
		local function refresh()
			if not box:IsFocused() then
				box.Text = tostring(source[key])
			end
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

	--------------------------------------------------------------------
	-- Colorpicker: квадрат насыщенности/яркости, полоса оттенка, прозрачность, HEX и RGB
	--   page:AddColorpicker{ Title, Default/Value = Color3, Transparency = 0 (включает полосу прозрачности), Callback(color, alpha) }
	--------------------------------------------------------------------
	local function colorpickerSetting(page, def)
		local hasAlpha = def.Transparency ~= nil
		if typeof(def.Default) ~= "Color3" then
			def.Default = C.accent
		end
		local source, key = resolveSource(def)
		local alphaKey = tostring(key) .. "_Alpha"
		if hasAlpha and source[alphaKey] == nil then
			source[alphaKey] = def.Transparency
		end

		local row = settingRow(page, def.Name, 38)
		local swatch = new("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.fromOffset(44, 22),
			BackgroundColor3 = source[key],
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Text = "",
			Parent = row,
		})
		round(swatch, 6)
		outline(swatch, C.line, 0.4)
		swatch:SetAttribute("KeepColor", true)

		local function currentAlpha()
			return hasAlpha and (source[alphaKey] or 0) or 0
		end

		local hue, sat, val = source[key]:ToHSV()
		local syncUI = nil

		local function refresh()
			local color = source[key]
			if typeof(color) ~= "Color3" then
				return
			end
			swatch.BackgroundColor3 = color
			swatch.BackgroundTransparency = currentAlpha()
			local h, s, v = color:ToHSV()
			if v > 0 and s > 0 then
				hue = h
			end
			if v > 0 then
				sat = s
			end
			val = v
			if syncUI then
				syncUI()
			end
		end

		local function commit(silent)
			source[key] = Color3.fromHSV(hue, sat, val)
			refresh()
			if not silent then
				fire(def.Callback, source[key], currentAlpha())
			end
		end

		local function setRGB(r, g, b)
			local color = Color3.fromRGB(math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255))
			hue, sat, val = color:ToHSV()
			source[key] = color
			refresh()
			fire(def.Callback, color, currentAlpha())
		end

		local function openPicker()
			if def.Locked then
				return
			end
			local width = 196
			local barsY = 126
			local inputsY = hasAlpha and 166 or 146
			local height = inputsY + 24 + 8
			local popup = openPopup(swatch, width, height, function()
				syncUI = nil
				activeDrag = nil
			end)

			-- квадрат S/V
			local svBox = new("TextButton", {
				Position = UDim2.fromOffset(8, 8),
				Size = UDim2.fromOffset(180, 110),
				BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Text = "",
				ZIndex = 31,
				Parent = popup,
			})
			round(svBox, 6)
			svBox:SetAttribute("KeepColor", true)
			local white = new("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
				ZIndex = 32,
				Parent = svBox,
			})
			round(white, 6)
			white:SetAttribute("KeepColor", true)
			new("UIGradient", { Transparency = NumberSequence.new(0, 1), Parent = white })
			local black = new("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Color3.new(0, 0, 0),
				BorderSizePixel = 0,
				ZIndex = 33,
				Parent = svBox,
			})
			round(black, 6)
			black:SetAttribute("KeepColor", true)
			new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0), Parent = black })
			local svCursor = new("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromOffset(12, 12),
				BackgroundTransparency = 1,
				ZIndex = 35,
				Parent = svBox,
			})
			round(svCursor, 6)
			local svStroke = new("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2, Parent = svCursor })
			svStroke:SetAttribute("KeepColor", true)

			-- полоса оттенка
			local hueBar = new("TextButton", {
				Position = UDim2.fromOffset(8, barsY),
				Size = UDim2.fromOffset(180, 12),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Text = "",
				ZIndex = 31,
				Parent = popup,
			})
			round(hueBar, 6)
			hueBar:SetAttribute("KeepColor", true)
			local hueKeys = {}
			for i = 0, 6 do
				table.insert(hueKeys, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 1, 1)))
			end
			new("UIGradient", { Color = ColorSequence.new(hueKeys), Parent = hueBar })
			local hueThumb = new("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.fromOffset(6, 16),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
				ZIndex = 34,
				Parent = hueBar,
			})
			round(hueThumb, 3)
			hueThumb:SetAttribute("KeepColor", true)

			-- полоса прозрачности
			local alphaBar, alphaThumb, alphaFill = nil, nil, nil
			if hasAlpha then
				alphaBar = new("TextButton", {
					Position = UDim2.fromOffset(8, barsY + 20),
					Size = UDim2.fromOffset(180, 12),
					BackgroundColor3 = C.inner,
					BorderSizePixel = 0,
					AutoButtonColor = false,
					Text = "",
					ZIndex = 31,
					Parent = popup,
				})
				round(alphaBar, 6)
				alphaFill = new("Frame", {
					Size = UDim2.fromScale(1, 1),
					BackgroundColor3 = source[key],
					BorderSizePixel = 0,
					ZIndex = 32,
					Parent = alphaBar,
				})
				round(alphaFill, 6)
				alphaFill:SetAttribute("KeepColor", true)
				new("UIGradient", { Transparency = NumberSequence.new(1, 0), Parent = alphaFill })
				alphaThumb = new("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0, 0.5),
					Size = UDim2.fromOffset(6, 16),
					BackgroundColor3 = Color3.new(1, 1, 1),
					BorderSizePixel = 0,
					ZIndex = 34,
					Parent = alphaBar,
				})
				round(alphaThumb, 3)
				alphaThumb:SetAttribute("KeepColor", true)
			end

			-- HEX и RGB
			local function makeBox(x, w, placeholder)
				local box = new("TextBox", {
					Position = UDim2.fromOffset(x, inputsY),
					Size = UDim2.fromOffset(w, 24),
					BackgroundColor3 = C.inner,
					BorderSizePixel = 0,
					Font = Enum.Font.Gotham,
					TextSize = 11,
					TextColor3 = C.text,
					PlaceholderText = placeholder,
					PlaceholderColor3 = C.sub,
					ClearTextOnFocus = false,
					ZIndex = 31,
					Text = "",
					Parent = popup,
				})
				round(box, 5)
				outline(box, C.line, 0.6)
				return box
			end
			local hexBox = makeBox(8, 72, "HEX")
			local rBox, gBox, bBox = makeBox(84, 32, "R"), makeBox(120, 32, "G"), makeBox(156, 32, "B")

			syncUI = function()
				svBox.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
				svCursor.Position = UDim2.fromScale(sat, 1 - val)
				hueThumb.Position = UDim2.fromScale(hue, 0.5)
				if alphaBar then
					alphaFill.BackgroundColor3 = source[key]
					alphaThumb.Position = UDim2.fromScale(1 - currentAlpha(), 0.5)
				end
				local color = source[key]
				local r = math.floor(color.R * 255 + 0.5)
				local g = math.floor(color.G * 255 + 0.5)
				local b = math.floor(color.B * 255 + 0.5)
				if not hexBox:IsFocused() then
					hexBox.Text = hexOf(color):sub(2)
				end
				if not rBox:IsFocused() then
					rBox.Text = tostring(r)
				end
				if not gBox:IsFocused() then
					gBox.Text = tostring(g)
				end
				if not bBox:IsFocused() then
					bBox.Text = tostring(b)
				end
			end
			syncUI()

			local function dragFor(guiObject, apply)
				guiObject.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						local function handler(position)
							local origin, size = guiObject.AbsolutePosition, guiObject.AbsoluteSize
							apply(
								math.clamp((position.X - origin.X) / math.max(size.X, 1), 0, 1),
								math.clamp((position.Y - origin.Y) / math.max(size.Y, 1), 0, 1)
							)
						end
						activeDrag = handler
						handler(pointerPosition(input))
					end
				end)
			end
			dragFor(svBox, function(x, y)
				sat, val = x, 1 - y
				commit()
			end)
			dragFor(hueBar, function(x)
				hue = math.clamp(x, 0, 0.999)
				commit()
			end)
			if alphaBar then
				dragFor(alphaBar, function(x)
					source[alphaKey] = math.floor((1 - x) * 100 + 0.5) / 100
					refresh()
					fire(def.Callback, source[key], currentAlpha())
				end)
			end

			hexBox.FocusLost:Connect(function()
				local text = hexBox.Text:gsub("#", "")
				if #text == 6 and text:match("^%x+$") then
					setRGB(tonumber(text:sub(1, 2), 16), tonumber(text:sub(3, 4), 16), tonumber(text:sub(5, 6), 16))
				else
					syncUI()
				end
			end)
			local function rgbBox(box, index)
				box.FocusLost:Connect(function()
					local value = tonumber(box.Text)
					if value then
						local color = source[key]
						local channels = {
							math.floor(color.R * 255 + 0.5),
							math.floor(color.G * 255 + 0.5),
							math.floor(color.B * 255 + 0.5),
						}
						channels[index] = math.floor(value)
						setRGB(channels[1], channels[2], channels[3])
					else
						syncUI()
					end
				end)
			end
			rgbBox(rBox, 1)
			rgbBox(gBox, 2)
			rgbBox(bBox, 3)
		end

		swatch.MouseButton1Click:Connect(openPicker)
		refresh()
		table.insert(uiRefreshers, refresh)

		local object = { Row = row }
		function object:Get()
			return source[key], currentAlpha()
		end
		function object:Set(color, alpha)
			if typeof(color) == "Color3" then
				source[key] = color
			end
			if hasAlpha and alpha ~= nil then
				source[alphaKey] = alpha
			end
			refresh()
			fire(def.Callback, source[key], currentAlpha())
		end
		object.OnDestroy = closePopup
		return object
	end

	--------------------------------------------------------------------
	-- Paragraph: заголовок + текст + кнопки
	--   page:AddParagraph{ Title, Desc, Buttons = { { Title, Icon, Callback, Variant } } }
	--------------------------------------------------------------------
	local function paragraphSetting(page, def)
		local row = cardFrame(page, true)
		new("UIPadding", {
			PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
			Parent = row,
		})
		new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = row })

		local title = new("TextLabel", {
			Name = "Title",
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.text,
			Text = def.Name,
			Parent = row,
		})
		local desc = new("TextLabel", {
			Name = "Desc",
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextColor3 = C.sub,
			Text = def.Desc or "",
			Visible = (def.Desc or "") ~= "",
			Parent = row,
		})

		for index, buttonDef in ipairs(def.Buttons or {}) do
			local bg, fg, strokeTransparency = variantStyle(buttonDef.Variant, buttonDef.Color)
			local button = new("TextButton", {
				LayoutOrder = 10 + index,
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundColor3 = bg,
				BorderSizePixel = 0,
				AutoButtonColor = true,
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				TextColor3 = fg,
				Text = buttonDef.Title or buttonDef.Name or "Button",
				Parent = row,
			})
			round(button, 6)
			if strokeTransparency < 1 then
				outline(button, C.line, strokeTransparency)
			end
			button.MouseButton1Click:Connect(function()
				fire(buttonDef.Callback)
			end)
		end

		local object = { Row = row }
		function object:SetTitle(text)
			title.Text = text
		end
		function object:SetDesc(text)
			desc.Text = text or ""
			desc.Visible = (text or "") ~= ""
		end
		return object
	end

	--------------------------------------------------------------------
	-- Code: блок кода с подсветкой Lua и кнопкой «копировать»
	--   page:AddCode{ Title, Code, CodeSize, Height, CanCopied, OnCopy(code), Highlight }
	--------------------------------------------------------------------
	local LUA_KEYWORDS = {}
	for _, word in ipairs({ "and", "break", "do", "else", "elseif", "end", "false", "for", "function", "goto", "if",
		"in", "local", "nil", "not", "or", "repeat", "return", "then", "true", "until", "while", "continue" }) do
		LUA_KEYWORDS[word] = true
	end

	local function escapeRich(text)
		return (text:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
	end

	local function highlightLua(code)
		if #code > 6000 then
			return escapeRich(code)
		end
		local out = {}
		local function push(token, color)
			if color then
				table.insert(out, '<font color="' .. color .. '">' .. escapeRich(token) .. "</font>")
			else
				table.insert(out, escapeRich(token))
			end
		end
		local keywordColor = hexOf(C.accent)
		local i, n = 1, #code
		while i <= n do
			local ch = code:sub(i, i)
			if code:sub(i, i + 1) == "--" then
				local j = code:find("\n", i, true) or (n + 1)
				push(code:sub(i, j - 1), "#7A8394")
				i = j
			elseif ch == '"' or ch == "'" then
				local j = i + 1
				while j <= n do
					local c = code:sub(j, j)
					if c == "\\" then
						j += 2
					elseif c == ch or c == "\n" then
						break
					else
						j += 1
					end
				end
				push(code:sub(i, math.min(j, n)), "#9ECE6A")
				i = math.min(j, n) + 1
			elseif ch:match("%d") then
				local token = code:match("^%d[%w%._]*", i)
				push(token, "#FF9E64")
				i += #token
			elseif ch:match("[%a_]") then
				local token = code:match("^[%a_][%w_]*", i)
				push(token, LUA_KEYWORDS[token] and keywordColor or nil)
				i += #token
			else
				push(ch, nil)
				i += 1
			end
		end
		return table.concat(out)
	end

	local function codeSetting(page, def)
		local row = cardFrame(page, true)
		local codeText = tostring(def.Code or "")
		local canCopy = def.CanCopied ~= false

		local top = new("Frame", {
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundTransparency = 1,
			Parent = row,
		})
		local titleLabel = new("TextLabel", {
			Name = "Title",
			Position = UDim2.fromOffset(12, 0),
			Size = UDim2.new(1, -60, 1, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextColor3 = C.text,
			Text = def.Title or def.Name or "",
			Parent = top,
		})
		local copyButton = nil
		if canCopy then
			copyButton = new("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -8, 0.5, 0),
				Size = UDim2.fromOffset(24, 22),
				BackgroundColor3 = C.inner,
				BorderSizePixel = 0,
				AutoButtonColor = true,
				Text = "",
				Parent = top,
			})
			round(copyButton, 5)
			drawIcon(copyButton, "copy", 14)(C.sub)
		end

		local bodyParent = row
		local body
		if def.Height then
			body = new("ScrollingFrame", {
				Position = UDim2.fromOffset(8, 32),
				Size = UDim2.new(1, -16, 0, def.Height),
				CanvasSize = UDim2.new(),
				AutomaticCanvasSize = Enum.AutomaticSize.XY,
				ScrollBarThickness = 3,
				ScrollBarImageColor3 = C.accent,
				BackgroundColor3 = C.inner,
				BorderSizePixel = 0,
				Parent = row,
			})
			round(body, 6)
			bodyParent = body
			row.Size = UDim2.new(1, 0, 0, 32 + def.Height + 8)
			row.AutomaticSize = Enum.AutomaticSize.None
		else
			body = new("Frame", {
				Position = UDim2.fromOffset(8, 32),
				Size = UDim2.new(1, -16, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = C.inner,
				BorderSizePixel = 0,
				Parent = row,
			})
			round(body, 6)
			new("UIPadding", { PaddingBottom = UDim.new(0, 8), Parent = row })
			bodyParent = body
		end

		local textLabel = new("TextLabel", {
			Position = UDim2.fromOffset(8, 6),
			Size = UDim2.new(1, -16, 0, 0),
			AutomaticSize = def.Height and Enum.AutomaticSize.XY or Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Font = Enum.Font.Code,
			TextSize = def.CodeSize or 12,
			TextWrapped = not def.Height,
			RichText = def.Highlight ~= false,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextColor3 = C.text,
			Text = def.Highlight ~= false and highlightLua(codeText) or codeText,
			Parent = bodyParent,
		})
		if not def.Height then
			new("UIPadding", { PaddingBottom = UDim.new(0, 6), Parent = body })
		end

		local function setCode(text)
			codeText = tostring(text or "")
			textLabel.Text = def.Highlight ~= false and highlightLua(codeText) or codeText
		end

		if copyButton then
			copyButton.MouseButton1Click:Connect(function()
				local clip = toclipboard or setclipboard or (type(Clipboard) == "table" and Clipboard.set) or nil
				if clip then
					pcall(clip, codeText)
				end
				fire(def.OnCopy, codeText)
				titleLabel.Text = S.Copied
				titleLabel.TextColor3 = C.accent
				task.delay(1.4, function()
					if titleLabel.Parent then
						titleLabel.Text = def.Title or def.Name or ""
						titleLabel.TextColor3 = C.text
					end
				end)
			end)
		end

		return {
			Row = row,
			Get = function()
				return codeText
			end,
			Set = function(_, text)
				setCode(text)
			end,
			SetCode = function(_, text)
				setCode(text)
			end,
		}
	end

	--------------------------------------------------------------------
	-- Divider / Space / Image
	--------------------------------------------------------------------
	local function dividerSetting(page, _)
		local horizontal = page:GetAttribute("OpusHorizontal") == true
		local holder = new("Frame", {
			LayoutOrder = #page:GetChildren(),
			Size = horizontal and UDim2.new(0, 7, 0, 38) or UDim2.new(1, 0, 0, 9),
			BackgroundTransparency = 1,
			Parent = page,
		})
		holder:SetAttribute("OpusFixed", horizontal and 7 or nil)
		new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = horizontal and UDim2.new(0, 1, 1, -8) or UDim2.new(1, -8, 0, 1),
			BackgroundColor3 = C.line,
			BackgroundTransparency = 0.55,
			BorderSizePixel = 0,
			Parent = holder,
		})
		return { Frame = holder }
	end

	local function spaceSetting(page, def)
		local horizontal = page:GetAttribute("OpusHorizontal") == true
		local amount = 8 * (def.Columns or 1)
		local holder = new("Frame", {
			LayoutOrder = #page:GetChildren(),
			Size = horizontal and UDim2.new(0, amount, 0, 1) or UDim2.new(1, 0, 0, amount),
			BackgroundTransparency = 1,
			Parent = page,
		})
		holder:SetAttribute("OpusFixed", horizontal and amount or nil)
		return { Frame = holder }
	end

	local function imageSetting(page, def)
		local holder = new("Frame", {
			LayoutOrder = #page:GetChildren(),
			Size = UDim2.new(1, 0, 0, 120),
			BackgroundColor3 = C.card,
			BackgroundTransparency = 0.2,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Parent = page,
		})
		round(holder, def.Radius or def.UICorner or 8)
		outline(holder, C.line, 0.7)
		local asset = def.Image
		if type(asset) == "number" then
			asset = "rbxassetid://" .. asset
		end
		local image = new("ImageLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = asset or "",
			ScaleType = def.ScaleType or Enum.ScaleType.Crop,
			Parent = holder,
		})

		local ratio = 16 / 9
		if type(def.AspectRatio) == "number" then
			ratio = def.AspectRatio
		elseif type(def.AspectRatio) == "string" then
			local a, b = def.AspectRatio:match("^(%d+%.?%d*):(%d+%.?%d*)$")
			if a and tonumber(b) and tonumber(b) > 0 then
				ratio = tonumber(a) / tonumber(b)
			end
		end
		if def.Height then
			holder.Size = UDim2.new(1, 0, 0, def.Height)
		else
			holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				local width = holder.AbsoluteSize.X
				if width > 0 then
					local s = math.max(frame.AbsoluteSize.X / WINDOW_SIZE.X, 0.1)
					local target = math.floor(width / s / ratio + 0.5)
					if math.abs(holder.Size.Y.Offset - target) > 1 then
						holder.Size = UDim2.new(1, 0, 0, target)
					end
				end
			end)
		end

		return {
			Frame = holder,
			Row = nil,
			Set = function(_, newImage)
				if type(newImage) == "number" then
					newImage = "rbxassetid://" .. newImage
				end
				image.Image = newImage or ""
			end,
		}
	end

	--------------------------------------------------------------------
	-- ProgressBar
	--   page:AddProgressBar{ Title, Value = { Min, Max, Default }, DisplayMode = "Percent" | "Value" | "Fraction",
	--                        Format = function(value, min, max) / "{value}/{max}", ShowValue, Indeterminate, Animate }
	--------------------------------------------------------------------
	local function progressSetting(page, def)
		local valueConfig = type(def.Value) == "table" and def.Value or {}
		local minValue = tonumber(valueConfig.Min) or tonumber(def.Min) or 0
		local maxValue = tonumber(valueConfig.Max) or tonumber(def.Max) or 100
		if minValue > maxValue then
			minValue, maxValue = maxValue, minValue
		end
		def.Default = type(def.Value) == "number" and def.Value
			or tonumber(valueConfig.Default) or tonumber(def.Default) or minValue
		local source, key = resolveSource(def)
		local indeterminate = def.Indeterminate == true
		local showValue = def.ShowValue
		if showValue == nil then
			showValue = not indeterminate
		end

		local row = settingRow(page, def.Name, 56)
		local valueLabel = new("TextLabel", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -12, 0, 0),
			Size = UDim2.fromOffset(90, 38),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextColor3 = C.accent,
			Text = "",
			Visible = showValue,
			Parent = row,
		})
		local track = new("Frame", {
			Position = UDim2.fromOffset(12, 40),
			Size = UDim2.new(1, -24, 0, 8),
			BackgroundColor3 = C.inner,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Parent = row,
		})
		round(track, 4)
		local fill = new("Frame", {
			Size = UDim2.fromScale(0, 1),
			BackgroundColor3 = C.accent,
			BorderSizePixel = 0,
			Parent = track,
		})
		round(fill, 4)

		local function formatValue(value)
			local range = maxValue - minValue
			local alpha = range > 0 and (value - minValue) / range or 0
			if type(def.Format) == "function" then
				local ok, text = pcall(def.Format, value, minValue, maxValue)
				return ok and tostring(text) or ""
			elseif type(def.Format) == "string" then
				return (def.Format:gsub("{value}", tostring(math.floor(value * 100 + 0.5) / 100))
					:gsub("{min}", tostring(minValue)):gsub("{max}", tostring(maxValue))
					:gsub("{percent}", tostring(math.floor(alpha * 100 + 0.5))))
			end
			if def.DisplayMode == "Value" then
				return tostring(math.floor(value * 100 + 0.5) / 100)
			elseif def.DisplayMode == "Fraction" then
				return tostring(math.floor(value * 100 + 0.5) / 100) .. " / " .. tostring(maxValue)
			end
			return math.floor(alpha * 100 + 0.5) .. "%"
		end

		local shown = nil
		local function refresh()
			local value = math.clamp(tonumber(source[key]) or minValue, minValue, maxValue)
			local range = maxValue - minValue
			local alpha = range > 0 and (value - minValue) / range or 0
			valueLabel.Text = formatValue(value)
			fill.BackgroundColor3 = C.accent
			valueLabel.TextColor3 = C.accent
			if not indeterminate then
				if def.Animate ~= false and shown ~= nil then
					TweenService:Create(fill, TweenInfo.new(def.AnimationDuration or 0.25, Enum.EasingStyle.Quad), {
						Size = UDim2.fromScale(alpha, 1),
					}):Play()
				else
					fill.Size = UDim2.fromScale(alpha, 1)
				end
			end
			shown = value
		end

		local function setIndeterminate(on)
			indeterminate = on
			valueLabel.Visible = showValue and not on
			if on then
				fill.Size = UDim2.fromScale(0.3, 1)
			else
				shown = nil
				refresh()
			end
		end

		bind(RunService.RenderStepped, function()
			if indeterminate then
				local t = (os.clock() * (def.Speed or 0.8)) % 1.6
				fill.Position = UDim2.fromScale(-0.3 + t, 0)
			end
		end)

		setIndeterminate(indeterminate)
		refresh()
		table.insert(uiRefreshers, refresh)

		return {
			Row = row,
			Get = function()
				return source[key]
			end,
			Set = function(_, value)
				source[key] = math.clamp(tonumber(value) or minValue, minValue, maxValue)
				if indeterminate then
					setIndeterminate(false)
				end
				refresh()
			end,
			SetIndeterminate = function(_, on)
				setIndeterminate(on and true or false)
			end,
		}
	end

	--------------------------------------------------------------------
	-- Viewport: 3D-предмет (Model / BasePart), вращается и крутится мышью
	--   page:AddViewport{ Object = instance, Height = 160, Interactive = true, Rotate = true }
	--------------------------------------------------------------------
	local function viewportSetting(page, def)
		local height = def.Height or 160
		local holder = new("Frame", {
			LayoutOrder = #page:GetChildren(),
			Size = UDim2.new(1, 0, 0, height),
			BackgroundColor3 = C.inner,
			BackgroundTransparency = 0.2,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Parent = page,
		})
		round(holder, def.UICorner or 8)
		outline(holder, C.line, 0.7)
		local view = new("ViewportFrame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Ambient = Color3.fromRGB(150, 150, 160),
			LightColor = Color3.fromRGB(235, 235, 240),
			LightDirection = Vector3.new(-0.4, -1, -0.6),
			Parent = holder,
		})
		local camera = Instance.new("Camera")
		camera.FieldOfView = 40
		camera.Parent = view
		view.CurrentCamera = camera

		local current, center, radius = nil, nil, 5
		local yaw = math.rad(200)
		local dragging, lastX = false, 0

		local function setObject(object)
			if current then
				current:Destroy()
				current = nil
			end
			if not object then
				return
			end
			local ok, copy = pcall(function()
				return object:Clone()
			end)
			if not ok or not copy then
				return
			end
			copy.Parent = view
			current = copy
			local okBox, boxCf, boxSize = pcall(function()
				if copy:IsA("Model") then
					return copy:GetBoundingBox()
				end
				return copy.CFrame, copy.Size
			end)
			if okBox and boxCf and boxSize then
				center = boxCf.Position
				radius = math.max(boxSize.X, boxSize.Y, boxSize.Z) * 1.6 + 1
			else
				center, radius = Vector3.new(0, 0, 0), 5
			end
		end
		setObject(def.Object)

		view.InputBegan:Connect(function(input)
			if def.Interactive ~= false and (input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch) then
				dragging = true
				lastX = input.Position.X
			end
		end)
		bind(UserInputService.InputChanged, function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then
				yaw -= (input.Position.X - lastX) * 0.012
				lastX = input.Position.X
			end
		end)
		bind(UserInputService.InputEnded, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		bind(RunService.RenderStepped, function(dt)
			if not current or not center or not holder.Parent or not frame.Visible then
				return
			end
			if def.Rotate ~= false and not dragging then
				yaw += (dt or 0) * 0.6
			end
			local position = center + CFrame.Angles(0, yaw, 0):VectorToWorldSpace(Vector3.new(0, radius * 0.25, radius))
			camera.CFrame = CFrame.lookAt(position, center)
		end)

		return {
			Frame = holder,
			Set = function(_, object)
				setObject(object)
			end,
		}
	end

	--------------------------------------------------------------------
	-- Контейнеры: Section (сворачиваемая группа), Group / HStack (в ряд), VStack (в столбик)
	--------------------------------------------------------------------
	local GROUP_GAP = 6

	local function afterAdd(container)
		if container:GetAttribute("OpusHorizontal") ~= true then
			return
		end
		local flexible, fixedTotal, count = {}, 0, 0
		for _, child in ipairs(container:GetChildren()) do
			if child:IsA("GuiObject") then
				count += 1
				local fixed = child:GetAttribute("OpusFixed")
				if fixed then
					fixedTotal += fixed
				else
					table.insert(flexible, child)
				end
			end
		end
		local n = math.max(#flexible, 1)
		local reserved = GROUP_GAP * math.max(count - 1, 0) + fixedTotal
		for _, child in ipairs(flexible) do
			child.Size = UDim2.new(1 / n, -reserved / n, 0, child.Size.Y.Offset)
		end
	end

	local function stackSetting(page, def, horizontal)
		local container = new("Frame", {
			LayoutOrder = #page:GetChildren(),
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Parent = page,
		})
		container:SetAttribute("OpusHorizontal", horizontal)
		new("UIListLayout", {
			FillDirection = horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
			Padding = UDim.new(0, GROUP_GAP),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = container,
		})
		local object = makePageObject(container)
		object.Row = nil
		return object
	end

	local function sectionSetting(page, def)
		local wrapper = new("Frame", {
			LayoutOrder = #page:GetChildren(),
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Parent = page,
		})
		new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = wrapper })

		local expandable = def.Expandable ~= false
		local opened = def.Opened ~= false
		local hasDesc = (def.Desc or "") ~= ""

		local header = new("TextButton", {
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, hasDesc and 40 or 28),
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			Text = "",
			Parent = wrapper,
		})
		local xOffset = 4
		new("Frame", {
			Position = UDim2.fromOffset(2, hasDesc and 8 or 7),
			Size = UDim2.fromOffset(3, 14),
			BackgroundColor3 = C.accent,
			BorderSizePixel = 0,
			Parent = header,
		})
		xOffset = 14
		if def.Icon then
			local holder = new("Frame", {
				Position = UDim2.fromOffset(xOffset, hasDesc and 6 or 5),
				Size = UDim2.fromOffset(18, 18),
				BackgroundTransparency = 1,
				Parent = header,
			})
			placeIcon(holder, def.Icon, 13, C.accent)
			xOffset += 24
		end
		local titleLabel = new("TextLabel", {
			Name = "Title",
			Position = UDim2.fromOffset(xOffset, hasDesc and 2 or 0),
			Size = UDim2.new(1, -(xOffset + 32), 0, hasDesc and 22 or 28),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			TextXAlignment = def.TextXAlignment == "Center" and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextColor3 = C.text,
			Text = def.Name,
			Parent = header,
		})
		local descLabel = new("TextLabel", {
			Name = "Desc",
			Position = UDim2.fromOffset(xOffset, 22),
			Size = UDim2.new(1, -(xOffset + 32), 0, 14),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextColor3 = C.sub,
			Text = def.Desc or "",
			Visible = hasDesc,
			Parent = header,
		})
		local arrow = new("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -8, 0, hasDesc and 13 or 7),
			Size = UDim2.fromOffset(14, 14),
			BackgroundTransparency = 1,
			Visible = expandable,
			Parent = header,
		})
		drawIcon(arrow, "chevron", 10)(C.sub)
		new("Frame", {
			Position = UDim2.new(0, 0, 1, -1),
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = C.line,
			BackgroundTransparency = 0.6,
			BorderSizePixel = 0,
			Parent = header,
		})

		local content = new("Frame", {
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = C.panel,
			BackgroundTransparency = def.Box and 0.5 or 1,
			BorderSizePixel = 0,
			Visible = opened,
			Parent = wrapper,
		})
		if def.Box then
			round(content, 8)
			if def.BoxBorder then
				outline(content, C.line, 0.6)
			end
			new("UIPadding", {
				PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
				PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6),
				Parent = content,
			})
		end
		new("UIListLayout", { Padding = UDim.new(0, GROUP_GAP), SortOrder = Enum.SortOrder.LayoutOrder, Parent = content })

		local function setOpened(on)
			opened = on and true or false
			content.Visible = opened
			arrow.Rotation = opened and 0 or -90
		end
		setOpened(opened)
		header.MouseButton1Click:Connect(function()
			if expandable then
				setOpened(not opened)
			end
		end)

		local object = makePageObject(content)
		object.Frame = wrapper
		function object:Open()
			setOpened(true)
		end
		function object:Close()
			setOpened(false)
		end
		function object:Toggle()
			setOpened(not opened)
		end
		function object:IsOpen()
			return opened
		end
		function object:SetTitle(text)
			titleLabel.Text = text
		end
		function object:SetDesc(text)
			descLabel.Text = text or ""
			descLabel.Visible = (text or "") ~= ""
		end
		function object:Destroy()
			wrapper:Destroy()
		end
		return object
	end

	--------------------------------------------------------------------
	-- Реестр элементов + объект страницы
	--------------------------------------------------------------------
	local function textElement(page, def)
		if def.MaxLength == nil then
			def.MaxLength = 500
		end
		if def.Type == "Textarea" then
			return areaSetting(page, def)
		end
		return textSetting(page, def)
	end

	ELEMENT_DEFS = {
		{ names = { "AddToggle", "Toggle" }, build = toggleSetting },
		{ names = { "AddSlider", "Slider" }, build = numberSetting, raw = true },
		{ names = { "AddChoice" }, build = choiceSetting },
		{ names = { "AddColor" }, build = colorSetting },
		{ names = { "AddTextBox" }, build = textSetting },
		{ names = { "AddButton", "Button" }, build = actionSetting },
		{ names = { "AddInput", "Input" }, build = textElement },
		{ names = { "AddDropdown", "Dropdown" }, build = dropdownSetting },
		{ names = { "AddMultiDropdown" }, build = function(page, def)
			def.Multi = true
			return dropdownSetting(page, def)
		end },
		{ names = { "AddKeybind", "Keybind" }, build = keybindSetting },
		{ names = { "AddColorpicker", "Colorpicker" }, build = colorpickerSetting },
		{ names = { "AddParagraph", "Paragraph" }, build = paragraphSetting },
		{ names = { "AddCode", "Code" }, build = codeSetting },
		{ names = { "AddDivider", "Divider" }, build = dividerSetting },
		{ names = { "AddSpace", "Space" }, build = spaceSetting },
		{ names = { "AddImage", "Image" }, build = imageSetting },
		{ names = { "AddProgressBar", "ProgressBar" }, build = progressSetting, raw = true },
		{ names = { "AddViewport", "Viewport" }, build = viewportSetting },
		{ names = { "AddSection", "Section" }, build = sectionSetting },
		{ names = { "AddGroup", "Group", "AddHStack", "HStack" }, build = function(page, def)
			return stackSetting(page, def, true)
		end },
		{ names = { "AddVStack", "VStack" }, build = function(page, def)
			return stackSetting(page, def, false)
		end },
	}
	Window.ElementNames = {}
	for _, entry in ipairs(ELEMENT_DEFS) do
		for _, name in ipairs(entry.names) do
			table.insert(Window.ElementNames, name)
		end
	end

	-- Объект страницы: из него вызываются Add* (и короткие имена WindUI: page:Toggle{...})
	makePageObject = function(pageFrame)
		local pageObject = { Frame = pageFrame }
		for _, entry in ipairs(ELEMENT_DEFS) do
			for _, name in ipairs(entry.names) do
				pageObject[name] = function(_, def)
					local d = normalizeDef(def, entry.raw)
					if entry.raw and type(d.Value) == "table" then
						d.Min = d.Min or d.Value.Min
						d.Max = d.Max or d.Value.Max
						if d.Default == nil then
							d.Default = d.Value.Default
						end
					elseif entry.raw and d.Default == nil and type(d.Value) == "number" then
						d.Default = d.Value
					end
					local object = entry.build(pageFrame, d)
					decorate(object, d)
					afterAdd(pageFrame)
					return object
				end
			end
		end
		return pageObject
	end

	--------------------------------------------------------------------
	-- Window:Dialog{ Title, Content, Icon, Buttons = { { Title, Callback, Variant } } }
	--------------------------------------------------------------------
	function Window:Dialog(dialogDef)
		dialogDef = dialogDef or {}
		closePopup()
		local overlay = new("TextButton", {
			Name = "Dialog",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.45,
			AutoButtonColor = false,
			Text = "",
			ZIndex = 40,
			Parent = frame,
		})
		round(overlay, 12)
		overlay:SetAttribute("KeepColor", true)
		local card = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(dialogDef.Width or 300, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = C.panel,
			BorderSizePixel = 0,
			ZIndex = 41,
			Parent = overlay,
		})
		round(card, 10)
		outline(card, C.accent, 0.4)
		new("UIPadding", {
			PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14),
			PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14),
			Parent = card,
		})
		new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = card })

		local function close()
			if overlay.Parent then
				overlay:Destroy()
			end
		end

		new("TextLabel", {
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 15,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.text,
			Text = dialogDef.Title or "",
			ZIndex = 42,
			Parent = card,
		})
		if (dialogDef.Content or "") ~= "" then
			new("TextLabel", {
				LayoutOrder = 2,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextColor3 = C.sub,
				Text = dialogDef.Content,
				ZIndex = 42,
				Parent = card,
			})
		end
		local buttons = dialogDef.Buttons or { { Title = "OK", Variant = "Primary" } }
		local buttonRow = new("Frame", {
			LayoutOrder = 3,
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundTransparency = 1,
			ZIndex = 42,
			Parent = card,
		})
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = buttonRow,
		})
		for index, buttonDef in ipairs(buttons) do
			local bg, fg, strokeTransparency = variantStyle(buttonDef.Variant, buttonDef.Color)
			local button = new("TextButton", {
				LayoutOrder = index,
				Size = UDim2.fromOffset(0, 30),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundColor3 = bg,
				BorderSizePixel = 0,
				AutoButtonColor = true,
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				TextColor3 = fg,
				Text = buttonDef.Title or buttonDef.Name or "OK",
				ZIndex = 43,
				Parent = buttonRow,
			})
			round(button, 6)
			new("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), Parent = button })
			if strokeTransparency < 1 then
				outline(button, C.line, strokeTransparency)
			end
			button.MouseButton1Click:Connect(function()
				close()
				fire(buttonDef.Callback)
			end)
		end
		return { Close = close }
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
		if elementListening then
			return
		end
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
		local isPage = rawDef.Page == true or rawDef.NoToggle == true
		do
			local source, key = rawDef.Source, rawDef.Key
			if isPage then
				-- карточка-страница: без переключателя, по клику открывает страницу настроек
				source, key = { Enabled = false }, "Enabled"
			elseif not source then
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
			Visible = not isPage,
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

		if isPage then
			ensureSettings()
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
		if not isPage then
			moduleRegistry[def.name] = { toggle = toggle, def = def, group = section.group, section = section.name }
		end

		card.MouseButton1Click:Connect(function()
			if isPage then
				openSettings(module)
			else
				toggle()
			end
		end)

		-- ПКМ: назначить клавишу
		card.MouseButton2Click:Connect(function()
			if isPage then
				return
			end
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
		if not isPage then
			table.insert(section.modules, def)
		end
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
		-- все элементы страницы доступны прямо на модуле: module:AddToggle{...}, module:Dropdown{...}
		for _, entry in ipairs(ELEMENT_DEFS) do
			for _, methodName in ipairs(entry.names) do
				if moduleObject[methodName] == nil then
				moduleObject[methodName] = function(_, d)
					local page = ensureSettings()
					return page[methodName](page, d)
				end
				end
			end
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
		-- карточка без переключателя, открывающая страницу с элементами: section:AddPage{ Name, Description, Icon, Settings }
		function object:AddPage(def)
			local copy = {}
			for k, v in pairs(def or {}) do
				copy[k] = v
			end
			copy.Page = true
			return addModule(data, copy)
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
				elseif valueType == "table" then
					-- списки строк/чисел (Dropdown с Multi)
					local items, valid = {}, true
					for _, item in ipairs(value) do
						if type(item) == "string" or type(item) == "number" then
							table.insert(items, item)
						else
							valid = false
						end
					end
					if valid then
						group[key] = { __list = true, items = items }
					end
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
						elseif type(current) == "table" and type(value) == "table" and value.__list then
							local items = {}
							for _, item in ipairs(value.items or {}) do
								table.insert(items, item)
							end
							source[key] = items
						elseif typeof(current) == typeof(value) then
							source[key] = value
						end
					elseif source == Window.Flags then
						-- флаг ещё не создан (элемент добавится позже): сохраняем значение заранее
						if type(value) == "table" and value.__color then
							source[key] = Color3.fromRGB(value.r, value.g, value.b)
						elseif type(value) == "table" and value.__list then
							local items = {}
							for _, item in ipairs(value.items or {}) do
								table.insert(items, item)
							end
							source[key] = items
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
		if gameProcessed or introPlaying or elementListening then
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
