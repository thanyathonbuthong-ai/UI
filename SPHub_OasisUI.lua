local t1 = {}
local v2 = unpack or table.unpack
t1.value1 = "SPHub_FirstTime.txt"
getgenv().SPHubIsFirstTime = false
pcall(function()
    if not isfile(t1.value1) then
        getgenv().SPHubIsFirstTime = true
        writefile(t1.value1, "played")
        task.spawn(function()
            task.wait(1)
            game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "SP Hub",
				Text = "First time using SP Hub! Enjoy the script without ads.",
				Duration = 7
			})
        end)
    end
end)

if not getgenv().SPHubIsFirstTime then
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/as6cd0/SP_Hub/refs/heads/main/DiscordADgui"))()
        game:GetService("CoreGui"):FindFirstChild("DiscordAdUI")

        repeat
            task.wait(1)
        until not game:GetService("CoreGui"):FindFirstChild("DiscordAdUI")
    end)
end
do
    local _isActive = isActive
    local _running = running
    local _carKillConnection = carKillConnection
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local UserInputService = game:GetService("UserInputService")
    local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local CurrentCamera = workspace.CurrentCamera
    local StarterGui = game:GetService("StarterGui")
    local LocalPlayer2 = game:GetService("Players").LocalPlayer
    local HttpService = game:GetService("HttpService")
    local MarketplaceService = game:GetService("MarketplaceService")
    local t2 = {
		f = 0,
		b = 0,
		l = 0,
		r = 0
	}
    local color3 = Color3.fromRGB(255, 0, 0)
    local v18 = game.Players.LocalPlayer.Character and (not not game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character.Humanoid.WalkSpeed) or 16
    local v19 = game.Players.LocalPlayer.Character and (not not game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character.Humanoid.JumpPower) or 50
    local vector3 = Vector3.new(2, 0, 0)

    t1.value2 = {
		antispy = true,
		CurrentLanguage = "en",
		TPoriginalSEC = 0.6,
		deletecoucSEC = 0.5,
		disableCatchKill = false,
		SpeedBang = 0.1,
		_isActive,
		_running,
		_carKillConnection,
		antiCrashConnection = nil,
		descendantAddedConn = nil,
		DistancePlayerForKill = 250,
		WaitForKillNext = 3,
		Players = Players,
		Workspace = Workspace,
		UserInputService = UserInputService,
		ReplicatedStorage = ReplicatedStorage2,
		RunService = RunService,
		camera = CurrentCamera,
		StarterGui = StarterGui,
		player = LocalPlayer2,
		HttpService = HttpService,
		MarketplaceService = MarketplaceService,
		character = nil,
		humanoid = nil,
		part = nil,
		flying = false,
		flightSpeed = 50,
		ctrl = t2,
		bg = nil,
		bv = nil,
		renderConn = nil,
		inputConn = nil,
		autoChangeWheelEnabled = false,
		wheelLoop = nil,
		speed = 0,
		maxSpeed = 120,
		acceleration = 5,
		deceleration = 4,
		turboSpeed = 250,
		turboAcceleration = 8,
		turboActive = false,
		moveForward = false,
		moveBackward = false,
		ESPColor = color3,
		originalFov = 70,
		originalSpeed = v18,
		originalJumpPower = v19,
		FlingToggle = nil,
		AntiFlingToggle = nil,
		antiFlingWasEnabled = nil,
		shiftLockEnabled = false,
		shiftLockActive = false,
		cameraOffset = vector3,
		SpamTextSpeed = 1.5,
		spamText = "Hello!",
		isSpamming = false,
		SpeedChange = 0.6,
		viewEnabled = false,
		selectedViewPlayer = nil,
		characterAddedConnection = nil,
		userInputCF = "",
		oscillateActive = false,
		antiVoidConnection = nil,
		plrcount = 0,
		TargetToolName = "Target Player",
		antiSitActive = false,
		filename = "preset_emotes.json",
		presetEmotes = {},
		emoteNames = {},
		selectedName = "",
		customEmoteId = nil,
		addEmoteInput = nil
	}
