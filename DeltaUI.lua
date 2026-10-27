--[[
	DeltaUI  -  Roblox UI Library
	Clone of the dark "dashboard" UI (sidebar icons / profile bar / Hello header /
	Details-Script Logs-UI Logs tabs / Server, Delta, Friends, Discord cards).

	ไม่ใช้อีโมจิเป็นไอคอน: ไอคอนทุกตัววาดด้วย Frame + UIStroke (เวกเตอร์)
	หรือใส่ rbxassetid://... เองก็ได้

	Usage:
		local Library = loadstring(readfile("DeltaUI.lua"))()
		local Window  = Library:CreateWindow({ ... })
		local Tab     = Window:AddTab({ Name = "Dashboard", Icon = "grid" })
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local Library = {
	Flags = {},
	Options = {},
	Version = "1.0.0",
}

------------------------------------------------------------------------
-- THEME
------------------------------------------------------------------------
Library.Theme = {
	Window = Color3.fromRGB(8, 10, 15),
	WindowStroke = Color3.fromRGB(32, 36, 48),
	Content = Color3.fromRGB(11, 14, 21),
	Card = Color3.fromRGB(12, 15, 22),
	CardStroke = Color3.fromRGB(25, 29, 41),
	Box = Color3.fromRGB(10, 12, 19),
	BoxStroke = Color3.fromRGB(21, 25, 36),
	BoxHover = Color3.fromRGB(15, 18, 27),
	Off = Color3.fromRGB(28, 32, 45),
	Accent = Color3.fromRGB(79, 131, 245),
	AccentText = Color3.fromRGB(167, 192, 255),
	Text = Color3.fromRGB(244, 246, 250),
	SubText = Color3.fromRGB(138, 144, 160),
	Value = Color3.fromRGB(154, 159, 173),
	Icon = Color3.fromRGB(232, 234, 240),
	Divider = Color3.fromRGB(22, 26, 36),
	TabActive = Color3.fromRGB(19, 23, 33),
}
local Theme = Library.Theme

Library.InfoStyles = {
	Green = {
		Colors = { { 0, Color3.fromRGB(12, 122, 58) }, { 0.55, Color3.fromRGB(5, 46, 23) }, { 1, Color3.fromRGB(0, 0, 0) } },
		Stroke = Color3.fromRGB(14, 62, 33),
		Content = Color3.fromRGB(214, 238, 224),
		Rotation = 8,
	},
	Blue = {
		Colors = { { 0, Color3.fromRGB(30, 70, 240) }, { 0.55, Color3.fromRGB(10, 24, 112) }, { 1, Color3.fromRGB(2, 4, 14) } },
		Stroke = Color3.fromRGB(20, 36, 112),
		Content = Color3.fromRGB(214, 224, 255),
		Rotation = 0,
	},
	Red = {
		Colors = { { 0, Color3.fromRGB(190, 38, 52) }, { 0.55, Color3.fromRGB(78, 12, 20) }, { 1, Color3.fromRGB(0, 0, 0) } },
		Stroke = Color3.fromRGB(88, 20, 28),
		Content = Color3.fromRGB(255, 220, 224),
		Rotation = 8,
	},
	Purple = {
		Colors = { { 0, Color3.fromRGB(120, 66, 235) }, { 0.55, Color3.fromRGB(46, 20, 100) }, { 1, Color3.fromRGB(4, 2, 12) } },
		Stroke = Color3.fromRGB(52, 28, 108),
		Content = Color3.fromRGB(230, 220, 255),
		Rotation = 8,
	},
}

------------------------------------------------------------------------
-- HELPERS
------------------------------------------------------------------------
local FONT_FAMILY = "rbxasset://fonts/families/Montserrat.json"

local function SetFont(obj, weight)
	local ok = pcall(function()
		obj.FontFace = Font.new(FONT_FAMILY, weight or Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	end)
	if not ok then
		obj.Font = Enum.Font.GothamMedium
	end
end

local function New(class, props, children)
	local inst = Instance.new(class)
	if inst:IsA("GuiObject") then
		inst.BorderSizePixel = 0
	end
	if class == "TextLabel" or class == "TextButton" or class == "TextBox" then
		inst.BackgroundTransparency = 1
		inst.TextColor3 = Theme.Text
		inst.TextSize = 13
		inst.RichText = false
		if class == "TextButton" then
			inst.AutoButtonColor = false
			inst.Text = ""
		end
		if class == "TextBox" then
			inst.ClearTextOnFocus = false
		end
		SetFont(inst, Enum.FontWeight.Medium)
	end
	if class == "ImageLabel" or class == "ImageButton" then
		inst.BackgroundTransparency = 1
	end
	local parent, weight
	for k, v in pairs(props or {}) do
		if k == "Parent" then
			parent = v
		elseif k == "Weight" then
			weight = v
		else
			inst[k] = v
		end
	end
	if weight then
		SetFont(inst, weight)
	end
	for _, c in ipairs(children or {}) do
		c.Parent = inst
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

local function Tween(obj, props, time)
	local t = TweenService:Create(obj, TweenInfo.new(time or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local function Corner(parent, r)
	return New("UICorner", { CornerRadius = UDim.new(0, r), Parent = parent })
end

local function Stroke(parent, color, thickness)
	return New("UIStroke", {
		Color = color,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent,
	})
end

local function Pad(parent, l, t, r, b)
	return New("UIPadding", {
		PaddingLeft = UDim.new(0, l or 0),
		PaddingTop = UDim.new(0, t or 0),
		PaddingRight = UDim.new(0, r or 0),
		PaddingBottom = UDim.new(0, b or 0),
		Parent = parent,
	})
end

local function List(parent, dir, padding, ha, va)
	local l = New("UIListLayout", {
		FillDirection = dir or Enum.FillDirection.Vertical,
		Padding = UDim.new(0, padding or 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = parent,
	})
	if ha then l.HorizontalAlignment = ha end
	if va then l.VerticalAlignment = va end
	return l
end

local function Gradient(parent, stops, rotation)
	local kp = {}
	for i, s in ipairs(stops) do
		kp[i] = ColorSequenceKeypoint.new(s[1], s[2])
	end
	return New("UIGradient", { Color = ColorSequence.new(kp), Rotation = rotation or 0, Parent = parent })
end

local function Fire(cb, ...)
	if type(cb) ~= "function" then
		return
	end
	local args = table.pack(...)
	task.spawn(function()
		local ok, err = pcall(cb, table.unpack(args, 1, args.n))
		if not ok then
			warn("[DeltaUI] callback error: " .. tostring(err))
		end
	end)
end

local function AssetOf(v)
	if type(v) == "number" then
		return "rbxassetid://" .. tostring(v)
	end
	if type(v) == "string" and v:find("^rbxasset") then
		return v
	end
	return nil
end

local function MakeDraggable(handle, target, getScale, conns)
	local state = { Moved = false }
	local dragging, startInput, startPos = false, nil, nil
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			state.Moved = false
			startInput = input.Position
			startPos = target.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	local c = UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local scale = getScale and getScale() or 1
			local dx = (input.Position.X - startInput.X) / scale
			local dy = (input.Position.Y - startInput.Y) / scale
			if math.abs(dx) + math.abs(dy) > 6 then
				state.Moved = true
			end
			target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + dx, startPos.Y.Scale, startPos.Y.Offset + dy)
		end
	end)
	if conns then
		conns[#conns + 1] = c
	end
	return state
end

------------------------------------------------------------------------
-- ICONS  (vector, no emoji) - วาดบนกริด 24x24
------------------------------------------------------------------------
local Icons = {}

Icons.grid = function(P)
	P.Rect(3, 3, 8, 9, 2.2)
	P.Rect(13, 3, 8, 6, 2.2)
	P.Rect(3, 15, 8, 6, 2.2)
	P.Rect(13, 12, 8, 9, 2.2)
end

Icons.folder = function(P)
	P.Poly({ { 3, 19 }, { 3, 6.5 }, { 4.5, 5 }, { 8.5, 5 }, { 11, 8 }, { 19.5, 8 }, { 21, 9.5 }, { 21, 19 }, { 3, 19 } })
end

Icons.home = function(P)
	P.Poly({ { 3, 11.5 }, { 12, 4 }, { 21, 11.5 } })
	P.Poly({ { 5.5, 10 }, { 5.5, 20 }, { 18.5, 20 }, { 18.5, 10 } })
	P.Poly({ { 9.5, 20 }, { 9.5, 15 }, { 14.5, 15 }, { 14.5, 20 } })
end

Icons.wheat = function(P)
	P.Line(4, 20, 19, 5)
	local pts = { { 10.75, 13.25 }, { 13.75, 10.25 }, { 16.75, 7.25 } }
	for _, p in ipairs(pts) do
		P.Oval(p[1] + 2.4, p[2] + 2.4, 3.6, 6.4, 60)
		P.Oval(p[1] - 2.4, p[2] - 2.4, 3.6, 6.4, 20)
	end
	P.Oval(19.8, 4.2, 3.4, 6, 45)
end

Icons.list = function(P)
	P.Line(3, 6, 15, 6)
	P.Line(3, 12, 15, 12)
	P.Line(3, 18, 15, 18)
	P.Dot(20, 6, 1)
	P.Dot(20, 12, 1)
	P.Dot(20, 18, 1)
end

Icons.toggle = function(P)
	P.Rect(2, 6.5, 20, 11, 5.5)
	P.Circle(16, 12, 2.4)
end

Icons.mouse = function(P)
	P.Rect(6.5, 2.5, 11, 19, 5.5)
	P.Line(12, 6.5, 12, 10.5)
end

Icons.search = function(P)
	P.Circle(11, 11, 7.5)
	P.Line(16.8, 16.8, 21, 21)
end

Icons.minus = function(P)
	P.Line(4, 12, 20, 12)
end

Icons.close = function(P)
	P.Line(5, 5, 19, 19)
	P.Line(19, 5, 5, 19)
end

Icons.edit = function(P)
	P.Poly({ { 13, 4 }, { 6, 4 }, { 3.5, 6.5 }, { 3.5, 18.5 }, { 6, 21 }, { 18, 21 }, { 20.5, 18.5 }, { 20.5, 12 } })
	P.Rect(13.5, 4.5, 4.5, 12, 1.5, 45)
end

Icons.chevron = function(P)
	P.Poly({ { 6, 9 }, { 12, 15 }, { 18, 9 } })
end

Icons.code = function(P)
	P.Poly({ { 8, 6.5 }, { 2.5, 12 }, { 8, 17.5 } })
	P.Poly({ { 16, 6.5 }, { 21.5, 12 }, { 16, 17.5 } })
end

Icons.file = function(P)
	P.Poly({ { 6, 3.5 }, { 14, 3.5 }, { 19, 8.5 }, { 19, 20.5 }, { 6, 20.5 }, { 6, 3.5 } })
	P.Poly({ { 14, 3.5 }, { 14, 8.5 }, { 19, 8.5 } })
	P.Line(9.5, 13, 15.5, 13)
	P.Line(9.5, 17, 15.5, 17)
end

Icons.user = function(P)
	P.Circle(12, 8, 4)
	P.Poly({ { 4, 21 }, { 4, 19 }, { 7, 15.5 }, { 12, 15 }, { 17, 15.5 }, { 20, 19 }, { 20, 21 } })
end

Icons.info = function(P)
	P.Circle(12, 12, 9)
	P.Line(12, 11, 12, 16.5)
	P.Dot(12, 7.8, 1)
end

Icons.wings = function(P)
	for _, sx in ipairs({ -1, 1 }) do
		P.Poly({ { 12, 17 }, { 12 + sx * 4, 12 }, { 12 + sx * 10, 6 } })
		P.Poly({ { 12, 17 }, { 12 + sx * 6, 14 }, { 12 + sx * 10.5, 10.5 } })
		P.Poly({ { 12, 17 }, { 12 + sx * 5, 17 }, { 12 + sx * 8, 15.5 } })
	end
	P.Line(12, 10, 12, 19)
end

function Library:AddIcon(name, builder)
	Icons[name] = builder
end

local function CreateIcon(name, parent, size, color)
	local asset = AssetOf(name)
	if asset then
		local img = New("ImageLabel", {
			Size = UDim2.fromOffset(size, size),
			Image = asset,
			ImageColor3 = color,
			Parent = parent,
		})
		return {
			Root = img,
			SetColor = function(_, c)
				img.ImageColor3 = c
			end,
		}
	end

	local s = size / 24
	local th = math.max(1.4, size / 12)
	local root = New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(size, size), Parent = parent })
	local strokes, fills = {}, {}
	local P = {}

	local function AddStroke(f)
		strokes[#strokes + 1] = New("UIStroke", {
			Color = color,
			Thickness = th,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Parent = f,
		})
	end

	function P.Rect(x, y, w, h, r, rot)
		local f = New("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(x * s + th, y * s + th),
			Size = UDim2.fromOffset(math.max(w * s - th * 2, 1), math.max(h * s - th * 2, 1)),
			Rotation = rot or 0,
			Parent = root,
		})
		New("UICorner", { CornerRadius = UDim.new(0, (r or 0) * s), Parent = f })
		AddStroke(f)
	end

	function P.Oval(cx, cy, w, h, rot)
		local f = New("Frame", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(cx * s, cy * s),
			Size = UDim2.fromOffset(math.max(w * s - th * 2, 1), math.max(h * s - th * 2, 1)),
			Rotation = rot or 0,
			Parent = root,
		})
		New("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = f })
		AddStroke(f)
	end

	function P.Circle(cx, cy, r, filled)
		local d = r * 2 * s
		local f
		if filled then
			f = New("Frame", {
				BackgroundColor3 = color,
				Position = UDim2.fromOffset((cx - r) * s, (cy - r) * s),
				Size = UDim2.fromOffset(d, d),
				Parent = root,
			})
			fills[#fills + 1] = f
		else
			f = New("Frame", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset((cx - r) * s + th, (cy - r) * s + th),
				Size = UDim2.fromOffset(math.max(d - th * 2, 1), math.max(d - th * 2, 1)),
				Parent = root,
			})
			AddStroke(f)
		end
		New("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = f })
	end

	function P.Dot(cx, cy, r)
		P.Circle(cx, cy, r, true)
	end

	function P.Line(x1, y1, x2, y2)
		local dx, dy = (x2 - x1) * s, (y2 - y1) * s
		local len = math.sqrt(dx * dx + dy * dy)
		local f = New("Frame", {
			BackgroundColor3 = color,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset((x1 + x2) / 2 * s, (y1 + y2) / 2 * s),
			Size = UDim2.fromOffset(len, th),
			Rotation = math.deg(math.atan2(dy, dx)),
			Parent = root,
		})
		New("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = f })
		fills[#fills + 1] = f
	end

	function P.Poly(points)
		for i = 1, #points - 1 do
			P.Line(points[i][1], points[i][2], points[i + 1][1], points[i + 1][2])
		end
		for i = 1, #points do
			local pt = points[i]
			local j = New("Frame", {
				BackgroundColor3 = color,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromOffset(pt[1] * s, pt[2] * s),
				Size = UDim2.fromOffset(th, th),
				Parent = root,
			})
			New("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = j })
			fills[#fills + 1] = j
		end
	end

	local builder = Icons[name]
	if builder then
		builder(P)
	else
		P.Circle(12, 12, 8)
	end

	local obj = { Root = root }
	function obj:SetColor(c, animate)
		for _, st in ipairs(strokes) do
			if animate then
				Tween(st, { Color = c }, 0.15)
			else
				st.Color = c
			end
		end
		for _, f in ipairs(fills) do
			if animate then
				Tween(f, { BackgroundColor3 = c }, 0.15)
			else
				f.BackgroundColor3 = c
			end
		end
	end
	return obj
end

local function CenterIcon(icon)
	icon.Root.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.Root.Position = UDim2.fromScale(0.5, 0.5)
	return icon
end

local function BuildLogo(parent, size, logo)
	local asset = AssetOf(logo)
	if asset then
		return New("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(size, size),
			Image = asset,
			Parent = parent,
		})
	end
	local ic = CreateIcon("wings", parent, size, Color3.fromRGB(139, 92, 246))
	CenterIcon(ic)
	return ic.Root
end

------------------------------------------------------------------------
-- CONTAINER  (page / column / card / sub-tab page)  - ทุกอย่างวางในนี้
------------------------------------------------------------------------
local Container = {}
Container.__index = Container

local function NewContainer(frame, window)
	return setmetatable({ Frame = frame, Window = window, _o = 0 }, Container)
end

function Container:_n()
	self._o = self._o + 1
	return self._o
end

function Container:_box(height)
	local f = New("Frame", {
		Size = UDim2.new(1, 0, 0, height),
		BackgroundColor3 = Theme.Box,
		LayoutOrder = self:_n(),
		Parent = self.Frame,
	})
	Corner(f, 8)
	Stroke(f, Theme.BoxStroke, 1)
	return f
end

local function RowText(box, name, desc, rightPad)
	local title = New("TextLabel", {
		Text = name or "",
		TextSize = 12,
		Weight = Enum.FontWeight.SemiBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.fromOffset(10, desc and 7 or 0),
		Size = UDim2.new(1, -(10 + (rightPad or 10)), desc and 0 or 1, desc and 15 or 0),
		Parent = box,
	})
	local d
	if desc then
		d = New("TextLabel", {
			Text = desc,
			TextSize = 11,
			TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Position = UDim2.fromOffset(10, 23),
			Size = UDim2.new(1, -(10 + (rightPad or 10)), 0, 14),
			Parent = box,
		})
	end
	return title, d
end

function Container:AddSpacer(h)
	return New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, h or 6),
		LayoutOrder = self:_n(),
		Parent = self.Frame,
	})
end

-- Header "Hello, name" ---------------------------------------------------
function Container:AddHeader(o)
	o = o or {}
	local card = New("Frame", {
		Size = UDim2.new(1, 0, 0, 75),
		BackgroundColor3 = Theme.Card,
		LayoutOrder = self:_n(),
		Parent = self.Frame,
	})
	Corner(card, 10)
	Stroke(card, Theme.CardStroke, 1)

	local av = New("Frame", {
		Position = UDim2.fromOffset(9, 7),
		Size = UDim2.fromOffset(60, 60),
		BackgroundColor3 = Theme.Box,
		Parent = card,
	})
	Corner(av, 10)
	Stroke(av, Theme.BoxStroke, 1)
	local img = New("ImageLabel", {
		Size = UDim2.fromScale(1, 1),
		ScaleType = Enum.ScaleType.Fit,
		Parent = av,
	})
	task.spawn(function()
		local uid = o.UserId or LocalPlayer.UserId
		local ok, url = pcall(function()
			return Players:GetUserThumbnailAsync(uid, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size150x150)
		end)
		if ok and url then
			img.Image = url
		end
	end)

	local greeting = o.Greeting or "Hello"
	local nameText = o.Name or LocalPlayer.DisplayName
	local title = New("TextLabel", {
		Text = greeting .. ", " .. nameText,
		TextColor3 = Theme.AccentText,
		TextSize = 18,
		Weight = Enum.FontWeight.Bold,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.fromOffset(83, 16),
		Size = UDim2.new(1, -93, 0, 26),
		Parent = card,
	})
	local sub = New("TextLabel", {
		Text = o.Subtitle or ("@" .. LocalPlayer.Name),
		TextColor3 = Color3.fromRGB(170, 175, 188),
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.fromOffset(83, 42),
		Size = UDim2.new(1, -93, 0, 16),
		Parent = card,
	})

	local obj = { Frame = card }
	function obj:SetName(n)
		nameText = n
		title.Text = greeting .. ", " .. n
	end
	function obj:SetSubtitle(t)
		sub.Text = t
	end
	return obj
end

-- Sub tabs (Details | Script Logs | UI Logs) -----------------------------
function Container:AddSubTabs(list)
	local bar = New("Frame", {
		Size = UDim2.new(1, 0, 0, 49),
		BackgroundColor3 = Theme.Card,
		LayoutOrder = self:_n(),
		Parent = self.Frame,
	})
	Corner(bar, 10)
	Stroke(bar, Theme.CardStroke, 1)
	Pad(bar, 6, 6, 6, 6)
	List(bar, Enum.FillDirection.Horizontal, 6)

	local n = #list
	local pages, items = {}, {}

	local function Select(idx)
		for i, it in ipairs(items) do
			local active = (i == idx)
			pages[i].Frame.Visible = active
			Tween(it.btn, { BackgroundColor3 = active and Theme.BoxHover or Theme.Box }, 0.15)
			Tween(it.stroke, { Color = active and Color3.fromRGB(31, 37, 54) or Theme.BoxStroke }, 0.15)
			it.icon:SetColor(active and Theme.Accent or Theme.Icon, true)
			Tween(it.label, { TextColor3 = active and Theme.Text or Color3.fromRGB(190, 195, 208) }, 0.15)
		end
	end
	pages.Select = Select

	for i, info in ipairs(list) do
		local btn = New("TextButton", {
			Size = UDim2.new(1 / n, -6 * (n - 1) / n, 1, 0),
			BackgroundTransparency = 0,
			BackgroundColor3 = Theme.Box,
			LayoutOrder = i,
			Parent = bar,
		})
		Corner(btn, 8)
		local st = Stroke(btn, Theme.BoxStroke, 1)
		local inner = New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = btn })
		List(inner, Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center)
		local icon = CreateIcon(info.Icon or "grid", inner, 16, Theme.Icon)
		icon.Root.LayoutOrder = 1
		local label = New("TextLabel", {
			Text = info.Name or ("Tab " .. i),
			TextSize = 14,
			Weight = Enum.FontWeight.SemiBold,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 16),
			LayoutOrder = 2,
			Parent = inner,
		})
		items[i] = { btn = btn, stroke = st, icon = icon, label = label }
		btn.Activated:Connect(function()
			Select(i)
			if self.Window then
				self.Window:_log("Sub tab: " .. tostring(info.Name), "info")
			end
		end)
	end

	for i = 1, n do
		local pf = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Visible = false,
			LayoutOrder = self:_n(),
			Parent = self.Frame,
		})
		List(pf, Enum.FillDirection.Vertical, 8)
		pages[i] = NewContainer(pf, self.Window)
	end
	Select(1)
	return pages
