--!nocheck
--[[
	Hawk Lib  -  Roblox UI Library (Luau)
	ใช้ได้ทั้ง ModuleScript (require) และ executor (loadstring)
	ไอคอนทั้งหมดวาดด้วย Frame ล้วน ไม่ต้องใช้ asset id
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Library = { Flags = {}, Windows = {} }

--========================================================
-- Theme (เทียบสีจากภาพ)
--========================================================
local Theme = {
	Window      = Color3.fromRGB(27, 27, 27),
	Content     = Color3.fromRGB(32, 32, 32),
	Card        = Color3.fromRGB(39, 39, 39),
	CardInner   = Color3.fromRGB(47, 47, 47),
	TabSelected = Color3.fromRGB(43, 43, 43),
	Input       = Color3.fromRGB(28, 28, 28),
	Track       = Color3.fromRGB(23, 23, 23),
	Fill        = Color3.fromRGB(84, 84, 84),
	Text        = Color3.fromRGB(255, 255, 255),
	SubText     = Color3.fromRGB(176, 176, 176),
	Accent      = Color3.fromRGB(255, 56, 56),
	Purple      = Color3.fromRGB(157, 125, 255),
	Stroke      = Color3.fromRGB(55, 55, 55),
	Notify      = Color3.fromRGB(44, 44, 44),
}
Library.Theme = Theme

--========================================================
-- Utilities
--========================================================
local function Create(class, props, children)
	local obj = Instance.new(class)
	local parent
	for k, v in pairs(props or {}) do
		if k == "Parent" then parent = v else obj[k] = v end
	end
	for _, c in ipairs(children or {}) do c.Parent = obj end
	if parent then obj.Parent = parent end
	return obj
end

local function Frame(props)
	props = props or {}
	if props.BorderSizePixel == nil then props.BorderSizePixel = 0 end
	return Create("Frame", props)
end

local function Text(props)
	local d = {
		BackgroundTransparency = 1, BorderSizePixel = 0,
		Font = Enum.Font.Gotham, TextColor3 = Theme.Text, TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
	}
	for k, v in pairs(props) do d[k] = v end
	return Create("TextLabel", d)
end

local function Button(props)
	local d = { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0 }
	for k, v in pairs(props) do d[k] = v end
	return Create("TextButton", d)
end

local function Corner(parent, r) return Create("UICorner", { CornerRadius = UDim.new(0, r), Parent = parent }) end
local function Round(parent) return Create("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = parent }) end
local function Padding(parent, t, r, b, l)
	return Create("UIPadding", {
		PaddingTop = UDim.new(0, t), PaddingRight = UDim.new(0, r),
		PaddingBottom = UDim.new(0, b), PaddingLeft = UDim.new(0, l), Parent = parent,
	})
end
local function List(parent, pad)
	return Create("UIListLayout", { Padding = UDim.new(0, pad or 0), SortOrder = Enum.SortOrder.LayoutOrder, Parent = parent })
end
local function Stroke(parent, color, thick, trans)
	return Create("UIStroke", {
		Color = color, Thickness = thick or 1, Transparency = trans or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = parent,
	})
end

local function tween(obj, time, props, style, dir)
	local t = TweenService:Create(obj, TweenInfo.new(time or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local function lighten(c, a) return c:Lerp(Color3.new(1, 1, 1), a) end

local function fmt(v)
	if math.abs(v - math.floor(v + 0.5)) < 1e-9 then return tostring(math.floor(v + 0.5)) end
	local s = string.format("%.3f", v):gsub("0+$", "")
	return (s:gsub("%.$", ""))
end

local function safe(fn, ...)
	if type(fn) == "function" then task.spawn(fn, ...) end
end

--========================================================
-- Icons (วาดด้วย Frame บนกริด 24x24)
--========================================================
local Glyphs = {}

local function mark(i) i:SetAttribute("Tint", true) return i end

local function gLine(root, x1, y1, x2, y2, th, color)
	local dx, dy = x2 - x1, y2 - y1
	local f = Frame({
		BackgroundColor3 = color, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale((x1 + x2) / 48, (y1 + y2) / 48),
		Size = UDim2.fromScale(math.sqrt(dx * dx + dy * dy) / 24, th / 24),
		Rotation = math.deg(math.atan2(dy, dx)), Parent = root,
	})
	Round(f)
	return mark(f)
end

local function gBlob(root, cx, cy, w, h, color, rot)
	local f = Frame({
		BackgroundColor3 = color, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(cx / 24, cy / 24), Size = UDim2.fromScale(w / 24, h / 24),
		Rotation = rot or 0, Parent = root,
	})
	Round(f)
	return mark(f)
end

local function gTri(root, a, b, c, color)
	local n = 16
	local pts = { a, b, c }
	local minY = math.min(a[2], b[2], c[2])
	local maxY = math.max(a[2], b[2], c[2])
	local h = (maxY - minY) / n
	for i = 0, n - 1 do
		local y = minY + (i + 0.5) * h
		local xs = {}
		for k = 1, 3 do
			local p, q = pts[k], pts[k % 3 + 1]
			if (p[2] <= y and q[2] > y) or (q[2] <= y and p[2] > y) then
				table.insert(xs, p[1] + (q[1] - p[1]) * ((y - p[2]) / (q[2] - p[2])))
			end
		end
		if #xs >= 2 then
			local x1, x2 = math.min(xs[1], xs[2]), math.max(xs[1], xs[2])
			mark(Frame({
				BackgroundColor3 = color,
				Position = UDim2.fromScale(x1 / 24, (minY + i * h) / 24),
				Size = UDim2.fromScale((x2 - x1) / 24, (h + 0.08) / 24), Parent = root,
			}))
		end
	end
end

Glyphs.minus = function(r, c) gLine(r, 4, 12, 20, 12, 2.2, c) end
Glyphs.close = function(r, c)
	gLine(r, 4.5, 4.5, 19.5, 19.5, 2.2, c)
	gLine(r, 19.5, 4.5, 4.5, 19.5, 2.2, c)
end
Glyphs.maximize = function(r, c)
	local t, a, b, l = 2.2, 2.5, 21.5, 6
	gLine(r, a, a, a + l, a, t, c); gLine(r, a, a, a, a + l, t, c)
	gLine(r, b, a, b - l, a, t, c); gLine(r, b, a, b, a + l, t, c)
	gLine(r, a, b, a + l, b, t, c); gLine(r, a, b, a, b - l, t, c)
	gLine(r, b, b, b - l, b, t, c); gLine(r, b, b, b, b - l, t, c)
end
Glyphs.chevron = function(r, c)
	gLine(r, 5.5, 9, 12, 15.5, 2.4, c)
	gLine(r, 12, 15.5, 18.5, 9, 2.4, c)
end
Glyphs.check = function(r, c)
	gLine(r, 4.5, 12.5, 9.5, 17.5, 2.4, c)
	gLine(r, 9.5, 17.5, 19.5, 7, 2.4, c)
end
Glyphs.gear = function(r, c, px)
	local s = px / 24
	local ring = Frame({
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(6 / 24, 6 / 24), Parent = r,
	})
	Round(ring)
	mark(Create("UIStroke", { Color = c, Thickness = 3.6 * s, Parent = ring }))
	for i = 0, 7 do
		local a = math.rad(i * 45)
		gBlob(r, 12 + math.cos(a) * 8, 12 + math.sin(a) * 8, 3.6, 4.6, c, i * 45 + 90)
	end
end
Glyphs.bell = function(r, c)
	gBlob(r, 12, 10.5, 11, 13, c)
	gBlob(r, 12, 16.6, 15, 3.4, c)
	gBlob(r, 12, 20.7, 4.6, 4.6, c)
	gBlob(r, 12, 3.7, 2, 2.6, c)
end
Glyphs.cursor = function(r, c)
	gTri(r, { 9, 9 }, { 14, 21 }, { 15.8, 15.8 }, c)
	gTri(r, { 9, 9 }, { 15.8, 15.8 }, { 21, 14 }, c)
	gLine(r, 15.5, 15.5, 20.5, 20.5, 2.4, c)
	gLine(r, 14, 4.1, 12, 6, 1.8, c)
	gLine(r, 5.1, 8, 2.2, 7.2, 1.8, c)
	gLine(r, 6, 12, 4.1, 14, 1.8, c)
	gLine(r, 7.2, 2.2, 8, 5.1, 1.8, c)
end
Library.Glyphs = Glyphs

local function TintIcon(root, color)
	local list = root:GetDescendants()
	table.insert(list, root)
	for _, d in ipairs(list) do
		if d:IsA("ImageLabel") then d.ImageColor3 = color
		elseif d:GetAttribute("Tint") then
			if d:IsA("UIStroke") then d.Color = color else d.BackgroundColor3 = color end
		end
	end
end

local function MakeIcon(parent, px, color, icon)
	if icon == nil then return nil end
	if typeof(icon) == "number" then icon = "rbxassetid://" .. icon end
	if typeof(icon) == "string" and (icon:find("rbxasset") or icon:find("http")) then
		return Create("ImageLabel", {
			BackgroundTransparency = 1, Size = UDim2.fromOffset(px, px),
			Image = icon, ImageColor3 = color, Parent = parent,
		})
	end
	if Glyphs[icon] then
		local root = Frame({ BackgroundTransparency = 1, Size = UDim2.fromOffset(px, px), Parent = parent })
		Glyphs[icon](root, color, px)
		return root
	end
	return nil
end

--========================================================
-- GUI root
--========================================================
function Library:_getGui()
	if self.Gui and self.Gui.Parent then return self.Gui end
	local gui = Create("ScreenGui", {
		Name = "HawkLib", ResetOnSpawn = false, IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999,
	})
	local ok = false
	if gethui then ok = pcall(function() gui.Parent = gethui() end) end
	if not ok then ok = pcall(function() gui.Parent = CoreGui end) end
	if not ok or not gui.Parent then
		gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	end
	self.Gui = gui
	return gui
end

--========================================================
-- Elements (ใช้ร่วมกันทั้ง Tab และ Section)
--========================================================
local Elements = {}

function Elements:_order()
	self._n = (self._n or 0) + 1
	return self._n
end

function Elements:_card(minH, listPad, class)
	local nested = self._nested
	local props = {
		BackgroundColor3 = nested and Theme.CardInner or Theme.Card,
		BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = self:_order(), Parent = self._parent,
	}
	local card
	if class == "TextButton" then
		props.Text = ""; props.AutoButtonColor = false
		card = Create("TextButton", props)
	else
		card = Create("Frame", props)
	end
	Corner(card, 8)
	Padding(card, 9, nested and 8 or 14, 10, nested and 9 or 16)
	Create("UISizeConstraint", { MinSize = Vector2.new(0, minH or 64), Parent = card })
	if listPad then List(card, listPad) end
	return card
end

local function Header(card, title, desc, rightPad)
	local wrap = Frame({
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1, Parent = card,
	})
	local inner = Frame({
		BackgroundTransparency = 1, Size = UDim2.new(1, -(rightPad or 0), 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, Parent = wrap,
	})
	List(inner, 2)
	local t = Text({
		Text = title or "", Font = Enum.Font.GothamBold, TextSize = 16,
		Size = UDim2.new(1, 0, 0, 20), TextTruncate = Enum.TextTruncate.AtEnd, LayoutOrder = 1, Parent = inner,
	})
	local d = Text({
		Text = desc or "", TextSize = 15, TextColor3 = Theme.SubText,
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, LayoutOrder = 2,
		Visible = (desc ~= nil and desc ~= ""), Parent = inner,
	})
	return wrap, t, d
end

local function BaseObj(card, t, d)
	local obj = {}
	function obj:SetTitle(s) t.Text = s end
	function obj:SetDescription(s) d.Text = s; d.Visible = (s ~= nil and s ~= "") end
	function obj:SetVisible(v) card.Visible = v end
	function obj:Destroy() card:Destroy() end
	obj.Instance = card
	return obj
end

local function title(cfg) return cfg.Title or cfg.Name or "" end

function Elements:_setScroll(on)
	if self._scroller then self._scroller.ScrollingEnabled = on end
end

-- Paragraph ---------------------------------------------------------
function Elements:AddParagraph(cfg)
	cfg = cfg or {}
	local card = self:_card(0, 3)
	local _, t, d = Header(card, title(cfg), nil, 0)
	local body = Text({
		Text = cfg.Content or cfg.Description or "", TextSize = 15, TextColor3 = Theme.SubText,
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top, LineHeight = 1.2, LayoutOrder = 2, Parent = card,
	})
	local obj = BaseObj(card, t, d)
	function obj:SetContent(s) body.Text = s end
	return obj
end

-- Label -------------------------------------------------------------
function Elements:AddLabel(cfg)
	if type(cfg) == "string" then cfg = { Title = cfg } end
	cfg = cfg or {}
	local card = self:_card(0)
	local _, t, d = Header(card, title(cfg), cfg.Description, 0)
	return BaseObj(card, t, d)
end

-- Divider -----------------------------------------------------------
function Elements:AddDivider()
	local f = Frame({
		BackgroundColor3 = self._nested and Color3.fromRGB(58, 58, 58) or Theme.CardInner,
		Size = UDim2.new(1, 0, 0, 10), LayoutOrder = self:_order(), Parent = self._parent,
	})
	Round(f)
	return { Instance = f, Destroy = function() f:Destroy() end }
end

-- Button ------------------------------------------------------------
function Elements:AddButton(cfg)
	cfg = cfg or {}
	local card = self:_card(68, nil, "TextButton")
	local _, t, d = Header(card, title(cfg), cfg.Description, 60)
	local ic = MakeIcon(card, 34, Color3.fromRGB(214, 214, 214), cfg.Icon or "cursor")
	if ic then
		ic.AnchorPoint = Vector2.new(1, 0.5)
		ic.Position = UDim2.new(1, 0, 0.5, 0)
	end
	local base = card.BackgroundColor3
	card.MouseEnter:Connect(function() tween(card, 0.12, { BackgroundColor3 = lighten(base, 0.05) }) end)
	card.MouseLeave:Connect(function() tween(card, 0.12, { BackgroundColor3 = base }) end)
	card.MouseButton1Down:Connect(function() tween(card, 0.08, { BackgroundColor3 = lighten(base, 0.1) }) end)
	card.MouseButton1Up:Connect(function() tween(card, 0.12, { BackgroundColor3 = lighten(base, 0.05) }) end)
	card.MouseButton1Click:Connect(function() safe(cfg.Callback) end)
	return BaseObj(card, t, d)
end

-- Textbox -----------------------------------------------------------
function Elements:AddTextbox(cfg)
	cfg = cfg or {}
	local card = self:_card(64)
	local _, t, d = Header(card, title(cfg), cfg.Description, 150)
	local box = Frame({
		BackgroundColor3 = Theme.Input, AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(134, 34), Parent = card,
	})
	Corner(box, 6)
	local st = Stroke(box, Theme.Accent, 1, 1)
	local tb = Create("TextBox", {
		BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = cfg.Default or "",
		PlaceholderText = cfg.Placeholder or "Your text...", PlaceholderColor3 = Color3.fromRGB(112, 112, 112),
		TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 15,
		ClearTextOnFocus = cfg.ClearOnFocus == true, TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Center, Parent = box,
	})
	Padding(tb, 0, 8, 0, 8)
	if cfg.Numeric then
		tb:GetPropertyChangedSignal("Text"):Connect(function()
			local f = tb.Text:gsub("[^%d%.%-]", "")
			if f ~= tb.Text then tb.Text = f end
		end)
	end
	tb.Focused:Connect(function() tween(st, 0.15, { Transparency = 0.2 }) end)
	tb.FocusLost:Connect(function(enter)
		tween(st, 0.15, { Transparency = 1 })
		if cfg.Flag then Library.Flags[cfg.Flag] = tb.Text end
		safe(cfg.Callback, tb.Text, enter)
	end)
	local obj = BaseObj(card, t, d)
	function obj:Set(s) tb.Text = tostring(s) end
	function obj:Get() return tb.Text end
	return obj
end

-- Slider ------------------------------------------------------------
function Elements:AddSlider(cfg)
	cfg = cfg or {}
	local min, max = cfg.Min or 0, cfg.Max or 100
	local inc = cfg.Increment or 1
	local suffix = cfg.Suffix or ""
	local card = self:_card(64, 8)
	local wrap, t, d = Header(card, title(cfg), cfg.Description, 70)
	local valueLbl = Text({
		Font = Enum.Font.GothamBold, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Right,
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(70, 20), Parent = wrap,
	})
	local track = Frame({
		BackgroundColor3 = Theme.Track, Size = UDim2.new(1, 0, 0, 30),
		ClipsDescendants = true, LayoutOrder = 2, Parent = card,
	})
	Corner(track, 6)
	local fill = Frame({ BackgroundColor3 = Theme.Fill, Size = UDim2.fromScale(0, 1), Parent = track })
	Corner(fill, 6)

	local obj = BaseObj(card, t, d)
	function obj:Set(v, silent)
		v = math.clamp(math.floor((v - min) / inc + 0.5) * inc + min, min, max)
		obj.Value = v
		valueLbl.Text = fmt(v) .. suffix
		tween(fill, 0.08, { Size = UDim2.fromScale((v - min) / (max - min), 1) })
		if cfg.Flag then Library.Flags[cfg.Flag] = v end
		if not silent then safe(cfg.Callback, v) end
	end
	function obj:Get() return obj.Value end

	local dragging = false
	local function update(x)
		local a = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		obj:Set(min + (max - min) * a)
	end
	track.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			self:_setScroll(false)
			update(i.Position.X)
		end
	end)
	local c1 = UserInputService.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			update(i.Position.X)
		end
	end)
	local c2 = UserInputService.InputEnded:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
			dragging = false
			self:_setScroll(true)
		end
	end)
	if self._win then table.insert(self._win._conns, c1); table.insert(self._win._conns, c2) end
	obj:Set(cfg.Default or min, true)
	return obj
end

-- Toggle ------------------------------------------------------------
function Elements:AddToggle(cfg)
	cfg = cfg or {}
	local card = self:_card(64, nil, "TextButton")
	local _, t, d = Header(card, title(cfg), cfg.Description, 80)
	local sw = Frame({
		BackgroundColor3 = Theme.Track, AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(48, 26), Parent = card,
	})
	Round(sw)
	local knob = Frame({
		BackgroundColor3 = Theme.Text, AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 4, 0.5, 0), Size = UDim2.fromOffset(18, 18), Parent = sw,
	})
	Round(knob)
	local obj = BaseObj(card, t, d)
	function obj:Set(v, silent)
		obj.Value = v and true or false
		tween(sw, 0.15, { BackgroundColor3 = obj.Value and Theme.Accent or Theme.Track })
		tween(knob, 0.15, { Position = obj.Value and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 4, 0.5, 0) })
		if cfg.Flag then Library.Flags[cfg.Flag] = obj.Value end
		if not silent then safe(cfg.Callback, obj.Value) end
	end
	function obj:Get() return obj.Value end
	local base = card.BackgroundColor3
	card.MouseEnter:Connect(function() tween(card, 0.12, { BackgroundColor3 = lighten(base, 0.04) }) end)
	card.MouseLeave:Connect(function() tween(card, 0.12, { BackgroundColor3 = base }) end)
	card.MouseButton1Click:Connect(function() obj:Set(not obj.Value) end)
	obj:Set(cfg.Default == true, true)
	return obj
end

-- Dropdown ----------------------------------------------------------
function Elements:AddDropdown(cfg)
	cfg = cfg or {}
	local options = cfg.Options or {}
	local card = self:_card(64, 0)
	local wrap, t, d = Header(card, title(cfg), cfg.Description, 150)
	local box = Button({
		BackgroundTransparency = 0, BackgroundColor3 = Theme.Input, AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(134, 34), Parent = wrap,
	})
	Corner(box, 6)
	local valLbl = Text({
		TextSize = 15, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -34, 1, 0),
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = box,
	})
	local chev = MakeIcon(box, 16, Theme.SubText, "chevron")
	chev.AnchorPoint = Vector2.new(0.5, 0.5)
	chev.Position = UDim2.new(1, -15, 0.5, 0)
	local holder = Frame({
		BackgroundTransparency = 1, ClipsDescendants = true, Size = UDim2.new(1, 0, 0, 0),
		LayoutOrder = 2, Parent = card,
	})
	Padding(holder, 8, 0, 0, 0)
	List(holder, 4)

	local open = false
	local buttons = {}
	local obj = BaseObj(card, t, d)

	local function openHeight()
		if #options == 0 then return 0 end
		return #options * 30 + (#options - 1) * 4 + 8
	end
	local function setOpen(v)
		open = v
		tween(holder, 0.2, { Size = UDim2.new(1, 0, 0, v and openHeight() or 0) })
		tween(chev, 0.2, { Rotation = v and 180 or 0 })
	end
	local function highlight()
		for _, b in ipairs(buttons) do
			local sel = b.Name == tostring(obj.Value)
			b.BackgroundColor3 = sel and Theme.Fill or Theme.Input
			b.TextColor3 = sel and Theme.Text or Theme.SubText
		end
	end
	function obj:Set(v, silent)
		obj.Value = v
		valLbl.Text = v ~= nil and tostring(v) or (cfg.Placeholder or "Select...")
		highlight()
		if cfg.Flag then Library.Flags[cfg.Flag] = v end
		if not silent then safe(cfg.Callback, v) end
	end
	function obj:Get() return obj.Value end
	function obj:Refresh(newOptions)
		options = newOptions or {}
		for _, b in ipairs(buttons) do b:Destroy() end
		buttons = {}
		for i, opt in ipairs(options) do
			local b = Button({
				Name = tostring(opt), BackgroundTransparency = 0, BackgroundColor3 = Theme.Input,
				Size = UDim2.new(1, 0, 0, 30), LayoutOrder = i, Text = tostring(opt),
				Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Theme.SubText, Parent = holder,
			})
			Corner(b, 6)
			b.MouseButton1Click:Connect(function() obj:Set(opt); setOpen(false) end)
			table.insert(buttons, b)
		end
		highlight()
		if open then setOpen(true) end
	end
	box.MouseButton1Click:Connect(function() setOpen(not open) end)
	obj:Refresh(options)
	obj:Set(cfg.Default, true)
	return obj
