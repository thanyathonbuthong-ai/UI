--[[
    ═══════════════════════════════════════════════════════
                 A E R I S   U I   L I B R A R Y
              Custom Violet & White UI Framework
      (diekstrak 1:1 dari AeriesHub.txt - tampilan identik)
    ═══════════════════════════════════════════════════════

    Pakai:
        local Aeris = loadstring(readfile("AerisUI.lua"))()
        local Window = Aeris:CreateWindow({ Title = "My Hub", Subtitle = "My Game" })
        local Tab = Window:CreateTab("Main")
        local Page = Tab:CreatePage("Main")
        local Sec = Page:CreateSection("Movement")
        Sec:AddToggle("Speed", false, function(v) end, { Flag = "Speed" })
]]

local function CreateAerisLibrary()
    local lib = {
        Scheme = {
            AccentColor = Color3.fromRGB(180, 130, 255),
            BackgroundColor = Color3.fromRGB(16, 11, 26),
            MainColor = Color3.fromRGB(24, 17, 38),
            OutlineColor = Color3.fromRGB(200, 170, 255),
            FontColor = Color3.fromRGB(255, 255, 255),
            SubTextColor = Color3.fromRGB(175, 160, 205),
            HoverColor = Color3.fromRGB(48, 34, 72)
        },
        Windows = {},
        Flags = {},
        Options = {},
        Elements = {},
        ShimmerGradients = {},
        MenuKey = Enum.KeyCode.RightShift,
        WatermarkEnabled = true
    }

    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local localPlayer = Players.LocalPlayer

    -- Safe GUI Parent Detection
    local function GetSafeGuiParent()
        local success, parent = pcall(function()
            if gethui then return gethui() end
            local cg = game:GetService("CoreGui")
            local t = Instance.new("Folder", cg)
            t:Destroy()
            return cg
        end)
        if success and parent then return parent end
        return localPlayer:WaitForChild("PlayerGui")
    end

    -- Re-inject guard: script ini sering di-execute ulang buat balikin keadaan (misal
    -- window lagi nyangkut). Tanpa ini GUI lama tetap nempel di CoreGui, jadi numpuk —
    -- window lama yang udah di luar layar pun masih hidup di belakang.
    pcall(function()
        local parent = GetSafeGuiParent()
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("ScreenGui") and (child.Name == "Aeris_MainHub"
                or child.Name == "Aeris_Notifications"
                or child.Name == "Aeris_Watermark") then
                child:Destroy()
            end
        end
    end)

    -- 60 FPS Iridescent Violet & White Shimmer Animation Loop
    RunService.RenderStepped:Connect(function()
        local rot = (tick() * 65) % 360
        for i = #lib.ShimmerGradients, 1, -1 do
            local grad = lib.ShimmerGradients[i]
            if grad and grad.Parent then
                grad.Rotation = rot
            else
                table.remove(lib.ShimmerGradients, i)
            end
        end
    end)

    function lib:ApplyShimmer(parent, thickness)
        local stroke = parent:FindFirstChildOfClass("UIStroke")
        if not stroke then
            stroke = Instance.new("UIStroke")
            stroke.Thickness = thickness or 1.8
            stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            stroke.Color = Color3.fromRGB(255, 255, 255)
            stroke.Transparency = 0.2
            stroke.Parent = parent
        end
        local grad = stroke:FindFirstChildOfClass("UIGradient")
        if not grad then
            grad = Instance.new("UIGradient")
            grad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(0.20, Color3.fromRGB(185, 120, 255)),
                ColorSequenceKeypoint.new(0.40, Color3.fromRGB(240, 220, 255)),
                ColorSequenceKeypoint.new(0.60, Color3.fromRGB(140, 60, 240)),
                ColorSequenceKeypoint.new(0.80, Color3.fromRGB(210, 170, 255)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))
            })
            grad.Parent = stroke
            table.insert(lib.ShimmerGradients, grad)
        end
        return stroke, grad
    end

    -- Modern Toast Notifications System
    local notifyGui = Instance.new("ScreenGui")
    notifyGui.Name = "Aeris_Notifications"
    notifyGui.IgnoreGuiInset = true
    notifyGui.DisplayOrder = 100000
    notifyGui.ResetOnSpawn = false
    notifyGui.Parent = GetSafeGuiParent()

    local notifyList = Instance.new("Frame")
    notifyList.Name = "NotifyContainer"
    notifyList.AnchorPoint = Vector2.new(1, 1)
    notifyList.Position = UDim2.new(1, -20, 1, -20)
    notifyList.Size = UDim2.new(0, 320, 1, -40)
    notifyList.BackgroundTransparency = 1
    notifyList.Parent = notifyGui

    local notifyLayout = Instance.new("UIListLayout")
    notifyLayout.FillDirection = Enum.FillDirection.Vertical
    notifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    notifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    notifyLayout.Padding = UDim.new(0, 10)
    notifyLayout.Parent = notifyList

    function lib:Notify(config)
        config = type(config) == "table" and config or { Title = "Aeris", Description = tostring(config), Duration = 3 }
        local title = config.Title or "Aeris Hub"
        local desc = config.Description or ""
        local duration = tonumber(config.Duration) or 3

        local card = Instance.new("Frame")
        card.Name = "NotifyCard"
        card.Size = UDim2.new(1, 0, 0, 66)
        card.BackgroundColor3 = Color3.fromRGB(18, 12, 30)
        card.BackgroundTransparency = 0.15
        card.BorderSizePixel = 0
        card.ClipsDescendants = true
        card.Parent = notifyList

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = card

        lib:ApplyShimmer(card, 1.5)

        local accent = Instance.new("Frame")
        accent.Size = UDim2.new(0, 4, 1, 0)
        accent.BackgroundColor3 = Color3.fromRGB(180, 130, 255)
        accent.BorderSizePixel = 0
        accent.Parent = card

        local tLabel = Instance.new("TextLabel")
        tLabel.Text = title
        tLabel.Font = Enum.Font.GothamBold
        tLabel.TextSize = 14
        tLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        tLabel.TextXAlignment = Enum.TextXAlignment.Left
        tLabel.BackgroundTransparency = 1
        tLabel.Position = UDim2.new(0, 14, 0, 10)
        tLabel.Size = UDim2.new(1, -24, 0, 18)
        tLabel.Parent = card

        local dLabel = Instance.new("TextLabel")
        dLabel.Text = desc
        dLabel.Font = Enum.Font.Gotham
        dLabel.TextSize = 12
        dLabel.TextColor3 = Color3.fromRGB(200, 190, 225)
        dLabel.TextXAlignment = Enum.TextXAlignment.Left
        dLabel.BackgroundTransparency = 1
        dLabel.Position = UDim2.new(0, 14, 0, 30)
        dLabel.Size = UDim2.new(1, -24, 0, 24)
        dLabel.TextWrapped = true
        dLabel.Parent = card

        local prog = Instance.new("Frame")
        prog.Size = UDim2.new(1, 0, 0, 2)
        prog.Position = UDim2.new(0, 0, 1, -2)
        prog.BackgroundColor3 = Color3.fromRGB(190, 140, 255)
        prog.BorderSizePixel = 0
        prog.Parent = card

        card.Position = UDim2.new(1, 50, 0, 0)
        TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()

        TweenService:Create(prog, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 0, 0, 2)
        }):Play()

        task.delay(duration, function()
            if card and card.Parent then
                local outTween = TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                    Position = UDim2.new(1, 50, 0, 0),
                    BackgroundTransparency = 1
                })
                outTween:Play()
                outTween.Completed:Wait()
                card:Destroy()
            end
        end)
    end

    -- Modern Floating Watermark
    local watermarkGui = Instance.new("ScreenGui")
    watermarkGui.Name = "Aeris_Watermark"
    watermarkGui.IgnoreGuiInset = true
    watermarkGui.DisplayOrder = 99998
    watermarkGui.ResetOnSpawn = false
    watermarkGui.Parent = GetSafeGuiParent()

    local watermarkFrame = Instance.new("Frame")
    watermarkFrame.Name = "WatermarkFrame"
    watermarkFrame.Position = UDim2.new(0, 20, 0, 16)
    watermarkFrame.Size = UDim2.new(0, 260, 0, 32)
    watermarkFrame.BackgroundColor3 = Color3.fromRGB(18, 12, 30)
    watermarkFrame.BackgroundTransparency = 0.25
    watermarkFrame.BorderSizePixel = 0
    watermarkFrame.Parent = watermarkGui
    -- Default OFF: badge "Aeris" nggak nempel di layar. Bisa dinyalain lagi
    -- dari Settings > UI Config > Watermark.
    watermarkFrame.Visible = false

    local wmCorner = Instance.new("UICorner")
    wmCorner.CornerRadius = UDim.new(0, 8)
    wmCorner.Parent = watermarkFrame

    lib:ApplyShimmer(watermarkFrame, 1.5)

    local wmLogo = Instance.new("ImageLabel")
    wmLogo.Image = "rbxassetid://94398897297532"
    wmLogo.Size = UDim2.new(0, 22, 0, 22)
    wmLogo.Position = UDim2.new(0, 6, 0.5, -11)
    wmLogo.BackgroundTransparency = 1
    wmLogo.ScaleType = Enum.ScaleType.Fit
    wmLogo.Parent = watermarkFrame

    local wmLabel = Instance.new("TextLabel")
    wmLabel.Text = (lib.WatermarkText or "Aeris Hub | Violence District") .. " | FPS: 60"
    wmLabel.Font = Enum.Font.GothamMedium
    wmLabel.TextSize = 12
    wmLabel.TextColor3 = Color3.fromRGB(240, 230, 255)
    wmLabel.BackgroundTransparency = 1
    wmLabel.Position = UDim2.new(0, 34, 0, 0)
    wmLabel.Size = UDim2.new(1, -40, 1, 0)
    wmLabel.TextXAlignment = Enum.TextXAlignment.Left
    wmLabel.Parent = watermarkFrame

    task.spawn(function()
        local frameCount = 0
        local lastTime = os.clock()
        RunService.RenderStepped:Connect(function()
            frameCount = frameCount + 1
            local now = os.clock()
            if now - lastTime >= 1 then
                local fps = math.round(frameCount / (now - lastTime))
                frameCount = 0
                lastTime = now
                if wmLabel and wmLabel.Parent then
                    wmLabel.Text = string.format("%s | FPS: %d", lib.WatermarkText or "Aeris Hub | Violence District", fps)
                end
            end
        end)
    end)

    function lib:SetWatermark(opt)
        if type(opt) == "table" then
            watermarkFrame.Visible = opt.Enabled ~= false
        elseif type(opt) == "boolean" then
            watermarkFrame.Visible = opt
        end
    end

    -- Main Window Constructor
    function lib:CreateWindow(config)
        config = config or {}
        local windowTitle = config.Title or "Aeris Hub"
        local windowSubtitle = config.Subtitle or "Violence District"
        local logoAsset = config.Logo or "rbxassetid://94398897297532"

        local mainGui = Instance.new("ScreenGui")
        mainGui.Name = "Aeris_MainHub"
        mainGui.IgnoreGuiInset = true
        mainGui.DisplayOrder = 50
        mainGui.ResetOnSpawn = false
        mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        mainGui.Parent = GetSafeGuiParent()

        local mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainWindow"
        mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        mainFrame.Size = UDim2.new(0, 690, 0, 470)
        mainFrame.BackgroundColor3 = Color3.fromRGB(16, 11, 26)
        mainFrame.BackgroundTransparency = 0.20
        mainFrame.BorderSizePixel = 0
        mainFrame.ClipsDescendants = false
        mainFrame.Parent = mainGui

        -- FIX HP: window 690x470 px itu kebesaran di layar HP. UIScale dipasang di
        -- frame-nya (bukan di ScreenGui) supaya notifikasi/splash nggak ikut mengecil,
        -- dan geser-geser window tetap 1:1 px.
        local uiScale = Instance.new("UIScale")
        uiScale.Name = "AerisUIScale"
        uiScale.Scale = 1
        uiScale.Parent = mainFrame
        lib.UIScale = uiScale
        lib.AutoFitHP = true
        -- Zoom default 120%. Window desain 690x470 px itu kecil di layar modern
        -- (cuma ~35% lebar layar di HP 1080p+), jadi default-nya dibesarin. Auto-fit
        -- di bawah yang nahan biar nggak lewat layar kalau layarnya sempit.
        -- Sengaja TIDAK digantung di UserInputService.TouchEnabled: sebagian executor
        -- nggak nge-set flag itu dengan bener, dan kalau salah deteksi ukurannya balik
        -- ke 100% tanpa kelihatan sebabnya.
        lib.DefaultUserScale = 1.2
        lib.UserScale = lib.DefaultUserScale

        local DESIGN_W, DESIGN_H = 690, 470 -- ukuran asli window (px desain)

        function lib:ApplyUIScale()
            -- Dua angka ini DIKALI, jangan pernah ditukar jadi math.min():
            --   fit       = skala dasar biar window muat layar (auto-fit, maks 100%)
            --   UserScale = zoom pilihan user (default 120%), dikali di atas fit
            -- Sempat ditulis math.min(UserScale, fit) dan itu bikin slider UI Scale
            -- MATI di layar kecil: kalau fit = 0.52, semua nilai slider di atas 52%
            -- langsung dipotong balik ke 0.52 — angkanya berubah tapi window-nya nggak.
            local fit = 1
            if lib.AutoFitHP then
                local camScale = workspace.CurrentCamera
                local vp = (camScale and camScale.ViewportSize) or Vector2.new(1280, 720)
                local availX, availY = vp.X, vp.Y
                -- Kurangi top bar + chat button: window ini IgnoreGuiInset, jadi
                -- tanpa ini header-nya ketutup bar Roblox di HP.
                pcall(function()
                    local inset = game:GetService("GuiService"):GetGuiInset()
                    availX = math.max(160, vp.X - inset.X * 2)
                    availY = math.max(120, vp.Y - inset.Y * 2)
                end)
                -- Window boleh makan maks 95% lebar & 92% tinggi area kepake. Fit cuma
                -- bisa ngecil (max 1): layar gede nggak bikin window auto-membengkak,
                -- pembesaran tetap keputusan user lewat slider UI Scale.
                fit = math.min(1, (availX * 0.95) / DESIGN_W, (availY * 0.92) / DESIGN_H)
            end
            -- Sengaja TANPA cap tambahan dari fit: kalau slider dinaikin sampai window
            -- lewat layar, itu pilihan user. Posisinya tetap ditahan keepOnScreen()
            -- supaya header-nya nggak pernah kabur keluar layar.
            uiScale.Scale = math.clamp(fit * (lib.UserScale or 1), 0.30, 1.6)
            -- Skala berubah = ukuran window di layar berubah, jadi window yang tadinya
            -- pas bisa jadi udah lewat bibir layar. Clamp ulang posisinya (helper-nya
            -- didefinisiin di bawah, makanya dicek dulu biar aman saat load awal).
            if lib.KeepWindowOnScreen then
                pcall(function() lib:KeepWindowOnScreen() end)
            end
        end

        -- Angka ini dilaporin lewat notifikasi tiap kali skala berubah: tanpa ini
        -- susah nebak device-nya butuh berapa persen.
        function lib:UIScaleInfo()
            local camScale = workspace.CurrentCamera
            local vp = (camScale and camScale.ViewportSize) or Vector2.new(0, 0)
            local sc = uiScale.Scale or 1
            return string.format("scale %.0f%% | layar %dx%d | window %.0fx%.0f px",
                sc * 100, vp.X, vp.Y, DESIGN_W * sc, DESIGN_H * sc)
        end
        lib:ApplyUIScale()
        pcall(function()
            local camScale = workspace.CurrentCamera
            if camScale then
                camScale:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                    pcall(function() lib:ApplyUIScale() end)
                end)
            end
        end)

        -- ===== ANTI WINDOW NYANGKUT DI LUAR LAYAR =====
        -- Dulu window bisa di-drag sampai header-nya lewat atas layar. Begitu header
        -- hilang, udah nggak ada bagian yang bisa dipegang buat narik balik, jadi
        -- satu-satunya jalan adalah re-execute script. Sekarang tiap geser / resize /
        -- perubahan skala posisinya di-clamp, dan "Lock GUI" beneran ngunci drag.
        local WIN_EDGE_MARGIN = 6 -- jarak minimal window ke pinggir layar (px)
        local winLocked = false   -- di-set lewat window:SetLocked()

        local function frameUiScale(frame)
            local s = frame:FindFirstChildOfClass("UIScale")
            return math.max((s and s.Scale) or 1, 0.05)
        end

        -- Geser frame sejauh (dx, dy) piksel LAYAR. UIScale bikin offset Position ikut
        -- di-skala, tapi itu jangan diasumsiin: geser pakai tebakan skala, ukur hasil
        -- aslinya lewat AbsolutePosition, lalu koreksi sisanya pakai faktor hasil ukur.
        local function shiftByScreenPixels(frame, dx, dy)
            if math.abs(dx) < 0.5 and math.abs(dy) < 0.5 then return end

            local sc = frameUiScale(frame)
            local before = frame.AbsolutePosition
            local p0 = frame.Position
            local stepX = (math.abs(dx) >= 0.5) and (dx / sc) or 0
            local stepY = (math.abs(dy) >= 0.5) and (dy / sc) or 0

            frame.Position = UDim2.new(p0.X.Scale, p0.X.Offset + stepX, p0.Y.Scale, p0.Y.Offset + stepY)

            local after = frame.AbsolutePosition
            local movedX, movedY = after.X - before.X, after.Y - before.Y
            local errX, errY = dx - movedX, dy - movedY
            if math.abs(errX) < 0.5 and math.abs(errY) < 0.5 then return end

            -- px layar per 1 satuan offset — dari hasil ukur, bukan tebakan
            local kx = (math.abs(stepX) > 0.001) and (movedX / stepX) or sc
            local ky = (math.abs(stepY) > 0.001) and (movedY / stepY) or sc
            if math.abs(kx) < 0.05 then kx = sc end
            if math.abs(ky) < 0.05 then ky = sc end

            local p1 = frame.Position
            frame.Position = UDim2.new(
                p1.X.Scale, p1.X.Offset + errX / kx,
                p1.Y.Scale, p1.Y.Offset + errY / ky
            )
        end

        -- Paksa frame tetap utuh di dalam viewport. Kalau frame-nya lebih gede dari layar
        -- (misal window udah di-zoom gede), dia dipaku ke pinggir atas/kiri supaya bagian
        -- header-nya — satu-satunya tempat buat drag — tetap kelihatan dan kejangkau.
        local function keepOnScreen(frame, margin)
            local camScale = workspace.CurrentCamera
            local vp = (camScale and camScale.ViewportSize) or Vector2.new(1280, 720)
            local m = margin or WIN_EDGE_MARGIN
            local ap = frame.AbsolutePosition
            local as = frame.AbsoluteSize

            local function fixAxis(a, size, vpSize)
                local maxA = vpSize - m - size
                if maxA < m then return m - a end -- lebih gede dari layar: paku kiri/atas
                if a < m then return m - a end
                if a > maxA then return maxA - a end
                return 0
            end

            shiftByScreenPixels(frame, fixAxis(ap.X, as.X, vp.X), fixAxis(ap.Y, as.Y, vp.Y))
        end

        function lib:KeepWindowOnScreen()
            keepOnScreen(mainFrame)
        end

        function lib:ResetWindowPosition()
            mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            keepOnScreen(mainFrame)
        end

        local mainCorner = Instance.new("UICorner")
        mainCorner.CornerRadius = UDim.new(0, 14)
        mainCorner.Parent = mainFrame

        lib:ApplyShimmer(mainFrame, 2.2)

        -- Header Frame (Draggable)
        local header = Instance.new("Frame")
        header.Name = "Header"
        header.Size = UDim2.new(1, 0, 0, 52)
        header.BackgroundColor3 = Color3.fromRGB(22, 15, 36)
        header.BackgroundTransparency = 0.35
        header.BorderSizePixel = 0
        header.Parent = mainFrame

        local headerCorner = Instance.new("UICorner")
        headerCorner.CornerRadius = UDim.new(0, 14)
        headerCorner.Parent = header

        local headerMask = Instance.new("Frame")
        headerMask.Size = UDim2.new(1, 0, 0, 14)
        headerMask.Position = UDim2.new(0, 0, 1, -14)
        headerMask.BackgroundColor3 = Color3.fromRGB(22, 15, 36)
        headerMask.BackgroundTransparency = 0.35
        headerMask.BorderSizePixel = 0
        headerMask.Parent = header

        local headerLine = Instance.new("Frame")
        headerLine.Size = UDim2.new(1, 0, 0, 1)
        headerLine.Position = UDim2.new(0, 0, 1, 0)
        headerLine.BackgroundColor3 = Color3.fromRGB(160, 110, 225)
        headerLine.BackgroundTransparency = 0.7
        headerLine.BorderSizePixel = 0
        headerLine.Parent = header

        local logoImg = Instance.new("ImageLabel")
        logoImg.Name = "Logo"
        logoImg.Image = logoAsset
        logoImg.Size = UDim2.new(0, 36, 0, 36)
        logoImg.Position = UDim2.new(0, 12, 0.5, -18)
        logoImg.BackgroundTransparency = 1
        logoImg.ScaleType = Enum.ScaleType.Fit
        logoImg.Parent = header

        local logoCorner = Instance.new("UICorner")
        logoCorner.CornerRadius = UDim.new(0, 8)
        logoCorner.Parent = logoImg

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Text = windowTitle
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = 17
        titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.BackgroundTransparency = 1
        titleLbl.Position = UDim2.new(0, 56, 0, 8)
        titleLbl.Size = UDim2.new(0, 200, 0, 20)
        titleLbl.Parent = header

        local subLbl = Instance.new("TextLabel")
        subLbl.Text = windowSubtitle
        subLbl.Font = Enum.Font.GothamMedium
        subLbl.TextSize = 11
        subLbl.TextColor3 = Color3.fromRGB(185, 160, 225)
        subLbl.TextXAlignment = Enum.TextXAlignment.Left
        subLbl.BackgroundTransparency = 1
        subLbl.Position = UDim2.new(0, 56, 0, 28)
        subLbl.Size = UDim2.new(0, 200, 0, 16)
        subLbl.Parent = header

        -- Controls on header
        local controlsFrame = Instance.new("Frame")
        controlsFrame.Size = UDim2.new(0, 70, 1, 0)
        controlsFrame.Position = UDim2.new(1, -75, 0, 0)
        controlsFrame.BackgroundTransparency = 1
        controlsFrame.Parent = header

        local minBtn = Instance.new("TextButton")
        minBtn.Name = "MinBtn"
        minBtn.Text = "-"
        minBtn.Font = Enum.Font.GothamBold
        minBtn.TextSize = 18
        minBtn.TextColor3 = Color3.fromRGB(220, 210, 240)
        minBtn.Size = UDim2.new(0, 28, 0, 28)
        minBtn.Position = UDim2.new(0, 0, 0.5, -14)
        minBtn.BackgroundColor3 = Color3.fromRGB(40, 28, 60)
        minBtn.BackgroundTransparency = 0.5
        minBtn.Parent = controlsFrame

        local minCorner = Instance.new("UICorner")
        minCorner.CornerRadius = UDim.new(0, 6)
        minCorner.Parent = minBtn

        local closeBtn = Instance.new("TextButton")
        closeBtn.Name = "CloseBtn"
        closeBtn.Text = "X"
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 13
        closeBtn.TextColor3 = Color3.fromRGB(255, 140, 160)
        closeBtn.Size = UDim2.new(0, 28, 0, 28)
        closeBtn.Position = UDim2.new(0, 36, 0.5, -14)
        closeBtn.BackgroundColor3 = Color3.fromRGB(40, 28, 60)
        closeBtn.BackgroundTransparency = 0.5
        closeBtn.Parent = controlsFrame

        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 6)
        closeCorner.Parent = closeBtn

        -- Smooth Dragging (di-clamp biar nggak keluar layar, dan dilock pas Lock GUI ON)
        local isDragging = false
        local dragStart, startPos
        header.InputBegan:Connect(function(input)
            if winLocked then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        isDragging = false
                    end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if isDragging and not winLocked and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                -- begitu header lewat bibir layar, nggak ada lagi pegangan buat narik
                -- window balik — jadi ditahan di dalam viewport
                keepOnScreen(mainFrame)
            end
        end)

        -- Left Sidebar for Tabs
        local sidebar = Instance.new("Frame")
        sidebar.Name = "Sidebar"
        sidebar.Size = UDim2.new(0, 160, 1, -53)
        sidebar.Position = UDim2.new(0, 0, 0, 53)
        sidebar.BackgroundColor3 = Color3.fromRGB(18, 12, 30)
        sidebar.BackgroundTransparency = 0.35
        sidebar.BorderSizePixel = 0
        sidebar.Parent = mainFrame

        local sidebarCorner = Instance.new("UICorner")
        sidebarCorner.CornerRadius = UDim.new(0, 14)
        sidebarCorner.Parent = sidebar

        local sidebarDivider = Instance.new("Frame")
        sidebarDivider.Size = UDim2.new(0, 1, 1, 0)
        sidebarDivider.Position = UDim2.new(1, -1, 0, 0)
        sidebarDivider.BackgroundColor3 = Color3.fromRGB(160, 110, 225)
        sidebarDivider.BackgroundTransparency = 0.7
        sidebarDivider.BorderSizePixel = 0
        sidebarDivider.Parent = sidebar

        local tabList = Instance.new("ScrollingFrame")
        tabList.Name = "TabList"
        tabList.Size = UDim2.new(1, -16, 1, -96)
        tabList.Position = UDim2.new(0, 8, 0, 8)
        tabList.BackgroundTransparency = 1
        tabList.ScrollBarThickness = 0
        tabList.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tabList.Parent = sidebar

        -- User Profile Card (Bottom Left Corner)
        local profileCard = Instance.new("Frame")
        profileCard.Name = "UserProfileCard"
        profileCard.Position = UDim2.new(0, 8, 1, -82)
        profileCard.Size = UDim2.new(1, -16, 0, 74)
        profileCard.BackgroundColor3 = Color3.fromRGB(22, 14, 36)
        profileCard.BackgroundTransparency = 0.35
        profileCard.BorderSizePixel = 0
        profileCard.Parent = sidebar

        local pCorner = Instance.new("UICorner")
        pCorner.CornerRadius = UDim.new(0, 10)
        pCorner.Parent = profileCard

        lib:ApplyShimmer(profileCard, 1.2)

        -- Avatar Headshot
        local avatarImg = Instance.new("ImageLabel")
        avatarImg.Name = "Avatar"
        avatarImg.Size = UDim2.new(0, 38, 0, 38)
        avatarImg.Position = UDim2.new(0, 6, 0.5, -19)
        avatarImg.BackgroundColor3 = Color3.fromRGB(35, 22, 55)
        avatarImg.BackgroundTransparency = 0.3
        avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(localPlayer.UserId) .. "&w=150&h=150"
        avatarImg.Parent = profileCard

        local avCorner = Instance.new("UICorner")
        avCorner.CornerRadius = UDim.new(1, 0)
        avCorner.Parent = avatarImg

        local avStroke = Instance.new("UIStroke")
        avStroke.Thickness = 1.2
        avStroke.Color = Color3.fromRGB(180, 130, 255)
        avStroke.Transparency = 0.4
        avStroke.Parent = avatarImg

        task.spawn(function()
            pcall(function()
                local content, isReady = Players:GetUserThumbnailAsync(localPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                if isReady and content and content ~= "" then
                    avatarImg.Image = content
                end
            end)
        end)

        -- Display Name
        local dName = Instance.new("TextLabel")
        dName.Name = "DisplayName"
        dName.Text = localPlayer.DisplayName or localPlayer.Name
        dName.Font = Enum.Font.GothamBold
        dName.TextSize = 12
        dName.TextColor3 = Color3.fromRGB(255, 255, 255)
        dName.TextXAlignment = Enum.TextXAlignment.Left
        dName.TextTruncate = Enum.TextTruncate.AtEnd
        dName.BackgroundTransparency = 1
        dName.Position = UDim2.new(0, 50, 0, 8)
        dName.Size = UDim2.new(1, -54, 0, 15)
        dName.Parent = profileCard

        local tabLayout = Instance.new("UIListLayout")
        tabLayout.FillDirection = Enum.FillDirection.Vertical
        tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        tabLayout.Padding = UDim.new(0, 6)
        tabLayout.Parent = tabList

        -- Content Area
        local contentArea = Instance.new("Frame")
        contentArea.Name = "ContentArea"
        contentArea.Size = UDim2.new(1, -162, 1, -54)
        contentArea.Position = UDim2.new(0, 161, 0, 53)
        contentArea.BackgroundTransparency = 1
        contentArea.ClipsDescendants = true
        contentArea.Parent = mainFrame

        -- Bottom-Right Window Resize Handle (with min/max limits)
        local resizeGrip = Instance.new("Frame")
        resizeGrip.Name = "ResizeGrip"
        resizeGrip.AnchorPoint = Vector2.new(1, 1)
        resizeGrip.Position = UDim2.new(1, -2, 1, -2)
        resizeGrip.Size = UDim2.new(0, 18, 0, 18)
        resizeGrip.BackgroundTransparency = 1
        resizeGrip.ZIndex = 80
        resizeGrip.Parent = mainFrame

        -- 3 Diagonal grip lines
        for i = 1, 3 do
            local gLine = Instance.new("Frame")
            gLine.Size = UDim2.new(0, 13 - (i-1)*4, 0, 2)
            gLine.AnchorPoint = Vector2.new(1, 1)
            gLine.Position = UDim2.new(1, -2, 1, -2 - (i-1)*4)
            gLine.BackgroundColor3 = Color3.fromRGB(190, 150, 255)
            gLine.BackgroundTransparency = 0.35
            gLine.BorderSizePixel = 0
            gLine.ZIndex = 81
            gLine.Parent = resizeGrip
            local glc = Instance.new("UICorner")
            glc.CornerRadius = UDim.new(0, 1)
            glc.Parent = gLine
        end

        local isResizing = false
        local resizeStartMouse, resizeStartSize
        resizeGrip.InputBegan:Connect(function(input)
            if winLocked then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isResizing = true
                resizeStartMouse = input.Position
                resizeStartSize = mainFrame.AbsoluteSize
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        isResizing = false
                    end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if isResizing and not winLocked and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - resizeStartMouse
                -- Limits: Min width 580px, Max width 1100px; Min height 380px, Max height 750px
                local newW = math.clamp(resizeStartSize.X + delta.X, 580, 1100)
                local newH = math.clamp(resizeStartSize.Y + delta.Y, 380, 750)
                mainFrame.Size = UDim2.new(0, newW, 0, newH)
                -- gedein window bisa bikin sisi kanan/bawahnya lewat layar
                keepOnScreen(mainFrame)
            end
        end)

        local window = {
            Gui = mainGui,
            Frame = mainFrame,
            Tabs = {},
            CurrentTab = nil,
            IsMinimized = false,
            IsLocked = false
        }

        local originalSize = mainFrame.Size

        -- Minimize nggak lagi ninggalin "pill" setengah-setengah: sekarang sembunyi
        -- total ke tombol floating di pojok kanan atas. Handler minBtn-nya dipasang
        -- di bawah bareng closeBtn, karena butuh SetMenuOpen yang baru ada setelah blok ini.

        -- Floating Mobile / Quick-Open Toggle Button
        local alwaysShowMobile = false
        local mobileToggle = Instance.new("TextButton")
        mobileToggle.Name = "AerisMobileToggle"
        mobileToggle.Size = UDim2.new(0, 48, 0, 48)
        -- Dikunci di pojok KANAN ATAS. mainGui.IgnoreGuiInset = true, jadi Y-nya harus
        -- digeser sejauh tinggi top bar Roblox; kalau nggak, tombolnya ketiban bar.
        mobileToggle.AnchorPoint = Vector2.new(1, 0)
        mobileToggle.Position = UDim2.new(1, -14, 0, 14)
        mobileToggle.BackgroundColor3 = Color3.fromRGB(22, 14, 36)
        mobileToggle.BackgroundTransparency = 0.25
        mobileToggle.BorderSizePixel = 0
        mobileToggle.Text = ""
        mobileToggle.AutoButtonColor = false
        mobileToggle.Visible = false
        mobileToggle.ZIndex = 200
        mobileToggle.Parent = mainGui

        local mtCorner = Instance.new("UICorner")
        mtCorner.CornerRadius = UDim.new(0, 24)
        mtCorner.Parent = mobileToggle

        local mtStroke = Instance.new("UIStroke")
        mtStroke.Thickness = 1.5
        mtStroke.Color = Color3.fromRGB(180, 120, 255)
        mtStroke.Transparency = 0.3
        mtStroke.Parent = mobileToggle

        local mtLogo = Instance.new("ImageLabel")
        mtLogo.Name = "Logo"
        mtLogo.Size = UDim2.new(1, -12, 1, -12)
        mtLogo.Position = UDim2.new(0, 6, 0, 6)
        mtLogo.BackgroundTransparency = 1
        mtLogo.Image = logoAsset
        mtLogo.ImageColor3 = Color3.fromRGB(240, 230, 255)
        mtLogo.ScaleType = Enum.ScaleType.Fit
        mtLogo.ZIndex = 201
        mtLogo.Parent = mobileToggle

        lib:ApplyShimmer(mobileToggle, 1.5)

        -- Posisi tombol floating: pojok kanan atas, di bawah top bar Roblox.
        local function placeMobileToggle()
            local insetTop = 0
            pcall(function()
                insetTop = game:GetService("GuiService"):GetGuiInset().Y
            end)
            mobileToggle.Position = UDim2.new(1, -14, 0, insetTop + 14)
        end
        placeMobileToggle()

        pcall(function()
            local camScale = workspace.CurrentCamera
            if camScale then
                camScale:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                    pcall(placeMobileToggle)
                end)
            end
        end)

        local isMenuOpen = true
        local lastToggleTick = 0

        local function SetMenuOpen(open)
            local now = tick()
            if now - lastToggleTick < 0.25 then return end
            lastToggleTick = now

            isMenuOpen = open == true
            if isMenuOpen then
                mainFrame.Visible = true
                mainFrame.BackgroundTransparency = 0.20
                if not window.IsMinimized then
                    sidebar.Visible = true
                    contentArea.Visible = true
                end

                if not alwaysShowMobile then
                    mobileToggle.Visible = false
                end
            else
                mainFrame.Visible = false

                mobileToggle.Visible = true
                mobileToggle.BackgroundTransparency = 0.25
                mtLogo.ImageTransparency = 0
            end
        end

        local function ToggleMenu()
            SetMenuOpen(not isMenuOpen)
        end

        -- Clean Dragging & Clicking for Mobile/Desktop Toggle Button
        local isDraggingMT = false
        local dragStartPos = nil
        local startPosMT = nil
        local hasDragged = false

        mobileToggle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDraggingMT = true
                hasDragged = false
                dragStartPos = input.Position
                startPosMT = mobileToggle.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if isDraggingMT and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                if dragStartPos and startPosMT then
                    local delta = input.Position - dragStartPos
                    if delta.Magnitude > 8 then
                        hasDragged = true
                        mobileToggle.Position = UDim2.new(
                            startPosMT.X.Scale,
                            startPosMT.X.Offset + delta.X,
                            startPosMT.Y.Scale,
                            startPosMT.Y.Offset + delta.Y
                        )
                        -- tombol buka menu ini juga dijaga: kalau dia hilang keluar layar,
                        -- menu udah nggak bisa dibuka lagi dari HP
                        keepOnScreen(mobileToggle, 4)
                    end
                end
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if isDraggingMT then
                    isDraggingMT = false
                    if not hasDragged then
                        SetMenuOpen(true)
                    end
                end
            end
        end)

        -- Backup click handler for mobileToggle
        mobileToggle.MouseButton1Click:Connect(function()
            if not hasDragged then
                SetMenuOpen(true)
            end
        end)

        closeBtn.MouseButton1Click:Connect(function()
            SetMenuOpen(false)
        end)

        -- Tombol minimize (-) = sembunyi total, sama kayak close: window ditutup dan
        -- yang kelihatan cuma tombol floating di pojok kanan atas. Nggak ada bar/pill
        -- yang bisa kesenggol terus kebuka sendiri pas lagi main.
        minBtn.MouseButton1Click:Connect(function()
            SetMenuOpen(false)
        end)

        UserInputService.InputBegan:Connect(function(input, gpe)
            if not gpe and input.KeyCode == lib.MenuKey then
                ToggleMenu()
            end
        end)

        function window:SetMenuKey(key)
            if typeof(key) == "EnumItem" then
                lib.MenuKey = key
            elseif type(key) == "string" and Enum.KeyCode[key] then
                lib.MenuKey = Enum.KeyCode[key]
            end
        end

        -- Balikin ukuran window ke ukuran desain (690x470). Perlu karena resize grip
        -- nggak punya jalan balik: begitu ditarik gede, ukurannya nempel sampai
        -- script di-execute ulang.
        function window:ResetWindowSize()
            mainFrame.Size = originalSize
            window.IsMinimized = false
            keepOnScreen(mainFrame)
        end

        -- Lock GUI: beneran ngunci drag + resize. Sebelumnya cuma nyimpen flag yang
        -- nggak ada satu pun pengeceknya, jadi toggle-nya kelihatan nyala padahal
        -- window masih bisa digeser-geser.
        function window:SetLocked(bool)
            window.IsLocked = bool == true
            winLocked = bool == true
            if resizeGrip then
                resizeGrip.Visible = not winLocked
            end
        end

        function window:SetAlwaysShowMobileButton(bool)
            alwaysShowMobile = bool == true
            if alwaysShowMobile then
                mobileToggle.Visible = true
                mobileToggle.BackgroundTransparency = 0.25
                mtLogo.ImageTransparency = 0
            elseif isMenuOpen then
                mobileToggle.Visible = false
            end
        end

        function window:ToggleMenu()
            ToggleMenu()
        end

        -- (tambahan) dipanggil script asli lewat v:SetTransparency / v:ResetWindowPosition
        -- tapi di aslinya nggak pernah didefinisiin di object window.
        function window:SetTransparency(n)
            n = math.clamp(tonumber(n) or 0.20, 0, 1)
            mainFrame.BackgroundTransparency = n
        end

        function window:ResetWindowPosition()
            lib:ResetWindowPosition()
        end

        local TAB_DEFAULT_ICONS = {
            ["Main"] = "rbxassetid://10723345749",       -- Home
            ["Survivor"] = "rbxassetid://10709791437",   -- Shield / Survivor
            ["Killer"] = "rbxassetid://10734950309",     -- Crossed Swords
            ["Visual"] = "rbxassetid://10709769841",     -- Eye / ESP
            ["Teleport"] = "rbxassetid://10723346959",   -- MapPin / Teleport
            ["Settings"] = "rbxassetid://10734950020",   -- Settings Gear
        }

        function window:CreateTab(tabName, icon, ...)
            local iconAsset = (type(icon) == "string" and icon ~= "") and icon or (TAB_DEFAULT_ICONS[tabName] or "rbxassetid://10723345749")

            local tabBtn = Instance.new("TextButton")
            tabBtn.Name = "Tab_" .. tabName
            tabBtn.Size = UDim2.new(1, 0, 0, 38)
            tabBtn.BackgroundColor3 = Color3.fromRGB(30, 20, 50)
            tabBtn.BackgroundTransparency = 0.7
            tabBtn.BorderSizePixel = 0
            tabBtn.Text = ""
            tabBtn.AutoButtonColor = false
            tabBtn.Parent = tabList

            -- Tab Icon Image
            local tabIcon = Instance.new("ImageLabel")
            tabIcon.Name = "Icon"
            tabIcon.Image = iconAsset
            tabIcon.Size = UDim2.new(0, 18, 0, 18)
            tabIcon.Position = UDim2.new(0, 12, 0.5, -9)
            tabIcon.BackgroundTransparency = 1
            tabIcon.ImageColor3 = Color3.fromRGB(180, 160, 220)
            tabIcon.ScaleType = Enum.ScaleType.Fit
            tabIcon.Parent = tabBtn

            -- Tab Title Text
            local tabTitle = Instance.new("TextLabel")
            tabTitle.Name = "Title"
            tabTitle.Text = tabName
            tabTitle.Font = Enum.Font.GothamMedium
            tabTitle.TextSize = 13
            tabTitle.TextColor3 = Color3.fromRGB(200, 185, 230)
            tabTitle.TextXAlignment = Enum.TextXAlignment.Left
            tabTitle.BackgroundTransparency = 1
            tabTitle.Position = UDim2.new(0, 38, 0, 0)
            tabTitle.Size = UDim2.new(1, -44, 1, 0)
            tabTitle.Parent = tabBtn

            local tabBtnCorner = Instance.new("UICorner")
            tabBtnCorner.CornerRadius = UDim.new(0, 8)
            tabBtnCorner.Parent = tabBtn

            local pageScroll = Instance.new("ScrollingFrame")
            pageScroll.Name = "Page_" .. tabName
            pageScroll.Size = UDim2.new(1, -20, 1, -20)
            pageScroll.Position = UDim2.new(0, 10, 0, 10)
            pageScroll.BackgroundTransparency = 1
            pageScroll.BorderSizePixel = 0
            pageScroll.ScrollBarThickness = 3
            pageScroll.ScrollBarImageColor3 = Color3.fromRGB(180, 120, 255)
            pageScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            pageScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            pageScroll.Visible = false
            pageScroll.Parent = contentArea

            local pageLayout = Instance.new("UIListLayout")
            pageLayout.FillDirection = Enum.FillDirection.Vertical
            pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            pageLayout.Padding = UDim.new(0, 12)
            pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
            pageLayout.Parent = pageScroll

            local tabObj = {
                Name = tabName,
                Button = tabBtn,
                Page = pageScroll,
                Sections = {}
            }

            local function ActivateTab()
                for _, t in ipairs(window.Tabs) do
                    t.Page.Visible = false
                    TweenService:Create(t.Button, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(30, 20, 50),
                        BackgroundTransparency = 0.7
                    }):Play()
                    local bTitle = t.Button:FindFirstChild("Title")
                    if bTitle then
                        TweenService:Create(bTitle, TweenInfo.new(0.2), { TextColor3 = Color3.fromRGB(200, 185, 230) }):Play()
                    end
                    local bIcon = t.Button:FindFirstChild("Icon")
                    if bIcon then
                        TweenService:Create(bIcon, TweenInfo.new(0.2), { ImageColor3 = Color3.fromRGB(175, 155, 215) }):Play()
                    end
                    local str = t.Button:FindFirstChildOfClass("UIStroke")
                    if str then str.Enabled = false end
                end

                pageScroll.Visible = true
                TweenService:Create(tabBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(130, 70, 220),
                    BackgroundTransparency = 0.35
                }):Play()
                if tabTitle then
                    TweenService:Create(tabTitle, TweenInfo.new(0.2), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
                end
                if tabIcon then
                    TweenService:Create(tabIcon, TweenInfo.new(0.2), { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
                end

                local activeStroke = tabBtn:FindFirstChildOfClass("UIStroke")
                if not activeStroke then
                    activeStroke = Instance.new("UIStroke")
                    activeStroke.Thickness = 1.2
                    activeStroke.Color = Color3.fromRGB(200, 160, 255)
                    activeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    activeStroke.Parent = tabBtn
                end
                activeStroke.Enabled = true
                window.CurrentTab = tabObj
            end

            tabBtn.MouseButton1Click:Connect(ActivateTab)

            function tabObj:CreatePage(pageName)
                return tabObj
            end

            function tabObj:CreateSection(secName, secIcon)
                local sectionCard = Instance.new("Frame")
                sectionCard.Name = "Card_" .. secName
                sectionCard.Size = UDim2.new(1, -6, 0, 0)
                sectionCard.AutomaticSize = Enum.AutomaticSize.Y
                sectionCard.BackgroundColor3 = Color3.fromRGB(24, 16, 40)
                sectionCard.BackgroundTransparency = 0.45
                sectionCard.BorderSizePixel = 0
                sectionCard.Parent = pageScroll

                local secCorner = Instance.new("UICorner")
                secCorner.CornerRadius = UDim.new(0, 10)
                secCorner.Parent = sectionCard

                local secStroke = Instance.new("UIStroke")
                secStroke.Thickness = 1
                secStroke.Color = Color3.fromRGB(140, 95, 215)
                secStroke.Transparency = 0.5
                secStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                secStroke.Parent = sectionCard

                local secHeader = Instance.new("Frame")
                secHeader.Name = "SecHeader"
                secHeader.Size = UDim2.new(1, 0, 0, 32)
                secHeader.BackgroundTransparency = 1
                secHeader.Parent = sectionCard

                local secTitle = Instance.new("TextLabel")
                secTitle.Text = secName
                secTitle.Font = Enum.Font.GothamBold
                secTitle.TextSize = 13
                secTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
                secTitle.TextXAlignment = Enum.TextXAlignment.Left
                secTitle.Position = UDim2.new(0, 12, 0, 0)
                secTitle.Size = UDim2.new(1, -24, 1, 0)
                secTitle.BackgroundTransparency = 1
                secTitle.Parent = secHeader

                local secLine = Instance.new("Frame")
                secLine.Size = UDim2.new(1, -24, 0, 1)
                secLine.Position = UDim2.new(0, 12, 1, -1)
                secLine.BackgroundColor3 = Color3.fromRGB(130, 85, 200)
                secLine.BackgroundTransparency = 0.6
                secLine.BorderSizePixel = 0
                secLine.Parent = secHeader

                local itemsFrame = Instance.new("Frame")
                itemsFrame.Name = "ItemsFrame"
                itemsFrame.Size = UDim2.new(1, -24, 0, 0)
                itemsFrame.Position = UDim2.new(0, 12, 0, 36)
                itemsFrame.AutomaticSize = Enum.AutomaticSize.Y
                itemsFrame.BackgroundTransparency = 1
                itemsFrame.Parent = sectionCard

                local itemsLayout = Instance.new("UIListLayout")
                itemsLayout.FillDirection = Enum.FillDirection.Vertical
                itemsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                itemsLayout.Padding = UDim.new(0, 8)
                itemsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                itemsLayout.Parent = itemsFrame

                local paddingBottom = Instance.new("UIPadding")
                paddingBottom.PaddingBottom = UDim.new(0, 10)
                paddingBottom.Parent = itemsFrame

                local section = {
                    Name = secName,
                    Card = sectionCard,
                    ItemsFrame = itemsFrame
                }

                                -- 1. ADD TOGGLE
                function section:AddToggle(toggleName, defaultVal, callback, opts)
                    defaultVal = defaultVal == true
                    callback = callback or function() end
                    opts = opts or {}
                    local flagName = (type(opts) == "table" and opts.Flag) or toggleName

                    local toggleRow = Instance.new("Frame")
                    toggleRow.Name = "Toggle_" .. toggleName
                    toggleRow.Size = UDim2.new(1, 0, 0, 32)
                    toggleRow.BackgroundTransparency = 1
                    toggleRow.Parent = itemsFrame

                    local label = Instance.new("TextLabel")
                    label.Text = toggleName
                    label.Font = Enum.Font.Gotham
                    label.TextSize = 13
                    label.TextColor3 = Color3.fromRGB(240, 235, 255)
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.BackgroundTransparency = 1
                    label.Position = UDim2.new(0, 4, 0, 0)
                    label.Size = UDim2.new(1, -120, 1, 0)
                    label.Parent = toggleRow

                    local rightControls = Instance.new("Frame")
                    rightControls.Name = "RightControls"
                    rightControls.AnchorPoint = Vector2.new(1, 0.5)
                    rightControls.Position = UDim2.new(1, -4, 0.5, 0)
                    rightControls.Size = UDim2.new(0, 110, 0, 24)
                    rightControls.BackgroundTransparency = 1
                    rightControls.Parent = toggleRow

                    local rightLayout = Instance.new("UIListLayout")
                    rightLayout.FillDirection = Enum.FillDirection.Horizontal
                    rightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                    rightLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                    rightLayout.Padding = UDim.new(0, 6)
                    rightLayout.Parent = rightControls

                    local switchBtn = Instance.new("TextButton")
                    switchBtn.Name = "Switch"
                    switchBtn.Size = UDim2.new(0, 42, 0, 22)
                    switchBtn.BackgroundColor3 = defaultVal and Color3.fromRGB(150, 75, 255) or Color3.fromRGB(42, 28, 64)
                    switchBtn.BackgroundTransparency = 0.35
                    switchBtn.BorderSizePixel = 0
                    switchBtn.Text = ""
                    switchBtn.AutoButtonColor = false
                    switchBtn.LayoutOrder = 100
                    switchBtn.Parent = rightControls

                    local switchCorner = Instance.new("UICorner")
                    switchCorner.CornerRadius = UDim.new(0, 11)
                    switchCorner.Parent = switchBtn

                    local knob = Instance.new("Frame")
                    knob.Name = "Knob"
                    knob.Size = UDim2.new(0, 16, 0, 16)
                    knob.Position = defaultVal and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
                    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    knob.BorderSizePixel = 0
                    knob.Parent = switchBtn

                    local knobCorner = Instance.new("UICorner")
                    knobCorner.CornerRadius = UDim.new(0, 8)
                    knobCorner.Parent = knob

                    local state = defaultVal
                    local toggleObj = { State = state }

                    local function SetState(newVal)
                        state = newVal == true
                        toggleObj.State = state
                        lib.Flags[flagName] = state
                        if state then
                            TweenService:Create(switchBtn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(150, 75, 255) }):Play()
                            TweenService:Create(knob, TweenInfo.new(0.2), { Position = UDim2.new(1, -19, 0.5, -8) }):Play()
                        else
                            TweenService:Create(switchBtn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(42, 28, 64) }):Play()
                            TweenService:Create(knob, TweenInfo.new(0.2), { Position = UDim2.new(0, 3, 0.5, -8) }):Play()
                        end
                        pcall(callback, state)
                    end

                    switchBtn.MouseButton1Click:Connect(function()
                        SetState(not state)
                    end)

                    function toggleObj:SetValue(val)
                        SetState(val)
                    end

                    function toggleObj:GetValue()
                        return state
                    end

                    function toggleObj:AddKeyPicker(keyOrName, pOpts)
                        pOpts = pOpts or {}
                        local currentKey = "None"
                        if type(keyOrName) == "string" and keyOrName ~= "None" and not pOpts.Default then
                            currentKey = keyOrName
                        elseif pOpts.Default then
                            currentKey = pOpts.Default
                        end

                        local keyBtn = Instance.new("TextButton")
                        keyBtn.Name = "KeyPicker"
                        keyBtn.Size = UDim2.new(0, 48, 0, 20)
                        keyBtn.BackgroundColor3 = Color3.fromRGB(50, 34, 75)
                        keyBtn.BackgroundTransparency = 0.4
                        keyBtn.BorderSizePixel = 0
                        keyBtn.Text = "[" .. currentKey .. "]"
                        keyBtn.Font = Enum.Font.GothamMedium
                        keyBtn.TextSize = 11
                        keyBtn.TextColor3 = Color3.fromRGB(200, 185, 230)
                        keyBtn.AutoButtonColor = false
                        keyBtn.LayoutOrder = 10
                        keyBtn.Parent = rightControls

                        local keyCorner = Instance.new("UICorner")
                        keyCorner.CornerRadius = UDim.new(0, 5)
                        keyCorner.Parent = keyBtn

                        local isBinding = false
                        keyBtn.MouseButton1Click:Connect(function()
                            if isBinding then return end
                            isBinding = true
                            keyBtn.Text = "[...]"
                            local conn
                            conn = UserInputService.InputBegan:Connect(function(inp)
                                if inp.UserInputType == Enum.UserInputType.Keyboard then
                                    if inp.KeyCode == Enum.KeyCode.Backspace or inp.KeyCode == Enum.KeyCode.Escape then
                                        currentKey = "None"
                                    else
                                        currentKey = inp.KeyCode.Name
                                    end
                                    keyBtn.Text = "[" .. currentKey .. "]"
                                    lib.Flags[flagName .. "_Key"] = currentKey
                                    isBinding = false
                                    conn:Disconnect()
                                    if pOpts.Callback then
                                        pcall(pOpts.Callback, currentKey)
                                    end
                                end
                            end)
                        end)

                        UserInputService.InputBegan:Connect(function(inp, gpe)
                            if not gpe and inp.UserInputType == Enum.UserInputType.Keyboard then
                                if currentKey ~= "None" and inp.KeyCode.Name == currentKey then
                                    SetState(not state)
                                end
                            end
                        end)

                        local keyFlag = (pOpts and pOpts.Flag) or (flagName .. "_Key")
                        lib.Flags[keyFlag] = currentKey
                        lib.Elements[keyFlag] = {
                            Type = "Keybind",
                            Name = keyFlag,
                            Flag = keyFlag,
                            Get = function() return currentKey end,
                            Set = function(k)
                                currentKey = tostring(k or "None")
                                lib.Flags[keyFlag] = currentKey
                                keyBtn.Text = "[" .. currentKey .. "]"
                                if pOpts and pOpts.Callback then
                                    pcall(pOpts.Callback, currentKey)
                                end
                            end
                        }

                        return keyBtn
                    end

                    function toggleObj:AddColorPicker(arg1, arg2)
                        local defColor = typeof(arg1) == "Color3" and arg1 or (typeof(arg2) == "table" and arg2.Default or Color3.fromRGB(255, 255, 255))
                        local cpOpts = typeof(arg2) == "table" and arg2 or (typeof(arg1) == "table" and arg1 or {})
                        local cpCallback = cpOpts.Callback or function() end

                        local swatch = Instance.new("TextButton")
                        swatch.Name = "ColorPickerSwatch"
                        swatch.Size = UDim2.new(0, 20, 0, 20)
                        swatch.BackgroundColor3 = defColor
                        swatch.BorderSizePixel = 0
                        swatch.Text = ""
                        swatch.AutoButtonColor = false
                        swatch.LayoutOrder = 5
                        swatch.Parent = rightControls

                        local sCorner = Instance.new("UICorner")
                        sCorner.CornerRadius = UDim.new(0, 4)
                        sCorner.Parent = swatch

                        local colorsList = {
                            Color3.fromRGB(255, 255, 255),
                            Color3.fromRGB(180, 130, 255),
                            Color3.fromRGB(255, 75, 75),
                            Color3.fromRGB(75, 255, 120),
                            Color3.fromRGB(255, 220, 75),
                            Color3.fromRGB(75, 180, 255),
                            Color3.fromRGB(255, 120, 220)
                        }
                        local cIdx = 1
                        swatch.MouseButton1Click:Connect(function()
                            cIdx = (cIdx % #colorsList) + 1
                            local newC = colorsList[cIdx]
                            swatch.BackgroundColor3 = newC
                            lib.Flags[flagName .. "_Color"] = { R = newC.R, G = newC.G, B = newC.B }
                            pcall(cpCallback, newC)
                        end)

                        local cpFlag = (cpOpts and cpOpts.Flag) or (flagName .. "_Color")
                        lib.Flags[cpFlag] = { R = defColor.R, G = defColor.G, B = defColor.B }
                        lib.Elements[cpFlag] = {
                            Type = "Color",
                            Name = cpFlag,
                            Flag = cpFlag,
                            Get = function() return swatch.BackgroundColor3 end,
                            Set = function(col)
                                if typeof(col) == "Color3" then
                                    swatch.BackgroundColor3 = col
                                    lib.Flags[cpFlag] = { R = col.R, G = col.G, B = col.B }
                                    pcall(cpCallback, col)
                                elseif type(col) == "table" and col.R and col.G and col.B then
                                    local c3 = Color3.new(col.R, col.G, col.B)
                                    swatch.BackgroundColor3 = c3
                                    lib.Flags[cpFlag] = col
                                    pcall(cpCallback, c3)
                                end
                            end
                        }

                        return swatch
                    end

                    lib.Flags[flagName] = defaultVal
                    lib.Elements[flagName] = {
                        Type = "Toggle",
                        Name = toggleName,
                        Flag = flagName,
                        Get = function() return toggleObj.State end,
                        Set = function(v) SetState(v) end
                    }
                    lib.Options[flagName] = toggleObj

                    return toggleObj
                end

                -- 2. ADD CHECKBOX
                function section:AddCheckbox(cbName, defVal, callback)
                    return section:AddToggle(cbName, defVal, callback)
                end

                -- 3. ADD SLIDER
                function section:AddSlider(sliderName, minVal, maxVal, defVal, callback, opts)
                    minVal = tonumber(minVal) or 0
                    maxVal = tonumber(maxVal) or 100
                    defVal = tonumber(defVal) or minVal
                    callback = callback or function() end
                    opts = opts or {}
                    local flagName = (type(opts) == "table" and opts.Flag) or sliderName

                    local sliderCard = Instance.new("Frame")
                    sliderCard.Name = "Slider_" .. sliderName
                    sliderCard.Size = UDim2.new(1, 0, 0, 46)
                    sliderCard.BackgroundTransparency = 1
                    sliderCard.Parent = itemsFrame

                    local sTitle = Instance.new("TextLabel")
                    sTitle.Text = sliderName
                    sTitle.Font = Enum.Font.Gotham
                    sTitle.TextSize = 13
                    sTitle.TextColor3 = Color3.fromRGB(240, 235, 255)
                    sTitle.TextXAlignment = Enum.TextXAlignment.Left
                    sTitle.BackgroundTransparency = 1
                    sTitle.Position = UDim2.new(0, 4, 0, 0)
                    sTitle.Size = UDim2.new(0.6, 0, 0, 20)
                    sTitle.Parent = sliderCard

                    local valLabel = Instance.new("TextLabel")
                    valLabel.Text = tostring(defVal)
                    valLabel.Font = Enum.Font.GothamMedium
                    valLabel.TextSize = 12
                    valLabel.TextColor3 = Color3.fromRGB(200, 180, 235)
                    valLabel.TextXAlignment = Enum.TextXAlignment.Right
                    valLabel.BackgroundTransparency = 1
                    valLabel.Position = UDim2.new(0.6, 0, 0, 0)
                    valLabel.Size = UDim2.new(0.4, -4, 0, 20)
                    valLabel.Parent = sliderCard

                    local track = Instance.new("Frame")
                    track.Name = "Track"
                    track.Size = UDim2.new(1, -8, 0, 6)
                    track.Position = UDim2.new(0, 4, 0, 28)
                    track.BackgroundColor3 = Color3.fromRGB(48, 32, 68)
                    track.BorderSizePixel = 0
                    track.Parent = sliderCard

                    local trackCorner = Instance.new("UICorner")
                    trackCorner.CornerRadius = UDim.new(0, 3)
                    trackCorner.Parent = track

                    local initialPct = (maxVal == minVal) and 0 or math.clamp((defVal - minVal) / (maxVal - minVal), 0, 1)

                    local fill = Instance.new("Frame")
                    fill.Name = "Fill"
                    fill.Size = UDim2.new(initialPct, 0, 1, 0)
                    fill.BackgroundColor3 = Color3.fromRGB(160, 90, 255)
                    fill.BorderSizePixel = 0
                    fill.Parent = track

                    local fillCorner = Instance.new("UICorner")
                    fillCorner.CornerRadius = UDim.new(0, 3)
                    fillCorner.Parent = fill

                    local knob = Instance.new("Frame")
                    knob.Name = "Knob"
                    knob.AnchorPoint = Vector2.new(0.5, 0.5)
                    knob.Position = UDim2.new(initialPct, 0, 0.5, 0)
                    knob.Size = UDim2.new(0, 14, 0, 14)
                    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    knob.BorderSizePixel = 0
                    knob.Parent = track

                    local knobCorner = Instance.new("UICorner")
                    knobCorner.CornerRadius = UDim.new(0, 7)
                    knobCorner.Parent = knob

                    local currentValue = defVal
                    local isSliding = false

                    local sliderObj = {
                        Value = defVal
                    }

                    local function UpdateFromX(xPos)
                        local pct = math.clamp((xPos - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                        fill.Size = UDim2.new(pct, 0, 1, 0)
                        knob.Position = UDim2.new(pct, 0, 0.5, 0)

                        local rawVal = minVal + (maxVal - minVal) * pct
                        local step = (maxVal - minVal <= 10 and maxVal - minVal > 1) and 0.1 or (maxVal - minVal <= 1 and 0.01 or 1)
                        local rounded = math.floor(rawVal / step + 0.5) * step
                        if step < 1 then
                            currentValue = tonumber(string.format("%.2f", rounded))
                        else
                            currentValue = math.floor(rounded)
                        end
                        sliderObj.Value = currentValue
                        lib.Flags[flagName] = currentValue
                        valLabel.Text = tostring(currentValue)
                        pcall(callback, currentValue)
                    end

                    track.InputBegan:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                            isSliding = true
                            UpdateFromX(inp.Position.X)
                            inp.Changed:Connect(function()
                                if inp.UserInputState == Enum.UserInputState.End then
                                    isSliding = false
                                end
                            end)
                        end
                    end)

                    UserInputService.InputChanged:Connect(function(inp)
                        if isSliding and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                            UpdateFromX(inp.Position.X)
                        end
                    end)

                    function sliderObj:SetValue(val)
                        val = tonumber(val) or minVal
                        currentValue = math.clamp(val, minVal, maxVal)
                        sliderObj.Value = currentValue
                        lib.Flags[flagName] = currentValue
                        local pct = (maxVal == minVal) and 0 or math.clamp((currentValue - minVal) / (maxVal - minVal), 0, 1)
                        fill.Size = UDim2.new(pct, 0, 1, 0)
                        knob.Position = UDim2.new(pct, 0, 0.5, 0)
                        valLabel.Text = tostring(currentValue)
                        pcall(callback, currentValue)
                    end

                    function sliderObj:GetValue()
                        return sliderObj.Value
                    end

                    lib.Flags[flagName] = defVal
                    lib.Elements[flagName] = {
                        Type = "Slider",
                        Name = sliderName,
                        Flag = flagName,
                        Get = function() return sliderObj.Value end,
                        Set = function(v) sliderObj:SetValue(v) end
                    }
                    lib.Options[flagName] = sliderObj

                    return sliderObj
                end

                -- 4. ADD BUTTON
                function section:AddButton(btnName, callback)
                    callback = callback or function() end

                    local btn = Instance.new("TextButton")
                    btn.Name = "Button_" .. btnName
                    btn.Size = UDim2.new(1, 0, 0, 34)
                    btn.BackgroundColor3 = Color3.fromRGB(90, 50, 160)
                    btn.BackgroundTransparency = 0.50
                    btn.BorderSizePixel = 0
                    btn.Text = btnName
                    btn.Font = Enum.Font.GothamBold
                    btn.TextSize = 13
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    btn.AutoButtonColor = false
                    btn.Parent = itemsFrame

                    local btnCorner = Instance.new("UICorner")
                    btnCorner.CornerRadius = UDim.new(0, 8)
                    btnCorner.Parent = btn

                    lib:ApplyShimmer(btn, 1.5)

                    btn.MouseEnter:Connect(function()
                        TweenService:Create(btn, TweenInfo.new(0.2), { BackgroundTransparency = 0.35 }):Play()
                    end)
                    btn.MouseLeave:Connect(function()
                        TweenService:Create(btn, TweenInfo.new(0.2), { BackgroundTransparency = 0.50 }):Play()
                    end)
                    btn.MouseButton1Click:Connect(function()
                        TweenService:Create(btn, TweenInfo.new(0.08), { BackgroundTransparency = 0.2 }):Play()
                        task.wait(0.08)
                        TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundTransparency = 0.35 }):Play()
                        pcall(callback)
                    end)

                    return btn
                end

                -- 5. ADD DROPDOWN
                function section:AddDropdown(ddName, optionsList, defaultOpt, callback)
                    optionsList = type(optionsList) == "table" and optionsList or {}
                    callback = callback or function() end
                    local flagName = ddName
                    local selected = defaultOpt or (optionsList[1] or "None")

                    local ddCard = Instance.new("Frame")
                    ddCard.Name = "Dropdown_" .. ddName
                    ddCard.Size = UDim2.new(1, 0, 0, 58)
                    ddCard.AutomaticSize = Enum.AutomaticSize.Y
                    ddCard.BackgroundTransparency = 1
                    ddCard.Parent = itemsFrame

                    local dTitle = Instance.new("TextLabel")
                    dTitle.Text = ddName
                    dTitle.Font = Enum.Font.Gotham
                    dTitle.TextSize = 13
                    dTitle.TextColor3 = Color3.fromRGB(240, 235, 255)
                    dTitle.TextXAlignment = Enum.TextXAlignment.Left
                    dTitle.BackgroundTransparency = 1
                    dTitle.Position = UDim2.new(0, 4, 0, 0)
                    dTitle.Size = UDim2.new(1, -8, 0, 18)
                    dTitle.Parent = ddCard

                    local mainBtn = Instance.new("TextButton")
                    mainBtn.Name = "MainBox"
                    mainBtn.Size = UDim2.new(1, 0, 0, 32)
                    mainBtn.Position = UDim2.new(0, 0, 0, 22)
                    mainBtn.BackgroundColor3 = Color3.fromRGB(36, 24, 56)
                    mainBtn.BackgroundTransparency = 0.4
                    mainBtn.BorderSizePixel = 0
                    mainBtn.Text = "  " .. tostring(selected)
                    mainBtn.Font = Enum.Font.GothamMedium
                    mainBtn.TextSize = 13
                    mainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    mainBtn.TextXAlignment = Enum.TextXAlignment.Left
                    mainBtn.AutoButtonColor = false
                    mainBtn.Parent = ddCard

                    local mbCorner = Instance.new("UICorner")
                    mbCorner.CornerRadius = UDim.new(0, 8)
                    mbCorner.Parent = mainBtn

                    local mbStroke = Instance.new("UIStroke")
                    mbStroke.Thickness = 1
                    mbStroke.Color = Color3.fromRGB(150, 105, 225)
                    mbStroke.Transparency = 0.5
                    mbStroke.Parent = mainBtn

                    local arrow = Instance.new("TextLabel")
                    arrow.Text = "▼"
                    arrow.Font = Enum.Font.GothamBold
                    arrow.TextSize = 11
                    arrow.TextColor3 = Color3.fromRGB(180, 140, 240)
                    arrow.BackgroundTransparency = 1
                    arrow.Position = UDim2.new(1, -26, 0, 0)
                    arrow.Size = UDim2.new(0, 20, 1, 0)
                    arrow.Parent = mainBtn

                    local optsContainer = Instance.new("Frame")
                    optsContainer.Name = "OptionsList"
                    optsContainer.Size = UDim2.new(1, 0, 0, 0)
                    optsContainer.Position = UDim2.new(0, 0, 0, 56)
                    optsContainer.AutomaticSize = Enum.AutomaticSize.Y
                    optsContainer.BackgroundColor3 = Color3.fromRGB(22, 14, 38)
                    optsContainer.BackgroundTransparency = 0.15
                    optsContainer.BorderSizePixel = 0
                    optsContainer.Visible = false
                    optsContainer.ZIndex = 30
                    optsContainer.Parent = ddCard

                    local oCorner = Instance.new("UICorner")
                    oCorner.CornerRadius = UDim.new(0, 8)
                    oCorner.Parent = optsContainer

                    local oStroke = Instance.new("UIStroke")
                    oStroke.Thickness = 1
                    oStroke.Color = Color3.fromRGB(130, 80, 200)
                    oStroke.Transparency = 0.4
                    oStroke.Parent = optsContainer

                    local oLayout = Instance.new("UIListLayout")
                    oLayout.FillDirection = Enum.FillDirection.Vertical
                    oLayout.Padding = UDim.new(0, 2)
                    oLayout.Parent = optsContainer

                    local isOpen = false

                    local ddObj = {
                        Value = selected
                    }

                    local function BuildOptions(list)
                        for _, c in ipairs(optsContainer:GetChildren()) do
                            if c:IsA("TextButton") then
                                c:Destroy()
                            end
                        end
                        for _, opt in ipairs(list) do
                            local optBtn = Instance.new("TextButton")
                            optBtn.Size = UDim2.new(1, -6, 0, 26)
                            optBtn.Position = UDim2.new(0, 3, 0, 0)
                            optBtn.BackgroundColor3 = Color3.fromRGB(38, 24, 60)
                            optBtn.BackgroundTransparency = 0.6
                            optBtn.BorderSizePixel = 0
                            optBtn.Text = "  " .. tostring(opt)
                            optBtn.Font = Enum.Font.Gotham
                            optBtn.TextSize = 12
                            optBtn.TextColor3 = Color3.fromRGB(230, 220, 250)
                            optBtn.TextXAlignment = Enum.TextXAlignment.Left
                            optBtn.ZIndex = 31
                            optBtn.AutoButtonColor = false
                            optBtn.Parent = optsContainer

                            local oBtnCorner = Instance.new("UICorner")
                            oBtnCorner.CornerRadius = UDim.new(0, 5)
                            oBtnCorner.Parent = optBtn

                            optBtn.MouseEnter:Connect(function()
                                optBtn.BackgroundTransparency = 0.2
                            end)
                            optBtn.MouseLeave:Connect(function()
                                optBtn.BackgroundTransparency = 0.6
                            end)
                            optBtn.MouseButton1Click:Connect(function()
                                selected = opt
                                ddObj.Value = selected
                                lib.Flags[flagName] = selected
                                mainBtn.Text = "  " .. tostring(selected)
                                isOpen = false
                                optsContainer.Visible = false
                                arrow.Text = "▼"
                                pcall(callback, selected)
                            end)
                        end
                    end

                    BuildOptions(optionsList)

                    mainBtn.MouseButton1Click:Connect(function()
                        isOpen = not isOpen
                        optsContainer.Visible = isOpen
                        arrow.Text = isOpen and "▲" or "▼"
                    end)

                    function ddObj:SetValue(opt)
                        selected = opt
                        ddObj.Value = selected
                        lib.Flags[flagName] = selected
                        mainBtn.Text = "  " .. tostring(selected)
                        pcall(callback, selected)
                    end

                    function ddObj:GetValue()
                        return ddObj.Value
                    end

                    function ddObj:Refresh(newList)
                        BuildOptions(newList)
                    end
                    ddObj.SetOptions = ddObj.Refresh
                    ddObj.SetValues = ddObj.Refresh
                    ddObj.Update = ddObj.Refresh

                    lib.Flags[flagName] = selected
                    lib.Elements[flagName] = {
                        Type = "Dropdown",
                        Name = ddName,
                        Flag = flagName,
                        Get = function() return ddObj.Value end,
                        Set = function(v) ddObj:SetValue(v) end
                    }
                    lib.Options[flagName] = ddObj

                    return ddObj
                end

                -- 6. ADD TEXTBOX
                function section:AddTextbox(tbName, placeholder, callback)
                    placeholder = placeholder or "Type here..."
                    callback = callback or function() end
                    local flagName = tbName

                    local tbRow = Instance.new("Frame")
                    tbRow.Name = "Textbox_" .. tbName
                    tbRow.Size = UDim2.new(1, 0, 0, 36)
                    tbRow.BackgroundTransparency = 1
                    tbRow.Parent = itemsFrame

                    local input = Instance.new("TextBox")
                    input.Size = UDim2.new(1, 0, 1, 0)
                    input.BackgroundColor3 = Color3.fromRGB(36, 24, 56)
                    input.BackgroundTransparency = 0.4
                    input.BorderSizePixel = 0
                    input.PlaceholderText = placeholder
                    input.PlaceholderColor3 = Color3.fromRGB(160, 140, 190)
                    input.Text = ""
                    input.Font = Enum.Font.Gotham
                    input.TextSize = 13
                    input.TextColor3 = Color3.fromRGB(255, 255, 255)
                    input.ClearTextOnFocus = false
                    input.Parent = tbRow

                    local inCorner = Instance.new("UICorner")
                    inCorner.CornerRadius = UDim.new(0, 8)
                    inCorner.Parent = input

                    local inStroke = Instance.new("UIStroke")
                    inStroke.Thickness = 1
                    inStroke.Color = Color3.fromRGB(150, 105, 225)
                    inStroke.Transparency = 0.5
                    inStroke.Parent = input

                    input.FocusLost:Connect(function(enterPressed)
                        lib.Flags[flagName] = input.Text
                        pcall(callback, input.Text)
                    end)

                    lib.Flags[flagName] = ""
                    lib.Elements[flagName] = {
                        Type = "Textbox",
                        Name = tbName,
                        Flag = flagName,
                        Get = function() return input.Text end,
                        Set = function(t)
                            input.Text = tostring(t or "")
                            lib.Flags[flagName] = input.Text
                            pcall(callback, input.Text)
                        end
                    }

                    return input
                end

                -- 7. ADD KEYBIND
                function section:AddKeybind(kbName, defaultKey, callback)
                    defaultKey = defaultKey or "None"
                    callback = callback or function() end
                    local boundKey = defaultKey
                    local flagName = kbName

                    local kbRow = Instance.new("Frame")
                    kbRow.Name = "Keybind_" .. kbName
                    kbRow.Size = UDim2.new(1, 0, 0, 32)
                    kbRow.BackgroundTransparency = 1
                    kbRow.Parent = itemsFrame

                    local label = Instance.new("TextLabel")
                    label.Text = kbName
                    label.Font = Enum.Font.Gotham
                    label.TextSize = 13
                    label.TextColor3 = Color3.fromRGB(240, 235, 255)
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.BackgroundTransparency = 1
                    label.Position = UDim2.new(0, 4, 0, 0)
                    label.Size = UDim2.new(1, -110, 1, 0)
                    label.Parent = kbRow

                    local kBtn = Instance.new("TextButton")
                    kBtn.Size = UDim2.new(0, 100, 0, 24)
                    kBtn.Position = UDim2.new(1, -104, 0.5, -12)
                    kBtn.BackgroundColor3 = Color3.fromRGB(45, 30, 70)
                    kBtn.BackgroundTransparency = 0.4
                    kBtn.BorderSizePixel = 0
                    kBtn.Text = "[" .. defaultKey .. "]"
                    kBtn.Font = Enum.Font.GothamMedium
                    kBtn.TextSize = 11
                    kBtn.TextColor3 = Color3.fromRGB(220, 205, 245)
                    kBtn.Parent = kbRow

                    local kCorner = Instance.new("UICorner")
                    kCorner.CornerRadius = UDim.new(0, 6)
                    kCorner.Parent = kBtn

                    local isListening = false
                    kBtn.MouseButton1Click:Connect(function()
                        if isListening then return end
                        isListening = true
                        kBtn.Text = "[...]"
                        local conn
                        conn = UserInputService.InputBegan:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.Keyboard then
                                if inp.KeyCode == Enum.KeyCode.Backspace or inp.KeyCode == Enum.KeyCode.Escape then
                                    boundKey = "None"
                                else
                                    boundKey = inp.KeyCode.Name
                                end
                                kBtn.Text = "[" .. boundKey .. "]"
                                lib.Flags[flagName] = boundKey
                                isListening = false
                                conn:Disconnect()
                                pcall(callback, boundKey)
                            end
                        end)
                    end)

                    local kbObj = {
                        Value = boundKey,
                        SetValue = function(self, key)
                            boundKey = tostring(key or "None")
                            kbObj.Value = boundKey
                            lib.Flags[flagName] = boundKey
                            kBtn.Text = "[" .. boundKey .. "]"
                            pcall(callback, boundKey)
                        end,
                        GetValue = function(self)
                            return boundKey
                        end
                    }

                    lib.Flags[flagName] = defaultKey
                    lib.Elements[flagName] = {
                        Type = "Keybind",
                        Name = kbName,
                        Flag = flagName,
                        Get = function() return boundKey end,
                        Set = function(k) kbObj:SetValue(k) end
                    }
                    lib.Options[flagName] = kbObj

                    return kBtn
                end

                -- 8. ADD COLORPICKER
                function section:AddColorPicker(arg1, arg2, arg3)
                    local title = "Color Picker"
                    local defColor = Color3.fromRGB(255, 255, 255)
                    local cpCallback = function() end

                    if type(arg1) == "string" then
                        title = arg1
                        if typeof(arg2) == "Color3" then
                            defColor = arg2
                            if type(arg3) == "table" and arg3.Callback then
                                cpCallback = arg3.Callback
                            elseif type(arg3) == "function" then
                                cpCallback = arg3
                            end
                        end
                    elseif typeof(arg1) == "Color3" then
                        defColor = arg1
                        if type(arg2) == "table" then
                            title = arg2.Title or title
                            cpCallback = arg2.Callback or cpCallback
                        end
                    end

                    local flagName = title
                    local currentColor = defColor

                    local cpRow = Instance.new("Frame")
                    cpRow.Name = "ColorPicker_" .. title
                    cpRow.Size = UDim2.new(1, 0, 0, 32)
                    cpRow.BackgroundTransparency = 1
                    cpRow.Parent = itemsFrame

                    local label = Instance.new("TextLabel")
                    label.Text = title
                    label.Font = Enum.Font.Gotham
                    label.TextSize = 13
                    label.TextColor3 = Color3.fromRGB(240, 235, 255)
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.BackgroundTransparency = 1
                    label.Position = UDim2.new(0, 4, 0, 0)
                    label.Size = UDim2.new(1, -40, 1, 0)
                    label.Parent = cpRow

                    local swatch = Instance.new("TextButton")
                    swatch.Size = UDim2.new(0, 24, 0, 24)
                    swatch.Position = UDim2.new(1, -28, 0.5, -12)
                    swatch.BackgroundColor3 = defColor
                    swatch.BorderSizePixel = 0
                    swatch.Text = ""
                    swatch.Parent = cpRow

                    local swCorner = Instance.new("UICorner")
                    swCorner.CornerRadius = UDim.new(0, 5)
                    swCorner.Parent = swatch

                    local colors = {
                        Color3.fromRGB(255, 255, 255),
                        Color3.fromRGB(180, 130, 255),
                        Color3.fromRGB(255, 80, 80),
                        Color3.fromRGB(80, 255, 130),
                        Color3.fromRGB(255, 220, 80),
                        Color3.fromRGB(80, 180, 255),
                        Color3.fromRGB(255, 120, 220)
                    }
                    local idx = 1
                    swatch.MouseButton1Click:Connect(function()
                        idx = (idx % #colors) + 1
                        currentColor = colors[idx]
                        swatch.BackgroundColor3 = currentColor
                        lib.Flags[flagName] = { R = currentColor.R, G = currentColor.G, B = currentColor.B }
                        pcall(cpCallback, currentColor)
                    end)

                    local cpObj = {
                        Value = currentColor,
                        SetValue = function(self, col)
                            if typeof(col) == "Color3" then
                                currentColor = col
                                swatch.BackgroundColor3 = col
                                lib.Flags[flagName] = { R = col.R, G = col.G, B = col.B }
                                pcall(cpCallback, col)
                            elseif type(col) == "table" and col.R and col.G and col.B then
                                local c3 = Color3.new(col.R, col.G, col.B)
                                currentColor = c3
                                swatch.BackgroundColor3 = c3
                                lib.Flags[flagName] = col
                                pcall(cpCallback, c3)
                            end
                        end,
                        GetValue = function(self)
                            return swatch.BackgroundColor3
                        end
                    }

                    lib.Flags[flagName] = { R = defColor.R, G = defColor.G, B = defColor.B }
                    lib.Elements[flagName] = {
                        Type = "Color",
                        Name = title,
                        Flag = flagName,
                        Get = function() return swatch.BackgroundColor3 end,
                        Set = function(c) cpObj:SetValue(c) end
                    }
                    lib.Options[flagName] = cpObj

                    return swatch
                end

                -- 9. ADD CONFIG MANAGER (Interactive List + Max 10 limit + Real Settings Restoration)
                function section:AddConfigManager(folderPath)
                    folderPath = folderPath or "AerisHub/Configs"

                    local isfolder = isfolder or function() return false end
                    local makefolder = makefolder or function() end
                    local listfiles = listfiles or function() return {} end
                    local readfile = readfile or function() return nil end
                    local writefile = writefile or function() end
                    local delfile = delfile or function() end

                    pcall(function()
                        if not isfolder(folderPath) then
                            makefolder(folderPath)
                        end
                    end)

                    local inMemoryConfigs = {}

                    local cfgCard = Instance.new("Frame")
                    cfgCard.Name = "ConfigManagerCard"
                    cfgCard.Size = UDim2.new(1, 0, 0, 0)
                    cfgCard.AutomaticSize = Enum.AutomaticSize.Y
                    cfgCard.BackgroundTransparency = 1
                    cfgCard.Parent = itemsFrame

                    local cfgLayout = Instance.new("UIListLayout")
                    cfgLayout.FillDirection = Enum.FillDirection.Vertical
                    cfgLayout.Padding = UDim.new(0, 8)
                    cfgLayout.Parent = cfgCard

                    -- Header with live count (X/10)
                    local headerRow = Instance.new("Frame")
                    headerRow.Size = UDim2.new(1, 0, 0, 20)
                    headerRow.BackgroundTransparency = 1
                    headerRow.Parent = cfgCard

                    local countLabel = Instance.new("TextLabel")
                    countLabel.Name = "CountLabel"
                    countLabel.Text = "Saved Configs (0/10)"
                    countLabel.Font = Enum.Font.GothamBold
                    countLabel.TextSize = 12
                    countLabel.TextColor3 = Color3.fromRGB(200, 175, 240)
                    countLabel.TextXAlignment = Enum.TextXAlignment.Left
                    countLabel.BackgroundTransparency = 1
                    countLabel.Size = UDim2.new(0.6, 0, 1, 0)
                    countLabel.Parent = headerRow

                    local limitNote = Instance.new("TextLabel")
                    limitNote.Text = "Max 10 configs"
                    limitNote.Font = Enum.Font.Gotham
                    limitNote.TextSize = 11
                    limitNote.TextColor3 = Color3.fromRGB(150, 130, 185)
                    limitNote.TextXAlignment = Enum.TextXAlignment.Right
                    limitNote.BackgroundTransparency = 1
                    limitNote.Size = UDim2.new(0.4, 0, 1, 0)
                    limitNote.Parent = headerRow

                    -- Input + Save button row
                    local inputRow = Instance.new("Frame")
                    inputRow.Size = UDim2.new(1, 0, 0, 32)
                    inputRow.BackgroundTransparency = 1
                    inputRow.Parent = cfgCard

                    local input = Instance.new("TextBox")
                    input.Name = "ConfigInput"
                    input.Size = UDim2.new(1, -112, 1, 0)
                    input.BackgroundColor3 = Color3.fromRGB(34, 22, 54)
                    input.BackgroundTransparency = 0.35
                    input.BorderSizePixel = 0
                    input.PlaceholderText = "New config name..."
                    input.PlaceholderColor3 = Color3.fromRGB(150, 130, 180)
                    input.Text = ""
                    input.Font = Enum.Font.Gotham
                    input.TextSize = 12
                    input.TextColor3 = Color3.fromRGB(255, 255, 255)
                    input.Parent = inputRow

                    local inC = Instance.new("UICorner")
                    inC.CornerRadius = UDim.new(0, 8)
                    inC.Parent = input

                    local inStroke = Instance.new("UIStroke")
                    inStroke.Thickness = 1
                    inStroke.Color = Color3.fromRGB(140, 95, 215)
                    inStroke.Transparency = 0.5
                    inStroke.Parent = input

                    local saveBtn = Instance.new("TextButton")
                    saveBtn.Name = "SaveBtn"
                    saveBtn.Size = UDim2.new(0, 104, 1, 0)
                    saveBtn.Position = UDim2.new(1, -104, 0, 0)
                    saveBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 210)
                    saveBtn.BackgroundTransparency = 0.4
                    saveBtn.BorderSizePixel = 0
                    saveBtn.Text = "+ Save Config"
                    saveBtn.Font = Enum.Font.GothamBold
                    saveBtn.TextSize = 12
                    saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    saveBtn.AutoButtonColor = false
                    saveBtn.Parent = inputRow

                    local saveC = Instance.new("UICorner")
                    saveC.CornerRadius = UDim.new(0, 8)
                    saveC.Parent = saveBtn

                    lib:ApplyShimmer(saveBtn, 1.2)

                    -- List Container for Configs
                    local listFrame = Instance.new("Frame")
                    listFrame.Name = "ConfigsList"
                    listFrame.Size = UDim2.new(1, 0, 0, 0)
                    listFrame.AutomaticSize = Enum.AutomaticSize.Y
                    listFrame.BackgroundTransparency = 1
                    listFrame.Parent = cfgCard

                    local listLayout = Instance.new("UIListLayout")
                    listLayout.FillDirection = Enum.FillDirection.Vertical
                    listLayout.Padding = UDim.new(0, 5)
                    listLayout.Parent = listFrame

                    -- Clean filename parsing function to prevent folder path duplication
                    local function CleanConfigName(rawPath)
                        local s = tostring(rawPath):gsub(string.char(92), "/")
                        local fname = s:match("([^/]+)$") or s
                        local base = fname:match("^(.-)%.json$") or fname:match("^(.-)%.txt$") or fname
                        return base
                    end

                    local function GetAllConfigs()
                        local cfgs = {}
                        local seen = {}
                        pcall(function()
                            if isfolder(folderPath) then
                                local files = listfiles(folderPath)
                                for _, f in ipairs(files) do
                                    local name = CleanConfigName(f)
                                    if name and name ~= "" and not seen[name] then
                                        seen[name] = true
                                        table.insert(cfgs, name)
                                    end
                                end
                            end
                        end)
                        for name, _ in pairs(inMemoryConfigs) do
                            local base = CleanConfigName(name)
                            if base and base ~= "" and not seen[base] then
                                seen[base] = true
                                table.insert(cfgs, base)
                            end
                        end
                        table.sort(cfgs)
                        return cfgs
                    end

                    local function RenderList()
                        for _, child in ipairs(listFrame:GetChildren()) do
                            if child:IsA("Frame") or child:IsA("TextLabel") then
                                child:Destroy()
                            end
                        end

                        local cfgs = GetAllConfigs()
                        countLabel.Text = string.format("Saved Configs (%d/10)", #cfgs)

                        if #cfgs == 0 then
                            local emptyLabel = Instance.new("TextLabel")
                            emptyLabel.Text = "No configs saved yet. Enter a name above to save one."
                            emptyLabel.Font = Enum.Font.Gotham
                            emptyLabel.TextSize = 11
                            emptyLabel.TextColor3 = Color3.fromRGB(160, 145, 195)
                            emptyLabel.BackgroundTransparency = 1
                            emptyLabel.Size = UDim2.new(1, 0, 0, 24)
                            emptyLabel.Parent = listFrame
                            return
                        end

                        for _, cName in ipairs(cfgs) do
                            local itemRow = Instance.new("Frame")
                            itemRow.Name = "Item_" .. cName
                            itemRow.Size = UDim2.new(1, 0, 0, 32)
                            itemRow.BackgroundColor3 = Color3.fromRGB(28, 18, 46)
                            itemRow.BackgroundTransparency = 0.5
                            itemRow.BorderSizePixel = 0
                            itemRow.Parent = listFrame

                            local irCorner = Instance.new("UICorner")
                            irCorner.CornerRadius = UDim.new(0, 6)
                            irCorner.Parent = itemRow

                            local irStroke = Instance.new("UIStroke")
                            irStroke.Thickness = 1
                            irStroke.Color = Color3.fromRGB(120, 80, 190)
                            irStroke.Transparency = 0.6
                            irStroke.Parent = itemRow

                            local icon = Instance.new("TextLabel")
                            icon.Text = "📄"
                            icon.Font = Enum.Font.Gotham
                            icon.TextSize = 12
                            icon.Size = UDim2.new(0, 24, 1, 0)
                            icon.Position = UDim2.new(0, 6, 0, 0)
                            icon.BackgroundTransparency = 1
                            icon.Parent = itemRow

                            local nameLbl = Instance.new("TextLabel")
                            nameLbl.Text = cName
                            nameLbl.Font = Enum.Font.GothamMedium
                            nameLbl.TextSize = 12
                            nameLbl.TextColor3 = Color3.fromRGB(240, 235, 255)
                            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                            nameLbl.Position = UDim2.new(0, 32, 0, 0)
                            nameLbl.Size = UDim2.new(1, -125, 1, 0)
                            nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
                            nameLbl.BackgroundTransparency = 1
                            nameLbl.Parent = itemRow

                            local actions = Instance.new("Frame")
                            actions.Size = UDim2.new(0, 85, 1, 0)
                            actions.Position = UDim2.new(1, -90, 0, 0)
                            actions.BackgroundTransparency = 1
                            actions.Parent = itemRow

                            local aLayout = Instance.new("UIListLayout")
                            aLayout.FillDirection = Enum.FillDirection.Horizontal
                            aLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                            aLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                            aLayout.Padding = UDim.new(0, 5)
                            aLayout.Parent = actions

                            -- Load Button
                            local loadBtn = Instance.new("TextButton")
                            loadBtn.Size = UDim2.new(0, 50, 0, 22)
                            loadBtn.BackgroundColor3 = Color3.fromRGB(110, 55, 190)
                            loadBtn.BackgroundTransparency = 0.35
                            loadBtn.BorderSizePixel = 0
                            loadBtn.Text = "Load"
                            loadBtn.Font = Enum.Font.GothamBold
                            loadBtn.TextSize = 11
                            loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                            loadBtn.AutoButtonColor = false
                            loadBtn.Parent = actions

                            local lbCorner = Instance.new("UICorner")
                            lbCorner.CornerRadius = UDim.new(0, 5)
                            lbCorner.Parent = loadBtn

                            loadBtn.MouseButton1Click:Connect(function()
                                local rawJson = nil
                                pcall(function()
                                    if isfolder(folderPath) then
                                        local candidates = {
                                            folderPath .. "/" .. cName .. ".json",
                                            folderPath .. string.char(92) .. cName .. ".json",
                                            folderPath .. "/" .. cName,
                                            folderPath .. string.char(92) .. cName
                                        }
                                        for _, p in ipairs(candidates) do
                                            local ok, res = pcall(function() return readfile(p) end)
                                            if ok and res and res ~= "" then
                                                rawJson = res
                                                break
                                            end
                                        end
                                    end
                                end)

                                local cfgData = nil
                                if rawJson and rawJson ~= "" then
                                    pcall(function()
                                        cfgData = HttpService:JSONDecode(rawJson)
                                    end)
                                end

                                if not cfgData or not cfgData.flags then
                                    cfgData = inMemoryConfigs[cName]
                                end

                                if cfgData and cfgData.flags then
                                    local appliedCount = 0
                                    for flag, val in pairs(cfgData.flags) do
                                        local elem = lib.Elements[flag]
                                        if elem and elem.Set then
                                            local ok = pcall(function()
                                                elem.Set(val)
                                            end)
                                            if ok then
                                                appliedCount = appliedCount + 1
                                            end
                                        end
                                    end
                                    lib:Notify({
                                        Title = "Config Loaded",
                                        Description = string.format("Config '%s' applied (%d settings updated)!", cName, appliedCount),
                                        Duration = 3
                                    })
                                else
                                    lib:Notify({
                                        Title = "Config Error",
                                        Description = "Could not load data for config '" .. cName .. "'!",
                                        Duration = 3
                                    })
                                end
                            end)

                            -- Delete Button
                            local delBtn = Instance.new("TextButton")
                            delBtn.Size = UDim2.new(0, 24, 0, 22)
                            delBtn.BackgroundColor3 = Color3.fromRGB(150, 45, 65)
                            delBtn.BackgroundTransparency = 0.4
                            delBtn.BorderSizePixel = 0
                            delBtn.Text = "X"
                            delBtn.Font = Enum.Font.GothamBold
                            delBtn.TextSize = 11
                            delBtn.TextColor3 = Color3.fromRGB(255, 180, 190)
                            delBtn.AutoButtonColor = false
                            delBtn.Parent = actions

                            local dbCorner = Instance.new("UICorner")
                            dbCorner.CornerRadius = UDim.new(0, 5)
                            dbCorner.Parent = delBtn

                            delBtn.MouseButton1Click:Connect(function()
                                pcall(function()
                                    if isfolder(folderPath) then
                                        delfile(folderPath .. "/" .. cName .. ".json")
                                        delfile(folderPath .. string.char(92) .. cName .. ".json")
                                        delfile(folderPath .. "/" .. cName)
                                        delfile(folderPath .. string.char(92) .. cName)
                                    end
                                end)
                                inMemoryConfigs[cName] = nil
                                for k, _ in pairs(inMemoryConfigs) do
                                    if CleanConfigName(k) == cName then
                                        inMemoryConfigs[k] = nil
                                    end
                                end
                                RenderList()
                                lib:Notify({ Title = "Config Manager", Description = "Config '" .. cName .. "' deleted!", Duration = 2 })
                            end)
                        end
                    end

                    saveBtn.MouseButton1Click:Connect(function()
                        local cName = input.Text:gsub("[^%w_%-]", "")
                        if cName == "" then
                            lib:Notify({ Title = "Config Manager", Description = "Please enter a valid config name!", Duration = 2.5 })
                            return
                        end

                        local currentConfigs = GetAllConfigs()
                        local alreadyExists = false
                        for _, existing in ipairs(currentConfigs) do
                            if existing == cName then
                                alreadyExists = true
                                break
                            end
                        end

                        -- Limit: Maximum 10 configs!
                        if not alreadyExists and #currentConfigs >= 10 then
                            lib:Notify({
                                Title = "Config Limit Reached",
                                Description = "Maximum limit of 10 configs reached! Delete an existing config first.",
                                Duration = 3.5
                            })
                            return
                        end

                        -- Save all registered elements
                        local savedFlags = {}
                        for flag, elem in pairs(lib.Elements) do
                            pcall(function()
                                local val = elem.Get()
                                if typeof(val) == "Color3" then
                                    val = { R = val.R, G = val.G, B = val.B }
                                end
                                savedFlags[flag] = val
                            end)
                        end

                        local cfgData = {
                            name = cName,
                            savedAt = os.time(),
                            flags = savedFlags
                        }
                        local json = HttpService:JSONEncode(cfgData)

                        pcall(function()
                            if not isfolder(folderPath) then
                                makefolder(folderPath)
                            end
                            writefile(folderPath .. "/" .. cName .. ".json", json)
                        end)

                        inMemoryConfigs[cName] = cfgData
                        input.Text = ""
                        RenderList()

                        local newCount = #GetAllConfigs()
                        lib:Notify({
                            Title = "Config Manager",
                            Description = string.format("Config '%s' saved successfully! (%d/10)", cName, newCount),
                            Duration = 2.5
                        })
                    end)

                    RenderList()
                end

                table.insert(tabObj.Sections, section)
                return section
            end

            table.insert(window.Tabs, tabObj)
            if #window.Tabs == 1 then
                ActivateTab()
            end
            return tabObj
        end

        return window
    end

    return lib
end

return CreateAerisLibrary()
