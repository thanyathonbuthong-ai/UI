--[[
	UAI UI Library  v1.0.0
	สกัดดีไซน์จาก Project UAI 3.7.1 (ui/theme, ui/primitives, ui/controls, ui/window)
	ทำเป็นไลบรารีไฟล์เดียว ไม่ต้องพึ่งโมดูลอื่น

	local Library = loadstring(game:HttpGet("<url>/UAI_UI_Library.lua"))()
	-- หรือ local Library = loadstring(readfile("UAI_UI_Library.lua"))()

	ดูตัวอย่างเต็มใน UAI_UI_Example.lua
]]

local cloneref = cloneref or function(x) return x end
local function service(name) return cloneref(game:GetService(name)) end

local Players = service("Players")
local UserInputService = service("UserInputService")
local TweenService = service("TweenService")
local HttpService = service("HttpService")
local Workspace = service("Workspace")

local genv = (getgenv and getgenv()) or _G
if genv.UAI_UI and type(genv.UAI_UI.Unload) == "function" then
	pcall(genv.UAI_UI.Unload, genv.UAI_UI)
end

local Library = {
	Version = "1.0.0",
	Flags = {},
	Accents = {},
	Mobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled,
	Folder = "UAI_UI",
	_elements = {},
	_conns = {},
	_accentFns = {},
	_keybinds = {},
	_windows = {},
}

--------------------------------------------------------------------------------
-- Theme tokens (ค่าเดียวกับ ui/theme ของ UAI)
--------------------------------------------------------------------------------
local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end

local N = {
	[0] = rgb(23, 23, 22), rgb(30, 30, 28), rgb(35, 35, 33), rgb(42, 42, 39),
	rgb(50, 50, 46), rgb(62, 62, 57), rgb(74, 74, 71), rgb(92, 91, 86),
	rgb(108, 107, 102), rgb(163, 161, 152), rgb(194, 191, 181), rgb(245, 244, 238),
}

local ACCENTS = {
	claude = { base = rgb(217, 119, 87), hot = rgb(232, 146, 117), label = "Coral" },
	aurora = { base = rgb(58, 205, 186), hot = rgb(96, 226, 208), label = "Aurora" },
	indigo = { base = rgb(122, 136, 255), hot = rgb(153, 165, 255), label = "Indigo" },
	amber = { base = rgb(226, 160, 74), hot = rgb(243, 184, 108), label = "Amber" },
	rose = { base = rgb(240, 108, 138), hot = rgb(249, 142, 166), label = "Rose" },
}
Library.Accents = ACCENTS

local function mix(a, b, t) return a:Lerp(b, math.clamp(t, 0, 1)) end

-- ตารางเดียว แก้ค่าในที่เดิม เพื่อให้ local C ที่ถูกอ้างอิงไว้ไม่เก่า
local C = {
	canvas = N[1], sidebar = N[0], surface = N[2], surfaceRaised = N[3],
	surfaceOverlay = N[4], surfaceHover = N[4], surfaceActive = N[5],
	borderSubtle = N[5], border = N[6], borderStrong = N[7],
	text = N[11], textSecondary = N[10], textTertiary = N[9], textDisabled = N[8],
	scrim = N[0],
	success = rgb(94, 200, 124), warn = rgb(226, 170, 78),
	danger = rgb(240, 132, 124), info = rgb(120, 162, 226),
	dangerSurface = mix(N[3], rgb(240, 132, 124), 0.13),
	dangerBorder = mix(N[5], rgb(240, 132, 124), 0.45),
}

local function buildAccent(accent)
	C.accent = accent.base
	C.accentHot = accent.hot
	C.onAccent = N[0]
	C.accentSurface = mix(N[3], accent.base, 0.14)
	C.surfaceSelected = mix(N[4], accent.base, 0.20)
end
buildAccent(ACCENTS.claude)

local R = { sm = 6, md = 8, lg = 12, xl = 16, pill = 999 }
local TS = { title = 15, body = 13, small = 12, caption = 11 }

local TI = {
	instant = TweenInfo.new(0),
	hover = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	press = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	slide = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	exit = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
}

--------------------------------------------------------------------------------
-- Fonts: ใช้ BuilderSans + แกน weight ถ้ามี ไม่งั้น fallback เป็น Gotham
--------------------------------------------------------------------------------
local family
pcall(function() family = Font.fromEnum(Enum.Font.BuilderSans).Family end)
local WEIGHT = { regular = "Regular", medium = "Medium", strong = "SemiBold" }
local FALLBACK = { regular = Enum.Font.Gotham, medium = Enum.Font.GothamMedium, strong = Enum.Font.GothamBold }

local function applyFont(obj, weight)
	weight = weight or "regular"
	if family then
		local ok = pcall(function()
			obj.FontFace = Font.new(family, Enum.FontWeight[WEIGHT[weight]], Enum.FontStyle.Normal)
		end)
		if ok then return end
	end
	obj.Font = FALLBACK[weight]