end

-- Columns ----------------------------------------------------------------
function Container:AddColumns(weights)
	weights = weights or { 0.5, 0.5 }
	local gap = 9
	local n = #weights
	local total = 0
	for _, w in ipairs(weights) do
		total = total + w
	end
	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = self:_n(),
		Parent = self.Frame,
	})
	List(row, Enum.FillDirection.Horizontal, gap)
	local cols = {}
	for i, w in ipairs(weights) do
		local nw = w / total
		local col = New("Frame", {
			Size = UDim2.new(nw, -nw * gap * (n - 1), 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = i,
			Parent = row,
		})
		List(col, Enum.FillDirection.Vertical, gap)
		cols[i] = NewContainer(col, self.Window)
	end
	return cols
end

-- Card (Server / Friends) ---------------------------------------------------
function Container:AddCard(o)
	o = o or {}
	local card = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Card,
		LayoutOrder = self:_n(),
		Parent = self.Frame,
	})
	Corner(card, 10)
	Stroke(card, Theme.CardStroke, 1)
	Pad(card, 3, 3, 3, 3)
	List(card, Enum.FillDirection.Vertical, 3)
	local c = NewContainer(card, self.Window)

	if o.Title then
		local head = New("Frame", {
			Size = UDim2.new(1, 0, 0, o.Subtitle and 52 or 34),
			BackgroundTransparency = 1,
			LayoutOrder = c:_n(),
			Parent = card,
		})
		c.TitleLabel = New("TextLabel", {
			Text = o.Title,
			TextSize = 16,
			Weight = Enum.FontWeight.Bold,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(13, o.Subtitle and 11 or 0),
			Size = UDim2.new(1, -26, 0, o.Subtitle and 20 or 34),
			Parent = head,
		})
		if o.Subtitle then
			c.SubtitleLabel = New("TextLabel", {
				Text = o.Subtitle,
				TextSize = 11,
				TextColor3 = Theme.SubText,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Position = UDim2.fromOffset(13, 31),
				Size = UDim2.new(1, -26, 0, 15),
				Parent = head,
			})
		end
	end
	return c
