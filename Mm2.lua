if _G.FVLV2Cleanup then
	_G.__FVLReloading = true
	pcall(_G.FVLV2Cleanup)
	_G.__FVLReloading = nil
end

do
	local ok, text = pcall(function()
		return identifyexecutor()
	end)

	ok = ok and type(text) == "string"
	local str1 = ""

	if not ok then
		text = str1
	end

	if text == "" then
		local ok2, result = pcall(function()
			return getexecutorname()
		end)

		if ok2 and type(result) == "string" then
			text = result
		end
	end

	text = text:match("^%s*(%a+)") or text
	local obj1 = text:lower()
	local flag1 = false

	for _, item in ipairs({ "solara", "xeno" }) do
		if obj1:find(item, 1, true) then
			flag1 = true
		end
	end

	if flag1 then
		local color = Color3.fromRGB(236, 236, 244)
		local color2 = Color3.fromRGB(168, 168, 184)
		local color3 = Color3.fromRGB(29, 29, 37)
		local color4 = Color3.fromRGB(158, 158, 174)
		local color5 = Color3.fromRGB(232, 232, 240)
		local color6 = Color3.fromRGB(22, 22, 28)
		local color7 = Color3.fromRGB(34, 197, 94)
		local hui = gethui and gethui() or game:GetService("CoreGui")
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "FVLExecutorWarning"
		screenGui.IgnoreGuiInset = true
		screenGui.ResetOnSpawn = false
		screenGui.DisplayOrder = 2000000
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		screenGui.Parent = hui
		local frame = Instance.new("Frame")
		frame.Size = UDim2.fromScale(1, 1)
		frame.BackgroundColor3 = Color3.new(0, 0, 0)
		frame.BackgroundTransparency = 0.4
		frame.BorderSizePixel = 0
		frame.ZIndex = 1
		frame.Parent = screenGui
		local x = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X or 800
		local frame2 = Instance.new("Frame")
		frame2.AnchorPoint = Vector2.new(0.5, 0.5)
		frame2.Position = UDim2.fromScale(0.5, 0.5)
		frame2.Size = UDim2.fromOffset(math.min(440, math.max(300, x - 40)), 236)
		frame2.BackgroundColor3 = Color3.fromRGB(23, 23, 28)
		frame2.BorderSizePixel = 0
		frame2.ZIndex = 2
		frame2.Parent = screenGui
		Instance.new("UICorner", frame2).CornerRadius = UDim.new(0, 22)
		local uiGradient = Instance.new("UIGradient", frame2)
		uiGradient.Rotation = 90

		uiGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 36)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 16, 20)),
		})

		local uiStroke = Instance.new("UIStroke", frame2)
		uiStroke.Color = color7
		uiStroke.Thickness = 1
		uiStroke.Transparency = 0.7
		local textLabel = Instance.new("TextLabel")
		textLabel.BackgroundTransparency = 1
		textLabel.Position = UDim2.new(0, 26, 0, 24)
		textLabel.Size = UDim2.new(1, -52, 0, 24)
		textLabel.Font = Enum.Font.GothamBold
		textLabel.TextSize = 18
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.TextColor3 = color
		textLabel.Text = "Executor Warning"
		textLabel.ZIndex = 3
		textLabel.Parent = frame2
		local textLabel2 = Instance.new("TextLabel")
		textLabel2.BackgroundTransparency = 1
		textLabel2.Position = UDim2.new(0, 26, 0, 48)
		textLabel2.Size = UDim2.new(1, -52, 0, 18)
		textLabel2.Font = Enum.Font.Gotham
		textLabel2.TextSize = 12
		textLabel2.TextXAlignment = Enum.TextXAlignment.Left
		textLabel2.TextColor3 = color4
		textLabel2.Text = text
		textLabel2.ZIndex = 3
		textLabel2.Parent = frame2
		local textLabel3 = Instance.new("TextLabel")
		textLabel3.BackgroundTransparency = 1
		textLabel3.Position = UDim2.new(0, 26, 0, 78)
		textLabel3.Size = UDim2.new(1, -52, 0, 96)
		textLabel3.Font = Enum.Font.Gotham
		textLabel3.TextSize = 14
		textLabel3.TextWrapped = true
		textLabel3.LineHeight = 1.15
		textLabel3.TextXAlignment = Enum.TextXAlignment.Left
		textLabel3.TextYAlignment = Enum.TextYAlignment.Top
		textLabel3.TextColor3 = color2

		textLabel3.Text = "Seems like you are using " .. text .. [[. This executor might not support all features of the script, and may result in bigger glitches or bugs.

Please use a better executor next time.]]

		textLabel3.ZIndex = 3
		textLabel3.Parent = frame2
		local textButton = Instance.new("TextButton")
		textButton.AnchorPoint = Vector2.new(0.5, 1)
		textButton.Position = UDim2.new(0.5, 0, 1, -22)
		textButton.Size = UDim2.new(1, -52, 0, 38)
		textButton.BackgroundColor3 = color3
		textButton.BorderSizePixel = 0
		textButton.AutoButtonColor = false
		textButton.Font = Enum.Font.GothamBold
		textButton.TextSize = 13
		textButton.TextColor3 = color4
		textButton.Text = "Understood  (5)"
		textButton.ZIndex = 3
		textButton.Parent = frame2
		Instance.new("UICorner", textButton).CornerRadius = UDim.new(0, 12)
		local flag2 = false
		local flag3 = false

		task.spawn(function()
			for i = 5, 1, -1 do
				textButton.Text = "Understood  (" .. i .. ")"
				task.wait(1)
			end

			flag2 = true
			textButton.Text = "Understood"
			textButton.BackgroundColor3 = color5
			textButton.TextColor3 = color6
		end)

		local function func1()
			if not flag2 or flag3 then
				return
			end
			flag3 = true

			pcall(function()
				screenGui:Destroy()
			end)
		end

		textButton.MouseButton1Click:Connect(func1)
		textButton.TouchTap:Connect(func1)
		local n = 0

		while not flag3 and n < 120 do
			task.wait(0.2)
			n += 0.2
		end

		pcall(function()
			screenGui:Destroy()
		end)
	end
end


if _G.FVLV2 then
	local fvlV2 = _G.FVLV2
	local flag7 = false

	pcall(function()
		flag7 = not fvlV2.Destroyed and fvlV2.UIElements and fvlV2.UIElements.Main and fvlV2.UIElements.Main.Parent ~= nil
	end)

	if flag7 then
		pcall(function()
			fvlV2:Destroy()
		end)

		local now = os.clock()

		while true do
			task.wait(0.1)
			if not (fvlV2.Destroyed or os.clock() - now > 3) then
				continue
			end
			break
		end

		task.wait(0.7)
	end

	_G.FVLV2 = nil
end

_G.FVLV2Cleanup = nil

pcall(function()
	local func3 = ipairs
	local CoreGui_ = game:GetService("CoreGui")

	for _, child in func3(CoreGui_:GetChildren()) do
		if child.Name == "FVLESP" or child.Name:match("^FVL.+Button$") then
			child:Destroy()
		end
	end
end)

pcall(function()
	local hui = gethui and gethui() or game:GetService("CoreGui")

	for _, child in ipairs(hui:GetChildren()) do
		if child.Name == "WindUI" or child.Name:match("^WindUI/") then
			child:Destroy()
		end
	end
end)

--[[==========================================================================
    F$VL MM2 — UI ported to OasisUI (WindUI-compatible shim)
    The block below replaces the original WindUI loader + theme + window setup.
    obj2 / obj3 keep the same WindUI-style surface so the rest of the script
    (game logic, callbacks, config, keybinds) runs unchanged.
  ==========================================================================]]

local __guiBefore = {} -- GUIs that existed before the UI library loaded (used for role colours)
pcall(function()
	for _, container in ipairs({ (gethui and gethui()) or game:GetService("CoreGui"), game:GetService("CoreGui") }) do
		for _, child in ipairs(container:GetChildren()) do
			__guiBefore[child] = true
		end
	end
end)

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/thanyathonbuthong-ai/UI/refs/heads/main/UI%20KIM"))()
local obj2, obj3  -- WindUI-style handles, assigned below (upvalues for the rest of the script)

-- theme: match the original F$VL green look as closely as OasisUI allows
pcall(function()
	local Theme = Library.Theme
	if Theme and Theme.UsePalette then
		pcall(Theme.UsePalette, "Emerald")
	end
	if Theme and Theme.Set then
		pcall(Theme.Set, {
			Accent = Color3.fromHex("#22c55e"),
			AccentAlt = Color3.fromHex("#4ade80"),
		})
	end
end)

local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local hui = (gethui and gethui()) or CoreGui

-- icon normalizer: WindUI uses "lucide:x" / "solar:x-bold"; OasisUI wants plain Lucide names
local function normIcon(icon)
	if icon == nil then return nil end
	if type(icon) == "number" then return icon end
	if typeof(icon) == "EnumItem" then return nil end
	local s = tostring(icon)
	if s:match("^rbxassetid://") then
		local n = tonumber(s:match("(%d+)"))
		return n
	end
	s = s:gsub("^lucide:", ""):gsub("^solar:", "")
	s = s:gsub("-bold%-duotone$", ""):gsub("-bold$", ""):gsub("-linear$", ""):gsub("-broken$", "")
	local map = {
		["gamepad-directional"] = "gamepad-2",
		["dollar-minimalistic"] = "dollar-sign",
		["eye"] = "eye",
		["bolt"] = "zap",
		["user"] = "user",
		["arrow-right-left"] = "arrow-left-right",
		["flame"] = "flame",
		["shield"] = "shield",
		["crosshair"] = "crosshair",
		["sword"] = "sword",
		["sparkles"] = "sparkles",
		["mouse-pointer-click"] = "mouse-pointer-click",
		["wind"] = "wind",
		["layout-grid"] = "layout-grid",
		["columns-2"] = "columns-2",
		["columns-3"] = "columns-3",
		["shirt"] = "shirt",
		["image"] = "image",
		["play"] = "play",
		["zap"] = "zap",
		["trash-2"] = "trash-2",
		["x"] = "x",
		["check"] = "check",
		["plus"] = "plus",
		["save"] = "save",
		["download"] = "download",
		["copy"] = "copy",
		["clipboard-paste"] = "clipboard-paste",
		["scissors"] = "scissors",
		["zoom-in"] = "zoom-in",
		["zoom-out"] = "zoom-out",
		["arrow-left"] = "arrow-left",
		["arrow-right"] = "arrow-right",
		["home"] = "home",
		["settings"] = "settings",
		["palette"] = "palette",
		["keyboard"] = "keyboard",
		["smartphone"] = "smartphone",
		["youtube"] = "youtube",
		["users"] = "users",
		["folder-open"] = "folder-open",
		["trash"] = "trash-2",
		["loader"] = "loader",
		["tag"] = "tag",
		["power"] = "power",
	}
	return map[s] or s
end

-- flag registry for config persistence (replaces WindUI ConfigManager)
local _FVL = { flags = {}, autoSave = nil }

local function colorToTable(c)
	return { __color = true, r = c.R, g = c.G, b = c.B }
end
local function tableToColor(t)
	return Color3.new(t.r, t.g, t.b)
end

-- element wrapper helpers ---------------------------------------------------
-- .Value is read dynamically from the underlying OasisUI element so the
-- script's direct `.Value` checks (e.g. handleLink.Value) always stay fresh.
local dynMT = {
	__index = function(t, k)
		if k == "Value" then
			local ok, v = pcall(function() return t._oasis.Value end)
			return ok and v or rawget(t, "_fallback")
		end
		return rawget(t, k)
	end,
	__newindex = function(t, k, v)
		if k == "Value" then
			local set = rawget(t, "Set")
			if set then pcall(set, t, v); return end
		end
		rawset(t, k, v)
	end,
}
local function dyn(w) return setmetatable(w, dynMT) end

-- silent programmatic set: updates state + repaints WITHOUT firing the callback.
-- WindUI's SetValue repainted regardless; OasisUI skips repaint when silent=true,
-- so we fire Changed manually (the paint handler is connected to it, the
-- callback is invoked directly inside _commit and is skipped by silent=true).
-- config-load set: NON-silent so it repaints the switch AND invokes the
-- callback (real functionality turns on). WindUI applied saved values fully;
-- OasisUI's silent=true skips the callback so features stayed off.
local function syncSet(oasis, v)
	pcall(function() if oasis.Set then oasis:Set(v, false) end end)
end

local function wrapToggle(oasis, def)
	local w = dyn({ _oasis = oasis })
	if def and def.Flag then _FVL.flags[def.Flag] = w end
	function w:Set(v, silent) pcall(function() oasis:Set(v and true or false, silent) end) end
	function w:GetValue() return oasis.Value end
	function w:SetValue(v) syncSet(oasis, v) end
	return w
end

local function wrapSlider(oasis, def)
	local w = dyn({ _oasis = oasis })
	if def and def.Flag then _FVL.flags[def.Flag] = w end
	function w:Set(v, silent)
		pcall(function()
			if oasis.Set then oasis:Set(v, silent)
			else oasis.Value = v; oasis.Changed:Fire(v) end
		end)
	end
	function w:GetValue() return oasis.Value end
	function w:SetValue(v) syncSet(oasis, v) end
	return w
end

local function wrapDropdown(oasis, def)
	local w = dyn({ _oasis = oasis })
	if def and def.Flag then _FVL.flags[def.Flag] = w end
	function w:Refresh(values, keep) pcall(function() oasis:Refresh(values, keep) end) end
	function w:SetValues(values) w:Refresh(values) end
	function w:Set(v, silent) pcall(function() oasis:Set(v, silent) end) end
	function w:GetValue() return oasis.Value end
	function w:SetValue(v) syncSet(oasis, v) end
	return w
end

local function wrapColorPicker(oasis, def)
	local w = dyn({ _oasis = oasis })
	if def and def.Flag then _FVL.flags[def.Flag] = w end
	function w:Set(v, silent) pcall(function() if oasis.Set then oasis:Set(v, silent) else oasis.Value = v end end) end
	function w:GetValue()
		local v = oasis.Value
		return typeof(v) == "Color3" and colorToTable(v) or v
	end
	function w:SetValue(v)
		if type(v) == "table" and v.__color then w:Set(tableToColor(v), true) else w:Set(v, true) end
	end
	return w
end

local function wrapInput(oasis, def)
	local w = dyn({ _oasis = oasis })
	if def and def.Flag then _FVL.flags[def.Flag] = w end
	function w:Set(v, silent)
		pcall(function()
			if oasis.Set then oasis:Set(v, silent)
			elseif oasis.SetText then oasis:SetText(v)
			else oasis.Value = v end
		end)
	end
	function w:Get() return oasis.Value end
	function w:GetValue() return oasis.Value end
	function w:SetValue(v) syncSet(oasis, v) end
	return w
end

local function wrapKeybind(oasis, def)
	local w = { _oasis = oasis, Value = nil }
	if def and def.Flag then _FVL.flags[def.Flag] = w end
	function w:GetKey() local ok, k = pcall(function() return oasis:GetKey() end); return ok and k or nil end
	function w:GetValue() return w:GetKey() end
	function w:SetValue(v) pcall(function() if oasis.SetKey then oasis:SetKey(v) elseif oasis.Set then oasis:SetKey(v) end end) end
	return w
end

local function wrapButton(oasis, def)
	local w = { _oasis = oasis }
	return w
end

-- paragraph wrapper: OasisUI Label + SetDesc + (lazy) skin-grid container
local function wrapParagraph(oasis, def, oasisTab, window)
	local title = def and def.Title or ""
	local w = { _oasis = oasis, _title = title }
	function w:SetDesc(text)
		pcall(function() oasis:Set(title .. "\n" .. tostring(text or "")) end)
	end
	-- lazy container for the custom skin grid (func119 reads .ParagraphFrame.UIElements.Container)
	local container = Instance.new("Frame")
	container.Name = "FVLParagraphContainer"
	container.BackgroundTransparency = 1
	container.Size = UDim2.new(1, 0, 0, 0)
	container.AutomaticSize = Enum.AutomaticSize.Y
	w.ParagraphFrame = { UIElements = { Container = container } }
	task.spawn(function()
		for i = 1, 80 do
			local ok = pcall(function()
				local page = oasisTab and oasisTab.Page
				local pageFrame = page and page.Frame
				if not pageFrame then error("no page") end
				local scroll = pageFrame:FindFirstChildWhichIsA("ScrollingFrame", true)
				if not scroll then error("no scroll") end
				local content = scroll:FindFirstChildOfClass("Frame") or scroll
				if container.Parent == nil then
					container.LayoutOrder = 100000 + i
					container.Parent = content
				end
			end)
			if ok and container.Parent then return end
			RunService.RenderStepped:Wait()
		end
	end)
	return w
end

-- ConfigManager shim (JSON files in FVLV2 folder) ---------------------------
local function cfgPath(name)
	-- fresh namespace so old WindUI / v1 configs are never loaded (they cause bugs);
	-- values saved from this UI live here and load normally on next run.
	return "FVLV2/oasiscfg_" .. tostring(name) .. ".json"
end

local function makeConfig(name)
	local cfg = { Name = name, Elements = {} }
	function cfg:GetData()
		local data = {}
		for flag, w in pairs(_FVL.flags) do
			local ok, v = pcall(function() return w:GetValue() end)
			if ok then data[flag] = v end
		end
		return data
	end
	function cfg:Save()
		pcall(function()
			self.Elements = self:GetData()
			if makefolder and isfolder and not isfolder("FVLV2") then makefolder("FVLV2") end
			if writefile then writefile(cfgPath(self.Name), HttpService:JSONEncode(self.Elements)) end
		end)
	end
	function cfg:Load()
		local ok, data = pcall(function()
			if isfile and isfile(cfgPath(self.Name)) then
				return HttpService:JSONDecode(readfile(cfgPath(self.Name)))
			end
			return nil
		end)
		if not ok or type(data) ~= "table" then return false end
		self.Elements = data
		for flag, v in pairs(data) do
			local w = _FVL.flags[flag]
			if w and w.SetValue then pcall(function() w:SetValue(v) end) end
		end
		return true
	end
	function cfg:Delete()
		pcall(function() if delfile and isfile and isfile(cfgPath(self.Name)) then delfile(cfgPath(self.Name)) end end)
	end
	function cfg:SetAsCurrent() end
	return cfg
end

local ConfigManager = {}
function ConfigManager:CreateConfig(name) return makeConfig(name) end
function ConfigManager:GetConfig(name)
	if isfile and isfile(cfgPath(name)) then return makeConfig(name) end
	return nil
end
function ConfigManager:AllConfigs()
	local out = {}
	pcall(function()
		if listfiles then
			for _, f in ipairs(listfiles("FVLV2")) do
				local n = f:match("cfg_(.+)%.json$")
				if n and n ~= "autosave" then out[#out + 1] = n end
			end
		end
	end)
	return out
end
function ConfigManager:DeleteConfig(name)
	pcall(function() if delfile and isfile and isfile(cfgPath(name)) then delfile(cfgPath(name)) end end)
end

-- section wrapper -----------------------------------------------------------
local function makeSection(oasisSection, oasisTab, window)
	local sec = { _oasis = oasisSection, _tab = oasisTab, _window = window }

	function sec:Toggle(def)
		-- force every toggle to start OFF (no imported state); saved config still
		-- overrides this on subsequent runs via SetValue.
		local d = {
			Title = def.Title or "Toggle",
			Default = false,
			Tooltip = def.Desc or def.Description,
			Callback = function(v)
				if def.Callback then pcall(def.Callback, v) end
			end,
		}
		local ok, el = pcall(function() return oasisSection:Toggle(d) end)
		if not ok then el = oasisSection:Toggle(d) end
		-- WindUI fires the callback on creation so the initial state is applied
		-- (e.g. on-screen buttons get destroyed when their toggle is off).
		-- OasisUI does not, so we fire it manually with the current default.
		task.spawn(function()
			pcall(function() if def.Callback then def.Callback(el.Value) end end)
		end)
		return wrapToggle(el, def)
	end

	function sec:Slider(def)
		local min, max, default = 0, 100, 0
		if type(def.Value) == "table" then
			min = def.Value.Min or 0; max = def.Value.Max or 100; default = def.Value.Default or min
		else
			min = def.Min or 0; max = def.Max or 100; default = def.Default or def.Value or min
		end
		local d = {
			Title = def.Title or "Slider",
			Min = min, Max = max, Default = default,
			Step = def.Step,
			Suffix = def.Suffix,
			Tooltip = def.Desc or def.Description,
			Callback = function(v)
				if def.Callback then pcall(def.Callback, v) end
			end,
		}
		local el = oasisSection:Slider(d)
		return wrapSlider(el, def)
	end

	function sec:Button(def)
		local d = {
			Title = def.Title or "Button",
			Icon = normIcon(def.Icon),
			Tooltip = def.Desc or def.Description,
			Style = def.Style,
			Confirm = def.Confirm,
			Callback = function()
				if def.Callback then pcall(def.Callback) end
			end,
		}
		local el = oasisSection:Button(d)
		return wrapButton(el, def)
	end

	function sec:Dropdown(def)
		local d = {
			Title = def.Title or "Dropdown",
			Values = def.Values or {},
			Default = def.Value,
			Multi = def.Multi == true,
			Placeholder = def.Placeholder,
			Tooltip = def.Desc or def.Description,
			Callback = function(v)
				if def.Callback then pcall(def.Callback, v) end
			end,
		}
		local el = oasisSection:Dropdown(d)
		return wrapDropdown(el, def)
	end

	function sec:Colorpicker(def)
		local d = {
			Title = def.Title or "Color",
			Default = def.Default,
			Tooltip = def.Desc or def.Description,
			Callback = function(v)
				if def.Callback then pcall(def.Callback, v) end
			end,
		}
		local el = oasisSection:ColorPicker(d)
		return wrapColorPicker(el, def)
	end
	sec.ColorPicker = sec.Colorpicker

	function sec:Input(def)
		local d = {
			Title = def.Title or "Input",
			Placeholder = def.Placeholder,
			Default = def.Default or def.Value,
			Numeric = def.Numeric == true,
			Tooltip = def.Desc or def.Description,
			Callback = function(v)
				if def.Callback then pcall(def.Callback, v) end
			end,
		}
		local el = oasisSection:Input(d)
		return wrapInput(el, def)
	end

	function sec:Keybind(def)
		local defaultKey = def.Value
		if defaultKey == "Unknown" or defaultKey == "" then defaultKey = nil end
		local d = {
			Title = def.Title or "Keybind",
			Default = defaultKey,
			Mode = "Always",
			Modes = { "Always" },
			Tooltip = def.Desc or def.Description,
			ChangedCallback = function(key)
				if def.Callback then pcall(def.Callback, key) end
			end,
		}
		local ok, el = pcall(function() return oasisSection:Keybind(d) end)
		if not ok then
			-- fallback: a button that captures the next key press
			local capturing = false
			local btn = oasisSection:Button({
				Title = (def.Title or "Keybind") .. ":  click to set",
				Callback = function() end,
			})
			el = { GetKey = function() return nil end, SetKey = function() end }
		end
		return wrapKeybind(el, def)
	end

	function sec:Paragraph(def)
		local text = ((def.Title or "") .. "\n" .. (def.Desc or "")):gsub("^\n", "")
		local el = oasisSection:Label({ Text = text, Size = 12 })
		return wrapParagraph(el, def, sec._tab, sec._window)
	end

	function sec:Label(def)
		local el = oasisSection:Label({ Text = def.Text or def.Title or "", Size = def.Size or 12 })
		return { _oasis = el, Set = function(_, t) pcall(function() el:Set(t) end) end }
	end

	return sec
end

-- sub-tab (category) bar inside a tab ---------------------------------------
local SubUI = {}
-- tab:SubTabs({ {"Category", {"Section title", ...}}, ... }) groups the tab's
-- sections into categories and adds a pill bar at the top of the tab page.
-- Everything is best-effort: if the page / sections can't be located the tab
-- simply keeps showing every section (nothing breaks).
SubUI.BAR_H = 30

function SubUI.Accent()
	local c = Color3.fromHex("#22c55e")
	pcall(function()
		local a = Library.Theme and Library.Theme.Accent
		if typeof(a) == "Color3" then c = a end
	end)
	return c
end

function SubUI.PageFrame(oasisTab)
	local ok, f = pcall(function() return oasisTab.Page and oasisTab.Page.Frame end)
	if ok and typeof(f) == "Instance" then return f end
	return nil
end

function SubUI.Snapshot(root)
	local s = {}
	for _, d in ipairs(root:GetDescendants()) do s[d] = true end
	return s
end

function SubUI.NewRoots(pageFrame, before)
	local out = {}
	for _, inst in ipairs(pageFrame:GetDescendants()) do
		if not before[inst] and inst:IsA("GuiObject") then
			local p = inst.Parent
			if p == pageFrame or before[p] then out[#out + 1] = inst end
		end
	end
	return out
end

function SubUI.Repaint(S)
	local accent = S.accent
	for _, name in ipairs(S.cats) do
		local b = S.buttons[name]
		if b then
			local on = (name == S.selected)
			b.BackgroundColor3 = on and accent or Color3.fromRGB(34, 34, 42)
			b.TextColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 170, 184)
		end
	end
end

function SubUI.Apply(S)
	for _, name in ipairs(S.cats) do
		local show = (name == S.selected)
		for _, root in ipairs(S.roots[name]) do
			if root.Parent then root.Visible = show end
		end
	end
	SubUI.Repaint(S)
end

function SubUI.Refresh(S)
	-- show a button only for categories that really got sections
	local populated = 0
	for _, name in ipairs(S.cats) do
		local has = #S.roots[name] > 0
		if has then populated = populated + 1 end
		if S.buttons[name] then S.buttons[name].Visible = has end
	end
	if S.bar then S.bar.Visible = populated >= 1 end
	if S.selected == nil or #S.roots[S.selected] == 0 then
		S.selected = nil
		for _, name in ipairs(S.cats) do
			if #S.roots[name] > 0 then S.selected = name; break end
		end
	end
	SubUI.Apply(S)
end

function SubUI.BuildBar(S, pageFrame)
	-- the page's scrolling area: the bar goes above it and pushes it down
	local scroll = pageFrame:FindFirstChildWhichIsA("ScrollingFrame", true)
	if not scroll then return false end
	local holder = scroll
	while holder.Parent and holder.Parent ~= pageFrame do holder = holder.Parent end
	if holder.Parent ~= pageFrame then return false end

	local bar = Instance.new("ScrollingFrame")
	bar.Name = "FVLSubTabs"
	bar.BackgroundTransparency = 1
	bar.BorderSizePixel = 0
	bar.Size = UDim2.new(1, 0, 0, SubUI.BAR_H)
	bar.Position = UDim2.fromOffset(0, 0)
	bar.ScrollBarThickness = 0
	bar.CanvasSize = UDim2.new()
	bar.AutomaticCanvasSize = Enum.AutomaticSize.X
	bar.ScrollingDirection = Enum.ScrollingDirection.X
	bar.ZIndex = 50

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 6)
	layout.Parent = bar
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 4)
	pad.PaddingRight = UDim.new(0, 4)
	pad.Parent = bar

	S.accent = SubUI.Accent()
	for i, name in ipairs(S.cats) do
		local b = Instance.new("TextButton")
		b.Name = "Sub_" .. name
		b.LayoutOrder = i
		b.AutoButtonColor = false
		b.AutomaticSize = Enum.AutomaticSize.X
		b.Size = UDim2.new(0, 0, 0, 24)
		b.BorderSizePixel = 0
		b.Font = Enum.Font.GothamMedium
		b.TextSize = 12
		b.Text = name
		b.ZIndex = 51
		b.Visible = false
		local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 12); c.Parent = b
		local bp = Instance.new("UIPadding")
		bp.PaddingLeft = UDim.new(0, 12); bp.PaddingRight = UDim.new(0, 12)
		bp.Parent = b
		b.Parent = bar
		b.Activated:Connect(function()
			S.selected = name
			SubUI.Apply(S)
		end)
		S.buttons[name] = b
	end

	-- FIX: the page has TWO scrolling columns (left + right). Only the first one used to be pushed
	-- below the bar, so the right column stayed at the top: taller than the left one and covered by
	-- the bar (its collapse arrows could not be clicked). Push every column down by the same amount.
	local shiftList, seen = {}, {}
	local function addShift(inst)
		if inst and not seen[inst] then seen[inst] = true; shiftList[#shiftList + 1] = inst end
	end
	addShift(holder)
	for _, child in ipairs(pageFrame:GetChildren()) do
		if child:IsA("ScrollingFrame") then addShift(child) end
	end
	for _, inst in ipairs(shiftList) do
		inst.Position = inst.Position + UDim2.fromOffset(0, SubUI.BAR_H + 4)
		inst.Size = inst.Size - UDim2.fromOffset(0, SubUI.BAR_H + 4)
	end
	bar.Parent = pageFrame
	S.bar = bar
	return true
end

-- tab wrapper ---------------------------------------------------------------
local function makeTab(oasisTab, window)
	local tab = { _oasis = oasisTab, _window = window, _sections = {}, _current = nil, _secCount = 0 }

	function tab:Section(def)
		tab._secCount = tab._secCount + 1
		local S = tab._subs
		local title = def and def.Title or nil
		local cat = nil
		local n = tab._secCount
		if S then
			cat = (title and S.lookup[title]) or S.last or S.cats[1]
			S.last = cat
			S.count[cat] = (S.count[cat] or 0) + 1
			n = S.count[cat] -- left/right balance is per category
		end
		local side = (n % 2 == 1) and "Left" or "Right"
		local d = {
			Title = title,
			Icon = normIcon(def and def.Icon),
			Side = side,
			Id = def and def.Id,
		}
		local pageFrame, before
		if S and not S.off then
			pageFrame = SubUI.PageFrame(oasisTab)
			if pageFrame then before = SubUI.Snapshot(pageFrame) end
		end
		local oasisSec = oasisTab:Section(d)
		if pageFrame and before then
			pcall(function()
				local roots = SubUI.NewRoots(pageFrame, before)
				if #roots == 0 then return end -- can't locate it: leave it always visible
				if not S.bar and not SubUI.BuildBar(S, pageFrame) then S.off = true; return end
				for _, r in ipairs(roots) do S.roots[cat][#S.roots[cat] + 1] = r end
				SubUI.Refresh(S)
			end)
		end
		local sec = makeSection(oasisSec, oasisTab, window)
		tab._current = sec
		tab._sections[#tab._sections + 1] = sec
		return sec
	end

	-- forward element calls to the current section (WindUI allows tab:Toggle(...) etc.)
	local function forward(name)
		return function(_, def)
			if not tab._current then tab:Section({ Title = nil }) end
			return tab._current[name](tab._current, def)
		end
	end
	tab.Toggle = forward("Toggle")
	tab.Slider = forward("Slider")
	tab.Button = forward("Button")
	tab.Dropdown = forward("Dropdown")
	tab.Colorpicker = forward("Colorpicker")
	tab.ColorPicker = tab.Colorpicker
	tab.Input = forward("Input")
	tab.Keybind = forward("Keybind")
	tab.Paragraph = forward("Paragraph")
	tab.Label = forward("Label")

	-- group this tab's sections into categories (sub-tabs)
	function tab:SubTabs(cats)
		local S = { cats = {}, lookup = {}, roots = {}, buttons = {}, count = {},
			selected = nil, last = nil, bar = nil, off = false, accent = SubUI.Accent() }
		for _, c in ipairs(cats) do
			S.cats[#S.cats + 1] = c[1]
			S.roots[c[1]] = {}
			for _, t in ipairs(c[2] or {}) do S.lookup[t] = c[1] end
		end
		tab._subs = S
		return tab
	end

	return tab
end

-- create the OasisUI window -------------------------------------------------
local oasisWindow = Library:CreateWindow({
	Title = "F$VL",
	Author = "Murder Mystery 2",
	Icon = "sword",
	Folder = "FVLV2_Oasis",
})

-- remember every ScreenGui the UI library created (dropdown lists may live in their own layer)
_FVL.libGuis = {}
pcall(function()
	for _, container in ipairs({ hui, CoreGui }) do
		for _, child in ipairs(container:GetChildren()) do
			if not __guiBefore[child] and child:IsA("LayerCollector") then
				_FVL.libGuis[#_FVL.libGuis + 1] = child
			end
		end
	end
end)

-- dummy UIElements.Main so cosmetic DOM-dive loops (func118/func120/tag sheen) no-op safely
local dummyMain = Instance.new("Frame")
dummyMain.Name = "FVLDummyMain"
dummyMain.Size = UDim2.fromOffset(0, 0)
dummyMain.BackgroundTransparency = 1
dummyMain.Parent = hui

local obj3 = {
	_oasis = oasisWindow,
	Destroyed = false,
	CurrentTab = 1,
	ConfigManager = ConfigManager,
	UIElements = { Main = dummyMain },
	_tabs = {},
	_onDestroy = {},
}

function obj3:Tab(def)
	local d = {
		Title = def.Title or "Tab",
		Icon = normIcon(def.Icon),
		Id = def.Id,
		Columns = def.Columns, -- 1 = one column across the whole tab (default: 2)
	}
	local oasisTab = oasisWindow:Tab(d)
	local tab = makeTab(oasisTab, oasisWindow)
	self._tabs[#self._tabs + 1] = tab
	return tab
end

function obj3:Tag() end -- cosmetic; ignored
function obj3:EditOpenButton() end -- cosmetic; ignored

local color = Color3.fromHex -- kept for compatibility (unused in the tail)

function obj3:SetBackgroundTransparency(v)
	pcall(function()
		local Theme = Library.Theme
		if Theme and Theme.Set then
			Theme.Set({ WindowTransparency = math.clamp(tonumber(v) or 0, 0, 0.9) })
		end
	end)
end
function obj3:SetBackgroundImageTransparency() end

function obj3:Toggle()
	pcall(function()
		local r = oasisWindow.Root
		if r then r.Visible = not r.Visible end
	end)
end

function obj3:Open()
	pcall(function()
		local r = oasisWindow.Root
		if r then r.Visible = true end
	end)
end

function obj3:SelectTab(i)
	local tab
	if type(i) == "number" then
		tab = self._tabs[i]
		self.CurrentTab = i
	elseif type(i) == "table" and i._oasis then
		tab = i
	end
	if tab then
		pcall(function() oasisWindow:SelectTab(tab._oasis) end)
	end
end

function obj3:OnDestroy(cb)
	self._onDestroy[#self._onDestroy + 1] = cb
end

function obj3:Destroy()
	if self.Destroyed then return end
	self.Destroyed = true
	for _, cb in ipairs(self._onDestroy) do pcall(cb) end
	pcall(function() oasisWindow:Destroy() end)
	pcall(function() dummyMain:Destroy() end)
end

-- obj2 = WindUI-style library handle (Notify + theme stubs) -----------------
local obj2 = { Themes = {} }

function obj2:AddTheme(def)
	self.Themes[def.Name or "Default"] = def
end
function obj2:SetTheme() end

function obj2:Notify(def)
	def = def or {}
	local icon = def.Icon and tostring(def.Icon) or ""
	local kind = "Info"
	if icon == "check" then kind = "Success"
	elseif icon == "x" then kind = "Error"
	elseif icon:find("warn") or icon:find("shield") then kind = "Warning"
	end
	pcall(function()
		Library:Notify({
			Title = def.Title or "Notification",
			Content = def.Content or "",
			Type = kind,
			Duration = def.Duration or 3,
		})
	end)
end



_G.FVLV2 = obj3
local list2

list2 = {
	farmTargetTime = 0,
	shellsOn = false,
	shellsRunning = false,
	flingAllRunning = false,
	hudScale = 1,
	flingWhenDone = false,
	flingDoneFired = false,
	sawCoins = false,
	lastMap = nil,
	killWhenFull = false,
	killFired = false,
	el = {},
	conns = {},
	revealed = {},
	clipWas = {},
	farmClipWas = {},
	config = nil,
	hudBtns = {},
	hudPos = {},
	cfgSnapshot = nil,
	cfgWiped = false,
	hudDir = "WindUI/FVLV2/hud",
	hudFile = "WindUI/FVLV2/hud/autosave.json",
}

pcall(function()
	if makefolder and isfolder and not isfolder(list2.hudDir) then
		makefolder(list2.hudDir)
	end
end)

list2.sfxId = {
	error = 131039887376992,
	gun = 131390520971848,
	click = 139800881181209,
	toggle = 136108770017536,
}

list2.sfxVol = { error = 0.55, gun = 0.75, click = 0.65, toggle = 0.6 }
list2.sfxOn = { error = true, gun = true, click = true, toggle = true }
list2.sfxReady = false
list2.sfxQuiet = false
list2.sfx = {}

list2.playSfx = function(name)
	if not list2.sfxOn[name] then
		return
	end
	local str4 = list2.sfxId[name]
	if not str4 then
		return
	end

	pcall(function()
		local SoundService = game:GetService("SoundService")
		local fvlSFX = SoundService:FindFirstChild("FVLSFX")

		if not fvlSFX then
			fvlSFX = Instance.new("Folder")
			fvlSFX.Name = "FVLSFX"
			fvlSFX.Parent = SoundService
		end

		local sound = list2.sfx[name]

		if not sound or not sound.Parent then
			sound = fvlSFX:FindFirstChild(name) or Instance.new("Sound")
			sound.Name = name
			sound.SoundId = "rbxassetid://" .. str4
			sound.Volume = list2.sfxVol[name] or 0.5
			sound.Parent = fvlSFX
			list2.sfx[name] = sound
		end

		sound.TimePosition = 0
		sound:Play()
	end)
end

local tab = obj3.Tab

obj3.Tab = function(self, param5)
	local value11 = tab(self, param5)

	if type(value11) == "table" and type(value11.Toggle) == "function" then
		local toggle = value11.Toggle

		value11.Toggle = function(param6, param7)
			if type(param7) == "table" then
				local callback = param7.Callback

				param7.Callback = function(...)
					if list2.sfxReady and not list2.sfxQuiet then
						list2.playSfx("toggle")
					end

					if callback then
						return callback(...)
					end
				end
			end

			return toggle(param6, param7)
		end
	end

	return value11
end

list2.notifyReady = false
list2.realNotify = obj2.Notify

obj2.Notify = function(self, param8)
	if not list2.notifyReady then
		return
	end

	if type(param8) == "table" and (param8.Icon == "x" or param8.Icon == "clock") then
		list2.playSfx("error")
	end

	return list2.realNotify(self, param8)
end

list2.notifyNow = function(param9)
	return list2.realNotify(obj2, param9)
end

task.delay(4, function()
	list2.notifyReady = true
end)

task.delay(20, function()
	list2.sfxReady = true
end)

task.spawn(function()
	local CoreGui_ = game:GetService("CoreGui")

	local function func7(child)
		if not (child and child:IsA("GuiObject")) then
			return
		end

		task.spawn(function()
			local imageLabel = nil

			for i = 1, 60 do
				imageLabel = child:FindFirstChildWhichIsA("ImageLabel")
				if not (imageLabel or not child.Parent) then
					task.wait()
					continue
				end
				break
			end

			if not imageLabel or imageLabel:FindFirstChild("FVLToastRamp") then
				return
			end
			local uiGradient = Instance.new("UIGradient")
			uiGradient.Name = "FVLToastRamp"
			uiGradient.Rotation = 45

			uiGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(118, 118, 130)),
			})

			uiGradient.Parent = imageLabel
		end)
	end

	local windUINotifications = nil

	for i = 1, 900 do
		windUINotifications = CoreGui_:FindFirstChild("WindUI/Notifications", true)
		if not windUINotifications then
			task.wait(0.2)
			continue
		end
		break
	end

	if not windUINotifications then
		return
	end
	local frame = nil

	for i = 1, 900 do
		frame = windUINotifications:FindFirstChildWhichIsA("Frame")
		if not frame then
			task.wait(0.2)
			continue
		end
		break
	end

	if not frame then
		return
	end

	for _, child in ipairs(frame:GetChildren()) do
		func7(child)
	end

	frame.ChildAdded:Connect(func7)
end)

list2.findOpenPill = function()
	local windUI = (gethui and gethui() or game:GetService("CoreGui")):FindFirstChild("WindUI")
	windUI = windUI and windUI:FindFirstChild("Window")
	if not windUI then
		return nil, nil
	end
	local value12 = nil
	local value13 = nil

	for _, child in ipairs(windUI:GetChildren()) do
		if child:IsA("Frame") then
			if child:FindFirstChild("Main") then
				value12 = child
			elseif child:FindFirstChildWhichIsA("TextButton", true) then
				value13 = child
			end
		end
	end

	return value13, value12
end

list2.pinOpenPill = function()
	task.spawn(function()
		local value14 = nil
		local value15 = nil

		for i = 1, 200 do
			value14, value15 = list2.findOpenPill()
			if not (value14 and value15) then
				task.wait(0.05)
				continue
			end
			break
		end

		if not (value14 and value15) then
			return
		end

		local function func8()
			local visible = not value15.Visible

			if value14.Visible ~= visible then
				value14.Visible = visible
			end
		end

		func8()
		list2.conns[#list2.conns + 1] = value15:GetPropertyChangedSignal("Visible"):Connect(func8)
		list2.conns[#list2.conns + 1] = value14:GetPropertyChangedSignal("Visible"):Connect(func8)
	end)
end

list2.mouseAimPoint = function()
	local currentCamera = Workspace.CurrentCamera
	if not currentCamera then
		return nil
	end

	local ok, result = pcall(function()
		local mouseLocation
		mouseLocation = UserInputService:GetMouseLocation()
		local num1 = currentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { LocalPlayer.Character }
		local hit = Workspace:Raycast(num1.Origin, num1.Direction * 300, raycastParams)
		return hit and hit.Position or num1.Origin + num1.Direction * 300
	end)

	return ok and result or nil
end

list2.xrayWas = {}
list2.xrayOn = false

list2.setXray = function(xrayOn)
	list2.xrayOn = xrayOn

	if xrayOn then
		for _, descendant in ipairs(Workspace:GetDescendants()) do
			if descendant:IsA("BasePart") and descendant.Transparency < 0.5 then
				local model = descendant:FindFirstAncestorWhichIsA("Model")

				if not (model and Players:GetPlayerFromCharacter(model)) then
					if list2.xrayWas[descendant] == nil then
						list2.xrayWas[descendant] = descendant.Transparency
					end

					descendant.Transparency = 0.5
				end
			end
		end
	else
		for k, value16 in next, list2.xrayWas, nil do
			pcall(function()
				if k.Parent then
					k.Transparency = value16
				end
			end)
		end

		list2.xrayWas = {}
	end
end

list2.dropConns = function(list3)
	if type(list3) ~= "table" then
		return
	end

	for _, item6 in ipairs(list3) do
		pcall(function()
			item6:Disconnect()
		end)
	end

	for i = #list3, 1, -1 do
		list3[i] = nil
	end
end

list2.unreveal = function()
	for k, value17 in next, list2.revealed, nil do
		pcall(function()
			if k.Parent then
				k.Transparency = value17
			end
		end)
	end

	list2.revealed = {}
end

list2.reclip = function(tbl6)
	for k in next, tbl6, nil do
		pcall(function()
			if k.Parent then
				k.CanCollide = true
			end
		end)
	end

	for k in next, tbl6, nil do
		tbl6[k] = nil
	end
end

list2.CLIPBOARD_FNS = {
	"setclipboard",
	"toclipboard",
	"tosetclipboard",
	"set_clipboard",
	"write_clipboard",
	"setClipboard",
}

list2.copyText = function(param10)
	local genv = getgenv and getgenv() or _G

	for _, clipboardFn in ipairs(list2.CLIPBOARD_FNS) do
		local value19 = rawget(genv, clipboardFn)
		local result

		if type(value19) ~= "function" then
			local ok

			ok, result = pcall(function()
				return getfenv(0)[clipboardFn]
			end)

			if not (ok and type(result) == "function") then
				result = value19
			end
		else
			result = value19
		end

		if type(result) == "function" and pcall(result, param10) then
			return true
		end
	end

	local func9 = ipairs
	local tbl7 = { syn, "write_clipboard" }
	local tbl8 = { syn, "set_clipboard" }
	local tbl9 = { rawget(genv, "Clipboard"), "set" }
	local tbl10 = { rawget(genv, "Clipboard"), "Set" }
	local tbl11 = { tbl7, tbl8, tbl9, tbl10 }

	for _, value20 in func9(tbl11) do
		local first1 = value20[1]
		local second1 = value20[2]

		if type(first1) == "table" and type(rawget(first1, second1)) == "function" then
			if pcall(first1[second1], param10) then
				return true
			end
		end
	end

	return false
end

task.spawn(function()
	local RunService_ = game:GetService("RunService")

	for i = 1, 300 do
		local main = obj3.UIElements and obj3.UIElements.Main

		if main then
			if not list2.bgAsset then
				local background = main:FindFirstChild("Background")
				local func10 = ipairs
				local children = background and background:GetChildren() or {}

				for _, child in func10(children) do
					if child:IsA("ImageLabel") and child.Size == UDim2.new(1, 0, 1, 0) and tostring(child.Image) ~= "" then
						list2.bgAsset = child.Image
					end
				end
			end

			if not list2.markIcon then
				local topbar = main:FindFirstChild("Topbar", true)
				local func11 = ipairs
				topbar = topbar and topbar:GetDescendants() or {}

				for _, value21 in func11(topbar) do
					if value21:IsA("ImageLabel") and value21.Size == UDim2.new(1, 0, 1, 0) and tostring(value21.Image):find("rbxassetid", 1, true) then
						list2.markIcon = value21:Clone()
						break
					end
				end
			end

			if list2.bgAsset and list2.markIcon then
				return
			end
		end

		RunService_.RenderStepped:Wait()
	end
end)

list2.card = function(flag15)
	local tbl14 = flag15 or {}

	local function func12()
	end

	pcall(function()
		local hui = gethui and gethui() or CoreGui
		local fvlCard = hui:FindFirstChild("FVLCard")

		if fvlCard then
			fvlCard:Destroy()
		end

		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "FVLCard"
		screenGui.IgnoreGuiInset = true
		screenGui.ResetOnSpawn = false
		screenGui.DisplayOrder = 99999
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		screenGui.Parent = hui
		local TweenService_ = game:GetService("TweenService")
		local color2 = Color3.fromRGB(34, 197, 94)
		local color3 = Color3.fromRGB(158, 158, 174)
		local color4 = Color3.fromRGB(168, 168, 184)
		local color5 = Color3.fromRGB(29, 29, 37)
		local color6 = Color3.fromRGB(233, 233, 242)
		local color7 = Color3.fromRGB(232, 232, 240)
		local color8 = Color3.fromRGB(22, 22, 28)
		local color9 = Color3.fromRGB(236, 236, 244)
		local actions = tbl14.actions
		local flag16 = type(actions) == "table" and #actions > 0
		local n = flag16 and 194 or 144
		local textButton = Instance.new("TextButton")
		textButton.Size = UDim2.fromScale(1, 1)
		textButton.BackgroundColor3 = Color3.new(0, 0, 0)
		textButton.BackgroundTransparency = 1
		textButton.BorderSizePixel = 0
		textButton.AutoButtonColor = false
		textButton.Text = ""
		textButton.Parent = screenGui
		local frame = Instance.new("Frame")
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.fromScale(0.5, 0.5)
		frame.Size = UDim2.fromOffset(math.min(440, math.max(300, (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X or 800) - 40)), n)
		frame.BackgroundColor3 = Color3.fromRGB(23, 23, 28)
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.ClipsDescendants = true
		frame.Parent = screenGui
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 22)
		local uiScale = Instance.new("UIScale", frame)
		uiScale.Scale = 0.96
		local uiGradient = Instance.new("UIGradient", frame)
		uiGradient.Rotation = 90
		local new = ColorSequenceKeypoint.new
		local color10 = Color3.fromRGB
		uiGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 36)), new(1, color10(16, 16, 20)) })
		local uiStroke = Instance.new("UIStroke", frame)
		uiStroke.Color = color2
		uiStroke.Thickness = 1
		uiStroke.Transparency = 1
		local bgAsset2 = list2.bgAsset and list2.bgAsset ~= ""
		local imageLabel = nil

		if bgAsset2 then
			imageLabel = Instance.new("ImageLabel")
			imageLabel.Size = UDim2.fromScale(1, 1)
			imageLabel.BackgroundTransparency = 1
			imageLabel.Image = list2.bgAsset
			imageLabel.ScaleType = Enum.ScaleType.Crop
			imageLabel.ImageTransparency = 1
			imageLabel.ZIndex = 0
			imageLabel.Parent = frame
			Instance.new("UICorner", imageLabel).CornerRadius = UDim.new(0, 22)
		end

		local frame2 = Instance.new("Frame")
		frame2.Position = UDim2.fromOffset(22, 20)
		frame2.Size = UDim2.fromOffset(48, 48)
		frame2.BackgroundColor3 = Color3.fromRGB(38, 38, 48)
		frame2.BackgroundTransparency = 1
		frame2.BorderSizePixel = 0
		frame2.ZIndex = 1
		frame2.Parent = frame
		Instance.new("UICorner", frame2).CornerRadius = UDim.new(1, 0)
		local uiStroke2 = Instance.new("UIStroke", frame2)
		uiStroke2.Color = color2
		uiStroke2.Thickness = 1
		uiStroke2.Transparency = 1
		local clone

		if list2.markIcon then
			clone = list2.markIcon:Clone()
		else
			clone = Instance.new("ImageLabel")
			clone.Image = "rbxassetid://103877612231883"
		end

		clone.Name = "Mark"
		clone.AnchorPoint = Vector2.new(0.5, 0.5)
		clone.Position = UDim2.fromScale(0.5, 0.5)
		clone.Size = UDim2.fromOffset(26, 26)
		clone.BackgroundTransparency = 1
		clone.ImageColor3 = color6
		clone.ImageTransparency = 1
		clone.Visible = true
		clone.Parent = frame2
		local textLabel = Instance.new("TextLabel")
		textLabel.Position = UDim2.fromOffset(86, 22)
		textLabel.Size = UDim2.new(1, -108, 0, 26)
		textLabel.BackgroundTransparency = 1
		textLabel.Font = Enum.Font.GothamBold
		textLabel.TextSize = 22
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		textLabel.TextTransparency = 1
		textLabel.Text = tostring(tbl14.title or "F$VL")
		textLabel.ZIndex = 1
		textLabel.Parent = frame
		local uiGradient2 = Instance.new("UIGradient", textLabel)
		uiGradient2.Rotation = 10
		local colorSequence = ColorSequence.new
		local value22 = ColorSequenceKeypoint.new(0, Color3.fromRGB(74, 222, 128))
		local value23 = ColorSequenceKeypoint.new(0.42, Color3.fromRGB(255, 255, 255))
		local value24 = ColorSequenceKeypoint.new(0.58, Color3.fromRGB(255, 255, 255))
		local new2 = ColorSequenceKeypoint.new
		local color11 = Color3.fromRGB
		local tbl15 = { value22, value23, value24 }

		do
			local values = table.pack(new2(1, color11(74, 222, 128)))
			table.move(values, 1, values.n, 4, tbl15)
		end

		uiGradient2.Color = colorSequence(tbl15)
		local textLabel2 = Instance.new("TextLabel")
		textLabel2.Position = UDim2.fromOffset(86, 50)
		textLabel2.Size = UDim2.new(1, -108, 0, 18)
		textLabel2.BackgroundTransparency = 1
		textLabel2.Font = Enum.Font.Gotham
		textLabel2.TextSize = 14
		textLabel2.TextXAlignment = Enum.TextXAlignment.Left
		textLabel2.TextColor3 = color3
		textLabel2.TextTransparency = 1
		textLabel2.Text = tostring(tbl14.subtitle or "")
		textLabel2.ZIndex = 1
		textLabel2.Parent = frame
		local textLabel3 = Instance.new("TextLabel")
		textLabel3.Position = UDim2.fromOffset(22, 82)
		textLabel3.Size = UDim2.new(1, -44, 0, 42)
		textLabel3.BackgroundTransparency = 1
		textLabel3.Font = Enum.Font.Gotham
		textLabel3.TextSize = 15
		textLabel3.LineHeight = 1.25
		textLabel3.TextWrapped = true
		textLabel3.TextXAlignment = Enum.TextXAlignment.Left
		textLabel3.TextYAlignment = Enum.TextYAlignment.Top
		textLabel3.TextColor3 = color4
		textLabel3.TextTransparency = 1
		textLabel3.Text = tostring(tbl14.body or "")
		textLabel3.ZIndex = 1
		textLabel3.Parent = frame

		func12 = function()
			pcall(function()
				screenGui:Destroy()
			end)
		end

		local function func13(param11, callback1)
			local n2 = 0

			local function func14()
				local now = os.clock()
				if now - n2 < 0.25 then
					return
				end
				n2 = now
				callback1()
			end

			param11.MouseButton1Click:Connect(func14)
			param11.TouchTap:Connect(func14)
		end

		local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad)



		func13(textButton, func12)
		local tbl16 = {}

		if flag16 then
			local frame4 = Instance.new("Frame")
			frame4.AnchorPoint = Vector2.new(1, 0)
			frame4.Position = UDim2.new(1, -22, 0, 136)
			frame4.Size = UDim2.new(1, -44, 0, 38)
			frame4.BackgroundTransparency = 1
			frame4.ZIndex = 1
			frame4.Parent = frame
			local uiListLayout = Instance.new("UIListLayout", frame4)
			uiListLayout.FillDirection = Enum.FillDirection.Horizontal
			uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
			uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			uiListLayout.Padding = UDim.new(0, 10)
			uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			local n2 = #actions
			local offset = uiListLayout.Padding.Offset
			local n3 = 0

			for _, action in ipairs(actions) do
				n3 += action.flex or 1
			end

			for i, action in ipairs(actions) do
				local tint = action.tint or action.primary and color7 or Color3.fromRGB(34, 34, 42)
				local primary = action.primary and color8 or color9
				local textButton3 = Instance.new("TextButton")
				textButton3.LayoutOrder = i
				local n4 = (action.flex or 1) / n3
				textButton3.Size = action.width and UDim2.fromOffset(action.width, 36) or UDim2.new(n4, -offset * (n2 - 1) * n4, 0, 36)
				textButton3.BackgroundColor3 = tint
				textButton3.BackgroundTransparency = 1
				textButton3.BorderSizePixel = 0
				textButton3.AutoButtonColor = false
				textButton3.Font = Enum.Font.GothamMedium
				textButton3.TextSize = 15
				textButton3.TextColor3 = primary
				textButton3.TextTransparency = 1
				textButton3.Text = tostring(action.label or "")
				textButton3.Parent = frame4
				Instance.new("UICorner", textButton3).CornerRadius = UDim.new(0, 11)

				if not action.primary and not action.tint then
					local uiStroke4 = Instance.new("UIStroke", textButton3)
					uiStroke4.Color = color2
					uiStroke4.Thickness = 1
					uiStroke4.Transparency = 1
					table.insert(tbl16, { obj = uiStroke4, prop = "Transparency", to = 0.5 })
				end

				table.insert(tbl16, { obj = textButton3, prop = "BackgroundTransparency", to = 0 })
				table.insert(tbl16, { obj = textButton3, prop = "TextTransparency", to = 0 })
				local uiScale3 = Instance.new("UIScale", textButton3)

				textButton3.MouseButton1Down:Connect(function()
					TweenService_:Create(uiScale3, TweenInfo.new(0.07), { Scale = 0.96 }):Play()
				end)

				textButton3.MouseButton1Up:Connect(function()
					TweenService_:Create(uiScale3, TweenInfo.new(0.12), { Scale = 1 }):Play()
				end)

				local callback = action.callback

				func13(textButton3, function()
					TweenService_:Create(uiScale3, TweenInfo.new(0.12), { Scale = 1 }):Play()

					if action.closes ~= false then
						func12()
					end

					if callback then
						task.spawn(callback)
					end
				end)
			end
		end

		local tweenInfo2 = TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tweenInfo3 = TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		frame.Position = UDim2.fromScale(0.5, 0.52)
		TweenService_:Create(frame, tweenInfo3, { Position = UDim2.fromScale(0.5, 0.5) }):Play()
		TweenService_:Create(uiScale, tweenInfo3, { Scale = 1 }):Play()
		TweenService_:Create(textButton, tweenInfo2, { BackgroundTransparency = 0.5 }):Play()
		TweenService_:Create(frame, tweenInfo2, { BackgroundTransparency = 0 }):Play()
		TweenService_:Create(uiStroke, tweenInfo2, { Transparency = 0.42 }):Play()
		TweenService_:Create(frame2, tweenInfo2, { BackgroundTransparency = 0 }):Play()
		TweenService_:Create(uiStroke2, tweenInfo2, { Transparency = 0.42 }):Play()
		TweenService_:Create(clone, tweenInfo2, { ImageTransparency = 0 }):Play()
		TweenService_:Create(textLabel, tweenInfo2, { TextTransparency = 0 }):Play()
		TweenService_:Create(textLabel2, tweenInfo2, { TextTransparency = 0 }):Play()
		TweenService_:Create(textLabel3, tweenInfo2, { TextTransparency = 0 }):Play()

		if imageLabel then
			TweenService_:Create(imageLabel, tweenInfo2, { ImageTransparency = 0.84 }):Play()
		end

		for _, item7 in ipairs(tbl16) do
			TweenService_:Create(item7.obj, tweenInfo2, { [item7.prop] = item7.to }):Play()
		end

		local timeout = tbl14.timeout or 25

		if timeout > 0 then
			task.delay(timeout, function()
				func12()
			end)
		end
	end)

	return func12
end

list2.farewell = function()
	if _G.__FVLReloading then
		return
	end

	if list2.saidBye then
		return
	end
	list2.saidBye = true

	list2.card({
		title = "Bye bye!",
		subtitle = "Thanks for running F$VL",
		body = "See you next time.",
	})
end

list2.inLobbyNow = function()
	local localPlayer = game:GetService("Players").LocalPlayer
	localPlayer = localPlayer and localPlayer:FindFirstChild("PlayerGui")
	localPlayer = localPlayer and localPlayer:FindFirstChild("MainGUI")
	localPlayer = localPlayer and localPlayer:FindFirstChild("Game")
	if not localPlayer then
		return true
	end
	return localPlayer:FindFirstChild("Inventory") == nil
end

list2.coinFails = {}
list2.coinSkips = {}

-- Farm mode: "Coins" (normal rounds) or "Candy" (Halloween event, candies replace the coins on the map).
-- Candies work exactly like coins; the only difference is the bag: candy bags hold 50.
list2.farmMode = "Coins"

list2.bagLimit = function()
	if list2.farmMode == "Candy" then
		return 50
	end

	-- (localPlayer is declared further down the file, so look it up here)
	local me = game:GetService("Players").LocalPlayer

	return me and me:GetAttribute("Elite") and 50 or 40
end

list2.coinSkip = function(param12)
	local flag17 = list2.coinSkips[param12]
	if not flag17 then
		return false
	end

	if flag17 < tick() then
		list2.coinSkips[param12] = nil
		list2.coinFails[param12] = nil
		return false
	end

	return true
end

list2.coinFailed = function(param13)
	local n = (list2.coinFails[param13] or 0) + 1
	list2.coinFails[param13] = n

	if n >= 2 then
		list2.coinSkips[param13] = tick() + 20
	end
end

list2.coinReset = function()
	local value25 = list2
	list2.coinFails = {}
	value25.coinSkips = {}
end

pcall(function()
	if not (isfile and delfile) then
		return
	end

	if isfile("WindUI/FVLV2/config/fvl_hud.json") then
		if writefile and not isfile(list2.hudFile) then
			writefile(list2.hudFile, readfile("WindUI/FVLV2/config/fvl_hud.json"))
		end

		delfile("WindUI/FVLV2/config/fvl_hud.json")
	end

	if listfiles then
		for _, listfile in ipairs(listfiles("WindUI/FVLV2/config")) do
			local match = tostring(listfile):match("[^/\\]+$") or ""

			if match:match("^fvl_hud") then
				local match2 = match:match("^fvl_hud_(.+)%.json$")

				if match2 and writefile then
					pcall(function()
						writefile(list2.hudDir .. "/" .. match2 .. ".json", readfile(listfile))
					end)
				end

				pcall(function()
					delfile(listfile)
				end)
			end
		end
	end
end)

pcall(function()
	if isfile and isfile(list2.hudFile) then
		local data = game:GetService("HttpService"):JSONDecode(readfile(list2.hudFile))

		if type(data) == "table" then
			list2.hudPos = data
		end
	end
end)

list2.hudStart = function(name, default)
	local t = list2.hudPos[name]
	if type(t) == "table" and #t == 4 then
		return UDim2.new(t[1], t[2], t[3], t[4])
	end
	return default
end

pcall(function()
	list2.config = obj3.ConfigManager:CreateConfig("autosave")

	if list2.config and list2.config.SetAsCurrent then
		list2.config:SetAsCurrent()
	end
end)

Players = game:GetService("Players")
RunService = game:GetService("RunService")
Workspace = game:GetService("Workspace")
ReplicatedStorage = game:GetService("ReplicatedStorage")
CoreGui = game:GetService("CoreGui")
HttpService = game:GetService("HttpService")
CollectionService = game:GetService("CollectionService")
local localPlayer, flag18, flag19, flag20, flag21, flag22, obj4, func15, func16, func17
local func18, func19, func20, func21, func22

do
	local function func23(param14)
		pcall(function()
			CollectionService:AddTag(param14, "WeaponPassthrough")
		end)
	end

	localPlayer = Players.LocalPlayer

	espColors = {
		murderer = Color3.fromRGB(255, 0, 4),
		sheriff = Color3.fromRGB(0, 153, 255),
		zombie = Color3.fromRGB(255, 115, 0), -- new mode: Zombie (works like the murderer)
		survivor = Color3.fromRGB(255, 221, 0), -- new mode: Survivor (works like the sheriff)
		innocent = Color3.fromRGB(0, 255, 8),
		gun = Color3.fromRGB(0, 153, 255),
		trap = Color3.fromHex("#A855F7"),
	}

	flag18 = false
	flag19 = false
	flag20 = false
	flag21 = false
	flag22 = false
	local value26 = nil
	local index = {}
	index.__index = index

	index.new = function()
		local obj = setmetatable({}, index)
		obj.ScreenGui = Instance.new("ScreenGui")
		obj.ScreenGui.Name = "FVLESP"
		obj.ScreenGui.IgnoreGuiInset = true
		obj.ScreenGui.ResetOnSpawn = false
		obj.ScreenGui.Parent = CoreGui
		obj.Groups = {}
		return obj
	end

	index.Add = function(self, adornee, param15)
		if not adornee then
			return
		end
		local highlight = Instance.new("Highlight")
		highlight.Name = "HL_" .. HttpService:GenerateGUID(false)
		highlight.Adornee = adornee
		highlight.FillColor = param15.Color
		highlight.OutlineColor = param15.Color
		highlight.FillTransparency = param15.FillTransparency
		highlight.OutlineTransparency = param15.OutlineTransparency
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Parent = self.ScreenGui
		local flag23 = self.Groups[param15.GroupName]

		if not flag23 then
			flag23 = {}
			self.Groups[param15.GroupName] = flag23
		end

		table.insert(flag23, highlight)

		if param15.Label then
			local billboardGui = Instance.new("BillboardGui")
			billboardGui.Name = "LBL_" .. HttpService:GenerateGUID(false)
			billboardGui.Adornee = param15.LabelAdornee or adornee
			billboardGui.AlwaysOnTop = true
			billboardGui.Size = UDim2.new(0, 140, 0, 16)
			billboardGui.StudsOffset = Vector3.new(0, param15.LabelAdornee and 2.2 or 2, 0)

			if param15.LabelMaxDistance then
				billboardGui.MaxDistance = param15.LabelMaxDistance
			end

			billboardGui.Parent = self.ScreenGui
			local textLabel = Instance.new("TextLabel")
			textLabel.Size = UDim2.new(1, 0, 1, 0)
			textLabel.BackgroundTransparency = 1
			textLabel.Font = Enum.Font.FredokaOne
			textLabel.TextSize = 11
			textLabel.TextColor3 = param15.Color
			textLabel.Text = param15.Label
			textLabel.Parent = billboardGui
			local uiStroke = Instance.new("UIStroke")
			uiStroke.Thickness = 0.5
			uiStroke.Color = Color3.new(0, 0, 0)
			uiStroke.Parent = textLabel
			table.insert(flag23, billboardGui)
		end
	end

	index.RemoveGroup = function(self, param16)
		local flag24 = self.Groups[param16]
		if not flag24 then
			return
		end

		for _, item8 in ipairs(flag24) do
			item8.Adornee = nil
			item8:Destroy()
		end

		self.Groups[param16] = nil
	end

	index.Destroy = function(self)
		for k in pairs(self.Groups) do
			self:RemoveGroup(k)
		end

		if self.ScreenGui then
			self.ScreenGui:Destroy()
		end
	end

	obj4 = index.new()

	list2.legacyFindMurderer = function()
		for _, player in ipairs(Players:GetPlayers()) do
			local backpack = player:FindFirstChildOfClass("Backpack")
			if backpack and backpack:FindFirstChild("Knife") then
				return player
			end
		end

		for _, player in ipairs(Players:GetPlayers()) do
			if player.Character and player.Character:FindFirstChild("Knife") then
				return player
			end
		end

		if value26 then
			for k, value27 in pairs(value26) do
				if value27.Role == "Murderer" and Players:FindFirstChild(k) then
					return Players:FindFirstChild(k)
				end
			end
		end

		return nil
	end

	list2.legacyFindSheriff = function()
		for _, player in ipairs(Players:GetPlayers()) do
			local backpack = player:FindFirstChildOfClass("Backpack")
			if backpack and backpack:FindFirstChild("Gun") then
				return player
			end
		end

		for _, player in ipairs(Players:GetPlayers()) do
			if player.Character and player.Character:FindFirstChild("Gun") then
				return player
			end
		end

		if value26 then
			for k, value28 in pairs(value26) do
				if (value28.Role == "Sheriff" or value28.Role == "Hero") and Players:FindFirstChild(k) then
					return Players:FindFirstChild(k)
				end
			end
		end

		return nil
	end

	-- ===== func15 / func16: "who is the murderer / sheriff?" =====
	-- Used all over the script. They now ask the shared role API (list2.getMurderer / list2.getSheriff, defined next
	-- to list2.getPlayerRole) so ESP, fling, teleport, aimbot, auto fling, ... can never disagree about who holds
	-- which role. The old standalone lookup is only a fallback for the first moments before the API exists.
	func15 = function()
		if list2.getMurderer then
			local ok, result = pcall(list2.getMurderer)

			if ok then
				return result
			end
		end

		return list2.legacyFindMurderer()
	end

	func16 = function()
		if list2.getSheriff then
			local ok, result = pcall(list2.getSheriff)

			if ok then
				return result
			end
		end

		return list2.legacyFindSheriff()
	end

	-- ===== ESP role resolver: ONE place decides how a player is shown (chams, boxes, tracers, dots, ...) =====
	-- espRole(player) returns  class, realRole
	--   class:    "Murderer" / "Sheriff" / "Zombie" / "Survivor" / "Innocent"
	--   realRole: the role underneath ("Murderer", "Sheriff", "Innocent", ...)
	list2.espCache = setmetatable({}, { __mode = "k" })

	list2.espRole = function(player)
		local now = os.clock()
		local cached = list2.espCache[player]

		if cached and now - cached.t < 0.15 then
			return cached.cls, cached.real
		end

		local real = nil
		local okRole, roleValue = pcall(list2.getPlayerRole, player)

		if okRole then
			real = roleValue
		end

		real = real or "Innocent"

		local cls = real

		if cls ~= "Murderer" and cls ~= "Sheriff" and cls ~= "Zombie" and cls ~= "Survivor" then
			cls = "Innocent"
		end

		list2.espCache[player] = { t = now, cls = cls, real = real }

		return cls, real
	end

	list2.espColorOfClass = function(cls)
		if cls == "Murderer" then
			return espColors.murderer
		elseif cls == "Sheriff" then
			return espColors.sheriff
		elseif cls == "Zombie" then
			return espColors.zombie
		elseif cls == "Survivor" then
			return espColors.survivor
		end

		return espColors.innocent
	end

	list2.espColor = function(player)
		return list2.espColorOfClass((list2.espRole(player)))
	end

	local function func24(list4)
		for _, descendant in ipairs(list4:GetDescendants()) do
			if descendant:IsA("BasePart") and descendant.Name ~= "HumanoidRootPart" and descendant.Transparency >= 1 then
				func23(descendant)

				if list2.revealed[descendant] == nil then
					list2.revealed[descendant] = descendant.Transparency
				end

				descendant.Transparency = 0.9
			end
		end
	end

	ROLEBOX = { conns = {} }

	ROLEBOX.hide = function(obj)
		if not obj:IsA("BoxHandleAdornment") then
			return
		end
		obj.Visible = false

		table.insert(ROLEBOX.conns, obj:GetPropertyChangedSignal("Visible"):Connect(function()
			if obj.Visible then
				obj.Visible = false
			end
		end))
	end

	ROLEBOX.watch = function(obj)
		for _, descendant in ipairs(obj:GetDescendants()) do
			ROLEBOX.hide(descendant)
		end

		table.insert(ROLEBOX.conns, obj.DescendantAdded:Connect(ROLEBOX.hide))
	end

	ROLEBOX.start = function()
		for _, player in ipairs(Players:GetPlayers()) do
			if player.Character then
				ROLEBOX.watch(player.Character)
			end

			table.insert(ROLEBOX.conns, player.CharacterAdded:Connect(ROLEBOX.watch))
		end

		table.insert(ROLEBOX.conns, Players.PlayerAdded:Connect(function(player)
			table.insert(ROLEBOX.conns, player.CharacterAdded:Connect(ROLEBOX.watch))
		end))
	end

	ROLEBOX.stop = function()
		for _, conn in ipairs(ROLEBOX.conns) do
			pcall(function()
				conn:Disconnect()
			end)
		end

		ROLEBOX.conns = {}

		for _, player in ipairs(Players:GetPlayers()) do
			if player.Character then
				for _, descendant in ipairs(player.Character:GetDescendants()) do
					if descendant:IsA("BoxHandleAdornment") then
						descendant.Visible = true
					end
				end
			end
		end
	end

	ROLEBOX.start()

	func17 = function()
		return flag18 or flag19 or flag20
	end

	func18 = function()
		obj4:RemoveGroup("players")
		if not func17() then
			return
		end
		local n = 1

		if flag19 then
			n = 0.75
		end

		local n2 = 1

		if flag18 then
			n2 = 0.1
		end

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= localPlayer and player.Character then
				func24(player.Character)
				local innocent = list2.espColor(player) -- Murderer / Sheriff / Innocent

				obj4:Add(player.Character, {
					Color = innocent,
					GroupName = "players",
					FillTransparency = n,
					OutlineTransparency = n2,
					Label = flag20 and player.DisplayName or nil,
					LabelAdornee = player.Character:FindFirstChild("Head"),
					LabelMaxDistance = 300,
				})
			end
		end
	end

	local function func25(param17)
		obj4:Add(param17, {
			Color = espColors.gun,
			GroupName = "gun",
			Label = "Gun",
			FillTransparency = 0.5,
			OutlineTransparency = 0,
		})
	end

	local function func26(param18)
		func23(param18)

		pcall(function()
			param18.Transparency = 0
		end)

		obj4:Add(param18, {
			Color = espColors.trap,
			GroupName = "trap",
			Label = "Trap",
			FillTransparency = 0.5,
			OutlineTransparency = 0,
		})
	end

	func19 = function()
		obj4:RemoveGroup("gun")
		if not flag21 then
			return
		end

		for _, descendant in ipairs(Workspace:GetDescendants()) do
			if descendant.Name == "GunDrop" and (descendant:IsA("BasePart") or descendant:IsA("Model")) then
				func25(descendant)
			end
		end
	end

	func20 = function()
		obj4:RemoveGroup("trap")
		if not flag22 then
			return
		end

		for _, descendant in ipairs(Workspace:GetDescendants()) do
			if descendant.Name == "Trap" and descendant.Parent and (descendant.Parent:IsA("Folder") or descendant.Parent:IsA("Model")) then
				func26(descendant)
			end
		end
	end

	local n = 0

	list2.espRecolourSoon = function()
		if not func17() then
			return
		end
		pcall(func18)

		for _, item9 in ipairs({ 0.1, 0.3, 0.6 }) do
			task.delay(item9, function()
				if func17() then
					pcall(func18)
				end
			end)
		end
	end

	-- somebody died -> refresh the colours right away instead of waiting for the next 1 s refresh
	list2.hookEspDeath = function(player)
		local function onChar(char)
			local hum = char:WaitForChild("Humanoid", 5)

			if hum then
				hum.Died:Connect(function()
					list2.espCache[player] = nil
					list2.espRecolourSoon()
				end)
			end
		end

		if player.Character then
			task.spawn(onChar, player.Character)
		end

		list2.conns[#list2.conns + 1] = player.CharacterAdded:Connect(onChar)
	end

	for _, pl in ipairs(Players:GetPlayers()) do
		list2.hookEspDeath(pl)
	end

	list2.conns[#list2.conns + 1] = Players.PlayerAdded:Connect(list2.hookEspDeath)

	pcall(function()
		list2.conns[#list2.conns + 1] = Workspace.DescendantAdded:Connect(function(descendant)
			if flag22 and descendant.Name == "Trap" and descendant.Parent and (descendant.Parent:IsA("Folder") or descendant.Parent:IsA("Model")) then
				func26(descendant)
			end

			-- Gun = new sheriff / survivor, Knife = a player just got infected and became a zombie
			if (descendant.Name == "Gun" or descendant.Name == "Knife") and descendant:IsA("Tool") then
				if descendant.Parent and Players:GetPlayerFromCharacter(descendant.Parent) then
					list2.espRecolourSoon()
				end
			end

			if descendant.Name == "GunDrop" and (descendant:IsA("BasePart") or descendant:IsA("Model")) then
				if flag21 then
					func25(descendant)
				end

				if tick() - n > 3 then
					n = tick()
					list2.playSfx("gun")

					obj2:Notify({
						Title = "Gun Dropped!",
						Content = "The sheriff died — the gun is on the floor.",
						Duration = 5,
						Icon = "crosshair",
					})
				end
			end
		end)

		list2.conns[#list2.conns + 1] = Workspace.DescendantRemoving:Connect(function(descendant)
			if flag21 and descendant.Name == "GunDrop" then
				task.defer(func19)
			end

			if flag22 and descendant.Name == "Trap" then
				task.defer(func20)
			end

			if descendant.Name == "GunDrop" then
				task.defer(list2.espRecolourSoon)
			end
		end)
	end)

	local flag25 = false

	func21 = function()
		if flag25 then
			return
		end
		flag25 = true

		task.spawn(function()
			-- FAST role watcher: every 0.2 s check whether anybody's ESP class changed (e.g. a survivor just got infected
			-- and became a Zombie) and redraw right away. The full redraw still happens every 1 s as before.
			-- (Before, a role change that came without a PlayerDataChanged event / equipped knife could wait up to 1 s.)
			local lastCls = setmetatable({}, { __mode = "k" })
			local ticks = 0

			while flag25 do
				task.wait(0.2)
				ticks += 1

				if func17() then
					local changed = false

					if ticks % 3 == 0 and list2.pollPlayerData then
						list2.pollPlayerData()
					end

					for _, player in ipairs(Players:GetPlayers()) do
						if player ~= localPlayer then
							local okCls, cls = pcall(list2.espRole, player)

							if okCls and lastCls[player] ~= cls then
								lastCls[player] = cls
								changed = true
							end
						end
					end

					if changed or ticks % 5 == 0 then
						pcall(func18)
					end
				end
			end
		end)
	end

	func22 = function()
		flag25 = false
	end

	list2.tr = {
		lines = false,
		dist = false,
		arrows = false,
		parts = {},
		murd = nil,
		sher = nil,
		roleAt = 0,
		conn = nil,
	}

	list2.tr.any = function()
		return list2.tr.lines or list2.tr.dist or list2.tr.arrows
	end

	list2.tr.colorOf = function(flag26)
		return list2.espColor(flag26) -- Murderer / Sheriff / Innocent
	end

	list2.tr.slot = function(param19)
		local flag27 = list2.tr.parts[param19]
		if flag27 and flag27.line and flag27.line.Parent then
			return flag27
		end
		local screenGui = obj4 and obj4.ScreenGui
		if not screenGui or not screenGui.Parent then
			return nil
		end
		local tbl17 = { line = Instance.new("Frame") }
		tbl17.line.Name = "FVLTracer"
		tbl17.line.AnchorPoint = Vector2.new(0.5, 0.5)
		tbl17.line.BorderSizePixel = 0
		tbl17.line.Visible = false
		tbl17.line.ZIndex = 2
		tbl17.line.Parent = screenGui
		tbl17.lbl = Instance.new("TextLabel")
		tbl17.lbl.Name = "FVLDist"
		tbl17.lbl.AnchorPoint = Vector2.new(0.5, 0)
		tbl17.lbl.BackgroundTransparency = 1
		tbl17.lbl.Size = UDim2.fromOffset(90, 14)
		tbl17.lbl.Font = Enum.Font.FredokaOne
		tbl17.lbl.TextSize = 11
		tbl17.lbl.Visible = false
		tbl17.lbl.ZIndex = 3
		tbl17.lbl.Parent = screenGui
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Thickness = 0.5
		uiStroke.Color = Color3.new(0, 0, 0)
		uiStroke.Parent = tbl17.lbl
		tbl17.arw = Instance.new("TextLabel")
		tbl17.arw.Name = "FVLArrow"
		tbl17.arw.AnchorPoint = Vector2.new(0.5, 0.5)
		tbl17.arw.BackgroundTransparency = 1
		tbl17.arw.Size = UDim2.fromOffset(28, 28)
		tbl17.arw.Font = Enum.Font.SourceSansBold
		tbl17.arw.TextSize = 24
		tbl17.arw.Text = utf8.char(9650)
		tbl17.arw.Visible = false
		tbl17.arw.ZIndex = 3
		tbl17.arw.Parent = screenGui
		local uiStroke2 = Instance.new("UIStroke")
		uiStroke2.Thickness = 1
		uiStroke2.Color = Color3.new(0, 0, 0)
		uiStroke2.Parent = tbl17.arw
		list2.tr.parts[param19] = tbl17
		return tbl17
	end

	list2.tr.drop = function(param20)
		local flag28 = list2.tr.parts[param20]
		if not flag28 then
			return
		end
		list2.tr.parts[param20] = nil

		for _, value29 in pairs(flag28) do
			pcall(function()
				value29:Destroy()
			end)
		end
	end

	list2.tr.step = function()
		local currentCamera = Workspace.CurrentCamera
		if not currentCamera then
			return
		end
		local viewportSize = currentCamera.ViewportSize
		if viewportSize.X < 1 or viewportSize.Y < 1 then
			return
		end
		local now = os.clock()

		if now - list2.tr.roleAt > 0.5 then
			list2.tr.roleAt = now
			list2.tr.murd = func15()
			list2.tr.sher = func16()

			for k in pairs(list2.tr.parts) do
				if k.Parent == nil then
					list2.tr.drop(k)
				end
			end
		end

		local character = localPlayer.Character
		character = character and character:FindFirstChild("HumanoidRootPart")
		local n2 = viewportSize.X * 0.5
		local y = viewportSize.Y
		local n3 = viewportSize.X * 0.5
		local n4 = viewportSize.Y * 0.5
		local n5 = math.min(viewportSize.X, viewportSize.Y) * 0.33
		local flag29 = list2.tr.any()

		for _, player in ipairs(Players:GetPlayers()) do
			local flag30 = list2.tr.parts[player]
			local character2 = player ~= localPlayer and player.Character or nil
			local humanoidRootPart = character2 and character2:FindFirstChild("HumanoidRootPart")
			character2 = character2 and character2:FindFirstChildOfClass("Humanoid")

			if flag29 and humanoidRootPart and character2 then
				flag30 = flag30 or list2.tr.slot(player)
			elseif flag30 then
				local lbl = flag30.lbl
				local arw = flag30.arw
				flag30.line.Visible = false
				lbl.Visible = false
				arw.Visible = false
				flag30 = nil
			end

			if flag30 then
				local value30 = list2.tr.colorOf(player)
				local value31, flag31 = currentCamera:WorldToViewportPoint(humanoidRootPart.Position)
				local flag32 = value31.Z <= 0
				flag31 = flag31 and not flag32

				if list2.tr.lines and flag31 then
					local n6 = value31.X - n2
					local n7 = value31.Y - y
					flag30.line.BackgroundColor3 = value30
					flag30.line.Size = UDim2.fromOffset(2, math.sqrt(n6 * n6 + n7 * n7))
					flag30.line.Position = UDim2.fromOffset(n2 + n6 * 0.5, y + n7 * 0.5)
					flag30.line.Rotation = math.deg(math.atan2(n7, n6)) - 90
					flag30.line.Visible = true
				else
					flag30.line.Visible = false
				end

				if list2.tr.dist and flag31 then
					local magnitude = character and (humanoidRootPart.Position - character.Position).Magnitude or (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude
					local value32 = currentCamera:WorldToViewportPoint(humanoidRootPart.Position - Vector3.new(0, 3.2, 0))
					flag30.lbl.TextColor3 = value30
					flag30.lbl.Text = math.floor(magnitude + 0.5) .. "m"
					flag30.lbl.Position = UDim2.fromOffset(value32.X, value32.Y)
					flag30.lbl.Visible = true
				else
					flag30.lbl.Visible = false
				end

				if list2.tr.arrows and not flag31 then
					local n6 = value31.X - n3
					local n7 = value31.Y - n4

					if flag32 then
						n6 = -n6
						n7 = -n7
					end

					local n8 = math.sqrt(n6 * n6 + n7 * n7)

					if n8 < 1 then
						n6 = 0
						n7 = -1
						n8 = 1
					end

					flag30.arw.TextColor3 = value30
					flag30.arw.Position = UDim2.fromOffset(n3 + n6 / n8 * n5, n4 + n7 / n8 * n5)
					flag30.arw.Rotation = math.deg(math.atan2(n7, n6)) + 90
					flag30.arw.Visible = true
				else
					flag30.arw.Visible = false
				end
			end
		end
	end

	list2.tr.start = function()
		if list2.tr.conn then
			return
		end

		list2.tr.conn = RunService.RenderStepped:Connect(function()
			pcall(list2.tr.step)
		end)
	end

	list2.tr.stop = function()
		if list2.tr.conn then
			pcall(function()
				list2.tr.conn:Disconnect()
			end)

			list2.tr.conn = nil
		end

		for k in pairs(list2.tr.parts) do
			list2.tr.drop(k)
		end
	end

	list2.tr.sync = function()
		if list2.tr.any() then
			list2.tr.start()
		else
			list2.tr.stop()
		end
	end

	pcall(function()
		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		remotes = remotes and remotes:FindFirstChild("Gameplay")
		local playerDataChanged = remotes and remotes:FindFirstChild("PlayerDataChanged")

		if playerDataChanged and playerDataChanged:IsA("RemoteEvent") then
			list2.conns[#list2.conns + 1] = playerDataChanged.OnClientEvent:Connect(function(param21)
				value26 = param21
				list2.liveData = param21
				list2.liveAt = os.clock()

				if func17() then
					func18()
				end
			end)
		end
	end)
end

TeleportService = game:GetService("TeleportService")
local flag33, func27, flag34, func28, func29, func30, func31, func32, func33

do
	local placeId = game.PlaceId
	local jobId = game.JobId
	flag33 = false

	-- Fling, two modes (Fling Mode in the Fling tab):
	--   Slam (Head): lands on the other player's head every frame (twice per frame) with a huge velocity pointing DOWN.
	--   Spin (Other Script): the other script's method. Your character is stood on the target again and again
	--   with a huge velocity and spin (alternating above / below them, turning every step).
	-- Both keep the camera on the target, stop as soon as they are thrown, then put you back where you were.
	func27 = function(player2)
		if flag33 then
			obj2:Notify({
				Title = "Fling Active!",
				Content = "Wait for the current fling to finish!",
				Duration = 1.5,
				Icon = "clock",
			})

			return
		end

		if not player2 or not player2.Character then
			obj2:Notify({ Title = "Error!", Content = "Could not find that player!", Duration = 1.5, Icon = "x" })

			return
		end

		if not player2.Character:FindFirstChildOfClass("Humanoid") then
			return
		end

		local character = localPlayer.Character
		if not character then
			return
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			return
		end

		local rootPart = humanoid.RootPart
		if not rootPart then
			return
		end

		local character2 = player2.Character
		local humanoid2 = character2:FindFirstChildOfClass("Humanoid")
		local rootPart2 = humanoid2 and humanoid2.RootPart
		local head = character2:FindFirstChild("Head")
		local accessory = character2:FindFirstChildOfClass("Accessory")
		accessory = accessory and accessory:FindFirstChild("Handle")

		if humanoid2 and humanoid2.Sit then
			return
		end

		flag33 = true

		local health = humanoid.Health
		local fallenPartsDestroyHeight = Workspace.FallenPartsDestroyHeight

		-- remember where we were (not while we are already flying around)
		if rootPart.Velocity.Magnitude < 50 then
			list2.flingOldPos = rootPart.CFrame
		end

		local oldPos = list2.flingOldPos or rootPart.CFrame
		local camera = Workspace.CurrentCamera
		local slam = list2.flingMode ~= "Spin"

		-- Smart Fling (extra): picks the mode by itself from what the target is doing right now.
		--   standing still -> Slam (Head), walking / running -> Spin (Other Script)
		if list2.smartFling and rootPart2 then
			local speed = 0

			pcall(function()
				local v = rootPart2.AssemblyLinearVelocity
				speed = Vector3.new(v.X, 0, v.Z).Magnitude

				local tracked = list2.velTrack and list2.velTrack[player2]

				if tracked and tracked.v then
					speed = math.max(speed, Vector3.new(tracked.v.X, 0, tracked.v.Z).Magnitude)
				end
			end)

			slam = speed < 3
		end

		if head then
			camera.CameraSubject = head
		elseif accessory then
			camera.CameraSubject = accessory
		elseif humanoid2 and rootPart2 then
			camera.CameraSubject = humanoid2
		end

		if not character2:FindFirstChildWhichIsA("BasePart") then
			camera.CameraSubject = humanoid
			flag33 = false

			return
		end

		local function fPos(basePart, offset, angle)
			local cf = CFrame.new(basePart.Position) * offset * angle

			rootPart.CFrame = cf

			pcall(function()
				character:SetPrimaryPartCFrame(cf)
			end)

			if slam then
				-- the huge velocity points straight DOWN, so whoever is hit is driven towards the ground and the
				-- void under the map
				rootPart.Velocity = Vector3.new(0, -8.1e14, 0)
				rootPart.RotVelocity = Vector3.new(8.1e14, 8.1e14, 8.1e14)
			else
				rootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
				rootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
			end
		end

		-- SLAM: land on the head EVERY frame (it used to be once every 4 frames) and, on top of that, land again
		-- before every physics step (Stepped), so the target gets hit twice per frame.
		-- SLAM_HEIGHTS = how high above the head we are on each frame; both heights are still a hit.
		local SLAM_HEIGHTS = { 0.6, 1.8 }

		local function slamBasePart(basePart)
			local now = tick()
			local step = 0
			local RunService = game:GetService("RunService")

			local pre = RunService.Stepped:Connect(function()
				if flag33 and rootPart and basePart.Parent then
					fPos(basePart, CFrame.new(0, SLAM_HEIGHTS[1], 0), CFrame.Angles(0, 0, 0))
				end
			end)

			while rootPart and humanoid2 and flag33 do
				step = step % #SLAM_HEIGHTS + 1
				fPos(basePart, CFrame.new(0, SLAM_HEIGHTS[step], 0), CFrame.Angles(0, 0, 0))
				task.wait()

				if basePart.Velocity.Magnitude > 500
					or basePart.Parent ~= player2.Character
					or player2.Parent ~= Players
					or humanoid.Health <= 0
					or humanoid.Health < health
					or humanoid2.Sit
					or tick() > now + 2
					or not flag33 then
					break
				end
			end

			pre:Disconnect()
		end

		local function sfBasePart(basePart)
			local timeToWait = 2
			local startTime = tick()
			local angle = 0

			repeat
				if rootPart and humanoid2 then
					local md = humanoid2.MoveDirection

					if basePart.Velocity.Magnitude < 50 then
						angle = angle + 100
						local rot = CFrame.Angles(math.rad(angle), 0, 0)
						local lead = md * basePart.Velocity.Magnitude / 1.25

						fPos(basePart, CFrame.new(0, 1.5, 0) + lead, rot)
						task.wait()
						fPos(basePart, CFrame.new(0, -1.5, 0) + lead, rot)
						task.wait()
						fPos(basePart, CFrame.new(2.25, 1.5, -2.25) + lead, rot)
						task.wait()
						fPos(basePart, CFrame.new(-2.25, -1.5, 2.25) + lead, rot)
						task.wait()
						fPos(basePart, CFrame.new(0, 1.5, 0) + md, rot)
						task.wait()
						fPos(basePart, CFrame.new(0, -1.5, 0) + md, rot)
						task.wait()
					else
						local ws = humanoid2.WalkSpeed
						local speed = (rootPart2 or basePart).Velocity.Magnitude / 1.25
						local r90 = CFrame.Angles(math.rad(90), 0, 0)
						local r0 = CFrame.Angles(0, 0, 0)

						fPos(basePart, CFrame.new(0, 1.5, ws), r90)
						task.wait()
						fPos(basePart, CFrame.new(0, -1.5, -ws), r0)
						task.wait()
						fPos(basePart, CFrame.new(0, 1.5, ws), r90)
						task.wait()
						fPos(basePart, CFrame.new(0, 1.5, speed), r90)
						task.wait()
						fPos(basePart, CFrame.new(0, -1.5, -speed), r0)
						task.wait()
						fPos(basePart, CFrame.new(0, 1.5, speed), r90)
						task.wait()
						fPos(basePart, CFrame.new(0, -1.5, 0), r90)
						task.wait()
						fPos(basePart, CFrame.new(0, -1.5, 0), r0)
						task.wait()
						fPos(basePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0))
						task.wait()
						fPos(basePart, CFrame.new(0, -1.5, 0), r0)
						task.wait()
					end
				else
					break
				end
			until basePart.Velocity.Magnitude > 500
				or basePart.Parent ~= player2.Character
				or player2.Parent ~= Players
				or humanoid2.Sit
				or humanoid.Health <= 0
				or tick() > startTime + timeToWait
				or not flag33
		end

		Workspace.FallenPartsDestroyHeight = (0 / 0)

		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Name = "FlingVel"
		bodyVelocity.Parent = rootPart
		bodyVelocity.Velocity = slam and Vector3.zero or Vector3.new(9e8, 9e8, 9e8)
		bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)

		humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

		pcall(function()
			if slam then
				-- we land on the HEAD of the other player (body / accessory only if they have no head)
				if head then
					slamBasePart(head)
				elseif rootPart2 then
					slamBasePart(rootPart2)
				elseif accessory then
					slamBasePart(accessory)
				end
			elseif rootPart2 and head then
				if (rootPart2.CFrame.p - head.CFrame.p).Magnitude > 5 then
					sfBasePart(head)
				else
					sfBasePart(rootPart2)
				end
			elseif rootPart2 and not head then
				sfBasePart(rootPart2)
			elseif not rootPart2 and head then
				sfBasePart(head)
			elseif accessory then
				sfBasePart(accessory)
			end
		end)

		bodyVelocity:Destroy()
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
		camera.CameraSubject = humanoid

		-- put us back where we were
		pcall(function()
			for _ = 1, 150 do
				rootPart.CFrame = oldPos * CFrame.new(0, 0.5, 0)

				pcall(function()
					character:SetPrimaryPartCFrame(oldPos * CFrame.new(0, 0.5, 0))
				end)

				humanoid:ChangeState("GettingUp")

				for _, child in ipairs(character:GetChildren()) do
					if child:IsA("BasePart") then
						child.Velocity = Vector3.zero
						child.RotVelocity = Vector3.zero
					end
				end

				task.wait()

				if (rootPart.Position - oldPos.p).Magnitude < 25 then
					break
				end
			end
		end)

		Workspace.FallenPartsDestroyHeight = fallenPartsDestroyHeight
		flag33 = false

		if humanoid.Health <= 0 then
			obj2:Notify({
				Title = "Fling Backfired",
				Content = player2.Name .. " killed you mid-fling.",
				Duration = 3,
				Icon = "x",
			})
		elseif humanoid.Health < health then
			obj2:Notify({
				Title = "Flinged!",
				Content = "Flinged " .. player2.Name .. " - took a hit.",
				Duration = 2,
				Icon = "flame",
			})
		else
			obj2:Notify({ Title = "Flinged!", Content = "Flinged " .. player2.Name .. "!", Duration = 1.5, Icon = "flame" })
		end
	end

	flag34 = false
	local flag35 = false

	func28 = function()
		return nil
	end

	func29 = function()
		if flag35 then
			return
		end
		flag35 = true

		task.spawn(function()
			while flag34 do
				task.wait(0.5)

				pcall(function()
					if not flag34 then
						return
					end

					if flag33 then
						return
					end
					local result4 = func28()
					if not result4 then
						return
					end
					local flag36 = Players:FindFirstChild(result4)

					if flag36 and flag36 ~= localPlayer and flag36.Character then
						func27(flag36)
					end
				end)

				if flag33 then
					while flag33 and flag34 do
						task.wait(0.2)
					end

					task.wait(1)
				end
			end

			flag35 = false
		end)
	end

	func30 = function()
		flag34 = false
	end

	func31 = function(player3, str6)
		local targetPlayer = player3
		player3 = player3 and player3.Character
		if not player3 or not player3:FindFirstChild("HumanoidRootPart") then
			obj2:Notify({ Title = "Error!", Content = "No " .. str6 .. " found!", Duration = 1.5, Icon = "x" })
			return
		end
		local character = localPlayer.Character
		if not character or not character:FindFirstChild("HumanoidRootPart") then
			return
		end
		character.HumanoidRootPart.Velocity = Vector3.zero
		character.HumanoidRootPart.CFrame = player3.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
		local roleSuffix = ""

		pcall(function()
			local role = list2.getPlayerRole and list2.getPlayerRole(targetPlayer)

			if role and role ~= str6 then
				roleSuffix = "  [" .. role .. "]"
			end
		end)

		obj2:Notify({ Title = "Teleported!", Content = "Teleported to " .. str6 .. roleSuffix, Duration = 1.5, Icon = "check" })
	end

	local function func36(url4)
		local ok, result = pcall(function()
			if syn and syn.request then
				return HttpService:JSONDecode(syn.request({ Url = url4, Method = "GET" }).Body)
			end

			if http and http.request then
				return HttpService:JSONDecode(http.request({ Url = url4, Method = "GET" }).Body)
			end

			if request then
				return HttpService:JSONDecode(request({ Url = url4, Method = "GET" }).Body)
			end

			if httpget then
				return HttpService:JSONDecode(httpget(url4))
			end
			return HttpService:JSONDecode(game:HttpGet(url4))
		end)

		if ok then
			return result
		end
		return nil
	end

	func32 = function()
		obj2:Notify({ Title = "Server Hop", Content = "Teleporting to a new server...", Duration = 3, Icon = "loader" })
		task.wait(0.5)

		local ok, result = pcall(function()
			TeleportService:Teleport(placeId)
		end)

		if not ok then
			obj2:Notify({ Title = "Error!", Content = "Failed to hop: " .. tostring(result), Duration = 3, Icon = "x" })
		end
	end

	func33 = function()
		obj2:Notify({
			Title = "Smallest Server",
			Content = "Finding the emptiest server...",
			Duration = 3,
			Icon = "loader",
		})

		local tbl18 = {}
		local n = 0
		local str7 = ""

		while n < 5 do
			n += 1
			local url5 = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"

			if str7 and str7 ~= "" then
				url5 ..= "&cursor=" .. str7
			end

			local flag37 = func36(url5)
			if not flag37 or not flag37.data then
				break
			end

			for _, item10 in ipairs(flag37.data) do
				if item10.id ~= jobId and item10.playing and item10.maxPlayers and item10.playing < item10.maxPlayers then
					table.insert(tbl18, item10)
				end
			end

			str7 = flag37.nextPageCursor
			if not str7 or str7 == "" then
				break
			end
		end

		if #tbl18 == 0 then
			obj2:Notify({
				Title = "No Servers!",
				Content = "No joinable servers found. Trying random hop...",
				Duration = 2,
				Icon = "x",
			})

			task.wait(1)

			pcall(function()
				TeleportService:Teleport(placeId)
			end)

			return
		end

		table.sort(tbl18, function(param22, param23)
			return param22.playing < param23.playing
		end)

		local first2 = tbl18[1]

		obj2:Notify({
			Title = "Joining!",
			Content = "Joining server with " .. first2.playing .. " players...",
			Duration = 2,
			Icon = "check",
		})

		task.wait(0.5)

		pcall(function()
			TeleportService:TeleportToPlaceInstance(placeId, first2.id)
		end)
	end

	list2.HOP_MIN_PLAYERS = 2
	list2.HOP_GRACE = 15
	list2.HOP_RETRY = 60
	list2.HOP_CONFIRM = 6
	list2.hopThread = nil
	list2.hopping = false

	list2.hopAttempt = function()
		obj2:Notify({
			Title = "Server Empty",
			Content = "Under " .. list2.HOP_MIN_PLAYERS .. " players here - hopping...",
			Duration = 4,
			Icon = "loader",
		})

		task.wait(0.5)

		if pcall(function()
			TeleportService:Teleport(placeId)
		end) then
			task.wait(list2.HOP_CONFIRM)
		end

		obj2:Notify({
			Title = "Matchmaking Refused",
			Content = "Picking from the server list...",
			Duration = 3,
			Icon = "x",
		})

		local value33 = nil
		local n = 0
		local str8 = ""

		while n < 4 do
			n += 1
			local url6 = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Desc&limit=100"

			if str8 ~= "" then
				url6 ..= "&cursor=" .. str8
			end

			local flag38 = func36(url6)

			if not (not flag38 or not flag38.data) then
				for _, item11 in ipairs(flag38.data) do
					if item11.id ~= jobId and item11.playing and item11.maxPlayers and item11.playing < item11.maxPlayers then
						if not value33 or item11.playing > value33.playing then
							value33 = item11
						end
					end
				end

				str8 = flag38.nextPageCursor or ""
				if str8 ~= "" then
					continue
				end
			end

			break
		end

		if value33 then
			obj2:Notify({
				Title = "Hopping",
				Content = "Joining a server with " .. value33.playing .. " players...",
				Duration = 3,
				Icon = "check",
			})

			task.wait(0.5)

			if pcall(function()
				TeleportService:TeleportToPlaceInstance(placeId, value33.id)
			end) then
				task.wait(list2.HOP_CONFIRM)
			end
		end

		return false
	end
end

list2.populatedHop = function()
	if list2.hopping then
		return false
	end
	list2.hopping = true
	local ok, result = pcall(list2.hopAttempt)
	if ok and result then
		return true
	end
	list2.hopping = false

	obj2:Notify({
		Title = "Hop Failed",
		Content = ok and "The server would not let go. Trying again in a minute." or "Hop errored - trying again in a minute.",
		Duration = 4,
		Icon = "x",
	})

	return false
end

list2.stopFarmHopWatch = function()
	if list2.hopThread then
		pcall(task.cancel, list2.hopThread)
		list2.hopThread = nil
	end
end

list2.startFarmHopWatch = function()
	list2.stopFarmHopWatch()

	list2.hopThread = task.spawn(function()
		local n = 0

		while true do
			task.wait(3)
			if not list2.farmHopOn then
				n = 0
				continue
			end

			if not (#Players:GetPlayers() < list2.HOP_MIN_PLAYERS) then
				n = 0
				continue
			end
			n += 3
			if not (list2.HOP_GRACE <= n) then
				continue
			end
			local ok, result = pcall(list2.populatedHop)
			local flag39 = false

			if ok then
				flag39 = result and true or false
			end

			if not flag39 then
				task.wait(list2.HOP_RETRY)
				n = 0
				continue
			end

			break
		end
	end)
end

UserInputService = game:GetService("UserInputService")
list2.touches = {}

pcall(function()
	list2.conns[#list2.conns + 1] = UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			list2.touches[input] = true
		end
	end)
end)

list2.pointerHeld = function()
	for k in pairs(list2.touches) do
		if k.UserInputState == Enum.UserInputState.End or k.UserInputState == Enum.UserInputState.Cancel then
			list2.touches[k] = nil
		end
	end

	if next(list2.touches) then
		return true
	end
	local flag40 = false

	pcall(function()
		for _, item12 in ipairs(UserInputService:GetMouseButtonsPressed()) do
			if item12.UserInputType == Enum.UserInputType.MouseButton1 then
				flag40 = true
			end
		end
	end)

	return flag40
end

task.spawn(function()
	while _G.FVLV2 == obj3 do
		task.wait(0.25)

		if obj2.CurrentInput ~= nil and not list2.pointerHeld() then
			obj2.CurrentInput = nil
		end
	end
end)

local flag41
flag41 = false
local flag42, n, flag43, flag44, walkSpeed, jumpPower, func37, func38, func39, func40
local func41, func42, func43, func44, func45, func46

do
	local connection = nil
	flag42 = false
	local connection2 = nil
	local bodyVelocity = nil
	local bodyGyro = nil
	n = 50
	flag43 = false
	local connection3 = nil
	local n2 = 0
	flag44 = false
	local connection4 = nil
	walkSpeed = 16
	jumpPower = 50

	-- Speed keeper. The speed used to be set once, so when the game changed WalkSpeed itself (the Murderer's knife
	-- does this the moment it is equipped / put away) the boost was lost. Now it is enforced all the time:
	--   1. before every physics step the speed is put back if it was changed;
	--   2. right after the step, if the game changed it AFTER we put it back (so the step ran at the game's speed),
	--      the missing distance is walked for you in the direction you are moving, and the speed is set again.
	-- Nothing happens while the speed is at the default 16.
	local speedConns = nil

	local function ensureSpeedKeeper()
		if speedConns then
			return
		end

		speedConns = {}

		speedConns[#speedConns + 1] = RunService.Stepped:Connect(function()
			if walkSpeed == 16 then
				return
			end

			local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoid.WalkSpeed ~= walkSpeed then
				humanoid.WalkSpeed = walkSpeed
			end
		end)

		speedConns[#speedConns + 1] = RunService.Heartbeat:Connect(function(dt)
			if walkSpeed == 16 then
				return
			end

			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local hrp = character and character:FindFirstChild("HumanoidRootPart")

			if not humanoid or not hrp or humanoid.Health <= 0 then
				return
			end

			if humanoid.WalkSpeed ~= walkSpeed then
				local missing = walkSpeed - humanoid.WalkSpeed
				local direction = humanoid.MoveDirection

				if missing > 0 and direction.Magnitude > 0.1 then
					hrp.CFrame = hrp.CFrame + direction * missing * dt
				end

				humanoid.WalkSpeed = walkSpeed
			end
		end)

		for _, connection in ipairs(speedConns) do
			list2.conns[#list2.conns + 1] = connection
		end
	end

	func37 = function(walkSpeed2)
		walkSpeed = walkSpeed2
		ensureSpeedKeeper()

		pcall(function()
			local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				humanoid.WalkSpeed = walkSpeed2
			end
		end)
	end

	func38 = function(jumpPower2)
		jumpPower = jumpPower2

		pcall(function()
			local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				humanoid.JumpPower = jumpPower2
				humanoid.UseJumpPower = true
			end
		end)
	end

	func39 = function()
		if connection then
			return
		end

		connection = RunService.Stepped:Connect(function()
			if not flag41 then
				return
			end

			pcall(function()
				local character = localPlayer.Character

				if character then
					for _, descendant in ipairs(character:GetDescendants()) do
						if descendant:IsA("BasePart") and descendant.CanCollide then
							if list2.clipWas[descendant] == nil then
								list2.clipWas[descendant] = true
							end

							descendant.CanCollide = false
						end
					end
				end
			end)
		end)
	end

	func40 = function()
		if connection then
			connection:Disconnect()
			connection = nil
		end

		list2.reclip(list2.clipWas)
	end

	func41 = function()
		if connection2 then
			return
		end
		local character = localPlayer.Character
		if not character then
			return
		end
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		if not humanoidRootPart then
			return
		end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			return
		end
		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Name = "FlyVelocity"
		bodyVelocity.Velocity = Vector3.zero
		bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bodyVelocity.Parent = humanoidRootPart
		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.Name = "FlyGyro"
		bodyGyro.P = 90000
		bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		bodyGyro.CFrame = humanoidRootPart.CFrame
		bodyGyro.Parent = humanoidRootPart
		humanoid.PlatformStand = true

		connection2 = RunService.Heartbeat:Connect(function()
			pcall(function()
				if not flag42 then
					return
				end
				local currentCamera = Workspace.CurrentCamera
				bodyGyro.CFrame = currentCamera.CFrame
				local obj5 = UserInputService
				local vector = Vector3.zero

				if obj5:IsKeyDown(Enum.KeyCode.W) then
					vector = Vector3.zero + currentCamera.CFrame.LookVector
				end

				if UserInputService:IsKeyDown(Enum.KeyCode.S) then
					vector -= currentCamera.CFrame.LookVector
				end

				if UserInputService:IsKeyDown(Enum.KeyCode.A) then
					vector -= currentCamera.CFrame.RightVector
				end

				if UserInputService:IsKeyDown(Enum.KeyCode.D) then
					vector += currentCamera.CFrame.RightVector
				end

				-- Phone / gamepad: the on-screen movement stick drives the humanoid's MoveDirection (world space,
				-- flat). Turn it into "forward / sideways relative to the camera" and fly along the camera's real
				-- look direction, so pushing the stick up flies where you are looking (up or down with the camera).
				-- Skipped when W/A/S/D is already used, so a keyboard is not counted twice.
				local analog = 1

				if vector.Magnitude == 0 then
					local stick = humanoid.MoveDirection

					if stick.Magnitude > 0.05 then
						local look = currentCamera.CFrame.LookVector
						local right = currentCamera.CFrame.RightVector
						local flatLook = Vector3.new(look.X, 0, look.Z)
						local flatRight = Vector3.new(right.X, 0, right.Z)

						if flatLook.Magnitude > 0.01 then
							vector += look * stick:Dot(flatLook.Unit)
						end

						if flatRight.Magnitude > 0.01 then
							vector += right * stick:Dot(flatRight.Unit)
						end

						-- a half-pushed stick flies at about half speed
						analog = math.clamp(stick.Magnitude, 0.3, 1)
					end
				end

				if UserInputService:IsKeyDown(Enum.KeyCode.Space) or humanoid.Jump then
					-- Space, or the phone's jump button held down: go up
					vector += Vector3.new(0, 1, 0)
				end

				if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
					vector -= Vector3.new(0, 1, 0)
				end

				if vector.Magnitude > 0 then
					bodyVelocity.Velocity = vector.Unit * n * analog
				else
					bodyVelocity.Velocity = Vector3.zero
				end
			end)
		end)
	end

	func42 = function()
		if connection2 then
			connection2:Disconnect()
			connection2 = nil
		end

		if bodyVelocity then
			bodyVelocity:Destroy()
			bodyVelocity = nil
		end

		if bodyGyro then
			bodyGyro:Destroy()
			bodyGyro = nil
		end

		pcall(function()
			local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				humanoid.PlatformStand = false
			end
		end)
	end

	func43 = function()
		if connection3 then
			return
		end

		connection3 = UserInputService.JumpRequest:Connect(function()
			if not flag43 then
				return
			end
			local now = tick()
			if now - n2 < 0.15 then
				return
			end
			n2 = now

			pcall(function()
				local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
				local flag45

				if humanoid then
					local jumping = Enum.HumanoidStateType.Jumping
					flag45 = humanoid:GetState() ~= jumping
				else
					flag45 = humanoid
				end

				if flag45 then
					humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end)
		end)

		-- Hold to keep jumping: while the jump key / button / pad button is held down, jump again every 0.15 s.
		-- (The JumpRequest above only fires once per press.)
		if not list2.infHoldConn then
			list2.infJump = { held = false, button = nil, conns = {}, nextBind = 0 }

			local function bindJumpButton()
				pcall(function()
					local gui = localPlayer:FindFirstChildOfClass("PlayerGui")
					local touchGui = gui and gui:FindFirstChild("TouchGui")
					local frame = touchGui and touchGui:FindFirstChild("TouchControlFrame")
					local button = frame and frame:FindFirstChild("JumpButton")

					if button and list2.infJump.button ~= button then
						list2.infJump.button = button

						list2.infJump.conns[#list2.infJump.conns + 1] = button.InputBegan:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
								list2.infJump.held = true
							end
						end)

						list2.infJump.conns[#list2.infJump.conns + 1] = button.InputEnded:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
								list2.infJump.held = false
							end
						end)
					end
				end)
			end

			list2.infHoldConn = RunService.Heartbeat:Connect(function()
				if not flag43 or list2.infJumpMode == "Tap" then
					return
				end

				-- the phone jump button is rebuilt when you respawn, so look for it again now and then
				local now = tick()

				if now >= list2.infJump.nextBind then
					list2.infJump.nextBind = now + 1
					bindJumpButton()
				end

				pcall(function()
					if UserInputService:GetFocusedTextBox() then
						return
					end

					local held = list2.infJump.held
						or UserInputService:IsKeyDown(Enum.KeyCode.Space)
						or UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonA)

					if not held or tick() - n2 < 0.15 then
						return
					end

					local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

					if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
						n2 = tick()
						humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
					end
				end)
			end)
		end
	end

	func44 = function()
		if connection3 then
			connection3:Disconnect()
			connection3 = nil
		end

		if list2.infHoldConn then
			list2.infHoldConn:Disconnect()
			list2.infHoldConn = nil
		end

		if list2.infJump then
			for _, connection in ipairs(list2.infJump.conns) do
				pcall(function()
					connection:Disconnect()
				end)
			end

			list2.infJump = nil
		end
	end

	func45 = function()
		if connection4 then
			return
		end

		connection4 = RunService.Heartbeat:Connect(function()
			if not flag44 then
				return
			end

			pcall(function()
				local character = localPlayer.Character
				if not character then
					return
				end
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				if not humanoidRootPart then
					return
				end

				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= localPlayer and player.Character then
						for _, descendant in ipairs(player.Character:GetDescendants()) do
							if descendant:IsA("BasePart") and not descendant.Anchored and descendant.Velocity.Magnitude > 200 then
								if (descendant.Position - humanoidRootPart.Position).Magnitude < 30 then
									descendant.Velocity = Vector3.zero
									descendant.RotVelocity = Vector3.zero
									descendant.Anchored = true

									task.delay(0.3, function()
										if descendant and descendant.Parent then
											descendant.Anchored = false
										end
									end)
								end
							end
						end
					end
				end
			end)
		end)
	end

	func46 = function()
		if connection4 then
			connection4:Disconnect()
			connection4 = nil
		end
	end
end

list2.conns[#list2.conns + 1] = localPlayer.CharacterAdded:Connect(function(character)
	character:WaitForChild("Humanoid")
	task.wait(0.5)

	pcall(function()
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			if walkSpeed ~= 16 then
				humanoid.WalkSpeed = walkSpeed
			end

			if jumpPower ~= 50 then
				humanoid.JumpPower = jumpPower
				humanoid.UseJumpPower = true
			end
		end
	end)

	if flag42 then
		pcall(func42)
		task.wait(0.2)
		pcall(func41)
	end

	if flag41 then
		pcall(func40)
		pcall(func39)
	end
end)

TweenService = game:GetService("TweenService")
VirtualUser = game:GetService("VirtualUser")
local obj6, n2, flag46, flag47, func47, func48, func49, func50, func51, func52
local func53

do
	local flag48 = false
	local flag49 = false
	obj6 = nil
	local value34 = nil
	local flag50 = false
	local tween = nil
	local value35 = nil
	local connection = nil
	n2 = 23
	local n3 = 0
	local value36 = nil
	flag46 = false
	local flag51 = false
	flag47 = false
	local connection2 = nil

	local function func54(instance2, flag52, flag53)
		local value37 = next
		local children, value38 = instance2:GetChildren()

		for _, value39 in value37, children, value38 do
			if value39.Name == flag52 and (not flag53 or value39.ClassName == flag53) then
				return value39
			end
		end
	end

	func47 = function(player4)
		if player4 and player4.Character then
			return func54(player4.Character, "HumanoidRootPart") or func54(player4.Character, "PrimaryPart")
		end
	end

	local function func55()
		local flag54 = func47(localPlayer)
		if not flag54 or not obj6 then
			return nil
		end
		local coinContainer = func54(obj6, "CoinContainer")
		if not coinContainer then
			return nil
		end
		local value40 = next
		local children, value41 = coinContainer:GetChildren()
		local huge = math.huge
		local value42 = nil

		for _, value43 in value40, children, value41 do
			local isPickup = value43.Name == "Coin_Server"
				or (list2.farmMode == "Candy" and value43:IsA("BasePart") and string.find(string.lower(value43.Name), "candy", 1, true) ~= nil)

			if isPickup and not value43:GetAttribute("Collected") and not list2.coinSkip(value43) then
				local magnitude = (flag54.Position - value43.Position).Magnitude

				if magnitude < huge then
					huge = magnitude
					value42 = value43
				end
			end
		end

		return value42
	end

	local function func56()
		local roundTimerPart = Workspace:FindFirstChild("RoundTimerPart")
		if roundTimerPart then
			return tonumber(roundTimerPart:GetAttribute("Time")) or 0
		end
		return 0
	end

	local function func57()
		local ok, result = pcall(function()
			local container

			if not list2.inLobbyNow() then
				container = localPlayer.PlayerGui.MainGUI.Game.CoinBags.Container
			else
				container = localPlayer.PlayerGui.MainGUI.Lobby.Dock.CoinBags.Container
			end

			if not container then
				return 0
			end
			local value44 = next
			local children, value45 = container:GetChildren()
			local value46 = nil

			for _, value47 in value44, children, value45 do
				if value47:IsA("GuiObject") and value47:FindFirstChild("CurrencyFrame") then
					if value47.Visible then
						value46 = value47
						break
					elseif value47.Name == "Coin" and not value46 then
						value46 = value47
					end
				end
			end

			if not value46 then
				return 0
			end
			local full = value46:FindFirstChild("Full")
			if full and full.Visible then
				return 999
			end
			local currencyFrame = value46:FindFirstChild("CurrencyFrame")
			currencyFrame = currencyFrame and currencyFrame:FindFirstChild("Icon")
			currencyFrame = currencyFrame and currencyFrame:FindFirstChild("Coins")
			currencyFrame = currencyFrame and currencyFrame.Text
			if currencyFrame and (string.lower(currencyFrame):find("full") or string.lower(currencyFrame):find("max")) then
				return 999
			end
			return tonumber(currencyFrame) or 0
		end)

		if ok then
			return result
		end
		return 0
	end

	local function func58(param24)
		if param24 then
			if not connection then
				connection = RunService.Stepped:Connect(function()
					-- FIX: the farm noclip must never outlive the farm. If the farm is off (or turned itself off) and
					-- something left this connection running, switch it off here and give the collisions back.
					if not flag48 then
						func58(false)
						return
					end

					local character = localPlayer.Character

					if character then
						local value48 = next
						local descendants, value49 = character:GetDescendants()

						for _, value50 in value48, descendants, value49 do
							if value50:IsA("BasePart") and value50.CanCollide then
								if list2.farmClipWas[value50] == nil then
									list2.farmClipWas[value50] = true
								end

								value50.CanCollide = false
							end
						end
					end
				end)
			end
		else
			if connection then
				connection:Disconnect()
				connection = nil
			end

			list2.reclip(list2.farmClipWas)
		end
	end

	local function func59(param25)
		local character = localPlayer.Character
		local upperTorso = character and character:FindFirstChild("UpperTorso")

		if param25 then
			if not upperTorso then
				return
			end
			local odhAutoFarmBodyGyro = upperTorso:FindFirstChild("ODH Auto Farm BodyGyro")
			local odhAutoFarmBodyVelocity = upperTorso:FindFirstChild("ODH Auto Farm BodyVelocity")

			odhAutoFarmBodyGyro = odhAutoFarmBodyGyro or odhAutoFarmBodyVelocity
			if odhAutoFarmBodyGyro then
				return
			end
			local flag55 = func47(localPlayer)
			if not flag55 then
				return
			end
			local humanoid = localPlayer.Character:FindFirstChild("Humanoid")
			if not humanoid then
				return
			end
			local cFrame = flag55.CFrame
			local cFrame2 = CFrame.new(cFrame.X, cFrame.Y, cFrame.Z) * CFrame.Angles(1.5707963267948966, 0, 1.5707963267948966)
			func58(true)
			local bodyGyro = Instance.new("BodyGyro")
			bodyGyro.Name = "ODH Auto Farm BodyGyro"
			bodyGyro.Parent = upperTorso
			bodyGyro.P = 90000
			bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
			bodyGyro.CFrame = cFrame2
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Name = "ODH Auto Farm BodyVelocity"
			bodyVelocity.Parent = upperTorso
			bodyVelocity.Velocity = Vector3.zero
			bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
			flag55.CFrame = cFrame2
			humanoid.PlatformStand = true
		else
			-- FIX: this used to quit early when the character had no UpperTorso yet (respawn / reset) or no
			-- Humanoid, and then the noclip was never switched off. Now the noclip is switched off FIRST,
			-- whatever state the character is in, and the leftovers are cleaned up after that.
			func58(false)

			if character then
				for _, leftover in ipairs(character:GetDescendants()) do
					if leftover.Name == "ODH Auto Farm BodyGyro" or leftover.Name == "ODH Auto Farm BodyVelocity" then
						pcall(function()
							leftover:Destroy()
						end)
					end
				end

				local humanoid = character:FindFirstChildOfClass("Humanoid")

				if humanoid then
					humanoid.PlatformStand = false
				end
			end
		end
	end

	local function func60()
		if not obj6 then
			return
		end
		local value51 = next
		local children, value52 = obj6.Spawns:GetChildren()
		local value53 = nil

		for _, value54 in value51, children, value52 do
			if value54.Name == "Spawn" or value54.Name == "PlayerSpawn" or value54.Name == "SpawnLocation" then
				value53 = value54
			end
		end

		if not value53 then
			return
		end
		local cFrame = value53.CFrame
		local value55 = func47(localPlayer)

		if value55 then
			value55.Velocity = Vector3.zero
			value55.CFrame = CFrame.new(cFrame.X, cFrame.Y + 5, cFrame.Z)
		end
	end

	local function func61()
		pcall(function()
			local playerGui = localPlayer:FindFirstChild("PlayerGui")
			playerGui = playerGui and playerGui:FindFirstChild("MainGUI")
			playerGui = playerGui and playerGui:FindFirstChild("Game")

			if playerGui then
				value34 = not playerGui:FindFirstChild("Inventory")
			end
		end)

		local value56 = next
		local children, value57 = Workspace:GetChildren()

		for _, value58 in value56, children, value57 do
			if value58:FindFirstChild("CoinAreas") or value58:FindFirstChild("CoinContainer") then
				obj6 = value58
			end
		end

		flag50 = false
		tween = nil
		value35 = nil
	end

	local function func62()
		if flag50 then
			flag50 = false
			value35 = nil

			if tween then
				pcall(function()
					tween:Cancel()
				end)
				tween = nil
			end

			-- FIX: always switch the farm movement / noclip off, even when there is no character right now
			pcall(func59, false)

			if localPlayer.Character and func56() > 0 and obj6 then
				func60()
			end
		elseif connection then
			-- FIX: the farm is idle (finished / died / respawned) but its noclip is still on: switch it off
			pcall(func59, false)
		end
	end

	func48 = function()
		if flag48 then
			return
		end
		flag48 = true
		func61()

		task.spawn(function()
			while flag48 do
				task.wait(0.1)

				pcall(function()
					if not flag48 then
						return
					end

					-- Avoid Murder: pause while the murderer is within 10 studs
					if list2.avoidMurderOn and list2.murdererNearby and list2.murdererNearby() then
						flag50 = false
						value35 = nil

						if tween then
							pcall(function()
								tween:Cancel()
							end)
							tween = nil
						end

						pcall(function()
							func59(false)
						end)

						local avoidHum = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
						if avoidHum then
							avoidHum.Sit = false
						end

						task.wait(1)
						return
					end

					if not localPlayer.Character then
						flag49 = false
					else
						local remotes = ReplicatedStorage:FindFirstChild("Remotes")
						local extras = remotes and remotes:FindFirstChild("Extras")
						local getPlayerData = extras and extras:FindFirstChild("GetPlayerData")

						if getPlayerData then
							local ok, result = pcall(function()
								return getPlayerData:InvokeServer()
							end)

							if ok and result then
								local entry1 = result[localPlayer.Name]

								if entry1 then
									entry1 = not entry1.Dead and not entry1.Killed
								end

								flag49 = entry1
							end
						end
					end

					local value59 = next
					local children, value60 = Workspace:GetChildren()

					for _, value61 in value59, children, value60 do
						if value61:FindFirstChild("CoinAreas") or value61:FindFirstChild("CoinContainer") then
							obj6 = value61
						end
					end

					if obj6 ~= list2.lastMap then
						list2.lastMap = obj6
						list2.sawCoins = false
						list2.flingDoneFired = false
						list2.killFired = false
						list2.coinReset()
					end

					local flag56 = func47(localPlayer)

					if flag49 and obj6 and flag56 and not list2.sawCoins and not func55() then
						if list2.hideUnderMap(flag56) then
							return
						end
					end

					if func56() > 0 then
						local result5 = func57()

						if list2.bagLimit() <= result5 then
							func62()
							list2.finishFling()

							if list2.killWhenFull and not list2.killFired and func15() == localPlayer then
								list2.killFired = true

								task.spawn(function()
									pcall(killAll)
								end)
							end
						elseif flag49 and localPlayer.Character then
							local num4 = func47(localPlayer)
							local obj7 = num4 and func55()

							if num4 and obj7 then
								list2.sawCoins = true

								if obj7 ~= value35 or value35 and value35:GetAttribute("Collected") then
									value35 = obj7
									flag50 = true
									list2.farmTargetTime = tick()

									if tween then
										tween:Cancel()
										tween = nil
									end

									func59(true)
									local cFrame = obj7.CFrame
									local n4 = (num4.Position - obj7.Position).Magnitude / n2

									if n4 > 15 then
										n4 = 3
									end

									if n4 < 0.05 then
										n4 = 0.05
									end

									num4.Velocity = Vector3.zero

									tween = TweenService:Create(num4, TweenInfo.new(n4, Enum.EasingStyle.Linear), {
										CFrame = CFrame.new(cFrame.X, cFrame.Y - 3.5, cFrame.Z) * CFrame.Angles(1.5707963267948966, 0, 1.5707963267948966),
									})

									tween:Play()
									num4.Velocity = Vector3.zero
								else
									local magnitude = (num4.Position - obj7.Position).Magnitude

									if magnitude <= 6 and not obj7:GetAttribute("Collected") then
										obj7.CFrame = CFrame.new(num4.Position + Vector3.new(math.random(-80, 80) / 100, math.random(-50, 300) / 100, math.random(-80, 80) / 100))

										if (obj7.Position - num4.Position).Magnitude > 0.1 then
											num4.CFrame = num4.CFrame * CFrame.new(0, math.random(-20, 20) / 100, math.random(-20, 20) / 100)
										end

										if value36 ~= obj7 then
											value36 = obj7
											n3 = tick()
										end

										if tick() - n3 > 2 then
											value36 = nil
											n3 = 0
											value35 = nil
										end
									elseif magnitude > 6 then
										local farmTargetTime = list2.farmTargetTime

										if tick() - farmTargetTime > 4 then
											list2.coinFailed(obj7)
											value35 = nil
											value36 = nil
											n3 = 0
										end
									end
								end
							elseif num4 then
								if list2.sawCoins then
									func62()
									list2.finishFling()
								end
							end
						else
							func62()
						end
					else
						func62()
					end
				end)
			end
		end)
	end

	list2.inActiveRound = function()
		if list2.inLobbyNow() then
			return false
		end

		if not flag49 then
			return false
		end
		local value62 = next
		local children, value63 = Workspace:GetChildren()
		local value64 = nil

		for _, value65 in value62, children, value63 do
			if value65:FindFirstChild("CoinAreas") or value65:FindFirstChild("CoinContainer") then
				value64 = value65
			end
		end

		if not value64 then
			return false
		end
		local character = localPlayer.Character
		character = character and character:FindFirstChildOfClass("Humanoid")
		if not character or character.Health <= 0 then
			return false
		end
		obj6 = value64
		return true
	end

	list2.teleportHome = function()
		if not obj6 then
			return
		end
		local spawns = obj6:FindFirstChild("Spawns")
		if not spawns then
			return
		end
		local value66 = next
		local children, value67 = spawns:GetChildren()
		local value68 = nil
		local value69 = nil

		for _, value70 in value66, children, value67 do
			if value70:IsA("BasePart") then
				value68 = value68 or value70

				if value70.Name == "Spawn" or value70.Name == "PlayerSpawn" or value70.Name == "SpawnLocation" then
					value69 = value70
				end
			end
		end

		value69 = value69 or value68
		if not value69 then
			return
		end
		local flag57 = func47(localPlayer)
		if not flag57 then
			return
		end
		local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid.PlatformStand = false
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end

		local cFrame = value69.CFrame
		flag57.Velocity = Vector3.zero
		flag57.RotVelocity = Vector3.zero
		flag57.CFrame = CFrame.new(cFrame.X, cFrame.Y + value69.Size.Y / 2 + 4, cFrame.Z)
	end

	func49 = function()
		flag48 = false

		if tween then
			pcall(function()
				tween:Cancel()
			end)

			tween = nil
		end

		pcall(function()
			func59(false)
		end)

		local flag58 = false

		pcall(function()
			if not (localPlayer.Character and func47(localPlayer)) then
				return
			end
			flag58 = list2.inActiveRound()

			if flag58 then
				list2.teleportHome()
			end
		end)

		task.spawn(function()
			task.wait(0.35)

			pcall(function()
				if tween then
					tween:Cancel()
					tween = nil
				end
			end)

			pcall(function()
				func59(false)
			end)

			local flag59 = false

			pcall(function()
				local character = localPlayer.Character
				if not character then
					return
				end
				local value71 = next
				local descendants, value72 = character:GetDescendants()

				for _, value73 in value71, descendants, value72 do
					if value73.Name == "ODH Auto Farm BodyGyro" or value73.Name == "ODH Auto Farm BodyVelocity" then
						value73:Destroy()
						flag59 = true
					end
				end

				local humanoid = character:FindFirstChildOfClass("Humanoid")

				if humanoid and humanoid.PlatformStand then
					humanoid.PlatformStand = false
					humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
					flag59 = true
				end
			end)

			if flag58 and flag59 then
				pcall(list2.teleportHome)
			end
		end)
	end

	list2.claimRewardPopup = function()
		local playerGui = localPlayer:FindFirstChild("PlayerGui")
		if not playerGui then
			return false
		end
		local claim = nil
		local crossPlatform = playerGui:FindFirstChild("CrossPlatform")
		local medium = crossPlatform and crossPlatform:FindFirstChild("NewItem") and crossPlatform.NewItem:FindFirstChild("Medium")

		if medium and medium.Visible then
			claim = medium:FindFirstChild("Container") and medium.Container:FindFirstChild("Claim")
		else
			medium = playerGui:FindFirstChild("MainGUI") and playerGui.MainGUI:FindFirstChild("Game")
			medium = medium and medium:FindFirstChild("NewItem")
			local visible = medium and medium.Visible
			local value74 = nil

			if visible then
				claim = medium:FindFirstChild("Container") and medium.Container:FindFirstChild("Claim")
			else
				medium = value74
			end
		end

		if not medium or not claim then
			return false
		end
		local amount = medium:FindFirstChild("Amount", true)
		local label = medium:FindFirstChild("Label", true)
		local icon = medium:FindFirstChild("Icon", true)
		local text = amount and amount.Text or nil
		local text2 = label and label.Text or nil
		local match = icon and tostring(icon.Image):match("%d+") or nil

		task.spawn(function()
			pcall(list2.whReward, text, text2, match)
		end)

		if getconnections then
			for _, item13 in ipairs({ "Activated", "MouseButton1Click" }) do
				local ok, result = pcall(getconnections, claim[item13])

				if ok and result and #result > 0 then
					for _, value75 in next, result, nil do
						pcall(function()
							value75:Fire()
						end)
					end

					return true
				end
			end
		end

		return (pcall(function()
			local VirtualInputManager = game:GetService("VirtualInputManager")
			local absolutePosition = claim.AbsolutePosition
			local absoluteSize = claim.AbsoluteSize
			local n4 = absolutePosition.X + absoluteSize.X / 2
			local n5 = absolutePosition.Y + absoluteSize.Y / 2 + 36
			VirtualInputManager:SendMouseButtonEvent(n4, n5, 0, true, game, 1)
			task.wait(0.05)
			VirtualInputManager:SendMouseButtonEvent(n4, n5, 0, false, game, 1)
		end))
	end

	list2.startShells = function()
		if list2.shellsRunning then
			return
		end
		list2.shellsRunning = true

		task.spawn(function()
			while list2.shellsOn do
				task.wait(0.5)
				pcall(list2.claimRewardPopup)
			end

			list2.shellsRunning = false
		end)
	end

	list2.stopShells = function()
		list2.shellsOn = false
	end

	list2.SBOX_DELAY = 1
	list2.CUR_NAME = { SummerKey2026 = "Shells" }

	list2.curName = function(param26)
		return list2.CUR_NAME[param26] or tostring(param26)
	end

	list2.BOX_CURRENCY = { Summer2026Box = "SummerKey2026" }

	list2.BOXES = {
		{ "Summer2026Box", "Summer Box '26" },
		{ "MysteryBox1", "Mystery Box #1" },
		{ "MysteryBox2", "Mystery Box #2" },
		{ "KnifeBox1", "Knife Box #1" },
		{ "KnifeBox2", "Knife Box #2" },
		{ "KnifeBox3", "Knife Box #3" },
		{ "KnifeBox4", "Knife Box #4" },
		{ "KnifeBox5", "Knife Box #5" },
		{ "GunBox1", "Gun Box #1" },
		{ "GunBox2", "Gun Box #2" },
		{ "GunBox3", "Gun Box #3" },
		{ "MLG Box", "Rainbow Box" },
	}

	list2.boxOn = {}
	list2.boxRunning = {}
	list2.boxWaiting = {}

	list2.boxPrice = function(param27)
		local str9 = list2.BOX_CURRENCY[param27] or "Coins"
		local ok, result = pcall(require, game:GetService("ReplicatedStorage").Database.Sync.NewShop)
		if not ok or type(result) ~= "table" then
			return str9, nil
		end
		local entry2 = result[param27]
		local price = type(entry2) == "table" and type(entry2.Price) == "table" and entry2.Price or nil
		return str9, price and tonumber(price[str9]) or nil
	end

	list2.boxImage = function(param28)
		local ok, result = pcall(require, game:GetService("ReplicatedStorage").Database.Sync.MysteryBox)
		if not ok or type(result) ~= "table" then
			return nil
		end
		local entry3 = result[param28]
		return type(entry3) == "table" and entry3.Image or nil
	end

	list2.boxFunds = function(param29)
		local tbl19 = list2.readOwned()
		if not tbl19 then
			return nil
		end
		return tonumber(tbl19[param29]) or 0
	end

	list2.openBox = function(payload)
		local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
		remotes = remotes and remotes:FindFirstChild("Shop")
		remotes = remotes and remotes:FindFirstChild("OpenCrate")
		if not remotes then
			return nil, "the OpenCrate remote is gone"
		end
		local str10 = list2.BOX_CURRENCY[payload] or "Coins"

		local ok, result = pcall(function()
			return remotes:InvokeServer(payload, "MysteryBox", str10)
		end)

		if not ok then
			return nil, tostring(result)
		end
		return result
	end

	list2.startBox = function(param30, param31)
		if list2.boxRunning[param30] then
			return
		end
		list2.boxRunning[param30] = true

		task.spawn(function()
			local n4 = 0

			while list2.boxOn[param30] do
				local value76, num5 = list2.boxPrice(param30)
				local num6 = list2.boxFunds(value76)

				if num5 and num6 and num6 < num5 then
					if not list2.boxWaiting[param30] then
						list2.boxWaiting[param30] = true

						obj2:Notify({
							Title = param31,
							Content = "Waiting for " .. list2.comma(num5 - num6) .. " more " .. list2.curName(value76) .. ". It opens on its own once you can afford one.",
							Duration = 5,
							Icon = "clock",
						})
					end

					task.wait(5)
				else
					list2.boxWaiting[param30] = false
					local flag60, flag61 = list2.openBox(param30)

					if not flag60 then
						local flag62 = list2.boxFunds(value76)

						if num5 and flag62 and flag62 < num5 then
							task.wait(5)
						else
							list2.boxOn[param30] = false

							if list2.el.box and list2.el.box[param30] then
								list2.setToggle(list2.el.box[param30], false)
							end

							obj2:Notify({
								Title = param31,
								Content = (n4 > 0 and "Opened " .. n4 .. ", then stopped: " or "Nothing opened: ") .. (flag61 or "the server refused") .. ".",
								Duration = 6,
								Icon = "x",
							})

							break
						end
					else
						n4 += 1

						task.spawn(function()
							pcall(list2.whBox, flag60)
						end)

						task.wait(list2.SBOX_DELAY)
					end
				end
			end

			list2.boxRunning[param30] = false
			list2.boxWaiting[param30] = false
		end)
	end

	list2.stopBox = function(param32)
		list2.boxOn[param32] = false
	end

	_G.__FVLBuild = "gatestyle-38"
	_G.__FVLGen = (_G.__FVLGen or 0) + 1
	list2.gen = _G.__FVLGen

	list2.current = function()
		return list2.gen == _G.__FVLGen
	end

	list2.WH_URL = ""
	list2.whOn = false

	list2.whUrlNow = function()
		return (tostring(list2.WH_URL or ""):gsub("^%s+", ""):gsub("%s+$", ""))
	end

	list2.WH_HOSTS = { "discord.com", "discordapp.com", "canary.discord.com", "ptb.discord.com" }

	list2.whReady = function()
		if not list2.current() then
			return false
		end

		if not list2.whOn then
			return false
		end

		if list2.whBreak then
			return false
		end
		local obj8 = list2.whUrlNow()

		for _, whHost in ipairs(list2.WH_HOSTS) do
			if obj8:find("^https://" .. whHost:gsub("%.", "%%.") .. "/api/webhooks/") then
				return true
			end
		end

		return false
	end

	list2.COIN_ICON = "197012173"
	list2.CLR_LINE = 1
	list2.BANNER = "https://media.discordapp.net/attachments/1538692700096831508/1540857194465988689/onyxscripts.png?ex=6a8b7a96&is=6a8a2916&hm=adfd88f586dc9af0ec57345e6b06ae67e779e414c854e73beb378bff8444f74f&=&format=webp&quality=lossless&width=550&height=310"

	list2.comma = function(param33)
		local num7 = tonumber(param33)
		if num7 == nil then
			return "?"
		end
		local str11 = num7 < 0 and "-" or ""
		local func63 = tostring
		local packed1 = table.pack(math.floor(math.abs(num7)))
		return str11 .. func63(table.unpack(packed1, 1, packed1.n)):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
	end

	list2.fld = function(param34, param35, flag63)
		return { name = param34, value = param35, inline = flag63 ~= false }
	end

	list2.avatarUrl = function()
		if list2.avatarCache ~= nil then
			return list2.avatarCache or nil
		end
		local localPlayer2 = game:GetService("Players").LocalPlayer

		local ok, result = pcall(function()
			return game:HttpGet("https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. tostring(localPlayer2.UserId) .. "&size=150x150&format=Png&isCircular=false")
		end)

		local match = ok and type(result) == "string" and result:match("\"imageUrl\"%s*:%s*\"([^\"]+)\"") or nil
		list2.avatarCache = match or false
		return match
	end

	list2.markUrl = function()
		if list2.markCache then
			return list2.markCache
		end
		local match = list2.markIcon and tostring(list2.markIcon.Image):match("(%d+)")
		if not match then
			return nil
		end
		list2.markCache = list2.itemThumb(match) or nil
		return list2.markCache
	end

	list2.FARM_FLAGS = {
		{ "Toggle_Coin_Autofarm", "Coin Autofarm" },
		{ "Slider_Farm_Speed", "Farm Speed" },
		{ "Toggle_Discord_Sender", "Discord Sender" },
		{ "Toggle_Farm_Perf_Master", "Performance Mode" },
		{ "Toggle_Farm_Dead_Hop", "Hop When Server Dies" },
		{ "Toggle_Anti_AFK", "Anti-AFK" },
		{ "Toggle_Auto_Reset_When_Bag_Full", "Auto-Reset When Bag Full" },
		{ "Toggle_Auto_Claim_Shells", "Auto Claim Shells" },
		{ "Toggle_Auto_Summer_Box", "Auto Open Summer Box" },
		{ "Toggle_Fling_Murderer_When_Done", "Fling Murderer When Done" },
		{ "Toggle_Kill_All_When_Bag_Full", "Kill All When Bag Full" },
	}

	list2.flagText = function(flag64, param36)
		if flag64 == "Toggle_Discord_Sender" then
			return list2.whOn and "on" or "off"
		end

		if param36.__type == "Slider" then
			return type(param36.Value) == "table" and tostring(param36.Value.Default) or tostring(param36.Value)
		end
		return param36.Value == true and "on" or "off"
	end

	list2.settingsBlob = function()
		local elements = list2.config and list2.config.Elements
		if type(elements) ~= "table" then
			return "_unavailable_"
		end
		local list5 = {}
		local n4 = 0

		for _, farmFlag in ipairs(list2.FARM_FLAGS) do
			local value77 = elements[farmFlag[1]]

			if type(value77) == "table" then
				list5[#list5 + 1] = { farmFlag[2], list2.flagText(farmFlag[1], value77) }

				if n4 < #farmFlag[2] then
					n4 = #farmFlag[2]
				end
			end
		end

		if #list5 == 0 then
			return "_unavailable_"
		end
		local tbl20 = {}

		for _, item14 in ipairs(list5) do
			local n5 = #tbl20 + 1
			local second2 = item14[2]
			tbl20[n5] = item14[1] .. string.rep(" ", n4 - #item14[1] + 2) .. second2
		end

		local str12 = "```\n" .. table.concat(tbl20, "\n") .. "\n```"

		if #str12 > 1000 then
			str12 = str12:sub(1, 986) .. "\n...\n```"
		end

		return str12
	end

	list2.setState = function()
		local elements = list2.config and list2.config.Elements
		if type(elements) ~= "table" then
			return nil
		end
		local tbl21 = {}

		for _, farmFlag in ipairs(list2.FARM_FLAGS) do
			local value78 = elements[farmFlag[1]]

			if type(value78) == "table" then
				tbl21[farmFlag[1]] = list2.flagText(farmFlag[1], value78)
			end
		end

		return tbl21
	end

	list2.setDiff = function(tbl22, list6)
		if type(tbl22) ~= "table" or type(list6) ~= "table" then
			return {}
		end
		local tbl23 = {}

		for _, farmFlag in ipairs(list2.FARM_FLAGS) do
			tbl23[farmFlag[1]] = farmFlag[2]
		end

		local list7 = {}

		for k, value79 in pairs(list6) do
			if tbl22[k] ~= nil and tbl22[k] ~= value79 then
				list7[#list7 + 1] = "**" .. tostring(tbl23[k] or k) .. "**  " .. tostring(tbl22[k]) .. "  ->  **" .. tostring(value79) .. "**"
			end
		end

		table.sort(list7)
		return list7
	end

	list2.whSettings = function(list8)
		if not list2.whReady() then
			return false, "not sending"
		end
		local flag65 = list8 and #list8 > 0
		local str13 = "Autofarm settings changed."

		if flag65 then
			str13 = table.concat(list8, "\n")

			if #str13 > 3500 then
				str13 = str13:sub(1, 3480) .. "\n..."
			end
		end

		return list2.whPost({
			title = "Settings Changed",
			body = str13,
			thumb = list2.avatarUrl(),
			fields = { { name = "Autofarm Settings", value = list2.settingsBlob(), inline = false } },
		})
	end

	task.spawn(function()
		task.wait(15)
		list2.setSnap = list2.setState()

		while true do
			task.wait(3)

			if not list2.current() then
				break
			else
				local flag66 = list2.setState()

				if flag66 and list2.setSnap then
					if #list2.setDiff(list2.setSnap, flag66) > 0 then
						task.wait(3)
						local value80 = list2.setState() or flag66
						local list9 = list2.setDiff(list2.setSnap, value80)
						list2.setSnap = value80

						if #list9 > 0 and list2.whReady() then
							task.spawn(function()
								pcall(list2.whSettings, list9)
							end)
						end
					end
				elseif flag66 then
					list2.setSnap = flag66
				end
			end
		end
	end)

	list2.whHello = function()
		if list2.saidHello then
			return true, "already sent"
		end
		local localPlayer2 = game:GetService("Players").LocalPlayer
		list2.readCoins()
		list2.readShells()
		local whPost = list2.whPost

		local tbl24 = {
			title = "F$VL logger started",
			body = "Logging as **" .. localPlayer2.DisplayName .. "** since <t:" .. tostring(os.time()) .. ":f>.",
			thumb = list2.avatarUrl(),
			wait = true,
		}

		local pad3 = list2.pad3
		local value81 = list2.fld("User ID", "`" .. tostring(localPlayer2.UserId) .. "`")
		local Coins = list2.fld("Coins", "`" .. list2.comma(list2.coinsTotal) .. "`")
		local Shells = list2.fld("Shells", "`" .. list2.comma(list2.shellsLeft) .. "`")
		local fld = list2.fld
		local value82 = list2.settingsBlob()
		local tbl25 = { value81, Coins, Shells }

		do
			local values = table.pack(fld("Autofarm settings", value82, false))
			table.move(values, 1, values.n, 4, tbl25)
		end

		tbl24.fields = pad3(tbl25)
		local value83, value84 = whPost(tbl24)

		if value83 then
			list2.saidHello = true
		end

		return value83, value84
	end

	list2.whQ = {}
	list2.whQBusy = false
	list2.whSentN = 0
	list2.whDropped = 0
	list2.whLastErr = nil
	list2.whBreak = false

	list2.whSend = function(param37)
		local request_ = syn and syn.request or request or http_request or http and http.request
		if not request_ then
			return false, "no request function", nil
		end

		local ok, result = pcall(request_, {
			Url = list2.whUrlNow(),
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body = param37,
		})

		if not ok then
			return false, "request failed", 5
		end
		local n4 = tonumber(type(result) == "table" and (result.StatusCode or result.Status) or nil) or 0
		if n4 == 204 or n4 == 200 or n4 == 0 and type(result) == "table" and result.Success == true then
			return true, tostring(n4), nil
		end

		if n4 == 429 then
			local flag67 = type(result) == "table"

			if flag67 then
				flag67 = tostring(result.Body or "")
			end

			return false, "429", math.min(60, (tonumber((flag67 or ""):match("\"retry_after\"%s*:%s*([%d%.]+)")) or 1) + 0.25)
		end

		if n4 >= 500 then
			return false, tostring(n4), 5
		end
		return false, tostring(n4), nil
	end

	list2.whPump = function()
		if list2.whQBusy then
			return
		end
		list2.whQBusy = true

		task.spawn(function()
			while #list2.whQ > 0 and list2.current() and not list2.whBreak do
				local value85 = list2.whQ[1]
				local value86, str14, value87 = list2.whSend(value85.body)

				if value86 then
					table.remove(list2.whQ, 1)
					list2.whSentN = list2.whSentN + 1
					list2.whLastErr = nil
					value85.ok = true
					value85.code = str14
					value85.done = true
					task.wait(0.35)
				elseif value87 then
					task.wait(value87)
				else
					table.remove(list2.whQ, 1)
					list2.whDropped = list2.whDropped + 1
					list2.whLastErr = str14
					value85.ok = false
					value85.code = str14
					value85.done = true

					if str14 == "401" or str14 == "403" or str14 == "404" then
						list2.whBreak = true

						obj2:Notify({
							Title = "Webhook Rejected",
							Content = "Discord answered " .. str14 .. ". The webhook was deleted or revoked, so sending has stopped. Paste a new one.",
							Duration = 10,
							Icon = "x",
						})
					end
				end
			end

			if list2.whBreak then
				for _, item15 in ipairs(list2.whQ) do
					item15.done = true
					item15.ok = false
					item15.code = "stopped"
				end

				list2.whDropped = list2.whDropped + #list2.whQ
				list2.whQ = {}
			end

			list2.whQBusy = false
		end)
	end

	list2.whPost = function(obj)
		if not list2.whReady() then
			return false, "no webhook set"
		end
		local localPlayer2 = game:GetService("Players").LocalPlayer

		local tbl26 = {
			title = obj.title,
			description = obj.body,
			color = list2.CLR_LINE,
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
			author = {
				name = localPlayer2.Name .. "  (" .. localPlayer2.DisplayName .. ")",
				url = "https://www.roblox.com/users/" .. tostring(localPlayer2.UserId) .. "/profile",
				icon_url = list2.avatarUrl(),
			},
			footer = { text = tostring(game.JobId), icon_url = list2.markUrl() },
		}

		if obj.thumb then
			tbl26.thumbnail = { url = obj.thumb }
		end

		if list2.BANNER ~= "" then
			tbl26.image = { url = list2.BANNER }
		end

		if obj.fields and #obj.fields > 0 then
			tbl26.fields = obj.fields
		end

		local tbl27 = {
			username = "F$VL",
			avatar_url = list2.markUrl(),
			allowed_mentions = { parse = {} },
			embeds = { tbl26 },
		}

		if obj.ping then
			tbl27.content = "@everyone"
			tbl27.allowed_mentions = { parse = { "everyone" } }
		end

		local ok, result = pcall(function()
			return game:GetService("HttpService"):JSONEncode(tbl27)
		end)

		if not ok then
			return false, "could not encode the payload"
		end
		local tbl28 = { body = result, done = false }

		if #list2.whQ >= 40 then
			local value88 = table.remove(list2.whQ, 1)
			value88.done = true
			value88.ok = false
			value88.code = "dropped"
			list2.whDropped = list2.whDropped + 1
		end

		list2.whQ[#list2.whQ + 1] = tbl28
		list2.whPump()
		if not obj.wait then
			return true, "queued"
		end
		local now = os.clock()

		while not tbl28.done and os.clock() - now < 25 do
			task.wait(0.1)
		end

		if not tbl28.done then
			return false, "no answer from Discord"
		end
		return tbl28.ok, tbl28.code
	end

	task.spawn(function()
		list2.avatarUrl()
		task.wait(4)
		list2.markUrl()
		list2.itemThumb(list2.COIN_ICON)
	end)

	list2.thumbCache = {}

	list2.itemThumb = function(flag68)
		if not flag68 then
			return nil
		end
		local str15 = tostring(flag68)
		if list2.thumbCache[str15] ~= nil then
			return list2.thumbCache[str15] or nil
		end
		local url7 = "https://thumbnails.roblox.com/v1/assets?assetIds=" .. str15 .. "&size=150x150&format=Png&isCircular=false"

		local ok, result = pcall(function()
			return game:HttpGet(url7)
		end)

		ok = ok and type(result) == "string" and result:match("\"imageUrl\"%s*:%s*\"([^\"]+)\"") or nil

		if ok and ok:find("PrivateImage", 1, true) then
			ok = nil
		end

		list2.thumbCache[str15] = ok or false
		return ok
	end

	list2.SHELL_IMG = "https://static.wikia.nocookie.net/murder-mystery-2/images/e/e5/Shells.png/revision/latest?cb=20260724145424"
	list2.ZWSP = utf8.char(8203)

	list2.pad3 = function(list10)
		local list11 = {}
		local list12 = {}

		for _, item16 in ipairs(list10) do
			if item16.inline then
				list11[#list11 + 1] = item16
			else
				list12[#list12 + 1] = item16
			end
		end

		while #list11 % 3 ~= 0 do
			list11[#list11 + 1] = { name = list2.ZWSP, value = list2.ZWSP, inline = true }
		end

		for _, item17 in ipairs(list12) do
			list11[#list11 + 1] = item17
		end

		return list11
	end

	list2.SHELL_KEY = "SummerKey2026"
	list2.SBOX_COST = 120
	list2.shellsLeft = nil
	list2.coinsTotal = nil

	list2.readOwned = function()
		local ok, result = pcall(require, game:GetService("ReplicatedStorage").Modules.ProfileData)
		if not ok or type(result) ~= "table" then
			return nil
		end
		local owned = result.Materials and result.Materials.Owned
		return type(owned) == "table" and owned or nil
	end

	list2.readXP = function()
		local ok, result = pcall(require, game:GetService("ReplicatedStorage").Modules.ProfileData)
		if not ok or type(result) ~= "table" then
			return nil
		end
		return tonumber(result.NewXP)
	end

	list2.readLevel = function()
		local flag69 = list2.readXP()
		if not flag69 then
			return nil
		end
		local ok, result = pcall(require, game:GetService("ReplicatedStorage").Modules.LevelModule)
		if not ok or type(result) ~= "table" or type(result.GetLevel) ~= "function" then
			return nil
		end
		local ok2, result2 = pcall(result.GetLevel, flag69)
		return ok2 and tonumber(result2) or nil
	end

	list2.readShells = function()
		local tbl29 = list2.readOwned()
		if not tbl29 then
			return nil
		end
		local shellsLeft = tonumber(tbl29[list2.SHELL_KEY]) or 0
		list2.shellsLeft = shellsLeft
		return shellsLeft
	end

	list2.readCoins = function()
		local flag70 = list2.readOwned()
		if not flag70 then
			return nil
		end
		local coinsTotal = tonumber(flag70.Coins) or 0
		list2.coinsTotal = coinsTotal
		return coinsTotal
	end

	list2.whBox = function(param38)
		if not list2.whReady() then
			return false, "no webhook set"
		end
		local ok, result = pcall(require, game:GetService("ReplicatedStorage").Database.Sync.Item)
		local flag71 = ok and type(result) == "table" and result[param38] or nil
		flag71 = type(flag71) == "table" and flag71 or {}
		list2.readShells()
		local str16 = tostring(flag71.ItemName or param38)
		local str17 = tostring(flag71.Rarity or "Unknown")
		local whPost = list2.whPost

		local tbl30 = {
			ping = str17:lower() == "godly",
			title = "Opened a Summer Box!",
			body = "Skin: **" .. str16 .. "**\n\n**Info:**",
			thumb = list2.itemThumb(flag71.ItemID),
		}

		local Rarity = list2.fld("Rarity", str17)
		local Cost = list2.fld("Cost", list2.comma(list2.SBOX_COST))
		local fld = list2.fld
		local comma = list2.comma
		local shellsLeft = list2.shellsLeft
		local fields = { Rarity, Cost }

		do
			local values = table.pack(fld("Shells left", comma(shellsLeft)))
			table.move(values, 1, values.n, 3, fields)
		end

		tbl30.fields = fields
		return whPost(tbl30)
	end

	list2.whReward = function(flag72, flag73, param39)
		if not list2.whReady() then
			return false, "no webhook set"
		end
		local str18 = tostring(flag72 or ""):gsub("^%s*[xX]%s*", "")
		local func64 = tonumber
		local str19 = str18:gsub("[^%d%.]", "")
		local str20 = func64(str19)

		if tostring(flag73 or "reward"):lower():find("shell", 1, true) then
			if not list2.readShells() and str20 and type(list2.shellsLeft) == "number" then
				list2.shellsLeft = list2.shellsLeft + str20
			end

			str20 = str20 and list2.comma(str20) or str18 ~= "" and str18 or "?"
			local list13 = {}
			local Received = list2.fld("Received", "+" .. str20 .. " Shells")
			local fld = list2.fld
			local str21 = list2.comma(list2.shellsLeft) .. " Shells"
			list13[1] = Received

			do
				local values = table.pack(fld("Balance", str21))
				table.move(values, 1, values.n, 2, list13)
			end

			if type(list2.shellsLeft) == "number" then
				local n4 = list2.SBOX_COST - list2.shellsLeft
				list13[#list13 + 1] = list2.fld("Next box", n4 > 0 and list2.comma(n4) .. " Shells left" or list2.comma(math.floor(list2.shellsLeft / list2.SBOX_COST)) .. " boxes ready")
			end

			return list2.whPost({
				title = utf8.char(128026) .. "  +" .. str20 .. " shells",
				thumb = list2.SHELL_IMG,
				fields = list2.pad3(list13),
			})
		end

		str20 = str20 and list2.comma(str20) or str18 ~= "" and str18 or nil
		local str22

		return list2.whPost({
			title = "Reward claimed",
			body = str20 and "Received **" .. str20 .. "** " .. str22 .. "." or "Received **" .. str22 .. "**.",
			thumb = list2.itemThumb(param39),
		})
	end

	list2.roundCoins = 0
	list2.roundBags = {}
	list2.roundRole = nil
	list2.roundEndRole = nil
	list2.roundStart = nil
	list2.roundLength = nil
	list2.roundMode = nil
	list2.roundWin = nil
	list2.roundId = nil
	list2.roundLive = false
	list2.roundLastT = nil

	list2.roundRoster = function()
		local ok, result = pcall(require, game:GetService("ReplicatedStorage").Modules.CurrentRoundClient)
		if not ok or type(result) ~= "table" then
			return nil
		end
		return type(result.PlayerData) == "table" and result.PlayerData or nil
	end

	list2.myRoundRec = function()
		local tbl31 = list2.roundRoster()
		return tbl31 and tbl31[localPlayer.Name] or nil
	end

	-- Role lookup for any player.
	-- Order: live PlayerDataChanged data -> round roster module -> Knife/Gun tool check.
	-- Returns: role (string or nil)

	-- other names for the same role -> the name the rest of the script expects
	-- (the game may say "Infected" / "Zombies" / "survivor" ... while ESP, fling, aim ... look for "Zombie" / "Survivor")
	list2.roleAlias = {
		hero = "Sheriff",
		infected = "Zombie",
		zombie = "Zombie",
		zombies = "Zombie",
		survivor = "Survivor",
		survivors = "Survivor",
	}

	list2.normRole = function(value)
		local text = tostring(value)

		return list2.roleAlias[string.lower(text)] or text
	end

	-- Is this round the zombie / infection mode? (game mode name first, then: does anybody carry a Zombie / Survivor role?)
	list2.infectionCache = { t = 0, value = false }

	list2.isInfectionRound = function()
		local now = os.clock()
		local cache = list2.infectionCache

		if now - cache.t < 0.5 then
			return cache.value
		end

		local found = false
		local okMode, mode = pcall(function()
			return workspace:GetAttribute("GameMode")
		end)

		if okMode and type(mode) == "string" then
			local lowered = string.lower(mode)

			if string.find(lowered, "infect", 1, true) or string.find(lowered, "zomb", 1, true) then
				found = true
			end
		end

		if not found then
			local function scan(data)
				if type(data) ~= "table" then
					return false
				end

				for _, rec in pairs(data) do
					if type(rec) == "table" and rec.Role ~= nil then
						local role = list2.normRole(rec.Role)

						if role == "Zombie" or role == "Survivor" then
							return true
						end
					end
				end

				return false
			end

			local okScan, result = pcall(function()
				return scan(list2.liveData) or scan(list2.polledData) or scan(list2.roundRoster())
			end)

			found = okScan and result == true
		end

		cache.t = now
		cache.value = found

		return found
	end

	-- Ask the server directly who has which role (the game's own GetPlayerData remote, the same one the rest of this
	-- script already uses). The PlayerDataChanged event alone did not carry the zombie roles before the knife / gun
	-- were handed out, so the ESP only saw zombies once the round had started. Runs in its own thread (InvokeServer
	-- yields) and is called from the ESP loop about every 0.6 s while the ESP is on.
	-- Debug: run  getgenv().MM2_ESP_DEBUG = true  to print every player's raw data whenever it changes.
	list2.polledData = nil
	list2.polledAt = 0
	list2.polling = false
	list2.pollStart = 0

	list2.pollPlayerData = function()
		if list2.polling and os.clock() - list2.pollStart < 5 then
			return
		end

		list2.polling = true
		list2.pollStart = os.clock()

		task.spawn(function()
			local ok, result = pcall(function()
				local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
				local extras = remotes and remotes:FindFirstChild("Extras")
				local getPlayerData = extras and extras:FindFirstChild("GetPlayerData")

				if getPlayerData and getPlayerData:IsA("RemoteFunction") then
					return getPlayerData:InvokeServer()
				end

				return nil
			end)

			if ok and type(result) == "table" then
				list2.polledData = result
				list2.polledAt = os.clock()

				if getgenv and getgenv().MM2_ESP_DEBUG then
					pcall(function()
						local parts = {}

						for name, rec in pairs(result) do
							if type(rec) == "table" then
								local fields = {}

								for k, v in pairs(rec) do
									local tv = type(v)

									if tv == "string" or tv == "number" or tv == "boolean" then
										fields[#fields + 1] = tostring(k) .. "=" .. tostring(v)
									end
								end

								table.sort(fields)
								parts[#parts + 1] = tostring(name) .. ": " .. table.concat(fields, ", ")
							end
						end

						table.sort(parts)
						local text = table.concat(parts, "\n")

						if text ~= list2.dbgLast then
							list2.dbgLast = text
							print("[MM2 ESP] PlayerData:\n" .. text)
						end
					end)
				end
			end

			list2.polling = false
		end)
	end

	list2.getPlayerRole = function(player)
		if not player then
			return nil
		end

		local role = nil

		local function readRec(rec)
			if type(rec) ~= "table" then
				return
			end

			if rec.Role ~= nil and role == nil then
				-- "Hero" (picked up the dropped gun) = sheriff; Infected / Zombies / Survivors ... are mapped too
				role = list2.normRole(rec.Role)
			end

		end

		-- data sources, newest first: server answer (if newer than the last event) -> live event data -> round roster
		-- -> server answer (older)
		local polled = nil

		if type(list2.polledData) == "table" and os.clock() - list2.polledAt < 3 then
			polled = list2.polledData
		end

		if polled and (list2.liveAt or 0) < list2.polledAt then
			readRec(polled[player.Name])
		end

		if type(list2.liveData) == "table" then
			readRec(list2.liveData[player.Name])
		end

		if role == nil then
			local roster = list2.roundRoster()
			readRec(roster and roster[player.Name])
		end

		if role == nil and polled then
			readRec(polled[player.Name])
		end

		local backpack = player:FindFirstChildOfClass("Backpack")
		local character = player.Character
		local hasKnife = (backpack ~= nil and backpack:FindFirstChild("Knife") ~= nil)
			or (character ~= nil and character:FindFirstChild("Knife") ~= nil)
		local hasGun = (backpack ~= nil and backpack:FindFirstChild("Gun") ~= nil)
			or (character ~= nil and character:FindFirstChild("Gun") ~= nil)

		local okInf, infection = pcall(list2.isInfectionRound)

		if okInf and infection then
			-- ZOMBIE MODE: the knife holders are the zombies, the gun holders are survivors.
			-- (This used to report "Murderer" / "Sheriff" here, so zombies got the murderer colour instead of
			-- the zombie colour, and a freshly infected player kept his old Survivor / Innocent role.)
			if role == "Murderer" then
				role = "Zombie"
			elseif hasKnife and (role == nil or role == "Innocent" or role == "Survivor") then
				role = "Zombie"
			elseif hasGun and (role == nil or role == "Innocent") then
				role = "Survivor"
			end
		elseif role == nil or role == "Innocent" then
			if hasKnife then
				role = "Murderer"
			elseif hasGun then
				role = "Sheriff"
			end
		end

		return role
	end

	-- ===== SHARED ROLE API: the one source of truth for roles =====
	-- list2.getPlayerRole(player) is the single "what role is this player" lookup
	-- (live PlayerDataChanged data -> round roster -> Knife/Gun tool check, Hero counts as Sheriff).
	-- Everything below is built on it, and func15 / func16 (who is the murderer / sheriff) use it too, so every
	-- feature in the script (ESP, fling, auto fling, teleports, aim, avoid-murderer, ...) sees the same roles.

	-- is this player dead? game flags (Dead / Killed) or a zero-health Humanoid
	list2.isPlayerDead = function(player)
		if not player then
			return true
		end

		local data = list2.liveData
		local rec = type(data) == "table" and data[player.Name] or nil

		if type(rec) == "table" and (rec.Dead == true or rec.Killed == true) then
			return true
		end

		local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")

		return hum ~= nil and hum.Health <= 0
	end

	-- does this player currently hold the tool (backpack or hands)?
	list2.holdsTool = function(player, toolName)
		if not player then
			return false
		end

		local backpack = player:FindFirstChildOfClass("Backpack")
		local character = player.Character

		return (backpack ~= nil and backpack:FindFirstChild(toolName) ~= nil)
			or (character ~= nil and character:FindFirstChild(toolName) ~= nil)
	end

	list2.isRole = function(player, role)
		if not player then
			return false
		end

		local ok, result = pcall(list2.getPlayerRole, player)

		return ok and result == role
	end

	-- the new mode: a Zombie plays like the murderer (knife, infects / kills), a Survivor plays like the sheriff
	-- (gun, shoots zombies). So everything that asks "is this the murderer / sheriff?" also accepts them.
	list2.isMurderer = function(player)
		return list2.isRole(player, "Murderer") or list2.isRole(player, "Zombie")
	end

	list2.isSheriff = function(player)
		return list2.isRole(player, "Sheriff") or list2.isRole(player, "Survivor")
	end

	-- the player who has this role right now. Several candidates (e.g. a dead old sheriff plus the new Hero who
	-- picked up the gun)? The one actually holding the weapon wins, then the one still alive. Cached for 0.1 s
	-- because many loops in the script ask this every frame.
	list2.roleFindCache = {}

	list2.findRole = function(role)
		local now = os.clock()
		local cached = list2.roleFindCache[role]

		if cached and now - cached.t < 0.1 and (cached.player == nil or cached.player.Parent == Players) then
			return cached.player
		end

		local toolName = (role == "Murderer" and "Knife") or (role == "Sheriff" and "Gun") or nil
		local best, bestScore, bestMe, bestDist = nil, -1, false, math.huge

		local myRoot = localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

		for _, player in ipairs(Players:GetPlayers()) do
			local matches

			if role == "Murderer" then
				matches = list2.isMurderer(player) -- Murderer or Zombie
			elseif role == "Sheriff" then
				matches = list2.isSheriff(player) -- Sheriff or Survivor
			else
				matches = list2.isRole(player, role)
			end

			if matches then
				local score = 0

				if toolName and list2.holdsTool(player, toolName) then
					score = score + 2
				end

				if not list2.isPlayerDead(player) then
					score = score + 1
				end

				-- Zombie / Survivor rounds have MANY players with the same role. Equal score: you win if it is you
				-- (so "am I the murderer / sheriff?" checks work for you), otherwise the closest one to you wins
				-- (so "shoot the murderer" aims at the nearest zombie).
				local isMe = player == localPlayer
				local dist = math.huge
				local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

				if myRoot and root then
					dist = (root.Position - myRoot.Position).Magnitude
				end

				local better = score > bestScore
					or (score == bestScore and ((isMe and not bestMe) or (isMe == bestMe and dist < bestDist)))

				if better then
					best, bestScore, bestMe, bestDist = player, score, isMe, dist
				end
			end
		end

		list2.roleFindCache[role] = { t = now, player = best }

		return best
	end

	list2.getMurderer = function()
		return list2.findRole("Murderer")
	end

	list2.getSheriff = function()
		return list2.findRole("Sheriff")
	end

	list2.roleText2 = function(player)
		local role = list2.getPlayerRole(player)
		local text = role or "Unknown (no round / no data)"

		return text
	end

	list2.ROLE_OK = {
		Innocent = true,
		Sheriff = true,
		Murderer = true,
		Survivor = true,
		Zombie = true,
		Freezer = true,
		Frozen = true,
		Assassin = true,
		Target = true,
	}

	list2.roleText = function()
		local roundRole2 = list2.roundRole and tostring(list2.roundRole) or nil
		local roundEndRole2 = list2.roundEndRole and tostring(list2.roundEndRole) or nil

		if roundRole2 and not list2.ROLE_OK[roundRole2] then
			roundRole2 ..= " (?)"
		end

		if roundEndRole2 and not list2.ROLE_OK[roundEndRole2] then
			roundEndRole2 ..= " (?)"
		end

		if roundRole2 and roundEndRole2 and roundRole2 ~= roundEndRole2 then
			return roundRole2 .. " -> " .. roundEndRole2
		end
		return roundEndRole2 or roundRole2 or "unknown"
	end

	list2.WIN_TEXT = {
		MurdererWin = "Murderer won",
		MurdererDied = "Innocents won",
		SheriffWin = "Sheriff won",
		HeroWin = "Hero won",
		InnocentWin = "Innocents won",
		MurdererLeft = "Murderer left",
		Time = "Time ran out",
		TimeRanOut = "Time ran out",
		Survivors = "Survivors won",
		Zombies = "Zombies won",
		Freezers = "Freezers won",
		Frozen = "Everyone frozen",
	}

	list2.roundSnapshot = function()
		local value89 = list2.myRoundRec()
		if type(value89) ~= "table" then
			return
		end

		if type(value89.Coins) == "number" then
			list2.roundCoinsAuth = value89.Coins
		end

		if value89.Role ~= nil then
			list2.roundEndRole = tostring(value89.Role)

			if list2.roundRole == nil then
				list2.roundRole = list2.roundEndRole
			end
		end

	end

	list2.whRound = function()
		if not list2.whReady() then
			return false, "not sending"
		end
		list2.readCoins()
		list2.readShells()
		local roundCoinsAuth = list2.roundCoinsAuth or list2.roundCoins or 0
		local n4

		if list2.roundLength and list2.roundLastT then
			n4 = math.max(0, math.floor(list2.roundLength - list2.roundLastT))
		else
			n4 = nil

			if list2.roundStart then
				local roundStart = list2.roundStart
				n4 = math.max(0, math.floor(os.clock() - roundStart))
			end
		end

		n4 = n4 and string.format("%dm %02ds", math.floor(n4 / 60), n4 % 60) or "?"
		local num8 = list2.readXP()
		local roundXP0 = num8 and list2.roundXP0
		local n5 = nil

		if roundXP0 then
			n5 = math.max(0, math.floor(num8 - list2.roundXP0))
		end

		local whPost = list2.whPost

		local tbl32 = {
			title = "Round Over.",
			thumb = list2.itemThumb(list2.COIN_ICON),
			body = "Collected: **+" .. list2.comma(roundCoinsAuth) .. "** Coins\n\n**Other Info:**",
		}

		local fields = {}
		local value90 = list2.fld("Coins Balance", list2.comma(list2.coinsTotal))
		local value91 = list2.fld("Played For", n4)
		local value92 = list2.fld("XP Gained", n5 and "+" .. list2.comma(n5) or "?")
		local value93 = list2.fld("Shell Balance", list2.comma(list2.shellsLeft))
		local Role = list2.fld("Role", list2.roleText())
		local fld = list2.fld
		local packed2 = table.pack(list2.comma(list2.readLevel()))
		packed2.n = 2 + packed2.n - 1
		table.move(packed2, 1, packed2.n, 2, packed2)
		packed2[1] = "Current Level"
		local packed3 = table.pack(fld(table.unpack(packed2, 1, packed2.n)))
		fields[1] = value90
		fields[2] = value91
		fields[3] = value92
		fields[4] = value93
		fields[5] = Role

		do
			local values = table.pack(table.unpack(packed3, 1, packed3.n))
			table.move(values, 1, values.n, 6, fields)
		end

		tbl32.fields = fields
		return whPost(tbl32)
	end

	list2.roundBegin = function(roundLength)
		list2.espOrig = nil -- a new round: forget the sheriff of the last one
		if list2.infectionCache then
			list2.infectionCache.t = 0
		end
		list2.espCache = setmetatable({}, { __mode = "k" })
		list2.roundCoins = 0
		list2.roundCoinsAuth = nil
		list2.roundBags = {}
		list2.roundRole = nil
		list2.roundEndRole = nil
		list2.roundWin = nil
			list2.roundLength = roundLength
		list2.roundLastT = roundLength
		list2.roundXP0 = list2.readXP()
		list2.roundStart = os.clock()
		list2.roundLive = true
		list2.roundMode = workspace:GetAttribute("GameMode")

		if getrenv then
			local ok, result = pcall(function()
				return getrenv()._G
			end)

			if ok and type(result) == "table" then
				list2.roundId = result.LastRound
			end
		end

		list2.roundSnapshot()
	end

	list2.roundFinish = function()
		if not list2.roundLive then
			return
		end
		list2.roundLive = false
		list2.roundSnapshot()

		task.spawn(function()
			local now = os.clock()

			while os.clock() - now < 30 do
				local flag74 = (list2.readXP() or 0) ~= (list2.roundXP0 or 0)
				if not (list2.roundWin and flag74) then
					task.wait(0.25)
					continue
				end
				break
			end

			pcall(list2.whRound)
		end)
	end

	task.spawn(function()
		local ReplicatedStorage_ = game:GetService("ReplicatedStorage")
		local roundTimerPart = workspace:WaitForChild("RoundTimerPart", 30)

		if roundTimerPart then
			local num9 = tonumber(roundTimerPart:GetAttribute("Time"))
			local num10 = tonumber(roundTimerPart:GetAttribute("RoundLength"))

			if num9 and num9 > 0 then
				list2.roundBegin(num10)

				if num10 then
					list2.roundStart = os.clock() - math.max(0, num10 - num9)
				end
			end

			list2.conns[#list2.conns + 1] = roundTimerPart:GetAttributeChangedSignal("Time"):Connect(function()
				if not list2.current() then
					return
				end
				local roundLastT = tonumber(roundTimerPart:GetAttribute("Time"))
				if roundLastT == nil then
					return
				end

				if roundLastT > 0 then
					list2.roundLastT = roundLastT
				end

				if roundLastT > 0 and not list2.roundLive then
					list2.roundBegin(tonumber(roundTimerPart:GetAttribute("RoundLength")))
				elseif roundLastT <= 0 and list2.roundLive then
					list2.roundFinish()
				end
			end)
		end

		local remotes = ReplicatedStorage_:FindFirstChild("Remotes")
		remotes = remotes and remotes:FindFirstChild("Gameplay")
		if not remotes then
			return
		end
		local victoryScreen = remotes:FindFirstChild("VictoryScreen")

		if victoryScreen then
			list2.conns[#list2.conns + 1] = victoryScreen.OnClientEvent:Connect(function(param40, roundEndRole, roundWin)
				if not list2.current() then
					return
				end

				if type(roundWin) == "string" then
					list2.roundWin = roundWin
				end

				if type(roundEndRole) == "string" and roundEndRole ~= "" then
					list2.roundEndRole = roundEndRole
				end
			end)
		end

		local coinCollected = remotes:FindFirstChild("CoinCollected")

		if coinCollected then
			list2.conns[#list2.conns + 1] = coinCollected.OnClientEvent:Connect(function(flag75, param41)
				if not list2.current() then
					return
				end
				local num11 = tonumber(param41)

				if num11 then
					list2.roundBags[tostring(flag75 or "Coin")] = num11
					local roundCoins = 0

					for _, roundBag in pairs(list2.roundBags) do
						roundCoins += roundBag
					end

					list2.roundCoins = roundCoins
				end

				list2.roundSnapshot()
			end)
		end

		local playerDataChanged = remotes:FindFirstChild("PlayerDataChanged")

		if playerDataChanged then
			list2.conns[#list2.conns + 1] = playerDataChanged.OnClientEvent:Connect(function()
				if not list2.current() then
					return
				end
				list2.roundSnapshot()
			end)
		end
	end)

	list2.setToggle = function(tbl33, param42, param43)
		list2.sfxQuiet = true
		local flag76 = false

		pcall(function()
			if tbl33 then
				for _, item18 in ipairs({ "SetValue", "Set", "UpdateValue" }) do
					if type(tbl33[item18]) ~= "function" then
						continue
					end

					if pcall(function()
						tbl33[item18](tbl33, param42)
					end) then
						flag76 = true
						return
					end
				end
			end
		end)

		if not flag76 and param43 then
			pcall(param43, param42)
		end

		list2.sfxQuiet = false
		return flag76
	end

	list2.underMapDepth = 15

	list2.underMapCF = function()
		if not obj6 then
			return nil
		end
		local spawns = obj6:FindFirstChild("Spawns")
		local position = nil

		if spawns then
			local value94 = next
			local children, value95 = spawns:GetChildren()
			position = nil

			for _, value96 in value94, children, value95 do
				if value96:IsA("BasePart") then
					position = value96.Position
					break
				else
					position = nil
				end
			end
		end

		if not position then
			local ok, result = pcall(function()
				return obj6:GetPivot()
			end)

			if ok and result then
				position = result.Position
			end
		end

		if not position then
			return nil
		end
		return CFrame.new(position.X, position.Y - list2.underMapDepth, position.Z)
	end

	list2.hideUnderMap = function(obj)
		local num12 = list2.underMapCF()
		if not num12 then
			return false
		end
		func59(true)
		flag50 = true

		if (obj.Position - num12.Position).Magnitude > 5 then
			obj.Velocity = Vector3.zero
			obj.CFrame = num12
		end

		return true
	end

	list2.finishFling = function()
		if not list2.flingWhenDone then
			return
		end

		if list2.flingDoneFired then
			return
		end

		if flag33 then
			return
		end
		local roundCoinsAuth = list2.roundCoinsAuth or list2.roundCoins or 0
		if roundCoinsAuth <= 0 and func57() <= 0 then
			return
		end
		list2.finishEarned = roundCoinsAuth > 0 and roundCoinsAuth or func57()
		local result6 = func15()
		if not result6 or result6 == localPlayer or not result6.Character then
			return
		end
		list2.flingDoneFired = true

		task.spawn(function()
			if flag46 then
				local str23 = " coins. Resetting, then flinging " .. result6.Name .. "..."

				obj2:Notify({
					Title = "Farm Done!",
					Content = "Collected " .. list2.comma(list2.finishEarned) .. str23,
					Duration = 3,
					Icon = "flame",
				})

				local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

				if humanoid and humanoid.Health > 0 then
					humanoid.Health = 0
				end

				local now = tick()
				local flag77

				while true do
					task.wait(0.2)
					local character = localPlayer.Character
					local humanoid2 = character and character:FindFirstChildOfClass("Humanoid")
					flag77 = character ~= nil and humanoid2 ~= nil and humanoid2.Health > 0 and character:FindFirstChild("HumanoidRootPart") ~= nil
					if not (flag77 or tick() - now > 12) then
						continue
					end
					break
				end

				if not flag77 then
					return
				end
				task.wait(0.6)
				result6 = func15()
				if not result6 or result6 == localPlayer or not result6.Character then
					return
				end
			else
				local str24 = " coins. Flinging " .. result6.Name .. "..."

				obj2:Notify({
					Title = "Farm Done!",
					Content = "Collected " .. list2.comma(list2.finishEarned) .. str24,
					Duration = 2,
					Icon = "flame",
				})
			end

			pcall(func27, result6)
		end)
	end

	list2.diedMidRound = false

	list2.conns[#list2.conns + 1] = localPlayer.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid", 5)

		if humanoid then
			list2.conns[#list2.conns + 1] = humanoid.Died:Connect(function()
				local result7 = func15()
				list2.diedMidRound = result7 ~= nil and result7 ~= localPlayer
			end)
		end

		if not list2.diedMidRound then
			return
		end
		list2.diedMidRound = false
		if not list2.flingWhenDone then
			return
		end

		if list2.flingDoneFired then
			return
		end

		task.spawn(function()
			task.wait(1.2)
			if not list2.flingWhenDone or list2.flingDoneFired or flag33 then
				return
			end
			local result8 = func15()
			if not result8 or result8 == localPlayer or not result8.Character then
				return
			end
			list2.flingDoneFired = true

			obj2:Notify({
				Title = "Out Of The Round",
				Content = "Flinging " .. result8.Name .. "...",
				Duration = 3,
				Icon = "flame",
			})

			pcall(func27, result8)
		end)
	end)

	list2.flingAll = function()
		if list2.flingAllRunning then
			list2.flingAllRunning = false
			obj2:Notify({ Title = "Fling All Stopped!", Content = "Cancelled.", Duration = 2, Icon = "power-off" })
			return
		end

		local list14 = {}

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= localPlayer and player.Character then
				list14[#list14 + 1] = player
			end
		end

		if #list14 == 0 then
			obj2:Notify({ Title = "Fling All", Content = "Nobody to fling!", Duration = 2, Icon = "x" })
			return
		end
		list2.flingAllRunning = true

		task.spawn(function()
			obj2:Notify({ Title = "Fling All", Content = "Flinging " .. #list14 .. " players...", Duration = 2, Icon = "flame" })
			local n4 = 0

			for _, item19 in ipairs(list14) do
				if list2.flingAllRunning then
					if item19.Parent and item19.Character then
						pcall(func27, item19)
						local now = tick()

						while flag33 and list2.flingAllRunning and tick() - now < 12 do
							task.wait(0.1)
						end

						n4 += 1
					end

					continue
				end

				break
			end

			if list2.flingAllRunning then
				obj2:Notify({
					Title = "Fling All Done!",
					Content = "Flung " .. n4 .. " players.",
					Duration = 2,
					Icon = "check",
				})
			end

			list2.flingAllRunning = false
		end)
	end

	func50 = function()
		if flag51 then
			return
		end
		flag51 = true

		task.spawn(function()
			while flag46 do
				task.wait(1)

				pcall(function()
					local held = func57()

					if held >= 999 or (list2.farmMode == "Candy" and held >= list2.bagLimit()) then
						local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

						if humanoid then
							humanoid.Health = 0
						end
					end
				end)
			end

			flag51 = false
		end)
	end

	func51 = function()
		flag46 = false
	end

	func52 = function()
		if connection2 then
			return
		end

		connection2 = localPlayer.Idled:Connect(function()
			if not flag47 then
				return
			end

			pcall(function()
				VirtualUser:CaptureController()
				VirtualUser:ClickButton2(Vector2.new())
			end)
		end)
	end

	func53 = function()
		if connection2 then
			connection2:Disconnect()
			connection2 = nil
		end
	end
end

local flag78
flag78 = false
list2.wallbang = false

-- Every gun shot goes through these two. The bullet always LEAVES THE GUN: it starts at the gun's muzzle (the
-- GunRaycastAttachment on your root part, or your right hand if there is none). When a shot has to start somewhere
-- else (through walls / right beside the target) the muzzle itself is moved there first, so the bullet still
-- comes out of the gun, then the muzzle is put back.
list2.gunMuzzle = function(character)
	local hrp = character and character:FindFirstChild("HumanoidRootPart")

	if not hrp then
		return nil
	end

	local attachment = hrp:FindFirstChild("GunRaycastAttachment")

	if attachment then
		return attachment.WorldCFrame, attachment
	end

	local hand = character:FindFirstChild("RightHand")

	return CFrame.new(hand and hand.Position or hrp.Position), nil
end

-- Always-hit-murderer: returns the (lead-predicted) point on the murderer's body, or nil when there is no
-- valid murderer (no round / you are the murderer / he is dead), in which case the original aim is kept.
-- how far (studs) the script will shoot the murderer from. math.huge = no limit.
list2.shootRange = math.huge

-- ===== Whitelist / Blacklist =====
-- white = players that Auto Shoot, Silent Aim (every auto-aimed shot), Triggerbot and Kill Aura never attack
-- black = players that are attacked first
-- Everything lives in list2.wb so it costs no extra locals.
list2.wb = { white = {}, black = {}, friends = false, friendCache = {}, friendBusy = {} }

-- "name1, name2" -> { name1 = true, name2 = true } (lower case; a leading @ is ignored)
list2.wb.parse = function(text)
	local set = {}

	for part in tostring(text or ""):gmatch("[^,;\n]+") do
		local name = part:match("^%s*@?(.-)%s*$")

		if name and name ~= "" then
			set[name:lower()] = true
		end
	end

	return set
end

-- matches the account name or the display name
list2.wb.has = function(set, player)
	if not player then
		return false
	end

	return set[player.Name:lower()] == true or set[tostring(player.DisplayName or ""):lower()] == true
end

list2.wb.active = function()
	local wb = list2.wb

	return wb.friends or next(wb.white) ~= nil or next(wb.black) ~= nil
end

-- asks Roblox once per player (it yields), so the loops below only ever read the cache
list2.wb.queryFriend = function(player)
	local wb = list2.wb

	if not player or player == localPlayer or wb.friendCache[player.UserId] ~= nil or wb.friendBusy[player.UserId] then
		return
	end

	wb.friendBusy[player.UserId] = true

	task.spawn(function()
		local ok, result = pcall(function()
			return localPlayer:IsFriendsWith(player.UserId)
		end)

		wb.friendCache[player.UserId] = ok and result == true
		wb.friendBusy[player.UserId] = nil
	end)
end

list2.wb.isWhite = function(player)
	local wb = list2.wb

	if not player or player == localPlayer then
		return false
	end

	if wb.has(wb.white, player) then
		return true
	end

	if wb.friends then
		local cached = wb.friendCache[player.UserId]

		if cached == nil then
			wb.queryFriend(player)

			return true -- not known yet: protect them until Roblox answers
		end

		return cached
	end

	return false
end

list2.wb.isBlack = function(player)
	return player ~= nil and player ~= localPlayer and list2.wb.has(list2.wb.black, player)
end

-- Who the gun features shoot. Normally that is the murderer (func15); in Zombie rounds it is one of many zombies.
--   * white-listed players are never returned (nil = nobody to shoot, the shot stays a normal shot)
--   * black-listed zombies / murderers come first, otherwise the usual pick is kept
-- Innocents are never picked, even when black-listed: shooting them would only hurt you.
list2.gunTarget = function()
	local default = func15 and func15() or nil
	local wb = list2.wb

	if not wb.active() or default == localPlayer then
		return default
	end

	local pool = {}

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer and list2.isMurderer(player) and not wb.isWhite(player) then
			local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoid.Health > 0 then
				pool[#pool + 1] = player
			end
		end
	end

	if #pool == 0 then
		return nil
	end

	local black = {}

	for _, player in ipairs(pool) do
		if wb.isBlack(player) then
			black[#black + 1] = player
		end
	end

	if #black > 0 then
		pool = black
	end

	for _, player in ipairs(pool) do
		if player == default then
			return default
		end
	end

	local myRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
	local best, bestDist = nil, math.huge

	for _, player in ipairs(pool) do
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		local dist = (myRoot and root) and (root.Position - myRoot.Position).Magnitude or math.huge

		if not best or dist < bestDist then
			best, bestDist = player, dist
		end
	end

	return best
end

list2.murdererAimPoint = function()
	local ok, point = pcall(function()
		local murderer
		if list2.gunTarget then
			murderer = list2.gunTarget()
		else
			murderer = func15 and func15()
		end

		if not murderer or murderer == localPlayer or not murderer.Character then
			return nil
		end

		local humanoid = murderer.Character:FindFirstChildOfClass("Humanoid")

		if not humanoid or humanoid.Health <= 0 then
			return nil
		end

		local root = murderer.Character:FindFirstChild("HumanoidRootPart")

		if not root then
			return nil
		end

		return list2.aimAt(murderer, root) or root.Position
	end)

	return ok and point or nil
end

-- When you stand pressed against a wall the gun's muzzle (GunRaycastAttachment / hand) sits INSIDE the wall, so the
-- bullet hits the wall the moment it leaves the gun, even though the murderer can be seen. If the muzzle is
-- blocked but a spot on your own body has a clear line to the murderer, the shot starts from that spot instead.
-- Returns nil when nothing needs changing (muzzle already clear) or when the murderer really is behind a wall.
list2.freeStart = function(character, startCF)
	local ok, result = pcall(function()
		local hrp = character and character:FindFirstChild("HumanoidRootPart")
		local murderer
		if list2.gunTarget then
			murderer = list2.gunTarget()
		else
			murderer = func15 and func15()
		end
		local mChar = murderer and murderer.Character
		local tHrp = mChar and mChar:FindFirstChild("HumanoidRootPart")

		if not hrp or not tHrp or not startCF then
			return nil
		end

		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { character, mChar }
		params.RespectCanCollide = true
		params.IgnoreWater = true

		local targetPos = tHrp.Position

		local function blocked(from)
			local delta = targetPos - from

			if delta.Magnitude < 0.5 then
				return false
			end

			return workspace:Raycast(from, delta, params) ~= nil
		end

		if not blocked(startCF.Position) then
			return nil
		end

		local base = hrp.Position
		local away = Vector3.new(base.X - targetPos.X, 0, base.Z - targetPos.Z)
		local back = away.Magnitude > 0.1 and away.Unit or Vector3.zero

		local candidates = {
			base,
			base + Vector3.new(0, 1.5, 0),
			base + Vector3.new(0, -1.2, 0),
			base + back * 1,
			base + Vector3.new(0, 1.5, 0) + back * 1,
		}

		for _, point in ipairs(candidates) do
			if not blocked(point) then
				return CFrame.new(point)
			end
		end

		return nil
	end)

	return ok and result or nil
end

list2.fireGun = function(shoot, character, aimPos, startCF, ownOrigin)
	local muzzle, attachment = list2.gunMuzzle(character)
	startCF = startCF or muzzle

	-- every gun shot (Shoot Murderer, Silent Aim, Triggerbot, Auto Shoot, TP Shoot, buttons, keybinds)
	-- passes through here, so overriding the aim point here makes ALL of them hit the murderer directly
	-- ESP dot menu shoots a chosen player, so it switches the murderer redirect off for its own shots
	local murdererPoint = (not list2.fireNoOverride) and list2.murdererAimPoint() or nil

	if murdererPoint then
		aimPos = murdererPoint

		local sa = list2.sa

		-- ownOrigin = the caller (TP Shoot) already chose where the shot starts, so the shared Silent Aim
		-- "Piercing" origin must not replace it
		if not ownOrigin and sa and sa.type == "Piercing" and sa.origin and os.clock() - sa.originT < 0.25 then
			startCF = sa.origin
		end
	end

	if not shoot or not startCF or not aimPos then
		return false
	end

	-- standing flush against a wall: the muzzle is inside it, so start the bullet from a clear spot on the body
	if startCF == muzzle and not list2.fireNoOverride then
		local clearCF = list2.freeStart(character, startCF)

		if clearCF then
			startCF = clearCF
		end
	end

	local moved = attachment and startCF ~= muzzle
	local original = attachment and attachment.CFrame

	if moved then
		pcall(function()
			attachment.WorldCFrame = startCF
		end)
	end

	local ok = pcall(function()
		shoot:FireServer(startCF, CFrame.new(aimPos))
	end)

	if moved then
		task.delay(0.15, function()
			pcall(function()
				attachment.CFrame = original
			end)
		end)
	end

	return ok
end

list2.velTrack = {}
list2.aimLead = 0.16

list2.startVelTracker = function()
	if list2.velConn then
		return
	end

	list2.velConn = RunService.Heartbeat:Connect(function()
		local now = os.clock()

		for _, player in ipairs(Players:GetPlayers()) do
			local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				list2.velTrack[player] = nil
			else
				local num13 = list2.velTrack[player]

				if not num13 then
					list2.velTrack[player] = { p = humanoidRootPart.Position, t = now, v = Vector3.zero }
				elseif now - num13.t >= 0.03 then
					num13.v = (humanoidRootPart.Position - num13.p) / (now - num13.t)
					num13.p = humanoidRootPart.Position
					num13.t = now
				end
			end
		end

		if list2.sa then
			pcall(list2.sa.sample)
		end
	end)
end

list2.stopVelTracker = function()
	if list2.velConn then
		pcall(function()
			list2.velConn:Disconnect()
		end)
	end

	list2.velConn = nil
	list2.velTrack = {}
end

list2.leadTime = function()
	local aimLead = tonumber(_G.__FVL_AIMLEAD) or list2.aimLead

	local ok, result = pcall(function()
		return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
	end)

	local flag79 = ok and type(result) == "number" and result > 0 and result < 1
	local n3 = 0.04

	if flag79 then
		n3 = result
	end

	return math.clamp(n3 + aimLead, 0, 0.3)
end

list2.aimAt = function(obj, part3)
	local humanoid = obj.Character and obj.Character:FindFirstChildOfClass("Humanoid")
	local n3

	if humanoid and humanoid.MoveDirection.Magnitude > 0.1 then
		n3 = humanoid.MoveDirection.Unit * humanoid.WalkSpeed
	else
		n3 = part3.AssemblyLinearVelocity or Vector3.zero

		if n3.Magnitude < 0.5 then
			local flag80 = list2.velTrack[obj]

			if flag80 and flag80.v.Magnitude >= 0.5 then
				n3 = flag80.v
			end
		end
	end

	if n3.Magnitude < 0.5 then
		return part3.Position
	end
	local num14 = list2.leadTime()
	local n4 = part3.Position + Vector3.new(n3.X, 0, n3.Z) * num14
	local n5 = n4 - part3.Position

	if n5.Magnitude > 8 then
		n4 = part3.Position + n5.Unit * 8
	end

	_G.__FVL_AIM = { aim = n4, targetPos = part3.Position, vel = n3, lead = num14, t = os.clock() }
	return n4
end

-- ============================================================================
-- Silent Aim Type (ported from snpware): Default / Dynamic / Piercing
--   Default  = simple velocity lead
--   Dynamic  = ping + intent + turn aware prediction (default)
--   Piercing = Dynamic prediction, but the shot starts BEHIND the target
-- list2.aimAt below uses this; the old lead logic stays as a fallback.
-- ============================================================================
list2.sa = {
	modes = { "Default", "Dynamic", "Piercing" },
	legacy = { Pro = "Dynamic", ["Dynamic 1"] = "Dynamic", Hacker = "Piercing" },
	type = "Dynamic",
	hist = {},
	lastUserId = nil,
	lastVel = Vector3.zero,
	lastJumpTick = 0,
	origin = nil,
	originT = 0,
	overshoot = 4,
	piercingBack = 4,
	TURN_WINDOW = 0.12,
	TURN_MIN_SPEED = 1.5,
	HIST_SPAN = 1,
	tune = {
		pingScale = 1, base = 0.113, minLead = 0.02, maxLead = 0.6,
		airExtra = 0, turnBoost = 0, turnGate = 0.15,
		intentBlend = 0.85, intentBlendAir = 0.5,
		straightScale = 1, turnScale = 1,
		airAimHeight = 5, fallMargin = 2, gravityScale = 1, yBias = 0, floorClamp = 1.2,
	},
	predictors = {},
}

do
	local sa = list2.sa

	local function flat(v)
		return Vector3.new(v.X, 0, v.Z)
	end

	local function safeUnit(v)
		if v.Magnitude < 0.001 then
			return Vector3.zero
		end
		return v.Unit
	end

	sa.normalize = function(v)
		if type(v) == "table" then
			v = v[1] or v.Value
		end
		if type(v) ~= "string" then
			return "Dynamic"
		end
		if sa.legacy[v] then
			return sa.legacy[v]
		end
		for _, m in ipairs(sa.modes) do
			if v == m then
				return v
			end
		end
		return "Dynamic"
	end

	local function turnBetween(a, b)
		if a.Magnitude < sa.TURN_MIN_SPEED or b.Magnitude < sa.TURN_MIN_SPEED then
			return 0
		end
		return 1 - math.clamp(a.Unit:Dot(b.Unit), -1, 1)
	end

	local function velAgo(dt)
		local h = sa.hist
		if #h == 0 then
			return nil
		end
		local now = os.clock()
		if sa.TURN_WINDOW < now - h[#h][1] then
			return nil
		end
		local want = now - dt
		for i = #h, 1, -1 do
			if h[i][1] <= want then
				return Vector3.new(h[i][2], h[i][3], h[i][4])
			end
		end
		return Vector3.new(h[1][2], h[1][3], h[1][4])
	end

	-- called every Heartbeat (from the velocity tracker) to keep the murderer's recent velocity
	sa.sample = function()
		local m = func15 and func15()
		if not m or m == localPlayer then
			return
		end
		local root = m.Character and m.Character:FindFirstChild("HumanoidRootPart")
		if not root then
			return
		end
		local vel = root.AssemblyLinearVelocity
		if sa.lastUserId ~= m.UserId then
			sa.lastUserId = m.UserId
			table.clear(sa.hist)
			sa.lastVel = vel
		end
		if sa.lastVel.Y <= 1 and vel.Y > 20 then
			sa.lastJumpTick = tick()
		end
		sa.lastVel = vel
		local now = os.clock()
		table.insert(sa.hist, { now, vel.X, vel.Y, vel.Z })
		while #sa.hist > 0 and now - sa.hist[1][1] > sa.HIST_SPAN do
			table.remove(sa.hist, 1)
		end
	end

	local function buildState(player, myChar)
		local char = player and player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not (root and hum) then
			return nil
		end
		local vel = root.AssemblyLinearVelocity
		local jumpAge = tick() - sa.lastJumpTick
		local recentJump = jumpAge < 0.18
		local okState, state = pcall(function()
			return hum:GetState()
		end)
		local inAir = okState and (state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall)

		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { char, myChar or localPlayer.Character }
		params.IgnoreWater = true
		local hit = workspace:Raycast(root.Position, Vector3.new(0, -80, 0), params)
		local velPast = velAgo(sa.TURN_WINDOW) or vel
		local standHeight = math.clamp(hum.HipHeight + root.Size.Y * 0.5, 0.5, 8)

		-- Humanoid state / FloorMaterial are unreliable for other players' characters (a murderer standing still
		-- is often reported as "in the air"), so trust the real distance to the floor and the real velocity too.
		local airborne = inAir or hum.FloorMaterial == Enum.Material.Air or recentJump
		local grounded = hit ~= nil and (root.Position.Y - hit.Position.Y) <= standHeight + 1.5 and math.abs(vel.Y) < 8 and not recentJump

		if grounded then
			airborne = false
		end

		return {
			pos = root.Position,
			vel = vel,
			moveDir = hum.MoveDirection,
			walkSpeed = hum.WalkSpeed,
			jumpPower = hum.UseJumpPower and hum.JumpPower or (hum.JumpHeight * 2 * workspace.Gravity) ^ 0.5,
			speed = flat(vel).Magnitude,
			look = flat(root.CFrame.LookVector),
			turn = turnBetween(flat(vel), flat(velPast)),
			jumpAge = jumpAge,
			air = airborne,
			sitting = hum.Sit or hum.PlatformStand,
			floorY = hit and hit.Position.Y or nil,
			standHeight = standHeight,
			ping = localPlayer:GetNetworkPing(),
		}
	end

	sa.predictors.Default = function(st)
		if st.vel.Magnitude == 0 then
			return st.pos, 0
		end
		local d = st.vel.Unit * st.vel.Magnitude / 16.5
		local y = math.clamp(d.Y, -2, 2.65)
		return st.pos + Vector3.new(d.X, y, d.Z / 1.25), 0
	end

	sa.predictors.Dynamic = function(st, tune)
		tune = tune or sa.tune
		if st.sitting then
			return st.pos, 0
		end
		-- standing still: nothing to predict, aim exactly at him (never above his head)
		if not st.air and st.speed < 0.5 and math.abs(st.vel.Y) < 1 then
			return st.pos, 0
		end
		local lead = st.ping * tune.pingScale + tune.base
		if st.air then
			lead += tune.airExtra
		end
		if tune.turnGate < st.turn then
			lead += st.turn * tune.turnBoost
		end
		lead = math.clamp(lead, tune.minLead, tune.maxLead)

		local intent = st.moveDir * (st.walkSpeed > 0 and st.walkSpeed or 16)
		local blend = st.air and tune.intentBlendAir or tune.intentBlend
		local turnT = math.clamp((st.turn - tune.turnGate) / math.max(0.001, 1 - tune.turnGate), 0, 1)
		local scale = tune.straightScale + (tune.turnScale - tune.straightScale) * turnT
		local move = flat(st.vel):Lerp(flat(intent), blend) * lead * scale

		local gravity = workspace.Gravity
		local floorY = st.floorY and (st.floorY + (st.standHeight or 3)) or (st.pos.Y - tune.floorClamp)
		local jp = (st.jumpPower or 0) > 0 and st.jumpPower or 50
		local maxRise = jp * jp / (2 * gravity)
		local y
		if not st.air then
			y = st.pos.Y
		elseif maxRise + tune.fallMargin < st.pos.Y - floorY then
			y = math.max(st.pos.Y + st.vel.Y * lead - 0.5 * gravity * tune.gravityScale * lead * lead, floorY)
		else
			y = floorY + tune.airAimHeight
		end
		return Vector3.new(st.pos.X + move.X, y + tune.yBias, st.pos.Z + move.Z), lead
	end

	sa.predictors.Piercing = function(st, tune)
		return sa.predictors.Dynamic(st, tune)
	end

	local function piercingOrigin(st)
		local dir = flat(st.vel)
		if dir.Magnitude < 1 then
			dir = flat(st.moveDir)
		end
		-- Standing still: velocity and move direction are both zero, which used to put the start of the shot
		-- exactly ON the target (start == aim point = a zero-length shot, so no bullet came out). Use the
		-- direction he is facing instead so the shot always starts a few studs behind him.
		if dir.Magnitude < 0.1 then
			dir = st.look
		end
		if dir.Magnitude < 0.1 then
			dir = Vector3.new(0, 0, -1)
		end
		return CFrame.new(st.pos - safeUnit(dir) * sa.piercingBack)
	end

	local function extend(from, to)
		local d = to - from
		if d.Magnitude <= 0.001 then
			return to
		end
		return from + d + d.Unit * sa.overshoot
	end

	-- returns the aim point for the current Silent Aim Type (nil = let the old logic handle it)
	sa.resolve = function(obj, part3)
		local mode = sa.type
		local myChar = localPlayer.Character
		local st = buildState(obj, myChar)
		if not st then
			return nil
		end
		local muzzle = list2.gunMuzzle(myChar)
		if not muzzle then
			return nil
		end
		local pred, lead = (sa.predictors[mode] or sa.predictors.Dynamic)(st, sa.tune)
		local origin = muzzle
		sa.origin = nil
		if mode == "Piercing" then
			origin = piercingOrigin(st)
			sa.origin = origin
			sa.originT = os.clock()
		end
		local aim = extend(origin.Position, pred)
		-- never send a shot whose start and aim point are the same spot: it has no direction, so no bullet
		if (aim - origin.Position).Magnitude < 1 then
			local fwd = safeUnit(pred - origin.Position)
			if fwd == Vector3.zero then
				fwd = safeUnit(st.look)
			end
			if fwd == Vector3.zero then
				fwd = Vector3.new(0, 0, -1)
			end
			aim = origin.Position + fwd * (sa.overshoot + 1)
		end
		_G.__FVL_AIM = { aim = aim, targetPos = st.pos, vel = st.vel, lead = lead or 0, t = os.clock() }
		return aim
	end
end

list2.aimAtClassic = list2.aimAt

list2.aimAt = function(obj, part3)
	local ok, point = pcall(list2.sa.resolve, obj, part3)
	if ok and point then
		return point
	end
	list2.sa.origin = nil
	return list2.aimAtClassic(obj, part3)
end

-- One shared shot path for "Shoot Murderer" (button / keybind) and "Auto Shoot".
-- Both follow the Silent Aim Type dropdown (list2.sa.type) exactly like Silent Aim does:
--   Default / Dynamic : aim point from that predictor, shot starts at the muzzle, wall rules apply
--   Piercing          : Dynamic aim point, shot starts BEHIND the target, wall check is skipped
-- opts.isClear(tHrp)  -> true when nothing blocks the shot (skipped for Piercing / wallbang / force)
-- opts.wallbang       -> start the shot just above the target (same as the Wallbang toggle)
-- opts.force + opts.forceStart(aim) -> Force Shoot origin (Auto Shoot); Piercing origin wins over it
list2.saShoot = function(shoot, character, murderer, opts)
	opts = opts or {}
	local sa = list2.sa
	local myHrp = character and character:FindFirstChild("HumanoidRootPart")
	local tHrp = murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart")

	if not (shoot and myHrp and tHrp) then
		return false, "missing"
	end

	local piercing = sa.type == "Piercing"

	if opts.isClear and not (piercing or opts.wallbang or opts.force) and not opts.isClear(tHrp) then
		return false, "wall"
	end

	-- aim point comes from the selected Silent Aim Type (this also refreshes sa.origin for Piercing)
	local aim = list2.aimAt(murderer, tHrp) or tHrp.Position

	local startCF
	if piercing and sa.origin and os.clock() - sa.originT < 0.25 then
		startCF = sa.origin
	elseif opts.force and opts.forceStart then
		startCF = opts.forceStart(aim)
	elseif opts.wallbang then
		startCF = CFrame.new(aim + Vector3.new(0, 1.5, 0))
	end

	return list2.fireGun(shoot, character, aim, startCF) == true, nil
end

list2.startVelTracker()
local num15
num15 = nil
COOLDOWN = { Shoot = 3.2, Throw = 2 }
local connection, obj9, connection2, func65, func66, func67, func68, func69, func70, n3
local connection3, tbl34, func71, connection4, func72, tbl35, func73, num16, flag81, flag82
local func74, func75, func76, func77, num17, flag83

do
	local function func78(obj10)
		obj10 = obj10 and obj10:GetAttribute("ThrowSpeed")
		if type(obj10) == "number" and obj10 > 0 then
			return 2 * obj10
		end
		return COOLDOWN.Throw
	end

	local flag84 = false
	local flag85 = false
	connection = nil

	local function func79()
		local ok, result = pcall(function()
			return require(ReplicatedStorage:WaitForChild("ClientServices"):WaitForChild("WeaponService"))
		end)

		if not ok or type(result) ~= "table" or not result.GunFired then
			return nil
		end

		return result.GunFired.OnClientEvent:Connect(function(obj11)
			local character = localPlayer.Character
			if not character or typeof(obj11) ~= "Instance" then
				return
			end

			if not obj11:IsDescendantOf(character) then
				return
			end
			local shoot = COOLDOWN.Shoot
			flag84 = true

			if num15 then
				num15.startCooldown("Shoot", shoot, "SHOOT\nMURDERER")
			end

			task.spawn(function()
				task.wait(shoot)
				flag84 = false
			end)
		end)
	end

	obj9 = func79()

	local function func80()
		local character = localPlayer.Character
		local backpack = localPlayer:FindFirstChild("Backpack")
		return character and character:FindFirstChild("Knife") or backpack and backpack:FindFirstChild("Knife")
	end

	local function func81(flag86)
		flag86 = flag86 and flag86.Animation
		if not flag86 or flag86.Name ~= "ThrowKnife" then
			return
		end

		if flag85 then
			return
		end
		local value97 = func78(func80())
		flag85 = true

		if num15 then
			num15.startCooldown("Throw", value97, "THROW\nKNIFE")
		end

		task.spawn(function()
			task.wait(value97)
			flag85 = false
		end)
	end

	local function func82()
		if connection then
			pcall(function()
				connection:Disconnect()
			end)
		end

		connection = nil
		local character = localPlayer.Character
		character = character and character:FindFirstChildOfClass("Humanoid")
		character = character and character:FindFirstChildOfClass("Animator")
		if not character then
			return
		end
		connection = character.AnimationPlayed:Connect(func81)
	end

	func82()

	connection2 = localPlayer.CharacterAdded:Connect(function(character)
		character:WaitForChild("Humanoid")
		task.wait(0.3)
		func82()
	end)

	func65 = function(instance3, part4)
		if not instance3 or not part4 then
			return false
		end
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { localPlayer.Character }
		raycastParams.RespectCanCollide = true
		local tbl36 = {}

		for _, item20 in ipairs({ "HumanoidRootPart", "Head", "UpperTorso", "Torso", "LeftFoot", "RightFoot" }) do
			local value98 = instance3:FindFirstChild(item20)

			if value98 then
				table.insert(tbl36, value98.Position)
			end
		end

		if #tbl36 == 0 and instance3.PrimaryPart then
			table.insert(tbl36, instance3.PrimaryPart.Position)
		end

		for _, item21 in ipairs(tbl36) do
			local hit = workspace:Raycast(part4.Position, item21 - part4.Position, raycastParams)
			if not hit then
				return true
			end

			if hit.Instance and hit.Instance:IsDescendantOf(instance3) then
				return true
			end

			if hit.Instance and hit.Instance.Transparency > 0.5 then
				return true
			end

			if hit.Instance and hit.Instance.CanCollide == false then
				return true
			end
		end

		return false
	end

	local function func83(player5, num18, flag87)
		local character = player5.Character
		if not character then
			return nil
		end
		local upperTorso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("HumanoidRootPart")
		if not upperTorso then
			return nil
		end
		local position = upperTorso.Position
		local assemblyLinearVelocity = upperTorso.AssemblyLinearVelocity or Vector3.new()
		local character2 = localPlayer.Character
		local upperTorso2

		if character2 then
			upperTorso2 = localPlayer.Character:FindFirstChild("UpperTorso") or localPlayer.Character:FindFirstChild("HumanoidRootPart")
		else
			upperTorso2 = character2
		end

		if not upperTorso2 then
			return position
		end
		local magnitude = (position - upperTorso2.Position).Magnitude
		if magnitude < 1 then
			return position
		end
		return position + assemblyLinearVelocity * math.min(magnitude / num18 * (flag87 or 1), 0.5)
	end

	func66 = function()
		local character = localPlayer.Character
		if not character then
			return nil
		end
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		if not humanoidRootPart then
			return nil
		end
		local huge = math.huge
		local value99 = nil
		local meZombie = list2.isRole(localPlayer, "Zombie") -- a zombie never throws at another zombie

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= localPlayer and player.Character and not (meZombie and list2.isRole(player, "Zombie")) then
				local humanoidRootPart2 = player.Character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 then
					local magnitude = (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude

					if magnitude < huge then
						huge = magnitude
						value99 = player
					end
				end
			end
		end

		return value99
	end

	func67 = function()
		if flag84 then
			return
		end
		flag84 = true

		local function func84(delay2)
			task.spawn(function()
				task.wait(delay2)
				flag84 = false
			end)
		end

		if func16() ~= localPlayer then
			func84(0.5)
			obj2:Notify({ Title = "Not Sheriff!", Content = "You don't have the gun.", Duration = 2, Icon = "x" })
			return
		end

		local result9 = func15()

		if not result9 or not result9.Character then
			obj2:Notify({ Title = "Error!", Content = "No murderer this round!", Duration = 2, Icon = "x" })
			func84(0.5)
			return
		end

		local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not humanoidRootPart then
			func84(0.5)
			return
		end

		if flag78 and not (list2.wallbang or (list2.sa and list2.sa.type == "Piercing")) then
			if not func65(result9.Character, localPlayer.Character:FindFirstChild("RightHand") or humanoidRootPart) then
				obj2:Notify({
					Title = "Wall Detected!",
					Content = "Murderer is behind a wall. Turn off Wall Check to shoot through it.",
					Duration = 3,
					Icon = "shield",
				})

				func84(0.5)
				return
			end
		end

		local gun = localPlayer.Character and localPlayer.Character:FindFirstChild("Gun")

		if not gun then
			local backpack = localPlayer:FindFirstChild("Backpack")
			backpack = backpack and backpack:FindFirstChild("Gun")

			if backpack and localPlayer.Character then
				localPlayer.Character.Humanoid:EquipTool(backpack)
				task.wait(0.1)
				gun = localPlayer.Character:FindFirstChild("Gun")
			end

			if not gun then
				func84(0.5)
				return
			end
		end

		local shoot = gun:FindFirstChild("Shoot")
		if not shoot or not shoot:IsA("RemoteEvent") then
			func84(0.5)
			return
		end
		local gunRaycastAttachment = humanoidRootPart:FindFirstChild("GunRaycastAttachment")
		gunRaycastAttachment = gunRaycastAttachment and gunRaycastAttachment.WorldCFrame or CFrame.new(humanoidRootPart.Position)
		local humanoidRootPart2 = result9.Character:FindFirstChild("HumanoidRootPart")
		if not humanoidRootPart2 then
			func84(0.5)
			return
		end

		if (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude > list2.shootRange then
			obj2:Notify({ Title = "Too Far!", Content = "The murderer is out of range.", Duration = 2, Icon = "x" })
			func84(0.5)
			return
		end

		-- follows the Silent Aim Type dropdown (Default / Dynamic / Piercing)
		local okShot, fired, reason = pcall(list2.saShoot, shoot, localPlayer.Character, result9, { wallbang = list2.wallbang })

		if not okShot then
			warn("Shoot Murderer failed: " .. tostring(fired))
			obj2:Notify({ Title = "Shoot failed", Content = "Could not fire the gun. Try again.", Duration = 2, Icon = "x" })
		elseif fired == false and reason == "wall" then
			obj2:Notify({ Title = "Wall Detected!", Content = "Murderer is behind a wall.", Duration = 2, Icon = "shield" })
		end

		func84(0.35)
	end

	func68 = function()
		if flag85 then
			return
		end
		flag85 = true

		local function func85(delay3)
			task.spawn(function()
				task.wait(delay3)
				flag85 = false
			end)
		end

		if func15() ~= localPlayer then
			obj2:Notify({ Title = "Not Murderer!", Content = "You don't have the knife.", Duration = 2, Icon = "x" })
			func85(0.5)
			return
		end

		local result10 = func66()

		if not result10 or not result10.Character then
			obj2:Notify({ Title = "Error!", Content = "No one nearby to throw at.", Duration = 2, Icon = "x" })
			func85(0.5)
			return
		end

		local rightHand = localPlayer.Character:FindFirstChild("RightHand") or localPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not rightHand then
			func85(0.5)
			return
		end

		if flag78 and not func65(result10.Character, rightHand) then
			obj2:Notify({
				Title = "Wall Detected!",
				Content = result10.Name .. " is behind a wall.",
				Duration = 2,
				Icon = "shield",
			})

			func85(0.5)
			return
		end

		local knife = localPlayer.Character:FindFirstChild("Knife")

		if not knife then
			local backpack = localPlayer:FindFirstChild("Backpack")
			backpack = backpack and backpack:FindFirstChild("Knife")

			if backpack then
				localPlayer.Character.Humanoid:EquipTool(backpack)
				task.wait(0.1)
				knife = localPlayer.Character:FindFirstChild("Knife")
			end
		end

		if not knife then
			func85(0.5)
			return
		end
		local flag88 = func83(result10, 600, 0.95)
		if not flag88 then
			func85(0.5)
			return
		end
		local throw = knife:FindFirstChild("Throw") or knife:FindFirstChild("Events") and knife.Events:FindFirstChild("KnifeThrown")

		if throw and throw:IsA("RemoteEvent") then
			throw:FireServer(CFrame.new(rightHand.Position), CFrame.new(flag88))

			pcall(function()
				local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
				humanoid = humanoid and humanoid:FindFirstChildOfClass("Animator")
				local throwKnife = knife:FindFirstChild("ThrowKnife", true)

				if humanoid and throwKnife then
					humanoid:LoadAnimation(throwKnife):Play(0.1, 6, 1)
				end
			end)

			local value100 = func78(knife)

			if num15 then
				num15.startCooldown("Throw", value100, "THROW\nKNIFE")
			end

			func85(value100)
		else
			func85(0.5)
		end
	end

	-- ===== ULTRA FAST gun grab =====
	-- Settings (change these if you want)
	-- (kept in one table so we don't use up Lua's 200-local limit)
	list2.grab = {
		touchSpam = 40, -- touch fires per part, per attempt (all in the same frame)
		burstTime = 1.5, -- seconds the burst keeps trying after a gun drops
		bursting = false,
		cdrop = nil,
		cparts = nil,
	}

	local cachedDrop = nil
	local autoOn = false
	local burstGrab -- defined after func87

	-- native recursive search (much faster than looping GetDescendants in Lua)
	local function scanDrop()
		local found = Workspace:FindFirstChild("GunDrop", true)

		if found and found.Parent then
			cachedDrop = found
			return found
		end

		cachedDrop = nil
		return nil
	end

	local function func86(forceScan)
		if cachedDrop and cachedDrop.Parent then
			return cachedDrop
		end

		cachedDrop = nil

		if forceScan then
			return scanDrop()
		end

		return nil
	end

	pcall(function()
		list2.conns[#list2.conns + 1] = Workspace.DescendantAdded:Connect(function(descendant)
			if descendant.Name == "GunDrop" and (descendant:IsA("BasePart") or descendant:IsA("Model")) then
				cachedDrop = descendant

				-- react the instant it spawns: nothing here waits for any notification
				if autoOn and burstGrab then
					pcall(burstGrab)
				end
			elseif autoOn and cachedDrop and descendant:IsA("BasePart") and descendant:IsDescendantOf(cachedDrop) then
				-- a part of the drop just arrived: re-read the parts and touch it right now
				list2.grab.cdrop = nil

				if list2.grab.now then
					list2.grab.now()
				end

				if burstGrab then
					pcall(burstGrab)
				end
			end
		end)
	end)

	local function hasGun(character)
		local backpack = localPlayer:FindFirstChildOfClass("Backpack")
		return (character and character:FindFirstChild("Gun")) or (backpack and backpack:FindFirstChild("Gun")) or false
	end

	-- every BasePart of the drop, parts that have a TouchInterest first
	list2.grab.parts = function(drop)
		local parts = {}

		if drop:IsA("BasePart") then
			parts[1] = drop
		end

		for _, descendant in ipairs(drop:GetDescendants()) do
			if descendant:IsA("BasePart") then
				if descendant:FindFirstChild("TouchInterest") then
					table.insert(parts, 1, descendant)
				else
					parts[#parts + 1] = descendant
				end
			end
		end

		return parts
	end

	list2.grab.touch = function(root, parts, times)
		for _ = 1, times do
			for i = 1, #parts do
				local part = parts[i]
				pcall(firetouchinterest, root, part, 0)
				pcall(firetouchinterest, root, part, 1)
			end
		end
	end

	local function func87(forceScan)
		local drop = func86(forceScan ~= false)
		if not drop then
			return false, "nodrop"
		end

		local character = localPlayer.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not root then
			return false, "nochar"
		end

		if hasGun(character) then
			return true
		end

		local parts = list2.grab.cparts
		if list2.grab.cdrop ~= drop or not parts or #parts == 0 then
			parts = list2.grab.parts(drop)
			list2.grab.cdrop = drop
			list2.grab.cparts = parts
		end
		if #parts == 0 then
			return false, "notouch"
		end

		-- Step 1: spam touches from where we stand, same frame, zero waiting
		list2.grab.touch(root, parts, list2.grab.touchSpam)
		if hasGun(character) then
			return true
		end

		if hasGun(localPlayer.Character) then
			return true
		end

		return false, "refused"
	end

	list2.grab.now = function()
		if autoOn and not hasGun(localPlayer.Character) then
			pcall(func87, false)
		end
	end

	-- Hammer the pickup: one attempt right now, then 5 attempts EVERY frame
	-- (Stepped + Heartbeat + RenderStepped + PreSimulation + PostSimulation), all at once, until we have the gun
	burstGrab = function()
		local grab = list2.grab
		if grab.bursting then
			return
		end

		grab.bursting = true
		grab.cdrop = nil -- re-read the drop's parts at the start of every burst

		local conns = {}
		local done = false
		local startedAt = os.clock()

		local function stop()
			done = true
			grab.bursting = false

			for _, conn in ipairs(conns) do
				pcall(function()
					conn:Disconnect()
				end)
			end

			conns = {}
		end

		local function attempt()
			if done then
				return
			end

			if
				not autoOn
				or os.clock() - startedAt > grab.burstTime
				or hasGun(localPlayer.Character)
				or not (cachedDrop and cachedDrop.Parent)
			then
				stop()
				return
			end

			pcall(func87, false)

			if hasGun(localPlayer.Character) then
				stop()
			end
		end

		attempt() -- fire immediately, same frame the gun appeared

		if done then
			return
		end

		conns[1] = RunService.Stepped:Connect(attempt)
		conns[2] = RunService.Heartbeat:Connect(attempt)
		pcall(function()
			conns[3] = RunService.RenderStepped:Connect(attempt)
		end)
		pcall(function()
			conns[4] = RunService.PreSimulation:Connect(attempt)
		end)
		pcall(function()
			conns[5] = RunService.PostSimulation:Connect(attempt)
		end)
	end

	local thread = nil

	func69 = function()
		autoOn = false

		if thread then
			pcall(task.cancel, thread)
			thread = nil
		end
	end

	func70 = function()
		func69()
		autoOn = true
		scanDrop() -- grab a drop that already exists the moment the toggle is switched on

		thread = task.spawn(function()
			while true do
				RunService.Stepped:Wait()

				if cachedDrop and cachedDrop.Parent then
					if not hasGun(localPlayer.Character) then
						burstGrab()
					end
				end

				RunService.Heartbeat:Wait()
			end
		end)
	end

	BOMB_COOLDOWN = 22
	n3 = 0
	connection3 = nil
	tbl34 = {}

	func71 = function()
		local now = tick()

		if now - n3 < BOMB_COOLDOWN then
			obj2:Notify({
				Title = "Cooldown",
				Content = string.format("Bomb jump on cooldown for %.1fs", BOMB_COOLDOWN - now - n3),
				Duration = 2,
				Icon = "clock",
			})

			return
		end

		pcall(function()
			local character = localPlayer.Character
			if not character then
				return
			end
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			if not humanoid or not humanoidRootPart then
				return
			end
			local tool = character:FindFirstChildOfClass("Tool")
			local fakeBomb = character:FindFirstChild("FakeBomb")

			if not fakeBomb then
				fakeBomb = localPlayer:FindFirstChild("Backpack")
				fakeBomb = fakeBomb and fakeBomb:FindFirstChild("FakeBomb")

				if fakeBomb then
					humanoid:EquipTool(fakeBomb)
					task.wait(0.1)
					fakeBomb = character:FindFirstChild("FakeBomb")
				end
			end

			if not fakeBomb then
				local remotes = ReplicatedStorage:FindFirstChild("Remotes")
				local extras = remotes and remotes:FindFirstChild("Extras")
				extras = extras and extras:FindFirstChild("ReplicateToy")

				if extras then
					extras:InvokeServer("FakeBomb")
					task.wait(0.15)
					fakeBomb = character:FindFirstChild("FakeBomb")

					if not fakeBomb then
						local backpack = localPlayer:FindFirstChild("Backpack")

						if backpack and backpack:FindFirstChild("FakeBomb") then
							humanoid:EquipTool(backpack.FakeBomb)
							task.wait(0.1)
							fakeBomb = character:FindFirstChild("FakeBomb")
						end
					end
				end
			end

			if not fakeBomb then
				obj2:Notify({ Title = "No Bomb", Content = "Couldn't get the FakeBomb toy.", Duration = 2, Icon = "x" })
				return
			end
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			task.wait(0.05)
			local remote = fakeBomb:FindFirstChild("Remote")

			if remote then
				local position = humanoidRootPart.Position
				remote:FireServer(CFrame.new(position.X, position.Y - 3, position.Z), 50)
				n3 = tick()

				if num15 then
					num15.startCooldown("Bomb", BOMB_COOLDOWN, "BOMB\nJUMP")
				end
			end

			task.wait(0.1)
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			task.wait(0.1)
			humanoid:UnequipTools()

			if tool and tool ~= fakeBomb and tool.Name ~= "FakeBomb" then
				task.wait(0.1)

				if tool.Parent then
					pcall(function()
						humanoid:EquipTool(tool)
					end)
				end
			end
		end)
	end

	local function func88()
		n3 = 0

		if num15 then
			num15.clearCooldown("Bomb")
		end
	end

	local function func89(obj12)
		if connection3 then
			pcall(function()
				connection3:Disconnect()
			end)
		end

		connection3 = nil
		obj12 = obj12 and obj12:FindFirstChildOfClass("Humanoid")

		if obj12 then
			connection3 = obj12.Died:Connect(func88)
		end
	end

	func89(localPlayer.Character)

	connection4 = localPlayer.CharacterAdded:Connect(function(character)
		character:WaitForChild("Humanoid")
		func88()
		func89(character)
	end)

	local n4 = 4
	local n5 = 14
	local n6 = 0.2
	local flag89 = false
	local n7 = 0

	local function func90(part5, num19, param44, delay4)
		if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
			RunService:BindToRenderStep("FVLWallFlick", Enum.RenderPriority.Camera.Value + 1, function()
				local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
				if not humanoidRootPart then
					return
				end
				local cframe = CFrame.Angles
				humanoidRootPart.CFrame = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + num19) * cframe(0, math.rad(param44), 0)
			end)

			task.wait(delay4)

			pcall(function()
				RunService:UnbindFromRenderStep("FVLWallFlick")
			end)

			pcall(function()
				part5.CFrame = CFrame.lookAt(part5.Position, part5.Position + num19)
			end)
		else
			local cframe = CFrame.lookAt(part5.Position, part5.Position + num19)

			pcall(function()
				part5.CFrame = cframe * CFrame.Angles(0, math.rad(param44), 0)
			end)

			task.wait(delay4)

			pcall(function()
				part5.CFrame = CFrame.lookAt(part5.Position, part5.Position + num19)
			end)
		end
	end

	local function func91(param45, part6)
		local raycastParams = RaycastParams.new()

		if not pcall(function()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		end) then
			raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
		end

		raycastParams.FilterDescendantsInstances = { param45 }

		for _, item22 in ipairs({ part6.CFrame.LookVector, part6.CFrame.RightVector, -part6.CFrame.RightVector }) do
			local hit = Workspace:Raycast(part6.Position, item22 * n4, raycastParams)
			if hit and hit.Instance and hit.Instance.CanCollide then
				return hit
			end
		end

		return nil
	end

	func72 = function()
		local value102 = flag89
		local flag90

		if flag89 then
			flag90 = value102
		else
			flag90 = os.clock() - n7 < n6
		end

		if flag90 then
			return
		end
		local character = localPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		if not humanoidRootPart then
			return
		end

		if not func91(character, humanoidRootPart) then
			obj2:Notify({ Title = "No wall", Content = "Stand next to a wall first.", Duration = 1.5, Icon = "x" })
			return
		end
		flag89 = true

		task.spawn(function()
			local function func92()
				flag89 = false
				n7 = os.clock()
			end

			local character2 = localPlayer.Character
			local humanoidRootPart2 = character2 and character2:FindFirstChild("HumanoidRootPart")
			local humanoid = character2 and character2:FindFirstChildOfClass("Humanoid")
			if not humanoidRootPart2 or not humanoid then
				func92()
				return
			end
			local num20 = func91(character2, humanoidRootPart2)
			if not num20 then
				func92()
				return
			end
			local n8 = -num20.Normal
			local vector = Vector3.new(n8.X, 0, n8.Z)
			if vector.Magnitude < 0.05 then
				func92()
				return
			end
			local unit = vector.Unit

			local function func93()
				pcall(function()
					humanoidRootPart2.AssemblyLinearVelocity = Vector3.new(unit.X * n5, humanoidRootPart2.AssemblyLinearVelocity.Y, unit.Z * n5)
				end)

				humanoid.Jump = true

				pcall(function()
					humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end)
			end

			func93()
			task.wait(0.12)
			func90(humanoidRootPart2, unit, 60, 0.08)
			task.wait(0.03)
			func93()
			func92()
		end)
	end

	num15 = { guis = {}, parts = {}, locked = false }

	ICONS = {
		crosshair = "rbxassetid://134242818164054",
		hand = "rbxassetid://130703864968637",
		sword = "rbxassetid://124448418211665",
		bomb = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=342187115",
		target = "rbxassetid://87563802520297",
		climb = "rbxassetid://100467452364672",
		skull = "rbxassetid://137726256442333",
		plane = "rbxassetid://126985561580989",
		expand = "rbxassetid://137492887754537",
		ghost = "rbxassetid://113822048130017",
		badge = "rbxassetid://116620312917084",
		flingknife = "rbxassetid://584555920",
		flinggun = "http://www.roblox.com/asset/?id=197518111",
		xray = "rbxassetid://340313896",
		invisible = "rbxassetid://6523858394",
		touchfling = "rbxassetid://9525534183",
		lobbytp = "rbxassetid://14832381261",
		maptp = "rbxassetid://14240466919",
	}

	IS_MOBILE = UserInputService.TouchEnabled
	TILE_W = IS_MOBILE and 72 or 84
	TILE_H = TILE_W
	TILE_GAP = 10

	if IS_MOBILE then
		list2.hudScale = 0.7
	end

	COOLDOWN_GREY = Color3.fromRGB(72, 72, 80)

	local function func94(num21, num22)
		return Color3.new(num21.R + (1 - num21.R) * num22, num21.G + (1 - num21.G) * num22, num21.B + (1 - num21.B) * num22)
	end

	num15.bgRest = function()
		return 0.18
	end

	num15.bgHover = function()
		return 0.06
	end

	num15.plateT = function(param46, flag91)
		if param46 then
			flag91 = flag91 and 0.3 or 0.35
			return flag91
		end
		return flag91 and 0.7 or 0.82
	end

	num15.iconC = function(param47, flag92)
		return func94(param47, flag92 and 0.8 or 0.55)
	end

	num15.glyphC = function(obj, param48)
		if obj and obj.raw then
			return Color3.fromRGB(255, 255, 255)
		end
		return num15.iconC(obj and obj.accent, param48)
	end

	num15.labelC = function(param49)
		if param49 then
			return Color3.fromRGB(240, 240, 246)
		end
		return Color3.fromRGB(146, 146, 158)
	end

	num15.labelStrokeT = function()
		return 1
	end

	num15.iconPx = function(param50)
		local num23 = HUDIconSize and HUDIconSize[param50]
		if not num23 then
			return nil
		end
		return math.max(8, math.floor(num23 * TILE_H / 84 + 0.5))
	end

	num15.SLOT_PLATED = IS_MOBILE and 30 or 34
	num15.SLOT_PLAIN = IS_MOBILE and 22 or 25
	num15.SLOT_GAP = 6
	num15.GLYPH_MAX = num15.SLOT_PLAIN + 2 * (num15.SLOT_GAP - 1)

	num15.layout = function(obj, footer)
		local offset = obj.btn.Size.Y.Offset
		obj.footer = footer
		local n8 = 3 * (IS_MOBILE and 8 or 9)
		local slotPlain = num15.plateless() and num15.SLOT_PLAIN or num15.SLOT_PLATED
		local n9 = math.max(slotPlain, math.min(num15.iconPx(obj.name) or 0, num15.GLYPH_MAX))
		local n10 = slotPlain + num15.SLOT_GAP + (n8 + math.ceil((obj.lines or 2) * obj.label.TextSize * obj.label.LineHeight)) / 2
		local n11 = math.floor((offset - n10) / 2)
		local n12 = n11 + n10 - offset - footer - 3

		if n12 > 0 then
			n11 -= math.ceil(n12)
		end

		local n13 = math.max(2, n11)
		obj.plate.Position = UDim2.new(0.5, 0, 0, n13 + math.floor(slotPlain / 2))
		obj.label.AnchorPoint = Vector2.new(0.5, 0)
		obj.label.TextYAlignment = Enum.TextYAlignment.Center
		obj.label.Size = UDim2.new(1, -6, 0, n8)
		obj.label.Position = UDim2.new(0.5, 0, 0, n13 + slotPlain + num15.SLOT_GAP)

		if n9 < obj.icon.Size.Y.Offset then
			obj.icon.Size = UDim2.fromOffset(n9, n9)
		end
	end

	num15.create = function(name2, text, param51, color2, param52, param53)
		if num15.guis[name2] then
			return
		end
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "FVL" .. name2 .. "Button"
		screenGui.ResetOnSpawn = false
		screenGui.IgnoreGuiInset = true
		screenGui.Parent = CoreGui
		local flag93 = IS_MOBILE
		local value103 = TILE_W
		local num24 = TILE_H
		local textButton = Instance.new("TextButton")
		textButton.Size = UDim2.new(0, value103, 0, num24)
		local tbl37 = list2.hudPos[name2]
		textButton.Position = tbl37 and UDim2.new(tbl37[1], tbl37[2], tbl37[3], tbl37[4]) or param51
		textButton.AnchorPoint = Vector2.new(0.5, 0.5)
		textButton.Text = ""
		textButton.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
		textButton.BackgroundTransparency = num15.bgRest()
		textButton.BorderSizePixel = 0
		textButton.AutoButtonColor = false
		textButton.ZIndex = 2
		textButton.Name = name2 .. "Btn"
		textButton.Parent = screenGui
		Instance.new("UICorner", textButton).CornerRadius = UDim.new(0, 16)
		local uiScale = Instance.new("UIScale")
		uiScale.Scale = list2.hudScale or 1
		uiScale.Parent = textButton
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Thickness = 1.5
		uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uiStroke.Color = color2
		uiStroke.Transparency = 0.15
		uiStroke.Parent = textButton
		local frame = Instance.new("Frame")
		frame.Name = "Plate"
		frame.Size = UDim2.new(0, num15.SLOT_PLATED, 0, num15.SLOT_PLATED)
		frame.Position = UDim2.new(0.5, 0, 0, math.floor(num24 * 0.36))
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.BackgroundColor3 = color2
		frame.BackgroundTransparency = num15.plateT(false, false)
		frame.BorderSizePixel = 0
		frame.ZIndex = 3
		frame.Parent = textButton
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 11)
		local uiStroke2 = Instance.new("UIStroke")
		uiStroke2.Thickness = 1
		uiStroke2.Color = color2
		uiStroke2.Transparency = 0.55
		uiStroke2.Parent = frame
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "Icon"
		imageLabel.Size = UDim2.new(0, 23, 0, 23)
		imageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.BackgroundTransparency = 1
		imageLabel.Image = ICONS[param52] or ""
		imageLabel.ImageColor3 = num15.iconC(color2, false)
		imageLabel.ZIndex = 5
		imageLabel.Parent = frame
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "Label"
		textLabel.Size = UDim2.new(1, -10, 0, 24)
		textLabel.Position = UDim2.new(0.5, 0, 1, -7)
		textLabel.AnchorPoint = Vector2.new(0.5, 1)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = text
		textLabel.TextSize = flag93 and 9 or 10
		textLabel.Font = Enum.Font.GothamBold
		textLabel.TextColor3 = num15.labelC(false)
		textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		textLabel.TextStrokeTransparency = num15.labelStrokeT()
		textLabel.TextWrapped = true
		textLabel.LineHeight = 1.1
		textLabel.ZIndex = 6
		textLabel.Parent = textButton
		local n8 = select(2, text:gsub("\n", "")) + 1

		if n8 >= 3 then
			frame.Size = UDim2.new(0, num15.SLOT_PLATED - 6, 0, num15.SLOT_PLATED - 6)
			imageLabel.Size = UDim2.new(0, 20, 0, 20)
			textLabel.TextSize = flag93 and 8 or 9
			textLabel.LineHeight = 1
		end

		local tbl38 = HUDIconArt and HUDIconArt[name2]

		if tbl38 then
			imageLabel.ImageRectOffset = Vector2.new(tbl38[1], tbl38[2])
			imageLabel.ImageRectSize = Vector2.new(tbl38[3], tbl38[3])
			imageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
		end

		local value104 = num15.iconPx(name2)

		if value104 then
			imageLabel.Size = UDim2.new(0, value104, 0, value104)
			frame.ClipsDescendants = false
		end

		num15.parts[name2] = {
			btn = textButton,
			stroke = uiStroke,
			plate = frame,
			plateStroke = uiStroke2,
			icon = imageLabel,
			label = textLabel,
			accent = color2,
			active = false,
			scale = uiScale,
			lines = n8,
			raw = (HUDIconArt and HUDIconArt[name2]) ~= nil,
			name = name2,
		}

		num15.layout(num15.parts[name2], 0)
		pcall(num15.applyDesign, num15.parts[name2])

		local function func95(param54, param55, flag94)
			TweenService:Create(param54, TweenInfo.new(flag94 or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), param55):Play()
		end

		textButton.MouseEnter:Connect(function()
			local flag95 = num15.parts[name2]
			func95(textButton, { BackgroundTransparency = num15.designHover() })
			if flag95 and flag95.cdUntil then
				return
			end

			if not num15.plateless() then
				func95(frame, { BackgroundTransparency = num15.plateT(flag95 and flag95.active, true) })
			end

			func95(textLabel, { TextColor3 = Color3.fromRGB(187, 247, 208) })
		end)

		textButton.MouseLeave:Connect(function()
			local flag96 = num15.parts[name2]
			func95(textButton, { BackgroundTransparency = num15.designRest() })
			if flag96 and flag96.cdUntil then
				return
			end

			if not num15.plateless() then
				func95(frame, { BackgroundTransparency = num15.plateT(flag96 and flag96.active, false) })
			end

			func95(textLabel, { TextColor3 = num15.labelC(flag96 and flag96.active) })
		end)

		local value105 = nil
		local value106 = nil
		local value107 = nil
		local position = nil
		local position2 = nil
		local n9 = 0

		local function func96()
			if value106 then
				return
			end
			local now = os.clock()
			if now - n9 < 0.2 then
				return
			end
			n9 = now
			list2.playSfx("click")
			local hudScale = list2.hudScale or 1
			func95(uiScale, { Scale = hudScale * 0.93 }, 0.06)

			task.delay(0.08, function()
				if uiScale.Parent then
					func95(uiScale, { Scale = hudScale }, 0.16)
				end
			end)

			task.spawn(param53)
		end

		textButton.MouseButton1Click:Connect(func96)
		textButton.TouchTap:Connect(func96)

		textButton.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				value105 = true
				value106 = false
				value107 = input
				position = textButton.Position
				position2 = input.Position
			end
		end)

		num15.parts[name2].dragConn = UserInputService.InputChanged:Connect(function(input)
			if not value105 or num15.locked or not textButton.Parent then
				return
			end

			if input.UserInputType ~= Enum.UserInputType.MouseMovement and input ~= value107 then
				return
			end
			local n10 = input.Position - position2

			if not value106 then
				if math.abs(n10.X) + math.abs(n10.Y) < 6 then
					return
				end
				value106 = true
			end

			textButton.Position = UDim2.new(position.X.Scale, position.X.Offset + n10.X, position.Y.Scale, position.Y.Offset + n10.Y)
		end)

		num15.parts[name2].endConn = UserInputService.InputEnded:Connect(function(input)
			if not value105 or input ~= value107 then
				return
			end
			value105 = false
			value107 = nil

			if value106 then
				local position3 = textButton.Position
				list2.hudPos[name2] = { position3.X.Scale, position3.X.Offset, position3.Y.Scale, position3.Y.Offset }
			end

			task.delay(0.05, function()
				value106 = false
			end)
		end)

		num15.guis[name2] = screenGui
		list2.hudBtns[name2] = textButton
		return textButton, textLabel
	end

	HUDOrder = { "Shoot", "Grab", "Aimbot", "Bomb", "Throw", "WallHop" }
	HUDOrder2 = { "KillAll", "KillSheriff", "Fly", "Noclip", "Xray" }
	list2.HUDOrder3 = { "FlingMurd", "FlingSher" }
	list2.HUDOrder4 = { "TPShoot", "Invis", "TouchFling" }
	list2.HUDOrder5 = { "LobbyTP", "MapTP" }

	-- TP Shoot shared state (used by the Combat tab and the floating buttons)
	list2.TP_POS = { "Front", "Behind", "Above Head", "Below Feet" }
	list2.TP_POS_SHORT = { ["Front"] = "FRONT", ["Behind"] = "BEHIND", ["Above Head"] = "ABOVE", ["Below Feet"] = "BELOW" }
	list2.tpShootPos = "Front"
	list2.tpShootDist = 3
	list2.tpPosText = function(name)
		return "TP SHOOT\nMURDERER"
	end
	tbl35 = {}

	local function func97(list15, param56)
		for i, item23 in ipairs(list15) do
			tbl35[item23] = UDim2.new(0.5, (i - (#list15 + 1) / 2) * (TILE_W + TILE_GAP), 0.25, param56)
		end
	end

	func97(HUDOrder, 0)
	func97(HUDOrder2, TILE_H + TILE_GAP)
	func97(list2.HUDOrder3, (TILE_H + TILE_GAP) * 2)
	func97(list2.HUDOrder4, (TILE_H + TILE_GAP) * 3)
	func97(list2.HUDOrder5, (TILE_H + TILE_GAP) * 4)

	num15.relayout = function()
		local hudScale = list2.hudScale or 1

		local function func98(list16, num25)
			for i, item24 in ipairs(list16) do
				tbl35[item24] = UDim2.new(0.5, (i - (#list16 + 1) / 2) * (TILE_W + TILE_GAP) * hudScale, 0.25, num25 * hudScale)

				if not list2.hudPos[item24] then
					local flag97 = num15.parts[item24]

					if flag97 and flag97.btn then
						flag97.btn.Position = tbl35[item24]
					end
				end
			end
		end

		func98(HUDOrder, 0)
		func98(HUDOrder2, TILE_H + TILE_GAP)
		func98(list2.HUDOrder3, (TILE_H + TILE_GAP) * 2)
		func98(list2.HUDOrder4, (TILE_H + TILE_GAP) * 3)
		func98(list2.HUDOrder5, (TILE_H + TILE_GAP) * 4)
	end

	HUDIcon = {
		Shoot = "crosshair",
		Grab = "hand",
		Throw = "sword",
		Bomb = "bomb",
		Aimbot = "target",
		WallHop = "climb",
		KillAll = "badge",
		Fly = "plane",
		Noclip = "ghost",
		KillSheriff = "skull",
		FlingMurd = "flingknife",
		FlingSher = "flinggun",
		Xray = "xray",
		TPShoot = "crosshair",
		Invis = "invisible",
		TouchFling = "touchfling",
		LobbyTP = "lobbytp",
		MapTP = "maptp",
	}

	HUDIconSize = { Xray = 34, Bomb = 48, FlingMurd = 40, FlingSher = 40, Invis = 40, TouchFling = 40, LobbyTP = 40, MapTP = 40 }
	HUDIconArt = { Xray = { 165, 85, 250 }, Bomb = { 8, 24, 170 }, FlingMurd = { 0, 0, 0 }, FlingSher = { 0, 0, 0 }, Invis = { 0, 0, 0 }, TouchFling = { 0, 0, 0 }, LobbyTP = { 0, 0, 0 }, MapTP = { 0, 0, 0 } }

	HUDAccent = {
		Shoot = Color3.fromHex("#257AF7"),
		Grab = Color3.fromHex("#10C550"),
		Throw = Color3.fromHex("#EF4444"),
		Bomb = Color3.fromHex("#F97316"),
		Aimbot = Color3.fromHex("#2DD4BF"),
		WallHop = Color3.fromHex("#A855F7"),
		KillAll = Color3.fromHex("#DC2626"),
		Fly = Color3.fromHex("#38BDF8"),
		Noclip = Color3.fromHex("#94A3B8"),
		KillSheriff = Color3.fromHex("#DC2626"),
		FlingMurd = Color3.fromHex("#F87171"),
		FlingSher = Color3.fromHex("#60A5FA"),
		Xray = Color3.fromHex("#FACC15"),
		TPShoot = Color3.fromHex("#F43F5E"),
		Invis = Color3.fromHex("#A78BFA"),
		TouchFling = Color3.fromHex("#FB923C"),
		LobbyTP = Color3.fromHex("#34D399"),
		MapTP = Color3.fromHex("#38BDF8"),
	}

	func73 = function()
		-- grab FIRST, notify afterwards (notifications never block the grab)
		local value108, flag98 = func87()

		task.spawn(function()
			if value108 then
				obj2:Notify({ Title = "Gun Grabbed!", Content = "Got the gun!", Duration = 1.5, Icon = "check" })
				return
			end

			local flag99 = false

			for _, value111 in ipairs(Workspace:GetChildren()) do
				if value111:FindFirstChild("CoinAreas") or value111:FindFirstChild("CoinContainer") then
					flag99 = true
					break
				end
			end

			if flag98 == "nochar" then
				obj2:Notify({
					Title = "No Character",
					Content = "Nothing to grab with right now.",
					Duration = 2,
					Icon = "x",
				})
			elseif not flag99 then
				obj2:Notify({
					Title = "Not In A Round",
					Content = "The round is over, so the gun can't be picked up. Wait for the next one.",
					Duration = 3,
					Icon = "clock",
				})
			elseif flag98 == "nodrop" then
				obj2:Notify({
					Title = "No Gun Found!",
					Content = "No gun on the ground right now.",
					Duration = 1.5,
					Icon = "x",
				})
			else
				obj2:Notify({
					Title = "Couldn't Grab It",
					Content = "Found the gun but the pickup didn't land -- move closer and try again.",
					Duration = 2.5,
					Icon = "x",
				})
			end
		end)
	end

	num15.setActive = function(param57, active)
		local flag100 = num15.parts[param57]
		if not flag100 then
			return
		end
		flag100.active = active
		local designNow = num15.designNow and num15.designNow()
		if designNow and designNow.active then
			pcall(designNow.active, flag100, active)
			return
		end

		local function func99(param58, param59)
			TweenService:Create(param58, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), param59):Play()
		end

		func99(flag100.stroke, { Transparency = active and 0 or 0.15 })
		func99(flag100.plate, { BackgroundTransparency = num15.plateT(active, false) })
		func99(flag100.plateStroke, { Transparency = active and 0.15 or 0.55 })
		func99(flag100.icon, { ImageColor3 = num15.glyphC(flag100, active) })
		func99(flag100.label, { TextColor3 = num15.labelC(active) })
	end

	num15.DESIGN = "Default Design"
	num15.DESIGN_LIST = { "Round Design", "Default Design" }
	num15.DESIGN_RENAMED = { Ring = "Round Design", ["Base Bar"] = "Default Design", ["New Style"] = "Default Design" }

	num15.snapDesign = function(obj)
		if obj.base then
			return
		end
		local uiCorner = obj.btn:FindFirstChildOfClass("UICorner")

		obj.base = {
			corner = uiCorner and uiCorner.CornerRadius or UDim.new(0, 16),
			body = obj.btn.BackgroundColor3,
			strokeThk = obj.stroke.Thickness,
			plateSize = obj.plate.Size,
			platePos = obj.plate.Position,
			iconSize = obj.icon.Size,
			labelPos = obj.label.Position,
			labelSize = obj.label.Size,
		}
	end

	num15.stopGlide = function(obj)
		if obj.glideT then
			obj.glideT:Cancel()
			obj.glideT = nil
		end

		if obj.arcT then
			obj.arcT:Cancel()
			obj.arcT = nil
		end
	end

	num15.setNow = function(flag101, param60)
		if not flag101 then
			return
		end
		TweenService:Create(flag101, TweenInfo.new(0.03, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), param60):Play()
	end

	num15.designNow = function()
		return num15.DESIGNS and num15.DESIGNS[num15.DESIGN] or nil
	end

	num15.designRest = function()
		local flag102 = num15.designNow()
		if flag102 and flag102.rest then
			return flag102.rest
		end
		return num15.bgRest()
	end

	num15.designHover = function()
		local flag103 = num15.designNow()
		if flag103 and flag103.hover then
			return flag103.hover
		end
		return num15.bgHover()
	end

	num15.plateless = function()
		local flag104 = num15.designNow()
		return flag104 ~= nil and flag104.plateless == true
	end

	num15.BAR_H = 4
	num15.BAR_DROP = 6
	num15.BAR_INSET = 13

	num15.buildBar = function(obj)
		if obj.track then
			return
		end
		local frame = Instance.new("Frame")
		frame.Name = "Track"
		frame.AnchorPoint = Vector2.new(0.5, 1)
		frame.Position = UDim2.new(0.5, 0, 1, -num15.BAR_DROP)
		frame.Size = UDim2.new(1, -num15.BAR_INSET * 2, 0, num15.BAR_H)
		frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		frame.BackgroundTransparency = 0.86
		frame.BorderSizePixel = 0
		frame.ZIndex = 4
		frame.Parent = obj.btn
		Instance.new("UICorner", frame).CornerRadius = UDim.new(1, 0)
		local frame2 = Instance.new("Frame")
		frame2.Name = "Fill"
		frame2.AnchorPoint = Vector2.new(0, 0.5)
		frame2.Position = UDim2.new(0, 0, 0.5, 0)
		frame2.Size = UDim2.fromScale(0, 1)
		frame2.BackgroundColor3 = obj.accent
		frame2.BorderSizePixel = 0
		frame2.ZIndex = 5
		frame2.Parent = frame
		Instance.new("UICorner", frame2).CornerRadius = UDim.new(1, 0)
		obj.track = frame
		obj.fill = frame2
	end

	num15.RING_INSET = 5
	num15.RING_THICK = 3

	num15.buildRing = function(obj)
		if obj.ring then
			return
		end
		local n8 = obj.btn.Size.Y.Offset - num15.RING_INSET * 2 - num15.RING_THICK
		local frame = Instance.new("Frame")
		frame.Name = "Ring"
		frame.BackgroundTransparency = 1
		frame.Size = UDim2.fromScale(1, 1)
		frame.ZIndex = 4
		frame.Parent = obj.btn
		local frame2 = Instance.new("Frame")
		frame2.Name = "Track"
		frame2.AnchorPoint = Vector2.new(0.5, 0.5)
		frame2.Position = UDim2.fromScale(0.5, 0.5)
		frame2.Size = UDim2.fromOffset(n8, n8)
		frame2.BackgroundTransparency = 1
		frame2.ZIndex = 4
		frame2.Parent = frame
		Instance.new("UICorner", frame2).CornerRadius = UDim.new(1, 0)
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Thickness = num15.RING_THICK
		uiStroke.Color = Color3.fromRGB(255, 255, 255)
		uiStroke.Transparency = 0.88
		uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uiStroke.Parent = frame2
		obj.arcs = {}

		for i, item25 in ipairs({ "Right", "Left" }) do
			local frame3 = Instance.new("Frame")
			frame3.Name = item25 .. "Mask"
			frame3.BackgroundTransparency = 1
			frame3.ClipsDescendants = true
			frame3.Size = UDim2.fromScale(0.5, 1)
			frame3.Position = UDim2.fromScale(item25 == "Right" and 0.5 or 0, 0)
			frame3.ZIndex = 5
			frame3.Parent = frame
			local frame4 = Instance.new("Frame")
			frame4.Name = "Arc"
			frame4.AnchorPoint = Vector2.new(0.5, 0.5)
			frame4.Position = UDim2.new(item25 == "Right" and 0 or 1, 0, 0.5, 0)
			frame4.Size = UDim2.fromOffset(n8, n8)
			frame4.BackgroundTransparency = 1
			frame4.ZIndex = 5
			frame4.Parent = frame3
			Instance.new("UICorner", frame4).CornerRadius = UDim.new(1, 0)
			local uiStroke2 = Instance.new("UIStroke")
			uiStroke2.Thickness = num15.RING_THICK
			uiStroke2.Color = obj.accent
			uiStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			uiStroke2.Parent = frame4
			local uiGradient = Instance.new("UIGradient")
			local numberSequence = NumberSequence.new
			local value112 = NumberSequenceKeypoint.new(0, 0)
			local value113 = NumberSequenceKeypoint.new(0.499, 0)
			local value114 = NumberSequenceKeypoint.new(0.5, 1)
			local new = NumberSequenceKeypoint.new
			local tbl39 = { value112, value113, value114 }

			do
				local values = table.pack(new(1, 1))
				table.move(values, 1, values.n, 4, tbl39)
			end

			uiGradient.Transparency = numberSequence(tbl39)
			uiGradient.Parent = uiStroke2
			obj.arcs[i] = uiGradient
		end

		obj.ringTrack = frame2
		obj.ring = frame
	end

	num15.setRing = function(obj, param61)
		if not obj.arcs then
			return
		end
		num15.stopGlide(obj)
		local n8 = math.clamp(param61, 0, 1) * 360
		obj.arcs[1].Rotation = math.min(n8, 180)
		obj.arcs[2].Rotation = math.clamp(n8, 180, 360)
	end

	num15.resetDesign = function(obj)
		num15.snapDesign(obj)
		local base = obj.base
		local uiCorner = obj.btn:FindFirstChildOfClass("UICorner")

		if uiCorner then
			uiCorner.CornerRadius = base.corner
		end

		obj.btn.BackgroundColor3 = base.body
		obj.btn.ClipsDescendants = false
		obj.stroke.Thickness = base.strokeThk
		local plate = obj.plate
		local platePos = base.platePos
		obj.plate.Size = base.plateSize
		plate.Position = platePos
		obj.plate.BackgroundColor3 = obj.accent
		obj.icon.Size = base.iconSize
		obj.label.Visible = true
		local label = obj.label
		local labelPos = base.labelPos
		local labelSize = base.labelSize
		obj.label.Position = labelPos
		label.Size = labelSize
		obj.footer = 0
		num15.setNow(obj.btn, { BackgroundTransparency = num15.bgRest() })
		num15.setNow(obj.stroke, { Color = obj.accent, Transparency = obj.active and 0 or 0.15 })
		num15.setNow(obj.plate, { BackgroundTransparency = num15.plateT(obj.active, false) })
		num15.setNow(obj.plateStroke, { Transparency = obj.active and 0.15 or 0.55 })
		num15.setNow(obj.icon, { ImageColor3 = num15.glyphC(obj, obj.active) })
		num15.setNow(obj.label, { TextColor3 = num15.labelC(obj.active) })

		if obj.track then
			obj.track.Visible = false
		end

		if obj.fill then
			obj.fill.Visible = false
		end

		if obj.ring then
			obj.ring.Visible = false
		end

		if obj.arcs then
			num15.setRing(obj, 0)
		end
	end

	num15.applyDesign = function(obj)
		if not obj or not obj.btn or not obj.btn.Parent then
			return
		end
		num15.resetDesign(obj)
		local flag105 = num15.designNow()

		if flag105 and flag105.apply then
			pcall(flag105.apply, obj)
		end

		num15.setActive(obj.name, obj.active)
	end

	num15.setDesign = function(param62)
		local designRenamed = num15.DESIGN_RENAMED and num15.DESIGN_RENAMED[param62] or param62

		if not num15.DESIGNS[designRenamed] then
			designRenamed = "Default Design"
		end

		num15.DESIGN = designRenamed
		list2.hudDesign = designRenamed

		for _, value115 in next, num15.parts, nil do
			pcall(num15.applyDesign, value115)
		end
	end

	num15.designSet = function(param63, param64)
		local flag106 = num15.designNow()

		if flag106 and flag106.set then
			pcall(flag106.set, param63, param64)
		end
	end

	num15.designSlide = function(param65, param66)
		local flag107 = num15.designNow()

		if flag107 and flag107.slide then
			pcall(flag107.slide, param65, param66)
		end
	end

	num15.DESIGNS = {
		["Round Design"] = {
			plateless = true,
			rest = 0.12,
			hover = 0.04,
			apply = function(param67)
				local uiCorner = param67.btn:FindFirstChildOfClass("UICorner")

				if uiCorner then
					uiCorner.CornerRadius = UDim.new(1, 0)
				end

				param67.stroke.Thickness = 2
				param67.plate.Position = UDim2.new(0.5, 0, 0.5, 0)
				param67.plate.AnchorPoint = Vector2.new(0.5, 0.5)
				local n8 = num15.iconPx(param67.name) or 26
				param67.icon.Size = UDim2.fromOffset(n8, n8)
				num15.setNow(param67.btn, { BackgroundTransparency = 0.12 })
				num15.setNow(param67.stroke, { Color = param67.accent, Transparency = 0 })
				num15.setNow(param67.plate, { BackgroundTransparency = 1 })
				num15.setNow(param67.plateStroke, { Transparency = 1 })
				num15.setNow(param67.icon, { ImageColor3 = num15.glyphC(param67, param67.active) })
				param67.label.Visible = false
				num15.buildRing(param67)
				param67.ring.Visible = true
				num15.setRing(param67, 0)
			end,
			active = function(flag108, flag109)
				num15.setNow(flag108.stroke, { Transparency = 0 })
				num15.setNow(flag108.icon, { ImageColor3 = num15.glyphC(flag108, flag109) })

				if not flag108.cdUntil then
					num15.setRing(flag108, flag109 and 1 or 0)
				end
			end,
			set = function(param68, param69)
				num15.setRing(param68, param69)
			end,
			slide = function(flag110, num26)
				if not flag110.arcs then
					return
				end
				num15.stopGlide(flag110)
				flag110.arcs[1].Rotation = 180
				flag110.arcs[2].Rotation = 360
				flag110.arcT = TweenService:Create(flag110.arcs[2], TweenInfo.new(num26 / 2, Enum.EasingStyle.Linear), { Rotation = 180 })
				flag110.arcT:Play()
				flag110.glideT = TweenService:Create(flag110.arcs[1], TweenInfo.new(num26 / 2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, num26 / 2), { Rotation = 0 })
				flag110.glideT:Play()
			end,
		},
		["Default Design"] = {
			plateless = true,
			rest = 0.1,
			hover = 0.03,
			apply = function(param70)
				local uiCorner = param70.btn:FindFirstChildOfClass("UICorner")

				if uiCorner then
					uiCorner.CornerRadius = UDim.new(0, 20)
				end

				param70.stroke.Thickness = 1
				local slotPlain = num15.iconPx(param70.name) or num15.SLOT_PLAIN
				param70.icon.Size = UDim2.fromOffset(slotPlain, slotPlain)
				num15.setNow(param70.btn, { BackgroundTransparency = 0.1 })

				num15.setNow(param70.stroke, {
					Color = param70.active and param70.accent or Color3.fromRGB(255, 255, 255),
					Transparency = param70.active and 0.35 or 0.88,
				})

				num15.setNow(param70.plate, { BackgroundTransparency = 1 })
				num15.setNow(param70.plateStroke, { Transparency = 1 })
				local setNow = num15.setNow
				local icon = param70.icon
				local tbl40 = {}
				local color2 = param70.raw and Color3.fromRGB(255, 255, 255)

				if not color2 then
					color2 = func94(param70.accent, param70.active and 0.6 or 0.25)
				end

				tbl40.ImageColor3 = color2
				setNow(icon, tbl40)
				num15.buildBar(param70)
				num15.layout(param70, num15.BAR_H + num15.BAR_DROP)
				param70.track.Visible = true
				param70.fill.Visible = true
				param70.fill.BackgroundColor3 = param70.accent
				num15.stopGlide(param70)
				param70.fill.Size = UDim2.fromScale(param70.active and 1 or 0, 1)
			end,
			active = function(param71, flag111)
				num15.setNow(param71.stroke, { Color = flag111 and param71.accent or Color3.fromRGB(255, 255, 255), Transparency = flag111 and 0.35 or 0.88 })
				local setNow = num15.setNow
				local icon = param71.icon
				local tbl41 = {}
				local color2 = param71.raw and Color3.fromRGB(255, 255, 255)

				if not color2 then
					color2 = func94(param71.accent, flag111 and 0.6 or 0.25)
				end

				tbl41.ImageColor3 = color2
				setNow(icon, tbl41)
				num15.setNow(param71.label, { TextColor3 = num15.labelC(flag111) })

				if param71.fill then
					num15.stopGlide(param71)
					param71.fill.Size = UDim2.fromScale(flag111 and 1 or 0, 1)
				end
			end,
			set = function(flag112, param72)
				if not flag112.fill then
					return
				end
				num15.stopGlide(flag112)
				flag112.fill.Size = UDim2.fromScale(param72, 1)
			end,
			slide = function(flag113, param73)
				if not flag113.fill then
					return
				end
				num15.stopGlide(flag113)
				flag113.fill.Size = UDim2.fromScale(1, 1)
				flag113.glideT = TweenService:Create(flag113.fill, TweenInfo.new(param73, Enum.EasingStyle.Linear), { Size = UDim2.fromScale(0, 1) })
				flag113.glideT:Play()
			end,
		},
	}

	num15.startCooldown = function(param74, cdTotal, text)
		local flag114 = num15.parts[param74]
		if not flag114 or not flag114.label then
			return
		end
		flag114.cdUntil = os.clock() + cdTotal
		flag114.cdTotal = cdTotal
		num15.designSlide(flag114, cdTotal)
		if flag114.cdThread then
			return
		end
		local match = text:match("^[^\n]+") or text

		local function func100(flag115, param75, flag116)
			if not flag115 then
				return
			end
			TweenService:Create(flag115, TweenInfo.new(flag116 or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), param75):Play()
		end

		func100(flag114.stroke, { Color = COOLDOWN_GREY })
		func100(flag114.plateStroke, { Color = COOLDOWN_GREY })
		func100(flag114.plate, { BackgroundColor3 = COOLDOWN_GREY })
		func100(flag114.icon, { ImageColor3 = Color3.fromRGB(124, 124, 134) })
		func100(flag114.label, { TextColor3 = Color3.fromRGB(112, 112, 124) })

		flag114.cdThread = task.spawn(function()
			while true do
				local flag117 = num15.parts[param74]

				if not (not flag117 or not flag117.cdUntil) then
					local n8 = flag117.cdUntil - os.clock()

					if not (n8 <= 0) then
						flag117.label.Text = match .. "\n" .. string.format("%.1fs", n8)
						task.wait(0.05)
						continue
					end
				end

				break
			end

			local value116 = num15.parts[param74]

			if value116 then
				value116.cdUntil = nil
				value116.cdThread = nil
				num15.designSet(value116, 0)

				if value116.active then
					local designNow = num15.designNow and num15.designNow()

					if designNow and designNow.active then
						pcall(designNow.active, value116, true)
					end
				end

				if value116.label then
					value116.label.Text = text
				end

				func100(value116.stroke, { Color = value116.accent })
				func100(value116.plateStroke, { Color = value116.accent })
				func100(value116.plate, { BackgroundColor3 = value116.accent })
				func100(value116.icon, { ImageColor3 = num15.glyphC(value116, value116.active) })
				func100(value116.label, { TextColor3 = num15.labelC(value116.active) })
				func100(value116.plate, { BackgroundTransparency = num15.plateT(value116.active, false) })
			end
		end)
	end

	num15.clearCooldown = function(param76)
		local value117 = num15.parts[param76]

		if value117 then
			value117.cdUntil = nil
		end
	end

	num15.destroy = function(param77)
		local value118 = num15.parts[param77]

		if value118 then
			if value118.dragConn then
				value118.dragConn:Disconnect()
			end

			if value118.endConn then
				value118.endConn:Disconnect()
			end
		end

		local obj13 = num15.guis[param77]

		if obj13 then
			obj13:Destroy()
			num15.guis[param77] = nil
		end

		num15.parts[param77] = nil
	end

	num15.destroyAll = function()
		for k in pairs(num15.guis) do
			num15.destroy(k)
		end
	end

	num16 = {
		enabled = false,
		conn = nil,
		smooth = 1,
		part = "UpperTorso",
		murdererOnly = true,
		wallCheck = false,
		fov = 500,
		leadFactor = 1,
		predictedPosition = function(part7)
			if not part7 then
				return nil
			end
			local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
			if not humanoidRootPart then
				return part7.Position
			end
			return part7.Position + (part7.AssemblyLinearVelocity or Vector3.zero) * math.clamp((humanoidRootPart.Position - part7.Position).Magnitude / 1200 * num16.leadFactor, 0.01, 0.3)
		end,
		getPart = function(instance4)
			if not instance4 then
				return nil
			end
			return instance4:FindFirstChild(num16.part) or instance4:FindFirstChild("UpperTorso") or instance4:FindFirstChild("Torso") or instance4:FindFirstChild("HumanoidRootPart") or instance4:FindFirstChild("Head")
		end,
		alive = function(player6)
			if not player6 or not player6.Character then
				return false
			end
			local humanoid = player6.Character:FindFirstChildOfClass("Humanoid")
			return humanoid ~= nil and humanoid.Health > 0
		end,
		inFov = function(param78)
			if num16.fov >= 500 then
				return true
			end
			local currentCamera = workspace.CurrentCamera
			local value119, flag118 = currentCamera:WorldToViewportPoint(param78)
			if not flag118 then
				return false
			end
			local n8 = currentCamera.ViewportSize / 2
			return (Vector2.new(value119.X, value119.Y) - n8).Magnitude <= num16.fov
		end,
		getTarget = function()
			local result12 = func15()

			if result12 and result12 ~= localPlayer and num16.alive(result12) then
				local flag119 = num16.getPart(result12.Character)

				if flag119 and num16.inFov(flag119.Position) then
					local flag120 = not num16.wallCheck

					if not flag120 then
						flag120 = func65(result12.Character, localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart"))
					end

					if flag120 then
						return result12, flag119
					end
				end
			end

			if num16.murdererOnly then
				return nil, nil
			end
			local currentCamera = workspace.CurrentCamera
			local n8 = currentCamera.ViewportSize / 2
			local huge = math.huge
			local value120 = nil
			local value121 = nil

			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= localPlayer and num16.alive(player) then
					local value122 = num16.getPart(player.Character)

					if value122 then
						local value123, value124 = currentCamera:WorldToViewportPoint(value122.Position)

						if value124 then
							local magnitude = (Vector2.new(value123.X, value123.Y) - n8).Magnitude

							if magnitude <= num16.fov and magnitude < huge then
								local flag121 = not num16.wallCheck
								local value125

								if flag121 then
									value125 = flag121
								else
									value125 = func65(player.Character, localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart"))
								end

								if value125 then
									huge = magnitude
									value120 = player
									value121 = value122
								end
							end
						end
					end
				end
			end

			return value120, value121
		end,
	}

	list2.hasGun = function()
		local character = localPlayer.Character
		return character ~= nil and character:FindFirstChild("Gun") ~= nil
	end

	num16.noGunWarned = false

	num16.warnNoGun = function()
		if num16.noGunWarned then
			return
		end
		num16.noGunWarned = true

		obj2:Notify({
			Title = "No Gun",
			Content = "Aimbot is on but you are not holding a gun - it will start aiming the moment you pick one up.",
			Duration = 4,
			Icon = "clock",
		})
	end

	num16.start = function()
		if num16.conn then
			return
		end

		num16.conn = RunService.RenderStepped:Connect(function()
			if not num16.enabled then
				return
			end

			if not list2.hasGun() then
				num16.warnNoGun()
				return
			end
			num16.noGunWarned = false

			pcall(function()
				local flag122
				flag122, flag122 = num16.getTarget()
				if not flag122 then
					return
				end
				local currentCamera = workspace.CurrentCamera
				if not currentCamera then
					return
				end
				currentCamera.CFrame = currentCamera.CFrame:Lerp(CFrame.new(currentCamera.CFrame.Position, num16.predictedPosition(flag122) or flag122.Position), math.clamp(num16.smooth, 0.01, 1))
			end)
		end)
	end

	num16.stop = function()
		if num16.conn then
			num16.conn:Disconnect()
			num16.conn = nil
		end
	end

	num16.refreshLabel = function()
		if num16.label then
			num16.label.Text = num16.enabled and "AIMBOT\nON" or "AIMBOT\nOFF"
		end

		num15.setActive("Aimbot", num16.enabled)
	end

	num16.set = function(enabled)
		num16.enabled = enabled

		if enabled then
			num16.start()
		else
			num16.stop()
		end

		num16.refreshLabel()

		if num16.toggleRef then
			pcall(function()
				num16.toggleRef:Set(enabled)
			end)
		end

		enabled = enabled and list2.enableSilentAim

		if enabled then
			list2.enableSilentAim()
		end
	end

	flag81 = { aimOn = false, aimConn = nil, aimDisabled = {}, conns = {} }
	flag82 = { enabled = false, conn = nil, delay = 0.18, fov = 60, last = 0 }

	local function func101(player7)
		if not player7 or not player7.Character then
			return false
		end
		local humanoid = player7.Character:FindFirstChildOfClass("Humanoid")
		return humanoid ~= nil and humanoid.Health > 0
	end

	local function func102(childName, list17)
		for _, item26 in ipairs(list17) do
			pcall(function()
				item26:Enable()
			end)
		end

		for i = #list17, 1, -1 do
			list17[i] = nil
		end

		if not getconnections then
			return false
		end

		return (pcall(function()
			local character = localPlayer.Character
			character = character and character:FindFirstChild(childName)
			if not character then
				return
			end

			for _, getconnection in ipairs(getconnections(character.Activated)) do
				getconnection:Disable()
				table.insert(list17, getconnection)
			end
		end))
	end

	local function func103(list18)
		for _, item27 in ipairs(list18) do
			pcall(function()
				item27:Enable()
			end)
		end

		for i = #list18, 1, -1 do
			list18[i] = nil
		end
	end

	local function func104(flag123, param79, callback2, param80)
		local function func105(flag124)
			if not flag124 then
				return
			end

			table.insert(param80, flag124.ChildAdded:Connect(function(child)
				if child.Name == flag123 and child:IsA("Tool") and callback2() then
					task.wait(0.1)
					func102(flag123, param79)
				end
			end))
		end

		func105(localPlayer.Character)

		table.insert(param80, localPlayer.CharacterAdded:Connect(function(character)
			if not callback2() then
				return
			end
			task.wait(1)
			func102(flag123, param79)
			func105(character)
		end))
	end

	func74 = function()
		if flag81.aimConn then
			return
		end
		func102("Gun", flag81.aimDisabled)

		if not getconnections then
			obj2:Notify({
				Title = "Silent Aim",
				Content = "Your executor has no getconnections - the normal shot fires too.",
				Duration = 4,
				Icon = "x",
			})
		end

		func104("Gun", flag81.aimDisabled, function()
			return flag81.aimOn
		end, flag81.conns)

		local function silentShot()
			if not flag81.aimOn then
				return
			end
			local character = localPlayer.Character
			local gun = character and character:FindFirstChild("Gun")
			gun = gun and gun:FindFirstChild("Shoot")
			character = character and character:FindFirstChild("HumanoidRootPart")
			if not gun or not character then
				return
			end
			local result13
			if list2.gunTarget then
				result13 = list2.gunTarget()
			else
				result13 = func15()
			end
			local flag125 = result13 and result13 ~= localPlayer and func101(result13)
			local value126 = nil

			if flag125 then
				local humanoidRootPart = result13.Character:FindFirstChild("HumanoidRootPart")
				local flag126 = humanoidRootPart and (character.Position - humanoidRootPart.Position).Magnitude <= list2.shootRange
				value126 = nil

				if flag126 then
					if flag78 and not (list2.wallbang or (list2.sa and list2.sa.type == "Piercing")) and not func65(result13.Character, character) then
						obj2:Notify({
							Title = "Wall Detected!",
							Content = "Murderer is behind a wall.",
							Duration = 2,
							Icon = "shield",
						})

						value126 = nil
					else
						value126 = list2.aimAt(result13, humanoidRootPart)
					end
				end
			end

			value126 = value126 or list2.mouseAimPoint()
			if not value126 then
				return
			end
			local gunRaycastAttachment = character:FindFirstChild("GunRaycastAttachment")

			if list2.wallbang and flag125 then
				list2.fireGun(gun, localPlayer.Character, value126, CFrame.new(value126 + Vector3.new(0, 1.5, 0)))
			else
				list2.fireGun(gun, localPlayer.Character, value126)
			end
		end

		flag81.aimConn = localPlayer:GetMouse().Button1Down:Connect(silentShot)
	end

	func75 = function()
		if flag81.aimConn then
			pcall(function()
				flag81.aimConn:Disconnect()
			end)

			flag81.aimConn = nil
		end

		func103(flag81.aimDisabled)
		list2.dropConns(flag81.conns)
	end

	list2.enableSilentAim = function()
		if flag81.aimOn then
			return
		end
		flag81.aimOn = true
		func74()
		list2.setToggle(list2.el.silentaim, true)
	end

	flag82.start = function()
		if flag82.conn then
			return
		end

		flag82.conn = RunService.Heartbeat:Connect(function()
			if not flag82.enabled then
				return
			end
			local last = flag82.last
			if tick() - last < flag82.delay then
				return
			end

			pcall(function()
				if func16() ~= localPlayer then
					return
				end
				local character = localPlayer.Character
				local gun = character and character:FindFirstChild("Gun")
				gun = gun and gun:FindFirstChild("Shoot")
				if not gun then
					return
				end
				local result14
				if list2.gunTarget then
					result14 = list2.gunTarget()
				else
					result14 = func15()
				end
				if not result14 or result14 == localPlayer or not func101(result14) then
					return
				end
				local humanoidRootPart = result14.Character:FindFirstChild("HumanoidRootPart")
				local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")
				if not humanoidRootPart or not humanoidRootPart2 then
					return
				end
				local currentCamera = Workspace.CurrentCamera
				local value127, flag127 = currentCamera:WorldToViewportPoint(humanoidRootPart.Position)
				if not flag127 then
					return
				end
				local n8 = currentCamera.ViewportSize / 2
				if flag82.fov < (Vector2.new(value127.X, value127.Y) - n8).Magnitude then
					return
				end

				if flag78 and not (list2.wallbang or (list2.sa and list2.sa.type == "Piercing")) and not func65(result14.Character, humanoidRootPart2) then
					return
				end

				if (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude > list2.shootRange then
					return
				end
				flag82.last = tick()
				local gunRaycastAttachment = humanoidRootPart2:FindFirstChild("GunRaycastAttachment")
				local wallbangAim = list2.aimAt(result14, humanoidRootPart)

				if list2.wallbang then
					list2.fireGun(gun, localPlayer.Character, wallbangAim, CFrame.new(wallbangAim + Vector3.new(0, 1.5, 0)))
				else
					list2.fireGun(gun, localPlayer.Character, wallbangAim)
				end
			end)
		end)
	end

	flag82.stop = function()
		if flag82.conn then
			pcall(function()
				flag82.conn:Disconnect()
			end)

			flag82.conn = nil
		end
	end

	local function func106()
		local character = localPlayer.Character
		if not character then
			return nil
		end
		local knife = character:FindFirstChild("Knife")
		if knife then
			return knife, character
		end
		local backpack = localPlayer:FindFirstChild("Backpack")
		backpack = backpack and backpack:FindFirstChild("Knife")
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if backpack and humanoid then
			humanoid:EquipTool(backpack)
			task.wait(0.1)
			local character2 = localPlayer.Character
			return character2 and character2:FindFirstChild("Knife"), character2
		end

		return nil
	end

	local function func107(player8)
		if not player8 or not player8.Character then
			return false
		end
		local humanoid = player8.Character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			return false
		end
		local obj14, obj15 = func106()
		if not obj14 or not obj15 then
			return false
		end
		local rightHand = obj15:FindFirstChild("RightHand") or obj15:FindFirstChild("HumanoidRootPart")
		if not rightHand then
			return false
		end
		local flag128 = func83(player8, 600, 0.95)
		if not flag128 then
			return false
		end
		local throw = obj14:FindFirstChild("Throw") or obj14:FindFirstChild("Events") and obj14.Events:FindFirstChild("KnifeThrown")
		if not (throw and throw:IsA("RemoteEvent")) then
			return false
		end
		local handle = obj14:FindFirstChild("Handle")
		throw:FireServer(handle and handle.CFrame or CFrame.new(rightHand.Position), CFrame.new(flag128))

		pcall(function()
			local humanoid2 = obj15:FindFirstChildOfClass("Humanoid")
			humanoid2 = humanoid2 and humanoid2:FindFirstChildOfClass("Animator")
			local throwKnife = obj14:FindFirstChild("ThrowKnife", true)

			if humanoid2 and throwKnife then
				humanoid2:LoadAnimation(throwKnife):Play(0.1, 6, 1)
			end
		end)

		return true
	end

	local function func108(list19, param81)
		local character

		if param81 then
			character = localPlayer.Character
			character = character and character:FindFirstChild("Knife")
		else
			character = func106()
		end

		character = character and character:FindFirstChild("Events")
		if not character then
			return 0
		end
		local knifeStabbed = character:FindFirstChild("KnifeStabbed")
		local handleTouched = character:FindFirstChild("HandleTouched")
		if not (knifeStabbed and handleTouched) then
			return 0
		end

		pcall(function()
			knifeStabbed:FireServer()
		end)

		local n8 = 0

		for _, item28 in ipairs(list19) do
			local character2 = item28.Character
			local humanoidRootPart = character2 and (character2:FindFirstChild("HumanoidRootPart") or character2:FindFirstChild("Torso") or character2:FindFirstChildWhichIsA("BasePart"))

			if humanoidRootPart then
				pcall(function()
					handleTouched:FireServer(humanoidRootPart)
				end)

				n8 += 1
			end
		end

		return n8
	end

	local function func109(flag129)
		local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
		local list20 = {}
		-- a Zombie only infects the others: fellow zombies are left alone
		local meZombie = list2.isRole(localPlayer, "Zombie")

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= localPlayer and player.Character and not (meZombie and list2.isRole(player, "Zombie")) then
				local humanoidRootPart2 = player.Character:FindFirstChild("HumanoidRootPart")
				local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

				if humanoidRootPart2 and humanoid and humanoid.Health > 0 then
					local value128 = flag129 and humanoidRootPart
					local flag130 = true

					if value128 then
						flag130 = (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude <= flag129
					end

					if flag130 then
						list20[#list20 + 1] = player
					end
				end
			end
		end

		return list20
	end

	func76 = function(childName2)
		if not childName2 or childName2 == "" then
			obj2:Notify({ Title = "No target", Content = "Pick a player first.", Duration = 2, Icon = "x" })
			return
		end

		if func15() ~= localPlayer then
			obj2:Notify({ Title = "Not Murderer!", Content = "You don't have the knife.", Duration = 2, Icon = "x" })
			return
		end
		local flag131 = Players:FindFirstChild(childName2)
		if not flag131 then
			obj2:Notify({ Title = "Gone", Content = childName2 .. " isn't in the server.", Duration = 2, Icon = "x" })
			return
		end
		local flag132 = func108({ flag131 })

		obj2:Notify({
			Title = flag132 > 0 and "Stabbed" or "Failed",
			Content = flag132 > 0 and "Stabbed " .. childName2 .. "." or "Couldn't reach " .. childName2 .. ".",
			Duration = 2,
			Icon = flag132 > 0 and "check" or "x",
		})
	end

	func77 = function()
		if func15() ~= localPlayer then
			obj2:Notify({ Title = "Not Murderer!", Content = "You don't have the knife.", Duration = 2, Icon = "x" })
			return
		end
		local flag133 = func108(func109(nil))

		obj2:Notify({
			Title = "Kill All",
			Content = ("Stabbed %d player%s."):format(flag133, flag133 == 1 and "" or "s"),
			Duration = 2,
			Icon = "check",
		})
	end

	-- Used by Auto Kill All: same stab messages as the Kill All button, no notification, repeated `times` times
	-- (the target list is built once per call, so a burst is cheap on the client).
	list2.killAllBurst = function(times)
		if func15() ~= localPlayer then
			return 0
		end

		local targets = func109(nil)

		if not targets or #targets == 0 then
			return 0
		end

		local stabbed = 0

		for _ = 1, times do
			stabbed = func108(targets)
		end

		return stabbed
	end

	num17 = {
		on = false,
		conn = nil,
		show = false,
		ball = nil,
		showConn = nil,
		NORMAL = 1.5,
		STEP = 0.1,
		mult = 1,
		radius = 1.5,
		setMult = function(mult)
			num17.mult = mult
			num17.radius = num17.NORMAL * (1 + (mult - 1) * num17.STEP)
		end,
		stop = function()
			if num17.conn then
				pcall(function()
					num17.conn:Disconnect()
				end)
			end

			num17.conn = nil

			if num17.thrownConn then
				pcall(function()
					num17.thrownConn:Disconnect()
				end)
			end

			num17.thrownConn = nil
		end,
		start = function()
			num17.stop()

			num17.conn = localPlayer:GetMouse().Button1Down:Connect(function()
				if not num17.on then
					return
				end

				if func15() ~= localPlayer then
					return
				end
				func108(func109(num17.radius), true)
			end)

			num17.thrownConn = CollectionService:GetInstanceAddedSignal("ThrowingKnife"):Connect(function(part8)
				if not num17.on then
					return
				end

				task.spawn(function()
					local handleLink = part8:WaitForChild("HandleLink", 3)
					handleLink = handleLink and handleLink.Value
					handleLink = handleLink and handleLink.Parent
					local character = localPlayer.Character
					if not (handleLink and character and handleLink:IsDescendantOf(character)) then
						return
					end
					local events = handleLink:FindFirstChild("Events")
					local knifeStabbed = events and events:FindFirstChild("KnifeStabbed")
					local handleTouched = events and events:FindFirstChild("HandleTouched")
					if not (knifeStabbed and handleTouched) then
						return
					end
					local tbl42 = {}

					while part8.Parent and num17.on do
						local position = part8:IsA("BasePart") and part8.Position
						local position2

						if position then
							position2 = position
						else
							position2 = part8:IsA("Model") and part8:GetPivot().Position
						end

						if position2 then
							for _, player in ipairs(Players:GetPlayers()) do
								if player ~= localPlayer and not tbl42[player] and player.Character then
									local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
									local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

									if humanoidRootPart and humanoid and humanoid.Health > 0 and (humanoidRootPart.Position - position2).Magnitude <= num17.radius then
										tbl42[player] = true

										pcall(function()
											knifeStabbed:FireServer()
										end)

										pcall(function()
											handleTouched:FireServer(humanoidRootPart)
										end)
									end
								end
							end
						end

						task.wait(0.05)
					end
				end)
			end)
		end,
		hideBall = function()
			if num17.showConn then
				pcall(function()
					num17.showConn:Disconnect()
				end)
			end

			num17.showConn = nil

			if num17.ball then
				pcall(function()
					num17.ball:Destroy()
				end)
			end

			num17.ball = nil
		end,
		showBall = function()
			num17.hideBall()
			local part = Instance.new("Part")
			part.Name = "FVLHitboxSphere"
			part.Shape = Enum.PartType.Ball
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.CastShadow = false
			part.Material = Enum.Material.Neon
			part.Color = Color3.fromRGB(255, 90, 90)
			part.Transparency = 0.88
			part.Size = Vector3.one * num17.radius * 2
			part.Parent = Workspace.CurrentCamera
			num17.ball = part

			num17.showConn = RunService.RenderStepped:Connect(function()
				if not part.Parent then
					return
				end
				local character = localPlayer.Character
				if not character then
					return
				end
				local position = nil

				for _, item29 in ipairs(CollectionService:GetTagged("ThrowingKnife")) do
					local handleLink = item29:FindFirstChild("HandleLink")
					local flag134 = handleLink and handleLink.Value
					local parent = flag134 and flag134.Parent

					if parent and parent:IsDescendantOf(character) then
						position = item29:IsA("BasePart") and item29.Position or item29:IsA("Model") and item29:GetPivot().Position
						if not position then
							continue
						end
					else
						continue
					end

					break
				end

				if not position then
					position = character:FindFirstChild("Knife")
					position = position and position:FindFirstChild("Handle")
					position = position and position.Position
				end

				if not position then
					position = character:FindFirstChild("HumanoidRootPart")
					position = position and position.Position
				end

				if position then
					part.Size = Vector3.one * num17.radius * 2
					part.CFrame = CFrame.new(position)
				end
			end)
		end,
	}

	flag83 = {
		on = false,
		conn = nil,
		disabled = {},
		conns = {},
		stop = function()
			if flag83.conn then
				pcall(function()
					flag83.conn:Disconnect()
				end)
			end

			flag83.conn = nil
			func103(flag83.disabled)
			list2.dropConns(flag83.conns)
		end,
		start = function()
			if flag83.conn then
				return
			end
			func102("Knife", flag83.disabled)

			if not getconnections then
				obj2:Notify({
					Title = "Silent Throw",
					Content = "Your executor has no getconnections - the normal throw fires too.",
					Duration = 4,
					Icon = "x",
				})
			end

			func104("Knife", flag83.disabled, function()
				return flag83.on
			end, flag83.conns)

			flag83.conn = localPlayer:GetMouse().Button2Down:Connect(function()
				if not flag83.on then
					return
				end

				if func15() ~= localPlayer then
					return
				end
				local result15 = func66()
				if not result15 then
					return
				end
				local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart and flag78 and not func65(result15.Character, humanoidRootPart) then
					obj2:Notify({
						Title = "Wall Detected!",
						Content = result15.Name .. " is behind a wall.",
						Duration = 2,
						Icon = "shield",
					})

					return
				end

				func107(result15)
			end)
		end,
	}
end

local func110

func110 = function()
	local value129 = flag82
	flag81.aimOn = false
	value129.enabled = false
	func75()
	flag82.stop()
	list2.dropConns(flag81.conns)
	num17.on = false
	num17.stop()
	num17.show = false
	num17.hideBall()
	flag83.on = false
	flag83.stop()
end

MM2_GUN_ICON = "rbxassetid://79658449"

CURSORS = {
	Default = MM2_GUN_ICON,
	Paw = "rbxassetid://11767069582",
	Gengar = "rbxassetid://11759293285",
	Bunny = "rbxassetid://1912438810",
	["Hello Kitty"] = "rbxassetid://11351620343",
	["Kitty v2"] = "rbxassetid://11802094220",
	Heart = "rbxthumb://type=Asset&w=420&h=420&id=11722368344",
	Pentagram = "rbxassetid://51838212",
	Star = "rbxassetid://11716559277",
	["Star v2"] = "rbxassetid://11716557686",
	Osu = "rbxassetid://8390115370",
	["Power Star"] = "rbxassetid://1718840561",
	Troll = "rbxassetid://12438907427",
	Cross = "rbxthumb://type=Asset&w=420&h=420&id=14034486267",
	["Pink Star"] = "rbxthumb://type=Asset&w=420&h=420&id=11719595129",
	Kuromi = "rbxthumb://type=Asset&w=420&h=420&id=11893991373",
	["Red Heart"] = "rbxthumb://type=Asset&w=420&h=420&id=11754042886",
	["Green Heart"] = "rbxthumb://type=Asset&w=420&h=420&id=11754039821",
	["Blue Heart"] = "rbxthumb://type=Asset&w=420&h=420&id=11754037423",
	["Yellow Heart"] = "rbxthumb://type=Asset&w=420&h=420&id=11754042019",
	["Heart Cross"] = "rbxassetid://11739569678",
	["Clean Kitty"] = "rbxassetid://11718192673",
	["Pixel Cat"] = "rbxassetid://10878214990",
	["Evil Kitty"] = "rbxassetid://11734940424",
	["Vamp Face"] = "rbxassetid://11734893655",
	["Glowing Circle"] = "rbxassetid://10891594349",
	Bear = "rbxassetid://11722088774",
	["Shoot this guy"] = "rbxassetid://8680062686",
	Barbie = "rbxassetid://11754489642",
	Death = "rbxassetid://12472046162",
	Donut = "rbxassetid://11717104785",
	Cat = "rbxassetid://11722553511",
	["Blue Donut"] = "rbxassetid://11717093063",
}

local flag135, value130, func111, flag136, func112, func113

do
	local n4 = 55
	flag135 = {
		style = "Default",
		onlyWithGun = false,
		size = 50,
		spin = false,
		-- "Center" = crosshair pinned to the middle of the screen (game reticle hidden)
		-- "Finger" = crosshair follows the finger / mouse (original Shift Lock reticle comes back)
		mode = UserInputService.TouchEnabled and "Center" or "Finger",
	}
	local mouse = localPlayer:GetMouse()
	local value131 = nil
	value130 = nil
	local connection5 = nil
	local mouseIconEnabled = UserInputService.MouseIconEnabled

	local function func114()
		return list2.hasGun()
	end

	-- 1x1 fully transparent PNG, used to hide the game's own Shift Lock / gun reticle (Mouse.Icon)
	local blankIconPath = nil
	local function getBlankIcon()
		if blankIconPath then
			return blankIconPath
		end

		pcall(function()
			if writefile and getcustomasset then
				local file = "FVLV2_blank_cursor.png"
				writefile(file, "\137\080\078\071\013\010\026\010\000\000\000\013\073\072\068\082\000\000\000\001\000\000\000\001\008\006\000\000\000\031\021\196\137\000\000\000\011\073\068\065\084\120\156\099\096\000\002\000\000\005\000\001\122\094\171\063\000\000\000\000\073\069\078\068\174\066\096\130")
				local asset = getcustomasset(file)
				if type(asset) == "string" and asset ~= "" then
					blankIconPath = asset
				end
			end
		end)

		blankIconPath = blankIconPath or "rbxasset://textures/blank.png"
		return blankIconPath
	end

	local lastReticleScan = 0
	local reticleBlanked = false
	local savedMouseIcon, savedUISIcon = nil, nil
	local hiddenReticles = {}

	-- puts the game's own Shift Lock reticle back exactly how the game had it
	local function restoreReticle()
		if not reticleBlanked then
			return
		end

		reticleBlanked = false

		for img, transparency in pairs(hiddenReticles) do
			pcall(function()
				if img.Parent then
					img.ImageTransparency = transparency
				end
			end)
		end

		hiddenReticles = {}

		pcall(function()
			UserInputService.MouseIcon = savedUISIcon or ""
		end)

		pcall(function()
			mouse.Icon = savedMouseIcon or (func114() and MM2_GUN_ICON or "")
		end)

		savedMouseIcon, savedUISIcon = nil, nil
	end

	flag135.restoreReticle = restoreReticle

	local function func115()
		restoreReticle()

		if connection5 then
			pcall(function()
				connection5:Disconnect()
			end)

			connection5 = nil
		end

		if value131 then
			pcall(function()
				value131:Destroy()
			end)

			value131 = nil
		end

		value130 = nil
		UserInputService.MouseIconEnabled = mouseIconEnabled

		pcall(function()
			UserInputService.MouseIcon = ""
		end)

		pcall(function()
			mouse.Icon = func114() and MM2_GUN_ICON or ""
		end)
	end

	func111 = function()
		func115()
		if flag135.style == "Default" or not CURSORS[flag135.style] then
			return
		end
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "FVLCrosshair"
		screenGui.ResetOnSpawn = false
		screenGui.IgnoreGuiInset = true
		screenGui.DisplayOrder = 10000
		screenGui.Parent = (gethui and gethui()) or CoreGui
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.BackgroundTransparency = 1
		imageLabel.Image = CURSORS[flag135.style] or CURSORS.Paw
		imageLabel.Size = UDim2.fromOffset(flag135.size, flag135.size)
		imageLabel.ScaleType = Enum.ScaleType.Stretch
		imageLabel.Parent = screenGui
		value131 = screenGui
		value130 = imageLabel

		connection5 = RunService.RenderStepped:Connect(function(deltaTime)
			if not imageLabel.Parent then
				return
			end

			if flag135.spin then
				imageLabel.Rotation = (imageLabel.Rotation + deltaTime * n4) % 360
			elseif imageLabel.Rotation ~= 0 then
				imageLabel.Rotation = 0
			end

			local visible = not flag135.onlyWithGun or func114()
			imageLabel.Visible = visible

			if visible then
				UserInputService.MouseIconEnabled = false
			else
				UserInputService.MouseIconEnabled = mouseIconEnabled
			end

			if visible then
				local currentCamera = workspace.CurrentCamera
				-- Mode picked in the Crosshair tab:
				--   Center = pinned to the middle of the screen, game reticle hidden
				--   Finger = follows the finger / mouse, original Shift Lock reticle is back
				if flag135.mode ~= "Finger" and currentCamera then
					local centre = currentCamera.ViewportSize / 2
					imageLabel.Position = UDim2.fromOffset(centre.X, centre.Y)

					-- Shift Lock draws its own centre reticle through Mouse.Icon (and MM2 puts the gun icon there too).
					-- Blank it every frame so only the chosen crosshair is left in the centre of the screen.
					local blank = getBlankIcon()
					reticleBlanked = true

					pcall(function()
						local cur = mouse.Icon

						if cur ~= blank then
							savedMouseIcon = cur
							mouse.Icon = blank
						end
					end)

					pcall(function()
						local cur = UserInputService.MouseIcon

						if cur ~= blank then
							savedUISIcon = cur
							UserInputService.MouseIcon = blank
						end
					end)

					-- in case the reticle is a normal GUI image instead of the mouse icon, make it invisible
					if os.clock() - lastReticleScan > 2 then
						lastReticleScan = os.clock()

						pcall(function()
							for _, root in ipairs({ localPlayer:FindFirstChildOfClass("PlayerGui"), CoreGui }) do
								for _, d in ipairs(root:GetDescendants()) do
									if d:IsA("ImageLabel") and d ~= imageLabel and type(d.Image) == "string"
										and d.Image:find("MouseLockedCursor", 1, true) then
										if hiddenReticles[d] == nil and d.ImageTransparency < 1 then
											hiddenReticles[d] = d.ImageTransparency
										end

										d.ImageTransparency = 1
									end
								end
							end
						end)
					end
				else
					-- finger mode: give the original Shift Lock reticle back (only does work once, right after switching)
					restoreReticle()

					local mouseLocation = UserInputService:GetMouseLocation()
					imageLabel.Position = UDim2.fromOffset(mouseLocation.X, mouseLocation.Y)
				end
			end
		end)
	end

	flag136 = false

	func112 = function(callback3)
		return function(...)
			if not flag136 then
				return
			end
			return callback3(...)
		end
	end

	func113 = function()
		flag135.style = "Default"
		func115()
	end
end

local tbl43
tbl43 = {}

ICON = {
	teal = Color3.fromHex("#14B8A6"),
	green = Color3.fromHex("#10B981"),
	grey = Color3.fromHex("#94A3B8"),
	purple = Color3.fromHex("#8B5CF6"),
	blue = Color3.fromHex("#3B82F6"),
	yellow = Color3.fromHex("#F59E0B"),
	red = Color3.fromHex("#F43F5E"),
	pink = Color3.fromHex("#EC4899"),
	gold = Color3.fromHex("#FFC107"),
	mono = Color3.fromHex("#E5E7EB"),
	tile = Color3.fromHex("#6E6E7B"),
}

tbl43.combat = obj3:Tab({
	Title = "Combat",
	Icon = "lucide:shield",
	IconColor = ICON.tile,
	IconShape = "Square",
	Border = true,
})

tbl43.crosshair = obj3:Tab({
	Title = "Crosshair",
	Icon = "lucide:crosshair",
	IconColor = ICON.tile,
	IconShape = "Square",
	Border = true,
	Columns = 1, -- one column across the whole tab
})

tbl43.skins = obj3:Tab({
	Title = "Skin Changer",
	Icon = "lucide:sword",
	IconColor = ICON.tile,
	IconShape = "Square",
	Border = true,
	Columns = 1, -- one column across the whole tab
})

do
	local color2 = Color3.new(1, 1, 1)
	local flag137 = false

	local function func116()
		for _, descendant in ipairs(obj3.UIElements.Main:GetDescendants()) do
			if descendant:IsA("TextLabel") and descendant.Text == "Skin Changer" then
				for _, descendant2 in ipairs(descendant.Parent.Parent:GetDescendants()) do
					if descendant2:IsA("ImageLabel") and descendant2.Name == "ImageLabel" and descendant2.ImageColor3 ~= ICON.tile then
						descendant2.ImageColor3 = color2

						descendant2:GetPropertyChangedSignal("ImageColor3"):Connect(function()
							if descendant2.ImageColor3 ~= color2 then
								descendant2.ImageColor3 = color2
							end
						end)

						flag137 = true
					end
				end

				return flag137
			end
		end

		return false
	end

	if not func116() then
		task.spawn(function()
			for i = 1, 30 do
				RunService.RenderStepped:Wait()
				if func116() then
					return
				end
			end
		end)
	end
end

tbl43.buttons = obj3:Tab({
	Title = "Buttons",
	Icon = "lucide:gamepad-directional",
	IconColor = ICON.tile,
	IconShape = "Square",
	Border = true,
})

tbl43.esp = obj3:Tab({
	Title = "ESP",
	Icon = "solar:eye-bold",
	IconColor = ICON.tile,
	IconShape = "Square",
	Border = true,
})

tbl43.fling = obj3:Tab({
	Title = "Fling & Teleport",
	Icon = "solar:bolt-bold",
	IconColor = ICON.tile,
	IconShape = "Square",
	Border = true,
})

tbl43.farm = obj3:Tab({
	Title = "Autofarm",
	Icon = "rbxassetid://107945457428063",
	IconColor = ICON.tile,
	IconShape = "Square",
	Border = true,
})

tbl43.player = obj3:Tab({
	Title = "Player",
	Icon = "solar:user-bold",
	IconColor = ICON.tile,
	IconShape = "Square",
	Border = true,
})

tbl43.maps = obj3:Tab({
	Title = "Maps",
	Icon = "lucide:map",
	IconColor = ICON.tile,
	IconShape = "Square",
	Border = true,
	Columns = 1, -- one column across the whole tab
})

tbl43.visuals = obj3:Tab({
	Title = "Visuals",
	Icon = "lucide:sparkles",
	IconColor = ICON.tile,
	IconShape = "Square",
	Border = true,
})

-- ===== sub-tabs (categories inside each tab) =====
tbl43.combat:SubTabs({
	{ "Sheriff", { "Sheriff — you have the gun", "Auto Shoot (Sheriff)", "Aimlock" } },
	{ "Murderer", { "Murderer — you have the knife", "Knife", "Kill Aura", "Knockback" } },
	{ "Targets", { "Whitelist / Blacklist" } },
})

tbl43.esp:SubTabs({
	{ "ESP", { "ESP", "ESP Colours", "Player Dots" } },
	{ "Chams & Alerts", { "Chams", "Alerts" } },
})

tbl43.fling:SubTabs({
	{ "Target", { "Target Player", "Click Tools" } },
	{ "Teleport", { "Quick Actions", "Lobby & Map" } },
	{ "Roles", { "Player Roles (Live Data)" } },
})

tbl43.farm:SubTabs({
	{ "Farm", { "Coin Autofarm", "Settings" } },
	{ "Boxes & Webhook", { "Auto Open Boxes", "Discord Webhook" } },
})

tbl43.buttons:SubTabs({
	{ "On-Screen", { "On-Screen Buttons", "TP Shoot Button" } },
	{ "Extra", { "Extra Buttons" } },
})

tbl43.player:SubTabs({
	{ "Movement", { "Speeds", "Movement Tricks", "Fun & Movement", "Blink" } },
	{ "Defense", { "Escape & Defense" } },
	{ "Emotes", { "Emotes & Animations", "Spam Emotes" } },
	{ "Beta", { "Beta" } },
})

tbl43.visuals:SubTabs({
	{ "World", { "Extra World", "World Effects", "World & Camera", "Shader", "Shaders", "Performance Mode" } },
	{ "Effects", { "Effects", "Death Effects", "Hit Effects", "Trails", "Auras", "Gun Beam", "Kill Cam" } },
	{ "Local", { "Local", "Client Ghost", "Gun Model" } },
	{ "Sounds", { "Sound Changer", "Gun Sounds", "Custom Sounds" } },
})

list2.timer = { on = false, gui = nil, conns = {}, pos = nil, lastUpdate = 0 }

list2.timer.fmt = function(seconds)
	seconds = math.max(0, math.floor(seconds + 0.5))
	return string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60)
end

list2.timer.destroy = function()
	for _, conn in ipairs(list2.timer.conns) do
		pcall(function()
			conn:Disconnect()
		end)
	end

	list2.timer.conns = {}

	if list2.timer.gui then
		pcall(function()
			list2.timer.gui:Destroy()
		end)

		list2.timer.gui = nil
	end
end

list2.timer.create = function()
	if list2.timer.gui then
		return
	end

	local mobile = UserInputService.TouchEnabled
	local width = mobile and 104 or 124
	local height = mobile and 50 or 58

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "FVLRoundTimer"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = CoreGui

	local frame = Instance.new("Frame")
	frame.Name = "Box"
	frame.Size = UDim2.new(0, width, 0, height)
	frame.Position = list2.timer.pos or list2.hudStart("__timer", UDim2.new(0.5, -width / 2, 0, 70))
	frame.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
	frame.BackgroundTransparency = 0.25
	frame.BorderSizePixel = 0
	frame.Active = true
	frame.Parent = screenGui
	list2.hudBtns["__timer"] = frame

	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 11)

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1
	stroke.Color = Color3.fromRGB(34, 197, 94)
	stroke.Transparency = 0.45
	stroke.Parent = frame

	local big = Instance.new("TextLabel")
	big.Name = "Remaining"
	big.Size = UDim2.new(1, 0, 0, height * 0.58)
	big.Position = UDim2.new(0, 0, 0, 3)
	big.BackgroundTransparency = 1
	big.Text = "----"
	big.TextColor3 = Color3.fromRGB(255, 255, 255)
	big.TextSize = mobile and 24 or 28
	big.Font = Enum.Font.GothamBold
	big.Parent = frame

	local small = Instance.new("TextLabel")
	small.Name = "Info"
	small.Size = UDim2.new(1, 0, 0, height * 0.32)
	small.Position = UDim2.new(0, 0, 1, -height * 0.34)
	small.BackgroundTransparency = 1
	small.Text = "Waiting for round"
	small.TextColor3 = Color3.fromRGB(180, 180, 190)
	small.TextSize = mobile and 10 or 11
	small.Font = Enum.Font.Gotham
	small.Parent = frame

	-- dragging (mouse + touch)
	local drag = { active = false, input = nil, start = nil, origin = nil }

	list2.timer.conns[#list2.timer.conns + 1] = frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			drag.active = true
			drag.start = input.Position
			drag.origin = frame.AbsolutePosition - screenGui.AbsolutePosition

			list2.timer.conns[#list2.timer.conns + 1] = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					drag.active = false
					list2.timer.pos = frame.Position
				end
			end)
		end
	end)

	list2.timer.conns[#list2.timer.conns + 1] = frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			drag.input = input
		end
	end)

	list2.timer.conns[#list2.timer.conns + 1] = UserInputService.InputChanged:Connect(function(input)
		if not drag.active or input ~= drag.input then
			return
		end

		local delta = input.Position - drag.start
		local bounds = screenGui.AbsoluteSize
		local x = math.clamp(drag.origin.X + delta.X, 0, math.max(0, bounds.X - width))
		local y = math.clamp(drag.origin.Y + delta.Y, 0, math.max(0, bounds.Y - height))

		frame.Position = UDim2.fromOffset(x, y)
	end)

	-- live update
	list2.timer.conns[#list2.timer.conns + 1] = RunService.Heartbeat:Connect(function()
		local now = os.clock()

		if now - list2.timer.lastUpdate < 0.2 then
			return
		end

		list2.timer.lastUpdate = now

		if not list2.roundLive or not list2.roundLastT then
			big.Text = "----"
			big.TextColor3 = Color3.fromRGB(255, 255, 255)
			small.Text = "Waiting for round"
			stroke.Color = Color3.fromRGB(120, 120, 130)
			return
		end

		local remaining = list2.roundLastT
		local elapsed

		if list2.roundLength then
			elapsed = math.max(0, list2.roundLength - remaining)
		elseif list2.roundStart then
			elapsed = math.max(0, now - list2.roundStart)
		else
			elapsed = 0
		end

		big.Text = list2.timer.fmt(remaining)
		small.Text = "Elapsed " .. list2.timer.fmt(elapsed)

		local color

		if remaining <= 20 then
			color = Color3.fromRGB(239, 68, 68)
		elseif remaining <= 60 then
			color = Color3.fromRGB(250, 204, 21)
		else
			color = Color3.fromRGB(34, 197, 94)
		end

		big.TextColor3 = color
		stroke.Color = color
	end)

	list2.timer.gui = screenGui
end

tbl43.visuals:Section({ Title = "Sound Changer" })

tbl43.visuals:Toggle({
	Title = "Error Sound",
	Flag = "Toggle_Sound_Errors",
	Desc = "A cue when something fails or gets refused.",
	Type = "Toggle",
	Value = true,
	Callback = function(error_)
		list2.sfxOn.error = error_
	end,
})

tbl43.visuals:Toggle({
	Title = "Gun Drop Sound",
	Flag = "Toggle_Sound_Gun_Drop",
	Desc = "A cue when the sheriff dies and the gun drops. Useful with the window closed.",
	Type = "Toggle",
	Value = true,
	Callback = function(gun)
		list2.sfxOn.gun = gun
	end,
})

tbl43.visuals:Toggle({
	Title = "Button Click Sound",
	Flag = "Toggle_Sound_Button_Click",
	Desc = "A click when you press an on-screen button.",
	Type = "Toggle",
	Value = true,
	Callback = function(click)
		list2.sfxOn.click = click
	end,
})

tbl43.visuals:Toggle({
	Title = "Toggle Sound",
	Flag = "Toggle_Sound_Switches",
	Desc = "A click when you flip a switch in the menu.",
	Type = "Toggle",
	Value = true,
	Callback = function(toggle)
		list2.sfxOn.toggle = toggle

		if toggle and list2.sfxReady and not list2.sfxQuiet then
			list2.playSfx("toggle")
		end
	end,
})

list2.myRole = function()
	-- shared role lookup first (same data every other feature uses)
	local okShared, shared = pcall(list2.getPlayerRole, localPlayer)

	if okShared and shared then
		return shared
	end

	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	remotes = remotes and remotes:FindFirstChild("Extras")
	local getPlayerData = remotes and remotes:FindFirstChild("GetPlayerData")
	if not getPlayerData then
		return nil
	end

	local ok, result = pcall(function()
		return getPlayerData:InvokeServer()
	end)

	if not ok or type(result) ~= "table" then
		return nil
	end
	local entry4 = result[localPlayer.Name]
	return entry4 and entry4.Role or nil
end

tbl43.troll = obj3:Tab({
	Title = "Troll & Fun",
	Icon = "rbxassetid://76699723672654",
	IconColor = ICON.tile,
	IconShape = "Square",
	Border = true,
})

tbl43.troll:SubTabs({
	{ "Players", { "Follow Player", "Friend", "Jerk Off" } },
	{ "Fun", { "Bouncy Mode", "Block Sheriff Gun" } },
	{ "Fake", { "Fake Avatar", "Fake Lag", "Fake Knife" } },
})

do
	local RS = game:GetService("RunService")
	local troll = {
		follow = false,
		shield = false,
		followName = nil,
		followDist = 4,
		followMode = "Behind",
		stateChar = nil,
		shieldDist = 3,
		tracks = {},
		animate = nil,
		mimicChar = nil,
	}

	local function plist()
		local t = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= localPlayer then
				t[#t + 1] = p.Name
			end
		end
		return t
	end

	local function pick(v)
		if type(v) == "table" then
			v = v[1] or v.Value
		end
		return v and tostring(v) or nil
	end

	local function hrpOf(p)
		local c = p and p.Character
		return c and c:FindFirstChild("HumanoidRootPart"), c
	end

	local function stopMimic()
		for _, tr in pairs(troll.tracks) do
			pcall(function()
				tr:Stop(0.1)
				tr:Destroy()
			end)
		end
		troll.tracks = {}

		if troll.animate then
			pcall(function()
				troll.animate.Disabled = false
			end)
			troll.animate = nil
		end

		troll.mimicChar = nil
	end

	local function mimic(targetChar, myChar)
		local myHum = myChar:FindFirstChildOfClass("Humanoid")
		local tHum = targetChar:FindFirstChildOfClass("Humanoid")
		if not myHum or not tHum then
			return
		end

		local myAnim = myHum:FindFirstChildOfClass("Animator")
		local tAnim = tHum:FindFirstChildOfClass("Animator")
		if not myAnim or not tAnim then
			return
		end

		-- character changed (respawn): reset, and silence our own Animate script + tracks
		if troll.mimicChar ~= myChar then
			stopMimic()
			troll.mimicChar = myChar

			local anim = myChar:FindFirstChild("Animate")
			if anim and anim:IsA("LocalScript") then
				troll.animate = anim
				anim.Disabled = true
			end

			for _, tr in ipairs(myAnim:GetPlayingAnimationTracks()) do
				pcall(function()
					tr:Stop(0)
				end)
			end
		end

		local seen = {}

		for _, tr in ipairs(tAnim:GetPlayingAnimationTracks()) do
			local a = tr.Animation
			local id = a and a.AnimationId

			if id and id ~= "" then
				seen[id] = true
				local mine = troll.tracks[id]

				if not mine then
					local ok, loaded = pcall(function()
						local inst = Instance.new("Animation")
						inst.AnimationId = id
						return myAnim:LoadAnimation(inst)
					end)

					if ok and loaded then
						loaded.Priority = tr.Priority
						loaded.Looped = tr.Looped
						loaded:Play(0.1, math.max(tr.WeightCurrent, 0.01), tr.Speed)
						troll.tracks[id] = loaded
						mine = loaded
					end
				end

				if mine then
					pcall(function()
						mine:AdjustSpeed(tr.Speed)
						mine:AdjustWeight(math.max(tr.WeightCurrent, 0.01), 0.05)

						if math.abs(mine.TimePosition - tr.TimePosition) > 0.2 then
							mine.TimePosition = tr.TimePosition
						end

						if not mine.IsPlaying then
							mine:Play(0.1, math.max(tr.WeightCurrent, 0.01), tr.Speed)
						end
					end)
				end
			end
		end

		for id, mine in pairs(troll.tracks) do
			if not seen[id] then
				pcall(function()
					mine:Stop(0.15)
					mine:Destroy()
				end)
				troll.tracks[id] = nil
			end
		end
	end

	-- Where to sit relative to the target's HumanoidRootPart.
	-- dist = 0 puts us exactly inside the target's body.
	-- Only the target's facing direction (yaw) is used, so we always stay
	-- upright even if the target is tilted or lying down.
	local function followCF(tHrp, mode, dist)
		local look = tHrp.CFrame.LookVector
		local flat = Vector3.new(look.X, 0, look.Z)
		if flat.Magnitude < 0.01 then
			local up = tHrp.CFrame.UpVector
			flat = Vector3.new(up.X, 0, up.Z)
		end
		if flat.Magnitude < 0.01 then
			flat = Vector3.new(0, 0, -1)
		end

		local pos = tHrp.Position
		local yaw = CFrame.lookAt(Vector3.zero, flat.Unit)

		-- lying on our back when above the head / under the feet
		local pose = CFrame.Angles(math.rad(90), 0, 0)

		if mode == "Above Head" then
			return CFrame.new(pos + Vector3.new(0, dist, 0)) * yaw * pose
		elseif mode == "Below Feet" then
			return CFrame.new(pos - Vector3.new(0, dist, 0)) * yaw * pose
		elseif mode == "In Front" then
			-- in front of them, turned around to face them
			return CFrame.new(pos + yaw.LookVector * dist) * yaw * CFrame.Angles(0, math.pi, 0)
		end

		-- Behind (default): same facing as the target
		return CFrame.new(pos - yaw.LookVector * dist) * yaw
	end

	-- Stops our humanoid from falling over / ragdolling while we hover in the air
	-- or sit under the floor.
	local NOFALL = {
		Enum.HumanoidStateType.FallingDown,
		Enum.HumanoidStateType.Ragdoll,
		Enum.HumanoidStateType.Freefall,
	}

	local function isLying()
		return troll.followMode == "Above Head" or troll.followMode == "Below Feet"
	end

	local function keepUpright(myChar)
		local hum = myChar:FindFirstChildOfClass("Humanoid")
		if not hum then
			return
		end

		if troll.stateChar ~= myChar then
			troll.stateChar = myChar
			for _, st in ipairs(NOFALL) do
				pcall(hum.SetStateEnabled, hum, st, false)
			end
		end

		hum.Sit = false

		-- PlatformStand stops the humanoid from trying to stand back up,
		-- so the lying pose stays
		local lying = isLying()
		hum.PlatformStand = lying
		if lying then
			return
		end

		local st = hum:GetState()
		if st == Enum.HumanoidStateType.FallingDown
			or st == Enum.HumanoidStateType.Ragdoll
			or st == Enum.HumanoidStateType.Freefall then
			pcall(hum.ChangeState, hum, Enum.HumanoidStateType.Running)
		end
	end

	local function restoreStates()
		local c = troll.stateChar
		troll.stateChar = nil
		local hum = c and c:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.PlatformStand = false
			for _, st in ipairs(NOFALL) do
				pcall(hum.SetStateEnabled, hum, st, true)
			end
		end
	end

	local function lock(myHrp, cf)
		myHrp.CFrame = cf
		myHrp.AssemblyLinearVelocity = Vector3.zero
		myHrp.AssemblyAngularVelocity = Vector3.zero
	end

	local stepConn = RS.Heartbeat:Connect(function()
		local myHrp, myChar = hrpOf(localPlayer)
		if not myHrp then
			return
		end

		-- Shield has priority over follow when both are on
		if troll.shield then
			local target = func16() -- Sheriff only
			local tHrp = hrpOf(target)

			if target and target ~= localPlayer and tHrp then
				-- stand right in front of the gun, facing the shooter, so shots hit us
				local pos = tHrp.Position + tHrp.CFrame.LookVector * troll.shieldDist
				lock(myHrp, CFrame.lookAt(pos, tHrp.Position))
			end

			if troll.mimicChar then
				stopMimic()
			end

			return
		end

		if troll.follow and troll.followName then
			local target = Players:FindFirstChild(troll.followName)
			local tHrp, tChar = hrpOf(target)

			if tHrp and tChar then
				lock(myHrp, followCF(tHrp, troll.followMode, troll.followDist))
				keepUpright(myChar)

				return
			end
		end

		if troll.mimicChar then
			stopMimic()
		end

		if troll.stateChar then
			restoreStates()
		end
	end)

	local noclipConn = RS.Stepped:Connect(function()
		if not (troll.follow and troll.followName) and not troll.shield then
			return
		end

		local _, myChar = hrpOf(localPlayer)
		if not myChar then
			return
		end

		for _, part in ipairs(myChar:GetDescendants()) do
			if part:IsA("BasePart") and part.CanCollide then
				part.CanCollide = false
			end
		end
	end)

	list2.conns[#list2.conns + 1] = stepConn
	list2.conns[#list2.conns + 1] = noclipConn
	list2.conns[#list2.conns + 1] = {
		Disconnect = function()
			troll.follow = false
			troll.shield = false
			stopMimic()
			restoreStates()
		end,
	}

	local followDrop

	tbl43.troll:Section({ Title = "Follow Player" })

	followDrop = tbl43.troll:Dropdown({
		Title = "Select Player",
		Desc = "Player to lock yourself onto",
		Multi = false,
		Value = nil,
		Values = plist(),
		Callback = function(v)
			troll.followName = pick(v)
		end,
	})

	tbl43.troll:Dropdown({
		Title = "Position",
		Flag = "Dropdown_Troll_FollowMode",
		Desc = "Where to stay relative to the player",
		Multi = false,
		Value = "Behind",
		Values = { "Above Head", "Below Feet", "In Front", "Behind" },
		Callback = function(v)
			troll.followMode = pick(v) or "Behind"
		end,
	})

	tbl43.troll:Slider({
		Title = "Distance",
		Flag = "Slider_Troll_Follow_Distance",
		Desc = "Studs from the player's center (0 = inside their body)",
		Step = 0.1,
		Value = { Min = 0, Max = 20, Default = 4 },
		Callback = function(v)
			troll.followDist = tonumber(v) or 4
		end,
	})

	tbl43.troll:Toggle({
		Title = "Follow Player",
		Flag = "Toggle_Troll_Follow",
		Desc = "Locks you onto the selected player at the chosen position and distance",
		Type = "Toggle",
		Value = false,
		Callback = function(v)
			if v and not troll.followName then
				obj2:Notify({ Title = "Troll", Content = "Pick a player first!", Duration = 2, Icon = "x" })
			end

			troll.follow = v
		end,
	})

	tbl43.troll:Section({ Title = "Block Sheriff Gun" })

	tbl43.troll:Slider({
		Title = "Distance In Front",
		Flag = "Slider_Troll_Shield_Distance",
		Desc = "How many studs in front of the sheriff",
		Step = 0.5,
		Value = { Min = 1, Max = 15, Default = 3 },
		Callback = function(v)
			troll.shieldDist = tonumber(v) or 3
		end,
	})

	tbl43.troll:Toggle({
		Title = "Stand In Front Of Sheriff",
		Flag = "Toggle_Troll_Shield",
		Desc = "Locks you in front of the sheriff only, so their shots hit you instead of the murderer (takes priority over Follow & Mimic)",
		Type = "Toggle",
		Value = false,
		Callback = function(v)
			if v and not func16() then
				obj2:Notify({ Title = "Troll", Content = "No sheriff this round!", Duration = 2, Icon = "x" })
			end

			troll.shield = v
		end,
	})

	local function refresh()
		pcall(function()
			followDrop:Refresh(plist())
		end)

	end

	list2.conns[#list2.conns + 1] = Players.PlayerAdded:Connect(refresh)
	list2.conns[#list2.conns + 1] = Players.PlayerRemoving:Connect(refresh)
end

-- ===================== ROLE COLOURS IN PLAYER DROPDOWNS =====================
-- Every player name shown in the UI (Select Player, Aimlock Target, Fling Target,
-- Kill Target, ...) is coloured by role as soon as it exists in the list, selected
-- or not: Murderer = red, Sheriff = blue. Everyone else keeps the normal colour.
do
	local MURDERER_COLOR = Color3.fromRGB(255, 70, 70)
	local SHERIFF_COLOR = Color3.fromRGB(70, 150, 255)

	local alive = true
	local murderer, sheriff = nil, nil
	local tracked = {} -- [textObject] = { orig = Color3, painted = bool, conn = colour listener }
	local hooks = {} -- [textObject] = Text-changed connection
	local roots = {}

	local function refreshRoles()
		local okM, m = pcall(func15)
		local okS, sh = pcall(func16)
		murderer = okM and m or nil
		sheriff = okS and sh or nil
	end

	local function playerFromText(text)
		local t = text:match("^%s*(.-)%s*$"):lower()
		if t == "" then
			return nil
		end
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= localPlayer and (p.Name:lower() == t or p.DisplayName:lower() == t) then
				return p
			end
		end
		return nil
	end

	local function wantedColor(inst)
		local p = playerFromText(inst.Text)
		if p and p == murderer then
			return MURDERER_COLOR
		elseif p and p == sheriff then
			return SHERIFF_COLOR
		end
		return nil
	end

	-- apply (or undo) the role colour on one text object right now
	local function paint(inst)
		local info = tracked[inst]
		if not info then
			return
		end

		local want = wantedColor(inst)
		if want then
			if not info.painted then
				info.orig = inst.TextColor3
				info.painted = true
			end
			if inst.TextColor3 ~= want then
				inst.TextColor3 = want
			end
		elseif info.painted then
			info.painted = false
			if info.orig then
				inst.TextColor3 = info.orig
			end
		end
	end

	local function untrack(inst)
		local info = tracked[inst]
		if info then
			if info.conn then
				info.conn:Disconnect()
			end
			tracked[inst] = nil
		end
	end

	local function consider(inst)
		if playerFromText(inst.Text) then
			if not tracked[inst] then
				local info = { orig = inst.TextColor3, painted = false }
				tracked[inst] = info
				-- if the UI library recolours the item (hover, select, refresh), paint it again at once
				info.conn = inst:GetPropertyChangedSignal("TextColor3"):Connect(function()
					paint(inst)
				end)
			end
			paint(inst)
		else
			if tracked[inst] and tracked[inst].painted then
				paint(inst)
			end
			untrack(inst)
		end
	end

	local function hook(inst)
		if hooks[inst] or not (inst:IsA("TextLabel") or inst:IsA("TextButton")) then
			return
		end

		hooks[inst] = inst:GetPropertyChangedSignal("Text"):Connect(function()
			consider(inst)
		end)

		consider(inst)
	end

	local function unhook(inst)
		local c = hooks[inst]
		if c then
			c:Disconnect()
			hooks[inst] = nil
		end
		untrack(inst)
	end

	local function watch(rootInst)
		if not rootInst or roots[rootInst] then
			return
		end
		roots[rootInst] = true

		for _, d in ipairs(rootInst:GetDescendants()) do
			hook(d)
		end

		list2.conns[#list2.conns + 1] = rootInst.DescendantAdded:Connect(hook)
		list2.conns[#list2.conns + 1] = rootInst.DescendantRemoving:Connect(unhook)
	end

	refreshRoles()

	local root = oasisWindow and oasisWindow.Root
	if root then
		watch(root:FindFirstAncestorOfClass("ScreenGui") or root)
	end
	for _, g in ipairs(_FVL.libGuis or {}) do
		watch(g)
	end

	task.spawn(function()
		while alive do
			refreshRoles()

			for inst in pairs(tracked) do
				if not inst.Parent then
					unhook(inst)
				else
					paint(inst)
				end
			end

			task.wait(0.25)
		end
	end)

	list2.conns[#list2.conns + 1] = {
		Disconnect = function()
			alive = false
			for inst in pairs(tracked) do
				local info = tracked[inst]
				if info and info.painted and info.orig then
					pcall(function()
						inst.TextColor3 = info.orig
					end)
				end
			end
			for inst in pairs(hooks) do
				unhook(inst)
			end
		end,
	}
end

-- ===================== EXTRAS (ported feature set) =====================
do
	local function installExtras()
		local RS = game:GetService("RunService")
		local Lighting = game:GetService("Lighting")
		local Debris = game:GetService("Debris")
		local TweenService = game:GetService("TweenService")
		local RepStorage = game:GetService("ReplicatedStorage")
		local Stats = game:GetService("Stats")
		local mouse = localPlayer:GetMouse()

		local X = {
			box = false, skel = false, flags = false,
			chams = false, selfChams = false, toolChams = false,
			material = Enum.Material.ForceField,
			selfColor = Color3.fromRGB(133, 220, 255),
			toolColor = Color3.fromRGB(255, 255, 255),
			ambient = false, ambientColor = Color3.fromRGB(120, 120, 140),
			exposure = false, exposureValue = 0,
			sky = false, skyName = "Jungle",
			landing = false, landingColor = Color3.fromRGB(133, 220, 255),
			tracer = false, tracerAll = false,
			tracerColor = Color3.fromRGB(133, 220, 255), tracerDur = 1,
			auto = false, autoDelay = 0, force = false, standOff = 15,
			predict = false, predStrength = 1, lastShot = 0,
			tpTool = false, flingTool = false,
			nMurd = false, nSher = false, nRoles = false,
		}

		local function notify(title, text, icon)
			obj2:Notify({ Title = title, Content = text, Duration = 2, Icon = icon or "x" })
		end

		local function pick(v)
			if type(v) == "table" then
				v = v[1] or v.Value
			end
			return v and tostring(v) or nil
		end

		local function hrpOf(p)
			local c = p and p.Character
			return c and c:FindFirstChild("HumanoidRootPart"), c
		end

		local function alive(p)
			local c = p and p.Character
			local h = c and c:FindFirstChildOfClass("Humanoid")
			return h ~= nil and h.Health > 0
		end

		----------------------------------------------------------------
		-- Drawing ESP: Box / Skeleton / Role flags
		----------------------------------------------------------------
		local hasDrawing = false
		pcall(function()
			local t = Drawing.new("Line")
			t:Remove()
			hasDrawing = true
		end)

		local R15 = {
			{ "Head", "UpperTorso" }, { "UpperTorso", "LowerTorso" },
			{ "UpperTorso", "LeftUpperArm" }, { "LeftUpperArm", "LeftLowerArm" }, { "LeftLowerArm", "LeftHand" },
			{ "UpperTorso", "RightUpperArm" }, { "RightUpperArm", "RightLowerArm" }, { "RightLowerArm", "RightHand" },
			{ "LowerTorso", "LeftUpperLeg" }, { "LeftUpperLeg", "LeftLowerLeg" }, { "LeftLowerLeg", "LeftFoot" },
			{ "LowerTorso", "RightUpperLeg" }, { "RightUpperLeg", "RightLowerLeg" }, { "RightLowerLeg", "RightFoot" },
		}
		local R6 = {
			{ "Head", "Torso" }, { "Torso", "Left Arm" }, { "Torso", "Right Arm" },
			{ "Torso", "Left Leg" }, { "Torso", "Right Leg" },
		}

		local pool = {}

		local function hideEntry(e)
			if e.box then e.box.Visible = false end
			if e.text then e.text.Visible = false end
			for _, l in ipairs(e.lines) do
				l.Visible = false
			end
		end

		local function removeEntry(e)
			pcall(function()
				if e.box then e.box:Remove() end
				if e.text then e.text:Remove() end
				for _, l in ipairs(e.lines) do
					l:Remove()
				end
			end)
		end

		local function entryFor(p)
			local e = pool[p]
			if not e then
				e = { lines = {} }
				pool[p] = e
			end
			return e
		end

		local function espOn()
			return X.box or X.skel or X.flags
		end

		local wasEsp = false

		local function espStep()
			if not hasDrawing then
				return
			end

			if not espOn() then
				if wasEsp then
					for _, e in pairs(pool) do
						hideEntry(e)
					end
					wasEsp = false
				end
				return
			end

			wasEsp = true
			local cam = workspace.CurrentCamera
			if not cam then
				return
			end

			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= localPlayer then
					local e = entryFor(p)
					local hrp, char = hrpOf(p)
					local hum = char and char:FindFirstChildOfClass("Humanoid")
					local drew = false

					if hrp and hum then
						local v, onScreen = cam:WorldToViewportPoint(hrp.Position)

						if onScreen and v.Z > 0 then
							drew = true
							local cls = list2.espRole(p)
							local col = list2.espColorOfClass(cls)
							local top = cam:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
							local bot = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.2, 0))
							local h = math.abs(bot.Y - top.Y)
							local w = h * 0.55

							if X.box then
								if not e.box then
									e.box = Drawing.new("Square")
									e.box.Thickness = 1.5
									e.box.Filled = false
								end
								e.box.Color = col
								e.box.Size = Vector2.new(w, h)
								e.box.Position = Vector2.new(v.X - w / 2, top.Y)
								e.box.Visible = true
							elseif e.box then
								e.box.Visible = false
							end

							if X.flags and (cls == "Murderer" or cls == "Sheriff" or cls == "Zombie" or cls == "Survivor") then
								if not e.text then
									e.text = Drawing.new("Text")
									e.text.Size = 14
									e.text.Center = true
									e.text.Outline = true
								end
								e.text.Text = string.upper(cls)
								e.text.Color = col
								e.text.Position = Vector2.new(v.X, bot.Y + 2)
								e.text.Visible = true
							elseif e.text then
								e.text.Visible = false
							end

							if X.skel then
								local pairsList = char:FindFirstChild("UpperTorso") and R15 or R6
								for i, pr in ipairs(pairsList) do
									local a = char:FindFirstChild(pr[1])
									local b = char:FindFirstChild(pr[2])
									local ln = e.lines[i]

									if not ln then
										ln = Drawing.new("Line")
										ln.Thickness = 1.5
										e.lines[i] = ln
									end

									if a and b then
										local pa = cam:WorldToViewportPoint(a.Position)
										local pb = cam:WorldToViewportPoint(b.Position)

										if pa.Z > 0 and pb.Z > 0 then
											ln.Color = col
											ln.From = Vector2.new(pa.X, pa.Y)
											ln.To = Vector2.new(pb.X, pb.Y)
											ln.Visible = true
										else
											ln.Visible = false
										end
									else
										ln.Visible = false
									end
								end

								for i = #pairsList + 1, #e.lines do
									e.lines[i].Visible = false
								end
							else
								for _, l in ipairs(e.lines) do
									l.Visible = false
								end
							end
						end
					end

					if not drew then
						hideEntry(e)
					end
				end
			end
		end

		list2.conns[#list2.conns + 1] = Players.PlayerRemoving:Connect(function(p)
			local e = pool[p]
			if e then
				removeEntry(e)
				pool[p] = nil
			end
		end)

		----------------------------------------------------------------
		-- Chams (others / self / tool)
		----------------------------------------------------------------
		local storeOthers, storeSelf, storeTool = {}, {}, {}

		-- Glass and Plastic only LOOK see-through when the part itself is transparent, so for those two materials
		-- we also set Transparency (and a little Reflectance for Glass). ForceField / Neon are left as they were.
		X.chamsTrans = X.chamsTrans or 0.5

		-- (a field on X instead of a new local: this block is close to Lua's 200-locals limit)
		X.chamsSeeThrough = function()
			return X.material == Enum.Material.Glass or X.material == Enum.Material.Plastic
		end

		-- Glass / Plastic with ForceField's glowing pattern: the real part becomes see-through Glass/Plastic and a slightly
		-- bigger ForceField copy of it (welded on, no collision, ignored by raycasts) is drawn over it.
		X.chamsOverlay = function(d, color, want)
			local ov = d:FindFirstChild("FVLChamsFF")

			if not want then
				if ov then
					ov:Destroy()
				end
				return
			end

			if not ov then
				local ok, c = pcall(function()
					return d:Clone()
				end)

				if not ok or not c then
					return
				end

				for _, ch in ipairs(c:GetChildren()) do
					if not ch:IsA("DataModelMesh") then
						ch:Destroy()
					end
				end

				c.Name = "FVLChamsFF"
				c.Anchored = false
				c.CanCollide = false
				c.CanQuery = false
				c.CanTouch = false
				c.Massless = true
				c.CastShadow = false
				c.Material = Enum.Material.ForceField
				c.Transparency = 0
				c.Reflectance = 0
				c.Size = d.Size * 1.04
				c.CFrame = d.CFrame

				local weld = Instance.new("WeldConstraint")
				weld.Part0 = d
				weld.Part1 = c
				weld.Parent = c

				c.Parent = d
				ov = c
			end

			if ov.Color ~= color then
				ov.Color = color
			end
		end

		local function chamsApply(store, model, color)
			local seeThrough = X.chamsSeeThrough()

			for _, d in ipairs(model:GetDescendants()) do
				if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" and d.Name ~= "FVLChamsFF" then
					if not store[d] then
						store[d] = { d.Material, d.Color, d.Transparency, d.Reflectance }
					end

					local o = store[d]

					if d.Material ~= X.material then
						d.Material = X.material
					end
					if d.Color ~= color then
						d.Color = color
					end

					-- never reveal parts the game keeps invisible (hitboxes, etc.)
					if o[3] < 0.99 then
						local wantT = seeThrough and math.max(o[3], X.chamsTrans) or o[3]
						local wantR = (seeThrough and X.material == Enum.Material.Glass) and 0.15 or o[4]

						if d.Transparency ~= wantT then
							d.Transparency = wantT
						end
						if d.Reflectance ~= wantR then
							d.Reflectance = wantR
						end
					end

					X.chamsOverlay(d, color, seeThrough and o[3] < 0.99)
				elseif (d:IsA("Decal") or d:IsA("Texture")) and d.Parent and d.Parent:IsA("BasePart") and d.Parent.Name ~= "HumanoidRootPart" and d.Parent.Name ~= "FVLChamsFF" then
					-- faces / clothing decals stay solid unless we fade them too
					if not store[d] then
						store[d] = { d.Transparency }
					end

					local wantT = seeThrough and math.max(store[d][1], X.chamsTrans) or store[d][1]

					if d.Transparency ~= wantT then
						d.Transparency = wantT
					end
				end
			end
		end

		local function chamsRestore(store)
			for inst, o in pairs(store) do
				pcall(function()
					if inst:IsA("Highlight") then
						inst:Destroy()
					elseif inst.Parent then
						if inst:IsA("BasePart") then
							local ov = inst:FindFirstChild("FVLChamsFF")

							if ov then
								ov:Destroy()
							end

							inst.Material = o[1]
							inst.Color = o[2]
							inst.Transparency = o[3]
							inst.Reflectance = o[4]
						else
							inst.Transparency = o[1]
						end
					end
				end)
			end
			table.clear(store)
		end

		local nextChams = 0

		local function chamsStep(now)
			if now < nextChams then
				return
			end
			nextChams = now + 0.25

			if X.chams then
				for _, p in ipairs(Players:GetPlayers()) do
					if p ~= localPlayer and p.Character then
						local col = list2.espColor(p) -- Murderer / Sheriff / Innocent
						chamsApply(storeOthers, p.Character, col)
					end
				end
			end

			local myChar = localPlayer.Character

			if X.selfChams and myChar then
				chamsApply(storeSelf, myChar, X.selfColor)
			end

			if X.toolChams and myChar then
				for _, t in ipairs(myChar:GetChildren()) do
					if t:IsA("Tool") then
						chamsApply(storeTool, t, X.toolColor)
					end
				end
			end
		end

		----------------------------------------------------------------
		-- Lighting: ambient / exposure / skybox
		----------------------------------------------------------------
		local lightOrig = nil

		local function snapLight()
			if not lightOrig then
				lightOrig = {
					Ambient = Lighting.Ambient,
					OutdoorAmbient = Lighting.OutdoorAmbient,
					Exposure = Lighting.ExposureCompensation,
				}
			end
		end

		local function applyLight()
			if X.ambient then
				snapLight()
				Lighting.Ambient = X.ambientColor
				Lighting.OutdoorAmbient = X.ambientColor
			end
			if X.exposure then
				snapLight()
				Lighting.ExposureCompensation = X.exposureValue
			end
		end

		local skyboxes = {
			Jungle = {
				SkyboxBk = "http://www.roblox.com/asset/?id=214399891", SkyboxDn = "http://www.roblox.com/asset/?id=214399887",
				SkyboxFt = "http://www.roblox.com/asset/?id=214399894", SkyboxLf = "http://www.roblox.com/asset/?id=214405668",
				SkyboxRt = "http://www.roblox.com/asset/?id=214399899", SkyboxUp = "http://www.roblox.com/asset/?id=214399889",
			},
			Blossom = {
				SkyboxBk = "http://www.roblox.com/asset/?id=271042516", SkyboxDn = "http://www.roblox.com/asset/?id=271077243",
				SkyboxFt = "http://www.roblox.com/asset/?id=271042556", SkyboxLf = "http://www.roblox.com/asset/?id=271042310",
				SkyboxRt = "http://www.roblox.com/asset/?id=271042467", SkyboxUp = "http://www.roblox.com/asset/?id=271077958",
			},
			["Red night"] = {
				SkyboxBk = "http://www.roblox.com/Asset/?ID=401664839", SkyboxDn = "http://www.roblox.com/Asset/?ID=401664862",
				SkyboxFt = "http://www.roblox.com/Asset/?ID=401664960", SkyboxLf = "http://www.roblox.com/Asset/?ID=401664881",
				SkyboxRt = "http://www.roblox.com/Asset/?ID=401664901", SkyboxUp = "http://www.roblox.com/Asset/?ID=401664936",
			},
			Purple = {
				SkyboxBk = "http://www.roblox.com/asset/?id=13694952867", SkyboxDn = "http://www.roblox.com/asset/?id=13694968325",
				SkyboxFt = "http://www.roblox.com/asset/?id=13694980654", SkyboxLf = "http://www.roblox.com/asset/?id=13694998113",
				SkyboxRt = "http://www.roblox.com/asset/?id=13695002700", SkyboxUp = "http://www.roblox.com/asset/?id=13695007103",
			},
			Foggy = {
				SkyboxBk = "rbxassetid://1370717244", SkyboxDn = "rbxassetid://1370717336",
				SkyboxFt = "rbxassetid://1370717438", SkyboxLf = "rbxassetid://1370717567",
				SkyboxRt = "rbxassetid://1370717698", SkyboxUp = "rbxassetid://1370717782",
			},
			["Default MM2 Summer"] = {
				SkyboxBk = "http://www.roblox.com/asset/?version=1&id=135483466", SkyboxDn = "http://www.roblox.com/asset/?version=1&id=135483484",
				SkyboxFt = "http://www.roblox.com/asset/?version=1&id=135483461", SkyboxLf = "http://www.roblox.com/asset/?version=1&id=135483495",
				SkyboxRt = "http://www.roblox.com/asset/?version=1&id=135483499", SkyboxUp = "http://www.roblox.com/asset/?version=1&id=135483475",
			},
			["Sunset"] = {
				SkyboxBk = "rbxassetid://600830446", SkyboxDn = "rbxassetid://600831635",
				SkyboxFt = "rbxassetid://600832720", SkyboxLf = "rbxassetid://600886090",
				SkyboxRt = "rbxassetid://600833862", SkyboxUp = "rbxassetid://600835177",
			},
			["Arctic"] = {
				SkyboxBk = "rbxassetid://225469390", SkyboxDn = "rbxassetid://225469395",
				SkyboxFt = "rbxassetid://225469403", SkyboxLf = "rbxassetid://225469450",
				SkyboxRt = "rbxassetid://225469471", SkyboxUp = "rbxassetid://225469481",
			},
			["Space"] = {
				SkyboxBk = "rbxassetid://166509999", SkyboxDn = "rbxassetid://166510057",
				SkyboxFt = "rbxassetid://166510116", SkyboxLf = "rbxassetid://166510092",
				SkyboxRt = "rbxassetid://166510131", SkyboxUp = "rbxassetid://166510114",
			},
			["Pink Skies"] = {
				SkyboxBk = "rbxassetid://151165214", SkyboxDn = "rbxassetid://151165197",
				SkyboxFt = "rbxassetid://151165224", SkyboxLf = "rbxassetid://151165191",
				SkyboxRt = "rbxassetid://151165206", SkyboxUp = "rbxassetid://151165227",
			},
			["Blue Night"] = {
				SkyboxBk = "rbxassetid://12064107", SkyboxDn = "rbxassetid://12064152",
				SkyboxFt = "rbxassetid://12064121", SkyboxLf = "rbxassetid://12063984",
				SkyboxRt = "rbxassetid://12064115", SkyboxUp = "rbxassetid://12064131",
			},
			["Purple Sunset"] = {
				SkyboxBk = "rbxassetid://264908339", SkyboxDn = "rbxassetid://264907909",
				SkyboxFt = "rbxassetid://264909420", SkyboxLf = "rbxassetid://264909758",
				SkyboxRt = "rbxassetid://264908886", SkyboxUp = "rbxassetid://264907379",
			},
			["Blue Nebula 2"] = {
				SkyboxBk = "rbxassetid://135207744", SkyboxDn = "rbxassetid://135207662",
				SkyboxFt = "rbxassetid://135207770", SkyboxLf = "rbxassetid://135207615",
				SkyboxRt = "rbxassetid://135207695", SkyboxUp = "rbxassetid://135207794",
			},
			["Blue Planet"] = {
				SkyboxBk = "rbxassetid://218955819", SkyboxDn = "rbxassetid://218953419",
				SkyboxFt = "rbxassetid://218954524", SkyboxLf = "rbxassetid://218958493",
				SkyboxRt = "rbxassetid://218957134", SkyboxUp = "rbxassetid://218950090",
			},
			["Deep Space"] = {
				SkyboxBk = "rbxassetid://159248188", SkyboxDn = "rbxassetid://159248183",
				SkyboxFt = "rbxassetid://159248187", SkyboxLf = "rbxassetid://159248173",
				SkyboxRt = "rbxassetid://159248192", SkyboxUp = "rbxassetid://159248176",
			},
		}
		local skyAssets = {
			Galaxy = 15983996673, Anime = 13107361022, Minecraft = 2758029221,
			["Snow Skybox"] = 4604073339, ["Purple Nebula"] = 83555979203508, ["Blue Nebula"] = 130093177270069,
			["Geoz Skybox"] = 97573261671957, ["SpongeBob Sky"] = 114523453023009, ["Night Sky Vibe"] = 78613024128163,
			["Asteroid Space"] = 295604372, ["Realistic Space"] = 136402262,
		}
		local createdSky, originalSky, originalSkyParent = nil, nil, nil

		local function detachOriginal()
			if originalSky then
				return
			end
			local ex = Lighting:FindFirstChildOfClass("Sky")
			if ex and ex ~= createdSky then
				originalSky = ex
				originalSkyParent = ex.Parent
				pcall(function()
					ex.Parent = nil
				end)
			end
		end

		local function clearCreated()
			if createdSky then
				pcall(function()
					createdSky:Destroy()
				end)
				createdSky = nil
			end
		end

		local function applySky(name)
			if skyboxes[name] then
				detachOriginal()
				clearCreated()
				local s = Instance.new("Sky")
				s.Name = "ExtraSky"
				for k, v in pairs(skyboxes[name]) do
					pcall(function()
						s[k] = v
					end)
				end
				s.Parent = Lighting
				createdSky = s
			elseif skyAssets[name] then
				task.spawn(function()
					local ok, objs = pcall(function()
						return game:GetObjects("rbxassetid://" .. skyAssets[name])
					end)
					if not ok or type(objs) ~= "table" or not X.sky then
						return
					end
					local found
					for _, o in ipairs(objs) do
						if o:IsA("Sky") then
							found = o
							break
						end
						local s = o:FindFirstChildWhichIsA("Sky", true)
						if s then
							found = s
							break
						end
					end
					if found then
						detachOriginal()
						clearCreated()
						found.Name = "ExtraSky"
						found.Parent = Lighting
						createdSky = found
					end
				end)
			end
		end

		local function restoreSky()
			clearCreated()
			if originalSky then
				pcall(function()
					originalSky.Parent = originalSkyParent or Lighting
				end)
				originalSky, originalSkyParent = nil, nil
			end
		end

		local function restoreLight()
			if lightOrig then
				Lighting.Ambient = lightOrig.Ambient
				Lighting.OutdoorAmbient = lightOrig.OutdoorAmbient
				Lighting.ExposureCompensation = lightOrig.Exposure
				lightOrig = nil
			end
		end

		----------------------------------------------------------------
		-- Landing circle
		----------------------------------------------------------------
		local wasAir, airSince = false, 0

		local function landingStep(now)
			if not X.landing then
				wasAir = false
				return
			end

			local hrp, char = hrpOf(localPlayer)
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if not hrp or not hum then
				return
			end

			local air = hum.FloorMaterial == Enum.Material.Air

			if air and not wasAir then
				airSince = now
			elseif not air and wasAir and now - airSince > 0.25 then
				local ring = Instance.new("Part")
				ring.Shape = Enum.PartType.Cylinder
				ring.Material = Enum.Material.Neon
				ring.Color = X.landingColor
				ring.Anchored = true
				ring.CanCollide = false
				ring.CanQuery = false
				ring.CanTouch = false
				ring.Transparency = 0.2
				ring.Size = Vector3.new(0.15, 1, 1)
				local feet = hrp.Position - Vector3.new(0, hum.HipHeight + hrp.Size.Y / 2 - 0.1, 0)
				ring.CFrame = CFrame.new(feet) * CFrame.Angles(0, 0, math.pi / 2)
				ring.Parent = workspace
				TweenService:Create(ring, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = Vector3.new(0.15, 12, 12),
					Transparency = 1,
				}):Play()
				Debris:AddItem(ring, 0.8)
			end

			wasAir = air
		end

		----------------------------------------------------------------
		-- Bullet tracer
		----------------------------------------------------------------
		local function toPos(v)
			if typeof(v) == "Vector3" then
				return v
			elseif typeof(v) == "CFrame" then
				return v.Position
			elseif typeof(v) == "Instance" then
				if v:IsA("Attachment") then
					return v.WorldPosition
				elseif v:IsA("BasePart") then
					return v.Position
				end
			end
		end

		local function point(pos, life)
			local p = Instance.new("Part")
			p.Transparency = 1
			p.Anchored = true
			p.CanCollide = false
			p.CanQuery = false
			p.Size = Vector3.new(1, 1, 1)
			p.CFrame = CFrame.new(pos)
			Instance.new("Attachment", p)
			Debris:AddItem(p, life)
			p.Parent = workspace
			return p
		end

		local function makeTracer(a, b)
			local pa, pb = toPos(a), toPos(b)
			if not pa or not pb then
				return
			end

			local dur = X.tracerDur
			local sp = point(pa, dur + 0.5)
			local ep = point(pb, dur + 0.5)
			local beam = Instance.new("Beam")
			beam.FaceCamera = true
			beam.TextureSpeed = 1.5
			beam.TextureLength = 2
			beam.Width0 = 0.25
			beam.Width1 = 0.25
			beam.LightEmission = 3
			beam.LightInfluence = 0
			beam.Brightness = 2.5
			beam.Texture = "rbxassetid://12781800668"
			beam.Color = ColorSequence.new(X.tracerColor)
			beam.Transparency = NumberSequence.new(0.1)
			beam.Attachment0 = sp.Attachment
			beam.Attachment1 = ep.Attachment
			beam.Parent = sp

			task.delay(dur, function()
				if beam.Parent then
					TweenService:Create(beam, TweenInfo.new(0.2), { Width0 = 0, Width1 = 0 }):Play()
				end
			end)
		end

		local tracerConn, tracerRemote = nil, nil

		local function connectTracer()
			local ok, remote = pcall(function()
				return RepStorage:WaitForChild("ClientServices", 2):WaitForChild("WeaponService", 2):WaitForChild("GunFired", 2)
			end)
			if not ok or not remote then
				return
			end
			if tracerConn and tracerRemote == remote and tracerConn.Connected then
				return
			end
			if tracerConn then
				pcall(function()
					tracerConn:Disconnect()
				end)
			end
			tracerRemote = remote
			tracerConn = remote.OnClientEvent:Connect(function(gun, a, b)
				if not X.tracer then
					return
				end
				local mine = typeof(gun) == "Instance" and localPlayer.Character and gun:IsDescendantOf(localPlayer.Character)
				if mine or X.tracerAll then
					task.spawn(makeTracer, a, b)
				end
			end)
		end

		----------------------------------------------------------------
		-- Auto shoot / force shoot / prediction
		----------------------------------------------------------------
		local function pingSec()
			local ok, v = pcall(function()
				return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
			end)
			return ok and v / 1000 or 0.08
		end

		local function getGun()
			local c = localPlayer.Character
			local g = c and c:FindFirstChild("Gun")
			if g then
				return g, true
			end
			local bp = localPlayer:FindFirstChildOfClass("Backpack")
			g = bp and bp:FindFirstChild("Gun")
			return g, false
		end

		local rayParams = RaycastParams.new()
		rayParams.FilterType = Enum.RaycastFilterType.Exclude

		local function autoStep(now)
			if not X.auto then
				return
			end
			if now - X.lastShot < math.max(X.autoDelay, 0.3) then
				return
			end

			local gun, equipped = getGun()
			if not gun then
				return
			end

			local myHrp, myChar = hrpOf(localPlayer)
			local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
			if not myHrp or not myHum or myHum.Health <= 0 then
				return
			end

			if not equipped then
				pcall(function()
					myHum:EquipTool(gun)
				end)
				return
			end

			local murd
			if list2.gunTarget then
				murd = list2.gunTarget()
			else
				murd = func15()
			end
			if not murd or murd == localPlayer or not alive(murd) then
				return
			end

			local tHrp, tChar = hrpOf(murd)
			if not tHrp then
				return
			end

			local shoot = gun:FindFirstChild("Shoot")
			if not shoot then
				return
			end

			-- follows the Silent Aim Type dropdown (Default / Dynamic / Piercing), same as Silent Aim.
			-- Piercing ignores walls; the other types keep the wall check unless Force Shoot is on.
			local fired = list2.saShoot(shoot, myChar, murd, {
				force = X.force,
				forceStart = function(aim)
					-- start the shot near the murderer so walls in between don't block it
					local toMe = Vector3.new(myHrp.Position.X - aim.X, 0, myHrp.Position.Z - aim.Z)
					local off = toMe.Magnitude > 0.1 and toMe.Unit * math.min(X.standOff, toMe.Magnitude) or Vector3.zero
					return CFrame.new(aim + off + Vector3.new(0, 1.5, 0))
				end,
				isClear = function(hrp)
					rayParams.FilterDescendantsInstances = { myChar, tChar }
					return not workspace:Raycast(myHrp.Position, hrp.Position - myHrp.Position, rayParams)
				end,
			})

			if fired then
				X.lastShot = now
			end
		end

		----------------------------------------------------------------
		-- TP tool / Fling tool
		----------------------------------------------------------------
		local tools = {}

		local function setTool(key, name, on, fn)
			if tools[key] then
				pcall(function()
					tools[key]:Destroy()
				end)
				tools[key] = nil
			end

			if not on then
				return
			end

			local bp = localPlayer:FindFirstChildOfClass("Backpack")
			if not bp then
				return
			end

			local t = Instance.new("Tool")
			t.Name = name
			t.ToolTip = name
			t.RequiresHandle = false
			t.CanBeDropped = false
			t.Activated:Connect(fn)
			t.Parent = bp
			tools[key] = t
		end

		local function tpClick()
			local hrp = hrpOf(localPlayer)
			local hit = mouse.Hit
			if hrp and hit then
				hrp.CFrame = CFrame.new(hit.Position + Vector3.new(0, 3, 0))
			end
		end

		local function flingClick()
			local target = mouse.Target
			local node = target
			while node and node ~= workspace do
				local p = Players:GetPlayerFromCharacter(node)
				if p and p ~= localPlayer then
					func27(p)
					return
				end
				node = node.Parent
			end
		end

		local function refreshTools()
			setTool("tp", "TP Tool", X.tpTool, tpClick)
			setTool("fling", "Fling Tool", X.flingTool, flingClick)
		end

		list2.conns[#list2.conns + 1] = localPlayer.CharacterAdded:Connect(function()
			task.wait(1)
			refreshTools()
		end)

		----------------------------------------------------------------
		-- Notifications
		----------------------------------------------------------------
		local function hookDeath(p)
			local function onChar(c)
				local h = c:WaitForChild("Humanoid", 5)
				if not h then
					return
				end
				h.Died:Connect(function()
					if X.nMurd and p == func15() and not list2.isRole(p, "Zombie") then
						notify("Murderer Down", p.Name .. " (murderer) died", "skull")
					elseif X.nSher and p == func16() and not list2.isRole(p, "Survivor") then
						notify("Sheriff Down", p.Name .. " (sheriff) died", "skull")
					end
				end)
			end
			if p.Character then
				task.spawn(onChar, p.Character)
			end
			list2.conns[#list2.conns + 1] = p.CharacterAdded:Connect(onChar)
		end

		for _, p in ipairs(Players:GetPlayers()) do
			hookDeath(p)
		end
		list2.conns[#list2.conns + 1] = Players.PlayerAdded:Connect(hookDeath)

		local lastM, lastS, nextRole = nil, nil, 0

		local function roleStep(now)
			if not X.nRoles or now < nextRole then
				return
			end
			nextRole = now + 1
			local m, s = func15(), func16()

			-- Zombie / Survivor rounds have many players with these roles (func15/func16 return the nearest one,
			-- which keeps changing): no "who is the murderer / sheriff" spam there
			if m and list2.isRole(m, "Zombie") then
				m = nil
			end

			if s and list2.isRole(s, "Survivor") then
				s = nil
			end

			if m ~= lastM then
				lastM = m
				if m then
					notify("Roles", "Murderer: " .. m.Name, "skull")
				end
			end
			if s ~= lastS then
				lastS = s
				if s then
					notify("Roles", "Sheriff: " .. s.Name, "shield")
				end
			end
		end

		----------------------------------------------------------------
		-- Main loops + cleanup
		----------------------------------------------------------------
		local nextLight = 0

		list2.conns[#list2.conns + 1] = RS.RenderStepped:Connect(function()
			pcall(espStep)
		end)

		list2.conns[#list2.conns + 1] = RS.Heartbeat:Connect(function()
			local now = os.clock()
			pcall(chamsStep, now)
			pcall(autoStep, now)
			pcall(landingStep, now)
			pcall(roleStep, now)

			if now >= nextLight then
				nextLight = now + 0.5
				pcall(applyLight)
				if X.tracer then
					pcall(connectTracer)
				end
			end
		end)

		list2.conns[#list2.conns + 1] = {
			Disconnect = function()
				X.auto = false
				X.tracer = false
				for _, e in pairs(pool) do
					removeEntry(e)
				end
				pool = {}
				chamsRestore(storeOthers)
				chamsRestore(storeSelf)
				chamsRestore(storeTool)
				restoreLight()
				restoreSky()
				X.tpTool, X.flingTool = false, false
				refreshTools()
				if tracerConn then
					pcall(function()
						tracerConn:Disconnect()
					end)
				end
			end,
		}

		----------------------------------------------------------------
		-- UI
		----------------------------------------------------------------
		local function needDrawing(v)
			if v and not hasDrawing then
				notify("Extra ESP", "Your executor has no Drawing library.", "x")
			end
		end

		-- ESP tab: the Drawing-based toggles are created later (list2.buildExtraEsp), inside the "ESP" section
		list2.buildExtraEsp = function()
			tbl43.esp:Toggle({
				Title = "Box ESP", Flag = "Toggle_Extra_Box", Desc = "2D box around players, coloured by role",
				Type = "Toggle", Value = false,
				Callback = function(v) needDrawing(v) X.box = v end,
			})

			tbl43.esp:Toggle({
				Title = "Skeleton ESP", Flag = "Toggle_Extra_Skeleton", Desc = "Draws the bones of every player",
				Type = "Toggle", Value = false,
				Callback = function(v) needDrawing(v) X.skel = v end,
			})

			tbl43.esp:Toggle({
				Title = "Role Flags", Flag = "Toggle_Extra_Flags", Desc = "MURDERER / SHERIFF label under the player",
				Type = "Toggle", Value = false,
				Callback = function(v) needDrawing(v) X.flags = v end,
			})
		end

		tbl43.esp:Section({ Title = "Chams" })

		tbl43.esp:Dropdown({
			Title = "Chams Material", Flag = "Dropdown_Esp_ChamsMaterial", Desc = "Material used by all chams below",
			Multi = false, Value = "ForceField",
			Values = { "ForceField", "Neon", "Glass", "Plastic" },
			Callback = function(v)
				local m = Enum.Material[pick(v) or "ForceField"]
				if m then
					X.material = m
					nextChams = 0 -- re-apply right away instead of waiting for the next tick
				end
			end,
		})

		tbl43.esp:Slider({
			Title = "Chams Transparency", Flag = "Slider_Esp_ChamsTransparency",
			Desc = "How see-through the Glass / Plastic layer under the ForceField glow is (0 = solid, 1 = invisible). ForceField and Neon ignore this.",
			Step = 0.05,
			Value = { Min = 0, Max = 0.95, Default = 0.5 },
			Callback = function(v)
				local n = tonumber(v) or (type(v) == "table" and tonumber(v.Value))
				if n then
					X.chamsTrans = n
					nextChams = 0
				end
			end,
		})

		tbl43.esp:Toggle({
			Title = "Material Chams", Flag = "Toggle_Extra_Chams", Desc = "Re-materials other players, coloured by role",
			Type = "Toggle", Value = false,
			Callback = function(v)
				X.chams = v
				if not v then chamsRestore(storeOthers) end
			end,
		})

		tbl43.esp:Toggle({
			Title = "Self Chams", Flag = "Toggle_Extra_SelfChams", Desc = "Re-materials your own character (only you see it)",
			Type = "Toggle", Value = false,
			Callback = function(v)
				X.selfChams = v
				if not v then chamsRestore(storeSelf) end
			end,
		})

		tbl43.esp:Colorpicker({
			Title = "Self Chams Colour", Flag = "Colorpicker_Extra_SelfChams", Default = X.selfColor,
			Callback = function(c) X.selfColor = c end,
		})

		tbl43.esp:Toggle({
			Title = "Tool Chams", Flag = "Toggle_Extra_ToolChams", Desc = "Re-materials the knife/gun you are holding",
			Type = "Toggle", Value = false,
			Callback = function(v)
				X.toolChams = v
				if not v then chamsRestore(storeTool) end
			end,
		})

		tbl43.esp:Colorpicker({
			Title = "Tool Chams Colour", Flag = "Colorpicker_Extra_ToolChams", Default = X.toolColor,
			Callback = function(c) X.toolColor = c end,
		})

		-- Visuals tab
		tbl43.visuals:Section({ Title = "Extra World" })

		tbl43.visuals:Toggle({
			Title = "Ambient", Flag = "Toggle_Extra_Ambient", Desc = "Custom ambient light colour",
			Type = "Toggle", Value = false,
			Callback = function(v)
				X.ambient = v
				if v then
					applyLight()
				elseif lightOrig then
					Lighting.Ambient = lightOrig.Ambient
					Lighting.OutdoorAmbient = lightOrig.OutdoorAmbient
					if not X.exposure then lightOrig = nil end
				end
			end,
		})

		tbl43.visuals:Colorpicker({
			Title = "Ambient Colour", Flag = "Colorpicker_Extra_Ambient", Default = X.ambientColor,
			Callback = function(c) X.ambientColor = c if X.ambient then applyLight() end end,
		})

		tbl43.visuals:Toggle({
			Title = "Exposure", Flag = "Toggle_Extra_Exposure", Desc = "Custom exposure compensation",
			Type = "Toggle", Value = false,
			Callback = function(v)
				X.exposure = v
				if v then
					applyLight()
				elseif lightOrig then
					Lighting.ExposureCompensation = lightOrig.Exposure
					if not X.ambient then lightOrig = nil end
				end
			end,
		})

		tbl43.visuals:Slider({
			Title = "Exposure Amount", Flag = "Slider_Extra_Exposure", Step = 0.1,
			Value = { Min = -3, Max = 3, Default = 0 },
			Callback = function(v) X.exposureValue = tonumber(v) or 0 if X.exposure then applyLight() end end,
		})

		tbl43.visuals:Toggle({
			Title = "Skybox", Flag = "Toggle_Extra_Skybox", Desc = "Replaces the sky with a preset",
			Type = "Toggle", Value = false,
			Callback = function(v)
				X.sky = v
				if v then applySky(X.skyName) else restoreSky() end
			end,
		})

		tbl43.visuals:Dropdown({
			Title = "Skybox Preset", Flag = "Dropdown_Visuals_Skybox", Multi = false, Value = "Jungle",
			Values = {
				"Purple", "Red night", "Blossom", "Jungle", "Foggy", "Galaxy", "Anime", "Minecraft",
				"Snow Skybox", "Purple Nebula", "Blue Nebula", "Geoz Skybox", "SpongeBob Sky",
				"Night Sky Vibe", "Asteroid Space", "Realistic Space",
				"Default MM2 Summer", "Sunset", "Arctic", "Space", "Pink Skies", "Blue Night",
				"Purple Sunset", "Blue Nebula 2", "Blue Planet", "Deep Space",
			},
			Callback = function(v)
				X.skyName = pick(v) or "Jungle"
				if X.sky then applySky(X.skyName) end
			end,
		})

		tbl43.visuals:Section({ Title = "Effects" })

		tbl43.visuals:Toggle({
			Title = "Landing Circle", Flag = "Toggle_Extra_Landing", Desc = "Expanding ring where you land",
			Type = "Toggle", Value = false,
			Callback = function(v) X.landing = v end,
		})

		tbl43.visuals:Colorpicker({
			Title = "Landing Circle Colour", Flag = "Colorpicker_Extra_Landing", Default = X.landingColor,
			Callback = function(c) X.landingColor = c end,
		})

		tbl43.visuals:Toggle({
			Title = "Bullet Tracer", Flag = "Toggle_Extra_Tracer", Desc = "Draws a line when you shoot",
			Type = "Toggle", Value = false,
			Callback = function(v)
				X.tracer = v
				if v then task.spawn(connectTracer) end
			end,
		})

		tbl43.visuals:Toggle({
			Title = "Tracer: All Players", Flag = "Toggle_Extra_TracerAll", Desc = "Also show tracers for other players' shots",
			Type = "Toggle", Value = false,
			Callback = function(v) X.tracerAll = v end,
		})

		tbl43.visuals:Colorpicker({
			Title = "Tracer Colour", Flag = "Colorpicker_Extra_Tracer", Default = X.tracerColor,
			Callback = function(c) X.tracerColor = c end,
		})

		tbl43.visuals:Slider({
			Title = "Tracer Duration", Flag = "Slider_Extra_Tracer_Duration", Step = 0.1,
			Value = { Min = 0.1, Max = 5, Default = 1 },
			Callback = function(v) X.tracerDur = tonumber(v) or 1 end,
		})

		-- Combat tab
		tbl43.combat:Section({ Title = "Auto Shoot (Sheriff)" })

		tbl43.combat:Toggle({
			Title = "Auto Shoot", Flag = "Toggle_Extra_AutoShoot", Desc = "Shoots the murderer automatically when you hold the gun (Survivor: shoots the nearest zombie). Skips whitelisted players, shoots blacklisted ones first.",
			Type = "Toggle", Value = false,
			Callback = function(v) X.auto = v end,
		})

		tbl43.combat:Slider({
			Title = "Auto Shoot Delay (ms)", Flag = "Slider_Extra_AutoShoot_Delay", Step = 10,
			Value = { Min = 0, Max = 600, Default = 0 },
			Callback = function(v) X.autoDelay = (tonumber(v) or 0) / 1000 end,
		})

		tbl43.combat:Toggle({
			Title = "Force Shoot", Flag = "Toggle_Extra_ForceShoot", Desc = "Auto Shoot also fires through walls (the gun's muzzle is moved next to the murderer first)",
			Type = "Toggle", Value = false,
			Callback = function(v) X.force = v end,
		})

		tbl43.combat:Slider({
			Title = "Force Shoot Origin (studs)", Flag = "Slider_Extra_ForceShoot_Origin", Step = 1,
			Value = { Min = 0, Max = 40, Default = 15 },
			Callback = function(v) X.standOff = tonumber(v) or 15 end,
		})

		tbl43.combat:Toggle({
			Title = "Prediction", Flag = "Toggle_Extra_Predict", Desc = "Old lead for Auto Shoot. Auto Shoot now follows Silent Aim Type, which already predicts movement.",
			Type = "Toggle", Value = false,
			Callback = function(v) X.predict = v end,
		})

		tbl43.combat:Slider({
			Title = "Prediction Strength", Flag = "Slider_Extra_Predict_Strength", Step = 0.1,
			Value = { Min = 0, Max = 2, Default = 1 },
			Callback = function(v) X.predStrength = tonumber(v) or 1 end,
		})

		-- Fling & Teleport tab: tools / ESP tab: alerts
		tbl43.fling:Section({ Title = "Click Tools" })

		tbl43.fling:Toggle({
			Title = "TP Tool", Flag = "Toggle_Extra_TPTool", Desc = "Gives you a tool: tap to teleport to where you aim",
			Type = "Toggle", Value = false,
			Callback = function(v) X.tpTool = v refreshTools() end,
		})

		tbl43.fling:Toggle({
			Title = "Fling Tool", Flag = "Toggle_Extra_FlingTool", Desc = "Gives you a tool: tap a player to fling them",
			Type = "Toggle", Value = false,
			Callback = function(v) X.flingTool = v refreshTools() end,
		})

		tbl43.esp:Section({ Title = "Alerts" })

		tbl43.esp:Toggle({
			Title = "Notify: Murderer Died", Flag = "Toggle_Extra_NotifyMurd", Type = "Toggle", Value = false,
			Callback = function(v) X.nMurd = v end,
		})

		tbl43.esp:Toggle({
			Title = "Notify: Sheriff Died", Flag = "Toggle_Extra_NotifySher", Type = "Toggle", Value = false,
			Callback = function(v) X.nSher = v end,
		})

		tbl43.esp:Toggle({
			Title = "Notify: Roles", Flag = "Toggle_Extra_NotifyRoles", Desc = "Announces who the murderer and sheriff are",
			Type = "Toggle", Value = false,
			Callback = function(v) X.nRoles = v lastM, lastS = nil, nil end,
		})
	end

	installExtras()
end

-- ===================== WORLD EFFECTS + DEATH EFFECTS =====================
do
	local function installFx()
		local RS = game:GetService("RunService")
		local TweenService = game:GetService("TweenService")
		local Debris = game:GetService("Debris")

		local F = {
			world = false,
			worldType = "Snow",
			worldColor = Color3.fromRGB(150, 200, 255),
			worldRate = 250,
			mOn = false,
			pOn = false,
			pSelf = false,
			mode = "Custom Aura",
			auraScale = 1,
			color = Color3.fromRGB(255, 60, 60),
			duration = 2,
		}

		local function pick(v)
			if type(v) == "table" then
				v = v[1] or v.Value
			end
			return v and tostring(v) or nil
		end

		----------------------------------------------------------------
		-- World effects (snow / sakura around the camera)
		----------------------------------------------------------------
		local SPAN, TALL = 260, 140
		local wPart, wEmitter, wConn = nil, nil, nil

		local function styleEmitter()
			local e = wEmitter
			if not e then
				return
			end

			e.Texture = "rbxasset://textures/particles/smoke_main.dds"
			e.LightInfluence = 0
			e.LightEmission = 0.4
			e.Drag = 0
			e.EmissionDirection = Enum.NormalId.Bottom
			e.Rate = F.worldRate
			e.Color = ColorSequence.new(F.worldColor)
			e.Rotation = NumberRange.new(0, 360)

			if F.worldType == "Snow" then
				e.Lifetime = NumberRange.new(4, 6)
				e.Speed = NumberRange.new(6, 12)
				e.Acceleration = Vector3.new(2, -6, 1)
				e.SpreadAngle = Vector2.new(35, 35)
				e.RotSpeed = NumberRange.new(-40, 40)
				e.Squash = NumberSequence.new(0)
				e.Size = NumberSequence.new(0.55)
				e.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.2),
					NumberSequenceKeypoint.new(0.8, 0.3),
					NumberSequenceKeypoint.new(1, 1),
				})
			else
				-- Sakura: slower, drifting petals
				e.Lifetime = NumberRange.new(5, 7)
				e.Speed = NumberRange.new(5, 10)
				e.Acceleration = Vector3.new(4, -5, 2)
				e.SpreadAngle = Vector2.new(40, 40)
				e.RotSpeed = NumberRange.new(-80, 80)
				e.Squash = NumberSequence.new(1.4)
				e.Size = NumberSequence.new(0.5)
				e.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.15),
					NumberSequenceKeypoint.new(0.85, 0.25),
					NumberSequenceKeypoint.new(1, 1),
				})
			end
		end

		local function burstWorld()
			if wEmitter then
				wEmitter:Emit(math.clamp(math.floor(F.worldRate * 0.16), 30, 140))
			end
		end

		local function stopWorld()
			if wConn then
				pcall(function()
					wConn:Disconnect()
				end)
				wConn = nil
			end
			if wPart then
				pcall(function()
					wPart:Destroy()
				end)
				wPart = nil
			end
			wEmitter = nil
		end

		local function startWorld()
			stopWorld()

			wPart = Instance.new("Part")
			wPart.Name = "WorldFX"
			wPart.Anchored = true
			wPart.CanCollide = false
			wPart.CanQuery = false
			wPart.CanTouch = false
			wPart.Transparency = 1
			wPart.Size = Vector3.new(SPAN, TALL, SPAN)
			wPart.Parent = workspace

			wEmitter = Instance.new("ParticleEmitter")
			pcall(function()
				wEmitter.Shape = Enum.ParticleEmitterShape.Box
				wEmitter.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
			end)
			wEmitter.Parent = wPart
			styleEmitter()

			wConn = RS.RenderStepped:Connect(function()
				local cam = workspace.CurrentCamera
				if not (wPart and wPart.Parent and cam) then
					return
				end

				local cf = cam.CFrame
				local look = cf.LookVector
				local flat = Vector3.new(look.X, 0, look.Z)
				flat = flat.Magnitude < 0.05 and Vector3.new(0, 0, -1) or flat.Unit
				wPart.CFrame = CFrame.new(cf.Position + flat * (SPAN * 0.22) + Vector3.new(0, TALL * 0.5 - 26, 0))
			end)

			burstWorld()
		end

		----------------------------------------------------------------
		-- Death effects
		----------------------------------------------------------------
		local ghosts, folders = {}, {}

		local function ghostClone(char)
			char.Archivable = true
			local ok, clone = pcall(function()
				return char:Clone()
			end)
			if not ok or not clone then
				return
			end

			for _, d in ipairs(clone:GetDescendants()) do
				if d:IsA("BasePart") then
					d.Anchored = true
					d.CanCollide = false
					d.CanQuery = false
					d.CanTouch = false

					if d.Name == "HumanoidRootPart" then
						d.Transparency = 1
					else
						d.Material = Enum.Material.ForceField
						d.Color = F.color
					end
				elseif d:IsA("Humanoid") or d:IsA("BaseScript") or d:IsA("Sound") or d:IsA("SurfaceAppearance")
					or d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam") or d:IsA("Highlight") or d:IsA("Light") then
					pcall(function()
						d:Destroy()
					end)
				end
			end

			clone.Name = "DeathGhost"
			clone.Parent = workspace
			ghosts[#ghosts + 1] = clone

			local life = F.duration
			task.delay(math.max(life - 1, 0.2), function()
				if not clone.Parent then
					return
				end
				for _, d in ipairs(clone:GetDescendants()) do
					if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then
						pcall(function()
							TweenService:Create(d, TweenInfo.new(1, Enum.EasingStyle.Linear), { Transparency = 1 }):Play()
						end)
					end
				end
			end)

			task.delay(life, function()
				for i = #ghosts, 1, -1 do
					if ghosts[i] == clone then
						table.remove(ghosts, i)
					end
				end
				if clone.Parent then
					clone:Destroy()
				end
			end)
		end

		local function orbBurst(char)
			local folder = Instance.new("Folder")
			folder.Name = "DeathOrbs"
			folder.Parent = workspace
			folders[#folders + 1] = folder

			local rnd = math.random
			local made = 0

			for _, part in ipairs(char:GetChildren()) do
				if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and made < 120 then
					for _ = 1, 8 do
						local s = part.Size
						local pos = part.CFrame:PointToWorldSpace(Vector3.new(
							(rnd() - 0.5) * s.X * 1.3,
							(rnd() - 0.5) * s.Y * 1.3,
							(rnd() - 0.5) * s.Z * 1.3
						))
						local d = 0.12 + rnd() * 0.12
						local ball = Instance.new("Part")
						ball.Shape = Enum.PartType.Ball
						ball.Material = Enum.Material.Neon
						ball.Color = F.color
						ball.Size = Vector3.new(0.02, 0.02, 0.02)
						ball.Position = pos
						ball.Anchored = true
						ball.CanCollide = false
						ball.CanQuery = false
						ball.CanTouch = false
						ball.CastShadow = false
						ball.Transparency = 0.1
						ball.Parent = folder
						made += 1

						TweenService:Create(ball, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
							Size = Vector3.new(d, d, d),
						}):Play()

						local rise = F.duration * 0.6
						task.delay(F.duration * 0.3, function()
							if ball.Parent then
								TweenService:Create(ball, TweenInfo.new(rise, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
									Position = pos + Vector3.new((rnd() - 0.5) * 2, 2 + rnd() * 3, (rnd() - 0.5) * 2),
									Transparency = 1,
									Size = Vector3.new(0.02, 0.02, 0.02),
								}):Play()
							end
						end)
					end
				end
			end

			Debris:AddItem(folder, F.duration + 0.5)
		end

		local function sparkBurst(char)
			local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart")
			if not root then
				return
			end

			local p = Instance.new("Part")
			p.Anchored = true
			p.CanCollide = false
			p.CanQuery = false
			p.CanTouch = false
			p.Transparency = 1
			p.Size = Vector3.new(1, 1, 1)
			p.CFrame = CFrame.new(root.Position)
			p.Parent = workspace

			local e = Instance.new("ParticleEmitter")
			e.Rate = 0
			e.Texture = "rbxasset://textures/particles/sparkles_main.dds"
			e.Color = ColorSequence.new(F.color)
			e.LightEmission = 1
			e.LightInfluence = 0
			e.Speed = NumberRange.new(15, 30)
			e.Lifetime = NumberRange.new(0.6, math.max(F.duration * 0.6, 0.7))
			e.SpreadAngle = Vector2.new(360, 360)
			e.Drag = 3
			e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0) })
			e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
			e.Parent = p
			e:Emit(50)

			Debris:AddItem(p, F.duration + 1)
		end

		-- Custom aura (asset 96578040525953) played at the body when someone dies
		-- Auras you can pick in the "Death Effect Type" dropdown (name -> asset id)
		-- NOTE: the first aura has no name from you yet, rename "Custom Aura" below if you want
		local AURAS = {
			{ name = "Custom Aura", id = 96578040525953 },
			{ name = "Energy Aura", id = 11760581403 },
			{ name = "Dacknest Aura", id = 80145706481445 },
		}
		local AURA_BY_NAME = {}
		local AURA_NAMES = {}
		for _, a in ipairs(AURAS) do
			AURA_BY_NAME[a.name] = a
			AURA_NAMES[#AURA_NAMES + 1] = a.name
		end

		local auraTemplates = {}

		local function loadAura(aura)
			local cached = auraTemplates[aura.id]
			if cached then
				return cached
			end

			-- executor loader first, InsertService as a fallback
			local ok, objs = pcall(function()
				return game:GetObjects("rbxassetid://" .. aura.id)
			end)
			if ok and type(objs) == "table" and objs[1] then
				auraTemplates[aura.id] = objs[1]
				return objs[1]
			end

			local ok2, model = pcall(function()
				return game:GetService("InsertService"):LoadAsset(aura.id)
			end)
			if ok2 and model then
				auraTemplates[aura.id] = model
				return model
			end
		end

		-- preload all auras so the first death doesn't lag
		task.spawn(function()
			for _, a in ipairs(AURAS) do
				pcall(loadAura, a)
			end
		end)

		local function auraBurst(char, aura)
			local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart")
			if not root then
				return
			end

			local origin = root.CFrame
			local life = F.duration

			local holder = Instance.new("Folder")
			holder.Name = "DeathAura_" .. aura.name:gsub("%s", "")
			holder.Parent = workspace
			folders[#folders + 1] = holder

			local tpl = loadAura(aura)
			if tpl then
				local obj = tpl:Clone()
				local model = Instance.new("Model")
				model.Name = "AuraModel"

				-- if LoadAsset returned a wrapper model, take its children
				if tpl:IsA("Model") and #tpl:GetChildren() > 0 and not tpl:FindFirstChildWhichIsA("BasePart") then
					for _, c in ipairs(obj:GetChildren()) do
						c.Parent = model
					end
					obj:Destroy()
				else
					obj.Parent = model
				end

				local all = model:GetDescendants()
				for _, d in ipairs(all) do
					if d:IsA("BaseScript") then
						pcall(function()
							d:Destroy()
						end)
					elseif d:IsA("BasePart") then
						d.Anchored = true
						d.CanCollide = false
						d.CanQuery = false
						d.CanTouch = false
						d.Massless = true
					end
				end

				model.Parent = holder

				-- normalise to a medium size: about 1.3x the player's height, times the Aura Size slider
				pcall(function()
					local charH = math.max(char:GetExtentsSize().Y, 3)
					local ext = model:GetExtentsSize()
					local biggest = math.max(ext.X, ext.Y, ext.Z)
					if biggest > 0.05 then
						model:ScaleTo(model:GetScale() * (charH * 1.3 * F.auraScale) / biggest)
					end
				end)

				pcall(function()
					model:PivotTo(origin)
				end)

				local emitters = {}
				for _, d in ipairs(model:GetDescendants()) do
					if d:IsA("ParticleEmitter") then
						d.Enabled = true
						pcall(function()
							d:Emit(d:GetAttribute("EmitCount") or 15)
						end)
						emitters[#emitters + 1] = d
					elseif d:IsA("Beam") or d:IsA("Trail") or d:IsA("Light") then
						d.Enabled = true
					end
				end

				-- stop emitting near the end so it fades out naturally
				task.delay(math.max(life * 0.7, 0.3), function()
					for _, e in ipairs(emitters) do
						pcall(function()
							e.Enabled = false
						end)
					end
				end)
			else
				-- fallback: asset is an image/texture, so use it as a particle
				local p = Instance.new("Part")
				p.Anchored = true
				p.CanCollide = false
				p.CanQuery = false
				p.CanTouch = false
				p.Transparency = 1
				p.Size = Vector3.new(1, 1, 1)
				p.CFrame = origin
				p.Parent = holder

				local e = Instance.new("ParticleEmitter")
				e.Rate = 0
				e.Texture = "rbxassetid://" .. aura.id
				e.Color = ColorSequence.new(F.color)
				e.LightEmission = 1
				e.LightInfluence = 0
				e.Speed = NumberRange.new(1, 4)
				e.Lifetime = NumberRange.new(math.max(life * 0.6, 0.6), math.max(life, 0.8))
				e.SpreadAngle = Vector2.new(25, 25)
				e.EmissionDirection = Enum.NormalId.Top
				e.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 2.5 * F.auraScale),
					NumberSequenceKeypoint.new(1, 4.5 * F.auraScale),
				})
				e.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.2),
					NumberSequenceKeypoint.new(1, 1),
				})
				e.Parent = p
				e:Emit(6)
			end

			Debris:AddItem(holder, life + 1.5)
		end

		local function trigger(char)
			local mode = F.mode
			if mode == "Ghost Clone" or mode == "All" then
				ghostClone(char)
			end
			if mode == "Orb Burst" or mode == "All" then
				orbBurst(char)
			end
			if mode == "Spark Burst" or mode == "All" then
				sparkBurst(char)
			end
			if mode == "All" then
				for _, a in ipairs(AURAS) do
					auraBurst(char, a)
				end
			elseif AURA_BY_NAME[mode] then
				auraBurst(char, AURA_BY_NAME[mode])
			end
		end

		local function hookPlayer(p)
			local function onChar(char)
				local hum = char:WaitForChild("Humanoid", 5)
				if not hum then
					return
				end

				hum.Died:Connect(function()
					local isMurd = p == func15()
					local want = (F.mOn and isMurd) or (F.pOn and (p ~= localPlayer or F.pSelf))
					if want then
						pcall(trigger, char)
					end
				end)
			end

			if p.Character then
				task.spawn(onChar, p.Character)
			end
			list2.conns[#list2.conns + 1] = p.CharacterAdded:Connect(onChar)
		end

		for _, p in ipairs(Players:GetPlayers()) do
			hookPlayer(p)
		end
		list2.conns[#list2.conns + 1] = Players.PlayerAdded:Connect(hookPlayer)

		list2.conns[#list2.conns + 1] = {
			Disconnect = function()
				F.world, F.mOn, F.pOn = false, false, false
				stopWorld()
				for _, g in ipairs(ghosts) do
					pcall(function()
						g:Destroy()
					end)
				end
				ghosts = {}
				for _, f in ipairs(folders) do
					pcall(function()
						f:Destroy()
					end)
				end
				folders = {}
			end,
		}

		----------------------------------------------------------------
		-- UI (Visuals tab)
		----------------------------------------------------------------
		tbl43.visuals:Section({ Title = "World Effects" })

		tbl43.visuals:Toggle({
			Title = "World Effects", Flag = "Toggle_Fx_World", Desc = "Snow or sakura petals falling around you",
			Type = "Toggle", Value = false,
			Callback = function(v)
				F.world = v
				if v then startWorld() else stopWorld() end
			end,
		})

		tbl43.visuals:Dropdown({
			Title = "World Effect Type", Flag = "Dropdown_Fx_WorldType", Multi = false, Value = "Snow",
			Values = { "Snow", "Sakura" },
			Callback = function(v)
				F.worldType = pick(v) or "Snow"
				if F.world then
					styleEmitter()
					burstWorld()
				end
			end,
		})

		tbl43.visuals:Colorpicker({
			Title = "World Effect Colour", Flag = "Colorpicker_Fx_World", Default = F.worldColor,
			Callback = function(c)
				F.worldColor = c
				if wEmitter then wEmitter.Color = ColorSequence.new(c) end
			end,
		})

		tbl43.visuals:Slider({
			Title = "World Effect Amount", Flag = "Slider_Fx_World_Amount", Step = 10,
			Value = { Min = 20, Max = 900, Default = 250 },
			Callback = function(v)
				F.worldRate = tonumber(v) or 250
				if wEmitter then
					styleEmitter()
					burstWorld()
				end
			end,
		})

		tbl43.visuals:Section({ Title = "Death Effects" })

		tbl43.visuals:Toggle({
			Title = "Murderer Death Effect", Flag = "Toggle_Fx_MurdDeath", Desc = "Plays the effects below when the murderer dies",
			Type = "Toggle", Value = false,
			Callback = function(v) F.mOn = v end,
		})

		tbl43.visuals:Toggle({
			Title = "Player Death Effect", Flag = "Toggle_Fx_PlayerDeath", Desc = "Plays the effects below when any player dies",
			Type = "Toggle", Value = false,
			Callback = function(v) F.pOn = v end,
		})

		tbl43.visuals:Toggle({
			Title = "Include Yourself", Flag = "Toggle_Fx_DeathSelf", Desc = "Also play it when you die (Player Death Effect)",
			Type = "Toggle", Value = false,
			Callback = function(v) F.pSelf = v end,
		})

		local typeValues = {}
		for _, n in ipairs(AURA_NAMES) do
			typeValues[#typeValues + 1] = n
		end
		for _, n in ipairs({ "Ghost Clone", "Orb Burst", "Spark Burst", "All" }) do
			typeValues[#typeValues + 1] = n
		end

		tbl43.visuals:Dropdown({
			Title = "Death Effect Type", Flag = "Dropdown_Fx_DeathType", Multi = false, Value = "Custom Aura",
			Values = typeValues,
			Callback = function(v) F.mode = pick(v) or "Custom Aura" end,
		})

		tbl43.visuals:Slider({
			Title = "Aura Size", Flag = "Slider_Fx_Aura_Size", Step = 0.1,
			Value = { Min = 0.5, Max = 3, Default = 1 },
			Callback = function(v) F.auraScale = tonumber(v) or 1 end,
		})

		tbl43.visuals:Colorpicker({
			Title = "Death Effect Colour", Flag = "Colorpicker_Fx_Death", Default = F.color,
			Callback = function(c) F.color = c end,
		})

		tbl43.visuals:Slider({
			Title = "Death Effect Duration", Flag = "Slider_Fx_Death_Duration", Step = 0.1,
			Value = { Min = 0.5, Max = 6, Default = 2 },
			Callback = function(v) F.duration = tonumber(v) or 2 end,
		})
	end

	installFx()
end

-- ===================== LOCAL: Korblox / Backtrack / Movement Graph / Pixel Surf =====================
do
	local function installLocal()
		local RS = game:GetService("RunService")
		local Stats = game:GetService("Stats")
		local ws = workspace

		local function pingSec()
			local ok, v = pcall(function()
				return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
			end)
			return ok and v / 1000 or 0.12
		end

		local function charParts()
			local c = localPlayer.Character
			return c and c:FindFirstChild("HumanoidRootPart"), c, c and c:FindFirstChildOfClass("Humanoid")
		end

		----------------------------------------------------------------
		-- Fake Korblox (right leg, R15 only, local only)
		----------------------------------------------------------------
		local K = { on = false, backup = {} }
		local KORBLOX = {
			RightUpperLeg = { MeshId = "rbxassetid://902942096", TextureID = "rbxassetid://902843398" },
			RightLowerLeg = { MeshId = "rbxassetid://902942093", Transparency = 1 },
			RightFoot = { MeshId = "rbxassetid://902942089", Transparency = 1 },
		}

		local function korbloxRestore()
			local c = localPlayer.Character
			if c then
				for name, b in pairs(K.backup) do
					local p = c:FindFirstChild(name)
					if p then
						pcall(function()
							p.MeshId = b.MeshId
							if b.TextureID then
								p.TextureID = b.TextureID
							end
							p.Transparency = b.Transparency
						end)
					end
				end
			end
			K.backup = {}
		end

		local function korbloxApply()
			if not K.on then
				return
			end
			local c = localPlayer.Character
			local ru = c and c:FindFirstChild("RightUpperLeg")
			if not ru or not ru:IsA("MeshPart") then
				return
			end

			for name, def in pairs(KORBLOX) do
				local p = c:FindFirstChild(name)
				if p and p:IsA("MeshPart") then
					if not K.backup[name] then
						K.backup[name] = { MeshId = p.MeshId, TextureID = p.TextureID, Transparency = p.Transparency }
					end
					if p.MeshId ~= def.MeshId then
						pcall(function()
							p.MeshId = def.MeshId
							if def.TextureID then
								p.TextureID = def.TextureID
							end
							if def.Transparency then
								p.Transparency = def.Transparency
							end
						end)
					end
				end
			end
		end

		list2.conns[#list2.conns + 1] = localPlayer.CharacterAdded:Connect(function()
			K.backup = {}
			task.wait(1)
			korbloxApply()
		end)

		----------------------------------------------------------------
		-- Backtrack (ghost showing where the server sees you: delayed by ping)
		----------------------------------------------------------------
		local B = { on = false, color = Color3.fromRGB(255, 60, 60), model = nil, pairs = {}, char = nil, hist = {}, ping = 0.12, pingAt = 0 }

		local function btDestroy()
			if B.model then
				pcall(function()
					B.model:Destroy()
				end)
			end
			B.model, B.pairs, B.char, B.hist = nil, {}, nil, {}
		end

		local function btBuild()
			btDestroy()
			local hrp, char = charParts()
			if not hrp then
				return
			end

			char.Archivable = true
			local ok, m = pcall(function()
				return char:Clone()
			end)
			if not ok or not m then
				return
			end

			local real = {}
			for _, d in ipairs(char:GetDescendants()) do
				if d:IsA("BasePart") then
					real[#real + 1] = d
				end
			end

			local i = 0
			for _, d in ipairs(m:GetDescendants()) do
				if d:IsA("BaseScript") or d:IsA("Decal") or d:IsA("Texture") or d:IsA("SurfaceAppearance")
					or d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("Trail") or d:IsA("Light") or d:IsA("Sound") then
					pcall(function()
						d:Destroy()
					end)
				elseif d:IsA("BasePart") then
					i += 1
					local rp = real[i]
					d.Anchored = true
					d.CanCollide = false
					d.CanQuery = false
					d.CanTouch = false
					d.Massless = true
					d.CastShadow = false

					if d.Name == "HumanoidRootPart" or (rp and rp.Transparency > 0.95) then
						d.Transparency = 1
					else
						d.Material = Enum.Material.ForceField
						d.Color = B.color
						d.Transparency = 0
					end

					B.pairs[#B.pairs + 1] = { d, rp }
				end
			end

			local hum = m:FindFirstChildOfClass("Humanoid")
			if hum then
				pcall(function()
					hum:Destroy()
				end)
			end

			m.Name = "BacktrackGhost"
			m.Parent = ws
			B.model, B.char = m, char
		end

		local function btStep(now)
			if not B.on then
				return
			end

			local hrp, char = charParts()
			if not hrp then
				return
			end

			if not B.model or B.char ~= char or not B.model.Parent then
				btBuild()
				if not B.model then
					return
				end
			end

			if now - B.pingAt > 0.25 then
				B.pingAt = now
				B.ping = math.clamp(pingSec(), 0.05, 0.6)
			end

			local hist = B.hist
			hist[#hist + 1] = { now, hrp.CFrame }
			while #hist > 2 and hist[1][1] < now - 1.5 do
				table.remove(hist, 1)
			end

			local target = now - B.ping
			local dcf = hist[1][2]
			for i = #hist, 1, -1 do
				if hist[i][1] <= target then
					dcf = hist[i][2]
					break
				end
			end

			local inv = hrp.CFrame
			for _, pr in ipairs(B.pairs) do
				local part, rp = pr[1], pr[2]
				if part.Parent and rp and rp.Parent then
					part.CFrame = dcf * inv:ToObjectSpace(rp.CFrame)
				end
			end
		end

		list2.conns[#list2.conns + 1] = RS.Heartbeat:Connect(function()
			pcall(btStep, os.clock())
			if K.on then
				pcall(korbloxApply)
			end
		end)

		----------------------------------------------------------------
		-- Movement graph (speed over time, Drawing)
		----------------------------------------------------------------
		local hasDrawing = false
		pcall(function()
			local t = Drawing.new("Line")
			t:Remove()
			hasDrawing = true
		end)

		local G = {
			on = false, color = Color3.fromRGB(242, 242, 242),
			w = 280, h = 72, y = 105,
			N = 84, step = 1 / 30, acc = 0, samples = {}, lines = {}, text = nil,
		}

		local function hSpeed()
			local hrp = charParts()
			if not hrp then
				return 0
			end
			local v = hrp.AssemblyLinearVelocity
			return Vector3.new(v.X, 0, v.Z).Magnitude
		end

		local function graphClear()
			for _, l in ipairs(G.lines) do
				pcall(function()
					l:Remove()
				end)
			end
			G.lines = {}
			if G.text then
				pcall(function()
					G.text:Remove()
				end)
				G.text = nil
			end
			G.samples, G.acc = {}, 0
		end

		local function graphStart()
			graphClear()
			local s = hSpeed()
			for i = 1, G.N do
				G.samples[i] = s
			end
		end

		local function graphStep(dt)
			if not G.on or not hasDrawing then
				return
			end

			local cam = ws.CurrentCamera
			if not cam or #G.samples == 0 then
				return
			end

			G.acc += dt
			while G.acc >= G.step do
				G.acc -= G.step
				table.remove(G.samples, 1)
				G.samples[#G.samples + 1] = hSpeed()
			end

			local _, _, hum = charParts()
			local ref = math.max(1, hum and hum.WalkSpeed or 16)
			local vp = cam.ViewportSize
			local w = math.min(G.w, math.max(120, vp.X - 48))
			local h = math.min(G.h, math.max(36, vp.Y - 32))
			local left = math.floor(vp.X * 0.5 - w * 0.5)
			local center = math.clamp(vp.Y * 0.5 + G.y, h * 0.5 + 8, vp.Y - h * 0.5 - 8)
			local n = #G.samples

			local function yOf(v)
				return center - math.clamp(v / ref - 1, -1, 1) * h * 0.44
			end

			for i = 1, n - 1 do
				local ln = G.lines[i]
				if not ln then
					ln = Drawing.new("Line")
					ln.Thickness = 1.5
					ln.ZIndex = 902
					G.lines[i] = ln
				end

				local ap, bp = (i - 1) / (n - 1), i / (n - 1)
				ln.Color = G.color
				ln.From = Vector2.new(left + ap * w, yOf(G.samples[i]))
				ln.To = Vector2.new(left + bp * w, yOf(G.samples[i + 1]))
				ln.Transparency = math.clamp(math.min(bp * 6, (1 - ap) * 6), 0, 1)
				ln.Visible = true
			end

			if not G.text then
				G.text = Drawing.new("Text")
				G.text.Size = 13
				G.text.Outline = true
				G.text.ZIndex = 904
			end
			G.text.Color = G.color
			G.text.Text = tostring(math.floor(G.samples[n] + 0.5))
			G.text.Position = Vector2.new(left + w + 8, center - 7)
			G.text.Visible = true
		end

		list2.conns[#list2.conns + 1] = RS.RenderStepped:Connect(function(dt)
			pcall(graphStep, dt)
		end)

		----------------------------------------------------------------
		-- Pixel Surf (glide along ledges / wall seams)
		----------------------------------------------------------------
		local S = {
			on = false, speed = 34, active = false, sign = 0, seen = 0,
			lock = nil, part = nil, solid = nil,
		}
		local sParams = RaycastParams.new()
		sParams.FilterType = Enum.RaycastFilterType.Exclude
		sParams.IgnoreWater = true

		local RANGE, LEN, DEPTH, THICK, UP, DOWN = 5, 11, 2.6, 1.6, 2.9, 2.4
		local ANG = { 0, 0.3, -0.3, 0.62, -0.62, 0.95, -0.95 }
		local OFF = { -0.35, -0.15, 0.06, 0.26, 0.5, 0.85, 1.25 }
		local DROP = Vector3.new(0, -(UP + DOWN + 0.2), 0)
		local GROUND = Vector3.new(0, -(DOWN + 4), 0)

		local function flatUnit(v)
			local f = Vector3.new(v.X, 0, v.Z)
			return f.Magnitude > 1e-3 and f.Unit or Vector3.zero
		end

		local function sPlatform()
			if not S.part then
				local p = Instance.new("Part")
				p.Name = "PixelStep"
				p.Anchored = true
				p.CanCollide = false
				p.CanQuery = false
				p.CanTouch = false
				p.Transparency = 1
				p.CustomPhysicalProperties = PhysicalProperties.new(0.01, 0, 0, 100, 1)
				p.Size = Vector3.new(LEN, THICK, DEPTH)
				S.part = p
			end
			if S.part.Parent ~= ws then
				S.part.Parent = ws
			end
			return S.part
		end

		local function sHide()
			if S.part then
				if S.part.Parent then
					S.part.Parent = nil
				end
				S.part.CanCollide = false
			end
			S.solid, S.sign, S.lock, S.active = nil, 0, nil, false
		end

		local function sCast(origin, dir)
			sParams.FilterDescendantsInstances = { localPlayer.Character, S.part }
			return ws:Raycast(origin, dir, sParams)
		end

		local function sYaw(v, a)
			local c, s = math.cos(a), math.sin(a)
			return Vector3.new(v.X * c + v.Z * s, 0, v.Z * c - v.X * s)
		end

		local function sProbe(origin, feet, dir)
			local hit = sCast(origin, dir)
			if hit and math.abs(hit.Normal.Y) < 0.45 then
				return hit
			end
			hit = sCast(Vector3.new(origin.X, feet + 0.8, origin.Z), dir)
			if hit and math.abs(hit.Normal.Y) < 0.45 then
				return hit
			end
		end

		local function sWall(hrp, feet, move, look)
			for pass = 1, 2 do
				local base = pass == 1 and move or look
				if base ~= Vector3.zero and (pass == 1 or move == Vector3.zero or move:Dot(look) < 0.99) then
					for i = 1, #ANG do
						local hit = sProbe(hrp.Position, feet, sYaw(base, ANG[i]) * RANGE)
						if hit then
							return hit
						end
					end
				end
			end
		end

		local function sScan(hrp, hum, move, look, hold)
			local feet = hum.HipHeight > 0 and (hrp.Position.Y - hrp.Size.Y * 0.5 - hum.HipHeight) or (hrp.Position.Y - 3)
			local wall = sWall(hrp, feet, move, look)
			if not wall then
				return
			end

			local n = flatUnit(wall.Normal)
			if n == Vector3.zero then
				return
			end

			local ground = sCast(hrp.Position, GROUND)
			local gy = ground and ground.Position.Y or -1e9
			local best, top, tp

			for i = 1, #OFF do
				local o = wall.Position + n * OFF[i]
				local hit = sCast(Vector3.new(o.X, feet + UP, o.Z), DROP)
				if hit and hit.Normal.Y > 0.35 then
					local y = hit.Position.Y
					if y > gy + 0.75 and y < feet + UP - 0.25 and y > feet - DOWN then
						local score
						if hold then
							score = math.abs(y - hold)
						elseif y >= feet - 0.3 then
							score = y - feet
						else
							score = 1000 - y
						end
						if not best or score < best then
							best, top, tp = score, y, hit.Position
						end
					end
				end
			end

			if not top then
				return
			end
			return Vector3.new(tp.X, top, tp.Z), n, feet
		end

		local function surfStep(dt)
			if not S.on then
				return
			end

			local hrp, char, hum = charParts()
			if not hrp or not hum or hum.Health <= 0 then
				sHide()
				return
			end

			local cam = ws.CurrentCamera
			local move = flatUnit(hum.MoveDirection)
			local look = cam and flatUnit(cam.CFrame.LookVector) or Vector3.zero
			local pos, n, feet = sScan(hrp, hum, move, look, S.active and S.lock and S.lock.Y or nil)

			if not pos then
				if os.clock() - S.seen > 0.3 then
					sHide()
				end
				return
			end

			local tangent = flatUnit(n:Cross(Vector3.yAxis))
			if tangent == Vector3.zero then
				return
			end

			local hp = hrp.Position
			local dx, dz = pos.X - hp.X, pos.Z - hp.Z
			local dist = math.sqrt(dx * dx + dz * dz)
			local push = move ~= Vector3.zero and move:Dot(n) or 0

			if S.active then
				if dist > 4.5 or push > 0.5 then
					sHide()
					return
				end
			elseif hum.FloorMaterial ~= Enum.Material.Air or dist > 2.8 or move == Vector3.zero or push > -0.15 then
				if os.clock() - S.seen > 0.3 then
					sHide()
				end
				return
			end

			S.seen = os.clock()
			local step = math.min(dt or 0.016, 0.1)

			if S.lock and (S.lock - pos).Magnitude < 2 then
				pos = S.lock:Lerp(pos, 1 - math.exp(-16 * step))
			end
			S.lock = pos

			local p = sPlatform()
			local center = pos + n * (DEPTH * 0.5 - 0.45) - Vector3.new(0, THICK * 0.5 + 0.02, 0)
			p.CFrame = CFrame.lookAt(center, center - n)

			local solid = S.solid
			if feet >= pos.Y - 0.06 then
				solid = true
			elseif feet < pos.Y - 0.55 then
				solid = false
			end
			if S.solid ~= solid then
				S.solid = solid
				p.CanCollide = solid
			end

			S.active = true

			local along = move:Dot(tangent)
			if math.abs(along) > 0.35 then
				S.sign = along > 0 and 1 or -1
			elseif S.sign == 0 then
				S.sign = (look:Dot(tangent) < 0) and -1 or 1
			end

			local v = hrp.AssemblyLinearVelocity
			local err = pos.Y - feet
			local vy
			if err > 0.05 then
				vy = math.min(err * 14 + 1.5, 34)
			elseif err < -0.4 then
				vy = math.max(v.Y, err * 8)
			elseif v.Y > 0 then
				vy = v.Y
			else
				vy = err * 8
			end

			local blend = 1 - math.exp(-14 * step)
			local cur = v.X * tangent.X + v.Z * tangent.Z
			local speed = cur + (S.speed * S.sign - cur) * blend
			local gap = (hp.X - pos.X) * n.X + (hp.Z - pos.Z) * n.Z
			local hug = math.clamp((0.75 - gap) * 9, -9, 9)
			local glide = tangent * speed + n * hug

			hrp.AssemblyLinearVelocity = Vector3.new(glide.X, vy, glide.Z)
		end

		list2.conns[#list2.conns + 1] = RS.Stepped:Connect(function(_, dt)
			pcall(surfStep, dt)
		end)

		list2.conns[#list2.conns + 1] = {
			Disconnect = function()
				K.on, B.on, G.on, S.on = false, false, false, false
				korbloxRestore()
				btDestroy()
				graphClear()
				sHide()
				if S.part then
					pcall(function()
						S.part:Destroy()
					end)
					S.part = nil
				end
			end,
		}

		----------------------------------------------------------------
		-- UI
		----------------------------------------------------------------
		-- Fake Korblox lives in the Troll & Fun tab (built together with Fake Headless)
		list2.mkKorblox = function()
		tbl43.troll:Toggle({
			Title = "Fake Korblox", Flag = "Toggle_Local_Korblox",
			Desc = "Korblox right leg (R15 only, only you see it)",
			Type = "Toggle", Value = false,
			Callback = function(v)
				K.on = v
				if v then korbloxApply() else korbloxRestore() end
			end,
		})
		end

		tbl43.player:Section({ Title = "Movement Tricks" })

		tbl43.player:Toggle({
			Title = "Pixel Surf", Flag = "Toggle_Local_PixelSurf",
			Desc = "Catches ledges and map seams, then slides along them. Walk into a wall edge while in the air.",
			Type = "Toggle", Value = false,
			Callback = function(v)
				S.on = v
				if not v then sHide() end
			end,
		})

		tbl43.player:Slider({
			Title = "Pixel Surf Speed", Flag = "Slider_Local_PixelSurf_Speed", Step = 1,
			Value = { Min = 8, Max = 90, Default = 34 },
			Callback = function(v) S.speed = tonumber(v) or 34 end,
		})

		tbl43.visuals:Section({ Title = "Local" })

		tbl43.visuals:Toggle({
			Title = "Backtrack", Flag = "Toggle_Local_Backtrack",
			Desc = "Ghost of your character showing where the server sees you (delayed by ping)",
			Type = "Toggle", Value = false,
			Callback = function(v)
				B.on = v
				if not v then btDestroy() end
			end,
		})

		tbl43.visuals:Colorpicker({
			Title = "Backtrack Colour", Flag = "Colorpicker_Local_Backtrack", Default = B.color,
			Callback = function(c)
				B.color = c
				if B.model then
					for _, pr in ipairs(B.pairs) do
						if pr[1].Transparency < 1 then
							pr[1].Color = c
						end
					end
				end
			end,
		})

		tbl43.visuals:Toggle({
			Title = "Movement Graph", Flag = "Toggle_Local_MovGraph",
			Desc = "On-screen graph of your horizontal speed",
			Type = "Toggle", Value = false,
			Callback = function(v)
				if v and not hasDrawing then
					obj2:Notify({ Title = "Movement Graph", Content = "Your executor has no Drawing library.", Duration = 2, Icon = "x" })
				end
				G.on = v
				if v then graphStart() else graphClear() end
			end,
		})

		tbl43.visuals:Colorpicker({
			Title = "Graph Colour", Flag = "Colorpicker_Local_MovGraph", Default = G.color,
			Callback = function(c) G.color = c end,
		})

		tbl43.visuals:Slider({
			Title = "Graph Width", Flag = "Slider_Local_MovGraph_Width", Step = 5,
			Value = { Min = 180, Max = 420, Default = 280 },
			Callback = function(v) G.w = tonumber(v) or 280 end,
		})

		tbl43.visuals:Slider({
			Title = "Graph Height", Flag = "Slider_Local_MovGraph_Height", Step = 2,
			Value = { Min = 40, Max = 120, Default = 72 },
			Callback = function(v) G.h = tonumber(v) or 72 end,
		})

		tbl43.visuals:Slider({
			Title = "Graph Y Position", Flag = "Slider_Local_MovGraph_Y", Step = 5,
			Value = { Min = -200, Max = 400, Default = 105 },
			Callback = function(v) G.y = tonumber(v) or 105 end,
		})
	end

	installLocal()
end

-- ===================== MORE: Jump Circle / Trails / Role names / Random spawn / Rejoin =====================
do
	local function installMore()
		local RS = game:GetService("RunService")
		local TweenService = game:GetService("TweenService")
		local Debris = game:GetService("Debris")
		local TeleportService = game:GetService("TeleportService")

		local function notify(title, text, icon)
			obj2:Notify({ Title = title, Content = text, Duration = 2, Icon = icon or "x" })
		end

		local function pick(v)
			if type(v) == "table" then
				v = v[1] or v.Value
			end
			return v and tostring(v) or nil
		end

		local function myParts()
			local c = localPlayer.Character
			return c and c:FindFirstChild("HumanoidRootPart"), c, c and c:FindFirstChildOfClass("Humanoid")
		end

		local J = { circle = false, circleColor = Color3.fromRGB(255, 255, 255), wasJump = false }
		local T = {
			on = false, style = "Rainbow", color = Color3.fromRGB(133, 220, 255),
			life = 0.8, width = 1, trail = nil, a0 = nil, a1 = nil, hrp = nil,
		}

		----------------------------------------------------------------
		-- Jump circle
		----------------------------------------------------------------
		local function ring(pos, color)
			local r = Instance.new("Part")
			r.Shape = Enum.PartType.Cylinder
			r.Material = Enum.Material.Neon
			r.Color = color
			r.Anchored = true
			r.CanCollide = false
			r.CanQuery = false
			r.CanTouch = false
			r.CastShadow = false
			r.Transparency = 0.25
			r.Size = Vector3.new(0.12, 1, 1)
			r.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.pi / 2)
			r.Parent = workspace

			TweenService:Create(r, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new(0.12, 8, 8),
				Transparency = 1,
			}):Play()
			Debris:AddItem(r, 0.7)
		end

		local function jumpStep()
			if not J.circle then
				J.wasJump = false
				return
			end

			local hrp, _, hum = myParts()
			if not hrp or not hum then
				return
			end

			local jumping = hum:GetState() == Enum.HumanoidStateType.Jumping
			if jumping and not J.wasJump then
				ring(hrp.Position - Vector3.new(0, hum.HipHeight + hrp.Size.Y / 2 - 0.1, 0), J.circleColor)
			end
			J.wasJump = jumping
		end

		----------------------------------------------------------------
		-- Trails
		----------------------------------------------------------------
		local function trailSequence()
			if T.style == "Rainbow" then
				local k = {}
				for i = 0, 6 do
					k[#k + 1] = ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 7, 0.85, 1))
				end
				return ColorSequence.new(k)
			elseif T.style == "Fire" then
				return ColorSequence.new(Color3.fromRGB(255, 220, 80), Color3.fromRGB(255, 60, 20))
			elseif T.style == "Ice" then
				return ColorSequence.new(Color3.fromRGB(220, 250, 255), Color3.fromRGB(60, 140, 255))
			elseif T.style == "Sakura" then
				return ColorSequence.new(Color3.fromRGB(255, 200, 225), Color3.fromRGB(255, 120, 170))
			end
			return ColorSequence.new(T.color)
		end

		local function trailStyle()
			if T.trail then
				T.trail.Color = trailSequence()
				T.trail.Lifetime = T.life
				T.trail.WidthScale = NumberSequence.new({
					NumberSequenceKeypoint.new(0, T.width),
					NumberSequenceKeypoint.new(1, 0),
				})
			end
		end

		local function trailDestroy()
			for _, o in ipairs({ T.trail, T.a0, T.a1 }) do
				pcall(function()
					o:Destroy()
				end)
			end
			T.trail, T.a0, T.a1, T.hrp = nil, nil, nil, nil
		end

		local function trailStep()
			if not T.on then
				return
			end

			local hrp = myParts()
			if not hrp then
				return
			end

			if T.hrp ~= hrp or not (T.trail and T.trail.Parent) then
				trailDestroy()
				T.hrp = hrp

				T.a0 = Instance.new("Attachment")
				T.a0.Name = "TrailTop"
				T.a0.Position = Vector3.new(0, 0.9, 0)
				T.a0.Parent = hrp

				T.a1 = Instance.new("Attachment")
				T.a1.Name = "TrailBottom"
				T.a1.Position = Vector3.new(0, -0.9, 0)
				T.a1.Parent = hrp

				local tr = Instance.new("Trail")
				tr.Attachment0 = T.a0
				tr.Attachment1 = T.a1
				tr.LightEmission = 1
				tr.LightInfluence = 0
				tr.FaceCamera = true
				tr.MinLength = 0.05
				tr.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.1),
					NumberSequenceKeypoint.new(1, 1),
				})
				tr.Parent = hrp
				T.trail = tr
				trailStyle()
			end
		end

		list2.conns[#list2.conns + 1] = RS.Heartbeat:Connect(function()
			pcall(jumpStep)
			pcall(trailStep)
		end)

		list2.conns[#list2.conns + 1] = {
			Disconnect = function()
				J.circle, T.on = false, false
				trailDestroy()
			end,
		}

		----------------------------------------------------------------
		-- UI
		----------------------------------------------------------------
		tbl43.visuals:Toggle({
			Title = "Jump Circle", Flag = "Toggle_More_JumpCircle", Desc = "Expanding ring under you every time you jump",
			Type = "Toggle", Value = false,
			Callback = function(v) J.circle = v end,
		})

		tbl43.visuals:Colorpicker({
			Title = "Jump Circle Colour", Flag = "Colorpicker_More_JumpCircle", Default = J.circleColor,
			Callback = function(c) J.circleColor = c end,
		})

		tbl43.visuals:Section({ Title = "Trails" })

		tbl43.visuals:Toggle({
			Title = "Trails", Flag = "Toggle_More_Trails", Desc = "A glowing trail that follows your character",
			Type = "Toggle", Value = false,
			Callback = function(v)
				T.on = v
				if not v then trailDestroy() end
			end,
		})

		tbl43.visuals:Dropdown({
			Title = "Trail Style", Flag = "Dropdown_More_TrailStyle", Multi = false, Value = "Rainbow",
			Values = { "Rainbow", "Solid", "Fire", "Ice", "Sakura" },
			Callback = function(v)
				T.style = pick(v) or "Rainbow"
				trailStyle()
			end,
		})

		tbl43.visuals:Colorpicker({
			Title = "Trail Colour (Solid)", Flag = "Colorpicker_More_Trail", Default = T.color,
			Callback = function(c)
				T.color = c
				trailStyle()
			end,
		})

		tbl43.visuals:Slider({
			Title = "Trail Length", Flag = "Slider_More_Trail_Length", Step = 0.1,
			Value = { Min = 0.2, Max = 3, Default = 0.8 },
			Callback = function(v)
				T.life = tonumber(v) or 0.8
				trailStyle()
			end,
		})

		tbl43.visuals:Slider({
			Title = "Trail Width", Flag = "Slider_More_Trail_Width", Step = 0.1,
			Value = { Min = 0.2, Max = 3, Default = 1 },
			Callback = function(v)
				T.width = tonumber(v) or 1
				trailStyle()
			end,
		})

		-- role names (ESP tab, Alerts)
		local function copyRole(label, getter)
			local p = getter()
			if not p then
				notify("Copy Name", "No " .. label:lower() .. " right now.", "x")
				return
			end

			local ok = pcall(function()
				setclipboard(p.Name)
			end)
			notify("Copy Name", ok and (label .. " name copied: " .. p.Name) or (label .. ": " .. p.Name), ok and "check" or "info")
		end

		tbl43.esp:Button({
			Title = "Copy Murderer Name",
			Desc = "Copies the murderer's username to your clipboard",
			Callback = function() copyRole("Murderer", func15) end,
		})

		tbl43.esp:Button({
			Title = "Copy Sheriff Name",
			Desc = "Copies the sheriff's username to your clipboard",
			Callback = function() copyRole("Sheriff", func16) end,
		})

		-- teleport to a random spawn (Fling & Teleport tab)
		tbl43.fling:Button({
			Title = "TP to Random Spawn",
			Desc = "Teleports you to a random spawn point on the current map",
			Callback = function()
				local folder = workspace:FindFirstChild("Spawns", true)
				local list = {}
				if folder then
					for _, c in ipairs(folder:GetChildren()) do
						if c:IsA("BasePart") then
							list[#list + 1] = c
						end
					end
				end

				local hrp = myParts()
				if #list == 0 or not hrp then
					notify("Teleport", "No spawns found. Wait for a round to start.", "x")
					return
				end

				local spawn = list[math.random(1, #list)]
				hrp.CFrame = spawn.CFrame + Vector3.new(0, 4, 0)
			end,
		})
	end

	installMore()
end

-- ===================== HIT EFFECTS (particles + sound) / CUSTOM GUN MODEL =====================
do
	local function installHitGun()
		local RS = game:GetService("RunService")
		local Debris = game:GetService("Debris")
		local SoundService = game:GetService("SoundService")
		local RepStorage = game:GetService("ReplicatedStorage")

		local function notify(title, text, icon)
			obj2:Notify({ Title = title, Content = text, Duration = 2, Icon = icon or "x" })
		end

		local function pick(v)
			if type(v) == "table" then
				v = v[1] or v.Value
			end
			return v and tostring(v) or nil
		end

		----------------------------------------------------------------
		-- Hit effects, same as the other script: every click is checked with a ray from the mouse; if the first
		-- thing it touches is another player's character, that counts as a hit -> hit sound + 8 particles.
		----------------------------------------------------------------
		local UIS = game:GetService("UserInputService")
		local TweenService = game:GetService("TweenService")

		local H = {
			particles = false, sound = false, mode = 1,
			color = Color3.fromRGB(255, 60, 60), gui = nil,
		}

		local HIT_SOUNDS = {
			"rbxassetid://140604838213617",
			"rbxassetid://130201387574815",
			"rbxassetid://135478009117226",
			"rbxassetid://96735711388006",
			"rbxassetid://126048302910782",
			"rbxassetid://7255642553",
		}

		local function playHitSound(mode)
			local s = Instance.new("Sound")
			s.SoundId = HIT_SOUNDS[mode or H.mode] or HIT_SOUNDS[1]
			s.Volume = 2
			s.Parent = SoundService
			s:Play()
			Debris:AddItem(s, 1)
		end

		-- the particles are drawn on the SCREEN (a ScreenGui), starting at where the hit point is on screen
		local function getGui()
			if H.gui and H.gui.Parent then
				return H.gui
			end

			local g = Instance.new("ScreenGui")
			g.Name = "HitParticles"
			g.ResetOnSpawn = false
			g.IgnoreGuiInset = true
			g.DisplayOrder = 50

			pcall(function()
				g.Parent = gethui and gethui() or localPlayer:WaitForChild("PlayerGui")
			end)

			if not g.Parent then
				g.Parent = localPlayer:WaitForChild("PlayerGui")
			end

			H.gui = g
			return g
		end

		local function hitParticle(worldPos)
			local cam = workspace.CurrentCamera
			if not cam then
				return
			end

			local v, onScreen = cam:WorldToViewportPoint(worldPos)
			if not onScreen or v.Z <= 0 then
				return
			end

			local size = math.random(5, 10)
			local f = Instance.new("Frame")
			f.AnchorPoint = Vector2.new(0.5, 0.5)
			f.Size = UDim2.fromOffset(size, size)
			f.Position = UDim2.fromOffset(v.X, v.Y)
			f.BackgroundColor3 = H.color
			f.BorderSizePixel = 0
			f.Rotation = math.random(0, 360)
			Instance.new("UICorner", f).CornerRadius = UDim.new(1, 0)
			f.Parent = getGui()

			local angle = math.rad(math.random(0, 359))
			local dist = math.random(40, 110)
			local life = 0.45 + math.random() * 0.35

			TweenService:Create(f, TweenInfo.new(life, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.fromOffset(v.X + math.cos(angle) * dist, v.Y + math.sin(angle) * dist),
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(2, 2),
			}):Play()

			Debris:AddItem(f, life + 0.1)
		end

		list2.conns[#list2.conns + 1] = UIS.InputBegan:Connect(function(input, processed)
			if processed or not (H.particles or H.sound) then
				return
			end

			local t = input.UserInputType
			if t ~= Enum.UserInputType.MouseButton1 and t ~= Enum.UserInputType.Touch then
				return
			end

			local cam = workspace.CurrentCamera
			if not cam then
				return
			end

			local loc = UIS:GetMouseLocation()
			local ray = cam:ViewportPointToRay(loc.X, loc.Y)
			local hit = workspace:Raycast(ray.Origin, ray.Direction * 1000)
			local inst = hit and hit.Instance
			local model = inst and inst:FindFirstAncestorOfClass("Model")
			local hum = model and model:FindFirstChildOfClass("Humanoid")

			if hum and model ~= localPlayer.Character then
				if H.sound then
					playHitSound()
				end

				if H.particles then
					for _ = 1, 8 do
						hitParticle(hit.Position)
					end
				end
			end
		end)

		----------------------------------------------------------------
		-- Custom gun model (replaces how your gun looks, only you see it)
		----------------------------------------------------------------
		local PI = math.pi
		local MODELS = {
			["AWP"] = { 4531395275, CFrame.Angles(0, 0, 0), CFrame.new(0, 0, -0.5) },
			["Pistol"] = { 5102714039, CFrame.Angles(0, PI, 0), CFrame.new(0, 0, 0.5) },
			["Shotgun"] = { 5294131243, CFrame.Angles(0, PI, 0), CFrame.new(0, 0, 0.8) },
			["RayGun"] = { 542699703, CFrame.Angles(0, PI, 0), CFrame.new(0, 0, 0.2) },
			["AK-47"] = { 127200798279812, CFrame.Angles(PI / 2, 0, -PI / 2), CFrame.new(0, -0.3, 0.3) },
			["PinkGun"] = { 18610978709, CFrame.Angles(0, 0, 0), CFrame.new(0, 0, -0.3) },
			["FlameGun"] = { 10656806096, CFrame.Angles(-PI / 2, PI / 2, PI / 2), CFrame.new(2.1, 0, -0.3) },
			["MiniBlackGun"] = { 62932622, CFrame.Angles(PI / 2, 0, 0), CFrame.new(0, 0, 0) },
			["BlueGun"] = { 87594143804300, CFrame.Angles(-PI / 2, PI / 2, PI / 2), CFrame.new(0, -0.3, 0.5) },
			["BigUSP-S"] = { 12899296613, CFrame.Angles(0, 0, 0), CFrame.new(0, 0, -1.3) },
			["GreenGun"] = { 1297856838, CFrame.Angles(PI / 2, 0, 0), CFrame.new(0, -0.3, 0) },
		}
		local MODEL_NAMES = { "AWP", "Pistol", "Shotgun", "RayGun", "AK-47", "PinkGun", "FlameGun", "MiniBlackGun", "BlueGun", "BigUSP-S", "GreenGun" }

		local G = {
			on = false, name = "AWP", templates = {}, hidden = {}, nextCheck = 0, warned = false,
			auto = true, rev = 0, flip = {}, roll = {}, fwd = 0, up = 0,
		}

		local function refit()
			G.rev += 1
			G.nextCheck = 0
		end

		local function loadTemplate(name)
			if G.templates[name] then
				return G.templates[name]
			end

			local ok, objs = pcall(function()
				return game:GetObjects("rbxassetid://" .. MODELS[name][1])
			end)

			if not ok or type(objs) ~= "table" or not objs[1] then
				if not G.warned then
					G.warned = true
					notify("Gun Model", "Could not load that model.", "x")
				end
				return nil
			end

			G.warned = false
			G.templates[name] = objs[1]
			return objs[1]
		end

		local function restoreGun()
			for inst, t in pairs(G.hidden) do
				pcall(function()
					if inst.Parent then
						inst.Transparency = t
					end
				end)
			end
			G.hidden = {}

			local c = localPlayer.Character
			local gun = c and c:FindFirstChild("Gun")
			local custom = gun and gun:FindFirstChild("CustomGunModel")
			if custom then
				pcall(function()
					custom:Destroy()
				end)
			end
		end

		-- Auto-fit: measure the model, put its LONGEST side along the hand's forward
		-- direction, the middle side up, and centre it on the hand. This replaces the
		-- hand-guessed per-model angles, so every model lines up with the hand.
		local function fitGun(main, list, gripFrame, flip, roll)
			local inv = main.CFrame:Inverse()
			local minV = Vector3.new(math.huge, math.huge, math.huge)
			local maxV = Vector3.new(-math.huge, -math.huge, -math.huge)
			local vol, wsum = 0, Vector3.zero

			for _, p in ipairs(list) do
				local rel = inv * p.CFrame
				local h = p.Size / 2

				for sx = -1, 1, 2 do
					for sy = -1, 1, 2 do
						for sz = -1, 1, 2 do
							local c = rel:PointToWorldSpace(Vector3.new(h.X * sx, h.Y * sy, h.Z * sz))
							minV = minV:Min(c)
							maxV = maxV:Max(c)
						end
					end
				end

				local v = p.Size.X * p.Size.Y * p.Size.Z
				vol += v
				wsum += rel.Position * v
			end

			if vol <= 0 then
				return nil
			end

			local size = maxV - minV
			local center = (minV + maxV) / 2
			local off = wsum / vol - center

			local sizes = { size.X, size.Y, size.Z }
			local offs = { off.X, off.Y, off.Z }
			local axes = { Vector3.xAxis, Vector3.yAxis, Vector3.zAxis }
			local order = { 1, 2, 3 }
			table.sort(order, function(a, b)
				return sizes[a] > sizes[b]
			end)

			local li, mi = order[1], order[2]

			-- barrel = long axis, pointing away from the heavy (stock/receiver) end
			local bs = 1
			if math.abs(offs[li]) > sizes[li] * 0.03 then
				bs = offs[li] > 0 and -1 or 1
			end

			-- up = middle axis, towards the side the mass sits on (grip hangs below)
			local us = 1
			if math.abs(offs[mi]) > sizes[mi] * 0.03 then
				us = offs[mi] > 0 and 1 or -1
			end

			local b = axes[li] * bs
			local u = axes[mi] * us
			local r = b:Cross(u)

			if flip then
				b = -b
				r = -r
			end

			for _ = 1, (roll or 0) % 4 do
				local newU = r
				r = -u
				u = newU
			end

			local M = CFrame.fromMatrix(Vector3.zero, r, u, -b)
			local T = Vector3.new(0, sizes[mi] * 0.15 + G.up, -(sizes[li] * 0.15) - G.fwd)

			return gripFrame * CFrame.new(T) * M:Inverse() * CFrame.new(-center)
		end

		local function buildGun(char, gun)
			local hand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
			if not hand then
				return
			end

			local old = gun:FindFirstChild("CustomGunModel")
			if old then
				old:Destroy()
			end

			local tpl = loadTemplate(G.name)
			if not tpl then
				return
			end

			local def = MODELS[G.name]
			local m = tpl:Clone()
			m.Name = "CustomGunModel"
			m:SetAttribute("ModelName", G.name)
			m:SetAttribute("Rev", G.rev)

			local main = m:IsA("BasePart") and m or m.PrimaryPart or m:FindFirstChild("Handle") or m:FindFirstChildWhichIsA("BasePart", true)
			if not main then
				m:Destroy()
				return
			end

			for _, d in ipairs(m:GetDescendants()) do
				if d:IsA("BaseScript") then
					d:Destroy()
				elseif d:IsA("BasePart") then
					d.Anchored = false
					d.CanCollide = false
					d.CanQuery = false
					d.CanTouch = false
					d.Massless = true
				end
			end
			if m:IsA("BasePart") then
				m.Anchored, m.CanCollide, m.CanQuery, m.CanTouch, m.Massless = false, false, false, false, true
			end

			-- hide the real gun (only what is not part of the new model)
			for k in pairs(G.hidden) do
				if not k.Parent then
					G.hidden[k] = nil
				end
			end
			for _, d in ipairs(gun:GetDescendants()) do
				if (d:IsA("BasePart") or d:IsA("Decal") or d:IsA("Texture")) and not d:IsDescendantOf(m) and not G.hidden[d] then
					G.hidden[d] = d.Transparency
					d.Transparency = 1
				end
			end

			local grip = char:FindFirstChild("UpperTorso")
					and CFrame.new(0, -0.25, -0.1) * CFrame.Angles(-PI / 2, 0, 0)
				or CFrame.new(0, -1, -0.1) * CFrame.Angles(-PI / 2, 0, 0)
			local gripFrame = hand.CFrame * grip

			local list = {}
			if m:IsA("BasePart") then
				list[1] = m
			end
			for _, d in ipairs(m:GetDescendants()) do
				if d:IsA("BasePart") then
					list[#list + 1] = d
				end
			end

			local target = G.auto and fitGun(main, list, gripFrame, G.flip[G.name], G.roll[G.name]) or nil

			if target then
				local delta = target * main.CFrame:Inverse()
				for _, p in ipairs(list) do
					p.CFrame = delta * p.CFrame
				end
			else
				local cf = gripFrame * def[2] * def[3]

				if m:IsA("Model") then
					m:PivotTo(cf)
				else
					m.CFrame = cf
				end
			end

			-- every piece is welded, otherwise loose parts of the model drop to the ground
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = hand
			weld.Part1 = main
			weld.Parent = main

			for _, d in ipairs(m:GetDescendants()) do
				if d:IsA("BasePart") and d ~= main then
					local w = Instance.new("WeldConstraint")
					w.Part0 = main
					w.Part1 = d
					w.Parent = d
				end
			end

			m.Parent = gun
		end

		local function gunStep(now)
			if not G.on or now < G.nextCheck then
				return
			end
			G.nextCheck = now + 0.3

			local char = localPlayer.Character
			local gun = char and char:FindFirstChild("Gun")
			if not gun then
				return
			end

			local cur = gun:FindFirstChild("CustomGunModel")
			if cur and cur:GetAttribute("ModelName") == G.name and cur:GetAttribute("Rev") == G.rev then
				return
			end

			buildGun(char, gun)
		end

		list2.conns[#list2.conns + 1] = RS.Heartbeat:Connect(function()
			pcall(gunStep, os.clock())
		end)

		list2.conns[#list2.conns + 1] = {
			Disconnect = function()
				G.on, H.particles, H.sound = false, false, false
				restoreGun()
				if H.gui then
					pcall(function()
						H.gui:Destroy()
					end)
				end
			end,
		}

		----------------------------------------------------------------
		-- UI (Visuals tab)
		----------------------------------------------------------------
		tbl43.visuals:Section({ Title = "Hit Effects" })

		tbl43.visuals:Toggle({
			Title = "Hit Particles", Flag = "Toggle_Hit_Particles",
			Desc = "Particles fly out on your screen every time you click on another player",
			Type = "Toggle", Value = false,
			Callback = function(v)
				H.particles = v
			end,
		})

		tbl43.visuals:Colorpicker({
			Title = "Hit Particles Colour", Flag = "Colorpicker_Hit_Particles", Default = H.color,
			Callback = function(c) H.color = c end,
		})

		tbl43.visuals:Toggle({
			Title = "Hit Sound", Flag = "Toggle_Hit_Sound",
			Desc = "Plays a sound every time you click on another player",
			Type = "Toggle", Value = false,
			Callback = function(v)
				H.sound = v
			end,
		})

		tbl43.visuals:Dropdown({
			Title = "Hit Sound Mode", Flag = "Dropdown_Visuals_HitSoundMode", Multi = false, Value = "1",
			Desc = "Which of the 6 hit sounds to play",
			Values = { "1", "2", "3", "4", "5", "6" },
			Callback = function(v)
				H.mode = tonumber(pick(v)) or 1
			end,
		})

		tbl43.visuals:Button({
			Title = "Preview Hit Sound",
			Desc = "Plays the selected hit sound once",
			Callback = function() playHitSound() end,
		})

		tbl43.visuals:Section({ Title = "Gun Model" })

		tbl43.visuals:Toggle({
			Title = "Custom Gun Model", Flag = "Toggle_Custom_Gun_Model",
			Desc = "Swaps how your gun looks in your hand (only you see it). Applies whenever you hold the gun.",
			Type = "Toggle", Value = false,
			Callback = function(v)
				G.on = v
				if v then
					G.nextCheck = 0
				else
					restoreGun()
				end
			end,
		})

		tbl43.visuals:Dropdown({
			Title = "Gun Model", Flag = "Dropdown_Visuals_GunModel", Multi = false, Value = "AWP",
			Values = MODEL_NAMES,
			Callback = function(v)
				G.name = pick(v) or "AWP"
				refit()
			end,
		})

		tbl43.visuals:Toggle({
			Title = "Auto Align Gun", Flag = "Toggle_Gun_Auto_Align",
			Desc = "Measures each model and lines it up with your hand automatically. Turn off to use the old fixed angles.",
			Type = "Toggle", Value = true,
			Callback = function(v)
				G.auto = v
				refit()
			end,
		})

		tbl43.visuals:Button({
			Title = "Flip Gun Direction",
			Desc = "Model pointing backwards? Press to turn the selected model around (remembered per model until you re-execute)",
			Callback = function()
				G.flip[G.name] = not G.flip[G.name]
				refit()
			end,
		})

		tbl43.visuals:Button({
			Title = "Roll Gun 90\194\176",
			Desc = "Model sideways or upside down? Press to roll the selected model a quarter turn (press twice = upside down fix)",
			Callback = function()
				G.roll[G.name] = ((G.roll[G.name] or 0) + 1) % 4
				refit()
			end,
		})

		tbl43.visuals:Slider({
			Title = "Gun Forward / Back", Flag = "Slider_Gun_Forward", Step = 0.05,
			Value = { Min = -3, Max = 3, Default = 0 },
			Callback = function(v)
				G.fwd = tonumber(v) or 0
				refit()
			end,
		})

		tbl43.visuals:Slider({
			Title = "Gun Up / Down", Flag = "Slider_Gun_Up", Step = 0.05,
			Value = { Min = -3, Max = 3, Default = 0 },
			Callback = function(v)
				G.up = tonumber(v) or 0
				refit()
			end,
		})
	end

	installHitGun()
end

-- ===================== KILL CAM (cinematic camera: Knife Throw / Shoot Murderer) =====================
-- Two separate features:
--   Knife Cam  : when you throw a knife at another player, the camera chases the real thrown knife, then
--                orbits the victim for a moment and glides back to you.
--   Shoot Cam  : when your shot is lined up with the murderer, the camera chases the bullet to the murderer,
--                then orbits him and glides back to you.
do
	local function installKillCam()
		local RS = game:GetService("RunService")
		local TweenService = game:GetService("TweenService")
		local CollectionService = game:GetService("CollectionService")
		local RepStorage = game:GetService("ReplicatedStorage")
		local PlayersService = game:GetService("Players")

		local K = {
			knife = false, gun = false,
			hold = 1.5, bars = true, zoom = true,
			busy = false, stop = nil, gui = nil, top = nil, bottom = nil,
		}

		local RENDER_NAME = "FVLKillCam"
		local RETURN_TIME = 0.45

		K.debug = false

		local function dbg(text)
			if K.debug then
				pcall(function()
					obj2:Notify({ Title = "Kill Cam", Content = tostring(text), Duration = 2, Icon = "x" })
				end)
			end
		end

		local connectGun -- defined below; the UI toggle calls it
		local preview -- defined below; the preview buttons call it

		----------------------------------------------------------------
		-- UI (Visuals tab)
		----------------------------------------------------------------
		tbl43.visuals:Section({ Title = "Kill Cam" })

		tbl43.visuals:Toggle({
			Title = "Knife Cam", Flag = "Toggle_KillCam_Knife",
			Desc = "When you throw a knife at another player the camera chases the knife, orbits the victim, then glides back",
			Type = "Toggle", Value = false,
			Callback = function(v)
				K.knife = v

				if not v and K.stop then
					pcall(K.stop)
				end
			end,
		})

		tbl43.visuals:Toggle({
			Title = "Shoot Cam (Murderer)", Flag = "Toggle_KillCam_Gun",
			Desc = "When you shoot at the murderer the camera chases the bullet, orbits him, then glides back",
			Type = "Toggle", Value = false,
			Callback = function(v)
				K.gun = v

				if v then
					if connectGun then
						task.spawn(connectGun)
					end
				elseif K.stop then
					pcall(K.stop)
				end
			end,
		})

		tbl43.visuals:Slider({
			Title = "Kill Cam Hold Time (s)", Flag = "Slider_KillCam_Hold", Step = 0.1,
			Value = { Min = 0.5, Max = 4, Default = 1.5 },
			Callback = function(v)
				K.hold = tonumber(v) or 1.5
			end,
		})

		tbl43.visuals:Toggle({
			Title = "Kill Cam Zoom", Flag = "Toggle_KillCam_Zoom",
			Desc = "FOV punch: widens while chasing, zooms in on the victim",
			Type = "Toggle", Value = true,
			Callback = function(v)
				K.zoom = v
			end,
		})

		tbl43.visuals:Button({
			Title = "Preview Knife Cam",
			Desc = "Plays the knife camera on the nearest player (no throw needed)",
			Callback = function()
				if preview then
					pcall(preview, "knife")
				end
			end,
		})

		tbl43.visuals:Button({
			Title = "Preview Shoot Cam",
			Desc = "Plays the shoot camera on the murderer (or the nearest player)",
			Callback = function()
				if preview then
					pcall(preview, "gun")
				end
			end,
		})

		tbl43.visuals:Toggle({
			Title = "Kill Cam Debug", Flag = "Toggle_KillCam_Debug",
			Desc = "Shows a small notice explaining why the camera did or did not start",
			Type = "Toggle", Value = false,
			Callback = function(v)
				K.debug = v
			end,
		})

		tbl43.visuals:Toggle({
			Title = "Cinematic Bars", Flag = "Toggle_KillCam_Bars",
			Desc = "Black movie bars at the top and bottom while the Kill Cam plays",
			Type = "Toggle", Value = true,
			Callback = function(v)
				K.bars = v
			end,
		})

		local function toPos(v)
			if typeof(v) == "Vector3" then
				return v
			elseif typeof(v) == "CFrame" then
				return v.Position
			elseif typeof(v) == "Instance" then
				if v:IsA("Attachment") then
					return v.WorldPosition
				elseif v:IsA("BasePart") then
					return v.Position
				end
			end
		end

		local function objPos(o)
			if o:IsA("BasePart") then
				return o.Position
			elseif o:IsA("Model") then
				return o:GetPivot().Position
			end
		end

		local function hrpOf(p)
			local c = p and p.Character
			return c and c:FindFirstChild("HumanoidRootPart")
		end

		local function isAlive(p)
			local c = p and p.Character
			local h = c and c:FindFirstChildOfClass("Humanoid")
			return h ~= nil and h.Health > 0
		end

		----------------------------------------------------------------
		-- Cinematic bars (black letterbox bars at the top and bottom)
		----------------------------------------------------------------
		local function getBars()
			if K.gui and K.gui.Parent then
				return K.top, K.bottom
			end

			local g = Instance.new("ScreenGui")
			g.Name = "FVLKillCamBars"
			g.ResetOnSpawn = false
			g.IgnoreGuiInset = true
			g.DisplayOrder = 40

			pcall(function()
				g.Parent = gethui and gethui() or localPlayer:WaitForChild("PlayerGui")
			end)

			if not g.Parent then
				g.Parent = localPlayer:WaitForChild("PlayerGui")
			end

			local top = Instance.new("Frame")
			top.BackgroundColor3 = Color3.new(0, 0, 0)
			top.BorderSizePixel = 0
			top.Size = UDim2.new(1, 0, 0, 0)
			top.Position = UDim2.new(0, 0, 0, 0)
			top.Parent = g

			local bottom = Instance.new("Frame")
			bottom.BackgroundColor3 = Color3.new(0, 0, 0)
			bottom.BorderSizePixel = 0
			bottom.AnchorPoint = Vector2.new(0, 1)
			bottom.Size = UDim2.new(1, 0, 0, 0)
			bottom.Position = UDim2.new(0, 0, 1, 0)
			bottom.Parent = g

			K.gui, K.top, K.bottom = g, top, bottom
			return top, bottom
		end

		local function showBars(on)
			if (on and not K.bars) or (not on and not K.gui) then
				return
			end

			local ok, top, bottom = pcall(getBars)
			if not ok or not top then
				return
			end

			local info = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local h = on and 0.11 or 0
			TweenService:Create(top, info, { Size = UDim2.new(1, 0, h, 0) }):Play()
			TweenService:Create(bottom, info, { Size = UDim2.new(1, 0, h, 0) }):Play()
		end

		----------------------------------------------------------------
		-- The camera director. A "track" tells it what to chase:
		--   track.start          Vector3 where the chase starts
		--   track.victim         Player (or nil) the camera orbits after the chase
		--   track.maxTime        longest the chase may last
		--   track.step(dt)       -> position, direction, finished
		--   track.endPos()       -> Vector3 fallback focus if there is no victim
		----------------------------------------------------------------
		local function play(track)
			if K.busy then
				return
			end

			local cam = workspace.CurrentCamera
			local myChar = localPlayer.Character
			local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
			local myHead = myChar and (myChar:FindFirstChild("Head") or myChar:FindFirstChild("HumanoidRootPart"))

			if not (cam and myHum and myHead and myHum.Health > 0) then
				return
			end

			-- another feature already controls the camera (free cam etc.): don't fight it
			if cam.CameraType == Enum.CameraType.Scriptable then
				return
			end

			K.busy = true

			local saved = { type = cam.CameraType, subject = cam.CameraSubject, fov = cam.FieldOfView }
			local startCF = cam.CFrame
			local homeOff = startCF.Position - myHead.Position
			local homeRot = startCF - startCF.Position

			cam.CameraType = Enum.CameraType.Scriptable
			showBars(true)

			local cur = startCF
			local phase, phaseT = "chase", 0
			local lastPos = track.start
			local lastDir = (cam.CFrame.LookVector)
			local orbitBase, orbitRadius, orbitSpin = 0, 9, 0
			local impactPos = track.start
			local returnFrom = startCF
			local ended = false

			local function stop()
				if ended then
					return
				end
				ended = true

				pcall(function()
					RS:UnbindFromRenderStep(RENDER_NAME)
				end)

				showBars(false)

				pcall(function()
					cam.FieldOfView = saved.fov
					cam.CameraType = saved.type

					if saved.subject then
						cam.CameraSubject = saved.subject
					end
				end)

				K.busy = false
				K.stop = nil
			end

			K.stop = stop

			local function lerpTo(a, b, rate, dt)
				return a:Lerp(b, 1 - math.exp(-rate * dt))
			end

			local function setFov(target, rate, dt)
				cam.FieldOfView = cam.FieldOfView + (target - cam.FieldOfView) * (1 - math.exp(-rate * dt))
			end

			local function frame(dt)
				-- you died / respawned / left: drop the cinematic at once
				if localPlayer.Character ~= myChar or not myHum.Parent or myHum.Health <= 0 then
					stop()
					return
				end

				phaseT = phaseT + dt

				if phase == "chase" then
					local pos, dir, finished = track.step(dt)

					if pos then
						lastPos = pos
					end

					if dir and dir.Magnitude > 0.01 then
						lastDir = lastDir:Lerp(dir.Unit, math.min(1, dt * 10))

						if lastDir.Magnitude < 0.01 then
							lastDir = dir.Unit
						end

						lastDir = lastDir.Unit
					end

					-- over-the-shoulder view just behind the projectile
					local side = lastDir:Cross(Vector3.new(0, 1, 0))

					if side.Magnitude < 0.1 then
						side = Vector3.new(1, 0, 0)
					end

					local back = math.clamp(track.chaseBack or 9, 3, 12)
					local camPos = lastPos - lastDir * back + Vector3.new(0, 2.4, 0) + side.Unit * 2.2
					local goal = CFrame.lookAt(camPos, lastPos + lastDir * 10)

					cur = lerpTo(cur, goal, 14, dt)
					cam.CFrame = cur
					cam.Focus = CFrame.new(lastPos)

					if K.zoom then
						setFov(saved.fov + 9, 8, dt)
					end

					if finished or phaseT >= (track.maxTime or 3.5) then
						phase, phaseT = "impact", 0
						impactPos = lastPos

						local focus = hrpOf(track.victim)
						focus = focus and focus.Position or impactPos
						local rel = cur.Position - focus
						orbitBase = math.atan2(rel.X, rel.Z)
						orbitRadius = math.clamp(Vector3.new(rel.X, 0, rel.Z).Magnitude, 6, 11)
						orbitSpin = 0
					end
				elseif phase == "impact" then
					local vHrp = hrpOf(track.victim)
					local focus = vHrp and vHrp.Position or impactPos

					orbitSpin = orbitSpin + dt * 0.9

					local ang = orbitBase + orbitSpin
					local camPos = focus + Vector3.new(math.sin(ang) * orbitRadius, 2.6, math.cos(ang) * orbitRadius)
					local goal = CFrame.lookAt(camPos, focus + Vector3.new(0, 1, 0))

					cur = lerpTo(cur, goal, 9, dt)
					cam.CFrame = cur
					cam.Focus = CFrame.new(focus)

					if K.zoom then
						setFov(math.max(30, saved.fov - 16), 6, dt)
					else
						setFov(saved.fov, 6, dt)
					end

					if phaseT >= K.hold then
						phase, phaseT = "return", 0
						returnFrom = cur
					end
				else
					-- glide back to where your own camera was (relative to your head)
					local alpha = math.clamp(phaseT / RETURN_TIME, 0, 1)
					alpha = alpha * alpha * (3 - 2 * alpha)

					local home = CFrame.new(myHead.Position + homeOff) * homeRot
					cam.CFrame = returnFrom:Lerp(home, alpha)
					setFov(saved.fov, 10, dt)

					if phaseT >= RETURN_TIME then
						stop()
					end
				end
			end

			RS:BindToRenderStep(RENDER_NAME, Enum.RenderPriority.Camera.Value + 1, function(dt)
				local ok = pcall(frame, dt)

				if not ok then
					stop()
				end
			end)
		end

		----------------------------------------------------------------
		-- Function 1: KNIFE CAM  (you throw a knife at another player)
		----------------------------------------------------------------
		local function knifeTrack(part, victim)
			local start = objPos(part) or Vector3.zero
			local prev = start
			local lastPos = start
			local still = 0

			return {
				start = start,
				victim = victim,
				maxTime = 4,
				chaseBack = 8,
				step = function(dt)
					if not part.Parent then
						return lastPos, nil, true
					end

					local pos = objPos(part)

					if not pos then
						return lastPos, nil, true
					end

					local vel = dt > 0 and (pos - prev) / dt or Vector3.zero
					prev, lastPos = pos, pos

					-- the knife stopped moving (stuck in a wall / the victim): the chase is over
					if vel.Magnitude < 4 then
						still = still + dt
					else
						still = 0
					end

					return pos, vel, still > 0.15
				end,
			}
		end

		-- is the knife really flying, and who is it flying at? (a living player close to the knife's straight path)
		-- returns moving (bool), victim (Player or nil)
		local function predictKnifeVictim(part)
			local p0 = objPos(part)

			if not p0 then
				return false, nil
			end

			local t0 = os.clock()
			local p1, vel

			for _ = 1, 12 do
				RS.Heartbeat:Wait()

				if not part.Parent then
					return false, nil
				end

				p1 = objPos(part)

				local dt = os.clock() - t0

				if p1 and dt > 0.04 then
					vel = (p1 - p0) / dt

					if vel.Magnitude > 20 then
						break
					end
				end
			end

			if not (p1 and vel and vel.Magnitude > 20) then
				return false, nil
			end

			local best, bestT
			local speedSq = vel:Dot(vel)

			for _, p in ipairs(PlayersService:GetPlayers()) do
				if p ~= localPlayer and isAlive(p) then
					local hrp = hrpOf(p)

					if hrp then
						local t = (hrp.Position - p1):Dot(vel) / speedSq

						if t > 0 and t < 8 then
							local off = (hrp.Position - (p1 + vel * t)).Magnitude

							if off < 14 and (not bestT or t < bestT) then
								best, bestT = p, t
							end
						end
					end
				end
			end

			return true, best
		end

		local function onKnifeThrown(part)
			if not K.knife or K.busy then
				return
			end

			local link = part:WaitForChild("HandleLink", 3)
			local handle = link and link.Value
			local owner = handle and handle.Parent
			local myChar = localPlayer.Character

			-- only OUR knives
			if not (owner and ((myChar and owner:IsDescendantOf(myChar)) or owner:IsDescendantOf(localPlayer))) then
				dbg("Knife: not your knife")
				return
			end

			local moving, victim = predictKnifeVictim(part)

			if not moving or not K.knife or K.busy or not part.Parent then
				dbg("Knife: not flying / camera busy")
				return
			end

			dbg(victim and ("Knife -> " .. victim.Name) or "Knife -> no player on its path")

			local track = knifeTrack(part, victim)
			local baseStep = track.step

			-- after the chase, orbit whoever the knife ended up next to (if it is not the predicted player)
			track.step = function(dt)
				local pos, dir, finished = baseStep(dt)

				if finished and pos and track.victim then
					local hrp = hrpOf(track.victim)

					if not hrp or (hrp.Position - pos).Magnitude > 25 then
						local near, nearD = nil, 15

						for _, p in ipairs(PlayersService:GetPlayers()) do
							local h = p ~= localPlayer and isAlive(p) and hrpOf(p)

							if h and (h.Position - pos).Magnitude < nearD then
								near, nearD = p, (h.Position - pos).Magnitude
							end
						end

						track.victim = near
					end
				end

				return pos, dir, finished
			end

			play(track)
		end

		list2.conns[#list2.conns + 1] = CollectionService:GetInstanceAddedSignal("ThrowingKnife"):Connect(function(part)
			task.spawn(function()
				pcall(onKnifeThrown, part)
			end)
		end)

		----------------------------------------------------------------
		-- Function 2: SHOOT CAM  (your shot is lined up with the murderer)
		----------------------------------------------------------------
		local function gunTrack(pa, victim, speed)
			local dist = 60
			local vHrp = hrpOf(victim)

			if vHrp then
				dist = (vHrp.Position - pa).Magnitude
			end

			-- slow enough to be seen, fast enough to feel like a bullet
			local flight = math.clamp(dist / (speed or 140), 0.3, 2.5)
			local t = 0
			local lastEnd = vHrp and vHrp.Position or pa

			return {
				start = pa,
				victim = victim,
				maxTime = flight + 0.5,
				chaseBack = math.clamp(dist * 0.5, 4, 10),
				step = function(dt)
					t = t + dt

					local h = hrpOf(victim)

					if h then
						lastEnd = h.Position
					end

					local alpha = math.clamp(t / flight, 0, 1)
					local pos = pa:Lerp(lastEnd, alpha)
					local dir = lastEnd - pa

					return pos, dir, alpha >= 1
				end,
			}
		end

		-- shared test: is a shot from pa towards pb lined up with the murderer?
		local function shotOnMurderer(pa, pb)
			if not K.gun or K.busy then
				return
			end

			local murderer = list2.getMurderer and list2.getMurderer()

			if not murderer or murderer == localPlayer or not isAlive(murderer) then
				dbg("Shoot: no murderer to follow")
				return
			end

			local hrp = hrpOf(murderer)

			if not (hrp and pa and pb) then
				return
			end

			local aim = pb - pa

			if aim.Magnitude < 1 then
				return
			end

			-- the shot counts as "on the murderer" when his body is within a few studs of the shot line
			local u = aim.Unit
			local t = (hrp.Position - pa):Dot(u)

			if t < -2 then
				dbg("Shoot: murderer is behind the shot")
				return
			end

			local closest = pa + u * math.clamp(t, 0, 1000)

			if (hrp.Position - closest).Magnitude > 4.5 then
				dbg("Shoot: shot was not on the murderer")
				return
			end

			dbg("Shoot -> " .. murderer.Name)
			play(gunTrack(pa, murderer))
		end

		-- manual shots: the game echoes our own shot back through GunFired
		local function onGunFired(gun, a, b)
			if not K.gun or K.busy then
				return
			end

			local myChar = localPlayer.Character

			if not (typeof(gun) == "Instance" and myChar and gun:IsDescendantOf(myChar)) then
				return
			end

			shotOnMurderer(toPos(a), toPos(b))
		end

		-- shots fired by this script (Shoot Murderer, Auto Shoot, Silent Aim, TP Shoot...) all go through
		-- list2.fireGun, so hook it too: the camera also works for those, even if the echo never arrives
		local origFireGun = list2.fireGun

		if type(origFireGun) == "function" then
			list2.fireGun = function(shoot, character, aimPos, startCF, ownOrigin)
				local result = origFireGun(shoot, character, aimPos, startCF, ownOrigin)

				if result == true and K.gun and not K.busy then
					pcall(function()
						local aimAt = aimPos

						if not list2.fireNoOverride and list2.murdererAimPoint then
							aimAt = list2.murdererAimPoint() or aimPos
						end

						local myHead = hrpOf(localPlayer)
						local from = (startCF and toPos(startCF)) or (myHead and myHead.Position)

						if typeof(aimAt) == "Vector3" and from then
							shotOnMurderer(from, aimAt)
						end
					end)
				end

				return result
			end
		end

		local gunConn, gunRemote

		connectGun = function()
			local ok, remote = pcall(function()
				return RepStorage:WaitForChild("ClientServices", 2):WaitForChild("WeaponService", 2):WaitForChild("GunFired", 2)
			end)

			if not ok or not remote then
				return
			end

			if gunConn and gunRemote == remote and gunConn.Connected then
				return
			end

			if gunConn then
				pcall(function()
					gunConn:Disconnect()
				end)
			end

			gunRemote = remote
			gunConn = remote.OnClientEvent:Connect(function(gun, a, b)
				pcall(onGunFired, gun, a, b)
			end)
		end

		-- the remote can be replaced between rounds, so re-check now and then
		local nextCheck = 0

		list2.conns[#list2.conns + 1] = RS.Heartbeat:Connect(function()
			local now = os.clock()

			if K.gun and now >= nextCheck then
				nextCheck = now + 1
				pcall(connectGun)
			end
		end)

		list2.conns[#list2.conns + 1] = {
			Disconnect = function()
				K.knife, K.gun = false, false

				if type(origFireGun) == "function" then
					list2.fireGun = origFireGun
				end

				if K.stop then
					pcall(K.stop)
				end

				if gunConn then
					pcall(function()
						gunConn:Disconnect()
					end)
				end

				if K.gui then
					pcall(function()
						K.gui:Destroy()
					end)
				end
			end,
		}

		----------------------------------------------------------------
		-- Preview: plays the camera on a fake projectile, so you can test it without throwing / shooting
		----------------------------------------------------------------
		preview = function(kind)
			if K.busy then
				return
			end

			local myHrp = hrpOf(localPlayer)

			if not myHrp then
				return
			end

			local victim = kind == "gun" and list2.getMurderer and list2.getMurderer() or nil

			if not victim or victim == localPlayer or not isAlive(victim) then
				victim = nil

				local bestD

				for _, p in ipairs(PlayersService:GetPlayers()) do
					local h = p ~= localPlayer and isAlive(p) and hrpOf(p)

					if h then
						local d = (h.Position - myHrp.Position).Magnitude

						if not bestD or d < bestD then
							victim, bestD = p, d
						end
					end
				end
			end

			if not victim then
				pcall(function()
					obj2:Notify({ Title = "Kill Cam", Content = "No other player to preview on", Duration = 2, Icon = "x" })
				end)
				return
			end

			local from = myHrp.Position + Vector3.new(0, 1.5, 0)
			play(gunTrack(from, victim, kind == "gun" and 140 or 70))
		end

	end

	local okKC, errKC = pcall(installKillCam)

	if not okKC then
		warn("Kill Cam failed to load: " .. tostring(errKC))
	end
end

-- ===================== JERK OFF (ported from MM2_readable) =====================
do
	local Players = game:GetService("Players")
	local localPlayer = Players.LocalPlayer

	local JO = { on = false, tool = nil, track = nil, thread = nil, equipped = false, charConn = nil, diedConn = nil }

	-- Same animations / timings the original script uses
	local ID_R6 = "rbxassetid://72042024"
	local ID_R15 = "rbxassetid://698251653"

	local function stopJerk()
		JO.equipped = false

		if JO.thread then
			pcall(task.cancel, JO.thread)
			JO.thread = nil
		end

		if JO.track then
			pcall(function()
				JO.track:Stop()
			end)
			JO.track = nil
		end
	end

	local function startJerk(tool)
		stopJerk()

		local char = localPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not hum then
			return
		end

		local isR15 = char:FindFirstChild("UpperTorso") ~= nil
		local speed = isR15 and 0.7 or 0.65
		local stopAt = isR15 and 0.7 or 0.65

		JO.equipped = true

		JO.thread = task.spawn(function()
			while JO.equipped and tool.Parent do
				task.wait()

				if not JO.track then
					local anim = Instance.new("Animation")
					anim.AnimationId = isR15 and ID_R15 or ID_R6

					local ok, track = pcall(function()
						return hum:LoadAnimation(anim)
					end)

					if not ok or not track then
						return
					end

					JO.track = track
				end

				-- play only a short slice of the animation, stop, repeat = the stroking motion
				local track = JO.track
				track:Play()
				track:AdjustSpeed(speed)
				track.TimePosition = 0.6
				task.wait(0.1)

				while JO.equipped and JO.track and JO.track.TimePosition < stopAt do
					task.wait(0.1)
				end

				if JO.track then
					pcall(function()
						JO.track:Stop()
					end)
					JO.track = nil
				end
			end
		end)
	end

	local function destroyOldTools()
		local backpack = localPlayer:FindFirstChildOfClass("Backpack")
		local char = localPlayer.Character

		for _, holder in ipairs({ backpack, char }) do
			if holder then
				for _, child in ipairs(holder:GetChildren()) do
					if child:IsA("Tool") and child.Name == "Jerk Off" then
						pcall(function()
							child:Destroy()
						end)
					end
				end
			end
		end
	end

	local function removeTool()
		stopJerk()

		if JO.diedConn then
			pcall(function()
				JO.diedConn:Disconnect()
			end)
			JO.diedConn = nil
		end

		destroyOldTools()
		JO.tool = nil
	end

	local function ensureTool()
		removeTool()

		local char = localPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local backpack = localPlayer:FindFirstChildOfClass("Backpack")
		if not hum or not backpack then
			return false
		end

		local tool = Instance.new("Tool")
		tool.Name = "Jerk Off"
		tool.ToolTip = "jorking it."
		tool.RequiresHandle = false
		tool.CanBeDropped = false

		tool.Equipped:Connect(function()
			startJerk(tool)
		end)
		tool.Unequipped:Connect(stopJerk)
		JO.diedConn = hum.Died:Connect(stopJerk)

		tool.Parent = backpack
		JO.tool = tool
		return true
	end

	local function setJerk(v)
		JO.on = v and true or false

		if JO.on then
			local ok = ensureTool()
			obj2:Notify({
				Title = "Jerk",
				Content = ok and "Tool added to backpack!" or "No character yet - respawn and toggle again.",
				Duration = 2,
				Icon = ok and "check" or "x",
			})
		else
			removeTool()
			obj2:Notify({ Title = "Jerk", Content = "Removed.", Duration = 2, Icon = "check" })
		end
	end

	-- respawn gives a fresh Backpack, so hand the tool back if the toggle is still on
	JO.charConn = localPlayer.CharacterAdded:Connect(function()
		stopJerk()
		JO.tool = nil

		if JO.on then
			task.wait(1)
			if JO.on then
				ensureTool()
			end
		end
	end)

	list2.conns[#list2.conns + 1] = {
		Disconnect = function()
			JO.on = false
			if JO.charConn then
				pcall(function()
					JO.charConn:Disconnect()
				end)
				JO.charConn = nil
			end
			removeTool()
		end,
	}

	tbl43.troll:Section({ Title = "Jerk Off" })

	tbl43.troll:Toggle({
		Title = "Jerk Off",
		Flag = "Toggle_Troll_Jerk_Off",
		Desc = "Adds a Jerk Off tool to your backpack. Equip it to play the animation, unequip to stop.",
		Type = "Toggle",
		Value = false,
		Callback = function(v)
			setJerk(v)
		end,
	})
end

-- ===================== BOUNCY MODE (Troll & Fun) =====================
-- Free bounce: you fly through the air like a super ball. There is no fixed direction and no hopping from the
-- ground: you bounce off floors, walls and ceilings in every direction (real reflection off the surface), and
-- every bounce keeps your full speed, so you never slow down. The speed slider sets how fast you fly.
do
	local RS = game:GetService("RunService")
	local GRAVITY = 55 -- lighter than the real gravity so the arcs stay long and floaty
	local RADIUS = 3.2 -- how far from a surface we turn around
	local BN = {
		on = false, speed = 50, conn = nil, vel = nil, safeCF = nil,
		rayParams = nil, rayChar = nil, lastBounce = 0, stand = {},
	}

	local function randomUnit()
		local v = Vector3.new(math.random() * 2 - 1, math.random() * 1.2 - 0.2, math.random() * 2 - 1)

		if v.Magnitude < 0.1 then
			return Vector3.new(0, 1, 0)
		end

		return v.Unit
	end

	-- the same direction, nudged a little in a random way so no two bounces look alike
	local function jitter(dir, amount)
		local v = dir + Vector3.new(math.random() * 2 - 1, math.random() * 2 - 1, math.random() * 2 - 1) * amount

		if v.Magnitude < 0.1 then
			return dir
		end

		return v.Unit
	end

	local function step(dt)
		dt = math.min(dt, 0.1)

		local char = localPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")

		if not hrp or not hum or hum.Health <= 0 then
			return
		end

		-- new character (respawn): fresh ray filter, fresh start
		if BN.rayChar ~= char then
			BN.rayChar = char
			BN.rayParams = RaycastParams.new()
			BN.rayParams.FilterType = Enum.RaycastFilterType.Exclude
			BN.rayParams.FilterDescendantsInstances = { char }
			BN.rayParams.RespectCanCollide = true
			BN.safeCF = nil
			BN.vel = randomUnit() * BN.speed
		end

		-- limp body: the humanoid stops fighting the movement, and you tumble while you fly
		if not hum.PlatformStand then
			hum.PlatformStand = true
			BN.stand[hum] = true
		end

		BN.vel = BN.vel or randomUnit() * BN.speed
		local pos = hrp.Position

		-- bounced into the void: back to the last safe spot, launched upwards
		if BN.safeCF and pos.Y < workspace.FallenPartsDestroyHeight + 60 then
			hrp.CFrame = BN.safeCF + Vector3.new(0, 6, 0)
			BN.vel = (Vector3.new(0, 1.5, 0) + randomUnit()).Unit * BN.speed
			hrp.AssemblyLinearVelocity = BN.vel
			return
		end

		-- gravity, then the speed slider is the speed we fly at (also while falling)
		local vel = BN.vel + Vector3.new(0, -GRAVITY * dt, 0)
		vel = vel.Unit * BN.speed

		-- look ahead along the flight path: anything in the way is a bounce
		local reach = BN.speed * dt + RADIUS
		local hit = workspace:Raycast(pos, vel.Unit * reach, BN.rayParams)

		if hit and os.clock() - BN.lastBounce > 0.03 then
			BN.lastBounce = os.clock()
			local n = hit.Normal

			-- reflect off the surface
			local r = vel - 2 * vel:Dot(n) * n
			r = jitter(r.Unit, 0.18)

			-- a floor never lets you skim along it: always throw you properly back up
			if n.Y > 0.6 then
				BN.safeCF = CFrame.new(hit.Position + n * RADIUS)
				r = Vector3.new(r.X, math.max(r.Y, 0.55), r.Z).Unit
			end

			-- step off the surface so you cannot get stuck inside it
			local away = hit.Position + n * RADIUS
			hrp.CFrame = CFrame.new(away) * (hrp.CFrame - hrp.CFrame.Position)

			vel = r * BN.speed
			hrp.AssemblyAngularVelocity = (randomUnit() * 12)
		end

		BN.vel = vel
		hrp.AssemblyLinearVelocity = vel
	end

	local function setBounce(v)
		v = v and true or false

		if v == BN.on then
			return
		end

		BN.on = v

		if BN.conn then
			BN.conn:Disconnect()
			BN.conn = nil
		end

		if v then
			BN.vel = nil
			BN.lastBounce = 0
			BN.conn = RS.Heartbeat:Connect(function(dt)
				pcall(step, dt)
			end)
		else
			-- give the body back: standing again, upright, no more speed
			for hum in pairs(BN.stand) do
				pcall(function()
					hum.PlatformStand = false
				end)
			end

			BN.stand = {}

			local char = localPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")

			if hrp then
				pcall(function()
					local look = hrp.CFrame.LookVector
					local flat = Vector3.new(look.X, 0, look.Z)

					if flat.Magnitude < 0.01 then
						flat = Vector3.new(0, 0, -1)
					end

					hrp.AssemblyAngularVelocity = Vector3.zero
					hrp.AssemblyLinearVelocity = Vector3.zero
					hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + flat.Unit)
				end)
			end

			BN.vel = nil
		end
	end

	list2.conns[#list2.conns + 1] = {
		Disconnect = function()
			setBounce(false)
		end,
	}

	tbl43.troll:Section({ Title = "Bouncy Mode" })

	tbl43.troll:Slider({
		Title = "Bounce Speed",
		Flag = "Slider_Troll_Bounce_Speed",
		Desc = "How fast you fly. You keep this speed through every bounce.",
		Step = 5,
		Value = { Min = 10, Max = 150, Default = 50 },
		Callback = function(v)
			local n = tonumber(v) or type(v) == "table" and tonumber(v.Value)

			if n then
				BN.speed = n
			end
		end,
	})

	tbl43.troll:Toggle({
		Title = "Bouncy Mode",
		Flag = "Toggle_Troll_Bounce",
		Desc = "Free bounce: you fly and tumble around the whole map like a super ball, bouncing off floors, walls and ceilings in every direction. Works best on its own: Follow Player and Stand In Front Of Sheriff fight it for your position.",
		Type = "Toggle",
		Value = false,
		Callback = function(v)
			setBounce(v)
		end,
	})
end

-- ===================== EXTRA FEATURES (ported from MM2_readable) =====================
-- Aimlock, Auto Knife Throw, Avoid Murder, AntiCoin, Shutup GunReload,
-- OffDamageWater, FadeDisabler. (Vote Duper already exists here as "Pick Map".)
do
	local Players = game:GetService("Players")
	local RS = game:GetService("RunService")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local lp = Players.LocalPlayer

	local function note(title, content, icon)
		obj2:Notify({ Title = title, Content = content, Duration = 2, Icon = icon or "check" })
	end

	local function onUnload(fn)
		list2.conns[#list2.conns + 1] = { Disconnect = fn }
	end

	local function killConns(t)
		for _, c in ipairs(t) do
			pcall(function()
				c:Disconnect()
			end)
		end
		table.clear(t)
	end

	-- ---------------------------------------------------------------- Aimlock
	local AL = { name = nil, conn = nil, dropdown = nil }

	local function alNames()
		local names = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= lp then
				table.insert(names, p.Name)
			end
		end
		return names
	end

	local function alStop()
		if AL.conn then
			pcall(function()
				AL.conn:Disconnect()
			end)
			AL.conn = nil
		end
	end

	local function alStart()
		alStop()
		AL.conn = RS.RenderStepped:Connect(function()
			local target = AL.name and Players:FindFirstChild(AL.name)
			local c = target and target.Character
			local hrp = c and c:FindFirstChild("HumanoidRootPart")
			local cam = workspace.CurrentCamera
			if hrp and cam then
				cam.CFrame = CFrame.new(cam.CFrame.Position, hrp.Position)
			end
		end)
	end

	-- ---------------------------------------------------------------- Auto Knife Throw
	-- Every 1.4s: if you are the murderer, throw at the nearest player (same throw as the Throw Knife button,
	-- but silent when nobody is in range / behind a wall so it does not spam notifications).
	local AK = { on = false, thread = nil }

	local function akStop()
		AK.on = false
		if AK.thread then
			pcall(task.cancel, AK.thread)
			AK.thread = nil
		end
	end

	local function akStart()
		akStop()
		AK.on = true

		AK.thread = task.spawn(function()
			while AK.on do
				task.wait(1.4)
				if not AK.on then
					break
				end

				pcall(function()
					if func15() ~= lp then
						return
					end

					local target = func66()
					if not target or not target.Character then
						return
					end

					local c = lp.Character
					local hand = c and (c:FindFirstChild("RightHand") or c:FindFirstChild("HumanoidRootPart"))
					if hand and flag78 and not func65(target.Character, hand) then
						return
					end

					func68()
				end)
			end
		end)
	end

	-- ---------------------------------------------------------------- Avoid Murder (used by Coin Autofarm)
	list2.avoidMurderOn = false

	list2.murdererNearby = function()
		local c = lp.Character
		local hrp = c and c:FindFirstChild("HumanoidRootPart")
		if not hrp then
			return false
		end

		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= lp and p.Character then
				local oh = p.Character:FindFirstChild("HumanoidRootPart")
				if oh and (oh.Position - hrp.Position).Magnitude <= 10 then
					if list2.isMurderer(p) and not list2.isPlayerDead(p) then
						return true
					end
				end
			end
		end

		return false
	end

	-- ---------------------------------------------------------------- AntiCoin
	-- Every 0.5s: coins become invisible, untouchable and non-solid. Turning it off puts them back.
	local AC = { on = false, thread = nil, saved = {} }

	local function hideCoinPart(part)
		if AC.saved[part] == nil then
			AC.saved[part] = { Touch = part.CanTouch, Collide = part.CanCollide, Trans = part.Transparency }
		end
		part.CanTouch = false
		part.CanCollide = false
		part.Transparency = 1
	end

	local function hideCoinsIn(root)
		for _, d in ipairs(root:GetDescendants()) do
			if d:IsA("BasePart") then
				hideCoinPart(d)
			end
		end
	end

	local function acTick()
		local mansion = workspace:FindFirstChild("Mansion2")
		local container = mansion and mansion:FindFirstChild("CoinContainer")

		if container then
			hideCoinsIn(container)
			return
		end

		for _, m in ipairs(workspace:GetDescendants()) do
			if m:IsA("Model") and string.find(m.Name:lower(), "coin") then
				hideCoinsIn(m)
			end
		end
	end

	local function acStop()
		AC.on = false
		if AC.thread then
			pcall(task.cancel, AC.thread)
			AC.thread = nil
		end

		for part, s in pairs(AC.saved) do
			if part and part.Parent then
				pcall(function()
					part.CanTouch = s.Touch
					part.CanCollide = s.Collide
					part.Transparency = s.Trans
				end)
			end
		end
		table.clear(AC.saved)
	end

	local function acStart()
		acStop()
		AC.on = true

		AC.thread = task.spawn(function()
			while AC.on do
				pcall(acTick)
				task.wait(0.5)
			end
		end)
	end

	-- ---------------------------------------------------------------- OffDamageWater
	-- Anything under a water / river / ocean object (or with a Splash / HitWater child) stops being touchable
	-- and its Touched handlers are switched off, so water can no longer hurt you.
	local WP = { on = false, saved = {}, cons = {}, conns = {} }

	local function isWater(inst)
		local n = inst.Name:lower()
		if string.find(n, "water") or string.find(n, "river") or string.find(n, "ocean") then
			return true
		end
		return inst:FindFirstChild("Splash") ~= nil or inst:FindFirstChild("HitWater") ~= nil
	end

	local function underWater(part)
		local cur = part
		while cur and cur ~= workspace do
			if isWater(cur) then
				return true
			end
			cur = cur.Parent
		end
		return false
	end

	local function disableWater(part)
		if WP.saved[part] == nil then
			WP.saved[part] = part.CanTouch
		end
		part.CanTouch = false

		if getconnections then
			pcall(function()
				for _, c in ipairs(getconnections(part.Touched)) do
					if c.Disable then
						c:Disable()
						WP.cons[#WP.cons + 1] = c
					end
				end
			end)
		end
	end

	local function wpStop()
		WP.on = false
		killConns(WP.conns)

		for part, was in pairs(WP.saved) do
			if part and part.Parent then
				pcall(function()
					part.CanTouch = was
				end)
			end
		end
		table.clear(WP.saved)

		for _, c in ipairs(WP.cons) do
			pcall(function()
				if c.Enable then
					c:Enable()
				end
			end)
		end
		table.clear(WP.cons)
	end

	local function wpStart()
		wpStop()
		WP.on = true

		WP.conns[#WP.conns + 1] = workspace.DescendantAdded:Connect(function(d)
			if WP.on and d:IsA("BasePart") then
				pcall(function()
					if underWater(d) then
						disableWater(d)
					end
				end)
			end
		end)

		task.spawn(function()
			for _, d in ipairs(workspace:GetDescendants()) do
				if not WP.on then
					return
				end
				if d:IsA("BasePart") then
					pcall(function()
						if underWater(d) then
							disableWater(d)
						end
					end)
				end
			end
		end)
	end

	-- ---------------------------------------------------------------- FadeDisabler
	-- The fade GUIs (CameraFade / Fade / SpawnFade) are made invisible IN PLACE. They are never moved or
	-- deleted: the game's own scripts (FadeModule, RoleSelect, GameplayAnimations) look them up and throw
	-- errors / wait forever if they are gone.
	local FD = { on = false, saved = {}, conns = {} }
	local FADE_NAMES = { CameraFade = true, Fade = true, SpawnFade = true }

	local function fdHide(obj)
		local prop
		if obj:IsA("ScreenGui") then
			prop = "Enabled"
		elseif obj:IsA("GuiObject") then
			prop = "Visible"
		else
			return
		end

		if FD.saved[obj] then
			return
		end

		-- "value" always holds what the game last wanted, so turning this off restores the right state
		local rec = { prop = prop, value = obj[prop] }
		FD.saved[obj] = rec
		obj[prop] = false

		FD.conns[#FD.conns + 1] = obj:GetPropertyChangedSignal(prop):Connect(function()
			if FD.on and obj[prop] ~= false then
				rec.value = obj[prop]
				obj[prop] = false
			end
		end)
	end

	local function fdStop()
		FD.on = false
		killConns(FD.conns)

		for obj, rec in pairs(FD.saved) do
			if obj and obj.Parent then
				pcall(function()
					obj[rec.prop] = rec.value
				end)
			end
		end
		table.clear(FD.saved)
	end

	local function fdStart()
		fdStop()
		FD.on = true

		local pg = lp:FindFirstChildOfClass("PlayerGui")
		if not pg then
			return
		end

		for _, d in ipairs(pg:GetDescendants()) do
			if FADE_NAMES[d.Name] then
				pcall(fdHide, d)
			end
		end

		FD.conns[#FD.conns + 1] = pg.DescendantAdded:Connect(function(d)
			if FD.on and FADE_NAMES[d.Name] then
				pcall(fdHide, d)
			end
		end)
	end

	-- ---------------------------------------------------------------- Shutup GunReload
	local SR = { on = false, conns = {}, vol = {} }

	local function srMute(s)
		if not s:IsA("Sound") or s.Name ~= "Reload" or SR.vol[s] ~= nil then
			return
		end

		SR.vol[s] = s.Volume
		s.Volume = 0
		pcall(function()
			s:Stop()
		end)

		SR.conns[#SR.conns + 1] = s.Played:Connect(function()
			if SR.on then
				s.Volume = 0
				pcall(function()
					s:Stop()
				end)
			end
		end)
	end

	local function srStop()
		SR.on = false
		killConns(SR.conns)

		for s, v in pairs(SR.vol) do
			if s and s.Parent then
				pcall(function()
					s.Volume = v
				end)
			end
		end
		table.clear(SR.vol)
	end

	local function srStart()
		srStop()
		SR.on = true

		for _, d in ipairs(workspace:GetDescendants()) do
			pcall(srMute, d)
		end

		SR.conns[#SR.conns + 1] = workspace.DescendantAdded:Connect(function(d)
			if SR.on then
				pcall(srMute, d)
			end
		end)
	end

	onUnload(function()
		alStop()
		akStop()
		acStop()
		wpStop()
		fdStop()
		srStop()
		list2.avoidMurderOn = false
	end)

	-- ---------------------------------------------------------------- UI
	tbl43.combat:Section({ Title = "Aimlock" })

	AL.dropdown = tbl43.combat:Dropdown({
		Title = "Aimlock Target",
		Desc = "Pick the player your camera locks onto.",
		Multi = false,
		Value = nil,
		Values = alNames(),
		Callback = function(value)
			AL.name = value
			if value then
				note("Aimlock", "Target set to " .. tostring(value))
			end
		end,
	})

	local function alRefresh()
		task.defer(function()
			pcall(function()
				AL.dropdown:Refresh(alNames())
			end)
		end)
	end

	list2.conns[#list2.conns + 1] = Players.PlayerAdded:Connect(alRefresh)
	list2.conns[#list2.conns + 1] = Players.PlayerRemoving:Connect(alRefresh)

	local alToggle
	alToggle = tbl43.combat:Toggle({
		Title = "Aimlock",
		Flag = "Toggle_Extra_Aimlock",
		Desc = "Your camera stays locked on the player picked in Aimlock Target.",
		Type = "Toggle",
		Value = false,
		Callback = function(v)
			if v then
				if not AL.name then
					note("Aimlock", "Pick a target first!", "x")
					task.defer(function()
						pcall(list2.setToggle, alToggle, false)
					end)
					return
				end
				alStart()
			else
				alStop()
			end
		end,
	})

	-- the Auto Knife Throw switch now lives in the "Knife" section of the combat tab (next to Auto Dodge Knife)
	list2.autoKnifeThrow = function(v)
		if v then
			akStart()
			note("Auto Knife Throw", "Enabled.")
		else
			akStop()
			note("Auto Knife Throw", "Disabled.", "power-off")
		end
	end

	-- Farm Extras toggles: built later inside the Auto Farm > Settings section
	list2.mkFarmExtras = function()
	tbl43.farm:Toggle({
		Title = "Avoid Murder",
		Flag = "Toggle_Extra_AvoidMurder",
		Desc = "Coin Autofarm pauses (and stops moving) while the murderer is within 10 studs of you.",
		Type = "Toggle",
		Value = false,
		Callback = function(v)
			list2.avoidMurderOn = v and true or false
		end,
	})

	tbl43.farm:Toggle({
		Title = "AntiCoin",
		Flag = "Toggle_Extra_AntiCoin",
		Desc = "Hides coins and makes them untouchable. Turn off to bring them back.",
		Type = "Toggle",
		Value = false,
		Callback = function(v)
			if v then
				acStart()
				note("AntiCoin", "Coins removed.")
			else
				acStop()
				note("AntiCoin", "Coins restored.", "power-off")
			end
		end,
	})

	tbl43.farm:Toggle({
		Title = "OffDamageWater",
		Flag = "Toggle_Extra_OffDamageWater",
		Desc = "Water stops hurting you.",
		Type = "Toggle",
		Value = false,
		Callback = function(v)
			if v then
				wpStart()
				note("OffDamageWater", "Enabled.")
			else
				wpStop()
				note("OffDamageWater", "Disabled.", "power-off")
			end
		end,
	})

	tbl43.farm:Toggle({
		Title = "FadeDisabler",
		Flag = "Toggle_Extra_FadeDisabler",
		Desc = "Hides the black screen fades (they stay in place, just invisible).",
		Type = "Toggle",
		Value = false,
		Callback = function(v)
			if v then
				fdStart()
				note("FadeDisabler", "Fades hidden.")
			else
				fdStop()
				note("FadeDisabler", "Fades restored.", "power-off")
			end
		end,
	})

	end

	tbl43.visuals:Section({ Title = "Gun Sounds" })

	tbl43.visuals:Toggle({
		Title = "Shutup GunReload",
		Flag = "Toggle_Extra_ShutupReload",
		Desc = "Mutes the gun reload sound.",
		Type = "Toggle",
		Value = false,
		Callback = function(v)
			if v then
				srStart()
				note("GunReload Sound", "Muted!")
			else
				srStop()
				note("GunReload Sound", "Unmuted!")
			end
		end,
	})
end

-- ===================== EXTRA FEATURES 2 (ported from MM2_readable) =====================
-- Magic Aura, Gun Beam, Angel Wings, Aura Pack, Shader (RTX).
-- Every feature sits in its own do-block so its locals are released again (Lua allows 200 locals per chunk).
do
	local Players = game:GetService("Players")
	local RS = game:GetService("RunService")
	local TweenService = game:GetService("TweenService")
	local Lighting = game:GetService("Lighting")
	local Debris = game:GetService("Debris")
	local lp = Players.LocalPlayer

	local function note(title, content, icon)
		obj2:Notify({ Title = title, Content = content, Duration = 2, Icon = icon or "check" })
	end

	local function onUnload(fn)
		list2.conns[#list2.conns + 1] = { Disconnect = fn }
	end

	local function newGui(name)
		local g = Instance.new("ScreenGui")
		g.Name = name
		g.ResetOnSpawn = false
		g.IgnoreGuiInset = true
		g.DisplayOrder = 9999
		local ok = pcall(function()
			g.Parent = game:GetService("CoreGui")
		end)
		if not ok or not g.Parent then
			g.Parent = lp:FindFirstChildOfClass("PlayerGui")
		end
		return g
	end

	-- ================================================================ Magic Aura
	-- Six neon balls orbiting your root part.
	do
		local MA = { on = false, parts = {}, conn = nil }
		local COLORS = {
			Color3.fromRGB(170, 90, 255), Color3.fromRGB(255, 90, 130), Color3.fromRGB(90, 255, 130),
			Color3.fromRGB(255, 255, 90), Color3.fromRGB(255, 130, 255), Color3.fromRGB(130, 255, 255),
		}

		local function maClear()
			for _, p in ipairs(MA.parts) do
				pcall(function()
					p:Destroy()
				end)
			end
			table.clear(MA.parts)
		end

		local function maStop()
			MA.on = false
			if MA.conn then
				MA.conn:Disconnect()
				MA.conn = nil
			end
			maClear()
		end

		local function maStart()
			maStop()
			MA.on = true

			MA.conn = RS.Heartbeat:Connect(function()
				local c = lp.Character
				local hrp = c and c:FindFirstChild("HumanoidRootPart")
				if not hrp then
					return
				end

				while #MA.parts < 6 do
					local p = Instance.new("Part")
					p.Name = "AuraSphere"
					p.Anchored = true
					p.CanCollide = false
					p.CanQuery = false
					p.CanTouch = false
					p.CastShadow = false
					p.Material = Enum.Material.Neon
					p.Shape = Enum.PartType.Ball
					p.Size = Vector3.new(0.6, 0.6, 0.6)
					p.Transparency = 0.3
					p.Parent = workspace
					table.insert(MA.parts, p)
				end

				local t = tick()
				for i, p in ipairs(MA.parts) do
					local phase = (i - 1) * (math.pi / 3)
					local x = math.cos(t * 1.5 + phase) * 3
					local z = math.sin(t * 1.5 + phase) * 3
					local y = math.sin(t * 2 + phase)
					p.CFrame = CFrame.new(hrp.Position + Vector3.new(x, y, z))
					p.Color = COLORS[i] or COLORS[1]
				end
			end)
		end

		onUnload(maStop)

		tbl43.visuals:Section({ Title = "Auras" })

		local maToggle = tbl43.visuals:Toggle({
			Title = "Magic Aura",
			Flag = "Toggle_Extra_MagicAura",
			Desc = "Six glowing orbs circle around you (only you see them).",
			Type = "Toggle",
			Value = false,
			Callback = function(v)
				if v then
					maStart()
				else
					maStop()
				end
			end,
		})

		list2.auraOff = list2.auraOff or {}
		list2.auraOff[#list2.auraOff + 1] = function()
			if MA.on then
				pcall(list2.setToggle, maToggle, false)
				maStop()
			end
		end
	end

	-- ================================================================ Angel Wings (Auras)
	-- The wings are a local copy that is NOT parented to your character: no collisions, no weight and no
	-- extra joints, so they can't change how you walk. Every frame they are re-fitted onto your torso, so
	-- they follow your height / size automatically (and keep following after a respawn).
	do
		local ASSET = 97658130917593

		-- ---- optional tuning (the defaults are automatic) ----
		local SIZE_MULT      = 1     -- extra multiplier on top of the automatic size (1.2 = 20% bigger)
		local SPAN_ACCESSORY = 0     -- 0 = keep the size the creator made, scaled to your avatar. Or a width in studs.
		local SPAN_MODEL     = 7     -- wing width (studs) on a default avatar, used when the asset has no back attachment
		-- only used when the asset has NO back attachment (it is then placed by its shape):
		local BACK_GAP       = 0.1   -- gap between your back and the wings (studs)
		local RAISE          = 0.15  -- raise (+) / lower (-) the wings, as a fraction of torso height
		local FLIP_BACK      = false -- true = the wings face the wrong way (front/back swapped)
		local FLIP_UP        = false -- true = the wings are upside down

		local ATTACH_NAMES = { "BodyBackAttachment", "WaistBackAttachment" }
		local AW = { on = false, asset = nil, model = nil, info = nil, conn = nil, token = 0 }

		local function comp(v, i)
			if i == 1 then
				return v.X
			elseif i == 2 then
				return v.Y
			end
			return v.Z
		end

		local function awRemove()
			AW.info = nil
			if AW.model then
				pcall(function()
					AW.model:Destroy()
				end)
				AW.model = nil
			end
		end

		-- Turns the downloaded asset into one anchored Model + a description of how to fit it.
		local function awBuild()
			if not AW.asset then
				return nil
			end

			local obj = AW.asset:Clone()

			-- throw away everything that could move / weigh down / script the wings
			for _, d in ipairs(obj:GetDescendants()) do
				if d:IsA("BaseScript") or d:IsA("Humanoid") or d:IsA("Animator") or d:IsA("AnimationController")
					or d:IsA("BodyMover") or d:IsA("JointInstance") or d:IsA("WeldConstraint") or d:IsA("Constraint") then
					pcall(function()
						d:Destroy()
					end)
				end
			end

			local parts = {}
			if obj:IsA("BasePart") then
				parts[#parts + 1] = obj
			end
			for _, d in ipairs(obj:GetDescendants()) do
				if d:IsA("BasePart") then
					parts[#parts + 1] = d
				end
			end
			if #parts == 0 then
				obj:Destroy()
				return nil
			end

			-- every part goes straight into one wrapper Model (world positions are kept)
			local wrap = Instance.new("Model")
			wrap.Name = "AngelWingsFx"
			for _, p in ipairs(parts) do
				p.Anchored = true
				p.CanCollide = false
				p.CanQuery = false
				p.CanTouch = false
				p.Parent = wrap
			end
			if not obj:IsA("BasePart") then
				obj:Destroy()
			end

			-- measure the wings (ignoring invisible helper parts)
			local vis = {}
			for _, p in ipairs(parts) do
				if p.Transparency < 0.95 then
					vis[#vis + 1] = p
				end
			end
			if #vis == 0 then
				vis = parts
			end

			local main, best = vis[1], -1
			for _, p in ipairs(vis) do
				local v = p.Size.X * p.Size.Y * p.Size.Z
				if v > best then
					best = v
					main = p
				end
			end

			local rot = main.CFrame - main.CFrame.Position
			local inv = rot:Inverse()
			local mn = Vector3.new(math.huge, math.huge, math.huge)
			local mx = Vector3.new(-math.huge, -math.huge, -math.huge)
			local wsum, csum = 0, Vector3.new(0, 0, 0)

			for _, p in ipairs(vis) do
				local h = p.Size / 2
				for sx = -1, 1, 2 do
					for sy = -1, 1, 2 do
						for sz = -1, 1, 2 do
							local c = inv * (p.CFrame * Vector3.new(sx * h.X, sy * h.Y, sz * h.Z))
							mn = Vector3.new(math.min(mn.X, c.X), math.min(mn.Y, c.Y), math.min(mn.Z, c.Z))
							mx = Vector3.new(math.max(mx.X, c.X), math.max(mx.Y, c.Y), math.max(mx.Z, c.Z))
						end
					end
				end
				local w = math.max(p.Size.X * p.Size.Y * p.Size.Z, 1e-4)
				wsum = wsum + w
				csum = csum + (inv * p.Position) * w
			end

			local ext = mx - mn
			local ctr = (mx + mn) / 2
			local cen = csum / wsum

			-- thinnest side = depth (front/back). Of the other two, the left/right-symmetric one = span.
			local depth = 1
			for i = 2, 3 do
				if comp(ext, i) < comp(ext, depth) then
					depth = i
				end
			end
			local ai, bi
			for i = 1, 3 do
				if i ~= depth then
					if not ai then
						ai = i
					else
						bi = i
					end
				end
			end
			local function asym(i)
				return math.abs(comp(cen, i) - comp(ctr, i)) / math.max(comp(ext, i), 1e-3)
			end
			local span, vert
			if math.abs(asym(ai) - asym(bi)) > 0.04 then
				if asym(ai) < asym(bi) then
					span, vert = ai, bi
				else
					span, vert = bi, ai
				end
			elseif comp(ext, ai) >= comp(ext, bi) then
				span, vert = ai, bi
			else
				span, vert = bi, ai
			end

			-- reference frame of the wings: X = right, Y = up, Z = back (same convention as your torso)
			local mode, attName, frame = "fit", nil, nil
			for _, nm in ipairs(ATTACH_NAMES) do
				for _, p in ipairs(parts) do
					local a = p:FindFirstChild(nm)
					if a and a:IsA("Attachment") then
						mode, attName, frame = "attach", nm, p.CFrame * a.CFrame
						break
					end
				end
				if frame then
					break
				end
			end

			if not frame then
				local function axisW(i)
					local v = (i == 1 and Vector3.new(1, 0, 0)) or (i == 2 and Vector3.new(0, 1, 0)) or Vector3.new(0, 0, 1)
					return rot:VectorToWorldSpace(v)
				end
				local up = axisW(vert) * (FLIP_UP and -1 or 1)
				local back = axisW(depth) * (FLIP_BACK and -1 or 1)
				local right = up:Cross(back)
				frame = CFrame.fromMatrix(rot:VectorToWorldSpace(ctr), right, up, back)
			end

			wrap.WorldPivot = frame

			local meshes = {}
			for _, d in ipairs(wrap:GetDescendants()) do
				if d:IsA("SpecialMesh") and d.MeshType == Enum.MeshType.FileMesh then
					meshes[#meshes + 1] = { d, d.Scale, d.Offset }
				end
			end

			local info = {
				mode = mode,
				attName = attName,
				span = comp(ext, span),
				depth = comp(ext, depth),
				scale = 1,
				meshes = meshes,
			}
			return wrap, info
		end

		local function awSetScale(model, info, s)
			if math.abs(s / info.scale - 1) < 0.01 then
				return
			end
			info.scale = s
			pcall(function()
				model:ScaleTo(s)
			end)
			-- make sure file-meshes follow the scale too (no-op if ScaleTo already did it)
			for _, m in ipairs(info.meshes) do
				local sm = m[1]
				if sm.Parent then
					local want = m[2] * s
					if (sm.Scale - want).Magnitude > 1e-3 * math.max(want.Magnitude, 1) then
						sm.Scale = want
						sm.Offset = m[3] * s
					end
				end
			end
		end

		-- runs every frame: fits the wings onto the current torso
		local function awStep()
			local model, info = AW.model, AW.info
			if not (model and info) then
				return
			end

			local char = lp.Character
			local base = char and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))
			local cam = workspace.CurrentCamera
			if not (base and base:IsA("BasePart") and cam) then
				if model.Parent then
					model.Parent = nil
				end
				return
			end
			if model.Parent ~= cam then
				model.Parent = cam
			end

			-- body size: upper + lower torso height (2 studs on a default avatar, R6 and R15)
			local lower = char:FindFirstChild("LowerTorso")
			local torsoH = base.Size.Y + ((lower and lower:IsA("BasePart")) and lower.Size.Y or 0)
			local charScale = math.clamp(torsoH / 2, 0.1, 25)

			local carrier, cAtt
			if info.mode == "attach" then
				for _, nm in ipairs({ "UpperTorso", "LowerTorso", "Torso" }) do
					local p = char:FindFirstChild(nm)
					local a = p and p:FindFirstChild(info.attName)
					if a and a:IsA("Attachment") then
						carrier, cAtt = p, a
						break
					end
				end
			end

			local s, target
			if info.mode == "attach" then
				local fit = (SPAN_ACCESSORY > 0 and info.span > 0.01) and (SPAN_ACCESSORY / info.span) or 1
				s = fit * charScale * SIZE_MULT
				if carrier then
					target = carrier.CFrame * cAtt.CFrame
				else
					target = base.CFrame * CFrame.new(0, 0.35 * base.Size.Y, base.Size.Z / 2)
				end
			else
				local fit = (SPAN_MODEL > 0 and info.span > 0.01) and (SPAN_MODEL / info.span) or 1
				s = fit * charScale * SIZE_MULT
				-- wings sit just behind the back; a little of their depth is allowed to sink in (0.4 of half)
				local zc = base.Size.Z / 2 + s * info.depth * 0.4 + BACK_GAP * charScale
				target = base.CFrame * CFrame.new(0, RAISE * base.Size.Y, zc)
			end

			awSetScale(model, info, math.clamp(s, 0.05, 100))
			model:PivotTo(target)
		end

		-- returns true = ready, false = failed, nil = cancelled while loading
		local function awApply(my)
			awRemove()

			if not AW.asset then
				local ok, objs = pcall(function()
					return game:GetObjects("rbxassetid://" .. ASSET)
				end)
				if AW.token ~= my then
					return nil
				end
				if not ok or type(objs) ~= "table" or not objs[1] then
					return false
				end
				AW.asset = objs[1]
			end

			local ok, model, info = pcall(awBuild)
			if not ok or not model then
				return false
			end

			AW.model = model
			AW.info = info
			return true
		end

		local awToggle

		local function awStop()
			AW.on = false
			AW.token = AW.token + 1
			if AW.conn then
				AW.conn:Disconnect()
				AW.conn = nil
			end
			awRemove()
		end

		local function awStart()
			awStop()
			AW.on = true
			AW.token = AW.token + 1
			local my = AW.token

			task.spawn(function()
				local ok = awApply(my)
				if ok == nil or AW.token ~= my then
					return
				end

				if not ok then
					note("Auras", "Failed to load Angel Wings", "x")
					task.defer(function()
						pcall(list2.setToggle, awToggle, false)
					end)
					return
				end

				AW.conn = RS.Heartbeat:Connect(awStep)
				note("Auras", "Angel Wings enabled!")
			end)
		end

		onUnload(awStop)

		awToggle = tbl43.visuals:Toggle({
			Title = "Angel Wings",
			Flag = "Toggle_Extra_AngelWings",
			Desc = "Puts a pair of angel wings on your back. Fits your height automatically (only you see them).",
			Type = "Toggle",
			Value = false,
			Callback = function(v)
				if v then
					awStart()
				else
					awStop()
					note("Auras", "Angel Wings disabled.", "power-off")
				end
			end,
		})

		list2.auraOff = list2.auraOff or {}
		list2.auraOff[#list2.auraOff + 1] = function()
			if AW.on then
				pcall(list2.setToggle, awToggle, false)
				awStop()
			end
		end
	end

	-- ================================================================ Aura Pack (16 auras as toggles + Clear Aura)
	-- These toggles live in the same "Auras" section as Magic Aura and Angel Wings.
	-- Each toggle loads the aura model from its asset id and puts its parts / effects on YOUR character
	-- (client side only: other players don't see it). Any number of them can be on together.
	-- Everything that gets created is tracked, so turning it off, Clear Aura or unloading removes all of it.
	-- The active aura is put back on automatically after you respawn.
	-- The model is used as the creator made it (no recolouring / softening), so nothing disappears by accident.
	do
		local InsertService = game:GetService("InsertService")

		local AURAS = {
			{ "Midnight Blues", "12002206611" },
			{ "Rainbow Effect", "8509695714" },
			{ "Red Shield", "14598330167" },
			{ "Crimson King", "11955208820" },
			{ "Daemon of Cards", "10373359918" },
			{ "Starlight", "134645216613107" },
			{ "Heavenly", "139300897520961" },
			{ "Ribbon", "132069507632161" },
			{ "Sakura", "81755778619404" },
			{ "Wind", "80694081850877" },
			{ "Flow", "119913533725648" },
			{ "Star", "73754563740680" },
			{ "Wings Aura", "90816193741219" },
			{ "404 Aura", "18380225083" },
			{ "Star Aura", "14531523902" },
			{ "Necromancer", "113083314851722" },
		}


		-- parts of the downloaded model that only stand in for a body part (they are not copied themselves)
		local BODY = {}
		for _, n in ipairs({
			"Torso", "UpperTorso", "LowerTorso", "HumanoidRootPart", "Head",
			"Left Arm", "Right Arm", "Left Leg", "Right Leg",
			"LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand",
			"LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot",
		}) do
			BODY[n] = true
		end

		local R6_TO_R15 = {
			["Left Arm"] = "LeftUpperArm", ["Right Arm"] = "RightUpperArm",
			["Left Leg"] = "LeftUpperLeg", ["Right Leg"] = "RightUpperLeg",
		}

		local FX = {
			ParticleEmitter = true, Trail = true, Beam = true, Highlight = true,
			Fire = true, Smoke = true, Sparkles = true,
		}
		local LINKED = { Beam = true, Trail = true } -- effects that point at two attachments

		local AU = { set = {}, cache = {}, charConn = nil, toggles = {}, switching = false, st = {} }
		for _, a in ipairs(AURAS) do
			AU.st[a[1]] = { items = {}, token = 0, want = false, pending = nil }
		end
		-- Auras made of many separate pieces (circles, chains, discs ...): EVERY piece of the model is put on you,
		-- even the see-through ones that only hold decals / gui glows / attachments.
		AU.keepAll = { ["Necromancer"] = true }

		-- Floating auras: the pieces are not welded to your body. They glide after your character (smoothed)
		-- and bob gently, so they trail behind you instead of being stuck to you.
		AU.floaty = { ["Necromancer"] = true }
		AU.float = {}
		AU.floatConn = nil

		AU.floatStep = function(dt)
			local list = AU.float
			local now = os.clock()
			local alpha = 1 - math.exp(-5 * dt)

			for i = #list, 1, -1 do
				local f = list[i]
				local part, root = f.part, f.root

				if not (part and part.Parent and root and root.Parent) then
					table.remove(list, i)
				else
					local goal = (root.CFrame * f.rel) + Vector3.new(0, math.sin(now * 1.6 + f.phase) * 0.25, 0)

					if (part.Position - goal.Position).Magnitude > 30 then
						part.CFrame = goal -- you teleported: do not fly across the map
					else
						part.CFrame = part.CFrame:Lerp(goal, alpha)
					end
				end
			end

			if #list == 0 and AU.floatConn then
				AU.floatConn:Disconnect()
				AU.floatConn = nil
			end
		end

		local cur = nil -- record of the aura that is being built right now (a build never yields)

		local function track(inst)
			cur.items[#cur.items + 1] = inst
			AU.set[inst] = true
			return inst
		end

		local function auWipe(S)
			local list = S.items
			S.items = {}
			for _, inst in ipairs(list) do
				AU.set[inst] = nil
				pcall(function()
					inst:Destroy()
				end)
			end
		end

		local function weld(a, b)
			local w = Instance.new("WeldConstraint")
			w.Part0 = a
			w.Part1 = b
			w.Parent = b
			track(w)
		end

		-- body part of your character that matches a part name of the model (nil if there is none)
		local function charPartFor(char, name)
			local c = char:FindFirstChild(R6_TO_R15[name] or name)
			if not (c and c:IsA("BasePart")) then
				c = char:FindFirstChild(name)
			end
			if c and c:IsA("BasePart") and not AU.set[c] then
				return c
			end
			return nil
		end

		-- accessory style: an attachment on your body with the same name (BodyBackAttachment, HatAttachment ...)
		local function findBodyAtt(char, name)
			for _, p in ipairs(char:GetChildren()) do
				if p:IsA("BasePart") and not AU.set[p] then
					local a = p:FindFirstChild(name)
					if a and a:IsA("Attachment") and not AU.set[a] then
						return a
					end
				end
			end
			return nil
		end

		-- cleans the downloaded copy: no scripts / sounds / lights, loose weightless parts, no joints.
		-- If nothing in the model is switched on or visible, every effect is switched on.
		local function prepare(src)
			local anyOn = false
			for _, d in ipairs(src:GetDescendants()) do
				local cn = d.ClassName
				if d:IsA("BaseScript") or d:IsA("Sound") or d:IsA("Humanoid") or d:IsA("Animator")
					or d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight")
					or d:IsA("JointInstance") or d:IsA("WeldConstraint") then
					pcall(function()
						d:Destroy()
					end)
				elseif d:IsA("BasePart") then
					d.Anchored = false
					d.CanCollide = false
					d.CanQuery = false
					d.CanTouch = false
					d.Massless = true
					if not BODY[d.Name] and d.Transparency < 0.95 then
						anyOn = true
					end
				elseif FX[cn] and d.Enabled then
					anyOn = true
				end
			end

			if not anyOn then
				for _, d in ipairs(src:GetDescendants()) do
					if FX[d.ClassName] then
						pcall(function()
							d.Enabled = true
						end)
					end
				end
			end
		end

		local function ownerPart(inst, src)
			local p = inst.Parent
			while p and p ~= src do
				if p:IsA("BasePart") then
					return p
				end
				p = p.Parent
			end
			return nil
		end

		-- puts the (already prepared) model `src` onto the character. returns true, or false + reason
		local function auBuild(src, name)
			local char = lp.Character
			if not char then
				return false, "Character not ready!"
			end

			local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
			local head = char:FindFirstChild("Head")
			if not (torso and torso:IsA("BasePart") and head and head:IsA("BasePart")) then
				return false, "Character parts not found!"
			end

			local shield = (name == "Red Shield")

			local parts = {}
			for _, d in ipairs(src:GetDescendants()) do
				if d:IsA("BasePart") then
					parts[#parts + 1] = d
				end
			end

			-- reference frame of the model: its own torso, otherwise the middle of all its parts
			local function findPart(n)
				local p = src:FindFirstChild(n, true)
				if p and p:IsA("BasePart") then
					return p
				end
				return nil
			end
			local srcTorso = findPart("Torso") or findPart("UpperTorso") or findPart("HumanoidRootPart")
			local srcHead = findPart("Head")
			local refCF
			if srcTorso then
				refCF = srcTorso.CFrame
			elseif #parts > 0 then
				local sum = Vector3.new(0, 0, 0)
				for _, p in ipairs(parts) do
					sum = sum + p.Position
				end
				refCF = CFrame.new(sum / #parts)
			end

			-- parts that are visible, or that carry effects, are moved onto your character
			local moved, snap = {}, {}
			for _, p in ipairs(parts) do
				if not BODY[p.Name] then
					local use = AU.keepAll[name] or p.Transparency < 0.95
					if not use then
						for _, d in ipairs(p:GetDescendants()) do
							if FX[d.ClassName] then
								use = true
								break
							end
						end
					end
					if use then
						moved[#moved + 1] = p
						snap[p] = p.CFrame
					end
				end
			end

			for _, p in ipairs(moved) do
				local cf0 = snap[p]
				local carrier = torso
				local target

				for _, a in ipairs(p:GetChildren()) do
					if a:IsA("Attachment") then
						local ca = findBodyAtt(char, a.Name)
						if ca then
							carrier = ca.Parent
							target = carrier.CFrame * ca.CFrame * a.CFrame:Inverse()
							break
						end
					end
				end

				if not target then
					if p.Name == "Crown Base" then
						carrier = head
						local rel = CFrame.new(0, 1.5, 0)
						if srcHead then
							rel = srcHead.CFrame:Inverse() * cf0
						end
						target = head.CFrame * rel
					else
						target = torso.CFrame * (refCF and (refCF:Inverse() * cf0) or CFrame.new())
						if p.Name == "Aura" then
							target = target * CFrame.new(0, 0.5, 0)
						end
					end
				end

				p.Parent = char
				p.CFrame = target

				if AU.floaty[name] then
					local root = char:FindFirstChild("HumanoidRootPart") or torso

					p.Anchored = true
					AU.float[#AU.float + 1] = {
						part = p,
						root = root,
						rel = root.CFrame:Inverse() * target,
						phase = #AU.float * 0.9,
					}
					track(p)
				else
					weld(carrier, p)
					track(p)
				end
			end

			-- everything that is still inside the model (effects on stand-in parts / loose effects)
			local rest = src:GetDescendants()
			local attMap = {}

			local function targetFor(inst)
				local owner = ownerPart(inst, src)
				if owner then
					return charPartFor(char, owner.Name) or torso
				end
				return torso
			end

			for _, d in ipairs(rest) do
				if d:IsA("Attachment") then
					local c = d:Clone()
					c.Parent = targetFor(d)
					track(c)
					attMap[d] = c
				end
			end

			local linked = {}
			for _, d in ipairs(rest) do
				local cn = d.ClassName
				if FX[cn] and not d.Parent:IsA("Attachment") then
					if LINKED[cn] then
						linked[#linked + 1] = d
					else
						local c = d:Clone()
						c.Parent = targetFor(d)
						track(c)
					end
				end
			end

			for _, b in ipairs(linked) do
				local c = b:Clone()
				local good = true
				for _, prop in ipairs({ "Attachment0", "Attachment1" }) do
					local a = b[prop]
					if a then
						local m = attMap[a]
						if not m and a:IsDescendantOf(char) then
							m = a -- the attachment travelled with a moved part
						end
						if m then
							c[prop] = m
						else
							good = false
						end
					end
				end
				if good and c.Attachment0 and c.Attachment1 then
					c.Parent = targetFor(b)
					track(c)
				else
					c:Destroy()
				end
			end

			-- Red Shield: longer-lived particles that stay glued to the part
			local fxCount, visible = 0, 0
			local function fix(e)
				if FX[e.ClassName] then
					fxCount = fxCount + 1
				end
				if shield and e:IsA("ParticleEmitter") then
					local lt = e.Lifetime
					e.Lifetime = NumberRange.new(lt.Min * 4, lt.Max * 4)
					e.LockedToPart = true
				end
			end
			for _, it in ipairs(cur.items) do
				if it:IsA("BasePart") and (AU.keepAll[name] or it.Transparency < 0.95) then
					visible = visible + 1
				end
				fix(it)
				for _, d in ipairs(it:GetDescendants()) do
					fix(d)
				end
			end

			if #AU.float > 0 and not AU.floatConn then
				AU.floatConn = game:GetService("RunService").RenderStepped:Connect(AU.floatStep)
				list2.conns[#list2.conns + 1] = AU.floatConn
			end

			print(string.format("[F$VL Auras] %s: %d part(s) moved, %d effect(s), %d visible part(s)", name, #moved, fxCount, visible))

			if fxCount == 0 and visible == 0 then
				return false, "Nothing usable found in " .. name
			end
			return true
		end

		local function waitChar(timeout)
			local t0 = os.clock()
			while os.clock() - t0 < timeout do
				local c = lp.Character
				if c and c.Parent and c:FindFirstChild("Head") and (c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso")) then
					return c
				end
				task.wait(0.2)
			end
			return nil
		end

		-- mode: nil = normal (toggle turned on), "respawn" = silent re-apply after you respawned
		-- done(ok) is called when the load finished
		local function auEquip(id, name, mode, done)
			local S = AU.st[name]
			S.token = S.token + 1
			local my = S.token
			auWipe(S)
			S.want = true
			if mode == nil then
				S.pending = nil
			end

			local function fail(msg)
				if S.token ~= my then
					return
				end
				auWipe(S)
				if mode == nil then
					S.want = false
					S.pending = nil
				end
				note("Auras", msg, "x")
				if done then
					done(false)
				end
			end

			task.spawn(function()
				local raw = AU.cache[id]
				if not raw then
					local objs
					local ok, res = pcall(function()
						return game:GetObjects("rbxassetid://" .. id)
					end)
					if ok and type(res) == "table" and res[1] then
						objs = res
					else
						local ok2, model = pcall(function()
							return InsertService:LoadAsset(tonumber(id))
						end)
						if ok2 and model then
							objs = model:GetChildren()
						end
					end
					if S.token ~= my then
						return
					end
					if objs and #objs > 0 then
						raw = Instance.new("Model")
						for _, o in ipairs(objs) do
							o.Parent = raw
						end
						AU.cache[id] = raw
					end
				end

				if not raw then
					return fail("Failed to load " .. name)
				end

				if not waitChar(10) then
					return fail("Character not ready!")
				end
				if S.token ~= my then
					return
				end

				local src = raw:Clone()
				local ok, built, reason = pcall(function()
					cur = S
					prepare(src)
					return auBuild(src, name)
				end)
				cur = nil
				pcall(function()
					src:Destroy()
				end)

				if S.token ~= my then
					auWipe(S)
					return
				end

				if not ok then
					warn("[F$VL Auras] " .. tostring(built))
					return fail("Failed to apply " .. name)
				end
				if not built then
					return fail(reason or ("Failed to apply " .. name))
				end

				S.pending = { id = id, name = name }
				if mode == nil then
					note("Auras", name .. " enabled!")
				end
				if done then
					done(true)
				end
			end)
		end

		local function auClearOne(S)
			S.token = S.token + 1
			S.want = false
			S.pending = nil
			auWipe(S)
		end

		local function auClearAll()
			for _, a in ipairs(AURAS) do
				auClearOne(AU.st[a[1]])
			end
		end

		-- turns every pack toggle off in the UI (their callbacks are ignored while this runs)
		local function setToggles()
			AU.switching = true
			for _, tg in pairs(AU.toggles) do
				pcall(list2.setToggle, tg, false)
			end
			AU.switching = false
		end

		-- put every active aura back on after a respawn
		AU.charConn = lp.CharacterAdded:Connect(function(char)
			local list = {}
			for _, a in ipairs(AURAS) do
				local p = AU.st[a[1]].pending
				if p then
					list[#list + 1] = p
				end
			end
			if #list == 0 then
				return
			end
			task.spawn(function()
				task.wait(0.8)
				for _, p in ipairs(list) do
					if AU.st[p.name].pending == p and lp.Character == char then
						auEquip(p.id, p.name, "respawn")
					end
				end
			end)
		end)

		onUnload(function()
			auClearAll()
			if AU.charConn then
				AU.charConn:Disconnect()
				AU.charConn = nil
			end
			for _, obj in pairs(AU.cache) do
				pcall(function()
					obj:Destroy()
				end)
			end
			AU.cache = {}
		end)

		-- no new section: these toggles continue the existing "Auras" section (Magic Aura, Angel Wings)
		for _, a in ipairs(AURAS) do
			local nm, id = a[1], a[2]
			AU.toggles[nm] = tbl43.visuals:Toggle({
				Title = nm,
				Flag = "Toggle_Aura_" .. (nm:gsub("%s+", "_")),
				Desc = "Puts the " .. nm .. " aura on you (only you see it). Can be combined with the other auras.",
				Type = "Toggle",
				Value = false,
				Callback = function(v)
					if AU.switching then
						return
					end
					local S = AU.st[nm]
					if v then
						auEquip(id, nm, nil, function(ok)
							if not ok then
								task.defer(function()
									AU.switching = true
									pcall(list2.setToggle, AU.toggles[nm], false)
									AU.switching = false
								end)
							end
						end)
					elseif S.want then
						auClearOne(S)
						note("Auras", nm .. " disabled.", "power-off")
					end
				end,
			})
		end

		tbl43.visuals:Button({
			Title = "Clear Aura",
			Desc = "Turns off every aura in this section (the pack auras, Magic Aura and Angel Wings)",
			Icon = "circle-slash",
			Callback = function()
				auClearAll()
				setToggles()
				for _, fn in ipairs(list2.auraOff or {}) do
					pcall(fn)
				end
				note("Auras", "Aura cleared!")
			end,
		})
	end

	-- ================================================================ Gun Beam
	-- Draws its own beam every time YOU shoot (it listens to the game's "GunFired" event), so it no longer
	-- depends on the game's own beam object. Turn the toggle off to get the normal shots back.
	do
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local GB = {
			on = false, kind = "Neon Fat", color = Color3.fromRGB(0, 170, 255), conn = nil, token = 0,
			width = 1, life = 1, muzzle = true, sparks = true,
			tint = false, customId = "", customTex = "", ringAxis = "Up (Y)", bulletAxis = "Front (Z)",
		}
		local TYPES = {
			"Neon Fat", "Nuke", "Zigzag Light", "Orbital Strike", "Black Hole", "Rainbow RGB",
			"Lightning Bolt", "DNA Helix", "Plasma Rings", "Railgun", "Glitch", "Stardust", "Inferno",
			"Ring Tunnel", "Model Bullet", "Aurora Ribbon", "Custom Model", "Random",
		}
		local POOL = {}
		for _, t in ipairs(TYPES) do
			if t ~= "Random" and t ~= "Custom Model" then
				POOL[#POOL + 1] = t
			end
		end
		local WHITE = Color3.new(1, 1, 1)
		local FIRE = Color3.fromRGB(255, 120, 30)

		local function toPos(v)
			if typeof(v) == "Vector3" then
				return v
			elseif typeof(v) == "CFrame" then
				return v.Position
			elseif typeof(v) == "Instance" then
				if v:IsA("Attachment") then
					return v.WorldPosition
				elseif v:IsA("BasePart") then
					return v.Position
				end
			end
			return nil
		end

		local function v3(n)
			return Vector3.new(n, n, n)
		end

		local function mkPart(shape, size, color, pos, material)
			local p = Instance.new("Part")
			p.Anchored = true
			p.CanCollide = false
			p.CanQuery = false
			p.CanTouch = false
			p.CastShadow = false
			p.Shape = shape
			p.Material = material or Enum.Material.Neon
			p.Color = color
			p.Size = size
			p.Position = pos
			p.Parent = workspace
			return p
		end

		local function tween(inst, time, props)
			TweenService:Create(inst, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
		end

		-- one straight neon bar from a to b that thins out and fades
		-- (width and life are scaled by the Beam Width / Beam Duration sliders)
		local function line(a, b, width, color, life, startTransparency)
			local len = (b - a).Magnitude
			if len < 0.1 then
				return
			end
			width = width * GB.width
			life = life * GB.life
			local p = mkPart(Enum.PartType.Block, Vector3.new(width, width, len), color, a)
			p.CFrame = CFrame.lookAt(a, b) * CFrame.new(0, 0, -len / 2)
			p.Transparency = startTransparency or 0
			tween(p, life, { Transparency = 1, Size = Vector3.new(width * 0.2, width * 0.2, len) })
			Debris:AddItem(p, life + 0.1)
		end

		-- two directions at right angles to a unit vector
		local function basis(unit)
			local right = unit:Cross(Vector3.new(0, 1, 0))
			if right.Magnitude < 0.01 then
				right = Vector3.new(1, 0, 0)
			end
			right = right.Unit
			return right, right:Cross(unit)
		end

		-- bright burst of light
		local function flash(pos, color, size)
			local core = mkPart(Enum.PartType.Ball, v3(size * 0.4), WHITE, pos)
			local halo = mkPart(Enum.PartType.Ball, v3(size * 0.4), color, pos)
			halo.Transparency = 0.4
			local light = Instance.new("PointLight")
			light.Range = size * 3
			light.Brightness = 3
			light.Color = color
			light.Parent = halo
			local t = 0.3 * GB.life
			tween(core, t, { Size = v3(size * 0.9), Transparency = 1 })
			tween(halo, t, { Size = v3(size * 1.6), Transparency = 1 })
			Debris:AddItem(core, t + 0.1)
			Debris:AddItem(halo, t + 0.1)
		end

		-- circle that always faces the camera and expands while it fades (a UIStroke on a round frame)
		local function ring(pos, color, startSize, endSize, life, delay, thickness)
			local function go()
				local lifeT = life * GB.life
				local anchor = mkPart(Enum.PartType.Ball, v3(0.2), color, pos)
				anchor.Transparency = 1

				local gui = Instance.new("BillboardGui")
				gui.Size = UDim2.fromOffset(startSize, startSize)
				gui.LightInfluence = 0
				gui.Adornee = anchor
				gui.Parent = anchor

				local f = Instance.new("Frame")
				f.AnchorPoint = Vector2.new(0.5, 0.5)
				f.Position = UDim2.fromScale(0.5, 0.5)
				f.Size = UDim2.fromScale(1, 1)
				f.BackgroundTransparency = 1
				f.BorderSizePixel = 0
				f.Parent = gui

				local corner = Instance.new("UICorner")
				corner.CornerRadius = UDim.new(0.5, 0)
				corner.Parent = f

				local stroke = Instance.new("UIStroke")
				stroke.Color = color
				stroke.Thickness = thickness or 3
				stroke.Transparency = 0.05
				stroke.Parent = f

				tween(gui, lifeT, { Size = UDim2.fromOffset(endSize, endSize) })
				tween(stroke, lifeT, { Transparency = 1, Thickness = 0.5 })
				Debris:AddItem(anchor, lifeT + 0.1)
			end

			if delay and delay > 0 then
				task.delay(delay, go)
			else
				go()
			end
		end

		-- little glowing shards that fly out and fall
		local function sparks(pos, color, count, speed)
			for i = 1, count do
				local d = Vector3.new(math.random() - 0.5, math.random() * 0.8 + 0.1, math.random() - 0.5)
				if d.Magnitude < 0.05 then
					d = Vector3.new(0, 1, 0)
				end
				d = d.Unit
				local p = mkPart(Enum.PartType.Block, Vector3.new(0.12, 0.12, 0.6), (i % 3 == 0) and WHITE or color, pos)
				p.CFrame = CFrame.lookAt(pos, pos + d)
				local life = (0.35 + math.random() * 0.35) * GB.life
				local target = pos + d * (speed * (0.5 + math.random())) - Vector3.new(0, 1.5, 0)
				TweenService:Create(p, TweenInfo.new(life, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					CFrame = CFrame.lookAt(target, target + d),
					Transparency = 1,
					Size = Vector3.new(0.03, 0.03, 0.2),
				}):Play()
				Debris:AddItem(p, life + 0.1)
			end
		end

		-- short-lived bead (used by the helix)
		local function bead(pos, size, color, delay, life)
			local function go()
				local lifeT = life * GB.life
				local p = mkPart(Enum.PartType.Ball, v3(size), color, pos)
				tween(p, lifeT, { Size = v3(size * 0.2), Transparency = 1 })
				Debris:AddItem(p, lifeT + 0.1)
			end
			if delay > 0 then
				task.delay(delay, go)
			else
				go()
			end
		end

		-- one burst of particles spread over the whole length of the shot
		local function emitAlong(p0, p1, o)
			local len = (p1 - p0).Magnitude
			if len < 0.5 then
				return
			end
			local part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.CastShadow = false
			part.Transparency = 1
			part.Size = Vector3.new(0.6, 0.6, len)
			part.CFrame = CFrame.lookAt(p0:Lerp(p1, 0.5), p1)
			part.Parent = workspace

			local e = Instance.new("ParticleEmitter")
			e.Texture = o.texture
			e.Color = o.color
			e.LightEmission = 1
			e.LightInfluence = 0
			e.Size = o.size
			e.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.7, 0.3),
				NumberSequenceKeypoint.new(1, 1),
			})
			e.Lifetime = o.lifetime
			e.Speed = o.speed
			e.SpreadAngle = Vector2.new(180, 180)
			e.Rotation = NumberRange.new(0, 360)
			e.RotSpeed = NumberRange.new(-120, 120)
			e.Acceleration = o.accel or Vector3.new(0, 0, 0)
			e.Rate = 0
			e.Parent = part
			e:Emit(o.count)
			Debris:AddItem(part, o.lifetime.Max + 0.4)
		end

		-- jagged list of points from a to b (calm at both ends, wild in the middle)
		local function jag(a, b, segs, amp)
			local dir = b - a
			local dist = dir.Magnitude
			local unit = dir.Unit
			local right, up = basis(unit)
			local pts = { a }
			for i = 1, segs - 1 do
				local t = i / segs
				local env = math.sin(t * math.pi)
				local base = a + unit * (dist * t)
				pts[#pts + 1] = base + (right * (math.random() - 0.5) + up * (math.random() - 0.5)) * amp * 2 * env
			end
			pts[#pts + 1] = b
			return pts
		end

		local function impact(kind, pos, color)
			if kind == "Nuke" then
				local ball = mkPart(Enum.PartType.Ball, Vector3.new(1, 1, 1), color, pos)
				ball.Transparency = 0.2
				local light = Instance.new("PointLight")
				light.Range = 20
				light.Brightness = 4
				light.Color = color
				light.Parent = ball
				tween(ball, 0.6, { Size = Vector3.new(14, 14, 14), Transparency = 1 })
				Debris:AddItem(ball, 0.8)
			elseif kind == "Orbital Strike" then
				local pillar = mkPart(Enum.PartType.Block, Vector3.new(2, 150, 2), color, pos + Vector3.new(0, 75, 0))
				pillar.Transparency = 0.1
				tween(pillar, 0.6, { Size = Vector3.new(0.2, 150, 0.2), Transparency = 1 })
				local ball = mkPart(Enum.PartType.Ball, Vector3.new(1, 1, 1), color, pos)
				tween(ball, 0.5, { Size = Vector3.new(6, 6, 6), Transparency = 1 })
				Debris:AddItem(pillar, 0.8)
				Debris:AddItem(ball, 0.8)
			elseif kind == "Black Hole" then
				local core = mkPart(Enum.PartType.Ball, Vector3.new(0.5, 0.5, 0.5), Color3.new(0, 0, 0), pos, Enum.Material.SmoothPlastic)
				local halo = mkPart(Enum.PartType.Ball, Vector3.new(0.5, 0.5, 0.5), color, pos)
				halo.Transparency = 0.6
				tween(core, 0.25, { Size = Vector3.new(6, 6, 6) })
				tween(halo, 0.25, { Size = Vector3.new(9, 9, 9) })
				task.delay(0.3, function()
					tween(core, 0.4, { Size = Vector3.new(0.1, 0.1, 0.1) })
					tween(halo, 0.4, { Size = Vector3.new(0.1, 0.1, 0.1), Transparency = 1 })
				end)
				Debris:AddItem(core, 1)
				Debris:AddItem(halo, 1)
			end
		end

		local function zigzag(p0, p1, color)
			local dir = p1 - p0
			local dist = dir.Magnitude
			if dist < 1 then
				return
			end

			local unit = dir.Unit
			local right = unit:Cross(Vector3.new(0, 1, 0))
			if right.Magnitude < 0.01 then
				right = Vector3.new(1, 0, 0)
			end
			right = right.Unit
			local up = right:Cross(unit)

			local n = math.clamp(math.floor(dist / 6), 4, 24)
			local points = { p0 }
			for i = 1, n - 1 do
				local base = p0 + unit * (dist * i / n)
				points[#points + 1] = base + right * (math.random() - 0.5) * 3 + up * (math.random() - 0.5) * 3
			end
			points[#points + 1] = p1

			for i = 1, #points - 1 do
				line(points[i], points[i + 1], 0.25, color, 0.35)
			end
		end

		-- ---------------------------------------------------------------- new beam types
		local function lightning(p0, p1, color)
			local dist = (p1 - p0).Magnitude
			if dist < 1 then
				return
			end
			local unit = (p1 - p0).Unit
			local right, up = basis(unit)

			local pts = jag(p0, p1, math.clamp(math.floor(dist / 4), 6, 30), 1.6)
			for i = 1, #pts - 1 do
				line(pts[i], pts[i + 1], 0.7, color, 0.35, 0.55)
				line(pts[i], pts[i + 1], 0.18, WHITE, 0.3)
			end

			-- side branches
			for _ = 1, math.clamp(math.floor(dist / 25), 2, 6) do
				local k = math.random(2, #pts - 1)
				local start = pts[k]
				local bdir = (unit + (right * (math.random() - 0.5) + up * (math.random() - 0.5)) * 1.6).Unit
				local stop = start + bdir * (4 + math.random() * 8)
				local bpts = jag(start, stop, 3, 0.8)
				for j = 1, #bpts - 1 do
					line(bpts[j], bpts[j + 1], 0.3, color, 0.25, 0.4)
				end
			end

			-- quick second strike so it flickers
			task.delay(0.06, function()
				local pts2 = jag(p0, p1, math.clamp(math.floor(dist / 4), 6, 30), 1.4)
				for i = 1, #pts2 - 1 do
					line(pts2[i], pts2[i + 1], 0.4, color, 0.2, 0.4)
					line(pts2[i], pts2[i + 1], 0.12, WHITE, 0.2)
				end
			end)
		end

		local function helix(p0, p1, color)
			local dist = (p1 - p0).Magnitude
			if dist < 2 then
				return
			end
			local unit = (p1 - p0).Unit
			local right, up = basis(unit)
			local h = color:ToHSV()
			local colB = Color3.fromHSV((h + 0.5) % 1, 0.85, 1)

			local n = math.clamp(math.floor(dist / 1.5), 10, 28)
			local turns = dist / 9
			local radius = 1.1 * GB.width
			local prevA, prevB
			for i = 0, n do
				local t = i / n
				local ang = t * turns * math.pi * 2
				local off = (right * math.cos(ang) + up * math.sin(ang)) * radius
				local c = p0:Lerp(p1, t)
				local a, b = c + off, c - off
				bead(a, 0.55 * GB.width, color, t * 0.18, 0.4)
				bead(b, 0.55 * GB.width, colB, t * 0.18, 0.4)
				if prevA then
					line(prevA, a, 0.14, color, 0.4, 0.2)
					line(prevB, b, 0.14, colB, 0.4, 0.2)
				end
				if i % 2 == 0 then
					line(a, b, 0.07, WHITE, 0.35, 0.3)
				end
				prevA, prevB = a, b
			end
		end

		local function plasmaRings(p0, p1, color)
			local dist = (p1 - p0).Magnitude
			line(p0, p1, 0.3, color, 0.5, 0.2)
			line(p0, p1, 0.1, WHITE, 0.5)
			local n = math.clamp(math.floor(dist / 3), 6, 26)
			for i = 1, n do
				local t = i / n
				ring(p0:Lerp(p1, t), (i % 2 == 0) and color or WHITE, 6, 55 + (1 - t) * 25, 0.35, t * 0.15, 2.5)
			end
		end

		local function railgun(p0, p1, color)
			local dist = (p1 - p0).Magnitude
			line(p0, p1, 1.6, color, 0.6, 0.75) -- soft glow around the shot
			line(p0, p1, 0.35, color, 0.4, 0.1)
			line(p0, p1, 0.12, WHITE, 0.3)

			-- bright head that rushes along the line
			local head = mkPart(Enum.PartType.Ball, v3(1.4 * GB.width), WHITE, p0)
			local light = Instance.new("PointLight")
			light.Range = 14
			light.Brightness = 3
			light.Color = color
			light.Parent = head
			local travel = math.clamp(dist / 500, 0.05, 0.35)
			TweenService:Create(head, TweenInfo.new(travel, Enum.EasingStyle.Linear), { Position = p1 }):Play()
			task.delay(travel, function()
				if head.Parent then
					tween(head, 0.2 * GB.life, { Size = v3(4 * GB.width), Transparency = 1 })
				end
			end)
			Debris:AddItem(head, travel + 0.5)
		end

		local function glitch(p0, p1, color)
			local dist = (p1 - p0).Magnitude
			if dist < 1 then
				return
			end
			local unit = (p1 - p0).Unit
			local right, up = basis(unit)
			local h = color:ToHSV()
			local palette = { color, Color3.fromHSV((h + 0.5) % 1, 1, 1), WHITE }
			local segs = 10

			line(p0, p1, 0.12, WHITE, 0.25)
			for pass = 0, 3 do
				task.delay(pass * 0.05, function()
					local prev = p0
					for i = 1, segs do
						local pt = p0:Lerp(p1, i / segs)
						if i < segs then
							pt = pt + (right * (math.random() - 0.5) + up * (math.random() - 0.5)) * 3 * GB.width
						end
						line(prev, pt, 0.35 + math.random() * 0.4, palette[math.random(1, 3)], 0.12, 0.1)
						prev = pt
					end
				end)
			end
		end

		local function stardust(p0, p1, color)
			local dist = (p1 - p0).Magnitude
			line(p0, p1, 0.18, color, 0.45, 0.2)
			emitAlong(p0, p1, {
				texture = "rbxasset://textures/particles/sparkles_main.dds",
				color = ColorSequence.new(color, WHITE),
				size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.9 * GB.width), NumberSequenceKeypoint.new(1, 0) }),
				lifetime = NumberRange.new(0.6 * GB.life, 1.1 * GB.life),
				speed = NumberRange.new(2, 5),
				count = math.clamp(math.floor(dist * 2), 30, 260),
			})
		end

		local function inferno(p0, p1)
			local dist = (p1 - p0).Magnitude
			line(p0, p1, 0.7, FIRE, 0.4, 0.4)
			line(p0, p1, 0.22, Color3.fromRGB(255, 240, 150), 0.35)
			emitAlong(p0, p1, {
				texture = "rbxasset://textures/particles/fire_main.dds",
				color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 80)),
					ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 110, 20)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 20, 0)),
				}),
				size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.6 * GB.width), NumberSequenceKeypoint.new(1, 0.2) }),
				lifetime = NumberRange.new(0.5 * GB.life, 1 * GB.life),
				speed = NumberRange.new(1, 4),
				accel = Vector3.new(0, 6, 0),
				count = math.clamp(math.floor(dist * 3), 40, 220),
			})
		end

		-- ---------------------------------------------------------------- extras on every shot
		-- ---------------------------------------------------------------- effects that use asset IDs
		-- Everything lives in the AS table so it only costs one local.
		-- Models are downloaded once, cached, then cloned for each shot.
		local AS = {
			RINGS = "15439100851", BULLET = "8448331374", TEX = "12781800668",
			cache = {}, loading = {},
			AXES = {
				["Front (Z)"] = CFrame.new(),
				["Back (-Z)"] = CFrame.Angles(0, math.pi, 0),
				["Side (X)"] = CFrame.Angles(0, math.rad(90), 0),
				["Up (Y)"] = CFrame.Angles(math.rad(-90), 0, 0),
			},
			AXIS_NAMES = { "Front (Z)", "Back (-Z)", "Side (X)", "Up (Y)" },
		}

		-- download a model (can yield). Returns the cached holder, or nil if it failed.
		function AS.load(id)
			id = tostring(id or "")
			if id == "" then
				return nil
			end
			if AS.cache[id] then
				return AS.cache[id]
			end
			if AS.loading[id] then
				return nil
			end
			AS.loading[id] = true

			local objs
			local ok, res = pcall(function()
				return game:GetObjects("rbxassetid://" .. id)
			end)
			if ok and type(res) == "table" and res[1] then
				objs = res
			else
				local ok2, m = pcall(function()
					return game:GetService("InsertService"):LoadAsset(tonumber(id))
				end)
				if ok2 and m then
					objs = m:GetChildren()
				end
			end
			AS.loading[id] = nil

			if not objs or #objs == 0 then
				return nil
			end
			local holder = Instance.new("Model")
			for _, o in ipairs(objs) do
				o.Parent = holder
			end
			AS.cache[id] = holder
			return holder
		end

		-- never yields: use the cached model, or start downloading it for the next shot
		function AS.get(id)
			id = tostring(id or "")
			local m = AS.cache[id]
			if not m and id ~= "" and not AS.loading[id] then
				task.spawn(AS.load, id)
			end
			return m
		end

		function AS.preload(kind)
			local ids = {}
			if kind == "Ring Tunnel" or kind == "Random" then
				ids[#ids + 1] = AS.RINGS
			end
			if kind == "Model Bullet" or kind == "Random" then
				ids[#ids + 1] = AS.BULLET
			end
			if kind == "Custom Model" and GB.customId ~= "" then
				ids[#ids + 1] = GB.customId
			end
			for _, id in ipairs(ids) do
				if not AS.cache[id] then
					task.spawn(AS.load, id)
				end
			end
		end

		-- clone for one use: anchored, no collisions, no scripts. Returns the clone and its parts.
		function AS.prep(src, color)
			local m = src:Clone()
			local parts = {}
			for _, d in ipairs(m:GetDescendants()) do
				if d:IsA("BaseScript") or d:IsA("ModuleScript") or d:IsA("Sound") then
					d:Destroy()
				elseif d:IsA("BasePart") then
					d.Anchored = true
					d.CanCollide = false
					d.CanQuery = false
					d.CanTouch = false
					d.CastShadow = false
					d.Massless = true
					if GB.tint then
						d.Color = color
					end
					parts[#parts + 1] = { d, d.Transparency }
				elseif GB.tint and d:IsA("ParticleEmitter") then
					d.Color = ColorSequence.new(color)
				end
			end
			return m, parts
		end

		-- resize so the model's longest side is `target` studs
		function AS.fit(m, target)
			local ok, size = pcall(function()
				return m:GetExtentsSize()
			end)
			if ok then
				local mx = math.max(size.X, size.Y, size.Z)
				if mx > 0.001 then
					pcall(function()
						m:ScaleTo(m:GetScale() * target / mx)
					end)
				end
			end
		end

		-- calls step(0..1) every frame for `dur` seconds, then removes the model
		function AS.run(m, dur, step)
			local t0 = os.clock()
			local conn
			conn = RS.Heartbeat:Connect(function()
				local a = (os.clock() - t0) / dur
				if a >= 1 or not m.Parent then
					conn:Disconnect()
					pcall(function()
						m:Destroy()
					end)
					return
				end
				pcall(step, a)
			end)
		end

		function AS.fade(parts, alpha)
			for _, e in ipairs(parts) do
				pcall(function()
					e[1].Transparency = e[2] + (1 - e[2]) * alpha
				end)
			end
		end

		-- copies of the rings model along the shot, popping open one after another
		function AS.rings(p0, p1, color)
			local dist = (p1 - p0).Magnitude
			line(p0, p1, 0.25, color, 0.5, 0.25)
			line(p0, p1, 0.1, WHITE, 0.5)
			local tpl = AS.get(AS.RINGS)
			if not tpl or dist < 2 then
				return
			end

			local unit = (p1 - p0).Unit
			local axis = AS.AXES[GB.ringAxis] or AS.AXES["Up (Y)"]
			local n = math.clamp(math.floor(dist / 7), 3, 10)
			for i = 1, n do
				local t = i / n
				local pos = p0:Lerp(p1, t)
				task.delay(t * 0.15, function()
					local m, parts = AS.prep(tpl, color)
					AS.fit(m, 7 * GB.width)
					local base = m:GetScale()
					local cf = CFrame.lookAt(pos, pos + unit) * axis
					local grow = #parts <= 30 -- growing every frame is only cheap for small models
					if grow then
						m:ScaleTo(base * 0.3)
					end
					m:PivotTo(cf)
					m.Parent = workspace
					AS.run(m, 0.55 * GB.life, function(a)
						if grow then
							local e = 1 - (1 - a) * (1 - a)
							m:ScaleTo(base * (0.3 + 0.7 * e))
						end
						AS.fade(parts, math.clamp((a - 0.4) / 0.6, 0, 1))
					end)
				end)
			end
		end

		-- a model that flies from the gun to the target with a glowing trail behind it
		function AS.bullet(p0, p1, color, id)
			local dist = (p1 - p0).Magnitude
			line(p0, p1, 0.3, color, 0.4, 0.3)
			line(p0, p1, 0.1, WHITE, 0.35)
			local tpl = AS.get(id)
			if not tpl or dist < 1 then
				return
			end

			local unit = (p1 - p0).Unit
			local axis = AS.AXES[GB.bulletAxis] or AS.AXES["Front (Z)"]
			local m, parts = AS.prep(tpl, color)
			AS.fit(m, 3.5 * GB.width)

			local travel = math.clamp(dist / 350, 0.06, 0.4)
			local tail = 0.18 * GB.life
			local function place(pos)
				m:PivotTo(CFrame.lookAt(pos, pos + unit) * axis)
			end
			place(p0)
			m.Parent = workspace
			AS.run(m, travel + tail, function(a)
				local el = a * (travel + tail)
				place(p0:Lerp(p1, math.min(el / travel, 1)))
				if el > travel then
					AS.fade(parts, (el - travel) / tail)
				end
			end)
		end

		-- three twisting ribbons that use an image texture (Beam objects)
		function AS.aurora(p0, p1, color)
			local dist = (p1 - p0).Magnitude
			line(p0, p1, 0.16, color, 0.5, 0.2)
			line(p0, p1, 0.07, WHITE, 0.5)
			if dist < 2 then
				return
			end

			local tex = (GB.customTex ~= "") and GB.customTex or AS.TEX
			local h = color:ToHSV()
			local colB = Color3.fromHSV((h + 0.15) % 1, 0.8, 1)
			local colC = Color3.fromHSV((h + 0.85) % 1, 0.8, 1)
			local life = 0.7 * GB.life

			local function anchor(pos)
				local p = Instance.new("Part")
				p.Anchored = true
				p.CanCollide = false
				p.CanQuery = false
				p.CanTouch = false
				p.CastShadow = false
				p.Transparency = 1
				p.Size = Vector3.new(0.2, 0.2, 0.2)
				p.Position = pos
				p.Parent = workspace
				local a = Instance.new("Attachment")
				a.Parent = p
				Debris:AddItem(p, life + 0.2)
				return p, a
			end
			local pa, a0 = anchor(p0)
			local _, a1 = anchor(p1)

			local function ribbon(width, c, curve, speed)
				local b = Instance.new("Beam")
				b.Attachment0 = a0
				b.Attachment1 = a1
				b.FaceCamera = true
				b.Texture = "rbxassetid://" .. tex
				b.TextureMode = Enum.TextureMode.Wrap
				b.TextureLength = 3
				b.TextureSpeed = speed
				b.LightEmission = 1
				b.LightInfluence = 0
				b.Brightness = 2
				b.Color = ColorSequence.new(c)
				b.Transparency = NumberSequence.new(0.1)
				b.CurveSize0 = curve
				b.CurveSize1 = -curve
				b.Segments = 30
				b.Width0 = width * GB.width
				b.Width1 = width * GB.width
				b.Parent = pa
				tween(b, life, { Width0 = 0, Width1 = 0 })
			end
			ribbon(1.5, color, 5, -2)
			ribbon(1.2, colB, -5, 2)
			ribbon(0.9, colC, 3, -3)
		end
		local function muzzleFx(pos, kind)
			local c = (kind == "Inferno") and FIRE or GB.color
			flash(pos, c, 2.5)
			ring(pos, c, 6, 55, 0.3, 0, 2.5)
		end

		local function hitFx(pos, kind)
			local c = (kind == "Inferno") and FIRE or GB.color
			sparks(pos, c, 14, 9)
			ring(pos, c, 8, 110, 0.45, 0, 3)
			ring(pos, WHITE, 6, 60, 0.35, 0.07, 2)
			if kind == "Lightning Bolt" or kind == "Railgun" then
				flash(pos, c, 6)
			end
		end

		local function fireBeam(p0, p1)
			local color = GB.color
			local kind = GB.kind
			if kind == "Random" then
				kind = POOL[math.random(#POOL)]
			end

			if kind == "Neon Fat" then
				line(p0, p1, 0.9, color, 0.45, 0.35)
				line(p0, p1, 0.3, WHITE, 0.45)
			elseif kind == "Nuke" then
				line(p0, p1, 0.8, color, 0.5, 0.2)
				line(p0, p1, 0.3, WHITE, 0.5)
				impact("Nuke", p1, color)
			elseif kind == "Zigzag Light" then
				zigzag(p0, p1, color)
			elseif kind == "Orbital Strike" then
				line(p0, p1, 0.8, color, 0.5, 0.2)
				line(p0, p1, 0.3, WHITE, 0.5)
				impact("Orbital Strike", p1, color)
			elseif kind == "Black Hole" then
				line(p0, p1, 0.8, color, 0.5, 0.2)
				impact("Black Hole", p1, color)
			elseif kind == "Rainbow RGB" then
				local n = 14
				local offset = os.clock() % 1
				for i = 0, n - 1 do
					local a = p0:Lerp(p1, i / n)
					local b = p0:Lerp(p1, (i + 1) / n)
					line(a, b, 0.8, Color3.fromHSV((i / n + offset) % 1, 1, 1), 0.5, 0.1)
				end
			elseif kind == "Lightning Bolt" then
				lightning(p0, p1, color)
			elseif kind == "DNA Helix" then
				helix(p0, p1, color)
			elseif kind == "Plasma Rings" then
				plasmaRings(p0, p1, color)
			elseif kind == "Railgun" then
				railgun(p0, p1, color)
			elseif kind == "Glitch" then
				glitch(p0, p1, color)
			elseif kind == "Stardust" then
				stardust(p0, p1, color)
			elseif kind == "Inferno" then
				inferno(p0, p1)
			elseif kind == "Ring Tunnel" then
				AS.rings(p0, p1, color)
			elseif kind == "Model Bullet" then
				AS.bullet(p0, p1, color, AS.BULLET)
			elseif kind == "Aurora Ribbon" then
				AS.aurora(p0, p1, color)
			elseif kind == "Custom Model" then
				AS.bullet(p0, p1, color, GB.customId)
			end

			if GB.muzzle then
				pcall(muzzleFx, p0, kind)
			end
			if GB.sparks then
				pcall(hitFx, p1, kind)
			end
		end

		local gbToggle

		local function gbStop()
			GB.on = false
			GB.token = GB.token + 1
			if GB.conn then
				GB.conn:Disconnect()
				GB.conn = nil
			end
		end

		local function gbStart()
			gbStop()
			GB.on = true
			GB.token = GB.token + 1
			local my = GB.token

			task.spawn(function()
				local ok, remote = pcall(function()
					return ReplicatedStorage:WaitForChild("ClientServices", 5)
						:WaitForChild("WeaponService", 5)
						:WaitForChild("GunFired", 5)
				end)
				if GB.token ~= my then
					return
				end

				if not ok or not remote then
					note("Gun Beam", "Could not find the gun event.", "x")
					task.defer(function()
						pcall(list2.setToggle, gbToggle, false)
					end)
					return
				end

				GB.conn = remote.OnClientEvent:Connect(function(gun, a, b)
					if not GB.on then
						return
					end
					local char = lp.Character
					if not (typeof(gun) == "Instance" and char and gun:IsDescendantOf(char)) then
						return -- only your own shots
					end
					local p0, p1 = toPos(a), toPos(b)
					if p0 and p1 then
						pcall(fireBeam, p0, p1)
					end
				end)

				AS.preload(GB.kind)
				note("Gun Beam", "Gun Beam enabled!")
			end)
		end

		onUnload(gbStop)

		tbl43.visuals:Section({ Title = "Gun Beam" })

		gbToggle = tbl43.visuals:Toggle({
			Title = "Gun Beam",
			Flag = "Toggle_Extra_GunBeam",
			Desc = "Draws a custom beam when you shoot (only you see it). Off = normal shots.",
			Type = "Toggle",
			Value = false,
			Callback = function(v)
				if v then
					gbStart()
				else
					gbStop()
					note("Gun Beam", "Gun Beam disabled.", "power-off")
				end
			end,
		})

		tbl43.visuals:Dropdown({
			Title = "Beam Type",
			Flag = "Dropdown_Extra_BeamType",
			Desc = "Pick how your shot beam looks. Random = a different one every shot. Inferno always uses fire colors. Ring Tunnel, Model Bullet and Custom Model use models from asset IDs.",
			Multi = false,
			Value = "Neon Fat",
			Values = TYPES,
			Callback = function(v)
				GB.kind = v or "Neon Fat"
				AS.preload(GB.kind)
				if GB.kind == "Custom Model" and GB.customId == "" then
					note("Gun Beam", "Paste a model ID in Custom Model ID first.", "x")
				end
			end,
		})

		tbl43.visuals:Colorpicker({
			Title = "Beam Color",
			Flag = "Colorpicker_Extra_BeamColor",
			Default = GB.color,
			Callback = function(c)
				GB.color = c
			end,
		})

		tbl43.visuals:Dropdown({
			Title = "Bullet Facing",
			Flag = "Dropdown_Extra_BeamBulletAxis",
			Desc = "Which side of the Model Bullet / Custom Model points forward. Change it if the model flies sideways or backwards.",
			Multi = false,
			Value = "Front (Z)",
			Values = AS.AXIS_NAMES,
			Callback = function(v)
				GB.bulletAxis = v or "Front (Z)"
			end,
		})

		tbl43.visuals:Dropdown({
			Title = "Ring Facing",
			Flag = "Dropdown_Extra_BeamRingAxis",
			Desc = "Which side of the Ring Tunnel model faces along the shot. Change it if the rings look edge-on.",
			Multi = false,
			Value = "Up (Y)",
			Values = AS.AXIS_NAMES,
			Callback = function(v)
				GB.ringAxis = v or "Up (Y)"
			end,
		})

		tbl43.visuals:Toggle({
			Title = "Tint Models With Beam Color",
			Flag = "Toggle_Extra_BeamTint",
			Desc = "Off = models keep their own colors. On = they use the Beam Color.",
			Type = "Toggle",
			Value = false,
			Callback = function(v)
				GB.tint = v
			end,
		})

		tbl43.visuals:Input({
			Title = "Custom Model ID",
			Flag = "Input_Extra_BeamModelId",
			Desc = "Paste any model asset ID, then pick Beam Type = Custom Model. It flies like the Model Bullet.",
			Placeholder = "e.g. 8448331374",
			Callback = function(value)
				GB.customId = string.match(tostring(value or ""), "%d+") or ""
				if #GB.customId >= 6 and GB.kind == "Custom Model" then
					AS.preload("Custom Model")
				end
			end,
		})

		tbl43.visuals:Input({
			Title = "Custom Texture ID",
			Flag = "Input_Extra_BeamTexId",
			Desc = "Optional image ID for Aurora Ribbon. Empty = the default beam texture.",
			Placeholder = "e.g. 12781800668",
			Callback = function(value)
				GB.customTex = string.match(tostring(value or ""), "%d+") or ""
			end,
		})
		tbl43.visuals:Slider({
			Title = "Beam Width", Flag = "Slider_Extra_BeamWidth", Step = 0.1,
			Value = { Min = 0.5, Max = 3, Default = 1 },
			Callback = function(v)
				GB.width = tonumber(v) or 1
			end,
		})

		tbl43.visuals:Slider({
			Title = "Beam Duration", Flag = "Slider_Extra_BeamLife", Step = 0.1,
			Value = { Min = 0.5, Max = 3, Default = 1 },
			Callback = function(v)
				GB.life = tonumber(v) or 1
			end,
		})

		tbl43.visuals:Toggle({
			Title = "Muzzle Flash",
			Flag = "Toggle_Extra_BeamMuzzle",
			Desc = "Light flash and ring where the shot starts",
			Type = "Toggle",
			Value = true,
			Callback = function(v)
				GB.muzzle = v
			end,
		})

		tbl43.visuals:Toggle({
			Title = "Impact Sparks",
			Flag = "Toggle_Extra_BeamSparks",
			Desc = "Sparks and shockwave rings where the shot lands",
			Type = "Toggle",
			Value = true,
			Callback = function(v)
				GB.sparks = v
			end,
		})

		tbl43.visuals:Button({
			Title = "Test Beam",
			Desc = "Fires the selected beam where you are looking, so you can preview it without shooting",
			Icon = "zap",
			Callback = function()
				task.spawn(function()
					local need = {}
					if GB.kind == "Ring Tunnel" or GB.kind == "Random" then
						need[#need + 1] = AS.RINGS
					end
					if GB.kind == "Model Bullet" or GB.kind == "Random" then
						need[#need + 1] = AS.BULLET
					end
					if GB.kind == "Custom Model" then
						need[#need + 1] = GB.customId
					end
					for _, id in ipairs(need) do
						if id ~= "" then
							AS.load(id)
							local waited = os.clock()
							while AS.loading[id] and os.clock() - waited < 10 do
								task.wait(0.1)
							end
							if not AS.cache[id] then
								note("Gun Beam", "Could not load model " .. id, "x")
							end
						end
					end
					local char = lp.Character
					local root = char and char:FindFirstChild("HumanoidRootPart")
					local cam = workspace.CurrentCamera
					if not (root and cam) then
						return
					end
					local origin = root.Position + Vector3.new(0, 1.5, 0) + root.CFrame.LookVector * 2
					local params = RaycastParams.new()
					params.FilterType = Enum.RaycastFilterType.Exclude
					params.FilterDescendantsInstances = { char }
					local hit = workspace:Raycast(origin, cam.CFrame.LookVector * 120, params)
					local p1 = hit and hit.Position or (origin + cam.CFrame.LookVector * 120)
					pcall(fireBeam, origin, p1)
				end)
			end,
		})
	end

	-- ================================================================ Shader (RTX)
	do
		local RT = { on = false, saved = {}, removed = {}, added = {}, gui = nil }
		local PROPS = {
			"Ambient", "Brightness", "ColorShift_Bottom", "ColorShift_Top", "EnvironmentDiffuseScale",
			"EnvironmentSpecularScale", "GlobalShadows", "OutdoorAmbient", "ShadowSoftness", "ClockTime",
			"GeographicLatitude", "ExposureCompensation",
		}

		local function rtStop()
			if not RT.on then
				return
			end
			RT.on = false

			for _, inst in ipairs(RT.added) do
				pcall(function()
					inst:Destroy()
				end)
			end
			RT.added = {}

			for _, inst in ipairs(RT.removed) do
				pcall(function()
					inst.Parent = Lighting
				end)
			end
			RT.removed = {}

			for name, value in pairs(RT.saved) do
				pcall(function()
					Lighting[name] = value
				end)
			end
			RT.saved = {}

			if RT.gui then
				pcall(function()
					RT.gui:Destroy()
				end)
				RT.gui = nil
			end
		end

		local function rtStart()
			if RT.on then
				return
			end
			RT.on = true

			for _, name in ipairs(PROPS) do
				pcall(function()
					RT.saved[name] = Lighting[name]
				end)
			end

			-- take the existing sky / post effects out of the way (they are put back on disable)
			for _, child in ipairs(Lighting:GetChildren()) do
				if child:IsA("PostEffect") or child:IsA("Sky") or child:IsA("Atmosphere") then
					table.insert(RT.removed, child)
					child.Parent = nil
				end
			end

			local bloom = Instance.new("BloomEffect")
			bloom.Intensity = 0.35
			bloom.Size = 20
			bloom.Threshold = 0.85

			local cc = Instance.new("ColorCorrectionEffect")
			cc.Brightness = 0.05
			cc.Contrast = 0.25
			cc.Saturation = 0.15
			cc.TintColor = Color3.fromRGB(255, 245, 230)

			local rays = Instance.new("SunRaysEffect")
			rays.Intensity = 0.12
			rays.Spread = 0.8

			local sky = Instance.new("Sky")
			sky.SkyboxBk = "http://www.roblox.com/asset/?id=151165214"
			sky.SkyboxDn = "http://www.roblox.com/asset/?id=151165197"
			sky.SkyboxFt = "http://www.roblox.com/asset/?id=151165224"
			sky.SkyboxLf = "http://www.roblox.com/asset/?id=151165191"
			sky.SkyboxRt = "http://www.roblox.com/asset/?id=151165206"
			sky.SkyboxUp = "http://www.roblox.com/asset/?id=151165227"
			sky.SunAngularSize = 11

			local atmo = Instance.new("Atmosphere")
			atmo.Density = 0.3
			atmo.Offset = 0.25
			atmo.Color = Color3.fromRGB(199, 175, 166)
			atmo.Decay = Color3.fromRGB(44, 39, 33)
			atmo.Glare = 0.35
			atmo.Haze = 1.2

			for _, inst in ipairs({ bloom, cc, rays, sky, atmo }) do
				table.insert(RT.added, inst)
				inst.Parent = Lighting
			end

			Lighting.Ambient = Color3.fromRGB(70, 70, 70)
			Lighting.Brightness = 2
			Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
			Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
			Lighting.EnvironmentDiffuseScale = 1
			Lighting.EnvironmentSpecularScale = 1
			Lighting.GlobalShadows = true
			Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100)
			Lighting.ShadowSoftness = 0.15
			Lighting.ClockTime = 14
			Lighting.GeographicLatitude = 45
			Lighting.ExposureCompensation = 0.1

			local gui = Instance.new("ScreenGui")
			gui.Name = "_AirflowVignette"
			gui.IgnoreGuiInset = true
			gui.ResetOnSpawn = false
			gui.Parent = lp:FindFirstChildOfClass("PlayerGui")

			local img = Instance.new("ImageLabel")
			img.AnchorPoint = Vector2.new(0.5, 1)
			img.Position = UDim2.new(0.5, 0, 1, 0)
			img.Size = UDim2.new(1, 0, 1.05, 0)
			img.BackgroundTransparency = 1
			img.Image = "rbxassetid://4576475446"
			img.ImageTransparency = 0.35
			img.ZIndex = 10
			img.Parent = gui

			RT.gui = gui
		end

		onUnload(rtStop)

		tbl43.visuals:Section({ Title = "Shader" })

		tbl43.visuals:Toggle({
			Title = "Shader (RTX)",
			Flag = "Toggle_Extra_RTX",
			Desc = "Bloom, color grading, sun rays, new sky and a soft vignette. Turn off to get the map's own lighting back.",
			Type = "Toggle",
			Value = false,
			Callback = function(v)
				if v then
					rtStart()
					note("Shader", "RTX Enabled")
				else
					rtStop()
					note("Shader", "RTX Disabled")
				end
			end,
		})
	end
end

-- ===================== EXTRA FEATURES 3 (ported from MM2_readable) =====================
-- Blink, Client Ghost, Friend. Each feature sits in its own do-block so its locals are released again.
do
	local Players = game:GetService("Players")
	local RS = game:GetService("RunService")
	local UIS = game:GetService("UserInputService")
	local TweenService = game:GetService("TweenService")
	local lp = Players.LocalPlayer

	local function note(title, content, icon)
		obj2:Notify({ Title = title, Content = content, Duration = 2, Icon = icon or "check" })
	end

	local function onUnload(fn)
		list2.conns[#list2.conns + 1] = { Disconnect = fn }
	end

	-- ================================================================ Blink
	-- Your root part is anchored (so the server stops seeing you move) while you glide locally with
	-- WASD / the touch stick, Space / jump = up, Left Shift = down. Turning it off un-anchors you.
	do
		local BL = { on = false, speed = 32, conn = nil }

		local function blStep(dt)
			local c = lp.Character
			local hrp = c and c:FindFirstChild("HumanoidRootPart")
			local hum = c and c:FindFirstChildOfClass("Humanoid")
			local cam = workspace.CurrentCamera
			if not (hrp and hum and cam) then
				return
			end

			hrp.Anchored = true

			local look = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
			if look.Magnitude > 0 then
				look = look.Unit
			end
			local right = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z)
			if right.Magnitude > 0 then
				right = right.Unit
			end

			local dir = Vector3.zero
			local keyboard = false
			if UIS:IsKeyDown(Enum.KeyCode.W) then
				dir += look
				keyboard = true
			end
			if UIS:IsKeyDown(Enum.KeyCode.S) then
				dir -= look
				keyboard = true
			end
			if UIS:IsKeyDown(Enum.KeyCode.D) then
				dir += right
				keyboard = true
			end
			if UIS:IsKeyDown(Enum.KeyCode.A) then
				dir -= right
				keyboard = true
			end
			if not keyboard then
				dir = hum.MoveDirection -- touch stick / gamepad
			end

			if UIS:IsKeyDown(Enum.KeyCode.Space) or hum.Jump then
				dir += Vector3.yAxis
			end
			if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
				dir -= Vector3.yAxis
			end

			if dir.Magnitude > 0 then
				dir = dir.Unit
			end

			hrp.CFrame = hrp.CFrame + dir * BL.speed * dt
		end

		local function blStop()
			BL.on = false
			if BL.conn then
				BL.conn:Disconnect()
				BL.conn = nil
			end

			local c = lp.Character
			local hrp = c and c:FindFirstChild("HumanoidRootPart")
			if hrp then
				pcall(function()
					hrp.Anchored = false
					hrp.AssemblyLinearVelocity = Vector3.zero
				end)
			end
		end

		local function blStart()
			blStop()
			BL.on = true
			BL.conn = RS.Heartbeat:Connect(blStep)
		end

		onUnload(blStop)

		tbl43.player:Section({ Title = "Blink" })

		tbl43.player:Toggle({
			Title = "Blink",
			Flag = "Toggle_Extra_Blink",
			Desc = "Freezes you in place for everyone else while you move locally. Turn off to snap to where you ended up.",
			Type = "Toggle",
			Value = false,
			Callback = function(v)
				if v then
					blStart()
					note("Blink", "Enabled.")
				else
					blStop()
					note("Blink", "Disabled.", "power-off")
				end
			end,
		})

		tbl43.player:Slider({
			Title = "Blink Speed",
			Flag = "Slider_Extra_BlinkSpeed",
			Step = 1,
			Value = { Min = 8, Max = 150, Default = 32 },
			Callback = function(v)
				BL.speed = tonumber(v) or 32
			end,
		})
	end

	-- ================================================================ Client Ghost
	-- A normal-looking copy of your avatar that shows where the server sees you (your position delayed by
	-- your ping). Unlike Backtrack it keeps your real look instead of a coloured force-field.
	do
		local CG = { on = false, model = nil, pairs = {}, char = nil, hist = {}, ping = 0.12, pingAt = 0, conn = nil, conn2 = nil }

		local function pingSec()
			local ok, v = pcall(function()
				return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
			end)
			if ok and type(v) == "number" then
				return v / 1000
			end
			return 0.12
		end

		local function cgDestroy()
			if CG.model then
				pcall(function()
					CG.model:Destroy()
				end)
			end
			CG.model, CG.pairs, CG.char, CG.hist = nil, {}, nil, {}
		end

		local function cgBuild(char)
			cgDestroy()

			char.Archivable = true
			local ok, m = pcall(function()
				return char:Clone()
			end)
			if not ok or not m then
				return
			end

			local real = {}
			for _, d in ipairs(char:GetDescendants()) do
				if d:IsA("BasePart") then
					real[#real + 1] = d
				end
			end

			local i = 0
			for _, d in ipairs(m:GetDescendants()) do
				if d:IsA("BaseScript") or d:IsA("Sound") or d:IsA("BillboardGui") then
					pcall(function()
						d:Destroy()
					end)
				elseif d:IsA("BasePart") then
					i += 1
					d.Anchored = true
					d.CanCollide = false
					d.CanQuery = false
					d.CanTouch = false
					d.Massless = true
					d.CastShadow = false
					CG.pairs[#CG.pairs + 1] = { d, real[i] }
				end
			end

			-- keep the humanoid (clothes need it to render) but silence name / health bars
			local hum = m:FindFirstChildOfClass("Humanoid")
			if hum then
				pcall(function()
					hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
					hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
					-- a live humanoid keeps switching CanCollide back on for its body parts; that made your
					-- real character stand on the ghost and get pushed up, so stop it from running
					hum.EvaluateStateMachine = false
					hum.PlatformStand = true
				end)
			end

			m.Name = "ClientGhost"
			m.Parent = workspace
			CG.model, CG.char = m, char
		end

		local function cgStep()
			if not CG.on then
				return
			end

			local char = lp.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if not hrp then
				return
			end

			if not CG.model or CG.char ~= char or not CG.model.Parent then
				cgBuild(char)
				if not CG.model then
					return
				end
			end

			local now = os.clock()
			if now - CG.pingAt > 0.25 then
				CG.pingAt = now
				CG.ping = math.clamp(pingSec(), 0.05, 0.6)
			end

			local hist = CG.hist
			hist[#hist + 1] = { now, hrp.CFrame }
			while #hist > 2 and hist[1][1] < now - 1.5 do
				table.remove(hist, 1)
			end

			local target = now - CG.ping
			local dcf = hist[1][2]
			for i = #hist, 1, -1 do
				if hist[i][1] <= target then
					dcf = hist[i][2]
					break
				end
			end

			local inv = hrp.CFrame
			for _, pr in ipairs(CG.pairs) do
				local part, rp = pr[1], pr[2]
				if part.Parent and rp and rp.Parent then
					part.CFrame = dcf * inv:ToObjectSpace(rp.CFrame)
				end
			end
		end

		local function cgStop()
			CG.on = false
			if CG.conn then
				CG.conn:Disconnect()
				CG.conn = nil
			end
			if CG.conn2 then
				CG.conn2:Disconnect()
				CG.conn2 = nil
			end
			cgDestroy()
		end

		local function cgStart()
			cgStop()
			CG.on = true
			CG.conn = RS.Heartbeat:Connect(function()
				pcall(cgStep)
			end)

			-- belt and braces: keep every ghost part non-solid before each physics step
			CG.conn2 = RS.Stepped:Connect(function()
				for _, pr in ipairs(CG.pairs) do
					local part = pr[1]
					if part.Parent then
						part.CanCollide = false
						part.CanQuery = false
						part.CanTouch = false
					end
				end
			end)
		end

		onUnload(cgStop)

		tbl43.visuals:Section({ Title = "Client Ghost" })

		tbl43.visuals:Toggle({
			Title = "Client Ghost",
			Flag = "Toggle_Extra_ClientGhost",
			Desc = "A copy of your avatar (real look) showing where the server sees you, delayed by your ping.",
			Type = "Toggle",
			Value = false,
			Callback = function(v)
				if v then
					cgStart()
					note("Client Ghost", "Enabled.")
				else
					cgStop()
					note("Client Ghost", "Disabled.", "power-off")
				end
			end,
		})
	end

	-- ================================================================ Friend
	-- A little companion that follows you around and answers when you click / tap it.
	do
		local BODY_ID = 10740710463
		local ACCESSORY_IDS = { 17106982150, 7175904988, 14474050865 }
		local SHIRT_ID, PANTS_ID, FACE_ID = 14877850833, 14119146662, "rbxassetid://11654084813"
		local FOLLOW_DIST = 6
		local PHRASES = { "Yeah?", "Hmm?", "Hey", "I'm listening", "Yo" }

		local FR = { on = false, token = 0, model = nil, conn = nil, idle = nil, walk = nil, busy = false }
		local frToggle

		local function load(id)
			local ok, objs = pcall(function()
				return game:GetObjects("rbxassetid://" .. tostring(id))
			end)
			if ok and type(objs) == "table" and objs[1] then
				return objs[1]
			end
			return nil
		end

		-- a Shirt / Pants asset loads as the Shirt / Pants itself (not inside a container),
		-- so check the object first and only then look inside it
		local function clothingFrom(obj, class)
			if not obj then
				return nil
			end
			if obj:IsA(class) then
				return obj
			end
			return obj:FindFirstChildWhichIsA(class, true)
		end

		local function loadClothing(id, class)
			local item = clothingFrom(load(id), class)
			if item then
				return item
			end
			-- fallback loader
			local ok, wrapper = pcall(function()
				return game:GetService("InsertService"):LoadAsset(id)
			end)
			return ok and clothingFrom(wrapper, class) or nil
		end

		local function pop()
			pcall(function()
				local s = Instance.new("Sound")
				s.SoundId = "rbxassetid://5855422149"
				s.Volume = 1
				s.PlayOnRemove = true
				s.Parent = game:GetService("SoundService")
				s:Destroy()
			end)
		end

		local function frStop()
			FR.on = false
			FR.token += 1
			FR.busy = false

			if FR.conn then
				FR.conn:Disconnect()
				FR.conn = nil
			end

			for _, t in ipairs({ FR.idle, FR.walk }) do
				if t then
					pcall(function()
						t:Stop()
					end)
				end
			end
			FR.idle, FR.walk = nil, nil

			if FR.model then
				pop()
				pcall(function()
					FR.model:Destroy()
				end)
				FR.model = nil
			end
		end

		local function frFail(text)
			note("Friend", text, "x")
			task.defer(function()
				pcall(list2.setToggle, frToggle, false)
			end)
		end

		local function frStart()
			frStop()
			FR.on = true
			local my = FR.token

			task.spawn(function()
				local char = lp.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				if not hrp then
					frFail("No character yet.")
					return
				end

				local model = load(BODY_ID)
				if not model then
					frFail("Couldn't load your friend.")
					return
				end
				if FR.token ~= my then
					model:Destroy()
					return
				end

				model.Parent = workspace
				model:PivotTo(hrp.CFrame * CFrame.new(5, 0, -5))

				-- plain skin tone, specific outfit and face
				local bc = model:FindFirstChildWhichIsA("BodyColors")
				if bc then
					bc:Destroy()
				end
				local skin = Color3.fromRGB(255, 224, 189)
				for _, d in ipairs(model:GetDescendants()) do
					if d:IsA("BasePart") and not d:FindFirstAncestorOfClass("Accessory") then
						d.Color = skin
					end
				end

				for _, c in ipairs(model:GetChildren()) do
					if c:IsA("Shirt") or c:IsA("Pants") or c:IsA("ShirtGraphic") or c:IsA("Clothing") then
						c:Destroy()
					end
				end
				pcall(function()
					local item = loadClothing(SHIRT_ID, "Shirt")
					if item then
						item.Parent = model
					else
						warn("[Friend] shirt failed to load")
					end
				end)
				pcall(function()
					local item = loadClothing(PANTS_ID, "Pants")
					if item then
						item.Parent = model
					else
						warn("[Friend] pants failed to load")
					end
				end)

				local head = model:FindFirstChild("Head")
				if head then
					local face = head:FindFirstChild("face") or head:FindFirstChildWhichIsA("Decal")
					if not face then
						face = Instance.new("Decal")
						face.Parent = head
					end
					face.Name = "face"
					face.Texture = FACE_ID
				end

				-- one random accessory welded to the head
				pcall(function()
					local acc = load(ACCESSORY_IDS[math.random(1, #ACCESSORY_IDS)])
					if acc and head then
						acc.Parent = model
						local handle = acc:IsA("BasePart") and acc or acc:FindFirstChild("Handle") or acc:FindFirstChildWhichIsA("BasePart", true)
						if handle then
							handle.Anchored = false
							handle.CFrame = head.CFrame * CFrame.new(0, -0.6, 0)
							local w = Instance.new("WeldConstraint")
							w.Part0 = head
							w.Part1 = handle
							w.Parent = handle
						end
					end
				end)

				local hum = model:FindFirstChildWhichIsA("Humanoid")
				local root = model:FindFirstChild("HumanoidRootPart")
				if not hum or not root then
					model:Destroy()
					frFail("Friend model is missing a humanoid.")
					return
				end

				pop()
				FR.model = model

				-- idle / walk animations (rig dependent)
				local animator = hum:FindFirstChildOfClass("Animator")
				if not animator then
					animator = Instance.new("Animator")
					animator.Parent = hum
				end

				local isR6 = hum.RigType == Enum.HumanoidRigType.R6
				local function track(id)
					local anim = Instance.new("Animation")
					anim.AnimationId = id
					local ok, t = pcall(function()
						return animator:LoadAnimation(anim)
					end)
					return ok and t or nil
				end

				-- standard Roblox animations: R6 idle 180435571 / walk 180426354, R15 idle 507766388 / walk 507777826
				FR.idle = track(isR6 and "rbxassetid://180435571" or "rbxassetid://507766388")
				FR.walk = track(isR6 and "rbxassetid://180426354" or "rbxassetid://507777826")
				if FR.idle then
					FR.idle.Priority = Enum.AnimationPriority.Idle
					FR.idle.Looped = true
					FR.idle:Play()
				end
				if FR.walk then
					FR.walk.Priority = Enum.AnimationPriority.Movement
					FR.walk.Looped = true
				end

				-- speech bubble + click / tap to talk
				local gui = Instance.new("BillboardGui")
				gui.Size = UDim2.new(0, 200, 0, 50)
				gui.StudsOffset = Vector3.new(0, 2.5, 0)
				gui.AlwaysOnTop = true
				gui.Adornee = head or root
				gui.Parent = head or root

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(1, 0, 1, 0)
				label.BackgroundTransparency = 1
				label.TextColor3 = Color3.fromRGB(255, 192, 203)
				label.TextStrokeTransparency = 0
				label.Font = Enum.Font.GothamSemibold
				label.TextScaled = true
				label.Text = ""
				label.Parent = gui

				local click = Instance.new("ClickDetector")
				click.MaxActivationDistance = 32
				click.Parent = model

				click.MouseClick:Connect(function()
					if FR.busy or FR.token ~= my then
						return
					end
					FR.busy = true

					local text = PHRASES[math.random(1, #PHRASES)]
					label.TextTransparency = 0
					label.TextStrokeTransparency = 0
					for i = 1, #text do
						if FR.token ~= my then
							return
						end
						label.Text = text:sub(1, i)
						task.wait(0.03)
					end
					task.wait(1.2)

					if FR.token ~= my then
						return
					end
					TweenService:Create(label, TweenInfo.new(0.5), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
					task.wait(0.5)

					if FR.token ~= my then
						return
					end
					label.Text = ""
					label.TextTransparency = 0
					label.TextStrokeTransparency = 0
					FR.busy = false
				end)

				-- follow loop
				local lastMove = 0
				FR.conn = RS.Heartbeat:Connect(function()
					local c = lp.Character
					local myRoot = c and c:FindFirstChild("HumanoidRootPart")
					if not (myRoot and FR.model and FR.model.Parent and root.Parent) then
						return
					end

					local pos = myRoot.Position
					local dist = (root.Position - pos).Magnitude

					if dist > 200 or pos.Y < -100 then
						FR.model:PivotTo(myRoot.CFrame * CFrame.new(5, 0, -5))
					elseif dist > FOLLOW_DIST then
						if os.clock() - lastMove > 0.1 then
							lastMove = os.clock()
							hum:MoveTo(pos)
						end
						if FR.walk and not FR.walk.IsPlaying then
							if FR.idle then
								FR.idle:Stop()
							end
							FR.walk:Play()
							FR.walk.Looped = true
						end
					else
						hum:MoveTo(root.Position)
						if FR.idle and not FR.idle.IsPlaying then
							if FR.walk then
								FR.walk:Stop()
							end
							FR.idle:Play()
							FR.idle.Looped = true
						end
					end
				end)

				note("Friend", "Enabled.")
			end)
		end

		onUnload(frStop)

		tbl43.troll:Section({ Title = "Friend" })

		frToggle = tbl43.troll:Toggle({
			Title = "Friend",
			Flag = "Toggle_Extra_Friend",
			Desc = "Spawns a companion that follows you. Click or tap it to talk to it.",
			Type = "Toggle",
			Value = false,
			Callback = function(v)
				if v then
					frStart()
				else
					frStop()
					note("Friend", "Disabled.", "power-off")
				end
			end,
		})
	end
end

tbl43.keybinds = obj3:Tab({
	Title = "Keybinds",
	Icon = "lucide:keyboard",
	IconColor = ICON.tile,
	IconShape = "Square",
	Border = true,
})

tbl43.settings = obj3:Tab({
	Title = "Settings & Configs",
	Icon = "solar:settings-bold",
	IconColor = ICON.tile,
	IconShape = "Square",
	Border = true,
})

tbl43.settings:SubTabs({
	{ "General", { "Interface", "Protection" } },
	{ "Server & Config", { "Server", "Config", "Meow" } },
})


do
	local tbl44 = {
		Combat = ICON.tile,
		Crosshair = ICON.tile,
		["Skin Changer"] = ICON.tile,
		Buttons = ICON.tile,
		ESP = ICON.tile,
		["Fling & Teleport"] = ICON.tile,
		Autofarm = ICON.tile,
		Player = ICON.tile,
		Visuals = ICON.tile,
		Keybinds = ICON.tile,
		["Settings & Configs"] = ICON.tile,
	}

	local color2 = Color3.new(1, 1, 1)
	local tbl45 = {}

	local function func117(param82, num27)
		return math.abs(param82.R - num27.R) < 0.02 and math.abs(param82.G - num27.G) < 0.02 and math.abs(param82.B - num27.B) < 0.02
	end

	task.spawn(function()
		for i = 1, 60 do
			local n4 = 0

			pcall(function()
				for _, descendant in ipairs(obj3.UIElements.Main:GetDescendants()) do
					local parent = descendant:IsA("TextLabel") and tbl44[descendant.Text] and descendant.Parent and descendant.Parent.Parent or nil

					if parent and parent:IsA("ImageButton") then
						local descendants = parent:GetDescendants()
						local value136 = nil

						for _, descendant2 in ipairs(descendants) do
							if descendant2:IsA("ImageLabel") and func117(descendant2.ImageColor3, tbl44[descendant.Text]) then
								value136 = descendant2
								break
							else
								value136 = nil
							end
						end

						if value136 then
							if not value136:FindFirstChildWhichIsA("UIGradient") then
								local uiGradient = Instance.new("UIGradient")
								uiGradient.Rotation = 90
								local new = ColorSequenceKeypoint.new
								local color3 = Color3.fromRGB
								uiGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)), new(1, color3(115, 115, 125)) })
								uiGradient.Parent = value136
								n4 += 1
							end

							for _, descendant2 in ipairs(descendants) do
								if descendant2 ~= value136 and descendant2:IsA("ImageLabel") and descendant2.Name == "ImageLabel" and not tbl45[descendant2] then
									tbl45[descendant2] = true
									descendant2.ImageColor3 = color2

									descendant2:GetPropertyChangedSignal("ImageColor3"):Connect(function()
										if descendant2.ImageColor3 ~= color2 then
											descendant2.ImageColor3 = color2
										end
									end)

									n4 += 1
								end
							end
						end
					end
				end
			end)

			if n4 > 0 then
				return
			end
			RunService.RenderStepped:Wait()
		end
	end)
end

local func118

func118 = function(param83, imageColor3, imageTransparency, textColor3)
	imageTransparency = imageTransparency or 0.55

	for _, descendant in ipairs(obj3.UIElements.Main:GetDescendants()) do
		if descendant:IsA("TextLabel") and descendant.Text == param83 then
			local imageButton = descendant:FindFirstAncestorWhichIsA("ImageButton")

			if imageButton then
				imageButton.ImageColor3 = imageColor3
				imageButton.ImageTransparency = imageTransparency

				imageButton:GetPropertyChangedSignal("ImageColor3"):Connect(function()
					if imageButton.ImageColor3 ~= imageColor3 then
						imageButton.ImageColor3 = imageColor3
					end
				end)

				imageButton:GetPropertyChangedSignal("ImageTransparency"):Connect(function()
					if imageButton.ImageTransparency > imageTransparency then
						imageButton.ImageTransparency = imageTransparency
					end
				end)

				if textColor3 then
					for _, descendant2 in ipairs(imageButton:GetDescendants()) do
						if descendant2:IsA("TextLabel") then
							descendant2.TextColor3 = textColor3

							descendant2:GetPropertyChangedSignal("TextColor3"):Connect(function()
								if descendant2.TextColor3 ~= textColor3 then
									descendant2.TextColor3 = textColor3
								end
							end)
						elseif descendant2:IsA("ImageLabel") and descendant2.Size ~= UDim2.new(1, 0, 1, 0) then
							descendant2.ImageColor3 = textColor3

							descendant2:GetPropertyChangedSignal("ImageColor3"):Connect(function()
								if descendant2.ImageColor3 ~= textColor3 then
									descendant2.ImageColor3 = textColor3
								end
							end)
						end
					end
				end
			end

			return
		end
	end
end

local func119

func119 = function(param84)
	local ok, result = pcall(function()
		return param84.ParagraphFrame.UIElements.Container
	end)

	if ok and typeof(result) == "Instance" then
		return result
	end
	return nil
end

local func120
local tbl46 = {}

func120 = function(imageColor3)
	for _, descendant in ipairs(obj3.UIElements.Main:GetDescendants()) do
		if not tbl46[descendant] and descendant.Name == "ToggleFrame" then
			local layer = descendant:FindFirstChild("Layer")

			if layer then
				tbl46[descendant] = true
				layer.ImageColor3 = imageColor3

				if not layer:FindFirstChildWhichIsA("UIGradient") then
					local uiGradient = Instance.new("UIGradient")
					uiGradient.Rotation = 115

					uiGradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 120, 130)),
					})

					uiGradient.Parent = layer
				end

				local frame = descendant:FindFirstChild("Frame")
				frame = frame and frame:FindFirstChild("Bar")
				frame = frame and frame:FindFirstChild("Highlight")
				local glass = frame and frame:FindFirstChild("Glass")

				if glass then
					glass.ImageColor3 = imageColor3

					glass:GetPropertyChangedSignal("ImageColor3"):Connect(function()
						if glass.ImageColor3 ~= imageColor3 then
							glass.ImageColor3 = imageColor3
						end
					end)
				end
			end
		end
	end
end

tbl43.esp:Section({ Title = "ESP" })

tbl43.esp:Toggle({
	Title = "ESP Outline",
	Flag = "Toggle_ESP_Outline",
	Desc = "Glowing outline on every player through walls.",
	Type = "Toggle",
	Value = false,
	Callback = function(value)
		flag18 = value

		if func17() then
			func18()
			func21()
		else
			obj4:RemoveGroup("players")
			func22()
		end
	end,
})

tbl43.esp:Toggle({
	Title = "Full Body ESP",
	Flag = "Toggle_Full_Body_ESP",
	Desc = "Fills the whole body in the role colour.",
	Type = "Toggle",
	Value = false,
	Callback = function(value)
		flag19 = value

		if func17() then
			func18()
			func21()
		else
			obj4:RemoveGroup("players")
			func22()
		end
	end,
})

tbl43.esp:Toggle({
	Title = "Display Name ESP",
	Flag = "Toggle_Display_Name_ESP",
	Desc = "Their display name above their head, in the role colour.",
	Type = "Toggle",
	Value = false,
	Callback = function(value)
		flag20 = value

		if func17() then
			func18()
			func21()
		else
			obj4:RemoveGroup("players")
			func22()
		end
	end,
})

tbl43.esp:Toggle({
	Title = "Dropped Gun ESP",
	Flag = "Toggle_Dropped_Gun_ESP",
	Desc = "Shows the gun on the floor after the sheriff dies.",
	Type = "Toggle",
	Value = false,
	Callback = function(value)
		flag21 = value
		func19()
	end,
})

tbl43.esp:Toggle({
	Title = "Trap ESP",
	Flag = "Toggle_Trap_ESP",
	Desc = "Shows traps other players hid around the map.",
	Type = "Toggle",
	Value = false,
	Callback = function(value)
		flag22 = value
		func20()
	end,
})

tbl43.esp:Toggle({
	Title = "Tracers",
	Flag = "Toggle_ESP_Tracers",
	Desc = "Draws a line from the bottom of your screen to every player, in their role colour.",
	Type = "Toggle",
	Value = false,
	Callback = function(lines)
		list2.tr.lines = lines
		list2.tr.sync()
	end,
})

tbl43.esp:Toggle({
	Title = "Distance",
	Flag = "Toggle_ESP_Distance",
	Desc = "How many studs away each player is, written under their feet.",
	Type = "Toggle",
	Value = false,
	Callback = function(dist)
		list2.tr.dist = dist
		list2.tr.sync()
	end,
})

tbl43.esp:Toggle({
	Title = "Off-Screen Arrows",
	Flag = "Toggle_ESP_Arrows",
	Desc = "Arrows around your crosshair pointing at the players you cannot see - including the ones behind you.",
	Type = "Toggle",
	Value = false,
	Callback = function(arrows)
		list2.tr.arrows = arrows
		list2.tr.sync()
	end,
})

if list2.buildExtraEsp then
	list2.buildExtraEsp()
end

tbl43.esp:Section({ Title = "ESP Colours" })

tbl43.esp:Colorpicker({
	Title = "Innocent",
	Flag = "Colorpicker_Innocent",
	Desc = "Outline colour for everyone else",
	Default = espColors.innocent,
	Callback = function(innocent)
		espColors.innocent = innocent
		local value137 = flag18
		local value138

		if flag18 then
			value138 = value137
		else
			value138 = flag19
		end

		if value138 then
			func18()
		end
	end,
})

tbl43.esp:Colorpicker({
	Title = "Sheriff",
	Flag = "Colorpicker_Sheriff",
	Desc = "Outline colour for the sheriff",
	Default = espColors.sheriff,
	Callback = function(sheriff)
		espColors.sheriff = sheriff
		local value139 = flag18
		local value140

		if flag18 then
			value140 = value139
		else
			value140 = flag19
		end

		if value140 then
			func18()
		end
	end,
})

tbl43.esp:Colorpicker({
	Title = "Murderer",
	Flag = "Colorpicker_Murderer",
	Desc = "Outline colour for the murderer",
	Default = espColors.murderer,
	Callback = function(murderer)
		espColors.murderer = murderer
		local value141 = flag18
		local value142

		if flag18 then
			value142 = value141
		else
			value142 = flag19
		end

		if value142 then
			func18()
		end
	end,
})

tbl43.esp:Colorpicker({
	Title = "Zombie",
	Flag = "Colorpicker_Zombie",
	Desc = "Outline colour for zombies (new mode)",
	Default = espColors.zombie,
	Callback = function(col)
		espColors.zombie = col

		if flag18 or flag19 then
			func18()
		end
	end,
})

tbl43.esp:Colorpicker({
	Title = "Survivor",
	Flag = "Colorpicker_Survivor",
	Desc = "Outline colour for survivors (new mode)",
	Default = espColors.survivor,
	Callback = function(col)
		espColors.survivor = col

		if flag18 or flag19 then
			func18()
		end
	end,
})

tbl43.esp:Colorpicker({
	Title = "Dropped Gun",
	Flag = "Colorpicker_Dropped_Gun_Blue",
	Desc = "Highlight colour for the dropped gun",
	Default = espColors.gun,
	Callback = function(gun)
		espColors.gun = gun
		func19()
	end,
})

tbl43.esp:Colorpicker({
	Title = "Traps",
	Flag = "Colorpicker_Traps",
	Desc = "Highlight colour for traps",
	Default = espColors.trap,
	Callback = function(trap)
		espColors.trap = trap
		func20()
	end,
})

func120(ICON.mono)
tbl43.fling:Section({ Title = "Quick Actions" })

list2.el.flingMurd = tbl43.fling:Button({
	Title = "Fling Murderer",
	Desc = "Yeet whoever has the knife",
	Icon = "lucide:flame",
	Callback = function()
		local result16 = func15()
		if not result16 then
			obj2:Notify({ Title = "Error!", Content = "No murderer this round!", Duration = 1.5, Icon = "x" })
			return
		end

		if result16 == localPlayer then
			obj2:Notify({ Title = "Error!", Content = "You can't fling yourself!", Duration = 1.5, Icon = "x" })
			return
		end
		func27(result16)
	end,
})

list2.el.flingSher = tbl43.fling:Button({
	Title = "Fling Sheriff",
	Desc = "Yeet whoever has the gun",
	Icon = "lucide:flame",
	Callback = function()
		local result17 = func16()
		if not result17 then
			obj2:Notify({ Title = "Error!", Content = "No sheriff this round!", Duration = 1.5, Icon = "x" })
			return
		end

		if result17 == localPlayer then
			obj2:Notify({ Title = "Error!", Content = "You can't fling yourself!", Duration = 1.5, Icon = "x" })
			return
		end
		func27(result17)
	end,
})

tbl43.fling:Button({
	Title = "Fling All",
	Desc = "Yeet everyone in the server, one after another. Press again to stop",
	Icon = "lucide:flame",
	Callback = function()
		list2.flingAll()
	end,
})

func118("Fling Murderer", Color3.fromHex("#FCA5A5"))
func118("Fling Sheriff", Color3.fromHex("#93C5FD"))
func118("Fling All", Color3.fromHex("#FDBA74"))

-- ===== Auto Fling Sheriff / Auto Fling Murderer =====
-- While a toggle is on, whoever holds the gun (sheriff) / the knife (murderer) is flung automatically as soon as
-- a round is running. It uses the same fling as the buttons above (Fling Mode / Smart Fling apply), skips
-- yourself and dead players, and does not re-fling the same player more than once every few seconds.
do
	local autoFling = { sheriff = false, murderer = false }
	local lastFlung = {}
	local RETRY_AFTER = 3 -- seconds before the same player can be auto-flung again
	local nextTurn = "murderer"
	local startDelay = 0 -- optional extra seconds to wait after a round starts before the first auto fling (slider below)
	local roundStartedAt = nil -- tick() when the current round was first seen running
	local sitOutNotified = false -- "you joined mid-round" notice already shown for this round

	-- players seen dead this round: once a player is in here he is never auto-flung again until the round ends
	local deadThisRound = {}

	-- dead-player test comes from the shared role API (Dead / Killed flags or zero-health Humanoid)
	local function flaggedDead(player)
		return list2.isPlayerDead(player)
	end

	local function alive(player)
		if not player then
			return false
		end

		if deadThisRound[player] then
			return false
		end

		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")

		-- positive proof of death: remember it for the rest of the round
		if (hum and hum.Health <= 0) or flaggedDead(player) then
			deadThisRound[player] = true
			return false
		end

		return hum ~= nil and char:FindFirstChild("HumanoidRootPart") ~= nil
	end

	-- are you the murderer right now? (then Auto Fling Sheriff must stay out of the way)
	local function iAmMurderer()
		return list2.isMurderer(localPlayer) or func15() == localPlayer
	end

	-- a round is running when the game's inventory GUI is up OR a map model (CoinContainer / CoinAreas / Spawns)
	-- exists in workspace. Two independent checks, so a game update that breaks one of them does not stop the toggle.
	local function roundRunning()
		local okLobby, inLobby = pcall(list2.inLobbyNow)

		if okLobby and not inLobby then
			return true
		end

		for _, child in ipairs(workspace:GetChildren()) do
			if child:IsA("Model") and child.Name ~= "RegularLobby" and child.Name ~= "Lobby"
				and (child:FindFirstChild("CoinContainer") or child:FindFirstChild("CoinAreas") or child:FindFirstChild("Spawns")) then
				return true
			end
		end

		return false
	end

	-- ===== "am I actually playing this round?" check =====
	-- roundRunning() also turns true when only a map model exists in workspace, which is also the case when you join
	-- a server whose round already started (you are just spectating, you were never dealt a role).
	-- You count as a participant when ANY of these is true:
	--   1) the game's Inventory GUI is up (the game only builds it for players in the round)
	--   2) the live role data (PlayerDataChanged) has a record for you
	--   3) the round roster module has a record for you
	-- A player who joined mid-round has none of the three, so Auto Fling waits for the next round.
	local function inMyRound()
		local okLobby, inLobby = pcall(list2.inLobbyNow)

		if okLobby and not inLobby then
			return true
		end

		local data = list2.liveData

		if type(data) == "table" and type(data[localPlayer.Name]) == "table" then
			return true
		end

		local okRec, rec = pcall(list2.myRoundRec)

		return okRec and rec ~= nil and rec ~= false
	end

	-- ===== "flung out of the map" check =====
	-- Principle: take the bounding box of the round's map model and see where the target's HumanoidRootPart is
	-- relative to it. Outside the box (+ a margin) = he was launched off the map, so flinging him again is pointless.
	-- The box is cached per map (GetBoundingBox walks the whole model, so it is not done every tick).
	local OUT_MARGIN = 60 -- studs of slack around the map box before someone counts as "out"
	local mapCache = { model = nil, cf = nil, size = nil, t = 0 }

	local function currentMap()
		for _, child in ipairs(workspace:GetChildren()) do
			if child:IsA("Model") and child.Name ~= "RegularLobby" and child.Name ~= "Lobby"
				and (child:FindFirstChild("CoinContainer") or child:FindFirstChild("CoinAreas") or child:FindFirstChild("Spawns")) then
				return child
			end
		end

		return nil
	end

	local function mapBox()
		local map = currentMap()

		if not map then
			mapCache.model = nil
			return nil
		end

		-- rebuild when the map changed, or every 30 s in case parts were still loading the first time
		if mapCache.model ~= map or tick() - mapCache.t > 30 then
			local ok, cf, size = pcall(function()
				return map:GetBoundingBox()
			end)

			if ok and cf and size then
				mapCache.model, mapCache.cf, mapCache.size, mapCache.t = map, cf, size, tick()
			else
				return nil
			end
		end

		return mapCache.cf, mapCache.size
	end

	local function outOfMap(player)
		local char = player and player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")

		if not root then
			return false
		end

		local pos = root.Position

		-- about to hit (or already under) the void: gone for good, whatever the map box says
		if pos.Y < workspace.FallenPartsDestroyHeight + 50 then
			return true
		end

		local cf, size = mapBox()

		if not cf then
			-- no map box available: only absurd positions count as "out"
			return pos.Y > 3000 or pos.Magnitude > 5000
		end

		local rel = cf:PointToObjectSpace(pos)
		local half = size / 2

		return math.abs(rel.X) > half.X + OUT_MARGIN
			or math.abs(rel.Y) > half.Y + OUT_MARGIN
			or math.abs(rel.Z) > half.Z + OUT_MARGIN
	end

	local lastWarn = {}

	-- tells you (at most every 15 s per role) why nothing is happening
	local function warn(role, text)
		if lastWarn[role] and tick() - lastWarn[role] < 15 then
			return
		end

		lastWarn[role] = tick()
		obj2:Notify({ Title = "Auto Fling", Content = text, Duration = 2.5, Icon = "x" })
	end

	local function tryFling(role, finder)
		-- you are the murderer: never auto-fling the sheriff
		if role == "sheriff" and iAmMurderer() then
			return false
		end

		local ok, target = pcall(finder)

		if not ok or not target then
			warn(role, "No " .. role .. " found yet (the role data has not arrived).")
			return false
		end

		if target == localPlayer or not alive(target) then
			return false
		end

		-- already launched off the map: no point flinging again
		if outOfMap(target) then
			warn(role, target.Name .. " (" .. role .. ") is already out of the map - skipping.")
			return false
		end

		if lastFlung[target] and tick() - lastFlung[target] < RETRY_AFTER then
			return false
		end

		lastFlung[target] = tick()
		obj2:Notify({ Title = "Auto Fling", Content = "Flinging " .. role .. ": " .. target.Name, Duration = 1.5, Icon = "flame" })
		pcall(func27, target)

		return true
	end

	task.spawn(function()
		while true do
			task.wait(0.25)

			if not (autoFling.sheriff or autoFling.murderer) then
				roundStartedAt = nil
				sitOutNotified = false

				if next(deadThisRound) then
					table.clear(deadThisRound)
				end
			elseif not roundRunning() then
				-- round over / lobby: forget who was dead and restart the delay for the next round
				table.clear(deadThisRound)
				roundStartedAt = nil
				sitOutNotified = false
			elseif not inMyRound() then
				-- a round is running but you are not in it (you joined mid-round): do nothing until the next round
				roundStartedAt = nil

				if not sitOutNotified then
					sitOutNotified = true
					obj2:Notify({ Title = "Auto Fling", Content = "Round already started without you - Auto Fling begins next round.", Duration = 3, Icon = "x" })
				end
			elseif not roundStartedAt then
				-- round just started: begin the countdown instead of flinging right away
				roundStartedAt = tick()
			elseif tick() - roundStartedAt < startDelay then
				-- still inside the start delay: do nothing yet
			elseif not flag33 and alive(localPlayer) then
				-- when both toggles are on, take turns so one role never starves the other
				local first, second = "murderer", "sheriff"

				if nextTurn == "sheriff" then
					first, second = "sheriff", "murderer"
				end

				local done = false

				for _, role in ipairs({ first, second }) do
					if not done and autoFling[role] then
						done = tryFling(role, role == "murderer" and func15 or func16)

						if done then
							nextTurn = role == "murderer" and "sheriff" or "murderer"
						end
					end
				end
			end
		end
	end)

	tbl43.fling:Toggle({
		Title = "Auto Fling Sheriff",
		Flag = "Toggle_Auto_Fling_Sheriff",
		Desc = "Automatically flings whoever has the gun, every round, until you turn it off.",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			autoFling.sheriff = value and true or false
			lastFlung = {}
			obj2:Notify({ Title = "Auto Fling Sheriff", Content = autoFling.sheriff and "ON" or "OFF", Duration = 1.5, Icon = "flame" })
		end,
	})

	tbl43.fling:Toggle({
		Title = "Auto Fling Murderer",
		Flag = "Toggle_Auto_Fling_Murderer",
		Desc = "Automatically flings whoever has the knife, every round, until you turn it off.",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			autoFling.murderer = value and true or false
			lastFlung = {}
			obj2:Notify({ Title = "Auto Fling Murderer", Content = autoFling.murderer and "ON" or "OFF", Duration = 1.5, Icon = "flame" })
		end,
	})

	tbl43.fling:Slider({
		Title = "Auto Fling Start Delay",
		Flag = "Slider_Auto_Fling_Delay",
		Desc = "Seconds to wait after a round starts before Auto Fling begins (0 = instant).",
		Step = 1,
		Suffix = " s",
		Value = { Min = 0, Max = 30, Default = 0 },
		Callback = function(v)
			local n = tonumber(v) or (type(v) == "table" and tonumber(v.Value)) or 0
			startDelay = math.clamp(n, 0, 30)
		end,
	})
end

list2.el.tpMurd = tbl43.fling:Button({
	Title = "Teleport to Murderer",
	Desc = "Instantly go to whoever has the knife",
	Icon = "lucide:crosshair",
	Callback = function()
		func31(func15(), "Murderer")
	end,
})

list2.el.tpSher = tbl43.fling:Button({
	Title = "Teleport to Sheriff",
	Desc = "Instantly go to whoever has the gun",
	Icon = "lucide:shield",
	Callback = function()
		func31(func16(), "Sheriff")
	end,
})

-- ===================== EXTRA FEATURES 4 (ported from MM2_readable) =====================
-- Kill Nearest, TP to Dropped Gun, Custom Sounds (GunKill / Gunshot / Knife Kill + test buttons),
-- Hide Display Skins. Everything sits in its own do-block (Lua allows 200 locals per chunk).
do
	local Players = game:GetService("Players")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local SoundService = game:GetService("SoundService")
	local Debris = game:GetService("Debris")
	local lp = Players.LocalPlayer

	local function note(title, content, icon)
		obj2:Notify({ Title = title, Content = content, Duration = 2, Icon = icon or "check" })
	end

	local function onUnload(fn)
		list2.conns[#list2.conns + 1] = { Disconnect = fn }
	end

	local function pick(v)
		if type(v) == "table" then
			v = v[1] or v.Value
		end
		return v and tostring(v) or nil
	end

	local function aliveRoot(p)
		local c = p and p.Character
		local r = c and c:FindFirstChild("HumanoidRootPart")
		local h = c and c:FindFirstChildOfClass("Humanoid")
		if r and h and h.Health > 0 then
			return r
		end
		return nil
	end

	-- ---------------------------------------------------------------- Kill Nearest
	-- Murderer only: stabs the closest living player (uses the same stab as the "Kill Target" button).
	local function nearestPlayer()
		local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
		if not myRoot then
			return nil
		end

		local best, bestDist = nil, math.huge

		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= lp then
				local r = aliveRoot(p)
				if r then
					local d = (r.Position - myRoot.Position).Magnitude
					if d < bestDist then
						best, bestDist = p, d
					end
				end
			end
		end

		return best
	end

	local function killNearest()
		if func15() ~= lp then
			note("Error", "You are not murderer.", "x")
			return
		end

		local target = nearestPlayer()
		if not target then
			note("Error", "Can't find a player!", "x")
			return
		end

		func76(target.Name)
	end

	-- ---------------------------------------------------------------- TP to Dropped Gun
	local function hasGun()
		local backpack = lp:FindFirstChildOfClass("Backpack")
		return (lp.Character and lp.Character:FindFirstChild("Gun")) or (backpack and backpack:FindFirstChild("Gun")) or nil
	end

	local tpBusy = false

	local function tpToDroppedGun()
		if tpBusy then
			return
		end

		if func15() == lp then
			note("Error", "You are murderer!", "x")
			return
		end

		local drop = workspace:FindFirstChild("GunDrop", true)
		if not (drop and drop.Parent) then
			note("Error", "No dropped gun.", "x")
			return
		end

		local char = lp.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not root then
			note("Error", "No character.", "x")
			return
		end

		if hasGun() then
			note("TP", "You already have a gun.", "x")
			return
		end

		tpBusy = true

		task.spawn(function()
			-- 1) touch it from where you stand (no teleport)
			local parts = {}
			if drop:IsA("BasePart") then
				parts[1] = drop
			end
			for _, d in ipairs(drop:GetDescendants()) do
				if d:IsA("BasePart") then
					parts[#parts + 1] = d
				end
			end

			local t0 = os.clock()
			while os.clock() - t0 < 0.4 and not hasGun() and drop.Parent do
				for _, part in ipairs(parts) do
					pcall(firetouchinterest, root, part, 0)
					pcall(firetouchinterest, root, part, 1)
				end
				task.wait()
			end

			if hasGun() then
				tpBusy = false
				note("TP", "Gun picked up (Remote).")
				return
			end

			-- 2) still no gun: go to it, wait for it to land in your backpack, then come back
			local back = char:GetPivot()
			local ok = pcall(function()
				char:PivotTo(drop:GetPivot())
			end)

			if ok then
				local t1 = os.clock()
				while os.clock() - t1 < 1.5 and not hasGun() and drop.Parent do
					task.wait()
				end

				if char.Parent then
					pcall(function()
						char:PivotTo(back)
					end)
				end
			end

			tpBusy = false

			if hasGun() then
				note("TP", "Gun picked up, returned to position.")
			else
				note("TP", "Couldn't pick up the gun.", "x")
			end
		end)
	end

	-- ---------------------------------------------------------------- Custom Sounds
	local SOUND_IDS = {
		["Rust Headshot"] = "138750331387064", Neverlose = "110168723447153", Bubble = "6534947588",
		Steve = "4965083997", ["Call of Duty"] = "5952120301", Bat = "3333907347",
		["TF2 Critical"] = "296102734", Saber = "8415678813", Bameware = "3124331820",
		Money = "13956013041", Notif = "6696469190", Shutter = "10066921516",
		RIFK7 = "9102080552", LazerBeam = "130791043", WindowsXPError = "160715357",
		TF2Hitsound = "3455144981", TF2Bat = "3333907347", BowHit = "1053296915",
		Bow = "3442683707", OSU = "7147454322", OneNN = "7349055654",
		TF2Pan = "3431749479", Mario = "5709456554", Bell = "6534947240",
		Pick = "1347140027", Fart = "130833677", Big = "5332005053",
		Vine = "5332680810", Bruh = "4578740568", Skeet = "5633695679",
		Fatality = "6534947869", Bonk = "5766898159", Minecraft = "5869422451",
		Gamesense = "4817809188", Bamboo = "3769434519", Weeb = "6442965016",
		Beep = "8177256015", Bambi = "8437203821", Stone = "3581383408",
		["Old Fatality"] = "6607142036", Click = "8053704437", Ding = "7149516994",
		Snow = "6455527632", Osu = "7149255551", TF2 = "2868331684",
		Slime = "6916371803", ["Among Us"] = "5700183626", One = "7380502345",
		BulletDeflect = "1657157666", ["Default Sound"] = "330595293", UwU = "8679659744",
		Cod = "160432334", ["Blood SFX"] = "8164951181", ["Blood Burst"] = "3781479909",
	}

	local SOUND_NAMES = {}
	for name in pairs(SOUND_IDS) do
		SOUND_NAMES[#SOUND_NAMES + 1] = name
	end
	table.sort(SOUND_NAMES)
	table.insert(SOUND_NAMES, 1, "Default")

	local function soundId(name)
		local id = name and SOUND_IDS[name]
		return id and ("rbxassetid://" .. id) or nil
	end

	-- the game's own sounds are named GunKill (sheriff kills), Gunshot and Kill (knife kill)
	local CS = {
		sel = { GunKill = "Default", Gunshot = "Default", Kill = "Default" },
		hooked = setmetatable({}, { __mode = "k" }),
		conns = {},
	}

	local function csHook(s)
		if not s:IsA("Sound") or CS.hooked[s] then
			return
		end
		local kind = s.Name
		if kind ~= "GunKill" and kind ~= "Gunshot" and kind ~= "Kill" then
			return
		end

		CS.hooked[s] = true

		CS.conns[#CS.conns + 1] = s.Played:Connect(function()
			local id = soundId(CS.sel[kind])
			if id and s.SoundId ~= id then
				s.SoundId = id
				s.TimePosition = 0
				s:Play()
			end
		end)
	end

	for _, d in ipairs(workspace:GetDescendants()) do
		pcall(csHook, d)
	end

	CS.conns[#CS.conns + 1] = workspace.DescendantAdded:Connect(function(d)
		pcall(csHook, d)
	end)

	onUnload(function()
		for _, c in ipairs(CS.conns) do
			pcall(function()
				c:Disconnect()
			end)
		end
		table.clear(CS.conns)
	end)

	local function testSound(title, kind)
		local id = soundId(CS.sel[kind])
		if not id then
			note(title, "Select a custom sound first.", "x")
			return
		end

		local s = Instance.new("Sound")
		s.SoundId = id
		s.Volume = 2
		s.Parent = SoundService
		s:Play()
		Debris:AddItem(s, 6)
		note(title, "Tested: " .. tostring(CS.sel[kind]))
	end

	local function selectSound(title, kind, v)
		local name = pick(v) or "Default"
		CS.sel[kind] = name
		note(title, "Set to: " .. name, "volume-2")
	end

	-- ---------------------------------------------------------------- Hide Display Skins
	-- Moves the DisplayRefGun / DisplayRefKnife objects (and the model they point at) out of your character,
	-- so the display skins of the knife and gun are not drawn. Switch it off to put them back.
	local HS = { on = false, store = {}, folder = nil, conns = {}, charConn = nil }

	local function hsHide(inst)
		if not HS.on or HS.store[inst] then
			return
		end
		if inst.Name ~= "DisplayRefGun" and inst.Name ~= "DisplayRefKnife" then
			return
		end

		HS.store[inst] = true

		task.spawn(function()
			local model
			if inst:IsA("ObjectValue") then
				if not inst.Value then
					inst:GetPropertyChangedSignal("Value"):Wait()
				end
				model = inst.Value
			end

			if not HS.on then
				HS.store[inst] = nil
				return
			end

			HS.store[inst] = {
				object = inst,
				objParent = inst.Parent,
				model = model,
				modelParent = model and model.Parent or nil,
			}

			if model then
				model.Parent = HS.folder
			end
			inst.Parent = HS.folder
		end)
	end

	local function hsHookChar(char)
		if HS.charConn then
			pcall(function()
				HS.charConn:Disconnect()
			end)
			HS.charConn = nil
		end
		if not char then
			return
		end

		for _, child in ipairs(char:GetChildren()) do
			hsHide(child)
		end

		HS.charConn = char.ChildAdded:Connect(hsHide)
	end

	local function hsRestore()
		HS.on = false

		if HS.charConn then
			pcall(function()
				HS.charConn:Disconnect()
			end)
			HS.charConn = nil
		end

		for _, c in ipairs(HS.conns) do
			pcall(function()
				c:Disconnect()
			end)
		end
		table.clear(HS.conns)

		for _, rec in pairs(HS.store) do
			if type(rec) == "table" then
				if rec.model and rec.modelParent and rec.modelParent.Parent then
					pcall(function()
						rec.model.Parent = rec.modelParent
					end)
				end
				if rec.object and rec.objParent and rec.objParent.Parent then
					pcall(function()
						rec.object.Parent = rec.objParent
					end)
				end
			end
		end
		table.clear(HS.store)
	end

	local function hsStart()
		hsRestore()
		HS.on = true

		local folder = ReplicatedStorage:FindFirstChild("HiddenSkins")
		if not folder then
			folder = Instance.new("Folder")
			folder.Name = "HiddenSkins"
			folder.Parent = ReplicatedStorage
		end
		HS.folder = folder

		hsHookChar(lp.Character)

		HS.conns[#HS.conns + 1] = lp.CharacterAdded:Connect(function(char)
			if HS.on then
				hsHookChar(char)
			end
		end)
	end

	onUnload(hsRestore)

	-- ---------------------------------------------------------------- UI
	-- the two buttons now live next to Kill All and Auto Grab Gun (see the combat tab); they call these
	list2.killNearest = killNearest
	list2.tpToDroppedGun = tpToDroppedGun

	tbl43.visuals:Section({ Title = "Custom Sounds" })

	tbl43.visuals:Dropdown({
		Title = "GunKill Sound",
		Flag = "Dropdown_Sound_GunKill",
		Desc = "Replaces the sound when the sheriff kills someone.",
		Multi = false,
		Value = "Default",
		Values = SOUND_NAMES,
		Callback = function(v)
			selectSound("GunKill Sound", "GunKill", v)
		end,
	})

	tbl43.visuals:Dropdown({
		Title = "Gunshot Sound",
		Flag = "Dropdown_Sound_Gunshot",
		Desc = "Replaces the gunshot sound.",
		Multi = false,
		Value = "Default",
		Values = SOUND_NAMES,
		Callback = function(v)
			selectSound("Gunshot Sound", "Gunshot", v)
		end,
	})

	tbl43.visuals:Dropdown({
		Title = "Knife Kill Sound",
		Flag = "Dropdown_Sound_KnifeKill",
		Desc = "Replaces the sound when the murderer kills someone.",
		Multi = false,
		Value = "Default",
		Values = SOUND_NAMES,
		Callback = function(v)
			selectSound("Knife Kill Sound", "Kill", v)
		end,
	})

	tbl43.visuals:Button({
		Title = "Test GunKill Sound",
		Icon = "speaker",
		Callback = function()
			testSound("GunKill Sound", "GunKill")
		end,
	})

	tbl43.visuals:Button({
		Title = "Test Gunshot Sound",
		Icon = "speaker",
		Callback = function()
			testSound("Gunshot Sound", "Gunshot")
		end,
	})

	tbl43.visuals:Button({
		Title = "Test Knife Kill Sound",
		Icon = "speaker",
		Callback = function()
			testSound("Knife Kill Sound", "Kill")
		end,
	})

	tbl43.skins:Toggle({
		Title = "Hide Display Skins",
		Flag = "Toggle_Hide_Display_Skins",
		Desc = "Hides the display skins of your knife and gun.",
		Type = "Toggle",
		Value = false,
		Callback = function(v)
			if v then
				hsStart()
				note("Avatar", "Skins hidden.")
			else
				hsRestore()
				note("Avatar", "Skins restored.", "power-off")
			end
		end,
	})
end

-- ===== Lobby / Map warp =====
do
	local returnCFrame = nil -- where we were in the map before warping to the lobby

	local function notify(title, content, ok)
		pcall(function()
			obj2:Notify({ Title = title, Content = content, Duration = 1.5, Icon = ok and "check" or "x" })
		end)
	end

	local function getRoot()
		local char = localPlayer.Character
		return char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
	end

	-- turn Part / Model / Folder into a CFrame we can stand on
	local function cframeOf(inst)
		if not inst then
			return nil
		end

		if inst:IsA("BasePart") then
			return inst.CFrame * CFrame.new(0, inst.Size.Y / 2 + 4, 0)
		end

		if inst:IsA("Model") then
			local ok, pivot = pcall(function()
				return inst:GetPivot()
			end)
			if ok then
				return pivot * CFrame.new(0, 4, 0)
			end
		end

		for _, d in ipairs(inst:GetDescendants()) do
			if d:IsA("BasePart") then
				return d.CFrame * CFrame.new(0, d.Size.Y / 2 + 4, 0)
			end
		end
	end

	-- lobby target: workspace.Lobby.Spawns (pick one of the spawn parts)
	local function lobbyCFrame()
		local lobbyFolder = Workspace:FindFirstChild("Lobby")
		local spawns = lobbyFolder and lobbyFolder:FindFirstChild("Spawns")
		if not spawns then
			return nil
		end

		if spawns:IsA("BasePart") then
			return cframeOf(spawns)
		end

		local parts = {}
		for _, d in ipairs(spawns:GetDescendants()) do
			if d:IsA("BasePart") then
				parts[#parts + 1] = d
			end
		end

		if #parts > 0 then
			return cframeOf(parts[math.random(1, #parts)])
		end

		return cframeOf(spawns)
	end

	-- the map of the current round = the model in workspace that has CoinContainer / Spawns
	local function findMap()
		for _, child in ipairs(Workspace:GetChildren()) do
			if child:IsA("Model") and child.Name ~= "RegularLobby" and child.Name ~= "Lobby"
				and (child:FindFirstChild("CoinContainer") or child:FindFirstChild("CoinAreas") or child:FindFirstChild("Spawns")) then
				return child
			end
		end
	end

	local function mapCFrame()
		local map = findMap()
		if not map then
			return nil
		end

		local spawns = map:FindFirstChild("Spawns")
		if spawns then
			local parts = {}
			for _, p in ipairs(spawns:GetChildren()) do
				if p:IsA("BasePart") then
					parts[#parts + 1] = p
				end
			end
			if #parts > 0 then
				return cframeOf(parts[math.random(1, #parts)])
			end
		end

		return cframeOf(map)
	end

	local function warp(cf)
		local root = getRoot()
		if not root or not cf then
			return false
		end

		local hum = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.PlatformStand = false
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end

		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		root.CFrame = cf
		return true
	end

	local function warpLobby()
		local root = getRoot()
		if not root then
			notify("Error!", "Character not loaded!", false)
			return
		end

		local cf = lobbyCFrame()
		if not cf then
			notify("Error!", "Lobby not found!", false)
			return
		end

		-- remember the map position only if we are actually in a round map
		if findMap() and not list2.inLobbyNow() then
			returnCFrame = root.CFrame
		end

		if warp(cf) then
			notify("Teleported!", "Teleported to Lobby", true)
		end
	end

	local function warpMap()
		if not findMap() then
			notify("Error!", "No map loaded - wait for a round to start!", false)
			return
		end

		local cf = returnCFrame or mapCFrame()
		if not cf then
			notify("Error!", "Couldn't find a spot on the map!", false)
			return
		end

		if warp(cf) then
			notify("Teleported!", "Teleported back to the Map", true)
		end
	end

	-- shared with the floating (on-screen) buttons
	list2.warpLobby = warpLobby
	list2.warpMap = warpMap

	tbl43.fling:Section({ Title = "Lobby & Map" })

	tbl43.fling:Button({
		Title = "Teleport to Lobby",
		Desc = "Warp to the lobby",
		Icon = "lucide:home",
		Callback = warpLobby,
	})

	tbl43.fling:Button({
		Title = "Teleport back to Map",
		Desc = "Go back to the map you were playing on (your last spot, or a map spawn)",
		Icon = "lucide:map",
		Callback = warpMap,
	})

	-- a new round = a different map, so the old saved map spot is no longer valid
	list2.conns[#list2.conns + 1] = Workspace.ChildAdded:Connect(function(child)
		if child:FindFirstChild("CoinContainer") or child:FindFirstChild("Spawns") then
			returnCFrame = nil
		end
	end)
end

tbl43.fling:Section({ Title = "Target Player" })
local connection5

do
	local value143 = nil

	local function func121()
		local tbl47 = {}

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= localPlayer then
				table.insert(tbl47, player.Name)
			end
		end

		return tbl47
	end

	local obj16 = tbl43.fling:Dropdown({
		Title = "Target",
		Desc = "Pick a player for the buttons below",
		Multi = false,
		Value = nil,
		Values = func121(),
		Callback = function(value)
			value143 = value
		end,
	})

	func28 = function()
		return value143
	end

	local function func122()
		pcall(function()
			obj16:Refresh(func121())
		end)

		pcall(function()
			killTargetDropdown:Refresh(func121())
		end)
	end

	list2.conns[#list2.conns + 1] = Players.PlayerAdded:Connect(func122)
	list2.conns[#list2.conns + 1] = Players.PlayerRemoving:Connect(func122)

	local function func123()
		if not value143 then
			obj2:Notify({ Title = "Error!", Content = "Pick a player first!", Duration = 1.5, Icon = "x" })
			return nil
		end
		local flag140 = Players:FindFirstChild(value143)
		if not flag140 then
			obj2:Notify({ Title = "Error!", Content = "Player left the game!", Duration = 1.5, Icon = "x" })
			return nil
		end

		if flag140 == localPlayer then
			obj2:Notify({ Title = "Error!", Content = "You can't target yourself!", Duration = 1.5, Icon = "x" })
			return nil
		end
		return flag140
	end

	list2.flingMode = list2.flingMode or "Slam"

	tbl43.fling:Dropdown({
		Title = "Fling Mode",
		Flag = "Dropdown_Fling_Mode",
		Desc = "Slam (Head): land on the head, pushes them into the void. Spin (Other Script): spin around the target above and below it, using the other script's method.",
		Multi = false,
		Value = "Slam (Head)",
		Values = { "Slam (Head)", "Spin (Other Script)" },
		Callback = function(value)
			local chosen = tostring(type(value) == "table" and (value[1] or value.Value) or value)

			if chosen:find("Spin") then
				list2.flingMode = "Spin"
			else
				list2.flingMode = "Slam"
			end
		end,
	})

	list2.smartFling = list2.smartFling or false

	tbl43.fling:Toggle({
		Title = "Smart Fling (Auto Mode)",
		Flag = "Toggle_Smart_Fling",
		Desc = "Extra for every fling: the target is standing still = Slam (Head), the target is walking = Spin (Other Script). Chosen again at the start of each fling, and overrides the Fling Mode above while it is on.",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			list2.smartFling = value and true or false
		end,
	})

	tbl43.fling:Button({
		Title = "Fling Player",
		Desc = "Fling whoever you picked above",
		Icon = "lucide:zap",
		Color = Color3.fromHex("#d6d6d6"),
		Callback = function()
			local result18 = func123()

			if result18 then
				func27(result18)
			end
		end,
	})

	tbl43.fling:Button({
		Title = "Teleport",
		Desc = "Teleport to the selected player",
		Icon = "lucide:navigation",
		Color = Color3.fromHex("#d6d6d6"),
		Callback = function()
			local result19 = func123()

			if result19 then
				func31(result19, result19.Name)
			end
		end,
	})

	local value144 = nil

	value144 = tbl43.fling:Toggle({
		Title = "Spam Fling",
		Flag = "Toggle_Spam_Fling",
		Desc = "Keeps flinging the player picked above until you turn it off",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			flag34 = value

			if value then
				if not value143 then
					obj2:Notify({
						Title = "Error!",
						Content = "Pick a player from the dropdown first!",
						Duration = 2,
						Icon = "x",
					})

					flag34 = false

					pcall(function()
						value144:Set(false)
					end)

					return
				end

				func29()

				obj2:Notify({
					Title = "Spam Fling ON",
					Content = "Spam flinging " .. value143 .. "!",
					Duration = 2,
					Icon = "flame",
				})
			else
				func30()

				obj2:Notify({
					Title = "Spam Fling OFF",
					Content = "Stopped spam flinging.",
					Duration = 2,
					Icon = "power-off",
				})
			end
		end,
	})

	-- ===== More things to do with the picked target: Spectate, Headsit, Loop Teleport =====
	do
		local RunService_ = game:GetService("RunService")

		local function targetCharacter()
			local name = func28 and func28()
			local player = name and Players:FindFirstChild(name)
			return player and player.Character
		end

		-- Spectate: the camera follows the target
		local spectating = false

		tbl43.fling:Toggle({
			Title = "Spectate",
			Flag = "Toggle_Target_Spectate",
			Desc = "Your camera follows the player picked above. Turn off to get your own camera back.",
			Type = "Toggle",
			Value = false,
			Callback = function(on)
				spectating = on

				if on then
					task.spawn(function()
						while spectating do
							local character = targetCharacter()
							local humanoid = character and character:FindFirstChildOfClass("Humanoid")
							local camera = workspace.CurrentCamera

							if humanoid and camera and camera.CameraSubject ~= humanoid then
								camera.CameraSubject = humanoid
							end

							task.wait(0.1)
						end
					end)
				else
					local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

					if humanoid and workspace.CurrentCamera then
						workspace.CurrentCamera.CameraSubject = humanoid
					end
				end
			end,
		})

		-- Headsit / Loop Teleport: stay glued to the target every frame
		local function followToggle(title, flag, desc, offset, onHead)
			local connection

			tbl43.fling:Toggle({
				Title = title,
				Flag = flag,
				Desc = desc,
				Type = "Toggle",
				Value = false,
				Callback = function(on)
					if connection then
						connection:Disconnect()
						connection = nil
					end

					if not on then
						return
					end

					connection = RunService_.Heartbeat:Connect(function()
						pcall(function()
							local character = targetCharacter()
							local part = character and (onHead and character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart"))
							local mine = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

							if part and mine then
								mine.AssemblyLinearVelocity = Vector3.zero
								mine.CFrame = part.CFrame * offset
							end
						end)
					end)
					list2.conns[#list2.conns + 1] = connection
				end,
			})
		end

		followToggle("Headsit", "Toggle_Target_Headsit", "Sit on top of the picked player's head and ride along with them.", CFrame.new(0, 1.6, 0), true)
		followToggle("Loop Teleport", "Toggle_Target_Loop_TP", "Keep teleporting to the picked player, right behind them, every frame.", CFrame.new(0, 0, 2.5), false)
	end

	tbl43.fling:Section({ Title = "Player Roles (Live Data)" })

	list2.roleUI = { last = nil, lastCheck = 0, tpIndex = 0 }
	list2.roleUI.para = tbl43.fling:Paragraph({ Title = "Selected Player Role", Desc = "Pick a player in the Target dropdown." })

	list2.roleUI.refresh = function()
		local text

		if not value143 then
			text = "Pick a player in the Target dropdown."
		else
			local player = Players:FindFirstChild(value143)

			if not player then
				text = "That player left the game."
			else
				text = player.Name .. "  —  " .. list2.roleText2(player)
			end
		end

		if text ~= list2.roleUI.last then
			list2.roleUI.last = text

			pcall(function()
				list2.roleUI.para:SetDesc(text)
			end)
		end
	end

	list2.conns[#list2.conns + 1] = RunService.Heartbeat:Connect(function()
		local now = os.clock()

		if now - list2.roleUI.lastCheck < 0.5 then
			return
		end

		list2.roleUI.lastCheck = now
		pcall(list2.roleUI.refresh)
	end)

	tbl43.fling:Button({
		Title = "Check Role",
		Desc = "Show the role of the player picked above (from live player data)",
		Icon = "lucide:scan-search",
		Callback = function()
			local player = func123()

			if player then
				obj2:Notify({
					Title = "Role Check",
					Content = player.Name .. ": " .. list2.roleText2(player),
					Duration = 3,
					Icon = "check",
				})
			end
		end,
	})

	tbl43.fling:Button({
		Title = "Show Murderer & Sheriff",
		Desc = "Lists who currently has the knife and the gun",
		Icon = "lucide:users",
		Callback = function()
			local murderer = func15()
			local sheriff = func16()

			if not murderer and not sheriff then
				obj2:Notify({ Title = "Roles", Content = "No round data yet.", Duration = 2, Icon = "x" })
				return
			end

			obj2:Notify({
				Title = "Roles",
				Content = "Murderer: " .. (murderer and murderer.Name or "?") .. "\nSheriff: " .. (sheriff and sheriff.Name or "?"),
				Duration = 4,
				Icon = "check",
			})
		end,
	})

	tbl43.fling:Button({
		Title = "Teleport to Next Player",
		Desc = "Cycles through every other alive player. The notification shows their role",
		Icon = "lucide:skip-forward",
		Callback = function()
			local candidates = {}

			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
					candidates[#candidates + 1] = player
				end
			end

			if #candidates == 0 then
				obj2:Notify({ Title = "Error!", Content = "No other players to teleport to!", Duration = 1.5, Icon = "x" })
				return
			end

			list2.roleUI.tpIndex = list2.roleUI.tpIndex % #candidates + 1
			local player = candidates[list2.roleUI.tpIndex]
			func31(player, player.Name)
		end,
	})

	list2.GUN_ICON = "http://www.roblox.com/asset/?id=197518111"
	list2.KNIFE_ICON = "rbxassetid://584555920"

	list2.FLAG_ICON = {
		Toggle_Sound_Errors = "rbxassetid://83898160590116",
		Toggle_Sound_Button_Click = "rbxassetid://107150227368485",
		Toggle_Sound_Switches = "rbxassetid://85887872573050",
	}

	list2.ROLE_ICON = {
		Toggle_Auto_Grab_Gun = "gun",
		Toggle_Silent_Aim = "gun",
		Toggle_Dropped_Gun_ESP = "gun",
		Toggle_Sound_Gun_Drop = "gun",
		Toggle_Silent_Throw = "knife",
		Toggle_Fling_Murderer_When_Done = "knife",
		Toggle_Kill_All_When_Bag_Full = "knife",
	}

	task.spawn(function()
		local tbl48 = {}

		for k, value145 in pairs(list2.ROLE_ICON) do
			tbl48[k] = value145 == "gun" and list2.GUN_ICON or list2.KNIFE_ICON
		end

		for k, value146 in pairs(list2.FLAG_ICON) do
			tbl48[k] = value146
		end

		local tbl49 = {}
		local n4 = os.clock() + 30

		while os.clock() < n4 do
			local elements = list2.config and list2.config.Elements

			if type(elements) ~= "table" then
				task.wait(0.5)
				continue
			else
				local flag141 = false

				for k, value147 in pairs(tbl48) do
					if not tbl49[k] then
						local entry5 = elements[k]

						if entry5 then
							pcall(function()
								entry5:SetImage(value147, 28)
							end)

							tbl49[k] = true
						else
							flag141 = true
						end
					end
				end

				if flag141 then
					task.wait(0.5)
					continue
				end
			end

			break
		end

		for i = 1, 80 do
			if not (#list2.gunEls > 0 and #list2.knifeEls > 0 and list2.el.flingSher and list2.el.tpSher and list2.el.flingMurd and list2.el.tpMurd) then
				task.wait(0.25)
				continue
			end
			break
		end

		local list21 = {}

		for _, gunEl in ipairs(list2.gunEls) do
			list21[#list21 + 1] = { gunEl, list2.GUN_ICON }
		end

		for _, knifeEl in ipairs(list2.knifeEls) do
			list21[#list21 + 1] = { knifeEl, list2.KNIFE_ICON }
		end

		list21[#list21 + 1] = { list2.el.flingSher, list2.GUN_ICON }
		list21[#list21 + 1] = { list2.el.tpSher, list2.GUN_ICON }
		list21[#list21 + 1] = { list2.el.flingMurd, list2.KNIFE_ICON }
		list21[#list21 + 1] = { list2.el.tpMurd, list2.KNIFE_ICON }
		list2.iconsApplied = 0

		for _, item30 in ipairs(list21) do
			if type(item30[1]) == "table" then
				if pcall(function()
					item30[1]:SetImage(item30[2], 28)
				end) then
					list2.iconsApplied = list2.iconsApplied + 1
				end
			end
		end

		for k in pairs(tbl49) do
			list2.iconsApplied = list2.iconsApplied + 1
		end
	end)

	func120(ICON.mono)
	tbl43.farm:Section({ Title = "Coin Autofarm" })

	tbl43.farm:Toggle({
		Title = "Coin Autofarm",
		Flag = "Toggle_Coin_Autofarm",
		Desc = "Walks you around picking up coins.",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			if value then
				if flag42 then
					list2.setToggle(list2.el.fly, false, function()
						flag42 = false
						func42()
					end)
				end

				func48()
				list2.startFarmHopWatch()
				obj2:Notify({ Title = "Autofarm Started!", Content = list2.farmMode == "Candy" and "Farming candy!" or "Farming coins!", Duration = 2, Icon = "check" })
			else
				func49()
				list2.stopFarmHopWatch()
				obj2:Notify({ Title = "Autofarm Stopped!", Content = "Stopped farming.", Duration = 2, Icon = "power-off" })
			end
		end,
	})

	tbl43.farm:Dropdown({
		Title = "Farm Mode",
		Flag = "Dropdown_Farm_Mode",
		Desc = "Coins: normal rounds (bag 40, Elite 50). Candy: Halloween event, candies are picked up the same way as coins and the bag is full at 50.",
		Multi = false,
		Value = "Coins",
		Values = { "Coins", "Candy" },
		Callback = function(value)
			local chosen = tostring(type(value) == "table" and (value[1] or value.Value) or value)

			if chosen:find("Candy") then
				list2.farmMode = "Candy"
			else
				list2.farmMode = "Coins"
			end
		end,
	})

	tbl43.farm:Slider({
		Title = "Farm Speed",
		Flag = "Slider_Farm_Speed",
		Desc = "Meters per second",
		Step = 1,
		Value = { Min = 5, Max = 25, Default = 25 },
		Callback = function(value)
			n2 = value >= 25 and 23 or value
		end,
	})

	tbl43.farm:Section({ Title = "Settings" })

	list2.perfFarmToggle = tbl43.farm:Toggle({
		Title = "Performance Mode",
		Flag = "Toggle_Farm_Perf_Master",
		Desc = "Strips textures, shadows, particles and effects for framerate. Same switch as the one on the Visuals tab.",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			if list2.perf then
				list2.perf.setAll(value)
			end
		end,
	})

	list2.farmHopOn = true

	tbl43.farm:Toggle({
		Title = "Hop When Server Dies",
		Flag = "Toggle_Farm_Dead_Hop",
		Desc = "Hops to a fresh server when this one empties out mid-farm.",
		Type = "Toggle",
		Value = true,
		Callback = function(farmHopOn)
			list2.farmHopOn = farmHopOn
		end,
	})

	tbl43.farm:Toggle({
		Title = "Anti-AFK",
		Flag = "Toggle_Anti_AFK",
		Desc = "Prevents you from getting AFK kicked.",
		Type = "Toggle",
		Value = true,
		Callback = function(value)
			flag47 = value

			if value then
				func52()
				obj2:Notify({ Title = "Anti-AFK Enabled!", Content = "You can go AFK now!", Duration = 2, Icon = "shield" })
			else
				func53()

				obj2:Notify({
					Title = "Anti-AFK Disabled!",
					Content = "AFK protection off.",
					Duration = 2,
					Icon = "power-off",
				})
			end
		end,
	})

	tbl43.farm:Toggle({
		Title = "Auto-Reset When Bag Full",
		Flag = "Toggle_Auto_Reset_When_Bag_Full",
		Desc = "Your character dies (resets) as soon as your coin bag is full. Off by default - only happens when you switch it on.",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			flag46 = value

			if value then
				func50()
			else
				func51()
			end
		end,
	})

	tbl43.farm:Toggle({
		Title = "Auto Claim Shells",
		Flag = "Toggle_Auto_Claim_Shells",
		Desc = "Claims the end-of-round reward popup for you",
		Type = "Toggle",
		Value = false,
		Callback = function(shellsOn)
			list2.shellsOn = shellsOn

			if shellsOn then
				list2.startShells()

				obj2:Notify({
					Title = "Auto Claim Shells On!",
					Content = "Rewards claim themselves.",
					Duration = 2,
					Icon = "check",
				})
			else
				list2.stopShells()

				obj2:Notify({
					Title = "Auto Claim Shells Off!",
					Content = "Claim them yourself.",
					Duration = 2,
					Icon = "power-off",
				})
			end
		end,
	})

	tbl43.farm:Toggle({
		Title = "Fling Murderer When Done",
		Flag = "Toggle_Fling_Murderer_When_Done",
		Desc = "Yeets the murderer once your bag is full or the coins run out",
		Type = "Toggle",
		Value = false,
		Callback = function(flingWhenDone)
			list2.flingWhenDone = flingWhenDone

			if flingWhenDone then
				list2.flingDoneFired = false
			end
		end,
	})

	tbl43.farm:Toggle({
		Title = "Kill All When Bag Full",
		Flag = "Toggle_Kill_All_When_Bag_Full",
		Desc = "Stabs everyone once your bag fills up. Murderer only.",
		Type = "Toggle",
		Value = false,
		Callback = function(killWhenFull)
			list2.killWhenFull = killWhenFull

			if killWhenFull then
				list2.killFired = false
			end
		end,
	})

	if list2.mkFarmExtras then list2.mkFarmExtras() end

	flag47 = true
	func52()
	tbl43.farm:Section({ Title = "Discord Webhook" })

	list2.el.whUrl = tbl43.farm:Input({
		Title = "Webhook URL",
		Flag = "Input_Discord_Webhook",
		Desc = "Paste a Discord webhook and logging starts. Logs box opens, shell claims and round coins. Empty the box to stop.",
		Placeholder = "https://discord.com/api/webhooks/...",
		Callback = function(value)
			local whUrl = tostring(value or "")

			if whUrl ~= tostring(list2.WH_URL or "") then
				list2.saidHello = false
				list2.whBreak = false
				list2.whLastErr = nil
			end

			list2.WH_URL = whUrl
		end,
	})

	list2.el.whOn = tbl43.farm:Toggle({
		Title = "Start Sender",
		Flag = "Toggle_Discord_Sender",
		Desc = "Starts posting to the webhook above. Logs box opens, shell claims and the coins each round paid out.",
		Type = "Toggle",
		Value = false,
		Callback = function(whOn)
			list2.whOn = whOn
			if not whOn then
				return
			end

			task.spawn(function()
				local flag142, value148 = list2.whHello()

				obj2:Notify({
					Title = flag142 and "Sender Started" or "Sender Failed",
					Content = flag142 and "Posted the opening message to your webhook." or "Could not post: " .. tostring(value148) .. ".",
					Duration = 6,
					Icon = flag142 and "check" or "x",
				})

				if not flag142 then
					list2.whOn = false
					list2.setToggle(list2.el.whOn, false)
				end
			end)
		end,
	})

	tbl43.farm:Section({ Title = "Auto Open Boxes" })
	list2.el.box = {}

	for _, boxe in ipairs(list2.BOXES) do
		local first3 = boxe[1]
		local second3 = boxe[2]
		local value149, flag143 = list2.boxPrice(first3)

		list2.el.box[first3] = tbl43.farm:Toggle({
			Title = "Auto Open " .. second3,
			Flag = "Toggle_Box_" .. first3:gsub("%W", "_"),
			Desc = "Waits until you get " .. (flag143 and list2.comma(flag143) or "?") .. " " .. list2.curName(value149) .. ", then auto-opens the box for you!",
			Type = "Toggle",
			Value = false,
			Callback = function(value)
				list2.boxOn[first3] = value

				if value then
					list2.startBox(first3, second3)
				else
					list2.stopBox(first3)
				end
			end,
		})

		local value150 = list2.boxImage(first3)

		if value150 then
			pcall(function()
				list2.el.box[first3]:SetImage(value150, 30)
			end)
		end

		if first3 == "Summer2026Box" then
			local elementFrame = list2.el.box[first3] and list2.el.box[first3].ElementFrame

			if typeof(elementFrame) == "Instance" then
				local uiGradient = elementFrame:FindFirstChildWhichIsA("UIGradient")

				if uiGradient then
					uiGradient:Destroy()
				end

				local uiGradient2 = Instance.new("UIGradient")
				uiGradient2.Color = ColorSequence.new(ICON.yellow, ICON.teal)
				uiGradient2.Parent = elementFrame
			end
		end
	end

	func120(ICON.mono)

	tbl43.buttons:Toggle({
		Title = "Lock Buttons In Place",
		Flag = "Toggle_Lock_Buttons_In_Place",
		Desc = "Stops the on-screen buttons moving when you tap them.",
		Type = "Toggle",
		Value = false,
		Callback = function(locked)
			num15.locked = locked
		end,
	})

	list2.el.designDrop = tbl43.buttons:Dropdown({
		Title = "Button Design",
		Flag = "Dropdown_Button_Design",
		Desc = "Round Design is a circle with a ring that fills as the cooldown runs. Default Design puts a gauge along the bottom.",
		Multi = false,
		Value = "Default Design",
		Values = num15.DESIGN_LIST,
		Callback = function(value)
			num15.setDesign(tostring(type(value) == "table" and (value[1] or value.Value) or value))
		end,
	})

	list2.el.sizeSlider = tbl43.buttons:Slider({
		Title = "Button Size",
		Flag = "Slider_Button_Size",
		Desc = "Scales the on-screen buttons. 100 is normal.",
		Step = 1,
		Value = { Min = 50, Max = 200, Default = IS_MOBILE and 70 or 100 },
		Callback = function(value)
			local num28 = tonumber(value)
			local flag144

			if num28 then
				flag144 = num28
			else
				flag144 = type(value) == "table" and tonumber(value.Value)
			end

			list2.hudScale = (flag144 or IS_MOBILE and 70 or 100) / 100

			for _, value151 in next, num15.parts, nil do
				if value151.scale then
					local tbl50 = { Scale = list2.hudScale }
					TweenService:Create(value151.scale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), tbl50):Play()
				end
			end

			num15.relayout()
		end,
	})

	tbl43.buttons:Section({ Title = "On-Screen Buttons" })

	tbl43.buttons:Toggle({
		Title = "Shoot Murderer",
		Flag = "Toggle_Shoot_Murderer",
		Desc = "Draggable on-screen button that shoots the murderer",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			if value then
				num15.create("Shoot", "SHOOT\nMURDERER", tbl35.Shoot, HUDAccent.Shoot, HUDIcon.Shoot, func67)
			else
				num15.destroy("Shoot")
			end
		end,
	})

	tbl43.buttons:Toggle({
		Title = "Grab Gun",
		Flag = "Toggle_Grab_Gun",
		Desc = "Grabs the gun off the floor. It only drops when the sheriff dies.",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			if value then
				num15.create("Grab", "GRAB\nGUN", tbl35.Grab, HUDAccent.Grab, HUDIcon.Grab, func73)
			else
				num15.destroy("Grab")
			end
		end,
	})

	tbl43.buttons:Toggle({
		Title = "Throw Knife",
		Flag = "Toggle_Throw_Knife",
		Desc = "Throws your knife at the nearest player",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			if value then
				num15.create("Throw", "THROW\nKNIFE", tbl35.Throw, HUDAccent.Throw, HUDIcon.Throw, func68)
			else
				num15.destroy("Throw")
			end
		end,
	})

	tbl43.buttons:Toggle({
		Title = "Bomb Jump",
		Flag = "Toggle_Bomb_Jump",
		Desc = "Bomb jump, with the cooldown shown on the button",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			if value then
				num15.create("Bomb", "BOMB\nJUMP", tbl35.Bomb, HUDAccent.Bomb, HUDIcon.Bomb, func71)
			else
				num15.destroy("Bomb")
			end
		end,
	})

	tbl43.buttons:Toggle({
		Title = "Wall Hop",
		Flag = "Toggle_Wall_Hop",
		Desc = "Climbs the wall you are standing against.",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			if value then
				num15.create("WallHop", "WALL\nHOP", tbl35.WallHop, HUDAccent.WallHop, HUDIcon.WallHop, func72)
			else
				num15.destroy("WallHop")
			end
		end,
	})

	tbl43.buttons:Toggle({
		Title = "Aimbot Button",
		Flag = "Toggle_Aimbot_Button",
		Desc = "Turns the aimbot on and off, and shows its state.",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			if value then
				local Aimbot, value152 = num15.create("Aimbot", "AIMBOT\nOFF", tbl35.Aimbot, HUDAccent.Aimbot, HUDIcon.Aimbot, function()
					num16.set(not num16.enabled)
				end)

				num16.label = value152
				num16.refreshLabel()
			else
				num15.destroy("Aimbot")
				num16.label = nil
				num16.set(false)
			end
		end,
	})

	list2.killSheriff = function()
		local result20 = func16()

		if not result20 then
			obj2:Notify({
				Title = "No Sheriff",
				Content = "Nobody is holding the gun right now.",
				Duration = 2,
				Icon = "x",
			})

			return
		end

		func76(result20.Name)
	end

	list2.makeHudFling = function(hudName, getTarget, roleName, itemName)
		return function()
			local target = getTarget()

			if not target then
				obj2:Notify({
					Title = "No " .. roleName,
					Content = "Nobody is holding the " .. itemName .. " right now.",
					Duration = 2,
					Icon = "x",
				})

				return
			end

			if target == localPlayer then
				obj2:Notify({ Title = "Error!", Content = "You can't fling yourself!", Duration = 1.5, Icon = "x" })
				return
			end

			pcall(num15.setActive, hudName, true)
			pcall(func27, target)
			pcall(num15.setActive, hudName, false)
		end
	end

	list2.flingMurdHud = list2.makeHudFling("FlingMurd", func15, "Murderer", "knife")
	list2.flingSherHud = list2.makeHudFling("FlingSher", func16, "Sheriff", "gun")

	tbl43.buttons:Section({ Title = "Extra Buttons" })

	tbl43.buttons:Toggle({
		Title = "Kill All Button  (Murderer Only)",
		Flag = "Toggle_Kill_All_Button",
		Desc = "Stabs every player at once. Murderer only.",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			if value then
				num15.create("KillAll", "KILL ALL\nMURDER\nONLY", tbl35.KillAll, HUDAccent.KillAll, HUDIcon.KillAll, func77)
			else
				num15.destroy("KillAll")
			end
		end,
	})

	tbl43.buttons:Toggle({
		Title = "Kill Sheriff Button  (Murderer Only)",
		Flag = "Toggle_Kill_Sheriff_Button",
		Desc = "Stabs whoever is holding the gun. Murderer only.",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			if value then
				num15.create("KillSheriff", "KILL\nSHERIFF", tbl35.KillSheriff, HUDAccent.KillSheriff, HUDIcon.KillSheriff, list2.killSheriff)
			else
				num15.destroy("KillSheriff")
			end
		end,
	})

	tbl43.buttons:Toggle({
		Title = "Fling Murderer Button",
		Flag = "Toggle_Fling_Murderer_Button",
		Desc = "On-screen button that flings whoever has the knife.",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			if value then
				num15.create("FlingMurd", "FLING\nMURDERER", tbl35.FlingMurd, HUDAccent.FlingMurd, HUDIcon.FlingMurd, list2.flingMurdHud)
			else
				num15.destroy("FlingMurd")
			end
		end,
	})

	tbl43.buttons:Toggle({
		Title = "Fling Sheriff Button",
		Flag = "Toggle_Fling_Sheriff_Button",
		Desc = "On-screen button that flings whoever has the gun.",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			if value then
				num15.create("FlingSher", "FLING\nSHERIFF", tbl35.FlingSher, HUDAccent.FlingSher, HUDIcon.FlingSher, list2.flingSherHud)
			else
				num15.destroy("FlingSher")
			end
		end,
	})

	tbl43.buttons:Toggle({
		Title = "Free X-Ray Button",
		Flag = "Toggle_Xray_Button",
		Desc = "Unlocks the X-Ray perk for free.",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			if value then
				num15.create("Xray", "FREE\nX-RAY", tbl35.Xray, HUDAccent.Xray, HUDIcon.Xray, function()
					list2.setXray(not list2.xrayOn)
					num15.setActive("Xray", list2.xrayOn)
				end)

				num15.setActive("Xray", list2.xrayOn)
			else
				num15.destroy("Xray")
			end
		end,
	})

	tbl43.buttons:Toggle({
		Title = "Fly Button",
		Flag = "Toggle_Fly_Button",
		Desc = "On-screen button that turns Fly on and off. Same fly as the Player tab.",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			if value then
				num15.create("Fly", "FLY", tbl35.Fly, HUDAccent.Fly, HUDIcon.Fly, function()
					flag42 = not flag42

					if flag42 then
						func41()
					else
						func42()
					end

					num15.setActive("Fly", flag42)
					list2.setToggle(list2.el.fly, flag42)
				end)

				num15.setActive("Fly", flag42)
			else
				num15.destroy("Fly")
			end
		end,
	})

	tbl43.buttons:Toggle({
		Title = "Noclip Button",
		Flag = "Toggle_Noclip_Button",
		Desc = "Turns Noclip on and off - walk through walls.",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			if value then
				num15.create("Noclip", "NOCLIP", tbl35.Noclip, HUDAccent.Noclip, HUDIcon.Noclip, function()
					flag41 = not flag41

					if flag41 then
						func39()
					else
						func40()
					end

					num15.setActive("Noclip", flag41)
					list2.setToggle(list2.el.noclip, flag41)
				end)

				num15.setActive("Noclip", flag41)
			else
				num15.destroy("Noclip")
			end
		end,
	})

	tbl43.buttons:Toggle({
		Title = "Invisible Button",
		Flag = "Toggle_Invisible_Button",
		Desc = "Draggable on-screen button that turns Invisible on and off.",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			if value then
				if list2.hudSpawns and list2.hudSpawns.Invis then
					list2.hudSpawns.Invis()
				end
			else
				num15.destroy("Invis")
			end
		end,
	})

	tbl43.buttons:Toggle({
		Title = "Touch Fling Button",
		Flag = "Toggle_Touch_Fling_Button",
		Desc = "Draggable on-screen button that turns Touch Fling on and off.",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			if value then
				if list2.hudSpawns and list2.hudSpawns.TouchFling then
					list2.hudSpawns.TouchFling()
				end
			else
				num15.destroy("TouchFling")
			end
		end,
	})

	tbl43.buttons:Toggle({
		Title = "Back to Lobby Button",
		Flag = "Toggle_Lobby_TP_Button",
		Desc = "Draggable on-screen button that warps you back to the lobby.",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			if value then
				if list2.hudSpawns and list2.hudSpawns.LobbyTP then
					list2.hudSpawns.LobbyTP()
				end
			else
				num15.destroy("LobbyTP")
			end
		end,
	})

	tbl43.buttons:Toggle({
		Title = "Back to Map Button",
		Flag = "Toggle_Map_TP_Button",
		Desc = "Draggable on-screen button that warps you back to the map you are playing on.",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			if value then
				if list2.hudSpawns and list2.hudSpawns.MapTP then
					list2.hudSpawns.MapTP()
				end
			else
				num15.destroy("MapTP")
			end
		end,
	})

	tbl43.buttons:Toggle({
		Title = "Round Timer",
		Flag = "Toggle_Round_Timer",
		Desc = "On-screen clock with the time left in the round and how long it has run. Drag it anywhere.",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			list2.timer.on = value

			if value then
				list2.timer.create()
			else
				list2.timer.destroy()
			end
		end,
	})

	list2.BTN_GLYPH = {
		Toggle_Shoot_Murderer = "Shoot",
		Toggle_Grab_Gun = "Grab",
		Toggle_Throw_Knife = "Throw",
		Toggle_Bomb_Jump = "Bomb",
		Toggle_Wall_Hop = "WallHop",
		Toggle_Aimbot_Button = "Aimbot",
		Toggle_Kill_All_Button = "KillAll",
		Toggle_Kill_Sheriff_Button = "KillSheriff",
		Toggle_Fling_Murderer_Button = "FlingMurd",
		Toggle_Fling_Sheriff_Button = "FlingSher",
		Toggle_Xray_Button = "Xray",
		Toggle_Fly_Button = "Fly",
		Toggle_Noclip_Button = "Noclip",
		Toggle_TP_Shoot_Button = "TPShoot",
		Toggle_Invisible_Button = "Invis",
		Toggle_Touch_Fling_Button = "TouchFling",
		Toggle_Lobby_TP_Button = "LobbyTP",
		Toggle_Map_TP_Button = "MapTP",
	}

	task.spawn(function()
		for i = 1, 40 do
			if not (list2.config and type(list2.config.Elements) == "table") then
				task.wait(0.25)
				continue
			end
			break
		end

		local elements = list2.config and list2.config.Elements
		if type(elements) ~= "table" then
			return
		end

		for k, value153 in pairs(list2.BTN_GLYPH) do
			local entry6 = elements[k]
			local entry7 = HUDIcon[value153]
			local value154 = entry7 and ICONS[entry7] or nil

			if entry6 and value154 then
				pcall(function()
					entry6:SetImage(value154, 28)
				end)
			end
		end
	end)

	list2.hudSpawns = {
		Shoot = function()
			num15.create("Shoot", "SHOOT\nMURDERER", tbl35.Shoot, HUDAccent.Shoot, HUDIcon.Shoot, func67)
		end,
		Grab = function()
			num15.create("Grab", "GRAB\nGUN", tbl35.Grab, HUDAccent.Grab, HUDIcon.Grab, func73)
		end,
		TPShoot = function()
			num15.create("TPShoot", list2.tpPosText(list2.tpShootPos), tbl35.TPShoot, HUDAccent.TPShoot, HUDIcon.TPShoot, function()
				if list2.tpShootRun then
					list2.tpShootRun()
				end
			end)
		end,
		Invis = function()
			num15.create("Invis", "INVISIBLE", tbl35.Invis, HUDAccent.Invis, HUDIcon.Invis, function()
				if list2.setInvisible then
					list2.setInvisible(not (list2.invis and list2.invis.on))
				end
			end)

			num15.setActive("Invis", list2.invis and list2.invis.on or false)
		end,
		TouchFling = function()
			num15.create("TouchFling", "TOUCH\nFLING", tbl35.TouchFling, HUDAccent.TouchFling, HUDIcon.TouchFling, function()
				if list2.setTouchFling then
					list2.setTouchFling(not (list2.touchFling and list2.touchFling.on))
				end
			end)

			num15.setActive("TouchFling", list2.touchFling and list2.touchFling.on or false)
		end,
		LobbyTP = function()
			num15.create("LobbyTP", "BACK TO\nLOBBY", tbl35.LobbyTP, HUDAccent.LobbyTP, HUDIcon.LobbyTP, function()
				if list2.warpLobby then
					list2.warpLobby()
				end
			end)
		end,
		MapTP = function()
			num15.create("MapTP", "BACK TO\nMAP", tbl35.MapTP, HUDAccent.MapTP, HUDIcon.MapTP, function()
				if list2.warpMap then
					list2.warpMap()
				end
			end)
		end,
		Throw = function()
			num15.create("Throw", "THROW\nKNIFE", tbl35.Throw, HUDAccent.Throw, HUDIcon.Throw, func68)
		end,
		Aimbot = function()
			local Aimbot, value155 = num15.create("Aimbot", "AIMBOT\nOFF", tbl35.Aimbot, HUDAccent.Aimbot, HUDIcon.Aimbot, function()
				num16.set(not num16.enabled)
			end)

			num16.label = value155
			num16.refreshLabel()
		end,
		Bomb = function()
			num15.create("Bomb", "BOMB\nJUMP", tbl35.Bomb, HUDAccent.Bomb, HUDIcon.Bomb, func71)
		end,
		WallHop = function()
			num15.create("WallHop", "WALL\nHOP", tbl35.WallHop, HUDAccent.WallHop, HUDIcon.WallHop, func72)
		end,
		KillAll = function()
			num15.create("KillAll", "KILL ALL\nMURDER\nONLY", tbl35.KillAll, HUDAccent.KillAll, HUDIcon.KillAll, func77)
		end,
		KillSheriff = function()
			num15.create("KillSheriff", "KILL\nSHERIFF", tbl35.KillSheriff, HUDAccent.KillSheriff, HUDIcon.KillSheriff, list2.killSheriff)
		end,
		FlingMurd = function()
			num15.create("FlingMurd", "FLING\nMURDERER", tbl35.FlingMurd, HUDAccent.FlingMurd, HUDIcon.FlingMurd, list2.flingMurdHud)
		end,
		FlingSher = function()
			num15.create("FlingSher", "FLING\nSHERIFF", tbl35.FlingSher, HUDAccent.FlingSher, HUDIcon.FlingSher, list2.flingSherHud)
		end,
		Xray = function()
			num15.create("Xray", "FREE\nX-RAY", tbl35.Xray, HUDAccent.Xray, HUDIcon.Xray, function()
				list2.setXray(not list2.xrayOn)
				num15.setActive("Xray", list2.xrayOn)
			end)

			num15.setActive("Xray", list2.xrayOn)
		end,
		Fly = function()
			num15.create("Fly", "FLY", tbl35.Fly, HUDAccent.Fly, HUDIcon.Fly, function()
				flag42 = not flag42

				if flag42 then
					func41()
				else
					func42()
				end

				num15.setActive("Fly", flag42)
				list2.setToggle(list2.el.fly, flag42)
			end)

			num15.setActive("Fly", flag42)
		end,
		Noclip = function()
			num15.create("Noclip", "NOCLIP", tbl35.Noclip, HUDAccent.Noclip, HUDIcon.Noclip, function()
				flag41 = not flag41

				if flag41 then
					func39()
				else
					func40()
				end

				num15.setActive("Noclip", flag41)
				list2.setToggle(list2.el.noclip, flag41)
			end)

			num15.setActive("Noclip", flag41)
		end,
	}

	local function hudSavedOn(flag)
		-- F$VL OasisUI port: read from THIS ui's config (list2.config.Elements)
		-- instead of the hardcoded old WindUI path. First run = no saved values =
		-- everything off; subsequent runs restore only what the user enabled here.
		local elements = list2.config and list2.config.Elements
		if type(elements) == "table" then
			local entry = elements[flag]
			if type(entry) == "boolean" then return entry end
			if type(entry) == "table" and entry.value ~= nil then return entry.value and true or false end
			if entry ~= nil then return entry and true or false end
		end
		return false
	end

	for flag, name2 in pairs(list2.BTN_GLYPH) do
		if hudSavedOn(flag) and list2.hudSpawns[name2] then
			list2.hudSpawns[name2]()
		end
	end

	num15.relayout()

	task.spawn(function()
		RunService.RenderStepped:Wait()

		pcall(function()
			local main = obj3.UIElements.Main
			local num29

			for k in next, num15.guis, nil do
				local textButton = CoreGui:FindFirstChild("FVL" .. k .. "Button")
				textButton = textButton and textButton:FindFirstChildWhichIsA("TextButton")

				if textButton then
					local n4 = textButton.AbsolutePosition.Y + textButton.AbsoluteSize.Y

					if not num29 or n4 > num29 then
						num29 = n4
					end
				end
			end

			if not num29 then
				return
			end
			local viewportSize = Workspace.CurrentCamera.ViewportSize
			local n4 = math.min(560, viewportSize.Y - 40)
			local n5 = main.AbsolutePosition.Y + main.AbsoluteSize.Y / 2
			local n6 = math.min(num29 + 12 + n4 / 2, viewportSize.Y - n4 / 2 - 8) - n5

			if n6 > 0 then
				local position = main.Position
				main.Position = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset + n6)
			end
		end)
	end)

	local function func124()
		local value156 = BOMB_COOLDOWN
		if tick() - n3 < value156 then
			return
		end
		n3 = tick()

		if num15 then
			num15.startCooldown("Bomb", BOMB_COOLDOWN, "BOMB\nJUMP")
		end
	end

	local function func125()
		for _, item31 in ipairs(tbl34) do
			pcall(function()
				item31:Disconnect()
			end)
		end

		tbl34 = {}

		local function func126(instance5)
			if not instance5 then
				return
			end
			local fakeBomb = instance5:FindFirstChild("FakeBomb")

			if fakeBomb and fakeBomb:IsA("Tool") then
				table.insert(tbl34, fakeBomb.Activated:Connect(func124))
			end

			table.insert(tbl34, instance5.ChildAdded:Connect(function(child)
				if child.Name == "FakeBomb" and child:IsA("Tool") then
					table.insert(tbl34, child.Activated:Connect(func124))
				end
			end))
		end

		func126(localPlayer:FindFirstChild("Backpack"))
		func126(localPlayer.Character)
	end

	func125()

	connection5 = localPlayer.CharacterAdded:Connect(function(character)
		character:WaitForChild("Humanoid")
		task.wait(0.5)
		func125()
	end)

	func120(ICON.mono)

	local function func127()
		local Players_ = game:GetService("Players")
		local ReplicatedStorage_ = game:GetService("ReplicatedStorage")
		game:GetService("InsertService")
		local localPlayer2 = Players_.LocalPlayer

		pcall(function()
			if setthreadidentity then
				setthreadidentity(2)
			end
		end)

		if _G.__MM2Viz and _G.__MM2Viz.destroy then
			pcall(_G.__MM2Viz.destroy)
		end

		local mM2Viz = { conns = {} }
		_G.__MM2Viz = mM2Viz
		local EquipService = require(ReplicatedStorage_:WaitForChild("ClientServices"):WaitForChild("EquipService"))
		local Sync = require(ReplicatedStorage_:WaitForChild("Database"):WaitForChild("Sync"))
		local ProfileData = require(ReplicatedStorage_:WaitForChild("Modules"):WaitForChild("ProfileData"))
		local weapons = Sync.Weapons
		local inventoryDataChanged = ReplicatedStorage_:WaitForChild("Remotes"):WaitForChild("Inventory"):WaitForChild("InventoryDataChanged")

		local function func128(url8)
			local ok, result = pcall(function()
				return game:HttpGet(url8, true)
			end)

			if ok and type(result) == "string" and #result > 0 then
				return result
			end
			local request_ = syn and syn.request or request or http_request or http and http.request
			if not request_ then
				return nil, tostring(result)
			end
			local ok2, result2 = pcall(request_, { Url = url8, Method = "GET" })
			if ok2 and type(result2) == "table" and type(result2.Body) == "string" and #result2.Body > 0 then
				return result2.Body
			end
			return nil, tostring(ok2 and result2 and result2.StatusCode or result2)
		end

		local lua = nil

		if isfile and readfile and isfile("FVLV2/weapon.lua") then
			local ok, result = pcall(readfile, "FVLV2/weapon.lua")

			if ok and type(result) == "string" and #result > 100000 then
				lua = result
			end
		end

		local flag145 = lua ~= nil
		local value157 = nil

		if not lua then
			lua, value157 = func128("https://raw.githubusercontent.com/kroxn/visual/refs/heads/main/weapon.lua")
		end

		if not lua then
			error("[MM2Viz] could not fetch mesh data from " .. "https://raw.githubusercontent.com/kroxn/visual/refs/heads/main/weapon.lua" .. " -- " .. tostring(value157), 0)
		end

		local chunk, value158 = loadstring(lua .. "\nreturn MESHES_FULL")

		if not chunk and flag145 then
			lua = func128("https://raw.githubusercontent.com/kroxn/visual/refs/heads/main/weapon.lua")
			chunk = lua and loadstring(lua .. "\nreturn MESHES_FULL")
			flag145 = false
			value158 = nil
		end

		if not chunk then
			error("[MM2Viz] mesh data failed to compile -- " .. tostring(value158), 0)
		end

		if not flag145 and writefile then
			pcall(function()
				if makefolder and isfolder and not isfolder("FVLV2") then
					makefolder("FVLV2")
				end

				writefile("FVLV2/weapon.lua", lua)
			end)
		end

		local result21 = chunk()

		if type(result21) ~= "table" or next(result21) == nil then
			error("[MM2Viz] fetched file produced no MESHES_FULL table (is the URL the data file?)", 0)
		end

		local tbl51 = {}

		for k, value159 in pairs(result21) do
			tbl51[k] = value159
		end

		local sweetChroma = tbl51.SweetChroma

		if sweetChroma and sweetChroma.Model and not tbl51.Sweet then
			local value160 = nil

			value160 = function(list22)
				local tbl52 = { Class = list22.Class, Id = list22.Id, Name = list22.Name, Props = list22.Props, Tags = list22.Tags }

				if list22.Children then
					tbl52.Children = {}

					for _, child in ipairs(list22.Children) do
						if not (child.Class == "Decal" and child.Name == "Chroma") then
							tbl52.Children[#tbl52.Children + 1] = value160(child)
						end
					end
				end

				return tbl52
			end

			local tbl53 = {}
			local func129 = pairs
			local meta = sweetChroma.Meta or {}

			for k, value161 in func129(meta) do
				tbl53[k] = value161
			end

			tbl53.Chroma = nil
			tbl51.Sweet = { Complete = false, Meta = tbl53, Model = value160(sweetChroma.Model) }
		end

		local tbl54 = { Godly = true, Ancient = true }

		local function func130(flag146)
			local str25 = tostring(flag146 or "")
			return str25 == "" or str25:match("^%?+$") ~= nil
		end

		local tbl55 = {}
		local n4 = 0

		for k, value162 in pairs(tbl51) do
			local entry8 = weapons[k]

			if type(entry8) == "table" and (entry8.ItemType == "Knife" or entry8.ItemType == "Gun") and tbl54[entry8.Rarity] and not func130(entry8.ItemName) then
				tbl55[k] = value162
			else
				n4 += 1
			end
		end

		local tbl56 = tbl55
		local n5 = 0
		local n6 = 0

		for _, value163 in pairs(tbl56) do
			n5 += 1

			if value163.Model then
				n6 += 1
			end
		end

		local RunService_ = game:GetService("RunService")
		local CollectionService_ = game:GetService("CollectionService")

		local function func131(text3)
			if type(text3) == "string" then
				return (text3:gsub("^%s+", ""):gsub("%s+$", ""))
			end
			return text3
		end

		local function func132(tbl57, list23, tbl58)
			for k, value164 in pairs(list23) do
				if not (tbl58 and tbl58[k]) then
					if k == "MeshId" or k == "TextureId" or k == "TextureID" or k == "Texture" then
						value164 = func131(value164)
					end

					pcall(function()
						tbl57[k] = value164
					end)
				end
			end
		end

		local function createPart(param85)
			local value165 = func131(param85.MeshId or "")
			local size = param85.Size or Vector3.one
			local value166 = nil

			pcall(function()
				value166 = game:GetService("InsertService"):CreateMeshPartAsync(value165, Enum.CollisionFidelity.Box, Enum.RenderFidelity.Precise)
			end)

			if value166 then
				pcall(function()
					value166.Size = size
				end)

				return value166
			end

			local part = Instance.new("Part")
			part.Size = size
			local specialMesh = Instance.new("SpecialMesh")
			specialMesh.MeshType = Enum.MeshType.FileMesh

			pcall(function()
				specialMesh.MeshId = value165
			end)

			pcall(function()
				specialMesh.TextureId = func131(param85.TextureID or "")
			end)

			specialMesh.Parent = part
			return part
		end

		local color2 = Color3.fromRGB(255, 0, 0)
		local color3 = Color3.fromRGB(255, 255, 0)
		local color4 = Color3.fromRGB(0, 255, 0)
		local color5 = Color3.fromRGB(0, 255, 255)
		local color6 = Color3.fromRGB(0, 0, 255)
		local color7 = Color3.fromRGB
		local tbl59 = { color2, color3, color4, color5, color6 }

		do
			local values = table.pack(color7(255, 0, 255))
			table.move(values, 1, values.n, 6, tbl59)
		end

		local function func133(num30)
			local n7 = #tbl59
			local n8 = num30 % n7
			local n9 = math.floor(n8)
			return tbl59[n9 + 1]:Lerp(tbl59[(n9 + 1) % n7 + 1], n8 - n9)
		end

		local function func134(obj17, param86)
			if param86.Meta and param86.Meta.Chroma == true then
				return true
			end
			return obj17:sub(-6) == "Chroma"
		end

		local n7 = 1.8

		local function func135(instance6)
			local list24 = {}
			local list25 = {}
			local list26 = {}
			local list27 = {}
			local flag147 = false

			for _, descendant in ipairs(instance6:GetDescendants()) do
				local attribute = descendant:GetAttribute("MM2Chroma")

				if attribute then
					if attribute == "part" then
						list24[#list24 + 1] = descendant
						flag147 = true
					elseif attribute == "decal" and descendant:IsA("Decal") then
						pcall(function()
							descendant.Texture = "rbxassetid://18363392181"
						end)

						list25[#list25 + 1] = descendant
						flag147 = true
					else
						flag147 = true

						if attribute == "fire" then
							list26[#list26 + 1] = descendant
						end
					end
				end
			end

			if not flag147 then
				for _, descendant in ipairs(instance6:GetDescendants()) do
					if descendant:IsA("BasePart") and (descendant.Material == Enum.Material.Neon or descendant.Name:lower():find("light")) then
						list24[#list24 + 1] = descendant
					elseif descendant:IsA("Decal") and descendant.Name:lower():find("chroma") then
						list25[#list25 + 1] = descendant
					elseif descendant:IsA("Fire") then
						list26[#list26 + 1] = descendant
					end
				end

				if #list25 == 0 then
					list26[#list26 + 1] = instance6
				end
			end

			local tbl60 = {}

			for _, item32 in ipairs(list26) do
				if item32:IsA("BasePart") then
					tbl60[item32] = true
				end
			end

			for _, item33 in ipairs(list24) do
				tbl60[item33] = nil
			end

			for _, descendant in ipairs(instance6:GetDescendants()) do
				if descendant:IsA("SpecialMesh") and descendant.TextureId ~= "" and tbl60[descendant.Parent] then
					list27[#list27 + 1] = descendant
				end
			end

			if instance6:IsA("Part") and tbl60[instance6] then
				local specialMesh = instance6:FindFirstChildWhichIsA("SpecialMesh")

				if specialMesh and specialMesh.TextureId ~= "" then
					list27[#list27 + 1] = specialMesh
				end
			end

			if #list24 == 0 and #list25 == 0 and #list26 == 0 and #list27 == 0 then
				return nil
			end

			return RunService_.Heartbeat:Connect(function()
				local now = os.clock()
				local value167 = func133(now)

				for _, item34 in ipairs(list25) do
					item34.Color3 = value167
				end

				for _, item35 in ipairs(list27) do
					item35.VertexColor = Vector3.new(value167.R, value167.G, value167.B)
				end

				for _, item36 in ipairs(list26) do
					if item36:IsA("Fire") then
						item36.Color = value167
					elseif item36:IsA("BasePart") then
						item36.Color = value167
					end
				end

				local n8 = math.floor(now * n7)

				for i, item37 in ipairs(list24) do
					item37.Color = tbl59[(n8 + i - 1) % #tbl59 + 1]
				end
			end)
		end

		local tbl61 = {
			WeldConstraint = true,
			Weld = true,
			Motor6D = true,
			RigidConstraint = true,
			Bone = true,
			Snap = true,
			ManualWeld = true,
			Rotate = true,
			RotateP = true,
			RotateV = true,
		}

		local function func136(obj18, list28)
			if not (obj18 and list28.Tags) then
				return
			end

			for _, tag in ipairs(list28.Tags) do
				local str26 = tag == "ChromaPart" and "part" or tag == "ChromaDecal" and "decal"
				local flag148

				if str26 then
					flag148 = str26
				else
					flag148 = tag == "ChromaFire" and "fire"
				end

				flag148 = flag148 or nil

				if flag148 then
					pcall(function()
						obj18:SetAttribute("MM2Chroma", flag148)
					end)
				end
			end
		end

		local function func137(param87)
			local class = param87.Class
			if tbl61[class] then
				return nil
			end
			local value168

			if class == "MeshPart" then
				value168 = createPart(param87.Props)
				func132(value168, param87.Props, { MeshId = true, Size = true, RelCF = true, CanCollide = true })
			else
				local ok, result = pcall(Instance.new, class)
				if not ok or not result then
					return nil
				end
				value168 = result
				func132(value168, param87.Props, { RelCF = true })
			end

			if param87.Name then
				pcall(function()
					value168.Name = param87.Name
				end)
			end

			func136(value168, param87)
			return value168
		end

		local value169 = nil

		value169 = function(param88, parent, parent2, tbl62, list29, list30)
			local func138 = ipairs
			local children = param88.Children or {}

			for _, child in func138(children) do
				local obj19 = func137(child)

				if obj19 then
					tbl62[child.Id] = obj19

					if obj19:IsA("BasePart") then
						obj19.Anchored = false
						obj19.CanCollide = false
						obj19.CanQuery = false
						obj19.CanTouch = false
						obj19.Massless = true
						list29[#list29 + 1] = { inst = obj19, relcf = child.Props.RelCF }
						obj19.Parent = parent2
						value169(child, obj19, parent2, tbl62, list29, list30)
					elseif obj19:IsA("Attachment") then
						if child.Props.RelCF then
							pcall(function()
								obj19.CFrame = child.Props.RelCF
							end)
						end

						obj19.Parent = parent2
						value169(child, obj19, parent2, tbl62, list29, list30)
					elseif obj19:IsA("Beam") or obj19:IsA("Trail") then
						obj19.Parent = parent
						list30[#list30 + 1] = { inst = obj19, a0 = child.Att0, a1 = child.Att1 }
						value169(child, obj19, parent2, tbl62, list29, list30)
					else
						obj19.Parent = parent
						value169(child, obj19, parent2, tbl62, list29, list30)
					end
				else
					value169(child, parent, parent2, tbl62, list29, list30)
				end
			end
		end

		local function func139(param89)
			local model = param89.Model
			if not model then
				return nil
			end
			local part

			if model.Class == "MeshPart" then
				part = createPart(model.Props)
				func132(part, model.Props, { MeshId = true, Size = true, RelCF = true, CanCollide = true })
			else
				part = Instance.new("Part")
				func132(part, model.Props, { RelCF = true, CanCollide = true })
			end

			if model.Name then
				pcall(function()
					part.Name = model.Name
				end)
			end

			func136(part, model)
			part.Anchored = false
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Massless = true
			local tbl63 = { [model.Id] = part }
			local tbl64 = {}
			local tbl65 = {}
			value169(model, part, part, tbl63, tbl64, tbl65)

			for _, item38 in ipairs(tbl65) do
				if item38.a0 and tbl63[item38.a0] then
					pcall(function()
						item38.inst.Attachment0 = tbl63[item38.a0]
					end)
				end

				if item38.a1 and tbl63[item38.a1] then
					pcall(function()
						item38.inst.Attachment1 = tbl63[item38.a1]
					end)
				end
			end

			return { root = part, parts = tbl64 }
		end

		local function func140(list31, cFrame)
			local root = list31.root

			pcall(function()
				root.CFrame = cFrame
			end)

			for _, part in ipairs(list31.parts) do
				if part.relcf then
					pcall(function()
						part.inst.CFrame = cFrame * part.relcf
					end)
				end

				local weldConstraint = Instance.new("WeldConstraint")
				weldConstraint.Part0 = part.inst
				weldConstraint.Part1 = root
				weldConstraint.Parent = part.inst
			end

			return root
		end

		local tbl66 = {
			ParticleEmitter = true,
			Fire = true,
			Smoke = true,
			Sparkles = true,
			PointLight = true,
			SpotLight = true,
			SurfaceLight = true,
		}

		local function func141(param90)
			local value170 = nil
			local list32 = {}
			local list33 = {}
			local list34 = {}
			local func142 = ipairs
			local display = param90.Display or {}

			for _, value171 in func142(display) do
				if value171.Path == "(root)" then
					value170 = value171
				elseif value171.Class == "SpecialMesh" then
					list32[#list32 + 1] = value171
				elseif value171.Class == "Decal" or value171.Class == "Texture" then
					list33[#list33 + 1] = value171
				elseif tbl66[value171.Class] then
					list34[#list34 + 1] = value171
				end
			end

			if not value170 then
				return nil
			end
			local part

			if value170.Class == "MeshPart" then
				part = createPart(value170.Props)
				func132(part, value170.Props, { MeshId = true, Size = true, CanCollide = true })
			else
				part = Instance.new("Part")
				part.Size = value170.Props.Size or Vector3.one
				func132(part, value170.Props, { Size = true, CanCollide = true })

				for _, item39 in ipairs(list32) do
					local specialMesh = Instance.new("SpecialMesh")
					specialMesh.MeshType = Enum.MeshType.FileMesh
					func132(specialMesh, item39.Props)
					specialMesh.Parent = part
				end
			end

			part.Anchored = false
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Massless = true

			if value170.Name then
				pcall(function()
					part.Name = value170.Name
				end)
			end

			for _, item40 in ipairs(list33) do
				local decal = Instance.new("Decal")
				func132(decal, item40.Props)

				if item40.Name then
					pcall(function()
						decal.Name = item40.Name
					end)
				end

				decal.Parent = part
			end

			for _, item41 in ipairs(list34) do
				local ok, result = pcall(Instance.new, item41.Class)

				if ok and result then
					func132(result, item41.Props)

					if item41.Name then
						pcall(function()
							result.Name = item41.Name
						end)
					end

					result.Parent = part
				end
			end

			return { root = part, parts = {} }
		end

		local function func143(param91)
			if param91.Model then
				return func139(param91)
			end

			if param91.Display then
				return func141(param91)
			end
			return nil
		end

		local function func144(param92)
			if param92.Model then
				local model = param92.Model
				if model.Class == "MeshPart" then
					return func131(model.Props.MeshId or "")
				end
				local func145 = ipairs
				local children = model.Children or {}

				for _, child in func145(children) do
					if child.Class == "SpecialMesh" then
						return func131(child.Props.MeshId or "")
					end
				end

				return ""
			end

			local func146 = ipairs
			local display = param92.Display or {}

			for _, value172 in func146(display) do
				if value172.Path == "(root)" and value172.Class == "MeshPart" then
					return func131(value172.Props.MeshId or "")
				end

				if value172.Class == "SpecialMesh" then
					return func131(value172.Props.MeshId or "")
				end
			end

			return ""
		end

		local function func147(instance7)
			if not instance7 then
				return ""
			end

			if instance7:IsA("MeshPart") then
				return func131(instance7.MeshId or "")
			end
			local specialMesh = instance7:FindFirstChildWhichIsA("SpecialMesh", true)

			if specialMesh then
				specialMesh = func131(specialMesh.MeshId or "")
			end

			return specialMesh or ""
		end

		local cframe = CFrame.identity
		local value173 = nil

		value173 = function(param93)
			local func148 = ipairs
			local children = param93.Children or {}

			for _, child in func148(children) do
				if child.Class == "Attachment" and child.Name == "CustomAttachment" and child.Props and child.Props.RelCF then
					return child.Props.RelCF
				end
				local value174 = value173(child)
				if value174 then
					return value174
				end
			end

			return nil
		end

		local function func149(param94)
			if param94.Model then
				return param94.Model.Props and param94.Model.Props.Size
			end
			local func150 = ipairs
			local display = param94.Display or {}

			for _, value175 in func150(display) do
				if value175.Path == "(root)" then
					return value175.Props and value175.Props.Size
				end
			end

			return nil
		end

		local function func151(flag149)
			if not flag149 then
				return nil
			end
			local tbl67 = { { flag149.X, "X" }, { flag149.Y, "Y" }, { flag149.Z, "Z" } }

			table.sort(tbl67, function(tbl68, tbl69)
				return tbl68[1] > tbl69[1]
			end)

			return tbl67[1][2] .. tbl67[2][2] .. tbl67[3][2]
		end

		local tbl70 = {
			Gun_ZYX = CFrame.new(0.12991, -3e-05, 0.075, 1, 0, 0, 0, 0.70713, 0.70708, 0, -0.70708, 0.70713),
			Gun_ZXY = CFrame.new(0.12991, 0, 0.07501, 2e-05, -0.5, -0.86603, 1, -4e-05, 5e-05, -6e-05, -0.86603, 0.5),
			Gun_XYZ = CFrame.new(-0.22989, 0.09821, 0.1, 1e-05, 0.98481, -0.17362, -1e-05, 0.17362, 0.98481, 1, -1e-05, 1e-05),
			Knife_YXZ = CFrame.new(0, 0, 0, -0.0446, -0.00031, -0.99901, 0.03549, 0.99937, -0.00189, 0.99837, -0.03553, -0.04456),
			Knife_ZYX = CFrame.new(0.00151, -0.12701, -0.15448, -0.99867, 0.03727, 0.03568, -0.04098, -0.15276, -0.98741, -0.03135, -0.98756, 0.15409),
			Knife_ZXY = CFrame.new(0.00151, -0.12701, -0.15448, -0.99867, 0.03727, 0.03568, -0.04098, -0.15276, -0.98741, -0.03135, -0.98756, 0.15409),
		}

		local mM2VizLearned = _G.__MM2VizLearned or {}
		_G.__MM2VizLearned = mM2VizLearned
		local mM2VizOverride = _G.__MM2VizOverride or {}
		_G.__MM2VizOverride = mM2VizOverride
		local mM2VizOverrideGrip = _G.__MM2VizOverrideGrip or {}
		_G.__MM2VizOverrideGrip = mM2VizOverrideGrip

		local function func152(instance8)
			if not instance8 then
				return nil
			end
			return instance8:FindFirstChild("CustomAttachment") or instance8:FindFirstChildWhichIsA("Attachment")
		end

		local function func153(param95)
			local flag150 = func147(param95)
			local value176 = func152(param95)

			if flag150 ~= "" and value176 then
				mM2VizLearned[flag150] = value176.CFrame
			end
		end

		local function func154(param96, param97, param98)
			if mM2VizOverride[param96] then
				return mM2VizOverride[param96]
			end

			if param97.Model then
				return value173(param97.Model) or cframe
			end
			local flag151 = func144(param97)
			if flag151 ~= "" and mM2VizLearned[flag151] then
				return mM2VizLearned[flag151]
			end
			local str27 = func151(func149(param97))
			return str27 and tbl70[(param97.Meta and param97.Meta.ItemType or param98) .. "_" .. str27] or cframe
		end

		local function func155(part9, obj20)
			local flag152 = func152(part9)
			return part9.CFrame * (flag152 and flag152.CFrame or cframe) * obj20:Inverse()
		end

		local function func156(list35, instance9)
			if instance9:IsA("BasePart") or instance9:IsA("Decal") then
				list35[#list35 + 1] = { inst = instance9, prop = "Transparency", val = instance9.Transparency }

				pcall(function()
					instance9.Transparency = 1
				end)
			elseif instance9:IsA("ParticleEmitter") or instance9:IsA("Trail") or instance9:IsA("Beam") or instance9:IsA("Fire") or instance9:IsA("Smoke") or instance9:IsA("Sparkles") then
				list35[#list35 + 1] = { inst = instance9, prop = "Enabled", val = instance9.Enabled }

				pcall(function()
					instance9.Enabled = false
				end)
			end
		end

		local function func157(list36)
			for _, item42 in ipairs(list36) do
				pcall(function()
					item42.inst[item42.prop] = item42.val
				end)
			end
		end

		local function func158(list37)
			local list38 = {}

			for _, item43 in ipairs(list37) do
				local inst = item43.inst
				local prop = item43.prop

				list38[#list38 + 1] = inst:GetPropertyChangedSignal(prop):Connect(function()
					if prop == "Enabled" then
						if inst.Enabled then
							inst.Enabled = false
						end
					elseif inst.Transparency ~= 1 then
						inst.Transparency = 1
					end
				end)
			end

			return list38
		end

		local function func159(flag153)
			local func160 = ipairs
			local tbl71 = flag153 or {}

			for _, value177 in func160(tbl71) do
				pcall(function()
					value177:Disconnect()
				end)
			end
		end

		local function func161()
			return localPlayer2.Character
		end

		local function func162(str28)
			local result22 = func161()
			if not result22 then
				return nil
			end
			local flag154 = result22:FindFirstChild("DisplayRef" .. str28)
			return flag154 and flag154.Value or nil
		end

		local function func163(param99, flag155)
			local n8 = os.clock() + (flag155 or 1)

			while os.clock() < n8 do
				local value178 = func162(param99)
				if value178 then
					return value178
				end
				task.wait(0.05)
			end

			return func162(param99)
		end

		local tbl72 = {}
		local tbl73 = {}
		local tbl74 = {}
		local value179 = nil

		local function func164(param100, flag156)
			local weaponDisplays = workspace:FindFirstChild("WeaponDisplays")
			if not weaponDisplays then
				return
			end

			for _, child in ipairs(weaponDisplays:GetChildren()) do
				if child ~= flag156 and child:GetAttribute("MM2VizSlot") == param100 then
					pcall(function()
						child:Destroy()
					end)
				end
			end
		end

		local function func165(param101)
			func164(param101)
			local entry9 = tbl72[param101]
			if not entry9 then
				return
			end

			if entry9.chroma then
				pcall(function()
					entry9.chroma:Disconnect()
				end)
			end

			if entry9.overlay then
				pcall(function()
					entry9.overlay:Destroy()
				end)
			end

			func157(entry9.hidden)
			tbl72[param101] = nil
		end

		local function func166(str29, str30)
			if tbl72[str29] and tbl73[str29] == str30 and str30 ~= nil then
				return
			end
			tbl74[str29] = (tbl74[str29] or 0) + 1
			local entry10 = tbl74[str29]
			func165(str29)
			local flag157 = str30 and tbl56[str30]
			if not flag157 then
				tbl73[str29] = str30
				return
			end
			tbl73[str29] = str30
			local obj21 = func162(str29) or func163(str29, 1.5)
			if tbl74[str29] ~= entry10 then
				return
			end

			if not obj21 then
				if value179 then
					value179("No " .. str29 .. " shown — equip a normal " .. str29 .. " first.", Color3.fromRGB(240, 200, 120))
				end

				return
			end

			func153(obj21)
			if func147(obj21) == func144(flag157) and func147(obj21) ~= "" then
				return
			end
			local value180 = func154(str30, flag157, str29)
			local tbl75 = {}
			func156(tbl75, obj21)

			for _, descendant in ipairs(obj21:GetDescendants()) do
				func156(tbl75, descendant)
			end

			local flag158 = func143(flag157)

			if not flag158 or not flag158.root or tbl74[str29] ~= entry10 or not obj21.Parent then
				func157(tbl75)

				if flag158 and flag158.root then
					flag158.root:Destroy()
				end

				return
			end

			func140(flag158, func155(obj21, value180))
			local root = flag158.root
			root:SetAttribute("MM2VizOverlay", true)
			root:SetAttribute("MM2VizSlot", str29)
			root.Parent = obj21.Parent or obj21
			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Part0 = root
			weldConstraint.Part1 = obj21
			weldConstraint.Parent = root
			local value181 = func134(str30, flag157) and func135(root) or nil
			func164(str29, root)
			tbl72[str29] = { overlay = root, hidden = tbl75, chroma = value181 }

			if value179 then
				value179("Showing: " .. str30 .. " (" .. str29 .. ")", Color3.fromRGB(150, 230, 170))
			end
		end

		local tbl76 = { X = Vector3.new(1, 0, 0), Y = Vector3.new(0, 1, 0), Z = Vector3.new(0, 0, 1) }

		local function func167(param102)
			local tbl77 = { { param102.X, "X" }, { param102.Y, "Y" }, { param102.Z, "Z" } }

			table.sort(tbl77, function(tbl78, tbl79)
				return tbl78[1] > tbl79[1]
			end)

			return tbl77[1][2], tbl77[2][2], tbl77[3][2]
		end

		local tbl80 = {
			Gun = { Vector3.new(0, 0, 1), Vector3.new(0, 1, 0), Vector3.new(-1, 0, 0) },
			Knife = { Vector3.new(0, 1, 0), Vector3.new(0, 0, 1), Vector3.new(1, 0, 0) },
		}

		local tbl81 = {
			Harvester = CFrame.Angles(0, 0, -1.5707963267948966),
			Icepiercer = CFrame.Angles(0, 0, -1.5707963267948966),
		}

		local tbl82 = { Sweet = true, SweetChroma = true }
		local tbl83 = { Harvester = 0.5, Icepiercer = 0.5 }

		local function func168(param103, num31, param104, param105)
			if num31 and tbl82[num31] then
				return cframe
			end
			local flag159 = func149(param104)
			local entry11 = tbl80[param105]
			if not (flag159 and entry11) then
				return cframe
			end
			local value182, value183, value184 = func167(flag159)
			local tbl84 = { [value182] = entry11[1], [value183] = entry11[2], [value184] = entry11[3] }

			if tbl76[value182]:Cross(tbl76[value183]):Dot(tbl76[value184]) < 0 then
				tbl84[value184] = -tbl84[value184]
			end

			local x = tbl84.X
			local y = tbl84.Y
			local z = tbl84.Z
			local n8 = param103.Grip.Rotation * CFrame.fromMatrix(Vector3.new(), x, y, z)
			local value185 = num31 and tbl81[num31]

			if value185 then
				n8 *= value185
			end

			num31 = num31 and tbl83[num31]

			if num31 then
				n8 *= CFrame.new(tbl76[value182] * num31)
			end

			return n8
		end

		local function func169(param106, param107)
			local flag160 = func149(param107)
			if not flag160 then
				return cframe
			end
			local value186, value187, value188 = func167(flag160)
			local value189, value190, value191 = func167(param106)
			local tbl85 = { [value186] = tbl76[value189], [value187] = tbl76[value190], [value188] = tbl76[value191] }

			if tbl76[value186]:Cross(tbl76[value187]):Dot(tbl76[value188]) ~= tbl76[value189]:Cross(tbl76[value190]):Dot(tbl76[value191]) then
				tbl85[value188] = -tbl85[value188]
			end

			local x = tbl85.X
			local y = tbl85.Y
			local z = tbl85.Z
			return CFrame.fromMatrix(Vector3.new(), x, y, z)
		end

		local function func170(text4)
			if not text4 then
				return nil
			end
			return text4:match("^(.-)Chroma$") or text4:match("^Chroma(.+)$")
		end

		local function func171(param108, param109)
			local flag161 = func170(param108)
			local meta = flag161 and tbl56[flag161] and tbl56[flag161].Meta or param109.Meta
			if not meta then
				return nil
			end

			if meta.ItemID then
				return ("rbxthumb://type=Asset&w=150&h=150&id=%d"):format(meta.ItemID)
			end
			return meta.Image
		end

		local obj = setmetatable({}, { __mode = "k" })

		local function func172(param110)
			local entry12 = obj[param110]
			if entry12 and entry12.Parent then
				return entry12
			end
			local playerGui = localPlayer2:FindFirstChild("PlayerGui")
			playerGui = playerGui and playerGui:FindFirstChild("BackpackUI")
			playerGui = playerGui and playerGui:FindFirstChild("BackpackFrame")
			if not playerGui then
				return nil
			end

			for _, child in ipairs(playerGui:GetChildren()) do
				local container = child:IsA("GuiObject") and child:FindFirstChild("Container")
				local nameLabel = container and container:FindFirstChild("NameLabel")

				if nameLabel and container:FindFirstChild("ToolIcon") then
					local name = child.Name
					local text = nameLabel.Text
					child.Name = name .. " "
					task.wait()
					local text2 = nameLabel.Text
					child.Name = name
					task.wait()
					nameLabel.Text = text
					if text2 == param110.Name then
						obj[param110] = container
						return container
					end
				end
			end

			return nil
		end

		local function func173(param111, image)
			task.spawn(function()
				local obj22 = func172(param111)
				if not obj22 then
					return
				end
				local toolIcon = obj22:FindFirstChild("ToolIcon")

				if toolIcon then
					toolIcon.Image = image
				end

				local nameLabel = obj22:FindFirstChild("NameLabel")

				if nameLabel then
					nameLabel.Text = image == "" and param111.Name or ""
				end
			end)
		end

		local function func174(param112, textureId)
			if not textureId or textureId == "" then
				return nil
			end
			local textureId2 = param112.TextureId
			param112.TextureId = textureId
			func173(param112, textureId)
			return textureId2
		end

		local function func175(param113, textureId)
			if not textureId then
				return
			end

			pcall(function()
				param113.TextureId = textureId
			end)

			func173(param113, textureId)
		end

		local tbl86 = {
			Harvester = "rbxassetid://7808472682",
			Icepiercer = "rbxassetid://7808472682",
			Raygun = "rbxassetid://92066070356304",
			RaygunChroma = "rbxassetid://92066070356304",
			Snowcannon = "rbxassetid://136161856273464",
			SnowcannonChroma = "rbxassetid://136161856273464",
			Gingerscope = "rbxassetid://74240492893421",
		}

		local mM2VizSounds = _G.__MM2VizSounds or {}
		_G.__MM2VizSounds = mM2VizSounds

		local function func176()
			for _, player in ipairs(Players_:GetPlayers()) do
				for _, item44 in ipairs({ player.Character, player:FindFirstChild("Backpack") }) do
					local func177 = ipairs
					item44 = item44 and item44:GetChildren() or {}

					for _, value192 in func177(item44) do
						local attribute = value192:IsA("Tool") and value192:GetAttribute("ItemID")
						local handle = attribute and value192:FindFirstChild("Handle")
						handle = handle and handle:FindFirstChild("AltSound")

						if handle and handle:IsA("Sound") and handle.SoundId ~= "" and mM2VizSounds[attribute] ~= handle.SoundId then
							mM2VizSounds[attribute] = handle.SoundId
							print(("learned shot sound -- SHOT_SOUND[%q] = %q"):format(attribute, handle.SoundId))
						end
					end
				end
			end
		end

		local function func178(instance10, param114)
			local flag162 = tbl86[param114] or mM2VizSounds[param114]
			local handle = flag162 and instance10:FindFirstChild("Handle")
			handle = handle and handle:FindFirstChild("Gunshot")
			if not (handle and handle:IsA("Sound")) then
				return nil
			end
			local soundId = handle.SoundId
			handle.SoundId = flag162
			return { sound = handle, old = soundId }
		end

		local function func179(flag163)
			if flag163 and flag163.sound then
				pcall(function()
					flag163.sound.SoundId = flag163.old
				end)
			end
		end

		local tbl87 = {}

		local function func180(obj23)
			if obj23:IsDescendantOf(localPlayer2) then
				return true
			end
			local result23 = func161()
			return result23 ~= nil and obj23:IsDescendantOf(result23)
		end

		local function func181(instance11, param115)
			if tbl87[instance11] then
				return
			end
			local handle = instance11:FindFirstChild("Handle") or instance11:WaitForChild("Handle", 5)
			if not handle then
				return
			end
			local flag164 = ProfileData.Weapons.Equipped[param115]
			local flag165 = flag164 and tbl56[flag164]
			if not flag165 then
				return
			end
			func153(handle)
			local flag166 = func143(flag165)
			if not flag166 or not flag166.root then
				return
			end
			local tbl88 = {}
			func156(tbl88, handle)

			for _, descendant in ipairs(handle:GetDescendants()) do
				func156(tbl88, descendant)
			end

			func140(flag166, handle.CFrame * (mM2VizOverrideGrip[flag164] or func168(instance11, flag164, flag165, param115)))
			local root = flag166.root
			root.Parent = handle
			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Part0 = root
			weldConstraint.Part1 = handle
			weldConstraint.Parent = root
			local value193 = func134(flag164, flag165) and func135(root) or nil
			root:SetAttribute("MM2VizOverlay", true)

			tbl87[instance11] = {
				overlay = root,
				hidden = tbl88,
				chroma = value193,
				icon = func174(instance11, func171(flag164, flag165)),
				skin = flag164,
				guards = func158(tbl88),
				shot = func178(instance11, flag164),
			}
		end

		local function func182(flag167)
			local list39 = {}
			local func183 = ipairs
			local value194 = CollectionService_
			local getTagged = value194.GetTagged
			local str31 = flag167 == "Gun" and "Weapon_Gun" or "Weapon_Knife"

			for _, value195 in func183(getTagged(value194, str31)) do
				if func180(value195) then
					list39[#list39 + 1] = value195
				end
			end

			return list39
		end

		local function func184(param116)
			local entry13 = tbl87[param116]
			if not entry13 then
				return
			end

			if entry13.chroma then
				pcall(function()
					entry13.chroma:Disconnect()
				end)
			end

			if entry13.overlay then
				pcall(function()
					entry13.overlay:Destroy()
				end)
			end

			pcall(func175, param116, entry13.icon)
			func179(entry13.shot)
			func159(entry13.guards)
			func157(entry13.hidden)
			tbl87[param116] = nil
		end

		local mM2VizBaseline = _G.__MM2VizBaseline

		if not mM2VizBaseline then
			mM2VizBaseline = {}

			for k, value196 in pairs(ProfileData.Weapons.Owned) do
				mM2VizBaseline[k] = value196
			end

			_G.__MM2VizBaseline = mM2VizBaseline
		end

		local mM2VizBaselineEq = _G.__MM2VizBaselineEq

		if not mM2VizBaselineEq then
			mM2VizBaselineEq = { Knife = ProfileData.Weapons.Equipped.Knife, Gun = ProfileData.Weapons.Equipped.Gun }
			_G.__MM2VizBaselineEq = mM2VizBaselineEq
		end

		local function spawn(param117, flag168)
			local n8 = flag168 or 1
			local owned = ProfileData.Weapons.Owned
			owned[param117] = (owned[param117] or 0) + n8

			pcall(function()
				inventoryDataChanged:Fire("Weapons", param117, owned[param117])
			end)
		end

		local function despawnAll()
			local owned = ProfileData.Weapons.Owned
			local n8 = 0

			for k in pairs(tbl56) do
				local entry14 = mM2VizBaseline[k]

				if owned[k] ~= entry14 then
					owned[k] = entry14

					pcall(function()
						inventoryDataChanged:Fire("Weapons", k, owned[k] or 0)
					end)

					n8 += 1
				end
			end

			for _, item45 in ipairs({ "Knife", "Gun" }) do
				local flag169 = ProfileData.Weapons.Equipped[item45]

				if flag169 and owned[flag169] == nil then
					local entry15 = mM2VizBaselineEq[item45]

					if not (entry15 and owned[entry15]) then
						entry15 = nil

						for k in pairs(owned) do
							local entry16 = weapons[k]
							if type(entry16) == "table" and entry16.ItemType == item45 then
								entry15 = k
								break
							end
						end
					end

					if not entry15 then
						entry15 = item45 == "Knife" and "DefaultKnife" or "DefaultGun"
					end

					ProfileData.Weapons.Equipped[item45] = entry15

					pcall(function()
						EquipService.EquippedChanged:Fire(item45, entry15)
					end)
				end
			end

			return n8
		end

		local list = {}

		for k in pairs(tbl56) do
			local entry17 = weapons[k]

			list[#list + 1] = {
				key = k,
				name = type(entry17) == "table" and entry17.ItemName or k,
				type = type(entry17) == "table" and entry17.ItemType or "",
				rarity = type(entry17) == "table" and entry17.Rarity or "",
				chroma = func134(k, tbl56[k]),
			}
		end

		table.sort(list, function(param118, param119)
			if param118.type ~= param119.type then
				return param118.type < param119.type
			end

			if param118.rarity ~= param119.rarity then
				return param118.rarity < param119.rarity
			end
			return param118.name:lower() < param119.name:lower()
		end)

		local value197 = nil
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "MM2Spawner"
		screenGui.ResetOnSpawn = false
		screenGui.IgnoreGuiInset = true
		screenGui.DisplayOrder = 999999

		pcall(function()
			screenGui.Parent = gethui and gethui() or game:GetService("CoreGui")
		end)

		if not screenGui.Parent then
			screenGui.Parent = localPlayer2:WaitForChild("PlayerGui")
		end

		mM2Viz.gui = screenGui
		local frame = Instance.new("Frame")
		frame.Size = UDim2.fromOffset(290, 420)
		frame.Position = list2.hudStart("__spawner", UDim2.new(0, 20, 0.5, -210))
		frame.BackgroundColor3 = Color3.fromRGB(20, 20, 27)
		frame.BorderSizePixel = 0
		frame.Active = true
		frame.Draggable = true
		frame.Parent = screenGui
		list2.hudBtns["__spawner"] = frame
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
		local uiStroke = Instance.new("UIStroke", frame)
		uiStroke.Color = Color3.fromRGB(120, 90, 230)
		uiStroke.Thickness = 1.5
		local textButton = Instance.new("TextButton")
		textButton.Size = UDim2.new(0.5, -14, 0, 26)
		textButton.Position = UDim2.fromOffset(12, 10)
		textButton.BackgroundColor3 = Color3.fromRGB(60, 95, 70)
		textButton.BorderSizePixel = 0
		textButton.Font = Enum.Font.GothamBold
		textButton.TextSize = 12
		textButton.TextColor3 = Color3.fromRGB(200, 255, 215)
		textButton.Text = "Spawn all"
		textButton.Parent = frame
		Instance.new("UICorner", textButton).CornerRadius = UDim.new(0, 6)
		local textButton2 = Instance.new("TextButton")
		textButton2.Size = UDim2.new(0.5, -14, 0, 26)
		textButton2.Position = UDim2.new(0.5, 2, 0, 10)
		textButton2.BackgroundColor3 = Color3.fromRGB(95, 60, 70)
		textButton2.BorderSizePixel = 0
		textButton2.Font = Enum.Font.GothamBold
		textButton2.TextSize = 12
		textButton2.TextColor3 = Color3.fromRGB(255, 205, 215)
		textButton2.Text = "Despawn all"
		textButton2.Parent = frame
		Instance.new("UICorner", textButton2).CornerRadius = UDim.new(0, 6)
		local scrollingFrame = Instance.new("ScrollingFrame")
		scrollingFrame.Size = UDim2.new(1, -20, 1, -56)
		scrollingFrame.Position = UDim2.fromOffset(10, 46)
		scrollingFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 19)
		scrollingFrame.BackgroundTransparency = 0.3
		scrollingFrame.BorderSizePixel = 0
		scrollingFrame.ScrollBarThickness = 6
		scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(120, 90, 230)
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
		scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scrollingFrame.Parent = frame
		Instance.new("UICorner", scrollingFrame).CornerRadius = UDim.new(0, 6)
		local uiListLayout = Instance.new("UIListLayout")
		uiListLayout.Padding = UDim.new(0, 2)
		uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout.Parent = scrollingFrame
		local uiPadding = Instance.new("UIPadding")
		uiPadding.PaddingTop = UDim.new(0, 3)
		uiPadding.PaddingBottom = UDim.new(0, 3)
		uiPadding.PaddingLeft = UDim.new(0, 3)
		uiPadding.PaddingRight = UDim.new(0, 3)
		uiPadding.Parent = scrollingFrame

		local function func185()
		end

		local tbl89 = { Godly = Color3.fromRGB(255, 110, 190), Ancient = Color3.fromRGB(165, 95, 245) }
		local flag170 = false
		local list40 = {}

		local function func186()
			if flag170 then
				return
			end
			flag170 = true

			task.spawn(function()
				for i, item46 in ipairs(list) do
					local textButton3 = Instance.new("TextButton")
					textButton3.Size = UDim2.new(1, -6, 0, 24)
					textButton3.BackgroundColor3 = item46.type == "Knife" and Color3.fromRGB(48, 44, 70) or Color3.fromRGB(44, 56, 72)
					textButton3.BackgroundTransparency = 0.25
					textButton3.Font = Enum.Font.Gotham
					textButton3.TextSize = 12
					textButton3.TextColor3 = Color3.fromRGB(235, 235, 245)
					textButton3.TextXAlignment = Enum.TextXAlignment.Left
					textButton3.TextTruncate = Enum.TextTruncate.AtEnd
					textButton3.Text = "  " .. item46.name .. (item46.chroma and "  [Chroma]" or "") .. "   -  " .. item46.rarity .. " " .. item46.type
					textButton3.LayoutOrder = i
					textButton3.Parent = scrollingFrame
					Instance.new("UICorner", textButton3).CornerRadius = UDim.new(0, 4)
					local uiStroke2 = Instance.new("UIStroke", textButton3)
					uiStroke2.Color = tbl89[item46.rarity] or Color3.fromRGB(90, 90, 110)
					uiStroke2.Thickness = 1.4
					uiStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					local key = item46.key

					textButton3.MouseButton1Click:Connect(function()
						spawn(key, 1)
						func185(key)
						local backgroundColor3 = textButton3.BackgroundColor3
						textButton3.BackgroundColor3 = Color3.fromRGB(0, 150, 100)

						task.delay(0.18, function()
							if textButton3.Parent then
								textButton3.BackgroundColor3 = backgroundColor3
							end
						end)
					end)

					list40[#list40 + 1] = { btn = textButton3, hay = (item46.key .. " " .. item46.name):lower() }

					if i % 60 == 0 then
						task.wait()
					end
				end
			end)
		end

		func186()

		textButton.MouseButton1Click:Connect(function()
			if textButton.Text ~= "Spawn all" then
				return
			end
			textButton.Text = "..."

			task.spawn(function()
				for i, item47 in ipairs(list) do
					spawn(item47.key, 1)

					if i % 25 == 0 then
						task.wait()
					end
				end

				textButton.Text = "Spawn all"
			end)
		end)

		textButton2.MouseButton1Click:Connect(function()
			if textButton2.Text ~= "Despawn all" then
				return
			end
			textButton2.Text = "..."

			task.spawn(function()
				despawnAll()
				textButton2.Text = "Despawn all"
			end)
		end)

		value179 = function(text, textColor3)
			if value197 then
				value197.Text = text
				value197.TextColor3 = textColor3 or Color3.fromRGB(190, 190, 205)
			end
		end

		local tbl90 = { Knife = nil, Gun = nil }

		pcall(function()
			tbl90.Knife = ProfileData.Weapons.Equipped.Knife
			tbl90.Gun = ProfileData.Weapons.Equipped.Gun
		end)

		task.spawn(function()
			for _, item48 in ipairs({ "Knife", "Gun" }) do
				local value198 = ProfileData.Weapons.Equipped[item48]

				if value198 then
					task.spawn(function()
						func166(item48, value198)
					end)
				end
			end

			while _G.__MM2Viz == mM2Viz do
				for _, item49 in ipairs({ "Knife", "Gun" }) do
					local value199 = nil

					pcall(function()
						value199 = ProfileData.Weapons.Equipped[item49]
					end)

					if value199 ~= tbl90[item49] then
						tbl90[item49] = value199
						local value200 = value199

						task.spawn(function()
							func166(item49, value200)
						end)

						for _, item50 in ipairs(func182(item49)) do
							task.spawn(function()
								func184(item50)
								func181(item50, item49)
							end)
						end
					end
				end

				task.wait(0.1)
			end
		end)

		local connection6 = EquipService.EquippedChanged.Event:Connect(function(flag171, param120)
			if flag171 == "Knife" or flag171 == "Gun" then
				tbl90[flag171] = param120

				task.spawn(function()
					func166(flag171, param120)
				end)
			end
		end)

		table.insert(mM2Viz.conns, connection6)

		local function func187(param121)
			local connection7 = param121.ChildAdded:Connect(function(child)
				local name = child.Name

				if name == "DisplayRefKnife" or name == "DisplayRefGun" then
					local str32 = name == "DisplayRefKnife" and "Knife" or "Gun"

					task.delay(0.2, function()
						local value201 = tbl72[str32] and tbl73[str32]

						if value201 then
							tbl72[str32] = nil
							func166(str32, value201)
						end
					end)
				end
			end)

			table.insert(mM2Viz.conns, connection7)
		end

		if func161() then
			local result24 = func161()
			func187(result24)
		end

		local connection7 = localPlayer2.CharacterAdded:Connect(function(character)
			for _, item51 in ipairs({ "Knife", "Gun" }) do
				local entry18 = tbl72[item51]

				if entry18 and entry18.overlay then
					pcall(function()
						entry18.overlay:Destroy()
					end)
				end
			end

			tbl72 = {}
			func187(character)

			task.delay(1, function()
				for _, item52 in ipairs({ "Knife", "Gun" }) do
					if tbl73[item52] then
						func166(item52, tbl73[item52])
					end
				end
			end)
		end)

		table.insert(mM2Viz.conns, connection7)

		for _, item53 in ipairs({ "Weapon_Knife", "Weapon_Gun" }) do
			local str33 = item53 == "Weapon_Gun" and "Gun" or "Knife"

			for _, item54 in ipairs(CollectionService_:GetTagged(item53)) do
				if func180(item54) then
					task.spawn(function()
						func181(item54, str33)
					end)
				end
			end

			table.insert(mM2Viz.conns, CollectionService_:GetInstanceAddedSignal(item53):Connect(function(param122)
				if func180(param122) then
					task.spawn(function()
						func181(param122, str33)
					end)
				end
			end))

			table.insert(mM2Viz.conns, CollectionService_:GetInstanceRemovedSignal(item53):Connect(function(param123)
				func184(param123)
			end))
		end

		local function func188(obj24)
			local knifeVisual = obj24:WaitForChild("KnifeVisual", 5)
			if not knifeVisual then
				return
			end
			local value202 = nil

			for _, descendant in ipairs(knifeVisual:GetDescendants()) do
				if descendant:GetAttribute("MM2VizOverlay") then
					value202 = descendant
					break
				else
					value202 = nil
				end
			end

			if not value202 then
				return
			end
			local tbl91 = {}
			func156(tbl91, knifeVisual)

			for _, descendant in ipairs(knifeVisual:GetDescendants()) do
				if descendant ~= value202 and not descendant:IsDescendantOf(value202) then
					func156(tbl91, descendant)
				end
			end
		end

		table.insert(mM2Viz.conns, CollectionService_:GetInstanceAddedSignal("ThrowingKnife"):Connect(function(param124)
			task.spawn(func188, param124)
		end))

		local tbl92 = {}

		local function func189()
			local result25 = func161()

			for _, item55 in ipairs(CollectionService_:GetTagged("Weapon_Knife")) do
				if item55:IsDescendantOf(localPlayer2) or result25 and item55:IsDescendantOf(result25) then
					return true
				end
			end

			return false
		end

		local function func190(param125)
			local entry19 = tbl92[param125]
			if not entry19 then
				return
			end
			tbl92[param125] = nil

			if entry19.chroma then
				pcall(function()
					entry19.chroma:Disconnect()
				end)
			end

			func159(entry19.guards)

			if entry19.overlay then
				pcall(function()
					entry19.overlay:Destroy()
				end)
			end
		end

		local function func191(parent)
			if tbl92[parent] or not func189() then
				return
			end
			local knife = ProfileData.Weapons.Equipped.Knife
			local flag172 = knife and tbl56[knife]
			if not flag172 then
				return
			end
			tbl92[parent] = {}
			local flag173 = func143(flag172)

			if not flag173 or not flag173.root or not parent.Parent then
				if flag173 and flag173.root then
					flag173.root:Destroy()
				end

				tbl92[parent] = nil
				return
			end

			local tbl93 = {}
			func156(tbl93, parent)

			for _, descendant in ipairs(parent:GetDescendants()) do
				func156(tbl93, descendant)
			end

			func140(flag173, parent.CFrame * func169(parent.Size, flag172))
			local root = flag173.root
			root.Parent = parent
			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Part0 = root
			weldConstraint.Part1 = parent
			weldConstraint.Parent = root
			tbl92[parent] = { overlay = root, chroma = func134(knife, flag172) and func135(root) or nil, guards = func158(tbl93) }

			parent.Destroying:Once(function()
				func190(parent)
			end)
		end

		local function func192(child)
			if child:IsA("BasePart") and child.Name == "StuckKnife" then
				task.spawn(func191, child)
			end
		end

		for _, child in ipairs(workspace:GetChildren()) do
			func192(child)
		end

		table.insert(mM2Viz.conns, workspace.ChildAdded:Connect(func192))

		task.spawn(function()
			while _G.__MM2Viz == mM2Viz do
				pcall(func176)
				task.wait(2)
			end
		end)

		mM2Viz.tune = function(param126, flag174, flag175, flag176)
			local entry20 = tbl73[param126]
			local flag177 = entry20 and tbl56[entry20]
			if not flag177 then
				warn("nothing applied on " .. tostring(param126))
				return
			end
			local n8 = (mM2VizOverride[entry20] or func154(entry20, flag177, param126)) * CFrame.Angles(flag174 or 0, flag175 or 0, flag176 or 0)
			mM2VizOverride[entry20] = n8
			local tbl94 = { n8:GetComponents() }

			for i, item56 in ipairs(tbl94) do
				tbl94[i] = string.format("%.5f", item56)
			end

			print(("OVERRIDE[%q] = CFrame.new(%s)"):format(entry20, table.concat(tbl94, ", ")))

			task.spawn(function()
				tbl73[param126] = nil
				func166(param126, entry20)
			end)
		end

		mM2Viz.tuneGrip = function(param127, flag178, flag179, flag180)
			local value203 = nil

			for k in pairs(tbl87) do
				if (CollectionService_:HasTag(k, "Weapon_Gun") and "Gun" or "Knife") == param127 then
					value203 = k
				end
			end

			local flag181 = value203 and tbl87[value203]
			local flag182 = flag181 and tbl56[flag181.skin]
			if not flag182 then
				warn("not holding a " .. tostring(param127))
				return
			end
			local n8 = (mM2VizOverrideGrip[flag181.skin] or func168(value203, flag181.skin, flag182, param127)) * CFrame.Angles(flag178 or 0, flag179 or 0, flag180 or 0)
			mM2VizOverrideGrip[flag181.skin] = n8
			local tbl95 = { n8:GetComponents() }

			for i, item57 in ipairs(tbl95) do
				tbl95[i] = string.format("%.5f", item57)
			end

			print(("OVERRIDE_GRIP[%q] = CFrame.new(%s)"):format(flag181.skin, table.concat(tbl95, ", ")))

			task.spawn(function()
				func184(value203)
				func181(value203, param127)
			end)
		end

		mM2Viz.nudge = function(param128, flag183)
			local value204 = nil

			for k in pairs(tbl87) do
				if (CollectionService_:HasTag(k, "Weapon_Gun") and "Gun" or "Knife") == param128 then
					value204 = k
				end
			end

			local flag184 = value204 and tbl87[value204]
			if not flag184 then
				warn("not holding a " .. tostring(param128))
				return
			end
			tbl83[flag184.skin] = (tbl83[flag184.skin] or 0) + (flag183 or 0)
			print(("GRIP_NUDGE[%q] = %.2f"):format(flag184.skin, tbl83[flag184.skin]))

			task.spawn(function()
				func184(value204)
				func181(value204, param128)
			end)
		end

		mM2Viz.spawn = spawn
		mM2Viz.despawnAll = despawnAll
		mM2Viz.list = list

		mM2Viz.icon = function(param129)
			local entry21 = tbl56[param129]
			return entry21 and func171(param129, entry21) or nil
		end

		mM2Viz.destroy = function()
			for _, conn in ipairs(mM2Viz.conns) do
				pcall(function()
					conn:Disconnect()
				end)
			end

			for k in pairs(tbl72) do
				pcall(func165, k)
			end

			for k in pairs(tbl87) do
				pcall(func184, k)
			end

			for k in pairs(tbl92) do
				pcall(func190, k)
			end

			if mM2Viz.gui then
				pcall(function()
					mM2Viz.gui:Destroy()
				end)
			end
		end

		value179(("Ready — %d weapons (%d full). Spawn + equip; works in-round too."):format(n5, n6))
		return _G.__MM2Viz
	end

	tbl43.skins:Paragraph({
		Title = "Visual Skin Changer — ONLY YOU CAN SEE THIS!",
		Desc = "Beta - expect the odd bug while holding items. Report them in our YouTube comments.",
	})

	local value205 = nil
	local weapons = nil

	tbl43.skins:Button({
		Title = "Spawn all visual skins",
		Callback = function()
			if not value205 then
				obj2:Notify({
					Title = "Skins",
					Content = "Still loading, try again in a second.",
					Duration = 2,
					Icon = "loader",
				})

				return
			end

			task.spawn(function()
				for _, item58 in ipairs(value205.list) do
					pcall(value205.spawn, item58.key, 1)
				end

				obj2:Notify({ Title = "Skins", Content = ("Spawned %d skins."):format(#value205.list), Duration = 2, Icon = "check" })
			end)
		end,
	})

	tbl43.skins:Button({
		Title = "Despawn all visual skins",
		Callback = function()
			if not value205 then
				return
			end
			pcall(value205.despawnAll)
			obj2:Notify({ Title = "Skins", Content = "Despawned.", Duration = 2, Icon = "check" })
		end,
	})

	local color2 = Color3.fromRGB
	func118("Spawn all visual skins", Color3.fromHex("#D9D9E0"), 0.25, color2(24, 24, 27))
	local color3 = Color3.fromRGB
	func118("Despawn all visual skins", Color3.fromHex("#2A2A32"), 0.25, color3(187, 247, 208))
	local obj25 = tbl43.skins:Paragraph({ Title = "Skins", Desc = "Loading…" })
	local list41 = {}

	local function func193()
		local flag185 = func119(obj25)
		if not flag185 then
			warn("[FVL] couldn't reach the Paragraph container - skin grid skipped")
			return
		end
		local frame = Instance.new("Frame")
		frame.Name = "FVLSkinSearch"
		frame.LayoutOrder = -1
		frame.Size = UDim2.new(1, 0, 0, 30)
		frame.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
		frame.BackgroundTransparency = 0.25
		frame.BorderSizePixel = 0
		frame.Parent = flag185
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
		local textBox = Instance.new("TextBox")
		textBox.BackgroundTransparency = 1
		textBox.Size = UDim2.new(1, -18, 1, 0)
		textBox.Position = UDim2.fromOffset(9, 0)
		textBox.Font = Enum.Font.Gotham
		textBox.TextSize = 12
		textBox.TextXAlignment = Enum.TextXAlignment.Left
		textBox.TextColor3 = Color3.fromRGB(230, 230, 240)
		textBox.PlaceholderText = "Search skins..."
		textBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 135)
		textBox.ClearTextOnFocus = false
		textBox.Text = ""
		textBox.Parent = frame
		local frame2 = Instance.new("Frame")
		frame2.Name = "FVLSkinGrid"
		frame2.LayoutOrder = 0
		frame2.BackgroundTransparency = 1
		frame2.Parent = flag185
		local uiGridLayout = Instance.new("UIGridLayout")
		uiGridLayout.CellSize = UDim2.fromOffset(84, 84)
		uiGridLayout.CellPadding = UDim2.fromOffset(6, 6)
		uiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uiGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uiGridLayout.Parent = frame2

		local function func194()
			frame2.Size = UDim2.new(1, 0, 0, uiGridLayout.AbsoluteContentSize.Y)
		end

		uiGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(func194)
		func194()
		local clone = nil

		pcall(function()
			local playerGui = localPlayer:FindFirstChild("PlayerGui")
			if not playerGui then
				return
			end

			for _, descendant in ipairs(playerGui:GetDescendants()) do
				if descendant:IsA("Frame") and descendant.Name == "Chroma" and descendant:FindFirstChild("BG") then
					clone = descendant:Clone()
					break
				end
			end
		end)

		local tbl96 = { Godly = Color3.fromRGB(255, 110, 190), Ancient = Color3.fromRGB(165, 95, 245) }

		local function func195(param130)
			local value206 = weapons and weapons[param130]

			if value206 then
				local image = type(value206.Image) == "string" and value206.Image or nil
				local pos

				if image then
					pos = image:find("rbxassetid") or image:find("rbxthumb")
				else
					pos = image
				end

				if pos then
					return image
				end

				if image then
					local match = image:match("[Aa]sset[Ii][Dd]=(%d+)") or image:match("[?&]id=(%d+)")
					if match then
						return "rbxthumb://type=Asset&w=150&h=150&id=" .. match
					end
				end

				if tonumber(value206.ItemID) then
					return ("rbxthumb://type=Asset&w=150&h=150&id=%s"):format(tostring(value206.ItemID))
				end
			end

			return value205.icon(param130) or ""
		end

		local tbl97 = { Ancient = 1, Godly = 2 }
		local list42 = {}

		for _, item59 in ipairs(value205.list) do
			list42[#list42 + 1] = item59
		end

		table.sort(list42, function(param131, param132)
			local n4 = tbl97[param131.rarity] or 3
			local n5 = tbl97[param132.rarity] or 3
			if n4 ~= n5 then
				return n4 < n5
			end
			return param131.name:lower() < param132.name:lower()
		end)

		for i, item60 in ipairs(list42) do
			local textButton = Instance.new("TextButton")
			textButton.Name = item60.key
			textButton.LayoutOrder = i
			textButton.Text = ""
			textButton.AutoButtonColor = false
			textButton.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
			textButton.BackgroundTransparency = 0.25
			textButton.BorderSizePixel = 0
			textButton.Parent = frame2
			Instance.new("UICorner", textButton).CornerRadius = UDim.new(0, 10)
			local uiStroke = Instance.new("UIStroke")
			uiStroke.Thickness = 1.5
			uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			uiStroke.Color = tbl96[item60.rarity] or Color3.fromRGB(255, 255, 255)
			uiStroke.Transparency = 0.55
			uiStroke.Parent = textButton
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.BackgroundTransparency = 1
			imageLabel.AnchorPoint = Vector2.new(0.5, 0)
			imageLabel.Position = UDim2.new(0.5, 0, 0, 5)
			imageLabel.Size = UDim2.fromOffset(56, 56)
			imageLabel.Image = func195(item60.key)
			imageLabel.ScaleType = Enum.ScaleType.Fit
			imageLabel.Parent = textButton
			local textLabel = Instance.new("TextLabel")
			textLabel.BackgroundTransparency = 1
			textLabel.AnchorPoint = Vector2.new(0.5, 1)
			textLabel.Position = UDim2.new(0.5, 0, 1, -4)
			textLabel.Size = UDim2.new(1, -6, 0, 18)
			textLabel.Font = Enum.Font.GothamBold
			textLabel.TextSize = 10
			textLabel.TextWrapped = true
			textLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
			textLabel.Text = item60.name
			textLabel.Parent = textButton

			if item60.chroma then
				local clone2

				if clone then
					clone2 = clone:Clone()
					clone2.Visible = true
					clone2.AnchorPoint = Vector2.new(0, 1)
					clone2.Position = UDim2.new(0, 3, 0, 61)
					clone2.Size = UDim2.fromOffset(36, 11)
					local tagName = clone2:FindFirstChild("TagName")

					if tagName and tagName:IsA("TextLabel") then
						tagName.TextSize = 9
					end
				else
					clone2 = Instance.new("TextLabel")
					clone2.BackgroundTransparency = 0.3
					clone2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					clone2.AnchorPoint = Vector2.new(0, 1)
					clone2.Position = UDim2.new(0, 3, 0, 61)
					clone2.Size = UDim2.fromOffset(36, 11)
					clone2.Font = Enum.Font.SourceSansBold
					clone2.TextSize = 9
					clone2.TextColor3 = Color3.fromRGB(255, 255, 255)
					clone2.Text = "Chroma"
					Instance.new("UICorner", clone2).CornerRadius = UDim.new(0, 4)
				end

				clone2.Name = "ChromaTag"
				clone2.ZIndex = 5

				for _, descendant in ipairs(clone2:GetDescendants()) do
					if descendant:IsA("GuiObject") then
						descendant.ZIndex = 5
					end
				end

				clone2.Parent = textButton
			end

			textButton.MouseButton1Click:Connect(function()
				local ok = pcall(value205.spawn, item60.key, 1)

				obj2:Notify({
					Title = ok and "Spawned" or "Failed",
					Content = ok and item60.name .. " — equip it from your inventory." or "Couldn't spawn " .. item60.name,
					Duration = 2,
					Icon = ok and "check" or "x",
				})
			end)

			list41[#list41 + 1] = { tile = textButton, search = item60.name:lower() }
		end

		textBox:GetPropertyChangedSignal("Text"):Connect(function()
			local flag186 = textBox.Text:lower()

			for _, item61 in ipairs(list41) do
				item61.tile.Visible = flag186 == "" or item61.search:find(flag186, 1, true) ~= nil
			end
		end)

		obj25:SetDesc(("%d skins — click one to add it, then equip it normally."):format(#value205.list))

		task.spawn(function()
			local list43 = {}

			for _, item62 in ipairs(list41) do
				local imageLabel = item62.tile:FindFirstChildWhichIsA("ImageLabel")

				if imageLabel then
					list43[#list43 + 1] = imageLabel
				end
			end

			pcall(function()
				game:GetService("ContentProvider"):PreloadAsync(list43)
			end)
		end)
	end

	task.spawn(function()
		local flag187 = getthreadidentity and getthreadidentity() or nil
		local ok, result = pcall(func127)

		pcall(function()
			weapons = require(game:GetService("ReplicatedStorage").Database.Sync).Weapons
		end)

		if flag187 and setthreadidentity then
			pcall(setthreadidentity, flag187)
		end

		if not ok or not result then
			pcall(function()
				obj25:SetDesc("Couldn't load skins: " .. tostring(result):sub(1, 120))
			end)

			return
		end

		value205 = result

		pcall(function()
			if value205.gui then
				value205.gui.Enabled = false
			end
		end)

		func193()
	end)

	list2.gunEls = {}
	list2.knifeEls = {}
	tbl43.combat:Section({ Title = "Sheriff — you have the gun" })

	tbl43.combat:Toggle({
		Title = "Auto Grab Gun",
		Flag = "Toggle_Auto_Grab_Gun",
		Desc = "Picks up the dropped gun for you.",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			if value then
				func70()
			else
				func69()
			end
		end,
	})

	tbl43.combat:Button({
		Title = "TP to Dropped Gun",
		Desc = "Grabs the dropped gun (touches it first, teleports there and back if that fails).",
		Icon = "location-pin",
		Callback = function()
			if list2.tpToDroppedGun then
				list2.tpToDroppedGun()
			end
		end,
	})

	list2.el.silentaim = tbl43.combat:Toggle({
		Title = "Silent Aim",
		Flag = "Toggle_Silent_Aim",
		Desc = "Bends your shots to the murderer when you click. Needs the gun, and the aimbot turns it on too.",
		Type = "Toggle",
		Value = false,
		Callback = function(aimOn)
			flag81.aimOn = aimOn

			if aimOn then
				func74()
			else
				func75()
			end
		end,
	})

	list2.gunEls[#list2.gunEls + 1] = list2.el.silentaim

	list2.el.silentaimtype = tbl43.combat:Dropdown({
		Title = "Silent Aim Type",
		Flag = "Dropdown_Silent_Aim_Type",
		Desc = "Default: simple lead. Dynamic: ping / turn / jump aware prediction. Piercing: Dynamic, but the shot starts behind the target (ignores walls). Applies to every gun shot, including the Shoot Murderer button and Auto Shoot.",
		Multi = false,
		Value = list2.sa.type,
		Values = { "Default", "Dynamic", "Piercing" },
		Callback = function(value)
			list2.sa.type = list2.sa.normalize(value)
		end,
	})

	list2.gunEls[#list2.gunEls + 1] = list2.el.silentaimtype

	tbl43.combat:Toggle({
		Title = "Wall Check",
		Flag = "Toggle_Wall_Check",
		Desc = "Only act when you can actually see the target. Covers Silent Aim, Triggerbot and the on-screen buttons.",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			flag78 = value
		end,
	})

	tbl43.combat:Toggle({
		Title = "Wallbang",
		Flag = "Toggle_Wallbang",
		Desc = "Shoots through walls. Skips the wall check and moves the gun's muzzle next to the target before firing, so the bullet still leaves the gun. Covers Shoot Murderer, Silent Aim and Triggerbot.",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			list2.wallbang = value
		end,
	})

	list2.gunEls[#list2.gunEls + 1] = tbl43.combat:Toggle({
		Title = "Triggerbot",
		Flag = "Toggle_Triggerbot",
		Desc = "Fires by itself when the murderer crosses your crosshair. Sheriff only.",
		Type = "Toggle",
		Value = false,
		Callback = function(enabled)
			flag82.enabled = enabled

			if enabled then
				flag82.start()
			else
				flag82.stop()
			end
		end,
	})

	-- ===================== ESP: Player Dots (tap a dot -> Fling / Shoot / Teleport) =====================
	-- A coloured dot (by role) follows every other player. Tap a dot and a small menu opens next to that player:
	--   Fling    = Smart Fling (Auto Mode): Slam (Head) if they stand still, Spin (Other Script) if they move
	--   Shoot    = Silent Aim in Piercing mode only (predicted shot that starts behind them, no teleport)
	--   Teleport = go to that player
	do
		local Players = game:GetService("Players")
		local RunService = game:GetService("RunService")
		local TweenService = game:GetService("TweenService")
		local Debris = game:GetService("Debris")
		local lp = Players.LocalPlayer

		pcall(function()
			for _, root in ipairs({ (gethui and gethui()) or game:GetService("CoreGui"), game:GetService("CoreGui") }) do
				local old = root:FindFirstChild("FVLPlayerDots")
				if old then
					old:Destroy()
				end
			end
		end)

		local EC = espColors or {}
		local D = {
			on = false,
			size = 20,
			gui = nil,
			root = nil,
			backdrop = nil,
			menu = nil,
			dots = {},
			selected = nil,
			meMurderer = false,
			conns = {},
			roleT = 0,
		}

		local function tw(obj, t, props, style, dir)
			local tween = TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
			tween:Play()
			return tween
		end

		local function corner(obj, r)
			local c = Instance.new("UICorner")
			c.CornerRadius = UDim.new(0, r)
			c.Parent = obj
			return c
		end

		-- role = "Murderer" / "Sheriff" / "Zombie" / "Survivor" / anything else = innocent
		local function roleColor(role)
			if role == "Murderer" or role == "Sheriff" or role == "Zombie" or role == "Survivor" then
				return list2.espColorOfClass(role)
			end

			return EC.innocent or Color3.fromRGB(0, 255, 8)
		end

		----------------------------------------------------------------
		-- Actions
		----------------------------------------------------------------
		local function actFling(target)
			if not (target and target.Parent and target.Character) then
				obj2:Notify({ Title = "Error!", Content = "Could not find that player!", Duration = 1.5, Icon = "x" })
				return
			end

			-- Smart Fling (Auto Mode): the target standing still (< 3 studs/s) = Slam (Head), walking = Spin (Other Script).
			-- Same rule as func27's own Smart Fling, decided here too, so the menu always uses it no matter what the
			-- Fling tab is set to.
			local speed = 0

			pcall(function()
				local root = target.Character:FindFirstChild("HumanoidRootPart")

				if root then
					local v = root.AssemblyLinearVelocity
					speed = Vector3.new(v.X, 0, v.Z).Magnitude

					local tracked = list2.velTrack and list2.velTrack[target]

					if tracked and tracked.v then
						speed = math.max(speed, Vector3.new(tracked.v.X, 0, tracked.v.Z).Magnitude)
					end
				end
			end)

			local prevSmart, prevMode = list2.smartFling, list2.flingMode

			list2.smartFling = true
			list2.flingMode = speed < 3 and "Slam" or "Spin"

			-- func27 reads both right at the start (before it waits), so they only need to be set for this call
			task.spawn(func27, target)

			list2.smartFling = prevSmart
			list2.flingMode = prevMode
		end

		-- Murderer only: stab that one player with the knife (same as the "Kill Player" function)
		local function actKill(target)
			if not (target and target.Parent) then
				return
			end

			func76(target.Name)
		end

		local function actTeleport(target)
			if not (target and target.Parent) then
				return
			end

			func31(target, target.Name)
		end

		-- Silent Aim "Piercing" shot on any player. No teleporting: the shot is predicted like Silent Aim and the
		-- bullet starts BEHIND the target (the gun's muzzle is moved there for the shot, then put back).
		local function actShoot(target)
			if list2.tpShootBusy then
				obj2:Notify({ Title = "Busy", Content = "A shot is already running.", Duration = 1.5, Icon = "clock" })
				return
			end

			list2.tpShootBusy = true

			local function release(delay)
				task.delay(delay, function()
					list2.tpShootBusy = false
				end)
			end

			if func16() ~= localPlayer then
				obj2:Notify({ Title = "Not Sheriff!", Content = "You don't have the gun.", Duration = 2, Icon = "x" })
				release(0.5)
				return
			end

			local tHrp = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")

			if not tHrp then
				obj2:Notify({ Title = "Error!", Content = "Could not find that player!", Duration = 2, Icon = "x" })
				release(0.5)
				return
			end

			local character = lp.Character
			local hrp = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if not hrp or not humanoid then
				release(0.5)
				return
			end

			if (hrp.Position - tHrp.Position).Magnitude > (tonumber(list2.shootRange) or math.huge) then
				obj2:Notify({ Title = "Too Far!", Content = target.Name .. " is out of range.", Duration = 2, Icon = "x" })
				release(0.5)
				return
			end

			local gun = character:FindFirstChild("Gun")

			if not gun then
				local backpack = lp:FindFirstChildOfClass("Backpack")
				local tool = backpack and backpack:FindFirstChild("Gun")

				if tool then
					humanoid:EquipTool(tool)
					task.wait(0.1)
					gun = character:FindFirstChild("Gun")
				end
			end

			local shoot = gun and gun:FindFirstChild("Shoot")

			if not shoot or not shoot:IsA("RemoteEvent") then
				obj2:Notify({ Title = "No Gun Found!", Content = "Couldn't find your gun.", Duration = 2, Icon = "x" })
				release(0.5)
				return
			end

			-- keep the gun tool from firing by itself (touch input) while we work
			local okE, gunWasEnabled = pcall(function()
				return gun.Enabled
			end)

			if not okE then
				gunWasEnabled = true
			end

			pcall(function()
				gun.Enabled = false
			end)

			local inputOff = {}

			if getconnections then
				pcall(function()
					for _, connection in ipairs(getconnections(gun.Activated)) do
						if connection.Enabled ~= false then
							connection:Disable()
							inputOff[#inputOff + 1] = connection
						end
					end
				end)
			end

			local sa = list2.sa
			local prevOrigin, prevOriginT = sa.origin, sa.originT

			-- this target must be hit, not the murderer, so fireGun must not redirect the aim
			list2.fireNoOverride = true

			pcall(function()
				local down = false

				for _ = 1, 3 do
					local char = target.Character
					local t = char and char:FindFirstChild("HumanoidRootPart")
					local hum = char and char:FindFirstChildOfClass("Humanoid")

					if not t or (hum and hum.Health <= 0) then
						down = true
						break
					end

					-- Piercing only, whatever "Silent Aim Type" is set to: sa.resolve gives the predicted aim point and
					-- puts the shot's start point behind the target in sa.origin
					local prevType = sa.type
					sa.type = "Piercing"

					local okR, aim = pcall(sa.resolve, target, t)
					local origin = sa.origin

					sa.type = prevType

					if not okR or not aim or not origin then
						-- fallback: same idea by hand (start behind the target, aim at him)
						local back = t.CFrame.LookVector
						origin = CFrame.new(t.Position - Vector3.new(back.X, 0, back.Z).Unit * (sa.piercingBack or 4))
						aim = t.Position
					end

					list2.fireGun(shoot, character, aim, origin, true)

					task.wait(0.12)
				end

				if not down then
					task.wait(0.1)

					local char = target.Character
					local hum = char and char:FindFirstChildOfClass("Humanoid")
					down = not char or (hum ~= nil and hum.Health <= 0)
				end

				if down then
					obj2:Notify({ Title = "Hit!", Content = target.Name .. " is down.", Duration = 2, Icon = "check" })
				end
			end)

			list2.fireNoOverride = false
			sa.origin, sa.originT = prevOrigin, prevOriginT

			pcall(function()
				gun.Enabled = gunWasEnabled
			end)

			for i = #inputOff, 1, -1 do
				pcall(function()
					inputOff[i]:Enable()
				end)
			end

			release(0.3)
		end

		----------------------------------------------------------------
		-- Menu
		----------------------------------------------------------------
		local closeMenu, openMenu

		local function buildMenu()
			local cg = Instance.new("CanvasGroup")
			cg.Name = "Menu"
			cg.BackgroundColor3 = Color3.fromRGB(15, 16, 23)
			cg.BackgroundTransparency = 0.03
			cg.BorderSizePixel = 0
			cg.Size = UDim2.fromOffset(224, 0)
			cg.AutomaticSize = Enum.AutomaticSize.Y
			cg.GroupTransparency = 1
			cg.Visible = false
			cg.ZIndex = 20
			cg.Parent = D.gui
			corner(cg, 14)

			local stroke = Instance.new("UIStroke")
			stroke.Thickness = 1.5
			stroke.Transparency = 0.3
			stroke.Color = Color3.fromRGB(255, 255, 255)
			stroke.Parent = cg

			local scale = Instance.new("UIScale")
			scale.Scale = 0.7
			scale.Parent = cg

			local pad = Instance.new("UIPadding")
			pad.PaddingTop = UDim.new(0, 10)
			pad.PaddingBottom = UDim.new(0, 10)
			pad.PaddingLeft = UDim.new(0, 10)
			pad.PaddingRight = UDim.new(0, 10)
			pad.Parent = cg

			local list = Instance.new("UIListLayout")
			list.Padding = UDim.new(0, 6)
			list.SortOrder = Enum.SortOrder.LayoutOrder
			list.Parent = cg

			-- header: initial circle, name, role, close
			local header = Instance.new("Frame")
			header.Name = "Header"
			header.LayoutOrder = 0
			header.Size = UDim2.new(1, 0, 0, 38)
			header.BackgroundTransparency = 1
			header.ZIndex = 21
			header.Parent = cg

			local badge = Instance.new("Frame")
			badge.Size = UDim2.fromOffset(36, 36)
			badge.Position = UDim2.fromOffset(0, 2)
			badge.BackgroundColor3 = Color3.fromRGB(70, 255, 100)
			badge.ZIndex = 21
			badge.Parent = header
			corner(badge, 18)

			local initial = Instance.new("TextLabel")
			initial.Size = UDim2.fromScale(1, 1)
			initial.BackgroundTransparency = 1
			initial.Font = Enum.Font.GothamBlack
			initial.TextSize = 16
			initial.TextColor3 = Color3.fromRGB(255, 255, 255)
			initial.TextStrokeTransparency = 0.6
			initial.Text = "?"
			initial.ZIndex = 22
			initial.Parent = badge

			-- profile picture of the selected player (the badge colour stays visible around it as a ring)
			local avatar = Instance.new("ImageLabel")
			avatar.AnchorPoint = Vector2.new(0.5, 0.5)
			avatar.Position = UDim2.fromScale(0.5, 0.5)
			avatar.Size = UDim2.new(1, -5, 1, -5)
			avatar.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
			avatar.BorderSizePixel = 0
			avatar.Image = ""
			avatar.ScaleType = Enum.ScaleType.Crop
			avatar.ZIndex = 23
			avatar.Parent = badge
			corner(avatar, 100)

			local nameLabel = Instance.new("TextLabel")
			nameLabel.Position = UDim2.fromOffset(42, 2)
			nameLabel.Size = UDim2.new(1, -76, 0, 18)
			nameLabel.BackgroundTransparency = 1
			nameLabel.Font = Enum.Font.GothamBold
			nameLabel.TextSize = 14
			nameLabel.TextColor3 = Color3.fromRGB(245, 246, 252)
			nameLabel.TextXAlignment = Enum.TextXAlignment.Left
			nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
			nameLabel.ZIndex = 21
			nameLabel.Parent = header

			local roleLabel = Instance.new("TextLabel")
			roleLabel.Position = UDim2.fromOffset(42, 20)
			roleLabel.Size = UDim2.new(1, -76, 0, 16)
			roleLabel.BackgroundTransparency = 1
			roleLabel.Font = Enum.Font.GothamMedium
			roleLabel.TextSize = 11
			roleLabel.TextColor3 = Color3.fromRGB(150, 155, 175)
			roleLabel.TextXAlignment = Enum.TextXAlignment.Left
			roleLabel.TextTruncate = Enum.TextTruncate.AtEnd
			roleLabel.ZIndex = 21
			roleLabel.Parent = header

			local closeBtn = Instance.new("TextButton")
			closeBtn.AnchorPoint = Vector2.new(1, 0.5)
			closeBtn.Position = UDim2.new(1, 0, 0.5, 0)
			closeBtn.Size = UDim2.fromOffset(28, 28)
			closeBtn.BackgroundColor3 = Color3.fromRGB(30, 32, 44)
			closeBtn.AutoButtonColor = false
			closeBtn.Font = Enum.Font.GothamBold
			closeBtn.TextSize = 18
			closeBtn.TextColor3 = Color3.fromRGB(190, 194, 212)
			closeBtn.Text = "×"
			closeBtn.ZIndex = 22
			closeBtn.Parent = header
			corner(closeBtn, 14)

			closeBtn.MouseEnter:Connect(function()
				tw(closeBtn, 0.12, { BackgroundColor3 = Color3.fromRGB(60, 40, 48), TextColor3 = Color3.fromRGB(255, 120, 130) })
			end)
			closeBtn.MouseLeave:Connect(function()
				tw(closeBtn, 0.12, { BackgroundColor3 = Color3.fromRGB(30, 32, 44), TextColor3 = Color3.fromRGB(190, 194, 212) })
			end)
			closeBtn.Activated:Connect(function()
				closeMenu()
			end)

			local function makeBtn(order, title, sub, accent, callback)
				local b = Instance.new("TextButton")
				b.Name = title
				b.LayoutOrder = order
				b.Size = UDim2.new(1, 0, 0, 46)
				b.BackgroundColor3 = Color3.fromRGB(27, 29, 41)
				b.AutoButtonColor = false
				b.Text = ""
				b.ZIndex = 21
				b.Parent = cg
				corner(b, 10)

				local bs = Instance.new("UIScale")
				bs.Parent = b

				local bar = Instance.new("Frame")
				bar.AnchorPoint = Vector2.new(0, 0.5)
				bar.Position = UDim2.new(0, 8, 0.5, 0)
				bar.Size = UDim2.new(0, 4, 0.55, 0)
				bar.BackgroundColor3 = accent
				bar.BorderSizePixel = 0
				bar.ZIndex = 22
				bar.Parent = b
				corner(bar, 2)

				local t1 = Instance.new("TextLabel")
				t1.Position = UDim2.fromOffset(22, 6)
				t1.Size = UDim2.new(1, -46, 0, 18)
				t1.BackgroundTransparency = 1
				t1.Font = Enum.Font.GothamBold
				t1.TextSize = 14
				t1.TextColor3 = Color3.fromRGB(245, 246, 252)
				t1.TextXAlignment = Enum.TextXAlignment.Left
				t1.Text = title
				t1.ZIndex = 22
				t1.Parent = b

				local t2 = Instance.new("TextLabel")
				t2.Position = UDim2.fromOffset(22, 24)
				t2.Size = UDim2.new(1, -46, 0, 14)
				t2.BackgroundTransparency = 1
				t2.Font = Enum.Font.GothamMedium
				t2.TextSize = 11
				t2.TextColor3 = Color3.fromRGB(150, 155, 175)
				t2.TextXAlignment = Enum.TextXAlignment.Left
				t2.Text = sub
				t2.ZIndex = 22
				t2.Parent = b

				local arrow = Instance.new("TextLabel")
				arrow.AnchorPoint = Vector2.new(1, 0.5)
				arrow.Position = UDim2.new(1, -10, 0.5, 0)
				arrow.Size = UDim2.fromOffset(16, 30)
				arrow.BackgroundTransparency = 1
				arrow.Font = Enum.Font.GothamBold
				arrow.TextSize = 22
				arrow.TextColor3 = accent
				arrow.Text = "›"
				arrow.ZIndex = 22
				arrow.Parent = b

				b.MouseEnter:Connect(function()
					tw(b, 0.12, { BackgroundColor3 = Color3.fromRGB(38, 41, 58) })
					tw(bar, 0.15, { Size = UDim2.new(0, 4, 0.8, 0) })
					tw(arrow, 0.15, { Position = UDim2.new(1, -6, 0.5, 0) })
				end)
				b.MouseLeave:Connect(function()
					tw(b, 0.15, { BackgroundColor3 = Color3.fromRGB(27, 29, 41) })
					tw(bar, 0.15, { Size = UDim2.new(0, 4, 0.55, 0) })
					tw(arrow, 0.15, { Position = UDim2.new(1, -10, 0.5, 0) })
				end)
				b.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						tw(bs, 0.08, { Scale = 0.95 })
						tw(b, 0.08, { BackgroundColor3 = Color3.fromRGB(46, 50, 70) })
					end
				end)
				b.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						tw(bs, 0.18, { Scale = 1 }, Enum.EasingStyle.Back)
						tw(b, 0.15, { BackgroundColor3 = Color3.fromRGB(27, 29, 41) })
					end
				end)
				b.Activated:Connect(function()
					local target = D.selected
					closeMenu()

					if target then
						task.spawn(callback, target)
					end
				end)

				return b, t1, t2
			end

			makeBtn(1, "Fling", "Auto mode - picks Slam / Spin", Color3.fromRGB(255, 150, 60), actFling)
			local shootBtn, shootTitle, shootSub = makeBtn(2, "Shoot", "Silent Aim - Piercing shot", Color3.fromRGB(255, 75, 95), actShoot)
			local killBtn = makeBtn(3, "Kill", "Stab them with the knife", Color3.fromRGB(235, 40, 40), actKill)
			killBtn.Visible = false
			makeBtn(4, "Teleport", "Go to their position", Color3.fromRGB(90, 200, 255), actTeleport)

			D.menu = {
				cg = cg,
				scale = scale,
				stroke = stroke,
				badge = badge,
				initial = initial,
				avatar = avatar,
				shootBtn = shootBtn,
				shootTitle = shootTitle,
				shootSub = shootSub,
				killBtn = killBtn,
				nameLabel = nameLabel,
				roleLabel = roleLabel,
			}
		end

		-- Kill shows only when you are the murderer; Shoot shows otherwise and reads "Shoot Murderer" on the murderer
		local function refreshButtons()
			local m = D.menu

			if not m or not D.selected then
				return
			end

			local rec = D.dots[D.selected]
			local meMurderer = D.meMurderer == true

			m.killBtn.Visible = meMurderer
			m.shootBtn.Visible = not meMurderer
			m.shootTitle.Text = (rec and (rec.role == "Murderer" or rec.role == "Zombie")) and "Shoot Murderer" or "Shoot"
		end

		local function markSelected()
			for player, rec in pairs(D.dots) do
				local on = player == D.selected
				tw(rec.dotStroke, 0.15, { Thickness = on and 3.5 or 1.5, Transparency = on and 0 or 0.35 })
			end
		end

		closeMenu = function()
			D.selected = nil
			markSelected()

			if D.backdrop then
				D.backdrop.Visible = false
			end

			local m = D.menu

			if m and m.cg.Visible then
				tw(m.cg, 0.14, { GroupTransparency = 1 })
				tw(m.scale, 0.14, { Scale = 0.7 })

				task.delay(0.16, function()
					if D.selected == nil and D.menu and D.menu.cg.Parent then
						D.menu.cg.Visible = false
					end
				end)
			end
		end

		openMenu = function(player)
			if not D.menu then
				buildMenu()
			end

			local m = D.menu
			local rec = D.dots[player]
			local color = rec and rec.color or roleColor(nil)

			D.selected = player
			markSelected()

			local shown = player.DisplayName ~= "" and player.DisplayName or player.Name
			m.nameLabel.Text = shown
			m.roleLabel.Text = "@" .. player.Name .. "  -  " .. ((rec and rec.role) or "Innocent")
			m.roleLabel.TextColor3 = color
			m.initial.Text = string.upper(string.sub(shown, 1, 1))
			m.badge.BackgroundColor3 = color
			m.stroke.Color = color

			-- profile picture (the letter stays behind it as a fallback if the picture doesn't load)
			m.initial.Visible = true
			m.avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
			task.delay(1.5, function()
				if D.selected == player and m.avatar.Parent and m.avatar.IsLoaded then
					m.initial.Visible = false
				end
			end)

			local okM, murd = pcall(func15)
			D.meMurderer = okM and murd == localPlayer
			refreshButtons()

			D.backdrop.Visible = true
			m.cg.Visible = true
			m.cg.GroupTransparency = 1
			m.scale.Scale = 0.7

			tw(m.cg, 0.2, { GroupTransparency = 0 })
			tw(m.scale, 0.28, { Scale = 1 }, Enum.EasingStyle.Back)
		end

		----------------------------------------------------------------
		-- Dots
		----------------------------------------------------------------
		local function ripple(rec, color)
			local r = Instance.new("Frame")
			r.AnchorPoint = Vector2.new(0.5, 0.5)
			r.Position = UDim2.fromScale(0.5, 0.5)
			r.Size = UDim2.fromOffset(D.size, D.size)
			r.BackgroundTransparency = 1
			r.ZIndex = 6
			r.Parent = rec.hit
			corner(r, 100)

			local s = Instance.new("UIStroke")
			s.Thickness = 3
			s.Color = color
			s.Parent = r

			tw(r, 0.5, { Size = UDim2.fromOffset(D.size * 3.4, D.size * 3.4) })
			tw(s, 0.5, { Transparency = 1, Thickness = 1 })
			Debris:AddItem(r, 0.6)
		end

		local function onDotClick(player)
			local rec = D.dots[player]

			if not rec then
				return
			end

			-- pop animation + ripple
			tw(rec.scale, 0.08, { Scale = 0.7 })
			task.delay(0.08, function()
				if rec.scale.Parent then
					tw(rec.scale, 0.3, { Scale = 1 }, Enum.EasingStyle.Back)
				end
			end)
			ripple(rec, rec.color or Color3.new(1, 1, 1))

			if D.selected == player then
				closeMenu()
			else
				openMenu(player)
			end
		end

		local function removeDot(player)
			local rec = D.dots[player]

			if not rec then
				return
			end

			D.dots[player] = nil

			if D.selected == player then
				closeMenu()
			end

			pcall(function()
				rec.t1:Cancel()
				rec.t2:Cancel()
			end)
			pcall(function()
				rec.hit:Destroy()
			end)
		end

		local function makeDot(player)
			if D.dots[player] or player == lp or not D.root then
				return
			end

			local size = D.size

			local hit = Instance.new("TextButton")
			hit.Name = "Dot_" .. player.Name
			hit.AnchorPoint = Vector2.new(0.5, 0.5)
			hit.BackgroundTransparency = 1
			hit.Text = ""
			hit.AutoButtonColor = false
			hit.Size = UDim2.fromOffset(size + 18, size + 18)
			hit.Visible = false
			hit.ZIndex = 5
			hit.Parent = D.root

			local scale = Instance.new("UIScale")
			scale.Scale = 0
			scale.Parent = hit

			local ring = Instance.new("Frame")
			ring.Name = "Ring"
			ring.AnchorPoint = Vector2.new(0.5, 0.5)
			ring.Position = UDim2.fromScale(0.5, 0.5)
			ring.Size = UDim2.fromOffset(size, size)
			ring.BackgroundTransparency = 1
			ring.ZIndex = 5
			ring.Parent = hit
			corner(ring, 100)

			local ringStroke = Instance.new("UIStroke")
			ringStroke.Thickness = 2
			ringStroke.Transparency = 0.2
			ringStroke.Parent = ring

			local dot = Instance.new("Frame")
			dot.Name = "Dot"
			dot.AnchorPoint = Vector2.new(0.5, 0.5)
			dot.Position = UDim2.fromScale(0.5, 0.5)
			dot.Size = UDim2.fromOffset(size, size)
			dot.BorderSizePixel = 0
			dot.ZIndex = 6
			dot.Parent = hit
			corner(dot, 100)

			local dotStroke = Instance.new("UIStroke")
			dotStroke.Thickness = 1.5
			dotStroke.Transparency = 0.35
			dotStroke.Color = Color3.fromRGB(255, 255, 255)
			dotStroke.Parent = dot

			local label = Instance.new("TextLabel")
			label.AnchorPoint = Vector2.new(0.5, 0)
			label.Position = UDim2.new(0.5, 0, 1, -2)
			label.Size = UDim2.fromOffset(110, 14)
			label.BackgroundTransparency = 1
			label.Font = Enum.Font.GothamMedium
			label.TextSize = 11
			label.TextColor3 = Color3.fromRGB(255, 255, 255)
			label.TextStrokeTransparency = 0.5
			label.Text = player.Name
			label.ZIndex = 6
			label.Parent = hit

			local info = TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1)
			local t1 = TweenService:Create(ring, info, { Size = UDim2.fromOffset(size * 2.1, size * 2.1) })
			local t2 = TweenService:Create(ringStroke, info, { Transparency = 1 })
			t1:Play()
			t2:Play()

			local rec = {
				hit = hit,
				dot = dot,
				dotStroke = dotStroke,
				ringStroke = ringStroke,
				scale = scale,
				label = label,
				t1 = t1,
				t2 = t2,
				role = "Innocent",
				color = nil,
			}

			D.dots[player] = rec
			hit.Activated:Connect(function()
				onDotClick(player)
			end)

			tw(scale, 0.4, { Scale = 1 }, Enum.EasingStyle.Back)
		end

		local function applyRoleColor(rec, role, cls)
			local color = roleColor(cls or role)
			rec.role = role or "Innocent"

			if rec.color ~= color then
				local first = rec.color == nil
				rec.color = color

				if first then
					rec.dot.BackgroundColor3 = color
					rec.ringStroke.Color = color
				else
					tw(rec.dot, 0.25, { BackgroundColor3 = color })
					tw(rec.ringStroke, 0.25, { Color = color })
				end
			end
		end

		local function step()
			local cam = workspace.CurrentCamera

			if not cam then
				return
			end

			local now = os.clock()
			local refreshRoles = now - D.roleT > 0.25

			if refreshRoles then
				D.roleT = now
			end

			if refreshRoles then
				local okM, murd = pcall(func15)
				D.meMurderer = okM and murd == localPlayer
			end

			for player, rec in pairs(D.dots) do
				if refreshRoles then
					local ok, cls, real = pcall(list2.espRole, player)
					applyRoleColor(rec, ok and real or nil, ok and cls or nil)
				end

				local char = player.Character
				local root = char and char:FindFirstChild("HumanoidRootPart")
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				local visible = false

				if root and hum then
					local v, onScreen = cam:WorldToViewportPoint(root.Position + Vector3.new(0, 0.5, 0))

					if onScreen and v.Z > 0 then
						rec.hit.Position = UDim2.fromOffset(v.X, v.Y)
						visible = true
					end
				end

				rec.hit.Visible = visible
			end

			if refreshRoles and D.selected then
				refreshButtons()
			end

			local m = D.menu

			if D.selected and m then
				local rec = D.dots[D.selected]

				if not rec or not rec.hit.Visible then
					closeMenu()
				else
					local vp = cam.ViewportSize
					local p = rec.hit.Position
					local x, y = p.X.Offset, p.Y.Offset
					local mh = m.cg.AbsoluteSize.Y
					local gap = D.size / 2 + 22

					if x + gap + 224 > vp.X - 8 then
						m.cg.AnchorPoint = Vector2.new(1, 0.5)
						x = x - gap
					else
						m.cg.AnchorPoint = Vector2.new(0, 0.5)
						x = x + gap
					end

					y = math.clamp(y, mh / 2 + 8, math.max(vp.Y - mh / 2 - 8, mh / 2 + 8))
					m.cg.Position = UDim2.fromOffset(x, y)
				end
			end
		end

		----------------------------------------------------------------
		-- Start / stop
		----------------------------------------------------------------
		local function stop()
			D.on = false

			for _, c in ipairs(D.conns) do
				pcall(function()
					c:Disconnect()
				end)
			end

			D.conns = {}

			for player in pairs(D.dots) do
				removeDot(player)
			end

			D.selected = nil
			D.menu = nil
			D.backdrop = nil
			D.root = nil

			if D.gui then
				pcall(function()
					D.gui:Destroy()
				end)

				D.gui = nil
			end
		end

		local function start()
			stop()
			D.on = true

			local gui = Instance.new("ScreenGui")
			gui.Name = "FVLPlayerDots"
			gui.ResetOnSpawn = false
			gui.IgnoreGuiInset = true
			gui.DisplayOrder = 9000
			gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
			D.gui = gui

			-- dots live in their own layer; the backdrop (only shown while the menu is open) sits under everything
			local backdrop = Instance.new("TextButton")
			backdrop.Name = "Backdrop"
			backdrop.Size = UDim2.fromScale(1, 1)
			backdrop.BackgroundTransparency = 1
			backdrop.Text = ""
			backdrop.AutoButtonColor = false
			backdrop.Visible = false
			backdrop.ZIndex = 1
			backdrop.Parent = gui
			backdrop.Activated:Connect(function()
				closeMenu()
			end)
			D.backdrop = backdrop

			local root = Instance.new("Folder")
			root.Name = "Dots"
			root.Parent = gui
			D.root = root

			for _, p in ipairs(Players:GetPlayers()) do
				makeDot(p)
			end

			D.conns[#D.conns + 1] = Players.PlayerAdded:Connect(makeDot)
			D.conns[#D.conns + 1] = Players.PlayerRemoving:Connect(removeDot)
			D.conns[#D.conns + 1] = RunService.RenderStepped:Connect(step)
		end

		list2.conns[#list2.conns + 1] = {
			Disconnect = function()
				stop()
			end,
		}

		----------------------------------------------------------------
		-- UI (ESP tab)
		----------------------------------------------------------------
		tbl43.esp:Section({ Title = "Player Dots" })

		tbl43.esp:Toggle({
			Title = "Player Dots (Tap Menu)",
			Flag = "Toggle_ESP_PlayerDots",
			Desc = "A coloured dot on every player (red = murderer, blue = sheriff, green = innocent). Tap a dot to Fling (Smart), Shoot (Piercing) or Teleport.",
			Type = "Toggle",
			Value = false,
			Callback = function(v)
				if v then
					start()
				else
					stop()
				end
			end,
		})

		tbl43.esp:Slider({
			Title = "Dot Size",
			Flag = "Slider_ESP_Dot_Size",
			Step = 1,
			Value = { Min = 12, Max = 40, Default = 20 },
			Callback = function(v)
				local n = tonumber(v) or (type(v) == "table" and tonumber(v.Value))

				if n and n ~= D.size then
					D.size = n

					if D.on then
						start()
					end
				end
			end,
		})
	end

	-- ===== TP Shoot Murderer (Sheriff only) =====
	-- Teleports to the murderer, locks onto him, fires from the gun, then returns you to your original spot.
	do
		list2.tpShootBusy = false
		list2.tpLockTime = 0.5

		local TP_SHOOT_VALID = {}

		for _, name in ipairs(list2.TP_POS) do
			TP_SHOOT_VALID[name] = true
		end

		-- Change the position from anywhere (Combat dropdown or the floating button)
		list2.tpSetPos = function(name, fromDropdown)
			if not TP_SHOOT_VALID[name] then
				return
			end

			list2.tpShootPos = name

			if not fromDropdown and list2.tpPosDropdown then
				pcall(function()
					list2.tpPosDropdown:Select(name)
				end)
			end
		end

		-- The gun tool shoots BY ITSELF towards wherever a finger touches the screen. That is what sends bullets
		-- the wrong way and eats the gun's cooldown. While TP Shoot runs we switch the gun's "Activated" handlers
		-- off (same trick as the Aimbot, needs an executor with getconnections) and back on afterwards.
		local gunInputOff = {}

		local function blockGunInput(character)
			local tool = character and character:FindFirstChild("Gun")

			if not tool then
				return
			end

			if getconnections then
				pcall(function()
					for _, connection in ipairs(getconnections(tool.Activated)) do
						-- only touch handlers that are currently on (another feature may have switched some off)
						if connection.Enabled ~= false then
							connection:Disable()
							gunInputOff[#gunInputOff + 1] = connection
						end
					end
				end)
			end
		end

		local function restoreGunInput()
			for i = #gunInputOff, 1, -1 do
				pcall(function()
					gunInputOff[i]:Enable()
				end)

				gunInputOff[i] = nil
			end
		end

		local function tpShootMurderer()
			if list2.tpShootBusy then
				return
			end
			list2.tpShootBusy = true

			local function release(delay)
				task.delay(delay, function()
					list2.tpShootBusy = false
				end)
			end

			if func16() ~= localPlayer then
				obj2:Notify({ Title = "Not Sheriff!", Content = "You don't have the gun.", Duration = 2, Icon = "x" })
				release(0.5)
				return
			end

			local murderer = func15()
			local murdererHrp = murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart")

			if not murdererHrp then
				obj2:Notify({ Title = "Error!", Content = "No murderer this round!", Duration = 2, Icon = "x" })
				release(0.5)
				return
			end

			local character = localPlayer.Character
			local hrp = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if not hrp or not humanoid then
				release(0.5)
				return
			end

			-- Make sure the gun is equipped
			local gun = character:FindFirstChild("Gun")

			if not gun then
				local backpack = localPlayer:FindFirstChildOfClass("Backpack")
				local tool = backpack and backpack:FindFirstChild("Gun")

				if tool then
					humanoid:EquipTool(tool)
					task.wait(0.1)
					gun = character:FindFirstChild("Gun")
				end
			end

			local shoot = gun and gun:FindFirstChild("Shoot")

			if not shoot or not shoot:IsA("RemoteEvent") then
				obj2:Notify({ Title = "No Gun Found!", Content = "Couldn't find your gun.", Duration = 2, Icon = "x" })
				release(0.5)
				return
			end

			-- The gun tool also shoots by itself towards wherever another finger touches the screen, and that shot
			-- eats the gun's cooldown so ours get ignored. Switch the tool's own input off while we work.
			local enabledOk, gunWasEnabled = pcall(function()
				return gun.Enabled
			end)

			if not enabledOk then
				gunWasEnabled = true
			end

			pcall(function()
				gun.Enabled = false
			end)

			blockGunInput(character)

			-- We teleport next to the murderer and lock onto him. The gun comes with us, so every bullet leaves the gun
			-- (its muzzle) from right beside him: the shots are fired the normal way, at his live position, and
			-- we go back to the exact spot we started from afterwards.
			local homeCF = hrp.CFrame
			local position = list2.tpShootPos
			local dist = tonumber(list2.tpShootDist) or 3
			local runService = game:GetService("RunService")
			local moveConn, moveConn2
			local GUN_LIFT = 1.3 -- raises us so the gun in our hand ends up at his head height, pointing at him
			local flat = position == "Above Head" or position == "Below Feet"

			-- Where we should stand, relative to the murderer's CURRENT position
			local function destinationFor(targetHrp)
				local cf = targetHrp.CFrame
				local pos = cf.Position
				local rot = cf - pos

				if position == "Behind" then
					local p = pos - cf.LookVector * dist + Vector3.new(0, GUN_LIFT, 0)
					return CFrame.lookAt(p, Vector3.new(pos.X, p.Y, pos.Z))
				elseif position == "Above Head" then
					-- lying flat, face down, hovering over him
					return CFrame.new(pos + Vector3.new(0, dist, 0)) * rot * CFrame.Angles(-math.rad(90), 0, 0)
				elseif position == "Below Feet" then
					-- lying flat, face up, under him
					return CFrame.new(pos - Vector3.new(0, dist, 0)) * rot * CFrame.Angles(math.rad(90), 0, 0)
				end

				local p = pos + cf.LookVector * dist + Vector3.new(0, GUN_LIFT, 0)
				return CFrame.lookAt(p, Vector3.new(pos.X, p.Y, pos.Z))
			end

			-- Stop the humanoid from standing us back up while we are locked on
			local oldPlatform, oldAutoRotate = humanoid.PlatformStand, humanoid.AutoRotate

			pcall(function()
				humanoid.AutoRotate = false

				if flat then
					humanoid.PlatformStand = true
				end

				-- Lock on: every frame, before AND after physics, put us back next to him
				local function follow()
					local char = murderer.Character
					local target = char and char:FindFirstChild("HumanoidRootPart")

					if not target or not (hrp and hrp.Parent) then
						return
					end

					hrp.AssemblyLinearVelocity = Vector3.zero
					hrp.AssemblyAngularVelocity = Vector3.zero
					hrp.CFrame = destinationFor(target)
				end

				moveConn = runService.Stepped:Connect(follow)
				moveConn2 = runService.Heartbeat:Connect(follow)

				task.wait(0.08) -- one short beat so the server sees us in the new place

				-- Bullets that follow him: keep firing at his LIVE position (re-read for every shot) for the whole
				-- lock time. At least 4 shots, until he is down or the time is up.
				local murdererDown = false
				local endAt = os.clock() + math.max(0.05, tonumber(list2.tpLockTime) or 0.5)
				local shot = 0

				while shot < 4 or os.clock() < endAt do
					shot = shot + 1
					local char = murderer.Character
					local target = char and char:FindFirstChild("HumanoidRootPart")
					local hum = char and char:FindFirstChildOfClass("Humanoid")

					if not target or (hum and hum.Health <= 0) then
						murdererDown = true
						break
					end

					local aim = list2.aimAt(murderer, target) or target.Position

					-- TP Shoot is self-contained: the bullet leaves the gun's muzzle from the spot picked in
					-- "TP Shoot Position". The shared Wallbang toggle and Silent Aim Type (Piercing) don't move it.
					list2.fireGun(shoot, character, aim, nil, true)

					task.wait(0.08)
				end

				if not murdererDown then
					task.wait(0.05)
					local char = murderer.Character
					local hum = char and char:FindFirstChildOfClass("Humanoid")
					murdererDown = not char or (hum ~= nil and hum.Health <= 0)
				end

				if murdererDown then
					obj2:Notify({ Title = "Hit!", Content = "Murderer is down.", Duration = 2, Icon = "check" })
				end
			end)

			-- Release the lock first
			if moveConn then
				moveConn:Disconnect()
				moveConn = nil
			end

			if moveConn2 then
				moveConn2:Disconnect()
				moveConn2 = nil
			end

			pcall(function()
				humanoid.PlatformStand = oldPlatform
				humanoid.AutoRotate = oldAutoRotate
			end)

			-- Always put us back on the exact original spot, even if something above errored.
			-- Re-applied for a few frames so nothing pulls us back.
			local backUntil = os.clock() + 0.15

			while os.clock() < backUntil do
				if not (hrp and hrp.Parent) then
					break
				end

				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero
				hrp.CFrame = homeCF

				runService.Heartbeat:Wait()
			end

			pcall(function()
				gun.Enabled = gunWasEnabled
			end)

			restoreGunInput()

			release(0.2)
		end

		-- Used by the Combat button and the floating button
		list2.tpShootRun = function()
			task.spawn(function()
				pcall(num15.setActive, "TPShoot", true)
				tpShootMurderer()
				pcall(num15.setActive, "TPShoot", false)
			end)
		end

		list2.tpPosDropdown = tbl43.combat:Dropdown({
			Title = "TP Shoot Position",
			Flag = "Dropdown_TP_Shoot_Position",
			Desc = "Where you stand next to the murderer while you shoot him. Above Head / Below Feet make you lie flat. Only used by TP Shoot (Wallbang and Silent Aim Type don't change it).",
			Multi = false,
			Value = "Front",
			Values = list2.TP_POS,
			Callback = function(value)
				list2.tpSetPos(tostring(type(value) == "table" and (value[1] or value.Value) or value), true)
			end,
		})

		list2.gunEls[#list2.gunEls + 1] = list2.tpPosDropdown

		list2.gunEls[#list2.gunEls + 1] = tbl43.combat:Slider({
			Title = "TP Shoot Distance",
			Flag = "Slider_TP_Shoot_Distance",
			Desc = "How far you stand from the murderer.",
			Step = 1,
			Value = { Min = 1, Max = 30, Default = 3 },
			Callback = function(value)
				local n = tonumber(value) or type(value) == "table" and tonumber(value.Value)

				if n then
					list2.tpShootDist = n
				end
			end,
		})

		list2.gunEls[#list2.gunEls + 1] = tbl43.combat:Slider({
			Title = "TP Shoot Lock Time",
			Flag = "Slider_TP_Shoot_Lock_Time",
			Desc = "Seconds you stay locked next to the murderer, following him and firing at where he is now, before you go back.",
			Step = 0.1,
			Value = { Min = 0.1, Max = 10, Default = 0.5 },
			Callback = function(value)
				local n = tonumber(value) or type(value) == "table" and tonumber(value.Value)

				if n then
					list2.tpLockTime = n
				end
			end,
		})

		list2.gunEls[#list2.gunEls + 1] = tbl43.combat:Button({
			Title = "TP Shoot Murderer",
			Desc = "Teleports next to the murderer and locks onto him, shoots from the gun, then returns you to your original spot. Sheriff only.",
			Callback = function()
				list2.tpShootRun()
			end,
		})

		-- Auto TP Shoot: fires the whole TP Shoot by itself every time the gun is ready
		local auto = { on = false, lastRun = 0, token = 0 }

		local function autoLoop(token)
			while auto.on and auto.token == token do
				task.wait(0.2)

				local cooldown = (COOLDOWN and COOLDOWN.Shoot or 3.2) + 0.1

				if auto.on and auto.token == token and not list2.tpShootBusy and os.clock() - auto.lastRun >= cooldown then
					pcall(function()
						if func16() ~= localPlayer then
							return -- only the sheriff has the gun
						end

						local murderer = func15()
						local char = murderer and murderer.Character
						local murdererHrp = char and char:FindFirstChild("HumanoidRootPart")
						local murdererHum = char and char:FindFirstChildOfClass("Humanoid")
						local myHrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

						if murdererHrp and murdererHum and murdererHum.Health > 0 and myHrp
							and (myHrp.Position - murdererHrp.Position).Magnitude <= list2.shootRange then
							auto.lastRun = os.clock()
							list2.tpShootRun()
						end
					end)
				end
			end
		end

		list2.gunEls[#list2.gunEls + 1] = tbl43.combat:Toggle({
			Title = "Auto TP Shoot",
			Flag = "Toggle_Auto_TP_Shoot",
			Desc = "Sheriff only: automatically does TP Shoot on the murderer every time your gun is ready (about every 3 seconds) until he is down. No button press needed.",
			Type = "Toggle",
			Value = false,
			Callback = function(value)
				auto.on = value and true or false
				auto.token = auto.token + 1

				if auto.on then
					auto.lastRun = 0
					task.spawn(autoLoop, auto.token)
				end
			end,
		})

		-- Floating (on-screen) buttons
		tbl43.buttons:Section({ Title = "TP Shoot Button" })

		tbl43.buttons:Toggle({
			Title = "TP Shoot Button",
			Flag = "Toggle_TP_Shoot_Button",
			Desc = "One draggable button. Tap it to send the gun to the murderer's head, shoot, and bring it back. Pick the side in the Combat tab.",
			Type = "Toggle",
			Value = false,
			Callback = function(value)
				if value then
					list2.hudSpawns.TPShoot()
				else
					num15.destroy("TPShoot")
				end
			end,
		})
	end

	-- ===== Auto Dodge Knife =====
	-- Watches every thrown knife (tag "ThrowingKnife") that isn't ours. As soon as one is flying so it will pass
	-- through us, we slide sideways - only as far as needed to be clear of its path, and very fast.
	do
		local CollectionService_ = game:GetService("CollectionService")
		local RunService_ = game:GetService("RunService")
		local DODGE_RADIUS = 5 -- how close to our body the knife's path must pass to count as a hit
		local CLEAR_MARGIN = 1 -- extra studs of room we want beyond that radius
		local LOOK_AHEAD = 1.2 -- only react to knives that would reach us within this many seconds

		local dodge = {
			on = false,
			conn = nil,
			speed = 250, -- studs per second of the slide (high = the dodge is over in about 2 frames)
			maxDistance = 8, -- never slide further than this
			lastSeen = {},
			done = {}, -- knives we already dodged (one slide per knife)
			dir = nil,
			remaining = 0,
		}

		local rayParams = RaycastParams.new()
		rayParams.FilterType = Enum.RaycastFilterType.Exclude

		local function knifePosition(knife)
			if knife:IsA("BasePart") then
				return knife.Position
			end

			if knife:IsA("Model") then
				return knife:GetPivot().Position
			end
		end

		local function isOurKnife(knife, character)
			local link = knife:FindFirstChild("HandleLink")
			local handle = link and link.Value
			local owner = handle and handle.Parent
			return owner ~= nil and owner:IsDescendantOf(character)
		end

		local function step(dt)
			local character = localPlayer.Character
			local hrp = character and character:FindFirstChild("HumanoidRootPart")
			local hum = character and character:FindFirstChildOfClass("Humanoid")

			if not hrp or not hum or hum.Health <= 0 or dt <= 0 then
				dodge.lastSeen = {}
				dodge.done = {}
				dodge.dir = nil
				dodge.remaining = 0
				return
			end

			local me = hrp.Position
			local seenNow = {}
			local stillDone = {}
			local bestT, bestDir, bestNeed, bestKnife

			for _, knife in ipairs(CollectionService_:GetTagged("ThrowingKnife")) do
				local pos = knifePosition(knife)

				if pos then
					seenNow[knife] = pos
					stillDone[knife] = dodge.done[knife]
					local prev = dodge.lastSeen[knife]

					if prev and not dodge.done[knife] and not isOurKnife(knife, character) then
						-- velocity from how far the knife moved since the last frame
						local vel = (pos - prev) / dt
						local speedSq = vel:Dot(vel)

						if speedSq > 400 then -- moving faster than 20 studs/s
							local t = (me - pos):Dot(vel) / speedSq -- seconds until it is closest to us

							if t > 0 and t < LOOK_AHEAD then
								local offset = me - (pos + vel * t)

								if offset.Magnitude < DODGE_RADIUS and (not bestT or t < bestT) then
									-- sidestep perpendicular to the knife's flight path, towards the side we are already on
									local perp = Vector3.new(-vel.Z, 0, vel.X)

									if perp.Magnitude < 0.1 then
										perp = Vector3.new(offset.X, 0, offset.Z) -- knife coming straight down / up
									end

									if perp.Magnitude < 0.1 then
										perp = Vector3.new(1, 0, 0)
									end

									perp = perp.Unit

									if perp:Dot(Vector3.new(offset.X, 0, offset.Z)) < 0 then
										perp = -perp
									end

									-- only slide as far as it takes to get clear of the path
									local sideways = math.max(0, offset:Dot(perp))
									local need = math.clamp(DODGE_RADIUS + CLEAR_MARGIN - sideways, 2, dodge.maxDistance)

									bestT, bestDir, bestNeed, bestKnife = t, perp, need, knife
								end
							end
						end
					end
				end
			end

			dodge.lastSeen = seenNow
			dodge.done = stillDone

			-- a new threat: start one quick slide, once per knife
			if bestDir and dodge.remaining <= 0 then
				dodge.dir = bestDir
				dodge.remaining = bestNeed
				dodge.done[bestKnife] = true
			end

			if dodge.dir and dodge.remaining > 0 then
				local stepLen = math.min(dodge.remaining, dodge.speed * dt)
				rayParams.FilterDescendantsInstances = { character }

				-- don't slide into a wall: flip to the other side instead
				if workspace:Raycast(me, dodge.dir * (stepLen + 2), rayParams) then
					dodge.dir = -dodge.dir
				end

				-- slide AND turn side-on to the knife: we face the direction we are sliding in, which is
				-- 90 degrees to the knife's flight path (a narrower target than facing it head-on)
				local newPos = hrp.Position + dodge.dir * stepLen
				hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
				hrp.CFrame = CFrame.lookAt(newPos, newPos + Vector3.new(dodge.dir.X, 0, dodge.dir.Z))
				dodge.remaining = dodge.remaining - stepLen
			else
				dodge.dir = nil
			end
		end

		local function setDodge(on)
			dodge.on = on

			if dodge.conn then
				dodge.conn:Disconnect()
				dodge.conn = nil
			end

			dodge.lastSeen = {}
			dodge.done = {}
			dodge.dir = nil
			dodge.remaining = 0

			if on then
				dodge.conn = RunService_.Stepped:Connect(function(_, dt)
					pcall(step, dt)
				end)
			end
		end

		tbl43.combat:Section({ Title = "Knife" })

		tbl43.combat:Toggle({
			Title = "Auto Knife Throw",
			Flag = "Toggle_Extra_AutoKnife",
			Desc = "As murderer, throws your knife at the nearest player every 1.4 seconds.",
			Type = "Toggle",
			Value = false,
			Callback = function(value)
				if list2.autoKnifeThrow then
					list2.autoKnifeThrow(value and true or false)
				end
			end,
		})

		tbl43.combat:Toggle({
			Title = "Auto Dodge Knife",
			Flag = "Toggle_Auto_Dodge_Knife",
			Desc = "When the murderer throws a knife that would hit you, you turn side-on and slide out of its path, only as far as needed and very fast.",
			Type = "Toggle",
			Value = false,
			Callback = function(value)
				setDodge(value and true or false)
			end,
		})

		tbl43.combat:Slider({
			Title = "Dodge Speed",
			Flag = "Slider_Dodge_Speed",
			Desc = "How fast the sideways slide is (studs per second). Higher = the dodge is over almost instantly.",
			Step = 10,
			Value = { Min = 60, Max = 600, Default = 250 },
			Callback = function(value)
				local n = tonumber(value) or type(value) == "table" and tonumber(value.Value)

				if n then
					dodge.speed = n
				end
			end,
		})

		tbl43.combat:Slider({
			Title = "Dodge Max Distance",
			Flag = "Slider_Dodge_Max_Distance",
			Desc = "The furthest you will ever slide for one knife (studs). It normally slides less: just enough to clear the knife's path.",
			Step = 1,
			Value = { Min = 3, Max = 15, Default = 8 },
			Callback = function(value)
				local n = tonumber(value) or type(value) == "table" and tonumber(value.Value)

				if n then
					dodge.maxDistance = n
				end
			end,
		})
	end

	-- ===== Touch Fling =====
	-- Walk into a player and they are sent flying, while you stay exactly where you are (nobody is teleported).
	-- This is the same method as the other script's WalkFling: every frame your velocity is multiplied by 10000
	-- (and pushed up) for a moment right when your movement is sent to the other players, then your own velocity
	-- is put straight back, so you feel and see nothing, but anyone who touches you is thrown away.
	do
		local RunService_ = game:GetService("RunService")
		local tf = { on = false, token = 0 }
		list2.touchFling = tf

		list2.setTouchFling = function(on)
			on = on and true or false

			if tf.on == on then
				return
			end

			tf.on = on
			tf.token += 1

			if on then
				local token = tf.token

				task.spawn(function()
					local nudge = 0.1

					local function alive()
						if not tf.on or tf.token ~= token then
							return nil
						end

						local character = localPlayer.Character
						local humanoid = character and character:FindFirstChildOfClass("Humanoid")
						local hrp = humanoid and humanoid.RootPart

						if character and character.Parent and humanoid and humanoid.Health > 0 and hrp and hrp.Parent then
							return hrp
						end
					end

					while tf.on and tf.token == token do
						RunService_.Heartbeat:Wait()

						local hrp = alive()

						if hrp then
							local vel = hrp.Velocity
							hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)

							RunService_.RenderStepped:Wait()

							-- ALWAYS put the real velocity back, even if the switch was turned off during this
							-- frame. Otherwise the huge velocity stays on you and flings YOU across the map.
							if hrp.Parent then
								hrp.Velocity = vel
							end

							RunService_.Stepped:Wait()

							if tf.on and tf.token == token and hrp.Parent then
								hrp.Velocity = vel + Vector3.new(0, nudge, 0)
								nudge = -nudge
							end
						end
					end
				end)
			end

			-- keep the floating button and the switch in step with each other
			pcall(function()
				num15.setActive("TouchFling", on)
			end)

			pcall(function()
				list2.setToggle(list2.touchFlingToggle, on)
			end)
		end

		tbl43.combat:Section({ Title = "Knockback" })

		list2.touchFlingToggle = tbl43.combat:Toggle({
			Title = "Touch Fling",
			Flag = "Toggle_Touch_Fling",
			Desc = "Walk into a player and they are sent flying. You are not moved and nobody is teleported. Works on whoever touches you, so it also hits people who run into you.",
			Type = "Toggle",
			Value = false,
			Callback = function(value)
				if list2.setTouchFling then
					list2.setTouchFling(value)
				end
			end,
		})
	end

	-- ===== Whitelist / Blacklist =====
	-- Whitelist: friends that Auto Shoot, Silent Aim, Triggerbot and Kill Aura never attack.
	-- Blacklist: players they attack first. The two text boxes are saved with your config; the dropdown + buttons just edit them.
	do
		local wb = list2.wb
		local pickName, pickDrop, whiteInput, blackInput, summary

		local function names(set)
			local out = {}

			for name in pairs(set) do
				out[#out + 1] = name
			end

			table.sort(out)

			return out
		end

		local function refreshSummary()
			if not summary then
				return
			end

			local white = #names(wb.white) > 0 and table.concat(names(wb.white), ", ") or "-"
			local black = #names(wb.black) > 0 and table.concat(names(wb.black), ", ") or "-"
			local text = "Whitelist: " .. white .. "\nBlacklist: " .. black

			if wb.friends then
				text = text .. "\nAll your Roblox friends are whitelisted too."
			end

			pcall(function()
				summary:Set(text)
			end)
		end

		local function playerNames()
			local out = {}

			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= localPlayer then
					out[#out + 1] = player.Name
				end
			end

			return out
		end

		-- put `name` on one list (key = "white" / "black") or on none (key = nil); a player is never on both
		local function setList(name, key)
			local lower = tostring(name or ""):lower()

			if lower == "" then
				return
			end

			wb.white[lower] = nil
			wb.black[lower] = nil

			if key then
				wb[key][lower] = true
			end

			pcall(function()
				whiteInput:Set(table.concat(names(wb.white), ", "))
			end)

			pcall(function()
				blackInput:Set(table.concat(names(wb.black), ", "))
			end)

			refreshSummary()
		end

		tbl43.combat:Section({ Title = "Whitelist / Blacklist" })

		summary = tbl43.combat:Label({ Text = "Whitelist: -\nBlacklist: -" })

		tbl43.combat:Toggle({
			Title = "Whitelist Roblox Friends",
			Flag = "Toggle_WB_Friends",
			Desc = "Every Roblox friend of yours that is in the server is treated as whitelisted.",
			Type = "Toggle",
			Value = false,
			Callback = function(on)
				wb.friends = on

				if on then
					for _, player in ipairs(Players:GetPlayers()) do
						wb.queryFriend(player)
					end
				end

				refreshSummary()
			end,
		})

		pickDrop = tbl43.combat:Dropdown({
			Title = "Player",
			Desc = "Pick someone in the server, then use the buttons below.",
			Multi = false,
			Value = nil,
			Values = playerNames(),
			Callback = function(value)
				pickName = value
			end,
		})

		tbl43.combat:Button({
			Title = "Add to Whitelist",
			Desc = "Auto Shoot, Silent Aim, Triggerbot and Kill Aura will never attack this player.",
			Icon = "shield",
			Callback = function()
				setList(pickName, "white")
			end,
		})

		tbl43.combat:Button({
			Title = "Add to Blacklist",
			Desc = "This player is attacked first (Kill Aura stabs them first; a zombie / murderer on the list is shot before the others).",
			Icon = "crosshair",
			Callback = function()
				setList(pickName, "black")
			end,
		})

		tbl43.combat:Button({
			Title = "Remove From Both Lists",
			Desc = "Takes the picked player off the whitelist and the blacklist.",
			Icon = "x",
			Callback = function()
				setList(pickName, nil)
			end,
		})

		whiteInput = tbl43.combat:Input({
			Title = "Whitelist (names, comma separated)",
			Flag = "Input_WB_White",
			Desc = "Account names or display names. Works for people who are not in the server yet.",
			Placeholder = "e.g. Friend1, Friend2",
			Callback = function(value)
				wb.white = wb.parse(value)
				refreshSummary()
			end,
		})

		blackInput = tbl43.combat:Input({
			Title = "Blacklist (names, comma separated)",
			Flag = "Input_WB_Black",
			Desc = "Account names or display names of the players to attack first.",
			Placeholder = "e.g. Enemy1, Enemy2",
			Callback = function(value)
				wb.black = wb.parse(value)
				refreshSummary()
			end,
		})

		local function refreshPlayers()
			pcall(function()
				pickDrop:Refresh(playerNames())
			end)
		end

		list2.conns[#list2.conns + 1] = Players.PlayerAdded:Connect(function(player)
			if wb.friends then
				wb.queryFriend(player)
			end

			refreshPlayers()
		end)

		list2.conns[#list2.conns + 1] = Players.PlayerRemoving:Connect(refreshPlayers)
	end

	-- ===== Kill Aura (murderer) =====
	-- While you hold the knife, everyone alive within the distance below is stabbed automatically, over and over.
	-- (The same stab messages the "Kill All" button sends, but only for players close to you and without any key.)
	do
		local RunService_ = game:GetService("RunService")
		local ka = { on = false, distance = 15, conn = nil, last = 0 }

		tbl43.combat:Section({ Title = "Kill Aura" })

		tbl43.combat:Toggle({
			Title = "Kill Aura",
			Flag = "Toggle_Kill_Aura",
			Desc = "Murderer / Zombie: while you hold the knife, everyone within the distance below is stabbed automatically (zombies skip other zombies). Whitelisted players are skipped, blacklisted ones are stabbed first.",
			Type = "Toggle",
			Value = false,
			Callback = function(on)
				ka.on = on

				if ka.conn then
					ka.conn:Disconnect()
					ka.conn = nil
				end

				if not on then
					return
				end

				ka.conn = RunService_.Heartbeat:Connect(function()
					if os.clock() - ka.last < 0.12 then
						return
					end

					ka.last = os.clock()

					pcall(function()
						local character = localPlayer.Character
						local hrp = character and character:FindFirstChild("HumanoidRootPart")
						local knife = character and character:FindFirstChild("Knife")
						local events = knife and knife:FindFirstChild("Events")
						local stab = events and events:FindFirstChild("KnifeStabbed")
						local touched = events and events:FindFirstChild("HandleTouched")

						if not (hrp and stab and touched) then
							return
						end

						local ordered = Players:GetPlayers()

						-- black-listed players are stabbed first
						if list2.wb.active() then
							table.sort(ordered, function(a, b)
								local aBlack, bBlack = list2.wb.isBlack(a), list2.wb.isBlack(b)

								if aBlack ~= bBlack then
									return aBlack
								end

								return false
							end)
						end

						for _, player in ipairs(ordered) do
							local otherCharacter = player ~= localPlayer and player.Character
							local otherHrp = otherCharacter and otherCharacter:FindFirstChild("HumanoidRootPart")
							local otherHumanoid = otherCharacter and otherCharacter:FindFirstChildOfClass("Humanoid")

							if otherHrp and otherHumanoid and otherHumanoid.Health > 0
								and not (list2.isRole(localPlayer, "Zombie") and list2.isRole(player, "Zombie"))
								and not list2.wb.isWhite(player)
								and (otherHrp.Position - hrp.Position).Magnitude <= ka.distance then
								pcall(function()
									stab:FireServer()
								end)

								pcall(function()
									touched:FireServer(otherHrp)
								end)
							end
						end
					end)
				end)
				list2.conns[#list2.conns + 1] = ka.conn
			end,
		})

		tbl43.combat:Slider({
			Title = "Kill Aura Distance",
			Flag = "Slider_Kill_Aura_Distance",
			Desc = "How close (studs) a player has to be to get stabbed.",
			Step = 1,
			Value = { Min = 5, Max = 60, Default = 15 },
			Callback = function(value)
				local n = tonumber(value) or type(value) == "table" and tonumber(value.Value)

				if n then
					ka.distance = n
				end
			end,
		})
	end

	tbl43.combat:Section({ Title = "Murderer — you have the knife" })
	local n4 = 0

	UserInputService.InputBegan:Connect(function()
		n4 = os.clock()
	end)

	local function func196()
		return os.clock() - n4 < 1
	end

	num17.on = true
	num17.start()

	list2.knifeEls[#list2.knifeEls + 1] = tbl43.combat:Slider({
		Title = "Change Knife Hitbox  (OP!)",
		Flag = "Slider_Change_Knife_Hitbox",
		Desc = "Change the size of your Knife! (1 is default hitbox)",
		Step = 1,
		Value = { Min = 1, Max = 200, Default = 1 },
		Callback = function(value)
			local num32 = tonumber(value) or type(value) == "table" and tonumber(value.Value)

			if num32 then
				num17.setMult(num32)
			end
		end,
	})

	list2.knifeEls[#list2.knifeEls + 1] = tbl43.combat:Toggle({
		Title = "Show Hitbox",
		Flag = "Toggle_Show_Hitbox",
		Desc = "Draws the reach as a sphere.",
		Type = "Toggle",
		Value = false,
		Callback = function(show)
			if not func196() then
				return
			end
			num17.show = show

			if show then
				num17.showBall()
			else
				num17.hideBall()
			end
		end,
	})

	list2.knifeEls[#list2.knifeEls + 1] = tbl43.combat:Toggle({
		Title = "Silent Throw",
		Flag = "Toggle_Silent_Throw",
		Desc = "Right click throws the knife at the nearest player. Murderer only.",
		Type = "Toggle",
		Value = false,
		Callback = function(on)
			flag83.on = on

			if on then
				flag83.start()
			else
				flag83.stop()
			end
		end,
	})

	killTargetDropdown = tbl43.combat:Dropdown({
		Title = "Target",
		Desc = "Pick who to stab, then use the button below.",
		Multi = false,
		Value = nil,
		Values = func121(),
		Callback = function(value)
			selectedKillTarget = value
		end,
	})
end

list2.knifeEls[#list2.knifeEls + 1] = killTargetDropdown

list2.knifeEls[#list2.knifeEls + 1] = tbl43.combat:Button({
	Title = "Kill Target",
	Desc = "Instantly stabs the player picked above.",
	Callback = function()
		func76(selectedKillTarget)
	end,
})

list2.knifeEls[#list2.knifeEls + 1] = tbl43.combat:Button({
	Title = "Kill All",
	Desc = "Instantly stabs every player in the server.",
	Callback = function()
		func77()
	end,
})

do
	local RunService_ = game:GetService("RunService")
	local autoKill = { on = false, conn = nil, perFrame = 50 } -- fixed, always full speed

	list2.knifeEls[#list2.knifeEls + 1] = tbl43.combat:Toggle({
		Title = "Auto Kill All",
		Flag = "Toggle_Auto_Kill_All",
		Desc = "Murderer: keeps stabbing every player in the server, nonstop, at full speed. Off by default.",
		Type = "Toggle",
		Value = false,
		Callback = function(on)
			autoKill.on = on

			if autoKill.conn then
				autoKill.conn:Disconnect()
				autoKill.conn = nil
			end

			if not on then
				return
			end

			-- every frame: one target list, then `perFrame` stabs on all of them
			autoKill.conn = RunService_.Heartbeat:Connect(function()
				if not autoKill.on or not list2.killAllBurst then
					return
				end

				pcall(list2.killAllBurst, autoKill.perFrame)
			end)

			list2.conns[#list2.conns + 1] = autoKill.conn
		end,
	})
end

list2.knifeEls[#list2.knifeEls + 1] = tbl43.combat:Button({
	Title = "Kill Nearest",
	Desc = "Murderer: stabs the closest living player.",
	Icon = "sword",
	Callback = function()
		if list2.killNearest then
			list2.killNearest()
		end
	end,
})

func118("Kill All", Color3.fromHex("#7F1D1D"), 0.25)
func118("Kill Nearest", Color3.fromHex("#7F1D1D"), 0.25)
func120(ICON.mono)
func118("Change Knife Hitbox  (OP!)", Color3.fromHex("#7F1D1D"), 0.25)

list2.perf = {
	LIGHTING = game:GetService("Lighting"),
	UNCAPPED = 999,
	on = {
		textures = false,
		effects = false,
		weaponfx = false,
		pets = false,
		anims = false,
		lighting = false,
		terrain = false,
		sounds = false,
		quality = false,
		fpsCounter = false,
	},
	el = {},
	stash = {
		parent = {},
		part = {},
		texid = {},
		volume = {},
		enabled = {},
		post = {},
		light = nil,
		terrain = nil,
		quality = nil,
	},
	animConns = {},
	watchConn = nil,
	playerConn = nil,
	owner = {},
}

list2.perf.ours = function(obj)
	while obj do
		if obj.Name:sub(1, 3) == "FVL" then
			return true
		end
		obj = obj.Parent
	end

	return false
end

list2.perf.FX = {
	ParticleEmitter = true,
	Trail = true,
	Smoke = true,
	Fire = true,
	Sparkles = true,
	Beam = true,
	Explosion = true,
	PointLight = true,
	SpotLight = true,
	SurfaceLight = true,
}

list2.perf.reparent = function(obj, parent)
	obj.Parent = parent
end

list2.perf.restorePart = function(obj, tbl98)
	local second4 = tbl98[2]
	local third1 = tbl98[3]
	obj.Material = tbl98[1]
	obj.CastShadow = second4
	obj.Reflectance = third1
end

list2.perf.CHUNK = 75
list2.perf.sweeping = false

list2.perf.breathe = function(num33)
	if num33 % list2.perf.CHUNK == 0 then
		task.wait()
	end
end

list2.perf.keysOf = function(param133)
	local tbl99 = {}
	local n4 = 0

	for k in next, param133, nil do
		n4 += 1
		tbl99[n4] = k
	end

	return tbl99, n4
end

list2.perf.readProp = function(tbl100, param134)
	return tbl100[param134]
end

list2.perf.TERRAIN = {
	{ "Decoration", false },
	{ "WaterWaveSize", 0 },
	{ "WaterWaveSpeed", 0 },
	{ "WaterReflectance", 0 },
	{ "WaterTransparency", 1 },
}

list2.perf.setProp = function(tbl101, param135, param136)
	tbl101[param135] = param136
end

list2.perf.detach = function(obj, param137)
	if list2.perf.stash.parent[obj] ~= nil then
		return
	end
	local parent = obj.Parent
	if not parent then
		return
	end
	list2.perf.stash.parent[obj] = parent
	list2.perf.owner[obj] = param137
	pcall(list2.perf.reparent, obj, nil)
end

list2.perf.stripTexture = function(obj)
	if obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("SurfaceAppearance") then
		list2.perf.detach(obj, "textures")
	elseif obj:IsA("SpecialMesh") then
		if list2.perf.stash.texid[obj] == nil and obj.TextureId ~= "" then
			list2.perf.stash.texid[obj] = obj.TextureId
			pcall(list2.perf.setProp, obj, "TextureId", "")
		end
	elseif obj:IsA("BasePart") and not obj:IsA("Terrain") then
		if list2.perf.stash.part[obj] == nil then
			list2.perf.stash.part[obj] = { obj.Material, obj.CastShadow, obj.Reflectance }
			obj.Material = Enum.Material.SmoothPlastic
			obj.CastShadow = false
			obj.Reflectance = 0
		end
	end
end

list2.perf.clearEmitter = function(obj26)
	obj26:Clear()
end

list2.perf.killFX = function(obj, param138)
	if obj:IsA("ParticleEmitter") then
		if list2.perf.stash.enabled[obj] == nil then
			list2.perf.stash.enabled[obj] = obj.Enabled
		end

		obj.Enabled = false
		pcall(list2.perf.clearEmitter, obj)
	end

	list2.perf.detach(obj, param138)
end

list2.perf.stripEffect = function(obj)
	if list2.perf.FX[obj.ClassName] then
		list2.perf.killFX(obj, "effects")
	end
end

list2.perf.stripWeaponFX = function(list44)
	for _, descendant in ipairs(list44:GetDescendants()) do
		if list2.perf.FX[descendant.ClassName] then
			list2.perf.killFX(descendant, "weaponfx")
		end
	end
end

list2.perf.stripSound = function(obj)
	if obj:IsA("Sound") and list2.perf.stash.volume[obj] == nil then
		list2.perf.stash.volume[obj] = obj.Volume
		pcall(list2.perf.setProp, obj, "Volume", 0)
	end
end

list2.perf.hookAnimator = function(obj)
	if list2.perf.animConns[obj] then
		return
	end

	pcall(function()
		for _, getPlayingAnimationTrack in ipairs(obj:GetPlayingAnimationTracks()) do
			getPlayingAnimationTrack:Stop(0)
		end
	end)

	local ok, result = pcall(function()
		return obj.AnimationPlayed:Connect(function(obj27)
			if not list2.perf.on.anims then
				return
			end

			pcall(function()
				obj27:Stop(0)
			end)
		end)
	end)

	if ok and result then
		list2.perf.animConns[obj] = result
	end
end

list2.perf.apply = function(obj)
	if list2.perf.ours(obj) then
		return
	end

	if list2.perf.on.textures then
		list2.perf.stripTexture(obj)
	end

	if list2.perf.on.effects then
		list2.perf.stripEffect(obj)
	end

	if list2.perf.on.sounds then
		list2.perf.stripSound(obj)
	end

	if list2.perf.on.anims and obj:IsA("Animator") then
		list2.perf.hookAnimator(obj)
	end

	if list2.perf.on.weaponfx then
		if obj:IsA("Tool") then
			list2.perf.stripWeaponFX(obj)
		elseif list2.perf.FX[obj.ClassName] and obj:FindFirstAncestorWhichIsA("Tool") then
			list2.perf.killFX(obj, "weaponfx")
		end
	end

	if list2.perf.on.pets then
		local parent = obj.Parent

		if parent and parent.Name == "PetContainer" then
			list2.perf.detach(obj, "pets")
		end
	end
end

list2.perf.queue = {}
list2.perf.queueN = 0
list2.perf.drainThread = nil
list2.perf.qHead = 1

list2.perf.enqueue = function(param139)
	local queueN = list2.perf.queueN + 1
	list2.perf.queueN = queueN
	list2.perf.queue[queueN] = param139
end

list2.perf.drainStep = function()
	local queue = list2.perf.queue
	local qHead = list2.perf.qHead
	local queueN = list2.perf.queueN

	if queueN < qHead then
		if queueN > 0 then
			local perf = list2.perf
			local perf2 = list2.perf
			list2.perf.queue = {}
			perf.queueN = 0
			perf2.qHead = 1
		end

		return
	end

	local n4 = qHead + list2.perf.CHUNK - 1

	if not (n4 > queueN) then
		queueN = n4
	end

	for i = qHead, queueN do
		list2.perf.safeApply(queue[i])
		queue[i] = nil
	end

	list2.perf.qHead = queueN + 1
end

list2.perf.stopDrain = function()
	if list2.perf.drainThread then
		pcall(task.cancel, list2.perf.drainThread)
		list2.perf.drainThread = nil
	end

	local perf = list2.perf
	local perf2 = list2.perf
	list2.perf.queue = {}
	perf.queueN = 0
	perf2.qHead = 1
end

list2.perf.startDrain = function()
	list2.perf.stopDrain()

	list2.perf.drainThread = task.spawn(function()
		while true do
			task.wait()
			local ok, result = pcall(list2.perf.drainStep)

			if not ok then
				warn("[FVL] performance queue: " .. tostring(result))
			end
		end
	end)
end

list2.perf.safeApply = function(param140)
	pcall(list2.perf.apply, param140)
end

list2.perf.sweepBody = function()
	local descendants = Workspace:GetDescendants()

	for i = 1, #descendants do
		list2.perf.safeApply(descendants[i])
		list2.perf.breathe(i)
	end

	if list2.perf.on.weaponfx then
		local descendants2 = localPlayer:GetDescendants()

		for i = 1, #descendants2 do
			local entry22 = descendants2[i]

			if entry22:IsA("Tool") then
				pcall(list2.perf.stripWeaponFX, entry22)
			end

			list2.perf.breathe(i)
		end
	end
end

list2.perf.resweep = false

list2.perf.sweep = function()
	if list2.perf.sweeping then
		list2.perf.resweep = true
		return
	end
	list2.perf.sweeping = true

	while true do
		list2.perf.resweep = false
		local ok, result = pcall(list2.perf.sweepBody)

		if not ok then
			warn("[FVL] performance sweep: " .. tostring(result))
		end

		if list2.perf.resweep then
			continue
		end
		break
	end

	list2.perf.sweeping = false
end

list2.perf.PROP_STASHES = { "part", "volume", "texid", "enabled" }

list2.perf.prune = function()
	local n4 = 0

	for _, propStashe in ipairs(list2.perf.PROP_STASHES) do
		local tbl102 = list2.perf.stash[propStashe]

		if tbl102 then
			local tbl103, value207 = list2.perf.keysOf(tbl102)

			for i = 1, value207 do
				local entry23 = tbl103[i]
				local ok, result = pcall(list2.perf.readProp, entry23, "Parent")

				if not ok or result == nil then
					tbl102[entry23] = nil
					n4 += 1
				end

				list2.perf.breathe(i)
			end
		end
	end

	local tbl104, value208 = list2.perf.keysOf(list2.perf.stash.parent)

	for i = 1, value208 do
		local entry24 = tbl104[i]
		local flag188 = list2.perf.stash.parent[entry24]

		if flag188 ~= nil then
			local ok, result = pcall(list2.perf.inGame, flag188)

			if not ok or not result then
				list2.perf.stash.parent[entry24] = nil
				list2.perf.owner[entry24] = nil
				n4 += 1
			end
		end

		list2.perf.breathe(i)
	end

	return n4
end

list2.perf.inGame = function(obj28)
	return obj28:IsDescendantOf(game)
end

list2.perf.PULSE = 10
list2.perf.pulseThread = nil

list2.perf.stopPulse = function()
	if list2.perf.pulseThread then
		pcall(task.cancel, list2.perf.pulseThread)
		list2.perf.pulseThread = nil
	end

	list2.perf.sweeping = false
end

list2.perf.startPulse = function()
	list2.perf.stopPulse()

	list2.perf.pulseThread = task.spawn(function()
		while true do
			task.wait(list2.perf.PULSE)
			local ok, result = pcall(list2.perf.sweep)

			if not ok then
				warn("[FVL] performance re-sweep: " .. tostring(result))
			end

			local ok2, result2 = pcall(list2.perf.prune)

			if not ok2 then
				warn("[FVL] performance prune: " .. tostring(result2))
			end
		end
	end)
end

list2.perf.syncWatcher = function()
	local textures = list2.perf.on.textures or list2.perf.on.effects or list2.perf.on.sounds or list2.perf.on.anims or list2.perf.on.weaponfx or list2.perf.on.pets

	if textures and not list2.perf.watchConn then
		list2.perf.watchConn = Workspace.DescendantAdded:Connect(list2.perf.enqueue)
		list2.perf.startDrain()
		list2.perf.startPulse()
	elseif not textures and list2.perf.watchConn then
		pcall(function()
			list2.perf.watchConn:Disconnect()
		end)

		list2.perf.watchConn = nil
		list2.perf.stopDrain()
		list2.perf.stopPulse()
	end

	if list2.perf.on.weaponfx and not list2.perf.playerConn then
		list2.perf.playerConn = localPlayer.DescendantAdded:Connect(list2.perf.enqueue)
	elseif not list2.perf.on.weaponfx and list2.perf.playerConn then
		pcall(function()
			list2.perf.playerConn:Disconnect()
		end)

		list2.perf.playerConn = nil
	end
end

list2.perf.restoreOwned = function(param141)
	local tbl105, value209 = list2.perf.keysOf(list2.perf.stash.parent)

	for i = 1, value209 do
		local entry25 = tbl105[i]
		local flag189 = list2.perf.stash.parent[entry25]

		if flag189 ~= nil and list2.perf.owner[entry25] == param141 then
			pcall(list2.perf.reparent, entry25, flag189)
			list2.perf.stash.parent[entry25] = nil
			list2.perf.owner[entry25] = nil
		end

		list2.perf.breathe(i)
	end
end

list2.perf.restoreEnabled = function(param142)
	local tbl106, value210 = list2.perf.keysOf(list2.perf.stash.enabled)

	for i = 1, value210 do
		local entry26 = tbl106[i]
		local flag190 = list2.perf.stash.enabled[entry26]

		if flag190 ~= nil and list2.perf.owner[entry26] == param142 then
			pcall(list2.perf.setProp, entry26, "Enabled", flag190)
			list2.perf.stash.enabled[entry26] = nil
		end

		list2.perf.breathe(i)
	end
end

list2.perf.restoreTextures = function()
	list2.perf.restoreOwned("textures")
	local tbl107, value211 = list2.perf.keysOf(list2.perf.stash.texid)

	for i = 1, value211 do
		local entry27 = tbl107[i]
		local flag191 = list2.perf.stash.texid[entry27]

		if flag191 ~= nil then
			if entry27.Parent then
				pcall(list2.perf.setProp, entry27, "TextureId", flag191)
			end

			list2.perf.stash.texid[entry27] = nil
		end

		list2.perf.breathe(i)
	end

	local tbl108, value212 = list2.perf.keysOf(list2.perf.stash.part)

	for i = 1, value212 do
		local entry28 = tbl108[i]
		local flag192 = list2.perf.stash.part[entry28]

		if flag192 ~= nil then
			if entry28.Parent then
				pcall(list2.perf.restorePart, entry28, flag192)
			end

			list2.perf.stash.part[entry28] = nil
		end

		list2.perf.breathe(i)
	end
end

list2.perf.features = {}

do
	local perf = list2.perf
	local perf2 = list2.perf
	list2.perf.gui = nil
	perf.label = nil
	perf2.fpsConn = nil
end

list2.perf.killCounter = function()
	if list2.perf.fpsConn then
		pcall(function()
			list2.perf.fpsConn:Disconnect()
		end)

		list2.perf.fpsConn = nil
	end

	if list2.perf.dragConn then
		pcall(function()
			list2.perf.dragConn:Disconnect()
		end)

		list2.perf.dragConn = nil
	end

	if list2.perf.gui then
		pcall(function()
			list2.perf.gui:Destroy()
		end)

		list2.perf.gui = nil
	end

	list2.perf.label = nil
end

list2.perf.buildCounter = function()
	list2.perf.killCounter()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "FVLFPSButton"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 9000
	screenGui.Parent = CoreGui
	local textButton = Instance.new("TextButton")
	textButton.AutoButtonColor = false
	textButton.Text = ""
	textButton.AnchorPoint = Vector2.new(0.5, 0)
	textButton.Position = list2.perf.fpsPos or list2.hudStart("__fps", UDim2.new(0.5, 0, 0, 6))
	textButton.Size = UDim2.fromOffset(72, 26)
	textButton.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
	textButton.BackgroundTransparency = 0.25
	textButton.BorderSizePixel = 0
	textButton.Parent = screenGui
	list2.hudBtns["__fps"] = textButton
	Instance.new("UICorner", textButton).CornerRadius = UDim.new(0, 8)
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 1
	uiStroke.Color = Color3.fromRGB(255, 255, 255)
	uiStroke.Transparency = 0.85
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = textButton
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextSize = 13
	textLabel.Text = "-- FPS"
	textLabel.TextColor3 = Color3.fromRGB(240, 240, 246)
	textLabel.Parent = textButton
	local perf = list2.perf
	list2.perf.gui = screenGui
	perf.label = textLabel
	local flag193 = false
	local value213 = nil
	local value214 = nil

	textButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local position = input.Position
			local position2 = textButton.Position
			flag193 = true
			value213 = position
			value214 = position2
		end
	end)

	textButton.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			flag193 = false
			list2.perf.fpsPos = textButton.Position
		end
	end)

	list2.perf.dragConn = UserInputService.InputChanged:Connect(function(input)
		if not flag193 then
			return
		end

		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local n4 = input.Position - value213
		textButton.Position = UDim2.new(value214.X.Scale, value214.X.Offset + n4.X, value214.Y.Scale, value214.Y.Offset + n4.Y)
	end)

	local n4 = 0
	local now = os.clock()

	list2.perf.fpsConn = RunService.RenderStepped:Connect(function()
		n4 += 1
		local now2 = os.clock()
		local n5 = now2 - now
		if n5 < 0.5 then
			return
		end
		local n6 = math.floor(n4 / n5 + 0.5)
		n4 = 0
		now = now2
		textLabel.Text = n6 .. " FPS"
		textLabel.TextColor3 = n6 >= 50 and ICON.green or n6 >= 30 and ICON.yellow or ICON.red
	end)
end

list2.perf.batch = false

list2.perf.set = function(str34, flag194)
	local flag195 = flag194 and true or false
	if list2.perf.on[str34] == flag195 then
		return
	end
	local flag196 = list2.perf.features[str34]
	if not flag196 then
		return
	end
	list2.perf.on[str34] = flag195
	if list2.perf.batch and flag195 and flag196.sweeps then
		return
	end
	local ok, result = pcall(flag195 and flag196.on or flag196.off)

	if not ok then
		warn("[FVL] performance '" .. str34 .. "' failed: " .. tostring(result))
	end

	list2.perf.syncWatcher()
end

list2.perf.MASTER = {
	"fpsCounter",
	"textures",
	"effects",
	"weaponfx",
	"pets",
	"anims",
	"lighting",
	"terrain",
	"sounds",
	"quality",
}

list2.perf.MIRRORS = { "master", "masterFarm" }
list2.perf.settingAll = false

list2.perf.setAll = function(param143)
	if list2.perf.settingAll then
		return
	end
	list2.perf.settingAll = true
	list2.perf.sweeping = false
	list2.perf.batch = true

	local ok, result = pcall(function()
		for _, item63 in ipairs(list2.perf.MASTER) do
			list2.setToggle(list2.perf.el[item63], param143)
			list2.perf.set(item63, param143)
		end
	end)

	for _, mirror in ipairs(list2.perf.MIRRORS) do
		list2.setToggle(list2.perf.el[mirror], param143)
	end

	list2.perf.batch = false
	list2.perf.settingAll = false

	if not ok then
		warn("[FVL] performance master failed: " .. tostring(result))
	end

	if param143 then
		pcall(list2.perf.sweep)
	end

	list2.perf.syncWatcher()
end

list2.perf.restoreAll = function()
	list2.perf.stopPulse()
	list2.perf.stopDrain()

	for k in next, list2.perf.features, nil do
		list2.perf.set(k, false)
	end

	list2.perf.killCounter()

	if list2.perf.capped then
		list2.perf.capped = false

		pcall(function()
			if setfpscap then
				setfpscap(list2.perf.UNCAPPED)
			end
		end)
	end
end

list2.perf.el.masterFarm = list2.perfFarmToggle
-- ===== Shaders: Morning, Afternoon and Rain =====
-- Ported from the Resonance shader preset script you sent (its own UI library is not loaded; the switches live
-- here in the Visuals tab instead). Morning / Afternoon change the lighting, colour grading, bloom, sun rays and the
-- time of day; Rain adds falling rain, splashes on the ground, a rain sky, clouds, a damp atmosphere and the sound
-- of rain. Everything is local to you, and every switch puts back exactly what it changed.
do
	local Lighting_ = game:GetService("Lighting")
	local RunService_ = game:GetService("RunService")

	local activePreset = nil
	local originalLighting = nil
	local originalPartShadows = {}
	local shadowAddedConnection = nil
	local ownedEffects = {}
	local presetAtmosphere = nil -- an Atmosphere that already existed and that a preset changed: { object, values }

	-- rain
	local rainEnabled = false
	local rainFolder = nil
	local rainConnection = nil
	local rainSound = nil
	local originalAtmosphere = nil
	local rainVolume = 1.6
	local originalSky = nil
	local rainSky = nil
	local rainClouds = nil
	local rainCloudsOwned = false
	local originalCloudsValues = nil

	local lightingProperties = {
		"Ambient", "Brightness", "ColorShift_Bottom", "ColorShift_Top",
		"ExposureCompensation", "FogColor", "FogEnd", "FogStart",
		"OutdoorAmbient", "ShadowSoftness", "GlobalShadows", "Technology",
		"ClockTime", "TimeOfDay", "EnvironmentDiffuseScale", "EnvironmentSpecularScale",
	}

	local presets = {
		Morning = {
			Brightness = 2.4,
			Exposure = 0.15,
			Saturation = 0.08,
			TintColor = Color3.fromRGB(255, 231, 202),
			Ambient = Color3.fromRGB(115, 99, 91),
			OutdoorAmbient = Color3.fromRGB(165, 145, 125),
			ColorShiftTop = Color3.fromRGB(255, 202, 145),
			ColorShiftBottom = Color3.fromRGB(80, 62, 54),
			FogColor = Color3.fromRGB(235, 190, 153),
			FogEnd = 1800,
			ShadowSoftness = 0.25,
			SunRaysIntensity = 0.08,
			ClockTime = 7.5, -- 07:30, morning
		},
		Afternoon = {
			Brightness = 2.8,
			Exposure = 0.05,
			Saturation = 0.12,
			TintColor = Color3.fromRGB(232, 245, 255),
			Ambient = Color3.fromRGB(120, 120, 120),
			OutdoorAmbient = Color3.fromRGB(155, 165, 175),
			ColorShiftTop = Color3.fromRGB(220, 238, 255),
			ColorShiftBottom = Color3.fromRGB(80, 90, 105),
			FogColor = Color3.fromRGB(190, 215, 235),
			FogEnd = 2500,
			ShadowSoftness = 0.35,
			SunRaysIntensity = 0.06,
			ClockTime = 14.0, -- 14:00, afternoon
		},
	}

	local function saveOriginalLighting()
		local values = {}

		for _, property in ipairs(lightingProperties) do
			pcall(function()
				values[property] = Lighting_[property]
			end)
		end

		return values
	end

	-- give back an Atmosphere that a preset changed (one the preset created itself is deleted by clearEffects)
	local function restorePresetAtmosphere()
		if presetAtmosphere and presetAtmosphere.object and presetAtmosphere.object.Parent then
			for property, value in pairs(presetAtmosphere.values) do
				pcall(function()
					presetAtmosphere.object[property] = value
				end)
			end
		end

		presetAtmosphere = nil
	end

	local function clearEffects()
		for _, effect in ipairs(ownedEffects) do
			if effect and effect.Parent then
				effect:Destroy()
			end
		end

		table.clear(ownedEffects)
	end

	local function stopRain()
		rainEnabled = false

		if rainConnection then
			rainConnection:Disconnect()
			rainConnection = nil
		end

		if rainSound then
			rainSound:Stop()
			rainSound:Destroy()
			rainSound = nil
		end

		if rainFolder then
			rainFolder:Destroy()
			rainFolder = nil
		end

		-- give the original sky back
		if rainSky then
			rainSky:Destroy()
			rainSky = nil
		end

		if rainClouds then
			if rainCloudsOwned then
				rainClouds:Destroy()
			elseif originalCloudsValues then
				for property, value in pairs(originalCloudsValues) do
					pcall(function()
						rainClouds[property] = value
					end)
				end
			end

			rainClouds = nil
			rainCloudsOwned = false
			originalCloudsValues = nil
		end

		if originalSky then
			for _, sky in ipairs(originalSky) do
				if sky then
					sky.Parent = Lighting_
				end
			end

			originalSky = nil
		end

		-- give the atmosphere back
		local atmosphere = Lighting_:FindFirstChildOfClass("Atmosphere")

		if atmosphere and originalAtmosphere then
			for property, value in pairs(originalAtmosphere) do
				pcall(function()
					atmosphere[property] = value
				end)
			end

			originalAtmosphere = nil
		end
	end

	local function startRain()
		if rainEnabled then
			return
		end

		rainEnabled = true

		local camera = workspace.CurrentCamera

		-- keep the current sky aside and put the rain sky in
		originalSky = {}

		for _, child in ipairs(Lighting_:GetChildren()) do
			if child:IsA("Sky") then
				table.insert(originalSky, child)
				child.Parent = nil
			end
		end

		rainSky = Instance.new("Sky")
		rainSky.Name = "FVLRainSky"
		rainSky.SkyboxBk = "rbxassetid://1618912481"
		rainSky.SkyboxFt = "rbxassetid://1618913244"
		rainSky.SkyboxLf = "rbxassetid://1618912849"
		rainSky.SkyboxRt = "rbxassetid://1618911568"
		rainSky.SkyboxUp = "rbxassetid://1618913654"
		rainSky.SkyboxDn = "rbxassetid://1618913943"
		rainSky.Parent = Lighting_

		-- clouds
		local existingClouds = Lighting_:FindFirstChildOfClass("Clouds")

		if existingClouds then
			rainClouds = existingClouds
			rainCloudsOwned = false
			originalCloudsValues = {
				Cover = existingClouds.Cover,
				Density = existingClouds.Density,
				Color = existingClouds.Color,
			}
		else
			rainClouds = Instance.new("Clouds")
			rainClouds.Name = "FVLRainClouds"
			rainClouds.Parent = Lighting_
			rainCloudsOwned = true
		end

		rainClouds.Cover = 0.6
		rainClouds.Density = 0.5
		rainClouds.Color = Color3.fromRGB(225, 246, 217)

		-- everything rain-related lives in one model
		rainFolder = Instance.new("Model")
		rainFolder.Name = "FVLRain"
		rainFolder.Parent = workspace

		-- the part the raindrops fall from
		local drops = Instance.new("Part")
		drops.Name = "RainDrops"
		drops.Size = Vector3.new(512, 20, 512)
		drops.Anchored = true
		drops.CanCollide = false
		drops.CanQuery = false
		drops.CanTouch = false
		drops.Transparency = 1
		drops.Parent = rainFolder

		-- many emitters = thick rain with big drops
		for i = 1, 38 do
			local particle = Instance.new("ParticleEmitter")
			particle.Name = "RainDrop_" .. i
			particle.Texture = "rbxassetid://241868005"
			particle.Rate = 1e5
			particle.Lifetime = NumberRange.new(30)
			particle.Speed = NumberRange.new(-100)
			particle.Size = NumberSequence.new(7)
			particle.Color = ColorSequence.new(Color3.fromRGB(59, 124, 185), Color3.fromRGB(71, 126, 177))
			particle.LightEmission = 1
			particle.LightInfluence = 0
			particle.Orientation = Enum.ParticleOrientation.FacingCamera
			particle.EmissionDirection = Enum.NormalId.Top
			particle.Enabled = true
			particle.Parent = drops
		end

		-- the part that makes splashes where the rain hits the ground
		local splashes = Instance.new("Part")
		splashes.Name = "RainSplashes"
		splashes.Size = Vector3.new(512, 0.05, 512)
		splashes.Anchored = true
		splashes.CanCollide = false
		splashes.CanQuery = false
		splashes.CanTouch = false
		splashes.Transparency = 1
		splashes.Parent = rainFolder

		for i = 1, 4 do
			local particle = Instance.new("ParticleEmitter")
			particle.Name = "Splash_" .. i
			particle.Texture = "rbxassetid://241576804"
			particle.Rate = 1e7
			particle.Lifetime = NumberRange.new(0.4, 0.7)
			particle.Speed = NumberRange.new(2, 5)
			particle.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.3, 1.5),
				NumberSequenceKeypoint.new(1, 3.5),
			})
			particle.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.08, 0.15),
				NumberSequenceKeypoint.new(0.4, 0.45),
				NumberSequenceKeypoint.new(1, 1),
			})
			particle.Color = ColorSequence.new(Color3.fromRGB(180, 200, 230), Color3.fromRGB(140, 170, 210))
			particle.Acceleration = Vector3.new(0, -20, 0)
			particle.Orientation = Enum.ParticleOrientation.FacingCamera
			particle.LightEmission = 0.15
			particle.Enabled = true
			particle.Parent = splashes
		end

		-- ripples on the ground
		for i = 1, 2 do
			local particle = Instance.new("ParticleEmitter")
			particle.Name = "Ripple_" .. i
			particle.Texture = "rbxassetid://241576804"
			particle.Rate = 8000
			particle.Lifetime = NumberRange.new(0.6, 1.0)
			particle.Speed = NumberRange.new(0.5, 1.5)
			particle.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.5),
				NumberSequenceKeypoint.new(0.5, 2.5),
				NumberSequenceKeypoint.new(1, 4.5),
			})
			particle.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.3),
				NumberSequenceKeypoint.new(0.5, 0.6),
				NumberSequenceKeypoint.new(1, 1),
			})
			particle.Color = ColorSequence.new(Color3.fromRGB(200, 220, 240))
			particle.Orientation = Enum.ParticleOrientation.FacingCamera
			particle.LightEmission = 0.2
			particle.Enabled = true
			particle.Parent = splashes
		end

		-- the sound of rain
		rainSound = Instance.new("Sound")
		rainSound.Name = "FVLRainSound"
		rainSound.SoundId = "rbxassetid://3786250088"
		rainSound.Looped = true
		rainSound.Volume = rainVolume
		rainSound.RollOffMaxDistance = 10000
		rainSound.RollOffMinDistance = 10
		rainSound.Parent = rainFolder
		rainSound:Play()

		-- the rain and the splashes follow the camera
		rainConnection = RunService_.RenderStepped:Connect(function()
			local currentCamera = workspace.CurrentCamera

			if not currentCamera or not rainFolder then
				return
			end

			local cf = currentCamera.CFrame

			if drops and drops.Parent then
				drops.CFrame = cf + cf.LookVector * 10 + Vector3.new(0, 5, 0)
			end

			if splashes and splashes.Parent then
				-- put the splashes on the ground under the camera
				local rayParams = RaycastParams.new()
				rayParams.FilterDescendantsInstances = { rainFolder }
				rayParams.FilterType = Enum.RaycastFilterType.Exclude
				local result = workspace:Raycast(cf.Position, Vector3.new(0, -80, 0), rayParams)
				local groundY = result and result.Position.Y or (cf.Position.Y - 8)
				splashes.CFrame = CFrame.new(cf.Position.X, groundY + 0.05, cf.Position.Z)
			end
		end)

		-- a damp, rainy atmosphere
		local atmosphere = Lighting_:FindFirstChildOfClass("Atmosphere")

		if not atmosphere then
			atmosphere = Instance.new("Atmosphere")
			atmosphere.Name = "FVLAtmosphere"
			atmosphere.Parent = Lighting_
			table.insert(ownedEffects, atmosphere)
		end

		if not originalAtmosphere then
			originalAtmosphere = {
				Density = atmosphere.Density,
				Offset = atmosphere.Offset,
				Color = atmosphere.Color,
				Decay = atmosphere.Decay,
				Glare = atmosphere.Glare,
				Haze = atmosphere.Haze,
			}
		end

		atmosphere.Density = 0.45
		atmosphere.Offset = 0.18
		atmosphere.Color = Color3.fromRGB(130, 145, 165)
		atmosphere.Decay = Color3.fromRGB(85, 95, 115)
		atmosphere.Glare = 0.1
		atmosphere.Haze = 2.0

		-- damper fog
		if not activePreset then
			Lighting_.FogColor = Color3.fromRGB(120, 135, 155)
			Lighting_.FogStart = 0
			Lighting_.FogEnd = 800
			Lighting_.Brightness = math.clamp(Lighting_.Brightness * 0.85, 0.7, 3)
		else
			Lighting_.FogEnd = math.min(Lighting_.FogEnd, 1100)
			Lighting_.FogColor = Color3.fromRGB(
				math.floor(Lighting_.FogColor.R * 255 * 0.7),
				math.floor(Lighting_.FogColor.G * 255 * 0.75),
				math.floor(Lighting_.FogColor.B * 255 * 0.8)
			)
		end
	end

	-- puts back the lighting / shadows of the preset only (the rain stays)
	local function restorePresetOnly()
		if shadowAddedConnection then
			shadowAddedConnection:Disconnect()
			shadowAddedConnection = nil
		end

		restorePresetAtmosphere()
		clearEffects()

		-- clean-up: remove any glow light left behind by the earlier "brighter fires" version
		for _, leftover in ipairs(workspace:GetDescendants()) do
			if leftover.Name == "FVLFireGlow" then
				leftover:Destroy()
			end
		end

		for part, oldValue in pairs(originalPartShadows) do
			if part and part.Parent then
				pcall(function()
					part.CastShadow = oldValue
				end)
			end
		end

		table.clear(originalPartShadows)

		if originalLighting then
			for property, value in pairs(originalLighting) do
				pcall(function()
					Lighting_[property] = value
				end)
			end

			originalLighting = nil
		end

		activePreset = nil
	end

	local function makeEffect(className, properties)
		local effect = Instance.new(className)
		effect.Name = "FVLPreset_" .. className

		for property, value in pairs(properties) do
			effect[property] = value
		end

		effect.Parent = Lighting_
		table.insert(ownedEffects, effect)
	end

	local function applyPreset(presetName)
		local preset = presets[presetName]

		if not preset then
			return
		end

		-- the original values are saved only the first time, so switching morning <-> afternoon never loses them
		if not originalLighting then
			originalLighting = saveOriginalLighting()
		else
			restorePresetAtmosphere()
			clearEffects()
		end

		activePreset = presetName

		pcall(function()
			Lighting_.Technology = Enum.Technology.Future
		end)

		Lighting_.GlobalShadows = true
		Lighting_.Brightness = preset.Brightness
		Lighting_.ExposureCompensation = preset.Exposure
		Lighting_.Ambient = preset.Ambient
		Lighting_.OutdoorAmbient = preset.OutdoorAmbient
		Lighting_.ColorShift_Top = preset.ColorShiftTop
		Lighting_.ColorShift_Bottom = preset.ColorShiftBottom
		Lighting_.FogColor = preset.FogColor
		Lighting_.FogStart = 0
		Lighting_.FogEnd = preset.FogEnd
		Lighting_.ShadowSoftness = preset.ShadowSoftness

		if preset.ClockTime then
			Lighting_.ClockTime = preset.ClockTime
		end

		if preset.EnvironmentDiffuseScale then
			pcall(function()
				Lighting_.EnvironmentDiffuseScale = preset.EnvironmentDiffuseScale
			end)
		end

		if preset.EnvironmentSpecularScale then
			pcall(function()
				Lighting_.EnvironmentSpecularScale = preset.EnvironmentSpecularScale
			end)
		end

		local function enablePartShadow(instance)
			if instance:IsA("BasePart") and originalPartShadows[instance] == nil then
				originalPartShadows[instance] = instance.CastShadow
				instance.CastShadow = true
			end
		end

		for _, instance in ipairs(workspace:GetDescendants()) do
			enablePartShadow(instance)
		end

		if shadowAddedConnection then
			shadowAddedConnection:Disconnect()
		end

		shadowAddedConnection = workspace.DescendantAdded:Connect(enablePartShadow)

		makeEffect("ColorCorrectionEffect", {
			Saturation = preset.Saturation,
			Contrast = preset.Contrast or 0.12,
			Brightness = preset.CCBrightness or 0.01,
			TintColor = preset.TintColor,
		})

		local bloom = preset.Bloom or { Intensity = 0.16, Size = 22, Threshold = 1.15 }
		makeEffect("BloomEffect", {
			Intensity = bloom.Intensity,
			Size = bloom.Size,
			Threshold = bloom.Threshold,
		})

		makeEffect("SunRaysEffect", {
			Intensity = preset.SunRaysIntensity,
			Spread = preset.SunRaysSpread or 0.72,
		})

		if preset.DepthOfField then
			makeEffect("DepthOfFieldEffect", {
				FarIntensity = preset.DepthOfField.FarIntensity,
				FocusDistance = preset.DepthOfField.FocusDistance,
				InFocusRadius = preset.DepthOfField.InFocusRadius,
				NearIntensity = preset.DepthOfField.NearIntensity,
			})
		end

		-- the warm glowing air of the sunrise
		if preset.Atmosphere then
			local atmosphere = Lighting_:FindFirstChildOfClass("Atmosphere")

			if atmosphere then
				presetAtmosphere = {
					object = atmosphere,
					values = {
						Density = atmosphere.Density,
						Offset = atmosphere.Offset,
						Color = atmosphere.Color,
						Decay = atmosphere.Decay,
						Glare = atmosphere.Glare,
						Haze = atmosphere.Haze,
					},
				}
			else
				atmosphere = Instance.new("Atmosphere")
				atmosphere.Name = "FVLPreset_Atmosphere"
				atmosphere.Parent = Lighting_
				table.insert(ownedEffects, atmosphere)
			end

			for property, value in pairs(preset.Atmosphere) do
				atmosphere[property] = value
			end
		end

		-- rain already on: keep the fog matching the rain
		if rainEnabled then
			Lighting_.FogEnd = math.min(Lighting_.FogEnd, 1100)
		end
	end

	tbl43.visuals:Section({ Title = "Shaders" })

	local morningToggle
	local afternoonToggle

	morningToggle = tbl43.visuals:Toggle({
		Title = "Morning Shader",
		Flag = "Toggle_Shader_Morning",
		Desc = "Warm morning light: golden tint, soft shadows, sun rays and the time set to 07:30.",
		Type = "Toggle",
		Value = false,
		Callback = function(enabled)
			if enabled then
				applyPreset("Morning")

				-- the two looks exclude each other: switch the other switch off too
				pcall(function()
					list2.setToggle(afternoonToggle, false)
				end)
			elseif activePreset == "Morning" then
				restorePresetOnly()
			end
		end,
	})

	afternoonToggle = tbl43.visuals:Toggle({
		Title = "Afternoon Shader",
		Flag = "Toggle_Shader_Afternoon",
		Desc = "Bright afternoon light: vivid colours, cool tint, sun rays and the time set to 14:00.",
		Type = "Toggle",
		Value = false,
		Callback = function(enabled)
			if enabled then
				applyPreset("Afternoon")

				pcall(function()
					list2.setToggle(morningToggle, false)
				end)
			elseif activePreset == "Afternoon" then
				restorePresetOnly()
			end
		end,
	})

	tbl43.visuals:Toggle({
		Title = "Rain",
		Flag = "Toggle_Shader_Rain",
		Desc = "Falling rain, splashes and ripples on the ground, a rain sky, clouds, a damp atmosphere and the sound of rain.",
		Type = "Toggle",
		Value = false,
		Callback = function(enabled)
			if enabled then
				startRain()
			elseif rainEnabled then
				stopRain()
			end
		end,
	})

	tbl43.visuals:Slider({
		Title = "Rain Volume",
		Flag = "Slider_Shader_Rain_Volume",
		Desc = "How loud the rain sounds.",
		Step = 0.05,
		Value = { Min = 0, Max = 3, Default = 1.6 },
		Callback = function(value)
			local n = tonumber(value) or type(value) == "table" and tonumber(value.Value)

			if n then
				rainVolume = n

				if rainSound and rainSound.Parent then
					rainSound.Volume = rainVolume
				end
			end
		end,
	})
end

-- ===== World & Camera =====
-- Features that the other hub has and this script did not: Fullbright, Time Changer, Custom Fog, Custom FOV and
-- Aspect Ratio. Everything is local to your screen and every switch puts back what it changed.
do
	local Lighting_ = game:GetService("Lighting")
	local RunService_ = game:GetService("RunService")

	tbl43.visuals:Section({ Title = "World & Camera" })

	-- ---------- Fullbright ----------
	local fb = { saved = nil, conn = nil }

	tbl43.visuals:Toggle({
		Title = "Fullbright",
		Flag = "Toggle_Fullbright",
		Desc = "Everything is lit evenly: no dark corners, no shadows.",
		Type = "Toggle",
		Value = false,
		Callback = function(on)
			if fb.conn then
				fb.conn:Disconnect()
				fb.conn = nil
			end

			if on then
				fb.saved = fb.saved or {
					Brightness = Lighting_.Brightness,
					Ambient = Lighting_.Ambient,
					OutdoorAmbient = Lighting_.OutdoorAmbient,
					GlobalShadows = Lighting_.GlobalShadows,
				}

				fb.conn = RunService_.RenderStepped:Connect(function()
					Lighting_.Brightness = 2
					Lighting_.Ambient = Color3.new(1, 1, 1)
					Lighting_.OutdoorAmbient = Color3.new(1, 1, 1)
					Lighting_.GlobalShadows = false
				end)
				list2.conns[#list2.conns + 1] = fb.conn
			elseif fb.saved then
				for property, value in pairs(fb.saved) do
					pcall(function()
						Lighting_[property] = value
					end)
				end

				fb.saved = nil
			end
		end,
	})

	-- ---------- Time Changer ----------
	local tc = { on = false, time = 12, saved = nil, conn = nil }

	tbl43.visuals:Toggle({
		Title = "Time Changer",
		Flag = "Toggle_Time_Changer",
		Desc = "Locks the time of day to the hour chosen below.",
		Type = "Toggle",
		Value = false,
		Callback = function(on)
			tc.on = on

			if tc.conn then
				tc.conn:Disconnect()
				tc.conn = nil
			end

			if on then
				tc.saved = tc.saved or Lighting_.ClockTime
				tc.conn = RunService_.RenderStepped:Connect(function()
					Lighting_.ClockTime = tc.time
				end)
				list2.conns[#list2.conns + 1] = tc.conn
			elseif tc.saved then
				Lighting_.ClockTime = tc.saved
				tc.saved = nil
			end
		end,
	})

	tbl43.visuals:Slider({
		Title = "Time Of Day",
		Flag = "Slider_Time_Of_Day",
		Desc = "Hour of the day (0 = midnight, 12 = noon).",
		Step = 0.1,
		Value = { Min = 0, Max = 24, Default = 12 },
		Callback = function(value)
			local n = tonumber(value) or type(value) == "table" and tonumber(value.Value)

			if n then
				tc.time = n
			end
		end,
	})

	-- ---------- Custom Fog ----------
	local fog = { on = false, start = 0, finish = 400, saved = nil, conn = nil }

	tbl43.visuals:Toggle({
		Title = "Custom Fog",
		Flag = "Toggle_Custom_Fog",
		Desc = "Sets how close the fog starts and how far it ends (sliders below).",
		Type = "Toggle",
		Value = false,
		Callback = function(on)
			fog.on = on

			if fog.conn then
				fog.conn:Disconnect()
				fog.conn = nil
			end

			if on then
				fog.saved = fog.saved or { FogStart = Lighting_.FogStart, FogEnd = Lighting_.FogEnd }
				fog.conn = RunService_.RenderStepped:Connect(function()
					Lighting_.FogStart = fog.start
					Lighting_.FogEnd = math.max(fog.finish, fog.start + 1)
				end)
				list2.conns[#list2.conns + 1] = fog.conn
			elseif fog.saved then
				for property, value in pairs(fog.saved) do
					pcall(function()
						Lighting_[property] = value
					end)
				end

				fog.saved = nil
			end
		end,
	})

	tbl43.visuals:Slider({
		Title = "Fog Start",
		Flag = "Slider_Fog_Start",
		Desc = "Distance (studs) where the fog begins.",
		Step = 5,
		Value = { Min = 0, Max = 2000, Default = 0 },
		Callback = function(value)
			local n = tonumber(value) or type(value) == "table" and tonumber(value.Value)

			if n then
				fog.start = n
			end
		end,
	})

	tbl43.visuals:Slider({
		Title = "Fog End",
		Flag = "Slider_Fog_End",
		Desc = "Distance (studs) where the fog is solid.",
		Step = 10,
		Value = { Min = 20, Max = 5000, Default = 400 },
		Callback = function(value)
			local n = tonumber(value) or type(value) == "table" and tonumber(value.Value)

			if n then
				fog.finish = n
			end
		end,
	})

	-- ---------- Custom FOV ----------
	local fov = { on = false, value = 70, saved = nil, conn = nil }

	tbl43.visuals:Toggle({
		Title = "Custom FOV",
		Flag = "Toggle_Custom_FOV",
		Desc = "Changes how wide the camera sees. Holds the value even if the game tries to change it.",
		Type = "Toggle",
		Value = false,
		Callback = function(on)
			fov.on = on

			if fov.conn then
				fov.conn:Disconnect()
				fov.conn = nil
			end

			local camera = workspace.CurrentCamera

			if on then
				fov.saved = fov.saved or (camera and camera.FieldOfView)
				fov.conn = RunService_.RenderStepped:Connect(function()
					local cam = workspace.CurrentCamera

					if cam then
						cam.FieldOfView = fov.value
					end
				end)
				list2.conns[#list2.conns + 1] = fov.conn
			elseif fov.saved and camera then
				camera.FieldOfView = fov.saved
				fov.saved = nil
			end
		end,
	})

	tbl43.visuals:Slider({
		Title = "FOV",
		Flag = "Slider_Custom_FOV",
		Desc = "Field of view in degrees (the game's normal is 70).",
		Step = 1,
		Value = { Min = 30, Max = 120, Default = 90 },
		Callback = function(value)
			local n = tonumber(value) or type(value) == "table" and tonumber(value.Value)

			if n then
				fov.value = n
			end
		end,
	})

	-- ---------- Aspect Ratio ----------
	local aspect = { on = false, value = 0.8 }

	tbl43.visuals:Toggle({
		Title = "Aspect Ratio",
		Flag = "Toggle_Aspect_Ratio",
		Desc = "Squeezes or stretches the picture vertically (the stretched-resolution look).",
		Type = "Toggle",
		Value = false,
		Callback = function(on)
			aspect.on = on

			pcall(function()
				RunService_:UnbindFromRenderStep("FVLAspectRatio")
			end)

			if on then
				-- right after the camera has been positioned for the frame
				RunService_:BindToRenderStep("FVLAspectRatio", Enum.RenderPriority.Camera.Value + 1, function()
					local cam = workspace.CurrentCamera

					if cam then
						cam.CFrame = cam.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, aspect.value, 0, 0, 0, 1)
					end
				end)
			end
		end,
	})

	tbl43.visuals:Slider({
		Title = "Aspect Ratio Amount",
		Flag = "Slider_Aspect_Ratio",
		Desc = "Below 1 = squeezed (wider look), above 1 = stretched.",
		Step = 0.05,
		Value = { Min = 0.3, Max = 1.5, Default = 0.8 },
		Callback = function(value)
			local n = tonumber(value) or type(value) == "table" and tonumber(value.Value)

			if n then
				aspect.value = n
			end
		end,
	})
end

tbl43.visuals:Section({ Title = "Performance Mode" })

tbl43.visuals:Paragraph({
	Title = "Read me first",
	Desc = "All client-side and fully reversible - switch it off and the map is back. Roughly 10-30% more frames.",
})

list2.perf.el.master = tbl43.visuals:Toggle({
	Title = "Performance Mode",
	Flag = "Toggle_Perf_Master",
	Desc = "Strips textures, shadows, particles, effects, pets, animations and sounds, and drops the graphics quality. Ugly, and fast.",
	Type = "Toggle",
	Value = false,
	Callback = func112(function(param144)
		list2.perf.setAll(param144)
	end),
})

list2.perf.features.fpsCounter = {
	on = function()
		list2.perf.buildCounter()
	end,
	off = function()
		list2.perf.killCounter()
	end,
}

list2.perf.el.fpsCounter = tbl43.visuals:Toggle({
	Title = "FPS Counter",
	Flag = "Toggle_Perf_FPS",
	Desc = "Live framerate at the top of the screen -- drag it anywhere. Green 50+, amber 30+, red below.",
	Type = "Toggle",
	Value = false,
	Callback = func112(function(param145)
		list2.perf.set("fpsCounter", param145)
	end),
})

list2.perf.features.textures = {
	sweeps = true,
	on = function()
		list2.perf.sweep()
	end,
	off = function()
		list2.perf.restoreTextures()
	end,
}

list2.perf.el.textures = tbl43.visuals:Toggle({
	Title = "Remove Textures",
	Flag = "Toggle_Perf_Textures",
	Desc = "Textures and decals off, every part flat, nothing casting a shadow. The biggest single win.",
	Type = "Toggle",
	Value = false,
	Callback = func112(function(param146)
		list2.perf.set("textures", param146)
	end),
})

list2.perf.features.effects = {
	sweeps = true,
	on = function()
		list2.perf.sweep()
	end,
	off = function()
		list2.perf.restoreEnabled("effects")
		list2.perf.restoreOwned("effects")
	end,
}

list2.perf.el.effects = tbl43.visuals:Toggle({
	Title = "Remove Particles & Effects",
	Flag = "Toggle_Perf_Effects",
	Desc = "Particles, trails, beams, smoke, fire and every dynamic light. F$VL's own ESP and crosshair stay.",
	Type = "Toggle",
	Value = false,
	Callback = func112(function(param147)
		list2.perf.set("effects", param147)
	end),
})

list2.perf.features.weaponfx = {
	sweeps = true,
	on = function()
		list2.perf.sweep()
	end,
	off = function()
		list2.perf.restoreEnabled("weaponfx")
		list2.perf.restoreOwned("weaponfx")
	end,
}

list2.perf.features.pets = {
	on = function()
		local petContainer = Workspace:FindFirstChild("PetContainer")

		if petContainer then
			for _, child in ipairs(petContainer:GetChildren()) do
				list2.perf.detach(child, "pets")
			end
		end
	end,
	off = function()
		list2.perf.restoreOwned("pets")
	end,
}

list2.perf.features.anims = {
	sweeps = true,
	on = function()
		list2.perf.sweep()
	end,
	off = function()
		for k, value215 in next, list2.perf.animConns, nil do
			pcall(function()
				value215:Disconnect()
			end)

			list2.perf.animConns[k] = nil
		end
	end,
}

list2.perf.el.anims = tbl43.visuals:Toggle({
	Title = "Remove Animations",
	Flag = "Toggle_Perf_Anims",
	Desc = "Freezes every animation. Everyone slides around, you included. Movement still works.",
	Type = "Toggle",
	Value = false,
	Callback = func112(function(param148)
		list2.perf.set("anims", param148)
	end),
})

list2.perf.features.sounds = {
	sweeps = true,
	on = function()
		list2.perf.sweep()
	end,
	off = function()
		local tbl109, value216 = list2.perf.keysOf(list2.perf.stash.volume)

		for i = 1, value216 do
			local entry29 = tbl109[i]
			local flag197 = list2.perf.stash.volume[entry29]

			if flag197 ~= nil then
				if entry29.Parent then
					pcall(list2.perf.setProp, entry29, "Volume", flag197)
				end

				list2.perf.stash.volume[entry29] = nil
			end

			list2.perf.breathe(i)
		end
	end,
}

list2.perf.el.sounds = tbl43.visuals:Toggle({
	Title = "Mute All Sounds",
	Flag = "Toggle_Perf_Sounds",
	Desc = "Mutes the map. You lose footsteps, so think twice as innocent.",
	Type = "Toggle",
	Value = false,
	Callback = func112(function(param149)
		list2.perf.set("sounds", param149)
	end),
})

list2.perf.features.lighting = {
	on = function()
		if not list2.perf.stash.light then
			list2.perf.stash.light = {
				shadows = list2.perf.LIGHTING.GlobalShadows,
				diffuse = list2.perf.LIGHTING.EnvironmentDiffuseScale,
				spec = list2.perf.LIGHTING.EnvironmentSpecularScale,
				soft = list2.perf.LIGHTING.ShadowSoftness,
			}
		end

		pcall(function()
			list2.perf.LIGHTING.GlobalShadows = false
			list2.perf.LIGHTING.EnvironmentDiffuseScale = 0
			list2.perf.LIGHTING.EnvironmentSpecularScale = 0
			list2.perf.LIGHTING.ShadowSoftness = 0
		end)

		for _, child in ipairs(list2.perf.LIGHTING:GetChildren()) do
			if child:IsA("PostEffect") then
				if list2.perf.stash.post[child] == nil then
					list2.perf.stash.post[child] = child.Enabled

					pcall(function()
						child.Enabled = false
					end)
				end
			elseif child:IsA("Atmosphere") then
				list2.perf.detach(child, "lighting")
			end
		end

		for _, child in ipairs(Workspace.Terrain:GetChildren()) do
			if child:IsA("Clouds") then
				list2.perf.detach(child, "lighting")
			end
		end
	end,
	off = function()
		local light = list2.perf.stash.light

		if light then
			pcall(function()
				list2.perf.LIGHTING.GlobalShadows = light.shadows
				list2.perf.LIGHTING.EnvironmentDiffuseScale = light.diffuse
				list2.perf.LIGHTING.EnvironmentSpecularScale = light.spec
				list2.perf.LIGHTING.ShadowSoftness = light.soft
			end)

			list2.perf.stash.light = nil
		end

		for k, value217 in next, list2.perf.stash.post, nil do
			pcall(function()
				if k.Parent then
					k.Enabled = value217
				end
			end)
		end

		list2.perf.stash.post = {}
		list2.perf.restoreOwned("lighting")
	end,
}

list2.perf.el.lighting = tbl43.visuals:Toggle({
	Title = "Remove Shadows & Lighting FX",
	Flag = "Toggle_Perf_Lighting",
	Desc = "Shadows, bloom, blur, sun rays, depth of field and clouds. Second biggest win after textures.",
	Type = "Toggle",
	Value = false,
	Callback = func112(function(param150)
		list2.perf.set("lighting", param150)
	end),
})

list2.perf.features.terrain = {
	on = function()
		local terrain = Workspace.Terrain
		list2.perf.stash.terrain = list2.perf.stash.terrain or {}

		for _, item64 in ipairs(list2.perf.TERRAIN) do
			local first4 = item64[1]
			local second5 = item64[2]
			local ok, result = pcall(list2.perf.readProp, terrain, first4)

			if ok and list2.perf.stash.terrain[first4] == nil then
				list2.perf.stash.terrain[first4] = result
				pcall(list2.perf.setProp, terrain, first4, second5)
			end
		end
	end,
	off = function()
		local terrain = list2.perf.stash.terrain
		if not terrain then
			return
		end
		local terrain2 = Workspace.Terrain

		for k, value218 in next, terrain, nil do
			pcall(list2.perf.setProp, terrain2, k, value218)
		end

		list2.perf.stash.terrain = nil
	end,
}

list2.perf.el.terrain = tbl43.visuals:Toggle({
	Title = "Flat Terrain & Water",
	Flag = "Toggle_Perf_Terrain",
	Desc = "Kills grass blades and the animated water waves.",
	Type = "Toggle",
	Value = false,
	Callback = func112(function(param151)
		list2.perf.set("terrain", param151)
	end),
})

list2.perf.features.quality = {
	on = function()
		if list2.perf.stash.quality == nil then
			pcall(function()
				list2.perf.stash.quality = settings().Rendering.QualityLevel
			end)
		end

		pcall(function()
			local level01 = Enum.QualityLevel.Level01
			settings().Rendering.QualityLevel = level01
		end)

		pcall(function()
			local qualityLevel1 = Enum.SavedQualitySetting.QualityLevel1
			UserSettings():GetService("UserGameSettings").SavedQualityLevel = qualityLevel1
		end)
	end,
	off = function()
		local quality = list2.perf.stash.quality

		if quality ~= nil then
			pcall(function()
				settings().Rendering.QualityLevel = quality
			end)

			list2.perf.stash.quality = nil
		end

		pcall(function()
			local automatic = Enum.SavedQualitySetting.Automatic
			UserSettings():GetService("UserGameSettings").SavedQualityLevel = automatic
		end)
	end,
}

list2.perf.el.quality = tbl43.visuals:Toggle({
	Title = "Lowest Graphics Quality",
	Flag = "Toggle_Perf_Quality",
	Desc = "Sets Roblox's own graphics slider to 1. Needs a level 8 executor.",
	Type = "Toggle",
	Value = false,
	Callback = func112(function(param152)
		list2.perf.set("quality", param152)
	end),
})

func120(ICON.mono)

do
	local tbl110 = { ToggleGUI = Enum.KeyCode.G }

	local tbl111 = {
		ToggleGUI = function()
			obj3:Toggle()
		end,
		Shoot = function()
			func67()
		end,
		Grab = function()
			func73()
		end,
		Throw = function()
			func68()
		end,
		Bomb = function()
			func71()
		end,
		Aimbot = function()
			num16.set(not num16.enabled)
		end,
		WallHop = function()
			func72()
		end,
		Noclip = function()
			list2.setToggle(list2.el.noclip, not flag41, function(param153)
				flag41 = param153

				if param153 then
					func39()
				else
					func40()
				end
			end)
		end,
		Fly = function()
			list2.setToggle(list2.el.fly, not flag42, function(param154)
				flag42 = param154

				if param154 then
					func41()
				else
					func42()
				end
			end)
		end,
		InfJump = function()
			list2.setToggle(list2.el.infjump, not flag43, function(param155)
				flag43 = param155

				if param155 then
					func43()
				else
					func44()
				end
			end)
		end,
		AntiFling = function()
			list2.setToggle(list2.el.antifling, not flag44, function(param156)
				flag44 = param156

				if param156 then
					func45()
				else
					func46()
				end
			end)
		end,
		Speed = function()
			local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
			func37(humanoid and humanoid.WalkSpeed ~= 16 and 16 or walkSpeed)
		end,
		Jump = function()
			local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
			func38(humanoid and humanoid.JumpPower ~= 50 and 50 or jumpPower)
		end,
		-- the floating buttons that had no key yet
		KillAll = function()
			func77()
		end,
		KillSheriff = function()
			if list2.killSheriff then
				list2.killSheriff()
			end
		end,
		FlingMurd = function()
			if list2.flingMurdHud then
				list2.flingMurdHud()
			end
		end,
		FlingSher = function()
			if list2.flingSherHud then
				list2.flingSherHud()
			end
		end,
		Xray = function()
			list2.setXray(not list2.xrayOn)
			pcall(num15.setActive, "Xray", list2.xrayOn)
		end,
		TPShoot = function()
			if list2.tpShootRun then
				list2.tpShootRun()
			end
		end,
		Invis = function()
			if list2.setInvisible then
				list2.setInvisible(not (list2.invis and list2.invis.on))
			end
		end,
		TouchFling = function()
			if list2.setTouchFling then
				list2.setTouchFling(not (list2.touchFling and list2.touchFling.on))
			end
		end,
	}

	keybindConn = UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		if input.KeyCode == Enum.KeyCode.Unknown then
			return
		end

		if UserInputService:GetFocusedTextBox() then
			return
		end

		for k, value219 in pairs(tbl110) do
			value219 = value219 and input.KeyCode == value219

			if value219 then
				local entry30 = tbl111[k]

				if entry30 then
					task.spawn(function()
						pcall(entry30)
					end)
				end
			end
		end
	end)

	local function func197(obj29, param157, param158, str35, param159)
		obj29:Keybind({
			Title = param157,
			Desc = param158,
			Flag = "Keybind_" .. str35,
			Value = param159,
			Callback = function(value)
				local ok, result = pcall(function()
					return Enum.KeyCode[value]
				end)

				if ok and result and result ~= Enum.KeyCode.Unknown then
					tbl110[str35] = result
				else
					tbl110[str35] = nil
				end
			end,
		})
	end

	tbl43.keybinds:Section({ Title = "Interface" })
	func197(tbl43.keybinds, "Toggle GUI", "Show or hide the window.", "ToggleGUI", "G")
	list2.UNBOUND = "Unbound - click to set a key. Ignore the key shown until you do."
	tbl43.keybinds:Section({ Title = "Actions" })
	func197(tbl43.keybinds, "Shoot Murderer", list2.UNBOUND, "Shoot", "Unknown")
	func197(tbl43.keybinds, "Grab Gun", list2.UNBOUND, "Grab", "Unknown")
	func197(tbl43.keybinds, "Throw Knife", list2.UNBOUND, "Throw", "Unknown")
	func197(tbl43.keybinds, "Bomb Jump", list2.UNBOUND, "Bomb", "Unknown")
	func197(tbl43.keybinds, "Toggle Aimbot", list2.UNBOUND, "Aimbot", "Unknown")
	tbl43.keybinds:Section({ Title = "Player" })
	func197(tbl43.keybinds, "Toggle Noclip", list2.UNBOUND, "Noclip", "Unknown")
	func197(tbl43.keybinds, "Toggle Fly", list2.UNBOUND, "Fly", "Unknown")
	func197(tbl43.keybinds, "Toggle Infinite Jump", list2.UNBOUND, "InfJump", "Unknown")
	func197(tbl43.keybinds, "Toggle Anti-Fling", list2.UNBOUND, "AntiFling", "Unknown")
	func197(tbl43.keybinds, "Toggle Walk Speed", list2.UNBOUND .. " Snaps between your slider speed and 16.", "Speed", "Unknown")
	func197(tbl43.keybinds, "Toggle Jump Power", list2.UNBOUND .. " Snaps between your slider jump and 50.", "Jump", "Unknown")
	func197(tbl43.keybinds, "Wall Hop", "Unbound — click to set a key. Ignore the key shown until you do.", "WallHop", "Unknown")

	tbl43.keybinds:Section({ Title = "More Actions" })
	func197(tbl43.keybinds, "Kill All (Murderer)", list2.UNBOUND, "KillAll", "Unknown")
	func197(tbl43.keybinds, "Kill Sheriff", list2.UNBOUND, "KillSheriff", "Unknown")
	func197(tbl43.keybinds, "Fling Murderer", list2.UNBOUND, "FlingMurd", "Unknown")
	func197(tbl43.keybinds, "Fling Sheriff", list2.UNBOUND, "FlingSher", "Unknown")
	func197(tbl43.keybinds, "TP Shoot Murderer", list2.UNBOUND, "TPShoot", "Unknown")
	func197(tbl43.keybinds, "Toggle Free X-Ray", list2.UNBOUND, "Xray", "Unknown")
	func197(tbl43.keybinds, "Toggle Invisible", list2.UNBOUND, "Invis", "Unknown")
	func197(tbl43.keybinds, "Toggle Touch Fling", list2.UNBOUND, "TouchFling", "Unknown")
end

tbl43.player:Section({ Title = "Speeds" })

tbl43.player:Slider({
	Title = "Walk Speed",
	Flag = "Slider_Walk_Speed",
	Desc = "How fast you walk — crank it to outrun the murderer",
	Step = 1,
	Value = { Min = 16, Max = 100, Default = 16 },
	Callback = function(value)
		func37(value)
	end,
})

tbl43.player:Slider({
	Title = "Jump Power",
	Flag = "Slider_Jump_Power",
	Desc = "How high you jump",
	Step = 1,
	Value = { Min = 50, Max = 200, Default = 50 },
	Callback = function(value)
		func38(value)
	end,
})

tbl43.player:Section({ Title = "Escape & Defense" })

list2.el.antifling = tbl43.player:Toggle({
	Title = "Anti-Fling",
	Flag = "Toggle_Anti_Fling",
	Desc = "Blocks other players from flinging you. On by default.",
	Type = "Toggle",
	Value = true,
	Callback = function(value)
		flag44 = value

		if value then
			func45()
			obj2:Notify({ Title = "Anti-Fling ON", Content = "Fling protection on!", Duration = 2, Icon = "shield" })
		else
			func46()

			obj2:Notify({
				Title = "Anti-Fling OFF",
				Content = "Fling protection off.",
				Duration = 2,
				Icon = "power-off",
			})
		end
	end,
})

list2.el.noclip = tbl43.player:Toggle({
	Title = "Noclip",
	Flag = "Toggle_Noclip",
	Desc = "Walk through walls",
	Type = "Toggle",
	Value = false,
	Callback = function(value)
		flag41 = value

		if value then
			func39()
		else
			func40()
		end

		if num15 then
			num15.setActive("Noclip", value)
		end
	end,
})

list2.el.infjump = tbl43.player:Toggle({
	Title = "Infinite Jump",
	Flag = "Toggle_Infinite_Jump",
	Desc = "Jump as many times as you want mid-air. The mode below chooses between holding the button or tapping.",
	Type = "Toggle",
	Value = false,
	Callback = function(value)
		flag43 = value

		if value then
			func43()
		else
			func44()
		end
	end,
})

list2.infJumpMode = list2.infJumpMode or "Hold"

tbl43.player:Dropdown({
	Title = "Infinite Jump Mode",
	Flag = "Dropdown_Infinite_Jump_Mode",
	Desc = "Hold: keep the jump button down to keep jumping. Tap: one jump per press, like before.",
	Multi = false,
	Value = "Hold",
	Values = { "Hold", "Tap" },
	Callback = function(value)
		local chosen = tostring(type(value) == "table" and (value[1] or value.Value) or value)

		if chosen == "Hold" or chosen == "Tap" then
			list2.infJumpMode = chosen
		end
	end,
})

list2.el.fly = tbl43.player:Toggle({
	Title = "Fly",
	Flag = "Toggle_Fly",
	Desc = "Fly around the map freely. WASD + Space / LeftShift",
	Type = "Toggle",
	Value = false,
	Callback = function(value)
		flag42 = value

		if value then
			func41()
		else
			func42()
		end

		if num15 then
			num15.setActive("Fly", value)
		end
	end,
})

tbl43.player:Slider({
	Title = "Fly Speed",
	Flag = "Slider_Fly_Speed",
	Desc = "How fast you fly",
	Step = 1,
	Value = { Min = 10, Max = 200, Default = 50 },
	Callback = function(value)
		n = value
	end,
})

list2.invisToggle = tbl43.player:Toggle({
	Title = "Invisible",
	Flag = "Toggle_Invisible",
	Desc = "Other players and the server see you far under the map; you still see and move normally (your body is half transparent on your screen). Touching coins and your own hits may not register while it is on.",
	Type = "Toggle",
	Value = false,
	Callback = function(value)
		if list2.setInvisible then
			list2.setInvisible(value)
		end
	end,
})

-- ===== Spin =====
-- Turns your character around on the spot, over and over, at the speed you choose (degrees per second).
-- Your position does not change, only which way you face. While it is on the character's own "turn towards
-- where I walk" is switched off so it does not fight the spin; it is switched back on when you turn Spin off.
do
	local RunService_ = game:GetService("RunService")
	local spin = { on = false, speed = 720, conn = nil, humanoid = nil, autoRotate = true }

	local function releaseHumanoid()
		if spin.humanoid and spin.humanoid.Parent then
			pcall(function()
				spin.humanoid.AutoRotate = spin.autoRotate
			end)
		end

		spin.humanoid = nil
	end

	local function setSpin(on)
		spin.on = on

		if spin.conn then
			spin.conn:Disconnect()
			spin.conn = nil
		end

		releaseHumanoid()

		if not on then
			return
		end

		spin.conn = RunService_.Stepped:Connect(function(_, dt)
			pcall(function()
				local character = localPlayer.Character
				local hrp = character and character:FindFirstChild("HumanoidRootPart")
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")

				if not hrp or not humanoid or humanoid.Health <= 0 then
					return
				end

				-- new character (respawn)? remember its setting and switch auto-turning off
				if spin.humanoid ~= humanoid then
					releaseHumanoid()
					spin.humanoid = humanoid
					spin.autoRotate = humanoid.AutoRotate
				end

				humanoid.AutoRotate = false
				hrp.AssemblyAngularVelocity = Vector3.zero
				hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spin.speed) * dt, 0)
			end)
		end)
	end

	tbl43.player:Toggle({
		Title = "Spin",
		Flag = "Toggle_Spin",
		Desc = "Turns your character around on the spot, non-stop. The speed is set below.",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			setSpin(value and true or false)
		end,
	})

	tbl43.player:Slider({
		Title = "Spin Speed",
		Flag = "Slider_Spin_Speed",
		Desc = "Degrees per second. 360 = one full turn every second.",
		Step = 10,
		Value = { Min = 30, Max = 3600, Default = 720 },
		Callback = function(value)
			local n = tonumber(value) or type(value) == "table" and tonumber(value.Value)

			if n then
				spin.speed = n
			end
		end,
	})
end

-- ===== Fun & Movement: China Hat, Bhop, Fake Headless =====
-- More features the other hub has and this script did not. All local to your screen.
do
	local RunService_ = game:GetService("RunService")
	local UserInputService_ = game:GetService("UserInputService")

	tbl43.player:Section({ Title = "Fun & Movement" })

	-- ---------- China Hat ----------
	-- A glowing cone sitting on top of your head. It only exists on your screen.
	local hat = { on = false, part = nil, conns = {} }

	local function removeHat()
		if hat.part then
			pcall(function()
				hat.part:Destroy()
			end)

			hat.part = nil
		end
	end

	local function buildHat(character)
		removeHat()
		local head = character and character:FindFirstChild("Head")

		if not head then
			return
		end

		local part = Instance.new("Part")
		part.Name = "FVLChinaHat"
		part.Size = Vector3.new(1.6, 1, 1.6)
		part.Material = Enum.Material.Neon
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Massless = true

		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.MeshId = "rbxassetid://1033714" -- a plain cone
		mesh.Scale = Vector3.new(1.7, 1.1, 1.7)
		mesh.Parent = part

		local weld = Instance.new("Weld")
		weld.Part0 = head
		weld.Part1 = part
		weld.C0 = CFrame.new(0, 0.9, 0)
		weld.Parent = part

		part.Parent = character
		hat.part = part
	end

	tbl43.player:Toggle({
		Title = "China Hat",
		Flag = "Toggle_China_Hat",
		Desc = "A glowing rainbow cone on top of your head (only you see it).",
		Type = "Toggle",
		Value = false,
		Callback = function(on)
			hat.on = on

			for i = #hat.conns, 1, -1 do
				pcall(function()
					hat.conns[i]:Disconnect()
				end)

				hat.conns[i] = nil
			end

			removeHat()

			if not on then
				return
			end

			buildHat(localPlayer.Character)

			hat.conns[#hat.conns + 1] = localPlayer.CharacterAdded:Connect(function(character)
				task.wait(1)

				if hat.on then
					buildHat(character)
				end
			end)

			hat.conns[#hat.conns + 1] = RunService_.Heartbeat:Connect(function()
				if hat.part and hat.part.Parent then
					hat.part.Color = Color3.fromHSV((os.clock() * 0.25) % 1, 0.85, 1)
				end
			end)
		end,
	})

	-- ---------- Bhop ----------
	-- Jump once (Space / jump button): after that single jump you are boosted forward at the speed set below
	-- for as long as you stay in the air. It no longer re-jumps for you when you land.
	local bhop = { on = false, speed = 28, conn = nil, jconn = nil, jumped = false, t = 0 }

	tbl43.player:Toggle({
		Title = "Bhop",
		Flag = "Toggle_Bhop",
		Desc = "Jump once and you dash forward at the Bhop Speed until you land. It does not jump again by itself.",
		Type = "Toggle",
		Value = false,
		Callback = function(on)
			bhop.on = on
			bhop.jumped = false

			if bhop.conn then
				bhop.conn:Disconnect()
				bhop.conn = nil
			end

			if bhop.jconn then
				bhop.jconn:Disconnect()
				bhop.jconn = nil
			end

			if not on then
				return
			end

			-- A real jump = jump input (Space / jump button) while standing on something.
			-- (The Humanoid's "Jumping" state only lasts a split second, so polling it in Heartbeat missed it.)
			bhop.jconn = UserInputService_.JumpRequest:Connect(function()
				pcall(function()
					local character = localPlayer.Character
					local humanoid = character and character:FindFirstChildOfClass("Humanoid")

					if humanoid and humanoid.Health > 0 and humanoid.FloorMaterial ~= Enum.Material.Air then
						bhop.jumped = true
						bhop.t = tick()
					end
				end)
			end)
			list2.conns[#list2.conns + 1] = bhop.jconn

			bhop.conn = RunService_.Heartbeat:Connect(function()
				pcall(function()
					local character = localPlayer.Character
					local humanoid = character and character:FindFirstChildOfClass("Humanoid")
					local hrp = character and character:FindFirstChild("HumanoidRootPart")

					if not humanoid or not hrp or humanoid.Health <= 0 then
						bhop.jumped = false
						return
					end

					-- no jump yet: nothing to do (walking off a ledge does not count)
					if not bhop.jumped then
						return
					end

					-- landed: stop boosting. Ignore the first moments of the jump, you still touch the floor then.
					if humanoid.FloorMaterial ~= Enum.Material.Air and tick() - bhop.t > 0.25 then
						bhop.jumped = false
						return
					end

					local direction = humanoid.MoveDirection

					if direction.Magnitude > 0.1 then
						local velocity = hrp.AssemblyLinearVelocity
						hrp.AssemblyLinearVelocity = Vector3.new(direction.X * bhop.speed, velocity.Y, direction.Z * bhop.speed)
					end
				end)
			end)
			list2.conns[#list2.conns + 1] = bhop.conn
		end,
	})

	tbl43.player:Slider({
		Title = "Bhop Speed",
		Flag = "Slider_Bhop_Speed",
		Desc = "How fast you move in the air while hopping.",
		Step = 1,
		Value = { Min = 16, Max = 80, Default = 28 },
		Callback = function(value)
			local n = tonumber(value) or type(value) == "table" and tonumber(value.Value)

			if n then
				bhop.speed = n
			end
		end,
	})

	-- ---------- Fake Headless ----------
	local headless = { on = false, saved = {}, conn = nil }

	local function applyHeadless(character, on)
		local head = character and character:FindFirstChild("Head")

		if not head then
			return
		end

		if on then
			if headless.saved[head] == nil then
				headless.saved[head] = head.Transparency
			end

			head.Transparency = 1

			for _, child in ipairs(head:GetChildren()) do
				if child:IsA("Decal") then
					if headless.saved[child] == nil then
						headless.saved[child] = child.Transparency
					end

					child.Transparency = 1
				end
			end
		else
			for object, value in pairs(headless.saved) do
				if object and object.Parent then
					object.Transparency = value
				end
			end

			table.clear(headless.saved)
		end
	end

	tbl43.troll:Section({ Title = "Fake Avatar" })

	if list2.mkKorblox then list2.mkKorblox() end

	tbl43.troll:Toggle({
		Title = "Fake Headless",
		Flag = "Toggle_Fake_Headless",
		Desc = "Hides your head and face on your own screen (other players still see them).",
		Type = "Toggle",
		Value = false,
		Callback = function(on)
			headless.on = on

			if headless.conn then
				headless.conn:Disconnect()
				headless.conn = nil
			end

			applyHeadless(localPlayer.Character, on)

			if on then
				headless.conn = localPlayer.CharacterAdded:Connect(function(character)
					task.wait(1)

					if headless.on then
						applyHeadless(character, true)
					end
				end)
				list2.conns[#list2.conns + 1] = headless.conn
			end
		end,
	})
end

-- ===== Emotes & Animations =====
-- A list of emotes you can play on your character (other players see them too, because they are played on your
-- own character), and animation packs that change how you idle, walk, run, jump, fall and climb.
-- Emotes and packs use R15 animations, so they need an R15 character.
do
	local EMOTES = {
		{ "Wave", 507770239 },
		{ "Point", 507770453 },
		{ "Cheer", 507770677 },
		{ "Laugh", 507770818 },
		{ "Dance 1", 507771019 },
		{ "Dance 2", 507776043 },
		{ "Dance 3", 507777268 },
		{ "Salute", 3360689775 },
		{ "Stadium", 3360686498 },
		{ "Tilt", 3360692915 },
		{ "Shrug", 3576968026 },
	}

	-- extra emotes and animation packs
	local MORE_EMOTES = {
		{ "2 Baddies Dance Move - NCT 127", 12259890638 },
		{ "24 Hour Cinderella", 122972776209997 },
		{ "Absolute Cinema", 97258018304125 },
		{ "Addendum Dance [R6]", 134442882516163 },
		{ "Agree", 4849487550 },
		{ "Ai Cat dance", 136593170936320 },
		{ "Air Dance", 4646302011 },
		{ "Air Guitar", 15506499986 },
		{ "Alo Yoga Pose - Lotus Position", 12507097350 },
		{ "Alo Yoga Pose - Triangle", 12507120275 },
		{ "Alo Yoga Pose - Warrior II", 12507106431 },
		{ "ALT\195\137GO - Couldn\226\128\153t Care Less", 92859581691366 },
		{ "Annyeong (\236\149\136\235\133\149)", 9528286240 },
		{ "AOK - Tai Verdes", 7942960760 },
		{ "Applaud", 5915779043 },
		{ "Arm Twist", 9710992846 },
		{ "Around Town", 3576747102 },
		{ "Assumptions", 127507691649322 },
		{ "At Ease", 76993139936388 },
		{ "Aura Farm Boat", 88042995626011 },
		{ "Aura Fly", 78755795767408 },
		{ "Ay-Yo Dance Move - NCT 127", 12804173616 },
		{ "baby", 82824758023484 },
		{ "Baby Dance", 4272484885 },
		{ "Baby Queen - Air Guitar & Knee Slide", 14353417553 },
		{ "Baby Queen - Bouncy Twirl", 14353423348 },
		{ "Baby Queen - Dramatic Bow", 14353419229 },
		{ "Baby Queen - Face Frame", 14353421343 },
		{ "Baby Queen - Strut", 14353425085 },
		{ "Ballin", 96293409369770 },
		{ "Barrel", 84511772437190 },
		{ "Be Not Afraid", 70635223083942 },
		{ "Beauty Touchdown", 16303091119 },
		{ "Beckon", 5230615437 },
		{ "Become A Car", 131544122623505 },
		{ "Become Couch", 93335594132613 },
		{ "Belly Dancing", 131939729732240 },
		{ "Biblically Accurate", 133596366979822 },
		{ "Billy Bounce", 126516908191316 },
		{ "BirdBrain", 105730788757021 },
		{ "BLACKPINK - How You Like That", 16874596971 },
		{ "BLACKPINK - Lovesick Girls", 16874600526 },
		{ "BLACKPINK As If It's Your Last", 18855603653 },
		{ "BLACKPINK Boombayah Emote", 16553259683 },
		{ "BLACKPINK DDU-DU DDU-DU", 16553262614 },
		{ "BLACKPINK Don't know what to do", 18855609889 },
		{ "BLACKPINK Ice Cream", 16181840356 },
		{ "BLACKPINK JENNIE You and Me", 15439457146 },
		{ "BLACKPINK JISOO Flower", 15439454888 },
		{ "BLACKPINK Kill This Love", 16181843366 },
		{ "BLACKPINK LISA Money", 15679957363 },
		{ "BLACKPINK Pink Venom - Get em Get em Get em", 14548709888 },
		{ "BLACKPINK Pink Venom - I Bring the Pain Like\226\128\166", 14548710952 },
		{ "BLACKPINK Pink Venom - Straight to Ya Dome", 14548711723 },
		{ "BLACKPINK ROS\195\137 On The Ground", 15679958535 },
		{ "BLACKPINK Shut Down - Part 1", 14901369589 },
		{ "BLACKPINK Shut Down - Part 2", 14901371589 },
		{ "Block Partier", 6865011755 },
		{ "Bodybuilder", 3994130516 },
		{ "Bone Chillin' Bop", 15123050663 },
		{ "Boom Boom Clap - George Ezra", 10370934040 },
		{ "Bored", 5230661597 },
		{ "Borock's Rage", 3236848555 },
		{ "Boxing Punch - KSI", 7202896732 },
		{ "Break Dance", 5915773992 },
		{ "Bubbly Sit", 112758073578333 },
		{ "Bunny Hop", 4646296016 },
		{ "BURBERRY LOLA ATTITUDE - BLOOM", 10147919199 },
		{ "BURBERRY LOLA ATTITUDE - GEM", 10147916560 },
		{ "BURBERRY LOLA ATTITUDE - HYDRO", 10147926081 },
		{ "BURBERRY LOLA ATTITUDE - NIMBUS", 10147924028 },
		{ "BURBERRY LOLA ATTITUDE - REFLEX", 10147921916 },
		{ "Caipirinha", 100165303717371 },
		{ "California Girl", 132074413582912 },
		{ "Car Transformation", 96887377943085 },
		{ "CaramellDansen", 93105950995997 },
		{ "Cartwheel - George Ezra", 10370929905 },
		{ "Cat Things", 131193808160056 },
		{ "Celebrate", 3994127840 },
		{ "Cha Cha", 6865013133 },
		{ "Cha-Cha", 3696764866 },
		{ "Chappell Roan HOT TO GO!", 79312439851071 },
		{ "Chicken Dance", 4849493309 },
		{ "Chill pose", 77058107325712 },
		{ "Chill Vibes - George Ezra", 10370918044 },
		{ "Chronoshift", 92600655160976 },
		{ "Club Penguin", 98099211500155 },
		{ "Cobra Arms - Tai Verdes", 7942964447 },
		{ "Come At Me [ R6 ]", 107758370940834 },
		{ "Confused", 4940592718 },
		{ "Conga", 97547955535086 },
		{ "Country Line Dance - Lil Nas X (LNX)", 5915780563 },
		{ "Cower", 4940597758 },
		{ "Cuco - Levitate", 15698511500 },
		{ "Curtsy", 4646306583 },
		{ "Cute Jump", 80556794144838 },
		{ "Cute Sit", 90244178386698 },
		{ "d4vd - Backflip", 15694504637 },
		{ "Dance n' Prance", 99031916674986 },
		{ "Dancin' Shoes - Twenty One Pilots", 7405123844 },
		{ "Dave's Spin Move - Glass Animals", 16276501655 },
		{ "DearALICE - Ariana", 133765015173412 },
		{ "Default Dance", 80877772569772 },
		{ "Deltarune - Tenna Dance", 73715378215546 },
		{ "Deltarune - Tenna Swing", 103139492736941 },
		{ "Die Lit", 121001502815813 },
		{ "Dio Pose", 76736978166708 },
		{ "Disagree", 4849495710 },
		{ "Dizzy", 3934986896 },
		{ "Do that thang", 113772829398170 },
		{ "Doggy Things", 105206768873249 },
		{ "Dolphin Dance", 5938365243 },
		{ "Doodle Dance", 107091254142209 },
		{ "Dorky Dance", 4212499637 },
		{ "Dropper", 130358790702800 },
		{ "Drum Master - Royal Blood", 6531538868 },
		{ "Drum Solo - Royal Blood", 6532844183 },
		{ "Drummer Moves - Twenty One Pilots", 7422838770 },
		{ "Electro Shuffle", 96426537876059 },
		{ "Elton John - Cat Man", 11435175895 },
		{ "Elton John - Elevate", 11394056822 },
		{ "Elton John - Heart Shuffle", 17748346932 },
		{ "Elton John - Heart Skip", 11309263077 },
		{ "Elton John - Piano Jump", 11453096488 },
		{ "Elton John - Rock Out", 11753545334 },
		{ "Elton John - Still Standing", 11435177473 },
		{ "ericdoa - dance", 15698510244 },
		{ "exclamation", 82714556886471 },
		{ "Family Guy", 78459263478161 },
		{ "Fancy Feet", 3934988903 },
		{ "Fancy Feets", 124512151372711 },
		{ "Fashion Klossette - Runway my way", 126683684984862 },
		{ "Fashion Roadkill", 73683655527605 },
		{ "Fashion Spin", 130046968468383 },
		{ "Fashionable", 3576745472 },
		{ "Fast Hands", 4272351660 },
		{ "Festive Dance", 15679955281 },
		{ "Fishing", 3994129128 },
		{ "Flex Walk", 15506506103 },
		{ "Floating on Clouds", 111426928948833 },
		{ "Floor Rock Freeze - Tommy Hilfiger", 10214411646 },
		{ "Flopping Fish", 133142324349281 },
		{ "Floss Dance", 5917570207 },
		{ "Flowing Breeze", 7466047578 },
		{ "Foreign Shuffle", 101507732056031 },
		{ "Frosty Flair - Tommy Hilfiger", 10214406616 },
		{ "Gangnam Style", 77205409178702 },
		{ "Garou", 86200585395371 },
		{ "Gashina - SUNMI", 9528294735 },
		{ "Get Out", 3934984583 },
		{ "GOALL", 78830825254717 },
		{ "Godlike", 3823158750 },
		{ "Golden Freddy", 122463450997235 },
		{ "Gon Rage", 139639173024927 },
		{ "Greatest", 3762654854 },
		{ "Griddy", 116065653184749 },
		{ "gun", 73562814360939 },
		{ "Gun Shoot", 105055412595333 },
		{ "Haha", 4102315500 },
		{ "Hakari (Forsaken)", 73271793399763 },
		{ "Hakari (FULL)", 71056659089869 },
		{ "Hakari (R6)", 127103118569243 },
		{ "Hakari Dance", 80270168146449 },
		{ "Hand Drill", 103882178542598 },
		{ "Happy", 4849499887 },
		{ "Head Juggling", 82224981519682 },
		{ "HeadBanging", 87447252507832 },
		{ "Heisman Pose", 3696763549 },
		{ "Helicopter", 84555218084038 },
		{ "Helicopter2", 119431985170060 },
		{ "Hello", 3576686446 },
		{ "Hero Landing", 5104377791 },
		{ "Hiding Human Box", 124935873390035 },
		{ "High Hands", 9710994651 },
		{ "High Wave", 5915776835 },
		{ "HIPMOTION - Amaarae", 16572756230 },
		{ "Hips Poppin' - Zara Larsson", 6797919579 },
		{ "HOLIDAY Dance - Lil Nas X (LNX)", 5938396308 },
		{ "Honored One", 121643381580730 },
		{ "house", 93552301087938 },
		{ "How A Creeper Walk", 108714986908463 },
		{ "HUGO Let's Drive!", 17360720445 },
		{ "Hwaiting (\237\153\148\236\157\180\237\140\133)", 9528291779 },
		{ "Hype Dance", 3696757129 },
		{ "Hyperfast 5G Dance Move", 9408642191 },
		{ "Idol", 4102317848 },
		{ "Imagine Dragons - \226\128\156Bones\226\128\157 Dance", 15689314578 },
		{ "Insanity", 129843344424281 },
		{ "Invisible", 109899950448992 },
		{ "Ishowspeed Shake Dancing", 138386881919239 },
		{ "It Ain't My Fault - Zara Larsson", 6797948622 },
		{ "Jacks", 3570649048 },
		{ "Jawny - Stomp", 16392120020 },
		{ "Jersey Joe", 134149640725489 },
		{ "Jersey Joe2", 115782117564871 },
		{ "Jumping Cheer", 5895009708 },
		{ "Jumping Wave", 4940602656 },
		{ "Jumpstyle", 99563839802389 },
		{ "KATSEYE - Touch", 139021427684680 },
		{ "Kawaii Groove", 77152953688098 },
		{ "Kazotsky", 97629500912487 },
		{ "Keeping Time", 4646306072 },
		{ "Kick It Dance Move - NCT 127", 12259888240 },
		{ "Kicking Feet Sit", 78758922757947 },
		{ "Lasso Turn - Tai Verdes", 7942972744 },
		{ "lemon melon cookie - Miku", 79874689836683 },
		{ "Lethal Dance", 77108921633993 },
		{ "Line Dance", 4049646104 },
		{ "Little Obbyist", 134584040095037 },
		{ "Locked In", 110145155419199 },
		{ "Louder", 3576751796 },
		{ "Luxurious / Springtrap", 132151459316300 },
		{ "M3GAN's Dance", 127271798262177 },
		{ "Macarena", 91274761264433 },
		{ "Mae Stephens - Piano Hands", 16553249658 },
		{ "Mae Stephens \226\128\147 Arm Wave", 16584496781 },
		{ "Magical Pose", 135489824748823 },
		{ "Man City Backflip", 13694140956 },
		{ "Man City Bicycle Kick", 13422286833 },
		{ "Man City Scorpion Kick", 13694139364 },
		{ "MANIAC - Stray Kids", 11309309359 },
		{ "Mean Girls Dance Break", 15963348695 },
		{ "Mean Mug - Tommy Hilfiger", 10214415687 },
		{ "Mesmerizer", 92707348383277 },
		{ "Mewing / Mogging", 135493514352956 },
		{ "Michael Myers", 88229016850146 },
		{ "Miku Dance", 117734400993750 },
		{ "Mini Kong", 17000058939 },
		{ "Monkey", 3716636630 },
		{ "NBA Monster Dunk", 117511481049460 },
		{ "NBA WNBA Fadeaway", 18526373545 },
		{ "Nicki Minaj Anaconda", 15571539403 },
		{ "Nicki Minaj Boom Boom Boom", 15571538346 },
		{ "Nicki Minaj Starships", 15571540519 },
		{ "Nicki Minaj That's That Super Bass Emote", 15571536896 },
		{ "Noclip, Speed", 137006085779408 },
		{ "Nya Anime Dance", 126647057611522 },
		{ "Nyan Nyan!", 73796726960568 },
		{ "Old Town Road Dance - Lil Nas X (LNX)", 5938394742 },
		{ "Olivia Rodrigo Fall Back to Float", 15554016057 },
		{ "Olivia Rodrigo good 4 u", 15554013003 },
		{ "Olivia Rodrigo Head Bop", 15554010118 },
		{ "Olympic Dismount", 18666650035 },
		{ "Omniman Think", 70560694892323 },
		{ "On The Outside - Twenty One Pilots", 7422841700 },
		{ "Onion", 113890289455724 },
		{ "Oscillating Fan", 71493999860590 },
		{ "Panini Dance - Lil Nas X (LNX)", 5915781665 },
		{ "Paranoid", 123407922818447 },
		{ "Paris Hilton - Checking My Angles", 15392937495 },
		{ "Paris Hilton - Iconic IT-Grrrl", 15392932768 },
		{ "Paris Hilton - Sliving For The Groove", 15392927897 },
		{ "Paris Hilton Sanasa", 16126526506 },
		{ "PARROT PARTY DANCE", 121067808279598 },
		{ "Plug Walk", 100359724990859 },
		{ "Point2", 3576823880 },
		{ "Power Blast", 4849497510 },
		{ "Prince Of Egypt", 134063402217274 },
		{ "PROXIMA", 81390693780805 },
		{ "Push-Up", 117922227854118 },
		{ "Quiet Waves", 7466046574 },
		{ "R15 Death (Accurate)", 114899970878842 },
		{ "Rabbit Hole - Miku", 133481721436918 },
		{ "Rambunctious", 134311528115559 },
		{ "Rasputin \226\128\147 Boney M.", 133477296392756 },
		{ "RAT DANCE", 133461102795137 },
		{ "Rise Above - The Chainsmokers", 13071993910 },
		{ "Robot", 3576721660 },
		{ "Robot M3GAN", 90569436057900 },
		{ "Rock Guitar - Royal Blood", 6532155086 },
		{ "Rock n Roll", 15506496093 },
		{ "Rock On", 5915782672 },
		{ "Rock Out - Bebe Rexha", 18225077553 },
		{ "Rock Star - Royal Blood", 6533100850 },
		{ "Rodeo Dance - Lil Nas X (LNX)", 5938397555 },
		{ "Rolling Stones Guitar Strum", 18148839527 },
		{ "RONALDO", 97547486465713 },
		{ "Sad", 4849502101 },
		{ "Samba", 6869813008 },
		{ "Sandwich Dance", 4390121879 },
		{ "Saturday Dance - Twenty One Pilots", 7422833723 },
		{ "Secret Handshake Dance", 120642514156293 },
		{ "Shocked meme", 129501229484294 },
		{ "Show Dem Wrists - KSI", 7202898984 },
		{ "Shrek Roar", 18524331128 },
		{ "Shuffle", 4391208058 },
		{ "Shy", 3576717965 },
		{ "Side to Side", 3762641826 },
		{ "Sidekicks - George Ezra", 10370922566 },
		{ "Skadoosh Emote - Kung Fu Panda 4", 16371235025 },
		{ "Skibidi", 124828909173982 },
		{ "Skibidi Toilet - Titan Speakerman Laser Spin", 103102322875221 },
		{ "Sleep", 4689362868 },
		{ "Slenderman", 81926508907412 },
		{ "Slickback", 103789826265487 },
		{ "Smeeze", 131683926643291 },
		{ "Sneaky", 3576754235 },
		{ "Sol de Janeiro - Samba", 16276506814 },
		{ "Spare Change", 126749574427431 },
		{ "Split", 98522218962476 },
		{ "SpongeBob Dance", 18443271885 },
		{ "SpongeBob Imaginaaation \240\159\140\136", 18443268949 },
		{ "SpongeBob Shuffle", 107899954696611 },
		{ "Spy Laugh tf2", 137720205462499 },
		{ "Squat?", 95441477641149 },
		{ "Squidward Yell", 109244554368414 },
		{ "Static [Hatsune Miku]", 84534006084837 },
		{ "Sticker Dance Move - NCT 127", 12259885838 },
		{ "Stray Kids Walkin On Water", 100773414188482 },
		{ "Strongest Stance", 80146495484274 },
		{ "Sturdy Dance - Ice Spice", 17746270218 },
		{ "Stylish Float", 97497383284399 },
		{ "Subject 3", 83732367439808 },
		{ "Sukuna", 91839607010745 },
		{ "Super Charge", 10478368365 },
		{ "Superhero Reveal", 3696759798 },
		{ "Swag Walk", 10478377385 },
		{ "Swan Dance", 7466048475 },
		{ "Swish", 3821527813 },
		{ "T", 3576719440 },
		{ "Take Me Under - Zara Larsson", 6797938823 },
		{ "Take The L", 123159156696507 },
		{ "Tantrum", 5104374556 },
		{ "Team USA Breaking Emote", 18526338976 },
		{ "Teto Dance", 93031502567721 },
		{ "Teto Territory", 114428584463004 },
		{ "Thanos Happy Jump - Squid Game", 82217023310738 },
		{ "The Conductor - George Ezra", 10370926562 },
		{ "The Weeknd Opening Night", 105098895743105 },
		{ "The Weeknd Starboy Strut", 130245358716273 },
		{ "The Zabb", 71389516735424 },
		{ "Thinking", 124584711308900 },
		{ "TMNT Dance", 18665886405 },
		{ "Tommy - Archer", 13823339506 },
		{ "Tommy K-Pop Mic Drop", 14024722653 },
		{ "Top Rock", 3570535774 },
		{ "Torture Dance", 116099356619436 },
		{ "Tree", 4049634387 },
		{ "TWICE ABCD by Nayeon", 18933761755 },
		{ "TWICE Fancy", 13520623514 },
		{ "TWICE Feel Special", 14900153406 },
		{ "TWICE I GOT YOU part 1", 16215060261 },
		{ "TWICE I GOT YOU part 2", 16256253954 },
		{ "TWICE Like Ooh-Ahh", 14124050904 },
		{ "TWICE LIKEY", 14900151704 },
		{ "TWICE Moonlight Sunrise", 12715393154 },
		{ "TWICE Pop by Nayeon", 13768975574 },
		{ "TWICE Set Me Free - Dance 1", 12715395038 },
		{ "TWICE Set Me Free - Dance 2", 12715397488 },
		{ "TWICE Strategy", 106862678450011 },
		{ "TWICE Takedown", 94796833553521 },
		{ "TWICE TAKEDOWN DANCE 2", 85623000473425 },
		{ "TWICE The Feels", 12874468267 },
		{ "TWICE What Is Love", 13344121112 },
		{ "Twirl", 3716633898 },
		{ "Ud'zal's Summoning", 3307604888 },
		{ "Up and Down - Twenty One Pilots", 7422843994 },
		{ "Uprise - Tommy Hilfiger", 10275057230 },
		{ "V Pose - Tommy Hilfiger", 10214418283 },
		{ "Vans Ollie", 18305539673 },
		{ "Victory - 24kGoldn", 9178397781 },
		{ "Victory Dance", 15506503658 },
		{ "Virtual Insanity", 83261816934732 },
		{ "Vroom Vroom", 18526410572 },
		{ "Wait", 106569806588657 },
		{ "Wake Up Call - KSI", 7202900159 },
		{ "Wally West", 133948663586698 },
		{ "Wally West Edit", 72247161810866 },
		{ "Wanna play?", 16646438742 },
		{ "What U Want / Prince Egypt", 133751526608969 },
		{ "Wisp - air guitar", 17370797454 },
		{ "Xaviersobased", 131763631172236 },
		{ "Y", 4391211308 },
		{ "Yapping Yap Yap Gesture", 119870339321091 },
		{ "You can't sit with us - Sunmi", 9983549160 },
		{ "Young-hee Head Spin - Squid Game", 134615135651900 },
		{ "Yungblud Happier Jump", 15610015346 },
		{ "YUNGBLUD \226\128\147 HIGH KICK", 14022978026 },
		{ "zenitsu", 92750276568993 },
		{ "Zombie", 4212496830 },
	}

	local MORE_PACKS = {
		{ "Bold", { idle = 16738333868, walk = 16738340646, run = 16738337225, jump = 16738336650, fall = 16738333171, climb = 16738332169, swim = 16738339158, swimidle = 16738339817 } },
		{ "Rthro", { idle = 2510196951, walk = 2510202577, run = 2510198475, jump = 2510197830, fall = 2510195892, climb = 2510192778, swim = 2510199791, swimidle = 2510201162 } },
		{ "Oldschool", { idle = 5319828216, walk = 5319847204, run = 5319844329, jump = 5319841935, fall = 5319839762, climb = 5319816685, swim = 5319850266, swimidle = 5319852613 } },
		{ "Realistic", { idle = 17172918855, walk = 11600249883, run = 11600211410, jump = 11600210487, fall = 11600206437, climb = 11600205519, swim = 11600212676, swimidle = 11600213505 } },
		{ "No Boundaries", { idle = 18747067405, walk = 18747074203, run = 18747070484, jump = 18747069148, fall = 18747062535, climb = 18747060903, swim = 18747073181, swimidle = 18747071682 } },
		{ "NFL Animation", { idle = 92080889861410, walk = 110358958299415, run = 117333533048078, jump = 119846112151352, fall = 129773241321032, climb = 134630013742019, swim = 132697394189921, swimidle = 79090109939093 } },
		{ "Adidas Aura", { idle = 110211186840347, walk = 83842218823011, run = 118320322718866, jump = 109996626521204, fall = 95603166884636, climb = 97824616490448, swim = 134530128383903, swimidle = 94922130551805 } },
		{ "Adidas Sports", { idle = 18537376492, walk = 18537392113, run = 18537384940, jump = 18537380791, fall = 18537367238, climb = 18537363391, swim = 18537389531, swimidle = 18537387180 } },
		{ "Adidas Community ", { idle = 122257458498464, walk = 122150855457006, run = 82598234841035, jump = 75290611992385, fall = 98600215928904, climb = 88763136693023, swim = 133308483266208, swimidle = 109346520324160 } },
		{ "Wickled Popular", { idle = 118832222982049, walk = 92072849924640, run = 72301599441680, jump = 104325245285198, fall = 121152442762481, climb = 131326830509784, swim = 99384245425157, swimidle = 113199415118199 } },
		{ "Catwalk Glam", { idle = 133806214992291, walk = 109168724482748, run = 81024476153754, jump = 116936326516985, fall = 92294537340807, climb = 119377220967554, swim = 134591743181628, swimidle = 98854111361360 } },
		{ "Princess", { idle = 941003647, walk = 941028902, run = 941015281, jump = 941008832, fall = 941000007, climb = 940996062, swim = 941018893, swimidle = 941025398 } },
		{ "Confident", { idle = 1069977950, walk = 1070017263, run = 1070001516, jump = 1069984524, fall = 1069973677, climb = 1069946257, swim = 1070009914, swimidle = 1070012133 } },
		{ "Popstar", { idle = 1212900985, walk = 1212980338, run = 1212980348, jump = 1212954642, fall = 1212900995, climb = 1213044953, swim = 1212852603, swimidle = 1070012133 } },
		{ "Patrol", { idle = 1149612882, walk = 1151231493, run = 1150967949, jump = 1150944216, fall = 1148863382, climb = 1148811837, swim = 1151204998, swimidle = 1151221899 } },
		{ "Sneaky", { idle = 1132473842, walk = 1132510133, run = 1132494274, jump = 1132489853, fall = 1132469004, climb = 1132461372, swim = 1132500520, swimidle = 1132506407 } },
		{ "Cowboy", { idle = 1014390418, walk = 1014421541, run = 1014401683, jump = 1014394726, fall = 1014384571, climb = 1014380606, swim = 1014406523, swimidle = 1014411816 } },
		{ "Ghost", { idle = 616006778, walk = 616013216, run = 616013216, jump = 616008936, fall = 616005863, climb = 0, swim = 616011509, swimidle = 616012453 } },
		{ "Ghost 2", { idle = 1151221899, walk = 1151221899, run = 1151221899, jump = 1151221899, fall = 1151221899, climb = 0, swim = 16738339158, swimidle = 1151221899 } },
		{ "Mr. Toilet", { idle = 4417977954, walk = 2510202577, run = 4417979645, jump = 2510197830, fall = 2510195892, climb = 2510192778, swim = 2510199791, swimidle = 2510201162 } },
		{ "Udzal", { idle = 3303162274, walk = 3303162967, run = 3236836670, jump = 2510197830, fall = 2510195892, climb = 2510192778, swim = 2510199791, swimidle = 2510191162 } },
		{ "Oinan Thickhoof", { idle = 657595757, walk = 2510202577, run = 3236836670, jump = 2510197830, fall = 2510195892, climb = 2510192778, swim = 2510199791, swimidle = 2510201162 } },
		{ "Borock", { idle = 3293641938, walk = 2510202577, run = 3236836670, jump = 2510197830, fall = 2510195892, climb = 2510192778, swim = 2510199791, swimidle = 2510201162 } },
		{ "Blocky Mech", { idle = 4417977954, walk = 2510202577, run = 4417979645, jump = 2510197830, fall = 2510195892, climb = 2510192778, swim = 2510199791, swimidle = 2510201162 } },
		{ "Stylized Female", { idle = 4708191566, walk = 4708193840, run = 4708192705, jump = 4708188025, fall = 4708186162, climb = 4708184253, swim = 4708189360, swimidle = 4708190607 } },
		{ "R15", { idle = 4211217646, walk = 4211223236, run = 4211220381, jump = 4211219390, fall = 4211216152, climb = 4211214992, swim = 4211221314, swimidle = 4374694239 } },
		{ "Mocap", { idle = 913367814, walk = 913402848, run = 913376220, jump = 913370268, fall = 913365531, climb = 913362637, swim = 913384386, swimidle = 913389285 } },
		{ "Wicked \"Dancing Through Life\"", { idle = 92849173543269, walk = 73718308412641, run = 135515454877967, jump = 78508480717326, fall = 78147885297412, climb = 129447497744818, swim = 110657013921774, swimidle = 129183123083281 } },
		{ "Unboxed", { idle = 98281136301627, walk = 90478085024465, run = 134824450619865, jump = 121454505477205, fall = 94788218468396, climb = 121145883950231, swim = 105962919001086, swimidle = 129126268464847 } },
	}

	-- swim animations for the packs that were already here
	local PACK_SWIM = {
		["Stylish"] = { 616143378, 616144772 },
		["Zombie"] = { 616165109, 616166655 },
		["Robot"] = { 616092998, 616094091 },
		["Toy"] = { 782844582, 782845186 },
		["Cartoony"] = { 742639220, 742639812 },
		["Superhero"] = { 616119360, 616120861 },
		["Mage"] = { 707876443, 707894699 },
		["Levitation"] = { 616011509, 616012453 },
		["Vampire"] = { 1083464683, 1083467779 },
		["Elder"] = { 845401742, 845403127 },
		["Werewolf"] = { 1083222527, 1083225406 },
		["Knight"] = { 657560551, 657557095 },
		["Astronaut"] = { 891639666, 891663592 },
		["Bubbly"] = { 910028158, 910030921 },
		["Pirate"] = { 750784579, 750785176 },
		["Ninja"] = { 656119721, 656121397 },
	}

	-- { idle, walk, run, jump, fall, climb }
	local PACKS = {
		{ "Ninja", 656117400, 656121766, 656118852, 656117878, 656115606, 656114359 },
		{ "Zombie", 616158929, 616168032, 616163682, 616161997, 616157476, 616156119 },
		{ "Robot", 616088211, 616095330, 616091570, 616090535, 616087089, 616086039 },
		{ "Cartoony", 742637544, 742640026, 742638842, 742637942, 742637151, 742636889 },
		{ "Toy", 782841498, 782843345, 782842708, 782847020, 782846423, 782843869 },
		{ "Levitation", 616006778, 616013216, 616010382, 616008936, 616005863, 616003713 },
		{ "Superhero", 616111295, 616122287, 616117076, 616115533, 616108001, 616104706 },
		{ "Vampire", 1083445855, 1083473930, 1083462077, 1083455352, 1083443587, 1083439238 },
		{ "Stylish", 616136790, 616146177, 616140816, 616139451, 616134815, 616133594 },
		{ "Bubbly", 910004836, 910034870, 910025107, 910016857, 910001910, 909997997 },
		{ "Mage", 707742142, 707897309, 707861613, 707853694, 707829716, 707826056 },
		{ "Knight", 657595757, 657552124, 657564596, 658409194, 657600338, 658360781 },
		{ "Pirate", 750781874, 750785693, 750783738, 750782230, 750780242, 750779899 },
		{ "Elder", 845397899, 845403856, 845386501, 845398858, 845396048, 845392038 },
		{ "Werewolf", 1083195517, 1083178339, 1083216690, 1083218792, 1083189019, 1083182000 },
		{ "Astronaut", 891621366, 891667138, 891636393, 891627522, 891617961, 891609353 },
	}

	local emoteNames, packNames = {}, {}
	local emoteIds, packData = {}, {}

	-- Rig support. Catalog emotes are made for R15 bodies and do NOT work on R6.
	-- Emotes whose name already says R6 are R6-only. The classic Roblox emotes have an R6 version too,
	-- so they work on both: [R15+R6]. Everything else is [R15].
	local R6_IDS = {
		["Wave"] = 128777973,
		["Point"] = 128853357,
		["Cheer"] = 129423030,
		["Laugh"] = 129423131,
		["Dance 1"] = 182435998,
		["Dance 2"] = 182436842,
		["Dance 3"] = 182436935,
	}

	-- emoteIds[displayName] = { r15 = id or nil, r6 = id or nil }
	local function addEmote(rawName, id)
		local stripped = rawName:gsub("%s*[%[%(]%s*R6%s*[%]%)]", "")
		local isR6Only = stripped ~= rawName
		local base = stripped:gsub("^%s+", ""):gsub("%s+$", "")
		local info
		local tag

		if isR6Only then
			info = { r6 = id }
			tag = "R6"
		elseif R6_IDS[base] then
			info = { r15 = id, r6 = R6_IDS[base] }
			tag = "R15+R6"
		else
			info = { r15 = id }
			tag = "R15"
		end

		local display = base .. " [" .. tag .. "]"

		if not emoteIds[display] then
			emoteNames[#emoteNames + 1] = display
			emoteIds[display] = info
		end
	end

	for _, entry in ipairs(EMOTES) do
		addEmote(entry[1], entry[2])
	end

	for _, entry in ipairs(PACKS) do
		packNames[#packNames + 1] = entry[1]
		packData[entry[1]] = { idle = entry[2], walk = entry[3], run = entry[4], jump = entry[5], fall = entry[6], climb = entry[7] }
	end

	for _, entry in ipairs(MORE_EMOTES) do
		addEmote(entry[1], entry[2])
	end

	for _, entry in ipairs(MORE_PACKS) do
		if not packData[entry[1]] then
			packNames[#packNames + 1] = entry[1]
			packData[entry[1]] = entry[2]
		end
	end

	for name, ids in pairs(PACK_SWIM) do
		if packData[name] then
			packData[name].swim = ids[1]
			packData[name].swimidle = ids[2]
		end
	end

	table.sort(emoteNames, function(x, y)
		return x:lower() < y:lower()
	end)

	local state = {
		emote = emoteNames[1],
		loop = false,
		speed = 1,
		stopOnMove = false, -- off = the emote keeps playing while you walk / jump
		wanted = nil, -- the emote that should keep playing (also after you die and respawn)
		emoteRespawnConn = nil,
		respawnToken = 0,
		track = nil,
		conns = {},
		pack = packNames[1],
		activePack = nil, -- the pack that is applied (and re-applied after you respawn)
		original = {}, -- the animation ids the character had before any pack: [Animation object] = id
		respawnConn = nil,
	}

	local function warn(text)
		obj2:Notify({ Title = "Emotes", Content = text, Duration = 3, Icon = "x" })
	end

	local function getHumanoid()
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
		return character, humanoid, animator
	end

	-- ---------- emotes ----------
	local function clearTrack()
		for i = #state.conns, 1, -1 do
			pcall(function()
				state.conns[i]:Disconnect()
			end)

			state.conns[i] = nil
		end

		if state.track then
			local track = state.track
			state.track = nil

			pcall(function()
				track:Stop(0.2)
			end)
		end
	end

	-- a real stop (button / walking with "Stop Emote When Moving"): forget the emote so it is not replayed
	local function stopEmote()
		state.wanted = nil
		state.respawnToken = state.respawnToken + 1
		clearTrack()
	end

	local playEmote

	-- after you die and respawn, play the same emote again
	local function ensureRespawnReplay()
		if state.emoteRespawnConn then
			return
		end

		state.emoteRespawnConn = localPlayer.CharacterAdded:Connect(function(character)
			local name = state.wanted

			if not name then
				return
			end

			state.respawnToken = state.respawnToken + 1
			local token = state.respawnToken

			clearTrack()

			task.spawn(function()
				local humanoid = character:WaitForChild("Humanoid", 10)

				if not humanoid then
					return
				end

				character:WaitForChild("HumanoidRootPart", 10)
				humanoid:WaitForChild("Animator", 5)
				task.wait(1) -- let the game's animation script start first

				if token ~= state.respawnToken or state.wanted ~= name or localPlayer.Character ~= character then
					return
				end

				playEmote(name)
			end)
		end)

		list2.conns[#list2.conns + 1] = state.emoteRespawnConn
	end

	function playEmote(name)
		local character, humanoid, animator = getHumanoid()
		local info = emoteIds[name]

		if not humanoid or not info then
			warn("No character to play the emote on.")
			return
		end

		-- pick the animation that matches the body type
		local isR15 = humanoid.RigType == Enum.HumanoidRigType.R15
		local id = isR15 and info.r15 or info.r6

		if not id then
			if isR15 then
				warn("This emote is R6 only - you are R15.")
			else
				warn("This emote is R15 only - you are R6.")
			end
			return
		end

		clearTrack()
		state.wanted = name
		ensureRespawnReplay()

		local animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://" .. id

		-- R6 characters sometimes have no Animator, so fall back to the Humanoid
		local loader = animator or humanoid

		local ok, track = pcall(function()
			return loader:LoadAnimation(animation)
		end)

		if not ok or not track then
			warn("Could not load that emote.")
			return
		end

		track.Looped = state.loop
		-- Action4 is the highest priority, so the walk / run / jump animations cannot override the emote
		track.Priority = Enum.AnimationPriority.Action4
		track:Play(0.2, 1, state.speed)
		state.track = track

		-- if the emote ends by itself while you are alive (not looped), forget it.
		-- If it ended because you died, keep it so it plays again after the respawn.
		state.conns[#state.conns + 1] = track.Stopped:Connect(function()
			if state.track == track then
				state.track = nil

				if humanoid.Health > 0 and character.Parent then
					state.wanted = nil
				end
			end
		end)

		-- only when "Stop Emote When Moving" is on: walking or jumping ends the emote
		if state.stopOnMove then
			state.conns[#state.conns + 1] = humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
				if state.stopOnMove and humanoid.MoveDirection.Magnitude > 0.1 then
					stopEmote()
				end
			end)

			state.conns[#state.conns + 1] = humanoid.Jumping:Connect(function()
				if state.stopOnMove then
					stopEmote()
				end
			end)
		end
	end

	-- ---------- animation packs ----------
	local function animateParts(character)
		local animate = character and character:FindFirstChild("Animate")

		if not animate then
			return nil
		end

		local function find(folder, name)
			local group = animate:FindFirstChild(folder)
			return group and group:FindFirstChild(name)
		end

		return animate, {
			idle = { find("idle", "Animation1"), find("idle", "Animation2") },
			walk = { find("walk", "WalkAnim") },
			run = { find("run", "RunAnim") },
			jump = { find("jump", "JumpAnim") },
			fall = { find("fall", "FallAnim") },
			climb = { find("climb", "ClimbAnim") },
			swim = { find("swim", "Swim") },
			swimidle = { find("swimidle", "SwimIdle") },
		}
	end

	-- make the game's animation script pick the new animations up straight away
	local function restartAnimate(character, animate)
		local _, humanoid, animator = getHumanoid()

		animate.Disabled = true

		if animator then
			for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
				pcall(function()
					track:Stop()
				end)
			end
		end

		animate.Disabled = false
	end

	local function applyPack(name)
		local pack = packData[name]
		local character, humanoid = getHumanoid()

		if not pack or not character or not humanoid then
			warn("No character to change.")
			return
		end

		if humanoid.RigType ~= Enum.HumanoidRigType.R15 then
			warn("Animation packs need an R15 character.")
			return
		end

		local animate, parts = animateParts(character)

		if not animate then
			warn("This character has no animation script to change.")
			return
		end

		for kind, objects in pairs(parts) do
			for _, object in ipairs(objects) do
				if object and pack[kind] then
					if state.original[object] == nil then
						state.original[object] = object.AnimationId
					end

					object.AnimationId = "rbxassetid://" .. pack[kind]
				end
			end
		end

		restartAnimate(character, animate)
		state.activePack = name

		-- keep the pack after you respawn
		if not state.respawnConn then
			state.respawnConn = localPlayer.CharacterAdded:Connect(function()
				task.wait(1.5)

				if state.activePack then
					applyPack(state.activePack)
				end
			end)
			list2.conns[#list2.conns + 1] = state.respawnConn
		end
	end

	local function resetPack()
		state.activePack = nil
		local character = localPlayer.Character
		local animate = character and character:FindFirstChild("Animate")

		for object, id in pairs(state.original) do
			if object and object.Parent then
				object.AnimationId = id
			end
		end

		table.clear(state.original)

		if animate then
			restartAnimate(character, animate)
		end
	end

	-- ---------- the controls ----------
	tbl43.player:Section({ Title = "Emotes & Animations" })

	local emoteDrop

	tbl43.player:Input({
		Title = "Search Emote",
		Flag = "Input_Emote_Search",
		Desc = "Type part of a name to filter the emote list. You can also search r6 or r15.",
		Placeholder = "e.g. twice, blackpink, r6",
		Callback = function(text)
			local q = tostring(text or ""):lower()
			local list = {}

			for _, n in ipairs(emoteNames) do
				if q == "" or n:lower():find(q, 1, true) then
					list[#list + 1] = n
				end
			end

			if #list == 0 then
				warn("No emotes match that.")
				return
			end

			if emoteDrop then
				emoteDrop:Refresh(list)
			end
		end,
	})

	emoteDrop = tbl43.player:Dropdown({
		Title = "Emote",
		Flag = "Dropdown_Emote",
		Desc = "Pick an emote, then press Play Emote.  [R15] = R15 only, [R6] = R6 only, [R15+R6] = works on both.",
		Multi = false,
		Value = emoteNames[1],
		Values = emoteNames,
		Callback = function(value)
			local chosen = tostring(type(value) == "table" and (value[1] or value.Value) or value)

			if emoteIds[chosen] then
				state.emote = chosen
			end
		end,
	})

	tbl43.player:Button({
		Title = "Play Emote",
		Desc = "Plays the emote picked above. It keeps playing while you walk (see Stop Emote When Moving).",
		Callback = function()
			playEmote(state.emote)
		end,
	})

	tbl43.player:Button({
		Title = "Stop Emote",
		Desc = "Stops the emote that is playing.",
		Callback = function()
			stopEmote()
		end,
	})

	tbl43.player:Toggle({
		Title = "Loop Emote",
		Flag = "Toggle_Loop_Emote",
		Desc = "The emote repeats until you press Stop Emote. Works on the emote that is already playing too.",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			state.loop = value and true or false

			if state.track then
				pcall(function()
					state.track.Looped = state.loop
				end)
			end
		end,
	})

	tbl43.player:Toggle({
		Title = "Stop Emote When Moving",
		Flag = "Toggle_Emote_Stop_On_Move",
		Desc = "Off = the emote keeps playing while you walk or jump. On = walking or jumping stops it. Applies to the next emote you play.",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			state.stopOnMove = value and true or false
		end,
	})

	tbl43.player:Slider({
		Title = "Emote Speed",
		Flag = "Slider_Emote_Speed",
		Desc = "How fast the emote plays (1 = normal).",
		Step = 0.05,
		Value = { Min = 0.25, Max = 3, Default = 1 },
		Callback = function(value)
			local n = tonumber(value) or type(value) == "table" and tonumber(value.Value)

			if n then
				state.speed = n

				if state.track then
					pcall(function()
						state.track:AdjustSpeed(n)
					end)
				end
			end
		end,
	})

	tbl43.player:Dropdown({
		Title = "Animation Pack",
		Flag = "Dropdown_Animation_Pack",
		Desc = "How you idle, walk, run, jump, fall and climb. Pick one, then turn on the Animation Pack switch below. Changing it while the switch is on applies it straight away.",
		Multi = false,
		Value = packNames[1],
		Values = packNames,
		Callback = function(value)
			local chosen = tostring(type(value) == "table" and (value[1] or value.Value) or value)

			if packData[chosen] then
				state.pack = chosen

				if state.packOn then
					applyPack(chosen)
				end
			end
		end,
	})

	tbl43.player:Toggle({
		Title = "Animation Pack",
		Flag = "Toggle_Animation_Pack",
		Desc = "On = uses the pack picked above (stays on after you respawn). Off = gives you your normal animations back.",
		Type = "Toggle",
		Value = false,
		Callback = function(value)
			state.packOn = value and true or false

			if state.packOn then
				applyPack(state.pack)

				-- no character yet (for example right after the config loads): keep trying for a few seconds
				if state.activePack ~= state.pack then
					task.spawn(function()
						for _ = 1, 10 do
							task.wait(1)

							if not state.packOn then
								return
							end

							applyPack(state.pack)

							if state.activePack == state.pack then
								return
							end
						end
					end)
				end
			else
				resetPack()
			end
		end,
	})
end

-- ===== Extra features: Fake Lag, Robloxegor Speed, Fake Knife, Spam Emotes =====
-- Ported from snpware. (Bang / Get Sucked / Get Banged were left out on purpose.)
do
	local Lighting_ = game:GetService("Lighting")
	local conns = {} -- everything we connect, so the menu can clean up when it closes

	local function track(conn)
		conns[#conns + 1] = conn
		return conn
	end

	local function num(v, fallback)
		return tonumber(v) or (type(v) == "table" and tonumber(v.Value)) or fallback
	end

	local function getChar()
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = character and character:FindFirstChild("HumanoidRootPart")
		return character, humanoid, root
	end

	local function notify(title, text)
		pcall(function()
			obj2:Notify({ Title = title, Content = text, Duration = 3, Icon = "x" })
		end)
	end

	----------------------------------------------------------------------
	-- Fake Lag
	----------------------------------------------------------------------
	local FL = { on = false, interval = 0.07, anchor = 0.4, tp = false, tpDist = 10, token = 0 }

	local function releaseRoot()
		local _, _, root = getChar()
		if root then
			root.Anchored = false
		end
	end

	local function startFakeLag()
		FL.token = FL.token + 1
		local token = FL.token

		task.spawn(function()
			while FL.on and FL.token == token do
				local _, humanoid, root = getChar()

				if root and humanoid and humanoid.Health > 0 then
					root.Anchored = true
					task.wait(FL.anchor)

					if root.Parent then
						root.Anchored = false
					end

					if FL.tp and humanoid.Parent and humanoid.MoveDirection.Magnitude > 0 and root.Parent then
						local dist = math.random(1, math.max(1, math.floor(FL.tpDist * 100))) / 100
						root.CFrame = root.CFrame + humanoid.MoveDirection.Unit * dist
					end
				end

				task.wait(FL.interval)
			end

			releaseRoot()
		end)
	end

	tbl43.troll:Section({ Title = "Fake Lag" })

	tbl43.troll:Toggle({
		Title = "Fake Lag",
		Flag = "Toggle_Fake_Lag",
		Desc = "Freezes your character in short bursts so you look laggy to other players.",
		Type = "Toggle",
		Value = false,
		Callback = function(v)
			FL.on = v and true or false

			if FL.on then
				startFakeLag()
			else
				FL.token = FL.token + 1
				releaseRoot()
			end
		end,
	})

	tbl43.troll:Slider({
		Title = "Fake Lag Interval",
		Flag = "Slider_Fake_Lag_Interval",
		Desc = "Time between freezes (1 = 0.01 s, 100 = 1 s).",
		Step = 1,
		Value = { Min = 1, Max = 100, Default = 7 },
		Callback = function(v)
			FL.interval = math.clamp(num(v, 7), 1, 100) / 100
		end,
	})

	tbl43.troll:Slider({
		Title = "Fake Lag Freeze Time",
		Flag = "Slider_Fake_Lag_Freeze",
		Desc = "How long each freeze lasts (30 = 0.3 s, 200 = 2 s).",
		Step = 1,
		Value = { Min = 30, Max = 200, Default = 40 },
		Callback = function(v)
			FL.anchor = math.clamp(num(v, 40), 30, 200) / 100
		end,
	})

	tbl43.troll:Toggle({
		Title = "Fake Lag [Wifi]",
		Flag = "Toggle_Fake_Lag_Wifi",
		Desc = "After each freeze you jump forward a little, like a bad connection catching up.",
		Type = "Toggle",
		Value = false,
		Callback = function(v)
			FL.tp = v and true or false
		end,
	})

	tbl43.troll:Slider({
		Title = "Wifi Jump Distance",
		Flag = "Slider_Fake_Lag_Wifi_Distance",
		Desc = "Biggest jump forward, in studs.",
		Step = 1,
		Value = { Min = 5, Max = 50, Default = 10 },
		Callback = function(v)
			FL.tpDist = math.clamp(num(v, 10), 5, 50)
		end,
	})

	----------------------------------------------------------------------
	-- Robloxegor Speed
	----------------------------------------------------------------------
	local EG = { on = false, run = nil, speed = nil, track = nil, oldSpeed = 16 }
	local EGOR_ANIM = "rbxassetid://913376220"

	local function stopEgor()
		if EG.run then
			EG.run:Disconnect()
			EG.run = nil
		end

		if EG.speed then
			EG.speed:Disconnect()
			EG.speed = nil
		end

		if EG.track then
			pcall(function()
				EG.track:Stop()
			end)
			EG.track = nil
		end

		local _, humanoid = getChar()

		if humanoid then
			humanoid.WalkSpeed = EG.oldSpeed

			for _, t in ipairs(humanoid:GetPlayingAnimationTracks()) do
				if t.Animation and t.Animation.AnimationId == EGOR_ANIM then
					t:Stop()
				end
			end
		end
	end

	local function startEgor()
		stopEgor()

		local _, humanoid = getChar()

		if not humanoid then
			return
		end

		EG.oldSpeed = humanoid.WalkSpeed > 3 and humanoid.WalkSpeed or 16
		humanoid.WalkSpeed = 3

		EG.speed = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
			if EG.on and humanoid.WalkSpeed ~= 3 then
				humanoid.WalkSpeed = 3
			end
		end)

		local animation = Instance.new("Animation")
		animation.AnimationId = EGOR_ANIM

		local loader = humanoid:FindFirstChildOfClass("Animator") or humanoid
		local ok, egorTrack = pcall(function()
			return loader:LoadAnimation(animation)
		end)

		if not ok or not egorTrack then
			notify("Robloxegor", "Could not load the animation.")
			return
		end

		egorTrack.Priority = Enum.AnimationPriority.Movement
		egorTrack.Looped = true
		egorTrack:AdjustSpeed(6)
		EG.track = egorTrack

		EG.run = RunService.RenderStepped:Connect(function()
			if not humanoid.Parent then
				if EG.run then
					EG.run:Disconnect()
					EG.run = nil
				end
				return
			end

			if humanoid.MoveDirection.Magnitude == 0 then
				if egorTrack.IsPlaying then
					egorTrack:Stop()
				end
			elseif not egorTrack.IsPlaying then
				egorTrack:Play()
				egorTrack:AdjustSpeed(6)
			end
		end)
	end

	tbl43.troll:Toggle({
		Title = "Robloxegor Speed",
		Flag = "Toggle_Robloxegor",
		Desc = "Slow walk speed with a very fast running animation, so you look like you are sliding.",
		Type = "Toggle",
		Value = false,
		Callback = function(v)
			EG.on = v and true or false

			if EG.on then
				startEgor()
			else
				stopEgor()
			end
		end,
	})

	track(localPlayer.CharacterAdded:Connect(function()
		if EG.run then
			EG.run:Disconnect()
			EG.run = nil
		end

		if EG.speed then
			EG.speed:Disconnect()
			EG.speed = nil
		end

		EG.track = nil

		if EG.on then
			task.wait(0.4)

			if EG.on then
				startEgor()
			end
		end
	end))

	----------------------------------------------------------------------
	-- Fake Knife
	----------------------------------------------------------------------
	local FK = { on = false, tool = nil, conns = {}, canAttack = true, attacking = false, fling = false, flinging = false, charConn = nil }
	local KNIFE_ANIMS = { "rbxassetid://2467567750", "rbxassetid://1957890538" }

	local function cleanKnife()
		FK.flinging = false
		FK.attacking = false

		if FK.tool then
			pcall(function()
				FK.tool:Destroy()
			end)
			FK.tool = nil
		end

		for _, c in ipairs(FK.conns) do
			pcall(function()
				c:Disconnect()
			end)
		end

		FK.conns = {}
	end

	-- optional: while the fake knife is held, touching players flings them (off by default)
	local function startKnifeFling(tool)
		local n = 0.1

		while FK.tool and FK.tool == tool do
			RunService.Heartbeat:Wait()

			if FK.flinging and FK.fling then
				local _, _, root = getChar()

				if root then
					local velocity = root.Velocity
					root.Velocity = velocity * 1000000 + Vector3.new(0, 1000000, 0)
					RunService.RenderStepped:Wait()
					root.Velocity = velocity
					RunService.Stepped:Wait()
					root.Velocity = velocity + Vector3.new(0, n, 0)
					n = -n
				end
			end
		end
	end

	local function createKnife()
		if FK.tool then
			cleanKnife()
		end

		local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
		local root = character:WaitForChild("HumanoidRootPart", 5)

		if not root then
			return
		end

		local tool = Instance.new("Tool")
		tool.Name = "Fake Knife"
		tool.CanBeDropped = false
		tool.RequiresHandle = true
		tool.TextureId = "rbxassetid://138663675657207"
		tool.Grip = CFrame.new(0, -1, -0.1, 1, 0, 0, 0, 1, 0, 0, 0, 1)

		local handle = Instance.new("Part")
		handle.Name = "Handle"
		handle.Size = Vector3.new(0.4, 3, 0.7)
		handle.Color = Color3.new(0.639216, 0.635294, 0.647059)
		handle.CanCollide = false
		handle.Parent = tool

		local mesh = Instance.new("SpecialMesh")
		mesh.Name = "Mesh"
		mesh.MeshId = "http://www.roblox.com/asset/?id=121944778"
		mesh.TextureId = "http://www.roblox.com/asset/?id=121944805"
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.Parent = handle

		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://142247768"
		sound.Volume = 0.8
		sound.Parent = root

		FK.tool = tool
		FK.canAttack = true

		FK.conns[#FK.conns + 1] = tool.Equipped:Connect(function()
			FK.flinging = true
		end)

		FK.conns[#FK.conns + 1] = tool.Unequipped:Connect(function()
			FK.flinging = false
			FK.attacking = false
		end)

		FK.conns[#FK.conns + 1] = tool.Activated:Connect(function()
			if not FK.canAttack then
				return
			end

			FK.canAttack = false
			FK.attacking = true

			local _, humanoid = getChar()

			if humanoid then
				local animation = Instance.new("Animation")
				animation.AnimationId = KNIFE_ANIMS[math.random(1, #KNIFE_ANIMS)]

				local loader = humanoid:FindFirstChildOfClass("Animator") or humanoid
				local ok, slash = pcall(function()
					return loader:LoadAnimation(animation)
				end)

				if ok and slash then
					slash.Priority = Enum.AnimationPriority.Action
					slash:Play()
				end
			end

			task.wait(0.5)
			FK.attacking = false
			task.wait(0.25)
			FK.canAttack = true
		end)

		local function onHandTouched(hit)
			if FK.tool and FK.tool.Parent == character and FK.attacking then
				local parent = hit.Parent

				if parent and parent ~= character and parent:FindFirstChildOfClass("Humanoid") and not sound.IsPlaying then
					sound:Play()
				end
			end
		end

		local hand = character:FindFirstChild("RightHand", true) or character:FindFirstChild("Right Arm", true)

		if hand then
			FK.conns[#FK.conns + 1] = hand.Touched:Connect(onHandTouched)
		end

		local backpack = localPlayer:FindFirstChildOfClass("Backpack")

		if backpack then
			tool.Parent = backpack
		end

		task.spawn(startKnifeFling, tool)
	end

	tbl43.troll:Section({ Title = "Fake Knife" })

	tbl43.troll:Toggle({
		Title = "Fake Knife",
		Flag = "Toggle_Fake_Knife",
		Desc = "Gives you a knife tool that only you can see work: slash animation and stab sound, no damage.",
		Type = "Toggle",
		Value = false,
		Callback = function(v)
			FK.on = v and true or false

			if FK.charConn then
				FK.charConn:Disconnect()
				FK.charConn = nil
			end

			if FK.on then
				task.spawn(createKnife)

				FK.charConn = localPlayer.CharacterAdded:Connect(function()
					cleanKnife()
					task.wait(0.5)

					if FK.on then
						createKnife()
					end
				end)
			else
				cleanKnife()
			end
		end,
	})

	tbl43.troll:Toggle({
		Title = "Fake Knife Fling",
		Flag = "Toggle_Fake_Knife_Fling",
		Desc = "Holding the fake knife also makes you fling players you touch (this is what the snpware knife did). Off by default.",
		Type = "Toggle",
		Value = false,
		Callback = function(v)
			FK.fling = v and true or false
		end,
	})

	----------------------------------------------------------------------
	-- Spam Emotes
	----------------------------------------------------------------------
	local SP = { on = false, speed = 1, token = 0 }
	local EMOTE_SPAM_LIST = { "sit", "ninja", "dab", "zen", "floss", "headless", "zombie", "wave", "cheer", "laugh" }

	local function fireEmote(name)
		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		local misc = remotes and remotes:FindFirstChild("Misc")
		local ev = misc and misc:FindFirstChild("PlayEmote")

		if not ev then
			return false
		end

		if ev:IsA("BindableEvent") then
			ev:Fire(name)
		elseif ev:IsA("RemoteEvent") then
			ev:FireServer(name)
		else
			return false
		end

		return true
	end

	tbl43.player:Section({ Title = "Spam Emotes" })

	tbl43.player:Toggle({
		Title = "Spam Emotes",
		Flag = "Toggle_Spam_Emotes",
		Desc = "Plays the game's own emotes (sit, ninja, dab, zen, floss, headless, zombie, wave, cheer, laugh) over and over in random order.",
		Type = "Toggle",
		Value = false,
		Callback = function(v)
			SP.on = v and true or false
			SP.token = SP.token + 1
			local token = SP.token

			if not SP.on then
				return
			end

			task.spawn(function()
				while SP.on and SP.token == token do
					if not fireEmote(EMOTE_SPAM_LIST[math.random(1, #EMOTE_SPAM_LIST)]) then
						notify("Spam Emotes", "This game has no emote event here.")
						SP.on = false
						return
					end

					task.wait(1 / math.clamp(SP.speed, 1, 10))
				end
			end)
		end,
	})

	tbl43.player:Slider({
		Title = "Emote Spam Speed",
		Flag = "Slider_Emote_Spam_Speed",
		Desc = "Emotes per second.",
		Step = 1,
		Value = { Min = 1, Max = 10, Default = 1 },
		Callback = function(v)
			SP.speed = math.clamp(num(v, 1), 1, 10)
		end,
	})

	obj3:OnDestroy(function()
		FL.on = false
		FL.token = FL.token + 1
		releaseRoot()

		EG.on = false
		stopEgor()

		FK.on = false
		cleanKnife()

		if FK.charConn then
			FK.charConn:Disconnect()
			FK.charConn = nil
		end

		SP.on = false
		SP.token = SP.token + 1

		for _, c in ipairs(conns) do
			pcall(function()
				c:Disconnect()
			end)
		end
	end)
end

-- ===== Map Picker [EXPERIMENTAL] =====
-- The "Maps" tab of the main UI lists the maps up for vote as cards (picture + name). Tap a card and the
-- script keeps putting you on that map's vote detector until the round starts: warp on once, reset, wait for the
-- new character, warp on again, and so on. Every time you stand on the detector it counts as another vote. It
-- stops by itself when the game starts, and tapping the same card again stops it too. The cards refresh by
-- themselves when the maps up for vote change. The server decides the winning map, so a result is never guaranteed.
do
	local RunService_ = game:GetService("RunService")
	local Players_ = game:GetService("Players")
	local pick = { token = 0, running = false, holder = nil, sig = nil, interval = 0.2, name = nil, conns = {}, cells = {}, items = {} }
	local VOTE_WORDS = { "vote", "voting" }

	local function matches(text)
		text = string.lower(text)

		for _, word in ipairs(VOTE_WORDS) do
			if string.find(text, word, 1, true) then
				return true
			end
		end

		return false
	end

	local function centerOf(item)
		if item:IsA("BasePart") then
			return item.Position + Vector3.new(0, item.Size.Y / 2 + 3, 0)
		end

		if item:IsA("Model") then
			local cf, size = item:GetBoundingBox()
			return cf.Position + Vector3.new(0, size.Y / 2 + 3, 0)
		end

		for _, d in ipairs(item:GetDescendants()) do
			if d:IsA("BasePart") then
				return d.Position + Vector3.new(0, d.Size.Y / 2 + 3, 0)
			end
		end
	end

	-- a bare number is an asset id; anything else is used as it is
	local function normalizeImage(value)
		if type(value) == "number" then
			return "rbxassetid://" .. tostring(math.floor(value))
		end

		if type(value) == "string" and value ~= "" then
			if string.match(value, "^%d+$") then
				return "rbxassetid://" .. value
			end

			return value
		end
	end

	-- The main UI loads pictures from "rbxassetid://<id>" only. Roblox objects often hold the same picture as
	-- "http://www.roblox.com/asset/?id=<id>" or "rbxthumb://...&id=<id>..." or a bare number - those would come
	-- out blank, so every picture is turned into "rbxassetid://<id>" first.
	local function toAssetUri(value)
		if type(value) ~= "string" then
			return value
		end

		local id = string.match(value, "rbxassetid://(%d+)")
			or string.match(value, "[?&]id=(%d+)")
			or string.match(value, "^(%d+)$")

		if id then
			return "rbxassetid://" .. id
		end

		return value
	end

	local IMAGE_WORDS = { "image", "icon", "thumb", "texture", "picture" }

	local function hasImageWord(text)
		text = string.lower(text)

		for _, word in ipairs(IMAGE_WORDS) do
			if string.find(text, word, 1, true) then
				return true
			end
		end

		return false
	end

	-- the picture held by one object, whatever kind of object it is
	local function imageOf(d)
		if (d:IsA("ImageLabel") or d:IsA("ImageButton")) and d.Image ~= "" then
			return d.Image
		end

		if (d:IsA("Decal") or d:IsA("Texture")) and d.Texture ~= "" then
			return d.Texture
		end

		if d:IsA("MeshPart") and d.TextureID ~= "" then
			return d.TextureID
		end

		if d:IsA("SurfaceAppearance") and d.ColorMap ~= "" then
			return d.ColorMap
		end

		if (d:IsA("StringValue") or d:IsA("IntValue") or d:IsA("NumberValue")) and hasImageWord(d.Name) then
			return normalizeImage(d.Value)
		end

		for name, value in pairs(d:GetAttributes()) do
			if hasImageWord(name) and (type(value) == "string" or type(value) == "number") then
				return normalizeImage(value)
			end
		end
	end

	local function firstImageIn(item)
		local image = imageOf(item)

		if image then
			return image
		end

		for _, d in ipairs(item:GetDescendants()) do
			image = imageOf(d)

			if image then
				return image
			end
		end
	end

	-- a SurfaceGui / BillboardGui that sits in PlayerGui but is attached ("Adornee") to this object
	local function attachedGuiImage(root)
		local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

		if not playerGui then
			return nil
		end

		for _, gui in ipairs(playerGui:GetDescendants()) do
			if (gui:IsA("SurfaceGui") or gui:IsA("BillboardGui")) and gui.Adornee
				and (gui.Adornee == root or gui.Adornee:IsDescendantOf(root)) then
				local image = firstImageIn(gui)

				if image then
					return image
				end
			end
		end
	end

	-- what is inside an object (for the "picture not found" note on a card)
	local function describe(root)
		if not root then
			return "nothing found"
		end

		local parts = {}

		for _, d in ipairs(root:GetDescendants()) do
			if #parts >= 8 then
				break
			end

			if d:IsA("SurfaceGui") or d:IsA("BillboardGui") or d:IsA("ImageLabel") or d:IsA("ImageButton")
				or d:IsA("Decal") or d:IsA("Texture") or d:IsA("MeshPart") or d:IsA("SurfaceAppearance")
				or d:IsA("ValueBase") or d:IsA("TextLabel") then
				parts[#parts + 1] = d.ClassName .. ":" .. d.Name
			end
		end

		return root.ClassName .. ":" .. root.Name .. " > " .. (#parts > 0 and table.concat(parts, ", ") or "no picture-like objects")
	end

	local function firstLabelIn(item)
		for _, d in ipairs(item:GetDescendants()) do
			if d:IsA("TextLabel") and #d.Text >= 2 and #d.Text <= 30
				and not string.match(d.Text, "^[%d%s%p]+$") and not matches(d.Text) then
				return d.Text
			end
		end
	end

	-- Where to stand on a detector: on top of it, or inside it when it is a tall invisible zone
	local function detectorPos(detector)
		local part = detector

		if not detector:IsA("BasePart") then
			part = detector:FindFirstChildWhichIsA("BasePart", true)
		end

		if not part then
			return nil
		end

		if part.Size.Y > 6 then
			return part.Position
		end

		return part.Position + Vector3.new(0, part.Size.Y / 2 + 3, 0)
	end

	-- The three maps up for vote (new MM2 lobby layout), for N = 1 / 2 / 3:
	--   name:    workspace.Lobby.VotePads.VotePadN.VoteInfoGui.Container.MapName
	--   picture: workspace.Lobby.VotePads.VotePadN.MapInfoGui.MapIcon
	--   spot we stand on to vote: workspace.Lobby.VotePads.VotePadN.Pad

	-- the text of one label, with formatting tags removed; empty / placeholder texts do not count
	local function readLabel(nameText)
		if nameText and nameText:IsA("TextLabel") then
			local text = nameText.ContentText ~= "" and nameText.ContentText or nameText.Text
			text = (string.gsub(text, "<[^>]+>", ""))

			if text ~= "" and text ~= "MapName" and text ~= "Label" and text ~= "TextLabel" then
				return text
			end
		end
	end

	-- ===== vote counts =====
	-- A number as the vote pad shows it: "5", "x5", "5 votes", "Votes: 5". Anything else is not a vote count.
	local function strictNumber(text)
		if type(text) ~= "string" then
			return nil
		end

		text = (string.gsub(text, "<[^>]+>", ""))
		text = string.match(text, "^%s*(.-)%s*$")

		local n = string.match(text, "^(%d+)$")
			or string.match(text, "^[xX]%s*(%d+)$")
			or string.match(text, "^(%d+)%s*[Vv][Oo][Tt][Ee][Ss]?$")
			or string.match(text, "^[Vv][Oo][Tt][Ee][Ss]?%s*:?%s*(%d+)$")

		return n and tonumber(n)
	end

	local function labelText(label)
		return label.ContentText ~= "" and label.ContentText or label.Text
	end

	local VOTE_NAME_WORDS = { "vote", "count", "amount", "score", "total" }

	local function looksLikeCounter(name)
		name = string.lower(name)

		if name == "mapname" then
			return false
		end

		for _, word in ipairs(VOTE_NAME_WORDS) do
			if string.find(name, word, 1, true) then
				return true
			end
		end

		return false
	end

	-- The number of votes on one vote pad (workspace.Lobby.VotePads.VotePadN), or nil when it cannot be found:
	--   1. a label / value named like a counter (Votes, VoteCount, Count ...) inside VoteInfoGui, then the pad
	--   2. an attribute named like a counter
	--   3. any lone number shown in VoteInfoGui
	local function readVotes(votePad)
		if not votePad then
			return nil
		end

		local infoGui = votePad:FindFirstChild("VoteInfoGui")
		local roots = {}

		if infoGui then
			roots[#roots + 1] = infoGui
		end

		roots[#roots + 1] = votePad

		for _, root in ipairs(roots) do
			for _, d in ipairs(root:GetDescendants()) do
				if looksLikeCounter(d.Name) then
					if d:IsA("TextLabel") or d:IsA("TextButton") then
						local n = strictNumber(labelText(d))

						if n then
							return n
						end
					elseif d:IsA("IntValue") or d:IsA("NumberValue") then
						return math.floor(d.Value)
					end
				end
			end
		end

		for _, root in ipairs({ votePad, infoGui }) do
			if root then
				for name, value in pairs(root:GetAttributes()) do
					if looksLikeCounter(name) and type(value) == "number" then
						return math.floor(value)
					end
				end
			end
		end

		if infoGui then
			for _, d in ipairs(infoGui:GetDescendants()) do
				if d:IsA("TextLabel") and string.lower(d.Name) ~= "mapname" then
					local n = strictNumber(labelText(d))

					if n then
						return n
					end
				end
			end
		end

		return nil
	end

	local function votePadAt(i)
		local lobby = workspace:FindFirstChild("Lobby")
		local padsFolder = lobby and lobby:FindFirstChild("VotePads")

		return padsFolder and padsFolder:FindFirstChild("VotePad" .. i)
	end

	local function scanFixed()
		local lobby = workspace:FindFirstChild("Lobby")
		local padsFolder = lobby and lobby:FindFirstChild("VotePads")

		if not padsFolder then
			return nil
		end

		local found = {}

		for i = 1, 3 do
			local votePad = padsFolder:FindFirstChild("VotePad" .. i)

			if votePad then
				local pad = votePad:FindFirstChild("Pad")
				local pos = (pad and detectorPos(pad)) or centerOf(votePad)

				if pos then
					local infoGui = votePad:FindFirstChild("VoteInfoGui")
					local container = infoGui and infoGui:FindFirstChild("Container")
					local mapGui = votePad:FindFirstChild("MapInfoGui")
					local icon = mapGui and mapGui:FindFirstChild("MapIcon")

					local label = readLabel(container and container:FindFirstChild("MapName"))
						or readLabel(votePad:FindFirstChild("MapName", true))
						or ("Map " .. i)

					local image = icon and firstImageIn(icon)
					image = toAssetUri(image)

					local note

					if not image then
						note = "Picture not found. MapIcon: " .. describe(icon)
					end

					found[#found + 1] = { name = label, image = image, pos = pos, note = note, padIndex = i }
				end
			end
		end

		return #found > 0 and found or nil
	end

	local statusPara -- the Paragraph at the top of the Maps tab (created at the bottom of this block)

	local function setStatus(text)
		if statusPara then
			pcall(function()
				statusPara:SetDesc(text)
			end)
		end
	end

	local refreshCells
	local updateVotes

	local function stopPicking(reason)
		pick.token = pick.token + 1
		pick.running = false
		pick.name = nil

		for i = #pick.conns, 1, -1 do
			pcall(function()
				pick.conns[i]:Disconnect()
			end)

			pick.conns[i] = nil
		end

		setStatus(reason or "Stopped.")

		if refreshCells then
			refreshCells()
		end
	end

	local function placeOn(pos)
		local character = localPlayer.Character
		local hrp = character and character:FindFirstChild("HumanoidRootPart")

		if hrp then
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.CFrame = CFrame.new(pos)
		end
	end

	-- Is a round's map in the world? Same signal the rest of the script uses (findMap / roundRunning).
	-- This does NOT depend on the Inventory GUI, so it still works when you are dead / spectating / just reset.
	local function mapLoaded()
		for _, child in ipairs(workspace:GetChildren()) do
			if child:IsA("Model") and child.Name ~= "RegularLobby" and child.Name ~= "Lobby"
				and (child:FindFirstChild("CoinContainer") or child:FindFirstChild("CoinAreas") or child:FindFirstChild("Spawns")) then
				return true
			end
		end

		return false
	end

	-- Has the round started (or is it starting)? Then we must stop.
	-- Several independent signals: if one of them fails (GUI missing, timer attribute not set), another still catches it.
	local function gameStarting()
		if not list2.inLobbyNow() then
			return true
		end

		if mapLoaded() then
			return true
		end

		local timerPart = workspace:FindFirstChild("RoundTimerPart")

		if timerPart and (tonumber(timerPart:GetAttribute("Time")) or 0) > 0 then
			return true
		end

		return false
	end

	local function startPicking(cand)
		-- Guard clause: voting only makes sense in the lobby vote phase. Once the map is loaded / the round runs,
		-- refuse here (the only entry point), instead of relying on the loop to notice later.
		if gameStarting() then
			stopPicking("A round is running. Wait for the lobby to vote.")
			obj2:Notify({ Title = "Map Picker", Content = "A round is running. Wait for the lobby to vote.", Duration = 4, Icon = "x" })
			return
		end

		pick.token = pick.token + 1
		local token = pick.token
		pick.running = true
		pick.name = cand.id -- which map (its number), not its name
		setStatus("Voting for the highlighted map. Tap it again to stop.")

		if refreshCells then
			refreshCells()
		end

		local function finish(reason)
			stopPicking(reason)
			obj2:Notify({ Title = "Map Picker", Content = reason, Duration = 4, Icon = "check" })
		end

		-- React the moment the game starts, not only when the loop looks: the map being put into the world
		-- (its coin container appears) or the round timer starting to count.
		pick.conns[#pick.conns + 1] = workspace.DescendantAdded:Connect(function(item)
			if pick.token == token and (item.Name == "CoinContainer" or item.Name == "CoinAreas") then
				finish("The map is loading. Stopped.")
			end
		end)

		local timerPart = workspace:FindFirstChild("RoundTimerPart")

		if timerPart then
			pick.conns[#pick.conns + 1] = timerPart:GetAttributeChangedSignal("Time"):Connect(function()
				if pick.token == token and (tonumber(timerPart:GetAttribute("Time")) or 0) > 0 then
					finish("The round started. Stopped.")
				end
			end)
		end

		local baselineSpawn -- where our new characters normally appear in the lobby
		local Heartbeat = RunService_.Heartbeat

		-- the character is "ready" the moment it has a living humanoid and a root part
		local function readyChar(char)
			if not char or not char.Parent then
				return nil
			end

			local humanoid = char:FindFirstChildOfClass("Humanoid")
			local root = char:FindFirstChild("HumanoidRootPart")

			if humanoid and root and humanoid.Health > 0 then
				return root
			end
		end

		-- Kill the character as fast as possible. Health = 0 alone is a server-owned value and is often
		-- ignored from the client; breaking the neck / removing the head is physics the client owns, so the
		-- server sees the humanoid die on the very next replication instead of us waiting and retrying.
		local function fastKill(char, humanoid)
			pcall(function()
				local head = char:FindFirstChild("Head")
				local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")

				for _, d in ipairs(char:GetDescendants()) do
					if d:IsA("Motor6D") and d.Name == "Neck" then
						d:Destroy()
					end
				end

				if head then
					head:Destroy()
				end

				if torso then
					torso:BreakJoints()
				end
			end)

			pcall(function()
				humanoid:ChangeState(Enum.HumanoidStateType.Dead)
				humanoid.Health = 0
				char:BreakJoints()
			end)
		end

		task.spawn(function()
			while pick.token == token do
				if gameStarting() then
					finish("The game is starting. Stopped.")
					return
				end

				-- 1. warp onto the detector the instant the character exists. For the first moments we keep
				-- snapping back (the server may still be placing the fresh character on its spawn), then we just stand.
				placeOn(cand.pos)

				local t0 = os.clock()
				local settleUntil = t0 + math.min(0.15, pick.interval)
				local stayUntil = t0 + pick.interval

				while pick.token == token and os.clock() < stayUntil do
					Heartbeat:Wait()

					if os.clock() < settleUntil then
						local r = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

						if r and (r.Position - cand.pos).Magnitude > 4 then
							placeOn(cand.pos)
						end
					end
				end

				if pick.token ~= token then
					return
				end

				if gameStarting() then
					finish("The game is starting. Stopped.")
					return
				end

				-- if the game has moved us far away from the detector, the round is starting: stop
				local hrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

				if hrp and (hrp.Position - cand.pos).Magnitude > 60 then
					finish("The game moved you. Stopped.")
					return
				end

				-- 2. reset right away and keep hitting it EVERY FRAME until the old character is really gone
				-- (a fresh character can ignore a single Health = 0)
				local old = localPlayer.Character
				local waitUntil = os.clock() + 12
				local newRoot

				while pick.token == token and os.clock() < waitUntil do
					local now = localPlayer.Character

					-- 3. the new character is here: go straight back to the detector (no extra waiting)
					if now ~= old then
						newRoot = readyChar(now)

						if newRoot then
							break
						end
					else
						local humanoid = old and old.Parent and old:FindFirstChildOfClass("Humanoid")

						if humanoid and humanoid.Health > 0 then
							fastKill(old, humanoid)
						end
					end

					Heartbeat:Wait()
				end

				if pick.token ~= token then
					return
				end

				if newRoot then
					local spawnPos = newRoot.Position

					if not baselineSpawn then
						baselineSpawn = spawnPos
					elseif (spawnPos - baselineSpawn).Magnitude > 150 then
						finish("The game moved you. Stopped.")
						return
					end
				end
			end
		end)
	end

	local ACCENT = Color3.fromRGB(34, 197, 94) -- same green as the script's other windows
	local DARK = Color3.fromRGB(10, 10, 13)
	local MUTED = Color3.fromRGB(150, 150, 160)

	local function styleBox(box, radius, strokeTransparency, strokeColor)
		box.BackgroundColor3 = DARK
		box.BackgroundTransparency = 0.25
		box.BorderSizePixel = 0
		Instance.new("UICorner", box).CornerRadius = UDim.new(0, radius)

		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 1
		stroke.Color = strokeColor or ACCENT
		stroke.Transparency = strokeTransparency
		stroke.Parent = box
		return stroke
	end

	refreshCells = function()
		for id, cell in pairs(pick.cells) do
			if cell.box.Parent then
				local active = pick.running and pick.name == id
				cell.stroke.Transparency = active and 0 or 0.55
				cell.stroke.Thickness = active and 2 or 1
				cell.box.BackgroundTransparency = active and 0.05 or 0.25
				if active then
					cell.hint.Text = "Voting... tap to stop"
				elseif pick.locked then
					cell.hint.Text = "Round running - wait for lobby"
				else
					cell.hint.Text = "Tap to vote for this map"
				end
				cell.hint.TextColor3 = active and ACCENT or MUTED
			end
		end
	end

	local votesWarned = false

	-- Re-reads the vote count of every card. One map clearly ahead gets the crown; maps tied for the most votes get the tie icon.
	-- It only changes the text / crown of the cards that are already drawn, it never rebuilds them.
	updateVotes = function()
		local best = 0
		local counts = {}
		local unreadable = false
		local anyPad

		for id, cell in pairs(pick.cells) do
			if cell.box.Parent then
				local votePad = votePadAt(cell.padIndex)
				anyPad = anyPad or votePad

				local n = votePad and readVotes(votePad)
				counts[id] = n

				if n then
					if n > best then
						best = n
					end
				else
					unreadable = true
				end
			end
		end

		-- how many maps share the top vote count (a tie when it is more than one)
		local leaders = 0
		for id, cell in pairs(pick.cells) do
			if cell.box.Parent then
				local n = counts[id]
				if n ~= nil and best > 0 and n == best then
					leaders = leaders + 1
				end
			end
		end
		local isTie = leaders > 1

		for id, cell in pairs(pick.cells) do
			if cell.box.Parent then
				local n = counts[id]
				local isLeader = n ~= nil and best > 0 and n == best
				cell.votes.Text = n and tostring(n) or "-"
				-- one map clearly ahead -> crown; maps tied for the top -> the tie icon instead
				cell.crown.Visible = isLeader and not isTie
				cell.tie.Visible = isLeader and isTie
			end
		end

		if unreadable and not votesWarned and not pick.running then
			votesWarned = true
			setStatus("Could not read the vote counts. VoteInfoGui: "
				.. describe(anyPad and anyPad:FindFirstChild("VoteInfoGui")))
		end
	end

	local function clearItems()
		for _, item in ipairs(pick.items) do
			pcall(function()
				item:Destroy()
			end)
		end

		pick.items = {}
		pick.cells = {}
	end

	-- The frame that holds the cards. It lives inside the Paragraph's container, the same way the Skins and
	-- Crosshair grids are put into the main UI (func119 reaches that container).
	local function getHolder()
		if pick.holder and pick.holder.Parent then
			return pick.holder
		end

		local container = statusPara and func119(statusPara)

		if not container then
			return nil
		end

		local holder = Instance.new("Frame")
		holder.Name = "FVLMapCards"
		holder.LayoutOrder = 0
		holder.BackgroundTransparency = 1
		holder.Size = UDim2.new(1, 0, 0, 0)
		holder.Parent = container

		local layout = Instance.new("UIListLayout")
		layout.FillDirection = Enum.FillDirection.Vertical
		layout.Padding = UDim.new(0, 6)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = holder

		local function fit()
			holder.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
		end

		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(fit)
		fit()

		pick.holder = holder
		return holder
	end

	local function signatureOf(found)
		local parts = {}

		for i, cand in ipairs(found) do
			parts[i] = tostring(cand.name) .. "|" .. tostring(cand.image) .. "|" .. tostring(cand.pos)
		end

		return table.concat(parts, ";")
	end

	local function makeLabel(parent, props)
		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Font = props.font or Enum.Font.Gotham
		label.TextSize = props.size or 12
		label.TextColor3 = props.color or Color3.fromRGB(255, 255, 255)
		label.TextXAlignment = props.xAlign or Enum.TextXAlignment.Left
		label.TextYAlignment = props.yAlign or Enum.TextYAlignment.Center
		label.TextWrapped = props.wrapped or false
		label.TextTruncate = props.truncate or Enum.TextTruncate.None
		label.Position = props.position
		label.Size = props.size2
		label.Text = props.text or ""
		label.Parent = parent
		return label
	end

	-- Draws one card (picture + name) per map up for vote, straight into the main UI.
	-- Does nothing when the maps are the same as the last time, unless force is true.
	local function renderCards(force)
		local holder = getHolder()

		if not holder then
			return
		end

		local found = scanFixed() or {}
		local sig = signatureOf(found)

		if not force and sig == pick.sig then
			return
		end

		pick.sig = sig
		clearItems()

		if #found == 0 then
			local empty = makeLabel(holder, {
				position = UDim2.new(0, 0, 0, 0),
				size2 = UDim2.new(1, 0, 0, 44),
				text = "No maps up for vote right now. Go to the lobby, or tap Refresh Maps.",
				color = MUTED,
				wrapped = true,
			})

			pick.items[#pick.items + 1] = empty
			return
		end

		for i, cand in ipairs(found) do
			cand.id = i

			local cell = Instance.new("TextButton")
			cell.Name = "Map" .. i
			cell.LayoutOrder = i
			cell.Size = UDim2.new(1, 0, 0, 84)
			cell.Text = ""
			cell.AutoButtonColor = false
			cell.Parent = holder
			local stroke = styleBox(cell, 8, 0.55)

			-- the picture of the map
			local picture = Instance.new("ImageLabel")
			picture.Name = "Picture"
			picture.Position = UDim2.new(0, 6, 0, 6)
			picture.Size = UDim2.new(0, 112, 1, -12)
			picture.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
			picture.BorderSizePixel = 0
			picture.ScaleType = Enum.ScaleType.Crop
			picture.Image = cand.image or ""
			picture.Parent = cell
			Instance.new("UICorner", picture).CornerRadius = UDim.new(0, 6)

			if not cand.image then
				makeLabel(picture, {
					position = UDim2.new(0, 0, 0, 0),
					size2 = UDim2.new(1, 0, 1, 0),
					text = "Wait for next round",
					size = 12,
					color = MUTED,
					xAlign = Enum.TextXAlignment.Center,
					wrapped = true,
				})
			end

			-- the name of the map (leaves room on the right for the crown and the vote count)
			makeLabel(cell, {
				position = UDim2.new(0, 128, 0, 10),
				size2 = UDim2.new(1, -208, 0, 40),
				text = cand.name,
				font = Enum.Font.GothamBold,
				size = 14,
				yAlign = Enum.TextYAlignment.Top,
				wrapped = true,
				truncate = Enum.TextTruncate.AtEnd,
			})

			local hint = makeLabel(cell, {
				position = UDim2.new(0, 128, 1, -26),
				size2 = UDim2.new(1, -208, 0, 18),
				text = "Tap to vote for this map",
				size = 11,
				color = MUTED,
			})

			-- the crown (only shown on the map with the most votes)
			local crown = Instance.new("ImageLabel")
			crown.Name = "Crown"
			crown.AnchorPoint = Vector2.new(0.5, 0)
			crown.Position = UDim2.new(1, -40, 0, 8)
			crown.Size = UDim2.fromOffset(28, 28)
			crown.BackgroundTransparency = 1
			crown.Image = "rbxassetid://6495659621"
			crown.ScaleType = Enum.ScaleType.Fit
			crown.Visible = false
			crown.Parent = cell

			-- the tie icon (shown instead of the crown on maps that are tied for the most votes)
			local tie = Instance.new("ImageLabel")
			tie.Name = "TieIcon"
			tie.AnchorPoint = Vector2.new(0.5, 0)
			tie.Position = UDim2.new(1, -40, 0, 8)
			tie.Size = UDim2.fromOffset(28, 28)
			tie.BackgroundTransparency = 1
			tie.Image = "rbxassetid://107372061126060"
			tie.ScaleType = Enum.ScaleType.Fit
			tie.Visible = false
			tie.Parent = cell

			-- the vote count
			local votes = makeLabel(cell, {
				position = UDim2.new(1, -40, 0, 38),
				size2 = UDim2.fromOffset(64, 22),
				text = "-",
				font = Enum.Font.GothamBold,
				size = 18,
				color = ACCENT,
				xAlign = Enum.TextXAlignment.Center,
			})
			votes.Name = "Votes"
			votes.AnchorPoint = Vector2.new(0.5, 0)

			local votesCaption = makeLabel(cell, {
				position = UDim2.new(1, -40, 0, 60),
				size2 = UDim2.fromOffset(64, 14),
				text = "votes",
				size = 10,
				color = MUTED,
				xAlign = Enum.TextXAlignment.Center,
			})
			votesCaption.AnchorPoint = Vector2.new(0.5, 0)

			pick.cells[i] = { box = cell, stroke = stroke, hint = hint, crown = crown, tie = tie, votes = votes, padIndex = cand.padIndex }
			pick.items[#pick.items + 1] = cell

			cell.Activated:Connect(function()
				if pick.running and pick.name == cand.id then
					stopPicking("Stopped.") -- tapping the chosen map again turns it off
				else
					startPicking(cand)
				end
			end)
		end

		refreshCells()
		updateVotes()
	end

	-- ===== the Maps tab =====
	tbl43.maps:Section({ Title = "Map Picker" })

	statusPara = tbl43.maps:Paragraph({
		Title = "Maps up for vote [EXPERIMENTAL]",
		Desc = "Tap a map card. You stand on its detector, reset, stand on it again... every time adds another vote for that map, until the game starts. Tap the card again to stop. Each card shows its vote count, and the map with the most votes gets a crown.",
	})

	tbl43.maps:Button({
		Title = "Refresh Maps",
		Icon = "lucide:refresh-cw",
		Desc = "Reads the maps up for vote again (the cards also refresh by themselves).",
		Callback = function()
			renderCards(true)
		end,
	})

	tbl43.maps:Slider({
		Title = "Map Picker: Seconds Before Reset",
		Flag = "Slider_Map_Picker_Interval",
		Desc = "How long you stay on the detector after warping, before the character is reset right away. Lower = faster cycles. If votes do not register, raise it a little.",
		Step = 0.05,
		Value = { Min = 0.05, Max = 5, Default = 0.2 },
		Callback = function(value)
			local n = tonumber(value) or type(value) == "table" and tonumber(value.Value)

			if n then
				pick.interval = n
			end
		end,
	})

	-- the picking stops when the UI is closed
	pcall(function()
		obj3:OnDestroy(function()
			pcall(stopPicking, "UI closed.")
		end)
	end)

	-- live vote counts + crown: re-read the vote pads twice a second (also while a pick is running)
	task.spawn(function()
		while not obj3.Destroyed do
			task.wait(0.5)

			if pick.holder and not pick.holder.Parent then
				break
			end

			local visible = true
			pcall(function()
				local root = obj3._oasis and obj3._oasis.Root
				if root then
					visible = root.Visible
				end
			end)

			if visible and next(pick.cells) ~= nil then
				pcall(updateVotes)

				-- lock / unlock the cards when the round starts / ends
				local okLock, locked = pcall(gameStarting)

				if okLock and locked ~= (pick.locked or false) then
					pick.locked = locked
					pcall(refreshCells)
				end
			end
		end
	end)

	-- draw the cards now, then keep them in sync with the vote pads (not while a pick is running or in a round)
	task.spawn(function()
		pcall(renderCards, true)

		while not obj3.Destroyed do
			task.wait(4)

			if pick.holder and not pick.holder.Parent then
				break
			end

			local visible = true
			pcall(function()
				local root = obj3._oasis and obj3._oasis.Root
				if root then
					visible = root.Visible
				end
			end)

			local inLobby = true
			pcall(function()
				inLobby = list2.inLobbyNow()
			end)

			if visible and inLobby and not pick.running then
				pcall(renderCards, false)
			end
		end
	end)
end

-- ===== Invisible =====
-- Same principle as the invisibility script you sent: every frame, right after the physics step (when your
-- position is sent to the other players), the character's root part is moved 200000 studs straight down and the
-- camera offset is raised by the same amount; right before the next frame is drawn both are put back. You see
-- and control yourself normally, while the server and other players only ever receive a position far under the
-- map. Your body is also drawn half transparent on YOUR screen so you can tell it is on.
-- Side effects: others see you far away, so touching things on the map (coins, doors) and your own hits may not
-- register while it is on.
-- Shift Lock fix: the camera and Shift Lock read your character's position every frame at their own point in the
-- frame. The "put back where I really am" step is therefore bound at the very FIRST render priority (before the
-- camera and before Shift Lock turn your character), so they always see the real, normal position and never the
-- spot far under the map.
do
	local RunService_ = game:GetService("RunService")
	local DEPTH = 200000
	local inv = { on = false, saved = nil, conns = {}, parts = {} }
	list2.invis = inv

	local function restoreSaved()
		local saved = inv.saved
		inv.saved = nil

		if saved and saved.hrp.Parent and saved.hum.Parent then
			saved.hrp.CFrame = saved.cf
			saved.hum.CameraOffset = saved.off
		end
	end

	local function restoreParts()
		for i = #inv.parts, 1, -1 do
			local part = inv.parts[i]

			if part.Parent then
				part.Transparency = 0
			end

			inv.parts[i] = nil
		end
	end

	local function collectParts(character)
		if not character then
			return
		end

		for _, item in ipairs(character:GetDescendants()) do
			if item:IsA("BasePart") and item.Name ~= "HumanoidRootPart" and item.Transparency == 0 then
				item.Transparency = 0.5
				inv.parts[#inv.parts + 1] = item
			end
		end
	end

	list2.setInvisible = function(on)
		on = on and true or false

		if inv.on == on then
			return
		end

		inv.on = on

		for i = #inv.conns, 1, -1 do
			pcall(function()
				inv.conns[i]:Disconnect()
			end)

			inv.conns[i] = nil
		end

		pcall(function()
			RunService_:UnbindFromRenderStep("FVLInvisRestore")
		end)

		restoreSaved()
		restoreParts()

		if on then
			collectParts(localPlayer.Character)

			-- after physics: what gets sent to everyone is the position far under the map
			inv.conns[#inv.conns + 1] = RunService_.Heartbeat:Connect(function()
				pcall(function()
					local character = localPlayer.Character
					local hrp = character and character:FindFirstChild("HumanoidRootPart")
					local humanoid = character and character:FindFirstChildOfClass("Humanoid")

					if not hrp or not humanoid or humanoid.Health <= 0 then
						return
					end

					local cf, off = hrp.CFrame, humanoid.CameraOffset
					inv.saved = { hrp = hrp, hum = humanoid, cf = cf, off = off }
					hrp.CFrame = cf * CFrame.new(0, -DEPTH, 0)
					humanoid.CameraOffset = off + Vector3.new(0, DEPTH, 0)
				end)
			end)

			-- before the camera / Shift Lock / the next frame: back to where we really are (first render priority)
			RunService_:BindToRenderStep("FVLInvisRestore", Enum.RenderPriority.First.Value, restoreSaved)

			-- a new character (respawn): pick up its parts again
			inv.conns[#inv.conns + 1] = localPlayer.CharacterAdded:Connect(function(character)
				task.wait(1)

				if inv.on and localPlayer.Character == character then
					restoreParts()
					collectParts(character)
				end
			end)
		end

		-- keep the floating button and the tab switch in step with each other
		pcall(function()
			num15.setActive("Invis", on)
		end)

		pcall(function()
			list2.setToggle(list2.invisToggle, on)
		end)
	end
end

func120(ICON.mono)
tbl43.crosshair:Section({ Title = "Sheriff Crosshair" })

tbl43.crosshair:Dropdown({
	Title = "Crosshair Mode",
	Flag = "Dropdown_Crosshair_Mode",
	Desc = "Center Lock: the crosshair stays pinned to the middle of the screen and the game's Shift Lock reticle is hidden. Follow Finger: the crosshair follows your finger like before, and the original Shift Lock reticle comes back.",
	Multi = false,
	Value = flag135.mode == "Finger" and "Follow Finger" or "Center Lock",
	Values = { "Center Lock", "Follow Finger" },
	Callback = function(value)
		local chosen = tostring(type(value) == "table" and (value[1] or value.Value) or value)

		if chosen:find("Finger") then
			flag135.mode = "Finger"

			if flag135.restoreReticle then
				flag135.restoreReticle()
			end
		else
			flag135.mode = "Center"
		end
	end,
})

tbl43.crosshair:Toggle({
	Title = "Spin Cursor",
	Flag = "Toggle_Spin_Cursor",
	Desc = "Slowly rotates the crosshair image.",
	Type = "Toggle",
	Value = false,
	Callback = func112(function(spin)
		flag135.spin = spin
	end),
})

tbl43.crosshair:Slider({
	Title = "Crosshair Size",
	Flag = "Slider_Crosshair_Size",
	Desc = "Size in pixels.",
	Step = 1,
	Value = { Min = 12, Max = 80, Default = 50 },
	Callback = func112(function(size)
		flag135.size = size

		if value130 then
			value130.Size = UDim2.fromOffset(size, size)
		end
	end),
})

CURSOR_ORDER = {
	"Default",
	"Hello Kitty",
	"Kitty v2",
	"Clean Kitty",
	"Evil Kitty",
	"Kuromi",
	"Pixel Cat",
	"Paw",
	"Cat",
	"Heart",
	"Red Heart",
	"Green Heart",
	"Blue Heart",
	"Yellow Heart",
	"Heart Cross",
	"Star",
	"Star v2",
	"Pink Star",
	"Power Star",
	"Cross",
	"Pentagram",
	"Gengar",
	"Bunny",
	"Vamp Face",
	"Osu",
	"Troll",
	"Glowing Circle",
	"Donut",
	"Blue Donut",
	"Death",
	"Bear",
	"Barbie",
	"Shoot this guy",
}

do
	local tbl112 = {}
	local value220 = tbl43.crosshair:Paragraph({ Title = "Crosshair", Desc = "" })

	local function func198()
		for k, value221 in pairs(tbl112) do
			local flag198 = k == flag135.style
			value221.stroke.Color = flag198 and ICON.pink or Color3.fromRGB(255, 255, 255)
			value221.stroke.Transparency = flag198 and 0.1 or 0.85
			value221.label.TextColor3 = flag198 and Color3.fromRGB(240, 240, 246) or Color3.fromRGB(150, 150, 160)
		end
	end

	local flag199 = func119(value220)

	if not flag199 then
		warn("[FVL] couldn't reach the Paragraph container - cursor grid skipped")
	else
		local ceiled = math.ceil(#CURSOR_ORDER / 4)
		local frame = Instance.new("Frame")
		frame.Name = "FVLCursorGrid"
		frame.BackgroundTransparency = 1
		frame.Size = UDim2.new(1, 0, 0, ceiled * 84 + (ceiled - 1) * 6)
		frame.Parent = flag199
		local uiGridLayout = Instance.new("UIGridLayout")
		uiGridLayout.CellSize = UDim2.fromOffset(84, 84)
		uiGridLayout.CellPadding = UDim2.fromOffset(6, 6)
		uiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uiGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uiGridLayout.Parent = frame

		local function func199()
			frame.Size = UDim2.new(1, 0, 0, uiGridLayout.AbsoluteContentSize.Y)
		end

		uiGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(func199)
		func199()

		for i, item65 in ipairs(CURSOR_ORDER) do
			local textButton = Instance.new("TextButton")
			textButton.Name = item65
			textButton.LayoutOrder = i
			textButton.Text = ""
			textButton.AutoButtonColor = false
			textButton.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
			textButton.BackgroundTransparency = 0.25
			textButton.BorderSizePixel = 0
			textButton.Parent = frame
			Instance.new("UICorner", textButton).CornerRadius = UDim.new(0, 10)
			local uiStroke = Instance.new("UIStroke")
			uiStroke.Thickness = 1.5
			uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			uiStroke.Parent = textButton
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.BackgroundTransparency = 1
			imageLabel.AnchorPoint = Vector2.new(0.5, 0)
			imageLabel.Position = UDim2.new(0.5, 0, 0, 5)
			imageLabel.Size = UDim2.fromOffset(56, 56)
			imageLabel.Image = CURSORS[item65]
			imageLabel.ScaleType = Enum.ScaleType.Stretch
			imageLabel.Parent = textButton
			local textLabel = Instance.new("TextLabel")
			textLabel.BackgroundTransparency = 1
			textLabel.AnchorPoint = Vector2.new(0.5, 1)
			textLabel.Position = UDim2.new(0.5, 0, 1, -4)
			textLabel.Size = UDim2.new(1, -6, 0, 18)
			textLabel.Font = Enum.Font.GothamBold
			textLabel.TextSize = 10
			textLabel.TextWrapped = true
			textLabel.Text = item65
			textLabel.Parent = textButton

			textButton.MouseButton1Click:Connect(function()
				flag135.style = item65
				func111()
				func198()
			end)

			tbl112[item65] = { tile = textButton, stroke = uiStroke, label = textLabel, img = imageLabel }
		end

		func198()
	end
end

flag136 = true
func111()
func120(ICON.mono)
tbl43.settings:Section({ Title = "Interface" })

list2.setOpacity = function(param160)
	local uiOpacity = math.clamp(tonumber(param160) or 60, 0, 100)
	list2.uiOpacity = uiOpacity
	local n4 = 1 - uiOpacity / 100

	pcall(function()
		obj3:SetBackgroundTransparency(n4)
	end)

	pcall(function()
		obj3:SetBackgroundImageTransparency(n4 * 0.875)
	end)

	local opTok = (list2.opTok or 0) + 1
	list2.opTok = opTok

	task.delay(0.12, function()
		if list2.opTok ~= opTok then
			return
		end

		pcall(function()
			local fvlTheme = obj2.Themes and obj2.Themes["F$VL"]
			if not fvlTheme then
				return
			end
			fvlTheme.ElementBackgroundTransparency = math.min(n4 * 0.75, 0.6)
			obj2:SetTheme("F$VL")
		end)
	end)
end

tbl43.settings:Slider({
	Title = "UI Opacity",
	Flag = "Slider_UI_Opacity",
	Desc = "How solid the window is. 100 hides the game behind it completely, low turns it to glass.",
	Step = 1,
	Value = { Min = 0, Max = 100, Default = 60 },
	Callback = function(value)
		list2.setOpacity(tonumber(value) or type(value) == "table" and tonumber(value.Value) or 60)
	end,
})

tbl43.settings:Section({ Title = "Protection" })
list2.antiStealer = false

tbl43.settings:Toggle({
	Title = "Anti Stealer",
	Flag = "Toggle_Anti_Stealer",
	Desc = "Stops other scripts you run from taking your godlys and other valuable items.",
	Type = "Toggle",
	Value = false,
	Callback = function(antiStealer)
		list2.antiStealer = antiStealer
	end,
})

tbl43.settings:Section({ Title = "Server" })

tbl43.settings:Button({
	Title = "Rejoin",
	Desc = "Rejoins the server you are in right now",
	Icon = "lucide:rotate-cw",
	Callback = function()
		obj2:Notify({ Title = "Rejoin", Content = "Rejoining...", Duration = 2, Icon = "loader" })

		local ok = pcall(function()
			local TeleportService = game:GetService("TeleportService")

			if #Players:GetPlayers() <= 1 then
				TeleportService:Teleport(game.PlaceId, localPlayer)
			else
				TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, localPlayer)
			end
		end)

		if not ok then
			obj2:Notify({ Title = "Rejoin", Content = "Could not rejoin.", Duration = 2, Icon = "x" })
		end
	end,
})

tbl43.settings:Button({
	Title = "Server Hop",
	Desc = "Quickly join another server",
	Icon = "lucide:arrow-right-left",
	Callback = function()
		task.spawn(func32)
	end,
})

tbl43.settings:Button({
	Title = "Smallest Server",
	Desc = "Join the server with the fewest players",
	Icon = "lucide:users",
	Callback = function()
		task.spawn(func33)
	end,
})

tbl43.settings:Section({ Title = "Config" })
list2.cfgName = ""

list2.namedConfig = function(param161)
	local config = obj3.ConfigManager:GetConfig(param161) or obj3.ConfigManager:CreateConfig(param161)

	if config and list2.config and list2.config.Elements then
		config.Elements = list2.config.Elements
	end

	return config
end

list2.hudFileFor = function(str36)
	if not str36 or str36 == "" or str36 == "autosave" then
		return list2.hudFile
	end
	return list2.hudDir .. "/" .. str36 .. ".json"
end

list2.hudSaveTo = function(param162)
	pcall(function()
		if writefile then
			local value222 = HttpService
			local jsonEncode = value222.JSONEncode
			local captureHud = list2.captureHud
			writefile(list2.hudFileFor(param162), jsonEncode(value222, captureHud()))
		end
	end)
end

list2.hudLoadFrom = function(param163)
	pcall(function()
		local hudFileF = list2.hudFileFor(param163)

		if isfile and isfile(hudFileF) then
			local data = HttpService:JSONDecode(readfile(hudFileF))

			if type(data) == "table" then
				list2.hudPos = data
				list2.applyHud()
			end
		end
	end)
end

list2.namedList = function()
	local list45 = {}

	pcall(function()
		local func200 = ipairs
		local config = list2.config and obj3.ConfigManager:AllConfigs() or {}

		for _, value223 in func200(config) do
			if value223 ~= "autosave" and not tostring(value223):match("^fvl_hud") then
				list45[#list45 + 1] = value223
			end
		end
	end)

	return list45
end

list2.el.cfgList = tbl43.settings:Dropdown({
	Title = "Saved Configs",
	Desc = "Pick one, then use Load or Delete",
	Multi = false,
	Value = nil,
	Values = list2.namedList(),
	Callback = function(value)
		list2.cfgName = tostring(value or "")
	end,
})

list2.refreshCfgList = function()
	pcall(function()
		if list2.el.cfgList and list2.el.cfgList.Refresh then
			list2.el.cfgList:Refresh(list2.namedList())
		elseif list2.el.cfgList and list2.el.cfgList.SetValues then
			list2.el.cfgList:SetValues(list2.namedList())
		end
	end)
end

list2.el.cfgInput = tbl43.settings:Input({
	Title = "Config Name",
	Desc = "Name to save under, or type an existing one to load/delete",
	Placeholder = "myconfig",
	Callback = function(value)
		list2.cfgName = tostring(value or "")
	end,
})

list2.DEFAULT_CFG = "F$VL_Default"

pcall(function()
	local config = obj3.ConfigManager:GetConfig(list2.DEFAULT_CFG) or obj3.ConfigManager:CreateConfig(list2.DEFAULT_CFG)

	if list2.config and list2.config.Elements then
		config.Elements = list2.config.Elements
	end

	config:Save()
	local tbl113 = {}

	for k, value224 in next, tbl35, nil do
		tbl113[k] = { value224.X.Scale, value224.X.Offset, value224.Y.Scale, value224.Y.Offset }
	end

	if writefile then
		local value225 = HttpService
		local jsonEncode = value225.JSONEncode
		writefile(list2.hudFileFor(list2.DEFAULT_CFG), jsonEncode(value225, tbl113))
	end
end)

list2.refreshCfgList()

list2.cfgPick = function(flag200)
	local flag201 = (list2.cfgName or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if flag201 == "" then
		obj2:Notify({ Title = "Config", Content = "Pick or type a name first.", Duration = 4, Icon = "x" })
		return nil
	end

	if flag201 == "autosave" then
		obj2:Notify({
			Title = "Config",
			Content = "That name is reserved for the autosave.",
			Duration = 4,
			Icon = "x",
		})

		return nil
	end

	if flag201 == list2.DEFAULT_CFG and flag200 ~= "load" then
		obj2:Notify({
			Title = "Protected Config",
			Content = "F$VL_Default is the built-in fallback - it cannot be " .. (flag200 == "delete" and "deleted." or "overwritten."),
			Duration = 5,
			Icon = "shield",
		})

		return nil
	end

	return flag201
end

list2.cfgApply = function(flag202)
	if flag202 ~= list2.DEFAULT_CFG then
		pcall(function()
			list2.namedConfig(list2.DEFAULT_CFG):Load()
		end)

		task.wait(0.35)
	end

	return (pcall(function()
		list2.namedConfig(flag202):Load()
	end))
end

tbl43.settings:Button({
	Title = "Load Config",
	Desc = "Applies the named config to every setting and button position.",
	Icon = "lucide:folder-open",
	Callback = function()
		local load = list2.cfgPick("load")
		if not load then
			return
		end

		task.spawn(function()
			local flag203 = list2.cfgApply(load)
			list2.hudLoadFrom(load)

			task.delay(1, function()
				pcall(list2.saveNow)
			end)

			obj2:Notify({
				Title = flag203 and "Config Loaded!" or "Config",
				Content = flag203 and "Loaded " .. load or "Could not load that config.",
				Duration = 4,
				Icon = flag203 and "check" or "x",
			})
		end)
	end,
})

tbl43.settings:Button({
	Title = "Save Config",
	Desc = "Writes your current settings and button positions to the name above.",
	Icon = "lucide:save",
	Callback = function()
		local save = list2.cfgPick("save")
		if not save then
			return
		end

		local ok = pcall(function()
			list2.namedConfig(save):Save()
		end)

		list2.hudSaveTo(save)
		list2.refreshCfgList()

		obj2:Notify({
			Title = ok and "Config Saved!" or "Config",
			Content = ok and "Saved as " .. save or "Could not save.",
			Duration = 4,
			Icon = ok and "check" or "x",
		})
	end,
})

tbl43.settings:Button({
	Title = "Delete Config",
	Desc = "Removes the named config. Leaves the autosave alone.",
	Icon = "lucide:trash",
	Callback = function()
		local delete = list2.cfgPick("delete")
		if not delete then
			return
		end

		local ok = pcall(function()
			local config = obj3.ConfigManager:GetConfig(delete)

			if config then
				config:Delete()
			else
				obj3.ConfigManager:DeleteConfig(delete)
			end
		end)

		pcall(function()
			local hudFileF2 = list2.hudFileFor(delete)

			if delfile and isfile and isfile(hudFileF2) then
				delfile(hudFileF2)
			end
		end)

		if list2.cfgName == delete then
			list2.cfgName = ""
		end

		list2.refreshCfgList()

		obj2:Notify({
			Title = ok and "Config Deleted!" or "Config",
			Content = ok and delete .. " removed." or "Could not delete that config.",
			Duration = 4,
			Icon = ok and "check" or "x",
		})
	end,
})

tbl43.settings:Paragraph({
	Title = "Autosave Config",
	Desc = "Everything saves itself a couple of seconds after you change it and comes back next time you execute. Separate from the named configs above.",
})

tbl43.settings:Button({
	Title = "Delete Autosave Config",
	Desc = "Wipes the saved config and goes back to defaults on next execute",
	Icon = "lucide:trash-2",
	Callback = function()
		if not list2.config then
			obj2:Notify({ Title = "Config", Content = "Nothing to delete.", Duration = 3, Icon = "x" })
			return
		end
		list2.cfgWiped = true
		list2.hudPos = {}

		local ok = pcall(function()
			list2.config:Delete()
		end)

		pcall(function()
			if delfile and isfile and isfile(list2.hudFile) then
				delfile(list2.hudFile)
			end
		end)

		obj2:Notify({
			Title = ok and "Config Deleted!" or "Config",
			Content = ok and "Re-execute the script to come up on defaults." or "Could not delete the config file.",
			Duration = 6,
			Icon = ok and "check" or "x",
		})
	end,
})

func118("Load Config", Color3.fromHex("#86EFAC"))
func118("Save Config", Color3.fromHex("#FDE68A"))
func118("Delete Config", Color3.fromHex("#FCA5A5"))
func118("Delete Autosave Config", Color3.fromHex("#FCA5A5"))

local function fvlV2Cleanup()
	func22()
	func30()
	flag18 = false
	flag19 = false
	flag20 = false
	obj4:Destroy()
	list2.unreveal()
	flag41 = false
	flag42 = false
	flag43 = false
	flag44 = false
	func40()
	func42()
	func44()
	func46()
	func37(16)
	func38(50)
	func49()
	func51()
	func53()
	list2.stopShells()
	local func201 = ipairs
	local boxes = list2.BOXES or {}

	for _, boxe in func201(boxes) do
		list2.boxOn[boxe[1]] = false
	end

	list2.stopFarmHopWatch()
	list2.flingAllRunning = false
	num16.enabled = false
	num16.stop()
	func110()
	func69()

	pcall(function()
		if _G.__MM2Viz and _G.__MM2Viz.destroy then
			_G.__MM2Viz.destroy()
		end
	end)

	if keybindConn then
		pcall(function()
			keybindConn:Disconnect()
		end)

		keybindConn = nil
	end

	if obj9 then
		pcall(function()
			obj9:Disconnect()
		end)

		obj9 = nil
	end

	if connection then
		pcall(function()
			connection:Disconnect()
		end)

		connection = nil
	end

	if connection2 then
		pcall(function()
			connection2:Disconnect()
		end)

		connection2 = nil
	end

	if connection4 then
		pcall(function()
			connection4:Disconnect()
		end)

		connection4 = nil
	end

	if connection3 then
		pcall(function()
			connection3:Disconnect()
		end)

		connection3 = nil
	end

	if connection5 then
		pcall(function()
			connection5:Disconnect()
		end)

		connection5 = nil
	end

	for _, item66 in ipairs(tbl34) do
		pcall(function()
			item66:Disconnect()
		end)
	end

	tbl34 = {}
	num15.destroyAll()
	func113()

	pcall(function()
		if list2.perf then
			list2.perf.restoreAll()
		end
	end)

	pcall(function()
		if ROLEBOX then
			ROLEBOX.stop()
		end
	end)

	list2.stopVelTracker()
	list2.tr.stop()
	list2.setXray(false)
	list2.dropConns(list2.conns)
	list2.reclip(list2.clipWas)
	list2.reclip(list2.farmClipWas)
	_G.FVLSilentTarget = nil
end

-- ============================================================================
--  Meow mascots
--  Ported from the Mimka build. UI lives in  Settings & Configs  ->  "Meow".
--  An animated mascot (Mimi / Furry / Koti / Protogen Bongo, or your own
--  image via Custom) that sits on the top-right corner of the menu.
-- ============================================================================
do
	local RunService_ = game:GetService("RunService")
	local GuiService_ = game:GetService("GuiService")

	local ASSET_BASE = "https://raw.githubusercontent.com/Royal-Script-hub/mimka/main/"
	local FRAME_INTERVAL = 0.12

	local canAssets = (writefile and getcustomasset) and true or false

	-- one entry per mascot. dx/dy = how far the mascot sits in from the menu's
	-- top-right corner (dy is how far it rises above the top edge), w/h in px at 100%.
	local MASCOTS = {
		Mimi = { file = "mimka.png", kind = "sheet", cols = 5, rows = 5, frames = 23, w = 128, h = 160, dx = 120, dy = 100 },
		Furry = { file = "furryan.png", kind = "sheet", cols = 5, rows = 4, frames = 18, w = 128, h = 128, dx = 135, dy = 57 },
		Koti = { file = "koti1.png", kind = "static", w = 230, h = 230, dx = 230, dy = 90 },
		["Protogen Bongo"] = { file = "protogen-bongo.png", kind = "strip", cols = 5, frames = 2, w = 128, h = 128, dx = 150, dy = 23 },
		Custom = { kind = "static", w = 230, h = 230, dx = 230, dy = 90 },
	}

	local M = {
		choice = "None",
		scale = 1,
		offX = 0,
		offY = 0,
		customUrl = "",
		token = 0,
		gui = nil,
		cur = nil,
		acc = 0,
		alpha = 0,
		conn = nil,
		sq = 0, -- squash amount (1 = fully squashed, below 0 = stretched past normal)
		sqVel = 0,
		sqGoal = 0,
	}

	-- remove an overlay left behind by a crashed run
	pcall(function()
		for _, child in ipairs(hui:GetChildren()) do
			if child.Name == "FVLMeowOverlay" then
				child:Destroy()
			end
		end
	end)

	local function say(content, icon)
		pcall(function()
			obj2:Notify({ Title = "Meow", Content = content, Duration = 3, Icon = icon or "check" })
		end)
	end

	-- images -----------------------------------------------------------------
	local assetCache = {}

	-- downloads a PNG and turns it into a local asset id (cached per url)
	local function fetchAsset(url, tag)
		if assetCache[url] then
			return assetCache[url]
		end
		if not canAssets then
			return nil
		end

		local okGet, data = pcall(function()
			return game:HttpGet(url)
		end)
		if not okGet or type(data) ~= "string" or data == "" then
			return nil
		end

		local file = ("fvl_%s_%d.png"):format(tag, math.random(100000, 999999))
		if not pcall(writefile, file, data) then
			return nil
		end

		local okAsset, asset = pcall(getcustomasset, file)
		task.delay(5, function()
			pcall(function()
				if delfile then
					delfile(file)
				end
			end)
		end)

		if okAsset and type(asset) == "string" and asset ~= "" then
			assetCache[url] = asset
			return asset
		end
		return nil
	end

	-- the menu window -------------------------------------------------------------
	local rootCache
	local lastScan = 0

	local function viewport()
		local cam = workspace.CurrentCamera
		return cam and cam.ViewportSize or Vector2.new(1920, 1080)
	end

	local function isFullScreen(inst)
		local v, sz = viewport(), inst.AbsoluteSize
		return sz.X >= v.X * 0.95 and sz.Y >= v.Y * 0.95
	end

	-- climb up to the outermost frame that is still a window (not a full-screen layer)
	local function outerFrame(inst)
		local cur = inst
		while cur.Parent and cur.Parent:IsA("GuiObject") and not isFullScreen(cur.Parent) do
			cur = cur.Parent
		end
		return cur
	end

	local function findRoot()
		local r = oasisWindow and oasisWindow.Root
		if typeof(r) == "Instance" and r:IsA("GuiObject") then
			return outerFrame(r)
		end

		-- fallback: the biggest non-full-screen frame inside the UI library's GUIs
		local best, bestArea = nil, 200 * 200
		for _, g in ipairs(_FVL.libGuis or {}) do
			for _, d in ipairs(g:GetDescendants()) do
				if d:IsA("Frame") and not isFullScreen(d) then
					local area = d.AbsoluteSize.X * d.AbsoluteSize.Y
					if area > bestArea then
						best, bestArea = d, area
					end
				end
			end
		end
		return best and outerFrame(best)
	end

	local function getRoot()
		local now = os.clock()
		if rootCache and rootCache.Parent and now - lastScan < 3 then
			return rootCache
		end
		lastScan = now
		rootCache = findRoot() or (rootCache and rootCache.Parent and rootCache) or nil
		return rootCache
	end

	local function isShown(inst)
		local cur = inst
		while cur and cur ~= game do
			if cur:IsA("GuiObject") and not cur.Visible then
				return false
			end
			if cur:IsA("LayerCollector") and not cur.Enabled then
				return false
			end
			cur = cur.Parent
		end
		local size = inst.AbsoluteSize
		return size.X > 40 and size.Y > 40
	end

	-- mascot -------------------------------------------------------------------
	local function ensureOverlay()
		if M.gui and M.gui.Parent then
			return
		end
		local gui = Instance.new("ScreenGui")
		gui.Name = "FVLMeowOverlay"
		gui.IgnoreGuiInset = true
		gui.ResetOnSpawn = false
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
		gui.DisplayOrder = 10000
		gui.Parent = hui
		M.gui = gui
	end

	local function clearMascot()
		local cur = M.cur
		M.cur = nil
		if cur and cur.clip then
			pcall(function()
				cur.clip:Destroy()
			end)
		end
	end

	local function buildMascot(name, asset)
		local def = MASCOTS[name]
		if not def or not M.gui then
			return
		end

		local clip = Instance.new("Frame")
		clip.Name = (name:gsub("%s", "")) .. "Clip"
		clip.BackgroundTransparency = 1
		clip.BorderSizePixel = 0
		clip.ClipsDescendants = def.kind ~= "static"
		clip.ZIndex = 10000
		clip.Visible = false
		clip.Parent = M.gui

		local cur = { def = def, clip = clip, images = {}, idx = 0 }

		if def.kind == "static" then
			local img = Instance.new("ImageLabel")
			img.Name = "MeowImage"
			img.BackgroundTransparency = 1
			img.Size = UDim2.fromScale(1, 1)
			img.ScaleType = Enum.ScaleType.Fit
			img.Image = asset
			img.ZIndex = 10001
			img.Parent = clip
			cur.images[1] = img
		elseif def.kind == "sheet" then
			-- sprite sheet: cols x rows cells, we slide it around inside the clip
			local sheet = Instance.new("ImageLabel")
			sheet.Name = "MeowSheet"
			sheet.BackgroundTransparency = 1
			sheet.Size = UDim2.fromScale(def.cols, def.rows)
			sheet.Image = asset
			sheet.ZIndex = 10001
			sheet.Parent = clip
			cur.images[1] = sheet
			cur.sheet = sheet
		else
			-- strip: one label per frame, each showing one cell of the strip
			for i = 0, def.frames - 1 do
				local img = Instance.new("ImageLabel")
				img.Name = "MeowFrame" .. (i + 1)
				img.BackgroundTransparency = 1
				img.Size = UDim2.fromScale(def.cols, 1)
				img.Position = UDim2.fromScale(-i, 0)
				img.ScaleType = Enum.ScaleType.Stretch
				img.Image = asset
				img.Visible = (i == 0)
				img.ZIndex = 10001
				img.Parent = clip
				cur.images[i + 1] = img
			end
		end

		-- invisible button over the mascot: press = squash, release = spring back (a little bigger first)
		local btn = Instance.new("TextButton")
		btn.Name = "MeowButton"
		btn.BackgroundTransparency = 1
		btn.BorderSizePixel = 0
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.Size = UDim2.fromScale(1, 1)
		btn.ZIndex = 10005
		btn.Parent = clip

		local function isPress(input)
			return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
		end

		btn.InputBegan:Connect(function(input)
			if isPress(input) then
				M.sqGoal = 1
			end
		end)

		btn.InputEnded:Connect(function(input)
			if isPress(input) then
				M.sqGoal = 0
			end
		end)

		btn.MouseLeave:Connect(function()
			M.sqGoal = 0
		end)

		cur.button = btn
		M.acc = 0
		M.cur = cur
	end

	local function applyChoice()
		M.token += 1
		local token = M.token
		clearMascot()

		local name = M.choice
		local def = MASCOTS[name]
		if not def then
			return
		end

		if not canAssets then
			say("Your executor can't load custom images (writefile / getcustomasset).", "x")
			return
		end

		task.spawn(function()
			local url
			if name == "Custom" then
				url = M.customUrl
				if url == "" then
					return
				end
			else
				url = ASSET_BASE .. def.file
			end

			local asset = fetchAsset(url, "meow")
			if token ~= M.token then
				return
			end
			if not asset then
				warn("[Meow] image failed to download:", url)
				say("Could not download the " .. name .. " image.", "x")
				return
			end

			ensureOverlay()
			buildMascot(name, asset)
		end)
	end

	local function step(dt)
		local cur = M.cur
		if not cur then
			return
		end

		local root = getRoot()
		local goal = (root and isShown(root)) and 1 or 0
		M.alpha = M.alpha + (goal - M.alpha) * math.min(1, dt * 12)
		if math.abs(goal - M.alpha) < 0.01 then
			M.alpha = goal
		end

		local clip, def = cur.clip, cur.def
		if not root or M.alpha <= 0 then
			clip.Visible = false
			return
		end

		-- the overlay ignores the top-bar inset; the menu's GUI may not
		local inset = Vector2.zero
		local rootGui = root:FindFirstAncestorOfClass("ScreenGui")
		if rootGui then
			if not rootGui.IgnoreGuiInset then
				inset = GuiService_:GetGuiInset()
			end
			if M.gui and M.gui.DisplayOrder <= rootGui.DisplayOrder then
				M.gui.DisplayOrder = rootGui.DisplayOrder + 1
			end
		end

		local s = M.scale
		local pos = root.AbsolutePosition + inset
		local size = root.AbsoluteSize
		-- squash / release spring (underdamped, so letting go overshoots into a small "expand" before settling)
		M.sqVel = M.sqVel + (M.sqGoal - M.sq) * 260 * dt
		M.sqVel = M.sqVel * math.exp(-14 * dt)
		M.sq = M.sq + M.sqVel * dt
		if math.abs(M.sq - M.sqGoal) < 0.002 and math.abs(M.sqVel) < 0.02 then
			M.sq = M.sqGoal
			M.sqVel = 0
		end

		local baseW, baseH = def.w * s, def.h * s
		local newW, newH

		if M.sq >= 0 then
			-- pressed: wider and flatter
			newW = baseW * (1 + 0.10 * M.sq)
			newH = baseH * (1 - 0.22 * M.sq)
		else
			-- released: pops out bigger than normal before settling
			newW = baseW * (1 - 0.14 * M.sq)
			newH = baseH * (1 - 0.14 * M.sq)
		end

		local baseX = pos.X + size.X - def.dx * s + M.offX
		local baseY = pos.Y - def.dy * s + M.offY

		-- keep the bottom-center of the mascot fixed so it squashes into the menu edge
		clip.Size = UDim2.fromOffset(math.floor(newW), math.floor(newH))
		clip.Position = UDim2.fromOffset(math.floor(baseX + (baseW - newW) / 2), math.floor(baseY + (baseH - newH)))
		clip.Visible = true

		local transparency = 1 - M.alpha
		for _, img in ipairs(cur.images) do
			img.ImageTransparency = transparency
		end

		if def.kind ~= "static" then
			M.acc = M.acc + dt
			if M.acc >= FRAME_INTERVAL then
				M.acc = 0
				cur.idx = (cur.idx + 1) % def.frames
				if def.kind == "sheet" then
					cur.sheet.Position = UDim2.fromScale(-(cur.idx % def.cols), -math.floor(cur.idx / def.cols))
				else
					for i, img in ipairs(cur.images) do
						img.Visible = (i - 1 == cur.idx)
					end
				end
			end
		end
	end

	M.conn = RunService_.RenderStepped:Connect(step)

	-- UI --------------------------------------------------------------------------
	tbl43.settings:Section({ Title = "Meow" })

	tbl43.settings:Dropdown({
		Title = "Meow",
		Flag = "Dropdown_Meow",
		Multi = false,
		Value = "None",
		Desc = "An animated mascot that sits on the corner of the menu window.",
		Values = { "None", "Mimi", "Furry", "Koti", "Protogen Bongo", "Custom" },
		Callback = function(v)
			if type(v) == "table" then
				v = v[1] or v.Value
			end
			v = tostring(v or "None")
			if not MASCOTS[v] then
				v = "None"
			end
			if v == M.choice then
				return
			end
			M.choice = v
			applyChoice()
		end,
	})

	tbl43.settings:Slider({
		Title = "Meow Size",
		Flag = "Slider_Meow_Size",
		Desc = "How big the mascot is.",
		Step = 5,
		Suffix = "%",
		Value = { Min = 50, Max = 200, Default = 100 },
		Callback = function(v)
			local n = tonumber(v) or (type(v) == "table" and tonumber(v.Value)) or 100
			M.scale = math.clamp(n, 50, 200) / 100
		end,
	})

	tbl43.settings:Slider({
		Title = "Meow Left / Right",
		Flag = "Slider_Meow_X",
		Desc = "Nudge the mascot sideways if it is not on the edge of the menu.",
		Step = 5,
		Value = { Min = -400, Max = 400, Default = 0 },
		Callback = function(v)
			M.offX = tonumber(v) or (type(v) == "table" and tonumber(v.Value)) or 0
		end,
	})

	tbl43.settings:Slider({
		Title = "Meow Up / Down",
		Flag = "Slider_Meow_Y",
		Desc = "Nudge the mascot up (minus) or down (plus).",
		Step = 5,
		Value = { Min = -400, Max = 400, Default = 0 },
		Callback = function(v)
			M.offY = tonumber(v) or (type(v) == "table" and tonumber(v.Value)) or 0
		end,
	})

	tbl43.settings:Input({
		Title = "Custom Meow Image",
		Flag = "Input_Meow_Custom_Url",
		Placeholder = "Direct link to a .png / .jpg",
		Default = "",
		Desc = "Used when Meow is set to Custom.",
		Callback = function(v)
			v = tostring(v or ""):gsub("^%s+", ""):gsub("%s+$", "")
			if v == M.customUrl then
				return
			end
			M.customUrl = v
			task.delay(0.8, function()
				if M.customUrl == v and M.choice == "Custom" then
					applyChoice()
				end
			end)
		end,
	})

	obj3:OnDestroy(function()
		M.token += 1
		if M.conn then
			pcall(function()
				M.conn:Disconnect()
			end)
			M.conn = nil
		end
		clearMascot()
		if M.gui then
			pcall(function()
				M.gui:Destroy()
			end)
			M.gui = nil
		end
	end)
end

obj3:OnDestroy(function()
	list2.farewell()
	fvlV2Cleanup()
	local list46 = {}

	pcall(function()
		local hui = gethui and gethui() or CoreGui

		for _, child in ipairs(hui:GetChildren()) do
			if child.Name == "WindUI" or child.Name:match("^WindUI/") then
				list46[#list46 + 1] = child
			end
		end
	end)

	task.delay(0.6, function()
		for _, item67 in ipairs(list46) do
			pcall(function()
				item67:Destroy()
			end)
		end
	end)

	if _G.FVLV2 == obj3 then
		_G.FVLV2 = nil
	end

	if _G.FVLV2Cleanup == fvlV2Cleanup then
		_G.FVLV2Cleanup = nil
	end
end)

_G.FVLV2Cleanup = fvlV2Cleanup
obj3:Open()
list2.pinOpenPill()
obj3:SelectTab(1)

task.spawn(function()
	for i = 1, 60 do
		RunService.RenderStepped:Wait()

		if obj3.CurrentTab ~= 1 then
			obj3:SelectTab(1)
		end
	end
end)

list2.captureHud = function()
	local tbl114 = {}

	-- keep saved positions of anything not currently on screen (toggled off buttons etc.)
	for k, v in next, list2.hudPos, nil do
		if type(v) == "table" and #v == 4 then
			tbl114[k] = v
		end
	end

	for k, value226 in next, list2.hudBtns, nil do
		if value226 and value226.Parent then
			local position = value226.Position
			local pos = { position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset }
			tbl114[k] = pos

			-- extra draggable frames ("__name") are remembered for when they get rebuilt
			if type(k) == "string" and k:sub(1, 2) == "__" then
				list2.hudPos[k] = pos
			end
		end
	end

	return tbl114
end

list2.applyHud = function()
	for k, value227 in next, list2.hudPos, nil do
		local flag204 = list2.hudBtns[k]

		if flag204 and flag204.Parent and type(value227) == "table" and #value227 == 4 then
			flag204.Position = UDim2.new(value227[1], value227[2], value227[3], value227[4])
		end
	end
end

list2.snapshot = function()
	if not list2.config then
		return ""
	end

	local ok, result = pcall(function()
		return HttpService:JSONEncode({ data = list2.config:GetData(), hud = list2.captureHud() })
	end)

	return ok and result or ""
end

list2.saveNow = function()
	if list2.cfgWiped then
		return
	end

	pcall(function()
		if writefile then
			writefile(list2.hudFile, HttpService:JSONEncode(list2.captureHud()))
		end
	end)

	if list2.config then
		pcall(function()
			list2.config:Save()
		end)
	end

	list2.cfgSnapshot = list2.snapshot()
end

task.spawn(function()
	if not list2.config then
		list2.notifyReady = true
		list2.sfxReady = true

		list2.notifyNow({
			Title = "Config",
			Content = "ConfigManager unavailable - settings will not persist.",
			Duration = 5,
			Icon = "x",
		})

		return
	end

	pcall(function()
		return list2.config:Load()
	end)

	list2.applyHud()
	task.wait(1)
	list2.cfgSnapshot = list2.snapshot()
	list2.notifyReady = true
	list2.sfxReady = true

	while _G.FVLV2 == obj3 do
		task.wait(2)

		if not list2.cfgWiped then
			local flag205 = list2.snapshot()

			if flag205 ~= "" and flag205 ~= list2.cfgSnapshot then
				list2.saveNow()
			end
		end
	end
end)


list2.notifyNow({
	Title = "F$VL",
	Content = "Loaded. G toggles the window.",
	Duration = 10,
	Icon = "rbxassetid://103877612231883",
})