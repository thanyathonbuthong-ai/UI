-- discord.gg/syncrypt

if not ValtLoading then
	ValtLoading = function(p1)
		print(("[Valt] loading %d%%"):format(p1))
	end
end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

if type(ValtConns) == "table" then
	for _, v in pairs(ValtConns) do
		pcall(function()
			v:Disconnect()
		end)
	end
end

ValtConns = {}
ValtFatal = function(E, D)
	local H = (D and "Valt could not start.\n\n" or "Valt - script error, try a different server.\n\n") .. tostring(E)

	pcall(function()
		local E = ((gethui and gethui()) or game:GetService("CoreGui")):FindFirstChild("ValtFatal")

		if E then
			E:Destroy()
		end

		local E = Instance.new("ScreenGui")

		E.Name = "ValtFatal"
		E.IgnoreGuiInset = true
		E.DisplayOrder = 2000000
		E.Parent = (gethui and gethui()) or game:GetService("CoreGui")

		local V = Instance.new("TextLabel")

		V.AnchorPoint = Vector2.new(0.5, 0.5)
		V.Position = UDim2.fromScale(0.5, 0.5)
		V.Size = UDim2.fromOffset(420, 120)
		V.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
		V.Font = Enum.Font.GothamMedium
		V.Text = H
		V.TextSize = 14
		V.TextWrapped = true
		V.TextColor3 = Color3.fromRGB(236, 238, 245)
		V.Parent = E
		Instance.new("UICorner", V).CornerRadius = UDim.new(0, 12)

		if D then
			game:GetService("Debris"):AddItem(E, 20)
		end
	end)

	if D then
		return
	end

	task.delay(2.5, function()
		pcall(function()
			Players.LocalPlayer:Kick(H)
		end)
	end)
end
ValtFailed = {}
ValtSafe = function(p2, p3)
	local ok, result = pcall(p3)

	if not ok then
		ValtFailed[#ValtFailed + 1] = p2 .. ": " .. tostring(result)
		warn("[Valt] feature block " .. p2 .. " failed: " .. tostring(result))
	end
end

if type(ValtVizConns) == "table" then
	for _, v in ipairs(ValtVizConns) do
		pcall(function()
			v:Disconnect()
		end)
	end
end

ValtVizConns = {}
ValtState = _G.ValtState or {}
_G.ValtState = ValtState

if _G.__ValtHub then
	pcall(_G.__ValtHub.destroy)
	task.wait()
	_G.__ValtHub = nil
	_G.__ValtGen = (_G.__ValtGen or 0) + 1
	ValtState.originalLook = ValtState.originalLook or _G.__ValtOriginalLook
	ValtState.aimOriginals = ValtState.aimOriginals or _G.__ValtAimOriginals
	ValtState.aimWrappers = ValtState.aimWrappers or _G.__ValtAimWrappers
end

local gen = (ValtState.gen or 0) + 1

ValtState.gen = gen

if ValtState.hub and ValtState.hub.destroy then
	pcall(ValtState.hub.destroy)
	task.wait()
end

ValtState.hub = nil

local u23 = false
local u24 = false
local thread
local u26 = false
local connection
local n1, n2, n3, n4, LocalPlayer, Character, HumanoidRootPart, t1, u36, u37
local t2, t3, obj, u41, t4, thread2, u44, n5, u46, u47
local u48, u49, u50, u51, u52, connection2, u54, n6, v56, v57
local v58, u59, n7, v61, v62, walkSpeed, v64, u65, v66, v67
local v68, v69, v70, u71, v72, v73, v74, v75, v76

do
	local u77

	n1 = 15
	n2 = 0
	n3 = 0
	n4 = 0
	LocalPlayer = Players.LocalPlayer
	Character = LocalPlayer.Character
	HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
	t1 = {
		murderer = false,
		sheriff = false,
		innocent = false,
		trap = false
	}

	local t5 = {}
	local t6 = {}

	u36 = false
	u37 = false
	t2 = {}
	t3 = {}
	obj = setmetatable({}, {
		__mode = "k"
	})
	u41 = false
	t4 = {}
	thread2 = nil
	u44 = false
	n5 = 40
	u46 = false
	u47 = false
	u48 = false
	u49 = false
	u50 = nil
	u51 = nil
	u52 = nil
	connection2 = nil
	u54 = false

	local connection3

	n6 = 50
	v56 = nil
	v57 = function(p4, p5)
		if not p4 then
			return
		end

		local Value

		pcall(function()
			Value = p4.Value
		end)

		if type(Value) == "boolean" and Value == p5 then
			return
		end

		if pcall(function()
			p4:Set(p5)
		end) then
			return
		end

		pcall(function()
			p4:SetValue(p5)
		end)
	end
	v58 = function(E,i)local D,H,V,F=0,nil,false,false;local function J()if V then return;end;local k=os.clock();if k-D<0.25 then return;end;D=k;i();end;pcall(function()E.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then H,V,F=i.Position,false,true;end;end);E.InputChanged:Connect(function(i)if not F or not H then return;end;if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement then local D=i.Position-H;if math.abs(D.X)>8 or math.abs(D.Y)>8 then V=true;end;end;end);E.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then F=false;end;end);end);pcall(function()E.Activated:Connect(J);end);pcall(function()E.MouseButton1Click:Connect(J);end);pcall(function()E.TouchTap:Connect(J);end);end
	u59 = false
	n7 = 16
	v61 = nil
	v62 = nil
	walkSpeed = 32
	ValtConns.charAdded = LocalPlayer.CharacterAdded:Connect(function(character)
		if ValtState.gen ~= gen then
			ValtConns.charAdded:Disconnect()

			return
		end

		Character = character
		HumanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)

		if u54 then
			u54 = false

			if connection3 then
				connection3:Disconnect()
				connection3 = nil
			end

			v57(v61, false)
		end

		if connection2 then
			connection2:Disconnect()
			connection2 = nil
			v57(v62, false)
		end

		if u59 then
			task.wait(0.1)

			local Humanoid = character:FindFirstChild("Humanoid")

			if Humanoid then
				Humanoid.WalkSpeed = walkSpeed
			end
		end
	end)

	local function v90(p6, p7, p8)
		if p8 then
			local next_ = next
			local children, v93 = p6:GetChildren()

			for _, v in next_, children, v93 do
				if v.Name ~= p7 then
					continue
				end

				if v.ClassName == p8 then
					return v
				end
			end
		else
			local next_ = next
			local children, v98 = p6:GetChildren()

			for _, v in next_, children, v98 do
				if v.Name == p7 then
					return v
				end
			end
		end
	end
	local function v101(p9)
		if p9 and p9.Character then
			return v90(p9.Character, "HumanoidRootPart") or v90(p9.Character, "PrimaryPart")
		end
	end

	local t7 = {}
	local t8 = {}
	local n8 = 0

	local function v105()
		table.clear(t8)

		for k in pairs(t7) do
			if not k.Parent then
				t7[k] = nil
			end
		end

		if not Character then
			return
		end

		local descendants, v108 = Character:GetDescendants()

		for _, v in next, descendants, v108 do
			if v:IsA("BasePart") then
				t8[#t8 + 1] = v
			end
		end
	end

	v64 = function(E)
		if E == (connection2 ~= nil) then
			return
		end

		if E then
			if not connection2 then
				n8 = 0
				connection2 = RunService.Heartbeat:Connect(function()
					if not Character then
						return
					end

					if tick() - n8 > 0.5 then
						n8 = tick()
						v105()
					end

					for E = 1, #t8 do
						local V = t8[E]

						if V.Parent and V.CanCollide then
							t7[V] = true
							V.CanCollide = false
						end
					end
				end)
			end

			v57(v62, true)

			if v56 then
				v56:Notify({ Title = "ValtHub", Content = "Noclip ENABLED", Duration = 1.5, Icon = "square" })
			end
		else
			if connection2 then
				connection2:Disconnect()
				connection2 = nil
			end

			for E, i in pairs(t7) do
				if E and E.Parent then
					E.CanCollide = i
				end

				t7[E] = nil
			end

			v57(v62, false)

			if v56 then
				v56:Notify({ Title = "ValtHub", Content = "Noclip DISABLED", Duration = 1.5, Icon = "square" })
			end
		end
	end
	u65 = false
	v66 = function(E)
		if E == (connection3 ~= nil) and E == u54 then
			return
		end

		u54 = E

		if connection3 then
			connection3:Disconnect()
			connection3 = nil
		end

		local N = LocalPlayer.Character

		if not N then
			u54 = false

			return
		end

		local j = N:FindFirstChild("HumanoidRootPart")
		local O = N:FindFirstChild("Humanoid")

		if j then
			local N = j:FindFirstChild("FlyBodyVelocity")

			if N then
				N:Destroy()
			end

			local N = j:FindFirstChild("FlyBodyGyro")

			if N then
				N:Destroy()
			end
		end

		if E then
			if not j then
				u54 = false

				return
			end

			if O then
				O.PlatformStand = true
			end

			local E = Instance.new("BodyVelocity")

			E.Name = "FlyBodyVelocity"
			E.Velocity = Vector3.zero
			E.MaxForce = Vector3.new(9e9, 9e9, 9e9)
			E.P = 5000
			E.Parent = j

			local E = Instance.new("BodyGyro")

			E.Name = "FlyBodyGyro"
			E.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
			E.P = 9000
			E.D = 500
			E.CFrame = j.CFrame
			E.Parent = j
			connection3 = RunService.Heartbeat:Connect(function()
				if not u54 then
					return
				end

				local E = LocalPlayer.Character

				if not E then
					return
				end

				local H = E:FindFirstChild("HumanoidRootPart")

				if not H then
					return
				end

				local k = H:FindFirstChild("FlyBodyVelocity")
				local P = H:FindFirstChild("FlyBodyGyro")

				if not k or not P then
					return
				end

				local H = workspace.CurrentCamera

				if not H then
					return
				end

				local f = H.CFrame.LookVector
				local N = H.CFrame.RightVector
				local j = Vector3.new(0, 1, 0)
				local R = Vector3.zero

				if UserInputService:IsKeyDown(Enum.KeyCode.W) then
					R = R + f
				end

				if UserInputService:IsKeyDown(Enum.KeyCode.S) then
					R = R - f
				end

				if UserInputService:IsKeyDown(Enum.KeyCode.A) then
					R = R - N
				end

				if UserInputService:IsKeyDown(Enum.KeyCode.D) then
					R = R + N
				end

				if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
					R = R + j
				end

				if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
					R = R - j
				end

				local f = E:FindFirstChildOfClass("Humanoid")

				if f then
					local E = f.MoveDirection

					if E.Magnitude > 0.05 then
						R = R + Vector3.new(E.X, 0, E.Z)
					end

					if f.Jump then
						R = R + j
					end
				end

				if R.Magnitude > 0 then
					k.Velocity = R.Unit * n6
				else
					k.Velocity = Vector3.zero
				end

				P.CFrame = H.CFrame
			end)

			if v61 then
				u65 = true
				v57(v61, true)
				u65 = false
			end

			if v56 then
				v56:Notify({ Title = "ValtHub", Content = "Fly ON", Duration = 1.5, Icon = "arrow-up" })
			end
		else
			if O then
				O.PlatformStand = false
			end

			if v61 then
				u65 = true
				v57(v61, false)
				u65 = false
			end

			if v56 then
				v56:Notify({ Title = "ValtHub", Content = "Fly OFF", Duration = 1.5, Icon = "arrow-up" })
			end
		end
	end
	v67 = function()
		local E = LocalPlayer.Character
		local i = E and E:FindFirstChild("Humanoid")

		if not i then
			if v56 then
				v56:Notify({ Title = "ValtHub", Content = "Character not found!", Duration = 1.5, Icon = "warning" })
			end

			return
		end

		local E = i.WalkSpeed > 16.01

		u59 = not E

		if u59 then
			i.WalkSpeed = walkSpeed

			if v56 then
				v56:Notify({ Title = "ValtHub", Content = "Speed Boost ON! (" .. walkSpeed .. ")", Duration = 1.5, Icon = "zap" })
			end
		else
			i.WalkSpeed = 16

			if v56 then
				v56:Notify({ Title = "ValtHub", Content = "Speed Boost OFF (16)", Duration = 1.5, Icon = "zap" })
			end
		end
	end
	v68 = function()
		if connection2 then
			v64(false)
		else
			v64(true)
		end
	end
	v69 = function(E)
		local F = Character and Character:FindFirstChild("UpperTorso")

		if not F then
			return
		end

		local J = F:FindFirstChild("AutoFarmGyro")
		local k = F:FindFirstChild("AutoFarmVelocity")

		if E then
			if not J and not k then
				local E = v101(LocalPlayer)

				if E then
					local i = Character:FindFirstChild("Humanoid")

					if i then
						local V = CFrame.new(E.Position) * CFrame.Angles(math.rad(90), 0, math.rad(90))

						v64(true)

						local P = Instance.new("BodyGyro")

						P.Name = "AutoFarmGyro"
						P.P = 90000
						P.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
						P.CFrame = V
						P.Parent = F

						local P = Instance.new("BodyVelocity")

						P.Name = "AutoFarmVelocity"
						P.Velocity = Vector3.zero
						P.MaxForce = Vector3.new(9e9, 9e9, 9e9)
						P.Parent = F
						E.CFrame = V
						i.PlatformStand = true
					end
				end
			end
		else
			local E = Character and Character:FindFirstChild("Humanoid")

			if E then
				if J then
					J:Destroy()
				end

				if k then
					k:Destroy()
				end

				E.PlatformStand = false
			end

			v64(false)
		end
	end
	v70 = function()
		local children, v146 = Workspace:GetChildren()

		for _, v in next, children, v146 do
			if v:FindFirstChild("CoinAreas") then
				u77 = v

				return v
			end

			if not v:FindFirstChild("CoinContainer") then
				continue
			end

			u77 = v

			return v
		end
	end
	ValtRound = {
		data = nil,
		stamp = 0,
		ready = false,
		changed = Instance.new("BindableEvent")
	}
	ValtSafe("L504", function()
		local E = ValtRound
		local H = { Murderer = "murderer", Sheriff = "sheriff", Hero = "sheriff", Innocent = "innocent" }

		local function V(F)
			if type(F) ~= "table" then
				return
			end

			E.data = F
			E.ready = true
			E.stamp = os.clock()
			pcall(function()
				E.changed:Fire()
			end)
		end

		task.spawn(function()
			local F

			pcall(function()
				F = ReplicatedStorage:WaitForChild("Remotes", 15):WaitForChild("Gameplay", 15)
			end)

			if not F then
				return
			end

			pcall(function()
				local i = F:WaitForChild("PlayerDataChanged", 15)

				ValtConns.roundData = i.OnClientEvent:Connect(function(i)
					if ValtState.gen ~= gen then
						ValtConns.roundData:Disconnect()

						return
					end

					V(i)
				end)
			end)
			pcall(function()
				local i = F:WaitForChild("GetCurrentPlayerData", 15)
				local D = i:InvokeServer()

				if not E.ready then
					V(D)
				end
			end)
		end)

		function E.pull()
			return E.data
		end
		function E.entry(i)
			local D = E.pull()

			if type(D) ~= "table" or not i then
				return nil
			end

			local V = rawget(D, i.Name)

			if type(V) == "table" then
				return V
			end

			local V = i.UserId

			for i, i in pairs(D) do
				if type(i) == "table" and rawget(i, "UserId") == V then
					return i
				end
			end

			return nil
		end
		function E.rawRole(i)
			local D = E.entry(i)
			local i = D and rawget(D, "Role")

			return (type(i) == "string" and i ~= "") and i or nil
		end
		function E.roleOf(i)
			local D = E.rawRole(i)

			return D and H[D] or nil
		end

		local i, D = nil, false

		function E.live()
			if i == E.stamp then
				return D
			end

			i, D = E.stamp, false

			local i = E.pull()

			if type(i) ~= "table" then
				return false
			end

			for V, V in pairs(i) do
				if type(V) == "table" and H[rawget(V, "Role")] then
					D = true

					break
				end
			end

			return D
		end

		local i = { "Dead", "IsDead", "Killed", "Died", "Defeated" }
		local D = { "Alive", "IsAlive" }
		local H = setmetatable({}, { __mode = "k" })
		local V
		local F, J = nil, ""

		local function k()
			if F == E.stamp then
				return J
			end

			F = E.stamp
			J = ""

			local F = E.pull()

			if type(F) ~= "table" then
				return ""
			end

			local P, f = "", ""

			for S, N in pairs(F) do
				if type(N) == "table" then
					local F = rawget(N, "Role")

					if F == "Murderer" then
						P = tostring(S)
					elseif F == "Sheriff" then
						f = tostring(S)
					end
				end
			end

			J = P .. "|" .. f

			return J
		end
		local function F()
			local J = k()

			if J ~= V then
				V = J
				H = setmetatable({}, { __mode = "k" })
			end
		end

		function E.markDowned(V)
			if V then
				F()
				H[V] = true
			end
		end
		function E.isDead(V)
			if not V then
				return false
			end

			F()

			if H[V] then
				return true
			end

			local H = E.entry(V)

			if type(H) ~= "table" then
				return false
			end

			for V, V in ipairs(i) do
				if rawget(H, V) == true then
					return true
				end
			end

			if E.live() then
				for i, i in ipairs(D) do
					if rawget(H, i) == false then
						return true
					end
				end
			end

			return false
		end
		function E.alive(i)
			if not i then
				return false
			end

			local D = i.Character

			if not D then
				return false
			end

			local H = D:FindFirstChildOfClass("Humanoid")

			if not H or H.Health <= 0 then
				return false
			end

			return not E.isDead(i)
		end
	end)
	ValtSafe("L654", function()
		local function E(H, V)
			if not V then
				return
			end

			task.spawn(function()
				local F = V:FindFirstChildOfClass("Humanoid") or V:WaitForChild("Humanoid", 5)

				if not F then
					return
				end

				local V = "died_" .. H.UserId

				if ValtConns[V] then
					ValtConns[V]:Disconnect()
				end

				ValtConns[V] = F.Died:Connect(function()
					if ValtState.gen ~= gen then
						ValtConns[V]:Disconnect()

						return
					end

					ValtRound.markDowned(H)

					if ValtRound.onDowned then
						pcall(ValtRound.onDowned, H)
					end
				end)
			end)
		end
		local function H(V)
			E(V, V.Character)

			local F = "diedChar_" .. V.UserId

			if ValtConns[F] then
				ValtConns[F]:Disconnect()
			end

			ValtConns[F] = V.CharacterAdded:Connect(function(J)
				if ValtState.gen ~= gen then
					ValtConns[F]:Disconnect()

					return
				end

				E(V, J)
			end)
		end

		for E, E in ipairs(Players:GetPlayers()) do
			H(E)
		end

		ValtConns.diedJoin = Players.PlayerAdded:Connect(function(E)
			if ValtState.gen ~= gen then
				ValtConns.diedJoin:Disconnect()

				return
			end

			H(E)
		end)
	end)
	ValtExec = {
		name = "unknown",
		tier = "full",
		why = "default"
	}
	ValtSafe("L693", function()local E=ValtExec;pcall(function()local i=identifyexecutor or getexecutorname;if i then local D=i();if type(D)=="\115t\114\105\110\x67"and D~=''then E.name=D;end;end;end);local i=E.name:lower();if i:find("xen\x6F",1,true)or i:find('\u{073}\z \u{06F}\z  l\u{061}\114a',1,true)then E.tier,E.why='li\z  m\105\116\101\x64','\u{58}en\o an\u{0064}\ \u{0053}\111\108a\u{0072}a \114un\u{020}th\z  e\ \x72\101\u{64}\z\u{075}\99e\100 \112\114o\102il\101';else E.tier,E.why='full','\102u\x6Cl\32\u{0070}\u{0072}\z \111f\z i\108e';end;E.limited=(E.tier=='\x6Cimited');E.profile=E.limited and{espScale=0.6,xrayBudget=120,skinRender=false,overlaySkip=2,httpRetries=4}or{espScale=1,xrayBudget=600,skinRender=true,overlaySkip=1,httpRetries=3};end)
	ValtPlat = {
		mobile = false,
		console = false,
		source = "unknown",
		override = "auto"
	}
	ValtSafe("L732", function()
		local E = ValtPlat
		local D = UserInputService
		local i = game:GetService("GuiService")

		pcall(function()
			if isfile and isfile("ValtHubHub/platform.txt") then
				local H = readfile("ValtHubHub/platform.txt")

				H = type(H) == "string" and H:lower():gsub("%s", "") or ""

				if H == "mobile" or H == "pc" then
					E.override = H
				end
			end
		end)

		function E.saveOverride(H)
			E.override = H
			pcall(function()
				if not (writefile and makefolder) then
					return
				end

				if isfolder and not isfolder("ValtHubHub") then
					makefolder("ValtHubHub")
				end

				writefile("ValtHubHub/platform.txt", H)
			end)
		end

		local function H(V)
			local F = {}

			for J, J in ipairs(V) do
				pcall(function()
					F[Enum.Platform[J]] = true
				end)
			end

			return F
		end

		local V = H({ "XBoxOne", "PS4", "PS3", "XBox360", "WiiU", "NX", "Ouya" })
		local F = H({ "IOS", "Android", "AndroidTV" })
		local J = H({ "Windows", "OSX", "Linux", "UWP" })
		local H

		pcall(function()
			H = D:GetPlatform()
		end)
		E.console = i:IsTenFootInterface() or (H ~= nil and V[H] == true)

		local function i()
			if E.console then
				return false, "console"
			end

			if not D.TouchEnabled then
				return false, "no touch"
			end

			if H and F[H] then
				return true, "GetPlatform"
			end

			if H and J[H] then
				return false, "GetPlatform desktop"
			end

			if D.AccelerometerEnabled or D.GyroscopeEnabled then
				return true, "accelerometer"
			end

			if not D.MouseEnabled then
				return true, "touch, no mouse"
			end

			if not D.KeyboardEnabled then
				return true, "touch, no keyboard"
			end

			return false, "touch + mouse + keyboard"
		end

		local H, V = i()

		if E.override == "mobile" then
			E.mobile, E.source = true, "forced mobile"
		elseif E.override == "pc" then
			E.mobile, E.source = false, "forced PC"
		else
			E.mobile, E.source = H, V
		end

		E.autoResult = H
		E.touch = D.TouchEnabled
	end)
	ValtESP = {}
	ValtESP.touch = ValtPlat.mobile
	ValtESP.slice = {
		players = 12,
		coins = ValtESP.touch and 8 or 10,
		traps = ValtESP.touch and 4 or 5,
		gunDrops = 3
	}

	if ValtExec.profile.espScale < 1 then
		local espScale = ValtExec.profile.espScale

		ValtESP.slice.coins = math.max(4, math.floor(ValtESP.slice.coins * espScale))
		ValtESP.slice.traps = math.max(2, math.floor(ValtESP.slice.traps * espScale))
		ValtESP.slice.gunDrops = math.max(2, math.floor(ValtESP.slice.gunDrops * espScale))
	end

	roleSource = "auto"
	ValtRound.fromTools = function(E)if not E then return"inno\99\z  \101n\x74";end;local i,D=false,false;local function H(V)V=V:lower();if V:find('k\110\z  \if\e')or V:find("\100\97gg\er")or V:find("\98lad\ze")or V:find('sw\o\z\114d')then i=true;end;if V:find('\u{067}\z un')or V:find('pist\111l')or V:find("re\x76olv\z e\114")or V:find('\z  shotgun')or V:find("\114ifl\101")then D=true;end;end;local V=E:FindFirstChildOfClass("\u{42}\97ckpa\x63k");if V then for F,F in ipairs(V:GetChildren())do H(F.Name);end;end;if E.Character then for V,V in ipairs(E.Character:GetChildren())do if V:IsA("Tool")then H(V.Name);end;end;end;if i then return"\z\x6Durde\u{0072}\u{65}\x72";elseif D then return"sh\101rif\102";else return'inno\99\101\u{006E}\zt';end;end
	u71 = function(E)if not E then return"\105nn\111\c\en\116";end;if roleSource~="t\z  \u{006F}ol\u{73}"then local i=ValtRound.roleOf(E);if i and i~='i\zn\110\111c\101\z  \u{006E}\z\u{074}'then return i;end;local D=ValtRound.fromTools(E);if D~='\u{069}\110n\z\111\ce\110\x74'then return D;end;if i or roleSource=="\u{72}ound"then return"\z in\u{006E}o\z  \x63ent";end;end;return ValtRound.fromTools(E);end
	ValtSafe("L858", function()
		local E = u71
		local D = {}
		local H = -1.0

		u71 = function(i)
			local V = ValtRound.stamp

			if V ~= H then
				H = V
				D = {}
			end

			local H = os.clock()
			local V = D[i]

			if V and H - V.t < 0.4 then
				return V.role
			end

			local V = E(i)

			D[i] = { role = V, t = H }

			return V
		end
	end)
	v72 = function(p10)
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character and ValtRound.alive(player) and u71(player) == p10 then
				return player
			end
		end

		return nil
	end
	v73 = function(p11)
		local Name = p11.Name

		return Name:find("[Tt][Rr][Aa][Pp]") ~= nil or Name:find("[Mm][Ii][Nn][Ee]") ~= nil
	end
	ValtESP.trapCap = ValtESP.slice.traps
	v74 = function(p12)
		if not t1.trap then
			return
		end

		if ValtESP.trapCap <= #t6 then
			return
		end

		for _, child in ipairs(p12:GetChildren()) do
			if child:IsA("Highlight") and child.Name == "TrapESPHL" then
				return
			end
		end

		local Highlight = Instance.new("Highlight")

		Highlight.Name = "TrapESPHL"
		Highlight.FillColor = Color3.fromRGB(255, 100, 0)
		Highlight.FillTransparency = 0.2
		Highlight.OutlineColor = Color3.fromRGB(255, 100, 0)
		Highlight.OutlineTransparency = 0
		Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		Highlight.Parent = p12
		table.insert(t6, Highlight)
	end
	v75 = function()
		for E, E in pairs(t6) do
			if E and E.Parent then
				E:Destroy()
			end
		end

		t6 = {}

		if not t1.trap then
			return
		end

		task.spawn(function()
			local E = 0

			for F, F in ipairs(workspace:GetDescendants()) do
				if not t1.trap then
					return
				end

				if #t6 >= ValtESP.trapCap then
					return
				end

				E = E + 1

				if E >= 800 then
					E = 0
					task.wait()
				end

				if v73(F) then
					v74(F)
				end
			end
		end)
	end
	ValtESP.brighten = function(p13, p14)
		local v246 = p14 or 0.45

		return Color3.new(p13.R + (1 - p13.R) * v246, p13.G + (1 - p13.G) * v246, p13.B + (1 - p13.B) * v246)
	end
	ValtESP.budget = ValtESP.slice.players
	ValtESP.color = {
		murderer = Color3.fromRGB(255, 0, 0),
		sheriff = Color3.fromRGB(0, 100, 255),
		innocent = Color3.fromRGB(0, 255, 0)
	}
	ValtESP.rank = {
		murderer = 0,
		sheriff = 1,
		innocent = 2
	}
	ValtESP.fillT = 0.78
	ValtESP.outlineT = 0
	ValtESP.glow = 0.45
	ValtESP.paint = function(p15, p16)
		p15.FillColor = p16
		p15.FillTransparency = ValtESP.fillT
		p15.OutlineColor = ValtESP.brighten(p16, ValtESP.glow)
		p15.OutlineTransparency = ValtESP.outlineT
	end
	ValtESP.make = function(p17, p18)
		local Highlight = Instance.new("Highlight")

		Highlight.Name = "ValtRoleESP"
		ValtESP.paint(Highlight, p18)
		Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		Highlight.Adornee = p17
		Highlight.Enabled = true
		Highlight.Parent = p17

		return Highlight
	end
	ValtESP.repaint = function()
		for _, v in pairs(t5) do
			if v.h and v.h.Parent then
				pcall(function()
					ValtESP.paint(v.h, ValtESP.color[v.role] or v.h.FillColor)
				end)
			end
		end
	end

	local function v250(p19, p20)
		if not p19 or not p19.Character then
			return nil
		end

		local Character2 = p19.Character

		for _, child in ipairs(Character2:GetChildren()) do
			if child:IsA("Highlight") and child.Name == "ValtRoleESP" then
				child:Destroy()
			end
		end

		return ValtESP.make(Character2, p20)
	end

	ValtESP.drop = function(p21)
		local v254 = t5[p21]

		if not v254 then
			return
		end

		if v254.h then
			pcall(function()
				v254.h:Destroy()
			end)
		end

		t5[p21] = nil
	end
	ValtESP.clearAll = function()
		for k in pairs(t5) do
			ValtESP.drop(k)
		end
	end
	ValtRound.onDowned = function(p22)
		ValtESP.drop(p22)
	end
	v76 = function()
		local E = t1.murderer or t1.sheriff or t1.innocent

		if not E then
			ValtESP.clearAll()

			return
		end

		local E

		do
			local k = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

			E = k and k.Position
		end

		local k = {}

		for P, P in ipairs(Players:GetPlayers()) do
			local V = (P ~= LocalPlayer) and P.Character or nil
			local J = V and V:FindFirstChild("HumanoidRootPart")
			local f = V and V:FindFirstChildOfClass("Humanoid")

			if J and f and f.Health > 0 and not ValtRound.isDead(P) then
				local f = u71(P)

				if t1[f] then
					local i = E and (J.Position - E).Magnitude or 0

					k[#k + 1] = { plr = P, char = V, role = f, rank = ValtESP.rank[f] or 3, dist = i }
				end
			end
		end

		table.sort(k, function(E, i)
			if E.rank ~= i.rank then
				return E.rank < i.rank
			end

			return E.dist < i.dist
		end)

		local E = {}

		for i = 1, math.min(#k, ValtESP.budget) do
			local D = k[i]

			E[D.plr] = true

			local i = t5[D.plr]
			local V = ValtESP.color[D.role]
			local J = (not i) or i.char ~= D.char or not i.h or i.h.Parent ~= D.char or i.h.Adornee ~= D.char

			if J then
				ValtESP.drop(D.plr)

				local J = v250(D.plr, V)

				if J then
					t5[D.plr] = { h = J, char = D.char, role = D.role }
				end
			else
				if not i.h.Enabled then
					i.h.Enabled = true
				end

				if i.role ~= D.role then
					i.role = D.role
					ValtESP.paint(i.h, V)
				end
			end
		end

		for i, D in pairs(t5) do
			if not E[i] or not i.Parent then
				ValtESP.drop(i)
			elseif D.h and D.h.Parent == nil then
				ValtESP.drop(i)
			end
		end
	end
end

ValtESP.watch = function(p23)
	if p23 == LocalPlayer then
		return
	end

	local v276 = "espChar_" .. p23.UserId

	if ValtConns[v276] then
		ValtConns[v276]:Disconnect()
	end

	ValtConns[v276] = p23.CharacterAdded:Connect(function()
		if ValtState.gen == gen then
			ValtESP.drop(p23)
			task.delay(0.35, function()
				if t1.murderer or t1.sheriff or t1.innocent then
					pcall(v76)
				end
			end)

			return
		end

		ValtConns[v276]:Disconnect()
	end)
end

for _, player in ipairs(Players:GetPlayers()) do
	ValtESP.watch(player)
end

ValtConns.espJoin = Players.PlayerAdded:Connect(function(player)
	if ValtState.gen == gen then
		ValtESP.watch(player)

		return
	end

	ValtConns.espJoin:Disconnect()
end)
ValtConns.espLeave = Players.PlayerRemoving:Connect(function(player)
	if ValtState.gen ~= gen then
		ValtConns.espLeave:Disconnect()

		return
	end

	local v279 = "espChar_" .. player.UserId

	if ValtConns[v279] then
		ValtConns[v279]:Disconnect()
		ValtConns[v279] = nil
	end

	ValtESP.drop(player)
end)
task.spawn(function()
	return (pcall(function()
		ValtConns.espRoleFlip = ValtRound.changed.Event:Connect(function()
			if ValtState.gen ~= gen then
				ValtConns.espRoleFlip:Disconnect()

				return
			end

			if t1.murderer or t1.sheriff or t1.innocent then
				pcall(v76)
			end
		end)
	end))
end)

local v280

do
	local function createBillboardGui(p24)
		if not p24 then
			return nil
		end

		local BillboardGui = Instance.new("BillboardGui")

		BillboardGui.Size = UDim2.new(0, 100, 0, 20)
		BillboardGui.Adornee = p24
		BillboardGui.AlwaysOnTop = true
		BillboardGui.MaxDistance = 300
		BillboardGui.Parent = p24

		local TextLabel = Instance.new("TextLabel")

		TextLabel.Size = UDim2.new(1, 0, 1, 0)
		TextLabel.BackgroundTransparency = 1
		TextLabel.Text = "Dropped Gun"
		TextLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
		TextLabel.TextScaled = true
		TextLabel.Font = Enum.Font.GothamBold
		TextLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		TextLabel.TextStrokeTransparency = 0.3
		TextLabel.Parent = BillboardGui
		table.insert(t3, BillboardGui)

		return BillboardGui
	end

	v280 = function(p25)
		if not p25 then
			return
		end

		if ValtESP.slice.gunDrops <= #t2 then
			return
		end

		for k, v in pairs(t2) do
			if v and v.Parent == p25 then
				v:Destroy()
				t2[k] = nil
			end
		end

		local Highlight = Instance.new("Highlight")

		Highlight.FillColor = Color3.fromRGB(255, 255, 0)
		Highlight.FillTransparency = 0.3
		Highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
		Highlight.OutlineTransparency = 0
		Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		Highlight.Parent = p25
		table.insert(t2, Highlight)
		createBillboardGui(p25)
	end
end

local function v287()
	for E, E in pairs(t2) do
		if E and E.Parent then
			E:Destroy()
		end
	end

	t2 = {}

	for E, E in pairs(t3) do
		if E and E.Parent then
			E:Destroy()
		end
	end

	t3 = {}

	if not u36 then
		return
	end

	task.spawn(function()
		local E = 0

		for H, H in ipairs(Workspace:GetDescendants()) do
			if not u36 then
				return
			end

			E = E + 1

			if E >= 800 then
				E = 0
				task.wait()
			end

			if H.Name == "GunDrop" and H:IsA("BasePart") then
				v280(H)
			end
		end
	end)
end

do
	local color3 = Color3.fromRGB(255, 225, 120)
	local coins = ValtESP.slice.coins
	local t9 = {}

	local function findCoinContainer()
		for _, child in ipairs(Workspace:GetChildren()) do
			local CoinContainer = child:FindFirstChild("CoinContainer")

			if CoinContainer then
				return CoinContainer
			end
		end

		return nil
	end
	local function v302(p26)
		local CoinVisual = p26:FindFirstChild("CoinVisual")

		if CoinVisual then
			return CoinVisual:FindFirstChild("MainCoin") or CoinVisual:FindFirstChildWhichIsA("MeshPart")
		end

		return nil
	end
	local function v304(p27)
		local v305 = v302(p27)

		if not v305 then
			return nil
		end

		if not t9[v305] then
			t9[v305] = {
				transparency = v305.Transparency
			}
		end

		if v305.Transparency ~= 0 then
			v305.Transparency = 0
		end

		return v305
	end
	local function v306()
		for k, v in pairs(t9) do
			if k and k.Parent then
				k.Transparency = v.transparency
			end

			t9[k] = nil
		end
	end
	local function removeCoinESP(p28)
		if t4[p28] then
			t4[p28]:Destroy()
			t4[p28] = nil
		end
	end
	local function v310()
		for k in pairs(t4) do
			removeCoinESP(k)
		end

		v306()
	end
	local function v312()
		local E = findCoinContainer()

		if not E then
			for k in pairs(t4) do
				removeCoinESP(k)
			end

			return
		end

		local k, N = {}, {}

		for j, j in ipairs(E:GetChildren()) do
			if j.Name == "Coin_Server" and not j:GetAttribute("Collected") then
				k[j] = true
				N[#N + 1] = j
				v304(j)
			end
		end

		for E in pairs(t4) do
			if not k[E] then
				removeCoinESP(E)
			end
		end

		for E in pairs(t9) do
			if not E.Parent then
				t9[E] = nil
			end
		end

		local E = LocalPlayer.Character
		local D = E and E:FindFirstChild("HumanoidRootPart")

		if D then
			local E, H = D.Position, {}

			for D, D in ipairs(N) do
				H[D] = (D.Position - E).Magnitude
			end

			table.sort(N, function(E, D)
				return H[E] < H[D]
			end)
		end

		for E, D in ipairs(N) do
			if E <= coins then
				local E = v302(D)

				if E then
					local H = t4[D]

					if not H or not H.Parent then
						H = Instance.new("Highlight")
						H.Name = "CoinESPHL"
						H.FillColor = color3
						H.FillTransparency = 0.3
						H.OutlineTransparency = 1
						H.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						H.Parent = CoreGui
						t4[D] = H
					end

					if H.Adornee ~= E then
						H.Adornee = E
					end
				end
			elseif t4[D] then
				removeCoinESP(D)
			end
		end
	end

	ValtESP.findCoinContainer = findCoinContainer
	ValtESP.removeCoinESP = removeCoinESP
	ValtESP.setupCoinESP = function()
		if thread2 then
			task.cancel(thread2)
			thread2 = nil
		end

		v310()

		if not u41 then
			return
		end

		thread2 = task.spawn(function()
			local E = true

			while u41 do
				local H, V = pcall(v312)

				if not H then
					warn("[Valt/CoinESP] refresh failed: " .. tostring(V))
				end

				if E then
					E = false

					local E = 0

					for D in pairs(t4) do
						E += 1
					end

					print("[Valt/CoinESP] ON ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â\u{9D} highlighted " .. E .. " coin(s)")
				end

				task.wait(0.5)
			end
		end)
	end
end

local function v336(p29, ...)
	local t10 = { ... }

	if not p29 then
		return nil
	end

	for _, child in ipairs(p29:GetChildren()) do
		if not child:IsA("Tool") then
			continue
		end

		local v340 = child.Name:lower()

		for _, v in ipairs(t10) do
			if v340:find(v) then
				return child
			end
		end
	end

	return nil
end
local function v343()
	local t11 = {
		"knife",
		"dagger",
		"blade",
		"sword"
	}

	return v336(Character, table.unpack(t11)) or v336(LocalPlayer.Backpack, table.unpack(t11))
end

ValtESP.drops = {}

local v345

do
	local function v346()
		for k in pairs(ValtESP.drops) do
			if k.Parent and k:IsDescendantOf(Workspace) then
				return k
			end

			ValtESP.drops[k] = nil
		end

		local GunDrop = Workspace:FindFirstChild("GunDrop", true)

		if not GunDrop or not GunDrop:IsA("BasePart") then
			return
		end

		ValtESP.drops[GunDrop] = true

		return GunDrop
	end

	local t12 = {
		file = "ValtHubHub/touch_guard.txt",
		unsafe = false
	}

	local function v350()
		local v351 = t12

		if ValtExec.name:lower():find("nexomia", 1, true) then
			v351.unsafe = true
			v351.why = "crashes on this executor"
		end

		pcall(function()
			if isfile and isfile(v351.file) then
				if readfile(v351.file) == ValtExec.name then
					v351.unsafe = true
					v351.why = "Roblox closed during a grab last run"
				end
			end
		end)
	end

	v350()

	local function v352(p30)
		pcall(function()
			if not writefile then
				return
			end

			if makefolder and isfolder then
				if not isfolder("ValtHubHub") then
					makefolder("ValtHubHub")
				end
			end

			writefile(t12.file, p30 and ValtExec.name or "")
		end)
	end

	v345 = function()
		local E = v346()

		if not E then
			return false
		end

		local F = obj[E]

		if F and os.clock() - F < 1 then
			return false
		end

		local F = LocalPlayer.Character

		if not F then
			return false
		end

		local J = F:FindFirstChild("HumanoidRootPart")

		if not J then
			return false
		end

		local k = F:GetPivot()

		if type(firetouchinterest) == "function" and not t12.unsafe then
			v352(true)
			F:PivotTo(CFrame.new(E.Position + Vector3.new(0, 2.5, 0)))
			task.wait(0.02)
			pcall(function()
				firetouchinterest(J, E, 0)
				firetouchinterest(J, E, 1)
			end)
			F:PivotTo(k)
			v352(false)
			obj[E] = os.clock()

			return true
		end

		local function H()
			local V = LocalPlayer:FindFirstChildOfClass("Backpack")

			return F:FindFirstChild("Gun") ~= nil or (V ~= nil and V:FindFirstChild("Gun") ~= nil)
		end

		local D = os.clock() + 0.8

		repeat
			pcall(function()
				F:PivotTo(CFrame.new(E.Position))
				J.AssemblyLinearVelocity = Vector3.zero
			end)
			task.wait()
		until H() or not E.Parent or os.clock() > D

		if not H() and not E.Parent then
			task.wait(0.2)
		end

		F:PivotTo(k)
		obj[E] = os.clock()

		return H()
	end
	ValtX = {
		btn = {
			folder = "ValtHubHub",
			file = "ValtHubHub/button_layout.json",
			version = 6,
			layout = {},
			objects = {},
			saving = false,
			scale = ValtPlat.mobile and 0.62 or 1,
			locked = false,
			fade = 0.3,
			MIN_PX = 30,
			MAX_PX = 280,
			MAX_W = 480,
			COMPACT_PX = 36
		},
		uiScale = 1,
		actions = {},
		keys = {
			map = {},
			actions = {},
			enabled = true
		},
		gun = {
			cooldown = 3,
			autoTrack = true,
			lastShot = 0,
			blockDuringCd = true
		},
		trace = {
			on = false,
			style = "Beam",
			life = 2.5,
			color = Color3.fromRGB(0, 255, 170),
			thickness = 0.28,
			impact = true,
			others = false
		},
		sfx = {
			on = false,
			volume = 0.6,
			customShoot = "",
			customKill = "",
			lastAt = 0
		},
		perf = {
			master = false,
			textures = false,
			particles = false,
			effects = false,
			shadows = false,
			lowQuality = false,
			fpsCounter = false,
			conns = {},
			lastStripped = 0
		},
		esp = {
			names = false,
			tracers = false,
			arrow = false,
			box = false,
			showRole = true,
			showDistance = true,
			showHealth = false,
			showHealthBar = true,
			tracerFrom = "Bottom",
			tracerThickness = 2,
			boxThickness = 2,
			maxDistance = 0
		},
		world = {}
	}
	ValtX.btn.meta = {
		ShootMurdButton = {
			image = "rbxassetid://3187399148",
			plain = true,
			color = Color3.fromRGB(99, 102, 241)
		},
		GrabGunButton = {
			image = "rbxassetid://130703864968637",
			color = Color3.fromRGB(34, 197, 94)
		},
		AimbotButton = {
			image = "rbxassetid://82947033619201",
			color = Color3.fromRGB(20, 184, 166)
		},
		BombJumpButton = {
			image = "rbxassetid://139223800924636",
			color = Color3.fromRGB(249, 115, 22)
		},
		KillAllButton = {
			image = "rbxassetid://137726256442333",
			color = Color3.fromRGB(239, 68, 68)
		},
		KillSheriffButton = {
			image = "rbxassetid://122931434733842",
			color = Color3.fromRGB(220, 38, 38)
		},
		FlyButton = {
			image = "rbxassetid://126985561580989",
			color = Color3.fromRGB(14, 165, 233)
		},
		NoclipButton = {
			image = "rbxassetid://113822048130017",
			color = Color3.fromRGB(148, 163, 184)
		},
		XrayButton = {
			image = "rbxassetid://100033680381365",
			color = Color3.fromRGB(132, 204, 22)
		},
		SpeedButton = {
			image = "rbxassetid://130551565616516",
			color = Color3.fromRGB(234, 179, 8)
		},
		TpMapButton = {
			image = "rbxassetid://95107167260947",
			color = Color3.fromRGB(236, 72, 153)
		},
		TpLobbyButton = {
			image = "rbxassetid://98755624629571",
			color = Color3.fromRGB(100, 116, 139)
		},
		EspToggleButton = {
			image = "rbxassetid://99244790601968",
			color = Color3.fromRGB(217, 70, 239)
		},
		ThrowKnifeButton = {
			image = "rbxassetid://124448418211665",
			color = Color3.fromRGB(190, 130, 255)
		},
		SilentAimButton = {
			image = "rbxassetid://134242818164054",
			color = Color3.fromRGB(56, 189, 248)
		}
	}
	ValtX.round = ValtRound
	ValtX.canTouch = type(firetouchinterest) == "function"
	ValtSafe("L1437", function()
		local E = {}

		local function D(H, V, F)
			if type(V) ~= "function" then
				E[#E + 1] = H .. " - " .. F
			end
		end

		D("loadstring", loadstring, "FATAL: the UI library cannot be compiled, nothing loads")
		D("firetouchinterest", firetouchinterest, "autofarm and Grab Gun physically touch instead - slower, still works")

		if t12.unsafe then
			E[#E + 1] = "firetouchinterest on the gun - " .. t12.why .. "; Grab Gun walks onto the gun instead"
		end

		D("writefile", writefile, "button layout, forced layout and saved configs will not persist between runs")
		D("getgc", getgc, "weapon spawner finds MM2's inventory by require instead - no loss")

		local i = setclipboard or toclipboard or writeclipboard or (syn and syn.write_clipboard) or (Clipboard and Clipboard.set)

		if not i then
			E[#E + 1] = "clipboard - Discord button shows the invite instead of copying it"
		end

		local i, D = pcall(function()
			return type(game.HttpGet) == "function"
		end)

		if not (i and D) then
			E[#E + 1] = "HttpGet - FATAL on first run; also no weapon skins and no server hop"
		end

		ValtX.missingFeatures = E

		if #E > 0 then
			warn("[Valt] executor limits:")

			for i, i in ipairs(E) do
				warn("  - " .. i)
			end
		end
	end)
end

ValtX.mod = {}
ValtSafe("L1475", function()
	local E = {}
	local D = {}
	local H = {}
	local V = { 3, 10, 30 }
	local F = not ValtExec.limited
	local J = not ValtExec.limited and type(getgc) == "function"

	local function k(P)
		local f = ReplicatedStorage

		for i, i in ipairs(P) do
			f = f and f:FindFirstChild(i)
		end

		return f
	end
	local function i(P, f)
		if not (F and P) then
			return nil
		end

		local F = k(P)

		if not (F and F:IsA("ModuleScript")) then
			return nil
		end

		local P, S = pcall(require, F)

		if P and type(S) == "table" then
			local F, P = pcall(f, S)

			if F and P then
				return S
			end
		end

		return nil
	end
	local function F(P, f)
		if not P then
			return nil
		end

		if type(getconnections) ~= "function" then
			return nil
		end

		if type(debug) ~= "table" or type(debug.getupvalues) ~= "function" then
			return nil
		end

		for S, S in ipairs(P) do
			local P = k(S)
			local k

			pcall(function()
				k = P and P.Event
			end)

			if k then
				local P, S = pcall(getconnections, k)

				if P and type(S) == "table" then
					for k, k in ipairs(S) do
						local P

						pcall(function()
							P = k.Function
						end)

						if type(P) == "function" then
							local k, S = pcall(debug.getupvalues, P)

							if k and type(S) == "table" then
								for k, k in pairs(S) do
									local P, S = pcall(f, k)

									if P and S then
										return k
									end

									if type(k) == "table" then
										for P, P in pairs(k) do
											local k, S = pcall(f, P)

											if k and S then
												return P
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

		return nil
	end
	local function k(P, f)
		if not J or H[P] then
			return
		end

		H[P] = true
		task.spawn(function()
			local H, J = pcall(getgc, true)

			if not H or type(J) ~= "table" then
				return
			end

			for H = 1, #J do
				if E[P] ~= nil then
					return
				end

				local S = J[H]

				if type(S) == "table" then
					local J, N = pcall(f, S)

					if J and N then
						E[P] = S

						return
					end
				end

				if H % 5000 == 0 then
					task.wait()
				end
			end
		end)
	end
	local function H(J, P, f, S)
		local N = E[J]

		if N ~= nil then
			return N
		end

		local N = D[J]

		if N then
			if N.n > #V then
				return nil
			end

			if os.clock() < N.at then
				return nil
			end
		end

		local j = i(f, P) or F(S, P)

		if j then
			E[J] = j
			D[J] = nil

			return j
		end

		k(J, P)
		N = N or { n = 0, at = 0 }
		N.n = N.n + 1
		N.at = os.clock() + (V[N.n] or math.huge)
		D[J] = N

		return nil
	end

	function ValtX.mod.gaveUp(i)
		local F = D[i]

		return F ~= nil and F.n > #V and E[i] == nil
	end
	function ValtX.mod.profileData()
		return H("ProfileData", function(E)
			local i = rawget(E, "Weapons")

			return type(i) == "table" and type(rawget(i, "Owned")) == "table" and type(rawget(i, "Equipped")) == "table"
		end, { "Modules", "ProfileData" }, { { "Remotes", "Inventory", "ProfileDataChanged" }, { "Remotes", "Inventory", "InventoryDataChanged" } })
	end
	function ValtX.mod.weaponService()
		return H("WeaponService", function(E)
			return type(rawget(E, "GetMouseTargetCFrame")) == "function"
		end, { "ClientServices", "WeaponService" })
	end
	function ValtX.mod.databaseSync()
		return H("DatabaseSync", function(E)
			local i = rawget(E, "Weapons")

			if type(i) ~= "table" or rawget(i, "Owned") ~= nil then
				return false
			end

			for E, E in pairs(i) do
				if type(E) == "table" and rawget(E, "ItemType") ~= nil then
					return true
				end
			end

			return false
		end, { "Database", "Sync" })
	end
end)
ValtX.lastBreath = 0
ValtX.breathe = function()
	local now = os.clock()

	if now - ValtX.lastBreath > 0.008 then
		ValtX.lastBreath = now
		task.wait()
	end
end
ValtX.btn.root = function()
	local ok, result = pcall(function()
		return gethui and gethui()
	end)

	if not ok or not result then
		return CoreGui
	end

	return result
end
ValtX.btn.load = function()local E=ValtX.btn;local i,D=pcall(function()if isfile and isfile(E.file)then return readfile(E.file);end;return nil;end);if not i or type(D)~='str\105n\z g'or D==''then return;end;local i,H=pcall(function()return game:GetService('Htt\112\83ervic\z\101'):JSONDecode(D);end);if not i or type(H)~="\z tab\z le"then return;end;if H.v==E.version and type(H.pos)=='\u{74}a\x62\u{06C}\z  e'then E.layout=H.pos;else E.layout={};end;if type(H.scale)=='n\z \u{75}mbe\x72'and H.scale~=0.74 then E.scale=math.clamp(H.scale,0.5,1.6);end;if type(H.locked)=="\u{0062}\111o\lea\110"then E.locked=H.locked;end;if type(H.fade)=="\u{6E}\117m\u{0062}e\114"then E.fade=math.clamp(H.fade,0,0.85);end;if type(H.shown)=="tab\z  le"then E.shown=H.shown;else E.shown={};end;if type(H.keys)=="t\u{61}\98le"then ValtX.keys.map=H.keys;end;end
ValtX.btn.save = function()local E=ValtX.btn;if E.saving then return;end;E.saving=true;task.delay(0.35,function()E.saving=false;pcall(function()if makefolder and isfolder and not isfolder(E.folder)then makefolder(E.folder);end;if not writefile then return;end;writefile(E.file,game:GetService('\zH\116\116\z  \112Ser\118\u{069}\99e'):JSONEncode({v=E.version,pos=E.layout,scale=E.scale,locked=E.locked,fade=E.fade,shown=E.shown or{},keys=ValtX.keys.map}));end);end);end
ValtX.btn.slotCount = 13
ValtX.btn.slot = function(E)
	local D = Workspace.CurrentCamera.ViewportSize
	local i = math.floor((ValtPlat.mobile and 68 or 78) * ValtX.btn.scale)
	local H = i + (ValtPlat.mobile and 4 or 6)
	local V = ValtX.btn.slotCount
	local F = math.ceil(V / 2)
	local J = E > F
	local k = J and (E - F) or E
	local E = J and (V - F) or F
	local P = math.max(3, math.floor((D.X * 0.96) / H))
	local f = math.max(1, math.ceil(E / P))
	local S = math.ceil(E / f)
	local E = (k - 1) % S
	local f = math.floor((k - 1) / S)
	local k = S * H - (H - i)
	local S = (D.X - k) / 2
	local k = 0

	pcall(function()
		k = game:GetService("GuiService"):GetGuiInset().Y
	end)

	local N = ValtPlat.mobile
	local j = N and (k + 4) or math.max(math.floor(D.Y * 0.03), k + 10)
	local k = i + (ValtPlat.mobile and 4 or 6)
	local i = math.max(1, math.ceil(F / P))
	local N = J and (i * k + 4) or 0
	local J = j + N + f * k
	local f = i + math.max(1, math.ceil((V - F) / P))
	local i = f * k + 4

	if j + i > D.Y then
		J = J - (j + i - D.Y)
	end

	return UDim2.new(0, math.floor(S + E * H), 0, math.floor(math.max(0, J)))
end
ValtX.btn.clamp = function(p31, p32, p33)
	local ViewportSize = Workspace.CurrentCamera.ViewportSize
	local v454 = p31.Y.Scale * ViewportSize.Y + p31.Y.Offset
	local v455 = math.clamp(p31.X.Scale * ViewportSize.X + p31.X.Offset, 0, math.max(0, ViewportSize.X - p32))
	local v456 = math.clamp(v454, 0, math.max(0, ViewportSize.Y - (p33 or p32)))

	return UDim2.new(0, math.floor(v455), 0, math.floor(v456))
end
ValtX.btn.load()

if not ValtX.btn.shown then
	ValtX.btn.shown = {}
end

for _, v in ipairs({
	"WallHopButton",
	"PanicButton",
	"InfJumpButton",
	"TpMurdButton"
}) do
	ValtX.btn.shown[v] = nil
	ValtX.btn.layout[v] = nil
end

local function v459(E, D, H)
	local V = E.UserInputType == Enum.UserInputType.Touch
	local F, J

	local function k()
		if F then
			F:Disconnect()
			F = nil
		end

		if J then
			J:Disconnect()
			J = nil
		end
	end

	F = UserInputService.InputChanged:Connect(function(F)
		if (V and F == E) or (not V and F.UserInputType == Enum.UserInputType.MouseMovement) then
			D(F.Position)
		end
	end)
	J = UserInputService.InputEnded:Connect(function(i)
		if (V and i == E) or (not V and i.UserInputType == Enum.UserInputType.MouseButton1) then
			k()
			D(i.Position)
			H()
		end
	end)

	return k
end
local function v464(E, F, J, k, P)
	local f = ValtX.btn

	P = P or {}

	local S = f.meta[E] or {}
	local N = P.color or S.color or Color3.fromRGB(200, 200, 210)
	local j = Instance.new("ScreenGui")

	j.Name = E
	j.ResetOnSpawn = false
	j.IgnoreGuiInset = true
	j.DisplayOrder = 100000
	j.Parent = f.root()

	local O = (ValtPlat.mobile and 68 or 78)
	local R = f.layout[E]
	local C = type(R) == "table" and tonumber(R.k) or nil
	local T = (type(R) == "table" and tonumber(R.kw)) or C or 1
	local W = (type(R) == "table" and tonumber(R.kh)) or C or 1
	local C = f.MAX_W or 360

	local function _(z, Y, q)
		return math.floor(math.clamp(O * z * Y, f.MIN_PX, q))
	end

	local z, Y = _(f.scale, T, C), _(f.scale, W, f.MAX_PX)
	local q = Instance.new("TextButton")

	q.Name = "Card"
	q.Size = UDim2.fromOffset(z, Y)
	q.Text = ""
	q.BackgroundTransparency = 1
	q.BorderSizePixel = 0
	q.AutoButtonColor = false
	q.ZIndex = 2
	q.Parent = j

	if type(R) == "table" and tonumber(R.x) and tonumber(R.y) then
		q.Position = f.clamp(UDim2.new(0, tonumber(R.x), 0, tonumber(R.y)), z, Y)
	else
		q.Position = f.clamp(J or UDim2.new(0.86, -z / 2, 0.5, 0), z, Y)
	end

	local function R()
		return math.clamp(tonumber(f.fade) or 0.3, 0, 0.85)
	end

	local t = Instance.new("Frame")

	t.Name = "Body"
	t.AnchorPoint = Vector2.new(0.5, 0.5)
	t.Position = UDim2.new(0.5, 0, 0.5, 0)
	t.Size = UDim2.new(1, 0, 1, 0)
	t.BackgroundColor3 = Color3.fromRGB(6, 6, 8)
	t.BackgroundTransparency = R()
	t.BorderSizePixel = 0
	t.ZIndex = 2
	t.Parent = q

	local Q = Instance.new("UICorner", t)
	local a = Color3.fromRGB(122, 126, 140)
	local X = Color3.fromRGB(228, 232, 245)
	local m = Instance.new("UIGradient", t)

	m.Rotation = 90
	m.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(17, 18, 22)), ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 4, 6)) })

	local m = Instance.new("UIStroke", t)

	m.Color = a
	m.Thickness = 2.2
	m.Transparency = 0.34
	m.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	local c, A = nil, nil
	local x = Instance.new("Frame")

	x.Name = "IconPad"
	x.BackgroundColor3 = N
	x.BackgroundTransparency = 1
	x.BorderSizePixel = 0
	x.ZIndex = 3
	x.Parent = t
	Instance.new("UICorner", x).CornerRadius = UDim.new(1, 0)

	local n = Instance.new("UIStroke", x)

	n.Color = N
	n.Thickness = 1.2
	n.Transparency = 1

	local n = Instance.new("ImageLabel")

	n.AnchorPoint = Vector2.new(0.5, 0.5)
	n.Position = UDim2.new(0.5, 0, 0.5, 0)
	n.Size = UDim2.new(0.74, 0, 0.74, 0)
	n.BackgroundTransparency = 1
	n.ScaleType = Enum.ScaleType.Fit
	n.Image = P.image or S.image or ""
	n.ImageColor3 = N
	n.ZIndex = 4
	n.Parent = x

	local b = (P.plain or S.plain) and true or false

	if b then
		n.ImageColor3 = Color3.fromRGB(255, 255, 255)
	end

	local function P(S)
		if not b then
			n.ImageColor3 = S
		end
	end

	local S = Instance.new("TextLabel")

	S.Name = "Caption"
	S.AnchorPoint = Vector2.new(0.5, 1)
	S.BackgroundTransparency = 1
	S.Text = string.upper(F)
	S.TextScaled = true
	S.TextWrapped = true
	S.Font = Enum.Font.GothamBold
	S.TextColor3 = Color3.fromRGB(236, 238, 245)
	S.LineHeight = 0.94
	S.ZIndex = 3
	S.Parent = t

	local n = Instance.new("UITextSizeConstraint", S)

	n.MinTextSize = 6

	local b = Instance.new("Frame")

	b.Name = "Cooldown"
	b.Size = UDim2.new(1, 0, 1, 0)
	b.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	b.BackgroundTransparency = 1
	b.BorderSizePixel = 0
	b.ClipsDescendants = true
	b.Visible = false
	b.ZIndex = 6
	b.Parent = t

	local d = Instance.new("UICorner", b)
	local L = Instance.new("TextLabel")

	L.AnchorPoint = Vector2.new(0.5, 0.5)
	L.BackgroundTransparency = 1
	L.Text = ""
	L.TextScaled = true
	L.Font = Enum.Font.GothamBold
	L.TextColor3 = Color3.fromRGB(255, 92, 92)
	L.ZIndex = 7
	L.Parent = b

	local Z = Instance.new("TextLabel")

	Z.AnchorPoint = Vector2.new(0.5, 1)
	Z.BackgroundTransparency = 1
	Z.Text = "RELOADING"
	Z.TextScaled = true
	Z.Font = Enum.Font.GothamMedium
	Z.TextColor3 = Color3.fromRGB(206, 128, 128)
	Z.ZIndex = 7
	Z.Parent = b

	local g = Instance.new("UITextSizeConstraint", Z)

	g.MinTextSize = 5

	local e = Instance.new("Frame")

	e.AnchorPoint = Vector2.new(0, 1)
	e.Position = UDim2.new(0, 0, 1, 0)
	e.Size = UDim2.new(1, 0, 0, 3)
	e.BackgroundColor3 = Color3.fromRGB(255, 92, 92)
	e.BorderSizePixel = 0
	e.ZIndex = 8
	e.Parent = b
	e.Visible = true

	local G = ValtPlat.mobile and 8 or 4
	local u = ValtPlat.mobile and 4 or 3
	local v = Instance.new("TextButton")

	v.Name = "ResizeGrip"
	v.AnchorPoint = Vector2.new(1, 1)
	v.Position = UDim2.new(1, G, 1, G)
	v.BackgroundTransparency = 1
	v.BorderSizePixel = 0
	v.Text = ""
	v.AutoButtonColor = false
	v.ZIndex = 10
	v.Visible = not f.locked
	v.Parent = q

	local w = Instance.new("Frame")

	w.BackgroundTransparency = 1
	w.ZIndex = 10
	w.Parent = v

	local U = {}

	for B, B in ipairs({ { 0.62, 0.34 }, { 0.34, 0.62 }, { 0.62, 0.62 } }) do
		local o = Instance.new("Frame")

		o.AnchorPoint = Vector2.new(0.5, 0.5)
		o.Position = UDim2.fromScale(B[1], B[2])
		o.Size = UDim2.fromOffset(u, u)
		o.BackgroundColor3 = Color3.fromRGB(236, 238, 245)
		o.BackgroundTransparency = 0.35
		o.BorderSizePixel = 0
		o.ZIndex = 11
		o.Parent = w
		Instance.new("UICorner", o).CornerRadius = UDim.new(1, 0)
		U[#U + 1] = o
	end

	local function u(B)
		for o, o in ipairs(U) do
			o.BackgroundTransparency = B and 0 or 0.35
			o.BackgroundColor3 = B and N or Color3.fromRGB(236, 238, 245)
		end
	end

	m.Transparency = 0.34

	local U, B, o = 0, nil, false
	local l = {}
	local M, p = z, Y
	local s, K = nil, nil
	local y, I = false, 0

	local function r()
		if y or os.clock() - I < 0.35 then
			return
		end

		if os.clock() < U then
			return
		end

		TweenService:Create(t, TweenInfo.new(0.07, Enum.EasingStyle.Quad), { Size = UDim2.new(0.9, 0, 0.9, 0) }):Play()
		task.delay(0.09, function()
			if t and t.Parent then
				TweenService:Create(t, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 1, 0) }):Play()
			end
		end)
		k(l)
	end

	v58(q, r)

	local function H()
		local V = { x = math.floor(q.Position.X.Offset), y = math.floor(q.Position.Y.Offset) }

		if math.abs(T - 1) > 0.01 then
			V.kw = math.floor(T * 1000 + 0.5) / 1000
		end

		if math.abs(W - 1) > 0.01 then
			V.kh = math.floor(W * 1000 + 0.5) / 1000
		end

		f.layout[E] = V
		f.save()
	end
	local function V(k)
		k = string.upper(tostring(k))

		if c == "wide" then
			k = (k:gsub("%s*\n%s*", " "))
		end

		return k
	end

	l.id = E
	l.gui = j
	l.card = t
	l.dead = false
	l.setLabel = function(k, r)
		if l.dead then
			return
		end

		if A then
			P(r or N)

			return
		end

		S.Text = V(k)
		S.TextColor3 = r or Color3.fromRGB(236, 238, 245)
	end
	l.resetLabel = function()
		if l.dead then
			return
		end

		if A then
			P(o and Color3.fromRGB(255, 255, 255) or N)

			return
		end

		S.Text = V(F)
		S.TextColor3 = o and N or Color3.fromRGB(236, 238, 245)
	end
	l.flash = function(V, F, k)
		l.setLabel(V, F)
		task.delay(k or 1, l.resetLabel)
	end

	local function V()
		if o then
			x.BackgroundTransparency = 0.86
			P(Color3.fromRGB(255, 255, 255))
			m.Color = X
			m.Thickness = 2.8
			m.Transparency = 0.05
			t.BackgroundTransparency = R()

			if not A then
				S.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
		else
			x.BackgroundTransparency = 1
			P(N)
			m.Color = a
			m.Thickness = 2.2
			m.Transparency = 0.34
			t.BackgroundTransparency = R()

			if not A then
				S.TextColor3 = Color3.fromRGB(236, 238, 245)
			end
		end
	end
	local function F(k, N)
		M, p = k, N

		local a = math.min(k, N)
		local X = c

		if k >= N * 1.6 and N >= 24 then
			c = "wide"
		elseif a < f.COMPACT_PX then
			c = "compact"
		else
			c = "stack"
		end

		A = (c == "compact")
		q.Size = UDim2.fromOffset(k, N)

		local r = UDim.new(0, math.floor(a * 0.22))

		Q.CornerRadius = r
		d.CornerRadius = r

		if c == "wide" then
			local Q = math.floor(N * 0.6)
			local d = math.floor(N * 0.2)

			x.AnchorPoint = Vector2.new(0, 0.5)
			x.Position = UDim2.new(0, d, 0.5, 0)
			x.Size = UDim2.fromOffset(Q, Q)

			local r = d + Q + math.floor(N * 0.16)

			S.AnchorPoint = Vector2.new(0, 0.5)
			S.Position = UDim2.new(0, r, 0.5, 0)
			S.Size = UDim2.new(1, -(r + d), 0, math.floor(N * 0.62))
			S.TextXAlignment = Enum.TextXAlignment.Left
			n.MaxTextSize = math.clamp(math.floor(N * 0.3), 7, 26)
		else
			local Q = A and math.floor(a * 0.66) or math.floor(math.min(k * 0.5, N * 0.42))

			x.AnchorPoint = Vector2.new(0.5, A and 0.5 or 0)
			x.Position = A and UDim2.fromScale(0.5, 0.5) or UDim2.new(0.5, 0, 0, math.floor(N * 0.11))
			x.Size = UDim2.fromOffset(Q, Q)
			S.AnchorPoint = Vector2.new(0.5, 1)
			S.Position = UDim2.new(0.5, 0, 1, -math.floor(N * 0.07))
			S.Size = UDim2.new(1, -8.0, 0, math.floor(N * 0.34))
			S.TextXAlignment = Enum.TextXAlignment.Center
			n.MaxTextSize = math.max(7, math.floor(math.min(k * 0.16, N * 0.135)))
		end

		S.Visible = not A

		if c == "stack" then
			L.Position = UDim2.fromScale(0.5, 0.42)
			L.Size = UDim2.fromScale(0.82, 0.44)
		else
			L.Position = UDim2.fromScale(0.5, 0.5)
			L.Size = UDim2.fromScale(c == "wide" and 0.5 or 0.86, c == "wide" and 0.7 or 0.6)
		end

		Z.Position = UDim2.new(0.5, 0, 1, -math.floor(N * 0.1))
		Z.Size = UDim2.new(1, -6.0, 0, math.floor(N * 0.2))
		Z.Visible = (c == "stack")
		g.MaxTextSize = math.max(6, math.floor(a * 0.11))

		local k = ValtPlat.mobile and math.clamp(math.floor(a * 0.4), 22, 32) or math.clamp(math.floor(a * 0.3), 14, 20)

		v.Size = UDim2.fromOffset(k + G, k + G)
		w.Size = UDim2.fromOffset(k, k)

		if X ~= nil and X ~= c and os.clock() >= U then
			V()
			l.resetLabel()
		end
	end

	q.InputBegan:Connect(function(k)
		if f.locked or y or l.dead then
			return
		end

		if k.UserInputType ~= Enum.UserInputType.MouseButton1 and k.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		if s then
			s()
		end

		local N, Q, a = q.Position, k.Position, false

		s = v459(k, function(k)
			if y then
				return
			end

			local X = k - Q

			if not a and (math.abs(X.X) > 3 or math.abs(X.Y) > 3) then
				a = true
			end

			if a then
				q.Position = UDim2.new(N.X.Scale, N.X.Offset + X.X, N.Y.Scale, N.Y.Offset + X.Y)
			end
		end, function()
			s = nil

			if not a or y then
				return
			end

			q.Position = f.clamp(q.Position, M, p)
			H()
		end)
	end)
	v.InputBegan:Connect(function(k)
		if f.locked or y or l.dead then
			return
		end

		if k.UserInputType ~= Enum.UserInputType.MouseButton1 and k.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		if s then
			s()
			s = nil
		end

		y, I = true, os.clock()
		u(true)

		local N, Q, a = M, p, k.Position

		K = v459(k, function(i)
			local k = i - a
			local i = Workspace.CurrentCamera.ViewportSize
			local D = math.max(f.MIN_PX, math.min(C, math.floor(i.X - q.Position.X.Offset)))
			local a = math.max(f.MIN_PX, math.min(f.MAX_PX, math.floor(i.Y - q.Position.Y.Offset)))

			F(math.clamp(math.floor(N + k.X), f.MIN_PX, D), math.clamp(math.floor(Q + k.Y), f.MIN_PX, a))
		end, function()
			K = nil
			y, I = false, os.clock()
			u(false)
			T = M / (O * f.scale)
			W = p / (O * f.scale)
			H()
		end)
	end)
	l.refreshLock = function()
		if l.dead then
			return
		end

		v.Visible = not f.locked

		if f.locked then
			if s then
				s()
				s = nil
			end

			if K then
				K()
				K = nil
				y = false
				u(false)
			end
		end
	end
	l.setLocked = function(i)
		ValtX.btn.applyLock(i)
	end
	l.setActive = function(i)
		if l.dead then
			return
		end

		o = i and true or false
		V()
	end
	l.setFade = function()
		if l.dead then
			return
		end

		t.BackgroundTransparency = R()
	end
	l.setScale = function(i)
		if l.dead then
			return
		end

		i = math.clamp(i, 0.5, 1.6)
		F(_(i, T, C), _(i, W, f.MAX_PX))
		q.Position = f.clamp(q.Position, M, p)
	end
	l.setSizeK = function(i, D)
		if l.dead then
			return
		end

		T = math.clamp(tonumber(i) or 1, 0.2, 6)
		W = math.clamp(tonumber(D) or tonumber(i) or 1, 0.2, 6)
		F(_(f.scale, T, C), _(f.scale, W, f.MAX_PX))
		q.Position = f.clamp(q.Position, M, p)
	end
	l.setPosition = function(i, D)
		q.Position = UDim2.fromOffset(math.floor(i), math.floor(D))
		H()
	end
	l.resetPosition = function()
		f.layout[E] = nil
		T, W = 1, 1
		F(_(f.scale, 1, C), _(f.scale, 1, f.MAX_PX))
		q.Position = f.clamp(J or UDim2.new(0.86, -M / 2, 0.5, 0), M, p)
	end
	l.isCooling = function()
		return os.clock() < U
	end
	l.startCooldown = function(i, D)
		if l.dead then
			return
		end

		i = tonumber(i) or 0

		if i <= 0 then
			return
		end

		if B then
			pcall(task.cancel, B)
			B = nil
		end

		U = os.clock() + i
		Z.Text = string.upper(D or "RELOADING")
		b.Visible = true
		b.BackgroundTransparency = 0.18
		m.Color = Color3.fromRGB(120, 40, 40)
		P(Color3.fromRGB(110, 55, 55))
		S.TextColor3 = Color3.fromRGB(110, 104, 108)
		x.BackgroundTransparency = 0.92
		B = task.spawn(function()
			while true do
				local D = U - os.clock()

				if D <= 0 then
					break
				end

				L.Text = string.format("%.1f", D)
				e.Size = UDim2.new(math.clamp(D / i, 0, 1), 0, 0, 3)
				task.wait(0.05)
			end

			L.Text = ""
			b.Visible = false
			b.BackgroundTransparency = 1
			V()
			l.resetLabel()
			l.flash("READY", Color3.fromRGB(80, 255, 140), 0.7)
			B = nil
		end)
	end
	l.cancelCooldown = function()
		U = 0

		if B then
			pcall(task.cancel, B)
			B = nil
		end

		b.Visible = false
		b.BackgroundTransparency = 1
		V()
		l.resetLabel()
	end
	l.destroy = function()
		l.dead = true

		if B then
			pcall(task.cancel, B)
		end

		if s then
			s()
			s = nil
		end

		if K then
			K()
			K = nil
		end

		if ValtX.btn.objects[E] == l then
			ValtX.btn.objects[E] = nil
		end

		if j then
			j:Destroy()
		end
	end
	F(z, Y)

	local i = f.objects[E]

	if i and i ~= l then
		pcall(i.destroy)
	end

	f.objects[E] = l

	return l
end

ValtX.btn.applyScale = function(p34)
	ValtX.btn.scale = math.clamp(p34, 0.5, 1.6)

	for _, object in pairs(ValtX.btn.objects) do
		pcall(function()
			object.setScale(ValtX.btn.scale)
		end)
	end

	ValtX.btn.save()
end

do
	ValtX.btn.applyFade = function(p35)
		ValtX.btn.fade = math.clamp(tonumber(p35) or 0.3, 0, 0.85)

		for _, object in pairs(ValtX.btn.objects) do
			pcall(function()
				object.setFade()
			end)
		end

		ValtX.btn.save()
	end
end

ValtX.btn.applyLock = function(p36)
	ValtX.btn.locked = p36 and true or false

	for _, object in pairs(ValtX.btn.objects) do
		pcall(function()
			object.refreshLock()
		end)
	end

	ValtX.btn.save()
end

do
	local function resetAll()
		for _, object in pairs(ValtX.btn.objects) do
			pcall(function()
				object.resetPosition()
			end)
		end

		ValtX.btn.layout = {}
		ValtX.btn.save()
	end

	ValtX.btn.resetAll = resetAll
end

local function v558()
	local v559 = v345()

	if u50 then
		if v559 then
			u50.flash("Got it!", Color3.fromRGB(0, 255, 100))

			if v56 then
				v56:Notify({
					Title = "ValtHub",
					Content = "Gun grabbed!",
					Duration = 2,
					Icon = "check"
				})
			end
		else
			u50.flash("No\nGun", Color3.fromRGB(255, 80, 80))

			if v56 then
				v56:Notify({
					Title = "ValtHub",
					Content = "No dropped gun found!",
					Duration = 2,
					Icon = "warning"
				})
			end
		end
	end
end
local function v560(p37)
	if not p37 then
		return
	end

	if p37.Parent == LocalPlayer.Backpack then
		local Humanoid = Character and Character:FindFirstChild("Humanoid")

		if Humanoid then
			Humanoid:EquipTool(p37)
			task.wait(0.3)
		end
	end
end
local function v562()
	local E = (Character and Character:FindFirstChild("Knife")) or (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Knife")) or v343()

	if not E then
		return nil
	end

	v560(E)
	E = Character and Character:FindFirstChild(E.Name)

	if not E then
		return nil
	end

	local i = E:FindFirstChild("Events")
	local D = i and i:FindFirstChild("KnifeStabbed")
	local H = i and i:FindFirstChild("HandleTouched")

	if not D or not H then
		return nil
	end

	return E, D, H
end

local v567, v568, v569, v570, u571, v572, v573, v574, v575, v576

do
	local function v577(E)
		local V, F, J = v562()

		if not V then
			return nil
		end

		local H = LocalPlayer.Character
		local V = H and H:FindFirstChild("HumanoidRootPart")

		if not V then
			return nil
		end

		local H = {}

		for k, k in ipairs(Players:GetPlayers()) do
			if k ~= LocalPlayer and k.Character and (not E or k == E) then
				local E = k.Character:FindFirstChild("Humanoid")
				local i = k.Character:FindFirstChild("HumanoidRootPart")

				if E and i and E.Health > 0 then
					H[#H + 1] = { root = i, was = i.Anchored }
				end
			end
		end

		if #H == 0 then
			return 0
		end

		local E = V.CFrame + V.CFrame.LookVector * 2

		for i, i in ipairs(H) do
			i.root.Anchored = true
			i.root.CFrame = E
		end

		pcall(function()
			F:FireServer()
		end)
		ValtX.sfx.play("kill")
		task.wait(0.1)

		for E, E in ipairs(H) do
			pcall(function()
				J:FireServer(E.root)
			end)
		end

		task.delay(0.4, function()
			for E, E in ipairs(H) do
				if E.root and E.root.Parent then
					E.root.Anchored = E.was
				end
			end
		end)

		return #H
	end

	v567 = function()
		local E = v577()

		if E == nil then
			if v56 then
				v56:Notify({ Title = "ValtHub", Content = "No knife found! You are not the murderer.", Duration = 2, Icon = "warning" })
			end

			if u52 then
				u52.flash("No Knife", Color3.fromRGB(255, 80, 80), 1.5)
			end

			return
		end

		if v56 then
			v56:Notify({ Title = "ValtHub", Content = E > 0 and ("Stabbed " .. E .. " players at once!") or "Nobody alive to stab.", Duration = 2, Icon = E > 0 and "sword" or "warning" })
		end

		if u52 then
			if E > 0 then
				u52.flash("Killed " .. E, Color3.fromRGB(0, 255, 100), 1.5)
			else
				u52.flash("No Kill", Color3.fromRGB(255, 80, 80), 1.5)
			end
		end
	end
	ValtRound.findByRole = function(E, H, V)
		local function F(J)
			return V or ValtRound.alive(J)
		end

		if roleSource ~= "tools" then
			for V, V in ipairs(Players:GetPlayers()) do
				if not (H and V == LocalPlayer) and V.Character and F(V) then
					if ValtRound.roleOf(V) == E then
						return V
					end
				end
			end
		end

		local V = (E == "murderer") and "Knife" or "Gun"

		for E, E in ipairs(Players:GetPlayers()) do
			if not (H and E == LocalPlayer) and F(E) then
				local i = E:FindFirstChildOfClass("Backpack")

				if i and i:FindFirstChild(V) then
					return E
				end

				if E.Character and E.Character:FindFirstChild(V) then
					return E
				end
			end
		end

		return nil
	end
	ValtRound.amShooter = function()
		if roleSource ~= "tools" then
			local v603 = ValtRound.rawRole(LocalPlayer)

			if v603 == "Sheriff" or v603 == "Hero" then
				return true
			end
		end

		local Character2 = LocalPlayer.Character

		if Character2 and Character2:FindFirstChild("Gun") then
			return true
		end

		local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")

		if Backpack and Backpack:FindFirstChild("Gun") then
			return true
		end

		return false
	end
	v568 = function()
		return ValtRound.findByRole("murderer", true)
	end
	v569 = function()
		return ValtRound.findByRole("sheriff", true)
	end
	ValtX.aim = {}
	ValtSafe("L2512", function()
		local E = ValtX.aim
		local _, _ = 25, 2

		E.INTERP = 0.05

		local F = setmetatable({}, { __mode = "k" })
		local J

		function E.ping()
			if J then
				return J
			end

			local k = 0

			pcall(function()
				k = LocalPlayer:GetNetworkPing()
			end)

			return k > 0 and k or 0.05
		end
		function E.velocity(k)
			local P = F[k]

			if P and P.vel then
				return P.vel
			end

			local P = k and k.Character
			local k = P and P:FindFirstChild("HumanoidRootPart")

			return k and k.AssemblyLinearVelocity or Vector3.zero
		end
		function E.lead(k)
			local P = E.ping() * 2 + E.INTERP

			return math.clamp(P * (k or 1), 0.04, 0.45)
		end

		local function E(k)
			local P = k.Magnitude

			if P > 60 then
				return k * (60 / P)
			end

			return k
		end

		local k

		k = RunService.Heartbeat:Connect(function(i)
			if ValtState.gen ~= gen then
				k:Disconnect()

				return
			end

			if i <= 0 then
				return
			end

			local H = os.clock()
			local P, f = pcall(LocalPlayer.GetNetworkPing, LocalPlayer)

			if not P or type(f) ~= "number" then
				f = 0
			end

			if f > 0 then
				J = J and (J + (f - J) * (1 - math.exp(-2.0 * i))) or f
			end

			local J = 1 - math.exp(-25.0 * i)

			for i, i in ipairs(Players:GetPlayers()) do
				if i ~= LocalPlayer then
					local D = i.Character
					local V = D and D:FindFirstChild("HumanoidRootPart")
					local D = F[i]

					if not V then
						F[i] = nil
					elseif not D or D.hrp ~= V then
						F[i] = { hrp = V, pos = V.Position, at = H, vel = E(V.AssemblyLinearVelocity) }
					else
						local i = V.AssemblyLinearVelocity
						local F = V.Position - D.pos
						local P = H - D.at

						if F.Magnitude > 1e-3 and P > 0 then
							i = (i + F / P) * 0.5
							D.pos, D.at = V.Position, H
						end

						D.vel = D.vel:Lerp(E(i), J)
					end
				end
			end
		end)
		ValtConns.aimTrack = k
	end)
	ValtX.aim.predict = function(E, H, V)
		local F = E and E.Character
		local J = F and F:FindFirstChild("HumanoidRootPart")
		local k = F and F:FindFirstChildOfClass("Humanoid")

		if not (J and k) then
			return H
		end

		V = V or ValtX.aim.lead()

		local P = ValtX.aim.velocity(E)
		local E = k:GetState()
		local k = (E == Enum.HumanoidStateType.Freefall or E == Enum.HumanoidStateType.Jumping)
		local E = H.Y + (k and P.Y * V or 0)

		if k then
			E = E - 0.5 * Workspace.Gravity * V * V

			local k = ValtX.aim.floorParams

			if not k then
				k = RaycastParams.new()
				k.FilterType = Enum.RaycastFilterType.Exclude
				ValtX.aim.floorParams = k
			end

			k.FilterDescendantsInstances = { F, LocalPlayer.Character }

			local i = Workspace:Raycast(J.Position, Vector3.new(0, -60.0, 0), k)

			if i then
				local D = i.Position.Y + 2.8 + (H.Y - J.Position.Y)

				E = math.max(E, D)
			end
		end

		return Vector3.new(H.X + P.X * V, E, H.Z + P.Z * V)
	end
	ValtSafe("L2632", function()
		local E = ValtX.aim
		local V = game:GetService("CollectionService")

		E.knifeSpeed = 96

		local F, J = {}, -1.0

		local function k()
			local P = os.clock()

			if P - J > 2 then
				J = P
				F = V:GetTagged("WeaponPassthrough")
			end

			return F
		end

		local F = RaycastParams.new()

		F.FilterType = Enum.RaycastFilterType.Exclude
		F.IgnoreWater = true

		function E.blocked(J, P, f)
			local S = {}

			if LocalPlayer.Character then
				S[#S + 1] = LocalPlayer.Character
			end

			if f then
				S[#S + 1] = f
			end

			for f, f in ipairs(k()) do
				S[#S + 1] = f
			end

			F.FilterDescendantsInstances = S

			local k = P - J

			for P = 1, 8 do
				local P = Workspace:Raycast(J, k, F)

				if not P then
					return nil
				end

				if P.Instance.Transparency ~= 1 then
					return P
				end

				S[#S + 1] = P.Instance
				F.FilterDescendantsInstances = S
			end

			return nil
		end
		function E.intercept(H, F, J, k)
			local P = F - H
			local H = J:Dot(J) - k * k
			local F = 2 * J:Dot(P)
			local J = P:Dot(P)

			if math.abs(H) < 1e-6 then
				if math.abs(F) < 1e-6 then
					return nil
				end

				local k = -J / F

				return k > 0 and k or nil
			end

			local k = F * F - 4 * H * J

			if k < 0 then
				return nil
			end

			local J = math.sqrt(k)
			local k, P = (-F - J) / (2 * H), (-F + J) / (2 * H)
			local H

			if k > 0 then
				H = k
			end

			if P > 0 and (not H or P < H) then
				H = P
			end

			return H
		end
		function E.heldKnife()
			local H = LocalPlayer.Character
			local F = H and H:FindFirstChild("Knife")

			return (F and F:IsA("Tool")) and F or nil
		end
		function E.knifeOrigin()
			local H = E.heldKnife()
			local F = H and H:FindFirstChild("Handle")

			return F and F.Position or nil
		end
		function E.gunOrigin()
			local H = LocalPlayer.Character
			local F = H and H:FindFirstChild("HumanoidRootPart")
			local H = F and F:FindFirstChild("GunRaycastAttachment")

			if H then
				return H.WorldCFrame.Position, H
			end

			return F and F.Position or nil, nil
		end

		local H = { "UpperTorso", "HumanoidRootPart", "Torso", "Head", "LowerTorso" }

		function E.shotPoint(F, J, k)
			k = k or {}

			local P = F and F.Character

			if not (P and J) then
				return nil, "no target"
			end

			local f, S

			for N, N in ipairs(k.order or H) do
				local H = P:FindFirstChild(N)

				if H and H:IsA("BasePart") then
					f = f or H

					if not E.blocked(J, H.Position, P) then
						S = H

						break
					end
				end
			end

			if not S then
				if k.wallCheck or not f then
					return nil, "behind cover"
				end

				S = f
			end

			local H = S.Position
			local f = E.lead(k.scale or 1)

			if k.knife then
				local N = k.speed or E.knifeSpeed
				local k = E.velocity(F)
				local j = Vector3.new(k.X, 0, k.Z)
				local k = H + j * f
				local O = E.intercept(J, k, j, N) or (k - J).Magnitude / N

				f = math.min(f + O, 2)
			end

			local k = E.predict(F, H, f)

			if (k - H).Magnitude > 0.05 and E.blocked(J, k, P) then
				local F = H:Lerp(k, 0.5)

				k = E.blocked(J, F, P) and H or F
			end

			return k, S
		end

		ValtConns.knifeSpeed = V:GetInstanceAddedSignal("ThrowingKnife"):Connect(function(H)
			if ValtState.gen ~= gen then
				return
			end

			task.spawn(function()
				local D = H:WaitForChild("HandleLink", 2)
				local V = D and D.Value
				local D = LocalPlayer.Character
				local i = tonumber(H:GetAttribute("ThrowSpeed"))

				if i and i > 10 and V and D and V:IsDescendantOf(D) then
					E.knifeSpeed = i
				end
			end)
		end)
	end)

	local function v691(p38, p39)
		local v692 = p39 or 2.8
		local Character2 = p38.Character

		if not Character2 then
			return nil
		end

		local HumanoidRootPart2 = Character2:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character2:FindFirstChildOfClass("Humanoid")

		if HumanoidRootPart2 and Humanoid then
			return ValtX.aim.predict(p38, HumanoidRootPart2.Position)
		end

		return nil
	end

	ValtX.trace.draw = function(E, H, V)
		local F = ValtX.trace

		if not F.on then
			return
		end

		if typeof(E) ~= "Vector3" or typeof(H) ~= "Vector3" then
			return
		end

		local J = (H - E).Magnitude

		if J < 0.5 or J ~= J then
			return
		end

		local k = Workspace:FindFirstChild("ValtTracers")

		if not k then
			k = Instance.new("Folder")
			k.Name = "ValtTracers"
			k.Parent = Workspace
		end

		local i = E:Lerp(H, 0.5)
		local E = Instance.new("Part")

		E.Name = "Tracer"
		E.Anchored = true
		E.CanCollide = false
		E.CanQuery = false
		E.CanTouch = false
		E.CastShadow = false
		E.Material = Enum.Material.Neon
		E.Color = F.color
		E.Transparency = 0.15

		if F.style == "Laser" then
			E.Shape = Enum.PartType.Cylinder
			E.Size = Vector3.new(J, F.thickness, F.thickness)
			E.CFrame = CFrame.lookAt(i, H) * CFrame.Angles(0, math.rad(90), 0)
		else
			E.Shape = Enum.PartType.Block
			E.Size = Vector3.new(F.thickness, F.thickness, J)
			E.CFrame = CFrame.lookAt(i, H)
		end

		E.Parent = k

		if F.style == "Beam" then
			local i = Instance.new("PointLight", E)

			i.Color = F.color
			i.Range = 6
			i.Brightness = 1.4
		end

		if F.impact then
			local i = Instance.new("Part")

			i.Name = "Impact"
			i.Shape = Enum.PartType.Ball
			i.Anchored = true
			i.CanCollide = false
			i.CanQuery = false
			i.CanTouch = false
			i.CastShadow = false
			i.Material = Enum.Material.Neon
			i.Color = V and Color3.fromRGB(255, 70, 70) or F.color
			i.Size = Vector3.new(1.1, 1.1, 1.1)
			i.Transparency = 0.1
			i.CFrame = CFrame.new(H)
			i.Parent = k

			local H = Instance.new("BillboardGui", i)

			H.Size = UDim2.new(0, 90, 0, 20)
			H.AlwaysOnTop = true
			H.StudsOffset = Vector3.new(0, 1.6, 0)

			local V = Instance.new("TextLabel", H)

			V.Size = UDim2.new(1, 0, 1, 0)
			V.BackgroundTransparency = 1
			V.Font = Enum.Font.GothamBold
			V.TextSize = 13
			V.TextColor3 = i.Color
			V.TextStrokeTransparency = 0.35
			V.Text = string.format("%.0f studs", J)
			TweenService:Create(i, TweenInfo.new(F.life, Enum.EasingStyle.Quad), { Transparency = 1, Size = Vector3.new(3.2, 3.2, 3.2) }):Play()
			game:GetService("Debris"):AddItem(i, F.life + 0.1)
		end

		TweenService:Create(E, TweenInfo.new(F.life, Enum.EasingStyle.Quad), { Transparency = 1 }):Play()
		game:GetService("Debris"):AddItem(E, F.life + 0.1)
	end
	ValtX.sfx.FALLBACK = {
		shoot = "rbxassetid://106018135",
		kill = "rbxassetid://142247768"
	}
	ValtX.sfx.BY_SKIN = {
		Harvester = "rbxassetid://7808472682",
		Icepiercer = "rbxassetid://7808472682",
		Raygun = "rbxassetid://92066070356304",
		RaygunChroma = "rbxassetid://92066070356304",
		Snowcannon = "rbxassetid://136161856273464",
		SnowcannonChroma = "rbxassetid://136161856273464",
		Gingerscope = "rbxassetid://74240492893421"
	}
	ValtX.sfx.PACK = {
		{
			name = "Weapon default",
			id = ""
		},
		{
			name = "Classic Gun",
			id = "rbxassetid://10209257"
		},
		{
			name = "Laser",
			id = "rbxassetid://130113322"
		},
		{
			name = "Vine Boom",
			id = "rbxassetid://6534947588"
		},
		{
			name = "Uhh",
			id = "rbxasset://sounds/uuhhh.mp3"
		},
		{
			name = "Squeak",
			id = "rbxassetid://4966068844"
		},
		{
			name = "Coin",
			id = "rbxassetid://607665037"
		},
		{
			name = "Bell",
			id = "rbxassetid://12221967"
		},
		{
			name = "Discord Ping",
			id = "rbxassetid://4590662766"
		},
		{
			name = "Ping",
			id = "rbxasset://sounds/electronicpingshort.wav"
		},
		{
			name = "Click",
			id = "rbxasset://sounds/clickfast.wav"
		},
		{
			name = "Switch",
			id = "rbxasset://sounds/switch.wav"
		},
		{
			name = "Bass Drop",
			id = "rbxasset://sounds/bass.mp3"
		},
		{
			name = "Splash",
			id = "rbxasset://sounds/impact_water.mp3"
		},
		{
			name = "Victory",
			id = "rbxasset://sounds/victory.wav"
		},
		{
			name = "Boing",
			id = "rbxassetid://138186576"
		},
		{
			name = "Explosion",
			id = "rbxassetid://12222084"
		},
		{
			name = "Metal Hit",
			id = "rbxassetid://12222030"
		}
	}
	ValtX.sfx.packShoot = ""
	ValtX.sfx.packKill = ""
	ValtX.sfx.packId = function(p40)
		for _, v in ipairs(ValtX.sfx.PACK) do
			if v.name == p40 then
				return v.id
			end
		end

		return ""
	end
	ValtX.sfx.packNames = function()
		local t13 = {}

		for i, v in ipairs(ValtX.sfx.PACK) do
			t13[i] = v.name
		end

		return t13
	end
	ValtX.sfx.equippedKey = function(p41)
		local v710 = ValtX.mod.profileData()

		if type(v710) ~= "table" then
			return nil
		end

		local u711

		pcall(function()
			u711 = v710.Weapons.Equipped[p41]
		end)

		return u711
	end
	ValtX.sfx.tool = function(p42)
		local v712, v713, v714 = ipairs(game:GetService("CollectionService"):GetTagged(p42))
		local v715 = geniter(v712, v713, v714)
		local v716 = table.pack(v715())

		if not v716[1] then
			return nil
		end

		local v717 = v716[3]

		while not v717:IsDescendantOf(LocalPlayer) and (not LocalPlayer.Character or not v717:IsDescendantOf(LocalPlayer.Character)) do
			local v718 = table.pack(v715())

			if not v718[1] then
				return nil
			end

			v717 = v718[3]
		end

		return v717
	end
	ValtX.sfx.fromTool = function(E,i)if not E then return nil;end;local D=E:FindFirstChild("Ha\110\100\z\108\101")or E;local E={};for H,H in ipairs(D:GetDescendants())do if H:IsA("So\z und")and H.SoundId and H.SoundId~=''and not H.SoundId:lower():match("^r\98\120as\115e\z  t\z \u{003A}\47/")then E[H.Name]=E[H.Name]or H.SoundId;end;end;for D,D in ipairs(i)do if E[D]then return E[D];end;end;return nil;end
	ValtX.sfx.fromDisplay = function(E, D)
		local H = LocalPlayer.Character

		if not H then
			return nil
		end

		local i = H:FindFirstChild("DisplayRef" .. E)
		local E = i and i.Value

		if not E or not E.Parent then
			return nil
		end

		for i, i in ipairs(D) do
			for D, D in ipairs(E.Parent:GetDescendants()) do
				if D:IsA("Sound") and D.Name == i and D.SoundId and D.SoundId ~= "" and not D.SoundId:lower():match("^rbxasset://") then
					return D.SoundId
				end
			end
		end

		return nil
	end
	ValtX.sfx.resolve = function(E)local i=ValtX.sfx;local D=(E=="\kill")and i.customKill or i.customShoot;if D and D~=""then return D;end;local D=(E=='kil\108')and i.packKill or i.packShoot;if D and D~=''then return D;end;if E~="\z \ki\108\108"then local D=i.equippedKey('\u{47}\zun');if D and i.BY_SKIN[D]then return i.BY_SKIN[D];end;end;if E=='ki\z ll'then return i.fromTool(i.tool("\u{57}\101a\u{070}\111n_Kn\105\102\101"),{'\65ltS\111u\u{006E}\z \u{0064}','Kil\z  l','S\x74\zab'})or i.fromDisplay('K\x6Ei\z\102e',{"\u{041}lt\u{53}\x6F\x75nd","K\ill",'\83tab'})or i.fromTool(i.tool("\87\101a\z p\111\110_Gun"),{"A\108\z  tSo\z  und","Ki\108\l"})or i.FALLBACK.kill;end;return i.fromTool(i.tool('W\101\97\u{070}on\x5FGun'),{"\65lt\z So\u{0075}nd",'S\x68o\x6Ft',"G\x75n\115h\111\u{74}",'\u{046}ire'})or i.fromDisplay("Gu\u{006E}",{"AltS\u{6F}und","S\104\x6Fo\116",'\z G\z u\110s\z  h\z \x6Ft',"\F\x69re"})or i.fromTool(i.tool('Wea\u{70}\u{06F}\110\95\75\z  ni\102\z\e'),{'\z \u{0041}ltSou\110d'})or i.FALLBACK.shoot;end
	ValtX.sfx.play = function(E)local i=ValtX.sfx;if not i.on then return;end;local D=os.clock();if D-i.lastAt<0.08 then return;end;i.lastAt=D;local D=i.resolve(E);if not D or D==''then return;end;local E=Instance.new('\u{53}\u{006F}\zu\z  nd');E.Name='\u{056}alt\x53F\88';E.SoundId=D;E.Volume=math.clamp(i.volume,0,1);E.PlayOnRemove=false;E.Parent=game:GetService("S\x6F\117\x6EdSe\x72v\z  i\x63e");E:Play();game:GetService("D\101bri\s"):AddItem(E,6);end
	ValtX.sfx.SKIN_SLOTS = {
		Shoot = true,
		Gunshot = true,
		AltSound = true
	}
	ValtX.sfx.swapped = setmetatable({}, {
		__mode = "k"
	})
	ValtX.sfx.applySkin = function()local E=ValtX.sfx;local i=E.BY_SKIN[E.equippedKey('G\117\z \110')or''];local D=E.tool('\x57\z  e\x61p\111\u{06E}\95Gu\110');if not D then return;end;for H,H in ipairs(D:GetDescendants())do if H:IsA('\zS\o\117n\z d')and E.SKIN_SLOTS[H.Name]then local D=E.swapped[H];if i then if D==nil and H.SoundId~=''then E.swapped[H]=H.SoundId;D=H.SoundId;end;if D~=nil and H.SoundId~=i then H.SoundId=i;end;elseif D~=nil then H.SoundId=D;E.swapped[H]=nil;end;end;end;end
	ValtX.sfx.muted = {}
	ValtX.sfx.GAME_SHOT = {
		AltSound = true,
		Shoot = true,
		Gunshot = true,
		Fire = true,
		Shot = true
	}
	ValtX.sfx.silenceGame = function()
		local E = ValtX.sfx

		if not E.on then
			for D, H in pairs(E.muted) do
				if D and D.Parent then
					pcall(function()
						D.Volume = H
					end)
				end

				E.muted[D] = nil
			end

			return
		end

		for D in pairs(E.muted) do
			if not D.Parent then
				E.muted[D] = nil
			end
		end

		local function D(H)
			if not H then
				return
			end

			for V, V in ipairs(H:GetDescendants()) do
				if V:IsA("Sound") and E.GAME_SHOT[V.Name] then
					if E.muted[V] == nil then
						E.muted[V] = V.Volume
					end

					if V.Volume ~= 0 then
						pcall(function()
							V.Volume = 0
						end)
					end

					if V.IsPlaying then
						pcall(function()
							V:Stop()
						end)
					end
				end
			end
		end

		D(E.tool("Weapon_Gun"))
		D(E.tool("Weapon_Knife"))

		local E = LocalPlayer.Character

		if E then
			for i, i in ipairs({ "Gun", "Knife" }) do
				local H = E:FindFirstChild("DisplayRef" .. i)

				D(H and H.Value)
			end
		end
	end
	ValtX.trace.clear = function()
		local ValtTracers = Workspace:FindFirstChild("ValtTracers")

		if ValtTracers then
			ValtTracers:Destroy()
		end
	end
	ValtX.gun.remaining = function()
		return math.max(0, ValtX.gun.lastShot + ValtX.gun.cooldown - os.clock())
	end
	ensureGunInHand = function(E, H)
		H = H or 1.2

		local V = os.clock() + H

		local function H()
			return E:FindFirstChild("Gun")
		end
		local function F()
			local J = LocalPlayer:FindFirstChildOfClass("Backpack")

			return J and J:FindFirstChild("Gun")
		end

		if H() then
			return H()
		end

		local D = E:FindFirstChildOfClass("Humanoid")

		if F() and D then
			pcall(function()
				D:EquipTool(F())
			end)

			repeat
				task.wait(0.05)

				if H() then
					return H()
				end
			until os.clock() > V
		end

		if not H() then
			pcall(v345)

			repeat
				task.wait(0.05)

				if H() then
					return H()
				end

				local E = F()

				if E and D then
					pcall(function()
						D:EquipTool(E)
					end)
					task.wait(0.1)

					if H() then
						return H()
					end
				end
			until os.clock() > V
		end

		return H()
	end
	v570 = function()
		local E = ValtX.gun.remaining()

		if ValtX.gun.blockDuringCd and E > 0 then
			if u51 then
				u51.startCooldown(E, "Reloading")
			end

			if v56 then
				v56:Notify({ Title = "ValtHub", Content = string.format("Gun reloading - %.1fs left", E), Duration = 1.2, Icon = "clock" })
			end

			return
		end

		if not ValtRound.amShooter() then
			if u51 then
				u51.flash("Not Sheriff", Color3.fromRGB(255, 80, 80))
			end

			if v56 then
				v56:Notify({ Title = "ValtHub", Content = "You are not the sheriff!", Duration = 2, Icon = "warning" })
			end

			return
		end

		local E = v568()

		if not E then
			if u51 then
				u51.flash("No Target", Color3.fromRGB(255, 80, 80))
			end

			if v56 then
				v56:Notify({ Title = "ValtHub", Content = "No murderer found!", Duration = 2, Icon = "warning" })
			end

			return
		end

		local i = LocalPlayer.Character

		if not i then
			if u51 then
				u51.flash("No Char", Color3.fromRGB(255, 80, 80))
			end

			return
		end

		local V = ensureGunInHand(i, 1.2)

		if not V then
			if u51 then
				u51.flash("No Gun", Color3.fromRGB(255, 80, 80))
			end

			if v56 then
				v56:Notify({ Title = "ValtHub", Content = "Could not get a gun in hand.", Duration = 2, Icon = "warning" })
			end

			return
		end

		local i = E.Character

		if not i then
			if u51 then
				u51.flash("No Char", Color3.fromRGB(255, 80, 80))
			end

			return
		end

		local F = i:FindFirstChild("HumanoidRootPart")

		if not F then
			if u51 then
				u51.flash("No HRP", Color3.fromRGB(255, 80, 80))
			end

			return
		end

		local J = V:FindFirstChild("Shoot")
		local V, k = ValtX.aim.gunOrigin()

		if not (J and J:IsA("RemoteEvent") and V) then
			if u51 then
				u51.flash("No Remote", Color3.fromRGB(255, 80, 80))
			end

			if v56 then
				v56:Notify({ Title = "ValtHub", Content = "This gun has no Shoot remote - MM2 may have changed.", Duration = 2, Icon = "warning" })
			end

			return
		end

		local P = ValtX.aim.shotPoint(E, V) or F.Position

		local function E()
			ValtX.gun.lastShot = os.clock()
			ValtX.sfx.play("shoot")
			pcall(function()
				local F = i and i:FindFirstChildOfClass("Humanoid")

				if not F or F.Health <= 0 then
					return
				end

				local f

				f = F.Died:Connect(function()
					if f then
						f:Disconnect()
						f = nil
					end

					ValtX.sfx.play("kill")
				end)
				task.delay(2, function()
					if f then
						f:Disconnect()
						f = nil
					end
				end)
			end)

			if u51 then
				u51.startCooldown(ValtX.gun.cooldown, "Reloading")
			end

			pcall(function()
				local F = not ValtX.aim.blocked(V, P, i)

				ValtX.trace.draw(V, P, F)
			end)

			if v56 then
				v56:Notify({ Title = "ValtHub", Content = "Shot fired at murderer!", Duration = 2, Icon = "check" })
			end
		end

		local i = pcall(function()
			local F = k and k.WorldCFrame or CFrame.new(V)

			J:FireServer(F, CFrame.new(P))
		end)

		if i then
			E()
		else
			if u51 then
				u51.flash("Failed", Color3.fromRGB(255, 80, 80))
			end

			if v56 then
				v56:Notify({ Title = "ValtHub", Content = "Failed to shoot!", Duration = 2, Icon = "warning" })
			end
		end
	end
	u571 = false

	local function v780(E)
		if not E or not E.Character then
			return
		end

		local H = LocalPlayer.Character
		local D = H and (H:FindFirstChildOfClass("Humanoid") or H:FindFirstChild("Humanoid"))
		local V = H and (H:FindFirstChild("HumanoidRootPart") or H.PrimaryPart)
		local F = E and E.Character
		local J
		local k
		local P
		local f
		local S

		if F and F:FindFirstChildOfClass("Humanoid") then
			J = F:FindFirstChildOfClass("Humanoid")
		end

		if J then
			k = F:FindFirstChild("HumanoidRootPart") or F.PrimaryPart or J.RootPart
		end

		if F and F:FindFirstChild("Head") then
			P = F.Head
		end

		if F and F:FindFirstChildOfClass("Accessory") then
			f = F:FindFirstChildOfClass("Accessory")
		end

		if f and f:FindFirstChild("Handle") then
			S = f.Handle
		end

		if H and D and V then
			if V.Velocity.Magnitude < 50 then
				ValtState.flingOldPos = V.CFrame
			end

			local N = workspace.CurrentCamera

			if P then
				N.CameraSubject = P
			elseif not P and S then
				N.CameraSubject = S
			elseif J and k then
				N.CameraSubject = J
			end

			if not (F and F:FindFirstChildWhichIsA("BasePart")) then
				return
			end

			local function N(j, O, R)
				V.CFrame = CFrame.new(j.Position) * O * R
				pcall(function()
					if H and H.PrimaryPart then
						H:SetPrimaryPartCFrame(CFrame.new(j.Position) * O * R)
					end
				end)
				V.Velocity = Vector3.new(9e7, 9.0E8, 9e7)
				V.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
			end
			local function j(O)
				local R = tick()
				local C = 0

				repeat
					if V and J then
						if O.Velocity.Magnitude < 50 then
							C = C + 100
							N(O, CFrame.new(0, 1.5, 0) + J.MoveDirection * O.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(C), 0, 0))
							task.wait()
							N(O, CFrame.new(0, -1.5, 0) + J.MoveDirection * O.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(C), 0, 0))
							task.wait()
							N(O, CFrame.new(2.25, 1.5, -2.25) + J.MoveDirection * O.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(C), 0, 0))
							task.wait()
							N(O, CFrame.new(-2.25, -1.5, 2.25) + J.MoveDirection * O.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(C), 0, 0))
							task.wait()
							N(O, CFrame.new(0, 1.5, 0) + J.MoveDirection, CFrame.Angles(math.rad(C), 0, 0))
							task.wait()
							N(O, CFrame.new(0, -1.5, 0) + J.MoveDirection, CFrame.Angles(math.rad(C), 0, 0))
							task.wait()
						else
							N(O, CFrame.new(0, 1.5, J.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
							task.wait()
							N(O, CFrame.new(0, -1.5, -J.WalkSpeed), CFrame.Angles(0, 0, 0))
							task.wait()
							N(O, CFrame.new(0, 1.5, J.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
							task.wait()
							N(O, CFrame.new(0, 1.5, k and k.Velocity.Magnitude / 1.25 or 0), CFrame.Angles(math.rad(90), 0, 0))
							task.wait()
							N(O, CFrame.new(0, -1.5, -(k and k.Velocity.Magnitude / 1.25 or 0)), CFrame.Angles(0, 0, 0))
							task.wait()
							N(O, CFrame.new(0, 1.5, k and k.Velocity.Magnitude / 1.25 or 0), CFrame.Angles(math.rad(90), 0, 0))
							task.wait()
							N(O, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
							task.wait()
							N(O, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
							task.wait()
							N(O, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90.0), 0, 0))
							task.wait()
							N(O, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
							task.wait()
						end
					else
						break
					end
				until O.Velocity.Magnitude > 500 or O.Parent ~= E.Character or E.Parent ~= Players or E.Character ~= F or (J and J.Sit) or (D and D.Health <= 0) or tick() > R + 2
			end

			if not ValtState.fpdh then
				ValtState.fpdh = workspace.FallenPartsDestroyHeight
			end

			workspace.FallenPartsDestroyHeight = 0 / 0

			local E = Instance.new("BodyVelocity")

			E.Name = "EpixVel"
			E.Parent = V
			E.Velocity = Vector3.new(9e8, 9e8, 9e8)
			E.MaxForce = Vector3.new(1 / 0, 1 / 0, 1 / 0)
			D:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

			if k and P then
				if (k.CFrame.p - P.CFrame.p).Magnitude > 5 then
					j(P)
				else
					j(k)
				end
			elseif k and not P then
				j(k)
			elseif not k and P then
				j(P)
			elseif not k and not P and f and S then
				j(S)
			end

			if E and E.Parent then
				E:Destroy()
			end

			D:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
			workspace.CurrentCamera.CameraSubject = D

			repeat
				if ValtState.flingOldPos then
					V.CFrame = ValtState.flingOldPos * CFrame.new(0, .5, 0)
					pcall(function()
						if H and H.PrimaryPart then
							H:SetPrimaryPartCFrame(ValtState.flingOldPos * CFrame.new(0, .5, 0))
						end
					end)
				end

				D:ChangeState(Enum.HumanoidStateType.GettingUp)

				for E, E in ipairs(H:GetChildren()) do
					if E:IsA("BasePart") then
						E.Velocity, E.RotVelocity = Vector3.new(), Vector3.new()
					end
				end

				task.wait()
			until not ValtState.flingOldPos or (V.Position - ValtState.flingOldPos.p).Magnitude < 25

			if ValtState.fpdh then
				workspace.FallenPartsDestroyHeight = ValtState.fpdh
			end
		end
	end

	v572 = function(p43)
		u571 = true

		local ok, result = pcall(v780, p43)

		u571 = false

		if not ok then
			warn("[Valt/Fling] " .. tostring(result))
		end
	end

	local function v800()
		for E, E in ipairs(workspace:GetChildren()) do
			if E:FindFirstChild("CoinContainer") and E:FindFirstChild("Spawns") then
				return E
			end

			if E:FindFirstChild("CoinAreas") then
				return E
			end
		end

		for E, E in ipairs(workspace:GetChildren()) do
			local D = E:FindFirstChild("Spawns")

			if D and not E.Name:lower():find("lobby") and not E:FindFirstChildWhichIsA("Humanoid") and not Players:GetPlayerFromCharacter(E) then
				for i, i in ipairs(D:GetChildren()) do
					if i:IsA("BasePart") then
						return E
					end
				end
			end
		end

		return nil
	end
	local function v808()local E=nil;for i,i in ipairs(workspace:GetChildren())do if i.Name:lower():find('lobby')then E=E or i;if i:FindFirstChild('S\pa\wns')or i:FindFirstChild('L\o\98\z \98\u{0079}\83pa\w\110s')then return i;end;end;end;if E then return E;end;for E,E in ipairs(workspace:GetChildren())do if E:FindFirstChild("\76\zob\u{062}\y")and E.Lobby:IsA('Ba\115e\u{0050}a\x72t')then return E.Lobby;end;if E:FindFirstChild("L\obb\u{0079}Spawn\s")then return E;end;end;return nil;end

	v573 = function(E)
		if not E or not E.Character then
			return
		end

		local H = LocalPlayer.Character

		if not H then
			return
		end

		local i = H:FindFirstChild("HumanoidRootPart")

		if not i then
			return
		end

		local H = E.Character:FindFirstChild("HumanoidRootPart")

		if not H then
			return
		end

		i.CFrame = H.CFrame * CFrame.new(0, 3, 0)

		if v56 then
			v56:Notify({ Title = "ValtHub", Content = "Teleported to " .. E.Name, Duration = 2, Icon = "check" })
		end
	end
	v574 = function()
		local E = LocalPlayer.Character

		if not E then
			if v56 then
				v56:Notify({ Title = "ValtHub", Content = "Character not found!", Duration = 2, Icon = "warning" })
			end

			return
		end

		local H = v800()

		if not H then
			if v56 then
				v56:Notify({ Title = "ValtHub", Content = "Map not found! Trying to find spawn...", Duration = 2, Icon = "warning" })
			end

			for D, D in ipairs(workspace:GetDescendants()) do
				if D:IsA("BasePart") and (D.Name:lower():find("spawn") or D.Name:lower():find("start")) then
					local V = E:FindFirstChild("HumanoidRootPart")

					if V then
						V.CFrame = D.CFrame * CFrame.new(0, 3, 0)

						if v56 then
							v56:Notify({ Title = "ValtHub", Content = "Teleported to spawn point!", Duration = 2, Icon = "check" })
						end

						return
					end
				end
			end

			return
		end

		local D = E:FindFirstChild("HumanoidRootPart")

		if not D then
			if v56 then
				v56:Notify({ Title = "ValtHub", Content = "HRP not found!", Duration = 2, Icon = "warning" })
			end

			return
		end

		local E = H:FindFirstChild("Spawns")

		if not E then
			if v56 then
				v56:Notify({ Title = "ValtHub", Content = "Spawns not found!", Duration = 2, Icon = "warning" })
			end

			return
		end

		local H = {}

		for V, V in ipairs(E:GetChildren()) do
			if V:IsA("BasePart") then
				table.insert(H, V)
			end
		end

		if #H == 0 then
			if v56 then
				v56:Notify({ Title = "ValtHub", Content = "No spawn parts found!", Duration = 2, Icon = "warning" })
			end

			return
		end

		local E = H[math.random(1, #H)]

		if E and E:IsA("BasePart") then
			D.CFrame = E.CFrame * CFrame.new(0, 3, 0)

			if v56 then
				v56:Notify({ Title = "ValtHub", Content = "Teleported to map!", Duration = 2, Icon = "check" })
			end
		end
	end
	v575 = function()
		local E = LocalPlayer.Character

		if not E then
			if v56 then
				v56:Notify({ Title = "ValtHub", Content = "Character not found!", Duration = 2, Icon = "warning" })
			end

			return
		end

		local D = v808()

		if not D then
			if v56 then
				v56:Notify({ Title = "ValtHub", Content = "Lobby not found!", Duration = 2, Icon = "warning" })
			end

			return
		end

		local i = E:FindFirstChild("HumanoidRootPart")

		if not i then
			if v56 then
				v56:Notify({ Title = "ValtHub", Content = "HRP not found!", Duration = 2, Icon = "warning" })
			end

			return
		end

		local E = D:FindFirstChild("Spawns") or D:FindFirstChild("LobbySpawns")

		if not E then
			if v56 then
				v56:Notify({ Title = "ValtHub", Content = "Spawns not found in lobby!", Duration = 2, Icon = "warning" })
			end

			return
		end

		local D = {}

		for V, V in ipairs(E:GetChildren()) do
			if V:IsA("BasePart") then
				table.insert(D, V)
			end
		end

		if #D == 0 then
			if v56 then
				v56:Notify({ Title = "ValtHub", Content = "No spawn parts found!", Duration = 2, Icon = "warning" })
			end

			return
		end

		local E = D[math.random(1, #D)]

		if E and E:IsA("BasePart") then
			i.CFrame = E.CFrame * CFrame.new(0, 3, 0)

			if v56 then
				v56:Notify({ Title = "ValtHub", Content = "Teleported to lobby!", Duration = 2, Icon = "check" })
			end
		end
	end
	ValtConns.worldAdded = Workspace.DescendantAdded:Connect(function(descendant)
		if ValtState.gen ~= gen then
			ValtConns.worldAdded:Disconnect()

			return
		end

		if descendant.Name == "GunDrop" then
			if descendant:IsA("BasePart") then
				ValtESP.drops[descendant] = true
			end

			if u36 then
				v280(descendant)
			end

			if u37 then
				task.spawn(function()
					task.wait(1)
					v345()
				end)
			end
		end

		if t1.trap and v73(descendant) then
			task.wait(0.1)
			v74(descendant)
		end
	end)
	ValtConns.worldGone = Workspace.DescendantRemoving:Connect(function(descendant)
		if ValtState.gen ~= gen then
			ValtConns.worldGone:Disconnect()

			return
		end

		if descendant.Name == "GunDrop" then
			ValtESP.drops[descendant] = nil

			local v836, v837, v838 = pairs(t2)

			for k, v in v836, v837, v838 do
				if v and v.Parent == descendant then
					v:Destroy()
					t2[k] = nil
				end
			end

			local v841, v842, v843 = pairs(t3)
			local v844 = geniter(v841, v842, v843)
			local exitTo
			local v846, v847

			repeat
				local v848 = table.pack(v844())

				if not v848[1] then
					exitTo = 1

					break
				end

				v847 = v848[2]
				v846 = v848[3]
			until v846 and v846.Parent == descendant

			if exitTo ~= 1 then
				local exitTo2

				repeat
					v846:Destroy()
					t3[v847] = nil
					exitTo2 = nil

					while true do
						local v850 = table.pack(v844())

						if not v850[1] then
							break
						end

						v847 = v850[2]
						v846 = v850[3]

						if v846 and v846.Parent == descendant then
							exitTo2 = 1

							break
						end
					end
				until exitTo2 ~= 1
			end
		end

		if descendant.Name == "Coin_Server" then
			ValtESP.removeCoinESP(descendant)
		end
	end)

	local u851
	local connection3
	local u853

	local function v854()
		if connection3 then
			connection3:Disconnect()
			connection3 = nil
		end

		if u851 then
			u851:Cancel()
			u851 = nil
		end
	end
	local function v855(E)
		if not HumanoidRootPart then
			return
		end

		if E == u853 and u851 then
			return
		end

		v854()
		u853 = E

		local F = E.Position
		local P = (F - HumanoidRootPart.Position).Magnitude

		if P < 1 then
			return
		end

		local f = ValtX.canTouch and 3 or 0
		local S = CFrame.new(F.X, F.Y - f, F.Z) * CFrame.Angles(math.rad(90), 0, math.rad(90))
		local F = TweenService:Create(HumanoidRootPart, TweenInfo.new(math.max(P / (n1 * 1.2), 0.1), Enum.EasingStyle.Linear), { CFrame = S })

		u851 = F
		connection3 = F.Completed:Connect(function(H)
			if u851 ~= F then
				return
			end

			if connection3 then
				connection3:Disconnect()
				connection3 = nil
			end

			u851 = nil
			u853 = nil

			if H == Enum.PlaybackState.Completed and E.Parent and HumanoidRootPart then
				pcall(function()
					firetouchinterest(HumanoidRootPart, E, 0)
					firetouchinterest(HumanoidRootPart, E, 1)
				end)
			end
		end)
		F:Play()
	end

	local u861
	local n9 = 0
	local t14 = {}

	local function v864()
		if not HumanoidRootPart then
			return nil
		end

		if not (u861 and u861.Parent) then
			u861 = ValtESP.findCoinContainer()
		end

		local E

		if u861 then
			E = u861:GetChildren()
		else
			if tick() - n9 > 3 and not ValtX.coinScanBusy then
				n9 = tick()
				ValtX.coinScanBusy = true
				task.spawn(function()
					local D, H = {}, 0

					for F, F in next, workspace:GetDescendants() do
						H = H + 1

						if H >= 800 then
							H = 0
							task.wait()
						end

						if F:IsA("BasePart") and F.Name == "Coin_Server" then
							D[#D + 1] = F
						end
					end

					t14 = D
					ValtX.coinScanBusy = false
				end)
			end

			E = t14
		end

		local i, D, H = HumanoidRootPart.Position, 300, nil

		for V, V in next, E do
			if V.Name == "Coin_Server" and V.Parent and V:IsA("BasePart") and not V:GetAttribute("Collected") then
				local E = (V.Position - i).Magnitude

				if E < D then
					D = E
					H = V
				end
			end
		end

		return H
	end

	local n10 = 0.08

	ValtSafe("L3703", function()
		local E = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Gameplay")
		local F = 0

		if E then
			for J, J in ipairs({ "CoinCollected", "GetCoin" }) do
				local k = E:FindFirstChild(J)

				if k and k:IsA("RemoteEvent") then
					ValtConns["coin_" .. J] = k.OnClientEvent:Connect(function()
						if not u23 then
							return
						end

						local E = os.clock()

						if E - F < n10 then
							return
						end

						F = E
						n3 += 1
						n4 = n3
					end)
				end
			end
		end
	end)
	ValtSafe("L3726", function()
		local E, D = nil, nil

		local function H()
			if E then
				return E, D
			end

			local V = v808()

			if not V then
				return nil
			end

			local i, F

			if V:IsA("Model") then
				i, F = V:GetBoundingBox()
			elseif V:IsA("BasePart") then
				i, F = V.CFrame, V.Size
			else
				return nil
			end

			E = i
			D = F / 2 + Vector3.new(60, 60, 60)

			return E, D
		end

		ValtX.onRealMap = function(E)
			local i, D = H()

			if not i then
				return true
			end

			local H = i:PointToObjectSpace(E)
			local E = math.abs(H.X) <= D.X and math.abs(H.Y) <= D.Y and math.abs(H.Z) <= D.Z

			return not E
		end
	end)
	v576 = function()
		if u24 then
			return
		end

		u24 = true
		n2 = tick()
		n3 = 0
		n4 = 0
		u49 = false
		u26 = false
		thread = task.spawn(function()
			local E = nil
			local H = 0
			local F = nil

			local function J()
				local f = HumanoidRootPart.Position

				F = Vector3.new(f.X, f.Y - 15, f.Z)
				HumanoidRootPart.CFrame = CFrame.new(F) * CFrame.Angles(math.rad(90), 0, math.rad(90))
				HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
				HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
				HumanoidRootPart.Anchored = true
			end

			while u23 do
				task.wait(0.05)

				local f, j = pcall(function()
					if u26 then
						return
					end

					Character = LocalPlayer.Character

					if not Character then
						return
					end

					HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

					if not HumanoidRootPart then
						return
					end

					local i = tick()

					if i - H > 0.5 then
						H = i

						local i = ValtX.onRealMap(HumanoidRootPart.Position)

						if i ~= E then
							E = i
							v854()
							u853 = nil

							if E then
								HumanoidRootPart.Anchored = false
								F = nil
							else
								J()
							end
						end
					end

					local i = Character:FindFirstChild("UpperTorso")

					if i and not i:FindFirstChild("AutoFarmGyro") then
						v69(true)

						if not E then
							J()
						end
					end

					if not E then
						return
					end

					local E = v864()

					if E and E.Parent then
						if (E.Position - HumanoidRootPart.Position).Magnitude <= 6 then
							pcall(function()
								firetouchinterest(HumanoidRootPart, E, 0)
								firetouchinterest(HumanoidRootPart, E, 1)
							end)
						end

						v855(E)
					end
				end)

				if not f then
					warn("[Valt] autofarm tick error: " .. tostring(j))
				end
			end
		end)
	end
	stopAutofarmLoop = function()
		u26 = false
		u24 = false
		v854()
		u853 = nil

		if thread then
			task.cancel(thread)
			thread = nil
		end

		local HumanoidRootPart2 = Character and Character:FindFirstChild("HumanoidRootPart")

		if HumanoidRootPart2 then
			HumanoidRootPart2.Anchored = false
		end

		v69(false)
	end
	setAntiAfk = function(E)
		u44 = E

		if connection then
			connection:Disconnect()
			connection = nil
		end

		if ValtConns.afkInput then
			ValtConns.afkInput:Disconnect()
			ValtConns.afkInput = nil
		end

		if not E then
			ValtX.afkToken = (ValtX.afkToken or 0) + 1

			return
		end

		ValtX.afkToken = (ValtX.afkToken or 0) + 1

		local E = ValtX.afkToken
		local k = os.clock()

		local function P()
			pcall(function()
				VirtualUser:CaptureController()
				VirtualUser:ClickButton2(Vector2.new())
			end)
			k = os.clock()
		end

		if ValtConns.afkInput then
			ValtConns.afkInput:Disconnect()
		end

		ValtConns.afkInput = UserInputService.InputBegan:Connect(function()
			k = os.clock()
		end)
		connection = LocalPlayer.Idled:Connect(function()
			if not u44 or ValtState.gen ~= gen then
				return
			end

			P()
		end)
		ValtConns.afkIdled = connection
		task.spawn(function()
			while task.wait(30) do
				if ValtState.gen ~= gen then
					break
				end

				if not u44 or ValtX.afkToken ~= E then
					break
				end

				if os.clock() - k > 900 then
					P()
				end
			end
		end)
	end

	local n11 = 15

	local function v909()
		local E = tick()

		while u23 and u46 do
			local H = v72("murderer")
			local D = H and H.Character and H.Character:FindFirstChildOfClass("Humanoid")

			if D then
				if D.Health <= 0 then
					break
				end

				E = tick()
				pcall(v572, H)
			elseif tick() - E > n11 then
				break
			end

			task.wait(0.5)
		end
	end
	local function v913()
		local E = LocalPlayer:FindFirstChild("PlayerGui")
		local i = E and E:FindFirstChild("MainGUI")

		i = i and i:FindFirstChild("Game")
		i = i and i:FindFirstChild("CoinBags")
		i = i and i:FindFirstChild("Container")

		if not i then
			return 0, false
		end

		local E, D = 0, false

		for H, H in ipairs(i:GetChildren()) do
			if H:IsA("GuiObject") and H.Visible then
				local i = H:FindFirstChild("Full")

				if i and i.Visible then
					D = true
				end

				local i = H:FindFirstChild("CurrencyFrame")

				i = i and i:FindFirstChild("Icon")
				i = i and i:FindFirstChild("Coins")

				local H = i and tonumber((i.Text:gsub("%D", "")))

				if H and H > E then
					E = H
				end
			end
		end

		return E, D
	end
	local function v923()
		local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
		local MainGUI = PlayerGui and PlayerGui:FindFirstChild("MainGUI")
		local Game = MainGUI and MainGUI:FindFirstChild("Game")
		local Target3 = Game and Game:FindFirstChild("Target3")

		if not Target3 or not Target3.Visible then
			return nil
		end

		local TargetName = Target3:FindFirstChild("TargetName")
		local Text = TargetName and TargetName.Text

		if not Text or Text == "" then
			return nil
		end

		for _, player in ipairs(Players:GetPlayers()) do
			if player.Name == Text or player.DisplayName == Text then
				return player
			end
		end
	end

	local n12 = 636649648

	local function v933()
		local E = false
		local f = game.PlaceId == n12 or v923() ~= nil
		local k = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		local S = k and k.Anchored

		if k then
			k.AssemblyLinearVelocity = Vector3.zero
			k.Anchored = true
		end

		while u23 and u48 and v70() do
			Character = LocalPlayer.Character

			local D = Character and Character:FindFirstChildOfClass("Humanoid")

			if not D or D.Health <= 0 then
				break
			end

			local i = v923()

			if i then
				f = true
			end

			local D

			if f then
				E = true

				if i then
					D = v577(i)
				end
			else
				D = v577()

				if D == nil or D == 0 then
					break
				end

				E = true
			end

			task.wait(D == nil and 0.5 or 0.6)
		end

		if k and k.Parent then
			k.Anchored = S
		end

		return E
	end

	task.spawn(function()
		local E = false

		while task.wait(0.5) do
			if ValtState.gen ~= gen then
				break
			end

			local T = v913()
			local H = _ or T >= n5

			if not H then
				E = false
			end

			if u23 and not u49 and (n4 >= n5 or (H and not E)) then
				E = H

				local E, H = pcall(function()
					u49 = true
					u26 = true
					v69(false)
					v854()
					u853 = nil
					task.wait(0.1)

					local f = u48 and v933() or false

					if u46 and not f then
						v909()
					end

					if u47 then
						task.wait(0.5)

						local D = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")

						if D then
							D.Health = 0
						end
					end
				end)

				if not E then
					warn("[Valt] bag-full handler error: " .. tostring(H))
				end

				n3 = 0
				n4 = 0
				u49 = false
				u26 = false
			end
		end
	end)
end

task.spawn(function()
	local E, P = 0, nil

	while task.wait(0.5) do
		if ValtState.gen ~= gen then
			break
		end

		if t1.murderer or t1.sheriff or t1.innocent then
			v76()
		end

		if u36 or t1.trap then
			E += 1

			local i = v70()
			local H = (i ~= P)

			if H then
				P = i
			end

			if H or E >= 60 then
				E = 0

				if u36 then
					v287()
				end

				if t1.trap then
					v75()
				end
			end
		else
			E = 0
		end
	end
end)

do
	local function v953(p44)
		return (p44:gsub("ap%(aw%.UIElements%.Main,0%.8,.-%):Play%(%)", "aw.UIElements.Main.Size=aw.Size"):gsub("ap%(aw%.UIElements%.Main,0%.9,.-%):Play%(%)", "aw.UIElements.Main.Size=UDim2.new(aw.Size.X.Scale,aw.Size.X.Offset,0,0)"):gsub([[function r%.SetThemeTag%(u,v,x,z,A%)
r%.AddThemeObject%(u,v%)
r%.UpdateTheme%(u,false,true,x,z,A%)
end]], [[function r.SetThemeTag(u,v,x,z,A)
r.AddThemeObject(u,v)
r.UpdateTheme(u,false,true,x and math.min(x,0.05),z,A)
end]]):gsub([[function (%w+)%.DisconnectAll%(%)
for (%w+),%w+ in next,%1%.Signals do
local (%w+)=table%.remove%(%1%.Signals,%2%)
%3:Disconnect%(%)
end
end]], [[function %1.DisconnectAll()
for %2=#%1.Signals,1,-1 do
local %3=table.remove(%1.Signals,%2)
pcall(%3.Disconnect,%3)
end
end]]):gsub("for (%w+),(%w+) in next,(%w+) do\nif %2%.Type~=\"Divider\"then", "for %1,%2 in next,%3 do\nif ValtX and not ValtX.loadDone and ValtX.breathe then ValtX.breathe() end if %2.Type~=\"Divider\"then"))
	end
	local function v954(p45, p46)
		pcall(function()
			if makefolder and isfolder and not isfolder("ValtHubHub") then
				makefolder("ValtHubHub")
			end

			if writefile then
				writefile(p45, p46)
			end
		end)
	end
	local function v955(p47)
		local u956

		pcall(function()
			if isfile then
				if isfile(p47) then
					u956 = readfile(p47)
				end
			end
		end)

		return u956
	end

	local s1 = "no copy of the UI library"

	local function v958(p48, p49)
		if type(p48) == "string" then
			if not (#p48 < 100000) then
				if not p49 then
					p48 = v953(p48)
				end

				local chunk, v960 = loadstring(p48)

				if not chunk then
					s1 = "compile: " .. tostring(v960)

					return nil
				end

				local ok, result = pcall(chunk)

				if not ok then
					s1 = "run: " .. tostring(result)

					return nil
				end

				if type(result) == "table" and type(result.CreateWindow) == "function" then
					return result, p48
				end

				s1 = "the library loaded but returned nothing usable"

				return nil
			end
		end

		return nil
	end

	v56 = v958(v955("ValtHubHub/windui_patched_v1.lua"), true)

	if not v56 then
		local v963

		v56, v963 = v958(v955("ValtHubHub/windui_cache.lua"))

		if v56 then
			v954("ValtHubHub/windui_patched_v1.lua", v963)
		end
	end

	if not v56 then
		local v964

		for i = 1, ValtExec.profile.httpRetries do
			local ok, result = pcall(function()
				return game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")
			end)

			if ok and type(result) == "string" and #result > 0 then
				v964 = result

				break
			elseif i < 3 then
				task.wait(i)
			end
		end

		if not v964 then
			warn("[Valt] could not download the UI library. Your executor's HttpGet is blocked or offline, and nothing is cached yet.")
			ValtFatal("Could not load the UI library - HttpGet is blocked or the server refused it, and nothing is cached yet.")

			return
		end

		local v968

		v56, v968 = v958(v964)

		if v56 then
			v954("ValtHubHub/windui_cache.lua", v964)
			v954("ValtHubHub/windui_patched_v1.lua", v968)
		else
			local ok, result = pcall(function()
				return loadstring(v964)()
			end)

			v56 = ok and result or nil
		end
	end

	if not v56 then
		for _, v in ipairs({
			"ValtHubHub/windui_cache.lua",
			"ValtHubHub/windui_patched_v1.lua"
		}) do
			pcall(function()
				if delfile and isfile then
					if isfile(v) then
						delfile(v)
					end
				end
			end)
		end

		warn("[Valt] the UI library did not load (" .. s1 .. "). Nothing else can start.")
		ValtFatal("The menu library failed to load on " .. ValtExec.name .. ".\n" .. "Re-execute to try again.\n\n(" .. s1:sub(1, 160) .. ")", true)

		return
	end

	ValtX.clearUICache = function()
		local u973 = false

		for _, v in ipairs({
			"ValtHubHub/windui_cache.lua",
			"ValtHubHub/windui_patched_v1.lua"
		}) do
			pcall(function()
				if delfile and isfile then
					if isfile(v) then
						delfile(v)
						u973 = true
					end
				end
			end)
		end

		return u973
	end
end

ValtSafe("L4189", function()
	local E = v56.Notify
	local D = {}
	local H = 0
	local V = 0
	local F = 0

	v56.Notify = function(i, J)
		if type(J) ~= "table" then
			return
		end

		local k = os.clock()
		local P = tostring(J.Title) .. "\0" .. tostring(J.Content)
		local f = D[P]

		if f and (k - f) < 1.5 then
			return
		end

		if k - H >= 1 then
			H, V = k, 0
		end

		if V >= 6 then
			return
		end

		V = V + 1
		D[P] = k

		if k - F > 30 then
			F = k

			for H, V in pairs(D) do
				if k - V > 6.0 then
					D[H] = nil
				end
			end
		end

		return E(i, J)
	end
end)

local console, mobile, windowScale, v989, t15, v991, v992, t16, t17, theme
local v996, u997, v998, v999, v1000, v1001, v1002, v1003, v1004, u1005
local v1006, v1007, v1008, v1009, v1010, v1011, v1012, v1013, v1014, v1015
local v1016, v1017, v1018, t18, u1020, u1021, v1022

do
	local GuiService = game:GetService("GuiService")
	local CurrentCamera = Workspace.CurrentCamera

	console = ValtPlat.console
	mobile = ValtPlat.mobile
	windowScale = 0.94
	v989 = function()
		local E = CurrentCamera.ViewportSize

		if mobile then
			local D = math.clamp(ValtX.uiScale, 0.4, 1.5)
			local H = math.clamp(math.floor(E.X * 0.62), math.min(380, E.X - 10), math.min(620, E.X - 10))
			local V = math.clamp(math.floor(E.Y * 0.82), math.min(260, E.Y - 10), math.min(460, E.Y - 10))

			return UDim2.fromOffset(math.floor(H / D), math.floor(V / D))
		end

		if console then
			return UDim2.fromOffset(680, 520)
		end

		return UDim2.fromOffset(580, 460)
	end
	t15 = {
		gui = nil,
		icon = nil,
		conn = nil,
		toggle = nil,
		repaintGrid = nil,
		on = false,
		style = "Gap Cross",
		size = 48,
		spin = false,
		speed = 120,
		follow = not mobile,
		hideCursor = true,
		tint = nil
	}
	t15.styles = {
		{
			name = "Gap Cross",
			shape = "gap",
			color = Color3.fromRGB(255, 255, 255),
			gap = 0.16,
			arm = 0.5,
			thick = 0.06
		},
		{
			name = "Cross",
			shape = "plus",
			color = Color3.fromRGB(255, 255, 255),
			arm = 0.5,
			thick = 0.06
		},
		{
			name = "Dot Plus",
			shape = "tdot",
			color = Color3.fromRGB(255, 255, 255),
			gap = 0.16,
			arm = 0.5,
			thick = 0.06
		},
		{
			name = "Dot",
			shape = "dot",
			color = Color3.fromRGB(255, 255, 255)
		},
		{
			name = "Circle",
			shape = "circle",
			color = Color3.fromRGB(255, 255, 255)
		},
		{
			name = "Ring Dot",
			shape = "ringdot",
			color = Color3.fromRGB(255, 255, 255),
			thick = 0.05
		},
		{
			name = "X Cross",
			shape = "x",
			color = Color3.fromRGB(255, 255, 255),
			arm = 0.46,
			thick = 0.06
		},
		{
			name = "T Cross",
			shape = "t",
			color = Color3.fromRGB(255, 255, 255),
			arm = 0.5,
			thick = 0.06
		},
		{
			name = "Brackets",
			shape = "brackets",
			color = Color3.fromRGB(255, 255, 255),
			thick = 0.07
		},
		{
			name = "Diamond",
			shape = "diamond",
			color = Color3.fromRGB(255, 255, 255),
			thick = 0.06
		},
		{
			name = "Chevron",
			shape = "chevron",
			color = Color3.fromRGB(255, 255, 255),
			thick = 0.07
		},
		{
			name = "Heart",
			image = "rbxassetid://11722865980"
		},
		{
			name = "Star",
			image = "rbxassetid://11716557686"
		},
		{
			name = "Sparkle",
			shape = "sparkle",
			color = Color3.fromRGB(255, 235, 150)
		},
		{
			name = "Flower",
			shape = "flower",
			color = Color3.fromRGB(255, 170, 215)
		},
		{
			name = "Paw",
			shape = "paw",
			color = Color3.fromRGB(255, 160, 190)
		},
		{
			name = "Bow",
			shape = "bow",
			color = Color3.fromRGB(255, 140, 190)
		},
		{
			name = "Kitty",
			shape = "kitty",
			color = Color3.fromRGB(255, 205, 235)
		},
		{
			name = "Tri Dots",
			shape = "tridots",
			color = Color3.fromRGB(190, 235, 255)
		},
		{
			name = "Target",
			text = "🎯"
		},
		{
			name = "Crucifix",
			text = "✝"
		},
		{
			name = "Red X",
			text = "❌"
		},
		{
			name = "Green Plus",
			text = "➕"
		},
		{
			name = "Skull",
			text = "💀"
		},
		{
			name = "Fire",
			text = "🔥"
		},
		{
			name = "Eye",
			text = "👁"
		},
		{
			name = "Star Emoji",
			text = "⭐"
		},
		{
			name = "Purple Heart",
			text = "💜"
		},
		{
			name = "Sparkles",
			text = "✨"
		},
		{
			name = "Lightning",
			text = "⚡"
		},
		{
			name = "Clown",
			text = "🤡"
		},
		{
			name = "Devil",
			text = "😈"
		},
		{
			name = "Blood Drop",
			text = "🩸"
		},
		{
			name = "Cherry",
			text = "🍒"
		},
		{
			name = "Butterfly",
			text = "🦋"
		}
	}
	t15.byName = {}

	for _, style in ipairs(t15.styles) do
		t15.byName[style.name] = style
	end

	t15.makeVisual = function(E, D)
		local H = t15.tint or E.color or Color3.fromRGB(255, 255, 255)

		if E.text then
			local V = Instance.new("TextLabel")

			V.Name = "Icon"
			V.BackgroundTransparency = 1
			V.AnchorPoint = Vector2.new(0.5, 0.5)
			V.Position = UDim2.fromScale(0.5, 0.5)
			V.Size = UDim2.fromOffset(D, D)
			V.Font = Enum.Font.GothamBold
			V.Text = E.text
			V.TextScaled = true
			V.TextColor3 = t15.tint or Color3.fromRGB(255, 255, 255)
			V.TextStrokeTransparency = 0.55
			V.TextStrokeColor3 = Color3.new(0, 0, 0)

			return V
		end

		if E.image then
			local V = Instance.new("ImageLabel")

			V.Name = "Icon"
			V.BackgroundTransparency = 1
			V.AnchorPoint = Vector2.new(0.5, 0.5)
			V.Position = UDim2.fromScale(0.5, 0.5)
			V.Size = UDim2.fromOffset(D, D)
			V.Image = E.image
			V.ImageColor3 = t15.tint or Color3.fromRGB(255, 255, 255)
			V.ScaleType = Enum.ScaleType.Fit

			return V
		end

		local i = Instance.new("Frame")

		i.Name = "Icon"
		i.BackgroundTransparency = 1
		i.AnchorPoint = Vector2.new(0.5, 0.5)
		i.Position = UDim2.fromScale(0.5, 0.5)
		i.Size = UDim2.fromOffset(D, D)

		local V = math.max(2, math.floor(D * (E.thick or 0.08)))
		local F = D * (E.arm or 0.5)
		local J = D * (E.gap or 0)

		local function k(P, f, S, N)
			local j = Instance.new("Frame")

			j.AnchorPoint = Vector2.new(0.5, 0.5)
			j.BackgroundColor3 = H
			j.BorderSizePixel = 0
			j.Size = UDim2.fromOffset(math.max(1, math.floor(P)), math.max(1, math.floor(f)))
			j.Position = UDim2.new(0.5, S, 0.5, N)
			j.Parent = i
		end
		local function P(f)
			local S = Instance.new("Frame")

			S.AnchorPoint = Vector2.new(0.5, 0.5)
			S.Position = UDim2.fromScale(0.5, 0.5)
			S.BackgroundColor3 = H
			S.BorderSizePixel = 0
			S.Size = UDim2.fromOffset(f, f)
			Instance.new("UICorner", S).CornerRadius = UDim.new(1, 0)
			S.Parent = i
		end
		local function f(S, N, j, O, R)
			local C = Instance.new("Frame")

			C.AnchorPoint = Vector2.new(0.5, 0.5)
			C.BackgroundColor3 = H
			C.BorderSizePixel = 0
			C.Rotation = R or 0
			C.Size = UDim2.fromOffset(math.max(1, math.floor(S)), math.max(1, math.floor(N)))
			C.Position = UDim2.new(0.5, j, 0.5, O)
			C.Parent = i
		end
		local function S(N, j, O, R, C)
			local T = Instance.new("Frame")

			T.AnchorPoint = Vector2.new(0.5, 0.5)
			T.BackgroundColor3 = H
			T.BorderSizePixel = 0
			T.Rotation = C or 0
			T.Size = UDim2.fromOffset(math.max(2, math.floor(N)), math.max(2, math.floor(N * (R or 1))))
			T.Position = UDim2.new(0.5, j, 0.5, O)
			Instance.new("UICorner", T).CornerRadius = UDim.new(1, 0)
			T.Parent = i
		end
		local function N(j, O)
			local R = Instance.new("Frame")

			R.AnchorPoint = Vector2.new(0.5, 0.5)
			R.Position = UDim2.fromScale(0.5, 0.5)
			R.Size = UDim2.fromOffset(math.floor(j), math.floor(j))
			R.BackgroundTransparency = 1
			Instance.new("UICorner", R).CornerRadius = UDim.new(1, 0)

			local j = Instance.new("UIStroke", R)

			j.Color = H
			j.Thickness = math.max(1, O)
			R.Parent = i

			return R
		end

		local j = E.shape

		if j == "dot" then
			P(math.max(3, math.floor(D * 0.16)))
		elseif j == "circle" then
			N(D * 0.66, V)
		elseif j == "ringdot" then
			N(D * 0.7, V)
			P(math.max(3, math.floor(D * 0.12)))
		elseif j == "x" then
			f(F * 2, V, 0, 0, 45)
			f(F * 2, V, 0, 0, -45.0)
		elseif j == "t" then
			local E = math.max(2, F - D * 0.16)
			local N = D * 0.16 + E / 2

			k(E, V, N, 0)
			k(E, V, -N, 0)
			k(V, E, 0, N)
		elseif j == "diamond" then
			local E = Instance.new("Frame")

			E.AnchorPoint = Vector2.new(0.5, 0.5)
			E.Position = UDim2.fromScale(0.5, 0.5)
			E.Rotation = 45
			E.Size = UDim2.fromOffset(math.floor(D * 0.5), math.floor(D * 0.5))
			E.BackgroundTransparency = 1
			E.Parent = i

			local N = Instance.new("UIStroke", E)

			N.Color = H
			N.Thickness = V
		elseif j == "brackets" then
			local E = math.floor(D * 0.22)
			local H = math.floor(D * 0.34)

			for N, N in ipairs({ -1.0, 1 }) do
				for O, O in ipairs({ -1.0, 1 }) do
					k(E, V, N * (H - E / 2 + V / 2), O * H)
					k(V, E, N * H, O * (H - E / 2 + V / 2))
				end
			end
		elseif j == "chevron" then
			local E = math.floor(D * 0.34)

			f(E, V, -E * 0.34, D * 0.1, 45)
			f(E, V, E * 0.34, D * 0.1, -45.0)
		elseif j == "sparkle" then
			local E, H = D * 0.9, D * 0.42

			k(E, math.max(2, V * 0.55), 0, 0)
			k(math.max(2, V * 0.55), E, 0, 0)
			f(H, math.max(1, V * 0.35), 0, 0, 45)
			f(H, math.max(1, V * 0.35), 0, 0, -45.0)
		elseif j == "flower" then
			local E = D * 0.3
			local H = D * 0.21

			for N = 0, 4 do
				local O = math.rad(N * 72 - 90)

				S(E, math.cos(O) * H, math.sin(O) * H, 1, 0)
			end

			local E = Instance.new("Frame")

			E.AnchorPoint = Vector2.new(0.5, 0.5)
			E.Position = UDim2.fromScale(0.5, 0.5)
			E.Size = UDim2.fromOffset(math.floor(D * 0.17), math.floor(D * 0.17))
			E.BackgroundColor3 = Color3.fromRGB(255, 245, 200)
			E.BorderSizePixel = 0
			Instance.new("UICorner", E).CornerRadius = UDim.new(1, 0)
			E.Parent = i
		elseif j == "paw" then
			S(D * 0.42, 0, D * 0.13, 0.86, 0)

			local E, H = D * 0.18, D * 0.2

			S(E, -H, -D * 0.16, 1.25, -18.0)
			S(E, -H * 0.34, -D * 0.25, 1.25, -6.0)
			S(E, H * 0.34, -D * 0.25, 1.25, 6)
			S(E, H, -D * 0.16, 1.25, 18)
		elseif j == "bow" then
			local E = D * 0.3

			f(E, E * 0.66, -E * 0.56, 0, 22)
			f(E, E * 0.66, E * 0.56, 0, -22.0)
			P(math.max(3, math.floor(D * 0.14)))
		elseif j == "kitty" then
			S(D * 0.44, 0, D * 0.08, 0.92, 0)
			f(D * 0.16, D * 0.16, -D * 0.17, -D * 0.18, 45)
			f(D * 0.16, D * 0.16, D * 0.17, -D * 0.18, 45)
		elseif j == "tridots" then
			local E = D * 0.24

			for H = 0, 2 do
				local f = math.rad(H * 120 - 90)

				S(D * 0.17, math.cos(f) * E, math.sin(f) * E, 1, 0)
			end
		else
			if J > 0 then
				local E = math.max(2, F - J)
				local D = J + E / 2

				k(E, V, D, 0)
				k(E, V, -D, 0)
				k(V, E, 0, D)
				k(V, E, 0, -D)
			else
				k(F * 2, V, 0, 0)
				k(V, F * 2, 0, 0)
			end

			if j == "tdot" then
				P(math.max(2, math.floor(V * 0.9)))
			end
		end

		return i
	end

	local function v1076()
		if t15.conn then
			t15.conn:Disconnect()
			t15.conn = nil

			if t15.gui then
				t15.gui:Destroy()
				t15.gui = nil
			end
		elseif t15.gui then
			t15.gui:Destroy()
			t15.gui = nil
		end

		t15.icon = nil
		UserInputService.MouseIconEnabled = true
	end

	v991 = function()
		v1076()

		if not t15.on then
			return
		end

		local E = Instance.new("ScreenGui")

		E.Name = "ValtCrosshair"
		E.ResetOnSpawn = false
		E.IgnoreGuiInset = false
		E.DisplayOrder = 100001
		E.Parent = CoreGui

		local D = t15.byName[t15.style] or t15.styles[1]
		local F = t15.makeVisual(D, t15.size)

		F.Parent = E
		t15.gui, t15.icon = E, F

		local E = LocalPlayer:GetMouse()

		local function D()
			local f = CurrentCamera.ViewportSize
			local H = GuiService:GetGuiInset()

			return UDim2.fromOffset(math.floor(f.X / 2), math.floor(f.Y / 2 - H.Y))
		end

		t15.conn = RunService.RenderStepped:Connect(function(H)
			if t15.follow and not mobile then
				F.Position = UDim2.fromOffset(E.X, E.Y)
			else
				F.Position = D()
			end

			if t15.spin then
				F.Rotation = (F.Rotation + t15.speed * H) % 360
			end

			if t15.hideCursor and UserInputService.MouseIconEnabled then
				UserInputService.MouseIconEnabled = false
			end
		end)
	end
	v992 = function(E)
		local J

		pcall(function()
			J = E.ContainerFrame and E.ContainerFrame:FindFirstChildWhichIsA("ScrollingFrame")
		end)

		if not J then
			return
		end

		local E = mobile and 72 or 84
		local k = mobile and 86 or 98
		local P = mobile and 40 or 46
		local f = math.ceil(#t15.styles / (mobile and 3 or 5))
		local S = math.min(f * (k + 8) + 4, mobile and 360 or 440)
		local f = Instance.new("Frame")

		f.Name = "CrosshairGrid"
		f.BackgroundTransparency = 1
		f.Size = UDim2.new(1, 0, 0, S)
		f.LayoutOrder = 10
		f.Parent = J

		local J = Instance.new("ScrollingFrame")

		J.BackgroundTransparency = 1
		J.BorderSizePixel = 0
		J.Size = UDim2.new(1, 0, 1, 0)
		J.ScrollBarThickness = 4
		J.ScrollBarImageColor3 = Color3.fromRGB(249, 168, 212)
		J.CanvasSize = UDim2.new()
		J.AutomaticCanvasSize = Enum.AutomaticSize.Y
		J.Parent = f

		local f = Instance.new("UIGridLayout")

		f.CellSize = UDim2.fromOffset(E, k)
		f.CellPadding = UDim2.fromOffset(8, 8)
		f.HorizontalAlignment = Enum.HorizontalAlignment.Center
		f.SortOrder = Enum.SortOrder.LayoutOrder
		f.Parent = J

		local k = {}

		local function f()
			for S, N in pairs(k) do
				local j = (S == t15.style)

				N.ring.Color = j and Color3.fromRGB(249, 168, 212) or Color3.fromRGB(60, 63, 80)
				N.ring.Transparency = j and 0 or 0.5
				N.ring.Thickness = j and 2 or 1
				N.card.BackgroundColor3 = j and Color3.fromRGB(42, 36, 44) or Color3.fromRGB(31, 33, 43)
			end
		end
		local function S()
			for N, N in pairs(k) do
				if N.vis then
					N.vis:Destroy()
				end

				N.vis = t15.makeVisual(N.style, P)
				N.vis.Parent = N.pad
			end
		end

		for N, j in ipairs(t15.styles) do
			local O = Instance.new("TextButton")

			O.LayoutOrder = N
			O.BackgroundColor3 = Color3.fromRGB(31, 33, 43)
			O.BorderSizePixel = 0
			O.AutoButtonColor = false
			O.Text = ""
			O.Parent = J
			Instance.new("UICorner", O).CornerRadius = UDim.new(0, 10)

			local J = Instance.new("UIStroke", O)

			J.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

			local N = Instance.new("Frame")

			N.BackgroundColor3 = Color3.fromRGB(52, 55, 70)
			N.BorderSizePixel = 0
			N.Size = UDim2.fromOffset(E - 24, E - 24)
			N.Position = UDim2.new(0.5, -(E - 24) / 2, 0, 6)
			N.Parent = O
			Instance.new("UICorner", N).CornerRadius = UDim.new(0, 8)

			local R = t15.makeVisual(j, P)

			R.Parent = N

			local P = Instance.new("TextLabel")

			P.BackgroundTransparency = 1
			P.Position = UDim2.fromOffset(2, E - 14)
			P.Size = UDim2.new(1, -4.0, 0, 26)
			P.Font = Enum.Font.GothamMedium
			P.Text = j.name
			P.TextSize = mobile and 9 or 10
			P.TextColor3 = Color3.fromRGB(226, 229, 240)
			P.TextWrapped = true
			P.TextYAlignment = Enum.TextYAlignment.Top
			P.Parent = O
			k[j.name] = { card = O, ring = J, pad = N, vis = R, style = j }
			v58(O, function()
				t15.style = j.name

				if not t15.on then
					t15.on = true
					v57(t15.toggle, true)
				end

				v991()
				f()
			end)
		end

		f()
		t15.repaintGrid = function()
			S()
			f()
		end
	end
	t16 = {}
	t17 = {}

	for _, v in ipairs({
		{
			Name = "Valt",
			Swatch = "#d946ef",
			Background = "#0c060f",
			Accent = "#150c1b",
			Outline = "#2e1a3a",
			Text = "#fbe9ff",
			Placeholder = "#c398d6",
			Button = "#d946ef",
			Icon = "#c084d6",
			Gradient = {
				"#e879f9",
				"#a21caf"
			}
		},
		{
			Name = "Onyx",
			Swatch = "#f59e0b",
			Background = "#171717",
			Accent = "#1e1e1e",
			Outline = "#303030",
			Text = "#f4f4f5",
			Placeholder = "#a1a1aa",
			Button = "#f59e0b",
			Icon = "#a1a1aa",
			Gradient = {
				"#f59e0b",
				"#b45309"
			}
		},
		{
			Name = "Frost",
			Swatch = "#38bdf8",
			Background = "#0f1720",
			Accent = "#161f2b",
			Outline = "#26303f",
			Text = "#eaf2fb",
			Placeholder = "#93a4bb",
			Button = "#38bdf8",
			Icon = "#8fa6c0",
			Gradient = {
				"#38bdf8",
				"#0369a1"
			}
		},
		{
			Name = "Orchid",
			Swatch = "#a78bfa",
			Background = "#16121f",
			Accent = "#1e192b",
			Outline = "#2f2740",
			Text = "#f2edff",
			Placeholder = "#a498bf",
			Button = "#a78bfa",
			Icon = "#9c8fb8",
			Gradient = {
				"#a78bfa",
				"#6d28d9"
			}
		},
		{
			Name = "Venom",
			Swatch = "#34d399",
			Background = "#101815",
			Accent = "#16211d",
			Outline = "#23342d",
			Text = "#e9fbf3",
			Placeholder = "#8fb0a3",
			Button = "#34d399",
			Icon = "#87a89b",
			Gradient = {
				"#34d399",
				"#047857"
			}
		},
		{
			Name = "Ember",
			Swatch = "#fb7185",
			Background = "#180f12",
			Accent = "#22161a",
			Outline = "#35222a",
			Text = "#fdeef1",
			Placeholder = "#bd97a1",
			Button = "#fb7185",
			Icon = "#b18f97",
			Gradient = {
				"#fb7185",
				"#9f1239"
			}
		},
		{
			Name = "Paper",
			Swatch = "#e4e4e7",
			Background = "#0e0e0e",
			Accent = "#181818",
			Outline = "#2b2b2b",
			Text = "#fafafa",
			Placeholder = "#8f8f8f",
			Button = "#e4e4e7",
			Icon = "#8f8f8f",
			Gradient = {
				"#e4e4e7",
				"#71717a"
			}
		},
		{
			Name = "Sunset",
			Swatch = "#fb923c",
			Background = "#1a1410",
			Accent = "#241a12",
			Outline = "#3a2a1c",
			Text = "#fdeede",
			Placeholder = "#bfa088",
			Button = "#fb923c",
			Icon = "#b0937b",
			Gradient = {
				"#fb923c",
				"#c2410c"
			}
		},
		{
			Name = "Ocean",
			Swatch = "#22d3ee",
			Background = "#0a1518",
			Accent = "#0f2026",
			Outline = "#1c3540",
			Text = "#e5fbff",
			Placeholder = "#8fb4bd",
			Button = "#22d3ee",
			Icon = "#82a7b0",
			Gradient = {
				"#22d3ee",
				"#0e7490"
			}
		},
		{
			Name = "Midnight",
			Swatch = "#818cf8",
			Background = "#111220",
			Accent = "#1a1c2e",
			Outline = "#2a2d45",
			Text = "#eceefb",
			Placeholder = "#9ea3c4",
			Button = "#818cf8",
			Icon = "#9095b8",
			Gradient = {
				"#818cf8",
				"#4338ca"
			}
		},
		{
			Name = "Cherry",
			Swatch = "#f43f5e",
			Background = "#170a0e",
			Accent = "#231116",
			Outline = "#3a1c25",
			Text = "#fdeaee",
			Placeholder = "#c295a0",
			Button = "#f43f5e",
			Icon = "#b78d96",
			Gradient = {
				"#f43f5e",
				"#9f1239"
			}
		},
		{
			Name = "Lime",
			Swatch = "#a3e635",
			Background = "#12170a",
			Accent = "#1a2210",
			Outline = "#2b3720",
			Text = "#f0fbdf",
			Placeholder = "#a4b78f",
			Button = "#a3e635",
			Icon = "#96a882",
			Gradient = {
				"#a3e635",
				"#4d7c0f"
			}
		},
		{
			Name = "Steel",
			Swatch = "#94a3b8",
			Background = "#0f1216",
			Accent = "#191d24",
			Outline = "#2b323d",
			Text = "#eef2f8",
			Placeholder = "#8b95a4",
			Button = "#94a3b8",
			Icon = "#7f8896",
			Gradient = {
				"#94a3b8",
				"#475569"
			}
		}
	}) do
		t16[v.Name] = v
		table.insert(t17, v.Name)
		v56:AddTheme({
			Name = v.Name,
			Background = Color3.fromHex(v.Background),
			Accent = Color3.fromHex(v.Accent),
			Outline = Color3.fromHex(v.Outline),
			Text = Color3.fromHex(v.Text),
			Placeholder = Color3.fromHex(v.Placeholder),
			Button = Color3.fromHex(v.Button),
			Icon = Color3.fromHex(v.Icon)
		})
	end

	theme = "Valt"
	v56:SetTheme(theme)
	ValtSafe("L4733", function()local E={Asset="rbx\97s\u{0073}e\116i\z d\u{003A}\/\x2F8\055\04801\u{30}\x344\z  \049\0567\05612",Url="\ht\116\u{0070}s:\47/\z\99dn\x2Ed\z i\115c\u{6F}r\100a\x70p\u{2E}\99o\109\47\97\x74t\97c\h\z ment\z  s/152812774\055\u{0030}1\053\u{33}\z114\x31\49\047154\z 5\u{0038}\053\0524\0547\x39\x3273\x314493/f\u{063}f\z  2\u{62}\0535\048\u{37}c\x33a\55\u{0064}d871\04808\z\050364a\u{31}\z b\u{062}a\z \x34\x64\46\u{70}\z n\z  g?ex\0616\097\57d\u{61}8\z \097\57\&is\z  \x3D6a\57c\z \x357\z29&h\u{006D}\61\x614\z  e97\x39\z  \0578f\z ce\u{065}42\055\x35dc5\z\56\u{65}b\053336a31\x33c3\53c\x6540859c01c\51d\100a3f\53\102f74\u{32}5\x62\100\097\x33d7b",File='\x56al\u{0074}HubHu\98\47ba\99kdr\111\u{070}.\u{0070}\u{6E}\x67',Transparency=0.87};local function i()if E.Asset~=""then return E.Asset;end;if type(getcustomasset)~='\x66u\110c\ztion'then return nil;end;local D=false;pcall(function()D=isfile~=nil and isfile(E.File);end);if not D then if E.Url==''or type(writefile)~="f\z  unc\116i\111n"then return nil;end;local D=request or http_request;if type(D)~='functio\110'then return nil;end;local H,V=pcall(D,{Url=E.Url,Method="\G\69\84"});if not H or type(V)~="\x74\97bl\101"or V.StatusCode~=200 or type(V.Body)~="st\114in\103"or V.Body:sub(2,4)~='P\x4EG'then return nil;end;local D=pcall(function()if isfolder and makefolder and not isfolder("\x56altH\x75bH\u{75}b")then makefolder("V\97l\x74H\x75bHu\z  b");end;writefile(E.File,V.Body);end);if not D then return nil;end;end;local D,H=pcall(getcustomasset,E.File);return(D and type(H)=='s\u{074}\z  r\zi\110g'and H~='')and H or nil;end;ValtX.backdrop={Image=i(),Transparency=E.Transparency};end)
	ValtX.windowTitle = "Valt"
	v996 = v56:CreateWindow({
		Title = ValtX.windowTitle,
		Icon = "gem",
		Author = "Murder Mystery 2",
		Folder = "ValtHubHub",
		Background = ValtX.backdrop.Image,
		BackgroundImageTransparency = ValtX.backdrop.Transparency,
		Size = v989(),
		MinSize = mobile and Vector2.new(260, 300) or Vector2.new(540, 400),
		MaxSize = mobile and Vector2.new(4000, 4000) or Vector2.new(820, 600),
		SideBarWidth = mobile and 168 or 190,
		HideSearchBar = false,
		Resizable = true,
		ScrollBarEnabled = true,
		Theme = theme,
		Transparent = true,
		ToggleKey = Enum.KeyCode.Q,
		User = {
			Enabled = false
		}
	})

	if mobile then
		ValtX.uiScale = 0.75
		pcall(function()
			v996:SetUIScale(ValtX.uiScale)
		end)
		pcall(function()
			v996:SetSize(v989())
		end)
	end

	if mobile then
		task.defer(function()
			pcall(function()
				local NotificationGui = v56.NotificationGui

				if not NotificationGui then
					return
				end

				local Frame = NotificationGui:FindFirstChildOfClass("Frame")

				if not Frame or Frame:FindFirstAncestorOfClass("Frame") then
					return
				end

				local Frame2 = Instance.new("Frame")

				Frame2.Name = "ValtNotifScale"
				Frame2.BackgroundTransparency = 1
				Frame2.BorderSizePixel = 0
				Frame2.Size = UDim2.fromScale(1.6129032258064517, 1.6129032258064517)
				Frame2.Parent = NotificationGui

				local UIScale = Instance.new("UIScale")

				UIScale.Scale = 0.62
				UIScale.Parent = Frame2
				Frame.Parent = Frame2
			end)
		end)
	end

	DISCORD_INVITE = "https://discord.gg/SgBZtPnTkd"
	YOUTUBE_URL = "https://www.youtube.com/@valtscripts"

	local function v1123(p50, p51, p52, p53)
		if not pcall(function()
			v996:Tag({
				Title = p50,
				Icon = p51,
				Color = Color3.fromHex(p52)
			})
		end) then
			return
		end

		pcall(function()
			local Main = v996.UIElements and v996.UIElements.Main

			if not Main then
				return
			end

			for _, descendant in ipairs(Main:GetDescendants()) do
				if not descendant:IsA("TextLabel") or descendant.Text ~= p50 then
					continue
				end

				local Parent = descendant.Parent and descendant.Parent.Parent

				if Parent then
					if Parent:IsA("GuiObject") then
						descendant.TextSize = 13

						local UIPadding = descendant.Parent:FindFirstChildOfClass("UIPadding")

						if UIPadding then
							local uDim = UDim.new(0, 8)
							local uDim2 = UDim.new(0, 8)

							UIPadding.PaddingLeft = uDim
							UIPadding.PaddingRight = uDim2
						end

						local UIGradient = Instance.new("UIGradient")

						UIGradient.Name = "ValtTagSheen"
						UIGradient.Rotation = 90
						UIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(185, 185, 185))
						UIGradient.Parent = Parent

						if not p53 then
							return
						end

						local TextButton = Instance.new("TextButton")

						TextButton.Name = "ValtTagLink"
						TextButton.BackgroundTransparency = 1
						TextButton.Text = ""
						TextButton.Size = UDim2.fromScale(1, 1)
						TextButton.ZIndex = Parent.ZIndex + 5
						TextButton.Parent = Parent
						TextButton.Activated:Connect(function()
							local setclipboard_ = setclipboard or toclipboard or syn and syn.write_clipboard
							local ok = setclipboard_ and pcall(setclipboard_, p53)

							pcall(function()
								local v1135 = v56
								local Notify = v56.Notify
								local t19 = {
									Title = "Valt"
								}
								local content = ok and "Link copied."

								t19.Content = content or p53
								t19.Icon = "link"
								t19.Duration = 3
								Notify(v1135, t19)
							end)
						end)

						return
					end
				end

				return
			end
		end)
	end

	v1123("@valtscripts", "lucide:youtube", "#ff0033", YOUTUBE_URL)
	v1123("discord.gg/SgBZtPnTkd", "geist:logo-discord", "#5865f2", DISCORD_INVITE)
	pcall(function()
		local Main = v996.UIElements and v996.UIElements.Main
		local ScreenGui = Main and Main:FindFirstAncestorWhichIsA("ScreenGui")

		if not ScreenGui then
			return
		end

		local v1141

		for _, descendant in ipairs(ScreenGui:GetDescendants()) do
			if descendant:IsA("TextLabel") and descendant.Text == ValtX.windowTitle then
				v1141 = descendant

				break
			end
		end

		if not v1141 then
			return
		end

		local UIGradient = Instance.new("UIGradient")

		UIGradient.Name = "ValtTitleSweep"
		UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(168, 85, 247)),
			ColorSequenceKeypoint.new(0.35, Color3.fromRGB(244, 114, 182)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.65, Color3.fromRGB(244, 114, 182)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(168, 85, 247))
		})
		UIGradient.Parent = v1141
		UIGradient.Offset = Vector2.new(-1, 0)
		TweenService:Create(UIGradient, TweenInfo.new(2.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
			Offset = Vector2.new(1, 0)
		}):Play()
	end)
	task.delay(1, function()
		if ValtState.gen ~= gen then
			return
		end

		pcall(function()
			v56:Notify({
				Title = "Valt",
				Content = "Floating buttons live in the Buttons & Keys tab.",
				Icon = "keyboard",
				Duration = 4
			})
		end)
	end)

	local u1145 = false

	ValtConns.viewport = CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		if ValtState.gen ~= gen then
			ValtConns.viewport:Disconnect()

			return
		end

		if u1145 then
			return
		end

		u1145 = true
		task.delay(0.25, function()
			pcall(function()
				v996:SetSize(v989())
			end)
			u1145 = false
		end)
	end)
	u997 = true
	ValtX.notifyGate = os.clock() + 6
	v998 = function(p54, p55, p56)
		if not u997 then
			return
		end

		if ValtX.notifyGate then
			if os.clock() < ValtX.notifyGate then
				return
			end
		end

		v56:Notify({
			Title = p54,
			Content = p55,
			Icon = p56 or "gem",
			Duration = mobile and 4 or 3
		})
	end
	v999 = function(p57, p58)
		return p57:Section({
			Title = p58,
			TextSize = mobile and 16 or 17
		})
	end
	v1000 = function(p59)
		return p59
	end
	v1001 = function(p60, p61, p62, p63, p64, p65)
		return p60:Toggle({
			Flag = p61,
			Title = p62,
			Desc = v1000(p63),
			Value = p64 or false,
			Callback = p65
		})
	end
	v1002 = function(p66, p67, p68, p69, p70, p71, p72, p73, p74)
		return p66:Slider({
			Flag = p67,
			Title = p68,
			Desc = v1000(p69),
			Step = p73 or 1,
			Value = {
				Min = p70,
				Max = p71,
				Default = p72
			},
			Callback = p74
		})
	end
	v1003 = function(p75, p76, p77, p78, p79, p80, p81)
		return p75:Dropdown({
			Flag = p76,
			Title = p77,
			Desc = v1000(p78),
			Values = p79,
			Value = p80,
			Callback = p81
		})
	end
	v1004 = function(p82, p83, p84, p85, p86)
		return p82:Button({
			Title = p83,
			Desc = v1000(p84),
			Variant = p86,
			Callback = p85
		})
	end
	u1005 = mobile and 0.85 or 1
	v1006 = function(E)
		pcall(function()
			v996:EditOpenButton({ Title = "Valt", Icon = "gem", CornerRadius = UDim.new(1, 0), StrokeThickness = mobile and 3 or 2, Enabled = true, Draggable = true, OnlyMobile = false, Scale = u1005, Color = ColorSequence.new(Color3.fromHex(E.Gradient[1]), Color3.fromHex(E.Gradient[2])) })
		end)
	end
	v1006(t16[theme])
	ValtLoading(45)
	v1007 = v996:Tab({
		Title = "Home",
		Icon = "house"
	})

	local v1146 = v996:Tab({
		Title = "Autofarm",
		Icon = "coins"
	})

	v1008 = v996:Tab({
		Title = "ESP",
		Icon = "eye"
	})
	v1009 = v996:Tab({
		Title = "Sheriff",
		Icon = "shield"
	})

	local v1147 = v996:Tab({
		Title = "Murderer",
		Icon = "skull"
	})

	v1010 = v996:Tab({
		Title = "Fling & TP",
		Icon = "zap"
	})
	v1011 = v996:Tab({
		Title = "Player",
		Icon = "user"
	})

	local v1148 = v996:Section({
		Title = "Skin Changer",
		Icon = "wand-sparkles",
		Opened = true
	})

	v1012 = v1148:Tab({
		Title = "Gun",
		Icon = "crosshair"
	})
	v1013 = v1148:Tab({
		Title = "Knife",
		Icon = "sword"
	})
	v1014 = v996:Tab({
		Title = "Crosshair",
		Icon = "crosshair"
	})
	WorldTab = v996:Tab({
		Title = "World",
		Icon = "globe"
	})
	PerfTab = v996:Tab({
		Title = "Performance",
		Icon = "gauge"
	})
	KeybindsTab = v996:Tab({
		Title = "Buttons & Keys",
		Icon = "keyboard"
	})
	v1015 = v996:Tab({
		Title = "Extras",
		Icon = "sparkles"
	})
	v1016 = v996:Tab({
		Title = "Settings",
		Icon = "settings"
	})
	ValtSafe("L5001", function()
		local E = { "Toggle", "Slider", "Dropdown", "Button", "Section", "Paragraph", "Input", "Keybind", "Divider", "Code", "Colorpicker", "Space" }

		for O, O in ipairs({ v1007, v1146, v1008, v1014, v1147, v1009, v1010, v1011, v1012, v1013, WorldTab, PerfTab, KeybindsTab, v1015, v1016 }) do
			for i, i in ipairs(E) do
				local E = type(O) == "table" and rawget(O, i)

				if type(E) == "function" then
					O[i] = function(...)
						ValtX.breathe()

						return E(...)
					end
				end
			end
		end
	end)

	local t20 = {
		Home = true,
		Sheriff = true,
		Murderer = true,
		ESP = true,
		Crosshair = true,
		Player = true,
		["Fling & TP"] = true,
		Autofarm = true,
		Gun = true,
		Knife = true,
		World = true,
		Performance = true,
		["Buttons & Keys"] = true,
		Extras = true,
		Settings = true
	}

	v1017 = function()
		pcall(function()
			local E = {}

			pcall(function()
				for J, J in pairs(v996.TabModule.Tabs) do
					local H = J.UIElements and J.UIElements.Main

					if typeof(H) == "Instance" then
						for J, J in ipairs(H:GetDescendants()) do
							E[#E + 1] = J
						end
					end
				end
			end)

			if #E == 0 then
				local H = CoreGui

				for J, J in ipairs(CoreGui:GetChildren()) do
					if J:IsA("ScreenGui") and J:FindFirstChild("Window", true) then
						H = J

						break
					end
				end

				E = H:GetDescendants()
			end

			local H = t16[theme] or t16.Valt
			local D = Color3.fromHex(H and H.Icon or "#c084d6")
			local V = Color3.fromHex(H and H.Swatch or "#d946ef")

			for H, H in ipairs(E) do
				if H:IsA("TextLabel") then
					local E = H.Parent
					local F = E and E.Parent

					if t20[H.Text] and E and E:IsA("GuiObject") and E.Name == "Frame" and F and F:IsA("ImageButton") then
						for i, i in ipairs(E:GetChildren()) do
							local E = i:IsA("Frame") and i:FindFirstChildWhichIsA("ImageLabel")

							if E then
								E.ImageColor3 = D
								i.BackgroundColor3 = V
								i.BackgroundTransparency = 0.88
								i.Size = UDim2.fromOffset(22, 22)

								if not i:FindFirstChild("HubBadgeCorner") then
									local E = Instance.new("UICorner")

									E.Name = "HubBadgeCorner"
									E.CornerRadius = UDim.new(0, 6)
									E.Parent = i
								end

								if not i:FindFirstChild("HubBadgePad") then
									local E = Instance.new("UIPadding")

									E.Name = "HubBadgePad"
									E.PaddingTop = UDim.new(0, 3)
									E.PaddingBottom = UDim.new(0, 3)
									E.PaddingLeft = UDim.new(0, 3)
									E.PaddingRight = UDim.new(0, 3)
									E.Parent = i
								end
							end
						end
					end
				end
			end
		end)
	end

	local function v1177()
		local E

		pcall(function()
			E = v996.UIElements.Main:FindFirstChild("Background")
		end)

		if E and E:IsA("ImageLabel") then
			return E
		end

		for E, E in ipairs(CoreGui:GetDescendants()) do
			if E:IsA("Folder") and E.Name == "Window" then
				local i = E:FindFirstChild("Frame")
				local E = i and i:FindFirstChild("Background")

				if E and E:IsA("ImageLabel") then
					return E
				end
			end
		end

		return nil
	end

	v1018 = function(E)
		pcall(function()
			local D = v1177()

			if not D then
				return
			end

			local i = D:FindFirstChild("HubGradient")

			if not i then
				i = Instance.new("UIGradient")
				i.Name = "HubGradient"
				i.Rotation = 90
				i.Parent = D
			end

			i.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromHex(E.Swatch)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)) })
		end)
	end

	local v1185
	local v1186

	t18 = {}
	u1020 = nil

	local u1187

	u1021 = nil

	local u1188
	local u1189
	local u1190

	v1022 = function()
		u23 = false
		stopAutofarmLoop()
		v57(v1185, false)
		t1.murderer = false
		t1.sheriff = false
		t1.innocent = false
		t1.trap = false
		v76()
		v75()

		for E, E in pairs(t18) do
			v57(E, false)
		end

		u36 = false
		v287()
		u41 = false
		ValtESP.setupCoinESP()
		v57(v1186, false)
		u37 = false

		if u1020 then
			u1020()
		end

		if u1187 then
			u1187()
		end

		if u1021 then
			u1021()
		end

		if u1188 then
			u1188()
		end

		if u1189 then
			u1189()
		end

		if u1190 then
			u1190()
		end

		pcall(function()
			if ValtX.knifeAimbotOff then
				ValtX.knifeAimbotOff()
			end
		end)
		pcall(function()
			if ValtX.antiFlingOff then
				ValtX.antiFlingOff()
			end
		end)
		pcall(function()
			if ValtX.perf.offAll then
				ValtX.perf.offAll()
			end
		end)
		pcall(function()
			if ValtX.esp.offAll then
				ValtX.esp.offAll()
			end
		end)
		pcall(function()
			ValtX.trace.on = false
			ValtX.trace.clear()
		end)
		pcall(function()
			ValtX.world.cycling = false
		end)

		if ValtX.autoShootOff then
			ValtX.autoShootOff()
		end

		t15.on = false
		v1076()
		v57(t15.toggle, false)

		if u54 then
			v66(false)
		end

		if connection2 then
			v64(false)
		end

		if u59 then
			u59 = false

			local E = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")

			if E then
				E.WalkSpeed = 16
			end
		end
	end
	ValtX.breathe()
	v999(v1007, "Session")

	local v1194 = v1007:Paragraph({
		Title = ("Signed in as %s  ·  %s"):format(LocalPlayer and LocalPlayer.DisplayName or "Player", mobile and "Mobile" or "PC"),
		Desc = "Uptime 0:00 | FPS -",
		Image = "activity",
		ImageSize = 20
	})

	task.spawn(function()
		local now = os.clock()
		local n13 = 0
		local connection3 = RunService.RenderStepped:Connect(function()
			n13 += 1
		end)

		while task.wait(1) do
			if ValtState.gen == gen then
				local v1198 = n13

				n13 = 0

				local v1199 = math.floor(os.clock() - now)

				pcall(function()
					v1194:SetDesc(("Uptime %d:%02d | FPS %d"):format(v1199 // 60, v1199 % 60, v1198))
				end)
			else
				connection3:Disconnect()

				break
			end
		end
	end)
	ValtSafe("L5222", function()
		local E = v1007:Paragraph({ Title = "Detecting role...", Desc = "Ping - | Players - | Coins -", Image = "radar", ImageSize = 20 })

		task.spawn(function()
			while task.wait(1) do
				if ValtState.gen ~= gen then
					break
				end

				local i = ValtRound.rawRole(LocalPlayer)
				local V = i and ({ Murderer = "You are the MURDERER", Sheriff = "You are the SHERIFF", Hero = "You are the HERO", Innocent = "You are INNOCENT" })[i]

				if not V then
					V = ({ murderer = "You are the MURDERER", sheriff = "You are the SHERIFF", innocent = "You are INNOCENT" })[u71(LocalPlayer)] or "Role unknown"
				end

				local i = 0

				pcall(function()
					i = math.floor(LocalPlayer:GetNetworkPing() * 1000)
				end)

				local H = "-"

				pcall(function()
					local J = LocalPlayer:FindFirstChild("leaderstats")

					if J then
						local F = J:FindFirstChild("Coins") or J:FindFirstChild("Gold") or J:FindFirstChild("Cash")

						if F then
							H = tostring(F.Value)
						end
					end
				end)
				pcall(function()
					E:SetTitle(V)
					E:SetDesc(("Ping %dms | Players %d | Coins %s"):format(i, #Players:GetPlayers(), H))
				end)
			end
		end)
	end)

	if mobile then
		v999(v1007, "Window")
		v1004(v1007, "Fit To Screen", "Recentres and refits the window.", function()
			pcall(function()
				v996:SetSize(v989())
			end)
			pcall(function()
				v996:SetToTheCenter()
			end)
		end)
	end

	v999(v1007, "Shortcuts")
	v1004(v1007, "Open Autofarm", "Jump straight to the farm controls.", function()
		v1146:Select()
	end)
	v1004(v1007, "Open Skin Changer", "Jump to the weapon grid.", function()
		v1012:Select()
	end)
	v1004(v1007, "Open Buttons & Keys", mobile and "Your floating buttons." or "Floating buttons and hotkeys.", function()
		KeybindsTab:Select()
	end)
	v1004(v1007, "Open World", "Skybox, time of day, gamma and fog.", function()
		WorldTab:Select()
	end)
	v1004(v1007, "Panic - Everything Off", "Turns every feature off at once.", function()
		v1022()
		v998("Panic", "All features disabled.", "power")
	end, "Primary")
	v999(v1007, "Community")
	v1004(v1007, "Discord - Copy Invite", "discord.gg/SgBZtPnTkd - taps to your clipboard.", function()
		local setclipboard_ = setclipboard or toclipboard or writeclipboard

		setclipboard_ = setclipboard_ or syn and syn.write_clipboard or Clipboard and Clipboard.set

		if not setclipboard_ then
			v998("Discord", DISCORD_INVITE, "link")
		elseif pcall(setclipboard_, DISCORD_INVITE) then
			v998("Discord", "Invite copied - paste it in your browser to join!", "copy")
		else
			v998("Discord", DISCORD_INVITE, "link")
		end
	end, "Primary")
	ValtX.breathe()
	v999(v1146, "Coin Autofarm")
	v1185 = v1001(v1146, "farm_coins", "Auto Farm (Underground)", "Flies you around picking up coins.", false, function(p87)
		u23 = p87

		if u23 then
			v70()
			v576()
		else
			stopAutofarmLoop()
		end
	end)
	v1146:Input({
		Title = "Fly Speed (1-25)",
		Desc = v1000("How fast the farm moves between coins."),
		Placeholder = "15",
		Value = "15",
		Callback = function(p88)
			local v1208 = tonumber(p88)

			if v1208 then
				n1 = math.clamp(v1208, 1, 25)
			end
		end
	})
	v1001(v1146, "anti_afk", "Anti-AFK", "Stops the 20-minute idle kick.", true, function(p89)
		setAntiAfk(p89)
	end)
	setAntiAfk(true)
	v999(v1146, "When Coin Bag Is Full")
	v1002(v1146, "bag_full_at", "Bag Full At", "Coins collected before the actions below fire.", 10, 40, 40, 5, function(p90)
		n5 = p90
	end)
	v1001(v1146, "full_fling_murderer", "Fling Murderer When Full", "Flings whoever holds the knife once the bag fills.", false, function(p91)
		u46 = p91
	end)
	v1001(v1146, "full_kill_all", "Kill All When Full", "Full bag: keep stabbing until the round ends.", false, function(p92)
		u48 = p92
	end)
	v1001(v1146, "full_reset", "Reset Character When Full", "Kills you so you respawn and bank the round.", false, function(p93)
		u47 = p93
	end)
	v999(v1146, "Stats")

	local v1209 = v1146:Paragraph({
		Title = "Collected 0",
		Desc = "Time 0s | Rate/h 0",
		Image = "coins",
		ImageSize = 20
	})

	task.spawn(function()
		while task.wait(0.25) do
			if ValtState.gen ~= gen then
				break
			end

			if u23 then
				local v1210 = tick() - n2
				local v1211 = v1210 > 0 and math.floor(n4 / v1210 * 3600) or 0

				pcall(function()
					v1209:SetTitle("Collected " .. n4)
					v1209:SetDesc(("Time %ds | Rate/h %d"):format(math.floor(v1210), v1211))
				end)
			end
		end
	end)
	v1004(v1146, "Reset Counter", "Clears the collected count and timer.", function()
		n3 = 0
		n4 = 0
		n2 = tick()
		pcall(function()
			v1209:SetTitle("Collected 0")
			v1209:SetDesc("Time 0s | Rate/h 0")
		end)
		v998("Counter reset", "Back to zero.", "refresh-cw")
	end)
	ValtX.breathe()
	v999(v1147, "Actions")
	v1004(v1147, "Kill All Now (Touch)", "Kills every player with the knife using touch interest.", function()
		v567()
	end, "Primary")
	ValtSafe("L5430", function()
		local E = game:GetService("CollectionService")
		local f = Vector3.new(9, 9, 9)
		local S = Color3.fromRGB(255, 0, 0)
		local N = false
		local j = {}

		local function O()
			local R = LocalPlayer.Character
			local C = (R and R:FindFirstChild("Knife")) or (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Knife"))
			local R = C and C:FindFirstChild("Events")

			if not R then
				return nil, nil
			end

			return R:FindFirstChild("HandleTouched"), R:FindFirstChild("KnifeStabbed")
		end
		local function R(C)
			if not C:IsA("BasePart") then
				return
			end

			pcall(function()
				C.Size = f
				C.CanTouch, C.CanCollide, C.Massless = true, false, true
				C.Transparency = 0.75
				C.Color = S
				C.Material = Enum.Material.Neon
				C.CastShadow = false

				if not C:FindFirstChild("ValtHitboxBox") then
					local T = Instance.new("SelectionBox")

					T.Name = "ValtHitboxBox"
					T.Adornee = C
					T.Color3 = S
					T.LineThickness = 0.05
					T.SurfaceColor3 = S
					T.SurfaceTransparency = 0.94
					T.Transparency = 0.45
					T.Parent = C
				end
			end)
		end
		local function S(C)
			if not N then
				return
			end

			local T = {}

			for W, W in ipairs(C:GetDescendants()) do
				if W:IsA("BasePart") then
					T[#T + 1] = W
					R(W)
				end
			end

			local W = C.DescendantAdded:Connect(function(_)
				if _:IsA("BasePart") then
					T[#T + 1] = _
					R(_)
				end
			end)

			task.spawn(function()
				local _, z = O()
				local O = {}
				local Y = os.clock()

				while N and C.Parent and os.clock() - Y < 3 do
					local C

					for Y = 1, #T do
						local q = T[Y]

						if q.Parent then
							if q.Size ~= f then
								R(q)
							end

							C = C or q.Position
						end
					end

					if C and _ then
						for f, f in ipairs(Players:GetPlayers()) do
							if f ~= LocalPlayer and f.Character and not O[f] then
								local i = f.Character:FindFirstChild("HumanoidRootPart")
								local P = f.Character:FindFirstChildOfClass("Humanoid")

								if i and P and P.Health > 0 and (i.Position - C).Magnitude <= 14 then
									O[f] = true
									pcall(function()
										if z then
											z:FireServer()
										end
									end)
									pcall(function()
										_:FireServer(i)
									end)
								end
							end
						end
					end

					RunService.Heartbeat:Wait()
				end

				pcall(function()
					W:Disconnect()
				end)
			end)
		end
		local function i(F)
			N = F

			for P, P in ipairs(j) do
				pcall(function()
					P:Disconnect()
				end)
			end

			j = {}

			if not F then
				return
			end

			for F, F in ipairs(E:GetTagged("ThrowingKnife")) do
				task.spawn(function()
					S(F)
				end)
			end

			j[#j + 1] = E:GetInstanceAddedSignal("ThrowingKnife"):Connect(function(E)
				S(E)
			end)
		end

		local E = v1001(v1147, "hitbox_expand", "Bigger Throw Hitbox", "Blows up YOUR thrown knife (shown thick red) and lands the hit from " .. 14 .. " studs out.", false, function(H)
			i(H)
			v998("Throw Hitbox", H and "Knife enlarged." or "Off.", "expand")
		end)

		u1190 = function()
			i(false)
			v57(E, false)
		end
	end)
	ValtSafe("L5541", function()
		local E = true
		local j = false
		local O = 0
		local R = nil

		local function C()
			local T = LocalPlayer.Character

			if not T then
				return nil
			end

			local W = T:FindFirstChild("Knife")

			if W then
				return W
			end

			local W = LocalPlayer.Backpack
			local _ = W and W:FindFirstChild("Knife")

			if _ then
				local W = T:FindFirstChildOfClass("Humanoid")

				if W then
					pcall(function()
						W:EquipTool(_)
					end)
					task.wait(0.3)
				end

				return T:FindFirstChild("Knife")
			end

			return v343()
		end
		local function k()
			local T = ValtX.aim.knifeOrigin()

			if T then
				return T
			end

			local T = LocalPlayer.Character
			local W = T and (T:FindFirstChild("RightHand") or T:FindFirstChild("Head") or T:FindFirstChild("HumanoidRootPart"))

			return W and W.Position or nil
		end
		local function T(W, _)
			local z = _ and _:FindFirstChild("HumanoidRootPart")

			if not z then
				return false
			end

			return not ValtX.aim.blocked(W, z.Position, _)
		end
		local function W()
			local _ = k()

			if not _ then
				return nil
			end

			local k, z

			for Y, Y in ipairs(Players:GetPlayers()) do
				if Y ~= LocalPlayer and Y.Character then
					local D = Y.Character:FindFirstChildOfClass("Humanoid")
					local V = Y.Character:FindFirstChild("HumanoidRootPart")

					if D and D.Health > 0 and V and ValtRound.alive(Y) and (not E or T(_, Y.Character)) then
						local D = (V.Position - _).Magnitude

						if not z or D < z then
							k, z = Y, D
						end
					end
				end
			end

			return k
		end
		local function D(V, k)
			local T = C()

			if not T then
				return false
			end

			local C = T:FindFirstChild("Handle")
			local _ = T:FindFirstChild("Events")
			local T = _ and _:FindFirstChild("KnifeThrown")

			if not C or not T then
				return false
			end

			local _ = ValtX.aim.shotPoint(V, C.Position, { knife = true }) or k

			return (pcall(function()
				T:FireServer(C.CFrame, CFrame.new(_))
			end))
		end
		local function V(k)
			local C = W()

			if not C then
				if R and not k then
					R.flash("No\nTarget", Color3.fromRGB(255, 80, 80))
				end

				return false, true
			end

			local k = C.Character and C.Character:FindFirstChild("HumanoidRootPart")

			if not k then
				return false
			end

			O = os.clock()

			local T = D(C, k.Position)

			if T then
				if R then
					R.flash("Thrown!", Color3.fromRGB(0, 255, 100))
				end

				v998("Knife Aimbot", "Threw at " .. C.Name, "sword")
			elseif R then
				R.flash("No\nKnife", Color3.fromRGB(255, 80, 80))
			end

			return T
		end

		v999(v1147, "Knife Throw")
		v1001(v1147, "knife_wallcheck", "Wall Check", "Only throw with a clear line to the target.", true, function(D)
			E = D
			v998("Wall Check", D and "On." or "Off.", "eye")
		end)
		v1004(v1147, "Throw Knife", "Throws at the nearest valid target right now.", function()
			V()
		end, "Primary")

		local E = nil

		local function D(k)
			j = k

			if E then
				pcall(task.cancel, E)
				E = nil
			end

			if not k then
				return
			end

			E = task.spawn(function()
				local E = 0

				while j and ValtState.gen == gen do
					local F = os.clock()

					if F >= E and F - O >= 0.6 then
						local k, _, f = pcall(V, true)

						if not k or f then
							E = F + 0.15
						end
					end

					RunService.Heartbeat:Wait()
				end
			end)
		end

		local E = v1001(v1147, "knife_aimbot", "Knife Aimbot (Auto Throw)", "Keeps throwing at the nearest target.", false, function(i)
			D(i)
			v998("Knife Aimbot", i and "Auto-throwing at the nearest target." or "Off.", "sword")
		end)

		ValtX.actions.throwKnife = function()
			task.spawn(V)
		end
		ValtX.actions.bindThrowButton = function(i)
			R = i
		end
		ValtX.knifeAimbotOff = function()
			D(false)
			v57(E, false)
		end
	end)
	ValtX.breathe()
	v999(v1009, "Gun")
	v1001(v1009, "she_autogun", "Auto Get Dropped Gun", "Grabs dropped guns the moment they appear.", false, function(p94)
		u37 = p94

		if p94 then
			task.spawn(function()
				v345()
			end)
		end
	end)
	v1004(v1009, "Grab Gun", "Grab the dropped gun and return to your position.", function()
		v558()
	end)
	v999(v1009, "Shooting")
	v1004(v1009, "Shoot Murderer", "Shoots the murderer with prediction. Keybind: R", function()
		v570()
	end, "Primary")
	ValtSafe("L5701", function()
		local E = false
		local f = nil
		local S = { "UpperTorso", "HumanoidRootPart", "Torso", "Head", "LowerTorso", "RightUpperArm", "LeftUpperArm", "RightUpperLeg", "LeftUpperLeg" }

		local function N()
			local j = LocalPlayer.Character

			if not j then
				return nil, nil
			end

			local O = j:FindFirstChild("Gun")

			if O then
				return O, j
			end

			local O = LocalPlayer.Backpack
			local i = O and O:FindFirstChild("Gun")

			if i then
				local O = j:FindFirstChildOfClass("Humanoid")

				if O then
					pcall(function()
						O:EquipTool(i)
					end)
				end

				return j:FindFirstChild("Gun"), j
			end

			return nil, j
		end
		local function i(j)
			local O = ValtX.aim.gunOrigin()
			local R = j.Character

			if not (O and R) then
				return nil
			end

			for j, j in ipairs(S) do
				local C = R:FindFirstChild(j)

				if C and not ValtX.aim.blocked(O, C.Position, R) then
					return C
				end
			end

			return nil
		end
		local function j(O)
			local R = N()
			local N, C = ValtX.aim.gunOrigin()
			local T = R and R:FindFirstChild("Shoot")

			if not (T and T:IsA("RemoteEvent") and N) then
				return false
			end

			local R = ValtX.aim.shotPoint(O, N, { order = S, wallCheck = true })

			if not R then
				return false
			end

			return (pcall(function()
				T:FireServer(C and C.WorldCFrame or CFrame.new(N), CFrame.new(R))
			end))
		end
		local function S(N)
			E = N

			if f then
				task.cancel(f)
				f = nil
			end

			if not N then
				return
			end

			local N = 0

			f = task.spawn(function()
				while E and ValtState.gen == gen do
					pcall(function()
						if os.clock() - N < 0.2 then
							return
						end

						if not ValtRound.amShooter() then
							return
						end

						local E = v568()

						if not E or not ValtRound.alive(E) then
							return
						end

						if i(E) then
							N = os.clock()
							j(E)
						end
					end)
					RunService.Heartbeat:Wait()
				end
			end)
		end

		local E = v1001(v1009, "auto_shoot", "Auto Shoot Murderer", "Fires at any exposed part of the murderer.", false, function(i)
			S(i)
			v998("Auto Shoot", i and "On - waiting for a clear shot." or "Off.", "crosshair")
		end)

		ValtX.autoShootOff = function()
			S(false)
			v57(E, false)
		end
	end)

	local function v1313()
		local u1314 = false
		local v1315
		local n14 = 0
		local u1317 = false
		local n15 = 0.15
		local t21 = {
			"UpperTorso",
			"HumanoidRootPart",
			"Torso",
			"LowerTorso"
		}

		local function v1320()
			local v1321 = v568() or v569()

			if v1321 and ValtRound.alive(v1321) then
				return v1321
			end

			return nil
		end
		local function v1322(p95)
			local Head = p95:FindFirstChild("Head")

			if Head then
				return Head
			end

			for _, v in ipairs(t21) do
				local v1326 = p95:FindFirstChild(v)

				if v1326 then
					return v1326
				end
			end

			return nil
		end
		local function v1327(p96)
			local Character2 = p96 and p96.Character

			if not Character2 then
				return nil
			end

			local v1329 = v1322(Character2)

			if not v1329 then
				return nil
			end

			if u1317 then
				local CurrentCamera2 = Workspace.CurrentCamera
				local Position = CurrentCamera2 and CurrentCamera2.CFrame.Position

				if not Position then
					return nil
				end

				if ValtX.aim.blocked(Position, v1329.Position, Character2) then
					return nil
				end
			end

			return v1329.Position
		end
		local function v1332(p97)
			local v1333 = ValtX.aim.knifeOrigin()

			if v1333 then
				return (ValtX.aim.shotPoint(p97, v1333, {
					knife = true,
					scale = 1 + n15
				}))
			end

			local t22 = {
				scale = 1 + n15
			}

			return (ValtX.aim.shotPoint(p97, ValtX.aim.gunOrigin(), t22))
		end

		local u1335

		local function v1336()
			if not u1335 then
				return
			end

			if u1314 then
				u1335.setActive(true)
				u1335.setLabel("Aimbot\nON", Color3.fromRGB(0, 255, 130))
			else
				u1335.setActive(false)
				u1335.resetLabel()
			end
		end
		local function v1337(p98)
			u1314 = p98
			pcall(function()
				RunService:UnbindFromRenderStep("ValtAimbot")
			end)

			if not p98 then
				v1336()

				return
			end

			v1336()

			local u1338
			local u1339

			RunService:BindToRenderStep("ValtAimbot", Enum.RenderPriority.Camera.Value + 1, function(p99)
				local CurrentCamera2 = Workspace.CurrentCamera

				if not CurrentCamera2 then
					return
				end

				local v1341 = v1320()
				local v1342 = v1341 and v1327(v1341)

				if not v1342 then
					u1338 = nil
					u1339 = nil

					return
				end

				local Position = CurrentCamera2.CFrame.Position

				if (v1342 - Position).Magnitude < 0.05 then
					return
				end

				if n14 <= 0 then
					u1338 = v1342
					u1339 = v1341
					CurrentCamera2.CFrame = CFrame.lookAt(Position, v1342)

					return
				end

				if u1339 ~= v1341 or not u1338 then
					u1338 = v1342
					u1339 = v1341
				end

				u1338 = u1338:Lerp(v1342, 1 - math.exp(-18 * p99))

				local Unit = (u1338 - Position).Unit
				local LookVector = CurrentCamera2.CFrame.LookVector

				if math.deg(math.acos(math.clamp(LookVector:Dot(Unit), -1, 1))) < 0.12 then
					return
				end

				local v1346 = LookVector:Lerp(Unit, 1 - math.exp(-(2.5 + 37.5 * (1 - math.clamp(n14, 0, 1))) * p99))
				local Unit2

				if v1346.Magnitude < 0.0001 then
					Unit2 = Unit
				else
					Unit2 = v1346.Unit
				end

				CurrentCamera2.CFrame = CFrame.lookAt(Position, Position + Unit2)
			end)
		end

		ValtAim = ValtAim or {}
		ValtAim.silent = ValtAim.silent or {
			on = false,
			fov = 0,
			mode = "Murderer",
			part = "Head",
			wallCheck = false,
			chance = 100,
			jitter = 0,
			maxRange = 300,
			predict = 1,
			saw = 0,
			hit = 0,
			why = "no shot yet"
		}

		local silent = ValtAim.silent

		silent.part = "Torso"

		local t23 = {
			Head = {
				"Head",
				"UpperTorso",
				"HumanoidRootPart",
				"Torso"
			},
			Torso = {
				"UpperTorso",
				"HumanoidRootPart",
				"Torso",
				"Head"
			},
			Nearest = {
				"HumanoidRootPart",
				"UpperTorso",
				"Head",
				"Torso",
				"LowerTorso"
			}
		}
		local t24 = {}
		local n16 = -1

		local function v1352(p100)
			if ValtRound.stamp ~= n16 then
				n16 = ValtRound.stamp
				t24 = {}
			end

			local v1353 = t24[p100]

			if v1353 then
				return v1353
			end

			local v1354 = u71(p100)

			if v1354 == "murderer" or v1354 == "sheriff" then
				t24[p100] = v1354
			end

			return v1354
		end
		local function v1355()
			local v1356 = u71(LocalPlayer)
			local t25 = {}

			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character then
					local Humanoid = player.Character:FindFirstChildOfClass("Humanoid")
					local HumanoidRootPart2 = player.Character:FindFirstChild("HumanoidRootPart")

					if Humanoid and HumanoidRootPart2 and Humanoid.Health > 0 and ValtRound.alive(player) then
						local v1362 = v1352(player)

						if v1356 == "murderer" or v1362 == "murderer" then
							t25[#t25 + 1] = {
								plr = player,
								char = player.Character,
								root = HumanoidRootPart2,
								hum = Humanoid
							}
						end
					end
				end
			end

			return t25
		end
		local function v1363(p101)
			local CurrentCamera2 = Workspace.CurrentCamera

			if not CurrentCamera2 then
				return 180
			end

			local v1365 = p101 - CurrentCamera2.CFrame.Position

			if v1365.Magnitude < 0.001 then
				return 0
			end

			return math.deg(math.acos(math.clamp(CurrentCamera2.CFrame.LookVector:Dot(v1365.Unit), -1, 1)))
		end
		local function v1366()
			local v1367 = ValtX.aim.knifeOrigin()

			if v1367 then
				return v1367, true
			end

			local v1368 = ValtX.aim.gunOrigin()

			if v1368 then
				return v1368, false
			end

			local CurrentCamera2 = Workspace.CurrentCamera

			return CurrentCamera2 and CurrentCamera2.CFrame.Position or nil, false
		end
		local function v1370(p102, p103)
			local v1371 = math.min(silent.maxRange, 295)
			local mode = silent.mode

			if mode == "Murderer" and (p103 or u71(LocalPlayer) == "murderer") then
				mode = "Closest to Crosshair"
			end

			local v1373
			local v1374

			for _, v in ipairs(v1355()) do
				local Position = v.root.Position
				local Magnitude = (Position - p102).Magnitude

				if Magnitude <= v1371 then
					local v1379 = v1363(Position)

					if silent.fov <= 0 or v1379 <= silent.fov then
						local Health

						if mode == "Closest to Crosshair" then
							Health = v1379
						elseif mode == "Closest to Me" then
							Health = Magnitude
						elseif mode == "Lowest Health" then
							Health = v.hum.Health
						elseif v1352(v.plr) == "murderer" then
							Health = Magnitude
						else
							Health = nil
						end

						if Health and (not v1374 or Health < v1374) then
							v1373 = v
							v1374 = Health
						end
					end
				end
			end

			return v1373
		end
		local function point()
			if silent.chance < 100 and silent.chance < math.random(100) then
				silent.why = "deliberately let this one miss"

				return nil
			end

			local v1382, v1383 = v1366()

			if not v1382 then
				silent.why = "no character"

				return nil
			end

			local v1384 = v1370(v1382, v1383)

			if not v1384 then
				silent.why = silent.fov > 0 and "nothing inside the FOV cone" or "no target"

				return nil
			end

			local v1385 = ValtX.aim.shotPoint(v1384.plr, v1382, {
				knife = v1383,
				scale = silent.predict or 1,
				order = t23[silent.part] or t23.Torso,
				wallCheck = silent.wallCheck
			})

			if not v1385 then
				silent.why = "target behind cover"

				return nil
			end

			if silent.jitter > 0 then
				v1385 += Vector3.new((math.random() - 0.5) * 2 * silent.jitter, (math.random() - 0.5) * 2 * silent.jitter, (math.random() - 0.5) * 2 * silent.jitter)
			end

			silent.why = "redirected to " .. v1384.plr.Name .. (v1383 and " (knife)" or "")

			return v1385
		end

		ValtAim.point = point
		task.spawn(function()
			if ValtExec.limited then
				silent.why = "not supported on " .. ValtExec.name

				return
			end

			local v1386

			for i = 1, 40 do
				v1386 = ValtX.mod.weaponService()

				if type(v1386) ~= "table" then
					task.wait(0.5)

					continue
				end

				break
			end

			if type(v1386) ~= "table" then
				ValtAim.silent.why = "WeaponService not found - wrong game?"

				return
			end

			rawset(v1386, "__ValtAimHooked", nil)

			local t26 = {}
			local n17 = -1
			local u1390
			local aimOriginals = ValtState.aimOriginals

			if type(aimOriginals) ~= "table" then
				aimOriginals = setmetatable({}, {
					__mode = "k"
				})
				ValtState.aimOriginals = aimOriginals
			end

			local aimWrappers = ValtState.aimWrappers

			if type(aimWrappers) ~= "table" then
				aimWrappers = setmetatable({}, {
					__mode = "k"
				})
				ValtState.aimWrappers = aimWrappers
			end

			local v1393 = aimOriginals[v1386]

			if not v1393 then
				v1393 = {}
				aimOriginals[v1386] = v1393
			end

			local t27 = {
				"GetMouseTargetCFrame",
				"GetTargetPosition"
			}

			local function v1395()
				local n18 = 0

				for _, v in ipairs(t27) do
					local v1399 = v1386[v]

					if type(v1399) == "function" and t26[v1399] == nil then
						local v1400

						if aimWrappers[v1399] then
							v1400 = v1393[v]
						else
							v1400 = v1399
							v1393[v] = v1399
						end

						if type(v1400) == "function" then
							local function v1401(...)
								local now = os.clock()

								if now - n17 < 0.03 then
									if not u1390 then
										return v1400(...)
									end

									return CFrame.new(u1390)
								end

								local result

								if silent.on then
									silent.saw += 1

									local ok

									ok, result = pcall(point)

									if not ok then
										silent.why = tostring(result)
										result = nil
									end

									if result then
										silent.hit += 1
									end
								elseif u1314 then
									local v1405 = v1320()
									local ok

									ok, result = pcall(function()
										return v1405 and v1332(v1405)
									end)

									if not ok then
										result = nil
									end
								end

								n17 = now
								u1390 = result

								if not result then
									return v1400(...)
								end

								return CFrame.new(result)
							end

							t26[v1401] = true
							aimWrappers[v1401] = true
							v1386[v] = v1401
							n18 += 1
						end
					end
				end

				return n18
			end

			local v1407 = v1395()

			silent.why = v1407 > 0 and "armed (" .. v1407 .. " aim paths hooked)" or "neither aim function was where it should be"
			task.spawn(function()
				while ValtState.gen == gen do
					task.wait(2)

					local v1408 = v1395()

					if v1408 > 0 then
						silent.why = "re-armed (" .. v1408 .. " path(s) had been replaced)"
					end
				end

				silent.on = false

				for _, v in ipairs(t27) do
					if t26[v1386[v]] and type(v1393[v]) == "function" then
						v1386[v] = v1393[v]
					end
				end
			end)
		end)

		local silent2 = ValtAim.silent

		silent2.on = false
		v999(v1009, "Aimbot")

		local v1412 = v1001(v1009, "aimbot", "Lock Aim on Murderer", "Holds the murderer's head. Keybind below.", false, function(p104)
			v1337(p104)
			v998("Aimbot", p104 and "Locked on the murderer." or "Off.", "crosshair")
		end)

		v1002(v1009, "aim_smooth", "Aim Smoothness", "0 snaps instantly. Higher glides in.", 0, 95, 0, 5, function(p105)
			n14 = p105 / 100
		end)
		v1002(v1009, "aim_lead", "Aim Lead", "Extra lead on top of your ping.", 0, 100, 15, 5, function(p106)
			n15 = p106 / 100
		end)
		v1001(v1009, "aim_visible", "Aim Visible Only", "Drops the lock while they're behind cover.", false, function(p107)
			u1317 = p107
		end)
		ValtX.actions.toggleAimbot = function()
			v1337(not u1314)
			v57(v1412, u1314)
			v998("Aimbot", u1314 and "Locked on the murderer." or "Off.", "crosshair")
		end
		ValtX.actions.bindAimButton = function(p108)
			u1335 = p108

			if p108 then
				v1336()
			end
		end
		v999(v1009, "Silent Aim")

		if ValtExec.limited then
			v1009:Paragraph({
				Title = "Silent Aim - not supported on " .. ValtExec.name,
				Desc = "It works by hooking MM2's WeaponService, and this executor cannot reach it. The aimbot lock above still works.",
				Image = "info",
				ImageSize = 18
			})
		else
			v1315 = v1001(v1009, "silent_aim", "Silent Aim", "Shots and knife throws hit without moving your camera.", false, function(p109)
				silent2.on = p109
				v998("Silent Aim", p109 and "Shots redirected." or "Off.", "crosshair")
			end)
			ValtX.actions.toggleSilent = function()
				silent2.on = not silent2.on
				v57(v1315, silent2.on)
				v998("Silent Aim", silent2.on and "Shots redirected." or "Off.", "crosshair")
			end
			v1002(v1009, "silent_predict", "Silent Aim Prediction", "Raise it if shots land behind runners.", 50, 200, 100, 5, function(p110)
				silent2.predict = p110 / 100
			end)
		end

		u1187 = function()
			v1337(false)
			v57(v1412, false)
			silent2.on = false
			v57(v1315, false)
		end
	end

	ValtX.breathe()
	ValtSafe("buildAimbot", v1313)
	ValtSafe("L6250", function()
		local E = false
		local S = false
		local N = nil
		local j = nil
		local O = {}

		local function R(C)
			local T, W = pcall(function()
				return C:Clone()
			end)

			if not T or not W then
				return nil
			end

			for C, C in ipairs(W:GetDescendants()) do
				if C:IsA("Script") or C:IsA("LocalScript") or C:IsA("ModuleScript") or C:IsA("RemoteEvent") or C:IsA("RemoteFunction") or C:IsA("BindableEvent") or C:IsA("BindableFunction") or C:IsA("Sound") or C:IsA("TouchTransmitter") then
					pcall(function()
						C:Destroy()
					end)
				elseif C:IsA("BasePart") then
					C.CanCollide, C.CanQuery, C.CanTouch, C.Massless, C.Anchored = false, false, false, true, false
				end
			end

			if W:IsA("BasePart") then
				W.CanCollide, W.CanQuery, W.CanTouch, W.Massless, W.Anchored = false, false, false, true, false
			end

			W.Name = "DualWieldHandle"

			return W
		end
		local function C()
			if j then
				pcall(function()
					j:Disconnect()
				end)
				j = nil
			end

			pcall(function()
				RunService:UnbindFromRenderStep("ValtDualLTM")
			end)

			if N then
				pcall(function()
					N:Destroy()
				end)
			end

			N = nil
		end
		local function T(W)
			for _, _ in ipairs(W:GetChildren()) do
				if _:IsA("Tool") then
					return _
				end
			end

			local _ = game:GetService("CollectionService")

			for z, z in ipairs({ "Weapon_Gun", "Weapon_Knife" }) do
				for Y, Y in ipairs(_:GetTagged(z)) do
					if Y:IsA("Tool") and Y:IsDescendantOf(W) then
						return Y
					end
				end
			end

			return nil
		end
		local function W(_)
			local z, Y, q, t, Q, a, X, m, c, A, x, n = _:GetComponents()

			return CFrame.new(-z, Y, q, t, -Q, -a, -X, m, c, -A, x, n)
		end
		local function _()
			C()

			if not E then
				return
			end

			local z = LocalPlayer.Character

			if not z then
				return
			end

			local Y = z:FindFirstChild("RightHand")
			local q = z:FindFirstChild("LeftHand")
			local t = T(z)
			local T = t and t:FindFirstChild("Handle")

			if not (Y and q and T) then
				return
			end

			local t = R(T)

			if not t then
				return
			end

			local R = Y.CFrame:ToObjectSpace(T.CFrame)

			if S then
				R = R * CFrame.Angles(0, math.rad(180), 0)
			end

			local T = Instance.new("Weld")

			T.Part0 = q
			T.Part1 = t
			T.C0 = R
			T.Parent = q
			t.Parent = z
			N = t

			local N = { { "LeftUpperArm", "LeftShoulder", "RightUpperArm", "RightShoulder" }, { "LeftLowerArm", "LeftElbow", "RightLowerArm", "RightElbow" }, { "LeftHand", "LeftWrist", "RightHand", "RightWrist" } }
			local R = {}

			for T, T in ipairs(N) do
				local N = z:FindFirstChild(T[1])
				local Y = z:FindFirstChild(T[3])
				local q = N and N:FindFirstChild(T[2])
				local N = Y and Y:FindFirstChild(T[4])

				if q and N then
					R[#R + 1] = { lc = q, rc = N }
				end
			end

			local N = {}

			if t:IsA("BasePart") then
				table.insert(N, t)
			end

			for T, T in ipairs(t:GetDescendants()) do
				if T:IsA("BasePart") then
					table.insert(N, T)
				end
			end

			j = RunService.Stepped:Connect(function()
				if not (t.Parent and z.Parent) then
					return
				end

				for j, j in ipairs(R) do
					if j.lc.Parent and j.rc.Parent then
						pcall(function()
							j.lc.Transform = W(j.rc.Transform)
						end)
					end
				end
			end)
			pcall(function()
				RunService:UnbindFromRenderStep("ValtDualLTM")
			end)
			RunService:BindToRenderStep("ValtDualLTM", Enum.RenderPriority.Last.Value, function()
				for k, k in ipairs(N) do
					if k.Parent and k.LocalTransparencyModifier ~= 0 then
						k.LocalTransparencyModifier = 0
					end
				end
			end)
		end
		local function k(N)
			for j, j in ipairs(O) do
				pcall(function()
					j:Disconnect()
				end)
			end

			table.clear(O)
			O[#O + 1] = N.ChildAdded:Connect(function(j)
				if j:IsA("Tool") then
					task.wait(0.15)
					_()
				end
			end)
			O[#O + 1] = N.ChildRemoved:Connect(function(N)
				if N:IsA("Tool") then
					_()
				end
			end)
			_()
		end
		local function N(j)
			E = j

			if not j then
				for j, j in ipairs(O) do
					pcall(function()
						j:Disconnect()
					end)
				end

				table.clear(O)
				C()

				return
			end

			if LocalPlayer.Character then
				k(LocalPlayer.Character)
			end
		end

		ValtConns.dualRespawn = LocalPlayer.CharacterAdded:Connect(function(V)
			if ValtState.gen ~= gen then
				ValtConns.dualRespawn:Disconnect()

				return
			end

			if E then
				task.wait(0.3)
				k(V)
			end
		end)
		v999(v1009, "Dual Wield")

		local V = v1001(v1009, "dual_wield", "Dual Wield (Gun + Knife)", "Copy of your weapon in the off hand. Visual only.", false, function(F)
			N(F)
			v998("Dual Wield", F and "Off-hand copy on." or "Off.", "swords")
		end)

		v1001(v1009, "dual_flip", "Flip Off-Hand", "If the off-hand weapon points the wrong way, turn this on.", false, function(D)
			S = D

			if E then
				_()
			end
		end)
		u1188 = function()
			N(false)
			v57(V, false)
		end
	end)
	ValtX.breathe()
	v999(v1008, "Players")
	t18.murderer = v1001(v1008, "esp_murderer", "Murderer ESP", "Shows the murderer in red.", false, function(p111)
		t1.murderer = p111
		v76()
	end)
	t18.sheriff = v1001(v1008, "esp_sheriff", "Sheriff ESP", "Sheriff and hero, in blue.", false, function(p112)
		t1.sheriff = p112
		v76()
	end)
	t18.innocent = v1001(v1008, "esp_innocent", "Innocent ESP", "Shows unarmed players in green.", false, function(p113)
		t1.innocent = p113
		v76()
	end)
	v999(v1008, "Chams Look")
	v1002(v1008, "esp_fill", "Body Transparency", "How see-through the body fill is.", 0, 100, 78, 2, function(p114)
		ValtESP.fillT = p114 / 100
		ValtESP.repaint()
	end)
	v1002(v1008, "esp_glow", "Outline Brightness", "Brighter outline for dark maps.", 0, 100, 45, 5, function(p115)
		ValtESP.glow = p115 / 100
		ValtESP.repaint()
	end)
	v999(v1008, "Role Source")
	ValtSafe("L6467", function()
		local E = v1008:Paragraph({ Title = "Round data: checking...", Desc = "Reading roles straight out of MM2 round table.", Image = "radar", ImageSize = 18 })

		task.spawn(function()
			while task.wait(2) do
				if ValtState.gen ~= gen then
					break
				end

				local H = ValtRound.live()
				local k = { Murderer = 0, Sheriff = 0, Hero = 0, Innocent = 0 }

				if H then
					for P, P in ipairs(Players:GetPlayers()) do
						local V = ValtRound.rawRole(P)

						if V and k[V] then
							k[V] = k[V] + 1
						end
					end
				end

				pcall(function()
					E:SetTitle(H and "Round data: live" or "Round data: waiting")
					E:SetDesc(H and ("%d murderer | %d sheriff | %d hero | %d innocent"):format(k.Murderer, k.Sheriff, k.Hero, k.Innocent) or "No roles assigned yet - nothing to read until the round is set up.")
				end)
			end
		end)
		v1003(v1008, "esp_role_source", "Where Roles Come From", "Round data knows roles instantly; Weapons waits for a tool.", { "Auto", "Round data", "Weapons" }, "Auto", function(E)
			local i = E

			if type(E) == "table" then
				i = E[1]
			end

			roleSource = (i == "Round data" and "round") or (i == "Weapons" and "tools") or "auto"
			v76()
			v998("Role Source", "Now using: " .. tostring(i), "radar")
		end)
	end)
	v999(v1008, "World")
	t18.gunDrop = v1001(v1008, "esp_gundrop", "Gun Drop ESP", "Marks dropped guns in yellow with a label.", false, function(p116)
		u36 = p116
		v287()
	end)
	t18.trap = v1001(v1008, "esp_trap", "Trap ESP", "Marks bear traps, mines and floor traps in orange.", false, function(p117)
		t1.trap = p117
		v75()
	end)
	v1186 = v1001(v1008, "esp_coins", "Coin ESP", "Fills the nearest coins with yellow, visible through walls.", false, function(p118)
		u41 = p118
		ValtESP.setupCoinESP()
	end)
	ValtSafe("L6530", function()
		local E = false
		local j, O = nil, nil
		local R = {}
		local C, T, W = {}, 1, 0

		local function _(z)
			W = W + 1
			C[W] = z
		end
		local function z()
			return math.min(ValtExec.profile.xrayBudget, mobile and 220 or 600)
		end
		local function S(Y)
			if R[Y] ~= nil or not Y.Parent or Y.Transparency >= 0.1 then
				return
			end

			local q = Y

			while q.Parent and q.Parent ~= Workspace do
				q = q.Parent
			end

			if q.Parent ~= Workspace or not q:IsA("Model") then
				return
			end

			if Players:GetPlayerFromCharacter(q) then
				return
			end

			if Y:FindFirstAncestor("CoinContainer") then
				return
			end

			R[Y] = Y.Transparency
			Y.Transparency = 0.72
		end
		local function Y()
			for q, q in ipairs(Workspace:GetChildren()) do
				if q:IsA("Model") and not Players:GetPlayerFromCharacter(q) then
					for D, D in ipairs(q:GetDescendants()) do
						if D:IsA("BasePart") then
							_(D)
						end
					end
				end
			end
		end
		local function D()
			for q, t in pairs(R) do
				if q and q.Parent then
					q.Transparency = t
				end

				R[q] = nil
			end
		end
		local function q(t)
			E = t

			if j then
				task.cancel(j)
				j = nil
			end

			if O then
				O:Disconnect()
				O = nil
			end

			C, T, W = {}, 1, 0

			if not t then
				D()

				return
			end

			O = Workspace.DescendantAdded:Connect(function(D)
				if E and D:IsA("BasePart") then
					_(D)
				end
			end)
			j = task.spawn(function()
				local D = false

				while E and ValtState.gen == gen do
					local E = v70()

					if E ~= D then
						D = E

						for E in pairs(R) do
							if not E.Parent then
								R[E] = nil
							end
						end

						Y()
					end

					if T <= W then
						local E, i = 0, z()

						while T <= W and E < i do
							local i = C[T]

							C[T] = nil
							T = T + 1
							E = E + 1
							pcall(S, i)
						end

						if T > W then
							C, T, W = {}, 1, 0
						end

						task.wait()
					else
						task.wait(0.5)
					end
				end

				if O then
					O:Disconnect()
					O = nil
				end
			end)
		end

		t18.xray = v1001(v1008, "xray", "X-Ray (see through walls)", "See players and coins through walls.", false, function(E)
			q(E)
			v998("X-Ray", E and "Walls thinned." or "Off.", "eye")
		end)
		u1189 = function()
			q(false)
			v57(t18.xray, false)
		end
	end)
end

ValtSafe("L6632", function()
	local E = ValtX.esp
	local T = { murderer = Color3.fromRGB(255, 60, 60), sheriff = Color3.fromRGB(70, 150, 255), innocent = Color3.fromRGB(80, 235, 120) }
	local W, _, z
	local Y = {}

	local function q()
		if W and W.Parent then
			return W
		end

		W = Instance.new("ScreenGui")
		W.Name = "ValtOverlayESP"
		W.ResetOnSpawn = false
		W.IgnoreGuiInset = true
		W.DisplayOrder = 99999
		W.Parent = ValtX.btn.root()

		return W
	end
	local function t(Q)
		local a = Y[Q]

		if not a then
			return
		end

		if a.tag then
			a.tag:Destroy()
		end

		if a.tracer then
			a.tracer:Destroy()
		end

		if a.box then
			a.box:Destroy()
		end

		Y[Q] = nil
	end
	local function Q()
		for a in pairs(Y) do
			t(a)
		end

		if _ then
			_.Visible = false
		end
	end
	local function a(X)
		local m = Y[X]

		if m and m.tag and m.tag.Parent then
			return m
		end

		local c = q()
		local A = Instance.new("Frame")

		A.Name = "Tag_" .. X.Name
		A.AnchorPoint = Vector2.new(0.5, 1)
		A.BackgroundTransparency = 1
		A.Size = UDim2.fromOffset(160, 46)
		A.Visible = false
		A.ZIndex = 3
		A.Parent = c

		local x = Instance.new("TextLabel")

		x.BackgroundTransparency = 1
		x.Position = UDim2.new(0, 0, 0, 0)
		x.Size = UDim2.new(1, 0, 0, 16)
		x.Font = Enum.Font.GothamBold
		x.TextSize = 13
		x.TextStrokeTransparency = 0.3
		x.TextStrokeColor3 = Color3.new(0, 0, 0)
		x.ZIndex = 4
		x.Parent = A

		local n = Instance.new("TextLabel")

		n.BackgroundTransparency = 1
		n.Position = UDim2.new(0, 0, 0, 16)
		n.Size = UDim2.new(1, 0, 0, 14)
		n.Font = Enum.Font.GothamMedium
		n.TextSize = 11
		n.TextColor3 = Color3.fromRGB(215, 220, 235)
		n.TextStrokeTransparency = 0.45
		n.TextStrokeColor3 = Color3.new(0, 0, 0)
		n.ZIndex = 4
		n.Parent = A

		local b = Instance.new("Frame")

		b.AnchorPoint = Vector2.new(0.5, 0)
		b.Position = UDim2.new(0.5, 0, 0, 32)
		b.Size = UDim2.fromOffset(64, 4)
		b.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
		b.BorderSizePixel = 0
		b.ZIndex = 4
		b.Parent = A
		Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)

		local d = Instance.new("Frame")

		d.Size = UDim2.new(1, 0, 1, 0)
		d.BackgroundColor3 = Color3.fromRGB(80, 235, 120)
		d.BorderSizePixel = 0
		d.ZIndex = 5
		d.Parent = b
		Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)

		local L = Instance.new("Frame")

		L.Name = "Tracer_" .. X.Name
		L.AnchorPoint = Vector2.new(0.5, 0.5)
		L.BorderSizePixel = 0
		L.BackgroundTransparency = 0.1
		L.Visible = false
		L.ZIndex = 2
		L.Parent = c
		Instance.new("UICorner", L).CornerRadius = UDim.new(1, 0)

		local Z = Instance.new("UIGradient")

		Z.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.85), NumberSequenceKeypoint.new(0.55, 0.35), NumberSequenceKeypoint.new(1, 0) })
		Z.Parent = L

		local Z = Instance.new("Frame")

		Z.Name = "Box_" .. X.Name
		Z.AnchorPoint = Vector2.new(0.5, 0.5)
		Z.BackgroundTransparency = 1
		Z.BorderSizePixel = 0
		Z.Visible = false
		Z.ZIndex = 2
		Z.Parent = c
		Instance.new("UICorner", Z).CornerRadius = UDim.new(0, 3)

		local c = Instance.new("UIStroke")

		c.Thickness = 1.5
		c.Transparency = 0
		c.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		c.Parent = Z
		m = { tag = A, name = x, info = n, bar = b, barFill = d, tracer = L, box = Z, boxStroke = c }
		Y[X] = m

		return m
	end
	local function X()
		if _ and _.Parent then
			return _
		end

		local m = q()

		_ = Instance.new("TextLabel")
		_.Name = "MurdererArrow"
		_.AnchorPoint = Vector2.new(0.5, 0.5)
		_.BackgroundTransparency = 1
		_.Size = UDim2.fromOffset(46, 46)
		_.Font = Enum.Font.GothamBold
		_.Text = "➤"
		_.TextSize = 34
		_.TextColor3 = T.murderer
		_.TextStrokeTransparency = 0.25
		_.TextStrokeColor3 = Color3.new(0, 0, 0)
		_.Visible = false
		_.ZIndex = 6
		_.Parent = m

		return _
	end

	local m, c = {}, -1.0

	local function A(x)
		if ValtRound.stamp ~= c then
			c = ValtRound.stamp
			m = {}
		end

		local c = m[x]

		if c then
			return c
		end

		local c = u71(x)

		if c == "murderer" or c == "sheriff" then
			m[x] = c
		end

		return c
	end
	local function D(m, c, x, n, b, d)
		local L, Z = n - c, b - x
		local n = math.sqrt(L * L + Z * Z)

		if n < 1 then
			m.Visible = false

			return
		end

		if m.BackgroundColor3 ~= d then
			m.BackgroundColor3 = d
		end

		m.Size = UDim2.fromOffset(math.floor(n), E.tracerThickness)
		m.Position = UDim2.fromOffset(math.floor(c + L / 2), math.floor(x + Z / 2))
		m.Rotation = math.deg(math.atan2(Z, L))
		m.Visible = true
	end
	local function m()
		local c = Workspace.CurrentCamera

		if not c then
			return
		end

		local j = E.names or E.tracers or E.arrow or E.box

		if not j then
			Q()

			return
		end

		local j = c.ViewportSize
		local x = LocalPlayer.Character
		local n = x and x:FindFirstChild("HumanoidRootPart")
		local x, b

		if E.tracerFrom == "Top" then
			x, b = j.X / 2, 0
		elseif E.tracerFrom == "Middle" then
			x, b = j.X / 2, j.Y / 2
		else
			x, b = j.X / 2, j.Y
		end

		local d = nil
		local L = os.clock()

		for Z, Z in ipairs(Players:GetPlayers()) do
			if Z == LocalPlayer then
				continue
			end

			local C = Z.Character
			local g = C and C:FindFirstChild("HumanoidRootPart")
			local e = C and C:FindFirstChildOfClass("Humanoid")

			if not (g and e and e.Health > 0) then
				t(Z)

				continue
			end

			local C = A(Z)

			if C == "murderer" then
				d = g.Position
			end

			if not t1[C] then
				t(Z)

				continue
			end

			local F = n and (g.Position - n.Position).Magnitude or 0

			if E.maxDistance > 0 and F > E.maxDistance then
				t(Z)

				continue
			end

			local A, n = c:WorldToViewportPoint(g.Position + Vector3.new(0, 3, 0))
			local G = c:WorldToViewportPoint(g.Position - Vector3.new(0, 3, 0))
			local g = A.Z <= 0
			local u = a(Z)
			local a = T[C] or Color3.fromRGB(220, 220, 220)

			if E.names then
				u.tag.Position = UDim2.fromOffset(math.floor(A.X), math.floor(A.Y))

				if not u.textAt or L - u.textAt >= 0.1 then
					u.textAt = L

					if u.name.Text ~= Z.Name then
						u.name.Text = Z.Name
					end

					if u.nameColour ~= a then
						u.nameColour = a
						u.name.TextColor3 = a
					end

					local T = {}

					if E.showRole then
						T[#T + 1] = C:upper()
					end

					if E.showDistance then
						T[#T + 1] = ("%dm"):format(math.floor(F))
					end

					if E.showHealth then
						T[#T + 1] = ("%d hp"):format(math.floor(e.Health))
					end

					local F = table.concat(T, "  |  ")

					if u.info.Text ~= F then
						u.info.Text = F
					end

					u.info.Visible = #T > 0

					local F = math.clamp(e.Health / math.max(1, e.MaxHealth), 0, 1)

					u.bar.Visible = E.showHealthBar

					if u.frac ~= F then
						u.frac = F
						u.barFill.Size = UDim2.new(F, 0, 1, 0)
						u.barFill.BackgroundColor3 = Color3.fromRGB(240, 70, 70):Lerp(Color3.fromRGB(80, 235, 120), F)
					end
				end

				u.tag.Visible = not g and n
			else
				u.tag.Visible = false
			end

			if E.tracers then
				local F, C = G.X, G.Y

				if g then
					F, C = j.X - F, j.Y - C
				end

				F = math.clamp(F, 2, j.X - 2)
				C = math.clamp(C, 2, j.Y - 2)
				D(u.tracer, x, b, F, C, a)
			else
				u.tracer.Visible = false
			end

			if E.box then
				local D = math.abs(G.Y - A.Y) * 0.88
				local F = D * 0.55

				u.box.Size = UDim2.fromOffset(math.floor(F), math.floor(D))
				u.box.Position = UDim2.fromOffset(math.floor((A.X + G.X) / 2), math.floor((A.Y + G.Y) / 2))

				if u.boxColour ~= a or u.boxGlow ~= ValtESP.glow then
					u.boxColour, u.boxGlow = a, ValtESP.glow
					u.boxStroke.Color = ValtESP.brighten(a, ValtESP.glow)
				end

				local F = E.boxThickness or 1.5

				if u.boxStroke.Thickness ~= F then
					u.boxStroke.Thickness = F
				end

				u.box.Visible = D > 4 and not g and n
			else
				u.box.Visible = false
			end
		end

		for D in pairs(Y) do
			if D.Parent == nil then
				t(D)
			end
		end

		if E.arrow and d then
			local D = X()
			local _, F = c:WorldToViewportPoint(d)

			if F then
				D.Visible = false
			else
				local F = c.CFrame:PointToObjectSpace(d)
				local C, T = F.X, -F.Y
				local F = math.sqrt(C * C + T * T)

				if F < 1e-3 then
					C, T, F = 0, 1, 1
				end

				local Y, a = j.X / 2, j.Y / 2
				local X = math.min(j.X, j.Y) * 0.38

				D.Position = UDim2.fromOffset(math.floor(Y + C / F * X), math.floor(a + T / F * X))
				D.Rotation = math.deg(math.atan2(T, C))
				D.Visible = true
			end
		elseif _ then
			_.Visible = false
		end
	end
	local function D(F)
		if z then
			z:Disconnect()
			z = nil
		end

		if not F then
			Q()

			if W then
				W:Destroy()
				W = nil
			end

			_ = nil

			return
		end

		q()

		local F = 0

		z = RunService.RenderStepped:Connect(function()
			if ValtState.gen ~= gen then
				if z then
					z:Disconnect()
					z = nil
				end

				return
			end

			local H = mobile and 2 or ValtExec.profile.overlaySkip

			if H > 1 then
				F += 1

				if F % H ~= 0 then
					return
				end
			end

			local H, V = pcall(m)

			if not H then
				warn("[Valt/OverlayESP] " .. tostring(V))
			end
		end)
	end
	local function H()
		D(E.names or E.tracers or E.arrow or E.box)
	end

	ValtConns.overlayLeave = Players.PlayerRemoving:Connect(function(V)
		if ValtState.gen ~= gen then
			ValtConns.overlayLeave:Disconnect()

			return
		end

		t(V)
	end)
	v999(v1008, "Name Tags")
	E.namesToggle = v1001(v1008, "esp_names", "Name ESP", "Floating label over each player with whatever you switch on below.", false, function(V)
		E.names = V
		H()
		v998("Name ESP", V and "On." or "Off.", "tag")
	end)
	v1001(v1008, "esp_show_role", "Show Role", "MURDERER, SHERIFF or INNOCENT.", true, function(V)
		E.showRole = V
	end)
	v1001(v1008, "esp_show_dist", "Show Distance", "How far away they are, in studs.", true, function(V)
		E.showDistance = V
	end)
	v1001(v1008, "esp_show_hp", "Show Health", "Their current hit points.", false, function(V)
		E.showHealth = V
	end)
	v1001(v1008, "esp_show_bar", "Health Bar", "Green to red strip under the name.", true, function(V)
		E.showHealthBar = V
	end)
	v999(v1008, "Boxes")
	E.boxToggle = v1001(v1008, "esp_box", "Box ESP", "2D outline box around each player.", false, function(V)
		E.box = V
		H()
		v998("Box ESP", V and "On." or "Off.", "square")
	end)
	v1002(v1008, "esp_box_thick", "Box Thickness", "How heavy the outline is.", 1, 5, 2, 1, function(V)
		E.boxThickness = V
	end)
	v999(v1008, "Tracers")
	E.tracerToggle = v1001(v1008, "esp_tracers", "Tracer Lines", "A line from the screen to each player.", false, function(V)
		E.tracers = V
		H()
		v998("Tracers", V and "On." or "Off.", "move-right")
	end)
	v1003(v1008, "esp_tracer_from", "Tracer Origin", "Where the lines start from.", { "Bottom", "Middle", "Top" }, "Bottom", function(i)
		E.tracerFrom = i
	end)
	v1002(v1008, "esp_tracer_thick", "Tracer Thickness", nil, 1, 6, 2, 1, function(i)
		E.tracerThickness = i
	end)
	v999(v1008, "Murderer Arrow")
	E.arrowToggle = v1001(v1008, "esp_arrow", "Off-Screen Murderer Arrow", "Points at the murderer whenever he is outside your view.", false, function(i)
		E.arrow = i
		H()
		v998("Murderer Arrow", i and "Watching." or "Off.", "navigation")
	end)
	v999(v1008, "Range")
	v1002(v1008, "esp_max_dist", "Max Distance", "Hides the overlay past this many studs. 0 means no limit.", 0, 2000, 0, 50, function(i)
		E.maxDistance = i
	end)
	ValtX.esp.set = function(i, V)
		local F = { names = E.namesToggle, tracers = E.tracerToggle, arrow = E.arrowToggle, box = E.boxToggle }

		if F[i] == nil and E[i] == nil then
			return false
		end

		E[i] = V and true or false
		v57(F[i], E[i])
		H()

		return true
	end
	ValtX.esp.offAll = function()
		E.names, E.tracers, E.arrow, E.box = false, false, false, false
		v57(E.namesToggle, false)
		v57(E.tracerToggle, false)
		v57(E.arrowToggle, false)
		v57(E.boxToggle, false)
		D(false)
	end
end)
v1004(v1008, "Refresh ESP", "Rebuilds every highlight by hand.", function()
	v76()
	v287()
	v75()
	ValtESP.setupCoinESP()
	v998("ESP refreshed", "All highlights rebuilt.", "refresh-cw")
end)
ValtX.breathe()
v999(v1014, "Crosshair")

do
	t15.toggle = v1001(v1014, "crosshair_on", "Show Crosshair", "Draws the picked icon on your cursor.", false, function(p119)
		t15.on = p119
		v991()
		v998("Crosshair", p119 and t15.style .. " on." or "Off.", "crosshair")
	end)
end

v999(v1014, "Pick One")
ValtSafe("L7114", function()
	local E = false

	local function H()
		if E then
			return
		end

		E = true
		v992(v1014)
	end

	local E

	pcall(function()
		E = v1014.ContainerFrame
	end)

	if E then
		E:GetPropertyChangedSignal("Visible"):Connect(function()
			if E.Visible then
				H()
			end
		end)

		if E.Visible then
			H()
		end
	else
		task.delay(2, H)
	end
end)
ValtSafe("L7135", function()
	local E = { "Default", "White", "Black", "Red", "Green", "Cyan", "Yellow", "Pink", "Purple", "Orange" }
	local F = { White = Color3.fromRGB(255, 255, 255), Black = Color3.fromRGB(0, 0, 0), Red = Color3.fromRGB(255, 45, 45), Green = Color3.fromRGB(60, 255, 90), Cyan = Color3.fromRGB(60, 230, 255), Yellow = Color3.fromRGB(255, 225, 60), Pink = Color3.fromRGB(255, 120, 200), Purple = Color3.fromRGB(180, 120, 255), Orange = Color3.fromRGB(255, 150, 50) }

	v1003(v1014, "crosshair_colour", "Colour", "Paints any crosshair. Default keeps each one's own colour.", E, "Default", function(E)
		t15.tint = F[E]

		if t15.on then
			v991()
		end

		if t15.repaintGrid then
			t15.repaintGrid()
		end
	end)
end)
v1002(v1014, "crosshair_size", "Size", "How many pixels across it is.", 16, 160, 48, 2, function(p120)
	t15.size = p120

	if t15.on then
		v991()
	end
end)
v999(v1014, "Spin")
v1001(v1014, "crosshair_spin", "Spin", "Rotates the crosshair on the spot.", false, function(p121)
	t15.spin = p121

	if not p121 and t15.icon then
		t15.icon.Rotation = 0
	end
end)
v1002(v1014, "crosshair_speed", "Spin Speed", "Degrees per second. 360 = one full turn a second.", 10, 720, 120, 10, function(p122)
	t15.speed = p122
end)

if not mobile then
	v999(v1014, "Position")
	v1001(v1014, "crosshair_follow", "Follow Cursor", "Off pins it to the middle of the screen instead.", true, function(p123)
		t15.follow = p123
	end)
	v1001(v1014, "crosshair_hide_mouse", "Hide Game Cursor", "Removes the Roblox pointer so only your crosshair shows.", true, function(p124)
		t15.hideCursor = p124
		UserInputService.MouseIconEnabled = not (p124 and t15.on)
	end)
end

ValtX.breathe()
v999(v1010, "Teleport to Role")

do
	v1004(v1010, "Teleport to Murderer", "Puts you right on top of the murderer.", function()
		local v1597 = v72("murderer")

		if v1597 then
			v573(v1597)
		else
			v998("ValtHub", "No murderer found!", "triangle-alert")
		end
	end)
end

v1004(v1010, "Teleport to Sheriff", "Puts you right on top of the sheriff.", function()
	local v1598 = v72("sheriff")

	if v1598 then
		v573(v1598)
	else
		v998("ValtHub", "No sheriff found!", "triangle-alert")
	end
end)
v999(v1010, "Map Teleports")
v1004(v1010, "Teleport to Map", "Drops you at a random map spawn.", function()
	v574()
end)
v1004(v1010, "Teleport to Lobby", "Sends you back to the lobby.", function()
	v575()
end)
v999(v1010, "Player Fling")

do
	local function v1599()
		local t28 = {}

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				t28[#t28 + 1] = player.Name
			end
		end

		table.sort(t28)

		return t28
	end

	local v1603 = v1599()
	local u1604 = v1603[1]
	local v1605 = v1010:Dropdown({
		Title = "Player",
		Values = v1603,
		Value = v1603[1] or "",
		Multi = false,
		Callback = function(p125)
			u1604 = p125
		end
	})

	local function v1606()
		local v1607 = v1599()

		pcall(function()
			v1605:Refresh(v1607)
		end)

		if not u1604 or not Players:FindFirstChild(u1604) then
			u1604 = v1607[1]

			if u1604 then
				pcall(function()
					v1605:Select(u1604)
				end)
			end
		end
	end

	ValtConns.flingAdd = Players.PlayerAdded:Connect(function()
		if ValtState.gen ~= gen then
			ValtConns.flingAdd:Disconnect()

			return
		end

		task.wait(0.5)
		v1606()
	end)
	ValtConns.flingGone = Players.PlayerRemoving:Connect(function()
		if ValtState.gen ~= gen then
			ValtConns.flingGone:Disconnect()

			return
		end

		task.wait(0.5)
		v1606()

		if u1604 and not Players:FindFirstChild(u1604) then
			u1604 = nil
		end
	end)
	v1004(v1010, "Refresh Player List", "Re-reads who is in the server.", function()
		v1606()
		v998("ValtHub", #v1599() .. " players found.", "users")
	end)
	v1004(v1010, "Fling Selected", "Flings the player picked above. You teleport back after.", function()
		if not u1604 then
			v998("ValtHub", "Pick a player from the list first!", "triangle-alert")

			return
		end

		local v1608 = Players:FindFirstChild(u1604)

		if not v1608 or not v1608.Character then
			v998("ValtHub", u1604 .. " is not in the server anymore.", "triangle-alert")
			v1606()

			return
		end

		v572(v1608)
		v998("ValtHub", "Flung " .. v1608.Name .. "!", "zap")
	end, "Primary")
end

v999(v1010, "Fling by Role")
v1004(v1010, "Fling Murderer", "Finds whoever holds the knife and flings them.", function()
	local v1609 = v72("murderer")

	if v1609 then
		v572(v1609)
		v998("ValtHub", "Flung the murderer (" .. v1609.Name .. ")!", "zap")
	else
		v998("ValtHub", "No murderer found!", "triangle-alert")
	end
end)
v1004(v1010, "Fling Sheriff", "Finds whoever holds the gun and flings them.", function()
	local v1610 = v72("sheriff")

	if v1610 then
		v572(v1610)
		v998("ValtHub", "Flung the sheriff (" .. v1610.Name .. ")!", "zap")
	else
		v998("ValtHub", "No sheriff found!", "triangle-alert")
	end
end)
ValtX.breathe()
v999(v1011, "Movement")

do
	v62 = v1001(v1011, "noclip", "No Clip", "Walk through walls and floors. Keybind: N", false, function(p126)
		v64(p126)
	end)
end

v61 = v1001(v1011, "fly", "Fly", "WASD plus Space and Shift. Keybind: F", false, function(p127)
	if u65 then
		return
	end

	v66(p127)
end)
v1002(v1011, "fly_speed", "Fly Speed", "Studs per second while flying.", 1, 200, 50, 1, function(p128)
	n6 = p128
end)
ValtSafe("L7325", function()
	local E = nil

	local function f(S)
		if E then
			E:Disconnect()
			E = nil
		end

		if not S then
			return
		end

		E = UserInputService.JumpRequest:Connect(function()
			local E = LocalPlayer.Character
			local F = E and E:FindFirstChildOfClass("Humanoid")

			if F and not u54 then
				F:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end)
	end

	local E = v1001(v1011, "inf_jump", "Infinite Jump", "Jump again in mid-air, as many times as you like.", false, function(i)
		f(i)
		v998("Infinite Jump", i and "On." or "Off.", "arrow-up")
	end)

	u1021 = function()
		f(false)
		v57(E, false)
	end
end)
ValtSafe("L7354", function()
	local E = false

	local function J()
		if E then
			return false
		end

		E = true

		local k = LocalPlayer.Character
		local P = k and k:FindFirstChildOfClass("Humanoid")
		local f = k and k:FindFirstChild("HumanoidRootPart")

		if not (P and f) then
			v998("Bomb Jump", "No character.", "triangle-alert")
			E = false

			return false
		end

		local S = LocalPlayer.Backpack:FindFirstChild("FakeBomb") or k:FindFirstChild("FakeBomb")

		if not S then
			local N, j = pcall(function()
				return ReplicatedStorage.Remotes.Extras.ReplicateToy:InvokeServer("FakeBomb")
			end)

			if N and j then
				task.wait()
				j.Parent = LocalPlayer.Backpack
				S = j
			end
		end

		if not S then
			v998("Bomb Jump", "You don't own the Prank Bomb.", "triangle-alert")
			E = false

			return false
		end

		local D

		for H, H in ipairs(k:GetChildren()) do
			if H:IsA("Tool") and H ~= S then
				D = H

				break
			end
		end

		P:EquipTool(S)
		task.wait()

		local H = S:FindFirstChild("Remote")

		if H then
			pcall(function()
				H:FireServer(CFrame.new(f.Position - Vector3.new(0, 3, 0)), 50)
			end)
		end

		pcall(function()
			P:ChangeState(Enum.HumanoidStateType.Jumping)
		end)
		task.wait(0.15)

		if D then
			pcall(function()
				P:EquipTool(D)
			end)
		else
			pcall(function()
				P:UnequipTools()
			end)
		end

		E = false

		return true
	end

	local E = nil

	local function D()
		task.spawn(function()
			local H = J()

			if E then
				if H then
					E.flash("Dropped", Color3.fromRGB(0, 255, 100), 1.5)
				else
					E.flash("No\nBomb", Color3.fromRGB(255, 80, 80), 1.5)
				end
			end
		end)
	end

	v1004(v1011, "Bomb Jump", "Drops the Prank Bomb at your feet. Jump as it goes off.", D)
	ValtX.actions.bombJump = D
	ValtX.actions.bindBombButton = function(i)
		E = i
	end
end)
v999(v1011, "Character")
v1002(v1011, "walk_speed", "Walk Speed", "The speed E boosts you to. Only applied while the boost is already on.", 1, 100, 32, 1, function(p129)
	walkSpeed = p129

	local Character2 = LocalPlayer.Character
	local Humanoid = Character2 and Character2:FindFirstChild("Humanoid")

	if Humanoid and Humanoid.WalkSpeed > 16.01 then
		Humanoid.WalkSpeed = p129
	end
end)
ValtSafe("L7459", function()
	local E = 70
	local J

	J = RunService.RenderStepped:Connect(function()
		if ValtState.gen ~= gen then
			J:Disconnect()

			return
		end

		if E == 70 then
			return
		end

		local D = Workspace.CurrentCamera

		if D and E ~= 70 and D.FieldOfView ~= E then
			D.FieldOfView = E
		end
	end)
	v1002(v1011, "fov", "FOV", "Camera field of view. 70 is default.", 30, 120, 70, 1, function(D)
		E = D

		local E = Workspace.CurrentCamera

		if E then
			E.FieldOfView = D
		end
	end)
end)

do
	local connection3
	local connection4
	local Position
	local t29 = {}

	ValtX.antiFlingToggle = v1001(v1011, "anti_fling", "ANTIFLING", "Neutralises flingers and snaps you back if you get flung.", false, function(p130)
		if connection3 then
			connection3:Disconnect()
			connection3 = nil
		end

		if connection4 then
			connection4:Disconnect()
			connection4 = nil
		end

		ValtConns.antiFlingDetect = nil
		ValtConns.antiFlingRestore = nil
		t29 = {}
		Position = nil

		if not p130 then
			return
		end

		local n19 = 0

		connection3 = RunService.Heartbeat:Connect(function()
			if ValtState.gen ~= gen then
				connection3:Disconnect()

				return
			end

			local now = os.clock()

			if now < n19 then
				return
			end

			n19 = now + 0.05

			for _, player in ipairs(Players:GetPlayers()) do
				local Character2 = player ~= LocalPlayer and player.Character
				local PrimaryPart = Character2 and Character2.PrimaryPart

				if PrimaryPart and (PrimaryPart.AssemblyAngularVelocity.Magnitude > 50 or PrimaryPart.AssemblyLinearVelocity.Magnitude > 100) then
					if not t29[player.Name] then
						t29[player.Name] = true
						v998("ValtHub", player.Name .. " is trying to fling!", "triangle-alert")
					end

					for _, descendant in ipairs(Character2:GetDescendants()) do
						if descendant:IsA("BasePart") then
							descendant.CanCollide = false
							descendant.AssemblyAngularVelocity = Vector3.zero
							descendant.AssemblyLinearVelocity = Vector3.zero
							descendant.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0)
						end
					end
				end
			end
		end)
		connection4 = RunService.Heartbeat:Connect(function()
			if ValtState.gen ~= gen then
				connection4:Disconnect()

				return
			end

			if u571 then
				return
			end

			local Character2 = LocalPlayer.Character
			local PrimaryPart = Character2 and Character2.PrimaryPart

			if not PrimaryPart then
				return
			end

			if PrimaryPart.AssemblyLinearVelocity.Magnitude > 250 or PrimaryPart.AssemblyAngularVelocity.Magnitude > 250 then
				PrimaryPart.AssemblyLinearVelocity = Vector3.zero
				PrimaryPart.AssemblyAngularVelocity = Vector3.zero

				if Position then
					PrimaryPart.CFrame = CFrame.new(Position)
				end
			else
				Position = PrimaryPart.Position
			end
		end)
		ValtConns.antiFlingDetect = connection3
		ValtConns.antiFlingRestore = connection4
	end)
	ValtX.antiFlingOff = function()
		if connection3 then
			connection3:Disconnect()
			connection3 = nil
		end

		if connection4 then
			connection4:Disconnect()
			connection4 = nil
		end

		ValtConns.antiFlingDetect = nil
		ValtConns.antiFlingRestore = nil
		v57(ValtX.antiFlingToggle, false)
	end
end

v1004(v1011, "Reset Walkspeed", "Puts walk speed back to 16.", function()
	local Humanoid = Character and Character:FindFirstChild("Humanoid")

	if Humanoid then
		Humanoid.WalkSpeed = 16
		n7 = 16
	end

	u59 = false
	v998("ValtHub", "Walk speed reset to 16!", "refresh-cw")
end)
v1004(v1011, "Kill Character", "Kills you so you respawn.", function()
	if Character then
		local Humanoid = Character:FindFirstChild("Humanoid")

		if Humanoid then
			Humanoid.Health = 0
		end
	end
end)
ValtLoading(68)
ValtX.breathe()
ValtLook = {
	avatar = {
		on = false,
		keep = true,
		name = "",
		userId = nil
	},
	anim = {
		pack = "Default",
		keep = true,
		ids = nil,
		stamp = 0
	},
	baseline = nil,
	busy = false
}
ValtSafe("L7587", function()
	local E = ValtLook
	local V = { Zombie = { idle = { 616158929, 616160636 }, walk = 616168032, run = 616163682, jump = 616161997, fall = 616157476, climb = 616156119, swim = 616165109, swimidle = 616166655 }, Ghost = { idle = { 616006778, 616008087 }, walk = 616013216, run = 616010382, jump = 616008936, fall = 616005863, climb = 616003713, swim = 616011509, swimidle = 616012453 }, Robot = { idle = { 616088211, 616089559 }, walk = 616095330, run = 616091570, jump = 616090535, fall = 616087089 }, Stylish = { idle = { 616136790, 616138447 }, walk = 616146177, run = 616140816, jump = 616139451, fall = 616134815, climb = 616133594, swimidle = 616143378 }, Superhero = { idle = { 616111295, 616113536 }, walk = 616122287, run = 616117076, jump = 616115533, fall = 616108001, climb = 616104706 }, Cartoony = { idle = { 742637544, 742638445 }, walk = 742640026, run = 742638842, jump = 742637942, fall = 742637151, climb = 742636889, swim = 742639220, swimidle = 742639812 }, Astronaut = { idle = { 891621366, 891633237 }, run = 891636393, jump = 891627522, fall = 891617961, climb = 891609353, swim = 891639666, swimidle = 891663592 }, Ninja = { idle = { 656117400, 656118341 }, walk = 656121766, run = 656118852, jump = 656117878, fall = 656115606, climb = 656114359, swim = 656119721 }, Mage = { idle = { 707742142, 707855907 }, walk = 707897309, run = 707861613, jump = 707853694, fall = 707829716, climb = 707826056, swim = 707876443 }, Pirate = { idle = { 750781874, 750782770 }, walk = 750785693, run = 750783738, jump = 750782230, fall = 750780242, climb = 750779899 }, Bubbly = { idle = { 910004836, 910009958 }, walk = 910034870, run = 910025107, jump = 910016857, fall = 910001910, swim = 910028158, swimidle = 910030921 }, Elder = { idle = { 845397899, 845400520 }, walk = 845403856, run = 845386501, jump = 845398858, fall = 845396048, climb = 845392038, swim = 845401742, swimidle = 845403127 }, Vampire = { idle = { 1083445855, 1083450166 }, walk = 1083473930, run = 1083462077, jump = 1083455352, fall = 1083443587, climb = 1083439238, swimidle = 1083464683 }, Werewolf = { idle = { 1083195517, 1083214717 }, walk = 1083178339, run = 1083216690, jump = 1083182000, fall = 1083189019, climb = 1083182000 }, Toy = { idle = { 782841498, 782845736 }, walk = 782843345, run = 782842708, fall = 782846423, climb = 782843869, swimidle = 782846423 }, Knight = { idle = { 657595757, 657568135 }, walk = 657552124, run = 656118852, jump = 658409194, fall = 657600338, climb = 658360781, swim = 657600338, swimidle = 657564596 } }

	E.packs = V

	local F = { "Default" }

	for J in pairs(V) do
		F[#F + 1] = J
	end

	table.sort(F, function(J, k)
		if J == "Default" then
			return true
		end

		if k == "Default" then
			return false
		end

		return J < k
	end)
	E.packNames = F

	local F = { idle = 2, walk = 1, run = 1, jump = 1, fall = 1, climb = 1, swim = 1, swimidle = 1 }

	local function J()
		local k = LocalPlayer.Character

		return k and k:FindFirstChildOfClass("Humanoid"), k
	end
	local function k(P, f)
		if not P then
			return nil
		end

		local S = P:FindFirstChild("Animate")

		if S then
			return S
		end

		local S, N = pcall(function()
			return P:WaitForChild("Animate", f or 5)
		end)

		return S and N or nil
	end
	local function P(f)
		local S = {}

		for N, N in ipairs(f:GetChildren()) do
			if N:IsA("Animation") then
				S[#S + 1] = N
			end
		end

		table.sort(S, function(f, N)
			return f.Name < N.Name
		end)

		return S
	end
	local function f(S)
		if type(S) == "string" then
			if S:match("^rbxassetid://") then
				return S
			end

			local N = S:match("(%d+)")

			return N and ("rbxassetid://" .. N) or S
		end

		return "rbxassetid://" .. tostring(S)
	end
	local function S(N)
		if E.baseline then
			return
		end

		local j = {}

		for O in pairs(F) do
			local F = N:FindFirstChild(O)

			if F then
				local N = {}

				for R, R in ipairs(P(F)) do
					N[#N + 1] = R.AnimationId
				end

				j[O] = N
			end
		end

		E.baseline = j
	end
	local function F(N)
		local j, O = J()

		if not j or not O then
			return false, "no character"
		end

		local J = k(O)

		if not J then
			return false, "no Animate script"
		end

		S(J)

		for k, S in pairs(N) do
			local N = J:FindFirstChild(k)

			if N then
				local k = P(N)
				local N = (type(S) == "table") and S or { S }

				for S, O in ipairs(k) do
					local k = N[S] or N[#N]

					if k then
						pcall(function()
							O.AnimationId = f(k)
						end)
					end
				end
			end
		end

		local k = j:FindFirstChildOfClass("Animator")

		if k then
			pcall(function()
				for S, S in ipairs(k:GetPlayingAnimationTracks()) do
					S:Stop(0)
				end
			end)
		end

		pcall(function()
			J.Disabled = true
			task.wait()
			J.Disabled = false
		end)
		E.anim.stamp = os.clock()

		return true
	end

	E.writeAnims = F

	local function J(k)
		local S = "https://catalog.roblox.com/v1/bundles/" .. tostring(k) .. "/details"
		local k
		local N = (syn and syn.request) or (http and http.request) or http_request or request

		if N then
			local j, O = pcall(N, { Url = S, Method = "GET" })

			if j and type(O) == "table" then
				k = O.Body
			end
		end

		if not k then
			local N, j = pcall(function()
				return game:HttpGet(S)
			end)

			if N then
				k = j
			end
		end

		if type(k) ~= "string" or k == "" then
			return nil, "no response from the catalog"
		end

		local S = { "swimidle", "climb", "swim", "walk", "fall", "jump", "idle", "run" }
		local N = {}

		local function j(O, R)
			local C = O:lower()

			for O, O in ipairs(S) do
				if not N[O] and C:find(O, 1, true) then
					N[O] = tonumber(R)

					return
				end
			end
		end

		for S, O in k:gmatch("\"id\":(%d+),\"name\":\"([^\"]-)\"") do
			j(O, S)
		end

		if not next(N) then
			for S, O in k:gmatch("\"name\":\"([^\"]-)\",\"id\":(%d+)") do
				j(S, O)
			end
		end

		if not next(N) then
			return nil, "no animations in that bundle"
		end

		if N.idle then
			N.idle = { N.idle, N.idle }
		end

		return N
	end

	function E.setPack(k)
		E.anim.pack = k

		if k == "Default" then
			E.anim.ids = nil

			if E.baseline then
				local S = {}

				for N, j in pairs(E.baseline) do
					S[N] = j
				end

				return F(S)
			end

			return true
		end

		local S = V[k]

		if not S then
			return false, "unknown pack"
		end

		E.anim.ids = S

		return F(S)
	end
	function E.setCustomPack(V)
		local k, S = J(V)

		if not k then
			return false, S
		end

		E.anim.pack = "Custom " .. tostring(V)
		E.anim.ids = k

		return F(k)
	end

	local function V()
		local J = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

		return J and J.RigType or Enum.HumanoidRigType.R15
	end

	local J

	local function k(S)
		if not J then
			local N, j = pcall(function()
				return Players:GetHumanoidDescriptionFromUserId(LocalPlayer.UserId)
			end)

			if N and j then
				J = j
			end
		end

		local N = J

		if not N then
			return true
		end

		if N.Shirt ~= 0 and not S:FindFirstChildOfClass("Shirt") then
			return false
		end

		if N.Pants ~= 0 and not S:FindFirstChildOfClass("Pants") then
			return false
		end

		if N.Torso ~= 0 then
			local J = S:FindFirstChild("UpperTorso") or S:FindFirstChild("Torso")

			if J and J:IsA("MeshPart") and (J.MeshId == nil or J.MeshId == "") then
				return false
			end
		end

		return true
	end
	local function J()
		if ValtState.originalLook then
			return
		end

		local S = LocalPlayer.Character

		if not S then
			return
		end

		if not k(S) then
			return
		end

		local k = { accessories = {}, meshes = {} }
		local N = S:FindFirstChild("Head")

		if N then
			local j = N:FindFirstChildOfClass("Decal")

			if j then
				k.face = j.Texture
			end

			local j = N:FindFirstChildOfClass("SpecialMesh")

			if j then
				k.headMesh = j:Clone()
			end

			k.headSize = N.Size
			k.headColor = N.Color

			if N:IsA("MeshPart") then
				k.headMeshPart = N:Clone()
			end
		end

		local N = S:FindFirstChildOfClass("Shirt")

		if N then
			k.shirt = N.ShirtTemplate
		end

		local N = S:FindFirstChildOfClass("Pants")

		if N then
			k.pants = N.PantsTemplate
		end

		local N = S:FindFirstChildOfClass("BodyColors")

		if N then
			k.bodyColors = {}

			for j, j in ipairs({ "HeadColor3", "TorsoColor3", "LeftArmColor3", "RightArmColor3", "LeftLegColor3", "RightLegColor3" }) do
				k.bodyColors[j] = N[j]
			end
		end

		local N = S:FindFirstChildOfClass("Humanoid")

		if N then
			for j, j in ipairs({ "BodyDepthScale", "BodyHeightScale", "BodyWidthScale", "HeadScale", "BodyProportionScale", "BodyTypeScale" }) do
				local O = N:FindFirstChild(j)

				if O then
					k["scale_" .. j] = O.Value
				end
			end
		end

		for N, N in ipairs(S:GetChildren()) do
			if N:IsA("Accessory") or N:IsA("Accoutrement") then
				k.accessories[#k.accessories + 1] = N:Clone()
			elseif N:IsA("CharacterMesh") then
				k.meshes[#k.meshes + 1] = N:Clone()
			elseif N:IsA("MeshPart") then
				k[N.Name .. "_mesh"] = N:Clone()
			end
		end

		ValtState.originalLook = k
	end

	function E.resnapshot()
		ValtState.originalLook = nil
		pcall(J)

		return ValtState.originalLook ~= nil
	end
	function copyBodyShape(k, S)
		local N = S:FindFirstChildOfClass("Humanoid")

		if not N then
			return 0
		end

		local j = {}

		if typeof(k) == "Instance" then
			for O, O in ipairs(k:GetChildren()) do
				if O:IsA("MeshPart") then
					j[O.Name] = O
				end
			end
		elseif type(k) == "table" then
			for O, R in pairs(k) do
				if typeof(R) == "Instance" and R:IsA("MeshPart") then
					j[O] = R
				end
			end
		end

		if not next(j) then
			return 0
		end

		local O = { "BodyDepthScale", "BodyHeightScale", "BodyWidthScale", "HeadScale", "BodyProportionScale", "BodyTypeScale" }
		local R = (typeof(k) == "Instance") and k:FindFirstChildOfClass("Humanoid") or nil

		for C, C in ipairs(O) do
			local O

			if R then
				local T = R:FindFirstChild(C)

				O = T and T.Value
			elseif type(k) == "table" then
				O = k["scale_" .. C]
			end

			if O then
				local k = N:FindFirstChild(C)

				if k then
					pcall(function()
						k.Value = O
					end)
				end
			end
		end

		pcall(function()
			N.AutomaticScalingEnabled = false
		end)

		local k = 0

		for O, R in pairs(j) do
			local j = S:FindFirstChild(O)

			if j and j:IsA("MeshPart") then
				pcall(function()
					j:ApplyMesh(R)
				end)
				pcall(function()
					j.Size = R.Size
				end)
				pcall(function()
					j.Color = R.Color
				end)
				pcall(function()
					j.Transparency = R.Transparency
				end)

				for S, S in ipairs(R:GetChildren()) do
					if S:IsA("Attachment") then
						local O = j:FindFirstChild(S.Name)

						if not O then
							O = Instance.new("Attachment")
							O.Name = S.Name
							O.Parent = j
						end

						pcall(function()
							O.CFrame = S.CFrame
						end)
					end
				end

				k = k + 1
			end
		end

		pcall(function()
			N:BuildRigFromAttachments()
		end)

		return k
	end

	local function k(S)
		for N, N in ipairs(S:GetChildren()) do
			if N:IsA("Accessory") or N:IsA("Accoutrement") or N:IsA("CharacterMesh") or N:IsA("ShirtGraphic") or N:IsA("Shirt") or N:IsA("Pants") then
				N:Destroy()
			end
		end
	end

	local S = { HatAttachment = { "Head", CFrame.new(0, 0.6, 0) }, HairAttachment = { "Head", CFrame.new(0, 0.6, 0) }, FaceFrontAttachment = { "Head", CFrame.new(0, 0, -0.6) }, FaceCenterAttachment = { "Head", CFrame.new(0, 0, -0.6) }, NeckAttachment = { "Torso", CFrame.new(0, 1, 0) }, BackAttachment = { "Torso", CFrame.new(0, 0, 0.6) }, BodyBackAttachment = { "Torso", CFrame.new(0, 0, 0.6) }, WaistAttachment = { "Torso", CFrame.new(0, -1.0, 0) }, BodyWaistAttachment = { "Torso", CFrame.new(0, -1.0, 0) }, LeftCollarAttachment = { "Torso", CFrame.new(-0.6, 1, 0) }, RightCollarAttachment = { "Torso", CFrame.new(0.6, 1, 0) }, LeftShoulderAttachment = { "Torso", CFrame.new(-1.0, 1, 0) }, RightShoulderAttachment = { "Torso", CFrame.new(1, 1, 0) } }

	local function N(j, O)
		local R = O:FindFirstChild("Handle")

		if not R or not R:IsA("BasePart") then
			return false
		end

		local C = R:FindFirstChildOfClass("Attachment")
		local T

		if C then
			for W, W in ipairs(j:GetChildren()) do
				if W:IsA("BasePart") then
					local _ = W:FindFirstChild(C.Name)

					if _ and _:IsA("Attachment") then
						T = _

						break
					end
				end
			end
		end

		local W

		if T then
			W, _ = T.Parent, T.CFrame
		else
			local T = (C and S[C.Name]) or { "Head", CFrame.new(0, 0.6, 0) }

			W, _ = j:FindFirstChild(T[1]), T[2]

			if not W then
				W, _ = j:FindFirstChild("Head"), CFrame.new(0, 0.6, 0)
			end
		end

		if not W then
			return false
		end

		O.Parent = j
		R.CanCollide = false
		R.Anchored = false
		R.Massless = true
		pcall(function()
			R.CustomPhysicalProperties = nil
		end)

		local S = C and C.CFrame or CFrame.new()

		pcall(function()
			R.CFrame = W.CFrame * _ * S:Inverse()
		end)

		local j = Instance.new("Weld")

		j.Name = "ValtLookWeld"
		j.Part0 = R
		j.Part1 = W
		j.C0 = S
		j.C1 = _
		j.Parent = R

		return true
	end
	local function S(j)
		local O, R = pcall(function()
			return Players:CreateHumanoidModelFromUserId(j)
		end)

		if O and R then
			return R
		end

		local O

		pcall(function()
			O = Players:GetHumanoidDescriptionFromUserId(j)
		end)

		if O then
			local j

			if pcall(function()
				j = Players:CreateHumanoidModelFromDescription(O, V())
			end) and j then
				return j
			end
		end

		return nil, "could not build that avatar"
	end
	local function V(j)
		local O = LocalPlayer.Character

		if not O or not O:FindFirstChildOfClass("Humanoid") then
			return false, "no character"
		end

		J()
		k(O)

		local R, C = O:FindFirstChild("Head"), j:FindFirstChild("Head")

		if R and C then
			local T = R:FindFirstChildOfClass("Decal")

			if T then
				T:Destroy()
			end

			local T = C:FindFirstChildOfClass("Decal")

			if T then
				pcall(function()
					T:Clone().Parent = R
				end)
			end

			if not R:IsA("MeshPart") then
				local T = R:FindFirstChildOfClass("SpecialMesh")
				local W = C:FindFirstChildOfClass("SpecialMesh")

				if T then
					T:Destroy()
				end

				if W then
					pcall(function()
						W:Clone().Parent = R
					end)
				end

				pcall(function()
					R.Size = C.Size
				end)
			elseif C:IsA("MeshPart") then
				pcall(function()
					R.TextureID = C.TextureID
				end)
			end

			pcall(function()
				R.Color = C.Color
			end)
		end

		copyBodyShape(j, O)

		local R = 0

		for C, C in ipairs(j:GetChildren()) do
			if C:IsA("Shirt") or C:IsA("Pants") or C:IsA("ShirtGraphic") or C:IsA("CharacterMesh") then
				pcall(function()
					C:Clone().Parent = O
				end)
			elseif C:IsA("BodyColors") then
				local j = O:FindFirstChildOfClass("BodyColors")

				if j then
					for T, T in ipairs({ "HeadColor3", "TorsoColor3", "LeftArmColor3", "RightArmColor3", "LeftLegColor3", "RightLegColor3" }) do
						pcall(function()
							j[T] = C[T]
						end)
					end
				else
					pcall(function()
						C:Clone().Parent = O
					end)
				end
			elseif C:IsA("Accessory") or C:IsA("Accoutrement") then
				pcall(function()
					if N(O, C:Clone()) then
						R = R + 1
					end
				end)
			end
		end

		E.avatar.worn = R

		return true
	end
	local function j()
		local O = LocalPlayer.Character
		local R = ValtState.originalLook

		if not O then
			return false, "no character"
		end

		if not R then
			return false, "nothing saved to go back to"
		end

		k(O)

		local k = O:FindFirstChild("Head")

		if k then
			local C = k:FindFirstChildOfClass("Decal")

			if C then
				C:Destroy()
			end

			if R.face then
				local C = Instance.new("Decal")

				C.Name = "face"
				C.Texture = R.face
				C.Parent = k
			end

			if not k:IsA("MeshPart") then
				local C = k:FindFirstChildOfClass("SpecialMesh")

				if C then
					C:Destroy()
				end

				if R.headMesh then
					pcall(function()
						R.headMesh:Clone().Parent = k
					end)
				end

				if R.headSize then
					pcall(function()
						k.Size = R.headSize
					end)
				end
			end

			if R.headColor then
				pcall(function()
					k.Color = R.headColor
				end)
			end
		end

		local k = {}

		for C, C in ipairs(O:GetChildren()) do
			if C:IsA("MeshPart") then
				local T = R[C.Name .. "_mesh"]

				if T then
					k[C.Name] = T
				end
			end
		end

		for C, T in pairs(R) do
			if type(C) == "string" and C:sub(1, 6) == "scale_" then
				k[C] = T
			end
		end

		if next(k) then
			copyBodyShape(k, O)
		end

		if R.shirt then
			local k = Instance.new("Shirt")

			k.Name = "Shirt"
			k.ShirtTemplate = R.shirt
			k.Parent = O
		end

		if R.pants then
			local k = Instance.new("Pants")

			k.Name = "Pants"
			k.PantsTemplate = R.pants
			k.Parent = O
		end

		if R.bodyColors then
			local k = O:FindFirstChildOfClass("BodyColors") or Instance.new("BodyColors")

			for C, T in pairs(R.bodyColors) do
				pcall(function()
					k[C] = T
				end)
			end

			k.Parent = O
		end

		for k, k in ipairs(R.meshes or {}) do
			pcall(function()
				k:Clone().Parent = O
			end)
		end

		local k = 0

		for C, C in ipairs(R.accessories or {}) do
			pcall(function()
				if N(O, C:Clone()) then
					k = k + 1
				end
			end)
		end

		E.avatar.worn = k

		return true
	end

	local k = 0

	local function N(O)
		k = k + 1

		local R = k
		local C, T = S(O)

		if not C then
			return false, T
		end

		if R ~= k then
			pcall(function()
				C:Destroy()
			end)

			return true
		end

		local S, O = V(C)

		pcall(function()
			C:Destroy()
		end)

		return S, O
	end

	E.applyUser = N

	function E.setAvatar(V)
		V = (V or ""):gsub("^%s+", ""):gsub("%s+$", "")

		if V == "" then
			return false, "type a username first"
		end

		local S = tonumber(V)

		if not S then
			local O, R = pcall(function()
				return Players:GetUserIdFromNameAsync(V)
			end)

			if O and type(R) == "number" then
				S = R
			end
		end

		if not S then
			for O, O in ipairs(Players:GetPlayers()) do
				if O.Name:lower() == V:lower() or O.DisplayName:lower() == V:lower() then
					S = O.UserId

					break
				end
			end
		end

		if not S then
			return false, "no Roblox account called " .. V
		end

		J()

		if not ValtState.originalLook then
			return false, "your avatar has not finished loading yet - give it a moment"
		end

		local H, O = N(S)

		if not H then
			return false, O
		end

		E.avatar.on = true
		E.avatar.name = V
		E.avatar.userId = S

		if E.anim.ids then
			task.spawn(function()
				F(E.anim.ids)
			end)
		end

		return true
	end
	function E.restoreAvatar()
		E.avatar.on = false
		E.avatar.userId = nil
		k = k + 1

		local H, V = j()

		if not H then
			H, V = N(LocalPlayer.UserId)
		end

		if not H then
			return false, V
		end

		if E.anim.ids then
			task.spawn(function()
				F(E.anim.ids)
			end)
		end

		return true
	end

	task.spawn(function()
		for H = 1, 45 do
			if ValtState.gen ~= gen then
				return
			end

			if ValtState.originalLook then
				return
			end

			pcall(J)
			task.wait(1)
		end
	end)
	ValtConns.lookSnapshot = LocalPlayer.CharacterAdded:Connect(function()
		if ValtState.gen ~= gen then
			ValtConns.lookSnapshot:Disconnect()

			return
		end

		if E.avatar.on then
			return
		end

		task.spawn(function()
			local H = nil

			for V = 1, 20 do
				task.wait(1)

				if ValtState.gen ~= gen or E.avatar.on then
					return
				end

				local V = ValtState.originalLook

				ValtState.originalLook = nil
				pcall(J)
				H = ValtState.originalLook

				if H then
					return
				end

				ValtState.originalLook = V
			end
		end)
	end)

	function E.reapply()
		if E.busy then
			return
		end

		E.busy = true
		task.spawn(function()
			local H = LocalPlayer.Character

			if H then
				pcall(function()
					H:WaitForChild("Humanoid", 10)
				end)
				pcall(function()
					H:WaitForChild("Animate", 10)
				end)
			end

			task.wait(0.6)

			if E.avatar.on and E.avatar.keep and E.avatar.userId then
				pcall(function()
					N(E.avatar.userId)
				end)
				task.wait(0.2)

				if (E.avatar.worn or 0) > 0 then
					for H = 1, 3 do
						task.wait(1.5)

						local H = LocalPlayer.Character

						if not H then
							break
						end

						local V = 0

						for J, J in ipairs(H:GetChildren()) do
							if J:IsA("Accessory") then
								V = V + 1
							end
						end

						if V >= E.avatar.worn then
							break
						end

						pcall(function()
							N(E.avatar.userId)
						end)
					end
				end
			end

			E.baseline = nil

			if E.anim.keep and E.anim.ids then
				pcall(function()
					F(E.anim.ids)
				end)
			end

			E.busy = false
		end)
	end

	ValtConns.lookRespawn = LocalPlayer.CharacterAdded:Connect(function()
		if ValtState.gen ~= gen then
			ValtConns.lookRespawn:Disconnect()

			return
		end

		E.reapply()
	end)
	task.spawn(function()
		while task.wait(3) do
			if ValtState.gen ~= gen then
				break
			end

			if E.anim.keep and E.anim.ids and not E.busy then
				local i = LocalPlayer.Character
				local D = i and i:FindFirstChild("Animate")
				local i = D and D:FindFirstChild("walk")

				if i then
					local D = P(i)
					local i = E.anim.ids.walk

					if D[1] and i and D[1].AnimationId ~= f(i) then
						pcall(function()
							F(E.anim.ids)
						end)
					end
				end
			end
		end
	end)
end)
v999(v1011, "Avatar (only you see it)")
ValtSafe("L8341", function()
	local E = ""
	local J = {}
	local k = nil

	local function P()
		if not (isfile and readfile) then
			return
		end

		pcall(function()
			if not isfile("ValtHubHub/saved_avatars.json") then
				return
			end

			local f = game:GetService("HttpService"):JSONDecode(readfile("ValtHubHub/saved_avatars.json"))

			if type(f) ~= "table" then
				return
			end

			J = {}

			for S, S in ipairs(f) do
				if type(S) == "string" and S ~= "" then
					J[#J + 1] = S
				end
			end
		end)
	end
	local function f()
		if not writefile then
			return
		end

		pcall(function()
			if isfolder and makefolder and not isfolder("ValtHubHub") then
				makefolder("ValtHubHub")
			end

			writefile("ValtHubHub/saved_avatars.json", game:GetService("HttpService"):JSONEncode(J))
		end)
	end

	P()

	local P = v1011:Input({ Title = "Copy Avatar From", Desc = v1000("Roblox username. Anyone - they do not have to be in the server."), Placeholder = "username", Value = "", Callback = function(H)
		E = H or ""
	end })
	local H

	local function S()
		if #J == 0 then
			return { "(nothing saved yet)" }
		end

		local N = {}

		for j, O in ipairs(J) do
			N[j] = O
		end

		return N
	end
	local function N()
		pcall(function()
			H:Refresh(S())
		end)

		if k and not table.find(J, k) then
			k = nil
		end
	end

	H = v1011:Dropdown({ Title = "Saved Avatars", Values = S(), Value = J[1] or "(nothing saved yet)", Multi = false, Callback = function(S)
		if not S or S == "(nothing saved yet)" then
			k = nil

			return
		end

		k = S
		E = S
		pcall(function()
			P:Set(S)
		end)
	end })
	v1004(v1011, "Save Avatar", "Adds the username above to the list.", function()
		local P = (E or ""):gsub("^%s+", ""):gsub("%s+$", "")

		if P == "" then
			v998("Avatar", "Type a username in the box first.", "triangle-alert")

			return
		end

		for S, S in ipairs(J) do
			if S:lower() == P:lower() then
				v998("Avatar", P .. " is already on the list.", "info")

				return
			end
		end

		J[#J + 1] = P
		f()
		N()
		pcall(function()
			H:Select(P)
		end)
		v998("Avatar", "Saved " .. P .. ".", "user-round-check")
	end)
	v1004(v1011, "Remove Saved Avatar", "Takes whichever one is picked in the list back off it.", function()
		if not k then
			v998("Avatar", "Pick one from the list first.", "triangle-alert")

			return
		end

		for P, S in ipairs(J) do
			if S == k then
				table.remove(J, P)

				break
			end
		end

		local P = k

		k = nil
		f()
		N()
		pcall(function()
			H:Select(J[1] or "(nothing saved yet)")
		end)
		v998("Avatar", "Removed " .. P .. ".", "trash-2")
	end)
	v1004(v1011, "Apply Avatar", "Become that account's avatar.", function()
		v998("Avatar", "Looking that up...", "user-round-search")
		task.spawn(function()
			local H, J = ValtLook.setAvatar(E)

			if H then
				v998("Avatar", "You are now wearing the avatar of " .. ValtLook.avatar.name .. ".", "user-round-check")
			else
				v998("Avatar", J or "Did not work.", "user-round-x")
			end
		end)
	end, "Primary")
	v1004(v1011, "Restore My Avatar", "Puts your own avatar back, from the copy taken when you joined.", function()
		task.spawn(function()
			local E, H = ValtLook.restoreAvatar()

			v998("Avatar", E and "Back to your own avatar." or (H or "Did not work."), E and "user-round-check" or "user-round-x")
		end)
	end)
	v1004(v1011, "Re-save My Look", "Use this if Restore gives you a default character.", function()
		task.spawn(function()
			if ValtLook.avatar.on then
				v998("Avatar", "Restore your own avatar first, or you would save the copied one.", "triangle-alert")

				return
			end

			ValtState.originalLook = nil

			local E = ValtLook.resnapshot()

			v998("Avatar", E and "Saved how you look now." or "Still loading - try again in a second.", E and "user-round-check" or "triangle-alert")
		end)
	end)
	v1001(v1011, "avatar_keep", "Keep Avatar After Respawn", "Re-applies it after every respawn.", true, function(E)
		ValtLook.avatar.keep = E
	end)
end)
v999(v1011, "Animations")
ValtSafe("L8509", function()
	v1003(v1011, "anim_pack", "Animation Pack", "Default puts your own animations back.", ValtLook.packNames, "Default", function(E)
		local V = E

		if type(E) == "table" then
			V = E[1]
		end

		if type(V) ~= "string" then
			return
		end

		task.spawn(function()
			local E, k = ValtLook.setPack(V)

			if E then
				v998("Animations", V == "Default" and "Back to your normal animations." or (V .. " animations on."), "person-standing")
			else
				v998("Animations", k or "Could not apply that pack.", "triangle-alert")
			end
		end)
	end)

	local E = ""

	v1011:Input({ Title = "Custom Pack (Bundle ID)", Desc = v1000("Any Roblox animation bundle id from the catalog URL. Use this for a pack that is not in the list."), Placeholder = "e.g. 1114", Value = "", Callback = function(V)
		E = V or ""
	end })
	v1004(v1011, "Apply Custom Pack", "Pulls the animation ids out of that bundle and applies them.", function()
		local V = tonumber((E or ""):match("%d+"))

		if not V then
			v998("Animations", "That is not a bundle id.", "triangle-alert")

			return
		end

		v998("Animations", "Fetching bundle " .. V .. "...", "download")
		task.spawn(function()
			local E, J = ValtLook.setCustomPack(V)

			v998("Animations", E and ("Bundle " .. V .. " applied.") or (J or "Did not work."), E and "person-standing" or "triangle-alert")
		end)
	end)
	v1004(v1011, "Reapply Now", "Forces the current pack back on if something overwrote it.", function()
		ValtLook.reapply()
		v998("Animations", "Re-applying.", "refresh-cw")
	end)
	v1001(v1011, "anim_keep", "Keep Animations After Respawn", "Re-applies the pack after every respawn.", true, function(E)
		ValtLook.anim.keep = E
	end)
end)
ValtLoading(70)
ValtX.breathe()
v999(v1016, "Themes")

do
	local v1883 = v1016:Paragraph({
		Title = "Valt",
		Desc = "Current theme",
		Image = "palette",
		ImageSize = 20
	})

	local function v1884(E, f)
		local S = t16[E]

		if not S then
			return
		end

		theme = E
		v56:SetTheme(E)
		v1006(S)
		task.delay(0.1, function()
			v1017()
			v1018(S)
		end)
		pcall(function()
			v1883:SetTitle(S.Name)
			v1883:SetDesc("Current theme")
		end)

		if not f then
			v998("Theme changed", S.Name .. " applied.", "palette")
		end
	end

	local v1886 = v1003(v1016, "theme", "Palette", "Retints the whole window, not just the accent.", t17, theme, function(p131)
		v1884(p131)
	end)

	v1004(v1016, "Cycle Palette", "Steps through the list.", function()
		local v1887 = table.find(t17, theme) or 1
		local v1888 = t17[v1887 % #t17 + 1]

		pcall(function()
			v1886:Select(v1888)
		end)
		v1884(v1888)
	end)
	pcall(function()
		v56:OnThemeChange(function(p132)
			if p132 ~= theme and t16[p132] then
				theme = p132
				pcall(function()
					v1886:Select(p132)
				end)
			end
		end)
	end)
	v999(v1016, "Executor")
	ValtSafe("L8630", function()
		local E = ValtExec.profile
		local V = ValtExec.limited and ("Reduced: skin changer and silent aim unavailable (no inventory or " .. "WeaponService access), overlay at half rate, smaller coin/trap " .. "budgets, x-ray in " .. E.xrayBudget .. "-part slices.") or "Nothing held back - full budgets, skin rendering on, overlay every frame."

		v1016:Paragraph({ Title = ("%s - %s profile"):format(ValtExec.name, ValtExec.tier), Desc = V .. "\n(" .. ValtExec.why .. ")", Image = ValtExec.limited and "battery-low" or "zap", ImageSize = 20 })

		if ValtExec.limited then
			v1001(v1016, "exec_force_full", "Use Full Settings Anyway", "Full overlay and x-ray on this executor. May drop frames.", false, function(E)
				ValtExec.profile.overlaySkip = E and 1 or 2
				ValtExec.profile.xrayBudget = E and 600 or 120
				v998("Executor", E and "Full settings forced. Watch your frame rate." or "Back to the reduced profile.", E and "zap" or "battery-low")
			end)
		end
	end)
	v999(v1016, "Device")
	ValtSafe("L8664", function()
		local E = ("Detected: %s (%s)"):format(console and "console" or (mobile and "mobile" or "PC"), ValtPlat.source)
		local P = v1016:Paragraph({ Title = E, Desc = "Wrong on a phone? Force Mobile below and re-execute.", Image = mobile and "smartphone" or "monitor", ImageSize = 20 })

		v1003(v1016, "layout_mode", "Force Layout", "Pick Mobile if a phone got the PC layout. Remembered.", { "Auto", "Mobile", "PC" }, (ValtPlat.override == "mobile" and "Mobile") or (ValtPlat.override == "pc" and "PC") or "Auto", function(E)
			local D = (E == "Mobile" and "mobile") or (E == "PC" and "pc") or "auto"

			ValtPlat.saveOverride(D)

			local E = (D == "mobile") or (D == "auto" and ValtPlat.autoResult)

			pcall(function()
				v996:SetSize(v989())
			end)
			pcall(function()
				v996:SetToTheCenter()
			end)

			if E ~= mobile then
				v998("Layout", "Saved. Run the script again to rebuild the menu at " .. (E and "phone" or "desktop") .. " sizes.", "refresh-cw")
			else
				v998("Layout", "Already laid out for " .. (E and "mobile" or "PC") .. ".", "check")
			end

			pcall(function()
				P:SetTitle(("Detected: %s (%s)"):format(console and "console" or (mobile and "mobile" or "PC"), D == "auto" and ValtPlat.source or ("forced " .. D)))
			end)
		end)
	end)
	v999(v1016, mobile and "Mobile" or "Window")

	if mobile then
		v1002(v1016, "open_scale", "Open Button Size", "Size of the round button that hides and shows the menu.", 5, 15, 9, 1, function(p133)
			u1005 = p133 / 10
			v1006(t16[theme])
		end)
		v1004(v1016, "Recentre Window", "Refits the window to the screen.", function()
			pcall(function()
				v996:SetSize(v989())
			end)
			pcall(function()
				v996:SetToTheCenter()
			end)
			v998("Recentred", "Window refitted to the screen.", "move")
		end)
	end

	v1001(v1016, "solid_background", "Disable Transparency", "Off = frosted window (default). On = solid fill.", false, function(p134)
		pcall(function()
			local v1895 = v996
			local SetBackgroundTransparency = v996.SetBackgroundTransparency
			local v1897 = p134 and 0

			SetBackgroundTransparency(v1895, v1897 or 0.15)
		end)
	end)
	pcall(function()
		v996:SetBackgroundTransparency(0.15)
	end)

	if not mobile then
		v1003(v1016, "win_size", "Window Size", "Resize without dragging the corner.", {
			"Compact",
			"Default",
			"Large"
		}, "Default", function(p135)
			local t30 = {
				Compact = UDim2.fromOffset(540, 400),
				Default = UDim2.fromOffset(580, 460),
				Large = UDim2.fromOffset(760, 560)
			}

			pcall(function()
				v996:SetSize(t30[p135])
			end)
		end)
		v1016:Keybind({
			Flag = "toggle_key",
			Title = "Toggle Key",
			Desc = "Opens and closes this window.",
			Value = "Q",
			Callback = function(p136)
				pcall(function()
					v996:SetToggleKey(Enum.KeyCode[p136])
				end)
			end
		})
	end

	v999(v1015, "Weapon Sounds")
	v1001(v1015, "sfx_on", "Weapon Sounds", "Your own shot and kill sounds instead of the game's.", false, function(p137)
		ValtX.sfx.on = p137
		pcall(ValtX.sfx.silenceGame)

		local v1899 = v998

		v1899("Weapon Sounds", p137 and "On." or "Off.", "volume-2")
	end)
	task.spawn(function()
		while ValtState.gen == gen do
			pcall(ValtX.sfx.applySkin)
			pcall(ValtX.sfx.silenceGame)
			task.wait(0.4)
		end
	end)
	ValtConns.sfxGunAdded = game:GetService("CollectionService"):GetInstanceAddedSignal("Weapon_Gun"):Connect(function()
		if ValtState.gen ~= gen then
			ValtConns.sfxGunAdded:Disconnect()

			return
		end

		task.defer(function()
			pcall(ValtX.sfx.applySkin)
		end)
	end)
	v1002(v1015, "sfx_volume", "Volume", nil, 0, 100, 60, 5, function(p138)
		ValtX.sfx.volume = p138 / 100
	end)
	ValtSafe("L8799", function()
		local E = ValtX.sfx.packNames()

		v1003(v1015, "sfx_pack_shoot", "Shoot Sound", "\"Weapon default\" keeps the game's own shot.", E, "Weapon default", function(P)
			ValtX.sfx.packShoot = ValtX.sfx.packId(P)
			v998("Weapon Sounds", "Shoot sound: " .. tostring(P), "volume-2")
		end)
		v1003(v1015, "sfx_pack_kill", "Kill Sound", "Same list, played when a kill lands.", E, "Weapon default", function(E)
			ValtX.sfx.packKill = ValtX.sfx.packId(E)
			v998("Weapon Sounds", "Kill sound: " .. tostring(E), "volume-2")
		end)

		local E = true

		local function D()
			local J = LocalPlayer.Character

			if not J then
				return false
			end

			for k, k in ipairs(J:GetChildren()) do
				if k:IsA("Tool") then
					if k.Name == "Gun" then
						return true
					end

					local J, P = pcall(function()
						return game:GetService("CollectionService"):HasTag(k, "Weapon_Gun")
					end)

					if J and P then
						return true
					end
				end
			end

			return false
		end

		v1001(v1015, "sfx_click", "Play On Click Too", "Also plays the shot when you click with the gun out.", true, function(H)
			E = H
		end)
		ValtConns.sfxClick = UserInputService.InputBegan:Connect(function(H, V)
			if ValtState.gen ~= gen then
				ValtConns.sfxClick:Disconnect()

				return
			end

			if not E or V then
				return
			end

			if H.UserInputType ~= Enum.UserInputType.MouseButton1 and H.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			if not D() then
				return
			end

			ValtX.sfx.play("shoot")
		end)
	end)
	v1015:Input({
		Title = "Custom Shoot Sound ID",
		Desc = v1000("Numeric asset ID. Leave empty to use the weapon's own sound."),
		Value = "",
		Placeholder = "e.g. 106018135",
		Callback = function(p139)
			local v1908 = tostring(p139):gsub("%D", "")

			ValtX.sfx.customShoot = v1908 ~= "" and "rbxassetid://" .. v1908 or ""
			v998("Weapon Sounds", v1908 ~= "" and "Shoot override set to " .. v1908 or "Shoot override cleared.", "volume-2")
		end
	})
	v1015:Input({
		Title = "Custom Kill Sound ID",
		Desc = v1000("Numeric asset ID. Leave empty to use the weapon's own sound."),
		Value = "",
		Placeholder = "e.g. 142247768",
		Callback = function(p140)
			local v1909 = tostring(p140):gsub("%D", "")

			ValtX.sfx.customKill = v1909 ~= "" and "rbxassetid://" .. v1909 or ""
			v998("Weapon Sounds", v1909 ~= "" and "Kill override set to " .. v1909 or "Kill override cleared.", "volume-2")
		end
	})
	v1004(v1015, "Test Shoot Sound", "Plays whatever your current gun would play.", function()
		local on = ValtX.sfx.on

		ValtX.sfx.on = true
		ValtX.sfx.lastAt = 0
		ValtX.sfx.play("shoot")
		ValtX.sfx.on = on
	end)
	v1004(v1015, "Test Kill Sound", "Plays whatever your current knife would play.", function()
		local on = ValtX.sfx.on

		ValtX.sfx.on = true
		ValtX.sfx.lastAt = 0
		ValtX.sfx.play("kill")
		ValtX.sfx.on = on
	end)
	v999(v1015, "Server")
	v1004(v1015, "Rejoin Server", "Drops back into THIS same server for a fresh round.", function()
		v998("Rejoin", "Teleporting back...", "refresh-cw")

		if not pcall(function()
			game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
		end) then
			v998("Rejoin failed", "Executor blocked the teleport.", "triangle-alert")
		end
	end)
	v1004(v1015, "Server Hop", "Jumps to a different low-population server.", function()
		v998("Server Hop", "Finding a fresh server...", "arrow-right-left")

		local TeleportService = game:GetService("TeleportService")
		local HttpService = game:GetService("HttpService")
		local ok, result = pcall(function()
			return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
		end)

		if not ok or not result then
			v998("Server Hop failed", "Couldn't reach the server list.", "triangle-alert")

			return
		end

		local ok2, result2 = pcall(function()
			return HttpService:JSONDecode(result)
		end)

		if not ok2 then
			result2 = nil
		end

		if not result2 or not result2.data then
			v998("Server Hop failed", "Bad server list response.", "triangle-alert")

			return
		end

		local id
		local playing

		for _, v in ipairs(result2.data) do
			if v.id ~= game.JobId and v.playing and v.maxPlayers and v.playing < v.maxPlayers and (not playing or v.playing < playing) then
				id = v.id
				playing = v.playing
			end
		end

		if not id then
			v998("Server Hop", "No other server with room found.", "triangle-alert")

			return
		end

		if not pcall(function()
			TeleportService:TeleportToPlaceInstance(game.PlaceId, id, LocalPlayer)
		end) then
			v998("Server Hop failed", "Teleport was blocked.", "triangle-alert")
		end
	end)
	v1004(v1015, "Copy Job ID", "Puts this server's ID on your clipboard.", function()
		if setclipboard then
			setclipboard(tostring(game.JobId))
			v998("Copied", "Server Job ID copied.", "clipboard")
		else
			v998("Not supported", "Your executor can't write to the clipboard.", "triangle-alert")
		end
	end)
	v999(v1015, "Links")
	v1004(v1015, "Copy YouTube Link", "valtscripts", function()
		if setclipboard then
			setclipboard(YOUTUBE_URL)
			v998("Copied", "Channel link is on your clipboard.", "youtube")
		else
			v998("Not supported", "Your executor can't write to the clipboard.", "triangle-alert")
		end
	end)
	ValtX.breathe()
	v999(v1016, "Interface")
	v1001(v1016, "notifications", "Notifications", "Show a toast when something turns on.", true, function(p141)
		u997 = p141
	end)
	v1004(v1016, "Refresh UI Library", "Downloads a fresh menu library on the next execute.", function()
		local clearUICache = ValtX.clearUICache and ValtX.clearUICache()

		v998(clearUICache and "UI cache cleared" or "Nothing cached", clearUICache and "Next execute pulls a fresh WindUI." or "It will download on next execute.", "refresh-cw")
	end)
	v999(v1016, "Configs")

	local s2 = "default"

	v1016:Input({
		Title = "Config Name",
		Desc = v1000("Saved under the ValtHubHub folder."),
		Value = s2,
		Placeholder = "default",
		Callback = function(p142)
			s2 = p142 ~= "" and p142 or "default"
		end
	})
	task.spawn(function()
		local E = { "Fade", "CameraFade", "SpawnFade" }
		local V = setmetatable({}, { __mode = "k" })

		while task.wait(1) do
			if ValtState.gen ~= gen then
				break
			end

			local D = LocalPlayer:FindFirstChildOfClass("PlayerGui")

			if D then
				local H = os.clock()

				for F, F in ipairs(E) do
					local E = D:FindFirstChild(F)

					if E then
						for D, D in ipairs(E:GetDescendants()) do
							if D:IsA("Frame") then
								local E = D.Visible and D.BackgroundTransparency < 0.05

								if E then
									V[D] = V[D] or H

									if H - V[D] > 10 then
										pcall(function()
											D.BackgroundTransparency = 1
										end)
										V[D] = nil
										v998("Screen", "Cleared a stuck fade.", "eye")
									end
								else
									V[D] = nil
								end
							end
						end
					end
				end
			end
		end
	end)

	local ConfigManager = v996.ConfigManager

	ValtCfg = {
		version = 2
	}
	ValtSafe("L9035", function()
		local E = ValtCfg
		local J = game:GetService("HttpService")

		local function k()
			local P, f = pcall(function()
				return v996.PendingFlags
			end)

			return (P and type(f) == "table") and f or {}
		end

		function E.readFlag(P)
			local f = tostring(rawget(P, "__type"))
			local S = rawget(P, "Value")

			if f == "Slider" then
				return type(S) == "table" and S.Default or S
			end

			return S
		end
		function E.snapshot()
			local P = { v = E.version, flags = {}, extra = {} }

			for f, S in pairs(k()) do
				if type(S) == "table" then
					local N = E.readFlag(S)
					local S = typeof(N)

					if S == "boolean" or S == "number" or S == "string" or S == "table" then
						P.flags[f] = N
					end
				end
			end

			local f = P.extra

			pcall(function()
				f.uiScale = ValtX.uiScale
			end)
			pcall(function()
				f.windowScale = windowScale
			end)
			pcall(function()
				f.theme = theme
			end)
			pcall(function()
				f.roleSource = roleSource
			end)
			pcall(function()
				f.layout = ValtPlat.override
			end)
			pcall(function()
				local F = v996:GetUIScale()

				if type(F) == "number" then
					f.windowUIScale = F
				end
			end)
			pcall(function()
				local F = v996.Size

				if F then
					f.size = { x = F.X.Offset, y = F.Y.Offset }
				end
			end)
			pcall(function()
				f.espFill = ValtESP.fillT
				f.espGlow = ValtESP.glow
			end)
			pcall(function()
				f.btn = { scale = ValtX.btn.scale, locked = ValtX.btn.locked, fade = ValtX.btn.fade, layout = {} }

				for F, S in pairs(ValtX.btn.layout or {}) do
					if type(S) == "table" then
						f.btn.layout[F] = { x = S.x or S.X, y = S.y or S.Y, kw = S.kw or S.k, kh = S.kh or S.k }
					end
				end
			end)

			return P
		end
		function E.apply(F)
			if type(F) ~= "table" or type(F.flags) ~= "table" then
				return false, "that is not a ValtHub config"
			end

			local P, f, S = k(), 0, 0

			for k, N in pairs(F.flags) do
				local j = P[k]

				if type(j) == "table" then
					local k = rawget(j, "Set")

					if type(k) ~= "function" and tostring(rawget(j, "__type")) == "Dropdown" then
						k = rawget(j, "Select")
					end

					if type(k) == "function" and pcall(function()
						k(j, N)
					end) then
						f = f + 1
					else
						S = S + 1
					end
				else
					S = S + 1
				end
			end

			local k = F.extra or {}

			if k.theme then
				pcall(function()
					v1884(k.theme, true)
				end)
			end

			if k.roleSource then
				roleSource = k.roleSource
			end

			if k.espFill then
				pcall(function()
					ValtESP.fillT = k.espFill
				end)
			end

			if k.espGlow then
				pcall(function()
					ValtESP.glow = k.espGlow
				end)
			end

			pcall(function()
				ValtESP.repaint()
			end)

			if k.uiScale then
				ValtX.uiScale = k.uiScale
				pcall(function()
					v996:SetUIScale(k.uiScale)
				end)
			end

			if k.windowScale then
				windowScale = k.windowScale
			end

			if k.size then
				pcall(function()
					v996:SetSize(UDim2.fromOffset(k.size.x, k.size.y))
				end)
			elseif k.windowScale then
				pcall(function()
					v996:SetSize(v989())
				end)
			end

			if type(k.btn) == "table" then
				pcall(function()
					if k.btn.scale then
						ValtX.btn.applyScale(k.btn.scale)
					end

					if k.btn.locked ~= nil then
						ValtX.btn.applyLock(k.btn.locked)
					end

					if k.btn.fade then
						ValtX.btn.applyFade(k.btn.fade)
					end

					for i, D in pairs(k.btn.layout or {}) do
						ValtX.btn.layout[i] = { x = D.x, y = D.y, kw = D.kw or D.k, kh = D.kh or D.k }
					end

					for i, D in pairs(ValtX.btn.objects or {}) do
						local H = ValtX.btn.layout[i]

						if H and D and D.setSizeK then
							D.setSizeK(H.kw or 1, H.kh or 1)
						end

						if H and D and D.setPosition then
							D.setPosition(H.x, H.y)
						end
					end
				end)
			end

			return true, ("%d settings restored%s"):format(f, S > 0 and (", " .. S .. " skipped") or "")
		end
		function E.encode()
			local i, D = pcall(function()
				return J:JSONEncode(E.snapshot())
			end)

			return i and D or nil
		end
		function E.decode(i)
			if type(i) ~= "string" then
				return nil
			end

			i = i:gsub("^%s+", ""):gsub("%s+$", "")

			if i == "" then
				return nil
			end

			local D, H = pcall(function()
				return J:JSONDecode(i)
			end)

			return (D and type(H) == "table") and H or nil
		end
		function E.copy()
			local i = E.encode()

			if not i then
				return false, "could not build the config"
			end

			local E = setclipboard or toclipboard or writeclipboard or (syn and syn.write_clipboard) or (Clipboard and Clipboard.set)

			if not E then
				return false, "your executor has no clipboard function"
			end

			local D = pcall(E, i)

			return D, D and (#i .. " bytes copied") or "clipboard write failed"
		end
	end)

	if ConfigManager then
		ConfigManager:Init(v996)
		v1004(v1016, "Save Config", "Writes every control to file under the name above.", function()
			local ok = pcall(function()
				ConfigManager:CreateConfig(s2):Save()
			end)

			pcall(function()
				if writefile then
					if makefolder then
						if isfolder and not isfolder("ValtHubHub") then
							makefolder("ValtHubHub")
						end

						writefile("ValtHubHub/" .. s2 .. "_extra.json", ValtCfg.encode() or "")
					end
				end
			end)
			v998(ok and "Config saved" or "Save failed", s2, "save")
		end, "Primary")
		v1004(v1016, "Load Config", "Restores a saved setup, window size and buttons included.", function()
			local ok = pcall(function()
				ConfigManager:CreateConfig(s2):Load()
			end)

			pcall(function()
				local v1974 = "ValtHubHub/" .. s2 .. "_extra.json"

				if isfile and isfile(v1974) then
					local v1975 = ValtCfg.decode(readfile(v1974))

					if v1975 then
						ValtCfg.apply(v1975)
					end
				end
			end)
			v998(ok and "Config loaded" or "Nothing to load", s2, "folder-open")
		end)
		v1004(v1016, "Delete Config", "Removes the saved file so nothing carries over.", function()
			local ok, result = pcall(function()
				ConfigManager:CreateConfig(s2):Delete()
			end)

			pcall(function()
				local v1978 = "ValtHubHub/" .. s2 .. "_extra.json"

				if isfile then
					if isfile(v1978) and delfile then
						delfile(v1978)
					end
				end
			end)
			v998(ok and "Config deleted" or "Nothing to delete", ok and s2 or tostring(result), "trash-2")
		end)
	end
end

v999(v1016, "Share")
ValtSafe("L9226", function()
	local E = ""
	local P = v1016:Paragraph({ Title = "Config code", Desc = "Your whole setup as one line. Paste it on another account to copy it.", Image = "clipboard-copy", ImageSize = 20 })

	v1004(v1016, "Copy Everything", "Puts the whole setup on your clipboard.", function()
		local f, S = ValtCfg.copy()

		v998(f and "Copied" or "Copy failed", S, f and "clipboard-check" or "clipboard-x")

		if f then
			pcall(function()
				local f = ValtCfg.snapshot()
				local S = 0

				for N in pairs(f.flags) do
					S = S + 1
				end

				P:SetDesc(string.format("Copied %d settings plus window size, scale, theme and button layout. Paste it below to restore.", S))
			end)
		end
	end, "Primary")
	v1016:Input({ Title = "Paste a config code", Desc = v1000("Drop someone else's code in here, then hit Apply."), Placeholder = "{\"v\":2,\"flags\":{...}}", Value = "", Callback = function(k)
		E = k or ""
	end })
	v1004(v1016, "Apply Pasted Code", "Loads the setup from the box above.", function()
		local k = ValtCfg.decode(E)

		if not k then
			v998("Config", "That is not a valid config code.", "triangle-alert")

			return
		end

		local E, P = ValtCfg.apply(k)

		v998(E and "Config applied" or "Config failed", P, E and "check" or "triangle-alert")
	end, "Primary")
	v1004(v1016, "Reset To Defaults", "Turns every feature off and puts the window back where it started.", function()
		v1022()
		pcall(function()
			ValtX.uiScale = 1
			v996:SetUIScale(1)
			v996:SetSize(v989())
			v996:SetToTheCenter()
			ValtX.btn.resetAll()
		end)
		v998("Reset", "Everything off, window recentred.", "rotate-ccw")
	end)
end)
v1016:Divider()
v1004(v1016, "Unload", "Closes the menu and clears it from memory.", function()
	v996:Dialog({
		Title = "Unload ValtHub?",
		Content = "Every feature is turned off and the menu closes.",
		Buttons = {
			{
				Title = "Cancel"
			},
			{
				Title = "Unload",
				Variant = "Primary",
				Callback = function()
					v1022()
					pcall(function()
						if ValtX.unparkPages then
							ValtX.unparkPages()
						end
					end)
					v996:Destroy()
				end
			}
		}
	})
end)

local function v1989()
	local E = nil
	local R = nil

	local function C(T)
		return T ~= nil and T:find("Chroma") ~= nil
	end
	local function T(W)
		local _ = {}

		for z, Y in W:gmatch("()\n    %[\"([^\"]+)\"%] = {") do
			_[#_ + 1] = { pos = z, key = Y }
		end

		if #_ == 0 then
			return nil
		end

		local z = {}

		for Y, Y in ipairs(_) do
			z[Y.key] = z[Y.key] or {}
		end

		local function Y(q, t)
			local Q = 1

			for a, X in W:gmatch(t) do
				while Q < #_ and _[Q + 1].pos < a do
					Q += 1
				end

				z[_[Q].key][q] = X
			end
		end

		Y("name", "()\n    ItemName = \"([^\"]*)\"")
		Y("type", "()\n    ItemType = \"([^\"]*)\"")
		Y("rarity", "()\n    Rarity = \"([^\"]*)\"")
		Y("image", "()\n    Image = \"([^\"]*)\"")

		local W = {}

		for _, Y in pairs(z) do
			if Y.name and (Y.type == "Gun" or Y.type == "Knife") then
				W[#W + 1] = { key = _, name = Y.name, type = Y.type, rarity = Y.rarity or "", image = Y.image, chroma = C(_) }
			end
		end

		return W
	end
	local function W(_)
		for z in _:gmatch("[^\r\n]+") do
			local _ = z:match("^%s*(.-)%s*$")

			if _ ~= "" and _:sub(1, 2) ~= "--" then
				return _:match("^return%s*{") ~= nil
			end
		end

		return false
	end
	local function _(z)
		local Y = {}

		for q, t in pairs(z) do
			local z = type(t) == "table" and t.Meta

			if z and z.ItemName and (z.ItemType == "Gun" or z.ItemType == "Knife") then
				Y[#Y + 1] = { key = q, name = z.ItemName, type = z.ItemType, rarity = z.Rarity or "", image = z.Image, chroma = z.Chroma == true or C(q) }
			end
		end

		return Y
	end
	local function z()
		local Y = ValtX.mod.databaseSync()
		local q = (type(Y) == "table") and Y.Weapons or nil

		if type(q) ~= "table" then
			return nil
		end

		local Y = {}

		for t, Q in pairs(q) do
			if type(Q) == "table" and (Q.ItemType == "Gun" or Q.ItemType == "Knife") then
				Y[#Y + 1] = { key = t, name = Q.ItemName or t, type = Q.ItemType, rarity = Q.Rarity or "", image = Q.Image, chroma = C(t) }
			end
		end

		return Y
	end

	local Y = { Unique = { rank = 1, color = Color3.fromHex("#22d3ee") }, Ancient = { rank = 2, color = Color3.fromHex("#3b82f6") }, Godly = { rank = 3, color = Color3.fromHex("#a855f7") }, Legendary = { rank = 4, color = Color3.fromHex("#f59e0b") }, Rare = { rank = 5, color = Color3.fromHex("#38bdf8") }, Uncommon = { rank = 6, color = Color3.fromHex("#22c55e") }, Common = { rank = 7, color = Color3.fromHex("#94a3b8") }, Classic = { rank = 8, color = Color3.fromHex("#eab308") } }
	local q = { rank = 9, color = Color3.fromRGB(90, 94, 112) }
	local t = Color3.fromHex("#f0f")

	local function Q(a)
		if a.chroma then
			return t
		end

		return (Y[a.rarity] or q).color
	end
	local function t(a)
		local X = (Y[a.rarity] or q).rank

		return a.chroma and (X - 0.5) or X
	end
	local function Y(q)
		local a = {}

		for X, X in ipairs(q) do
			a[X.name] = (a[X.name] or 0) + 1
		end

		for X, X in ipairs(q) do
			X.label = (a[X.name] > 1) and X.key or X.name
		end
	end

	local q, a

	local function X()
		if not a then
			local m = ReplicatedStorage:FindFirstChild("Remotes")
			local c = m and m:FindFirstChild("Inventory")

			a = c and c:FindFirstChild("InventoryDataChanged") or nil
		end

		if q then
			return true
		end

		q = ValtX.mod.profileData()

		return q ~= nil
	end

	local m = {}

	local function c(A, x)
		if not X() then
			v998("Not in MM2", "The inventory module isn't in this place.", "circle-alert")

			return false
		end

		local n = q.Weapons.Owned

		n[A.key] = (n[A.key] or 0) + x
		pcall(function()
			a:Fire("Weapons", A.key, n[A.key])
		end)
		m[A.type] = A.key
		pcall(function()
			q.Weapons.Equipped[A.type] = A.key
		end)
		task.defer(function()
			pcall(ValtX.sfx.applySkin)
		end)

		if ValtX.refreshWeaponIcons then
			task.spawn(function()
				pcall(ValtX.refreshWeaponIcons)
			end)
		end

		return true
	end

	local A = mobile and 380 or 520
	local x = mobile and 72 or 84
	local n = mobile and 88 or 100
	local b = mobile and 46 or 56
	local F = nil
	local d = false
	local L = {}

	local function Z(g)
		local e

		pcall(function()
			local G = g.ContainerFrame

			if not G then
				return
			end

			e = G:FindFirstChildWhichIsA("ScrollingFrame") or (G:IsA("ScrollingFrame") and G or nil) or G:FindFirstChildWhichIsA("ScrollingFrame", true)
		end)

		return e
	end
	local function g(e, G)
		local u = Z(e)

		if not u then
			task.spawn(function()
				local v = os.clock() + 15

				repeat
					task.wait(0.2)
					u = Z(e)
				until u or os.clock() > v

				if u then
					g(e, G)
				end
			end)

			return
		end

		local Z = Instance.new("Frame")

		Z.Name = "SkinGrid" .. G
		Z.BackgroundTransparency = 1
		Z.Size = UDim2.new(1, 0, 0, 272.0)
		Z.LayoutOrder = 50
		Z.Parent = u

		local e = Instance.new("TextBox")

		e.Size = UDim2.new(1, 0, 0, 30)
		e.BackgroundColor3 = Color3.fromRGB(31, 33, 43)
		e.BorderSizePixel = 0
		e.ClearTextOnFocus = false
		e.Font = Enum.Font.Gotham
		e.PlaceholderText = "Search a " .. G:lower() .. "..."
		e.PlaceholderColor3 = Color3.fromRGB(120, 125, 145)
		e.Text = ""
		e.TextColor3 = Color3.fromRGB(236, 238, 246)
		e.TextSize = 13
		e.TextXAlignment = Enum.TextXAlignment.Left
		e.Parent = Z
		Instance.new("UICorner", e).CornerRadius = UDim.new(0, 8)

		local v = Instance.new("UIPadding", e)

		v.PaddingLeft = UDim.new(0, 10)
		v.PaddingRight = UDim.new(0, 10)

		local v = 1
		local w
		local U = Instance.new("TextLabel")

		U.BackgroundTransparency = 1
		U.Position = UDim2.fromOffset(2, 38)
		U.Size = UDim2.new(1, -110.0, 0, 24)
		U.Font = Enum.Font.Gotham
		U.Text = "Amount per tap"
		U.TextSize = 12
		U.TextColor3 = Color3.fromRGB(150, 155, 175)
		U.TextXAlignment = Enum.TextXAlignment.Left
		U.Parent = Z

		local function U(B, o, l)
			local M = Instance.new("TextButton")

			M.Size = UDim2.fromOffset(26, 24)
			M.Position = UDim2.new(1, o, 0, 38)
			M.BackgroundColor3 = Color3.fromRGB(38, 40, 52)
			M.BorderSizePixel = 0
			M.AutoButtonColor = false
			M.Font = Enum.Font.GothamBold
			M.Text = B
			M.TextSize = 14
			M.TextColor3 = Color3.fromRGB(236, 238, 246)
			M.Parent = Z
			Instance.new("UICorner", M).CornerRadius = UDim.new(0, 7)

			local function B()
				v = math.clamp(v + l, 1, 99)
				w.Text = tostring(v)
			end

			v58(M, B)
		end

		U("-", -92.0, -1.0)
		U("+", -26.0, 1)
		w = Instance.new("TextLabel")
		w.BackgroundTransparency = 1
		w.Position = UDim2.new(1, -64.0, 0, 38)
		w.Size = UDim2.fromOffset(36, 24)
		w.Font = Enum.Font.GothamBold
		w.Text = "1"
		w.TextSize = 13
		w.TextColor3 = Color3.fromRGB(236, 238, 246)
		w.Parent = Z

		local w = Instance.new("ScrollingFrame")

		w.BackgroundTransparency = 1
		w.BorderSizePixel = 0
		w.Position = UDim2.fromOffset(0, 68)
		w.Size = UDim2.new(1, 0, 0, 180)
		w.ScrollBarThickness = 4
		w.ScrollBarImageColor3 = Color3.fromRGB(160, 120, 220)
		w.CanvasSize = UDim2.new()
		w.AutomaticCanvasSize = Enum.AutomaticSize.Y
		w.Parent = Z

		local U = Instance.new("UIGridLayout")

		U.CellSize = UDim2.fromOffset(x, n)
		U.CellPadding = UDim2.fromOffset(8, 8)
		U.HorizontalAlignment = Enum.HorizontalAlignment.Center
		U.SortOrder = Enum.SortOrder.LayoutOrder
		U.Parent = w

		local x = Instance.new("TextLabel")

		x.BackgroundTransparency = 1
		x.Position = UDim2.fromOffset(2, 250.0)
		x.Size = UDim2.new(1, -4.0, 0, 20)
		x.Font = Enum.Font.Gotham
		x.Text = "Not loaded."
		x.TextSize = 11
		x.TextColor3 = Color3.fromRGB(140, 145, 165)
		x.TextXAlignment = Enum.TextXAlignment.Left
		x.TextTruncate = Enum.TextTruncate.AtEnd
		x.Parent = Z

		local function U()
			local B = math.clamp(math.floor(u.AbsoluteSize.Y) - 130, 180, A)

			w.Size = UDim2.new(1, 0, 0, B)
			x.Position = UDim2.fromOffset(2, B + 70)
			Z.Size = UDim2.new(1, 0, 0, B + 92)
		end

		U()
		u:GetPropertyChangedSignal("AbsoluteSize"):Connect(U)

		local A = {}

		local function Z(u)
			local U = A[u]

			if U then
				return U
			end

			local B = Instance.new("TextButton")

			B.BorderSizePixel = 0
			B.AutoButtonColor = false
			B.Text = ""
			B.Parent = w
			Instance.new("UICorner", B).CornerRadius = UDim.new(0, 10)

			local w = Instance.new("UIStroke", B)

			w.Transparency = 0.1
			w.Thickness = 2
			w.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

			local o = Instance.new("ImageLabel")

			o.BackgroundTransparency = 1
			o.Size = UDim2.fromOffset(b, b)
			o.Position = UDim2.new(0.5, -b / 2, 0, 6)
			o.ScaleType = Enum.ScaleType.Fit
			o.Parent = B

			local l = Instance.new("TextLabel")

			l.BackgroundTransparency = 1
			l.Position = UDim2.fromOffset(2, b + 8)
			l.Size = UDim2.new(1, -4.0, 0, n - b - 10)
			l.Font = Enum.Font.GothamMedium
			l.TextSize = 10
			l.TextColor3 = Color3.fromRGB(226, 229, 240)
			l.TextWrapped = true
			l.TextYAlignment = Enum.TextYAlignment.Top
			l.Parent = B
			U = { card = B, ring = w, img = o, name = l, item = nil }
			A[u] = U
			v58(B, function()
				local S = U.item

				if not S then
					return
				end

				if c(S, v) then
					w.Transparency, w.Thickness = 0, 4
					task.delay(0.35, function()
						if w.Parent then
							w.Transparency, w.Thickness = 0.1, 2
						end
					end)
					x.Text = ("Spawned %d x %s"):format(v, S.name)
					v998("Spawned", ("%d x %s"):format(v, S.name), "package-plus")
				end
			end)

			return U
		end
		local function S(c)
			for n = c, #A do
				A[n].card.Visible = false
				A[n].item = nil
			end
		end
		local function c()
			if d then
				S(1)
				x.Text = "Fetching weapon list..."

				return
			end

			if not F then
				S(1)
				x.Text = "Not loaded - hit Reload list."

				return
			end

			local A = e.Text:lower():gsub("^%s+", ""):gsub("%s+$", "")
			local n = {}

			for b, b in ipairs(F) do
				if b.type == G and (A == "" or b.name:lower():find(A, 1, true) or b.key:lower():find(A, 1, true)) then
					n[#n + 1] = b
				end
			end

			table.sort(n, function(A, b)
				local u, v = t(A), t(b)

				if u ~= v then
					return u < v
				end

				return A.name:lower() < b.name:lower()
			end)

			local t = math.min(#n, 150)

			for A = 1, t do
				local b = n[A]
				local u = Z(A)
				local Z = Q(b)
				local Q = b.image or ""

				u.item = b
				u.card.LayoutOrder = A
				u.card.BackgroundColor3 = Color3.fromRGB(31, 33, 43):Lerp(Z, 0.14)
				u.ring.Color = Z

				if u.img.Image ~= Q then
					u.img.Image = Q
				end

				u.img.Visible = Q ~= ""
				u.name.Text = b.label or b.name
				u.card.Visible = true
			end

			S(t + 1)

			if #n == 0 then
				x.Text = "Nothing matches that."
			elseif t < #n then
				x.Text = ("Showing %d of %d - search to narrow it down."):format(t, #n)
			else
				x.Text = ("%d %s%s."):format(#n, G:lower(), #n == 1 and "" or "s")
			end
		end

		local S = 0

		e:GetPropertyChangedSignal("Text"):Connect(function()
			S = S + 1

			local t = S

			task.delay(0.12, function()
				if t == S then
					c()
				end
			end)
		end)
		L[G] = { rebuild = c }
		c()
	end
	local function S()
		for t, t in pairs(L) do
			pcall(t.rebuild)
		end
	end

	local t = ValtPlat.mobile

	local function Q()
		if F then
			return
		end

		local c = z()

		if c and #c > 0 then
			Y(c)
			F = c
			S()
		end
	end
	local function c()
		local A = math.max(ValtExec.profile.httpRetries, t and 3 or 2)

		for t = 1, A do
			local x, n = pcall(function()
				return game:HttpGet("https://raw.githubusercontent.com/furqwk/Soawn/refs/heads/main/mm2-spawner-cartoon.lua")
			end)

			if x and type(n) == "string" and #n > 4096 and n:sub(1, 1) ~= "<" then
				return n
			end

			if t < A then
				task.wait(1.5 * t)
			end
		end

		return nil
	end
	local function t(A)
		if d then
			return
		end

		if F and not A then
			return
		end

		d = true
		S()
		Q()
		task.spawn(function()
			local Q = c()
			local c = Q ~= nil
			local A, x

			if c and W(Q) then
				local W = loadstring(Q)
				local n

				if W then
					local b, L = pcall(W)

					if b and type(L) == "table" then
						n = L
					end
				end

				if n then
					E = n
					A = _(n)
					x = "skins"
				end
			end

			if (not A or #A == 0) and c then
				A = T(Q)
				x = (A and #A > 0) and "names" or nil
			end

			if not A or #A == 0 then
				A = z()
				x = A and "game" or nil
			end

			if A then
				Y(A)
			end

			d = false

			if A and #A > 0 then
				F = A
			end

			S()

			if E and R then
				task.spawn(R)
			end

			if x == "skins" then
				v998("Weapons loaded", ("%d ready to spawn, with skins."):format(#A), "package-plus")
			elseif x == "names" then
				v998("Names only", ("%d weapons, but no skin data - they equip as the stock mesh."):format(#A), "triangle-alert")
			elseif x == "game" then
				v998("Using MM2's list", ("Skin fetch failed - %d weapons from the game, no skins. Hit Reload list to retry."):format(#A), "triangle-alert")
			else
				v998("List unavailable", "Fetch failed and MM2's own database isn't here.", "wifi-off")
			end
		end)
	end
	local function S(T, W)
		if not X() then
			v998("Not in MM2", "The inventory module isn't in this place.", "circle-alert")

			return
		end

		if not F then
			v998("Spawn All", "Fetching the weapon list first...", "download")
			t(false)

			local _ = os.clock() + 20

			while not F and os.clock() < _ do
				task.wait(0.25)
			end
		end

		if not F then
			v998("Spawn All", "Weapon list could not be fetched.", "wifi-off")

			return
		end

		local _ = q.Weapons.Owned
		local z, Y = 0, 0

		for Q, Q in ipairs(F) do
			if Q.type == T then
				_[Q.key] = (_[Q.key] or 0) + W
				pcall(function()
					a:Fire("Weapons", Q.key, _[Q.key])
				end)
				z = z + 1
				Y = Y + 1

				if Y >= 25 then
					Y = 0
					task.wait()
				end
			end
		end

		v998("Spawn All", ("%d %s added to your inventory."):format(z, (T == "Knife") and "knives" or "guns"), "package-plus")
	end

	local T = game:GetService("CollectionService")
	local W = { ParticleEmitter = true, Fire = true, Smoke = true, Sparkles = true, PointLight = true, SpotLight = true, SurfaceLight = true }
	local _ = { WeldConstraint = true, Weld = true, Motor6D = true, RigidConstraint = true, Bone = true, Snap = true, ManualWeld = true, Rotate = true, RotateP = true, RotateV = true }
	local z, _, _ = ValtExec.profile.skinRender, true, true

	local function Y()
		return LocalPlayer.Character
	end
	local function Q(a)
		if not X() then
			return nil
		end

		local X

		pcall(function()
			X = q.Weapons.Equipped[a]
		end)

		return X
	end
	local function q(a)
		if type(a) == "string" then
			return (a:gsub("^%s+", ""):gsub("%s+$", ""))
		end

		return a
	end
	local function a(X, c, A)
		for x, n in pairs(c) do
			if not (A and A[x]) then
				if x == "MeshId" or x == "TextureId" or x == "TextureID" or x == "Texture" then
					n = q(n)
				end

				pcall(function()
					X[x] = n
				end)
			end
		end
	end
	local function X(c)
		local A = q(c.MeshId or "")
		local x = c.Size or Vector3.new(1, 1, 1)
		local n

		pcall(function()
			n = game:GetService("InsertService"):CreateMeshPartAsync(A, Enum.CollisionFidelity.Box, Enum.RenderFidelity.Precise)
		end)

		if n then
			pcall(function()
				n.Size = x
			end)

			return n
		end

		local n = Instance.new("Part")

		n.Size = x

		local x = Instance.new("SpecialMesh")

		x.MeshType = Enum.MeshType.FileMesh
		pcall(function()
			x.MeshId = A
		end)
		pcall(function()
			x.TextureId = q(c.TextureID or "")
		end)
		x.Parent = n

		return n
	end

	local c = { Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 255, 0), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 255, 255), Color3.fromRGB(0, 0, 255), Color3.fromRGB(255, 0, 255) }

	local function A(x)
		local n = #c
		local b = x % n
		local x = math.floor(b)

		return c[x + 1]:Lerp(c[((x + 1) % n) + 1], b - x)
	end
	local function x(n)
		local b, d, L = {}, {}, {}
		local Z = false

		for e, e in ipairs(n:GetDescendants()) do
			local G = e:GetAttribute("MM2Chroma")

			if G then
				Z = true

				if G == "part" then
					b[#b + 1] = e
				elseif G == "decal" and e:IsA("Decal") then
					pcall(function()
						e.Texture = "rbxassetid://18363392181"
					end)
					d[#d + 1] = e
				elseif G == "fire" then
					L[#L + 1] = e
				end
			end
		end

		if not Z then
			for Z, Z in ipairs(n:GetDescendants()) do
				if Z:IsA("BasePart") and (Z.Material == Enum.Material.Neon or Z.Name:lower():find("light")) then
					b[#b + 1] = Z
				elseif Z:IsA("Decal") and Z.Name:lower():find("chroma") then
					d[#d + 1] = Z
				elseif Z:IsA("Fire") then
					L[#L + 1] = Z
				end
			end

			if #d == 0 then
				L[#L + 1] = n
			end
		end

		if #b == 0 and #d == 0 and #L == 0 then
			return nil
		end

		return RunService.Heartbeat:Connect(function()
			local n = os.clock()
			local Z = A(n)

			for A, A in ipairs(d) do
				A.Color3 = Z
			end

			for A, A in ipairs(L) do
				if A:IsA("Fire") then
					A.Color = Z
				elseif A:IsA("BasePart") then
					A.Color = Z
				end
			end

			local A = math.floor(n * 1.8)

			for n, d in ipairs(b) do
				d.Color = c[((A + n - 1) % #c) + 1]
			end
		end)
	end
	local function c(A, n)
		if not (A and n.Tags) then
			return
		end

		for b, b in ipairs(n.Tags) do
			local n = (b == "ChromaPart" and "part") or (b == "ChromaDecal" and "decal") or (b == "ChromaFire" and "fire") or nil

			if n then
				pcall(function()
					A:SetAttribute("MM2Chroma", n)
				end)
			end
		end
	end
	local function A(n)
		local b = n.Class

		if _[b] then
			return nil
		end

		if W[b] and false then
			return nil
		end

		local W

		if b == "MeshPart" then
			W = X(n.Props)
			a(W, n.Props, { MeshId = true, Size = true, RelCF = true, CanCollide = true })
		else
			local _, d = pcall(Instance.new, b)

			if not _ or not d then
				return nil
			end

			W = d
			a(W, n.Props, { RelCF = true })
		end

		if n.Name then
			pcall(function()
				W.Name = n.Name
			end)
		end

		c(W, n)

		return W
	end
	local function W(_, n, b, d, L, Z)
		for e, e in ipairs(_.Children or {}) do
			local _ = A(e)

			if _ then
				d[e.Id] = _

				if _:IsA("BasePart") then
					_.Anchored, _.CanCollide, _.CanQuery, _.CanTouch, _.Massless = false, false, false, false, true
					L[#L + 1] = { inst = _, relcf = e.Props.RelCF }
					_.Parent = b
					W(e, _, b, d, L, Z)
				elseif _:IsA("Attachment") then
					if e.Props.RelCF then
						pcall(function()
							_.CFrame = e.Props.RelCF
						end)
					end

					_.Parent = b
					W(e, _, b, d, L, Z)
				elseif _:IsA("Beam") or _:IsA("Trail") then
					_.Parent = n
					Z[#Z + 1] = { inst = _, a0 = e.Att0, a1 = e.Att1 }
					W(e, _, b, d, L, Z)
				else
					_.Parent = n
					W(e, _, b, d, L, Z)
				end
			else
				W(e, n, b, d, L, Z)
			end
		end
	end
	local function _(A)
		local n = A.Model

		if not n then
			return nil
		end

		local A

		if n.Class == "MeshPart" then
			A = X(n.Props)
			a(A, n.Props, { MeshId = true, Size = true, RelCF = true, CanCollide = true })
		else
			A = Instance.new("Part")
			a(A, n.Props, { RelCF = true, CanCollide = true })
		end

		if n.Name then
			pcall(function()
				A.Name = n.Name
			end)
		end

		c(A, n)
		A.Anchored, A.CanCollide, A.CanQuery, A.CanTouch, A.Massless = false, false, false, false, true

		local a = { [n.Id] = A }
		local X, c = {}, {}

		W(n, A, A, a, X, c)

		for W, W in ipairs(c) do
			if W.a0 and a[W.a0] then
				pcall(function()
					W.inst.Attachment0 = a[W.a0]
				end)
			end

			if W.a1 and a[W.a1] then
				pcall(function()
					W.inst.Attachment1 = a[W.a1]
				end)
			end
		end

		return { root = A, parts = X }
	end
	local function W(a)
		local X = a:FindFirstChild("CustomAttachment") or a:FindFirstChild("Attachment")

		return (X and X:IsA("Attachment")) and X.CFrame or nil
	end
	local function a(X)
		local c = X and X.Model

		if not c then
			return nil
		end

		local X

		for A, A in ipairs(c.Children or {}) do
			if A.Class == "Attachment" and A.Props and A.Props.RelCF then
				if A.Name == "CustomAttachment" then
					return A.Props.RelCF
				end

				if A.Name == "Attachment" then
					X = X or A.Props.RelCF
				end
			end
		end

		return X
	end
	local function X(c, A)
		local n = a(A)

		if not n then
			return c.CFrame
		end

		return c.CFrame * (W(c) or CFrame.identity) * n:Inverse()
	end

	local W = { Vector3.xAxis, Vector3.yAxis, Vector3.zAxis }

	local function a(c)
		local A = { { c.X, 1 }, { c.Y, 2 }, { c.Z, 3 } }

		table.sort(A, function(c, n)
			return c[1] > n[1]
		end)

		return A[1][2], A[2][2], A[3][2]
	end
	local function c(A, n)
		return CFrame.fromMatrix(Vector3.zero, A:Cross(n), n)
	end

	local A = -0.37
	local A = { Gun = { fwd = 0.45, side = 0 }, Knife = { fwd = 0, side = 0 } }
	local n = { Harvester = -0.65, Icepiercer = -0.47 }
	local b = {}

	local function d()
		if not (isfile and readfile) then
			return
		end

		pcall(function()
			if not isfile("ValtHubHub/knife_fix.json") then
				return
			end

			local L = game:GetService("HttpService"):JSONDecode(readfile("ValtHubHub/knife_fix.json"))

			if type(L) ~= "table" then
				return
			end

			for Z, e in pairs(L) do
				if type(Z) == "string" and type(e) == "table" then
					b[Z] = { fwd = tonumber(e.fwd) or 0, side = tonumber(e.side) or 0, rot = tonumber(e.rot) or 0 }
				end
			end
		end)
	end
	local function L()
		if not writefile then
			return
		end

		pcall(function()
			if isfolder and makefolder and not isfolder("ValtHubHub") then
				makefolder("ValtHubHub")
			end

			writefile("ValtHubHub/knife_fix.json", game:GetService("HttpService"):JSONEncode(b))
		end)
	end

	d()

	local function d(L, Z, e, G)
		if not Z then
			return L.CFrame
		end

		local u = A[G] or A.Knife
		local A, v = a(Z)
		local w, U = a(L.Size)
		local a

		if G == "Knife" then
			local B = L.Size:Dot(W[w])
			local o = Z:Dot(W[A])

			a = (o - B) / 2 + u.fwd
		else
			a = (n[e] or -0.37) + u.fwd
		end

		local n = (A == 3) and -W[3] or W[A]
		local Z = (A ~= 2) and W[2] or W[v]
		local v = c(n, Z)
		local n = c(W[w], W[U])
		local c = (G == "Knife") and b[e] or nil
		local b = W[w] * (a + (c and c.fwd or 0)) + W[U] * (u.side + (c and c.side or 0))
		local W = CFrame.new()

		if G == "Knife" and A == 3 then
			W = CFrame.Angles(-math.pi / 2, 0, 0)
		end

		if c and c.rot and c.rot ~= 0 then
			W = W * CFrame.Angles(0, math.rad(c.rot), 0)
		end

		return L.CFrame * CFrame.new(b) * n * v:Inverse() * W
	end
	local function W(a, c)
		local A = a.root

		pcall(function()
			A.CFrame = c
		end)

		for n, n in ipairs(a.parts) do
			if n.relcf then
				pcall(function()
					n.inst.CFrame = c * n.relcf
				end)
			end

			local a = Instance.new("WeldConstraint")

			a.Part0, a.Part1 = n.inst, A
			a.Parent = n.inst
		end

		return A
	end
	local function a(c)
		local A = c.Model

		if not A then
			return ""
		end

		if A.Class == "MeshPart" then
			return q(A.Props.MeshId or "")
		end

		for c, c in ipairs(A.Children or {}) do
			if c.Class == "SpecialMesh" then
				return q(c.Props.MeshId or "")
			end
		end

		return ""
	end
	local function c(A)
		if not A then
			return ""
		end

		if A:IsA("MeshPart") then
			return q(A.MeshId or "")
		end

		local n = A:FindFirstChildWhichIsA("SpecialMesh", true)

		return n and q(n.MeshId or "") or ""
	end
	local function q(A, n)
		if n:IsA("BasePart") or n:IsA("Decal") then
			A[#A + 1] = { inst = n, prop = "Transparency", val = n.Transparency }
			pcall(function()
				n.Transparency = 1
			end)
		elseif n:IsA("ParticleEmitter") or n:IsA("Trail") or n:IsA("Beam") or n:IsA("Fire") or n:IsA("Smoke") or n:IsA("Sparkles") then
			A[#A + 1] = { inst = n, prop = "Enabled", val = n.Enabled }
			pcall(function()
				n.Enabled = false
			end)
		end
	end
	local function A(n, b)
		if b:IsA("BasePart") then
			n[#n + 1] = { inst = b, prop = "LocalTransparencyModifier", val = b.LocalTransparencyModifier }
			pcall(function()
				b.LocalTransparencyModifier = 1
			end)
		elseif b:IsA("Decal") then
			n[#n + 1] = { inst = b, prop = "Transparency", val = b.Transparency }
			pcall(function()
				b.Transparency = 1
			end)
		elseif b:IsA("ParticleEmitter") or b:IsA("Trail") or b:IsA("Beam") or b:IsA("Fire") or b:IsA("Smoke") or b:IsA("Sparkles") then
			n[#n + 1] = { inst = b, prop = "Enabled", val = b.Enabled }
			pcall(function()
				b.Enabled = false
			end)
		end
	end
	local function n(b)
		for L, L in ipairs(b) do
			pcall(function()
				L.inst[L.prop] = L.val
			end)
		end
	end
	local function b(L)
		for Z, Z in ipairs(L or {}) do
			pcall(function()
				if Z.prop == "Enabled" then
					if Z.inst.Enabled then
						Z.inst.Enabled = false
					end
				elseif Z.inst[Z.prop] ~= 1 then
					Z.inst[Z.prop] = 1
				end
			end)
		end
	end
	local function L(Z)
		local e = {}

		if Z:IsA("BasePart") then
			e[1] = Z
		end

		for G, G in ipairs(Z:GetDescendants()) do
			if G:IsA("BasePart") or G:IsA("Decal") then
				e[#e + 1] = G
			end
		end

		return e
	end
	local function Z(e, G)
		for u = 1, #e do
			local v = e[u]

			if v.LocalTransparencyModifier ~= G then
				v.LocalTransparencyModifier = G
			end
		end
	end

	local e, G, u = {}, {}, {}
	local v = ValtVizConns
	local w = {}

	local function U(B)
		local o = Y()

		if not o then
			return nil
		end

		local l = o:FindFirstChild("DisplayRef" .. B)

		return l and l.Value or nil
	end
	local function B(o, l)
		local M = os.clock() + (l or 1)

		while os.clock() < M do
			local l = U(o)

			if l then
				return l
			end

			task.wait(0.05)
		end

		return U(o)
	end
	local function o(l)
		local M = e[l]

		if not M then
			return
		end

		if M.chroma then
			pcall(function()
				M.chroma:Disconnect()
			end)
		end

		if M.overlay then
			pcall(function()
				M.overlay:Destroy()
			end)
		end

		n(M.hidden)
		e[l] = nil
	end

	local l

	function l(M, p)
		if not z then
			return
		end

		if e[M] and G[M] == p and p ~= nil then
			return
		end

		u[M] = (u[M] or 0) + 1

		local s = u[M]

		o(M)
		G[M] = p

		local K = p and E and E[p]

		if not K then
			if p and E then
				ValtX.skinWarned = ValtX.skinWarned or {}

				if not ValtX.skinWarned[p] then
					ValtX.skinWarned[p] = true
					v998("No skin model", p .. " has no model in the skin pack, so it shows as the stock weapon.", "triangle-alert")
				end
			end

			return
		end

		local N = U(M) or B(M, 1.5)

		if u[M] ~= s or not N then
			return
		end

		local B = c(N)

		if B ~= "" and B == a(K) then
			return
		end

		local a = {}

		do
			A(a, N)

			for c, c in ipairs(N:GetDescendants()) do
				A(a, c)
			end
		end

		local c = _(K)

		if not c or not c.root or u[M] ~= s or not N.Parent then
			n(a)

			if c and c.root then
				c.root:Destroy()
			end

			return
		end

		W(c, X(N, K))

		local X = c.root

		X.Parent = N.Parent or N

		local c = Instance.new("WeldConstraint")

		c.Part0, c.Part1 = X, N
		c.Parent = X
		e[M] = { overlay = X, hidden = a, ltm = L(X), chroma = C(p) and x(X) or nil }

		if ValtX.equipSync then
			task.defer(ValtX.equipSync)
		end
	end

	local function N(a)
		if a:IsDescendantOf(LocalPlayer) then
			return true
		end

		local X = Y()

		return X ~= nil and a:IsDescendantOf(X)
	end
	local function a(X)
		local c = w[X]

		if not c then
			return
		end

		c.alive = false

		if c.conns then
			for A, A in ipairs(c.conns) do
				pcall(function()
					A:Disconnect()
				end)
			end
		end

		if c.chroma then
			pcall(function()
				c.chroma:Disconnect()
			end)
		end

		if c.overlay then
			pcall(function()
				c.overlay:Destroy()
			end)
		end

		n(c.hidden)

		if c.seen then
			for A, n in pairs(c.seen) do
				if A and A.Parent then
					pcall(function()
						if type(n) == "boolean" then
							A.Enabled = n
						else
							A.Transparency = n
						end
					end)
				end
			end
		end

		w[X] = nil
	end
	local function X(c)
		if not c then
			return nil
		end

		if F then
			for A, A in ipairs(F) do
				if A.key == c and A.image then
					return A.image
				end
			end
		end

		local F = E and E[c]
		local c = F and F.Meta

		return c and c.Image or nil
	end
	local function F(c, A, n)
		local u = LocalPlayer:FindFirstChild("PlayerGui")
		local B = u and u:FindFirstChild("BackpackUI")
		local u = B and B:FindFirstChild("BackpackFrame")

		if not u then
			return
		end

		for B, B in ipairs(u:GetChildren()) do
			local u = B:FindFirstChild("Container")
			local B = u and u:FindFirstChild("ToolIcon")
			local M = u and u:FindFirstChild("NameLabel")

			if B and M then
				local u = (c ~= "" and B.Image == c) or (M.Text ~= "" and M.Text == A)

				if u and B.Image ~= n then
					pcall(function()
						B.Image = n
						M.Text = ""
					end)
				end
			end
		end
	end

	local c = setmetatable({}, { __mode = "k" })

	local function A(n, u)
		if not n or not n.Parent then
			return
		end

		local B = n.TextureId or ""

		if c[n] == nil then
			c[n] = B
		end

		local M = X(Q(u)) or c[n]

		if not M or M == "" then
			return
		end

		local X = n.Name

		if B == M then
			return
		end

		pcall(function()
			n.TextureId = M
		end)
		F(B, X, M)
		task.delay(0.35, function()
			F(B, X, M)
		end)
		task.delay(1.2, function()
			F(B, X, M)
		end)
		task.delay(3.0, function()
			F(B, X, M)
		end)
	end
	local function F()
		for X, X in ipairs({ "Weapon_Knife", "Weapon_Gun" }) do
			local c = (X == "Weapon_Gun") and "Gun" or "Knife"

			for n, n in ipairs(T:GetTagged(X)) do
				if N(n) then
					A(n, c)
				end
			end
		end
	end

	ValtX.refreshWeaponIcons = F

	local function F(X, c, n)
		local u = X.conns

		local function B(M)
			return M == n or M:IsDescendantOf(n)
		end
		local function n(M)
			if B(M) then
				return
			end

			if M:IsA("BasePart") or M:IsA("Decal") then
				if M.Transparency ~= 1 then
					if X.seen[M] == nil then
						X.seen[M] = M.Transparency
					end

					pcall(function()
						M.Transparency = 1
					end)
				end
			elseif M:IsA("ParticleEmitter") or M:IsA("Trail") or M:IsA("Beam") or M:IsA("Fire") or M:IsA("Smoke") or M:IsA("Sparkles") then
				if M.Enabled then
					if X.seen[M] == nil then
						X.seen[M] = M.Enabled
					end

					pcall(function()
						M.Enabled = false
					end)
				end
			end
		end
		local function M(p)
			if B(p) then
				return
			end

			if p:IsA("BasePart") or p:IsA("Decal") then
				u[#u + 1] = p:GetPropertyChangedSignal("Transparency"):Connect(function()
					n(p)
				end)
			end
		end

		M(c)

		for B, B in ipairs(c:GetDescendants()) do
			M(B)
		end

		u[#u + 1] = c.DescendantAdded:Connect(function(c)
			task.defer(function()
				if not X.alive then
					return
				end

				n(c)
				M(c)
			end)
		end)
	end
	local function X(c, n)
		if not z or w[c] then
			return
		end

		local u = c:FindFirstChild("Handle") or c:WaitForChild("Handle", 5)

		if not u then
			return
		end

		local B = Q(n)
		local M = B and E and E[B]

		if not M then
			return
		end

		local E = _(M)

		if not E or not E.root then
			return
		end

		local _ = {}

		do
			q(_, u)

			for M, M in ipairs(u:GetDescendants()) do
				q(_, M)
			end
		end

		W(E, d(u, E.root.Size, B, n))

		local W = E.root

		W.Parent = u

		local E = Instance.new("WeldConstraint")

		E.Part0, E.Part1 = W, u
		E.Parent = W

		local E = { overlay = W, hidden = _, ltm = L(W), seen = {}, conns = {}, alive = true, chroma = C(B) and x(W) or nil }

		w[c] = E

		do
			F(E, u, W)
		end

		if ValtX.equipSync then
			task.defer(ValtX.equipSync)
		end
	end

	local E = true
	local F = {}

	local function C()
		for W, _ in pairs(F) do
			if W and W.Parent then
				pcall(function()
					W.Transparency = _
				end)
			end

			F[W] = nil
		end
	end
	local function W()
		local _ = LocalPlayer.Backpack
		local q = LocalPlayer.Character

		local function c(x)
			return (_ and _:FindFirstChild(x)) or (q and q:FindFirstChild(x))
		end

		if c("Gun") then
			return "Gun"
		end

		if c("Knife") then
			return "Knife"
		end

		return nil
	end
	local function _(q)
		if not q then
			return
		end

		local function c(x)
			if F[x] == nil and (x:IsA("BasePart") or x:IsA("Decal")) then
				F[x] = x.Transparency
				pcall(function()
					x.Transparency = 1
				end)
			end
		end

		c(q)

		for x, x in ipairs(q:GetDescendants()) do
			c(x)
		end
	end

	local q = {}

	local function c()
		if not E then
			C()
			q = {}

			return
		end

		local x = W()
		local W, n = U("Gun"), U("Knife")
		local d = e.Gun and e.Gun.overlay
		local u = e.Knife and e.Knife.overlay
		local B = q

		if x == B.keep and W == B.gD and n == B.kD and d == B.gO and u == B.kO then
			for B in pairs(F) do
				if B.Parent and B.Transparency ~= 1 then
					F[B] = B.Transparency
					pcall(function()
						B.Transparency = 1
					end)
				end
			end

			return
		end

		q = { keep = x, gD = W, kD = n, gO = d, kO = u }
		C()

		if not x then
			return
		end

		for F, F in ipairs({ "Gun", "Knife" }) do
			if F ~= x then
				_(U(F))

				local W = e[F]

				if W then
					_(W.overlay)
				end
			end
		end
	end
	local function F()
		local W = Y()

		if not W then
			return nil
		end

		for _, _ in ipairs(W:GetChildren()) do
			if _:IsA("Tool") then
				if T:HasTag(_, "Weapon_Gun") then
					return "Gun"
				end

				if T:HasTag(_, "Weapon_Knife") then
					return "Knife"
				end
			end
		end

		return nil
	end
	local function W()
		local _ = Y()
		local Y = _ and _:FindFirstChild("Head")

		if not Y then
			return 0
		end

		return math.clamp(Y.LocalTransparencyModifier, 0, 1)
	end
	local function _()
		local Y = F()
		local F = W()

		for W, W in ipairs({ "Gun", "Knife" }) do
			local q = e[W]
			local x = q and q.overlay
			local n = U(W)

			if x and x.Parent then
				local d

				if n then
					d = (n.Transparency >= 1) and 1 or 0
				else
					d = (Y == W) and 1 or 0
				end

				d = math.max(d, F)
				pcall(Z, q.ltm or L(x), d)
				b(q.hidden)
			end
		end

		for F, W in pairs(w) do
			local Y = W and W.overlay

			if Y and Y.Parent and F.Parent then
				pcall(Z, W.ltm or L(Y), 0)
			end
		end
	end

	ValtX.equipSync = _
	pcall(function()
		RunService:UnbindFromRenderStep("ValtHeldSkin")
	end)
	RunService:BindToRenderStep("ValtHeldSkin", Enum.RenderPriority.Last.Value, function()
		if ValtState.gen ~= gen then
			pcall(function()
				RunService:UnbindFromRenderStep("ValtHeldSkin")
			end)

			return
		end

		for V, F in pairs(w) do
			local W = F and F.overlay

			if W and W.Parent and V.Parent and F.ltm then
				Z(F.ltm, 0)
			end
		end
	end)

	local function V()
		for F in pairs(e) do
			pcall(o, F)
		end

		for F in pairs(w) do
			pcall(a, F)
		end

		G.Knife, G.Gun = nil, nil
	end

	R = function()
		V()

		if not z then
			return
		end

		for F, F in ipairs({ "Knife", "Gun" }) do
			local W = Q(F)

			if W then
				task.spawn(function()
					l(F, W)
				end)
			end
		end

		for F, F in ipairs({ "Weapon_Knife", "Weapon_Gun" }) do
			local W = (F == "Weapon_Gun") and "Gun" or "Knife"

			for Y, Y in ipairs(T:GetTagged(F)) do
				if N(Y) then
					task.spawn(function()
						X(Y, W)
						A(Y, W)
					end)
				end
			end
		end
	end
	u1020 = function()
		E = false
		C()
		z = false
		m.Gun, m.Knife = nil, nil
		V()

		for E, E in ipairs(v) do
			pcall(function()
				E:Disconnect()
			end)
		end

		table.clear(v)
	end

	local E = {}

	task.spawn(function()
		while ValtState.gen == gen do
			for V, V in ipairs({ "Knife", "Gun" }) do
				local F = m[V]

				if F and Q(V) ~= F then
					m[V] = nil
				end

				local F = Q(V)

				if F ~= E[V] then
					E[V] = F
					task.spawn(function()
						l(V, F)
					end)

					for F in pairs(w) do
						local O = T:HasTag(F, "Weapon_Gun") and "Gun" or "Knife"

						if O == V then
							task.spawn(function()
								a(F)
								X(F, V)
							end)
						end
					end

					task.spawn(function()
						local F = (V == "Gun") and "Weapon_Gun" or "Weapon_Knife"

						for O, O in ipairs(T:GetTagged(F)) do
							if N(O) then
								pcall(A, O, V)
							end
						end
					end)
				end
			end

			pcall(c)
			pcall(_)
			task.wait(0.25)
		end
	end)
	pcall(function()
		local V = ReplicatedStorage:WaitForChild("ClientServices", 5):WaitForChild("EquipService", 5):WaitForChild("EquippedChanged", 5)

		v[#v + 1] = V.Event:Connect(function(V, F)
			if V == "Knife" or V == "Gun" then
				E[V] = F
				task.spawn(function()
					l(V, F)
				end)
			end
		end)
	end)

	local function E(V)
		v[#v + 1] = V.ChildAdded:Connect(function(V)
			local F = V.Name

			if F == "DisplayRefKnife" or F == "DisplayRefGun" then
				local V = (F == "DisplayRefKnife") and "Knife" or "Gun"

				task.delay(0.2, function()
					local F = G[V]

					if F then
						o(V)
						l(V, F)
					end
				end)
			end
		end)
	end

	if LocalPlayer.Character then
		E(LocalPlayer.Character)
	end

	v[#v + 1] = LocalPlayer.CharacterAdded:Connect(function(V)
		if ValtState.gen ~= gen then
			return
		end

		for F, F in ipairs({ "Knife", "Gun" }) do
			pcall(o, F)
		end

		E(V)
		task.delay(1.0, function()
			for E, E in ipairs({ "Knife", "Gun" }) do
				if G[E] then
					l(E, G[E])
				end
			end
		end)
	end)

	for E, E in ipairs({ "Weapon_Knife", "Weapon_Gun" }) do
		local V = (E == "Weapon_Gun") and "Gun" or "Knife"

		for F, F in ipairs(T:GetTagged(E)) do
			if N(F) then
				task.spawn(function()
					X(F, V)
					A(F, V)
				end)
			end
		end

		v[#v + 1] = T:GetInstanceAddedSignal(E):Connect(function(F)
			if N(F) then
				task.spawn(function()
					X(F, V)
					A(F, V)
				end)
			end
		end)
		v[#v + 1] = T:GetInstanceRemovedSignal(E):Connect(function(E)
			a(E)
		end)
	end

	do
		local function E(V)
			if not V then
				return
			end

			v[#v + 1] = V.ChildAdded:Connect(function(F)
				if F:IsA("Tool") then
					task.defer(_)
				end
			end)
			v[#v + 1] = V.ChildRemoved:Connect(function(F)
				if F:IsA("Tool") then
					task.defer(_)
				end
			end)

			local F = V:FindFirstChild("Head") or V:WaitForChild("Head", 5)

			if F then
				v[#v + 1] = F:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
					task.defer(_)
				end)
			end

			task.defer(_)
		end

		E(LocalPlayer.Character)
		v[#v + 1] = LocalPlayer.CharacterAdded:Connect(function(V)
			task.delay(1, function()
				E(V)
			end)
		end)
	end

	for E, E in ipairs({ { v1012, "Gun" }, { v1013, "Knife" } }) do
		local H, V = E[1], E[2]

		v999(H, V .. "s")
		g(H, V)

		local E = (V == "Knife") and "Knives" or (V .. "s")

		v1004(H, "Spawn All " .. E, "Adds every " .. E:lower() .. " in the list to your inventory at once.", function()
			task.spawn(function()
				S(V, 1)
			end)
		end, "Primary")
		v1004(H, "Reload list", "Fetch the weapon list again.", function()
			t(true)
		end)
		pcall(function()
			local E = H.ContainerFrame

			E:GetPropertyChangedSignal("Visible"):Connect(function()
				if E.Visible then
					t(false)
				end
			end)

			if E.Visible then
				t(false)
			end
		end)
	end

	task.spawn(function()
		local E = os.clock() + 15

		repeat
			task.wait(0.25)
		until ValtX.loadDone or os.clock() > E or ValtState.gen ~= gen

		if ValtState.gen ~= gen then
			return
		end

		task.wait(0.5)
		t(false)
	end)
	ValtX.skinRenderToggle = v1001(v1012, "skin_render", "Render Skins (Gun + Knife)", "Draws the spawned skin over the weapon MM2 actually hands you.", ValtExec.profile.skinRender, function(E)
		z = E
		R()
	end)
end

ValtLoading(85)
ValtX.breathe()

if ValtExec.limited then
	v1012:Paragraph({
		Title = "Skin Changer - not supported on " .. ValtExec.name,
		Desc = "Spawning and skins need access to MM2's inventory, which this executor cannot reach. Everything else in the hub still works.",
		Image = "info",
		ImageSize = 18
	})
	v1013:Paragraph({
		Title = "Skin Changer - not supported on " .. ValtExec.name,
		Desc = "Spawning and skins need access to MM2's inventory, which this executor cannot reach. Everything else in the hub still works.",
		Image = "info",
		ImageSize = 18
	})
else
	ValtSafe("buildSkinChanger", v1989)
end

ValtSafe("L10911", function()
	local E = ValtX.trace
	local S = ValtX.gun
	local N = { ["Green"] = Color3.fromRGB(0, 255, 170), ["Red"] = Color3.fromRGB(255, 60, 60), ["Blue"] = Color3.fromRGB(70, 160, 255), ["Purple"] = Color3.fromRGB(190, 90, 255), ["Yellow"] = Color3.fromRGB(255, 220, 40), ["White"] = Color3.fromRGB(255, 255, 255) }

	v999(v1009, "Shot Tracer")
	v1001(v1009, "trace_on", "Show Shot Trace", "Draws a beam from your muzzle to where the shot actually landed.", false, function(j)
		E.on = j

		if not j then
			ValtX.trace.clear()
		end

		v998("Shot Tracer", j and "Tracing every shot." or "Off.", "move-right")
	end)
	v1003(v1009, "trace_style", "Trace Style", "Beam glows, Laser is a thin cylinder, Line is flat.", { "Beam", "Laser", "Line" }, "Beam", function(j)
		E.style = j
	end)
	v1003(v1009, "trace_color", "Trace Colour", nil, { "Green", "Red", "Blue", "Purple", "Yellow", "White" }, "Green", function(i)
		E.color = N[i] or E.color
	end)
	v1002(v1009, "trace_life", "Trace Lifetime", "Seconds before the beam fades out.", 1, 15, 3, 1, function(i)
		E.life = i
	end)
	v1002(v1009, "trace_thick", "Trace Thickness", nil, 1, 10, 3, 1, function(i)
		E.thickness = i / 10
	end)
	v1001(v1009, "trace_impact", "Impact Marker", "Drops a ball plus the distance in studs where the shot ended.", true, function(i)
		E.impact = i
	end)
	v1004(v1009, "Test Trace", "Fires a dummy beam 60 studs ahead so you can see the settings.", function()
		local i = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

		if not i then
			v998("Shot Tracer", "No character.", "triangle-alert")

			return
		end

		local V = E.on

		E.on = true
		ValtX.trace.draw(i.Position, i.Position + i.CFrame.LookVector * 60, false)
		E.on = V
		v998("Shot Tracer", "Test beam fired.", "move-right")
	end)
	v1004(v1009, "Clear Traces", "Wipes every beam still on screen.", function()
		ValtX.trace.clear()
		v998("Shot Tracer", "Cleared.", "eraser")
	end)
	v999(v1009, "Reload Timer")
	v1002(v1009, "gun_cd", "Gun Cooldown", "Seconds the revolver needs before it fires again.", 5, 80, 30, 1, function(E)
		S.cooldown = E / 10
	end)
	v1001(v1009, "gun_cd_block", "Block Shot While Reloading", "Stops the wasted remote call and greys the Shoot button out instead.", true, function(E)
		S.blockDuringCd = E
	end)
	v1004(v1009, "Reset Reload Timer", "Clears the countdown right now.", function()
		S.lastShot = 0

		if u51 then
			u51.cancelCooldown()
		end

		v998("Reload", "Timer cleared.", "rotate-ccw")
	end)
end)
ValtSafe("L10987", function()
	local function E()
		local S = game:GetService("Lighting")
		local N = { ClockTime = S.ClockTime, Brightness = S.Brightness, Ambient = S.Ambient, OutdoorAmbient = S.OutdoorAmbient, FogEnd = S.FogEnd, FogStart = S.FogStart, FogColor = S.FogColor, GlobalShadows = S.GlobalShadows, ExposureCompensation = S.ExposureCompensation, EnvironmentDiffuseScale = S.EnvironmentDiffuseScale, EnvironmentSpecularScale = S.EnvironmentSpecularScale }
		local j = nil

		do
			local O = S:FindFirstChildOfClass("Sky")

			if O then
				j = O:Clone()
			end
		end

		local O = ValtX.world

		O.cycling = false
		O.cycleStep = 0.25
		O.fullbright = false

		local function R()
			local C = S:FindFirstChild("ValtGrade")

			if not C then
				C = Instance.new("ColorCorrectionEffect")
				C.Name = "ValtGrade"
				C.Parent = S
			end

			return C
		end
		local function C()
			local T = S:FindFirstChild("ValtBloom")

			if not T then
				T = Instance.new("BloomEffect")
				T.Name = "ValtBloom"
				T.Enabled = false
				T.Parent = S
			end

			return T
		end
		local function T()
			local W = S:FindFirstChild("ValtBlur")

			if not W then
				W = Instance.new("BlurEffect")
				W.Name = "ValtBlur"
				W.Size = 0
				W.Parent = S
			end

			return W
		end
		local function W()
			local _ = S:FindFirstChild("ValtRays")

			if not _ then
				_ = Instance.new("SunRaysEffect")
				_.Name = "ValtRays"
				_.Enabled = false
				_.Parent = S
			end

			return _
		end
		local function _()
			for z, z in ipairs(S:GetChildren()) do
				if z:IsA("Sky") then
					z:Destroy()
				end
			end
		end
		local function z(Y)
			_()

			local q = Instance.new("Sky")

			q.Name = "ValtSky"
			q.SkyboxBk = Y.bk
			q.SkyboxDn = Y.dn
			q.SkyboxFt = Y.ft
			q.SkyboxLf = Y.lf
			q.SkyboxRt = Y.rt
			q.SkyboxUp = Y.up
			q.StarCount = Y.stars or 3000
			q.CelestialBodiesShown = Y.bodies ~= false
			q.Parent = S

			return q
		end
		local function Y(q)
			q = tostring(q):gsub("%D", "")

			if q == "" then
				return nil
			end

			return "rbxassetid://" .. q
		end

		local q = { ["Bluecloud"] = { bk = "rbxassetid://12064107", dn = "rbxassetid://12064152", ft = "rbxassetid://12064121", lf = "rbxassetid://12063984", rt = "rbxassetid://12064115", up = "rbxassetid://12064131" }, ["Black Void"] = { bk = "", dn = "", ft = "", lf = "", rt = "", up = "", stars = 0, bodies = false }, ["Starfield"] = { bk = "", dn = "", ft = "", lf = "", rt = "", up = "", stars = 30000, bodies = false } }

		v999(WorldTab, "Time of Day")

		local t = v1002(WorldTab, "world_time", "Clock Time", "0 is midnight, 12 is high noon, 24 wraps back around.", 0, 24, math.floor(S.ClockTime), 1, function(Q)
			S.ClockTime = Q % 24
		end)

		v1004(WorldTab, "Day", "Bright noon lighting.", function()
			O.cycling = false
			S.ClockTime = 14
			S.Brightness = 2
			v57(t, 14)
			v998("World", "Day.", "sun")
		end)
		v1004(WorldTab, "Sunset", "Low orange sun.", function()
			O.cycling = false
			S.ClockTime = 17.8
			v57(t, 18)
			v998("World", "Sunset.", "sunset")
		end)
		v1004(WorldTab, "Night", "Full dark with stars.", function()
			O.cycling = false
			S.ClockTime = 0
			v57(t, 0)
			v998("World", "Night.", "moon")
		end)
		v1001(WorldTab, "world_cycle", "Auto Day-Night Cycle", "Rolls the clock forward on its own.", false, function(H)
			O.cycling = H
			O.cycleToken = (O.cycleToken or 0) + 1

			if not H then
				return
			end

			local H = O.cycleToken

			task.spawn(function()
				while O.cycling and O.cycleToken == H and ValtState.gen == gen do
					S.ClockTime = (S.ClockTime + O.cycleStep) % 24
					task.wait(0.1)
				end
			end)
		end)
		v1002(WorldTab, "world_cycle_speed", "Cycle Speed", "Hours added every tenth of a second.", 1, 20, 3, 1, function(H)
			O.cycleStep = H / 20
		end)
		v999(WorldTab, "Sky")
		v1003(WorldTab, "world_sky", "Skybox", "Swaps all six faces at once.", { "Game Default", "Bluecloud", "Black Void", "Starfield" }, "Game Default", function(H)
			if H == "Game Default" then
				_()

				if j then
					j:Clone().Parent = S
				end

				v998("Sky", "Back to the game's own skybox.", "cloud")

				return
			end

			local F = q[H]

			if F then
				z(F)
				v998("Sky", H .. " applied.", "cloud")
			end
		end)
		WorldTab:Input({ Title = "Custom Sky Asset ID", Desc = v1000("Paste any decal or texture ID - it goes on all six faces."), Value = "", Placeholder = "e.g. 159454299", Callback = function(H)
			local F = Y(H)

			if not F then
				v998("Sky", "That isn't a numeric asset ID.", "triangle-alert")

				return
			end

			z({ bk = F, dn = F, ft = F, lf = F, rt = F, up = F })
			v998("Sky", "Custom skybox applied.", "image")
		end })
		v1001(WorldTab, "world_nosky", "Remove Sky", "Strips the skybox entirely - flat ambient colour behind the map.", false, function(H)
			if H then
				z(q["Black Void"])
			else
				_()

				if j then
					j:Clone().Parent = S
				end
			end
		end)
		v999(WorldTab, "Gamma and Colour")
		v1002(WorldTab, "world_gamma", "Gamma", "Raw Lighting.Brightness - the fastest way to see indoors.", 0, 100, math.floor(S.Brightness * 10), 1, function(H)
			S.Brightness = H / 10
		end)
		v1002(WorldTab, "world_exposure", "Exposure", "Shifts the whole frame up or down in stops.", -30.0, 30, 0, 1, function(H)
			S.ExposureCompensation = H / 10
		end)
		v1002(WorldTab, "world_sat", "Saturation", "Negative goes grayscale, positive goes neon.", -100.0, 100, 0, 5, function(H)
			R().Saturation = H / 100
		end)
		v1002(WorldTab, "world_contrast", "Contrast", nil, -100.0, 100, 0, 5, function(H)
			R().Contrast = H / 100
		end)
		v1002(WorldTab, "world_tint", "Tint Strength", "Blends the tint colour picked below over the frame.", 0, 100, 0, 5, function(H)
			local F = R()

			F.TintColor = (O.tintColor or Color3.fromRGB(255, 255, 255)):Lerp(Color3.fromRGB(255, 255, 255), 1 - (H / 100))
		end)
		v1003(WorldTab, "world_tint_color", "Tint Colour", nil, { "White", "Red", "Green", "Blue", "Purple", "Orange", "Cyan" }, "White", function(H)
			O.tintColor = ({ White = Color3.fromRGB(255, 255, 255), Red = Color3.fromRGB(255, 80, 80), Green = Color3.fromRGB(80, 255, 140), Blue = Color3.fromRGB(90, 150, 255), Purple = Color3.fromRGB(190, 100, 255), Orange = Color3.fromRGB(255, 160, 60), Cyan = Color3.fromRGB(80, 255, 240) })[H] or Color3.fromRGB(255, 255, 255)
		end)
		v1001(WorldTab, "world_fullbright", "Fullbright", "Flattens every shadow so nothing can hide in a dark corner.", false, function(H)
			O.fullbright = H

			if H then
				S.Ambient = Color3.fromRGB(255, 255, 255)
				S.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
				S.Brightness = 2
				S.GlobalShadows = false
				S.FogEnd = 1e6
				S.EnvironmentDiffuseScale = 1
				S.EnvironmentSpecularScale = 1
			else
				S.Ambient = N.Ambient
				S.OutdoorAmbient = N.OutdoorAmbient
				S.Brightness = N.Brightness
				S.GlobalShadows = N.GlobalShadows
				S.FogEnd = N.FogEnd
				S.EnvironmentDiffuseScale = N.EnvironmentDiffuseScale
				S.EnvironmentSpecularScale = N.EnvironmentSpecularScale
			end

			v998("Fullbright", H and "On." or "Off.", "lightbulb")
		end)
		v999(WorldTab, "Fog and Effects")
		v1002(WorldTab, "world_fog", "Fog Distance", "Studs before fog swallows everything.", 0, 5000, math.floor(math.min(S.FogEnd, 5000)), 50, function(H)
			S.FogEnd = H
		end)
		v1001(WorldTab, "world_nofog", "No Fog", "Pushes fog past the map entirely.", false, function(H)
			S.FogEnd = H and 1e6 or N.FogEnd
		end)
		v1001(WorldTab, "world_shadows", "Global Shadows", "Off costs nothing and lifts a few frames.", S.GlobalShadows, function(H)
			S.GlobalShadows = H
		end)
		v1001(WorldTab, "world_bloom", "Bloom", "Glow bleed around bright pixels.", false, function(H)
			C().Enabled = H
		end)
		v1002(WorldTab, "world_bloom_i", "Bloom Intensity", nil, 0, 30, 10, 1, function(H)
			local F = C()

			F.Intensity = H / 10
			F.Size = 24
			F.Threshold = 0.9
		end)
		v1001(WorldTab, "world_rays", "Sun Rays", "God rays out of the sun.", false, function(H)
			W().Enabled = H
		end)
		v1002(WorldTab, "world_blur", "Screen Blur", "0 is off.", 0, 40, 0, 1, function(H)
			T().Size = H
		end)
		v1001(WorldTab, "world_nodof", "Kill Depth of Field", "Disables every DOF effect the game ships.", false, function(D)
			for H, H in ipairs(S:GetDescendants()) do
				if H:IsA("DepthOfFieldEffect") then
					H.Enabled = not D
				end
			end
		end)
		v999(WorldTab, "Performance")
		v1004(WorldTab, "Open Performance Tab", "Reversible texture, particle and shadow strips, plus an FPS counter.", function()
			PerfTab:Select()
		end)
		v1004(WorldTab, "Restore World", "Puts every lighting value back where it started.", function()
			O.cycling = false

			for i, D in pairs(N) do
				pcall(function()
					S[i] = D
				end)
			end

			local i = S:FindFirstChild("ValtGrade")

			if i then
				i:Destroy()
			end

			for i, i in ipairs({ "ValtBloom", "ValtBlur", "ValtRays" }) do
				local D = S:FindFirstChild(i)

				if D then
					D:Destroy()
				end
			end

			_()

			if j then
				j:Clone().Parent = S
			end

			v998("World", "Restored to the server's lighting.", "rotate-ccw")
		end)
	end

	local i = false

	local function D()
		if i then
			return
		end

		i = true
		E()
	end

	local E

	pcall(function()
		E = WorldTab.ContainerFrame
	end)

	if E then
		E:GetPropertyChangedSignal("Visible"):Connect(function()
			if E.Visible then
				D()
			end
		end)

		if E.Visible then
			D()
		end
	else
		task.delay(3, D)
	end
end)
ValtSafe("L11349", function()
	local function E()
		local f = ValtX.perf
		local S = { textures = {}, particles = {}, effects = {} }
		local N, j = 0, 4000

		local function O(R, C, T)
			local W = S[R]
			local R = W[C]

			if not R then
				R = {}
				W[C] = R
				N = N + 1

				if N >= j then
					N = 0

					for W, W in pairs(S) do
						for _ in pairs(W) do
							if _.Parent then
								N = N + 1
							else
								W[_] = nil
							end
						end
					end

					j = math.max(4000, N * 2)
				end
			end

			if R[T] == nil then
				local N, j = pcall(function()
					return C[T]
				end)

				if N then
					R[T] = j
				end
			end
		end
		local function N(j)
			local R = S[j]
			local S = 0

			for j, C in pairs(R) do
				if j and j.Parent then
					for T, W in pairs(C) do
						pcall(function()
							j[T] = W
						end)
					end

					S = S + 1
				end

				R[j] = nil
			end

			return S
		end

		local S = setmetatable({}, { __mode = "v" })

		local function j(R)
			if R:IsA("BasePart") then
				O("textures", R, "Material")
				O("textures", R, "Reflectance")
				O("textures", R, "CastShadow")
				R.Material = Enum.Material.SmoothPlastic
				R.Reflectance = 0
				R.CastShadow = false

				return true
			elseif R:IsA("Decal") or R:IsA("Texture") then
				O("textures", R, "Transparency")
				R.Transparency = 1

				return true
			elseif R:IsA("SurfaceAppearance") then
				if R.Parent then
					S[R] = R.Parent
					R.Parent = nil
				end

				return true
			end

			return false
		end
		local function R(C)
			if C:IsA("ParticleEmitter") or C:IsA("Trail") or C:IsA("Smoke") or C:IsA("Fire") or C:IsA("Sparkles") or C:IsA("Beam") then
				O("particles", C, "Enabled")
				C.Enabled = false

				return true
			end

			return false
		end
		local function C(T)
			if T:IsA("PostEffect") then
				O("effects", T, "Enabled")
				T.Enabled = false

				return true
			end

			return false
		end
		local function O(T, W, _)
			task.spawn(function()
				local z, Y = 0, 0

				for q, q in ipairs(T) do
					for T, T in ipairs(q:GetDescendants()) do
						if not _() then
							return
						end

						z = z + 1

						if z >= 700 then
							z = 0
							task.wait()
						end

						if W(T) then
							Y = Y + 1
						end
					end
				end

				f.lastStripped = Y
			end)
		end
		local function T(W, _, z)
			if f.conns[W] then
				f.conns[W]:Disconnect()
			end

			f.conns[W] = Workspace.DescendantAdded:Connect(function(W)
				if not z() then
					return
				end

				pcall(_, W)
			end)
		end
		local function W(_)
			if f.conns[_] then
				f.conns[_]:Disconnect()
				f.conns[_] = nil
			end
		end
		local function _(z)
			f.textures = z

			if z then
				O({ Workspace }, j, function()
					return f.textures
				end)
				T("textures", j, function()
					return f.textures
				end)
			else
				W("textures")

				for j, z in pairs(S) do
					if z and z.Parent then
						pcall(function()
							j.Parent = z
						end)
					end

					S[j] = nil
				end

				N("textures")
			end
		end
		local function S(j)
			f.particles = j

			if j then
				O({ Workspace }, R, function()
					return f.particles
				end)
				T("particles", R, function()
					return f.particles
				end)
			else
				W("particles")
				N("particles")
			end
		end
		local function j(R)
			f.effects = R

			local T = game:GetService("Lighting")

			if R then
				O({ T, Workspace }, C, function()
					return f.effects
				end)
			else
				N("effects")
			end
		end
		local function P(N)
			local O = game:GetService("Lighting")

			f.shadows = N

			if N then
				if f.savedShadows == nil then
					f.savedShadows = O.GlobalShadows
				end

				if f.savedFogEnd == nil then
					f.savedFogEnd = O.FogEnd
				end

				O.GlobalShadows = false
				O.FogEnd = 1e6
			else
				if f.savedShadows ~= nil then
					O.GlobalShadows = f.savedShadows
				end

				if f.savedFogEnd ~= nil then
					O.FogEnd = f.savedFogEnd
				end

				f.savedShadows, f.savedFogEnd = nil, nil
			end
		end
		local function N(O)
			f.lowQuality = O
			pcall(function()
				local R = settings().Rendering

				if O then
					if f.savedQuality == nil then
						f.savedQuality = R.QualityLevel
					end

					R.QualityLevel = Enum.QualityLevel.Level01
				elseif f.savedQuality ~= nil then
					R.QualityLevel = f.savedQuality
					f.savedQuality = nil
				end
			end)
		end
		local function O(R)
			f.fpsCounter = R

			if f.fpsConn then
				f.fpsConn:Disconnect()
				f.fpsConn = nil
			end

			if f.fpsThread then
				pcall(task.cancel, f.fpsThread)
				f.fpsThread = nil
			end

			if f.fpsGui then
				f.fpsGui:Destroy()
				f.fpsGui = nil
			end

			if not R then
				return
			end

			local R = Instance.new("ScreenGui")

			R.Name = "ValtFPS"
			R.ResetOnSpawn = false
			R.IgnoreGuiInset = true
			R.DisplayOrder = 100002
			R.Parent = ValtX.btn.root()
			f.fpsGui = R

			local C = Instance.new("TextButton")

			C.AnchorPoint = Vector2.new(0.5, 0)
			C.Position = UDim2.new(0.5, 0, 0, 6)
			C.Size = UDim2.fromOffset(96, 26)
			C.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
			C.BackgroundTransparency = 0.25
			C.BorderSizePixel = 0
			C.AutoButtonColor = false
			C.Text = ""
			C.Parent = R
			Instance.new("UICorner", C).CornerRadius = UDim.new(0, 8)

			local R = Instance.new("TextLabel")

			R.Size = UDim2.new(1, 0, 1, 0)
			R.BackgroundTransparency = 1
			R.Font = Enum.Font.GothamBold
			R.TextSize = 14
			R.Text = "-- FPS"
			R.TextColor3 = Color3.fromRGB(120, 240, 150)
			R.Parent = C

			local T, W, z = false, nil, nil

			C.InputBegan:Connect(function(Y)
				if Y.UserInputType == Enum.UserInputType.MouseButton1 or Y.UserInputType == Enum.UserInputType.Touch then
					T, W, z = true, C.Position, Y.Position
				end
			end)
			C.InputChanged:Connect(function(Y)
				if not T then
					return
				end

				if Y.UserInputType == Enum.UserInputType.MouseMovement or Y.UserInputType == Enum.UserInputType.Touch then
					local q = Y.Position - z

					C.Position = UDim2.new(W.X.Scale, W.X.Offset + q.X, W.Y.Scale, W.Y.Offset + q.Y)
				end
			end)
			C.InputEnded:Connect(function()
				T = false
			end)

			local C = 0

			f.fpsConn = RunService.RenderStepped:Connect(function()
				C = C + 1
			end)
			f.fpsThread = task.spawn(function()
				while f.fpsCounter and ValtState.gen == gen do
					task.wait(1)

					local D = C

					C = 0

					if R.Parent then
						R.Text = D .. " FPS"
						R.TextColor3 = (D >= 50 and Color3.fromRGB(120, 240, 150)) or (D >= 30 and Color3.fromRGB(250, 200, 90)) or Color3.fromRGB(250, 110, 110)
					end
				end
			end)
		end

		v999(PerfTab, "Performance Mode")
		f.masterToggle = v1001(PerfTab, "perf_master", "Performance Mode", "Turns on every strip below at once. Ugly and fast.", false, function(D)
			f.master = D
			_(D)
			v57(f.texToggle, D)
			S(D)
			v57(f.partToggle, D)
			j(D)
			v57(f.fxToggle, D)
			P(D)
			v57(f.shadowToggle, D)
			N(D)
			v57(f.qualToggle, D)
			v998("Performance Mode", D and "Everything stripped." or "Everything restored.", "gauge")
		end, "Primary")
		v999(PerfTab, "Individual Strips")
		f.texToggle = v1001(PerfTab, "perf_textures", "Remove Textures", "Flat parts, no textures or shadows. Biggest FPS win.", false, function(D)
			_(D)
			v998("Textures", D and "Stripped." or "Restored.", "image-off")
		end)
		f.partToggle = v1001(PerfTab, "perf_particles", "Remove Particles & Effects", "Emitters, trails, smoke, fire, sparkles and beams switched off.", false, function(D)
			S(D)
			v998("Particles", D and "Off." or "Back on.", "sparkles")
		end)
		f.fxToggle = v1001(PerfTab, "perf_posteffects", "Remove Post Effects", "The game's own bloom, blur, depth of field and colour correction.", false, function(D)
			j(D)
			v998("Post Effects", D and "Off." or "Back on.", "aperture")
		end)
		f.shadowToggle = v1001(PerfTab, "perf_shadows", "Remove Shadows & Fog", "Global shadows off and fog pushed past the map.", false, function(D)
			P(D)
			v998("Shadows", D and "Off." or "Restored.", "sun-dim")
		end)
		f.qualToggle = v1001(PerfTab, "perf_quality", "Lowest Graphics Quality", "Drops the render quality level to its minimum.", false, function(D)
			N(D)
			v998("Quality", D and "Minimum." or "Restored.", "settings-2")
		end)
		v999(PerfTab, "Meter")
		f.fpsToggle = v1001(PerfTab, "perf_fps", "FPS Counter", "Draggable FPS meter at the top of the screen.", false, function(D)
			O(D)
		end)
		v999(PerfTab, "Restore")
		v1004(PerfTab, "Restore Everything", "Puts every strip back and clears the counter.", function()
			_(false)
			v57(f.texToggle, false)
			S(false)
			v57(f.partToggle, false)
			j(false)
			v57(f.fxToggle, false)
			P(false)
			v57(f.shadowToggle, false)
			N(false)
			v57(f.qualToggle, false)
			f.master = false
			v57(f.masterToggle, false)
			v998("Performance", "Everything restored.", "rotate-ccw")
		end)
		ValtX.perf.offAll = function()
			_(false)
			S(false)
			j(false)
			P(false)
			N(false)
			O(false)
			f.master = false
			v57(f.masterToggle, false)
			v57(f.texToggle, false)
			v57(f.partToggle, false)
			v57(f.fxToggle, false)
			v57(f.shadowToggle, false)
			v57(f.qualToggle, false)
			v57(f.fpsToggle, false)
		end
	end

	local i = false

	local function D()
		if i then
			return
		end

		i = true
		E()
	end

	local E

	pcall(function()
		E = PerfTab.ContainerFrame
	end)

	if E then
		E:GetPropertyChangedSignal("Visible"):Connect(function()
			if E.Visible then
				D()
			end
		end)

		if E.Visible then
			D()
		end
	else
		task.delay(3, D)
	end
end)
ValtSafe("L11728", function()
	local E = ValtX.keys
	local d = ValtX.btn

	local function L(Z)
		if not Z or Z == LocalPlayer then
			return false
		end

		local g, e, G = v562()

		if not g then
			return nil
		end

		local P = LocalPlayer.Character
		local _ = P and P:FindFirstChild("HumanoidRootPart")

		if not _ then
			return false
		end

		local P = Z.Character
		local Z = P and P:FindFirstChild("HumanoidRootPart")
		local g = P and P:FindFirstChild("Humanoid")

		if not Z or not g or g.Health <= 0 then
			return false
		end

		local P = Z.Anchored

		Z.Anchored = true
		Z.CFrame = _.CFrame + _.CFrame.LookVector * 2
		pcall(function()
			e:FireServer()
		end)
		ValtX.sfx.play("kill")
		task.wait(0.1)
		pcall(function()
			G:FireServer(Z)
		end)
		task.delay(0.4, function()
			if Z and Z.Parent then
				Z.Anchored = P
			end
		end)

		return true
	end
	local function P()
		local P = v569()

		if not P then
			v998("Kill Sheriff", "Nobody is holding a gun.", "triangle-alert")

			return false
		end

		local S = L(P)

		if S == nil then
			v998("Kill Sheriff", "No knife - you aren't the murderer.", "triangle-alert")
		elseif S then
			v998("Kill Sheriff", "Stabbed " .. P.Name .. ".", "sword")
		else
			v998("Kill Sheriff", "Sheriff is already down.", "triangle-alert")
		end

		return S
	end

	local P = false

	local function S()
		P = not P
		v57(t18.xray, P)
		v998("X-Ray", P and "Walls thinned." or "Off.", "eye")
	end

	local _ = false

	local function L()
		_ = not _

		for Z, Z in ipairs({ "murderer", "sheriff", "innocent" }) do
			v57(t18[Z], _)
		end

		v998("ESP", _ and "Murderer, sheriff and innocents lit up." or "Off.", "eye")
	end
	local function m()
		local m = v568()

		if not m then
			v998("Teleport", "No murderer found.", "triangle-alert")

			return
		end

		v573(m)
	end

	E.actions = { { id = "shoot_murd", name = "Shoot Murderer", key = "R", fn = v570 }, { id = "grab_gun", name = "Grab Gun", key = "G", fn = v558 }, { id = "fly", name = "Toggle Fly", key = "F", fn = function()
		v66(not u54)
	end }, { id = "noclip", name = "Toggle Noclip", key = "N", fn = function()
		v68()
		v57(v62, connection2 ~= nil)
	end }, { id = "speed", name = "Speed Boost", key = "E", fn = v67 }, { id = "throw_knife", name = "Throw Knife", key = "T", fn = function()
		if ValtX.actions.throwKnife then
			ValtX.actions.throwKnife()
		end
	end }, { id = "aimbot", name = "Toggle Aimbot", key = "V", fn = function()
		if ValtX.actions.toggleAimbot then
			ValtX.actions.toggleAimbot()
		end
	end }, { id = "bomb_jump", name = "Bomb Jump", key = "B", fn = function()
		if ValtX.actions.bombJump then
			ValtX.actions.bombJump()
		end
	end } }
	E.byKey = {}

	do
		local k = {}

		for Q, Q in ipairs(E.actions) do
			k[Q.id] = true
		end

		for Q in pairs(E.map) do
			if not k[Q] then
				E.map[Q] = nil
			end
		end
	end

	local function k()
		E.byKey = {}

		for Q, Q in ipairs(E.actions) do
			local m = E.map[Q.id] or Q.key

			if m and m ~= "" and m ~= "None" then
				E.byKey[string.upper(m)] = Q
			end
		end
	end

	k()
	ValtConns.hotkeys = UserInputService.InputBegan:Connect(function(Q)
		if ValtState.gen ~= gen then
			return
		end

		if not E.enabled then
			return
		end

		if Q.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		if UserInputService:GetFocusedTextBox() then
			return
		end

		local m = E.byKey[string.upper(Q.KeyCode.Name)]

		if m then
			task.spawn(m.fn)
		end
	end)

	local Q = { { id = "ShootMurdButton", label = "Shoot\nMurderer", idx = 1, action = v570, bind = function(O)
		u51 = O
	end }, { id = "GrabGunButton", label = "Grab\nGun", idx = 2, action = v558, bind = function(O)
		u50 = O
	end }, { id = "AimbotButton", label = "Aimbot", idx = 3, action = function()
		if ValtX.actions.toggleAimbot then
			ValtX.actions.toggleAimbot()
		end
	end, bind = function(O)
		if ValtX.actions.bindAimButton then
			ValtX.actions.bindAimButton(O)
		end
	end }, { id = "BombJumpButton", label = "Bomb\nJump", idx = 4, action = function()
		if ValtX.actions.bombJump then
			ValtX.actions.bombJump()
		end
	end, bind = function(O)
		if ValtX.actions.bindBombButton then
			ValtX.actions.bindBombButton(O)
		end
	end }, { id = "KillAllButton", label = "Kill All\nPlayers", idx = 5, action = v567, bind = function(O)
		u52 = O
	end }, { id = "FlyButton", label = "Fly", idx = 6, action = function()
		v66(not u54)
	end, live = function()
		return u54
	end }, { id = "NoclipButton", label = "Noclip", idx = 7, action = function()
		v68()
		v57(v62, connection2 ~= nil)
	end, live = function()
		return connection2 ~= nil
	end }, { id = "XrayButton", label = "Free\nX-Ray", idx = 8, action = S, live = function()
		return P
	end }, { id = "EspToggleButton", label = "ESP", idx = 9, action = L, live = function()
		return _
	end }, { id = "TpMapButton", label = "TP\nMap", idx = 10, action = v574 }, { id = "TpLobbyButton", label = "TP\nLobby", idx = 11, action = v575 }, { id = "ThrowKnifeButton", label = "Throw\nKnife", idx = 12, action = function()
		if ValtX.actions.throwKnife then
			ValtX.actions.throwKnife()
		end
	end, bind = function(H)
		if ValtX.actions.bindThrowButton then
			ValtX.actions.bindThrowButton(H)
		end
	end }, { id = "SilentAimButton", label = "Silent\nAim", idx = 13, action = function()
		if ValtX.actions.toggleSilent then
			ValtX.actions.toggleSilent()
		end
	end, live = function()
		return ValtAim and ValtAim.silent and ValtAim.silent.on or false
	end } }

	if ValtExec.limited then
		for H = #Q, 1, -1.0 do
			if Q[H].id == "SilentAimButton" then
				table.remove(Q, H)
			end
		end
	end

	do
		local H = ValtX.btn.root()

		if H then
			for F, F in ipairs(H:GetChildren()) do
				if F:IsA("ScreenGui") and F.Name:sub(-6.0) == "Button" then
					pcall(function()
						F:Destroy()
					end)
				end
			end
		end
	end

	local H = {}
	local F = {}
	local P = {}

	local function S(j, O)
		if O then
			if H[j.id] then
				H[j.id].destroy()
			end

			H[j.id] = v464(j.id, j.label, ValtX.btn.slot(j.idx), function()
				task.spawn(j.action)
			end)

			if j.bind then
				j.bind(H[j.id])
			end

			if j.live then
				H[j.id].setActive(j.live())
			end
		else
			if H[j.id] then
				H[j.id].destroy()
				H[j.id] = nil
			end

			if j.bind then
				j.bind(nil)
			end
		end

		P = {}

		for V, V in ipairs(Q) do
			if V.live and H[V.id] then
				P[#P + 1] = { obj = H[V.id], live = V.live }
			end
		end

		d.shown[j.id] = O and true or false
		d.save()
	end

	ValtX.destroyAllButtons = function()
		for V, V in ipairs(Q) do
			if H[V.id] then
				H[V.id].destroy()
				H[V.id] = nil
			end
		end
	end
	v999(KeybindsTab, "Button Layout")
	v1002(KeybindsTab, "btn_scale", "Button Size", "Resizes every button. Drag a button's corner to stretch just one.", 50, 160, math.floor(d.scale * 100), 5, function(H)
		ValtX.btn.applyScale(H / 100)
	end)
	v1002(KeybindsTab, "btn_fade", "Button Transparency", "How see-through the button backgrounds are.", 0, 85, math.floor((d.fade or 0.3) * 100), 5, function(H)
		ValtX.btn.applyFade(H / 100)
	end)
	v1001(KeybindsTab, "btn_lock", "Lock Positions", "Stops buttons moving or resizing, and hides the grips.", d.locked, function(H)
		ValtX.btn.applyLock(H)
		v998("Buttons", H and "Positions locked." or "Positions unlocked.", "lock")
	end)
	v1004(KeybindsTab, "Reset Positions", "Sends every button back to the default grid and size.", function()
		ValtX.btn.resetAll()
		v998("Buttons", "Layout reset.", "grid-2x2")
	end)
	v1004(KeybindsTab, "Show All Buttons", "Turns the whole grid on at once.", function()
		for H, H in ipairs(Q) do
			S(H, true)
			v57(F[H.id], true)
		end

		v998("Buttons", #Q .. " buttons on screen.", "layout-grid")
	end, "Primary")
	v1004(KeybindsTab, "Hide All Buttons", "Clears the screen.", function()
		for H, H in ipairs(Q) do
			S(H, false)
			v57(F[H.id], false)
		end

		v998("Buttons", "Screen cleared.", "eye-off")
	end)
	v999(KeybindsTab, "Buttons")

	for H, H in ipairs(Q) do
		local V = (d.shown[H.id] == true) or (mobile and d.shown[H.id] == nil)

		F[H.id] = v1001(KeybindsTab, "btn_" .. H.id, (H.label:gsub("\n", " ")) .. " Button", "Drag it anywhere. The spot is saved the moment you let go.", V, function(F)
			S(H, F)
		end)

		if V then
			S(H, true)
		end
	end

	if not mobile then
		v999(KeybindsTab, "Hotkeys")

		for H, H in ipairs(E.actions) do
			KeybindsTab:Keybind({ Flag = "key_" .. H.id, Title = H.name, Desc = v1000("Default " .. H.key .. "."), Value = E.map[H.id] or H.key, Callback = function(V)
				E.map[H.id] = V
				k()
				ValtX.btn.save()
				v998("Keybind", H.name .. " -> " .. tostring(V), "keyboard")
			end })
		end

		v999(KeybindsTab, "Router")
		v1001(KeybindsTab, "keys_enabled", "Hotkeys Enabled", "Kills every hotkey without unbinding them.", true, function(i)
			E.enabled = i
			v998("Hotkeys", i and "Listening." or "Muted.", "keyboard")
		end)
		v1004(KeybindsTab, "Reset Keybinds", "Puts every hotkey back to its default letter.", function()
			E.map = {}
			k()
			ValtX.btn.save()
			v998("Keybinds", "Defaults restored. Reopen the tab to see them.", "rotate-ccw")
		end)
	end

	task.spawn(function()
		local E = {}

		while ValtState.gen == gen do
			for i = 1, #P do
				local D = P[i]
				local i = D.live() and true or false

				if E[D.obj] ~= i then
					E[D.obj] = i
					D.obj.setActive(i)
				end
			end

			if u51 and not u51.dead and not u51.isCooling() then
				local E = ValtX.gun.remaining()

				if E > 0.15 then
					u51.startCooldown(E, "Reloading")
				end
			end

			task.wait(0.35)
		end
	end)
end)
task.wait(0.15)

do
	pcall(function()
		v1007:Select()
	end)
end

v1017()
v1018(t16[theme])
task.spawn(function()
	task.wait(1)

	if ValtState.gen ~= gen then
		return
	end

	local E

	pcall(function()
		E = v996.PendingFlags
	end)

	if type(E) ~= "table" then
		ValtX.loadDone = true

		return
	end

	local V, F = 0, u997

	u997 = false

	local J = {}

	for k, P in pairs(E) do
		J[#J + 1] = { k, P }
	end

	for E, E in ipairs(J) do
		local J, k = E[1], E[2]

		if type(k) == "table" then
			local E = rawget(k, "Callback")
			local P = rawget(k, "Value")
			local f = tostring(rawget(k, "__type"))

			if f == "Slider" and type(P) == "table" then
				P = P.Default
			end

			local k = (J == "theme" and P == theme)

			if type(E) == "function" and P ~= nil and not k then
				ValtX.breathe()

				if ValtState.gen ~= gen then
					break
				end

				if pcall(E, P) then
					V = V + 1
				end
			end
		end
	end

	u997 = F
	ValtX.loadDone = true

	if V > 0 then
		print(("[Valt] synced %d controls to their features"):format(V))
	end
end)
task.spawn(function()
	task.wait(0.5)

	if ValtState.gen ~= gen then
		return
	end

	local E

	pcall(function()
		E = v996.TabModule.Containers
	end)

	if type(E) ~= "table" then
		return
	end

	local D = Instance.new("Folder")

	D.Name = "ValtParkedPages"

	local H = {}

	local function V(F)
		if F.Visible then
			if F.Parent == D and H[F] then
				F.Parent = H[F]
			end
		elseif F.Parent ~= D then
			H[F] = F.Parent
			F.Parent = D
		end
	end

	ValtX.unparkPages = function()
		for F, J in pairs(H) do
			if F.Parent == D and J.Parent then
				pcall(function()
					F.Parent = J
				end)
			end
		end
	end

	for D, F in pairs(E) do
		if typeof(F) == "Instance" and F:IsA("GuiObject") then
			H[F] = F.Parent
			ValtConns["pagePark_" .. tostring(D)] = F:GetPropertyChangedSignal("Visible"):Connect(function()
				if ValtState.gen ~= gen then
					return
				end

				pcall(V, F)
			end)
			pcall(V, F)
		end
	end
end)

do
	ValtState.hub = {
		destroy = function()
			pcall(v1022)
			pcall(function()
				if ValtX.destroyAllButtons then
					ValtX.destroyAllButtons()
				end
			end)
			pcall(function()
				if ValtX.unparkPages then
					ValtX.unparkPages()
				end
			end)
			pcall(function()
				v996:Destroy()
			end)
		end
	}
end

do
	local function v2597(p143)
		local setclipboard_ = setclipboard or toclipboard

		setclipboard_ = setclipboard_ or writeclipboard or syn and syn.write_clipboard or Clipboard and Clipboard.set

		if setclipboard_ then
			return pcall(setclipboard_, p143)
		end

		return false
	end

	local u2599 = true

	pcall(function()
		if isfile and isfile("ValtHubHub/welcome_seen.txt") then
			local v2600 = tonumber(readfile("ValtHubHub/welcome_seen.txt"))

			if v2600 and os.time() - v2600 < 86400 then
				u2599 = false
			end
		end
	end)

	if u2599 then
		pcall(function()
			if writefile then
				writefile("ValtHubHub/welcome_seen.txt", tostring(os.time()))
			end

			v996:Dialog({
				Title = "Welcome to ValtHub",
				Icon = "gem",
				Content = [[Murder Mystery 2

Need help or want to suggest a feature? Join our Discord!
discord.gg/SgBZtPnTkd
youtube.com/@valtscripts]],
				Buttons = {
					{
						Title = "Copy Discord",
						Variant = "Primary",
						Callback = function()
							if v2597(DISCORD_INVITE) then
								v998("Discord", "Invite copied.", "link")
							else
								v998("Discord", DISCORD_INVITE, "link")
							end
						end
					},
					{
						Title = "Close"
					}
				}
			})
		end)
	end
end

ValtLoading(100)
print("[Valt] ValtHub loaded succesfully")

if #ValtFailed > 0 then
	task.delay(3, function()
		if ValtState.gen ~= gen then
			return
		end

		pcall(function()
			v56:Notify({
				Title = "Valt",
				Content = ("%d feature(s) could not load on %s and were skipped. Press F9 and send a screenshot to support."):format(#ValtFailed, ValtExec.name),
				Icon = "triangle-alert",
				Duration = 8
			})
		end)
	end)
end