end

-- Stat boxes -----------------------------------------------------------------
function Container:AddStatRow(stats)
	local n = #stats
	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, 43),
		BackgroundTransparency = 1,
		LayoutOrder = self:_n(),
		Parent = self.Frame,
	})
	List(row, Enum.FillDirection.Horizontal, 3)
	local out = {}
	for i, s in ipairs(stats) do
		local box = New("Frame", {
			Size = UDim2.new(1 / n, -3 * (n - 1) / n, 1, 0),
			BackgroundColor3 = Theme.Box,
			LayoutOrder = i,
			Parent = row,
		})
		Corner(box, 8)
		Stroke(box, Theme.BoxStroke, 1)
		local t = New("TextLabel", {
			Text = s.Title or "",
			TextSize = 12,
			Weight = Enum.FontWeight.Bold,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Position = UDim2.fromOffset(10, 6),
			Size = UDim2.new(1, -16, 0, 15),
			Parent = box,
		})
		local v = New("TextLabel", {
			Text = tostring(s.Value or "-"),
			TextSize = 12,
			TextColor3 = Theme.Value,
			Weight = Enum.FontWeight.Regular,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Position = UDim2.fromOffset(10, 22),
			Size = UDim2.new(1, -16, 0, 15),
			Parent = box,
		})
		out[i] = {
			Frame = box,
			Set = function(_, val)
				v.Text = tostring(val)
			end,
			SetTitle = function(_, val)
				t.Text = tostring(val)
			end,
		}
	end
	return out