end
t1.value3 = game:GetService("HttpService")
t1.value4 = game:GetService("RunService")
t1.value5 = game:GetService("Players")
t1.value6 = game.Players.LocalPlayer
t1.value7 = t1.value6.Character
local v24
do
    local LocalPlayer3 = t1.value5.LocalPlayer

    t1.value8 = game:GetService("UserInputService")
    t1.value9 = loadstring(game:HttpGet("https://raw.githubusercontent.com/as6cd0/ScriptsMoudle/main/Brookhaven-Translate.lua"))()
    _G.SP_Hub_TKeys = {}

    function _G.SP_Hub_Translator(p1)
        local _tostring = tostring

        if not p1 then
            p1 = ""
        end

        local v309 = _tostring(p1)

        return t1.value9[v309] and t1.value9[v309][t1.value2.CurrentLanguage] or v309
    end
    function t1.value10(p2)
        local _tostring = tostring

        if not p2 then
            p2 = ""
        end

        local v312 = _tostring(p2)
        local v313 = _G.SP_Hub_Translator(v312)

        _G.SP_Hub_TKeys[tostring(v313)] = v312
        _G.SP_Hub_TKeys[v312] = v312

        return v313
    end

    t1.value11 = {
		API_URL = "https://sphub.lol/api/check",
		GET_KEY_URL = "https://sphub.lol/get-key",
		KEY_FILE = "sphub_key.txt",
		savedKey = ""
	}

    function t1.value12(p3, p4, p5)
        local v317 = p3
        local _tostring = tostring
        if not p3 then
            v317 = "SP Hub"
        end
        local v319 = _tostring(v317)
        local str = tostring(p4 or "")
        local t3 = {
			Name = v319,
			Content = str,
			Time = p5 or 5
		}
        if type(splib) == "table" and type(splib.MakeNotification) == "function" and pcall(function()
            splib:MakeNotification(t3)
        end) then
            return
        end
        local _tostring2 = tostring
        if not p3 then
            p3 = "SP Hub"
        end
        local v323 = _tostring2(p3)
        local _tostring3 = tostring
        if not p4 then
            p4 = ""
        end
        local v325 = _tostring3(p4)
        local v326 = p5 or 5
        local t4 = {
			Title = v323,
			Text = v325,
			Duration = v326
		}
        local u328 = t4
        if pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", u328)
        end) then
            return
        end
        warn("[SP Hub] " .. u328.Title .. ": " .. u328.Text)
    end
    function t1.value13(p6, p7)
        local v331 = false

        if type(setclipboard) == "function" then
            v331 = pcall(setclipboard, p6)
        elseif type(toclipboard) == "function" then
            v331 = pcall(toclipboard, p6)
        end

        if v331 then
            t1.value12("Link Copied", tostring(p7 or "Link") .. " copied to clipboard.", 5)

            return
        end

        t1.value12("Clipboard", "Clipboard API is unavailable in this runtime.", 5)
        print("[SP Hub] " .. tostring(p7 or "Link") .. ": " .. tostring(p6))
    end
    function t1.value14(p8, p9)
        if type(p9) ~= "function" then
            return p9
        end

        return function(...)
            local success, result = pcall(p9, ...)
            if not success then
                warn("[SP Hub] UI callback failed [" .. tostring(p8) .. "]: " .. tostring(result))
                t1.value12("UI Error", tostring(p8) .. " failed. Check console.", 5)
            end
        end
    end
    function t1.value15()
        if type(request) == "function" then
            return request
        end

        if type(http_request) == "function" then
            return http_request
        end

        if type(syn) == "table" and type(syn.request) == "function" then
            return syn.request
        end

        if type(http) == "table" and type(http.request) == "function" then
            return http.request
        end

        if type(fluxus) == "table" and type(fluxus.request) == "function" then
            return fluxus.request
        end

        return nil
    end

    do
        local v25

        do
            local function v22(p10)
                local _tostring = tostring

                if not p10 then
                    p10 = ""
                end

                local v342 = _tostring(p10):gsub("%s+", "")

                if v342 == "" then
                    return false, "No Key", "Please enter a key"
                end

                local ClientId = game:GetService("RbxAnalyticsService"):GetClientId()
                local v344 = t1.value6 and t1.value6.Name or ""
                local t6 = {
					key = v342,
					hwid = ClientId,
					user_id = v344
				}
                local v346 = t1.value15()

                if not v346 then
                    return false, "Executor Error", "Your executor does not support HTTP requests"
                end

                local ok, result = pcall(function()
                    local v1405 = v346
                    local API_URL = t1.value11.API_URL
                    local t7 = {
						["Content-Type"] = "application/json"
					}
                    local json = t1.value3:JSONEncode(t6)

                    return v1405({
						Url = API_URL,
						Method = "POST",
						Headers = t7,
						Body = json
					})
                end)
                local v349 = not ok

                if not v349 then
                    v349 = not result
                end

                if v349 then
                    return false, "Connection Error", "Failed to contact verification server"
                end

                local v350 = result.Body or result.body

                if not v350 or v350 == "" then
                    return false, "Empty Response", "Server returned empty response"
                end

                local ok2, result2 = pcall(function()
                    return t1.value3:JSONDecode(v350)
                end)
                local v353 = not ok2

                if not v353 then
                    v353 = not result2 or type(result2) ~= "table"
                end

                if v353 then
                    return false, "Decode Error", "Failed to parse API response"
                end

                if result2.valid then
                    return true, result2.expires_formatted or (result2.time_left and tostring(result2.time_left) .. "s" or "Active"), result2.expires or os.time() + 315360000
                end

                local str = tostring(result2.reason or (result2.code or "Invalid"))
                local t8 = { tostring(result2.error or "Invalid Key") }

                return false, str, v2(t8)
            end

            pcall(function()
                if isfile(t1.value11.KEY_FILE) then
                    t1.value11.savedKey = readfile(t1.value11.KEY_FILE)
                end
            end)
            t1.value16 = {
				English = "en",
				Arabic = "ar",
				Russian = "ru",
				Turkey = "tr",
				["España"] = "es",
				France = "fr",
				Germany = "de",
				Brazil = "pt"
			}
            t1.value12("SP Hub", t1.value10("This will take some sec for loading"), 6)

            local function v23(p11)
                while t1.value2.antispy do
                    local t9 = {
						[1] = "",
						[2] = p11,
						[3] = "AntiSpy EZZZZ BY: SP Hub"
					}
                    local v358 = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Avata1rOrigina1l")
                    local t10 = { unpack(t9) }

                    v358:FireServer(v2(t10))
                    wait(0.2)
                end
            end

            task.spawn(v23, {
				[1] = "DONT TRY",
				[2] = "JUST TURN OFF SIMPLE SPY B#I#TCH",
				[3] = "YOUU CANTT STEALLLL EZZZZZZZZZZZZZZZZZZZZZZZZZ",
				[4] = "HAHAHAHAHAHHAHAHAA"
			})
            task.spawn(v23, {
				[1] = "EZZZZZ EZZZZZZ TAKE THIS NOW ",
				[2] = "Why You Want Steal ME?!😂",
				[3] = "BRO 😂😂",
				[4] = "EZZZZZZZZZZZZZZZZZZZZZ"
			})
            --[[ UI SWAP: splib -> OasisUI (UI KIM) via compatibility adapter ]]
            do
                local Oasis = assert(loadstring(game:HttpGet("https://raw.githubusercontent.com/thanyathonbuthong-ai/UI/refs/heads/main/UI%20KIM"))(), "OasisUI (UI KIM) failed to load")
                local adapter = {}
                adapter.Flags = {}

                function adapter:MakeWindow(def)
                    def = def or {}
                    local win = Oasis:CreateWindow({
                        Title = def.Name or "SP Hub",
                        Subtitle = def.Subtitle,
                        Folder = "SPHub_OasisUI",
                        AutoSave = def.SaveConfig == true,
                    })
                    local winWrap = {}
                    winWrap._oasis = win
                    local secCounter = 0

                    local function nextSide()
                        secCounter = secCounter + 1
                        return (secCounter % 2 == 1) and "Left" or "Right"
                    end

                    function winWrap:MakeTab(tabDef)
                        tabDef = tabDef or {}
                        local tabName = tabDef.Name or tabDef[1] or "Tab"
                        local tabId = tabDef.Id or tabDef[2] or tabName
                        local oasisTab = win:Tab({ Title = tabName, Id = tabId, Icon = tabDef.Icon })
                        local tabWrap = {}
                        tabWrap._oasisTab = oasisTab
                        tabWrap._section = nil

                        local function curSec()
                            if not tabWrap._section then
                                tabWrap._section = oasisTab:Section({ Title = "General", Side = nextSide() })
                            end
                            return tabWrap._section
                        end

                        function tabWrap:AddSection(secDef)
                            local name
                            if type(secDef) == "string" then
                                name = secDef
                            elseif type(secDef) == "table" then
                                name = secDef.Name or secDef.Title or secDef[1] or "Section"
                            else
                                name = "Section"
                            end
                            tabWrap._section = oasisTab:Section({ Title = name, Side = nextSide() })
                            return tabWrap._section
                        end

                        local function passFlag(d, el)
                            if d and d.Flag then
                                adapter.Flags[d.Flag] = el
                                pcall(function() Oasis.Flags = Oasis.Flags or {}; Oasis.Flags[d.Flag] = el end)
                            end
                        end

                        function tabWrap:AddButton(d)
                            d = d or {}
                            return curSec():Button({
                                Title = d.Name or d.Title or "Button",
                                Description = d.Desc or d.Description,
                                Icon = d.Icon,
                                Callback = d.Callback,
                            })
                        end

                        function tabWrap:AddToggle(d)
                            d = d or {}
                            local el = curSec():Toggle({
                                Title = d.Name or d.Title or "Toggle",
                                Default = d.Default or false,
                                Flag = d.Flag,
                                Callback = d.Callback,
                            })
                            passFlag(d, el)
                            return el
                        end

                        function tabWrap:AddDropdown(d)
                            d = d or {}
                            local el = curSec():Dropdown({
                                Title = d.Name or d.Title or "Dropdown",
                                Values = d.Options or d.Values or {},
                                Default = d.Default,
                                Flag = d.Flag,
                                Callback = d.Callback,
                            })
                            passFlag(d, el)
                            return el -- native :Refresh(values, keep) / :Set() match splib
                        end

                        function tabWrap:AddSlider(d)
                            d = d or {}
                            local el = curSec():Slider({
                                Title = d.Name or d.Title or "Slider",
                                Min = d.Min or 0,
                                Max = d.Max or 100,
                                Default = d.Default or 0,
                                Suffix = d.Suffix,
                                Step = d.Increment or d.Step,
                                Flag = d.Flag,
                                Callback = d.Callback,
                            })
                            passFlag(d, el)
                            return el -- native :Set(value) matches splib
                        end

                        function tabWrap:AddTextbox(d)
                            d = d or {}
                            local el = curSec():Input({
                                Title = d.Name or d.Title or "Input",
                                Placeholder = d.Placeholder or d.DefaultText,
                                Default = d.Default,
                                Flag = d.Flag,
                                Callback = d.Callback,
                            })
                            passFlag(d, el)
                            return el -- native :Set(text) matches splib
                        end
                        tabWrap.AddTextBox = tabWrap.AddTextbox

                        function tabWrap:AddKeybind(d)
                            d = d or {}
                            local mode = d.Mode or (d.Hold and "Hold" or "Toggle")
                            local el = curSec():Keybind({
                                Title = d.Name or d.Title or "Keybind",
                                Default = d.Default or d.Key,
                                Mode = mode,
                                Flag = d.Flag,
                                Callback = d.Callback,
                            })
                            passFlag(d, el)
                            return el
                        end

                        -- splib AddBind = one-shot action key -> Always mode fires Callback every press
                        function tabWrap:AddBind(d)
                            d = d or {}
                            local el = curSec():Keybind({
                                Title = d.Name or d.Title or "Bind",
                                Default = d.Default or d.Key,
                                Mode = "Always",
                                Flag = d.Flag,
                                Callback = d.Callback,
                            })
                            passFlag(d, el)
                            return el
                        end

                        -- splib AddParagraph(title, text) returns object with :Set(title, text)
                        function tabWrap:AddParagraph(title, text)
                            local el = curSec():Paragraph({ Title = tostring(title or ""), Content = tostring(text or "") })
                            local wrap = { _oasis = el }
                            function wrap:Set(a, b)
                                if b ~= nil then
                                    el:Set({ Title = tostring(a or ""), Content = tostring(b or "") })
                                elseif type(a) == "table" then
                                    el:Set(a)
                                else
                                    el:SetContent(tostring(a or ""))
                                end
                            end
                            function wrap:SetContent(t) el:SetContent(tostring(t or "")) end
                            function wrap:Destroy() el:Destroy() end
                            function wrap:SetVisible(v) el:SetVisible(v) end
                            return wrap
                        end

                        function tabWrap:AddLabel(text)
                            return curSec():Label({ Text = tostring(text or "") })
                        end

                        function tabWrap:AddDiscordInvite(d)
                            d = d or {}
                            return curSec():Discord({
                                Title = d.Name or d.Title or "Discord",
                                Description = d.Desc or d.Description,
                                Invite = d.Invite or d.Link,
                            })
                        end

                        return tabWrap
                    end

                    return winWrap
                end

                function adapter:MakeNotification(d)
                    d = d or {}
                    pcall(function()
                        Oasis:Notify({
                            Title = d.Name or d.Title or "SP Hub",
                            Content = d.Content or d.Text or "",
                            Duration = d.Time or d.Duration or 5,
                            Type = d.Type or "Info",
                        })
                    end)
                end

                function adapter:SetPremium(on) end -- no-op in OasisUI
                function adapter:RefreshTranslations() end -- no-op (OasisUI has no translation layer)
                function adapter:Destroy() pcall(function() Oasis:Unload() end) end

                -- the notifier helper also checks a global "splib"
                pcall(function() getgenv().splib = adapter end)
                pcall(function() _G.splib = adapter end)

                t1.value17 = adapter
            end
            v24 = t1.value17:MakeWindow({
				Name = "SP Hub | Brookhaven | 1.6v",
				SaveConfig = true,
				Setting = true,
				IsPremium = false,
				CloseCallback = true
			})

            if getgenv().SPHubIsFirstTime then
                task.spawn(function()
                    task.wait(2)
                    t1.value12("SP Hub", t1.value10("Welcome to SP Hub! Enjoy your first session ad-free!"), 15)
                end)
            end

            v25 = function(p12, p13)
                if type(p12) ~= "table" then
                    return p12
                end

                for _, v in ipairs({
					"AddButton",
					"AddToggle",
					"AddDropdown",
					"AddSlider",
					"AddTextbox",
					"AddTextBox",
					"AddKeybind"
				}) do
                    local v338 = v
                    local v339 = p12[v338]

                    if type(v339) == "function" then
                        p12[v338] = function(p14, p15, ...)
                            if type(p15) == "table" and type(p15.Callback) == "function" then
                                local v1404 = p15.Name or (p15.Title or v338)

                                p15.Callback = t1.value14(p13 .. " > " .. tostring(v1404), p15.Callback)
                            end

                            return v339(p14, p15, ...)
                        end
                    end
                end

                return p12
            end or function(p16, _)
                return p16
            end
            t1.value18 = false
            t1.value19 = t1.value10("Lifetime")
            t1.value20 = os.time() + 315360000
            t1.value21 = false

            local v26 = v25(v24:MakeTab({
				t1.value10("Info"),
				"Info"
			}), "Info")

            v26:AddSection({ t1.value10("Language") })
            v26:AddDropdown({
				Name = t1.value10("Language"),
				Options = {
					"English",
					"Arabic",
					"Russian",
					"Turkey",
					"Española",
					"France",
					"Germany",
					"Brazil"
				},
				Default = "English",
				Flag = "LanguageSetting",
				Callback = function(p18)
                local v363 = ({
						English = "en",
						Arabic = "ar",
						Russian = "ru",
						Turkey = "tr",
						["Española"] = "es",
						["España"] = "es",
						Espaa = "es",
						France = "fr",
						Germany = "de",
						Brazil = "pt"
					})[p18] or "en"

                if t1.value2 then
                    t1.value2.CurrentLanguage = v363
                end

                if currentLanguage ~= nil then
                    currentLanguage = v363
                end

                if t1.value17.RefreshTranslations then
                    t1.value17:RefreshTranslations()
                end
            end
			})
            v26:AddSection({ t1.value10("SP Hub Channels") })
            v26:AddButton({
				Name = t1.value10("Telegram Channel"),
				Callback = function()
                setclipboard("https://discord.gg/JD4s8wrvVH")

                local value17 = t1.value17
                local v365 = t1.value10("Copied")
                local MakeNotification = value17.MakeNotification
                local v367 = t1.value10("Telegram channel link copied to clipboard")

                MakeNotification(value17, {
						Name = v365,
						Content = v367,
						Time = 2
					})
            end
			})
            v26:AddButton({
				Name = t1.value10("YouTube Channel"),
				Callback = function()
                setclipboard("https://discord.gg/JD4s8wrvVH")

                local value17 = t1.value17
                local value10 = t1.value10
                local MakeNotification = value17.MakeNotification
                local v371 = value10("Copied")
                local v372 = t1.value10("YouTube channel link copied to clipboard")

                MakeNotification(value17, {
						Name = v371,
						Content = v372,
						Time = 2
					})
            end
			})

            local v27 = t1.value10("Discord Server")
            local value10 = t1.value10
            local AddDiscordInvite = v26.AddDiscordInvite
            local v30 = value10("Join our community for updates, announcements, and key claims!")

            AddDiscordInvite(v26, {
				Name = v27,
				Desc = v30,
				Logo = "rbxassetid://83114982417764",
				Invite = "do not join brodie"
			})
            t1.value22 = v25(v24:MakeTab({
				t1.value10("Key"),
				"Key"
			}), "Key")
            t1.value22:AddParagraph(t1.value10("🔑 Key System"), t1.value10("This script is Keyless! However, some exclusive premium features require a key to unlock."))
            t1.value22:AddParagraph(t1.value10("🎁 <font color=\"#ff8c00\">Get 3 Days FREE Premium!</font>"), t1.value10("<font color=\"#ffffff\">To claim it, visit </font><font color=\"#1e90ff\"><b>www.sphub.lol</b></font><font color=\"#ffffff\">, create an account and link it to Discord, and you'll be given the key </font><font color=\"#ff8c00\"><b>for free!</b></font>"))
            pcall(function()
                local v373 = t1.value22.Cont and t1.value22.Cont:FindFirstChild("Option")

                if v373 and v373:IsA("TextButton") then
                    v373.MouseButton1Click:Connect(function()
                        setclipboard("www.sphub.lol")

                        local value17 = t1.value17
                        local v1410 = t1.value10("Copied")
                        local v1411 = t1.value10("Website URL copied to clipboard")

                        value17:MakeNotification({
							Name = v1410,
							Content = v1411,
							Time = 2
						})
                    end)
                end
            end)

            function t1.value23(p19)
                if p19 <= 0 then
                    return t1.value10("Expired")
                end

                local v375 = math.floor(p19 / 86400)
                local v376 = math.floor(p19 % 86400 / 3600)
                local v377 = math.floor(p19 % 3600 / 60)
                local v378 = math.floor(p19 % 60)
                local t11 = {}

                if v375 > 0 then
                    table.insert(t11, v375 .. t1.value10("d"))
                end

                if v376 > 0 or v375 > 0 then
                    table.insert(t11, v376 .. t1.value10("h"))
                end

                if v377 > 0 or (v376 > 0 or v375 > 0) then
                    table.insert(t11, v377 .. t1.value10("m"))
                end

                table.insert(t11, v378 .. t1.value10("s"))

                return table.concat(t11, " ")
            end

            t1.value24 = t1.value22:AddParagraph(t1.value10("Status"), t1.value10("Waiting..."))
            t1.value25 = nil
            t1.value25 = nil

            function t1.value26(p20)
                t1.value21 = true

                if t1.value25 then
                    task.cancel(t1.value25)
                end

                t1.value24:Set(t1.value10("Status"), p20)
                t1.value25 = task.delay(3, function()
                    t1.value21 = false
                end)
            end

            local value22 = t1.value22
            local v32 = t1.value10("Enter Key")
            local v33 = t1.value11 and t1.value11.savedKey or ""

            t1.value27 = value22:AddTextbox({
				Name = v32,
				Default = v33,
				TextDisappear = false,
				Flag = "SavedKey",
				Callback = function(p21)
                if t1.value11 then
                    t1.value11.savedKey = p21
                end
            end
			})
            t1.value22:AddButton({
				Name = t1.value10("Get Key"),
				Callback = function()
                setclipboard(t1.value11 and t1.value11.GET_KEY_URL or "https://sphub.lol/get-key")

                local value17 = t1.value17
                local v383 = t1.value10("Copied")
                local v384 = t1.value10("Key link copied")

                value17:MakeNotification({
						Name = v383,
						Content = v384,
						Time = 2
					})
            end
			})
            t1.value22:AddButton({
				Name = t1.value10("Verify Key"),
				Callback = function()
                local v385 = tostring(t1.value17.Flags and t1.value17.Flags.SavedKey or (t1.value11 and t1.value11.savedKey or "")):gsub("%s+", "")
                if v385 == "" then
                    t1.value26(t1.value10("Enter key first"))

                    return
                end
                t1.value26(t1.value10("Checking..."))
                local t12, v387, v388 = v22(v385)
                if t12 then
                    t1.value19 = v387 or t1.value10("Lifetime")

                    if not v388 then
                        v388 = os.time() + 315360000
                    end

                    t1.value20 = v388
                    pcall(function()
                        if t1.value11 then
                            writefile(t1.value11.KEY_FILE, v385)
                        end
                    end)
                    t1.value17:SetPremium(true)
                    t1.value18 = true
                    t1.value26(t1.value10("✅ Key Valid"))

                    local value17 = t1.value17
                    local v390 = t1.value10("Success")
                    local v391 = t1.value10("Premium Activated")

                    value17:MakeNotification({
							Name = v390,
							Content = v391,
							Time = 2
						})

                    return
                end
                t1.value18 = false
                t1.value17:SetPremium(false)
                pcall(function()
                    if t1.value11 and isfile(t1.value11.KEY_FILE) then
                        delfile(t1.value11.KEY_FILE)
                    end
                end)
                local value26 = t1.value26
                local format = string.format
                local _tostring = tostring
                if not v387 then
                    v387 = "Invalid"
                end
                local v395 = _tostring(v387)
                local _tostring4 = tostring
                if not v388 then
                    v388 = "Invalid Key"
                end
                value26(format("❌ Reason: %s | Error: %s", v395, _tostring4(v388)))
            end
			})
            t1.value22:AddButton({
				Name = t1.value10("Deactivate Key"),
				Callback = function()
                pcall(function()
                    if t1.value11 and isfile(t1.value11.KEY_FILE) then
                        delfile(t1.value11.KEY_FILE)
                    end
                end)
                pcall(function()
                    t1.value27:Set("")
                end)
                t1.value18 = false
                t1.value17:SetPremium(false)
                t1.value26(t1.value10("Key Deactivated"))

                local value17 = t1.value17
                local v398 = t1.value10("Deactivated")
                local value10_2 = t1.value10
                local MakeNotification = value17.MakeNotification
                local v401 = value10_2("Premium deactivated and key cleared")

                MakeNotification(value17, {
						Name = v398,
						Content = v401,
						Time = 2
					})
            end
			})
            task.spawn(function()
                task.wait(1)

                if t1.value11 and t1.value11.savedKey ~= "" then
                    local v402, v403, v404 = v22(t1.value11.savedKey)

                    if v402 then
                        t1.value19 = v403 or t1.value10("Lifetime")
                        t1.value20 = v404 or os.time() + 315360000
                        t1.value26(t1.value10("✅ Auto Login"))
                        t1.value17:SetPremium(true)
                        t1.value18 = true

                        return
                    end

                    t1.value18 = false
                    t1.value17:SetPremium(false)
                    pcall(function()
                        if t1.value11 then
                            delfile(t1.value11.KEY_FILE)
                        end
                    end)
                    t1.value26(string.format("Saved Key Invalid (Reason: %s | Error: %s)", tostring(v403 or "Invalid"), (tostring(v404 or "Invalid Key"))))
                end
            end)
        end

        task.spawn(function()
            while task.wait(1) do
                if t1.value18 and not t1.value21 then
                    local v405 = t1.value20 - os.time()

                    t1.value24:Set(t1.value10("Status"), t1.value10("Key Active") .. "\n" .. t1.value10("Expires") .. ": " .. t1.value19 .. "\n" .. t1.value10("Time Left") .. ": " .. t1.value23(v405))
                end
            end
        end)

        local v34 = v25(v24:MakeTab({
			t1.value10("Info"),
			"Info"
		}), "Info")

        v34:AddSection({ t1.value10("Language") })
        v34:AddDropdown({
			Name = t1.value10("Language"),
			Options = {
				"English",
				"Arabic",
				"Russian",
				"Turkey",
				"España",
				"France",
				"Germany",
				"Brazil"
			},
			Default = "English",
			Flag = "LanguageSetting",
			Callback = function(p22)
            t1.value2.CurrentLanguage = t1.value16[p22] or "en"

            if t1.value17.RefreshTranslations then
                t1.value17:RefreshTranslations()
            end
        end
		})
        v34:AddSection({ t1.value10("SP Hub Channels") })
        v34:AddButton({
			Name = t1.value10("Telegram Channel"),
			Callback = function()
            t1.value13("https://discord.gg/JD4s8wrvVH", "Telegram channel link")
        end
		})
        v34:AddButton({
			Name = t1.value10("YouTube Channel"),
			Callback = function()
            t1.value13("https://discord.gg/JD4s8wrvVH", "YouTube channel link")
        end
		})

        local v35 = t1.value10("Discord Server")
        local v36 = t1.value10("Join our community for updates, announcements, and key claims!")

        v34:AddDiscordInvite({
			Name = v35,
			Desc = v36,
			Logo = "rbxassetid://83114982417764",
			Invite = "do not join brodie"
		})
        Tab = v24:MakeTab({
			Name = t1.value10("Players"),
			Icon = "rbxassetid://9726104962"
		})
        Tab:AddSection({
			Name = t1.value10("Target Players")
		})
        t1.value28 = {}
        playersDropdown = Tab:AddDropdown({
			Name = t1.value10("Players"),
			Default = "No Players",
			Options = { "No Players" },
			Callback = function(p23)
            if p23 ~= "No Players" then
                getgenv().selectedPlayer = p23
            end
        end
		})

        function t1.value29()
            local t13 = {}

            for _, player in pairs(game.Players:GetPlayers()) do
                table.insert(t13, player.Name)
            end

            t1.value28 = t13
            playersDropdown:Refresh(#t1.value28 > 0 and t1.value28 or { "No Players" }, true)
        end

        t1.value29()
        game.Players.PlayerAdded:Connect(function(_)
            t1.value29()
        end)
        game.Players.PlayerRemoving:Connect(function(_)
            t1.value29()
        end)
        Tab:AddToggle({
			Name = t1.value10("Target Player Tool"),
			Default = false,
			Callback = function(p26)
            local Backpack = t1.value6:FindFirstChild("Backpack")

            if p26 then
                local t1value2TargetToolName = Backpack:FindFirstChild(t1.value2.TargetToolName)

                if not t1value2TargetToolName then
                    t1value2TargetToolName = t1.value7

                    if t1value2TargetToolName then
                        t1value2TargetToolName = t1.value7:FindFirstChild(t1.value2.TargetToolName)
                    end
                end

                if t1value2TargetToolName then
                    return
                end

                local Tool = Instance.new("Tool")

                Tool.Name = t1.value2.TargetToolName
                Tool.RequiresHandle = false
                Tool.TextureId = "rbxassetid://87129552111975"
                Tool.ToolTip = "Click on a player to select them"
                Tool.Parent = Backpack
                Tool.Activated:Connect(function()
                    local Target = t1.value6:GetMouse().Target

                    if Target and Target.Parent then
                        local Model = Target:FindFirstAncestorOfClass("Model")

                        if Model then
                            local player = game.Players:GetPlayerFromCharacter(Model)

                            if player then
                                local playerName = player.Name

                                if playersDropdown and table.find(t1.value28, playerName) then
                                    playersDropdown:Select(playerName)
                                    getgenv().selectedPlayer = playerName
                                end

                                if killDropdown and table.find(t1.value28, playerName) then
                                    killDropdown:Select(playerName)
                                    getgenv().selectedPlayer = playerName
                                end

                                if Bangdropdown and table.find(t1.value28, playerName) then
                                    Bangdropdown:Select(playerName)
                                    getgenv().selectedPlayer = playerName
                                end

                                if AvatarPlayerDropdown and table.find(t1.value28, playerName) then
                                    AvatarPlayerDropdown:Select(playerName)
                                    getgenv().selectedPlayer = playerName
                                end
                            end
                        end
                    end
                end)

                return
            end

            local t1value2TargetToolName = Backpack:FindFirstChild(t1.value2.TargetToolName)

            if t1value2TargetToolName then
                t1value2TargetToolName:Destroy()
            end

            if t1.value7 then
                local t1value2TargetToolName2 = t1.value7:FindFirstChild(t1.value2.TargetToolName)

                if t1value2TargetToolName2 then
                    t1value2TargetToolName2:Destroy()
                end
            end
        end
		})
        Tab:AddSection({
			Name = t1.value10("Features")
		})
        Tab:AddButton({
			Name = t1.value10("Teleport"),
			Callback = function()
            local selectedPlayer2 = getgenv().selectedPlayer

            if selectedPlayer2 then
                local selectedPlayer2_2 = game.Players:FindFirstChild(selectedPlayer2)

                if selectedPlayer2_2 and selectedPlayer2_2.Character then
                    local Character = selectedPlayer2_2.Character

                    if Character.PrimaryPart then
                        game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(Character.PrimaryPart.CFrame)
                    end
                end
            end
        end
		})
        t1.value30 = false
        Tab:AddToggle({
			Name = t1.value10("Follow Player"),
			Default = false,
			Callback = function(p27)
            t1.value30 = p27
        end
		})
        game:GetService("RunService").Heartbeat:Connect(function()
            if t1.value30 and getgenv().selectedPlayer then
                local LocalPlayer4 = game.Players.LocalPlayer
                local selectedPlayer3 = game.Players:FindFirstChild(getgenv().selectedPlayer)

                if selectedPlayer3 and (selectedPlayer3.Character and selectedPlayer3.Character.PrimaryPart) then
                    local PrimaryPartPosition = selectedPlayer3.Character.PrimaryPart.Position
                    local Character = LocalPlayer4.Character
                    local t14 = { CFrame.new(PrimaryPartPosition) }

                    Character:SetPrimaryPartCFrame(v2(t14))
                end
            end
        end)

        local LocalPlayer5 = game:GetService("Players").LocalPlayer

        t1.value31 = nil
        t1.value31 = LocalPlayer5
        t1.value32 = {}

        function t1.value33(p28)
            if p28 ~= t1.value31 and (p28.Character and not p28.Character:FindFirstChild("Highlight")) then
                local Highlight = Instance.new("Highlight")

                Highlight.FillTransparency = 0
                Highlight.OutlineTransparency = 0
                Highlight.FillColor = t1.value2.ESPColor
                Highlight.Parent = p28.Character

                local Head = p28.Character:FindFirstChild("Head")

                if Head and not Head:FindFirstChild("PlayerNameBar") then
                    local BillboardGui = Instance.new("BillboardGui")

                    BillboardGui.Name = "PlayerNameBar"
                    BillboardGui.Size = UDim2.new(0, 100, 0, 25)
                    BillboardGui.StudsOffset = Vector3.new(0, 2, 0)
                    BillboardGui.AlwaysOnTop = true
                    BillboardGui.Adornee = Head

                    local TextLabel = Instance.new("TextLabel")

                    TextLabel.BackgroundTransparency = 1
                    TextLabel.Size = UDim2.new(1, 0, 1, 0)
                    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    TextLabel.TextStrokeTransparency = 0
                    TextLabel.TextScaled = true
                    TextLabel.Text = p28.Name
                    TextLabel.Parent = BillboardGui
                    BillboardGui.Parent = Head
                end
            end
        end
        function t1.value34(p29)
            if p29.Character then
                if p29.Character:FindFirstChild("Highlight") then
                    p29.Character.Highlight:Destroy()
                end

                local Head = p29.Character:FindFirstChild("Head")

                if Head and Head:FindFirstChild("PlayerNameBar") then
                    Head.PlayerNameBar:Destroy()
                end
            end
        end

        Tab:AddToggle({
			Name = t1.value10("ESP"),
			Default = false,
			Callback = function(p30)
            if p30 then
                for _, player in ipairs(game.Players:GetPlayers()) do
                    if player ~= t1.value31 then
                        t1.value33(player)
                    end
                end

                t1.value32.PlayerAdded = game.Players.PlayerAdded:Connect(function(player)
                    t1.value32[player] = player.CharacterAdded:Connect(function()
                        wait(1)

                        if player ~= t1.value31 then
                            t1.value33(player)
                        end
                    end)
                end)

                return
            end
            for v440, v441 in ipairs(game.Players:GetPlayers()) do

                t1.value34(v441)
            end
            for _, v in pairs(t1.value32) do
                if v then
                    v:Disconnect()
                end
            end
        end
		})

        function t1.value35(p31)
            if p31 then
                t1.value2.selectedViewPlayer = game.Players:FindFirstChild(getgenv().selectedPlayer)

                if t1.value2.selectedViewPlayer and t1.value2.selectedViewPlayer.Character then
                    game.Workspace.CurrentCamera.CameraSubject = t1.value2.selectedViewPlayer.Character

                    if t1.value2.characterAddedConnection then
                        t1.value2.characterAddedConnection:Disconnect()
                    end

                    t1.value2.characterAddedConnection = t1.value2.selectedViewPlayer.CharacterAdded:Connect(function(character)
                        game.Workspace.CurrentCamera.CameraSubject = character
                    end)

                    return
                end

                t1.value2.viewEnabled = false

                return
            end

            if t1.value2.characterAddedConnection then
                t1.value2.characterAddedConnection:Disconnect()
                t1.value2.characterAddedConnection = nil
            end

            game.Workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character
        end

        game.Players.PlayerRemoving:Connect(function(player)
            if player == t1.value2.selectedViewPlayer then
                t1.value2.selectedViewPlayer = nil

                if t1.value2.viewEnabled then
                    t1.value35(false)
                end
            end
        end)
        task.spawn(function()
            while wait() do
                if t1.value2.viewEnabled and (t1.value2.selectedViewPlayer and t1.value2.selectedViewPlayer.Character) and game.Workspace.CurrentCamera.CameraSubject ~= t1.value2.selectedViewPlayer.Character then
                    game.Workspace.CurrentCamera.CameraSubject = t1.value2.selectedViewPlayer.Character
                end
            end
        end)
        Tab:AddToggle({
			Name = t1.value10("Spectate Player"),
			Default = false,
			Callback = function(p32)
            t1.value2.viewEnabled = p32
            t1.value35(p32)
        end
		})
        Tab:AddSection({
			Name = t1.value10("Info")
		})
        Tab:AddButton({
			Name = t1.value10("Copy Selected Player Username"),
			Callback = function()
            local selectedPlayer4 = getgenv().selectedPlayer

            if selectedPlayer4 then
                setclipboard(selectedPlayer4)
            end
        end
		})
        Tab = v24:MakeTab({
			Name = t1.value10("Kill"),
			Icon = "rbxassetid://17691740806"
		})
        Tab:AddSection({
			Name = t1.value10("Target Players")
		})

        local function v38(p33)
            local Character = p33.Character

            if not Character or not Character.Parent then
                return
            end

            local Humanoid = Character:FindFirstChildOfClass("Humanoid")

            if not Humanoid then
                return
            end

            if Humanoid.Sit then
                Humanoid.Sit = false
                task.wait(0.1)
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end

        killDropdown = Tab:AddDropdown({
			Name = t1.value10("Players"),
			Default = "No Players",
			Options = { "No Players" },
			Callback = function(p34)
            if p34 ~= "No Players" then
                getgenv().kkselectedPlayer = p34
            end
        end
		})

        local function v39()
            t1.value28 = {}

            for _, player in ipairs(game.Players:GetPlayers()) do
                table.insert(t1.value28, player.Name)
            end

            killDropdown:Refresh(#t1.value28 > 0 and t1.value28 or { "No Players" }, true)
        end

        v39()
        game.Players.PlayerAdded:Connect(v39)
        game.Players.PlayerRemoving:Connect(v39)
        Tab:AddToggle({
			Name = t1.value10("Target Player Tool"),
			Default = false,
			Callback = function(p35)
            local Backpack = t1.value31:FindFirstChild("Backpack")

            if p35 then
                local t1value2TargetToolName = Backpack:FindFirstChild(t1.value2.TargetToolName)

                if not t1value2TargetToolName then
                    t1value2TargetToolName = t1.value7

                    if t1value2TargetToolName then
                        t1value2TargetToolName = t1.value7:FindFirstChild(t1.value2.TargetToolName)
                    end
                end

                if t1value2TargetToolName then
                    return
                end

                local Tool = Instance.new("Tool")

                Tool.Name = t1.value2.TargetToolName
                Tool.RequiresHandle = false
                Tool.TextureId = "rbxassetid://87129552111975"
                Tool.ToolTip = "Click on a player to select them"
                Tool.Parent = Backpack
                Tool.Activated:Connect(function()
                    local Target = t1.value31:GetMouse().Target

                    if Target and Target.Parent then
                        local Model = Target:FindFirstAncestorOfClass("Model")

                        if Model then
                            local player = game.Players:GetPlayerFromCharacter(Model)

                            if player then
                                local playerName = player.Name

                                if playersDropdown and table.find(t1.value28, playerName) then
                                    playersDropdown:Select(playerName)
                                    getgenv().selectedPlayer = playerName
                                end

                                if killDropdown and table.find(t1.value28, playerName) then
                                    killDropdown:Select(playerName)
                                    getgenv().selectedPlayer = playerName
                                end

                                if Bangdropdown and table.find(t1.value28, playerName) then
                                    Bangdropdown:Select(playerName)
                                    getgenv().selectedPlayer = playerName
                                end

                                if AvatarPlayerDropdown and table.find(t1.value28, playerName) then
                                    AvatarPlayerDropdown:Select(playerName)
                                    getgenv().selectedPlayer = playerName
                                end
                            end
                        end
                    end
                end)

                return
            end

            local t1value2TargetToolName = Backpack:FindFirstChild(t1.value2.TargetToolName)

            if t1value2TargetToolName then
                t1value2TargetToolName:Destroy()
            end

            if t1.value7 then
                local t1value2TargetToolName3 = t1.value7:FindFirstChild(t1.value2.TargetToolName)

                if t1value2TargetToolName3 then
                    t1value2TargetToolName3:Destroy()
                end
            end
        end
		})
        Tab:AddSection({
			Name = t1.value10("Kill System")
		})

        local function v40()
            local LocalPlayer6 = game.Players.LocalPlayer

            if selectedPlayer then
                v38(LocalPlayer6)

                local selectedPlayer5 = game.Players:FindFirstChild(selectedPlayer)

                if selectedPlayer5 then
                    local PrimaryPartPosition
                    local g496
                    if LocalPlayer6.Character and LocalPlayer6.Character.PrimaryPart then
                        PrimaryPartPosition = LocalPlayer6.Character.PrimaryPart.Position
                    end
                    local v491
                    local v492, v493, v494 = pairs(LocalPlayer6.Backpack:GetChildren())
                    local v495
                    repeat
                        v494, v495 = v492(v493, v494)

                        if not v494 then
                            g496 = true
                        end

                        if g496 then
                            break
                        end
                    until v495.Name == "Couch"
                    if not g496 then
                        v491 = v495
                    end
                    if not v491 then
                        local t15 = {
							[1] = "PickingTools",
							[2] = "Couch"
						}
                        local v498 = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l")
                        local t16 = { unpack(t15) }

                        v498:InvokeServer(v2(t16))

                        repeat
                            task.wait(0.1)

                            for _, child in pairs(LocalPlayer6.Backpack:GetChildren()) do
                                if child.Name == "Couch" then
                                    v491 = child

                                    break
                                end
                            end
                        until v491
                    end
                    if v491 then
                        v491.Parent = LocalPlayer6.Character
                    end
                    local Character = selectedPlayer5.Character
                    local v503 = Character and Character:FindFirstChild("Humanoid")
                    if v503 and v503.Sit then
                        killing = false

                        local value17 = t1.value17
                        local v505 = t1.value10("player is sitting!")
                        local v506 = t1.value10("The player is sitting on something.")

                        value17:MakeNotification({
							Name = v505,
							Content = v506,
							Image = "rbxassetid://4483345998",
							Time = 2
						})

                        return
                    end
                    local v507 = Character
                    if Character then
                        v507 = Character.PrimaryPart and (LocalPlayer6.Character and LocalPlayer6.Character.PrimaryPart)
                    end
                    if v507 then
                        local v508 = Character.PrimaryPart.CFrame.LookVector * -2.5
                        local v509 = Character.PrimaryPart.Position + v508 + Vector3.new(0, 1.5, 0)

                        LocalPlayer6.Character:SetPrimaryPartCFrame(CFrame.new(v509, Character.PrimaryPart.Position))
                    end
                    task.wait(0.1)
                    local AlignPosition = Instance.new("AlignPosition")
                    AlignPosition.Name = "BringAttach"
                    AlignPosition.RigidityEnabled = true
                    AlignPosition.MaxForce = 1e999
                    AlignPosition.Responsiveness = 500
                    AlignPosition.Parent = LocalPlayer6.Character.PrimaryPart
                    local AlignOrientation = Instance.new("AlignOrientation")
                    AlignOrientation.Name = "BringRotate"
                    AlignOrientation.RigidityEnabled = false
                    AlignOrientation.MaxTorque = 1e999
                    AlignOrientation.Responsiveness = 100
                    AlignOrientation.Parent = LocalPlayer6.Character.PrimaryPart
                    local Attachment = Instance.new("Attachment", LocalPlayer6.Character.PrimaryPart)
                    local Attachment2 = Instance.new("Attachment", Character.PrimaryPart)
                    Attachment.Position = Vector3.new(0, -5, 0)
                    Attachment2.Position = Vector3.new(0, -5, 0)
                    AlignPosition.Attachment0 = Attachment
                    AlignPosition.Attachment1 = Attachment2
                    AlignOrientation.Attachment0 = Attachment
                    AlignOrientation.Attachment1 = Attachment2
                    task.spawn(function()
                        while AlignOrientation and AlignOrientation.Parent do
                            local timestamp = tick()
                            local v1423 = math.sin(timestamp * 10) * 45
                            local v1424 = math.cos(timestamp * 10)
                            local _math = math
                            local v1426 = v1424 * 45
                            local v1427 = _math.sin(timestamp * 10) * 45

                            Attachment.Orientation = Vector3.new(v1423, v1426, v1427)
                            wait(0.01)
                        end
                    end)
                    local RunService = game:GetService("RunService")
                    t1.value2.RunService.Heartbeat:Connect(function(_, _)
                        if Attachment and Attachment.Parent then
                            local timestamp = tick()
                            local v1431 = math.sin(timestamp * 10) * 3
                            local v1432 = math.sin(timestamp * 20)
                            local _math = math
                            local v1434 = v1432 * 1.5
                            local v1435 = _math.cos(timestamp * 10) * 3

                            Attachment.Position = Vector3.new(v1431, v1434, v1435)
                        end
                    end)
                    if v503 then
                        task.spawn(function()
                            local n1 = 0

                            if not (n1 >= 7) then
                                local _ = v503.SeatPart
                            end

                            repeat
                                task.wait(0.1)
                                n1 += 0.1

                                local v1438 = not v503.Parent

                                if not v1438 then
                                    v1438 = not v503:IsDescendantOf(game)
                                end
                            until v1438 or (n1 >= 7 or v503.SeatPart)

                            local v1439 = n1 >= 7

                            if not v1439 then
                                v1439 = not v503.Parent

                                if not v1439 then
                                    v1439 = not v503:IsDescendantOf(game)
                                end
                            end

                            if v1439 then
                                if AlignOrientation and AlignOrientation.Parent then
                                    AlignOrientation:Destroy()
                                end

                                if AlignPosition and AlignPosition.Parent then
                                    AlignPosition:Destroy()
                                end

                                task.wait(0.2)

                                if LocalPlayer6.Character and (LocalPlayer6.Character.PrimaryPart and PrimaryPartPosition) then
                                    LocalPlayer6.Character:SetPrimaryPartCFrame(CFrame.new(PrimaryPartPosition))

                                    return
                                end
                            else
                                local vector3 = Vector3.new(0, 0, 0)
                                local Magnitude = (vector3 - Attachment.Position).Magnitude

                                RunService.Heartbeat:Connect(function(_, p39)
                                    if (Attachment.Position - vector3).Magnitude > 0.1 then
                                        local v1888 = math.min(Magnitude * 1 * p39, (vector3 - Attachment.Position).Magnitude)

                                        Attachment.Position = Attachment.Position + (vector3 - Attachment.Position).Unit * v1888
                                    end
                                end)

                                if AlignPosition then
                                    AlignPosition:Destroy()
                                end

                                if AlignOrientation then
                                    AlignOrientation:Destroy()
                                end

                                if Attachment then
                                    Attachment:Destroy()
                                end

                                if Attachment2 then
                                    Attachment2:Destroy()
                                end

                                local vector3_2 = Vector3.new(10000, 500, 10000)

                                if LocalPlayer6.Character and LocalPlayer6.Character.PrimaryPart then
                                    LocalPlayer6.Character:SetPrimaryPartCFrame(CFrame.new(vector3_2))
                                end

                                task.wait(t1.value2.deletecoucSEC)

                                local t17 = {
									[1] = "PlayerWantsToDeleteTool",
									[2] = "Couch"
								}
                                local v1444 = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Clea1rTool1s")
                                local t18 = { unpack(t17) }

                                v1444:FireServer(v2(t18))
                                task.wait(t1.value2.TPoriginalSEC)

                                if PrimaryPartPosition then
                                    LocalPlayer6.Character:SetPrimaryPartCFrame(CFrame.new(PrimaryPartPosition))
                                end
                            end
                        end)
                    end
                end
            end
        end

        function t1.value36()
            local Players = game:GetService("Players")
            local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
            local LocalPlayer7 = Players.LocalPlayer
            local kkselectedPlayer = getgenv().kkselectedPlayer
            if not kkselectedPlayer then
                return
            end
            local kkselectedPlayer2 = Players:FindFirstChild(kkselectedPlayer)
            if not kkselectedPlayer2 or (not kkselectedPlayer2.Character or not kkselectedPlayer2.Character:FindFirstChild("HumanoidRootPart")) then
                return
            end
            local v465
            local v466, v467, v468 = pairs(LocalPlayer7.Backpack:GetChildren())
            local g470
            local v469
            repeat
                v468, v469 = v466(v467, v468)

                if not v468 then
                    g470 = true
                end

                if g470 then
                    break
                end
            until v469.Name == "Couch"
            if not g470 then
                v465 = v469
            end
            g470 = false
            if not v465 then
                local t19 = {
					[1] = "PickingTools",
					[2] = "Couch"
				}

                ReplicatedStorage3.RE:FindFirstChild("1Too1l"):InvokeServer(unpack(t19))

                repeat
                    task.wait(0.1)

                    for _, child in pairs(LocalPlayer7.Backpack:GetChildren()) do
                        if child.Name == "Couch" then
                            v465 = child

                            break
                        end
                    end
                until v465
            end
            if not v465 then
                warn("Error: Couch not found")

                return
            end
            v465.Name = "Chaos.Couch"
            local Seat1 = v465:FindFirstChild("Seat1")
            local Seat2 = v465:FindFirstChild("Seat2")
            local v476 = Seat1
            local Handle = v465:FindFirstChild("Handle")
            if Seat1 then
                v476 = Seat2 and Handle
            end
            if not v476 then
                warn("Error: Couch components not found")

                return
            end
            Seat1.Disabled = true
            Seat2.Disabled = true
            Handle.Name = "Handle "
            v465.Parent = LocalPlayer7.Character
            local BodyVelocity = Instance.new("BodyVelocity", Seat1)
            BodyVelocity.MaxForce = Vector3.new(1e999, 1e999, 1e999)
            BodyVelocity.P = 999999
            BodyVelocity.Velocity = Vector3.new(0, 0, 0)
            BodyVelocity.Name = "#mOVOOEPF$#@F$#GERE..>V<<<<EW<V<<W"
            if kkselectedPlayer2.Character and kkselectedPlayer2.Character:FindFirstChild("Humanoid") then
                if kkselectedPlayer2.Character.Humanoid.Sit ~= true then
                end
            end
            repeat
                for _ = 1, 35 do
                    local v480 = kkselectedPlayer2.Character and kkselectedPlayer2.Character:FindFirstChild("HumanoidRootPart")

                    if not v480 then
                        break
                    end

                    local v481 = v480.Position + v480.Velocity / 2

                    Seat1.CFrame = CFrame.new(v481) * CFrame.new(-2, 2, 0)
                    Seat1.AssemblyLinearVelocity = Vector3.new(math.random(-6000, 6000), math.random(3000, 7000), math.random(-6000, 6000))
                    Seat1.AssemblyAngularVelocity = Vector3.new(math.random(-150, 150), math.random(-150, 150), math.random(-150, 150))
                    task.wait()
                end

                BodyVelocity:Destroy()
                v465.Parent = LocalPlayer7.Backpack
                task.wait()

                local v482 = v465:FindFirstChild("Handle ")

                if v482 then
                    v482.Name = "Handle"
                end

                task.wait(0.2)
                v465.Parent = LocalPlayer7.Character
                task.wait()
                v465.Parent = LocalPlayer7.Backpack

                local Handle2 = v465:FindFirstChild("Handle")

                if Handle2 then
                    Handle2.Name = "Handle "
                end

                task.wait(0.2)
                v465.Parent = LocalPlayer7.Character
                BodyVelocity = Instance.new("BodyVelocity", Seat1)
                BodyVelocity.MaxForce = Vector3.new(1e999, 1e999, 1e999)
                BodyVelocity.P = 999999
                BodyVelocity.Velocity = Vector3.new(0, 0, 0)
                BodyVelocity.Name = "#mOVOOEPF$#@F$#GERE..>V<<<<EW<V<<W"
            until kkselectedPlayer2.Character and (kkselectedPlayer2.Character:FindFirstChild("Humanoid") and kkselectedPlayer2.Character.Humanoid.Sit == true)
            task.wait()
            v465.Parent = LocalPlayer7.Backpack
            Seat1.CFrame = CFrame.new(9999, -450, 9999)
            Seat2.CFrame = CFrame.new(9999, -450, 9999)
            v465.Parent = LocalPlayer7.Character
            task.wait(0.1)
            v465.Parent = LocalPlayer7.Backpack
            task.wait(2)
            local v484 = Seat1:FindFirstChild("#mOVOOEPF$#@F$#GERE..>V<<<<EW<V<<W")
            if v484 then
                v484:Destroy()
            end
            local t20 = {
				[1] = "PlayerWantsToDeleteTool",
				[2] = "Couch"
			}
            local v486 = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Clea1rTool1s")
            local t21 = { unpack(t20) }
            v486:FireServer(v2(t21))
        end

        t1.value37 = game:GetService("Players").LocalPlayer

        function t1.value38()
            local kkselectedPlayer = game.Players:FindFirstChild(getgenv().kkselectedPlayer)

            v38(t1.value37)

            if not kkselectedPlayer or (not kkselectedPlayer.Character or not kkselectedPlayer.Character:FindFirstChild("HumanoidRootPart")) then
                return
            end

            local v516 = t1.value37.Character or t1.value37.CharacterAdded:Wait()
            local Humanoid = v516:WaitForChild("Humanoid")
            local HumanoidRootPart = v516:WaitForChild("HumanoidRootPart")
            local Humanoid2 = kkselectedPlayer.Character:FindFirstChild("Humanoid")
            local HumanoidRootPartPosition = HumanoidRootPart.Position
            local Anchored = HumanoidRootPart.Anchored

            HumanoidRootPart.CFrame = CFrame.new(634.18, -4, 1839.65)
            wait(1)
            game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Ca1r"):FireServer(unpack({
				"PickingBoat",
				"MilitaryBoatFree"
			}))
            wait(1);
            (function()
                local v1446 = workspace.Vehicles:FindFirstChild(t1.value37.Name .. "Car")

                if not v1446 then
                    return
                end

                local VehicleSeat = v1446.Body:FindFirstChild("VehicleSeat")

                if not VehicleSeat then
                    return
                end

                HumanoidRootPart.Anchored = false
                Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                wait(0.2)
                HumanoidRootPart.CFrame = VehicleSeat.CFrame * CFrame.new(0, 0.5, 0)
                wait(0.2)
                Humanoid.Sit = true
                firetouchinterest(HumanoidRootPart, VehicleSeat, 0)
                firetouchinterest(HumanoidRootPart, VehicleSeat, 1)

                local timestamp = tick()

                while tick() - timestamp < 3 and VehicleSeat ~= Humanoid.SeatPart do
                    HumanoidRootPart.CFrame = VehicleSeat.CFrame * CFrame.new(0, 0.5, 0)
                    Humanoid.Sit = true
                    firetouchinterest(HumanoidRootPart, VehicleSeat, 0)
                    firetouchinterest(HumanoidRootPart, VehicleSeat, 1)
                    wait(0.2)
                end

                if VehicleSeat ~= Humanoid.SeatPart then
                    return
                end
            end)()
            wait(0.5)

            local HumanoidRootPartPosition2 = kkselectedPlayer.Character.HumanoidRootPart.Position
            local v523 = workspace.Vehicles:FindFirstChild(t1.value37.Name .. "Car")

            if v523 then
                local t22 = { CFrame.new(HumanoidRootPartPosition2 + Vector3.new(0, -2, 0)) }

                v523:SetPrimaryPartCFrame(v2(t22))
                HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPartPosition2 + Vector3.new(0, 5, 0))
                tick()

                while not (Humanoid2 and Humanoid2.SeatPart) do
                    local vector3 = Vector3.new(math.random(-8, 8), math.random(-3, 1), math.random(-8, 8))

                    v523:SetPrimaryPartCFrame(CFrame.new(HumanoidRootPartPosition2 + Vector3.new(0, -2, 0) + vector3))
                    wait(0.05)
                end

                local vector3 = Vector3.new(-86, -224.27, 34.57)

                if v523 then
                    v523:SetPrimaryPartCFrame(CFrame.new(vector3))
                    HumanoidRootPart.CFrame = CFrame.new(vector3 + Vector3.new(0, 5, 0))
                end

                HumanoidRootPart.Anchored = false
                Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

                if v523 then
                    v523:Destroy()
                end

                wait(0.5)
                HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPartPosition)
                HumanoidRootPart.Anchored = Anchored
                Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
            end
        end
        function t1.value39()
            v38(t1.value37)

            local kkselectedPlayer = game.Players:FindFirstChild(getgenv().kkselectedPlayer)

            if not kkselectedPlayer or (not kkselectedPlayer.Character or not kkselectedPlayer.Character:FindFirstChild("HumanoidRootPart")) then
                return
            end

            local v546 = t1.value37.Character or t1.value37.CharacterAdded:Wait()
            local Humanoid = v546:WaitForChild("Humanoid")
            local HumanoidRootPart = v546:WaitForChild("HumanoidRootPart")
            local HumanoidRootPartPosition = HumanoidRootPart.Position
            local Anchored = HumanoidRootPart.Anchored

            HumanoidRootPart.CFrame = CFrame.new(634.18, -4, 1839.65)
            wait(0.5)
            game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Ca1r"):FireServer(unpack({
				"PickingBoat",
				"PirateFree"
			}))
            wait(1.5);
            (function()
                local v1451 = workspace.Vehicles:FindFirstChild(t1.value37.Name .. "Car")

                if not v1451 then
                    return
                end

                local VehicleSeat = v1451.Body:FindFirstChild("VehicleSeat")

                if not VehicleSeat then
                    return
                end

                HumanoidRootPart.Anchored = false
                Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                wait(0.2)
                HumanoidRootPart.CFrame = VehicleSeat.CFrame * CFrame.new(0, 0.5, 0)
                wait(0.2)
                Humanoid.Sit = true
                firetouchinterest(HumanoidRootPart, VehicleSeat, 0)
                firetouchinterest(HumanoidRootPart, VehicleSeat, 1)
                wait(0.5)

                if VehicleSeat ~= Humanoid.SeatPart then
                    HumanoidRootPart.CFrame = VehicleSeat.CFrame * CFrame.new(0, 0.5, 0)
                    Humanoid.Sit = true
                    wait(0.5)
                end
            end)()
            wait(0.5)

            local HumanoidRootPartPosition3 = kkselectedPlayer.Character.HumanoidRootPart.Position
            local v552 = workspace.Vehicles:FindFirstChild(t1.value37.Name .. "Car")

            if v552 then
                v552:SetPrimaryPartCFrame(CFrame.new(HumanoidRootPartPosition3 + Vector3.new(0, -2, 0)))
                HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPartPosition3 + Vector3.new(0, 5, 0))

                local timestamp = tick()

                while tick() - timestamp < 2 do
                    local vector3 = Vector3.new(math.random(-8, 8), math.random(-3, 1), math.random(-8, 8))
                    local t23 = { CFrame.new(HumanoidRootPartPosition3 + Vector3.new(0, -2, 0) + vector3) }

                    v552:SetPrimaryPartCFrame(v2(t23))
                    wait(0.05)
                end
            end

            local vector3 = Vector3.new(-86, -224.27, 34.57)

            if v552 then
                v552:SetPrimaryPartCFrame(CFrame.new(vector3))
                HumanoidRootPart.CFrame = CFrame.new(vector3 + Vector3.new(0, 5, 0))
            end

            wait(0.5)
            HumanoidRootPart.Anchored = false
            Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

            if v552 then
                v552:Destroy()
            end

            wait(0.5)
            HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPartPosition)
            HumanoidRootPart.Anchored = Anchored
            Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
        end
        function t1.value40()
            v38(t1.value37)

            local kkselectedPlayer = game.Players:FindFirstChild(getgenv().kkselectedPlayer)

            if not kkselectedPlayer or (not kkselectedPlayer.Character or not kkselectedPlayer.Character:FindFirstChild("HumanoidRootPart")) then
                return
            end

            local v528 = t1.value37.Character or t1.value37.CharacterAdded:Wait()
            local Humanoid = v528:WaitForChild("Humanoid")
            local HumanoidRootPart = v528:WaitForChild("HumanoidRootPart")
            local Humanoid3 = kkselectedPlayer.Character:FindFirstChild("Humanoid")
            local HumanoidRootPartPosition = HumanoidRootPart.Position
            local Anchored = HumanoidRootPart.Anchored

            HumanoidRootPart.CFrame = CFrame.new(1211.17712, 2.84999919, 739.555908)
            wait(1)

            local v534 = game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Ca1r")
            local t24 = { unpack({
				"PickingCar",
				"SchoolBus"
			}) }

            v534:FireServer(v2(t24))
            wait(0.5);
            (function()
                local v1449 = workspace.Vehicles:FindFirstChild(t1.value37.Name .. "Car")

                if not v1449 then
                    return
                end

                local VehicleSeat = v1449.Body:FindFirstChild("VehicleSeat")

                if not VehicleSeat then
                    return
                end

                HumanoidRootPart.Anchored = false
                Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                wait(0.2)
                HumanoidRootPart.CFrame = VehicleSeat.CFrame * CFrame.new(0, 0.5, 0)
                wait(0.2)
                Humanoid.Sit = true
                firetouchinterest(HumanoidRootPart, VehicleSeat, 0)
                firetouchinterest(HumanoidRootPart, VehicleSeat, 1)
                wait(0.5)

                if VehicleSeat ~= Humanoid.SeatPart then
                    HumanoidRootPart.CFrame = VehicleSeat.CFrame * CFrame.new(0, 0.5, 0)
                    Humanoid.Sit = true
                    wait(0.5)
                end
            end)()
            wait(0.5)

            local HumanoidRootPartPosition4 = kkselectedPlayer.Character.HumanoidRootPart.Position
            local v537 = workspace.Vehicles:FindFirstChild(t1.value37.Name .. "Car")

            if v537 then
                v537:SetPrimaryPartCFrame(CFrame.new(HumanoidRootPartPosition4 + Vector3.new(0, -2, 0)))
                HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPartPosition4 + Vector3.new(0, 5, 0))
                tick()

                while not (Humanoid3 and Humanoid3.SeatPart) do
                    local vector3 = Vector3.new(math.random(-8, 8), math.random(-3, 1), math.random(-8, 8))
                    local new = CFrame.new
                    local v540 = HumanoidRootPartPosition4 + Vector3.new(0, -2, 0)
                    local SetPrimaryPartCFrame = v537.SetPrimaryPartCFrame
                    local t25 = { new(v540 + vector3) }

                    SetPrimaryPartCFrame(v537, v2(t25))
                    wait(0.05)
                end
            end

            local vector3 = Vector3.new(-86, -224.27, 34.57)

            if v537 then
                local t26 = { CFrame.new(vector3) }

                v537:SetPrimaryPartCFrame(v2(t26))
                HumanoidRootPart.CFrame = CFrame.new(vector3 + Vector3.new(0, 5, 0))
            end

            wait(0.5)
            v537:Destroy()
            HumanoidRootPart.Anchored = false
            Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

            if v537 then
                v537:Destroy()
            end

            wait(0.5)
            HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPartPosition)
            HumanoidRootPart.Anchored = Anchored
            Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
        end
        function t1.value41()
            local LocalPlayer8 = game.Players.LocalPlayer
            local hiddenfling = t1.value2.hiddenfling
            local g587
            if not t1.value2.hiddenfling then
                if t1.value2.antiFlingWasEnabled == nil then
                    t1.value2.antiFlingWasEnabled = _G.AntiFling
                end

                _G.AntiFling = false
                t1.value2.hiddenfling = true

                if t1.value2.AntiFlingToggle then
                    t1.value2.AntiFlingToggle:Set(false)
                end
            end
            if getgenv().kkselectedPlayer then
                v38(LocalPlayer8)

                local kkselectedPlayer = game.Players:FindFirstChild(getgenv().kkselectedPlayer)

                if kkselectedPlayer then
                    local PrimaryPartPosition
                    if LocalPlayer8.Character and LocalPlayer8.Character.PrimaryPart then
                        PrimaryPartPosition = LocalPlayer8.Character.PrimaryPart.Position
                    end
                    local v582
                    local v583, v584, v585 = pairs(LocalPlayer8.Backpack:GetChildren())
                    local v586
                    repeat
                        v585, v586 = v583(v584, v585)

                        if not v585 then
                            g587 = true
                        end

                        if g587 then
                            break
                        end
                    until v586.Name == "Couch"
                    if not g587 then
                        v582 = v586
                    end
                    if not v582 then
                        local t27 = {
							[1] = "PickingTools",
							[2] = "Couch"
						}

                        game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l"):InvokeServer(unpack(t27))

                        repeat
                            task.wait(0.1)

                            for _, child in pairs(LocalPlayer8.Backpack:GetChildren()) do
                                if child.Name == "Couch" then
                                    v582 = child

                                    break
                                end
                            end
                        until v582
                    end
                    if v582 then
                        v582.Parent = LocalPlayer8.Character
                    end
                    local Character = kkselectedPlayer.Character
                    local v592 = Character and Character:FindFirstChild("Humanoid")
                    if v592 and v592.Sit then
                        killing = false

                        local value17 = t1.value17
                        local v594 = t1.value10("player is sitting!")
                        local v595 = t1.value10("The player is sitting on something.")

                        value17:MakeNotification({
							Name = v594,
							Content = v595,
							Image = "rbxassetid://4483345998",
							Time = 2
						})

                        return
                    end
                    local v596 = Character
                    if Character then
                        v596 = Character.PrimaryPart and (LocalPlayer8.Character and LocalPlayer8.Character.PrimaryPart)
                    end
                    if v596 then
                        local v597 = Character.PrimaryPart.CFrame.LookVector * -2.5
                        local v598 = Character.PrimaryPart.Position + v597 + Vector3.new(0, 1.5, 0)
                        local Character2 = LocalPlayer8.Character
                        local t28 = { CFrame.new(v598, Character.PrimaryPart.Position) }

                        Character2:SetPrimaryPartCFrame(v2(t28))
                    end
                    task.wait(0.1)
                    local AlignPosition = Instance.new("AlignPosition")
                    AlignPosition.Name = "BringAttach"
                    AlignPosition.RigidityEnabled = true
                    AlignPosition.MaxForce = 1e999
                    AlignPosition.Responsiveness = 500
                    AlignPosition.Parent = LocalPlayer8.Character.PrimaryPart
                    local AlignOrientation = Instance.new("AlignOrientation")
                    AlignOrientation.Name = "BringRotate"
                    AlignOrientation.RigidityEnabled = false
                    AlignOrientation.MaxTorque = 1e999
                    AlignOrientation.Responsiveness = 100
                    AlignOrientation.Parent = LocalPlayer8.Character.PrimaryPart
                    local Attachment = Instance.new("Attachment", LocalPlayer8.Character.PrimaryPart)
                    local Attachment3 = Instance.new("Attachment", Character.PrimaryPart)
                    Attachment.Position = Vector3.new(0, -5, 0)
                    Attachment3.Position = Vector3.new(0, -5, 0)
                    AlignPosition.Attachment0 = Attachment
                    AlignPosition.Attachment1 = Attachment3
                    AlignOrientation.Attachment0 = Attachment
                    AlignOrientation.Attachment1 = Attachment3
                    task.spawn(function()
                        while AlignOrientation and AlignOrientation.Parent do
                            local timestamp = tick()
                            local v1465 = math.sin(timestamp * 10) * 45
                            local v1466 = math.cos(timestamp * 10)
                            local _math = math
                            local v1468 = v1466 * 45
                            local v1469 = _math.sin(timestamp * 10) * 45

                            Attachment.Orientation = Vector3.new(v1465, v1468, v1469)
                            wait(0.01)
                        end
                    end)
                    t1.value2.RunService.Heartbeat:Connect(function(_, _)
                        if Attachment and Attachment.Parent then
                            local timestamp = tick()
                            local v1473 = math.sin(timestamp * 10) * 3
                            local v1474 = math.sin(timestamp * 20) * 1.5
                            local v1475 = math.cos(timestamp * 10) * 3

                            Attachment.Position = Vector3.new(v1473, v1474, v1475)
                        end
                    end)
                    if v592 then
                        task.spawn(function()
                            local n2 = 0

                            if not (n2 >= 7) then
                                local _ = v592.SeatPart
                            end

                            repeat
                                task.wait(0.1)
                                n2 += 0.1

                                local v1478 = not v592.Parent

                                if not v1478 then
                                    v1478 = not v592:IsDescendantOf(game)
                                end
                            until v1478 or (n2 >= 7 or v592.SeatPart)

                            local v1479 = n2 >= 7

                            if not v1479 then
                                v1479 = not v592.Parent

                                if not v1479 then
                                    v1479 = not v592:IsDescendantOf(game)
                                end
                            end

                            if v1479 then
                                if AlignOrientation and AlignOrientation.Parent then
                                    AlignOrientation:Destroy()
                                end

                                if AlignPosition and AlignPosition.Parent then
                                    AlignPosition:Destroy()
                                end

                                task.wait(0.1)

                                if LocalPlayer8.Character and (LocalPlayer8.Character.PrimaryPart and PrimaryPartPosition) then
                                    local Character3 = LocalPlayer8.Character
                                    local t29 = { CFrame.new(PrimaryPartPosition) }

                                    Character3:SetPrimaryPartCFrame(v2(t29))
                                end
                            else
                                if AlignPosition then
                                    AlignPosition:Destroy()
                                end

                                if AlignOrientation then
                                    AlignOrientation:Destroy()
                                end

                                if Attachment then
                                    Attachment:Destroy()
                                end

                                if Attachment3 then
                                    Attachment3:Destroy()
                                end

                                task.wait(t1.value2.deletecoucSEC)

                                local t30 = {
									[1] = "PlayerWantsToDeleteTool",
									[2] = "Couch"
								}
                                local v1483 = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Clea1rTool1s")
                                local t31 = { unpack(t30) }

                                v1483:FireServer(v2(t31))
                                task.wait(t1.value2.TPoriginalSEC)

                                if PrimaryPartPosition then
                                    LocalPlayer8.Character:SetPrimaryPartCFrame(CFrame.new(PrimaryPartPosition))
                                end
                            end

                            if not hiddenfling then
                                t1.value2.hiddenfling = false

                                if t1.value2.antiFlingWasEnabled ~= nil then
                                    _G.AntiFling = t1.value2.antiFlingWasEnabled

                                    if t1.value2.AntiFlingToggle then
                                        t1.value2.AntiFlingToggle:Set(t1.value2.antiFlingWasEnabled)
                                    end

                                    t1.value2.antiFlingWasEnabled = nil
                                end
                            end
                        end)
                    end
                end
            end
        end
        function t1.value42()
            game:GetService("UserInputService")
            if not t1.value37 then
                return
            end
            local kkselectedPlayer = game.Players:FindFirstChild(getgenv().kkselectedPlayer)
            if not kkselectedPlayer then
                return
            end
            local v558 = workspace.WorkspaceCom and workspace.WorkspaceCom["001_SoccerBalls"]
            if not v558 then
                return
            end
            local u559 = v558:FindFirstChild("Soccer" .. t1.value37.Name)
            if not u559 then
                if not t1.value37.Backpack:FindFirstChild("SoccerBall") then
                    local t32 = {
						[1] = "PickingTools",
						[2] = "SoccerBall"
					}

                    pcall(function()
                        local v1453 = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l")

                        if v1453 and v1453.InvokeServer then
                            local t33 = { unpack(t32) }

                            v1453:InvokeServer(v2(t33))
                        end
                    end)
                    task.wait()
                end

                if t1.value37.Backpack:FindFirstChild("SoccerBall") then
                    t1.value37.Backpack.SoccerBall.Parent = t1.value37.Character
                    repeat
                        u559 = v558:FindFirstChild("Soccer" .. t1.value37.Name)
                        task.wait()
                    until u559
                    if t1.value37.Character and t1.value37.Character:FindFirstChild("SoccerBall") then
                        t1.value37.Character.SoccerBall.Parent = t1.value37.Backpack
                    end
                    task.wait()
                end
            end
            local v562 = kkselectedPlayer.Character or kkselectedPlayer.CharacterAdded:Wait()
            local v563 = v562 and v562:FindFirstChild("HumanoidRootPart") or v562:FindFirstChild("Torso")
            if not u559 or not v563 then
                return
            end
            for _, child in pairs(u559:GetChildren()) do
                local v566 = child

                if v566:IsA("BodyMover") then
                    pcall(function()
                        v566:Destroy()
                    end)
                end
            end
            local BodyVelocity = Instance.new("BodyVelocity")
            BodyVelocity.Velocity = Vector3.new(900000000, 900000000, 900000000)
            BodyVelocity.MaxForce = Vector3.new(1e999, 1e999, 1e999)
            BodyVelocity.P = 10000000000
            BodyVelocity.Parent = u559
            local BodyVelocity2 = Instance.new("BodyVelocity")
            BodyVelocity2.Velocity = Vector3.new(900000000, 900000000, 900000000)
            BodyVelocity2.MaxForce = Vector3.new(1e999, 1e999, 1e999)
            BodyVelocity2.P = 1000000000
            BodyVelocity2.Parent = v563
            local CurrentCamera = workspace.CurrentCamera
            local v570 = CurrentCamera and CurrentCamera.CameraSubject
            local v571 = CurrentCamera and CurrentCamera.CameraType
            local v572 = v562 and v562:FindFirstChildOfClass("Humanoid") or v563
            pcall(function()
                if CurrentCamera then
                    CurrentCamera.CameraType = Enum.CameraType.Custom
                    CurrentCamera.CameraSubject = v572
                end
            end)
            local ScreenGui;
            (function()
                local v1455 = t1.value37:FindFirstChild("PlayerGui") or t1.value37:WaitForChild("PlayerGui")

                if not v1455 then
                    return
                end

                local SpectateReturnGui = v1455:FindFirstChild("SpectateReturnGui")

                if SpectateReturnGui then
                    pcall(function()
                        SpectateReturnGui:Destroy()
                    end)
                end

                ScreenGui = Instance.new("ScreenGui")
                ScreenGui.Name = "SpectateReturnGui"
                ScreenGui.ResetOnSpawn = false
                ScreenGui.DisplayOrder = 1000
                ScreenGui.Parent = v1455

                local TextButton = Instance.new("TextButton")

                TextButton.Name = "ReturnCamButton"
                TextButton.Parent = ScreenGui
                TextButton.Position = UDim2.new(0.5, 0, 0.5, 0)
                TextButton.Position = UDim2.new(0.5, 0, 0.7, 0)
                TextButton.Size = UDim2.new(0, 60, 0, 60)
                TextButton.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
                TextButton.BorderSizePixel = 0
                TextButton.Text = "👁\239\184\143"
                TextButton.Font = Enum.Font.SourceSansBold
                TextButton.TextSize = 26
                TextButton.TextColor3 = Color3.fromRGB(240, 240, 240)
                TextButton.AutoButtonColor = true

                local UICorner = Instance.new("UICorner")

                UICorner.CornerRadius = UDim.new(1, 0)
                UICorner.Parent = TextButton

                local function v1459()
                    pcall(function()
                        if CurrentCamera and t1.value37.Character then
                            local Humanoid = t1.value37.Character:FindFirstChildOfClass("Humanoid")
                            local v2033 = t1.value37.Character:FindFirstChild("HumanoidRootPart") or t1.value37.Character.PrimaryPart

                            CurrentCamera.CameraType = Enum.CameraType.Custom

                            local v2034 = CurrentCamera

                            if not Humanoid then
                                if not v2033 then
                                    v2033 = CurrentCamera.CameraSubject
                                end

                                Humanoid = v2033
                            end

                            v2034.CameraSubject = Humanoid
                        end
                    end)
                    pcall(function()
                        ScreenGui:Destroy()
                    end)
                end

                TextButton.Activated:Connect(v1459)
                TextButton.MouseButton1Click:Connect(v1459)
            end)()
            local timestamp = tick()
            local n3 = 20
            local _, _ = pcall(function()
                while true do
                    local v1460 = v563

                    if v1460 then
                        v1460 = v563.Parent

                        if v1460 then
                            v1460 = v563:IsDescendantOf(game)
                        end
                    end

                    if not v1460 then
                        break
                    end

                    local v1461 = v562

                    if v1461 then
                        v1461 = v562.Parent

                        if v1461 then
                            v1461 = v562:IsDescendantOf(game)
                        end
                    end

                    if not v1461 or not (kkselectedPlayer and kkselectedPlayer.Parent) then
                        return
                    end

                    local v1462 = t1.value37.Character and t1.value37.Character.PrimaryPart or t1.value37.Character:FindFirstChild("HumanoidRootPart")

                    if not v1462 or (v563.Velocity and v563.Velocity.Magnitude or 0) > 5000 or (v563.Position - v1462.Position).Magnitude > 500 or v562:FindFirstChildOfClass("Humanoid") and v562:FindFirstChildOfClass("Humanoid").Health == 0 then
                        return
                    end

                    local v1463 = v563.Position + v563.Velocity / 1.5

                    pcall(function()
                        u559.CFrame = CFrame.new(v1463)
                    end)

                    if tick() - timestamp > n3 then
                        return
                    end

                    task.wait(0.016)
                end
            end)
            if BodyVelocity and BodyVelocity.Parent then
                pcall(function()
                    BodyVelocity:Destroy()
                end)
            end
            if BodyVelocity2 and BodyVelocity2.Parent then
                pcall(function()
                    BodyVelocity2:Destroy()
                end)
            end
            if ScreenGui and ScreenGui.Parent then
                pcall(function()
                    ScreenGui:Destroy()
                end)
            end
            pcall(function()
                if CurrentCamera then
                    if v570 and v570.Parent then
                        CurrentCamera.CameraSubject = v570
                    elseif t1.value37.Character and t1.value37.Character:FindFirstChildOfClass("Humanoid") then
                        CurrentCamera.CameraSubject = t1.value37.Character:FindFirstChildOfClass("Humanoid")
                    elseif t1.value37.Character and t1.value37.Character:FindFirstChild("HumanoidRootPart") then
                        CurrentCamera.CameraSubject = t1.value37.Character:FindFirstChild("HumanoidRootPart")
                    end

                    if v571 then
                        CurrentCamera.CameraType = v571

                        return
                    end

                    CurrentCamera.CameraType = Enum.CameraType.Custom
                end
            end)
        end

        local _Tab = Tab
        local v42 = t1.value10("Kill Type")
        local AddDropdown = _Tab.AddDropdown
        local v44 = t1.value10("Kill")

        AddDropdown(_Tab, {
			Name = v42,
			Default = v44,
			Options = {
				"Kill",
				"Kill Couch",
				"Fling",
				"Boat",
				"Ship",
				"Bus",
				"Ball"
			},
			Callback = function(p42)
            selectedKillType = p42
        end
		})
        Tab:AddButton({
			Name = t1.value10("Kill"),
			Callback = function()
            if not getgenv().kkselectedPlayer then
                return
            end

            if selectedKillType == "Kill" then
                v40()

                return
            end

            if selectedKillType == "Kill Couch" then
                t1.value36()

                return
            end

            if selectedKillType == "Fling" then
                t1.value41()

                return
            end

            if selectedKillType == "Boat" then
                t1.value38()

                return
            end

            if selectedKillType == "Ship" then
                t1.value39()

                return
            end

            if selectedKillType == "Bus" then
                t1.value40()

                return
            end

            if selectedKillType == "Ball" then
                t1.value42()
            end
        end
		})
        Tab:AddToggle({
			Name = t1.value10("Faster Kill Click Tool"),
			Default = false,
			Callback = function(p43)
            local UserInputService = game:GetService("UserInputService")
            local LocalPlayer9 = t1.value5.LocalPlayer
            if not LocalPlayer9 then
                return
            end
            local v609 = t1.value10("Fast kill")
            getgenv().selectedKillType = getgenv().selectedKillType or t1.value10("Kill")
            local u610
            local u611
            local t34 = {}
            local function v613()
                for _, v in ipairs(t34) do
                    local v1487 = v

                    pcall(function()
                        v1487:Disconnect()
                    end)
                end

                t34 = {}
            end
            local function v614()
                v613()
                for v1490, v1491 in ipairs({
						LocalPlayer9:FindFirstChild("Backpack"),
						LocalPlayer9.Character
					}) do

                    if v1491 then
                        for _, child in ipairs(v1491:GetChildren()) do
                            local v1494 = child

                            if v1494 and (v1494:IsA("Tool") and v1494.Name == v609) then
                                pcall(function()
                                    v1494:Destroy()
                                end)
                            end
                        end
                    end
                end
                if u611 then
                    pcall(function()
                        u611:Destroy()
                    end)
                    u611 = nil
                end
                u610 = nil
            end
            local function v615(p44)
                if not p44 or not p44.Parent then
                    return
                end

                getgenv().kkselectedPlayer = p44.Name

                if getgenv().selectedKillType == "Kill" then
                    pcall(v40)

                    return
                end

                if getgenv().selectedKillType == "Fling" then
                    pcall(t1.value41)

                    return
                end

                if getgenv().selectedKillType == "Boat" then
                    pcall(t1.value38)

                    return
                end

                if getgenv().selectedKillType == "Ship" then
                    pcall(t1.value39)

                    return
                end

                if getgenv().selectedKillType == "Bus" then
                    pcall(t1.value40)

                    return
                end

                if getgenv().selectedKillType == "Ball" then
                    pcall(t1.value42)
                end
            end
            local function v616()
                local Mouse = LocalPlayer9:GetMouse()

                if Mouse and Mouse.Target then
                    local Model = Mouse.Target:FindFirstAncestorOfClass("Model")

                    if Model then
                        local player = t1.value5:GetPlayerFromCharacter(Model)

                        if player then
                            return player
                        end
                    end
                end

                local CurrentCamera = workspace.CurrentCamera

                if not CurrentCamera then
                    return nil
                end

                local ViewportSize = CurrentCamera.ViewportSize
                local v1501 = CurrentCamera:ScreenPointToRay(ViewportSize.X / 2, ViewportSize.Y / 2)
                local PartOnRayWithIgnoreList = workspace:FindPartOnRayWithIgnoreList(Ray.new(v1501.Origin, v1501.Direction * 5000), { LocalPlayer9.Character })

                if PartOnRayWithIgnoreList then
                    local Model = PartOnRayWithIgnoreList:FindFirstAncestorOfClass("Model")

                    if Model then
                        local player = t1.value5:GetPlayerFromCharacter(Model)

                        if player then
                            return player
                        end
                    end
                end

                return nil
            end
            if p43 then
                v614()
                u610 = Instance.new("Tool")
                u610.Name = v609
                u610.ToolTip = t1.value10("Pickup the tool to show all type kill")
                u610.RequiresHandle = false
                u610.CanBeDropped = true
                u610.Parent = LocalPlayer9:WaitForChild("Backpack")
                table.insert(t34, u610.Activated:Connect(function()
                    local v1505 = v616()

                    if v1505 then
                        v615(v1505)
                    end
                end))
                table.insert(t34, u610.Equipped:Connect(function()
                    if u611 then
                        u611:Destroy()
                        u611 = nil
                    end

                    local ScreenGui = Instance.new("ScreenGui")

                    ScreenGui.Name = "FasterKillGui"
                    ScreenGui.ResetOnSpawn = false
                    ScreenGui.Parent = LocalPlayer9:WaitForChild("PlayerGui")

                    local Frame = Instance.new("Frame")

                    Frame.Size = UDim2.new(0, 205, 0, 165)
                    Frame.Position = UDim2.new(0.5, -100, 0.8, -160)
                    Frame.BackgroundTransparency = 0.2
                    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                    Frame.BorderSizePixel = 0
                    Frame.Parent = ScreenGui

                    local UICorner = Instance.new("UICorner")

                    UICorner.CornerRadius = UDim.new(0, 8)
                    UICorner.Parent = Frame

                    local TextLabel = Instance.new("TextLabel")

                    TextLabel.Size = UDim2.new(1, 0, 0, 24)
                    TextLabel.BackgroundTransparency = 1
                    TextLabel.Text = t1.value10("Select Kill Type") .. " : " .. (t1.value10(getgenv().selectedKillType) or getgenv().selectedKillType)
                    TextLabel.TextScaled = true
                    TextLabel.Font = Enum.Font.SourceSansBold
                    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    TextLabel.Parent = Frame

                    for i, v in ipairs({
							"Kill",
							"Fling",
							"Boat",
							"Ship",
							"Bus",
							"Ball"
						}) do
                        local v1512 = v
                        local Frame2 = Instance.new("Frame")

                        Frame2.Size = UDim2.new(1, -12, 0, 20)
                        Frame2.Position = UDim2.new(0, 6, 0, 27 + (i - 1) * 22)
                        Frame2.BackgroundTransparency = 0.3
                        Frame2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                        Frame2.BorderSizePixel = 0

                        local UICorner2 = Instance.new("UICorner")

                        UICorner2.CornerRadius = UDim.new(0, 4)
                        UICorner2.Parent = Frame2
                        Frame2.Parent = Frame

                        local TextButton = Instance.new("TextButton")

                        TextButton.Size = UDim2.new(1, 0, 1, 0)
                        TextButton.BackgroundTransparency = 1
                        TextButton.Text = t1.value10(v1512) or v1512
                        TextButton.Font = Enum.Font.SourceSans
                        TextButton.TextSize = 18
                        TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                        TextButton.AutoButtonColor = false
                        TextButton.Parent = Frame2

                        local Frame3 = Instance.new("Frame")

                        Frame3.Size = UDim2.new(1, 0, 1, 0)
                        Frame3.BackgroundTransparency = 0.7
                        Frame3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        Frame3.BorderSizePixel = 0
                        Frame3.Visible = false
                        Frame3.Parent = Frame2
                        TextButton.MouseEnter:Connect(function()
                            Frame3.Visible = true
                        end)
                        TextButton.MouseLeave:Connect(function()
                            Frame3.Visible = false
                        end)
                        TextButton.MouseButton1Click:Connect(function()
                            getgenv().selectedKillType = v1512
                            TextLabel.Text = t1.value10("Select Kill Type") .. " : " .. (t1.value10(v1512) or v1512)

                            for _, child in ipairs(Frame:GetChildren()) do
                                local v1891 = child:IsA("Frame")

                                if v1891 then
                                    v1891 = child ~= TextLabel

                                    if v1891 then
                                        v1891 = child ~= UICorner
                                    end
                                end

                                if v1891 and child:FindFirstChildWhichIsA("TextButton") then
                                    local v1892 = child.Parent == Frame and child.Position == Frame2.Position

                                    child.BackgroundTransparency = not v1892 and 0.3 or 0.1
                                    child.BackgroundColor3 = v1892 and Color3.fromRGB(31, 156, 214) or Color3.fromRGB(0, 0, 0)
                                end
                            end

                            Frame2.BackgroundTransparency = 0.1
                            Frame2.BackgroundColor3 = Color3.fromRGB(31, 156, 214)
                        end)

                        if v1512 == getgenv().selectedKillType then
                            Frame2.BackgroundTransparency = 0.1
                            Frame2.BackgroundColor3 = Color3.fromRGB(31, 156, 214)
                        end
                    end

                    u611 = ScreenGui
                end))
                table.insert(t34, u610.Unequipped:Connect(function()
                    if u611 then
                        u611:Destroy()
                    end
                end))
                table.insert(t34, UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed then
                        return
                    end

                    if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.C then
                        v614()
                    end
                end))
            else
                v614()
            end
        end
		})
        Tab:AddSection({
			Name = t1.value10("Bring System")
		})
        Tab:AddButton({
			Name = t1.value10("Bring Player"),
			Callback = function()
            local LocalPlayer10 = game.Players.LocalPlayer

            if getgenv().kkselectedPlayer then
                local kkselectedPlayer = game.Players:FindFirstChild(getgenv().kkselectedPlayer)

                v38(LocalPlayer10)

                if kkselectedPlayer then
                    local PrimaryPartPosition
                    local g625
                    if LocalPlayer10.Character and LocalPlayer10.Character.PrimaryPart then
                        PrimaryPartPosition = LocalPlayer10.Character.PrimaryPart.Position
                    end
                    local v620
                    local v621, v622, v623 = pairs(LocalPlayer10.Backpack:GetChildren())
                    local v624
                    repeat
                        v623, v624 = v621(v622, v623)

                        if not v623 then
                            g625 = true
                        end

                        if g625 then
                            break
                        end
                    until v624.Name == "Couch"
                    if not g625 then
                        v620 = v624
                    end
                    if not v620 then
                        local t35 = {
								[1] = "PickingTools",
								[2] = "Couch"
							}

                        game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l"):InvokeServer(unpack(t35))

                        repeat
                            task.wait(0.1)

                            for _, child in pairs(LocalPlayer10.Backpack:GetChildren()) do
                                if child.Name == "Couch" then
                                    v620 = child

                                    break
                                end
                            end
                        until v620
                    end
                    if v620 then
                        v620.Parent = LocalPlayer10.Character
                    end
                    local Character = kkselectedPlayer.Character
                    local v630 = Character and Character:FindFirstChild("Humanoid")
                    if v630 and v630.Sit then
                        killing = false

                        local value17 = t1.value17
                        local v632 = t1.value10("player is sitting!")
                        local v633 = t1.value10("The player is sitting on something.")

                        value17:MakeNotification({
								Name = v632,
								Content = v633,
								Image = "rbxassetid://4483345998",
								Time = 2
							})

                        return
                    end
                    if kkselectedPlayer.Character and kkselectedPlayer.Character.PrimaryPart then
                        local v634 = kkselectedPlayer.Character.PrimaryPart.Position - Vector3.new(0, 5, 0)

                        if LocalPlayer10.Character and LocalPlayer10.Character.PrimaryPart then
                            LocalPlayer10.Character:SetPrimaryPartCFrame(CFrame.new(v634))
                        end
                    end
                    task.wait(0.3)
                    local AlignPosition = Instance.new("AlignPosition")
                    AlignPosition.Name = "BringAttach"
                    AlignPosition.RigidityEnabled = true
                    AlignPosition.MaxForce = 1e999
                    AlignPosition.Responsiveness = 500
                    AlignPosition.Parent = LocalPlayer10.Character.PrimaryPart
                    local AlignOrientation = Instance.new("AlignOrientation")
                    AlignOrientation.Name = "BringRotate"
                    AlignOrientation.RigidityEnabled = false
                    AlignOrientation.MaxTorque = 1e999
                    AlignOrientation.Responsiveness = 100
                    AlignOrientation.Parent = LocalPlayer10.Character.PrimaryPart
                    local Attachment = Instance.new("Attachment", LocalPlayer10.Character.PrimaryPart)
                    local Attachment4 = Instance.new("Attachment", Character.PrimaryPart)
                    Attachment.Position = Vector3.new(0, -5, 0)
                    Attachment4.Position = Vector3.new(0, -5, 0)
                    AlignPosition.Attachment0 = Attachment
                    AlignPosition.Attachment1 = Attachment4
                    AlignOrientation.Attachment0 = Attachment
                    AlignOrientation.Attachment1 = Attachment4
                    task.spawn(function()
                        local n4 = 0

                        while AlignOrientation and AlignOrientation.Parent do
                            n4 += 15
                            Attachment.Orientation = Vector3.new(math.sin((math.rad(n4))) * 45, n4 % 360, 0)
                            task.wait(0.01)
                        end
                    end)
                    game:GetService("RunService").Heartbeat:Connect(function(_, _)
                        Attachment.Position = Attachment.Position + Vector3.new(0, math.sin(tick() * 20) * 0.5, 0)
                    end)
                    if v630 then
                        task.spawn(function()
                            local _ = v630.SeatPart

                            repeat
                                task.wait()
                            until v630.SeatPart

                            local vector3 = Vector3.new(0, 0, 0)
                            local Magnitude = (vector3 - Attachment.Position).Magnitude

                            game:GetService("RunService").Heartbeat:Connect(function(_, p48)
                                if (Attachment.Position - vector3).Magnitude > 0.1 then
                                    local v1895 = math.min(Magnitude * 1 * p48, (vector3 - Attachment.Position).Magnitude)

                                    Attachment.Position = Attachment.Position + (vector3 - Attachment.Position).Unit * v1895
                                end
                            end)

                            if PrimaryPartPosition then
                                LocalPlayer10.Character:SetPrimaryPartCFrame(CFrame.new(PrimaryPartPosition))
                            end

                            if AlignPosition and AlignPosition.Parent then
                                AlignPosition:Destroy()
                            end

                            if AlignOrientation and AlignOrientation.Parent then
                                AlignOrientation:Destroy()
                            end

                            task.wait(0.5)

                            local t36 = {
									[1] = "PlayerWantsToDeleteTool",
									[2] = "Couch"
								}

                            game:GetService("ReplicatedStorage").RE:FindFirstChild("1Clea1rTool1s"):FireServer(unpack(t36))
                            wait(0.1)

                            local t37 = {
									[1] = "PickingTools",
									[2] = "Couch"
								}
                            local v1527 = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l")
                            local t38 = { unpack(t37) }

                            v1527:InvokeServer(v2(t38))
                        end)
                    end
                end
            end
        end
		})
        Tab:AddSection({
			Name = t1.value10("Auto Features")
		})
        t1.value43 = false
        t1.value44 = false
        Tab:AddToggle({
			Name = t1.value10("Auto Kill"),
			Callback = function(p49)
            t1.value43 = p49

            if t1.value43 then
                local LocalPlayer11 = game.Players.LocalPlayer
                local Backpack = LocalPlayer11:FindFirstChild("Backpack")
                local Character = LocalPlayer11.Character
                local v643 = false
                local v644, v645, v646 = pairs(Backpack:GetChildren())
                local g648
                repeat
                    local v647

                    v646, v647 = v644(v645, v646)

                    if not v646 then
                        g648 = true
                    end

                    if g648 then
                        break
                    end
                until v647.Name == "Couch"
                if not g648 then
                    v643 = true
                end
                if not v643 then
                    for _, child in pairs(Character:GetChildren()) do
                        if child.Name == "Couch" then
                            v643 = true

                            break
                        end
                    end
                end
                if not v643 then
                    local t39 = {
							[1] = "PickingTools",
							[2] = "Couch"
						}

                    game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l"):InvokeServer(unpack(t39))
                end
                spawn(function()
                    local g1534
                    while t1.value43 do
                        if not t1.value44 then
                            local v1529
                            local v1530, v1531, v1532 = pairs(Backpack:GetChildren())
                            local v1533
                            repeat
                                v1532, v1533 = v1530(v1531, v1532)

                                if not v1532 then
                                    g1534 = true
                                end

                                if g1534 then
                                    break
                                end
                            until v1533.Name == "Couch"
                            if not g1534 then
                                v1529 = v1533
                            end
                            g1534 = false
                            if not v1529 then
                                for _, child in pairs(Character:GetChildren()) do
                                    if child.Name == "Couch" then
                                        v1529 = child

                                        break
                                    end
                                end
                            end
                            if v1529 then
                                for _, player in pairs(game.Players:GetPlayers()) do
                                    if player ~= LocalPlayer11 and (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) and (Character.PrimaryPart.Position - player.Character.PrimaryPart.Position).Magnitude <= t1.value2.DistancePlayerForKill then
                                        killTarget(player)

                                        break
                                    end
                                end
                            end
                        end

                        wait(0.5)
                    end
                end)
            end
        end
		})

        function killTarget(p50)
            local LocalPlayer12 = game.Players.LocalPlayer
            local v654 = not p50
            local g661
            if not v654 then
                v654 = not p50.Character or not p50.Character.PrimaryPart
            end
            if v654 then
                return
            end
            t1.value44 = true
            local PrimaryPartPosition = LocalPlayer12.Character.PrimaryPart.Position
            local v656
            local v657, v658, v659 = pairs(LocalPlayer12.Backpack:GetChildren())
            local v660
            repeat
                v659, v660 = v657(v658, v659)

                if not v659 then
                    g661 = true
                end

                if g661 then
                    break
                end
            until v660.Name == "Couch"
            if not g661 then
                v656 = v660
            end
            if not v656 then
                for _, child in pairs(LocalPlayer12.Character:GetChildren()) do
                    if child.Name == "Couch" then
                        v656 = child

                        break
                    end
                end
            end
            if v656 then
                v656.Parent = LocalPlayer12.Character
            end
            local Character = p50.Character
            local v665 = Character and Character:FindFirstChild("Humanoid")
            if v665 and v665.Sit then
                t1.value44 = false

                local value17 = t1.value17
                local v667 = t1.value10("player is sitting!")
                local v668 = t1.value10("The player is sitting on something.")

                value17:MakeNotification({
					Name = v667,
					Content = v668,
					Image = "rbxassetid://4483345998",
					Time = 2
				})

                return
            end
            local v669 = Character
            if v669 then
                v669 = Character.PrimaryPart and (LocalPlayer12.Character and LocalPlayer12.Character.PrimaryPart)
            end
            if v669 then
                local v670 = Character.PrimaryPart.CFrame.LookVector * -2.5
                local v671 = Character.PrimaryPart.Position + v670 + Vector3.new(0, 1.5, 0)

                LocalPlayer12.Character:SetPrimaryPartCFrame(CFrame.new(v671, Character.PrimaryPart.Position))
            end
            wait(0.3)
            local function v672(p51)
                for _, player in pairs(game.Players:GetPlayers()) do
                    if player ~= LocalPlayer12 and (player.Character and player.Character:FindFirstChild("Humanoid")) then
                        local Humanoid = player.Character.Humanoid
                        local Magnitude = (p51 - player.Character.PrimaryPart.Position).Magnitude

                        if Humanoid.Sit and Magnitude <= 7 then
                            local Character4 = player.Character

                            if Character4:FindFirstChild("Humanoid") then
                                local vector3 = Vector3.new(10000, 500, 10000)

                                Character4:SetPrimaryPartCFrame(CFrame.new(vector3))
                                wait(0.5)
                            end
                        end
                    end
                end
            end
            task.spawn(function()
                while t1.value44 do
                    v672(Character.PrimaryPart.Position)
                    wait(1)
                end
            end)
            local AlignPosition = Instance.new("AlignPosition")
            AlignPosition.Name = "KillAttach"
            AlignPosition.RigidityEnabled = true
            AlignPosition.MaxForce = 1e999
            AlignPosition.Responsiveness = 500
            AlignPosition.Parent = LocalPlayer12.Character.PrimaryPart
            local AlignOrientation = Instance.new("AlignOrientation")
            AlignOrientation.Name = "KillRotate"
            AlignOrientation.RigidityEnabled = false
            AlignOrientation.MaxTorque = 1e999
            AlignOrientation.Responsiveness = 100
            AlignOrientation.Parent = LocalPlayer12.Character.PrimaryPart
            local Attachment = Instance.new("Attachment", LocalPlayer12.Character.PrimaryPart)
            local Attachment5 = Instance.new("Attachment", Character.PrimaryPart)
            Attachment.Position = Vector3.new(0, -5, 0)
            Attachment5.Position = Vector3.new(0, -5, 0)
            AlignPosition.Attachment0 = Attachment
            AlignPosition.Attachment1 = Attachment5
            AlignOrientation.Attachment0 = Attachment
            AlignOrientation.Attachment1 = Attachment5
            task.spawn(function()
                while AlignOrientation and AlignOrientation.Parent do
                    local timestamp = tick()
                    local v1547 = math.sin(timestamp * 15) * 45
                    local v1548 = math.cos(timestamp * 15) * 45
                    local v1549 = math.sin(timestamp * 15) * 45

                    Attachment.Orientation = Vector3.new(v1547, v1548, v1549)
                    wait(0.01)
                end
            end)
            local connection = t1.value2.RunService.Heartbeat:Connect(function(_, _)
                if Attachment and Attachment.Parent then
                    local timestamp = tick()
                    local v1553 = math.sin(timestamp * 10)
                    local _math = math
                    local v1555 = v1553 * 1.5
                    local v1556 = _math.sin(timestamp * 20) * 0.5
                    local v1557 = math.cos(timestamp * 10) * 1.5

                    Attachment.Position = Vector3.new(v1555, v1556, v1557)
                end
            end)
            if v665 then
                task.spawn(function()
                    local n5 = 0

                    if not (n5 >= 3) then
                        local _ = v665.SeatPart
                    end

                    repeat
                        task.wait(0.1)
                        n5 += 0.1

                        local v1560 = not v665.Parent

                        if not v1560 then
                            v1560 = not v665:IsDescendantOf(game)
                        end
                    until v1560 or (n5 >= 3 or v665.SeatPart)

                    local v1561 = n5 >= 3

                    if not v1561 then
                        v1561 = not v665.Parent

                        if not v1561 then
                            v1561 = not v665:IsDescendantOf(game)
                        end
                    end

                    if v1561 then
                        if AlignPosition then
                            AlignPosition:Destroy()
                        end

                        if AlignOrientation then
                            AlignOrientation:Destroy()
                        end

                        if Attachment then
                            Attachment:Destroy()
                        end

                        if Attachment5 then
                            Attachment5:Destroy()
                        end

                        if PrimaryPartPosition then
                            local Character5 = LocalPlayer12.Character
                            local t40 = { CFrame.new(PrimaryPartPosition) }

                            Character5:SetPrimaryPartCFrame(v2(t40))
                        end

                        t1.value44 = false

                        return
                    end

                    if connection then
                        connection:Disconnect()
                    end

                    local vector3 = Vector3.new(0, 0, 0)

                    while (Attachment.Position - vector3).Magnitude > 0.1 do
                        local elapsed = wait()
                        local v1566 = vector3 - Attachment.Position

                        if v1566.Magnitude > 0 then
                            local v1567 = math.min(v1566.Magnitude, 25 * elapsed)

                            Attachment.Position = Attachment.Position + v1566.Unit * v1567
                        end
                    end

                    if AlignPosition then
                        AlignPosition:Destroy()
                    end

                    if AlignOrientation then
                        AlignOrientation:Destroy()
                    end

                    if Attachment then
                        Attachment:Destroy()
                    end

                    if Attachment5 then
                        Attachment5:Destroy()
                    end

                    local vector3_3 = Vector3.new(10000, 500, 10000)

                    if LocalPlayer12.Character and LocalPlayer12.Character.PrimaryPart then
                        local Character6 = LocalPlayer12.Character
                        local t41 = { CFrame.new(vector3_3) }

                        Character6:SetPrimaryPartCFrame(v2(t41))
                    end

                    wait(t1.value2.deletecoucSEC)

                    local t42 = {
						[1] = "PlayerWantsToDeleteTool",
						[2] = "Couch"
					}

                    game:GetService("ReplicatedStorage").RE:FindFirstChild("1Clea1rTool1s"):FireServer(unpack(t42))
                    wait(0.1)

                    local t43 = {
						[1] = "PickingTools",
						[2] = "Couch"
					}

                    game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l"):InvokeServer(unpack(t43))
                    wait(t1.value2.TPoriginalSEC)

                    if PrimaryPartPosition then
                        LocalPlayer12.Character:SetPrimaryPartCFrame(CFrame.new(PrimaryPartPosition))
                    end

                    wait(t1.value2.WaitForKillNext)
                    t1.value44 = false
                end)
            end
        end

        t1.value45 = false
        Tab:AddToggle({
			Name = t1.value10("Auto Kill Selected Player"),
			Default = false,
			Callback = function(p54)
            t1.value45 = p54

            if p54 then
                task.spawn(function()
                    while t1.value45 do
                        if getgenv().getgenv().kkselectedPlayer then
                            local kkselectedPlayer = game.Players:FindFirstChild(getgenv().getgenv().kkselectedPlayer)

                            if kkselectedPlayer and not t1.value44 then
                                killTarget(kkselectedPlayer)
                            end
                        end

                        wait(1)
                    end
                end)
            end
        end
		})

        local function v45()
            local LocalPlayer13 = game.Players.LocalPlayer
            local v680
            local v681
            local v682 = LocalPlayer13.Character and LocalPlayer13.Character.PrimaryPart.Position
            local v683, v684, v685 = pairs(LocalPlayer13.Backpack:GetChildren())
            local g687
            local v686
            repeat
                v685, v686 = v683(v684, v685)

                if not v685 then
                    g687 = true
                end

                if g687 then
                    break
                end
            until v686.Name == "Couch"
            if not g687 then
                v680 = v686
            end
            if not v680 then
                for _, child in pairs(LocalPlayer13.Character:GetChildren()) do
                    if child.Name == "Couch" then
                        v681 = child

                        break
                    end
                end
            end
            wait(0.3)
            local vector3 = Vector3.new(10000, 0, 10000)
            LocalPlayer13.Character:SetPrimaryPartCFrame(CFrame.new(vector3))
            wait(t1.value2.deletecoucSEC)
            if v681 then
                local t44 = {
					[1] = "PlayerWantsToDeleteTool",
					[2] = "Couch"
				}
                local v692 = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Clea1rTool1s")
                local t45 = { unpack(t44) }

                v692:FireServer(v2(t45))
            end
            wait(0.2)
            local t46 = {
				[1] = "PickingTools",
				[2] = "Couch"
			}
            local v695 = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l")
            local t47 = { unpack(t46) }
            v695:InvokeServer(v2(t47))
            wait(t1.value2.TPoriginalSEC)
            if v682 then
                LocalPlayer13.Character:SetPrimaryPartCFrame(CFrame.new(v682))
            end
            wait(0.4)
            for _, child in pairs(game.Workspace:GetChildren()) do
                if child.Name == "Couch" then
                    return
                end
            end
        end

        t1.value46 = false
        Tab:AddToggle({
			Name = t1.value10("Auto Manual Kill"),
			Callback = function(p55)
            t1.value46 = p55

            if t1.value46 then
                spawn(function()
                    local g1581
                    while t1.value46 do
                        local LocalPlayer14 = game.Players.LocalPlayer

                        if LocalPlayer14.Character and LocalPlayer14.Character.PrimaryPart then
                            local PrimaryPartPosition = LocalPlayer14.Character.PrimaryPart.Position
                            local v1576 = false
                            local v1577, v1578, v1579 = pairs(LocalPlayer14.Backpack:GetChildren())

                            repeat
                                local v1580

                                v1579, v1580 = v1577(v1578, v1579)

                                if not v1579 then
                                    g1581 = true
                                end

                                if g1581 then
                                    break
                                end
                            until v1580.Name == "Couch"

                            if not g1581 then
                                v1576 = true
                            end

                            g1581 = false

                            if not v1576 then
                                for _, child in pairs(LocalPlayer14.Character:GetChildren()) do
                                    if child.Name == "Couch" then
                                        v1576 = true

                                        break
                                    end
                                end
                            end

                            if v1576 then
                                for _, player in pairs(game.Players:GetPlayers()) do
                                    local v1586 = player ~= LocalPlayer14

                                    if v1586 then
                                        v1586 = player.Character and (player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid"))
                                    end

                                    if v1586 and (PrimaryPartPosition - player.Character.HumanoidRootPart.Position).Magnitude <= 7 then
                                        local Humanoid = player.Character:FindFirstChild("Humanoid")

                                        if Humanoid and Humanoid.SeatPart then
                                            v45()
                                        end
                                    end
                                end
                            end
                        end

                        wait(0.1)
                    end
                end)
            end
        end
		})
        Tab:AddSection({
			Name = t1.value10("Stop Kill For All Type")
		})
        Tab:AddButton({
			Name = t1.value10("Stop Killing"),
			Callback = function()
            t1.value37.Character:SetPrimaryPartCFrame(CFrame.new(currentPosition))

            local Character = game.Players.LocalPlayer.Character

            if Character and Character:FindFirstChild("HumanoidRootPart") then
                local HumanoidRootPart = Character.HumanoidRootPart
                local KillAttach = HumanoidRootPart:FindFirstChild("KillAttach")
                local KillRotate = HumanoidRootPart:FindFirstChild("KillRotate")

                if KillAttach then
                    KillAttach:Destroy()
                end

                if KillRotate then
                    KillRotate:Destroy()
                end
            end
        end
		})

        local _Tab2 = Tab
        local AddSection = _Tab2.AddSection
        local v48 = t1.value10("Catch player")

        AddSection(_Tab2, {
			IsPC = true,
			Name = v48
		})
        t1.value47 = "Kill"
        Tab:AddDropdown({
			Name = t1.value10("Catch Type"),
			Default = "Kill",
			Options = {
				"Kill",
				"Fling"
			},
			Callback = function(p56)
            t1.value47 = p56
        end
		})

        local _Tab3 = Tab
        local v50 = t1.value10("Catch And Kill Player")
        local E = Enum.KeyCode.E

        _Tab3:AddBind({
			Name = v50,
			Default = E,
			IsPC = true,
			Hold = false,
			Flag = "CatchAndKillPlayer",
			Callback = function()
            if t1.value2.disableCatchKill then
                return
            end
            local LocalPlayer15 = t1.value5.LocalPlayer
            local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
            local TweenService = game:GetService("TweenService")
            local Mouse = LocalPlayer15:GetMouse()
            local v709
            local v710
            local v711, v712, v713 = pairs(LocalPlayer15.Backpack:GetChildren())
            local g715
            local v714
            repeat
                v713, v714 = v711(v712, v713)

                if not v713 then
                    g715 = true
                end

                if g715 then
                    break
                end
            until v714.Name == "Couch"
            if not g715 then
                v709 = v714
            end
            g715 = false
            if not v709 then
                for _, child in pairs(LocalPlayer15.Character:GetChildren()) do
                    if child.Name == "Couch" then
                        v710 = child

                        break
                    end
                end
            end
            if not v709 and not v710 then
                local t48 = {
						[1] = "PickingTools",
						[2] = "Couch"
					}

                ReplicatedStorage4.RE:FindFirstChild("1Too1l"):InvokeServer(unpack(t48))
            end
            local v719
            if Mouse.Target then
                local Model = Mouse.Target:FindFirstAncestorOfClass("Model")

                if Model then
                    local player = t1.value5:GetPlayerFromCharacter(Model)

                    if player then
                        v719 = player
                    end
                end
            end
            if not v719 then
                v719 = (function(p57)
                    local v1594
                    local v1595 = p57 or 100
                    for _, player in pairs(t1.value5:GetPlayers()) do
                        if player ~= LocalPlayer15 and (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then
                            local Magnitude = (LocalPlayer15.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude

                            if Magnitude < v1595 then
                                v1595 = Magnitude
                                v1594 = player
                            end
                        end
                    end

                    return v1594
                end)(75)
            end
            if v719 then
                getgenv().kkselectedPlayer = v719.Name

                if t1.value47 == "Kill" then
                    killTarget(v719)
                elseif t1.value47 == "Fling" then
                    t1.value41()
                end;

                (function()
                    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))

                    ScreenGui.IgnoreGuiInset = true

                    local TextLabel = Instance.new("TextLabel")

                    TextLabel.Parent = ScreenGui
                    TextLabel.Size = UDim2.new(0, 150, 0, 50)
                    TextLabel.Position = UDim2.new(0, math.random(100, 800), 0, math.random(100, 500))
                    TextLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    TextLabel.BackgroundTransparency = 0.2
                    TextLabel.BorderSizePixel = 0
                    TextLabel.Text = "CATCH"
                    TextLabel.TextColor3 = Color3.new(1, 1, 1)
                    TextLabel.TextScaled = true
                    TextLabel.Font = Enum.Font.GothamBlack
                    TextLabel.TextStrokeTransparency = 0.5

                    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    local t49 = {
							TextTransparency = 1,
							BackgroundTransparency = 1,
							TextStrokeTransparency = 1
						}
                    local tween = TweenService:Create(TextLabel, tweenInfo, t49)

                    tween:Play()
                    tween.Completed:Connect(function()
                        ScreenGui:Destroy()
                    end)
                end)()
            end
        end
		})
    end

    Tab:AddToggle({
		Name = t1.value10("Disable Catch And Kill"),
		IsPC = true,
		Flag = "DisableCatch",
		Default = false,
		Callback = function(p58)
        t1.value2.disableCatchKill = p58
    end
	})
    Tab:AddSection({
		Name = t1.value10("More Features")
	})
    spawn(function()
        local n6 = 0.1
        local v724
        local Character
        local LocalPlayer16 = t1.value2.Players.LocalPlayer
        while true do
            t1.value2.RunService.Heartbeat:Wait()

            if t1.value2.hiddenfling then
                while true do
                    local hiddenfling = t1.value2.hiddenfling

                    if hiddenfling then
                        hiddenfling = not Character and (Character.Parent and (v724 and v724.Parent))
                    end

                    if not hiddenfling then
                        break
                    end

                    t1.value2.RunService.Heartbeat:Wait()
                    Character = LocalPlayer16.Character
                    v724 = Character and Character:FindFirstChild("HumanoidRootPart")
                end

                if t1.value2.hiddenfling then
                    local Velocity = v724.Velocity

                    v724.Velocity = Velocity * 10000 + Vector3.new(0, 10000, 0)
                    t1.value2.RunService.RenderStepped:Wait()

                    if Character and (Character.Parent and (v724 and v724.Parent)) then
                        v724.Velocity = Velocity
                    end

                    t1.value2.RunService.Stepped:Wait()

                    if Character and (Character.Parent and (v724 and v724.Parent)) then
                        v724.Velocity = Velocity + Vector3.new(0, n6, 0)
                        n6 *= -1
                    end
                end
            end
        end
    end)
    t1.value2.FlingToggle = Tab:AddToggle({
		Name = t1.value10("Fling"),
		Flag = "FlingToggle",
		Default = false,
		Callback = function(p59)
        if p59 then
            if t1.value2.antiFlingWasEnabled == nil then
                t1.value2.antiFlingWasEnabled = _G.AntiFling
            end

            _G.AntiFling = false
            t1.value2.hiddenfling = true

            if t1.value2.AntiFlingToggle then
                t1.value2.AntiFlingToggle:Set(false)

                return
            end
        else
            t1.value2.hiddenfling = false

            if t1.value2.antiFlingWasEnabled ~= nil then
                _G.AntiFling = t1.value2.antiFlingWasEnabled

                if t1.value2.AntiFlingToggle then
                    t1.value2.AntiFlingToggle:Set(t1.value2.antiFlingWasEnabled)
                end

                t1.value2.antiFlingWasEnabled = nil
            end
        end
    end
	})
    Tab:AddToggle({
		Name = t1.value10("Fling Doors"),
		Default = false,
		Callback = function(p60)
        local Workspace = game:GetService("Workspace")
        local UserInputService = game:GetService("UserInputService")
        local LocalPlayer17 = t1.value5.LocalPlayer
        local HumanoidRootPart = (LocalPlayer17.Character or LocalPlayer17.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
        local v735 = Tab._FlingDoorsState or {}

        Tab._FlingDoorsState = v735

        if p60 then
            if v735.Active then
                return
            end

            v735.Active = true
            v735.ControlledDoors = {}

            local Part = Instance.new("Part")

            Part.Size = Vector3.new(100000000, 100000000, 100000000)
            Part.Transparency = 1
            Part.Anchored = true
            Part.CanCollide = false
            Part.Name = "BlackHoleTarget"
            Part.Parent = Workspace
            v735.BlackHole = Part

            local Attachment = Instance.new("Attachment")

            Attachment.Name = "Luscaa_BlackHoleAttachment"
            Attachment.Parent = Part
            v735.BaseAttachment = Attachment
            v735.HeartbeatConn = t1.value4.Heartbeat:Connect(function()
                Part.CFrame = HumanoidRootPart.CFrame
            end)

            local function v738(p61)
                if not p61:IsA("BasePart") or (p61.Anchored or not string.find(p61.Name, "Door")) then
                    return
                end

                if p61:FindFirstChild("Luscaa_Attached") then
                    return
                end

                p61.CanCollide = false

                for _, child in ipairs(p61:GetChildren()) do
                    if child:IsA("AlignPosition") or (child:IsA("Torque") or child:IsA("Attachment")) then
                        child:Destroy()
                    end
                end

                Instance.new("BoolValue", p61).Name = "Luscaa_Attached"

                local Attachment6 = Instance.new("Attachment", p61)
                local AlignPosition = Instance.new("AlignPosition", p61)

                AlignPosition.Attachment0 = Attachment6
                AlignPosition.Attachment1 = Attachment
                AlignPosition.MaxForce = 1E+30
                AlignPosition.MaxVelocity = 1e999
                AlignPosition.Responsiveness = 999999

                local Torque = Instance.new("Torque", p61)

                Torque.Attachment0 = Attachment6
                Torque.RelativeTo = Enum.ActuatorRelativeTo.World
                Torque.Torque = Vector3.new(math.random(-1000000, 1000000) * 1000000, math.random(-1000000, 1000000) * 1000000, math.random(-1000000, 1000000) * 1000000)
                table.insert(v735.ControlledDoors, {
						Part = p61,
						Align = AlignPosition
					})
            end

            for _, descendant in ipairs(Workspace:GetDescendants()) do
                if descendant:IsA("BasePart") and string.find(descendant.Name, "Door") then
                    v738(descendant)
                end
            end

            v735.DescConn = Workspace.DescendantAdded:Connect(function(descendant)
                if descendant:IsA("BasePart") and string.find(descendant.Name, "Door") then
                    v738(descendant)
                end
            end)

            local function v741(p62)
                local Character = p62.Character
                if not Character then
                    return
                end
                local HumanoidRootPart2 = Character:FindFirstChild("HumanoidRootPart")
                if not HumanoidRootPart2 then
                    return
                end
                local SHNMAX_TargetAttachment = HumanoidRootPart2:FindFirstChild("SHNMAX_TargetAttachment")
                if not SHNMAX_TargetAttachment then
                    SHNMAX_TargetAttachment = Instance.new("Attachment", HumanoidRootPart2)
                    SHNMAX_TargetAttachment.Name = "SHNMAX_TargetAttachment"
                end
                for v1612, v1613 in ipairs(v735.ControlledDoors) do

                    if v1613.Align then
                        v1613.Align.Attachment1 = SHNMAX_TargetAttachment
                    end
                end
                local timestamp = tick()
                while tick() - timestamp < 5 and not (HumanoidRootPart2.Velocity.Magnitude >= 20) do
                    t1.value4.Heartbeat:Wait()
                end
                for _, v in ipairs(v735.ControlledDoors) do
                    if v.Align then
                        v.Align.Attachment1 = Attachment
                    end
                end
            end

            v735.TouchConn = UserInputService.TouchTap:Connect(function(p63, p64)
                if p64 then
                    return
                end

                local v1619 = p63[1]
                local v1620 = Workspace.CurrentCamera:ScreenPointToRay(v1619.X, v1619.Y)
                local raycastResult = Workspace:Raycast(v1620.Origin, v1620.Direction * 1000)

                if raycastResult and raycastResult.Instance then
                    local Instance2 = raycastResult.Instance
                    local player = t1.value5:GetPlayerFromCharacter(Instance2:FindFirstAncestorOfClass("Model"))

                    if player and player ~= LocalPlayer17 then
                        v741(player)
                    end
                end
            end)

            return
        end

        if not v735.Active then
            return
        end

        v735.Active = false

        if v735.ControlledDoors then
            for _, v in ipairs(v735.ControlledDoors) do
                if v.Align then
                    v.Align.Attachment1 = v735.BaseAttachment
                end
            end
        end

        if v735.HeartbeatConn then
            v735.HeartbeatConn:Disconnect()
            v735.HeartbeatConn = nil
        end

        if v735.DescConn then
            v735.DescConn:Disconnect()
            v735.DescConn = nil
        end

        if v735.TouchConn then
            v735.TouchConn:Disconnect()
            v735.TouchConn = nil
        end

        if v735.ControlledDoors then
            for _, v in ipairs(v735.ControlledDoors) do
                local Part = v.Part

                if Part and Part.Parent then
                    local Luscaa_Attached = Part:FindFirstChild("Luscaa_Attached")

                    if Luscaa_Attached then
                        Luscaa_Attached:Destroy()
                    end

                    local Attachment = Part:FindFirstChildWhichIsA("Attachment")

                    if Attachment and Attachment.Name == "Luscaa_DoorAttachment" then
                        Attachment:Destroy()
                    end

                    local AlignPosition = Part:FindFirstChild("AlignPosition")

                    if AlignPosition and AlignPosition.Name == "Luscaa_DoorAlign" then
                        AlignPosition:Destroy()
                    end

                    local Torque = Part:FindFirstChild("Torque")

                    if Torque and Torque.Name == "Luscaa_DoorTorque" then
                        Torque:Destroy()
                    end
                end
            end
        end

        if v735.BlackHole and v735.BlackHole.Parent then
            v735.BlackHole:Destroy()
            v735.BlackHole = nil
        end

        v735.ControlledDoors = nil
        v735.BaseAttachment = nil
    end
	})
    getgenv().AutoCouchEnabled = false
    Tab:AddToggle({
		Name = t1.value10("Auto Get Sofa"),
		Flag = "AutoGetSofa",
		Default = false,
		Callback = function(p65)
        getgenv().AutoCouchEnabled = p65

        if p65 then
            task.spawn(function()
                while getgenv().AutoCouchEnabled do
                    local v1624 = false
                    local Backpack = t1.value31:FindFirstChild("Backpack")

                    if Backpack then
                        for _, child in pairs(Backpack:GetChildren()) do
                            if child.Name == "Couch" then
                                v1624 = true

                                break
                            end
                        end
                    end

                    if t1.value7 then
                        for _, child in pairs(t1.value7:GetChildren()) do
                            if child.Name == "Couch" then
                                v1624 = true

                                break
                            end
                        end
                    end

                    if not v1624 then
                        local t50 = {
								[1] = "PickingTools",
								[2] = "Couch"
							}

                        game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l"):InvokeServer(unpack(t50))
                    end

                    task.wait(1)
                end
            end)
        end
    end
	})
    Tab:AddButton({
		Name = t1.value10("Get/Remove Sofa"),
		Callback = function()
        local t51 = {
				[1] = "PickingTools",
				[2] = "Couch"
			}
        local v753 = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l")
        local t52 = { unpack(t51) }

        v753:InvokeServer(v2(t52))
    end
	})
    Tab:AddSection({
		Name = t1.value10("Kill Setting")
	})

    do
        local _Tab = Tab
        local v53 = t1.value10("Delay Before Tool Delete")
        local deletecoucSEC = t1.value2.deletecoucSEC
        local AddSlider = _Tab.AddSlider
        local v56 = t1.value10("sec")

        AddSlider(_Tab, {
			Name = v53,
			Min = 0.1,
			Max = 2,
			Default = deletecoucSEC,
			ValueName = v56,
			Flag = "DeleteToolSec1",
			Increment = 0.1,
			Callback = function(p66)
            t1.value2.deletecoucSEC = p66
        end
		})

        local _Tab4 = Tab
        local v58 = t1.value10("Delay Before Teleport Back")
        local TPoriginalSEC2 = t1.value2.TPoriginalSEC
        local value10 = t1.value10
        local AddSlider2 = _Tab4.AddSlider
        local v62 = value10("sec")

        AddSlider2(_Tab4, {
			Name = v58,
			Min = 0.1,
			Max = 2,
			Default = TPoriginalSEC2,
			ValueName = v62,
			Flag = "TeleportBackSec",
			Increment = 0.1,
			Callback = function(p67)
            TPoriginalSEC = p67
        end
		})
        Tab:AddSection({
			Name = t1.value10("For Auto Kill")
		})

        local _Tab5 = Tab
        local v64 = t1.value10("Distance For Target Player")
        local AddSlider3 = _Tab5.AddSlider
        local DistancePlayerForKill = t1.value2.DistancePlayerForKill
        local v67 = t1.value10("distance")

        AddSlider3(_Tab5, {
			Name = v64,
			Min = 1,
			Max = 2500,
			Flag = "DistanceTargetKill",
			Default = DistancePlayerForKill,
			ValueName = v67,
			Increment = 1,
			Callback = function(p68)
            t1.value2.DistancePlayerForKill = p68
        end
		})
    end

    do
        local _Tab = Tab
        local v69 = t1.value10("Wait For Kill Next Player")
        local value2 = t1.value2
        local AddSlider = _Tab.AddSlider
        local WaitForKillNext = value2.WaitForKillNext
        local v73 = t1.value10("sec")

        AddSlider(_Tab, {
			Name = v69,
			Min = 0.1,
			Max = 10,
			Flag = "SecForKillNextPlayer",
			Default = WaitForKillNext,
			ValueName = v73,
			Increment = 0.1,
			Callback = function(p69)
            t1.value2.WaitForKillNext = p69
        end
		})
        Tab = v24:MakeTab({
			Name = t1.value10("Player"),
			Icon = "rbxassetid://2795572800"
		})
        Tab:AddSection({
			Name = t1.value10("Name")
		})
        Tab:AddButton({
			Name = t1.value10("Empty Name"),
			Callback = function()
            local _game = game
            local t53 = {
					[1] = "RolePlayName",
					[2] = ""
				}

            _game:GetService("ReplicatedStorage").RE:FindFirstChild("1RPNam1eTex1t"):FireServer(unpack(t53))
        end
		})
        Tab:AddButton({
			Name = t1.value10("Empty Bio"),
			Callback = function()
            local t54 = {
					[1] = "RolePlayBio",
					[2] = ""
				}
            local v762 = game:GetService("ReplicatedStorage").RE:FindFirstChild("1RPNam1eTex1t")
            local t55 = { unpack(t54) }

            v762:FireServer(v2(t55))
        end
		})
        Tab:AddSection({
			Name = t1.value10("Player")
		})

        local _Tab6 = Tab
        local v75 = t1.value10("Player Speed")
        local originalSpeed = t1.value2.originalSpeed
        local originalSpeed2 = t1.value2.originalSpeed
        local value10 = t1.value10
        local AddSlider4 = _Tab6.AddSlider
        local v80 = value10("Speed")

        t1.value48 = AddSlider4(_Tab6, {
			Name = v75,
			Min = originalSpeed,
			Max = 250,
			Default = originalSpeed2,
			Increment = 1,
			ValueName = v80,
			Callback = function(p70)
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = p70
        end
		})
        game.Players.LocalPlayer.Character.Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            t1.value48:Set(game.Players.LocalPlayer.Character.Humanoid.WalkSpeed)
        end)
        Tab:AddButton({
			Name = t1.value10("Default Speed"),
			Callback = function()
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = t1.value2.originalSpeed
            t1.value48:Set(t1.value2.originalSpeed)
        end
		})

        local _Tab7 = Tab
        local v82 = t1.value10("Jump Power")
        local originalJumpPower = t1.value2.originalJumpPower
        local originalJumpPower2 = t1.value2.originalJumpPower
        local AddSlider5 = _Tab7.AddSlider
        local v86 = t1.value10("Power")

        t1.value49 = AddSlider5(_Tab7, {
			Name = v82,
			Min = originalJumpPower,
			Max = 250,
			Default = originalJumpPower2,
			Increment = 1,
			ValueName = v86,
			Callback = function(p71)
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = p71
        end
		})
    end

    game.Players.LocalPlayer.Character.Humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
        t1.value49:Set(game.Players.LocalPlayer.Character.Humanoid.JumpPower)
    end)
    Tab:AddButton({
		Name = t1.value10("Default Power"),
		Callback = function()
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = t1.value2.originalJumpPower
        t1.value49:Set(t1.value2.originalJumpPower)
    end
	})

    local _Tab = Tab
    local v88 = t1.value10("Fov")
    local originalFov = t1.value2.originalFov
    local v90 = t1.value10("Fov")

    t1.value50 = _Tab:AddSlider({
		Name = v88,
		Min = 1,
		Max = 150,
		Default = originalFov,
		Increment = 1,
		ValueName = v90,
		Callback = function(p72)
        workspace.CurrentCamera.FieldOfView = p72
    end
	})
    Tab:AddButton({
		Name = t1.value10("Default Fov"),
		Callback = function()
        workspace.CurrentCamera.FieldOfView = t1.value2.originalFov
        t1.value50:Set(t1.value2.originalFov)
    end
	})

    function t1.value51(p73, p74)
        for _, child in pairs(p73:GetChildren()) do
            if child:IsA("BasePart") then
                child.CanCollide = p74
            end
        end
    end

    Tab:AddSection({
		Name = t1.value10("Mods")
	})
    t1.value52 = false
    t1.value53 = nil
    Tab:AddToggle({
		Name = t1.value10("Infinite Jump"),
		Default = false,
		Callback = function(p75)
        t1.value52 = p75

        if not t1.value53 then
            game:GetService("UserInputService").JumpRequest:Connect(function()
                if t1.value52 then
                    local Character = game.Players.LocalPlayer.Character

                    if Character and Character:FindFirstChildOfClass("Humanoid") then
                        Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
                    end
                end
            end)
        end
    end
	})

    local _Tab8 = Tab
    local value10 = t1.value10
    local AddToggle = _Tab8.AddToggle
    local v94 = value10("Swim")
    local v95 = (function()
        local UserInputService = game:GetService("UserInputService")
        local u775 = false
        local Gravity = workspace.Gravity
        local u777
        local u778
        local function v779()
            if u775 then
                return
            end

            local v1632 = t1.value37.Character or t1.value37.CharacterAdded:Wait()
            local v1633 = v1632 and v1632:FindFirstChildWhichIsA("Humanoid")

            if not v1633 then
                return
            end

            Gravity = workspace.Gravity
            workspace.Gravity = 0
            u777 = v1633.Died:Connect(function()
                workspace.Gravity = Gravity
                u775 = false

                if u778 then
                    u778:Disconnect()
                    u778 = nil
                end

                if u777 then
                    u777:Disconnect()
                    u777 = nil
                end
            end)

            local EnumItems = Enum.HumanoidStateType:GetEnumItems()

            table.remove(EnumItems, table.find(EnumItems, Enum.HumanoidStateType.None))

            for _, v in pairs(EnumItems) do
                v1633:SetStateEnabled(v, false)
            end

            v1633:ChangeState(Enum.HumanoidStateType.Swimming)
            u778 = t1.value4.Heartbeat:Connect(function()
                pcall(function()
                    local v2035 = v1632 and v1632:FindFirstChild("HumanoidRootPart")

                    if not v2035 then
                        return
                    end

                    local v2036 = v1633.MoveDirection.Magnitude > 0

                    if not v2036 then
                        v2036 = UserInputService:IsKeyDown(Enum.KeyCode.Space)
                    end

                    if v2036 then
                        return
                    end

                    v2035.Velocity = Vector3.new()
                end)
            end)
            u775 = true
        end
        local function v780()
            if not u775 then
                return
            end

            if u777 then
                u777:Disconnect()
            end

            if u778 then
                u778:Disconnect()
            end

            workspace.Gravity = Gravity

            local Character = t1.value37.Character

            if Character then
                local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")

                if Humanoid then
                    local EnumItems = Enum.HumanoidStateType:GetEnumItems()

                    table.remove(EnumItems, table.find(EnumItems, Enum.HumanoidStateType.None))

                    for _, v in pairs(EnumItems) do
                        Humanoid:SetStateEnabled(v, true)
                    end
                end
            end
        end

        return function(p76)
            if p76 then
                v779()

                return
            end

            v780()
        end
    end)()

    AddToggle(_Tab8, {
		Name = v94,
		Default = false,
		Callback = v95
	})
    Tab:AddToggle({
		Name = t1.value10("No Clip"),
		Default = false,
		Callback = function(p77)
        noclipEnabled = p77

        local Character = game.Players.LocalPlayer.Character

        if noclipEnabled then
            noclipLoop = runService.Stepped:Connect(function()
                if Character then
                    t1.value51(Character, false)
                end
            end)

            return
        end

        if noclipLoop then
            noclipLoop:Disconnect()
        end

        if Character then
            t1.value51(Character, true)
        end
    end
	})
    t1.value54 = game:GetService("Workspace")
    Tab:AddToggle({
		Name = t1.value10("Gravity 0"),
		Default = false,
		Callback = function(p78)
        local Character = t1.value37.Character
        local v783 = Character and Character:FindFirstChild("Humanoid")

        if v783 then
            if p78 then
                t1.value2.Workspace.Gravity = 0
                v783.PlatformStand = true

                return
            end

            t1.value2.Workspace.Gravity = 196.2
            v783.PlatformStand = false
        end
    end
	})
    Tab:AddToggle({
		Name = t1.value10("Freeze"),
		Default = false,
		Callback = function(p79)
        local Character = t1.value37.Character
        local v786 = Character and Character:FindFirstChild("Humanoid")

        if v786 then
            if p79 then
                v786.PlatformStand = true

                return
            end

            v786.PlatformStand = false
        end
    end
	})
    Tab:AddToggle({
		Name = t1.value10("Anti Sit"),
		Default = false,
		Flag = "AntiSeatFlag",
		Callback = function(p80)
        t1.value2.antiSitActive = p80
        task.spawn(function()
            while t1.value2.antiSitActive and game.Players.LocalPlayer.Character do
                local Humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

                if Humanoid then
                    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

                    if Humanoid:GetState() == Enum.HumanoidStateType.Seated then
                        Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                end

                task.wait(0.05)
            end

            if not t1.value2.antiSitActive then
                local v1644 = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

                if v1644 then
                    v1644:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                end
            end
        end)
    end
	})

    local CoreGui = game:GetService("CoreGui")

    t1.value55 = game:GetService("Workspace").CurrentCamera

    local v97 = LocalPlayer3.Character or LocalPlayer3.CharacterAdded:Wait()

    t1.value56 = v97:WaitForChild("HumanoidRootPart")
    v97:WaitForChild("Humanoid")

    local ScreenGui = Instance.new("ScreenGui")

    ScreenGui.Name = "Shiftlock (CoreGui)"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    t1.value57 = Instance.new("ImageButton")
    t1.value57.Parent = ScreenGui
    t1.value57.BackgroundTransparency = 1
    t1.value57.Position = UDim2.new(0.7, 0, 0.75, 0)
    t1.value57.Size = UDim2.new(0.063, 0, 0.066, 0)
    t1.value57.SizeConstraint = Enum.SizeConstraint.RelativeXX
    t1.value57.Image = "rbxassetid://7986256039"
    t1.value57.Visible = false
    t1.value58 = Instance.new("ImageLabel")
    t1.value58.Name = "Shiftlock Cursor"
    t1.value58.Parent = ScreenGui
    t1.value58.Image = "rbxassetid://17404114716"
    t1.value58.Size = UDim2.new(0.03, 0, 0.03, 0)
    t1.value58.Position = UDim2.new(0.5, 0, 0.5, 0)
    t1.value58.AnchorPoint = Vector2.new(0.5, 0.5)
    t1.value58.SizeConstraint = Enum.SizeConstraint.RelativeXX
    t1.value58.BackgroundTransparency = 1
    t1.value58.Visible = false

    local function v99()
        if t1.value2.ShiftLockActive then
            local LookVector = t1.value55.CFrame.LookVector

            t1.value56.CFrame = CFrame.new(t1.value56.Position, t1.value56.Position + Vector3.new(LookVector.X, 0, LookVector.Z))
        end
    end

    function t1.value59(p81)
        if not t1.value2.ShiftLockEnabled then
            return
        end

        t1.value2.ShiftLockActive = p81

        if t1.value2.ShiftLockActive then
            t1.value2.UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            t1.value58.Visible = true
            t1.value2.RunService:BindToRenderStep("ShiftLockRotation", Enum.RenderPriority.Camera.Value, v99)

            return
        end

        t1.value2.UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        t1.value58.Visible = false
        t1.value2.RunService:UnbindFromRenderStep("ShiftLockRotation")
    end

    t1.value2.UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.C and t1.value2.ShiftLockEnabled then
            t1.value59(not t1.value2.ShiftLockActive)
        end
    end)
    t1.value57.MouseButton1Click:Connect(function()
        if t1.value2.ShiftLockEnabled then
            t1.value59(not t1.value2.ShiftLockActive)
        end
    end)

    local _Tab9 = Tab
    local v101 = t1.value10("Shift Lock")
    local v102 = t1.value10("For PC Press C")

    _Tab9:AddToggle({
		Name = v101,
		Default = false,
		Desc = v102,
		Callback = function(p82)
        t1.value2.ShiftLockEnabled = p82

        if t1.value2.ShiftLockEnabled then
            t1.value57.Visible = t1.value2.UserInputService.TouchEnabled

            return
        end

        t1.value57.Visible = false
        t1.value59(false)
    end
	})
    Tab:AddToggle({
		Name = t1.value10("Fast TP Right-Left"),
		Default = false,
		Save = false,
		Callback = function(p83)
        t1.value2.oscillateActive = p83

        if p83 then
            spawn(function()
                while t1.value2.oscillateActive do
                    local v1645 = t1.value2.player.Character or t1.value2.player.CharacterAdded:Wait()
                    local v1646 = v1645 and v1645:FindFirstChild("HumanoidRootPart")

                    if v1646 then
                        v1646.CFrame = v1646.CFrame * CFrame.new(20, 0, 0)
                    end

                    task.wait(0.001)

                    if not t1.value2.oscillateActive then
                        return
                    end

                    if v1646 then
                        v1646.CFrame = v1646.CFrame * CFrame.new(-20, 0, 0)
                    end

                    task.wait(0.001)
                end
            end)
        end
    end
	})

    local _Tab10 = Tab
    local v104 = t1.value10("FE Invisibility")
    local v105 = t1.value10("Invisibility works on all players")

    _Tab10:AddToggle({
		Name = v104,
		Desc = v105,
		Default = false,
		PremiumOnly = true,
		Flag = "FEInvisibility",
		Callback = function(p84)
        if _G.InvisConnections then
            for _, v in pairs(_G.InvisConnections) do
                v:Disconnect()
            end

            _G.InvisConnections = nil
        end

        local LocalPlayer18 = game.Players.LocalPlayer

        if not LocalPlayer18 then
            return
        end

        local u799 = LocalPlayer18.Character or LocalPlayer18.CharacterAdded:Wait()
        local Humanoid = u799:WaitForChild("Humanoid")
        local HumanoidRootPart = u799:WaitForChild("HumanoidRootPart")

        local function v802(p85)
            for _, descendant in pairs(u799:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    if descendant.Name == "HumanoidRootPart" then
                        descendant.LocalTransparencyModifier = not p85 and 0 or 1
                    else
                        descendant.LocalTransparencyModifier = not p85 and 0 or 0.5
                    end
                elseif descendant:IsA("Decal") then
                    descendant.Transparency = not p85 and 0 or 0.5
                end
            end
        end

        if p84 then
            v802(true)

            local t57 = {
					[1] = game:GetService("RunService").Heartbeat:Connect(function()
                if HumanoidRootPart and Humanoid then
                    local HumanoidRootPartCFrame = HumanoidRootPart.CFrame
                    local CameraOffset = Humanoid.CameraOffset
                    local v1652 = HumanoidRootPartCFrame * CFrame.new(0, -200000, 0)

                    HumanoidRootPart.CFrame = v1652

                    local v1653 = Humanoid
                    local t56 = { CFrame.new(HumanoidRootPartCFrame.Position) }

                    v1653.CameraOffset = v1652:ToObjectSpace(v2(t56)).Position
                    game:GetService("RunService").RenderStepped:Wait()
                    HumanoidRootPart.CFrame = HumanoidRootPartCFrame
                    Humanoid.CameraOffset = CameraOffset
                end
            end),
					[2] = LocalPlayer18.CharacterAdded:Connect(function()
                task.wait(1)
                u799 = LocalPlayer18.Character
                u799:WaitForChild("Humanoid")
                u799:WaitForChild("HumanoidRootPart")
                v802(true)
            end)
				}

            _G.InvisConnections = t57
        else
            v802(false)

            if _G.InvisConnections then
                for _, v in pairs(_G.InvisConnections) do
                    v:Disconnect()
                end

                _G.InvisConnections = nil
            end
        end
    end
	})
end
function t1.value60()
    local Character = game.Players.LocalPlayer.Character

    if Character and Character:FindFirstChild("Humanoid") then
        Character:FindFirstChild("Humanoid").Sit = true
    end
end
Tab:AddButton({
	Name = t1.value10("Sit"),
	Callback = function()
    t1.value60()
end
})
Tab:AddButton({
	Name = t1.value10("Fly"),
	Callback = function()
    local s1 = "https://raw.githubusercontent.com/as6cd0/RandomScripts/refs/heads/main/Fly"
    local success = pcall(function()
        loadstring(game:HttpGet(s1))()
    end)
    if success then
    end
end
})
Tab = v24:MakeTab({
	Name = t1.value10("Teleport"),
	Icon = "rbxassetid://12598594243"
})
Tab:AddSection({
	Name = t1.value10("Teleports")
})

do
    local cFrame = CFrame.new(0.469212, 6.858102, 0.614092)
    local cFrame2 = CFrame.new(4, 3, -120)
    local cFrame3 = CFrame.new(149.117783, 3.597955, -141.587067)
    local cFrame4 = CFrame.new(144.870056, 4.398026, 61.741516)
    local cFrame5 = CFrame.new(-41, 3, 254)
    local cFrame6 = CFrame.new(-104, 3, 260)
    local cFrame7 = CFrame.new(-126, 3, 253)
    local cFrame8 = CFrame.new(-129, 20, 254)
    local cFrame9 = CFrame.new(-160, 20, 288)
    local cFrame10 = CFrame.new(-159, 3, 259)
    local cFrame11 = CFrame.new(-155, 20, 248)
    local cFrame12 = CFrame.new(-156, 3, 133)
    local cFrame13 = CFrame.new(-127, 3, -110)
    local cFrame14 = CFrame.new(-8, 3, -342)
    local cFrame15 = CFrame.new(149, 4, -367)
    local cFrame16 = CFrame.new(316, 4, 39)
    local cFrame17 = CFrame.new(-168, 3, -110)
    local cFrame18 = CFrame.new(-73, 3, -124)
    local cFrame19 = CFrame.new(986, 4, 63)
    local cFrame20 = CFrame.new(672, 4, -296)
    local cFrame21 = CFrame.new(-312, 4, 211)
    local cFrame22 = CFrame.new(161, 8, 52)
    local cFrame23 = CFrame.new(-309, 4, 71)
    local cFrame24 = CFrame.new(-1925, 23, 127)
    local cFrame25 = CFrame.new(-589, 141, -59)
    local cFrame26 = CFrame.new(179, 4, -464)
    local cFrame27 = CFrame.new(-343, 4, -613)
    local cFrame28 = CFrame.new(-119, -28, 235)
    local cFrame29 = CFrame.new(1, 3, 264)
    local cFrame30 = CFrame.new(-9, 17, 257)

    t1.value61 = {
		Lobby = cFrame,
		Market = cFrame2,
		["Haven Plaza"] = cFrame3,
		["Burger Barn"] = cFrame4,
		RockStar = cFrame5,
		Starbucks = cFrame6,
		Library = cFrame7,
		["Iron Sights"] = cFrame8,
		Laundromat = cFrame9,
		["Post Office"] = cFrame10,
		["The Brick Restaurant"] = cFrame11,
		DayCare = cFrame12,
		["Ice Cream Shop"] = cFrame13,
		["Auto Mall"] = cFrame14,
		["Food Mart"] = cFrame15,
		Airport = cFrame16,
		Arcades = cFrame17,
		["Hair And Nails"] = cFrame18,
		["Abandoned House"] = cFrame19,
		["Portal Agency"] = cFrame20,
		School = cFrame21,
		["Brooks Diner"] = cFrame22,
		Hospital = cFrame23,
		Island = cFrame24,
		Arch = cFrame25,
		Agency = cFrame26,
		["Secret Room 2"] = cFrame27,
		["Criminal's"] = cFrame28,
		Bank = cFrame29,
		["Money Safe"] = cFrame30
	}
end
do
    local t59 = {
		"Lobby",
		"Market",
		"Haven Plaza",
		"Burger Barn",
		"RockStar",
		"Starbucks",
		"Library",
		"Iron Sights",
		"Laundromat",
		"Post Office",
		"The Brick Restaurant",
		"DayCare",
		"Ice Cream Shop",
		"Auto Mall",
		"Food Mart",
		"Airport",
		"Arcades",
		"Hair And Nails",
		"Abandoned House",
		"Portal Agency",
		"School",
		"Brooks Diner",
		"Hospital",
		"Island",
		"Arch",
		"Agency",
		"Secret Room 2",
		"Criminal's",
		"Bank",
		"Money Safe"
	}

    t1.value62 = t59[1]

    local _Tab = Tab
    local v138 = t1.value10("Teleports")
    local value62 = t1.value62

    _Tab:AddDropdown({
		Name = v138,
		Default = value62,
		Options = t59,
		Callback = function(p86)
        t1.value62 = p86
    end
	})
    Tab:AddButton({
		Name = t1.value10("Teleport Now"),
		Callback = function()
        local LocalPlayer19 = game.Players.LocalPlayer

        if not LocalPlayer19 then
            return
        end

        local v812 = LocalPlayer19.Character or LocalPlayer19.CharacterAdded:Wait()
        local u813 = v812 and v812:FindFirstChild("HumanoidRootPart") or v812.PrimaryPart or (v812:WaitForChild("HumanoidRootPart", 2) or v812.PrimaryPart)
        local v814 = t1.value61[t1.value62]

        if u813 and v814 then
            pcall(function()
                u813.CFrame = v814
            end)
        end
    end
	})
    Tab = v24:MakeTab({
		Name = t1.value10("Items"),
		Icon = "rbxassetid://484396034"
	})
    Tab:AddSection({
		Name = t1.value10("Get Item")
	})
    Tab:AddButton({
		Name = t1.value10("Get Sofa"),
		Callback = function()
        local _game = game
        local t60 = {
				[1] = "PickingTools",
				[2] = "Couch"
			}

        _game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l"):InvokeServer(unpack(t60))
    end
	})
    Tab:AddButton({
		Name = t1.value10("Get Crystal"),
		Callback = function()
        local t61 = {
				[1] = "PickingTools",
				[2] = "Crystal"
			}
        local v818 = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l")
        local t62 = { unpack(t61) }

        v818:InvokeServer(v2(t62))
    end
	})
    Tab:AddButton({
		Name = t1.value10("Get Crystals"),
		Callback = function()
        local t63 = {
				[1] = "PickingTools",
				[2] = "Crystals"
			}
        local v821 = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l")
        local t64 = { unpack(t63) }

        v821:InvokeServer(v2(t64))
    end
	})
    Tab:AddButton({
		Name = t1.value10("Get Agency Book"),
		Callback = function()
        local t65 = {
				[1] = "PickingTools",
				[2] = "AgencyBook"
			}
        local v824 = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l")
        local t66 = { unpack(t65) }

        v824:InvokeServer(v2(t66))
    end
	})
    Tab:AddButton({
		Name = t1.value10("Get Bank Key Card White"),
		Callback = function()
        local t67 = {
				[1] = "PickingTools",
				[2] = "KeyCardWhite"
			}
        local v827 = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l")
        local t68 = { unpack(t67) }

        v827:InvokeServer(v2(t68))
    end
	})
    Tab:AddButton({
		Name = t1.value10("Get Black Old Key"),
		Callback = function()
        local t69 = {
				[1] = "PickingTools",
				[2] = "BankGateKey"
			}

        game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l"):InvokeServer(unpack(t69))
    end
	})
    Tab:AddButton({
		Name = t1.value10("Get Duffle Bag Gold"),
		Callback = function()
        local t70 = {
				[1] = "PickingTools",
				[2] = "DuffleBagGold"
			}
        local v831 = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l")
        local t71 = { unpack(t70) }

        v831:InvokeServer(v2(t71))
    end
	})
    Tab:AddButton({
		Name = t1.value10("Get Duffle Bag Diamonds"),
		Callback = function()
        local t72 = {
				[1] = "PickingTools",
				[2] = "DuffleBagDiamonds"
			}
        local v834 = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l")
        local t73 = { unpack(t72) }

        v834:InvokeServer(v2(t73))
    end
	})
    Tab:AddButton({
		Name = t1.value10("Get Duffle Bag Bitcoin"),
		Callback = function()
        local t74 = {
				[1] = "PickingTools",
				[2] = "DuffleBagBitcoin"
			}
        local v837 = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l")
        local t75 = { unpack(t74) }

        v837:InvokeServer(v2(t75))
    end
	})
    Tab:AddButton({
		Name = t1.value10("Get Egg Launcher"),
		Callback = function()
        local LocalPlayer20 = game:GetService("Players").LocalPlayer
        local _game = game
        local t76 = {
				[1] = "AcceptedToolToServer",
				[2] = "EggLauncher",
				[3] = LocalPlayer20
			}
        local v842 = _game:GetService("ReplicatedStorage").RE:FindFirstChild("1Playe1rTrigge1rEven1t")
        local t77 = { unpack(t76) }

        v842:FireServer(v2(t77))
    end
	})
    Tab:AddButton({
		Name = t1.value10("Get Cannon"),
		Callback = function()
        local LocalPlayer21 = game:GetService("Players").LocalPlayer
        local t78 = {
				[1] = "AcceptedToolToServer",
				[2] = "Cannon",
				[3] = LocalPlayer21
			}

        game:GetService("ReplicatedStorage").RE:FindFirstChild("1Playe1rTrigge1rEven1t"):FireServer(unpack(t78))
    end
	})
    Tab:AddButton({
		Name = t1.value10("Get Glider"),
		Callback = function()
        local LocalPlayer22 = game:GetService("Players").LocalPlayer
        local t79 = {
				[1] = "AcceptedToolToServer",
				[2] = "Glider",
				[3] = LocalPlayer22
			}
        local v848 = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Playe1rTrigge1rEven1t")
        local t80 = { unpack(t79) }

        v848:FireServer(v2(t80))
    end
	})
    Tab:AddButton({
		Name = t1.value10("Get Water Balloon"),
		Callback = function()
        local LocalPlayer23 = game:GetService("Players").LocalPlayer
        local t81 = {
				[1] = "AcceptedToolToServer",
				[2] = "Water Balloon",
				[3] = LocalPlayer23
			}
        local v852 = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Playe1rTrigge1rEven1t")
        local t82 = { unpack(t81) }

        v852:FireServer(v2(t82))
    end
	})
    Tab:AddButton({
		Name = t1.value10("Get Uranium Rod"),
		Callback = function()
        local LocalPlayer24 = game:GetService("Players").LocalPlayer
        local t83 = {
				[1] = "AcceptedToolToServer",
				[2] = "UraniumRod",
				[3] = LocalPlayer24
			}
        local v856 = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Playe1rTrigge1rEven1t")
        local t84 = { unpack(t83) }

        v856:FireServer(v2(t84))
    end
	})
    Tab:AddButton({
		Name = t1.value10("Get Chainsaw"),
		Callback = function()
        local LocalPlayer25 = game:GetService("Players").LocalPlayer
        local t85 = {
				[1] = "AcceptedToolToServer",
				[2] = "Chainsaw",
				[3] = LocalPlayer25
			}
        local v860 = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Playe1rTrigge1rEven1t")
        local t86 = { unpack(t85) }

        v860:FireServer(v2(t86))
    end
	})
    Tab:AddButton({
		Name = t1.value10("Get Present"),
		Callback = function()
        local LocalPlayer26 = game:GetService("Players").LocalPlayer
        local t87 = {
				[1] = "AcceptedToolToServer",
				[2] = "Present",
				[3] = LocalPlayer26
			}

        game:GetService("ReplicatedStorage").RE:FindFirstChild("1Playe1rTrigge1rEven1t"):FireServer(unpack(t87))
    end
	})
    Tab:AddButton({
		Name = t1.value10("Delete All Items"),
		Callback = function()
        local t88 = {
				[1] = "ClearAllTools"
			}

        game:GetService("ReplicatedStorage").RE:FindFirstChild("1Clea1rTool1s"):FireServer(unpack(t88))
    end
	})
    Tab:AddSection({
		Name = t1.value10("Mods")
	})
    Tab:AddButton({
		Name = t1.value10("Teleport Tool"),
		Callback = function()
        mouse = game.Players.LocalPlayer:GetMouse()
        tool = Instance.new("Tool")
        tool.RequiresHandle = false
        tool.Name = "Teleporter Tool"
        tool.Activated:connect(function()
            local v1655 = mouse.Hit + Vector3.new(0, 2.5, 0)
            local cFrame = CFrame.new(v1655.X, v1655.Y, v1655.Z)

            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = cFrame
        end)
        tool.Parent = game.Players.LocalPlayer.Backpack
    end
	})
    Tab:AddButton({
		Name = t1.value10("Graper Tool"),
		Callback = function()
        local Mouse = game.Players.LocalPlayer:GetMouse()
        local Tool = Instance.new("Tool")
        Tool.RequiresHandle = false
        Tool.Name = "Graper Tool"
        local u867
        Tool.Activated:connect(function()
            if u867 then
                u867:Destroy()
                u867 = nil

                return
            end
            local MouseTarget = Mouse.Target
            local HumanoidRootPart
            if MouseTarget and (MouseTarget.Parent and MouseTarget.Parent:FindFirstChild("Humanoid")) then
                HumanoidRootPart = MouseTarget.Parent:FindFirstChild("HumanoidRootPart")
            elseif MouseTarget then
                HumanoidRootPart = MouseTarget
            end
            if HumanoidRootPart then
                local v1659 = (HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude * 1

                u867 = Instance.new("Part")
                u867.Size = Vector3.new(0, 1, v1659)
                u867.Position = (HumanoidRootPart.Position + game.Players.LocalPlayer.Character.HumanoidRootPart.Position) / 2
                u867.Anchored = false
                u867.CanCollide = false
                u867.BrickColor = BrickColor.new("Bright yellow")
                u867.Transparency = 1
                u867.Material = Enum.Material.SmoothPlastic
                u867.Parent = game.Workspace

                local RodConstraint = Instance.new("RodConstraint")

                RodConstraint.Attachment0 = game.Players.LocalPlayer.Character.HumanoidRootPart:FindFirstChild("Attachment") or Instance.new("Attachment", game.Players.LocalPlayer.Character.HumanoidRootPart)
                RodConstraint.Attachment1 = HumanoidRootPart:FindFirstChild("Attachment") or Instance.new("Attachment", HumanoidRootPart)
                RodConstraint.Length = v1659
                RodConstraint.Parent = u867
            end
        end)
        Tool.Parent = game.Players.LocalPlayer.Backpack
    end
	})
    Tab = v24:MakeTab({
		Name = t1.value10("Avatar"),
		Icon = "rbxassetid://11955919597"
	})
    Tab:AddSection({
		Name = t1.value10("Target Players")
	})
    AvatarPlayerDropdown = Tab:AddDropdown({
		Name = t1.value10("Players"),
		Default = "No Players",
		Options = { "No Players" },
		Callback = function(p87)
        if p87 ~= "No Players" then
            getgenv().dselectedPlayer = p87
        end
    end
	})

    local function v140()
        local t89 = {}

        for _, player in pairs(game.Players:GetPlayers()) do
            table.insert(t89, player.Name)
        end

        if #t89 == 0 then
            t89 = { "No Players" }
        end

        AvatarPlayerDropdown:Refresh(t89, true)
    end

    v140()
    game.Players.PlayerAdded:Connect(v140)
    game.Players.PlayerRemoving:Connect(v140)
    Tab:AddToggle({
		Name = t1.value10("Target Player Tool"),
		Default = false,
		Callback = function(p88)
        local Backpack = t1.value31:FindFirstChild("Backpack")

        if p88 then
            if Backpack:FindFirstChild(t1.value2.TargetToolName) or t1.value7 and t1.value7:FindFirstChild(t1.value2.TargetToolName) then
                return
            end

            local Tool = Instance.new("Tool")

            Tool.Name = t1.value2.TargetToolName
            Tool.RequiresHandle = false
            Tool.TextureId = "rbxassetid://87129552111975"
            Tool.ToolTip = "Click on a player to select them"
            Tool.Parent = Backpack
            Tool.Activated:Connect(function()
                local Target = t1.value31:GetMouse().Target

                if Target and Target.Parent then
                    local Model = Target:FindFirstAncestorOfClass("Model")

                    if Model then
                        local player = game.Players:GetPlayerFromCharacter(Model)

                        if player then
                            local playerName = player.Name

                            if playersDropdown and table.find(t1.value28, playerName) then
                                playersDropdown:Select(playerName)
                                getgenv().selectedPlayer = playerName
                            end

                            if killDropdown and table.find(t1.value28, playerName) then
                                killDropdown:Select(playerName)
                                getgenv().selectedPlayer = playerName
                            end

                            if Bangdropdown and table.find(t1.value28, playerName) then
                                Bangdropdown:Select(playerName)
                                getgenv().selectedPlayer = playerName
                            end

                            if AvatarPlayerDropdown and table.find(t1.value28, playerName) then
                                AvatarPlayerDropdown:Select(playerName)
                                getgenv().selectedPlayer = playerName
                            end
                        end
                    end
                end
            end)

            return
        end

        local t1value2TargetToolName = Backpack:FindFirstChild(t1.value2.TargetToolName)

        if t1value2TargetToolName then
            t1value2TargetToolName:Destroy()
        end

        if t1.value7 then
            local t1value2TargetToolName4 = t1.value7:FindFirstChild(t1.value2.TargetToolName)

            if t1value2TargetToolName4 then
                t1value2TargetToolName4:Destroy()
            end
        end
    end
	})
    Tab:AddSection({
		Name = t1.value10("Features")
	})

    local _Tab11 = Tab
    local v142 = t1.value10("Copy Avatar")
    local AddButton = _Tab11.AddButton
    local v144 = t1.value10("Do reset character avatar before copy (better)")

    AddButton(_Tab11, {
		Name = v142,
		Desc = v144,
		Callback = function()
        local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
        local Players = game:GetService("Players")
        local UserInputService = game:GetService("UserInputService")
        if not dselectedPlayer then
            local value17 = t1.value17
            local v881 = t1.value10("Error")
            local v882 = t1.value10("Please select a player first!")

            value17:MakeNotification({
					Name = v881,
					Content = v882,
					Image = "rbxassetid://6026568198",
					Time = 3
				})

            return
        end
        local LocalPlayer27 = Players.LocalPlayer
        local PlayerGui = LocalPlayer27:WaitForChild("PlayerGui")
        local Character = LocalPlayer27.Character
        local dselectedPlayer2 = Players:FindFirstChild(dselectedPlayer)
        if not dselectedPlayer2 or not dselectedPlayer2.Character then
            local value17 = t1.value17
            local v888 = t1.value10("Error")
            local v889 = t1.value10("Player not found or no character!")

            value17:MakeNotification({
					Name = v888,
					Content = v889,
					Image = "rbxassetid://6026568198",
					Time = 3
				})

            return
        end
        local v890 = Character and Character:FindFirstChildOfClass("Humanoid")
        local Humanoid = dselectedPlayer2.Character:FindFirstChildOfClass("Humanoid")
        if not v890 or not Humanoid then
            return
        end
        local v892 = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
        local ScreenGui = Instance.new("ScreenGui", PlayerGui)
        ScreenGui.Name = "AvatarCopyUI"
        ScreenGui.ResetOnSpawn = false
        local Frame = Instance.new("Frame", ScreenGui)
        Frame.Size = v892 and UDim2.new(0.9, 0, 0.75, 0) or UDim2.new(0, 360, 0, 280)
        Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
        Frame.AnchorPoint = Vector2.new(0.5, 0.5)
        Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        Frame.BorderSizePixel = 0
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)
        local TextLabel = Instance.new("TextLabel", Frame)
        TextLabel.Size = UDim2.new(1, 0, 0, 25)
        TextLabel.Text = t1.value10("Starting...")
        TextLabel.TextScaled = true
        TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.BackgroundTransparency = 1
        TextLabel.Font = Enum.Font.GothamBold
        local Frame4 = Instance.new("Frame", Frame)
        Frame4.Position = UDim2.new(0, 5, 0, 30)
        Frame4.Size = UDim2.new(1, -10, 0, 5)
        Frame4.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Frame4.BorderSizePixel = 0
        local Frame5 = Instance.new("Frame", Frame4)
        Frame5.Size = UDim2.new(0, 0, 1, 0)
        Frame5.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        Frame5.BorderSizePixel = 0
        local TextButton = Instance.new("TextButton", Frame)
        TextButton.Size = UDim2.new(0, 25, 0, 25)
        TextButton.Position = UDim2.new(1, -30, 0, 3)
        TextButton.Text = "X"
        TextButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        TextButton.TextColor3 = Color3.fromRGB(255, 0, 0)
        TextButton.Font = Enum.Font.GothamBold
        Instance.new("UICorner", TextButton).CornerRadius = UDim.new(0, 4)
        TextButton.MouseButton1Click:Connect(function()
            ScreenGui:Destroy()
        end)
        local u899
        local inputPosition
        local FramePosition
        Frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                u899 = true
                inputPosition = input.Position
                FramePosition = Frame.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if u899 and input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local v1667 = input.Position - inputPosition

                Frame.Position = FramePosition + UDim2.new(0, v1667.X, 0, v1667.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            end
        end)
        local ScrollingFrame = Instance.new("ScrollingFrame", Frame)
        ScrollingFrame.Position = UDim2.new(0, 0, 0, 40)
        ScrollingFrame.Size = UDim2.new(1, 0, 1, -40)
        ScrollingFrame.BackgroundTransparency = 1
        ScrollingFrame.ScrollBarThickness = 4
        ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 0)
        local UIGridLayout = Instance.new("UIGridLayout", ScrollingFrame)
        UIGridLayout.CellSize = v892 and UDim2.new(0, 65, 0, 65) or UDim2.new(0, 55, 0, 55)
        UIGridLayout.CellPadding = UDim2.new(0, 5, 0, 5)
        UIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIGridLayout.AbsoluteContentSize.Y + 10)
        end)
        local AppliedDescription
        local n7 = 0
        local function v906(p89)
            if not AppliedDescription or tick() - n7 > 0.3 then
                AppliedDescription = v890:GetAppliedDescription()
                n7 = tick()
            end

            if not AppliedDescription then
                return false
            end

            local str = tostring(p89)
            local v1671, v1672, v1673 = pairs({
					AppliedDescription.Shirt,
					AppliedDescription.Pants,
					AppliedDescription.Face,
					AppliedDescription.IdleAnimation,
					AppliedDescription.WalkAnimation,
					AppliedDescription.RunAnimation,
					AppliedDescription.JumpAnimation,
					AppliedDescription.FallAnimation,
					AppliedDescription.ClimbAnimation,
					AppliedDescription.SwimAnimation,
					AppliedDescription.Head,
					AppliedDescription.Torso,
					AppliedDescription.LeftArm,
					AppliedDescription.RightArm,
					AppliedDescription.LeftLeg,
					AppliedDescription.RightLeg
				})

            repeat
                local v1674

                v1673, v1674 = v1671(v1672, v1673)

                if not v1673 then
                    for _, v in ipairs(AppliedDescription:GetAccessories(true)) do
                        if str == tostring(v.AssetId) then
                            return true
                        end
                    end

                    return false
                end
            until str == tostring(v1674)

            return true
        end
        local t90 = {}
        local t91 = {}
        local t92 = {}
        local t93 = {}
        local function v911(p90)
            if not p90 or p90 == 0 then
                return
            end

            if t91[p90] then
                return
            end

            t91[p90] = true

            local ImageButton = Instance.new("ImageButton", ScrollingFrame)

            ImageButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            ImageButton.Image = "rbxthumb://type=Asset&id=" .. p90 .. "&w=150&h=150"
            Instance.new("UICorner", ImageButton).CornerRadius = UDim.new(0, 8)

            local UIStroke = Instance.new("UIStroke", ImageButton)

            UIStroke.Thickness = 2
            UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

            local function v1680()
                if v906(p90) then
                    UIStroke.Color = Color3.fromRGB(0, 255, 0)
                    ImageButton.BackgroundColor3 = Color3.fromRGB(30, 60, 30)

                    return
                end

                UIStroke.Color = Color3.fromRGB(255, 80, 80)
                ImageButton.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
            end

            v1680()
            ImageButton.MouseButton1Click:Connect(function()
                if not v906(p90) then
                    table.insert(t93, p90)
                end
            end)
            table.insert(t90, {
					id = p90,
					update = v1680,
					btn = ImageButton
				})
        end
        local AppliedDescription2 = v890:GetAppliedDescription()
        local AppliedDescription3 = Humanoid:GetAppliedDescription()
        local function v914(p91)
            local t94 = {}
            local ok, result = pcall(function()
                return p91:GetAccessories(true)
            end)

            if ok and result then
                for _, v in ipairs(result) do
                    if v.AssetId then
                        t94[tonumber(v.AssetId)] = true
                    end
                end
            end

            for _, v in ipairs({
					p91.HatAccessory,
					p91.HairAccessory,
					p91.FaceAccessory,
					p91.NeckAccessory,
					p91.FrontAccessory,
					p91.BackAccessory,
					p91.WaistAccessory
				}) do
                local v1689 = v

                if v then
                    v1689 = v ~= ""
                end

                if v1689 then
                    for match in string.gmatch(v, "%d+") do
                        t94[tonumber(match)] = true
                    end
                end
            end

            return t94
        end
        local v915 = v914(AppliedDescription2)
        local v916 = v914(AppliedDescription3)
        local t95 = {}
        for k in pairs(v915) do
            local v919 = k

            if not v916[v919] then
                table.insert(t95, v919)
            end
        end
        local t96 = {}
        for k in pairs(v916) do
            local v922 = k

            if not v915[v922] then
                table.insert(t96, v922)
            end
        end
        local v923 = tonumber(AppliedDescription2.Shirt) or 0
        local v924 = tonumber(AppliedDescription3.Shirt) or 0
        local v925 = tonumber(AppliedDescription2.Pants) or 0
        local v926 = tonumber(AppliedDescription3.Pants) or 0
        local v927 = tonumber(AppliedDescription2.GraphicTShirt) or 0
        local v928 = tonumber(AppliedDescription3.GraphicTShirt) or 0
        local v929 = tonumber(AppliedDescription2.Face) or 0
        local v930 = tonumber(AppliedDescription3.Face) or 0
        for v933, v934 in pairs({
				AppliedDescription3.Shirt,
				AppliedDescription3.Pants,
				AppliedDescription3.Face,
				AppliedDescription3.IdleAnimation,
				AppliedDescription3.WalkAnimation,
				AppliedDescription3.RunAnimation,
				AppliedDescription3.JumpAnimation,
				AppliedDescription3.FallAnimation,
				AppliedDescription3.ClimbAnimation,
				AppliedDescription3.SwimAnimation,
				AppliedDescription3.Head,
				AppliedDescription3.Torso,
				AppliedDescription3.LeftArm,
				AppliedDescription3.RightArm,
				AppliedDescription3.LeftLeg,
				AppliedDescription3.RightLeg
			}) do

            v911(v934)
        end
        local GetAccessories = AppliedDescription3.GetAccessories
        for v938, v939 in ipairs(GetAccessories(AppliedDescription3, true)) do

            v911(v939.AssetId)
        end
        if #t95 > 0 then
            TextLabel.Text = t1.value10("Removing old accessories...")

            for _, v in ipairs(t95) do
                local v942 = v

                pcall(function()
                    Remotes.Wear:InvokeServer((tonumber(v942)))
                end)
                task.wait(0.06)
            end
        end
        if v923 > 0 and v924 == 0 then
            pcall(function()
                Remotes.Wear:InvokeServer((tonumber(v923)))
            end)
            task.wait(0.06)
        end
        if v925 > 0 and v926 == 0 then
            pcall(function()
                local Wear = Remotes.Wear
                local t97 = { (tonumber(v925)) }

                Wear:InvokeServer(v2(t97))
            end)
            task.wait(0.06)
        end
        if v927 > 0 and v928 == 0 then
            pcall(function()
                local Wear = Remotes.Wear
                local t98 = { (tonumber(v927)) }

                Wear:InvokeServer(v2(t98))
            end)
            task.wait(0.06)
        end
        if v929 > 0 and v930 == 0 then
            pcall(function()
                Remotes.Wear:InvokeServer((tonumber(v929)))
            end)
            task.wait(0.06)
        end
        local v943 = AppliedDescription2.Torso ~= AppliedDescription3.Torso
        if not v943 then
            v943 = AppliedDescription2.RightArm ~= AppliedDescription3.RightArm

            if not v943 then
                v943 = AppliedDescription2.LeftArm ~= AppliedDescription3.LeftArm

                if not v943 then
                    v943 = AppliedDescription2.RightLeg ~= AppliedDescription3.RightLeg or (AppliedDescription2.LeftLeg ~= AppliedDescription3.LeftLeg or AppliedDescription2.Head ~= AppliedDescription3.Head)
                end
            end
        end
        if v943 then
            TextLabel.Text = t1.value10("Applying body parts...")

            local Torso = AppliedDescription3.Torso
            local RightArm = AppliedDescription3.RightArm
            local LeftArm = AppliedDescription3.LeftArm
            local RightLeg = AppliedDescription3.RightLeg
            local LeftLeg = AppliedDescription3.LeftLeg
            local Head = AppliedDescription3.Head
            local t99 = {
					[1] = {
						[1] = Torso,
						[2] = RightArm,
						[3] = LeftArm,
						[4] = RightLeg,
						[5] = LeftLeg,
						[6] = Head
					}
				}

            if not pcall(function()
                local ChangeCharacterBody = Remotes.ChangeCharacterBody
                local t100 = { unpack(t99) }

                ChangeCharacterBody:InvokeServer(v2(t100))
            end) then
                task.wait(0.3)
                pcall(function()
                    local ChangeCharacterBody = Remotes.ChangeCharacterBody
                    local t101 = { unpack(t99) }

                    ChangeCharacterBody:InvokeServer(v2(t101))
                end)
            end
        end
        local v951 = dselectedPlayer2.Character:FindFirstChild("Body Colors")
        local v952 = Character:FindFirstChild("Body Colors")
        local v953 = true
        if v951 and v952 then
            local v954 = tostring(v951.HeadColor) == tostring(v952.HeadColor)

            if v954 then
                v954 = tostring(v951.TorsoColor) == tostring(v952.TorsoColor)

                if v954 then
                    v954 = tostring(v951.LeftArmColor) == tostring(v952.LeftArmColor)

                    if v954 then
                        v954 = tostring(v951.RightArmColor) == tostring(v952.RightArmColor) and (tostring(v951.LeftLegColor) == tostring(v952.LeftLegColor) and tostring(v951.RightLegColor) == tostring(v952.RightLegColor))
                    end
                end
            end

            if v954 then
                v953 = false
            end
        end
        if v951 and (v953 and Remotes:FindFirstChild("ChangeBodyColor")) then
            pcall(function()
                Remotes.ChangeBodyColor:FireServer((tostring(v951.HeadColor)))
            end)
        end
        task.wait(0.2)
        local t102 = {}
        if v924 > 0 and v923 ~= v924 then
            table.insert(t102, v924)
        end
        if v926 > 0 and v925 ~= v926 then
            table.insert(t102, v926)
        end
        if v928 > 0 and v927 ~= v928 then
            table.insert(t102, v928)
        end
        if v930 > 0 and v929 ~= v930 then
            table.insert(t102, v930)
        end
        for v958 in pairs(t96) do

            table.insert(t102, v958)
        end
        for _, v in ipairs({
				"IdleAnimation",
				"WalkAnimation",
				"RunAnimation",
				"JumpAnimation",
				"FallAnimation",
				"ClimbAnimation",
				"SwimAnimation"
			}) do
            local v961 = tonumber(AppliedDescription2[v]) or 0
            local v962 = tonumber(AppliedDescription3[v]) or 0

            if v962 > 0 and v961 ~= v962 then
                table.insert(t102, v962)
            end
        end
        local n8 = 0
        local v964 = #t90
        local n9 = 0
        for _, v in ipairs(t90) do
            if v906(v.id) then
                n9 += 1
            end
        end
        local function v968()
            local v1699 = n9 / v964

            Frame5:TweenSize(UDim2.new(v1699, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
            TextLabel.Text = string.format(t1.value10("Equipping %d/%d"), n9, v964)
        end
        v968()
        TextLabel.Text = t1.value10("Starting to equip items...")
        task.spawn(function()
            local n10 = 1

            while n10 <= #t102 do
                while n8 >= 3 do
                    task.wait(0.05)
                end

                if not ScreenGui.Parent then
                    break
                end

                local v1702 = t102[n10]

                if not v906(v1702) then
                    local v1703 = v1702

                    n8 += 1
                    task.spawn(function()
                        local v1901 = t92[v1703] or {
								tries = 0,
								failed = false
							}

                        t92[v1703] = v1901

                        while not v906(v1703) and (not v1901.failed and v1901.tries < 6) do
                            v1901.tries = v1901.tries + 1

                            local ok, _ = pcall(function()
                                Remotes.Wear:InvokeServer((tonumber(v1703)))
                            end)

                            if not ok then
                                v1901.failed = true

                                break
                            end

                            task.wait(0.2)
                            AppliedDescription = v890:GetAppliedDescription()
                            n7 = tick()
                        end

                        if v1901.tries >= 6 then
                            v1901.failed = true
                        end

                        if v906(v1703) then
                            n9 += 1
                            v968()
                        end

                        for _, v in ipairs(t90) do
                            if v.id == v1703 then
                                v.update()

                                break
                            end
                        end

                        n8 -= 1
                    end)
                else
                    n9 += 1
                    v968()
                end

                n10 += 1
                task.wait(0.05)
            end

            while n8 > 0 do
                task.wait(0.05)
            end

            local n11 = 0

            AppliedDescription = v890:GetAppliedDescription()
            n7 = tick()

            for _, v in ipairs(t90) do
                v.update()

                if v906(v.id) then
                    n11 += 1
                end
            end

            TextLabel.Text = string.format(t1.value10("Done ✅ (%d/%d equipped)"), n11, #t90)
            Frame5.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            Frame5:TweenSize(UDim2.new(1, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
            task.wait(2)

            if ScreenGui.Parent then
                ScreenGui:Destroy()
            end
        end)
        local connection = v890.Changed:Connect(function(property)
            if property == "HipHeight" or property == "Health" then
                return
            end

            task.wait(0.1)
            AppliedDescription = v890:GetAppliedDescription()
            n7 = tick()

            for _, v in ipairs(t90) do
                v.update()
            end
        end)
        ScreenGui.Destroying:Connect(function()
            if connection then
                connection:Disconnect()
            end
        end)
    end
	})
    Tab:AddButton({
		Name = t1.value10("Reset Character Avatar"),
		Callback = function()
        game:GetService("ReplicatedStorage").Remotes.ResetCharacterAppearance:FireServer()
    end
	})
    Tab:AddSection({
		Name = t1.value10("Character Avatar")
	})
    t1.value63 = nil
    t1.value64 = {
		["Headless Head"] = 134082579,
		["Koroblox Right Leg"] = 139607718,
		["Koroblox Left Leg"] = 139607673,
		["Robot Head"] = 3210773801,
		["Blue Neon Eyes"] = 16580493236
	}
    Tab:AddDropdown({
		Name = t1.value10("Select Avatar Item"),
		Default = "Headless Head",
		Options = {
			"Headless Head",
			"Koroblox Right Leg",
			"Koroblox Left Leg",
			"Robot Head",
			"Blue Neon Eyes"
		},
		Callback = function(p92)
        t1.value63 = p92
    end
	})
    Tab:AddButton({
		Name = t1.value10("Apply Skin"),
		Callback = function()
        if t1.value63 and t1.value64[t1.value63] then
            local t103 = {
					[1] = t1.value64[t1.value63]
				}
            local Wear = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 9000000000):WaitForChild("Wear", 9000000000)
            local t104 = { unpack(t103) }

            Wear:InvokeServer(v2(t104))
        end
    end
	})
    Tab:AddSection({
		Name = t1.value10("Hats")
	})
    t1.value65 = nil
    t1.value66 = {
		["Cola (Sound)"] = 24114402,
		["Chicken (Sound)"] = 24112667,
		["Cola 2 (Sound)"] = 305888394,
		["Harmonica (Sound)"] = 33070696,
		Ghosdeeri = 183468963
	}
    Tab:AddDropdown({
		Name = t1.value10("Select Hat"),
		Default = "Cola (Sound)",
		Options = {
			"Cola (Sound)",
			"Chicken (Sound)",
			"Cola 2 (Sound)",
			"Harmonica (Sound)",
			"Ghosdeeri"
		},
		Callback = function(p93)
        t1.value65 = p93
    end
	})
    Tab:AddButton({
		Name = t1.value10("Apply Hat"),
		Callback = function()
        if t1.value65 and t1.value66[t1.value65] then
            local t105 = {
					[1] = t1.value66[t1.value65]
				}

            game:GetService("ReplicatedStorage").Remotes.Wear:InvokeServer(unpack(t105))
        end
    end
	})
    Tab:AddSection({
		Name = t1.value10("Character Tools")
	})
    t1.value67 = nil
    t1.value68 = {
		Axe = 3240543366,
		["Druid Of The Stage Staff"] = 3131092953,
		["Dread Druid Staff"] = 4840766306,
		["Tycoon Summoner Staff"] = 3210526113,
		["Erisyphia Staff"] = 3141364957
	}
    Tab:AddDropdown({
		Name = t1.value10("Select Tool"),
		Default = "Axe",
		Options = {
			"Axe",
			"Druid Of The Stage Staff",
			"Dread Druid Staff",
			"Tycoon Summoner Staff",
			"Erisyphia Staff"
		},
		Callback = function(p94)
        t1.value67 = p94
    end
	})
    Tab:AddButton({
		Name = t1.value10("Apply Tool"),
		Callback = function()
        if t1.value67 and t1.value68[t1.value67] then
            local v977 = t1.value68[t1.value67]
            local _game = game
            local t106 = {
					[1] = v977
				}

            _game:GetService("ReplicatedStorage").Remotes.Wear:InvokeServer(unpack(t106))
        end
    end
	})
    Tab:AddSection({
		Name = t1.value10("Horror Skins")
	})
    t1.value69 = nil
    t1.value70 = {
		["Michael Myers"] = 15133320948,
		["Mario Victim 1"] = 14732524763,
		Scary = 15036977826,
		["Scary dog"] = 14761007249,
		["Jeff The Killer"] = 14502327402
	}
    Tab:AddDropdown({
		Name = t1.value10("Select Horror Skin"),
		Default = "Michael Myers",
		Options = {
			"Michael Myers",
			"Mario Victim 1",
			"Scary",
			"Scary dog",
			"Jeff The Killer"
		},
		Callback = function(p95)
        t1.value69 = p95
    end
	})
    Tab:AddButton({
		Name = t1.value10("Apply Horror Skin"),
		Callback = function()
        if t1.value69 and t1.value70[t1.value69] then
            local t107 = {
					[1] = t1.value70[t1.value69]
				}
            local Wear = game:GetService("ReplicatedStorage").Remotes.Wear
            local t108 = { unpack(t107) }

            Wear:InvokeServer(v2(t108))
        end
    end
	})
    Tab:AddSection({
		Name = t1.value10("Skin")
	})
    t1.value71 = "Naked"
    t1.value72 = {
		Naked = 196054224
	}

    local _Tab12 = Tab
    local v146 = t1.value10("Select Skin")
    local value71 = t1.value71

    _Tab12:AddDropdown({
		Name = v146,
		Default = value71,
		Options = { "Naked" },
		Callback = function(p96)
        t1.value71 = p96
    end
	})
    Tab:AddButton({
		Name = t1.value10("Apply Skin"),
		Callback = function()
        if t1.value71 and t1.value72[t1.value71] then
            local t109 = {
					[1] = t1.value72[t1.value71]
				}

            game:GetService("ReplicatedStorage").Remotes.Wear:InvokeServer(unpack(t109))
        end
    end
	})
    Tab:AddSection({
		Name = t1.value10("Animations Run")
	})
    t1.value73 = nil
    t1.value74 = {
		["Mr Toilet Run"] = 4418324223,
		["Rthro Heavy Run"] = 3236849826,
		["Ud'zal's Run"] = 3307608414,
		["Adidas Run"] = 124765145869330
	}
    Tab:AddDropdown({
		Name = t1.value10("Select Animation"),
		Default = "Mr Toilet Run",
		Options = {
			"Mr Toilet Run",
			"Rthro Heavy Run",
			"Ud'zal's Run",
			"Adidas Run"
		},
		Callback = function(p97)
        t1.value73 = p97
    end
	})
    Tab:AddButton({
		Name = t1.value10("Apply Animation"),
		Callback = function()
        if t1.value73 and t1.value74[t1.value73] then
            local t110 = {
					[1] = t1.value74[t1.value73]
				}
            local Wear = game:GetService("ReplicatedStorage").Remotes.Wear
            local t111 = { unpack(t110) }

            Wear:InvokeServer(v2(t111))
        end
    end
	})
    Tab:AddSection({
		Name = t1.value10("Animations Idle")
	})
    t1.value75 = nil
    t1.value76 = {
		["Mr Toilet Idle"] = 4418326547,
		["Ud'zal's Idle"] = 3307605825,
		["Adidas Idle"] = 126354114956640
	}
    Tab:AddDropdown({
		Name = t1.value10("Select Idle Animation"),
		Default = "Mr Toilet Idle",
		Options = {
			"Mr Toilet Idle",
			"Ud'zal's Idle",
			"Adidas Idle"
		},
		Callback = function(p98)
        t1.value75 = p98
    end
	})
    Tab:AddButton({
		Name = t1.value10("Apply Idle"),
		Callback = function()
        if t1.value75 and t1.value76[t1.value75] then
            local t112 = {
					[1] = t1.value76[t1.value75]
				}
            local Wear = game:GetService("ReplicatedStorage").Remotes.Wear
            local t113 = { unpack(t112) }

            Wear:InvokeServer(v2(t113))
        end
    end
	})
    Tab = v24:MakeTab({
		Name = t1.value10("Car"),
		Icon = "rbxassetid://13773498965"
	})
    Tab:AddSection(t1.value10("Destroy Car"))
    t1.value77 = Tab:AddDropdown({
		Name = t1.value10("Players Cars"),
		Default = "No Cars Found",
		Options = { "No Cars Found" },
		Callback = function(p99)
        getgenv().deselectedplayer = p99
    end
	})

    local function v148()
        local t114 = {}
        local Vehicles = workspace:FindFirstChild("Vehicles")

        if Vehicles then
            for _, player in ipairs(game.Players:GetPlayers()) do
                if Vehicles:FindFirstChild(player.Name .. "Car") then
                    table.insert(t114, player.Name)
                end
            end
        end

        local value77 = t1.value77
        local v1000 = #t114 > 0 and t114

        if not v1000 then
            v1000 = { t1.value10("No Cars Found") }
        end

        value77:Refresh(v1000, true)

        if getgenv().deselectedplayer and getgenv().deselectedplayer ~= t1.value10("No Cars Found") then
            local v1001 = not Vehicles
            local v1002 = getgenv().deselectedplayer .. "Car"

            if not v1001 then
                v1001 = not Vehicles:FindFirstChild(v1002)
            end

            if v1001 then
                getgenv().deselectedplayer = t1.value10("No Cars Found")
            end
        end
    end

    v148()
    game.Players.PlayerAdded:Connect(v148)
    game.Players.PlayerRemoving:Connect(v148)

    local Vehicles = workspace:FindFirstChild("Vehicles")

    if Vehicles then
        Vehicles.ChildAdded:Connect(v148)
        Vehicles.ChildRemoved:Connect(v148)
    end
end
Tab:AddButton({
	Name = t1.value10("Destroy Car"),
	Callback = function()
    spawn(function()
        local Character = t1.value37.Character

        if not Character then
            return
        end

        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

        if not HumanoidRootPart then
            return
        end

        if not getgenv().deselectedplayer or getgenv().deselectedplayer == "No Cars Found" then
            return
        end

        local HumanoidRootPartPosition = HumanoidRootPart.Position
        local Anchored = HumanoidRootPart.Anchored
        local Vehicles = workspace:FindFirstChild("Vehicles")

        if not Vehicles then
            return
        end

        local v1715 = Vehicles:FindFirstChild(getgenv().deselectedplayer .. "Car")

        if not v1715 then
            return
        end

        local VehicleSeat = v1715:FindFirstChildOfClass("VehicleSeat")

        if not VehicleSeat then
            for _, descendant in ipairs(v1715:GetDescendants()) do
                if descendant:IsA("VehicleSeat") then
                    VehicleSeat = descendant

                    break
                end
            end
        end

        if not VehicleSeat then
            return
        end

        local Occupant = VehicleSeat.Occupant

        if Occupant then
            local OccupantParent = Occupant.Parent
            local v1721 = OccupantParent and t1.value5:GetPlayerFromCharacter(OccupantParent)
            local v1722 = v1721 and v1721.Name or (OccupantParent and OccupantParent.Name or "Unknown")

            pcall(function()
                local value17 = t1.value17
                local v1907 = t1.value10("Vehicle Occupied")
                local MakeNotification = value17.MakeNotification
                local v1909 = t1.value10("Player " .. tostring(v1722) .. " is seated on this vehicle")

                MakeNotification(value17, {
						Name = v1907,
						Image = "rbxassetid://10709752996",
						Content = v1909,
						Time = 5
					})
            end)

            return
        end

        Character:PivotTo(VehicleSeat.CFrame)
        task.wait(0.1)

        local Humanoid = Character:FindFirstChildOfClass("Humanoid")

        if Humanoid then
            local timestamp = tick()

            HumanoidRootPart.Anchored = false

            while tick() - timestamp < 5 and VehicleSeat ~= Humanoid.SeatPart do
                HumanoidRootPart.CFrame = VehicleSeat.CFrame * CFrame.new(0, 0.5, 0)
                Humanoid.Sit = true
                pcall(firetouchinterest, HumanoidRootPart, VehicleSeat, 0)
                pcall(firetouchinterest, HumanoidRootPart, VehicleSeat, 1)
                task.wait(0.1)
            end

            if VehicleSeat ~= Humanoid.SeatPart then
                HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPartPosition)
                HumanoidRootPart.Anchored = Anchored

                return
            end

            task.wait(0.5)

            local vector3 = Vector3.new(9999999999, 999999999, 9999999999)

            VehicleSeat.CFrame = CFrame.new(vector3)
            task.wait(0.3)

            if VehicleSeat == Humanoid.SeatPart then
                pcall(function()
                    Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                end)
                Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end

            pcall(function()
                Humanoid:LeaveVehicle()
            end)
            task.wait(0.5)

            local vector3_4 = Vector3.new(HumanoidRootPartPosition.X, HumanoidRootPartPosition.Y + 50, HumanoidRootPartPosition.Z)

            Character:PivotTo(CFrame.new(vector3_4))
            task.wait(0.2)
            Character:PivotTo(CFrame.new(HumanoidRootPartPosition))
            HumanoidRootPart.Anchored = Anchored
        end
    end)
end
})
Tab:AddButton({
	Name = t1.value10("Destroy Current Car"),
	Callback = function()
    spawn(function()
        local Character = game.Players.LocalPlayer.Character

        if not Character then
            pcall(function()
                local value17 = t1.value17
                local v1911 = t1.value10("Error")
                local v1912 = t1.value10("No character found")

                value17:MakeNotification({
						Name = v1911,
						Image = "rbxassetid://10709752996",
						Content = v1912,
						Time = 3
					})
            end)

            return
        end

        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

        if not HumanoidRootPart then
            pcall(function()
                local value17 = t1.value17
                local v1914 = t1.value10("Error")
                local MakeNotification = value17.MakeNotification
                local v1916 = t1.value10("No HumanoidRootPart found")

                MakeNotification(value17, {
						Name = v1914,
						Image = "rbxassetid://10709752996",
						Content = v1916,
						Time = 3
					})
            end)

            return
        end

        local Humanoid = Character:FindFirstChildOfClass("Humanoid")

        if not Humanoid then
            pcall(function()
                local value17 = t1.value17
                local v1918 = t1.value10("Error")
                local value10 = t1.value10
                local MakeNotification = value17.MakeNotification
                local v1921 = value10("No humanoid found")

                MakeNotification(value17, {
						Name = v1918,
						Image = "rbxassetid://10709752996",
						Content = v1921,
						Time = 3
					})
            end)

            return
        end

        if not Humanoid.SeatPart then
            pcall(function()
                local value17 = t1.value17
                local v1923 = t1.value10("Error")
                local value10 = t1.value10
                local MakeNotification = value17.MakeNotification
                local v1926 = value10("You are not sitting on any vehicle")

                MakeNotification(value17, {
						Name = v1923,
						Image = "rbxassetid://10709752996",
						Content = v1926,
						Time = 3
					})
            end)

            return
        end

        local SeatPart = Humanoid.SeatPart

        if not SeatPart or not SeatPart:IsA("VehicleSeat") then
            pcall(function()
                local value17 = t1.value17
                local v1928 = t1.value10("Error")
                local v1929 = t1.value10("You are not sitting on a valid vehicle seat")

                value17:MakeNotification({
						Name = v1928,
						Image = "rbxassetid://10709752996",
						Content = v1929,
						Time = 3
					})
            end)

            return
        end

        local SeatPartParent = SeatPart.Parent

        if not SeatPartParent or not SeatPartParent:IsA("Model") then
            pcall(function()
                local value17 = t1.value17
                local v1931 = t1.value10("Error")
                local value10 = t1.value10
                local MakeNotification = value17.MakeNotification
                local v1934 = value10("Cannot find vehicle")

                MakeNotification(value17, {
						Name = v1931,
						Image = "rbxassetid://10709752996",
						Content = v1934,
						Time = 3
					})
            end)

            return
        end

        if not workspace:FindFirstChild("Vehicles") then
            pcall(function()
                local value17 = t1.value17
                local v1936 = t1.value10("Error")
                local v1937 = t1.value10("Vehicles folder not found")

                value17:MakeNotification({
						Name = v1936,
						Image = "rbxassetid://10709752996",
						Content = v1937,
						Time = 3
					})
            end)

            return
        end

        local HumanoidRootPartPosition = HumanoidRootPart.Position
        local Anchored = HumanoidRootPart.Anchored

        pcall(function()
            local value17 = t1.value17
            local MakeNotification = value17.MakeNotification
            local v1940 = t1.value10("Car Destruction")
            local v1941 = t1.value10("Destroying current vehicle...")

            MakeNotification(value17, {
					Name = v1940,
					Image = "rbxassetid://10709752996",
					Content = v1941,
					Time = 2
				})
        end)
        HumanoidRootPart.Anchored = false

        local vector3 = Vector3.new(9999999999, 999999999, 9999999999)

        SeatPart.CFrame = CFrame.new(vector3)
        task.wait(0.3)

        if SeatPart == Humanoid.SeatPart then
            pcall(function()
                Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end)
            Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end

        pcall(function()
            Humanoid:LeaveVehicle()
        end)

        local t115 = { CFrame.new(HumanoidRootPartPosition) }

        Character:PivotTo(v2(t115))
        HumanoidRootPart.Anchored = Anchored
        task.wait(0.5)
        pcall(function()
            local value17 = t1.value17
            local value10 = t1.value10
            local MakeNotification = value17.MakeNotification
            local v1945 = value10("Success")
            local v1946 = t1.value10("Current vehicle has been destroyed!")

            MakeNotification(value17, {
					Name = v1945,
					Content = v1946,
					Time = 3
				})
        end)
    end)
end
})
Tab:AddSection({
	Name = t1.value10("Car Mods")
})
Tab:AddToggle({
	Name = t1.value10("Auto Change Wheel"),
	Default = false,
	Callback = function(p100)
    t1.value2.autoChangeWheelEnabled = p100

    if t1.value2.autoChangeWheelEnabled then
        t1.value2.wheelLoop = task.spawn(function()
            while t1.value2.autoChangeWheelEnabled do
                local t116 = {
						[1] = "WheelNumber"
					}
                local v1737 = ReplicatedStorage:FindFirstChild("RE"):FindFirstChild("1Player1sCa1r")

                if v1737 then
                    v1737:FireServer(unpack(t116))
                end

                task.wait(0.3)
            end
        end)

        return
    end

    t1.value2.autoChangeWheelEnabled = false
end
})
Tab:AddToggle({
	Name = t1.value10("Auto Height Car"),
	Default = false,
	Callback = function(p101)
    isActive = p101

    if isActive then
        spawn(function()
            while isActive do
                local t117 = {
						[1] = "VehicleHeight",
						[2] = 1
					}

                game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Player1sCa1r"):FireServer(unpack(t117))
                wait(0.3)

                if not isActive then
                    return
                end

                local t118 = {
						[1] = "VehicleHeight",
						[2] = 4
					}
                local v1740 = game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Player1sCa1r")
                local t119 = { unpack(t118) }

                v1740:FireServer(v2(t119))
                wait(0.3)
            end
        end)
    end
end
})
Tab:AddSection({
	Name = t1.value10("Mods")
})

local v257
do
    local t151, t152, t153, t154, t155, t156, t157, t158, t159, t160, t161, t162, t163, t164, t165, t166
    local t167
    do
        local v180

        do
            local function v150()
                t1.value2.character = t1.value2.player.Character or t1.value2.player.CharacterAdded:Wait()
                t1.value2.humanoid = t1.value2.character:WaitForChild("Humanoid")

                local RigType = t1.value2.humanoid.RigType

                t1.value2.part = RigType == Enum.HumanoidRigType.R6 and t1.value2.character:FindFirstChild("Torso") or t1.value2.character:FindFirstChild("UpperTorso")
            end

            v150()
            t1.value2.player.CharacterAdded:Connect(function()
                if t1.value2.flying then
                    stopFlight()
                end

                v150()
            end)

            local _Tab = Tab
            local v152 = t1.value10("Fly Speed")
            local flightSpeed = t1.value2.flightSpeed

            _Tab:AddSlider({
				Name = v152,
				Min = 10,
				Max = 200,
				Flag = "FlySpeed",
				Default = flightSpeed,
				Increment = 1,
				Callback = function(p102)
                t1.value2.flightSpeed = p102
            end
			})

            function t1.value78()
                if not t1.value2.humanoid or not t1.value2.part then
                    return
                end
                t1.value2.ctrl = t1.value2.ctrl or {
					f = 0,
					b = 0,
					l = 0,
					r = 0
				}
                t1.value2.flying = true
                t1.value2.humanoid.PlatformStand = true
                local v1007 = t1.value2.flightSpeed or 50
                local n12 = 0
                t1.value2.bg = Instance.new("BodyGyro", t1.value2.part)
                t1.value2.bg.P = 90000
                t1.value2.bg.MaxTorque = Vector3.new(9000000000, 9000000000, 9000000000)
                t1.value2.bg.CFrame = workspace.CurrentCamera.CFrame
                t1.value2.bv = Instance.new("BodyVelocity", t1.value2.part)
                t1.value2.bv.Velocity = Vector3.new(0, 0.1, 0)
                t1.value2.bv.MaxForce = Vector3.new(9000000000, 9000000000, 9000000000)
                if not t1.value2.UserInputService.TouchEnabled then
                    if t1.value2.inputConnBegan then
                        t1.value2.inputConnBegan:Disconnect()
                        t1.value2.inputConnBegan = nil
                    end

                    if t1.value2.inputConnEnded then
                        t1.value2.inputConnEnded:Disconnect()
                        t1.value2.inputConnEnded = nil
                    end

                    t1.value2.inputConnBegan = t1.value2.UserInputService.InputBegan:Connect(function(input, gameProcessed)
                        if gameProcessed then
                            return
                        end

                        if input.KeyCode == Enum.KeyCode.W then
                            t1.value2.ctrl.f = -1
                        end

                        if input.KeyCode == Enum.KeyCode.S then
                            t1.value2.ctrl.b = 1
                        end

                        if input.KeyCode == Enum.KeyCode.A then
                            t1.value2.ctrl.l = -1
                        end

                        if input.KeyCode == Enum.KeyCode.D then
                            t1.value2.ctrl.r = 1
                        end
                    end)
                    t1.value2.inputConnEnded = t1.value2.UserInputService.InputEnded:Connect(function(input, gameProcessed)
                        if gameProcessed then
                            return
                        end

                        if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S then
                            t1.value2.ctrl.f = 0
                            t1.value2.ctrl.b = 0
                        end

                        if input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D then
                            t1.value2.ctrl.l = 0
                            t1.value2.ctrl.r = 0
                        end
                    end)
                end
                if t1.value2.renderConn then
                    t1.value2.renderConn:Disconnect()
                    t1.value2.renderConn = nil
                end
                t1.value2.renderConn = t1.value2.RunService.RenderStepped:Connect(function(_)
                    local flying = t1.value2.flying

                    if flying then
                        flying = t1.value2.bg

                        if flying then
                            flying = t1.value2.bv and (t1.value2.part and t1.value2.humanoid)
                        end
                    end

                    if not flying then
                        return
                    end

                    local CurrentCamera = workspace.CurrentCamera

                    if not CurrentCamera then
                        return
                    end

                    if not t1.value2.UserInputService.TouchEnabled then
                        if t1.value2.ctrl.l + t1.value2.ctrl.r ~= 0 or t1.value2.ctrl.f + t1.value2.ctrl.b ~= 0 then
                            n12 = n12 + 0.5 + n12 / v1007

                            if n12 > v1007 then
                                n12 = v1007
                            end
                        elseif n12 ~= 0 then
                            n12 -= 1

                            if n12 < 0 then
                                n12 = 0
                            end
                        end

                        local CurrentCameraCFrame = CurrentCamera.CFrame
                        local v1750 = (CurrentCameraCFrame.LookVector * (t1.value2.ctrl.f + t1.value2.ctrl.b) + ((CurrentCameraCFrame * CFrame.new(t1.value2.ctrl.l + t1.value2.ctrl.r, (t1.value2.ctrl.f + t1.value2.ctrl.b) * 0.2, 0)).p - CurrentCameraCFrame.p)) * n12

                        if (t1.value2.ctrl.l + t1.value2.ctrl.r == 0 or t1.value2.ctrl.f + t1.value2.ctrl.b ~= 0) and n12 ~= 0 then
                            v1750 = (CurrentCamera.CFrame.LookVector * 0 + (CurrentCamera.CFrame * CFrame.new(0, 0, 0).p - CurrentCamera.CFrame.p)) * n12
                        elseif (t1.value2.ctrl.l + t1.value2.ctrl.r == 0 or t1.value2.ctrl.f + t1.value2.ctrl.b ~= 0) and n12 == 0 then
                            v1750 = Vector3.new(0, 0, 0)
                        end

                        if t1.value2.ctrl.l + t1.value2.ctrl.r ~= 0 or t1.value2.ctrl.f + t1.value2.ctrl.b ~= 0 then
                            local _ = t1.value2.ctrl.f
                            local _ = t1.value2.ctrl.b
                            local _ = t1.value2.ctrl.l
                            local _ = t1.value2.ctrl.r
                        end

                        t1.value2.bv.Velocity = v1750
                        t1.value2.bg.CFrame = CurrentCamera.CFrame * CFrame.Angles(-math.rad((t1.value2.ctrl.f + t1.value2.ctrl.b) * 50 * (n12 / v1007)), 0, 0)

                        return
                    end

                    local MoveDirection = t1.value2.humanoid.MoveDirection
                    local vector3 = Vector3.new(MoveDirection.X, 0, MoveDirection.Z)
                    local vector3_5 = Vector3.new(CurrentCamera.CFrame.LookVector.X, 0, CurrentCamera.CFrame.LookVector.Z)
                    local vector3_6 = Vector3.new(CurrentCamera.CFrame.RightVector.X, 0, CurrentCamera.CFrame.RightVector.Z)
                    local n13 = 0
                    local n14 = 0

                    if vector3.Magnitude > 0 then
                        n14 = vector3:Dot(vector3_5.Unit)
                        n13 = vector3:Dot(vector3_6.Unit)
                    end

                    local v1761 = CurrentCamera.CFrame.LookVector * n14 + CurrentCamera.CFrame.RightVector * n13
                    local v1762 = if not (v1761.Magnitude > 0) then Vector3.new(0, 0, 0) else v1761.Unit * math.clamp(MoveDirection.Magnitude * t1.value2.flightSpeed or v1007, 0, v1007)

                    t1.value2.bv.Velocity = Vector3.new(v1762.X, v1762.Y, v1762.Z)
                    t1.value2.bg.CFrame = CurrentCamera.CFrame * CFrame.Angles(-math.rad(n14 * 30), 0, 0)
                end)
            end
            function stopFlight()
                t1.value2.flying = false

                if t1.value2.bg then
                    pcall(function()
                        t1.value2.bg:Destroy()
                    end)
                    t1.value2.bg = nil
                end

                if t1.value2.bv then
                    pcall(function()
                        t1.value2.bv:Destroy()
                    end)
                    t1.value2.bv = nil
                end

                if t1.value2.renderConn then
                    pcall(function()
                        t1.value2.renderConn:Disconnect()
                    end)
                    t1.value2.renderConn = nil
                end

                if t1.value2.inputConnBegan then
                    pcall(function()
                        t1.value2.inputConnBegan:Disconnect()
                    end)
                    t1.value2.inputConnBegan = nil
                end

                if t1.value2.inputConnEnded then
                    pcall(function()
                        t1.value2.inputConnEnded:Disconnect()
                    end)
                    t1.value2.inputConnEnded = nil
                end

                if t1.value2.humanoid then
                    pcall(function()
                        t1.value2.humanoid.PlatformStand = false
                    end)
                end
            end

            Tab:AddToggle({
				Name = t1.value10("Fly Car"),
				IsMobile = true,
				Default = false,
				Callback = function(p104)
                if p104 then
                    t1.value78()

                    return
                end

                stopFlight()
            end
			})

            local function v154()
                if not t1.value2.humanoid or not t1.value2.part then
                    return
                end

                t1.value2.flying = true
                t1.value2.humanoid.PlatformStand = true
                t1.value2.bg = Instance.new("BodyGyro", t1.value2.part)
                t1.value2.bg.P = 90000
                t1.value2.bg.maxTorque = Vector3.new(9000000000, 9000000000, 9000000000)
                t1.value2.bg.cframe = t1.value2.camera.CFrame
                t1.value2.bv = Instance.new("BodyVelocity", t1.value2.part)
                t1.value2.bv.velocity = Vector3.new(0, 0, 0)
                t1.value2.bv.maxForce = Vector3.new(9000000000, 9000000000, 9000000000)

                if not t1.value2.UserInputService.TouchEnabled then
                    t1.value2.inputConn = t1.value2.UserInputService.InputBegan:Connect(function(input, gameProcessed)
                        if gameProcessed then
                            return
                        end

                        if input.KeyCode == Enum.KeyCode.W then
                            t1.value2.ctrl.f = -1
                        end

                        if input.KeyCode == Enum.KeyCode.S then
                            t1.value2.ctrl.f = 1
                        end

                        if input.KeyCode == Enum.KeyCode.A then
                            t1.value2.ctrl.l = -1
                        end

                        if input.KeyCode == Enum.KeyCode.D then
                            t1.value2.ctrl.r = 1
                        end
                    end)
                    t1.value2.UserInputService.InputEnded:Connect(function(input, gameProcessed)
                        if gameProcessed then
                            return
                        end

                        if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S then
                            t1.value2.ctrl.f = 0
                        end

                        if input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D then
                            t1.value2.ctrl.l = 0
                            t1.value2.ctrl.r = 0
                        end
                    end)
                end

                t1.value2.renderConn = t1.value2.RunService.RenderStepped:Connect(function()
                    local flying = t1.value2.flying

                    if flying then
                        flying = t1.value2.bg and (t1.value2.bv and t1.value2.part)
                    end

                    if flying then
                        local CurrentCamera = workspace.CurrentCamera
                        local v1770

                        if t1.value2.UserInputService.TouchEnabled then
                            local MoveDirection = t1.value2.humanoid.MoveDirection

                            v1770 = if not (MoveDirection.Magnitude > 0) then Vector3.new(0, 0, 0) else CurrentCamera.CFrame.LookVector * MoveDirection.Magnitude
                        else
                            v1770 = CurrentCamera.CFrame:VectorToWorldSpace(Vector3.new(t1.value2.ctrl.l + t1.value2.ctrl.r, 0, t1.value2.ctrl.f))
                        end

                        t1.value2.bv.velocity = v1770 * t1.value2.flightSpeed
                        t1.value2.bg.cframe = CurrentCamera.CFrame
                    end
                end)
            end

            function stopFlightPC()
                t1.value2.flying = false

                if t1.value2.bg then
                    t1.value2.bg:Destroy()
                    t1.value2.bg = nil
                end

                if t1.value2.bv then
                    t1.value2.bv:Destroy()
                    t1.value2.bv = nil
                end

                if t1.value2.renderConn then
                    t1.value2.renderConn:Disconnect()
                    t1.value2.renderConn = nil
                end

                if t1.value2.inputConn then
                    t1.value2.inputConn:Disconnect()
                    t1.value2.inputConn = nil
                end

                if t1.value2.humanoid then
                    t1.value2.humanoid.PlatformStand = false
                end
            end

            Tab:AddToggle({
				Name = t1.value10("Fly Car"),
				IsPC = true,
				Default = false,
				Callback = function(p105)
                if p105 then
                    v154()

                    return
                end

                stopFlightPC()
            end
			})
            Tab:AddSection({
				Name = t1.value10("Car Speed System")
			})
            Tab:AddToggle({
				Name = t1.value10("Car Speed"),
				Default = false,
				Callback = function(p106)
                t1.value2.flying = p106

                if not t1.value2.flying and t1.value2.part then
                    t1.value2.part.Velocity = Vector3.zero
                    t1.value2.speed = 0
                end

                if t1.value8.TouchEnabled then
                    if p106 then
                        if not t1.value2._mobileGui then
                            local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
                            local ScreenGui = Instance.new("ScreenGui")

                            ScreenGui.Name = "CarMobileControls"
                            ScreenGui.ResetOnSpawn = false
                            ScreenGui.DisplayOrder = 1000
                            ScreenGui.Parent = PlayerGui
                            t1.value2._mobileGui = ScreenGui

                            local function v1015(p107, p108)
                                local TextButton = Instance.new("TextButton")

                                TextButton.Name = p107
                                TextButton.Size = UDim2.new(0, 90, 0, 90)
                                TextButton.Position = p108
                                TextButton.AnchorPoint = Vector2.new(0.5, 0.5)
                                TextButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                                TextButton.BackgroundTransparency = 0.15
                                TextButton.BorderSizePixel = 0
                                TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                                TextButton.Font = Enum.Font.SourceSansBold
                                TextButton.TextSize = 30
                                TextButton.Text = p107
                                TextButton.Parent = ScreenGui

                                return TextButton
                            end

                            t1.value2._btnForward = v1015("↑", UDim2.new(0.12, 0, 0.78, 0))
                            t1.value2._btnBackward = v1015("↓", UDim2.new(0.12, 0, 0.9, 0))
                            t1.value2._btnTurbo = v1015("Turbo", UDim2.new(0.26, 0, 0.85, 0))

                            local function v1016(p109, p110, p111)
                                p109.InputBegan:Connect(function(input)
                                    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                                        p110()
                                    end
                                end)
                                p109.InputEnded:Connect(function(input)
                                    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                                        p111()
                                    end
                                end)
                            end

                            v1016(t1.value2._btnForward, function()
                                t1.value2.moveForward = true
                            end, function()
                                t1.value2.moveForward = false
                            end)
                            v1016(t1.value2._btnBackward, function()
                                t1.value2.moveBackward = true
                            end, function()
                                t1.value2.moveBackward = false
                            end)
                            v1016(t1.value2._btnTurbo, function()
                                t1.value2.turboActive = true
                            end, function()
                                t1.value2.turboActive = false
                            end)

                            return
                        end
                    else
                        if t1.value2._mobileGui then
                            pcall(function()
                                t1.value2._mobileGui:Destroy()
                            end)
                            t1.value2._mobileGui = nil
                        end

                        t1.value2.moveForward = false
                        t1.value2.moveBackward = false
                        t1.value2.turboActive = false
                    end
                end
            end
			})

            if not t1.value2._keyboardBound then
                t1.value2._keyboardBound = true
                t1.value2.UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed then
                        return
                    end

                    if input.KeyCode == Enum.KeyCode.W then
                        t1.value2.moveForward = true

                        return
                    end

                    if input.KeyCode == Enum.KeyCode.S then
                        t1.value2.moveBackward = true

                        return
                    end

                    if input.KeyCode == Enum.KeyCode.LeftShift then
                        t1.value2.turboActive = true
                    end
                end)
                t1.value2.UserInputService.InputEnded:Connect(function(input, gameProcessed)
                    if gameProcessed then
                        return
                    end

                    if input.KeyCode == Enum.KeyCode.W then
                        t1.value2.moveForward = false

                        return
                    end

                    if input.KeyCode == Enum.KeyCode.S then
                        t1.value2.moveBackward = false

                        return
                    end

                    if input.KeyCode == Enum.KeyCode.LeftShift then
                        t1.value2.turboActive = false
                    end
                end)
            end

            t1.value2.RunService.RenderStepped:Connect(function()
                if t1.value2.flying and t1.value2.part then
                    local n15 = 0

                    if t1.value2.moveForward then
                        n15 = 1
                    elseif t1.value2.moveBackward then
                        n15 = -1
                    elseif t1.value2.character and t1.value2.character:FindFirstChildOfClass("Humanoid") then
                        local Humanoid = t1.value2.character:FindFirstChildOfClass("Humanoid")

                        if Humanoid.MoveDirection.Magnitude > 0 then
                            local Unit = Humanoid.MoveDirection.Unit
                            local v1024 = t1.value2.part.CFrame.LookVector:Dot(Unit)

                            if v1024 > 0.25 then
                                n15 = 1
                            elseif v1024 < -0.25 then
                                n15 = -1
                            end
                        end
                    end

                    local v1025 = t1.value2.turboActive and t1.value2.turboSpeed or t1.value2.maxSpeed
                    local v1026 = t1.value2.turboActive and t1.value2.turboAcceleration or t1.value2.acceleration

                    if n15 == 1 then
                        t1.value2.speed = math.clamp(t1.value2.speed + v1026, -v1025, v1025)
                    elseif n15 == -1 then
                        t1.value2.speed = math.clamp(t1.value2.speed - v1026, -v1025 / 2, v1025 / 2)
                    elseif t1.value2.speed > 0 then
                        t1.value2.speed = math.max(t1.value2.speed - t1.value2.deceleration, 0)
                    elseif t1.value2.speed < 0 then
                        t1.value2.speed = math.min(t1.value2.speed + t1.value2.deceleration, 0)
                    end

                    local v1027 = t1.value2.part.CFrame.LookVector * t1.value2.speed

                    t1.value2.part.Velocity = Vector3.new(v1027.X, t1.value2.part.Velocity.Y, v1027.Z)
                end
            end)

            local _Tab13 = Tab
            local v156 = t1.value10("Car Speed")
            local maxSpeed = t1.value2.maxSpeed

            _Tab13:AddSlider({
				Name = v156,
				Min = 50,
				Max = 250,
				Flag = "CarMaxSpeed",
				Default = maxSpeed,
				Increment = 5,
				Callback = function(p112)
                t1.value2.maxSpeed = p112
            end
			})

            local _Tab14 = Tab
            local v159 = t1.value10("Car Acceleration")
            local acceleration = t1.value2.acceleration

            _Tab14:AddSlider({
				Name = v159,
				Min = 1,
				Max = 20,
				Flag = "CarAcceleration",
				Default = acceleration,
				Increment = 1,
				Callback = function(p113)
                t1.value2.acceleration = p113
            end
			})
            Tab = v24:MakeTab({
				Name = t1.value10("House"),
				Icon = "rbxassetid://279461710"
			})
            Tab:AddSection({
				Name = t1.value10("Players House")
			})

            function t1.value79()
                local t120 = {}
                local v1031 = workspace:FindFirstChild("001_Lots")

                if v1031 then
                    for _, child in ipairs(v1031:GetChildren()) do
                        if child.Name ~= "For Sale" and child:IsA("Model") then
                            table.insert(t120, child.Name)
                        end
                    end
                end

                return t120
            end

            t1.value80 = "..."

            local _Tab15 = Tab
            local v162 = t1.value10("Select House")
            local AddDropdown = _Tab15.AddDropdown
            local v164 = t1.value79()

            HouseDropdown = AddDropdown(_Tab15, {
				Name = v162,
				Options = v164,
				Default = "...",
				Callback = function(p114)
                t1.value80 = p114

                if NoclipDoor then
                    NoclipDoor:Set(false)
                end
            end
			})

            local v165 = t1.value79()

            if #v165 == 0 then
                v165 = { "..." }
            end

            HouseDropdown:Refresh(v165, true)
            task.spawn(function()
                local n16 = 0

                while true do
                    local v1036 = t1.value79()

                    if n16 ~= #v1036 then
                        n16 = #v1036
                        HouseDropdown:Refresh(v1036, true)
                    end

                    task.wait(2)
                end
            end)
            Tab:AddButton({
				Name = t1.value10("Teleport to House"),
				Callback = function()
                local v1037 = workspace["001_Lots"]
                local t121 = { tostring(t1.value80) }
                local v1039 = v1037:FindFirstChild(v2(t121))

                if v1039 and game.Players.LocalPlayer.Character then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(v1039.WorldPivot.Position)
                end
            end
			})
            Tab:AddButton({
				Name = t1.value10("Teleport to Safe"),
				Callback = function()
                local v1040 = workspace["001_Lots"]
                local t122 = { (tostring(t1.value80)) }
                local v1042 = v1040:FindFirstChild(v2(t122))

                if v1042 and (v1042:FindFirstChild("HousePickedByPlayer") and game.Players.LocalPlayer.Character) then
                    local v1043 = v1042.HousePickedByPlayer.HouseModel:FindFirstChild("001_Safe")

                    if v1043 then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(v1043.WorldPivot.Position)
                    end
                end
            end
			})
            t1.value81 = {}

            function t1.value82(p115)
                local v1045 = game.Workspace:FindFirstChild("001_Lots")

                if not v1045 then
                    return
                end

                for _, player in ipairs(game.Players:GetPlayers()) do
                    local v1048 = v1045:FindFirstChild(player.Name .. "House")

                    if v1048 then
                        local HousePickedByPlayer = v1048:FindFirstChild("HousePickedByPlayer")

                        if HousePickedByPlayer then
                            local HouseModel = HousePickedByPlayer:FindFirstChild("HouseModel")

                            if HouseModel then
                                for _, child in ipairs(HouseModel:GetChildren()) do
                                    if string.find(child.Name, "BannedBlock") and p115 then
                                        child:Destroy()
                                    end
                                end
                            end
                        end
                    end
                end
            end

            local function v166(p116)
                local v1066 = game.Workspace:FindFirstChild("001_Lots")

                if not v1066 then
                    return
                end

                for _, player in ipairs(game.Players:GetPlayers()) do
                    local v1069 = v1066:FindFirstChild(player.Name .. "House")

                    if v1069 then
                        local HousePickedByPlayer = v1069:FindFirstChild("HousePickedByPlayer")

                        if HousePickedByPlayer then
                            local HouseModel = HousePickedByPlayer:FindFirstChild("HouseModel")

                            if HouseModel and not t1.value81[v1069] then
                                t1.value81[v1069] = HouseModel.ChildAdded:Connect(function(child)
                                    if string.find(child.Name, "BannedBlock") then
                                        t1.value82(p116)
                                    end
                                end)
                            end
                        end
                    end
                end
            end

            local _Tab16 = Tab
            local v168 = t1.value10("UnBan From All House")
            local v169 = getgenv().UnBanState or false

            _Tab16:AddToggle({
				Name = v168,
				Default = v169,
				Callback = function(p117)
                getgenv().UnBanState = p117
                t1.value82(p117)

                if p117 then
                    v166(p117)

                    return
                end

                for _, v in pairs(t1.value81) do
                    v:Disconnect()
                end
            end
			});
            (function()
                local v1072 = getgenv().UnBanState or false

                t1.value82(v1072)

                if v1072 then
                    v166(v1072)
                end
            end)()
            Tab:AddSection({
				Name = t1.value10("Your House")
			})
            t1.value83 = 1
            t1.value84 = {
				Color3.fromRGB(255, 0, 0),
				Color3.fromRGB(0, 255, 0),
				Color3.fromRGB(0, 0, 255),
				Color3.fromRGB(255, 255, 0),
				Color3.fromRGB(255, 165, 0),
				Color3.fromRGB(75, 0, 130),
				v2({ Color3.fromRGB(238, 130, 238) })
			}
            t1.value85 = false
            Tab:AddToggle({
				Name = t1.value10("Rainbow House"),
				Default = false,
				Callback = function(p118)
                if p118 then
                    t1.value85 = true

                    while t1.value85 do
                        local v1077 = t1.value84[t1.value83 + 1]
                        local t123 = {
								[1] = "ColorPickHouse",
								[2] = v1077
							}
                        local v1079 = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Player1sHous1e")
                        local t124 = { unpack(t123) }

                        v1079:FireServer(v2(t124))

                        local value84 = t1.value84

                        t1.value83 = (t1.value83 + 1) % #value84
                        wait(1)
                    end
                end
            end
			})
            t1.value86 = false
            Tab:AddToggle({
				Name = t1.value10("Auto Close/Open Curtains"),
				Default = false,
				Callback = function(p119)
                if p119 then
                    t1.value86 = true

                    while t1.value86 do
                        local t125 = {
								[1] = "Curtains"
							}

                        game:GetService("ReplicatedStorage").RE:FindFirstChild("1Player1sHous1e"):FireServer(unpack(t125))
                        wait(1.5)
                    end
                end
            end
			})
            t1.value87 = false
            Tab:AddToggle({
				Name = t1.value10("Auto Close/Open Garage Door"),
				Default = false,
				Callback = function(p120)
                if p120 then
                    t1.value87 = true

                    while t1.value87 do
                        local t126 = {
								[1] = "GarageDoor"
							}
                        local v1086 = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Player1sHous1e")
                        local t127 = { unpack(t126) }

                        v1086:FireServer(v2(t127))
                        wait(2)
                    end
                end
            end
			})
            Tab:AddButton({
				Name = t1.value10("Fire Your House"),
				Callback = function()
                local _game = game
                local t128 = {
						[1] = "PlayerWantsFire"
					}

                _game:GetService("ReplicatedStorage").RE:FindFirstChild("1Player1sHous1e"):FireServer(unpack(t128))
            end
			})
            Tab:AddButton({
				Name = t1.value10("Remove Your House"),
				Callback = function()
                local t129 = {
						[1] = "PlayerSellHouse"
					}
                local v1091 = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Player1sHous1eChoic1e")
                local t130 = { unpack(t129) }

                v1091:FireServer(v2(t130))
            end
			})
            Tab = v24:MakeTab({
				Name = t1.value10("Music"),
				Icon = "rbxassetid://7059338404"
			})
            Tab:AddSection({
				Name = t1.value10("Music Player")
			})
            t1.value88 = {
				{
					name = "Sonic.exe Laugh",
					id = 2496367477
				},
				{
					name = "Scream",
					id = 270145703
				},
				{
					name = "Scream 2",
					id = 91784486966761
				},
				{
					name = "Scream 3",
					id = 107732411055226
				},
				{
					name = "Scream 5",
					id = 9043346574
				},
				{
					name = "Scream 6",
					id = 104868924499220
				},
				{
					name = "Scream 7",
					id = 1319496541
				},
				{
					name = "Fnaf 3 Jumpscare",
					id = 99804224106385
				},
				{
					name = "Fnaf Jumpscare",
					id = 18338717319
				},
				{
					name = "John's Laugh ",
					id = 130759239
				},
				{
					name = "Chucky Laugh",
					id = 132179181
				},
				{
					name = "Deat Note Laugh",
					id = 8833800231
				},
				{
					name = "Grito ",
					id = 80156405968805
				},
				{
					name = "Rizz ",
					id = 9087418452
				},
				{
					name = "Sus Audio",
					id = 7705506391
				}
			}
            t1.value89 = nil

            local t131 = {}

            for _, v in ipairs(t1.value88) do
                table.insert(t131, v.name)
            end

            Tab:AddTextbox({
				Name = t1.value10("Enter the Audio or Music ID "),
				Default = "",
				Callback = function(p121)
                t1.value89 = tonumber(p121)
            end
			})

            local _Tab17 = Tab
            local v174 = t1.value10("Audios")
            local v175 = t131[1]

            _Tab17:AddDropdown({
				Name = v174,
				Default = v175,
				Options = t131,
				Callback = function(p122)
                for _, v in ipairs(t1.value88) do
                    if p122 == v.name then
                        t1.value89 = v.id

                        return
                    end
                end
            end
			})
            t1.value90 = false
            t1.value91 = nil
            Tab:AddSection({
				Name = t1.value10("Loop Sound")
			})
            Tab:AddToggle({
				Name = t1.value10("Loop Sound"),
				Default = false,
				Callback = function(p123)
                t1.value90 = p123

                if not t1.value90 and t1.value91 then
                    t1.value91:Stop()
                    t1.value91 = nil

                    return
                end

                if t1.value90 and not t1.value91 then
                    playAudio()
                end
            end
			})
            t1.value92 = false
            t1.value93 = {}
            t1.value94 = nil
            t1.value95 = nil

            function t1.value95()
                if t1.value89 then
                    local v1098 = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

                    if not v1098 then
                        return
                    end

                    if not t1.value92 and t1.value94 then
                        t1.value94:Stop()
                        t1.value94:Destroy()
                        t1.value94 = nil
                    end

                    local RE = game:GetService("ReplicatedStorage"):FindFirstChild("RE")

                    if RE then
                        local v1100 = RE:FindFirstChild("1Gu1nSound1s")

                        if v1100 and v1100.FireServer then
                            pcall(function()
                                v1100:FireServer(workspace, tostring(t1.value89), 1)
                            end)
                        end
                    end

                    if RE then
                        local v1101 = RE:FindFirstChild("1Gu1n")

                        if v1101 and v1101.FireServer then
                            local vector3 = Vector3.new(0, -1, 0)
                            local vector3_7 = Vector3.new(0, 0, 0)
                            local str = tostring(t1.value89)
                            local str2 = tostring(t1.value89)
                            local t132 = {
								[1] = true
							}
                            local vector3_8 = Vector3.new(0.25, 0.25, 100)
                            local brickColor = BrickColor.new(24)
                            local SmoothPlastic = Enum.Material.SmoothPlastic
                            local t133 = {
								[1] = v1098,
								[2] = v1098,
								[3] = vector3,
								[4] = vector3_7,
								[5] = v1098,
								[6] = v1098,
								[7] = str,
								[8] = str2,
								[9] = t132,
								[10] = {
									[1] = 25,
									[2] = vector3_8,
									[3] = brickColor,
									[4] = 0.25,
									[5] = SmoothPlastic,
									[6] = 0.25
								},
								[11] = true,
								[12] = false
							}

                            pcall(function()
                                v1101:FireServer(unpack(t133))
                            end)
                        end
                    end

                    local Sound = Instance.new("Sound")

                    Sound.SoundId = "rbxassetid://" .. t1.value89
                    Sound.Parent = v1098
                    Sound:Play()

                    if t1.value92 then
                        table.insert(t1.value93, Sound)
                    else
                        t1.value94 = Sound
                    end

                    Sound.Ended:Connect(function()
                        if t1.value90 then
                            t1.value95()
                        end

                        if t1.value92 then
                            for i, v in ipairs(t1.value93) do
                                if v == Sound then
                                    table.remove(t1.value93, i)

                                    return
                                end
                            end

                            return
                        end

                        t1.value94 = nil
                    end)
                end
            end

            Tab:AddToggle({
				Name = t1.value10("Multi Audio"),
				Default = false,
				Callback = function(p124)
                t1.value92 = p124

                if not t1.value92 then
                    for _, v in ipairs(t1.value93) do
                        v:Stop()
                    end
                end
            end
			})
            Tab:AddSection({
				Name = t1.value10("Play sound")
			})
            Tab:AddButton({
				Name = t1.value10("Play Sound"),
				Callback = function()
                t1.value95()
            end
			})
            Tab:AddButton({
				Name = t1.value10("Stop Sound"),
				Callback = function()
                if t1.value94 then
                    t1.value94:Stop()
                    t1.value94 = nil
                end
            end
			})

            local _Tab18 = Tab
            local v177 = t1.value10("Play Random Audios")
            local AddToggle = _Tab18.AddToggle
            local v179 = (function()
                local u1115 = false

                return function(p125)
                    u1115 = p125 == true

                    if u1115 then
                        task.spawn(function()
                            while u1115 and (type(t1.value88) == "table" and #t1.value88 ~= 0) do
                                local v1975 = t1.value88[math.random(1, #t1.value88)]
                                local v1976 = v1975 and v1975.id

                                if v1976 then
                                    local v1977 = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

                                    if v1977 then
                                        local vector3 = Vector3.new(0, -1, 0)
                                        local vector3_9 = Vector3.new(0, 0, 0)
                                        local str = tostring(v1976)
                                        local str3 = tostring(v1976)
                                        local _Vector3 = Vector3
                                        local t134 = {
											[1] = true
										}
                                        local v1984 = _Vector3.new(0.25, 0.25, 100)
                                        local brickColor = BrickColor.new(24)
                                        local SmoothPlastic = Enum.Material.SmoothPlastic
                                        local t135 = {
											[1] = v1977,
											[2] = v1977,
											[3] = vector3,
											[4] = vector3_9,
											[5] = v1977,
											[6] = v1977,
											[7] = str,
											[8] = str3,
											[9] = t134,
											[10] = {
												[1] = 25,
												[2] = v1984,
												[3] = brickColor,
												[4] = 0.25,
												[5] = SmoothPlastic,
												[6] = 0.25
											},
											[11] = true,
											[12] = false
										}
                                        local RE = game:GetService("ReplicatedStorage"):FindFirstChild("RE")
                                        if RE then
                                            local v1989 = RE:FindFirstChild("1Gu1n")

                                            if v1989 and v1989.FireServer then
                                                pcall(function()
                                                    v1989:FireServer(unpack(t135))
                                                end)
                                            end
                                        end
                                        local Sound = Instance.new("Sound")
                                        Sound.Name = "RandomAudio"
                                        Sound.SoundId = "rbxassetid://" .. tostring(v1976)
                                        Sound.PlaybackSpeed = 1
                                        Sound.Parent = v1977
                                        local u1991 = false
                                        local connection
                                        connection = Sound.Ended:Connect(function()
                                            u1991 = true

                                            if connection then
                                                connection:Disconnect()
                                            end
                                        end)
                                        pcall(function()
                                            Sound:Play()
                                        end)
                                        local n17 = 0
                                        while u1115 and (not u1991 and n17 < 30) do
                                            task.wait(0.2)
                                            n17 += 0.2
                                        end
                                        if connection then
                                            pcall(function()
                                                connection:Disconnect()
                                            end)
                                        end
                                        pcall(function()
                                            Sound:Stop()
                                        end)
                                        pcall(function()
                                            Sound:Destroy()
                                        end)
                                    end
                                end

                                task.wait(0.25)
                            end
                        end)

                        return
                    end

                    pcall(function()
                        local LocalPlayer28 = game.Players.LocalPlayer

                        if LocalPlayer28 and LocalPlayer28.Character then
                            for _, descendant in ipairs(LocalPlayer28.Character:GetDescendants()) do
                                local v1997 = descendant

                                if v1997:IsA("Sound") and v1997.Name == "RandomAudio" then
                                    pcall(function()
                                        v1997:Stop()
                                    end)
                                    pcall(function()
                                        v1997:Destroy()
                                    end)
                                end
                            end
                        end

                        for _, descendant in ipairs(workspace:GetDescendants()) do
                            local v2000 = descendant

                            if v2000:IsA("Sound") and v2000.Name == "RandomAudio" then
                                pcall(function()
                                    v2000:Stop()
                                end)
                                pcall(function()
                                    v2000:Destroy()
                                end)
                            end
                        end
                    end)
                end
            end)()

            AddToggle(_Tab18, {
				Name = v177,
				Default = false,
				Callback = v179
			})
            Tab:AddLabel(t1.value10("Everyone on the server hears the audio"))
            task.spawn(function()
                while true do
                    if t1.value90 and not t1.value94 then
                        t1.value95()
                    end

                    task.wait(0.1)
                end
            end)
            Tab = v24:MakeTab({
				Name = t1.value10("Emotes"),
				Icon = "rbxassetid://73944772549465"
			})

            function v180(p126)
                local Character = t1.value2.player.Character
                if not Character then
                    return
                end
                local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                if not Humanoid then
                    return
                end
                local success, result = pcall(function()
                    Humanoid:PlayEmoteAndGetAnimTrackById(p126)
                end)
                if not success then
                    local v1131 = t1.value10("Error")
                    local v1132 = t1.value10("Failed to play emote: ") .. tostring(result)

                    t1.value2.StarterGui:SetCore("SendNotification", {
						Title = v1131,
						Text = v1132,
						Duration = 3
					})
                end
            end
            function t1.value96(p127)
                if type(isfile) == "function" and isfile(p127) then
                    local ok, result = pcall(readfile, p127)

                    if ok and result then
                        local ok3, result3 = pcall(t1.value2.HttpService.JSONDecode, t1.value2.HttpService, result)

                        if ok3 then
                            ok3 = type(result3) == "table"
                        end

                        if ok3 then
                            return result3
                        end
                    end
                end

                return nil
            end

            local function v181(p128, p129)
                if type(writefile) == "function" then
                    local ok, result = pcall(t1.value2.HttpService.JSONEncode, t1.value2.HttpService, p129)

                    if ok and result then
                        pcall(writefile, p128, result)

                        return true
                    end
                end

                return false
            end

            function t1.value97()
                local v1140 = t1.value96(t1.value2.filename)

                if v1140 and type(v1140) == "table" then
                    t1.value2.presetEmotes = v1140

                    return
                end

                t1.value2.presetEmotes = {}
            end
            function t1.value98()
                v181(t1.value2.filename, t1.value2.presetEmotes)
            end
        end

        function t1.value99()
            local t137 = {}

            for k, _ in pairs(t1.value2.presetEmotes) do
                table.insert(t137, k)
            end

            table.sort(t137)

            return t137
        end

        t1.value97()
        t1.value2.emoteNames = t1.value99()
        t1.value2.selectedName = t1.value2.emoteNames[1] or ""
        Tab:AddTextbox({
			Name = t1.value10("Custom Emote ID"),
			Flag = "CustomIDEmoteFlag",
			Default = "",
			Callback = function(p130)
            local num = tonumber(p130)

            t1.value2.customEmoteId = num
        end
		})
        Tab:AddButton({
			Name = t1.value10("Play Custom Emote"),
			Callback = function()
            if t1.value2.customEmoteId and type(t1.value2.customEmoteId) == "number" then
                v180(t1.value2.customEmoteId)

                return
            end

            local v1143 = t1.value10("Error")
            local v1144, v1145 = t1.value10("Invalid Emote ID")
            local StarterGui = t1.value2.StarterGui
            local v1147 = v1145 or 3

            StarterGui:SetCore("SendNotification", {
					Title = v1143,
					Text = v1144,
					Duration = v1147
				})
        end
		})
        Tab:AddSection(t1.value10("Emotes List"))

        local _Tab = Tab
        local v183 = t1.value10("Emote List")
        local v184 = t1.value2.selectedName ~= "" and t1.value2.selectedName or ""
        local value2 = t1.value2
        local AddDropdown = _Tab.AddDropdown
        local emoteNames = value2.emoteNames

        t1.value100 = AddDropdown(_Tab, {
			Name = v183,
			Flag = "EmotesFlag",
			Default = v184,
			Options = emoteNames,
			Callback = function(p131)
            t1.value2.selectedName = p131
        end
		})
        Tab:AddButton({
			Name = t1.value10("Play Selected Emote"),
			Callback = function()
            if not t1.value2.selectedName or t1.value2.selectedName == "" then
                local v1149 = t1.value10("Error")
                local v1150, v1151 = t1.value10("No emote selected")
                local StarterGui = t1.value2.StarterGui
                local v1153 = v1151 or 3

                StarterGui:SetCore("SendNotification", {
						Title = v1149,
						Text = v1150,
						Duration = v1153
					})

                return
            end

            local v1154 = t1.value2.presetEmotes[t1.value2.selectedName]

            if not v1154 then
                local v1155 = t1.value10("Error")
                local v1156, v1157 = t1.value10("Selected emote has no id")
                local StarterGui = t1.value2.StarterGui
                local v1159 = v1157 or 3

                StarterGui:SetCore("SendNotification", {
						Title = v1155,
						Text = v1156,
						Duration = v1159
					})

                return
            end

            v180(v1154)
        end
		})
        Tab:AddSection(t1.value10("Emotes List Edit"))
        Tab:AddTextbox({
			Name = t1.value10("Add Emote ID"),
			Flag = "AddEmotAddListFlag",
			Default = "",
			Callback = function(p132)
            t1.value2.addEmoteInput = p132
        end
		})
        Tab:AddButton({
			Name = t1.value10("Add Emote ID"),
			Callback = function()
            local num = tonumber(t1.value2.addEmoteInput)

            if not num then
                local v1162 = t1.value10("Error")
                local v1163, v1164 = t1.value10("Invalid ID")
                local StarterGui = t1.value2.StarterGui
                local v1166 = v1164 or 3

                StarterGui:SetCore("SendNotification", {
						Title = v1162,
						Text = v1163,
						Duration = v1166
					})

                return
            end

            local ok, result = pcall(function()
                return t1.value2.MarketplaceService:GetProductInfo(num)
            end)
            local str = tostring(num)

            if ok then
                ok = result and result.Name
            end

            if ok then
                str = result.Name
            end

            local v1170 = str

            if t1.value2.presetEmotes[str] then
                local n18 = 1

                v1170 = str

                while t1.value2.presetEmotes[v1170] do
                    v1170 = str .. " [" .. tostring(n18) .. "]"
                    n18 += 1
                end
            end

            t1.value2.presetEmotes[v1170] = num
            t1.value98()
            t1.value2.emoteNames = t1.value99()
            pcall(function()
                t1.value100:Refresh(t1.value2.emoteNames, true)
            end)
            t1.value2.selectedName = v1170
            pcall(function()
                t1.value100:Select(t1.value2.selectedName)
            end)

            local v1172 = t1.value10("Added")

            t1.value2.StarterGui:SetCore("SendNotification", {
					Title = v1172,
					Text = v1170,
					Duration = 3
				})
        end
		})
        Tab:AddButton({
			Name = t1.value10("Remove Selected Emote"),
			Callback = function()
            if not t1.value2.selectedName or t1.value2.selectedName == "" then
                local v1173 = t1.value10("Error")
                local v1174, v1175 = t1.value10("No emote selected")
                local StarterGui = t1.value2.StarterGui
                local v1177 = v1175 or 3

                StarterGui:SetCore("SendNotification", {
						Title = v1173,
						Text = v1174,
						Duration = v1177
					})

                return
            end

            if t1.value2.presetEmotes[t1.value2.selectedName] then
                t1.value2.presetEmotes[t1.value2.selectedName] = nil
                t1.value98()
                t1.value2.emoteNames = t1.value99()
                pcall(function()
                    t1.value100:Refresh(t1.value2.emoteNames, true)
                end)
                t1.value2.selectedName = t1.value2.emoteNames[1] or ""

                if t1.value2.selectedName ~= "" then
                    pcall(function()
                        t1.value100:Select(t1.value2.selectedName)
                    end)
                end

                local v1178 = t1.value10("Removed")
                local selectedName = t1.value2.selectedName

                t1.value2.StarterGui:SetCore("SendNotification", {
						Title = v1178,
						Text = selectedName,
						Duration = 3
					})

                return
            end

            local v1180 = t1.value10("Error")
            local v1181, v1182 = t1.value10("Selected not in list")
            local StarterGui = t1.value2.StarterGui
            local v1184 = v1182 or 3

            StarterGui:SetCore("SendNotification", {
					Title = v1180,
					Text = v1181,
					Duration = v1184
				})
        end
		})
        Tab:AddButton({
			Name = t1.value10("Refresh List"),
			Callback = function()
            t1.value97()
            t1.value2.emoteNames = t1.value99()
            pcall(function()
                t1.value100:Refresh(t1.value2.emoteNames, true)
            end)
            t1.value2.selectedName = t1.value2.emoteNames[1] or ""

            if t1.value2.selectedName ~= "" then
                pcall(function()
                    t1.value100:Select(t1.value2.selectedName)
                end)
            end

            local v1185 = t1.value10("Refreshed")
            local str = tostring(#t1.value2.emoteNames)

            t1.value2.StarterGui:SetCore("SendNotification", {
					Title = v1185,
					Text = str,
					Duration = 3
				})
        end
		})
        Tab = v24:MakeTab({
			Name = t1.value10("Trolls"),
			Icon = "rbxassetid://9943307858"
		})
        Tab:AddSection({
			Name = t1.value10("Trolls")
		})
        Tab:AddTextbox({
			Name = t1.value10("Enter Spam Chat Text"),
			Default = "Hello!",
			TextDisappear = false,
			Callback = function(p133)
            t1.value2.spamText = p133
        end
		})
        Tab:AddToggle({
			Name = t1.value10("Spam Chat"),
			Default = false,
			Callback = function(p134)
            t1.value2.isSpamming = p134

            if t1.value2.isSpamming then
                while t1.value2.isSpamming do
                    pcall(function()
                        game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(t1.value2.spamText)
                    end)
                    wait(t1.value2.SpamTextSpeed)
                end
            end
        end
		})
        Tab:AddSection({
			Name = t1.value10("18+")
		})
        Tab:AddButton({
			Name = t1.value10("Jerk Off"),
			Callback = function()
            loadstring(game:HttpGet("https://pastefy.app/YZoglOyJ/raw"))()
        end
		})
        Tab:AddButton({
			Name = "Small D1ck",
			Callback = function()
            local t138 = {
					[1] = "PickingTools",
					[2] = "Trophy"
				}
            local v1190 = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l")
            local _unpack = unpack
            local InvokeServer = v1190.InvokeServer
            local t139 = { _unpack(t138) }

            InvokeServer(v1190, v2(t139))
            spawn(function()
                wait(0.1)

                local LocalPlayer29 = game.Players.LocalPlayer
                local v1782 = LocalPlayer29.Character or LocalPlayer29.CharacterAdded:Wait()
                local Trophy = LocalPlayer29.Backpack:FindFirstChild("Trophy")

                if Trophy and Trophy:IsA("Tool") then
                    Trophy.Parent = v1782
                    wait(0.05)

                    local Trophy2 = v1782:FindFirstChild("Trophy")

                    if Trophy2 and Trophy2:IsA("Tool") then
                        Trophy2.Grip = CFrame.new(Vector3.new(0.9, 0.15, 0.6)) * CFrame.Angles(0.5235987755982988, 0.5235987755982988, 0.08726646259971647)
                    end
                end
            end)
        end
		})
        Tab:AddButton({
			Name = "Big D1ck",
			Callback = function()
            local t140 = {
					[1] = "PickingTools",
					[2] = "Tree"
				}

            game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l"):InvokeServer(unpack(t140))
            spawn(function()
                wait(0.1)

                local LocalPlayer30 = game.Players.LocalPlayer
                local v1786 = LocalPlayer30.Character or LocalPlayer30.CharacterAdded:Wait()
                local Tree = LocalPlayer30.Backpack:FindFirstChild("Tree")

                if Tree and Tree:IsA("Tool") then
                    Tree.Parent = v1786
                    wait(0.05)

                    local Tree2 = v1786:FindFirstChild("Tree")

                    if Tree2 and Tree2:IsA("Tool") then
                        Tree2.Grip = CFrame.new(Vector3.new(0.2, -0.3, 3)) * CFrame.Angles(1.0471975511965976, 0.9599310885968813, 0.4363323129985824)
                    end
                end
            end)
        end
		})
        Tab:AddSection({
			Name = t1.value10("Bang")
		})
        t1.value101 = game:GetService("TweenService")
        Bangdropdown = Tab:AddDropdown({
			Name = t1.value10("Select Player For Bang"),
			Default = "No Players",
			Options = { "No Players" },
			Callback = function(p135)
            getgenv().bselectedPlayer = p135 ~= "No Players" and p135 or nil
        end
		})

        local function v188()
            local t141 = {}

            for _, player in pairs(t1.value5:GetPlayers()) do
                table.insert(t141, player.Name)
            end

            t1.value28 = t141
            Bangdropdown:Refresh(#t1.value28 > 0 and t1.value28 or { "No Players" }, true)

            local selectedPlayer6 = getgenv().selectedPlayer

            if selectedPlayer6 then
                selectedPlayer6 = not t1.value5:FindFirstChild(getgenv().selectedPlayer)
            end

            if selectedPlayer6 then
                getgenv().selectedPlayer = nil
            end
        end

        v188()
        t1.value5.PlayerAdded:Connect(v188)
        t1.value5.PlayerRemoving:Connect(v188)
        Tab:AddToggle({
			Name = t1.value10("Target Player Tool"),
			Default = false,
			Callback = function(p136)
            local Backpack = t1.value31:FindFirstChild("Backpack")

            if p136 then
                local t1value2TargetToolName = Backpack:FindFirstChild(t1.value2.TargetToolName)

                if not t1value2TargetToolName then
                    t1value2TargetToolName = t1.value7

                    if t1value2TargetToolName then
                        t1value2TargetToolName = t1.value7:FindFirstChild(t1.value2.TargetToolName)
                    end
                end

                if t1value2TargetToolName then
                    return
                end

                local Tool = Instance.new("Tool")

                Tool.Name = t1.value2.TargetToolName
                Tool.RequiresHandle = false
                Tool.TextureId = "rbxassetid://87129552111975"
                Tool.ToolTip = "Click on a player to select them"
                Tool.Parent = Backpack
                Tool.Activated:Connect(function()
                    local Target = t1.value31:GetMouse().Target

                    if Target and Target.Parent then
                        local Model = Target:FindFirstAncestorOfClass("Model")

                        if Model then
                            local player = game.Players:GetPlayerFromCharacter(Model)

                            if player then
                                local playerName = player.Name

                                if playersDropdown and table.find(t1.value28, playerName) then
                                    playersDropdown:Select(playerName)
                                    getgenv().selectedPlayer = playerName
                                end

                                if killDropdown and table.find(t1.value28, playerName) then
                                    killDropdown:Select(playerName)
                                    getgenv().selectedPlayer = playerName
                                end

                                if Bangdropdown and table.find(t1.value28, playerName) then
                                    Bangdropdown:Select(playerName)
                                    getgenv().selectedPlayer = playerName
                                end

                                if AvatarPlayerDropdown and table.find(t1.value28, playerName) then
                                    AvatarPlayerDropdown:Select(playerName)
                                    getgenv().selectedPlayer = playerName
                                end
                            end
                        end
                    end
                end)

                return
            end

            local t1value2TargetToolName = Backpack:FindFirstChild(t1.value2.TargetToolName)

            if t1value2TargetToolName then
                t1value2TargetToolName:Destroy()
            end

            if t1.value7 then
                local t1value2TargetToolName5 = t1.value7:FindFirstChild(t1.value2.TargetToolName)

                if t1value2TargetToolName5 then
                    t1value2TargetToolName5:Destroy()
                end
            end
        end
		})
        Tab:AddSection({
			Name = t1.value10("Features")
		})

        local SpeedBang2 = t1.value2.SpeedBang
        local SpeedBang3 = t1.value2.SpeedBang
        local SpeedBang4 = t1.value2.SpeedBang
        local SpeedBang5 = t1.value2.SpeedBang

        t1.value102 = {
			["Face Bang"] = SpeedBang2,
			["Face Bang 2"] = SpeedBang3,
			Bang = SpeedBang4,
			["Bang 2"] = SpeedBang5
		}

        local function v193(p137, p138, p139)
            local u1209 = false
            local u1210
            Tab:AddToggle({
				Name = p137,
				Default = false,
				Callback = function(p140)
                u1209 = p140

                local Character = t1.value37.Character

                if not Character then
                    return
                end

                local Humanoid = Character:FindFirstChildOfClass("Humanoid")

                if not Humanoid then
                    return
                end

                if p140 then
                    Humanoid.PlatformStand = true;
                    (function()
                        if u1209 and getgenv().bselectedPlayer then
                            local bselectedPlayer = t1.value5:FindFirstChild(getgenv().bselectedPlayer)

                            if bselectedPlayer and (bselectedPlayer.Character and bselectedPlayer.Character.PrimaryPart) then
                                local Head = bselectedPlayer.Character:FindFirstChild("Head")

                                if Head and Character.PrimaryPart then
                                    local n19 = 4
                                    local t142 = {}

                                    if p139 then
                                        t142.CFrame = Head.CFrame * CFrame.new(0, 1, -n19) * CFrame.Angles(0, 3.141592653589793, 0)
                                    else
                                        t142.CFrame = Head.CFrame * CFrame.new(0, p138, n19) * CFrame.Angles(0, 0, 0)
                                    end

                                    local tweenInfo = TweenInfo.new(t1.value102[p137] or 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

                                    u1210 = t1.value101:Create(Character.PrimaryPart, tweenInfo, t142)
                                    u1210:Play()
                                    task.wait(t1.value102[p137] or 0.1)

                                    if u1209 then
                                        (nil)()
                                    end
                                end
                            end
                        end
                    end)()

                    return
                end

                Humanoid.PlatformStand = false

                if u1210 then
                    u1210:Cancel()
                end
            end
			})
        end

        v193("Bang", -1, false)
        v193("Face Bang", 1, true)

        function t1.value103(p141)
            if p141 and p141.Character then
                return p141.Character:FindFirstChild("HumanoidRootPart")
            end

            return nil
        end
        function t1.value104(p142, p143, _)
            pcall(function()
                local LocalPlayer31 = t1.value5.LocalPlayer

                LocalPlayer31.Character.Animate.Disabled = false

                local Humanoid = LocalPlayer31.Character:FindFirstChildOfClass("Humanoid")

                if not Humanoid then
                    return
                end

                local Animator = Humanoid:FindFirstChildOfClass("Animator")

                if not Animator then
                    Animator = Instance.new("Animator")
                    Animator.Parent = Humanoid
                end

                for _, v in pairs(Humanoid:GetPlayingAnimationTracks()) do
                    v:Stop()
                end

                LocalPlayer31.Character.Animate.Disabled = true

                local Animation = Instance.new("Animation")

                Animation.AnimationId = "rbxassetid://" .. p142

                local track = Animator:LoadAnimation(Animation)

                track:Play()
                track.TimePosition = p143
                track:AdjustSpeed(2)
                track.Stopped:Connect(function()
                    LocalPlayer31.Character.Animate.Disabled = false

                    for _, v in pairs(Humanoid:GetPlayingAnimationTracks()) do
                        v:Stop()
                    end
                end)
            end)
        end
        function t1.value105()
            local LocalPlayer32 = t1.value5.LocalPlayer

            LocalPlayer32.Character.Animate.Disabled = false

            local Humanoid = LocalPlayer32.Character:FindFirstChildOfClass("Humanoid")

            if not Humanoid then
                return
            end

            for _, v in pairs(Humanoid:GetPlayingAnimationTracks()) do
                v:Stop()
            end
        end

        local function v194(p145, p146, p147)
            local u1222 = false
            local u1223
            Tab:AddToggle({
				Name = p145,
				Default = false,
				Callback = function(p148)
                u1222 = p148

                local Character = t1.value37.Character

                if not Character then
                    return
                end

                local Humanoid = Character:FindFirstChildOfClass("Humanoid")

                if not Humanoid then
                    return
                end

                if p148 then
                    Humanoid.PlatformStand = true;
                    (function()
                        if u1222 and getgenv().bselectedPlayer then
                            local bselectedPlayer = t1.value5:FindFirstChild(getgenv().bselectedPlayer)

                            if bselectedPlayer and (bselectedPlayer.Character and bselectedPlayer.Character.PrimaryPart) then
                                local Head = bselectedPlayer.Character:FindFirstChild("Head")

                                if Head and Character.PrimaryPart then
                                    local t143 = {}

                                    if p145 == "Face Bang 2" then
                                        t143.CFrame = Head.CFrame * CFrame.new(0, 1, -1) * CFrame.Angles(0, 3.141592653589793, 0)
                                    elseif p145 == "Bang 2" then
                                        t143.CFrame = Head.CFrame * CFrame.new(0, -1.5, 4) * CFrame.Angles(0, 0, 0)
                                    elseif p147 then
                                        t143.CFrame = Head.CFrame * CFrame.new(0, 1, -4) * CFrame.Angles(0, 3.141592653589793, 0)
                                    else
                                        t143.CFrame = Head.CFrame * CFrame.new(0, p146, 4) * CFrame.Angles(0, 0, 0)
                                    end

                                    local tweenInfo = TweenInfo.new(t1.value102[p145] or 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

                                    u1223 = t1.value101:Create(Character.PrimaryPart, tweenInfo, t143)
                                    u1223:Play()
                                    u1223.Completed:Wait()

                                    if u1222 then
                                        (nil)()
                                    end
                                end
                            end
                        end
                    end)()

                    return
                end

                Humanoid.PlatformStand = false

                if u1223 then
                    u1223:Cancel()
                end
            end
			})
        end

        v194("Bang 2", -1.5, false)
        v194("Face Bang 2", 1, true)
        t1.value106 = false
        Tab:AddToggle({
			Name = t1.value10("Bang 3"),
			Default = false,
			Callback = function(p149)
            t1.value106 = p149

            if t1.value106 and getgenv().bselectedPlayer then
                t1.value104(5918726674, 0, 1)
                task.spawn(function()
                    local _ = t1.value106

                    repeat
                        pcall(function()
                            local v2012 = t1.value103(t1.value5.LocalPlayer)

                            if v2012 and not v2012:FindFirstChild("BreakVelocity") then
                                local BodyVelocity = Instance.new("BodyVelocity")

                                BodyVelocity.Name = "BreakVelocity"
                                BodyVelocity.Parent = v2012
                            end

                            local bselectedPlayer = t1.value5:FindFirstChild(getgenv().bselectedPlayer)

                            if bselectedPlayer then
                                local v2015 = t1.value103(bselectedPlayer)

                                if v2015 and v2012 then
                                    v2012.CFrame = v2015.CFrame * CFrame.new(0, 0, 1.1)
                                    v2012.Velocity = Vector3.new(0, 0, 0)
                                end
                            end
                        end)
                        task.wait()
                    until not t1.value106

                    t1.value105()

                    local BreakVelocity = t1.value103(t1.value5.LocalPlayer):FindFirstChild("BreakVelocity")

                    if BreakVelocity then
                        BreakVelocity:Destroy()
                    end
                end)

                return
            end

            t1.value105()

            local BreakVelocity = t1.value103(t1.value5.LocalPlayer):FindFirstChild("BreakVelocity")

            if BreakVelocity then
                BreakVelocity:Destroy()
            end
        end
		})
        t1.value107 = false
        Tab:AddToggle({
			Name = t1.value10("Face Bang 3"),
			Default = false,
			Callback = function(p150)
            t1.value107 = p150

            if t1.value107 and getgenv().bselectedPlayer then
                t1.value104(5918726674, 0, 1)
                task.spawn(function()
                    local _ = t1.value107

                    repeat
                        pcall(function()
                            local v2016 = t1.value103(t1.value5.LocalPlayer)

                            if v2016 and not v2016:FindFirstChild("BreakVelocity") then
                                local BodyVelocity = Instance.new("BodyVelocity")

                                BodyVelocity.Name = "BreakVelocity"
                                BodyVelocity.Parent = v2016
                            end

                            local bselectedPlayer = t1.value5:FindFirstChild(getgenv().bselectedPlayer)

                            if bselectedPlayer and bselectedPlayer.Character then
                                local Head = bselectedPlayer.Character:FindFirstChild("Head")

                                if Head and v2016 then
                                    v2016.CFrame = Head.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(0, 3.141592653589793, 0)
                                    v2016.Velocity = Vector3.new(0, 0, 0)
                                end
                            end
                        end)
                        task.wait()
                    until not t1.value107

                    t1.value105()

                    local BreakVelocity = t1.value103(t1.value5.LocalPlayer):FindFirstChild("BreakVelocity")

                    if BreakVelocity then
                        BreakVelocity:Destroy()
                    end
                end)

                return
            end

            t1.value105()

            local BreakVelocity = t1.value103(t1.value5.LocalPlayer):FindFirstChild("BreakVelocity")

            if BreakVelocity then
                BreakVelocity:Destroy()
            end
        end
		})
        Tab:AddSection({
			Name = t1.value10("Name")
		})
        t1.value108 = false
        Tab:AddToggle({
			Name = t1.value10("Rainbow Name"),
			Default = false,
			Callback = function(p151)
            if p151 then
                t1.value108 = true

                while t1.value108 do
                    local v1229 = t1.value84[t1.value83 + 1]
                    local t144 = {
							[1] = "PickingRPNameColor",
							[2] = v1229
						}
                    local v1231 = game:GetService("ReplicatedStorage").RE:FindFirstChild("1RPNam1eColo1r")
                    local t145 = { unpack(t144) }

                    v1231:FireServer(v2(t145))
                    t1.value83 = (t1.value83 + 1) % #t1.value84
                    wait(t1.value2.SpeedChange)
                end
            end
        end
		})
        t1.value109 = false
        Tab:AddToggle({
			Name = t1.value10("Rainbow Bio"),
			Default = false,
			Callback = function(p152)
            if p152 then
                t1.value109 = true

                while t1.value109 do
                    local v1234 = t1.value84[t1.value83 + 1]
                    local t146 = {
							[1] = "PickingRPBioColor",
							[2] = v1234
						}
                    local v1236 = game:GetService("ReplicatedStorage").RE:FindFirstChild("1RPNam1eColo1r")
                    local t147 = { unpack(t146) }

                    v1236:FireServer(v2(t147))
                    t1.value83 = (t1.value83 + 1) % #t1.value84
                    wait(t1.value2.SpeedChange)
                end
            end
        end
		})
        t1.value110 = {
			"h a c k e r",
			"#",
			"#1#",
			"##2#",
			"###3#",
			"##2##4#",
			"##5###5#",
			"###6###6#",
			"###6####7#",
			"####1####8#",
			"####3##2###9#",
			"###5##3#####10#",
			"######5645##3###11#",
			"###64##3####5###12#",
			"######4###6####13#",
			"###2##4#6#6#4######14#",
			"####2#####7######15#",
			"#####3###5##4###343###16#",
			"####1###4##65##5###53###17#",
			"###1##3###5#445#4###3###16#",
			"####1#23##46###75653#5##324####17#",
			"####1###3424#63###5#432#####17#",
			"####1#2##64#34###52######17#",
			"####41###4####5465#25##54###17#",
			"####16###4#6##2#5######17#",
			"####1###4#235###5###456###17#",
			"####1###2424###4#5######17#",
			"####61###4##4##5###56##7#17#"
		}
        t1.value111 = false
        t1.value112 = 1
        Tab:AddToggle({
			Name = t1.value10("Auto Change Name"),
			Default = false,
			Callback = function(p153)
            t1.value111 = p153

            if t1.value111 then
                spawn(function()
                    while t1.value111 do
                        if #t1.value110 > 0 then
                            local v1810 = t1.value110[t1.value112]
                            local t148 = {
									[1] = "RolePlayName",
									[2] = v1810
								}
                            local v1812 = game:GetService("ReplicatedStorage").RE:FindFirstChild("1RPNam1eTex1t")
                            local t149 = { unpack(t148) }

                            v1812:FireServer(v2(t149))
                            t1.value112 = t1.value112 + 1

                            if t1.value112 > #t1.value110 then
                                t1.value112 = 1
                            end
                        end

                        wait(t1.value2.SpeedChange)
                    end
                end)
            end
        end
		})
        t1.value113 = false
        Tab:AddToggle({
			Name = t1.value10("Auto Change Bio"),
			Default = false,
			Callback = function(p154)
            t1.value113 = p154

            if t1.value113 then
                spawn(function()
                    while t1.value113 do
                        if #t1.value110 > 0 then
                            local v1814 = t1.value110[t1.value112]
                            local t150 = {
									[1] = "RolePlayBio",
									[2] = v1814
								}

                            game:GetService("ReplicatedStorage").RE:FindFirstChild("1RPNam1eTex1t"):FireServer(unpack(t150))
                            t1.value112 = t1.value112 + 1

                            if t1.value112 > #t1.value110 then
                                t1.value112 = 1
                            end
                        end

                        wait(t1.value2.SpeedChange)
                    end
                end)
            end
        end
		})
        Tab:AddSection({
			Name = t1.value10("Charcter")
		})
        Tab:AddButton({
			Name = t1.value10("Fire On Hand"),
			Callback = function()
            local LocalPlayer33 = game.Players.LocalPlayer
            local v1241 = LocalPlayer33.Character or LocalPlayer33.CharacterAdded:Wait()
            local HumanoidRootPartPosition = v1241.HumanoidRootPart.Position
            local vector3 = Vector3.new(-347.73376464844, 2.397120475769, 98.972328186035)

            v1241.HumanoidRootPart.CFrame = CFrame.new(vector3)
            wait(1)
            fireclickdetector(t1.value54.WorkspaceCom["001_Hospital"].PoolClick.ClickDetector)
            wait(1)
            v1241.HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPartPosition)
        end
		})

        local color3 = Color3.fromRGB(242, 243, 243)

        t151 = {
			Name = "001",
			ColorName = "White",
			Color = color3
		}

        local color3_2 = Color3.fromRGB(215, 197, 154)

        t152 = {
			Name = "005",
			ColorName = "Brick yellow",
			Color = color3_2
		}

        local color3_3 = Color3.fromRGB(245, 205, 48)

        t153 = {
			Name = "006",
			ColorName = "Light yellow",
			Color = color3_3
		}

        local color3_4 = Color3.fromRGB(193, 223, 152)

        t154 = {
			Name = "009",
			ColorName = "Light green",
			Color = color3_4
		}

        local color3_5 = Color3.fromRGB(128, 187, 219)

        t155 = {
			Name = "011",
			ColorName = "Pastel Blue",
			Color = color3_5
		}

        local color3_6 = Color3.fromRGB(204, 142, 105)

        t156 = {
			Name = "018",
			ColorName = "Nougat",
			Color = color3_6
		}

        local color3_7 = Color3.fromRGB(196, 40, 28)

        t157 = {
			Name = "021",
			ColorName = "Bright red",
			Color = color3_7
		}

        local color3_8 = Color3.fromRGB(13, 105, 172)

        t158 = {
			Name = "023",
			ColorName = "Bright blue",
			Color = color3_8
		}

        local color3_9 = Color3.fromRGB(245, 205, 48)

        t159 = {
			Name = "024",
			ColorName = "Bright yellow",
			Color = color3_9
		}

        local color3_10 = Color3.fromRGB(27, 42, 53)

        t160 = {
			Name = "026",
			ColorName = "Black",
			Color = color3_10
		}

        local color3_11 = Color3.fromRGB(73, 151, 208)

        t161 = {
			Name = "037",
			ColorName = "Medium blue",
			Color = color3_11
		}

        local color3_12 = Color3.fromRGB(75, 151, 75)

        t162 = {
			Name = "038",
			ColorName = "Bright green",
			Color = color3_12
		}

        local color3_13 = Color3.fromRGB(116, 134, 156)

        t163 = {
			Name = "045",
			ColorName = "Sand blue",
			Color = color3_13
		}

        local color3_14 = Color3.fromRGB(149, 138, 115)

        t164 = {
			Name = "048",
			ColorName = "Sand yellow",
			Color = color3_14
		}

        local color3_15 = Color3.fromRGB(136, 62, 62)

        t165 = {
			Name = "050",
			ColorName = "Burgundy",
			Color = color3_15
		}

        local color3_16 = Color3.fromRGB(255, 0, 0)

        t166 = {
			Name = "052",
			ColorName = "Really red",
			Color = color3_16
		}

        local color3_17 = Color3.fromRGB(255, 102, 204)

        t167 = {
			Name = "054",
			ColorName = "Pink",
			Color = color3_17
		}
    end
    local color3 = Color3.fromRGB(255, 152, 220)
    local t168 = {
		Name = "055",
		ColorName = "Carnation pink",
		Color = color3
	}
    local color3_18 = Color3.fromRGB(255, 148, 148)
    local t169 = {
		Name = "057",
		ColorName = "Salmon",
		Color = color3_18
	}
    local color3_19 = Color3.fromRGB(255, 176, 0)
    local t170 = {
		Name = "102",
		ColorName = "Light orange",
		Color = color3_19
	}
    local color3_20 = Color3.fromRGB(218, 133, 65)
    local t171 = {
		Name = "106",
		ColorName = "Bright orange",
		Color = color3_20
	}
    local color3_21 = Color3.fromRGB(205, 98, 152)
    local t172 = {
		Name = "119",
		ColorName = "Bright violet",
		Color = color3_21
	}
    local color3_22 = Color3.fromRGB(0, 143, 156)
    local t173 = {
		Name = "135",
		ColorName = "Bright bluish green",
		Color = color3_22
	}
    local color3_23 = Color3.fromRGB(124, 156, 107)
    local t174 = {
		Name = "141",
		ColorName = "Bright yellowish green",
		Color = color3_23
	}
    local color3_24 = Color3.fromRGB(144, 76, 123)
    local t175 = {
		Name = "151",
		ColorName = "Bright reddish violet",
		Color = color3_24
	}
    local color3_25 = Color3.fromRGB(252, 172, 64)
    local t176 = {
		Name = "191",
		ColorName = "Flame yellowish orange",
		Color = color3_25
	}
    local color3_26 = Color3.fromRGB(105, 64, 40)
    local t177 = {
		Name = "192",
		ColorName = "Reddish brown",
		Color = color3_26
	}
    local color3_27 = Color3.fromRGB(255, 221, 85)
    local t178 = {
		Name = "194",
		ColorName = "Cool yellow",
		Color = color3_27
	}
    local color3_28 = Color3.fromRGB(32, 95, 46)
    local t179 = {
		Name = "199",
		ColorName = "Earth green",
		Color = color3_28
	}
    local color3_29 = Color3.fromRGB(99, 95, 98)
    local t180 = {
		Name = "208",
		ColorName = "Dark stone grey",
		Color = color3_29
	}
    local color3_30 = Color3.fromRGB(217, 96, 59)
    t1.value114 = {
		t151,
		t152,
		t153,
		t154,
		t155,
		t156,
		t157,
		t158,
		t159,
		t160,
		t161,
		t162,
		t163,
		t164,
		t165,
		t166,
		t167,
		t168,
		t169,
		t170,
		t171,
		t172,
		t173,
		t174,
		t175,
		t176,
		t177,
		t178,
		t179,
		t180,
		{
			Name = "217",
			ColorName = "Bright red-orange",
			Color = color3_30
		}
	}
    t1.value115 = {
		Color3.new(1, 0, 0),
		Color3.new(0, 1, 0),
		Color3.new(0, 0, 1),
		Color3.new(1, 1, 0),
		Color3.new(1, 0, 1),
		Color3.new(0, 1, 1),
		Color3.new(1, 1, 1),
		Color3.new(0, 0, 0),
		Color3.new(1, 0.5, 0),
		Color3.new(0.5, 0, 1),
		Color3.new(1, 0.5, 0.5),
		Color3.new(0.5, 1, 0.5),
		Color3.new(0.5, 0.5, 1),
		Color3.new(1, 0.8, 0.2),
		Color3.new(0.8, 0.2, 1),
		Color3.new(0.2, 1, 0.8),
		Color3.new(1, 0.2, 0.8),
		Color3.new(0.8, 1, 0.2),
		Color3.new(0.2, 0.8, 1),
		Color3.new(1, 0.3, 0.3),
		Color3.new(0.3, 1, 0.3),
		Color3.new(0.3, 0.3, 1),
		Color3.new(0.9, 0.1, 0.9),
		Color3.new(0.1, 0.9, 0.9),
		Color3.new(0.9, 0.9, 0.1)
	}
    Tab:AddToggle({
		Name = t1.value10("Rainbow Charcter Skin"),
		Default = false,
		Callback = function(p155)
        t1.value2.running = p155

        if t1.value2.running then
            spawn(function()
                local n20 = 1

                while t1.value2.running do
                    local t181 = {
							[1] = t1.value114[n20].Name
						}

                    game:GetService("ReplicatedStorage").Remotes.ChangeBodyColor:FireServer(unpack(t181))
                    n20 += 1

                    if n20 > #t1.value114 then
                        n20 = 1
                    end

                    wait(t1.value2.SpeedChange)
                end
            end)
        end
    end
	})
    local function v256()
        local n21 = 1

        while t1.value2.isActive and t1.value2.isActive do
            local v1246 = t1.value115[n21]
            local t182 = {
				[1] = "ChangeHairColor2",
				[2] = v1246
			}
            local v1248 = game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Max1y")
            local t183 = { unpack(t182) }

            v1248:FireServer(v2(t183))
            wait(0.1)
            n21 = n21 % #t1.value115 + 1
        end
    end
    Tab:AddToggle({
		Name = t1.value10("Rainbow Hair"),
		Default = false,
		Callback = function(p156)
        t1.value2.isActive = p156

        if t1.value2.isActive then
            spawn(v256)
        end
    end
	})
    t1.value116 = {
		9567541545,
		6181765977,
		6407472707,
		9258722467,
		8933908520,
		6205763608,
		12871927691,
		12253076242,
		11686728731,
		1616887404
	}
    t1.value117 = false
    Tab:AddToggle({
		Name = t1.value10("Auto Change Shirts"),
		Default = false,
		Callback = function(p157)
        t1.value117 = p157

        if t1.value117 then
            spawn(function()
                local n22 = 1

                while t1.value117 do
                    local v1819 = t1.value116[n22]
                    local _game = game
                    local t184 = {
							[1] = v1819
						}

                    _game:GetService("ReplicatedStorage").Remotes.Wear:InvokeServer(unpack(t184))
                    n22 += 1

                    if n22 > #t1.value116 then
                        n22 = 1
                    end

                    wait(t1.value2.SpeedChange)
                end
            end)
        end
    end
	})
    t1.value118 = {
		4795962204,
		12253078230,
		11686747177,
		1724837297,
		12623985892,
		7042096590,
		6106068219,
		758330089,
		10441108233,
		4455882827
	}
    t1.value119 = false
    Tab:AddToggle({
		Name = t1.value10("Auto Change Pants"),
		Default = false,
		Callback = function(p158)
        t1.value119 = p158

        if t1.value119 then
            spawn(function()
                local n23 = 1

                while t1.value119 do
                    local v1823 = t1.value118[n23]
                    local _game = game
                    local t185 = {
							[1] = v1823
						}
                    local Wear = _game:GetService("ReplicatedStorage").Remotes.Wear
                    local t186 = { unpack(t185) }

                    Wear:InvokeServer(v2(t186))
                    n23 += 1

                    if n23 > #t1.value118 then
                        n23 = 1
                    end

                    wait(t1.value2.SpeedChange)
                end
            end)
        end
    end
	})
    Tab = v24:MakeTab({
		Name = t1.value10("Protection"),
		Icon = "rbxassetid://18227536067"
	})
    Tab:AddSection({
		Name = t1.value10("Protect")
	})
    Tab:AddToggle({
		Name = t1.value10("Anti Fall Down"),
		Flag = "AntiFallDown",
		Default = true,
		Callback = function(p159)
        local v1254 = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")

        if v1254 then
            v1254:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not p159)
            v1254:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, not p159)
        end
    end
	})
    Tab:AddToggle({
		Name = t1.value10("Anti AFK"),
		Default = true,
		Flag = "AntiAFK",
		Callback = function(p160)
        if p160 then
            local v1256 = game:service("VirtualUser")

            game:service("Players").LocalPlayer.Idled:Connect(function()
                v1256:CaptureController()
                v1256:ClickButton2(Vector2.new())
            end)
        end
    end
	})
    Tab:AddToggle({
		Name = t1.value10("Anti Lag"),
		Default = false,
		Flag = "AntiLag",
		Callback = function(p161)
        local t187 = {}
        local u1259
        if not p161 then
            return
        end
        local function v1260(p162)
            u1259 = p162
        end
        local function v1261(p163)
            local t188 = {}
            local t189 = {}

            if p163.Character then
                table.insert(t189, p163.Character)
            end

            local Backpack = p163:FindFirstChildOfClass("Backpack")

            if Backpack then
                table.insert(t189, Backpack)
            end

            local StarterGear = p163:FindFirstChild("StarterGear")

            if StarterGear then
                table.insert(t189, StarterGear)
            end

            for _, v in ipairs(t189) do
                for _, child in ipairs(v:GetChildren()) do
                    if child:IsA("Tool") then
                        table.insert(t188, child)
                    end
                end
            end

            return t188
        end
        local function v1262(p164)
            if p164 == u1259 then
                return
            end

            if t187[p164] then
                return
            end

            t187[p164] = true

            local v1840 = v1261(p164)

            if #v1840 > 1 then
                for i = 2, #v1840 do
                    pcall(function()
                        v1840[i]:Destroy()
                    end)
                end
            end

            t187[p164] = false
        end
        local function v1263(p165)
            if not u1259 then
                v1260(p165)
            end

            task.defer(v1262, p165)

            local function v1843(p166)
                task.delay(0.5, function()
                    v1262(p165)
                end)
                p166.ChildAdded:Connect(function(child)
                    if child:IsA("Tool") then
                        task.delay(0.1, function()
                            v1262(p165)
                        end)
                    end
                end)
            end

            if p165.Character then
                v1843(p165.Character)
            end

            p165.CharacterAdded:Connect(v1843)

            local Backpack = p165:WaitForChild("Backpack", 10)

            if Backpack then
                Backpack.ChildAdded:Connect(function(child)
                    if child:IsA("Tool") then
                        task.delay(0.1, function()
                            v1262(p165)
                        end)
                    end
                end)
            end

            local v1845 = p165:FindFirstChild("StarterGear") or p165:WaitForChild("StarterGear", 10)

            if v1845 then
                v1845.ChildAdded:Connect(function(child)
                    if child:IsA("Tool") then
                        task.delay(0.1, function()
                            v1262(p165)
                        end)
                    end
                end)
            end
        end
        t1.value5.PlayerAdded:Connect(v1263)
        for _, player in ipairs(t1.value5:GetPlayers()) do
            v1263(player)
        end
        task.spawn(function()
            while p161 do
                for _, player in ipairs(t1.value5:GetPlayers()) do
                    v1262(player)
                end

                task.wait(2)
            end
        end)
    end
	})
    Tab:AddToggle({
		Name = t1.value10("Anti Void"),
		Default = true,
		Flag = "AntiVoid",
		Callback = function(p167)
        if p167 then
            if not t1.value2.antiVoidConnection then
                t1.value2.antiVoidConnection = t1.value4.Stepped:Connect(function(_, _)
                    local LocalPlayer34 = game.Players.LocalPlayer

                    if LocalPlayer34 and LocalPlayer34.Character then
                        local HumanoidRootPart = LocalPlayer34.Character:FindFirstChild("HumanoidRootPart")

                        if HumanoidRootPart and HumanoidRootPart.Position.Y < -50 then
                            HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position.X, 52, HumanoidRootPart.Position.Z)
                        end
                    end
                end)

                return
            end
        elseif t1.value2.antiVoidConnection then
            t1.value2.antiVoidConnection:Disconnect()
            t1.value2.antiVoidConnection = nil
        end
    end
	})
    Tab:AddToggle({
		Name = t1.value10("Anti Crash"),
		Default = true,
		Flag = "AntiCrash",
		Callback = function(p170)
        if p170 then
            if not t1.value2.antiCrashConnection then
                local n24 = 0
                local timestamp = tick()

                t1.value2.antiCrashConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    if tick() - timestamp >= 1 then
                        n24 = 0
                        tick()
                    end
                end)
                t1.value2.descendantAddedConn = workspace.DescendantAdded:Connect(function(descendant)
                    if not _G.AntiCrash then
                        return
                    end

                    local v1853 = descendant:IsA("Part")

                    if not v1853 then
                        v1853 = descendant:IsA("MeshPart")

                        if not v1853 then
                            v1853 = descendant:IsA("UnionOperation")

                            if not v1853 then
                                v1853 = descendant:IsA("Explosion") or (descendant:IsA("Fire") or descendant:IsA("Smoke"))
                            end
                        end
                    end

                    if v1853 then
                        n24 += 1

                        if n24 > 200 then
                            pcall(function()
                                descendant:Destroy()
                            end)
                        end
                    end
                end)
            end

            _G.AntiCrash = true

            return
        end

        _G.AntiCrash = false

        if t1.value2.antiCrashConnection then
            t1.value2.antiCrashConnection:Disconnect()
            t1.value2.antiCrashConnection = nil
        end

        if t1.value2.descendantAddedConn then
            t1.value2.descendantAddedConn:Disconnect()
            t1.value2.descendantAddedConn = nil
        end
    end
	})
    Tab:AddSection({
		Name = t1.value10("Protection From Exploiters")
	})
    t1.value2.AntiFlingToggle = Tab:AddToggle({
		Name = t1.value10("Anti Fling"),
		Flag = "AntiFling",
		Default = true,
		Callback = function(p171)
        if p171 then
            _G.AntiFling = true

            local self = setmetatable({}, {
					__index = function(p172, p173)
                local p173_2 = game:GetService(p173)

                if p173_2 then
                    p172[p173] = p173_2
                end

                return p173_2
            end
				})
            local LocalPlayer35 = self.Players.LocalPlayer

            local function v1273(p174)
                local u1858 = false
                local u1859
                local HumanoidRootPart
                local function v1861(p175)
                    u1859 = p175
                    repeat
                        wait()
                        HumanoidRootPart = p175:FindFirstChild("HumanoidRootPart")
                    until HumanoidRootPart
                    u1858 = false
                end
                v1861(p174.Character or p174.CharacterAdded:Wait())
                p174.CharacterAdded:Connect(v1861)
                self.RunService.Heartbeat:Connect(function()
                    if not _G.AntiFling then
                        return
                    end

                    local v2025 = u1859

                    if v2025 then
                        v2025 = u1859:IsDescendantOf(workspace)
                    end

                    if v2025 then
                        v2025 = HumanoidRootPart

                        if v2025 then
                            v2025 = HumanoidRootPart:IsDescendantOf(u1859)
                        end
                    end

                    if v2025 and (HumanoidRootPart.AssemblyAngularVelocity.Magnitude > 50 or HumanoidRootPart.AssemblyLinearVelocity.Magnitude > 100) then
                        if u1858 ~= false then
                        end

                        for _, descendant in ipairs(u1859:GetDescendants()) do
                            if descendant:IsA("BasePart") then
                                descendant.CanCollide = false
                                descendant.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                                descendant.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                descendant.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0)
                            end
                        end
                    end
                end)
            end

            for _, player in ipairs(self.Players:GetPlayers()) do
                if player ~= LocalPlayer35 then
                    v1273(player)
                end
            end

            self.Players.PlayerAdded:Connect(v1273)
            self.RunService.Heartbeat:Connect(function()
                if not _G.AntiFling then
                    return
                end

                pcall(function()
                    local PrimaryPart = LocalPlayer35.Character.PrimaryPart

                    if PrimaryPart.AssemblyLinearVelocity.Magnitude > 250 or PrimaryPart.AssemblyAngularVelocity.Magnitude > 250 then
                        PrimaryPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                        PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        PrimaryPart.CFrame = nil

                        return
                    end

                    if PrimaryPart.AssemblyLinearVelocity.Magnitude < 50 or PrimaryPart.AssemblyAngularVelocity.Magnitude > 50 then
                        local _ = PrimaryPart.CFrame
                    end
                end)
            end)

            return
        end

        _G.AntiFling = false
    end
	})
    function v257(p176, p177)
        local u1278 = false

        task.spawn(function()
            while true do
                if u1278 and LocalPlayer.Character then
                    local v1862 = p177()

                    if v1862 then
                        for _, child in ipairs(v1862:GetChildren()) do
                            local v1865 = false

                            if p176 == "Vehicles" then
                                for _, descendant in ipairs(child:GetDescendants()) do
                                    if descendant:IsA("VehicleSeat") or descendant:IsA("Seat") and (descendant.Occupant and descendant.Occupant.Parent == LocalPlayer.Character) then
                                        v1865 = true

                                        break
                                    end
                                end
                            elseif p176 == "Canoes" then
                                local Owner = child:FindFirstChild("Owner")

                                v1865 = Owner and Owner.Value == LocalPlayer
                            else
                                local v1869 = p176 == "Jets"

                                if not v1869 then
                                    v1869 = p176 == "Helis"
                                end

                                if v1869 then
                                    v1865 = child.Name == LocalPlayer.Name
                                end
                            end

                            if not v1865 then
                                table.insert(backupTables[p176], child:Clone())
                                child:Destroy()
                            end
                        end
                    end
                end

                task.wait(0.03)
            end
        end)

        return function(p178)
            u1278 = p178

            if not p178 then
                for _, v in ipairs(backupTables[p176]) do
                    local v1873 = p177()

                    if v1873 then
                        v.Parent = v1873
                    end
                end

                backupTables[p176] = {}
            end
        end
    end
    local _Tab = Tab
    local v259 = t1.value10("Anti Cars Fling")
    local v260 = v257("Vehicles", function()
        return t1.value54:FindFirstChild("Vehicles")
    end)
    _Tab:AddToggle({
		Name = v259,
		Default = false,
		Flag = "AntiCarsFling",
		Callback = v260
	})
end
local _Tab = Tab
local v262 = t1.value10("Anti Canoe Fling")
local AddToggle = _Tab.AddToggle
local v264 = v257("Canoes", function()
    local WorkspaceCom = t1.value54:FindFirstChild("WorkspaceCom")

    return WorkspaceCom and WorkspaceCom:FindFirstChild("001_CanoeStorage")
end)

AddToggle(_Tab, {
	Name = v262,
	Default = false,
	Flag = "AntiCanoeFling",
	Callback = v264
})
local _Tab19 = Tab
local v266 = t1.value10("Anti Jets Fling")
local v267 = v257("Jets", function()
    local WorkspaceCom = t1.value54:FindFirstChild("WorkspaceCom")

    if WorkspaceCom and WorkspaceCom:FindFirstChild("001_Airport") then
        local AirportHanger = WorkspaceCom["001_Airport"]:FindFirstChild("AirportHanger")

        if AirportHanger then
            return AirportHanger:FindFirstChild("001_JetStorage") and AirportHanger["001_JetStorage"]:FindFirstChild("JetAirport")
        end
    end
end)

_Tab19:AddToggle({
	Name = v266,
	Default = false,
	Flag = "AntiJetsFling",
	Callback = v267
})
local _Tab20 = Tab
local v269 = t1.value10("Anti Helecopters Fling")
local v270 = v257("Helis", function()
    local WorkspaceCom = t1.value54:FindFirstChild("WorkspaceCom")

    return WorkspaceCom and (WorkspaceCom:FindFirstChild("001_HeliStorage") and WorkspaceCom["001_HeliStorage"]:FindFirstChild("PoliceStationHeli"))
end)

_Tab20:AddToggle({
	Name = v269,
	Default = false,
	Flag = "AntiHelecoptersFling",
	Callback = v270
})
local _Tab21 = Tab
local v272 = t1.value10("Anti Ball Fling")
local AddToggle2 = _Tab21.AddToggle
local v274 = v257("Balls", function()
    local WorkspaceCom = t1.value54:FindFirstChild("WorkspaceCom")

    return WorkspaceCom and WorkspaceCom:FindFirstChild("001_SoccerBalls")
end)

AddToggle2(_Tab21, {
	Name = v272,
	Default = false,
	PremiumOnly = true,
	Flag = "AntiBallFling",
	Callback = v274
})
Tab:AddToggle({
	Name = t1.value10("Anti Doors Fling"),
	Default = false,
	PremiumOnly = true,
	Flag = "AntiDoorsFling",
	Callback = function(p179)
    if not _G.hiddenDoors then
        _G.hiddenDoors = {}
    end

    if p179 then
        _G.hiddenDoors = {}

        for _, descendant in ipairs(workspace:GetDescendants()) do
            if descendant:IsA("BasePart") and descendant.Name:lower():find("door") then
                local descendantTransparency = descendant.Transparency
                local CanCollide = descendant.CanCollide
                local CastShadow = descendant.CastShadow
                local t190 = {
						door = descendant,
						originalTransparency = descendantTransparency,
						originalCanCollide = CanCollide,
						originalCastShadow = CastShadow
					}

                descendant.Transparency = 1
                descendant.CanCollide = false

                local GetChildren = descendant.GetChildren

                descendant.CastShadow = false

                for _, v in ipairs(GetChildren(descendant)) do
                    if v:IsA("BasePart") then
                        v.Transparency = 1
                        v.CanCollide = false
                    elseif v:IsA("SurfaceGui") or v:IsA("BillboardGui") then
                        v.Enabled = false
                    end
                end

                table.insert(_G.hiddenDoors, t190)
            end
        end

        return
    end

    for _, v in ipairs(_G.hiddenDoors or {}) do
        if v.door and v.door.Parent then
            v.door.Transparency = v.originalTransparency
            v.door.CanCollide = v.originalCanCollide
            v.door.CastShadow = v.originalCastShadow

            for _, child in ipairs(v.door:GetChildren()) do
                if child:IsA("BasePart") then
                    child.Transparency = 0
                    child.CanCollide = true
                elseif child:IsA("SurfaceGui") or child:IsA("BillboardGui") then
                    child.Enabled = true
                end
            end
        end
    end

    _G.hiddenDoors = {}
end
})
Tab:AddToggle({
	Name = t1.value10("Anti Bang"),
	Default = false,
	Callback = function(p180)
    getgenv().AntiBangJitter = p180

    if p180 then
        task.spawn(function()
            while getgenv().AntiBangJitter and task.wait(0.1) do
                pcall(function()
                    local Character = game.Players.LocalPlayer.Character

                    if Character and Character:FindFirstChild("HumanoidRootPart") then
                        local HumanoidRootPart = Character.HumanoidRootPart

                        HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, 1000, 0)
                        task.wait(0.1)
                        HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, -1000, 0)
                    end
                end)
            end
        end)
    end
end
})
Tab = v24:MakeTab({
	Name = t1.value10("Dev"),
	Icon = "rbxassetid://87350324375899"
})
Tab:AddSection({
	Name = t1.value10("CFrame")
})
Tab:AddButton({
	Name = t1.value10("Copy My CFrame"),
	Callback = function()
    local v1299 = t1.value2.player.Character or t1.value2.player.CharacterAdded:Wait()

    if v1299 and v1299.PrimaryPart then
        local PrimaryPartPosition = v1299.PrimaryPart.Position
        local v1301 = string.format("CFrame.new(%f, %f, %f)", PrimaryPartPosition.X, PrimaryPartPosition.Y, PrimaryPartPosition.Z)

        setclipboard(v1301)
    end
end
})
Tab:AddTextbox({
	Name = t1.value10("CFrame"),
	Default = "",
	Flag = "CFrame",
	Callback = function(p181)
    t1.value2.userInputCF = p181
end
})
Tab:AddButton({
	Name = t1.value10("TP"),
	Callback = function()
    local ok, result = pcall(function()
        local v1874 = t1.value2.userInputCF:gsub("CFrame%.new", "")
        local t191 = {}
        for v1878 in string.gmatch(v1874, "([-?%d%.]+)") do

            table.insert(t191, (tonumber(v1878)))
        end
        if #t191 == 3 then
            return CFrame.new(t191[1], t191[2], t191[3])
        end

        return nil
    end)

    if ok then
        ok = typeof(result) == "CFrame"
    end

    if ok then
        local v1305 = t1.value2.player.Character or t1.value2.player.CharacterAdded:Wait()

        if v1305 and v1305.PrimaryPart then
            v1305:SetPrimaryPartCFrame(result)
        end
    end
end
})
Tab:AddSection({
	Name = t1.value10("Tool Grip Editor")
})
t1.value120 = {
	Position = Vector3.new(0, 0, 0),
	Rotation = {
		0,
		0,
		0
	}
}
local function v275()
    local v1306 = t1.value37.Character and t1.value37.Character:FindFirstChildWhichIsA("Tool")

    if not v1306 then
        return
    end

    local value120Position = t1.value120.Position
    local value120Rotation = t1.value120.Rotation

    v1306.Grip = CFrame.new(value120Position) * CFrame.Angles(math.rad(value120Rotation[1]), math.rad(value120Rotation[2]), (math.rad(value120Rotation[3])))