end

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------
local function connect(signal, fn)
	local c = signal:Connect(fn)
	Library._conns[#Library._conns + 1] = c
	return c
end

local function fire(cb, ...)
	if type(cb) ~= "function" then return end
	local ok, err = pcall(cb, ...)
	if not ok then warn("[UAI UI] callback error: " .. tostring(err)) end
end

local function tw(obj, info, goals)
	local t = TweenService:Create(obj, info, goals)
	t:Play()
	return t
end

local function gui(class, props, parent)
	local o = Instance.new(class)
	o.BorderSizePixel = 0
	if props.BackgroundColor3 == nil then o.BackgroundTransparency = 1 end
	if class == "TextButton" then o.AutoButtonColor = false; o.Text = "" end
	if class == "TextLabel" then o.Text = "" end
	for k, v in pairs(props) do o[k] = v end
	if parent then o.Parent = parent end
	return o
end

local function corner(o, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = o
	return c
end

local function stroke(o, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = o
	return s
end

local function pad(o, t, r, b, l)
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, t or 0)
	p.PaddingRight = UDim.new(0, r or t or 0)
	p.PaddingBottom = UDim.new(0, b or t or 0)
	p.PaddingLeft = UDim.new(0, l or r or t or 0)
	p.Parent = o
	return p
end

local function list(o, gap, dir)
	local l = Instance.new("UIListLayout")
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Padding = UDim.new(0, gap or 8)
	l.FillDirection = dir or Enum.FillDirection.Vertical
	l.Parent = o
	return l
end

local function text(parent, o)
	local l = gui("TextLabel", {
		Text = tostring(o.Text or ""),
		TextSize = o.TextSize or TS.body,
		TextColor3 = o.Color or C.text,
		TextXAlignment = o.Align or Enum.TextXAlignment.Left,
		TextYAlignment = o.AlignY or Enum.TextYAlignment.Center,
		TextWrapped = o.Wrap == true,
		RichText = o.Rich == true,
		TextTruncate = o.Truncate and Enum.TextTruncate.AtEnd or Enum.TextTruncate.None,
		Size = o.Size or UDim2.new(1, 0, 0, 16),
		Position = o.Position or UDim2.new(),
		AnchorPoint = o.Anchor or Vector2.new(),
		LayoutOrder = o.LayoutOrder or 0,
		AutomaticSize = o.Auto or Enum.AutomaticSize.None,
	}, parent)
	applyFont(l, o.Weight)
	return l
end

local function onAccent(anchor, fn)
	Library._accentFns[#Library._accentFns + 1] = { anchor = anchor, fn = fn }
	fn()
end

local function isPress(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

-- ลากแบบรวมศูนย์ (เมาส์ + ทัช) : onMove(Vector2) ถูกเรียกทันทีหนึ่งครั้งตอนเริ่มลาก
local function startDrag(input, onMove, onEnd)
	onMove(input.Position)
	local c1, c2
	c1 = UserInputService.InputChanged:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
			onMove(i.Position)
		end
	end)
	c2 = input.Changed:Connect(function()
		if input.UserInputState == Enum.UserInputState.End then
			c1:Disconnect()
			c2:Disconnect()
			if onEnd then onEnd() end
		end
	end)
end

--------------------------------------------------------------------------------
-- Root GUI + overlay
--------------------------------------------------------------------------------
local function resolveParent()
	local ok, ui = pcall(function() return gethui and gethui() end)
	if ok and ui then return ui end
	ok, ui = pcall(function() return service("CoreGui") end)
	if ok and ui then
		local probe = Instance.new("Folder")
		local writable = pcall(function() probe.Parent = ui end)
		probe:Destroy()
		if writable then return ui end
	end
	return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function ensureGui()
	if Library.Gui and Library.Gui.Parent then return end
	local g = Instance.new("ScreenGui")
	g.Name = "UAI_UI"
	g.ResetOnSpawn = false
	g.IgnoreGuiInset = true
	g.DisplayOrder = 999
	g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	g.Parent = resolveParent()
	Library.Gui = g

	Library.Overlay = gui("Frame", { Name = "Overlay", Size = UDim2.fromScale(1, 1), ZIndex = 50 }, g)

	Library.ToastHolder = gui("Frame", {
		Name = "Toasts", AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0, 16), Size = UDim2.new(0, 280, 1, -32), ZIndex = 80,
	}, g)
	local l = list(Library.ToastHolder, 8)
	l.HorizontalAlignment = Enum.HorizontalAlignment.Right
end

--------------------------------------------------------------------------------
-- Button factory (variants จาก ui/primitives)
--------------------------------------------------------------------------------
local function variantOf(name)
	if name == "primary" then
		return { bg = C.text, hover = mix(C.text, rgb(255, 255, 255), 0.5), press = C.textSecondary, text = N[0] }
	elseif name == "accent" then
		return { bg = C.accent, hover = C.accentHot, press = C.accent, text = C.onAccent }
	elseif name == "danger" then
		return { bg = nil, hover = C.dangerSurface, press = C.danger, text = C.danger, stroke = C.dangerBorder }
	elseif name == "ghost" then
		return { bg = nil, hover = C.surfaceHover, press = C.surfaceActive, text = C.textSecondary }
	end
	return { bg = nil, hover = C.surfaceHover, press = C.surfaceActive, text = C.text, stroke = C.border }
end

local function makeButton(parent, o)
	local v = variantOf(o.Variant)
	local btn = gui("TextButton", {
		Size = o.Size or UDim2.new(0, 0, 0, Library.Mobile and 38 or 32),
		AutomaticSize = o.Size and Enum.AutomaticSize.None or Enum.AutomaticSize.X,
		BackgroundColor3 = v.bg or C.surfaceHover,
		BackgroundTransparency = v.bg and 0 or 1,
		LayoutOrder = o.LayoutOrder or 0,
	}, parent)
	corner(btn, R.md)
	local st = stroke(btn, v.stroke or C.accent)
	st.Transparency = v.stroke and 0 or 1
	pad(btn, 0, 14, 0, 14)
	local label = text(btn, {
		Text = o.Text or "Button", Color = v.text, Weight = "medium",
		Size = UDim2.new(o.Size and 1 or 0, 0, 1, 0),
		Auto = (not o.Size) and Enum.AutomaticSize.X or nil,
		Align = Enum.TextXAlignment.Center, Truncate = true,
	})

	local h, p = false, false
	local function paint()
		local target = p and v.press or (h and v.hover or v.bg)
		tw(btn, TI.hover, {
			BackgroundColor3 = target or v.hover,
			BackgroundTransparency = target and 0 or 1,
		})
	end
	connect(btn.MouseEnter, function() h = true; paint() end)
	connect(btn.MouseLeave, function() h = false; p = false; paint() end)
	connect(btn.MouseButton1Down, function() p = true; paint() end)
	connect(btn.MouseButton1Up, function() p = false; paint() end)
	connect(btn.Activated, function() fire(o.Callback) end)

	return { Instance = btn, Label = label, SetText = function(_, t) label.Text = tostring(t) end }
end

--------------------------------------------------------------------------------
-- Popup (dropdown / color picker) -- อยู่บน overlay ปิดเมื่อคลิกข้างนอกหรือกด Esc
--------------------------------------------------------------------------------
function Library:_closePopup()
	if self._popupClose then
		local fn = self._popupClose
		self._popupClose = nil
		pcall(fn)
	end
end

function Library:_openPopup(anchor, width, height)
	self:_closePopup()
	local catcher = gui("TextButton", { Size = UDim2.fromScale(1, 1), ZIndex = 60 }, self.Overlay)
	local ap, as = anchor.AbsolutePosition, anchor.AbsoluteSize
	local vp = self.Gui.AbsoluteSize
	local x = math.clamp(ap.X + as.X - width, 8, math.max(8, vp.X - width - 8))
	local y = ap.Y + as.Y + 4
	if y + height > vp.Y - 8 then y = math.max(8, ap.Y - height - 4) end
	local pop = gui("Frame", {
		Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(width, height),
		BackgroundColor3 = C.surfaceRaised, ClipsDescendants = true, Active = true,
	}, catcher)
	corner(pop, R.md)
	stroke(pop, C.border)
	pop.BackgroundTransparency = 1
	pop.Size = UDim2.fromOffset(width, height - 8)
	tw(pop, TI.hover, { BackgroundTransparency = 0, Size = UDim2.fromOffset(width, height) })
	connect(catcher.Activated, function() self:_closePopup() end)
	self._popupClose = function() catcher:Destroy() end
	return pop
end

--------------------------------------------------------------------------------
-- Toasts
--------------------------------------------------------------------------------
function Library:Notify(o)
	ensureGui()
	if type(o) == "string" then o = { Content = o } end
	local kind = o.Type or "info"
	local tint = ({ success = C.success, warn = C.warn, error = C.danger })[kind] or C.info
	local wrapper = gui("Frame", { Size = UDim2.new(0, 280, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, self.ToastHolder)
	local card = gui("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.fromOffset(300, 0), BackgroundColor3 = C.surfaceRaised,
	}, wrapper)
	corner(card, R.lg)
	stroke(card, C.border)
	gui("Frame", { Size = UDim2.new(0, 3, 1, -16), Position = UDim2.fromOffset(0, 8), BackgroundColor3 = tint }, card)
	local body = gui("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, card)
	pad(body, 10, 12, 10, 16)
	list(body, 2)
	if o.Title then
		text(body, { Text = o.Title, Weight = "strong", Size = UDim2.new(1, 0, 0, 18), LayoutOrder = 1 })
	end
	if o.Content then
		text(body, {
			Text = o.Content, Color = C.textSecondary, TextSize = TS.small, Wrap = true,
			Size = UDim2.new(1, 0, 0, 0), Auto = Enum.AutomaticSize.Y, LayoutOrder = 2,
		})
	end
	tw(card, TI.slide, { Position = UDim2.fromOffset(0, 0) })
	task.delay(o.Duration or 4, function()
		if not card.Parent then return end
		local t = tw(card, TI.exit, { Position = UDim2.fromOffset(300, 0) })
		t.Completed:Wait()
		wrapper:Destroy()
	end)
end

--------------------------------------------------------------------------------
-- Dialog / Confirm
--------------------------------------------------------------------------------
function Library:Dialog(o)
	ensureGui()
	local scrim = gui("TextButton", {
		Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.scrim, BackgroundTransparency = 1, ZIndex = 70,
	}, self.Overlay)
	tw(scrim, TI.hover, { BackgroundTransparency = 0.5 })
	local card = gui("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0, math.min(340, self.Gui.AbsoluteSize.X - 32), 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = C.surfaceRaised, Active = true,
	}, scrim)
	corner(card, R.xl)
	stroke(card, C.border)
	pad(card, 16)
	list(card, 10)
	text(card, { Text = o.Title or "Dialog", TextSize = TS.title, Weight = "strong", Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 1 })
	if o.Content then
		text(card, {
			Text = o.Content, Color = C.textSecondary, Wrap = true,
			Size = UDim2.new(1, 0, 0, 0), Auto = Enum.AutomaticSize.Y, LayoutOrder = 2,
		})
	end
	local buttons = gui("Frame", { Size = UDim2.new(1, 0, 0, Library.Mobile and 38 or 32), LayoutOrder = 3 }, card)
	local bl = list(buttons, 8, Enum.FillDirection.Horizontal)
	bl.HorizontalAlignment = Enum.HorizontalAlignment.Right

	local function close()
		local t = tw(scrim, TI.exit, { BackgroundTransparency = 1 })
		card:Destroy()
		t.Completed:Once(function() scrim:Destroy() end)
	end
	for i, b in ipairs(o.Buttons or { { Text = "OK", Variant = "accent" } }) do
		makeButton(buttons, {
			Text = b.Text, Variant = b.Variant or "secondary", LayoutOrder = i,
			Callback = function() close(); fire(b.Callback) end,
		})
	end
	connect(scrim.Activated, function() if o.Dismissable ~= false then close() end end)
	return { Close = close }
end

function Library:Confirm(o)
	return self:Dialog({
		Title = o.Title or "Confirm", Content = o.Content,
		Buttons = {
			{ Text = o.CancelText or "Cancel", Callback = o.OnCancel },
			{ Text = o.ConfirmText or "Confirm", Variant = o.Danger and "danger" or "accent", Callback = o.Callback },
		},
	})
end

--------------------------------------------------------------------------------
-- Section + controls
--------------------------------------------------------------------------------
local Section = {}
Section.__index = Section

function Section:_row(height, auto)
	self._order = self._order + 1
	local f = gui("Frame", { Size = UDim2.new(1, 0, 0, height), LayoutOrder = self._order }, self.Card)
	if auto then f.AutomaticSize = Enum.AutomaticSize.Y end
	return f
end

function Section:_label(row, str, reserve)
	return text(row, { Text = str, Size = UDim2.new(1, -(reserve or 0), 1, 0), Truncate = true })
end

local function finish(el, row, o)
	el.Frame = row
	el.Flag = o.Flag
	function el:SetVisible(v) row.Visible = v end
	function el:Destroy()
		row:Destroy()
		if el.Flag then Library._elements[el.Flag] = nil; Library.Flags[el.Flag] = nil end
	end
	if o.Flag then
		Library._elements[o.Flag] = el
		Library.Flags[o.Flag] = el.Value
	end
	return el
end

local function commit(el, value, silent, cb)
	el.Value = value
	if el.Flag then Library.Flags[el.Flag] = value end
	if not silent then fire(cb, value) end
end

local rowHeight = Library.Mobile and 38 or 34

function Section:AddLabel(str)
	local row = self:_row(0, true)
	local l = text(row, {
		Text = str, Color = C.textSecondary, TextSize = TS.small, Wrap = true,
		Size = UDim2.new(1, 0, 0, 0), Auto = Enum.AutomaticSize.Y,
	})
	local el = { Value = str }
	function el:Set(s) l.Text = tostring(s); el.Value = s end
	return finish(el, row, {})
end

function Section:AddParagraph(o)
	local row = self:_row(0, true)
	list(row, 2)
	text(row, { Text = o.Title or "", Weight = "medium", Size = UDim2.new(1, 0, 0, 18), LayoutOrder = 1 })
	local body = text(row, {
		Text = o.Content or "", Color = C.textSecondary, TextSize = TS.small, Wrap = true,
		Size = UDim2.new(1, 0, 0, 0), Auto = Enum.AutomaticSize.Y, LayoutOrder = 2,
	})
	local el = { Value = o.Content }
	function el:Set(s) body.Text = tostring(s); el.Value = s end
	return finish(el, row, {})
end

function Section:AddDivider()
	local row = self:_row(1)
	gui("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.borderSubtle }, row)
	return finish({}, row, {})
end

function Section:AddButton(o)
	local row = self:_row(Library.Mobile and 38 or 32)
	local b = makeButton(row, {
		Text = o.Name or o.Text or "Button", Variant = o.Variant or "secondary",
		Size = UDim2.fromScale(1, 1), Callback = o.Callback,
	})
	local el = {}
	function el:SetText(t) b:SetText(t) end
	return finish(el, row, {})
end

function Section:AddToggle(o)
	local row = self:_row(rowHeight)
	self:_label(row, o.Name or "Toggle", 46)
	local rail = gui("Frame", {
		Size = UDim2.fromOffset(34, 18), AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0), BackgroundColor3 = C.surfaceActive,
	}, row)
	corner(rail, R.pill)
	local st = stroke(rail, C.borderStrong)
	local knob = gui("Frame", {
		Size = UDim2.fromOffset(12, 12), AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 9, 0.5, 0), BackgroundColor3 = C.textSecondary,
	}, rail)
	corner(knob, R.pill)
	local hit = gui("TextButton", { Size = UDim2.fromScale(1, 1) }, row)

	local el = { Value = o.Default == true }
	local hovered = false
	local function paint(animate)
		local on, info = el.Value, animate and TI.hover or TI.instant
		tw(rail, info, { BackgroundColor3 = on and (hovered and C.accentHot or C.accent) or (hovered and C.surfaceHover or C.surfaceActive) })
		tw(st, info, { Color = on and C.accent or C.borderStrong })
		tw(knob, info, {
			Position = on and UDim2.new(1, -9, 0.5, 0) or UDim2.new(0, 9, 0.5, 0),
			BackgroundColor3 = on and C.onAccent or C.textSecondary,
		})
	end
	onAccent(row, function() paint(false) end)
	connect(hit.MouseEnter, function() hovered = true; paint(true) end)
	connect(hit.MouseLeave, function() hovered = false; paint(true) end)
	function el:Set(v, silent)
		commit(el, v == true, silent, o.Callback)
		paint(true)
	end
	connect(hit.Activated, function() el:Set(not el.Value) end)
	return finish(el, row, o)
end

function Section:AddSlider(o)
	local min, max = o.Min or 0, o.Max or 100
	local step = o.Step or o.Increment or 1
	local decimals = 0
	do
		local s = tostring(step)
		local dot = s:find("%.")
		if dot then decimals = #s - dot end
	end
	local function fmt(v)
		return string.format("%." .. decimals .. "f", v) .. (o.Suffix or "")
	end

	local row = self:_row(rowHeight + 14)
	self:_label(row, o.Name or "Slider", 70).Size = UDim2.new(1, -70, 0, 20)
	local valueLabel = text(row, {
		Text = "", Color = C.textTertiary, TextSize = TS.small, Anchor = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 70, 0, 20), Align = Enum.TextXAlignment.Right,
	})
	local track = gui("Frame", {
		Size = UDim2.new(1, -12, 0, 4), Position = UDim2.new(0, 6, 1, -14),
		BackgroundColor3 = C.surfaceActive,
	}, row)
	corner(track, R.pill)
	local fill = gui("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = C.accent }, track)
	corner(fill, R.pill)
	local knob = gui("Frame", {
		Size = UDim2.fromOffset(12, 12), AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5), BackgroundColor3 = C.text, ZIndex = 3,
	}, track)
	corner(knob, R.pill)
	local hit = gui("TextButton", { Size = UDim2.new(1, 0, 0, 26), Position = UDim2.new(0, 0, 1, -26), ZIndex = 4 }, row)

	local el = { Value = math.clamp(o.Default or min, min, max) }
	local dragging = false
	local function paint()
		local a = (max > min) and (el.Value - min) / (max - min) or 0
		fill.Size = UDim2.fromScale(a, 1)
		knob.Position = UDim2.fromScale(a, 0.5)
		valueLabel.Text = fmt(el.Value)
		fill.BackgroundColor3 = (dragging) and C.accentHot or C.accent
	end
	onAccent(row, paint)
	function el:Set(v, silent)
		v = math.clamp(tonumber(v) or min, min, max)
		v = min + math.floor((v - min) / step + 0.5) * step
		v = math.clamp(tonumber(string.format("%." .. decimals .. "f", v)), min, max)
		commit(el, v, silent, o.Callback)
		paint()
	end
	el.Value = el.Value
	paint()

	connect(hit.InputBegan, function(input)
		if not isPress(input) then return end
		dragging = true
		local page = self.Tab and self.Tab.Page
		if page then page.ScrollingEnabled = false end
		startDrag(input, function(pos)
			local a = math.clamp((pos.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
			el:Set(min + a * (max - min))
		end, function()
			dragging = false
			if page then page.ScrollingEnabled = true end
			paint()
		end)
	end)
	return finish(el, row, o)
end

function Section:AddDropdown(o)
	local multi = o.Multi == true
	local options = o.Options or {}
	local row = self:_row(rowHeight)
	self:_label(row, o.Name or "Dropdown", 150)
	local box = gui("TextButton", {
		Size = UDim2.new(0, 140, 0, rowHeight - 6), AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0), BackgroundColor3 = C.surfaceRaised,
	}, row)
	corner(box, R.md)
	local st = stroke(box, C.border)
	local shown = text(box, {
		Text = "", TextSize = TS.small, Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(1, -28, 1, 0), Truncate = true,
	})
	text(box, {
		Text = "▾", Color = C.textTertiary, TextSize = TS.small, Anchor = Vector2.new(1, 0),
		Position = UDim2.new(1, -8, 0, 0), Size = UDim2.new(0, 12, 1, 0), Align = Enum.TextXAlignment.Center,
	})

	local el = { Value = multi and {} or nil, Options = options }
	if multi then
		for _, v in ipairs(type(o.Default) == "table" and o.Default or {}) do el.Value[#el.Value + 1] = v end
	else
		el.Value = o.Default
	end

	local function isSelected(opt)
		if multi then return table.find(el.Value, opt) ~= nil end
		return el.Value == opt
	end
	local function refreshText()
		if multi then
			shown.Text = #el.Value > 0 and table.concat(el.Value, ", ") or "None"
		else
			shown.Text = el.Value ~= nil and tostring(el.Value) or "Select"
		end
		shown.TextColor3 = (multi or el.Value ~= nil) and C.text or C.textTertiary
	end
	refreshText()

	function el:Set(v, silent)
		if multi then
			local copy = {}
			if type(v) == "table" then for _, x in ipairs(v) do copy[#copy + 1] = x end end
			commit(el, copy, silent, o.Callback)
		else
			commit(el, v, silent, o.Callback)
		end
		refreshText()
	end
	function el:Refresh(newOptions, keep)
		el.Options = newOptions or {}
		options = el.Options
		if not keep then el:Set(multi and {} or nil, true) end
	end

	connect(box.Activated, function()
		tw(st, TI.hover, { Color = C.accent })
		local count = #options
		local h = math.min(count * 30 + 8, 188)
		local pop = Library:_openPopup(box, math.max(box.AbsoluteSize.X, 140), math.max(h, 38))
		local scroll = gui("ScrollingFrame", {
			Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 3, ScrollBarImageColor3 = C.borderStrong,
		}, pop)
		pad(scroll, 4)
		list(scroll, 2)
		for i, opt in ipairs(options) do
			local b = gui("TextButton", { Size = UDim2.new(1, 0, 0, 28), LayoutOrder = i }, scroll)
			corner(b, R.sm)
			local lbl = text(b, { Text = tostring(opt), TextSize = TS.small, Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -28, 1, 0), Truncate = true })
			local tick = text(b, { Text = "✓", Color = C.accent, TextSize = TS.small, Anchor = Vector2.new(1, 0), Position = UDim2.new(1, -6, 0, 0), Size = UDim2.new(0, 14, 1, 0), Align = Enum.TextXAlignment.Center })
			local function paint()
				local sel = isSelected(opt)
				tick.Visible = sel
				lbl.TextColor3 = sel and C.accent or C.text
				b.BackgroundColor3 = C.surfaceHover
			end
			paint()
			connect(b.MouseEnter, function() b.BackgroundTransparency = 0 end)
			connect(b.MouseLeave, function() b.BackgroundTransparency = 1 end)
			connect(b.Activated, function()
				if multi then
					local copy = table.clone(el.Value)
					local idx = table.find(copy, opt)
					if idx then table.remove(copy, idx) else copy[#copy + 1] = opt end
					el:Set(copy)
					paint()
				else
					el:Set(opt)
					Library:_closePopup()
				end
			end)
		end
		local prev = Library._popupClose
		Library._popupClose = function()
			if prev then prev() end
			tw(st, TI.hover, { Color = C.border })
		end
	end)
	return finish(el, row, o)
end

function Section:AddTextbox(o)
	local row = self:_row(rowHeight)
	self:_label(row, o.Name or "Textbox", 160)
	local holder = gui("Frame", {
		Size = UDim2.new(0, 150, 0, rowHeight - 6), AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0), BackgroundColor3 = C.surfaceRaised,
	}, row)
	corner(holder, R.md)
	local st = stroke(holder, C.border)
	local box = gui("TextBox", {
		Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(10, 0),
		Text = tostring(o.Default or ""), PlaceholderText = o.Placeholder or "",
		PlaceholderColor3 = C.textDisabled, TextColor3 = C.text, TextSize = TS.small,
		TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = o.ClearOnFocus == true,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, holder)
	applyFont(box, "regular")
	local el = { Value = box.Text }
	connect(box.Focused, function() tw(st, TI.hover, { Color = C.accent }) end)
	connect(box.FocusLost, function()
		tw(st, TI.hover, { Color = C.border })
		commit(el, box.Text, false, o.Callback)
	end)
	function el:Set(v, silent)
		box.Text = tostring(v or "")
		commit(el, box.Text, silent, o.Callback)
	end
	return finish(el, row, o)
end

function Section:AddKeybind(o)
	local row = self:_row(rowHeight)
	self:_label(row, o.Name or "Keybind", 100)
	local btn = gui("TextButton", {
		Size = UDim2.new(0, 90, 0, rowHeight - 6), AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0), BackgroundColor3 = C.surfaceRaised,
	}, row)
	corner(btn, R.md)
	local st = stroke(btn, C.border)
	local lbl = text(btn, { Text = "", TextSize = TS.small, Size = UDim2.fromScale(1, 1), Align = Enum.TextXAlignment.Center, Color = C.textSecondary })

	local el = { Value = o.Default and o.Default.Name or "None", Listening = false }
	local function paint()
		lbl.Text = el.Listening and "..." or el.Value
		lbl.TextColor3 = el.Listening and C.accent or C.textSecondary
		st.Color = el.Listening and C.accent or C.border
	end
	paint()
	function el:Set(v, silent)
		if typeof(v) == "EnumItem" then v = v.Name end
		commit(el, tostring(v or "None"), silent, o.Changed)
		paint()
	end
	connect(btn.Activated, function() el.Listening = true; paint() end)
	connect(UserInputService.InputBegan, function(input, processed)
		if el.Listening then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				el.Listening = false
				el:Set(input.KeyCode == Enum.KeyCode.Escape and "None" or input.KeyCode)
			end
			return
		end
		if processed or el.Value == "None" then return end
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == el.Value then
			fire(o.Callback, el.Value)
		end
	end)
	return finish(el, row, o)
end

function Section:AddColorPicker(o)
	local row = self:_row(rowHeight)
	self:_label(row, o.Name or "Color", 50)
	local swatch = gui("TextButton", {
		Size = UDim2.fromOffset(34, 20), AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0), BackgroundColor3 = o.Default or C.accent,
	}, row)
	corner(swatch, R.sm)
	stroke(swatch, C.borderStrong)

	local el = { Value = o.Default or C.accent }
	local hue, sat, val = Color3.toHSV(el.Value)
	function el:Set(v, silent)
		if type(v) == "table" then v = Color3.new(v.r or 0, v.g or 0, v.b or 0) end
		hue, sat, val = Color3.toHSV(v)
		swatch.BackgroundColor3 = v
		commit(el, v, silent, o.Callback)
	end

	connect(swatch.Activated, function()
		local pop = Library:_openPopup(swatch, 200, 184)
		pad(pop, 10)
		local sv = gui("Frame", { Size = UDim2.new(1, 0, 0, 110), BackgroundColor3 = Color3.fromHSV(hue, 1, 1) }, pop)
		corner(sv, R.sm)
		local white = gui("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = rgb(255, 255, 255) }, sv)
		corner(white, R.sm)
		local g1 = Instance.new("UIGradient")
		g1.Transparency = NumberSequence.new(0, 1)
		g1.Parent = white
		local black = gui("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = rgb(0, 0, 0) }, sv)
		corner(black, R.sm)
		local g2 = Instance.new("UIGradient")
		g2.Rotation = 90
		g2.Transparency = NumberSequence.new(1, 0)
		g2.Parent = black
		local svCursor = gui("Frame", {
			Size = UDim2.fromOffset(10, 10), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = rgb(255, 255, 255),
		}, sv)
		corner(svCursor, R.pill)
		stroke(svCursor, rgb(0, 0, 0))

		local hueBar = gui("Frame", { Size = UDim2.new(1, 0, 0, 12), Position = UDim2.fromOffset(0, 118), BackgroundColor3 = rgb(255, 255, 255) }, pop)
		corner(hueBar, R.pill)
		local g3 = Instance.new("UIGradient")
		g3.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, rgb(255, 0, 0)), ColorSequenceKeypoint.new(0.167, rgb(255, 255, 0)),
			ColorSequenceKeypoint.new(0.333, rgb(0, 255, 0)), ColorSequenceKeypoint.new(0.5, rgb(0, 255, 255)),
			ColorSequenceKeypoint.new(0.667, rgb(0, 0, 255)), ColorSequenceKeypoint.new(0.833, rgb(255, 0, 255)),
			ColorSequenceKeypoint.new(1, rgb(255, 0, 0)),
		})
		g3.Parent = hueBar
		local hueCursor = gui("Frame", {
			Size = UDim2.fromOffset(6, 16), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5),
			BackgroundColor3 = rgb(255, 255, 255),
		}, hueBar)
		corner(hueCursor, 3)
		stroke(hueCursor, rgb(0, 0, 0))

		local hexHolder = gui("Frame", { Size = UDim2.new(1, 0, 0, 24), Position = UDim2.fromOffset(0, 140), BackgroundColor3 = C.surface }, pop)
		corner(hexHolder, R.sm)
		local hex = gui("TextBox", {
			Size = UDim2.new(1, -16, 1, 0), Position = UDim2.fromOffset(8, 0), Text = "", TextSize = TS.small,
			TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false,
		}, hexHolder)
		applyFont(hex, "regular")

		local function sync(silent)
			local c = Color3.fromHSV(hue, sat, val)
			sv.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
			svCursor.Position = UDim2.fromScale(sat, 1 - val)
			hueCursor.Position = UDim2.fromScale(hue, 0.5)
			hex.Text = "#" .. c:ToHex():upper()
			swatch.BackgroundColor3 = c
			commit(el, c, silent, o.Callback)
		end
		sync(true)

		local function lockScroll(lock)
			local page = row.Parent and row.Parent.Parent and row.Parent.Parent.Parent
			if page and page:IsA("ScrollingFrame") then page.ScrollingEnabled = not lock end
		end
		local svHit = gui("TextButton", { Size = UDim2.fromScale(1, 1), ZIndex = 5 }, sv)
		connect(svHit.InputBegan, function(input)
			if not isPress(input) then return end
			lockScroll(true)
			startDrag(input, function(pos)
				sat = math.clamp((pos.X - sv.AbsolutePosition.X) / math.max(sv.AbsoluteSize.X, 1), 0, 1)
				val = 1 - math.clamp((pos.Y - sv.AbsolutePosition.Y) / math.max(sv.AbsoluteSize.Y, 1), 0, 1)
				sync()
			end, function() lockScroll(false) end)
		end)
		local hueHit = gui("TextButton", { Size = UDim2.new(1, 0, 1, 8), Position = UDim2.fromOffset(0, -4), ZIndex = 5 }, hueBar)
		connect(hueHit.InputBegan, function(input)
			if not isPress(input) then return end
			lockScroll(true)
			startDrag(input, function(pos)
				hue = math.clamp((pos.X - hueBar.AbsolutePosition.X) / math.max(hueBar.AbsoluteSize.X, 1), 0, 0.999)
				sync()
			end, function() lockScroll(false) end)
		end)
		connect(hex.FocusLost, function()
			local ok, c = pcall(Color3.fromHex, hex.Text)
			if ok and c then hue, sat, val = Color3.toHSV(c) end
			sync()
		end)
	end)
	return finish(el, row, o)