end

-- Gradient info card (Delta / Discord) -----------------------------------
function Container:AddInfoCard(o)
	o = o or {}
	local style = Library.InfoStyles[o.Style or "Green"] or Library.InfoStyles.Green
	local card = New("Frame", {
		Size = UDim2.new(1, 0, 0, o.Height or 92),
		BackgroundColor3 = Color3.new(1, 1, 1),
		ClipsDescendants = true,
		LayoutOrder = self:_n(),
		Parent = self.Frame,
	})
	Corner(card, 10)
	local st = Stroke(card, style.Stroke, 1)
	local grad = Gradient(card, o.Colors or style.Colors, style.Rotation)

	local title = New("TextLabel", {
		Text = o.Title or "",
		TextSize = 17,
		Weight = Enum.FontWeight.Bold,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.fromOffset(18, 17),
		Size = UDim2.new(1, -36, 0, 24),
		Parent = card,
	})
	local content = New("TextLabel", {
		Text = o.Content or "",
		TextSize = 13,
		TextColor3 = style.Content,
		Weight = Enum.FontWeight.Regular,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Position = UDim2.fromOffset(18, 42),
		Size = UDim2.new(1, -36, 1, -48),
		Parent = card,
	})

	if o.Callback then
		local click = New("TextButton", { Size = UDim2.fromScale(1, 1), Parent = card })
		click.Activated:Connect(function()
			Fire(o.Callback)
		end)
	end

	local obj = { Frame = card }
	function obj:SetTitle(t)
		title.Text = t
	end
	function obj:SetContent(t)
		content.Text = t
	end
	function obj:SetStyle(name)
		local s = Library.InfoStyles[name]
		if not s then
			return
		end
		st.Color = s.Stroke
		content.TextColor3 = s.Content
		grad:Destroy()
		grad = Gradient(card, s.Colors, s.Rotation)
	end
	return obj
end

-- Label / Paragraph -------------------------------------------------------
function Container:AddLabel(text)
	local l = New("TextLabel", {
		Text = text or "",
		TextSize = 12,
		TextColor3 = Theme.SubText,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		LayoutOrder = self:_n(),
		Parent = self.Frame,
	})
	Pad(l, 8, 3, 8, 3)
	return {
		Frame = l,
		SetText = function(_, t)
			l.Text = t
		end,
	}
end

function Container:AddParagraph(o)
	o = o or {}
	local box = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Box,
		LayoutOrder = self:_n(),
		Parent = self.Frame,
	})
	Corner(box, 8)
	Stroke(box, Theme.BoxStroke, 1)
	Pad(box, 10, 8, 10, 9)
	List(box, Enum.FillDirection.Vertical, 3)
	local t = New("TextLabel", {
		Text = o.Title or "",
		TextSize = 12,
		Weight = Enum.FontWeight.SemiBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		TextWrapped = true,
		LayoutOrder = 1,
		Parent = box,
	})
	local c = New("TextLabel", {
		Text = o.Content or "",
		TextSize = 11,
		TextColor3 = Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		TextWrapped = true,
		LayoutOrder = 2,
		Parent = box,
	})
	return {
		Frame = box,
		SetTitle = function(_, v)
			t.Text = v
		end,
		SetContent = function(_, v)
			c.Text = v
		end,
	}
end

-- Toggle --------------------------------------------------------------------
function Container:AddToggle(o)
	o = o or {}
	local box = self:_box(o.Description and 44 or 36)
	RowText(box, o.Name, o.Description, 56)
	local sw = New("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(34, 18),
		BackgroundColor3 = Theme.Off,
		Parent = box,
	})
	Corner(sw, 9)
	local knob = New("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 2, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = sw,
	})
	Corner(knob, 7)
	local btn = New("TextButton", { Size = UDim2.fromScale(1, 1), Parent = box })

	local obj = { Type = "Toggle", Value = false, Frame = box }
	function obj:Set(v, silent)
		v = v and true or false
		obj.Value = v
		Tween(sw, { BackgroundColor3 = v and Theme.Accent or Theme.Off }, 0.15)
		Tween(knob, { Position = v and UDim2.new(0, 18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0) }, 0.15)
		if o.Flag then
			Library.Flags[o.Flag] = v
		end
		if not silent then
			Fire(o.Callback, v)
		end
	end
	btn.Activated:Connect(function()
		obj:Set(not obj.Value)
		if self.Window then
			self.Window:_log(tostring(o.Name) .. " -> " .. tostring(obj.Value), obj.Value and "ok" or "info")
		end
	end)
	btn.MouseEnter:Connect(function()
		Tween(box, { BackgroundColor3 = Theme.BoxHover }, 0.12)
	end)
	btn.MouseLeave:Connect(function()
		Tween(box, { BackgroundColor3 = Theme.Box }, 0.12)
	end)
	obj:Set(o.Default or false, not o.Default)
	if o.Flag then
		Library.Options[o.Flag] = obj
	end
	if self.Window then
		self.Window:_register(box, o.Name)
	end
	return obj
