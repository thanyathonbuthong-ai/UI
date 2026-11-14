--[[
    Catsaken UI Library
    -------------------------------------------------------------
    UI extracted from "CatSaken v4.1" as a standalone Luau library.
    Only the interface is included (window, tabs, sections, elements,
    theme tab, notifications, loading screen). No game logic.

    Usage:
        local Library = loadstring(readfile("CatsakenUI.lua"))()

        local Window = Library:CreateWindow({
            Name = "My Hub",
            Version = "V1.0",
            Icon = nil,                         -- rbxassetid / number / file path (nil = default cat icon)
            TabWidth = nil,                     -- default 160
            ToggleUIKeybind = "F4",
            ConfigurationSaving = { Enabled = true, FileName = "myhub.json", ConfigName = "default" },
        })

        local Tab = Window:CreateTab("Main", "star")      -- Lucide icon name
        Tab:CreateSection("Section", "Left")              -- "Left" / "Right"
        Tab:CreateToggle({ Name = "Toggle", Flag = "T1", CurrentValue = false, Callback = function(v) end })
        Window:CreateTab("#!SETTINGS", "cog")             -- hidden tab opened by the header cog button
        Window:CreateThemeTab()                           -- theme tab opened by the header brush button

    See Example.lua for every element.
]]

----------------------------------------------------------------
-- Services / executor shims
----------------------------------------------------------------
local cloneref_ = cloneref or function(obj) return obj end
local function GetService(name)
    return cloneref_(game:GetService(name))
end

local Players = GetService("Players")
local RunService = GetService("RunService")
local TweenService = GetService("TweenService")
local UserInputService = GetService("UserInputService")
local ContextActionService = GetService("ContextActionService")
local HttpService = GetService("HttpService")
local SoundService = GetService("SoundService")
local Debris = GetService("Debris")
local CoreGui = GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local wait = task.wait
local setthreadidentity = setthreadidentity or function() end
local gethui_ = gethui or function() return CoreGui end
local getcustomasset_ = getcustomasset or getsynasset
local function getcustomasset(path)
    if getcustomasset_ then
        return getcustomasset_(path)
    end
    return path
end
local isfile = isfile or function() return false end
local readfile = readfile or function() return "" end
local writefile = writefile or function() end
local isfolder = isfolder or function() return true end
local makefolder = makefolder or function() end
local delfolder = delfolder or function() end
local delfile = delfile or function() end
local listfiles = listfiles or function() return {} end
local loadfile = loadfile or function(path) return loadstring(readfile(path)) end

local function GetHui()
    if RunService:IsStudio() then
        return LocalPlayer:WaitForChild("PlayerGui")
    end
    local ok, result = pcall(gethui_)
    return ok and result or CoreGui
end

local function Warn(...)
    warn("[CatsakenUI]", ...)
end

----------------------------------------------------------------
-- Library table / settings
----------------------------------------------------------------
local Library = {
    Version = "1.0.0",
    Folder = "Catsaken",                         -- workspace folder (icons, themes, assets)
    Background = "https://github.com/aibabylaugh/catsaken/raw/main/patterns.jpg",
    Title = nil,                                 -- custom window title override
    SingleColumns = false,                       -- force single column layout (mobile always single)
    TabWidth = nil,
    SoundsEnabled = true,
    SoundIds = {},                               -- { select = "rbxassetid://..", click = .., switch = .., tick = .. }
    OnSound = nil,                               -- optional function(name, props) to play your own sounds
    SizeFile = "CatsakenMenuSize.txt",
    IconsUrl = "https://raw.githubusercontent.com/aibabylaugh/catsaken-real-script-not-assets/refs/heads/main/lucide.lua",
    TruncateTime = function(seconds)
        seconds = math.floor(seconds)
        return string.format("%d:%02d", seconds // 60, seconds % 60)
    end,
}

local Unloaded = false
local Connections = {}
local function Track(conn)
    Connections[#Connections + 1] = conn
    return conn
end

local IsMobile = UserInputService.TouchEnabled == true and UserInputService.KeyboardEnabled == false
local function Single()
    return IsMobile or Library.SingleColumns
end
local function ElementSize(height)
    return UDim2.new(1, -(Single() and 29 or 10), 0, height)
end

----------------------------------------------------------------
-- Utilities
----------------------------------------------------------------
local function Make(class, props, parent)
    local inst = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            inst[k] = v
        end
    end
    if parent then
        inst.Parent = parent
    end
    return inst
end

local function Tween(inst, info, goal)
    local tw = TweenService:Create(inst, info, goal)
    tw:Play()
    return tw
end

local function RandomString(len)
    local chars = ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"):split("")
    local out = ""
    for _ = 1, len or 16 do
        out ..= chars[math.random(1, #chars)]
    end
    return out
end

local function HttpGet(url)
    local req = (http and http.request) or request or http_request or (syn and syn.request)
    if req then
        local ok, res = pcall(req, { Url = url, Method = "GET" })
        if ok and type(res) == "table" and type(res.Body) == "string" and #res.Body > 0 then
            return res.Body
        end
    end
    local ok, body = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and type(body) == "string" then
        return body
    end
end

local function EnsureFolder()
    if not isfolder(Library.Folder) then
        makefolder(Library.Folder)
    end
end

local function EnsureFile(path, url)
    if not isfile(path) then
        local data = HttpGet(url)
        if data then
            writefile(path, data)
        end
    end
    return isfile(path)
end

local function PlaySound(name, props)
    if Unloaded or not Library.SoundsEnabled then
        return
    end
    if Library.OnSound then
        pcall(Library.OnSound, name, props)
        return
    end
    local id = Library.SoundIds[name]
    if id then
        local sound = Instance.new("Sound")
        sound.SoundId = id
        sound.Volume = (props and props.Volume) or 0.5
        sound.Parent = SoundService
        sound:Play()
        Debris:AddItem(sound, 5)
    end
end

local function FormatColor(c)
    return table.concat({ c:ToHSV() }, "/")
end
Library.FormatColor = FormatColor

local function SanitizeFlags(value)
    local tv = typeof(value)
    if tv == "table" then
        local out = {}
        for k, v in pairs(value) do
            local tk = typeof(k)
            if tk == "string" or tk == "number" then
                local s = SanitizeFlags(v)
                if s ~= nil then
                    out[k] = s
                end
            end
        end
        return out
    elseif tv == "Color3" then
        return FormatColor(value)
    elseif tv == "function" or tv == "Instance" or tv == "userdata" then
        return nil
    end
    return value
end

local function DeepCopy(v)
    if type(v) ~= "table" then
        return v
    end
    local t = {}
    for k, val in pairs(v) do
        t[DeepCopy(k)] = DeepCopy(val)
    end
    return setmetatable(t, getmetatable(v))
end

----------------------------------------------------------------
-- Icons (Lucide)
----------------------------------------------------------------
local IconCache
local EmptyIcon = { id = "", imageRectSize = Vector2.new(0, 0), imageRectOffset = Vector2.new(0, 0) }

local function LoadIconData()
    if IconCache ~= nil then
        return IconCache
    end
    EnsureFolder()
    local path = Library.Folder .. "/LucideIcons_V1.lua"
    local ok, data = pcall(function()
        if isfile(path) then
            return loadfile(path)()
        end
        local src = HttpGet(Library.IconsUrl)
        if not src then
            return nil
        end
        writefile(path, src)
        return loadstring(src)()
    end)
    IconCache = (ok and data) or false
    if not IconCache then
        Warn("could not load Lucide icons, icons will be empty")
    end
    return IconCache
end

local function GetIcon(name)
    if name == nil then
        return EmptyIcon
    end
    if typeof(name) == "number" then
        name = "rbxassetid://" .. name
    end
    if tostring(name):find("rbxasset") then
        return {
            id = name,
            imageRectSize = Vector2.new(0, 0),
            imageRectOffset = Vector2.new(0, 0),
        }
    end
    local data = LoadIconData()
    local entry = data and data["48px"] and data["48px"][string.match(string.lower(tostring(name)), "^%s*(.*)%s*$")]
    if not entry then
        return EmptyIcon
    end
    return {
        id = "rbxassetid://" .. entry[1],
        imageRectSize = Vector2.new(entry[2][1], entry[2][2]),
        imageRectOffset = Vector2.new(entry[3][1], entry[3][2]),
    }
end
Library.GetIcon = GetIcon

local function BannerAsset()
    if EnsureFile("banner.png", "https://github.com/lunar-repo/pic/raw/main/banner.png") then
        return getcustomasset("banner.png")
    end
    return ""
end

local function DefaultWindowIcon()
    EnsureFolder()
    local path = Library.Folder .. "/catsaken_transparent.png"
    if EnsureFile(path, "https://github.com/aibabylaugh/catsaken/raw/main/catsaken1.png") then
        return getcustomasset(path)
    end
    return ""
end

----------------------------------------------------------------
-- Accent / theme color system
----------------------------------------------------------------
Library.AccentColorChanged = Instance.new("BindableEvent")
Library.AccentVariantChanged = Instance.new("BindableEvent")
Library.AccentShadeNames = { "alt", "hover", "mid", "dark", "dark2", "deep", "light" }

local Accent = Color3.fromRGB(255, 190, 80)
local ShadeOffsets = {}
local ShadeOverrides = {}
local AccentAppliers = {}

do
    local h, s, v = Accent:ToHSV()
    for name, c in pairs({
        alt = Color3.fromRGB(255, 173, 80),
        hover = Color3.fromRGB(255, 150, 30),
        mid = Color3.fromRGB(245, 159, 39),
        dark = Color3.fromRGB(140, 85, 15),
        dark2 = Color3.fromRGB(160, 100, 15),
        deep = Color3.fromRGB(110, 65, 5),
        light = Color3.fromRGB(255, 200, 110),
    }) do
        local h2, s2, v2 = c:ToHSV()
        ShadeOffsets[name] = { h2 - h, s2 / s, v2 / v }
    end
end

local function GetAccentColor(shade)
    local override = shade and ShadeOverrides[shade]
    if override then
        return override
    end
    local offset = shade and ShadeOffsets[shade]
    if not offset then
        return Accent
    end
    local h, s, v = Accent:ToHSV()
    return Color3.fromHSV((h + offset[1]) % 1, math.clamp(s * offset[2], 0, 1), math.clamp(v * offset[3], 0, 1))
end

local function Bind(fn)
    fn()
    AccentAppliers[#AccentAppliers + 1] = fn
end

local function BindAccent(inst, prop, shade)
    Bind(function()
        inst[prop] = GetAccentColor(shade)
    end)
end

local function RefreshAccent()
    for _, fn in ipairs(AccentAppliers) do
        pcall(fn)
    end
end

local function RGBString(c)
    return string.format("rgb(%d, %d, %d)", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end

Track(Library.AccentColorChanged.Event:Connect(function(color)
    if typeof(color) ~= "Color3" then
        return
    end
    Accent = color
    RefreshAccent()
end))
Track(Library.AccentVariantChanged.Event:Connect(function(shade, color)
    if not ShadeOffsets[shade] then
        return
    end
    ShadeOverrides[shade] = typeof(color) == "Color3" and color or nil
    RefreshAccent()
end))

function Library:GetAccent(shade)
    return GetAccentColor(shade)
end

function Library:SetAccent(color)
    Library.AccentColorChanged:Fire(color)
end

----------------------------------------------------------------
-- Small widgets / helpers used by the window
----------------------------------------------------------------
local function AddBottomFade(scroll)
    local fade = Make("Frame", {
        Size = UDim2.new(1, 0, 0, 80),
        Position = UDim2.new(0, 0, 1, -80.0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0,
        ZIndex = scroll.ZIndex + 1,
    }, scroll.Parent)
    Make("UICorner", { CornerRadius = UDim.new(0, 5) }, fade)
    Make("UIGradient", {
        Rotation = 90,
        Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.6) }),
    }, fade)

    local function update()
        local atBottom = (scroll.CanvasPosition.Y + scroll.AbsoluteWindowSize.Y + 10) >= scroll.AbsoluteCanvasSize.Y - 1
        Tween(fade, TweenInfo.new(0.1, Enum.EasingStyle.Quad), { BackgroundTransparency = atBottom and 1 or 0 })
    end
    Track(scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(update))
    return fade
end

local function Ripple(parent, x, y)
    local ripple = Make("Frame", {
        Name = "Ripple",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(x, y),
        Size = UDim2.fromOffset(0, 0),
        ZIndex = parent.ZIndex + 1,
        ClipsDescendants = false,
    })
    Make("UICorner", { CornerRadius = UDim.new(1, 0) }, ripple)
    ripple.Parent = parent

    local abs = parent.AbsoluteSize
    local diameter = math.sqrt(abs.X ^ 2 + abs.Y ^ 2) * 0.2
    local tw = Tween(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(diameter, diameter),
        BackgroundTransparency = 1,
    })
    Track(tw.Completed:Connect(function()
        ripple:Destroy()
    end))
end

local function AddCustomScrollbar(scroll)
    scroll.ScrollBarThickness = 0

    local track = Make("TextButton", {
        Name = "CustomScrollTrack",
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.450,
        BorderSizePixel = 0,
        ZIndex = scroll.ZIndex + 1,
        Text = "",
    }, scroll.Parent)
    local bar = Make("Frame", {
        Name = "Bar",
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
    }, track)

    local function place()
        track.Position = UDim2.new(1, -2.0, 0, 0)
        track.Size = UDim2.new(0, 16, 1, 0)
    end
    place()

    local dragging = false
    local dragStartY = 0
    local startCanvasY = 0

    local function update()
        local canvas = scroll.AbsoluteCanvasSize.Y
        local window = scroll.AbsoluteWindowSize.Y
        if canvas <= window + 1 then
            track.Visible = false
            return
        end
        track.Visible = true
        local trackH = track.AbsoluteSize.Y
        local ratio = math.clamp(window / canvas, 0.05, 1)
        local barH = math.max(trackH * ratio, 20)
        local maxScroll = canvas - window
        local frac = maxScroll > 0 and (scroll.CanvasPosition.Y / maxScroll) or 0
        local free = trackH - barH
        bar.Size = UDim2.new(1, 0, 0, barH)
        bar.Position = UDim2.new(0, 0, 0, free * frac)
    end

    Track(scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(update))
    Track(scroll:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(update))
    Track(scroll:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(update))
    Track(track:GetPropertyChangedSignal("AbsoluteSize"):Connect(update))
    Track(scroll:GetPropertyChangedSignal("AbsolutePosition"):Connect(place))
    Track(scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(place))

    local function jumpTo(mouseY)
        local trackY = track.AbsolutePosition.Y
        local trackH = track.AbsoluteSize.Y
        local barH = bar.AbsoluteSize.Y
        local canvas = scroll.AbsoluteCanvasSize.Y
        local window = scroll.AbsoluteWindowSize.Y
        local maxScroll = math.max(canvas - window, 0)
        local free = math.max(trackH - barH, 1)
        local pos = math.clamp(mouseY - trackY - (barH / 2), 0, free)
        scroll.CanvasPosition = Vector2.new(scroll.CanvasPosition.X, maxScroll * (pos / free))
    end

    Track(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local canvas = scroll.AbsoluteCanvasSize.Y
            local window = scroll.AbsoluteWindowSize.Y
            local maxScroll = math.max(canvas - window, 0)
            local trackH = track.AbsoluteSize.Y
            local barH = bar.AbsoluteSize.Y
            local free = math.max(trackH - barH, 1)
            local delta = input.Position.Y - dragStartY
            local add = (delta / free) * maxScroll
            scroll.CanvasPosition = Vector2.new(scroll.CanvasPosition.X, math.clamp(startCanvasY + add, 0, maxScroll))
        end
    end))
    Track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
    Track(track.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        local barTop = bar.AbsolutePosition.Y
        local barH = bar.AbsoluteSize.Y
        local onBar = input.Position.Y >= barTop and input.Position.Y <= barTop + barH
        if onBar then
            dragging = true
            dragStartY = input.Position.Y
            startCanvasY = scroll.CanvasPosition.Y
        else
            jumpTo(input.Position.Y)
        end
    end))
    update()
    return track
end

local function MakeDraggable(frame, handle)
    local detector = Instance.new("UIDragDetector")
    detector.Parent = handle
    detector.ResponseStyle = Enum.UIDragDetectorResponseStyle.CustomOffset

    local startPoint, startPos
    detector.DragContinue:Connect(function(point)
        if not startPoint then
            startPoint, startPos = point, frame.Position
            return
        end
        local delta = point - startPoint
        Tween(frame, TweenInfo.new(0.05), {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y),
        })
    end)
    detector.DragEnd:Connect(function()
        startPoint = nil
    end)
end

----------------------------------------------------------------
-- Smooth scrolling module (mouse wheel inertia + scroll bar drag)
----------------------------------------------------------------
local SmoothScroll