end

--------------------------------------------------------------------------------
-- Tab
--------------------------------------------------------------------------------
local Tab = {}
Tab.__index = Tab

function Tab:AddSection(o)
	if type(o) == "string" then o = { Title = o } end
	o = o or {}
	local card = gui("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = C.surface, LayoutOrder = #self.Sections + 1,
	}, self.Page)
	corner(card, R.lg)
	stroke(card, C.borderSubtle)
	pad(card, 12)
	list(card, 8)
	local sec = setmetatable({ Card = card, Tab = self, _order = 2 }, Section)
	text(card, { Text = o.Title or o.Name or "", Weight = "medium", TextSize = TS.small, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 0 })
	if o.Description then
		text(card, {
			Text = o.Description, Color = C.textTertiary, TextSize = TS.caption, Wrap = true,
			Size = UDim2.new(1, 0, 0, 0), Auto = Enum.AutomaticSize.Y, LayoutOrder = 1,
		})
	end
	self.Sections[#self.Sections + 1] = sec
	return sec
end

--------------------------------------------------------------------------------
-- Window
--------------------------------------------------------------------------------
local Window = {}
Window.__index = Window

function Window:SelectTab(tab)
	for _, t in ipairs(self.Tabs) do
		local on = (t == tab)
		t.Page.Visible = on
		t._selected = on
		t._paint()
	end
	self.Current = tab
end

function Window:AddTab(o)
	if type(o) == "string" then o = { Name = o } end
	local tab = setmetatable({ Name = o.Name, Sections = {}, Window = self }, Tab)

	local btn = gui("TextButton", { Size = UDim2.new(1, 0, 0, Library.Mobile and 38 or 32), LayoutOrder = #self.Tabs + 1 }, self.TabList)
	corner(btn, R.md)
	local bar = gui("Frame", { Size = UDim2.fromOffset(3, 14), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = C.accent }, btn)
	corner(bar, R.pill)
	local label = text(btn, {
		Text = (o.Icon and (o.Icon .. "  ") or "") .. (o.Name or "Tab"),
		Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -16, 1, 0), Truncate = true, Weight = "medium",
	})
	local hovered = false
	tab._selected = false
	function tab._paint()
		if tab._selected then
			tw(btn, TI.hover, { BackgroundColor3 = C.surfaceSelected, BackgroundTransparency = 0 })
		elseif hovered then
			tw(btn, TI.hover, { BackgroundColor3 = C.surfaceHover, BackgroundTransparency = 0 })
		else
			tw(btn, TI.hover, { BackgroundTransparency = 1 })
		end
		bar.Visible = tab._selected
		bar.BackgroundColor3 = C.accent
		label.TextColor3 = tab._selected and C.text or C.textSecondary
	end
	onAccent(btn, tab._paint)
	connect(btn.MouseEnter, function() hovered = true; tab._paint() end)
	connect(btn.MouseLeave, function() hovered = false; tab._paint() end)
	connect(btn.Activated, function() self:SelectTab(tab) end)

	tab.Page = gui("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1), Visible = false, CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3,
		ScrollBarImageColor3 = C.borderStrong, ScrollingDirection = Enum.ScrollingDirection.Y,
	}, self.Content)
	pad(tab.Page, 12, 14, 12, 12)
	list(tab.Page, 10)

	self.Tabs[#self.Tabs + 1] = tab
	if #self.Tabs == 1 then self:SelectTab(tab) end
	return tab
end

function Window:Show() self.Root.Visible = true; self.Visible = true end
function Window:Hide() self.Root.Visible = false; self.Visible = false; Library:_closePopup() end
function Window:Toggle() if self.Visible then self:Hide() else self:Show() end end
function Window:SetTitle(t) self.TitleLabel.Text = tostring(t) end

function Window:Minimize()
	self.Minimized = not self.Minimized
	if self.Minimized then
		self._fullSize = self.Root.Size
		self.Body.Visible = false
		self.Grip.Visible = false
		tw(self.Root, TI.slide, { Size = UDim2.new(self.Root.Size.X.Scale, self.Root.Size.X.Offset, 0, 44) })
	else
		tw(self.Root, TI.slide, { Size = self._fullSize })
		task.delay(0.12, function()
			if not self.Minimized and self.Body then
				self.Body.Visible = true
				self.Grip.Visible = true
			end
		end)
	end
end

function Window:Destroy()
	Library:_closePopup()
	if self.Launcher then self.Launcher:Destroy() end
	self.Root:Destroy()
	local idx = table.find(Library._windows, self)
	if idx then table.remove(Library._windows, idx) end
end

function Library:CreateWindow(o)
	o = o or {}
	ensureGui()
	if o.Accent then self:SetAccent(o.Accent) end

	local vp = self.Gui.AbsoluteSize
	local w = math.min(o.Width or 580, vp.X - 24)
	local h = math.min(o.Height or 400, vp.Y - 24)
	local minW, minH = 380, 260

	local win = setmetatable({ Tabs = {}, Visible = true, Minimized = false }, Window)
	local root = gui("Frame", {
		Name = o.Name or "Window", Size = UDim2.fromOffset(w, h),
		Position = UDim2.new(0.5, -w / 2, 0.5, -h / 2), BackgroundColor3 = C.canvas,
		ClipsDescendants = true, Active = true, ZIndex = 1,
	}, self.Gui)
	corner(root, R.xl)
	stroke(root, C.border)
	win.Root = root

	-- header
	local header = gui("Frame", { Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = C.sidebar }, root)
	gui("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = C.borderSubtle }, header)
	win.TitleLabel = text(header, {
		Text = o.Title or "UAI", TextSize = TS.title, Weight = "strong",
		Position = UDim2.fromOffset(16, 0), Size = UDim2.new(0, 0, 1, 0), Auto = Enum.AutomaticSize.X,
	})
	if o.Subtitle then
		text(header, {
			Text = o.Subtitle, Color = C.textTertiary, TextSize = TS.small,
			Position = UDim2.new(0, 24 + win.TitleLabel.TextBounds.X + 6, 0, 0), Size = UDim2.new(1, -140, 1, 0), Truncate = true,
		})
	end
	local function headerButton(glyph, xOffset, cb)
		local b = gui("TextButton", { Size = UDim2.fromOffset(30, 30), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, xOffset, 0.5, 0) }, header)
		corner(b, R.md)
		local l = text(b, { Text = glyph, TextSize = 18, Color = C.textSecondary, Size = UDim2.fromScale(1, 1), Align = Enum.TextXAlignment.Center })
		connect(b.MouseEnter, function() tw(b, TI.hover, { BackgroundColor3 = C.surfaceHover, BackgroundTransparency = 0 }) end)
		connect(b.MouseLeave, function() tw(b, TI.hover, { BackgroundTransparency = 1 }) end)
		connect(b.Activated, cb)
		return l
	end
	headerButton("×", -8, function() win:Hide() end)
	headerButton("–", -42, function() win:Minimize() end)

	-- drag by header
	connect(header.InputBegan, function(input)
		if not isPress(input) then return end
		local startMouse, startPos = input.Position, root.Position
		startDrag(input, function(pos)
			local d = pos - startMouse
			local nx = math.clamp(startPos.X.Offset + d.X, -root.AbsoluteSize.X + 80 - vp.X / 2, vp.X / 2 - 80)
			local ny = math.clamp(startPos.Y.Offset + d.Y, -vp.Y / 2, vp.Y / 2 - 44)
			root.Position = UDim2.new(startPos.X.Scale, nx, startPos.Y.Scale, ny)
		end)
	end)

	-- body: sidebar + content
	local body = gui("Frame", { Size = UDim2.new(1, 0, 1, -44), Position = UDim2.fromOffset(0, 44) }, root)
	win.Body = body
	local sideW = Library.Mobile and 120 or 148
	local sidebar = gui("Frame", { Size = UDim2.new(0, sideW, 1, 0), BackgroundColor3 = C.sidebar }, body)
	gui("Frame", { Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0), BackgroundColor3 = C.borderSubtle }, sidebar)
	win.TabList = gui("ScrollingFrame", {
		Size = UDim2.new(1, -1, 1, 0), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 0,
	}, sidebar)
	pad(win.TabList, 8)
	list(win.TabList, 4)
	win.Content = gui("Frame", { Size = UDim2.new(1, -sideW, 1, 0), Position = UDim2.fromOffset(sideW, 0), ClipsDescendants = true }, body)

	-- resize grip
	local grip = gui("TextButton", {
		Size = UDim2.fromOffset(22, 22), AnchorPoint = Vector2.new(1, 1), Position = UDim2.fromScale(1, 1), ZIndex = 5,
	}, root)
	for r = 0, 2 do
		for c = 0, r do
			gui("Frame", {
				Size = UDim2.fromOffset(2, 2), BackgroundColor3 = C.borderStrong, ZIndex = 5,
				Position = UDim2.new(1, -5 - c * 4, 1, -5 - (2 - r) * 4),
			}, grip)
		end
	end
	win.Grip = grip
	connect(grip.InputBegan, function(input)
		if not isPress(input) then return end
		local startMouse, startSize = input.Position, root.AbsoluteSize
		startDrag(input, function(pos)
			local d = pos - startMouse
			root.Size = UDim2.fromOffset(
				math.clamp(startSize.X + d.X, minW, vp.X - 16),
				math.clamp(startSize.Y + d.Y, minH, vp.Y - 16))
		end)
	end)

	-- toggle key + launcher
	local toggleKey = o.ToggleKey or (not Library.Mobile and Enum.KeyCode.RightShift or nil)
	if toggleKey then
		connect(UserInputService.InputBegan, function(input, processed)
			if not processed and input.KeyCode == toggleKey then win:Toggle() end
		end)
	end
	if o.Launcher == true or (o.Launcher == nil and Library.Mobile) then
		local launcher = gui("TextButton", {
			Size = UDim2.fromOffset(44, 44), Position = UDim2.new(0, 8, 0.5, -22),
			BackgroundColor3 = C.accent, ZIndex = 40,
		}, self.Gui)
		corner(launcher, R.pill)
		text(launcher, { Text = o.LauncherText or "U", Weight = "strong", TextSize = 18, Color = C.onAccent, Size = UDim2.fromScale(1, 1), Align = Enum.TextXAlignment.Center })
		connect(launcher.Activated, function() win:Toggle() end)
		onAccent(launcher, function() launcher.BackgroundColor3 = C.accent end)
		win.Launcher = launcher
	end

	self._windows[#self._windows + 1] = win
	return win
end

--------------------------------------------------------------------------------
-- Theme / config / lifecycle
--------------------------------------------------------------------------------
function Library:SetAccent(accent)
	if type(accent) == "string" then
		accent = ACCENTS[accent]
	elseif typeof(accent) == "Color3" then
		accent = { base = accent, hot = accent:Lerp(rgb(255, 255, 255), 0.18) }
	end
	if not accent then return end
	buildAccent(accent)
	for i = #self._accentFns, 1, -1 do
		local entry = self._accentFns[i]
		if entry.anchor.Parent then
			pcall(entry.fn)
		else
			table.remove(self._accentFns, i)
		end
	end
end

local function encode(v)
	if typeof(v) == "Color3" then return { __t = "Color3", r = v.R, g = v.G, b = v.B } end
	return v
end
local function decode(v)
	if type(v) == "table" and v.__t == "Color3" then return Color3.new(v.r, v.g, v.b) end
	return v
end

function Library:GetConfig()
	local out = {}
	for flag, v in pairs(self.Flags) do out[flag] = encode(v) end
	return out
end

function Library:ApplyConfig(cfg)
	for flag, v in pairs(cfg or {}) do
		local el = self._elements[flag]
		if el and el.Set then pcall(el.Set, el, decode(v), false) end
	end
end

function Library:SaveConfig(name)
	if not (writefile and isfolder and makefolder) then return false, "executor has no file API" end
	local ok, err = pcall(function()
		if not isfolder(self.Folder) then makefolder(self.Folder) end
		writefile(self.Folder .. "/" .. name .. ".json", HttpService:JSONEncode(self:GetConfig()))
	end)
	return ok, err
end

function Library:LoadConfig(name)
	if not (readfile and isfile) then return false, "executor has no file API" end
	local path = self.Folder .. "/" .. name .. ".json"
	if not isfile(path) then return false, "config not found" end
	local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
	if not ok then return false, data end
	self:ApplyConfig(data)
	return true
end

function Library:Unload()
	self:_closePopup()
	for _, c in ipairs(self._conns) do pcall(function() c:Disconnect() end) end
	self._conns = {}
	if self.Gui then pcall(function() self.Gui:Destroy() end) end
	self.Gui = nil
	if genv.UAI_UI == self then genv.UAI_UI = nil end
end

genv.UAI_UI = Library
return Library