end

-- Button --------------------------------------------------------------------
function Container:AddButton(o)
	o = o or {}
	local box = self:_box(o.Description and 44 or 36)
	RowText(box, o.Name, o.Description, 34)
	local arrow = CreateIcon("chevron", box, 12, Theme.SubText)
	arrow.Root.Rotation = -90
	arrow.Root.AnchorPoint = Vector2.new(1, 0.5)
	arrow.Root.Position = UDim2.new(1, -12, 0.5, 0)
	local btn = New("TextButton", { Size = UDim2.fromScale(1, 1), Parent = box })
	btn.MouseEnter:Connect(function()
		Tween(box, { BackgroundColor3 = Theme.BoxHover }, 0.12)
		arrow:SetColor(Theme.Accent, true)
	end)
	btn.MouseLeave:Connect(function()
		Tween(box, { BackgroundColor3 = Theme.Box }, 0.12)
		arrow:SetColor(Theme.SubText, true)
	end)
	btn.Activated:Connect(function()
		local st = box:FindFirstChildOfClass("UIStroke")
		if st then
			st.Color = Theme.Accent
			Tween(st, { Color = Theme.BoxStroke }, 0.35)
		end
		if self.Window then
			self.Window:_log("Button: " .. tostring(o.Name), "info")
		end
		Fire(o.Callback)
	end)
	if self.Window then
		self.Window:_register(box, o.Name)
	end
	return { Frame = box }
end

