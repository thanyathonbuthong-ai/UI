--[[
    BlushUI Library  —  Roblox UI Library (clone of the "blush." menu)
    - Sidebar (sections / tabs / sub-tabs), breadcrumb header, header buttons + badge
    - Cards (collapsible), Checkbox (+keybind, +badge), Slider, Dropdown, Button, Label, Tab card
    - Notifications, Stats bar (fps / ping / time), draggable, auto UIScale for phones
    - All icons are drawn with Frames (no asset ids needed). Custom: Library:RegisterIcon / "rbxassetid://..."
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local Library = { Flags = {}, Options = {}, Windows = {}, Theme = {}, _conns = {}, _guis = {} }

-- ───────────────────────── Theme ─────────────────────────
local Theme = Library.Theme
Theme.Sidebar      = Color3.fromRGB(10, 10, 10)
Theme.Content      = Color3.fromRGB(13, 13, 13)
Theme.Card         = Color3.fromRGB(26, 26, 26)
Theme.CardAlpha    = 0.25
Theme.Control      = Color3.fromRGB(32, 32, 32)
Theme.ControlHover = Color3.fromRGB(44, 44, 44)
Theme.Button       = Color3.fromRGB(12, 12, 12)
Theme.Box          = Color3.fromRGB(40, 40, 40)
Theme.BoxDisabled  = Color3.fromRGB(30, 30, 30)
Theme.Track        = Color3.fromRGB(55, 55, 55)
Theme.Accent       = Color3.fromRGB(255, 255, 255)
Theme.Text         = Color3.fromRGB(255, 255, 255)
Theme.TextDim      = Color3.fromRGB(190, 190, 190)
Theme.NavInactive  = Color3.fromRGB(190, 190, 190)
Theme.SubText      = Color3.fromRGB(160, 160, 160)
Theme.Muted        = Color3.fromRGB(125, 125, 125)
Theme.Disabled     = Color3.fromRGB(72, 72, 72)
Theme.Danger       = Color3.fromRGB(255, 69, 69)
Theme.Line         = Color3.fromRGB(48, 48, 48)

-- ───────────────────────── Fonts ─────────────────────────
local function MakeFont(weight)
	local ok, f = pcall(function()
		return Font.new(Font.fromEnum(Enum.Font.Roboto).Family, weight)
	end)
	return ok and f or Font.fromEnum(Enum.Font.Roboto)
end
local F = {
	Regular = MakeFont(Enum.FontWeight.Regular),
	Medium = MakeFont(Enum.FontWeight.Medium),
	SemiBold = MakeFont(Enum.FontWeight.SemiBold),
	Bold = MakeFont(Enum.FontWeight.Bold),
}

-- ───────────────────────── Helpers ─────────────────────────
local AS_X, AS_Y = Enum.AutomaticSize.X, Enum.AutomaticSize.Y
local HORIZ, VERT = Enum.FillDirection.Horizontal, Enum.FillDirection.Vertical

local Defaults = {
	Frame = { BorderSizePixel = 0 },
	TextLabel = { BackgroundTransparency = 1, BorderSizePixel = 0, FontFace = F.Regular, TextSize = 13, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left },
	TextButton = { BackgroundTransparency = 1, BorderSizePixel = 0, AutoButtonColor = false, FontFace = F.Regular, TextSize = 13, TextColor3 = Theme.Text, Text = "" },
	ImageLabel = { BackgroundTransparency = 1, BorderSizePixel = 0 },
	ScrollingFrame = { BackgroundTransparency = 1, BorderSizePixel = 0 },
}

local function Create(class, props, children)
	local inst = Instance.new(class)
	for k, v in pairs(Defaults[class] or {}) do inst[k] = v end
	local parent
	for k, v in pairs(props or {}) do
		if k == "Parent" then parent = v else inst[k] = v end
	end
	for _, c in ipairs(children or {}) do c.Parent = inst end
	inst.Parent = parent
	return inst
end

local function Corner(r) return Create("UICorner", { CornerRadius = UDim.new(0, r) }) end
local function Round() return Create("UICorner", { CornerRadius = UDim.new(1, 0) }) end
local function Stroke(color, th, tr)
	return Create("UIStroke", { Color = color, Thickness = th or 1, Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
end
local function List(pad, dir, ha, va)
	return Create("UIListLayout", {
		Padding = UDim.new(0, pad or 0), FillDirection = dir or VERT,
		HorizontalAlignment = ha or Enum.HorizontalAlignment.Left,
		VerticalAlignment = va or Enum.VerticalAlignment.Top,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
end
local function Pad(t, r, b, l)
	return Create("UIPadding", { PaddingTop = UDim.new(0, t or 0), PaddingRight = UDim.new(0, r or 0), PaddingBottom = UDim.new(0, b or 0), PaddingLeft = UDim.new(0, l or 0) })
end

local Counters = setmetatable({}, { __mode = "k" })
local function Order(c)
	Counters[c] = (Counters[c] or 0) + 1
	return Counters[c]
end

local function Tween(inst, props, time, style)
	local t = TweenService:Create(inst, TweenInfo.new(time or 0.15, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local function Connect(signal, fn)
	local c = signal:Connect(fn)
	table.insert(Library._conns, c)
	return c
end

local function NewGui(name)
	local gui = Create("ScreenGui", { Name = name, ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999 })
	pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
	local parent
	pcall(function() if gethui then parent = gethui() end end)
	if not parent then
		local ok = pcall(function() gui.Parent = CoreGui end)
		if ok and gui.Parent == CoreGui then parent = CoreGui end
	end
	gui.Parent = parent or LocalPlayer:WaitForChild("PlayerGui")
	table.insert(Library._guis, gui)
	return gui
end

local function SetAvatar(img, v)
	if type(v) == "string" then img.Image = v return end
	task.spawn(function()
		local ok, content = pcall(function()
			return Players:GetUserThumbnailAsync(v or LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		end)
		if ok then img.Image = content end
	end)
end

-- ───────────────────────── Icons (drawn with Frames) ─────────────────────────
local IconDraw = {}

local function BuildIcon(drawFn, size, color, parent, units)
	local root = Create("Frame", { Name = "Icon", BackgroundTransparency = 1, Size = UDim2.fromOffset(size, size), Parent = parent })
	local k = size / 24
	local parts = {}
	local d = {}
	local function th(t) return math.max(1, (t or units) * k) end

	function d.line(x1, y1, x2, y2, t)
		local w = th(t)
		local dx, dy = (x2 - x1) * k, (y2 - y1) * k
		local len = math.sqrt(dx * dx + dy * dy)
		local f = Create("Frame", {
			BackgroundColor3 = color, AnchorPoint = Vector2.new(.5, .5),
			Position = UDim2.fromOffset((x1 + x2) / 2 * k, (y1 + y2) / 2 * k),
			Size = UDim2.fromOffset(len + w, w), Rotation = math.deg(math.atan2(dy, dx)), Parent = root,
		}, { Create("UICorner", { CornerRadius = UDim.new(.5, 0) }) })
		table.insert(parts, { f, "BackgroundColor3" })
	end
	function d.poly(pts, t)
		for i = 1, #pts - 1 do d.line(pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2], t) end
	end
	function d.ring(cx, cy, r, t, par)
		local f = Create("Frame", {
			BackgroundTransparency = 1, AnchorPoint = Vector2.new(.5, .5),
			Position = UDim2.fromOffset(cx * k, cy * k), Size = UDim2.fromOffset(r * 2 * k, r * 2 * k), Parent = par or root,
		}, { Round(), Create("UIStroke", { Color = color, Thickness = th(t), ApplyStrokeMode = Enum.ApplyStrokeMode.Border }) })
		table.insert(parts, { f:FindFirstChildOfClass("UIStroke"), "Color" })
	end
	function d.dot(cx, cy, r)
		local s = math.max(2 * r * k, 1.5)
		local f = Create("Frame", { BackgroundColor3 = color, AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromOffset(cx * k, cy * k), Size = UDim2.fromOffset(s, s), Parent = root }, { Round() })
		table.insert(parts, { f, "BackgroundColor3" })
	end
	function d.clip(x, y, w, h)
		return Create("Frame", { BackgroundTransparency = 1, ClipsDescendants = true, Position = UDim2.fromOffset(x * k, y * k), Size = UDim2.fromOffset(w * k, h * k), Parent = root })
	end

	drawFn(d)

	local obj = { Root = root }
	function obj.SetColor(c, t)
		for _, p in ipairs(parts) do
			if t then Tween(p[1], { [p[2]] = c }, t) else p[1][p[2]] = c end
		end
	end
	return obj
end

IconDraw["chevron-down"]  = function(d) d.poly({ { 6, 9 }, { 12, 15 }, { 18, 9 } }) end
IconDraw["chevron-right"] = function(d) d.poly({ { 9, 6 }, { 15, 12 }, { 9, 18 } }) end
IconDraw["check"]         = function(d) d.poly({ { 4, 12.5 }, { 9, 17.5 }, { 20, 6.5 } }) end
IconDraw["x"]             = function(d) d.line(18, 6, 6, 18) d.line(6, 6, 18, 18) end
IconDraw["search"]        = function(d) d.ring(11, 11, 8) d.line(21, 21, 16.7, 16.7) end
IconDraw["circle"]        = function(d) d.ring(12, 12, 10) end
IconDraw["info"]          = function(d) d.ring(12, 12, 10) d.line(12, 16, 12, 12) d.dot(12, 8, 1.1) end
IconDraw["circle-check"]  = function(d) d.ring(12, 12, 10) d.poly({ { 8, 12 }, { 11, 15 }, { 16, 9 } }) end
IconDraw["circle-x"]      = function(d) d.ring(12, 12, 10) d.line(15, 9, 9, 15) d.line(9, 9, 15, 15) end
IconDraw["triangle-alert"] = function(d)
	d.poly({ { 12, 3.5 }, { 22, 20 }, { 2, 20 }, { 12, 3.5 } })
	d.line(12, 9.5, 12, 13.5) d.dot(12, 17, 1)
end
IconDraw["home"] = function(d)
	d.poly({ { 3, 19 }, { 3, 10 }, { 12, 3 }, { 21, 10 }, { 21, 19 }, { 19, 21 }, { 5, 21 }, { 3, 19 } })
	d.poly({ { 9, 21 }, { 9, 13 }, { 10, 12 }, { 14, 12 }, { 15, 13 }, { 15, 21 } })
end
IconDraw["house"] = IconDraw["home"]
IconDraw["crosshair"] = function(d)
	d.ring(12, 12, 10)
	d.line(22, 12, 18, 12) d.line(6, 12, 2, 12) d.line(12, 6, 12, 2) d.line(12, 22, 12, 18)
end
IconDraw["target"] = function(d) d.ring(12, 12, 10) d.ring(12, 12, 6) d.ring(12, 12, 2) end
IconDraw["eye"] = function(d)
	d.poly({ { 2, 12 }, { 4.5, 8.8 }, { 8, 6.4 }, { 12, 5.5 }, { 16, 6.4 }, { 19.5, 8.8 }, { 22, 12 },
		{ 19.5, 15.2 }, { 16, 17.6 }, { 12, 18.5 }, { 8, 17.6 }, { 4.5, 15.2 }, { 2, 12 } })
	d.ring(12, 12, 3)
end
IconDraw["sparkles"] = function(d)
	d.poly({ { 12, 2.4 }, { 14.3, 9.7 }, { 21.6, 12 }, { 14.3, 14.3 }, { 12, 21.6 }, { 9.7, 14.3 }, { 2.4, 12 }, { 9.7, 9.7 }, { 12, 2.4 } })
	d.line(20, 3, 20, 7) d.line(22, 5, 18, 5) d.line(4, 17, 4, 19) d.line(5, 18, 3, 18)
end
IconDraw["sprout"] = function(d)
	d.line(7, 20, 17, 20)
	d.poly({ { 10, 20 }, { 13, 17 }, { 13.6, 14 }, { 13, 10 } })
	d.poly({ { 9.5, 9.4 }, { 11.8, 13.1 }, { 7, 12.8 }, { 4, 8.6 }, { 9.5, 9.4 } })
	d.poly({ { 14.1, 6 }, { 13, 10 }, { 17.3, 8.6 }, { 19, 4 }, { 14.1, 6 } })
end
IconDraw["settings"] = function(d)
	d.ring(12, 12, 3)
	d.ring(12, 12, 6.6)
	for i = 0, 7 do
		local a = math.rad(i * 45)
		local c, s = math.cos(a), math.sin(a)
		d.line(12 + c * 7.6, 12 + s * 7.6, 12 + c * 9.6, 12 + s * 9.6, 3)
	end
end
IconDraw["bell"] = function(d)
	local clip = d.clip(0, 0, 24, 8)
	d.ring(12, 8, 6, nil, clip)
	d.poly({ { 6, 8 }, { 6, 11 }, { 5, 14 }, { 3, 17 }, { 21, 17 }, { 19, 14 }, { 18, 11 }, { 18, 8 } })
	d.poly({ { 10.3, 21 }, { 11.1, 21.9 }, { 12.9, 21.9 }, { 13.7, 21 } })
end
IconDraw["folder"] = function(d)
	d.poly({ { 2, 19 }, { 2, 5 }, { 4, 3 }, { 8, 3 }, { 10, 5 }, { 11, 6 }, { 20, 6 }, { 22, 8 }, { 22, 18 }, { 20, 20 }, { 4, 20 }, { 2, 18 } })
end

function Library:RegisterIcon(name, drawFn) IconDraw[name] = drawFn end

function Library:Icon(name, size, color, parent, units)
	size = size or 16
	color = color or Theme.Text
	local key = tostring(name or "")
	key = (key:gsub("^lucide[-:]", ""))
	if IconDraw[key] then
		return BuildIcon(IconDraw[key], size, color, parent, units or 2)
	elseif key:match("^rbxassetid://") or key:match("^%d+$") then
		local img = Create("ImageLabel", { Size = UDim2.fromOffset(size, size), Image = key:match("^%d+$") and ("rbxassetid://" .. key) or key, ImageColor3 = color, Parent = parent })
		return { Root = img, SetColor = function(c, t) if t then Tween(img, { ImageColor3 = c }, t) else img.ImageColor3 = c end end }
	end
	return BuildIcon(IconDraw["circle"], size, color, parent, units or 2)
end

-- ───────────────────────── Keybind helpers ─────────────────────────
local MouseNames = { MB1 = Enum.UserInputType.MouseButton1, MB2 = Enum.UserInputType.MouseButton2, MB3 = Enum.UserInputType.MouseButton3 }
local function KeyName(k)
	if k == nil then return "None" end
	if k == Enum.UserInputType.MouseButton1 then return "MB1" end
	if k == Enum.UserInputType.MouseButton2 then return "MB2" end
	if k == Enum.UserInputType.MouseButton3 then return "MB3" end
	return k.Name
end
local function ToKey(v)
	if typeof(v) == "EnumItem" then return v end
	if MouseNames[v] then return MouseNames[v] end
	local ok, k = pcall(function() return Enum.KeyCode[v] end)
	return ok and k or nil
end

local function Register(o, obj)
	if o.Flag then Library.Flags[o.Flag] = obj.Value; Library.Options[o.Flag] = obj end
end
local function Fire(o, obj)
	if o.Flag then Library.Flags[o.Flag] = obj.Value end
	if o.Callback then task.spawn(o.Callback, obj.Value) end
end

-- ───────────────────────── Elements ─────────────────────────
local Elements = {}
Elements.__index = Elements

function Elements:AddCheckbox(o)
	o = o or {}
	local Obj = { Type = "Checkbox", Value = false }
	local disabled = o.Disabled
	local Row = Create("Frame", { Name = o.Text or "Checkbox", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 23), LayoutOrder = Order(self.Body), Parent = self.Body })
	local Hit = Create("TextButton", { Size = UDim2.fromScale(1, 1), Parent = Row })
	local Box = Create("Frame", {
		BackgroundColor3 = disabled and Theme.BoxDisabled or Theme.Box, AnchorPoint = Vector2.new(0, .5),
		Position = UDim2.new(0, 0, .5, 0), Size = UDim2.fromOffset(17, 17), Parent = Row,
	}, { Corner(5) })
	local Check = Library:Icon("check", 11, Color3.fromRGB(10, 10, 10), Box, 3.2)
	Check.Root.AnchorPoint = Vector2.new(.5, .5)
	Check.Root.Position = UDim2.fromScale(.5, .5)
	Check.Root.Visible = false

	local Info = Create("Frame", { BackgroundTransparency = 1, Position = UDim2.new(0, 26, 0, 0), Size = UDim2.new(1, -26, 1, 0), Parent = Row },
		{ List(8, HORIZ, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) })
	Create("TextLabel", {
		Text = o.Text or "", TextColor3 = o.TextColor or (disabled and Theme.Disabled or Theme.Text),
		AutomaticSize = AS_X, Size = UDim2.new(0, 0, 1, 0), LayoutOrder = 1, Parent = Info,
	})
	if o.Badge then
		local B = Create("Frame", { BackgroundColor3 = Color3.fromRGB(14, 14, 14), AutomaticSize = AS_X, Size = UDim2.new(0, 0, 0, 17), LayoutOrder = 2, Parent = Info },
			{ Corner(6), Pad(0, 7, 0, 7) })
		Create("TextLabel", { Text = o.Badge, FontFace = F.Bold, TextSize = 9, AutomaticSize = AS_X, Size = UDim2.new(0, 0, 1, 0), Parent = B })
	end

	function Obj:SetValue(v, silent)
		v = v and true or false
		self.Value = v
		Tween(Box, { BackgroundColor3 = v and Theme.Accent or (disabled and Theme.BoxDisabled or Theme.Box) }, .12)
		Check.Root.Visible = v
		if silent then
			if o.Flag then Library.Flags[o.Flag] = v end
		else
			Fire(o, self)
		end
	end
	function Obj:SetVisible(v) Row.Visible = v end
	Obj.Root = Row

	if not disabled then
		Hit.MouseButton1Click:Connect(function() Obj:SetValue(not Obj.Value) end)
	end

	-- keybind (display + rebind + toggle/hold)
	if o.Keybind then
		Obj.Key = ToKey(o.Keybind)
		local KeyBtn = Create("TextButton", {
			Text = KeyName(Obj.Key), TextColor3 = Theme.SubText, TextSize = 12, AnchorPoint = Vector2.new(1, .5),
			Position = UDim2.new(1, 0, .5, 0), AutomaticSize = AS_X, Size = UDim2.new(0, 0, 1, 0), ZIndex = 3, Parent = Row,
		})
		KeyBtn.MouseButton1Click:Connect(function()
			KeyBtn.Text = "..."
			Obj._listening = true
			local con
			con = UserInputService.InputBegan:Connect(function(i)
				local k
				if i.UserInputType == Enum.UserInputType.Keyboard then
					k = (i.KeyCode ~= Enum.KeyCode.Escape) and i.KeyCode or nil
				elseif i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.MouseButton2 or i.UserInputType == Enum.UserInputType.MouseButton3 then
					k = i.UserInputType
				else
					return
				end
				con:Disconnect()
				Obj._listening = false
				Obj.Key = k
				KeyBtn.Text = KeyName(k)
				if o.KeybindChanged then task.spawn(o.KeybindChanged, k) end
			end)
		end)
		Connect(UserInputService.InputBegan, function(i, gp)
			if gp or Obj._listening or not Obj.Key or disabled then return end
			if i.KeyCode == Obj.Key or i.UserInputType == Obj.Key then
				if o.KeybindMode == "Hold" then Obj:SetValue(true) else Obj:SetValue(not Obj.Value) end
			end
		end)
		if o.KeybindMode == "Hold" then
			Connect(UserInputService.InputEnded, function(i)
				if Obj.Key and (i.KeyCode == Obj.Key or i.UserInputType == Obj.Key) then Obj:SetValue(false) end
			end)
		end
	end

	Obj:SetValue(o.Default or false, true)
	Register(o, Obj)
	return Obj
end

function Elements:AddSlider(o)
	o = o or {}
	local min, max, inc = o.Min or 0, o.Max or 100, o.Increment or 1
	local Obj = { Type = "Slider", Value = math.clamp(o.Default or min, min, max) }
	local Frame = Create("Frame", { Name = o.Text or "Slider", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 39), LayoutOrder = Order(self.Body), Parent = self.Body })
	Create("TextLabel", { Text = o.Text or "", Size = UDim2.new(.7, 0, 0, 18), Parent = Frame })
	local ValueLabel = Create("TextLabel", { TextSize = 12, TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Right, Position = UDim2.fromScale(.7, 0), Size = UDim2.new(.3, 0, 0, 18), Parent = Frame })
	local Track = Create("Frame", { BackgroundColor3 = Theme.Track, AnchorPoint = Vector2.new(0, .5), Position = UDim2.new(0, 0, 0, 29), Size = UDim2.new(1, 0, 0, 4), Parent = Frame }, { Corner(2) })
	local Fill = Create("Frame", { BackgroundColor3 = Theme.Accent, Size = UDim2.new(0, 0, 1, 0), Parent = Track }, { Corner(2) })
	local Knob = Create("Frame", { BackgroundColor3 = Theme.Accent, AnchorPoint = Vector2.new(.5, .5), Position = UDim2.new(0, 0, .5, 0), Size = UDim2.fromOffset(13, 13), ZIndex = 2, Parent = Track }, { Round() })
	local Hit = Create("TextButton", { Position = UDim2.new(0, 0, 0, 17), Size = UDim2.new(1, 0, 0, 24), ZIndex = 3, Parent = Frame })

	local function fmt(v)
		local s
		if inc % 1 == 0 then s = tostring(math.floor(v + .5)) else s = string.format("%." .. (o.Decimals or 2) .. "f", v) end
		return (o.Prefix or "") .. s .. (o.Suffix or "")
	end

	function Obj:SetValue(v, silent)
		v = math.clamp(v, min, max)
		v = math.floor((v - min) / inc + .5) * inc + min
		v = tonumber(string.format("%.6f", math.clamp(v, min, max)))
		self.Value = v
		local a = (max == min) and 0 or (v - min) / (max - min)
		Fill.Size = UDim2.new(a, 0, 1, 0)
		Knob.Position = UDim2.new(a, 0, .5, 0)
		ValueLabel.Text = fmt(v)
		if silent then
			if o.Flag then Library.Flags[o.Flag] = v end
		else
			Fire(o, self)
		end
	end
	function Obj:SetVisible(v) Frame.Visible = v end
	Obj.Root = Frame

	local dragging = false
	local window = self.Window
	local function update(x)
		local a = math.clamp((x - Track.AbsolutePosition.X) / math.max(Track.AbsoluteSize.X, 1), 0, 1)
		Obj:SetValue(min + (max - min) * a)
	end
	Hit.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			if window then window:LockScroll(true) end
			update(i.Position.X)
		end
	end)
	Connect(UserInputService.InputChanged, function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			update(i.Position.X)
		end
	end)
	Connect(UserInputService.InputEnded, function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
			dragging = false
			if window then window:LockScroll(false) end
		end
	end)

	Obj:SetValue(Obj.Value, true)
	Register(o, Obj)
	return Obj
end

function Elements:AddDropdown(o)
	o = o or {}
	local Obj = { Type = "Dropdown", Options = o.Options or {}, Multi = o.Multi }
	if o.Multi then
		Obj.Value = {}
		for _, v in ipairs(o.Default or {}) do Obj.Value[v] = true end
	else
		Obj.Value = o.Default or Obj.Options[1]
	end
	local Frame = Create("Frame", { Name = o.Text or "Dropdown", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 50), LayoutOrder = Order(self.Body), Parent = self.Body })
	Create("TextLabel", { Text = o.Text or "", Size = UDim2.new(1, 0, 0, 16), Parent = Frame })
	local Box = Create("TextButton", { BackgroundTransparency = 0, BackgroundColor3 = Theme.Control, Position = UDim2.new(0, 0, 0, 22), Size = UDim2.new(1, 0, 0, 28), Parent = Frame }, { Corner(8) })
	local Text = Create("TextLabel", { Position = UDim2.new(0, 9, 0, 0), Size = UDim2.new(1, -34, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, Parent = Box })
	local Chev = Library:Icon("chevron-down", 14, Theme.TextDim, Box)
	Chev.Root.AnchorPoint = Vector2.new(.5, .5)
	Chev.Root.Position = UDim2.new(1, -18, .5, 0)

	local function refreshText()
		if Obj.Multi then
			local t = {}
			for _, opt in ipairs(Obj.Options) do if Obj.Value[opt] then table.insert(t, opt) end end
			Text.Text = #t > 0 and table.concat(t, ", ") or "None"
		else
			Text.Text = tostring(Obj.Value or "None")
		end
	end

	function Obj:SetValue(v, silent)
		if self.Multi then
			self.Value = {}
			for _, x in ipairs(v or {}) do self.Value[x] = true end
		else
			self.Value = v
		end
		refreshText()
		if silent then
			if o.Flag then Library.Flags[o.Flag] = self.Value end
		else
			Fire(o, self)
		end
	end
	function Obj:SetOptions(opts) self.Options = opts refreshText() end
	function Obj:SetVisible(v) Frame.Visible = v end
	Obj.Root = Frame

	local window = self.Window
	Box.MouseButton1Click:Connect(function()
		window:ClosePopup()
		local sc = window.Scale.Scale
		local n = #Obj.Options
		local h = math.min(n * 26 + 8, 164)
		local abs = (Box.AbsolutePosition - window.Popups.AbsolutePosition) / sc
		local bh = Box.AbsoluteSize.Y / sc
		local y = abs.Y + bh + 4
		if y + h > window.Main.AbsoluteSize.Y / sc then y = abs.Y - h - 4 end
		local L = Create("ScrollingFrame", {
			BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			Position = UDim2.fromOffset(abs.X, y), Size = UDim2.fromOffset(Box.AbsoluteSize.X / sc, h),
			CanvasSize = UDim2.new(), AutomaticCanvasSize = AS_Y, ScrollBarThickness = 2,
		}, { Corner(8), Stroke(Theme.Line, 1), List(0), Pad(4, 4, 4, 4) })
		local buttons = {}
		local function paint()
			for opt, b in pairs(buttons) do
				local sel = Obj.Multi and Obj.Value[opt] or (not Obj.Multi and Obj.Value == opt)
				b.TextColor3 = sel and Theme.Text or Theme.SubText
			end
		end
		for idx, opt in ipairs(Obj.Options) do
			local b = Create("TextButton", { Text = opt, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, BackgroundColor3 = Theme.Control, Size = UDim2.new(1, 0, 0, 26), LayoutOrder = idx, Parent = L },
				{ Corner(6), Pad(0, 0, 0, 8) })
			buttons[opt] = b
			b.MouseEnter:Connect(function() b.BackgroundTransparency = 0 end)
			b.MouseLeave:Connect(function() b.BackgroundTransparency = 1 end)
			b.MouseButton1Click:Connect(function()
				if Obj.Multi then
					Obj.Value[opt] = not Obj.Value[opt] or nil
					refreshText(); paint(); Fire(o, Obj)
				else
					Obj:SetValue(opt)
					window:ClosePopup()
				end
			end)
		end
		paint()
		Tween(Chev.Root, { Rotation = 180 }, .15)
		window:OpenPopup(L, function() Tween(Chev.Root, { Rotation = 0 }, .15) end)
	end)

	refreshText()
	Register(o, Obj)
	return Obj
end

function Elements:AddButton(o)
	o = o or {}
	local Btn = Create("TextButton", {
		Name = o.Text or "Button", BackgroundTransparency = 0, BackgroundColor3 = Theme.Button, Size = UDim2.new(1, 0, 0, 27),
		Text = o.Text or "Button", FontFace = F.Medium, TextSize = 13, LayoutOrder = Order(self.Body), Parent = self.Body,
	}, { Corner(8) })
	Btn.MouseEnter:Connect(function() Tween(Btn, { BackgroundColor3 = Color3.fromRGB(22, 22, 22) }, .12) end)
	Btn.MouseLeave:Connect(function() Tween(Btn, { BackgroundColor3 = Theme.Button }, .12) end)
	Btn.MouseButton1Down:Connect(function() Tween(Btn, { BackgroundColor3 = Color3.fromRGB(6, 6, 6) }, .08) end)
	Btn.MouseButton1Up:Connect(function() Tween(Btn, { BackgroundColor3 = Color3.fromRGB(22, 22, 22) }, .08) end)
	Btn.MouseButton1Click:Connect(function() if o.Callback then task.spawn(o.Callback) end end)
	return { Root = Btn, Type = "Button", SetText = function(_, t) Btn.Text = t end, SetVisible = function(_, v) Btn.Visible = v end }
end

function Elements:AddLabel(o)
	o = type(o) == "string" and { Text = o } or (o or {})
	local L = Create("TextLabel", {
		Text = o.Text or "", TextSize = o.Size or 12, TextColor3 = o.Color or Theme.Muted, TextWrapped = true,
		AutomaticSize = AS_Y, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = Order(self.Body), Parent = self.Body,
	})
	return { Root = L, Type = "Label", SetText = function(_, t) L.Text = t end, SetVisible = function(_, v) L.Visible = v end }
end

-- ───────────────────────── Page (tab content) ─────────────────────────
local PageMethods = {}

function PageMethods:_Column(o)
	local c = o.Column or o.Side
	if c == 2 or c == "Right" or c == "right" then return self.Right end
	if c == 1 or c == "Left" or c == "left" then return self.Left end
	self._alt = not self._alt
	return self._alt and self.Left or self.Right
end

function PageMethods:AddCard(o)
	o = o or {}
	local col = self:_Column(o)
	local Frame = Create("Frame", {
		Name = o.Title or "Card", BackgroundColor3 = Theme.Card, BackgroundTransparency = Theme.CardAlpha,
		AutomaticSize = AS_Y, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = Order(col), Parent = col,
	}, { Corner(10) })
	local Head = Create("TextButton", { Size = UDim2.new(1, 0, 0, 38), Parent = Frame })
	if o.Icon then
		local ic = Library:Icon(o.Icon, 16, Theme.Text, Head)
		ic.Root.Position = UDim2.new(0, 13, .5, -8)
	end
	local Title = Create("TextLabel", { Text = o.Title or "", FontFace = F.Medium, TextSize = 14, Position = UDim2.new(0, o.Icon and 38 or 13, 0, 0), Size = UDim2.new(1, -70, 1, 0), Parent = Head })
	local Chev = Library:Icon("chevron-down", 14, Theme.TextDim, Head)
	Chev.Root.AnchorPoint = Vector2.new(.5, .5)
	Chev.Root.Position = UDim2.new(1, -19, .5, 0)
	Create("Frame", { BackgroundColor3 = Theme.Line, BackgroundTransparency = .35, Position = UDim2.new(0, 12, 0, 37), Size = UDim2.new(1, -24, 0, 1), Parent = Frame })
	local Body = Create("Frame", {
		BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 38), AutomaticSize = AS_Y, Size = UDim2.new(1, 0, 0, 0), Parent = Frame,
	}, { List(6), Pad(8, 11, 11, 11) })

	local Card = setmetatable({ Frame = Frame, Body = Body, Window = self.Window }, Elements)
	local open = true
	function Card:SetOpen(v)
		open = v
		Body.Visible = v
		Tween(Chev.Root, { Rotation = v and 0 or -90 }, .15)
	end
	function Card:SetVisible(v) Frame.Visible = v end
	function Card:SetTitle(t) Title.Text = t end
	if o.Collapsible ~= false then Head.MouseButton1Click:Connect(function() Card:SetOpen(not open) end) end
	if o.Open == false then Card:SetOpen(false) end
	return Card
end

function PageMethods:AddTabCard(o)
	o = o or {}
	local col = self:_Column(o)
	local Frame = Create("Frame", {
		Name = "TabCard", BackgroundColor3 = Theme.Card, BackgroundTransparency = Theme.CardAlpha,
		AutomaticSize = AS_Y, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = Order(col), Parent = col,
	}, { Corner(10) })
	local Strip = Create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), Parent = Frame },
		{ List(22, HORIZ, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top), Pad(0, 0, 0, 17) })
	Create("Frame", { BackgroundColor3 = Theme.Line, BackgroundTransparency = .35, Position = UDim2.new(0, 17, 0, 35), Size = UDim2.new(1, -34, 0, 1), Parent = Frame })
	local Wrap = Create("Frame", { BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 36), AutomaticSize = AS_Y, Size = UDim2.new(1, 0, 0, 0), Parent = Frame })

	local TC = { Frame = Frame, Tabs = {}, Window = self.Window }
	local function select(t)
		for _, x in ipairs(TC.Tabs) do
			local on = x == t
			x.Body.Visible = on
			x.Line.Visible = on
			Tween(x.Btn, { TextColor3 = on and Theme.Text or Theme.SubText }, .12)
		end
	end
	function TC:AddTab(name)
		local Btn = Create("TextButton", {
			Text = name, FontFace = F.Medium, TextSize = 13, TextColor3 = Theme.SubText, AutomaticSize = AS_X,
			Size = UDim2.new(0, 0, 0, 40), LayoutOrder = Order(Strip), Parent = Strip,
		})
		local Line = Create("Frame", { BackgroundColor3 = Theme.Accent, Position = UDim2.new(0, 0, 0, 34), Size = UDim2.new(1, 0, 0, 2), Visible = false, Parent = Btn }, { Corner(1) })
		local Body = Create("Frame", { BackgroundTransparency = 1, AutomaticSize = AS_Y, Size = UDim2.new(1, 0, 0, 0), Visible = false, Parent = Wrap },
			{ List(6), Pad(12, 17, 12, 17) })
		local t = setmetatable({ Name = name, Btn = Btn, Line = Line, Body = Body, Window = TC.Window }, Elements)
		table.insert(TC.Tabs, t)
		Btn.MouseButton1Click:Connect(function() select(t) end)
		if #TC.Tabs == 1 then select(t) end
		return t
	end
	function TC:SetVisible(v) Frame.Visible = v end
	return TC
end

local function MakePage(window)
	local Page = Create("ScrollingFrame", {
		Name = "Page", Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.new(), AutomaticCanvasSize = AS_Y,
		ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(90, 90, 90), ScrollingDirection = Enum.ScrollingDirection.Y,
		Visible = false, Parent = window._Pages,
	}, { Pad(0, 0, 11, 0) })
	local Left = Create("Frame", { Name = "Left", BackgroundTransparency = 1, AutomaticSize = AS_Y, Position = UDim2.new(0, 11, 0, 0), Size = UDim2.new(.5, -17, 0, 0), Parent = Page }, { List(12) })
	local Right = Create("Frame", { Name = "Right", BackgroundTransparency = 1, AutomaticSize = AS_Y, Position = UDim2.new(.5, 6, 0, 0), Size = UDim2.new(.5, -17, 0, 0), Parent = Page }, { List(12) })
	return Page, Left, Right
end

-- ───────────────────────── Notifications ─────────────────────────
local NotifyHolder
local NotifyTypes = {
	Info = { "info", Theme.Text },
	Success = { "circle-check", Color3.fromRGB(95, 220, 135) },
	Warning = { "triangle-alert", Color3.fromRGB(255, 190, 70) },
	Error = { "circle-x", Color3.fromRGB(255, 90, 90) },
}

function Library:Notify(o)
	o = o or {}
	if not NotifyHolder or not NotifyHolder.Parent then
		local gui = NewGui("BlushUI_Notify")
		NotifyHolder = Create("Frame", {
			AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -20, 1, -20), Size = UDim2.new(0, 402, 1, -40),
			BackgroundTransparency = 1, Parent = gui,
		}, { List(8, VERT, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom) })
		local sc = Create("UIScale", { Parent = NotifyHolder })
		local function fit() sc.Scale = math.clamp((gui.AbsoluteSize.Y - 24) / 600, .4, 1) end
		fit()
		gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
	end
	local kind = NotifyTypes[o.Type or "Info"] or NotifyTypes.Info
	local dur = o.Duration or 4

	local Holder = Create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 89), LayoutOrder = Order(NotifyHolder), Parent = NotifyHolder })
	local Card = Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(14, 14, 14), BackgroundTransparency = .03,
		Position = UDim2.new(1, 60, 0, 0), Size = UDim2.fromScale(1, 1), Parent = Holder,
	}, { Corner(15), Stroke(Color3.fromRGB(38, 38, 38), 1) })
	local IconBox = Create("Frame", { BackgroundColor3 = Color3.fromRGB(34, 34, 34), Position = UDim2.new(0, 20, 0, 23), Size = UDim2.fromOffset(43, 43), Parent = Card }, { Corner(10) })
	local ic = Library:Icon(o.Icon or kind[1], 22, kind[2], IconBox)
	ic.Root.AnchorPoint = Vector2.new(.5, .5)
	ic.Root.Position = UDim2.fromScale(.5, .5)
	Create("TextLabel", { Text = o.Title or "Info", FontFace = F.Bold, TextSize = 16, Position = UDim2.new(0, 75, 0, 17), Size = UDim2.new(1, -120, 0, 20), Parent = Card })
	Create("TextLabel", {
		Text = o.Content or "", TextSize = 14, TextColor3 = Theme.TextDim, TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.new(0, 75, 0, 45), Size = UDim2.new(1, -90, 0, 18), Parent = Card,
	})
	local Close = Create("TextButton", { Position = UDim2.new(1, -36, 0, 12), Size = UDim2.fromOffset(24, 24), Parent = Card })
	local xi = Library:Icon("x", 14, Theme.TextDim, Close)
	xi.Root.AnchorPoint = Vector2.new(.5, .5)
	xi.Root.Position = UDim2.fromScale(.5, .5)
	local Bar = Create("Frame", { BackgroundColor3 = Color3.fromRGB(190, 190, 190), Position = UDim2.new(0, 20, 0, 80), Size = UDim2.new(1, -40, 0, 3), Parent = Card }, { Round() })

	local closed = false
	local Obj = {}
	function Obj:Close()
		if closed then return end
		closed = true
		Tween(Card, { Position = UDim2.new(1, 60, 0, 0) }, .2)
		task.delay(.2, function()
			local t = Tween(Holder, { Size = UDim2.new(1, 0, 0, 0) }, .15)
			t.Completed:Wait()
			Holder:Destroy()
		end)
	end
	Close.MouseButton1Click:Connect(function() Obj:Close() end)

	Tween(Card, { Position = UDim2.new(0, 0, 0, 0) }, .25, Enum.EasingStyle.Back)
	Tween(Bar, { Size = UDim2.new(0, 0, 0, 3) }, dur, Enum.EasingStyle.Linear)
	task.delay(dur, function() Obj:Close() end)
	return Obj