end
Tab:AddTextbox({
	Name = t1.value10("X Position"),
	Default = "0",
	Flag = "XPosition",
	Callback = function(p182)
    t1.value120.Position = Vector3.new(tonumber(p182) or 0, t1.value120.Position.Y, t1.value120.Position.Z)
    v275()
end
})
Tab:AddTextbox({
	Name = t1.value10("Y Position"),
	Default = "0",
	Flag = "YPosition",
	Callback = function(p183)
    t1.value120.Position = Vector3.new(t1.value120.Position.X, tonumber(p183) or 0, t1.value120.Position.Z)
    v275()
end
})
Tab:AddTextbox({
	Name = t1.value10("Z Position"),
	Default = "0",
	Flag = "ZPosition",
	Callback = function(p184)
    t1.value120.Position = Vector3.new(t1.value120.Position.X, t1.value120.Position.Y, tonumber(p184) or 0)
    v275()
end
})
Tab:AddTextbox({
	Name = t1.value10("Roll"),
	Default = "0",
	Flag = "PRoll",
	Callback = function(p185)
    t1.value120.Rotation[1] = tonumber(p185) or 0
    v275()
end
})
Tab:AddTextbox({
	Name = t1.value10("Pitch"),
	Default = "0",
	Flag = "PPitch",
	Callback = function(p186)
    t1.value120.Rotation[2] = tonumber(p186) or 0
    v275()
end
})
Tab:AddTextbox({
	Name = t1.value10("Yaw"),
	Flag = "PYaw",
	Default = "0",
	Callback = function(p187)
    t1.value120.Rotation[3] = tonumber(p187) or 0
    v275()
end
})
Tab = v24:MakeTab({
	Name = t1.value10("Setting"),
	Icon = "rbxassetid://11385220704"
})
Tab:AddSection({
	Name = t1.value10("Setting")
})
t1.value121 = false
function t1.value122(p188)
    t1.value121 = p188

    if not t1.value121 then
    end
