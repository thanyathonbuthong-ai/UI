--[[
	UILib — Dark glass UI library for Roblox (Luau)
	Version 3.0.0  (หน้าต่างแนวนอน + แท็บด้านซ้าย)

	พอร์ตจาก UI ต้นฉบับแบบตรงทุกค่า: ธีม, ฟอนต์, ขนาด, ระยะห่าง, แอนิเมชัน
	(toggle, slider, range slider, dropdown, text input, list input,
	 color row, color wheel, button, button row, section, window, tooltip,
	 กฎ "หน้าต่างบนสุดรับคลิก" และเอฟเฟกต์กดปุ่ม)

	วิธีใช้อย่างย่อ (ตัวอย่างเต็มอยู่ใน Example.lua):

		local UILib = require(path.to.UILib)
		UILib:Init({ Name = "MyHub", ToggleKey = Enum.KeyCode.RightShift })

		local win = UILib:CreateWindow({ Title = "My Hub" })
		local tab = win:AddTab({ Name = "Combat", Icon = "swords" })
		local sec = tab:AddSection({ Title = "General", Open = true })

		sec:AddToggle({ Name = "Enabled", Default = true, Callback = function(v) end })
		sec:AddSlider({ Name = "Speed", Min = 0, Max = 100, Default = 16, Callback = print })

	ทุก element คืน object ที่มี .Frame, :Get(), :Set(value, silent)
	ใส่ Flag = "ชื่อ" แล้วค่าล่าสุดจะอยู่ที่ UILib.Flags["ชื่อ"]
	UILib.Compact = true  => slider ช่วงกว้างจะกลายเป็นช่องใส่ตัวเลข (เหมือนโหมด compact ต้นฉบับ)
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")

----------------------------------------------------------------------
-- Theme (ค่าเดียวกับต้นฉบับ แก้ได้ก่อนเรียก CreateWindow)
----------------------------------------------------------------------
local theme = {
	TextPrimary = Color3.fromHex("f0f0f4"),
	TextSub = Color3.fromHex("9898a2"),
	TextMuted = Color3.fromHex("686872"),
	TextOnAccent = Color3.fromHex("000000"),
	StatusBad = Color3.fromHex("D50000"),
	StatusGood = Color3.fromHex("2FBF71"),

	SurfaceHeader = Color3.fromHex("18181c"),
	SurfaceElement = Color3.fromHex("26262c"),
	SurfaceHover = Color3.fromHex("303038"),
	SurfaceField = Color3.fromHex("1c1c21"),
	SurfaceSection = Color3.fromHex("1e1e24"),
	SurfaceWell = Color3.fromHex("121216"),
	SurfaceChip = Color3.fromHex("0c0c0f"),
	Hairline = Color3.fromHex("323338"),

	BodyTop = Color3.fromHex("2a2a2f"),
	BodyMid = Color3.fromHex("1a1a1e"),
	BodyBot = Color3.fromHex("101013"),
	BodyTopA = 0.05,
	BodyMidA = 0.13,
	BodyBotA = 0.42,

	SweepSpeed = 0.22,

	AccentA = Color3.fromHex("A30000"),
	AccentMid = Color3.fromHex("F43120"),
	AccentB = Color3.fromHex("D50000"),
	AccentDark = Color3.fromHex("7A0000"),

	RadiusSm = 5,
	RadiusMd = 6,
	RadiusLg = 8,
	GapSm = 6,
	GapMd = 8,
	GapLg = 12,
	GapXl = 14,
	RowH = 34,
	HeaderH = 40,
}

local UILib = {
	Version = "3.0.0",
	Theme = theme,
	Flags = {},
	Compact = false,
	MenuZ = 20,
}

local WHITE = Color3.new(1, 1, 1)
local BLACK = Color3.new(0, 0, 0)

-- ไอคอน (Lucide ผ่าน rbxassetid) ใช้ใน Window/Tab { Icon = "swords" }
local ICONS = {
	plus = 10734924532,
	x = 10747384394,
	pin = 10734922324,
	info = 10723415903,
	check = 10709790644,
	["chevron-down"] = 10709790948,
	["chevron-up"] = 10709791523,
	["chevron-left"] = 10709791281,
	["chevron-right"] = 10709791437,
	crown = 10709818626,
	["trash-2"] = 10747362241,
	swords = 10734975692,
	eye = 10723346959,
	bell = 10709775704,
	coins = 10709811110,
	users = 10747373426,
	palette = 10734910430,
	map = 10734886202,
	camera = 10709789686,
	bug = 10709782845,
	search = 10734943674,
	["alert-triangle"] = 10709753149,
	shield = 10734951847,
}
UILib.Icons = ICONS

----------------------------------------------------------------------
-- Internal state
----------------------------------------------------------------------
local gui -- ScreenGui
local conns = {}
local windows = {}
local libVisible = true
local sweeps = {}
local sweepConn
local tipState = { frame = nil, label = nil, target = nil, showAt = 0, conn = nil }
local topCounter = 0

local function keep(conn)
	conns[#conns + 1] = conn
	return conn
end

----------------------------------------------------------------------
-- Fonts / text styles (ตรงต้นฉบับ)
----------------------------------------------------------------------
local FAMILIES = {
	sans = "rbxasset://fonts/families/Montserrat.json",
	mono = "rbxasset://fonts/families/RobotoMono.json",
}
local FALLBACK = {
	[Enum.FontWeight.Regular] = Enum.Font.Gotham,
	[Enum.FontWeight.Medium] = Enum.Font.GothamMedium,
	[Enum.FontWeight.SemiBold] = Enum.Font.GothamBold,
	[Enum.FontWeight.Bold] = Enum.Font.GothamBold,
}

local function setFont(obj, family, weight)
	local ok = pcall(function()
		obj.FontFace = Font.new(FAMILIES[family], weight)
	end)
	if not ok then
		obj.Font = FALLBACK[weight] or Enum.Font.Gotham
	end
end

local STYLES = {
	windowTitle = { family = "sans", weight = Enum.FontWeight.SemiBold, size = 15, color = "TextPrimary" },
	windowChip = { family = "sans", weight = Enum.FontWeight.Bold, size = 15, color = "TextPrimary" },
	rowLabel = { family = "sans", weight = Enum.FontWeight.Medium, size = 13, color = "TextPrimary" },
	rowButton = { family = "sans", weight = Enum.FontWeight.SemiBold, size = 13, color = "TextOnAccent" },
	rowEntry = { family = "sans", weight = Enum.FontWeight.SemiBold, size = 13, color = "TextPrimary" },
	rowStat = { family = "sans", weight = Enum.FontWeight.Medium, size = 14, color = "TextPrimary" },
	captionKey = { family = "sans", weight = Enum.FontWeight.Medium, size = 12, color = "TextSub" },
	captionSub = { family = "sans", weight = Enum.FontWeight.Regular, size = 10, color = "TextMuted" },
	captionStat = { family = "sans", weight = Enum.FontWeight.Bold, size = 12, color = "TextSub" },
	monoValue = { family = "mono", weight = Enum.FontWeight.Medium, size = 11, color = "TextOnAccent" },
	monoMeta = { family = "mono", weight = Enum.FontWeight.Medium, size = 10, color = "TextMuted" },
	monoStat = { family = "mono", weight = Enum.FontWeight.Medium, size = 13, color = "TextSub" },
}

----------------------------------------------------------------------
-- Instance helpers (ตรงต้นฉบับ)
----------------------------------------------------------------------
local function new(class, props, parent)
	local obj = Instance.new(class)
	if props then
		for k, v in pairs(props) do
			obj[k] = v
		end
	end
	if parent then
		obj.Parent = parent
	end
	return obj
end

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
	return c
end

local function stroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or theme.Hairline
	s.Thickness = thickness or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function pad(parent, top, right, bottom, left)
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, top)
	p.PaddingRight = UDim.new(0, right)
	p.PaddingBottom = UDim.new(0, bottom)
	p.PaddingLeft = UDim.new(0, left)
	p.Parent = parent
	return p
end

local function vlist(parent, gap, sortOrder)
	local l = Instance.new("UIListLayout")
	l.FillDirection = Enum.FillDirection.Vertical
	l.Padding = UDim.new(0, gap or theme.GapSm)
	l.SortOrder = sortOrder or Enum.SortOrder.LayoutOrder
	l.Parent = parent
	return l
end

local function hlist(parent, gap)
	local l = Instance.new("UIListLayout")
	l.FillDirection = Enum.FillDirection.Horizontal
	l.VerticalAlignment = Enum.VerticalAlignment.Center
	l.Padding = UDim.new(0, gap or theme.GapMd)
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Parent = parent
	return l
end

local function flexFill(obj, reserve, scaleY, offsetY)
	if not reserve then
		return false
	end
	obj.Size = UDim2.new(1, -reserve, scaleY or 1, offsetY or 0)
	return true
end

local function label(parent, text, styleName, order)
	local st = STYLES[styleName] or STYLES.rowLabel
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Text = text or ""
	l.TextColor3 = theme[st.color]
	l.TextSize = st.size
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextYAlignment = Enum.TextYAlignment.Center
	l.LayoutOrder = order or 1
	l.Size = UDim2.new(1, 0, 1, 0)
	setFont(l, st.family, st.weight)
	l.Parent = parent
	return l
end

local function caption(parent, text, order)
	local l = label(parent, text, "captionSub", order)
	l.AutomaticSize = Enum.AutomaticSize.Y
	l.Size = UDim2.new(1, 0, 0, 0)
	l.TextWrapped = true
	l.TextYAlignment = Enum.TextYAlignment.Top
	return l
end

local function accentGradient(parent, rotation)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, theme.AccentA),
		ColorSequenceKeypoint.new(0.53, theme.AccentMid),
		ColorSequenceKeypoint.new(1, theme.AccentB),
	})
	g.Rotation = rotation or 0
	g.Parent = parent
	return g
end

local function icon(parent, name, size, color, z)
	local img = Instance.new("ImageLabel")
	img.Name = "Icon_" .. tostring(name)
	img.BackgroundTransparency = 1
	img.BorderSizePixel = 0
	img.Image = "rbxassetid://" .. tostring(ICONS[name] or ICONS.info)
	img.ImageColor3 = color or theme.TextSub
	img.ScaleType = Enum.ScaleType.Fit
	img.Size = UDim2.fromOffset(size or 16, size or 16)
	if z then
		img.ZIndex = z
	end
	img.Parent = parent
	return img
end

local function chevron(parent)
	local holder = Instance.new("Frame")
	holder.Name = "Chevron"
	holder.BackgroundTransparency = 1
	holder.Size = UDim2.fromOffset(16, 16)
	holder.LayoutOrder = 99
	holder.Parent = parent
	local img = icon(holder, "chevron-down", 16, theme.TextSub)
	img.AnchorPoint = Vector2.new(0.5, 0.5)
	img.Position = UDim2.fromScale(0.5, 0.5)
	return {
		frame = holder,
		setOpen = function(open)
			img.Rotation = open and 180 or 0
			img.ImageColor3 = open and theme.AccentMid or theme.TextSub
		end,
	}