end

-- ───────────────────────── Window ─────────────────────────
function Library:CreateWindow(o)
	o = o or {}
	local Window = { Library = Library, Visible = true }
	local WSize = o.Size or Vector2.new(820, 600)
	local SB, HEADER, FOOT = 190, 55, 79

	local Gui = NewGui("BlushUI")
	Window.Gui = Gui
	local Main = Create("Frame", {
		Name = "Window", AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
		Size = UDim2.fromOffset(WSize.X, WSize.Y), BackgroundTransparency = 1, Parent = Gui,
	})
	local Scale = Create("UIScale", { Parent = Main })
	Window.Main, Window.Scale = Main, Scale
	local function Fit()
		local vp = Gui.AbsoluteSize
		if vp.X > 0 then Scale.Scale = math.clamp(math.min((vp.X - 24) / WSize.X, (vp.Y - 24) / WSize.Y), .35, 1) end
	end
	Fit()
	Connect(Gui:GetPropertyChangedSignal("AbsoluteSize"), Fit)

	-- content background (extends under the sidebar so only the right corners show)
	local geo = { Position = UDim2.new(0, SB - 24, 0, 0), Size = UDim2.new(1, -(SB - 24), 1, 0) }
	Create("Frame", { Name = "ContentBG", BackgroundColor3 = Theme.Content, BackgroundTransparency = o.Background and 0 or .05, Position = geo.Position, Size = geo.Size, ZIndex = 1, Parent = Main }, { Corner(12) })
	local BGImage = Create("ImageLabel", {
		Name = "BGImage", Image = o.Background or "", ImageTransparency = o.BackgroundTransparency or .3, ScaleType = Enum.ScaleType.Crop,
		Position = geo.Position, Size = geo.Size, ZIndex = 1, Visible = o.Background ~= nil, Parent = Main,
	}, { Corner(12) })
	function Window:SetBackground(img)
		BGImage.Image = img or ""
		BGImage.Visible = img ~= nil
	end

	-- sidebar
	local Sidebar = Create("Frame", { Name = "Sidebar", BackgroundColor3 = Theme.Sidebar, Size = UDim2.new(0, SB, 1, 0), ZIndex = 3, Parent = Main }, { Corner(12) })
	Create("Frame", { BackgroundColor3 = Theme.Sidebar, Position = UDim2.new(1, -14, 0, 0), Size = UDim2.new(0, 14, 1, 0), Parent = Sidebar })

	local Profile = Create("Frame", { Name = "Profile", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 68), Parent = Sidebar })
	local Av = Create("ImageLabel", { BackgroundTransparency = 0, BackgroundColor3 = Theme.Control, Position = UDim2.fromOffset(15, 14), Size = UDim2.fromOffset(40, 40), Parent = Profile }, { Round() })
	SetAvatar(Av, o.Avatar)
	Create("TextLabel", { Text = o.Name or "blush.", FontFace = F.Bold, TextSize = 15, Position = UDim2.fromOffset(65, 13), Size = UDim2.new(1, -75, 0, 20), Parent = Profile })
	Create("TextLabel", { Text = o.Subtitle or "", FontFace = F.Medium, TextSize = 11, TextColor3 = Theme.SubText, Position = UDim2.fromOffset(65, 35), Size = UDim2.new(1, -75, 0, 14), Parent = Profile })

	local Nav = Create("ScrollingFrame", {
		Name = "Nav", Position = UDim2.new(0, 0, 0, 68), Size = UDim2.new(1, 0, 1, -(68 + FOOT)), CanvasSize = UDim2.new(),
		AutomaticCanvasSize = AS_Y, ScrollBarThickness = 0, Parent = Sidebar,
	}, { List(18), Pad(8, 0, 8, 0) })

	-- footer (user / expiry)
	if o.User ~= false then
		local u = o.User or {}
		local Foot = Create("Frame", { Name = "Footer", BackgroundTransparency = 1, Position = UDim2.new(0, 0, 1, -FOOT), Size = UDim2.new(1, 0, 0, FOOT), Parent = Sidebar })
		Create("Frame", { BackgroundColor3 = Color3.fromRGB(30, 30, 30), Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -26, 0, 1), Parent = Foot })
		local fa = Create("ImageLabel", { BackgroundTransparency = 0, BackgroundColor3 = Theme.Control, Position = UDim2.new(0, 15, .5, -20), Size = UDim2.fromOffset(40, 40), Parent = Foot }, { Round() })
		SetAvatar(fa, u.Avatar)
		Create("TextLabel", { Text = u.Name or LocalPlayer.Name, FontFace = F.SemiBold, TextSize = 12, Position = UDim2.new(0, 65, .5, -19), Size = UDim2.new(1, -75, 0, 16), Parent = Foot })
		if u.Value then
			Create("TextLabel", {
				Text = (u.Label or "Expires:") .. ' <font color="#ffffff"><b>' .. u.Value .. "</b></font>", RichText = true,
				TextSize = 12, TextColor3 = Theme.TextDim, Position = UDim2.new(0, 65, .5, 1), Size = UDim2.new(1, -75, 0, 16), Parent = Foot,
			})
		end
	end

	-- content
	local Content = Create("Frame", { Name = "Content", BackgroundTransparency = 1, Position = UDim2.new(0, SB, 0, 0), Size = UDim2.new(1, -SB, 1, 0), ZIndex = 2, Parent = Main })
	local Header = Create("Frame", { Name = "Header", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, HEADER), Parent = Content })
	local Crumb = Create("Frame", { BackgroundTransparency = 1, Position = UDim2.new(0, 11, 0, 0), Size = UDim2.new(1, -200, 1, 0), Parent = Header },
		{ List(8, HORIZ, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) })
	local Buttons = Create("Frame", {
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -12, 0, 28),
		Size = UDim2.new(0, 0, 0, 32), AutomaticSize = AS_X, Parent = Header,
	}, { List(8, HORIZ, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) })
	Window._Pages = Create("Frame", { Name = "Pages", BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, HEADER), Size = UDim2.new(1, 0, 1, -HEADER), Parent = Content })

	function Window:SetBreadcrumb(parts)
		for _, c in ipairs(Crumb:GetChildren()) do
			if not c:IsA("UIListLayout") then c:Destroy() end
		end
		for i, p in ipairs(parts) do
			if i > 1 then
				local ic = Library:Icon("chevron-right", 14, Theme.Muted, Crumb)
				ic.Root.LayoutOrder = i * 2 - 1
			end
			Create("TextLabel", {
				Text = p, FontFace = F.Bold, TextSize = 17, TextColor3 = (i == #parts and #parts > 1) and Theme.TextDim or Theme.Text,
				AutomaticSize = AS_X, Size = UDim2.new(0, 0, 1, 0), LayoutOrder = i * 2, Parent = Crumb,
			})
		end
	end

	function Window:AddHeaderButton(b)
		b = b or {}
		local Btn = Create("TextButton", {
			Name = b.Name or b.Icon or "Button", BackgroundTransparency = 0, BackgroundColor3 = Theme.Control,
			Size = UDim2.fromOffset(32, 32), LayoutOrder = Order(Buttons), Parent = Buttons,
		}, { Corner(8) })
		local ic = Library:Icon(b.Icon or "circle", 16, Theme.TextDim, Btn)
		ic.Root.AnchorPoint = Vector2.new(.5, .5)
		ic.Root.Position = UDim2.fromScale(.5, .5)
		Btn.MouseEnter:Connect(function() Tween(Btn, { BackgroundColor3 = Theme.ControlHover }, .12) ic.SetColor(Theme.Text, .12) end)
		Btn.MouseLeave:Connect(function() Tween(Btn, { BackgroundColor3 = Theme.Control }, .12) ic.SetColor(Theme.TextDim, .12) end)
		Btn.MouseButton1Click:Connect(function() if b.Callback then task.spawn(b.Callback) end end)
		local Badge = Create("Frame", {
			BackgroundColor3 = Theme.Danger, AnchorPoint = Vector2.new(.5, .5), Position = UDim2.new(1, -3, 0, 3),
			Size = UDim2.fromOffset(14, 14), ZIndex = 5, Visible = false, Parent = Btn,
		}, { Round() })
		local BadgeText = Create("TextLabel", { FontFace = F.Bold, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), Parent = Badge })
		local Obj = { Button = Btn }
		function Obj:SetBadge(n)
			Badge.Visible = n ~= nil and n ~= 0
			BadgeText.Text = tostring(n or "")
		end
		if b.Badge then Obj:SetBadge(b.Badge) end
		return Obj
	end

	-- popups (dropdown lists)
	Window.Popups = Create("Frame", { Name = "Popups", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 50, Visible = false, Parent = Main })
	local Catcher = Create("TextButton", { AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromScale(4, 4), ZIndex = 1, Parent = Window.Popups })
	function Window:ClosePopup()
		if self._popup then self._popup:Destroy() self._popup = nil end
		self.Popups.Visible = false
		if self._onClose then local f = self._onClose self._onClose = nil f() end
	end
	function Window:OpenPopup(frame, onClose)
		self:ClosePopup()
		frame.ZIndex = 2
		frame.Parent = self.Popups
		self._popup, self._onClose = frame, onClose
		self.Popups.Visible = true
	end
	Catcher.MouseButton1Click:Connect(function() Window:ClosePopup() end)

	function Window:LockScroll(lock)
		if self.CurrentPage then self.CurrentPage.ScrollingEnabled = not lock end
	end

	-- dragging
	local function MakeDraggable(handle)
		local dragging, startMouse, startPos
		handle.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				dragging, startMouse, startPos = true, i.Position, Main.Position
				i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
			end
		end)
		Connect(UserInputService.InputChanged, function(i)
			if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				local d = (i.Position - startMouse) / Scale.Scale
				Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end)
	end
	MakeDraggable(Header)
	MakeDraggable(Profile)

	-- sections / tabs
	local function NewTab(container, t, parentTab)
		local level = parentTab and 1 or 0
		local Tab = setmetatable({ Name = t.Name, Parent = parentTab, Window = Window, Subs = {} }, { __index = PageMethods })
		local Holder = Create("Frame", { Name = t.Name, BackgroundTransparency = 1, AutomaticSize = AS_Y, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = Order(container), Parent = container }, { List(6) })
		local Btn = Create("TextButton", { Size = UDim2.new(1, 0, 0, 32), LayoutOrder = 1, Parent = Holder })
		local ix = level == 0 and 24 or 38
		local icon = Library:Icon(t.Icon or "circle", 16, Theme.NavInactive, Btn)
		icon.Root.Position = UDim2.new(0, ix, .5, -8)
		local text = Create("TextLabel", {
			Text = t.Name, FontFace = F.Medium, TextSize = level == 0 and 14 or 13, TextColor3 = Theme.NavInactive,
			Position = UDim2.new(0, ix + 26, 0, 0), Size = UDim2.new(1, -(ix + 26), 1, 0), Parent = Btn,
		})
		local bar = Create("Frame", {
			BackgroundColor3 = Theme.Text, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, .5),
			Position = UDim2.new(0, 9, .5, 0), Size = UDim2.fromOffset(3, 0), Parent = Btn,
		}, { Round() })

		Tab.Page, Tab.Left, Tab.Right = MakePage(Window)

		function Tab:_Paint()
			local cur = Window.Current
			local isSel = cur == Tab
			local active = isSel or (cur ~= nil and cur.Parent == Tab)
			local c = active and Theme.Text or Theme.NavInactive
			icon.SetColor(c, .15)
			Tween(text, { TextColor3 = c }, .15)
			Tween(bar, { Size = UDim2.fromOffset(3, isSel and 18 or 0), BackgroundTransparency = isSel and 0 or 1 }, .15)
		end

		Btn.MouseEnter:Connect(function()
			if Window.Current ~= Tab then Tween(text, { TextColor3 = Theme.Text }, .1) icon.SetColor(Theme.Text, .1) end
		end)
		Btn.MouseLeave:Connect(function() Tab:_Paint() end)

		Btn.MouseButton1Click:Connect(function()
			if Tab.SubHolder then
				local vis = not Tab.SubHolder.Visible
				Tab.SubHolder.Visible = vis
				local cur = Window.Current
				if vis and not (cur and cur.Parent == Tab) and Tab.Subs[1] then Window:SelectTab(Tab.Subs[1]) end
			else
				Window:SelectTab(Tab)
			end
		end)

		function Tab:AddSubTab(st)
			if not Tab.SubHolder then
				Tab.SubHolder = Create("Frame", { BackgroundTransparency = 1, AutomaticSize = AS_Y, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 2, Parent = Holder }, { List(0) })
			end
			local sub = NewTab(Tab.SubHolder, st, Tab)
			table.insert(Tab.Subs, sub)
			if Window.Current == Tab then Window:SelectTab(sub) end
			return sub
		end

		Tab.Holder = Holder
		table.insert(Window.Tabs or {}, Tab)
		if level == 0 and not Window.Current then Window:SelectTab(Tab) end
		return Tab
	end
	Window.Tabs = {}

	function Window:SelectTab(tab)
		local old = self.Current
		if old == tab then return end
		if old then old.Page.Visible = false end
		self:ClosePopup()
		self.Current = tab
		tab.Page.Visible = true
		self.CurrentPage = tab.Page
		self:SetBreadcrumb(tab.Parent and { tab.Parent.Name, tab.Name } or { tab.Name })
		if old then
			old:_Paint()
			if old.Parent then old.Parent:_Paint() end
		end
		tab:_Paint()
		if tab.Parent then tab.Parent:_Paint() end
	end

	function Window:AddSection(name)
		local Section = { Name = name }
		local Frame = Create("Frame", { Name = name, BackgroundTransparency = 1, AutomaticSize = AS_Y, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = Order(Nav), Parent = Nav }, { List(6) })
		local Head = Create("TextButton", { Size = UDim2.new(1, 0, 0, 24), LayoutOrder = 0, Parent = Frame })
		Create("TextLabel", { Text = name, FontFace = F.Medium, TextColor3 = Theme.SubText, Position = UDim2.new(0, 23, 0, 0), Size = UDim2.new(1, -60, 1, 0), Parent = Head })
		local Chev = Library:Icon("chevron-down", 14, Theme.SubText, Head)
		Chev.Root.AnchorPoint = Vector2.new(.5, .5)
		Chev.Root.Position = UDim2.new(1, -28, .5, 0)
		local Body = Create("Frame", { Name = "Body", BackgroundTransparency = 1, AutomaticSize = AS_Y, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 1, Parent = Frame }, { List(6) })
		local open = true
		Head.MouseButton1Click:Connect(function()
			open = not open
			Body.Visible = open
			Tween(Chev.Root, { Rotation = open and 0 or -90 }, .15)
		end)
		function Section:AddTab(t) return NewTab(Body, t, nil) end
		return Section
	end

	-- stats bar (top center)
	if o.StatsBar then
		local sb = type(o.StatsBar) == "table" and o.StatsBar or { Items = { o.Name or "blush." } }
		local Bar = Create("Frame", {
			Name = "StatsBar", BackgroundColor3 = Color3.fromRGB(10, 10, 10), AnchorPoint = Vector2.new(.5, 0),
			Position = UDim2.new(.5, 0, 0, -10), Size = UDim2.new(0, 0, 0, 38), AutomaticSize = AS_X, Parent = Gui,
		}, { Corner(9), List(0, HORIZ, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Bottom) })
		local n = 0
		local function item(text, bold)
			n += 1
			if n > 1 then
				local s = Create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(0, 1, 0, 28), LayoutOrder = n * 2 - 1, Parent = Bar })
				Create("Frame", { BackgroundColor3 = Color3.fromRGB(55, 55, 55), Position = UDim2.new(0, 0, .5, -7), Size = UDim2.new(1, 0, 0, 14), Parent = s })
			end
			return Create("TextLabel", {
				Text = text, FontFace = bold and F.Bold or F.Medium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center,
				AutomaticSize = AS_X, Size = UDim2.new(0, 0, 0, 28), LayoutOrder = n * 2, Parent = Bar,
			}, { Pad(0, 12, 0, 12) })
		end
		for idx, t in ipairs(sb.Items or {}) do item(t, idx == 1) end
		local fpsL = sb.FPS ~= false and item("0 fps")
		local pingL = sb.Ping ~= false and item("0 ms")
		local timeL = sb.Time ~= false and item(os.date("%H:%M"))
		local frames, last = 0, os.clock()
		Connect(RunService.RenderStepped, function()
			frames += 1
			local now = os.clock()
			if now - last >= .5 then
				if fpsL then fpsL.Text = math.floor(frames / (now - last) + .5) .. " fps" end
				if pingL then
					local ok, v = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
					pingL.Text = (ok and math.floor(v + .5) or 0) .. " ms"
				end
				if timeL then timeL.Text = os.date("%H:%M") end
				frames, last = 0, now
			end
		end)
		Window.StatsBar = Bar
	end

	-- toggle (key + mobile button)
	function Window:Toggle(v)
		if v == nil then v = not self.Visible end
		self.Visible = v
		Main.Visible = v
		if not v then self:ClosePopup() end
	end
	Connect(UserInputService.InputBegan, function(i, gp)
		if gp then return end
		if i.KeyCode == (o.ToggleKey or Enum.KeyCode.RightShift) then Window:Toggle() end
	end)
	if o.MobileButton ~= false and UserInputService.TouchEnabled then
		local TB = Create("TextButton", {
			BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(10, 10, 10), Position = UDim2.new(1, -56, 0, 56),
			Size = UDim2.fromOffset(38, 38), Parent = Gui,
		}, { Corner(10), Stroke(Theme.Line, 1) })
		local ic = Library:Icon("sparkles", 18, Theme.Text, TB)
		ic.Root.AnchorPoint = Vector2.new(.5, .5)
		ic.Root.Position = UDim2.fromScale(.5, .5)
		TB.MouseButton1Click:Connect(function() Window:Toggle() end)
	end

	Window.Notify = function(_, n) return Library:Notify(n) end
	table.insert(Library.Windows, Window)
	return Window
end

function Library:Unload()
	for _, c in ipairs(self._conns) do pcall(function() c:Disconnect() end) end
	for _, g in ipairs(self._guis) do pcall(function() g:Destroy() end) end
	table.clear(self._conns)
	table.clear(self._guis)
	NotifyHolder = nil
end

return Library