-- Slider --------------------------------------------------------------------
function Container:AddSlider(o)
	o = o or {}
	local min, max = o.Min or 0, o.Max or 100
	local inc = o.Increment or 1
	local box = self:_box(50)
	RowText(box, o.Name, nil, 80)
	box:FindFirstChildOfClass("TextLabel").Size = UDim2.new(1, -90, 0, 24)
	box:FindFirstChildOfClass("TextLabel").Position = UDim2.fromOffset(10, 2)
	local valueLabel = New("TextLabel", {
		TextSize = 12,
		TextColor3 = Theme.Value,
		TextXAlignment = Enum.TextXAlignment.Right,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 2),
		Size = UDim2.fromOffset(80, 24),
		Parent = box,
	})
	local bar = New("Frame", {
		Position = UDim2.fromOffset(10, 33),
		Size = UDim2.new(1, -20, 0, 6),
		BackgroundColor3 = Theme.Off,
		Parent = box,
	})
	Corner(bar, 3)
	local fill = New("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = Theme.Accent, Parent = bar })
	Corner(fill, 3)
	local knob = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(12, 12),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = bar,
	})
	Corner(knob, 6)
	local hit = New("TextButton", { Position = UDim2.fromOffset(0, 24), Size = UDim2.new(1, 0, 0, 26), Parent = box })

	local obj = { Type = "Slider", Value = min, Frame = box }
	function obj:Set(v, silent)
		v = math.clamp(v, min, max)
		v = math.floor((v - min) / inc + 0.5) * inc + min
		v = math.clamp(math.floor(v * 1000 + 0.5) / 1000, min, max)
		obj.Value = v
		local rel = (max == min) and 0 or (v - min) / (max - min)
		fill.Size = UDim2.fromScale(rel, 1)
		knob.Position = UDim2.fromScale(rel, 0.5)
		valueLabel.Text = tostring(v) .. (o.Suffix or "")
		if o.Flag then
			Library.Flags[o.Flag] = v
		end
		if not silent then
			Fire(o.Callback, v)
		end
	end

	local dragging = false
	local function FromX(x)
		local rel = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
		obj:Set(min + (max - min) * rel)
	end
	hit.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			FromX(input.Position.X)
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	local conn = UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			FromX(input.Position.X)
		end
	end)
	if self.Window then
		self.Window._conns[#self.Window._conns + 1] = conn
		self.Window:_register(box, o.Name)
	end

	obj:Set(o.Default or min, true)
	if o.Flag then
		Library.Options[o.Flag] = obj
	end
	return obj
end

-- Dropdown ------------------------------------------------------------------
function Container:AddDropdown(o)
	o = o or {}
	local multi = o.Multi and true or false
	local holder = New("Frame", {
		Size = UDim2.new(1, 0, 0, 36),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Box,
		ClipsDescendants = true,
		LayoutOrder = self:_n(),
		Parent = self.Frame,
	})
	Corner(holder, 8)
	Stroke(holder, Theme.BoxStroke, 1)
	List(holder, Enum.FillDirection.Vertical, 0)

	local head = New("TextButton", { Size = UDim2.new(1, 0, 0, 36), LayoutOrder = 1, Parent = holder })
	New("TextLabel", {
		Text = o.Name or "",
		TextSize = 12,
		Weight = Enum.FontWeight.SemiBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(0.5, -10, 1, 0),
		Parent = head,
	})
	local valueLabel = New("TextLabel", {
		TextSize = 12,
		TextColor3 = Theme.Value,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextTruncate = Enum.TextTruncate.AtEnd,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -32, 0, 0),
		Size = UDim2.new(0.5, -32, 1, 0),
		Parent = head,
	})
	local chev = CreateIcon("chevron", head, 12, Theme.SubText)
	chev.Root.AnchorPoint = Vector2.new(1, 0.5)
	chev.Root.Position = UDim2.new(1, -12, 0.5, 0)

	local listFrame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Visible = false,
		LayoutOrder = 2,
		Parent = holder,
	})
	Pad(listFrame, 4, 0, 4, 4)
	List(listFrame, Enum.FillDirection.Vertical, 2)

	local obj = { Type = "Dropdown", Options = o.Options or {}, Frame = holder }
	local selected = {}
	local buttons = {}
	local open = false

	local function Display()
		if multi then
			local arr = {}
			for _, opt in ipairs(obj.Options) do
				if selected[opt] then
					arr[#arr + 1] = opt
				end
			end
			obj.Value = arr
			valueLabel.Text = (#arr > 0) and table.concat(arr, ", ") or "None"
		else
			valueLabel.Text = obj.Value and tostring(obj.Value) or "None"
		end
		for opt, b in pairs(buttons) do
			local on
			if multi then
				on = selected[opt]
			else
				on = (obj.Value == opt)
			end
			b.label.TextColor3 = on and Theme.AccentText or Theme.Value
			b.btn.BackgroundTransparency = on and 0 or 1
		end
		if o.Flag then
			Library.Flags[o.Flag] = obj.Value
		end
	end

	local function Rebuild()
		for _, b in pairs(buttons) do
			b.btn:Destroy()
		end
		buttons = {}
		for i, opt in ipairs(obj.Options) do
			local b = New("TextButton", {
				Size = UDim2.new(1, 0, 0, 28),
				BackgroundTransparency = 1,
				BackgroundColor3 = Theme.BoxHover,
				LayoutOrder = i,
				Parent = listFrame,
			})
			Corner(b, 6)
			local l = New("TextLabel", {
				Text = tostring(opt),
				TextSize = 12,
				TextColor3 = Theme.Value,
				TextXAlignment = Enum.TextXAlignment.Left,
				Position = UDim2.fromOffset(8, 0),
				Size = UDim2.new(1, -16, 1, 0),
				Parent = b,
			})
			buttons[opt] = { btn = b, label = l }
			b.Activated:Connect(function()
				if multi then
					selected[opt] = not selected[opt]
					Display()
					Fire(o.Callback, obj.Value)
				else
					obj.Value = opt
					Display()
					Fire(o.Callback, opt)
					open = false
					listFrame.Visible = false
					chev.Root.Rotation = 0
				end
				if self.Window then
					self.Window:_log(tostring(o.Name) .. " -> " .. tostring(opt), "info")
				end
			end)
		end
		Display()
	end

	function obj:Set(v, silent)
		if multi then
			selected = {}
			for _, x in ipairs(v or {}) do
				selected[x] = true
			end
		else
			obj.Value = v
		end
		Display()
		if not silent then
			Fire(o.Callback, obj.Value)
		end
	end
	function obj:SetOptions(list)
		obj.Options = list or {}
		if not multi and obj.Value and not table.find(obj.Options, obj.Value) then
			obj.Value = nil
		end
		Rebuild()
	end

	head.Activated:Connect(function()
		open = not open
		listFrame.Visible = open
		chev.Root.Rotation = open and 180 or 0
	end)

	if multi then
		for _, x in ipairs(o.Default or {}) do
			selected[x] = true
		end
	else
		obj.Value = o.Default
	end
	Rebuild()
	if o.Flag then
		Library.Options[o.Flag] = obj
	end
	if self.Window then
		self.Window:_register(holder, o.Name)
	end
	return obj
end

-- Input ---------------------------------------------------------------------
function Container:AddInput(o)
	o = o or {}
	local box = self:_box(o.Description and 44 or 36)
	RowText(box, o.Name, o.Description, 140)
	local field = New("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(120, 24),
		BackgroundColor3 = Color3.fromRGB(7, 9, 14),
		Parent = box,
	})
	Corner(field, 6)
	local fs = Stroke(field, Theme.BoxStroke, 1)
	local tb = New("TextBox", {
		Text = o.Default or "",
		PlaceholderText = o.Placeholder or "...",
		PlaceholderColor3 = Color3.fromRGB(88, 94, 110),
		TextSize = 12,
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.fromOffset(8, 0),
		Size = UDim2.new(1, -16, 1, 0),
		Parent = field,
	})
	local obj = { Type = "Input", Value = tb.Text, Frame = box }
	function obj:Set(v, silent)
		tb.Text = tostring(v)
		obj.Value = tb.Text
		if o.Flag then
			Library.Flags[o.Flag] = obj.Value
		end
		if not silent then
			Fire(o.Callback, obj.Value)
		end
	end
	tb.Focused:Connect(function()
		Tween(fs, { Color = Theme.Accent }, 0.12)
	end)
	tb.FocusLost:Connect(function()
		Tween(fs, { Color = Theme.BoxStroke }, 0.12)
		if o.Numeric then
			local n = tonumber(tb.Text)
			tb.Text = n and tostring(n) or ""
		end
		obj.Value = tb.Text
		if o.Flag then
			Library.Flags[o.Flag] = obj.Value
		end
		Fire(o.Callback, obj.Value)
	end)
	if o.Flag then
		Library.Flags[o.Flag] = obj.Value
		Library.Options[o.Flag] = obj
	end
	if self.Window then
		self.Window:_register(box, o.Name)
	end
	return obj
end

-- Log box (Script Logs / UI Logs) -----------------------------------------
local LogColors = {
	info = Color3.fromRGB(190, 195, 208),
	ok = Color3.fromRGB(96, 214, 140),
	warn = Color3.fromRGB(240, 190, 80),
	error = Color3.fromRGB(240, 100, 110),
}

function Container:AddLog(o)
	o = o or {}
	local maxLines = o.MaxLines or 200
	local box = self:_box(o.Height or 170)
	local scroll = New("ScrollingFrame", {
		Position = UDim2.fromOffset(6, 6),
		Size = UDim2.new(1, -12, 1, -12),
		BackgroundTransparency = 1,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Color3.fromRGB(45, 52, 72),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		BorderSizePixel = 0,
		Parent = box,
	})
	List(scroll, Enum.FillDirection.Vertical, 2)
	Pad(scroll, 4, 2, 6, 2)
	local lines = {}
	local log = { Frame = box }
	function log:Add(text, kind)
		local l = New("TextLabel", {
			Text = "[" .. os.date("%H:%M:%S") .. "] " .. tostring(text),
			TextSize = 11,
			TextColor3 = LogColors[kind or "info"] or LogColors.info,
			Font = Enum.Font.Code,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			LayoutOrder = #lines + 1,
			Parent = scroll,
		})
		lines[#lines + 1] = l
		if #lines > maxLines then
			local first = table.remove(lines, 1)
			first:Destroy()
		end
		task.defer(function()
			if scroll.Parent then
				scroll.CanvasPosition = Vector2.new(0, 1e6)
			end
		end)
	end
	function log:Clear()
		for _, l in ipairs(lines) do
			l:Destroy()
		end
		lines = {}
	end
	return log
end

------------------------------------------------------------------------
-- WINDOW
------------------------------------------------------------------------
local WindowClass = {}
WindowClass.__index = WindowClass

local SB_W = 60
local TOP_H = 49

local function GetGuiParent()
	local ok, hui = pcall(function()
		return gethui and gethui()
	end)
	if ok and hui then
		return hui
	end
	local ok2 = pcall(function()
		return CoreGui.Name
	end)
	if ok2 then
		return CoreGui
	end
	return LocalPlayer:WaitForChild("PlayerGui")
end

function WindowClass:_n()
	self._order = self._order + 1
	return self._order
end

function WindowClass:_register(frame, name)
	if name then
		self._search[#self._search + 1] = { Frame = frame, Name = string.lower(tostring(name)) }
	end
end

function WindowClass:_log(text, kind)
	if self.UILog then
		self.UILog:Add(text, kind)
	end
end

function WindowClass:SetUILog(log)
	self.UILog = log
end

function WindowClass:Search(q)
	q = string.lower(q or "")
	for _, e in ipairs(self._search) do
		if e.Frame and e.Frame.Parent then
			e.Frame.Visible = (q == "") or (e.Name:find(q, 1, true) ~= nil)
		end
	end
end

function WindowClass:SetVisible(v)
	self.Main.Visible = v
	if self._restore then
		self._restore.Visible = not v
	end
end

function WindowClass:Toggle()
	self:SetVisible(not self.Main.Visible)
end

function WindowClass:Minimize()
	self:SetVisible(false)
end

function WindowClass:Destroy()
	for _, c in ipairs(self._conns) do
		pcall(function()
			c:Disconnect()
		end)
	end
	if self.Gui then
		self.Gui:Destroy()
	end
	Fire(self._opts.OnClose)
end

function WindowClass:SetProfile(name, silent)
	self.Profile = name
	self._profileLabel.Text = tostring(name)
	if not silent then
		Fire(self._opts.OnProfileChanged, name)
	end
end

function WindowClass:SetProfiles(list)
	self.Profiles = list
	self:_buildProfiles()
end

function WindowClass:AddDivider(o)
	o = o or {}
	local f = New("Frame", {
		Size = UDim2.fromOffset(40, o.Height or 10),
		BackgroundTransparency = 1,
		LayoutOrder = self:_n(),
		Parent = o.Bottom and self._sideBottom or self._sideTop,
	})
	if o.Line ~= false then
		New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = Theme.Divider,
			Parent = f,
		})
	end
	return f
end

function WindowClass:SelectTab(tab)
	for _, t in ipairs(self.Tabs) do
		local active = (t == tab)
		t.Page.Visible = active
		Tween(t.Button, { BackgroundTransparency = active and 0 or 1 }, 0.15)
		t._icon:SetColor(active and Theme.Accent or Theme.Icon, true)
	end
	self.CurrentTab = tab
end

function WindowClass:AddTab(o)
	o = o or {}
	local window = self
	local btn = New("TextButton", {
		Name = o.Name or "Tab",
		Size = UDim2.fromOffset(48, 30),
		BackgroundColor3 = Theme.TabActive,
		BackgroundTransparency = 1,
		LayoutOrder = self:_n(),
		Parent = (o.Position == "Bottom") and self._sideBottom or self._sideTop,
	})
	Corner(btn, 8)
	local icon = CenterIcon(CreateIcon(o.Icon or "grid", btn, o.IconSize or 20, Theme.Icon))

	local page = New("ScrollingFrame", {
		Name = (o.Name or "Tab") .. "Page",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Color3.fromRGB(45, 52, 72),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Visible = false,
		Parent = self._pages,
	})
	Pad(page, 5, 7, 5, 8)
	List(page, Enum.FillDirection.Vertical, 8)

	local tab = NewContainer(page, self)
	tab.Name = o.Name
	tab.Button = btn
	tab.Page = page
	tab._icon = icon
	function tab:Select()
		window:SelectTab(tab)
	end
	self.Tabs[#self.Tabs + 1] = tab

	btn.Activated:Connect(function()
		self:SelectTab(tab)
		self:_log("Tab: " .. tostring(o.Name), "info")
	end)
	btn.MouseEnter:Connect(function()
		if self.CurrentTab ~= tab then
			Tween(btn, { BackgroundTransparency = 0.6 }, 0.12)
		end
	end)
	btn.MouseLeave:Connect(function()
		if self.CurrentTab ~= tab then
			Tween(btn, { BackgroundTransparency = 1 }, 0.12)
		end
	end)

	if #self.Tabs == 1 then
		self:SelectTab(tab)
	end
	return tab
end

function WindowClass:Notify(o)
	o = o or {}
	local n = New("CanvasGroup", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Card,
		GroupTransparency = 1,
		Parent = self._notif,
	})
	Corner(n, 10)
	Stroke(n, Theme.CardStroke, 1)
	New("Frame", { Size = UDim2.new(0, 3, 1, 0), BackgroundColor3 = Theme.Accent, Parent = n })
	local inner = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = n,
	})
	Pad(inner, 14, 9, 12, 10)
	List(inner, Enum.FillDirection.Vertical, 2)
	New("TextLabel", {
		Text = o.Title or "Notification",
		TextSize = 13,
		Weight = Enum.FontWeight.Bold,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		TextWrapped = true,
		LayoutOrder = 1,
		Parent = inner,
	})
	if o.Content then
		New("TextLabel", {
			Text = o.Content,
			TextSize = 12,
			TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			TextWrapped = true,
			LayoutOrder = 2,
			Parent = inner,
		})
	end
	Tween(n, { GroupTransparency = 0 }, 0.2)
	task.delay(o.Duration or 4, function()
		if n.Parent then
			local t = Tween(n, { GroupTransparency = 1 }, 0.25)
			t.Completed:Wait()
			n:Destroy()
		end
	end)
