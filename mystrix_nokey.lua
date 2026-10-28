
local players = game:GetService("Players")
local httpService = game:GetService("HttpService")
local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local coreGui = game:GetService("CoreGui")
local runService = game:GetService("RunService")
local textChatService = game:GetService("TextChatService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local virtualUser = game:GetService("VirtualUser")
local starterGui = game:GetService("StarterGui")
local coreGui2 = game:FindFirstChild("CoreGui") or coreGui
local localPlayer = players.LocalPlayer
local touchEnabled = userInputService.TouchEnabled and not userInputService.KeyboardEnabled

local function makeTextLabel()
  local mystrixLoading = Instance.new("ScreenGui")
  mystrixLoading.Name = "MystrixLoading"
  mystrixLoading.Parent = coreGui2
  mystrixLoading.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
  mystrixLoading.Enabled = true
  mystrixLoading.ResetOnSpawn = false

  local loadingFrame = Instance.new("Frame")
  loadingFrame.Name = "LoadingFrame"
  loadingFrame.Parent = mystrixLoading
  loadingFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
  loadingFrame.BorderSizePixel = 0
  loadingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
  loadingFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

  local udim = touchEnabled and UDim2.new(0.9, 0, 0, 360) or UDim2.new(0, 440, 0, 360)
  loadingFrame.Size = UDim2.new(0, 0, 0, 0)

  local uiGradient = Instance.new("UIGradient")

  uiGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 18, 26)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 20, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 26)),
  })

  uiGradient.Rotation = 45
  uiGradient.Parent = loadingFrame

  local uiCorner = Instance.new("UICorner")
  uiCorner.CornerRadius = UDim.new(0, 18)
  uiCorner.Parent = loadingFrame

  local title = Instance.new("TextLabel")
  title.Name = "Title"
  title.Parent = loadingFrame
  title.BackgroundTransparency = 1
  title.Position = UDim2.new(0, 0, 0, 30)
  title.Size = UDim2.new(1, 0, 0, 50)
  title.Font = Enum.Font.GothamBlack
  title.Text = "MYSTRIX HUB"
  title.TextColor3 = Color3.fromRGB(255, 255, 255)
  title.TextSize = touchEnabled and 32 or 38

  local loadingLabel = Instance.new("TextLabel")
  loadingLabel.Name = "LoadingLabel"
  loadingLabel.Parent = loadingFrame
  loadingLabel.BackgroundTransparency = 1
  loadingLabel.AnchorPoint = Vector2.new(0.5, 0.5)
  loadingLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
  loadingLabel.Size = UDim2.new(1, 0, 0, 60)
  loadingLabel.Font = Enum.Font.GothamBold
  loadingLabel.Text = "LOADING"
  loadingLabel.TextColor3 = Color3.fromRGB(180, 140, 240)
  loadingLabel.TextSize = touchEnabled and 24 or 28

  task.spawn(function()
    local v13 = { "", ".", "..", "..." }
    local v14 = 1

    while loadingFrame and loadingFrame.Parent do
      loadingLabel.Text = "LOADING" .. v13[v14]
      v14 = v14 % 4 + 1
      task.wait(0.3)
    end
  end)

  local loadingBarBackground = Instance.new("Frame")
  loadingBarBackground.Name = "LoadingBarBackground"
  loadingBarBackground.Parent = loadingFrame
  loadingBarBackground.BackgroundColor3 = Color3.fromRGB(30, 26, 40)
  loadingBarBackground.BorderSizePixel = 0
  loadingBarBackground.AnchorPoint = Vector2.new(0.5, 0)
  loadingBarBackground.Position = UDim2.new(0.5, 0, 0, 220)
  loadingBarBackground.Size = UDim2.new(0.7, 0, 0, 8)

  local uiCorner2 = Instance.new("UICorner")
  uiCorner2.CornerRadius = UDim.new(1, 0)
  uiCorner2.Parent = loadingBarBackground

  local loadingBar = Instance.new("Frame")
  loadingBar.Name = "LoadingBar"
  loadingBar.Parent = loadingBarBackground
  loadingBar.BackgroundColor3 = Color3.fromRGB(180, 140, 240)
  loadingBar.BorderSizePixel = 0
  loadingBar.Size = UDim2.new(0, 0, 1, 0)

  task.spawn(function()
    for j = 1, 100 do
      if not (loadingFrame and loadingFrame.Parent) then
        break
      end

      loadingBar.Size = UDim2.new(j / 100, 0, 1, 0)
      task.wait(0.03)
    end
  end)

  loadingFrame.BackgroundTransparency = 1

  tweenService:Create(
    loadingFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    { Size = udim }
  ):Play()

  tweenService:Create(loadingFrame, TweenInfo.new(0.4), { BackgroundTransparency = 0 }):Play()

  return mystrixLoading
end

local v16 = {}
v16.__index = v16