end
Tab:AddToggle({
	Name = t1.value10("Notify when player leaves/joins"),
	Default = false,
	Flag = "NotifyUser",
	Callback = function(p189)
    t1.value122(p189)
end
})
t1.value5.PlayerAdded:Connect(function(player)
    if t1.value121 then
        local StarterGui = game.StarterGui
        local playerName = player.Name
        local SetCore = StarterGui.SetCore
        local v1319 = playerName .. " Has joined"

        SetCore(StarterGui, "SendNotification", {
			Title = "Player Joined",
			Text = v1319,
			Duration = 5
		})
    end
end)
t1.value5.PlayerRemoving:Connect(function(player)
    if t1.value121 then
        local StarterGui = game.StarterGui
        local SetCore = StarterGui.SetCore
        local v1324 = player.Name .. " Has left"

        SetCore(StarterGui, "SendNotification", {
			Title = "Player Left",
			Text = v1324,
			Duration = 5
		})
    end
end)
Tab:AddButton({
	Name = t1.value10("Rejoin Server"),
	Callback = function()
    local TeleportService = game:GetService("TeleportService")
    local LocalPlayer36 = game:GetService("Players").LocalPlayer

    TeleportService:Teleport(game.PlaceId, LocalPlayer36)
end
})
t1.value123 = game.PlaceId
t1.value124 = {}
t1.value125 = ""
t1.value126 = os.date("!*t").hour
function TPReturner()
    local data

    if t1.value125 == "" then
        local HttpService = game.HttpService
        local t192 = { game:HttpGet("https://games.roblox.com/v1/games/" .. t1.value123 .. "/servers/Public?sortOrder=Asc&limit=100") }

        data = HttpService:JSONDecode(v2(t192))
    else
        data = game.HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. t1.value123 .. "/servers/Public?sortOrder=Asc&limit=100&cursor=" .. t1.value125))
    end

    local s2 = ""

    if data.nextPageCursor and (data.nextPageCursor ~= "null" and data.nextPageCursor ~= nil) then
        t1.value125 = data.nextPageCursor
    end

    local n25 = 0

    for _, v in pairs(data.data) do
        local v1335 = true

        s2 = tostring(v.id)

        if tonumber(v.maxPlayers) > tonumber(v.playing) then

            for v1338, v1339 in pairs(t1.value124) do

                if n25 ~= 0 then
                    if s2 == tostring(v1339) then
                        v1335 = false
                    end
                elseif tonumber(t1.value126) ~= tonumber(v1339) then
                    pcall(function()
                        t1.value124 = {}
                        table.insert(t1.value124, t1.value126)
                    end)
                end

                n25 += 1
            end
            if v1335 == true then
                local insert = table.insert
                local v1341 = s2

                insert(t1.value124, v1341)
                wait()
                pcall(function()
                    wait()
                    game:GetService("TeleportService"):TeleportToPlaceInstance(t1.value123, s2, game.Players.LocalPlayer)
                end)
                wait(4)
            end
        end
    end