end

-- Section (พับได้) --------------------------------------------------
local Section = {}
Section.__index = Section
for k, v in pairs(Elements) do Section[k] = v end

local function Collapsible(holder, layout, chevron, extra, open)
	local s = { Open = open }
	local function size() return UDim2.new(1, 0, 0, s.Open and (layout.AbsoluteContentSize.Y + extra) or 0) end
	chevron.Rotation = open and 0 or -90
	holder.Size = size()
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() holder.Size = size() end)
	function s.Set(v)
		s.Open = v
		tween(holder, 0.22, { Size = size() })
		tween(chevron, 0.22, { Rotation = v and 0 or -90 })
	end
	return s
end

function Elements:AddSection(cfg)
	if type(cfg) == "string" then cfg = { Title = cfg } end
	cfg = cfg or {}
	local card = Frame({
		BackgroundColor3 = self._nested and Theme.CardInner or Theme.Card, Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = self:_order(), Parent = self._parent,
	})
	Corner(card, 8)
	List(card, 0)
	local head = Button({ Size = UDim2.new(1, 0, 0, 40), LayoutOrder = 1, Parent = card })
	Text({
		Text = title(cfg), Font = Enum.Font.GothamBold, TextSize = 17,
		Position = UDim2.fromOffset(9, 0), Size = UDim2.new(1, -50, 1, 0), Parent = head,
	})
	local chev = MakeIcon(head, 22, Theme.Text, "chevron")
	chev.AnchorPoint = Vector2.new(0.5, 0.5)
	chev.Position = UDim2.new(1, -24, 0.5, 0)
	local body = Frame({
		BackgroundTransparency = 1, ClipsDescendants = true, Size = UDim2.new(1, 0, 0, 0),
		LayoutOrder = 2, Parent = card,
	})
	Padding(body, 0, 11, 0, 11)
	local layout = List(body, 10)
	local col = Collapsible(body, layout, chev, 13, cfg.Open ~= false)
	head.MouseButton1Click:Connect(function() col.Set(not col.Open) end)
	return setmetatable({
		_parent = body, _nested = true, _scroller = self._scroller, _win = self._win,
		_n = 0, Collapse = col, Instance = card,
	}, Section)