local function BuildSmoothScroll()
    local mouse = LocalPlayer:GetMouse()
    local parentGui = RunService:IsStudio() and LocalPlayer:WaitForChild("PlayerGui") or CoreGui

    wait()

    local DefaultSens, DefaultFrict = mouse.ViewSizeY / 27, 0.78
    local registry = {}
    local container
    local draggingBar = false
    local module = {}

    if not UserInputService.TouchEnabled then
        container = Instance.new("ScreenGui")
        container.Name = "SmoothScroll"
        container.Parent = parentGui

        Track(RunService.Heartbeat:Connect(function()
            for frame, data in pairs(registry) do
                if data.Velocity > 0.05 or data.Velocity < -0.05 then
                    data.Velocity = data.Velocity * data.Frict
                    if data.Axis == "X" then
                        frame.CanvasPosition = Vector2.new(frame.CanvasPosition.X + data.Velocity, frame.CanvasPosition.Y)
                        if math.abs(data.LastPos - frame.CanvasPosition.X) == 0 then
                            data.Velocity = 0
                        end
                        data.LastPos = frame.CanvasPosition.X
                    else
                        frame.CanvasPosition = Vector2.new(frame.CanvasPosition.X, frame.CanvasPosition.Y + data.Velocity)
                        if math.abs(data.LastPos - frame.CanvasPosition.Y) == 0 then
                            data.Velocity = 0
                        end
                        data.LastPos = frame.CanvasPosition.Y
                    end
                end
            end
        end))

        Track(UserInputService.PointerAction:Connect(function(_, pan)
            if not draggingBar then
                local objects = parentGui:GetGuiObjectsAtPosition(mouse.X, mouse.Y)
                for _, obj in ipairs(objects) do
                    local data = registry[obj]
                    if data and data.Visibility.Visible == true then
                        data.Velocity = data.Velocity - (data.Sens * pan.Y * (data.Inverted and -1.0 or 1))
                        break
                    end
                end
            end
        end))

        ContextActionService:BindActionAtPriority("SmoothScroll", function(_, _, input)
            if draggingBar then
                return Enum.ContextActionResult.Pass
            end
            local handled = false
            local objects = parentGui:GetGuiObjectsAtPosition(mouse.X, mouse.Y)
            for _, obj in ipairs(objects) do
                local data = registry[obj]
                if data and data.Visibility.Visible == true then
                    data.Velocity = data.Velocity - (data.Sens * input.Position.Z * (data.Inverted and -1.0 or 1))
                    handled = true
                    break
                end
            end
            return handled and Enum.ContextActionResult.Sink or Enum.ContextActionResult.Pass
        end, false, 8000, Enum.UserInputType.MouseWheel)
    end

    -- visibility tracker (is the frame + all ancestors visible?)
    local VisTracker = {}
    VisTracker.__index = VisTracker

    function VisTracker.new(gui)
        assert(typeof(gui) == "Instance" and gui:IsA("GuiObject"), "Argument #1 expected GuiObject")
        local changedEvent = Instance.new("BindableEvent")
        local self = setmetatable({
            GuiObject = gui,
            Visible = nil,
            Changed = changedEvent.Event,
            _path = {},
            _conn = {},
            _root = nil,
            _visibleChanged = changedEvent,
        }, VisTracker)

        local function update()
            local vis = (self._root and self._root.Enabled or false)
            if vis then
                for _, g in ipairs(self._path) do
                    if not g.Visible then
                        vis = false
                        break
                    end
                end
            end
            if vis ~= self.Visible then
                self.Visible = vis
                changedEvent:Fire(vis)
            end
        end

        local function rebuild()
            for _, c in ipairs(self._conn) do
                c:Disconnect()
            end
            local path, conns, root = {}, {}, nil
            local cur = gui
            while cur and (cur:IsA("GuiObject") or cur:IsA("Folder")) do
                if cur:IsA("GuiObject") then
                    conns[#conns + 1] = cur:GetPropertyChangedSignal("Visible"):Connect(update)
                    Track(conns[#conns])
                    path[#path + 1] = cur
                end
                cur = cur.Parent
            end
            if cur and cur:IsA("LayerCollector") then
                conns[#conns + 1] = cur:GetPropertyChangedSignal("Enabled"):Connect(update)
                Track(conns[#conns])
                root = cur
            end
            self._path = path
            self._conn = conns
            self._root = root
            update()
        end

        self._ancestry = gui.AncestryChanged:Connect(function()
            rebuild()
        end)
        Track(self._ancestry)
        rebuild()
        return self
    end

    function VisTracker:Destroy()
        self._visibleChanged:Fire(false)
        self._visibleChanged:Destroy()
        self._ancestry:Disconnect()
        for _, c in ipairs(self._conn) do
            c:Disconnect()
        end
    end

    local function CreateScroller(frame, axis)
        if not (frame and typeof(frame) == "Instance" and frame.ClassName == "ScrollingFrame") then
            Warn("Invalid frame to create custom bar")
            return
        end

        local btn = Instance.new("TextButton")
        btn.Name = frame.Name .. "_Scroller_" .. axis
        btn.Text = ""
        btn.BackgroundTransparency = 1
        btn.Visible = registry[frame].Visibility.Visible

        local size, pos, thick = frame.AbsoluteSize, frame.AbsolutePosition, frame.ScrollBarThickness
        local moveConn

        Track(btn.MouseButton1Down:Connect(function()
            if not draggingBar and not moveConn then
                draggingBar = true
                local last = Vector2.new(mouse.X, mouse.Y)
                moveConn = UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        local cur = Vector2.new(input.Position.X, input.Position.Y)
                        local delta = cur - last
                        local frac = (axis == "Y" and delta.Y or delta.X) / (axis == "Y" and frame.AbsoluteWindowSize.Y or frame.AbsoluteWindowSize.X)
                        local ancestor = frame:FindFirstAncestorWhichIsA("GuiBase2d")
                        if ancestor then
                            local canvas = Vector2.new(
                                (frame.CanvasSize.X.Scale * ancestor.AbsoluteSize.X) + frame.CanvasSize.X.Offset,
                                (frame.CanvasSize.Y.Scale * ancestor.AbsoluteSize.Y) + frame.CanvasSize.Y.Offset
                            )
                            frame.CanvasPosition = Vector2.new(
                                frame.CanvasPosition.X + (axis == "X" and canvas.X * frac or 0),
                                frame.CanvasPosition.Y + (axis == "Y" and canvas.Y * frac or 0)
                            )
                        end
                        last = cur
                    end
                end)
            end
        end))

        local inputEnded = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and moveConn then
                draggingBar = false
                moveConn:Disconnect()
                moveConn = nil
            end
        end)
        Track(inputEnded)
        Track(registry[frame].Visibility.Changed:Connect(function(vis)
            btn.Visible = vis
            if not vis and moveConn then
                draggingBar = false
                moveConn:Disconnect()
                moveConn = nil
            end
        end))

        local function layout()
            if axis == "X" then
                btn.Size = UDim2.new(0, size.X, 0, thick)
                btn.Position = UDim2.new(0, pos.X, 0, pos.Y + size.Y - thick)
            else
                btn.Size = UDim2.new(0, thick, 0, size.Y)
                btn.Position = UDim2.new(0, frame.VerticalScrollBarPosition == Enum.VerticalScrollBarPosition.Right and pos.X + size.X - thick or pos.X, 0, pos.Y)
            end
        end
        layout()

        local changedConn
        changedConn = frame.Changed:Connect(function(prop)
            if registry[frame] then
                if frame:FindFirstAncestorWhichIsA("GuiBase2d") then
                    if prop == "AbsoluteSize" or prop == "AbsolutePosition" or prop == "CanvasSize" or prop == "ScrollBarThickness" then
                        size, pos, thick = frame.AbsoluteSize, frame.AbsolutePosition, frame.ScrollBarThickness
                        layout()
                    end
                end
            else
                btn:Destroy()
                changedConn:Disconnect()
                inputEnded:Disconnect()
                if moveConn then
                    moveConn:Disconnect()
                    moveConn = nil
                end
            end
        end)
        Track(changedConn)
        btn.Parent = container
    end

    function module.Enable(frame, sens, frict, inverted, axis)
        if UserInputService.MouseEnabled and not UserInputService.TouchEnabled then
            if not (frame and typeof(frame) == "Instance" and frame.ClassName == "ScrollingFrame") then
                Warn("Invalid frame to smooth")
                return
            end

            if not registry[frame] then
                frame.ScrollingEnabled = false

                local actives, conns = {}, {}

                for _, desc in ipairs(frame:GetDescendants()) do
                    if desc:IsA("GuiObject") then
                        actives[desc] = desc.Active
                        desc.Active = false
                        conns[#conns + 1] = desc:GetPropertyChangedSignal("Active"):Connect(function()
                            desc.Active = false
                        end)
                        Track(conns[#conns])
                    end
                end

                local cur = frame
                while cur and (cur:IsA("GuiObject") or cur:IsA("Folder")) do
                    if cur:IsA("GuiObject") then
                        local target = cur
                        actives[target] = target.Active
                        target.Active = false
                        conns[#conns + 1] = target:GetPropertyChangedSignal("Active"):Connect(function()
                            target.Active = false
                        end)
                        Track(conns[#conns])
                    end
                    cur = cur.Parent
                end

                conns[#conns + 1] = frame.DescendantAdded:Connect(function(desc)
                    if desc:IsA("GuiObject") then
                        registry[frame].Actives[desc] = desc.Active
                        desc.Active = false
                        registry[frame].Connections[#registry[frame].Connections + 1] = desc:GetPropertyChangedSignal("Active"):Connect(function()
                            desc.Active = false
                        end)
                    end
                end)
                Track(conns[#conns])

                if not (axis and (axis == "X" or axis == "Y")) then
                    axis = "Y"
                    if frame.CanvasSize.Y.Offset > 0 or frame.CanvasSize.Y.Scale > 0 then
                        axis = "Y"
                    elseif frame.CanvasSize.X.Offset > 0 or frame.CanvasSize.X.Scale > 0 then
                        axis = "X"
                    end
                end

                registry[frame] = {
                    Connections = conns,
                    Actives = actives,
                    Velocity = 0,
                    LastPos = 0,
                    Visibility = VisTracker.new(frame),
                    Inverted = inverted,
                    Axis = axis,
                    Frict = math.clamp(type(frict) == "number" and frict or DefaultFrict, 0.2, 0.99),
                    Sens = math.clamp(type(sens) == "number" and sens or DefaultSens, 0.01, 99999999999999999),
                }
                CreateScroller(frame, "X")
                CreateScroller(frame, "Y")
            else
                registry[frame].Sens = math.clamp(type(sens) == "number" and sens or DefaultSens, 0.01, 99999999999999999)
                registry[frame].Frict = math.clamp(type(frict) == "number" and frict or DefaultFrict, 0.2, 0.99)
                registry[frame].Inverted = inverted
            end
        end
    end

    function module.Disable(frame)
        if registry[frame] then
            frame.ScrollingEnabled = true
            for _, c in ipairs(registry[frame].Connections) do
                c:Disconnect()
            end
            registry[frame].Visibility:Destroy()
            for obj, active in pairs(registry[frame].Actives) do
                obj.Active = active
            end
            registry[frame] = nil
        end
    end

    function module.Destroy()
        pcall(function()
            ContextActionService:UnbindAction("SmoothScroll")
        end)
        if container then
            container:Destroy()
        end
    end

    return module
end

local function GetSmoothScroll()
    if not SmoothScroll then
        SmoothScroll = BuildSmoothScroll()
    end
    return SmoothScroll
end

----------------------------------------------------------------
-- SafeCallback
----------------------------------------------------------------
function Library:SafeCallback(callback, name, kind, ...)
    assert(typeof(callback) == "function", "SafeCallback: Callback is not a function")
    assert(typeof(name) == "string", "SafeCallback: Name is not a string")
    assert(typeof(kind) == "string", "SafeCallback: Type is not a string")
    xpcall(callback, function(err)
        Warn(string.format("[UI] error in %s \"%s\"! threw: %s", tostring(kind), tostring(name), tostring(err)))
    end, ...)
end

----------------------------------------------------------------
-- Window
----------------------------------------------------------------
function Library:CreateWindow(cfg)
    cfg = cfg or {}
    EnsureFolder()

    local window = {}
    window.Keybinds = {}
    window.Flags = setmetatable({}, {
        __index = function(tbl, key)
            if not rawget(tbl, key) then
                return { CurrentValue = false, Color = Color3.fromRGB(0, 0, 0), CurrentOption = {} }
            end
            return rawget(tbl, key)
        end,
    })

    local titleName = cfg.Name or "Catsaken"
    local defaultTitle = titleName
    local versionText = cfg.Version or "V0.0"
    if cfg.TabWidth then
        Library.TabWidth = cfg.TabWidth
    end
    local tabWidth = cfg.TabWidth or Library.TabWidth

    -- saved flags (config)
    local saved = {}
    local configPath, configName
    local cs = cfg.ConfigurationSaving
    if cs and cs.Enabled then
        configPath = cs.FileName or "catsakenconfigs.json"
        configName = cs.ConfigName or ("catsaken-default-" .. LocalPlayer.Name .. ".json")
        if isfile(configPath) then
            local ok, data = pcall(function()
                return HttpService:JSONDecode(readfile(configPath))
            end)
            if ok and type(data) == "table" and type(data[configName]) == "table" then
                saved = data[configName]
            end
        else
            writefile(configPath, HttpService:JSONEncode({ [configName] = {} }))
        end
    end

    ----------------------------------------------------------------
    -- Background / title management
    ----------------------------------------------------------------
    local bgImage = Library.Background or BannerAsset()
    local applyBackground = function() end

    if isfolder("lunarbackgrounds") then
        delfolder("lunarbackgrounds")
    end
    makefolder("lunarbackgrounds")

    function window:UpdateBackground()
        bgImage = Library.Background
        if bgImage then
            local filePath = "lunarbackgrounds/" .. RandomString(10)
            if (bgImage:find("https://") or bgImage:find("http://")) and not bgImage:match("http?.://roblox%.com") then
                local data = HttpGet(bgImage)
                if data and type(data) == "string" then
                    writefile(filePath, data)
                    bgImage = getcustomasset(filePath) or BannerAsset()
                end
            end
        else
            bgImage = BannerAsset()
        end
        applyBackground()
    end
    window:UpdateBackground()

    local iconAsset = cfg.Icon
    if iconAsset == nil then
        iconAsset = DefaultWindowIcon()
    elseif typeof(iconAsset) == "number" then
        iconAsset = "rbxassetid://" .. iconAsset
    elseif type(iconAsset) == "string" and not iconAsset:find("rbxasset") and not iconAsset:find("://") and isfile(iconAsset) then
        iconAsset = getcustomasset(iconAsset)
    end

    ----------------------------------------------------------------
    -- Main GUI
    ----------------------------------------------------------------
    local gui = Instance.new("ScreenGui")
    local main = Instance.new("Frame")
    local bgLabel = Instance.new("ImageLabel")
    local mainCorner = Instance.new("UICorner")
    local topbar = Instance.new("Frame")
    local topbarCorner = Instance.new("UICorner")
    local iconLabel = Instance.new("ImageLabel")
    local titleLabel = Instance.new("TextLabel")
    local searchFrame = Instance.new("Frame")
    local searchCorner = Instance.new("UICorner")
    local searchIcon = Instance.new("ImageLabel")
    local searchBox = Instance.new("TextBox")
    local bgCorner = Instance.new("UICorner")
    local tabListFrame = Instance.new("Frame")
    local tabList = Instance.new("ScrollingFrame")
    local tabListLayout = Instance.new("UIListLayout")

    MakeDraggable(main, topbar)

    pcall(function()
        local shadow = Instance.new("UIShadow")
        shadow.Parent = main
        shadow.BlurRadius = UDim.new(0, 10)
    end)

    gui.Name = HttpService:GenerateGUID()
    gui.Parent = GetHui()
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.ResetOnSpawn = false
    gui.Enabled = false
    gui.OnTopOfCoreBlur = true
    gui.DisplayOrder = 2147483647
    gui.IgnoreGuiInset = true
    Library.ScreenGui = gui
    window.ScreenGui = gui

    function window:SetVisible(state)
        gui.Enabled = state and true or false
    end
    function window:Toggle()
        gui.Enabled = not gui.Enabled
    end
    function window:IsVisible()
        return gui.Enabled
    end

    local toggleKey = cfg.ToggleUIKeybind or "F4"
    if type(toggleKey) == "string" then
        toggleKey = Enum.KeyCode[toggleKey] or Enum.KeyCode.F4
    end
    Track(UserInputService.InputBegan:Connect(function(input, processed)
        if Unloaded or processed then
            return
        end
        if input.KeyCode == toggleKey then
            window:Toggle()
        end
    end))

    if IsMobile and cfg.MobileToggle ~= false then
        local toggleGui = Make("ScreenGui", {
            Name = "CatsakenToggle",
            ResetOnSpawn = false,
            IgnoreGuiInset = true,
            DisplayOrder = 2147483647,
        })
        toggleGui.Parent = GetHui()
        local toggleBtn = Make("ImageButton", {
            Size = UDim2.fromOffset(40, 40),
            Position = UDim2.new(0, 12, 0, 64),
            BackgroundColor3 = Color3.fromRGB(13, 13, 13),
            BackgroundTransparency = 0.35,
            Image = iconAsset,
            AutoButtonColor = false,
        }, toggleGui)
        Make("UICorner", { CornerRadius = UDim.new(0, 8) }, toggleBtn)
        Make("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) }, toggleBtn)
        Track(toggleBtn.MouseButton1Click:Connect(function()
            window:Toggle()
        end))
        window.MobileToggleGui = toggleGui
    end

    ----------------------------------------------------------------
    -- Tooltip
    ----------------------------------------------------------------
    local tooltip = Make("Frame", {
        Name = "Tooltip",
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(220, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = false,
        ZIndex = 1000,
    }, gui)
    Make("UICorner", { CornerRadius = UDim.new(0, 7) }, tooltip)
    local tooltipStroke = Make("UIStroke", { Color = Color3.fromRGB(65, 65, 65), Thickness = 1, Transparency = 0.15 }, tooltip)
    Make("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 7),
        PaddingBottom = UDim.new(0, 7),
    }, tooltip)
    local tooltipText = Make("TextLabel", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Font = Enum.Font.Gotham,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        RichText = true,
        ZIndex = 1001,
    }, tooltip)
    local tooltipScale = Make("UIScale", { Scale = 1 }, tooltip)

    local tipTarget, tipActive, tipToken, tipTouch = nil, false, 0, nil

    local function pointer()
        if tipTouch then
            return tipTouch.Position
        end
        return UserInputService:GetMouseLocation()
    end

    local function positionTooltip()
        if not tipActive then
            return
        end
        local cam = workspace.CurrentCamera
        if not cam then
            return
        end
        local viewport = cam.ViewportSize
        local pt = pointer()
        local size = tooltip.AbsoluteSize
        local x = pt.X + 14
        local y = pt.Y - size.Y - 14
        if x + size.X > viewport.X - 6 then
            x = pt.X - size.X - 14
        end
        if y < 6 then
            y = pt.Y + 14
        end
        x = math.clamp(x, 6, math.max(6, viewport.X - size.X - 6))
        y = math.clamp(y, 6, math.max(6, viewport.Y - size.Y - 6))
        tooltip.Position = UDim2.fromOffset(x, y)
    end

    local function showTooltip(target, text)
        if not text or text == "" then
            return
        end
        tipToken += 1
        local token = tipToken
        tipTarget = target
        tipActive = true
        tooltipText.Text = text
        tooltip.Visible = true
        tooltipScale.Scale = 0.96
        tooltip.BackgroundTransparency = 0.05
        tooltipStroke.Transparency = 0.15
        task.defer(function()
            if token ~= tipToken or not tipActive then
                return
            end
            positionTooltip()
            Tween(tooltipScale, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Scale = 1 })
        end)
    end

    local function hideTooltip()
        tipToken += 1
        tipTarget = nil
        tipActive = false
        tipTouch = nil
        tooltip.Visible = false
    end

    local function attachTooltip(guiObject, opts)
        if not guiObject or not opts then
            return
        end
        local tip = opts.ToolTip
        if not tip or tip == "" then
            return
        end
        guiObject.Active = true
        Track(guiObject.MouseEnter:Connect(function()
            if IsMobile then
                return
            end
            showTooltip(guiObject, tip)
        end))
        Track(guiObject.MouseLeave:Connect(function()
            if IsMobile then
                return
            end
            if tipTarget == guiObject then
                hideTooltip()
            end
        end))
        Track(guiObject.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.Touch then
                return
            end
            tipTouch = input
            tipToken += 1
            local token = tipToken
            task.delay(0.28, function()
                if token ~= tipToken then
                    return
                end
                if tipTouch ~= input then
                    return
                end
                showTooltip(guiObject, tip)
            end)
        end))
        Track(guiObject.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                tipTouch = input
                if tipTarget == guiObject then
                    positionTooltip()
                end
            end
        end))
        Track(guiObject.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                if tipTouch == input then
                    hideTooltip()
                end
            end
        end))
    end

    Track(UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if tipActive then
                positionTooltip()
            end
        elseif input.UserInputType == Enum.UserInputType.Touch then
            if tipActive then
                tipTouch = input
                positionTooltip()
            end
        end
    end))

    ----------------------------------------------------------------
    -- Main frame
    ----------------------------------------------------------------
    main.Parent = gui
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    main.BorderColor3 = Color3.fromRGB(0, 0, 0)
    main.BorderSizePixel = 0
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.Size = Single() and UDim2.new(0, 570, 0, gui.AbsoluteSize.Y / 1.4) or UDim2.new(0, 890, 0, 460)
    pcall(function()
        local sx, sy = readfile(Library.SizeFile):match("(%d+),(%d+)")
        main.Size = UDim2.fromOffset(math.max(420, tonumber(sx)), math.max(260, tonumber(sy)))
    end)
    mainCorner.TopLeftRadius = UDim.new(0, 5)
    mainCorner.TopRightRadius = UDim.new(0, 5)
    mainCorner.BottomRightRadius = UDim.new(0, 5)
    mainCorner.BottomLeftRadius = UDim.new(0, 5)
    mainCorner.Parent = main

    local mainStroke = Instance.new("UIStroke")
    BindAccent(mainStroke, "Color")
    mainStroke.Transparency = 0.75
    mainStroke.Thickness = 1
    mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    mainStroke.Parent = main

    topbar.Parent = main
    topbar.BackgroundColor3 = Color3.fromRGB(13, 13, 13)
    topbar.BackgroundTransparency = 0.650
    topbar.BorderColor3 = Color3.fromRGB(0, 0, 0)
    topbar.BorderSizePixel = 0
    topbar.Size = UDim2.new(1, 0, 0, 50)
    topbarCorner.TopLeftRadius = UDim.new(0, 5)
    topbarCorner.TopRightRadius = UDim.new(0, 5)
    topbarCorner.BottomRightRadius = UDim.new(0, 0)
    topbarCorner.BottomLeftRadius = UDim.new(0, 0)
    topbarCorner.Parent = topbar

    iconLabel.Parent = topbar
    iconLabel.AnchorPoint = Vector2.new(0, 0.5)
    iconLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    iconLabel.BackgroundTransparency = 1.000
    iconLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    iconLabel.BorderSizePixel = 0
    iconLabel.Position = UDim2.new(0, 3, 0.5, 0)
    iconLabel.Size = UDim2.new(0, 36, 0, 36)
    iconLabel.Image = iconAsset

    titleLabel.Parent = topbar
    titleLabel.AnchorPoint = Vector2.new(0, 0.5)
    titleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1.000
    titleLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    titleLabel.BorderSizePixel = 0
    titleLabel.Position = UDim2.new(0, 50, 0.5, 0)
    titleLabel.Size = UDim2.new(0, 200, 0, 20)
    titleLabel.FontFace = Font.fromName("Arial", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    titleLabel.Text = titleName
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 14.000
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.RichText = true

    local versionLabel = titleLabel:Clone()
    versionLabel.Parent = topbar
    versionLabel.AnchorPoint = Vector2.new(1, 0.5)
    versionLabel.Position = UDim2.new(1, -17.0, 0.5, 0)
    versionLabel.Text = versionText
    versionLabel.TextColor3 = Color3.fromRGB(144, 144, 144)
    versionLabel.Size = UDim2.new(0, 34, 0, 14)
    versionLabel.TextXAlignment = Enum.TextXAlignment.Right

    local titleGradient = Instance.new("UIGradient")
    Bind(function()
        titleGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, GetAccentColor()),
            ColorSequenceKeypoint.new(1, GetAccentColor("alt")),
        })
    end)
    titleGradient.Parent = titleLabel

    function window:UpdateTitle()
        titleLabel.Text = type(Library.Title) == "string" and Library.Title or titleName
    end

    local idleColor = Color3.fromRGB(150, 150, 150)
    local quartTween = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local fastTween = TweenInfo.new(0.15)
    local searchOpen, searchHover = false, false

    RunService.RenderStepped:Wait()

    -- search button
    searchFrame.Name = "search"
    searchFrame.Parent = topbar
    searchFrame.AnchorPoint = Vector2.new(1, 0.5)
    BindAccent(searchFrame, "BackgroundColor3", "dark")
    searchFrame.BackgroundTransparency = 1
    searchFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    searchFrame.BorderSizePixel = 0
    searchFrame.ClipsDescendants = true
    searchFrame.Position = UDim2.new(1, -(22 + versionLabel.TextBounds.X + 56.0), 0.5, 0)
    searchFrame.Size = UDim2.new(0, 28, 1, -24.0)
    searchCorner.CornerRadius = UDim.new(0, 5)
    searchCorner.Parent = searchFrame

    local searchIconData = GetIcon("search")
    searchIcon.Parent = searchFrame
    searchIcon.AnchorPoint = Vector2.new(1, 0.5)
    searchIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    searchIcon.BackgroundTransparency = 1.000
    searchIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
    searchIcon.BorderSizePixel = 0
    searchIcon.Position = UDim2.new(1, -6.0, 0.5, 0)
    searchIcon.Size = UDim2.new(0, 16, 0, 16)
    searchIcon.Image = searchIconData.id
    searchIcon.ImageRectOffset = searchIconData.imageRectOffset
    searchIcon.ImageRectSize = searchIconData.imageRectSize
    searchIcon.ImageColor3 = idleColor

    searchBox.Parent = searchFrame
    searchBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.BackgroundTransparency = 1.000
    searchBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
    searchBox.BorderSizePixel = 0
    searchBox.ClipsDescendants = true
    searchBox.Position = UDim2.new(0, 4, 0, 0)
    searchBox.Size = UDim2.new(1, -34.0, 1, 0)
    searchBox.Font = Enum.Font.GothamMedium
    searchBox.PlaceholderText = "Search"
    searchBox.Text = ""
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.TextSize = 14.000
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.Visible = false

    local searchHit = Instance.new("TextButton")
    searchHit.Name = "hit"
    searchHit.Parent = searchFrame
    searchHit.BackgroundTransparency = 1
    searchHit.BorderSizePixel = 0
    searchHit.Size = UDim2.new(1, 0, 1, 0)
    searchHit.Text = ""
    searchHit.AutoButtonColor = false
    searchHit.ZIndex = 5

    local function updateSearchIcon()
        Tween(searchIcon, fastTween, { ImageColor3 = (searchOpen or searchHover) and GetAccentColor("hover") or idleColor })
    end
    Bind(updateSearchIcon)

    local function setSearchOpen(open)
        searchOpen = open
        searchHover = false
        searchHit.Visible = not open
        searchBox.Visible = open
        Tween(searchFrame, quartTween, {
            Size = UDim2.new(0, open and 139 or 28, 1, -24.0),
            BackgroundTransparency = open and 0.65 or 1,
        })
        updateSearchIcon()
        if open then
            searchBox:CaptureFocus()
        end
    end

    Track(searchHit.MouseEnter:Connect(function()
        searchHover = true
        updateSearchIcon()
    end))
    Track(searchHit.MouseLeave:Connect(function()
        searchHover = false
        updateSearchIcon()
    end))
    Track(searchHit.MouseButton1Click:Connect(function()
        PlaySound("select")
        setSearchOpen(true)
    end))
    Track(searchBox.FocusLost:Connect(function()
        if searchOpen and searchBox.Text == "" then
            setSearchOpen(false)
        end
    end))

    -- header icon buttons (settings / theme)
    local function CreateHeaderButton(name, iconName, offsetX, onClick)
        local frame = Instance.new("Frame")
        frame.Name = name
        frame.Parent = topbar
        frame.AnchorPoint = Vector2.new(1, 0.5)
        frame.BackgroundTransparency = 1
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = true
        frame.Position = UDim2.new(1, -(22 + versionLabel.TextBounds.X + offsetX), 0.5, 0)
        frame.Size = UDim2.new(0, 28, 1, -24.0)

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 5)
        corner.Parent = frame

        local iconData = GetIcon(iconName)
        local icon = Instance.new("ImageLabel")
        icon.Parent = frame
        icon.AnchorPoint = Vector2.new(1, 0.5)
        icon.BackgroundTransparency = 1
        icon.BorderSizePixel = 0
        icon.Position = UDim2.new(1, -6.0, 0.5, 0)
        icon.Size = UDim2.new(0, 16, 0, 16)
        icon.Image = iconData.id
        icon.ImageRectOffset = iconData.imageRectOffset
        icon.ImageRectSize = iconData.imageRectSize
        icon.ImageColor3 = idleColor

        local hit = Instance.new("TextButton")
        hit.Name = "hit"
        hit.Parent = frame
        hit.BackgroundTransparency = 1
        hit.BorderSizePixel = 0
        hit.Size = UDim2.new(1, 0, 1, 0)
        hit.Text = ""
        hit.AutoButtonColor = false
        hit.ZIndex = 5

        Track(hit.MouseEnter:Connect(function()
            Tween(icon, fastTween, { ImageColor3 = GetAccentColor("hover") })
        end))
        Track(hit.MouseLeave:Connect(function()
            Tween(icon, fastTween, { ImageColor3 = idleColor })
        end))
        Track(hit.MouseButton1Click:Connect(onClick))
        return frame
    end

    CreateHeaderButton("settings", "settings", 0, function()
        if not Library._SettingsTabIndex then
            Warn("yo theres no settings tab wtf")
            return
        end
        PlaySound("select")
        window:SelectTab(Library._SettingsTabIndex)
    end)
    CreateHeaderButton("theme", "paintbrush", 28, function()
        if not Library._ThemeTabIndex then
            return Warn("no theme tab, call Window:CreateThemeTab()")
        end
        PlaySound("select")
        window:SelectTab(Library._ThemeTabIndex)
    end)

    -- background image
    bgLabel.Name = "backgroundimagelabel"
    bgLabel.Parent = main
    bgLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    bgLabel.BackgroundTransparency = 1.00
    bgLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    bgLabel.BorderSizePixel = 0
    bgLabel.Size = UDim2.new(1, 0, 1, 0)
    bgLabel.ZIndex = 0
    bgLabel.Image = bgImage or ""
    bgLabel.ImageColor3 = Color3.fromRGB(116, 116, 116)
    bgLabel.ScaleType = Enum.ScaleType.Crop
    applyBackground = function()
        bgLabel.Image = bgImage or BannerAsset()
    end
    bgCorner.CornerRadius = UDim.new(0, 5)
    bgCorner.Parent = bgLabel

    -- tab list
    tabListFrame.Parent = main
    tabListFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    tabListFrame.BackgroundTransparency = 0.650
    tabListFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    tabListFrame.BorderSizePixel = 0
    tabListFrame.Position = UDim2.new(0, 1, 0, 50)
    tabListFrame.Size = UDim2.new(0, tabWidth or 160, 1, -50.0)

    tabList.Parent = tabListFrame
    tabList.Active = true
    tabList.AnchorPoint = Vector2.new(0, 0.5)
    tabList.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    tabList.BackgroundTransparency = 1.000
    tabList.BorderColor3 = Color3.fromRGB(0, 0, 0)
    tabList.BorderSizePixel = 0
    tabList.Position = UDim2.new(0, 0, 0.5, 0)
    tabList.Size = UDim2.new(1, 0, 1, -6.0)
    tabList.ScrollBarThickness = 2
    BindAccent(tabList, "ScrollBarImageColor3", "mid")
    tabList.ScrollBarImageTransparency = 0.4
    tabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabList.ScrollingDirection = Enum.ScrollingDirection.Y
    tabList.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
    tabList.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
    tabList.ClipsDescendants = true
    AddBottomFade(tabList)
    GetSmoothScroll().Enable(tabList, 2, 0.9)
    tabListLayout.Parent = tabList
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabListLayout.Padding = UDim.new(0, 4)
    tabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local pageHolder = Instance.new("Frame")
    pageHolder.Name = "PageHolder"
    pageHolder.Parent = main
    pageHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    pageHolder.BackgroundTransparency = 1.000
    pageHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
    pageHolder.BorderSizePixel = 0
    pageHolder.Position = UDim2.new(0, 161, 0, 50)
    pageHolder.Size = UDim2.new(1, -159.0, 1, -60.0)
    pageHolder.ClipsDescendants = true

    ----------------------------------------------------------------
    -- Resize handle
    ----------------------------------------------------------------
    local resizeBtn = Instance.new("TextButton")
    resizeBtn.AnchorPoint = Vector2.zero
    resizeBtn.Position = UDim2.new(1, 0, 1, 0)
    resizeBtn.Size = UDim2.fromOffset(22, 22)
    resizeBtn.BackgroundTransparency = 1
    resizeBtn.Text = ""
    resizeBtn.ZIndex = 50
    resizeBtn.Parent = main

    local resizeStartSize, resizeStartPointer, resizeStartPos

    local function isPress(input)
        return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
    end
    local function endResize()
        if not resizeStartSize then
            return
        end
        resizeStartSize = nil
        local abs = main.AbsoluteSize
        pcall(writefile, Library.SizeFile, math.floor(abs.X) .. "," .. math.floor(abs.Y))
    end

    Track(resizeBtn.InputBegan:Connect(function(input)
        if isPress(input) then
            resizeStartSize, resizeStartPointer, resizeStartPos = main.AbsoluteSize, input.Position, main.Position
            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    endResize()
                    conn:Disconnect()
                end
            end)
        end
    end))
    Track(UserInputService.InputChanged:Connect(function(input)
        if resizeStartSize and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            if input.UserInputType == Enum.UserInputType.MouseMovement and not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                return endResize()
            end
            local delta = Vector2.new(input.Position.X - resizeStartPointer.X, input.Position.Y - resizeStartPointer.Y)
            local newW, newH = math.max(420, resizeStartSize.X + delta.X), math.max(260, resizeStartSize.Y + delta.Y)
            main.Size = UDim2.fromOffset(newW, newH)
            main.Position = UDim2.new(
                resizeStartPos.X.Scale, resizeStartPos.X.Offset + (newW - resizeStartSize.X) / 2,
                resizeStartPos.Y.Scale, resizeStartPos.Y.Offset + (newH - resizeStartSize.Y) / 2
            )
        end
    end))
    Track(UserInputService.InputEnded:Connect(function(input)
        if isPress(input) then
            endResize()
        end
    end))

    ----------------------------------------------------------------
    -- Collapse / expand tab list
    ----------------------------------------------------------------
    local expandedWidth, collapsedWidth = tabWidth or 160, 48
    local expanded = false
    local layoutFns = {}
    local layoutTween = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    local function applyProps(inst, props, instant)
        if instant then
            for k, v in pairs(props) do
                inst[k] = v
            end
        else
            Tween(inst, layoutTween, props)
        end
    end

    local menuButton = Instance.new("Frame")
    menuButton.Name = "MenuButton"
    menuButton.Parent = tabList
    menuButton.LayoutOrder = -2.0
    BindAccent(menuButton, "BackgroundColor3", "deep")
    menuButton.BackgroundTransparency = 1
    menuButton.BorderSizePixel = 0
    menuButton.ClipsDescendants = true

    local menuIconData = GetIcon("menu")
    local menuIcon = Instance.new("ImageLabel")
    menuIcon.Parent = menuButton
    menuIcon.AnchorPoint = Vector2.new(0, 0.5)
    menuIcon.BackgroundTransparency = 1
    menuIcon.BorderSizePixel = 0
    menuIcon.Size = UDim2.fromOffset(16, 16)
    menuIcon.Image = menuIconData.id
    menuIcon.ImageRectOffset = menuIconData.imageRectOffset
    menuIcon.ImageRectSize = menuIconData.imageRectSize
    BindAccent(menuIcon, "ImageColor3")
    menuIcon.ScaleType = Enum.ScaleType.Fit

    local menuText = Instance.new("TextLabel")
    menuText.Parent = menuButton
    menuText.AnchorPoint = Vector2.new(0, 0.5)
    menuText.BackgroundTransparency = 1
    menuText.BorderSizePixel = 0
    menuText.Position = UDim2.new(0, 30, 0.5, 0)
    menuText.Size = UDim2.new(0, 200, 0, 20)
    menuText.Font = Enum.Font.GothamMedium
    menuText.Text = "Collapse"
    BindAccent(menuText, "TextColor3")
    menuText.TextSize = 13
    menuText.TextXAlignment = Enum.TextXAlignment.Left
    menuText.TextTransparency = 1

    local menuHit = Instance.new("TextButton")
    menuHit.Parent = menuButton
    menuHit.Text = ""
    menuHit.ZIndex = 2
    menuHit.BackgroundTransparency = 1
    menuHit.BorderSizePixel = 0
    menuHit.Size = UDim2.fromScale(1, 1)
    Track(menuHit.MouseEnter:Connect(function()
        Tween(menuButton, TweenInfo.new(0.1), { BackgroundTransparency = 0.8 })
    end))
    Track(menuHit.MouseLeave:Connect(function()
        Tween(menuButton, TweenInfo.new(0.1), { BackgroundTransparency = 1 })
    end))
    table.insert(layoutFns, function(isExpanded, instant)
        applyProps(menuButton, { Size = isExpanded and UDim2.new(1, -4.0, 0, 35) or UDim2.fromOffset(35, 35) }, instant)
        applyProps(menuIcon, { Position = UDim2.new(0, isExpanded and 7 or 10, 0.5, 0) }, instant)
        applyProps(menuText, { TextTransparency = isExpanded and 0 or 1 }, instant)
    end)

    local menuDivider = Instance.new("Frame")
    menuDivider.Name = "MenuDivider"
    menuDivider.Parent = tabList
    menuDivider.LayoutOrder = -1.0
    menuDivider.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    menuDivider.BackgroundTransparency = 0.5
    menuDivider.BorderSizePixel = 0
    table.insert(layoutFns, function(isExpanded, instant)
        applyProps(menuDivider, { Size = isExpanded and UDim2.new(1, -12.0, 0, 1) or UDim2.fromOffset(28, 1) }, instant)
    end)

    local function setExpanded(isExpanded, instant)
        expanded = isExpanded
        local width = isExpanded and expandedWidth or collapsedWidth
        applyProps(tabListFrame, { Size = UDim2.new(0, width, 1, -50.0) }, instant)
        applyProps(pageHolder, {
            Position = UDim2.new(0, width + 1, 0, 50),
            Size = UDim2.new(1, -(width - 1), 1, -60.0),
        }, instant)
        for _, fn in ipairs(layoutFns) do
            fn(isExpanded, instant)
        end
    end

    Track(menuHit.MouseButton1Click:Connect(function()
        setExpanded(not expanded)
    end))
    setExpanded(true, true)

    ----------------------------------------------------------------
    -- Tabs + search
    ----------------------------------------------------------------
    local tabs = {}

    local function scoreFeature(feature, query)
        local lower = feature:lower()
        local score = 0
        if lower == query then
            return 100
        end
        local words = {}
        for word in query:gmatch("%S+") do
            table.insert(words, word)
        end
        if #words > 1 then
            for _, word in ipairs(words) do
                if not lower:find(word, 1, true) then
                    return 0
                end
                score = score + 1
            end
            if lower:find(query, 1, true) then
                score = score + 3
            end
            if lower == query then
                return 100
            end
            score = score - (#lower / 20)
            return score
        end

        local pos = lower:find(query, 1, true)
        if not pos then
            return 0
        end
        score = score + 1
        if pos == 1 then
            score = score + 4
        end
        for word in lower:gmatch("%S+") do
            if word:sub(1, #query) == query then
                score = score + 3
                break
            end
            if word == query then
                score = score + 5
                break
            end
        end
        score = score - (#lower / 20)
        return score
    end

    local function runSearch(query)
        query = query:lower()
        local best = 0
        local bestIndex = nil
        for index, tab in pairs(tabs) do
            if index == Library._SettingsTabIndex or index == Library._ThemeTabIndex then
                continue
            end
            local total = 0
            for _, feature in pairs(tab.Features) do
                total = total + scoreFeature(feature, query)
            end
            tab.Frame.Visible = total > 0
            if total > best then
                best = total
                bestIndex = index
            end
        end
        if bestIndex then
            window:SelectTab(bestIndex)
        end
    end

    Track(searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local text = searchBox.Text
        if text ~= "" then
            runSearch(text)
        else
            for index, tab in pairs(tabs) do
                if index == Library._SettingsTabIndex or index == Library._ThemeTabIndex then
                    continue
                end
                tab.Frame.Visible = true
            end
        end
    end))

    function window:CreateTab(tabName, iconName)
        local rawName = tabName
        if tabName == "#!SETTINGS" then
            tabName = "Settings"
        elseif tabName == "#!THEME" then
            tabName = "Theme"
        end

        local button = Instance.new("Frame")
        local bar = Instance.new("Frame")
        local label = Instance.new("TextLabel")
        local icon = Instance.new("ImageLabel")
        local iconData = GetIcon(iconName)
        local page = Instance.new("Frame")
        local header = Instance.new("Frame")
        local headerText = Instance.new("TextLabel")
        local columnLeft = Instance.new("ScrollingFrame")
        local columnRight = Instance.new("ScrollingFrame")
        local layoutLeft = Instance.new("UIListLayout")
        local layoutRight = Instance.new("UIListLayout")
        local currentColumn = columnLeft

        page.Name = "Page"
        setthreadidentity(8)

        local storage = Library.TabStorage or Instance.new("ScreenGui")
        Library.TabStorage = storage
        page.Parent = nil
        page.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        page.BackgroundTransparency = 1.000
        page.BorderColor3 = Color3.fromRGB(0, 0, 0)
        page.BorderSizePixel = 0
        page.Position = UDim2.new(0, 0, 0, -30.0)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.Visible = false

        header.Parent = page
        header.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        header.BackgroundTransparency = 0.750
        header.BorderColor3 = Color3.fromRGB(0, 0, 0)
        header.BorderSizePixel = 0
        header.Size = UDim2.new(1, -1.0, 0, 28)
        header.Position = UDim2.fromOffset(-1.0, 0)

        headerText.Parent = header
        headerText.AnchorPoint = Vector2.new(0, 0.5)
        headerText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        headerText.BackgroundTransparency = 1.000
        headerText.BorderColor3 = Color3.fromRGB(0, 0, 0)
        headerText.BorderSizePixel = 0
        headerText.Position = UDim2.new(0, 8, 0.5, 0)
        headerText.Size = UDim2.new(1, 0, 1, 0)
        headerText.Font = Enum.Font.GothamMedium
        headerText.Text = tabName .. " <font color=\"rgb(144,144,144)\"> | </font>0 elements"
        BindAccent(headerText, "TextColor3")
        headerText.TextSize = 12.000
        headerText.RichText = true
        headerText.TextXAlignment = Enum.TextXAlignment.Left

        for _, column in ipairs({ columnLeft, columnRight }) do
            column.Parent = page
            column.Active = true
            column.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            column.BackgroundTransparency = 1.000
            column.BorderColor3 = Color3.fromRGB(0, 0, 0)
            column.BorderSizePixel = 0
            column.ScrollBarThickness = 0
            column.CanvasSize = UDim2.new(0, 0, 0, 0)
            column.AutomaticCanvasSize = Enum.AutomaticSize.Y
            column.ScrollingDirection = Enum.ScrollingDirection.Y
            column.ClipsDescendants = true
            GetSmoothScroll().Enable(column, 4, 0.9)
        end

        columnLeft.Position = UDim2.new(0, 0, 0, 28)
        Make("UIPadding", { PaddingLeft = UDim.new(0, 6) }, columnLeft)
        Make("UIPadding", { PaddingLeft = UDim.new(0, 1) }, columnRight)

        if Single() then
            columnLeft.Size = UDim2.new(1, 0, 1, -28.0)
            columnRight.Visible = false
        else
            columnLeft.Size = UDim2.new(0.5, -4.0, 1, -28.0)
            columnRight.Position = UDim2.new(0.5, 4, 0, 28)
            columnRight.Size = UDim2.new(0.5, -4.0, 1, -28.0)
        end

        for _, pair in ipairs({ { layoutLeft, columnLeft }, { layoutRight, columnRight } }) do
            local layout, column = pair[1], pair[2]
            layout.Parent = column
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            if Single() then
                layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
            end
            layout.Padding = UDim.new(0, 3)
        end

        -- tab button
        button.Name = "TabButton"
        button.Parent = tabList
        BindAccent(button, "BackgroundColor3", "deep")
        button.BackgroundTransparency = 1.000
        button.BorderColor3 = Color3.fromRGB(0, 0, 0)
        button.BorderSizePixel = 0
        button.Size = UDim2.new(1, -4.0, 0, 35)

        bar.Parent = button
        BindAccent(bar, "BackgroundColor3")
        bar.BorderColor3 = Color3.fromRGB(0, 0, 0)
        bar.BorderSizePixel = 0
        bar.AnchorPoint = Vector2.new(0, 0)
        bar.Position = UDim2.new(0, 0, 0, 0)
        bar.Size = UDim2.new(0, 1, 0, 0)

        label.Parent = button
        label.AnchorPoint = Vector2.new(0, 0.5)
        label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        label.BackgroundTransparency = 1.000
        label.BorderColor3 = Color3.fromRGB(0, 0, 0)
        label.BorderSizePixel = 0
        label.Position = UDim2.new(0, 30, 0.5, 0)
        label.Size = UDim2.new(0, 200, 0, 20)
        label.Font = Enum.Font.GothamMedium
        label.Text = tabName
        label.TextColor3 = Color3.fromRGB(161, 161, 161)
        label.TextSize = 12.000
        label.TextXAlignment = Enum.TextXAlignment.Left

        icon.Parent = button
        icon.AnchorPoint = Vector2.new(0, 0.5)
        icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        icon.BackgroundTransparency = 1.000
        icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
        icon.BorderSizePixel = 0
        icon.Position = UDim2.new(0, 7, 0.5, 0)
        icon.Size = UDim2.new(0, 16, 0, 16)
        icon.Image = iconData.id
        icon.ImageColor3 = Color3.fromRGB(161, 161, 161)
        icon.ImageRectOffset = iconData.imageRectOffset
        icon.ImageRectSize = iconData.imageRectSize
        icon.ScaleType = Enum.ScaleType.Fit
        button.ClipsDescendants = true

        local function tabLayout(isExpanded, instant)
            applyProps(button, { Size = isExpanded and UDim2.new(1, -4.0, 0, 35) or UDim2.new(0, 36, 0, 35) }, instant)
            applyProps(icon, { Position = UDim2.new(0, isExpanded and 7 or 10, 0.5, 0) }, instant)
            applyProps(label, { TextTransparency = isExpanded and 0 or 1 }, instant)
        end
        table.insert(layoutFns, tabLayout)
        tabLayout(expanded, true)

        local colorTween = TweenInfo.new(0.1, Enum.EasingStyle.Linear)
        local barTween = nil
        local pageTween = nil

        local function setBarAnchor(anchorY)
            bar.AnchorPoint = Vector2.new(0, anchorY)
            bar.Position = UDim2.new(0, bar.Position.X.Offset, anchorY, bar.Position.Y.Offset)
        end

        local function deselectDirectional(downwards, onDone)
            if pageTween then
                pageTween:Cancel()
                pageTween = nil
            end
            page.Position = UDim2.new(0, 0, 0, -10.0)
            page.Visible = false
            page.Parent = storage
            Tween(button, colorTween, { BackgroundTransparency = 1 })
            Tween(label, colorTween, { TextColor3 = Color3.fromRGB(161, 161, 161) })
            Tween(icon, colorTween, { ImageColor3 = Color3.fromRGB(161, 161, 161) })
            setBarAnchor(downwards and 1 or 0)

            if barTween then
                barTween:Cancel()
            end
            barTween = TweenService:Create(bar, colorTween, { Size = UDim2.new(0, 1, 0, 0) })
            if onDone then
                Track(barTween.Completed:Connect(onDone))
            end
            barTween:Play()
        end

        local function selectDirectional(downwards)
            page.Parent = pageHolder
            RunService.RenderStepped:Wait()
            page.Visible = true
            pageTween = Tween(page, TweenInfo.new(0.2), { Position = UDim2.fromOffset(0, 0) })
            Tween(button, colorTween, { BackgroundTransparency = 0.65 })
            Tween(label, colorTween, { TextColor3 = GetAccentColor() })
            Tween(icon, colorTween, { ImageColor3 = GetAccentColor() })
            setBarAnchor(downwards and 0 or 1)

            if barTween then
                barTween:Cancel()
            end
            bar.Size = UDim2.new(0, 1, 0, 0)
            barTween = Tween(bar, colorTween, { Size = UDim2.new(0, 1, 1, 0) })
        end

        local tabData = {
            IsSelected = false,
            Frame = button,
            Deselect = function()
                deselectDirectional(true)
            end,
            Select = function()
                selectDirectional(true)
            end,
            DeselectDirectional = deselectDirectional,
            SelectDirectional = selectDirectional,
            Index = #tabs + 1,
            Features = {},
            NumSections = 0,
            AutoIndex = 0,
            NumElements = 0,
        }
        tabs[#tabs + 1] = tabData

        Bind(function()
            if tabData.IsSelected then
                label.TextColor3 = GetAccentColor()
                icon.ImageColor3 = GetAccentColor()
            end
        end)

        if rawName == "#!SETTINGS" then
            button.Visible = false
            Library._SettingsTabIndex = #tabs
        elseif rawName == "#!THEME" then
            button.Visible = false
            Library._ThemeTabIndex = #tabs
        end

        local tabHit = Instance.new("TextButton")
        tabHit.Parent = button
        tabHit.Text = ""
        tabHit.ZIndex = 2
        tabHit.BackgroundTransparency = 1
        tabHit.BorderSizePixel = 0
        tabHit.Size = UDim2.fromScale(1, 1)

        local function selectThis()
            if tabData.IsSelected then
                return
            end
            PlaySound("select")

            local downwards = true
            local previous = nil
            for _, other in pairs(tabs) do
                if other.IsSelected then
                    downwards = tabData.Index > other.Index
                    previous = other
                    break
                end
            end
            for _, other in pairs(tabs) do
                other.IsSelected = false
            end
            tabData.IsSelected = true

            if previous then
                previous.DeselectDirectional(downwards, function()
                    if tabData.IsSelected then
                        selectDirectional(downwards)
                    end
                end)
            else
                selectDirectional(downwards)
            end
        end

        Track(tabHit.MouseEnter:Connect(function()
            tabData.IsHover = true
            if not tabData.IsSelected then
                Tween(button, colorTween, { BackgroundTransparency = 0.8 })
            end
        end))
        Track(tabHit.MouseLeave:Connect(function()
            tabData.IsHover = false
            if not tabData.IsSelected then
                Tween(button, colorTween, { BackgroundTransparency = 1 })
            end
        end))
        Track(tabHit.MouseButton1Down:Connect(function()
            if not tabData.IsSelected then
                Tween(button, colorTween, { BackgroundTransparency = 0.7 })
            end
        end))
        Track(tabHit.MouseButton1Up:Connect(function()
            if not tabData.IsSelected then
                if tabData.IsHover then
                    Tween(button, colorTween, { BackgroundTransparency = 0.8 })
                else
                    Tween(button, colorTween, { BackgroundTransparency = 1 })
                end
            end
        end))
        Track(tabHit.MouseButton1Click:Connect(selectThis))

        ----------------------------------------------------------------
        -- Tab API
        ----------------------------------------------------------------
        local tab = {}
        local hiddenFolder = Instance.new("Folder")
        hiddenFolder.Name = "HiddenElements"
        tabData.CurrentSection = nil
        tabData.CurrentSectionIndex = 0
        tabData.SectionGroups = {}
        tabData.Columns = {
            Left = { ScrollingFrame = columnLeft, Count = 0, LastSection = nil },
            Right = { ScrollingFrame = columnRight, Count = 0, LastSection = nil },
        }

        local function registerElement(frame, noCount)
            tabData.NumElements = tabData.NumElements + (noCount and 0 or 1)
            headerText.Text = tabName .. (" <font color=\"rgb(144,144,144)\"> | </font>%d elements"):format(tabData.NumElements)

            if frame.Name ~= "Frame" then
                local stroke = Instance.new("UIStroke")
                stroke.Color = Color3.fromRGB(255, 255, 255)
                stroke.Transparency = 0.93
                stroke.Thickness = 1
                stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                stroke.Parent = frame
            end

            local section = tabData.CurrentSection
            if section then
                local group = tabData.SectionGroups[section]
                frame.LayoutOrder = tabData.CurrentSectionIndex * 1000 + #group + 1
                table.insert(group, frame)
            else
                frame.LayoutOrder = tabData.CurrentSectionIndex * 1000
            end
        end

        if IsMobile then
            AddCustomScrollbar(columnLeft)
        end

        ------------------------------------------------------------
        -- Section
        ------------------------------------------------------------
        function tab:CreateSection(sectionName, side)
            tabData.NumSections = tabData.NumSections + 1

            local sideKey
            if Single() then
                sideKey = "Left"
            elseif side then
                sideKey = side
            else
                tabData.AutoIndex = tabData.AutoIndex + 1
                sideKey = (tabData.AutoIndex % 2 == 1) and "Left" or "Right"
            end

            local column = tabData.Columns[sideKey] or tabData.Columns.Left

            if column.Count > 0 and column.LastSection then
                local prevGroup = tabData.SectionGroups[column.LastSection]
                local spacer = Instance.new("Frame")
                spacer.Parent = column.ScrollingFrame
                spacer.BackgroundTransparency = 1
                spacer.Size = UDim2.new(0, 0, 0, 10)
                spacer.LayoutOrder = column.LastSection.LayoutOrder + #prevGroup + 1
                table.insert(prevGroup, spacer)
            end

            currentColumn = column.ScrollingFrame

            local sectionFrame = Instance.new("Frame")
            local sectionButton = Instance.new("TextButton")

            sectionFrame.Name = "Section"
            sectionFrame.Parent = currentColumn
            sectionFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            sectionFrame.BackgroundTransparency = 1.000
            sectionFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
            sectionFrame.BorderSizePixel = 0
            sectionFrame.Size = UDim2.new(1, 0, 0, 28)

            sectionButton.Parent = sectionFrame
            sectionButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            sectionButton.BackgroundTransparency = 1.000
            sectionButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
            sectionButton.BorderSizePixel = 0
            sectionButton.Position = UDim2.new(0, 30, 0, 0)
            sectionButton.Size = UDim2.new(1, -40.0, 1, 0)
            sectionButton.Font = Enum.Font.GothamMedium
            sectionButton.Text = sectionName
            sectionButton.TextColor3 = Color3.fromRGB(199, 199, 199)
            sectionButton.TextSize = 12.000
            sectionButton.TextXAlignment = Enum.TextXAlignment.Left
            sectionButton.ZIndex = 2

            local sectionShadow = sectionButton:Clone()
            sectionShadow.ZIndex = 1
            sectionShadow.TextColor3 = Color3.fromRGB(0, 0, 0)
            sectionShadow.Position = sectionButton.Position + UDim2.fromOffset(1, 1)
            sectionShadow.Parent = sectionButton.Parent
            sectionShadow.Active = false

            local chevronData = GetIcon("chevron-down")
            local chevron = Instance.new("ImageLabel")
            chevron.Name = "Chevron"
            chevron.Parent = sectionFrame
            chevron.BackgroundTransparency = 1
            chevron.AnchorPoint = Vector2.new(0, 0.5)
            chevron.Position = UDim2.new(0, 10, 0.5, 0)
            chevron.Size = UDim2.fromOffset(14, 14)
            chevron.ImageColor3 = Color3.fromRGB(199, 199, 199)
            chevron.ZIndex = 2
            chevron.Image = chevronData.id
            chevron.ImageRectSize = chevronData.imageRectSize
            chevron.ImageRectOffset = chevronData.imageRectOffset

            tabData.CurrentSectionIndex = tabData.CurrentSectionIndex + 1
            sectionFrame.LayoutOrder = tabData.CurrentSectionIndex * 1000
            tabData.CurrentSection = sectionFrame
            tabData.SectionGroups[sectionFrame] = {}
            column.Count = column.Count + 1
            column.LastSection = sectionFrame

            local collapsed = false
            local busy = false
            local sectionTween = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            local columnFrame = column.ScrollingFrame

            Track(sectionButton.MouseButton1Click:Connect(function()
                if busy then
                    return
                end
                busy = true
                PlaySound("click")
                collapsed = not collapsed
                Tween(chevron, sectionTween, { Rotation = collapsed and -90.0 or 0 })

                local group = tabData.SectionGroups[sectionFrame]
                local count = #group
                local total = 0.2 + (count > 0 and (count - 1) * 0.06 or 0)

                if collapsed then
                    local sizes, autosizes, clips, positions = {}, {}, {}, {}

                    for i = 1, count do
                        local el = group[i]
                        sizes[el] = el.Size
                        autosizes[el] = el.AutomaticSize
                        if el.AutomaticSize ~= Enum.AutomaticSize.None then
                            el.AutomaticSize = Enum.AutomaticSize.None
                        end
                        clips[el] = el.ClipsDescendants
                        positions[el] = el.Position
                        el.ClipsDescendants = true
                    end

                    for i = count, 1, -1.0 do
                        local el = group[i]
                        local delay = (count - i) * 0.06
                        local height = sizes[el].Y.Offset

                        task.delay(delay, function()
                            Tween(el, sectionTween, { Size = UDim2.new(el.Size.X.Scale, el.Size.X.Offset, 0, 0) })
                            for k = i + 1, count do
                                local other = group[k]
                                local pos = other.Position
                                Tween(other, sectionTween, {
                                    Position = UDim2.new(pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset - height),
                                })
                            end
                        end)
                    end

                    task.delay(total, function()
                        for i = 1, count do
                            local el = group[i]
                            el.Parent = hiddenFolder
                            el.Position = positions[el]
                            el:SetAttribute("__restoreX", sizes[el].X.Scale)
                            el:SetAttribute("__restoreXO", sizes[el].X.Offset)
                            el:SetAttribute("__restoreY", sizes[el].Y.Scale)
                            el:SetAttribute("__restoreYO", sizes[el].Y.Offset)
                            el:SetAttribute("__clips", clips[el])
                            el:SetAttribute("__autosize", autosizes[el].Name)
                        end
                        busy = false
                    end)
                else
                    for i = 1, count do
                        local el = group[i]
                        local rx = el:GetAttribute("__restoreX") or 0
                        local rxo = el:GetAttribute("__restoreXO") or 0
                        el.Size = UDim2.new(rx, rxo, 0, 0)
                        el.Parent = columnFrame
                    end

                    wait()

                    local positions = {}
                    for i = 1, count do
                        positions[group[i]] = group[i].Position
                    end
                    for i = 1, count do
                        local el = group[i]
                        el.Position = positions[el]
                    end

                    for i = 1, count do
                        local el = group[i]
                        local rx = el:GetAttribute("__restoreX") or 0
                        local rxo = el:GetAttribute("__restoreXO") or 0
                        local ry = el:GetAttribute("__restoreY") or 0
                        local ryo = el:GetAttribute("__restoreYO") or 0
                        local delay = (i - 1) * 0.06

                        task.delay(delay, function()
                            Tween(el, sectionTween, { Size = UDim2.new(rx, rxo, ry, ryo) })
                            for k = i + 1, count do
                                local other = group[k]
                                local pos = other.Position
                                Tween(other, sectionTween, {
                                    Position = UDim2.new(pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset + ryo),
                                })
                            end
                        end)
                    end

                    task.delay(total, function()
                        for i = 1, count do
                            local el = group[i]
                            local clip = el:GetAttribute("__clips")
                            el.ClipsDescendants = (clip == nil) and false or clip
                            local auto = el:GetAttribute("__autosize")
                            if auto then
                                el.AutomaticSize = Enum.AutomaticSize[auto]
                            end
                        end
                        busy = false
                    end)
                end
            end))

            return {
                Set = function(_, text)
                    sectionButton.Text = text
                    sectionShadow.Text = text
                end,
            }
        end

        ------------------------------------------------------------
        -- Label / Paragraph
        ------------------------------------------------------------
        function tab:CreateLabel(text)
            local frame = Instance.new("Frame")
            local textLabel = Instance.new("TextLabel")
            local corner = Instance.new("UICorner")
            local padding = Instance.new("UIPadding")

            frame.Name = "Toggle"
            frame.Parent = currentColumn
            registerElement(frame)
            frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            frame.BackgroundTransparency = 0.450
            frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
            frame.BorderSizePixel = 0
            frame.AutomaticSize = Enum.AutomaticSize.Y
            frame.Size = ElementSize(28)

            padding.Parent = frame
            padding.PaddingTop = UDim.new(0, 6)
            padding.PaddingBottom = UDim.new(0, 6)

            textLabel.Parent = frame
            textLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            textLabel.BackgroundTransparency = 1.000
            textLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
            textLabel.BorderSizePixel = 0
            textLabel.Position = UDim2.new(0, 10, 0, 0)
            textLabel.Size = UDim2.new(1, -20.0, 0, 0)
            textLabel.AutomaticSize = Enum.AutomaticSize.Y
            textLabel.TextWrapped = true
            textLabel.Font = Enum.Font.GothamMedium
            textLabel.Text = text
            textLabel.TextColor3 = Color3.fromRGB(145, 145, 145)
            textLabel.TextSize = 12.000
            textLabel.TextXAlignment = Enum.TextXAlignment.Left
            textLabel.RichText = true

            corner.CornerRadius = UDim.new(0, 5)
            corner.Parent = frame

            return {
                Set = function(_, newText)
                    textLabel.Text = newText
                end,
            }
        end

        function tab:CreateParagraph(opts)
            return tab:CreateLabel(opts.Content)
        end

        ------------------------------------------------------------
        -- Toggle
        ------------------------------------------------------------
        function tab:CreateToggle(opts)
            local flag = opts.Flag or opts.Name
            local value = opts.CurrentValue
            local name = opts.Name
            local callback = opts.Callback or function() end
            local textMode = opts.TextMode

            window.Flags[flag] = { CurrentValue = value, __ISTOGGLE = true }
            table.insert(tabData.Features, name)

            local frame = Instance.new("Frame")
            local nameButton = Instance.new("TextButton")
            local corner = Instance.new("UICorner")
            local switch, switchCorner, ball, ballCorner, stateLabel

            frame.Name = "Toggle"
            frame.Parent = currentColumn
            registerElement(frame)
            frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            frame.BackgroundTransparency = 0.450
            frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
            frame.BorderSizePixel = 0
            frame.Size = ElementSize(28)

            nameButton.Parent = frame
            nameButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            nameButton.BackgroundTransparency = 1.000
            nameButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
            nameButton.BorderSizePixel = 0
            nameButton.Position = UDim2.new(0, 10, 0, 0)
            nameButton.Size = UDim2.new(0.5, 0, 0, 28)
            nameButton.Font = Enum.Font.GothamMedium
            nameButton.Text = name
            nameButton.TextColor3 = Color3.fromRGB(199, 199, 199)
            nameButton.TextSize = 12.000
            nameButton.TextXAlignment = Enum.TextXAlignment.Left
            nameButton.RichText = true
            attachTooltip(nameButton, opts)
            corner.CornerRadius = UDim.new(0, 5)
            corner.Parent = frame

            local hit = Instance.new("TextButton")
            hit.Text = ""
            hit.ZIndex = 2
            hit.BackgroundTransparency = 1
            hit.BorderSizePixel = 0

            local render

            if textMode then
                stateLabel = Instance.new("TextLabel")
                stateLabel.Name = "StateLabel"
                stateLabel.Parent = frame
                stateLabel.AnchorPoint = Vector2.new(1, 0.5)
                stateLabel.BackgroundTransparency = 1
                stateLabel.Position = UDim2.new(1, -10.0, 0.5, 0)
                stateLabel.Size = UDim2.new(0, 40, 0, 20)
                stateLabel.Font = Enum.Font.GothamMedium
                stateLabel.TextSize = 13
                stateLabel.TextXAlignment = Enum.TextXAlignment.Right
                hit.Parent = stateLabel
                hit.Size = UDim2.fromScale(1, 1)
                render = function()
                    if value then
                        stateLabel.Text = "ON"
                        stateLabel.TextColor3 = Color3.fromRGB(85, 170, 85)
                    else
                        stateLabel.Text = "OFF"
                        stateLabel.TextColor3 = Color3.fromRGB(170, 60, 60)
                    end
                    stateLabel.TextSize = 18
                    Tween(stateLabel, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { TextSize = 13 })
                end
            else
                switch = Instance.new("Frame")
                switchCorner = Instance.new("UICorner")
                ball = Instance.new("Frame")
                ballCorner = Instance.new("UICorner")

                switch.Name = "Switch"
                switch.Parent = frame
                switch.AnchorPoint = Vector2.new(1, 0)
                switch.BackgroundColor3 = Color3.fromRGB(67, 67, 67)
                switch.BackgroundTransparency = 0.700
                switch.BorderColor3 = Color3.fromRGB(0, 0, 0)
                switch.BorderSizePixel = 0
                switch.Position = UDim2.new(1, -4.0, 0, 4)
                switch.Size = UDim2.new(0, 48, 0, 20)
                switchCorner.CornerRadius = UDim.new(1, 0)
                switchCorner.Parent = switch

                ball.Name = "ball"
                ball.Parent = switch
                ball.AnchorPoint = Vector2.new(0, 0.5)
                ball.BackgroundColor3 = Color3.fromRGB(62, 62, 62)
                ball.BorderColor3 = Color3.fromRGB(0, 0, 0)
                ball.BorderSizePixel = 0
                ball.Position = UDim2.new(0, 2, 0.5, 0)
                ball.Size = UDim2.new(0, 16, 0, 16)
                ballCorner.CornerRadius = UDim.new(1, 0)
                ballCorner.Parent = ball

                hit.Parent = switch
                hit.Size = UDim2.fromScale(1, 1)

                local switchTween = TweenInfo.new(0.3, Enum.EasingStyle.Sine)
                render = function()
                    task.spawn(function()
                        setthreadidentity(8)
                        if value then
                            Tween(switch, switchTween, { BackgroundColor3 = GetAccentColor("dark") })
                            Tween(ball, switchTween, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) })
                            Tween(ball, switchTween, { Position = UDim2.new(0, 30, 0.5, 0) })
                        else
                            Tween(switch, switchTween, { BackgroundColor3 = Color3.fromRGB(67, 67, 67) })
                            Tween(ball, switchTween, { BackgroundColor3 = Color3.fromRGB(62, 62, 62) })
                            Tween(ball, switchTween, { Position = UDim2.new(0, 2, 0.5, 0) })
                        end
                    end)
                end
                Bind(function()
                    if value then
                        switch.BackgroundColor3 = GetAccentColor("dark")
                    end
                end)
                Track(hit.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        Tween(ball, TweenInfo.new(0.15, Enum.EasingStyle.Sine), { Size = UDim2.new(0, 16, 0, 10) })
                    end
                end))
                Track(hit.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        Tween(ball, TweenInfo.new(0.15, Enum.EasingStyle.Sine), { Size = UDim2.new(0, 16, 0, 16) })
                    end
                end))
            end

            local flagObj = window.Flags[flag]

            function flagObj:Set(newValue, silent)
                value = newValue
                window.Flags[flag].CurrentValue = value
                render()
                if not silent then
                    PlaySound("switch")
                end
                task.spawn(function()
                    Library:SafeCallback(callback, name, "toggle", value, silent)
                end)
            end

            local initial
            if value then
                initial = (value ~= nil and value ~= false) and true or nil
            end
            if saved[flag] and saved[flag].CurrentValue ~= nil and not opts.NoSave then
                initial = saved[flag].CurrentValue
            end
            if initial ~= nil then
                flagObj:Set(initial, true)
            end

            Track(hit.MouseButton1Click:Connect(function()
                flagObj:Set(not value)
            end))

            if not value and textMode then
                render()
            end

            return flagObj
        end

        ------------------------------------------------------------
        -- Button
        ------------------------------------------------------------
        function tab:CreateButton(opts)
            local name = opts.Name
            local callback = opts.Callback or function() end

            table.insert(tabData.Features, name)

            local frame = Instance.new("Frame")
            local nameLabel = Instance.new("TextLabel")
            local corner = Instance.new("UICorner")
            local clickIcon = Instance.new("ImageLabel")
            local infoIcon = Instance.new("ImageLabel")

            frame.Name = "Button"
            frame.Parent = currentColumn
            registerElement(frame)
            frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            frame.BackgroundTransparency = 0.450
            frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
            frame.BorderSizePixel = 0
            frame.Size = ElementSize(32)
            frame.ClipsDescendants = true

            nameLabel.Parent = frame
            nameLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.BackgroundTransparency = 1.000
            nameLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
            nameLabel.BorderSizePixel = 0
            nameLabel.Position = UDim2.new(0, 10, 0, 0)
            nameLabel.Size = UDim2.new(0.5, 0, 0, 32)
            nameLabel.Font = Enum.Font.GothamMedium
            nameLabel.Text = name
            nameLabel.TextColor3 = Color3.fromRGB(199, 199, 199)
            nameLabel.TextSize = 12.000
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            attachTooltip(infoIcon, opts)

            if opts.ToolTip then
                local infoData = GetIcon("info")
                infoIcon.Parent = frame
                infoIcon.AnchorPoint = Vector2.new(1, 0)
                infoIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                infoIcon.BackgroundTransparency = 1.000
                infoIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
                infoIcon.BorderSizePixel = 0
                infoIcon.Position = UDim2.new(1, -30.0, 0, 6)
                infoIcon.Size = UDim2.new(0, 20, 0, 20)
                infoIcon.Image = infoData.id
                infoIcon.ImageRectOffset = infoData.imageRectOffset
                infoIcon.ImageRectSize = infoData.imageRectSize
            end

            corner.CornerRadius = UDim.new(0, 5)
            corner.Parent = frame

            local pointerData = GetIcon("mouse-pointer-2")
            clickIcon.Parent = frame
            clickIcon.AnchorPoint = Vector2.new(1, 0)
            clickIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            clickIcon.BackgroundTransparency = 1.000
            clickIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
            clickIcon.BorderSizePixel = 0
            clickIcon.Position = UDim2.new(1, -4.0, 0, 6)
            clickIcon.Size = UDim2.new(0, 20, 0, 20)
            clickIcon.Image = pointerData.id
            clickIcon.ImageRectOffset = pointerData.imageRectOffset
            clickIcon.ImageRectSize = pointerData.imageRectSize

            local hit = Instance.new("TextButton")
            hit.Parent = frame
            hit.Text = ""
            hit.BackgroundTransparency = 1
            hit.Size = UDim2.new(1, -(opts.ToolTip and 57 or 31), 1, 0)
            Track(hit.MouseButton1Click:Connect(function()
                task.spawn(function()
                    Library:SafeCallback(callback, name, "button")
                end)
            end))
            Track(hit.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local abs = frame.AbsolutePosition
                    Ripple(frame, input.Position.X - abs.X, input.Position.Y - abs.Y)
                end
            end))
        end

        ------------------------------------------------------------
        -- Slider
        ------------------------------------------------------------
        function tab:CreateSlider(opts)
            local name = opts.Name
            local range = opts.Range
            local min = range[1]
            local max = range[2]
            local value = opts.CurrentValue
            local flag = opts.Flag or name

            window.Flags[flag] = { CurrentValue = value }

            local callback = opts.Callback or function() end
            local suffix = opts.Suffix or ""
            local increment = opts.Increment
            local formatType = opts.FormatType

            table.insert(tabData.Features, name)

            local frame = Instance.new("Frame")
            local nameLabel = Instance.new("TextLabel")
            local valueBox = Instance.new("TextBox")
            local corner = Instance.new("UICorner")
            local bar = Instance.new("Frame")
            local barCorner = Instance.new("UICorner")
            local ball = Instance.new("Frame")
            local ballCorner = Instance.new("UICorner")
            local fill = Instance.new("Frame")
            local fillCorner = Instance.new("UICorner")

            frame.Name = "Slider"
            frame.Parent = currentColumn
            registerElement(frame)
            frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            frame.BackgroundTransparency = 0.450
            frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
            frame.BorderSizePixel = 0
            frame.Size = ElementSize(32)

            nameLabel.Name = "SliderName"
            nameLabel.Parent = frame
            nameLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.BackgroundTransparency = 1.000
            nameLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
            nameLabel.BorderSizePixel = 0
            nameLabel.Position = UDim2.new(0, 10, 0, 0)
            nameLabel.Size = UDim2.new(0.5, -40.0, 0, 32)
            nameLabel.Font = Enum.Font.GothamMedium
            nameLabel.Text = name
            nameLabel.TextColor3 = Color3.fromRGB(199, 199, 199)
            nameLabel.TextSize = 12.000
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.RichText = true
            attachTooltip(nameLabel, opts)

            valueBox.Name = "ValueBox"
            valueBox.Parent = frame
            valueBox.BackgroundTransparency = 1
            valueBox.BorderSizePixel = 0
            valueBox.AutomaticSize = Enum.AutomaticSize.X
            valueBox.Size = UDim2.new(0, 24, 0, 32)
            valueBox.Font = Enum.Font.GothamMedium
            valueBox.TextSize = 12.000
            valueBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            valueBox.TextXAlignment = Enum.TextXAlignment.Left
            valueBox.ClearTextOnFocus = false
            valueBox.RichText = true
            valueBox.Text = ""

            corner.CornerRadius = UDim.new(0, 5)
            corner.Parent = frame

            bar.Name = "Bar"
            bar.Parent = frame
            bar.AnchorPoint = Vector2.new(1, 0)
            bar.BackgroundColor3 = Color3.fromRGB(109, 109, 129)
            bar.BackgroundTransparency = 0.500
            bar.BorderColor3 = Color3.fromRGB(0, 0, 0)
            bar.BorderSizePixel = 0
            bar.Position = UDim2.new(1, -16.0, 0, 13)
            bar.Size = UDim2.new(0, 120, 0, 6)
            barCorner.CornerRadius = UDim.new(1, 0)
            barCorner.Parent = bar

            ball.Name = "Ball"
            ball.Parent = bar
            ball.AnchorPoint = Vector2.new(0.5, 0.5)
            ball.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ball.BorderColor3 = Color3.fromRGB(0, 0, 0)
            ball.BorderSizePixel = 0
            ball.Position = UDim2.new(0.5, 0, 0.5, 0)
            ball.Size = UDim2.new(0, 16, 0, 16)
            ball.ZIndex = 2
            ballCorner.CornerRadius = UDim.new(1, 0)
            ballCorner.Parent = ball

            fill.Name = "Fill"
            fill.Parent = bar
            BindAccent(fill, "BackgroundColor3", "mid")
            fill.BorderColor3 = Color3.fromRGB(0, 0, 0)
            fill.BorderSizePixel = 0
            fill.Size = UDim2.new(0.5, 0, 1, 0)
            fillCorner.CornerRadius = UDim.new(1, 0)
            fillCorner.Parent = fill

            local barDrag = Instance.new("UIDragDetector")
            barDrag.Parent = bar
            barDrag.ResponseStyle = Enum.UIDragDetectorResponseStyle.CustomOffset
            barDrag:Clone().Parent = ball

            local barNormal = UDim2.new(0, 120, 0, 6)
            local barHover = UDim2.new(0, 120, 0, 9)
            local ballNormal = UDim2.new(0, 16, 0, 16)
            local ballHover = UDim2.new(0, 20, 0, 20)
            local hoverTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local allowNegative = min < 0

            local function placeValueBox()
                valueBox.Position = UDim2.new(0, 10 + nameLabel.TextBounds.X + 4, 0, 0)
            end
            placeValueBox()
            Track(nameLabel:GetPropertyChangedSignal("TextBounds"):Connect(placeValueBox))

            local function toFraction(v)
                return (v - min) / (max - min)
            end
            local function fromFraction(f)
                local raw = f * (max - min) + min
                local rounded = math.round(raw / increment) * increment
                local digits = math.max(0, math.ceil(-math.log10(increment)))
                return tonumber(string.format("%." .. digits .. "f", math.clamp(rounded, min, max)))
            end
            local function formatValue(v)
                return "<font color=\"" .. RGBString(GetAccentColor("mid")) .. "\">" .. (formatType == "time" and Library.TruncateTime(v) or v) .. "<font color=\"rgb(141, 141, 141)\">" .. suffix .. "</font></font>"
            end
            local function updateText()
                valueBox.RichText = true
                valueBox.Text = formatValue(window.Flags[flag].CurrentValue)
            end
            local function updateVisual(fraction, animate)
                if not valueBox:IsFocused() then
                    updateText()
                end
                local fillSize = UDim2.new(fraction, 0, 1, 0)
                local ballPos = UDim2.new(fraction, 0, 0.5, 0)
                if animate then
                    Tween(fill, hoverTween, { Size = fillSize })
                    Tween(ball, hoverTween, { Position = ballPos })
                else
                    fill.Size = fillSize
                    ball.Position = ballPos
                end
            end

            if saved[flag] then
                value = saved[flag].CurrentValue
                window.Flags[flag] = { CurrentValue = value }
                task.spawn(function()
                    Library:SafeCallback(callback, name, "slider", value)
                end)
            end

            updateVisual(toFraction(value), false)

            local dragging = false

            local function setValue(v, strict)
                if strict then
                    v = math.clamp(v, min, max)
                else
                    v = fromFraction(toFraction(math.clamp(v, min, max)))
                end
                if v ~= window.Flags[flag].CurrentValue then
                    window.Flags[flag].CurrentValue = v
                    updateVisual(toFraction(v), true)
                    PlaySound("tick", { Volume = 0.1 })
                    Library:SafeCallback(callback, name, "slider", v)
                end
            end
            local function setFromPointer(x)
                local left = bar.AbsolutePosition.X
                local width = bar.AbsoluteSize.X
                local frac = math.clamp((x - left) / width, 0, 1)
                setValue(fromFraction(frac))
            end

            Track(valueBox.Focused:Connect(function()
                valueBox.RichText = false
                valueBox.Text = tostring(window.Flags[flag].CurrentValue)
            end))
            Track(valueBox:GetPropertyChangedSignal("Text"):Connect(function()
                if not valueBox:IsFocused() or valueBox.RichText then
                    return
                end
                local text = valueBox.Text
                local negative = allowNegative and text:sub(1, 1) == "-"
                text = text:gsub("[^%d%.]", "")
                do
                    local dot = text:find(".", 1, true)
                    if dot then
                        text = text:sub(1, dot) .. (text:sub(dot + 1):gsub("%.", ""))
                    end
                end
                if negative then
                    text = "-" .. text
                end
                if text ~= valueBox.Text then
                    valueBox.Text = text
                end
            end))
            Track(valueBox.FocusLost:Connect(function()
                local n = tonumber(valueBox.Text)
                if n then
                    setValue(n, not opts.StrictIncrement)
                end
                updateText()
            end))

            local barHovered = false
            local ballHovered = false

            Track(bar.MouseEnter:Connect(function()
                barHovered = true
                Tween(bar, hoverTween, { Size = barHover })
                Tween(ball, hoverTween, { Size = ballHover })
            end))
            Track(bar.MouseLeave:Connect(function()
                barHovered = false
                if not ballHovered and not dragging then
                    Tween(bar, hoverTween, { Size = barNormal })
                    Tween(ball, hoverTween, { Size = ballNormal })
                end
            end))
            Track(ball.MouseEnter:Connect(function()
                ballHovered = true
                Tween(bar, hoverTween, { Size = barHover })
                Tween(ball, hoverTween, { Size = ballHover })
            end))
            Track(ball.MouseLeave:Connect(function()
                ballHovered = false
                if not barHovered and not dragging then
                    Tween(bar, hoverTween, { Size = barNormal })
                    Tween(ball, hoverTween, { Size = ballNormal })
                end
            end))
            Track(ball.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    setFromPointer(input.Position.X)
                end
            end))
            Track(bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    setFromPointer(input.Position.X)
                end
            end))
            Track(UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    setFromPointer(input.Position.X)
                end
            end))
            Track(UserInputService.InputEnded:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                    dragging = false
                    if input.UserInputType == Enum.UserInputType.Touch or (not barHovered and not ballHovered) then
                        Tween(bar, hoverTween, { Size = barNormal })
                        Tween(ball, hoverTween, { Size = ballNormal })
                    end
                end
            end))
            Bind(function()
                if not valueBox:IsFocused() then
                    updateText()
                end
            end)

            return {
                Set = function(_, v)
                    setValue(v, true)
                end,
            }
        end

        ------------------------------------------------------------
        -- Dropdown
        ------------------------------------------------------------
        function tab:CreateDropdown(opts)
            local name = opts.Name
            local flag = opts.Flag or name
            local current = DeepCopy(opts.CurrentOption or {})
            local options = DeepCopy(opts.Options or {})
            local multiple = opts.MultipleOptions
            local searchable = opts.Searchable == true
            local searchHeight = searchable and 28 or 0
            local callback = opts.Callback or function() end

            table.insert(tabData.Features, name)

            local frame = Instance.new("Frame")
            local nameLabel = Instance.new("TextLabel")
            local corner = Instance.new("UICorner")
            local arrow = Instance.new("ImageLabel")
            local list = Instance.new("ScrollingFrame")
            local listLayout = Instance.new("UIListLayout")

            frame.Name = "Dropdown"
            frame.Parent = currentColumn
            registerElement(frame)
            frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            frame.BackgroundTransparency = 0.450
            frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
            frame.BorderSizePixel = 0
            frame.ClipsDescendants = true
            frame.Size = ElementSize(32)

            nameLabel.Name = "SliderName"
            nameLabel.Parent = frame
            nameLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.BackgroundTransparency = 1.000
            nameLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
            nameLabel.BorderSizePixel = 0
            nameLabel.Position = UDim2.new(0, 10, 0, 0)
            nameLabel.Size = UDim2.new(0.5, 0, 0, 32)
            nameLabel.Font = Enum.Font.GothamMedium
            nameLabel.TextColor3 = Color3.fromRGB(199, 199, 199)
            nameLabel.TextSize = 12.000
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.RichText = true
            attachTooltip(nameLabel, opts)

            corner.CornerRadius = UDim.new(0, 5)
            corner.Parent = frame

            arrow.Parent = frame
            arrow.AnchorPoint = Vector2.new(1, 0)
            arrow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            arrow.BackgroundTransparency = 1.000
            arrow.BorderColor3 = Color3.fromRGB(0, 0, 0)
            arrow.BorderSizePixel = 0
            arrow.Position = UDim2.new(1, -4.0, 0, 6)
            arrow.Size = UDim2.new(0, 20, 0, 20)
            arrow.Image = "rbxassetid://130996747355335"

            list.Parent = frame
            list.Active = true
            list.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            list.BackgroundTransparency = 1.000
            list.BorderColor3 = Color3.fromRGB(0, 0, 0)
            list.BorderSizePixel = 0
            list.Position = UDim2.new(0, 10, 0, 32 + searchHeight)
            list.Size = UDim2.new(1, -20.0, 1, -(42 + searchHeight))
            list.ScrollBarThickness = 8
            list.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
            list.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
            list.AutomaticCanvasSize = Enum.AutomaticSize.Y
            list.CanvasSize = UDim2.new(0, 0, 0, 0)
            list.Visible = false

            listLayout.Parent = list
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0, 4)
            listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

            local function collect(selected)
                local out = {}
                for key, v in pairs(selected) do
                    if v == true then
                        table.insert(out, key)
                    end
                end
                return out
            end

            local function deepEqual(a, b)
                if type(a) ~= type(b) then
                    return false
                end
                if type(a) ~= "table" then
                    return a == b
                end
                for k, v in pairs(a) do
                    if not deepEqual(v, b[k]) then
                        return false
                    end
                end
                for k in pairs(b) do
                    if a[k] == nil then
                        return false
                    end
                end
                return true
            end

            if (saved[flag] or {}).CurrentOption and not deepEqual(saved[flag].CurrentOption, options) then
                current = saved[flag].CurrentOption
                task.spawn(function()
                    Library:SafeCallback(callback, name, "dropdown", current, true)
                end)
            end

            local selected = {}
            for _, opt in pairs(options) do
                selected[opt] = false
            end
            for _, opt in pairs(current) do
                selected[opt] = true
            end

            window.Flags[flag] = { CurrentOption = collect(selected) }

            local headerHit = Instance.new("TextButton")
            headerHit.Parent = frame
            headerHit.Text = ""
            headerHit.ZIndex = 2
            headerHit.BackgroundTransparency = 1
            headerHit.BorderSizePixel = 0
            headerHit.Size = UDim2.new(1, 0, 0, 32)

            local fade
            if #options > 3 then
                fade = AddBottomFade(list)
                fade.Visible = false
            end

            local searchFrameD, searchBoxD, searchStroke

            local function filterOptions()
                if not searchBoxD then
                    return
                end
                local words = {}
                for word in searchBoxD.Text:lower():gmatch("%S+") do
                    words[#words + 1] = word
                end
                for _, child in pairs(list:GetChildren()) do
                    if child.Name == "Option" then
                        local text = child.OName.Text:lower()
                        local match = true
                        for _, word in ipairs(words) do
                            if not text:find(word, 1, true) then
                                match = false
                                break
                            end
                        end
                        child.Visible = match
                    end
                end
                list.CanvasPosition = Vector2.new(0, 0)
            end

            if searchable then
                searchFrameD = Instance.new("Frame")
                searchFrameD.Name = "SearchFrame"
                searchFrameD.Parent = frame
                searchFrameD.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                searchFrameD.BackgroundTransparency = 0.5
                searchFrameD.BorderSizePixel = 0
                searchFrameD.Position = UDim2.new(0, 10, 0, 36)
                searchFrameD.Size = UDim2.new(1, -20.0, 0, 22)
                searchFrameD.ZIndex = 2
                searchFrameD.Visible = false

                local sCorner = Instance.new("UICorner")
                sCorner.CornerRadius = UDim.new(0, 5)
                sCorner.Parent = searchFrameD

                searchStroke = Instance.new("UIStroke")
                searchStroke.Color = Color3.fromRGB(70, 70, 70)
                searchStroke.Thickness = 1
                searchStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                searchStroke.Parent = searchFrameD

                searchBoxD = Instance.new("TextBox")
                searchBoxD.Name = "SearchBox"
                searchBoxD.Parent = searchFrameD
                searchBoxD.BackgroundTransparency = 1
                searchBoxD.BorderSizePixel = 0
                searchBoxD.Position = UDim2.new(0, 8, 0, 0)
                searchBoxD.Size = UDim2.new(1, -16.0, 1, 0)
                searchBoxD.ZIndex = 3
                searchBoxD.ClearTextOnFocus = false
                searchBoxD.Font = Enum.Font.GothamMedium
                searchBoxD.PlaceholderText = "Search..."
                searchBoxD.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
                searchBoxD.Text = ""
                searchBoxD.TextColor3 = Color3.fromRGB(199, 199, 199)
                searchBoxD.TextSize = 12.000
                searchBoxD.TextXAlignment = Enum.TextXAlignment.Left
                Track(searchBoxD:GetPropertyChangedSignal("Text"):Connect(filterOptions))
                Track(searchBoxD.Focused:Connect(function()
                    Tween(searchStroke, TweenInfo.new(0.15), { Color = GetAccentColor("mid") })
                end))
                Track(searchBoxD.FocusLost:Connect(function()
                    Tween(searchStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(70, 70, 70) })
                end))
                Bind(function()
                    if searchBoxD:IsFocused() then
                        searchStroke.Color = GetAccentColor("mid")
                    end
                end)
            end

            local open = false
            Track(headerHit.MouseButton1Click:Connect(function()
                open = not open
                PlaySound("click")
                if fade then
                    fade.Visible = open
                end
                list.Visible = open
                if searchFrameD then
                    searchFrameD.Visible = open
                end
                if open then
                    local height = math.clamp(38 + (#options * (28 + listLayout.Padding.Offset)), 0, 38 + (3 * (28 + listLayout.Padding.Offset))) + searchHeight
                    Tween(frame, TweenInfo.new(0.3), { Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, frame.Size.Y.Scale, height) })
                else
                    if searchBoxD then
                        searchBoxD:ReleaseFocus()
                        searchBoxD.Text = ""
                    end
                    list.CanvasPosition = Vector2.new(0, 0)
                    Tween(frame, TweenInfo.new(0.3), { Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, frame.Size.Y.Scale, 32) })
                end
            end))

            local dropdown = { __DropdownOptions = {} }

            local function summarize(sel)
                local names = {}
                for key, v in pairs(sel) do
                    if v == true then
                        table.insert(names, tostring(key))
                    end
                end
                return #names == 1 and names[1] or ((#names == 0 and "no" or #names) .. " options")
            end

            function dropdown:SetTitle(newTitle)
                name = newTitle
                nameLabel.Text = name .. " <font color=\"rgb(100, 100, 100)\">" .. summarize(selected) .. "</font>"
            end
            dropdown:SetTitle(name)

            local function buildOptions(newOptions)
                options = newOptions
                table.clear(dropdown.__DropdownOptions)

                for _, child in pairs(list:GetChildren()) do
                    if child.Name == "Option" then
                        child:Destroy()
                    end
                end

                for _, optName in pairs(newOptions) do
                    local optFrame = Instance.new("Frame")
                    local optCorner = Instance.new("UICorner")
                    local optText = Instance.new("TextLabel")
                    local optShadow = Instance.new("TextLabel")

                    optFrame.Name = "Option"
                    optFrame.Parent = list
                    optFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                    optFrame.BackgroundTransparency = 0.800
                    optFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    optFrame.BorderSizePixel = 0
                    optFrame.Size = UDim2.new(1, 0, 0, 28)
                    optFrame.ClipsDescendants = true
                    optCorner.CornerRadius = UDim.new(0, 5)
                    optCorner.Parent = optFrame

                    optText.Name = "OName"
                    optText.Parent = optFrame
                    optText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    optText.BackgroundTransparency = 1.000
                    optText.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    optText.BorderSizePixel = 0
                    optText.Position = UDim2.new(0, 10, 0, 0)
                    optText.Size = UDim2.new(1, -20.0, 1, 0)
                    optText.ZIndex = 2
                    optText.Font = Enum.Font.GothamMedium
                    optText.Text = tostring(optName)
                    optText.TextColor3 = Color3.fromRGB(199, 199, 199)
                    optText.TextSize = 12.000
                    optText.TextXAlignment = Enum.TextXAlignment.Left

                    optShadow.Name = "ONameShadow"
                    optShadow.Parent = optFrame
                    optShadow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    optShadow.BackgroundTransparency = 1.000
                    optShadow.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    optShadow.BorderSizePixel = 0
                    optShadow.Position = UDim2.new(0, 11, 0, 1)
                    optShadow.Size = UDim2.new(1, -20.0, 1, 0)
                    optShadow.Font = Enum.Font.GothamMedium
                    optShadow.Text = tostring(optName)
                    optShadow.TextColor3 = Color3.fromRGB(0, 0, 0)
                    optShadow.TextSize = 12.000
                    optShadow.TextXAlignment = Enum.TextXAlignment.Left

                    local optHit = Instance.new("TextButton")
                    optHit.Parent = optFrame
                    optHit.Text = ""
                    optHit.ZIndex = 2
                    optHit.BackgroundTransparency = 1
                    optHit.BorderSizePixel = 0
                    optHit.Size = UDim2.fromScale(1, 1)

                    table.insert(dropdown.__DropdownOptions, {
                        Title = setmetatable({}, {
                            __newindex = function(_, key, v)
                                if key == "Text" then
                                    optText.Text = v
                                    optShadow.Text = v
                                end
                            end,
                        }),
                    })

                    local colorTween = TweenInfo.new(0.1, Enum.EasingStyle.Linear)

                    Track(optHit.MouseButton1Click:Connect(function()
                        if selected[optName] == true and not multiple then
                            return
                        end

                        selected[optName] = not selected[optName]

                        if not multiple then
                            for other in pairs(selected) do
                                if other ~= optName then
                                    selected[other] = false
                                end
                            end
                            for _, child in pairs(list:GetChildren()) do
                                if child.Name == "Option" then
                                    Tween(child, colorTween, { BackgroundColor3 = Color3.fromRGB(100, 100, 100) })
                                    Tween(child.OName, colorTween, { TextColor3 = Color3.fromRGB(199, 199, 199) })
                                end
                            end
                        end

                        if selected[optName] then
                            Tween(optFrame, colorTween, { BackgroundColor3 = GetAccentColor("mid") })
                            Tween(optText, colorTween, { TextColor3 = GetAccentColor("mid") })
                        else
                            Tween(optFrame, colorTween, { BackgroundColor3 = Color3.fromRGB(100, 100, 100) })
                            Tween(optText, colorTween, { TextColor3 = Color3.fromRGB(199, 199, 199) })
                        end

                        dropdown:SetTitle(name)
                        window.Flags[flag] = { CurrentOption = collect(selected) }
                        task.spawn(function()
                            Library:SafeCallback(callback, name, "dropdown", collect(selected))
                        end)
                    end))
                    Track(optHit.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            local abs = optFrame.AbsolutePosition
                            Ripple(optFrame, input.Position.X - abs.X, input.Position.Y - abs.Y)
                        end
                    end))
                    Bind(function()
                        if selected[optName] then
                            optFrame.BackgroundColor3 = GetAccentColor("mid")
                            optText.TextColor3 = GetAccentColor("mid")
                        end
                    end)
                end

                filterOptions()
            end

            buildOptions(options)

            function dropdown:Refresh(newOptions)
                buildOptions(newOptions)
            end

            return dropdown
        end

        ------------------------------------------------------------
        -- Keybind
        ------------------------------------------------------------
        function tab:CreateKeybind(opts)
            local currentKey = opts.CurrentKeybind
            local name = opts.Name
            local flag = opts.Flag
            local callback = opts.Callback or function() end

            table.insert(tabData.Features, name)

            if flag then
                local savedFlag = saved[flag]
                if savedFlag and savedFlag.CurrentValue ~= nil and not opts.NoSave then
                    local savedKey = savedFlag.CurrentValue
                    if savedKey == "" then
                        currentKey = nil
                    elseif Enum.KeyCode:FromName(savedKey) then
                        currentKey = savedKey
                    end
                end
                window.Flags[flag] = { CurrentValue = currentKey or "" }
            end

            local frame = Instance.new("Frame")
            local nameLabel = Instance.new("TextLabel")
            local corner = Instance.new("UICorner")
            local keyBox = Instance.new("Frame")
            local keyCorner = Instance.new("UICorner")
            local keyButton = Instance.new("TextButton")
            local keyIcon = Instance.new("ImageLabel")

            frame.Name = "Keybind"
            frame.Parent = currentColumn
            registerElement(frame)
            frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            frame.BackgroundTransparency = 0.450
            frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
            frame.BorderSizePixel = 0
            frame.ClipsDescendants = true
            frame.Size = ElementSize(32)

            nameLabel.Name = "KeybindName"
            nameLabel.Parent = frame
            nameLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.BackgroundTransparency = 1.000
            nameLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
            nameLabel.BorderSizePixel = 0
            nameLabel.Position = UDim2.new(0, 10, 0, 0)
            nameLabel.Size = UDim2.new(0.5, 0, 0, 32)
            nameLabel.Font = Enum.Font.GothamMedium
            nameLabel.Text = name
            nameLabel.TextColor3 = Color3.fromRGB(199, 199, 199)
            nameLabel.TextSize = 12.000
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            attachTooltip(nameLabel, opts)

            corner.CornerRadius = UDim.new(0, 5)
            corner.Parent = frame

            keyBox.Parent = frame
            keyBox.AnchorPoint = Vector2.new(1, 0)
            keyBox.BackgroundColor3 = Color3.fromRGB(53, 53, 53)
            keyBox.BackgroundTransparency = 0.700
            keyBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
            keyBox.BorderSizePixel = 0
            keyBox.Position = UDim2.new(1, -4.0, 0, 4)
            keyBox.Size = UDim2.new(0, 30, 0, 20)
            keyBox.ClipsDescendants = true
            keyCorner.CornerRadius = UDim.new(0, 5)
            keyCorner.Parent = keyBox

            keyButton.Parent = keyBox
            keyButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            keyButton.BackgroundTransparency = 1.000
            keyButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
            keyButton.BorderSizePixel = 0
            keyButton.Size = UDim2.new(1, 0, 1, 0)
            keyButton.Font = Enum.Font.GothamMedium
            keyButton.Text = currentKey or ""
            keyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            keyButton.TextSize = 14.000
            keyButton.ClipsDescendants = true

            keyIcon.Parent = keyBox
            keyIcon.AnchorPoint = Vector2.new(0.5, 0)
            keyIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            keyIcon.BackgroundTransparency = 1.000
            keyIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
            keyIcon.BorderSizePixel = 0
            keyIcon.Position = UDim2.new(0.5, 0, 0, 2)
            keyIcon.Size = UDim2.new(0, 16, 0, 16)
            keyIcon.Image = "rbxassetid://121142147574111"
            keyIcon.Visible = false
            if currentKey == nil then
                keyIcon.Visible = true
            end

            local entry = { KeyCode = currentKey, Callback = callback, Pressable = true }
            table.insert(window.Keybinds, entry)

            local function saveFlag()
                if flag then
                    window.Flags[flag] = { CurrentValue = entry.KeyCode or "" }
                end
            end

            local busy = false
            local listening = false
            local blinkThread = nil
            local quad = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local back = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

            local function startListening()
                if blinkThread then
                    task.cancel(blinkThread)
                end
                Tween(keyBox, quad, { BackgroundColor3 = GetAccentColor("dark2"), BackgroundTransparency = 0.3 })
                Tween(keyButton, quad, { TextColor3 = GetAccentColor("mid") })
                blinkThread = task.spawn(function()
                    while listening do
                        Tween(keyBox, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = 0.1 })
                        wait(0.5)
                        Tween(keyBox, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = 0.4 })
                        wait(0.5)
                    end
                end)
            end
            local function confirmKey()
                if blinkThread then
                    task.cancel(blinkThread)
                    blinkThread = nil
                end
                Tween(keyBox, quad, { BackgroundColor3 = Color3.fromRGB(60, 180, 80), BackgroundTransparency = 0.2 })
                Tween(keyButton, quad, { TextColor3 = Color3.fromRGB(255, 255, 255) })
                wait()
                local width = math.max(30, keyButton.TextBounds.X + 16)
                local grow = UDim2.new(0, width + 8, 0, 24)
                local settle = UDim2.new(0, width, 0, 20)
                Tween(keyBox, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = grow })
                task.delay(0.1, function()
                    Tween(keyBox, back, { Size = settle })
                end)
                task.delay(0.4, function()
                    Tween(keyBox, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { BackgroundColor3 = Color3.fromRGB(53, 53, 53), BackgroundTransparency = 0.700 })
                end)
            end
            local function cancelListening()
                if blinkThread then
                    task.cancel(blinkThread)
                    blinkThread = nil
                end
                Tween(keyBox, quad, { BackgroundColor3 = Color3.fromRGB(53, 53, 53), BackgroundTransparency = 0.700 })
                Tween(keyButton, quad, { TextColor3 = Color3.fromRGB(255, 255, 255) })
            end

            Track(keyButton.MouseButton1Click:Connect(function()
                if busy then
                    return
                end
                busy = true
                entry.Pressable = false
                keyIcon.Visible = false
                keyButton.Text = "..."
                listening = true
                startListening()
                wait(0.1)
                busy = false
            end))
            Track(UserInputService.InputBegan:Connect(function(input, processed)
                RunService.Heartbeat:Wait()

                if Unloaded then
                    return
                end
                if processed then
                    return
                end

                if listening and input.KeyCode.Name ~= "Unknown" then
                    local previous = entry.KeyCode
                    entry.KeyCode = input.KeyCode.Name
                    listening = false

                    if previous == entry.KeyCode then
                        entry.KeyCode = nil
                        keyIcon.Visible = true
                        keyButton.Text = ""
                        cancelListening()
                        saveFlag()
                        entry.Pressable = true
                        return
                    end

                    keyButton.Text = entry.KeyCode
                    saveFlag()
                    confirmKey()
                end

                entry.Pressable = true
            end))

            local function updateWidth()
                local width = math.max(30, keyButton.TextBounds.X + 16)
                Tween(keyBox, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0, width, 0, 20) })
            end
            Track(RunService.RenderStepped:Connect(updateWidth))
        end

        ------------------------------------------------------------
        -- Input
        ------------------------------------------------------------
        function tab:CreateInput(opts)
            local name = opts.Name
            local flag = opts.Flag or name
            local value = opts.CurrentValue
            local placeholder = opts.PlaceholderText
            local callback = opts.Callback or function() end

            table.insert(tabData.Features, name)
            window.Flags[flag] = { CurrentValue = value }

            local frame = Instance.new("Frame")
            local nameLabel = Instance.new("TextLabel")
            local corner = Instance.new("UICorner")
            local box = Instance.new("Frame")
            local boxCorner = Instance.new("UICorner")
            local unusedLabel = Instance.new("TextLabel")
            local icon = Instance.new("ImageLabel")
            local textBox = Instance.new("TextBox")

            frame.Name = "Input"
            frame.Parent = currentColumn
            registerElement(frame)
            frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            frame.BackgroundTransparency = 0.450
            frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
            frame.BorderSizePixel = 0
            frame.ClipsDescendants = true
            frame.Size = ElementSize(32)

            nameLabel.Name = "KeybindName"
            nameLabel.Parent = frame
            nameLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.BackgroundTransparency = 1.000
            nameLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
            nameLabel.BorderSizePixel = 0
            nameLabel.Position = UDim2.new(0, 10, 0, 0)
            nameLabel.Size = UDim2.new(0.5, 0, 0, 32)
            nameLabel.Font = Enum.Font.GothamMedium
            nameLabel.Text = name
            nameLabel.TextColor3 = Color3.fromRGB(199, 199, 199)
            nameLabel.TextSize = 12.000
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            attachTooltip(nameLabel, opts)

            corner.CornerRadius = UDim.new(0, 5)
            corner.Parent = frame

            box.Parent = frame
            box.AnchorPoint = Vector2.new(1, 0)
            box.BackgroundColor3 = Color3.fromRGB(53, 53, 53)
            box.BackgroundTransparency = 0.700
            box.BorderColor3 = Color3.fromRGB(0, 0, 0)
            box.BorderSizePixel = 0
            box.ClipsDescendants = true
            box.Position = UDim2.new(1, -4.0, 0, 4)
            box.Size = UDim2.new(0, 0, 0, 20)
            boxCorner.CornerRadius = UDim.new(0, 5)
            boxCorner.Parent = box

            unusedLabel.Parent = box
            unusedLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            unusedLabel.BackgroundTransparency = 1.000
            unusedLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
            unusedLabel.BorderSizePixel = 0
            unusedLabel.Size = UDim2.new(1, 0, 1, 0)
            unusedLabel.Font = Enum.Font.GothamMedium
            unusedLabel.Text = ""
            unusedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            unusedLabel.TextSize = 14.000

            icon.Parent = box
            icon.AnchorPoint = Vector2.new(1, 0)
            icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            icon.BackgroundTransparency = 1.000
            icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
            icon.BorderSizePixel = 0
            icon.Position = UDim2.new(1, -8.0, 0, 2)
            icon.Size = UDim2.new(0, 16, 0, 16)
            icon.Image = "rbxassetid://76137750753739"
            BindAccent(icon, "ImageColor3", "light")

            textBox.Parent = box
            textBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            textBox.BackgroundTransparency = 1.000
            textBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
            textBox.BorderSizePixel = 0
            textBox.ClipsDescendants = true
            textBox.Position = UDim2.new(0, 7, 0, 0)
            textBox.Size = UDim2.new(1, -40.0, 1, 0)
            textBox.Font = Enum.Font.GothamMedium
            textBox.PlaceholderColor3 = Color3.fromRGB(127, 127, 127)
            textBox.PlaceholderText = placeholder or "Input Text"
            textBox.Text = value or ""
            BindAccent(textBox, "TextColor3", "light")
            textBox.TextSize = 12.000
            textBox.TextXAlignment = Enum.TextXAlignment.Left
            textBox.ClearTextOnFocus = opts.ClearTextOnFocus == true

            Track(textBox.FocusLost:Connect(function()
                local text = textBox.Text
                window.Flags[flag] = { CurrentValue = text }
                if opts.RemoveTextAfterFocusLost then
                    textBox.Text = ""
                end
                task.spawn(function()
                    Library:SafeCallback(callback, name, "input", text)
                end)
            end))

            if saved[flag] and not opts.DontSave then
                window.Flags[flag] = saved[flag]
                textBox.Text = tostring(saved[flag].CurrentValue)
                task.spawn(function()
                    Library:SafeCallback(callback, name, "input", textBox.Text, true)
                end)
            end

            Track(RunService.RenderStepped:Connect(function()
                local width = math.max(30, textBox.TextBounds.X + 50)
                Tween(box, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0, math.clamp(width, 0, 160), 0, 20) })
            end))

            return {
                Set = function(_, v)
                    textBox.Text = tostring(v or "")
                    window.Flags[flag] = { CurrentValue = textBox.Text }
                end,
            }
        end

        ------------------------------------------------------------
        -- Color picker
        ------------------------------------------------------------
        function tab:CreateColorPicker(opts)
            local name = opts.Name
            local color = opts.Color
            local flag = opts.Flag or name
            local callback = opts.Callback or function() end

            local function parseColor(str)
                local h, s, v = unpack(str:split("/"))
                return Color3.fromHSV(tonumber(h), tonumber(s), tonumber(v))
            end

            if saved[flag] and saved[flag].Color and not opts.DontSave then
                local ok, parsed = pcall(parseColor, saved[flag].Color)
                if ok then
                    color = parsed
                end
            end

            window.Flags[flag] = { Color = color }
            table.insert(tabData.Features, name)

            local frame = Instance.new("Frame")
            local nameLabel = Instance.new("TextLabel")
            local corner = Instance.new("UICorner")
            local indicatorBg = Instance.new("Frame")
            local indicatorBgCorner = Instance.new("UICorner")
            local indicator = Instance.new("Frame")
            local indicatorCorner = Instance.new("UICorner")
            local hueSlider = Instance.new("Frame")
            local hueGradient = Instance.new("UIGradient")
            local hueCorner = Instance.new("UICorner")
            local base = Instance.new("Frame")
            local baseCorner = Instance.new("UICorner")
            local baseGradient = Instance.new("UIGradient")
            local overlay = Instance.new("Frame")
            local overlayCorner = Instance.new("UICorner")
            local overlayGradient = Instance.new("UIGradient")
            local hexFrame = Instance.new("Frame")
            local hexCorner = Instance.new("UICorner")
            local hexBox = Instance.new("TextBox")
            local hexLabel = Instance.new("TextLabel")
            local rgbFrame = Instance.new("Frame")
            local rgbCorner = Instance.new("UICorner")
            local rgbBox = Instance.new("TextBox")
            local rgbLabel = Instance.new("TextLabel")
            local hsvFrame = Instance.new("Frame")
            local hsvCorner = Instance.new("UICorner")
            local hsvBox = Instance.new("TextBox")
            local hsvLabel = Instance.new("TextLabel")

            frame.Name = "Colorpicker"
            frame.Parent = currentColumn
            registerElement(frame)
            frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            frame.BackgroundTransparency = 0.450
            frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
            frame.BorderSizePixel = 0
            frame.ClipsDescendants = true
            frame.Size = ElementSize(32)

            nameLabel.Name = "SliderName"
            nameLabel.Parent = frame
            nameLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.BackgroundTransparency = 1.000
            nameLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
            nameLabel.BorderSizePixel = 0
            nameLabel.Position = UDim2.new(0, 10, 0, 0)
            nameLabel.Size = UDim2.new(0.5, 0, 0, 32)
            nameLabel.Font = Enum.Font.GothamMedium
            nameLabel.Text = name
            nameLabel.TextColor3 = Color3.fromRGB(199, 199, 199)
            nameLabel.TextSize = 12.000
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            attachTooltip(nameLabel, opts)

            corner.CornerRadius = UDim.new(0, 5)
            corner.Parent = frame

            indicatorBg.Name = "ColorIndicatorBackground"
            indicatorBg.Parent = frame
            indicatorBg.AnchorPoint = Vector2.new(1, 0.5)
            indicatorBg.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            indicatorBg.BackgroundTransparency = 0.300
            indicatorBg.BorderColor3 = Color3.fromRGB(0, 0, 0)
            indicatorBg.BorderSizePixel = 0
            indicatorBg.Position = UDim2.new(1, -4.0, 0, 16)
            indicatorBg.Size = UDim2.new(0, 50, 0, 20)
            indicatorBgCorner.CornerRadius = UDim.new(0, 5)
            indicatorBgCorner.Parent = indicatorBg

            indicator.Name = "ColorIndicator"
            indicator.Parent = frame
            indicator.AnchorPoint = Vector2.new(1, 0.5)
            indicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            indicator.BorderColor3 = Color3.fromRGB(0, 0, 0)
            indicator.BorderSizePixel = 0
            indicator.Position = UDim2.new(1, -6.0, 0, 16)
            indicator.Size = UDim2.new(0, 46, 0, 16)
            indicatorCorner.CornerRadius = UDim.new(0, 4)
            indicatorCorner.Parent = indicator

            hueSlider.Name = "ColorSlider"
            hueSlider.Parent = frame
            hueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            hueSlider.BorderColor3 = Color3.fromRGB(27, 42, 53)
            hueSlider.ClipsDescendants = true
            hueSlider.Position = UDim2.new(0, 10, 0, 120)
            hueSlider.Size = UDim2.new(0, 173, 0, 12)
            hueGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.06, Color3.fromRGB(255, 85, 0)),
                ColorSequenceKeypoint.new(0.11, Color3.fromRGB(255, 170, 0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(254, 255, 0)),
                ColorSequenceKeypoint.new(0.22, Color3.fromRGB(169, 255, 0)),
                ColorSequenceKeypoint.new(0.28, Color3.fromRGB(83, 255, 0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 1)),
                ColorSequenceKeypoint.new(0.39, Color3.fromRGB(0, 255, 86)),
                ColorSequenceKeypoint.new(0.45, Color3.fromRGB(0, 255, 171)),
                ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 252, 255)),
                ColorSequenceKeypoint.new(0.56, Color3.fromRGB(0, 167, 255)),
                ColorSequenceKeypoint.new(0.61, Color3.fromRGB(0, 82, 255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(2, 0, 255)),
                ColorSequenceKeypoint.new(0.72, Color3.fromRGB(88, 0, 255)),
                ColorSequenceKeypoint.new(0.78, Color3.fromRGB(173, 0, 255)),
                ColorSequenceKeypoint.new(0.84, Color3.fromRGB(255, 0, 251)),
                ColorSequenceKeypoint.new(0.89, Color3.fromRGB(255, 0, 166)),
                ColorSequenceKeypoint.new(0.95, Color3.fromRGB(255, 0, 80)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
            })
            hueGradient.Parent = hueSlider
            hueCorner.CornerRadius = UDim.new(0, 6)
            hueCorner.Parent = hueSlider

            base.Name = "Base"
            base.Parent = frame
            base.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            base.BorderColor3 = Color3.fromRGB(0, 0, 0)
            base.BorderSizePixel = 0
            base.Position = UDim2.new(0, 10, 0, 33)
            base.Size = UDim2.new(0, 173, 0, 80)
            baseCorner.CornerRadius = UDim.new(0, 6)
            baseCorner.Parent = base

            local hueThumb = Instance.new("Frame")
            local hueThumbCorner = Instance.new("UICorner")
            hueThumb.Name = "HueThumb"
            hueThumb.Parent = hueSlider
            hueThumb.AnchorPoint = Vector2.new(0.5, 0.5)
            hueThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            hueThumb.BorderSizePixel = 0
            hueThumb.Size = UDim2.new(0, 6, 0, 6)
            hueThumb.ZIndex = 10
            hueThumb.ClipsDescendants = false
            hueThumbCorner.CornerRadius = UDim.new(1, 0)
            hueThumbCorner.Parent = hueThumb
            local hueThumbStroke = Instance.new("UIStroke")
            hueThumbStroke.Color = Color3.fromRGB(0, 0, 0)
            hueThumbStroke.Thickness = 1
            hueThumbStroke.Parent = hueThumb

            local colorThumb = Instance.new("Frame")
            local colorThumbCorner = Instance.new("UICorner")
            colorThumb.Name = "ColorThumb"
            colorThumb.Parent = overlay
            colorThumb.AnchorPoint = Vector2.new(0.5, 0.5)
            colorThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            colorThumb.BorderColor3 = Color3.fromRGB(0, 0, 0)
            colorThumb.BorderSizePixel = 0
            colorThumb.Size = UDim2.fromOffset(6, 6)
            colorThumb.ZIndex = 10
            colorThumb.ClipsDescendants = false
            colorThumbCorner.CornerRadius = UDim.new(1, 0)
            colorThumbCorner.Parent = colorThumb
            local colorThumbStroke = Instance.new("UIStroke")
            colorThumbStroke.Color = Color3.fromRGB(0, 0, 0)
            colorThumbStroke.Thickness = 1
            colorThumbStroke.Parent = colorThumb

            local function hueFromX(x)
                local left = hueSlider.AbsolutePosition.X
                local width = hueSlider.AbsoluteSize.X
                return math.clamp((x - left) / width, 0, 1)
            end
            local function svFromPos(x, y)
                local px = overlay.AbsolutePosition.X
                local sx = overlay.AbsoluteSize.X
                local fx = math.clamp((x - px) / sx, 0, 1)
                local py = overlay.AbsolutePosition.Y
                local sy = overlay.AbsoluteSize.Y
                local fy = math.clamp((y - py) / sy, 0, 1)
                return fx, fy
            end
            local function hueSequence(hue)
                return ColorSequence.new({
                    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1.00, Color3.fromHSV(hue, 1, 1)),
                })
            end

            local hue
            local initH, initS, initV = color:ToHSV()

            colorThumb.Position = UDim2.fromScale(1 - initV, 1 - initS)
            baseGradient.Color = hueSequence(initH)
            baseGradient.Rotation = 270
            baseGradient.Parent = base
            hue = initH
            hueThumb.Position = UDim2.fromScale(initH, 0.5)

            local lastHex, lastRgb, lastHsv

            local function apply(x, y, fx, fy, silent)
                if not (fx and fy) then
                    fx, fy = svFromPos(x, y)
                end

                Tween(colorThumb, TweenInfo.new(0.1), { Position = UDim2.fromScale(fx, fy) })

                local newColor = Color3.fromHSV(hue, 1 - fy, 1 - fx)

                indicatorBg.BackgroundColor3 = newColor
                indicator.BackgroundColor3 = newColor

                local h, s, v = newColor:ToHSV()
                hsvBox.Text = string.format("%s, %s, %s", math.floor(h * 360), math.floor(s * 255), math.floor(v * 255))

                local r, g, b = math.floor((newColor.R * 255) + 0.5), math.floor((newColor.G * 255) + 0.5), math.floor((newColor.B * 255) + 0.5)

                rgbBox.Text = string.format("%s, %s, %s", r, g, b)
                hexBox.Text = string.format("#%02x%02x%02x", r, g, b)
                lastHex = hexBox.Text
                lastRgb = rgbBox.Text
                lastHsv = hsvBox.Text
                window.Flags[flag] = { Color = newColor }

                if not silent then
                    task.spawn(function()
                        Library:SafeCallback(callback, name, "colorpicker", newColor)
                    end)
                end
            end

            local draggingHue = false
            local draggingSV = false
            local hueInput
            local svInput

            Track(hueSlider.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingHue = true
                    hueInput = input

                    while draggingHue and wait() do
                        local newHue = hueFromX(hueInput.Position.X)
                        hue = newHue
                        Tween(hueThumb, TweenInfo.new(0.1), { Position = UDim2.fromScale(newHue, 0.5) })
                        baseGradient.Color = hueSequence(newHue)
                        apply(nil, nil, colorThumb.Position.X.Scale, colorThumb.Position.Y.Scale)
                    end
                end
            end))
            Track(hueSlider.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    hueInput = input
                end
            end))
            Track(hueSlider.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingHue = false
                end
            end))

            overlay.Name = "Overlay"
            overlay.Parent = frame
            overlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            overlay.BorderColor3 = Color3.fromRGB(0, 0, 0)
            overlay.BorderSizePixel = 0
            overlay.Position = UDim2.new(0, 10, 0, 33)
            overlay.Size = UDim2.new(0, 173, 0, 80)
            overlayCorner.CornerRadius = UDim.new(0, 6)
            overlayCorner.Parent = overlay
            overlayGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 0, 0)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 0, 0)),
            })
            overlayGradient.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0.00, 1.00),
                NumberSequenceKeypoint.new(1.00, 0.00),
            })
            overlayGradient.Parent = overlay

            Track(overlay.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSV = true
                    svInput = input

                    while draggingSV and wait() do
                        apply(svInput.Position.X, svInput.Position.Y)
                    end
                end
            end))
            Track(overlay.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    svInput = input
                end
            end))
            Track(overlay.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSV = false
                end
            end))

            local function setupValueBox(boxFrame, boxCornerInst, textBox, indicatorLabel, formatName, posY, clearOnFocus)
                boxFrame.Parent = frame
                boxFrame.AnchorPoint = Vector2.new(1, 1)
                boxFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                boxFrame.BackgroundTransparency = 0.500
                boxFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
                boxFrame.BorderSizePixel = 0
                boxFrame.Position = UDim2.new(1, -10.0, 0, posY)
                boxFrame.Size = UDim2.new(0, 100, 0, 26)
                boxCornerInst.Parent = boxFrame

                textBox.Parent = boxFrame
                textBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                textBox.BackgroundTransparency = 1.000
                textBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
                textBox.BorderSizePixel = 0
                textBox.Size = UDim2.new(1, 0, 1, 0)
                textBox.Font = Enum.Font.GothamMedium
                textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                textBox.TextSize = 14.000
                if clearOnFocus == false then
                    textBox.ClearTextOnFocus = false
                end

                indicatorLabel.Name = "FormatIndication"
                indicatorLabel.Parent = boxFrame
                indicatorLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                indicatorLabel.BackgroundTransparency = 1.000
                indicatorLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
                indicatorLabel.BorderSizePixel = 0
                indicatorLabel.Position = UDim2.new(-1.0, -7.0, 0, 0)
                indicatorLabel.Size = UDim2.new(1, 0, 1, 0)
                indicatorLabel.Font = Enum.Font.GothamMedium
                indicatorLabel.Text = formatName
                indicatorLabel.TextColor3 = Color3.fromRGB(141, 141, 141)
                indicatorLabel.TextSize = 14.000
                indicatorLabel.TextWrapped = true
                indicatorLabel.TextXAlignment = Enum.TextXAlignment.Right
            end

            hexFrame.Name = "HexValue"
            hexBox.Name = "HexValueText"
            hexLabel.Name = "FormatIndication"
            setupValueBox(hexFrame, hexCorner, hexBox, hexLabel, "HEX", 130, false)

            rgbFrame.Name = "RgbValue"
            rgbBox.Name = "RgbValueText"
            setupValueBox(rgbFrame, rgbCorner, rgbBox, rgbLabel, "RGB", 100, false)

            hsvFrame.Name = "HsvValue"
            hsvBox.Name = "HsvValueText"
            setupValueBox(hsvFrame, hsvCorner, hsvBox, hsvLabel, "HSV", 70, nil)

            local function moveToColor(newColor)
                local h, s, v = newColor:ToHSV()
                hue = h
                Tween(hueThumb, TweenInfo.new(0.1), { Position = UDim2.fromScale(h, 0.5) })
                baseGradient.Color = hueSequence(h)
                apply(nil, nil, 1 - v, 1 - s)
            end

            Track(hexBox.FocusLost:Connect(function()
                local text = hexBox.Text

                if text:sub(1, 1) == "#" then
                    text = text:sub(2)
                end

                if not text:match("%x+%x+%x+") then
                    hexBox.Text = lastHex
                    return
                end

                local r = tonumber(text:sub(1, 2), 16)
                local g = tonumber(text:sub(3, 4), 16)
                local b = tonumber(text:sub(5, 6), 16)
                if not (r and g and b) then
                    hexBox.Text = lastHex
                    return
                end

                moveToColor(Color3.fromRGB(r, g, b))
            end))

            Track(rgbBox.FocusLost:Connect(function()
                local text = rgbBox.Text:gsub(" ", "")

                if not text:match("%d+,%d+,%d+") then
                    rgbBox.Text = lastRgb
                    return
                end

                local parts = text:split(",")
                local r, g, b = tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3])
                if not (r and g and b) then
                    rgbBox.Text = lastRgb
                    return
                end
                if (r < 0 or r > 255) or (g < 0 or g > 255) or (b < 0 or b > 255) then
                    rgbBox.Text = lastRgb
                    return
                end

                moveToColor(Color3.fromRGB(r, g, b))
            end))

            Track(hsvBox.FocusLost:Connect(function()
                local text = hsvBox.Text:gsub(" ", "")

                if not text:match("%d+,%d+,%d+") then
                    hsvBox.Text = lastHsv
                    return
                end

                local parts = text:split(",")
                local h, s, v = tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3])
                if not (h and s and v) then
                    hsvBox.Text = lastHsv
                    return
                end
                if (h < 0 or h > 360) or (s < 0 or s > 255) or (v < 0 or v > 255) then
                    hsvBox.Text = lastHsv
                    return
                end

                moveToColor(Color3.fromHSV(h / 360, s / 255, v / 255))
            end))

            apply(nil, nil, colorThumb.Position.X.Scale, colorThumb.Position.Y.Scale, true)

            if saved[flag] and saved[flag].Color and not opts.DontSave then
                local loaded = window.Flags[flag].Color
                task.spawn(function()
                    Library:SafeCallback(callback, name, "colorpicker", loaded)
                end)
            end

            -- expand / collapse
            local headerHit = Instance.new("TextButton")
            headerHit.Parent = frame
            headerHit.Text = ""
            headerHit.ZIndex = 2
            headerHit.BackgroundTransparency = 1
            headerHit.BorderSizePixel = 0
            headerHit.Size = UDim2.new(1, 0, 0, 32)

            local expandedPicker = false
            local token = 0
            local sizeTween

            local function frameSize(h)
                return UDim2.new(1, -(Single() and 29 or 10), 0, h)
            end
            local function setPartsVisible(v)
                hexFrame.Visible = v
                rgbFrame.Visible = v
                hsvFrame.Visible = v
                hueSlider.Visible = v
                overlay.Visible = v
                base.Visible = v
            end

            local groups = {
                { Items = { base, overlay }, Delay = 0, Offset = Vector2.new(0, 14) },
                { Items = { hueSlider }, Delay = 0.06, Offset = Vector2.new(0, 14) },
                { Items = { hsvFrame }, Delay = 0.10, Offset = Vector2.new(24, 0) },
                { Items = { rgbFrame }, Delay = 0.15, Offset = Vector2.new(24, 0) },
                { Items = { hexFrame }, Delay = 0.20, Offset = Vector2.new(24, 0) },
            }

            local function collectFade(root)
                local entries = {}
                local function consider(obj)
                    if obj:IsA("GuiObject") then
                        table.insert(entries, { obj, "BackgroundTransparency", obj.BackgroundTransparency })
                        if obj:IsA("TextLabel") or obj:IsA("TextBox") then
                            table.insert(entries, { obj, "TextTransparency", obj.TextTransparency })
                        end
                    elseif obj:IsA("UIStroke") then
                        table.insert(entries, { obj, "Transparency", obj.Transparency })
                    end
                end
                consider(root)
                for _, desc in ipairs(root:GetDescendants()) do
                    consider(desc)
                end
                return entries
            end

            for _, group in ipairs(groups) do
                group.Data = {}
                for _, item in ipairs(group.Items) do
                    local rest = item.Position
                    group.Data[item] = {
                        Rest = rest,
                        Hidden = UDim2.new(rest.X.Scale, rest.X.Offset + group.Offset.X, rest.Y.Scale, rest.Y.Offset + group.Offset.Y),
                        Fade = collectFade(item),
                    }
                end
            end

            local function setState(rest)
                for _, group in ipairs(groups) do
                    for item, data in pairs(group.Data) do
                        item.Position = rest and data.Rest or data.Hidden
                        for _, entry in ipairs(data.Fade) do
                            entry[1][entry[2]] = rest and entry[3] or 1
                        end
                    end
                end
            end

            local function setExpandedPicker(state)
                token += 1
                local myToken = token

                if sizeTween then
                    sizeTween:Cancel()
                end

                if state then
                    setPartsVisible(true)
                end

                sizeTween = Tween(frame, TweenInfo.new(state and 0.45 or 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Size = frameSize(state and 140 or 32),
                })

                local duration = state and 0.4 or 0.18
                local info = TweenInfo.new(duration, state and Enum.EasingStyle.Quint or Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

                for _, group in ipairs(groups) do
                    task.delay(state and group.Delay or 0, function()
                        if myToken ~= token then
                            return
                        end
                        for item, data in pairs(group.Data) do
                            Tween(item, info, { Position = state and data.Rest or data.Hidden })
                            for _, entry in ipairs(data.Fade) do
                                Tween(entry[1], info, { [entry[2]] = state and entry[3] or 1 })
                            end
                        end
                    end)
                end

                if not state then
                    task.delay(0.3, function()
                        if myToken == token and not expandedPicker then
                            setPartsVisible(false)
                        end
                    end)
                end
            end

            Track(headerHit.MouseButton1Click:Connect(function()
                expandedPicker = not expandedPicker
                PlaySound("click")
                setExpandedPicker(expandedPicker)
            end))

            frame.Size = frameSize(32)
            setState(false)
            setPartsVisible(false)

            return {
                Set = function(_, newColor)
                    local h, s, v = newColor:ToHSV()
                    hue = h
                    hueThumb.Position = UDim2.fromScale(h, 0.5)
                    baseGradient.Color = hueSequence(h)
                    apply(nil, nil, 1 - v, 1 - s, true)
                end,
            }
        end

        ------------------------------------------------------------
        -- Divider
        ------------------------------------------------------------
        function tab:CreateDivider()
            local frame = Instance.new("Frame")
            frame.Parent = currentColumn
            registerElement(frame, true)
            frame.BackgroundTransparency = 1
            frame.Size = UDim2.new(1, 0, 0, 18)
            frame.ClipsDescendants = true

            local line = Instance.new("Frame")
            line.Parent = frame
            line.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            line.Size = UDim2.new(1, -4.0, 0, 1)
            line.Position = UDim2.new(0.5, -2.0, 0.5, 0)
            line.AnchorPoint = Vector2.new(0.5, 0.5)
            line.BorderSizePixel = 0
            line.BackgroundTransparency = 0.5
        end

        tab.Index = tabData.Index
        return tab
    end

    ----------------------------------------------------------------
    -- Theme tab
    ----------------------------------------------------------------
    function window:CreateThemeTab()
        local themeTab = window:CreateTab("#!THEME", "paintbrush")

        pcall(function()
            if not isfolder(Library.Folder) then
                makefolder(Library.Folder)
            end
            if not isfolder(Library.Folder .. "/themes") then
                makefolder(Library.Folder .. "/themes")
            end
        end)

        local themesDir = Library.Folder .. "/themes"
        local presetNames = { "Default Catsaken", "Purplesaken", "Greensaken", "Bluesaken" }
        local presets = {
            Purplesaken = {
                title = "",
                background = "https://i.pinimg.com/236x/3f/f6/d6/3ff6d6f8e37e18859575e453bd434eb9.jpg",
                accent = "ae59ff",
                shades = { alt = "c900ff", hover = "b81eff", mid = "9e27f5", dark = "c900ff", dark2 = "7c0fa0", deep = "84009b", light = "c76eff" },
            },
            Greensaken = {
                title = "",
                background = "https://img.pixers.pics/pho_wat(s3:700/FO/47/10/76/97/700_FO47107697_297131ab14cff90a0d8e3fe6e39e5b9b.jpg,700,700,cms:2018/10/5bd1b6b8d04b8_220x50-watermark.png,over,480,650,jpg)/wall-murals-green-eco-leaves-seamless-background-pattern.jpg.jpg",
                accent = "59ff5b",
                shades = { alt = "00ff0c", hover = "1eff57", mid = "27f53f", dark = "20ff00", dark2 = "0fa034", deep = "00ff4a", light = "6eff70" },
            },
            ["Default Catsaken"] = {
                title = "",
                background = "https://github.com/aibabylaugh/catsaken/raw/main/patterns.jpg",
                accent = "ffbe50",
            },
            Bluesaken = {
                title = "",
                background = "https://w.wallhaven.cc/full/eo/wallhaven-eod8ew.png",
                accent = "0088ff",
                shades = { alt = "00a1ff", hover = "00a0ff", mid = "008ef5", dark = "00548c", dark2 = "005ca0", deep = "00416e", light = "2b9eff" },
            },
        }

        local pickers = {}
        local titleInput, backgroundInput

        local function toHex(c)
            return string.format("%02x%02x%02x", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
        end
        local function fromHex(hex)
            hex = tostring(hex):gsub("#", "")
            local r, g, b = tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
            if r and g and b then
                return Color3.fromRGB(r, g, b)
            end
        end
        local function sanitizeName(n)
            n = tostring(n or ""):gsub("[^%w _%-]", "")
            return n:match("^%s*(.-)%s*$")
        end
        local function themePath(n)
            return themesDir .. "/" .. n .. ".json"
        end
        local function snapshotTheme()
            local data = {
                title = type(Library.Title) == "string" and Library.Title or "",
                background = type(Library.Background) == "string" and Library.Background or "",
                accent = toHex(GetAccentColor()),
                shades = {},
            }
            for _, shade in ipairs(Library.AccentShadeNames) do
                data.shades[shade] = toHex(GetAccentColor(shade))
            end
            return data
        end
        local function listThemeFiles()
            local out = {}
            local ok, files = pcall(listfiles, themesDir)
            if ok then
                for _, path in ipairs(files) do
                    local fileName = path:match("([^/\\]+)%.json$")
                    if fileName then
                        table.insert(out, fileName)
                    end
                end
            end
            table.sort(out, function(a, b)
                return a:lower() < b:lower()
            end)
            return out
        end
        local function allThemeNames()
            local out = { unpack(presetNames) }
            for _, n in ipairs(listThemeFiles()) do
                if not presets[n] then
                    table.insert(out, n)
                end
            end
            return out
        end
        local function loadThemeData(n)
            if presets[n] then
                return presets[n]
            end
            local path = themePath(n)
            if isfile(path) then
                local ok, data = pcall(function()
                    return HttpService:JSONDecode(readfile(path))
                end)
                if ok and type(data) == "table" then
                    return data
                end
            end
        end
        local function getAutoload()
            if isfile(themesDir .. "/_autoload.txt") then
                local n = readfile(themesDir .. "/_autoload.txt"):match("^%s*(.-)%s*$")
                return n ~= "" and n or nil
            end
        end
        local function applyTheme(data)
            local accentColor = data.accent and fromHex(data.accent)
            if accentColor then
                Accent = accentColor
            end

            for _, shade in ipairs(Library.AccentShadeNames) do
                local hex = data.shades and data.shades[shade]
                ShadeOverrides[shade] = hex and fromHex(hex) or nil
            end

            RefreshAccent()

            if pickers.accent then
                pickers.accent:Set(GetAccentColor())
            end
            for _, shade in ipairs(Library.AccentShadeNames) do
                if pickers[shade] then
                    pickers[shade]:Set(GetAccentColor(shade))
                end
            end

            if data.title ~= nil then
                Library.Title = data.title ~= "" and data.title or defaultTitle
                window:UpdateTitle()
                if titleInput then
                    titleInput:Set(data.title)
                end
            end

            if data.background ~= nil then
                Library.Background = data.background ~= "" and data.background or nil
                window:UpdateBackground()
                if backgroundInput then
                    backgroundInput:Set(data.background)
                end
            end
        end

        themeTab:CreateSection("Colors", "Left")
        pickers.accent = themeTab:CreateColorPicker({
            Name = "Accent",
            Color = GetAccentColor(),
            Flag = "__ThemeAccent",
            DontSave = true,
            Callback = function(color)
                Accent = color
                RefreshAccent()

                for _, shade in ipairs(Library.AccentShadeNames) do
                    if not ShadeOverrides[shade] and pickers[shade] then
                        pickers[shade]:Set(GetAccentColor(shade))
                    end
                end
            end,
        })

        local shadeDescriptions = {
            alt = "Title gradient end",
            hover = "Icon hover",
            mid = "Slider, dropdown, scrollbar",
            dark = "Toggle on, search box",
            dark2 = "Keybind waiting",
            deep = "Tab hover",
            light = "Input text",
        }

        for _, shade in ipairs(Library.AccentShadeNames) do
            pickers[shade] = themeTab:CreateColorPicker({
                Name = shadeDescriptions[shade],
                Color = GetAccentColor(shade),
                Flag = "__ThemeShade_" .. shade,
                DontSave = true,
                Callback = function(color)
                    ShadeOverrides[shade] = color
                    RefreshAccent()
                end,
            })
        end

        themeTab:CreateSection("Themes", "Right")

        local selectedTheme = presetNames[1]
        local saveName = ""
        local statusLabel

        local function status(message)
            statusLabel:Set("Auto-load: " .. (getAutoload() or "none") .. (message and ("\n" .. message) or ""))
        end

        statusLabel = themeTab:CreateLabel("")
        status()

        local themeDropdown = themeTab:CreateDropdown({
            Name = "Theme",
            Flag = "__ThemeSelect",
            Options = allThemeNames(),
            CurrentOption = { selectedTheme },
            MultipleOptions = false,
            Callback = function(selection)
                selectedTheme = selection[1]
            end,
        })

        themeTab:CreateButton({
            Name = "Load theme",
            Callback = function()
                local data = selectedTheme and loadThemeData(selectedTheme)
                if not data then
                    return status("Pick a theme first")
                end
                applyTheme(data)
                status("Loaded " .. selectedTheme)
            end,
        })
        themeTab:CreateButton({
            Name = "Set as auto-load",
            Callback = function()
                if not (selectedTheme and loadThemeData(selectedTheme)) then
                    return status("Pick a theme first")
                end
                writefile(themesDir .. "/_autoload.txt", selectedTheme)
                status("Auto-load set to " .. selectedTheme)
            end,
        })
        themeTab:CreateButton({
            Name = "Clear auto-load",
            Callback = function()
                pcall(delfile, themesDir .. "/_autoload.txt")
                status("Auto-load cleared")
            end,
        })
        themeTab:CreateButton({
            Name = "Delete theme",
            Callback = function()
                if not selectedTheme then
                    return status("Pick a theme first")
                end
                if presets[selectedTheme] then
                    return status("Presets can't be deleted")
                end

                local deleted = selectedTheme
                pcall(delfile, themePath(deleted))

                if getAutoload() == deleted then
                    pcall(delfile, themesDir .. "/_autoload.txt")
                end

                selectedTheme = nil
                themeDropdown:Refresh(allThemeNames())
                status("Deleted " .. deleted)
            end,
        })
        themeTab:CreateInput({
            Name = "Save current as",
            Flag = "__ThemeSaveName",
            PlaceholderText = "Theme name",
            RemoveTextAfterFocusLost = false,
            DontSave = true,
            Callback = function(text)
                saveName = sanitizeName(text)
            end,
        })
        themeTab:CreateButton({
            Name = "Save theme",
            Callback = function()
                if saveName == "" then
                    return status("Type a theme name first")
                end
                if presets[saveName] then
                    return status(saveName .. " is a preset name")
                end
                writefile(themePath(saveName), HttpService:JSONEncode(snapshotTheme()))
                themeDropdown:Refresh(allThemeNames())
                status("Saved " .. saveName)
            end,
        })

        themeTab:CreateSection("Preview", "Right")
        themeTab:CreateLabel("Everything here uses your colors live.")
        themeTab:CreateToggle({ Name = "Example toggle", Flag = "__ThemePreviewToggle", CurrentValue = true, NoSave = true, ToolTip = "Example tooltip" })
        themeTab:CreateToggle({ Name = "Example text toggle", Flag = "__ThemePreviewTextToggle", CurrentValue = true, TextMode = true, NoSave = true, ToolTip = "Used to easily differentiate setting/configurations and actual features" })
        themeTab:CreateSlider({ Name = "Example slider", Flag = "__ThemePreviewSlider", Range = { 0, 100 }, Increment = 1, Suffix = "%", CurrentValue = 50 })
        themeTab:CreateDropdown({ Name = "Example dropdown", Flag = "__ThemePreviewDropdown", Options = { "Option 1", "Option 2", "Option 3" }, CurrentOption = { "Option 1" }, MultipleOptions = false })
        themeTab:CreateKeybind({ Name = "Example keybind" })
        themeTab:CreateInput({ Name = "Example textbox", Flag = "__ThemePreviewInput", PlaceholderText = "Type here", DontSave = true })
        themeTab:CreateColorPicker({ Name = "Example color picker", Color = Color3.fromRGB(255, 255, 255), Flag = "__ThemePreviewColor", DontSave = true })
        themeTab:CreateButton({ Name = "Example button" })

        themeTab:CreateSection("Window", "Left")
        backgroundInput = themeTab:CreateInput({
            Name = "Background (URL)",
            CurrentValue = isfile(Library.Folder .. "/backgroundimg") and readfile(Library.Folder .. "/backgroundimg"),
            PlaceholderText = "URL",
            RemoveTextAfterFocusLost = false,
            Flag = "backgroundimg",
            DontSave = true,
            Callback = function(url, init)
                if init then
                    return
                end

                writefile(Library.Folder .. "/backgroundimg", url)

                if url == "" or not url:match("http?.://") then
                    url = "https://github.com/aibabylaugh/catsaken/raw/main/patterns.jpg"
                end

                Library.Background = url
                window:UpdateBackground()
            end,
        })
        titleInput = themeTab:CreateInput({
            Name = "Window title (html supported)",
            CurrentValue = isfile(Library.Folder .. "/windowtitle") and readfile(Library.Folder .. "/windowtitle"),
            PlaceholderText = "Text",
            RemoveTextAfterFocusLost = false,
            Flag = "windowtitle",
            DontSave = true,
            Callback = function(text, init)
                if init then
                    return
                end

                writefile(Library.Folder .. "/windowtitle", text)
                Library.Title = text ~= "" and text or defaultTitle
                window:UpdateTitle()
            end,
        })

        if isfile(Library.Folder .. "/backgroundimg") then
            local url = readfile(Library.Folder .. "/backgroundimg")

            if url == "" or not url:match("http?.://") then
                url = "https://github.com/aibabylaugh/catsaken/raw/main/patterns.jpg"
            end

            Library.Background = url
            window:UpdateBackground()
        end

        if isfile(Library.Folder .. "/windowtitle") then
            local text = readfile(Library.Folder .. "/windowtitle")
            Library.Title = text ~= "" and text or defaultTitle
            window:UpdateTitle()
        end

        local autoload = getAutoload()
        local autoloadData = autoload and loadThemeData(autoload)

        if autoloadData then
            task.spawn(applyTheme, autoloadData)
        end

        return themeTab
    end

    ----------------------------------------------------------------
    -- Global keybind dispatcher / tab selection
    ----------------------------------------------------------------
    Track(UserInputService.InputBegan:Connect(function(input, processed)
        if Unloaded then
            return
        end
        if processed then
            return
        end
        for _, keybind in pairs(window.Keybinds) do
            if keybind.Pressable and keybind.KeyCode and input.KeyCode == Enum.KeyCode[keybind.KeyCode] then
                keybind.Callback()
            end
        end
    end))

    function window:SelectTab(index)
        for _, tab in pairs(tabs) do
            if tab ~= tabs[index] then
                tab.IsSelected = false
                tab.Deselect()
            end
        end
        tabs[index].IsSelected = true
        tabs[index].Select()
    end

    ----------------------------------------------------------------
    -- Config helpers
    ----------------------------------------------------------------
    function window:GetConfigData()
        return SanitizeFlags(window.Flags)
    end

    function window:SaveConfig()
        if not configPath then
            return false
        end
        local data = {}
        if isfile(configPath) then
            local ok, decoded = pcall(function()
                return HttpService:JSONDecode(readfile(configPath))
            end)
            if ok and type(decoded) == "table" then
                data = decoded
            end
        end
        data[configName] = window:GetConfigData()
        writefile(configPath, HttpService:JSONEncode(data))
        return true
    end

    if configPath and cs.AutoSave ~= false then
        task.spawn(function()
            while not Unloaded do
                local okBefore, before = pcall(function()
                    return HttpService:JSONEncode(window:GetConfigData())
                end)

                wait(1)

                if Unloaded then
                    break
                end

                local okAfter, after = pcall(function()
                    return HttpService:JSONEncode(window:GetConfigData())
                end)

                if okBefore and okAfter and before ~= after then
                    pcall(function()
                        window:SaveConfig()
                    end)
                end
            end
        end)
    end

    window.Tabs = tabs
    window.Frame = main

    if cfg.StartHidden ~= true then
        gui.Enabled = true
    end

    return window
end

----------------------------------------------------------------
-- Notifications
----------------------------------------------------------------
local NotifGui, NotifList, NotifLayout
local NotifQueue = {}

local function EnsureNotifHolder()
    if NotifGui and NotifGui.Parent then
        return
    end

    NotifGui = Instance.new("ScreenGui")
    NotifGui.Name = "NotifHolder"
    NotifGui.Parent = GetHui()
    NotifGui.ResetOnSpawn = false
    NotifGui.IgnoreGuiInset = true

    NotifList = Instance.new("Frame")
    NotifList.Name = "List"
    NotifList.Parent = NotifGui
    NotifList.AnchorPoint = Vector2.new(1, 1)
    NotifList.Position = UDim2.new(1, -20, 1, -20)
    NotifList.Size = UDim2.new(0, 300, 1, -40)
    NotifList.BackgroundTransparency = 1

    NotifLayout = Instance.new("UIListLayout")
    NotifLayout.Parent = NotifList
    NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    NotifLayout.Padding = UDim.new(0, 8)
end

function Library:ChangeNotificationLayout(alignment)
    EnsureNotifHolder()
    NotifLayout.VerticalAlignment = Enum.VerticalAlignment[alignment]
end

function Library:DeleteNotifications()
    EnsureNotifHolder()
    for _, child in pairs(NotifList:GetChildren()) do
        if child.Name == "Notif" then
            child:Destroy()
        end
    end
    NotifQueue = {}
end

function Library:Notify(opts)
    EnsureNotifHolder()

    local title = opts.Title or ""
    local content = opts.Content or ""
    local duration = opts.Duration or 5
    local image = opts.Image
    local noQueue = opts.NoQueue

    if NotifQueue[content] then
        return
    end

    if not noQueue then
        NotifQueue[content] = true
    end

    task.delay(duration, function()
        NotifQueue[content] = nil
    end)

    local frame = Instance.new("Frame")
    frame.Name = "Notif"
    frame.Parent = NotifList
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(1, 0, 0, 0)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.ClipsDescendants = true
    frame.LayoutOrder = NotifLayout.VerticalAlignment == Enum.VerticalAlignment.Bottom and -os.clock() or os.clock()
    frame.BackgroundTransparency = 0.5

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(55, 55, 55)
    stroke.Thickness = 1
    stroke.Parent = frame

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = frame

    local offset = 0

    if image then
        local iconData = GetIcon(image)
        local iconLabel = Instance.new("ImageLabel")
        iconLabel.Name = "Icon"
        iconLabel.Parent = frame
        iconLabel.BackgroundTransparency = 1
        iconLabel.Position = UDim2.new(0, 0, 0, 1)
        iconLabel.Size = UDim2.new(0, 18, 0, 18)
        iconLabel.Image = iconData.id
        iconLabel.ImageRectOffset = iconData.imageRectOffset
        iconLabel.ImageRectSize = iconData.imageRectSize
        iconLabel.ImageColor3 = Color3.fromRGB(230, 230, 230)
        offset = 26
    end

    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Parent = frame
    closeBtn.AnchorPoint = Vector2.new(1, 0)
    closeBtn.Position = UDim2.new(1, 0, 0, 0)
    closeBtn.Size = UDim2.new(0, 18, 0, 18)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = ""
    closeBtn.ZIndex = 3

    local closeData = GetIcon("x")
    local closeIcon = Instance.new("ImageLabel")
    closeIcon.Parent = closeBtn
    closeIcon.BackgroundTransparency = 1
    closeIcon.Size = UDim2.new(1, 0, 1, 0)
    closeIcon.Image = closeData.id
    closeIcon.ImageRectOffset = closeData.imageRectOffset
    closeIcon.ImageRectSize = closeData.imageRectSize
    closeIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)

    closeBtn.MouseEnter:Connect(function()
        setthreadidentity(8)
        TweenService:Create(closeIcon, TweenInfo.new(0.15), { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        setthreadidentity(8)
        TweenService:Create(closeIcon, TweenInfo.new(0.15), { ImageColor3 = Color3.fromRGB(150, 150, 150) }):Play()
    end)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Parent = frame
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, offset, 0, 0)
    titleLabel.Size = UDim2.new(1, -offset - 22, 0, 18)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Top

    local contentLabel = Instance.new("TextLabel")
    contentLabel.Name = "Content"
    contentLabel.Parent = frame
    contentLabel.BackgroundTransparency = 1
    contentLabel.Position = UDim2.new(0, offset, 0, 22)
    contentLabel.Size = UDim2.new(1, -offset, 0, 0)
    contentLabel.AutomaticSize = Enum.AutomaticSize.Y
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.Text = content
    contentLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    contentLabel.TextSize = 13
    contentLabel.TextWrapped = true
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    contentLabel.RichText = true

    local progress = Instance.new("Frame")
    progress.Name = "Bar"
    progress.Parent = frame
    progress.AnchorPoint = Vector2.new(0, 1)
    progress.Position = UDim2.new(0, 8, 1, 12)
    progress.Size = UDim2.new(1, -16, 0, 2)
    progress.BackgroundColor3 = Color3.fromRGB(245, 159, 39)
    progress.BorderSizePixel = 0

    frame.Size = UDim2.new(1, 0, 0, 0)
    frame.BackgroundTransparency = 1
    frame.Position = UDim2.new(0, 40, 0, 0)

    for _, desc in ipairs(frame:GetDescendants()) do
        if desc:IsA("TextLabel") then
            desc.TextTransparency = 1
        end
        if desc:IsA("ImageLabel") then
            desc.ImageTransparency = 1
        end
    end

    stroke.Transparency = 1
    progress.BackgroundTransparency = 1
    wait()

    TweenService:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.15,
        Position = UDim2.new(0, 0, 0, 0),
    }):Play()
    TweenService:Create(stroke, TweenInfo.new(0.35), { Transparency = 0 }):Play()

    for _, desc in ipairs(frame:GetDescendants()) do
        if desc:IsA("TextLabel") then
            TweenService:Create(desc, TweenInfo.new(0.35), { TextTransparency = desc == contentLabel and 0.3 or 0 }):Play()
        elseif desc:IsA("ImageLabel") then
            TweenService:Create(desc, TweenInfo.new(0.35), { ImageTransparency = 0 }):Play()
        end
    end

    TweenService:Create(progress, TweenInfo.new(0.35), { BackgroundTransparency = 0.3 }):Play()
    TweenService:Create(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) }):Play()

    local closed = false

    local function close()
        if closed then
            return
        end
        closed = true
        NotifQueue[content] = nil

        local info = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

        TweenService:Create(frame, info, { BackgroundTransparency = 1, Position = UDim2.new(0, 40, 0, 0) }):Play()
        TweenService:Create(stroke, info, { Transparency = 1 }):Play()

        for _, desc in ipairs(frame:GetDescendants()) do
            if desc:IsA("TextLabel") then
                TweenService:Create(desc, info, { TextTransparency = 1 }):Play()
            elseif desc:IsA("ImageLabel") then
                TweenService:Create(desc, info, { ImageTransparency = 1 }):Play()
            end
        end

        TweenService:Create(progress, info, { BackgroundTransparency = 1 }):Play()
        wait(0.2)

        local tween = TweenService:Create(frame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(1, 0, 0, 0),
        })
        tween:Play()
        tween.Completed:Wait()
        frame:Destroy()
    end

    closeBtn.MouseButton1Click:Connect(close)

    if not opts.Sticky then
        task.delay(duration + 1, function()
            frame:Destroy()
        end)
        task.delay(duration, close)
    end

    return { Close = close }