end
function Teleport()
    while wait() do
        pcall(function()
            TPReturner()

            if t1.value125 ~= "" then
                TPReturner()
            end
        end)
    end
end
Tab:AddButton({
	Name = t1.value10("Server Hop"),
	Callback = function()
    Teleport()
end
})
Tab:AddSection({
	Name = t1.value10("Mod")
})
Tab:AddToggle({
	Name = t1.value10("Free Cam"),
	Default = false,
	Callback = function(p190)
    getgenv().FreeCamNative = p190

    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local CoreGui = game:GetService("CoreGui")
    local CurrentCamera = workspace.CurrentCamera
    local LocalPlayer37 = game.Players.LocalPlayer
    local Character = LocalPlayer37.Character
    local v1350 = Character and Character:FindFirstChild("HumanoidRootPart")
    local v1351 = Character and Character:FindFirstChildOfClass("Humanoid")

    if not getgenv().FreeCamSpeed then
        getgenv().FreeCamSpeed = 2
    end

    if p190 then
        if v1350 then
            v1350.Anchored = true
        end

        local Part = Instance.new("Part")

        Part.Name = "SPHub_CameraPart"
        Part.Transparency = 1
        Part.CanCollide = false
        Part.Anchored = true
        Part.Size = Vector3.new(1, 1, 1)
        Part.CFrame = CurrentCamera.CFrame
        Part.Parent = workspace
        getgenv().SPHubCameraPart = Part
        CurrentCamera.CameraSubject = Part
        LocalPlayer37.CameraMaxZoomDistance = 0.5
        LocalPlayer37.CameraMinZoomDistance = 0.5

        local ScreenGui = Instance.new("ScreenGui")

        ScreenGui.Name = "SPHub_ModalGui"
        ScreenGui.Parent = CoreGui

        local TextButton = Instance.new("TextButton")

        TextButton.Size = UDim2.new(0, 0, 0, 0)
        TextButton.Position = UDim2.new(0, 0, 0, 0)
        TextButton.Text = ""
        TextButton.BackgroundTransparency = 1
        TextButton.Modal = true
        TextButton.Parent = ScreenGui
        getgenv().SPHubModalGui = ScreenGui
        getgenv().FreeCamMouseConnection = RunService.RenderStepped:Connect(function()
            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            end

            UserInputService.MouseIconEnabled = true
        end)

        if not UserInputService.TouchEnabled or UserInputService.KeyboardEnabled then
            local ScreenGui2 = Instance.new("ScreenGui")

            ScreenGui2.Name = "SPHub_SpeedGui"
            ScreenGui2.Parent = CoreGui

            local Frame = Instance.new("Frame")

            Frame.Size = UDim2.new(0, 200, 0, 50)
            Frame.Position = UDim2.new(0.5, -100, 0.8, 0)
            Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Frame.BackgroundTransparency = 1
            Frame.BorderSizePixel = 0

            local UICorner = Instance.new("UICorner")

            UICorner.CornerRadius = UDim.new(0, 8)
            UICorner.Parent = Frame
            Frame.Parent = ScreenGui2

            local TextLabel = Instance.new("TextLabel")

            TextLabel.Size = UDim2.new(1, 0, 1, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.TextTransparency = 1
            TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextLabel.Font = Enum.Font.GothamBold
            TextLabel.TextSize = 20
            TextLabel.Text = "Speed: " .. tostring(getgenv().FreeCamSpeed)
            TextLabel.Parent = Frame
            getgenv().SPHubSpeedGui = ScreenGui2

            local n26 = 0
            local u1360 = false

            getgenv().FreeCamScrollConnection = UserInputService.InputChanged:Connect(function(input, _)
                if not getgenv().FreeCamNative then
                    return
                end

                if input.UserInputType == Enum.UserInputType.MouseWheel then
                    getgenv().FreeCamSpeed = math.clamp(getgenv().FreeCamSpeed + input.Position.Z * 2, 0.5, 100)
                    TextLabel.Text = "Speed: " .. tostring(getgenv().FreeCamSpeed)
                    n26 = tick()

                    if not u1360 then
                        u1360 = true
                        TweenService:Create(Frame, TweenInfo.new(0.3), {
								BackgroundTransparency = 0.3
							}):Play()
                        TweenService:Create(TextLabel, TweenInfo.new(0.3), {
								TextTransparency = 0
							}):Play()
                    end
                end
            end)
            getgenv().FreeCamFadeConnection = RunService.Heartbeat:Connect(function()
                if u1360 and tick() - n26 > 3 then
                    TweenService:Create(Frame, TweenInfo.new(0.5), {
							BackgroundTransparency = 1
						}):Play()
                    TweenService:Create(TextLabel, TweenInfo.new(0.5), {
							TextTransparency = 1
						}):Play()
                end
            end)
        end

        getgenv().FreeCamConnection = RunService.RenderStepped:Connect(function()
            if not getgenv().FreeCamNative then
                return
            end

            if not v1351 then
                return
            end

            Vector3.new(0, 0, 0)

            local MoveDirection

            if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
                MoveDirection = v1351.MoveDirection
            else
                local v1882 = UserInputService:IsKeyDown(Enum.KeyCode.W) and 1

                if not v1882 then
                    v1882 = not UserInputService:IsKeyDown(Enum.KeyCode.S) and 0 or -1
                end

                local v1883 = if not UserInputService:IsKeyDown(Enum.KeyCode.D) then not UserInputService:IsKeyDown(Enum.KeyCode.A) and 0 or -1 else 1
                local v1884 = UserInputService:IsKeyDown(Enum.KeyCode.E) and 1

                if not v1884 then
                    v1884 = not UserInputService:IsKeyDown(Enum.KeyCode.Q) and 0 or -1
                end

                MoveDirection = CurrentCamera.CFrame.LookVector * v1882 + CurrentCamera.CFrame.RightVector * v1883 + CurrentCamera.CFrame.UpVector * v1884
            end

            if MoveDirection.Magnitude > 0 then
                if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
                    Part.CFrame = Part.CFrame + MoveDirection * getgenv().FreeCamSpeed

                    return
                end

                Part.CFrame = Part.CFrame + MoveDirection.Unit * getgenv().FreeCamSpeed
            end
        end)

        return
    end

    if v1350 then
        v1350.Anchored = false
    end

    if getgenv().FreeCamConnection then
        getgenv().FreeCamConnection:Disconnect()
    end

    if getgenv().FreeCamMouseConnection then
        getgenv().FreeCamMouseConnection:Disconnect()
    end

    if getgenv().FreeCamScrollConnection then
        getgenv().FreeCamScrollConnection:Disconnect()
    end

    if getgenv().FreeCamFadeConnection then
        getgenv().FreeCamFadeConnection:Disconnect()
    end

    if getgenv().SPHubCameraPart then
        getgenv().SPHubCameraPart:Destroy()
    end

    if getgenv().SPHubModalGui then
        getgenv().SPHubModalGui:Destroy()
    end

    if getgenv().SPHubSpeedGui then
        getgenv().SPHubSpeedGui:Destroy()
    end

    if v1351 then
        CurrentCamera.CameraSubject = v1351
    end

    LocalPlayer37.CameraMaxZoomDistance = 400
    LocalPlayer37.CameraMinZoomDistance = 0.5
end
})
t1.value127 = game:GetService("Lighting")
t1.value128 = false
Tab:AddToggle({
	Name = t1.value10("RTX Mode"),
	Default = false,
	Flag = "RTXmode",
	Callback = function(p192)
    t1.value128 = p192

    if t1.value128 then
        local Sky = Instance.new("Sky")
        local BloomEffect = Instance.new("BloomEffect")
        local BlurEffect = Instance.new("BlurEffect")
        local ColorCorrectionEffect = Instance.new("ColorCorrectionEffect")
        local SunRaysEffect = Instance.new("SunRaysEffect")

        t1.value127.Brightness = 2.25
        t1.value127.ExposureCompensation = 0.1
        t1.value127.ClockTime = 17.55
        Sky.SkyboxBk = "http://www.roblox.com/asset/?id=144933338"
        Sky.SkyboxDn = "http://www.roblox.com/asset/?id=144931530"
        Sky.SkyboxFt = "http://www.roblox.com/asset/?id=144933262"
        Sky.SkyboxLf = "http://www.roblox.com/asset/?id=144933244"
        Sky.SkyboxRt = "http://www.roblox.com/asset/?id=144933299"
        Sky.SkyboxUp = "http://www.roblox.com/asset/?id=144931564"
        Sky.StarCount = 5000
        Sky.SunAngularSize = 5
        Sky.Parent = t1.value127
        BloomEffect.Intensity = 0.3
        BloomEffect.Size = 10
        BloomEffect.Threshold = 0.8
        BloomEffect.Parent = t1.value127
        BlurEffect.Size = 5
        BlurEffect.Parent = t1.value127
        ColorCorrectionEffect.Brightness = 0
        ColorCorrectionEffect.Contrast = 0.1
        ColorCorrectionEffect.Saturation = 0.25
        ColorCorrectionEffect.TintColor = Color3.fromRGB(255, 255, 255)
        ColorCorrectionEffect.Parent = t1.value127
        SunRaysEffect.Intensity = 0.1
        SunRaysEffect.Spread = 0.8
        SunRaysEffect.Parent = t1.value127

        return
    end

    for _, child in pairs(t1.value127:GetChildren()) do
        if child:IsA("Sky") or child:IsA("PostEffect") then
            child:Destroy()
        end
    end

    t1.value127.Brightness = 2
    t1.value127.ExposureCompensation = 0
end
})
Tab:AddToggle({
	Name = t1.value10("Remove Lag"),
	Default = false,
	Callback = function(p193)
    if p193 then
        disableLaggyFeatures()
        workspace.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("ParticleEmitter") or (descendant:IsA("Trail") or (descendant:IsA("Smoke") or descendant:IsA("Fire"))) then
                descendant.Enabled = false
            end
        end)
    end
end
})
Tab:AddSection({
	Name = t1.value10("Performance")
})
Tab:AddToggle({
	Name = t1.value10("FPS Booster"),
	Default = false,
	Callback = function(p194)
    if p194 then
        for _, descendant in pairs(workspace:GetDescendants()) do
            if descendant:IsA("Texture") or (descendant:IsA("Decal") or descendant:IsA("ParticleEmitter")) then
                descendant:Destroy()
            end
        end
    end
end
})
Tab:AddToggle({
	Name = t1.value10("Disable Shadows & Fog"),
	Default = false,
	Callback = function(p195)
    game:GetService("Lighting").GlobalShadows = not p195

    if p195 then
        if game:GetService("Lighting"):FindFirstChildOfClass("Atmosphere") then
            game:GetService("Lighting"):FindFirstChildOfClass("Atmosphere"):Destroy()
        end

        game:GetService("Lighting").FogEnd = 9000000000
    end
end
})
getgenv().OriginalMaterials = getgenv().OriginalMaterials or {}
Tab:AddToggle({
	Name = t1.value10("Smooth Plastic World"),
	Default = false,
	Callback = function(p196)
    if p196 then
        for _, descendant in pairs(workspace:GetDescendants()) do
            if descendant:IsA("BasePart") then
                getgenv().OriginalMaterials[descendant] = descendant.Material
                descendant.Material = Enum.Material.SmoothPlastic
            end
        end

        game:GetService("Lighting").Technology = Enum.Technology.Compatibility

        return
    end

    for k, v in pairs(getgenv().OriginalMaterials) do
        local v1379 = k

        if v1379 and v1379.Parent then
            v1379.Material = v
        end
    end

    getgenv().OriginalMaterials = {}
end
})
Tab:AddSection({
	Name = t1.value10("Edit Functions")
})