end

local function isPress(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

local function isMove(input)
	return input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
end

----------------------------------------------------------------------
-- Accent sweep / body gradient / shadow
----------------------------------------------------------------------
local function accentSweep(parent)
	parent.ClipsDescendants = true
	local sweep = Instance.new("Frame")
	sweep.Name = "Sweep"
	sweep.BackgroundColor3 = WHITE
	sweep.BorderSizePixel = 0
	sweep.Size = UDim2.new(2, 0, 1, 0)
	sweep.Position = UDim2.new(-1, 0, 0, 0)
	sweep.ZIndex = parent.ZIndex
	sweep.Parent = parent
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, theme.AccentA),
		ColorSequenceKeypoint.new(0.125, theme.AccentMid),
		ColorSequenceKeypoint.new(0.25, theme.AccentB),
		ColorSequenceKeypoint.new(0.375, theme.AccentMid),
		ColorSequenceKeypoint.new(0.5, theme.AccentA),
		ColorSequenceKeypoint.new(0.625, theme.AccentMid),
		ColorSequenceKeypoint.new(0.75, theme.AccentB),
		ColorSequenceKeypoint.new(0.875, theme.AccentMid),
		ColorSequenceKeypoint.new(1, theme.AccentA),
	})
	g.Parent = sweep
	sweeps[#sweeps + 1] = sweep
	if not sweepConn then
		sweepConn = RunService.RenderStepped:Connect(function()
			local t = os.clock() * (theme.SweepSpeed or 0.22) % 1
			local pos = UDim2.new(t - 1, 0, 0, 0)
			for i = #sweeps, 1, -1 do
				local s = sweeps[i]
				if s.Parent then
					s.Position = pos
				else
					table.remove(sweeps, i)
				end
			end
		end)
		keep(sweepConn)
	end
	return sweep
end

local function bodyGradient(parent)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, theme.BodyTop),
		ColorSequenceKeypoint.new(0.45, theme.BodyMid),
		ColorSequenceKeypoint.new(1, theme.BodyBot),
	})
	g.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, theme.BodyTopA),
		NumberSequenceKeypoint.new(0.45, theme.BodyMidA),
		NumberSequenceKeypoint.new(1, theme.BodyBotA),
	})
	g.Rotation = 90
	g.Parent = parent
	return g
end

local function shadow(target, layers, grow, drop, alpha, radius)
	layers, grow, drop, alpha, radius =
		layers or 8, grow or 1.5, drop or 10, alpha or 0.04, radius or theme.RadiusLg
	local holder = Instance.new("Frame")
	holder.Name = (target.Name or "Window") .. "Shadow"
	holder.BackgroundTransparency = 1
	holder.ZIndex = math.max(target.ZIndex - 1, 0)
	local function sync()
		holder.Position, holder.Size, holder.AnchorPoint, holder.Visible =
			target.Position, target.Size, target.AnchorPoint, target.Visible
	end
	sync()
	holder.Parent = target.Parent
	for _, prop in ipairs({ "Position", "Size", "AnchorPoint", "Visible" }) do
		target:GetPropertyChangedSignal(prop):Connect(sync)
	end
	target.AncestryChanged:Connect(function()
		if target.Parent then
			if holder.Parent ~= target.Parent then
				holder.Parent = target.Parent
			end
		else
			holder:Destroy()
		end
	end)
	for i = 1, layers do
		local g = i * grow
		local dy = drop * (i / layers)
		local layer = Instance.new("Frame")
		layer.Name = "L" .. i
		layer.BackgroundColor3 = BLACK
		layer.BackgroundTransparency = 1 - alpha
		layer.BorderSizePixel = 0
		layer.ZIndex = target.ZIndex - 1
		layer.Position = UDim2.fromOffset(-g, -g + dy)
		layer.Size = UDim2.new(1, g * 2, 1, g * 2)
		corner(layer, radius + g)
		layer.Parent = holder
	end
	return holder
end

----------------------------------------------------------------------
-- Tooltip (fade-in 0.16s เหมือนต้นฉบับ)
----------------------------------------------------------------------
local function ensureTip(parentGui)
	if tipState.frame and tipState.frame.Parent then
		return
	end
	local frame = Instance.new("Frame")
	frame.Name = "Tooltip"
	frame.BackgroundColor3 = Color3.fromHex("3a3a42")
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.ZIndex = 500
	frame.AutomaticSize = Enum.AutomaticSize.XY
	frame.Size = UDim2.fromOffset(0, 0)
	frame.Parent = parentGui
	corner(frame, theme.RadiusSm)
	stroke(frame, Color3.fromHex("4a4a55"), 1)
	pad(frame, 6, 8, 6, 8)

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.AutomaticSize = Enum.AutomaticSize.XY
	lbl.Size = UDim2.fromOffset(0, 0)
	lbl.TextWrapped = true
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextYAlignment = Enum.TextYAlignment.Top
	lbl.TextColor3 = Color3.fromHex("e8e8ee")
	lbl.TextSize = 11
	lbl.ZIndex = 501
	setFont(lbl, "sans", Enum.FontWeight.Medium)
	lbl.Parent = frame
	local constraint = Instance.new("UISizeConstraint")
	constraint.MaxSize = Vector2.new(240, math.huge)
	constraint.Parent = lbl

	tipState.frame, tipState.label = frame, lbl
	if tipState.conn then
		tipState.conn:Disconnect()
	end
	tipState.conn = RunService.RenderStepped:Connect(function()
		if not tipState.target then
			return
		end
		local now = os.clock()
		if not tipState.frame.Visible then
			if now < tipState.showAt then
				return
			end
			tipState.frame.Visible = true
			local st = tipState.frame:FindFirstChildOfClass("UIStroke")
			tipState.frame.BackgroundTransparency, tipState.label.TextTransparency = 1, 1
			if st then
				st.Transparency = 1
				TweenService:Create(st, TweenInfo.new(0.16), { Transparency = 0 }):Play()
			end
			TweenService:Create(tipState.frame, TweenInfo.new(0.16), { BackgroundTransparency = 0 }):Play()
			TweenService:Create(tipState.label, TweenInfo.new(0.16), { TextTransparency = 0 }):Play()
		end
		local m = UIS:GetMouseLocation()
		local cam = workspace.CurrentCamera
		local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)
		local w, h = tipState.frame.AbsoluteSize.X, tipState.frame.AbsoluteSize.Y
		local x = (m.X + 16 + w > vp.X) and (m.X - 16 - w) or (m.X + 16)
		local y = (m.Y + 18 + h > vp.Y) and (m.Y - 12 - h) or (m.Y + 18)
		tipState.frame.Position = UDim2.fromOffset(x, y)
	end)
	keep(tipState.conn)
end

local function hideTip()
	tipState.target = nil
	if tipState.frame then
		tipState.frame.Visible = false
	end
end

local function tip(target, text)
	if not text or text == "" then
		return target
	end
	target.MouseEnter:Connect(function()
		if not tipState.frame then
			return
		end
		tipState.target = target
		tipState.showAt = os.clock() + 0.45
		tipState.frame.Visible = false
		tipState.label.Text = text
	end)
	target.MouseLeave:Connect(function()
		if tipState.target == target then
			hideTip()
		end
	end)
	target.AncestryChanged:Connect(function()
		if not target:IsDescendantOf(game) and tipState.target == target then
			hideTip()
		end
	end)
	return target
end

----------------------------------------------------------------------
-- กฎ "หน้าต่างบนสุดรับคลิก" (pressOnTop) ตรงต้นฉบับ
----------------------------------------------------------------------
local function ownerWindow(obj)
	local v = obj
	while v and not (v.GetAttribute and v:GetAttribute("hlWin")) do
		v = v.Parent
	end
	return v
end

local function rankOf(child)
	local parent = child.Parent
	return child.ZIndex * 100000 + (parent and table.find(parent:GetChildren(), child) or 0)
end

local function pointerPos(input)
	if input and input.UserInputType == Enum.UserInputType.Touch then
		local inset = GuiService:GetGuiInset()
		return input.Position.X + inset.X, input.Position.Y + inset.Y
	end
	local m = UIS:GetMouseLocation()
	return m.X, m.Y
end

local function topWindowAt(x, y, container)
	local best, bestRank
	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("GuiObject") and child.Visible and child:GetAttribute("hlWin") then
			local p, s = child.AbsolutePosition, child.AbsoluteSize
			if x >= p.X and y >= p.Y and x <= p.X + s.X and y <= p.Y + s.Y then
				local r = rankOf(child)
				if not bestRank or r > bestRank then
					best, bestRank = child, r
				end
			end
		end
	end
	return best
end

local function pressOnTop(obj, input)
	local win = ownerWindow(obj)
	if not win or not win.Parent then
		return true
	end
	local x, y = pointerPos(input)
	local top = topWindowAt(x, y, win.Parent)
	return top == nil or top == win
end

local function raiseWindow(frame)
	topCounter = topCounter + 1
	frame:SetAttribute("hlTop", topCounter)
	frame.ZIndex = UILib.MenuZ + 1 + topCounter
	local parent = frame.Parent
	if parent then
		frame.Parent = nil
		frame.Parent = parent
	end
end

----------------------------------------------------------------------
-- row / hoverable / pressable / slideTo (ตรงต้นฉบับ)
----------------------------------------------------------------------
local function row(parent, text, order, height, reserve)
	local r = Instance.new("Frame")
	r.Name = "Row"
	r.BackgroundColor3 = theme.SurfaceElement
	r.BorderSizePixel = 0
	r.Size = UDim2.new(1, 0, 0, height or theme.RowH)
	r.LayoutOrder = order or 1
	r.Parent = parent
	corner(r, theme.RadiusMd)
	stroke(r, theme.Hairline, 1)
	pad(r, 0, theme.GapLg, 0, theme.GapLg)
	hlist(r, theme.GapMd)
	local lbl = label(r, text, "rowLabel", 1)
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.TextTruncate = Enum.TextTruncate.AtEnd
	flexFill(lbl, reserve or 24)
	return r, lbl, height
end

local function hoverable(frame, clickable)
	local base = frame.BackgroundColor3
	frame.MouseEnter:Connect(function()
		if pressOnTop(frame) then
			TweenService:Create(frame, TweenInfo.new(0.14, Enum.EasingStyle.Quint), {
				BackgroundColor3 = theme.SurfaceHover,
			}):Play()
		end
	end)
	frame.MouseLeave:Connect(function()
		TweenService:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
			BackgroundColor3 = base,
		}):Play()
	end)
	if not clickable then
		return nil
	end
	frame.Active = true
	return {
		onClick = function(fn)
			frame.InputBegan:Connect(function(input)
				if isPress(input) and pressOnTop(frame, input) then
					fn()
				end
			end)
		end,
	}
end