function v16:LoadScript()
  local v26, v27 = pcall(function()
    print("Mystrix Hub loaded successfully")
    local dist = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

    local window = dist:CreateWindow({
      Title = "Mystrix Hub - TOJ",
      Icon = "app-window-mac",
      Author = "Ummarxfarooq",
      Theme = "Dark",
    })

    dist:AddTheme({
      Name = "RubyNoir",
      Accent = dist:Gradient({
        ["0"] = { Color = Color3.fromHex("#991B1B"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#7F1D1D"), Transparency = 0 },
      }, { Rotation = 45 }),
      Dialog = dist:Gradient({
        ["0"] = { Color = Color3.fromHex("#0A0303"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#120606"), Transparency = 0 },
      }, { Rotation = 90 }),
      Outline = Color3.fromHex("#DC2626"),
      Text = Color3.fromHex("#E5E5E5"),
      Placeholder = Color3.fromHex("#450A0A"),
      Background = dist:Gradient({
        ["0"] = { Color = Color3.fromHex("#000000"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#0D0404"), Transparency = 0 },
      }, { Rotation = 180 }),
      Button = dist:Gradient({
        ["0"] = { Color = Color3.fromHex("#7F1D1D"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#991B1B"), Transparency = 0 },
      }, { Rotation = 90 }),
      Icon = Color3.fromHex("#DC2626"),
    })

    dist:SetTheme("RubyNoir")

    local mainSection = window:Section({ Title = "Main", Icon = "gamepad-2", Opened = true })
    local cosmeticRemote = replicatedStorage:WaitForChild("CosmeticRemote")
    local equipTitle = replicatedStorage:WaitForChild("EquipTitle")
    local localPlayer2 = players.LocalPlayer
    local playerGui = localPlayer2:WaitForChild("PlayerGui")

    getgenv().autoFarmEnabled = false
    getgenv().autoFarmAltEnabled = false
    getgenv().autoFarmNewEnabled = false
    getgenv().flyEnabled = false
    getgenv().walkSpeed = 16
    getgenv().jumpPower = 50
    getgenv().noClipEnabled = false
    getgenv().InfJumpEnabled = false
    getgenv().antiAfkEnabled = false

    local function f9()
      local timerGui = playerGui:FindFirstChild("TimerGui")

      if timerGui then
        return timerGui:FindFirstChild("Timer")
      end

      return nil
    end

    local function f10(walkSpeed)
      local character = localPlayer2.Character

      if character and character:FindFirstChildOfClass("Humanoid") then
        character.Humanoid.WalkSpeed = walkSpeed
      end
    end

    local function f11(p10)
      local character2 = localPlayer2.Character

      if character2 and character2:FindFirstChildOfClass("Humanoid") then
        local humanoid = character2.Humanoid

        if humanoid.UseJumpPower then
          humanoid.JumpPower = p10
        else
          humanoid.JumpHeight = p10 / 10
        end
      end
    end

    local v28 = false

    local function f12()
      if v28 then
        return
      end

      v28 = true

      local humanoidRootPart = (localPlayer2.Character
        or localPlayer2.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")

      local connect = nil

      connect = runService.RenderStepped:Connect(function(delta)
        if not v28 or not humanoidRootPart or not humanoidRootPart.Parent then
          if connect then
            connect:Disconnect()
          end

          return
        end

        humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, 30 * delta, 0)
      end)
    end

    local function f13()
      v28 = false
    end

    local function f14(text3)
      local v29, v30 = text3:match("(%d+):(%d+)")

      if v29 and v30 then
        return tonumber(v29) * 60 + tonumber(v30)
      end

      return nil
    end

    local function f15()
      local huge, huge2

      while getgenv().autoFarmEnabled do
        local v31 = f9()

        if not v31 then
          print("Timer not found, waiting...")
          task.wait(2)
        else
          f14(v31.Text)

          repeat
            local v32 = f14(v31.Text)

            if v32 then
              print("Current time: " .. v31.Text .. " (" .. v32 .. "s)")
            end

            if not getgenv().autoFarmEnabled then
              break
            end

            task.wait(0.05)
            huge = f14(v31.Text) or math.huge
          until huge <= 274

          if not getgenv().autoFarmEnabled then
            break
          else
            local character3 = localPlayer2.Character or localPlayer2.CharacterAdded:Wait()

            character3:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(
              31.34, 219.23, 141.96
            )

            print("Teleported")
            f12()
            f14(v31.Text)

            repeat
              local v33 = f14(v31.Text)

              if v33 then
                print("Waiting for 4:30: " .. v31.Text .. " (" .. v33 .. "s)")
              end

              if not getgenv().autoFarmEnabled then
                break
              end

              task.wait(0.05)
              huge2 = f14(v31.Text) or math.huge
            until huge2 <= 270

            if not getgenv().autoFarmEnabled then
              break
            end

            textChatService.TextChannels.RBXGeneral:SendAsync("/skip")
            print("Sent /skip")

            task.delay(2, function()
              f13()
              print("Spinning stopped after 2 seconds post-skip")
            end)

            f14(v31.Text)

            repeat
              local v34 = f14(v31.Text)

              if v34 then
                print("Waiting for reset: " .. v31.Text .. " (" .. v34 .. "s)")
              end

              if not getgenv().autoFarmEnabled then
                break
              end

              task.wait(0.2)
              goto L10016622
            until (f14(v31.Text) or 0) > 290

            print("Round reset detected, continuing loop")
            task.wait(3)
          end
        end
      end

      f13()
      print("Auto-farm loop stopped")
    end

    local function f16()
      local huge3, huge4

      while getgenv().autoFarmAltEnabled do
        local v35 = f9()

        if not v35 then
          print("Alt Timer not found, waiting...")
          task.wait(2)
        else
          f14(v35.Text)

          repeat
            local v36 = f14(v35.Text)

            if v36 then
              print("Alt Current time: " .. v35.Text .. " (" .. v36 .. "s)")
            end

            if not getgenv().autoFarmAltEnabled then
              break
            end

            task.wait(0.05)
            huge3 = f14(v35.Text) or math.huge
          until huge3 <= 185

          if not getgenv().autoFarmAltEnabled then
            break
          else
            local character4 = localPlayer2.Character or localPlayer2.CharacterAdded:Wait()

            character4:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(
              31.34, 219.23, 141.96
            )

            print("Alt Teleported")
            f12()
            f14(v35.Text)

            repeat
              local v37 = f14(v35.Text)

              if v37 then
                print("Alt Waiting for 3:00: " .. v35.Text .. " (" .. v37 .. "s)")
              end

              if not getgenv().autoFarmAltEnabled then
                break
              end

              task.wait(0.05)
              huge4 = f14(v35.Text) or math.huge
            until huge4 <= 180

            if not getgenv().autoFarmAltEnabled then
              break
            end

            textChatService.TextChannels.RBXGeneral:SendAsync("/skip")
            print("Alt Sent /skip")

            task.delay(2, function()
              f13()
              print("Alt Spinning stopped after 2 seconds post-skip")
            end)

            f14(v35.Text)

            repeat
              local v38 = f14(v35.Text)

              if v38 then
                print("Alt Waiting for reset: " .. v35.Text .. " (" .. v38 .. "s)")
              end

              if not getgenv().autoFarmAltEnabled then
                break
              end

              task.wait(0.2)
              goto L6094449
            until (f14(v35.Text) or 0) > 290

            print("Alt Round reset detected, continuing loop")
            task.wait(3)
          end
        end
      end

      f13()
      print("Alt Auto-farm loop stopped")
    end

    local function f17()
      local huge5

      while getgenv().autoFarmNewEnabled do
        local v39 = f9()

        if not v39 then
          print("New Timer not found, waiting...")
          task.wait(2)
        else
          f14(v39.Text)

          repeat
            local v40 = f14(v39.Text)

            if v40 then
              print("New Current time: " .. v39.Text .. " (" .. v40 .. "s)")
            end

            if not getgenv().autoFarmNewEnabled then
              break
            end

            task.wait(0.05)
            huge5 = f14(v39.Text) or math.huge
          until huge5 <= 5

          if not getgenv().autoFarmNewEnabled then
            break
          else
            local character5 = localPlayer2.Character or localPlayer2.CharacterAdded:Wait()

            character5:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(
              31.34, 219.23, 141.96
            )

            print("New Teleported")
            f12()

            task.delay(7, function()
              f13()
              print("New Spinning stopped after 7 seconds")
            end)

            f14(v39.Text)

            repeat
              local v41 = f14(v39.Text)

              if v41 then
                print("New Waiting for reset: " .. v39.Text .. " (" .. v41 .. "s)")
              end

              if not getgenv().autoFarmNewEnabled then
                break
              end

              task.wait(0.2)
              goto L1394636
            until (f14(v39.Text) or 0) > 290

            print("New Round reset detected, continuing loop")
            task.wait(3)
          end
        end
      end

      f13()
      print("New Auto-farm loop stopped")
    end

    local connect2, bodyVelocity, v42

    local function makeBodyVelocity()
      local character6 = localPlayer2.Character

      if not character6 or not character6:FindFirstChild("HumanoidRootPart")
        or not character6:FindFirstChildOfClass("Humanoid") then
        return
      end

      local humanoidRootPart2 = character6.HumanoidRootPart
      character6:FindFirstChildOfClass("Humanoid").PlatformStand = true

      bodyVelocity = Instance.new("BodyVelocity")
      bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
      bodyVelocity.Velocity = Vector3.new(0, 0, 0)
      bodyVelocity.Parent = humanoidRootPart2

      local vector = Vector3.new(0, 0, 0)

      connect2 = runService.RenderStepped:Connect(function(delta2)
        if not getgenv().flyEnabled or not character6 or not humanoidRootPart2.Parent then
          stopFlying()
          return
        else
          local vector2 = Vector3.new(0, 0, 0)
          local currentCamera = workspace.CurrentCamera
          local lookVector = currentCamera.CFrame.LookVector
          local rightVector = currentCamera.CFrame.RightVector
          local vector3 = Vector3.new(0, 1, 0)

          if userInputService:IsKeyDown(Enum.KeyCode.W) then
            vector2 = vector2 + lookVector
          end

          if userInputService:IsKeyDown(Enum.KeyCode.S) then
            vector2 = vector2 - lookVector
          end

          if userInputService:IsKeyDown(Enum.KeyCode.D) then
            vector2 = vector2 + rightVector
          end

          if userInputService:IsKeyDown(Enum.KeyCode.A) then
            vector2 = vector2 - rightVector
          end

          if userInputService:IsKeyDown(Enum.KeyCode.Space) then
            vector2 = vector2 + vector3
          end

          if userInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            vector2 = vector2 - vector3
          end

          if v42 then
            local viewportSize = currentCamera.ViewportSize
            local position2 = v42.Position
            local unit = (position2 - viewportSize / 2).Unit
            vector2 = vector2 + (lookVector * -unit.Y + rightVector * unit.X)

            if position2.X > viewportSize.X * 0.75 then
              if position2.Y < viewportSize.Y * 0.5 then
                vector2 = vector2 + vector3
              else
                vector2 = vector2 - vector3
              end
            end
          end

          if vector2.Magnitude > 0 then
            vector = vector + (vector2.Unit * 50 - vector) * (100 * delta2)
          else
            vector = vector * 0.9
          end

          bodyVelocity.Velocity = vector
          return
        end
      end)
    end

    local flyToggle

    local function f18()
      local flyEnabled = getgenv().flyEnabled
      getgenv().flyEnabled = false

      if connect2 then
        connect2:Disconnect()
        connect2 = nil
      end

      if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
      end

      if v42 then
        v42 = nil
      end

      local character7 = localPlayer2.Character

      if character7 and character7:FindFirstChildOfClass("Humanoid") then
        local humanoid2 = character7.Humanoid
        humanoid2.PlatformStand = false
        humanoid2.WalkSpeed = getgenv().walkSpeed or 16

        f11(getgenv().jumpPower or 50)
        local humanoidRootPart3 = character7:FindFirstChild("HumanoidRootPart")

        if humanoidRootPart3 then
          local cframe = humanoidRootPart3.CFrame
          humanoidRootPart3.CFrame = cframe + Vector3.new(0, 0.1, 0)
          task.wait(0.1)
          humanoidRootPart3.CFrame = cframe
        end
      end

      if flyToggle then
        flyToggle:Set(false)
      end

      if flyEnabled then
        dist:Notify({
          Title = "Fly Disabled",
          Content = "Flying disabled. Normal movement restored.",
          Duration = 5,
          Icon = "plane",
        })
      end
    end

    userInputService.TouchStarted:Connect(function(p11)
      if getgenv().flyEnabled then
        v42 = p11
      end
    end)

    userInputService.TouchEnded:Connect(function(part)
      if v42 == part then
        v42 = nil
      end
    end)

    local connect3

    local function f19()
      if connect3 then
        return
      end

      local character8 = localPlayer2.Character

      if not character8 or not character8:FindFirstChild("HumanoidRootPart") then
        return
      end

      connect3 = runService.Stepped:Connect(function()
        if not getgenv().noClipEnabled then
          connect3:Disconnect()
          connect3 = nil
          return
        end

        for index, value in ipairs((character8:GetDescendants())) do
          if value:IsA("BasePart") then
            value.CanCollide = false
          end
        end
      end)
    end

    local function f20()
      getgenv().noClipEnabled = false

      if connect3 then
        connect3:Disconnect()
        connect3 = nil
      end

      local character9 = localPlayer2.Character

      if character9 then
        local humanoid3 = character9:FindFirstChildOfClass("Humanoid")

        if humanoid3 then
          if not getgenv().flyEnabled then
            humanoid3.PlatformStand = false
          end

          humanoid3.WalkSpeed = getgenv().walkSpeed or 16
          humanoid3.HipHeight = 0

          f11(getgenv().jumpPower or 50)
        end

        for index2, value2 in ipairs((character9:GetDescendants())) do
          if value2:IsA("BasePart") then
            value2.CanCollide = true
          end
        end

-- https://discord.gg/hkQAMzyGum
        local humanoidRootPart4 = character9:FindFirstChild("HumanoidRootPart")

        if humanoidRootPart4 then
          local cframe2 = humanoidRootPart4.CFrame
          humanoidRootPart4.CFrame = cframe2 + Vector3.new(0, 0.1, 0)
          task.wait(0.1)
          humanoidRootPart4.CFrame = cframe2
        end
      end
    end

    local v43

    local function f21()
      if v43 then
        return
      end

      v43 = task.spawn(function()
        while getgenv().antiAfkEnabled do
          local character10 = localPlayer2.Character

          if character10 and character10:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart5 = character10.HumanoidRootPart
            local cframe3 = humanoidRootPart5.CFrame
            humanoidRootPart5.CFrame = cframe3 * CFrame.Angles(0, math.rad(1), 0)
            task.wait(0.1)
            humanoidRootPart5.CFrame = cframe3

            virtualUser:CaptureController()
            virtualUser:ClickButton1(Vector2.new(0, 0))
          end

          task.wait(300)
        end
      end)
    end

    local function f22()
      getgenv().antiAfkEnabled = false

      if v43 then
        task.cancel(v43)
        v43 = nil
      end
    end

    localPlayer2.CharacterAdded:Connect(function(character11)
      task.wait(1)

      if getgenv().flyEnabled then
        makeBodyVelocity()
      end

      if getgenv().noClipEnabled then
        f19()
      end

      if getgenv().antiAfkEnabled then
        f21()
      end

      f10(getgenv().walkSpeed)
      f11(getgenv().jumpPower)
    end)

    local tab = mainSection:Tab({ Title = "Auto-Farm Wins", Icon = "infinity", Locked = false })
    tab:Select()
    tab:Divider()

    tab:Button({
      Title = "Auto-Claim Wins",
      Desc = "Auto-Claim All Wins For You!",
      Locked = false,
      Callback = function()
        local rewardClaimed = replicatedStorage:FindFirstChild("RewardClaimed")
          or replicatedStorage:WaitForChild("RewardClaimed")

        if not rewardClaimed then
          warn("RewardClaimed RemoteEvent not found!")
          return
        end

        for index3, value3 in ipairs({ 300, 700, 1100, 1500, 1900, 2200, 2600, 3000 }) do
          local v44 = value3

          pcall(function()
            rewardClaimed:FireServer(v44)
            print("Claimed reward: " .. v44)
          end)

          task.wait(0.1)
        end

        print("All wins claimed!")
      end,
    })

    tab:Divider()

    tab:Toggle({
      Title = "Auto-Farm Wins (VIP)",
      Desc = "This Works Only in PRIVATE SERVERS and for people with VIP GAMEPASS AND WORKS AT 4:30 !!!",
      Icon = "check",
      Type = "Checkbox",
      Default = false,
      Callback = function(value4)
        getgenv().autoFarmEnabled = value4
        print("Toggle Activated: " .. tostring(value4))

        if value4 then
          task.spawn(f15)
        else
          f13()
        end
      end,
    })

    tab:Toggle({
      Title = "Auto-Farm Wins (NON-VIP)",
      Desc = "This Works Only in PRIVATE SERVERS TOO and for normal people without VIP GAMEPASS AND WORKS AT 3:00!!!",
      Icon = "check",
      Type = "Checkbox",
      Default = false,
      Callback = function(value5)
        getgenv().autoFarmAltEnabled = value5
        print("Alt Toggle Activated: " .. tostring(value5))

        if value5 then
          task.spawn(f16)
        else
          f13()
        end
      end,
    })

    tab:Toggle({
      Title = "Auto-Farm Wins (Public Server)",
      Desc = "This works for public server and for all users!!!",
      Icon = "check",
      Type = "Checkbox",
      Default = false,
      Callback = function(value6)
        getgenv().autoFarmNewEnabled = value6
        print("New Toggle Activated: " .. tostring(value6))

        if value6 then
          task.spawn(f17)
        else
          f13()
        end
      end,
    })

    local teleportsTab = mainSection:Tab({
      Title = "Teleports",
      Icon = "map-pin",
      Locked = false,
    })

    teleportsTab:Divider()

    teleportsTab:Button({
      Title = "Teleport To the Top",
      Desc = "Teleports you to the top without any effort!",
      Locked = false,
      Callback = function()
        local localPlayer3 = players.LocalPlayer

        if localPlayer3 and localPlayer3.Character
          and localPlayer3.Character:FindFirstChild("HumanoidRootPart") then
          localPlayer3.Character.HumanoidRootPart.CFrame = CFrame.new(31.63, 219.06, 93.76)
        else
          warn("Player character or HumanoidRootPart not found!")
        end
      end,
    })

    teleportsTab:Button({
      Title = "Teleport To the Winners Room",
      Desc = "Teleports you to the Winners Room!",
      Locked = false,
      Callback = function()
        local localPlayer4 = players.LocalPlayer

        if localPlayer4 and localPlayer4.Character
          and localPlayer4.Character:FindFirstChild("HumanoidRootPart") then
          localPlayer4.Character.HumanoidRootPart.CFrame = CFrame.new(-38462.02, 387.7, -18.68)
        else
          warn("Player character or HumanoidRootPart not found!")
        end
      end,
    })

    teleportsTab:Button({
      Title = "Teleport To Win Door",
      Desc = "Teleports you to the Win Door with ease!",
      Locked = false,
      Callback = function()
        local localPlayer5 = players.LocalPlayer

        if localPlayer5 and localPlayer5.Character
          and localPlayer5.Character:FindFirstChild("HumanoidRootPart") then
          localPlayer5.Character.HumanoidRootPart.CFrame = CFrame.new(31.34, 219.23, 141.96)
        else
          warn("Player character or HumanoidRootPart not found!")
        end
      end,
    })

    teleportsTab:Divider()

    teleportsTab:Button({
      Title = "Teleport To Tic-Tac-Toe Game",
      Desc = "Teleports you to the Tic-Tac-Toe area!",
      Locked = false,
      Callback = function()
        local localPlayer6 = players.LocalPlayer

        if localPlayer6 and localPlayer6.Character
          and localPlayer6.Character:FindFirstChild("HumanoidRootPart") then
          localPlayer6.Character.HumanoidRootPart.CFrame = CFrame.new(-38447.61, 388.11, -43.25)
        else
          warn("Player character or HumanoidRootPart not found!")
        end
      end,
    })

    teleportsTab:Button({
      Title = "Teleport To Swimming Pool",
      Desc = "Teleports you to the Swimming Pool!",
      Locked = false,
      Callback = function()
        local localPlayer7 = players.LocalPlayer

        if localPlayer7 and localPlayer7.Character
          and localPlayer7.Character:FindFirstChild("HumanoidRootPart") then
          localPlayer7.Character.HumanoidRootPart.CFrame = CFrame.new(-38503.78, 378.79, 1.47)
        else
          warn("Player character or HumanoidRootPart not found!")
        end
      end,
    })

    teleportsTab:Button({
      Title = "Teleport Near Confetti Button",
      Desc = "Teleports you near the Confetti Button!",
      Locked = false,
      Callback = function()
        local localPlayer8 = players.LocalPlayer

        if localPlayer8 and localPlayer8.Character
          and localPlayer8.Character:FindFirstChild("HumanoidRootPart") then
          localPlayer8.Character.HumanoidRootPart.CFrame = CFrame.new(-38473.77, 381.34, 86.95)
        else
          warn("Player character or HumanoidRootPart not found!")
        end
      end,
    })

    teleportsTab:Divider()

    teleportsTab:Button({
      Title = "Teleport To Parkour Minigame",
      Desc = "Teleports you to the Parkour Minigame!",
      Locked = false,
      Callback = function()
        local localPlayer9 = players.LocalPlayer

        if localPlayer9 and localPlayer9.Character
          and localPlayer9.Character:FindFirstChild("HumanoidRootPart") then
          localPlayer9.Character.HumanoidRootPart.CFrame = CFrame.new(-38501.7, 387.33, -40.36)
        else
          warn("Player character or HumanoidRootPart not found!")
        end
      end,
    })

    teleportsTab:Button({
      Title = "Teleport To Roof Of Tower",
      Desc = "Teleports you to the Roof of the Tower!",
      Locked = false,
      Callback = function()
        local localPlayer10 = players.LocalPlayer

        if localPlayer10 and localPlayer10.Character
          and localPlayer10.Character:FindFirstChild("HumanoidRootPart") then
          localPlayer10.Character.HumanoidRootPart.CFrame = CFrame.new(31.63, 300, 93.76)
        else
          warn("Player character or HumanoidRootPart not found!")
        end
      end,
    })

    local cosmeticsTab = mainSection:Tab({
      Title = "Cosmetics",
      Icon = "sparkles",
      Locked = false,
    })

    cosmeticsTab:Divider()

    local mainFrame = playerGui:WaitForChild("HaloGui"):WaitForChild("MainFrame")
    local getChildren = mainFrame.GetChildren
    local v45 = {}

    for index4, value7 in ipairs(getChildren(mainFrame)) do
      if value7:IsA("ScrollingFrame") then
        table.insert(v45, value7)
      end
    end

    local function f23(haloId)
      for index5, value8 in ipairs(v45) do
        local findFirstChild = value8:FindFirstChild(haloId)

        if findFirstChild then
          return findFirstChild
        end
      end

      return nil
    end

    local mainFrame2 = playerGui:WaitForChild("TrailsGUI"):WaitForChild("MainFrame")
    local v46 = {}

    for index6, value9 in ipairs(mainFrame2:GetChildren()) do
      if value9:IsA("ScrollingFrame") then
        table.insert(v46, value9)
      end
    end

    local function f24(trailId)
      for index7, value10 in ipairs(v46) do
        local findFirstChild2 = value10:FindFirstChild(trailId)

        if findFirstChild2 then
          return findFirstChild2
        end
      end

      return nil
    end

    cosmeticsTab:Button({
      Title = "Equip Best Halo",
      Desc = "Equips the best halo based on your wins!",
      Locked = false,
      Callback = function()
        local value11 = localPlayer2:WaitForChild("leaderstats"):WaitForChild("Wins").Value

        local v47 = {
          { req = 0, halos = { "Halo1" }, name = "Green Halo" },
          { req = 1, halos = { "Halo2" }, name = "Blue Halo" },
          { req = 2, halos = { "Halo3" }, name = "Red Halo" },
          { req = 3, halos = { "Halo4" }, name = "Pink Halo" },
          { req = 5, halos = { "Halo5" }, name = "White Halo" },
          { req = 10, halos = { "Halo6" }, name = "Purple Halo" },
          { req = 25, halos = { "Halo7" }, name = "Black Halo" },
          { req = 50, halos = { "Halo8" }, name = "Golden Halo" },
          {
            req = 100,
            halos = { "Halo9", "Halo16", "Halo17", "Halo18" },
            names = { "Rainbow Halo", "Toxic Halo", "Water Halo", "Flame Halo" },
          },
          { req = 150, halos = { "Halo10" }, name = "Soul Halo" },
          { req = 250, halos = { "Halo11" }, name = "Inferno Halo" },
          { req = 500, halos = { "Halo12" }, name = "Universe Halo" },
        }

        local v48 = v47[1]

        for index8, value12 in ipairs(v47) do
          if value11 >= value12.req then
            v48 = value12
          else
            break
          end
        end

        local v49 = math.random(1, #v48.halos)
        local v50 = v48.halos[v49]
        local names = v48.names and v48.names[v49] or v48.name
        local v51 = f23(v50)

        if v51 then
          local equip = v51:FindFirstChild("Equip")

          if equip then
            for n = 1, 5 do
              cosmeticRemote:FireServer("halo", "Equip", v50, equip)
            end

            dist:Notify({
              Title = "Equipped Halo",
              Content = "Equipped " .. names .. " based on your " .. value11 .. " wins!",
              Duration = 5,
              Icon = "sparkles",
            })
          else
            dist:Notify({
              Title = "Error",
              Content = "Equip button not found for " .. names,
              Duration = 5,
              Icon = "x",
            })
          end
        else
          dist:Notify({
            Title = "Error",
            Content = "Halo frame not found for " .. names,
            Duration = 5,
            Icon = "x",
          })
        end
      end,
    })

    cosmeticsTab:Dropdown({
      Title = "Select Halo to Equip",
      Values = {
        { Title = "Green Halo (0 wins)", HaloId = "Halo1", Req = 0 },
        { Title = "Blue Halo (1 win)", HaloId = "Halo2", Req = 1 },
        { Title = "Red Halo (2 wins)", HaloId = "Halo3", Req = 2 },
        { Title = "Pink Halo (3 wins)", HaloId = "Halo4", Req = 3 },
        { Title = "White Halo (5 wins)", HaloId = "Halo5", Req = 5 },
        { Title = "Purple Halo (10 wins)", HaloId = "Halo6", Req = 10 },
        { Title = "Black Halo (25 wins)", HaloId = "Halo7", Req = 25 },
        { Title = "Golden Halo (50 wins)", HaloId = "Halo8", Req = 50 },
        { Title = "Rainbow Halo (100 wins)", HaloId = "Halo9", Req = 100 },
        { Title = "Soul Halo (150 wins)", HaloId = "Halo10", Req = 150 },
        { Title = "Inferno Halo (250 wins)", HaloId = "Halo11", Req = 250 },
        { Title = "Universe Halo (500 wins)", HaloId = "Halo12", Req = 500 },
        { Title = "Toxic Halo (100 wins)", HaloId = "Halo16", Req = 100 },
        { Title = "Water Halo (100 wins)", HaloId = "Halo17", Req = 100 },
        { Title = "Flame Halo (100 wins)", HaloId = "Halo18", Req = 100 },
      },
      Value = "Green Halo (0 wins)",
      Callback = function(value13)
        local value14 = localPlayer2:WaitForChild("leaderstats"):WaitForChild("Wins").Value

        if value14 >= value13.Req then
          local v52 = f23(value13.HaloId)

          if v52 then
            local equip2 = v52:FindFirstChild("Equip")

            if equip2 then
              for i6 = 1, 5 do
                cosmeticRemote:FireServer("halo", "Equip", value13.HaloId, equip2)
              end

              dist:Notify({
                Title = "Equipped Halo",
                Content = "Equipped " .. value13.Title .. "!",
                Duration = 5,
                Icon = "sparkles",
              })
            else
              dist:Notify({
                Title = "Error",
                Content = "Equip button not found for " .. value13.Title,
                Duration = 5,
                Icon = "x",
              })
            end
          else
            dist:Notify({
              Title = "Error",
              Content = "Halo frame not found for " .. value13.Title,
              Duration = 5,
              Icon = "x",
            })
          end
        else
          dist:Notify({
            Title = "Insufficient Wins",
            Content = "You need " .. value13.Req .. " wins for " .. value13.Title
              .. "! You have " .. value14 .. ".",
            Duration = 5,
            Icon = "x",
          })
        end
      end,
    })

    cosmeticsTab:Divider()

    cosmeticsTab:Button({
      Title = "Equip Best Trail",
      Desc = "Equips the best trail based on your wins!",
      Locked = false,
      Callback = function()
        local value15 = localPlayer2:WaitForChild("leaderstats"):WaitForChild("Wins").Value

        local v53 = {
          { req = 0, trails = { "Trail1" }, name = "Green Trail" },
          { req = 1, trails = { "Trail2" }, name = "Blue Trail" },
          { req = 2, trails = { "Trail3" }, name = "Red Trail" },
          { req = 5, trails = { "Trail4" }, name = "Purple Trail" },
          { req = 10, trails = { "Trail5" }, name = "Orange Trail" },
          { req = 20, trails = { "Trail6" }, name = "Rainbow Trail" },
          { req = 30, trails = { "Trail7" }, name = "Universe Trail" },
          { req = 50, trails = { "Trail8" }, name = "Inferno Trail" },
          { req = 75, trails = { "Trail9" }, name = "Soul Trail" },
          { req = 100, trails = { "Trail10" }, name = "Toxic Trail" },
          { req = 150, trails = { "Trail11" }, name = "Water Trail" },
          { req = 200, trails = { "Trail12" }, name = "Flame Trail" },
        }

        local v54 = v53[1]

        for index9, value16 in ipairs(v53) do
          if value15 >= value16.req then
            v54 = value16
          else
            break
          end
        end

        local v55 = math.random(1, #v54.trails)
        local v56 = v54.trails[v55]
        local names2 = v54.names and v54.names[v55] or v54.name
        local v57 = f24(v56)

        if v57 then
          local equip3 = v57:FindFirstChild("Equip")

          if equip3 then
            for i7 = 1, 5 do
              cosmeticRemote:FireServer("trail", "Equip", v56, equip3)
            end

            dist:Notify({
              Title = "Equipped Trail",
              Content = "Equipped " .. names2 .. " based on your " .. value15 .. " wins!",
              Duration = 5,
              Icon = "sparkles",
            })
          else
            dist:Notify({
              Title = "Error",
              Content = "Equip button not found for " .. names2,
              Duration = 5,
              Icon = "x",
            })
          end
        else
          dist:Notify({
            Title = "Error",
            Content = "Trail frame not found for " .. names2,
            Duration = 5,
            Icon = "x",
          })
        end
      end,
    })

    cosmeticsTab:Dropdown({
      Title = "Select Trail to Equip",
      Values = {
        { Title = "Green Trail (0 wins)", TrailId = "Trail1", Req = 0 },
        { Title = "Blue Trail (1 win)", TrailId = "Trail2", Req = 1 },
        { Title = "Red Trail (2 wins)", TrailId = "Trail3", Req = 2 },
        { Title = "Purple Trail (5 wins)", TrailId = "Trail4", Req = 5 },
        { Title = "Orange Trail (10 wins)", TrailId = "Trail5", Req = 10 },
        { Title = "Rainbow Trail (20 wins)", TrailId = "Trail6", Req = 20 },
        { Title = "Universe Trail (30 wins)", TrailId = "Trail7", Req = 30 },
        { Title = "Inferno Trail (50 wins)", TrailId = "Trail8", Req = 50 },
        { Title = "Soul Trail (75 wins)", TrailId = "Trail9", Req = 75 },
        { Title = "Toxic Trail (100 wins)", TrailId = "Trail10", Req = 100 },
        { Title = "Water Trail (150 wins)", TrailId = "Trail11", Req = 150 },
        { Title = "Flame Trail (200 wins)", TrailId = "Trail12", Req = 200 },
      },
      Value = "Green Trail (0 wins)",
      Callback = function(value17)
        local value18 = localPlayer2:WaitForChild("leaderstats"):WaitForChild("Wins").Value

        if value18 >= value17.Req then
          local v58 = f24(value17.TrailId)

          if v58 then
            local equip4 = v58:FindFirstChild("Equip")

            if equip4 then
              for i8 = 1, 5 do
                cosmeticRemote:FireServer("trail", "Equip", value17.TrailId, equip4)
              end

              dist:Notify({
                Title = "Equipped Trail",
                Content = "Equipped " .. value17.Title .. "!",
                Duration = 5,
                Icon = "sparkles",
              })
            else
              dist:Notify({
                Title = "Error",
                Content = "Equip button not found for " .. value17.Title,
                Duration = 5,
                Icon = "x",
              })
            end
          else
            dist:Notify({
              Title = "Error",
              Content = "Trail frame not found for " .. value17.Title,
              Duration = 5,
              Icon = "x",
            })
          end
        else
          dist:Notify({
            Title = "Insufficient Wins",
            Content = "You need " .. value17.Req .. " wins for " .. value17.Title
              .. "! You have " .. value18 .. ".",
            Duration = 5,
            Icon = "x",
          })
        end
      end,
    })

    cosmeticsTab:Divider()

    cosmeticsTab:Button({
      Title = "Equip Best Title",
      Desc = "Equips the best title based on your wins!",
      Locked = false,
      Callback = function()
        local value19 = localPlayer2:WaitForChild("leaderstats"):WaitForChild("Wins").Value

        local v59 = {
          { req = 0, titles = { "Noob" }, name = "Noob" },
          { req = 5, titles = { "Pro" }, name = "Pro" },
          { req = 10, titles = { "SUPER Pro" }, name = "SUPER Pro" },
          { req = 15, titles = { "Ultra Pro" }, name = "Ultra Pro" },
          { req = 25, titles = { "Ultra Speedster" }, name = "Ultra Speedster" },
          { req = 40, titles = { "SPEEDRUNNER" }, name = "SPEEDRUNNER" },
          { req = 50, titles = { "GOD GAMER" }, name = "GOD GAMER" },
          { req = 75, titles = { "GODLY" }, name = "GODLY" },
          { req = 100, titles = { "Destroyer" }, name = "Destroyer" },
          { req = 150, titles = { "THE INFERNO" }, name = "THE INFERNO" },
          { req = 500, titles = { "THE UNIVERSE" }, name = "THE UNIVERSE" },
        }

        local v60 = v59[1]

        for index10, value20 in ipairs(v59) do
          if value19 >= value20.req then
            v60 = value20
          else
            break
          end
        end

        local v61 = math.random(1, #v60.titles)
        local v62 = v60.titles[v61]
        local name = v60.name
        local v63 = v62 == "THE UNIVERSE" and "THE UNIVERSE 🌌" or v62

        for i9 = 1, 5 do
          equipTitle:FireServer(v63, true)
        end

        dist:Notify({
          Title = "Equipped Title",
          Content = "Equipped " .. name .. " based on your " .. value19 .. " wins!",
          Duration = 5,
          Icon = "sparkles",
        })
      end,
    })

    cosmeticsTab:Dropdown({
      Title = "Select Title to Equip",
      Values = {
        { Title = "Noob (0 wins)", TitleId = "Noob", Req = 0 },
        { Title = "Pro (5 wins)", TitleId = "Pro", Req = 5 },
        { Title = "SUPER Pro (10 wins)", TitleId = "SUPER Pro", Req = 10 },
        { Title = "Ultra Pro (15 wins)", TitleId = "Ultra Pro", Req = 15 },
        { Title = "Ultra Speedster (25 wins)", TitleId = "Ultra Speedster", Req = 25 },
        { Title = "SPEEDRUNNER (40 wins)", TitleId = "SPEEDRUNNER", Req = 40 },
        { Title = "GOD GAMER (50 wins)", TitleId = "GOD GAMER", Req = 50 },
        { Title = "GODLY (75 wins)", TitleId = "GODLY", Req = 75 },
        { Title = "Destroyer (100 wins)", TitleId = "Destroyer", Req = 100 },
        { Title = "THE INFERNO (150 wins)", TitleId = "THE INFERNO", Req = 150 },
        { Title = "THE UNIVERSE (500 wins)", TitleId = "THE UNIVERSE 🌌", Req = 500 },
      },
      Value = "Noob (0 wins)",
      Callback = function(value21)
        local value22 = localPlayer2:WaitForChild("leaderstats"):WaitForChild("Wins").Value

        if value22 >= value21.Req then
          for i10 = 1, 5 do
            equipTitle:FireServer(value21.TitleId, true)
          end

          dist:Notify({
            Title = "Equipped Title",
            Content = "Equipped " .. value21.Title .. "!",
            Duration = 5,
            Icon = "sparkles",
          })
        else
          dist:Notify({
            Title = "Insufficient Wins",
            Content = "You need " .. value21.Req .. " wins for " .. value21.Title
              .. "! You have " .. value22 .. ".",
            Duration = 5,
            Icon = "x",
          })
        end
      end,
    })

    local playerTab = mainSection:Tab({ Title = "Player", Icon = "user", Locked = false })
    playerTab:Divider()

    playerTab:Slider({
      Title = "Speed",
      Desc = "Adjust your walk speed (1-100). You can drag or type a value.",
      Step = 1,
      Value = { Min = 1, Max = 100, Default = 16 },
      Callback = function(value23)
        getgenv().walkSpeed = value23
        f10(value23)
        print("WalkSpeed set to: " .. value23)
      end,
    })

    playerTab:Slider({
      Title = "JumpPower",
      Desc = "Adjust your jump power (1-200). You can drag or type a value.",
      Step = 1,
      Value = { Min = 1, Max = 200, Default = 50 },
      Callback = function(value24)
        getgenv().jumpPower = value24
        f11(value24)
        print("JumpPower set to: " .. value24)
      end,
    })

    playerTab:Divider()

    playerTab:Toggle({
      Title = "Fly",
      Desc = "Enables or disables flying! (PC: WASD, Space (up), Ctrl (down); Mobile: Touch controls)",
      Icon = "plane",
      Type = "Checkbox",
      Default = false,
      Callback = function(value25)
        getgenv().flyEnabled = value25
        flyToggle = FlyToggle
        print("Fly Toggle Activated: " .. tostring(value25))

        if value25 then
          makeBodyVelocity()

          dist:Notify({
            Title = "Fly Enabled",
            Content = "You can now fly! PC: WASD, Space (up), Ctrl (down). Mobile: Touch left for direction, right for up/down.",
            Duration = 5,
            Icon = "plane",
          })
        else
          f18()
        end
      end,
    })

    playerTab:Toggle({
      Title = "NoClip",
      Desc = "Allows you to pass through walls and objects!",
      Icon = "ghost",
      Type = "Checkbox",
      Default = false,
      Callback = function(value26)
        if getgenv().noClipEnabled ~= value26 then
          getgenv().noClipEnabled = value26
          print("NoClip Toggle Activated: " .. tostring(value26))

          if value26 then
            f19()

            dist:Notify({
              Title = "NoClip Enabled",
              Content = "You can now pass through walls and objects!",
              Duration = 5,
              Icon = "ghost",
            })
          else
            f20()

            dist:Notify({
              Title = "NoClip Disabled",
              Content = "Collisions restored.",
              Duration = 5,
              Icon = "ghost",
            })
          end
        end
      end,
    })

    playerTab:Toggle({
      Title = "Infinite Jump",
      Desc = "Hold or tap jump to bounce infinitely",
      Icon = "arrow-up",
      Type = "Checkbox",
      Default = false,
      Callback = function(value27)
        getgenv().InfJumpEnabled = value27
        print("Infinite Jump Toggle Activated: " .. tostring(value27))
      end,
    })

    playerTab:Toggle({
      Title = "Anti-AFK",
      Desc = "Prevents you from being kicked for inactivity!",
      Icon = "clock",
      Type = "Checkbox",
      Default = false,
      Callback = function(value28)
        if getgenv().antiAfkEnabled ~= value28 then
          getgenv().antiAfkEnabled = value28
          print("Anti-AFK Toggle Activated: " .. tostring(value28))

          if value28 then
            f21()

            dist:Notify({
              Title = "Anti-AFK Enabled",
              Content = "You will no longer be kicked for inactivity!",
              Duration = 5,
              Icon = "clock",
            })
          else
            f22()

            dist:Notify({
              Title = "Anti-AFK Disabled",
              Content = "Anti-AFK system stopped.",
              Duration = 5,
              Icon = "clock",
            })
          end
        end
      end,
    })

    userInputService.InputBegan:Connect(function(input, p12)
      if p12 then
        return
      end

      if input.KeyCode == Enum.KeyCode.Space or input.UserInputType == Enum.UserInputType.Touch then
        jumping = true
      end
    end)

    userInputService.InputEnded:Connect(function(input2)
      if input2.KeyCode == Enum.KeyCode.Space
        or input2.UserInputType == Enum.UserInputType.Touch then
        jumping = false
      end
    end)

    task.spawn(function()
      while task.wait(0.05) do
        if getgenv().InfJumpEnabled and jumping then
          local character12 = localPlayer2.Character

          if character12 then
            local humanoid4 = character12:FindFirstChildOfClass("Humanoid")

            if humanoid4 and humanoid4:GetState() ~= Enum.HumanoidStateType.Dead then
              humanoid4:ChangeState(Enum.HumanoidStateType.Jumping)
            end
          end
        end
      end
    end)

    local performanceTab = mainSection:Tab({
      Title = "Performance ",
      Icon = "cpu",
      Locked = false,
    })

    performanceTab:Divider()

    performanceTab:Toggle({
      Title = "Hide Players",
      Default = false,
      Callback = function(value29)
        for key, value30 in pairs(players:GetPlayers()) do
          if value30 ~= players.LocalPlayer then
            local character13 = value30.Character

            if character13 then
              for key2, value31 in pairs(character13:GetDescendants()) do
                if value31:IsA("BasePart") or value31:IsA("Decal") then
                  if not (value31.Name:lower():find("halo")
                    or value31:IsA("Accessory") and value31:FindFirstChildWhichIsA("BasePart")
                      and value31:FindFirstChildWhichIsA("BasePart").Name:lower():find("halo")) then
                    if value29 then
                      if not value31:GetAttribute("OriginalTransparency") then
                        value31:SetAttribute("OriginalTransparency", value31.Transparency)
                      end

                      value31.Transparency = 1
                    else
                      value31.Transparency = value31:GetAttribute("OriginalTransparency") or 0
                    end
                  end
                end
              end
            end
          end
        end
      end,
    })

    performanceTab:Toggle({
      Title = "Hide Halos",
      Default = false,
      Callback = function(value32)
        for key3, value33 in pairs(players:GetPlayers()) do
          if value33 ~= players.LocalPlayer then
            local character14 = value33.Character

            if character14 then
              for key4, value34 in pairs(character14:GetDescendants()) do
                if (value34:IsA("BasePart") and value34.Name:lower():find("halo")
                    or value34:IsA("Accessory") and value34:FindFirstChildWhichIsA("BasePart")
                      and value34:FindFirstChildWhichIsA("BasePart").Name:lower():find("halo"))
                  and (value34:IsA("BasePart") or value34:IsA("Decal")) then
                  if value32 then
                    if not value34:GetAttribute("OriginalTransparency") then
                      value34:SetAttribute("OriginalTransparency", value34.Transparency)
                    end

                    value34.Transparency = 1
                  else
                    value34.Transparency = value34:GetAttribute("OriginalTransparency") or 0
                  end
                end

                if value34:IsA("ParticleEmitter") or value34:IsA("Beam") or value34:IsA("Smoke")
                  or value34:IsA("Fire") or value34:IsA("Sparkles") then
                  local v64 = false
                  local parent = value34.Parent

                  while parent do
                    if parent:IsA("BasePart") and parent.Name:lower():find("halo")
                      or parent:IsA("Accessory") and parent:FindFirstChildWhichIsA("BasePart")
                        and parent:FindFirstChildWhichIsA("BasePart").Name:lower():find("halo") then
                      v64 = true
                      break
                    end

                    parent = parent.Parent
                  end

                  if v64 then
                    value34.Enabled = not value32
                  end
                end
              end
            end
          end
        end
      end,
    })

    performanceTab:Toggle({
      Title = "Hide Trails",
      Default = false,
      Callback = function(value35)
        for key5, value36 in pairs(players:GetPlayers()) do
          if value36 ~= players.LocalPlayer then
            local character15 = value36.Character

            if character15 then
              for key6, value37 in pairs(character15:GetDescendants()) do
                if value37:IsA("Trail") then
                  value37.Enabled = not value35
                end

                if (value37:IsA("ParticleEmitter") or value37:IsA("Beam") or value37:IsA("Smoke")
                    or value37:IsA("Fire") or value37:IsA("Sparkles"))
                  and value37.Parent
                  and value37.Parent:IsA("Trail") then
                  value37.Enabled = not value35
                end
              end
            end
          end
        end
      end,
    })

    performanceTab:Toggle({
      Title = "Hide Usernames",
      Default = false,
      Callback = function(value38)
        for key7, value39 in pairs(players:GetPlayers()) do
          if value39 ~= players.LocalPlayer then
            local character16 = value39.Character

            if character16 then
              for key8, value40 in pairs(character16:GetDescendants()) do
                if value40:IsA("BillboardGui") and value40.Name == "Nametag" then
                  for key9, value41 in pairs(value40:GetChildren()) do
                    if value41:IsA("TextLabel") and value41.Name == "Username" then
                      if value38 then
                        if not value41:GetAttribute("OriginalVisible") then
                          value41:SetAttribute("OriginalVisible", value41.Visible)
                        end

                        value41.Visible = false
                      else
                        value41.Visible = value41:GetAttribute("OriginalVisible") ~= false
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end,
    })

    performanceTab:Toggle({
      Title = "Hide Wins",
      Default = false,
      Callback = function(value42)
        for key10, value43 in pairs(players:GetPlayers()) do
          if value43 ~= players.LocalPlayer then
            local character17 = value43.Character

            if character17 then
              for key11, value44 in pairs(character17:GetDescendants()) do
                if value44:IsA("BillboardGui") and value44.Name == "Nametag" then
                  for key12, value45 in pairs(value44:GetChildren()) do
                    if value45:IsA("TextLabel") and value45.Name == "Wins" then
                      if value42 then
                        if not value45:GetAttribute("OriginalVisible") then
                          value45:SetAttribute("OriginalVisible", value45.Visible)
                        end

                        value45.Visible = false
                      else
                        value45.Visible = value45:GetAttribute("OriginalVisible") ~= false
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end,
    })

    performanceTab:Toggle({
      Title = "Hide Height Bar",
      Default = false,
      Callback = function(value46)
        local playerGui2 = players.LocalPlayer:FindFirstChild("PlayerGui")

        if playerGui2 then
          local heightGui = playerGui2:FindFirstChild("HeightGui")

          if heightGui then
            local frame = heightGui:FindFirstChild("Frame")
            local players2 = heightGui:FindFirstChild("Players")

            if frame then
              if value46 then
                if not frame:GetAttribute("OriginalVisible") then
                  frame:SetAttribute("OriginalVisible", frame.Visible)
                end

                frame.Visible = false
              else
                frame.Visible = frame:GetAttribute("OriginalVisible") ~= false
              end
            end

            if players2 then
              if value46 then
                if not players2:GetAttribute("OriginalVisible") then
                  players2:SetAttribute("OriginalVisible", players2.Visible)
                end

                players2.Visible = false
              else
                players2.Visible = players2:GetAttribute("OriginalVisible") ~= false
              end
            end
          end
        end
      end,
    })

    window:Section({ Title = "Community", Icon = "users", Opened = true }):Tab({
      Title = "Discord",
      Icon = "link",
    }):Button({
      Title = "Join Our Discord",
      Desc = "Click to copy the invite link to clipboard.",
      Icon = "link",
      Callback = function()
        if setclipboard then
          setclipboard("https://discord.gg/XV66VWqAaN")

          dist:Notify({
            Title = "Discord Invite Copied",
            Desc = "Link copied to clipboard! Paste in Discord to join.",
            Duration = 5,
          })
        else
          dist:Notify({
            Title = "Clipboard Unsupported",
            Desc = "Your executor doesn’t support clipboard functions.",
            Duration = 5,
          })
        end
      end,
    })
  end)

  if not v26 then
    warn("Script error:", v27)

    starterGui:SetCore("SendNotification", {
      Title = "Mystrix Hub",
      Text = "Script loaded with errors. Join Discord for help.",
      Duration = 5,
    })
  else
    starterGui:SetCore("SendNotification", {
      Title = "Mystrix Hub",
      Text = "Successfully loaded",
      Duration = 3,
    })
  end
end

local v65 = setmetatable({}, v16)
local v69 = makeTextLabel()
task.wait(0.5)
v65:LoadScript()
task.wait(3)

if v69 then
  v69:Destroy()
end