local _Tab22 = Tab
local v277 = t1.value10("Change ESP Color")
local AddColorpicker = _Tab22.AddColorpicker
local color3 = Color3.fromRGB(255, 0, 0)

AddColorpicker(_Tab22, {
	Name = v277,
	Default = color3,
	Flag = "ESPColor",
	Callback = function(p197)
    t1.value2.ESPColor = p197

    for _, player in ipairs(game.Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("Highlight") then
            player.Character.Highlight.FillColor = t1.value2.ESPColor
        end
    end
end
})
local _Tab23 = Tab
local v281 = t1.value10("Bang Speed")
local SpeedBang6 = t1.value2.SpeedBang
local AddSlider = _Tab23.AddSlider
local v284 = t1.value10("Speed")

AddSlider(_Tab23, {
	Name = v281,
	Min = 0,
	Max = 1,
	Default = SpeedBang6,
	Increment = 0.01,
	Flag = "BangSpeed",
	ValueName = v284,
	Callback = function(p198)
    SpeedBang = p198
    t1.value102["Face Bang"] = SpeedBang
    t1.value102["Face Bang 2"] = SpeedBang
    t1.value102.Bang = SpeedBang
    t1.value102["Bang 2"] = SpeedBang
end
})
local _Tab24 = Tab
local v286 = t1.value10("Spam Chat Speed")
local SpamTextSpeed = t1.value2.SpamTextSpeed
local AddSlider6 = _Tab24.AddSlider
local v289 = t1.value10("Speed")

AddSlider6(_Tab24, {
	Name = v286,
	Min = 0.1,
	Max = 5,
	Default = SpamTextSpeed,
	Increment = 0.1,
	Flag = "SpamChatSpeed",
	ValueName = v289,
	Callback = function(p199)
    t1.value2.SpamTextSpeed = p199
end
})
local _Tab25 = Tab
local v291 = t1.value10("Auto Changer Speed")
local SpeedChange = t1.value2.SpeedChange
local AddSlider7 = _Tab25.AddSlider
local v294 = t1.value10("Speed")

AddSlider7(_Tab25, {
	Name = v291,
	Min = 0.1,
	Max = 3,
	Default = SpeedChange,
	Increment = 0.1,
	Flag = "AutoChangeSpeed",
	ValueName = v294,
	Callback = function(p200)
    t1.value2.SpeedChange = p200
end
})
Tab:AddButton({
	Name = t1.value10("Destroy Gui"),
	Callback = function()
    t1.value17:Destroy()
end
})
t1.value129 = game:GetService("HttpService")
t1.value130 = game:GetService("LocalizationService")

local Players = game:GetService("Players")

t1.value131 = game:GetService("MarketplaceService")
t1.value132 = game:GetService("UserInputService")
t1.value133 = Players.LocalPlayer
t1.value134 = "http://78.154.103.18:11336/register"
t1.value135 = "Unknown"
pcall(function()
    t1.value135 = t1.value130:GetCountryRegionForPlayerAsync(t1.value133)
end)
t1.value136 = "Unknown"
pcall(function()
    local LocaleId = t1.value133.LocaleId

    if LocaleId and string.find(LocaleId, "_") then
        t1.value136 = string.split(LocaleId, "_")[2] or "Unknown"
    end
end)
t1.value137 = "Unknown"
pcall(function()
    local ProductInfo = t1.value131:GetProductInfo(game.PlaceId)

    if ProductInfo then
        t1.value137 = ProductInfo.Name
    end
end)

local v296 = (function()
    if identifyexecutor then
        local ok, result = pcall(identifyexecutor)

        if ok then
            ok = type(result) == "string" and #result > 0
        end

        if ok then
            return result
        end
    end

    if syn then
        return "Synapse X"
    end

    if KRNL_LOADED then
        return "Krnl"
    end

    if is_sirhurt_closure then
        return "SirHurt"
    end

    if pebc_execute then
        return "ProtoSmasher"
    end

    if secure_load then
        return "Sentinel"
    end

    return "Unknown"
end)()
local v297 = (function()
    if t1.value132.TouchEnabled and not t1.value132.KeyboardEnabled then
        return "Mobile"
    end

    if t1.value132.GamepadEnabled then
        return "Console"
    end

    return "Computer"
end)()
local v298 = (function()
    if gethwid then
        local ok, result = pcall(gethwid)

        if ok and result then
            return tostring(result)
        end
    end

    if syn and syn.get_hwid then
        local ok, result = pcall(syn.get_hwid)

        if ok and result then
            return tostring(result)
        end
    end

    if get_hwid then
        local ok, result = pcall(get_hwid)

        if ok and result then
            return tostring(result)
        end
    end

    return "unknown"
end)()
local value133Name = t1.value133.Name
local UserId = t1.value133.UserId
local value135 = t1.value135
local value136 = t1.value136
local value137 = t1.value137
local JobId = game.JobId
local str = tostring(game.PlaceId)
local v306 = os.date("!%Y-%m-%dT%H:%M:%SZ")

t1.value138 = {
	username = value133Name,
	userId = UserId,
	country = value135,
	state = value136,
	game = value137,
	server = JobId,
	placeId = str,
	time = v306,
	execution = true,
	executor = v296,
	script = "SP Hub Brookhaven",
	device = v297,
	hwid = v298
}
task.spawn(function()
    local json = t1.value129:JSONEncode(t1.value138)
    local t193 = {
		["Content-Type"] = "application/json"
	}

    if t1.value129.HttpEnabled then
        pcall(function()
            t1.value129:PostAsync(t1.value134, json, Enum.HttpContentType.ApplicationJson, false, t193)
        end)
    end

    for _, v in ipairs({
		http_request,
		request,
		syn and syn.request,
		http and http.request,
		fluxus and fluxus.request
	}) do
        if v then
            pcall(function()
                v({
					Url = t1.value134,
					Method = "POST",
					Headers = t193,
					Body = json
				})
            end)

            return
        end
    end
end)