end

function Section:SetOpen(v) self.Collapse.Set(v) end
function Section:Destroy() self.Instance:Destroy() end

--========================================================
-- Tab class
--========================================================
local Tab = {}
Tab.__index = Tab
for k, v in pairs(Elements) do Tab[k] = v end
function Tab:Select() self._win:SelectTab(self) end

--========================================================
-- Window
--========================================================
function Library:CreateWindow(cfg)
	cfg = cfg or {}
	local gui = self:_getGui()
	local size = cfg.Size or UDim2.fromOffset(742, 565)
	local Window = { Tabs = {}, _conns = {}, Selected = nil }
	local TOP = 62
	local minimized, maximized = false, false
	local savedPos

	local Root = Frame({
		Name = "HawkWindow", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = size, BackgroundColor3 = Theme.Window, ClipsDescendants = true, Parent = gui,
	})
	Corner(Root, 10)
	Stroke(Root, Theme.Stroke, 1, 0.2)
	local Scale = Create("UIScale", { Parent = Root })
	local function updateScale()
		local vp = gui.AbsoluteSize
		if vp.X <= 0 then return end
		Scale.Scale = math.max(0.4, math.min(1, (vp.X - 24) / size.X.Offset, (vp.Y - 24) / size.Y.Offset))
	end
	updateScale()
	table.insert(Window._conns, gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateScale))

	-- Topbar -------------------------------------------------------
	local Top = Frame({ Name = "Topbar", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, TOP), Parent = Root })
	local TitleLbl = Text({
		Text = cfg.Title or "Hawk Lib", TextSize = 18,
		Position = UDim2.fromOffset(17, -3), Size = UDim2.new(1, -200, 1, 0), Parent = Top,
	})

	local function control(icon, px, fromRight, cb)
		local b = Button({
			BackgroundColor3 = Color3.new(1, 1, 1), AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(1, -fromRight, 0, 31), Size = UDim2.fromOffset(36, 36), Parent = Top,
		})
		Corner(b, 8)
		local ic = MakeIcon(b, px, Theme.Text, icon)
		ic.AnchorPoint = Vector2.new(0.5, 0.5)
		ic.Position = UDim2.fromScale(0.5, 0.5)
		b.MouseEnter:Connect(function() tween(b, 0.12, { BackgroundTransparency = 0.92 }) end)
		b.MouseLeave:Connect(function() tween(b, 0.12, { BackgroundTransparency = 1 }) end)
		b.MouseButton1Click:Connect(cb)
		return b
	end

	local Body = Frame({
		Name = "Body", BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, TOP), Size = UDim2.new(1, 0, 1, -TOP), Parent = Root,
	})

	local function fullSize()
		if maximized then
			local vp, s = gui.AbsoluteSize, Scale.Scale
			return UDim2.fromOffset(vp.X / s - 24, vp.Y / s - 24)
		end
		return size
	end

	function Window:Minimize()
		minimized = not minimized
		local fs = fullSize()
		if minimized then
			tween(Root, 0.25, { Size = UDim2.new(fs.X.Scale, fs.X.Offset, 0, TOP) })
			task.delay(0.25, function() if minimized then Body.Visible = false end end)
		else
			Body.Visible = true
			tween(Root, 0.25, { Size = fs })
		end
	end
	function Window:Maximize()
		if minimized then return end
		maximized = not maximized
		if maximized then
			savedPos = Root.Position
			tween(Root, 0.25, { Size = fullSize(), Position = UDim2.fromScale(0.5, 0.5) })
		else
			tween(Root, 0.25, { Size = size, Position = savedPos or UDim2.fromScale(0.5, 0.5) })
		end
	end
	function Window:Toggle() Root.Visible = not Root.Visible end
	function Window:SetTitle(s) TitleLbl.Text = s end
	function Window:Destroy()
		for _, c in ipairs(Window._conns) do pcall(function() c:Disconnect() end) end
		Root:Destroy()
		for i, w in ipairs(Library.Windows) do if w == Window then table.remove(Library.Windows, i) break end end
		safe(cfg.OnClose)
	end

	control("minus", 24, 126, function() Window:Minimize() end)
	control("maximize", 24, 79, function() Window:Maximize() end)
	control("close", 24, 32, function() Window:Destroy() end)

	-- Drag ---------------------------------------------------------
	local dragging, dragStart, startPos = false, nil, nil
	Top.InputBegan:Connect(function(i)
		if maximized then return end
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging, dragStart, startPos = true, i.Position, Root.Position
		end
	end)
	table.insert(Window._conns, UserInputService.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - dragStart
			local s = Scale.Scale
			Root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X / s, startPos.Y.Scale, startPos.Y.Offset + d.Y / s)
		end
	end))
	table.insert(Window._conns, UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
	end))

	local toggleKey = cfg.ToggleKey
	if toggleKey == nil then toggleKey = Enum.KeyCode.RightShift end
	if toggleKey then
		table.insert(Window._conns, UserInputService.InputBegan:Connect(function(i, gpe)
			if not gpe and i.KeyCode == toggleKey then Window:Toggle() end
		end))
	end

	-- Sidebar + Content -------------------------------------------
	local Sidebar = Frame({ BackgroundTransparency = 1, Size = UDim2.new(0, 215, 1, 0), Parent = Body })
	local SideScroll = Create("ScrollingFrame", {
		BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 0, Parent = Sidebar,
	})
	Padding(SideScroll, 1, 16, 12, 22)
	List(SideScroll, 9)

	local Content = Frame({
		BackgroundColor3 = Theme.Content, Position = UDim2.fromOffset(215, 0),
		Size = UDim2.new(1, -215, 1, 0), Parent = Body,
	})
	Corner(Content, 10)
	for _, p in ipairs({
		{ UDim2.fromOffset(0, 0), Vector2.new(0, 0) },
		{ UDim2.new(1, 0, 0, 0), Vector2.new(1, 0) },
		{ UDim2.new(0, 0, 1, 0), Vector2.new(0, 1) },
	}) do
		Frame({
			BackgroundColor3 = Theme.Content, Position = p[1], AnchorPoint = p[2],
			Size = UDim2.fromOffset(12, 12), ZIndex = 5, Parent = Content,
		})
	end

	local sideOrder = 0
	local function nextSide() sideOrder += 1 return sideOrder end

	local function newPage()
		local page = Create("ScrollingFrame", {
			Name = "Page", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
			CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 3, ScrollBarImageColor3 = Color3.fromRGB(95, 95, 95),
			ScrollingDirection = Enum.ScrollingDirection.Y, Visible = false, Parent = Content,
		})
		Padding(page, 12, 21, 14, 19)
		List(page, 10)
		return page
	end

	local function newTabButton(parent, name, icon, sub)
		local btn = Button({
			BackgroundColor3 = Theme.TabSelected, Size = UDim2.new(1, 0, 0, sub and 38 or 40),
			LayoutOrder = nextSide(), Parent = parent,
		})
		Corner(btn, 8)
		local bar = Frame({
			BackgroundColor3 = Theme.Accent, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 1, 0.5, 0), Size = UDim2.fromOffset(4, 20), Parent = btn,
		})
		Round(bar)
		local x = 12
		if icon then
			local ic = MakeIcon(btn, 18, Theme.Text, icon)
			if ic then
				ic.AnchorPoint = Vector2.new(0, 0.5)
				ic.Position = UDim2.new(0, 13, 0.5, 0)
				x = 41
			end
		end
		local lbl = Text({
			Text = name, Font = Enum.Font.GothamMedium, TextSize = sub and 15 or 16,
			TextColor3 = Color3.fromRGB(215, 215, 215), Position = UDim2.fromOffset(x, 0),
			Size = UDim2.new(1, -x - 6, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, Parent = btn,
		})
		local selected = false
		local api = { Button = btn }
		function api.SetSelected(v)
			selected = v
			tween(btn, 0.15, { BackgroundTransparency = v and 0 or 1 })
			tween(bar, 0.15, { BackgroundTransparency = v and 0 or 1 })
			tween(lbl, 0.15, { TextColor3 = v and Theme.Text or Color3.fromRGB(215, 215, 215) })
		end
		btn.MouseEnter:Connect(function() if not selected then tween(btn, 0.1, { BackgroundTransparency = 0.75 }) end end)
		btn.MouseLeave:Connect(function() if not selected then tween(btn, 0.1, { BackgroundTransparency = 1 }) end end)
		return api
	end

	function Window:SelectTab(tab)
		if Window.Selected == tab then return end
		local old = Window.Selected
		if old then
			old.Page.Visible = false
			for _, b in ipairs(old.Buttons) do b.SetSelected(false) end
		end
		Window.Selected = tab
		tab.Page.Position = UDim2.fromOffset(0, 10)
		tab.Page.Visible = true
		tween(tab.Page, 0.2, { Position = UDim2.fromOffset(0, 0) })
		for _, b in ipairs(tab.Buttons) do b.SetSelected(true) end
	end

	local function makeTab(parent, c, sub)
		c = c or {}
		local tab = c.Link
		if not tab then
			local page = newPage()
			tab = setmetatable({
				Name = c.Name, Page = page, Buttons = {}, _parent = page, _nested = false,
				_scroller = page, _win = Window, _n = 0,
			}, Tab)
			table.insert(Window.Tabs, tab)
		end
		local b = newTabButton(parent, c.Name or tab.Name or "Tab", c.Icon, sub)
		b.Button.MouseButton1Click:Connect(function() Window:SelectTab(tab) end)
		table.insert(tab.Buttons, b)
		if not Window.Selected then Window:SelectTab(tab) elseif Window.Selected == tab then b.SetSelected(true) end
		return tab
	end

	function Window:AddTab(c) return makeTab(SideScroll, c, false) end

	function Window:AddTabGroup(c)
		c = c or {}
		local holder = Frame({
			BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextSide(), Parent = SideScroll,
		})
		List(holder, 0)
		local header = Button({ Size = UDim2.new(1, 0, 0, 38), LayoutOrder = 1, Parent = holder })
		Text({
			Text = c.Name or "Group", Font = Enum.Font.GothamBold, TextSize = 20,
			Position = UDim2.fromOffset(5, 0), Size = UDim2.new(1, -40, 1, 0), Parent = header,
		})
		local chev = MakeIcon(header, 22, Theme.Text, "chevron")
		chev.AnchorPoint = Vector2.new(0.5, 0.5)
		chev.Position = UDim2.new(1, -13, 0.5, 0)
		local items = Frame({
			BackgroundTransparency = 1, ClipsDescendants = true, Size = UDim2.new(1, 0, 0, 0),
			LayoutOrder = 2, Parent = holder,
		})
		Padding(items, 0, 12, 0, 13)
		local layout = List(items, 8)
		local col = Collapsible(items, layout, chev, 0, c.Open ~= false)
		header.MouseButton1Click:Connect(function() col.Set(not col.Open) end)
		local group = { Collapse = col }
		function group:AddTab(tc) return makeTab(items, tc, true) end
		function group:SetOpen(v) col.Set(v) end
		return group
	end

	Window.Root = Root
	table.insert(Library.Windows, Window)
	return Window
end

--========================================================
-- Notifications (Notify / Notification / Timer)
--========================================================
local function getLayer(self, side)
	local gui = self:_getGui()
	local key = side == "left" and "_leftLayer" or "_rightLayer"
	if self[key] and self[key].Parent then return self[key] end
	local layer = Frame({ Name = "Notify_" .. side, BackgroundTransparency = 1, ZIndex = 50, Parent = gui })
	if side == "left" then
		layer.AnchorPoint = Vector2.new(0, 1)
		layer.Position = UDim2.new(0, 32, 1, -33)
	else
		layer.AnchorPoint = Vector2.new(1, 1)
		layer.Position = UDim2.new(1, -26, 1, -34)
	end
	layer.Size = UDim2.new(0, 360, 1, -60)
	Create("UIListLayout", {
		Padding = UDim.new(0, 15), SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Vertical, VerticalAlignment = Enum.VerticalAlignment.Bottom,
		HorizontalAlignment = side == "left" and Enum.HorizontalAlignment.Left or Enum.HorizontalAlignment.Right,
		Parent = layer,
	})
	local sc = Create("UIScale", { Parent = layer })
	local function upd() sc.Scale = math.clamp(gui.AbsoluteSize.X / 900, 0.6, 1) end
	upd()
	gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(upd)
	self[key] = layer
	return layer
end

function Library:_notify(kind, cfg)
	cfg = cfg or {}
	local side = (kind == "notify") and "left" or "right"
	local layer = getLayer(self, side)
	self._nOrder = (self._nOrder or 0) + 1
	local H = ({ notify = 78, notification = 79, timer = 76 })[kind]
	local dir = side == "left" and -1 or 1

	local wrap = Frame({ BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, H), LayoutOrder = self._nOrder, Parent = layer })
	local card = Frame({
		BackgroundColor3 = Theme.Notify, Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(dir * 1.3, 0), ClipsDescendants = true, Parent = wrap,
	})
	Corner(card, 9)
	Stroke(card, Theme.Stroke, 1, 0.35)

	local dead = false
	local function dismiss()
		if dead then return end
		dead = true
		tween(card, 0.25, { Position = UDim2.fromScale(dir * 1.3, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		task.delay(0.25, function()
			tween(wrap, 0.2, { Size = UDim2.new(1, 0, 0, 0) })
			task.delay(0.2, function() wrap:Destroy() end)
		end)
	end

	local titleX = (kind == "timer") and 14 or 77
	if kind ~= "timer" then
		local box = Frame({
			BackgroundColor3 = Theme.Purple, Position = UDim2.fromOffset(13, 13),
			Size = UDim2.fromOffset(52, 52), Parent = card,
		})
		Corner(box, 8)
		local ic = MakeIcon(box, 28, Color3.new(1, 1, 1), cfg.Icon or "bell")
		if ic then
			ic.AnchorPoint = Vector2.new(0.5, 0.5)
			ic.Position = UDim2.fromScale(0.5, 0.5)
		end
	end
	local rightPad = (kind == "notify") and 66 or 14
	Text({
		Text = cfg.Title or "", Font = Enum.Font.GothamBold, TextSize = 16,
		Position = UDim2.fromOffset(titleX, kind == "timer" and 13 or 19),
		Size = UDim2.new(1, -(titleX + rightPad), 0, 22), TextTruncate = Enum.TextTruncate.AtEnd, Parent = card,
	})
	Text({
		Text = cfg.Content or cfg.Description or "", TextSize = 15, TextColor3 = Color3.fromRGB(205, 205, 205),
		Position = UDim2.fromOffset(titleX, kind == "timer" and 35 or 43),
		Size = UDim2.new(1, -(titleX + rightPad), 0, 20), TextTruncate = Enum.TextTruncate.AtEnd, Parent = card,
	})

	if kind == "notify" then
		local function iconBtn(name, px, y, cb)
			local b = Button({
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -29, 0, y),
				Size = UDim2.fromOffset(32, 26), Parent = card,
			})
			local ic = MakeIcon(b, px, Theme.Text, name)
			ic.AnchorPoint = Vector2.new(0.5, 0.5)
			ic.Position = UDim2.fromScale(0.5, 0.5)
			b.MouseEnter:Connect(function() TintIcon(ic, Theme.SubText) end)
			b.MouseLeave:Connect(function() TintIcon(ic, Theme.Text) end)
			b.MouseButton1Click:Connect(cb)
		end
		iconBtn("check", 26, 26, function() safe(cfg.Callback, true); dismiss() end)
		iconBtn("close", 22, 53, function() safe(cfg.OnCancel, false); dismiss() end)
	end

	local duration = cfg.Duration
	if duration == nil and kind ~= "notify" then duration = 5 end
	if kind == "timer" then
		local bar = Frame({
			BackgroundColor3 = Color3.new(1, 1, 1), Position = UDim2.new(0, 2, 1, -8),
			Size = UDim2.new(1, -4, 0, 6), Parent = card,
		})
		Corner(bar, 3)
		tween(bar, duration, { Size = UDim2.new(0, 0, 0, 6) }, Enum.EasingStyle.Linear)
	end

	tween(card, 0.35, { Position = UDim2.fromScale(0, 0) }, Enum.EasingStyle.Quint)
	if duration then task.delay(duration, dismiss) end
	return { Dismiss = dismiss, Instance = card }
end

-- ปุ่ม ✓ / ✕ ซ้ายล่าง  (Callback = กด ✓, OnCancel = กด ✕)
function Library:Notify(cfg) return self:_notify("notify", cfg) end
-- การ์ดมีไอคอนระฆัง ขวาล่าง
function Library:Notification(cfg) return self:_notify("notification", cfg) end
-- การ์ดไม่มีไอคอน + แถบเวลานับถอยหลัง ขวาล่าง
function Library:Timer(cfg) return self:_notify("timer", cfg) end

function Library:Destroy()
	for _, w in ipairs({ table.unpack(self.Windows) }) do w:Destroy() end
	if self.Gui then self.Gui:Destroy() end
	self.Gui, self._leftLayer, self._rightLayer = nil, nil, nil
end

return Library