end

----------------------------------------------------------------
-- Loading screen
----------------------------------------------------------------
--  local loader = Library:CreateLoader({ Title = "Catsaken" })
--  loader:setStatus("Loading..."); loader:setProgress(50, "Halfway"); loader:finished()
function Library:CreateLoader(opts)
    opts = opts or {}

    local cardBg = Color3.fromRGB(33, 33, 33)
    local strokeColor = Color3.fromRGB(60, 60, 60)
    local barBg = Color3.fromRGB(55, 55, 55)
    local orange = Color3.fromRGB(255, 182, 46)
    local statusColor = Color3.fromRGB(170, 170, 170)
    local textColor = Color3.fromRGB(235, 235, 235)

    local Loader = {}
    Loader.__index = Loader

    local function new(class, props, parent)
        local inst = Instance.new(class)
        for k, v in pairs(props) do
            inst[k] = v
        end
        inst.Parent = parent
        return inst
    end

    local function fade(self, show)
        local info = TweenInfo.new(0.3, Enum.EasingStyle.Quad, show and Enum.EasingDirection.Out or Enum.EasingDirection.In)
        local value = show and 0 or 1

        TweenService:Create(self._content, info, { GroupTransparency = value }):Play()
        TweenService:Create(self._card, info, { BackgroundTransparency = value }):Play()
        TweenService:Create(self._stroke, info, { Transparency = value }):Play()

        local tween = TweenService:Create(self._scale, info, { Scale = show and 1 or 0.9 })
        tween:Play()
        return tween
    end

    local self = setmetatable({}, Loader)

    local card = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(340, 116),
        BackgroundColor3 = cardBg,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    })

    new("UIDragDetector", {}, card)
    new("UICorner", { CornerRadius = UDim.new(0, 14) }, card)

    local stroke = new("UIStroke", { Color = strokeColor, Thickness = 1, Transparency = 1 }, card)
    local scale = new("UIScale", { Scale = 0.9 }, card)
    local content = new("CanvasGroup", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        GroupTransparency = 1,
    }, card)

    local spinner = new("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -24, 0, 16),
        Size = UDim2.fromOffset(34, 34),
        BackgroundTransparency = 1,
    }, content)

    local dots = {}
    for i = 1, 13 do
        local angle = (i - 1) / 13 * math.pi * 2 - 1.5707963267948966
        local dot = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5 + math.cos(angle) * 0.385, 0.5 + math.sin(angle) * 0.385),
            Size = UDim2.fromOffset(5, 5),
            BackgroundColor3 = orange,
            BorderSizePixel = 0,
        }, spinner)
        new("UICorner", { CornerRadius = UDim.new(1, 0) }, dot)
        dots[i] = dot
    end

    new("TextLabel", {
        Position = UDim2.fromOffset(24, 16),
        Size = UDim2.new(1, -90, 0, 34),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = opts.Title or "Catsaken",
        TextColor3 = textColor,
        TextSize = 22,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, content)

    local statusLabel = new("TextLabel", {
        Position = UDim2.fromOffset(24, 56),
        Size = UDim2.new(1, -110, 0, 22),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = "Loading...",
        TextColor3 = statusColor,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, content)

    local percentLabel = new("TextLabel", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -24, 0, 56),
        Size = UDim2.fromOffset(56, 22),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "0%",
        TextColor3 = textColor,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, content)

    local barTrack = new("Frame", {
        Position = UDim2.fromOffset(24, 88),
        Size = UDim2.new(1, -48, 0, 8),
        BackgroundColor3 = barBg,
        BorderSizePixel = 0,
    }, content)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, barTrack)

    local barFill = new("Frame", {
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = orange,
        BorderSizePixel = 0,
    }, barTrack)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, barFill)

    local root = new("ScreenGui", {
        Name = "LoadingScreen",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        DisplayOrder = 999,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    card.Parent = root
    root.Parent = opts.Parent or GetHui()

    self._root = root
    self._card = card
    self._stroke = stroke
    self._scale = scale
    self._content = content
    self._status = statusLabel
    self._target = 0
    self._shown = 0
    self._done = false
    self._conn = RunService.Heartbeat:Connect(function(dt)
        local phase = os.clock() * 10 % 13

        for i, dot in ipairs(dots) do
            dot.BackgroundTransparency = (phase - i) % 13 / 13 * 0.85
        end

        self._shown += (self._target - self._shown) * math.min(1, dt * 8)
        barFill.Size = UDim2.fromScale(self._shown / 100, 1)
        percentLabel.Text = math.floor(self._shown + 0.5) .. "%"
    end)
    fade(self, true)

    function Loader:setProgress(value, status)
        if self._done then
            return
        end
        self._target = math.clamp(value, 0, 100)
        if status then
            self._status.Text = status
        end
    end

    function Loader:setStatus(text)
        if self._done then
            return
        end
        self._status.Text = text
    end

    function Loader:finished()
        if self._done then
            return
        end
        self._done = true
        self._target = 100

        while self._shown < 99.5 and self._root.Parent do
            wait()
        end

        self._shown = 100
        wait(0.25)

        if not self._root.Parent then
            return
        end

        fade(self, false)
        wait(0.3)
        self:destroy()
    end

    function Loader:destroy()
        self._done = true
        self._conn:Disconnect()
        self._root:Destroy()
    end

    return self
end

----------------------------------------------------------------
-- Destroy everything
----------------------------------------------------------------
function Library:Destroy()
    if Unloaded then
        return
    end
    Unloaded = true

    pcall(function()
        if Library.ScreenGui then
            Library.ScreenGui:Destroy()
        end
    end)
    pcall(function()
        if Library.TabStorage then
            Library.TabStorage:Destroy()
        end
    end)
    pcall(function()
        if NotifGui then
            NotifGui:Destroy()
        end
    end)
    pcall(function()
        if SmoothScroll then
            SmoothScroll.Destroy()
        end
    end)

    for _, conn in ipairs(Connections) do
        pcall(function()
            conn:Disconnect()
        end)
    end
    table.clear(Connections)
    table.clear(AccentAppliers)
    Library.ScreenGui = nil
end

return Library