end

function WindowClass:_buildProfiles()
	for _, c in ipairs(self._ddFrame:GetChildren()) do
		if c:IsA("TextButton") then
			c:Destroy()
		end
	end
	for i, name in ipairs(self.Profiles) do
		local b = New("TextButton", {
			Size = UDim2.new(1, 0, 0, 26),
			BackgroundColor3 = Theme.BoxHover,
			BackgroundTransparency = 1,
			LayoutOrder = i,
			ZIndex = 11,
			Parent = self._ddFrame,
		})
		Corner(b, 6)
		New("TextLabel", {
			Text = tostring(name),
			TextSize = 12,
			TextColor3 = Theme.Value,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(8, 0),
			Size = UDim2.new(1, -16, 1, 0),
			ZIndex = 12,
			Parent = b,
		})
		b.MouseEnter:Connect(function()
			Tween(b, { BackgroundTransparency = 0 }, 0.1)
		end)
		b.MouseLeave:Connect(function()
			Tween(b, { BackgroundTransparency = 1 }, 0.1)
		end)
		b.Activated:Connect(function()
			self:SetProfile(name)
			self._ddFrame.Visible = false
			self._chev.Root.Rotation = 0
		end)
	end
end

function Library:CreateWindow(opts)
	opts = opts or {}
	local win = setmetatable({
		Tabs = {},
		Profiles = opts.Profiles or { "Default" },
		Profile = opts.Profile or "Default",
		_opts = opts,
		_conns = {},
		_search = {},
		_order = 0,
	}, WindowClass)

	local parent = GetGuiParent()
	local guiName = opts.GuiName or "DeltaUILibrary"
	local old = parent:FindFirstChild(guiName)
	if old then
		old:Destroy()
	end

	local gui = New("ScreenGui", {
		Name = guiName,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
		DisplayOrder = 999,
	})
	pcall(function()
		if syn and syn.protect_gui then
			syn.protect_gui(gui)
		end
	end)
	gui.Parent = parent
	win.Gui = gui

	local size = opts.Size or UDim2.fromOffset(640, 384)
	local main = New("Frame", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = size,
		BackgroundColor3 = Theme.Window,
		ClipsDescendants = true,
		Parent = gui,
	})
	Corner(main, 12)
	Stroke(main, Theme.WindowStroke, 1)
	local uiScale = New("UIScale", { Parent = main })
	win.Main = main

	local function Fit()
		local cam = workspace.CurrentCamera
		if not cam then
			return
		end
		local vp = cam.ViewportSize
		local sc = math.min(1, (vp.X - 16) / size.X.Offset, (vp.Y - 16) / size.Y.Offset)
		uiScale.Scale = math.max(sc, 0.4)
	end
	Fit()
	if workspace.CurrentCamera then
		win._conns[#win._conns + 1] = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(Fit)
	end
	local function GetScale()
		return uiScale.Scale
	end

	-- Sidebar ---------------------------------------------------------------
	local sidebar = New("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, SB_W, 1, 0),
		BackgroundTransparency = 1,
		Parent = main,
	})
	local sideTop = New("Frame", {
		Size = UDim2.new(1, 0, 1, -44),
		BackgroundTransparency = 1,
		Parent = sidebar,
	})
	Pad(sideTop, 0, 3, 0, 0)
	List(sideTop, Enum.FillDirection.Vertical, 5, Enum.HorizontalAlignment.Center)
	win._sideTop = sideTop

	local sideBottom = New("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, -5),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = sidebar,
	})
	List(sideBottom, Enum.FillDirection.Vertical, 5, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Bottom)
	win._sideBottom = sideBottom

	-- logo
	local logoBox = New("Frame", {
		Size = UDim2.fromOffset(38, 38),
		BackgroundColor3 = Color3.fromRGB(4, 5, 8),
		LayoutOrder = win:_n(),
		Parent = sideTop,
	})
	Corner(logoBox, 10)
	Stroke(logoBox, Color3.fromRGB(18, 21, 30), 1)
	BuildLogo(logoBox, 28, opts.Logo)
	win:AddDivider({ Height = 10 })

	-- avatar (bottom)
	if opts.ShowAvatar ~= false then
		local av = New("ImageLabel", {
			Size = UDim2.fromOffset(30, 30),
			ScaleType = Enum.ScaleType.Fit,
			LayoutOrder = win:_n(),
			Parent = sideBottom,
		})
		task.spawn(function()
			local ok, url = pcall(function()
				return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size100x100)
			end)
			if ok and url then
				av.Image = url
			end
		end)
	end

	-- Content -----------------------------------------------------------------
	local content = New("Frame", {
		Name = "Content",
		Position = UDim2.fromOffset(SB_W, 0),
		Size = UDim2.new(1, -SB_W, 1, 0),
		BackgroundColor3 = Theme.Content,
		ClipsDescendants = true,
		Parent = main,
	})
	Corner(content, 12)

	local pages = New("Frame", {
		Position = UDim2.fromOffset(0, TOP_H),
		Size = UDim2.new(1, 0, 1, -TOP_H),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = content,
	})
	win._pages = pages

	-- Topbar ------------------------------------------------------------------
	local topbar = New("Frame", {
		Name = "Topbar",
		Size = UDim2.new(1, 0, 0, TOP_H),
		BackgroundTransparency = 1,
		ZIndex = 2,
		Parent = content,
	})
	New("Frame", {
		Position = UDim2.new(0, 5, 0, TOP_H - 1),
		Size = UDim2.new(1, -10, 0, 1),
		BackgroundColor3 = Theme.Divider,
		Parent = topbar,
	})

	local profile = New("TextButton", {
		Position = UDim2.fromOffset(9, 9),
		Size = UDim2.fromOffset(112, 31),
		BackgroundTransparency = 0,
		BackgroundColor3 = Theme.Box,
		Parent = topbar,
	})
	Corner(profile, 8)
	Stroke(profile, Theme.BoxStroke, 1)

	local editBtn = New("TextButton", {
		Position = UDim2.fromOffset(2, 3),
		Size = UDim2.fromOffset(26, 25),
		Parent = profile,
	})
	local editIcon = CenterIcon(CreateIcon("edit", editBtn, 16, Theme.Icon))
	editBtn.MouseEnter:Connect(function()
		editIcon:SetColor(Theme.Accent, true)
	end)
	editBtn.MouseLeave:Connect(function()
		editIcon:SetColor(Theme.Icon, true)
	end)
	editBtn.Activated:Connect(function()
		Fire(opts.OnProfileEdit, win.Profile)
	end)

	win._profileLabel = New("TextLabel", {
		Text = tostring(win.Profile),
		TextSize = 13,
		TextColor3 = Color3.fromRGB(196, 200, 212),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.fromOffset(34, 0),
		Size = UDim2.new(1, -56, 1, 0),
		Parent = profile,
	})
	win._chev = CreateIcon("chevron", profile, 12, Theme.Icon)
	win._chev.Root.AnchorPoint = Vector2.new(1, 0.5)
	win._chev.Root.Position = UDim2.new(1, -9, 0.5, 0)

	win._ddFrame = New("Frame", {
		Position = UDim2.fromOffset(9, 43),
		Size = UDim2.fromOffset(112, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Card,
		Visible = false,
		ZIndex = 10,
		Parent = content,
	})
	Corner(win._ddFrame, 8)
	Stroke(win._ddFrame, Theme.CardStroke, 1)
	Pad(win._ddFrame, 3, 3, 3, 3)
	List(win._ddFrame, Enum.FillDirection.Vertical, 2)
	win:_buildProfiles()
	profile.Activated:Connect(function()
		win._ddFrame.Visible = not win._ddFrame.Visible
		win._chev.Root.Rotation = win._ddFrame.Visible and 180 or 0
	end)

	-- right icons: search / minimize / close
	local function TopIcon(name, fromRight, iconSize, cb)
		local b = New("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(1, -fromRight, 0.5, -1),
			Size = UDim2.fromOffset(28, 28),
			Parent = topbar,
		})
		local ic = CenterIcon(CreateIcon(name, b, iconSize, Theme.Icon))
		b.MouseEnter:Connect(function()
			ic:SetColor(Theme.Accent, true)
		end)
		b.MouseLeave:Connect(function()
			ic:SetColor(Theme.Icon, true)
		end)
		b.Activated:Connect(cb)
		return b
	end

	-- search box (toggle by search icon)
	local searchFrame = New("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -108, 0.5, -1),
		Size = UDim2.fromOffset(0, 26),
		BackgroundColor3 = Theme.Box,
		ClipsDescendants = true,
		Visible = false,
		Parent = topbar,
	})
	Corner(searchFrame, 8)
	Stroke(searchFrame, Theme.BoxStroke, 1)
	local searchBox = New("TextBox", {
		PlaceholderText = "Search...",
		PlaceholderColor3 = Color3.fromRGB(88, 94, 110),
		Text = "",
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(9, 0),
		Size = UDim2.new(1, -18, 1, 0),
		Parent = searchFrame,
	})
	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		win:Search(searchBox.Text)
	end)
	local searchOpen = false
	TopIcon("search", 92, 17, function()
		searchOpen = not searchOpen
		if searchOpen then
			searchFrame.Visible = true
			Tween(searchFrame, { Size = UDim2.fromOffset(150, 26) }, 0.2)
			searchBox:CaptureFocus()
		else
			searchBox.Text = ""
			win:Search("")
			local t = Tween(searchFrame, { Size = UDim2.fromOffset(0, 26) }, 0.2)
			t.Completed:Connect(function()
				if not searchOpen then
					searchFrame.Visible = false
				end
			end)
		end
	end)
	TopIcon("minus", 52, 15, function()
		win:Minimize()
	end)
	TopIcon("close", 23, 15, function()
		win:Destroy()
	end)

	MakeDraggable(topbar, main, GetScale, win._conns)
	MakeDraggable(sidebar, main, GetScale, win._conns)

	-- Notifications -----------------------------------------------------------
	local notif = New("Frame", {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -12, 1, -12),
		Size = UDim2.new(0, 250, 1, -24),
		BackgroundTransparency = 1,
		Parent = gui,
	})
	List(notif, Enum.FillDirection.Vertical, 6, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)
	win._notif = notif

	-- Restore button (after minimize) ------------------------------------
	local restore = New("TextButton", {
		Name = "Restore",
		Position = UDim2.fromOffset(14, 90),
		Size = UDim2.fromOffset(40, 40),
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.fromRGB(4, 5, 8),
		Visible = false,
		Parent = gui,
	})
	Corner(restore, 10)
	Stroke(restore, Theme.WindowStroke, 1)
	BuildLogo(restore, 28, opts.Logo)
	local rState = MakeDraggable(restore, restore, nil, win._conns)
	restore.Activated:Connect(function()
		if rState.Moved then
			return
		end
		win:SetVisible(true)
	end)
	win._restore = restore

	-- Toggle key ------------------------------------------------------------
	local key = opts.ToggleKey or Enum.KeyCode.RightShift
	win._conns[#win._conns + 1] = UserInputService.InputBegan:Connect(function(input, gp)
		if not gp and input.KeyCode == key then
			win:Toggle()
		end
	end)

	return win
end

function Library:Unload()
	local ok, hui = pcall(GetGuiParent)
	if ok and hui then
		local g = hui:FindFirstChild("DeltaUILibrary")
		if g then
			g:Destroy()
		end
	end
end

return Library