-- เอฟเฟกต์กดปุ่ม: ย่อ 0.96 แล้วเด้งกลับแบบ Back
local function pressable(button)
	local scale = Instance.new("UIScale")
	scale.Parent = button
	button.MouseButton1Down:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.08, Enum.EasingStyle.Quad), { Scale = 0.96 }):Play()
	end)
	local function release()
		TweenService:Create(scale, TweenInfo.new(0.28, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	end
	button.MouseButton1Up:Connect(release)
	button.MouseLeave:Connect(release)
end

-- แอนิเมชันเปิด/ปิดเมนูและ section (ความสูง tween แบบ Quint)
local slideGen = setmetatable({}, { __mode = "k" })
local function slideTo(frame, layout, extra, open, onDone)
	local gen = (slideGen[frame] or 0) + 1
	slideGen[frame] = gen
	local xs = frame.Size.X
	local startH = frame.Visible and frame.AbsoluteSize.Y or 0
	frame.ClipsDescendants = true
	frame.AutomaticSize = Enum.AutomaticSize.None
	frame.Size = UDim2.new(xs.Scale, xs.Offset, 0, startH)
	frame.Visible = true
	task.defer(function()
		if slideGen[frame] ~= gen then
			return
		end
		local targetH = open and (layout.AbsoluteContentSize.Y + extra) or 0
		local tween = TweenService:Create(
			frame,
			TweenInfo.new(open and 0.34 or 0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Size = UDim2.new(xs.Scale, xs.Offset, 0, targetH) }
		)
		tween:Play()
		tween.Completed:Once(function()
			if slideGen[frame] ~= gen then
				return
			end
			slideGen[frame] = nil
			if not open then
				frame.Visible = false
			end
			frame.AutomaticSize = Enum.AutomaticSize.Y
			frame.Size = UDim2.new(xs.Scale, xs.Offset, 0, 0)
			frame.ClipsDescendants = false
			if onDone then
				onDone()
			end
		end)
	end)
end

local function animateOK(frame)
	return gui ~= nil and libVisible and frame:IsDescendantOf(game)
end

----------------------------------------------------------------------
-- Shared element helpers
----------------------------------------------------------------------
local function fire(o, ...)
	if o.Flag then
		UILib.Flags[o.Flag] = (...)
	end
	if o.Callback then
		local ok, err = pcall(o.Callback, ...)
		if not ok then
			warn("[UILib] callback error: " .. tostring(err))
		end
	end
end

local function setFlag(o, value)
	if o.Flag then
		UILib.Flags[o.Flag] = value
	end
end

local function trim(s)
	return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function toNumber(textBox)
	return tonumber((string.gsub(textBox.Text, "[^%d%.%-]", "")))
end

-- snap ค่าตามกติกาต้นฉบับ: step > float(0.1) > จำนวนเต็ม
local function snapValue(v, min, max, float, step)
	v = math.clamp(v, min, max)
	if step then
		v = math.floor(v / step + 0.5) * step
	elseif float then
		v = math.floor(v * 10 + 0.5) / 10
	else
		v = math.floor(v + 0.5)
	end
	return math.clamp(v, min, max)
end

local function formatValue(v, float, step)
	if step then
		return (string.format("%.3f", v):gsub("0+$", ""):gsub("%.$", ""))
	end
	if float then
		return string.format("%.1f", v)
	end
	return tostring(math.floor(v + 0.5))
end

local function formatCompact(v, float)
	if float then
		return string.format("%.1f", v)
	end
	return tostring(math.floor(v + 0.5))
end

local function useCompact(min, max, step, float)
	if UILib.Compact ~= true then
		return false
	end
	local span = max - min
	local unit = step or (float and 0.1 or 1)
	return span / unit > 60
end

local function numberBox(parent, width, order)
	local box = Instance.new("TextBox")
	box.Name = "Number"
	box.BackgroundColor3 = theme.SurfaceField
	box.BorderSizePixel = 0
	box.Size = UDim2.fromOffset(width, 24)
	box.LayoutOrder = order
	box.TextColor3 = theme.TextPrimary
	box.TextSize = 12
	box.ClearTextOnFocus = false
	box.TextXAlignment = Enum.TextXAlignment.Center
	setFont(box, "sans", Enum.FontWeight.SemiBold)
	box.Parent = parent
	corner(box, theme.RadiusSm)
	stroke(box, theme.Hairline, 1)
	return box
end

local function captionBox(parent, text, width, order)
	local l = label(parent, (tostring(text or ""):gsub("^%s+", "")), "captionSub", order)
	l.Size = UDim2.fromOffset(width, 24)
	l.TextXAlignment = Enum.TextXAlignment.Left
	return l
end

local function dragEnd(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

----------------------------------------------------------------------
-- Toggle
----------------------------------------------------------------------
local function buildToggle(parent, o, order)
	local state = o.Default and true or false
	local r = row(parent, o.Name or "Toggle", order, nil, 46)
	local click = hoverable(r, true)

	local track = Instance.new("Frame")
	track.Name = "Track"
	track.BackgroundColor3 = theme.SurfaceField
	track.BorderSizePixel = 0
	track.Size = UDim2.fromOffset(38, 20)
	track.LayoutOrder = 2
	track.Parent = r
	corner(track, 10)
	local trackStroke = stroke(track, theme.Hairline, 1)
	local grad = accentGradient(track, 0)
	grad.Enabled = false

	local knob = Instance.new("Frame")
	knob.Name = "Knob"
	knob.BackgroundColor3 = theme.TextMuted
	knob.BorderSizePixel = 0
	knob.Size = UDim2.fromOffset(14, 14)
	knob.Position = UDim2.fromOffset(2, 3)
	knob.ZIndex = 2
	corner(knob, 7)
	knob.Parent = track

	local rendered = false
	local function render()
		local on = state
		grad.Enabled = on
		track.BackgroundColor3 = on and WHITE or theme.SurfaceField
		trackStroke.Transparency = on and 1 or 0
		knob.BackgroundColor3 = on and theme.TextOnAccent or theme.TextMuted
		local pos = UDim2.fromOffset(on and 22 or 2, 3)
		if rendered and knob.Position ~= pos and knob:IsDescendantOf(game) then
			TweenService:Create(knob, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Position = pos,
			}):Play()
		else
			knob.Position = pos
		end
		rendered = true
	end
	render()

	click.onClick(function()
		state = not state
		render()
		fire(o, state)
	end)
	tip(r, o.Tooltip)
	setFlag(o, state)

	local obj = { Frame = r, Render = render }
	function obj:Get()
		return state
	end
	function obj:Set(v, silent)
		v = v and true or false
		if v == state then
			return
		end
		state = v
		render()
		if silent then
			setFlag(o, state)
		else
			fire(o, state)
		end
	end
	return obj
end

----------------------------------------------------------------------
-- Slider (+ โหมด compact เป็นช่องตัวเลข)
----------------------------------------------------------------------
local function buildSlider(parent, o, order)
	local min, max = o.Min or 0, o.Max or 100
	local float, step = o.Float and true or false, o.Step
	local suffix = o.Suffix or ""
	local value = snapValue(tonumber(o.Default) or min, min, max, float, step)

	local obj = {}
	local function commit(v, silent)
		v = snapValue(v, min, max, float, step)
		if v == value then
			obj.Render()
			return
		end
		value = v
		obj.Render()
		if silent then
			setFlag(o, value)
		else
			fire(o, value)
		end
	end

	if useCompact(min, max, step, float) then
		local r = row(parent, o.Name or "Slider", order, nil, 136)
		local box = numberBox(r, 80, 2)
		captionBox(r, o.Description, 40, 3)
		obj.Frame = r
		obj.Render = function()
			box.Text = formatCompact(value, float)
		end
		obj.Render()
		box.FocusLost:Connect(function()
			local n = toNumber(box)
			if n then
				commit(n)
			end
			obj.Render()
		end)
		tip(r, o.Tooltip)
	else
		local holder = Instance.new("Frame")
		holder.Name = "Slider"
		holder.BackgroundTransparency = 0
		holder.BackgroundColor3 = theme.SurfaceElement
		holder.BorderSizePixel = 0
		holder.AutomaticSize = Enum.AutomaticSize.Y
		holder.Size = UDim2.new(1, 0, 0, 0)
		holder.LayoutOrder = order or 1
		holder.Parent = parent
		corner(holder, theme.RadiusMd)
		stroke(holder, theme.Hairline, 1)
		pad(holder, 7, 12, 9, 12)
		vlist(holder, theme.GapSm)

		local head = Instance.new("Frame")
		head.Name = "Head"
		head.BackgroundTransparency = 1
		head.AutomaticSize = Enum.AutomaticSize.Y
		head.Size = UDim2.new(1, 0, 0, 0)
		head.LayoutOrder = 1
		head.Parent = holder
		vlist(head, 1)
		label(head, o.Name or "Slider", "rowLabel", 1).Size = UDim2.new(1, 0, 0, 18)
		if o.Description and o.Description ~= "" then
			label(head, o.Description, "captionSub", 2).Size = UDim2.new(1, 0, 0, 12)
		end

		local track = Instance.new("Frame")
		track.Name = "Track"
		track.BackgroundColor3 = theme.SurfaceField
		track.BorderSizePixel = 0
		track.Size = UDim2.new(1, 0, 0, 18)
		track.ClipsDescendants = true
		track.LayoutOrder = 2
		track.Active = true
		track.Parent = holder
		corner(track, theme.RadiusSm)
		stroke(track, theme.Hairline, 1)

		local fill = Instance.new("Frame")
		fill.Name = "Fill"
		fill.BackgroundColor3 = WHITE
		fill.BorderSizePixel = 0
		fill.Size = UDim2.fromScale(0, 1)
		fill.Parent = track
		corner(fill, theme.RadiusSm)
		accentGradient(fill, 0)

		local valueLabel = Instance.new("TextLabel")
		valueLabel.Name = "Value"
		valueLabel.BackgroundTransparency = 1
		valueLabel.Size = UDim2.new(1, -8, 1, 0)
		valueLabel.Position = UDim2.fromOffset(0, 0)
		valueLabel.TextXAlignment = Enum.TextXAlignment.Right
		valueLabel.TextColor3 = theme.TextOnAccent
		valueLabel.TextSize = 11
		valueLabel.ZIndex = 3
		setFont(valueLabel, "mono", Enum.FontWeight.Medium)
		valueLabel.Parent = fill

		obj.Frame = holder
		obj.Render = function()
			local ratio = (max == min) and 0 or math.clamp((value - min) / (max - min), 0, 1)
			fill.Size = UDim2.fromScale(ratio, 1)
			valueLabel.Text = formatValue(value, float, step) .. suffix
			if ratio < 0.22 then
				valueLabel.Parent = track
				valueLabel.Size = UDim2.new(1, -8, 1, 0)
				valueLabel.TextColor3 = theme.TextPrimary
			else
				valueLabel.Parent = fill
				valueLabel.Size = UDim2.new(1, -8, 1, 0)
				valueLabel.TextColor3 = theme.TextOnAccent
			end
		end
		obj.Render()

		local dragging = false
		local function update(x)
			if track.AbsoluteSize.X <= 0 then
				return
			end
			local ratio = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
			commit(min + (max - min) * ratio)
		end
		track.InputBegan:Connect(function(input)
			if not pressOnTop(track, input) then
				return
			end
			if isPress(input) then
				dragging = true
				update(input.Position.X)
			end
		end)
		keep(UIS.InputChanged:Connect(function(input)
			if dragging and isMove(input) then
				update(input.Position.X)
			end
		end))
		keep(UIS.InputEnded:Connect(function(input)
			if dragEnd(input) then
				dragging = false
			end
		end))
		tip(holder, o.Tooltip)
	end

	setFlag(o, value)
	function obj:Get()
		return value
	end
	function obj:Set(v, silent)
		commit(tonumber(v) or value, silent)
	end
	return obj
end

----------------------------------------------------------------------
-- Range slider (จำนวนเต็ม, แสดง "lo - hi")
----------------------------------------------------------------------
local function buildRangeSlider(parent, o, order)
	local min, max = o.Min or 0, o.Max or 100
	local unit = (o.Unit and o.Unit ~= "") and (" " .. o.Unit) or ""
	local lo = math.clamp(math.floor((tonumber(o.DefaultMin) or min) + 0.5), min, max)
	local hi = math.clamp(math.floor((tonumber(o.DefaultMax) or max) + 0.5), min, max)
	if hi < lo then
		lo, hi = hi, lo
	end

	local obj = {}
	local function publish(silent)
		if o.Flag then
			UILib.Flags[o.Flag] = { lo, hi }
		end
		if not silent and o.Callback then
			local ok, err = pcall(o.Callback, lo, hi)
			if not ok then
				warn("[UILib] callback error: " .. tostring(err))
			end
		end
	end

	if useCompact(min, max, nil, false) then
		local r = row(parent, o.Name or "Range", order, nil, 200)
		local boxLo = numberBox(r, 58, 2)
		local to = label(r, "to", "captionSub", 3)
		to.Size, to.TextXAlignment = UDim2.fromOffset(16, 24), Enum.TextXAlignment.Center
		local boxHi = numberBox(r, 58, 4)
		captionBox(r, o.Description, 36, 5)
		obj.Frame = r
		obj.Render = function()
			boxLo.Text, boxHi.Text = formatCompact(lo), formatCompact(hi)
		end
		obj.Render()
		local function onLost()
			local a = snapValue(toNumber(boxLo) or lo, min, max)
			local b = snapValue(toNumber(boxHi) or hi, min, max)
			if a > b then
				a, b = b, a
			end
			lo, hi = a, b
			publish(false)
			obj.Render()
		end
		boxLo.FocusLost:Connect(onLost)
		boxHi.FocusLost:Connect(onLost)
		tip(r, o.Tooltip)
	else
		local holder = Instance.new("Frame")
		holder.Name = "RangeSlider"
		holder.BackgroundTransparency = 0
		holder.BackgroundColor3 = theme.SurfaceElement
		holder.BorderSizePixel = 0
		holder.AutomaticSize = Enum.AutomaticSize.Y
		holder.Size = UDim2.new(1, 0, 0, 0)
		holder.LayoutOrder = order or 1
		holder.Parent = parent
		corner(holder, theme.RadiusMd)
		stroke(holder, theme.Hairline, 1)
		pad(holder, 7, 12, 9, 12)
		vlist(holder, theme.GapSm)

		local head = Instance.new("Frame")
		head.Name = "Head"
		head.BackgroundTransparency = 1
		head.AutomaticSize = Enum.AutomaticSize.Y
		head.Size = UDim2.new(1, 0, 0, 0)
		head.LayoutOrder = 1
		head.Parent = holder
		vlist(head, 1)

		local top = Instance.new("Frame")
		top.Name = "Top"
		top.BackgroundTransparency = 1
		top.Size = UDim2.new(1, 0, 0, 18)
		top.LayoutOrder = 1
		top.Parent = head
		label(top, o.Name or "Range", "rowLabel", 1).Size = UDim2.new(1, -96, 1, 0)
		local valueText = label(top, "", "captionKey", 2)
		valueText.Size = UDim2.new(0, 96, 1, 0)
		valueText.Position = UDim2.new(1, -96, 0, 0)
		valueText.TextXAlignment = Enum.TextXAlignment.Right
		if o.Description and o.Description ~= "" then
			label(head, o.Description, "captionSub", 2).Size = UDim2.new(1, 0, 0, 12)
		end

		local track = Instance.new("Frame")
		track.Name = "Track"
		track.BackgroundColor3 = theme.SurfaceField
		track.BorderSizePixel = 0
		track.Size = UDim2.new(1, 0, 0, 18)
		track.ClipsDescendants = false
		track.LayoutOrder = 2
		track.Active = true
		track.Parent = holder
		corner(track, theme.RadiusSm)
		stroke(track, theme.Hairline, 1)

		local fill = Instance.new("Frame")
		fill.Name = "Fill"
		fill.BackgroundColor3 = WHITE
		fill.BorderSizePixel = 0
		fill.Size = UDim2.fromScale(0, 1)
		fill.Parent = track
		corner(fill, theme.RadiusSm)
		accentGradient(fill, 0)

		local function makeHandle(name)
			local f = Instance.new("Frame")
			f.Name = name
			f.AnchorPoint = Vector2.new(0.5, 0.5)
			f.BackgroundColor3 = theme.TextPrimary
			f.BorderSizePixel = 0
			f.Size = UDim2.fromOffset(8, 22)
			f.ZIndex = 3
			f.Parent = track
			corner(f, 3)
			stroke(f, theme.Hairline, 1)
			return f
		end
		local handleLo, handleHi = makeHandle("Low"), makeHandle("High")
		local span = math.max(max - min, 1)

		obj.Frame = holder
		obj.Render = function()
			local rLo, rHi = (lo - min) / span, (hi - min) / span
			fill.Position = UDim2.fromScale(rLo, 0)
			fill.Size = UDim2.fromScale(rHi - rLo, 1)
			handleLo.Position = UDim2.fromScale(rLo, 0.5)
			handleHi.Position = UDim2.fromScale(rHi, 0.5)
			valueText.Text = (lo == hi) and (tostring(lo) .. unit) or (("%d - %d"):format(lo, hi) .. unit)
		end
		obj.Render()

		local mode
		local function valueAt(x)
			local r = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
			return math.floor(min + (max - min) * r + 0.5)
		end
		local function update(x)
			if not mode or track.AbsoluteSize.X <= 0 then
				return
			end
			local v = valueAt(x)
			local a, b = lo, hi
			if mode == "both" then
				if v > b then
					mode = "hi"
				elseif v < a then
					mode = "lo"
				else
					return
				end
			end
			if mode == "lo" then
				a = math.min(v, b)
			else
				b = math.max(v, a)
			end
			lo, hi = a, b
			publish(false)
			obj.Render()
		end
		track.InputBegan:Connect(function(input)
			if not pressOnTop(track, input) then
				return
			end
			if isPress(input) then
				if track.AbsoluteSize.X <= 0 then
					return
				end
				local v = valueAt(input.Position.X)
				if lo == hi and v == lo then
					mode = "both"
				elseif v <= lo then
					mode = "lo"
				elseif v >= hi then
					mode = "hi"
				else
					mode = (v - lo <= hi - v) and "lo" or "hi"
				end
				update(input.Position.X)
			end
		end)
		keep(UIS.InputChanged:Connect(function(input)
			if mode and isMove(input) then
				update(input.Position.X)
			end
		end))
		keep(UIS.InputEnded:Connect(function(input)
			if dragEnd(input) then
				mode = nil
			end
		end))
		tip(holder, o.Tooltip)
	end

	publish(true)
	function obj:Get()
		return lo, hi
	end
	function obj:Set(a, b, silent)
		a = snapValue(tonumber(a) or lo, min, max)
		b = snapValue(tonumber(b) or hi, min, max)
		if a > b then
			a, b = b, a
		end
		lo, hi = a, b
		obj.Render()
		publish(silent)
	end
	return obj
end

----------------------------------------------------------------------
-- List input (รายการช่องกรอกที่เพิ่มแถวใหม่ให้อัตโนมัติ)
----------------------------------------------------------------------
local function buildListInput(parent, o, order)
	local ENTRY_H, ENTRY_GAP, LIST_PAD = 26, 4, 4
	local maxRows = o.MaxRows or 5

	local holder = Instance.new("Frame")
	holder.Name = "ListInput"
	holder.BackgroundTransparency = 1
	holder.AutomaticSize = Enum.AutomaticSize.Y
	holder.Size = UDim2.new(1, 0, 0, 0)
	holder.LayoutOrder = order or 1
	holder.Parent = parent
	vlist(holder, theme.GapSm)

	local head = Instance.new("Frame")
	head.Name = "Head"
	head.BackgroundTransparency = 1
	head.AutomaticSize = Enum.AutomaticSize.Y
	head.Size = UDim2.new(1, 0, 0, 0)
	head.LayoutOrder = 1
	head.Parent = holder
	vlist(head, 1)
	label(head, o.Name or "List", "rowLabel", 1).Size = UDim2.new(1, 0, 0, 18)
	if o.Description and o.Description ~= "" then
		label(head, o.Description, "captionSub", 2).Size = UDim2.new(1, 0, 0, 12)
	end

	local list = Instance.new("ScrollingFrame")
	list.Name = "List"
	list.BackgroundColor3 = theme.SurfaceField
	list.BorderSizePixel = 0
	list.LayoutOrder = 2
	list.Size = UDim2.new(1, 0, 0, 34)
	list.CanvasSize = UDim2.new()
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.ScrollingDirection = Enum.ScrollingDirection.Y
	list.ScrollBarThickness = 4
	list.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 95)
	list.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
	list.Parent = holder
	corner(list, theme.RadiusMd)
	stroke(list, theme.Hairline, 1)
	pad(list, LIST_PAD, LIST_PAD, LIST_PAD, LIST_PAD)
	vlist(list, ENTRY_GAP)

	local entries, silent = {}, false

	local function resize()
		local rows = math.clamp(#entries, 1, maxRows)
		list.Size = UDim2.new(1, 0, 0, LIST_PAD * 2 + rows * ENTRY_H + (rows - 1) * ENTRY_GAP)
	end
	local function collect()
		local out = {}
		for _, e in ipairs(entries) do
			local t = trim(e.Text)
			if t ~= "" then
				out[#out + 1] = t
			end
		end
		return out
	end
	local function publish()
		if silent then
			return
		end
		fire(o, collect())
	end
	local function toBottom()
		task.defer(function()
			if list.Parent then
				list.CanvasPosition = Vector2.new(0, math.max(0, list.AbsoluteCanvasSize.Y - list.AbsoluteWindowSize.Y))
			end
		end)
	end

	local addEntry
	local function cleanup()
		for i = #entries - 1, 1, -1 do
			local e = entries[i]
			if trim(e.Text) == "" then
				table.remove(entries, i)
				e:Destroy()
			end
		end
		if #entries == 0 then
			addEntry("")
		elseif trim(entries[#entries].Text) ~= "" then
			addEntry("")
		end
		for i, e in ipairs(entries) do
			e.LayoutOrder = i
		end
		resize()
	end

	addEntry = function(text)
		local e = Instance.new("TextBox")
		e.Name = "Entry"
		e.BackgroundColor3 = theme.SurfaceElement
		e.BorderSizePixel = 0
		e.Size = UDim2.new(1, 0, 0, ENTRY_H)
		e.LayoutOrder = #entries + 1
		e.Text = text or ""
		e.PlaceholderText = o.Placeholder or "Add a name"
		e.PlaceholderColor3 = theme.TextMuted
		e.TextColor3 = theme.TextPrimary
		e.TextSize = 12
		e.ClearTextOnFocus = false
		e.TextXAlignment = Enum.TextXAlignment.Left
		e.TextTruncate = Enum.TextTruncate.AtEnd
		setFont(e, "sans", Enum.FontWeight.Medium)
		e.Parent = list
		corner(e, theme.RadiusSm)
		stroke(e, theme.Hairline, 1)
		pad(e, 0, 8, 0, 8)
		entries[#entries + 1] = e
		e:GetPropertyChangedSignal("Text"):Connect(function()
			if silent then
				return
			end
			if entries[#entries] == e and trim(e.Text) ~= "" then
				addEntry("")
				resize()
				toBottom()
			end
			publish()
		end)
		e.FocusLost:Connect(function()
			if silent then
				return
			end
			cleanup()
			publish()
		end)
		return e
	end

	local function render(values)
		silent = true
		for _, e in ipairs(entries) do
			e:Destroy()
		end
		table.clear(entries)
		if type(values) == "table" then
			for _, v in ipairs(values) do
				local t = trim(v)
				if t ~= "" then
					addEntry(t)
				end
			end
		end
		addEntry("")
		silent = false
		resize()
	end
	render(o.Default)
	tip(holder, o.Tooltip)
	setFlag(o, collect())

	local obj = { Frame = holder, Render = render, ToBottom = toBottom }
	function obj:Get()
		return collect()
	end
	function obj:Set(values, silentSet)
		render(values)
		if silentSet then
			setFlag(o, collect())
		else
			fire(o, collect())
		end
	end
	return obj
end

----------------------------------------------------------------------
-- Dropdown (เมนูเลื่อนเปิด/ปิดด้วย slideTo, ตัวเลือกมากกว่า 6 = กริด)
----------------------------------------------------------------------
local function buildDropdown(parent, o, order)
	local entries = {}
	local function load(listOptions)
		entries = {}
		for _, opt in ipairs(listOptions or {}) do
			if type(opt) == "table" then
				entries[#entries + 1] = { value = opt.value, label = opt.label or tostring(opt.value) }
			else
				entries[#entries + 1] = { value = opt, label = tostring(opt) }
			end
		end
	end
	load(o.Options)

	local current = o.Default
	if current == nil and entries[1] then
		current = entries[1].value
	end

	local holder = Instance.new("Frame")
	holder.Name = "Dropdown"
	holder.BackgroundTransparency = 1
	holder.AutomaticSize = Enum.AutomaticSize.Y
	holder.Size = UDim2.new(1, 0, 0, 0)
	holder.LayoutOrder = order or 1
	holder.Parent = parent
	vlist(holder, 4)

	local r = row(holder, o.Name or "Dropdown", 1, nil, 150)
	local click = hoverable(r, true)
	local valueLbl = label(r, "", "captionKey", 2)
	valueLbl.Size = UDim2.fromOffset(118, 18)
	valueLbl.AutomaticSize = Enum.AutomaticSize.None
	valueLbl.TextTruncate = Enum.TextTruncate.AtEnd
	valueLbl.TextXAlignment = Enum.TextXAlignment.Right
	local chev = chevron(r)

	local menu = Instance.new("Frame")
	menu.Name = "Menu"
	menu.BackgroundColor3 = theme.SurfaceField
	menu.BorderSizePixel = 0
	menu.AutomaticSize = Enum.AutomaticSize.Y
	menu.Size = UDim2.new(1, 0, 0, 0)
	menu.Visible = false
	menu.LayoutOrder = 2
	menu.Parent = holder
	corner(menu, theme.RadiusMd)
	stroke(menu, theme.Hairline, 1)
	pad(menu, 4, 4, 4, 4)

	local layout
	local buttons = {}
	local open = false

	local function render()
		valueLbl.Text = tostring(current)
		for _, b in ipairs(buttons) do
			local on = (b.value == current)
			b.btn.BackgroundColor3 = on and theme.SurfaceHover or theme.SurfaceElement
			b.btn.TextColor3 = on and theme.AccentMid or theme.TextSub
		end
	end

	local function setOpen(v)
		open = v
		chev.setOpen(v)
		if animateOK(menu) then
			slideTo(menu, layout, 8, v)
		else
			menu.Visible = v
		end
	end

	local function rebuild()
		for _, c in ipairs(menu:GetChildren()) do
			if c:IsA("TextButton") or c:IsA("UIListLayout") or c:IsA("UIGridLayout") then
				c:Destroy()
			end
		end
		buttons = {}
		if #entries > 6 then
			local cols = #entries > 10 and 3 or 2
			local grid = Instance.new("UIGridLayout")
			grid.CellSize = UDim2.new(1 / cols, -math.ceil(2 * (cols - 1) / cols) - 1, 0, 26)
			grid.CellPadding = UDim2.fromOffset(2, 2)
			grid.FillDirectionMaxCells = cols
			grid.SortOrder = Enum.SortOrder.LayoutOrder
			grid.Parent = menu
			layout = grid
		else
			layout = vlist(menu, 2)
		end
		for i, e in ipairs(entries) do
			local b = Instance.new("TextButton")
			b.Name = tostring(e.value)
			b.BackgroundColor3 = theme.SurfaceElement
			b.BorderSizePixel = 0
			b.Size = UDim2.new(1, 0, 0, 26)
			b.Text = e.label
			b.TextColor3 = theme.TextSub
			b.TextSize = 12
			b.LayoutOrder = i
			setFont(b, "sans", Enum.FontWeight.Medium)
			b.Parent = menu
			corner(b, 4)
			b.MouseButton1Click:Connect(function()
				current = e.value
				setOpen(false)
				render()
				fire(o, current)
			end)
			buttons[#buttons + 1] = { btn = b, value = e.value }
		end
		render()
	end
	rebuild()

	click.onClick(function()
		setOpen(not open)
	end)
	tip(r, o.Tooltip)
	setFlag(o, current)

	local obj = { Frame = holder, Render = render }
	function obj:Get()
		return current
	end
	function obj:Set(v, silent)
		current = v
		render()
		if silent then
			setFlag(o, current)
		else
			fire(o, current)
		end
	end
	function obj:Refresh(newOptions)
		load(newOptions)
		rebuild()
	end
	return obj
end

----------------------------------------------------------------------
-- Text input
----------------------------------------------------------------------
local function buildTextInput(parent, o, order)
	local r = row(parent, o.Name or "Input", order, nil, 196)
	local input = Instance.new("TextBox")
	input.Name = "Input"
	input.BackgroundColor3 = theme.SurfaceField
	input.BorderSizePixel = 0
	input.Size = UDim2.fromOffset(180, 24)
	input.LayoutOrder = 2
	input.Text = tostring(o.Default or "")
	input.PlaceholderText = o.Placeholder or ""
	input.PlaceholderColor3 = theme.TextMuted
	input.TextColor3 = theme.TextPrimary
	input.TextSize = 12
	input.ClearTextOnFocus = false
	input.TextXAlignment = Enum.TextXAlignment.Left
	input.TextTruncate = Enum.TextTruncate.AtEnd
	setFont(input, "sans", Enum.FontWeight.Medium)
	input.Parent = r
	corner(input, theme.RadiusSm)
	stroke(input, theme.Hairline, 1)
	pad(input, 0, 8, 0, 8)

	input.FocusLost:Connect(function()
		if o.Numeric then
			local n = toNumber(input)
			input.Text = n and tostring(n) or ""
			fire(o, n)
		else
			fire(o, input.Text)
		end
	end)
	tip(r, o.Tooltip)
	setFlag(o, input.Text)

	local obj = { Frame = r, Box = input }
	function obj:Get()
		return input.Text
	end
	function obj:Set(v, silent)
		input.Text = tostring(v or "")
		if silent then
			setFlag(o, input.Text)
		else
			fire(o, input.Text)
		end
	end
	return obj
end

----------------------------------------------------------------------
-- Button / ButtonRow
----------------------------------------------------------------------
local function buildButton(parent, o, order)
	local style = o.Style or "default"
	local text = o.Name or "Button"
	local b = Instance.new("TextButton")
	b.Name = "Button"
	b.BorderSizePixel = 0
	b.Size = UDim2.new(1, 0, 0, 32)
	b.Text = text
	b.TextSize = 13
	b.AutoButtonColor = false
	b.LayoutOrder = order or 1
	setFont(b, "sans", Enum.FontWeight.SemiBold)
	b.Parent = parent
	corner(b, theme.RadiusMd)

	local ok, size = pcall(function()
		return TextService:GetTextSize(tostring(text), 13, Enum.Font.GothamBold, Vector2.new(2000, 40))
	end)
	local constraint = Instance.new("UISizeConstraint")
	constraint.MaxSize = Vector2.new(math.max(220, (ok and size.X or 180) + 44), math.huge)
	constraint.Parent = b

	pressable(b)

	if style == "accent" or style == "danger" then
		b.BackgroundTransparency = 1
		b.TextTransparency = 1
		local fill = Instance.new("Frame")
		fill.Name = "Fill"
		fill.BackgroundColor3 = WHITE
		fill.BorderSizePixel = 0
		fill.Size = UDim2.fromScale(1, 1)
		fill.ZIndex = b.ZIndex
		fill.Parent = b
		corner(fill, theme.RadiusMd)
		local g = Instance.new("UIGradient")
		g.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, theme.AccentB),
			ColorSequenceKeypoint.new(0.5, theme.AccentDark),
			ColorSequenceKeypoint.new(1, theme.AccentB),
		})
		g.Parent = fill
		local lbl = Instance.new("TextLabel")
		lbl.Name = "Label"
		lbl.BackgroundTransparency = 1
		lbl.Size = UDim2.fromScale(1, 1)
		lbl.ZIndex = b.ZIndex + 1
		lbl.Text = b.Text
		lbl.TextColor3 = theme.TextOnAccent
		lbl.TextSize = b.TextSize
		setFont(lbl, "sans", Enum.FontWeight.SemiBold)
		lbl.Parent = b
		b:GetPropertyChangedSignal("Text"):Connect(function()
			lbl.Text = b.Text
		end)
		b.MouseEnter:Connect(function()
			fill.BackgroundColor3 = Color3.new(0.68, 0.68, 0.68)
		end)
		b.MouseLeave:Connect(function()
			fill.BackgroundColor3 = WHITE
		end)
	else
		b.BackgroundColor3 = theme.SurfaceElement
		b.TextColor3 = theme.TextPrimary
		stroke(b, theme.Hairline, 1)
		b.MouseEnter:Connect(function()
			b.BackgroundColor3 = theme.SurfaceHover
		end)
		b.MouseLeave:Connect(function()
			b.BackgroundColor3 = theme.SurfaceElement
		end)
	end

	b.MouseButton1Click:Connect(function()
		if o.Callback then
			local okc, err = pcall(o.Callback)
			if not okc then
				warn("[UILib] callback error: " .. tostring(err))
			end
		end
	end)
	tip(b, o.Tooltip)

	local obj = { Frame = b }
	function obj:SetText(t)
		b.Text = t
	end
	return obj
end

local function buildButtonRow(parent, order)
	local frame = Instance.new("Frame")
	frame.Name = "Buttons"
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1, 0, 0, 32)
	frame.LayoutOrder = order or 1
	frame.Parent = parent
	hlist(frame, theme.GapMd)

	local count, items = 0, {}
	local obj = { Frame = frame }
	function obj:AddButton(o)
		count = count + 1
		local btn = buildButton(frame, o or {}, count)
		btn.Frame.Size = UDim2.new(0, 0, 1, 0)
		items[count] = btn.Frame
		for _, f in ipairs(items) do
			f.Size = UDim2.new(1 / count, -(theme.GapMd * (count - 1)) / count, 1, 0)
		end
		return btn
	end
	return obj
end

----------------------------------------------------------------------
-- Color row (สี่เหลี่ยม SV + แถบ Hue) และ Color wheel
----------------------------------------------------------------------
local function buildColorPicker(parent, o, order)
	local color = o.Default or Color3.fromRGB(244, 49, 32)
	local h, s, v = color:ToHSV()

	local holder = Instance.new("Frame")
	holder.Name = "Color"
	holder.BackgroundTransparency = 1
	holder.AutomaticSize = Enum.AutomaticSize.Y
	holder.Size = UDim2.new(1, 0, 0, 0)
	holder.LayoutOrder = order or 1
	holder.Parent = parent
	vlist(holder, theme.GapSm)

	local r = row(holder, o.Name or "Color", 1, nil, 54)
	local click = hoverable(r, true)
	local swatch = Instance.new("Frame")
	swatch.Name = "Swatch"
	swatch.BackgroundColor3 = color
	swatch.BorderSizePixel = 0
	swatch.Size = UDim2.fromOffset(46, 20)
	swatch.LayoutOrder = 2
	swatch.Parent = r
	corner(swatch, theme.RadiusSm)
	stroke(swatch, theme.Hairline, 1)

	local picker = Instance.new("Frame")
	picker.Name = "Picker"
	picker.BackgroundTransparency = 1
	picker.Size = UDim2.new(1, 0, 0, 140)
	picker.Visible = false
	picker.LayoutOrder = 2
	picker.Parent = holder
	hlist(picker, theme.GapMd)

	local sv = Instance.new("Frame")
	sv.Name = "SV"
	sv.BackgroundColor3 = WHITE
	sv.BorderSizePixel = 0
	sv.Size = UDim2.new(1, -22, 1, 0)
	sv.Active = true
	sv.LayoutOrder = 1
	sv.Parent = picker
	corner(sv, theme.RadiusMd)
	flexFill(sv, 22)
	local svGradient = Instance.new("UIGradient")
	svGradient.Rotation = 0
	svGradient.Parent = sv

	local shade = Instance.new("Frame")
	shade.Name = "Shade"
	shade.BackgroundColor3 = BLACK
	shade.BorderSizePixel = 0
	shade.Size = UDim2.fromScale(1, 1)
	shade.Parent = sv
	corner(shade, theme.RadiusMd)
	local shadeGradient = Instance.new("UIGradient")
	shadeGradient.Rotation = 90
	shadeGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 0),
	})
	shadeGradient.Parent = shade

	local cursor = Instance.new("Frame")
	cursor.Name = "Cursor"
	cursor.BackgroundTransparency = 1
	cursor.AnchorPoint = Vector2.new(0.5, 0.5)
	cursor.Size = UDim2.fromOffset(12, 12)
	cursor.ZIndex = 4
	cursor.Parent = sv
	corner(cursor, 6)
	stroke(cursor, WHITE, 2)

	local hue = Instance.new("Frame")
	hue.Name = "Hue"
	hue.BackgroundColor3 = WHITE
	hue.BorderSizePixel = 0
	hue.Size = UDim2.new(0, 14, 1, 0)
	hue.Active = true
	hue.LayoutOrder = 2
	hue.Parent = picker
	corner(hue, theme.RadiusSm)
	local hueGradient = Instance.new("UIGradient")
	hueGradient.Rotation = 90
	hueGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
		ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
	})
	hueGradient.Parent = hue

	local marker = Instance.new("Frame")
	marker.Name = "Marker"
	marker.BackgroundColor3 = WHITE
	marker.BorderSizePixel = 0
	marker.AnchorPoint = Vector2.new(0.5, 0.5)
	marker.Size = UDim2.fromOffset(20, 3)
	marker.Position = UDim2.new(0.5, 0, 0, 0)
	marker.ZIndex = 4
	corner(marker, 2)
	marker.Parent = hue

	local function render()
		color = Color3.fromHSV(h, s, v)
		swatch.BackgroundColor3 = color
		svGradient.Color = ColorSequence.new(WHITE, Color3.fromHSV(h, 1, 1))
		cursor.Position = UDim2.fromScale(s, 1 - v)
		marker.Position = UDim2.new(0.5, 0, h, 0)
	end
	render()

	local dragSV, dragHue = false, false
	local function updateSV(x, y)
		if sv.AbsoluteSize.X <= 0 then
			return
		end
		s = math.clamp((x - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
		v = 1 - math.clamp((y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
		render()
		fire(o, color)
	end
	local function updateHue(y)
		if hue.AbsoluteSize.Y <= 0 then
			return
		end
		h = math.clamp((y - hue.AbsolutePosition.Y) / hue.AbsoluteSize.Y, 0, 1)
		render()
		fire(o, color)
	end
	sv.InputBegan:Connect(function(input)
		if not pressOnTop(sv, input) then
			return
		end
		if isPress(input) then
			dragSV = true
			updateSV(input.Position.X, input.Position.Y)
		end
	end)
	hue.InputBegan:Connect(function(input)
		if not pressOnTop(hue, input) then
			return
		end
		if isPress(input) then
			dragHue = true
			updateHue(input.Position.Y)
		end
	end)
	keep(UIS.InputChanged:Connect(function(input)
		if not isMove(input) then
			return
		end
		if dragSV then
			updateSV(input.Position.X, input.Position.Y)
		end
		if dragHue then
			updateHue(input.Position.Y)
		end
	end))
	keep(UIS.InputEnded:Connect(function(input)
		if dragEnd(input) then
			dragSV, dragHue = false, false
		end
	end))

	click.onClick(function()
		picker.Visible = not picker.Visible
	end)
	tip(r, o.Tooltip)
	setFlag(o, color)

	local obj = { Frame = holder, Render = render }
	function obj:Get()
		return color
	end
	function obj:Set(c, silent)
		h, s, v = c:ToHSV()
		render()
		if silent then
			setFlag(o, color)
		else
			fire(o, color)
		end
	end
	return obj
end

local function buildColorWheel(parent, o, order)
	local color = o.Default or Color3.fromRGB(244, 49, 32)
	local h, s, v = color:ToHSV()

	local holder = Instance.new("Frame")
	holder.Name = "ColorWheel"
	holder.BackgroundTransparency = 1
	holder.AutomaticSize = Enum.AutomaticSize.Y
	holder.Size = UDim2.new(1, 0, 0, 0)
	holder.LayoutOrder = order or 1
	holder.Parent = parent
	vlist(holder, theme.GapSm)

	local r = row(holder, o.Name or "Color", 1, nil, 54)
	local click = hoverable(r, true)
	local swatch = Instance.new("Frame")
	swatch.Name = "Swatch"
	swatch.BorderSizePixel = 0
	swatch.Size = UDim2.fromOffset(46, 20)
	swatch.LayoutOrder = 2
	swatch.Parent = r
	corner(swatch, theme.RadiusSm)
	stroke(swatch, theme.Hairline, 1)

	local picker = Instance.new("Frame")
	picker.Name = "Picker"
	picker.BackgroundTransparency = 1
	picker.Size = UDim2.new(1, 0, 0, 180)
	picker.Visible = false
	picker.LayoutOrder = 2
	picker.Parent = holder

	local wheel = Instance.new("Frame")
	wheel.Name = "Wheel"
	wheel.BackgroundTransparency = 1
	wheel.AnchorPoint = Vector2.new(0.5, 0)
	wheel.Position = UDim2.new(0.5, 0, 0, 0)
	wheel.Size = UDim2.fromOffset(150, 150)
	wheel.Active = true
	wheel.Parent = picker

	for i = 0, 35 do
		local spoke = Instance.new("Frame")
		spoke.Name = "Spoke"
		spoke.BorderSizePixel = 0
		spoke.BackgroundColor3 = WHITE
		spoke.AnchorPoint = Vector2.new(0.5, 0.5)
		spoke.Position = UDim2.fromScale(0.5, 0.5)
		spoke.Size = UDim2.fromOffset(150, 10)
		spoke.Rotation = i * 360 / 72
		local g = Instance.new("UIGradient")
		g.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV((i + 36) % 72 / 72, 1, 1)),
			ColorSequenceKeypoint.new(0.5, WHITE),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(i / 72, 1, 1)),
		})
		g.Parent = spoke
		spoke.Parent = wheel
	end

	local shade = Instance.new("Frame")
	shade.Name = "Shade"
	shade.BorderSizePixel = 0
	shade.BackgroundColor3 = BLACK
	shade.Size = UDim2.fromScale(1, 1)
	shade.ZIndex = 3
	shade.Parent = wheel
	corner(shade, 150)

	local rim = Instance.new("Frame")
	rim.Name = "Rim"
	rim.BackgroundTransparency = 1
	rim.Size = UDim2.fromScale(1, 1)
	rim.ZIndex = 4
	rim.Parent = wheel
	corner(rim, 150)
	stroke(rim, theme.Hairline, 2)

	local cursor = Instance.new("Frame")
	cursor.Name = "Cursor"
	cursor.BackgroundTransparency = 1
	cursor.AnchorPoint = Vector2.new(0.5, 0.5)
	cursor.Size = UDim2.fromOffset(12, 12)
	cursor.ZIndex = 5
	cursor.Parent = wheel
	corner(cursor, 6)
	stroke(cursor, WHITE, 2)

	local brightness = Instance.new("Frame")
	brightness.Name = "Brightness"
	brightness.BorderSizePixel = 0
	brightness.BackgroundColor3 = WHITE
	brightness.AnchorPoint = Vector2.new(0.5, 0)
	brightness.Position = UDim2.new(0.5, 0, 0, 162)
	brightness.Size = UDim2.fromOffset(150, 12)
	brightness.Active = true
	brightness.Parent = picker
	corner(brightness, theme.RadiusSm)
	stroke(brightness, theme.Hairline, 1)
	local brightnessGradient = Instance.new("UIGradient")
	brightnessGradient.Parent = brightness

	local marker = Instance.new("Frame")
	marker.Name = "Marker"
	marker.BackgroundColor3 = WHITE
	marker.BorderSizePixel = 0
	marker.AnchorPoint = Vector2.new(0.5, 0.5)
	marker.Size = UDim2.fromOffset(4, 18)
	marker.ZIndex = 4
	marker.Parent = brightness
	corner(marker, 2)

	local function render()
		color = Color3.fromHSV(h, s, v)
		swatch.BackgroundColor3 = color
		shade.BackgroundTransparency = v
		local angle = h * 2 * math.pi
		cursor.Position = UDim2.fromScale(0.5 + math.cos(angle) * s * 0.5, 0.5 + math.sin(angle) * s * 0.5)
		brightnessGradient.Color = ColorSequence.new(BLACK, Color3.fromHSV(h, s, 1))
		marker.Position = UDim2.new(v, 0, 0.5, 0)
	end
	render()

	local dragWheel, dragBright = false, false
	local function updateWheel(x, y)
		local size = wheel.AbsoluteSize
		if size.X <= 0 then
			return
		end
		local center = wheel.AbsolutePosition + size * 0.5
		local dx, dy = x - center.X, y - center.Y
		h = math.atan2(dy, dx) / (2 * math.pi) % 1
		s = math.clamp(math.sqrt(dx * dx + dy * dy) / (size.X * 0.5), 0, 1)
		render()
		fire(o, color)
	end
	local function updateBright(x)
		if brightness.AbsoluteSize.X <= 0 then
			return
		end
		v = math.clamp((x - brightness.AbsolutePosition.X) / brightness.AbsoluteSize.X, 0, 1)
		render()
		fire(o, color)
	end
	wheel.InputBegan:Connect(function(input)
		if not pressOnTop(wheel, input) then
			return
		end
		if isPress(input) then
			dragWheel = true
			updateWheel(input.Position.X, input.Position.Y)
		end
	end)
	brightness.InputBegan:Connect(function(input)
		if not pressOnTop(brightness, input) then
			return
		end
		if isPress(input) then
			dragBright = true
			updateBright(input.Position.X)
		end
	end)
	keep(UIS.InputChanged:Connect(function(input)
		if not isMove(input) then
			return
		end
		if dragWheel then
			updateWheel(input.Position.X, input.Position.Y)
		end
		if dragBright then
			updateBright(input.Position.X)
		end
	end))
	keep(UIS.InputEnded:Connect(function(input)
		if dragEnd(input) then
			dragWheel, dragBright = false, false
		end
	end))

	click.onClick(function()
		picker.Visible = not picker.Visible
	end)
	tip(r, o.Tooltip)
	setFlag(o, color)

	local obj = { Frame = holder, Render = render }
	function obj:Get()
		return color
	end
	function obj:Set(c, silent)
		h, s, v = c:ToHSV()
		render()
		if silent then
			setFlag(o, color)
		else
			fire(o, color)
		end
	end
	return obj
end

----------------------------------------------------------------------
-- Container mixin (Tab และ Section ใช้ร่วมกัน)
----------------------------------------------------------------------
local Container = {}

function Container:_next()
	self._n = (self._n or 0) + 1
	return self._n
end

function Container:AddToggle(o)
	return buildToggle(self._content, o or {}, self:_next())
end
function Container:AddSlider(o)
	return buildSlider(self._content, o or {}, self:_next())
end
function Container:AddRangeSlider(o)
	return buildRangeSlider(self._content, o or {}, self:_next())
end
function Container:AddDropdown(o)
	return buildDropdown(self._content, o or {}, self:_next())
end
function Container:AddTextInput(o)
	return buildTextInput(self._content, o or {}, self:_next())
end
function Container:AddListInput(o)
	return buildListInput(self._content, o or {}, self:_next())
end
function Container:AddColorPicker(o)
	return buildColorPicker(self._content, o or {}, self:_next())
end
function Container:AddColorWheel(o)
	return buildColorWheel(self._content, o or {}, self:_next())
end
function Container:AddButton(o)
	return buildButton(self._content, o or {}, self:_next())
end
function Container:AddButtonRow()
	return buildButtonRow(self._content, self:_next())
end
function Container:AddLabel(text)
	local t = type(text) == "table" and (text.Text or "") or tostring(text or "")
	local l = caption(self._content, t, self:_next())
	local obj = { Frame = l }
	function obj:SetText(newText)
		l.Text = newText
	end
	return obj
end

-- Section: หัวแถว SurfaceSection (พับได้ + แอนิเมชัน) / เนื้อหาใน SurfaceWell
local function buildSection(parent, o, order)
	local section = Instance.new("Frame")
	section.Name = "Section"
	section.BackgroundTransparency = 1
	section.AutomaticSize = Enum.AutomaticSize.Y
	section.Size = UDim2.new(1, 0, 0, 0)
	section.LayoutOrder = order or 1
	section.Parent = parent
	vlist(section, theme.GapSm)

	local head, title = row(section, o.Title or "Section", 1, nil, 24)
	head.BackgroundColor3 = theme.SurfaceSection
	setFont(title, "sans", Enum.FontWeight.SemiBold)
	local click = hoverable(head, true)
	local chev = chevron(head)

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.BackgroundColor3 = theme.SurfaceWell
	content.BorderSizePixel = 0
	content.AutomaticSize = Enum.AutomaticSize.Y
	content.Size = UDim2.new(1, 0, 0, 0)
	content.Visible = false
	content.LayoutOrder = 2
	content.Parent = section
	corner(content, theme.RadiusMd)
	local layout = vlist(content, theme.GapSm)
	pad(content, 6, 6, 6, 6)

	local visible = false
	local function setOpen(v, instant)
		v = v and true or false
		local changed = v ~= visible
		visible = v
		chev.setOpen(visible)
		title.TextColor3 = visible and theme.AccentMid or theme.TextPrimary
		if changed then
			if not instant and animateOK(section) then
				slideTo(content, layout, 12, visible)
			else
				content.Visible = visible
			end
		else
			content.Visible = visible
		end
	end
	setOpen(false, true)
	click.onClick(function()
		setOpen(not visible)
	end)
	tip(head, o.Tooltip)

	if o.Description and o.Description ~= "" then
		local d = label(content, o.Description, "captionSub", -1000)
		d.Name = "Description"
		d.TextSize = 11
		d.AutomaticSize = Enum.AutomaticSize.Y
		d.Size = UDim2.new(1, 0, 0, 0)
		d.TextWrapped = true
		d.TextYAlignment = Enum.TextYAlignment.Top
		pad(d, 2, 4, 2, 4)
	end

	local sec = setmetatable({ Frame = section, _content = content }, { __index = Container })
	function sec:SetOpen(v, instant)
		setOpen(v, instant)
	end
	function sec:Open()
		setOpen(true)
	end
	function sec:Close()
		setOpen(false)
	end
	function sec:Toggle()
		setOpen(not visible)
	end
	function sec:IsOpen()
		return visible
	end
	function sec:SetTitle(t)
		title.Text = t
	end

	if o.Open == true then
		setOpen(true, true)
	end
	return sec
end

function Container:AddSection(o)
	return buildSection(self._content, o or {}, self:_next())
end

----------------------------------------------------------------------
-- Window (แนวนอน: header + แท็บซ้าย + หน้าเนื้อหาขวา)
----------------------------------------------------------------------
local function makeDraggable(handle, frame)
	local dragging, startPointer, startPos = false, nil, nil
	handle.InputBegan:Connect(function(input)
		if isPress(input) and pressOnTop(frame, input) then
			dragging = true
			startPointer = input.Position
			startPos = frame.Position
			raiseWindow(frame)
		end
	end)
	handle.InputEnded:Connect(function(input)
		if dragEnd(input) then
			dragging = false
		end
	end)
	keep(UIS.InputChanged:Connect(function(input)
		if not dragging or not isMove(input) then
			return
		end
		local d = input.Position - startPointer
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + d.X,
			startPos.Y.Scale,
			startPos.Y.Offset + d.Y
		)
	end))
	keep(UIS.InputEnded:Connect(function(input)
		if dragEnd(input) then
			dragging = false
		end
	end))
