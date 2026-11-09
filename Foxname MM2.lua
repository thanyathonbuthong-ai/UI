--[[
    Foxname - Murder Mystery 2
    Maintained and secured by the Foxname Team.
--]]
task.defer(function()
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "Foxname",
			Text = "Script is loading. This may take a few seconds...",
			Icon = "rbxassetid://133245078123989",
			Duration = 5,
		})
	end)
end)

local genv
genv = getgenv and getgenv() or _G

FoxnameCopyToClipboard = function(arg)
	local str = tostring(arg or "")
	local v

	if typeof(setclipboard) == "function" then
		v = setclipboard
	elseif typeof(setrbxclipboard) == "function" then
		v = setrbxclipboard
	else
		v = nil
	end

	if v then
		return (pcall(v, str))
	end
	return false
end

FoxnameKickPlayer = function(arg, arg2)
	if not arg then
		return false
	end

	return (pcall(function()
		local v = arg
		local kick = v.Kick
		local v2 = tostring
		local v3 = arg2
		local str

		if arg2 then
			str = v3
		else
			str = ""
		end

		kick(v, v2(str))
	end))
end

local hookSupported, silentAimSupported, foxnameMM2Runtime, sessionId, isTerminated, WindUI, Window, isOwner
local Tabs, UI_BUILD_DELAY = nil, 0.08

do
	local tbl2 = { Name = "Unknown executor", IsXeno = false, IsDelta = false }

	pcall(function()
		if type(identifyexecutor) == "function" then
			tbl2.Name = tostring(select(1, identifyexecutor()) or tbl2.Name)
		end
	end)

	local v8 = string.lower(tbl2.Name)
	tbl2.IsXeno = v8:find("xeno", 1, true) ~= nil
	tbl2.IsDelta = v8:find("delta", 1, true) ~= nil

	local function fn6()
		if tbl2.IsXeno then
			return false
		end
		return type(hookmetamethod) == "function" and type(getnamecallmethod) == "function" and type(checkcaller) == "function" and type(newcclosure) == "function"
	end

	local v9 = fn6()
	hookSupported = v9
	silentAimSupported = v9
	genv.__FoxnameMM2Runtime = genv.__FoxnameMM2Runtime or { running = false, windui = nil, window = nil, alive = false, sessionId = nil }
	foxnameMM2Runtime = genv.__FoxnameMM2Runtime
	local random = math.random
	sessionId = string.format("%.6f_%d", os.clock(), random(100000, 999999))
	isTerminated = false

	if foxnameMM2Runtime.running and foxnameMM2Runtime.alive then
		local windui = foxnameMM2Runtime.windui

		if windui and type(windui.Notify) == "function" then
			pcall(function()
				windui:Notify({ Title = "Fail", Content = "Script already running!", Icon = "ban", Duration = 2.5 })
			end)
		end

		return
	end

	foxnameMM2Runtime.running = true
	foxnameMM2Runtime.alive = true
	foxnameMM2Runtime.sessionId = sessionId
	local HttpService = game:GetService("HttpService")

	if syn and type(syn.request) == "function" then
		request_ = syn.request
	elseif type(http_request) == "function" then
		request_ = http_request
	elseif type(request) == "function" then
		request_ = request
	end

	local function fn17()
		local str2 = "Unknown executor"

		pcall(function()
			if type(identifyexecutor) == "function" then
				local v10, v11 = identifyexecutor()
				str2 = tostring(v10 or str2)

				if v11 and tostring(v11) ~= "" then
					str2 ..= " " .. tostring(v11)
				end
			end
		end)

		local flag6 = type(request) == "function" or type(http_request) == "function" or type(syn) == "table" and type(syn.request) == "function"
		local websocket_ = type(WebSocket) == "table" and WebSocket
		local flag7 = type(websocket_) == "table"

		if flag7 then
			flag7 = type(websocket_.connect or websocket_.Connect) == "function"
		end

		local flag8 = type(queue_on_teleport) == "function"

		if not flag8 then
			flag8 = type(syn) == "table"

			if flag8 then
				flag8 = type(syn.queue_on_teleport or syn.queueonteleport) == "function"
			end
		end

		local flag9 = type(readfile) == "function" and type(writefile) == "function" and type(makefolder) == "function" and type(isfile) == "function" and type(isfolder) == "function" and type(delfile) == "function"
		local v10 = v9
		local tbl3 = {}

		local tbl4 = {
			name = "HTTP requests",
			ok = flag6,
			features = { "Discord live information", "Compatibility report sending" },
		}

		local tbl5 = {
			name = "WebSocket",
			ok = flag7,
			features = { "Messages", "Owner / same-script user detection", "Owner panel commands" },
		}

		local tbl6 = {
			name = "File storage",
			ok = flag9,
			features = { "Save / load / delete configs", "Auto Load Config", "Mobile button position saving" },
		}

		local tbl7 = { name = "Teleport queue", ok = flag8, features = { "Automatic rejoin and script re-execution" } }

		local tbl8 = {
			name = "Touch simulation",
			ok = type(firetouchinterest) == "function",
			features = { "Coin touch fallback", "Get Gun / Insta Take Gun" },
		}

		local tbl9 = {
			name = "Connection inspection",
			ok = type(getconnections) == "function",
			features = { "Verified game UI button activation" },
		}

		local tbl10 = {
			name = "Metamethod hooks",
			ok = v10,
			features = { "Full in-game emote selector synchronization" },
		}

		local tbl11 = {
			name = "Clipboard",
			ok = type(setclipboard) == "function",
			features = { "Copy Discord invite and report" },
		}

		local tbl12 = {
			name = "Dynamic code loading",
			ok = type(loadstring) == "function",
			features = { "Remote libraries and Anti Fling loading" },
		}

		tbl3[1] = tbl4
		tbl3[2] = tbl5
		tbl3[3] = tbl6
		tbl3[4] = tbl7
		tbl3[5] = tbl8
		tbl3[6] = tbl9
		tbl3[7] = tbl10
		tbl3[8] = tbl11
		tbl3[9] = tbl12

		tbl3[10] = {
			name = "Executor identification",
			ok = str2 ~= "Unknown executor",
			features = { "Executor name detection" },
		}

		local tbl13 = {}
		local tbl14 = {}
		local tbl15 = {}
		local n2 = 0

		for _, v11 in ipairs(tbl3) do
			if v11.ok then
				n2 += 1
			else
				table.insert(tbl14, v11.name)

				for _, feature in ipairs(v11.features) do
					if not tbl15[feature] then
						tbl15[feature] = true
						table.insert(tbl13, feature)
					end
				end
			end
		end

		return {
			executor = str2,
			score = math.floor(n2 / #tbl3 * 100 + 0.5),
			checks = tbl3,
			missing = tbl14,
			unsupported = tbl13,
		}
	end

	local v10 = fn17()

	task.spawn(function()
		local Players = game:GetService("Players")
		local UserInputService = game:GetService("UserInputService")
		local GuiService = game:GetService("GuiService")
		local localPlayer = Players.LocalPlayer
		local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")

		if not playerGui and localPlayer then
			playerGui = localPlayer:WaitForChild("PlayerGui", 2)
		end

		if playerGui then
			local function fn18(arg)
				while arg and arg ~= playerGui do
					if arg:IsA("GuiObject") and not arg.Visible then
						return false
					end

					if arg:IsA("LayerCollector") and not arg.Enabled then
						return false
					end
					arg = arg.Parent
				end

				return arg == playerGui
			end

			local function fn19(arg)
				if not arg or not arg:IsA("GuiButton") or not fn18(arg) then
					return false
				end
				local n2 = arg.AbsolutePosition + arg.AbsoluteSize / 2

				if type(mousemoveabs) == "function" and type(mouse1click) == "function" then
					if pcall(function()
						mousemoveabs(n2.X, n2.Y)
						mouse1click()
					end) then
						return true
					end
				end

				local ok, result = pcall(game.GetService, game, "VirtualInputManager")

				if ok and result then
					return pcall(function()
						result:SendMouseButtonEvent(n2.X, n2.Y, 0, true, game, 0)
						result:SendMouseButtonEvent(n2.X, n2.Y, 0, false, game, 0)
					end)
				end

				return false
			end

			local function fn20(arg)
				if not arg or not arg:IsA("GuiButton") or not fn18(arg) then
					return false
				end

				if type(getconnections) ~= "function" then
					return fn19(arg)
				end
				local ok, result = pcall(getconnections, arg.MouseButton1Click)
				if not ok or type(result) ~= "table" then
					return fn19(arg)
				end

				for _, v11 in ipairs(result) do
					if v11.Enabled ~= false and type(v11.Function) == "function" then
						local function_ = v11.Function

						task.spawn(function()
							local v12 = getthreadidentity or getidentity
							local v13 = setthreadidentity or setidentity
							local v14 = nil

							if type(v12) == "function" then
								pcall(function()
									v14 = v12()
								end)
							end

							if type(v13) == "function" then
								pcall(v13, 2)
							end

							pcall(function_)

							if v14 and type(v13) == "function" then
								pcall(v13, v14)
							end
						end)

						return true
					end
				end

				return fn19(arg)
			end

			local function fn21()
				local currentCamera = workspace.CurrentCamera
				currentCamera = currentCamera and currentCamera.ViewportSize

				if not currentCamera or currentCamera.X <= 0 or currentCamera.Y <= 0 then
					local ok, result = pcall(function()
						return GuiService:GetScreenResolution()
					end)

					if ok then
						currentCamera = result
					end
				end

				if not currentCamera or currentCamera.X <= 0 or currentCamera.Y <= 0 then
					return "Phone"
				end
				local n2 = math.min(currentCamera.X, currentCamera.Y)
				return math.max(currentCamera.X, currentCamera.Y) / math.max(n2, 1) <= 1.7 and "Tablet" or "Phone"
			end

			local now = os.clock()
			local n2 = now + 5
			local n3 = now + 12
			local n4 = 0
			local now2 = nil
			local n5 = 0

			while os.clock() < n3 do
				local deviceSelect = playerGui:FindFirstChild("DeviceSelect")
				local flag6 = deviceSelect and UserInputService.TouchEnabled and n4 < 8
				local flag7 = false

				if flag6 then
					local container = deviceSelect:FindFirstChild("Container")
					local button

					if container then
						local v11 = container
						local findFirstChild = v11.FindFirstChild
						local v12 = fn21()
						button = findFirstChild(v11, v12)
					else
						button = container
					end

					button = button and button:FindFirstChild("Button")

					if fn20(button) then
						n4 += 1
						now2 = os.clock()
						flag7 = true
					end
				end

				local join = playerGui:FindFirstChild("Join") or playerGui:FindFirstChild("JoinPhone")
				join = join and join:FindFirstChild("Friends")
				local play = join and join:FindFirstChild("Play")

				if play and fn18(play) and n5 < 6 then
					if fn20(play) then
						n5 += 1
						now2 = os.clock()
						flag7 = true
					end
				end

				local wait

				if now2 then
					if not (not playerGui:FindFirstChild("DeviceSelect") and not playerGui:FindFirstChild("Join") and not playerGui:FindFirstChild("JoinPhone") and os.clock() - now2 >= 0.6) then
						wait = task.wait
						flag7 = flag7 and 0.35 or 0.15
						wait(flag7)
						continue
					end
				elseif not (os.clock() >= n2) then
					wait = task.wait
					wait(flag7 and 0.35 or 0.15)
					continue
				end

				break
			end

			local n6 = 0

			while foxnameMM2Runtime.alive do
				local deviceSelect = playerGui:FindFirstChild("DeviceSelect")
				deviceSelect = deviceSelect and deviceSelect:FindFirstChild("Container")

				if deviceSelect then
					local findFirstChild = deviceSelect.FindFirstChild
					local v11 = fn21()
					deviceSelect = findFirstChild(deviceSelect, v11)
				end

				deviceSelect = deviceSelect and deviceSelect:FindFirstChild("Button")
				local join = playerGui:FindFirstChild("Join") or playerGui:FindFirstChild("JoinPhone")
				join = join and join:FindFirstChild("Friends")
				join = join and join:FindFirstChild("Play")
				local isGuiButton = deviceSelect and deviceSelect:IsA("GuiButton") and fn18(deviceSelect)
				local isGuiButton2 = join and join:IsA("GuiButton") and fn18(join)

				if not (not isGuiButton and not isGuiButton2) then
					if os.clock() - n6 >= 1 then
						n6 = os.clock()

						if isGuiButton and UserInputService.TouchEnabled then
							fn20(deviceSelect)
						elseif isGuiButton2 then
							fn20(join)
						end
					end

					task.wait(0.2)
					continue
				end

				break
			end
		end
	end)

	local function fn18()
		pcall(function()
			local ReplicatedStorage = game:GetService("ReplicatedStorage")

			if not ReplicatedStorage:FindFirstChild("GetIcons") then
				local remoteFunction = Instance.new("RemoteFunction")
				remoteFunction.Name = "GetIcons"

				remoteFunction.OnClientInvoke = function()
					return { Icons = {} }
				end

				remoteFunction.Parent = ReplicatedStorage
			end
		end)

		local request_2

		if typeof(http_request) == "function" then
			request_2 = http_request
		elseif typeof(request) == "function" then
			request_2 = request
		elseif typeof(syn) == "table" and typeof(syn.request) == "function" then
			request_2 = syn.request
		else
			request_2 = nil
		end

		local urls = {
			"https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
			"https://fastly.jsdelivr.net/gh/Footagesus/WindUI@main/dist/main.lua",
			"https://cdn.jsdelivr.net/gh/Footagesus/WindUI@main/dist/main.lua",
			"https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
		}

		local cachePath = "Foxname/WindUI_cache.lua"
		local function tryReadCache()
			if typeof(isfile) == "function" and typeof(readfile) == "function" then
				local ok, content = pcall(readfile, cachePath)
				if ok and typeof(content) == "string" and #content > 400 then
					return content
				end
				local ok2, content2 = pcall(readfile, "WindUI.lua")
				if ok2 and typeof(content2) == "string" and #content2 > 400 then
					return content2
				end
			end
			return nil
		end

		local function tryWriteCache(src)
			if typeof(writefile) == "function" and typeof(src) == "string" and #src > 400 then
				pcall(function()
					if typeof(isfolder) == "function" and typeof(makefolder) == "function" and not isfolder("Foxname") then
						makefolder("Foxname")
					end
					writefile(cachePath, src)
				end)
			end
		end

		local function compileSource(src)
			if typeof(src) ~= "string" or #src < 400 then
				return nil
			end
			local str2 = src:gsub("WaitForChild%(\"GetIcons\",%s*%d+%)", "FindFirstChild(\"GetIcons\")"):gsub("local d=b%(game:GetService\"ReplicatedStorage\":WaitForChild%(\"GetIcons\",99999%):InvokeServer%(%)%)", "local d={Icons={}}")
			str2 = str2:gsub("d=ak%.AddSignal%(ar%.UIElements%.ContainerFrame%.ChildAdded,%s*function%(%)%s*b%.Visible=false%s*d:Disconnect%(%)%s*end%)", "d=ak.AddSignal(ar.UIElements.ContainerFrame.ChildAdded,function(c) if c~=b and c.ClassName~='UIListLayout' and c.ClassName~='UIPadding' then b.Visible=false b.Size=UDim2.new(1,0,0,0) if d then d:Disconnect() end end end)\nif #ar.Elements>0 or #ar.UIElements.ContainerFrame:GetChildren()>3 then b.Visible=false b.Size=UDim2.new(1,0,0,0) end")
			local chunk, err = loadstring(str2)
			if chunk then
				return chunk
			end
			return nil
		end

		local chunk = nil

		for _, url in ipairs(urls) do
			for attempt = 1, 2 do
				local body = nil
				if request_2 then
					local ok, res = pcall(request_2, {
						Url = url,
						Method = "GET",
						Headers = { ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" },
					})
					if ok and typeof(res) == "table" and (res.Body or res.body) then
						local b = res.Body or res.body
						if typeof(b) == "string" and #b > 400 then
							body = b
						end
					end
				end

				if not body then
					local ok, res = pcall(function()
						return game:HttpGet(url)
					end)
					if ok and typeof(res) == "string" and #res > 400 then
						body = res
					end
				end

				if body then
					chunk = compileSource(body)
					if chunk then
						tryWriteCache(body)
						break
					end
				end

				if attempt < 2 then
					task.wait(0.15)
				end
			end
			if chunk then
				break
			end
		end

		if not chunk then
			local cached = tryReadCache()
			if cached then
				chunk = compileSource(cached)
			end
		end

		if not chunk then
			error("WindUI source could not be downloaded")
		end

		return chunk()
	end

	WindUI = fn18()
	foxnameMM2Runtime.windui = WindUI

	WindUI:AddTheme({
		Name = "Lunar Abyss",
		Accent = WindUI:Gradient({
			["0"] = { Color = Color3.fromHex("#0D0D1A"), Transparency = 0 },
			["50"] = { Color = Color3.fromHex("#1A1A33"), Transparency = 0 },
			["100"] = { Color = Color3.fromHex("#2E2E5C"), Transparency = 0 },
		}, { Rotation = 90 }),
		Dialog = WindUI:Gradient({
			["0"] = { Color = Color3.fromHex("#101026"), Transparency = 0 },
			["50"] = { Color = Color3.fromHex("#1A1A3D"), Transparency = 0 },
			["100"] = { Color = Color3.fromHex("#333366"), Transparency = 0 },
		}, { Rotation = 90 }),
		Outline = WindUI:Gradient({
			["0"] = { Color = Color3.fromHex("#2E2E5C"), Transparency = 0 },
			["50"] = { Color = Color3.fromHex("#404080"), Transparency = 0 },
			["100"] = { Color = Color3.fromHex("#5050A0"), Transparency = 0 },
		}, { Rotation = 90 }),
		Text = WindUI:Gradient({
			["0"] = { Color = Color3.fromHex("#A0A0FF"), Transparency = 0 },
			["50"] = { Color = Color3.fromHex("#C0C0FF"), Transparency = 0 },
			["100"] = { Color = Color3.fromHex("#E0E0FF"), Transparency = 0 },
		}, { Rotation = 90 }),
		Placeholder = WindUI:Gradient({
			["0"] = { Color = Color3.fromHex("#6060A0"), Transparency = 0 },
			["50"] = { Color = Color3.fromHex("#8080C0"), Transparency = 0 },
			["100"] = { Color = Color3.fromHex("#A0A0E0"), Transparency = 0 },
		}, { Rotation = 90 }),
		Background = WindUI:Gradient({
			["0"] = { Color = Color3.fromHex("#0A0A1A"), Transparency = 0 },
			["50"] = { Color = Color3.fromHex("#1A1A33"), Transparency = 0 },
			["100"] = { Color = Color3.fromHex("#2E2E5C"), Transparency = 0 },
		}, { Rotation = 90 }),
		Button = WindUI:Gradient({
			["0"] = { Color = Color3.fromHex("#404080"), Transparency = 0 },
			["50"] = { Color = Color3.fromHex("#5050A0"), Transparency = 0 },
			["100"] = { Color = Color3.fromHex("#6060C0"), Transparency = 0 },
		}, { Rotation = 90 }),
		Icon = WindUI:Gradient({
			["0"] = { Color = Color3.fromHex("#6060C0"), Transparency = 0 },
			["50"] = { Color = Color3.fromHex("#8080E0"), Transparency = 0 },
			["100"] = { Color = Color3.fromHex("#A0A0FF"), Transparency = 0 },
		}, { Rotation = 90 }),
	})

	local function fn19(arg, arg2, arg3)
		local n2 = #arg
		if n2 <= 1 then
			return string.format("<font color=\"rgb(%d,%d,%d)\">%s</font>", math.floor(arg2.R * 255), math.floor(arg2.G * 255), math.floor(arg2.B * 255), arg)
		end
		local n3 = n2 - 1
		local str2 = ""

		for i = 1, n2 do
			local n4 = (i - 1) / n3
			str2 ..= string.format("<font color=\"rgb(%d,%d,%d)\">%s</font>", math.floor(arg2.R * 255 + (arg3.R * 255 - arg2.R * 255) * n4), math.floor(arg2.G * 255 + (arg3.G * 255 - arg2.G * 255) * n4), math.floor(arg2.B * 255 + (arg3.B * 255 - arg2.B * 255) * n4), arg:sub(i, i))
		end

		return str2
	end

	WindUI:Popup({
		Title = "Before we start",
		Icon = "circle-alert",
		Content = "Would you like to join our Discord server? I believe you'll have a lot of fun!",
		Buttons = {
			{
				Title = "Yeah sure",
				Icon = "arrow-right",
				Variant = "Primary",
				Callback = function()
					FoxnameCopyToClipboard("https://discord.gg/v8ZPq4y2nD")

					WindUI:Notify({
						Title = "Success",
						Content = "Discord invite link copied to your clipboard paste it on your browser",
						Duration = 2.5,
					})
				end,
			},
			{
				Title = "No fuck off",
				Icon = "x",
				Variant = "Secondary",
				Callback = function()
				end,
			},
		},
	})

	local color = Color3.fromRGB
	local color2 = Color3.fromHex

	Window = WindUI:CreateWindow({
		Title = fn19("Foxname - Murder Mystery 2", Color3.fromRGB(255, 64, 96), color(255, 186, 220)),
		Author = "discord.gg/v8ZPq4y2nD",
		Theme = "Rose",
		Size = UDim2.fromOffset(520, 420),
		Folder = "Foxname_MM2",
		SideBarWidth = 200,
		Enabled = true,
		Draggable = true,
		OnlyMobile = false,
		ScrollBarEnabled = true,
		Icon = "rbxassetid://133245078123989",
		Background = "rbxassetid://82503368188240",
		BackgroundImageTransparency = 0.6,
		User = { Enabled = true, Anonymous = false },
		OpenButton = {
			Title = "Open Menu",
			CornerRadius = UDim.new(1, 0),
			StrokeThickness = 2,
			Enabled = true,
			Draggable = true,
			OnlyMobile = false,
			Color = ColorSequence.new(Color3.fromHex("#ff0000"), Color3.fromHex("#b50000"), color2("#ff2929")),
		},
	})

	foxnameMM2Runtime.window = Window

	Window:Tag({ Title = "Release", Icon = "rocket", Color = Color3.fromRGB(255, 13, 49) })
	isOwner = false

	local function fn20()
		local dummyTab = setmetatable({}, {
			__index = function(self, k)
				return function()
					return self
				end
			end,
		})
		local v11 = dummyTab
		local v12 = dummyTab

		local v13 = Window:Section({
			Title = "Info",
			Opened = true,
			Icon = "info",
			Box = true,
			BoxBorder = true,
			IconColor = Color3.fromRGB(120, 190, 255),
		})
		task.wait(UI_BUILD_DELAY)

		local discordTab = v13:Tab({ Title = "Discord", Icon = "messages-square" })
		task.wait(UI_BUILD_DELAY)
		local compatTab = v13:Tab({ Title = "UNC / sUNC", Icon = "badge-check" })
		task.wait(UI_BUILD_DELAY)
		local visualsTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
		task.wait(UI_BUILD_DELAY)
		local crosshairTab = Window:Tab({ Title = "Crosshair", Icon = "crosshair" })
		task.wait(UI_BUILD_DELAY)
		local combatTab = Window:Tab({ Title = "Combat", Icon = "crosshair" })
		task.wait(UI_BUILD_DELAY)
		local miscTab = Window:Tab({ Title = "Misc", Icon = "wrench" })
		task.wait(UI_BUILD_DELAY)
		local movementTab = Window:Tab({ Title = "Player", Icon = "user" })
		task.wait(UI_BUILD_DELAY)
		local farmTab = Window:Tab({ Title = "Farm", Icon = "coins" })
		task.wait(UI_BUILD_DELAY)
		local animsTab = Window:Tab({ Title = "Anims", Icon = "play" })
		task.wait(UI_BUILD_DELAY)
		local radioTab = Window:Tab({ Title = "Radio", Icon = "radio" })
		task.wait(UI_BUILD_DELAY)
		local teleportsTab = Window:Tab({ Title = "Teleports", Icon = "navigation" })
		task.wait(UI_BUILD_DELAY)
		local settingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })
		task.wait(UI_BUILD_DELAY)

		local tbl3 = {
			Messages = v11,
			Panel = v12,
			Discord = discordTab,
			Compatibility = compatTab,
			Donate = donateTab,
			Visuals = visualsTab,
			Crosshair = crosshairTab,
			Combat = combatTab,
			Misc = miscTab,
			Movement = movementTab,
			Farm = farmTab,
			Anims = animsTab,
			Radio = radioTab,
			Teleports = teleportsTab,
			Settings = settingsTab,
		}

		tbl3.ESP = tbl3.Visuals
		tbl3.LocalPlayer = tbl3.Movement
		tbl3.Aim = tbl3.Combat
		tbl3.Player = tbl3.Movement

		local function fixEmptyTab(tab)
			if not tab or typeof(tab) ~= "table" or typeof(tab.UIElements) ~= "table" then
				return
			end
			local container = tab.UIElements.ContainerFrame
			if not container or typeof(container) ~= "Instance" or not container:IsA("ScrollingFrame") then
				return
			end

			local function checkAndHide()
				local hasElements = (tab.Elements and #tab.Elements > 0)
				for _, child in ipairs(container:GetChildren()) do
					if child:IsA("GuiObject") and child.ClassName ~= "UIListLayout" and child.ClassName ~= "UIPadding" then
						local tl = child:FindFirstChildWhichIsA("TextLabel", true)
						local isPlaceholder = tl and string.find(string.lower(tl.Text), "empty")
						if not isPlaceholder then
							hasElements = true
							break
						end
					end
				end

				if hasElements then
					for _, child in ipairs(container:GetChildren()) do
						if child:IsA("Frame") then
							local tl = child:FindFirstChildWhichIsA("TextLabel", true)
							if tl and string.find(string.lower(tl.Text), "empty") then
								child.Visible = false
								child.Size = UDim2.new(1, 0, 0, 0)
							end
						end
					end
				end
			end

			checkAndHide()
			container.ChildAdded:Connect(function()
				task.defer(checkAndHide)
			end)
		end

		for _, tab in pairs(tbl3) do
			fixEmptyTab(tab)
		end

		task.defer(function()
			local mainBar = Window and typeof(Window.UIElements) == "table" and Window.UIElements.MainBar
			if mainBar and typeof(mainBar) == "Instance" then
				mainBar.DescendantAdded:Connect(function(descendant)
					if descendant:IsA("TextLabel") and string.find(string.lower(descendant.Text), "empty") then
						local parentFrame = descendant.Parent
						if parentFrame and parentFrame:IsA("Frame") and parentFrame.Parent and parentFrame.Parent:IsA("ScrollingFrame") then
							local scroller = parentFrame.Parent
							local hasContent = false
							for _, c in ipairs(scroller:GetChildren()) do
								if c ~= parentFrame and c:IsA("GuiObject") and c.ClassName ~= "UIListLayout" and c.ClassName ~= "UIPadding" then
									hasContent = true
									break
								end
							end
							if hasContent then
								parentFrame.Visible = false
								parentFrame.Size = UDim2.new(1, 0, 0, 0)
							end
						end
					end
				end)
			end
		end)

		return tbl3
	end

	Tabs = fn20()
	game:GetService("RunService").Heartbeat:Wait()

	local HttpService2 = game:GetService("HttpService")
	local str2 = "v8ZPq4y2nD"
	local str3 = "https://discord.gg/" .. str2
	local str4 = "https://discord.com/api/v10/invites/" .. str2 .. "?with_counts=true&with_expiration=true"

	local v11 = Tabs.Discord:Paragraph({
		Title = "Foxname Community",
		Desc = "Loading Discord information...",
		Image = "messages-square",
		ImageSize = 42,
	})

	local function fn22(arg)
		return FoxnameCopyToClipboard(arg)
	end

	local function fn23()
		local ok, result = pcall(function()
			return HttpService2:JSONDecode(game:HttpGet(str4))
		end)

		if ok and type(result) == "table" and type(result.guild) == "table" then
			return result
		end
		return nil
	end

	local function fn24(arg, arg2)
		if arg then
			local guild = arg.guild
			local flag6 = type(guild.icon) == "string"

			if flag6 then
				local str5 = "/" .. guild.icon .. ".png?size=1024"
				flag6 = "https://cdn.discordapp.com/icons/" .. tostring(guild.id) .. str5
			end

			local str5 = flag6 or "messages-square"

			pcall(function()
				v11:SetTitle(tostring(guild.name or "Foxname Community"))
				v11:SetDesc("<font color=\"#22C55E\"><b>LIVE</b></font>  Foxname community server" .. "\nMembers: " .. tostring(arg.approximate_member_count or "?") .. "  |  Online: " .. tostring(arg.approximate_presence_count or "?") .. "\n<font color=\"#94A3B8\">discord.gg/" .. str2 .. "</font>")
				v11:SetImage(str5, 42)
			end)

			if arg2 then
				WindUI:Notify({
					Title = "Discord",
					Content = "Community information updated",
					Icon = "refresh-cw",
					Duration = 2,
				})
			end

			return true
		end

		pcall(function()
			v11:SetTitle("Foxname Community")
			v11:SetDesc("Live Discord information is unavailable.\n" .. str3)
			v11:SetImage("wifi-off", 34)
		end)

		if arg2 then
			WindUI:Notify({
				Title = "Discord",
				Content = "Could not refresh Discord information",
				Icon = "triangle-alert",
				Duration = 2,
			})
		end

		return false
	end

	local function fn25(arg)
		task.spawn(function()
			fn24(fn23(), arg)
		end)
	end

	Tabs.Discord:Button({
		Title = "Copy Discord Invite",
		Icon = "copy",
		Callback = function()
			if fn22(str3) then
				WindUI:Notify({ Title = "Discord", Content = "Invite copied to clipboard", Icon = "check", Duration = 2 })
			else
				WindUI:Notify({ Title = "Discord", Content = str3, Icon = "link", Duration = 4 })
			end
		end,
	})

	task.wait(UI_BUILD_DELAY)

	Tabs.Discord:Button({
		Title = "Refresh Discord Info",
		Icon = "refresh-cw",
		Callback = function()
			fn25(true)
		end,
	})

	local str5 = tostring(genv.FOXNAME_COMPATIBILITY_REPORT_ENDPOINT or "")
	local tbl3 = {}

	for _, check in ipairs(v10.checks) do
		table.insert(tbl3, (check.ok and "[PASS] " or "[FAIL] ") .. check.name)
	end

	Tabs.Compatibility:Paragraph({
		Title = "Executor: " .. v10.executor,
		Desc = "Compatibility: " .. tostring(v10.score) .. "%\n" .. table.concat(tbl3, "\n"),
		Image = v10.score == 100 and "badge-check" or "triangle-alert",
		ImageSize = 38,
	})

	task.wait(UI_BUILD_DELAY)

	Tabs.Compatibility:Paragraph({
		Title = "Feature Support",
		Desc = #v10.unsupported == 0 and "No unsupported script features were detected." or "These features may not work:\n- " .. table.concat(v10.unsupported, "\n- "),
		Image = #v10.unsupported == 0 and "circle-check" or "list-x",
		ImageSize = 34,
	})

	local function foxnameSendCompatibilityReport(arg, arg2)
		if v10.score >= 100 and not arg2 then
			return true
		end
		local request_2 = type(request) == "function" and request or type(http_request) == "function" and http_request or type(syn) == "table" and type(syn.request) == "function" and syn.request
		if type(request_2) ~= "function" then
			return false
		end
		local tbl4 = {}
		local embeds = {}

		local tbl5 = {
			title = arg2 and "Anonymous MM2 Compatibility Test" or "Anonymous MM2 Compatibility Report",
			description = arg2 and "This report was manually triggered by the script owner." or "An executor compatibility problem was detected during startup.",
			color = 16753920,
		}

		local fields = {}
		local tbl6 = { name = "Executor", value = "`" .. v10.executor .. "`", inline = true }
		local tbl7 = { name = "Compatibility", value = "`" .. tostring(v10.score) .. "%`", inline = true }

		local tbl8 = {
			name = "Missing APIs",
			value = #v10.missing > 0 and table.concat(v10.missing, "\n") or "None",
			inline = false,
		}

		local tbl9 = {
			name = "Affected features",
			value = #v10.unsupported > 0 and table.concat(v10.unsupported, "\n") or "None",
			inline = false,
		}

		fields[1] = tbl6
		fields[2] = tbl7
		fields[3] = tbl8
		fields[4] = tbl9
		tbl5.fields = fields
		embeds[1] = tbl5
		tbl4.embeds = embeds

		local ok, result = pcall(request_2, {
			Url = str5,
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body = HttpService2:JSONEncode(tbl4),
		})

		local flag6 = ok and type(result) == "table"

		if flag6 then
			flag6 = tonumber(result.StatusCode or result.Status or result.status_code)
		end

		flag6 = flag6 or nil
		ok = ok and (flag6 == nil or flag6 >= 200 and flag6 < 300)

		if arg then
			WindUI:Notify({
				Title = "Compatibility",
				Content = ok and "Anonymous compatibility report sent" or "Compatibility report could not be sent",
				Icon = ok and "check" or "x",
				Duration = 3,
			})
		end

		return ok
	end

	genv.__FoxnameSendCompatibilityReport = foxnameSendCompatibilityReport

	task.defer(function()
		WindUI:Notify({
			Title = "Compatibility Test",
			Content = tostring(v10.score) .. "% compatible (open the UNC / sUNC tab for more information)",
			Icon = v10.score == 100 and "badge-check" or "triangle-alert",
			Duration = 5,
		})

		if v10.score < 100 then
			task.spawn(foxnameSendCompatibilityReport, false)
		end

		task.spawn(function()
			local v12 = nil

			for i = 1, 8 do
				v12 = fn23()
				if not v12 then
					task.wait(1.5)
					continue
				end
				break
			end

			fn24(v12, false)
		end)
	end)

	-- script user communication and panel removed
end

local tbl2
tbl2 = { General = Tabs.Misc, Murderer = Tabs.Combat, Sheriff = Tabs.Combat, Farm = Tabs.Farm }

pcall(function()
	Tabs.ESP:Select()
end)

local Players
Players = game:GetService("Players")
local RunService
RunService = game:GetService("RunService")
local TweenService
TweenService = game:GetService("TweenService")
local ReplicatedStorage
ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting
Lighting = game:GetService("Lighting")
local StarterGui
StarterGui = game:GetService("StarterGui")
local currentCamera
currentCamera = workspace.CurrentCamera
local UserInputService
UserInputService = game:GetService("UserInputService")
local TeleportService
TeleportService = game:GetService("TeleportService")
local GuiService
GuiService = game:GetService("GuiService")
local HttpService
HttpService = game:GetService("HttpService")
local localPlayer
localPlayer = Players.LocalPlayer
local flag6
flag6 = false


local fn6

fn6 = function(arg)
	return false
end

local fn7

fn7 = function(arg)
end

local fn8

fn8 = function(arg)
end

local fn9

fn9 = function(arg)
	return false
end

local localChar
localChar = { character = localPlayer.Character }
localChar.humanoid = localChar.character and localChar.character:FindFirstChildOfClass("Humanoid")
localChar.rootPart = localChar.character and localChar.character:FindFirstChild("HumanoidRootPart")
local cleanupDeadConns, trackConn
local trackedConnections = {}

cleanupDeadConns = function()
	for i = #trackedConnections, 1, -1 do
		local v8 = trackedConnections[i]

		if not v8 or v8.Connected == false then
			table.remove(trackedConnections, i)
		end
	end
end

trackConn = function(arg)
	if arg then
		if #trackedConnections >= 64 then
			cleanupDeadConns()
		end

		table.insert(trackedConnections, arg)
	end

	return arg
end

local Hub

Hub = {
	PlayerESP = false,
	PlayerESPStyle = "Filled",
	LineESP = false,
	NametagESP = false,
	GunESP = false,
	CoinESP = false,
	BulletTracer = {
		enabled = false,
		color = Color3.fromRGB(255, 55, 75),
		thickness = 0.35,
		duration = 1,
		folder = nil,
		shotCooldown = 3,
		lastDrawAt = 0,
	},
	ESP360 = false,
	DroppedGunNotify = false,
	ESPTable = {},
	ESPPlayerConnections = {},
	GunESPTable = {},
	CoinESPTable = {},
	CoinESPAddedConnection = nil,
	CoinESPRemovingConnection = nil,
	CoinESPMap = nil,
	CoinESPContainer = nil,
	CoinESPGeneration = 0,
	AimEnabled = false,
	AimlockPart = "Head",
	AimPrediction = true,
	AimPredictionStrength = 5,
	PredictionStrength = 5,
	AimStyle = "Aimlock",
	AimSticky = true,
	OnlyAimWhileSheriff = false,
	IgnoreWalls = false,
	HideFOV = false,
	FOV = 150,
	FlyEnabled = false,
	FlySpeed = 50,
	WalkSpeed = 16,
}

local cameraFov = workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView
Hub.PlayerFOV = math.clamp(type(cameraFov) == "number" and cameraFov or 70, 40, 120)
Hub.NoclipEnabled = false
Hub.JumpPower = 50
Hub.InfiniteJumpEnabled = false
Hub.SpeedGlitchEnabled = false
Hub.SpeedGlitchPower = 2
Hub.JumpConnection = nil
Hub.StartFly = nil
Hub.StopFly = nil
Hub.ToggleInfiniteJump = nil
Hub.SetupInfiniteJump = nil
Hub.CleanupSelector = nil
Hub.CleanupRadio = nil
Hub.ToggleAutoShoot = nil
Hub.ToggleThrowKnifeButton = nil
Hub.UpdateAutoShoot = nil
Hub.TriggerAutoShootInput = nil
Hub.TriggerThrowKnifeInput = nil
Hub.UpdateAimBinding = nil
Hub.AutoShootTouchGui = nil
Hub.AutoShootTouchButton = nil

Hub.AutoShootState = {
	enabled = false,
	mode = "Normal",
	part = "Head",
	cooldown = 0.5,
	tapWindow = 2.25,
	retryInterval = 0.1,
	inputCooldown = 0.18,
	inputBusy = false,
	inputGeneration = 0,
	nextInputAt = 0,
	offset = 2.8,
	lastShotAt = 0,
}

Hub.AutoShootDragState = {
	enabled = false,
	size = "Medium",
	shape = "Square",
	backgroundColor = Color3.fromRGB(18, 18, 18),
	outlineColor = Color3.fromRGB(174, 92, 255),
	textColor = Color3.fromRGB(240, 236, 247),
	position = UDim2.new(0.84, 0, 0.62, 0),
	draggable = false,
	gui = nil,
	button = nil,
	beginConn = nil,
	inputConn = nil,
	globalConn = nil,
	endConn = nil,
	input = nil,
	start = nil,
	startPos = nil,
	dragging = false,
}

Hub.AutoGunTouchEnabled = false
Hub.AutoGunTouchSources = { misc = false }
Hub.AutoGunTouchPending = {}
Hub.SetAutoGunTouchSource = nil
Hub.AutoGunTouchControl = nil
Hub.AutoGunTouchBeforeCoinFarm = false
Hub.AutoGunTouchForcedByCoinFarm = false
Hub.SetCoinFarmAutoGunTouch = nil
Hub.TakeDroppedGunOnce = nil

Hub.GetGunButtonState = {
	enabled = false,
	size = "Medium",
	shape = "Square",
	position = UDim2.new(0.84, 0, 0.71, 0),
	draggable = false,
	gui = nil,
	button = nil,
	beginConn = nil,
	inputConn = nil,
	globalConn = nil,
	endConn = nil,
	input = nil,
	start = nil,
	startPos = nil,
	dragging = false,
}

Hub.BombJump = { busy = false, nextReadyAt = 0, cooldown = 22 }

Hub.BombJumpButtonState = {
	enabled = false,
	size = "Medium",
	shape = "Square",
	position = UDim2.new(0.84, 0, 0.8, 0),
	draggable = false,
	gui = nil,
	button = nil,
	beginConn = nil,
	inputConn = nil,
	globalConn = nil,
	endConn = nil,
	input = nil,
	start = nil,
	startPos = nil,
	dragging = false,
}

Hub.QuickMenuState = {
	enabled = false,
	open = false,
	position = UDim2.new(0.91, 0, 0.5, 0),
	gui = nil,
	button = nil,
	actions = {},
	connections = {},
	dragging = false,
	dragInput = nil,
	dragStart = nil,
	dragStartPosition = nil,
	dragMoved = false,
}

Hub.RunBombJump = nil
Hub.AntiFlingEnabled = false
Hub.AntiFlingSources = { manual = false }
Hub.SetAntiFlingSource = nil
Hub.SetCoinFarmAntiFling = nil

Hub.ThrowKnifeButtonState = {
	enabled = false,
	mode = "Normal",
	size = "Medium",
	shape = "Square",
	backgroundColor = Color3.fromRGB(112, 35, 185),
	outlineColor = Color3.fromRGB(195, 130, 255),
	textColor = Color3.fromRGB(255, 255, 255),
	position = UDim2.new(0.84, 0, 0.53, 0),
	draggable = false,
	gui = nil,
	button = nil,
	beginConn = nil,
	inputConn = nil,
	globalConn = nil,
	endConn = nil,
	inputCooldown = 0.4,
	inputBusy = false,
	nextInputAt = 0,
	input = nil,
	start = nil,
	startPos = nil,
	dragging = false,
}

Hub.RoleState = { cache = {}, lastGunDropPicker = nil, lastGunDropAt = 0, gunDropPickerTtl = 2.5 }

Hub.RoundState = {
	active = false,
	coinsReady = false,
	initialized = false,
	startedAt = 0,
	currentMapName = nil,
	currentMapInstance = nil,
	mapReceivedAt = 0,
}

Hub.Crosshair = {
	enabled = false,
	style = "star",
	mode = "Shiftlock / First Person",
	size = 30,
	speed = 360,
	frameInterval = UserInputService.TouchEnabled and 0.033333333333333333 or 0.016666666666666666,
	rgb = false,
	color = Color3.fromRGB(255, 255, 255),
	root = nil,
	parts = {},
	connection = nil,
	angle = 0,
	lastUpdate = 0,
	cursorHidden = false,
	suppressCursor = false,
	cursorConnection = nil,
	originalMouseIconEnabled = nil,
	userGameSettings = (typeof(UserSettings) == "function" and pcall(UserSettings)) and UserSettings():GetService("UserGameSettings") or nil,
	iconModule = nil,
	iconLoading = false,
	icons = {
		star = "rbxassetid://136141469398409",
		heart = "rbxassetid://116559368303288",
		["circle-plus"] = "rbxassetid://113157136350384",
		crosshair = "rbxassetid://134242818164054",
	},
}

Hub.Spinbot = { enabled = false, speed = 1, connection = nil, humanoid = nil, originalAutoRotate = nil }

Hub.HitboxExpander = {
	enabled = false,
	size = 6,
	visible = false,
	originals = {},
	playerConnections = {},
	partConnections = {},
	localPlayerConnection = nil,
	localCharacterConnection = nil,
	localToolConnections = {},
	stabGeneration = 0,
	stabActive = false,
}

Hub.NoclipParts = {}
Hub.NoclipConn = nil
Hub.NoclipStepConn = nil
Hub.NoclipNextRefresh = 0
Hub.FlingActive = false
Hub.FlingAllRunning = false
Hub.SelectedFlingName = nil
Hub.FlingOldPos = nil
Hub.SafezonePart = nil
Hub.XRayEnabled = false
Hub.XRayOriginal = {}
Hub.XRayConn = nil
Hub.XRayRemoveConn = nil
Hub.XRayRefreshConn = nil
Hub.XRayScanGeneration = 0
Hub.XRayMap = nil

Hub.XRayButtonState = {
	enabled = false,
	size = "Medium",
	shape = "Square",
	position = UDim2.new(0.84, 0, 0.35, 0),
	draggable = false,
	gui = nil,
	button = nil,
	beginConn = nil,
	inputConn = nil,
	globalConn = nil,
	endConn = nil,
	input = nil,
	start = nil,
	startPos = nil,
	dragging = false,
}

Hub.WallPhaseButtonState = {
	enabled = false,
	size = "Medium",
	shape = "Square",
	backgroundColor = Color3.fromRGB(27, 24, 34),
	outlineColor = Color3.fromRGB(174, 92, 255),
	textColor = Color3.fromRGB(255, 255, 255),
	position = UDim2.new(0.84, 0, 0.26, 0),
	draggable = false,
	gui = nil,
	button = nil,
	beginConn = nil,
	inputConn = nil,
	globalConn = nil,
	endConn = nil,
	input = nil,
	start = nil,
	startPos = nil,
	dragging = false,
}

Hub.FlyButtonState = {
	enabled = false,
	size = "Medium",
	shape = "Square",
	position = UDim2.new(0.66, 0, 0.71, 0),
	draggable = false,
	gui = nil,
	button = nil,
	beginConn = nil,
	inputConn = nil,
	globalConn = nil,
	endConn = nil,
	input = nil,
	start = nil,
	startPos = nil,
	dragging = false,
}

Hub.NoclipButtonState = {
	enabled = false,
	size = "Medium",
	shape = "Square",
	position = UDim2.new(0.66, 0, 0.8, 0),
	draggable = false,
	gui = nil,
	button = nil,
	beginConn = nil,
	inputConn = nil,
	globalConn = nil,
	endConn = nil,
	input = nil,
	start = nil,
	startPos = nil,
	dragging = false,
}

Hub.AimlockButtonState = {
	enabled = false,
	size = "Medium",
	shape = "Square",
	position = UDim2.new(0.84, 0, 0.44, 0),
	draggable = false,
	gui = nil,
	button = nil,
	beginConn = nil,
	inputConn = nil,
	globalConn = nil,
	endConn = nil,
	input = nil,
	start = nil,
	startPos = nil,
	dragging = false,
}

Hub.InvisibilityEnabled = false
Hub.InvisibilityTransparency = 0.75
Hub.InvisibilitySeatName = "invischair"
Hub.InvisibilitySeatTeleportPosition = Vector3.new(-25.95, 400, 3537.55)
Hub.InvisibilityDescAddedConn = nil
Hub.InvisibilityRefreshConn = nil
Hub.WalkSpeedConn = nil

Hub.TouchButtons = {
	XRayToggleControl = nil,
	XRayKeybindControl = nil,
	AimToggleControl = nil,
	FlyToggleControl = nil,
	NoclipToggleControl = nil,
	AutoShootToggleControl = nil,
	ThrowKnifeToggleControl = nil,
	Theme = {
		backgroundColor = Color3.fromRGB(27, 24, 34),
		accentColor = Color3.fromRGB(174, 92, 255),
		textColor = Color3.fromRGB(240, 236, 247),
	},
	iconModule = nil,
	iconLoading = false,
	iconCache = {},
	remoteIconCache = {},
	remoteIconLoading = {},
	remoteIconFailed = {},
	iconFallback = {
		default = "rbxassetid://130359823580534",
		eye = "rbxassetid://100033680381365",
		target = "rbxassetid://87563802520297",
		hand = "rbxassetid://130703864968637",
		bomb = "rbxassetid://139223800924636",
		["brick-wall"] = "rbxassetid://112878522258821",
		slice = "rbxassetid://95810504278179",
		crosshair = "rbxassetid://134242818164054",
		send = "rbxassetid://97136202386756",
		circle = "rbxassetid://130359823580534",
	},
	Icons = {
		XRay = "eye",
		Aimlock = "target",
		["Get Gun"] = "hand",
		["Bomb Jump"] = "bomb",
		["Wall Glitch"] = "brick-wall",
		["Throw Knife"] = "slice",
		Shoot = "crosshair",
		["Auto Shoot"] = "crosshair",
		AutoShoot = "crosshair",
		Fly = "rocket",
		Noclip = "grid-3x3",
	},
	RemoteIcons = {
		XRay = "xray.png",
		Aimlock = "aimlock.png",
		["Get Gun"] = "get-gun.png",
		["Bomb Jump"] = "bomb-jump.png",
		["Wall Glitch"] = "wall-glitch.png",
		["Throw Knife"] = "throw-knife.png",
		Shoot = "shoot.png",
		["Auto Shoot"] = "shoot.png",
		AutoShoot = "shoot.png",
		Fly = "fly.png",
		Noclip = "noclip.png",
	},
	Sizes = {
		Small = { size = UDim2.fromOffset(135, 52), textSize = 21 },
		Medium = { size = UDim2.fromOffset(170, 70), textSize = 28 },
		Large = { size = UDim2.fromOffset(210, 86), textSize = 32 },
	},
}

Hub.AutoPrestige = {
	enabled = false,
	waitingForServer = false,
	requestedPrestige = nil,
	lastRequestAt = 0,
	connection = nil,
	control = nil,
	profile = nil,
	profileRefreshedAt = 0,
	lastKnownPrestige = nil,
	blackScreenPrestige = nil,
	blackScreenPrestigeResetPending = false,
	levelModule = nil,
}

Hub.AutoClaimReward = {
	enabled = true,
	connection = nil,
	control = nil,
}

Hub.CoinFarm = {
	enabled = false,
	mode = "CFrame",
	position = "Normal",
	speed = 28,
	speedControl = nil,
	blackScreenEnabled = false,
	disable3DRendering = false,
	blackScreenGui = nil,
	blackScreenStartedAt = 0,
	sessionStartedAt = 0,
	resumedSessionElapsed = 0,
	antiAfkLastAt = 0,
	blackScreenUpdateGeneration = 0,
	blackScreenLabels = {},
	blackScreenControl = nil,
	renderingControl = nil,
	reduceCoinVisuals = UserInputService.TouchEnabled,
	optimizedCoinVisuals = setmetatable({}, { __mode = "k" }),
	phase = "Disabled",
	generation = 0,
	workerRunning = false,
	coins = {},
	retryUntil = {},
	contactAttempts = {},
	coinVisualParts = setmetatable({}, { __mode = "k" }),
	currentCoin = nil,
	indexedMap = nil,
	indexedCoinContainer = nil,
	mapAddedConnection = nil,
	mapRemovingConnection = nil,
	lastIndexAttemptAt = 0,
	lastBagCount = nil,
	bagMaximum = nil,
	bagFull = false,
	resetRequestedForBag = false,
	xpFarmEnabled = false,
	serverHopLowPlayers = false,
	serverHopPlayerThreshold = 4,
	serverHopRunning = false,
	serverHopCount = 0,
	serverHopTimerMinutes = 15,
	serverHopTimerStartedAt = 0,
	resumedFromServerHop = false,
	webhookUrl = "",
	webhookDraft = "",
	webhookInput = nil,
	webhookGeneration = 0,
	bagWebhookSent = false,
	serverHopControl = nil,
	serverHopThresholdControl = nil,
	serverHopTimerControl = nil,
	antiBotEnabled = false,
	antiBotControl = nil,
	antiBotLastCount = 0,
	StartLowPlayerServerHop = nil,
	StartAntiBotServerHop = nil,
	xpWaitRunning = false,
	xpWaitGeneration = 0,
	xpWaitShotStarted = false,
	xpWaitFlingAttempted = false,
	endRoundEnabled = false,
	endRoundRunning = false,
	endRoundCompleted = false,
	endRoundGeneration = 0,
	endRoundDeathRequested = false,
	endRoundRespawnRetryRunning = false,
	endRoundRespawnRetryGeneration = 0,
	lastLocalDead = false,
	flingMurderer = nil,
	flingSheriff = nil,
	getSheriffFlingTarget = nil,
	sheriffFlingRunning = false,
	sheriffFlingBlocking = false,
	sheriffFlingCompleted = false,
	shootMurderer = nil,
	runKnifeAura = nil,
	totalCollected = 0,
	totalEarnedXP = 0,
	lastObservedXP = nil,
	ownedCoinAmountLabel = nil,
	bagCurrentValue = nil,
	bagCountLabel = nil,
	ranThisRound = false,
	endTeleportDone = false,
	safetyChecked = false,
	safetyStartedAt = 0,
	murdererNearRange = 30,
	nextMurdererCheckAt = 0,
	nextMurdererEscapeAt = 0,
	escapeCoin = nil,
	escapeUnderActive = false,
	activeTween = nil,
	underCharacter = nil,
	underParts = {},
	underToolMassless = {},
	underAddedConnection = nil,
	stabilizer = nil,
	stabilizerRoot = nil,
	nextUnderEnforceAt = 0,
	statsControl = nil,
	toggleControl = nil,
	xpFarmControl = nil,
	UpdateXPFarmLock = nil,
	endRoundControl = nil,
	modeControl = nil,
	positionControl = nil,
	lastStatsText = nil,
}

Hub.ShowRoundTimer = false
Hub.ShowTimerControl = nil
Hub.ShowTimerBeforeXPFarm = false
Hub.ShowTimerForcedByXPFarm = false
Hub.SetXPFarmTimerForced = nil
Hub.UpdateRoundTimer = nil
Hub.MobileRoundTimerGui = nil
Hub.AvoidMurderer = { enabled = false, distance = 35, nextTeleportAt = 0, accumulator = 0, connection = nil }
Hub.AutoMapVote = { enabled = false, board = "Board 1", thread = nil, control = nil, boardControl = nil }
local VirtualUser = nil

pcall(function()
	VirtualUser = game:GetService("VirtualUser")
end)

trackConn(localPlayer.Idled:Connect(function()
	if not Hub.CoinFarm.enabled or not VirtualUser then
		return
	end
	local now = os.clock()
	if now - Hub.CoinFarm.antiAfkLastAt < 30 then
		return
	end
	Hub.CoinFarm.antiAfkLastAt = now
	local currentCamera2 = workspace.CurrentCamera
	local cFrame = currentCamera2 and currentCamera2.CFrame or CFrame.new()

	pcall(function()
		VirtualUser:CaptureController()
		VirtualUser:Button2Down(Vector2.new(0, 0), cFrame)
	end)

	task.delay(0.1, function()
		pcall(function()
			VirtualUser:Button2Up(Vector2.new(0, 0), cFrame)
		end)
	end)
end))

Hub.AutoPrestige.GetData = function(arg)
	local now = os.clock()
	local flag7 = arg or not Hub.AutoPrestige.profile
	local flag8

	if flag7 then
		flag8 = flag7
	else
		flag8 = now - (Hub.AutoPrestige.profileRefreshedAt or 0) >= 1
	end

	if flag8 then
		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		remotes = remotes and remotes:FindFirstChild("Inventory")
		local getProfileData = remotes and remotes:FindFirstChild("GetProfileData")

		if getProfileData and getProfileData:IsA("RemoteFunction") then
			local ok, profile = pcall(function()
				return getProfileData:InvokeServer(localPlayer.Name)
			end)

			if ok and type(profile) == "table" then
				Hub.AutoPrestige.profile = profile
				Hub.AutoPrestige.profileRefreshedAt = now
			end
		end
	end

	if not Hub.AutoPrestige.profile then
		local ok, profile = pcall(require, ReplicatedStorage.Modules.ProfileData)

		if ok and type(profile) == "table" then
			Hub.AutoPrestige.profile = profile
			Hub.AutoPrestige.profileRefreshedAt = now
		end
	end

	if not Hub.AutoPrestige.levelModule then
		local ok, levelModule = pcall(require, ReplicatedStorage.Modules.LevelModule)

		if ok and type(levelModule) == "table" then
			Hub.AutoPrestige.levelModule = levelModule
		end
	end

	return Hub.AutoPrestige.profile, Hub.AutoPrestige.levelModule
end

Hub.AutoPrestige.SetControl = function(arg)
	local control = Hub.AutoPrestige.control

	if control and type(control.Set) == "function" then
		pcall(function()
			control:Set(arg)
		end)
	end
end

Hub.AutoPrestige.FireButton = function(arg)
	if not arg or not arg:IsA("GuiButton") then
		return false
	end

	if type(firesignal) == "function" then
		if pcall(function()
			firesignal(arg.MouseButton1Click)
		end) then
			return true
		end
	end

	if type(getconnections) == "function" then
		local flag7 = false

		for _, v8 in ipairs(getconnections(arg.MouseButton1Click)) do
			local ok = pcall(function()
				if type(v8.Fire) == "function" then
					v8:Fire()
				elseif type(v8.Function) == "function" then
					v8.Function()
				end
			end)

			flag7 = flag7 or ok
		end

		if flag7 then
			return true
		end
	end

	return false
end

Hub.AutoPrestige.Request = function()
	local playerGui = localPlayer:FindFirstChild("PlayerGui")
	playerGui = playerGui and playerGui:FindFirstChild("MainGUI")
	playerGui = playerGui and playerGui:FindFirstChild("Game")
	local level = playerGui and playerGui:FindFirstChild("Level")
	local tabletLevel = playerGui and playerGui:FindFirstChild("TabletLevel")
	level = level and level:FindFirstChild("Prestige")

	if not level or not level.Visible then
		level = tabletLevel and tabletLevel:FindFirstChild("Prestige")
	end

	if level and Hub.AutoPrestige.FireButton(level) then
		task.wait(0.1)
		playerGui = playerGui and playerGui:FindFirstChild("Prestige")
		if Hub.AutoPrestige.FireButton(playerGui and playerGui:FindFirstChild("Accept")) then
			return true
		end
	end

	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	remotes = remotes and remotes:FindFirstChild("Inventory")
	remotes = remotes and remotes:FindFirstChild("Prestige")
	if remotes and remotes:IsA("RemoteEvent") then
		remotes:FireServer()
		return true
	end
	return false
end

Hub.AutoPrestige.Check = function()
	if not Hub.AutoPrestige.enabled then
		return false
	end
	local v8, v9 = Hub.AutoPrestige.GetData(true)
	if not v8 or not v9 or type(v9.GetLevel) ~= "function" then
		return false
	end
	local lastKnownPrestige = tonumber(localPlayer:GetAttribute("Prestige")) or tonumber(v8.Prestige) or 0
	local n2 = tonumber(v8.NewXP) or 0
	local v10 = tonumber
	local v11 = v9.GetLevel(n2)
	local n3 = v10(v11) or 1
	local num = tonumber(Hub.AutoPrestige.lastKnownPrestige)
	Hub.AutoPrestige.lastKnownPrestige = lastKnownPrestige

	if num and lastKnownPrestige > num then
		Hub.AutoPrestige.waitingForServer = false
		Hub.AutoPrestige.requestedPrestige = nil
	end

	if lastKnownPrestige >= 10 then
		Hub.AutoPrestige.enabled = false
		Hub.AutoPrestige.waitingForServer = false
		Hub.AutoPrestige.requestedPrestige = nil
		Hub.AutoPrestige.SetControl(false)

		WindUI:Notify({
			Title = "Auto Prestige",
			Content = "Maximum prestige reached (X)",
			Icon = "crown",
			Duration = 3,
		})

		return false
	end

	if Hub.AutoPrestige.waitingForServer then
		if not (lastKnownPrestige > (tonumber(Hub.AutoPrestige.requestedPrestige) or lastKnownPrestige) or n3 < 100) then
			return false
		end
		Hub.AutoPrestige.waitingForServer = false
		Hub.AutoPrestige.requestedPrestige = nil
	end

	local flag7 = n3 < 100
	local flag8

	if flag7 then
		flag8 = flag7
	else
		local lastRequestAt = Hub.AutoPrestige.lastRequestAt
		flag8 = os.clock() - lastRequestAt < 15
	end

	if flag8 then
		return false
	end
	Hub.AutoPrestige.waitingForServer = true
	Hub.AutoPrestige.requestedPrestige = lastKnownPrestige
	Hub.AutoPrestige.lastRequestAt = os.clock()

	if not Hub.AutoPrestige.Request() then
		Hub.AutoPrestige.waitingForServer = false
		Hub.AutoPrestige.requestedPrestige = nil
		return false
	end

	WindUI:Notify({
		Title = "Auto Prestige",
		Content = "Prestige " .. tostring(lastKnownPrestige + 1) .. " requested",
		Icon = "crown",
		Duration = 2.5,
	})

	return true
end

Hub.AutoPrestige.SetEnabled = function(arg)
	Hub.AutoPrestige.enabled = arg and true or false

	if not Hub.AutoPrestige.enabled then
		Hub.AutoPrestige.waitingForServer = false
		Hub.AutoPrestige.requestedPrestige = nil
		return
	end

	task.defer(Hub.AutoPrestige.Check)
end

Hub.AutoPrestige.Init = function()
	if Hub.AutoPrestige.connection then
		return
	end
	local updateData2 = ReplicatedStorage:FindFirstChild("UpdateData2")

	if updateData2 and updateData2:IsA("RemoteEvent") then
		Hub.AutoPrestige.connection = updateData2.OnClientEvent:Connect(function()
			task.defer(function()
				RunService.Heartbeat:Wait()
				Hub.AutoPrestige.GetData(true)

				if Hub.CoinFarm.enabled and type(Hub.CoinFarm.SyncEarnedXP) == "function" then
					Hub.CoinFarm.SyncEarnedXP()
				end

				if Hub.AutoPrestige.enabled then
					Hub.AutoPrestige.Check()
				end
			end)
		end)
	end
end

Hub.AutoPrestige.Destroy = function()
	Hub.AutoPrestige.enabled = false
	Hub.AutoPrestige.waitingForServer = false
	Hub.AutoPrestige.requestedPrestige = nil

	if Hub.AutoPrestige.connection then
		Hub.AutoPrestige.connection:Disconnect()
		Hub.AutoPrestige.connection = nil
	end
end

Hub.AutoPrestige.Init()

task.spawn(function()
	while foxnameMM2Runtime.alive and not isTerminated do
		if Hub.AutoPrestige.enabled then
			pcall(Hub.AutoPrestige.Check)
		end

		task.wait(2)
	end
end)

Hub.AutoClaimReward.FireButton = function(btn)
	if not btn or not btn:IsA("GuiButton") then
		return false
	end

	local fired = false

	if type(firesignal) == "function" then
		for _, sig in ipairs({ btn.Activated, btn.MouseButton1Click }) do
			if sig and pcall(firesignal, sig) then
				fired = true
			end
		end

		if fired then
			return true
		end
	end

	if type(getconnections) == "function" then
		for _, sig in ipairs({ btn.Activated, btn.MouseButton1Click }) do
			if sig then
				for _, con in ipairs(getconnections(sig)) do
					local ok = pcall(function()
						if type(con.Fire) == "function" then
							con:Fire()
						elseif type(con.Function) == "function" then
							con.Function()
						end
					end)

					fired = fired or ok
				end
			end
		end
	end

	return fired
end

Hub.AutoClaimReward.Check = function()
	if not Hub.AutoClaimReward.enabled then
		return false
	end

	local playerGui = localPlayer:FindFirstChild("PlayerGui")
	if not playerGui then
		return false
	end

	local claimed = false
	local crossPlatform = playerGui:FindFirstChild("CrossPlatform")
	local newItem = crossPlatform and crossPlatform:FindFirstChild("NewItem")
	local medium = newItem and newItem:FindFirstChild("Medium")

	if medium and medium.Visible then
		local container = medium:FindFirstChild("Container")
		local claimBtn = container and container:FindFirstChild("Claim")
		local attempts = 0

		while medium.Visible and claimBtn and attempts < 10 do
			attempts += 1
			if Hub.AutoClaimReward.FireButton(claimBtn) then
				claimed = true
			end
			task.wait(0.1)
		end
	end

	local mainGui = playerGui:FindFirstChild("MainGUI")
	local gameFrame = mainGui and mainGui:FindFirstChild("Game")
	local legacyNewItem = gameFrame and gameFrame:FindFirstChild("NewItem")

	if legacyNewItem and legacyNewItem.Visible then
		local container = legacyNewItem:FindFirstChild("Container")
		local claimBtn = container and container:FindFirstChild("Claim")

		if claimBtn and Hub.AutoClaimReward.FireButton(claimBtn) then
			claimed = true
		end
	end

	return claimed
end

Hub.AutoClaimReward.SetEnabled = function(enabled)
	Hub.AutoClaimReward.enabled = enabled and true or false

	if Hub.AutoClaimReward.enabled then
		task.defer(Hub.AutoClaimReward.Check)
	end
end

Hub.AutoClaimReward.Init = function()
	if Hub.AutoClaimReward.connection then
		return
	end

	local playerGui = localPlayer:FindFirstChild("PlayerGui")
	local crossPlatform = playerGui and playerGui:FindFirstChild("CrossPlatform")
	local newItem = crossPlatform and crossPlatform:FindFirstChild("NewItem")
	local medium = newItem and newItem:FindFirstChild("Medium")

	if medium then
		Hub.AutoClaimReward.connection = medium:GetPropertyChangedSignal("Visible"):Connect(function()
			if medium.Visible and Hub.AutoClaimReward.enabled then
				task.defer(Hub.AutoClaimReward.Check)
			end
		end)
	end
end

Hub.AutoClaimReward.Destroy = function()
	Hub.AutoClaimReward.enabled = false

	if Hub.AutoClaimReward.connection then
		Hub.AutoClaimReward.connection:Disconnect()
		Hub.AutoClaimReward.connection = nil
	end
end

Hub.AutoClaimReward.Init()

task.spawn(function()
	while foxnameMM2Runtime.alive and not isTerminated do
		if Hub.AutoClaimReward.enabled then
			if not Hub.AutoClaimReward.connection then
				pcall(Hub.AutoClaimReward.Init)
			end

			pcall(Hub.AutoClaimReward.Check)
		end

		task.wait(0.5)
	end
end)

Hub.CoinFarm.RefreshStats = function()
	local statsControl = Hub.CoinFarm.statsControl
	local cache = Hub.RoleState.cache
	local flag7 = type(cache) == "table" and (cache[localPlayer.Name] or cache[tostring(localPlayer.UserId)] or cache[localPlayer.UserId]) or nil
	local role

	if type(Hub.CoinFarm.GetCachedRole) == "function" then
		role = Hub.CoinFarm.GetCachedRole(localPlayer)
	else
		role = type(flag7) == "table" and flag7.Role or nil
	end

	if role ~= "Innocent" and role ~= "Sheriff" and role ~= "Murderer" and role ~= "Hero" then
		role = "Unknown"
	end

	local lastStatsText = "Status: " .. tostring(Hub.CoinFarm.phase) .. "\nTotal Collected Coins: " .. tostring(Hub.CoinFarm.totalCollected) .. "\nTotal Earned XP: " .. tostring(Hub.CoinFarm.totalEarnedXP) .. "\nRole: " .. role

	if Hub.CoinFarm.lastStatsText ~= lastStatsText then
		Hub.CoinFarm.lastStatsText = lastStatsText

		if statsControl and type(statsControl.SetDesc) == "function" then
			pcall(function()
				statsControl:SetDesc(lastStatsText)
			end)
		end
	end

	if type(Hub.CoinFarm.RefreshBlackScreen) == "function" then
		Hub.CoinFarm.RefreshBlackScreen(role)
	end
end

Hub.CoinFarm.GetCurrentXP = function()
	local profile = Hub.AutoPrestige.profile

	if type(profile) ~= "table" then
		local modules = ReplicatedStorage:FindFirstChild("Modules")
		modules = modules and modules:FindFirstChild("ProfileData")

		if modules then
			local ok, profile2 = pcall(require, modules)

			if ok and type(profile2) == "table" then
				Hub.AutoPrestige.profile = profile2
				profile = profile2
			end
		end
	end

	local num = type(profile) == "table" and tonumber(profile.NewXP) or nil
	return num and math.max(0, math.floor(num)) or nil
end

Hub.CoinFarm.SyncEarnedXP = function()
	if not Hub.CoinFarm.enabled then
		return false
	end
	local v8 = Hub.CoinFarm.GetCurrentXP()
	if v8 == nil then
		return false
	end
	local num = tonumber(Hub.CoinFarm.lastObservedXP)
	Hub.CoinFarm.lastObservedXP = v8
	if num == nil or v8 <= num then
		return false
	end
	local coinFarm = Hub.CoinFarm
	coinFarm.totalEarnedXP = coinFarm.totalEarnedXP + v8 - num
	Hub.CoinFarm.RefreshStats()
	return true
end

Hub.CoinFarm.SetPhase = function(phase)
	if Hub.CoinFarm.phase == phase then
		return
	end
	Hub.CoinFarm.phase = phase
	Hub.CoinFarm.RefreshStats()
end

Hub.CoinFarm.GetRoundTimeRemaining = function()
	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
	playerGui = playerGui and playerGui:FindFirstChild("MainGUI")
	playerGui = playerGui and playerGui:FindFirstChild("Game")
	playerGui = playerGui and playerGui:FindFirstChild("Timer")
	playerGui = playerGui and playerGui:FindFirstChild("XPText")
	local text = playerGui and playerGui:IsA("TextLabel") and playerGui.Text or ""
	local match, v8 = text:match("(%d+)%s*m%s*(%d+)%s*s")
	if match and v8 then
		return match * 60 + tonumber(v8), "GameUI"
	end
	local match2, v9 = text:match("(%d+)%s*:%s*(%d+)")
	if match2 and v9 then
		return match2 * 60 + v9, "GameUI"
	end
	local match3 = text:match("^(%d+)%s*s$")
	if match3 then
		return tonumber(match3), "GameUI"
	end
	local roundTimerPart = workspace:FindFirstChild("RoundTimerPart")

	if roundTimerPart then
		local num = tonumber(roundTimerPart:GetAttribute("Time"))
		if num and num >= 0 then
			return math.max(0, num), "Attribute"
		end
		local surfaceGui = roundTimerPart:FindFirstChildWhichIsA("SurfaceGui")
		surfaceGui = surfaceGui and surfaceGui:FindFirstChild("Timer", true)
		local text2 = surfaceGui and surfaceGui:IsA("TextLabel") and surfaceGui.Text or ""
		local match4, v10 = text2:match("(%d+)%s*m%s*(%d+)%s*s")
		if match4 and v10 then
			return match4 * 60 + v10, "SurfaceGui"
		end
		local match5, v11 = text2:match("(%d+)%s*:%s*(%d+)")
		if match5 and v11 then
			return match5 * 60 + v11, "SurfaceGui"
		end
		local match6 = text2:match("(%d+)%s*s")
		if match6 then
			return tonumber(match6), "SurfaceGui"
		end
		local num2 = tonumber(roundTimerPart:GetAttribute("RoundLength"))
		if num2 and Hub.RoundState.startedAt > 0 then
			local startedAt = Hub.RoundState.startedAt
			return math.max(0, num2 - os.clock() - startedAt), "Estimated"
		end
	end

	if Hub.RoundState.startedAt > 0 then
		local startedAt = Hub.RoundState.startedAt
		return math.max(0, 180 - os.clock() - startedAt), "Estimated"
	end
	return nil, "Unavailable"
end

Hub.CoinFarm.CancelXPFarmWait = function()
	local coinFarm = Hub.CoinFarm
	coinFarm.xpWaitGeneration = coinFarm.xpWaitGeneration + 1
	Hub.CoinFarm.xpWaitRunning = false
	Hub.CoinFarm.xpWaitShotStarted = false
	Hub.CoinFarm.xpWaitFlingAttempted = false
end

Hub.CoinFarm.CancelEndRoundRespawnRetry = function()
	local coinFarm = Hub.CoinFarm
	coinFarm.endRoundRespawnRetryGeneration = coinFarm.endRoundRespawnRetryGeneration + 1
	Hub.CoinFarm.endRoundRespawnRetryRunning = false
end

Hub.CoinFarm.DisconnectMap = function()
	if Hub.CoinFarm.mapAddedConnection then
		Hub.CoinFarm.mapAddedConnection:Disconnect()
		Hub.CoinFarm.mapAddedConnection = nil
	end

	if Hub.CoinFarm.mapRemovingConnection then
		Hub.CoinFarm.mapRemovingConnection:Disconnect()
		Hub.CoinFarm.mapRemovingConnection = nil
	end

	table.clear(Hub.CoinFarm.coins)
	table.clear(Hub.CoinFarm.retryUntil)
	table.clear(Hub.CoinFarm.contactAttempts)
	table.clear(Hub.CoinFarm.coinVisualParts)
	Hub.CoinFarm.currentCoin = nil
	Hub.CoinFarm.escapeCoin = nil
	Hub.CoinFarm.escapeUnderActive = false
	Hub.CoinFarm.indexedMap = nil
	Hub.CoinFarm.indexedCoinContainer = nil
end

Hub.CoinFarm.CancelTween = function()
	local activeTween = Hub.CoinFarm.activeTween
	Hub.CoinFarm.activeTween = nil
	if not activeTween then
		return
	end

	pcall(function()
		activeTween:Cancel()
	end)

	pcall(function()
		activeTween:Destroy()
	end)
end

Hub.CoinFarm.DisableUnder = function()
	if Hub.CoinFarm.underAddedConnection then
		Hub.CoinFarm.underAddedConnection:Disconnect()
		Hub.CoinFarm.underAddedConnection = nil
	end

	if Hub.CoinFarm.stabilizer then
		pcall(function()
			Hub.CoinFarm.stabilizer:Destroy()
		end)

		Hub.CoinFarm.stabilizer = nil
	end

	Hub.CoinFarm.stabilizerRoot = nil

	for k, underPart in pairs(Hub.CoinFarm.underParts) do
		if k and k.Parent then
			if Hub.NoclipEnabled then
				if Hub.NoclipParts[k] == nil or Hub.NoclipParts[k] == false then
					Hub.NoclipParts[k] = underPart
				end
			else
				k.CanCollide = underPart
			end

			local v8 = Hub.CoinFarm.underToolMassless[k]

			if v8 ~= nil then
				k.Massless = v8
			end
		end
	end

	table.clear(Hub.CoinFarm.underParts)
	table.clear(Hub.CoinFarm.underToolMassless)
	Hub.CoinFarm.underCharacter = nil
	Hub.CoinFarm.nextUnderEnforceAt = 0
end

Hub.CoinFarm.TrackUnderPart = function(arg)
	if not arg:IsA("BasePart") then
		return
	end

	if Hub.CoinFarm.underParts[arg] == nil then
		Hub.CoinFarm.underParts[arg] = arg.CanCollide
	end

	arg.CanCollide = false

	if arg:FindFirstAncestorWhichIsA("Tool") then
		if Hub.CoinFarm.underToolMassless[arg] == nil then
			Hub.CoinFarm.underToolMassless[arg] = arg.Massless
		end

		arg.Massless = true
	end
end

Hub.CoinFarm.EnableUnder = function(underCharacter, arg, arg2)
	if not (arg2 == true or Hub.CoinFarm.position == "Under" or Hub.CoinFarm.mode == "Tween") or not Hub.CoinFarm.enabled or not Hub.RoundState.active then
		Hub.CoinFarm.DisableUnder()
		return
	end

	if Hub.CoinFarm.underCharacter ~= underCharacter then
		Hub.CoinFarm.DisableUnder()
		Hub.CoinFarm.underCharacter = underCharacter

		for _, descendant in ipairs(underCharacter:GetDescendants()) do
			Hub.CoinFarm.TrackUnderPart(descendant)
		end

		Hub.CoinFarm.underAddedConnection = underCharacter.DescendantAdded:Connect(function(descendant)
			if Hub.CoinFarm.enabled and (Hub.CoinFarm.position == "Under" or Hub.CoinFarm.mode == "Tween" or Hub.CoinFarm.escapeUnderActive) then
				Hub.CoinFarm.TrackUnderPart(descendant)
			end
		end)

		Hub.CoinFarm.nextUnderEnforceAt = os.clock() + 0.5
	elseif Hub.CoinFarm.nextUnderEnforceAt <= os.clock() then
		Hub.CoinFarm.nextUnderEnforceAt = os.clock() + 0.5

		for k in pairs(Hub.CoinFarm.underParts) do
			if k and k.Parent then
				k.CanCollide = false

				if Hub.CoinFarm.underToolMassless[k] ~= nil then
					k.Massless = true
				end
			else
				Hub.CoinFarm.underParts[k] = nil
				Hub.CoinFarm.underToolMassless[k] = nil
			end
		end
	end

	local humanoidRootPart = underCharacter:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end

	if Hub.CoinFarm.position ~= "Under" and arg2 ~= true or arg == false then
		if Hub.CoinFarm.stabilizer then
			Hub.CoinFarm.stabilizer:Destroy()
			Hub.CoinFarm.stabilizer = nil
		end

		Hub.CoinFarm.stabilizerRoot = nil
		return
	end

	if not Hub.CoinFarm.stabilizer or Hub.CoinFarm.stabilizer.Parent ~= humanoidRootPart or Hub.CoinFarm.stabilizerRoot ~= humanoidRootPart then
		if Hub.CoinFarm.stabilizer then
			Hub.CoinFarm.stabilizer:Destroy()
		end

		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Name = "FoxnameCoinFarmStabilizer"
		bodyVelocity.Velocity = Vector3.zero
		bodyVelocity.MaxForce = Vector3.new(0, 9e9, 0)
		bodyVelocity.P = 90000
		bodyVelocity.Parent = humanoidRootPart
		Hub.CoinFarm.stabilizer = bodyVelocity
		Hub.CoinFarm.stabilizerRoot = humanoidRootPart
	end
end

Hub.CoinFarm.ResolveMap = function()
	local currentMapInstance = Hub.RoundState.currentMapInstance
	if currentMapInstance and currentMapInstance.Parent and currentMapInstance:IsDescendantOf(workspace) then
		return currentMapInstance
	end
	local currentMapName = Hub.RoundState.currentMapName

	if type(currentMapName) == "string" and currentMapName ~= "" then
		local v8 = workspace:FindFirstChild(currentMapName) or workspace:FindFirstChild(currentMapName, true)
		if v8 and (v8:IsA("Model") or v8:IsA("Folder")) then
			Hub.RoundState.currentMapInstance = v8
			return v8
		end
		local str = string.lower(currentMapName):gsub("[^%w]", "")

		for _, child in ipairs(workspace:GetChildren()) do
			if (child:IsA("Model") or child:IsA("Folder")) and string.lower(child.Name):gsub("[^%w]", "") == str then
				Hub.RoundState.currentMapInstance = child
				return child
			end
		end
	end

	local lobby = workspace:FindFirstChild("Lobby")

	for _, child in ipairs(workspace:GetChildren()) do
		if child ~= lobby and (child:IsA("Model") or child:IsA("Folder")) and (child:FindFirstChild("Coin_Server", true) or child:FindFirstChild("Candy_Server", true) or child:FindFirstChild("CoinContainer", true) or child:FindFirstChild("CandyContainer", true)) then
			Hub.RoundState.currentMapName = child.Name
			Hub.RoundState.currentMapInstance = child
			return child
		end
	end

	return nil
end

Hub.CoinFarm.IsLocalPlayerInRound = function()
	local character_ = localPlayer.Character
	local humanoid = character_ and character_:FindFirstChildOfClass("Humanoid")
	if not character_ or not character_:IsDescendantOf(workspace) or not humanoid or humanoid.Health <= 0 then
		return false
	end
	local cache = Hub.RoleState.cache
	local flag7 = type(cache) == "table" and (cache[localPlayer.Name] or cache[tostring(localPlayer.UserId)] or cache[localPlayer.UserId]) or nil

	if type(flag7) == "table" then
		if flag7.Role == "Murderer" or flag7.Role == "Sheriff" or flag7.Role == "Innocent" or flag7.Role == "Hero" then
			if flag7.Dead ~= true then
				return true
			end
		end
	end

	local backpack = localPlayer:FindFirstChildOfClass("Backpack")

	if character_ then
		character_ = character_:FindFirstChild("Gun") ~= nil or character_:FindFirstChild("Knife") ~= nil
	end

	return character_ or backpack and (backpack:FindFirstChild("Gun") ~= nil or backpack:FindFirstChild("Knife") ~= nil) or false
end

Hub.CoinFarm.GetCachedRole = function(arg)
	if not arg or type(Hub.RoleState.cache) ~= "table" then
		return nil
	end
	local v8 = Hub.RoleState.cache[arg.Name] or Hub.RoleState.cache[tostring(arg.UserId)] or Hub.RoleState.cache[arg.UserId]
	local role = type(v8) == "table" and v8.Role or nil

	if arg == localPlayer and Hub.RoundState.active then
		local character_ = localPlayer.Character
		local backpack = localPlayer:FindFirstChildOfClass("Backpack")
		if character_ and character_:FindFirstChild("Knife") or backpack and backpack:FindFirstChild("Knife") then
			return "Murderer"
		end

		if type(Hub.CoinFarm.FindLocalGun) == "function" and Hub.CoinFarm.FindLocalGun() then
			return role == "Sheriff" and "Sheriff" or "Hero"
		end
	end

	return role
end

Hub.CoinFarm.FindLocalGun = function()
	local v8 = workspace:FindFirstChild(localPlayer.Name)
	local gun = v8 and v8:FindFirstChild("Gun")
	if gun and gun:IsA("Tool") then
		return gun
	end
	local backpack = localPlayer:FindFirstChildOfClass("Backpack")
	backpack = backpack and backpack:FindFirstChild("Gun")
	if backpack and backpack:IsA("Tool") then
		return backpack
	end
	return nil
end

Hub.CoinFarm.GetMurdererRoot = function()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer and Hub.CoinFarm.GetCachedRole(player) == "Murderer" then
			local character_ = player.Character
			local humanoid = character_ and character_:FindFirstChildOfClass("Humanoid")
			character_ = character_ and character_:FindFirstChild("HumanoidRootPart")
			if humanoid and humanoid.Health > 0 and character_ then
				return character_
			end
		end
	end

	return nil
end

Hub.CoinFarm.RunInitialSafety = function(arg)
	if Hub.CoinFarm.safetyChecked then
		return true
	end

	if Hub.CoinFarm.GetCachedRole(localPlayer) == "Murderer" then
		Hub.CoinFarm.safetyChecked = true
		return true
	end

	if Hub.CoinFarm.safetyStartedAt == 0 then
		Hub.CoinFarm.safetyStartedAt = os.clock()
	end

	local v8 = Hub.CoinFarm.GetMurdererRoot()

	if not v8 then
		local safetyStartedAt = Hub.CoinFarm.safetyStartedAt
		if os.clock() - safetyStartedAt < 3 then
			return false
		end
		Hub.CoinFarm.safetyChecked = true
		return true
	end

	Hub.CoinFarm.safetyChecked = true
	if Hub.CoinFarm.murdererNearRange < (v8.Position - arg.Position).Magnitude then
		return true
	end
	local indexedMap = Hub.CoinFarm.indexedMap or Hub.CoinFarm.ResolveMap()
	if not indexedMap then
		return true
	end
	local n2 = -math.huge
	local v9 = nil

	for _, descendant in ipairs(indexedMap:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant.Name == "Spawn" then
			local magnitude = (descendant.Position - v8.Position).Magnitude

			if n2 < magnitude then
				n2 = magnitude
				v9 = descendant
			end
		end
	end

	if not v9 then
		return true
	end
	Hub.CoinFarm.CancelTween()
	Hub.CoinFarm.DisableUnder()
	local n3 = v9.Size.Y * 0.5 + arg.Size.Y * 0.5 + 0.15
	arg.AssemblyLinearVelocity = Vector3.zero
	arg.AssemblyAngularVelocity = Vector3.zero
	arg.CFrame = v9.CFrame + Vector3.new(0, n3, 0)
	Hub.CoinFarm.currentCoin = nil
	return true
end

Hub.CoinFarm.GetNearbyMurderer = function(arg)
	if not arg or Hub.CoinFarm.GetCachedRole(localPlayer) == "Murderer" then
		return nil
	end
	local now = os.clock()
	if now < Hub.CoinFarm.nextMurdererCheckAt then
		return nil
	end
	Hub.CoinFarm.nextMurdererCheckAt = now + 0.2
	local v8 = Hub.CoinFarm.GetMurdererRoot()
	if v8 and (v8.Position - arg.Position).Magnitude <= Hub.CoinFarm.murdererNearRange then
		return v8
	end
	return nil
end

Hub.CoinFarm.EscapeMurderer = function(arg, arg2)
	local now = os.clock()
	if not arg or not arg2 or now < Hub.CoinFarm.nextMurdererEscapeAt then
		return false
	end
	local now2 = os.clock()
	local n2 = -math.huge
	local v8 = nil

	for k in pairs(Hub.CoinFarm.coins) do
		local flag7 = Hub.CoinFarm.IsCoinAvailable(k)

		if flag7 then
			flag7 = (Hub.CoinFarm.retryUntil[k] or 0) <= now2
		end

		if flag7 then
			local magnitude = (k.Position - arg2.Position).Magnitude

			if n2 < magnitude then
				n2 = magnitude
				v8 = k
			end
		end
	end

	Hub.CoinFarm.nextMurdererEscapeAt = now + 0.5
	if not v8 then
		return false
	end
	Hub.CoinFarm.currentCoin = v8
	Hub.CoinFarm.escapeCoin = v8
	Hub.CoinFarm.escapeUnderActive = true
	Hub.CoinFarm.SetPhase("Avoiding Murderer")
	return true
end

Hub.CoinFarm.TrackCoin = function(arg)
	if arg and arg:IsA("BasePart") and (arg.Name == "Coin_Server" or arg.Name == "Candy_Server") and arg.Parent then
		Hub.CoinFarm.coins[arg] = true

		if Hub.CoinFarm.enabled and Hub.CoinFarm.OptimizeCoinVisual then
			Hub.CoinFarm.OptimizeCoinVisual(arg)

			task.defer(function()
				if Hub.CoinFarm.enabled and arg.Parent then
					Hub.CoinFarm.OptimizeCoinVisual(arg)
				end
			end)
		end
	end
end

Hub.CoinFarm.OptimizeCoinVisual = function(arg)
	if not Hub.CoinFarm.enabled or not Hub.CoinFarm.reduceCoinVisuals or not arg or not arg.Parent then
		return
	end
	local coinVisual = arg:FindFirstChild("CoinVisual")
	if not coinVisual then
		return
	end
	local optimizedCoinVisuals = Hub.CoinFarm.optimizedCoinVisuals

	local function fn12(arg2)
		if (arg2:IsA("ParticleEmitter") or arg2:IsA("Trail") or arg2:IsA("Beam")) and optimizedCoinVisuals[arg2] == nil then
			optimizedCoinVisuals[arg2] = arg2.Enabled
			arg2.Enabled = false
		elseif arg2:IsA("Light") and optimizedCoinVisuals[arg2] == nil then
			optimizedCoinVisuals[arg2] = arg2.Enabled
			arg2.Enabled = false
		end
	end

	fn12(coinVisual)

	for _, descendant in ipairs(coinVisual:GetDescendants()) do
		fn12(descendant)
	end
end

Hub.CoinFarm.RestoreCoinVisuals = function()
	for k, optimizedCoinVisual in pairs(Hub.CoinFarm.optimizedCoinVisuals) do
		if k and k.Parent then
			pcall(function()
				k.Enabled = optimizedCoinVisual
			end)
		end

		Hub.CoinFarm.optimizedCoinVisuals[k] = nil
	end
end

Hub.CoinFarm.OptimizeIndexedCoins = function()
	if not Hub.CoinFarm.enabled then
		return
	end

	for k in pairs(Hub.CoinFarm.coins) do
		Hub.CoinFarm.OptimizeCoinVisual(k)
	end
end

Hub.CoinFarm.IsCoinVisualPartVisible = function(arg, arg2)
	return arg and arg:IsA("BasePart") and (arg == arg2 or arg:IsDescendantOf(arg2)) and arg.Transparency < 0.99 and arg.LocalTransparencyModifier < 0.99
end

Hub.CoinFarm.IsCoinAvailable = function(arg)
	if not arg or not arg.Parent or not arg:IsA("BasePart") or (arg.Name ~= "Coin_Server" and arg.Name ~= "Candy_Server") then
		return false
	end
	if arg:GetAttribute("Collected") == true then
		return false
	end
	local coinVisual = arg:FindFirstChild("CoinVisual")
	if coinVisual and coinVisual:GetAttribute("Collected") == true then
		return false
	end
	if not coinVisual then
		return true
	end
	local v8 = Hub.CoinFarm.coinVisualParts[arg]

	if not Hub.CoinFarm.IsCoinVisualPartVisible(v8, coinVisual) then
		v8 = Hub.CoinFarm.IsCoinVisualPartVisible(coinVisual, coinVisual) and coinVisual or nil

		if not v8 then
			for _, descendant in ipairs(coinVisual:GetDescendants()) do
				if Hub.CoinFarm.IsCoinVisualPartVisible(descendant, coinVisual) then
					v8 = descendant
					break
				end
			end
		end

		Hub.CoinFarm.coinVisualParts[arg] = v8
	end

	return v8 ~= nil
end

Hub.CoinFarm.IndexMap = function()
	local v8 = Hub.CoinFarm.ResolveMap()
	if v8 and Hub.CoinFarm.indexedMap == v8 then
		return true
	end
	local now = os.clock()
	if now - Hub.CoinFarm.lastIndexAttemptAt < 0.75 then
		return false
	end
	Hub.CoinFarm.lastIndexAttemptAt = now
	local v9 = v8 or Hub.CoinFarm.ResolveMap()
	if not v9 then
		return false
	end
	Hub.CoinFarm.DisconnectMap()
	Hub.CoinFarm.indexedMap = v9
	local coinContainer = v9:FindFirstChild("CoinContainer") or v9:FindFirstChild("CandyContainer") or v9:FindFirstChild("CoinContainer", true) or v9:FindFirstChild("CandyContainer", true)
	local flag7

	if coinContainer then
		flag7 = not (coinContainer:IsA("Model") or coinContainer:IsA("Folder"))
	else
		flag7 = coinContainer
	end

	if flag7 then
		coinContainer = nil
	end

	v9 = coinContainer or v9
	Hub.CoinFarm.indexedCoinContainer = coinContainer

	for _, descendant in ipairs(v9:GetDescendants()) do
		Hub.CoinFarm.TrackCoin(descendant)
	end

	Hub.CoinFarm.mapAddedConnection = v9.DescendantAdded:Connect(Hub.CoinFarm.TrackCoin)

	Hub.CoinFarm.mapRemovingConnection = v9.DescendantRemoving:Connect(function(descendant)
		Hub.CoinFarm.coins[descendant] = nil
		Hub.CoinFarm.retryUntil[descendant] = nil
		Hub.CoinFarm.contactAttempts[descendant] = nil
		Hub.CoinFarm.coinVisualParts[descendant] = nil

		if Hub.CoinFarm.currentCoin == descendant then
			Hub.CoinFarm.currentCoin = nil
		end

		if Hub.CoinFarm.escapeCoin == descendant then
			Hub.CoinFarm.escapeCoin = nil
			Hub.CoinFarm.escapeUnderActive = false
		end
	end)

	Hub.CoinFarm.OptimizeIndexedCoins()
	return true
end

Hub.CoinFarm.GetNearestCoin = function(arg)
	local now = os.clock()
	local huge = math.huge
	local v8 = nil

	for k in pairs(Hub.CoinFarm.coins) do
		if not k.Parent then
			Hub.CoinFarm.coins[k] = nil
			Hub.CoinFarm.retryUntil[k] = nil
			Hub.CoinFarm.contactAttempts[k] = nil
		else
			local flag7 = Hub.CoinFarm.IsCoinAvailable(k)

			if flag7 then
				flag7 = (Hub.CoinFarm.retryUntil[k] or 0) <= now
			end

			if flag7 then
				local magnitude = (k.Position - arg.Position).Magnitude

				if magnitude < huge then
					huge = magnitude
					v8 = k
				end
			end
		end
	end

	return v8
end

Hub.CoinFarm.MarkCurrentCollected = function()
	local currentCoin = Hub.CoinFarm.currentCoin
	if not currentCoin then
		return
	end
	Hub.CoinFarm.coins[currentCoin] = nil
	Hub.CoinFarm.retryUntil[currentCoin] = nil
	Hub.CoinFarm.contactAttempts[currentCoin] = nil
	Hub.CoinFarm.currentCoin = nil

	if Hub.CoinFarm.escapeCoin == currentCoin then
		Hub.CoinFarm.escapeCoin = nil
		Hub.CoinFarm.escapeUnderActive = false
	end
end

Hub.CoinFarm.FindBagCountLabel = function()
	local playerGui = localPlayer:FindFirstChild("PlayerGui")
	playerGui = playerGui and playerGui:FindFirstChild("MainGUI")
	playerGui = playerGui and playerGui:FindFirstChild("Game")
	playerGui = playerGui and playerGui:FindFirstChild("CoinBags")
	local container = playerGui and playerGui:FindFirstChild("Container")
	if not container then
		return nil
	end
	local bag = (container:FindFirstChild("Candy") and container.Candy.Visible and container.Candy)
		or (container:FindFirstChild("Coin") and container.Coin.Visible and container.Coin)
		or container:FindFirstChild("Candy")
		or container:FindFirstChild("Coin")
	local coin = bag and bag:FindFirstChild("CurrencyFrame")
	coin = coin and coin:FindFirstChild("Icon")
	coin = coin and coin:FindFirstChild("Coins")
	return coin and coin:IsA("TextLabel") and coin or nil
end

Hub.CoinFarm.GetBagCount = function()
	if type(Hub.CoinFarm.bagCurrentValue) == "number" then
		return Hub.CoinFarm.bagCurrentValue
	end
	local bagCountLabel = Hub.CoinFarm.bagCountLabel

	if not bagCountLabel or not bagCountLabel.Parent then
		bagCountLabel = Hub.CoinFarm.FindBagCountLabel()
		Hub.CoinFarm.bagCountLabel = bagCountLabel
	end

	if not bagCountLabel then
		return nil
	end
	local match = tostring(bagCountLabel.Text or ""):match("%d[%d,]*")

	if match then
		local v8 = tonumber
		local str = match:gsub(",", "")
		match = v8(str)
	end

	return match or nil
end

Hub.CoinFarm.SyncTotalCollected = function()
	if not Hub.CoinFarm.enabled then
		return
	end
	local v8 = Hub.CoinFarm.GetBagCount()
	if type(v8) ~= "number" then
		return
	end
	local lastBagCount = math.max(0, math.floor(v8))
	local lastBagCount2 = Hub.CoinFarm.lastBagCount
	if lastBagCount2 == nil then
		Hub.CoinFarm.lastBagCount = lastBagCount
		return
	end

	if lastBagCount >= lastBagCount2 and lastBagCount > lastBagCount2 then
		local coinFarm = Hub.CoinFarm
		coinFarm.totalCollected = coinFarm.totalCollected + lastBagCount - lastBagCount2
		Hub.CoinFarm.RefreshStats()
	end

	Hub.CoinFarm.lastBagCount = lastBagCount
end

Hub.CoinFarm.ResetAfterBagFull = function()
	if not Hub.CoinFarm.enabled then
		return false
	end

	if Hub.CoinFarm.resetRequestedForBag then
		return true
	end
	local character_ = localPlayer.Character
	local humanoid = character_ and character_:FindFirstChildOfClass("Humanoid")
	if not character_ or not humanoid or humanoid.Health <= 0 then
		return false
	end
	Hub.CoinFarm.resetRequestedForBag = true
	Hub.CoinFarm.SetPhase("Coin bag full: Resetting")
	Hub.CoinFarm.CancelTween()
	Hub.CoinFarm.LeaveUnderSafely(nil, true)

	pcall(function()
		humanoid.Health = 0
	end)

	if humanoid.Health > 0 then
		pcall(function()
			character_:BreakJoints()
		end)
	end

	return true
end

Hub.CoinFarm.ApplyBagCount = function(arg, arg2)
	if not Hub.CoinFarm.enabled then
		return
	end
	local num = tonumber(arg)
	if not num then
		return
	end
	local bagCurrentValue = math.max(0, math.floor(num))
	Hub.CoinFarm.bagCurrentValue = bagCurrentValue
	local num2 = tonumber(arg2)

	if num2 and num2 > 0 then
		Hub.CoinFarm.bagMaximum = math.floor(num2)
	end

	Hub.CoinFarm.SyncTotalCollected()

	if Hub.CoinFarm.bagMaximum and bagCurrentValue >= Hub.CoinFarm.bagMaximum then
		Hub.CoinFarm.bagFull = true
		Hub.CoinFarm.ReportBagFull()
		Hub.CoinFarm.currentCoin = nil
		Hub.CoinFarm.CancelTween()
		Hub.CoinFarm.LeaveUnderSafely(nil, true)

		if not (type(Hub.CoinFarm.StartXPFarmWait) == "function" and Hub.CoinFarm.StartXPFarmWait()) then
			if Hub.CoinFarm.endRoundEnabled then
				Hub.CoinFarm.SetPhase("Coin bag full")
				Hub.CoinFarm.StartEndRoundAction()
			else
				Hub.CoinFarm.ResetAfterBagFull()
			end
		end
	end
end

task.spawn(function()
	while foxnameMM2Runtime.alive and not isTerminated do
		if Hub.CoinFarm.enabled then
			Hub.CoinFarm.SyncEarnedXP()

			if Hub.RoundState.active then
				Hub.CoinFarm.SyncTotalCollected()
			end
		end

		task.wait(1)
	end
end)

Hub.CoinFarm.CheckBagFullGui = function()
	if not Hub.CoinFarm.enabled then
		return false
	end
	local playerGui = localPlayer:FindFirstChild("PlayerGui")
	playerGui = playerGui and playerGui:FindFirstChild("MainGUI")
	playerGui = playerGui and playerGui:FindFirstChild("Game")
	playerGui = playerGui and playerGui:FindFirstChild("CoinBags")
	local container = playerGui and playerGui:FindFirstChild("Container")
	if not container then
		return false
	end
	local bag = (container:FindFirstChild("Candy") and container.Candy.Visible and container.Candy)
		or (container:FindFirstChild("Coin") and container.Coin.Visible and container.Coin)
		or container:FindFirstChild("Candy")
		or container:FindFirstChild("Coin")
	local full = bag and bag:FindFirstChild("Full")
	if not full or not full:IsA("GuiObject") or full.Visible ~= true then
		return false
	end
	Hub.CoinFarm.bagFull = true
	Hub.CoinFarm.ReportBagFull()
	Hub.CoinFarm.currentCoin = nil
	Hub.CoinFarm.CancelTween()
	Hub.CoinFarm.LeaveUnderSafely(nil, true)

	if not (type(Hub.CoinFarm.StartXPFarmWait) == "function" and Hub.CoinFarm.StartXPFarmWait()) then
		if Hub.CoinFarm.endRoundEnabled then
			Hub.CoinFarm.SetPhase("Coin bag full")
			Hub.CoinFarm.StartEndRoundAction()
		else
			Hub.CoinFarm.ResetAfterBagFull()
		end
	end

	return true
end

Hub.CoinFarm.StartEndRoundAction = function()
	if not Hub.CoinFarm.endRoundEnabled or not Hub.CoinFarm.enabled or not Hub.CoinFarm.bagFull and not Hub.CoinFarm.endRoundDeathRequested or Hub.CoinFarm.endRoundRunning or Hub.CoinFarm.endRoundCompleted or Hub.CoinFarm.xpWaitRunning or not Hub.RoundState.active then
		return false
	end
	local str = Hub.CoinFarm.GetCachedRole(localPlayer)

	if str == nil then
		local character_ = localPlayer.Character
		local backpack = localPlayer:FindFirstChildOfClass("Backpack")

		if character_ and character_:FindFirstChild("Knife") or backpack and backpack:FindFirstChild("Knife") then
			str = "Murderer"
		end
	end

	local flag7 = not Hub.CoinFarm.endRoundDeathRequested and (str == "Sheriff" or str == "Hero")
	if not flag7 and str ~= "Murderer" and str ~= "Sheriff" and str ~= "Innocent" and str ~= "Hero" then
		return false
	end
	Hub.CoinFarm.endRoundRunning = true
	local coinFarm = Hub.CoinFarm
	coinFarm.endRoundGeneration = coinFarm.endRoundGeneration + 1
	local endRoundGeneration = Hub.CoinFarm.endRoundGeneration
	Hub.CoinFarm.SetPhase(flag7 and "Ending round: Auto Shoot" or str == "Murderer" and "Ending round: Knife Aura" or "Ending round: Fling")

	task.spawn(function()
		local endRoundCompleted

		if str == "Murderer" and not Hub.CoinFarm.endRoundDeathRequested and not flag7 then
			local runKnifeAura = Hub.CoinFarm.runKnifeAura
			local n2 = 0

			while true do
				local flag8 = n2 < 8 and Hub.CoinFarm.enabled and Hub.CoinFarm.endRoundEnabled and Hub.RoundState.active and Hub.CoinFarm.endRoundGeneration == endRoundGeneration
				endRoundCompleted = false

				if flag8 then
					n2 += 1

					if type(runKnifeAura) == "function" and runKnifeAura(endRoundGeneration) == true then
						endRoundCompleted = true
						break
					else
						task.wait(0.25)
						continue
					end
				end

				break
			end
		else
			task.wait(0.12)
			local n2 = 0

			while true do
				local flag8 = n2 < 3 and Hub.CoinFarm.enabled and Hub.CoinFarm.endRoundEnabled and Hub.RoundState.active and Hub.CoinFarm.endRoundGeneration == endRoundGeneration
				endRoundCompleted = false

				if flag8 then
					local character_ = localPlayer.Character
					character_ = character_ and character_:FindFirstChildOfClass("Humanoid")

					if not character_ or character_.Health <= 0 then
						Hub.CoinFarm.endRoundDeathRequested = true
						Hub.CoinFarm.QueueEndRoundAfterRespawn()
						return
					end

					n2 += 1
					local v8 = Hub.CoinFarm.GetCachedRole(localPlayer)
					local flag9 = not Hub.CoinFarm.endRoundDeathRequested and (v8 == "Sheriff" or v8 == "Hero")
					Hub.CoinFarm.SetPhase(flag9 and "Ending round: Auto Shoot" or "Ending round: Fling")
					flag9 = flag9 and Hub.CoinFarm.shootMurderer or Hub.CoinFarm.flingMurderer
					if type(flag9) == "function" and flag9() == true then
						endRoundCompleted = true
						break
					end
					task.wait(0.4)
					continue
				end

				break
			end
		end

		if Hub.CoinFarm.endRoundGeneration == endRoundGeneration then
			Hub.CoinFarm.endRoundRunning = false
			Hub.CoinFarm.endRoundCompleted = endRoundCompleted
		end
	end)

	return true
end

Hub.CoinFarm.QueueEndRoundAfterRespawn = function()
	if Hub.CoinFarm.endRoundRespawnRetryRunning or not Hub.CoinFarm.enabled or not Hub.CoinFarm.endRoundEnabled or not Hub.RoundState.active then
		return false
	end
	Hub.CoinFarm.CancelXPFarmWait()
	local coinFarm = Hub.CoinFarm
	coinFarm.endRoundGeneration = coinFarm.endRoundGeneration + 1
	Hub.CoinFarm.endRoundRunning = false
	Hub.CoinFarm.endRoundCompleted = false
	Hub.CoinFarm.endRoundRespawnRetryRunning = true
	local coinFarm2 = Hub.CoinFarm
	coinFarm2.endRoundRespawnRetryGeneration = coinFarm2.endRoundRespawnRetryGeneration + 1
	local endRoundRespawnRetryGeneration = Hub.CoinFarm.endRoundRespawnRetryGeneration
	local character_ = localPlayer.Character
	Hub.CoinFarm.SetPhase("Waiting for respawn to fling Murderer")

	task.spawn(function()
		local exitTo = nil

		while true do
			if foxnameMM2Runtime.alive and not isTerminated and Hub.CoinFarm.enabled and Hub.CoinFarm.endRoundEnabled and Hub.RoundState.active and Hub.CoinFarm.endRoundRespawnRetryGeneration == endRoundRespawnRetryGeneration then
				local character_2 = localPlayer.Character
				local humanoid = character_2 and character_2:FindFirstChildOfClass("Humanoid")
				local humanoidRootPart = character_2 and character_2:FindFirstChild("HumanoidRootPart")
				if not (character_2 and character_2 ~= character_ and character_2:IsDescendantOf(workspace) and humanoid and humanoid.Health > 0 and humanoidRootPart) then
					task.wait(0.1)
					continue
				end
			else
				exitTo = 1
				break
			end

			break
		end

		if exitTo ~= 1 then
			task.wait(0.2)

			if Hub.CoinFarm.endRoundRespawnRetryGeneration == endRoundRespawnRetryGeneration then
				Hub.CoinFarm.endRoundRespawnRetryRunning = false
				Hub.CoinFarm.endRoundCompleted = false
				Hub.CoinFarm.StartEndRoundAction()
				return
			end
		end

		if Hub.CoinFarm.endRoundRespawnRetryGeneration == endRoundRespawnRetryGeneration then
			Hub.CoinFarm.endRoundRespawnRetryRunning = false
		end
	end)

	return true
end

Hub.CoinFarm.OnPlayerDataChanged = function()
	local cache = Hub.RoleState.cache
	local flag7 = type(cache) == "table" and (cache[localPlayer.Name] or cache[tostring(localPlayer.UserId)] or cache[localPlayer.UserId]) or nil
	local lastLocalDead = type(flag7) == "table" and flag7.Dead == true

	if lastLocalDead and not Hub.CoinFarm.lastLocalDead and Hub.CoinFarm.enabled and Hub.CoinFarm.endRoundEnabled and Hub.CoinFarm.ranThisRound and flag7.Role ~= "Murderer" then
		Hub.CoinFarm.endRoundDeathRequested = true
		Hub.CoinFarm.QueueEndRoundAfterRespawn()
	end

	Hub.CoinFarm.lastLocalDead = lastLocalDead
	Hub.CoinFarm.StartRoundSheriffFling()
end

Hub.CoinFarm.StartRoundSheriffFling = function()
	local v8 = Hub.CoinFarm.GetCachedRole(localPlayer)
	local sheriffFlingRunning = Hub.CoinFarm.sheriffFlingRunning or Hub.CoinFarm.sheriffFlingCompleted or not Hub.CoinFarm.enabled or not Hub.CoinFarm.endRoundEnabled or not Hub.RoundState.active
	local flag7

	if sheriffFlingRunning then
		flag7 = sheriffFlingRunning
	else
		flag7 = v8 ~= "Murderer" and v8 ~= "Innocent"
	end

	if flag7 then
		return false
	end
	Hub.CoinFarm.sheriffFlingRunning = true
	Hub.CoinFarm.sheriffFlingBlocking = true
	local endRoundGeneration = Hub.CoinFarm.endRoundGeneration

	task.spawn(function()
		local function fn12()
			local v9 = Hub.CoinFarm.GetCachedRole(localPlayer)
			return Hub.CoinFarm.enabled and Hub.CoinFarm.endRoundEnabled and Hub.RoundState.active and Hub.CoinFarm.endRoundGeneration == endRoundGeneration and (v9 == "Murderer" or v9 == "Innocent")
		end

		local function fn13()
			local gunDrop = workspace:FindFirstChild("GunDrop")
			return gunDrop ~= nil and gunDrop:IsA("BasePart")
		end

		local n2 = os.clock() + 10
		local flag8, flag9

		while true do
			local flag10 = fn12() and os.clock() < n2
			flag8 = false
			flag9 = false

			if flag10 then
				if fn13() then
					flag8 = true
					break
				else
					local getSheriffFlingTarget = Hub.CoinFarm.getSheriffFlingTarget
					local flag11 = type(getSheriffFlingTarget) == "function" and getSheriffFlingTarget() or nil

					if flag11 and flag11 ~= localPlayer then
						local character_ = localPlayer.Character
						local humanoid = character_ and character_:FindFirstChildOfClass("Humanoid")
						character_ = character_ and character_:FindFirstChild("HumanoidRootPart")
						local character_2 = flag11.Character
						local humanoid2 = character_2 and character_2:FindFirstChildOfClass("Humanoid")
						local humanoidRootPart = character_2 and character_2:FindFirstChild("HumanoidRootPart")

						if Hub.CoinFarm.IsLocalPlayerInRound() and humanoid and humanoid.Health > 0 and character_ and character_2 and character_2:IsDescendantOf(workspace) and humanoid2 and humanoid2.Health > 0 and humanoidRootPart and fn12() then
							Hub.CoinFarm.CancelTween()
							Hub.CoinFarm.currentCoin = nil
							Hub.CoinFarm.LeaveUnderSafely(nil, true)
							RunService.Heartbeat:Wait()
							local flingSheriff = Hub.CoinFarm.flingSheriff

							if type(flingSheriff) == "function" then
								local result
								flag8, result = pcall(flingSheriff, endRoundGeneration, flag11)
								flag9 = true
								flag8 = flag8 and result == true
							end

							break
						else
							task.wait(0.1)
							continue
						end
					else
						task.wait(0.1)
						continue
					end
				end
			end

			break
		end

		local character_ = localPlayer.Character
		character_ = character_ and character_:FindFirstChildOfClass("Humanoid")
		local currentCamera2 = workspace.CurrentCamera

		if currentCamera2 and character_ then
			currentCamera2.CameraType = Enum.CameraType.Custom
			currentCamera2.CameraSubject = character_
		end

		if Hub.CoinFarm.endRoundGeneration == endRoundGeneration then
			Hub.CoinFarm.sheriffFlingRunning = false
			Hub.CoinFarm.sheriffFlingBlocking = false
			Hub.CoinFarm.sheriffFlingCompleted = flag9 or flag8 or fn13()
		end
	end)

	return true
end

Hub.CoinFarm.OnRoundStarted = function()
	local coinFarm = Hub.CoinFarm
	coinFarm.generation = coinFarm.generation + 1
	Hub.CoinFarm.CancelXPFarmWait()
	Hub.CoinFarm.CancelEndRoundRespawnRetry()
	Hub.CoinFarm.CancelTween()
	Hub.CoinFarm.DisableUnder()
	Hub.CoinFarm.ranThisRound = false
	Hub.CoinFarm.endTeleportDone = false
	Hub.CoinFarm.safetyChecked = false
	Hub.CoinFarm.safetyStartedAt = 0
	Hub.CoinFarm.nextMurdererCheckAt = 0
	Hub.CoinFarm.nextMurdererEscapeAt = 0
	Hub.CoinFarm.bagCurrentValue = 0
	Hub.CoinFarm.lastBagCount = 0
	Hub.CoinFarm.bagMaximum = nil
	Hub.CoinFarm.bagFull = false
	Hub.CoinFarm.bagWebhookSent = false
	Hub.CoinFarm.resetRequestedForBag = false
	Hub.CoinFarm.endRoundRunning = false
	Hub.CoinFarm.endRoundCompleted = false
	local coinFarm2 = Hub.CoinFarm
	coinFarm2.endRoundGeneration = coinFarm2.endRoundGeneration + 1
	Hub.CoinFarm.sheriffFlingRunning = false
	Hub.CoinFarm.sheriffFlingBlocking = false
	Hub.CoinFarm.sheriffFlingCompleted = false
	Hub.CoinFarm.endRoundDeathRequested = false
	Hub.CoinFarm.lastLocalDead = false
	Hub.RoleState.lastGunDropPicker = nil
	Hub.RoleState.lastGunDropAt = 0
	Hub.CoinFarm.DisconnectMap()

	if type(Hub.RefreshCoinESP) == "function" then
		task.defer(Hub.RefreshCoinESP)
	end

	if Hub.CoinFarm.enabled then
		Hub.CoinFarm.SetPhase("Waiting for coins")
		Hub.CoinFarm.StartRoundSheriffFling()

		task.delay(0.75, function()
			if foxnameMM2Runtime.alive and Hub.CoinFarm.enabled and Hub.RoundState.active and Hub.CoinFarm.blackScreenEnabled then
				Hub.CoinFarm.SetBlackScreen(true, true)
			end
		end)
	end

	Hub.CoinFarm.RefreshStats()
end

Hub.CoinFarm.OnCoinsStarted = function(arg)
	if type(arg) ~= "table" or (arg.Coin == nil and arg.Candy == nil) then
		return
	end
	Hub.CoinFarm.bagCurrentValue = 0
	Hub.CoinFarm.lastBagCount = 0
	local coin = arg.Candy ~= nil and arg.Candy or arg.Coin

	if type(coin) == "number" then
		Hub.CoinFarm.bagMaximum = coin
	elseif type(coin) == "table" then
		Hub.CoinFarm.bagMaximum = tonumber(coin.MaxCoins or coin.Maximum or coin.Max or coin.Capacity)
	end

	Hub.CoinFarm.bagFull = false
	Hub.CoinFarm.bagWebhookSent = false
	Hub.CoinFarm.resetRequestedForBag = false

	if Hub.CoinFarm.enabled then
		Hub.CoinFarm.IndexMap()
	end

	if Hub.CoinESP and type(Hub.RefreshCoinESP) == "function" then
		task.defer(Hub.RefreshCoinESP)
	end
end

Hub.CoinFarm.TeleportToMapSpawn = function(arg)
	local character_ = localPlayer.Character
	character_ = character_ and character_:FindFirstChild("HumanoidRootPart")
	if not arg or not arg.Parent or not character_ then
		return false
	end
	local huge = math.huge
	local v8 = nil

	for _, descendant in ipairs(arg:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant.Name == "Spawn" then
			local magnitude = (descendant.Position - character_.Position).Magnitude

			if magnitude < huge then
				huge = magnitude
				v8 = descendant
			end
		end
	end

	if not v8 then
		return false
	end
	local n2 = v8.Size.Y * 0.5 + character_.Size.Y * 0.5 + 0.15
	character_.AssemblyLinearVelocity = Vector3.zero
	character_.AssemblyAngularVelocity = Vector3.zero
	character_.CFrame = v8.CFrame + Vector3.new(0, n2, 0)
	return true
end

Hub.CoinFarm.TeleportToMapSurface = function(arg)
	local character_ = localPlayer.Character
	local humanoid = character_ and character_:FindFirstChildOfClass("Humanoid")
	character_ = character_ and character_:FindFirstChild("HumanoidRootPart")
	if not arg or not arg.Parent or not arg:IsDescendantOf(workspace) or not humanoid or humanoid.Health <= 0 or not character_ then
		return false
	end
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { arg }
	local n2 = character_.Position + Vector3.new(0, character_.Size.Y * 0.5 + 0.05, 0)
	local n3 = 512
	local v8 = nil

	for i = 1, 8 do
		local hit = workspace:Raycast(n2, Vector3.new(0, n3, 0), raycastParams)
		v8 = nil

		if hit then
			if hit.Instance.Name ~= "Coin_Server" then
				v8 = hit
				break
			else
				n3 -= (hit.Position - n2).Magnitude + 0.1
				v8 = nil

				if not (n3 <= 0) then
					n2 = hit.Position + Vector3.new(0, 0.1, 0)
					v8 = nil
					continue
				end
			end
		end

		break
	end

	if not v8 then
		return false
	end
	local n4 = v8.Position.Y + humanoid.HipHeight + character_.Size.Y * 0.5 + 0.15
	character_.AssemblyLinearVelocity = Vector3.zero
	character_.AssemblyAngularVelocity = Vector3.zero
	local rotation = character_.CFrame.Rotation
	character_.CFrame = CFrame.new(character_.Position.X, n4, character_.Position.Z) * rotation
	return true
end

Hub.CoinFarm.LeaveUnderSafely = function(arg, arg2)
	local character_ = localPlayer.Character
	local humanoid = character_ and character_:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = character_ and character_:FindFirstChild("HumanoidRootPart")
	local flag7 = (Hub.CoinFarm.underCharacter ~= nil or Hub.CoinFarm.stabilizer ~= nil) and humanoidRootPart and humanoid and humanoid.Health > 0
	local flag8 = false

	if flag7 then
		local indexedMap = arg or Hub.CoinFarm.indexedMap or Hub.RoundState.currentMapInstance or Hub.CoinFarm.ResolveMap()

		if arg2 ~= false then
			flag8 = Hub.CoinFarm.TeleportToMapSpawn(indexedMap)
		end

		flag8 = flag8 or Hub.CoinFarm.TeleportToMapSurface(indexedMap)

		if not flag8 then
			humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
			humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
			humanoidRootPart.CFrame = humanoidRootPart.CFrame + Vector3.new(0, 8, 0)
			flag8 = true
		end
	end

	Hub.CoinFarm.DisableUnder()

	if flag8 and humanoidRootPart and humanoidRootPart.Parent then
		humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
		humanoidRootPart.AssemblyAngularVelocity = Vector3.zero

		pcall(function()
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end)

		task.defer(function()
			RunService.Heartbeat:Wait()

			if humanoidRootPart.Parent then
				humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
				humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
			end
		end)
	end

	return flag8
end

Hub.CoinFarm.OnRoundEnded = function()
	local coinFarm = Hub.CoinFarm
	coinFarm.generation = coinFarm.generation + 1
	Hub.CoinFarm.CancelXPFarmWait()
	Hub.CoinFarm.CancelEndRoundRespawnRetry()
	local blackScreenGui = Hub.CoinFarm.blackScreenGui
	local coinFarm2 = Hub.CoinFarm
	coinFarm2.blackScreenUpdateGeneration = coinFarm2.blackScreenUpdateGeneration + 1

	if blackScreenGui and blackScreenGui.Parent then
		pcall(function()
			blackScreenGui:Destroy()
		end)
	end

	Hub.CoinFarm.blackScreenGui = nil
	table.clear(Hub.CoinFarm.blackScreenLabels)
	local indexedMap = Hub.CoinFarm.indexedMap or Hub.RoundState.currentMapInstance
	local flag7 = Hub.CoinFarm.enabled and Hub.CoinFarm.ranThisRound and not Hub.CoinFarm.endTeleportDone

	if flag7 then
		Hub.CoinFarm.endTeleportDone = true
	end

	Hub.CoinFarm.CancelTween()

	if flag7 then
		if not Hub.CoinFarm.LeaveUnderSafely(indexedMap, true) then
			Hub.CoinFarm.TeleportToMapSpawn(indexedMap)
		end
	else
		Hub.CoinFarm.DisableUnder()
	end

	Hub.CoinFarm.bagCurrentValue = nil
	Hub.CoinFarm.lastBagCount = nil
	Hub.CoinFarm.bagMaximum = nil
	Hub.CoinFarm.bagFull = false
	Hub.CoinFarm.resetRequestedForBag = false
	Hub.CoinFarm.endRoundRunning = false
	Hub.CoinFarm.endRoundCompleted = false
	local coinFarm3 = Hub.CoinFarm
	coinFarm3.endRoundGeneration = coinFarm3.endRoundGeneration + 1
	Hub.CoinFarm.sheriffFlingRunning = false
	Hub.CoinFarm.sheriffFlingBlocking = false
	Hub.CoinFarm.sheriffFlingCompleted = false
	Hub.CoinFarm.endRoundDeathRequested = false
	Hub.CoinFarm.lastLocalDead = false
	Hub.CoinFarm.safetyChecked = false
	Hub.CoinFarm.safetyStartedAt = 0
	Hub.CoinFarm.nextMurdererCheckAt = 0
	Hub.CoinFarm.nextMurdererEscapeAt = 0
	Hub.CoinFarm.ranThisRound = false
	Hub.RoleState.cache = {}
	Hub.RoleState.lastGunDropPicker = nil
	Hub.RoleState.lastGunDropAt = 0
	Hub.CoinFarm.DisconnectMap()

	if type(Hub.DisconnectCoinESPMap) == "function" then
		Hub.DisconnectCoinESPMap(true)
	end

	if Hub.CoinFarm.enabled then
		Hub.CoinFarm.SetPhase("Waiting for round")
	end

	Hub.CoinFarm.RefreshStats()
end

Hub.CoinFarm.TouchCoin = function(arg, arg2, arg3)
	if not Hub.CoinFarm.IsCoinAvailable(arg3) then
		return false
	end
	arg2.AssemblyLinearVelocity = Vector3.zero
	arg2.CFrame = CFrame.new(Hub.CoinFarm.GetTargetPosition(arg, arg2, arg3, Hub.CoinFarm.escapeCoin == arg3 and "Under" or nil))
	local head = arg:FindFirstChild("Head") or arg2

	if type(firetouchinterest) == "function" then
		pcall(function()
			if head and head.Parent then
				firetouchinterest(head, arg3, 0)
				firetouchinterest(head, arg3, 1)
			end
			if arg2 and arg2.Parent and arg2 ~= head then
				firetouchinterest(arg2, arg3, 0)
				firetouchinterest(arg2, arg3, 1)
			end
		end)
	end

	return true
end

Hub.CoinFarm.GetTargetPosition = function(arg, arg2, arg3, arg4)
	if (arg4 or Hub.CoinFarm.position) ~= "Under" then
		return arg3.Position
	end
	local head = arg:FindFirstChild("Head")
	head = head and head:IsA("BasePart") and head or arg2
	local n2 = head.Position.Y + head.Size.Y * 0.5 - arg2.Position.Y
	local n3 = math.max(0, arg2.Size.Y * 0.5)
	local n4 = math.clamp(n2, n3, math.max(5, n3))
	local n5 = arg3.Position.Y - arg3.Size.Y * 0.5
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { arg, arg3 }
	local hit = workspace:Raycast(arg3.Position - Vector3.new(0, arg3.Size.Y * 0.5 + 0.05, 0), Vector3.new(0, -16, 0), raycastParams)

	if hit then
		n5 = hit.Position.Y
	end

	return Vector3.new(arg3.Position.X, n5 - n4 - 1.5, arg3.Position.Z)
end

Hub.CoinFarm.IsTravelValid = function(arg, arg2, arg3, arg4)
	return foxnameMM2Runtime.alive and not isTerminated and Hub.CoinFarm.enabled and not Hub.CoinFarm.sheriffFlingRunning and not Hub.CoinFarm.sheriffFlingBlocking and not Hub.FlingActive and Hub.RoundState.active and Hub.RoundState.coinsReady and Hub.CoinFarm.currentCoin == arg2 and Hub.CoinFarm.mode == arg3 and Hub.CoinFarm.position == arg4 and arg2.Parent ~= nil and Hub.CoinFarm.IsCoinAvailable(arg2) and arg.Parent ~= nil and Hub.CoinFarm.IsLocalPlayerInRound()
end

Hub.CoinFarm.MoveToCoin = function(arg, arg2, arg3)
	local mode = Hub.CoinFarm.mode
	local position = Hub.CoinFarm.position
	local escapeUnderActive = Hub.CoinFarm.escapeCoin == arg3
	local str = escapeUnderActive and "Under" or position
	Hub.CoinFarm.escapeUnderActive = escapeUnderActive
	local position2 = arg2.Position
	local v8 = Hub.CoinFarm.GetTargetPosition(arg, arg2, arg3, str)
	local magnitude = (v8 - position2).Magnitude
	local speed = Hub.CoinFarm.speed or 28
	local n2 = math.max(magnitude / math.max(1, speed), 0.01)

	if str == "Under" or mode == "Tween" then
		Hub.CoinFarm.EnableUnder(arg, false, escapeUnderActive)
	else
		Hub.CoinFarm.DisableUnder()
	end

	if mode == "Tween" then
		Hub.CoinFarm.CancelTween()
		local tween = TweenService:Create(arg2, TweenInfo.new(n2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), { CFrame = CFrame.new(v8) })
		Hub.CoinFarm.activeTween = tween
		tween:Play()

		while tween.PlaybackState == Enum.PlaybackState.Playing do
			if not Hub.CoinFarm.IsTravelValid(arg2, arg3, mode, position) then
				tween:Cancel()
				break
			else
				local v9 = Hub.CoinFarm.GetNearbyMurderer(arg2)

				if v9 and Hub.CoinFarm.EscapeMurderer(arg2, v9) then
					tween:Cancel()
					break
				else
					if str == "Under" or mode == "Tween" then
						Hub.CoinFarm.EnableUnder(arg, false, escapeUnderActive)
					end

					RunService.Heartbeat:Wait()
				end
			end
		end

		local flag7 = tween.PlaybackState == Enum.PlaybackState.Completed

		if Hub.CoinFarm.activeTween == tween then
			Hub.CoinFarm.activeTween = nil
		end

		pcall(function()
			tween:Destroy()
		end)

		if flag7 and str == "Under" then
			Hub.CoinFarm.EnableUnder(arg, true, escapeUnderActive)
		end

		return flag7
	end

	local now = os.clock()
	local v9 = now

	while Hub.CoinFarm.IsTravelValid(arg2, arg3, mode, position) do
		local now2 = os.clock()
		local n3 = math.clamp((now2 - now) / n2, 0, 1)

		if str == "Under" then
			Hub.CoinFarm.EnableUnder(arg, false, escapeUnderActive)
		end

		local v10 = Hub.CoinFarm.GetNearbyMurderer(arg2)
		if v10 and Hub.CoinFarm.EscapeMurderer(arg2, v10) then
			return false
		end
		arg2.AssemblyLinearVelocity = Vector3.zero
		arg2.AssemblyAngularVelocity = Vector3.zero
		local n4 = position2:Lerp(v8, n3)
		local n5 = math.max(3, speed * math.min(now2 - v9, 0.12) * 1.35)
		local n6 = n4 - arg2.Position

		if n5 < n6.Magnitude then
			n4 = arg2.Position + n6.Unit * n5
		end

		arg2.CFrame = CFrame.new(n4)

		if n3 >= 1 then
			if str == "Under" then
				Hub.CoinFarm.EnableUnder(arg, true, escapeUnderActive)
			end

			return true
		end

		RunService.Heartbeat:Wait()
		v9 = now2
	end

	return false
end

Hub.CoinFarm.Worker = function()
	if Hub.CoinFarm.workerRunning then
		return
	end
	Hub.CoinFarm.workerRunning = true
	local character_, humanoid, humanoidRootPart, currentCoin, flag7

	while true do
		local alive = foxnameMM2Runtime.alive
		local flag8 = alive and not isTerminated
		local exitTo = nil
		local flag9, flag10, flag11, flag12, flag13, getTargetPosition, str, v8, position, flag14, flag15, v9, v10, n2, n3, flag16

		while flag8 do
			if not Hub.CoinFarm.enabled then
				exitTo = 1
				break
			elseif Hub.CoinFarm.sheriffFlingBlocking or Hub.FlingActive then
				exitTo = 2
				break
			elseif not Hub.RoundState.active then
				exitTo = 3
				break
			else
				local v11, flag17, startedAt, flag18, sheriffFlingRunning

				if not Hub.RoundState.coinsReady then
					Hub.CoinFarm.IndexMap()

					for k in pairs(Hub.CoinFarm.coins) do
						if Hub.CoinFarm.IsCoinAvailable(k) then
							Hub.RoundState.coinsReady = true
							break
						end
					end

					if not Hub.RoundState.coinsReady then
						exitTo = 14
						break
					elseif not Hub.CoinFarm.IsLocalPlayerInRound() then
						exitTo = 15
						break
					else
						v11 = Hub.CoinFarm.GetCachedRole(localPlayer)
						flag17 = Hub.CoinFarm.endRoundEnabled and v11 == nil

						if flag17 then
							startedAt = Hub.RoundState.startedAt
							flag17 = os.clock() - startedAt < 6
						end

						if flag17 then
							exitTo = 16
							break
						else
							flag18 = Hub.CoinFarm.endRoundEnabled and not Hub.CoinFarm.sheriffFlingCompleted and (v11 == "Murderer" or v11 == "Innocent")

							if flag18 then
								Hub.CoinFarm.StartRoundSheriffFling()
								sheriffFlingRunning = Hub.CoinFarm.sheriffFlingRunning or Hub.CoinFarm.sheriffFlingBlocking

								if sheriffFlingRunning then
									exitTo = 23
									break
								else
									if not Hub.CoinFarm.bagFull then
										Hub.CoinFarm.CheckBagFullGui()
									end

									if Hub.CoinFarm.bagFull then
										Hub.CoinFarm.CancelTween()
										Hub.CoinFarm.LeaveUnderSafely(nil, true)
										Hub.CoinFarm.currentCoin = nil
										flag9 = type(Hub.CoinFarm.StartXPFarmWait) == "function" and Hub.CoinFarm.StartXPFarmWait()

										if not flag9 then
											if Hub.CoinFarm.endRoundEnabled then
												Hub.CoinFarm.SetPhase("Coin bag full")
												Hub.CoinFarm.StartEndRoundAction()
											else
												Hub.CoinFarm.ResetAfterBagFull()
											end
										end

										task.wait(0.2)
										alive = foxnameMM2Runtime.alive
										flag8 = alive and not isTerminated
									elseif not Hub.CoinFarm.IndexMap() then
										Hub.CoinFarm.SetPhase("Waiting for map")
										task.wait(0.2)
										alive = foxnameMM2Runtime.alive
										flag8 = alive and not isTerminated
									else
										Hub.CoinFarm.ranThisRound = true
										Hub.CoinFarm.SetPhase("Farming")
										character_ = localPlayer.Character
										humanoid = character_ and character_:FindFirstChildOfClass("Humanoid")
										humanoidRootPart = character_ and character_:FindFirstChild("HumanoidRootPart")
										flag10 = not humanoid or humanoid.Health <= 0
										flag11 = flag10 or not humanoidRootPart

										if flag11 then
											humanoid = humanoid and humanoid.Health <= 0 and Hub.CoinFarm.endRoundEnabled and Hub.CoinFarm.ranThisRound and Hub.CoinFarm.GetCachedRole(localPlayer) ~= "Murderer"

											if humanoid then
												Hub.CoinFarm.endRoundDeathRequested = true
												Hub.CoinFarm.StartEndRoundAction()
											end

											Hub.CoinFarm.CancelTween()
											Hub.CoinFarm.DisableUnder()
											Hub.CoinFarm.currentCoin = nil
											Hub.CoinFarm.SetPhase("Waiting for respawn")
											task.wait(0.2)
											alive = foxnameMM2Runtime.alive
											flag8 = alive and not isTerminated
										else
											currentCoin = Hub.CoinFarm.currentCoin
											flag12 = not currentCoin or not currentCoin.Parent or not Hub.CoinFarm.coins[currentCoin]
											flag13 = flag12 or not Hub.CoinFarm.IsCoinAvailable(currentCoin)

											if flag13 then
												if Hub.CoinFarm.escapeCoin == currentCoin then
													Hub.CoinFarm.escapeCoin = nil
													Hub.CoinFarm.escapeUnderActive = false
												end

												currentCoin = Hub.CoinFarm.GetNearestCoin(humanoidRootPart)
												Hub.CoinFarm.currentCoin = currentCoin
											end

											if not currentCoin then
												Hub.CoinFarm.DisableUnder()
												Hub.CoinFarm.SetPhase("Waiting for coin")
												task.wait(0.15)
												alive = foxnameMM2Runtime.alive
												flag8 = alive and not isTerminated
											else
												flag7 = Hub.CoinFarm.escapeCoin == currentCoin
												getTargetPosition = Hub.CoinFarm.GetTargetPosition
												str = flag7 and "Under"
												v8 = str or nil
												position = humanoidRootPart.Position

												if not ((getTargetPosition(character_, humanoidRootPart, currentCoin, v8) - position).Magnitude > 2.25) then
													flag14 = not currentCoin.Parent or Hub.CoinFarm.currentCoin ~= currentCoin

													if flag14 then
														alive = foxnameMM2Runtime.alive
														flag8 = alive and not isTerminated
													else
														flag15 = Hub.CoinFarm.position == "Under"
														v9 = flag15 or flag7

														if v9 then
															Hub.CoinFarm.EnableUnder(character_, true, flag7)
														end

														Hub.CoinFarm.SetPhase("Farming")
														v10 = Hub.CoinFarm.contactAttempts[currentCoin]
														n2 = v10 or 0
														n3 = n2 + 1
														Hub.CoinFarm.contactAttempts[currentCoin] = n3
														Hub.CoinFarm.TouchCoin(character_, humanoidRootPart, currentCoin)

														if flag7 then
															Hub.CoinFarm.escapeCoin = nil
															Hub.CoinFarm.escapeUnderActive = false

															if Hub.CoinFarm.position ~= "Under" then
																Hub.CoinFarm.DisableUnder()
															end
														end

														task.wait(0.3)
														flag16 = Hub.CoinFarm.currentCoin == currentCoin and Hub.CoinFarm.coins[currentCoin]

														if flag16 then
															if not (n3 >= 2) then
																alive = foxnameMM2Runtime.alive
																flag8 = alive and not isTerminated
															else
																Hub.CoinFarm.retryUntil[currentCoin] = os.clock() + 1.5
																Hub.CoinFarm.contactAttempts[currentCoin] = nil
																Hub.CoinFarm.currentCoin = nil

																if Hub.CoinFarm.escapeCoin ~= currentCoin then
																	alive = foxnameMM2Runtime.alive
																	flag8 = alive and not isTerminated
																else
																	Hub.CoinFarm.escapeCoin = nil
																	Hub.CoinFarm.escapeUnderActive = false
																	alive = foxnameMM2Runtime.alive
																	flag8 = alive and not isTerminated
																end
															end
														else
															alive = foxnameMM2Runtime.alive
															flag8 = alive and not isTerminated
														end
													end
												else
													Hub.CoinFarm.SetPhase("Farming")

													if not Hub.CoinFarm.MoveToCoin(character_, humanoidRootPart, currentCoin) then
														if Hub.CoinFarm.currentCoin == currentCoin then
															Hub.CoinFarm.currentCoin = nil
														end

														task.wait(0.05)
														alive = foxnameMM2Runtime.alive
														flag8 = alive and not isTerminated
													else
														flag14 = not currentCoin.Parent or Hub.CoinFarm.currentCoin ~= currentCoin

														if flag14 then
															alive = foxnameMM2Runtime.alive
															flag8 = alive and not isTerminated
														else
															flag15 = Hub.CoinFarm.position == "Under"
															v9 = flag15 or flag7

															if v9 then
																Hub.CoinFarm.EnableUnder(character_, true, flag7)
															end

															Hub.CoinFarm.SetPhase("Farming")
															v10 = Hub.CoinFarm.contactAttempts[currentCoin]
															n2 = v10 or 0
															n3 = n2 + 1
															Hub.CoinFarm.contactAttempts[currentCoin] = n3
															Hub.CoinFarm.TouchCoin(character_, humanoidRootPart, currentCoin)

															if flag7 then
																Hub.CoinFarm.escapeCoin = nil
																Hub.CoinFarm.escapeUnderActive = false

																if Hub.CoinFarm.position ~= "Under" then
																	Hub.CoinFarm.DisableUnder()
																end
															end

															task.wait(0.3)
															flag16 = Hub.CoinFarm.currentCoin == currentCoin and Hub.CoinFarm.coins[currentCoin]

															if flag16 then
																if not (n3 >= 2) then
																	alive = foxnameMM2Runtime.alive
																	flag8 = alive and not isTerminated
																else
																	Hub.CoinFarm.retryUntil[currentCoin] = os.clock() + 1.5
																	Hub.CoinFarm.contactAttempts[currentCoin] = nil
																	Hub.CoinFarm.currentCoin = nil

																	if Hub.CoinFarm.escapeCoin ~= currentCoin then
																		alive = foxnameMM2Runtime.alive
																		flag8 = alive and not isTerminated
																	else
																		Hub.CoinFarm.escapeCoin = nil
																		Hub.CoinFarm.escapeUnderActive = false
																		alive = foxnameMM2Runtime.alive
																		flag8 = alive and not isTerminated
																	end
																end
															else
																alive = foxnameMM2Runtime.alive
																flag8 = alive and not isTerminated
															end
														end
													end
												end
											end
										end
									end
								end
							else
								if not Hub.CoinFarm.bagFull then
									Hub.CoinFarm.CheckBagFullGui()
								end

								if Hub.CoinFarm.bagFull then
									exitTo = 17
									break
								elseif not Hub.CoinFarm.IndexMap() then
									exitTo = 18
									break
								else
									Hub.CoinFarm.ranThisRound = true
									Hub.CoinFarm.SetPhase("Farming")
									character_ = localPlayer.Character
									humanoid = character_ and character_:FindFirstChildOfClass("Humanoid")
									humanoidRootPart = character_ and character_:FindFirstChild("HumanoidRootPart")
									flag10 = not humanoid or humanoid.Health <= 0
									flag11 = flag10 or not humanoidRootPart

									if flag11 then
										exitTo = 19
										break
									else
										currentCoin = Hub.CoinFarm.currentCoin
										flag12 = not currentCoin or not currentCoin.Parent or not Hub.CoinFarm.coins[currentCoin]
										flag13 = flag12 or not Hub.CoinFarm.IsCoinAvailable(currentCoin)

										if flag13 then
											if Hub.CoinFarm.escapeCoin == currentCoin then
												Hub.CoinFarm.escapeCoin = nil
												Hub.CoinFarm.escapeUnderActive = false
											end

											currentCoin = Hub.CoinFarm.GetNearestCoin(humanoidRootPart)
											Hub.CoinFarm.currentCoin = currentCoin
										end

										if not currentCoin then
											exitTo = 20
											break
										else
											flag7 = Hub.CoinFarm.escapeCoin == currentCoin
											getTargetPosition = Hub.CoinFarm.GetTargetPosition
											str = flag7 and "Under"
											v8 = str or nil
											position = humanoidRootPart.Position

											if not ((getTargetPosition(character_, humanoidRootPart, currentCoin, v8) - position).Magnitude > 2.25) then
												exitTo = 21
												break
											else
												Hub.CoinFarm.SetPhase("Farming")

												if not Hub.CoinFarm.MoveToCoin(character_, humanoidRootPart, currentCoin) then
													exitTo = 22
													break
												else
													flag14 = not currentCoin.Parent or Hub.CoinFarm.currentCoin ~= currentCoin

													if flag14 then
														alive = foxnameMM2Runtime.alive
														flag8 = alive and not isTerminated
													else
														flag15 = Hub.CoinFarm.position == "Under"
														v9 = flag15 or flag7

														if v9 then
															Hub.CoinFarm.EnableUnder(character_, true, flag7)
														end

														Hub.CoinFarm.SetPhase("Farming")
														v10 = Hub.CoinFarm.contactAttempts[currentCoin]
														n2 = v10 or 0
														n3 = n2 + 1
														Hub.CoinFarm.contactAttempts[currentCoin] = n3
														Hub.CoinFarm.TouchCoin(character_, humanoidRootPart, currentCoin)

														if flag7 then
															Hub.CoinFarm.escapeCoin = nil
															Hub.CoinFarm.escapeUnderActive = false

															if Hub.CoinFarm.position ~= "Under" then
																Hub.CoinFarm.DisableUnder()
															end
														end

														task.wait(0.3)
														flag16 = Hub.CoinFarm.currentCoin == currentCoin and Hub.CoinFarm.coins[currentCoin]

														if flag16 then
															if not (n3 >= 2) then
																alive = foxnameMM2Runtime.alive
																flag8 = alive and not isTerminated
															else
																Hub.CoinFarm.retryUntil[currentCoin] = os.clock() + 1.5
																Hub.CoinFarm.contactAttempts[currentCoin] = nil
																Hub.CoinFarm.currentCoin = nil

																if Hub.CoinFarm.escapeCoin ~= currentCoin then
																	alive = foxnameMM2Runtime.alive
																	flag8 = alive and not isTerminated
																else
																	Hub.CoinFarm.escapeCoin = nil
																	Hub.CoinFarm.escapeUnderActive = false
																	alive = foxnameMM2Runtime.alive
																	flag8 = alive and not isTerminated
																end
															end
														else
															alive = foxnameMM2Runtime.alive
															flag8 = alive and not isTerminated
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end
				elseif not Hub.CoinFarm.IsLocalPlayerInRound() then
					exitTo = 4
					break
				else
					v11 = Hub.CoinFarm.GetCachedRole(localPlayer)
					flag17 = Hub.CoinFarm.endRoundEnabled and v11 == nil

					if flag17 then
						startedAt = Hub.RoundState.startedAt
						flag17 = os.clock() - startedAt < 6
					end

					if flag17 then
						exitTo = 5
						break
					else
						flag18 = Hub.CoinFarm.endRoundEnabled and not Hub.CoinFarm.sheriffFlingCompleted and (v11 == "Murderer" or v11 == "Innocent")

						if flag18 then
							Hub.CoinFarm.StartRoundSheriffFling()
							sheriffFlingRunning = Hub.CoinFarm.sheriffFlingRunning or Hub.CoinFarm.sheriffFlingBlocking

							if sheriffFlingRunning then
								exitTo = 7
								break
							else
								if not Hub.CoinFarm.bagFull then
									Hub.CoinFarm.CheckBagFullGui()
								end

								if Hub.CoinFarm.bagFull then
									exitTo = 8
									break
								elseif not Hub.CoinFarm.IndexMap() then
									exitTo = 9
									break
								else
									Hub.CoinFarm.ranThisRound = true
									Hub.CoinFarm.SetPhase("Farming")
									character_ = localPlayer.Character
									humanoid = character_ and character_:FindFirstChildOfClass("Humanoid")
									humanoidRootPart = character_ and character_:FindFirstChild("HumanoidRootPart")
									flag10 = not humanoid or humanoid.Health <= 0
									flag11 = flag10 or not humanoidRootPart

									if flag11 then
										exitTo = 10
										break
									else
										currentCoin = Hub.CoinFarm.currentCoin
										flag12 = not currentCoin or not currentCoin.Parent or not Hub.CoinFarm.coins[currentCoin]
										flag13 = flag12 or not Hub.CoinFarm.IsCoinAvailable(currentCoin)

										if flag13 then
											if Hub.CoinFarm.escapeCoin == currentCoin then
												Hub.CoinFarm.escapeCoin = nil
												Hub.CoinFarm.escapeUnderActive = false
											end

											currentCoin = Hub.CoinFarm.GetNearestCoin(humanoidRootPart)
											Hub.CoinFarm.currentCoin = currentCoin
										end

										if not currentCoin then
											exitTo = 11
											break
										else
											flag7 = Hub.CoinFarm.escapeCoin == currentCoin
											getTargetPosition = Hub.CoinFarm.GetTargetPosition
											str = flag7 and "Under"
											v8 = str or nil
											position = humanoidRootPart.Position

											if not ((getTargetPosition(character_, humanoidRootPart, currentCoin, v8) - position).Magnitude > 2.25) then
												exitTo = 12
												break
											else
												Hub.CoinFarm.SetPhase("Farming")

												if not Hub.CoinFarm.MoveToCoin(character_, humanoidRootPart, currentCoin) then
													exitTo = 13
													break
												else
													flag14 = not currentCoin.Parent or Hub.CoinFarm.currentCoin ~= currentCoin

													if flag14 then
														alive = foxnameMM2Runtime.alive
														flag8 = alive and not isTerminated
													else
														flag15 = Hub.CoinFarm.position == "Under"
														v9 = flag15 or flag7

														if v9 then
															Hub.CoinFarm.EnableUnder(character_, true, flag7)
														end

														Hub.CoinFarm.SetPhase("Farming")
														v10 = Hub.CoinFarm.contactAttempts[currentCoin]
														n2 = v10 or 0
														n3 = n2 + 1
														Hub.CoinFarm.contactAttempts[currentCoin] = n3
														Hub.CoinFarm.TouchCoin(character_, humanoidRootPart, currentCoin)

														if flag7 then
															Hub.CoinFarm.escapeCoin = nil
															Hub.CoinFarm.escapeUnderActive = false

															if Hub.CoinFarm.position ~= "Under" then
																Hub.CoinFarm.DisableUnder()
															end
														end

														task.wait(0.3)
														flag16 = Hub.CoinFarm.currentCoin == currentCoin and Hub.CoinFarm.coins[currentCoin]

														if flag16 then
															if not (n3 >= 2) then
																alive = foxnameMM2Runtime.alive
																flag8 = alive and not isTerminated
															else
																Hub.CoinFarm.retryUntil[currentCoin] = os.clock() + 1.5
																Hub.CoinFarm.contactAttempts[currentCoin] = nil
																Hub.CoinFarm.currentCoin = nil

																if Hub.CoinFarm.escapeCoin ~= currentCoin then
																	alive = foxnameMM2Runtime.alive
																	flag8 = alive and not isTerminated
																else
																	Hub.CoinFarm.escapeCoin = nil
																	Hub.CoinFarm.escapeUnderActive = false
																	alive = foxnameMM2Runtime.alive
																	flag8 = alive and not isTerminated
																end
															end
														else
															alive = foxnameMM2Runtime.alive
															flag8 = alive and not isTerminated
														end
													end
												end
											end
										end
									end
								end
							end
						else
							exitTo = 6
							break
						end
					end
				end
			end
		end

		if exitTo == 1 then
			task.wait(0.2)
			continue
		end

		if exitTo == 2 then
			Hub.CoinFarm.CancelTween()
			Hub.CoinFarm.DisableUnder()
			Hub.CoinFarm.currentCoin = nil
			task.wait(0.1)
			continue
		end

		if exitTo == 3 then
			Hub.CoinFarm.CancelTween()
			Hub.CoinFarm.DisableUnder()
			local serverHopLowPlayers = Hub.CoinFarm.serverHopLowPlayers

			if serverHopLowPlayers then
				local serverHopPlayerThreshold = Hub.CoinFarm.serverHopPlayerThreshold
				serverHopLowPlayers = #Players:GetPlayers() <= serverHopPlayerThreshold
			end

			if serverHopLowPlayers and type(Hub.CoinFarm.StartLowPlayerServerHop) == "function" and Hub.CoinFarm.StartLowPlayerServerHop() or Hub.CoinFarm.serverHopRunning then
				task.wait(1)
			else
				Hub.CoinFarm.SetPhase("Waiting for round")
				task.wait(0.2)
			end

			continue
		end

		if exitTo == 4 then
			Hub.CoinFarm.CancelTween()
			Hub.CoinFarm.DisableUnder()
			Hub.CoinFarm.currentCoin = nil
			Hub.CoinFarm.SetPhase("Waiting for round")
			task.wait(0.2)
			continue
		end

		if exitTo == 5 then
			Hub.CoinFarm.SetPhase("Waiting for role")
			task.wait(0.1)
			continue
		end

		if exitTo == 6 then
			if not Hub.CoinFarm.bagFull then
				Hub.CoinFarm.CheckBagFullGui()
			end

			if Hub.CoinFarm.bagFull then
				Hub.CoinFarm.CancelTween()
				Hub.CoinFarm.LeaveUnderSafely(nil, true)
				Hub.CoinFarm.currentCoin = nil
				flag9 = type(Hub.CoinFarm.StartXPFarmWait) == "function" and Hub.CoinFarm.StartXPFarmWait()

				if not flag9 then
					if Hub.CoinFarm.endRoundEnabled then
						Hub.CoinFarm.SetPhase("Coin bag full")
						Hub.CoinFarm.StartEndRoundAction()
					else
						Hub.CoinFarm.ResetAfterBagFull()
					end
				end

				task.wait(0.2)
			elseif not Hub.CoinFarm.IndexMap() then
				Hub.CoinFarm.SetPhase("Waiting for map")
				task.wait(0.2)
			else
				Hub.CoinFarm.ranThisRound = true
				Hub.CoinFarm.SetPhase("Farming")
				character_ = localPlayer.Character
				humanoid = character_ and character_:FindFirstChildOfClass("Humanoid")
				humanoidRootPart = character_ and character_:FindFirstChild("HumanoidRootPart")
				flag10 = not humanoid or humanoid.Health <= 0
				flag11 = flag10 or not humanoidRootPart

				if flag11 then
					humanoid = humanoid and humanoid.Health <= 0 and Hub.CoinFarm.endRoundEnabled and Hub.CoinFarm.ranThisRound and Hub.CoinFarm.GetCachedRole(localPlayer) ~= "Murderer"

					if humanoid then
						Hub.CoinFarm.endRoundDeathRequested = true
						Hub.CoinFarm.StartEndRoundAction()
					end

					Hub.CoinFarm.CancelTween()
					Hub.CoinFarm.DisableUnder()
					Hub.CoinFarm.currentCoin = nil
					Hub.CoinFarm.SetPhase("Waiting for respawn")
					task.wait(0.2)
				else
					currentCoin = Hub.CoinFarm.currentCoin
					flag12 = not currentCoin or not currentCoin.Parent or not Hub.CoinFarm.coins[currentCoin]
					flag13 = flag12 or not Hub.CoinFarm.IsCoinAvailable(currentCoin)

					if flag13 then
						if Hub.CoinFarm.escapeCoin == currentCoin then
							Hub.CoinFarm.escapeCoin = nil
							Hub.CoinFarm.escapeUnderActive = false
						end

						currentCoin = Hub.CoinFarm.GetNearestCoin(humanoidRootPart)
						Hub.CoinFarm.currentCoin = currentCoin
					end

					if not currentCoin then
						Hub.CoinFarm.DisableUnder()
						Hub.CoinFarm.SetPhase("Waiting for coin")
						task.wait(0.15)
					else
						flag7 = Hub.CoinFarm.escapeCoin == currentCoin
						getTargetPosition = Hub.CoinFarm.GetTargetPosition
						str = flag7 and "Under"
						v8 = str or nil
						position = humanoidRootPart.Position

						if not ((getTargetPosition(character_, humanoidRootPart, currentCoin, v8) - position).Magnitude > 2.25) then
							flag14 = not currentCoin.Parent or Hub.CoinFarm.currentCoin ~= currentCoin

							if not flag14 then
								flag15 = Hub.CoinFarm.position == "Under"
								v9 = flag15 or flag7

								if v9 then
									Hub.CoinFarm.EnableUnder(character_, true, flag7)
								end

								Hub.CoinFarm.SetPhase("Farming")
								v10 = Hub.CoinFarm.contactAttempts[currentCoin]
								n2 = v10 or 0
								n3 = n2 + 1
								Hub.CoinFarm.contactAttempts[currentCoin] = n3
								Hub.CoinFarm.TouchCoin(character_, humanoidRootPart, currentCoin)

								if flag7 then
									Hub.CoinFarm.escapeCoin = nil
									Hub.CoinFarm.escapeUnderActive = false

									if Hub.CoinFarm.position ~= "Under" then
										Hub.CoinFarm.DisableUnder()
									end
								end

								task.wait(0.3)
								flag16 = Hub.CoinFarm.currentCoin == currentCoin and Hub.CoinFarm.coins[currentCoin]

								if flag16 then
									if n3 >= 2 then
										Hub.CoinFarm.retryUntil[currentCoin] = os.clock() + 1.5
										Hub.CoinFarm.contactAttempts[currentCoin] = nil
										Hub.CoinFarm.currentCoin = nil

										if Hub.CoinFarm.escapeCoin == currentCoin then
											Hub.CoinFarm.escapeCoin = nil
											Hub.CoinFarm.escapeUnderActive = false
										end
									end
								end
							end
						else
							Hub.CoinFarm.SetPhase("Farming")

							if not Hub.CoinFarm.MoveToCoin(character_, humanoidRootPart, currentCoin) then
								if Hub.CoinFarm.currentCoin == currentCoin then
									Hub.CoinFarm.currentCoin = nil
								end

								task.wait(0.05)
							else
								flag14 = not currentCoin.Parent or Hub.CoinFarm.currentCoin ~= currentCoin

								if not flag14 then
									flag15 = Hub.CoinFarm.position == "Under"
									v9 = flag15 or flag7

									if v9 then
										Hub.CoinFarm.EnableUnder(character_, true, flag7)
									end

									Hub.CoinFarm.SetPhase("Farming")
									v10 = Hub.CoinFarm.contactAttempts[currentCoin]
									n2 = v10 or 0
									n3 = n2 + 1
									Hub.CoinFarm.contactAttempts[currentCoin] = n3
									Hub.CoinFarm.TouchCoin(character_, humanoidRootPart, currentCoin)

									if flag7 then
										Hub.CoinFarm.escapeCoin = nil
										Hub.CoinFarm.escapeUnderActive = false

										if Hub.CoinFarm.position ~= "Under" then
											Hub.CoinFarm.DisableUnder()
										end
									end

									task.wait(0.3)
									flag16 = Hub.CoinFarm.currentCoin == currentCoin and Hub.CoinFarm.coins[currentCoin]

									if flag16 then
										if n3 >= 2 then
											Hub.CoinFarm.retryUntil[currentCoin] = os.clock() + 1.5
											Hub.CoinFarm.contactAttempts[currentCoin] = nil
											Hub.CoinFarm.currentCoin = nil

											if Hub.CoinFarm.escapeCoin == currentCoin then
												Hub.CoinFarm.escapeCoin = nil
												Hub.CoinFarm.escapeUnderActive = false
											end
										end
									end
								end
							end
						end
					end
				end
			end

			continue
		end

		if exitTo == 7 then
			Hub.CoinFarm.CancelTween()
			Hub.CoinFarm.DisableUnder()
			Hub.CoinFarm.currentCoin = nil
			task.wait(0.1)
			continue
		end

		if exitTo == 8 then
			Hub.CoinFarm.CancelTween()
			Hub.CoinFarm.LeaveUnderSafely(nil, true)
			Hub.CoinFarm.currentCoin = nil
			flag9 = type(Hub.CoinFarm.StartXPFarmWait) == "function" and Hub.CoinFarm.StartXPFarmWait()

			if not flag9 then
				if Hub.CoinFarm.endRoundEnabled then
					Hub.CoinFarm.SetPhase("Coin bag full")
					Hub.CoinFarm.StartEndRoundAction()
				else
					Hub.CoinFarm.ResetAfterBagFull()
				end
			end

			task.wait(0.2)
			continue
		end

		if exitTo == 9 then
			Hub.CoinFarm.SetPhase("Waiting for map")
			task.wait(0.2)
			continue
		end

		if exitTo == 10 then
			humanoid = humanoid and humanoid.Health <= 0 and Hub.CoinFarm.endRoundEnabled and Hub.CoinFarm.ranThisRound and Hub.CoinFarm.GetCachedRole(localPlayer) ~= "Murderer"

			if humanoid then
				Hub.CoinFarm.endRoundDeathRequested = true
				Hub.CoinFarm.StartEndRoundAction()
			end

			Hub.CoinFarm.CancelTween()
			Hub.CoinFarm.DisableUnder()
			Hub.CoinFarm.currentCoin = nil
			Hub.CoinFarm.SetPhase("Waiting for respawn")
			task.wait(0.2)
			continue
		end

		if exitTo == 11 then
			Hub.CoinFarm.DisableUnder()
			Hub.CoinFarm.SetPhase("Waiting for coin")
			task.wait(0.15)
			continue
		end

		if exitTo == 12 then
			flag14 = not currentCoin.Parent or Hub.CoinFarm.currentCoin ~= currentCoin
			if flag14 then
				continue
			end
			flag15 = Hub.CoinFarm.position == "Under"
			v9 = flag15 or flag7

			if v9 then
				Hub.CoinFarm.EnableUnder(character_, true, flag7)
			end

			Hub.CoinFarm.SetPhase("Farming")
			v10 = Hub.CoinFarm.contactAttempts[currentCoin]
			n2 = v10 or 0
			n3 = n2 + 1
			Hub.CoinFarm.contactAttempts[currentCoin] = n3
			Hub.CoinFarm.TouchCoin(character_, humanoidRootPart, currentCoin)

			if flag7 then
				Hub.CoinFarm.escapeCoin = nil
				Hub.CoinFarm.escapeUnderActive = false

				if Hub.CoinFarm.position ~= "Under" then
					Hub.CoinFarm.DisableUnder()
				end
			end

			task.wait(0.3)
			flag16 = Hub.CoinFarm.currentCoin == currentCoin and Hub.CoinFarm.coins[currentCoin]
			if not flag16 then
				continue
			end

			if not (n3 >= 2) then
				continue
			end
			Hub.CoinFarm.retryUntil[currentCoin] = os.clock() + 1.5
			Hub.CoinFarm.contactAttempts[currentCoin] = nil
			Hub.CoinFarm.currentCoin = nil
			if Hub.CoinFarm.escapeCoin ~= currentCoin then
				continue
			end
			Hub.CoinFarm.escapeCoin = nil
			Hub.CoinFarm.escapeUnderActive = false
			continue
		end

		if exitTo == 13 then
			if Hub.CoinFarm.currentCoin == currentCoin then
				Hub.CoinFarm.currentCoin = nil
			end

			task.wait(0.05)
			continue
		end

		if exitTo == 14 then
			local character_2 = localPlayer.Character
			character_2 = character_2 and character_2:FindFirstChild("HumanoidRootPart")
			local v11 = Hub.CoinFarm.GetNearbyMurderer(character_2)

			if v11 then
				Hub.CoinFarm.EscapeMurderer(character_2, v11)
			end

			Hub.CoinFarm.CancelTween()
			Hub.CoinFarm.DisableUnder()
			Hub.CoinFarm.SetPhase("Waiting for coins")
			task.wait(0.2)
			continue
		end

		if exitTo == 15 then
			Hub.CoinFarm.CancelTween()
			Hub.CoinFarm.DisableUnder()
			Hub.CoinFarm.currentCoin = nil
			Hub.CoinFarm.SetPhase("Waiting for round")
			task.wait(0.2)
			continue
		end

		if exitTo == 16 then
			Hub.CoinFarm.SetPhase("Waiting for role")
			task.wait(0.1)
			continue
		end

		if exitTo == 17 then
			Hub.CoinFarm.CancelTween()
			Hub.CoinFarm.LeaveUnderSafely(nil, true)
			Hub.CoinFarm.currentCoin = nil
			flag9 = type(Hub.CoinFarm.StartXPFarmWait) == "function" and Hub.CoinFarm.StartXPFarmWait()

			if not flag9 then
				if Hub.CoinFarm.endRoundEnabled then
					Hub.CoinFarm.SetPhase("Coin bag full")
					Hub.CoinFarm.StartEndRoundAction()
				else
					Hub.CoinFarm.ResetAfterBagFull()
				end
			end

			task.wait(0.2)
			continue
		end

		if exitTo == 18 then
			Hub.CoinFarm.SetPhase("Waiting for map")
			task.wait(0.2)
			continue
		end

		if exitTo == 19 then
			humanoid = humanoid and humanoid.Health <= 0 and Hub.CoinFarm.endRoundEnabled and Hub.CoinFarm.ranThisRound and Hub.CoinFarm.GetCachedRole(localPlayer) ~= "Murderer"

			if humanoid then
				Hub.CoinFarm.endRoundDeathRequested = true
				Hub.CoinFarm.StartEndRoundAction()
			end

			Hub.CoinFarm.CancelTween()
			Hub.CoinFarm.DisableUnder()
			Hub.CoinFarm.currentCoin = nil
			Hub.CoinFarm.SetPhase("Waiting for respawn")
			task.wait(0.2)
			continue
		end

		if exitTo == 20 then
			Hub.CoinFarm.DisableUnder()
			Hub.CoinFarm.SetPhase("Waiting for coin")
			task.wait(0.15)
			continue
		end

		if exitTo == 21 then
			flag14 = not currentCoin.Parent or Hub.CoinFarm.currentCoin ~= currentCoin
			if flag14 then
				continue
			end
			flag15 = Hub.CoinFarm.position == "Under"
			v9 = flag15 or flag7

			if v9 then
				Hub.CoinFarm.EnableUnder(character_, true, flag7)
			end

			Hub.CoinFarm.SetPhase("Farming")
			v10 = Hub.CoinFarm.contactAttempts[currentCoin]
			n2 = v10 or 0
			n3 = n2 + 1
			Hub.CoinFarm.contactAttempts[currentCoin] = n3
			Hub.CoinFarm.TouchCoin(character_, humanoidRootPart, currentCoin)

			if flag7 then
				Hub.CoinFarm.escapeCoin = nil
				Hub.CoinFarm.escapeUnderActive = false

				if Hub.CoinFarm.position ~= "Under" then
					Hub.CoinFarm.DisableUnder()
				end
			end

			task.wait(0.3)
			flag16 = Hub.CoinFarm.currentCoin == currentCoin and Hub.CoinFarm.coins[currentCoin]
			if not flag16 then
				continue
			end

			if not (n3 >= 2) then
				continue
			end
			Hub.CoinFarm.retryUntil[currentCoin] = os.clock() + 1.5
			Hub.CoinFarm.contactAttempts[currentCoin] = nil
			Hub.CoinFarm.currentCoin = nil
			if Hub.CoinFarm.escapeCoin ~= currentCoin then
				continue
			end
			Hub.CoinFarm.escapeCoin = nil
			Hub.CoinFarm.escapeUnderActive = false
			continue
		end

		if exitTo == 22 then
			if Hub.CoinFarm.currentCoin == currentCoin then
				Hub.CoinFarm.currentCoin = nil
			end

			task.wait(0.05)
			continue
		end

		if exitTo == 23 then
			Hub.CoinFarm.CancelTween()
			Hub.CoinFarm.DisableUnder()
			Hub.CoinFarm.currentCoin = nil
			task.wait(0.1)
			continue
		end

		break
	end

	Hub.CoinFarm.workerRunning = false
end

Hub.CoinFarm.FindOwnedCoinAmountLabels = function()
	local function fn12(arg)
		if not arg then
			return nil
		end
		local title = arg:FindFirstChild("Title")
		local container = title and title:FindFirstChild("Container")
		container = container and container:FindFirstChild("Coins") or title and title:FindFirstChild("Coins")
		container = container and container:FindFirstChild("Container")
		local amount = container and container:FindFirstChild("Amount")
		if amount and amount:IsA("TextLabel") and amount.Visible then
			return amount
		end
		amount = amount and amount:FindFirstChild("Amount")
		if amount and amount:IsA("TextLabel") and amount.Visible then
			return amount
		end
		return nil
	end

	local function fn13(arg)
		arg = arg and arg:FindFirstChild("CrossPlatform")
		arg = arg and arg:FindFirstChild("Shop")
		if not arg then
			return nil
		end
		local small = arg:FindFirstChild("Small")
		return fn12(small and small:FindFirstChild("Container")), (fn12(arg:FindFirstChild("Medium")))
	end

	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
	local CoreGui = nil

	pcall(function()
		CoreGui = game:GetService("CoreGui")
	end)

	local v8, v9 = fn13(playerGui)
	if v8 or v9 then
		return v8, v9
	end
	return fn13(CoreGui)
end

Hub.CoinFarm.ParseOwnedCoinText = function(arg)
	if not arg or not arg.Parent or not arg:IsA("TextLabel") or not arg.Visible then
		return nil
	end
	local match = tostring(arg.Text or ""):match("%d[%d%.,]*")
	if not match then
		return nil
	end
	local v8 = tonumber
	local str = match:gsub("[^%d]", "")
	local v9 = v8(str)
	return v9 and math.max(0, math.floor(v9)) or nil
end

Hub.CoinFarm.FindOwnedCoinAmountLabel = function(arg)
	local v8, flag7 = Hub.CoinFarm.FindOwnedCoinAmountLabels()
	local v9 = Hub.CoinFarm.ParseOwnedCoinText(v8)
	local v10 = Hub.CoinFarm.ParseOwnedCoinText(flag7)
	if v9 == 43000 and v10 ~= nil and v10 ~= 43000 then
		return flag7
	end

	if v10 == 43000 and v9 ~= nil and v9 ~= 43000 then
		return v8
	end
	flag7 = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and (v8 or flag7) or flag7 or v8

	if v9 == 43000 and v10 == 43000 then
		local num = type(arg) == "table" and tonumber(arg.Coins) or nil
		if num and math.floor(num) ~= 43000 then
			return nil
		end
	end

	return flag7
end

Hub.CoinFarm.GetOwnedCoinCount = function(arg)
	local ownedCoinAmountLabel = Hub.CoinFarm.ownedCoinAmountLabel

	if not ownedCoinAmountLabel or not ownedCoinAmountLabel.Parent or not ownedCoinAmountLabel:IsA("TextLabel") or not ownedCoinAmountLabel.Visible then
		ownedCoinAmountLabel = Hub.CoinFarm.FindOwnedCoinAmountLabel(arg)
		Hub.CoinFarm.ownedCoinAmountLabel = ownedCoinAmountLabel
	end

	if ownedCoinAmountLabel then
		local v8 = Hub.CoinFarm.ParseOwnedCoinText(ownedCoinAmountLabel)

		if v8 == 43000 then
			local v9 = Hub.CoinFarm.FindOwnedCoinAmountLabel(arg)
			Hub.CoinFarm.ownedCoinAmountLabel = v9
			v8 = Hub.CoinFarm.ParseOwnedCoinText(v9)
		end

		if v8 then
			return math.max(0, math.floor(v8))
		end
		Hub.CoinFarm.ownedCoinAmountLabel = nil
	end

	local num = type(arg) == "table" and tonumber(arg.Coins) or nil
	return num and math.max(0, math.floor(num)) or 0
end

Hub.CoinFarm.RefreshBlackScreen = function(text)
	local blackScreenLabels = Hub.CoinFarm.blackScreenLabels
	local blackScreenGui = Hub.CoinFarm.blackScreenGui
	if not Hub.CoinFarm.blackScreenEnabled or not blackScreenGui or not blackScreenGui.Parent or type(blackScreenLabels) ~= "table" or not blackScreenLabels.status then
		return
	end

	if text ~= "Innocent" and text ~= "Sheriff" and text ~= "Murderer" and text ~= "Hero" then
		text = type(Hub.CoinFarm.GetCachedRole) == "function" and Hub.CoinFarm.GetCachedRole(localPlayer) or nil
	end

	if text ~= "Innocent" and text ~= "Sheriff" and text ~= "Murderer" and text ~= "Hero" then
		text = "Unknown"
	end

	local n2 = tonumber(Hub.CoinFarm.bagCurrentValue) or tonumber(Hub.CoinFarm.lastBagCount) or tonumber(Hub.CoinFarm.GetBagCount()) or 0
	local n3 = tonumber(Hub.CoinFarm.bagMaximum) or 0
	local n4 = math.max(0, math.floor(n2))
	local n5 = math.max(0, math.floor(n3))
	local n6 = tonumber(Hub.CoinFarm.sessionStartedAt) or 0
	local n7 = n6 > 0 and math.max(0, os.clock() - n6) or 0
	local n8 = math.floor(n7 / 60)
	local n9 = math.floor(n7 % 60)
	local v8, v9 = Hub.AutoPrestige.GetData()
	local n10 = type(v8) == "table" and tonumber(v8.NewXP) or 0
	local v10 = Hub.CoinFarm.GetOwnedCoinCount(v8)
	local n11 = math.max(tonumber(localPlayer:GetAttribute("Prestige")) or 0, type(v8) == "table" and tonumber(v8.Prestige) or nil or 0)
	local flag7 = type(v9) == "table" and type(v9.GetLevel) == "function"
	local n12 = 1

	if flag7 then
		local ok, result = pcall(v9.GetLevel, n10)

		if ok then
			local numericResult = tonumber(result)
			if numericResult then
				n12 = math.max(1, math.floor(numericResult))
			end
		end
	end

	local num = tonumber(Hub.AutoPrestige.blackScreenPrestige)

	if num and n11 > num then
		Hub.AutoPrestige.blackScreenPrestigeResetPending = true
	end

	if Hub.AutoPrestige.blackScreenPrestigeResetPending and n12 >= 100 then
		n12 = 1
	elseif n12 < 100 then
		Hub.AutoPrestige.blackScreenPrestigeResetPending = false
	end

	Hub.AutoPrestige.blackScreenPrestige = math.max(num or 0, n11)

	local function fn12(arg)
		return tostring(math.max(0, math.floor(tonumber(arg) or 0))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
	end

	local text2 = tostring(Hub.CoinFarm.phase)
	local text3 = n5 > 0 and tostring(n4) .. " / " .. tostring(n5) or tostring(n4)
	local text4 = fn12(Hub.CoinFarm.totalEarnedXP) .. " XP"
	local v11 = fn12(Hub.CoinFarm.totalCollected)
	local v12 = fn12(v10)
	local text5 = string.format("%02d:%02d", n8, n9)
	local n13 = n5 > 0 and math.clamp(n4 / n5, 0, 1) or 0

	if blackScreenLabels.status.Text ~= text2 then
		blackScreenLabels.status.Text = text2
	end

	if blackScreenLabels.role.Text ~= text then
		blackScreenLabels.role.Text = text
	end

	if blackScreenLabels.bag.Text ~= text3 then
		blackScreenLabels.bag.Text = text3
	end

	if blackScreenLabels.level.Text ~= tostring(n12) then
		blackScreenLabels.level.Text = tostring(n12)
	end

	if blackScreenLabels.prestige.Text ~= tostring(n11) then
		blackScreenLabels.prestige.Text = tostring(n11)
	end

	if blackScreenLabels.earnedXP.Text ~= text4 then
		blackScreenLabels.earnedXP.Text = text4
	end

	if blackScreenLabels.collectedCoins.Text ~= v11 then
		blackScreenLabels.collectedCoins.Text = v11
	end

	if blackScreenLabels.totalCoins.Text ~= v12 then
		blackScreenLabels.totalCoins.Text = v12
	end

	if blackScreenLabels.session.Text ~= text5 then
		blackScreenLabels.session.Text = text5
	end

	if math.abs(blackScreenLabels.progress.Size.X.Scale - n13) > 0.001 then
		blackScreenLabels.progress.Size = UDim2.fromScale(n13, 1)
	end
end

Hub.CoinFarm.SetBlackScreen = function(arg, arg2)
	local blackScreenEnabled = arg and true or false
	Hub.CoinFarm.blackScreenEnabled = blackScreenEnabled
	local coinFarm = Hub.CoinFarm
	coinFarm.blackScreenUpdateGeneration = coinFarm.blackScreenUpdateGeneration + 1
	local blackScreenUpdateGeneration = Hub.CoinFarm.blackScreenUpdateGeneration
	local blackScreenGui = Hub.CoinFarm.blackScreenGui

	if blackScreenGui and blackScreenGui.Parent then
		blackScreenGui:Destroy()
	end

	Hub.CoinFarm.blackScreenGui = nil
	table.clear(Hub.CoinFarm.blackScreenLabels)
	if not blackScreenEnabled then
		return true
	end

	if not Hub.CoinFarm.enabled or not Hub.RoundState.active or not Hub.CoinFarm.IsLocalPlayerInRound() then
		return true
	end
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "FoxnameCoinFarmBlackScreen_" .. sessionId
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 2147483647
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	local textButton = Instance.new("TextButton")
	textButton.Name = "Cover"
	textButton.Size = UDim2.fromScale(1, 1)
	textButton.BackgroundColor3 = Color3.new(0, 0, 0)
	textButton.BackgroundTransparency = 0
	textButton.BorderSizePixel = 0
	textButton.AutoButtonColor = false
	textButton.Text = ""
	textButton.ZIndex = 1000000
	textButton.Parent = screenGui
	local frame = Instance.new("Frame")
	frame.Name = "FarmCard"
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromScale(0.5, 0.5)
	frame.Size = UDim2.new(0.88, 0, 0, 518)
	frame.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
	frame.BorderSizePixel = 0
	frame.ClipsDescendants = true
	frame.ZIndex = textButton.ZIndex + 1
	frame.Parent = textButton
	local uiSizeConstraint = Instance.new("UISizeConstraint")
	uiSizeConstraint.MinSize = Vector2.new(290, 518)
	uiSizeConstraint.MaxSize = Vector2.new(430, 518)
	uiSizeConstraint.Parent = frame
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = frame
	local connection = nil

	local function fn12()
		local currentCamera2 = workspace.CurrentCamera
		currentCamera2 = currentCamera2 and currentCamera2.ViewportSize
		if not currentCamera2 or currentCamera2.X <= 0 or currentCamera2.Y <= 0 then
			uiScale.Scale = 1
			return
		end
		local n2 = (currentCamera2.Y - 24) / 518
		uiScale.Scale = math.clamp(math.min((currentCamera2.X - 24) / math.clamp(currentCamera2.X * 0.88, 290, 430), n2), 0.55, 1)
	end

	fn12()

	if workspace.CurrentCamera then
		connection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fn12)
	end

	screenGui.Destroying:Once(function()
		if connection then
			connection:Disconnect()
			connection = nil
		end
	end)

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 20)
	uiCorner.Parent = frame
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(80, 28, 42)
	uiStroke.Transparency = 0.25
	uiStroke.Thickness = 1
	uiStroke.Parent = frame
	local frame2 = Instance.new("Frame")
	frame2.Name = "AccentClip"
	frame2.Position = UDim2.fromOffset(0, 0)
	frame2.Size = UDim2.new(1, 0, 0, 20)
	frame2.BackgroundTransparency = 1
	frame2.BorderSizePixel = 0
	frame2.ClipsDescendants = true
	frame2.ZIndex = frame.ZIndex + 1
	frame2.Parent = frame
	local frame3 = Instance.new("Frame")
	frame3.Name = "Accent"
	frame3.Position = UDim2.fromOffset(0, 0)
	frame3.Size = UDim2.new(1, 0, 0, 518)
	frame3.BackgroundTransparency = 1
	frame3.BorderSizePixel = 0
	frame3.ZIndex = frame2.ZIndex
	frame3.Parent = frame2
	local uiCorner2 = Instance.new("UICorner")
	uiCorner2.CornerRadius = UDim.new(0, 20)
	uiCorner2.Parent = frame3
	local uiStroke2 = Instance.new("UIStroke")
	uiStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke2.Color = Color3.new(1, 1, 1)
	uiStroke2.Thickness = 3
	uiStroke2.Transparency = 0
	uiStroke2.Parent = frame3
	local uiGradient = Instance.new("UIGradient")
	local colorSequence = ColorSequence.new
	local tbl7 = {}
	local v8 = ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 35, 74))
	local v9 = ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 90, 135))
	local new = ColorSequenceKeypoint.new
	local color = Color3.fromRGB
	tbl7[1] = v8
	tbl7[2] = v9

	do
		local values = table.pack(new(1, color(255, 35, 74)))
		table.move(values, 1, values.n, 3, tbl7)
	end

	uiGradient.Color = colorSequence(tbl7)
	uiGradient.Parent = uiStroke2
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "Icon"
	imageLabel.Position = UDim2.fromOffset(24, 25)
	imageLabel.Size = UDim2.fromOffset(42, 42)
	imageLabel.BackgroundColor3 = Color3.fromRGB(32, 10, 17)
	imageLabel.BorderSizePixel = 0
	imageLabel.Image = "rbxassetid://133245078123989"
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.ZIndex = frame.ZIndex + 1
	imageLabel.Parent = frame
	local uiCorner3 = Instance.new("UICorner")
	uiCorner3.CornerRadius = UDim.new(0, 12)
	uiCorner3.Parent = imageLabel

	local function createTextLabel(name, text, position, size, textSize, textColor3, font, textXAlignment)
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = name
		textLabel.Position = position
		textLabel.Size = size
		textLabel.BackgroundTransparency = 1
		textLabel.Text = text
		textLabel.TextColor3 = textColor3
		textLabel.TextSize = textSize
		textLabel.Font = font
		textLabel.TextXAlignment = textXAlignment or Enum.TextXAlignment.Left
		textLabel.TextYAlignment = Enum.TextYAlignment.Center
		textLabel.ZIndex = frame.ZIndex + 1
		textLabel.Parent = frame
		return textLabel
	end

	local gothamBold = Enum.Font.GothamBold
	createTextLabel("Title", "FOXNAME", UDim2.fromOffset(78, 24), UDim2.new(1, -102, 0, 24), 20, Color3.fromRGB(255, 244, 247), gothamBold)
	local gothamBold2 = Enum.Font.GothamBold
	createTextLabel("Subtitle", "AFK FARMING MODE", UDim2.fromOffset(78, 48), UDim2.new(1, -190, 0, 18), 11, Color3.fromRGB(255, 83, 122), gothamBold2)
	local gothamBold3 = Enum.Font.GothamBold
	local right = Enum.TextXAlignment.Right
	local Session = createTextLabel("Session", "00:00", UDim2.new(1, -98, 0, 48), UDim2.fromOffset(74, 18), 11, Color3.fromRGB(166, 166, 178), gothamBold3, right)
	local frame4 = Instance.new("Frame")
	frame4.Position = UDim2.fromOffset(24, 82)
	frame4.Size = UDim2.new(1, -48, 0, 48)
	frame4.BackgroundColor3 = Color3.fromRGB(18, 18, 23)
	frame4.BorderSizePixel = 0
	frame4.ZIndex = frame.ZIndex + 1
	frame4.Parent = frame
	local uiCorner4 = Instance.new("UICorner")
	uiCorner4.CornerRadius = UDim.new(0, 12)
	uiCorner4.Parent = frame4
	local frame5 = Instance.new("Frame")
	frame5.AnchorPoint = Vector2.new(0, 0.5)
	frame5.Position = UDim2.new(0, 14, 0.5, 0)
	frame5.Size = UDim2.fromOffset(8, 8)
	frame5.BackgroundColor3 = Color3.fromRGB(62, 224, 138)
	frame5.BorderSizePixel = 0
	frame5.ZIndex = frame4.ZIndex + 1
	frame5.Parent = frame4
	local uiCorner5 = Instance.new("UICorner")
	uiCorner5.CornerRadius = UDim.new(1, 0)
	uiCorner5.Parent = frame5
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Status"
	textLabel.Position = UDim2.fromOffset(32, 0)
	textLabel.Size = UDim2.new(1, -44, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "Waiting for round"
	textLabel.TextColor3 = Color3.fromRGB(235, 235, 240)
	textLabel.TextSize = 14
	textLabel.Font = Enum.Font.GothamMedium
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.ZIndex = frame4.ZIndex + 1
	textLabel.Parent = frame4

	local function createTextLabel2(arg3, text, arg4, arg5)
		local frame6 = Instance.new("Frame")
		frame6.Name = arg3 .. "Card"
		frame6.Position = UDim2.new(arg4, arg4 == 0 and 24 or 4, 0, arg5)
		frame6.Size = UDim2.new(0.5, -28, 0, 62)
		frame6.BackgroundColor3 = Color3.fromRGB(15, 15, 19)
		frame6.BorderSizePixel = 0
		frame6.ZIndex = frame.ZIndex + 1
		frame6.Parent = frame
		local uiCorner6 = Instance.new("UICorner")
		uiCorner6.CornerRadius = UDim.new(0, 12)
		uiCorner6.Parent = frame6
		local textLabel2 = Instance.new("TextLabel")
		textLabel2.Position = UDim2.fromOffset(12, 7)
		textLabel2.Size = UDim2.new(1, -24, 0, 18)
		textLabel2.BackgroundTransparency = 1
		textLabel2.Text = text
		textLabel2.TextColor3 = Color3.fromRGB(126, 126, 138)
		textLabel2.TextSize = 10
		textLabel2.Font = Enum.Font.GothamBold
		textLabel2.TextXAlignment = Enum.TextXAlignment.Left
		textLabel2.ZIndex = frame6.ZIndex + 1
		textLabel2.Parent = frame6
		local textLabel3 = Instance.new("TextLabel")
		textLabel3.Position = UDim2.fromOffset(12, 25)
		textLabel3.Size = UDim2.new(1, -24, 0, 28)
		textLabel3.BackgroundTransparency = 1
		textLabel3.Text = "--"
		textLabel3.TextColor3 = Color3.fromRGB(245, 245, 248)
		textLabel3.TextSize = 17
		textLabel3.Font = Enum.Font.GothamBold
		textLabel3.TextXAlignment = Enum.TextXAlignment.Left
		textLabel3.TextScaled = true
		textLabel3.ZIndex = frame6.ZIndex + 1
		textLabel3.Parent = frame6
		local uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
		uiTextSizeConstraint.MinTextSize = 10
		uiTextSizeConstraint.MaxTextSize = 17
		uiTextSizeConstraint.Parent = textLabel3
		return textLabel3
	end

	local Role = createTextLabel2("Role", "ROLE", 0, 140)
	local Bag = createTextLabel2("Bag", "COIN BAG", 0.5, 140)
	local Level = createTextLabel2("Level", "LEVEL", 0, 210)
	local Prestige = createTextLabel2("Prestige", "PRESTIGE", 0.5, 210)
	local EarnedXP = createTextLabel2("EarnedXP", "EARNED XP", 0, 280)
	local CollectedCoins = createTextLabel2("CollectedCoins", "COLLECTED COINS", 0.5, 280)
	local TotalCoins = createTextLabel2("TotalCoins", "OWNED COINS", 0, 350)
	TotalCoins.Parent.Size = UDim2.new(1, -48, 0, 62)
	local frame6 = Instance.new("Frame")
	frame6.Name = "ProgressTrack"
	frame6.Position = UDim2.new(0, 24, 0, 426)
	frame6.Size = UDim2.new(1, -48, 0, 5)
	frame6.BackgroundColor3 = Color3.fromRGB(29, 29, 35)
	frame6.BorderSizePixel = 0
	frame6.ZIndex = frame.ZIndex + 1
	frame6.Parent = frame
	local uiCorner6 = Instance.new("UICorner")
	uiCorner6.CornerRadius = UDim.new(1, 0)
	uiCorner6.Parent = frame6
	local frame7 = Instance.new("Frame")
	frame7.Name = "Progress"
	frame7.Size = UDim2.fromScale(0, 1)
	frame7.BackgroundColor3 = Color3.fromRGB(255, 55, 98)
	frame7.BorderSizePixel = 0
	frame7.ZIndex = frame6.ZIndex + 1
	frame7.Parent = frame6
	local uiCorner7 = Instance.new("UICorner")
	uiCorner7.CornerRadius = UDim.new(1, 0)
	uiCorner7.Parent = frame7

	local function createTextButton(name, text, position, backgroundColor3)
		local textButton2 = Instance.new("TextButton")
		textButton2.Name = name
		textButton2.Position = position
		textButton2.Size = UDim2.new(0.5, -30, 0, 42)
		textButton2.BackgroundColor3 = backgroundColor3
		textButton2.BorderSizePixel = 0
		textButton2.AutoButtonColor = true
		textButton2.Text = text
		textButton2.TextColor3 = Color3.fromRGB(248, 248, 251)
		textButton2.TextSize = 13
		textButton2.Font = Enum.Font.GothamBold
		textButton2.ZIndex = frame.ZIndex + 3
		textButton2.Parent = frame
		local uiCorner8 = Instance.new("UICorner")
		uiCorner8.CornerRadius = UDim.new(0, 12)
		uiCorner8.Parent = textButton2
		return textButton2
	end

	local color2 = Color3.fromRGB
	local ExitBlackScreen = createTextButton("ExitBlackScreen", "Exit Black Screen", UDim2.new(0, 24, 0, 452), color2(119, 27, 48))
	local color3 = Color3.fromRGB
	local HideBlackScreen = createTextButton("HideBlackScreen", "Hide Black Screen", UDim2.new(0.5, 6, 0, 452), color3(28, 28, 35))
	local textButton2 = Instance.new("TextButton")
	textButton2.Name = "ShowBlackScreen"
	textButton2.AnchorPoint = Vector2.new(0.5, 0)
	textButton2.Position = UDim2.new(0.5, 0, 0, 54)
	textButton2.Size = UDim2.fromOffset(190, 44)
	textButton2.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	textButton2.BorderSizePixel = 0
	textButton2.AutoButtonColor = true
	textButton2.Text = "Show Black Screen"
	textButton2.TextColor3 = Color3.fromRGB(255, 235, 241)
	textButton2.TextSize = 13
	textButton2.Font = Enum.Font.GothamBold
	textButton2.Visible = false
	textButton2.ZIndex = textButton.ZIndex + 10
	textButton2.Parent = screenGui
	local uiCorner8 = Instance.new("UICorner")
	uiCorner8.CornerRadius = UDim.new(0, 12)
	uiCorner8.Parent = textButton2
	local uiStroke3 = Instance.new("UIStroke")
	uiStroke3.Color = Color3.fromRGB(255, 55, 98)
	uiStroke3.Transparency = 0.2
	uiStroke3.Thickness = 1
	uiStroke3.Parent = textButton2

	ExitBlackScreen.Activated:Connect(function()
		local blackScreenControl = Hub.CoinFarm.blackScreenControl

		if blackScreenControl and type(blackScreenControl.Set) == "function" then
			pcall(function()
				blackScreenControl:Set(false)
			end)
		end

		Hub.CoinFarm.SetBlackScreen(false, true)
	end)

	HideBlackScreen.Activated:Connect(function()
		textButton.Visible = false
		textButton2.Visible = true
	end)

	textButton2.Activated:Connect(function()
		textButton2.Visible = false
		textButton.Visible = true
		Hub.CoinFarm.RefreshBlackScreen()
	end)

	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

	if type(gethui) == "function" then
		local ok, result = pcall(gethui)

		if ok and result then
			playerGui = result
		end
	end

	if not playerGui then
		if not arg2 then
			WindUI:Notify({ Title = "Black Screen", Content = "UI parent is unavailable", Icon = "x", Duration = 2 })
		end

		screenGui:Destroy()
		Hub.CoinFarm.blackScreenEnabled = false
		return false
	end

	screenGui.Parent = playerGui
	Hub.CoinFarm.blackScreenGui = screenGui
	Hub.CoinFarm.blackScreenStartedAt = os.clock()

	Hub.CoinFarm.blackScreenLabels = {
		status = textLabel,
		role = Role,
		bag = Bag,
		level = Level,
		prestige = Prestige,
		earnedXP = EarnedXP,
		collectedCoins = CollectedCoins,
		totalCoins = TotalCoins,
		session = Session,
		progress = frame7,
	}

	Hub.CoinFarm.RefreshBlackScreen()

	task.spawn(function()
		while foxnameMM2Runtime.alive and not isTerminated and Hub.CoinFarm.blackScreenEnabled and Hub.CoinFarm.blackScreenUpdateGeneration == blackScreenUpdateGeneration and screenGui.Parent do
			task.wait(1)
			Hub.CoinFarm.RefreshBlackScreen()
		end
	end)

	return true
end

Hub.CoinFarm.Set3DRenderingDisabled = function(arg, arg2)
	local disable3DRendering = arg and true or false

	if not pcall(function()
		RunService:Set3dRenderingEnabled(not disable3DRendering)
	end) then
		Hub.CoinFarm.disable3DRendering = false

		if not arg2 then
			WindUI:Notify({
				Title = "Disable 3D Rendering",
				Content = "This executor does not support changing 3D rendering.",
				Icon = "triangle-alert",
				Duration = 3,
			})
		end

		return false
	end

	Hub.CoinFarm.disable3DRendering = disable3DRendering
	return true
end

Hub.CoinFarm.SetEnabled = function(arg)
	local enabled = Hub.CoinFarm.enabled
	local indexedMap = Hub.CoinFarm.indexedMap or Hub.RoundState.currentMapInstance

	if enabled and not arg then
		Hub.CoinFarm.SyncEarnedXP()
	end

	Hub.CoinFarm.enabled = arg and true or false

	if Hub.CoinFarm.enabled and not enabled then
		Hub.CoinFarm.sessionStartedAt = os.clock() - math.max(0, tonumber(Hub.CoinFarm.resumedSessionElapsed) or 0)
		Hub.CoinFarm.serverHopTimerStartedAt = os.clock()
		Hub.CoinFarm.resumedSessionElapsed = 0
		Hub.CoinFarm.resetRequestedForBag = false
		Hub.CoinFarm.bagCurrentValue = nil
		Hub.CoinFarm.lastBagCount = nil
		Hub.CoinFarm.lastObservedXP = Hub.CoinFarm.GetCurrentXP()
		local v8 = Hub.CoinFarm.GetBagCount()

		if type(v8) == "number" then
			Hub.CoinFarm.lastBagCount = math.max(0, math.floor(v8))
		end

		Hub.CoinFarm.bagWebhookSent = false
		local coinFarm = Hub.CoinFarm
		coinFarm.webhookGeneration = coinFarm.webhookGeneration + 1
		local webhookGeneration = Hub.CoinFarm.webhookGeneration

		if type(Hub.CoinFarm.SendWebhook) == "function" then
			Hub.CoinFarm.SendWebhook("Started")
		end

		task.spawn(function()
			while foxnameMM2Runtime.alive and not isTerminated and Hub.CoinFarm.enabled and Hub.CoinFarm.webhookGeneration == webhookGeneration do
				task.wait(900)

				if foxnameMM2Runtime.alive and not isTerminated and Hub.CoinFarm.enabled and Hub.CoinFarm.webhookGeneration == webhookGeneration then
					if type(Hub.CoinFarm.SendWebhook) == "function" then
						Hub.CoinFarm.SendWebhook("15 Minute Update")
					end
				end
			end
		end)
	elseif not Hub.CoinFarm.enabled then
		if enabled then
			if type(Hub.CoinFarm.SendWebhook) == "function" then
				Hub.CoinFarm.SendWebhook("Stopped")
			end
		end

		local coinFarm = Hub.CoinFarm
		coinFarm.webhookGeneration = coinFarm.webhookGeneration + 1
		Hub.CoinFarm.sessionStartedAt = 0
		Hub.CoinFarm.serverHopTimerStartedAt = 0
		Hub.CoinFarm.lastObservedXP = nil
	end

	Hub.CoinFarm.RefreshBlackScreen()

	if Hub.SetCoinFarmAutoGunTouch then
		Hub.SetCoinFarmAutoGunTouch(Hub.CoinFarm.enabled)
	end

	if Hub.SetXPFarmTimerForced then
		Hub.SetXPFarmTimerForced(Hub.CoinFarm.enabled)
	end

	if type(Hub.SetCoinFarmAntiFling) == "function" then
		Hub.SetCoinFarmAntiFling(Hub.CoinFarm.enabled)
	end

	local coinFarm = Hub.CoinFarm
	coinFarm.generation = coinFarm.generation + 1
	Hub.CoinFarm.CancelXPFarmWait()
	Hub.CoinFarm.CancelEndRoundRespawnRetry()
	Hub.CoinFarm.CancelTween()
	Hub.CoinFarm.currentCoin = nil
	Hub.CoinFarm.escapeCoin = nil
	Hub.CoinFarm.escapeUnderActive = false

	if not Hub.CoinFarm.enabled then
		local blackScreenGui = Hub.CoinFarm.blackScreenGui
		local coinFarm2 = Hub.CoinFarm
		coinFarm2.blackScreenUpdateGeneration = coinFarm2.blackScreenUpdateGeneration + 1

		if blackScreenGui and blackScreenGui.Parent then
			pcall(function()
				blackScreenGui:Destroy()
			end)
		end

		Hub.CoinFarm.blackScreenGui = nil
		table.clear(Hub.CoinFarm.blackScreenLabels)
		Hub.CoinFarm.RestoreCoinVisuals()
		Hub.CoinFarm.serverHopRunning = false
		local coinFarm3 = Hub.CoinFarm
		coinFarm3.endRoundGeneration = coinFarm3.endRoundGeneration + 1
		Hub.CoinFarm.endRoundRunning = false
		Hub.CoinFarm.sheriffFlingRunning = false
		Hub.CoinFarm.sheriffFlingBlocking = false
		Hub.CoinFarm.sheriffFlingCompleted = false

		if enabled then
			if Hub.RoundState.active and Hub.CoinFarm.IsLocalPlayerInRound() then
				if not Hub.CoinFarm.LeaveUnderSafely(indexedMap, true) then
					Hub.CoinFarm.TeleportToMapSpawn(indexedMap)
				end
			else
				Hub.CoinFarm.LeaveUnderSafely(indexedMap, false)
			end
		else
			Hub.CoinFarm.DisableUnder()
		end

		Hub.CoinFarm.DisconnectMap()
		Hub.CoinFarm.SetPhase("Disabled")
		return
	end

	if Hub.RoundState.active and Hub.RoundState.coinsReady then
		Hub.CoinFarm.IndexMap()
	else
		Hub.CoinFarm.SetPhase("Waiting for round")
	end

	Hub.CoinFarm.SetBlackScreen(Hub.CoinFarm.blackScreenEnabled, true)

	if Hub.RoundState.active and Hub.CoinFarm.endRoundEnabled then
		Hub.CoinFarm.StartRoundSheriffFling()
	end

	task.spawn(Hub.CoinFarm.Worker)
end

Hub.CoinFarm.Destroy = function()
	Hub.CoinFarm.enabled = false
	Hub.CoinFarm.sessionStartedAt = 0
	Hub.CoinFarm.serverHopTimerStartedAt = 0
	Hub.CoinFarm.serverHopRunning = false
	Hub.CoinFarm.CancelXPFarmWait()
	Hub.CoinFarm.CancelEndRoundRespawnRetry()

	if Hub.SetCoinFarmAutoGunTouch then
		Hub.SetCoinFarmAutoGunTouch(false)
	end

	if Hub.SetXPFarmTimerForced then
		Hub.SetXPFarmTimerForced(false)
	end

	if type(Hub.SetCoinFarmAntiFling) == "function" then
		Hub.SetCoinFarmAntiFling(false)
	end

	local coinFarm = Hub.CoinFarm
	coinFarm.generation = coinFarm.generation + 1
	local coinFarm2 = Hub.CoinFarm
	coinFarm2.endRoundGeneration = coinFarm2.endRoundGeneration + 1
	Hub.CoinFarm.endRoundRunning = false
	Hub.CoinFarm.sheriffFlingRunning = false
	Hub.CoinFarm.sheriffFlingBlocking = false
	Hub.CoinFarm.sheriffFlingCompleted = false
	Hub.CoinFarm.CancelTween()
	Hub.CoinFarm.DisableUnder()
	Hub.CoinFarm.RestoreCoinVisuals()
	Hub.CoinFarm.SetBlackScreen(false, true)
	Hub.CoinFarm.Set3DRenderingDisabled(false, true)
	Hub.CoinFarm.DisconnectMap()
	Hub.CoinFarm.SetPhase("Disabled")
end

Hub.CoinFarm.ApplyResume = function()
	local genv2 = type(getgenv) == "function" and getgenv() or _G
	local foxnameCoinFarmResume = genv2.__FoxnameCoinFarmResume
	genv2.__FoxnameCoinFarmResume = nil
	local v8

	if type(foxnameCoinFarmResume) ~= "table" and type(isfile) == "function" and type(readfile) == "function" then
		local ok, result = pcall(isfile, "Foxname_MM2/coin_farm_resume.json")

		if ok and result then
			local ok2, result2 = pcall(readfile, "Foxname_MM2/coin_farm_resume.json")
			local ok3, result3 = pcall(HttpService.JSONDecode, HttpService, ok2 and result2 or "")

			if ok3 and type(result3) == "table" then
				local n2 = tonumber(result3.savedAt) or 0

				if n2 <= 0 or math.abs(os.time() - n2) <= 1800 then
					v8 = result3
				else
					v8 = foxnameCoinFarmResume
				end
			else
				v8 = foxnameCoinFarmResume
			end
		else
			v8 = foxnameCoinFarmResume
		end
	else
		v8 = foxnameCoinFarmResume
	end

	if type(v8) ~= "table" then
		return false
	end
	Hub.CoinFarm.resumedFromServerHop = true
	Hub.CoinFarm.totalCollected = math.max(0, math.floor(tonumber(v8.total) or 0))
	Hub.CoinFarm.totalEarnedXP = math.max(0, math.floor(tonumber(v8.totalXP) or 0))
	Hub.CoinFarm.resumedSessionElapsed = math.max(0, tonumber(v8.sessionElapsed) or 0)
	Hub.CoinFarm.serverHopCount = math.max(0, math.floor(tonumber(v8.serverHopCount) or 0))
	Hub.CoinFarm.mode = v8.mode == "Tween" and "Tween" or "CFrame"
	Hub.CoinFarm.position = v8.position == "Under" and "Under" or "Normal"
	Hub.CoinFarm.endRoundEnabled = v8.endRound == true
	Hub.CoinFarm.xpFarmEnabled = v8.xpFarm == true and Hub.CoinFarm.endRoundEnabled
	Hub.CoinFarm.serverHopLowPlayers = v8.serverHopLowPlayers == true
	Hub.CoinFarm.serverHopPlayerThreshold = math.clamp(math.floor(tonumber(v8.serverHopThreshold) or 4), 1, 6)
	Hub.CoinFarm.serverHopTimerMinutes = math.clamp(math.floor(tonumber(v8.serverHopTimerMinutes) or 15), 10, 30)
	Hub.CoinFarm.antiBotEnabled = v8.antiBot == true
	Hub.CoinFarm.blackScreenEnabled = v8.blackScreen == true
	Hub.CoinFarm.disable3DRendering = v8.disable3D == true
	Hub.AutoPrestige.SetEnabled(v8.autoPrestige == true)
	Hub.AutoClaimReward.SetEnabled(v8.autoClaimRewards ~= false)
	Hub.CoinFarm.RefreshStats()

	local function fn12(arg, arg2)
		if arg and type(arg.Set) == "function" then
			pcall(function()
				arg:Set(arg2)
			end)
		end
	end

	local function fn13(arg, arg2)
		if arg and type(arg.Select) == "function" then
			pcall(function()
				arg:Select(arg2)
			end)
		else
			fn12(arg, arg2)
		end
	end

	fn12(Hub.AutoPrestige.control, Hub.AutoPrestige.enabled)
	fn12(Hub.AutoClaimReward.control, Hub.AutoClaimReward.enabled)
	fn13(Hub.CoinFarm.modeControl, Hub.CoinFarm.mode)
	fn13(Hub.CoinFarm.positionControl, Hub.CoinFarm.position)
	fn12(Hub.CoinFarm.endRoundControl, Hub.CoinFarm.endRoundEnabled)

	if type(Hub.CoinFarm.UpdateXPFarmLock) == "function" then
		Hub.CoinFarm.UpdateXPFarmLock()
	end

	fn12(Hub.CoinFarm.xpFarmControl, Hub.CoinFarm.xpFarmEnabled)
	fn12(Hub.CoinFarm.serverHopControl, Hub.CoinFarm.serverHopLowPlayers)
	fn12(Hub.CoinFarm.serverHopThresholdControl, Hub.CoinFarm.serverHopPlayerThreshold)
	fn12(Hub.CoinFarm.serverHopTimerControl, Hub.CoinFarm.serverHopTimerMinutes)
	fn12(Hub.CoinFarm.antiBotControl, Hub.CoinFarm.antiBotEnabled)
	fn12(Hub.CoinFarm.blackScreenControl, Hub.CoinFarm.blackScreenEnabled)
	fn12(Hub.CoinFarm.renderingControl, Hub.CoinFarm.disable3DRendering)
	fn12(Hub.CoinFarm.toggleControl, v8.enabled == true)
	Hub.CoinFarm.SetBlackScreen(Hub.CoinFarm.blackScreenEnabled, true)
	Hub.CoinFarm.Set3DRenderingDisabled(Hub.CoinFarm.disable3DRendering, true)
	local eventBox = Hub.EventBox

	if type(eventBox) == "table" then
		if type(v8.eventBox) == "string" and eventBox.boxes[v8.eventBox] then
			eventBox.selectedBox = v8.eventBox
			fn13(eventBox.boxDropdown, v8.eventBox)
		end

		if type(v8.eventCurrency) == "string" then
			eventBox.selectedCurrency = v8.eventCurrency
			fn13(eventBox.currencyDropdown, v8.eventCurrency)
		end

		fn12(eventBox.autoBuyControl, v8.autoBuyBoxes == true)
	end

	if v8.enabled == true and not Hub.CoinFarm.enabled then
		Hub.CoinFarm.SetEnabled(true)
	end

	if type(isfile) == "function" and type(delfile) == "function" then
		local ok, result = pcall(isfile, "Foxname_MM2/coin_farm_resume.json")

		if ok and result then
			pcall(delfile, "Foxname_MM2/coin_farm_resume.json")
		end
	end

	return true
end

Hub.TouchButtons.ApplySize = function(arg, arg2, arg3)
	if not arg then
		return
	end
	local medium = Hub.TouchButtons.Sizes[arg2] or Hub.TouchButtons.Sizes.Medium
	local str = arg3 == "Rectangle" and "Rectangle" or "Square"
	local textWrapped = str == "Square"

	if textWrapped then
		local n2 = math.floor(medium.size.Y.Offset * 1.25 + 0.5)
		arg.Size = UDim2.fromOffset(n2, n2)
	else
		arg.Size = medium.size
	end

	arg.Text = ""
	local uiCorner = arg:FindFirstChildOfClass("UICorner")

	if uiCorner then
		if str == "Circle" then
			uiCorner.CornerRadius = UDim.new(1, 0)
		elseif str == "Square" then
			uiCorner.CornerRadius = UDim.new(0, 8)
		else
			uiCorner.CornerRadius = UDim.new(0, 12)
		end
	end

	local buttonTitle = arg:FindFirstChild("ButtonTitle")
	local titleDivider = arg:FindFirstChild("TitleDivider")
	local buttonIcon = arg:FindFirstChild("ButtonIcon")
	local statusDot = arg:FindFirstChild("StatusDot")
	local holdHint = arg:FindFirstChild("HoldHint")

	if buttonTitle then
		buttonTitle.Visible = not textWrapped
		buttonTitle.Position = UDim2.fromScale(0.34, 0.08)
		buttonTitle.Size = UDim2.fromScale(0.62, 0.42)
		buttonTitle.TextSize = arg2 == "Small" and 11 or arg2 == "Large" and 16 or 14
	end

	if titleDivider then
		titleDivider.Visible = not textWrapped
		titleDivider.Position = UDim2.fromScale(0.36, 0.52)
		titleDivider.Size = UDim2.new(0.56, 0, 0, 1)
	end

	if buttonIcon then
		buttonIcon.Position = textWrapped and UDim2.fromScale(0.1, 0.1) or UDim2.fromScale(0.06, 0.18)
		buttonIcon.Size = textWrapped and UDim2.fromScale(0.8, 0.8) or UDim2.fromScale(0.24, 0.5)
	end

	if statusDot then
		statusDot.Visible = false
		statusDot.Size = UDim2.fromOffset(arg2 == "Small" and 6 or 8, arg2 == "Small" and 6 or 8)
	end

	if holdHint then
		holdHint.Position = textWrapped and UDim2.fromScale(0.13, 0.68) or UDim2.fromScale(0.34, 0.56)
		holdHint.Size = textWrapped and UDim2.fromScale(0.74, 0.23) or UDim2.fromScale(0.62, 0.34)
		holdHint.TextWrapped = textWrapped
		textWrapped = textWrapped and (arg2 == "Small" and 7 or arg2 == "Large" and 9 or 8)
		local textSize

		if textWrapped then
			textSize = textWrapped
		else
			local n2 = arg2 == "Small" and 9
			local n3

			if n2 then
				n3 = n2
			else
				n3 = arg2 == "Large" and 12
			end

			textSize = n3 or 11
		end

		holdHint.TextSize = textSize
	end
end

Hub.TouchButtons.ApplyAppearance = function(arg, arg2)
	if not arg or not arg2 then
		return
	end
	local theme = Hub.TouchButtons.Theme
	local backgroundColor = theme.backgroundColor
	local outlineColor = arg2.outlineColor or theme.accentColor
	local color = Color3.new(1, 1, 1)
	arg.BackgroundColor3 = backgroundColor
	arg.BackgroundTransparency = 0.28
	arg.TextColor3 = color
	local uiStroke = arg:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		uiStroke.Color = outlineColor
		uiStroke.Transparency = 0
		uiStroke.Thickness = 3
	end

	local buttonTitle = arg:FindFirstChild("ButtonTitle")
	local titleDivider = arg:FindFirstChild("TitleDivider")
	local buttonIcon = arg:FindFirstChild("ButtonIcon")
	local holdHint = arg:FindFirstChild("HoldHint")

	if buttonTitle then
		buttonTitle.TextColor3 = color
	end

	if titleDivider then
		titleDivider.BackgroundColor3 = outlineColor
		titleDivider.BackgroundTransparency = 0.15
	end

	if buttonIcon then
		if buttonIcon:IsA("ImageLabel") then
			buttonIcon.ImageColor3 = outlineColor
		else
			buttonIcon.TextColor3 = outlineColor
			buttonIcon.TextStrokeColor3 = backgroundColor
		end
	end

	if holdHint then
		holdHint.TextColor3 = color
		holdHint.TextStrokeColor3 = Color3.new(0, 0, 0)
		holdHint.TextStrokeTransparency = 0.35
	end
end

Hub.TouchButtons.ForEachStyledButton = function(arg)
	for _, v8 in ipairs({
		Hub.XRayButtonState,
		Hub.AimlockButtonState,
		Hub.GetGunButtonState,
		Hub.BombJumpButtonState,
		Hub.ThrowKnifeButtonState,
		Hub.WallPhaseButtonState,
		Hub.FlyButtonState,
		Hub.NoclipButtonState,
	}) do
		arg(v8, v8.button)
	end

	arg(Hub.AutoShootDragState, Hub.AutoShootDragState.button or Hub.AutoShootTouchButton)
end

Hub.TouchButtons.SetThemeColor = function(arg, arg2)
	Hub.TouchButtons.Theme[arg == "outlineColor" and "accentColor" or arg] = arg2

	Hub.TouchButtons.ForEachStyledButton(function(arg3, arg4)
		arg3[arg] = arg2

		if arg4 and arg4.Parent then
			Hub.TouchButtons.ApplyAppearance(arg4, arg3)
		end
	end)
end

Hub.TouchButtons.RefreshAllHoldHints = function()
	Hub.TouchButtons.ForEachStyledButton(function(arg, arg2)
		Hub.TouchButtons.UpdateHoldHint(arg, arg2)
	end)
end

Hub.ESPColors = {
	Murderer = Color3.new(1, 0, 0.0156863),
	Sheriff = Color3.new(0, 0.6, 1),
	Innocent = Color3.new(0, 1, 0.0313725),
	Gun = Color3.new(0.952941, 1, 0.0745098),
}

Hub.OwnerESPColors = {
	Black = Color3.fromRGB(18, 18, 22),
	Gray = Color3.fromRGB(125, 125, 135),
	White = Color3.fromRGB(245, 245, 250),
}

do
	local colorSequence = ColorSequence.new
	local tbl7 = {}
	local v8 = ColorSequenceKeypoint.new(0, Hub.OwnerESPColors.Black)
	local v9 = ColorSequenceKeypoint.new(0.25, Hub.OwnerESPColors.Gray)
	local v10 = ColorSequenceKeypoint.new(0.5, Hub.OwnerESPColors.White)
	local v11 = ColorSequenceKeypoint.new(0.75, Hub.OwnerESPColors.Gray)
	local new = ColorSequenceKeypoint.new
	local black = Hub.OwnerESPColors.Black
	tbl7[1] = v8
	tbl7[2] = v9
	tbl7[3] = v10
	tbl7[4] = v11

	do
		local values = table.pack(new(1, black))
		table.move(values, 1, values.n, 5, tbl7)
	end

	Hub.OwnerESPGradient = colorSequence(tbl7)
end

Hub.GetOwnerESPGradientColor = function(arg)
	local n2 = (math.sin((arg or os.clock()) * 1.15) + 1) * 0.5
	if n2 < 0.5 then
		return Hub.OwnerESPColors.Black:Lerp(Hub.OwnerESPColors.Gray, n2 * 2)
	end
	return Hub.OwnerESPColors.Gray:Lerp(Hub.OwnerESPColors.White, (n2 - 0.5) * 2)
end

Hub.WorldFeatureConfig = { safezoneModelName = "Foxname_MM2_Safezone", xrayTransparency = 0.72 }

do
	local function fn12()
		if type(request) == "function" then
			return request
		end

		if type(http_request) == "function" then
			return http_request
		end

		if type(syn) == "table" and type(syn.request) == "function" then
			return syn.request
		end

		if type(fluxus) == "table" and type(fluxus.request) == "function" then
			return fluxus.request
		end
		return nil
	end

	local function fn13()
		local str = tostring(genv.FOXNAME_COIN_FARM_WEBHOOK or "")

		if str == "" and type(isfile) == "function" and type(readfile) == "function" then
			local ok, result = pcall(isfile, "Foxname_MM2/coin_farm_webhook.txt")

			if ok and result then
				local ok2, result2 = pcall(readfile, "Foxname_MM2/coin_farm_webhook.txt")

				if ok2 then
					str = tostring(result2 or "")
				end
			end
		end

		local match = str:match("^%s*(.-)%s*$") or ""
		Hub.CoinFarm.webhookUrl = match
		Hub.CoinFarm.webhookDraft = match
	end

	Hub.CoinFarm.SaveWebhook = function(arg)
		local match = tostring(arg or ""):match("^%s*(.-)%s*$") or ""
		local match2 = match:match("^https://discord%.com/api/webhooks/") or match:match("^https://discordapp%.com/api/webhooks/") or match:match("^https://ptb%.discord%.com/api/webhooks/") or match:match("^https://canary%.discord%.com/api/webhooks/")
		if match ~= "" and not match2 then
			return false, "Enter a valid Discord webhook URL."
		end

		if type(isfolder) ~= "function" or type(makefolder) ~= "function" or type(writefile) ~= "function" then
			return false, "This executor does not support file storage."
		end

		if not pcall(function()
			if not isfolder("Foxname_MM2") then
				makefolder("Foxname_MM2")
			end

			writefile("Foxname_MM2/coin_farm_webhook.txt", match)
		end) then
			return false, "Webhook could not be saved."
		end

		Hub.CoinFarm.webhookUrl = match
		Hub.CoinFarm.webhookDraft = match
		genv.FOXNAME_COIN_FARM_WEBHOOK = match
		return true, match == "" and "Webhook cleared." or "Webhook saved."
	end

	local function fn14(arg)
		local n2 = math.max(0, math.floor(tonumber(arg) or 0))
		return string.format("%02d:%02d:%02d", math.floor(n2 / 3600), math.floor(n2 / 60) % 60, n2 % 60)
	end

	Hub.CoinFarm.SendWebhook = function(arg, arg2)
		local str = tostring(Hub.CoinFarm.webhookUrl or "")
		local v8 = fn12()
		if str == "" or type(v8) ~= "function" then
			return false
		end
		local flag7 = Hub.CoinFarm.sessionStartedAt > 0

		if flag7 then
			local sessionStartedAt = Hub.CoinFarm.sessionStartedAt
			flag7 = math.max(0, os.clock() - sessionStartedAt)
		end

		local n2 = flag7 or 0
		local n3 = n2 / 60
		local n4 = math.max(0, math.floor(tonumber(Hub.CoinFarm.totalCollected) or 0))
		local n5 = math.max(0, math.floor(tonumber(Hub.CoinFarm.totalEarnedXP) or 0))
		local str2 = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png", tonumber(localPlayer.UserId) or 0)

		local tbl7 = {
			Started = 5763719,
			Stopped = 15158332,
			["15 Minute Update"] = 3447003,
			["Bag Full"] = 16753920,
			["Server Hop"] = 10181046,
		}

		local tbl8 = {}
		local tbl9 = { name = "Username", value = "`" .. tostring(localPlayer.Name) .. "`", inline = true }
		local tbl10 = { name = "Display Name", value = "`" .. tostring(localPlayer.DisplayName) .. "`", inline = true }
		local tbl11 = { name = "UserId", value = "`" .. tostring(localPlayer.UserId) .. "`", inline = true }
		local tbl12 = { name = "Report Type", value = "`" .. tostring(arg) .. "`", inline = true }
		local tbl13 = { name = "Farm Duration", value = "`" .. fn14(n2) .. "`", inline = true }

		local tbl14 = {
			name = "Server Hops",
			value = "`" .. tostring(Hub.CoinFarm.serverHopCount or 0) .. "`",
			inline = true,
		}

		local tbl15 = { name = "Collected Coins", value = "`" .. tostring(n4) .. "`", inline = true }
		local tbl16 = { name = "Earned XP", value = "`" .. tostring(n5) .. "`", inline = true }

		local tbl17 = {
			name = "Coins / Minute",
			value = "`" .. string.format("%.2f", n3 > 0 and n4 / n3 or 0) .. "`",
			inline = true,
		}

		local tbl18 = {
			name = "XP / Minute",
			value = "`" .. string.format("%.2f", n3 > 0 and n5 / n3 or 0) .. "`",
			inline = true,
		}

		local tbl19 = { name = "Mode", value = "`" .. tostring(Hub.CoinFarm.mode) .. "`", inline = true }
		local tbl20 = { name = "Position", value = "`" .. tostring(Hub.CoinFarm.position) .. "`", inline = true }
		tbl8[1] = tbl9
		tbl8[2] = tbl10
		tbl8[3] = tbl11
		tbl8[4] = tbl12
		tbl8[5] = tbl13
		tbl8[6] = tbl14
		tbl8[7] = tbl15
		tbl8[8] = tbl16
		tbl8[9] = tbl17
		tbl8[10] = tbl18
		tbl8[11] = tbl19
		tbl8[12] = tbl20
		tbl8[13] = { name = "Speed", value = "`30`", inline = true }

		if arg == "Server Hop" then
			table.insert(tbl8, { name = "Server Hop Reason", value = "`" .. tostring(arg2 or "Unknown") .. "`", inline = true })
		end

		table.insert(tbl8, {
			name = "Date / Time",
			value = "`" .. tostring(os.date("%Y-%m-%d %H:%M:%S %Z")) .. "`",
			inline = false,
		})

		local tbl21 = {}

		tbl21.embeds = {
			{
				title = "Coin Farm - " .. tostring(arg),
				color = tbl7[arg] or 9807270,
				thumbnail = { url = str2 },
				fields = tbl8,
			},
		}

		task.spawn(function()
			pcall(v8, {
				Url = str,
				Method = "POST",
				Headers = { ["Content-Type"] = "application/json" },
				Body = HttpService:JSONEncode(tbl21),
			})
		end)

		return true
	end

	Hub.CoinFarm.ReportBagFull = function()
		if Hub.CoinFarm.bagWebhookSent then
			return
		end
		Hub.CoinFarm.bagWebhookSent = true
		Hub.CoinFarm.SendWebhook("Bag Full")
	end

	Hub.CoinFarm.ReportServerHop = function(arg)
		Hub.CoinFarm.serverHopCount = math.max(0, math.floor(tonumber(Hub.CoinFarm.serverHopCount) or 0)) + 1
		Hub.CoinFarm.SendWebhook("Server Hop", arg)
	end

	fn13()
end

local getSafeGuiParent, createScreenGui
local v8 = nil

getSafeGuiParent = function()
	if gethui then
		local ok, result = pcall(function()
			return gethui()
		end)

		if ok and result then
			return result
		end
	end

	local ok, result = pcall(function()
		return game:GetService("CoreGui")
	end)

	if ok and result then
		return result
	end
	return localPlayer:WaitForChild("PlayerGui")
end

createScreenGui = function()
	if v8 and v8.Parent then
		return v8
	end
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "Foxname_MM2_Overlay"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = 999999

	pcall(function()
		if syn and syn.protect_gui then
			syn.protect_gui(screenGui)
		elseif protect_gui then
			protect_gui(screenGui)
		end
	end)

	screenGui.Parent = getSafeGuiParent()
	v8 = screenGui
	return screenGui
end

local fn13, fn14, fn15, fn16, fn17, fn18, fn19, fn20, fn21, fn22
local fn23, fn24, fn25, fn26, fn27, fn28, fn29, fn30, fn31, fn32
local fn33, fn34

do
	local function fn35()
		local v9 = createScreenGui()
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "ESP360Arrow"
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.Size = UDim2.fromOffset(34, 34)
		imageLabel.BackgroundTransparency = 1
		imageLabel.Image = "rbxassetid://97136202386756"
		imageLabel.Visible = false
		imageLabel.ZIndex = 20
		imageLabel.Parent = v9
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "ESP360Distance"
		textLabel.AnchorPoint = Vector2.new(0.5, 0)
		textLabel.Size = UDim2.fromOffset(90, 22)
		textLabel.BackgroundTransparency = 1
		textLabel.Font = Enum.Font.GothamBold
		textLabel.TextSize = 17
		textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
		textLabel.TextStrokeTransparency = 0.25
		textLabel.Visible = false
		textLabel.ZIndex = 21
		textLabel.Parent = v9
		return imageLabel, textLabel
	end

	fn13 = function(arg, arg2)
		if arg then
			arg.Visible = false
		end

		if arg2 then
			arg2.Visible = false
		end
	end

	fn14 = function(arg, arg2, arg3, imageColor3, arg4, arg5)
		if not arg or not arg2 or not arg3 then
			fn13(arg, arg2)
			return
		end
		local v9, v10 = currentCamera:WorldToViewportPoint(arg3)
		if v10 and v9.Z > 0 and v9.X >= 48 and v9.X <= arg4.X - 48 and v9.Y >= 48 and v9.Y <= arg4.Y - 48 then
			fn13(arg, arg2)
			return
		end
		local cFrame = currentCamera.CFrame
		local v11 = cFrame:VectorToObjectSpace(arg3 - cFrame.Position)
		local vector2 = Vector2.new(v11.X, v11.Y)
		local vector22

		if vector2.Magnitude < 0.001 then
			vector22 = Vector2.new(0, -1)
		else
			vector22 = vector2.Unit
		end

		local n2 = math.max(1, arg4.X * 0.5 - 48)
		local n3 = math.max(1, arg4.Y * 0.5 - 48)
		local n4 = vector22 * math.min(math.abs(vector22.X) > 0.001 and n2 / math.abs(vector22.X) or math.huge, math.abs(vector22.Y) > 0.001 and n3 / math.abs(vector22.Y) or math.huge)
		local vector23 = Vector2.new(arg4.X * 0.5 + n4.X, arg4.Y * 0.5 - n4.Y)
		arg.Position = UDim2.fromOffset(vector23.X, vector23.Y)
		arg.Rotation = math.deg(math.atan2(vector22.X, vector22.Y))
		arg.ImageColor3 = imageColor3
		arg.Visible = true
		arg5 = arg5 and arg5.Position or cFrame.Position
		arg2.Position = UDim2.fromOffset(vector23.X, vector23.Y + 18)
		arg2.Text = tostring(math.floor((arg3 - arg5).Magnitude + 0.5))
		arg2.TextColor3 = imageColor3
		arg2.Visible = true
	end

	Hub.Crosshair.RestoreCursor = function()
		local crosshair = Hub.Crosshair
		crosshair.suppressCursor = false

		if crosshair.cursorHidden then
			if crosshair.originalMouseIconEnabled ~= nil then
				UserInputService.MouseIconEnabled = crosshair.originalMouseIconEnabled
			end
		end

		crosshair.cursorHidden = false
		crosshair.originalMouseIconEnabled = nil
	end

	Hub.Crosshair.HideCursor = function()
		local crosshair = Hub.Crosshair

		if not crosshair.cursorHidden then
			crosshair.originalMouseIconEnabled = UserInputService.MouseIconEnabled
			crosshair.cursorHidden = true
		end

		crosshair.suppressCursor = true
		UserInputService.MouseIconEnabled = false
	end

	Hub.Crosshair.Destroy = function()
		local crosshair = Hub.Crosshair

		if crosshair.connection then
			crosshair.connection:Disconnect()
			crosshair.connection = nil
		end

		if crosshair.cursorConnection then
			crosshair.cursorConnection:Disconnect()
			crosshair.cursorConnection = nil
		end

		if crosshair.root then
			crosshair.root:Destroy()
			crosshair.root = nil
		end

		table.clear(crosshair.parts)
		crosshair.angle = 0
		crosshair.lastUpdate = 0
		Hub.Crosshair.RestoreCursor()
	end

	Hub.Crosshair.ApplyAppearance = function()
		local crosshair = Hub.Crosshair
		local color = crosshair.rgb and Color3.fromHSV(os.clock() * 0.16 % 1, 0.9, 1) or crosshair.color

		for _, part in ipairs(crosshair.parts) do
			if part and part.Parent then
				part.ImageColor3 = color
			end
		end
	end

	Hub.Crosshair.Rebuild = function()
		local crosshair = Hub.Crosshair
		Hub.Crosshair.Destroy()
		if not crosshair.enabled then
			return
		end
		local frame = Instance.new("Frame")
		frame.Name = "CustomCrosshair"
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.fromScale(0.5, 0.5)
		frame.Size = UDim2.fromOffset(crosshair.size, crosshair.size)
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.ZIndex = 100
		frame.Parent = createScreenGui()
		crosshair.root = frame
		local v9 = crosshair.icons[crosshair.style]

		if not v9 then
			frame:Destroy()
			crosshair.root = nil
			return
		end

		local image = type(v9) == "table" and v9.image or v9
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "Lucide_" .. crosshair.style
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.Position = UDim2.fromScale(0.5, 0.5)
		imageLabel.Size = UDim2.fromScale(1, 1)
		imageLabel.BackgroundTransparency = 1
		imageLabel.Image = image

		if type(v9) == "table" then
			imageLabel.ImageRectSize = v9.rectSize or Vector2.zero
			imageLabel.ImageRectOffset = v9.rectPosition or Vector2.zero
		end

		imageLabel.ImageColor3 = crosshair.color
		imageLabel.ScaleType = Enum.ScaleType.Fit
		imageLabel.ZIndex = 101
		imageLabel.Parent = frame
		table.insert(crosshair.parts, imageLabel)
		Hub.Crosshair.ApplyAppearance()
		crosshair.lastUpdate = os.clock()

		crosshair.cursorConnection = UserInputService:GetPropertyChangedSignal("MouseIconEnabled"):Connect(function()
			if crosshair.enabled and crosshair.suppressCursor and UserInputService.MouseIconEnabled then
				UserInputService.MouseIconEnabled = false
			end
		end)

		crosshair.connection = RunService.RenderStepped:Connect(function(deltaTime)
			if not crosshair.enabled or not crosshair.root or not crosshair.root.Parent then
				return
			end
			local now = os.clock()
			local n2 = now - crosshair.lastUpdate
			if n2 < crosshair.frameInterval then
				return
			end
			crosshair.lastUpdate = now
			local character_ = localPlayer.Character
			character_ = character_ and character_:FindFirstChild("Head")
			local flag7 = localPlayer.CameraMode == Enum.CameraMode.LockFirstPerson or character_ and (currentCamera.CFrame.Position - character_.Position).Magnitude <= 1.25 or false
			local icon = localPlayer:GetMouse().Icon
			local flag8 = type(icon) == "string" and string.find(string.lower(icon), "mouselockedcursor", 1, true) ~= nil
			flag7 = flag7 or flag8 or crosshair.userGameSettings.RotationType == Enum.RotationType.CameraRelative
			crosshair.root.Visible = crosshair.mode == "Always" or flag7

			if flag7 then
				Hub.Crosshair.HideCursor()
			else
				Hub.Crosshair.RestoreCursor()
			end

			crosshair.angle = (crosshair.angle + crosshair.speed * math.max(n2, deltaTime)) % 360
			crosshair.root.Rotation = crosshair.angle

			if crosshair.rgb then
				Hub.Crosshair.ApplyAppearance()
			end
		end)
	end

	Hub.Crosshair.SetEnabled = function(arg)
		Hub.Crosshair.enabled = arg and true or false
		Hub.Crosshair.Rebuild()
	end

	Hub.Crosshair.SetCustomIcon = function(arg)
		local crosshair = Hub.Crosshair
		local v9 = string.gsub(string.gsub(string.gsub(string.lower(tostring(arg or "")), "^%s+", ""), "%s+$", ""), "%s+", "-")
		if v9 == "" then
			return
		end

		if not string.match(v9, "^[a-z0-9%-]+$") then
			WindUI:Notify({
				Title = "Invalid Cursor Name",
				Content = "Use a Lucide icon name such as sparkles",
				Icon = "x",
				Duration = 2.5,
			})

			return
		end

		if crosshair.icons[v9] then
			crosshair.style = v9

			if crosshair.enabled then
				crosshair.Rebuild()
			end

			return
		end

		if crosshair.iconLoading then
			WindUI:Notify({
				Title = "Cursor Loading",
				Content = "Please wait for the current icon",
				Icon = "loader",
				Duration = 2,
			})

			return
		end

		crosshair.iconLoading = true

		task.spawn(function()
			local ok, result = pcall(function()
				if not crosshair.iconModule then
					crosshair.iconModule = Hub.TouchButtons and Hub.TouchButtons.iconModule
				end

				if not crosshair.iconModule then
					crosshair.iconModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"))()
				end

				return crosshair.iconModule.Icon2(v9)
			end)

			crosshair.iconLoading = false

			if not ok or type(result) ~= "table" or type(result[1]) ~= "string" then
				WindUI:Notify({
					Title = "Cursor Not Found",
					Content = v9 .. " is not a valid Lucide icon",
					Icon = "search-x",
					Duration = 3,
				})

				return
			end

			local tbl7 = result[2] or {}
			crosshair.icons[v9] = { image = result[1], rectSize = tbl7.ImageRectSize, rectPosition = tbl7.ImageRectPosition }
			crosshair.style = v9

			if crosshair.enabled then
				crosshair.Rebuild()
			end

			WindUI:Notify({ Title = "Crosshair Updated", Content = v9, Icon = "check", Duration = 2 })
		end)
	end

	Hub.Spinbot.RestoreHumanoid = function()
		local spinbot = Hub.Spinbot

		if spinbot.humanoid and spinbot.humanoid.Parent and spinbot.originalAutoRotate ~= nil then
			spinbot.humanoid.AutoRotate = spinbot.originalAutoRotate
		end

		spinbot.humanoid = nil
		spinbot.originalAutoRotate = nil
	end

	Hub.Spinbot.SetEnabled = function(arg)
		local spinbot = Hub.Spinbot
		spinbot.enabled = arg and true or false

		if spinbot.connection then
			spinbot.connection:Disconnect()
			spinbot.connection = nil
		end

		Hub.Spinbot.RestoreHumanoid()
		if not spinbot.enabled then
			return
		end

		spinbot.connection = RunService.Heartbeat:Connect(function(deltaTime)
			if not spinbot.enabled then
				return
			end
			local character_ = localPlayer.Character
			local humanoid = character_ and character_:FindFirstChildOfClass("Humanoid")
			character_ = character_ and character_:FindFirstChild("HumanoidRootPart")
			if not humanoid or not character_ or humanoid.Health <= 0 then
				return
			end

			if spinbot.humanoid ~= humanoid then
				Hub.Spinbot.RestoreHumanoid()
				spinbot.humanoid = humanoid
				spinbot.originalAutoRotate = humanoid.AutoRotate
				humanoid.AutoRotate = false
			elseif humanoid.AutoRotate then
				humanoid.AutoRotate = false
			end

			character_.CFrame = character_.CFrame * CFrame.Angles(0, math.rad(spinbot.speed * 1440 * deltaTime), 0)
		end)
	end

	Hub.HitboxExpander.RestorePart = function(arg)
		local hitboxExpander = Hub.HitboxExpander
		local v9 = hitboxExpander.originals[arg]
		if not v9 then
			return
		end
		local v10 = hitboxExpander.partConnections[arg]

		if v10 then
			if type(v10) == "table" then
				for _, v11 in pairs(v10) do
					if v11 and v11.Connected then
						v11:Disconnect()
					end
				end
			elseif v10.Connected then
				v10:Disconnect()
			end

			hitboxExpander.partConnections[arg] = nil
		end

		hitboxExpander.originals[arg] = nil
		if not arg.Parent then
			return
		end

		pcall(function()
			arg.Size = v9.Size
			arg.CanCollide = v9.CanCollide
			arg.CanQuery = v9.CanQuery
			arg.CanTouch = v9.CanTouch
			arg.Massless = v9.Massless
			arg.Transparency = v9.Transparency
			arg.LocalTransparencyModifier = v9.LocalTransparencyModifier
			arg.Color = v9.Color
			arg.Material = v9.Material
		end)
	end

	Hub.HitboxExpander.ApplyCharacter = function(arg, arg2)
		local hitboxExpander = Hub.HitboxExpander
		if not hitboxExpander.enabled or not hitboxExpander.stabActive or arg == localPlayer or fn6(arg) and not isOwner or not arg2 then
			return
		end
		local humanoidRootPart = arg2:FindFirstChild("HumanoidRootPart") or arg2:WaitForChild("HumanoidRootPart", 5)
		if not hitboxExpander.enabled or not hitboxExpander.stabActive or not humanoidRootPart or not humanoidRootPart:IsA("BasePart") then
			return
		end

		if not hitboxExpander.originals[humanoidRootPart] then
			hitboxExpander.originals[humanoidRootPart] = {
				Size = humanoidRootPart.Size,
				CanCollide = humanoidRootPart.CanCollide,
				CanQuery = humanoidRootPart.CanQuery,
				CanTouch = humanoidRootPart.CanTouch,
				Massless = humanoidRootPart.Massless,
				Transparency = humanoidRootPart.Transparency,
				LocalTransparencyModifier = humanoidRootPart.LocalTransparencyModifier,
				Color = humanoidRootPart.Color,
				Material = humanoidRootPart.Material,
			}
		end

		local n2 = math.clamp(tonumber(hitboxExpander.size) or 6, 2, 50)

		if not hitboxExpander.partConnections[humanoidRootPart] then
			hitboxExpander.partConnections[humanoidRootPart] = {
				Size = humanoidRootPart:GetPropertyChangedSignal("Size"):Connect(function()
					if not hitboxExpander.enabled or not hitboxExpander.stabActive or not humanoidRootPart.Parent then
						return
					end
					local n3 = math.clamp(tonumber(hitboxExpander.size) or 6, 2, 50)
					if (humanoidRootPart.Size - Vector3.new(n3, n3, n3)).Magnitude <= 0.01 then
						return
					end
					local v9 = hitboxExpander.originals[humanoidRootPart]

					if v9 then
						v9.Size = humanoidRootPart.Size
					end

					task.defer(Hub.HitboxExpander.ApplyCharacter, arg, arg2)
				end),
				CanCollide = humanoidRootPart:GetPropertyChangedSignal("CanCollide"):Connect(function()
					if hitboxExpander.enabled and hitboxExpander.stabActive and humanoidRootPart.Parent and humanoidRootPart.CanCollide then
						humanoidRootPart.CanCollide = false
					end
				end),
				Massless = humanoidRootPart:GetPropertyChangedSignal("Massless"):Connect(function()
					if hitboxExpander.enabled and hitboxExpander.stabActive and humanoidRootPart.Parent and not humanoidRootPart.Massless then
						humanoidRootPart.Massless = true
					end
				end),
			}
		end

		pcall(function()
			humanoidRootPart.Size = Vector3.new(n2, n2, n2)
			humanoidRootPart.CanCollide = false
			humanoidRootPart.Massless = true
			humanoidRootPart.CanQuery = true
			humanoidRootPart.CanTouch = true
			humanoidRootPart.Transparency = hitboxExpander.visible and 0.55 or 0.99
			humanoidRootPart.LocalTransparencyModifier = hitboxExpander.visible and 0 or 1

			if hitboxExpander.visible then
				humanoidRootPart.Color = Color3.fromRGB(255, 70, 70)
				humanoidRootPart.Material = Enum.Material.Neon
			end
		end)
	end

	Hub.HitboxExpander.ApplyAll = function()
		if not Hub.HitboxExpander.enabled then
			return
		end

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= localPlayer and player.Character then
				task.spawn(Hub.HitboxExpander.ApplyCharacter, player, player.Character)
			end
		end
	end

	Hub.HitboxExpander.RestoreAll = function()
		local tbl7 = {}

		for k in pairs(Hub.HitboxExpander.originals) do
			tbl7[#tbl7 + 1] = k
		end

		for _, v9 in ipairs(tbl7) do
			Hub.HitboxExpander.RestorePart(v9)
		end
	end

	Hub.HitboxExpander.TrackPlayer = function(arg)
		local hitboxExpander = Hub.HitboxExpander
		if arg == localPlayer or hitboxExpander.playerConnections[arg] then
			return
		end

		hitboxExpander.playerConnections[arg] = arg.CharacterAdded:Connect(function(character_)
			if hitboxExpander.enabled then
				task.spawn(Hub.HitboxExpander.ApplyCharacter, arg, character_)
			end
		end)

		if hitboxExpander.enabled and arg.Character then
			task.spawn(Hub.HitboxExpander.ApplyCharacter, arg, arg.Character)
		end
	end

	Hub.HitboxExpander.DisconnectKnifeTracking = function()
		local hitboxExpander = Hub.HitboxExpander

		if hitboxExpander.localCharacterConnection then
			hitboxExpander.localCharacterConnection:Disconnect()
			hitboxExpander.localCharacterConnection = nil
		end

		for k, localToolConnection in pairs(hitboxExpander.localToolConnections) do
			if localToolConnection and localToolConnection.Connected then
				localToolConnection:Disconnect()
			end

			hitboxExpander.localToolConnections[k] = nil
		end
	end

	Hub.HitboxExpander.EndActionWindow = function(arg)
		local hitboxExpander = Hub.HitboxExpander
		if arg and hitboxExpander.stabGeneration ~= arg then
			return false
		end
		hitboxExpander.stabGeneration = hitboxExpander.stabGeneration + 1
		hitboxExpander.stabActive = false
		Hub.HitboxExpander.RestoreAll()
		return true
	end

	Hub.HitboxExpander.BeginStabWindow = function()
		local hitboxExpander = Hub.HitboxExpander
		if not hitboxExpander.enabled then
			return nil
		end
		local character_ = localPlayer.Character
		character_ = character_ and character_:FindFirstChild("Knife")
		if not character_ or not character_:IsA("Tool") then
			return nil
		end
		hitboxExpander.stabGeneration = hitboxExpander.stabGeneration + 1
		local stabGeneration = hitboxExpander.stabGeneration
		hitboxExpander.stabActive = true
		Hub.HitboxExpander.ApplyAll()

		task.delay(0.55, function()
			Hub.HitboxExpander.EndActionWindow(stabGeneration)
		end)

		return stabGeneration
	end

	Hub.HitboxExpander.TrackKnife = function(arg)
		local hitboxExpander = Hub.HitboxExpander
		if not hitboxExpander.enabled or not arg or not arg:IsA("Tool") or arg.Name ~= "Knife" or hitboxExpander.localToolConnections[arg] then
			return
		end

		hitboxExpander.localToolConnections[arg] = arg.Activated:Connect(function()
			Hub.HitboxExpander.BeginStabWindow()
		end)
	end

	Hub.HitboxExpander.StartKnifeTracking = function()
		local hitboxExpander = Hub.HitboxExpander
		Hub.HitboxExpander.DisconnectKnifeTracking()
		local character_ = localPlayer.Character
		if not character_ then
			return
		end

		for _, child in ipairs(character_:GetChildren()) do
			Hub.HitboxExpander.TrackKnife(child)
		end

		hitboxExpander.localCharacterConnection = character_.ChildAdded:Connect(function(child)
			Hub.HitboxExpander.TrackKnife(child)
		end)
	end

	Hub.HitboxExpander.SetEnabled = function(arg)
		local hitboxExpander = Hub.HitboxExpander
		hitboxExpander.enabled = arg and true or false

		if hitboxExpander.enabled then
			Hub.HitboxExpander.StartKnifeTracking()

			if hitboxExpander.localPlayerConnection then
				hitboxExpander.localPlayerConnection:Disconnect()
			end

			hitboxExpander.localPlayerConnection = localPlayer.CharacterAdded:Connect(function()
				task.defer(Hub.HitboxExpander.StartKnifeTracking)
			end)
		else
			hitboxExpander.stabGeneration = hitboxExpander.stabGeneration + 1
			hitboxExpander.stabActive = false
			Hub.HitboxExpander.DisconnectKnifeTracking()

			if hitboxExpander.localPlayerConnection then
				hitboxExpander.localPlayerConnection:Disconnect()
				hitboxExpander.localPlayerConnection = nil
			end

			Hub.HitboxExpander.RestoreAll()
		end
	end

	Hub.HitboxExpander.Destroy = function()
		local hitboxExpander = Hub.HitboxExpander
		hitboxExpander.enabled = false
		hitboxExpander.stabGeneration = hitboxExpander.stabGeneration + 1
		hitboxExpander.stabActive = false
		Hub.HitboxExpander.DisconnectKnifeTracking()

		if hitboxExpander.localPlayerConnection then
			hitboxExpander.localPlayerConnection:Disconnect()
			hitboxExpander.localPlayerConnection = nil
		end

		Hub.HitboxExpander.RestoreAll()

		for k, playerConnection in pairs(hitboxExpander.playerConnections) do
			if playerConnection and playerConnection.Connected then
				playerConnection:Disconnect()
			end

			hitboxExpander.playerConnections[k] = nil
		end
	end

	for _, player in ipairs(Players:GetPlayers()) do
		Hub.HitboxExpander.TrackPlayer(player)
	end

	trackConn(Players.PlayerAdded:Connect(function(player)
		Hub.HitboxExpander.TrackPlayer(player)
	end))

	trackConn(Players.PlayerRemoving:Connect(function(player)
		local hitboxExpander = Hub.HitboxExpander
		local v9 = hitboxExpander.playerConnections[player]

		if v9 then
			v9:Disconnect()
			hitboxExpander.playerConnections[player] = nil
		end

		if player.Character then
			local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				Hub.HitboxExpander.RestorePart(humanoidRootPart)
			end
		end
	end))

	local function createFrame(arg)
		local frame = Instance.new("Frame")
		frame.Name = "ESPLine"
		frame.BorderSizePixel = 0
		frame.BackgroundColor3 = Color3.new(1, 1, 1)
		frame.BackgroundTransparency = 0
		frame.Size = UDim2.new(0, 0, 0, arg or 2)
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Visible = false
		frame.ZIndex = 10
		frame.Parent = createScreenGui()
		return frame
	end

	fn15 = function(arg)
		if not arg then
			return
		end

		if typeof(arg) == "Instance" then
			arg:Destroy()
		elseif type(arg.Remove) == "function" then
			arg:Remove()
		end
	end

	fn16 = function(arg, arg2, arg3, backgroundColor3)
		if not arg then
			return
		end
		local n2 = arg3 - arg2
		local magnitude = n2.Magnitude
		if magnitude < 1 then
			arg.Visible = false
			return
		end

		if backgroundColor3 then
			arg.BackgroundColor3 = backgroundColor3
		end

		local n3 = (arg2 + arg3) * 0.5
		arg.Size = UDim2.new(0, magnitude, 0, arg.Size.Y.Offset)
		arg.Position = UDim2.new(0, n3.X, 0, n3.Y)
		arg.Rotation = math.deg(math.atan2(n2.Y, n2.X))
		arg.Visible = true
	end

	local function fn36(arg)
		if not arg:IsA("BasePart") then
			return
		end

		if Hub.NoclipParts[arg] == nil then
			Hub.NoclipParts[arg] = arg.CanCollide
		end

		if arg.CanCollide then
			arg.CanCollide = false
		end
	end

	fn17 = function()
		local character_ = localPlayer.Character

		if character_ then
			for _, descendant in ipairs(character_:GetDescendants()) do
				fn36(descendant)
			end
		end

		if Hub.NoclipConn then
			Hub.NoclipConn:Disconnect()
			Hub.NoclipConn = nil
		end

		if Hub.NoclipStepConn then
			Hub.NoclipStepConn:Disconnect()
			Hub.NoclipStepConn = nil
		end

		if character_ then
			Hub.NoclipConn = character_.DescendantAdded:Connect(function(descendant)
				if Hub.NoclipEnabled then
					fn36(descendant)
				end
			end)
		end

		Hub.NoclipNextRefresh = 0

		Hub.NoclipStepConn = RunService.Heartbeat:Connect(function()
			if not Hub.NoclipEnabled then
				return
			end
			local now = tick()
			if now < Hub.NoclipNextRefresh then
				return
			end
			Hub.NoclipNextRefresh = now + 0.2
			local character_2 = localPlayer.Character
			if not character_2 then
				return
			end

			for _, descendant in ipairs(character_2:GetDescendants()) do
				if descendant:IsA("BasePart") and descendant.CanCollide then
					fn36(descendant)
				end
			end
		end)
	end

	fn18 = function()
		if Hub.NoclipConn then
			Hub.NoclipConn:Disconnect()
			Hub.NoclipConn = nil
		end

		if Hub.NoclipStepConn then
			Hub.NoclipStepConn:Disconnect()
			Hub.NoclipStepConn = nil
		end

		for k, noclipPart in pairs(Hub.NoclipParts) do
			if k and k.Parent then
				k.CanCollide = noclipPart
			end
		end

		Hub.NoclipNextRefresh = 0
		table.clear(Hub.NoclipParts)
	end

	Hub.SpeedGlitchConn = RunService.Heartbeat:Connect(function(deltaTime)
		if not Hub.SpeedGlitchEnabled then
			return
		end
		local character_ = localPlayer.Character
		if not character_ then
			return
		end
		local humanoid = character_:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = character_:FindFirstChild("HumanoidRootPart")
		if not humanoid or not humanoidRootPart then
			return
		end

		if humanoid.MoveDirection.Magnitude > 0 and humanoid.FloorMaterial == Enum.Material.Air then
			humanoidRootPart.CFrame = humanoidRootPart.CFrame + humanoid.MoveDirection * Hub.SpeedGlitchPower * 15 * deltaTime
			local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity

			if assemblyLinearVelocity.Y < 0 then
				humanoidRootPart.AssemblyLinearVelocity = Vector3.new(assemblyLinearVelocity.X, assemblyLinearVelocity.Y * 0.97, assemblyLinearVelocity.Z)
			end
		end
	end)

	local fn37 = nil

	local function fn38()
		WindUI:Notify({ Title = "Done", Content = "Fling complete", Icon = "check", Duration = 1.5 })
	end

	fn19 = function(arg)
		WindUI:Notify({ Title = "Error", Content = arg or "Not found", Icon = "x", Duration = 1.5 })
	end

	local function fn39(arg)
		local character_ = localPlayer.Character
		local humanoid = character_ and character_:FindFirstChildOfClass("Humanoid")
		local rootPart = humanoid and humanoid.RootPart
		arg = arg and arg.Character
		if not arg then
			return
		end
		local humanoid2 = arg:FindFirstChildOfClass("Humanoid")
		local rootPart2 = humanoid2 and humanoid2.RootPart
		local head = arg:FindFirstChild("Head")
		local accessory = arg:FindFirstChildOfClass("Accessory")
		accessory = accessory and accessory:FindFirstChild("Handle")
		if not (character_ and humanoid and rootPart) then
			return
		end

		if rootPart.Velocity.Magnitude < 50 then
			Hub.FlingOldPos = rootPart.CFrame
		end

		if humanoid2 and humanoid2.Sit then
			return
		end
		local currentCamera2 = workspace.CurrentCamera

		if currentCamera2 then
			if head then
				currentCamera2.CameraSubject = head
			elseif accessory then
				currentCamera2.CameraSubject = accessory
			elseif humanoid2 then
				currentCamera2.CameraSubject = humanoid2
			end
		end

		if not arg:FindFirstChildWhichIsA("BasePart") then
			return
		end

		local function fn40(arg2, arg3, arg4)
			rootPart.CFrame = CFrame.new(arg2.Position) * arg3 * arg4

			if character_.PrimaryPart then
				character_:SetPrimaryPartCFrame(CFrame.new(arg2.Position) * arg3 * arg4)
			end

			rootPart.Velocity = Vector3.new(90000000, -900000000, 90000000)
			rootPart.RotVelocity = Vector3.new(900000000, 900000000, 900000000)
		end

		local function fn41(arg2)
			local now = tick()
			local n2 = 0

			while true do
				if rootPart and humanoid2 then
					if arg2.Velocity.Magnitude < 50 then
						n2 += 100
						local n3 = humanoid2.MoveDirection * arg2.Velocity.Magnitude / 1.25
						local cframe = CFrame.Angles
						fn40(arg2, CFrame.new(0, 1.5, 0) + n3, cframe(math.rad(n2), 0, 0))
						task.wait()
						local cframe2 = CFrame.Angles
						fn40(arg2, CFrame.new(0, -1.5, 0) + n3, cframe2(math.rad(n2), 0, 0))
						task.wait()
						local cframe3 = CFrame.Angles
						fn40(arg2, CFrame.new(0, 1.5, 0) + n3, cframe3(math.rad(n2), 0, 0))
						task.wait()
						local cframe4 = CFrame.Angles
						fn40(arg2, CFrame.new(0, -1.5, 0) + n3, cframe4(math.rad(n2), 0, 0))
						task.wait()
						local moveDirection = humanoid2.MoveDirection
						local cframe5 = CFrame.Angles
						fn40(arg2, CFrame.new(0, 1.5, 0) + moveDirection, cframe5(math.rad(n2), 0, 0))
						task.wait()
						local moveDirection2 = humanoid2.MoveDirection
						local cframe6 = CFrame.Angles
						fn40(arg2, CFrame.new(0, -1.5, 0) + moveDirection2, cframe6(math.rad(n2), 0, 0))
						task.wait()
					else
						local cframe = CFrame.Angles
						fn40(arg2, CFrame.new(0, 1.5, humanoid2.WalkSpeed), cframe(1.5707963267948966, 0, 0))
						task.wait()
						local cframe2 = CFrame.Angles
						fn40(arg2, CFrame.new(0, -1.5, -humanoid2.WalkSpeed), cframe2(0, 0, 0))
						task.wait()
						local cframe3 = CFrame.Angles
						fn40(arg2, CFrame.new(0, 1.5, humanoid2.WalkSpeed), cframe3(1.5707963267948966, 0, 0))
						task.wait()
						local cframe4 = CFrame.Angles
						fn40(arg2, CFrame.new(0, -1.5, 0), cframe4(1.5707963267948966, 0, 0))
						task.wait()
						local cframe5 = CFrame.Angles
						fn40(arg2, CFrame.new(0, -1.5, 0), cframe5(0, 0, 0))
						task.wait()
						local cframe6 = CFrame.Angles
						fn40(arg2, CFrame.new(0, -1.5, 0), cframe6(1.5707963267948966, 0, 0))
						task.wait()
						local cframe7 = CFrame.Angles
						fn40(arg2, CFrame.new(0, -1.5, 0), cframe7(0, 0, 0))
						task.wait()
					end
				end

				if not (now + 2 < tick() or not Hub.FlingActive or humanoid.Health <= 0) then
					continue
				end
				break
			end
		end

		local fallenPartsDestroyHeight = workspace.FallenPartsDestroyHeight
		workspace.FallenPartsDestroyHeight = (0/0)
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Parent = rootPart
		bodyVelocity.Velocity = Vector3.zero
		bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

		if rootPart2 then
			fn41(rootPart2)
		elseif head then
			fn41(head)
		else
			if not accessory then
				bodyVelocity:Destroy()
				humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
				workspace.FallenPartsDestroyHeight = fallenPartsDestroyHeight
				return
			end

			fn41(accessory)
		end

		bodyVelocity:Destroy()
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)

		if currentCamera2 then
			currentCamera2.CameraSubject = humanoid
		end

		if Hub.FlingOldPos and humanoid.Health > 0 then
			while true do
				rootPart.CFrame = Hub.FlingOldPos * CFrame.new(0, 0.5, 0)

				if character_.PrimaryPart then
					character_:SetPrimaryPartCFrame(Hub.FlingOldPos * CFrame.new(0, 0.5, 0))
				end

				humanoid:ChangeState("GettingUp")

				for _, child in pairs(character_:GetChildren()) do
					if child:IsA("BasePart") then
						local vector = Vector3.new()
						local vector2 = Vector3.new()
						child.Velocity = vector
						child.RotVelocity = vector2
					end
				end

				task.wait()
				if not ((rootPart.Position - Hub.FlingOldPos.p).Magnitude < 25 or not Hub.FlingActive or humanoid.Health <= 0) then
					continue
				end
				break
			end
		end

		workspace.FallenPartsDestroyHeight = fallenPartsDestroyHeight
	end

	local function fn40(arg)
		arg = arg and arg.Character
		if not arg then
			return nil
		end
		local humanoid = arg:FindFirstChildOfClass("Humanoid")
		humanoid = humanoid and humanoid.RootPart
		if humanoid then
			return humanoid
		end
		local head = arg:FindFirstChild("Head")
		if head then
			return head
		end
		local accessory = arg:FindFirstChildOfClass("Accessory")
		return accessory and accessory:FindFirstChild("Handle")
	end

	fn20 = function(arg, arg2, arg3, arg4)
		if Hub.FlingActive then
			return false
		end

		if not arg then
			return false
		end
		local v9 = Players:FindFirstChild(arg)
		if not v9 then
			fn19("Player not found")
			return false
		end

		local function fn41()
			local character_ = localPlayer.Character
			local humanoid = character_ and character_:FindFirstChildOfClass("Humanoid")
			return humanoid ~= nil and humanoid.Health > 0
		end

		local function fn42()
			if type(arg2) ~= "function" then
				return true
			end
			local ok, result = pcall(arg2)
			return ok and result == true
		end

		local function fn43(arg5, arg6)
			local n2 = tick() + 0.8
			local n3 = 0

			while true do
				if not fn41() then
					return false, true
				else
					if not v9.Parent or v9.Character ~= arg5 then
						return true, false
					end
					local character_ = v9.Character
					local humanoid = character_ and character_:FindFirstChildOfClass("Humanoid")
					if not character_ or not character_:IsDescendantOf(workspace) or not humanoid or humanoid.Health <= 0 then
						return true, false
					end

					if not fn42() then
						return false, true
					end
					local v10 = fn40(v9)

					if v10 and arg6 then
						n3 = (v10.Position - arg6).Magnitude
					end

					task.wait(0.1)
					if not (n2 <= tick()) then
						continue
					end
					break
				end
			end

			return n3 >= 30, false
		end

		local flag7 = Hub.AntiFlingEnabled == true

		if flag7 then
			fn37(false)
			RunService.Heartbeat:Wait()
			RunService.Heartbeat:Wait()

			if not fn42() or not fn41() then
				if Hub.AntiFlingEnabled then
					fn37(true)
				end

				return false
			end
		end

		Hub.FlingActive = true

		if type(arg2) == "function" then
			task.spawn(function()
				while Hub.FlingActive do
					if not fn42() then
						Hub.FlingActive = false
						break
					else
						task.wait(0.05)
					end
				end
			end)
		end

		local n2 = math.clamp(tonumber(arg3) or 3, 1, 3)
		local flag8 = false

		for i = 1, n2 do
			if not (not Hub.FlingActive or not fn42()) then
				if not (not v9 or not v9.Parent) then
					local position = fn40(v9)
					position = position and position.Position
					local character_ = v9.Character

					local ok = pcall(function()
						fn39(v9)
					end)

					if fn41() then
						local flag9 = false
						local flag10 = false

						if ok then
							flag9, flag10 = fn43(character_, position)
						end

						if flag9 then
							flag8 = true
							break
						elseif not (flag10 or not fn41()) then
							if i < n2 then
								task.wait(0.25)
							end

							continue
						end
					end
				end
			end

			break
		end

		Hub.FlingActive = false

		if flag7 and Hub.AntiFlingEnabled then
			fn37(true)
		end

		local character_ = localPlayer.Character
		character_ = character_ and character_:FindFirstChildOfClass("Humanoid")
		local currentCamera2 = workspace.CurrentCamera

		if currentCamera2 and character_ then
			currentCamera2.CameraSubject = character_
		end

		if flag8 and not arg4 then
			fn38()
		end

		return flag8
	end

	fn21 = function()
		if not Hub.FlingActive then
			return
		end
		Hub.FlingActive = false
		local character_ = localPlayer.Character
		character_ = character_ and character_:FindFirstChildOfClass("Humanoid")
		local currentCamera2 = workspace.CurrentCamera

		if currentCamera2 and character_ then
			currentCamera2.CameraSubject = character_
		end
	end

	local tbl7 = { antiFlingController = nil }

	local function fn41()
		local tbl8 = {
			enabled = false,
			connections = {},
			playerConnections = {},
			characterConnections = {},
			parts = {},
			originalCollision = {},
			lastSafeCFrame = nil,
			lastRoot = nil,
			motionAccumulator = 0,
			motionRefreshRate = 0.033333333333333333,
			collisionAccumulator = 0,
			collisionRefreshRate = 0.1,
			horizontalLimit = 120,
			verticalLimit = 500,
			angularLimit = 45,
		}

		local function fn42(arg)
			if arg then
				arg:Disconnect()
			end
		end

		local function fn43(arg, arg2)
			if not arg2:IsA("BasePart") then
				return
			end
			local v9 = tbl8.parts[arg]
			if not v9 or v9[arg2] then
				return
			end
			v9[arg2] = true
			tbl8.originalCollision[arg2] = arg2.CanCollide

			if tbl8.enabled then
				arg2.CanCollide = false
			end
		end

		local function fn44(arg)
			local v9 = tbl8.parts[arg]
			if not v9 then
				return
			end

			for k in pairs(v9) do
				if k.Parent then
					local v10 = tbl8.originalCollision[k]

					if v10 ~= nil then
						k.CanCollide = v10
					end
				end

				tbl8.originalCollision[k] = nil
			end
		end

		local function fn45(arg)
			fn44(arg)
			local v9 = tbl8.characterConnections[arg]

			if v9 then
				for _, v10 in ipairs(v9) do
					fn42(v10)
				end
			end

			tbl8.characterConnections[arg] = nil
			tbl8.parts[arg] = nil
		end

		local function fn46(character_)
			if not tbl8.enabled or not character_ or character_ == localPlayer.Character then
				return
			end
			fn45(character_)
			tbl8.parts[character_] = {}
			tbl8.characterConnections[character_] = {}

			for _, descendant in ipairs(character_:GetDescendants()) do
				fn43(character_, descendant)
			end

			table.insert(tbl8.characterConnections[character_], character_.DescendantAdded:Connect(function(descendant)
				fn43(character_, descendant)
			end))

			table.insert(tbl8.characterConnections[character_], character_.DescendantRemoving:Connect(function(descendant)
				local v9 = tbl8.parts[character_]

				if v9 then
					v9[descendant] = nil
				end

				tbl8.originalCollision[descendant] = nil
			end))
		end

		local function fn47(player)
			local v9 = tbl8.playerConnections[player]

			if v9 then
				for _, v10 in ipairs(v9) do
					fn42(v10)
				end
			end

			tbl8.playerConnections[player] = nil

			if player.Character then
				fn45(player.Character)
			end
		end

		local function fn48(player)
			if not tbl8.enabled or player == localPlayer then
				return
			end
			fn47(player)
			local characterRemoving = player.CharacterRemoving
			local connect = characterRemoving.Connect
			tbl8.playerConnections[player] = { player.CharacterAdded:Connect(fn46), connect(characterRemoving, fn45) }

			if player.Character then
				fn46(player.Character)
			end
		end

		local function fn49()
			tbl8.enabled = false
			local tbl9 = {}

			for k in pairs(tbl8.parts) do
				table.insert(tbl9, k)
			end

			for _, v9 in ipairs(tbl9) do
				fn45(v9)
			end

			for _, playerConnection in pairs(tbl8.playerConnections) do
				for _, v9 in ipairs(playerConnection) do
					fn42(v9)
				end
			end

			for _, connection in ipairs(tbl8.connections) do
				fn42(connection)
			end

			table.clear(tbl8.connections)
			table.clear(tbl8.playerConnections)
			table.clear(tbl8.characterConnections)
			table.clear(tbl8.parts)
			table.clear(tbl8.originalCollision)
			tbl8.lastSafeCFrame = nil
			tbl8.lastRoot = nil
			tbl8.motionAccumulator = 0
			tbl8.collisionAccumulator = 0
		end

		local function fn50()
			if tbl8.enabled then
				return
			end
			tbl8.enabled = true

			for _, player in ipairs(Players:GetPlayers()) do
				fn48(player)
			end

			table.insert(tbl8.connections, Players.PlayerAdded:Connect(fn48))
			table.insert(tbl8.connections, Players.PlayerRemoving:Connect(fn47))

			table.insert(tbl8.connections, RunService.Heartbeat:Connect(function(deltaTime)
				if not tbl8.enabled then
					return
				end
				tbl8.motionAccumulator = tbl8.motionAccumulator + deltaTime
				if tbl8.motionAccumulator < tbl8.motionRefreshRate then
					return
				end
				local motionAccumulator = tbl8.motionAccumulator
				tbl8.motionAccumulator = 0
				local character_ = localPlayer.Character
				local humanoidRootPart = character_ and character_:FindFirstChild("HumanoidRootPart")
				character_ = character_ and character_:FindFirstChildOfClass("Humanoid")

				if not humanoidRootPart or not character_ then
					tbl8.lastSafeCFrame = nil
					tbl8.lastRoot = nil
					return
				end

				if tbl8.lastRoot ~= humanoidRootPart then
					tbl8.lastRoot = humanoidRootPart
					tbl8.lastSafeCFrame = nil
				end

				local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
				local magnitude = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude
				local n2 = math.abs(assemblyLinearVelocity.Y)
				local magnitude2 = assemblyLinearVelocity.Magnitude
				local magnitude3 = humanoidRootPart.AssemblyAngularVelocity.Magnitude
				local flag7 = Hub.CoinFarm.enabled and Hub.CoinFarm.currentCoin ~= nil and (Hub.CoinFarm.phase == "Farming" or Hub.CoinFarm.phase == "Avoiding Murderer")

				if not (Hub.FlingActive or Hub.FlyEnabled or flag7) and character_.FloorMaterial ~= Enum.Material.Air and magnitude2 < 45 and magnitude3 < 15 then
					tbl8.lastSafeCFrame = humanoidRootPart.CFrame
				end

				local flag8 = not Hub.FlingActive and not Hub.FlyEnabled

				if flag8 then
					flag8 = magnitude > tbl8.horizontalLimit or n2 > tbl8.verticalLimit or magnitude3 > tbl8.angularLimit
				end

				if flag8 then
					humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
					humanoidRootPart.AssemblyAngularVelocity = Vector3.zero

					if not flag7 and tbl8.lastSafeCFrame then
						humanoidRootPart.CFrame = tbl8.lastSafeCFrame + Vector3.new(0, 2, 0)
					end

					character_:ChangeState(Enum.HumanoidStateType.GettingUp)
				end

				tbl8.collisionAccumulator = tbl8.collisionAccumulator + motionAccumulator
				if tbl8.collisionAccumulator < tbl8.collisionRefreshRate then
					return
				end
				tbl8.collisionAccumulator = 0

				for _, part in pairs(tbl8.parts) do
					for k in pairs(part) do
						if k.Parent and k.CanCollide then
							k.CanCollide = false
						end
					end
				end
			end))
		end

		tbl8.SetEnabled = function(arg, arg2)
			if arg2 then
				fn50()
			else
				fn49()
			end

			return arg.enabled
		end

		tbl8.Destroy = function()
			fn49()
		end

		return tbl8
	end

	fn37 = function(arg)
		if arg and not tbl7.antiFlingController then
			tbl7.antiFlingController = fn41()
		end

		local antiFlingController = tbl7.antiFlingController

		if antiFlingController then
			local ok, result = pcall(antiFlingController.SetEnabled, antiFlingController, arg and true or false)
			if not ok then
				warn("[ANTI FLING ERROR] " .. tostring(result))
				return false
			end
		end

		return true
	end

	Hub.SetAntiFlingSource = function(arg, arg2)
		if arg ~= "manual" then
			return false
		end
		Hub.AntiFlingSources[arg] = arg2 and true or false
		local manual = Hub.AntiFlingSources.manual

		if manual and not Hub.AntiFlingEnabled then
			Hub.AntiFlingEnabled = fn37(true) == true
		elseif not manual and Hub.AntiFlingEnabled then
			fn37(false)
			Hub.AntiFlingEnabled = false
		end

		return Hub.AntiFlingEnabled
	end

	fn22 = function()
		local currentCamera2 = workspace.CurrentCamera

		if currentCamera2 and localChar.humanoid then
			currentCamera2.CameraType = Enum.CameraType.Custom
			currentCamera2.CameraSubject = localChar.humanoid
		end
	end

	local function fn42()
		local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
		return humanoidRootPart and humanoidRootPart.Position or Vector3.new(0, 200, 0)
	end

	local function createPart()
		if Hub.SafezonePart and Hub.SafezonePart.Parent then
			return Hub.SafezonePart
		end
		local v9 = workspace:FindFirstChild(Hub.WorldFeatureConfig.safezoneModelName)

		if v9 and v9:IsA("Model") then
			local base = v9:FindFirstChild("Base") or v9:FindFirstChildWhichIsA("BasePart")
			if base then
				Hub.SafezonePart = base
				return base
			end
		end

		local model = Instance.new("Model")
		model.Name = Hub.WorldFeatureConfig.safezoneModelName
		model.Parent = workspace
		local part = Instance.new("Part")
		part.Name = "Base"
		part.Size = Vector3.new(40, 1, 40)
		part.Anchored = true
		part.CanCollide = true
		part.Material = Enum.Material.Neon
		part.Color = Color3.fromRGB(0, 170, 255)
		part.Transparency = 0.2
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		part.Parent = model
		part.CFrame = CFrame.new(fn42() + Vector3.new(10000, 150, 0))
		Hub.SafezonePart = part
		return part
	end

	fn23 = function()
		local character_ = localPlayer.Character or localPlayer.CharacterAdded:Wait()

		if character_ then
			character_ = character_:FindFirstChild("HumanoidRootPart") or character_:WaitForChild("HumanoidRootPart", 5)
		end

		if not character_ then
			return false
		end
		local v9 = createPart()
		if not v9 then
			return false
		end
		local cFrame = v9.CFrame + Vector3.new(0, 3, 0)
		character_.CFrame = cFrame

		task.delay(0.15, function()
			local character_2 = localPlayer.Character
			character_2 = character_2 and character_2:FindFirstChild("HumanoidRootPart")
			if not character_2 then
				return
			end

			if (character_2.Position - cFrame.Position).Magnitude > 4 then
				character_2.CFrame = cFrame
			end
		end)

		return true
	end

	fn24 = function(arg)
		return arg and arg:IsA("BasePart") and arg.Name == "GunDrop"
	end

	local function fn43()
		local gunDrop = workspace:FindFirstChild("GunDrop")
		return gunDrop ~= nil and gunDrop:IsA("BasePart")
	end

	local function fn44(lastGunDropPicker)
		if not lastGunDropPicker then
			return
		end
		Hub.RoleState.lastGunDropPicker = lastGunDropPicker
		Hub.RoleState.lastGunDropAt = tick()
	end

	local function fn45()
		if not Hub.RoleState.lastGunDropPicker or not Hub.RoleState.lastGunDropPicker.Parent then
			return nil
		end
		local lastGunDropAt = Hub.RoleState.lastGunDropAt
		if Hub.RoleState.gunDropPickerTtl < tick() - lastGunDropAt then
			return nil
		end
		return Hub.RoleState.lastGunDropPicker
	end

	Hub.LobbyCache = workspace:FindFirstChild("Lobby")

	local function fn46()
		if Hub.LobbyCache and Hub.LobbyCache.Parent then
			return Hub.LobbyCache
		end
		Hub.LobbyCache = workspace:FindFirstChild("Lobby")
		return Hub.LobbyCache
	end

	fn25 = function(arg)
		local v9 = fn46()
		arg = arg and arg.Character
		return v9 and arg and arg:IsDescendantOf(v9)
	end

	fn26 = function(arg)
		local character_ = arg and arg.Character
		character_ = character_ and character_:FindFirstChildOfClass("Humanoid")
		return character_ and character_.Health > 0
	end

	fn27 = function(arg)
		if not arg or type(Hub.RoleState.cache) ~= "table" then
			return nil
		end
		local v9 = Hub.RoleState.cache[arg.Name] or Hub.RoleState.cache[tostring(arg.UserId)] or Hub.RoleState.cache[arg.UserId]
		if type(v9) ~= "table" then
			return nil
		end
		local role = v9.Role
		if role == "Murderer" or role == "Sheriff" or role == "Innocent" then
			return role
		end
		return nil
	end

	fn28 = nil

	fn29 = function(arg)
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= localPlayer and player.Character then
				if fn28(player) == arg then
					return player
				end
			end
		end

		return nil
	end

	fn30 = function()
		for _, player in ipairs(Players:GetPlayers()) do
			if not fn26(player) then
				continue
			end
			local backpack = player:FindFirstChildOfClass("Backpack")
			if backpack and backpack:FindFirstChild("Knife") then
				return player
			end
		end

		for _, player in ipairs(Players:GetPlayers()) do
			if not fn26(player) then
				continue
			end
			local character_ = player.Character
			if character_ and character_:FindFirstChild("Knife") then
				return player
			end
		end

		for _, player in ipairs(Players:GetPlayers()) do
			if fn26(player) and fn27(player) == "Murderer" then
				return player
			end
		end

		return nil
	end

	fn31 = function()
		for _, player in ipairs(Players:GetPlayers()) do
			if not fn26(player) then
				continue
			end
			local backpack = player:FindFirstChildOfClass("Backpack")
			if backpack and backpack:FindFirstChild("Gun") then
				return player
			end
		end

		for _, player in ipairs(Players:GetPlayers()) do
			if not fn26(player) then
				continue
			end
			local character_ = player.Character
			if character_ and character_:FindFirstChild("Gun") then
				return player
			end
		end

		local v9 = fn45()
		if v9 and fn26(v9) then
			return v9
		end

		if not fn43() then
			for _, player in ipairs(Players:GetPlayers()) do
				if fn26(player) and fn27(player) == "Sheriff" then
					return player
				end
			end
		end

		return nil
	end

	fn28 = function(arg)
		if not arg or not fn26(arg) then
			return "Innocent"
		end

		if arg == fn30() then
			return "Murderer"
		end

		if arg == fn31() then
			return "Sheriff"
		end
		return "Innocent"
	end

	Hub.CoinFarm.flingMurderer = function()
		local v9 = fn30()
		if not v9 or v9 == localPlayer then
			return false
		end
		return fn20(v9.Name) == true
	end

	Hub.CoinFarm.getSheriffFlingTarget = function()
		for _, player in ipairs(Players:GetPlayers()) do
			local v9 = Hub.RoleState.cache[player.Name] or Hub.RoleState.cache[tostring(player.UserId)] or Hub.RoleState.cache[player.UserId]
			if type(v9) == "table" and v9.Dead ~= true and v9.Role == "Sheriff" then
				return player
			end
		end

		local v9 = fn31()
		return v9 ~= localPlayer and v9 or nil
	end

	Hub.CoinFarm.flingSheriff = function(arg, arg2)
		if not arg2 or arg2 == localPlayer then
			return false
		end

		local function fn47()
			if not Hub.CoinFarm.enabled or not Hub.CoinFarm.endRoundEnabled or not Hub.RoundState.active or not Hub.CoinFarm.IsLocalPlayerInRound() or arg and Hub.CoinFarm.endRoundGeneration ~= arg then
				return false
			end
			local character_ = arg2.Character
			local humanoid = character_ and character_:FindFirstChildOfClass("Humanoid")
			local v9 = Hub.RoleState.cache[arg2.Name] or Hub.RoleState.cache[tostring(arg2.UserId)] or Hub.RoleState.cache[arg2.UserId]
			local flag7 = type(v9) == "table" and v9.Dead ~= true and v9.Role == "Sheriff"
			local backpack = arg2:FindFirstChildOfClass("Backpack")
			backpack = character_:FindFirstChild("Gun") ~= nil or backpack and backpack:FindFirstChild("Gun") ~= nil
			return humanoid ~= nil and humanoid.Health > 0 and character_:IsDescendantOf(workspace) and character_:FindFirstChild("HumanoidRootPart") ~= nil and (flag7 or backpack)
		end

		if not fn47() then
			return false
		end
		return fn20(arg2.Name, fn47, 3) == true
	end

	task.spawn(function()
		local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:WaitForChild("Remotes", 8)

		if remotes then
			remotes = remotes:FindFirstChild("Gameplay") or remotes:WaitForChild("Gameplay", 8)
		end

		local playerDataChanged = remotes and (remotes:FindFirstChild("PlayerDataChanged") or remotes:WaitForChild("PlayerDataChanged", 8))
		local modules = ReplicatedStorage:FindFirstChild("Modules")
		local currentRoundClient = modules and (modules:FindFirstChild("CurrentRoundClient") or modules:WaitForChild("CurrentRoundClient", 8))

		if currentRoundClient then
			local ok, result = pcall(require, currentRoundClient)
			ok = ok and type(result) == "table" and result.PlayerData or nil

			if type(ok) == "table" then
				Hub.RoleState.cache = ok
				Hub.RoundState.active = next(ok) ~= nil
				Hub.RoundState.coinsReady = Hub.RoundState.active
				Hub.CoinFarm.OnPlayerDataChanged()
			end
		end

		Hub.RoundState.initialized = true
		local v9 = nil
		local v10 = nil

		local function fn47()
			if Hub.MobileRoundTimerGui then
				Hub.MobileRoundTimerGui:Destroy()
				Hub.MobileRoundTimerGui = nil
			end
		end

		local function fn48()
			if Hub.MobileRoundTimerGui and Hub.MobileRoundTimerGui.Parent then
				return Hub.MobileRoundTimerGui:FindFirstChild("Timer")
			end
			local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
			if not playerGui then
				return nil
			end
			local foxnameMobileRoundTimer = playerGui:FindFirstChild("FoxnameMobileRoundTimer")

			if foxnameMobileRoundTimer then
				foxnameMobileRoundTimer:Destroy()
			end

			local screenGui = Instance.new("ScreenGui")
			screenGui.Name = "FoxnameMobileRoundTimer"
			screenGui.ResetOnSpawn = false
			screenGui.IgnoreGuiInset = false
			screenGui.DisplayOrder = 20
			screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			local mainGUI = playerGui:FindFirstChild("MainGUI")
			mainGUI = mainGUI and mainGUI:FindFirstChild("Game")
			mainGUI = mainGUI and mainGUI:FindFirstChild("Timer")
			local clone

			if mainGUI and mainGUI:IsA("Frame") then
				clone = mainGUI:Clone()
			else
				clone = Instance.new("Frame")
				clone.BackgroundTransparency = 1
				clone.Size = UDim2.fromOffset(150, 75)
				local textLabel = Instance.new("TextLabel")
				textLabel.Name = "XPText"
				textLabel.BackgroundTransparency = 1
				textLabel.Position = UDim2.fromOffset(0, 15)
				textLabel.Size = UDim2.new(1, 0, 0, 40)
				textLabel.Font = Enum.Font.SourceSansBold
				textLabel.TextColor3 = Color3.new(1, 1, 1)
				textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
				textLabel.TextStrokeTransparency = 0
				textLabel.TextSize = 48
				textLabel.Parent = clone
			end

			clone.Name = "Timer"
			clone.Position = UDim2.new(0.5, -75, 0, 0)
			clone.Size = UDim2.fromOffset(150, 75)
			clone.Visible = false
			clone.Parent = screenGui
			screenGui.Parent = playerGui
			Hub.MobileRoundTimerGui = screenGui
			return clone
		end

		local function updateRoundTimer()
			local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
			if not playerGui then
				return
			end

			if not Hub.ShowRoundTimer then
				fn47()
				return
			end
			local v11 = fn48()
			local xpText = v11 and v11:FindFirstChild("XPText")
			if not v11 or not v11:IsA("GuiObject") then
				return
			end
			local mainGUI = playerGui:FindFirstChild("MainGUI")
			mainGUI = mainGUI and mainGUI:FindFirstChild("Game")
			mainGUI = mainGUI and mainGUI:FindFirstChild("Timer")
			mainGUI = mainGUI and mainGUI:FindFirstChild("XPText")
			local text = mainGUI and mainGUI:IsA("TextLabel") and mainGUI.Text or ""
			local roundTimerPart = workspace:FindFirstChild("RoundTimerPart")
			local n2 = roundTimerPart and tonumber(roundTimerPart:GetAttribute("Time")) or -1
			local visible = Hub.RoundState.active and (text ~= "" or n2 > 0)
			v11.Visible = visible

			if visible and xpText and xpText:IsA("TextLabel") then
				if text ~= "" then
					xpText.Text = text
				else
					local n3 = math.max(0, math.floor(n2))
					local n4 = math.floor(n3 / 60)
					xpText.Text = (n4 > 0 and tostring(n4) .. "m " or "") .. tostring(n3 - n4 * 60) .. "s"
				end
			end
		end

		Hub.UpdateRoundTimer = updateRoundTimer

		local function fn49()
			if v9 then
				v9:Disconnect()
				v9 = nil
			end

			if v10 then
				v10:Disconnect()
				v10 = nil
			end

			local roundTimerPart = workspace:FindFirstChild("RoundTimerPart")

			if roundTimerPart then
				v9 = trackConn(roundTimerPart:GetAttributeChangedSignal("Time"):Connect(function()
					task.defer(updateRoundTimer)
				end))
			end

			local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
			playerGui = playerGui and playerGui:FindFirstChild("MainGUI")
			playerGui = playerGui and playerGui:FindFirstChild("Game")
			local timer = playerGui and playerGui:FindFirstChild("Timer")
			timer = timer and timer:FindFirstChild("XPText")

			if timer and timer:IsA("TextLabel") then
				v10 = trackConn(timer:GetPropertyChangedSignal("Text"):Connect(function()
					task.defer(updateRoundTimer)
				end))
			end

			task.defer(updateRoundTimer)
		end

		fn49()

		trackConn(workspace.ChildAdded:Connect(function(child)
			if child.Name == "RoundTimerPart" then
				task.defer(fn49)
			end
		end))

		local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

		if playerGui then
			trackConn(playerGui.DescendantAdded:Connect(function(descendant)
				if descendant.Name == "XPText" and descendant.Parent and descendant.Parent.Name == "Timer" and descendant:IsA("TextLabel") and playerGui:FindFirstChild("MainGUI") and descendant:IsDescendantOf(playerGui:FindFirstChild("MainGUI")) then
					task.defer(fn49)
				end
			end))
		end

		if playerDataChanged and playerDataChanged:IsA("RemoteEvent") then
			trackConn(playerDataChanged.OnClientEvent:Connect(function(cache)
				if type(cache) ~= "table" then
					return
				end
				Hub.RoleState.cache = cache
				Hub.CoinFarm.OnPlayerDataChanged()
				Hub.CoinFarm.RefreshStats()

				if next(cache) == nil then
					Hub.RoundState.active = false
					Hub.RoundState.coinsReady = false
					Hub.CoinFarm.OnRoundEnded()
					task.defer(updateRoundTimer)
				end
			end))
		end

		local roundStart = remotes and remotes:FindFirstChild("RoundStart")

		if roundStart and roundStart:IsA("RemoteEvent") then
			trackConn(roundStart.OnClientEvent:Connect(function(arg, cache)
				if type(cache) == "table" then
					Hub.RoleState.cache = cache
				else
					Hub.RoleState.cache = {}
				end

				Hub.RoundState.active = true
				Hub.RoundState.coinsReady = false
				Hub.RoundState.startedAt = os.clock()
				Hub.CoinFarm.OnRoundStarted()
				task.defer(updateRoundTimer)
			end))
		end

		local coinsStarted = remotes and remotes:FindFirstChild("CoinsStarted")

		if coinsStarted and coinsStarted:IsA("RemoteEvent") then
			trackConn(coinsStarted.OnClientEvent:Connect(function(arg)
				Hub.RoundState.coinsReady = Hub.RoundState.active and type(arg) == "table" and (arg.Coin ~= nil or arg.Candy ~= nil)
				Hub.CoinFarm.OnCoinsStarted(arg)
			end))
		end

		local coinCollected = remotes and remotes:FindFirstChild("CoinCollected")

		if coinCollected and coinCollected:IsA("RemoteEvent") then
			trackConn(coinCollected.OnClientEvent:Connect(function(arg, arg2, arg3)
				local currency = tostring(arg)
				if currency ~= "Coin" and currency ~= "Candy" then
					return
				end
				local num = tonumber(arg2)
				local num2 = tonumber(arg3)

				if not (num and num2 and num > num2) then
					local v11 = num2
					num2 = num
					num = v11
				end

				if not num2 then
					num2 = (Hub.CoinFarm.bagCurrentValue or Hub.CoinFarm.lastBagCount or Hub.CoinFarm.GetBagCount() or 0) + 1
				end

				Hub.CoinFarm.MarkCurrentCollected()
				Hub.CoinFarm.ApplyBagCount(num2, num)
			end))
		end

		local function fn50()
			Hub.RoundState.active = false
			Hub.RoundState.coinsReady = false
			Hub.CoinFarm.OnRoundEnded()
			task.defer(updateRoundTimer)
		end

		local fn51 = nil

		fn51 = function(arg)
			if typeof(arg) == "Instance" then
				if arg:IsA("Model") or arg:IsA("Folder") then
					return arg.Name, arg
				end
				return nil, nil
			end

			if type(arg) == "string" then
				local match = arg:match("^%s*(.-)%s*$")
				if match ~= "" then
					return match, nil
				end
				return nil, nil
			end

			if type(arg) ~= "table" then
				return nil, nil
			end

			for _, v11 in ipairs({ "MapName", "mapName", "Name", "name", "Map", "map", "MapModel", "mapModel" }) do
				local v12, v13 = fn51(arg[v11])
				if v12 then
					return v12, v13
				end
			end

			return nil, nil
		end

		local loadingMap = remotes and remotes:FindFirstChild("LoadingMap")

		if loadingMap and loadingMap:IsA("RemoteEvent") then
			trackConn(loadingMap.OnClientEvent:Connect(function(...)
				fn50()
				Hub.RoundState.currentMapName = nil
				Hub.RoundState.currentMapInstance = nil
				Hub.RoundState.mapReceivedAt = os.clock()
				local v11 = table.pack(...)

				for i = 1, v11.n do
					local v12, v13 = fn51(v11[i])

					if v12 then
						Hub.RoundState.currentMapName = v12
						Hub.RoundState.currentMapInstance = v13
						break
					end
				end
			end))
		end

		for _, v11 in ipairs({ "VictoryScreen", "GameOver", "RoundEndFade" }) do
			local v12 = remotes and remotes:FindFirstChild(v11)

			if v12 and v12:IsA("RemoteEvent") then
				trackConn(v12.OnClientEvent:Connect(fn50))
			end
		end
	end)

	fn32 = function(arg)
		local v9 = Hub.ESPTable[arg]
		if not v9 then
			return
		end
		fn15(v9.Line)

		if v9.BoxLines then
			for _, boxLine in pairs(v9.BoxLines) do
				boxLine:Remove()
			end
		end

		for _, v10 in pairs(v9) do
			if typeof(v10) == "Instance" then
				v10:Destroy()
			end
		end

		Hub.ESPTable[arg] = nil
	end

	local function fn47(arg, adornee)
		fn32(arg)
		local head = adornee:FindFirstChild("Head") or adornee:WaitForChild("Head", 5)
		local humanoidRootPart = adornee:FindFirstChild("HumanoidRootPart") or adornee:WaitForChild("HumanoidRootPart", 5)
		if not head or not humanoidRootPart then
			return
		end
		local highlight = Instance.new("Highlight")
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Adornee = adornee
		highlight.Enabled = false
		highlight.Parent = adornee
		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Size = UDim2.fromOffset(220, 32)
		billboardGui.StudsOffset = Vector3.new(0, 2.75, 0)
		billboardGui.AlwaysOnTop = true
		billboardGui.Enabled = false
		billboardGui.Parent = head
		local textLabel = Instance.new("TextLabel", billboardGui)
		textLabel.Size = UDim2.fromScale(1, 1)
		textLabel.BackgroundTransparency = 1
		textLabel.TextScaled = false
		textLabel.TextSize = 14
		textLabel.Font = Enum.Font.GothamBold
		local uiGradient = Instance.new("UIGradient")
		uiGradient.Color = Hub.OwnerESPGradient
		uiGradient.Enabled = false
		uiGradient.Parent = textLabel
		local uiStroke = Instance.new("UIStroke", textLabel)
		uiStroke.Thickness = 1.25
		uiStroke.Color = Color3.new(0, 0, 0)
		local v9 = createFrame(2)
		local v10, v11 = fn35()

		Hub.ESPTable[arg] = {
			Highlight = highlight,
			Billboard = billboardGui,
			Text = textLabel,
			OwnerGradient = uiGradient,
			Line = v9,
			Arrow = v10,
			ArrowDistance = v11,
			BoxLines = {},
			HRP = humanoidRootPart,
			Head = head,
		}
	end

	local function fn48(arg)
		if arg == localPlayer then
			return
		end

		if arg.Character then
			fn47(arg, arg.Character)
		end

		if not Hub.ESPPlayerConnections[arg] then
			Hub.ESPPlayerConnections[arg] = arg.CharacterAdded:Connect(function(character_)
				fn47(arg, character_)
			end)
		end
	end

	fn33 = function(arg)
		local v9 = arg and Hub.GunESPTable[arg]
		if not Hub.DroppedGunNotify or not v9 or v9.Notified then
			return
		end
		v9.Notified = true
		local character_ = localPlayer.Character
		character_ = character_ and character_:FindFirstChild("HumanoidRootPart")
		character_ = character_ and math.floor((arg.Position - character_.Position).Magnitude + 0.5)

		WindUI:Notify({
			Title = "Dropped Gun",
			Content = character_ and "A dropped gun was detected " .. tostring(character_) .. " studs away." or "A dropped gun was detected.",
			Icon = "locate-fixed",
			Duration = 4,
		})
	end

	local function fn49(parent)
		if Hub.GunESPTable[parent] then
			return
		end
		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Size = UDim2.fromOffset(120, 40)
		billboardGui.AlwaysOnTop = true
		billboardGui.StudsOffset = Vector3.new(0, 3, 0)
		billboardGui.Enabled = Hub.GunESP
		local textLabel = Instance.new("TextLabel", billboardGui)
		textLabel.Size = UDim2.fromScale(1, 1)
		textLabel.BackgroundTransparency = 1
		textLabel.Font = Enum.Font.GothamBold
		textLabel.TextSize = 32
		textLabel.Text = "GUN"
		textLabel.TextStrokeTransparency = 0.5
		textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
		billboardGui.Parent = parent
		local v9 = createFrame(2)
		v9.Visible = Hub.GunESP
		local v10, v11 = fn35()

		Hub.GunESPTable[parent] = {
			Billboard = billboardGui,
			TextLabel = textLabel,
			Line = v9,
			Arrow = v10,
			ArrowDistance = v11,
			Notified = false,
			TouchedConnection = parent.Touched:Connect(function(hit)
				local model = hit and hit:FindFirstAncestorOfClass("Model")
				local playerFromCharacter = model and Players:GetPlayerFromCharacter(model)

				if playerFromCharacter then
					fn44(playerFromCharacter)
				end
			end),
		}

		fn33(parent)
	end

	local color = Color3.fromRGB(255, 190, 35)

	local function fn50(arg)
		return arg and arg:IsA("BasePart") and (arg.Name == "Coin_Server" or arg.Name == "Candy_Server")
	end

	local function fn51(arg)
		local v9 = Hub.CoinESPTable[arg]

		if v9 then
			pcall(function()
				v9:Destroy()
			end)

			Hub.CoinESPTable[arg] = nil
		end
	end

	local function fn52(arg)
		local coinVisual = arg and arg:FindFirstChild("CoinVisual")
		if not coinVisual then
			return arg
		end

		if coinVisual:IsA("Model") then
			return coinVisual
		end
		local mainCoin = coinVisual:FindFirstChild("MainCoin", true)
		if mainCoin and mainCoin:IsA("BasePart") and mainCoin.Transparency < 0.99 and mainCoin.LocalTransparencyModifier < 0.99 then
			return mainCoin
		end

		for _, descendant in ipairs(coinVisual:GetDescendants()) do
			if descendant:IsA("BasePart") and descendant.Transparency < 0.99 and descendant.LocalTransparencyModifier < 0.99 then
				return descendant
			end
		end

		return coinVisual
	end

	local function fn53(parent)
		if not Hub.CoinESP or not fn50(parent) or Hub.CoinESPTable[parent] then
			return
		end
		local folder = Instance.new("Folder")
		folder.Name = "FoxnameCoinESP"
		folder.Parent = parent
		local highlight = Instance.new("Highlight")
		highlight.Name = "Highlight"
		highlight.Adornee = fn52(parent)
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.FillColor = color
		highlight.FillTransparency = 0.3
		highlight.OutlineColor = Color3.fromRGB(255, 226, 110)
		highlight.OutlineTransparency = 0
		highlight.Parent = folder
		Hub.CoinESPTable[parent] = folder

		task.defer(function()
			if Hub.CoinESP and parent.Parent and folder.Parent and highlight.Parent then
				highlight.Adornee = fn52(parent)
			end
		end)
	end

	local function disconnectCoinESPMap(arg)
		Hub.CoinESPGeneration = Hub.CoinESPGeneration + 1

		if Hub.CoinESPAddedConnection then
			Hub.CoinESPAddedConnection:Disconnect()
			Hub.CoinESPAddedConnection = nil
		end

		if Hub.CoinESPRemovingConnection then
			Hub.CoinESPRemovingConnection:Disconnect()
			Hub.CoinESPRemovingConnection = nil
		end

		Hub.CoinESPMap = nil
		Hub.CoinESPContainer = nil

		if arg then
			for k in pairs(Hub.CoinESPTable) do
				fn51(k)
			end
		end
	end

	Hub.DisconnectCoinESPMap = disconnectCoinESPMap

	local function fn54(arg)
		if not arg or not arg.Parent then
			return nil
		end
		local coinContainer = arg:FindFirstChild("CoinContainer") or arg:FindFirstChild("CandyContainer") or arg:FindFirstChild("CoinContainer", true) or arg:FindFirstChild("CandyContainer", true)
		if coinContainer and (coinContainer:IsA("Model") or coinContainer:IsA("Folder")) then
			return coinContainer
		end
		return nil
	end

	local function refreshCoinESP()
		disconnectCoinESPMap(true)
		if not Hub.CoinESP then
			return false
		end
		local coinESPGeneration = Hub.CoinESPGeneration
		local v9 = Hub.CoinFarm.ResolveMap()
		if not v9 then
			return false
		end
		local v10 = fn54(v9)
		local v11 = v10 or v9
		Hub.CoinESPMap = v9
		Hub.CoinESPContainer = v10
		local descendants = v11:GetDescendants()

		for i, descendant in ipairs(descendants) do
			if not Hub.CoinESP or Hub.CoinESPMap ~= v9 or Hub.CoinESPGeneration ~= coinESPGeneration then
				return false
			end

			if fn50(descendant) then
				fn53(descendant)
			end

			if i % 100 == 0 then
				RunService.Heartbeat:Wait()
			end
		end

		if not Hub.CoinESP or not v11.Parent or Hub.CoinESPGeneration ~= coinESPGeneration then
			return false
		end

		Hub.CoinESPAddedConnection = v11.DescendantAdded:Connect(function(descendant)
			if Hub.CoinESP and fn50(descendant) then
				fn53(descendant)
			end
		end)

		Hub.CoinESPRemovingConnection = v11.DescendantRemoving:Connect(function(descendant)
			if Hub.CoinESPTable[descendant] then
				fn51(descendant)
			end
		end)

		return true
	end

	Hub.RefreshCoinESP = refreshCoinESP

	local function fn55()
		task.spawn(function()
			for i = 1, 40 do
				if not Hub.CoinESP then
					return
				end

				if refreshCoinESP() then
					return
				end
				task.wait(0.2)
			end
		end)
	end

	fn34 = function(arg)
		Hub.CoinESP = arg and true or false
		if not Hub.CoinESP then
			disconnectCoinESPMap(true)
			return
		end
		fn55()
	end

	local function fn56(arg, arg2)
		local flag7 = not arg2
		if flag7 and not Hub.AutoGunTouchEnabled then
			return
		end

		if flag7 and Hub.CoinFarm.enabled and Hub.CoinFarm.GetCachedRole(localPlayer) == "Murderer" then
			return
		end

		if Hub.AutoGunTouchPending[arg] then
			return
		end
		Hub.AutoGunTouchPending[arg] = true

		task.spawn(function()
			if not arg or not arg.Parent then
				Hub.AutoGunTouchPending[arg] = nil
				return
			end
			local character_ = localPlayer.Character
			local humanoidRootPart

			if character_ then
				humanoidRootPart = character_:FindFirstChild("HumanoidRootPart") or character_:FindFirstChild("Torso")
			else
				humanoidRootPart = character_
			end

			local humanoid = character_ and character_:FindFirstChildOfClass("Humanoid")

			if humanoidRootPart and typeof(firetouchinterest) == "function" then
				for i = 1, 4 do
					if not (not arg or not arg.Parent) then
						pcall(function()
							firetouchinterest(humanoidRootPart, arg, 0)
							firetouchinterest(humanoidRootPart, arg, 1)
						end)

						continue
					end

					break
				end
			end

			local touchTransmitter = arg:FindFirstChildOfClass("TouchTransmitter") or arg:FindFirstChild("TouchInterest")

			if touchTransmitter and typeof(firetouchtransmitter) == "function" then
				pcall(function()
					firetouchtransmitter(touchTransmitter)
				end)
			end

			task.spawn(function()
				local backpack = localPlayer:FindFirstChildOfClass("Backpack")

				for i = 1, 10 do
					local gun = backpack and backpack:FindFirstChild("Gun")

					if gun and gun:IsA("Tool") and humanoid and humanoid.Health > 0 then
						pcall(function()
							humanoid:EquipTool(gun)
						end)

						break
					else
						task.wait(0.03)
					end
				end
			end)

			task.wait(0.1)
			Hub.AutoGunTouchPending[arg] = nil
		end)
	end

	Hub.TakeDroppedGunOnce = function()
		local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
		local huge = math.huge
		local v9 = nil

		for k in pairs(Hub.GunESPTable) do
			if fn24(k) and k.Parent then
				local magnitude = humanoidRootPart and (k.Position - humanoidRootPart.Position).Magnitude or 0

				if magnitude < huge then
					huge = magnitude
					v9 = k
				end
			end
		end

		if not v9 then
			local gunDrop = workspace:FindFirstChild("GunDrop")

			if fn24(gunDrop) then
				v9 = gunDrop
			end
		end

		if not v9 then
			WindUI:Notify({ Title = "Get Gun", Content = "No dropped gun was found.", Icon = "x", Duration = 2 })
			return false
		end
		fn56(v9, true)
		return true
	end

	Hub.SetAutoGunTouchSource = function(arg, arg2)
		if arg ~= "misc" then
			return false
		end
		local autoGunTouchEnabled = Hub.AutoGunTouchEnabled
		Hub.AutoGunTouchSources[arg] = arg2 and true or false
		Hub.AutoGunTouchEnabled = Hub.AutoGunTouchSources.misc

		if Hub.AutoGunTouchEnabled and not autoGunTouchEnabled then
			task.spawn(function()
				local descendants = workspace:GetDescendants()

				for i, descendant in ipairs(descendants) do
					if Hub.AutoGunTouchEnabled then
						if fn24(descendant) then
							fn56(descendant)
						end

						if i % 250 == 0 then
							RunService.Heartbeat:Wait()
						end

						continue
					end

					break
				end
			end)
		end

		return Hub.AutoGunTouchEnabled
	end

	trackConn(workspace.DescendantAdded:Connect(function(descendant)
		if fn24(descendant) then
			fn49(descendant)
			fn56(descendant)
		end
	end))

	trackConn(workspace.DescendantRemoving:Connect(function(descendant)
		Hub.AutoGunTouchPending[descendant] = nil

		if Hub.GunESPTable[descendant] then
			local v9 = Hub.GunESPTable[descendant]

			if v9.TouchedConnection then
				v9.TouchedConnection:Disconnect()
			end

			fn15(v9.Line)

			if v9.Arrow then
				v9.Arrow:Destroy()
			end

			if v9.ArrowDistance then
				v9.ArrowDistance:Destroy()
			end

			v9.Billboard:Destroy()
			Hub.GunESPTable[descendant] = nil
		end
	end))

	task.spawn(function()
		local descendants = workspace:GetDescendants()

		for i, descendant in ipairs(descendants) do
			if fn24(descendant) then
				fn49(descendant)
				fn56(descendant)
			end

			if i % 250 == 0 then
				RunService.Heartbeat:Wait()
			end
		end
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		fn48(player)
		fn8(player)
	end

	trackConn(Players.PlayerAdded:Connect(function(player)
		fn48(player)
		fn8(player)
	end))
end

trackConn(Players.PlayerRemoving:Connect(function(player)
	local v9 = Hub.ESPPlayerConnections[player]

	if v9 then
		v9:Disconnect()
		Hub.ESPPlayerConnections[player] = nil
	end

	fn32(player)
end))

Hub.ReexecuteScriptUrl = "https://raw.githubusercontent.com/FoxnameTeam/OSS/main/Murder-Mystery-2/main.luau"
Hub.AdminReexecuteScriptUrl = Hub.ReexecuteScriptUrl
Hub.CoinFarmKickRecoveryStarted = false
Hub.SuppressCoinFarmKickRecovery = false

do
	local function fn35()
		local flag7 = Hub.CoinFarm.sessionStartedAt > 0

		if flag7 then
			local sessionStartedAt = Hub.CoinFarm.sessionStartedAt
			flag7 = math.max(0, os.clock() - sessionStartedAt)
		end

		flag7 = flag7 or 0
		local eventBox = Hub.EventBox

		local ok, result = pcall(HttpService.JSONEncode, HttpService, {
			version = 2,
			savedAt = os.time(),
			enabled = Hub.CoinFarm.enabled == true,
			total = math.max(0, math.floor(tonumber(Hub.CoinFarm.totalCollected) or 0)),
			totalXP = math.max(0, math.floor(tonumber(Hub.CoinFarm.totalEarnedXP) or 0)),
			sessionElapsed = flag7,
			serverHopCount = math.max(0, math.floor(tonumber(Hub.CoinFarm.serverHopCount) or 0)),
			serverHopTimerMinutes = math.clamp(math.floor(tonumber(Hub.CoinFarm.serverHopTimerMinutes) or 15), 10, 30),
			mode = Hub.CoinFarm.mode,
			position = Hub.CoinFarm.position,
			xpFarm = Hub.CoinFarm.xpFarmEnabled == true,
			endRound = Hub.CoinFarm.endRoundEnabled == true,
			serverHopLowPlayers = Hub.CoinFarm.serverHopLowPlayers == true,
			serverHopThreshold = math.clamp(math.floor(tonumber(Hub.CoinFarm.serverHopPlayerThreshold) or 4), 1, 6),
			antiBot = Hub.CoinFarm.antiBotEnabled == true,
			autoPrestige = Hub.AutoPrestige.enabled == true,
			autoClaimRewards = Hub.AutoClaimReward.enabled == true,
			blackScreen = Hub.CoinFarm.blackScreenEnabled == true,
			disable3D = Hub.CoinFarm.disable3DRendering == true,
			eventBox = type(eventBox) == "table" and eventBox.selectedBox or nil,
			eventCurrency = type(eventBox) == "table" and eventBox.selectedCurrency or nil,
			autoBuyBoxes = type(eventBox) == "table" and eventBox.autoBuy == true or false,
		})

		if ok and type(result) == "string" then
			pcall(function()
				if type(isfolder) == "function" and type(makefolder) == "function" and not isfolder("Foxname_MM2") then
					makefolder("Foxname_MM2")
				end

				if type(writefile) == "function" then
					writefile("Foxname_MM2/coin_farm_resume.json", result)
				end
			end)
		end

		local flag8 = type(queue_on_teleport) == "function" and queue_on_teleport or type(queueonteleport) == "function" and queueonteleport
		local queueOnTeleport

		if flag8 then
			queueOnTeleport = flag8
		else
			local flag9 = type(syn) == "table"

			if flag9 then
				queueOnTeleport = syn.queue_on_teleport or syn.queueonteleport
			else
				queueOnTeleport = flag9
			end
		end

		queueOnTeleport = queueOnTeleport or type(fluxus) == "table" and (fluxus.queue_on_teleport or fluxus.queueonteleport)
		if type(queueOnTeleport) ~= "function" then
			return false, "queue_on_teleport unavailable"
		end
		local str = tostring(Hub.AdminReexecuteScriptUrl or "")
		if str == "" then
			return false, "re-execute URL unavailable"
		end

		if not ok or type(result) ~= "string" then
			return false, "resume state could not be encoded"
		end
		local str2 = string.format("if not game:IsLoaded() then game.Loaded:Wait() end;%sloadstring(game:HttpGet(%q))()", string.format("local e=(getgenv and getgenv()) or _G;e.__FoxnameCoinFarmResume=game:GetService('HttpService'):JSONDecode(%q);", result), str)
		local ok2, result2 = pcall(queueOnTeleport, str2)
		return ok2, ok2 and nil or tostring(result2)
	end

	Hub.CoinFarm.FetchServerCandidates = function(arg, arg2, arg3)
		local tbl7 = {}
		local n2 = math.clamp(math.floor(tonumber(arg3) or 2), 1, 3)
		arg2 = type(arg2) == "table" and arg2 or {}
		local nextPageCursor = nil

		for i = 1, n2 do
			local str = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&excludeFullGames=true&limit=100%s", tonumber(arg) or game.PlaceId, nextPageCursor and "&cursor=" .. HttpService:UrlEncode(nextPageCursor) or "")
			local genv2 = type(getgenv) == "function" and getgenv() or _G

			if type(genv2) ~= "table" then
				genv2 = _G
			end

			local request_ = genv2.request or genv2.http_request or type(genv2.syn) == "table" and genv2.syn.request
			local body = nil

			if type(request_) == "function" then
				local ok, result = pcall(request_, { Url = str, Method = "GET", Headers = { Accept = "application/json" } })
				ok = ok and type(result) == "table"
				body = nil

				if ok then
					local num = tonumber(result.StatusCode or result.Status)
					local flag7 = not num or num >= 200 and num < 300
					body = nil

					if flag7 then
						body = result.Body or result.body
					end
				end
			end

			if type(body) ~= "string" or body == "" then
				local ok, result = pcall(game.HttpGet, game, str)

				if ok and type(result) == "string" then
					body = result
				end
			end

			local ok, result = pcall(HttpService.JSONDecode, HttpService, body or "")

			if not (not ok or type(result) ~= "table" or type(result.data) ~= "table") then
				for _, v9 in ipairs(result.data) do
					local flag7 = type(v9) == "table"

					if flag7 then
						flag7 = tostring(v9.id or "")
					end

					flag7 = flag7 or ""
					local n3 = tonumber(type(v9) == "table" and v9.playing) or 0
					local n4 = tonumber(type(v9) == "table" and v9.maxPlayers) or 0

					if flag7 ~= "" and flag7 ~= tostring(game.JobId) and not arg2[flag7] and n4 > n3 then
						table.insert(tbl7, { id = flag7, playing = n3, safe = n4 - n3 >= 2, randomOrder = math.random() })
					end
				end

				nextPageCursor = type(result.nextPageCursor) == "string" and result.nextPageCursor ~= "" and result.nextPageCursor or nil
				if nextPageCursor then
					continue
				end
			end

			break
		end

		table.sort(tbl7, function(arg4, arg5)
			if arg4.safe ~= arg5.safe then
				return arg4.safe
			end

			if arg4.playing ~= arg5.playing then
				return arg4.playing > arg5.playing
			end
			return arg4.randomOrder < arg5.randomOrder
		end)

		return tbl7
	end

	Hub.CoinFarm.TryServerTeleport = function(arg, arg2, arg3)
		local flag7 = false
		local flag8 = false
		local bindableEvent = Instance.new("BindableEvent")

		local function fn36(arg4)
			if flag7 then
				return
			end
			flag7 = true
			flag8 = arg4 == true
			bindableEvent:Fire()
		end

		local tbl7 = {
			localPlayer.OnTeleport:Connect(function(arg4)
				if arg4 == Enum.TeleportState.Started or arg4 == Enum.TeleportState.WaitingForServer or arg4 == Enum.TeleportState.InProgress then
					fn36(true)
				elseif arg4 == Enum.TeleportState.Failed then
					fn36(false)
				end
			end),
			(TeleportService.TeleportInitFailed:Connect(function(arg4)
				if arg4 == localPlayer then
					fn36(false)
				end
			end)),
		}

		task.delay(math.max(3, tonumber(arg3) or 8), function()
			fn36(false)
		end)

		if not pcall(function()
			if type(arg2) == "string" and arg2 ~= "" then
				TeleportService:TeleportToPlaceInstance(arg, arg2, localPlayer)
			else
				TeleportService:Teleport(arg, localPlayer)
			end
		end) then
			fn36(false)
		end

		if not flag7 then
			bindableEvent.Event:Wait()
		end

		for _, v9 in ipairs(tbl7) do
			if v9.Connected then
				v9:Disconnect()
			end
		end

		bindableEvent:Destroy()
		return flag8
	end

	Hub.CoinFarm.StartLowPlayerServerHop = function()
		local serverHopRunning = Hub.CoinFarm.serverHopRunning or not Hub.CoinFarm.enabled or not Hub.CoinFarm.serverHopLowPlayers or Hub.RoundState.active

		if not serverHopRunning then
			local serverHopPlayerThreshold = Hub.CoinFarm.serverHopPlayerThreshold
			serverHopRunning = #Players:GetPlayers() > serverHopPlayerThreshold
		end

		if serverHopRunning then
			return false
		end
		Hub.CoinFarm.serverHopRunning = true
		Hub.CoinFarm.serverHopTimerStartedAt = os.clock()
		Hub.CoinFarm.SetPhase("Server hopping")
		Hub.CoinFarm.ReportServerHop("Low player server")

		task.spawn(function()
			fn35()
			Hub.CoinFarm.failedServerJobIds = Hub.CoinFarm.failedServerJobIds or {}
			local failedServerJobIds = Hub.CoinFarm.failedServerJobIds
			local v9 = Hub.CoinFarm.FetchServerCandidates(game.PlaceId, failedServerJobIds, 2)

			for i = 1, math.min(#v9, 8) do
				if not Hub.CoinFarm.enabled or not Hub.CoinFarm.serverHopLowPlayers then
					Hub.CoinFarm.serverHopRunning = false
					return
				end
				local id = v9[i].id
				failedServerJobIds[id] = true

				if Hub.CoinFarm.TryServerTeleport(game.PlaceId, id, 7) then
					local jobId = game.JobId

					task.delay(15, function()
						if game.JobId == jobId then
							Hub.CoinFarm.serverHopRunning = false
						end
					end)

					return
				end

				task.wait(2)
			end

			if Hub.CoinFarm.enabled and Hub.CoinFarm.serverHopLowPlayers then
				if Hub.CoinFarm.TryServerTeleport(game.PlaceId, nil, 8) then
					local jobId = game.JobId

					task.delay(15, function()
						if game.JobId == jobId then
							Hub.CoinFarm.serverHopRunning = false
						end
					end)

					return
				end
			end

			Hub.CoinFarm.serverHopRunning = false
		end)

		return true
	end

	Hub.CoinFarm.CountLikelyBotPlayers = function()
		local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
		playerGui = playerGui and playerGui:FindFirstChild("MainGUI")
		playerGui = playerGui and playerGui:FindFirstChild("Game")
		playerGui = playerGui and playerGui:FindFirstChild("Leaderboard")
		playerGui = playerGui and playerGui:FindFirstChild("Container")
		local tbl7 = { I = 1, II = 2, III = 3, IV = 4, V = 5, VI = 6, VII = 7, VIII = 8, IX = 9, X = 10 }
		Hub.CoinFarm.antiBotSamples = Hub.CoinFarm.antiBotSamples or {}
		local antiBotSamples = Hub.CoinFarm.antiBotSamples
		local now = os.clock()
		local antiBotLastCount = 0

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= localPlayer then
				local num = tonumber(player:GetAttribute("Level"))
				local num2 = tonumber(player:GetAttribute("Prestige"))

				if num == nil or num2 == nil then
					local level = playerGui and playerGui:FindFirstChild(player.Name)
					level = level and level:FindFirstChild("Level")
					local level2 = level and level:FindFirstChild("Level")
					level = level and level:FindFirstChild("Prestige")

					if num == nil and level2 and level2:IsA("TextLabel") then
						num = tonumber(tostring(level2.Text):match("%d+"))
					end

					if num2 == nil and level and level:IsA("TextLabel") then
						local match = tostring(level.Text or ""):upper():match("^%s*(.-)%s*$")
						num2 = match == "" and 0 or tbl7[match]
					end
				end

				local tbl8 = antiBotSamples[player]

				if type(tbl8) ~= "table" then
					tbl8 = { score = 0, observations = 0, lastPosition = nil, lastAt = now }
					antiBotSamples[player] = tbl8
				end

				local character_ = player.Character
				local humanoid = character_ and character_:FindFirstChildOfClass("Humanoid")
				character_ = character_ and character_:FindFirstChild("HumanoidRootPart")

				if character_ and humanoid and humanoid.Health > 0 then
					local n2 = math.max(0.05, now - (tbl8.lastAt or now))
					local magnitude = tbl8.lastPosition and (character_.Position - tbl8.lastPosition).Magnitude or 0
					local n3 = magnitude / n2
					local huge = math.huge
					local flag7 = false

					for k in pairs(Hub.CoinFarm.coins) do
						if Hub.CoinFarm.IsCoinAvailable(k) then
							local magnitude2 = (character_.Position - k.Position).Magnitude

							if magnitude2 < huge then
								flag7 = character_.Position.Y < k.Position.Y - 4
								huge = magnitude2
							end
						end
					end

					if tbl8.lastPosition then
						tbl8.observations = tbl8.observations + 1

						if huge <= 7 and n3 >= 9 or magnitude >= 18 and n3 >= 18 or flag7 and huge <= 12 and n3 >= 7 then
							tbl8.score = math.min(12, tbl8.score + 2)
						else
							tbl8.score = math.max(0, tbl8.score - 0.5)
						end
					end

					tbl8.lastPosition = character_.Position
					tbl8.lastAt = now
				else
					tbl8.score = math.max(0, tbl8.score - 1)
					tbl8.lastPosition = nil
					tbl8.lastAt = now
				end

				local flag7 = num and num >= 1 and num <= 30 and num2 == 0
				local flag8 = tbl8.observations >= 2

				if flag8 then
					flag8 = tbl8.score >= (flag7 and 4 or 6)
				end

				if flag8 then
					antiBotLastCount += 1
				end
			end
		end

		for k in pairs(antiBotSamples) do
			if k.Parent ~= Players then
				antiBotSamples[k] = nil
			end
		end

		Hub.CoinFarm.antiBotLastCount = antiBotLastCount
		return antiBotLastCount
	end

	Hub.CoinFarm.StartAntiBotServerHop = function()
		if Hub.CoinFarm.serverHopRunning or not Hub.CoinFarm.enabled or not Hub.CoinFarm.antiBotEnabled or Hub.CoinFarm.CountLikelyBotPlayers() < 4 then
			return false
		end
		Hub.CoinFarm.serverHopRunning = true
		Hub.CoinFarm.serverHopTimerStartedAt = os.clock()
		Hub.CoinFarm.SetPhase("Anti Bot: Server hopping")
		Hub.CoinFarm.ReportServerHop("Bot server detected")

		task.spawn(function()
			fn35()
			local tbl7 = {}
			local v9 = Hub.CoinFarm.FetchServerCandidates(game.PlaceId, tbl7, 3)

			for i = 1, math.min(#v9, 12) do
				if not Hub.CoinFarm.enabled or not Hub.CoinFarm.antiBotEnabled then
					Hub.CoinFarm.serverHopRunning = false
					return
				end
				local id = v9[i].id
				tbl7[id] = true

				if Hub.CoinFarm.TryServerTeleport(game.PlaceId, id, 7) then
					task.delay(15, function()
						if foxnameMM2Runtime.alive and Hub.CoinFarm.enabled then
							Hub.CoinFarm.serverHopRunning = false
						end
					end)

					return
				end

				task.wait(1.5)
			end

			if Hub.CoinFarm.enabled and Hub.CoinFarm.antiBotEnabled then
				if Hub.CoinFarm.TryServerTeleport(game.PlaceId, nil, 8) then
					task.delay(15, function()
						if foxnameMM2Runtime.alive and Hub.CoinFarm.enabled then
							Hub.CoinFarm.serverHopRunning = false
						end
					end)

					return
				end
			end

			Hub.CoinFarm.serverHopRunning = false
		end)

		return true
	end

	Hub.CoinFarm.StartTimerServerHop = function(arg, arg2)
		if Hub.CoinFarm.serverHopRunning or not Hub.CoinFarm.enabled then
			return false
		end
		Hub.CoinFarm.serverHopRunning = true
		Hub.CoinFarm.serverHopTimerStartedAt = os.clock()
		Hub.CoinFarm.SetPhase(arg2 or "Timer: Server hopping")
		Hub.CoinFarm.ReportServerHop(arg or "Server hop timer")

		task.spawn(function()
			fn35()
			local tbl7 = {}
			local v9 = Hub.CoinFarm.FetchServerCandidates(game.PlaceId, tbl7, 3)

			for i = 1, math.min(#v9, 12) do
				if not Hub.CoinFarm.enabled then
					Hub.CoinFarm.serverHopRunning = false
					return
				end
				local id = v9[i].id
				tbl7[id] = true

				if Hub.CoinFarm.TryServerTeleport(game.PlaceId, id, 7) then
					task.delay(15, function()
						if foxnameMM2Runtime.alive and Hub.CoinFarm.enabled then
							Hub.CoinFarm.serverHopRunning = false
							Hub.CoinFarm.serverHopTimerStartedAt = os.clock()
						end
					end)

					return
				end

				task.wait(1.5)
			end

			if Hub.CoinFarm.enabled and Hub.CoinFarm.TryServerTeleport(game.PlaceId, nil, 8) then
				task.delay(15, function()
					if foxnameMM2Runtime.alive and Hub.CoinFarm.enabled then
						Hub.CoinFarm.serverHopRunning = false
						Hub.CoinFarm.serverHopTimerStartedAt = os.clock()
					end
				end)

				return
			end

			Hub.CoinFarm.serverHopRunning = false
			Hub.CoinFarm.serverHopTimerStartedAt = os.clock()
		end)

		return true
	end

	task.spawn(function()
		while foxnameMM2Runtime.alive and not isTerminated do
			if Hub.CoinFarm.enabled and Hub.CoinFarm.antiBotEnabled and not Hub.CoinFarm.serverHopRunning then
				Hub.CoinFarm.StartAntiBotServerHop()
			end

			task.wait(3)
		end
	end)

	task.spawn(function()
		while foxnameMM2Runtime.alive and not isTerminated do
			if Hub.CoinFarm.enabled and not Hub.CoinFarm.serverHopRunning then
				if Hub.CoinFarm.serverHopTimerStartedAt <= 0 then
					Hub.CoinFarm.serverHopTimerStartedAt = os.clock()
				end

				local clamp = math.clamp
				local n2 = tonumber(Hub.CoinFarm.serverHopTimerMinutes) or 15
				local serverHopTimerStartedAt = Hub.CoinFarm.serverHopTimerStartedAt

				if clamp(n2, 10, 30) * 60 <= os.clock() - serverHopTimerStartedAt then
					Hub.CoinFarm.StartTimerServerHop()
				end
			end

			task.wait(1)
		end
	end)

	task.spawn(function()
		while foxnameMM2Runtime.alive and not isTerminated and not Hub.CoinFarm.resumedFromServerHop do
			task.wait(0.5)
		end

		if not foxnameMM2Runtime.alive or UserInputService.TouchEnabled or not UserInputService.KeyboardEnabled then
			return
		end
		task.wait(8)
		local CoreGui = nil

		pcall(function()
			CoreGui = game:GetService("CoreGui")
		end)

		local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

		local function fn36(arg, arg2)
			while arg and arg ~= arg2 do
				if arg:IsA("GuiObject") and not arg.Visible then
					return false
				end

				if arg:IsA("LayerCollector") and not arg.Enabled then
					return false
				end
				arg = arg.Parent
			end

			return arg == arg2
		end

		local function fn37()
			playerGui = localPlayer:FindFirstChildOfClass("PlayerGui") or playerGui
			local joinPhone = playerGui and playerGui:FindFirstChild("JoinPhone")
			if joinPhone and fn36(joinPhone, playerGui) then
				return true
			end
			local touchGui = CoreGui and CoreGui:FindFirstChild("TouchGui", true)
			if not touchGui or not fn36(touchGui, CoreGui) then
				return false
			end
			local touchControlFrame = touchGui:FindFirstChild("TouchControlFrame", true)
			if touchControlFrame and fn36(touchControlFrame, CoreGui) then
				return true
			end

			for _, descendant in ipairs(touchGui:GetDescendants()) do
				if descendant:IsA("GuiButton") and fn36(descendant, CoreGui) then
					return true
				end
			end

			return false
		end

		local n2 = os.clock() + 40
		local n3 = 0

		while foxnameMM2Runtime.alive and not isTerminated and Hub.CoinFarm.enabled and os.clock() < n2 do
			if fn37() then
				n3 += 1
				if n3 >= 4 then
					Hub.CoinFarm.StartTimerServerHop("Incorrect mobile controls detected", "Device UI mismatch: Server hopping")
					return
				end
			else
				n3 = 0
			end

			task.wait(0.75)
		end
	end)

	local fn36 = nil

	fn36 = function(arg)
		if Hub.CoinFarmKickRecoveryStarted or Hub.SuppressCoinFarmKickRecovery or not Hub.CoinFarm.enabled then
			return
		end

		if Hub.CoinFarm.serverHopRunning and not arg then
			return
		end
		Hub.CoinFarm.serverHopRunning = false
		Hub.CoinFarm.serverHopTimerStartedAt = os.clock()
		Hub.CoinFarmKickRecoveryStarted = true
		Hub.CoinFarm.SetPhase("Disconnected: Server hopping")
		Hub.CoinFarm.ReportServerHop("Invalid Position kick")
		local v9, v10 = fn35()

		if not v9 then
			warn("[Foxname] Coin Farm re-execute queue failed: " .. tostring(v10))
		end

		local placeId = game.PlaceId

		task.spawn(function()
			local tbl7 = {}
			local tbl8 = {}
			local n2 = 1

			for i = 1, 30 do
				if not Hub.CoinFarm.enabled or Hub.SuppressCoinFarmKickRecovery then
					break
				end

				if n2 > math.min(#tbl8, 12) then
					n2 = 1
					tbl8 = Hub.CoinFarm.FetchServerCandidates(placeId, tbl7, 2)
				end

				local v11 = nil

				if tbl8[n2] then
					local id = tbl8[n2].id
					n2 += 1
					tbl7[id] = true
					v11 = id
				end

				if Hub.CoinFarm.TryServerTeleport(placeId, v11, 8) then
					task.delay(15, function()
						if Hub.CoinFarm.enabled then
							Hub.CoinFarmKickRecoveryStarted = false
							task.defer(fn36)
						end
					end)

					return
				end

				task.wait(i < 3 and 5 or i < 10 and 12 or 30)
			end

			Hub.CoinFarmKickRecoveryStarted = false
		end)
	end

	if GuiService and GuiService.ErrorMessageChanged then
		trackConn(GuiService.ErrorMessageChanged:Connect(function(arg)
			local v9 = string.lower(tostring(arg or ""))

			if v9:match("%S") and Hub.CoinFarm.enabled and not Hub.SuppressCoinFarmKickRecovery then
				task.defer(fn36, (v9:find("invalid position", 1, true) or v9:find("error code: 267", 1, true) or v9:find("error code 267", 1, true)) and true or false)
			end
		end))
	end

	task.spawn(function()
		local CoreGui = nil

		pcall(function()
			CoreGui = game:GetService("CoreGui")
		end)

		while foxnameMM2Runtime.alive and not isTerminated do
			if Hub.CoinFarm.enabled and not Hub.SuppressCoinFarmKickRecovery and not Hub.CoinFarmKickRecoveryStarted then
				local str = ""

				pcall(function()
					if type(GuiService.GetErrorMessage) == "function" then
						str = tostring(GuiService:GetErrorMessage() or "")
					end
				end)

				local v9 = string.lower(str)
				local pos = v9:find("invalid position", 1, true) or v9:find("error code: 267", 1, true) or v9:find("error code 267", 1, true)

				if pos or pos then
					task.defer(fn36, true)
				end
			end

			task.wait(0.25)
		end
	end)

	local function fn37(arg, arg2, arg3)
		Hub.SuppressCoinFarmKickRecovery = true
		local v9, v10 = fn35()

		if not v9 then
			warn("[Foxname] Re-execute queue failed: " .. tostring(v10))
		end

		local placeId = tonumber(arg2) or game.PlaceId
		local str = tostring(arg3 or "")

		if str == "" then
			str = tostring(game.JobId or "")
		end

		local flag7 = false
		local flag8 = false
		local n2 = 0
		local fn38 = nil

		local function fn39(arg4)
			local v11 = flag7
			local v12

			if flag7 then
				v12 = v11
			else
				v12 = flag8
			end

			if v12 then
				return
			end
			flag8 = true

			task.delay(arg4 or 1.5, function()
				flag8 = false

				if not flag7 then
					fn38()
				end
			end)
		end

		trackConn(localPlayer.OnTeleport:Connect(function(arg4)
			if arg4 == Enum.TeleportState.Started or arg4 == Enum.TeleportState.InProgress then
				flag7 = true
			elseif arg4 == Enum.TeleportState.Failed then
				flag7 = false
				fn39(1)
			end
		end))

		trackConn(TeleportService.TeleportInitFailed:Connect(function(arg4)
			if arg4 == localPlayer then
				flag7 = false
				fn39(1)
			end
		end))

		trackConn(GuiService.ErrorMessageChanged:Connect(function(arg4)
			if tostring(arg4 or ""):match("%S") and not flag7 then
				task.defer(fn38)
			end
		end))

		fn38 = function()
			if flag7 then
				return
			end
			n2 += 1
			local flag9 = false

			if str ~= "" then
				flag9 = pcall(function()
					TeleportService:TeleportToPlaceInstance(placeId, str, localPlayer)
				end)
			end

			if not flag9 and n2 >= 6 then
				pcall(function()
					TeleportService:Teleport(placeId, localPlayer)
				end)
			end

			if not flag7 then
				fn39(n2 < 6 and 1.5 or 2.5)
			end
		end

		WindUI:Notify({
			Title = "Rejoining Server",
			Content = "Rejoining the original server instance...",
			Icon = "refresh-cw",
			Duration = 3,
		})

		task.delay(0.35, function()
			if not flag7 then
				fn38()
			end
		end)

		FoxnameKickPlayer(localPlayer, arg)
	end

	Hub.RunBombJump = function()
		local bombJump = Hub.BombJump
		local now = os.clock()
		if bombJump.busy then
			return false
		end

		if now < bombJump.nextReadyAt then
			WindUI:Notify({
				Title = "Bomb Jump",
				Content = string.format("Ready in %.1f seconds", bombJump.nextReadyAt - now),
				Icon = "clock",
				Duration = 1.5,
			})

			return false
		end

		local character_ = localPlayer.Character
		local humanoid = character_ and character_:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = character_ and character_:FindFirstChild("HumanoidRootPart")
		local backpack = localPlayer:FindFirstChildOfClass("Backpack")
		if not character_ or not humanoid or not humanoidRootPart or not backpack or humanoid.Health <= 0 then
			return false
		end

		if humanoid.FloorMaterial ~= Enum.Material.Air then
			WindUI:Notify({
				Title = "Bomb Jump",
				Content = "Jump first, then activate Bomb Jump while in mid-air.",
				Icon = "info",
				Duration = 1.8,
			})

			return false
		end

		local fakeBomb = character_:FindFirstChild("FakeBomb") or backpack:FindFirstChild("FakeBomb")
		if not fakeBomb or not fakeBomb:IsA("Tool") then
			WindUI:Notify({ Title = "Bomb Jump", Content = "Fake Bomb is not available", Icon = "x", Duration = 2 })
			return false
		end
		local remote = fakeBomb:FindFirstChild("Remote")
		if not remote or not remote:IsA("RemoteEvent") then
			WindUI:Notify({ Title = "Bomb Jump", Content = "Fake Bomb remote was not found", Icon = "x", Duration = 2 })
			return false
		end
		bombJump.busy = true
		bombJump.nextReadyAt = now + bombJump.cooldown

		task.spawn(function()
			local tool = character_:FindFirstChildOfClass("Tool")
			local client = fakeBomb:FindFirstChild("Client")
			local disabled = nil

			if client and client:IsA("LocalScript") then
				disabled = client.Disabled

				pcall(function()
					client.Disabled = true
				end)
			end

			local connection = nil
			local connection2 = nil
			local connection3 = nil
			local v9 = nil
			local flag7 = false

			local function fn38()
				if connection then
					connection:Disconnect()
					connection = nil
				end

				if connection2 then
					connection2:Disconnect()
					connection2 = nil
				end

				if connection3 then
					connection3:Disconnect()
					connection3 = nil
				end
			end

			local function fn39(arg)
				if not arg or not arg:IsA("BasePart") or arg.Name ~= "Handle" then
					return false
				end

				if not arg:IsDescendantOf(workspace) or (arg.Position - humanoidRootPart.Position).Magnitude > 60 then
					return false
				end
				return arg:FindFirstChild("Fuse") or arg:FindFirstChild("Beep") or arg:FindFirstChild("PleaseNo") or arg:FindFirstChild("Smoke")
			end

			local function fn40(arg)
				if v9 or not fn39(arg) then
					return
				end
				v9 = arg
			end

			local ok, result = pcall(function()
				humanoid:EquipTool(fakeBomb)
				task.wait()

				if fakeBomb.Parent ~= character_ then
					error("Fake Bomb could not be equipped")
				end

				local moveDirection = humanoid.MoveDirection
				local vector

				if moveDirection.Magnitude < 0.05 then
					vector = Vector3.new(humanoidRootPart.CFrame.LookVector.X, 0, humanoidRootPart.CFrame.LookVector.Z)
				else
					vector = Vector3.new(moveDirection.X, 0, moveDirection.Z)
				end

				if vector.Magnitude < 0.05 then
					vector = Vector3.new(0, 0, -1)
				end

				local unit = vector.Unit
				local vector2 = Vector3.new(-unit.Z, 0, unit.X)
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.FilterDescendantsInstances = { character_ }
				raycastParams.IgnoreWater = true
				local hit = workspace:Raycast(humanoidRootPart.Position, Vector3.new(0, -24, 0), raycastParams)
				local n2 = (hit and humanoidRootPart.Position.Y - hit.Position.Y or math.huge) <= 8 and -0.24 or -0.73
				local unit2 = (unit * math.sqrt(1 - n2 * n2) + Vector3.new(0, n2, 0)).Unit
				local n3 = humanoidRootPart.Position + vector2 * 1.75 + Vector3.new(0, 0.8, 0) - unit2 * 13.6
				local raycastParams2 = RaycastParams.new()
				raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams2.FilterDescendantsInstances = { character_ }
				raycastParams2.IgnoreWater = true
				local hit2 = workspace:Raycast(n3, unit2 * 1000, raycastParams2)
				local position = hit2 and hit2.Position or n3 + unit2 * 1000
				local cframe = CFrame.lookAt(position, position + unit2)

				connection = workspace.ChildAdded:Connect(function(child)
					if child:IsA("BasePart") and child.Name == "Handle" then
						task.defer(function()
							local n4 = os.clock() + 0.25

							while true do
								if fn39(child) then
									fn40(child)
									return
								else
									task.wait()
									if os.clock() >= n4 or not child.Parent then
										break
									end
								end
							end
						end)
					end
				end)

				connection2 = workspace.DescendantAdded:Connect(function(descendant)
					if descendant.Name == "Fuse" or descendant.Name == "Beep" or descendant.Name == "PleaseNo" or descendant.Name == "Smoke" then
						fn40(descendant.Parent)
					end
				end)

				remote:FireServer(cframe, 50)
				local n4 = os.clock() + 0.85

				while true do
					task.wait()
					if not (v9 or os.clock() >= n4) then
						continue
					end
					break
				end

				if not v9 then
					return
				end

				connection3 = v9.Touched:Connect(function(hit3)
					if hit3 and hit3:IsDescendantOf(character_) then
						flag7 = true
					end
				end)

				local VirtualInputManager = nil

				if not UserInputService.TouchEnabled then
					pcall(function()
						VirtualInputManager = game:GetService("VirtualInputManager")
					end)
				end

				local n5 = os.clock() + 0.48
				local now2 = nil

				while not (humanoid.Health <= 0 or not humanoidRootPart.Parent) do
					humanoid.Jump = true

					if humanoid.FloorMaterial ~= Enum.Material.Air then
						humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
					end

					if VirtualInputManager then
						pcall(function()
							VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
							VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
						end)
					end

					if flag7 and not now2 then
						now2 = os.clock()
					end

					task.wait(0.03)
					if os.clock() >= n5 or now2 and os.clock() - now2 >= 0.1 then
						break
					end
				end
			end)

			fn38()

			if fakeBomb and fakeBomb.Parent == character_ then
				pcall(function()
					humanoid:UnequipTools()
				end)
			end

			if tool and tool.Parent and tool ~= fakeBomb then
				pcall(function()
					humanoid:EquipTool(tool)
				end)
			end

			if client and client.Parent and disabled ~= nil then
				pcall(function()
					client.Disabled = disabled
				end)
			end

			bombJump.busy = false

			if not ok then
				bombJump.nextReadyAt = 0
				WindUI:Notify({ Title = "Bomb Jump", Content = tostring(result), Icon = "x", Duration = 2 })
			end
		end)

		return true
	end

	local function fn38(arg)
	end

	local function fn39(arg)
	end

	-- presence / wss communication removed
end

do
	local function fn35()
		Hub.XRayScanGeneration = Hub.XRayScanGeneration + 1

		for k, v9 in pairs(Hub.XRayOriginal) do
			if k and k.Parent then
				pcall(function()
					k.LocalTransparencyModifier = v9
				end)
			end

			Hub.XRayOriginal[k] = nil
		end

		Hub.XRayMap = nil
	end

	local function fn36()
		if not Hub.RoundState.active then
			return nil
		end
		local currentMapInstance = Hub.RoundState.currentMapInstance
		local lobby = workspace:FindFirstChild("Lobby")
		local flag7 = currentMapInstance and currentMapInstance.Parent and currentMapInstance:IsDescendantOf(workspace) and currentMapInstance ~= lobby

		if flag7 then
			flag7 = not (lobby and currentMapInstance:IsDescendantOf(lobby))
		end

		if flag7 then
			return currentMapInstance
		end
		local currentMapName = Hub.RoundState.currentMapName

		if type(currentMapName) == "string" and currentMapName ~= "" then
			local str = currentMapName:lower():gsub("[^%w]", "")

			for _, child in ipairs(workspace:GetChildren()) do
				if child ~= lobby and (child:IsA("Model") or child:IsA("Folder")) and child.Name:lower():gsub("[^%w]", "") == str then
					Hub.RoundState.currentMapInstance = child
					return child
				end
			end
		end

		for _, child in ipairs(workspace:GetChildren()) do
			if child ~= lobby and (child:IsA("Model") or child:IsA("Folder")) and (child:FindFirstChild("CoinContainer", true) or child:FindFirstChild("Coin_Server", true)) then
				Hub.RoundState.currentMapInstance = child
				Hub.RoundState.currentMapName = child.Name
				return child
			end
		end

		return nil
	end

	local function fn37(arg)
		if not Hub.XRayEnabled or not Hub.XRayMap or not arg:IsA("BasePart") or arg.Name == "Coin_Server" or arg.Transparency >= 1 then
			return
		end

		if Hub.XRayOriginal[arg] == nil then
			Hub.XRayOriginal[arg] = arg.LocalTransparencyModifier
		end

		arg.LocalTransparencyModifier = math.clamp((Hub.WorldFeatureConfig.xrayTransparency - arg.Transparency) / (1 - arg.Transparency), 0, 1)
	end

	local function fn38()
		if not Hub.XRayEnabled then
			return
		end
		local v9 = fn36()
		if not v9 then
			return
		end

		if Hub.XRayMap ~= v9 then
			fn35()
			if not Hub.XRayEnabled then
				return
			end
			Hub.XRayMap = v9
		else
			Hub.XRayScanGeneration = Hub.XRayScanGeneration + 1
		end

		local xRayScanGeneration = Hub.XRayScanGeneration

		task.spawn(function()
			for i, descendant in ipairs(v9:GetDescendants()) do
				if not Hub.XRayEnabled or Hub.XRayScanGeneration ~= xRayScanGeneration or Hub.XRayMap ~= v9 then
					return
				end
				fn37(descendant)

				if i % 300 == 0 then
					RunService.Heartbeat:Wait()
				end
			end
		end)
	end

	local function fn39()
		Hub.XRayEnabled = false

		if Hub.XRayConn then
			Hub.XRayConn:Disconnect()
			Hub.XRayConn = nil
		end

		if Hub.XRayRemoveConn then
			Hub.XRayRemoveConn:Disconnect()
			Hub.XRayRemoveConn = nil
		end

		if Hub.XRayRefreshConn then
			Hub.XRayRefreshConn:Disconnect()
			Hub.XRayRefreshConn = nil
		end

		fn35()
	end

	local function fn40(arg)
		Hub.XRayEnabled = arg and true or false
		if not Hub.XRayEnabled then
			fn39()
			return
		end
		fn38()

		if Hub.XRayConn then
			Hub.XRayConn:Disconnect()
		end

		Hub.XRayConn = workspace.DescendantAdded:Connect(function(descendant)
			if not Hub.XRayEnabled then
				return
			end

			if Hub.XRayMap and descendant:IsDescendantOf(Hub.XRayMap) then
				fn37(descendant)
			else
				local flag7 = descendant.Parent == workspace
				local isModel

				if flag7 then
					isModel = descendant:IsA("Model") or descendant:IsA("Folder")
				else
					isModel = flag7
				end

				if isModel then
					task.delay(0.25, function()
						if not Hub.XRayEnabled then
							return
						end
						local v9 = fn36()

						if v9 and v9 ~= Hub.XRayMap then
							fn38()
						end
					end)
				end
			end
		end)

		if Hub.XRayRemoveConn then
			Hub.XRayRemoveConn:Disconnect()
		end

		Hub.XRayRemoveConn = workspace.ChildRemoved:Connect(function(child)
			if Hub.XRayEnabled and child == Hub.XRayMap then
				fn35()
			end
		end)

		if Hub.XRayRefreshConn then
			Hub.XRayRefreshConn:Disconnect()
		end

		local n2 = 0

		Hub.XRayRefreshConn = RunService.Heartbeat:Connect(function(deltaTime)
			if not Hub.XRayEnabled then
				return
			end
			n2 += deltaTime
			if n2 < 0.5 then
				return
			end
			n2 = 0
			local v9 = fn36()

			if v9 ~= Hub.XRayMap then
				if v9 then
					fn38()
				elseif Hub.XRayMap then
					fn35()
				end
			end
		end)
	end

	Hub.TouchButtons.SetControlValue = function(arg, arg2)
		if not arg then
			return false
		end

		for _, v9 in ipairs({ "Set", "SetValue", "SetState" }) do
			local v10 = arg[v9]
			if type(v10) ~= "function" then
				continue
			end

			if pcall(v10, arg, arg2) then
				return true
			end
		end

		return false
	end

	Hub.TouchButtons.ApplyLucideIcon = function(arg, arg2)
		if not arg or not arg:IsA("ImageLabel") then
			return
		end
		local v9 = Hub.TouchButtons.RemoteIcons[arg2]
		local v10 = v9 and Hub.TouchButtons.remoteIconCache[v9]

		if v10 then
			arg.Image = v10
			arg.ImageRectSize = Vector2.zero
			arg.ImageRectOffset = Vector2.zero
			return
		end

		local str = Hub.TouchButtons.Icons[arg2] or "circle"
		local v11 = Hub.TouchButtons.iconCache[str]

		if not v11 then
			local v12 = Hub.TouchButtons.iconFallback[str]
			local flag7 = v12 ~= nil
			arg.Image = v12 or Hub.TouchButtons.iconFallback.default
			arg.ImageRectSize = Vector2.zero
			arg.ImageRectOffset = Vector2.zero

			if not flag7 then
				Hub.TouchButtons.LoadLucideIcons()
			end
		else
			arg.Image = v11.image
			arg.ImageRectSize = v11.rectSize or Vector2.zero
			arg.ImageRectOffset = v11.rectPosition or Vector2.zero
		end

		if v9 and not Hub.TouchButtons.remoteIconFailed[v9] then
			Hub.TouchButtons.LoadRemoteIcon(v9)
		end
	end

	Hub.TouchButtons.LoadRemoteIcon = function(arg)
		if type(arg) ~= "string" or not arg:match("^[%w_%-]+%.png$") or Hub.TouchButtons.remoteIconCache[arg] or Hub.TouchButtons.remoteIconLoading[arg] or Hub.TouchButtons.remoteIconFailed[arg] then
			return
		end
		local flag7 = type(getcustomasset) == "function" and getcustomasset or type(getsynasset) == "function" and getsynasset
		if type(flag7) ~= "function" or type(writefile) ~= "function" or type(isfile) ~= "function" or type(makefolder) ~= "function" or type(isfolder) ~= "function" then
			Hub.TouchButtons.remoteIconFailed[arg] = true
			return
		end
		Hub.TouchButtons.remoteIconLoading[arg] = true

		task.spawn(function()
			local ok, image = pcall(function()
				for _, v9 in ipairs({ "FoxnameMM2", "FoxnameMM2/icons_v1" }) do
					if not isfolder(v9) then
						makefolder(v9)
					end
				end

				local function fn41(arg2)
					return type(arg2) == "string" and #arg2 >= 8 and arg2:sub(1, 8) == "\137PNG\r\n\26\n"
				end

				local str = "FoxnameMM2/icons_v1/" .. arg
				local ok = isfile(str)

				if ok and type(readfile) == "function" then
					local result
					ok, result = pcall(readfile, str)
					ok = ok and fn41(result)
				end

				local ok2, result = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/FoxnameTeam/OSS/main/Murder-Mystery-2/icons/" .. arg)

				if ok2 and fn41(result) then
					writefile(str, result)
					ok = true
				end

				if not ok then
					error("PNG icon download failed")
				end

				return flag7(str)
			end)

			if ok and type(image) == "string" and image ~= "" then
				local flag8 = false
				local imageLabel = Instance.new("ImageLabel")
				imageLabel.Name = "FoxnameRemoteIconPreload"
				imageLabel.Size = UDim2.fromOffset(1, 1)
				imageLabel.Position = UDim2.fromOffset(-100, -100)
				imageLabel.BackgroundTransparency = 1
				imageLabel.ImageTransparency = 1
				imageLabel.Image = image
				local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

				if type(gethui) == "function" then
					pcall(function()
						playerGui = gethui() or playerGui
					end)
				end

				imageLabel.Parent = playerGui
				local ContentProvider = game:GetService("ContentProvider")

				flag8 = pcall(function()
					ContentProvider:PreloadAsync({ imageLabel }, function(arg2, arg3)
						if arg3 == Enum.AssetFetchStatus.Success then
							flag8 = true
						end
					end)
				end) and (flag8 or imageLabel.IsLoaded)

				imageLabel:Destroy()

				if not flag8 then
					image = "PNG custom asset is unsupported by this executor"
					ok = false
				end
			end

			Hub.TouchButtons.remoteIconLoading[arg] = nil

			if ok and type(image) == "string" and image ~= "" then
				Hub.TouchButtons.remoteIconCache[arg] = image
				Hub.TouchButtons.RefreshLucideIcons()
			else
				Hub.TouchButtons.remoteIconFailed[arg] = true
				Hub.TouchButtons.RefreshLucideIcons()
			end
		end)
	end

	Hub.TouchButtons.RefreshLucideIcons = function()
		Hub.TouchButtons.ForEachStyledButton(function(arg, arg2)
			if not arg2 or not arg2.Parent then
				return
			end
			local buttonTitle = arg2:FindFirstChild("ButtonTitle")
			Hub.TouchButtons.ApplyLucideIcon(arg2:FindFirstChild("ButtonIcon"), buttonTitle and buttonTitle.Text or "")
		end)
	end

	Hub.TouchButtons.GenerateLucideIconCache = function()
		local iconModule = Hub.TouchButtons.iconModule
		if not iconModule or type(iconModule.Icon2) ~= "function" then
			return
		end
		local tbl7 = {}
		local tbl8 = {}

		for _, icon in pairs(Hub.TouchButtons.Icons) do
			if not tbl7[icon] then
				tbl7[icon] = true
				table.insert(tbl8, icon)
			end
		end

		if not tbl7.circle then
			table.insert(tbl8, "circle")
		end

		for _, v9 in ipairs(tbl8) do
			local ok, result = pcall(iconModule.Icon2, v9)

			if ok and type(result) == "table" and type(result[1]) == "string" then
				local tbl9 = result[2] or {}
				Hub.TouchButtons.iconCache[v9] = { image = result[1], rectSize = tbl9.ImageRectSize, rectPosition = tbl9.ImageRectPosition }
			end
		end
	end

	Hub.TouchButtons.LoadLucideIcons = function()
		if Hub.TouchButtons.iconModule or Hub.TouchButtons.iconLoading then
			return
		end
		local iconModule = Hub.Crosshair and Hub.Crosshair.iconModule

		if iconModule and type(iconModule.Icon2) == "function" then
			Hub.TouchButtons.iconModule = iconModule
			Hub.TouchButtons.GenerateLucideIconCache()
			Hub.TouchButtons.RefreshLucideIcons()
			return
		end

		Hub.TouchButtons.iconLoading = true

		task.spawn(function()
			local ok, iconModule2 = pcall(function()
				return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"))()
			end)

			if ok and type(iconModule2) == "table" and type(iconModule2.Icon2) == "function" then
				Hub.TouchButtons.iconModule = iconModule2

				if Hub.Crosshair and not Hub.Crosshair.iconModule then
					Hub.Crosshair.iconModule = iconModule2
				end

				Hub.TouchButtons.GenerateLucideIconCache()
			end

			Hub.TouchButtons.iconLoading = false

			if Hub.TouchButtons.iconModule then
				Hub.TouchButtons.RefreshLucideIcons()
			end
		end)
	end

	for _, remoteIcon in pairs(Hub.TouchButtons.RemoteIcons) do
		Hub.TouchButtons.LoadRemoteIcon(remoteIcon)
	end

	task.spawn(function()
		local tbl7 = {}

		for k, v9 in pairs(Hub.TouchButtons.iconFallback) do
			if k ~= "default" then
				local imageLabel = Instance.new("ImageLabel")
				imageLabel.Image = v9
				table.insert(tbl7, imageLabel)
			end
		end

		local ok, result = pcall(game.GetService, game, "ContentProvider")

		if ok and result then
			pcall(result.PreloadAsync, result, tbl7)
		end

		for _, v9 in ipairs(tbl7) do
			v9:Destroy()
		end

		Hub.TouchButtons.RefreshLucideIcons()
	end)

	Hub.TouchButtons.UpdateDisplay = function(arg, text, arg2)
		local button = arg.button

		if button and button.Parent then
			button.Text = ""
			local buttonTitle = button:FindFirstChild("ButtonTitle")
			local buttonIcon = button:FindFirstChild("ButtonIcon")
			local statusDot = button:FindFirstChild("StatusDot")

			if buttonTitle then
				buttonTitle.Text = text
			end

			if buttonIcon then
				Hub.TouchButtons.ApplyLucideIcon(buttonIcon, text)
			end

			if statusDot then
				statusDot.Visible = false
				statusDot.BackgroundColor3 = arg2 and Color3.fromRGB(72, 235, 145) or Color3.fromRGB(105, 101, 115)
			end
		end
	end

	Hub.TouchButtons.UpdateText = function(arg, arg2, arg3)
		Hub.TouchButtons.UpdateDisplay(arg, arg2, arg3, false)
	end

	Hub.TouchButtons.UpdateHoldHint = function(arg, arg2)
		local button = arg2 or arg.button
		button = button and button:FindFirstChild("HoldHint")
		if not button then
			return
		end
		button.Text = ""
		button.Visible = false
	end

	Hub.TouchButtons.BindHoldDrag = function(arg, arg2, arg3)
		Hub.TouchButtons.Disconnect(arg)
		arg3 = arg3 or "position"
		arg.suppressNextActivation = false

		arg.beginConn = arg2.InputBegan:Connect(function(input)
			local userInputType = input.UserInputType
			if userInputType ~= Enum.UserInputType.MouseButton1 and userInputType ~= Enum.UserInputType.Touch then
				return
			end
			arg.dragging = arg.draggable == true
			arg.input = input
			arg.start = input.Position
			arg.startPos = arg2.Position

			if arg.endConn then
				arg.endConn:Disconnect()
			end

			arg.endConn = input.Changed:Connect(function()
				if input.UserInputState ~= Enum.UserInputState.End then
					return
				end
				arg.dragging = false
				arg[arg3] = arg2.Position

				if arg.endConn then
					arg.endConn:Disconnect()
					arg.endConn = nil
				end

				task.delay(0.15, function()
					arg.suppressNextActivation = false
				end)
			end)
		end)

		arg.inputConn = arg2.InputChanged:Connect(function(input)
			local userInputType = input.UserInputType

			if userInputType == Enum.UserInputType.MouseMovement or userInputType == Enum.UserInputType.Touch then
				arg.input = input
			end
		end)

		arg.globalConn = UserInputService.InputChanged:Connect(function(input)
			if not arg.dragging or input ~= arg.input then
				return
			end

			if not arg.start or not arg.startPos then
				return
			end
			local n2 = input.Position - arg.start

			if n2.Magnitude > 6 then
				arg.suppressNextActivation = true
			end

			arg2.Position = UDim2.new(arg.startPos.X.Scale, arg.startPos.X.Offset + n2.X, arg.startPos.Y.Scale, arg.startPos.Y.Offset + n2.Y)
			arg[arg3] = arg2.Position
		end)

		Hub.TouchButtons.UpdateHoldHint(arg, arg2)
	end

	Hub.TouchButtons.ShouldSuppressActivation = function(arg)
		if not arg.suppressNextActivation then
			return false
		end
		arg.suppressNextActivation = false
		return true
	end

	Hub.TouchButtons.DecorateActionButton = function(parent, arg, text)
		if not parent then
			return
		end
		local buttonTitle = parent:FindFirstChild("ButtonTitle") or Instance.new("TextLabel")
		buttonTitle.Name = "ButtonTitle"
		buttonTitle.BackgroundTransparency = 1
		buttonTitle.Font = Enum.Font.GothamBold
		buttonTitle.Text = text
		buttonTitle.TextXAlignment = Enum.TextXAlignment.Center
		buttonTitle.TextYAlignment = Enum.TextYAlignment.Center
		buttonTitle.ZIndex = parent.ZIndex + 1
		buttonTitle.Parent = parent
		local titleDivider = parent:FindFirstChild("TitleDivider") or Instance.new("Frame")
		titleDivider.Name = "TitleDivider"
		titleDivider.BorderSizePixel = 0
		titleDivider.ZIndex = parent.ZIndex + 1
		titleDivider.Parent = parent
		local buttonIcon = parent:FindFirstChild("ButtonIcon")
		local v9

		if buttonIcon and not buttonIcon:IsA("ImageLabel") then
			buttonIcon:Destroy()
			v9 = nil
		else
			v9 = buttonIcon
		end

		local imageLabel = v9 or Instance.new("ImageLabel")
		imageLabel.Name = "ButtonIcon"
		imageLabel.BackgroundTransparency = 1
		imageLabel.ScaleType = Enum.ScaleType.Fit
		imageLabel.ZIndex = parent.ZIndex + 1
		imageLabel.Parent = parent
		Hub.TouchButtons.ApplyLucideIcon(imageLabel, text)
		local holdHint = parent:FindFirstChild("HoldHint") or Instance.new("TextLabel")
		holdHint.Name = "HoldHint"
		holdHint.BackgroundTransparency = 1
		holdHint.Font = Enum.Font.GothamMedium
		holdHint.TextXAlignment = Enum.TextXAlignment.Center
		holdHint.TextYAlignment = Enum.TextYAlignment.Center
		holdHint.TextTruncate = Enum.TextTruncate.None
		holdHint.TextWrapped = true
		holdHint.ZIndex = parent.ZIndex + 1
		holdHint.Parent = parent
		parent.Text = ""
		Hub.TouchButtons.ApplySize(parent, arg.size, arg.shape)
		Hub.TouchButtons.ApplyAppearance(parent, arg)
		Hub.TouchButtons.UpdateHoldHint(arg, parent)
	end

	Hub.TouchButtons.SetXRayEnabled = function(arg, arg2)
		local flag7 = arg and true or false

		if Hub.XRayEnabled ~= flag7 then
			fn40(flag7)
		end

		Hub.TouchButtons.UpdateText(Hub.XRayButtonState, "XRay", flag7)

		if arg2 then
			Hub.TouchButtons.SetControlValue(Hub.TouchButtons.XRayToggleControl, flag7)
		end

		if Hub.TouchButtons.RefreshQuickMenu then
			Hub.TouchButtons.RefreshQuickMenu()
		end
	end
end

Hub.TouchButtons.SetAimEnabled = function(aimEnabled, arg)
	aimEnabled = aimEnabled and true or false
	Hub.AimEnabled = aimEnabled

	if Hub.UpdateAimBinding then
		Hub.UpdateAimBinding()
	end

	Hub.TouchButtons.UpdateText(Hub.AimlockButtonState, "Aimlock", aimEnabled)

	if arg then
		Hub.TouchButtons.SetControlValue(Hub.TouchButtons.AimToggleControl, aimEnabled)
	end

	if Hub.TouchButtons.RefreshQuickMenu then
		Hub.TouchButtons.RefreshQuickMenu()
	end
end

Hub.TouchButtons.SetNoclipEnabled = function(arg, arg2)
	local noclipEnabled = arg and true or false
	Hub.NoclipEnabled = noclipEnabled

	if noclipEnabled then
		fn17()
	else
		fn18()
	end

	Hub.TouchButtons.UpdateText(Hub.NoclipButtonState, "Noclip", noclipEnabled)

	if arg2 then
		Hub.TouchButtons.SetControlValue(Hub.TouchButtons.NoclipToggleControl, noclipEnabled)
	end
end

Hub.TouchButtons.SetFlyEnabled = function(flyEnabled, arg)
	flyEnabled = flyEnabled and true or false
	Hub.FlyEnabled = flyEnabled

	if flyEnabled then
		if Hub.StartFly then
			Hub.StartFly()
		end
	else
		if Hub.StopFly then
			Hub.StopFly()
		end

		if localChar.rootPart then
			localChar.rootPart.Velocity = Vector3.zero
		end
	end

	Hub.TouchButtons.UpdateText(Hub.FlyButtonState, "Fly", flyEnabled)

	if arg then
		Hub.TouchButtons.SetControlValue(Hub.TouchButtons.FlyToggleControl, flyEnabled)
	end
end

Hub.TouchButtons.Disconnect = function(arg)
	if arg.beginConn then
		arg.beginConn:Disconnect()
		arg.beginConn = nil
	end

	if arg.inputConn then
		arg.inputConn:Disconnect()
		arg.inputConn = nil
	end

	if arg.globalConn then
		arg.globalConn:Disconnect()
		arg.globalConn = nil
	end

	if arg.endConn then
		arg.endConn:Disconnect()
		arg.endConn = nil
	end

	arg.input = nil
	arg.start = nil
	arg.startPos = nil
	arg.dragging = false
end

Hub.TouchButtons.Destroy = function(arg)
	Hub.TouchButtons.Disconnect(arg)

	if arg.button then
		arg.position = arg.button.Position
		arg.button:Destroy()
		arg.button = nil
	end

	if arg.gui then
		arg.gui:Destroy()
		arg.gui = nil
	end
end

Hub.TouchButtons.Create = function(arg, name, name2, text, arg2, arg3, arg4)
	if arg.gui and arg.gui.Parent and arg.button and arg.button.Parent then
		local updateDisplay = Hub.TouchButtons.UpdateDisplay

		if arg4 then
		end

		updateDisplay(arg, text, arg2(), arg4)
		Hub.TouchButtons.ApplySize(arg.button, arg.size, arg.shape)
		Hub.TouchButtons.ApplyAppearance(arg.button, arg)
		return
	end

	Hub.TouchButtons.Destroy(arg)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = name
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = 999996

	pcall(function()
		if syn and syn.protect_gui then
			syn.protect_gui(screenGui)
		elseif protect_gui then
			protect_gui(screenGui)
		end
	end)

	screenGui.Parent = getSafeGuiParent()
	local textButton = Instance.new("TextButton")
	textButton.Name = name2
	textButton.AnchorPoint = Vector2.new(0.5, 0.5)
	textButton.Position = arg.position or arg.buttonPos or UDim2.new(0.84, 0, 0.62, 0)
	textButton.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	textButton.BackgroundTransparency = 0.35
	textButton.BorderSizePixel = 0
	textButton.Text = ""
	textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	textButton.Font = Enum.Font.GothamBold
	textButton.AutoButtonColor = true
	textButton.Active = true
	textButton.ZIndex = 30
	textButton.Parent = screenGui
	Hub.TouchButtons.ApplySize(textButton, arg.size, arg.shape)
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 12)
	uiCorner.Parent = textButton
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 1.5
	uiStroke.Color = Color3.fromRGB(255, 255, 255)
	uiStroke.Transparency = 0.4
	uiStroke.Parent = textButton
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "ButtonTitle"
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Text = text
	textLabel.TextColor3 = Color3.fromRGB(240, 236, 247)
	textLabel.TextXAlignment = Enum.TextXAlignment.Center
	textLabel.TextYAlignment = Enum.TextYAlignment.Center
	textLabel.ZIndex = textButton.ZIndex + 1
	textLabel.Parent = textButton
	local frame = Instance.new("Frame")
	frame.Name = "TitleDivider"
	frame.BorderSizePixel = 0
	frame.BackgroundColor3 = Color3.fromRGB(174, 92, 255)
	frame.ZIndex = textButton.ZIndex + 1
	frame.Parent = textButton
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "ButtonIcon"
	imageLabel.BackgroundTransparency = 1
	imageLabel.ImageColor3 = Color3.fromRGB(174, 92, 255)
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.ZIndex = textButton.ZIndex + 1
	imageLabel.Parent = textButton
	Hub.TouchButtons.ApplyLucideIcon(imageLabel, text)
	local frame2 = Instance.new("Frame")
	frame2.Name = "StatusDot"
	frame2.AnchorPoint = Vector2.new(0.5, 0.5)
	frame2.BorderSizePixel = 0
	frame2.ZIndex = textButton.ZIndex + 2
	frame2.Parent = textButton
	local uiCorner2 = Instance.new("UICorner")
	uiCorner2.CornerRadius = UDim.new(1, 0)
	uiCorner2.Parent = frame2
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "HoldHint"
	textLabel2.BackgroundTransparency = 1
	textLabel2.Font = Enum.Font.GothamMedium
	textLabel2.TextColor3 = Color3.fromRGB(174, 168, 185)
	textLabel2.TextXAlignment = Enum.TextXAlignment.Center
	textLabel2.TextYAlignment = Enum.TextYAlignment.Center
	textLabel2.TextTruncate = Enum.TextTruncate.None
	textLabel2.TextWrapped = false
	textLabel2.ZIndex = textButton.ZIndex + 1
	textLabel2.Parent = textButton
	Hub.TouchButtons.ApplySize(textButton, arg.size, arg.shape)
	Hub.TouchButtons.ApplyAppearance(textButton, arg)
	arg.gui = screenGui
	arg.button = textButton
	local updateDisplay = Hub.TouchButtons.UpdateDisplay

	if arg4 then
	end

	updateDisplay(arg, text, arg2(), arg4)

	textButton.Activated:Connect(function()
		if Hub.TouchButtons.ShouldSuppressActivation(arg) then
			return
		end

		if arg4 then
			arg3()
		else
			arg3(not arg2())
		end
	end)

	Hub.TouchButtons.BindHoldDrag(arg, textButton, "position")
end

Hub.TouchButtons.ToggleGetGunButton = function(arg)
	local getGunButtonState = Hub.GetGunButtonState
	getGunButtonState.enabled = arg and true or false

	if getGunButtonState.enabled then
		Hub.TouchButtons.Create(getGunButtonState, "Foxname_MM2_GetGunButton", "GetGunButton", "Get Gun", function()
			return false
		end, function()
			if Hub.TakeDroppedGunOnce then
				Hub.TakeDroppedGunOnce()
			end
		end, true)
	else
		Hub.TouchButtons.Destroy(getGunButtonState)
	end
end

Hub.TouchButtons.ToggleBombJumpButton = function(arg)
	local bombJumpButtonState = Hub.BombJumpButtonState
	bombJumpButtonState.enabled = arg and true or false

	if bombJumpButtonState.enabled then
		Hub.TouchButtons.Create(bombJumpButtonState, "Foxname_MM2_BombJumpButton", "BombJumpButton", "Bomb Jump", function()
			return false
		end, function()
			if Hub.RunBombJump then
				Hub.RunBombJump()
			end
		end, true)
	else
		Hub.TouchButtons.Destroy(bombJumpButtonState)
	end
end

Hub.TouchButtons.ToggleXRayButton = function(arg)
	local xRayButtonState = Hub.XRayButtonState
	xRayButtonState.enabled = arg and true or false

	if xRayButtonState.enabled then
		Hub.TouchButtons.Create(xRayButtonState, "Foxname_MM2_XRayButton", "XRayButton", "XRay", function()
			return Hub.XRayEnabled
		end, function(arg2)
			Hub.TouchButtons.SetXRayEnabled(arg2, true)
		end)
	else
		Hub.TouchButtons.Destroy(xRayButtonState)
	end
end

Hub.TouchButtons.ToggleAimlockButton = function(arg)
	local aimlockButtonState = Hub.AimlockButtonState
	aimlockButtonState.enabled = arg and true or false

	if aimlockButtonState.enabled then
		Hub.TouchButtons.Create(aimlockButtonState, "Foxname_MM2_AimlockButton", "AimlockButton", "Aimlock", function()
			return Hub.AimEnabled
		end, function(arg2)
			Hub.TouchButtons.SetAimEnabled(arg2, true)
		end)
	else
		Hub.TouchButtons.Destroy(aimlockButtonState)
	end
end

Hub.TouchButtons.ToggleFlyButton = function(arg)
	local flyButtonState = Hub.FlyButtonState
	flyButtonState.enabled = arg and true or false

	if flyButtonState.enabled then
		Hub.TouchButtons.Create(flyButtonState, "Foxname_MM2_FlyButton", "FlyButton", "Fly", function()
			return Hub.FlyEnabled
		end, function(arg2)
			Hub.TouchButtons.SetFlyEnabled(arg2, true)
		end)
	else
		Hub.TouchButtons.Destroy(flyButtonState)
	end
end

Hub.TouchButtons.ToggleNoclipButton = function(arg)
	local noclipButtonState = Hub.NoclipButtonState
	noclipButtonState.enabled = arg and true or false

	if noclipButtonState.enabled then
		Hub.TouchButtons.Create(noclipButtonState, "Foxname_MM2_NoclipButton", "NoclipButton", "Noclip", function()
			return Hub.NoclipEnabled
		end, function(arg2)
			Hub.TouchButtons.SetNoclipEnabled(arg2, true)
		end)
	else
		Hub.TouchButtons.Destroy(noclipButtonState)
	end
end

Hub.TouchButtons.ToggleThrowKnifeButton = function(arg)
	local throwKnifeButtonState = Hub.ThrowKnifeButtonState
	throwKnifeButtonState.enabled = arg and true or false

	if throwKnifeButtonState.enabled then
		Hub.TouchButtons.Create(throwKnifeButtonState, "Foxname_MM2_ThrowKnifeButton", "ThrowKnifeButton", "Throw Knife", function()
			return false
		end, function()
			if Hub.TriggerThrowKnifeInput then
				Hub.TriggerThrowKnifeInput()
			end
		end, true)
	else
		Hub.TouchButtons.Destroy(throwKnifeButtonState)
	end
end

Hub.TouchButtons.ToggleAutoShootButton = function(arg)
	local autoShootDragState = Hub.AutoShootDragState
	autoShootDragState.enabled = arg and true or false
	Hub.AutoShootState.enabled = autoShootDragState.enabled

	if autoShootDragState.enabled then
		Hub.TouchButtons.Create(autoShootDragState, "Foxname_MM2_AutoShootButton", "AutoShootButton", "Shoot", function()
			return false
		end, function()
			if Hub.TriggerAutoShootInput then
				Hub.TriggerAutoShootInput()
			elseif Hub.UpdateAutoShoot then
				Hub.UpdateAutoShoot()
			end
		end, true)

		Hub.AutoShootTouchButton = autoShootDragState.button
	else
		Hub.TouchButtons.Destroy(autoShootDragState)
		Hub.AutoShootTouchButton = nil
	end
end

Hub.TouchButtons.ToggleShootButton = Hub.TouchButtons.ToggleAutoShootButton
Hub.ToggleThrowKnifeButton = Hub.TouchButtons.ToggleThrowKnifeButton
Hub.ToggleAutoShoot = Hub.TouchButtons.ToggleAutoShootButton

Hub.TouchButtons.RefreshQuickMenu = function()
	local actions = Hub.QuickMenuState.actions
	local xRay = actions.XRay
	local aimlock = actions.Aimlock

	if xRay and xRay.Parent then
		xRay.Text = Hub.XRayEnabled and "XRay ON" or "XRay"
		xRay.BackgroundColor3 = Hub.XRayEnabled and Color3.fromRGB(210, 45, 90) or Color3.fromRGB(22, 22, 25)
	end

	if aimlock and aimlock.Parent then
		aimlock.Text = Hub.AimEnabled and "Aim ON" or "Aimlock"
		aimlock.BackgroundColor3 = Hub.AimEnabled and Color3.fromRGB(210, 45, 90) or Color3.fromRGB(22, 22, 25)
	end
end

Hub.TouchButtons.PositionQuickMenuActions = function(arg)
	local quickMenuState = Hub.QuickMenuState
	local button = quickMenuState.button
	if not button or not button.Parent then
		return
	end
	local currentCamera2 = workspace.CurrentCamera
	local n2 = button.AbsolutePosition.X + button.AbsoluteSize.X * 0.5 > (currentCamera2 and currentCamera2.ViewportSize.X or 1000) * 0.5 and -1 or 1

	local tbl7 = {
		Shoot = Vector2.new(48 * n2, -132),
		Throw = Vector2.new(108 * n2, -88),
		GetGun = Vector2.new(140 * n2, -24),
		BombJump = Vector2.new(132 * n2, 48),
		XRay = Vector2.new(82 * n2, 108),
		Aimlock = Vector2.new(16 * n2, 138),
		WallPhase = Vector2.new(-52 * n2, 124),
	}

	for k, action in pairs(quickMenuState.actions) do
		if action and action.Parent then
			local vector2 = tbl7[k] or Vector2.zero
			local udim2 = UDim2.new(quickMenuState.position.X.Scale, quickMenuState.position.X.Offset + vector2.X, quickMenuState.position.Y.Scale, quickMenuState.position.Y.Offset + vector2.Y)

			if quickMenuState.open then
				action.Visible = true

				if arg then
					TweenService:Create(action, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = udim2, BackgroundTransparency = 0.18, TextTransparency = 0 }):Play()
				else
					action.Position = udim2
					action.BackgroundTransparency = 0.18
					action.TextTransparency = 0
				end
			elseif arg then
				local tbl8 = { Position = quickMenuState.position, BackgroundTransparency = 1, TextTransparency = 1 }
				TweenService:Create(action, TweenInfo.new(0.11, Enum.EasingStyle.Quad, Enum.EasingDirection.In), tbl8):Play()

				task.delay(0.12, function()
					if action.Parent and not quickMenuState.open then
						action.Visible = false
					end
				end)
			else
				action.Position = quickMenuState.position
				action.BackgroundTransparency = 1
				action.TextTransparency = 1
				action.Visible = false
			end
		end
	end
end

Hub.TouchButtons.SetQuickMenuOpen = function(arg, arg2)
	Hub.QuickMenuState.open = arg and true or false
	local button = Hub.QuickMenuState.button

	if button and button.Parent then
		button.Text = Hub.QuickMenuState.open and "Ã—" or "Quick"
	end

	Hub.TouchButtons.PositionQuickMenuActions(arg2 ~= false)
end

Hub.TouchButtons.DestroyQuickMenu = function()
	local quickMenuState = Hub.QuickMenuState

	if quickMenuState.button and quickMenuState.button.Parent then
		quickMenuState.position = quickMenuState.button.Position
	end

	for _, connection in ipairs(quickMenuState.connections) do
		if connection and connection.Connected then
			connection:Disconnect()
		end
	end

	table.clear(quickMenuState.connections)
	table.clear(quickMenuState.actions)

	if quickMenuState.gui then
		quickMenuState.gui:Destroy()
	end

	quickMenuState.gui = nil
	quickMenuState.button = nil
	quickMenuState.open = false
	quickMenuState.dragging = false
	quickMenuState.dragInput = nil
end

Hub.TouchButtons.ToggleQuickMenu = function(arg)
	local quickMenuState = Hub.QuickMenuState
	quickMenuState.enabled = arg and true or false
	if not quickMenuState.enabled then
		Hub.TouchButtons.DestroyQuickMenu()
		return
	end

	if quickMenuState.gui and quickMenuState.gui.Parent and quickMenuState.button and quickMenuState.button.Parent then
		return
	end
	Hub.TouchButtons.DestroyQuickMenu()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "Foxname_MM2_QuickMenu"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = 999998

	pcall(function()
		if syn and syn.protect_gui then
			syn.protect_gui(screenGui)
		elseif protect_gui then
			protect_gui(screenGui)
		end
	end)

	screenGui.Parent = getSafeGuiParent()

	local function fn35(parent, size, textSize)
		parent.AnchorPoint = Vector2.new(0.5, 0.5)
		parent.Size = size
		parent.BackgroundColor3 = Color3.fromRGB(22, 22, 25)
		parent.BorderSizePixel = 0
		parent.TextColor3 = Color3.fromRGB(255, 255, 255)
		parent.Font = Enum.Font.GothamBold
		parent.TextSize = textSize
		parent.AutoButtonColor = true
		parent.Active = true
		parent.ZIndex = 50
		parent.Parent = screenGui
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, 12)
		uiCorner.Parent = parent
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Thickness = 1.5
		uiStroke.Color = Color3.fromRGB(240, 55, 100)
		uiStroke.Transparency = 0.12
		uiStroke.Parent = parent
	end

	local textButton = Instance.new("TextButton")
	textButton.Name = "QuickMenuButton"
	textButton.Text = "Quick"
	textButton.Position = quickMenuState.position
	fn35(textButton, UDim2.fromOffset(58, 58), 14)
	quickMenuState.gui = screenGui
	quickMenuState.button = textButton

	for _, v9 in ipairs({
		{
			"Shoot",
			"Shoot",
			function()
				if Hub.TriggerAutoShootInput then
					Hub.TriggerAutoShootInput()
				end
			end,
		},
		{
			"Throw",
			"Throw",
			function()
				if Hub.TriggerThrowKnifeInput then
					Hub.TriggerThrowKnifeInput()
				end
			end,
		},
		{
			"GetGun",
			"Gun",
			function()
				if Hub.TakeDroppedGunOnce then
					Hub.TakeDroppedGunOnce()
				end
			end,
		},
		{
			"BombJump",
			"Bomb",
			function()
				if Hub.RunBombJump then
					Hub.RunBombJump()
				end
			end,
		},
		{
			"XRay",
			"XRay",
			function()
				Hub.TouchButtons.SetXRayEnabled(not Hub.XRayEnabled, true)
			end,
		},
		{
			"Aimlock",
			"Aimlock",
			function()
				Hub.TouchButtons.SetAimEnabled(not Hub.AimEnabled, true)
			end,
		},
		{
			"WallPhase",
			"Wall Glitch",
			function()
				local wallPhaseAssist = Hub.WallPhaseAssist

				if wallPhaseAssist and type(wallPhaseAssist.Run) == "function" then
					wallPhaseAssist.Run()
				end
			end,
		},
	}) do
		local textButton2 = Instance.new("TextButton")
		textButton2.Name = v9[1] .. "QuickAction"
		textButton2.Text = v9[2]
		textButton2.Position = quickMenuState.position
		fn35(textButton2, UDim2.fromOffset(68, 40), 13)
		textButton2.Visible = false
		textButton2.BackgroundTransparency = 1
		textButton2.TextTransparency = 1
		quickMenuState.actions[v9[1]] = textButton2
		table.insert(quickMenuState.connections, textButton2.Activated:Connect(v9[3]))
	end

	table.insert(quickMenuState.connections, textButton.Activated:Connect(function()
		if quickMenuState.dragMoved then
			quickMenuState.dragMoved = false
			return
		end
		Hub.TouchButtons.SetQuickMenuOpen(not quickMenuState.open, true)
	end))

	table.insert(quickMenuState.connections, textButton.InputBegan:Connect(function(input)
		local userInputType = input.UserInputType
		if userInputType ~= Enum.UserInputType.Touch and userInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end
		quickMenuState.dragging = true
		quickMenuState.dragInput = input
		quickMenuState.dragStart = input.Position
		quickMenuState.dragStartPosition = textButton.Position
		quickMenuState.dragMoved = false
		local connection = nil

		connection = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				quickMenuState.dragging = false
				quickMenuState.position = textButton.Position

				if connection then
					connection:Disconnect()
					connection = nil
				end

				task.defer(function()
					quickMenuState.dragMoved = false
				end)
			end
		end)
	end))

	table.insert(quickMenuState.connections, textButton.InputChanged:Connect(function(input)
		local userInputType = input.UserInputType

		if userInputType == Enum.UserInputType.Touch or userInputType == Enum.UserInputType.MouseMovement then
			quickMenuState.dragInput = input
		end
	end))

	table.insert(quickMenuState.connections, UserInputService.InputChanged:Connect(function(input)
		if not quickMenuState.dragging or input ~= quickMenuState.dragInput or not quickMenuState.dragStart or not quickMenuState.dragStartPosition then
			return
		end
		local n2 = input.Position - quickMenuState.dragStart

		if n2.Magnitude > 7 then
			quickMenuState.dragMoved = true
		end

		textButton.Position = UDim2.new(quickMenuState.dragStartPosition.X.Scale, quickMenuState.dragStartPosition.X.Offset + n2.X, quickMenuState.dragStartPosition.Y.Scale, quickMenuState.dragStartPosition.Y.Offset + n2.Y)
		quickMenuState.position = textButton.Position
		Hub.TouchButtons.PositionQuickMenuActions(false)
	end))

	Hub.TouchButtons.RefreshQuickMenu()
	Hub.TouchButtons.SetQuickMenuOpen(false, false)
end

local fn35, fn36

do
	local function fn37()
		local v9 = workspace:FindFirstChild(Hub.InvisibilitySeatName)

		if v9 then
			pcall(function()
				v9:Destroy()
			end)
		end
	end

	local function fn38()
		if Hub.InvisibilityDescAddedConn then
			pcall(function()
				Hub.InvisibilityDescAddedConn:Disconnect()
			end)

			Hub.InvisibilityDescAddedConn = nil
		end

		if Hub.InvisibilityRefreshConn then
			pcall(function()
				Hub.InvisibilityRefreshConn:Disconnect()
			end)

			Hub.InvisibilityRefreshConn = nil
		end
	end

	local function fn39(arg, transparency)
		if not arg then
			return
		end

		for _, descendant in ipairs(arg:GetDescendants()) do
			if descendant:IsA("BasePart") then
				if descendant.Name ~= "HumanoidRootPart" then
					descendant.Transparency = transparency
				end

				descendant.LocalTransparencyModifier = transparency
			elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
				descendant.Transparency = transparency
			end
		end
	end

	local function fn40(arg)
		if not arg or not arg.Parent then
			return false
		end
		local humanoidRootPart = arg:FindFirstChild("HumanoidRootPart") or arg:WaitForChild("HumanoidRootPart", 3)
		if not humanoidRootPart then
			return false
		end
		fn39(arg, Hub.InvisibilityTransparency)
		local cFrame = humanoidRootPart.CFrame

		pcall(function()
			arg:MoveTo(Hub.InvisibilitySeatTeleportPosition)
		end)

		task.wait(0.05)
		local humanoidRootPart2 = arg:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart2 or humanoidRootPart2.Position.Y < -50 then
			pcall(function()
				arg:MoveTo(cFrame.Position)
			end)

			fn39(arg, 0)
			return false
		end

		fn37()
		local seat = Instance.new("Seat")
		seat.Name = Hub.InvisibilitySeatName
		seat.Transparency = 1
		seat.CanCollide = false
		seat.Anchored = false
		seat.Position = Hub.InvisibilitySeatTeleportPosition
		seat.Parent = workspace
		local torso = arg:FindFirstChild("Torso") or arg:FindFirstChild("UpperTorso")
		if not torso then
			seat:Destroy()
			return false
		end
		local weld = Instance.new("Weld")
		weld.Part0 = seat
		weld.Part1 = torso
		weld.Parent = seat
		local weld2 = Instance.new("Weld")
		weld2.Part0 = seat
		weld2.Part1 = humanoidRootPart
		weld2.Parent = seat
		task.wait()

		pcall(function()
			seat.CFrame = cFrame
		end)

		return true
	end

	local function fn41()
		Hub.InvisibilityEnabled = false
		fn38()
		fn37()
		fn39(localPlayer.Character, 0)
	end

	local function fn42(arg)
		fn38()
		if not arg or not arg.Parent then
			return
		end
		fn39(arg, Hub.InvisibilityTransparency)

		Hub.InvisibilityDescAddedConn = arg.DescendantAdded:Connect(function(descendant)
			if not Hub.InvisibilityEnabled then
				return
			end

			if descendant:IsA("BasePart") then
				if descendant.Name ~= "HumanoidRootPart" then
					descendant.Transparency = Hub.InvisibilityTransparency
				end

				descendant.LocalTransparencyModifier = Hub.InvisibilityTransparency
			elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
				descendant.Transparency = Hub.InvisibilityTransparency
			end
		end)

		local n2 = 0

		Hub.InvisibilityRefreshConn = RunService.Heartbeat:Connect(function()
			if not Hub.InvisibilityEnabled then
				return
			end
			local character_ = localPlayer.Character
			if not character_ or character_ ~= arg then
				return
			end
			local now = tick()
			if now < n2 then
				return
			end
			n2 = now + 0.2
			fn39(character_, Hub.InvisibilityTransparency)
		end)
	end

	fn35 = function()
		local character_ = localPlayer.Character or localPlayer.CharacterAdded:Wait()

		if not fn40(character_) then
			Hub.InvisibilityEnabled = false

			WindUI:Notify({
				Title = "Invisibility",
				Content = "Invisibility failed on this spawn.",
				Icon = "x",
				Duration = 2,
			})

			fn38()
			return
		end

		fn42(character_)
	end

	fn36 = function(arg)
		if arg == Hub.InvisibilityEnabled then
			return
		end
		Hub.InvisibilityEnabled = arg and true or false

		if Hub.InvisibilityEnabled then
			fn35()
		else
			fn41()
		end
	end
end

Hub.MM2StartupDataReady = false

local function fn37()
	local tbl7 = {
		{ name = "Fake Dead 1", id = 132384701706046 },
		{ name = "Fake Dead 2", id = 89258194846699 },
		{ name = "Wall Phase (GLITCH)", id = 79017619155911 },
	}

	local tbl8 = {}
	local name = tbl7[1].name
	local tbl9 = {}
	local tbl10 = {}
	local tbl11 = {}
	local tbl12 = {}
	local str = ""
	local n2 = 1
	local v9 = nil
	local connection = nil
	local v10 = nil
	local flag7 = false
	local flag8 = false

	local tbl13 = {
		pages = {},
		page = 1,
		mergedEmotes = {},
		interceptedNames = {},
		interceptedIds = {},
		navigationFrame = nil,
		navigationRetryPending = false,
		navigationRetryCount = 0,
		hookInstalled = false,
		syncedToyOrder = {},
		maxSyncedToyTemplates = 48,
	}

	local tbl14 = {}
	local tbl15 = {}
	local v11 = nil
	local v12 = nil
	local v13 = nil
	local v14 = nil
	local v15 = nil

	local function fn38()
		local database = ReplicatedStorage:FindFirstChild("Database")
		local modules = ReplicatedStorage:FindFirstChild("Modules")
		database = database and database:FindFirstChild("Sync")
		modules = modules and modules:FindFirstChild("ProfileData")

		if not v14 and database then
			local ok, result = pcall(require, database)

			if ok and type(result) == "table" then
				v14 = result
			end
		end

		if not v15 and modules then
			local ok, result = pcall(require, modules)

			if ok and type(result) == "table" then
				v15 = result
			end
		end

		return v14 ~= nil and v15 ~= nil
	end

	task.spawn(function()
		local n3 = os.clock() + 5

		while true do
			if foxnameMM2Runtime.alive and not isTerminated then
				if fn38() then
					Hub.MM2StartupDataReady = true
					break
				else
					task.wait(os.clock() < n3 and 0.1 or 1)
					continue
				end
			end

			break
		end
	end)

	local function fn39()
		table.clear(tbl9)
		table.clear(tbl10)

		for _, v16 in ipairs(tbl8) do
			tbl9[v16.name] = v16
			tbl10[tostring(v16.id)] = v16
		end
	end

	fn39()

	local function fn40(arg)
		arg = arg and arg.Animation
		arg = arg and arg.AnimationId
		return arg and arg:match("(%d+)") or nil
	end

	local function fn41(arg)
		if connection then
			connection:Disconnect()
			connection = nil
		end

		arg = arg and arg:FindFirstChildOfClass("Humanoid")

		if arg then
			arg = arg:FindFirstChildOfClass("Animator") or arg:FindFirstChild("Animator")
		end

		if not arg then
			return
		end

		connection = arg.AnimationPlayed:Connect(function(arg2)
			local v16 = fn40(arg2)

			if v16 and tbl10[v16] then
				v9 = arg2
				arg2:AdjustSpeed(n2)
			end
		end)
	end

	local function fn42()
		if not v10 then
			return
		end
		local tbl16 = { "None" }
		local tbl17 = {}

		for k in pairs(tbl11) do
			table.insert(tbl17, k)
		end

		table.sort(tbl17)

		for _, v16 in ipairs(tbl17) do
			table.insert(tbl16, v16)
		end

		local flag9 = false

		if v10.SetValues then
			flag9 = pcall(function()
				v10:SetValues(tbl16)
			end)
		end

		if not flag9 and v10.Refresh then
			flag9 = pcall(function()
				v10:Refresh(tbl16)
			end)
		end

		if not flag9 and v10.Update then
			pcall(function()
				v10:Update(tbl16)
			end)
		end
	end

	local function fn43()
		if v9 then
			pcall(function()
				v9:Stop(0.15)
			end)

			v9 = nil
		end
	end

	local function fn44(arg, arg2)
		fn43()
		if not arg or arg == "None" then
			return nil
		end
		local v16 = tbl12[arg]

		if v16 and not arg2 then
			local playEmote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Misc") and ReplicatedStorage.Remotes.Misc:FindFirstChild("PlayEmote")
			if playEmote and playEmote:IsA("BindableEvent") then
				playEmote:Fire(v16)
				return true
			end
		end

		local v17 = tbl11[arg]
		local character_ = localPlayer.Character
		local humanoid = character_ and character_:FindFirstChildOfClass("Humanoid")
		if not v17 or not humanoid then
			return nil
		end
		tbl13.humanoid = humanoid
		local v18 = nil

		local ok, result, result2 = pcall(function()
			return humanoid:PlayEmoteAndGetAnimTrackById(v17)
		end)

		if ok then
			if typeof(result) == "Instance" and result:IsA("AnimationTrack") then
				v18 = result
			elseif result == true and typeof(result2) == "Instance" and result2:IsA("AnimationTrack") then
				v18 = result2
			end
		end

		if not v18 then
			local animator = humanoid:FindFirstChildOfClass("Animator") or humanoid:FindFirstChild("Animator")

			if not animator then
				animator = Instance.new("Animator")
				animator.Parent = humanoid
			end

			local animation = Instance.new("Animation")
			animation.AnimationId = "rbxassetid://" .. tostring(v17)

			local ok2, result3 = pcall(function()
				return animator:LoadAnimation(animation)
			end)

			animation:Destroy()

			if ok2 then
				v18 = result3

				pcall(function()
					v18:Play(0.15)
				end)
			end
		end

		if v18 then
			v9 = v18

			pcall(function()
				v18:AdjustSpeed(n2)
			end)
		end

		return v18
	end

	Hub.TouchButtons.ToggleWallPhaseButton = function(arg)
		local wallPhaseButtonState = Hub.WallPhaseButtonState
		wallPhaseButtonState.enabled = arg and true or false

		if wallPhaseButtonState.enabled then
			Hub.TouchButtons.Create(wallPhaseButtonState, "Foxname_MM2_WallPhaseButton", "WallPhaseButton", "Wall Glitch", function()
				return false
			end, function()
				local wallPhaseAssist = Hub.WallPhaseAssist

				if wallPhaseAssist and type(wallPhaseAssist.Run) == "function" then
					wallPhaseAssist.Run()
				end
			end, true)
		else
			Hub.TouchButtons.Destroy(wallPhaseButtonState)
		end
	end

	Hub.WallPhaseAssist = { busy = false, emoteName = "Wall Phase (GLITCH)", maxWallDistance = 3 }

	Hub.WallPhaseAssist.Run = function()
		local wallPhaseAssist = Hub.WallPhaseAssist
		if wallPhaseAssist.busy or not foxnameMM2Runtime.alive then
			return false
		end
		wallPhaseAssist.busy = true
		local character_ = localPlayer.Character
		local humanoid = character_ and character_:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = character_ and character_:FindFirstChild("HumanoidRootPart")
		local currentCamera2 = workspace.CurrentCamera

		if not character_ or not humanoid or humanoid.Health <= 0 or not humanoidRootPart or not currentCamera2 then
			wallPhaseAssist.busy = false

			WindUI:Notify({
				Title = "Wall Glitch",
				Content = "Character or camera is not ready.",
				Icon = "x",
				Duration = 2,
			})

			return false
		end

		local vector = Vector3.new(currentCamera2.CFrame.LookVector.X, 0, currentCamera2.CFrame.LookVector.Z)

		if vector.Magnitude < 0.01 then
			vector = Vector3.new(humanoidRootPart.CFrame.LookVector.X, 0, humanoidRootPart.CFrame.LookVector.Z)
		end

		local unit = vector.Unit
		local vector2 = Vector3.new(humanoidRootPart.CFrame.LookVector.X, 0, humanoidRootPart.CFrame.LookVector.Z)
		local unit2 = vector2.Magnitude > 0.01 and vector2.Unit or unit
		local tbl16 = {}
		local v16 = unit:Cross(Vector3.new(0, 1, 0))
		local n3 = -unit:Cross(Vector3.new(0, 1, 0))
		tbl16[1] = -unit
		tbl16[2] = -unit2
		tbl16[3] = unit
		tbl16[4] = unit2
		tbl16[5] = v16
		tbl16[6] = n3
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { character_ }
		raycastParams.IgnoreWater = true
		local hit = nil

		for _, v17 in ipairs(tbl16) do
			hit = workspace:Raycast(humanoidRootPart.Position, v17.Unit * wallPhaseAssist.maxWallDistance, raycastParams)
			if not (hit and hit.Instance and hit.Instance:IsA("BasePart") and hit.Instance.CanCollide and math.abs(hit.Normal.Y) < 0.45) then
				hit = nil
				continue
			end
			break
		end

		if not hit then
			wallPhaseAssist.busy = false

			WindUI:Notify({
				Title = "Wall Glitch",
				Content = "No wall found nearby. Stand within 3 studs.",
				Icon = "scan-search",
				Duration = 3,
			})

			return false
		end

		local n4 = humanoidRootPart.Position + Vector3.new(0, 1.5, 0)
		local n5 = currentCamera2.CFrame.Position - n4

		if Vector3.new(n5.X, 0, n5.Z).Magnitude < 0.5 then
			n5 = Vector3.new(0, 2, 8)
		end

		local vector3 = Vector3.new(-n5.X, n5.Y, -n5.Z)
		local cameraType = currentCamera2.CameraType
		currentCamera2.CameraType = Enum.CameraType.Scriptable
		currentCamera2.CFrame = CFrame.lookAt(n4 + vector3, n4, Vector3.new(0, 1, 0))
		RunService.RenderStepped:Wait()

		local ok, result, result2 = pcall(function()
			return humanoid:PlayEmoteAndGetAnimTrackById(79017619155911)
		end)

		local isAnimationTrack = typeof(result) == "Instance" and result:IsA("AnimationTrack") and result
		local isAnimationTrack2

		if isAnimationTrack then
			isAnimationTrack2 = isAnimationTrack
		else
			isAnimationTrack2 = result == true and typeof(result2) == "Instance" and result2:IsA("AnimationTrack") and result2 or nil
		end

		local flag9

		if ok then
			flag9 = result == true or isAnimationTrack2 ~= nil
		else
			flag9 = ok
		end

		if not flag9 then
			currentCamera2.CameraType = cameraType
			wallPhaseAssist.busy = false

			WindUI:Notify({
				Title = "Wall Glitch",
				Content = "The emote failed to start. Do not move or respawn and try again.",
				Icon = "x",
				Duration = 3,
			})

			return false
		end

		if isAnimationTrack2 then
			v9 = isAnimationTrack2

			pcall(function()
				isAnimationTrack2:AdjustSpeed(n2)
			end)
		end

		task.wait(0.5)
		currentCamera2.CameraType = cameraType
		RunService.RenderStepped:Wait()
		local flag10 = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
		local ok2, result3 = pcall(game.GetService, game, "VirtualInputManager")

		if not ok2 then
			result3 = nil
		end

		local ok3

		if flag10 then
			local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
			local v17 = nil

			if playerGui then
				for _, descendant in ipairs(playerGui:GetDescendants()) do
					if descendant:IsA("GuiButton") then
						local v18 = string.lower(tostring(descendant.Name) .. " " .. tostring(descendant:IsA("TextButton") and descendant.Text or "") .. " " .. tostring(descendant:GetAttribute("Action") or ""))
						if v18:find("shiftlock", 1, true) or v18:find("shift lock", 1, true) or v18:find("mouselock", 1, true) or v18:find("mouse lock", 1, true) then
							v17 = descendant
							break
						end
					end
				end
			end

			if v17 and type(firesignal) == "function" then
				ok3 = pcall(function()
					firesignal(v17.Activated)
				end)
			else
				local v18 = v17 and result3
				ok3 = false

				if v18 then
					local n6 = v17.AbsolutePosition + v17.AbsoluteSize / 2

					ok3 = pcall(function()
						result3:SendMouseButtonEvent(n6.X, n6.Y, 0, true, game, 0)
						RunService.RenderStepped:Wait()
						result3:SendMouseButtonEvent(n6.X, n6.Y, 0, false, game, 0)
					end)
				end
			end
		else
			ok3 = false

			if result3 then
				ok3 = pcall(function()
					result3:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
					RunService.RenderStepped:Wait()
					result3:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
				end)
			end
		end

		if ok3 then
			RunService.RenderStepped:Wait()

			pcall(function()
				local cameraRelative = Enum.RotationType.CameraRelative
				UserSettings():GetService("UserGameSettings").RotationType = cameraRelative
			end)

			pcall(function()
				UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
			end)
		end

		local flag11

		if not ok3 then
			local lookVector = currentCamera2.CFrame.LookVector
			local vector4 = Vector3.new(lookVector.X, 0, lookVector.Z)

			if vector4.Magnitude > 0.01 then
				humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
				humanoidRootPart.CFrame = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + vector4.Unit, Vector3.new(0, 1, 0))
				flag11 = true
			else
				flag11 = ok3
			end
		else
			flag11 = ok3
		end

		wallPhaseAssist.busy = false

		if not flag11 then
			WindUI:Notify({
				Title = "Wall Glitch",
				Content = "Emote started, but Shift Lock or character rotation failed.",
				Icon = "triangle-alert",
				Duration = 3,
			})

			return false
		end

		WindUI:Notify({ Title = "Wall Glitch", Content = "Success!", Icon = "door-open", Duration = 3 })
		return true
	end

	local function fn45()
		local character_ = localPlayer.Character
		local humanoid = character_ and character_:FindFirstChildOfClass("Humanoid")
		tbl13.humanoid = humanoid

		if humanoid then
			humanoid = humanoid:FindFirstChildOfClass("HumanoidDescription") or humanoid:FindFirstChild("HumanoidDescription") or humanoid:WaitForChild("HumanoidDescription", 3)
		end

		return humanoid, character_
	end

	local fn46 = nil

	local function fn47(arg)
		local v16, v17 = fn45()
		local n3 = #tbl13.pages
		if not v16 or n3 == 0 then
			return false
		end
		tbl13.page = math.clamp(tbl13.page, 1, n3)
		local v18 = tbl13.pages[tbl13.page]

		if not pcall(function()
			v16:SetEmotes(tbl13.mergedEmotes)
			v16:SetEquippedEmotes(v18)
		end) then
			return false
		end

		pcall(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, true)
		end)

		fn41(v17)

		task.defer(function()
			if fn46 then
				fn46()
			end
		end)

		if arg then
			task.delay(0.12, function()
				pcall(function()
					GuiService:SetEmotesMenuOpen(true)
				end)
			end)
		end

		return true
	end

	fn46 = function()
		local n3 = #tbl13.pages
		local navigationFrame = tbl13.navigationFrame

		if navigationFrame and not navigationFrame.Parent then
			tbl13.navigationFrame = nil
			navigationFrame = nil
		end

		local robloxGui = game:GetService("CoreGui"):FindFirstChild("RobloxGui")
		robloxGui = robloxGui and robloxGui:FindFirstChild("EmotesMenu")
		robloxGui = robloxGui and robloxGui:FindFirstChild("Children")
		local main = robloxGui and robloxGui:FindFirstChild("Main")
		local emotesWheel = main and main:FindFirstChild("EmotesWheel")

		if not emotesWheel then
			if not tbl13.navigationRetryPending and tbl13.navigationRetryCount < 12 then
				tbl13.navigationRetryCount = tbl13.navigationRetryCount + 1
				tbl13.navigationRetryPending = true

				task.delay(0.25, function()
					tbl13.navigationRetryPending = false
					fn46()
				end)
			end

			return
		end

		tbl13.navigationRetryCount = 0

		pcall(function()
			emotesWheel.ClipsDescendants = false
		end)

		navigationFrame = navigationFrame or emotesWheel:FindFirstChild("FoxnameEmotePages")

		if not navigationFrame then
			navigationFrame = Instance.new("Frame")
			navigationFrame.Name = "FoxnameEmotePages"
			navigationFrame.AnchorPoint = Vector2.new(0.5, 0)
			navigationFrame.Position = UDim2.new(0.5, 0, 1, 12)
			navigationFrame.Size = UDim2.fromOffset(150, 34)
			navigationFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
			navigationFrame.BackgroundTransparency = 0.15
			navigationFrame.BorderSizePixel = 0
			navigationFrame.ZIndex = 100
			navigationFrame.Parent = emotesWheel
			local uiCorner = Instance.new("UICorner")
			uiCorner.CornerRadius = UDim.new(0, 10)
			uiCorner.Parent = navigationFrame
			local textButton = Instance.new("TextButton")
			textButton.Name = "Previous"
			textButton.Size = UDim2.fromOffset(42, 34)
			textButton.BackgroundTransparency = 1
			textButton.Text = "<"
			textButton.TextColor3 = Color3.new(1, 1, 1)
			textButton.TextSize = 22
			textButton.Font = Enum.Font.GothamBold
			textButton.ZIndex = 101
			textButton.Parent = navigationFrame
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "Page"
			textLabel.Position = UDim2.fromOffset(42, 0)
			textLabel.Size = UDim2.fromOffset(66, 34)
			textLabel.BackgroundTransparency = 1
			textLabel.TextColor3 = Color3.new(1, 1, 1)
			textLabel.TextSize = 15
			textLabel.Font = Enum.Font.GothamSemibold
			textLabel.ZIndex = 101
			textLabel.Parent = navigationFrame
			local textButton2 = Instance.new("TextButton")
			textButton2.Name = "Next"
			textButton2.Position = UDim2.fromOffset(108, 0)
			textButton2.Size = UDim2.fromOffset(42, 34)
			textButton2.BackgroundTransparency = 1
			textButton2.Text = ">"
			textButton2.TextColor3 = Color3.new(1, 1, 1)
			textButton2.TextSize = 22
			textButton2.Font = Enum.Font.GothamBold
			textButton2.ZIndex = 101
			textButton2.Parent = navigationFrame

			textButton.Activated:Connect(function()
				local n4 = #tbl13.pages
				if n4 <= 1 then
					return
				end
				tbl13.page = (tbl13.page - 2) % n4 + 1
				fn47(false)
			end)

			textButton2.Activated:Connect(function()
				local n4 = #tbl13.pages
				if n4 <= 1 then
					return
				end
				tbl13.page = tbl13.page % n4 + 1
				fn47(false)
			end)
		end

		tbl13.navigationFrame = navigationFrame
		navigationFrame.Visible = n3 > 1
		local page = navigationFrame:FindFirstChild("Page")

		if page then
			page.Text = string.format("%d / %d", tbl13.page, math.max(n3, 1))
		end
	end

	local function fn48()
		if tbl13.hookInstalled or not hookSupported then
			return
		end
		local v16 = nil

		tbl13.hookInstalled = pcall(function()
			local function fn49(arg, ...)
				local v17 = table.pack(...)
				local v18 = getnamecallmethod()
				if arg ~= tbl13.humanoid then
					return v16(arg, ...)
				end
				local value = select(1, ...)

				if v18 == "PlayEmote" and type(value) == "string" then
					if tbl13.interceptedNames[value] then
						task.defer(function()
							fn44(value, true)
						end)

						return true
					end
				elseif v18 == "PlayEmoteAndGetAnimTrackById" and type(checkcaller) == "function" and not checkcaller() then
					local v19 = tbl13.interceptedIds[tostring(value)]
					if v19 then
						local v20 = fn44(v19, true)
						return v20 ~= nil, v20
					end
				end

				return v16(arg, table.unpack(v17, 1, v17.n))
			end

			if type(newcclosure) == "function" then
				fn49 = newcclosure(fn49)
			end

			v16 = hookmetamethod(game, "__namecall", fn49)
		end) and type(v16) == "function"

		if not tbl13.hookInstalled then
			hookSupported = false
		end
	end

	local function fn49()
		local v16 = fn45()
		if not v16 then
			return false
		end
		local mergedEmotes = {}
		local tbl16 = {}
		local tbl17 = {}
		local tbl18 = { v16 }

		local ok, result = pcall(function()
			return Players:GetHumanoidDescriptionFromUserId(localPlayer.UserId)
		end)

		if not ok or typeof(result) ~= "Instance" or not result:IsA("HumanoidDescription") then
			result = nil
		end

		if result then
			table.insert(tbl18, result)
		end

		for _, v17 in ipairs(tbl18) do
			local ok2, result2 = pcall(function()
				return v17:GetEmotes()
			end)

			if ok2 and type(result2) == "table" then
				for k, v18 in pairs(result2) do
					if type(k) == "string" and k ~= "Next Emote Page" and k:sub(1, 6) ~= "MM2 - " and type(v18) == "table" and not mergedEmotes[k] then
						local tbl19 = {}

						for _, v19 in ipairs(v18) do
							if tonumber(v19) then
								table.insert(tbl19, tonumber(v19))
							end
						end

						if #tbl19 > 0 then
							mergedEmotes[k] = tbl19
						end
					end
				end
			end
		end

		for _, v17 in ipairs(tbl18) do
			local ok2, result2 = pcall(function()
				return v17:GetEquippedEmotes()
			end)

			if ok2 and type(result2) == "table" then
				local tbl19 = {}

				for i, v18 in ipairs(result2) do
					if type(v18) ~= "string" then
						local v19 = nil

						if type(v18) == "table" then
							local name2 = v18.Name or v18.name
							local num = tonumber(v18.Slot or v18.slot)

							if num then
								v18 = name2
								i = num
							else
								v18 = name2
							end
						else
							v18 = v19
						end
					end

					if type(v18) == "string" then
						table.insert(tbl19, { name = v18, slot = i })
					end
				end

				table.sort(tbl19, function(arg, arg2)
					return arg.slot < arg2.slot
				end)

				for _, v18 in ipairs(tbl19) do
					if not (#tbl16 >= 8) then
						local num = mergedEmotes[v18.name]
						num = num and tonumber(num[1])
						local flag9 = v18.name == "Next Emote Page" or v18.name:sub(1, 6) == "MM2 - "

						if num then
							for _, v19 in ipairs(tbl8) do
								if tonumber(v19.id) == num then
									flag9 = true
									break
								end
							end
						end

						if not flag9 and mergedEmotes[v18.name] and not tbl17[v18.name] then
							tbl17[v18.name] = true
							table.insert(tbl16, v18.name)
						end

						continue
					end

					break
				end
			end
		end

		table.clear(tbl11)
		table.clear(tbl10)
		table.clear(tbl12)
		table.clear(tbl13.interceptedNames)
		table.clear(tbl13.interceptedIds)

		for k, mergedEmote in pairs(mergedEmotes) do
			local num = tonumber(mergedEmote[1])

			if num then
				tbl11[k] = num
				tbl10[tostring(num)] = true
			end
		end

		local tbl19 = {}

		for _, v17 in ipairs(tbl8) do
			if v17.nativeSelector == false or not hookSupported then
				tbl11[v17.name] = v17.id
				tbl10[tostring(v17.id)] = v17

				if v17.gameKey then
					tbl12[v17.name] = v17.gameKey
				end
			else
				local name2 = v17.name
				local n3 = 2

				while mergedEmotes[name2] and tonumber(mergedEmotes[name2][1]) ~= tonumber(v17.id) do
					name2 = v17.name .. " (" .. n3 .. ")"
					n3 += 1
				end

				mergedEmotes[name2] = { v17.id }
				tbl11[name2] = v17.id
				tbl10[tostring(v17.id)] = v17

				if v17.gameKey then
					tbl12[name2] = v17.gameKey
				end

				tbl13.interceptedNames[name2] = true
				tbl13.interceptedIds[tostring(v17.id)] = name2
				table.insert(tbl19, name2)
			end
		end

		local tbl20 = {}
		local tbl21 = {}

		for _, v17 in ipairs(tbl16) do
			if not tbl21[v17] then
				tbl21[v17] = true
				table.insert(tbl20, v17)
			end
		end

		for _, v17 in ipairs(tbl19) do
			if not tbl21[v17] then
				tbl21[v17] = true
				table.insert(tbl20, v17)
			end
		end

		table.clear(tbl13.pages)

		for i = 1, #tbl20, 8 do
			local tbl22 = {}

			for i2 = i, math.min(i + 8 - 1, #tbl20) do
				table.insert(tbl22, tbl20[i2])
			end

			table.insert(tbl13.pages, tbl22)
		end

		if #tbl13.pages == 0 then
			table.insert(tbl13.pages, {})
		end

		tbl13.mergedEmotes = mergedEmotes
		tbl13.page = math.clamp(tbl13.page, 1, #tbl13.pages)
		fn48()
		local v17 = fn47(false)

		pcall(function()
			GuiService:SetEmotesMenuOpen(false)
		end)

		fn42()

		if typeof(result) == "Instance" and result:IsA("HumanoidDescription") and result.Parent == nil then
			result:Destroy()
		end

		return v17
	end

	Hub.SyncReadySelectorEmote = function(arg)
		local v16 = nil

		for _, v17 in ipairs(tbl7) do
			if v17.name == arg then
				v16 = v17
				break
			else
				v16 = nil
			end
		end

		if not v16 then
			WindUI:Notify({ Title = "Ready Animations", Content = "Select an animation first.", Icon = "x", Duration = 2 })
			return false
		end

		for _, v17 in ipairs(tbl8) do
			if v17.id == v16.id then
				WindUI:Notify({ Title = "Animation Already Synced", Content = v16.name, Icon = "info", Duration = 2 })
				return true
			end
		end

		table.insert(tbl8, { name = v16.name, id = v16.id })
		fn39()
		if fn49() then
			WindUI:Notify({ Title = "Animation Synced", Content = v16.name, Icon = "check", Duration = 2 })
			return true
		end
		table.remove(tbl8, #tbl8)
		fn39()
		WindUI:Notify({ Title = "Selector Error", Content = "Respawn and try syncing again.", Icon = "x", Duration = 2 })
		return false
	end

	local function fn50(arg)
		local match = tostring(arg or ""):match("^%s*(.-)%s*$")
		if match == "" then
			return nil
		end
		local num = tonumber(match:match("/catalog/(%d+)") or match:match("rbxassetid://(%d+)") or match:match("[?&]id=(%d+)") or match:match("^%d+$") or match:match("(%d%d%d%d%d+)"))
		if not num or num <= 0 then
			return nil
		end
		local match2 = match:match("^%s*([^:\r\n]+)%s*:%s*https?://")
		local match3 = match:match("/catalog/%d+/([^?/#]+)")
		match2 = match2 or match3
		match2 = match2 and match2:gsub("%%20", " "):gsub("[_%-]+", " "):match("^%s*(.-)%s*$")

		if not match2 or match2 == "" then
			match2 = "Custom Emote " .. tostring(num)
		end

		return num, match2
	end

	local function fn51(arg)
		local v16, v17 = fn50(arg)

		if not v16 then
			WindUI:Notify({
				Title = "Invalid Emote",
				Content = "Enter a Roblox catalog link or animation ID",
				Icon = "x",
				Duration = 2,
			})

			return
		end

		for _, v18 in ipairs(tbl8) do
			if v18.id == v16 then
				WindUI:Notify({ Title = "Emote Exists", Content = v18.name, Icon = "info", Duration = 2 })
				return
			end
		end

		local n3 = 2
		local str2 = v17

		while tbl9[str2] do
			str2 = v17 .. " (" .. n3 .. ")"
			n3 += 1
		end

		local tbl16 = { name = str2, id = v16 }
		table.insert(tbl8, tbl16)
		tbl9[str2] = tbl16
		tbl10[tostring(v16)] = tbl16

		if fn49() then
			WindUI:Notify({ Title = "Emote Added", Content = str2, Icon = "check", Duration = 2 })
		else
			WindUI:Notify({ Title = "Selector Error", Content = "Respawn and try again", Icon = "x", Duration = 2 })
		end
	end

	local function fn52(arg, arg2)
		if type(arg) ~= "table" or table.find(arg, arg2) then
			return false
		end
		table.insert(arg, arg2)
		return true
	end

	local function fn53(arg, arg2)
		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		remotes = remotes and remotes:FindFirstChild("Inventory")
		local inventoryDataChanged = remotes and remotes:FindFirstChild("InventoryDataChanged")

		if inventoryDataChanged and inventoryDataChanged:IsA("BindableEvent") then
			pcall(function()
				inventoryDataChanged:Fire(arg, arg2, 1)
			end)
		end
	end

	local function fn54()
		local emotes = v14 and v14.Emotes
		local owned = v15 and v15.Emotes and v15.Emotes.Owned
		if type(emotes) ~= "table" then
			WindUI:Notify({ Title = "Sync Failed", Content = "MM2 emote database not found", Icon = "x", Duration = 2 })
			return
		end
		local n3 = 0

		for k, emote in pairs(emotes) do
			local num = type(emote) == "table" and tonumber(emote.AnimationID)

			if num then
				local flag9 = false

				for _, v16 in ipairs(tbl8) do
					if v16.id == num or v16.gameKey == k then
						flag9 = true
						break
					end
				end

				if not flag9 then
					table.insert(tbl8, {
						name = "MM2 - " .. tostring(emote.Name or k),
						id = num,
						gameKey = k,
						nativeSelector = false,
					})

					n3 += 1
				end

				fn52(owned, k)
			end
		end

		fn39()
		fn49()
		fn53("Emotes", "Synced")

		WindUI:Notify({
			Title = "In-Game Emotes Synced",
			Content = tostring(n3) .. " new emote(s) added",
			Icon = "check",
			Duration = 2,
		})
	end

	local function fn55()
		if not v11 then
			return
		end
		local tbl16 = {}
		table.clear(tbl15)

		for k in pairs(tbl14) do
			local toys = v14 and v14.Toys and v14.Toys[k]
			local flag9 = type(toys) == "table"

			if flag9 then
				flag9 = tostring(toys.Name or k)
			end

			local v16 = flag9 or k

			if tbl15[v16] and tbl15[v16] ~= k then
				v16 ..= " [" .. k .. "]"
			end

			tbl15[v16] = k
			table.insert(tbl16, v16)
		end

		table.sort(tbl16)

		if #tbl16 == 0 then
			tbl16 = { "(No synced items)" }
		end

		local str2 = table.concat(tbl16, "\0")
		if str2 == v13 then
			return
		end
		v13 = str2
		local flag9 = false

		if v11.SetValues then
			flag9 = pcall(function()
				v11:SetValues(tbl16)
			end)
		end

		if not flag9 and v11.Refresh then
			flag9 = pcall(function()
				v11:Refresh(tbl16)
			end)
		end

		if not flag9 and v11.Update then
			pcall(function()
				v11:Update(tbl16)
			end)
		end
	end

	local function fn56(arg)
		if not arg or not arg:IsA("Tool") or tbl14[arg.Name] then
			return false
		end
		local clone = arg:Clone()
		clone.Parent = nil
		tbl14[arg.Name] = clone
		table.insert(tbl13.syncedToyOrder, arg.Name)

		while tbl13.maxSyncedToyTemplates < #tbl13.syncedToyOrder do
			local v16 = table.remove(tbl13.syncedToyOrder, 1)
			local v17 = tbl14[v16]

			if v17 then
				v17:Destroy()
				tbl14[v16] = nil
				v13 = nil
			end
		end

		local owned = v15 and v15.Emotes and v15.Emotes.Owned
		fn52(v15 and v15.Toys and v15.Toys.Owned, arg.Name)
		fn52(owned, arg.Name)
		return true
	end

	local function fn57(arg)
		local n3 = 0

		for _, player in ipairs(Players:GetPlayers()) do
			local backpack = player:FindFirstChildOfClass("Backpack")
			backpack = backpack and backpack:FindFirstChild("Toys")

			if backpack then
				for _, child in ipairs(backpack:GetChildren()) do
					if fn56(child) then
						n3 += 1
					end
				end
			end
		end

		if n3 > 0 then
			fn55()
			fn53("Toys", "Synced")
		end

		if not arg then
			WindUI:Notify({
				Title = "In-Game Items Synced",
				Content = tostring(n3) .. " new item(s) found",
				Icon = "check",
				Duration = 2,
			})
		end
	end

	local function fn58(arg)
		if arg then
			arg = tbl15[arg] or arg
		end

		local v16 = arg and tbl14[arg]
		local backpack = localPlayer:FindFirstChildOfClass("Backpack")
		local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

		if not v16 or not backpack or not humanoid then
			WindUI:Notify({
				Title = "Item Unavailable",
				Content = "Sync items again in a populated server",
				Icon = "x",
				Duration = 2,
			})

			return
		end

		local v17 = backpack:FindFirstChild(arg)

		if v17 and v17:GetAttribute("FoxnameSyncedItem") then
			v17:Destroy()
		end

		local character_ = localPlayer.Character and localPlayer.Character:FindFirstChild(arg)

		if character_ and character_:GetAttribute("FoxnameSyncedItem") then
			character_:Destroy()
		end

		local clone = v16:Clone()
		clone:SetAttribute("FoxnameSyncedItem", true)
		clone.Parent = backpack
		humanoid:EquipTool(clone)
	end

	trackConn(Players.DescendantAdded:Connect(function(descendant)
		if not flag8 or not descendant:IsA("Tool") or not descendant.Parent or descendant.Parent.Name ~= "Toys" or not descendant:FindFirstAncestorOfClass("Player") then
			return
		end

		if fn56(descendant) then
			fn55()
			fn53("Toys", descendant.Name)
		end
	end))

	trackConn(localPlayer.CharacterAdded:Connect(function(character_)
		v9 = nil

		task.delay(1, function()
			fn41(character_)
			fn49()
		end)
	end))

	task.defer(function()
		fn41(localPlayer.Character)
		fn49()
	end)

	Hub.CleanupSelector = function()
		flag7 = false
		flag8 = false

		if Hub.WallPhaseAssist then
			Hub.WallPhaseAssist.busy = false
		end

		if connection then
			connection:Disconnect()
			connection = nil
		end

		fn43()

		for k, v16 in pairs(tbl14) do
			if v16 then
				pcall(function()
					v16:Destroy()
				end)
			end

			tbl14[k] = nil
		end

		table.clear(tbl15)
		table.clear(tbl13.syncedToyOrder)
		v13 = nil
		local character_ = localPlayer.Character

		for _, v16 in ipairs({ localPlayer:FindFirstChildOfClass("Backpack"), character_ }) do
			if v16 then
				for _, child in ipairs(v16:GetChildren()) do
					if child:GetAttribute("FoxnameSyncedItem") then
						child:Destroy()
					end
				end
			end
		end
	end

	task.wait(UI_BUILD_DELAY)

	Tabs.Anims:Dropdown({
		Title = "Ready Animations",
		Values = { "Fake Dead 1", "Fake Dead 2", "Wall Glitch (GLITCH)" },
		Value = name,
		AllowNone = false,
		Callback = function(arg)
			name = tostring(arg or "")
		end,
	})

	Tabs.Anims:Button({
		Title = "Sync Selected Animation",
		Icon = "download",
		Callback = function()
			Hub.SyncReadySelectorEmote(name)
		end,
	})

	Tabs.Anims:Divider()

	Tabs.Anims:Input({
		Title = "Add Custom Emote",
		Type = "Input",
		Desc = "Emote catalog link or id",
		Callback = function(arg)
			str = tostring(arg or "")
		end,
	})

	Tabs.Anims:Button({
		Title = "Add Custom Emote",
		Callback = function()
			fn51(str)
		end,
	})

	Hub.AutoGunTouchControl = tbl2.General:Toggle({
		Title = "Instant Auto Take Gun (Without Teleporting)",
		Flag = "General_InstantAutoTakeGun",
		Default = false,
		LockedTitle = "Automatically enabled and locked\nwhile Coin Farm is active.",
		Callback = function(arg)
			Hub.SetAutoGunTouchSource("misc", arg)
		end,
	})

	Hub.SetCoinFarmAutoGunTouch = function(arg)
		if arg then
			if not Hub.AutoGunTouchForcedByCoinFarm then
				Hub.AutoGunTouchBeforeCoinFarm = Hub.AutoGunTouchSources.misc == true
			end

			Hub.AutoGunTouchForcedByCoinFarm = true
			Hub.SetAutoGunTouchSource("misc", true)
			Hub.AutoGunTouchControl:Unlock()
			Hub.AutoGunTouchControl:Set(true, false, true)
			Hub.AutoGunTouchControl:Lock()
		else
			Hub.AutoGunTouchControl:Unlock()

			if Hub.AutoGunTouchForcedByCoinFarm then
				Hub.AutoGunTouchForcedByCoinFarm = false
				Hub.SetAutoGunTouchSource("misc", Hub.AutoGunTouchBeforeCoinFarm)
				Hub.AutoGunTouchControl:Set(Hub.AutoGunTouchBeforeCoinFarm, false, true)
			end
		end
	end

	tbl2.General:Keybind({
		Title = "Wall Glitch Keybind",
		Flag = "Anims_WallPhaseKeybind",
		Value = "G",
		Callback = function()
			Hub.WallPhaseAssist.Run()
		end,
	})

	tbl2.General:Toggle({
		Title = "Wall Glitch Button",
		Flag = "Anims_WallPhaseButton",
		Default = false,
		Callback = function(arg)
			Hub.TouchButtons.ToggleWallPhaseButton(arg)
		end,
	})

	tbl2.General:Dropdown({
		Title = "Wall Glitch Button Size",
		Flag = "Anims_WallPhaseButtonSize",
		Values = { "Small", "Medium", "Large" },
		Value = Hub.WallPhaseButtonState.size,
		Callback = function(size)
			if Hub.TouchButtons.Sizes[size] then
				Hub.WallPhaseButtonState.size = size
				Hub.TouchButtons.ApplySize(Hub.WallPhaseButtonState.button, size, Hub.WallPhaseButtonState.shape)
			end
		end,
	})

	tbl2.General:Dropdown({
		Title = "Wall Glitch Button Shape",
		Flag = "Anims_WallPhaseButtonShape",
		Values = { "Square", "Rectangle" },
		Value = Hub.WallPhaseButtonState.shape,
		Callback = function(arg)
			Hub.WallPhaseButtonState.shape = arg == "Rectangle" and "Rectangle" or "Square"
			Hub.TouchButtons.ApplySize(Hub.WallPhaseButtonState.button, Hub.WallPhaseButtonState.size, Hub.WallPhaseButtonState.shape)
			Hub.TouchButtons.UpdateHoldHint(Hub.WallPhaseButtonState, Hub.WallPhaseButtonState.button)
		end,
	})

	tbl2.General:Colorpicker({
		Title = "Wall Glitch Icon Color",
		Flag = "Anims_WallPhaseButtonColor",
		Default = Hub.WallPhaseButtonState.outlineColor,
		Callback = function(outlineColor)
			Hub.WallPhaseButtonState.outlineColor = outlineColor
			Hub.TouchButtons.ApplyAppearance(Hub.WallPhaseButtonState.button, Hub.WallPhaseButtonState)
		end,
	})

	tbl2.General:Toggle({
		Title = "Wall Glitch Button Draggable",
		Flag = "Anims_WallPhaseButtonDraggable",
		Default = Hub.WallPhaseButtonState.draggable,
		Callback = function(arg)
			Hub.WallPhaseButtonState.draggable = arg and true or false
		end,
	})

	task.wait(UI_BUILD_DELAY)

	Tabs.Anims:Button({
		Title = "Sync In-Game Emotes",
		Callback = function()
			fn54()
		end,
	})

	Tabs.Anims:Toggle({
		Title = "Auto Sync In-Game Emotes",
		Flag = "Anims_AutoSyncInGameEmotes",
		Default = false,
		Callback = function(arg)
			flag7 = arg and true or false

			if flag7 then
				task.defer(fn54)
			end
		end,
	})

	v10 = Tabs.Anims:Dropdown({
		Title = "Play Emote",
		Values = { "None" },
		Value = "None",
		Callback = function(arg)
			fn44(arg)
		end,
	})

	Tabs.Anims:Slider({
		Title = "Animation Speed",
		Flag = "Anims_AnimationSpeed",
		Value = { Min = 0.1, Max = 3, Default = 1 },
		Step = 0.1,
		Callback = function(arg)
			n2 = tonumber(arg) or 1

			if v9 and v9.IsPlaying then
				v9:AdjustSpeed(n2)
			end
		end,
	})

	Tabs.Anims:Divider()

	Tabs.Anims:Button({
		Title = "Sync In-Game Items",
		Callback = function()
			fn57(false)
		end,
	})

	Tabs.Anims:Toggle({
		Title = "Auto Sync In-Game Items",
		Flag = "Anims_AutoSyncInGameItems",
		Default = false,
		Callback = function(arg)
			flag8 = arg and true or false

			if flag8 then
				task.defer(fn57, true)
			end
		end,
	})

	v11 = Tabs.Anims:Dropdown({
		Title = "In-Game Item",
		Values = { "(No synced items)" },
		Value = nil,
		Callback = function(arg)
			if arg ~= "(No synced items)" then
				v12 = arg
			end
		end,
	})

	Tabs.Anims:Button({
		Title = "Equip Selected Item",
		Callback = function()
			fn58(v12)
		end,
	})
end

fn37()

do
	local SoundService = game:GetService("SoundService")
	local playSong = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Inventory") and ReplicatedStorage.Remotes.Inventory:FindFirstChild("PlaySong")
	local str = "Server (FE)"
	local str2 = ""
	local n2 = 50
	local looped = false
	local sound = nil
	local flag7 = false
	local obj = setmetatable({}, { __mode = "k" })
	local connection = nil
	local connection2 = nil

	local function fn38(arg)
		if not arg or not arg:IsA("Sound") or arg == sound then
			return false
		end

		for _, player in ipairs(Players:GetPlayers()) do
			local character_ = player ~= localPlayer and player.Character or nil

			if character_ and arg:IsDescendantOf(character_) then
				while arg and arg ~= character_ do
					local str3 = arg.Name:lower()
					if str3:find("radio", 1, true) or str3:find("boombox", 1, true) then
						return true
					end
					arg = arg.Parent
				end

				return false
			end
		end

		return false
	end

	local function fn39(arg)
		local v9 = obj[arg]
		if not v9 then
			return
		end

		if v9.connection then
			v9.connection:Disconnect()
		end

		if arg and arg.Parent then
			pcall(function()
				arg.Volume = v9.volume
			end)
		end

		obj[arg] = nil
	end

	local function fn40(descendant)
		if not flag7 or not fn38(descendant) or obj[descendant] then
			return
		end

		obj[descendant] = {
			volume = descendant.Volume,
			connection = descendant:GetPropertyChangedSignal("Volume"):Connect(function()
				if flag7 and descendant.Parent and descendant.Volume ~= 0 then
					descendant.Volume = 0
				end
			end),
		}

		descendant.Volume = 0
	end

	local function fn41(arg)
		flag7 = arg and true or false

		if not flag7 then
			if connection then
				connection:Disconnect()
				connection = nil
			end

			if connection2 then
				connection2:Disconnect()
				connection2 = nil
			end

			for k in pairs(obj) do
				fn39(k)
			end

			return
		end

		if not connection then
			connection = workspace.DescendantAdded:Connect(fn40)
		end

		if not connection2 then
			connection2 = workspace.DescendantRemoving:Connect(function(descendant)
				if obj[descendant] then
					fn39(descendant)
				end
			end)
		end

		task.spawn(function()
			for i, descendant in ipairs(workspace:GetDescendants()) do
				if flag7 then
					if descendant:IsA("Sound") then
						fn40(descendant)
					end

					if i % 250 == 0 then
						RunService.Heartbeat:Wait()
					end

					continue
				end

				break
			end
		end)
	end

	local function fn42()
		if sound and sound.Parent then
			return sound
		end
		local foxnameLocalRadio = SoundService:FindFirstChild("FoxnameLocalRadio")

		if foxnameLocalRadio then
			foxnameLocalRadio:Destroy()
		end

		sound = Instance.new("Sound")
		sound.Name = "FoxnameLocalRadio"
		sound.Volume = n2 / 100
		sound.Looped = looped
		sound.Parent = SoundService
		return sound
	end

	local function fn43(arg)
		local match = tostring(arg or ""):match("(%d+)")
		if not match or tonumber(match) == 0 then
			return nil
		end
		return match
	end

	local function fn44(arg)
		local v9 = fn42()
		v9:Stop()
		v9.SoundId = "rbxassetid://" .. arg
		v9.TimePosition = 0
		v9:Play()
	end

	local function fn45()
		local v9 = fn43(str2)

		if not v9 then
			WindUI:Notify({
				Title = "Radio",
				Content = "Enter a valid Roblox audio ID.",
				Icon = "triangle-alert",
				Duration = 3,
			})

			return
		end

		if str == "Server (FE)" then
			if localPlayer:GetAttribute("Radio") and playSong and playSong:IsA("RemoteEvent") then
				playSong:FireServer("https://www.roblox.com/asset/?id=" .. v9)

				WindUI:Notify({
					Title = "FE Radio",
					Content = "Playing through MM2's server radio.",
					Icon = "radio",
					Duration = 3,
				})

				return
			end

			fn44(v9)

			WindUI:Notify({
				Title = "Radio",
				Content = "MM2 Radio access was not detected. Playing locally instead.",
				Icon = "headphones",
				Duration = 4,
			})

			return
		end

		fn44(v9)
	end

	local function fn46()
		if sound then
			sound:Stop()
			sound.SoundId = ""
		end

		if str == "Server (FE)" and localPlayer:GetAttribute("Radio") and playSong and playSong:IsA("RemoteEvent") then
			playSong:FireServer("")
		end
	end

	task.wait(UI_BUILD_DELAY)

	Tabs.Radio:Paragraph({
		Title = "FE Radio",
		Desc = "Server (FE) uses MM2's replicated radio and requires Radio access. Local mode is heard only by you.",
		Image = "radio",
		ImageSize = 34,
	})

	Tabs.Radio:Input({
		Title = "Audio ID",
		Type = "Input",
		Placeholder = "Enter a Roblox audio ID",
		ClearTextOnFocus = false,
		Callback = function(arg)
			str2 = tostring(arg or "")
		end,
	})

	Tabs.Radio:Dropdown({
		Title = "Radio Mode",
		Flag = "Radio_Mode",
		Values = { "Server (FE)", "Local" },
		Value = "Server (FE)",
		Callback = function(arg)
			if arg == "Server (FE)" or arg == "Local" then
				fn46()
				str = arg
			end
		end,
	})

	task.wait(UI_BUILD_DELAY)

	Tabs.Radio:Slider({
		Title = "Local Volume",
		Flag = "Radio_LocalVolume",
		Value = { Min = 0, Max = 100, Default = 50 },
		Step = 1,
		Callback = function(arg)
			n2 = math.clamp(tonumber(arg) or 50, 0, 100)

			if sound then
				sound.Volume = n2 / 100
			end
		end,
	})

	Tabs.Radio:Toggle({
		Title = "Loop Local Radio",
		Flag = "Radio_LocalLoop",
		Default = false,
		Callback = function(arg)
			looped = arg and true or false

			if sound then
				sound.Looped = looped
			end
		end,
	})

	Tabs.Radio:Toggle({
		Title = "Mute Other Players' Radios",
		Flag = "Radio_MuteOthers",
		Default = false,
		Callback = fn41,
	})

	Tabs.Radio:Button({ Title = "Play Radio", Icon = "play", Callback = fn45 })
	Tabs.Radio:Button({ Title = "Stop Radio", Icon = "square", Callback = fn46 })

	Hub.CleanupRadio = function()
		fn41(false)

		if sound then
			sound:Destroy()
			sound = nil
		end
	end
end

do
	local function fn38()
		local folder = Hub.BulletTracer.folder
		Hub.BulletTracer.folder = nil

		if folder and folder.Parent then
			folder:Destroy()
		end
	end

	local function fn39(arg, arg2)
		local bulletTracer = Hub.BulletTracer
		if not bulletTracer.enabled or not foxnameMM2Runtime.alive then
			return
		end
		local position = typeof(arg) == "CFrame" and arg.Position or typeof(arg) == "Vector3" and arg or typeof(arg) == "Instance" and arg:IsA("Attachment") and arg.WorldPosition

		if not position then
			position = typeof(arg) == "Instance" and arg:IsA("BasePart") and arg.Position
		end

		position = position or nil
		local position2 = typeof(arg2) == "CFrame" and arg2.Position or typeof(arg2) == "Vector3" and arg2 or typeof(arg2) == "Instance" and arg2:IsA("BasePart") and arg2.Position or nil
		if not position or not position2 then
			return
		end
		local n2 = position2 - position
		if n2.Magnitude < 0.05 then
			return
		end
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = localPlayer.Character and { localPlayer.Character } or {}
		local hit = workspace:Raycast(position, n2, raycastParams)

		if hit then
			position2 = hit.Position
		end

		local magnitude = (position2 - position).Magnitude
		if magnitude < 0.05 then
			return
		end
		local folder = bulletTracer.folder

		if not folder or not folder.Parent then
			folder = Instance.new("Folder")
			folder.Name = "FoxnameLocalBulletTracers_" .. sessionId
			folder.Parent = workspace
			bulletTracer.folder = folder
		end

		local part = Instance.new("Part")
		part.Name = "LocalShotTracer"
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.CastShadow = false
		part.Material = Enum.Material.Neon
		part.Color = bulletTracer.color
		part.Transparency = 0.05
		part.Size = Vector3.new(0.35, 0.35, magnitude)
		part.CFrame = CFrame.lookAt(position:Lerp(position2, 0.5), position2)
		part.Parent = folder
		local n3 = math.clamp(tonumber(bulletTracer.duration) or 0.35, 0.05, 3)
		local tween = TweenService:Create(part, TweenInfo.new(n3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 1 })
		tween:Play()

		task.delay(n3 + 0.05, function()
			pcall(function()
				tween:Destroy()
			end)

			if part.Parent then
				part:Destroy()
			end
		end)
	end

	local function fn40(arg, arg2, arg3)
		local character_ = localPlayer.Character
		if not character_ or not Hub.BulletTracer.enabled then
			return
		end

		if not (arg and arg:IsDescendantOf(character_) or character_:FindFirstChild("Gun") ~= nil) then
			return
		end
		local now = os.clock()
		local bulletTracer = Hub.BulletTracer
		if now - bulletTracer.lastDrawAt < bulletTracer.shotCooldown then
			return
		end
		bulletTracer.lastDrawAt = now
		fn39(arg2, arg3)
	end

	pcall(function()
		local weaponEvents = ReplicatedStorage:WaitForChild("WeaponEvents", 3)
		weaponEvents = weaponEvents and weaponEvents:WaitForChild("GunBeam", 3)

		if weaponEvents and weaponEvents:IsA("RemoteEvent") then
			weaponEvents.OnClientEvent:Connect(function(arg, arg2, arg3)
				fn40(arg, arg2, arg3)
			end)
		end
	end)

	pcall(function()
		local clientServices = ReplicatedStorage:WaitForChild("ClientServices", 3)
		clientServices = clientServices and clientServices:WaitForChild("WeaponService", 3)

		if clientServices then
			local module = require(clientServices)

			if module and module.GunFired and module.GunFired.OnClientEvent then
				module.GunFired.OnClientEvent:Connect(function(arg, arg2, arg3)
					fn40(arg, arg2, arg3)
				end)
			end
		end
	end)

	task.wait(UI_BUILD_DELAY)

	Tabs.ESP:Toggle({
		Title = "Player ESP",
		Flag = "ESP_Player",
		Callback = function(playerESP)
			Hub.PlayerESP = playerESP
		end,
	})

	Tabs.ESP:Dropdown({
		Title = "Player ESP Style",
		Flag = "ESP_PlayerStyle",
		Values = { "Filled", "Outline" },
		Value = "Filled",
		Callback = function(playerESPStyle)
			if playerESPStyle == "Filled" or playerESPStyle == "Outline" then
				Hub.PlayerESPStyle = playerESPStyle
			end
		end,
	})

	Tabs.ESP:Toggle({
		Title = "Line ESP",
		Flag = "ESP_Line",
		Callback = function(lineESP)
			Hub.LineESP = lineESP
		end,
	})

	Tabs.ESP:Toggle({
		Title = "Nametag ESP",
		Flag = "ESP_Nametag",
		Callback = function(nametagESP)
			Hub.NametagESP = nametagESP
		end,
	})

	Tabs.ESP:Toggle({
		Title = "Gun ESP",
		Flag = "ESP_Gun",
		Callback = function(gunESP)
			Hub.GunESP = gunESP
		end,
	})

	Tabs.ESP:Toggle({
		Title = "Bullet Tracer",
		Desc = "Draws a neon line for your own Sheriff/Hero shots only.",
		Flag = "ESP_BulletTracer",
		Default = false,
		Callback = function(arg)
			Hub.BulletTracer.enabled = arg and true or false

			if not Hub.BulletTracer.enabled then
				fn38()
			end
		end,
	})
end

Tabs.ESP:Colorpicker({
	Title = "Bullet Tracer Color",
	Flag = "ESP_BulletTracerColor",
	Default = Hub.BulletTracer.color,
	Callback = function(color)
		if typeof(color) == "Color3" then
			Hub.BulletTracer.color = color
		end
	end,
})

Tabs.ESP:Slider({
	Title = "Bullet Tracer Duration",
	Flag = "ESP_BulletTracerDuration",
	Value = { Min = 1, Max = 5, Default = Hub.BulletTracer.duration },
	Step = 0.5,
	Callback = function(arg)
		Hub.BulletTracer.duration = math.clamp(tonumber(arg) or 1, 1, 5)
	end,
})

task.wait(UI_BUILD_DELAY)

Tabs.ESP:Toggle({ Title = "Coin ESP", Flag = "ESP_Coin", Default = false, Callback = fn34 })

Tabs.ESP:Toggle({
	Title = "360 ESP",
	Desc = "Shows off-screen arrows for the Murderer, Sheriff and dropped gun.",
	Flag = "ESP_360",
	Callback = function(arg)
		Hub.ESP360 = arg and true or false
	end,
})


Tabs.ESP:Toggle({
	Title = "Dropped Gun Notify",
	Flag = "ESP_DroppedGunNotify",
	Callback = function(arg)
		Hub.DroppedGunNotify = arg and true or false

		if Hub.DroppedGunNotify then
			for k in pairs(Hub.GunESPTable) do
				fn33(k)
			end
		end
	end,
})

Hub.TouchButtons.XRayToggleControl = Tabs.ESP:Toggle({
	Title = "XRay",
	Flag = "ESP_XRay",
	Callback = function(arg)
		Hub.TouchButtons.SetXRayEnabled(arg, false)
	end,
})

Hub.TouchButtons.XRayKeybindControl = Tabs.ESP:Keybind({
	Title = "XRay Keybind",
	Flag = "ESP_XRayKeybind",
	Value = "V",
	Callback = function()
		Hub.TouchButtons.SetXRayEnabled(not Hub.XRayEnabled, true)
	end,
})

Tabs.ESP:Toggle({
	Title = "XRay Button",
	Flag = "ESP_XRayButton",
	Default = false,
	Callback = function(arg)
		Hub.TouchButtons.ToggleXRayButton(arg)
	end,
})

Tabs.ESP:Dropdown({
	Title = "XRay Button Size",
	Flag = "ESP_XRayButtonSize",
	Values = { "Small", "Medium", "Large" },
	Value = Hub.XRayButtonState.size,
	Callback = function(size)
		if Hub.TouchButtons.Sizes[size] then
			Hub.XRayButtonState.size = size
			Hub.TouchButtons.ApplySize(Hub.XRayButtonState.button, size, Hub.XRayButtonState.shape)
		end
	end,
})

Tabs.ESP:Dropdown({
	Title = "XRay Button Shape",
	Flag = "ESP_XRayButtonShape",
	Values = { "Square", "Rectangle" },
	Value = Hub.XRayButtonState.shape,
	Callback = function(arg)
		Hub.XRayButtonState.shape = arg == "Rectangle" and "Rectangle" or "Square"
		Hub.TouchButtons.ApplySize(Hub.XRayButtonState.button, Hub.XRayButtonState.size, Hub.XRayButtonState.shape)
		Hub.TouchButtons.UpdateHoldHint(Hub.XRayButtonState, Hub.XRayButtonState.button)
	end,
})

Tabs.ESP:Colorpicker({
	Title = "XRay Icon Color",
	Flag = "ESP_XRayButtonColor",
	Default = Hub.XRayButtonState.outlineColor or Hub.TouchButtons.Theme.accentColor,
	Callback = function(outlineColor)
		Hub.XRayButtonState.outlineColor = outlineColor
		Hub.TouchButtons.ApplyAppearance(Hub.XRayButtonState.button, Hub.XRayButtonState)
	end,
})

Tabs.ESP:Toggle({
	Title = "XRay Button Draggable",
	Flag = "ESP_XRayButtonDraggable",
	Default = Hub.XRayButtonState.draggable,
	Callback = function(arg)
		Hub.XRayButtonState.draggable = arg and true or false
	end,
})

do
	local fogColor = Lighting.FogColor

	if typeof(fogColor) == "Color3" and (fogColor.R + fogColor.G + fogColor.B < 0.3) then
		fogColor = Color3.fromRGB(188, 194, 204)
	end

	local worldVisuals = {
		preset = "Default",
		colorEffect = nil,
		bloomEffect = nil,
		sunRaysEffect = nil,
		depthEffect = nil,
		skybox = "Default",
		customSky = nil,
		hiddenSkies = {},
		snowEnabled = false,
		snowDensity = 600,
		snowPart = nil,
		snowEmitter = nil,
		snowConnection = nil,
		fogEnabled = false,
		fogColor = fogColor,
		fogDensity = "Medium",
		fogConnection = nil,
		applyingFog = false,
		original = {
			Ambient = Lighting.Ambient,
			OutdoorAmbient = Lighting.OutdoorAmbient,
			Brightness = Lighting.Brightness,
			ExposureCompensation = Lighting.ExposureCompensation,
			EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
			EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
			GlobalShadows = Lighting.GlobalShadows,
			ShadowSoftness = Lighting.ShadowSoftness,
			FogColor = Lighting.FogColor,
			FogStart = Lighting.FogStart,
			FogEnd = Lighting.FogEnd,
		},
	}

	Hub.WorldVisuals = worldVisuals

	local function createColorCorrectionEffect()
		if worldVisuals.colorEffect and worldVisuals.colorEffect.Parent then
			return worldVisuals.colorEffect
		end
		local v9 = Lighting:FindFirstChild("FoxnameWorldColor_" .. sessionId)

		if v9 then
			v9:Destroy()
		end

		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Name = "FoxnameWorldColor_" .. sessionId
		colorCorrectionEffect.Parent = Lighting
		worldVisuals.colorEffect = colorCorrectionEffect
		return colorCorrectionEffect
	end

	local function fn38()
		if not (worldVisuals.bloomEffect and worldVisuals.bloomEffect.Parent) then
			local bloomEffect = Instance.new("BloomEffect")
			bloomEffect.Name = "FoxnameWorldBloom_" .. sessionId
			bloomEffect.Parent = Lighting
			worldVisuals.bloomEffect = bloomEffect
		end

		if not (worldVisuals.sunRaysEffect and worldVisuals.sunRaysEffect.Parent) then
			local sunRaysEffect = Instance.new("SunRaysEffect")
			sunRaysEffect.Name = "FoxnameWorldSunRays_" .. sessionId
			sunRaysEffect.Parent = Lighting
			worldVisuals.sunRaysEffect = sunRaysEffect
		end

		if not (worldVisuals.depthEffect and worldVisuals.depthEffect.Parent) then
			local depthOfFieldEffect = Instance.new("DepthOfFieldEffect")
			depthOfFieldEffect.Name = "FoxnameWorldDepth_" .. sessionId
			depthOfFieldEffect.Parent = Lighting
			worldVisuals.depthEffect = depthOfFieldEffect
		end

		return worldVisuals.bloomEffect, worldVisuals.sunRaysEffect, worldVisuals.depthEffect
	end

	local tbl7 = {
		["Purple Nebula"] = {
			Bk = "159454299",
			Dn = "159454296",
			Ft = "159454293",
			Lf = "159454286",
			Rt = "159454300",
			Up = "159454288",
		},
		["Dreamy Sunset"] = {
			Bk = "1417494030",
			Dn = "1417494146",
			Ft = "1417494253",
			Lf = "1417494402",
			Rt = "1417494499",
			Up = "1417494643",
		},
		Redshift = {
			Bk = "401664839",
			Dn = "401664862",
			Ft = "401664960",
			Lf = "401664881",
			Rt = "401664901",
			Up = "401664936",
		},
	}

	local fn39 = nil

	local function fn40()
		if worldVisuals.customSky then
			worldVisuals.customSky:Destroy()
			worldVisuals.customSky = nil
		end

		for _, hiddenSky in ipairs(worldVisuals.hiddenSkies) do
			if hiddenSky and hiddenSky.Parent == nil then
				hiddenSky.Parent = Lighting
			end
		end

		table.clear(worldVisuals.hiddenSkies)
	end

	local function fn41(arg)
		local str = tostring(arg or "Default")
		worldVisuals.skybox = tbl7[str] and str or "Default"
		fn40()

		for _, child in ipairs(Lighting:GetChildren()) do
			if child:IsA("Atmosphere") then
				pcall(function()
					child:Destroy()
				end)
			end
		end

		if worldVisuals.skybox == "Default" then
			if worldVisuals.fogEnabled and fn39 then
				task.defer(fn39)
			end

			return
		end

		for _, child in ipairs(Lighting:GetChildren()) do
			if child:IsA("Sky") then
				table.insert(worldVisuals.hiddenSkies, child)
				child.Parent = nil
			end
		end

		local v9 = tbl7[worldVisuals.skybox]
		if not v9 then
			return
		end
		local sky = Instance.new("Sky")
		sky.Name = "FoxnameWorldSky_" .. sessionId
		sky.SkyboxBk = "rbxassetid://" .. v9.Bk
		sky.SkyboxDn = "rbxassetid://" .. v9.Dn
		sky.SkyboxFt = "rbxassetid://" .. v9.Ft
		sky.SkyboxLf = "rbxassetid://" .. v9.Lf
		sky.SkyboxRt = "rbxassetid://" .. v9.Rt
		sky.SkyboxUp = "rbxassetid://" .. v9.Up
		sky.CelestialBodiesShown = true
		sky.SunAngularSize = 0
		sky.MoonAngularSize = 0
		sky.StarCount = 3000
		sky.Parent = Lighting
		worldVisuals.customSky = sky

		if worldVisuals.fogEnabled and fn39 then
			task.defer(fn39)
		end
	end

	local function fn42()
		if worldVisuals.fogConnection then
			worldVisuals.fogConnection:Disconnect()
			worldVisuals.fogConnection = nil
		end
	end

	local function fn43()
		if worldVisuals.snowConnection then
			worldVisuals.snowConnection:Disconnect()
			worldVisuals.snowConnection = nil
		end

		if worldVisuals.snowPart then
			worldVisuals.snowPart:Destroy()
			worldVisuals.snowPart = nil
			worldVisuals.snowEmitter = nil
		end
	end

	local function fn44(arg)
		worldVisuals.snowEnabled = arg and true or false
		fn43()
		if not worldVisuals.snowEnabled then
			return
		end
		local part = Instance.new("Part")
		part.Name = "FoxnameSnowEmitter_" .. sessionId
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Transparency = 1
		part.Size = Vector3.new(96, 1, 96)
		part.Parent = workspace
		local particleEmitter = Instance.new("ParticleEmitter")
		particleEmitter.Name = "Snowflakes"
		particleEmitter.Texture = "rbxassetid://8158344433"
		particleEmitter.Rate = worldVisuals.snowDensity
		particleEmitter.Lifetime = NumberRange.new(3.6, 5.2)
		particleEmitter.Speed = NumberRange.new(12, 19)
		particleEmitter.Acceleration = Vector3.new(1.8, -4.2, 0.9)
		particleEmitter.Drag = 0.65
		particleEmitter.Rotation = NumberRange.new(0, 360)
		particleEmitter.RotSpeed = NumberRange.new(-55, 55)
		local numberSequence = NumberSequence.new
		local tbl8 = {}
		local v9 = NumberSequenceKeypoint.new(0, 0.38)
		local v10 = NumberSequenceKeypoint.new(0.7, 0.27)
		local new = NumberSequenceKeypoint.new
		tbl8[1] = v9
		tbl8[2] = v10

		do
			local values = table.pack(new(1, 0.08))
			table.move(values, 1, values.n, 3, tbl8)
		end

		particleEmitter.Size = numberSequence(tbl8)
		local numberSequence2 = NumberSequence.new
		local tbl9 = {}
		local v11 = NumberSequenceKeypoint.new(0, 0.02)
		local v12 = NumberSequenceKeypoint.new(0.82, 0.1)
		local new2 = NumberSequenceKeypoint.new
		tbl9[1] = v11
		tbl9[2] = v12

		do
			local values = table.pack(new2(1, 1))
			table.move(values, 1, values.n, 3, tbl9)
		end

		particleEmitter.Transparency = numberSequence2(tbl9)
		particleEmitter.LightInfluence = 0.25
		particleEmitter.LightEmission = 0.58
		particleEmitter.EmissionDirection = Enum.NormalId.Bottom
		particleEmitter.SpreadAngle = Vector2.new(12, 12)

		pcall(function()
			particleEmitter.Shape = Enum.ParticleEmitterShape.Box
			particleEmitter.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
			particleEmitter.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
		end)

		particleEmitter.Parent = part
		worldVisuals.snowPart = part
		worldVisuals.snowEmitter = particleEmitter
		local n2 = 0

		worldVisuals.snowConnection = RunService.Heartbeat:Connect(function(deltaTime)
			n2 += deltaTime
			if n2 < 0.083333333333333329 then
				return
			end
			n2 = 0
			local currentCamera2 = workspace.CurrentCamera
			if not currentCamera2 or not part.Parent then
				return
			end
			local position = currentCamera2.CFrame.Position
			part.CFrame = CFrame.new(position.X, position.Y + 30, position.Z)
		end)
	end

	local fn45 = nil

	fn45 = function(arg)
		if typeof(arg) == "Color3" then
			return arg
		end

		if type(arg) == "string" then
			local match = arg:match("^%s*#?([%x][%x][%x][%x][%x][%x])%s*$")
			if not match then
				return nil
			end
			local ok, result = pcall(Color3.fromHex, "#" .. match)
			return ok and result or nil
		end

		if type(arg) ~= "table" then
			return nil
		end
		local color = arg.Color or arg.color or arg.Value or arg.value

		if color ~= nil then
			local v9 = fn45(color)
			if v9 then
				return v9
			end
		end

		local num = tonumber(arg.R or arg.r or arg[1])
		local num2 = tonumber(arg.G or arg.g or arg[2])
		local num3 = tonumber(arg.B or arg.b or arg[3])
		if not num or not num2 or not num3 then
			return nil
		end

		if num > 1 or num2 > 1 or num3 > 1 then
			local clamp = math.clamp
			return Color3.fromRGB(math.clamp(num, 0, 255), math.clamp(num2, 0, 255), clamp(num3, 0, 255))
		end
		local clamp = math.clamp
		return Color3.new(math.clamp(num, 0, 1), math.clamp(num2, 0, 1), clamp(num3, 0, 1))
	end

	fn39 = function()
		if worldVisuals.applyingFog then
			return
		end
		worldVisuals.applyingFog = true

		if not worldVisuals.fogEnabled then
			Lighting.FogColor = worldVisuals.original.FogColor
			Lighting.FogStart = worldVisuals.original.FogStart
			Lighting.FogEnd = worldVisuals.original.FogEnd
			worldVisuals.applyingFog = false
			return
		end

		local str = tostring(worldVisuals.fogDensity or "Medium")

		local tbl8 = {
			Low = { FogStart = 60, FogEnd = 500 },
			Medium = { FogStart = 25, FogEnd = 300 },
			High = { FogStart = 5, FogEnd = 150 },
		}

		local medium = tbl8[str] or tbl8.Medium
		Lighting.FogColor = worldVisuals.fogColor
		Lighting.FogStart = medium.FogStart
		Lighting.FogEnd = medium.FogEnd
		worldVisuals.applyingFog = false
	end

	local function fn46(arg)
		fn42()
		worldVisuals.fogEnabled = arg and true or false
		fn39()

		if worldVisuals.fogEnabled then
			worldVisuals.fogConnection = Lighting:GetPropertyChangedSignal("FogEnd"):Connect(function()
				if worldVisuals.fogEnabled and not worldVisuals.applyingFog then
					task.defer(fn39)
				end
			end)
		end
	end

	local function fn47(arg)
		worldVisuals.preset = tostring(arg or "Default")
		local v9 = createColorCorrectionEffect()
		local v10, v11, v12 = fn38()
		v9.Enabled = worldVisuals.preset ~= "Default"
		v9.Brightness = 0
		v9.Contrast = 0
		v9.Saturation = 0
		v9.TintColor = Color3.new(1, 1, 1)
		v10.Enabled = false
		v10.Intensity = 0
		v10.Size = 18
		v10.Threshold = 1.2
		v11.Enabled = false
		v11.Intensity = 0
		v11.Spread = 0.8
		v12.Enabled = false
		v12.FarIntensity = 0
		v12.FocusDistance = 55
		v12.InFocusRadius = 40
		v12.NearIntensity = 0
		Lighting.Ambient = worldVisuals.original.Ambient
		Lighting.OutdoorAmbient = worldVisuals.original.OutdoorAmbient
		Lighting.Brightness = worldVisuals.original.Brightness
		Lighting.ExposureCompensation = worldVisuals.original.ExposureCompensation
		Lighting.EnvironmentDiffuseScale = worldVisuals.original.EnvironmentDiffuseScale
		Lighting.EnvironmentSpecularScale = worldVisuals.original.EnvironmentSpecularScale
		Lighting.GlobalShadows = worldVisuals.original.GlobalShadows
		Lighting.ShadowSoftness = worldVisuals.original.ShadowSoftness

		if worldVisuals.preset == "RTX Reflection & Shaders" then
			v9.Contrast = 0.12
			v9.Saturation = 0.1
			v9.TintColor = Color3.fromRGB(255, 255, 255)
			Lighting.EnvironmentDiffuseScale = 1
			Lighting.EnvironmentSpecularScale = 1
			Lighting.GlobalShadows = true
			Lighting.ShadowSoftness = 0.12
			Lighting.ExposureCompensation = 0.1
			v10.Enabled = true
			v10.Intensity = 0.18
			v10.Size = 28
			v10.Threshold = 1.05
			v11.Enabled = true
			v11.Intensity = 0.045
			v11.Spread = 0.8
			v12.Enabled = true
			v12.FarIntensity = 0.02
			v12.FocusDistance = 55
			v12.InFocusRadius = 42
			v12.NearIntensity = 0.02

			if atmosphere then
				atmosphere.Density = 0.3
				atmosphere.Offset = 0.25
				atmosphere.Haze = 0.15
				atmosphere.Color = Color3.fromRGB(199, 218, 255)
				atmosphere.Decay = Color3.fromRGB(106, 122, 160)
			end
		elseif worldVisuals.preset == "Realistic Shader" then
			v9.Contrast = 0.09
			v9.Saturation = 0.06
			v9.TintColor = Color3.fromRGB(248, 251, 255)
			Lighting.EnvironmentDiffuseScale = 1
			Lighting.EnvironmentSpecularScale = 1
			Lighting.GlobalShadows = true
			Lighting.ShadowSoftness = 0.18
			v10.Enabled = true
			v10.Intensity = 0.12
			v10.Size = 24
			v10.Threshold = 1.15
			v11.Enabled = true
			v11.Intensity = 0.035
			v11.Spread = 0.76
			v12.Enabled = true
			v12.FarIntensity = 0.018
			v12.FocusDistance = 60
			v12.InFocusRadius = 46
			v12.NearIntensity = 0.025

			if atmosphere then
				atmosphere.Density = 0.25
				atmosphere.Offset = 0.1
				atmosphere.Haze = 0.1
			end
		elseif worldVisuals.preset == "Deep Shader" then
			v9.Contrast = 0.145
			v9.Saturation = 0.04
			v9.TintColor = Color3.fromRGB(241, 247, 255)
			Lighting.EnvironmentDiffuseScale = 0.95
			Lighting.EnvironmentSpecularScale = 1
			Lighting.GlobalShadows = true
			Lighting.ShadowSoftness = 0.1
			v10.Enabled = true
			v10.Intensity = 0.1
			v10.Size = 22
			v10.Threshold = 1.22
			v12.Enabled = true
			v12.FarIntensity = 0.025
			v12.FocusDistance = 52
			v12.InFocusRadius = 38
			v12.NearIntensity = 0.035

			if atmosphere then
				atmosphere.Density = 0.35
				atmosphere.Offset = 0.15
				atmosphere.Haze = 0.2
			end
		elseif worldVisuals.preset == "Cinematic" then
			v9.Contrast = 0.16
			v9.Saturation = -0.03
			v9.TintColor = Color3.fromRGB(235, 242, 255)
			Lighting.EnvironmentDiffuseScale = 0.9
			Lighting.EnvironmentSpecularScale = 0.98
			Lighting.GlobalShadows = true
			Lighting.ShadowSoftness = 0.14
			v10.Enabled = true
			v10.Intensity = 0.13
			v10.Size = 26
			v10.Threshold = 1.16
			v11.Enabled = true
			v11.Intensity = 0.028
			v11.Spread = 0.7
			v12.Enabled = true
			v12.FarIntensity = 0.04
			v12.FocusDistance = 48
			v12.InFocusRadius = 34
			v12.NearIntensity = 0.055

			if atmosphere then
				atmosphere.Density = 0.4
				atmosphere.Offset = 0.3
				atmosphere.Haze = 0.25
			end
		elseif worldVisuals.preset == "Soft Shader" then
			v9.Contrast = 0.055
			v9.Saturation = 0.03
			v9.TintColor = Color3.fromRGB(255, 248, 243)
			Lighting.EnvironmentDiffuseScale = 0.95
			Lighting.EnvironmentSpecularScale = 0.95
			Lighting.GlobalShadows = true
			Lighting.ShadowSoftness = 0.28
			v10.Enabled = true
			v10.Intensity = 0.09
			v10.Size = 20
			v10.Threshold = 1.28
			v12.Enabled = true
			v12.FarIntensity = 0.012
			v12.FocusDistance = 64
			v12.InFocusRadius = 52
			v12.NearIntensity = 0.018
		else
			worldVisuals.preset = "Default"
			v9.Enabled = false
		end
	end

	task.wait(UI_BUILD_DELAY)

	Tabs.ESP:Section({ Title = "Shaders & Lighting", TextXAlignment = "Center", TextSize = 17, Opened = true })

	Tabs.ESP:Dropdown({
		Title = "Shader Preset",
		Flag = "Visuals_WorldPreset",
		Values = {
			"Default",
			"RTX Reflection & Shaders",
			"Realistic Shader",
			"Deep Shader",
			"Cinematic",
			"Soft Shader",
		},
		Value = "Default",
		Callback = fn47,
	})

	Tabs.ESP:Slider({
		Title = "Reflection Specular Scale",
		Flag = "Visuals_ReflectionScale",
		Value = { Min = 0, Max = 1, Default = 1 },
		Step = 0.05,
		Callback = function(arg)
			Lighting.EnvironmentSpecularScale = math.clamp(tonumber(arg) or 1, 0, 1)
			Lighting.EnvironmentDiffuseScale = math.clamp(tonumber(arg) or 1, 0, 1)
		end,
	})

	task.wait(UI_BUILD_DELAY)

	Tabs.ESP:Section({ Title = "Skybox / Weather", TextXAlignment = "Center", TextSize = 17, Opened = true })

	Tabs.ESP:Dropdown({
		Title = "Skybox",
		Flag = "Visuals_Skybox",
		Values = { "Default", "Purple Nebula", "Dreamy Sunset", "Redshift" },
		Value = "Default",
		Callback = fn41,
	})

	Tabs.ESP:Toggle({ Title = "Snowflakes", Flag = "Visuals_Snowflakes", Default = false, Callback = fn44 })

	Tabs.ESP:Dropdown({
		Title = "Snow Density",
		Flag = "Visuals_SnowDensityLevel",
		Values = { "Low", "Medium", "High" },
		Value = "Medium",
		Callback = function(arg)
			local tbl8 = { Low = 300, Medium = 600, High = 1000 }
			worldVisuals.snowDensity = tbl8[tostring(arg)] or tbl8.Medium

			if worldVisuals.snowEmitter then
				worldVisuals.snowEmitter.Rate = worldVisuals.snowDensity
			end
		end,
	})

	Tabs.ESP:Toggle({ Title = "Fog", Flag = "Visuals_Fog", Default = false, Callback = fn46 })

	worldVisuals.fogColorControl = Tabs.ESP:Colorpicker({
		Title = "Fog Color",
		Flag = "Visuals_FogColor",
		Default = worldVisuals.fogColor,
		Callback = function(arg)
			local v9 = fn45(arg)

			if v9 then
				worldVisuals.fogColor = v9

				if worldVisuals.fogEnabled then
					fn39()
				end
			end
		end,
	})

	Hub.SyncConfigColorValues = function()
		local fogColorControl = worldVisuals.fogColorControl
		fogColorControl = fogColorControl and fn45(fogColorControl.Default)

		if fogColorControl then
			worldVisuals.fogColor = fogColorControl
			fn39()
		end
	end

	Tabs.ESP:Dropdown({
		Title = "Fog Density",
		Flag = "Visuals_FogDensityLevel",
		Values = { "Low", "Medium", "High" },
		Value = "Medium",
		Callback = function(arg)
			local str = tostring(arg or "Medium")
			worldVisuals.fogDensity = (str == "Low" or str == "High") and str or "Medium"

			if worldVisuals.fogEnabled then
				fn39()
			end
		end,
	})

	Hub.CleanupWorldVisuals = function()
		fn43()
		fn42()
		fn40()

		if worldVisuals.colorEffect then
			worldVisuals.colorEffect:Destroy()
		end

		if worldVisuals.bloomEffect then
			worldVisuals.bloomEffect:Destroy()
		end

		if worldVisuals.sunRaysEffect then
			worldVisuals.sunRaysEffect:Destroy()
		end

		if worldVisuals.depthEffect then
			worldVisuals.depthEffect:Destroy()
		end

		Lighting.Ambient = worldVisuals.original.Ambient
		Lighting.OutdoorAmbient = worldVisuals.original.OutdoorAmbient
		Lighting.Brightness = worldVisuals.original.Brightness
		Lighting.ExposureCompensation = worldVisuals.original.ExposureCompensation
		Lighting.EnvironmentDiffuseScale = worldVisuals.original.EnvironmentDiffuseScale
		Lighting.EnvironmentSpecularScale = worldVisuals.original.EnvironmentSpecularScale
		Lighting.GlobalShadows = worldVisuals.original.GlobalShadows
		Lighting.ShadowSoftness = worldVisuals.original.ShadowSoftness
		Lighting.FogColor = worldVisuals.original.FogColor
		Lighting.FogStart = worldVisuals.original.FogStart
		Lighting.FogEnd = worldVisuals.original.FogEnd
	end
end

task.wait(UI_BUILD_DELAY)

Tabs.Crosshair:Toggle({
	Title = "Custom Crosshair",
	Flag = "Visuals_CrosshairEnabled",
	Default = false,
	Callback = function(arg)
		Hub.Crosshair.SetEnabled(arg)
	end,
})

Tabs.Crosshair:Dropdown({
	Title = "Crosshair Style",
	Flag = "Visuals_CrosshairStyle",
	Values = { "star", "heart", "circle-plus", "crosshair" },
	Value = Hub.Crosshair.style,
	Callback = function(style)
		if style == "star" or style == "heart" or style == "circle-plus" or style == "crosshair" then
			Hub.Crosshair.style = style

			if Hub.Crosshair.enabled then
				Hub.Crosshair.Rebuild()
			end
		end
	end,
})

Tabs.Crosshair:Dropdown({
	Title = "Crosshair Visibility",
	Flag = "Visuals_CrosshairMode",
	Values = { "Shiftlock / First Person", "Always" },
	Value = Hub.Crosshair.mode,
	Callback = function(mode)
		if mode == "Shiftlock / First Person" or mode == "Always" then
			Hub.Crosshair.mode = mode
		end
	end,
})

Tabs.Crosshair:Input({
	Title = "Custom Cursor Name",
	Desc = "Enter the name of any cursor from https://lucide.dev/icons",
	Type = "Input",
	Placeholder = "sparkles",
	Callback = function(arg)
		Hub.Crosshair.SetCustomIcon(arg)
	end,
})

Tabs.Crosshair:Slider({
	Title = "Crosshair Size",
	Flag = "Visuals_CrosshairSize",
	Value = { Min = 16, Max = 64, Default = Hub.Crosshair.size },
	Step = 1,
	Callback = function(arg)
		Hub.Crosshair.size = tonumber(arg) or 30

		if Hub.Crosshair.enabled then
			Hub.Crosshair.Rebuild()
		end
	end,
})

Tabs.Crosshair:Toggle({
	Title = "RGB Crosshair",
	Flag = "Visuals_CrosshairRGB",
	Default = false,
	Callback = function(arg)
		Hub.Crosshair.rgb = arg and true or false
		Hub.Crosshair.ApplyAppearance()
	end,
})

Hub.Crosshair.colorControl = Tabs.Crosshair:Colorpicker({
	Title = "Crosshair Color",
	Flag = "Visuals_CrosshairColor",
	Default = Hub.Crosshair.color,
	Callback = function(color)
		if typeof(color) == "Color3" then
			Hub.Crosshair.color = color
			Hub.Crosshair.ApplyAppearance()
		end
	end,
})

local syncConfigColorValues = Hub.SyncConfigColorValues

Hub.SyncConfigColorValues = function()
	if syncConfigColorValues then
		syncConfigColorValues()
	end

	local colorControl = Hub.Crosshair.colorControl
	colorControl = colorControl and colorControl.Default

	if typeof(colorControl) == "Color3" then
		Hub.Crosshair.color = colorControl
		Hub.Crosshair.ApplyAppearance()
	end
end

task.wait(UI_BUILD_DELAY)

Tabs.Combat:Section({ Title = "Aim", TextXAlignment = "Center", TextSize = 17, Opened = true })

Hub.TouchButtons.AimToggleControl = Tabs.Aim:Toggle({
	Title = "Aim",
	Flag = "Aim_Enabled",
	Callback = function(arg)
		Hub.TouchButtons.SetAimEnabled(arg, false)
	end,
})

Tabs.Aim:Slider({
	Title = "Prediction Strength",
	Flag = "Aim_Prediction_Strength",
	Value = { Min = 1, Max = 15, Default = 5 },
	Step = 1,
	Suffix = "ms*10",
	Callback = function(predictionStrength)
		Hub.PredictionStrength = predictionStrength
	end,
})

Tabs.Aim:Dropdown({
	Title = "Aim Style",
	Flag = "Aim_Style",
	Values = { "Aimlock", "Silent Aim" },
	Value = Hub.AimStyle,
	Callback = function(aimStyle)
		if aimStyle == "Aimlock" or aimStyle == "Silent Aim" then
			Hub.AimStyle = aimStyle

			if aimStyle == "Silent Aim" and not silentAimSupported then
				WindUI:Notify({
					Title = "Silent Aim",
					Content = "This feature may not work!",
					Icon = "triangle-alert",
					Duration = 5,
				})
			end
		end
	end,
})

Tabs.Aim:Keybind({
	Title = "Aimlock Keybind",
	Flag = "Aim_Keybind",
	Value = "Q",
	Callback = function()
		Hub.TouchButtons.SetAimEnabled(not Hub.AimEnabled, true)
	end,
})

Tabs.Aim:Toggle({
	Title = "Aimlock Button",
	Flag = "Aim_Button",
	Default = false,
	Callback = function(arg)
		Hub.TouchButtons.ToggleAimlockButton(arg)
	end,
})

Tabs.Aim:Dropdown({
	Title = "Aimlock Button Size",
	Flag = "Aim_ButtonSize",
	Values = { "Small", "Medium", "Large" },
	Value = Hub.AimlockButtonState.size,
	Callback = function(size)
		if Hub.TouchButtons.Sizes[size] then
			Hub.AimlockButtonState.size = size
			Hub.TouchButtons.ApplySize(Hub.AimlockButtonState.button, size, Hub.AimlockButtonState.shape)
		end
	end,
})

Tabs.Aim:Dropdown({
	Title = "Aimlock Button Shape",
	Flag = "Aim_ButtonShape",
	Values = { "Square", "Rectangle" },
	Value = Hub.AimlockButtonState.shape,
	Callback = function(arg)
		Hub.AimlockButtonState.shape = arg == "Rectangle" and "Rectangle" or "Square"
		Hub.TouchButtons.ApplySize(Hub.AimlockButtonState.button, Hub.AimlockButtonState.size, Hub.AimlockButtonState.shape)
		Hub.TouchButtons.UpdateHoldHint(Hub.AimlockButtonState, Hub.AimlockButtonState.button)
	end,
})

Tabs.Aim:Colorpicker({
	Title = "Aimlock Icon Color",
	Flag = "Aim_ButtonColor",
	Default = Hub.AimlockButtonState.outlineColor or Hub.TouchButtons.Theme.accentColor,
	Callback = function(outlineColor)
		Hub.AimlockButtonState.outlineColor = outlineColor
		Hub.TouchButtons.ApplyAppearance(Hub.AimlockButtonState.button, Hub.AimlockButtonState)
	end,
})

Tabs.Aim:Toggle({
	Title = "Aimlock Button Draggable",
	Flag = "Aim_ButtonDraggable",
	Default = Hub.AimlockButtonState.draggable,
	Callback = function(arg)
		Hub.AimlockButtonState.draggable = arg and true or false
	end,
})

Tabs.Aim:Slider({
	Title = "FOV Size",
	Flag = "Aim_FOVSize",
	Value = { Min = 50, Max = 400, Default = Hub.FOV },
	Step = 5,
	Callback = function(fov)
		Hub.FOV = fov
	end,
})

Tabs.Aim:Dropdown({
	Title = "Aimlock Part",
	Flag = "Aim_AimlockPart",
	Values = { "Head", "HumanoidRootPart", "Torso" },
	Value = Hub.AimlockPart,
	Callback = function(aimlockPart)
		if aimlockPart == "Head" or aimlockPart == "HumanoidRootPart" or aimlockPart == "Torso" then
			Hub.AimlockPart = aimlockPart
		end
	end,
})

Tabs.Aim:Toggle({
	Title = "Hide FOV",
	Flag = "Aim_HideFOV",
	Callback = function(hideFOV)
		Hub.HideFOV = hideFOV
	end,
})

Tabs.Aim:Toggle({
	Title = "Only Aim While Sheriff",
	Flag = "Aim_OnlyWhileSheriff",
	Callback = function(arg)
		Hub.OnlyAimWhileSheriff = arg and true or false
	end,
})

Tabs.Aim:Toggle({
	Title = "Ignore Walls",
	Flag = "Aim_IgnoreWalls",
	Callback = function(ignoreWalls)
		Hub.IgnoreWalls = ignoreWalls
	end,
})

task.wait(UI_BUILD_DELAY)

Tabs.Combat:Section({ Title = "Sheriff", TextXAlignment = "Center", TextSize = 17, Opened = true })

Hub.TouchButtons.AutoShootToggleControl = tbl2.Sheriff:Toggle({
	Title = "Auto Shoot Button",
	Flag = "Sheriff_AutoShootButton",
	Desc = "You need a GUN for this",
	Default = Hub.AutoShootDragState.enabled,
	Callback = function(arg)
		Hub.TouchButtons.ToggleAutoShootButton(arg)
	end,
})

tbl2.Sheriff:Dropdown({
	Title = "Auto Shoot Mode",
	Flag = "Sheriff_AutoShootMode",
	Values = { "Normal", "Behind Walls" },
	Value = Hub.AutoShootState.mode,
	Callback = function(mode)
		if mode == "Normal" or mode == "Behind Walls" then
			Hub.AutoShootState.mode = mode
		end
	end,
})

tbl2.Sheriff:Dropdown({
	Title = "Auto Shoot Part",
	Flag = "Sheriff_AutoShootPart",
	Values = { "UpperTorso", "HumanoidRootPart", "Head", "Torso" },
	Value = Hub.AutoShootState.part,
	Callback = function(part)
		if part == "UpperTorso" or part == "HumanoidRootPart" or part == "Head" or part == "Torso" then
			Hub.AutoShootState.part = part
		end
	end,
})

tbl2.Sheriff:Dropdown({
	Title = "Shoot Button Size",
	Flag = "Sheriff_ShootButtonSize",
	Values = { "Small", "Medium", "Large" },
	Value = Hub.AutoShootDragState.size,
	Callback = function(size)
		if Hub.TouchButtons.Sizes[size] then
			Hub.AutoShootDragState.size = size
			Hub.TouchButtons.ApplySize(Hub.AutoShootTouchButton, size, Hub.AutoShootDragState.shape)
		end
	end,
})

tbl2.Sheriff:Dropdown({
	Title = "Shoot Button Shape",
	Flag = "Sheriff_ShootButtonShape",
	Values = { "Square", "Rectangle" },
	Value = Hub.AutoShootDragState.shape,
	Callback = function(arg)
		Hub.AutoShootDragState.shape = arg == "Rectangle" and "Rectangle" or "Square"
		Hub.TouchButtons.ApplySize(Hub.AutoShootTouchButton, Hub.AutoShootDragState.size, Hub.AutoShootDragState.shape)
		Hub.TouchButtons.UpdateHoldHint(Hub.AutoShootDragState, Hub.AutoShootTouchButton)
	end,
})

tbl2.Sheriff:Colorpicker({
	Title = "Shoot Icon Color",
	Flag = "Sheriff_ShootButtonColor",
	Default = Hub.AutoShootDragState.outlineColor,
	Callback = function(outlineColor)
		Hub.AutoShootDragState.outlineColor = outlineColor
		Hub.TouchButtons.ApplyAppearance(Hub.AutoShootTouchButton, Hub.AutoShootDragState)
	end,
})

tbl2.Sheriff:Toggle({
	Title = "Shoot Button Draggable",
	Flag = "Sheriff_ShootButtonDraggable",
	Default = Hub.AutoShootDragState.draggable == true,
	Callback = function(arg)
		Hub.AutoShootDragState.draggable = arg and true or false
	end,
})

tbl2.Sheriff:Keybind({
	Title = "Auto Shoot Keybind",
	Flag = "Sheriff_AutoShootKeybind",
	Value = "X",
	Callback = function()
		if Hub.TriggerAutoShootInput then
			Hub.TriggerAutoShootInput()
		end
	end,
})

Tabs.Movement:Toggle({
	Title = "Invisibility",
	Flag = "General_Invisibility",
	Callback = function(arg)
		fn36(arg)
	end,
})

Tabs.Farm:Section({ Title = "Progression", TextXAlignment = "Center", TextSize = 17, Opened = true })

Hub.AutoPrestige.control = Tabs.Farm:Toggle({
	Title = "Auto Prestige",
	Flag = "Farm_AutoPrestige",
	Default = false,
	Callback = function(arg)
		Hub.AutoPrestige.SetEnabled(arg)
	end,
})

Hub.AutoClaimReward.control = Tabs.Farm:Toggle({
	Title = "Auto Claim Rewards",
	Desc = "Automatically claims random candy and item reward popups.",
	Flag = "Farm_AutoClaimRewards",
	Default = true,
	Callback = function(arg)
		Hub.AutoClaimReward.SetEnabled(arg)
	end,
})

Tabs.Farm:Section({ Title = "Coin Farm", TextXAlignment = "Center", TextSize = 17, Opened = true })

Hub.CoinFarm.statsControl = Tabs.Farm:Paragraph({
	Title = "Coin Farm Statistics",
	Desc = [[Status: Disabled
Total Collected Coins: 0
Total Earned XP: 0
Role: Unknown]],
	Icon = "coins",
})

Hub.CoinFarm.RefreshStats()

Hub.CoinFarm.toggleControl = Tabs.Farm:Toggle({
	Title = "Coin Farm",
	Desc = "Automatically server hops and re-executes the script if the user is kicked.",
	Flag = "Farm_CoinFarm",
	Default = false,
	Callback = function(arg)
		Hub.CoinFarm.SetEnabled(arg)
	end,
})

Hub.CoinFarm.webhookInput = Tabs.Farm:Input({
	Title = "Coin Farm Webhook",
	Desc = "Press Enter to save. Leave empty and press Enter to clear.",
	Type = "Input",
	Value = Hub.CoinFarm.webhookUrl,
	Placeholder = "https://discord.com/api/webhooks/...",
	ClearTextOnFocus = false,
	Callback = function(arg)
		Hub.CoinFarm.webhookDraft = tostring(arg or "")
	end,
})

task.defer(function()
	local webhookInput = Hub.CoinFarm.webhookInput
	local inputFrame = webhookInput and typeof(webhookInput) == "table" and webhookInput.InputFrame
	local uiElements = inputFrame and typeof(inputFrame) == "table" and inputFrame.UIElements
	local main

	if uiElements and typeof(uiElements) == "table" then
		main = uiElements.Main or uiElements.Container
	else
		main = uiElements
	end

	main = main and typeof(main) == "Instance" and main:FindFirstChildWhichIsA("TextBox", true)
	if not main then
		return
	end

	trackConn(main.FocusLost:Connect(function(enterPressed)
		if not enterPressed then
			return
		end
		local v9, v10 = Hub.CoinFarm.SaveWebhook(main.Text)
		WindUI:Notify({ Title = "Coin Farm Webhook", Content = v10, Icon = v9 and "check" or "x", Duration = 3 })
	end))
end)

Tabs.Farm:Button({
	Title = "Test Webhook",
	Icon = "send",
	Callback = function()
		if tostring(Hub.CoinFarm.webhookUrl or "") == "" then
			WindUI:Notify({ Title = "Coin Farm Webhook", Content = "Save a webhook URL first.", Icon = "x", Duration = 3 })
			return
		end
		local Test = Hub.CoinFarm.SendWebhook("Test")

		WindUI:Notify({
			Title = "Coin Farm Webhook",
			Content = Test and "Test webhook request sent." or "Test webhook could not be sent.",
			Icon = Test and "check" or "x",
			Duration = 3,
		})
	end,
})

task.wait(UI_BUILD_DELAY)

Hub.CoinFarm.blackScreenControl = Tabs.Farm:Toggle({
	Title = "Black Screen",
	Flag = "Farm_BlackScreen",
	Default = false,
	Callback = function(arg)
		Hub.CoinFarm.SetBlackScreen(arg, false)
	end,
})

Hub.CoinFarm.renderingControl = Tabs.Farm:Toggle({
	Title = "Disable 3D Rendering",
	Flag = "Farm_Disable3DRendering",
	Default = false,
	Callback = function(arg)
		if not Hub.CoinFarm.Set3DRenderingDisabled(arg, false) and arg and Hub.CoinFarm.renderingControl and type(Hub.CoinFarm.renderingControl.Set) == "function" then
			task.defer(function()
				pcall(function()
					Hub.CoinFarm.renderingControl:Set(false)
				end)
			end)
		end
	end,
})

Hub.CoinFarm.xpFarmControl = Tabs.Farm:Toggle({
	Title = "Farm XP While Coin Farming",
	Desc = "Keeps Innocent/Hero alive and lets Hero shoot at 10 seconds",
	LockedTitle = "Enable End Round When Coin Bag Is Full\nor Died before enabling Farm XP.",
	Flag = "Farm_CoinFarmXP",
	Default = false,
	Callback = function(arg)
		if arg and not Hub.CoinFarm.endRoundEnabled then
			Hub.CoinFarm.xpFarmEnabled = false

			if type(Hub.CoinFarm.UpdateXPFarmLock) == "function" then
				task.defer(Hub.CoinFarm.UpdateXPFarmLock)
			end

			return
		end

		Hub.CoinFarm.xpFarmEnabled = arg and true or false

		if not Hub.CoinFarm.xpFarmEnabled then
			Hub.CoinFarm.CancelXPFarmWait()

			if Hub.CoinFarm.enabled and Hub.CoinFarm.bagFull and Hub.CoinFarm.endRoundEnabled then
				Hub.CoinFarm.StartEndRoundAction()
			end
		elseif Hub.CoinFarm.enabled and Hub.CoinFarm.bagFull then
			Hub.CoinFarm.StartXPFarmWait()
		end
	end,
})

Hub.CoinFarm.endRoundControl = Tabs.Farm:Toggle({
	Title = "End Round When Coin Bag Is Full or Died",
	Flag = "Farm_EndRoundOnFullOrDied",
	Default = false,
	Callback = function(arg)
		Hub.CoinFarm.endRoundEnabled = arg and true or false

		if type(Hub.CoinFarm.UpdateXPFarmLock) == "function" then
			Hub.CoinFarm.UpdateXPFarmLock()
		end

		if not Hub.CoinFarm.endRoundEnabled then
			local coinFarm = Hub.CoinFarm
			coinFarm.endRoundGeneration = coinFarm.endRoundGeneration + 1
			Hub.CoinFarm.endRoundRunning = false
			Hub.CoinFarm.sheriffFlingRunning = false
			Hub.CoinFarm.sheriffFlingBlocking = false
			Hub.CoinFarm.sheriffFlingCompleted = false
		elseif Hub.RoundState.active then
			if Hub.CoinFarm.bagFull then
				if not (Hub.CoinFarm.xpFarmEnabled and Hub.CoinFarm.StartXPFarmWait()) then
					Hub.CoinFarm.StartEndRoundAction()
				end

				return
			end

			local coinFarm = Hub.CoinFarm
			coinFarm.endRoundGeneration = coinFarm.endRoundGeneration + 1
			Hub.CoinFarm.endRoundRunning = false
			Hub.CoinFarm.sheriffFlingRunning = false
			Hub.CoinFarm.sheriffFlingBlocking = false
			Hub.CoinFarm.sheriffFlingCompleted = false
			Hub.CoinFarm.StartRoundSheriffFling()
		end
	end,
})

Hub.CoinFarm.serverHopControl = Tabs.Farm:Toggle({
	Title = "Server Hop If Low Players",
	Flag = "Farm_ServerHopLowPlayers",
	Default = false,
	Callback = function(arg)
		Hub.CoinFarm.serverHopLowPlayers = arg and true or false
	end,
})

Hub.CoinFarm.serverHopThresholdControl = Tabs.Farm:Slider({
	Title = "Server Hop Player Threshold",
	Flag = "Farm_ServerHopPlayerThreshold",
	Value = { Min = 1, Max = 6, Default = Hub.CoinFarm.serverHopPlayerThreshold },
	Step = 1,
	Callback = function(arg)
		Hub.CoinFarm.serverHopPlayerThreshold = math.clamp(math.floor(tonumber(arg) or 4), 1, 6)
	end,
})

Hub.CoinFarm.serverHopTimerControl = Tabs.Farm:Slider({
	Title = "Server Hop Timer",
	Flag = "Farm_ServerHopTimerMinutes",
	Value = { Min = 10, Max = 30, Default = Hub.CoinFarm.serverHopTimerMinutes },
	Step = 1,
	Callback = function(arg)
		Hub.CoinFarm.serverHopTimerMinutes = math.clamp(math.floor(tonumber(arg) or 15), 10, 30)
		Hub.CoinFarm.serverHopTimerStartedAt = Hub.CoinFarm.enabled and os.clock() or 0
	end,
})

Hub.CoinFarm.antiBotControl = Tabs.Farm:Toggle({
	Title = "Anti Bot Server Hop",
	Desc = "Server hops if suspicious bot server detected",
	Flag = "Farm_AntiBotServerHop",
	Default = false,
	Callback = function(arg)
		Hub.CoinFarm.antiBotEnabled = arg and true or false

		if Hub.CoinFarm.antiBotEnabled and type(Hub.CoinFarm.StartAntiBotServerHop) == "function" then
			task.defer(Hub.CoinFarm.StartAntiBotServerHop)
		end
	end,
})

Hub.CoinFarm.UpdateXPFarmLock = function()
	local xpFarmControl = Hub.CoinFarm.xpFarmControl
	if not xpFarmControl then
		return
	end

	if Hub.CoinFarm.endRoundEnabled then
		pcall(function()
			xpFarmControl:Unlock()
		end)

		return
	end

	Hub.CoinFarm.xpFarmEnabled = false
	Hub.CoinFarm.CancelXPFarmWait()

	pcall(function()
		xpFarmControl:Unlock()
		xpFarmControl:Set(false, false, true)
		xpFarmControl:Lock()
	end)
end

Hub.CoinFarm.UpdateXPFarmLock()

Hub.CoinFarm.speedControl = Tabs.Farm:Slider({
	Title = "Coin Farm Speed",
	Desc = "Movement & Tween speed for collecting coins",
	Flag = "Farm_CoinFarmSpeed",
	Value = { Min = 10, Max = 60, Default = Hub.CoinFarm.speed or 28 },
	Step = 1,
	Suffix = "studs/s",
	Callback = function(arg)
		Hub.CoinFarm.speed = tonumber(arg) or 28
	end,
})

Hub.CoinFarm.modeControl = Tabs.Farm:Dropdown({
	Title = "Coin Farm Mode",
	Flag = "Farm_CoinFarmMode",
	Values = { "CFrame", "Tween" },
	Value = Hub.CoinFarm.mode,
	Callback = function(mode)
		if mode ~= "CFrame" and mode ~= "Tween" then
			return
		end
		Hub.CoinFarm.mode = mode
		Hub.CoinFarm.currentCoin = nil
		Hub.CoinFarm.CancelTween()

		if mode ~= "Tween" and Hub.CoinFarm.position ~= "Under" then
			Hub.CoinFarm.DisableUnder()
		end
	end,
})

Hub.CoinFarm.positionControl = Tabs.Farm:Dropdown({
	Title = "Coin Farm Position",
	Flag = "Farm_CoinFarmPosition",
	Values = { "Normal", "Under" },
	Value = Hub.CoinFarm.position,
	Callback = function(position)
		if position ~= "Normal" and position ~= "Under" then
			return
		end
		Hub.CoinFarm.position = position
		Hub.CoinFarm.currentCoin = nil
		Hub.CoinFarm.CancelTween()

		if position ~= "Under" then
			Hub.CoinFarm.DisableUnder()
		end
	end,
})

do
	local eventBox = {
		selectedBox = nil,
		selectedCurrency = nil,
		autoBuy = false,
		busy = false,
		generation = 0,
		boxes = {},
		shopData = nil,
		profileData = nil,
		boxDropdown = nil,
		currencyDropdown = nil,
	}

	Hub.EventBox = eventBox

	local function fn38()
		if not eventBox.shopData then
			local database = ReplicatedStorage:FindFirstChild("Database")
			database = database and database:FindFirstChild("Sync")

			if database then
				local ok, result = pcall(require, database)

				if ok and type(result) == "table" then
					eventBox.shopData = result.NewShop
				end
			end
		end

		return eventBox.shopData
	end

	local function fn39()
		if not eventBox.profileData then
			local modules = ReplicatedStorage:FindFirstChild("Modules")
			modules = modules and modules:FindFirstChild("ProfileData")

			if modules then
				local ok, profileData = pcall(require, modules)

				if ok and type(profileData) == "table" then
					eventBox.profileData = profileData
				end
			end
		end

		return eventBox.profileData
	end

	local function fn40(arg)
		local v9 = pairs
		local tbl7 = arg or {}

		for k in v9(tbl7) do
			if k ~= "Coins" and k ~= "Gems" and k ~= "Key" and k ~= "Robux" then
				return true
			end
		end

		return false
	end

	local function fn41()
		local tbl7 = fn38()
		local tbl8 = {}
		eventBox.boxes = {}
		local v9 = pairs
		tbl7 = type(tbl7) == "table" and tbl7 or {}

		for k, v10 in v9(tbl7) do
			if type(v10) == "table" and v10.Type == "MysteryBox" and v10.Hidden ~= true and type(v10.Price) == "table" then
				eventBox.boxes[k] = v10
				table.insert(tbl8, k)
			end
		end

		table.sort(tbl8, function(arg, arg2)
			local v10 = fn40(eventBox.boxes[arg].Price)
			if v10 ~= fn40(eventBox.boxes[arg2].Price) then
				return v10
			end
			return string.lower(arg) < string.lower(arg2)
		end)

		return tbl8
	end

	local function fn42(arg)
		local price = eventBox.boxes[arg]
		local tbl7 = {}
		local v9 = pairs
		price = price and price.Price or {}

		for k in v9(price) do
			if k ~= "Robux" then
				table.insert(tbl7, k)
			end
		end

		table.sort(tbl7, function(arg2, arg3)
			local flag7 = arg2 ~= "Coins" and arg2 ~= "Gems" and arg2 ~= "Key"
			if flag7 ~= (arg3 ~= "Coins" and arg3 ~= "Gems" and arg3 ~= "Key") then
				return flag7
			end
			local tbl8 = { Coins = 1, Gems = 2, Key = 3 }
			return (tbl8[arg2] or 10) < (tbl8[arg3] or 10)
		end)

		return tbl7
	end

	local function fn43(arg)
		local v9 = fn39()
		local owned = v9 and v9.Materials and v9.Materials.Owned
		local owned2 = v9 and v9.Weapons and v9.Weapons.Owned
		local num = tonumber(owned and owned[arg])
		local num2

		if num then
			num2 = num
		else
			num2 = tonumber(owned2 and owned2[arg])
		end

		return num2 or 0
	end

	local function fn44(arg, arg2)
		local tbl7 = fn42(arg)

		if #tbl7 == 0 then
			tbl7 = { "Unavailable" }
		end

		local v9 = table.find(tbl7, arg2) and arg2 or tbl7[1]
		eventBox.selectedCurrency = v9 ~= "Unavailable" and v9 or nil
		local currencyDropdown = eventBox.currencyDropdown

		if currencyDropdown then
			local flag7 = false

			if currencyDropdown.SetValues then
				flag7 = pcall(function()
					currencyDropdown:SetValues(tbl7)
				end)
			end

			if not flag7 and currencyDropdown.Refresh then
				pcall(function()
					currencyDropdown:Refresh(tbl7)
				end)
			end

			pcall(function()
				currencyDropdown:Select(v9)
			end)
		end
	end

	local function fn45(arg)
		if eventBox.busy then
			return false
		end
		local selectedBox = eventBox.selectedBox
		local selectedCurrency = eventBox.selectedCurrency
		local v9 = selectedBox and eventBox.boxes[selectedBox]
		local price = v9 and v9.Price and v9.Price[selectedCurrency]

		if not selectedBox or not selectedCurrency or type(price) ~= "number" then
			if not arg then
				WindUI:Notify({
					Title = "Box Purchase",
					Content = "Select a valid box and currency",
					Icon = "x",
					Duration = 2.5,
				})
			end

			return false
		end

		local v10 = fn43(selectedCurrency)

		if v10 < price then
			if not arg then
				WindUI:Notify({
					Title = "Box Purchase",
					Content = string.format("Not enough %s (%d/%d)", selectedCurrency, v10, price),
					Icon = "x",
					Duration = 2.5,
				})
			end

			return false
		end

		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		remotes = remotes and remotes:FindFirstChild("Shop")
		local openCrate = remotes and remotes:FindFirstChild("OpenCrate")

		if not openCrate or not openCrate:IsA("RemoteFunction") then
			if not arg then
				WindUI:Notify({
					Title = "Box Purchase",
					Content = "OpenCrate remote is unavailable",
					Icon = "x",
					Duration = 2.5,
				})
			end

			return false
		end

		eventBox.busy = true

		local ok, result = pcall(function()
			return openCrate:InvokeServer(selectedBox, "MysteryBox", selectedCurrency)
		end)

		ok = ok and result ~= nil and result ~= false
		local flag7 = false

		if ok then
			local boxController = remotes:FindFirstChild("BoxController")

			if boxController and boxController:IsA("BindableEvent") then
				flag7 = pcall(function()
					boxController:Fire({ { MysteryBoxId = selectedBox, RewardedItemId = result } })
				end)
			end
		end

		if flag7 then
			task.delay(4.6, function()
				eventBox.busy = false
			end)
		else
			eventBox.busy = false
		end

		if not arg and (not ok or not flag7) then
			WindUI:Notify({
				Title = ok and "Box Opened" or "Box Purchase Failed",
				Content = ok and "Received: " .. tostring(result) or "The server rejected the purchase",
				Icon = ok and "gift" or "x",
				Duration = 3,
			})
		end

		return ok
	end

	local tbl7 = fn41()

	if #tbl7 == 0 then
		tbl7 = { "Unavailable" }
	end

	eventBox.selectedBox = tbl7[1] ~= "Unavailable" and tbl7[1] or nil
	local selectedBox = eventBox.selectedBox and fn42(eventBox.selectedBox) or {}

	if #selectedBox == 0 then
		selectedBox = { "Unavailable" }
	end

	eventBox.selectedCurrency = selectedBox[1] ~= "Unavailable" and selectedBox[1] or nil
	task.wait(UI_BUILD_DELAY)

	Tabs.Farm:Section({ Title = "Event Boxes", TextXAlignment = "Center", TextSize = 17, Opened = true })

	eventBox.boxDropdown = Tabs.Farm:Dropdown({
		Title = "Box",
		Flag = "Farm_EventBox",
		Values = tbl7,
		Value = tbl7[1],
		Callback = function(selectedBox2)
			if selectedBox2 == "Unavailable" or not eventBox.boxes[selectedBox2] then
				return
			end
			eventBox.selectedBox = selectedBox2
			fn44(selectedBox2, eventBox.selectedCurrency)
		end,
	})

	eventBox.currencyDropdown = Tabs.Farm:Dropdown({
		Title = "Box Currency",
		Flag = "Farm_EventBoxCurrency",
		Values = selectedBox,
		Value = selectedBox[1],
		Callback = function(selectedCurrency)
			if selectedCurrency ~= "Unavailable" then
				eventBox.selectedCurrency = selectedCurrency
			end
		end,
	})

	Tabs.Farm:Button({
		Title = "Buy Box",
		Callback = function()
			task.spawn(fn45, false)
		end,
	})

	eventBox.autoBuyControl = Tabs.Farm:Toggle({
		Title = "Auto Buy Boxes",
		Flag = "Farm_AutoBuyBoxes",
		Default = false,
		Callback = function(arg)
			eventBox.autoBuy = arg and true or false
			eventBox.generation = eventBox.generation + 1
			if not eventBox.autoBuy then
				return
			end
			local generation = eventBox.generation

			task.spawn(function()
				while foxnameMM2Runtime.alive and not isTerminated and eventBox.autoBuy and eventBox.generation == generation do
					task.wait(fn45(true) and 4.75 or 1.75)
				end
			end)
		end,
	})

	Hub.CleanupEventBox = function()
		eventBox.autoBuy = false
		eventBox.generation = eventBox.generation + 1
		eventBox.busy = false
	end
end

local function fn38(arg)
	Hub.PlayerFOV = math.clamp(tonumber(arg) or Hub.PlayerFOV or 70, 40, 120)
	local currentCamera2 = workspace.CurrentCamera

	if currentCamera2 then
		currentCamera2.FieldOfView = Hub.PlayerFOV
	end
end

task.wait(UI_BUILD_DELAY)

Tabs.LocalPlayer:Slider({
	Title = "Field of View",
	Flag = "LocalPlayer_FieldOfView",
	Value = { Min = 40, Max = 120, Default = Hub.PlayerFOV },
	Step = 1,
	Callback = fn38,
})

Tabs.LocalPlayer:Slider({
	Title = "WalkSpeed",
	Flag = "LocalPlayer_WalkSpeed",
	Value = { Min = 16, Max = 500, Default = Hub.WalkSpeed },
	Step = 1,
	Callback = function(walkSpeed)
		Hub.WalkSpeed = walkSpeed

		if localChar.humanoid then
			localChar.humanoid.WalkSpeed = Hub.WalkSpeed
		end
	end,
})

Tabs.LocalPlayer:Toggle({
	Title = "Speed Glitch (Jumping)",
	Flag = "LocalPlayer_SpeedGlitch",
	Default = false,
	Callback = function(speedGlitchEnabled)
		Hub.SpeedGlitchEnabled = speedGlitchEnabled
	end,
})

Tabs.LocalPlayer:Slider({
	Title = "Speed Glitch Power",
	Flag = "LocalPlayer_SpeedGlitchPower",
	Value = { Min = 1, Max = 5, Default = Hub.SpeedGlitchPower },
	Step = 1,
	Callback = function(speedGlitchPower)
		Hub.SpeedGlitchPower = speedGlitchPower
	end,
})

trackConn(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	currentCamera = workspace.CurrentCamera or currentCamera
	task.defer(fn38, Hub.PlayerFOV)
end))

Hub.TouchButtons.NoclipToggleControl = Tabs.LocalPlayer:Toggle({
	Title = "Noclip",
	Flag = "LocalPlayer_Noclip",
	Callback = function(arg)
		Hub.TouchButtons.SetNoclipEnabled(arg, false)
	end,
})

Tabs.LocalPlayer:Keybind({
	Title = "Noclip Keybind",
	Flag = "LocalPlayer_NoclipKeybind",
	Value = "N",
	Callback = function()
		Hub.TouchButtons.SetNoclipEnabled(not Hub.NoclipEnabled, true)
	end,
})

Tabs.LocalPlayer:Toggle({
	Title = "Noclip Button",
	Flag = "LocalPlayer_NoclipButton",
	Default = false,
	Callback = function(arg)
		Hub.TouchButtons.ToggleNoclipButton(arg)
	end,
})

Tabs.LocalPlayer:Dropdown({
	Title = "Noclip Button Size",
	Flag = "LocalPlayer_NoclipButtonSize",
	Values = { "Small", "Medium", "Large" },
	Value = Hub.NoclipButtonState.size,
	Callback = function(size)
		if Hub.TouchButtons.Sizes[size] then
			Hub.NoclipButtonState.size = size
			Hub.TouchButtons.ApplySize(Hub.NoclipButtonState.button, size, Hub.NoclipButtonState.shape)
		end
	end,
})

Tabs.LocalPlayer:Dropdown({
	Title = "Noclip Button Shape",
	Flag = "LocalPlayer_NoclipButtonShape",
	Values = { "Square", "Rectangle" },
	Value = Hub.NoclipButtonState.shape,
	Callback = function(arg)
		Hub.NoclipButtonState.shape = arg == "Rectangle" and "Rectangle" or "Square"
		Hub.TouchButtons.ApplySize(Hub.NoclipButtonState.button, Hub.NoclipButtonState.size, Hub.NoclipButtonState.shape)
	end,
})

Tabs.LocalPlayer:Colorpicker({
	Title = "Noclip Icon Color",
	Flag = "LocalPlayer_NoclipButtonColor",
	Default = Hub.NoclipButtonState.outlineColor or Hub.TouchButtons.Theme.accentColor,
	Callback = function(outlineColor)
		Hub.NoclipButtonState.outlineColor = outlineColor
		Hub.TouchButtons.ApplyAppearance(Hub.NoclipButtonState.button, Hub.NoclipButtonState)
	end,
})

Tabs.LocalPlayer:Toggle({
	Title = "Noclip Button Draggable",
	Flag = "LocalPlayer_NoclipButtonDraggable",
	Default = Hub.NoclipButtonState.draggable,
	Callback = function(arg)
		Hub.NoclipButtonState.draggable = arg and true or false
	end,
})

Hub.AntiFlingToggleControl = Tabs.Player:Toggle({
	Title = "Anti Fling",
	Flag = "General_AntiFling",
	Default = false,
	LockedTitle = "Automatically enabled and locked\nwhile Coin Farm is active.",
	Callback = function(arg)
		Hub.SetAntiFlingSource("manual", arg)
	end,
})

Hub.AntiFlingBeforeCoinFarm = false
Hub.AntiFlingForcedByCoinFarm = false

Hub.SetCoinFarmAntiFling = function(arg)
	if arg then
		if not Hub.AntiFlingForcedByCoinFarm then
			Hub.AntiFlingBeforeCoinFarm = Hub.AntiFlingSources.manual == true
		end

		Hub.AntiFlingForcedByCoinFarm = true
		Hub.SetAntiFlingSource("manual", true)
		Hub.AntiFlingToggleControl:Unlock()
		Hub.AntiFlingToggleControl:Set(true, false, true)
		Hub.AntiFlingToggleControl:Lock()
	else
		Hub.AntiFlingToggleControl:Unlock()

		if Hub.AntiFlingForcedByCoinFarm then
			Hub.AntiFlingForcedByCoinFarm = false
			Hub.SetAntiFlingSource("manual", Hub.AntiFlingBeforeCoinFarm)
			Hub.AntiFlingToggleControl:Set(Hub.AntiFlingBeforeCoinFarm, false, true)
		end
	end
end

Hub.TouchButtons.FlyToggleControl = Tabs.LocalPlayer:Toggle({
	Title = "Fly",
	Flag = "LocalPlayer_Fly",
	Callback = function(arg)
		Hub.TouchButtons.SetFlyEnabled(arg, false)
	end,
})

Tabs.LocalPlayer:Keybind({
	Title = "Fly Keybind",
	Flag = "LocalPlayer_FlyKeybind",
	Value = "F",
	Callback = function()
		Hub.TouchButtons.SetFlyEnabled(not Hub.FlyEnabled, true)
	end,
})

Tabs.LocalPlayer:Toggle({
	Title = "Fly Button",
	Flag = "LocalPlayer_FlyButton",
	Default = false,
	Callback = function(arg)
		Hub.TouchButtons.ToggleFlyButton(arg)
	end,
})

Tabs.LocalPlayer:Dropdown({
	Title = "Fly Button Size",
	Flag = "LocalPlayer_FlyButtonSize",
	Values = { "Small", "Medium", "Large" },
	Value = Hub.FlyButtonState.size,
	Callback = function(size)
		if Hub.TouchButtons.Sizes[size] then
			Hub.FlyButtonState.size = size
			Hub.TouchButtons.ApplySize(Hub.FlyButtonState.button, size, Hub.FlyButtonState.shape)
		end
	end,
})

Tabs.LocalPlayer:Dropdown({
	Title = "Fly Button Shape",
	Flag = "LocalPlayer_FlyButtonShape",
	Values = { "Square", "Rectangle" },
	Value = Hub.FlyButtonState.shape,
	Callback = function(arg)
		Hub.FlyButtonState.shape = arg == "Rectangle" and "Rectangle" or "Square"
		Hub.TouchButtons.ApplySize(Hub.FlyButtonState.button, Hub.FlyButtonState.size, Hub.FlyButtonState.shape)
	end,
})

Tabs.LocalPlayer:Colorpicker({
	Title = "Fly Icon Color",
	Flag = "LocalPlayer_FlyButtonColor",
	Default = Hub.FlyButtonState.outlineColor or Hub.TouchButtons.Theme.accentColor,
	Callback = function(outlineColor)
		Hub.FlyButtonState.outlineColor = outlineColor
		Hub.TouchButtons.ApplyAppearance(Hub.FlyButtonState.button, Hub.FlyButtonState)
	end,
})

Tabs.LocalPlayer:Toggle({
	Title = "Fly Button Draggable",
	Flag = "LocalPlayer_FlyButtonDraggable",
	Default = Hub.FlyButtonState.draggable,
	Callback = function(arg)
		Hub.FlyButtonState.draggable = arg and true or false
	end,
})

Tabs.LocalPlayer:Slider({
	Title = "Fly Speed",
	Flag = "LocalPlayer_FlySpeed",
	Value = { Min = 50, Max = 100, Default = Hub.FlySpeed },
	Step = 1,
	Callback = function(flySpeed)
		Hub.FlySpeed = flySpeed
	end,
})

Tabs.LocalPlayer:Toggle({
	Title = "Infinite Jump",
	Flag = "LocalPlayer_InfiniteJump",
	Default = false,
	Callback = function(arg)
		Hub.ToggleInfiniteJump(arg)
	end,
})

Tabs.LocalPlayer:Slider({
	Title = "Jump Power",
	Flag = "LocalPlayer_JumpPower",
	Value = { Min = 1, Max = 5, Default = Hub.JumpPower / 50 },
	Step = 1,
	Callback = function(arg)
		Hub.JumpPower = arg * 50

		if localChar.humanoid then
			localChar.humanoid.JumpPower = Hub.JumpPower
		end
	end,
})

do
	local tbl7 = { generation = 0, active = false, tool = nil, track = nil, connections = {} }

	local function fn39()
		tbl7.active = false

		if tbl7.track then
			pcall(function()
				tbl7.track:Stop()
			end)

			tbl7.track = nil
		end
	end

	local function cleanupJerk()
		tbl7.generation = tbl7.generation + 1
		fn39()

		for _, connection in ipairs(tbl7.connections) do
			if connection and connection.Connected then
				connection:Disconnect()
			end
		end

		table.clear(tbl7.connections)

		if tbl7.tool then
			pcall(function()
				tbl7.tool:Destroy()
			end)

			tbl7.tool = nil
		end
	end

	Tabs.LocalPlayer:Button({
		Title = "Jerk",
		Callback = function()
			cleanupJerk()
			local character_ = localPlayer.Character
			local humanoid = character_ and character_:FindFirstChildWhichIsA("Humanoid")
			local backpack = localPlayer:FindFirstChildWhichIsA("Backpack")
			if not humanoid or not backpack then
				WindUI:Notify({ Title = "Jerk", Content = "Character is not ready", Icon = "x", Duration = 2 })
				return
			end
			local tool = Instance.new("Tool")
			tool.Name = "Jerk Off"
			tool.ToolTip = "Equip the tool to play the animation."
			tool.RequiresHandle = false
			tool.Parent = backpack
			tbl7.tool = tool
			local generation = tbl7.generation

			table.insert(tbl7.connections, tool.Equipped:Connect(function()
				tbl7.active = true
			end))

			table.insert(tbl7.connections, tool.Unequipped:Connect(fn39))
			table.insert(tbl7.connections, humanoid.Died:Connect(fn39))

			task.spawn(function()
				while true do
					if foxnameMM2Runtime.alive and not isTerminated and tbl7.generation == generation and tool.Parent then
						if not tbl7.active then
							task.wait(0.1)
							continue
						else
							local flag7 = humanoid.RigType == Enum.HumanoidRigType.R15
							local track, v9, adjustSpeed, n2, flag8

							if not tbl7.track then
								local animation = Instance.new("Animation")
								animation.AnimationId = flag7 and "rbxassetid://698251653" or "rbxassetid://72042024"
								local ok, track2 = pcall(humanoid.LoadAnimation, humanoid, animation)
								animation:Destroy()

								if not (not ok or not track2) then
									tbl7.track = track2
									track = tbl7.track
									track:Play()
									v9 = track
									adjustSpeed = v9.AdjustSpeed
									n2 = flag7 and 0.7 or 0.65
									adjustSpeed(v9, n2)
									track.TimePosition = 0.6
									task.wait(0.1)
									flag7 = flag7 and 0.7 or 0.65

									while true do
										flag8 = tbl7.active and tbl7.track == track and track.TimePosition < flag7
										if flag8 then
											task.wait(0.1)
											continue
										end
										break
									end

									if tbl7.track == track then
										track:Stop()
										tbl7.track = nil
									end

									continue
								end
							else
								track = tbl7.track
								track:Play()
								v9 = track
								adjustSpeed = v9.AdjustSpeed
								n2 = flag7 and 0.7 or 0.65
								adjustSpeed(v9, n2)
								track.TimePosition = 0.6
								task.wait(0.1)
								flag7 = flag7 and 0.7 or 0.65

								while true do
									flag8 = tbl7.active and tbl7.track == track and track.TimePosition < flag7
									if flag8 then
										task.wait(0.1)
										continue
									end
									break
								end

								if tbl7.track == track then
									track:Stop()
									tbl7.track = nil
								end

								continue
							end
						end
					end

					break
				end

				fn39()
			end)
		end,
	})

	Hub.CleanupJerk = cleanupJerk
end

Hub.ESPRenderCache = {
	nametagInterval = 0.4,
	roleInterval = UserInputService.TouchEnabled and 0.75 or 0.6,
	lineInterval = UserInputService.TouchEnabled and 0.041666666666666664 or 0.033333333333333333,
	passiveInterval = UserInputService.TouchEnabled and 0.083333333333333329 or 0.066666666666666666,
	lastFrameUpdate = 0,
	lastRoleUpdate = 0,
	wasActive = false,
	murderer = nil,
	sheriff = nil,
}

trackConn(RunService.RenderStepped:Connect(function()
	local playerESP = Hub.PlayerESP or Hub.LineESP or Hub.NametagESP or Hub.ESP360
	local gunESP = Hub.GunESP or Hub.ESP360
	local flag7 = not playerESP

	if flag7 and not gunESP then
		if Hub.ESPRenderCache.wasActive then
			Hub.ESPRenderCache.wasActive = false

			for _, v9 in pairs(Hub.ESPTable) do
				if v9.Highlight then
					v9.Highlight.Enabled = false
				end

				if v9.Billboard then
					v9.Billboard.Enabled = false
				end

				if v9.Line then
					v9.Line.Visible = false
				end

				fn13(v9.Arrow, v9.ArrowDistance)
			end

			for _, v9 in pairs(Hub.GunESPTable) do
				if v9.Line then
					v9.Line.Visible = false
				end

				if v9.Billboard then
					v9.Billboard.Enabled = false
				end

				fn13(v9.Arrow, v9.ArrowDistance)
			end
		end

		return
	end

	Hub.ESPRenderCache.wasActive = true
	local now = os.clock()
	if now - Hub.ESPRenderCache.lastFrameUpdate < ((Hub.LineESP or Hub.GunESP) and Hub.ESPRenderCache.lineInterval or Hub.ESP360 and Hub.ESPRenderCache.lineInterval or Hub.ESPRenderCache.passiveInterval) then
		return
	end
	Hub.ESPRenderCache.lastFrameUpdate = now
	local currentCamera2 = workspace.CurrentCamera
	if not currentCamera2 then
		return
	end
	currentCamera = currentCamera2
	local viewportSize = currentCamera2.ViewportSize
	local character_ = localPlayer.Character
	character_ = character_ and character_:FindFirstChild("HumanoidRootPart")

	if playerESP then
		if Hub.ESPRenderCache.roleInterval <= now - Hub.ESPRenderCache.lastRoleUpdate then
			Hub.ESPRenderCache.lastRoleUpdate = now
			Hub.ESPRenderCache.murderer = fn30()
			Hub.ESPRenderCache.sheriff = fn31()
		end
	end

	if flag7 then
		for _, v9 in pairs(Hub.ESPTable) do
			if v9.Highlight then
				v9.Highlight.Enabled = false
			end

			if v9.Billboard then
				v9.Billboard.Enabled = false
			end

			if v9.Line then
				v9.Line.Visible = false
			end
		end
	else
		for k, v9 in pairs(Hub.ESPTable) do
			local head = v9.Head
			local hrp = v9.HRP
			local v10 = fn6(k)
			local v11 = fn9(k)
			local v12 = v10 or v11

			if not head or not hrp or not hrp.Parent then
				v9.Highlight.Enabled = false
				v9.Billboard.Enabled = false
				v9.Line.Visible = false
				fn13(v9.Arrow, v9.ArrowDistance)
			elseif fn25(k) and not v12 then
				v9.Highlight.Enabled = false
				v9.Billboard.Enabled = false
				v9.Line.Visible = false
				fn13(v9.Arrow, v9.ArrowDistance)
			else
				local lastRole

				if k == Hub.ESPRenderCache.murderer then
					lastRole = "Murderer"
				else
					lastRole = "Innocent"

					if k == Hub.ESPRenderCache.sheriff then
						lastRole = "Sheriff"
					end
				end

				local color = v10 and Hub.GetOwnerESPGradientColor(now) or v11 and Color3.fromRGB(180, 85, 255) or Hub.ESPColors[lastRole]

				if Hub.ESP360 and (lastRole == "Murderer" or lastRole == "Sheriff") then
					fn14(v9.Arrow, v9.ArrowDistance, hrp.Position, Hub.ESPColors[lastRole], viewportSize, character_)
				else
					fn13(v9.Arrow, v9.ArrowDistance)
				end

				if Hub.PlayerESP then
					if v9.Highlight.Adornee ~= character then
						v9.Highlight.Adornee = character
					end

					v9.Highlight.Enabled = true

					if v12 or v9._lastRole ~= lastRole or v9._lastStyle ~= Hub.PlayerESPStyle then
						v9.Highlight.FillColor = color
						v9.Highlight.OutlineColor = color
						v9.Highlight.FillTransparency = Hub.PlayerESPStyle == "Outline" and 1 or 0.3
						v9.Highlight.OutlineTransparency = 0
						v9._lastRole = lastRole
						v9._lastStyle = Hub.PlayerESPStyle
					end
				else
					v9.Highlight.Enabled = false
				end

				v9.Billboard.Enabled = Hub.NametagESP

				if Hub.NametagESP then
					if v9.OwnerGradient then
						v9.OwnerGradient.Enabled = v10

						if v10 then
							v9.OwnerGradient.Rotation = 90
							v9.OwnerGradient.Offset = Vector2.new(0, math.sin(now * 0.7) * 0.28)
							v9.Text.TextColor3 = Color3.new(1, 1, 1)
						elseif v12 then
							v9.Text.TextColor3 = color
						end
					elseif v12 then
						v9.Text.TextColor3 = color
					end

					if Hub.ESPRenderCache.nametagInterval <= now - (v9._lastNametagUpdate or 0) then
						v9._lastNametagUpdate = now
						local str = ""

						if character_ then
							str = " | " .. tostring(math.floor((hrp.Position - character_.Position).Magnitude + 0.5)) .. " studs"
						end

						v9.Text.TextSize = v12 and 15 or 14
						v9.Text.Text = v10 and k.Name .. " [Owner | " .. lastRole .. "]" .. str or v11 and k.Name .. " [Same Script | " .. lastRole .. "]" .. str or k.Name .. " [" .. lastRole .. "]" .. str
						v9.Text.TextColor3 = v10 and Color3.new(1, 1, 1) or color
					end
				end

				if Hub.LineESP then
					if Hub.ESPRenderCache.lineInterval <= now - (v9._lastLineUpdate or 0) then
						v9._lastLineUpdate = now
						local v13, v14 = currentCamera2:WorldToViewportPoint(head.Position)

						if v14 and v13.Z > 0 then
							local vector2 = Vector2.new
							local clamp = math.clamp
							local y = v13.Y
							local y2 = viewportSize.Y
							fn16(v9.Line, Vector2.new(viewportSize.X * 0.5, 0), vector2(math.clamp(v13.X, 0, viewportSize.X), clamp(y, 0, y2)), color)
						else
							v9.Line.Visible = false
						end
					end
				else
					v9.Line.Visible = false
				end
			end
		end
	end

	if not gunESP then
		for _, v9 in pairs(Hub.GunESPTable) do
			if v9.Line then
				v9.Line.Visible = false
			end

			if v9.Billboard then
				v9.Billboard.Enabled = false
			end

			fn13(v9.Arrow, v9.ArrowDistance)
		end
	else
		for k, v9 in pairs(Hub.GunESPTable) do
			v9.Billboard.Enabled = Hub.GunESP
			v9.Line.Visible = Hub.GunESP

			if Hub.ESP360 then
				fn14(v9.Arrow, v9.ArrowDistance, k.Position, Hub.ESPColors.Gun, viewportSize, character_)
			else
				fn13(v9.Arrow, v9.ArrowDistance)
			end

			if Hub.GunESP then
				local v10, v11 = currentCamera2:WorldToViewportPoint(k.Position)

				if v11 and v10.Z > 0 then
					local gun = Hub.ESPColors.Gun
					v9.TextLabel.TextColor3 = gun
					local vector2 = Vector2.new
					local clamp = math.clamp
					local y = v10.Y
					local y2 = viewportSize.Y
					fn16(v9.Line, Vector2.new(viewportSize.X * 0.5, 0), vector2(math.clamp(v10.X, 0, viewportSize.X), clamp(y, 0, y2)), gun)
					v9.Billboard.StudsOffset = Vector3.new(0, 3, 0)
				else
					v9.Line.Visible = false
				end
			end
		end
	end
end))

do
	local function fn39(arg)
		local humanoid = arg:WaitForChild("Humanoid")
		humanoid.WalkSpeed = Hub.WalkSpeed
		humanoid.JumpPower = Hub.JumpPower
	end

	local function fn40(arg)
		if not arg then
			return
		end
		return arg:FindFirstChild("HumanoidRootPart") or arg:FindFirstChild("Torso") or arg:FindFirstChild("UpperTorso")
	end

	local function fn41(arg)
		for k, v9 in pairs(arg) do
			if v9 and typeof(v9.Disconnect) == "function" then
				pcall(function()
					v9:Disconnect()
				end)
			end

			arg[k] = nil
		end
	end

	local tbl7 = {
		flying = false,
		conns = {},
		objects = {},
		gamepadAxis = Vector2.new(0, 0),
		control = { F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0 },
	}

	Hub.StopFly = function()
		if not tbl7.flying then
			return
		end
		tbl7.flying = false
		fn41(tbl7.conns)

		pcall(function()
			if tbl7.objects.bv then
				tbl7.objects.bv:Destroy()
			end

			if tbl7.objects.bg then
				tbl7.objects.bg:Destroy()
			end
		end)

		tbl7.objects = {}
		tbl7.gamepadAxis = Vector2.new(0, 0)
		tbl7.control = { F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0 }
		local character_ = localPlayer.Character
		character_ = character_ and character_:FindFirstChildOfClass("Humanoid")

		if character_ then
			character_.PlatformStand = false
		end
	end

	Hub.StartFly = function()
		if tbl7.flying then
			return
		end
		local character_ = localPlayer.Character or localPlayer.CharacterAdded:Wait()
		local v9 = fn40(character_)
		if not v9 then
			return
		end
		tbl7.flying = true
		tbl7.control = { F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0 }
		local humanoid = character_:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid.PlatformStand = true
		end

		local bodyGyro = Instance.new("BodyGyro")
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyGyro.Name = "FlyBodyGyro"
		bodyGyro.P = 90000
		bodyGyro.D = 1000
		bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		bodyGyro.CFrame = v9.CFrame
		bodyGyro.Parent = v9
		bodyVelocity.Name = "FlyBodyVelocity"
		bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		bodyVelocity.Velocity = Vector3.zero
		bodyVelocity.Parent = v9
		tbl7.objects.bg = bodyGyro
		tbl7.objects.bv = bodyVelocity

		tbl7.conns.inputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed or input.UserInputType ~= Enum.UserInputType.Keyboard then
				return
			end
			local keyCode = input.KeyCode

			if keyCode == Enum.KeyCode.W then
				tbl7.control.F = 1
			end

			if keyCode == Enum.KeyCode.S then
				tbl7.control.B = 1
			end

			if keyCode == Enum.KeyCode.A then
				tbl7.control.L = -1
			end

			if keyCode == Enum.KeyCode.D then
				tbl7.control.R = 1
			end

			if keyCode == Enum.KeyCode.E then
				tbl7.control.E = 1
			end

			if keyCode == Enum.KeyCode.Q then
				tbl7.control.Q = -1
			end
		end)

		tbl7.conns.inputEnded = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.Keyboard then
				return
			end
			local keyCode = input.KeyCode

			if keyCode == Enum.KeyCode.W then
				tbl7.control.F = 0
			end

			if keyCode == Enum.KeyCode.S then
				tbl7.control.B = 0
			end

			if keyCode == Enum.KeyCode.A then
				tbl7.control.L = 0
			end

			if keyCode == Enum.KeyCode.D then
				tbl7.control.R = 0
			end

			if keyCode == Enum.KeyCode.E then
				tbl7.control.E = 0
			end

			if keyCode == Enum.KeyCode.Q then
				tbl7.control.Q = 0
			end
		end)

		tbl7.conns.inputChanged = UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.Thumbstick1 then
				tbl7.gamepadAxis = input.Position or Vector2.new(0, 0)
			end
		end)

		tbl7.conns.heartbeat = RunService.Heartbeat:Connect(function()
			if not tbl7.flying then
				return
			end

			if not v9 or not v9.Parent then
				Hub.StopFly()
				return
			end
			local n2 = tonumber(Hub.FlySpeed) or 50
			local currentCamera2 = workspace.CurrentCamera
			local lookVector = currentCamera2 and currentCamera2.CFrame.LookVector or v9.CFrame.LookVector
			local vector = Vector3.new(lookVector.X, 0, lookVector.Z)

			if vector.Magnitude <= 0.001 then
				vector = Vector3.new(v9.CFrame.LookVector.X, 0, v9.CFrame.LookVector.Z)
			end

			local unit = vector.Unit
			local vector2 = Vector3.new(-unit.Z, 0, unit.X)
			local n3

			if humanoid and humanoid.MoveDirection and humanoid.MoveDirection.Magnitude > 0.001 then
				n3 = humanoid.MoveDirection.Unit * n2
			elseif tbl7.gamepadAxis.Magnitude > 0.01 then
				n3 = (unit * -tbl7.gamepadAxis.Y + vector2 * tbl7.gamepadAxis.X) * n2
			else
				local n4 = unit * (tbl7.control.F - tbl7.control.B) + vector2 * (tbl7.control.R + tbl7.control.L)
				n3 = Vector3.zero

				if n4.Magnitude > 0 then
					n3 = n4.Unit * n2 * 0.6
				end
			end

			local n4 = 0

			if n3.Magnitude > 0.05 then
				local vector3 = Vector3.new(n3.X, 0, n3.Z)
				local n5 = 0

				if vector3.Magnitude > 0.001 then
					n5 = vector3.Unit:Dot(unit)
				end

				n4 = lookVector.Y * n2 * n5
			end

			local n5 = 0

			if n3.Magnitude > 0.05 then
				n5 = (tbl7.control.E + tbl7.control.Q) * n2 * 0.5
			end

			local vector3 = Vector3.new(n3.X, n4 + n5, n3.Z)
			local n6 = math.max(n2 * 1.2, 50)

			if vector3.Y > n6 then
				vector3 = Vector3.new(vector3.X, n6, vector3.Z)
			end

			if vector3.Y < -n6 then
				vector3 = Vector3.new(vector3.X, -n6, vector3.Z)
			end

			tbl7.objects.bv.Velocity = vector3

			if currentCamera2 then
				bodyGyro.CFrame = CFrame.new(v9.Position, v9.Position + lookVector)
			else
				bodyGyro.CFrame = v9.CFrame
			end
		end)
	end

	local function fn42(character_)
		local blackScreenGui = Hub.CoinFarm.blackScreenGui

		if blackScreenGui and blackScreenGui.Parent then
			local coinFarm = Hub.CoinFarm
			coinFarm.blackScreenUpdateGeneration = coinFarm.blackScreenUpdateGeneration + 1

			pcall(function()
				blackScreenGui:Destroy()
			end)

			Hub.CoinFarm.blackScreenGui = nil
			table.clear(Hub.CoinFarm.blackScreenLabels)
		end

		localChar.character = character_
		localChar.humanoid = character_:WaitForChild("Humanoid")
		localChar.rootPart = character_:WaitForChild("HumanoidRootPart")
		fn39(character_)
		fn22()

		if Hub.FlyEnabled then
			Hub.StopFly()
			Hub.StartFly()
		end

		if Hub.NoclipEnabled then
			fn18()
			fn17()
		end

		if Hub.InvisibilityEnabled then
			task.defer(fn35)
		end

		if Hub.WalkSpeedConn then
			Hub.WalkSpeedConn:Disconnect()
			Hub.WalkSpeedConn = nil
		end

		Hub.WalkSpeedConn = localChar.humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
			if localChar.humanoid.WalkSpeed ~= Hub.WalkSpeed then
				localChar.humanoid.WalkSpeed = Hub.WalkSpeed
			end
		end)
	end

	trackConn(localPlayer.CharacterAdded:Connect(fn42))

	if localPlayer.Character then
		task.spawn(function()
			fn42(localPlayer.Character)
		end)
	end
end

do
	local function fn39(arg)
		local character_ = localPlayer.Character
		character_ = character_ and character_:FindFirstChild("HumanoidRootPart")
		if not character_ then
			return
		end
		local humanoidRootPart

		if arg == "Gun" then
			humanoidRootPart = nil

			for _, descendant in ipairs(workspace:GetDescendants()) do
				if fn24(descendant) then
					humanoidRootPart = descendant
					break
				else
					humanoidRootPart = nil
				end
			end
		else
			humanoidRootPart = nil

			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
					local knife = arg == "Murderer" and (player.Character:FindFirstChild("Knife") or player:FindFirstChildOfClass("Backpack") and player.Backpack:FindFirstChild("Knife"))
					local str = ""

					if knife then
						str = "Murderer"
					end

					local flag7 = arg == "Sheriff"
					local gun

					if flag7 then
						local gun2 = player.Character:FindFirstChild("Gun")

						if gun2 then
							gun = gun2
						else
							gun = player:FindFirstChildOfClass("Backpack") and player.Backpack:FindFirstChild("Gun")
						end
					else
						gun = flag7
					end

					if gun then
						str = "Sheriff"
					end

					if str == arg then
						humanoidRootPart = player.Character.HumanoidRootPart
						break
					else
						humanoidRootPart = nil
					end
				else
					humanoidRootPart = nil
				end
			end
		end

		if humanoidRootPart then
			if arg == "Murderer" and humanoidRootPart.Parent:FindFirstChild("HumanoidRootPart") then
				character_.CFrame = CFrame.new(humanoidRootPart.Position - humanoidRootPart.CFrame.LookVector * 15 + Vector3.new(0, 3, 0))
			else
				character_.CFrame = humanoidRootPart.CFrame + Vector3.new(0, 3, 0)
			end
		else
			WindUI:Notify({ Title = "Error", Content = arg .. " cannot be found", Icon = "x", Duration = 1.5 })
		end
	end

	local function fn40(cFrame, arg)
		local character_ = localPlayer.Character
		local humanoid = character_ and character_:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = character_ and character_:FindFirstChild("HumanoidRootPart")
		if not character_ or not humanoid or humanoid.Health <= 0 or not humanoidRootPart then
			WindUI:Notify({ Title = "Teleport", Content = "Your character is not alive.", Icon = "x", Duration = 2.5 })
			return false
		end

		pcall(function()
			humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
			humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
			character_:PivotTo(cFrame)
			humanoidRootPart.CFrame = cFrame
		end)

		WindUI:Notify({
			Title = "Teleport",
			Content = "Teleported to " .. (arg or "location") .. "!",
			Icon = "check",
			Duration = 2,
		})

		return true
	end

	local function fn41()
		local tbl7 = {}
		local summerLobby = workspace:FindFirstChild("SummerLobby")
		local lobby = workspace:FindFirstChild("Lobby")
		local normalLobby = workspace:FindFirstChild("NormalLobby")
		local halloweenLobby = workspace:FindFirstChild("HalloweenLobby")
		local christmasLobby = workspace:FindFirstChild("ChristmasLobby")
		local v9 = workspace
		local findFirstChild = v9.FindFirstChild
		tbl7[1] = summerLobby
		tbl7[2] = lobby
		tbl7[3] = normalLobby
		tbl7[4] = halloweenLobby
		tbl7[5] = christmasLobby

		do
			local values = table.pack(findFirstChild(v9, "EasterLobby"))
			table.move(values, 1, values.n, 6, tbl7)
		end

		for _, v10 in ipairs(tbl7) do
			if v10 then
				local spawns = v10:FindFirstChild("Spawns")

				if spawns then
					local spawnLocation = spawns:FindFirstChildOfClass("SpawnLocation") or spawns:FindFirstChildWhichIsA("BasePart")
					if spawnLocation then
						return spawnLocation.CFrame + Vector3.new(0, 3.5, 0), "Lobby Spawns"
					end
				end

				local nikilis = v10:FindFirstChild("Lobby") and v10.Lobby:FindFirstChild("Nikilis")

				if nikilis and (nikilis:IsA("BasePart") or nikilis:IsA("Model")) then
					local pivot

					if nikilis:IsA("Model") then
						pivot = nikilis:GetPivot()
					else
						pivot = nikilis.CFrame
					end

					return pivot + Vector3.new(0, 3.5, 0), "Nikilis Lobby"
				end

				v10 = v10:FindFirstChild("Lobby") or v10
				local basePart = v10:FindFirstChildWhichIsA("BasePart", true)
				if basePart then
					return basePart.CFrame + Vector3.new(0, 5, 0), "Lobby"
				end
			end
		end

		for _, descendant in ipairs(workspace:GetDescendants()) do
			if descendant:IsA("SpawnLocation") and (descendant.Parent and string.find(string.lower(descendant.Parent.Name), "spawn") or descendant.Position.Y < -50) then
				return descendant.CFrame + Vector3.new(0, 3.5, 0), "Lobby Spawn"
			end
		end

		return nil, nil
	end

	local function fn42()
		local tbl7 = {
			SummerLobby = true,
			Lobby = true,
			NormalLobby = true,
			HalloweenLobby = true,
			ChristmasLobby = true,
			EasterLobby = true,
			EffectLoader = true,
			ServerStatus = true,
			PetContainer = true,
			WeaponDisplays = true,
			RCCars = true,
			Terrain = true,
			Camera = true,
		}

		local function fn43(arg)
			if not arg then
				return false
			end
			local name = arg.Name
			if tbl7[name] then
				return true
			end

			if string.find(string.lower(name), "lobby") then
				return true
			end
			return false
		end

		local currentMapInstance = Hub.RoundState and Hub.RoundState.currentMapInstance
		local resolveMap

		if currentMapInstance then
			resolveMap = currentMapInstance
		else
			resolveMap = Hub.CoinFarm and Hub.CoinFarm.ResolveMap and Hub.CoinFarm.ResolveMap()
		end

		resolveMap = resolveMap or Hub.CoinFarm and Hub.CoinFarm.indexedMap

		if not (resolveMap and resolveMap.Parent and resolveMap:IsDescendantOf(workspace)) then
			resolveMap = nil

			for _, child in ipairs(workspace:GetChildren()) do
				if (child:IsA("Model") or child:IsA("Folder")) and not fn43(child) and not Players:GetPlayerFromCharacter(child) then
					if child:FindFirstChild("CoinContainer", true) or child:FindFirstChild("Coin_Server", true) or child:FindFirstChild("CoinVisual", true) then
						resolveMap = child
						break
					else
						resolveMap = nil
					end
				else
					resolveMap = nil
				end
			end
		end

		if not (resolveMap and resolveMap.Parent and resolveMap:IsDescendantOf(workspace)) then
			for _, child in ipairs(workspace:GetChildren()) do
				if child:IsA("Model") and not fn43(child) and not Players:GetPlayerFromCharacter(child) then
					local spawns = child:FindFirstChild("Spawns")
					if spawns and spawns:FindFirstChildWhichIsA("BasePart") then
						resolveMap = child
						break
					end
				end
			end
		end

		if resolveMap and resolveMap:IsDescendantOf(workspace) then
			local spawns = resolveMap:FindFirstChild("Spawns")

			if spawns then
				local tbl8 = {}

				for _, child in ipairs(spawns:GetChildren()) do
					if child:IsA("BasePart") then
						table.insert(tbl8, child)
					end
				end

				if #tbl8 > 0 then
					return tbl8[math.random(1, #tbl8)].CFrame + Vector3.new(0, 3.5, 0), "Arena Spawns (" .. resolveMap.Name .. ")"
				end
			end

			local coinContainer = resolveMap:FindFirstChild("CoinContainer") or resolveMap:FindFirstChild("CoinContainer", true)

			if coinContainer then
				local basePart = coinContainer:FindFirstChildWhichIsA("BasePart", true)
				if basePart then
					return basePart.CFrame + Vector3.new(0, 3, 0), "Arena (" .. resolveMap.Name .. ")"
				end
			end

			local primaryPart = resolveMap.PrimaryPart or resolveMap:FindFirstChildWhichIsA("BasePart", true)
			if primaryPart then
				return primaryPart.CFrame + Vector3.new(0, 5, 0), "Arena (" .. resolveMap.Name .. ")"
			end
		end

		local gunDrop = workspace:FindFirstChild("GunDrop", true)
		if gunDrop and gunDrop:IsA("BasePart") then
			return gunDrop.CFrame + Vector3.new(0, 3, 0), "Arena (GunDrop)"
		end
		local coinServer = workspace:FindFirstChild("Coin_Server", true) or workspace:FindFirstChild("CoinVisual", true)
		if coinServer and coinServer:IsA("BasePart") and not fn43(coinServer.Parent) then
			return coinServer.CFrame + Vector3.new(0, 3, 0), "Arena (Coins)"
		end
		local flag7 = typeof(fn30) == "function" and fn30()

		if flag7 and flag7 ~= localPlayer and flag7.Character then
			local humanoidRootPart = flag7.Character:FindFirstChild("HumanoidRootPart")
			if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
				return humanoidRootPart.CFrame + Vector3.new(0, 3.5, 0), "Arena (Near Murderer)"
			end
		end

		local flag8 = typeof(fn31) == "function" and fn31()

		if flag8 and flag8 ~= localPlayer and flag8.Character then
			local humanoidRootPart = flag8.Character:FindFirstChild("HumanoidRootPart")
			if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
				return humanoidRootPart.CFrame + Vector3.new(0, 3.5, 0), "Arena (Near Sheriff)"
			end
		end

		return nil, nil
	end

	local function fn43()
		local v9, v10 = fn41()
		if v9 then
			return fn40(v9, v10 or "Lobby")
		end
		WindUI:Notify({ Title = "Error", Content = "Lobby not found.", Icon = "x", Duration = 2 })
		return false
	end

	local function fn44()
		local v9, v10 = fn42()
		if v9 then
			return fn40(v9, v10 or "Game Arena")
		end
		WindUI:Notify({ Title = "Error", Content = "No active game arena map found.", Icon = "x", Duration = 2 })
		return false
	end

	local function resolveVotePads()
		local lobbyNames = { "Lobby", "NormalLobby", "SummerLobby", "HalloweenLobby", "ChristmasLobby", "EasterLobby" }
		for _, name in ipairs(lobbyNames) do
			local lob = workspace:FindFirstChild(name)
			if lob then
				local vp = lob:FindFirstChild("VotePads")
				if vp then
					return vp
				end
			end
		end
		return workspace:FindFirstChild("VotePads", true)
	end

	local function resolveVotingPad(selection)
		local vp = resolveVotePads()
		if not vp then
			return nil
		end
		local str = tostring(selection or "1")
		local num = str:match("%d") or "1"
		return vp:FindFirstChild("VotePad" .. num)
	end

	local function getBoardCFrame(pad)
		if not pad then
			return nil
		end
		local padPart = pad:FindFirstChild("Pad")
		if not padPart or not padPart:IsA("BasePart") then
			return nil
		end
		local adornee = pad:FindFirstChild("MapInfoGui") and pad.MapInfoGui.Adornee
		local targetPos = padPart.Position + Vector3.new(0, 3, 0)
		if adornee and adornee:IsA("BasePart") then
			return CFrame.lookAt(targetPos, Vector3.new(adornee.Position.X, targetPos.Y, adornee.Position.Z))
		end
		return padPart.CFrame + Vector3.new(0, 3, 0)
	end

	local function getPadVotes(pad)
		if not pad then
			return 0
		end
		local vi = pad:FindFirstChild("VoteInfoGui")
		local container = vi and vi:FindFirstChild("Container")
		local votesLabel = container and container:FindFirstChild("Votes")
		if votesLabel and votesLabel:IsA("TextLabel") then
			local num = tonumber(votesLabel.Text:match("%d+"))
			return num or 0
		end
		return 0
	end

	local function isVotingActive()
		local vp = resolveVotePads()
		if not vp then
			return false
		end
		for _, pad in ipairs(vp:GetChildren()) do
			local vi = pad:FindFirstChild("VoteInfoGui")
			if vi and vi:IsA("SurfaceGui") and vi.Enabled then
				return true
			end
		end
		return false
	end

	local function teleportToVotePad(cf)
		local character_ = localPlayer.Character
		local humanoid = character_ and character_:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = character_ and character_:FindFirstChild("HumanoidRootPart")
		if not character_ or not humanoid or humanoid.Health <= 0 or not humanoidRootPart then
			return false
		end
		pcall(function()
			humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
			humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
			character_:PivotTo(cf)
			humanoidRootPart.CFrame = cf
		end)
		return true
	end

	local function resetCharacterForVote()
		local character_ = localPlayer.Character
		local humanoid = character_ and character_:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			pcall(function()
				humanoid.Health = 0
			end)
			if humanoid.Health > 0 then
				pcall(function()
					character_:BreakJoints()
				end)
			end
		end
	end

	local function waitForRespawn(timeout)
		local deadline = os.clock() + (timeout or 6)
		while os.clock() < deadline and Hub.AutoMapVote.enabled do
			local character_ = localPlayer.Character
			local humanoid = character_ and character_:FindFirstChildOfClass("Humanoid")
			local humanoidRootPart = character_ and character_:FindFirstChild("HumanoidRootPart")
			if character_ and humanoid and humanoidRootPart and humanoid.Health > 0 then
				task.wait(0.12)
				return character_
			end
			task.wait(0.05)
		end
		return localPlayer.Character
	end

	local function runAutoMapVoteCycle()
		while Hub.AutoMapVote.enabled do
			if not isVotingActive() then
				task.wait(0.5)
				continue
			end

			local pad = resolveVotingPad(Hub.AutoMapVote.board)
			if not pad then
				task.wait(0.5)
				continue
			end

			local cf = getBoardCFrame(pad)
			if not cf then
				task.wait(0.5)
				continue
			end

			local startVotes = getPadVotes(pad)
			teleportToVotePad(cf)

			local voteRose = false
			local waitStart = os.clock()
			while Hub.AutoMapVote.enabled and isVotingActive() and (os.clock() - waitStart < 3) do
				if getPadVotes(pad) > startVotes then
					voteRose = true
					break
				end
				if os.clock() - waitStart > 1.2 then
					teleportToVotePad(cf)
				end
				task.wait(0.05)
			end

			if voteRose and Hub.AutoMapVote.enabled and isVotingActive() then
				resetCharacterForVote()
				waitForRespawn(6)
			else
				task.wait(0.2)
			end
		end
	end

	local function teleportToVotingBoard()
		local pad = resolveVotingPad(Hub.AutoMapVote.board)
		local cf = getBoardCFrame(pad)
		if cf then
			local mapName = pad:FindFirstChild("VoteInfoGui") and pad.VoteInfoGui:FindFirstChild("Container") and pad.VoteInfoGui.Container:FindFirstChild("MapName") and pad.VoteInfoGui.Container.MapName.Text
			local label = Hub.AutoMapVote.board
			if mapName and mapName ~= "" then
				label ..= " (" .. mapName .. ")"
			end
			return fn40(cf, label)
		end
		WindUI:Notify({ Title = "Error", Content = "Voting board not found.", Icon = "x", Duration = 2 })
		return false
	end

	local function fn45(arg)
		local v9 = Players:FindFirstChild(arg)
		if not v9 or not v9.Character then
			WindUI:Notify({ Title = "Error", Content = "Player not found", Icon = "x", Duration = 1.5 })
			return
		end
		local humanoidRootPart = v9.Character:FindFirstChild("HumanoidRootPart")
		if not humanoidRootPart then
			return
		end
		local character_ = localPlayer.Character
		character_ = character_ and character_:FindFirstChild("HumanoidRootPart")
		if not character_ then
			return
		end
		character_.CFrame = humanoidRootPart.CFrame + Vector3.new(0, 3, 0)
	end

	local function fn46()
		local tbl7 = {}

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= localPlayer then
				table.insert(tbl7, player.Name)
			end
		end

		table.sort(tbl7)
		return tbl7
	end

	local v9 = nil
	local v10 = nil
	local v11 = nil
	Hub.RefreshingPlayerDropdown = false

	local function fn47(arg, arg2)
		if not arg then
			return
		end
		local flag7 = false

		if arg.SetValues then
			flag7 = pcall(function()
				arg:SetValues(arg2)
			end)
		end

		if not flag7 and arg.Refresh then
			flag7 = pcall(function()
				arg:Refresh(arg2)
			end)
		end

		if not flag7 and arg.Update then
			pcall(function()
				arg:Update(arg2)
			end)
		end
	end

	local function fn48()
		Hub.RefreshingPlayerDropdown = true
		local tbl7 = fn46()

		if #tbl7 == 0 then
			tbl7 = { "(No other players)" }
		end

		fn47(v9, tbl7)
		fn47(v10, tbl7)

		if v11 and not Players:FindFirstChild(v11) then
			v11 = nil
		end

		if Hub.SelectedFlingName and not Players:FindFirstChild(Hub.SelectedFlingName) then
			Hub.SelectedFlingName = nil
		end

		task.defer(function()
			Hub.RefreshingPlayerDropdown = false
		end)
	end

	local function fn49()
		local tbl7 = {
			enabled = false,
			generation = 0,
			connections = {},
			restoreItems = {},
			processed = setmetatable({}, { __mode = "k" }),
			stats = { parts = 0, textures = 0, effects = 0 },
		}

		local function fn50(arg, arg2)
			local stats = tbl7.stats
			stats[arg2] = stats[arg2] + 1
		end

		local function fn51(arg, arg2, arg3)
			if not arg then
				return false
			end

			local ok, result = pcall(function()
				return arg[arg2]
			end)

			if not ok then
				return false
			end

			if result == arg3 then
				return true
			end
			table.insert(tbl7.restoreItems, arg)
			table.insert(tbl7.restoreItems, arg2)
			table.insert(tbl7.restoreItems, result)

			return pcall(function()
				arg[arg2] = arg3
			end)
		end

		local function fn52(arg)
			if not arg then
				return false
			end

			while arg and arg ~= workspace do
				if arg:IsA("Model") then
					if Players:GetPlayerFromCharacter(arg) then
						return true
					end
					local v12 = Players:FindFirstChild(arg.Name)
					local flag7

					if v12 then
						flag7 = v12.Character == arg or arg:FindFirstChildOfClass("Humanoid") ~= nil
					else
						flag7 = v12
					end

					if flag7 then
						return true
					end
				end

				arg = arg.Parent
			end

			return false
		end

		local function fn53(arg)
			if not tbl7.enabled or not arg or fn52(arg) or tbl7.processed[arg] then
				return
			end
			tbl7.processed[arg] = true

			if arg:IsA("BasePart") then
				fn51(arg, "Material", Enum.Material.SmoothPlastic)
				fn50(arg, "parts")

				if arg:IsA("MeshPart") then
					fn51(arg, "TextureID", "")
					fn50(arg, "textures")
				end
			elseif arg:IsA("Decal") or arg:IsA("Texture") then
				fn51(arg, "Texture", "")
				fn51(arg, "Transparency", 1)
				fn50(arg, "textures")
			elseif arg:IsA("SurfaceAppearance") then
				fn51(arg, "ColorMap", "")
				fn51(arg, "MetalnessMap", "")
				fn51(arg, "NormalMap", "")
				fn51(arg, "RoughnessMap", "")
				fn50(arg, "textures")
			elseif arg:IsA("ParticleEmitter") or arg:IsA("Smoke") or arg:IsA("Sparkles") or arg:IsA("Fire") or arg:IsA("Trail") or arg:IsA("Beam") then
				fn51(arg, "Enabled", false)
				fn50(arg, "effects")
			end
		end

		local function fn54()
			local restoreItems = tbl7.restoreItems

			for i = #restoreItems - 2, 1, -3 do
				local v12 = restoreItems[i]
				local v13 = restoreItems[i + 1]
				local v14 = restoreItems[i + 2]

				if v12 and v12.Parent then
					pcall(function()
						v12[v13] = v14
					end)
				end
			end

			table.clear(restoreItems)
		end

		Hub.SetFPSBoost = function(enabled, arg)
			enabled = enabled and true or false
			if tbl7.enabled == enabled then
				return
			end
			tbl7.enabled = enabled
			tbl7.generation = tbl7.generation + 1
			local generation = tbl7.generation

			for i = #tbl7.connections, 1, -1 do
				local v12 = tbl7.connections[i]
				tbl7.connections[i] = nil

				if v12 and v12.Connected then
					pcall(function()
						v12:Disconnect()
					end)
				end
			end

			if not enabled then
				fn54()
				tbl7.processed = setmetatable({}, { __mode = "k" })

				if not arg then
					WindUI:Notify({
						Title = "Anti Lag",
						Content = "Original materials, textures and particle effects restored.",
						Icon = "rotate-ccw",
						Duration = 2.5,
					})
				end

				return
			end

			table.clear(tbl7.restoreItems)
			tbl7.processed = setmetatable({}, { __mode = "k" })
			tbl7.stats = { parts = 0, textures = 0, effects = 0 }

			table.insert(tbl7.connections, workspace.DescendantAdded:Connect(function(descendant)
				task.defer(function()
					if tbl7.enabled and tbl7.generation == generation then
						fn53(descendant)
					end
				end)
			end))

			task.spawn(function()
				local n2 = 0

				local function fn55(arg2)
					for _, descendant in ipairs(arg2:GetDescendants()) do
						if not tbl7.enabled or tbl7.generation ~= generation then
							return false
						end
						fn53(descendant)
						n2 += 1

						if n2 % 200 == 0 then
							RunService.Heartbeat:Wait()
						end
					end

					return true
				end

				if fn55(workspace) and tbl7.enabled and tbl7.generation == generation and not arg then
					WindUI:Notify({
						Title = "Anti Lag",
						Content = string.format("Reduced %d parts, %d textures and %d particle effects. Lighting was preserved.", tbl7.stats.parts, tbl7.stats.textures, tbl7.stats.effects),
						Icon = "gauge",
						Duration = 3,
					})
				end
			end)
		end
	end

	fn49()

	local function fn50()
		local character_ = localPlayer.Character
		character_ = character_ and character_:FindFirstChild("HumanoidRootPart")
		if not character_ then
			return nil
		end
		local huge = math.huge
		local v12 = nil

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= localPlayer and player.Character and fn26(player) and not fn25(player) then
				local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					local magnitude = (character_.Position - humanoidRootPart.Position).Magnitude

					if magnitude < huge then
						huge = magnitude
						v12 = player
					end
				end
			end
		end

		if not v12 then
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= localPlayer and player.Character and fn26(player) then
					local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart then
						local magnitude = (character_.Position - humanoidRootPart.Position).Magnitude

						if magnitude < huge then
							huge = magnitude
							v12 = player
						end
					end
				end
			end
		end

		return v12
	end

	local function fn51(arg)
		local character_ = localPlayer.Character
		local humanoid = character_ and character_:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = character_ and character_:FindFirstChild("HumanoidRootPart")
		if not (character_ and humanoid and humanoidRootPart) then
			return false
		end
		local knife = character_:FindFirstChild("Knife")

		if not knife then
			local backpack = localPlayer:FindFirstChildOfClass("Backpack")
			backpack = backpack and backpack:FindFirstChild("Knife")

			if backpack then
				humanoid:EquipTool(backpack)
				task.wait(0.05)
				knife = character_:FindFirstChild("Knife") or backpack
			end
		end

		local isMurderer = fn28(localPlayer) == "Murderer" or knife ~= nil or (localPlayer:FindFirstChildOfClass("Backpack") and localPlayer.Backpack:FindFirstChild("Knife") ~= nil)
		if not isMurderer then
			if not arg then
				WindUI:Notify({ Title = "Error", Content = "You must be Murderer for this", Icon = "x", Duration = 1.5 })
			end

			return false
		end

		if not knife then
			if not arg then
				WindUI:Notify({ Title = "Error", Content = "Knife not found", Icon = "x", Duration = 1.5 })
			end

			return false
		end

		local v12 = fn50()

		if not v12 or not v12.Character then
			if not arg then
				WindUI:Notify({ Title = "Error", Content = "No target found", Icon = "x", Duration = 1.5 })
			end

			return false
		end

		local humanoidRootPart2 = v12.Character:FindFirstChild("HumanoidRootPart")
		local humanoid2 = v12.Character:FindFirstChildOfClass("Humanoid")
		if not humanoidRootPart2 then
			return false
		end
		local rightHand = character_:FindFirstChild("RightHand") or character_:FindFirstChild("Right Arm")
		local position = rightHand and rightHand.Position or humanoidRootPart.Position
		local moveDirection = humanoid2 and humanoid2.MoveDirection or Vector3.new()
		local n2 = (Hub.AutoShootState and Hub.AutoShootState.offset or 2.8) + 1
		local n3 = humanoidRootPart2.Position + humanoidRootPart2.AssemblyLinearVelocity * Vector3.new(0.75, 0.5, 0.75) * n2 / 15 + moveDirection * n2

		if Hub.ThrowKnifeButtonState.mode == "Behind Walls" then
			local unit

			if moveDirection.Magnitude <= 0.001 then
				local n4 = humanoidRootPart2.AssemblyLinearVelocity * Vector3.new(1, 0, 1)
				unit = n4.Magnitude > 0.001 and n4.Unit or humanoidRootPart2.CFrame.LookVector
			else
				unit = moveDirection.Unit
			end

			position = n3 + unit * 1.35 + Vector3.new(0, 0.8, 0)
		end

		local events = knife:FindFirstChild("Events") or knife:WaitForChild("Events", 1)
		local knifeThrown

		if events then
			knifeThrown = events:FindFirstChild("KnifeThrown") or events:WaitForChild("KnifeThrown", 1)
		else
			knifeThrown = events
		end

		if not knifeThrown or not knifeThrown:IsA("RemoteEvent") then
			if not arg then
				WindUI:Notify({ Title = "Error", Content = "Knife remote not found", Icon = "x", Duration = 1.5 })
			end

			return false
		end

		local handle = knife:FindFirstChild("Handle")
		local originCFrame = handle and handle.CFrame or CFrame.new(position)

		local ok = pcall(function()
			knifeThrown:FireServer(originCFrame, CFrame.new(n3))
		end)

		if not ok and not arg then
			WindUI:Notify({ Title = "Error", Content = "Throw failed", Icon = "x", Duration = 1.5 })
		end

		return ok
	end

	local function fn52()
		Hub.TouchButtons.Destroy(Hub.ThrowKnifeButtonState)
	end

	local function fn53()
		Hub.TouchButtons.ToggleThrowKnifeButton(true)
	end

	Hub.TriggerThrowKnifeInput = function()
		local throwKnifeButtonState = Hub.ThrowKnifeButtonState
		local now = tick()
		if throwKnifeButtonState.inputBusy or now < throwKnifeButtonState.nextInputAt then
			return false
		end
		throwKnifeButtonState.inputBusy = true
		throwKnifeButtonState.nextInputAt = now + throwKnifeButtonState.inputCooldown

		task.spawn(function()
			pcall(fn51, false)
			throwKnifeButtonState.inputBusy = false
		end)

		return true
	end

	Hub.ToggleThrowKnifeButton = function(arg)
		Hub.TouchButtons.ToggleThrowKnifeButton(arg)
	end

	task.wait(UI_BUILD_DELAY)

	Tabs.Teleports:Button({
		Title = "TP to Murderer",
		Callback = function()
			fn39("Murderer")
		end,
	})

	Tabs.Teleports:Button({
		Title = "TP to Sheriff",
		Callback = function()
			fn39("Sheriff")
		end,
	})

	Tabs.Teleports:Button({
		Title = "TP to Gun",
		Callback = function()
			fn39("Gun")
		end,
	})

	Tabs.Teleports:Button({
		Title = "TP to Safezone",
		Callback = function()
			fn23()
		end,
	})

	Tabs.Teleports:Button({
		Title = "TP to Lobby",
		Callback = function()
			fn43()
		end,
	})

	Tabs.Teleports:Button({
		Title = "TP to Game Arena",
		Callback = function()
			fn44()
		end,
	})

	Tabs.Teleports:Button({
		Title = "TP to Voting Board",
		Callback = function()
			teleportToVotingBoard()
		end,
	})

	Tabs.Teleports:Divider()

	Hub.AutoMapVote.control = Tabs.Teleports:Toggle({
		Title = "Auto Map Vote",
		Flag = "Teleports_AutoMapVote",
		Default = false,
		Callback = function(arg)
			Hub.AutoMapVote.enabled = arg and true or false
			if Hub.AutoMapVote.enabled then
				if not Hub.AutoMapVote.thread then
					Hub.AutoMapVote.thread = task.spawn(function()
						runAutoMapVoteCycle()
						Hub.AutoMapVote.thread = nil
					end)
				end
			else
				Hub.AutoMapVote.thread = nil
			end
		end,
	})

	Hub.AutoMapVote.boardControl = Tabs.Teleports:Dropdown({
		Title = "Voting Board",
		Flag = "Teleports_VotingBoard",
		Values = { "Board 1", "Board 2", "Board 3" },
		Value = Hub.AutoMapVote.board,
		Callback = function(arg)
			Hub.AutoMapVote.board = arg or "Board 1"
		end,
	})

	Tabs.Teleports:Divider()

	local function fn54()
		local v12 = fn46()
		if #v12 == 0 then
			return { "(No other players)" }
		end
		return v12
	end

	v9 = Tabs.Teleports:Dropdown({
		Title = "TP to Player",
		Values = fn54(),
		Value = nil,
		Callback = function(arg)
			if Hub.RefreshingPlayerDropdown then
				return
			end

			if not arg or arg == "(No other players)" then
				return
			end
			v11 = arg
			fn45(arg)
		end,
	})

	Tabs.Teleports:Button({
		Title = "Refresh Player List",
		Callback = function()
			fn48()
		end,
	})

	trackConn(Players.PlayerAdded:Connect(function()
		task.defer(fn48)
	end))

	trackConn(Players.PlayerRemoving:Connect(function(player)
		if Hub.SelectedFlingName and player and player.Name == Hub.SelectedFlingName then
			Hub.SelectedFlingName = nil
			fn21()
		end
	end))

	Hub.FrozenPlayers = {}
	Hub.FrozenPlayerReleaseIds = {}
	Hub.KnifeAuraFrozenPlayers = {}
	Hub.KnifeAuraReleaseId = 0

	Hub.CoinFarm.runKnifeAura = function(arg)
		local v12 = Hub.CoinFarm.GetCachedRole(localPlayer)
		local character_ = localPlayer.Character
		local humanoid = character_ and character_:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = character_ and character_:FindFirstChild("HumanoidRootPart")
		local backpack = localPlayer:FindFirstChildOfClass("Backpack")
		local knife = character_ and character_:FindFirstChild("Knife")
		backpack = backpack and backpack:FindFirstChild("Knife")
		local flag7 = v12 ~= "Murderer"

		if flag7 then
			flag7 = not (knife or backpack)
		end

		if flag7 then
			return false
		end
		local flag8 = not character_ or not humanoid or humanoid.Health <= 0 or not humanoidRootPart

		if not flag8 then
			flag8 = not (knife or backpack)
		end

		if flag8 then
			return false
		end

		if not fn23() then
			return false
		end
		task.wait(0.15)
		local character_2 = localPlayer.Character
		local humanoid2 = character_2 and character_2:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart2 = character_2 and character_2:FindFirstChild("HumanoidRootPart")
		local backpack2 = localPlayer:FindFirstChildOfClass("Backpack")
		local knife2 = character_2 and character_2:FindFirstChild("Knife")
		backpack2 = backpack2 and backpack2:FindFirstChild("Knife")
		local flag9 = not character_2 or not humanoid2 or humanoid2.Health <= 0 or not humanoidRootPart2
		local flag10

		if flag9 then
			flag10 = flag9
		else
			flag10 = not (knife2 or backpack2)
		end

		if flag10 then
			return false
		end

		if not knife2 then
			humanoid2:EquipTool(backpack2)
			task.wait(0.15)
			knife2 = character_2:FindFirstChild("Knife")
		end

		if not knife2 or not knife2:IsA("Tool") then
			return false
		end
		local stab = knife2:FindFirstChild("Stab")
		local events = knife2:FindFirstChild("Events") or knife2:WaitForChild("Events", 0.5)
		local knifeStabbed = events and events:FindFirstChild("KnifeStabbed")
		local flag11 = not (stab and stab:IsA("RemoteEvent"))

		if flag11 then
			flag11 = not (knifeStabbed and knifeStabbed:IsA("RemoteEvent"))
		end

		if flag11 then
			return false
		end

		local function fn55(arg2)
			if not arg2 or arg2 == localPlayer then
				return false
			end

			if fn6(arg2) and not isOwner then
				fn7("kill")
				return false
			end
			local v13 = Hub.RoleState.cache[arg2.Name] or Hub.RoleState.cache[tostring(arg2.UserId)] or Hub.RoleState.cache[arg2.UserId]
			if type(v13) == "table" then
				return v13.Dead ~= true and v13.Role ~= "Murderer"
			end
			return not fn25(arg2)
		end

		local tbl7 = {}
		local cFrame = humanoidRootPart2.CFrame + humanoidRootPart2.CFrame.LookVector * 2

		for _, player in ipairs(Players:GetPlayers()) do
			local character_3 = player.Character
			local humanoid3 = character_3 and character_3:FindFirstChildOfClass("Humanoid")
			local humanoidRootPart3 = character_3 and character_3:FindFirstChild("HumanoidRootPart")

			if fn55(player) and humanoid3 and humanoid3.Health > 0 and humanoidRootPart3 and character_3:IsDescendantOf(workspace) then
				table.insert(tbl7, { root = humanoidRootPart3, anchored = humanoidRootPart3.Anchored })
				humanoidRootPart3.Anchored = true
				humanoidRootPart3.CFrame = cFrame
			end
		end

		local flag12 = #tbl7 > 0
		local flag13 = false

		if flag12 then
			task.wait(0.15)

			if Hub.CoinFarm.endRoundGeneration == arg and Hub.CoinFarm.enabled and Hub.CoinFarm.endRoundEnabled and Hub.CoinFarm.bagFull and knife2.Parent and humanoid2.Health > 0 then
				for i = 1, 3 do
					if not (Hub.CoinFarm.endRoundGeneration ~= arg or not Hub.RoundState.active) then
						local cFrame2 = humanoidRootPart2.CFrame + humanoidRootPart2.CFrame.LookVector * 2

						for _, v13 in ipairs(tbl7) do
							if v13.root and v13.root.Parent then
								v13.root.Anchored = true
								v13.root.CFrame = cFrame2
							end
						end

						local ok = pcall(function()
							knife2:Activate()

							if stab and stab:IsA("RemoteEvent") then
								stab:FireServer("Slash")
							else
								knifeStabbed:FireServer()
							end
						end)

						flag13 = flag13 or ok
						task.wait(0.1)
						continue
					end

					break
				end

				task.wait(0.25)
			end
		end

		for _, v13 in ipairs(tbl7) do
			if v13.root and v13.root.Parent then
				v13.root.Anchored = v13.anchored == true
			end
		end

		local n2 = 0

		for _, player in ipairs(Players:GetPlayers()) do
			if fn55(player) then
				local character_3 = player.Character
				character_3 = character_3 and character_3:FindFirstChildOfClass("Humanoid")

				if character_3 and character_3.Health > 0 then
					n2 += 1
				end
			end
		end

		return flag12 and flag13 and n2 == 0
	end

	local function fn55(arg)
		local flag7 = arg == "Murderer" and fn30() or fn31()
		if not flag7 or flag7 == localPlayer then
			return
		end
		local character_ = localPlayer.Character
		character_ = character_ and character_:FindFirstChild("HumanoidRootPart")
		if not character_ then
			return
		end
		local character_2 = flag7.Character
		character_2 = character_2 and character_2:FindFirstChild("HumanoidRootPart")
		if not character_2 then
			return
		end
		character_2.Anchored = true
		character_2.CFrame = character_.CFrame + character_.CFrame.LookVector * 5
		Hub.FrozenPlayers[flag7] = character_2
		local n2 = (Hub.FrozenPlayerReleaseIds[flag7] or 0) + 1
		Hub.FrozenPlayerReleaseIds[flag7] = n2

		task.delay(15, function()
			if Hub.FrozenPlayerReleaseIds[flag7] ~= n2 then
				return
			end
			local v12 = Hub.FrozenPlayers[flag7]

			if v12 and v12.Parent then
				v12.Anchored = false
			end

			Hub.FrozenPlayers[flag7] = nil
			Hub.FrozenPlayerReleaseIds[flag7] = nil
		end)
	end

	task.wait(UI_BUILD_DELAY)

	Tabs.Combat:Section({ Title = "Murderer", TextXAlignment = "Center", TextSize = 17, Opened = true })

	tbl2.Murderer:Button({
		Title = "Bring + Freeze Sheriff",
		Desc = "Automatically unfreezes after 15 seconds",
		Callback = function()
			fn55("Sheriff")
		end,
	})

	Tabs.Player:Toggle({
		Title = "Spinbot",
		Flag = "Misc_Spinbot",
		Default = false,
		Callback = function(arg)
			Hub.Spinbot.SetEnabled(arg)
		end,
	})

	Tabs.Player:Slider({
		Title = "Spin Speed",
		Flag = "Misc_SpinbotSpeed",
		Value = { Min = 1, Max = 3, Default = Hub.Spinbot.speed },
		Step = 1,
		Callback = function(arg)
			Hub.Spinbot.speed = math.clamp(tonumber(arg) or 1, 1, 3)
		end,
	})

	tbl2.Murderer:Toggle({
		Title = "Hitbox Expander",
		Desc = "Works during knife stabs",
		Flag = "Misc_HitboxExpander",
		Default = false,
		Callback = function(arg)
			Hub.HitboxExpander.SetEnabled(arg)
		end,
	})

	tbl2.Murderer:Slider({
		Title = "Hitbox Size",
		Flag = "Misc_HitboxSize",
		Value = { Min = 2, Max = 50, Default = Hub.HitboxExpander.size },
		Step = 1,
		Callback = function(arg)
			Hub.HitboxExpander.size = math.clamp(tonumber(arg) or 6, 2, 50)

			if Hub.HitboxExpander.stabActive then
				Hub.HitboxExpander.ApplyAll()
			end
		end,
	})

	tbl2.Murderer:Toggle({
		Title = "Show Hitboxes",
		Flag = "Misc_ShowHitboxes",
		Default = false,
		Callback = function(arg)
			Hub.HitboxExpander.visible = arg and true or false

			if Hub.HitboxExpander.stabActive then
				Hub.HitboxExpander.ApplyAll()
			end
		end,
	})

	tbl2.General:Toggle({
		Title = "Avoid Murderer",
		Flag = "General_AvoidMurderer",
		Default = false,
		Callback = function(arg)
			local avoidMurderer = Hub.AvoidMurderer
			avoidMurderer.enabled = arg and true or false
			avoidMurderer.nextTeleportAt = 0
			avoidMurderer.accumulator = 0

			if avoidMurderer.connection then
				avoidMurderer.connection:Disconnect()
				avoidMurderer.connection = nil
			end

			if not avoidMurderer.enabled then
				return
			end

			avoidMurderer.connection = RunService.Heartbeat:Connect(function(deltaTime)
				avoidMurderer.accumulator = avoidMurderer.accumulator + deltaTime
				if avoidMurderer.accumulator < 0.15 then
					return
				end
				avoidMurderer.accumulator = 0
				local flag7 = not Hub.RoundState.active or Hub.CoinFarm.GetCachedRole(localPlayer) == "Murderer"

				if not flag7 then
					local nextTeleportAt = avoidMurderer.nextTeleportAt
					flag7 = os.clock() < nextTeleportAt
				end

				if flag7 then
					return
				end
				local character_ = localPlayer.Character
				local humanoid = character_ and character_:FindFirstChildOfClass("Humanoid")
				character_ = character_ and character_:FindFirstChild("HumanoidRootPart")
				local v12 = Hub.CoinFarm.GetMurdererRoot()
				if not humanoid or humanoid.Health <= 0 or not character_ or not v12 or (v12.Position - character_.Position).Magnitude > avoidMurderer.distance then
					return
				end
				local v13 = Hub.CoinFarm.ResolveMap()
				if not v13 then
					return
				end
				local n2 = -math.huge
				local v14 = nil

				for _, descendant in ipairs(v13:GetDescendants()) do
					if descendant:IsA("BasePart") and descendant.Name == "Spawn" then
						local magnitude = (descendant.Position - v12.Position).Magnitude

						if n2 < magnitude then
							n2 = magnitude
							v14 = descendant
						end
					end
				end

				if not v14 then
					return
				end
				avoidMurderer.nextTeleportAt = os.clock() + 1
				Hub.CoinFarm.CancelTween()
				Hub.CoinFarm.currentCoin = nil
				Hub.CoinFarm.DisableUnder()
				character_.AssemblyLinearVelocity = Vector3.zero
				character_.AssemblyAngularVelocity = Vector3.zero
				character_.CFrame = v14.CFrame + Vector3.new(0, v14.Size.Y * 0.5 + character_.Size.Y * 0.5 + 0.15, 0)
			end)
		end,
	})

	tbl2.General:Slider({
		Title = "Avoid Murderer Distance",
		Flag = "General_AvoidMurdererDistance",
		Value = { Min = 10, Max = 150, Default = 35 },
		Step = 1,
		Callback = function(arg)
			Hub.AvoidMurderer.distance = math.clamp(tonumber(arg) or 35, 10, 150)
		end,
	})

	Hub.ShowTimerControl = Tabs.Misc:Toggle({
		Title = "Show Timer",
		Flag = "Misc_ShowTimer",
		Default = false,
		LockedTitle = "Automatically enabled and locked\nwhile Coin Farm is active.",
		Callback = function(arg)
			Hub.ShowRoundTimer = arg and true or false

			if type(Hub.UpdateRoundTimer) == "function" then
				task.defer(Hub.UpdateRoundTimer)
			end
		end,
	})

	Hub.SetXPFarmTimerForced = function(arg)
		if arg then
			if not Hub.ShowTimerForcedByXPFarm then
				Hub.ShowTimerBeforeXPFarm = Hub.ShowRoundTimer
			end

			Hub.ShowTimerForcedByXPFarm = true
			Hub.ShowRoundTimer = true
			Hub.ShowTimerControl:Unlock()
			Hub.ShowTimerControl:Set(true, false, true)
			Hub.ShowTimerControl:Lock()
		else
			Hub.ShowTimerControl:Unlock()

			if Hub.ShowTimerForcedByXPFarm then
				Hub.ShowTimerForcedByXPFarm = false
				Hub.ShowRoundTimer = Hub.ShowTimerBeforeXPFarm
				Hub.ShowTimerControl:Set(Hub.ShowTimerBeforeXPFarm, false, true)
			end
		end

		if type(Hub.UpdateRoundTimer) == "function" then
			task.defer(Hub.UpdateRoundTimer)
		end
	end

	tbl2.General:Toggle({
		Title = "Mobile Quick Menu",
		Desc = "One compact button for Shoot, Throw, Get Gun, Bomb Jump, XRay, Aimlock and Wall Glitch.",
		Flag = "General_MobileQuickMenu",
		Default = false,
		Callback = function(arg)
			Hub.TouchButtons.ToggleQuickMenu(arg)
		end,
	})

	tbl2.General:Toggle({
		Title = "Get Gun Button",
		Flag = "General_GetGunButton",
		Default = false,
		Callback = function(arg)
			Hub.TouchButtons.ToggleGetGunButton(arg)
		end,
	})

	tbl2.General:Dropdown({
		Title = "Get Gun Button Size",
		Flag = "General_GetGunButtonSize",
		Values = { "Small", "Medium", "Large" },
		Value = Hub.GetGunButtonState.size,
		Callback = function(size)
			if Hub.TouchButtons.Sizes[size] then
				Hub.GetGunButtonState.size = size
				Hub.TouchButtons.ApplySize(Hub.GetGunButtonState.button, size, Hub.GetGunButtonState.shape)
			end
		end,
	})

	tbl2.General:Dropdown({
		Title = "Get Gun Button Shape",
		Flag = "General_GetGunButtonShape",
		Values = { "Square", "Rectangle" },
		Value = Hub.GetGunButtonState.shape,
		Callback = function(arg)
			Hub.GetGunButtonState.shape = arg == "Rectangle" and "Rectangle" or "Square"
			Hub.TouchButtons.ApplySize(Hub.GetGunButtonState.button, Hub.GetGunButtonState.size, Hub.GetGunButtonState.shape)
			Hub.TouchButtons.UpdateHoldHint(Hub.GetGunButtonState, Hub.GetGunButtonState.button)
		end,
	})

	tbl2.General:Colorpicker({
		Title = "Get Gun Icon Color",
		Flag = "General_GetGunButtonColor",
		Default = Hub.GetGunButtonState.outlineColor or Hub.TouchButtons.Theme.accentColor,
		Callback = function(outlineColor)
			Hub.GetGunButtonState.outlineColor = outlineColor
			Hub.TouchButtons.ApplyAppearance(Hub.GetGunButtonState.button, Hub.GetGunButtonState)
		end,
	})

	tbl2.General:Toggle({
		Title = "Get Gun Button Draggable",
		Flag = "General_GetGunButtonDraggable",
		Default = Hub.GetGunButtonState.draggable,
		Callback = function(arg)
			Hub.GetGunButtonState.draggable = arg and true or false
		end,
	})

	tbl2.General:Keybind({
		Title = "Get Gun Keybind",
		Flag = "General_GetGunKeybind",
		Value = "J",
		Callback = function()
			if Hub.TakeDroppedGunOnce then
				Hub.TakeDroppedGunOnce()
			end
		end,
	})

	tbl2.General:Toggle({
		Title = "Bomb Jump Button",
		Desc = "Jump and click Bomb Jump while you're in mid-air.",
		Flag = "General_BombJumpButton",
		Default = false,
		Callback = function(arg)
			Hub.TouchButtons.ToggleBombJumpButton(arg)
		end,
	})

	tbl2.General:Dropdown({
		Title = "Bomb Jump Button Size",
		Flag = "General_BombJumpButtonSize",
		Values = { "Small", "Medium", "Large" },
		Value = Hub.BombJumpButtonState.size,
		Callback = function(size)
			if Hub.TouchButtons.Sizes[size] then
				Hub.BombJumpButtonState.size = size
				Hub.TouchButtons.ApplySize(Hub.BombJumpButtonState.button, size, Hub.BombJumpButtonState.shape)
			end
		end,
	})

	tbl2.General:Dropdown({
		Title = "Bomb Jump Button Shape",
		Flag = "General_BombJumpButtonShape",
		Values = { "Square", "Rectangle" },
		Value = Hub.BombJumpButtonState.shape,
		Callback = function(arg)
			Hub.BombJumpButtonState.shape = arg == "Rectangle" and "Rectangle" or "Square"
			Hub.TouchButtons.ApplySize(Hub.BombJumpButtonState.button, Hub.BombJumpButtonState.size, Hub.BombJumpButtonState.shape)
			Hub.TouchButtons.UpdateHoldHint(Hub.BombJumpButtonState, Hub.BombJumpButtonState.button)
		end,
	})

	tbl2.General:Colorpicker({
		Title = "Bomb Jump Icon Color",
		Flag = "General_BombJumpButtonColor",
		Default = Hub.BombJumpButtonState.outlineColor or Hub.TouchButtons.Theme.accentColor,
		Callback = function(outlineColor)
			Hub.BombJumpButtonState.outlineColor = outlineColor
			Hub.TouchButtons.ApplyAppearance(Hub.BombJumpButtonState.button, Hub.BombJumpButtonState)
		end,
	})

	tbl2.General:Toggle({
		Title = "Bomb Jump Button Draggable",
		Flag = "General_BombJumpButtonDraggable",
		Default = Hub.BombJumpButtonState.draggable,
		Callback = function(arg)
			Hub.BombJumpButtonState.draggable = arg and true or false
		end,
	})

	tbl2.General:Keybind({
		Title = "Bomb Jump Keybind",
		Flag = "General_BombJumpKeybind",
		Value = "B",
		Callback = function()
			if Hub.RunBombJump then
				Hub.RunBombJump()
			end
		end,
	})

	local function fn56()
		local v12 = fn46()
		if #v12 == 0 then
			return { "(No other players)" }
		end
		return v12
	end

	v10 = tbl2.General:Dropdown({
		Title = "Fling Target",
		Values = fn56(),
		Value = nil,
		Callback = function(selectedFlingName)
			if Hub.RefreshingPlayerDropdown then
				return
			end

			if not selectedFlingName or selectedFlingName == "(No other players)" then
				return
			end
			Hub.SelectedFlingName = selectedFlingName

			task.spawn(function()
				fn20(selectedFlingName)
			end)
		end,
	})
end

tbl2.General:Button({
	Title = "Fling Sheriff",
	Callback = function()
		local Sheriff = fn29("Sheriff")
		if not Sheriff then
			fn19("Sheriff not found")
			return
		end

		task.spawn(function()
			fn20(Sheriff.Name)
		end)
	end,
})

tbl2.General:Button({
	Title = "Fling Murderer",
	Callback = function()
		local Murderer = fn29("Murderer")
		if not Murderer then
			fn19("Murderer not found")
			return
		end

		task.spawn(function()
			fn20(Murderer.Name)
		end)
	end,
})

tbl2.General:Button({
	Title = "Fling All Players",
	Callback = function()
		if Hub.FlingActive or Hub.FlingAllRunning then
			WindUI:Notify({ Title = "Fling All", Content = "A fling is already running", Icon = "loader", Duration = 2 })
			return
		end
		Hub.FlingAllRunning = true

		task.spawn(function()
			local players = Players:GetPlayers()
			local n2 = 0
			local n3 = 0

			for _, player in ipairs(players) do
				if not (not foxnameMM2Runtime.alive or false) then
					if player ~= localPlayer and player.Parent and (isOwner or not fn6(player)) then
						n2 += 1

						if fn20(player.Name, nil, 1, true) then
							n3 += 1
						end

						task.wait(0.1)
					end

					continue
				end

				break
			end

			Hub.FlingAllRunning = false

			WindUI:Notify({
				Title = "Fling All",
				Content = string.format("Tried %d player(s), flung %d", n2, n3),
				Icon = "check",
				Duration = 3,
			})
		end)
	end,
})

tbl2.General:Toggle({
	Title = "Anti Lag",
	Flag = "General_FPSBoost",
	Default = false,
	Callback = function(arg)
		Hub.SetFPSBoost(arg)
	end,
})

tbl2.General:Divider()

tbl2.Murderer:Button({
	Title = "Knife Aura",
	Callback = function()
		if fn28(localPlayer) ~= "Murderer" then
			WindUI:Notify({ Title = "Error", Content = "You must be Murderer for this", Icon = "x", Duration = 1.5 })
			return
		end
		local character_ = localPlayer.Character
		character_ = character_ and character_:FindFirstChild("HumanoidRootPart")
		if not character_ then
			return
		end
		Hub.KnifeAuraReleaseId = Hub.KnifeAuraReleaseId + 1
		local knifeAuraReleaseId = Hub.KnifeAuraReleaseId
		local n2 = 0

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= localPlayer and fn6(player) and not isOwner and not fn25(player) then
				fn7("kill")
			end

			local flag7 = player ~= localPlayer and not fn25(player)
			local flag8

			if flag7 then
				local v9 = isOwner

				if isOwner then
					flag8 = v9
				else
					flag8 = not fn6(player)
				end
			else
				flag8 = flag7
			end

			if flag8 then
				local character_2 = player.Character
				character_2 = character_2 and character_2:FindFirstChild("HumanoidRootPart")

				if character_2 then
					character_2.Anchored = true
					character_2.CFrame = character_.CFrame + character_.CFrame.LookVector * 5
					Hub.KnifeAuraFrozenPlayers[player] = character_2
					n2 += 1
				end
			end
		end

		task.delay(30, function()
			if knifeAuraReleaseId ~= Hub.KnifeAuraReleaseId then
				return
			end
			local n3 = 0

			for k, knifeAuraFrozenPlayer in pairs(Hub.KnifeAuraFrozenPlayers) do
				if knifeAuraFrozenPlayer and knifeAuraFrozenPlayer.Parent then
					knifeAuraFrozenPlayer.Anchored = false
					n3 += 1
				end

				Hub.KnifeAuraFrozenPlayers[k] = nil
			end

			WindUI:Notify({
				Title = "Knife Aura",
				Content = "Released " .. tostring(n3) .. " player(s)",
				Icon = "check",
				Duration = 2,
			})
		end)

		WindUI:Notify({
			Title = "Done",
			Content = "Hostage applied to " .. tostring(n2) .. " player(s)",
			Icon = "check",
			Duration = 2,
		})
	end,
})

Hub.TouchButtons.ThrowKnifeToggleControl = tbl2.Murderer:Toggle({
	Title = "Throw Knife Button",
	Flag = "Murderer_ThrowKnifeButton",
	Default = Hub.ThrowKnifeButtonState.enabled,
	Callback = function(arg)
		Hub.TouchButtons.ToggleThrowKnifeButton(arg)
	end,
})

tbl2.Murderer:Dropdown({
	Title = "Throw Knife Mode",
	Flag = "Murderer_ThrowKnifeMode",
	Values = { "Normal", "Behind Walls" },
	Value = Hub.ThrowKnifeButtonState.mode,
	Callback = function(mode)
		if mode == "Normal" or mode == "Behind Walls" then
			Hub.ThrowKnifeButtonState.mode = mode
		end
	end,
})

tbl2.Murderer:Dropdown({
	Title = "Throw Knife Button Size",
	Flag = "Murderer_ThrowKnifeButtonSize",
	Values = { "Small", "Medium", "Large" },
	Value = Hub.ThrowKnifeButtonState.size,
	Callback = function(size)
		if Hub.TouchButtons.Sizes[size] then
			Hub.ThrowKnifeButtonState.size = size
			Hub.TouchButtons.ApplySize(Hub.ThrowKnifeButtonState.button, size, Hub.ThrowKnifeButtonState.shape)
		end
	end,
})

tbl2.Murderer:Dropdown({
	Title = "Throw Knife Button Shape",
	Flag = "Murderer_ThrowKnifeButtonShape",
	Values = { "Square", "Rectangle" },
	Value = Hub.ThrowKnifeButtonState.shape,
	Callback = function(arg)
		Hub.ThrowKnifeButtonState.shape = arg == "Rectangle" and "Rectangle" or "Square"
		Hub.TouchButtons.ApplySize(Hub.ThrowKnifeButtonState.button, Hub.ThrowKnifeButtonState.size, Hub.ThrowKnifeButtonState.shape)
		Hub.TouchButtons.UpdateHoldHint(Hub.ThrowKnifeButtonState, Hub.ThrowKnifeButtonState.button)
	end,
})

tbl2.Murderer:Colorpicker({
	Title = "Throw Knife Icon Color",
	Flag = "Murderer_ThrowKnifeButtonColor",
	Default = Hub.ThrowKnifeButtonState.outlineColor,
	Callback = function(outlineColor)
		Hub.ThrowKnifeButtonState.outlineColor = outlineColor
		Hub.TouchButtons.ApplyAppearance(Hub.ThrowKnifeButtonState.button, Hub.ThrowKnifeButtonState)
	end,
})

tbl2.Murderer:Toggle({
	Title = "Throw Knife Button Draggable",
	Flag = "Murderer_ThrowKnifeButtonDraggable",
	Default = Hub.ThrowKnifeButtonState.draggable,
	Callback = function(arg)
		Hub.ThrowKnifeButtonState.draggable = arg and true or false
	end,
})

tbl2.Murderer:Keybind({
	Title = "Throw Knife Keybind",
	Flag = "Murderer_ThrowKnifeKeybind",
	Value = "Z",
	Callback = function()
		if Hub.TriggerThrowKnifeInput then
			Hub.TriggerThrowKnifeInput()
		end
	end,
})

tbl2.Murderer:Divider()
Hub.ApplyAutoLoadConfig = nil

local function fn39()
	Tabs.Settings:Section({ Title = "Mobile Button Style", TextXAlignment = "Center", TextSize = 17, Opened = true })

	Tabs.Settings:Colorpicker({
		Title = "Mobile Button Icon Color",
		Desc = "Changes the icon, divider and outer outline color of every action button.",
		Flag = "Settings_MobileButtonAccent",
		Default = Hub.TouchButtons.Theme.accentColor,
		Callback = function(arg)
			Hub.TouchButtons.SetThemeColor("outlineColor", arg)
		end,
	})

	Tabs.Settings:Divider()

	local function fn40(arg)
		if type(arg) ~= "string" then
			return nil
		end
		local match = arg:match("^%s*(.-)%s*$")
		if match == "" then
			return ""
		end

		if match:match("^%d+$") then
			return "rbxassetid://" .. match
		end

		if match:match("^rbxassetid://") or match:match("^https?://") then
			return match
		end
		return nil
	end

	local tbl7 = {}

	for k in pairs(WindUI:GetThemes()) do
		table.insert(tbl7, k)
	end

	local nowUsingTheme = tbl7[1]
	task.wait(UI_BUILD_DELAY)

	Tabs.Settings:Section({ Title = "Theme / Background", TextXAlignment = "Center", TextSize = 17, Opened = true })

	Tabs.Settings:Dropdown({
		Title = "Select Theme",
		Flag = "Settings_Theme",
		Values = tbl7,
		Value = tbl7[1],
		Callback = function(arg)
			nowUsingTheme = arg
		end,
	})

	Tabs.Settings:Button({
		Title = "Apply Theme",
		Callback = function()
			if nowUsingTheme then
				WindUI:SetTheme(nowUsingTheme)
				WindUI:Notify({ Title = "Theme Applied", Content = "Now using theme: " .. nowUsingTheme, Duration = 2 })
			else
				WindUI:Notify({ Title = "Error", Content = "No theme selected!", Icon = "x", Duration = 2 })
			end
		end,
	})

	local tbl8 = {
		["No Background"] = "rbxassetid://0",
		Main = "rbxassetid://82503368188240",
		Extra = "rbxassetid://75141440720375",
		["Extra 1"] = "rbxassetid://131127340766745",
		Furina = "rbxassetid://133222171266319",
		["Extra 2"] = "rbxassetid://103408204293875",
	}

	local main = tbl8.Main

	Tabs.Settings:Dropdown({
		Title = "Select Background",
		Flag = "Settings_Background",
		Values = { "No Background", "Main", "Extra", "Extra 1", "Extra 2", "Furina" },
		Value = "Main",
		Callback = function(arg)
			main = tbl8[arg]

			pcall(function()
				Window:SetBackgroundImage(main)
			end)
		end,
	})

	Tabs.Settings:Input({
		Title = "Background ID / URL",
		Flag = "Settings_CustomBackground",
		Type = "Input",
		Placeholder = "rbxassetid://1234567890 or https://...",
		Callback = function(arg)
			local v9 = fn40(tostring(arg or ""))

			if v9 == nil then
				WindUI:Notify({
					Title = "Invalid URL",
					Content = "Use rbxassetid://<id> or https:// URL",
					Icon = "alert-triangle",
					Duration = 2,
				})

				return
			end

			if v9 == "" then
				return
			end
			main = v9

			pcall(function()
				Window:SetBackgroundImage(main)
			end)
		end,
	})

	task.wait(UI_BUILD_DELAY)

	Tabs.Settings:Section({ Title = "Keybind", TextXAlignment = "Center", TextSize = 17, Opened = true })

	Tabs.Settings:Keybind({
		Title = "Keybind",
		Flag = "Settings_MenuKeybind",
		Value = "H",
		Callback = function()
			Window:Toggle()
		end,
	})

	Tabs.Settings:Divider()
	task.wait(UI_BUILD_DELAY)

	Tabs.Settings:Section({ Title = "Configs", TextXAlignment = "Center", TextSize = 17, Opened = true })
	local configManager = Window.ConfigManager
	local str = "default"
	local v9 = nil
	local v10 = nil
	local v11 = nil
	local str2 = "FoxnameAutoLoad"
	local str3 = "FoxnameButtonPositions"
	local str4 = "FoxnameCoinFarmState"
	local flag7 = false
	local str5 = "default"

	local function fn41(arg)
		local str6 = tostring(arg or ""):match("^%s*(.-)%s*$"):gsub("%.json$", ""):gsub("[^%w_%-]", "_"):gsub("_+", "_"):sub(1, 48)

		if str6 == "" then
			str6 = "default"
		end

		return str6
	end

	local function fn42(arg)
		if typeof(arg) ~= "UDim2" then
			return nil
		end
		return { arg.X.Scale, arg.X.Offset, arg.Y.Scale, arg.Y.Offset }
	end

	local function fn43(arg)
		if type(arg) ~= "table" then
			return nil
		end
		local num = tonumber(arg[1])
		local num2 = tonumber(arg[2])
		local num3 = tonumber(arg[3])
		local num4 = tonumber(arg[4])
		if not num or not num2 or not num3 or not num4 then
			return nil
		end
		return UDim2.new(num, num2, num3, num4)
	end

	local function fn44()
		for _, v12 in ipairs({
			Hub.XRayButtonState,
			Hub.AimlockButtonState,
			Hub.GetGunButtonState,
			Hub.BombJumpButtonState,
			Hub.ThrowKnifeButtonState,
			Hub.WallPhaseButtonState,
			Hub.FlyButtonState,
			Hub.NoclipButtonState,
			Hub.QuickMenuState,
		}) do
			if v12.button and v12.button.Parent then
				v12.position = v12.button.Position
			end
		end

		if Hub.AutoShootTouchButton and Hub.AutoShootTouchButton.Parent then
			Hub.AutoShootDragState.buttonPos = Hub.AutoShootTouchButton.Position
		end
	end

	local function fn45()
		fn44()

		return {
			xray = fn42(Hub.XRayButtonState.position),
			aimlock = fn42(Hub.AimlockButtonState.position),
			getGun = fn42(Hub.GetGunButtonState.position),
			bombJump = fn42(Hub.BombJumpButtonState.position),
			throwKnife = fn42(Hub.ThrowKnifeButtonState.position),
			wallPhase = fn42(Hub.WallPhaseButtonState.position),
			fly = fn42(Hub.FlyButtonState.position),
			noclip = fn42(Hub.NoclipButtonState.position),
			quickMenu = fn42(Hub.QuickMenuState.position),
			autoShoot = fn42(Hub.AutoShootDragState.buttonPos),
		}
	end

	local function fn46(arg, arg2)
		if type(arg) ~= "table" then
			return false
		end

		if type(arg.CustomData) ~= "table" then
			arg.CustomData = {}
		end

		arg.CustomData[str3] = fn45()

		arg.CustomData[str4] = {
			enabled = Hub.CoinFarm.enabled == true,
			xpFarm = Hub.CoinFarm.xpFarmEnabled == true,
			endRound = Hub.CoinFarm.endRoundEnabled == true,
			mode = Hub.CoinFarm.mode,
			position = Hub.CoinFarm.position,
			serverHopLowPlayers = Hub.CoinFarm.serverHopLowPlayers == true,
			serverHopThreshold = Hub.CoinFarm.serverHopPlayerThreshold,
			serverHopTimerMinutes = Hub.CoinFarm.serverHopTimerMinutes,
			antiBot = Hub.CoinFarm.antiBotEnabled == true,
			autoPrestige = Hub.AutoPrestige.enabled == true,
			autoClaimRewards = Hub.AutoClaimReward.enabled == true,
			blackScreen = Hub.CoinFarm.blackScreenEnabled == true,
			disable3D = Hub.CoinFarm.disable3DRendering == true,
			eventBox = Hub.EventBox and Hub.EventBox.selectedBox or nil,
			eventCurrency = Hub.EventBox and Hub.EventBox.selectedCurrency or nil,
			autoBuyBoxes = Hub.EventBox and Hub.EventBox.autoBuy == true or false,
		}

		arg.CustomData[str2] = flag7 and fn41(str5) == fn41(arg2)
		return true
	end

	local function fn47(arg)
		local customData = type(arg) == "table" and arg.CustomData
		local flag8 = type(customData) == "table" and customData[str4]
		if type(flag8) ~= "table" then
			return false
		end
		local endRoundEnabled = flag8.endRound == true
		local xpFarmEnabled = flag8.xpFarm == true and endRoundEnabled
		local mode = flag8.mode == "Tween" and "Tween" or "CFrame"
		local position = flag8.position == "Under" and "Under" or "Normal"
		Hub.CoinFarm.endRoundEnabled = endRoundEnabled
		Hub.CoinFarm.xpFarmEnabled = xpFarmEnabled
		Hub.CoinFarm.mode = mode
		Hub.CoinFarm.position = position
		Hub.CoinFarm.serverHopLowPlayers = flag8.serverHopLowPlayers == true
		Hub.CoinFarm.serverHopPlayerThreshold = math.clamp(math.floor(tonumber(flag8.serverHopThreshold) or 4), 1, 6)
		Hub.CoinFarm.serverHopTimerMinutes = math.clamp(math.floor(tonumber(flag8.serverHopTimerMinutes) or 15), 10, 30)
		Hub.CoinFarm.antiBotEnabled = flag8.antiBot == true
		Hub.CoinFarm.currentCoin = nil
		Hub.CoinFarm.CancelTween()

		if position ~= "Under" then
			Hub.CoinFarm.DisableUnder()
		end

		local function fn48(arg2, arg3)
			if arg2 and type(arg2.Set) == "function" then
				pcall(function()
					arg2:Set(arg3)
				end)
			end
		end

		local function fn49(arg2, arg3)
			if arg2 and type(arg2.Select) == "function" then
				pcall(function()
					arg2:Select(arg3)
				end)
			else
				fn48(arg2, arg3)
			end
		end

		fn48(Hub.CoinFarm.endRoundControl, endRoundEnabled)

		if type(Hub.CoinFarm.UpdateXPFarmLock) == "function" then
			Hub.CoinFarm.UpdateXPFarmLock()
		end

		fn48(Hub.CoinFarm.xpFarmControl, xpFarmEnabled)
		fn49(Hub.CoinFarm.modeControl, mode)
		fn49(Hub.CoinFarm.positionControl, position)
		fn48(Hub.CoinFarm.serverHopControl, Hub.CoinFarm.serverHopLowPlayers)
		fn48(Hub.CoinFarm.serverHopThresholdControl, Hub.CoinFarm.serverHopPlayerThreshold)
		fn48(Hub.CoinFarm.serverHopTimerControl, Hub.CoinFarm.serverHopTimerMinutes)
		fn48(Hub.CoinFarm.antiBotControl, Hub.CoinFarm.antiBotEnabled)
		Hub.AutoPrestige.SetEnabled(flag8.autoPrestige == true)
		fn48(Hub.AutoPrestige.control, Hub.AutoPrestige.enabled)
		Hub.AutoClaimReward.SetEnabled(flag8.autoClaimRewards ~= false)
		fn48(Hub.AutoClaimReward.control, Hub.AutoClaimReward.enabled)
		Hub.CoinFarm.SetBlackScreen(flag8.blackScreen == true, true)
		Hub.CoinFarm.Set3DRenderingDisabled(flag8.disable3D == true, true)
		fn48(Hub.CoinFarm.blackScreenControl, flag8.blackScreen == true)
		fn48(Hub.CoinFarm.renderingControl, flag8.disable3D == true)
		local eventBox = Hub.EventBox

		if type(eventBox) == "table" then
			if type(flag8.eventBox) == "string" and eventBox.boxes[flag8.eventBox] then
				eventBox.selectedBox = flag8.eventBox
				fn49(eventBox.boxDropdown, flag8.eventBox)
			end

			if type(flag8.eventCurrency) == "string" then
				eventBox.selectedCurrency = flag8.eventCurrency
				fn49(eventBox.currencyDropdown, flag8.eventCurrency)
			end

			fn48(eventBox.autoBuyControl, flag8.autoBuyBoxes == true)
		end

		fn48(Hub.CoinFarm.toggleControl, flag8.enabled == true)

		if flag8.enabled == true and not Hub.CoinFarm.enabled then
			Hub.CoinFarm.SetEnabled(true)
		end

		return true
	end

	local function fn48(arg, arg2)
		local v12 = fn43(arg2)
		if not v12 then
			return
		end
		arg.position = v12

		if arg.button and arg.button.Parent then
			arg.button.Position = v12
		end
	end

	local function fn49(arg)
		local flag8 = type(arg) == "table" and type(arg.CustomData) == "table" and arg.CustomData[str3] or nil
		if type(flag8) ~= "table" then
			return false
		end
		fn48(Hub.XRayButtonState, flag8.xray)
		fn48(Hub.AimlockButtonState, flag8.aimlock)
		fn48(Hub.GetGunButtonState, flag8.getGun)
		fn48(Hub.BombJumpButtonState, flag8.bombJump)
		fn48(Hub.ThrowKnifeButtonState, flag8.throwKnife)
		fn48(Hub.WallPhaseButtonState, flag8.wallPhase)
		fn48(Hub.FlyButtonState, flag8.fly)
		fn48(Hub.NoclipButtonState, flag8.noclip)
		fn48(Hub.QuickMenuState, flag8.quickMenu)
		local v12 = fn43(flag8.autoShoot)

		if v12 then
			Hub.AutoShootDragState.buttonPos = v12

			if Hub.AutoShootTouchButton and Hub.AutoShootTouchButton.Parent then
				Hub.AutoShootTouchButton.Position = v12
			end
		end

		return true
	end

	local function fn50()
		local tbl9 = {}
		local tbl10 = {}
		if type(configManager) ~= "table" or type(configManager.AllConfigs) ~= "function" then
			return tbl9
		end

		local ok, result = pcall(function()
			return configManager:AllConfigs()
		end)

		if ok and type(result) == "table" then
			for k, v12 in pairs(result) do
				if type(v12) ~= "string" then
					v12 = nil

					if type(k) == "string" then
						v12 = k
					end
				end

				if v12 then
					v12 = v12:match("([^/\\]+)$") or v12
					local v13 = fn41(v12)

					if not tbl10[v13] then
						tbl10[v13] = true
						table.insert(tbl9, v13)
					end
				end
			end
		end

		table.sort(tbl9)
		return tbl9
	end

	local function fn51()
		return fn50()
	end

	local function fn52(arg)
		local path = type(configManager) == "table" and type(configManager.Path) == "string" and configManager.Path or "WindUI/Foxname_MM2/config/"

		if not path:match("[/\\]$") then
			path ..= "/"
		end

		return path .. fn41(arg) .. ".json"
	end

	local function fn53()
		local path = type(configManager) == "table" and type(configManager.Path) == "string" and configManager.Path or "WindUI/Foxname_MM2/config/"

		if not path:match("[/\\]$") then
			path ..= "/"
		end

		return path .. "_foxname_autoload.txt"
	end

	local function fn54()
		local match = fn53():match("^(.*)[/\\][^/\\]+$")
		if not match or match == "" then
			return true
		end

		if type(isfolder) == "function" then
			local ok, result = pcall(isfolder, match)
			if ok and result then
				return true
			end
		end

		if type(makefolder) ~= "function" then
			return false
		end
		return pcall(makefolder, match)
	end

	local function fn55(arg)
		if type(readfile) ~= "function" then
			return nil
		end
		local v12 = fn52(arg)

		if type(isfile) == "function" then
			local ok, result = pcall(isfile, v12)
			if not ok or not result then
				return nil
			end
		end

		local ok, result = pcall(readfile, v12)
		if not ok or type(result) ~= "string" then
			return nil
		end
		local ok2, result2 = pcall(HttpService.JSONDecode, HttpService, result)
		return ok2 and type(result2) == "table" and result2 or nil
	end

	local function fn56(arg, arg2)
		if type(writefile) ~= "function" or type(arg2) ~= "table" then
			return false
		end
		local ok, result = pcall(HttpService.JSONEncode, HttpService, arg2)
		if not ok then
			return false
		end
		return pcall(writefile, fn52(arg), result)
	end

	local function fn57(arg)
		if type(arg) ~= "string" then
			return nil
		end
		local match, v12 = arg:match("^%s*([01])%s*\r?\n%s*(.-)%s*$")
		if not match then
			return nil
		end
		local v13 = fn41(v12)
		if match ~= "1" or v13 == "None" or v13 == "Disabled" then
			return false, "default"
		end
		return true, v13
	end

	local function fn58(arg)
		if type(readfile) ~= "function" then
			return nil
		end

		if type(isfile) == "function" then
			local ok, result = pcall(isfile, arg)
			if not ok or not result then
				return nil
			end
		end

		local ok, result = pcall(readfile, arg)
		if not ok then
			return nil
		end
		return fn57(result)
	end

	local function fn59()
		if type(writefile) ~= "function" then
			return false
		end

		if not fn54() then
			return false
		end
		local flag8 = flag7 == true
		local str6 = flag8 and fn41(str5) or "default"
		return pcall(writefile, fn53(), (flag8 and "1" or "0") .. "\n" .. str6)
	end

	local function fn60(arg)
		local v12 = fn41(arg)

		for _, v13 in ipairs(fn50()) do
			if fn41(v13) == v12 then
				return true
			end
		end

		return false
	end

	local function fn61()
		flag7 = false
		str5 = "default"
		local txt, v12 = fn58(fn53())
		local flag8 = false

		if txt == nil then
			txt, v12 = fn58("FoxnameMM2/auto_load_config.txt")
			flag8 = txt ~= nil
		end

		if txt ~= nil then
			if txt and fn60(v12) then
				flag7 = true
				str5 = fn41(v12)
				v9 = str5
			elseif txt then
				fn59()
			end

			if flag8 then
				fn59()
			end

			return flag7
		end

		for _, v13 in ipairs(fn50()) do
			local v14 = fn55(v13)
			local custom = v14 and v14.__custom

			if type(custom) == "table" and custom[str2] == true then
				flag7 = true
				str5 = fn41(v13)
				v9 = str5
				fn59()
				return true
			end
		end

		return false
	end

	local function fn62()
		local v12 = flag7 and fn41(str5) or nil
		local flag8 = v12 == nil or fn60(v12)

		for _, v13 in ipairs(fn50()) do
			local v14 = fn55(v13)

			if v14 then
				if type(v14.__custom) ~= "table" then
					v14.__custom = {}
				end

				v14.__custom[str2] = v12 ~= nil and fn41(v13) == v12
				fn56(v13, v14)
			end
		end

		return fn59() and flag8
	end

	fn61()

	local function fn63(arg)
		local v12 = fn41(arg)

		for _, v13 in ipairs(fn50()) do
			if v13 == v12 then
				return true
			end
		end

		return false
	end

	local function fn64()
		local tbl9 = { "None" }

		for _, v12 in ipairs(fn50()) do
			table.insert(tbl9, v12)
		end

		local str6 = "None"

		if flag7 and fn63(str5) then
			str6 = fn41(str5)
		elseif flag7 then
			flag7 = false
			str5 = "default"
			fn62()
		end

		if v11 then
			pcall(function()
				v11:Refresh(tbl9)
			end)

			pcall(function()
				v11:Select(str6)
			end)
		end
	end

	local function fn65(arg)
		local v12 = fn51()
		arg = arg or v9
		arg = arg and fn41(arg) or nil
		local flag8 = false

		for _, v13 in ipairs(v12) do
			if v13 == arg then
				flag8 = true
				break
			end
		end

		v9 = flag8 and arg or v12[1]

		if v10 then
			pcall(function()
				v10:Refresh(v12)
			end)

			pcall(function()
				v10:Select(v9)
			end)
		end
	end

	local function fn66(arg)
		if type(configManager) ~= "table" or type(configManager.CreateConfig) ~= "function" then
			return nil
		end

		local ok, result = pcall(function()
			return configManager:CreateConfig(fn41(arg))
		end)

		return ok and result or nil
	end

	local function fn67(arg)
		if not arg then
			return false, "Config manager is unavailable"
		end

		local ok, result = pcall(function()
			return arg:Save()
		end)

		if ok and result ~= false then
			return true
		end

		if type(writefile) ~= "function" or type(arg.Path) ~= "string" or type(configManager) ~= "table" or type(configManager.Parser) ~= "table" then
			return false, tostring(result)
		end

		if type(Window.PendingFlags) == "table" and type(arg.Register) == "function" then
			for k, pendingFlag in pairs(Window.PendingFlags) do
				pcall(function()
					arg:Register(k, pendingFlag)
				end)
			end
		end

		local tbl9 = {
			__version = tonumber(arg.Version) or 1.2,
			__elements = {},
			__autoload = arg.AutoLoad == true,
			__custom = type(arg.CustomData) == "table" and arg.CustomData or {},
		}

		local v12 = pairs
		local elements = arg.Elements or {}

		for k, element in v12(elements) do
			local flag8 = type(element) == "table" and configManager.Parser[element.__type] or nil

			if flag8 and type(flag8.Save) == "function" then
				local ok2, result2 = pcall(flag8.Save, element)

				if ok2 then
					local HttpService2 = game:GetService("HttpService")

					if pcall(HttpService2.JSONEncode, HttpService2, result2) then
						tbl9.__elements[tostring(k)] = result2
					end
				end
			end
		end

		local HttpService2 = game:GetService("HttpService")
		local ok2, result2 = pcall(HttpService2.JSONEncode, HttpService2, tbl9)
		if not ok2 then
			return false, tostring(result2)
		end
		local ok3, result3 = pcall(writefile, arg.Path, result2)
		return ok3, ok3 and nil or tostring(result3)
	end

	Tabs.Settings:Input({
		Title = "Config Name",
		Value = "default",
		Placeholder = "default",
		Callback = function(arg)
			str = fn41(arg)
		end,
	})

	v10 = Tabs.Settings:Dropdown({
		Title = "Selected Config",
		Values = fn51(),
		Value = v9,
		AllowNone = true,
		Callback = function(arg)
			if arg then
				v9 = fn41(arg)
			else
				v9 = nil
			end
		end,
	})

	local function fn68()
		local str6 = flag7 and fn63(str5) and fn41(str5) or "None"
		local tbl9 = { "None" }

		for _, v12 in ipairs(fn50()) do
			table.insert(tbl9, v12)
		end

		v11 = Tabs.Settings:Dropdown({
			Title = "Auto Load Config",
			Values = tbl9,
			Value = str6,
			AllowNone = false,
			Callback = function(arg)
				if type(arg) == "table" then
					arg = arg[1] or next(arg)
				end

				local str7 = tostring(arg or "None")

				if str7 == "None" or str7 == "Disabled" then
					flag7 = false
					str5 = "default"
				else
					flag7 = true
					str5 = fn41(str7)
				end

				if not fn62() and flag7 then
					flag7 = false
					str5 = "default"
					task.defer(fn64)

					WindUI:Notify({
						Title = "Config Error",
						Content = "Executor file storage is unavailable",
						Icon = "x",
						Duration = 2,
					})
				end
			end,
		})
	end

	fn68()

	Tabs.Settings:Button({
		Title = "Save Config",
		Callback = function()
			local v12 = fn41(str)
			local v13 = fn66(v12)
			local v14 = fn46(v13, v12)
			local v15, v16 = fn67(v13)

			if v15 then
				v9 = v12
				fn65(v12)
				fn64()

				WindUI:Notify({
					Title = "Config Saved",
					Content = v14 and v12 or v12 .. " (custom data could not be saved)",
					Icon = v14 and "check" or "triangle-alert",
					Duration = 2,
				})
			else
				WindUI:Notify({
					Title = "Config Error",
					Content = "Could not save config: " .. tostring(v16 or "unknown error"),
					Icon = "x",
					Duration = 3,
				})
			end
		end,
	})

	Tabs.Settings:Button({
		Title = "Load Selected Config",
		Callback = function()
			if not v9 then
				WindUI:Notify({ Title = "Config Error", Content = "No config selected", Icon = "x", Duration = 2 })
				return
			end
			local v12 = fn41(v9)
			local v13 = fn66(v12)
			local result = nil
			local flag8 = false

			if v13 then
				flag8, result = pcall(function()
					return v13:Load()
				end)
			end

			if flag8 and result ~= false then
				fn49(v13)
				fn47(v13)

				task.defer(function()
					fn49(v13)
				end)

				task.defer(function()
					if Hub.SyncConfigColorValues then
						Hub.SyncConfigColorValues()
					end
				end)

				if nowUsingTheme then
					pcall(function()
						WindUI:SetTheme(nowUsingTheme)
					end)
				end

				WindUI:Notify({ Title = "Config Loaded", Content = v12, Icon = "check", Duration = 2 })
			else
				WindUI:Notify({ Title = "Config Error", Content = "Could not load config", Icon = "x", Duration = 2 })
			end
		end,
	})

	Tabs.Settings:Button({
		Title = "Delete Selected Config",
		Callback = function()
			if not v9 then
				WindUI:Notify({ Title = "Config Error", Content = "No config selected", Icon = "x", Duration = 2 })
				return
			end
			local v12 = fn41(v9)
			local v13 = fn66(v12)
			local flag8 = flag7 and fn41(str5) == v12
			local result = nil
			local flag9 = false

			if v13 then
				flag9, result = pcall(function()
					return v13:Delete()
				end)
			end

			if flag9 and result == true then
				v9 = nil
				fn65(nil)

				if flag8 then
					flag7 = false
					str5 = "default"
				end

				fn64()
				WindUI:Notify({ Title = "Config Deleted", Content = v12, Icon = "trash-2", Duration = 2 })
			else
				WindUI:Notify({ Title = "Config Error", Content = "Could not delete config", Icon = "x", Duration = 2 })
			end
		end,
	})

	Tabs.Settings:Button({
		Title = "Refresh Config List",
		Callback = function()
			fn65(v9)
			fn64()
		end,
	})

	Hub.ApplyAutoLoadConfig = function()
		if not flag7 then
			return false
		end
		local v12 = fn41(str5)

		if v12 == "None" or v12 == "Disabled" then
			flag7 = false
			str5 = "default"
			fn62()
			fn64()
			return false
		end

		local v13 = fn66(v12)
		local result = nil
		local flag8 = false

		if v13 then
			flag8, result = pcall(function()
				return v13:Load()
			end)
		end

		if flag8 and result ~= false then
			fn49(v13)
			fn47(v13)

			task.defer(function()
				fn49(v13)
			end)

			task.defer(function()
				if Hub.SyncConfigColorValues then
					Hub.SyncConfigColorValues()
				end
			end)

			v9 = v12
			fn65(v12)

			if nowUsingTheme then
				pcall(function()
					WindUI:SetTheme(nowUsingTheme)
				end)
			end

			fn64()
			WindUI:Notify({ Title = "Config Auto Loaded", Content = v12, Icon = "check", Duration = 2 })
			return true
		end

		flag7 = false
		str5 = "default"
		fn62()
		fn64()
		WindUI:Notify({ Title = "Config Error", Content = "Auto-load config not found: " .. v12, Icon = "x", Duration = 2 })
		return false
	end

	fn65(v9)
	fn64()
end

task.wait(UI_BUILD_DELAY)
fn39()

local function fn40()
	local v9 = nil
	local v10 = nil

	local tbl7 = {
		target = nil,
		player = nil,
		character = nil,
		lastFOV = nil,
		lastFOVColorAt = 0,
		rayParams = RaycastParams.new(),
		rayFilterCharacter = nil,
	}

	local str = "Foxname_MM2_Aim_" .. sessionId
	local flag7 = false

	local function fn41()
		if v9 and v9.Parent then
			return
		end
		local frame = Instance.new("Frame")
		frame.Name = "FOVCircle"
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.fromScale(0.5, 0.5)
		frame.Visible = false
		frame.ZIndex = 20
		frame.Parent = createScreenGui()
		local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
		uiAspectRatioConstraint.AspectRatio = 1
		uiAspectRatioConstraint.Parent = frame
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(1, 0)
		uiCorner.Parent = frame
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Thickness = 2
		uiStroke.Color = Color3.fromRGB(255, 255, 255)
		uiStroke.Parent = frame
		v9 = frame
		v10 = uiStroke
	end

	local function fn42()
		if not Hub.AimEnabled then
			return false
		end
		local character_ = localPlayer.Character
		local humanoid = character_ and character_:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = character_ and character_:FindFirstChild("HumanoidRootPart")
		if not (character_ and humanoid and humanoid.Health > 0 and humanoidRootPart and humanoidRootPart.Parent) then
			return false
		end

		if Hub.OnlyAimWhileSheriff then
			local backpack = localPlayer:FindFirstChildOfClass("Backpack")
			if not (character_:FindFirstChild("Gun") ~= nil or backpack and backpack:FindFirstChild("Gun") ~= nil) and fn27(localPlayer) ~= "Sheriff" then
				return false
			end
		end

		return true
	end

	local function fn43(arg)
		if not arg then
			return nil
		end
		local aimlockPart = Hub.AimlockPart or "Head"
		if aimlockPart == "HumanoidRootPart" then
			return arg:FindFirstChild("HumanoidRootPart") or arg:FindFirstChild("UpperTorso") or arg:FindFirstChild("Torso") or arg:FindFirstChild("Head")
		end

		if aimlockPart == "Torso" then
			return arg:FindFirstChild("UpperTorso") or arg:FindFirstChild("Torso") or arg:FindFirstChild("HumanoidRootPart") or arg:FindFirstChild("Head")
		end
		return arg:FindFirstChild("Head") or arg:FindFirstChild("UpperTorso") or arg:FindFirstChild("HumanoidRootPart")
	end

	local function fn44(rayFilterCharacter, arg, arg2)
		if Hub.IgnoreWalls then
			return true
		end
		local position = currentCamera.CFrame.Position
		local rayParams = tbl7.rayParams

		if tbl7.rayFilterCharacter ~= rayFilterCharacter then
			tbl7.rayFilterCharacter = rayFilterCharacter
			rayParams.FilterDescendantsInstances = { rayFilterCharacter }
			rayParams.FilterType = Enum.RaycastFilterType.Exclude
		end

		local hit = workspace:Raycast(position, arg2 - position, rayParams)
		return not hit or hit.Instance:IsDescendantOf(arg)
	end

	local function fn45()
		tbl7.target = nil
		tbl7.player = nil
		tbl7.character = nil
	end

	local function fn46()
		if not fn42() then
			fn45()
			return nil
		end
		local v11 = fn30()
		if not v11 or v11 == localPlayer then
			fn45()
			return nil
		end
		local character_ = v11.Character
		local humanoid = character_ and character_:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = character_ and character_:FindFirstChild("HumanoidRootPart")
		if not (character_ and humanoid and humanoid.Health > 0 and humanoidRootPart and humanoidRootPart.Parent) then
			fn45()
			return nil
		end
		local v12 = fn43(character_)
		if not (v12 and v12:IsA("BasePart")) then
			fn45()
			return nil
		end
		local v13, v14 = currentCamera:WorldToViewportPoint(v12.Position)
		if not v14 or v13.Z <= 0 then
			fn45()
			return nil
		end
		local n2 = currentCamera.ViewportSize / 2
		local n3 = tonumber(Hub.FOV) or 100

		if tbl7.target == v12 then
			n3 *= 1.7
		end

		if n3 < (Vector2.new(v13.X, v13.Y) - n2).Magnitude then
			fn45()
			return nil
		end
		local character_2 = localPlayer.Character
		if not (character_2 and fn44(character_2, character_, v12.Position)) then
			fn45()
			return nil
		end
		tbl7.target = v12
		tbl7.player = v11
		tbl7.character = character_
		return v12
	end

	local function fn47()
		fn41()
		local visible = Hub.AimEnabled and not Hub.HideFOV
		v9.Visible = visible

		if visible then
			local now = os.clock()

			if (UserInputService.TouchEnabled and 0.05 or 0.033333333333333333) <= now - tbl7.lastFOVColorAt then
				tbl7.lastFOVColorAt = now
				v10.Color = Color3.fromHSV(now * 0.35 % 1, 1, 1)
			end

			if Hub.FOV ~= tbl7.lastFOV then
				tbl7.lastFOV = Hub.FOV
				v9.Size = UDim2.new(0, Hub.FOV * 2, 0, Hub.FOV * 2)
				v9.Position = UDim2.fromScale(0.5, 0.5)
			end
		end

		if Hub.AimEnabled then
			local v11 = fn46()

			if v11 and v11:IsA("BasePart") then
				if Hub.AimStyle == "Aimlock" then
					currentCamera.CFrame = CFrame.lookAt(currentCamera.CFrame.Position, v11.Position, Vector3.new(0, 1, 0))
				end
			end
		else
			fn45()
		end
	end

	Hub.UpdateAimBinding = function()
		if Hub.AimEnabled then
			if flag7 then
				return
			end

			pcall(function()
				RunService:UnbindFromRenderStep(str)
			end)

			RunService:BindToRenderStep(str, Enum.RenderPriority.Camera.Value + 1, fn47)
			flag7 = true
			return
		end

		if flag7 then
			pcall(function()
				RunService:UnbindFromRenderStep(str)
			end)

			flag7 = false
		end

		fn45()

		if v9 then
			v9.Visible = false
		end
	end

	local v11 = nil
	local flag8 = true

	if silentAimSupported then
		flag8 = pcall(function()
			local function fn48(arg, ...)
				local v12 = table.pack(...)
				local v13 = getnamecallmethod()
				local tbl8 = { ... }
				local flag9 = not (type(checkcaller) == "function" and checkcaller() or false)
				local flag10

				if flag9 then
					flag10 = v13 == "FireServer" or v13 == "fireServer"
				else
					flag10 = flag9
				end

				if flag10 and typeof(arg) == "Instance" and arg.Name == "Shoot" then
					if Hub.AimEnabled and (Hub.AimStyle == "Silent Aim" or Hub.AimStyle == "Aimlock") then
						local v14 = fn46()

						if v14 and v14:IsA("BasePart") then
							local parent = v14.Parent
							local humanoid = parent and parent:FindFirstChildOfClass("Humanoid")
							parent = parent and (parent:FindFirstChild("HumanoidRootPart") or v14)
							local n2 = math.clamp(localPlayer:GetNetworkPing(), 0.02, 0.22)
							parent = parent and parent.AssemblyLinearVelocity or v14.AssemblyLinearVelocity or Vector3.zero

							if parent.Magnitude > 65 then
								parent = parent.Unit * 65
							end

							local moveDirection = humanoid and humanoid.MoveDirection or Vector3.zero
							local walkSpeed

							if humanoid and humanoid.WalkSpeed > 0 then
								walkSpeed = humanoid.WalkSpeed
							else
								walkSpeed = 16
							end

							if moveDirection.Magnitude > 0.1 then
								parent = Vector3.new(moveDirection.X * walkSpeed, parent.Y * 0.65, moveDirection.Z * walkSpeed)
							end

							local n3 = v14.Position + parent * (n2 * 0.9 + (Hub.PredictionStrength or 5) * 10 / 1000)

							if Hub.AutoShootState.mode == "Behind Walls" or Hub.AutoShootState.mode == "Wallbang" then
								tbl8[1] = CFrame.new(n3 + Vector3.new(0, 1.2, 0))
							end

							tbl8[2] = CFrame.new(n3)
							return v11(arg, unpack(tbl8))
						end
					end
				end

				return v11(arg, table.unpack(v12, 1, v12.n))
			end

			if typeof(newcclosure) == "function" then
				v11 = hookmetamethod(game, "__namecall", newcclosure(fn48))
			else
				v11 = hookmetamethod(game, "__namecall", fn48)
			end
		end)
	end

	if silentAimSupported and (not flag8 or type(v11) ~= "function") then
		silentAimSupported = false
	end

	local n2 = 0

	local function fn48(child)
		if child:IsA("Tool") and child.Name == "Gun" then
			child.Activated:Connect(function()
				if Hub.AimEnabled then
					local now = os.clock()

					if now - n2 > 0.25 then
						n2 = now

						if Hub.TriggerAutoShootInput then
							Hub.TriggerAutoShootInput()
						elseif Hub.UpdateAutoShoot then
							Hub.UpdateAutoShoot()
						end
					end
				end
			end)
		end
	end

	localPlayer.CharacterAdded:Connect(function(character_)
		character_.ChildAdded:Connect(fn48)
		local backpack = localPlayer:FindFirstChildOfClass("Backpack")

		if backpack then
			for _, v12 in backpack:GetChildren() do
				fn48(v12)
			end

			backpack.ChildAdded:Connect(fn48)
		end
	end)

	if localPlayer.Character then
		localPlayer.Character.ChildAdded:Connect(fn48)
	end

	local backpack = localPlayer:FindFirstChildOfClass("Backpack")

	if backpack then
		for _, v12 in backpack:GetChildren() do
			fn48(v12)
		end

		backpack.ChildAdded:Connect(fn48)
	end

	Hub.UpdateAimBinding()
end

fn40()

do
	local function fn41()
		local character_ = localPlayer.Character
		if not character_ then
			return nil
		end
		local gun = character_:FindFirstChild("Gun")
		if gun and gun:IsA("Tool") then
			return gun
		end
		local humanoid = character_:FindFirstChildOfClass("Humanoid")
		local backpack = localPlayer:FindFirstChildOfClass("Backpack")
		local gun2 = backpack and backpack:FindFirstChild("Gun")
		if not (humanoid and gun2 and gun2:IsA("Tool")) then
			return nil
		end

		pcall(function()
			humanoid:EquipTool(gun2)
		end)

		for i = 1, 6 do
			local gun3 = character_:FindFirstChild("Gun")
			if gun3 and gun3:IsA("Tool") then
				return gun3
			end
			task.wait(0.02)
		end

		return character_:FindFirstChild("Gun") or gun2
	end

	local function fn42(arg, arg2)
		local rightHand = arg:FindFirstChild("RightHand") or arg:FindFirstChild("Right Arm")
		if rightHand and rightHand:IsA("BasePart") then
			return rightHand.CFrame
		end
		local gunRaycastAttachment = arg2:FindFirstChild("GunRaycastAttachment") or arg2:FindFirstChild("GunRaycastAttachment", true)
		if gunRaycastAttachment and gunRaycastAttachment:IsA("Attachment") then
			return gunRaycastAttachment.WorldCFrame
		end
		return CFrame.new(arg2.Position + Vector3.new(0, 0.5, 0))
	end

	local function fn43(arg, arg2)
		local character_ = localPlayer.Character
		if not character_ or typeof(arg) ~= "Vector3" then
			return false
		end
		local gun = fn41()
		if not gun then
			return false
		end
		local humanoid = character_:FindFirstChildOfClass("Humanoid")

		if gun.Parent ~= character_ and humanoid then
			pcall(function()
				humanoid:EquipTool(gun)
			end)

			task.wait(0.05)
			gun = character_:FindFirstChild("Gun") or gun
		end

		local shoot = gun:FindFirstChild("Shoot") or gun:FindFirstChild("Shoot", true)
		if not shoot or not shoot:IsA("RemoteEvent") then
			return false
		end
		local lastShotAt = Hub.AutoShootState.lastShotAt
		if os.clock() - lastShotAt < Hub.AutoShootState.cooldown then
			return false
		end
		local humanoidRootPart = character_:FindFirstChild("HumanoidRootPart")
		if not humanoidRootPart then
			return false
		end
		arg2 = arg2 or Hub.AutoShootState.mode
		local cframe

		if arg2 == "Behind Walls" or arg2 == "Wallbang" or arg2 == "Behind Walls(inaccurate)" then
			cframe = CFrame.new(arg + Vector3.new(0, 1.2, 0))
		else
			cframe = fn42(character_, humanoidRootPart)
		end

		local v9 = cframe
		local cframe2 = CFrame.new(arg)
		if not pcall(function()
			shoot:FireServer(v9, cframe2)
		end) then
			return false
		end
		Hub.AutoShootState.lastShotAt = os.clock()
		return true
	end

	Hub.UpdateAutoShoot = function(arg, arg2)
		local character_ = localPlayer.Character
		if not character_ then
			return false
		end
		local flag7 = character_:FindFirstChild("Gun") ~= nil
		local flag8

		if flag7 then
			flag8 = flag7
		else
			flag8 = localPlayer:FindFirstChildOfClass("Backpack") and localPlayer.Backpack:FindFirstChild("Gun") ~= nil
		end

		if not flag8 then
			local v9 = fn31()
			if v9 and v9 ~= localPlayer then
				return false
			end

			if fn28(localPlayer) ~= "Sheriff" then
				return false
			end
		end

		arg2 = arg2 or fn30()
		if not arg2 or not arg2.Character then
			return false
		end

		local character_2 = arg2.Character
		local humanoid = character_2:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health <= 0 then
			return false
		end
		local humanoidRootPart = character_2:FindFirstChild("HumanoidRootPart")
		local aimlockPart = Hub.AimlockPart or Hub.AutoShootState.part or "Head"
		local torso = character_2:FindFirstChild(aimlockPart)

		if not torso and aimlockPart == "UpperTorso" then
			torso = character_2:FindFirstChild("Torso")
		elseif not torso and aimlockPart == "Torso" then
			torso = character_2:FindFirstChild("UpperTorso")
		end

		local head = torso or humanoidRootPart or character_2:FindFirstChild("Head")
		if not (humanoidRootPart and head and head:IsA("BasePart")) then
			return false
		end
		arg = arg or Hub.AutoShootState.mode
		local n2 = math.clamp(localPlayer:GetNetworkPing(), 0.02, 0.22)
		local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity or head.AssemblyLinearVelocity or Vector3.zero

		if assemblyLinearVelocity.Magnitude > 65 then
			assemblyLinearVelocity = assemblyLinearVelocity.Unit * 65
		end

		local moveDirection = humanoid and humanoid.MoveDirection or Vector3.zero
		local walkSpeed

		if humanoid and humanoid.WalkSpeed > 0 then
			walkSpeed = humanoid.WalkSpeed
		else
			walkSpeed = 16
		end

		if moveDirection.Magnitude > 0.1 then
			assemblyLinearVelocity = Vector3.new(moveDirection.X * walkSpeed, assemblyLinearVelocity.Y * 0.65, moveDirection.Z * walkSpeed)
		end

		return fn43(head.Position + assemblyLinearVelocity * (n2 * 0.9 + (Hub.PredictionStrength or 5) * 10 / 1000), arg)
	end

	Hub.TriggerAutoShootInput = function()
		local autoShootState = Hub.AutoShootState
		local now = os.clock()
		if now < autoShootState.nextInputAt then
			return false
		end
		autoShootState.nextInputAt = now + 0.15
		if Hub.UpdateAutoShoot then
			return Hub.UpdateAutoShoot()
		end
		return false
	end

	Hub.ToggleAutoShoot = function(arg)
		Hub.TouchButtons.ToggleAutoShootButton(arg)
	end

	Hub.CoinFarm.shootMurderer = function(arg)
		if arg and Hub.CoinFarm.endRoundGeneration ~= arg then
			return false
		end
		local v9 = Hub.CoinFarm.GetCachedRole(localPlayer)
		if Hub.CoinFarm.endRoundDeathRequested or v9 ~= "Sheriff" then
			return false
		end

		if not fn41() then
			return false
		end
		return Hub.UpdateAutoShoot and Hub.UpdateAutoShoot("Behind Walls")
	end
end

Hub.SetupInfiniteJump = function()
	if Hub.JumpConnection then
		Hub.JumpConnection:Disconnect()
	end

	Hub.JumpConnection = UserInputService.JumpRequest:Connect(function()
		if not Hub.InfiniteJumpEnabled then
			return
		end
		local character_ = localPlayer.Character
		if not character_ then
			return
		end
		local humanoid = character_:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end)
end

Hub.ToggleInfiniteJump = function(infiniteJumpEnabled)
	Hub.InfiniteJumpEnabled = infiniteJumpEnabled

	if infiniteJumpEnabled then
		Hub.SetupInfiniteJump()
	elseif Hub.JumpConnection then
		Hub.JumpConnection:Disconnect()
		Hub.JumpConnection = nil
	end
end

task.spawn(function()
	RunService.Heartbeat:Wait()

	if foxnameMM2Runtime.alive and not isTerminated then
		if Hub.ApplyAutoLoadConfig then
			Hub.ApplyAutoLoadConfig()
		end

		Hub.CoinFarm.ApplyResume()
	end
end)

task.spawn(function()
	while true do
		if foxnameMM2Runtime.alive and not isTerminated then
			task.wait(30)

			if not (not foxnameMM2Runtime.alive or false) then
				cleanupDeadConns()

				for k in pairs(Hub.NoclipParts) do
					if not k or not k.Parent then
						Hub.NoclipParts[k] = nil
					end
				end

				for k, partConnection in pairs(Hub.HitboxExpander.partConnections) do
					if not k or not k.Parent then
						if type(partConnection) == "table" then
							for _, v9 in pairs(partConnection) do
								if v9 and v9.Connected then
									v9:Disconnect()
								end
							end
						elseif partConnection and partConnection.Connected then
							partConnection:Disconnect()
						end

						Hub.HitboxExpander.partConnections[k] = nil
						Hub.HitboxExpander.originals[k] = nil
					end
				end

				for k in pairs(Hub.HitboxExpander.originals) do
					if not k or not k.Parent then
						Hub.HitboxExpander.originals[k] = nil
					end
				end

				for k in pairs(Hub.AutoGunTouchPending) do
					if not k or not k.Parent then
						Hub.AutoGunTouchPending[k] = nil
					end
				end

				for k in pairs(Hub.CoinFarm.retryUntil) do
					if not k or not k.Parent then
						Hub.CoinFarm.retryUntil[k] = nil
						Hub.CoinFarm.contactAttempts[k] = nil
						Hub.CoinFarm.coins[k] = nil
					end
				end

				for k, v9 in pairs(Hub.GunESPTable) do
					if not k or not k.Parent then
						if v9.TouchedConnection and v9.TouchedConnection.Connected then
							v9.TouchedConnection:Disconnect()
						end

						fn15(v9.Line)

						if v9.Billboard then
							v9.Billboard:Destroy()
						end

						if v9.Arrow then
							v9.Arrow:Destroy()
						end

						if v9.ArrowDistance then
							v9.ArrowDistance:Destroy()
						end

						Hub.GunESPTable[k] = nil
					end
				end

				for k in pairs(Hub.ESPTable) do
					if not k or not k.Parent then
						fn32(k)
						local v9 = Hub.ESPPlayerConnections[k]

						if v9 then
							v9:Disconnect()
						end

						Hub.ESPPlayerConnections[k] = nil
					end
				end

				for k, frozenPlayer in pairs(Hub.FrozenPlayers) do
					if not k or k.Parent ~= Players or not frozenPlayer or not frozenPlayer.Parent then
						Hub.FrozenPlayers[k] = nil
						Hub.FrozenPlayerReleaseIds[k] = nil
					end
				end

				for k, knifeAuraFrozenPlayer in pairs(Hub.KnifeAuraFrozenPlayers) do
					if not k or k.Parent ~= Players or not knifeAuraFrozenPlayer or not knifeAuraFrozenPlayer.Parent then
						Hub.KnifeAuraFrozenPlayers[k] = nil
					end
				end

				continue
			end
		end

		break
	end
end)

task.spawn(function()
	while foxnameMM2Runtime.alive and not isTerminated and not Hub.MM2StartupDataReady do
		task.wait(0.1)
	end

	if not foxnameMM2Runtime.alive then
		return
	end
	RunService.Heartbeat:Wait()

	WindUI:Notify({
		Title = "Welcome user!",
		Content = "Enjoy unlimited fun with us ^^",
		Icon = "check",
		Duration = 1.5,
	})
end)