end

function UILib:CreateWindow(o)
	o = o or {}
	self:Init()

	local width, height = o.Width or 580, o.Height or 380
	local sidebarW = o.SidebarWidth or 150
	local offset = 30 * #windows

	local frame = Instance.new("Frame")
	frame.Name = o.Name or "Window"
	frame.BackgroundColor3 = WHITE
	frame.BorderSizePixel = 0
	frame.Size = UDim2.fromOffset(width, height)
	frame.Position = o.Position or UDim2.fromOffset(40 + offset, 40 + offset)
	frame.Visible = o.Visible ~= false
	frame.Active = true
	frame.ClipsDescendants = true
	frame.ZIndex = 2
	frame:SetAttribute("hlWin", true)
	frame.Parent = gui

	frame.InputBegan:Connect(function(input)
		if isPress(input) and pressOnTop(frame, input) and frame.Parent then
			pointerPos(input)
			local best, bestRank
			for _, child in ipairs(frame.Parent:GetChildren()) do
				if child:IsA("GuiObject") and child.Visible and child:GetAttribute("hlWin") then
					local r = rankOf(child)
					if not bestRank or r > bestRank then
						best, bestRank = child, r
					end
				end
			end
			if best ~= frame then
				task.defer(raiseWindow, frame)
			end
		end
	end)

	corner(frame, theme.RadiusLg)
	stroke(frame, theme.Hairline, 1)
	bodyGradient(frame)
	shadow(frame)

	local win = { Frame = frame, _pinned = false, _hidden = (o.Visible == false) }

	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.BackgroundColor3 = theme.SurfaceHeader
	header.BorderSizePixel = 0
	header.Size = UDim2.new(1, 0, 0, theme.HeaderH)
	header.Position = UDim2.fromOffset(0, 3)
	header.Active = true
	header.ZIndex = 3
	header.Parent = frame
	corner(header, theme.RadiusLg)
	pad(header, 0, 12, 0, 14)

	local headerFill = Instance.new("Frame")
	headerFill.Name = "HeaderFill"
	headerFill.BackgroundColor3 = theme.SurfaceHeader
	headerFill.BorderSizePixel = 0
	headerFill.Position = UDim2.fromOffset(0, theme.HeaderH + 3 - theme.RadiusLg)
	headerFill.Size = UDim2.new(1, 0, 0, theme.RadiusLg)
	headerFill.ZIndex = 3
	headerFill.Parent = frame

	local accentBar = Instance.new("CanvasGroup")
	accentBar.Name = "AccentBar"
	accentBar.BackgroundTransparency = 1
	accentBar.BorderSizePixel = 0
	accentBar.Position = UDim2.fromOffset(0, 0)
	accentBar.Size = UDim2.new(1, 0, 0, theme.RadiusLg + 3)
	accentBar.ZIndex = 4
	accentBar.Parent = frame
	corner(accentBar, theme.RadiusLg)

	local band = Instance.new("Frame")
	band.Name = "Band"
	band.BackgroundColor3 = WHITE
	band.BorderSizePixel = 0
	band.Size = UDim2.new(1, 0, 0, 3)
	band.ZIndex = 4
	band.Parent = accentBar
	accentSweep(band)

	hlist(header, theme.GapLg)
	makeDraggable(header, frame)

	local mark
	if o.Icon and ICONS[o.Icon] then
		mark = icon(header, o.Icon, 16, WHITE, 4)
		mark.Name = "Icon"
		mark.LayoutOrder = 1
	else
		mark = Instance.new("Frame")
		mark.Name = "Icon"
		mark.BackgroundColor3 = WHITE
		mark.BorderSizePixel = 0
		mark.Size = UDim2.fromOffset(14, 14)
		mark.LayoutOrder = 1
		mark.ZIndex = 4
		mark.Parent = header
		corner(mark, 4)
	end
	accentGradient(mark, 45)

	local title = label(header, o.Title or "Window", "windowTitle", 2)
	title.ZIndex = 4
	flexFill(title, 58 + (o.Info and 32 or 0))

	-- Pin
	local pin = Instance.new("TextButton")
	pin.Name = "Pin"
	pin.BackgroundColor3 = theme.SurfaceElement
	pin.BorderSizePixel = 0
	pin.Size = UDim2.fromOffset(20, 20)
	pin.Text = ""
	pin.AutoButtonColor = false
	pin.LayoutOrder = 3
	pin.ZIndex = 4
	pin.Parent = header
	corner(pin, 6)
	local pinStroke = stroke(pin, theme.Hairline, 1)
	local pinIcon = icon(pin, "pin", 13, theme.TextMuted, 5)
	pinIcon.AnchorPoint, pinIcon.Position = Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5)
	local function renderPin()
		pinIcon.ImageColor3 = win._pinned and theme.AccentMid or theme.TextMuted
		pinStroke.Color = win._pinned and theme.AccentMid or theme.Hairline
		pin.BackgroundColor3 = win._pinned and theme.SurfaceHover or theme.SurfaceElement
	end
	renderPin()
	tip(
		pin,
		"Pin this window so it stays on screen after you close the interface. You can still drag it. Click again to let it hide with the rest."
	)

	if o.Info then
		local info = Instance.new("TextLabel")
		info.Name = "Info"
		info.BackgroundColor3 = theme.SurfaceElement
		info.BorderSizePixel = 0
		info.Size = UDim2.fromOffset(20, 20)
		info.Text = ""
		info.TextColor3 = theme.TextSub
		info.TextSize = 12
		info.LayoutOrder = 3
		info.ZIndex = 4
		setFont(info, "sans", Enum.FontWeight.Bold)
		info.Parent = header
		corner(info, 10)
		stroke(info, theme.Hairline, 1)
		local ic = icon(info, "info", 13, theme.TextSub, 5)
		ic.AnchorPoint, ic.Position = Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5)
		tip(info, o.Info)
	end

	local divider = Instance.new("Frame")
	divider.Name = "Divider"
	divider.BackgroundColor3 = theme.Hairline
	divider.BorderSizePixel = 0
	divider.Size = UDim2.new(1, 0, 0, 1)
	divider.Position = UDim2.fromOffset(0, 3 + theme.HeaderH)
	divider.ZIndex = 3
	divider.Parent = frame

	-- Sidebar (แท็บ) + เส้นแบ่งแนวตั้ง + พื้นที่หน้า
	local bodyTop = 4 + theme.HeaderH
	local bodyBottom = theme.RadiusLg

	local sidebar = Instance.new("ScrollingFrame")
	sidebar.Name = "Tabs"
	sidebar.BackgroundTransparency = 1
	sidebar.BorderSizePixel = 0
	sidebar.Position = UDim2.fromOffset(0, bodyTop)
	sidebar.Size = UDim2.new(0, sidebarW, 1, -(bodyTop + bodyBottom))
	sidebar.CanvasSize = UDim2.new()
	sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
	sidebar.ScrollBarThickness = 0
	sidebar.ZIndex = 3
	sidebar.Parent = frame
	pad(sidebar, 10, 8, 10, 12)
	vlist(sidebar, theme.GapSm)

	local sidebarDivider = Instance.new("Frame")
	sidebarDivider.Name = "SidebarDivider"
	sidebarDivider.BackgroundColor3 = theme.Hairline
	sidebarDivider.BorderSizePixel = 0
	sidebarDivider.Position = UDim2.fromOffset(sidebarW, bodyTop)
	sidebarDivider.Size = UDim2.new(0, 1, 1, -(bodyTop + bodyBottom))
	sidebarDivider.ZIndex = 3
	sidebarDivider.Parent = frame

	local pages = Instance.new("Frame")
	pages.Name = "Pages"
	pages.BackgroundTransparency = 1
	pages.Position = UDim2.fromOffset(sidebarW + 1, bodyTop)
	pages.Size = UDim2.new(1, -(sidebarW + 1), 1, -(bodyTop + bodyBottom))
	pages.ClipsDescendants = true
	pages.ZIndex = 3
	pages.Parent = frame

	local tabs = {}

	function win:SelectTab(tab)
		for _, t in ipairs(tabs) do
			t._setSelected(t == tab)
		end
	end

	function win:AddTab(t)
		t = t or {}
		local tab = setmetatable({}, { __index = Container })

		local btn, lbl = row(sidebar, t.Name or "Tab", #tabs + 1, nil, 0)
		btn.Name = "Tab"
		local btnStroke = btn:FindFirstChildOfClass("UIStroke")
		local ic
		local reserve = 0
		if t.Icon and ICONS[t.Icon] then
			ic = icon(btn, t.Icon, 16, theme.TextSub, 4)
			ic.LayoutOrder = 1
			lbl.LayoutOrder = 2
			reserve = 24
		end
		lbl.Size = UDim2.new(1, -reserve, 1, 0)
		btn.Active = true

		local page = Instance.new("ScrollingFrame")
		page.Name = t.Name or "Page"
		page.BackgroundTransparency = 1
		page.BorderSizePixel = 0
		page.Size = UDim2.fromScale(1, 1)
		page.CanvasSize = UDim2.new()
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		page.ScrollBarThickness = 4
		page.ScrollBarImageColor3 = Color3.fromHex("50505f")
		page.Visible = false
		page.ZIndex = 3
		page.Parent = pages
		pad(page, 10, theme.GapLg, theme.GapXl, theme.GapLg)
		vlist(page, theme.GapSm)

		tab._content = page
		tab.Page = page
		tab.Button = btn

		local selected = false
		local function render()
			btn.BackgroundColor3 = selected and theme.SurfaceHover or theme.SurfaceElement
			lbl.TextColor3 = selected and theme.AccentMid or theme.TextPrimary
			btnStroke.Color = selected and theme.AccentMid or theme.Hairline
			if ic then
				ic.ImageColor3 = selected and theme.AccentMid or theme.TextSub
			end
			page.Visible = selected
		end
		tab._setSelected = function(on)
			selected = on
			render()
		end
		render()

		btn.MouseEnter:Connect(function()
			if not selected and pressOnTop(btn) then
				TweenService:Create(btn, TweenInfo.new(0.14, Enum.EasingStyle.Quint), {
					BackgroundColor3 = theme.SurfaceHover,
				}):Play()
			end
		end)
		btn.MouseLeave:Connect(function()
			if not selected then
				TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
					BackgroundColor3 = theme.SurfaceElement,
				}):Play()
			end
		end)
		btn.InputBegan:Connect(function(input)
			if isPress(input) and pressOnTop(btn, input) then
				win:SelectTab(tab)
			end
		end)
		tip(btn, t.Tooltip)

		function tab:Select()
			win:SelectTab(self)
		end

		tabs[#tabs + 1] = tab
		if #tabs == 1 then
			win:SelectTab(tab)
		end
		return tab
	end

	local function refreshVisible()
		frame.Visible = (not win._hidden) and (libVisible or win._pinned)
	end
	win._refresh = refreshVisible
	refreshVisible()

	pin.MouseButton1Click:Connect(function()
		win:SetPinned(not win._pinned)
	end)

	function win:SetPinned(v)
		self._pinned = v and true or false
		renderPin()
		refreshVisible()
		if o.OnPinChanged then
			o.OnPinChanged(self)
		end
	end
	function win:IsPinned()
		return self._pinned
	end
	function win:SetVisible(v)
		self._hidden = not v
		refreshVisible()
	end
	function win:SetTitle(t)
		title.Text = t
	end
	function win:Destroy()
		for i, w in ipairs(windows) do
			if w == self then
				table.remove(windows, i)
				break
			end
		end
		frame:Destroy()
	end

	windows[#windows + 1] = win
	return win
end

----------------------------------------------------------------------
-- Library lifecycle
----------------------------------------------------------------------
function UILib:Init(opts)
	if gui and gui.Parent then
		return self
	end
	opts = opts or {}
	gui = Instance.new("ScreenGui")
	gui.Name = opts.Name or "UILib"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder = opts.DisplayOrder or 999
	gui.IgnoreGuiInset = true
	-- ส่ง Parent เองได้ เช่น Init({ Parent = someGui }) ไม่งั้นใช้ PlayerGui
	gui.Parent = opts.Parent or Players.LocalPlayer:WaitForChild("PlayerGui")
	self.Gui = gui

	ensureTip(gui)

	if opts.ToggleKey then
		keep(UIS.InputBegan:Connect(function(input, processed)
			if processed then
				return
			end
			if input.KeyCode == opts.ToggleKey then
				self:Toggle()
			end
		end))
	end
	return self
end

function UILib:SetVisible(v)
	libVisible = v and true or false
	if not libVisible then
		hideTip()
	end
	for _, w in ipairs(windows) do
		w._refresh()
	end
end

function UILib:Toggle()
	self:SetVisible(not libVisible)
end

function UILib:IsVisible()
	return libVisible
end

function UILib:Destroy()
	for _, c in ipairs(conns) do
		pcall(function()
			c:Disconnect()
		end)
	end
	conns, windows, sweeps = {}, {}, {}
	sweepConn = nil
	tipState = { frame = nil, label = nil, target = nil, showAt = 0, conn = nil }
	if gui then
		gui:Destroy()
		gui = nil
	end
	self.Gui = nil
	self.Flags = {}
	libVisible = true
	topCounter = 0
end

return UILib
