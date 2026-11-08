local __modules, __cache = {}, {}

local function import(name)
    local cached = __cache[name]
    if cached ~= nil then return cached end

    local factory = __modules[name]
    if not factory then
        error("[rift] unknown module: " .. tostring(name), 2)
    end

    local result = factory(import)
    __cache[name] = result
    return result
end

__modules["core/Services"] = function(import)

local Services = {}

Services.Players            = game:GetService("Players")
Services.RunService         = game:GetService("RunService")
Services.UserInputService   = game:GetService("UserInputService")
Services.ReplicatedStorage  = game:GetService("ReplicatedStorage")
Services.CollectionService  = game:GetService("CollectionService")
Services.TweenService       = game:GetService("TweenService")
Services.HttpService        = game:GetService("HttpService")
Services.Workspace          = workspace

Services.LocalPlayer = Services.Players.LocalPlayer

Services.LogoImage = "rbxassetid://127992680361909"
Services.Camera      = workspace.CurrentCamera

local RS = Services.ReplicatedStorage
Services.Remotes  = RS:WaitForChild("Remotes")
Services.Gameplay = Services.Remotes:WaitForChild("Gameplay")
Services.Shop     = Services.Remotes:WaitForChild("Shop")

local function tryRequire(path)
    local ok, result = pcall(function()
        local node = RS
        for _, name in ipairs(path) do
            node = node:WaitForChild(name, 10)
            if not node then return nil end
        end
        return require(node)
    end)
    if ok then return result end
    return nil
end

Services.Sync               = tryRequire({ "Database", "Sync" })
Services.CurrentRoundClient = tryRequire({ "Modules", "CurrentRoundClient" })
Services.WeaponService      = tryRequire({ "ClientServices", "WeaponService" })

return Services
end

__modules["core/State"] = function(import)

return {
    SelectedConfig     = nil,

    SilentGun          = false,
    SilentKnife        = false,
    LeadPrediction     = true,
    JumpPrediction     = true,
    PredictionMult     = 1.0,
    JumpPredictionMult = 1.0,
    SilentPredict      = 1.0,
    SilentMode         = "Closest to Crosshair",
    SilentFov          = 0,
    SilentMaxRange     = 295,
    SilentWallCheck    = false,
    SilentChance       = 100,
    SilentJitter       = 0,
    AimPart            = "HumanoidRootPart",
    KnifeTargetHero    = true,

    KnifeSpeedEnabled  = false,
    KnifeThrowSpeed    = 96,
    AutoThrowKnife     = false,
    ThrowDelay         = 0.6,

    HitboxEnabled      = false,
    HitboxSize         = 12,
    HitboxVisible      = false,
    HitboxMode         = "Everyone",
    HitboxForceTouch   = false,
    HitboxTouchRange   = 25,
    HitboxTouchDelay   = 0.2,

    KnifeAura          = false,
    AuraRadius         = 18,
    AuraDelay          = 0.15,

    AutoKillAll        = false,
    KillAllDelay       = 3,
    KillAllStep        = 0.08,

    AutoShootMurderer  = false,

    Triggerbot         = false,
    TriggerFov         = 60,
    TriggerDelay       = 0.05,
    TriggerCooldown    = 0.25,
    TriggerVisibleOnly = true,
    TriggerNeedsEquip  = true,
    TriggerShowFov     = false,
    ShootDelay         = 0.35,

    AutoGrabGun        = false,
    KillMurdererDistance = 4,
    KillMurdererReturn = true,
    KillMurdererShots  = 6,
    KillMurdererGap    = 1,
    KillingMurderer    = false,
    GunDropNotify      = false,
    AutoKillMurderer   = false,
    ShootingMurderer   = false,
    ThrowTarget        = nil,
    AntiTrap           = false,
    FakeGunDetector    = false,
    DualGun            = false,
    DualKnife          = false,
    GunDropSound       = true,

    AutoDodge          = false,
    DodgeRadius        = 6,
    DodgeWarning       = 0.6,
    DodgeDistance      = 7,
    DodgeCooldown      = 0.35,
    DodgeNotify        = false,

    BulletDodge        = false,
    BulletStyle        = "Slide",
    BulletJukeDistance = 3,
    BulletJukeEvery    = 0.22,
    BulletRange        = 150,
    BulletFacing       = 40,
    BulletJump         = false,
    BulletNotify       = false,
    BulletNearMiss     = 8,
    BulletAllowEdges   = false,

    KnifeTrail         = false,
    KnifeTrailColor    = "Halloween",
    KnifeTrailPath     = true,
    KnifeTrailGlow     = true,
    KnifeTrailMarker   = true,

    AntiStab           = false,
    AntiStabRadius     = 14,
    AntiStabDistance   = 20,
    AntiStabHop        = 16,
    AntiStabMode       = "Dash",
    AntiStabReact      = 0.2,
    AntiStabCooldown   = 0.35,
    AntiStabNotify     = false,

    ShotTrace          = false,
    TraceStyle         = "Beam",
    TraceColorName     = "Green",
    TraceLife          = 2.5,
    TraceThickness     = 0.28,
    TraceImpact        = true,

    StabGap            = 0.05,

    EspMurderer        = false,
    EspSheriff         = false,
    EspHero            = false,
    EspInnocents       = false,
    EspZombies         = false,
    EspAssassinTarget  = false,
    EspAssassins       = false,
    SilentAssassin     = true,
    EspSurvivors       = false,
    SilentZombies      = true,
    EspGun             = false,
    EspEverything      = false,
    EspBoxes           = false,
    BoxThickness       = 1.5,
    EspTracers         = false,
    TracerOrigin       = "Bottom",
    TracerThickness    = 1,
    EspNames           = true,
    EspDistance        = true,
    ShowCounter        = false,
    XRay               = false,
    EspTraps           = false,
    EspSkins           = false,
    MurdererAlarm      = false,
    AlarmRadius        = 25,
    AlarmSound         = true,
    AutoWallHop        = false,
    AntiAfk            = false,
    AutoRejoin         = false,
    FarmStats          = false,
    RoundLog           = false,
    RoundWebhookUrl    = "",
    PerformanceMode    = false,
    FpsCounter         = false,

    SpeedEnabled       = false,
    WalkSpeed          = 16,
    JumpEnabled        = false,
    JumpPower          = 50,
    Fly                = false,
    FlySpeed           = 60,
    AutoGhost          = false,

    Emote              = nil,

    ShowSpawner        = false,
    SpawnerChroma      = false,
    SpawnerQty         = 1,

    Crosshair          = false,
    CrosshairSpin      = false,
    CrosshairId        = "11770890197",
    CrosshairSize      = 42,

    UITheme            = "Halloween",
    Background         = nil,
    UIEffects          = true,
    HalloweenClaim     = false,
    HalloweenBuyTiers  = false,
    HalloweenBuyFinal  = false,
    HalloweenKeep      = 0,
    HalloweenCraft     = false,
    HalloweenGift      = false,
    HalloweenQuests    = false,
    HalloweenNotify    = true,

    MenuKey            = "RightShift",
    KeybindNotify      = true,

    ShowFloatingButtons = false,
    LockButtons        = false,
    ButtonSize         = 72,
    ButtonStyle        = "Squircle",
    ShowKillAllBtn      = true,
    ShowAutoKillAllBtn  = true,
    ShowKnifeAuraBtn    = true,
    ShowAutoShootBtn    = true,
    ShowGrabGunBtn      = true,
    ShowAutoGrabGunBtn  = true,
    ShowSilentAimBtn    = true,
    ShowSilentThrowBtn  = true,
    ShowFlingMurdererBtn = true,
    ShowAutoFarmBtn     = true,
    ShowBombJumpBtn     = true,
    ShowWallHopBtn      = true,
    ShowKillMurdererBtn = true,
    ShowShootMurdererBtn = true,
    ShowThrowKnifeBtn  = true,

    FlingDuration      = 2.5,
    FlingTarget        = nil,

    AntiFling          = false,
    AntiFlingMax       = 150,
    AntiFlingSnap      = 40,
    AntiFlingCollisions = true,

    AutoBox            = false,
    BoxId              = nil,
    BoxDelay           = 1.5,
    BoxAnimation       = false,
    WebhookUrl         = "",
    WebhookLogging     = false,

    CraftRecipe        = nil,
    AutoCraft          = false,
    CraftAny           = false,
    CraftMaterials     = false,
    CraftDelay         = 1,
    AutoSalvage        = false,
    SalvageCommon      = true,
    SalvageUncommon    = false,
    SalvageRare        = false,
    SalvageLegendary   = false,
    SalvageKeepOne     = true,
    SalvageDelay       = 1,
    LogCrafts          = false,
    LogSalvages        = false,
    CraftWebhookUrl    = "",

    AutoFarmCoins      = false,
    FarmMode           = "Normal",
    FarmDepth          = 3.5,
    FarmSpeed          = 20,
    FarmDelay          = 0.05,
    FlingMurdererOnFull = false,
    KillAllOnFull      = false,
}
end

__modules["core/Util"] = function(import)

local Services = import("core/Services")

local Players      = Services.Players
local RunService   = Services.RunService
local TweenService = Services.TweenService
local LP           = Services.LocalPlayer

local Util = {}

Util.Connections = {}
Util.Notify = function(_, _) end

function Util.Character(player)
    player = player or LP
    return player and player.Character
end

function Util.HRP(player)
    local char = Util.Character(player)
    return char and char:FindFirstChild("HumanoidRootPart")
end

function Util.Humanoid(player)
    local char = Util.Character(player)
    return char and char:FindFirstChildOfClass("Humanoid")
end

function Util.Alive(player)
    local hum = Util.Humanoid(player)
    local hrp = Util.HRP(player)
    return hum ~= nil and hrp ~= nil and hum.Health > 0
end

function Util.AimPart(player, partName)
    local char = Util.Character(player)
    if not char then return nil end
    return char:FindFirstChild(partName or "HumanoidRootPart")
        or char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("Head")
end

function Util.Distance(player)
    local a, b = Util.HRP(), Util.HRP(player)
    if not a or not b then return math.huge end
    return (a.Position - b.Position).Magnitude
end

function Util.Others(filter)
    local out = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and Util.Alive(plr) then
            if not filter or filter(plr) then
                table.insert(out, plr)
            end
        end
    end
    return out
end

function Util.Closest(filter)
    local best, bestDist = nil, math.huge
    for _, plr in ipairs(Util.Others(filter)) do
        local d = Util.Distance(plr)
        if d < bestDist then
            best, bestDist = plr, d
        end
    end
    return best, bestDist
end

function Util.FindPlayer(name)
    if not name then return nil end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name == name or plr.DisplayName == name then return plr end
    end
    return nil
end

function Util.Bind(key, signal, fn)
    Util.Unbind(key)
    Util.Connections[key] = signal:Connect(fn)
    return Util.Connections[key]
end

function Util.Unbind(key)
    local conn = Util.Connections[key]
    if conn then
        pcall(function() conn:Disconnect() end)
        Util.Connections[key] = nil
    end
end

function Util.UnbindAll()
    for key in pairs(Util.Connections) do
        Util.Unbind(key)
    end
end

function Util.Loop(key, interval, fn)
    Util.Unbind(key)
    local alive = true
    Util.Connections[key] = {
        Disconnect = function() alive = false end,
    }
    task.spawn(function()
        while alive do
            local ok, err = pcall(fn)
            if not ok then
                warn("[Riftware] loop '" .. key .. "' error: " .. tostring(err))
            end
            task.wait(interval() or 0.1)
        end
    end)
end

local noclipUsers = {}

local function noclipStep()
    local char = Util.Character()
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end

function Util.Noclip(owner, on)
    if on then
        noclipUsers[owner] = true
    else
        noclipUsers[owner] = nil
    end

    local any = next(noclipUsers) ~= nil
    if any then
        if not Util.Connections["__noclip"] then
            Util.Bind("__noclip", RunService.Stepped, noclipStep)
        end
    else
        Util.Unbind("__noclip")
    end
end

function Util.Teleport(cframe)
    local hrp = Util.HRP()
    if not hrp then return false end
    hrp.CFrame = cframe
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    return true
end

function Util.Glide(position, speed, keepGoing)
    local hrp = Util.HRP()
    if not hrp then return false end

    if type(speed) ~= "number" or speed <= 0 then speed = 20 end

    local distance = (hrp.Position - position).Magnitude
    if distance < 1 then return true end

    local duration = distance / speed

    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
        { CFrame = CFrame.new(position) }
    )

    Util.CurrentGlide = tween
    tween:Play()

    local elapsed = 0
    while elapsed < duration do
        if keepGoing and not keepGoing() then
            tween:Cancel()
            Util.CurrentGlide = nil
            return false
        end
        elapsed = elapsed + task.wait()
    end

    Util.CurrentGlide = nil
    return true
end

function Util.CancelGlide()
    if Util.CurrentGlide then
        pcall(function() Util.CurrentGlide:Cancel() end)
        Util.CurrentGlide = nil
    end
end

return Util
end

__modules["core/Roles"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")

local Players = Services.Players
local CS      = Services.CollectionService

local Roles = {}

local cache = nil
local cacheAt = 0
local fetching = false
local lastFetch = 0
local huntUntil = 0
local listeners = {}
local hooked = false

local function gameplayRemote(name)
    local gameplay = Services.Gameplay or Services.Remotes:FindFirstChild("Gameplay")
    return gameplay and gameplay:FindFirstChild(name)
end

local function adopt(data)
    if type(data) ~= "table" then return end
    cache = data
    cacheAt = os.clock()
    for _, fn in ipairs(listeners) do
        task.spawn(pcall, fn)
    end
end

function Roles.OnChanged(fn)
    table.insert(listeners, fn)
end

function Roles.Fetch(force)
    if fetching then return false end

    local now = os.clock()
    if not force and now - lastFetch < 0.35 then return false end

    local remote = gameplayRemote("GetCurrentPlayerData")
    if not remote then return false end

    lastFetch = now
    fetching = true

    task.spawn(function()
        local ok, data = pcall(function() return remote:InvokeServer() end)
        fetching = false
        if ok then adopt(data) end
    end)

    return true
end

function Roles.Hunt(seconds)
    local untilTime = os.clock() + (seconds or 3)
    if untilTime <= huntUntil then return end

    local running = os.clock() < huntUntil
    huntUntil = untilTime
    if running then return end

    task.spawn(function()
        while os.clock() < huntUntil do
            Roles.Fetch(true)
            task.wait(0.4)
        end
    end)
end

function Roles.Hook()
    if hooked then return end
    hooked = true

    local changed = gameplayRemote("PlayerDataChanged")
    if changed then
        changed.OnClientEvent:Connect(adopt)
    end

    local mod = Services.CurrentRoundClient
    if mod and type(mod.PlayerData) == "table" and next(mod.PlayerData) then
        adopt(mod.PlayerData)
    end
    Roles.Fetch(true)
end

function Roles.Age()
    if not cache then return math.huge end
    return os.clock() - cacheAt
end

function Roles.Data()
    if not hooked then Roles.Hook() end

    if cache then return cache end

    local mod = Services.CurrentRoundClient
    if mod and type(mod.PlayerData) == "table" then
        return mod.PlayerData
    end
    return {}
end

local function isKnifeTool(tool)
    if CS:HasTag(tool, "Weapon_Knife") then return true end
    local events = tool:FindFirstChild("Events")
    if events and events:FindFirstChild("KnifeStabbed") then return true end
    return tool.Name:lower():find("knife") ~= nil
end

local function isFakeGun(tool)
    if not tool:IsA("Tool") then return false end
    if tool.Name == "FakeGun" then return true end
    return tool:GetAttribute("FakeGun") == true
end

local function isGunTool(tool)
    if isFakeGun(tool) then return false end
    if CS:HasTag(tool, "Weapon_Gun") then return true end
    if tool:FindFirstChild("Shoot", true) then return true end
    local name = tool.Name:lower()
    return name:find("gun") ~= nil or name:find("revolver") ~= nil
        or name:find("pistol") ~= nil or name:find("luger") ~= nil
end

Roles.IsFakeGun = isFakeGun

Roles.IsKnifeTool = isKnifeTool
Roles.IsGunTool   = isGunTool

local function heldWeapon(player)
    local char = Util.Character(player)
    if not char then return nil end

    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then
            if isKnifeTool(child) then return "Knife" end
            if isGunTool(child) then return "Gun" end
        end
    end

    return nil
end

Roles.HeldWeapon = heldWeapon

local function inferFromTools(player)
    local held = heldWeapon(player)
    if held == "Knife" then return "Murderer" end
    if held == "Gun" then return "Sheriff" end
    return nil
end

local function holdingGun(player)
    return heldWeapon(player) == "Gun"
end

local function holdingKnife(player)
    return heldWeapon(player) == "Knife"
end

Roles.HoldingGun   = holdingGun
Roles.HoldingKnife = holdingKnife

function Roles.Of(player)
    if not player then return nil end

    local entry = Roles.Data()[player.Name]
    local role = entry and entry.Role

    if role == "Murderer" or role == "Sheriff" or role == "Hero" then
        return role
    end

    if holdingGun(player) then return "Hero" end

    if role then return role end
    return inferFromTools(player)
end

function Roles.IsDead(player)
    if not player then return true end
    local entry = Roles.Data()[player.Name]
    if entry and entry.Dead ~= nil then return entry.Dead == true end
    return not Util.Alive(player)
end

function Roles.Find(role)
    for _, plr in ipairs(Players:GetPlayers()) do
        if Roles.Of(plr) == role and not Roles.IsDead(plr) and Util.Alive(plr) then
            return plr
        end
    end
    return nil
end

function Roles.Murderer() return Roles.Find("Murderer") end
function Roles.Sheriff()  return Roles.Find("Sheriff")  end

function Roles.Hero() return Roles.Find("Hero") end

function Roles.Armed()
    return Roles.Sheriff() or Roles.Hero()
end

function Roles.LocalRole()
    return Roles.Of(Services.LocalPlayer)
end

function Roles.LocalIsMurderer()
    return Roles.LocalRole() == "Murderer"
end

function Roles.Innocents()
    return Util.Others(function(plr)
        local role = Roles.Of(plr)
        return role ~= "Murderer" and role ~= "Sheriff" and role ~= "Hero"
            and not Roles.IsDead(plr)
    end)
end

function Roles.WithRole(role)
    return Util.Others(function(plr)
        return Roles.Of(plr) == role and not Roles.IsDead(plr)
    end)
end

function Roles.Zombies() return Roles.WithRole("Zombie") end
function Roles.Survivors() return Roles.WithRole("Survivor") end

function Roles.Everyone()
    return Util.Others(function(plr)
        return not Roles.IsDead(plr)
    end)
end

return Roles
end

__modules["core/Weapons"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")

local CS      = Services.CollectionService
local Players = Services.Players
local LP      = Services.LocalPlayer

local Weapons = {}

Weapons.LastStabPath = nil

local function backpack()
    return LP:FindFirstChildOfClass("Backpack")
end

local function searchFor(container, tag)
    if not container then return nil end
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("Tool") and CS:HasTag(child, tag) then
            return child
        end
    end
    return nil
end

function Weapons.Get(tag)
    return searchFor(Util.Character(), tag) or searchFor(backpack(), tag)
end

function Weapons.Knife()

    local containers = {}
    local char, bag = Util.Character(), backpack()
    if char then table.insert(containers, char) end
    if bag then table.insert(containers, bag) end

    for _, container in ipairs(containers) do
        if container then
            for _, tool in ipairs(container:GetChildren()) do
                if tool:IsA("Tool") then
                    local events = tool:FindFirstChild("Events")
                    if events
                        and events:FindFirstChild("KnifeStabbed")
                        and events:FindFirstChild("HandleTouched")
                    then
                        return tool
                    end
                end
            end
        end
    end

    return Weapons.Get("Weapon_Knife")
        or (Util.Character() and Util.Character():FindFirstChild("Knife"))
        or (backpack() and backpack():FindFirstChild("Knife"))
end

function Weapons.Gun()
    return Weapons.Get("Weapon_Gun")
        or (Util.Character() and Util.Character():FindFirstChild("Gun"))
        or (backpack() and backpack():FindFirstChild("Gun"))
end

function Weapons.Equipped(tag)
    return searchFor(Util.Character(), tag)
end

function Weapons.Equip(tool)
    if not tool then return false end
    if tool.Parent == Util.Character() then return true end

    local hum = Util.Humanoid()
    if not hum then return false end

    hum:EquipTool(tool)

    for _ = 1, 10 do
        if tool.Parent == Util.Character() then break end
        task.wait(0.015)
    end

    return tool.Parent == Util.Character()
end

function Weapons.KnifeEvents(knife)
    knife = knife or Weapons.Knife()
    if not knife then return nil, nil end

    local events = knife:FindFirstChild("Events")
    if not events then return nil, nil end

    return events:FindFirstChild("KnifeStabbed"), events:FindFirstChild("HandleTouched")
end

function Weapons.StabTarget(player)
    if not player then return false, "no target" end

    local char = player.Character
    if not char then return false, "target has no character" end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false, "target is dead" end

    local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
    if not root then return false, "target has no root part" end

    local knife = Weapons.Knife()
    if not knife then return false, "no knife" end
    Weapons.Equip(knife)

    local stabbed, touched = Weapons.KnifeEvents(knife)
    if not stabbed or not touched then
        return false, "knife has no Events.KnifeStabbed / HandleTouched"
    end

    local ok, err = pcall(function()
        stabbed:FireServer()
        task.wait(State.StabGap or 0.05)
        touched:FireServer(root)
    end)

    if not ok then return false, tostring(err) end

    Weapons.LastStabPath = "Events.KnifeStabbed + HandleTouched"
    return true
end

function Weapons.Stab()
    local knife = Weapons.Knife()
    if not knife then return false, "no knife" end
    Weapons.Equip(knife)

    local stabbed = (Weapons.KnifeEvents(knife))
    if stabbed then
        stabbed:FireServer()
        return true
    end

    knife:Activate()
    return true
end

function Weapons.ThrowKnife()
    local service = Services.WeaponService
    if not service or type(service.ThrowKnife) ~= "function" then
        return false, "WeaponService has no ThrowKnife"
    end

    local knife = Weapons.Knife()
    if not knife then return false, "no knife" end
    Weapons.Equip(knife)

    local ok, err = pcall(function() service:ThrowKnife() end)
    if not ok then return false, tostring(err) end
    return true
end

function Weapons.ShootRemote()
    local gun = Weapons.Gun()
    if not gun then return nil end
    return gun:FindFirstChild("Shoot", true)
end

function Weapons.ShootOrigin()
    local hrp = Util.HRP()
    if not hrp then return nil end
    local att = hrp:FindFirstChild("GunRaycastAttachment")
    if att then
        local ok, cf = pcall(function() return att.WorldCFrame end)
        if ok and typeof(cf) == "CFrame" then return cf end
    end
    return CFrame.new(hrp.Position)
end

function Weapons.CanShoot()
    local char = Util.Character()
    if not char then return false end
    for _, d in ipairs(char:GetDescendants()) do
        if d.Name == "CantShoot" and d:IsA("BoolValue") and d.Value == true then return false end
    end
    return true
end

function Weapons.ShootAtCFrame(cf)
    if not cf then return false, "no target" end

    local gun = Weapons.Gun()
    if not gun then return false, "no gun" end

    Weapons.Equip(gun)

    local remote = Weapons.ShootRemote()
    if not remote then return false, "gun has no Shoot remote" end

    local origin = Weapons.ShootOrigin()
    if not origin then return false, "no character" end

    local ok, err = pcall(function()
        remote:FireServer(origin, CFrame.new(cf.Position))
    end)

    if not ok then return false, tostring(err) end
    return true
end

function Weapons.ShootAt(part)
    if not part then return false, "no target" end
    return Weapons.ShootAtCFrame(part.CFrame)
end

function Weapons.Shoot()
    local gun = Weapons.Gun()
    if not gun then return false, "no gun" end
    if not Weapons.Equip(gun) then return false, "could not equip" end
    gun:Activate()
    return true
end

function Weapons.Describe()
    local knife = Weapons.Knife()
    local gun = Weapons.Gun()
    local lines = {}

    if knife then
        table.insert(lines, "Knife tool: " .. knife.Name)
        for _, child in ipairs(knife:GetChildren()) do
            table.insert(lines, ("  %s : %s"):format(child.Name, child.ClassName))
        end
        local stabbed, touched = Weapons.KnifeEvents(knife)
        table.insert(lines, "  KnifeStabbed: " .. (stabbed and "found" or "MISSING"))
        table.insert(lines, "  HandleTouched: " .. (touched and "found" or "MISSING"))
    else
        table.insert(lines, "No knife tool found.")
    end

    if gun then
        table.insert(lines, "Gun tool: " .. gun.Name)
        local remote = Weapons.ShootRemote()
        table.insert(lines, "  Shoot remote: " .. (remote and remote:GetFullName() or "MISSING"))
    else
        table.insert(lines, "No gun tool found.")
    end

    table.insert(lines, "Last stab path: " .. tostring(Weapons.LastStabPath or "none yet"))

    local text = table.concat(lines, "\n")
    print("[Riftware] " .. text)
    return text
end

return Weapons
end

__modules["core/Webhook"] = function(import)

local Services = import("core/Services")

local HttpService = Services.HttpService

local Webhook = {}

local rarityColor = {
    Common    = 0x9CA3AF,
    Uncommon  = 0x22C55E,
    Rare      = 0x3B82F6,
    Legendary = 0xA855F7,
    Godly     = 0xEF4444,
    Unique    = 0xF59E0B,
    Vintage   = 0xEAB308,
    Chroma    = 0xEC4899,
}

local function requestFn()
    if syn and syn.request then return syn.request end
    if http and http.request then return http.request end
    if http_request then return http_request end
    if request then return request end
    if fluxus and fluxus.request then return fluxus.request end
    return nil
end

function Webhook.Available()
    return requestFn() ~= nil
end

function Webhook.Post(url, payload)
    if type(url) ~= "string" or not url:match("^https://") then
        return false, "webhook url is empty or not https"
    end

    local send = requestFn()
    if not send then
        return false, "executor exposes no http request function"
    end

    local body
    local ok, err = pcall(function()
        body = HttpService:JSONEncode(payload)
    end)
    if not ok then return false, "encode failed: " .. tostring(err) end

    local sent, sendErr = pcall(send, {
        Url = url,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = body,
    })

    if not sent then return false, tostring(sendErr) end
    return true
end

function Webhook.AssetThumbnail(image)
    if type(image) ~= "string" then return nil end

    local id = image:match("assetId=(%d+)")
        or image:match("[%?&]id=(%d+)")
        or image:match("rbxassetid://(%d+)")
        or image:match("rbxthumb://.-id=(%d+)")
        or image:match("^%s*(%d+)%s*$")

    if not id then return nil end

    return ("https://www.roblox.com/asset-thumbnail/image?assetId=%s&width=420&height=420&format=png")
        :format(id)
end

function Webhook.LogUnbox(url, info)
    local color = rarityColor[info.rarity or ""] or 0x5865F2

    local fields = {
        { name = "Box",    value = tostring(info.boxName or info.boxId or "?"), inline = true },
        { name = "Item",   value = tostring(info.itemName or info.itemId or "?"), inline = true },
        { name = "Rarity", value = tostring(info.rarity or "?"), inline = true },
    }

    if info.currency then
        table.insert(fields, { name = "Paid With", value = tostring(info.currency), inline = true })
    end
    if info.opened then
        table.insert(fields, { name = "Opened This Session", value = tostring(info.opened), inline = true })
    end

    local embed = {
        title = "Box Opened",
        color = color,
        fields = fields,
        footer = { text = tostring(info.player or Services.LocalPlayer.Name) },
        timestamp = DateTime.now():ToIsoDate(),
    }

    local thumbnail = Webhook.AssetThumbnail(info.image)
    if thumbnail then
        embed.thumbnail = { url = thumbnail }
    end

    return Webhook.Post(url, {
        username = "Riftware",
        embeds = { embed },
    })
end

return Webhook
end

__modules["core/Service"] = function(import)

local Services = import("core/Services")

local Service = {}

local BASE = "https://rift-onoff-yutm.vercel.app/api"

local function requester()
    if type(request) == "function" then return request end
    if type(http_request) == "function" then return http_request end
    if syn and type(syn.request) == "function" then return syn.request end
    if http and type(http.request) == "function" then return http.request end
    if fluxus and type(fluxus.request) == "function" then return fluxus.request end
    return nil
end

function Service.CountExecute()
    local req = requester()
    if not req then return end
    task.spawn(function()
        pcall(req, {
            Url = BASE .. "/executes",
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = "{}",
        })
    end)
end

function Service.Online()
    local body
    local req = requester()
    if req then
        local ok, res = pcall(req, { Url = BASE .. "/status", Method = "GET" })
        if ok and type(res) == "table" then body = res.Body end
    end
    if type(body) ~= "string" then
        local ok, res = pcall(function() return game:HttpGet(BASE .. "/status") end)
        if ok then body = res end
    end
    if type(body) ~= "string" then return false end

    local ok, data = pcall(function() return Services.HttpService:JSONDecode(body) end)
    return ok and type(data) == "table" and data.online == true
end

function Service.NotifyOffline()
    print("[Riftware] service off")
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Riftware",
            Text = "Service is offline right now.",
            Duration = 6,
        })
    end)
end

return Service
end

__modules["features/SilentAim"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")
local Roles    = import("core/Roles")
local Weapons  = import("core/Weapons")
local Assassin = import("features/Assassin")

local Players    = Services.Players
local RunService = Services.RunService
local CS         = Services.CollectionService
local LP         = Services.LocalPlayer

local SilentAim = {}

local WeaponService = Services.WeaponService

SilentAim.INTERP   = 0.05
SilentAim.MAX_VEL  = 60
SilentAim.Modes    = { "Closest to Crosshair", "Closest to Me", "Lowest Health" }

local PART_ORDER = {
    Head             = { "Head", "UpperTorso", "HumanoidRootPart", "Torso" },
    Torso            = { "UpperTorso", "HumanoidRootPart", "Torso", "Head" },
    UpperTorso       = { "UpperTorso", "HumanoidRootPart", "Torso", "Head" },
    HumanoidRootPart = { "HumanoidRootPart", "UpperTorso", "Torso", "Head", "LowerTorso" },
}

local smoothPing = nil
local tracks = setmetatable({}, { __mode = "k" })

local function capVel(v)
    local m = v.Magnitude
    if m > SilentAim.MAX_VEL then return v * (SilentAim.MAX_VEL / m) end
    return v
end

function SilentAim.PingSeconds()
    if smoothPing then return smoothPing end
    local p = 0
    pcall(function() p = LP:GetNetworkPing() end)
    if p > 0 then return p end

    local ok, ms = pcall(function()
        return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    if ok and type(ms) == "number" and ms > 0 then return ms / 2000 end
    return 0.05
end

SilentAim.Ping = SilentAim.PingSeconds

function SilentAim.Lead(scale)
    local t = SilentAim.PingSeconds() * 2 + SilentAim.INTERP
    return math.clamp(t * (scale or 1), 0.04, 0.45)
end

function SilentAim.Velocity(player)
    local t = tracks[player]
    if t and t.vel then return t.vel end
    local hrp = Util.HRP(player)
    return hrp and capVel(hrp.AssemblyLinearVelocity) or Vector3.new(0, 0, 0)
end

local function track(dt)
    if dt <= 0 then return end
    local now = os.clock()
    local ok, p = pcall(LP.GetNetworkPing, LP)
    if ok and type(p) == "number" and p > 0 then
        smoothPing = smoothPing and (smoothPing + (p - smoothPing) * (1 - math.exp(-2 * dt))) or p
    end
    local blend = 1 - math.exp(-25 * dt)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local hrp = Util.HRP(plr)
            local t = tracks[plr]
            if not hrp then
                tracks[plr] = nil
            elseif not t or t.hrp ~= hrp then
                tracks[plr] = { hrp = hrp, pos = hrp.Position, at = now, vel = capVel(hrp.AssemblyLinearVelocity) }
            else
                local v = hrp.AssemblyLinearVelocity
                local moved = hrp.Position - t.pos
                local elapsed = now - t.at
                if moved.Magnitude > 1e-3 and elapsed > 0 then
                    v = (v + moved / elapsed) * 0.5
                    t.pos, t.at = hrp.Position, now
                end
                t.vel = t.vel:Lerp(capVel(v), blend)
            end
        end
    end
end

SilentAim.Track = track

local passthrough, passthroughAt = {}, -math.huge
local function passthroughParts()
    if os.clock() - passthroughAt > 2 then
        passthroughAt = os.clock()
        local ok, list = pcall(function() return CS:GetTagged("WeaponPassthrough") end)
        passthrough = ok and list or {}
    end
    return passthrough
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
pcall(function() rayParams.IgnoreWater = true end)

function SilentAim.Blocked(from, to, ignore)
    local skip = {}
    local me = Util.Character()
    if me then table.insert(skip, me) end
    if ignore then table.insert(skip, ignore) end
    for _, p in ipairs(passthroughParts()) do table.insert(skip, p) end
    rayParams.FilterDescendantsInstances = skip

    local dir = to - from
    for _ = 1, 8 do
        local hit = workspace:Raycast(from, dir, rayParams)
        if not hit then return nil end
        local inst = hit.Instance
        if not inst or inst.Transparency ~= 1 then return hit end
        table.insert(skip, inst)
        rayParams.FilterDescendantsInstances = skip
    end
    return nil
end

local floorParams = RaycastParams.new()
floorParams.FilterType = Enum.RaycastFilterType.Exclude

local function airborne(hum, root)
    local state = hum and hum:GetState()
    return state == Enum.HumanoidStateType.Freefall
        or state == Enum.HumanoidStateType.Jumping
        or (root and math.abs(root.AssemblyLinearVelocity.Y) > 3)
end

SilentAim.Airborne = function(part)
    local model = part and part.Parent
    return airborne(model and model:FindFirstChildOfClass("Humanoid"), part)
end

function SilentAim.Predict(player, point, t)
    local char = player and player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not (root and hum) then return point end

    local vel = SilentAim.Velocity(player)
    local lead = State.LeadPrediction ~= false and t * (State.PredictionMult or 1) or 0
    local x = point.X + vel.X * lead
    local z = point.Z + vel.Z * lead
    local y = point.Y

    if State.JumpPrediction ~= false and airborne(hum, root) then
        local jt = t * (State.JumpPredictionMult or 1)
        y = point.Y + vel.Y * jt - 0.5 * workspace.Gravity * jt * jt

        floorParams.FilterDescendantsInstances = { char, Util.Character() }
        local floor = workspace:Raycast(root.Position, Vector3.new(0, -60, 0), floorParams)
        if floor then
            y = math.max(y, floor.Position.Y + 2.8 + (point.Y - root.Position.Y))
        end
    end
    return Vector3.new(x, y, z)
end

function SilentAim.Intercept(origin, pos, vel, speed)
    local d = pos - origin
    local a = vel:Dot(vel) - speed * speed
    local b = 2 * vel:Dot(d)
    local c = d:Dot(d)
    if math.abs(a) < 1e-6 then
        if math.abs(b) < 1e-6 then return nil end
        local t = -c / b
        return t > 0 and t or nil
    end
    local disc = b * b - 4 * a * c
    if disc < 0 then return nil end
    local s = math.sqrt(disc)
    local t1, t2 = (-b - s) / (2 * a), (-b + s) / (2 * a)
    local best
    if t1 > 0 then best = t1 end
    if t2 > 0 and (not best or t2 < best) then best = t2 end
    return best
end

SilentAim.LearnedKnifeSpeed = nil

function SilentAim.KnifeSpeed()
    if SilentAim.LearnedKnifeSpeed then return SilentAim.LearnedKnifeSpeed end
    if State.KnifeSpeedEnabled and type(State.KnifeThrowSpeed) == "number" and State.KnifeThrowSpeed > 0 then
        return State.KnifeThrowSpeed
    end
    return 96
end

local function originFor(knife)
    if knife then
        local k = Weapons.Knife()
        local handle = k and k:FindFirstChild("Handle")
        if handle then return handle.Position end
    end
    local hrp = Util.HRP()
    local att = hrp and hrp:FindFirstChild("GunRaycastAttachment")
    if att then return att.WorldCFrame.Position end
    return hrp and hrp.Position or nil
end

SilentAim.Origin = originFor

function SilentAim.ShotPoint(player, origin, opts)
    opts = opts or {}
    local char = player and player.Character
    if not (char and origin) then return nil, "no target" end

    local order = opts.order or PART_ORDER[State.AimPart or "HumanoidRootPart"] or PART_ORDER.HumanoidRootPart
    local first, visible
    for _, name in ipairs(order) do
        local part = char:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            first = first or part
            if not SilentAim.Blocked(origin, part.Position, char) then
                visible = part
                break
            end
        end
    end
    if not visible then
        if opts.wallCheck or not first then return nil, "behind cover" end
        visible = first
    end

    local at = visible.Position
    local t = SilentAim.Lead(opts.scale or 1)
    if opts.knife then
        local speed = opts.speed or SilentAim.KnifeSpeed()
        local v = SilentAim.Velocity(player)
        local flat = Vector3.new(v.X, 0, v.Z)
        local ahead = at + flat * t
        local flight = SilentAim.Intercept(origin, ahead, flat, speed) or (ahead - origin).Magnitude / speed
        t = math.min(t + flight, 2)
    end

    local point = SilentAim.Predict(player, at, t)

    if (point - at).Magnitude > 0.05 and SilentAim.Blocked(origin, point, char) then
        local half = at:Lerp(point, 0.5)
        point = SilentAim.Blocked(origin, half, char) and at or half
    end
    return point, visible
end

local function alive(plr)
    if plr == LP or Roles.IsDead(plr) then return false end
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum ~= nil and hum.Health > 0 and char:FindFirstChild("HumanoidRootPart") ~= nil
end

local function angleTo(pos)
    local cam = workspace.CurrentCamera
    if not cam then return 180 end
    local d = pos - cam.CFrame.Position
    if d.Magnitude < 1e-3 then return 0 end
    return math.deg(math.acos(math.clamp(cam.CFrame.LookVector:Dot(d.Unit), -1, 1)))
end

SilentAim.AngleTo = angleTo

local function inReach(plr, origin)
    local hrp = Util.HRP(plr)
    if not hrp then return false end
    local range = math.min(State.SilentMaxRange or 295, 295)
    if (hrp.Position - origin).Magnitude > range then return false end
    local fov = State.SilentFov or 0
    return fov <= 0 or angleTo(hrp.Position) <= fov
end

local function pick(list, origin)
    local mode = State.SilentMode or "Closest to Crosshair"
    local best, score
    for _, plr in ipairs(list) do
        if alive(plr) and inReach(plr, origin) then
            local hrp = Util.HRP(plr)
            local s
            if mode == "Closest to Me" then
                s = (hrp.Position - origin).Magnitude
            elseif mode == "Lowest Health" then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                s = hum and hum.Health or math.huge
            else
                s = angleTo(hrp.Position)
            end
            if not score or s < score then best, score = plr, s end
        end
    end
    return best
end

local function closest(list, origin)
    local best, bestD
    for _, plr in ipairs(list) do
        local hrp = Util.HRP(plr)
        if hrp and alive(plr) and inReach(plr, origin) then
            local d = (hrp.Position - origin).Magnitude
            if not bestD or d < bestD then best, bestD = plr, d end
        end
    end
    return best
end

SilentAim.Closest = closest

function SilentAim.InfectionTarget(knife, origin)
    if State.SilentZombies == false then return nil end
    local me = Roles.LocalRole()
    if me == "Zombie" then
        return closest(Roles.Survivors(), origin)
    end
    if me == "Survivor" or (not knife and #Roles.Zombies() > 0) then
        return closest(Roles.Zombies(), origin)
    end
    return nil
end

function SilentAim.AssassinTarget(origin)
    if State.SilentAssassin == false or not Assassin.Active() then return nil end
    local t = Assassin.Target()
    if t and alive(t) and inReach(t, origin) then return t end
    return nil
end

function SilentAim.TargetFor(knife, origin)
    local mine = SilentAim.AssassinTarget(origin)
    if mine then return mine end
    local infected = SilentAim.InfectionTarget(knife, origin)
    if infected then return infected end
    if not knife then
        local m = Roles.Murderer()
        return (m and alive(m) and inReach(m, origin)) and m or nil
    end
    if State.KnifeTargetHero ~= false then
        for _, plr in ipairs({ Roles.Sheriff(), Roles.Hero() }) do
            if plr and alive(plr) and inReach(plr, origin) then return plr end
        end
    end
    return pick(Players:GetPlayers(), origin)
end

SilentAim.Why = "no shot yet"

local function forced()
    return State.AutoShootMurderer or State.KillingMurderer or State.ShootingMurderer
end

local function resolveTarget()
    local char = Util.Character()
    if not char then SilentAim.Why = "no character" return nil end

    local gun, knife = Weapons.Gun(), Weapons.Knife()
    local gunOut = gun ~= nil and gun.Parent == char
    local knifeOut = knife ~= nil and knife.Parent == char

    local throwAt = knifeOut and State.ThrowTarget or nil
    if throwAt and not alive(throwAt) then throwAt = nil end

    local useKnife
    if throwAt then
        useKnife = true
    elseif gunOut and (State.SilentGun or forced()) then
        useKnife = false
    elseif knifeOut and State.SilentKnife then
        useKnife = true
    else
        return nil
    end

    local human = not forced() and not throwAt
    if human and (State.SilentChance or 100) < 100 and math.random(100) > State.SilentChance then
        SilentAim.Why = "let this one miss (hit chance)"
        return nil
    end

    local origin = originFor(useKnife)
    if not origin then SilentAim.Why = "no origin" return nil end
    local target = throwAt or SilentAim.TargetFor(useKnife, origin)
    if not target then
        SilentAim.Why = (State.SilentFov or 0) > 0 and "nobody inside the FOV" or "no target"
        return nil
    end

    local point, why = SilentAim.ShotPoint(target, origin, {
        knife = useKnife,
        scale = State.SilentPredict or 1,
        wallCheck = human and State.SilentWallCheck,
    })
    if not point then SilentAim.Why = "target " .. tostring(why) return nil end

    local j = human and (State.SilentJitter or 0) or 0
    if j > 0 then
        point = point + Vector3.new((math.random() - 0.5) * 2 * j, (math.random() - 0.5) * 2 * j, (math.random() - 0.5) * 2 * j)
    end
    SilentAim.Why = "redirected to " .. target.Name .. (useKnife and " (knife)" or "")
    return point
end

SilentAim.Resolve = resolveTarget

function SilentAim.GunTarget()
    local murderer = Roles.Murderer()
    if not murderer then return nil end
    return Util.AimPart(murderer, State.AimPart)
end

function SilentAim.GunAimAt(part)
    local model = part and part.Parent
    local plr = model and Players:GetPlayerFromCharacter(model)
    if not plr then return part.CFrame end
    return CFrame.new(SilentAim.Predict(plr, part.Position, SilentAim.Lead(State.SilentPredict or 1)))
end

function SilentAim.GunAimCFrame()
    local murderer = Roles.Murderer()
    if not murderer then return nil end
    local origin = originFor(false)
    local point = origin and SilentAim.ShotPoint(murderer, origin, { scale = State.SilentPredict or 1 })
    if point then return CFrame.new(point) end
    local part = SilentAim.GunTarget()
    return part and part.CFrame or nil
end

local NAMES = { "GetMouseTargetCFrame", "GetTargetPosition" }
local originals, wrappers = {}, setmetatable({}, { __mode = "k" })
local hooked = false
local cacheAt, cached = -math.huge, nil

SilentAim.Calls = 0
SilentAim.Hits = 0
SilentAim.LastSource = "never called"

local function answer()
    local now = os.clock()

    if now - cacheAt < 0.03 then return cached end
    SilentAim.Calls = SilentAim.Calls + 1
    local ok, pos = pcall(resolveTarget)
    if not ok then SilentAim.Why = tostring(pos) pos = nil end
    cacheAt, cached = now, pos
    if pos then SilentAim.Hits = SilentAim.Hits + 1 end
    SilentAim.LastSource = pos and "silent" or "passthrough"
    return pos
end

function SilentAim.Flush()
    cacheAt, cached = -math.huge, nil
end

local function arm()
    if not WeaponService then return 0 end
    local n = 0
    for _, name in ipairs(NAMES) do
        local fn = rawget(WeaponService, name) or WeaponService[name]
        if type(fn) == "function" and not wrappers[fn] then
            originals[name] = fn
            local original = fn
            local wrapper = function(...)
                local pos = answer()
                if pos then return CFrame.new(pos) end
                return original(...)
            end
            wrappers[wrapper] = true
            WeaponService[name] = wrapper
            n = n + 1
        end
    end
    return n
end

function SilentAim.Hook()
    if not WeaponService then return false end
    if hooked then return true end
    local n = arm()
    if n == 0 and not originals[NAMES[1]] then
        SilentAim.Why = "neither aim function was where it should be"
        return false
    end
    hooked = true
    SilentAim.Why = "armed (" .. n .. " aim paths hooked)"
    local checkedAt = os.clock()
    Util.Bind("silentaimtrack", RunService.Heartbeat, function(dt)
        track(dt)

        if os.clock() - checkedAt > 2 then
            checkedAt = os.clock()
            local again = arm()
            if again > 0 then SilentAim.Why = "re-armed (" .. again .. " path(s) had been replaced)" end
        end
    end)

    pcall(function()
        Util.Bind("silentaimknife", CS:GetInstanceAddedSignal("ThrowingKnife"), function(knife)
            task.spawn(function()
                local link = knife:WaitForChild("HandleLink", 2)
                local handle = link and link.Value
                local speed = tonumber(knife:GetAttribute("ThrowSpeed"))
                local me = Util.Character()
                if speed and speed > 10 and handle and me and handle:IsDescendantOf(me) then
                    SilentAim.LearnedKnifeSpeed = speed
                end
            end)
        end)
    end)
    return true
end

function SilentAim.Unhook()
    if not WeaponService then return end
    for _, name in ipairs(NAMES) do
        local current = WeaponService[name]
        if wrappers[current] and originals[name] then WeaponService[name] = originals[name] end
    end
    Util.Unbind("silentaimtrack")
    Util.Unbind("silentaimknife")
    hooked = false
end

function SilentAim.Hooked()
    return hooked
end

function SilentAim.Report()
    local text = table.concat({
        "Hooked: " .. tostring(hooked),
        "WeaponService found: " .. tostring(WeaponService ~= nil),
        "Aim queries: " .. SilentAim.Calls .. "  redirected: " .. SilentAim.Hits,
        "Last: " .. tostring(SilentAim.Why),
        ("Ping %.0fms  lead %.2fs  knife speed %d"):format(SilentAim.PingSeconds() * 1000, SilentAim.Lead(State.SilentPredict or 1), SilentAim.KnifeSpeed()),
    }, "\n")
    print("[Riftware] " .. text)
    return text
end

return SilentAim
end

__modules["features/KnifeSpeed"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")

local CS         = Services.CollectionService
local RunService = Services.RunService

local KnifeSpeed = {}

KnifeSpeed.Seen = 0

local function speed()
    local value = State.KnifeThrowSpeed
    if type(value) ~= "number" or value <= 0 then return 96 end
    return value
end

KnifeSpeed.Speed = speed

local function step()
    if not State.KnifeSpeedEnabled then return end

    local value = speed()

    for _, projectile in ipairs(CS:GetTagged("ThrowingKnife")) do
        if projectile.Parent then
            pcall(function()
                projectile:SetAttribute("ThrowSpeed", value)

                local visual = projectile:FindFirstChild("KnifeVisual")
                if visual then
                    visual:SetAttribute("ThrowSpeed", value)
                end
            end)
        end
    end
end

local function onAdded(projectile)
    KnifeSpeed.Seen = KnifeSpeed.Seen + 1
    if not State.KnifeSpeedEnabled then return end
    pcall(function()
        projectile:SetAttribute("ThrowSpeed", speed())
    end)
end

function KnifeSpeed.Set(on)
    State.KnifeSpeedEnabled = on

    if on then
        Util.Bind("knifespeed", RunService.PreSimulation, step)
        Util.Bind("knifespeedadd", CS:GetInstanceAddedSignal("ThrowingKnife"), onAdded)
    else
        Util.Unbind("knifespeed")
        Util.Unbind("knifespeedadd")
    end
end

function KnifeSpeed.Refresh()
    if not State.KnifeSpeedEnabled then return end
    step(0)
end

return KnifeSpeed
end

__modules["features/Melee"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")
local Roles    = import("core/Roles")
local Weapons  = import("core/Weapons")
local SilentAim = import("features/SilentAim")

local RunService = Services.RunService

local Melee = {}

local killing = false

local lastHit = {}

local function auraStep()
    if not State.KnifeAura then return end
    local knife = Weapons.Knife()
    if not knife then return end

    local hrp = Util.HRP()
    if not hrp then return end

    local radius = State.AuraRadius or 18
    local now = os.clock()

    for _, plr in ipairs(Roles.Everyone()) do
        local part = Util.AimPart(plr, "HumanoidRootPart")
        if part and (part.Position - hrp.Position).Magnitude <= radius then
            if not lastHit[plr] or now - lastHit[plr] >= (State.AuraDelay or 0.15) then
                lastHit[plr] = now
                Weapons.StabTarget(plr)

                break
            end
        end
    end
end

function Melee.SetAura(on)
    State.KnifeAura = on
    if on then
        Util.Bind("aura", RunService.Heartbeat, auraStep)
    else
        Util.Unbind("aura")
        lastHit = {}
    end
end

function Melee.KillAll()
    if killing then return false, "already running" end

    local knife = Weapons.Knife()
    if not knife then
        Util.Notify("Kill All", "You have no knife.")
        return false, "no knife"
    end

    local stabbed, touched = Weapons.KnifeEvents(knife)
    if not stabbed or not touched then
        Util.Notify("Kill All", "Knife has no Events pair -- run Inspect Knife Tool.")
        return false, "no KnifeStabbed / HandleTouched"
    end

    killing = true
    Weapons.Equip(knife)

    local targets = Roles.Everyone()

    task.spawn(function()
        local sent, failed = 0, nil

        for _, plr in ipairs(targets) do
            if not killing then break end

            local ok, err = Weapons.StabTarget(plr)
            if ok then
                sent = sent + 1
            else
                failed = err
            end

            task.wait(State.KillAllStep or 0.08)
        end

        killing = false

        if sent == 0 then
            Util.Notify("Kill All", "Nothing sent: " .. tostring(failed))
        else
            Util.Notify("Kill All", ("Sent %d stab call%s."):format(sent, sent == 1 and "" or "s"))
        end
    end)

    return true
end

function Melee.StopKillAll()
    killing = false
end

function Melee.IsKilling()
    return killing
end

function Melee.ThrowTarget()
    local function up(plr) return plr and Util.Alive(plr) and not Roles.IsDead(plr) end
    local sheriff = Roles.Sheriff()
    if up(sheriff) then return sheriff end
    local hero = Roles.Hero()
    if up(hero) then return hero end
    return (Util.Closest(up))
end

function Melee.ThrowKnife()
    if not Weapons.Knife() then return false, "you don't have the knife" end
    local target = Melee.ThrowTarget()
    if not target then return false, "nobody to throw at" end

    State.ThrowTarget = target
    pcall(SilentAim.Hook)
    pcall(SilentAim.Flush)
    local ok, err = Weapons.ThrowKnife()
    task.delay(0.5, function()
        if State.ThrowTarget == target then State.ThrowTarget = nil end
    end)

    if not ok then return false, tostring(err) end
    return true, "threw at " .. (target.DisplayName or target.Name)
end

function Melee.SetAutoThrow(on)
    State.AutoThrowKnife = on

    if on then
        Util.Loop("autothrow", function()
            return State.ThrowDelay or 0.6
        end, function()
            if not State.AutoThrowKnife then return end
            if not Weapons.Knife() then return end

            local target = Roles.Sheriff()
            if not target and State.KnifeTargetHero then target = Roles.Hero() end
            if not target then
                target = Util.Closest(function(plr) return not Roles.IsDead(plr) end)
            end
            if not target then return end

            local ok, err = Weapons.ThrowKnife()
            if not ok then
                Util.Notify("Auto Throw", "Stopped: " .. tostring(err))
                State.AutoThrowKnife = false
                Util.Unbind("autothrow")
            end
        end)
    else
        Util.Unbind("autothrow")
    end
end

function Melee.SetAutoKillAll(on)
    State.AutoKillAll = on
    if on then
        Util.Loop("autokillall", function()
            return State.KillAllDelay or 3
        end, function()
            if State.AutoKillAll and not killing then
                Melee.KillAll()
            end
        end)
    else
        Util.Unbind("autokillall")
    end
end

return Melee
end

__modules["features/Hitbox"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")
local Roles    = import("core/Roles")
local Weapons  = import("core/Weapons")

local Players = Services.Players
local LP      = Services.LocalPlayer

local Hitbox = {}

Hitbox.Hits = 0
Hitbox.Modes = { "Everyone", "Sheriff / Hero only", "Innocents only" }

local originals = setmetatable({}, { __mode = "k" })

local function wanted(player)
    local mode = State.HitboxMode or "Everyone"
    local role = Roles.Of(player)
    if mode == "Sheriff / Hero only" then return role == "Sheriff" or role == "Hero" end
    if mode == "Innocents only" then
        return role ~= "Sheriff" and role ~= "Hero" and role ~= "Murderer"
    end
    return true
end

local function rootOf(player)
    local char = player.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function remember(part)
    if originals[part] ~= nil then return end
    originals[part] = {
        size = part.Size,
        transparency = part.Transparency,
        canCollide = part.CanCollide,
        canTouch = part.CanTouch,
        massless = part.Massless,
        material = part.Material,
        color = part.Color,
    }
end

local function restore(part)
    local saved = originals[part]
    if not saved then return end
    originals[part] = nil
    if not part.Parent then return end

    pcall(function()
        part.Size = saved.size
        part.Transparency = saved.transparency
        part.CanCollide = saved.canCollide
        part.CanTouch = saved.canTouch
        part.Massless = saved.massless
        part.Material = saved.material
        part.Color = saved.color
    end)
end

local function expand(part)
    remember(part)
    local size = State.HitboxSize or 12

    pcall(function()
        part.Size = Vector3.new(size, size, size)
        part.CanTouch = true
        part.Massless = true
        part.CanCollide = false

        if State.HitboxVisible then
            part.Transparency = 0.75
            part.Material = Enum.Material.ForceField
            part.Color = Color3.fromRGB(226, 231, 240)
        else
            part.Transparency = 1
        end
    end)
end

function Hitbox.RestoreAll()
    for part in pairs(originals) do restore(part) end
end

local function step()
    if not State.HitboxEnabled then return end

    if not Weapons.Knife() then
        Hitbox.RestoreAll()
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP then
            local root = rootOf(player)
            if root then
                if wanted(player) and not Roles.IsDead(player) then
                    expand(root)
                else
                    restore(root)
                end
            end
        end
    end
end

local function forceTouchStep()
    if not State.HitboxForceTouch or not firetouchinterest then return end

    local knife = Weapons.Knife()
    if not knife or knife.Parent ~= Util.Character() then return end

    local handle = knife:FindFirstChild("Handle")
    local hrp = Util.HRP()
    if not handle or not hrp then return end

    local radius = State.HitboxTouchRange or 25

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP and wanted(player) and not Roles.IsDead(player) then
            local root = rootOf(player)
            if root and (root.Position - hrp.Position).Magnitude <= radius then
                local ok = pcall(function()
                    firetouchinterest(handle, root, 0)
                    firetouchinterest(handle, root, 1)
                end)
                if ok then Hitbox.Hits = Hitbox.Hits + 1 end
            end
        end
    end
end

function Hitbox.SetForceTouch(on)
    State.HitboxForceTouch = on
    if on then
        if not firetouchinterest then
            Util.Notify("Hitbox", "Your executor has no firetouchinterest.")
            return
        end
        Util.Loop("hitboxtouch", function() return State.HitboxTouchDelay or 0.2 end, forceTouchStep)
    else
        Util.Unbind("hitboxtouch")
    end
end

function Hitbox.Refresh()
    if not State.HitboxEnabled then return end
    Hitbox.RestoreAll()
    step()
end

function Hitbox.Set(on)
    State.HitboxEnabled = on
    if on then

        Util.Loop("hitbox", function() return 0.3 end, step)
    else
        Util.Unbind("hitbox")
        Hitbox.RestoreAll()
    end
end

return Hitbox
end

__modules["features/Guns"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")
local Roles    = import("core/Roles")
local Weapons  = import("core/Weapons")
local SilentAim = import("features/SilentAim")

local CS      = Services.CollectionService
local Players = Services.Players

local Guns = {}

local warnedAt = 0

local function shootStep()
    if not State.AutoShootMurderer then return end

    local murderer = Roles.Murderer()
    if not murderer or not Util.Alive(murderer) then return end

    local gun = Weapons.Gun()
    if not gun then return end

    local cf = SilentAim.GunAimCFrame()
    if not cf then return end

    local ok, err = Weapons.ShootAtCFrame(cf)
    if not ok and os.clock() - warnedAt > 8 then
        warnedAt = os.clock()
        Util.Notify("Auto Shoot", tostring(err))
    end
end

function Guns.SetAutoShoot(on)
    State.AutoShootMurderer = on
    if on then
        Util.Loop("autoshoot", function()
            return State.ShootDelay or 0.35
        end, shootStep)
    else
        Util.Unbind("autoshoot")
    end
end

local UIS = Services.UserInputService

local TRIGGER_PARTS = { "Head", "UpperTorso", "Torso", "HumanoidRootPart" }

local triggerParams = RaycastParams.new()
triggerParams.FilterType = Enum.RaycastFilterType.Exclude

local lastTrigger = 0
local onTargetSince = nil

local function aimPoint()
    local camera = workspace.CurrentCamera
    local size = camera.ViewportSize
    local centre = Vector2.new(size.X / 2, size.Y / 2)

    if UIS.TouchEnabled and not UIS.MouseEnabled then return centre end

    local service = Services.WeaponService
    local locked = false
    if service and service.IsMouseLockEnabled then
        local ok, result = pcall(function() return service:IsMouseLockEnabled() end)
        locked = ok and result == true
    end
    if locked then return centre end

    return UIS:GetMouseLocation()
end

local function visible(camera, part, targetChar)
    local origin = camera.CFrame.Position
    local myChar = Util.Character()
    triggerParams.FilterDescendantsInstances = myChar and { myChar } or {}
    local hit = workspace:Raycast(origin, part.Position - origin, triggerParams)
    return not hit or hit.Instance:IsDescendantOf(targetChar)
end

local function onTarget(murderer)
    local char = murderer.Character
    if not char then return false end

    local camera = workspace.CurrentCamera
    if not camera then return false end

    local aim = aimPoint()
    local fov = State.TriggerFov or 60

    local function inside(worldPos)
        local screen, onScreen = camera:WorldToViewportPoint(worldPos)
        if not onScreen or screen.Z <= 0 then return false end
        return (Vector2.new(screen.X, screen.Y) - aim).Magnitude <= fov
    end

    local predicted = SilentAim.GunAimCFrame()
    local root = char:FindFirstChild("HumanoidRootPart")
    if predicted and root and inside(predicted.Position)
        and (not State.TriggerVisibleOnly or visible(camera, root, char))
    then
        return true
    end

    for _, name in ipairs(TRIGGER_PARTS) do
        local part = char:FindFirstChild(name)
        if part and part:IsA("BasePart") and inside(part.Position)
            and (not State.TriggerVisibleOnly or visible(camera, part, char))
        then
            return true
        end
    end
    return false
end

Guns.AimPoint = aimPoint

Guns.TriggerOnTarget = onTarget

local function triggerStep()
    if not State.Triggerbot then return end

    local murderer = Roles.Murderer()
    if not murderer or murderer == Services.LocalPlayer or not Util.Alive(murderer) then
        onTargetSince = nil
        return
    end

    local gun = Weapons.Gun()
    if not gun then return end
    if State.TriggerNeedsEquip ~= false and gun.Parent ~= Util.Character() then
        onTargetSince = nil
        return
    end

    if not onTarget(murderer) then
        onTargetSince = nil
        return
    end

    local now = os.clock()
    onTargetSince = onTargetSince or now

    if now - onTargetSince < (State.TriggerDelay or 0.05) then return end
    if now - lastTrigger < (State.TriggerCooldown or 0.25) then return end

    local cf = SilentAim.GunAimCFrame()
    if not cf then return end

    lastTrigger = now
    local ok, err = Weapons.ShootAtCFrame(cf)
    if not ok and now - warnedAt > 8 then
        warnedAt = now
        Util.Notify("Triggerbot", tostring(err))
    end
end

Guns.TriggerStep = triggerStep

function Guns.SetTriggerbot(on)
    State.Triggerbot = on
    onTargetSince = nil
    if on then

        SilentAim.Hook()
        Util.Bind("triggerbot", Services.RunService.Heartbeat, triggerStep)
    else
        Util.Unbind("triggerbot")
    end
end

local fovGui, fovRing, fovStroke

local function guiParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    local ok2, core = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and core then return core end
    return Services.LocalPlayer:WaitForChild("PlayerGui")
end

local function buildRing()
    if fovGui and fovGui.Parent then return end
    fovGui = Instance.new("ScreenGui")
    fovGui.Name = "RiftwareFov"
    fovGui.IgnoreGuiInset = true
    fovGui.ResetOnSpawn = false
    fovGui.DisplayOrder = 999
    fovGui.Parent = guiParent()

    fovRing = Instance.new("Frame")
    fovRing.Name = "Ring"
    fovRing.AnchorPoint = Vector2.new(0.5, 0.5)
    fovRing.BackgroundTransparency = 1
    fovRing.BorderSizePixel = 0
    fovRing.Parent = fovGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = fovRing

    fovStroke = Instance.new("UIStroke")
    fovStroke.Thickness = 1.5
    fovStroke.Transparency = 0.15
    fovStroke.Color = Color3.fromRGB(184, 190, 202)
    fovStroke.Parent = fovRing
end

local STEEL = Color3.fromRGB(184, 190, 202)
local GLINT = Color3.fromRGB(248, 250, 255)

local function ringStep()
    if not State.TriggerShowFov or not fovRing then return end
    local fov = State.TriggerFov or 60
    local aim = aimPoint()
    fovRing.Size = UDim2.fromOffset(fov * 2, fov * 2)
    fovRing.Position = UDim2.fromOffset(aim.X, aim.Y)

    local murderer = Roles.Murderer()
    local hot = murderer and murderer ~= Services.LocalPlayer and Util.Alive(murderer) and onTarget(murderer)
    fovStroke.Color = hot and GLINT or STEEL
    fovStroke.Thickness = hot and 2 or 1.5
end

Guns.RingStep = ringStep

local function beforeRender()
    local rs = Services.RunService
    local ok, signal = pcall(function() return rs.RenderStepped end)
    if ok and signal then return signal end
    return rs.Heartbeat
end

function Guns.SetFovCircle(on)
    State.TriggerShowFov = on
    if on then
        buildRing()
        fovGui.Enabled = true
        Util.Bind("triggerfov", beforeRender(), ringStep)
        ringStep()
    else
        Util.Unbind("triggerfov")
        if fovGui then fovGui.Enabled = false end
    end
end

function Guns.DestroyFovCircle()
    Util.Unbind("triggerfov")
    if fovGui then pcall(function() fovGui:Destroy() end) end
    fovGui, fovRing, fovStroke = nil, nil, nil
end

local function isInsideSomeone(inst)
    local model = inst:FindFirstAncestorOfClass("Model")
    if not model then return false end
    if Players:GetPlayerFromCharacter(model) then return true end
    return false
end

function Guns.FindDropped()
    for _, tool in ipairs(CS:GetTagged("Weapon_Gun")) do
        if tool:IsA("Tool") and tool:IsDescendantOf(workspace) and not isInsideSomeone(tool) then
            local handle = tool:FindFirstChild("Handle")
            if handle then return tool, handle end
        end
    end

    for _, inst in ipairs(workspace:GetChildren()) do
        local name = inst.Name:lower()
        if name:find("gundrop") or name == "gun" then
            local handle = inst:IsA("BasePart") and inst or inst:FindFirstChild("Handle")
            if handle and not isInsideSomeone(handle) then return inst, handle end
        end
    end

    return nil, nil
end

local function getMap()
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:FindFirstChild("CoinContainer") and obj:FindFirstChild("Spawns") then
            return obj
        end
    end
    return nil
end

Guns.GetMap = getMap

function Guns.FindDroppedPart()
    local map = getMap()
    local drop = map and map:FindFirstChild("GunDrop")
    if drop and drop:IsA("BasePart") then return drop end

    local _, handle = Guns.FindDropped()
    return handle
end

function Guns.GrabDropped()
    local hrp = Util.HRP()
    if not hrp or not hrp.Parent then return false, "no character" end

    if not firetouchinterest then
        return false, "executor has no firetouchinterest"
    end

    local map = getMap()
    if not map then return false, "map not found" end

    local drop = map:FindFirstChild("GunDrop")
    if not drop or not drop:IsA("BasePart") then return false, "no gun on the floor" end

    local ok = pcall(function()
        firetouchinterest(drop, hrp, 1)
        firetouchinterest(drop, hrp, 0)
    end)

    return ok
end

local killing = false

local function murdererDown(murderer)
    if Roles.Murderer() ~= murderer then return true end
    if not Util.Alive(murderer) or Roles.IsDead(murderer) then return true end
    local char = murderer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum ~= nil and hum.Health <= 0
end

Guns.MurdererDown = murdererDown

local function stepBehind(me, them)
    local behind = (them.CFrame * CFrame.new(0, 0, State.KillMurdererDistance or 4)).Position
    Util.Teleport(CFrame.lookAt(behind, them.Position))
end

function Guns.KillMurderer()
    if killing then return false, "already on it" end
    if Roles.LocalIsMurderer() then return false, "you're the murderer" end

    local murderer = Roles.Murderer()
    if not murderer or not Util.Alive(murderer) then return false, "no murderer alive" end
    local gun = Weapons.Gun()
    if not gun then return false, "you don't have the gun" end

    local me = Util.HRP()
    if not (me and Util.HRP(murderer)) then return false, "no character" end

    killing = true
    State.KillingMurderer = true
    pcall(SilentAim.Hook)

    local home = me.CFrame
    local shots, dead = 0, false
    local maxShots = State.KillMurdererShots or 6
    local gap = State.KillMurdererGap or 1

    local ok, err = pcall(function()
        while shots < maxShots and not dead do
            local them = Util.HRP(murderer)
            if not them then dead = murdererDown(murderer) break end

            Weapons.Equip(gun)
            for _ = 1, 80 do
                if Weapons.CanShoot() or murdererDown(murderer) then break end
                task.wait(0.05)
                local t = Util.HRP(murderer)
                if t then them = t end
            end
            if murdererDown(murderer) then dead = true break end

            stepBehind(me, them)
            task.wait(0.06)

            local target = SilentAim.GunAimCFrame() or them.CFrame
            local fired, why = Weapons.ShootAtCFrame(target)
            if not fired then error(why, 0) end
            shots = shots + 1

            for _ = 1, math.max(1, math.ceil(gap / 0.05)) do
                if murdererDown(murderer) then dead = true break end
                task.wait(0.05)
                local t = Util.HRP(murderer)
                if t then stepBehind(me, t) end
            end
        end
    end)

    State.KillingMurderer = false
    if State.KillMurdererReturn ~= false then Util.Teleport(home) end
    killing = false

    if not ok then return false, tostring(err), shots end
    if not dead then return false, ("he survived %d shot%s"):format(shots, shots == 1 and "" or "s"), shots end
    return true, ("murderer down in %d shot%s"):format(shots, shots == 1 and "" or "s"), shots
end

function Guns.ShootMurderer()
    if Roles.LocalIsMurderer() then return false, "you're the murderer" end
    local murderer = Roles.Murderer()
    if not murderer or not Util.Alive(murderer) then return false, "no murderer alive" end
    if not Weapons.Gun() then return false, "you don't have the gun" end
    if not Weapons.CanShoot() then return false, "reloading" end

    local char = Util.Character(murderer)
    local hitbox = char and (char:FindFirstChild("HumanoidRootPart") or Util.AimPart(murderer, State.AimPart))
    if not hitbox then return false, "no hitbox" end

    State.ShootingMurderer = true
    pcall(SilentAim.Hook)
    local ok, err = Weapons.ShootAtCFrame(SilentAim.GunAimAt(hitbox))
    task.delay(0.3, function() State.ShootingMurderer = false end)

    if not ok then return false, tostring(err) end
    return true, "shot " .. (murderer.DisplayName or murderer.Name)
end

local retryAt = 0

local function autoKillStep()
    if not State.AutoKillMurderer or killing or os.clock() < retryAt then return end
    if Roles.LocalIsMurderer() then return end
    local murderer = Roles.Murderer()
    if not murderer or not Util.Alive(murderer) or murdererDown(murderer) then return end
    if not Weapons.Gun() then return end
    local ok, msg = Guns.KillMurderer()
    if ok then
        Util.Notify("Auto Kill Murderer", msg)
    elseif msg ~= "already on it" then
        retryAt = os.clock() + 3
    end
end

Guns.AutoKillStep = autoKillStep

function Guns.SetAutoKillMurderer(on)
    State.AutoKillMurderer = on
    retryAt = 0
    if on then
        Util.Loop("autokillmurderer", function() return 0.3 end, autoKillStep)
    else
        Util.Unbind("autokillmurderer")
    end
end

local DING = "rbxasset://sounds/electronicpingshort.wav"
local lastDrop = -math.huge
local dropSound

local function ding()
    pcall(function()
        if not dropSound or not dropSound.Parent then
            dropSound = Instance.new("Sound")
            dropSound.SoundId = DING
            dropSound.Volume = 0.8
            dropSound.Parent = Services.LocalPlayer:FindFirstChildOfClass("PlayerGui")
                or Services.LocalPlayer:WaitForChild("PlayerGui")
        end
        dropSound.PlaybackSpeed = 1.25
        dropSound:Play()
    end)
end

local function onDrop(part)
    if os.clock() - lastDrop < 3 then return end
    lastDrop = os.clock()
    local me = Util.HRP()
    local far = me and part:IsA("BasePart") and ("  (%dm away)"):format(math.floor((me.Position - part.Position).Magnitude)) or ""
    Util.Notify("Gun Dropped!", "The sheriff died -- the gun is on the floor." .. far)
    if State.GunDropSound ~= false then ding() end
end

local function onPickup()
    task.delay(0.6, function()
        if not State.GunDropNotify then return end
        local hero = Roles.Hero and Roles.Hero()
        if not hero then
            for _, plr in ipairs(Players:GetPlayers()) do
                local char = plr.Character
                if char and char:FindFirstChild("Gun") then hero = plr break end
            end
        end
        if hero then
            local who = hero == Services.LocalPlayer and "You" or (hero.DisplayName or hero.Name)
            Util.Notify("Gun Picked Up", who .. " has the gun now.")
        end
    end)
end

Guns.OnDrop, Guns.OnPickup = onDrop, onPickup

function Guns.SetGunDropNotify(on)
    State.GunDropNotify = on
    Util.Unbind("gundropadded")
    Util.Unbind("gundropremoved")
    if not on then return end
    Util.Bind("gundropadded", workspace.DescendantAdded, function(d)
        if d.Name == "GunDrop" then onDrop(d) end
    end)
    Util.Bind("gundropremoved", workspace.DescendantRemoving, function(d)
        if d.Name == "GunDrop" then onPickup() end
    end)
end

function Guns.SetAutoGrab(on)
    State.AutoGrabGun = on
    if on then
        Util.Loop("autograb", function() return 0.25 end, function()
            if State.AutoGrabGun then
                Guns.GrabDropped()
            end
        end)
    else
        Util.Unbind("autograb")
    end
end

return Guns
end

__modules["features/ShotTrace"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")
local Weapons  = import("core/Weapons")

local Players = Services.Players
local TweenService = Services.TweenService

local ShotTrace = {}

ShotTrace.Styles = { "Beam", "Laser", "Line" }
ShotTrace.Colors = {
    Green   = Color3.fromRGB(0, 255, 170),
    Red     = Color3.fromRGB(255, 60, 60),
    Blue    = Color3.fromRGB(70, 160, 255),
    Purple  = Color3.fromRGB(190, 90, 255),
    Yellow  = Color3.fromRGB(255, 220, 40),
    White   = Color3.fromRGB(255, 255, 255),
    Orange  = Color3.fromRGB(255, 130, 30),
    Pink    = Color3.fromRGB(255, 105, 200),
    Cyan    = Color3.fromRGB(40, 230, 255),
    Lime    = Color3.fromRGB(170, 255, 40),
    Crimson = Color3.fromRGB(200, 15, 50),
    Magenta = Color3.fromRGB(255, 40, 255),
    Gold    = Color3.fromRGB(255, 190, 60),
    Ice     = Color3.fromRGB(190, 235, 255),
}

local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end
ShotTrace.Gradients = {
    ["Halloween"]  = { rgb(255, 122, 26), rgb(255, 90, 0), rgb(139, 61, 255) },
    ["Candy Corn"] = { rgb(255, 245, 225), rgb(255, 200, 40), rgb(255, 110, 20) },
    ["Toxic"]      = { rgb(200, 255, 60), rgb(60, 255, 120), rgb(20, 140, 60) },
    ["Blood Moon"] = { rgb(255, 160, 60), rgb(220, 30, 40), rgb(90, 0, 20) },
    ["Phantom"]    = { rgb(235, 240, 255), rgb(150, 130, 255), rgb(60, 40, 140) },
    ["Rainbow"]    = { rgb(255, 60, 60), rgb(255, 200, 40), rgb(60, 255, 120), rgb(40, 200, 255), rgb(200, 80, 255) },
}

ShotTrace.ColorNames = {
    "Halloween", "Candy Corn", "Toxic", "Blood Moon", "Phantom", "Rainbow",
    "Green", "Red", "Blue", "Purple", "Yellow", "White",
    "Orange", "Pink", "Cyan", "Lime", "Crimson", "Magenta", "Gold", "Ice",
}

local HIT_RED = Color3.fromRGB(255, 70, 70)

local function color()
    if State.TraceColor then return State.TraceColor end
    local stops = ShotTrace.Gradients[State.TraceColorName or ""]
    if stops then return stops[1] end
    return ShotTrace.Colors[State.TraceColorName or "Green"] or ShotTrace.Colors.Green
end

local function gradient()
    if State.TraceColor then return nil end
    return ShotTrace.Gradients[State.TraceColorName or ""]
end

ShotTrace.Gradient = gradient

local function sequence(stops)
    local keys = {}
    for i, c in ipairs(stops) do
        keys[i] = ColorSequenceKeypoint.new((i - 1) / math.max(#stops - 1, 1), c)
    end
    return ColorSequence.new(keys)
end

local function fadeBeam(beam, life)
    local value = Instance.new("NumberValue")
    value.Value = 0
    pcall(function()
        value.Changed:Connect(function(v)
            beam.Transparency = NumberSequence.new(math.clamp(v, 0, 1))
        end)
        TweenService:Create(value, TweenInfo.new(life, Enum.EasingStyle.Quad), { Value = 1 }):Play()
    end)
    task.delay(life + 0.1, function() pcall(function() value:Destroy() end) end)
end

local function folder()
    local f = workspace:FindFirstChild("RiftwareTracers")
    if not f then
        f = Instance.new("Folder")
        f.Name = "RiftwareTracers"
        f.Parent = workspace
    end
    return f
end

local function fade(inst, life, goal)
    pcall(function() TweenService:Create(inst, TweenInfo.new(life, Enum.EasingStyle.Quad), goal):Play() end)
    task.delay(life + 0.1, function() pcall(function() inst:Destroy() end) end)
end

function ShotTrace.Draw(from, to, hitPlayer)
    if not State.ShotTrace then return nil end
    if typeof(from) ~= "Vector3" or typeof(to) ~= "Vector3" then return nil end
    local length = (to - from).Magnitude
    if length < 0.5 or length ~= length then return nil end

    local life = State.TraceLife or 2.5
    local thick = State.TraceThickness or 0.28
    local style = State.TraceStyle or "Beam"
    local tint = color()
    local stops = gradient()
    local mid = from:Lerp(to, 0.5)

    local bar = Instance.new("Part")
    bar.Name = "Tracer"
    bar.Anchored, bar.CanCollide = true, false
    pcall(function() bar.CanQuery = false end)
    pcall(function() bar.CanTouch = false end)
    bar.CastShadow = false
    bar.Material = Enum.Material.Neon
    bar.Color = tint
    bar.Transparency = 0.15
    if style == "Laser" then
        bar.Shape = Enum.PartType.Cylinder
        bar.Size = Vector3.new(length, thick, thick)
        bar.CFrame = CFrame.lookAt(mid, to) * CFrame.Angles(0, math.rad(90), 0)
    else
        bar.Shape = Enum.PartType.Block
        bar.Size = Vector3.new(thick, thick, length)
        bar.CFrame = CFrame.lookAt(mid, to)
    end
    bar.Parent = folder()

    if stops then

        bar.Transparency = 0.45
        local half = length / 2
        local muzzle, impact = Instance.new("Attachment"), Instance.new("Attachment")
        if style == "Laser" then
            muzzle.Position, impact.Position = Vector3.new(-half, 0, 0), Vector3.new(half, 0, 0)
        else
            muzzle.Position, impact.Position = Vector3.new(0, 0, half), Vector3.new(0, 0, -half)
        end
        muzzle.Parent, impact.Parent = bar, bar
        local glow = Instance.new("Beam")
        glow.Name = "Gradient"
        glow.Attachment0, glow.Attachment1 = muzzle, impact
        glow.Color = sequence(stops)
        glow.Width0, glow.Width1 = thick * 2.6, thick * 2.2
        glow.FaceCamera = true
        glow.LightEmission = 1
        glow.LightInfluence = 0
        glow.Segments = 1
        glow.Transparency = NumberSequence.new(0)
        glow.Parent = bar
        fadeBeam(glow, life)
    end

    if style == "Beam" then
        local light = Instance.new("PointLight")
        light.Color, light.Range, light.Brightness = tint, 6, 1.4
        light.Parent = bar
    end

    if State.TraceImpact ~= false then
        local ball = Instance.new("Part")
        ball.Name = "Impact"
        ball.Shape = Enum.PartType.Ball
        ball.Anchored, ball.CanCollide = true, false
        pcall(function() ball.CanQuery = false end)
        pcall(function() ball.CanTouch = false end)
        ball.CastShadow = false
        ball.Material = Enum.Material.Neon
        ball.Color = hitPlayer and HIT_RED or (stops and stops[#stops]) or tint
        ball.Size = Vector3.new(1.1, 1.1, 1.1)
        ball.Transparency = 0.1
        ball.CFrame = CFrame.new(to)
        ball.Parent = folder()

        local tag = Instance.new("BillboardGui")
        tag.Size = UDim2.new(0, 90, 0, 20)
        tag.AlwaysOnTop = true
        tag.StudsOffset = Vector3.new(0, 1.6, 0)
        tag.Parent = ball
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.TextSize = 13
        label.TextColor3 = ball.Color
        label.TextStrokeTransparency = 0.35
        local pumpkin = State.TraceColorName == "Halloween" and stops and "\u{1F383} " or ""
        label.Text = ("%s%.0f studs"):format(pumpkin, length)
        label.Parent = tag

        fade(ball, life, { Transparency = 1, Size = Vector3.new(3.2, 3.2, 3.2) })
    end

    fade(bar, life, { Transparency = 1 })
    return bar
end

function ShotTrace.Clear()
    local f = workspace:FindFirstChild("RiftwareTracers")
    if f then
        for _, c in ipairs(f:GetChildren()) do pcall(function() c:Destroy() end) end
    end
end

local function toPosition(v)
    if typeof(v) == "Vector3" then return v end
    if typeof(v) == "CFrame" then return v.Position end
    if typeof(v) == "Instance" then
        if v:IsA("BasePart") then return v.Position end
        if v:IsA("Attachment") then return v.WorldPosition end
    end
    return nil
end

local function isPlayerPart(part)
    if typeof(part) ~= "Instance" then return false end
    local model = part:FindFirstAncestorOfClass("Model")
    return model ~= nil and Players:GetPlayerFromCharacter(model) ~= nil
end

function ShotTrace.OnGunFired(host, origin, target, hit)
    if not State.ShotTrace or typeof(host) ~= "Instance" then return nil end
    local gun, char = Weapons.Gun(), Util.Character()
    local ours = gun and (host == gun or host:IsDescendantOf(gun)) or (char and host == char)
    if not ours then return nil end
    local from = toPosition(origin) or Weapons.ShootOrigin() and Weapons.ShootOrigin().Position
    local to = toPosition(target)
    if not (from and to) then return nil end
    return ShotTrace.Draw(from, to, isPlayerPart(hit))
end

function ShotTrace.Set(on)
    State.ShotTrace = on
    if on then
        local service = Services.WeaponService
        if service and service.GunFired then
            Util.Bind("shottrace", service.GunFired.OnClientEvent, ShotTrace.OnGunFired)
        end
    else
        Util.Unbind("shottrace")
        ShotTrace.Clear()
    end
end

function ShotTrace.Destroy()
    ShotTrace.Set(false)
    local f = workspace:FindFirstChild("RiftwareTracers")
    if f then pcall(function() f:Destroy() end) end
end

return ShotTrace
end

__modules["features/ESP"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")
local Roles    = import("core/Roles")
local Guns     = import("features/Guns")
local Assassin = import("features/Assassin")

local Players = Services.Players

local ESP = {}

local COLORS = {
    Murderer = Color3.fromRGB(255, 60, 60),
    Sheriff  = Color3.fromRGB(60, 130, 255),
    Hero     = Color3.fromRGB(255, 150, 40),
    Innocent = Color3.fromRGB(70, 220, 120),
    Zombie   = Color3.fromRGB(25, 172, 0),
    Survivor = Color3.fromRGB(43, 154, 238),
    Target   = Color3.fromRGB(255, 40, 90),
    Assassin = Color3.fromRGB(255, 170, 60),
    Gun      = Color3.fromRGB(255, 210, 60),
    Unknown  = Color3.fromRGB(230, 230, 230),
}

local container
local objects = {}
local gunObject

local function guiParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and cg then return cg end
    return Services.LocalPlayer:WaitForChild("PlayerGui")
end

local function ensureContainer()
    if container and container.Parent then return container end
    container = Instance.new("Folder")
    container.Name = "RiftwareESP"
    container.Parent = guiParent()
    return container
end

local function makeBillboard(adornee)
    local bb = Instance.new("BillboardGui")
    bb.Name = "RiftwareTag"
    bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0, 200, 0, 40)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.Adornee = adornee
    bb.Parent = ensureContainer()

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextStrokeTransparency = 0.4
    label.TextColor3 = COLORS.Unknown
    label.Text = ""
    label.Parent = bb

    return bb, label
end

local function makeHighlight(adornee, color)
    local hl = Instance.new("Highlight")
    hl.Name = "RiftwareHighlight"
    hl.FillColor = color
    hl.OutlineColor = color
    hl.FillTransparency = 0.65
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = adornee
    hl.Parent = ensureContainer()
    return hl
end

local function clearPlayer(plr)
    local obj = objects[plr]
    if not obj then return end
    if obj.highlight then obj.highlight:Destroy() end
    if obj.billboard then obj.billboard:Destroy() end
    objects[plr] = nil
end

local function clearGun()
    if not gunObject then return end
    if gunObject.highlight then gunObject.highlight:Destroy() end
    if gunObject.billboard then gunObject.billboard:Destroy() end
    gunObject = nil
end

local function colorFor(plr)
    local role = Roles.Of(plr)

    if State.EspAssassinTarget and plr == Assassin.Target() then
        return COLORS.Target, "YOUR TARGET"
    end
    if role == "Assassin" and (State.EspAssassins or State.EspEverything) then
        return COLORS.Assassin, "Assassin"
    end

    if role == "Murderer" and (State.EspMurderer or State.EspEverything) then
        return COLORS.Murderer, "Murderer"
    end
    if role == "Sheriff" and (State.EspSheriff or State.EspEverything) then
        return COLORS.Sheriff, "Sheriff"
    end

    if role == "Hero" and (State.EspHero or State.EspEverything) then
        return COLORS.Hero, "Hero"
    end

    if role == "Zombie" and (State.EspZombies or State.EspEverything) then
        return COLORS.Zombie, "Zombie"
    end
    if role == "Survivor" and (State.EspSurvivors or State.EspEverything) then
        return COLORS.Survivor, "Survivor"
    end

    local isInnocent = role ~= "Murderer" and role ~= "Sheriff" and role ~= "Hero"
        and role ~= "Zombie" and role ~= "Survivor" and role ~= "Assassin"
    if isInnocent and (State.EspInnocents or State.EspEverything) then
        return COLORS.Innocent, role or "Innocent"
    end

    if State.EspEverything then
        return COLORS.Unknown, role or "?"
    end

    return nil, nil
end

local function updatePlayer(plr)
    local color, roleName = colorFor(plr)
    local char = Util.Character(plr)

    if not color or not char or not Util.Alive(plr) or Roles.IsDead(plr) then
        clearPlayer(plr)
        return
    end

    local obj = objects[plr]
    if not obj or not obj.highlight or not obj.highlight.Parent then
        clearPlayer(plr)
        local hl = makeHighlight(char, color)
        local bb, label = makeBillboard(char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
        obj = { highlight = hl, billboard = bb, label = label }
        objects[plr] = obj
    end

    obj.highlight.Adornee = char
    obj.highlight.FillColor = color
    obj.highlight.OutlineColor = color
    obj.billboard.Adornee = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")

    if State.EspNames or State.EspDistance then
        local parts = {}
        if State.EspNames then
            table.insert(parts, plr.DisplayName .. " [" .. tostring(roleName) .. "]")
        end
        if State.EspDistance then
            table.insert(parts, ("%dm"):format(math.floor(Util.Distance(plr))))
        end
        obj.label.Text = table.concat(parts, "  ")
        obj.label.TextColor3 = color
        obj.billboard.Enabled = true
    else
        obj.billboard.Enabled = false
    end
end

local function updateGun()
    if not (State.EspGun or State.EspEverything) then
        clearGun()
        return
    end

    local handle = Guns.FindDroppedPart()
    if not handle then
        clearGun()
        return
    end

    if not gunObject or not gunObject.highlight or not gunObject.highlight.Parent then
        clearGun()
        local hl = makeHighlight(handle, COLORS.Gun)
        local bb, label = makeBillboard(handle)
        label.Text = "DROPPED GUN"
        label.TextColor3 = COLORS.Gun
        gunObject = { highlight = hl, billboard = bb, label = label }
    end

    gunObject.highlight.Adornee = handle
    gunObject.billboard.Adornee = handle

    if State.EspDistance then
        local hrp = Util.HRP()
        local dist = hrp and math.floor((handle.Position - hrp.Position).Magnitude) or 0
        gunObject.label.Text = ("DROPPED GUN  %dm"):format(dist)
    else
        gunObject.label.Text = "DROPPED GUN"
    end
end

local function anyEnabled()
    return State.EspMurderer or State.EspSheriff or State.EspHero
        or State.EspInnocents or State.EspGun or State.EspEverything
        or State.EspZombies or State.EspSurvivors
        or State.EspAssassinTarget or State.EspAssassins
end

local gunWasDown = false

local function watchPickup()
    local down = Guns.FindDroppedPart() ~= nil
    if gunWasDown and not down then
        Roles.Hunt(3)
    end
    gunWasDown = down
end

local function step()
    if not anyEnabled() then
        ESP.Clear()
        return
    end

    pcall(watchPickup)

    if Roles.Age() > 2 then Roles.Fetch() end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Services.LocalPlayer then
            local ok, err = pcall(updatePlayer, plr)
            if not ok then warn("[Riftware] esp: " .. tostring(err)) end
        end
    end

    for plr in pairs(objects) do
        if not plr.Parent then clearPlayer(plr) end
    end

    pcall(updateGun)
end

function ESP.Clear()
    for plr in pairs(objects) do
        clearPlayer(plr)
    end
    clearGun()
end

local roleHooked = false
local listening = false
local conns = {}
local burstUntil = 0

local function burst(seconds)
    burstUntil = os.clock() + (seconds or 3)
end

local function track(signal, fn)
    local ok, conn = pcall(function() return signal:Connect(fn) end)
    if ok and conn then table.insert(conns, conn) end
end

local function poke(seconds)
    burst(seconds)
    pcall(step)
end

local function watchCharacter(char)
    track(char.ChildAdded, function(child)
        if child:IsA("Tool") then
            Roles.Fetch()
            poke(1)
        end
    end)
    track(char.ChildRemoved, function(child)
        if child:IsA("Tool") then poke(1) end
    end)

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then

        track(hum.Died, function()
            Roles.Hunt(3)
            poke(5)
        end)
    end
end

local function watchPlayer(plr)
    if plr.Character then watchCharacter(plr.Character) end
    track(plr.CharacterAdded, function(char)
        task.defer(function() watchCharacter(char) end)
        poke(2)
    end)
end

local function hookRoleEvents()
    if roleHooked then return end
    roleHooked = true

    if not listening then
        listening = true
        Roles.OnChanged(function()
            if roleHooked then poke(1) end
        end)
    end
    Roles.Hook()

    for _, plr in ipairs(Players:GetPlayers()) do
        watchPlayer(plr)
    end
    track(Players.PlayerAdded, watchPlayer)
    track(Players.PlayerRemoving, function() poke(1) end)

    local CS = Services.CollectionService
    for _, tag in ipairs({ "Weapon_Gun", "Weapon" }) do
        local ok, signal = pcall(function() return CS:GetInstanceAddedSignal(tag) end)
        if ok and signal then track(signal, function() poke(2) end) end
    end
end

local function unhookRoleEvents()
    for _, conn in ipairs(conns) do
        pcall(function() conn:Disconnect() end)
    end
    conns = {}
    roleHooked = false
    burstUntil = 0
end

function ESP.Refresh()
    if anyEnabled() then
        Util.Loop("esp", function()
            return os.clock() < burstUntil and 0 or 0.1
        end, step)
        hookRoleEvents()
    else
        Util.Unbind("esp")
        ESP.Clear()
    end
end

function ESP.Destroy()
    unhookRoleEvents()
    Util.Unbind("esp")
    ESP.Clear()
    if container then
        container:Destroy()
        container = nil
    end
end

return ESP
end

__modules["features/Visuals"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")
local Roles    = import("core/Roles")

local Players    = Services.Players
local RunService = Services.RunService
local UIS        = Services.UserInputService
local LP         = Services.LocalPlayer

local Visuals = {}

local COLORS = {
    Murderer = Color3.fromRGB(255, 60, 60),
    Sheriff  = Color3.fromRGB(60, 130, 255),
    Hero     = Color3.fromRGB(255, 150, 40),
    Innocent = Color3.fromRGB(70, 220, 120),
}

Visuals.Colors = COLORS

local gui
local objects = {}

local function guiParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and cg then return cg end
    return LP:WaitForChild("PlayerGui")
end

local function ensureGui()
    if gui and gui.Parent then return end

    gui = Instance.new("ScreenGui")
    gui.Name = "RiftwareVisuals"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 9996
    gui.Parent = guiParent()
end

local function makeFor(plr)
    ensureGui()

    local box = Instance.new("Frame")
    box.Name = "Box"
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Visible = false
    box.Parent = gui

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Color = COLORS.Innocent
    stroke.Parent = box

    local tracer = Instance.new("Frame")
    tracer.Name = "Tracer"
    tracer.AnchorPoint = Vector2.new(0.5, 0.5)
    tracer.BorderSizePixel = 0
    tracer.BackgroundColor3 = COLORS.Innocent
    tracer.Visible = false
    tracer.Parent = gui

    local entry = { box = box, stroke = stroke, tracer = tracer }
    objects[plr] = entry
    return entry
end

local function clear(plr)
    local entry = objects[plr]
    if not entry then return end
    if entry.box then entry.box:Destroy() end
    if entry.tracer then entry.tracer:Destroy() end
    objects[plr] = nil
end

local function clearAll()
    for plr in pairs(objects) do
        clear(plr)
    end
end

local function tracerOrigin(viewport)
    local mode = State.TracerOrigin or "Bottom"

    if mode == "Center" then
        return Vector2.new(viewport.X / 2, viewport.Y / 2)
    elseif mode == "Top" then
        return Vector2.new(viewport.X / 2, 0)
    elseif mode == "Mouse" then
        local mouse = UIS:GetMouseLocation()
        return Vector2.new(mouse.X, mouse.Y)
    end

    return Vector2.new(viewport.X / 2, viewport.Y)
end

local function colorFor(plr)
    return COLORS[Roles.Of(plr)] or COLORS.Innocent
end

local function enabled()
    return State.EspBoxes or State.EspTracers
end

local function step()
    if not enabled() then return end

    local cam = workspace.CurrentCamera
    if not cam then return end

    local viewport = cam.ViewportSize
    local origin = tracerOrigin(viewport)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local alive = Util.Alive(plr) and not Roles.IsDead(plr)

            if hrp and alive then
                local entry = objects[plr] or makeFor(plr)
                local color = colorFor(plr)

                local topPoint, onScreen = cam:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
                local bottomPoint = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.5, 0))

                if onScreen and topPoint.Z > 0 then
                    local height = math.abs(bottomPoint.Y - topPoint.Y)
                    local width = height / 2

                    if State.EspBoxes then
                        entry.box.Visible = true
                        entry.box.Size = UDim2.fromOffset(width, height)
                        entry.box.Position = UDim2.fromOffset(topPoint.X - width / 2, topPoint.Y)
                        entry.stroke.Color = color
                        entry.stroke.Thickness = State.BoxThickness or 1.5
                    else
                        entry.box.Visible = false
                    end

                    if State.EspTracers then
                        local target = Vector2.new(topPoint.X, bottomPoint.Y)
                        local delta = target - origin
                        local length = delta.Magnitude

                        entry.tracer.Visible = true
                        entry.tracer.BackgroundColor3 = color
                        entry.tracer.Size = UDim2.fromOffset(length, State.TracerThickness or 1)
                        entry.tracer.Position = UDim2.fromOffset(
                            (origin.X + target.X) / 2,
                            (origin.Y + target.Y) / 2
                        )
                        entry.tracer.Rotation = math.deg(math.atan2(delta.Y, delta.X))
                    else
                        entry.tracer.Visible = false
                    end
                else

                    entry.box.Visible = false
                    entry.tracer.Visible = false
                end
            else
                clear(plr)
            end
        end
    end

    for plr in pairs(objects) do
        if not plr.Parent then clear(plr) end
    end
end

function Visuals.Refresh()
    if enabled() then
        ensureGui()
        Util.Bind("visuals", RunService.RenderStepped, step)
    else
        Util.Unbind("visuals")
        clearAll()
    end
end

function Visuals.Destroy()
    Util.Unbind("visuals")
    clearAll()
    if gui then
        gui:Destroy()
        gui = nil
    end
end

return Visuals
end

__modules["features/XRay"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")

local Players = Services.Players

local XRay = {}

local ALPHA = 0.5
local was = {}

local function isPlayerPart(part)
    local model = part:FindFirstAncestorWhichIsA("Model")
    return model ~= nil and Players:GetPlayerFromCharacter(model) ~= nil
end

local function apply(d)
    if not d:IsA("BasePart") or was[d] ~= nil then return end
    if d.Transparency >= ALPHA or isPlayerPart(d) then return end
    was[d] = d.Transparency
    d.Transparency = ALPHA
end

function XRay.Set(on)
    State.XRay = on
    Util.Unbind("xrayadded")
    if on then
        for _, d in ipairs(workspace:GetDescendants()) do pcall(apply, d) end
        Util.Bind("xrayadded", workspace.DescendantAdded, function(d)
            task.defer(function() pcall(apply, d) end)
        end)
    else
        for part, value in pairs(was) do
            pcall(function() if part.Parent then part.Transparency = value end end)
        end
        was = {}
    end
end

function XRay.Destroy()
    XRay.Set(false)
end

return XRay
end

__modules["features/TrapESP"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")

local LP = Services.LocalPlayer

local TrapESP = {}

local COLOR = Color3.fromRGB(230, 80, 255)
local SHOWN = 0.35

local folder
local tracked = {}

local function guiParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and cg then return cg end
    return LP:WaitForChild("PlayerGui")
end

local function ensureFolder()
    if folder and folder.Parent then return folder end
    folder = Instance.new("Folder")
    folder.Name = "RiftwareTrapESP"
    folder.Parent = guiParent()
    return folder
end

local function visualOf(trap)
    local visual = trap:FindFirstChild("TrapVisual")
    if visual and visual:IsA("BasePart") then return visual end
    if trap:IsA("BasePart") then return trap end
    return trap:FindFirstChildWhichIsA("BasePart", true)
end

local function isTrap(inst)
    if inst.Name ~= "Trap" then return false end
    local parent = inst.Parent
    if not parent or parent:IsA("Tool") then return false end
    return inst:IsA("Model") or inst:IsA("Folder") or inst:IsA("BasePart")
end

TrapESP.IsTrap = isTrap

local function ownerName(trap)
    local placed = trap:FindFirstChild("PlacedPlayer")
    local plr = placed and placed.Value
    if plr and plr.Name then return plr.DisplayName or plr.Name end
    return nil
end

local function untrack(trap)
    local t = tracked[trap]
    if not t then return end
    tracked[trap] = nil
    if t.part and t.was ~= nil then pcall(function() t.part.Transparency = t.was end) end
    if t.highlight then pcall(function() t.highlight:Destroy() end) end
    if t.billboard then pcall(function() t.billboard:Destroy() end) end
end

local function track(trap)
    if tracked[trap] or not isTrap(trap) then return end
    local part = visualOf(trap)
    if not part then return end

    local t = { part = part }
    if part.Transparency > SHOWN then
        t.was = part.Transparency
        part.Transparency = SHOWN
    end

    local hl = Instance.new("Highlight")
    hl.Name = "RiftwareTrap"
    hl.FillColor = COLOR
    hl.OutlineColor = COLOR
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = trap:IsA("Folder") and part or trap
    hl.Parent = ensureFolder()
    t.highlight = hl

    local bb = Instance.new("BillboardGui")
    bb.Name = "RiftwareTrapTag"
    bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0, 160, 0, 30)
    bb.StudsOffset = Vector3.new(0, 2, 0)
    bb.Adornee = part
    bb.Parent = ensureFolder()
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextColor3 = COLOR
    label.TextStrokeTransparency = 0.4
    label.Text = "TRAP"
    label.Parent = bb
    t.billboard, t.label = bb, label

    tracked[trap] = t
end

TrapESP.Track = track

local function refresh()
    for trap, t in pairs(tracked) do
        if not trap.Parent or not t.part.Parent then
            untrack(trap)
        else
            local parts = { "TRAP" }
            local owner = ownerName(trap)
            if owner then table.insert(parts, owner) end
            local root = Util.HRP(LP)
            if root then
                table.insert(parts, ("%dm"):format(math.floor((root.Position - t.part.Position).Magnitude)))
            end
            t.label.Text = table.concat(parts, "  \u{00B7}  ")

            if t.part.Transparency > SHOWN then
                t.was = t.was or t.part.Transparency
                t.part.Transparency = SHOWN
            end
        end
    end
end

TrapESP.Refresh = refresh

function TrapESP.Count()
    local n = 0
    for _ in pairs(tracked) do n = n + 1 end
    return n
end

function TrapESP.Set(on)
    State.EspTraps = on
    Util.Unbind("trapadded")
    Util.Unbind("trapremoved")
    Util.Unbind("traprefresh")
    if not on then
        for trap in pairs(tracked) do untrack(trap) end
        return
    end

    for _, d in ipairs(workspace:GetDescendants()) do pcall(track, d) end
    Util.Bind("trapadded", workspace.DescendantAdded, function(d)
        if d.Name == "Trap" then

            task.delay(0.1, function() pcall(track, d) end)
        end
    end)
    Util.Bind("trapremoved", workspace.DescendantRemoving, function(d)
        if tracked[d] then untrack(d) end
    end)
    Util.Loop("traprefresh", function() return 0.5 end, refresh)
end

function TrapESP.Destroy()
    TrapESP.Set(false)
    if folder then pcall(function() folder:Destroy() end) end
    folder = nil
end

return TrapESP
end

__modules["features/AntiTrap"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")

local LP = Services.LocalPlayer
local RS = Services.ReplicatedStorage

local AntiTrap = {}

local HOLD = 4.5
local guardUntil = 0
AntiTrap.Saved = 0

local function wanted()
    local walk = State.SpeedEnabled and State.WalkSpeed or 16
    local jump = State.JumpEnabled and State.JumpPower or 50
    return walk, jump
end

local function restore(hum)
    local walk, jump = wanted()
    if hum.WalkSpeed < walk then hum.WalkSpeed = walk end
    pcall(function()
        if hum.UseJumpPower then
            if hum.JumpPower < jump then hum.JumpPower = jump end
        elseif hum.JumpHeight < jump / 7.5 then
            hum.JumpHeight = jump / 7.5
        end
    end)
end

local function dropTrapGui()
    local pg = LP:FindFirstChildOfClass("PlayerGui")
    local gui = pg and pg:FindFirstChild("TrapGUI")
    if gui then pcall(function() gui:Destroy() end) end
end

function AntiTrap.OnTrapped()
    guardUntil = os.clock() + HOLD
    AntiTrap.Saved = AntiTrap.Saved + 1
    local hum = Util.Humanoid()
    if hum then restore(hum) end

    task.defer(function()
        local h = Util.Humanoid()
        if h then restore(h) end
        dropTrapGui()
    end)
end

local function guardStep()
    if os.clock() > guardUntil then return end
    local hum = Util.Humanoid()
    if hum then restore(hum) end
    dropTrapGui()
end

function AntiTrap.Set(on)
    State.AntiTrap = on
    Util.Unbind("antitrap")
    Util.Unbind("antitrapguard")
    if not on then return end
    local system = RS:FindFirstChild("TrapSystem")
    local hit = system and system:FindFirstChild("TrapHitLocal")
    if hit then
        Util.Bind("antitrap", hit.OnClientEvent, function() AntiTrap.OnTrapped() end)
    end
    Util.Bind("antitrapguard", Services.RunService.Heartbeat, guardStep)
end

AntiTrap.GuardStep = guardStep

function AntiTrap.Destroy()
    AntiTrap.Set(false)
end

return AntiTrap
end

__modules["features/FakeGun"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")
local Roles    = import("core/Roles")

local Players = Services.Players
local LP      = Services.LocalPlayer

local FakeGun = {}

local RED = Color3.fromRGB(255, 70, 85)

local folder
local tags = {}
local announced = {}

local function guiParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and cg then return cg end
    return LP:WaitForChild("PlayerGui")
end

function FakeGun.IsFake(tool)
    return Roles.IsFakeGun(tool)
end

function FakeGun.Holding(player)
    local char = Util.Character(player)
    if not char then return nil end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") and Roles.IsFakeGun(child) then return child end
    end
    return nil
end

local function tagFor(plr, head)
    local bb = tags[plr]
    if bb and bb.Parent then
        bb.Adornee = head
        return bb
    end
    if not folder or not folder.Parent then
        folder = Instance.new("Folder")
        folder.Name = "RiftwareFakeGun"
        folder.Parent = guiParent()
    end
    bb = Instance.new("BillboardGui")
    bb.Name = "RiftwareFake_" .. plr.Name
    bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0, 140, 0, 24)
    bb.StudsOffset = Vector3.new(0, 6.2, 0)
    bb.Adornee = head
    bb.Parent = folder
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 14
    label.TextColor3 = RED
    label.TextStrokeTransparency = 0.3
    label.Text = "FAKE GUN"
    label.Parent = bb
    tags[plr] = bb
    return bb
end

local function clear(plr)
    if tags[plr] then pcall(function() tags[plr]:Destroy() end) end
    tags[plr] = nil
end

local function step()
    local seen = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and FakeGun.Holding(plr) then
            local char = Util.Character(plr)
            local head = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
            if head then
                seen[plr] = true
                tagFor(plr, head)
                if not announced[plr] then
                    announced[plr] = true
                    Util.Notify("Fake Gun", (plr.DisplayName or plr.Name) .. " is holding a FAKE gun -- that's the murderer.")
                end
            end
        end
    end
    for plr in pairs(tags) do
        if not seen[plr] then clear(plr) end
    end
end

FakeGun.Step = step

function FakeGun.Set(on)
    State.FakeGunDetector = on
    if on then
        Util.Loop("fakegun", function() return 0.3 end, step)

        pcall(function()
            local fade = Services.Gameplay:FindFirstChild("RoundEndFade")
            if fade then Util.Bind("fakegunround", fade.OnClientEvent, function() announced = {} end) end
        end)
    else
        Util.Unbind("fakegun")
        Util.Unbind("fakegunround")
        for plr in pairs(tags) do clear(plr) end
    end
end

function FakeGun.Destroy()
    FakeGun.Set(false)
    if folder then pcall(function() folder:Destroy() end) end
    folder = nil
end

return FakeGun
end

__modules["features/DualWield"] = function(import)

local Services = import("core/Services")
local State    = import("core/State")
local Roles    = import("core/Roles")

local RunService = Services.RunService
local CS = Services.CollectionService
local LP = Services.LocalPlayer

local DualWield = {}

local copy = nil
local armConn = nil
local toolConns = {}
local respawnConn = nil

local PAIRS = {
    { "LeftUpperArm", "LeftShoulder", "RightUpperArm", "RightShoulder" },
    { "LeftLowerArm", "LeftElbow", "RightLowerArm", "RightElbow" },
    { "LeftHand", "LeftWrist", "RightHand", "RightWrist" },
}

local function mirror(cf)
    local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
    return CFrame.new(-x, y, z, r00, -r01, -r02, -r10, r11, r12, -r20, r21, r22)
end

DualWield.Mirror = mirror

local function cloneHandle(handle)
    local ok, c = pcall(function() return handle:Clone() end)
    if not ok or not c then return nil end
    for _, d in ipairs(c:GetDescendants()) do
        if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ModuleScript") or d:IsA("RemoteEvent")
            or d:IsA("RemoteFunction") or d:IsA("BindableEvent") or d:IsA("BindableFunction")
            or d:IsA("Sound") or d:IsA("TouchTransmitter") then
            pcall(function() d:Destroy() end)
        elseif d:IsA("BasePart") then
            d.CanCollide, d.CanQuery, d.CanTouch, d.Massless, d.Anchored = false, false, false, true, false
        end
    end
    if c:IsA("BasePart") then
        c.CanCollide, c.CanQuery, c.CanTouch, c.Massless, c.Anchored = false, false, false, true, false
    end
    c.Name = "DualWieldHandle"
    return c
end

local function clear()
    if armConn then
        pcall(function() armConn:Disconnect() end)
        armConn = nil
    end
    pcall(function() RunService:UnbindFromRenderStep("RiftwareDualLTM") end)
    if copy then pcall(function() copy:Destroy() end) end
    copy = nil
end

local function heldTool(char)
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then return child end
    end
    for _, tag in ipairs({ "Weapon_Gun", "Weapon_Knife" }) do
        local ok, list = pcall(function() return CS:GetTagged(tag) end)
        for _, t in ipairs(ok and list or {}) do
            if t:IsA("Tool") and t:IsDescendantOf(char) then return t end
        end
    end
    return nil
end

local function kindOf(tool)
    if Roles.IsKnifeTool(tool) then return "knife" end
    if Roles.IsGunTool(tool) then return "gun" end
    return nil
end

DualWield.KindOf = kindOf

local function enabledFor(kind)
    if kind == "gun" then return State.DualGun == true end
    if kind == "knife" then return State.DualKnife == true end
    return false
end

local function build()
    clear()
    local char = LP.Character
    if not char then return end

    local right = char:FindFirstChild("RightHand")
    local left = char:FindFirstChild("LeftHand")
    local tool = heldTool(char)
    local handle = tool and tool:FindFirstChild("Handle")
    if not (right and left and handle) then return end

    local kind = kindOf(tool)
    if not enabledFor(kind) then return end

    local c = cloneHandle(handle)
    if not c then return end

    local offset = right.CFrame:ToObjectSpace(handle.CFrame)

    local weld = Instance.new("Weld")
    weld.Part0 = left
    weld.Part1 = c
    weld.C0 = offset
    weld.Parent = left
    c.Parent = char
    copy = c

    local arms = {}
    for _, p in ipairs(PAIRS) do
        local lp, rp = char:FindFirstChild(p[1]), char:FindFirstChild(p[3])
        local lc = lp and lp:FindFirstChild(p[2])
        local rc = rp and rp:FindFirstChild(p[4])
        if lc and rc then table.insert(arms, { lc = lc, rc = rc }) end
    end

    local parts = {}
    if c:IsA("BasePart") then table.insert(parts, c) end
    for _, d in ipairs(c:GetDescendants()) do
        if d:IsA("BasePart") then table.insert(parts, d) end
    end

    armConn = RunService.Stepped:Connect(function()
        if not (c.Parent and char.Parent) then return end
        for _, j in ipairs(arms) do
            if j.lc.Parent and j.rc.Parent then
                pcall(function() j.lc.Transform = mirror(j.rc.Transform) end)
            end
        end
    end)
    pcall(function()
        RunService:BindToRenderStep("RiftwareDualLTM", Enum.RenderPriority.Last.Value, function()
            for _, p in ipairs(parts) do
                if p.Parent and p.LocalTransparencyModifier ~= 0 then p.LocalTransparencyModifier = 0 end
            end
        end)
    end)
end

DualWield.Build = build

function DualWield.Copy() return copy end

local function unwatch()
    for _, c in ipairs(toolConns) do pcall(function() c:Disconnect() end) end
    toolConns = {}
end

local function watch(char)
    unwatch()
    table.insert(toolConns, char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            task.wait(0.15)
            build()
        end
    end))
    table.insert(toolConns, char.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") then build() end
    end))
    build()
end

local function refresh()
    if State.DualGun or State.DualKnife then
        if not respawnConn then
            respawnConn = LP.CharacterAdded:Connect(function(char)
                task.wait(0.3)
                if State.DualGun or State.DualKnife then watch(char) end
            end)
        end
        if LP.Character then watch(LP.Character) end
    else
        if respawnConn then
            pcall(function() respawnConn:Disconnect() end)
            respawnConn = nil
        end
        unwatch()
        clear()
    end
end

function DualWield.SetGun(on)
    State.DualGun = on
    refresh()
end

function DualWield.SetKnife(on)
    State.DualKnife = on
    refresh()
end

function DualWield.Destroy()
    State.DualGun, State.DualKnife = false, false
    refresh()
end

return DualWield
end

__modules["features/Assassin"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")

local Players = Services.Players
local LP      = Services.LocalPlayer

local Assassin = {}

Assassin.TargetName = nil
Assassin.Mode = nil
Assassin.OnChanged = nil

local function set(name)
    if name == "" then name = nil end
    if name == Assassin.TargetName then return end
    Assassin.TargetName = name
    if Assassin.OnChanged then pcall(Assassin.OnChanged, name) end
end

Assassin.Set = set

local function fromGui()
    local gui = LP and LP:FindFirstChild("PlayerGui")
    local card = gui and gui:FindFirstChild("AssassinTarget", true)
    if not (card and card.Visible) then return nil end
    local label = card:FindFirstChild("TargetName", true)
    local text = label and label.Text
    return (type(text) == "string" and text ~= "") and text or nil
end

function Assassin.Active()
    return Assassin.Mode == "Assassin" or Assassin.TargetName ~= nil or fromGui() ~= nil
end

function Assassin.Target()
    local name = Assassin.TargetName or fromGui()
    if not name then return nil end
    local plr = Players:FindFirstChild(name)
    if plr and plr:IsA("Player") then return plr end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.DisplayName == name then return p end
    end
    return nil
end

function Assassin.Start()
    local gameplay = Services.Gameplay
    if not gameplay then return false end
    local roleSelect = gameplay:FindFirstChild("RoleSelect")
    if roleSelect then
        Util.Bind("assassinroles", roleSelect.OnClientEvent, function(_, _, _, _, mode, targetName)
            Assassin.Mode = mode
            set(mode == "Assassin" and targetName or nil)
        end)
    end
    local change = gameplay:FindFirstChild("ChangeTarget")
    if change then
        Util.Bind("assassintarget", change.OnClientEvent, function(targetName)
            Assassin.Mode = "Assassin"
            set(targetName)
        end)
    end
    local victory = gameplay:FindFirstChild("VictoryScreen")
    if victory then
        Util.Bind("assassinend", victory.OnClientEvent, function()
            Assassin.Mode = nil
            set(nil)
        end)
    end
    return true
end

function Assassin.Destroy()
    Util.Unbind("assassinroles")
    Util.Unbind("assassintarget")
    Util.Unbind("assassinend")
end

return Assassin
end

__modules["features/Dodge"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")

local CS         = Services.CollectionService
local RunService = Services.RunService

local Dodge = {}

Dodge.Dodges = 0
Dodge.LastReason = "nothing yet"

local lastDodge = 0

local function knifePart(projectile)
    if projectile:IsA("BasePart") then return projectile end

    local visual = projectile:FindFirstChild("KnifeVisual")
    if visual and visual:IsA("BasePart") then return visual end

    if projectile:IsA("Model") and projectile.PrimaryPart then
        return projectile.PrimaryPart
    end

    return projectile:FindFirstChildWhichIsA("BasePart")
end

local function threatOf(projectile, myPosition)
    local part = knifePart(projectile)
    if not part then return nil end

    local direction = projectile:GetAttribute("Direction")
    if typeof(direction) ~= "Vector3" or direction.Magnitude < 0.001 then return nil end

    local heading = direction.Unit
    local toUs = myPosition - part.Position

    local along = toUs:Dot(heading)
    if along <= 0 then return nil end

    local closestPoint = part.Position + heading * along
    local miss = (myPosition - closestPoint).Magnitude

    local speed = projectile:GetAttribute("ThrowSpeed")
    if type(speed) ~= "number" or speed <= 0 then speed = 96 end

    return miss, along / speed, heading, closestPoint
end

Dodge.KnifePart = knifePart
Dodge.ThreatOf = threatOf

local function step()
    if not State.AutoDodge then return end

    local hrp = Util.HRP()
    if not hrp then return end

    local now = os.clock()
    if now - lastDodge < (State.DodgeCooldown or 0.35) then return end

    local myPosition = hrp.Position
    local radius = State.DodgeRadius or 6
    local warning = State.DodgeWarning or 0.6

    for _, projectile in ipairs(CS:GetTagged("ThrowingKnife")) do
        if projectile.Parent then
            local ok, miss, timeToHit, heading, closestPoint = pcall(threatOf, projectile, myPosition)

            if ok and miss and miss <= radius and timeToHit <= warning then

                local away = myPosition - closestPoint
                local side

                if away.Magnitude > 0.25 then
                    side = Vector3.new(away.X, 0, away.Z)
                    if side.Magnitude < 0.05 then
                        side = heading:Cross(Vector3.new(0, 1, 0))
                    end
                else
                    side = heading:Cross(Vector3.new(0, 1, 0))
                end

                if side.Magnitude > 0.001 then
                    side = side.Unit
                    local distance = State.DodgeDistance or 7

                    hrp.CFrame = hrp.CFrame + side * distance

                    lastDodge = now
                    Dodge.Dodges = Dodge.Dodges + 1
                    Dodge.LastReason = ("miss %.1f studs, %.2fs out"):format(miss, timeToHit)

                    if State.DodgeNotify then
                        Util.Notify("Auto Dodge", "Dodged a knife.")
                    end

                    return
                end
            end
        end
    end
end

function Dodge.Set(on)
    State.AutoDodge = on

    if on then

        Util.Bind("dodge", RunService.Heartbeat, step)
    else
        Util.Unbind("dodge")
    end
end

function Dodge.Report()
    local live = #CS:GetTagged("ThrowingKnife")

    local text = table.concat({
        "Enabled: " .. tostring(State.AutoDodge),
        "Trigger radius: " .. tostring(State.DodgeRadius) .. " studs",
        "Reacts within: " .. tostring(State.DodgeWarning) .. "s of impact",
        "Sidestep: " .. tostring(State.DodgeDistance) .. " studs",
        "Knives in the air: " .. tostring(live),
        "Dodges this session: " .. tostring(Dodge.Dodges),
        "Last: " .. tostring(Dodge.LastReason),
    }, "\n")

    print("[Riftware] " .. text)
    return text
end

return Dodge
end

__modules["features/BulletDodge"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")
local Roles    = import("core/Roles")

local Players    = Services.Players
local RunService = Services.RunService
local CS         = Services.CollectionService

local BulletDodge = {}

BulletDodge.Styles = { "Slide", "Blink" }
BulletDodge.Jukes = 0
BulletDodge.Dodged = 0
BulletDodge.Hits = 0
BulletDodge.Threat = nil

local UP = Vector3.new(0, 1, 0)

local lastScan, lastJuke, nextGap = 0, 0, 0.22
local side = 1
local slide = nil
local threats = {}

local function eyes(player)
    local char = Util.Character(player)
    local head = char and char:FindFirstChild("Head")
    if head then return head.Position end
    local hrp = Util.HRP(player)
    return hrp and hrp.Position
end

local function sightBlocked(from, to, ignore)
    local params = RaycastParams.new()
    local list = {}
    for _, inst in ipairs(ignore) do table.insert(list, inst) end
    for _, inst in ipairs(CS:GetTagged("WeaponPassthrough")) do table.insert(list, inst) end
    pcall(function()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = list
    end)
    local dir = to - from
    for _ = 1, 8 do
        local hit = workspace:Raycast(from, dir, params)
        if not hit then return false end
        local part = hit.Instance
        if part and part.Transparency == 1 then
            table.insert(list, part)
            pcall(function() params.FilterDescendantsInstances = list end)
        else
            return true
        end
    end
    return false
end

local function facingAngle(player, target)
    local hrp = Util.HRP(player)
    if not hrp then return 180 end
    local look = hrp.CFrame.LookVector
    local to = target - hrp.Position
    local flatLook = Vector3.new(look.X, 0, look.Z)
    local flatTo = Vector3.new(to.X, 0, to.Z)
    if flatLook.Magnitude < 0.01 or flatTo.Magnitude < 0.01 then return 0 end
    local dot = math.clamp(flatLook.Unit:Dot(flatTo.Unit), -1, 1)
    return math.deg(math.acos(dot))
end

BulletDodge.FacingAngle = facingAngle

function BulletDodge.Threats()
    local out = {}
    local me = Util.HRP()
    if not me then return out end
    local myChar = Util.Character()
    local range = State.BulletRange or 150
    local cone = State.BulletFacing or 40
    for _, plr in ipairs(Util.Others()) do
        if Roles.HeldWeapon(plr) == "Gun" then
            local from = eyes(plr)
            local distance = from and (me.Position - from).Magnitude
            if distance and distance <= range then
                local angle = facingAngle(plr, me.Position)
                if angle <= cone and not sightBlocked(from, me.Position, { Util.Character(plr), myChar }) then
                    table.insert(out, { player = plr, distance = distance, angle = angle })
                end
            end
        end
    end
    table.sort(out, function(a, b) return a.distance < b.distance end)
    return out
end

local function safeStep(hrp, offset)
    local char = Util.Character()
    local from = hrp.Position
    local params = RaycastParams.new()
    pcall(function()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { char }
    end)
    local reach = offset + offset.Unit * 1.5
    local wall = workspace:Raycast(from, reach, params)
    if wall and wall.Instance and wall.Instance.CanCollide ~= false and wall.Instance.Transparency < 1 then
        return false
    end
    local floor = workspace:Raycast(from + offset, Vector3.new(0, -14, 0), params)
    return floor ~= nil or State.BulletAllowEdges == true
end

BulletDodge.SafeStep = safeStep

local function startJuke(hrp, threat)
    local from = eyes(threat.player) or hrp.Position
    local toMe = hrp.Position - from
    local across = Vector3.new(toMe.X, 0, toMe.Z):Cross(UP)
    if across.Magnitude < 0.01 then across = Vector3.new(1, 0, 0) end
    across = across.Unit

    if math.random() < 0.7 then side = -side end
    local distance = (State.BulletJukeDistance or 3) * (0.75 + math.random() * 0.5)
    local offset = across * side * distance
    if not safeStep(hrp, offset) then
        offset = -offset
        side = -side
        if not safeStep(hrp, offset) then return false end
    end

    if (State.BulletStyle or "Slide") == "Blink" then
        hrp.CFrame = hrp.CFrame + offset
    else
        slide = { offset = offset, start = os.clock(), duration = 0.12, done = 0 }
    end
    if State.BulletJump then
        local hum = Util.Humanoid()
        if hum and math.random() < 0.35 then hum.Jump = true end
    end
    BulletDodge.Jukes = BulletDodge.Jukes + 1
    return true
end

BulletDodge.StartJuke = startJuke

local function advanceSlide(hrp)
    if not slide then return end
    local a = math.clamp((os.clock() - slide.start) / slide.duration, 0, 1)
    local eased = 1 - (1 - a) * (1 - a)
    local step = eased - slide.done
    if step > 0 then hrp.CFrame = hrp.CFrame + slide.offset * step end
    slide.done = eased
    if a >= 1 then slide = nil end
end

local function step()
    if not State.BulletDodge then return end
    local hrp = Util.HRP()
    if not hrp or not Util.Alive() then return end

    advanceSlide(hrp)

    local now = os.clock()
    if now - lastScan >= 0.08 then
        lastScan = now
        threats = BulletDodge.Threats()
        local was = BulletDodge.Threat
        BulletDodge.Threat = threats[1] and threats[1].player or nil
        if BulletDodge.Threat and BulletDodge.Threat ~= was and State.BulletNotify then
            Util.Notify("Bullet Dodge", BulletDodge.Threat.Name .. " is aiming at you.")
        end
    end
    if not threats[1] or slide then return end

    if now - lastJuke >= nextGap then
        if startJuke(hrp, threats[1]) then
            lastJuke = now
            local every = State.BulletJukeEvery or 0.22
            nextGap = every * (0.7 + math.random() * 0.6)
        end
    end
end

BulletDodge.Step = step

local function toPosition(v)
    if typeof(v) == "Vector3" then return v end
    if typeof(v) == "CFrame" then return v.Position end
    return nil
end

function BulletDodge.OnGunFired(host, _, target, hit)
    if not State.BulletDodge or typeof(host) ~= "Instance" then return nil end
    local myChar = Util.Character()
    if myChar and (host == myChar or host:IsDescendantOf(myChar)) then return nil end
    local me = Util.HRP()
    local landed = toPosition(target)
    if not (me and landed) then return nil end
    if typeof(hit) == "Instance" and myChar and hit:IsDescendantOf(myChar) then
        BulletDodge.Hits = BulletDodge.Hits + 1
        return "hit"
    end
    if (landed - me.Position).Magnitude <= (State.BulletNearMiss or 8) then
        BulletDodge.Dodged = BulletDodge.Dodged + 1
        if State.BulletNotify then
            local owner = host:FindFirstAncestorOfClass("Model")
            local shooter = owner and Players:GetPlayerFromCharacter(owner)
            Util.Notify("Bullet Dodge", "Dodged a shot" .. (shooter and (" from " .. shooter.Name) or "") .. ".")
        end
        return "dodged"
    end
    return nil
end

function BulletDodge.Set(on)
    State.BulletDodge = on
    slide, threats, BulletDodge.Threat = nil, {}, nil
    if on then

        Util.Bind("bulletdodge", RunService.Heartbeat, step)
        local service = Services.WeaponService
        if service and service.GunFired then
            Util.Bind("bulletdodgefired", service.GunFired.OnClientEvent, BulletDodge.OnGunFired)
        end
    else
        Util.Unbind("bulletdodge")
        Util.Unbind("bulletdodgefired")
    end
end

function BulletDodge.Report()
    local threat = BulletDodge.Threat
    return table.concat({
        "Enabled: " .. tostring(State.BulletDodge == true),
        "Aimed at by: " .. (threat and threat.Name or "nobody"),
        ("Watching guns within %d studs, facing you within %d deg"):format(State.BulletRange or 150, State.BulletFacing or 40),
        "Jukes: " .. BulletDodge.Jukes,
        "Shots dodged: " .. BulletDodge.Dodged .. "   hits taken: " .. BulletDodge.Hits,
    }, "\n")
end

function BulletDodge.Destroy()
    BulletDodge.Set(false)
end

return BulletDodge
end

__modules["features/KnifeTrail"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")
local Dodge    = import("features/Dodge")

local Players    = Services.Players
local RunService = Services.RunService
local CS         = Services.CollectionService

local KnifeTrail = {}

local DANGER = Color3.fromRGB(255, 50, 70)
KnifeTrail.Palettes = {
    Halloween = { Color3.fromRGB(255, 122, 26), Color3.fromRGB(139, 61, 255) },
    Red       = { Color3.fromRGB(255, 70, 70), Color3.fromRGB(150, 0, 30) },
    White     = { Color3.fromRGB(255, 255, 255), Color3.fromRGB(170, 180, 200) },
    Blue      = { Color3.fromRGB(70, 170, 255), Color3.fromRGB(40, 60, 200) },
    Green     = { Color3.fromRGB(80, 255, 150), Color3.fromRGB(20, 140, 90) },
}
KnifeTrail.PaletteNames = { "Halloween", "Red", "White", "Blue", "Green" }

local MAX_RANGE = 400
local tracked = {}

local function palette()
    return KnifeTrail.Palettes[State.KnifeTrailColor or "Halloween"] or KnifeTrail.Palettes.Halloween
end

local function sequence(a, b)
    return ColorSequence.new({ ColorSequenceKeypoint.new(0, a), ColorSequenceKeypoint.new(1, b) })
end

local function folder()
    local f = workspace:FindFirstChild("RiftwareKnifeTrails")
    if not f then
        f = Instance.new("Folder")
        f.Name = "RiftwareKnifeTrails"
        f.Parent = workspace
    end
    return f
end

local function ghostPart(name, parent)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch, p.CastShadow = true, false, false, false, false
    p.Transparency = 1
    p.Size = Vector3.new(0.2, 0.2, 0.2)
    p.Parent = parent
    return p
end

local function landing(pos, dir, projectile)
    local params = RaycastParams.new()
    local ignore = { projectile, folder() }
    for _, inst in ipairs(CS:GetTagged("WeaponPassthrough")) do table.insert(ignore, inst) end
    pcall(function()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = ignore
    end)

    local origin = pos + dir * 1.5
    for _ = 1, 8 do
        local hit = workspace:Raycast(origin, dir * MAX_RANGE, params)
        if not hit then return pos + dir * MAX_RANGE, nil end
        local part = hit.Instance
        local model = part and part:FindFirstAncestorOfClass("Model")
        local victim = model and Players:GetPlayerFromCharacter(model) or nil

        if part and part.Transparency == 1 and not victim then
            table.insert(ignore, part)
            pcall(function() params.FilterDescendantsInstances = ignore end)
        else
            return hit.Position, victim
        end
    end
    return pos + dir * MAX_RANGE, nil
end

KnifeTrail.Landing = landing

local function untrack(projectile)
    local t = tracked[projectile]
    if not t then return end
    tracked[projectile] = nil
    pcall(function() t.anchor:Destroy() end)
    if t.trail then

        pcall(function() t.trail.Enabled = false end)
        task.delay(0.5, function()
            pcall(function() t.trail:Destroy() end)
            for _, a in ipairs(t.trailAtt or {}) do pcall(function() a:Destroy() end) end
        end)
    end
end

local function track(projectile)
    if tracked[projectile] or not State.KnifeTrail then return end
    local colors = palette()
    local anchor = ghostPart("KnifePath", folder())
    local a0 = Instance.new("Attachment")
    a0.Parent = anchor
    local a1 = Instance.new("Attachment")
    a1.Parent = anchor

    local beam = Instance.new("Beam")
    beam.Name = "Path"
    beam.Attachment0, beam.Attachment1 = a0, a1
    beam.Width0, beam.Width1 = 0.22, 0.12
    beam.FaceCamera = true
    beam.LightEmission = 1
    beam.Segments = 1
    beam.Color = sequence(colors[1], colors[2])
    beam.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.05), NumberSequenceKeypoint.new(1, 0.45) })
    beam.Enabled = State.KnifeTrailPath ~= false
    beam.Parent = anchor

    local marker = ghostPart("Landing", anchor)
    marker.Shape = Enum.PartType.Ball
    marker.Size = Vector3.new(1.4, 1.4, 1.4)
    marker.Material = Enum.Material.Neon
    marker.Color = colors[1]
    marker.Transparency = State.KnifeTrailMarker == false and 1 or 0.25

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Who"
    billboard.Size = UDim2.fromOffset(160, 26)
    billboard.StudsOffset = Vector3.new(0, 2.2, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = false
    billboard.Adornee = marker
    billboard.Parent = marker
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 15
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0.4
    label.Parent = billboard

    local t = { anchor = anchor, a0 = a0, a1 = a1, beam = beam, marker = marker, billboard = billboard, label = label }

    if State.KnifeTrailGlow ~= false then
        local part = Dodge.KnifePart(projectile)
        if part then
            local top, bottom = Instance.new("Attachment"), Instance.new("Attachment")
            top.Name, bottom.Name = "RiftwareTrailTop", "RiftwareTrailBottom"
            top.Position, bottom.Position = Vector3.new(0, 0.3, 0), Vector3.new(0, -0.3, 0)
            top.Parent, bottom.Parent = part, part
            local trail = Instance.new("Trail")
            trail.Name = "RiftwareTrail"
            trail.Attachment0, trail.Attachment1 = top, bottom
            trail.Lifetime = 0.35
            trail.FaceCamera = true
            trail.LightEmission = 1
            trail.MinLength = 0.05
            trail.Color = sequence(colors[1], colors[2])
            trail.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1) })
            trail.WidthScale = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.1) })
            trail.Parent = part
            t.trail, t.trailAtt = trail, { top, bottom }
        end
    end

    tracked[projectile] = t
    pcall(function()
        projectile.Destroying:Connect(function() untrack(projectile) end)
    end)
end

KnifeTrail.Track = track

local function update(projectile, t)
    local part = Dodge.KnifePart(projectile)
    local direction = projectile:GetAttribute("Direction")
    if not part or typeof(direction) ~= "Vector3" or direction.Magnitude < 0.001 then return end
    local dir = direction.Unit
    local pos = part.Position
    local stop, victim = landing(pos, dir, projectile)
    t.a0.WorldPosition, t.a1.WorldPosition = pos, stop
    t.marker.CFrame = CFrame.new(stop)

    local me = Util.HRP()
    local danger = false
    if me then
        local ok, miss = pcall(Dodge.ThreatOf, projectile, me.Position)
        danger = ok and miss ~= nil and miss <= (State.DodgeRadius or 6)
    end
    if victim == Services.LocalPlayer then danger = true end

    local colors = palette()
    if t.danger ~= danger then
        t.danger = danger
        t.beam.Color = danger and sequence(DANGER, DANGER) or sequence(colors[1], colors[2])
        t.marker.Color = danger and DANGER or colors[1]
    end
    local who = danger and "YOU" or (victim and victim.Name) or nil
    t.billboard.Enabled = who ~= nil and State.KnifeTrailMarker ~= false
    if who then t.label.Text = "\u{1F52A} " .. who end
    t.label.TextColor3 = danger and DANGER or Color3.new(1, 1, 1)
end

local function step()
    for projectile, t in pairs(tracked) do
        if not projectile.Parent then
            untrack(projectile)
        else
            pcall(update, projectile, t)
        end
    end
end

KnifeTrail.Step = step

function KnifeTrail.Count()
    local n = 0
    for _ in pairs(tracked) do n = n + 1 end
    return n
end

function KnifeTrail.Clear()
    for projectile in pairs(tracked) do untrack(projectile) end
end

function KnifeTrail.Set(on)
    State.KnifeTrail = on
    if on then
        for _, projectile in ipairs(CS:GetTagged("ThrowingKnife")) do track(projectile) end
        Util.Bind("knifetrailadd", CS:GetInstanceAddedSignal("ThrowingKnife"), function(projectile)

            task.defer(track, projectile)
        end)
        Util.Bind("knifetrail", RunService.Heartbeat, step)
    else
        Util.Unbind("knifetrailadd")
        Util.Unbind("knifetrail")
        KnifeTrail.Clear()
    end
end

function KnifeTrail.Refresh()
    for _, t in pairs(tracked) do
        t.beam.Enabled = State.KnifeTrailPath ~= false
        t.marker.Transparency = State.KnifeTrailMarker == false and 1 or 0.25
        t.danger = nil
    end
end

function KnifeTrail.Destroy()
    KnifeTrail.Set(false)
    local f = workspace:FindFirstChild("RiftwareKnifeTrails")
    if f then pcall(function() f:Destroy() end) end
end

return KnifeTrail
end

__modules["features/AntiStab"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")
local Roles    = import("core/Roles")

local Players    = Services.Players
local RunService = Services.RunService

local AntiStab = {}

AntiStab.Escapes = 0
AntiStab.LastReason = "nothing yet"
AntiStab.Threat = nil

local lastEscape = 0

local function knifeHolders()
    local out = {}

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Services.LocalPlayer and Util.Alive(plr) and not Roles.IsDead(plr) then
            if Roles.Of(plr) == "Murderer" or Roles.HoldingKnife(plr) then
                local char = plr.Character
                local root = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
                if root then
                    table.insert(out, { player = plr, root = root })
                end
            end
        end
    end

    return out
end

local function closingDistance(theirRoot, myPosition, lead)
    local now = (theirRoot.Position - myPosition).Magnitude

    local velocity = theirRoot.AssemblyLinearVelocity
    local soon = ((theirRoot.Position + velocity * lead) - myPosition).Magnitude

    return math.min(now, soon), now
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function buildFilter()
    local filter = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then table.insert(filter, plr.Character) end
    end
    rayParams.FilterDescendantsInstances = filter
    return rayParams
end

local function clearDistance(origin, direction, wanted)
    local result = workspace:Raycast(origin, direction * wanted, buildFilter())
    if not result then return wanted end
    return math.max(0, result.Distance - 2.5)
end

local function bestEscape(myPosition, threatPosition, wanted)
    local away = myPosition - threatPosition
    away = Vector3.new(away.X, 0, away.Z)

    if away.Magnitude < 0.1 then
        away = Vector3.new(1, 0, 0)
    end
    away = away.Unit

    local bestDir, bestScore = nil, -1

    for _, degrees in ipairs({ 0, 30, -30, 60, -60, 90, -90, 135, -135, 180 }) do
        local radians = math.rad(degrees)
        local dir = Vector3.new(
            away.X * math.cos(radians) - away.Z * math.sin(radians),
            0,
            away.X * math.sin(radians) + away.Z * math.cos(radians)
        ).Unit

        local room = clearDistance(myPosition, dir, wanted)
        if room >= 3 then
            local landing = myPosition + dir * room
            local score = (landing - threatPosition).Magnitude

            if degrees == 0 then score = score + 1 end

            if score > bestScore then
                bestScore, bestDir = score, dir * room
            end
        end
    end

    return bestDir, bestScore
end

local function escape(hrp, threatPosition)
    local mode = State.AntiStabMode or "Dash"
    local wanted = State.AntiStabDistance or 20
    local moved = false
    local how = ""

    if mode == "Dash" or mode == "Both" then
        local offset = bestEscape(hrp.Position, threatPosition, wanted)
        if offset then
            hrp.CFrame = hrp.CFrame + offset
            moved = true
            how = ("dashed %.0f studs"):format(offset.Magnitude)
        end
    end

    if mode == "Hop" or mode == "Both" or not moved then

        local hop = State.AntiStabHop or 16
        local headroom = clearDistance(hrp.Position, Vector3.new(0, 1, 0), hop)

        if headroom >= 4 then
            hrp.CFrame = hrp.CFrame + Vector3.new(0, headroom, 0)
            hrp.AssemblyLinearVelocity = Vector3.new(
                hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
            moved = true
            how = how ~= "" and (how .. " + hopped") or ("hopped %.0f studs"):format(headroom)
        end
    end

    return moved, how
end

local function step()
    if not State.AntiStab then return end

    local hrp = Util.HRP()
    if not hrp then return end

    local now = os.clock()
    if now - lastEscape < (State.AntiStabCooldown or 0.35) then return end

    local myPosition = hrp.Position
    local radius = State.AntiStabRadius or 14
    local lead = State.AntiStabReact or 0.2

    local nearest, nearestDist, nearestActual = nil, math.huge, nil

    for _, threat in ipairs(knifeHolders()) do
        local effective, actual = closingDistance(threat.root, myPosition, lead)
        if effective < nearestDist then
            nearest, nearestDist, nearestActual = threat, effective, actual
        end
    end

    AntiStab.Threat = nearest and ("%s at %.0f studs"):format(nearest.player.Name, nearestActual)
        or nil

    if not nearest or nearestDist > radius then return end

    local moved, how = escape(hrp, nearest.root.Position)
    if not moved then
        AntiStab.LastReason = "boxed in, nowhere to go"
        return
    end

    lastEscape = now
    AntiStab.Escapes = AntiStab.Escapes + 1
    AntiStab.LastReason = ("%s closed to %.0f studs -- %s"):format(
        nearest.player.Name, nearestActual, how)

    if State.AntiStabNotify then
        Util.Notify("Anti Stab", AntiStab.LastReason)
    end
end

function AntiStab.Set(on)
    State.AntiStab = on

    if on then

        Util.Bind("antistab", RunService.Heartbeat, step)
    else
        Util.Unbind("antistab")
        AntiStab.Threat = nil
    end
end

function AntiStab.Report()
    local text = table.concat({
        "Enabled: " .. tostring(State.AntiStab),
        "Mode: " .. tostring(State.AntiStabMode),
        "Trigger radius: " .. tostring(State.AntiStabRadius) .. " studs",
        "Escape distance: " .. tostring(State.AntiStabDistance) .. " studs",
        "Current threat: " .. tostring(AntiStab.Threat or "none"),
        "Escapes this session: " .. tostring(AntiStab.Escapes),
        "Last: " .. tostring(AntiStab.LastReason),
    }, "\n")

    print("[Riftware] " .. text)
    return text
end

return AntiStab
end

__modules["features/Counter"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")
local Roles    = import("core/Roles")

local Players = Services.Players
local LP      = Services.LocalPlayer

local Counter = {}

local gui, label
local roundStart = os.clock()
local lastAliveCount = -1

local function guiParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and cg then return cg end
    return LP:WaitForChild("PlayerGui")
end

local function build()
    if gui and gui.Parent then return end

    gui = Instance.new("ScreenGui")
    gui.Name = "RiftwareCounter"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 9998
    gui.Parent = guiParent()

    local holder = Instance.new("Frame")
    holder.Name = "Holder"
    holder.AnchorPoint = Vector2.new(0.5, 0)
    holder.Position = UDim2.new(0.5, 0, 0, 6)
    holder.Size = UDim2.new(0, 260, 0, 24)
    holder.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    holder.BackgroundTransparency = 0.35
    holder.BorderSizePixel = 0
    holder.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = holder

    label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextColor3 = Color3.fromRGB(235, 235, 240)
    label.TextStrokeTransparency = 0.6
    label.Text = "--"
    label.Parent = holder
end

local timerLabel

local function findGameTimer()
    if not (timerLabel and timerLabel.Parent) then
        timerLabel = nil
        local part = workspace:FindFirstChild("RoundTimerPart")
        local surface = part and part:FindFirstChild("SurfaceGui")
        local label = surface and surface:FindFirstChild("Timer")
        if label and label:IsA("TextLabel") then
            timerLabel = label
        end
    end

    if not timerLabel then return nil end

    local text = timerLabel.Text
    if text == "" then return nil end
    return (text:match("^%s*(.-)%s*$"))
end

local function aliveCount()
    local data = Roles.Data()
    if next(data) == nil then

        local n = 0
        for _, plr in ipairs(Players:GetPlayers()) do
            if Util.Alive(plr) then n = n + 1 end
        end
        return n, #Players:GetPlayers()
    end

    local alive, total = 0, 0
    for _, entry in pairs(data) do
        total = total + 1
        if entry.Dead ~= true then alive = alive + 1 end
    end
    return alive, total
end

local function step()
    if not State.ShowCounter then return end
    build()

    local alive, total = aliveCount()

    if alive > lastAliveCount and lastAliveCount ~= -1 and alive >= total - 1 then
        roundStart = os.clock()
    end
    lastAliveCount = alive

    local timer = findGameTimer()
    local clock
    if timer then
        clock = timer
    else
        local elapsed = math.floor(os.clock() - roundStart)
        clock = ("~%d:%02d"):format(math.floor(elapsed / 60), elapsed % 60)
    end

    local murderer = Roles.Murderer()
    local sheriff = Roles.Sheriff()

    label.Text = ("%s   Alive %d/%d   M:%s  S:%s"):format(
        clock,
        alive, total,
        murderer and "yes" or "--",
        sheriff and "yes" or "--"
    )
end

function Counter.Set(on)
    State.ShowCounter = on
    if on then
        roundStart = os.clock()
        lastAliveCount = -1
        Util.Loop("counter", function() return 0.5 end, step)
    else
        Util.Unbind("counter")
        Counter.Destroy()
    end
end

function Counter.Destroy()
    if gui then
        gui:Destroy()
        gui = nil
        label = nil
    end
end

return Counter
end

__modules["features/Perf"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")

local RunService = Services.RunService
local Lighting   = game:GetService("Lighting")
local LP         = Services.LocalPlayer

local Perf = {}

local saved = nil

local EMITTERS = {
    ParticleEmitter = true,
    Trail = true,
    Smoke = true,
    Fire = true,
    Sparkles = true,
    Explosion = true,
}

local function applyPerformance()
    saved = {
        globalShadows = Lighting.GlobalShadows,
        fogEnd = Lighting.FogEnd,
        emitters = {},
        effects = {},
        quality = nil,
        waterWaveSize = nil,
        waterReflectance = nil,
    }

    pcall(function()
        saved.quality = settings().Rendering.QualityLevel
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)

    pcall(function() Lighting.GlobalShadows = false end)

    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then
            saved.effects[effect] = effect.Enabled
            effect.Enabled = false
        end
    end

    pcall(function()
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            saved.waterWaveSize = terrain.WaterWaveSize
            saved.waterReflectance = terrain.WaterReflectance
            terrain.WaterWaveSize = 0
            terrain.WaterReflectance = 0
        end
    end)

    for _, inst in ipairs(workspace:GetDescendants()) do
        if EMITTERS[inst.ClassName] and inst.Enabled ~= nil then
            saved.emitters[inst] = inst.Enabled
            inst.Enabled = false
        end
    end
end

local function restorePerformance()
    if not saved then return end

    pcall(function()
        if saved.quality then settings().Rendering.QualityLevel = saved.quality end
    end)
    pcall(function() Lighting.GlobalShadows = saved.globalShadows end)

    for effect, enabled in pairs(saved.effects) do
        if effect.Parent then pcall(function() effect.Enabled = enabled end) end
    end

    pcall(function()
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain and saved.waterWaveSize then
            terrain.WaterWaveSize = saved.waterWaveSize
            terrain.WaterReflectance = saved.waterReflectance
        end
    end)

    for emitter, enabled in pairs(saved.emitters) do
        if emitter.Parent then pcall(function() emitter.Enabled = enabled end) end
    end

    saved = nil
end

local function muteNewEffects()
    if not State.PerformanceMode or not saved then return end

    for _, inst in ipairs(workspace:GetDescendants()) do
        if EMITTERS[inst.ClassName] and inst.Enabled == true then
            saved.emitters[inst] = saved.emitters[inst] == nil and true or saved.emitters[inst]
            inst.Enabled = false
        end
    end
end

function Perf.SetPerformance(on)
    State.PerformanceMode = on

    if on then
        applyPerformance()
        Util.Loop("perfmute", function() return 3 end, muteNewEffects)
    else
        Util.Unbind("perfmute")
        restorePerformance()
    end
end

local Icons = import("features/Icons")

local gui, pill, fpsLabel, pingLabel, clockLabel
local frames, lastSample, currentFps = 0, os.clock(), 0

Perf.Fps = 0
Perf.Ping = 0
local PUMPKIN = Color3.fromRGB(255, 122, 26)
local POTION  = Color3.fromRGB(139, 61, 255)

local function spooky() return State.UITheme ~= "Classic" end

local TEXT = Color3.fromRGB(196, 196, 206)

local function guiParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and cg then return cg end
    return LP:WaitForChild("PlayerGui")
end

local function destroyFps()
    Util.Unbind("fpscount")
    Util.Unbind("fpsdraw")
    Util.Unbind("fpsdrag")
    Util.Unbind("fpsdragend")
    if gui then
        gui:Destroy()
        gui, pill, fpsLabel, pingLabel, clockLabel = nil, nil, nil, nil, nil
    end
end

local function colorFor(fps)
    if fps >= 55 then return Color3.fromRGB(80, 230, 120) end
    if fps >= 40 then return Color3.fromRGB(180, 230, 90) end
    if fps >= 28 then return Color3.fromRGB(255, 205, 70) end
    if fps >= 18 then return Color3.fromRGB(255, 140, 60) end
    return Color3.fromRGB(255, 70, 70)
end

Perf.ColorFor = colorFor

local function pingMs()
    local ms
    pcall(function()
        ms = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    if type(ms) ~= "number" or ms <= 0 then
        pcall(function() ms = LP:GetNetworkPing() * 2000 end)
    end
    return math.floor((tonumber(ms) or 0) + 0.5)
end

Perf.PingMs = pingMs

local function clockText()
    local t = os.date("*t")
    local hour = t.hour % 12
    if hour == 0 then hour = 12 end
    return ("%d:%02d %s"):format(hour, t.min, t.hour < 12 and "AM" or "PM")
end

Perf.ClockText = clockText

local function countFrame()
    frames = frames + 1
end

local function sample()
    local now = os.clock()
    local elapsed = now - lastSample
    if elapsed <= 0 then return end

    currentFps = math.floor(frames / elapsed + 0.5)
    Perf.Fps = currentFps
    Perf.Ping = pingMs()
    frames = 0
    lastSample = now

    if fpsLabel then
        fpsLabel.Text = tostring(currentFps) .. " FPS"

        fpsLabel.TextColor3 = currentFps >= 40 and TEXT or colorFor(currentFps)
    end
    if pingLabel then pingLabel.Text = tostring(Perf.Ping) .. " MS" end
    if clockLabel then clockLabel.Text = clockText() end
end

Perf.Sample = sample

local function viewport()
    local cam = workspace.CurrentCamera
    local v = cam and cam.ViewportSize
    if typeof(v) == "Vector2" and v.X > 0 then return v end
    return Vector2.new(1280, 720)
end

function Perf.SetFps(on)
    State.FpsCounter = on
    destroyFps()
    if not on then return end

    local vp = viewport()
    local phone = vp.Y < 560 or vp.X < 760
    local h = phone and 34 or 42
    local size = phone and 13 or 16
    local iconSize = phone and 15 or 19

    gui = Instance.new("ScreenGui")
    gui.Name = "RiftwareFps"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 9997
    gui.Parent = guiParent()

    pill = Instance.new("Frame")
    pill.Name = "Pill"
    pill.AnchorPoint = Vector2.new(0.5, 0)
    pill.Position = UDim2.new(0.5, 0, 0, phone and 8 or 12)
    pill.Size = UDim2.fromOffset(0, h)
    pill.AutomaticSize = Enum.AutomaticSize.X
    local halloween = spooky()
    local accent = halloween and PUMPKIN or Color3.fromRGB(225, 228, 236)
    pill.BackgroundColor3 = halloween and Color3.fromRGB(30, 18, 38) or Color3.fromRGB(30, 30, 40)
    pill.BackgroundTransparency = 0.08
    pill.BorderSizePixel = 0
    pill.Active = true
    pill.Parent = gui

    local round = Instance.new("UICorner")
    round.CornerRadius = UDim.new(1, 0)
    round.Parent = pill
    local outline = Instance.new("UIStroke")
    outline.Color = halloween and Color3.new(1, 1, 1) or accent
    outline.Transparency = 0.25
    outline.Thickness = 1.5
    outline.Parent = pill
    if halloween then
        local flow = Instance.new("UIGradient")
        flow.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, PUMPKIN), ColorSequenceKeypoint.new(1, POTION) })
        flow.Parent = outline
    end
    local sheen = Instance.new("UIGradient")
    sheen.Rotation = 90
    sheen.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(175, 175, 190)) })
    sheen.Parent = pill
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft, padding.PaddingRight = UDim.new(0, phone and 14 or 20), UDim.new(0, phone and 14 or 20)
    padding.Parent = pill
    local list = Instance.new("UIListLayout")
    list.FillDirection = Enum.FillDirection.Horizontal
    list.VerticalAlignment = Enum.VerticalAlignment.Center
    list.Padding = UDim.new(0, phone and 8 or 11)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = pill

    local n = 0
    local function text(name, value, bold, color)
        n = n + 1
        local l = Instance.new("TextLabel")
        l.Name = name
        l.BackgroundTransparency = 1
        l.AutomaticSize = Enum.AutomaticSize.X
        l.Size = UDim2.fromOffset(0, h)
        l.Font = bold and Enum.Font.GothamBold or Enum.Font.GothamMedium
        l.TextSize = size
        l.TextColor3 = color or TEXT
        l.Text = value
        l.LayoutOrder = n
        l.Parent = pill
        return l
    end
    local function glyph(iconName)
        n = n + 1
        local img = Instance.new("ImageLabel")
        img.Name = "Icon"
        img.BackgroundTransparency = 1
        img.Image = Icons.Get(iconName)
        img.ImageColor3 = accent
        img.Size = UDim2.fromOffset(iconSize, iconSize)
        img.LayoutOrder = n
        img.Parent = pill
    end
    local function dot()
        text("Dot", "\u{00B7}", true, halloween and Color3.fromRGB(150, 100, 200) or Color3.fromRGB(120, 120, 132))
    end

    text("Brand", "RIFTWARE", true, Color3.fromRGB(240, 240, 246))
    n = n + 1
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.BackgroundColor3 = halloween and Color3.fromRGB(110, 70, 140) or Color3.fromRGB(90, 90, 104)
    divider.BorderSizePixel = 0
    divider.Size = UDim2.fromOffset(1, h - 16)
    divider.LayoutOrder = n
    divider.Parent = pill
    glyph("activity")
    fpsLabel = text("Fps", "-- FPS")
    dot()
    glyph("wifi")
    pingLabel = text("Ping", "-- MS")
    dot()
    glyph("clock")
    clockLabel = text("Clock", clockText())

    local dragging, startPos, startInput
    pill.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, startPos, startInput = true, pill.Position, input.Position
        end
    end)
    local UIS = game:GetService("UserInputService")
    Util.Bind("fpsdrag", UIS.InputChanged, function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - startInput
            pill.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    Util.Bind("fpsdragend", UIS.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    frames, lastSample = 0, os.clock()
    Util.Bind("fpscount", RunService.RenderStepped, countFrame)
    Util.Loop("fpsdraw", function() return 0.5 end, sample)
end

function Perf.Destroy()
    destroyFps()
    Util.Unbind("perfmute")
    restorePerformance()
end

return Perf
end

__modules["features/Fling"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")
local Roles    = import("core/Roles")

local LP = Services.LocalPlayer

local Fling = {}

local flinging = false

Fling.LastResult = "never run"

function Fling.IsFlinging()
    return flinging
end

function Fling.Stop()
    flinging = false
end

local LINEAR  = 9e7
local ANGULAR = 9e8

local function collidable(a, b)
    local ok, result = pcall(function()
        return game:GetService("PhysicsService"):CollisionGroupsAreCollidable(a.CollisionGroup, b.CollisionGroup)
    end)
    if ok and result == false then return false end
    return true
end

local function zeroAll(char)
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
    end
end

local function run(player)
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = hum and (hum.RootPart or char:FindFirstChild("HumanoidRootPart"))

    local tChar = player.Character
    local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
    local tRoot = tChar and ((tHum and tHum.RootPart) or tChar:FindFirstChild("HumanoidRootPart"))
    local tHead = tChar and tChar:FindFirstChild("Head")

    if not (root and hum and tRoot and tHum) then
        flinging = false
        Fling.LastResult = "missing a character"
        return
    end

    if not collidable(root, tRoot) then
        Util.Notify("Fling", "Players don't collide on this server -- nothing can fling them.")
    end

    local origin = root.CFrame
    local duration = State.FlingDuration or 2.5

    local oldFPDH = workspace.FallenPartsDestroyHeight
    pcall(function() workspace.FallenPartsDestroyHeight = 0 / 0 end)

    local camera = workspace.CurrentCamera
    local oldSubject = camera and camera.CameraSubject
    if camera then pcall(function() camera.CameraSubject = tHead or tHum end) end

    local bv = Instance.new("BodyVelocity")
    bv.Name = "RiftwareFling"
    bv.Velocity = Vector3.new(LINEAR, LINEAR * 10, LINEAR)
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Parent = root

    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end)

    local target = tRoot
    if tHead and (tRoot.Position - tHead.Position).Magnitude > 5 then target = tHead end

    local started = os.clock()
    local angle = 0
    local thrown = false

    local function stop()
        return not flinging
            or not root.Parent or not target.Parent
            or hum.Health <= 0 or tHum.Sit
            or player.Parent == nil or player.Character ~= tChar
            or os.clock() - started > duration
    end

    local function place(offset, rot)
        local lead = tHum.MoveDirection * (target.AssemblyLinearVelocity.Magnitude / 1.25)
        local cf = CFrame.new(target.Position) * (CFrame.new(offset) + lead) * rot
        root.CFrame = cf
        root.AssemblyLinearVelocity = Vector3.new(LINEAR, LINEAR * 10, LINEAR)
        root.AssemblyAngularVelocity = Vector3.new(ANGULAR, ANGULAR, ANGULAR)
        task.wait()
        if target.AssemblyLinearVelocity.Magnitude > 500 then thrown = true end
    end

    while not stop() and not thrown do
        local speed = target.AssemblyLinearVelocity.Magnitude
        if speed < 50 then

            angle = angle + 100
            local spin = CFrame.Angles(math.rad(angle), 0, 0)
            for _, offset in ipairs({
                Vector3.new(0, 1.5, 0), Vector3.new(0, -1.5, 0),
                Vector3.new(2.25, 1.5, -2.25), Vector3.new(-2.25, -1.5, 2.25),
                Vector3.new(0, 1.5, 0), Vector3.new(0, -1.5, 0),
            }) do
                if stop() or thrown then break end
                place(offset, spin)
            end
        else

            local ahead = tHum.WalkSpeed
            local far = speed / 1.25
            local up = CFrame.Angles(math.rad(90), 0, 0)
            local flat = CFrame.Angles(0, 0, 0)
            for _, step in ipairs({
                { Vector3.new(0, 1.5, ahead), up }, { Vector3.new(0, -1.5, -ahead), flat },
                { Vector3.new(0, 1.5, ahead), up }, { Vector3.new(0, 1.5, far), up },
                { Vector3.new(0, -1.5, -far), flat }, { Vector3.new(0, 1.5, far), up },
                { Vector3.new(0, -1.5, 0), up }, { Vector3.new(0, -1.5, 0), flat },
                { Vector3.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0) },
            }) do
                if stop() or thrown then break end
                place(step[1], step[2])
            end
        end
    end

    pcall(function() bv:Destroy() end)
    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true) end)
    if camera then pcall(function() camera.CameraSubject = oldSubject or hum end) end

    local back = os.clock()
    repeat
        if not root.Parent then break end
        root.CFrame = origin * CFrame.new(0, 0.5, 0)
        zeroAll(char)
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
        task.wait()
    until (root.Position - origin.Position).Magnitude < 25 or os.clock() - back > 3

    zeroAll(char)
    pcall(function() workspace.FallenPartsDestroyHeight = oldFPDH end)

    Fling.LastResult = thrown and ("flung " .. player.Name) or ("couldn't move " .. player.Name)
    flinging = false
end

function Fling.At(player)
    if flinging then return false, "already flinging" end
    if not player or not player.Character then return false, "no target" end
    if not Util.HRP() then return false, "no character" end

    flinging = true
    task.spawn(run, player)
    return true
end

function Fling.Murderer()
    local target = Roles.Murderer()
    if not target then
        Util.Notify("Fling", "No murderer found.")
        return false
    end
    return Fling.At(target)
end

function Fling.Sheriff()
    local target = Roles.Sheriff()
    if not target then
        Util.Notify("Fling", "No sheriff found.")
        return false
    end
    return Fling.At(target)
end

function Fling.Named(name)
    local target = Util.FindPlayer(name)
    if not target then
        Util.Notify("Fling", "Player '" .. tostring(name) .. "' not found.")
        return false
    end
    return Fling.At(target)
end

return Fling
end

__modules["features/AntiFling"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")
local Fling    = import("features/Fling")

local Players    = Services.Players
local RunService = Services.RunService
local LP         = Services.LocalPlayer

local AntiFling = {}

AntiFling.Blocked = 0

local lastSafe = nil
local originals = setmetatable({}, { __mode = "k" })

local function clampStep()
    if not State.AntiFling then return end

    if Fling.IsFlinging() then
        lastSafe = nil
        return
    end

    local hrp = Util.HRP()
    if not hrp then return end

    local humanoid = Util.Humanoid()
    local maxSpeed = State.AntiFlingMax or 150

    local linear = hrp.AssemblyLinearVelocity
    local angular = hrp.AssemblyAngularVelocity

    local launched = linear.Magnitude > maxSpeed or angular.Magnitude > maxSpeed

    if launched then

        hrp.AssemblyLinearVelocity = Vector3.new(0, math.min(linear.Y, 0), 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

        if humanoid then
            humanoid.PlatformStand = false
            humanoid.Sit = false
        end

        local snap = State.AntiFlingSnap or 40
        if lastSafe and (hrp.Position - lastSafe.Position).Magnitude > snap then
            hrp.CFrame = lastSafe
        end

        AntiFling.Blocked = AntiFling.Blocked + 1
        return
    end

    if linear.Magnitude < 60 then
        lastSafe = hrp.CFrame
    end
end

local function neutralise(part)
    if originals[part] == nil then
        originals[part] = { canCollide = part.CanCollide, massless = part.Massless }
    end

    if part.CanCollide or not part.Massless then
        part.CanCollide = false
        part.Massless = true
    end
end

local function restorePart(part)
    local saved = originals[part]
    if not saved then return end
    originals[part] = nil

    if not part.Parent then return end
    pcall(function()
        part.CanCollide = saved.canCollide
        part.Massless = saved.massless
    end)
end

local function collisionStep()
    if not State.AntiFling or not State.AntiFlingCollisions then return end

    if Fling.IsFlinging() then
        AntiFling.RestoreAll()
        return
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local char = plr.Character
            if char then
                for _, part in ipairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        pcall(neutralise, part)
                    end
                end
            end
        end
    end
end

function AntiFling.RestoreAll()
    for part in pairs(originals) do
        restorePart(part)
    end
end

function AntiFling.Set(on)
    State.AntiFling = on

    if on then
        lastSafe = nil
        Util.Bind("antifling", RunService.Heartbeat, clampStep)
        Util.Loop("antiflingparts", function() return 0.5 end, collisionStep)
    else
        Util.Unbind("antifling")
        Util.Unbind("antiflingparts")
        AntiFling.RestoreAll()
        lastSafe = nil
    end
end

function AntiFling.SetCollisions(on)
    State.AntiFlingCollisions = on
    if not on then
        AntiFling.RestoreAll()
    end
end

return AntiFling
end

__modules["features/Boxes"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")
local Webhook  = import("core/Webhook")

local Boxes = {}

Boxes.Opened = 0

local function sync()
    return Services.Sync
end

function Boxes.List()
    local names, lookup = {}, {}
    local data = sync()
    if not data or not data.MysteryBox then return names, lookup end

    for boxId, info in pairs(data.MysteryBox) do
        local label = (info.Name or boxId) .. "  (" .. boxId .. ")"
        table.insert(names, label)
        lookup[label] = boxId
    end

    table.sort(names)
    return names, lookup
end

function Boxes.Currencies(boxId)
    local out = {}
    local data = sync()
    if not data or not data.NewShop or not boxId then return out end

    local entry = data.NewShop[boxId]
    if not entry or type(entry.Price) ~= "table" then return out end

    for currency in pairs(entry.Price) do
        table.insert(out, currency)
    end
    table.sort(out)
    return out
end

local PREFERRED = { "Coins", "Gems", "Key" }

function Boxes.AutoCurrency(boxId)
    local options = Boxes.Currencies(boxId)
    if #options == 0 then return nil end

    local available = {}
    for _, name in ipairs(options) do available[name] = true end

    for _, name in ipairs(PREFERRED) do
        if available[name] then return name end
    end

    for _, name in ipairs(options) do
        if name ~= "Robux" then return name end
    end

    return nil
end

function Boxes.Price(boxId, currency)
    local data = sync()
    if not data or not data.NewShop or not boxId or not currency then return nil end
    local entry = data.NewShop[boxId]
    return entry and entry.Price and entry.Price[currency]
end

local function itemInfo(itemId)
    local data = sync()
    if not data or not data.Weapons or not itemId then return nil end
    return data.Weapons[itemId]
end

function Boxes.BoxName(boxId)
    local data = sync()
    local info = data and data.MysteryBox and data.MysteryBox[boxId]
    return info and info.Name or boxId
end

function Boxes.Open(boxId, currency)
    boxId = boxId or State.BoxId
    if not boxId then return nil, "no box selected" end

    currency = currency or Boxes.AutoCurrency(boxId)
    if not currency then
        return nil, "this box has no currency price (Robux-only or event-only)"
    end

    local openCrate = Services.Shop:FindFirstChild("OpenCrate")
    if not openCrate then return nil, "Remotes.Shop.OpenCrate missing" end

    local ok, rewarded = pcall(function()
        return openCrate:InvokeServer(boxId, "MysteryBox", currency)
    end)

    if not ok then return nil, tostring(rewarded) end
    if not rewarded then return nil, "server refused (can't afford / not owned?)" end

    Boxes.Opened = Boxes.Opened + 1

    if State.BoxAnimation then
        local controller = Services.Shop:FindFirstChild("BoxController")
        if controller then
            pcall(function()
                controller:Fire({ { MysteryBoxId = boxId, RewardedItemId = rewarded } })
            end)
        end
    end

    if State.WebhookLogging and State.WebhookUrl ~= "" then
        local info = itemInfo(rewarded)
        task.spawn(function()
            local sent, err = Webhook.LogUnbox(State.WebhookUrl, {
                boxId = boxId,
                boxName = Boxes.BoxName(boxId),
                itemId = rewarded,
                itemName = info and (info.ItemName or info.Name) or rewarded,
                rarity = info and info.Rarity or nil,
                image = info and info.Image or nil,
                currency = currency,
                opened = Boxes.Opened,
                player = Services.LocalPlayer.Name,
            })
            if not sent then
                warn("[Riftware] webhook failed: " .. tostring(err))
            end
        end)
    end

    return rewarded
end

function Boxes.SetAuto(on)
    State.AutoBox = on
    if on then
        Util.Loop("autobox", function()
            return State.BoxDelay or 1.5
        end, function()
            if not State.AutoBox then return end
            local rewarded, err = Boxes.Open()
            if not rewarded then
                Util.Notify("Auto Box", "Stopped: " .. tostring(err))
                State.AutoBox = false
                Util.Unbind("autobox")
                return
            end
            local info = itemInfo(rewarded)
            Util.Notify("Unboxed", (info and (info.ItemName or info.Name) or rewarded)
                .. (info and info.Rarity and (" [" .. info.Rarity .. "]") or ""))
        end)
    else
        Util.Unbind("autobox")
    end
end

function Boxes.TestWebhook()
    if State.WebhookUrl == "" then
        Util.Notify("Webhook", "Paste a webhook URL first.")
        return false
    end
    if not Webhook.Available() then
        Util.Notify("Webhook", "Your executor has no http request function.")
        return false
    end

    local ok, err = Webhook.Post(State.WebhookUrl, {
        username = "Riftware",
        content = "Webhook connected. Logging unboxes for **"
            .. Services.LocalPlayer.Name .. "**.",
    })

    Util.Notify("Webhook", ok and "Test message sent." or ("Failed: " .. tostring(err)))
    return ok
end

return Boxes
end

__modules["features/Crafting"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")
local Webhook  = import("core/Webhook")

local RS = game:GetService("ReplicatedStorage")

local Crafting = {}

Crafting.Crafted  = 0
Crafting.Salvaged = 0

Crafting.SalvageRarities = { "Common", "Uncommon", "Rare", "Legendary" }

local COLORS = {
    Common = 0x9CA3AF, Uncommon = 0x22C55E, Rare = 0x3B82F6,
    Legendary = 0xA855F7, Godly = 0xEF4444, Ancient = 0xA06EFF,
}

local profile = nil

local function ProfileData()
    if profile ~= nil then return profile or nil end
    local ok, result = pcall(function()
        return require(RS:WaitForChild("Modules", 10):WaitForChild("ProfileData", 10))
    end)
    profile = (ok and type(result) == "table" and result) or false
    return profile or nil
end

Crafting.ProfileData = ProfileData

local function sync() return Services.Sync end

local function remote(name)
    local remotes = Services.Remotes
    local inv = remotes and remotes:FindFirstChild("Inventory")
    return inv and inv:FindFirstChild(name)
end

function Crafting.Recipes()
    local data = sync()
    return (data and type(data.Recipes) == "table") and data.Recipes or {}
end

function Crafting.MaterialName(id)
    local data = sync()
    local m = data and data.Materials and data.Materials[id]
    return (m and m.Name) or tostring(id)
end

function Crafting.ItemInfo(id, kind)
    local data = sync()
    if not data then return nil end
    local tbl = kind and data[kind]
    local info = (type(tbl) == "table" and tbl[id]) or (data.Item and data.Item[id]) or (data.Weapons and data.Weapons[id])
    return info
end

local function owned(kind)
    local p = Crafting.ProfileData()
    local t = p and p[kind]
    return (t and type(t.Owned) == "table") and t.Owned or {}
end

function Crafting.Owned(mat) return owned("Materials")[mat] or 0 end

function Crafting.List()
    local rows = {}
    for id, r in pairs(Crafting.Recipes()) do
        if type(r) == "table" and type(r.Materials) == "table" then
            table.insert(rows, { id = id, r = r })
        end
    end
    table.sort(rows, function(a, b) return (a.r.SortPriority or 0) < (b.r.SortPriority or 0) end)
    local names, lookup = {}, {}
    for _, row in ipairs(rows) do
        local label = row.r.Name or row.id
        table.insert(names, label)
        lookup[label] = row.id
    end
    return names, lookup
end

function Crafting.Affordable(recipeId)
    local r = Crafting.Recipes()[recipeId]
    if not r or type(r.Materials) ~= "table" then return 0 end
    local times = math.huge
    for mat, need in pairs(r.Materials) do
        if need > 0 then times = math.min(times, math.floor(Crafting.Owned(mat) / need)) end
    end
    return times == math.huge and 0 or times
end

function Crafting.Describe(recipeId)
    local r = Crafting.Recipes()[recipeId]
    if not r then return "Pick a recipe." end
    local parts = {}
    for mat, need in pairs(r.Materials or {}) do
        table.insert(parts, ("%s %d/%d"):format(Crafting.MaterialName(mat), Crafting.Owned(mat), need))
    end
    table.sort(parts)
    return table.concat(parts, "  •  ") .. ("\nCan craft: %d"):format(Crafting.Affordable(recipeId))
end

local function webhookUrl()
    local url = State.CraftWebhookUrl
    if type(url) ~= "string" or url == "" then url = State.WebhookUrl end
    return url
end

local function post(embed)
    local url = webhookUrl()
    if type(url) ~= "string" or url == "" then return end
    embed.footer = { text = Services.LocalPlayer.Name .. " • Riftware" }
    pcall(function() embed.timestamp = DateTime.now():ToIsoDate() end)
    task.spawn(function()
        local ok, err = Webhook.Post(url, { username = "Riftware", embeds = { embed } })
        if not ok then warn("[Riftware] craft webhook failed: " .. tostring(err)) end
    end)
end

local function materialsText(list)
    local parts = {}
    for mat, n in pairs(list or {}) do
        table.insert(parts, ("%dx %s"):format(n, Crafting.MaterialName(mat)))
    end
    table.sort(parts)
    return #parts > 0 and table.concat(parts, "\n") or "-"
end

function Crafting.LogCraft(recipeId, itemId, amount, kind)
    local r = Crafting.Recipes()[recipeId] or {}
    local info = Crafting.ItemInfo(itemId, kind) or {}
    local rarity = info.Rarity or r.Rarity
    local embed = {
        title = "Crafted " .. tostring(info.ItemName or info.Name or itemId),
        color = COLORS[rarity or ""] or 0x5865F2,
        fields = {
            { name = "Recipe", value = tostring(r.Name or recipeId), inline = true },
            { name = "Rarity", value = tostring(rarity or "?"), inline = true },
            { name = "Amount", value = tostring(amount or 1), inline = true },
            { name = "Spent", value = materialsText(r.Materials), inline = true },
            { name = "Crafted This Session", value = tostring(Crafting.Crafted), inline = true },
        },
    }
    local thumb = Webhook.AssetThumbnail(info.Image or r.Image)
    if thumb then embed.thumbnail = { url = thumb } end
    post(embed)
    return embed
end

local batch = { items = {}, gained = {}, count = 0 }

function Crafting.FlushSalvageLog()
    if batch.count == 0 then return nil end
    local items = {}
    for name, n in pairs(batch.items) do table.insert(items, ("%dx %s"):format(n, name)) end
    table.sort(items)
    local embed = {
        title = ("Salvaged %d item%s"):format(batch.count, batch.count == 1 and "" or "s"),
        color = 0xF59E0B,
        fields = {
            { name = "Items", value = table.concat(items, "\n"):sub(1, 1000), inline = true },
            { name = "Gained", value = materialsText(batch.gained), inline = true },
            { name = "Salvaged This Session", value = tostring(Crafting.Salvaged), inline = true },
        },
    }
    batch = { items = {}, gained = {}, count = 0 }
    if State.LogSalvages then post(embed) end
    return embed
end

local busy = false

function Crafting.Craft(recipeId)
    recipeId = recipeId or State.CraftRecipe
    if not recipeId or not Crafting.Recipes()[recipeId] then return nil, "pick a recipe" end
    if Crafting.Affordable(recipeId) < 1 then return nil, "not enough materials" end
    local rf = remote("Craft")
    if not rf then return nil, "Remotes.Inventory.Craft missing" end
    if busy then return nil, "busy" end

    busy = true
    local ok, itemId, amount, kind = pcall(function() return rf:InvokeServer(recipeId) end)
    busy = false

    if not ok then return nil, tostring(itemId) end
    if not itemId then return nil, "server refused" end

    Crafting.Crafted = Crafting.Crafted + 1

    pcall(function()
        local popup = require(RS.ClientServices.ItemPopupService)
        popup:AddNewItem(itemId, kind, amount)
    end)
    if State.LogCrafts then Crafting.LogCraft(recipeId, itemId, amount, kind) end
    return itemId, amount, kind
end

function Crafting.ItemName(itemId, kind)
    local info = Crafting.ItemInfo(itemId, kind)
    return (info and (info.ItemName or info.Name)) or tostring(itemId)
end

function Crafting.NextRecipe()
    if not State.CraftAny then
        return (State.CraftRecipe and Crafting.Affordable(State.CraftRecipe) > 0) and State.CraftRecipe or nil
    end
    local best, bestPri = nil, -math.huge
    for id, r in pairs(Crafting.Recipes()) do
        if Crafting.Affordable(id) > 0 and (r.SortPriority or 0) > bestPri then
            best, bestPri = id, r.SortPriority or 0
        end
    end
    return best
end

local function stopCraft(msg)
    State.AutoCraft = false
    Util.Unbind("autocraft")
    Crafting.FlushSalvageLog()
    if msg then Util.Notify("Auto Craft", msg) end
    if Crafting.OnStop then pcall(Crafting.OnStop, "craft") end
end

local gatherStep

local function craftStep()
    if not State.AutoCraft or busy then return end
    local id = Crafting.NextRecipe()
    if not id then

        if State.CraftMaterials and State.CraftRecipe then
            local did, why = gatherStep(State.CraftRecipe)
            if did then return end
            if not State.AutoSalvage then stopCraft(("Stopped: %s. Crafted %d."):format(why, Crafting.Crafted)) end
            return
        end

        if not State.AutoSalvage then stopCraft(("Out of materials. Crafted %d."):format(Crafting.Crafted)) end
        return
    end
    local itemId, amountOrErr, kind = Crafting.Craft(id)
    if not itemId then
        if amountOrErr ~= "busy" then stopCraft("Stopped: " .. tostring(amountOrErr)) end
        return
    end
    Util.Notify("Crafted", Crafting.ItemName(itemId, kind))
end

Crafting.CraftStep = craftStep

function Crafting.SetAutoCraft(on)
    State.AutoCraft = on
    if on then
        Util.Loop("autocraft", function() return State.CraftDelay or 1 end, craftStep)
    else
        Util.Unbind("autocraft")
    end
end

local function allowedRarity(rarity)
    for _, r in ipairs(Crafting.SalvageRarities) do
        if r == rarity then return State["Salvage" .. r] == true end
    end
    return false
end

function Crafting.Salvageable(id)
    local data = sync()
    local w = data and data.Weapons and data.Weapons[id]
    if not w then return false end
    if data.Codes and data.Codes[id] then return false end
    if w.Season ~= nil or w.ItemType == "Misc" then return false end
    local rewards = data.SalvageRewards or {}
    local has = rewards[id] or rewards[w.Rarity]
    if not has then return false end
    if w.Event ~= nil and not rewards[id] then return false end
    return true
end

local function equipped(id)
    local p = Crafting.ProfileData()
    local eq = p and p.Weapons and p.Weapons.Equipped
    return eq and (eq.Knife == id or eq.Gun == id)
end

function Crafting.NextSalvage()
    local data = sync()
    local keep = State.SalvageKeepOne ~= false and 1 or 0
    local pick, pickN = nil, -1
    for id, n in pairs(owned("Weapons")) do
        local w = data and data.Weapons and data.Weapons[id]
        if type(n) == "number" and n > keep and w and allowedRarity(w.Rarity)
            and not equipped(id) and Crafting.Salvageable(id) then
            if n > pickN then pick, pickN = id, n end
        end
    end
    return pick
end

function Crafting.SalvageYield(id)
    local data = sync()
    local w = data and data.Weapons and data.Weapons[id]
    local rewards = data and data.SalvageRewards or {}
    local entry = rewards[id] or (w and rewards[w.Rarity])
    return (entry and entry.Rewards) or {}
end

function Crafting.Missing(recipeId)
    local r = Crafting.Recipes()[recipeId]
    local out = {}
    for mat, need in pairs((r and r.Materials) or {}) do
        local have = Crafting.Owned(mat)
        if have < need then out[mat] = need - have end
    end
    return out
end

function Crafting.MaterialRecipeFor(mat)
    for id, r in pairs(Crafting.Recipes()) do
        if type(r) == "table" and r.RewardType == "Materials" and r.RewardItem == mat then return id end
    end
    return nil
end

function Crafting.NextSalvageFor(mat)
    local data = sync()
    local keep = State.SalvageKeepOne ~= false and 1 or 0
    local pick, pickN = nil, -1
    for id, n in pairs(owned("Weapons")) do
        local w = data and data.Weapons and data.Weapons[id]
        if type(n) == "number" and n > keep and w and allowedRarity(w.Rarity)
            and not equipped(id) and Crafting.Salvageable(id) and Crafting.SalvageYield(id)[mat] then
            if n > pickN then pick, pickN = id, n end
        end
    end
    return pick
end

local function gather(recipeId, depth)
    local missing = Crafting.Missing(recipeId)
    local names = {}
    for mat in pairs(missing) do
        table.insert(names, Crafting.MaterialName(mat))
        local sub = Crafting.MaterialRecipeFor(mat)
        if sub and sub ~= recipeId then
            if Crafting.Affordable(sub) > 0 then
                local itemId, err = Crafting.Craft(sub)
                if itemId then return "crafted", mat end
                if err == "busy" then return "busy", mat end
            elseif depth < 3 then
                local did = gather(sub, depth + 1)
                if did then return did, mat end
            end
        end
        local weapon = Crafting.NextSalvageFor(mat)
        if weapon then
            local result, err = Crafting.Salvage(weapon)
            if result then return "salvaged", mat end
            if err == "busy" then return "busy", mat end
        end
    end
    if #names == 0 then return nil, "nothing missing" end
    table.sort(names)
    return nil, "can't make more " .. table.concat(names, ", ")
end

gatherStep = function(recipeId) return gather(recipeId, 0) end
Crafting.GatherStep = gatherStep

function Crafting.Salvage(id)
    if not id then return nil, "nothing to salvage" end
    local rf = remote("Salvage")
    if not rf then return nil, "Remotes.Inventory.Salvage missing" end
    if busy then return nil, "busy" end

    busy = true
    local ok, result = pcall(function() return rf:InvokeServer(id) end)
    busy = false

    if not ok then return nil, tostring(result) end
    if not result then return nil, "server refused" end

    Crafting.Salvaged = Crafting.Salvaged + 1
    local name = Crafting.ItemName(id, "Weapons")
    batch.count = batch.count + 1
    batch.items[name] = (batch.items[name] or 0) + 1
    if type(result) == "table" then
        for _, got in pairs(result) do
            if type(got) == "table" and got.ID then
                batch.gained[got.ID] = (batch.gained[got.ID] or 0) + (got.Amount or 1)
            end
        end
    end
    if batch.count >= 25 then Crafting.FlushSalvageLog() end
    return result
end

local function stopSalvage(msg)
    State.AutoSalvage = false
    Util.Unbind("autosalvage")
    Crafting.FlushSalvageLog()
    if msg then Util.Notify("Auto Salvage", msg) end
    if Crafting.OnStop then pcall(Crafting.OnStop, "salvage") end
end

local function salvageStep()
    if not State.AutoSalvage or busy then return end
    local id = Crafting.NextSalvage()
    if not id then
        stopSalvage(("Nothing left to salvage. Salvaged %d."):format(Crafting.Salvaged))
        return
    end
    local result, err = Crafting.Salvage(id)
    if not result and err ~= "busy" then stopSalvage("Stopped: " .. tostring(err)) end
end

Crafting.SalvageStep = salvageStep

function Crafting.SetAutoSalvage(on)
    State.AutoSalvage = on
    if on then
        local any = false
        for _, r in ipairs(Crafting.SalvageRarities) do any = any or State["Salvage" .. r] == true end
        if not any then
            Util.Notify("Auto Salvage", "Pick at least one rarity to salvage.")
            State.AutoSalvage = false
            return false
        end
        Util.Loop("autosalvage", function() return State.SalvageDelay or 1 end, salvageStep)
    else
        Util.Unbind("autosalvage")
        Crafting.FlushSalvageLog()
    end
    return true
end

function Crafting.TestWebhook()
    local url = webhookUrl()
    if type(url) ~= "string" or url == "" then return false, "paste a webhook URL first" end
    return Webhook.Post(url, {
        username = "Riftware",
        content = "Crafting log connected for **" .. Services.LocalPlayer.Name .. "**.",
    })
end

function Crafting.Destroy()
    Crafting.SetAutoCraft(false)
    Util.Unbind("autosalvage")
    State.AutoSalvage = false
    Crafting.FlushSalvageLog()
end

return Crafting
end

__modules["features/Keybinds"] = function(import)

local Util     = import("core/Util")
local State    = import("core/State")

local UIS = game:GetService("UserInputService")

local Keybinds = {}

Keybinds.List = {}
local byId = {}

local CLEAR = { Backspace = true, Delete = true }

function Keybinds.Register(id, label, kind, fn)
    local entry = byId[id]
    if not entry then
        entry = { id = id }
        byId[id] = entry
        table.insert(Keybinds.List, entry)
    end
    entry.label, entry.kind, entry.fn = label, kind, fn
    if State["Bind_" .. id] == nil then State["Bind_" .. id] = "None" end
    return entry
end

function Keybinds.Get(id)
    local key = State["Bind_" .. id]
    return (type(key) == "string" and key ~= "") and key or "None"
end

function Keybinds.Set(id, key)
    if type(key) ~= "string" or key == "" or CLEAR[key] then key = "None" end
    local stolen
    if key ~= "None" then
        if key == Keybinds.MenuKey() then return Keybinds.Get(id), nil, "that's the menu key" end
        for _, other in ipairs(Keybinds.List) do
            if other.id ~= id and Keybinds.Get(other.id) == key then
                State["Bind_" .. other.id] = "None"
                stolen = other.label
                if Keybinds.OnChanged then pcall(Keybinds.OnChanged, other.id, "None") end
            end
        end
    end
    State["Bind_" .. id] = key
    return key, stolen
end

function Keybinds.ClearAll()
    for _, entry in ipairs(Keybinds.List) do
        State["Bind_" .. entry.id] = "None"
        if Keybinds.OnChanged then pcall(Keybinds.OnChanged, entry.id, "None") end
    end
end

Keybinds.ApplyMenuKey = nil

function Keybinds.MenuKey()
    local key = State.MenuKey
    return (type(key) == "string" and key ~= "") and key or "RightShift"
end

function Keybinds.SetMenuKey(key)
    if type(key) ~= "string" or CLEAR[key] or key == "None" then return Keybinds.MenuKey() end
    local code
    pcall(function() code = Enum.KeyCode[key] end)
    if not code then return Keybinds.MenuKey() end

    for _, entry in ipairs(Keybinds.List) do
        if Keybinds.Get(entry.id) == key then
            State["Bind_" .. entry.id] = "None"
            if Keybinds.OnChanged then pcall(Keybinds.OnChanged, entry.id, "None") end
        end
    end
    State.MenuKey = key
    if Keybinds.ApplyMenuKey then pcall(Keybinds.ApplyMenuKey, code) end
    return key
end

function Keybinds.Press(key)
    local hit = false
    for _, entry in ipairs(Keybinds.List) do
        if entry.fn and Keybinds.Get(entry.id) == key then
            hit = true
            local ok, result = pcall(entry.fn)
            if ok and entry.kind == "toggle" and State.KeybindNotify ~= false and result ~= nil then
                Util.Notify("Keybind", ("%s %s"):format(entry.label, result and "ON" or "OFF"))
            elseif not ok then
                warn("[Riftware] keybind " .. entry.id .. " failed: " .. tostring(result))
            end
        end
    end
    return hit
end

local function onInput(input)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    local typing = false
    pcall(function() typing = UIS:GetFocusedTextBox() ~= nil end)
    if typing then return end

    if Keybinds.Picking and Keybinds.Picking() then return end
    Keybinds.Press(input.KeyCode.Name)
end

Keybinds.OnInput = onInput

function Keybinds.Start()
    Util.Bind("keybinds", UIS.InputBegan, onInput)
end

function Keybinds.Destroy()
    Util.Unbind("keybinds")
    Util.Unbind("keybindsync")
end

return Keybinds
end

__modules["features/Halloween"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")
local Roles    = import("core/Roles")

local RS = game:GetService("ReplicatedStorage")

local Halloween = {}

Halloween.Log = {}

local cache = { event = nil, profile = nil, tried = false }

local function load()
    if cache.event and cache.profile then return true end
    local ok = pcall(function()
        local info = require(RS:WaitForChild("SharedServices", 10):WaitForChild("EventInfoService", 10))
        if info.WaitForInitializedAsync then info = info:WaitForInitializedAsync() or info end
        cache.event = info:GetMainEvent()
        cache.profile = require(RS:WaitForChild("Modules", 10):WaitForChild("ProfileData", 10))
    end)
    cache.tried = true
    return ok and cache.event ~= nil and cache.profile ~= nil
end

Halloween.Load = load

function Halloween.SetSource(event, profile)
    cache.event, cache.profile, cache.tried = event, profile, true
end

function Halloween.Event() return cache.event end
local function info() return cache.event and cache.event.EventStartInfo or {} end
local function mine()
    local p, e = cache.profile, cache.event
    return (p and e and p[e.Title]) or nil
end

function Halloween.Remotes()
    local e = cache.event
    if not e then return nil end
    local remotes = Services.Remotes
    local events = remotes and remotes:FindFirstChild("Events")
    return events and events:FindFirstChild(e.Title .. "Remotes")
end

local function remote(name)
    local folder = Halloween.Remotes()
    return folder and folder:FindFirstChild(name)
end

local function fire(name, ...)
    local r = remote(name)
    if not r then return false, name .. " remote missing" end
    local args = { ... }
    local ok, err = pcall(function() r:FireServer(table.unpack(args)) end)
    return ok, err
end

local function note(text)
    table.insert(Halloween.Log, 1, text)
    if #Halloween.Log > 6 then table.remove(Halloween.Log) end
    if State.HalloweenNotify ~= false then Util.Notify("Halloween", text) end
end

function Halloween.Candies()
    local p = cache.profile
    local owned = p and p.Materials and p.Materials.Owned
    local name = info().CurrencyName
    return (owned and name and owned[name]) or 0
end

function Halloween.CurrencyName()
    return info().CurrencyName or "Candies"
end

function Halloween.Tier()
    local m, bp = mine(), info().BattlePass
    return m and m.CurrentTier or 0, bp and bp.TotalTiers or 0
end

function Halloween.ClaimTiers()
    local m, bp = mine(), info().BattlePass
    if not (m and bp and bp.Rewards) then return 0 end
    m.ClaimedRewards = m.ClaimedRewards or {}
    local n = 0
    for key in pairs(bp.Rewards) do
        local tier = tonumber(key)
        if tier and tier <= (m.CurrentTier or 0) and tier ~= bp.TotalTiers and m.ClaimedRewards[key] ~= true then
            if fire("ClaimBattlePassReward", key) then
                m.ClaimedRewards[key] = true
                n = n + 1
            end
        end
    end
    if n > 0 then note(("Claimed %d battle pass reward%s."):format(n, n == 1 and "" or "s")) end
    return n
end

function Halloween.BuyTiers()
    local m, bp = mine(), info().BattlePass
    if not (m and bp and bp.TierCost and bp.TierCost > 0) then return 0 end
    local left = (bp.TotalTiers or 0) - (m.CurrentTier or 0)
    if left <= 0 then return 0 end
    local spend = Halloween.Candies() - (State.HalloweenKeep or 0)
    local n = math.min(left, math.floor(spend / bp.TierCost))
    if n < 1 then return 0 end
    if fire("BuyBattlePassTiers", n) then
        m.CurrentTier = (m.CurrentTier or 0) + n
        local p = cache.profile
        p.Materials.Owned[info().CurrencyName] = Halloween.Candies() - n * bp.TierCost
        note(("Bought %d tier%s (now %d/%d)."):format(n, n == 1 and "" or "s", m.CurrentTier, bp.TotalTiers))
        return n
    end
    return 0
end

function Halloween.BuyFinal()
    local m, bp = mine(), info().BattlePass
    if not (m and bp and bp.FinalRewardCost) then return false end
    if (m.CurrentTier or 0) < (bp.TotalTiers or math.huge) then return false end
    if Halloween.Candies() - (State.HalloweenKeep or 0) < bp.FinalRewardCost then return false end
    if fire("BuyBattlePassFinalReward") then
        m.FinalRewardClaimAmount = (m.FinalRewardClaimAmount or 0) + 1
        cache.profile.Materials.Owned[info().CurrencyName] = Halloween.Candies() - bp.FinalRewardCost
        note(("Bought the final reward (%dx total)."):format(m.FinalRewardClaimAmount))
        return true
    end
    return false
end

local function owns(input)
    local p = cache.profile
    local bucket = p and p[input.ItemType]
    local have = bucket and bucket.Owned and bucket.Owned[input.ItemID] or 0
    return have >= (input.Amount or 1)
end

function Halloween.Craftable()
    local m, recipes = mine(), info().CraftingRecipes
    local out = {}
    if not (m and recipes) then return out end
    m.Crafted = m.Crafted or {}
    for id, r in pairs(recipes) do
        if not m.Crafted[id] and type(r.Input) == "table" then
            local all = #r.Input > 0
            for _, input in ipairs(r.Input) do
                if not owns(input) then all = false break end
            end
            if all then table.insert(out, id) end
        end
    end
    table.sort(out)
    return out
end

function Halloween.CraftAll()
    local m = mine()
    local n = 0
    for _, id in ipairs(Halloween.Craftable()) do
        if fire("CraftRecipe", id) then
            m.Crafted[id] = true
            n = n + 1
            local r = info().CraftingRecipes[id]
            note("Crafted " .. tostring(r and r.Title or id) .. ".")
        end
    end
    return n
end

function Halloween.ClaimGift()
    local m, g = mine(), info().Gifting
    if not (m and g and g.RewardRequiredAmount) then return false end
    local claimed = m.GiftRewardClaimedAmount or 0
    if (m.GiftsGiven or 0) < (claimed + 1) * g.RewardRequiredAmount then return false end
    if fire("ClaimGiftReward") then
        m.GiftRewardClaimedAmount = claimed + 1
        note("Claimed the gifting reward.")
        return true
    end
    return false
end

local function boardSlot(id)
    local board = info().ChallengeBoard
    if not board then return nil end
    for _, v in pairs(board.Cells or {}) do if v == id then return "cell" end end
    for _, v in pairs(board.Rewards or {}) do if v == id then return "reward" end end
    return nil
end

local function progressOf(id)
    local m = mine()
    local entry = m and m.Quests and m.Quests[id]
    return tonumber(entry and entry.Progress) or 0
end

Halloween.ProgressOf = progressOf

local KINDS = {
    { kind = "board",    label = "Fills as board squares finish" },
    { kind = "gift",     label = "Do this one yourself (needs other players)", words = { "gift" } },
    { kind = "craft",    label = "Auto Craft Event Recipes", words = { "craft" } },
    { kind = "collect",  label = "Auto Farm Coins", words = { "coin", "cand", "collect", "bag", "token", "pick up" } },
    { kind = "gun",      label = "Auto Grab Dropped Gun", words = { "grab the gun", "pick up the gun", "dropped gun", "grab gun" } },
    { kind = "murderer", label = "Auto Kill All as murderer", roles = { murderer = true },
      words = { "as murderer", "as the murderer", "stab", "knife" } },
    { kind = "sheriff",  label = "Auto Kill Murderer as sheriff / hero", roles = { sheriff = true, hero = true },
      words = { "sheriff", "hero", "shoot", "kill the murderer" } },
    { kind = "survive",  label = "Anti Stab + Auto Dodge", words = { "survive", "alive", "win" } },
    { kind = "play",     label = "Anti AFK keeps you in rounds", words = { "play", "round", "match" } },
}

function Halloween.QuestKind(q)
    if q.board == "reward" then return "board", KINDS[1].label end
    local text = ((q.title or "") .. " " .. (q.description or "")):lower()
    local role = tostring(q.role or ""):lower()
    for i = 2, #KINDS do
        local k = KINDS[i]
        if k.roles and k.roles[role] then return k.kind, k.label end
        for _, w in ipairs(k.words or {}) do
            if text:find(w, 1, true) then return k.kind, k.label end
        end
    end
    return "other", "Do this one yourself"
end

function Halloween.Quests()
    local quests = info().Quests
    local out = {}
    if not quests then return out end
    for id, q in pairs(quests) do
        local progress = progressOf(id)
        local steps = {}
        for i, step in ipairs(q.Quests or {}) do
            local amount = tonumber(step.ChallengeAmount) or 1
            steps[i] = { amount = amount, rewardId = step.RewardID, rewardType = step.RewardType,
                         rewardAmount = step.RewardAmount or 1, reached = amount <= progress }
        end
        local goal = steps[#steps] and steps[#steps].amount or 1
        local nextStep
        for _, step in ipairs(steps) do
            if not step.reached then nextStep = step break end
        end
        local entry = {
            id = id, title = q.Title or id, description = q.Description or "", role = q.Role,
            progress = progress, goal = goal, done = goal <= progress, steps = steps, nextStep = nextStep,
            board = boardSlot(id), refresh = q.RefreshTime, order = q.LayoutOrder or 0,
        }
        entry.kind, entry.action = Halloween.QuestKind(entry)
        table.insert(out, entry)
    end
    table.sort(out, function(a, b)
        if a.done ~= b.done then return not a.done end
        if (a.board ~= nil) ~= (b.board ~= nil) then return a.board == nil end
        if a.order ~= b.order then return a.order < b.order end
        return tostring(a.id) < tostring(b.id)
    end)
    return out
end

function Halloween.Quest(id)
    for _, q in ipairs(Halloween.Quests()) do
        if q.id == id then return q end
    end
    return nil
end

function Halloween.Summary()
    local open, done = 0, 0
    for _, q in ipairs(Halloween.Quests()) do
        if q.done then done = done + 1 else open = open + 1 end
    end
    return open, done
end

Halloween.Priority = {
    Murderer = { "murderer", "collect", "play", "craft" },
    Sheriff  = { "sheriff", "collect", "survive", "play", "craft" },
    Hero     = { "sheriff", "collect", "survive", "play", "craft" },
    Innocent = { "collect", "gun", "sheriff", "survive", "play", "craft" },
}

function Halloween.Focus(role)
    local order = Halloween.Priority[role] or Halloween.Priority.Innocent
    local quests = Halloween.Quests()
    for _, kind in ipairs(order) do
        for _, q in ipairs(quests) do
            if not q.done and q.kind == kind then return q end
        end
    end
    return nil
end

function Halloween.Plan(role)
    local q = Halloween.Focus(role)
    local kind = q and q.kind
    local plan = {
        farm = kind == "collect",
        killAll = kind == "murderer" and role == "Murderer",
        killMurderer = kind == "sheriff" and (role == "Sheriff" or role == "Hero"),

        grabGun = kind == "gun" or (kind == "sheriff" and role ~= "Sheriff" and role ~= "Hero" and role ~= "Murderer"),
        survive = kind == "survive" and role ~= "Murderer",
        stayIn = kind == "play",
        craft = kind == "craft",
    }
    plan.focus = q
    return plan
end

local PLAN_KEYS = { "farm", "killAll", "killMurderer", "grabGun", "survive", "stayIn", "craft" }
local function planKey(plan, role)
    local parts = { tostring(role), tostring(plan.focus and plan.focus.id) }
    for _, k in ipairs(PLAN_KEYS) do parts[#parts + 1] = tostring(plan[k]) end
    return table.concat(parts, ",")
end

Halloween.OffPlan = { farm = false, killAll = false, killMurderer = false, grabGun = false,
                      survive = false, stayIn = false, craft = false }

Halloween.ApplyPlan = nil
local lastPlanKey = nil

local function questStep()
    if not State.HalloweenQuests or not Halloween.ApplyPlan then return end
    local role = Roles.LocalRole and Roles.LocalRole() or nil
    local plan = Halloween.Plan(role)
    local key = planKey(plan, role)
    if key ~= lastPlanKey then
        local was = Halloween.Current
        lastPlanKey = key
        Halloween.Current = plan.focus
        pcall(Halloween.ApplyPlan, plan, role)
        if plan.focus and (not was or was.id ~= plan.focus.id) then
            note(("Auto Quests: now on %s -- %s"):format(plan.focus.title, plan.focus.action))
        end
    end
end

Halloween.QuestStep = questStep
Halloween.Current = nil

Halloween.OnQuestChanged = nil
local seen = {}

local itemService
local function items()
    if itemService == nil then
        itemService = false
        pcall(function()
            local mod = RS:FindFirstChild("ClientServices") and RS.ClientServices:FindFirstChild("ItemService")
            if mod then itemService = require(mod) end
        end)
    end
    return itemService or nil
end

local function rewardName(step)
    if not step or not step.rewardId then return nil end
    local name = tostring(step.rewardId)
    pcall(function()
        local display = items():GetDisplayInfo(step.rewardId, step.rewardType)
        if display and display.Name then name = display.Name end
    end)
    return (step.rewardAmount or 1) > 1 and (name .. " x" .. step.rewardAmount) or name
end

Halloween.RewardName = rewardName

function Halloween.Crossed(q, before)
    local crossed = {}
    for _, step in ipairs(q.steps) do
        if step.amount > before and step.amount <= q.progress then table.insert(crossed, step) end
    end
    return crossed, q.done and q.goal > before
end

local function onProgress(id, progress)
    local before = seen[id]
    if before == nil then before = progressOf(id) end

    local m = mine()
    if m then
        m.Quests = m.Quests or {}
        if m.Quests[id] then m.Quests[id].Progress = progress else m.Quests[id] = { Progress = progress, Claimed = {} } end
    end
    seen[id] = tonumber(progress) or 0
    local q = Halloween.Quest(id)
    if not q then return end
    local crossed, finished = Halloween.Crossed(q, before)
    if finished then
        note(("Quest done: %s"):format(q.title))
    else
        for _, step in ipairs(crossed) do
            local reward = rewardName(step)
            note(("%s %d/%d%s"):format(q.title, math.min(q.progress, q.goal), q.goal, reward and (" -- got " .. reward) or ""))
        end
    end
    if Halloween.OnQuestChanged then pcall(Halloween.OnQuestChanged, q, before) end

    if finished or progress < before then lastPlanKey = nil end
    questStep()
end

Halloween.OnProgress = onProgress

function Halloween.Watch()
    local r = remote("EventQuestProgressed")
    if not r then return false end
    for _, q in ipairs(Halloween.Quests()) do seen[q.id] = q.progress end
    Util.Bind("halloweenquests", r.OnClientEvent, onProgress)
    return true
end

local watching = false

local function step()
    if not (cache.event and cache.profile) then
        if not load() then return end
    end
    if not watching then watching = Halloween.Watch() end
    if State.HalloweenClaim then Halloween.ClaimTiers() end
    if State.HalloweenBuyTiers then Halloween.BuyTiers() end
    if State.HalloweenBuyFinal then Halloween.BuyFinal() end
    if State.HalloweenCraft then Halloween.CraftAll() end
    if State.HalloweenGift then Halloween.ClaimGift() end
    questStep()
end

Halloween.Step = step

local function anyOn()
    return State.HalloweenClaim or State.HalloweenBuyTiers or State.HalloweenBuyFinal
        or State.HalloweenCraft or State.HalloweenGift or State.HalloweenQuests
end

function Halloween.Refresh()
    if anyOn() then
        Util.Loop("halloween", function() return 3 end, step)
    else
        Util.Unbind("halloween")
        lastPlanKey = nil
    end
end

function Halloween.Set(key, on)
    State[key] = on
    if key == "HalloweenQuests" and not on then
        lastPlanKey = nil
        Halloween.Current = nil
        if Halloween.ApplyPlan then pcall(Halloween.ApplyPlan, Halloween.OffPlan, nil) end
    end
    Halloween.Refresh()
end

function Halloween.Report()
    if not (cache.event and cache.profile) and not load() then
        return "No live event found (or ProfileData didn't load)."
    end
    local tier, total = Halloween.Tier()
    local open, done = Halloween.Summary()
    local lines = {
        ("%s  ·  %s %s"):format(cache.event.Title or "Event", tostring(Halloween.Candies()), Halloween.CurrencyName()),
        ("Battle pass tier %d/%d"):format(tier, total),
        ("Quests: %d done, %d open"):format(done, open),
    }
    for _, q in ipairs(Halloween.Quests()) do
        if not q.done then
            table.insert(lines, ("• %s  %d/%d  ->  %s"):format(q.title, math.min(q.progress, q.goal), q.goal, q.action))
        end
    end
    local craft = #Halloween.Craftable()
    if craft > 0 then table.insert(lines, ("%d recipe%s ready to craft"):format(craft, craft == 1 and "" or "s")) end
    return table.concat(lines, "\n")
end

function Halloween.Destroy()
    Util.Unbind("halloween")
    Util.Unbind("halloweenquests")
    watching = false
end

return Halloween
end

__modules["features/FarmStats"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")

local LP = Services.LocalPlayer

local FarmStats = {}

local total = 0
local rounds = 0
local started = os.clock()
local last = {}
local bagText = "--"

local hud, lines

local function guiParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    return LP:WaitForChild("PlayerGui")
end

function FarmStats.OnCoin(bag, amount, max)
    if type(amount) ~= "number" then return end
    bag = tostring(bag or "Coins")
    local prev = last[bag]
    if prev == nil or amount < prev then
        if prev ~= nil then rounds = rounds + 1 end
        prev = 0
    end
    if amount > prev then total = total + (amount - prev) end
    last[bag] = amount
    bagText = type(max) == "number" and ("%s  %d/%d"):format(bag, amount, max) or ("%s  %d"):format(bag, amount)
    if FarmStats.Refresh then FarmStats.Refresh() end
end

function FarmStats.Snapshot()
    local elapsed = math.max(1, os.clock() - started)
    return {
        total = total,
        perHour = math.floor(total / elapsed * 3600 + 0.5),
        seconds = elapsed,
        rounds = rounds,
        bag = bagText,
    }
end

function FarmStats.Reset()
    total, rounds, started, last, bagText = 0, 0, os.clock(), {}, "--"
    if FarmStats.Refresh then FarmStats.Refresh() end
end

local function clock(seconds)
    seconds = math.floor(seconds)
    local h, m, s = math.floor(seconds / 3600), math.floor(seconds / 60) % 60, seconds % 60
    if h > 0 then return ("%d:%02d:%02d"):format(h, m, s) end
    return ("%d:%02d"):format(m, s)
end

local function build()
    if hud and hud.Parent then return end
    hud = Instance.new("ScreenGui")
    hud.Name = "RiftwareFarmStats"
    hud.ResetOnSpawn = false
    hud.IgnoreGuiInset = true
    hud.DisplayOrder = 40
    hud.Parent = guiParent()

    local frame = Instance.new("Frame")
    frame.AnchorPoint = Vector2.new(1, 0)
    frame.Position = UDim2.new(1, -12, 0, 70)
    frame.Size = UDim2.new(0, 170, 0, 92)
    frame.BackgroundColor3 = Color3.fromRGB(12, 13, 16)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.Parent = hud
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 12)
    c.Parent = frame
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(226, 231, 240)
    s.Transparency = 0.7
    s.Parent = frame

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 12, 0, 8)
    title.Size = UDim2.new(1, -24, 0, 14)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 11
    title.TextColor3 = Color3.fromRGB(248, 250, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "FARM STATS"
    title.Parent = frame

    lines = {}
    for i = 1, 4 do
        local t = Instance.new("TextLabel")
        t.BackgroundTransparency = 1
        t.Position = UDim2.new(0, 12, 0, 12 + i * 16)
        t.Size = UDim2.new(1, -24, 0, 14)
        t.Font = Enum.Font.GothamMedium
        t.TextSize = 11
        t.TextColor3 = Color3.fromRGB(184, 190, 202)
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = frame
        lines[i] = t
    end
end

local function refresh()
    if not (hud and lines) then return end
    local s = FarmStats.Snapshot()
    lines[1].Text = ("Coins  %d   (%d/hr)"):format(s.total, s.perHour)
    lines[2].Text = ("Time  %s"):format(clock(s.seconds))
    lines[3].Text = ("Rounds  %d"):format(s.rounds)
    lines[4].Text = ("Bag  %s"):format(s.bag)
end

function FarmStats.Set(on)
    State.FarmStats = on
    if on then
        build()
        hud.Enabled = true
        FarmStats.Refresh = refresh
        refresh()
        Util.Loop("farmstats", function() return 1 end, refresh)
    else
        Util.Unbind("farmstats")
        FarmStats.Refresh = nil
        if hud then hud.Enabled = false end
    end
end

function FarmStats.Destroy()
    FarmStats.Set(false)
    if hud then hud:Destroy() end
    hud, lines = nil, nil
end

return FarmStats
end

__modules["features/RoundLog"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")
local Webhook  = import("core/Webhook")

local LP = Services.LocalPlayer

local RoundLog = {}

local WINS = {
    Innocent = { Time = true, MurdererDied = true, MurdererLeft = true, InnocentsEscaped = true },
    Hero     = { Time = true, MurdererDied = true, MurdererLeft = true },
    Sheriff  = { MurdererDied = true, MurdererLeft = true, SheriffWin = true },
    Murderer = { MurdererWin = true },
}

local RESULT_TEXT = {
    MurdererWin = "Murderer Wins",
    MurdererDied = "Murderer Eliminated",
    MurdererLeft = "Murderer Left",
    SheriffWin = "Sheriff Wins",
    Time = "Time Ran Out",
    InnocentsEscaped = "Innocents Escaped",
}

local session = { rounds = 0, wins = 0, xp = 0, coins = 0 }
local lastRound = nil
RoundLog.Session = session

local function url()
    local own = State.RoundWebhookUrl
    if type(own) == "string" and own ~= "" then return own end
    return State.WebhookUrl
end

local function commafy(n)
    local s = tostring(math.floor(tonumber(n) or 0))
    local out
    repeat
        out = s
        s = s:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
    until s == out
    return s
end

local function itemName(key)
    local db = Services.Sync and (Services.Sync.Weapons or Services.Sync.Item)
    local info = type(db) == "table" and key and db[key]
    return (type(info) == "table" and info.ItemName) or key
end

local function findRole(data, role)
    for name, entry in pairs(data or {}) do
        if type(entry) == "table" and entry.Role == role then return name, entry end
    end
    return nil
end

function RoundLog.BuildEmbed(result)
    local data = result.PlayerData or {}
    local me = data[LP.Name] or {}
    local role = me.Role or "Innocent"
    local won = WINS[role] and WINS[role][result.WinCondition] == true or false
    local rewards = result.Rewards or {}
    local xp = tonumber(rewards.TotalEarnedXP) or 0
    local coins = tonumber(me.Coins) or 0

    local fields = {
        { name = "Result", value = won and "**Won**" or "Lost", inline = true },
        { name = "Your Role", value = tostring(role), inline = true },
        { name = "Mode", value = tostring(result.GameModeName or "Classic"), inline = true },
    }

    local murderer, mEntry = findRole(data, "Murderer")
    if murderer then
        table.insert(fields, { name = "Murderer", inline = true,
            value = ("%s\n%s"):format(murderer, tostring(itemName(mEntry.Knife) or "?")) })
    end
    local shooter = result.Shooter or findRole(data, "Sheriff")
    local sEntry = shooter and data[shooter]
    if shooter then
        table.insert(fields, { name = result.Shooter and "Shot By" or "Sheriff", inline = true,
            value = ("%s\n%s"):format(shooter, tostring(sEntry and itemName(sEntry.Gun) or "?")) })
    end

    local lines = {}
    for _, r in pairs(rewards.XPRewards or {}) do
        if type(r) == "table" and r.XP then
            table.insert(lines, ("%s  **%s%s**"):format(tostring(r.Text or "XP"),
                tostring(r.Multiplier or "+"), commafy(r.XP)))
        end
    end
    table.sort(lines)
    table.insert(fields, { name = ("XP Earned  (+%s)"):format(commafy(xp)),
        value = #lines > 0 and table.concat(lines, "\n") or "--", inline = false })
    table.insert(fields, { name = "Coins", value = commafy(coins), inline = true })

    table.insert(fields, { name = "Session", inline = false, value = ("%d rounds  \u{00B7}  %d won  \u{00B7}  +%s XP  \u{00B7}  %s coins")
        :format(session.rounds, session.wins, commafy(session.xp), commafy(session.coins)) })

    return {
        title = ("Round %s  \u{2014}  %s"):format(tostring(result.RoundCount or "?"),
            RESULT_TEXT[result.WinCondition] or tostring(result.WinCondition or "Over")),
        color = won and 0x22C55E or 0xEF4444,
        fields = fields,
        thumbnail = { url = ("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=150&height=150&format=png")
            :format(math.abs(LP.UserId or 0)) },
        footer = { text = "Riftware  \u{00B7}  " .. tostring(LP.Name) },
        timestamp = DateTime.now():ToIsoDate(),
    }, won, xp, coins
end

function RoundLog.Handle(result)
    if type(result) ~= "table" then return false, "no result" end
    if result.RoundCount ~= nil and result.RoundCount == lastRound then return false, "already logged" end
    lastRound = result.RoundCount

    local data = result.PlayerData or {}
    local me = data[LP.Name] or {}
    local role = me.Role or "Innocent"
    local won = WINS[role] and WINS[role][result.WinCondition] == true or false
    session.rounds = session.rounds + 1
    if won then session.wins = session.wins + 1 end
    session.xp = session.xp + (tonumber(result.Rewards and result.Rewards.TotalEarnedXP) or 0)
    session.coins = session.coins + (tonumber(me.Coins) or 0)

    local embed = RoundLog.BuildEmbed(result)
    return Webhook.Post(url(), { username = "Riftware", embeds = { embed } })
end

local function fetch()
    local remote = Services.Gameplay and Services.Gameplay:FindFirstChild("GetLastRoundRewards")
    if not remote then return nil end
    local ok, result = pcall(function() return remote:InvokeServer() end)
    if ok then return result end
    return nil
end

function RoundLog.Set(on)
    State.RoundLog = on
    Util.Unbind("roundlog")
    if not on then return end
    local fade = Services.Gameplay and Services.Gameplay:FindFirstChild("RoundEndFade")
    if not fade then return end
    Util.Bind("roundlog", fade.OnClientEvent, function()

        task.delay(2, function()
            if not State.RoundLog then return end
            local result = fetch()
            if result then
                local ok, err = RoundLog.Handle(result)
                if not ok and err ~= "already logged" then
                    Util.Notify("Round Log", "Webhook failed: " .. tostring(err))
                end
            end
        end)
    end)
end

function RoundLog.Test()
    if url() == "" then return false, "paste a webhook URL first" end
    local result = fetch()
    if type(result) ~= "table" then
        return Webhook.Post(url(), { username = "Riftware",
            content = "Round logging connected for **" .. tostring(LP.Name) .. "**. Results post after each round." })
    end
    local embed = RoundLog.BuildEmbed(result)
    return Webhook.Post(url(), { username = "Riftware", embeds = { embed } })
end

function RoundLog.Destroy()
    RoundLog.Set(false)
end

return RoundLog
end

__modules["features/Farm"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")
local FarmStats = import("features/FarmStats")
local Roles    = import("core/Roles")
local Melee    = import("features/Melee")
local Fling    = import("features/Fling")

local CS           = Services.CollectionService
local RunService   = Services.RunService

local Farm = {}

local farming = false

local function liveCoins()
    local out = {}
    for _, coin in ipairs(CS:GetTagged("CoinVisual")) do
        if coin:IsA("BasePart")
            and coin:IsDescendantOf(workspace)
            and not coin:GetAttribute("Collected")
            and not coin:GetAttribute("Delete")
        then
            table.insert(out, coin)
        end
    end
    return out
end

Farm.LiveCoins = liveCoins

local function glideTo(position)
    local speed = State.FarmSpeed
    if type(speed) ~= "number" or speed <= 0 then speed = 20 end
    return Util.Glide(position, speed, function() return State.AutoFarmCoins end)
end

Farm.GlideTo = glideTo

Farm.Modes = { "Normal", "Underground" }

local function underground()
    return State.FarmMode == "Underground"
end

local function depth()
    local d = State.FarmDepth
    if type(d) ~= "number" or d <= 0 then d = 3.5 end
    return d
end

local FLAT = CFrame.Angles(math.pi / 2, 0, math.pi / 2)
local GYRO, VELOCITY = "Riftware Farm Gyro", "Riftware Farm Velocity"
local UNDER_MAP = 15

Farm.Now = os.clock
Farm.BagFull = false

local under = { map = nil, target = nil, since = 0, stuck = nil, stuckSince = 0, tween = nil,
                fails = {}, skips = {}, sawCoins = false, bodied = false }

local function currentMap()
    for _, child in ipairs(workspace:GetChildren()) do
        if child:FindFirstChild("CoinContainer") or child:FindFirstChild("CoinAreas") then return child end
    end
    return nil
end

Farm.CurrentMap = currentMap

local function skipped(coin)
    local untilAt = under.skips[coin]
    if not untilAt then return false end
    if untilAt < Farm.Now() then
        under.skips[coin], under.fails[coin] = nil, nil
        return false
    end
    return true
end

local function failed(coin)
    local n = (under.fails[coin] or 0) + 1
    under.fails[coin] = n
    if n >= 2 then under.skips[coin] = Farm.Now() + 20 end
end

local function nearestCoin(from)
    local container = under.map and under.map:FindFirstChild("CoinContainer")
    local pool = {}
    if container then
        for _, c in ipairs(container:GetChildren()) do
            if c.Name == "Coin_Server" then table.insert(pool, c) end
        end
    end
    if #pool == 0 then pool = liveCoins() end
    local best, bestDist = nil, math.huge
    for _, c in ipairs(pool) do
        if c.Parent and not c:GetAttribute("Collected") and not skipped(c) then
            local d = (from - c.Position).Magnitude
            if d < bestDist then best, bestDist = c, d end
        end
    end
    return best
end

Farm.NearestCoin = nearestCoin

local function torso()
    local char = Util.Character()
    return char and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart"))
end

local function body(on)
    local part, hum, hrp = torso(), Util.Humanoid(), Util.HRP()
    if on then
        if under.bodied and part and part:FindFirstChild(GYRO) then return end
        if not (part and hum and hrp) then return end
        Util.Noclip("farmunder", true)
        local flat = CFrame.new(hrp.Position) * FLAT
        local gyro = Instance.new("BodyGyro")
        gyro.Name, gyro.P, gyro.MaxTorque, gyro.CFrame = GYRO, 90000, Vector3.new(9e9, 9e9, 9e9), flat
        gyro.Parent = part
        local vel = Instance.new("BodyVelocity")
        vel.Name, vel.Velocity, vel.MaxForce = VELOCITY, Vector3.new(0, 0, 0), Vector3.new(9e9, 9e9, 9e9)
        vel.Parent = part
        hrp.CFrame = flat
        hum.PlatformStand = true
        under.bodied = true
    else
        local char = Util.Character()
        if char then
            for _, d in ipairs(char:GetDescendants()) do
                if d.Name == GYRO or d.Name == VELOCITY then pcall(function() d:Destroy() end) end
            end
        end
        if hum then
            hum.PlatformStand = false
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
        end
        Util.Noclip("farmunder", false)
        under.bodied = false
    end
end

Farm.Body = body

local function cancelTween()
    if under.tween then
        pcall(function() under.tween:Cancel() end)
        under.tween = nil
    end
end

local function spawnPart(map)
    local spawns = map and map:FindFirstChild("Spawns")
    if not spawns then return nil end
    local first, named
    for _, p in ipairs(spawns:GetChildren()) do
        if p:IsA("BasePart") then
            first = first or p
            if p.Name == "Spawn" or p.Name == "PlayerSpawn" or p.Name == "SpawnLocation" then named = p end
        end
    end
    return named or first
end

local function goHome()
    cancelTween()
    body(false)
    local spot, hrp = spawnPart(under.map), Util.HRP()
    if not (spot and hrp) then return end
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    hrp.CFrame = CFrame.new(spot.Position + Vector3.new(0, spot.Size.Y / 2 + 4, 0))
end

Farm.GoHome = goHome

local function hideUnderMap(hrp)
    local spot = spawnPart(under.map)
    local base = spot and spot.Position
    if not base then
        local ok, pivot = pcall(function() return under.map:GetPivot() end)
        base = ok and pivot and pivot.Position
    end
    if not base then return false end
    body(true)
    local hide = base - Vector3.new(0, UNDER_MAP, 0)
    if (hrp.Position - hide).Magnitude > 5 then
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.CFrame = CFrame.new(hide) * FLAT
    end
    return true
end

local function underStep()
    if not State.AutoFarmCoins or not underground() then return end
    local hrp = Util.HRP()
    if not hrp or not Util.Alive() then
        under.target = nil
        return
    end

    local map = currentMap()
    if map ~= under.map then

        under.map, under.target, under.sawCoins = map, nil, false
        under.fails, under.skips = {}, {}
        Farm.BagFull = false
    end
    if not map then return end

    if Farm.BagFull then
        if under.bodied then goHome() end
        return
    end

    local coin = nearestCoin(hrp.Position)
    if not coin then
        if under.sawCoins then

            if under.bodied then goHome() end
        else
            hideUnderMap(hrp)
        end
        return
    end
    under.sawCoins = true

    if coin ~= under.target or coin:GetAttribute("Collected") then

        under.target, under.since = coin, Farm.Now()
        cancelTween()
        body(true)
        local speed = State.FarmSpeed
        if type(speed) ~= "number" or speed <= 0 then speed = 23 end
        local t = (hrp.Position - coin.Position).Magnitude / speed
        if t > 15 then t = 3 end
        if t < 0.05 then t = 0.05 end
        local p = coin.Position
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        under.tween = Services.TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear),
            { CFrame = CFrame.new(p.X, p.Y - depth(), p.Z) * FLAT })
        under.tween:Play()
        return
    end

    local distance = (hrp.Position - coin.Position).Magnitude
    if distance <= 6 then

        coin.CFrame = CFrame.new(hrp.Position + Vector3.new(math.random(-80, 80) / 100, math.random(-50, 300) / 100, math.random(-80, 80) / 100))
        hrp.CFrame = hrp.CFrame * CFrame.new(0, math.random(-20, 20) / 100, math.random(-20, 20) / 100)
        if under.stuck ~= coin then under.stuck, under.stuckSince = coin, Farm.Now() end
        if Farm.Now() - under.stuckSince > 2 then
            under.stuck, under.target = nil, nil
        end
    elseif Farm.Now() - under.since > 4 then
        failed(coin)
        under.target, under.stuck = nil, nil
    end
end

Farm.UnderStep = underStep

local function farmStep()
    if not State.AutoFarmCoins then return end

    local hrp = Util.HRP()
    if not hrp then return end

    local coins = liveCoins()
    if #coins == 0 then return end

    table.sort(coins, function(a, b)
        return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude
    end)

    for _, coin in ipairs(coins) do
        if not State.AutoFarmCoins or underground() then break end
        if coin.Parent and not coin:GetAttribute("Collected") then
            glideTo(coin.Position)
            task.wait(State.FarmDelay or 0.05)
        end
    end
end

local function inRound()
    return under.map ~= nil and under.map.Parent ~= nil and Util.Alive()
end

function Farm.SetAutoFarm(on)
    State.AutoFarmCoins = on

    if on then
        farming = true
        if underground() then
            under.map, under.target = nil, nil
            Util.Loop("autofarm", function() return 0.1 end, underStep)
        else
            Util.Noclip("farm", true)
            Util.Loop("autofarm", function() return 0.2 end, farmStep)
        end
    else
        farming = false
        Util.Unbind("autofarm")

        Util.CancelGlide()
        Util.Noclip("farm", false)
        if under.bodied or under.tween then
            local home = inRound()
            cancelTween()
            body(false)
            if home then goHome() end
        end
        under.target = nil
    end
end

function Farm.SetMode(mode)
    local was = State.AutoFarmCoins
    if was then Farm.SetAutoFarm(false) end
    State.FarmMode = mode
    if was then Farm.SetAutoFarm(true) end
end

function Farm.IsFarming()
    return farming
end

local function onBagFull(bagName)
    Farm.BagFull = true
    Util.Notify("Coin Bag", tostring(bagName) .. " is full.")

    if State.FlingMurdererOnFull then
        local murderer = Roles.Murderer()
        if murderer then
            Fling.At(murderer)
        else
            Util.Notify("Bag Full", "No murderer to fling.")
        end
    end

    if State.KillAllOnFull then

        if Roles.LocalIsMurderer() then
            Melee.KillAll()
        else
            Util.Notify("Bag Full", "Kill All skipped -- you are not the murderer.")
        end
    end
end

function Farm.HookBag()
    local remote = Services.Gameplay:FindFirstChild("CoinCollected")
    if not remote then return false end

    Util.Bind("bagwatch", remote.OnClientEvent, function(bagName, amount, max)
        pcall(FarmStats.OnCoin, bagName, amount, max)
        if type(amount) ~= "number" or type(max) ~= "number" then return end
        if max <= amount then
            task.spawn(onBagFull, bagName)
        end
    end)

    return true
end

function Farm.UnhookBag()
    Util.Unbind("bagwatch")
end

return Farm
end

__modules["features/Character"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")

local RunService = Services.RunService
local UIS        = Services.UserInputService
local LP         = Services.LocalPlayer

local Character = {}

local function applyStats()
    local hum = Util.Humanoid()
    if not hum then return end

    if State.SpeedEnabled then
        if hum.WalkSpeed ~= State.WalkSpeed then
            hum.WalkSpeed = State.WalkSpeed
        end
    end

    if State.JumpEnabled then

        if hum.UseJumpPower then
            if hum.JumpPower ~= State.JumpPower then
                hum.JumpPower = State.JumpPower
            end
        else
            local height = State.JumpPower / 7.5
            if math.abs(hum.JumpHeight - height) > 0.01 then
                hum.JumpHeight = height
            end
        end
    end
end

local function ensureStatsLoop()
    if State.SpeedEnabled or State.JumpEnabled then
        Util.Bind("charstats", RunService.Heartbeat, applyStats)
    else
        Util.Unbind("charstats")
    end
end

function Character.SetSpeed(on)
    State.SpeedEnabled = on
    if not on then
        local hum = Util.Humanoid()
        if hum then hum.WalkSpeed = 16 end
    end
    ensureStatsLoop()
end

function Character.SetJump(on)
    State.JumpEnabled = on
    if not on then
        local hum = Util.Humanoid()
        if hum then
            if hum.UseJumpPower then
                hum.JumpPower = 50
            else
                hum.JumpHeight = 7.2
            end
        end
    end
    ensureStatsLoop()
end

local flyVelocity, flyGyro

local function flyStep()
    local hrp = Util.HRP()
    local cam = workspace.CurrentCamera
    if not hrp or not cam or not flyVelocity or not flyGyro then return end

    local dir = Vector3.new(0, 0, 0)
    local cf = cam.CFrame

    if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end

    if dir.Magnitude > 0 then
        dir = dir.Unit * State.FlySpeed
    end

    flyVelocity.Velocity = dir
    flyGyro.CFrame = cf
end

local function stopFly()
    Util.Unbind("fly")

    if flyVelocity then flyVelocity:Destroy(); flyVelocity = nil end
    if flyGyro then flyGyro:Destroy(); flyGyro = nil end

    local hum = Util.Humanoid()
    if hum then hum.PlatformStand = false end
end

local function startFly()
    local hrp = Util.HRP()
    local hum = Util.Humanoid()
    if not hrp or not hum then
        Util.Notify("Fly", "No character.")
        State.Fly = false
        return
    end

    stopFly()

    flyVelocity = Instance.new("BodyVelocity")
    flyVelocity.Name = "RiftwareFlyVelocity"
    flyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyVelocity.Parent = hrp

    flyGyro = Instance.new("BodyGyro")
    flyGyro.Name = "RiftwareFlyGyro"
    flyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyGyro.P = 9e4
    flyGyro.CFrame = hrp.CFrame
    flyGyro.Parent = hrp

    hum.PlatformStand = true
    Util.Bind("fly", RunService.Heartbeat, flyStep)
end

function Character.SetFly(on)
    State.Fly = on
    if on then startFly() else stopFly() end
end

function Character.HookRespawn()
    Util.Bind("respawn", LP.CharacterAdded, function()
        task.wait(0.6)
        if State.Fly then startFly() end
        ensureStatsLoop()
    end)
end

function Character.Reset()
    Character.SetFly(false)
    State.SpeedEnabled = false
    State.JumpEnabled = false
    Util.Unbind("charstats")
    Util.Unbind("respawn")
end

return Character
end

__modules["features/Emotes"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")

local Emotes = {}

local function emoteRemote()
    local misc = Services.Remotes:FindFirstChild("Misc")
    return misc and misc:FindFirstChild("PlayEmote")
end

local function database()
    local sync = Services.Sync
    return sync and sync.Emotes or nil
end

function Emotes.List()
    local labels, lookup = {}, {}
    local emotes = database()
    if not emotes then return labels, lookup end

    for id, info in pairs(emotes) do
        if info.AnimationID then
            local label = (info.Name or id) .. "  (" .. id .. ")"
            table.insert(labels, label)
            lookup[label] = id
        end
    end

    table.sort(labels)
    return labels, lookup
end

function Emotes.Info(id)
    local emotes = database()
    return emotes and emotes[id] or nil
end

function Emotes.Play(id)
    if not id then return false, "no emote selected" end

    local remote = emoteRemote()
    if not remote then return false, "Remotes.Misc.PlayEmote missing" end

    local info = Emotes.Info(id)
    if not info then return false, "unknown emote id" end
    if not info.AnimationID then return false, "emote has no animation" end

    local ok, err = pcall(function()
        remote:Fire(id)
    end)

    if not ok then return false, tostring(err) end
    return true, info.Name or id
end

function Emotes.Stop()
    local hum = Util.Humanoid()
    if not hum then return false end

    hum:ChangeState(Enum.HumanoidStateType.Jumping)
    return true
end

return Emotes
end

__modules["features/SpawnFx"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")
local Roles    = import("core/Roles")

local Players = Services.Players
local LP      = Services.LocalPlayer
local Http    = Services.HttpService

local SpawnFx = {}

local REMOTE_URL = "https://raw.githubusercontent.com/riftwarewtf/rift/refs/heads/main/fx"
local FILE       = "Riftware/fx.json"
local DIR        = "Riftware"

local SEED = {
    ["Gingerscope"] = {
        ["beam"] = {
            ["Color"] = { { 0, 1.0, 1.0, 1.0 }, { 1, 1.0, 1.0, 1.0 } },
            ["LightEmission"] = 1,
            ["Texture"] = "rbxassetid://15374653796",
            ["TextureLength"] = 1.5,
            ["Transparency"] = { { 0, 0, 0 }, { 1, 0, 0 } },
            ["Width0"] = 1,
            ["Width1"] = 1
        }
    },
    ["Harvester"] = {
        ["beam"] = {
            ["Color"] = { { 0, 0.0, 1.0, 0.0 }, { 1, 0.0, 1.0, 0.0 } },
            ["LightEmission"] = 0.5,
            ["Texture"] = "",
            ["TextureLength"] = 1,
            ["Transparency"] = { { 0, 0.5, 0 }, { 1, 0.5, 0 } },
            ["Width0"] = 0.2,
            ["Width1"] = 0.2
        }
    },
    ["Icepiercer"] = {
        ["beam"] = {
            ["Color"] = { { 0, 0.0, 0.898, 1.0 }, { 1, 0.0, 0.898, 1.0 } },
            ["CurveSize0"] = 0,
            ["CurveSize1"] = 0,
            ["Enabled"] = true,
            ["FaceCamera"] = false,
            ["LightEmission"] = 0.5,
            ["LightInfluence"] = 0,
            ["Segments"] = 10,
            ["Texture"] = "",
            ["TextureLength"] = 1,
            ["TextureMode"] = "Stretch",
            ["TextureSpeed"] = 1,
            ["Transparency"] = { { 0, 0.5, 0 }, { 1, 0.5, 0 } },
            ["Width0"] = 0.2,
            ["Width1"] = 0.2,
            ["ZOffset"] = 0
        }
    },
    ["Raygun"] = {
        ["beam"] = {
            ["Color"] = { { 0, 0.0, 1.0, 0.0 }, { 1, 0.0, 1.0, 0.0 } },
            ["LightEmission"] = 0.5,
            ["Texture"] = "",
            ["TextureLength"] = 1,
            ["Transparency"] = { { 0, 0.5, 0 }, { 1, 0.5, 0 } },
            ["Width0"] = 0.2,
            ["Width1"] = 0.2
        }
    },
    ["RaygunChroma"] = {
        ["beam"] = {
            ["Color"] = { { 0, 1.0, 0.0, 0.0157 }, { 0.1834, 0.6667, 0.0, 0.6118 }, { 0.391, 0.0, 0.0, 0.7725 }, { 0.6194, 0.0, 1.0, 0.9686 }, { 0.8045, 0.0, 0.651, 0.0431 }, { 1, 1.0, 0.9333, 0.0 } },
            ["LightEmission"] = 0.5,
            ["Texture"] = "",
            ["TextureLength"] = 1,
            ["Transparency"] = { { 0, 0.5, 0 }, { 1, 0.5, 0 } },
            ["Width0"] = 0.2,
            ["Width1"] = 0.2
        }
    },
    ["Snowcannon"] = {
        ["beam"] = {
            ["Color"] = { { 0, 1.0, 1.0, 1.0 }, { 1, 1.0, 1.0, 1.0 } },
            ["LightEmission"] = 0.5,
            ["Texture"] = "",
            ["TextureLength"] = 1,
            ["Transparency"] = { { 0, 0.5, 0 }, { 1, 0.5, 0 } },
            ["Width0"] = 0.5,
            ["Width1"] = 0.5
        }
    },
    ["SnowcannonChroma"] = {
        ["beam"] = {
            ["Color"] = { { 0, 1.0, 0.0, 0.0157 }, { 0.1834, 0.6667, 0.0, 0.6118 }, { 0.391, 0.0, 0.0, 0.7725 }, { 0.6194, 0.0, 1.0, 0.9686 }, { 0.8045, 0.0, 0.651, 0.0431 }, { 1, 1.0, 0.9333, 0.0 } },
            ["LightEmission"] = 0.5,
            ["Texture"] = "",
            ["TextureLength"] = 1,
            ["Transparency"] = { { 0, 0.5, 0 }, { 1, 0.5, 0 } },
            ["Width0"] = 0.5,
            ["Width1"] = 0.5
        }
    }
}

local SHOT_SOUND = {
    Harvester        = "rbxassetid://7808472682",
    Icepiercer       = "rbxassetid://7808472682",
    Raygun           = "rbxassetid://92066070356304",
    RaygunChroma     = "rbxassetid://92066070356304",
    Snowcannon       = "rbxassetid://136161856273464",
    SnowcannonChroma = "rbxassetid://136161856273464",
    Gingerscope      = "rbxassetid://74240492893421",
}

local library = {}
local DEFAULT = "__default"
SpawnFx.Library = library
SpawnFx.Captured = 0

local function merge(items, overwrite)
    if type(items) ~= "table" then return end
    for key, entry in pairs(items) do
        if type(entry) == "table" then
            local mine = library[key] or {}
            if entry.beam and (overwrite or not mine.beam) then mine.beam = entry.beam end
            if entry.sounds and (overwrite or not mine.sounds) then mine.sounds = entry.sounds end
            library[key] = mine
        end
    end
end

local function decode(body)
    local ok, data = pcall(function() return Http:JSONDecode(body) end)
    if ok and type(data) == "table" and type(data.items) == "table" then return data.items end
    return nil
end

function SpawnFx.Encode()
    local ok, body = pcall(function()
        return Http:JSONEncode({ version = 1, items = library })
    end)
    return ok and body or nil
end

local function save()
    if not (writefile and makefolder) then return end
    local body = SpawnFx.Encode()
    if not body then return end
    pcall(function()
        if isfolder and not isfolder(DIR) then makefolder(DIR) end
        writefile(FILE, body)
    end)
end

local loaded = false

function SpawnFx.Load()
    if loaded then return end
    loaded = true

    merge(SEED, false)

    if isfile and readfile then
        local ok, body = pcall(function()
            if isfile(FILE) then return readfile(FILE) end
        end)
        if ok and type(body) == "string" then merge(decode(body), true) end
    end

    task.spawn(function()
        local ok, body = pcall(function() return game:HttpGet(REMOTE_URL) end)
        if ok and type(body) == "string" then merge(decode(body), false) end
    end)
end

function SpawnFx.Has(key)
    if key == DEFAULT then return false end
    local entry = library[key]
    return entry ~= nil and (entry.beam ~= nil or entry.sounds ~= nil)
end

function SpawnFx.Count()
    local beams, sounds = 0, 0
    for key, entry in pairs(library) do
        if key ~= DEFAULT then
            if entry.beam then beams = beams + 1 end
            if entry.sounds then sounds = sounds + 1 end
        end
    end
    return beams, sounds
end

local function readBeam(beam)
    local out = {}
    local ok = pcall(function()
        local colors = {}
        for _, kp in ipairs(beam.Color.Keypoints) do
            table.insert(colors, { kp.Time, kp.Value.R, kp.Value.G, kp.Value.B })
        end
        out.Color = colors

        local alphas = {}
        for _, kp in ipairs(beam.Transparency.Keypoints) do
            table.insert(alphas, { kp.Time, kp.Value, kp.Envelope })
        end
        out.Transparency = alphas

        for _, prop in ipairs({ "Width0", "Width1", "LightEmission", "LightInfluence",
            "Texture", "TextureLength", "TextureSpeed", "FaceCamera", "Segments",
            "CurveSize0", "CurveSize1", "ZOffset" }) do
            out[prop] = beam[prop]
        end
        out.TextureMode = beam.TextureMode.Name
    end)
    if ok then return out end
    return nil
end

local function makeBeam(data)
    local beam = Instance.new("Beam")
    beam.Name = "CustomBeam"
    pcall(function()
        if data.Color then
            local kps = {}
            for _, c in ipairs(data.Color) do
                table.insert(kps, ColorSequenceKeypoint.new(c[1], Color3.new(c[2], c[3], c[4])))
            end
            beam.Color = ColorSequence.new(kps)
        end
        if data.Transparency then
            local kps = {}
            for _, t in ipairs(data.Transparency) do
                table.insert(kps, NumberSequenceKeypoint.new(t[1], t[2], t[3] or 0))
            end
            beam.Transparency = NumberSequence.new(kps)
        end
    end)
    for _, prop in ipairs({ "Width0", "Width1", "LightEmission", "LightInfluence",
        "Texture", "TextureLength", "TextureSpeed", "FaceCamera", "Segments",
        "CurveSize0", "CurveSize1", "ZOffset" }) do
        if data[prop] ~= nil then pcall(function() beam[prop] = data[prop] end) end
    end
    if type(data.TextureMode) == "string" then
        pcall(function() beam.TextureMode = Enum.TextureMode[data.TextureMode] end)
    end
    return beam
end

SpawnFx.MakeBeam = makeBeam

local function readSounds(tool)
    local out = {}
    for _, d in ipairs(tool:GetDescendants()) do
        if d:IsA("Sound") and d.SoundId ~= "" then
            table.insert(out, {
                name = d.Name, id = d.SoundId,
                volume = d.Volume, speed = d.PlaybackSpeed,
            })
        end
    end
    if #out == 0 then return nil end
    return out
end

local function digits(id)
    return tostring(id or ""):match("(%d+)") or ""
end

local function signatureOfHandle(handle)
    if not handle then return nil end
    local mesh, tex
    if handle:IsA("MeshPart") then
        mesh, tex = handle.MeshId, handle.TextureID
    else
        local sm = handle:FindFirstChildOfClass("SpecialMesh")
        if sm then mesh, tex = sm.MeshId, sm.TextureId end
    end
    if not mesh or digits(mesh) == "" then return nil end
    return digits(mesh) .. "|" .. digits(tex)
end

local function signatureOfNode(node)
    local handle
    for _, child in ipairs(node.Children or {}) do
        if child.Name == "Handle" then handle = child break end
    end
    if not handle then return nil end
    local mesh, tex = handle.MeshId, handle.TextureID
    if handle.ClassName ~= "MeshPart" then
        for _, c in ipairs(handle.Children or {}) do
            if c.ClassName == "SpecialMesh" then mesh, tex = c.MeshId, c.TextureId break end
        end
    end
    if not mesh or digits(mesh) == "" then return nil end
    return digits(mesh) .. "|" .. digits(tex)
end

local bySignature = {}
local indexed = {}

local function index(source, signatureOf)
    if type(source) ~= "table" or indexed[source] then return end
    indexed[source] = true
    local db = Services.Sync and (Services.Sync.Weapons or Services.Sync.Item) or {}
    local keys = {}
    for key in pairs(source) do table.insert(keys, key) end
    table.sort(keys)
    for _, key in ipairs(keys) do
        local info = db[key]
        if not info or info.ItemType == "Gun" then
            local sig = signatureOf(key, source[key])
            if sig and not bySignature[sig] then bySignature[sig] = key end
        end
    end
end

function SpawnFx.Index(meshData)
    index(meshData, function(_, node) return signatureOfNode(node) end)
end

function SpawnFx.IndexSkins(Skins)
    index(Skins.Data(), function(key) return Skins.Signature(key) end)
end

function SpawnFx.KeyOf(tool)
    return bySignature[signatureOfHandle(tool:FindFirstChild("Handle")) or ""]
end

local dressed = setmetatable({}, { __mode = "k" })

local function capture(tool, key)
    if not key or dressed[tool] then return end
    local beamInst = tool:FindFirstChild("CustomBeam", true)
    local beam = beamInst and readBeam(beamInst)
    local sounds = readSounds(tool)
    if not beam and not sounds then return end

    local entry = library[key] or {}
    local changed = false
    if beam and not entry.beam then entry.beam = beam; changed = true end
    if sounds and not entry.sounds then entry.sounds = sounds; changed = true end
    if changed then
        library[key] = entry
        SpawnFx.Captured = SpawnFx.Captured + 1
        save()
    end
end

SpawnFx.Capture = capture

local function scan()

    local ownKey = nil
    local okProfile, profile = pcall(function()
        return require(Services.ReplicatedStorage.Modules.ProfileData)
    end)
    if okProfile and profile and profile.Weapons then
        ownKey = profile.Weapons.Equipped and profile.Weapons.Equipped.Gun
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        local char = plr.Character
        if char then
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") and Roles.IsGunTool(tool) then
                    local key = SpawnFx.KeyOf(tool)
                    if not key and plr == LP and SpawnFx.IsReal and SpawnFx.IsReal(ownKey) then
                        key = ownKey
                    end
                    pcall(capture, tool, key)
                end
            end
        end

        local containers = {}
        if char then table.insert(containers, char) end
        local bag = plr:FindFirstChild("Backpack")
        if bag then table.insert(containers, bag) end
        for _, container in ipairs(containers) do
            for _, tool in ipairs(container:GetChildren()) do
                if tool:IsA("Tool") and not dressed[tool] then pcall(SpawnFx.LearnShot, tool) end
            end
        end
    end
end

SpawnFx.Scan = scan

function SpawnFx.StartCapture()
    SpawnFx.Load()
    Util.Loop("fxcapture", function() return 2 end, scan)
end

local function looksLikeShot(name)
    name = name:lower()
    if name:find("reload") or name:find("equip") or name:find("empty") then return false end
    return name:find("fire") or name:find("shoot") or name:find("shot") or name:find("gun")
end

local function gunshotOf(tool)
    local handle = tool:FindFirstChild("Handle")
    local named = handle and handle:FindFirstChild("Gunshot")
    if named and named:IsA("Sound") then return named end
    for _, d in ipairs(tool:GetDescendants()) do
        if d:IsA("Sound") and d.Name ~= "AltSound" and looksLikeShot(d.Name) then return d end
    end
    return nil
end

local function altOf(tool)
    local handle = tool:FindFirstChild("Handle")
    local alt = handle and handle:FindFirstChild("AltSound")
    if alt and alt:IsA("Sound") then return alt end
    return nil
end

function SpawnFx.LearnShot(tool)
    local key = tool:GetAttribute("ItemID")
    local alt = key and altOf(tool)
    if not (alt and alt.SoundId ~= "") or SHOT_SOUND[key] then return end
    local entry = library[key] or {}
    for _, s in ipairs(entry.sounds or {}) do
        if s.name == "AltSound" and s.id == alt.SoundId then return end
    end
    entry.sounds = { { name = "AltSound", id = alt.SoundId, volume = alt.Volume, speed = alt.PlaybackSpeed } }
    library[key] = entry
    save()
end

local function shotId(key)
    if SHOT_SOUND[key] then return SHOT_SOUND[key] end
    local entry = library[key]
    for _, s in ipairs(entry and entry.sounds or {}) do
        if s.name == "AltSound" and s.id and s.id ~= "" then return s.id end
    end
    return nil
end

SpawnFx.ShotId = shotId

local worn = {}

local function parkBeams(tool, entry)
    for _, d in ipairs(tool:GetDescendants()) do
        if d:IsA("Beam") and d.Name == "CustomBeam" then
            d.Name = "CustomBeam_Riftware"
            table.insert(entry.parked, d)
        end
    end
end

local function isShotSound(entry, d)
    if not d:IsA("Sound") or d.Name == "RiftwareShot" then return false end
    return entry.shotIds[d.SoundId] == true
end

local function playIdFor(tool, key)
    local id = shotId(key)
    if id then return id end
    local alt, gunshot = altOf(tool), gunshotOf(tool)
    if alt and gunshot and gunshot.SoundId ~= "" then return gunshot.SoundId end
    return nil
end

local function mute(entry, sound)
    if entry.muted[sound] ~= nil then return end
    entry.muted[sound] = sound.Volume
    sound.Volume = 0

    pcall(function()
        table.insert(entry.conns, sound:GetPropertyChangedSignal("Volume"):Connect(function()
            if worn[entry.tool] == entry and entry.id and sound.Volume ~= 0 then sound.Volume = 0 end
        end))
    end)
end

local function unmute(entry)
    for _, c in ipairs(entry.conns) do pcall(function() c:Disconnect() end) end
    entry.conns = {}
    for sound, volume in pairs(entry.muted) do
        pcall(function() sound.Volume = volume end)
    end
    entry.muted = {}
end

local function applySound(tool, entry)
    local id = playIdFor(tool, entry.key)
    if entry.soundDone and entry.id == id then return end
    unmute(entry)
    entry.soundDone = true
    entry.id = id
    if not id then return end

    local gunshot = gunshotOf(tool)
    entry.volume = gunshot and gunshot.Volume or 1

    entry.shotIds = {}
    local shots = {}
    if gunshot then table.insert(shots, gunshot) end
    local alt = altOf(tool)
    if alt then table.insert(shots, alt) end
    for _, d in ipairs(shots) do
        if d.SoundId ~= "" then entry.shotIds[d.SoundId] = true end
        mute(entry, d)
    end

    pcall(function()
        table.insert(entry.conns, tool.DescendantAdded:Connect(function(d)
            SpawnFx.OnSoundAdded(tool, d)
        end))
    end)
end

function SpawnFx.OnSoundAdded(tool, d)
    local entry = worn[tool]
    if entry and entry.id and entry.shotIds and isShotSound(entry, d) then mute(entry, d) end
end

function SpawnFx.Remove(tool)
    local entry = worn[tool]
    if not entry then return end
    worn[tool] = nil
    dressed[tool] = nil
    for _, b in ipairs(entry.added) do pcall(function() b:Destroy() end) end
    for _, b in ipairs(entry.parked) do pcall(function() b.Name = "CustomBeam" end) end
    unmute(entry)
end

function SpawnFx.Apply(tool, key)
    local entry = worn[tool]
    if entry and entry.key == key then

        applySound(tool, entry)
        return
    end
    if entry then SpawnFx.Remove(tool) end

    local ownBeam = true

    entry = { tool = tool, key = key, parked = {}, added = {}, muted = {}, conns = {} }
    worn[tool] = entry
    dressed[tool] = true

    local data = library[key]
    parkBeams(tool, entry)
    applySound(tool, entry)

    if ownBeam and data and data.beam then
        local handle = tool:FindFirstChild("Handle")
        for _, host in ipairs({ tool, handle }) do
            if host then
                local beam = makeBeam(data.beam)
                beam.Parent = host
                table.insert(entry.added, beam)
            end
        end
    end
end

function SpawnFx.KeyWorn(tool)
    local entry = worn[tool]
    return entry and entry.key
end

local function firedFrom(host, tool)
    if host == tool or host:IsDescendantOf(tool) then return true end
    return tool.Parent == host and host == LP.Character
end

local function onGunFired(host)
    if typeof(host) ~= "Instance" then return end
    for tool, entry in pairs(worn) do
        if tool.Parent and firedFrom(host, tool) then
            local handle = tool:FindFirstChild("Handle")
            if entry.id and handle then
                local sound = Instance.new("Sound")
                sound.Name = "RiftwareShot"
                sound.SoundId = entry.id
                sound.Volume = entry.volume or 1
                sound.Parent = handle
                sound:Play()
                task.delay(3, function() pcall(function() sound:Destroy() end) end)
            end
            return
        end
    end
end

SpawnFx.OnGunFired = onGunFired

function SpawnFx.StartSound()
    local service = Services.WeaponService
    local fired = service and service.GunFired
    if fired and fired.OnClientEvent then
        Util.Bind("fxgunfired", fired.OnClientEvent, onGunFired)
    end
end

function SpawnFx.Destroy()
    Util.Unbind("fxcapture")
    Util.Unbind("fxgunfired")
    for tool in pairs(worn) do SpawnFx.Remove(tool) end
end

return SpawnFx
end

__modules["features/Skins"] = function(import)

local Services = import("core/Services")

local RunService = Services.RunService

local Skins = {}

local URL        = "https://raw.githubusercontent.com/kroxn/visual/refs/heads/main/weapon.lua"
local CACHE_DIR  = "Riftware"
local CACHE_FILE = "Riftware/weapon.lua"

local IDENTITY = CFrame.new()

local data = nil
Skins.State = "idle"

local function trim(v)
    if type(v) == "string" then return (v:gsub("^%s+", ""):gsub("%s+$", "")) end
    return v
end

local function httpGet(url)
    local ok, body = pcall(function() return game:HttpGet(url, true) end)
    if ok and type(body) == "string" and #body > 0 then return body end
    local req = (syn and syn.request) or request or http_request or (http and http.request)
    if not req then return nil end
    local ok2, res = pcall(req, { Url = url, Method = "GET" })
    if ok2 and type(res) == "table" and type(res.Body) == "string" and #res.Body > 0 then
        return res.Body
    end
    return nil
end

local function readCache()
    if not (isfile and readfile) then return nil end
    local ok, body = pcall(function()
        if isfile(CACHE_FILE) then return readfile(CACHE_FILE) end
    end)
    if ok and type(body) == "string" and body:find("MESHES_FULL", 1, true) then return body end
    return nil
end

local function writeCache(body)
    if not writefile then return end
    pcall(function()
        if makefolder and isfolder and not isfolder(CACHE_DIR) then makefolder(CACHE_DIR) end
        writefile(CACHE_FILE, body)
    end)
end

local function compile(body)
    if type(body) ~= "string" then return nil end
    local fn = loadstring(body .. "\nreturn MESHES_FULL")
    if not fn then return nil end
    local ok, result = pcall(fn)
    if ok and type(result) == "table" and next(result) ~= nil then return result end
    return nil
end

local function addSweet(t)
    local chroma = t.SweetChroma
    if not (chroma and chroma.Model) or t.Sweet then return end
    local function strip(node)
        local out = { Class = node.Class, Id = node.Id, Name = node.Name, Props = node.Props, Tags = node.Tags }
        if node.Children then
            out.Children = {}
            for _, child in ipairs(node.Children) do
                if not (child.Class == "Decal" and child.Name == "Chroma") then
                    table.insert(out.Children, strip(child))
                end
            end
        end
        return out
    end
    local meta = {}
    for k, v in pairs(chroma.Meta or {}) do meta[k] = v end
    meta.Chroma = nil
    t.Sweet = { Complete = false, Meta = meta, Model = strip(chroma.Model) }
end

function Skins.Load(onDone)
    if Skins.State == "ready" then
        if onDone then task.spawn(onDone, true) end
        return
    end
    if Skins.State == "loading" then return end
    Skins.State = "loading"

    task.spawn(function()
        local cached = readCache()
        local body = cached or httpGet(URL)
        local result = compile(body)
        if not result and cached then
            cached = nil
            body = httpGet(URL)
            result = compile(body)
        end

        if result then
            addSweet(result)
            data = result
            Skins.State = "ready"
            if not cached then writeCache(body) end
        else
            Skins.State = "failed"
        end
        if onDone then pcall(onDone, result ~= nil) end
    end)
end

function Skins.Has(key)
    local e = data and key and data[key]
    return e ~= nil and (e.Model ~= nil or e.Display ~= nil)
end

function Skins.Entry(key)
    return data and data[key]
end

function Skins.Data()
    return data
end

local JOINTS = {
    WeldConstraint = true, Weld = true, Motor6D = true, RigidConstraint = true, Bone = true,
    Snap = true, ManualWeld = true, Rotate = true, RotateP = true, RotateV = true,
}

local EFFECTS = {
    ParticleEmitter = true, Fire = true, Smoke = true, Sparkles = true,
    PointLight = true, SpotLight = true, SurfaceLight = true,
}

local function applyProps(inst, props, skip)
    for k, v in pairs(props or {}) do
        if not (skip and skip[k]) then
            if k == "MeshId" or k == "TextureId" or k == "TextureID" or k == "Texture" then v = trim(v) end
            pcall(function() inst[k] = v end)
        end
    end
end

local function meshPart(props)
    local meshId = trim(props.MeshId or "")
    local size = props.Size or Vector3.new(1, 1, 1)
    local part
    pcall(function()
        part = game:GetService("InsertService"):CreateMeshPartAsync(
            meshId, Enum.CollisionFidelity.Box, Enum.RenderFidelity.Precise)
    end)
    if part then
        pcall(function() part.Size = size end)
        return part
    end
    part = Instance.new("Part")
    part.Size = size
    local sm = Instance.new("SpecialMesh")
    sm.MeshType = Enum.MeshType.FileMesh
    pcall(function() sm.MeshId = meshId end)
    pcall(function() sm.TextureId = trim(props.TextureID or "") end)
    sm.Parent = part
    return part
end

local function tagChroma(inst, node)
    if not (inst and node.Tags) then return end
    for _, tag in ipairs(node.Tags) do
        local kind = (tag == "ChromaPart" and "part") or (tag == "ChromaDecal" and "decal")
            or (tag == "ChromaFire" and "fire") or nil
        if kind then pcall(function() inst:SetAttribute("RiftwareChroma", kind) end) end
    end
end

local MESH_SKIP = { MeshId = true, Size = true, RelCF = true, CanCollide = true }
local REL_SKIP  = { RelCF = true }

local function makeNode(node)
    if JOINTS[node.Class] then return nil end
    local inst
    if node.Class == "MeshPart" then
        inst = meshPart(node.Props or {})
        applyProps(inst, node.Props, MESH_SKIP)
    else
        local ok, result = pcall(Instance.new, node.Class)
        if not ok or not result then return nil end
        inst = result
        applyProps(inst, node.Props, REL_SKIP)
    end
    if node.Name then pcall(function() inst.Name = node.Name end) end
    tagChroma(inst, node)
    return inst
end

local function settle(part)
    part.Anchored = false
    part.CanCollide = false
    pcall(function() part.CanQuery = false end)
    pcall(function() part.CanTouch = false end)
    part.Massless = true
    pcall(function() part.CastShadow = false end)
end

local function walk(node, parent, root, byId, parts, links)
    for _, child in ipairs(node.Children or {}) do
        local inst = makeNode(child)
        if inst then
            if child.Id then byId[child.Id] = inst end
            if inst:IsA("BasePart") then
                settle(inst)
                table.insert(parts, { inst = inst, relcf = child.Props and child.Props.RelCF })
                inst.Parent = root
                walk(child, inst, root, byId, parts, links)
            elseif inst:IsA("Attachment") then
                if child.Props and child.Props.RelCF then
                    pcall(function() inst.CFrame = child.Props.RelCF end)
                end
                inst.Parent = root
                walk(child, inst, root, byId, parts, links)
            elseif inst:IsA("Beam") or inst:IsA("Trail") then
                inst.Parent = parent
                table.insert(links, { inst = inst, a0 = child.Att0, a1 = child.Att1 })
                walk(child, inst, root, byId, parts, links)
            else
                inst.Parent = parent
                walk(child, inst, root, byId, parts, links)
            end
        else
            walk(child, parent, root, byId, parts, links)
        end
    end
end

local function buildModel(entry)
    local model = entry.Model
    local root
    if model.Class == "MeshPart" then
        root = meshPart(model.Props or {})
        applyProps(root, model.Props, MESH_SKIP)
    else
        root = Instance.new("Part")
        applyProps(root, model.Props, { RelCF = true, CanCollide = true })
    end
    if model.Name then pcall(function() root.Name = model.Name end) end
    tagChroma(root, model)
    settle(root)

    local byId, parts, links = {}, {}, {}
    if model.Id then byId[model.Id] = root end
    walk(model, root, root, byId, parts, links)

    for _, link in ipairs(links) do
        if link.a0 and byId[link.a0] then pcall(function() link.inst.Attachment0 = byId[link.a0] end) end
        if link.a1 and byId[link.a1] then pcall(function() link.inst.Attachment1 = byId[link.a1] end) end
    end
    return { root = root, parts = parts }
end

local function buildDisplay(entry)
    local rootNode
    local meshes, decals, effects = {}, {}, {}
    for _, node in ipairs(entry.Display or {}) do
        if node.Path == "(root)" then
            rootNode = node
        elseif node.Class == "SpecialMesh" then
            table.insert(meshes, node)
        elseif node.Class == "Decal" or node.Class == "Texture" then
            table.insert(decals, node)
        elseif EFFECTS[node.Class] then
            table.insert(effects, node)
        end
    end
    if not rootNode then return nil end

    local root
    if rootNode.Class == "MeshPart" then
        root = meshPart(rootNode.Props or {})
        applyProps(root, rootNode.Props, { MeshId = true, Size = true, CanCollide = true })
    else
        root = Instance.new("Part")
        root.Size = (rootNode.Props and rootNode.Props.Size) or Vector3.new(1, 1, 1)
        applyProps(root, rootNode.Props, { Size = true, CanCollide = true })
        for _, node in ipairs(meshes) do
            local sm = Instance.new("SpecialMesh")
            sm.MeshType = Enum.MeshType.FileMesh
            applyProps(sm, node.Props)
            sm.Parent = root
        end
    end
    settle(root)
    if rootNode.Name then pcall(function() root.Name = rootNode.Name end) end

    for _, node in ipairs(decals) do
        local ok, inst = pcall(Instance.new, node.Class)
        if ok and inst then
            applyProps(inst, node.Props)
            if node.Name then pcall(function() inst.Name = node.Name end) end
            inst.Parent = root
        end
    end
    for _, node in ipairs(effects) do
        local ok, inst = pcall(Instance.new, node.Class)
        if ok and inst then
            applyProps(inst, node.Props)
            if node.Name then pcall(function() inst.Name = node.Name end) end
            inst.Parent = root
        end
    end
    return { root = root, parts = {} }
end

function Skins.Build(key)
    local entry = Skins.Entry(key)
    if not entry then return nil end
    if entry.Model then return buildModel(entry) end
    if entry.Display then return buildDisplay(entry) end
    return nil
end

function Skins.Place(built, cf)
    local root = built.root
    pcall(function() root.CFrame = cf end)
    for _, p in ipairs(built.parts) do
        if p.relcf then pcall(function() p.inst.CFrame = cf * p.relcf end) end
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = p.inst
        weld.Part1 = root
        weld.Parent = p.inst
    end
    return root
end

function Skins.MeshOf(key)
    local entry = Skins.Entry(key)
    if not entry then return "" end
    if entry.Model then
        local model = entry.Model
        if model.Class == "MeshPart" then return trim(model.Props and model.Props.MeshId or "") end
        for _, child in ipairs(model.Children or {}) do
            if child.Class == "SpecialMesh" then return trim(child.Props and child.Props.MeshId or "") end
        end
        return ""
    end
    for _, node in ipairs(entry.Display or {}) do
        if node.Path == "(root)" and node.Class == "MeshPart" then return trim(node.Props.MeshId or "") end
        if node.Class == "SpecialMesh" then return trim(node.Props.MeshId or "") end
    end
    return ""
end

function Skins.MeshOfPart(part)
    if not part then return "" end
    if part:IsA("MeshPart") then return trim(part.MeshId or "") end
    local sm = part:FindFirstChildWhichIsA("SpecialMesh", true)
    return sm and trim(sm.MeshId or "") or ""
end

local function digits(id)
    return tostring(id or ""):match("(%d+)") or ""
end

function Skins.Signature(key)
    local entry = Skins.Entry(key)
    if not entry then return nil end
    local mesh, tex
    if entry.Model then
        local model = entry.Model
        local props = model.Props or {}
        if model.Class == "MeshPart" then
            mesh, tex = props.MeshId, props.TextureID
        else
            for _, child in ipairs(model.Children or {}) do
                if child.Class == "SpecialMesh" then
                    mesh, tex = child.Props and child.Props.MeshId, child.Props and child.Props.TextureId
                    break
                end
            end
        end
    else
        for _, node in ipairs(entry.Display or {}) do
            if node.Path == "(root)" and node.Class == "MeshPart" then
                mesh, tex = node.Props.MeshId, node.Props.TextureID
                break
            elseif node.Class == "SpecialMesh" then
                mesh, tex = node.Props.MeshId, node.Props.TextureId
                break
            end
        end
    end
    if digits(mesh) == "" then return nil end
    return digits(mesh) .. "|" .. digits(tex)
end

local function sizeOf(entry)
    if entry.Model then return entry.Model.Props and entry.Model.Props.Size end
    for _, node in ipairs(entry.Display or {}) do
        if node.Path == "(root)" then return node.Props and node.Props.Size end
    end
    return nil
end

local function axisOrder(size)
    local t = { { size.X, "X" }, { size.Y, "Y" }, { size.Z, "Z" } }
    table.sort(t, function(a, b) return a[1] > b[1] end)
    return t[1][2], t[2][2], t[3][2]
end

local function findCustomAttachment(node)
    for _, child in ipairs(node.Children or {}) do
        if child.Class == "Attachment" and child.Name == "CustomAttachment" and child.Props and child.Props.RelCF then
            return child.Props.RelCF
        end
        local found = findCustomAttachment(child)
        if found then return found end
    end
    return nil
end

local DISPLAY_FALLBACK = {
    Gun_ZYX   = CFrame.new(0.12991, -3e-05, 0.075, 1, 0, 0, 0, 0.70713, 0.70708, 0, -0.70708, 0.70713),
    Gun_ZXY   = CFrame.new(0.12991, 0, 0.07501, 2e-05, -0.5, -0.86603, 1, -4e-05, 5e-05, -6e-05, -0.86603, 0.5),
    Gun_XYZ   = CFrame.new(-0.22989, 0.09821, 0.1, 1e-05, 0.98481, -0.17362, -1e-05, 0.17362, 0.98481, 1, -1e-05, 1e-05),
    Knife_YXZ = CFrame.new(0, 0, 0, -0.0446, -0.00031, -0.99901, 0.03549, 0.99937, -0.00189, 0.99837, -0.03553, -0.04456),
    Knife_ZYX = CFrame.new(0.00151, -0.12701, -0.15448, -0.99867, 0.03727, 0.03568, -0.04098, -0.15276, -0.98741, -0.03135, -0.98756, 0.15409),
    Knife_ZXY = CFrame.new(0.00151, -0.12701, -0.15448, -0.99867, 0.03727, 0.03568, -0.04098, -0.15276, -0.98741, -0.03135, -0.98756, 0.15409),
}

local learned = {}

local function attachmentOf(part)
    if not part then return nil end
    return part:FindFirstChild("CustomAttachment") or part:FindFirstChildWhichIsA("Attachment")
end

function Skins.Learn(part)
    local mesh = Skins.MeshOfPart(part)
    local att = attachmentOf(part)
    if mesh ~= "" and att then learned[mesh] = att.CFrame end
end

local function displayRel(key, slot)
    local entry = Skins.Entry(key)
    if entry.Model then return findCustomAttachment(entry.Model) or IDENTITY end
    local mesh = Skins.MeshOf(key)
    if mesh ~= "" and learned[mesh] then return learned[mesh] end
    local size = sizeOf(entry)
    if not size then return IDENTITY end
    local a, b, c = axisOrder(size)
    local itemType = (entry.Meta and entry.Meta.ItemType) or slot
    return DISPLAY_FALLBACK[itemType .. "_" .. a .. b .. c] or IDENTITY
end

function Skins.DisplayCFrame(display, key, slot)
    local att = attachmentOf(display)
    return display.CFrame * (att and att.CFrame or IDENTITY) * displayRel(key, slot):Inverse()
end

local AXIS = { X = Vector3.new(1, 0, 0), Y = Vector3.new(0, 1, 0), Z = Vector3.new(0, 0, 1) }

local GRIP_BASIS = {
    Gun   = { Vector3.new(0, 0, 1), Vector3.new(0, 1, 0), Vector3.new(-1, 0, 0) },
    Knife = { Vector3.new(0, 1, 0), Vector3.new(0, 0, 1), Vector3.new(1, 0, 0) },
}
local GRIP_TWIST = {
    Harvester  = CFrame.Angles(0, 0, -math.pi / 2),
    Icepiercer = CFrame.Angles(0, 0, -math.pi / 2),
}
local GRIP_AS_IS = { Sweet = true, SweetChroma = true }
local GRIP_NUDGE = { Harvester = 0.5, Icepiercer = 0.5 }

function Skins.Grip(tool, key, slot)
    if GRIP_AS_IS[key] then return IDENTITY end
    local entry = Skins.Entry(key)
    local size = entry and sizeOf(entry)
    local basis = GRIP_BASIS[slot]
    if not (size and basis) then return IDENTITY end

    local ok, cf = pcall(function()
        local a, b, c = axisOrder(size)
        local map = { [a] = basis[1], [b] = basis[2], [c] = basis[3] }
        if AXIS[a]:Cross(AXIS[b]):Dot(AXIS[c]) < 0 then map[c] = -map[c] end

        local out = tool.Grip.Rotation * CFrame.fromMatrix(Vector3.new(), map.X, map.Y, map.Z)
        if GRIP_TWIST[key] then out = out * GRIP_TWIST[key] end
        if GRIP_NUDGE[key] then out = out * CFrame.new(AXIS[a] * GRIP_NUDGE[key]) end
        return out
    end)
    return ok and cf or IDENTITY
end

function Skins.StuckOffset(partSize, key)
    local entry = Skins.Entry(key)
    local size = entry and sizeOf(entry)
    if not (size and partSize) then return IDENTITY end
    local ok, cf = pcall(function()
        local a, b, c = axisOrder(size)
        local x, y, z = axisOrder(partSize)
        local map = { [a] = AXIS[x], [b] = AXIS[y], [c] = AXIS[z] }
        if AXIS[a]:Cross(AXIS[b]):Dot(AXIS[c]) ~= AXIS[x]:Cross(AXIS[y]):Dot(AXIS[z]) then
            map[c] = -map[c]
        end
        return CFrame.fromMatrix(Vector3.new(), map.X, map.Y, map.Z)
    end)
    return ok and cf or IDENTITY
end

local CHROMA = {
    Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 255, 0), Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 255, 255), Color3.fromRGB(0, 0, 255), Color3.fromRGB(255, 0, 255),
}
local CHROMA_STEP = 1.8
local CHROMA_DECAL = "rbxassetid://18363392181"

local function chromaAt(t)
    local n = #CHROMA
    local phase = t % n
    local i = math.floor(phase)
    return CHROMA[i + 1]:Lerp(CHROMA[(i + 1) % n + 1], phase - i)
end

function Skins.IsChroma(key)
    local entry = Skins.Entry(key)
    if entry and entry.Meta and entry.Meta.Chroma == true then return true end
    return type(key) == "string" and key:sub(-6) == "Chroma"
end

function Skins.Chroma(root)
    local stepped, decals, tinted, meshes = {}, {}, {}, {}
    local tagged = false

    for _, d in ipairs(root:GetDescendants()) do
        local kind = d:GetAttribute("RiftwareChroma")
        if kind then
            tagged = true
            if kind == "part" then
                table.insert(stepped, d)
            elseif kind == "decal" and d:IsA("Decal") then
                pcall(function() d.Texture = CHROMA_DECAL end)
                table.insert(decals, d)
            elseif kind == "fire" then
                table.insert(tinted, d)
            end
        end
    end
    if root:GetAttribute("RiftwareChroma") == "part" then
        tagged = true
        table.insert(stepped, root)
    end

    if not tagged then
        for _, d in ipairs(root:GetDescendants()) do
            if d:IsA("BasePart") and (d.Material == Enum.Material.Neon or d.Name:lower():find("light")) then
                table.insert(stepped, d)
            elseif d:IsA("Decal") and d.Name:lower():find("chroma") then
                table.insert(decals, d)
            elseif d:IsA("Fire") then
                table.insert(tinted, d)
            end
        end
        if #decals == 0 then table.insert(tinted, root) end
    end

    local tintParts = {}
    for _, d in ipairs(tinted) do
        if d:IsA("BasePart") then tintParts[d] = true end
    end
    for _, d in ipairs(stepped) do tintParts[d] = nil end
    for _, d in ipairs(root:GetDescendants()) do
        if d:IsA("SpecialMesh") and d.TextureId ~= "" and tintParts[d.Parent] then
            table.insert(meshes, d)
        end
    end
    if tintParts[root] then
        local sm = root:FindFirstChildWhichIsA("SpecialMesh")
        if sm and sm.TextureId ~= "" then table.insert(meshes, sm) end
    end

    if #stepped == 0 and #decals == 0 and #tinted == 0 and #meshes == 0 then return nil end

    return RunService.Heartbeat:Connect(function()
        local now = os.clock()
        local col = chromaAt(now)
        for _, d in ipairs(decals) do d.Color3 = col end
        for _, m in ipairs(meshes) do m.VertexColor = Vector3.new(col.R, col.G, col.B) end
        for _, d in ipairs(tinted) do d.Color = col end
        local step = math.floor(now * CHROMA_STEP)
        for i, d in ipairs(stepped) do d.Color = CHROMA[(step + i - 1) % #CHROMA + 1] end
    end)
end

return Skins
end

__modules["features/Spawner"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")
local SpawnFx  = import("features/SpawnFx")
local Skins    = import("features/Skins")

local RS         = Services.ReplicatedStorage
local RunService = Services.RunService
local LP         = Services.LocalPlayer

local Spawner = {}

local MESH_URL   = "https://raw.githubusercontent.com/riftwarewtf/rift/refs/heads/main/mesh"
local CACHE_DIR  = "Riftware"
local CACHE_FILE = "Riftware/meshes.lua"

Spawner.RARITIES = { "Ancient", "Godly", "Classic", "Unique" }

local RARITY_ORDER = { Ancient = 1, Godly = 2, Classic = 3, Unique = 4 }

local RARITY_FALLBACK = {
    Ancient = Color3.fromRGB(160, 110, 255),
    Godly   = Color3.fromRGB(255, 60, 170),
    Classic = Color3.fromRGB(110, 190, 255),
    Unique  = Color3.fromRGB(255, 200, 70),
}

local mods = {}

local function lazy(name, path)
    if mods[name] ~= nil then return mods[name] or nil end
    local ok, result = pcall(function()
        local node = RS
        for _, step in ipairs(path) do
            node = node:WaitForChild(step, 10)
            if not node then return nil end
        end
        return require(node)
    end)
    mods[name] = (ok and result) or false
    return mods[name] or nil
end

local function ProfileData()
    return lazy("ProfileData", { "Modules", "ProfileData" })
end

local function InventoryModule()
    return lazy("InventoryModule", { "Modules", "InventoryModule" })
end

local function inventoryRemote(name)
    local remotes = Services.Remotes
    local inventory = remotes and remotes:FindFirstChild("Inventory")
    return inventory and inventory:FindFirstChild(name)
end

local function weaponDB()
    local sync = Services.Sync
    local db = sync and (sync.Weapons or sync.Item)
    if type(db) == "table" then return db end
    return nil
end

local catalog, chromaOf, chromaKeys

local function iconFor(image)
    if image == nil then return "" end
    local text = tostring(image)
    if tonumber(text) then
        return "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. text
    end
    return text
end

Spawner.IconFor = iconFor

local function baseOfChroma(key, info, db, byName)
    local keyed, named = {}, {}

    local function addKeyed(k) if k then table.insert(keyed, k) end end
    addKeyed(key:match("^Chroma(.+)$"))
    addKeyed(key:match("^(.+)Chroma$"))

    local name = info.ItemName and tostring(info.ItemName)
    if name then
        local stripped = name:gsub("^[Cc]hroma%s*", "")
        for _, k in ipairs(byName[stripped:lower()] or {}) do table.insert(named, k) end
    end

    local best, bestScore = nil, -1

    local function consider(base, bonus)
        local b = db[base]
        if type(b) ~= "table" or b.Chroma or base == key then return end
        if b.ItemType ~= info.ItemType then return end

        local score = bonus
        if b.Rarity == info.Rarity then score = score + 10 end
        if b.Event == info.Event then score = score + 4 end
        if b.Year == info.Year then score = score + 2 end

        if score > bestScore or (score == bestScore and base < best) then
            best, bestScore = base, score
        end
    end

    for _, base in ipairs(keyed) do consider(base, 100) end
    for _, base in ipairs(named) do consider(base, 0) end

    return best
end

function Spawner.Catalog()
    if catalog then return catalog end

    local db = weaponDB()
    if not db then return {} end

    catalog, chromaOf, chromaKeys = {}, {}, {}

    local byName = {}
    for key, info in pairs(db) do
        if type(info) == "table" and info.ItemName and not info.Chroma then
            local lower = tostring(info.ItemName):lower()
            byName[lower] = byName[lower] or {}
            table.insert(byName[lower], key)
        end
    end

    local chromaList = {}
    for key, info in pairs(db) do
        if type(info) == "table" and info.Chroma then
            chromaKeys[key] = true
            table.insert(chromaList, key)
        end
    end
    table.sort(chromaList)

    for _, key in ipairs(chromaList) do
        local base = baseOfChroma(key, db[key], db, byName)
        if base and not chromaOf[base] then
            chromaOf[base] = key
        end
    end

    for key, info in pairs(db) do
        if type(info) == "table"
            and not info.Chroma
            and RARITY_ORDER[info.Rarity]
            and (info.ItemType == "Knife" or info.ItemType == "Gun")
        then
            table.insert(catalog, {
                key    = key,
                name   = tostring(info.ItemName or key),
                rarity = info.Rarity,
                type   = info.ItemType,
                icon   = iconFor(info.Image),
                chroma = chromaOf[key],
            })
        end
    end

    table.sort(catalog, function(a, b)
        if a.rarity ~= b.rarity then return RARITY_ORDER[a.rarity] < RARITY_ORDER[b.rarity] end
        if a.type ~= b.type then return a.type < b.type end
        return a.name:lower() < b.name:lower()
    end)

    return catalog
end

function Spawner.RarityColor(rarity)
    local sync = Services.Sync
    local entry = sync and type(sync.Rarities) == "table" and sync.Rarities[rarity]
    local color = type(entry) == "table" and entry.Color
    if typeof(color) == "Color3" then return color end
    return RARITY_FALLBACK[rarity] or Color3.fromRGB(200, 205, 215)
end

function Spawner.ChromaOf(key)
    Spawner.Catalog()
    return chromaOf and chromaOf[key] or nil
end

function Spawner.IsChroma(key)
    Spawner.Catalog()
    return chromaKeys and chromaKeys[key] == true or false
end

local expected = {}
local uniques = {}
local wanted = {}
local hooked = false

Spawner.Spawned = expected

local function fireClient(remote, ...)
    local signal = remote and remote.OnClientEvent
    if not signal then return false end

    if firesignal then
        return (pcall(firesignal, signal, ...))
    end

    if getconnections then
        local args = table.pack(...)
        local any = false
        for _, conn in ipairs(getconnections(signal)) do
            local ok = pcall(function()
                if conn.Function then
                    conn.Function(table.unpack(args, 1, args.n))
                else
                    conn:Fire(table.unpack(args, 1, args.n))
                end
            end)
            any = any or ok
        end
        return any
    end

    return false
end

local function pushCount(key, count)
    local profile = ProfileData()
    if not profile or not profile.Weapons then return false end

    fireClient(inventoryRemote("ChangeInventoryItem"), "Weapons", key, count)

    if tonumber(profile.Weapons.Owned[key]) ~= count then
        profile.Weapons.Owned[key] = count

        local changed = inventoryRemote("InventoryDataChanged")
        if changed then pcall(function() changed:Fire("Weapons", key, count) end) end

        local update = RS:FindFirstChild("UpdateDataClient")
        if update then pcall(function() update:Fire(false, profile) end) end
    end

    return true
end

local function tabFor(info)
    local event = info.Event
    if event then
        if event == "Christmas" or event == "Halloween" then return event end
        return "Current"
    end
    if info.Season then return "Current" end
    return "Classic"
end

local function injectUnique(key, rank)
    local inv = InventoryModule()
    local my = inv and inv.MyInventory
    local gui = inv and inv.GUI and inv.GUI.MyInventory
    if not (my and my.Data and my.Data.Weapons and gui and gui.Main) then
        return false
    end

    local info = weaponDB()[key]
    local tab = tabFor(info)
    local bucket = my.Data.Weapons[tab]
    if not bucket then return false end
    if bucket[key] then return true end

    local item = inv.CreateNewItemData(key, 1, "Weapons")
    if not item then return false end

    item.Signature = "Riftware"
    item.Rank = rank
    item.EvoXP = 0

    bucket[key] = item
    table.insert(my.Sort.Weapons[tab], key)

    local sorted = inv.SortInventory(my)
    inv.GenerateNewInventoryFrames(sorted, gui.Main)
    inv.ConnectEquipButtons()
    return true
end

local function hasUnique(profile, key)
    for _, entry in ipairs(profile.Uniques or {}) do
        if type(entry) == "table" and entry.BaseItem == key then return true end
    end
    return false
end

local function giveUnique(key)
    local profile = ProfileData()
    if not profile then return false, "your profile hasn't loaded yet" end

    if uniques[key] or hasUnique(profile, key) then
        return false, "you already have it -- uniques are one of a kind"
    end

    local rank = math.random(1, 100)
    profile.Uniques = profile.Uniques or {}
    table.insert(profile.Uniques, {
        BaseItem = key, Rank = rank, Signature = "Riftware", XP = 0,
    })
    uniques[key] = rank

    if not injectUnique(key, rank) then
        return true, "added -- reopen your inventory if it isn't showing yet"
    end
    return true
end

local function reassert(which)
    local profile = ProfileData()
    if not profile then return end

    if which == "Weapons" and profile.Weapons then
        for key, count in pairs(expected) do
            if (tonumber(profile.Weapons.Owned[key]) or 0) < count then
                pushCount(key, count)
            end
        end

        local equipped = profile.Weapons.Equipped
        local changed = false
        for slot, key in pairs(wanted) do
            if equipped and equipped[slot] ~= key then
                equipped[slot] = key
                changed = true
            end
        end
        if changed then
            local inv = InventoryModule()
            if inv and inv.UpdateMyEquip then pcall(inv.UpdateMyEquip) end
        end
    elseif which == "Uniques" then
        for key, rank in pairs(uniques) do
            if not hasUnique(profile, key) then
                profile.Uniques = profile.Uniques or {}
                table.insert(profile.Uniques, {
                    BaseItem = key, Rank = rank, Signature = "Riftware", XP = 0,
                })
            end
            injectUnique(key, rank)
        end
    end
end

local function hook()
    if hooked then return end

    local changed = inventoryRemote("ProfileDataChanged")
    if not changed then return end

    hooked = true
    Util.Bind("spawnerprofile", changed.Event, function(which)
        task.defer(reassert, which)
    end)
end

function Spawner.Give(key, amount)
    local db = weaponDB()
    local info = db and db[key]
    if type(info) ~= "table" then return false, "unknown item" end

    local profile = ProfileData()
    if not profile or not profile.Weapons then
        return false, "your profile hasn't loaded yet"
    end

    hook()
    Spawner.StartWatching()

    if info.Rarity == "Unique" then
        return giveUnique(key)
    end

    amount = math.clamp(math.floor(tonumber(amount) or 1), 1, 999)

    local count = (tonumber(profile.Weapons.Owned[key]) or 0) + amount
    expected[key] = count

    if not pushCount(key, count) then
        return false, "couldn't reach the inventory"
    end
    return true
end

local function isSpawned(key)
    return key ~= nil and (expected[key] ~= nil or uniques[key] ~= nil)
end

local meshData = nil
Spawner.MeshState = "idle"

local function readCache()
    if not (isfile and readfile) then return nil end
    local ok, body = pcall(function()
        if isfile(CACHE_FILE) then return readfile(CACHE_FILE) end
        return nil
    end)
    if ok and type(body) == "string" and #body > 1000 then return body end
    return nil
end

local function writeCache(body)
    if not (writefile and makefolder) then return end
    pcall(function()
        if isfolder and not isfolder(CACHE_DIR) then makefolder(CACHE_DIR) end
        writefile(CACHE_FILE, body)
    end)
end

local function fetch()
    local ok, body = pcall(function() return game:HttpGet(MESH_URL) end)
    if ok and type(body) == "string" and body:find("local%s+data%s*=") then
        return body
    end
    return nil
end

local function parse(body)
    if not body then return nil end
    if not body:find("return%s+data%s*$") then
        body = body .. "\nreturn data"
    end
    local fn = loadstring(body)
    if not fn then return nil end
    local ok, result = pcall(fn)
    if ok and type(result) == "table" then return result end
    return nil
end

function Spawner.LoadMeshes(onDone)
    if Spawner.MeshState == "loading" or Spawner.MeshState == "ready" then
        if onDone and Spawner.MeshState == "ready" then task.spawn(onDone, true) end
        return
    end
    Spawner.MeshState = "loading"

    local pending, any = 2, false
    local function finish(ok)
        any = any or ok
        pending = pending - 1
        if pending > 0 then return end
        Spawner.MeshState = any and "ready" or "failed"
        if onDone then pcall(onDone, any) end
    end

    Skins.Load(function(ok)
        if ok then pcall(SpawnFx.IndexSkins, Skins) end
        finish(ok)
    end)

    task.spawn(function()
        local cached = readCache()
        local body = cached or fetch()
        local data = parse(body)

        if not data and cached then

            body = fetch()
            data = parse(body)
            cached = nil
        end

        if data then
            meshData = data

            pcall(SpawnFx.Index, data)
            if not cached then writeCache(body) end
        end

        finish(data ~= nil)

        if cached then
            local fresh = fetch()
            if fresh and fresh ~= cached then writeCache(fresh) end
        end
    end)
end

local function hasLegacy(key)
    return meshData ~= nil and meshData[key] ~= nil
end

function Spawner.HasMesh(key)
    return Skins.Has(key) or hasLegacy(key)
end

local SKIP = {
    TouchTransmitter = true, ManualWeld = true, Weld = true, WeldConstraint = true,
    Motor6D = true, RigidConstraint = true, Script = true, LocalScript = true,
    ModuleScript = true, RemoteEvent = true, RemoteFunction = true,
    BindableEvent = true, Animation = true, Sound = true, BoolValue = true,
    StringValue = true, NumberValue = true, ObjectValue = true,
    EqualizerSoundEffect = true, Attachment = true, Beam = true, Trail = true,
    SurfaceAppearance = true,
}

local CONTAINERS = { Tool = true, Model = true, Folder = true }

local function trim(v)
    if type(v) == "string" then return (v:gsub("^%s+", ""):gsub("%s+$", "")) end
    return v
end

local function vec3(t)
    if type(t) ~= "table" then return nil end
    return Vector3.new(t[1] or 0, t[2] or 0, t[3] or 0)
end

local function color3(t)
    if type(t) ~= "table" then return nil end
    return Color3.new(t[1] or 1, t[2] or 1, t[3] or 1)
end

local function cframe(t)
    if type(t) ~= "table" or #t < 12 then return nil end
    return CFrame.new(t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8], t[9], t[10], t[11], t[12])
end

local function enum(enumType, name)
    if type(name) ~= "string" then return nil end
    local ok, value = pcall(function() return enumType[name] end)
    if ok then return value end
    return nil
end

local function numberRange(t)
    if type(t) == "table" then return NumberRange.new(t[1] or 0, t[2] or t[1] or 0) end
    if type(t) == "number" then return NumberRange.new(t) end
    return nil
end

local function set(inst, prop, value)
    if value == nil then return end
    pcall(function() inst[prop] = value end)
end

local function newMeshPart(node)
    local meshId = trim(node.MeshId or "")
    local part
    pcall(function()
        part = game:GetService("InsertService"):CreateMeshPartAsync(
            meshId, Enum.CollisionFidelity.Box, Enum.RenderFidelity.Precise)
    end)
    if part then
        set(part, "TextureID", trim(node.TextureID))
        return part
    end

    local fallback = Instance.new("Part")
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    set(mesh, "MeshId", meshId)
    set(mesh, "TextureId", trim(node.TextureID))
    mesh.Parent = fallback
    return fallback
end

local function newPart(node)
    local part
    if node.ClassName == "MeshPart" then
        part = newMeshPart(node)
    else
        part = Instance.new("Part")
        set(part, "Shape", enum(Enum.PartType, node.Shape))
    end

    set(part, "Size", vec3(node.Size))
    set(part, "Color", color3(node.Color))
    set(part, "Material", enum(Enum.Material, node.Material))
    set(part, "Transparency", node.Transparency)
    set(part, "Reflectance", node.Reflectance)

    part.Anchored = false
    part.CanCollide = false
    set(part, "CanTouch", false)
    set(part, "CanQuery", false)
    part.Massless = true
    set(part, "CastShadow", false)
    part.Name = tostring(node.Name or "Part")
    return part
end

local function newDecoration(node)
    local className = node.ClassName
    local ok, inst = pcall(Instance.new, className)
    if not ok or not inst then return nil end

    if className == "SpecialMesh" then
        set(inst, "MeshType", enum(Enum.MeshType, node.MeshType))
        set(inst, "MeshId", trim(node.MeshId))
        set(inst, "TextureId", trim(node.TextureId))
        set(inst, "Scale", vec3(node.Scale))
        set(inst, "Offset", vec3(node.Offset))
        set(inst, "VertexColor", vec3(node.VertexColor))
    elseif className == "Decal" or className == "Texture" then
        set(inst, "Texture", trim(node.Texture))
        set(inst, "Face", enum(Enum.NormalId, node.Face))
        set(inst, "Transparency", node.Transparency)
        set(inst, "Color3", color3(node.Color))
    elseif className == "ParticleEmitter" then
        set(inst, "Texture", trim(node.Texture))
        set(inst, "Rate", node.Rate)
        set(inst, "Speed", numberRange(node.Speed))
        set(inst, "Lifetime", numberRange(node.Lifetime))
    end

    inst.Name = tostring(node.Name or className)
    return inst
end

local function isPartNode(node)
    return node.ClassName == "Part" or node.ClassName == "MeshPart"
        or node.ClassName == "UnionOperation"
end

local function findHandle(tree)
    local first
    for _, child in ipairs(tree.Children or {}) do
        if isPartNode(child) then
            if child.Name == "Handle" then return child end
            first = first or child
        end
    end
    return first
end

local function build(key)
    local tree = meshData and meshData[key]
    if type(tree) ~= "table" then return nil end

    local handleNode = findHandle(tree)
    if not handleNode then return nil end

    local handleCF = cframe(handleNode.CFrame) or CFrame.new()
    local root = newPart(handleNode)
    local extras = {}

    local function walk(node, parentInst)
        for _, child in ipairs(node.Children or {}) do
            local className = child.ClassName
            if child == handleNode then
                walk(child, root)
            elseif SKIP[className] then

            elseif CONTAINERS[className] then
                walk(child, parentInst)
            elseif isPartNode(child) then
                local part = newPart(child)
                local cf = cframe(child.CFrame)
                table.insert(extras, {
                    part = part,
                    offset = cf and handleCF:Inverse() * cf or CFrame.new(),
                })
                part.Parent = root
                walk(child, part)
            else
                local deco = newDecoration(child)
                if deco then
                    deco.Parent = parentInst
                    walk(child, deco)
                end
            end
        end
    end

    walk(tree, root)
    return { root = root, extras = extras }
end

Spawner.Build = build

local overlays = {}
local chromaTargets = {}

local CHROMA = {
    Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 255, 0), Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 255, 255), Color3.fromRGB(0, 0, 255), Color3.fromRGB(255, 0, 255),
}

local function chromaAt(t)
    local n = #CHROMA
    local phase = t % n
    local i = math.floor(phase)
    return CHROMA[i + 1]:Lerp(CHROMA[(i + 1) % n + 1], phase - i)
end

Spawner.ChromaAt = chromaAt

local function chromaStep()
    local col = chromaAt(os.clock())
    for inst, prop in pairs(chromaTargets) do
        if inst.Parent then
            if prop == "VertexColor" then
                inst.VertexColor = Vector3.new(col.R, col.G, col.B)
            else
                inst[prop] = col
            end
        else
            chromaTargets[inst] = nil
        end
    end
end

local function registerChroma(root)
    local found = false
    for _, d in ipairs(root:GetDescendants()) do
        if d:IsA("Decal") and d.Name:lower():find("chroma") then
            chromaTargets[d] = "Color3"
            found = true
        elseif d:IsA("BasePart") and d.Material == Enum.Material.Neon then
            chromaTargets[d] = "Color"
            found = true
        end
    end

    if not found then
        local mesh = root:FindFirstChildOfClass("SpecialMesh")
        if mesh then
            chromaTargets[mesh] = "VertexColor"
        else
            chromaTargets[root] = "Color"
        end
    end

    Util.Bind("spawnerchroma", RunService.Heartbeat, chromaStep)
end

local function hide(list, inst)
    if inst:IsA("BasePart") or inst:IsA("Decal") or inst:IsA("Texture") then
        table.insert(list, { inst = inst, prop = "Transparency", value = inst.Transparency })
        inst.Transparency = 1
    elseif inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam")
        or inst:IsA("Fire") or inst:IsA("Smoke") or inst:IsA("Sparkles")
    then
        table.insert(list, { inst = inst, prop = "Enabled", value = inst.Enabled })
        inst.Enabled = false
    end
end

local function hideAll(hidden, base, except)
    pcall(hide, hidden, base)
    for _, d in ipairs(base:GetDescendants()) do
        if not (except and (d == except or d:IsDescendantOf(except))) then
            pcall(hide, hidden, d)
        end
    end
end

local function restore(hidden)
    for _, h in ipairs(hidden or {}) do
        pcall(function() h.inst[h.prop] = h.value end)
    end
end

local function guard(hidden)
    local conns = {}
    for _, h in ipairs(hidden) do
        local inst, prop = h.inst, h.prop
        local ok, conn = pcall(function()
            return inst:GetPropertyChangedSignal(prop):Connect(function()
                if prop == "Enabled" then
                    if inst.Enabled then inst.Enabled = false end
                elseif inst.Transparency ~= 1 then
                    inst.Transparency = 1
                end
            end)
        end)
        if ok and conn then table.insert(conns, conn) end
    end
    return conns
end

local function disconnect(list)
    for _, c in ipairs(list or {}) do pcall(function() c:Disconnect() end) end
end

local function unwear(base)
    local entry = overlays[base]
    if not entry then return end
    overlays[base] = nil

    disconnect(entry.guards)
    if entry.chroma then pcall(function() entry.chroma:Disconnect() end) end
    if entry.root then pcall(function() entry.root:Destroy() end) end
    restore(entry.hidden)
end

local function attach(root, base)
    root.Name = "RiftwareSkin"
    pcall(function() root:SetAttribute("RiftwareSkin", true) end)
    root.Parent = base
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = root
    weld.Part1 = base
    weld.Parent = root
end

local building = {}

local function wearFull(base, key, slot)
    local tool = base.Parent
    local held = tool ~= nil and tool:IsA("Tool")

    pcall(Skins.Learn, base)
    if not held then
        local mesh = Skins.MeshOf(key)
        if mesh ~= "" and Skins.MeshOfPart(base) == mesh then

            unwear(base)
            overlays[base] = { key = key, hidden = {}, guards = {} }
            return
        end
    end

    local built = Skins.Build(key)
    if not built or not built.root or not base.Parent then
        if built and built.root then built.root:Destroy() end
        return
    end

    unwear(base)
    local hidden = {}
    hideAll(hidden, base)

    local cf
    if held then
        cf = base.CFrame * Skins.Grip(tool, key, slot)
    else
        cf = Skins.DisplayCFrame(base, key, slot)
    end
    Skins.Place(built, cf)
    attach(built.root, base)

    local chroma = nil
    if Skins.IsChroma(key) or Spawner.IsChroma(key) then chroma = Skins.Chroma(built.root) end

    overlays[base] = { key = key, root = built.root, hidden = hidden, guards = guard(hidden), chroma = chroma }
end

local function wearLegacy(base, key)
    local built = build(key)
    if not built or not base.Parent then
        if built then built.root:Destroy() end
        return
    end

    unwear(base)
    local hidden = {}
    hideAll(hidden, base)

    local root = built.root
    root.CFrame = base.CFrame
    for _, extra in ipairs(built.extras) do
        extra.part.CFrame = base.CFrame * extra.offset
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = extra.part
        weld.Part1 = root
        weld.Parent = extra.part
    end
    attach(root, base)

    if Spawner.IsChroma(key) then registerChroma(root) end

    overlays[base] = { key = key, root = root, hidden = hidden, guards = guard(hidden) }
end

local function wear(base, key, slot)
    if building[base] then return end
    building[base] = true
    local ok, err = pcall(function()
        if Skins.Has(key) then
            wearFull(base, key, slot)
        else
            wearLegacy(base, key)
        end
    end)
    building[base] = nil
    if not ok then warn("[Riftware] skin: " .. tostring(err)) end
end

function Spawner.BuildPreview(key)
    local root, chroma
    if Skins.Has(key) then
        local built = Skins.Build(key)
        if not built or not built.root then return nil end
        Skins.Place(built, CFrame.new())
        root = built.root
        if Skins.IsChroma(key) or Spawner.IsChroma(key) then chroma = Skins.Chroma(root) end
    elseif hasLegacy(key) then
        local built = build(key)
        if not built then return nil end
        root = built.root
        root.CFrame = CFrame.new()
        for _, extra in ipairs(built.extras) do extra.part.CFrame = extra.offset end
    else
        return nil
    end

    local model = Instance.new("Model")
    model.Name = "Preview_" .. tostring(key)
    root.Parent = model
    pcall(function() model.PrimaryPart = root end)
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then d.Anchored = true end
    end
    return model, chroma
end

local toolSkins = {}

local function hotbarSlots()
    local pg = LP:FindFirstChildOfClass("PlayerGui") or LP:FindFirstChild("PlayerGui")
    local ui = pg and pg:FindFirstChild("BackpackUI")
    if not ui then return {} end

    local out = {}
    for _, d in ipairs(ui:GetDescendants()) do
        if d.Name == "ToolIcon" and (d:IsA("ImageLabel") or d:IsA("ImageButton")) then
            local container = d.Parent
            table.insert(out, {
                icon = d,
                name = container and container:FindFirstChild("NameLabel"),
            })
        end
    end
    return out
end

local function isToolSlot(slot, tool, image)
    if image ~= "" then return slot.icon.Image == image end
    return slot.icon.Image == "" and slot.name ~= nil and slot.name.Text == tool.Name
end

local function unskinTool(tool)
    local entry = toolSkins[tool]
    if not entry then return end
    toolSkins[tool] = nil

    pcall(function() tool.TextureId = entry.original end)
    for _, slot in ipairs(hotbarSlots()) do
        if slot.icon.Image == entry.icon then
            slot.icon.Image = entry.original
            if entry.original == "" and slot.name then slot.name.Text = tool.Name end
        end
    end
end

local function skinTool(tool, key)
    local db = weaponDB()
    local info = db and db[key]
    if type(info) ~= "table" then return end
    local icon = iconFor(info.Image)
    if icon == "" then return end

    local entry = toolSkins[tool]
    if entry and entry.icon ~= icon then
        unskinTool(tool)
        entry = nil
    end
    if not entry then
        entry = { original = tool.TextureId or "", icon = icon }
        toolSkins[tool] = entry
    end

    if tool.TextureId ~= icon then
        pcall(function() tool.TextureId = icon end)
    end

    for _, slot in ipairs(hotbarSlots()) do
        if isToolSlot(slot, tool, entry.original) then
            slot.icon.Image = icon
            if slot.name then slot.name.Text = "" end
        end
    end
end

Spawner.SkinTool = skinTool

local function slotOf(tool)
    local CS = Services.CollectionService
    if tool:FindFirstChild("Shoot", true) ~= nil or CS:HasTag(tool, "Weapon_Gun") then return "Gun" end
    local events = tool:FindFirstChild("Events")
    if (events and events:FindFirstChild("KnifeStabbed")) or CS:HasTag(tool, "Weapon_Knife") then
        return "Knife"
    end
    return nil
end

local function basesFor(slot)
    local out = {}
    local char = LP.Character

    local containers = {}
    if char then table.insert(containers, char) end
    local bag = LP:FindFirstChildOfClass("Backpack")
    if bag then table.insert(containers, bag) end

    for _, container in ipairs(containers) do
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") and slotOf(tool) == slot then
                local handle = tool:FindFirstChild("Handle")
                if handle and handle:IsA("BasePart") then table.insert(out, handle) end
            end
        end
    end

    local ref = char and char:FindFirstChild("DisplayRef" .. slot)
    local shown = ref and ref.Value
    if shown and shown:IsA("BasePart") then table.insert(out, shown) end

    return out
end

local lastEquipped = {}
local fxTools = {}

local function watchStep()
    local profile = ProfileData()
    local equipped = profile and profile.Weapons and profile.Weapons.Equipped
    if not equipped then return end

    for _, slot in ipairs({ "Knife", "Gun" }) do
        local now = equipped[slot]
        if now ~= lastEquipped[slot] then
            lastEquipped[slot] = now
            wanted[slot] = isSpawned(now) and now or nil
        end
    end

    local live, liveTools, liveGuns = {}, {}, {}
    for _, slot in ipairs({ "Knife", "Gun" }) do
        local key = wanted[slot]
        if key then
            for _, base in ipairs(basesFor(slot)) do

                local tool = base.Parent
                if tool and tool:IsA("Tool") then
                    liveTools[tool] = key
                    if slot == "Gun" then liveGuns[tool] = key end
                end

                if Spawner.HasMesh(key) then
                    live[base] = true
                    local current = overlays[base]
                    if not current or current.key ~= key or (current.root and not current.root.Parent) then
                        task.spawn(wear, base, key, slot)
                    end
                end
            end
        end
    end

    for base in pairs(overlays) do
        if not live[base] then unwear(base) end
    end

    for tool, key in pairs(liveTools) do
        pcall(skinTool, tool, key)
    end
    for tool in pairs(toolSkins) do
        if not liveTools[tool] then unskinTool(tool) end
    end

    for tool, key in pairs(liveGuns) do
        pcall(SpawnFx.Apply, tool, key)
    end
    for tool in pairs(fxTools) do
        if not liveGuns[tool] then pcall(SpawnFx.Remove, tool) end
    end
    fxTools = liveGuns
end

local function onThrown(model)
    local visual = model:WaitForChild("KnifeVisual", 5)
    if not visual then return end
    local skin
    for _, d in ipairs(visual:GetDescendants()) do
        if d:GetAttribute("RiftwareSkin") then skin = d break end
    end
    if not skin then return end
    hideAll({}, visual, skin)
end

local function holdingKnife()
    local containers = {}
    if LP.Character then table.insert(containers, LP.Character) end
    local bag = LP:FindFirstChildOfClass("Backpack")
    if bag then table.insert(containers, bag) end
    for _, container in ipairs(containers) do
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") and slotOf(tool) == "Knife" then return true end
        end
    end
    return false
end

local stuck = {}

local function unstick(part)
    local entry = stuck[part]
    if not entry then return end
    stuck[part] = nil
    disconnect(entry.guards)
    if entry.chroma then pcall(function() entry.chroma:Disconnect() end) end
    if entry.root then pcall(function() entry.root:Destroy() end) end
end

local function onStuck(part)
    if stuck[part] or not holdingKnife() then return end
    local key = wanted.Knife
    if not (key and Skins.Has(key)) then return end
    stuck[part] = {}

    local built = Skins.Build(key)
    if not built or not built.root or not part.Parent then
        if built and built.root then built.root:Destroy() end
        stuck[part] = nil
        return
    end

    local hidden = {}
    hideAll(hidden, part)
    Skins.Place(built, part.CFrame * Skins.StuckOffset(part.Size, key))
    attach(built.root, part)

    local chroma = nil
    if Skins.IsChroma(key) or Spawner.IsChroma(key) then chroma = Skins.Chroma(built.root) end
    stuck[part] = { root = built.root, guards = guard(hidden), chroma = chroma }

    pcall(function()
        part.Destroying:Connect(function() unstick(part) end)
    end)
end

local function onWorkspaceChild(child)
    if child:IsA("BasePart") and child.Name == "StuckKnife" then
        task.spawn(onStuck, child)
    end
end

Spawner.OnStuck = onStuck
Spawner.OnThrown = onThrown

function Spawner.StartWatching()
    Spawner.LoadMeshes()
    Spawner.StartFx()
    Util.Loop("spawnerwatch", function() return 0.25 end, watchStep)

    local CS = Services.CollectionService
    pcall(function()
        Util.Bind("spawnerthrown", CS:GetInstanceAddedSignal("ThrowingKnife"), function(model)
            task.spawn(onThrown, model)
        end)
    end)
    Util.Bind("spawnerstuck", workspace.ChildAdded, onWorkspaceChild)
end

local fxStarted = false
function Spawner.StartFx()
    if fxStarted then return end
    fxStarted = true
    SpawnFx.IsReal = function(key) return key ~= nil and not isSpawned(key) end
    SpawnFx.StartCapture()
    SpawnFx.StartSound()
end

function Spawner.Wearing()
    return wanted.Knife, wanted.Gun
end

function Spawner.Destroy()
    Util.Unbind("spawnerwatch")
    Util.Unbind("spawnerchroma")
    Util.Unbind("spawnerprofile")
    Util.Unbind("spawnerthrown")
    Util.Unbind("spawnerstuck")
    for part in pairs(stuck) do unstick(part) end
    for base in pairs(overlays) do unwear(base) end
    for tool in pairs(toolSkins) do unskinTool(tool) end
    SpawnFx.Destroy()
    fxTools = {}
    fxStarted = false
    chromaTargets = {}
    hooked = false
end

return Spawner
end

__modules["features/SpawnerGui"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")
local Spawner  = import("features/Spawner")

local UIS         = Services.UserInputService
local TweenService = Services.TweenService
local RunService  = Services.RunService
local LP          = Services.LocalPlayer

local Gui = {}

local C = {
    BG       = Color3.fromRGB(10, 10, 12),
    PANEL    = Color3.fromRGB(19, 20, 24),
    CARD     = Color3.fromRGB(24, 25, 30),
    CARD_HI  = Color3.fromRGB(34, 36, 43),
    LINE     = Color3.fromRGB(52, 56, 66),
    GLINT    = Color3.fromRGB(248, 250, 255),
    CHROME   = Color3.fromRGB(226, 231, 240),
    SILVER   = Color3.fromRGB(184, 190, 202),
    STEEL    = Color3.fromRGB(150, 158, 172),
    SMOKE    = Color3.fromRGB(92, 98, 110),
    TEXT     = Color3.fromRGB(232, 236, 244),
    SUB      = Color3.fromRGB(138, 145, 160),
    OK       = Color3.fromRGB(170, 230, 190),
    FAV      = Color3.fromRGB(255, 205, 70),
    WARN     = Color3.fromRGB(240, 205, 130),
    BAD      = Color3.fromRGB(245, 130, 130),
}

local BASE_W, BASE_H = 760, 420
local PREVIEW_W = 178
local CARD_W, CARD_H = 104, 128

local screen, window, grid, statusLabel
local selectedLabel, selectedRarity, selectedIcon
local qtyBox, chromaKnob, chromaTrack, spawnButton
local chips = {}
local dragConns = {}
local cards = {}
local selected = nil
local filter = "All"
local query = ""
local built = false

local preview = {}

local FAV_DIR, FAV_FILE = "Riftware", "Riftware/favorites.json"
local favorites = {}
local favsLoaded = false

local function loadFavorites()
    if favsLoaded then return end
    favsLoaded = true
    if not (isfile and readfile) then return end
    pcall(function()
        if not isfile(FAV_FILE) then return end
        local list = Services.HttpService:JSONDecode(readfile(FAV_FILE))
        if type(list) == "table" then
            for _, key in ipairs(list) do favorites[tostring(key)] = true end
        end
    end)
end

local function saveFavorites()
    if not writefile then return end
    local list = {}
    for key in pairs(favorites) do table.insert(list, key) end
    table.sort(list)
    pcall(function()
        if makefolder and isfolder and not isfolder(FAV_DIR) then makefolder(FAV_DIR) end
        writefile(FAV_FILE, Services.HttpService:JSONEncode(list))
    end)
end

Gui.Favorites = favorites
Gui.LoadFavorites = loadFavorites

local function new(className, props, parent)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do
        pcall(function() inst[k] = v end)
    end
    if parent then inst.Parent = parent end
    return inst
end

local function corner(inst, px)
    return new("UICorner", { CornerRadius = UDim.new(0, px or 8) }, inst)
end

local function stroke(inst, color, thickness, transparency)
    return new("UIStroke", {
        Color = color or C.LINE,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, inst)
end

local function chromeGradient(inst)
    return new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, C.GLINT),
            ColorSequenceKeypoint.new(0.45, C.CHROME),
            ColorSequenceKeypoint.new(1, C.STEEL),
        }),
        Rotation = 90,
    }, inst)
end

local function tween(inst, props, t)
    pcall(function()
        TweenService:Create(inst, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad), props):Play()
    end)
end

local function setStatus(text, color)
    if statusLabel then
        statusLabel.Text = text
        statusLabel.TextColor3 = color or C.SUB
    end
end

Gui.SetStatus = setStatus

local function guiParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    local ok2, core = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and core then return core end
    return LP:WaitForChild("PlayerGui")
end

local function makeDraggable(handle, target)
    local dragging, startPos, startInput

    handle.InputBegan:Connect(function(input)
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
            dragging = input
            startInput = input.Position
            startPos = target.Position
        end
    end)

    table.insert(dragConns, UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        local t = input.UserInputType
        local matches = (t == Enum.UserInputType.MouseMovement and dragging.UserInputType == Enum.UserInputType.MouseButton1)
            or (t == Enum.UserInputType.Touch and input == dragging)
        if not matches then return end

        local delta = input.Position - startInput
        target.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end))

    table.insert(dragConns, UIS.InputEnded:Connect(function(input)
        if dragging and (input == dragging or input.UserInputType == Enum.UserInputType.MouseButton1) then
            dragging = nil
        end
    end))
end

local function spawnKey()
    if not selected then return nil end
    if State.SpawnerChroma then return selected.chroma end
    return selected.key
end

local function refreshFooter()
    if not selectedLabel then return end

    if not selected then
        selectedLabel.Text = "Pick an item"
        selectedRarity.Text = "Tap a card to select it"
        selectedRarity.TextColor3 = C.SUB
        selectedIcon.Image = ""
    else
        local chroma = State.SpawnerChroma and selected.chroma
        selectedLabel.Text = (chroma and "Chroma " or "") .. selected.name
        selectedRarity.Text = selected.rarity .. "  -  " .. selected.type
        selectedRarity.TextColor3 = Spawner.RarityColor(selected.rarity)
        selectedIcon.Image = selected.icon
    end

    local blocked = selected == nil or (State.SpawnerChroma and not selected.chroma)
    local isUnique = selected and selected.rarity == "Unique"

    if spawnButton then
        spawnButton.Text = (State.SpawnerChroma and selected and not selected.chroma)
            and "NO CHROMA" or "SPAWN"
        spawnButton.AutoButtonColor = not blocked
        tween(spawnButton, { BackgroundTransparency = blocked and 0.55 or 0 })
    end

    if qtyBox then
        qtyBox.TextTransparency = isUnique and 0.6 or 0
    end
end

local function paintCard(card)
    local isSelected = selected and selected.key == card.entry.key
    card.frame.BackgroundColor3 = isSelected and C.CARD_HI or C.CARD
    card.stroke.Color = isSelected and C.GLINT or C.LINE
    card.stroke.Thickness = isSelected and 1.6 or 1

    local dim = State.SpawnerChroma and not card.entry.chroma
    card.icon.ImageTransparency = dim and 0.7 or 0
    card.name.TextTransparency = dim and 0.55 or 0
    card.rarityLabel.TextTransparency = dim and 0.55 or 0
    card.badge.Visible = State.SpawnerChroma and card.entry.chroma ~= nil

    local fav = favorites[card.entry.key] == true
    card.star.TextColor3 = fav and C.FAV or C.SMOKE
    card.star.TextTransparency = fav and 0 or 0.35
    card.frame.LayoutOrder = (fav and 0 or 100000) + card.order
end

local function repaint()
    for _, card in ipairs(cards) do paintCard(card) end
    refreshFooter()
end

local function applyFilter()
    for _, card in ipairs(cards) do
        local entry = card.entry
        local rarityOk = filter == "All" or entry.rarity == filter
            or (filter == "Favorites" and favorites[entry.key] == true)
        local queryOk = query == "" or entry.name:lower():find(query, 1, true) ~= nil
            or entry.key:lower():find(query, 1, true) ~= nil
        card.frame.Visible = rarityOk and queryOk
    end
    if grid then grid.CanvasPosition = Vector2.new(0, 0) end
end

local function paintChips()
    for name, chip in pairs(chips) do
        local on = name == filter
        chip.button.BackgroundTransparency = on and 0 or 1
        chip.button.TextColor3 = on and C.BG or C.SILVER
        chip.gradient.Enabled = on
        chip.stroke.Transparency = on and 1 or 0
    end
end

local function makeCard(entry, order)
    local rarityColor = Spawner.RarityColor(entry.rarity)

    local frame = new("TextButton", {
        Name = entry.key,
        Text = "",
        AutoButtonColor = false,
        BackgroundColor3 = C.CARD,
        BorderSizePixel = 0,
        LayoutOrder = order,
    }, grid)
    corner(frame, 10)
    local st = stroke(frame, C.LINE, 1)

    local stripe = new("Frame", {
        BackgroundColor3 = rarityColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -20, 0, 2),
        Position = UDim2.new(0, 10, 1, -4),
    }, frame)
    corner(stripe, 1)

    local icon = new("ImageLabel", {
        BackgroundTransparency = 1,
        Image = entry.icon,
        ScaleType = Enum.ScaleType.Fit,
        Size = UDim2.new(0, 64, 0, 64),
        Position = UDim2.new(0.5, -32, 0, 12),
    }, frame)

    local typeTag = new("TextLabel", {
        BackgroundTransparency = 1,
        Text = entry.type == "Gun" and "GUN" or "KNIFE",
        Font = Enum.Font.GothamBold,
        TextSize = 8,
        TextColor3 = C.SMOKE,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0, 40, 0, 10),
        Position = UDim2.new(0, 8, 0, 6),
    }, frame)

    local name = new("TextLabel", {
        BackgroundTransparency = 1,
        Text = entry.name,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = C.TEXT,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Size = UDim2.new(1, -12, 0, 14),
        Position = UDim2.new(0, 6, 0, 82),
    }, frame)

    local rarityLabel = new("TextLabel", {
        BackgroundTransparency = 1,
        Text = entry.rarity:upper(),
        Font = Enum.Font.GothamMedium,
        TextSize = 9,
        TextColor3 = rarityColor,
        Size = UDim2.new(1, -12, 0, 12),
        Position = UDim2.new(0, 6, 0, 98),
    }, frame)

    local badge = new("Frame", {
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 10, 0, 10),
        Position = UDim2.new(1, -38, 0, 7),
        Visible = false,
    }, frame)
    corner(badge, 5)
    new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 60, 60)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 230, 60)),
            ColorSequenceKeypoint.new(0.66, Color3.fromRGB(60, 220, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 60, 255)),
        }),
    }, badge)

    local star = new("TextButton", {
        Name = "Star",
        BackgroundTransparency = 1,
        Text = "\u{2605}",
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = C.SMOKE,
        AutoButtonColor = false,
        Size = UDim2.new(0, 24, 0, 22),
        Position = UDim2.new(1, -26, 0, 1),
        ZIndex = 3,
    }, frame)

    local card = {
        frame = frame, entry = entry, icon = icon, name = name, order = order,
        rarityLabel = rarityLabel, badge = badge, stroke = st, typeTag = typeTag, star = star,
    }

    star.MouseButton1Click:Connect(function() Gui.ToggleFavorite(entry.key) end)

    frame.MouseButton1Click:Connect(function()
        selected = entry
        repaint()
        if Gui.ShowPreview then Gui.ShowPreview() end
    end)

    return card
end

local function buildCards()
    if built then return end
    built = true
    loadFavorites()

    local list = Spawner.Catalog()
    if #list == 0 then
        setStatus("Couldn't read the item database (Database.Sync).", C.BAD)
        return
    end

    task.spawn(function()
        for i, entry in ipairs(list) do
            if not screen then return end
            local card = makeCard(entry, i)
            paintCard(card)
            table.insert(cards, card)
            if i % 40 == 0 then task.wait() end
        end
        applyFilter()
        setStatus(("%d items. Spawn, then equip from your inventory."):format(#list))
    end)
end

local function readQty()
    local n = math.floor(tonumber(qtyBox and qtyBox.Text) or 1)
    n = math.clamp(n, 1, 999)
    return n
end

local function doSpawn()
    if not selected then
        setStatus("Select an item first.", C.WARN)
        return
    end

    local key = spawnKey()
    if not key then
        setStatus(selected.name .. " has no chroma version.", C.WARN)
        return
    end

    local qty = readQty()
    State.SpawnerQty = qty

    local ok, message = Spawner.Give(key, qty)
    local label = (State.SpawnerChroma and "Chroma " or "") .. selected.name

    if ok then
        local suffix = selected.rarity == "Unique" and "" or (" x" .. qty)
        local text = "Spawned " .. label .. suffix .. " -- equip it from your inventory."
        if message then text = "Spawned " .. label .. " -- " .. message end
        if Spawner.MeshState == "failed" then
            text = text .. " (skin data didn't load, so it won't show when equipped)"
        end
        setStatus(text, C.OK)

        tween(spawnButton, { Size = UDim2.new(0, 112, 0, 34) }, 0.06)
        task.delay(0.08, function()
            if spawnButton then tween(spawnButton, { Size = UDim2.new(0, 118, 0, 38) }, 0.12) end
        end)
    else
        setStatus("Couldn't spawn " .. label .. ": " .. tostring(message), C.BAD)
    end
end

local function clearPreview()
    if preview.chroma then pcall(function() preview.chroma:Disconnect() end) end
    if preview.model then pcall(function() preview.model:Destroy() end) end
    preview.model, preview.chroma = nil, nil
end

local function frameModel(model)
    local center, size = Vector3.new(0, 0, 0), Vector3.new(4, 4, 4)
    pcall(function()
        local cf, s = model:GetBoundingBox()
        center, size = cf.Position, s
    end)
    local radius = math.max(size.X, size.Y, size.Z) / 2
    preview.center = center
    preview.dist = math.max(1.5, radius / math.tan(math.rad(20)) * 1.15)
end

local function showPreview()
    if not preview.viewport then return end
    clearPreview()
    preview.token = (preview.token or 0) + 1
    local token = preview.token

    if not selected then
        preview.label.Text = "Pick an item"
        preview.hint.Text = "Tap a card to see it in 3D"
        preview.fallback.Image = ""
        return
    end

    local key = spawnKey() or selected.key
    local chroma = State.SpawnerChroma and selected.chroma ~= nil
    preview.label.Text = (chroma and "Chroma " or "") .. selected.name
    preview.fallback.Image = selected.icon
    preview.fallback.Visible = true
    preview.hint.Text = "Loading 3D..."

    task.spawn(function()

        for _ = 1, 80 do
            if Spawner.MeshState ~= "loading" and Spawner.MeshState ~= "idle" then break end
            task.wait(0.25)
            if token ~= preview.token then return end
        end

        local ok, model, conn = pcall(Spawner.BuildPreview, key)
        if token ~= preview.token or not screen then
            if ok and model then pcall(function() model:Destroy() end) end
            if ok and conn then pcall(function() conn:Disconnect() end) end
            return
        end
        if not ok or not model then
            preview.hint.Text = "No 3D model for this one"
            return
        end

        frameModel(model)
        model.Parent = preview.viewport
        preview.model, preview.chroma = model, conn
        preview.fallback.Visible = false
        preview.hint.Text = "Drag to spin"
    end)
end

Gui.ShowPreview = showPreview

function Gui.ToggleFavorite(key)
    loadFavorites()
    favorites[key] = (not favorites[key]) or nil
    saveFavorites()
    for _, card in ipairs(cards) do
        if card.entry.key == key then paintCard(card) end
    end
    if filter == "Favorites" then applyFilter() end
end

function Gui.Select(key)
    for _, card in ipairs(cards) do
        if card.entry.key == key then
            selected = card.entry
            repaint()
            showPreview()
            return true
        end
    end
    return false
end

function Gui.SetFilter(name)
    filter = name
    paintChips()
    applyFilter()
end

function Gui.PreviewState()
    return preview
end

local function fitToScreen(scale)
    local camera = workspace.CurrentCamera
    local vp = camera and camera.ViewportSize
    if not vp or vp.X <= 0 then return end
    local s = math.min(1, (vp.X - 24) / BASE_W, (vp.Y - 24) / BASE_H)
    scale.Scale = math.max(0.45, s)
end

local function buildWindow()
    screen = new("ScreenGui", {
        Name = "RiftwareSpawner",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 1000,
    })
    screen.Parent = guiParent()

    window = new("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, BASE_W, 0, BASE_H),
        BackgroundColor3 = C.BG,
        BackgroundTransparency = 0.04,
        BorderSizePixel = 0,
        Active = true,
    }, screen)
    corner(window, 14)
    stroke(window, C.LINE, 1)

    local scale = new("UIScale", {}, window)
    fitToScreen(scale)
    local camera = workspace.CurrentCamera
    if camera then
        Util.Bind("spawnerfit", camera:GetPropertyChangedSignal("ViewportSize"), function()
            fitToScreen(scale)
        end)
    end

    local sheen = new("Frame", {
        BackgroundColor3 = C.GLINT,
        BackgroundTransparency = 0.94,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 52),
    }, window)
    corner(sheen, 14)
    new("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        }),
        Rotation = 90,
    }, sheen)

    local bar = new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 52),
        Active = true,
    }, window)
    makeDraggable(bar, window)

    local mark = new("ImageLabel", {
        BackgroundColor3 = C.BG,
        Image = Services.LogoImage,
        ScaleType = Enum.ScaleType.Crop,
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(0, 14, 0, 10),
    }, bar)
    corner(mark, 8)
    stroke(mark, C.LINE, 1)

    new("TextLabel", {
        BackgroundTransparency = 1,
        Text = "RIFTWARE",
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        TextColor3 = C.SUB,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0, 200, 0, 12),
        Position = UDim2.new(0, 56, 0, 11),
    }, bar)

    local title = new("TextLabel", {
        BackgroundTransparency = 1,
        Text = "Spawner",
        Font = Enum.Font.GothamBlack,
        TextSize = 18,
        TextColor3 = C.GLINT,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0, 200, 0, 20),
        Position = UDim2.new(0, 56, 0, 22),
    }, bar)
    chromeGradient(title)

    local close = new("TextButton", {
        BackgroundColor3 = C.PANEL,
        Text = "X",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = C.SILVER,
        AutoButtonColor = true,
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -46, 0, 10),
    }, bar)
    corner(close, 8)
    stroke(close, C.LINE, 1)

    statusLabel = new("TextLabel", {
        BackgroundTransparency = 1,
        Text = "",
        Font = Enum.Font.GothamMedium,
        TextSize = 10,
        TextColor3 = C.SUB,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextWrapped = true,
        Size = UDim2.new(0, 330, 0, 28),
        Position = UDim2.new(1, -388, 0, 12),
    }, bar)

    close.MouseButton1Click:Connect(function()
        Gui.SetVisible(false)
        if Gui.OnClosed then pcall(Gui.OnClosed) end
    end)

    local filters = new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -28, 0, 30),
        Position = UDim2.new(0, 14, 0, 58),
    }, window)

    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    }, filters)

    local chipNames = { "All", "Favorites" }
    for _, r in ipairs(Spawner.RARITIES) do table.insert(chipNames, r) end

    for i, chipName in ipairs(chipNames) do
        local button = new("TextButton", {
            BackgroundColor3 = C.GLINT,
            BackgroundTransparency = 1,
            Text = chipName == "Favorites" and "\u{2605} Favs" or chipName,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextColor3 = C.SILVER,
            AutoButtonColor = false,
            Size = UDim2.new(0, chipName == "All" and 44 or chipName == "Favorites" and 64 or 70, 0, 28),
            LayoutOrder = i,
        }, filters)
        corner(button, 14)
        local st = stroke(button, C.LINE, 1)
        local gradient = chromeGradient(button)
        gradient.Enabled = false

        chips[chipName] = { button = button, stroke = st, gradient = gradient }
        button.MouseButton1Click:Connect(function()
            filter = chipName
            paintChips()
            applyFilter()
        end)
    end
    paintChips()

    local search = new("TextBox", {
        BackgroundColor3 = C.PANEL,
        Text = "",
        PlaceholderText = "Search items...",
        PlaceholderColor3 = C.SMOKE,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = C.TEXT,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0, 150, 0, 28),
        Position = UDim2.new(1, -164, 0, 59),
    }, window)
    corner(search, 14)
    stroke(search, C.LINE, 1)
    new("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, search)
    search:GetPropertyChangedSignal("Text"):Connect(function()
        query = search.Text:lower():gsub("^%s+", ""):gsub("%s+$", "")
        applyFilter()
    end)

    grid = new("ScrollingFrame", {
        BackgroundColor3 = C.PANEL,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -(28 + PREVIEW_W + 8), 1, -174),
        Position = UDim2.new(0, 14, 0, 96),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = C.STEEL,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
    }, window)
    corner(grid, 10)

    new("UIPadding", {
        PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
    }, grid)
    new("UIGridLayout", {
        CellSize = UDim2.new(0, CARD_W, 0, CARD_H),
        CellPadding = UDim2.new(0, 8, 0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    }, grid)

    local pane = new("Frame", {
        Name = "Preview",
        BackgroundColor3 = C.PANEL,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        Size = UDim2.new(0, PREVIEW_W, 1, -174),
        Position = UDim2.new(1, -(14 + PREVIEW_W), 0, 96),
    }, window)
    corner(pane, 10)
    stroke(pane, C.LINE, 1)

    new("TextLabel", {
        BackgroundTransparency = 1,
        Text = "3D PREVIEW",
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        TextColor3 = C.SUB,
        Size = UDim2.new(1, -16, 0, 12),
        Position = UDim2.new(0, 8, 0, 8),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, pane)

    local viewport = new("ViewportFrame", {
        BackgroundColor3 = C.BG,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -16, 1, -70),
        Position = UDim2.new(0, 8, 0, 24),
        Ambient = Color3.fromRGB(160, 166, 180),
        LightColor = Color3.fromRGB(255, 255, 255),
        LightDirection = Vector3.new(-0.6, -1, -0.4),
        Active = true,
    }, pane)
    corner(viewport, 8)
    local camera = new("Camera", { FieldOfView = 40 }, viewport)
    viewport.CurrentCamera = camera

    local fallback = new("ImageLabel", {
        BackgroundTransparency = 1,
        ScaleType = Enum.ScaleType.Fit,
        Size = UDim2.new(0.7, 0, 0.7, 0),
        Position = UDim2.new(0.15, 0, 0.15, 0),
        ImageTransparency = 0.2,
        Image = "",
    }, viewport)

    local pLabel = new("TextLabel", {
        BackgroundTransparency = 1,
        Text = "Pick an item",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = C.TEXT,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Size = UDim2.new(1, -16, 0, 16),
        Position = UDim2.new(0, 8, 1, -42),
    }, pane)

    local pHint = new("TextLabel", {
        BackgroundTransparency = 1,
        Text = "Tap a card to see it in 3D",
        Font = Enum.Font.GothamMedium,
        TextSize = 9,
        TextColor3 = C.SUB,
        Size = UDim2.new(1, -16, 0, 12),
        Position = UDim2.new(0, 8, 1, -22),
    }, pane)

    preview.viewport, preview.camera, preview.fallback = viewport, camera, fallback
    preview.label, preview.hint = pLabel, pHint
    preview.yaw, preview.center, preview.dist = 0, Vector3.new(0, 0, 0), 6

    viewport.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            preview.dragging = input.Position
        end
    end)
    Util.Bind("spawnerpreviewdrag", UIS.InputChanged, function(input)
        if not preview.dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local dx = input.Position.X - preview.dragging.X
        preview.dragging = input.Position
        preview.yaw = preview.yaw - dx * 0.012
    end)
    Util.Bind("spawnerpreviewup", UIS.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            preview.dragging = nil
        end
    end)

    local lastT = os.clock()
    Util.Bind("spawnerpreview", RunService.Heartbeat, function()
        local now = os.clock()
        local dt = now - lastT
        lastT = now
        if not preview.model or not screen or not screen.Enabled then return end
        if not preview.dragging then preview.yaw = preview.yaw + dt * 0.9 end
        camera.CFrame = CFrame.new(preview.center) * CFrame.Angles(0, preview.yaw, 0)
            * CFrame.Angles(-0.28, 0, 0) * CFrame.new(0, 0, preview.dist)
    end)

    local footer = new("Frame", {
        BackgroundColor3 = C.PANEL,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -28, 0, 60),
        Position = UDim2.new(0, 14, 1, -72),
    }, window)
    corner(footer, 10)
    stroke(footer, C.LINE, 1)

    selectedIcon = new("ImageLabel", {
        BackgroundColor3 = C.CARD,
        Image = "",
        ScaleType = Enum.ScaleType.Fit,
        Size = UDim2.new(0, 44, 0, 44),
        Position = UDim2.new(0, 8, 0, 8),
    }, footer)
    corner(selectedIcon, 8)

    selectedLabel = new("TextLabel", {
        BackgroundTransparency = 1,
        Text = "Pick an item",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = C.TEXT,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Size = UDim2.new(0, 158, 0, 16),
        Position = UDim2.new(0, 60, 0, 13),
    }, footer)

    selectedRarity = new("TextLabel", {
        BackgroundTransparency = 1,
        Text = "Tap a card to select it",
        Font = Enum.Font.GothamMedium,
        TextSize = 10,
        TextColor3 = C.SUB,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0, 158, 0, 12),
        Position = UDim2.new(0, 60, 0, 31),
    }, footer)

    local qtyCaption = new("TextLabel", {
        BackgroundTransparency = 1,
        Text = "QTY",
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        TextColor3 = C.SUB,
        Size = UDim2.new(0, 96, 0, 10),
        Position = UDim2.new(1, -366, 0, 6),
    }, footer)

    local function stepButton(text, x)
        local b = new("TextButton", {
            BackgroundColor3 = C.CARD,
            Text = text,
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextColor3 = C.CHROME,
            AutoButtonColor = true,
            Size = UDim2.new(0, 28, 0, 28),
            Position = UDim2.new(1, x, 0, 20),
        }, footer)
        corner(b, 8)
        stroke(b, C.LINE, 1)
        return b
    end

    local minus = stepButton("-", -366)

    qtyBox = new("TextBox", {
        BackgroundColor3 = C.BG,
        Text = tostring(State.SpawnerQty or 1),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = C.TEXT,
        ClearTextOnFocus = false,
        Size = UDim2.new(0, 36, 0, 28),
        Position = UDim2.new(1, -334, 0, 20),
    }, footer)
    corner(qtyBox, 8)
    stroke(qtyBox, C.LINE, 1)

    local plus = stepButton("+", -294)

    local function bump(delta)
        qtyBox.Text = tostring(math.clamp(readQty() + delta, 1, 999))
    end
    minus.MouseButton1Click:Connect(function() bump(-1) end)
    plus.MouseButton1Click:Connect(function() bump(1) end)
    qtyBox.FocusLost:Connect(function()
        qtyBox.Text = tostring(readQty())
        State.SpawnerQty = readQty()
    end)
    qtyCaption.TextXAlignment = Enum.TextXAlignment.Left

    new("TextLabel", {
        BackgroundTransparency = 1,
        Text = "CHROMA",
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        TextColor3 = C.SUB,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0, 60, 0, 10),
        Position = UDim2.new(1, -252, 0, 6),
    }, footer)

    chromaTrack = new("TextButton", {
        BackgroundColor3 = C.CARD,
        Text = "",
        AutoButtonColor = false,
        Size = UDim2.new(0, 48, 0, 26),
        Position = UDim2.new(1, -252, 0, 21),
    }, footer)
    corner(chromaTrack, 13)
    local trackStroke = stroke(chromaTrack, C.LINE, 1)
    local trackGradient = new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 70, 70)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 225, 70)),
            ColorSequenceKeypoint.new(0.66, Color3.fromRGB(70, 220, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(215, 70, 255)),
        }),
        Enabled = false,
    }, chromaTrack)

    chromaKnob = new("Frame", {
        BackgroundColor3 = C.SILVER,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 3, 0.5, -10),
    }, chromaTrack)
    corner(chromaKnob, 10)

    local function paintChroma(animate)
        local on = State.SpawnerChroma == true
        local pos = on and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        if animate then tween(chromaKnob, { Position = pos }) else chromaKnob.Position = pos end
        chromaKnob.BackgroundColor3 = on and C.GLINT or C.SILVER
        trackGradient.Enabled = on
        chromaTrack.BackgroundColor3 = on and Color3.new(1, 1, 1) or C.CARD
        trackStroke.Transparency = on and 1 or 0
    end
    paintChroma(false)

    chromaTrack.MouseButton1Click:Connect(function()
        State.SpawnerChroma = not State.SpawnerChroma
        paintChroma(true)
        repaint()
        showPreview()
    end)

    Util.Bind("spawnerchip", RunService.Heartbeat, function()
        if State.SpawnerChroma and trackGradient.Enabled then
            trackGradient.Rotation = (os.clock() * 90) % 360
        end
    end)

    spawnButton = new("TextButton", {
        BackgroundColor3 = C.GLINT,
        Text = "SPAWN",
        Font = Enum.Font.GothamBlack,
        TextSize = 13,
        TextColor3 = C.BG,
        AutoButtonColor = true,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 118, 0, 38),
        Position = UDim2.new(1, -73, 0.5, 0),
    }, footer)
    corner(spawnButton, 10)
    chromeGradient(spawnButton)
    spawnButton.MouseButton1Click:Connect(doSpawn)

    refreshFooter()
end

function Gui.SetVisible(on)
    State.ShowSpawner = on

    if on then
        if not screen or not screen.Parent then
            screen = nil
            cards, chips, built, selected = {}, {}, false, nil
            buildWindow()
        end
        screen.Enabled = true
        setStatus("Loading items...")
        buildCards()

        Spawner.StartFx()
        Spawner.LoadMeshes(function(ok)
            if not ok then
                setStatus("Couldn't load skin data -- items still spawn, they just won't show when worn.", C.WARN)
            end
        end)
    elseif screen then
        screen.Enabled = false
    end
end

function Gui.Destroy()
    for _, conn in ipairs(dragConns) do pcall(function() conn:Disconnect() end) end
    dragConns = {}
    Util.Unbind("spawnerfit")
    Util.Unbind("spawnerchip")
    Util.Unbind("spawnerpreview")
    Util.Unbind("spawnerpreviewdrag")
    Util.Unbind("spawnerpreviewup")
    clearPreview()
    preview = {}
    if screen then pcall(function() screen:Destroy() end) end
    screen, window, grid = nil, nil, nil
    cards, chips, built, selected = {}, {}, false, nil
end

return Gui
end

__modules["features/SpawnerCards"] = function(import)

local Util       = import("core/Util")
local State      = import("core/State")
local Spawner    = import("features/Spawner")
local SpawnerGui = import("features/SpawnerGui")

local SpawnerCards = {}

SpawnerCards.FILTERS = { "All", "Favorites", "Ancient", "Godly", "Classic", "Unique", "Chroma", "Knives", "Guns" }

local function isFav(key)
    SpawnerGui.LoadFavorites()
    return SpawnerGui.Favorites[key] == true
end

local function toggleFav(key)
    SpawnerGui.ToggleFavorite(key)
end

local function frameModel(model)
    local center, size = Vector3.new(0, 0, 0), Vector3.new(4, 4, 4)
    pcall(function()
        local cf, s = model:GetBoundingBox()
        center, size = cf.Position, s
    end)
    local radius = math.max(size.X, size.Y, size.Z) / 2
    return center, math.max(1.5, radius / math.tan(math.rad(20)) * 1.15)
end

function SpawnerCards.Items()
    local list = {}
    for i, entry in ipairs(Spawner.Catalog()) do
        list[i] = {
            id = entry.key,
            title = entry.name,
            sub = entry.rarity,
            tag = entry.type == "Gun" and "GUN" or "KNIFE",
            image = entry.icon,
            color = Spawner.RarityColor(entry.rarity),
            entry = entry,
            search = table.concat({ entry.name, entry.key, entry.rarity, entry.type }, " "),
        }
    end
    return list
end

function SpawnerCards.Filter(item, name)
    local e = item.entry
    if name == "All" then return true end
    if name == "Favorites" then return isFav(e.key) end
    if name == "Chroma" then return e.chroma ~= nil end
    if name == "Knives" then return e.type == "Knife" end
    if name == "Guns" then return e.type == "Gun" end
    return e.rarity == name
end

function SpawnerCards.Spawn(entry)
    local chroma = State.SpawnerChroma and entry.chroma ~= nil
    local key = chroma and entry.chroma or entry.key
    local unique = entry.rarity == "Unique"
    local qty = unique and 1 or math.clamp(math.floor(tonumber(State.SpawnerQty) or 1), 1, 999)
    local name = (chroma and "Chroma " or "") .. entry.name

    local ok, message = Spawner.Give(key, qty)
    if not ok then return false, "Couldn't spawn " .. name .. ": " .. tostring(message) end

    local text = "Spawned " .. name .. (unique and "" or (" x" .. qty)) .. " -- equip it from your inventory."
    if message then text = "Spawned " .. name .. " -- " .. message end
    if Spawner.MeshState == "failed" then
        text = text .. " (skin data didn't load, so it won't show when equipped)"
    end
    return true, text
end

function SpawnerCards.Build(tab, window)
    local gallery

    local function openItem(entry)
        window:OpenPanel({
            Title = entry.name,
            Build = function(panel)
                local hero = panel:Hero({
                    Image = entry.icon,
                    Title = entry.name,
                    Sub = (entry.rarity .. "  ·  " .. entry.type):upper(),
                    Color = Spawner.RarityColor(entry.rarity),
                })

                local function chroma() return State.SpawnerChroma and entry.chroma ~= nil end
                local token
                local function loadModel()
                    local mine = {}
                    token = mine
                    hero:ClearModel()
                    hero:SetTitle((chroma() and "Chroma " or "") .. entry.name)
                    hero:SetHint("Loading 3D...")
                    task.spawn(function()

                        for _ = 1, 80 do
                            if Spawner.MeshState ~= "loading" and Spawner.MeshState ~= "idle" then break end
                            task.wait(0.25)
                            if token ~= mine or not panel:IsOpen() then return end
                        end
                        local ok, model, conn = pcall(Spawner.BuildPreview, chroma() and entry.chroma or entry.key)
                        if token ~= mine or not panel:IsOpen() then
                            if ok and model then pcall(function() model:Destroy() end) end
                            if ok and conn then pcall(function() conn:Disconnect() end) end
                            return
                        end
                        if not ok or not model then
                            hero:SetHint("No 3D model")
                            return
                        end
                        local center, dist = frameModel(model)
                        hero:ShowModel(model, center, dist, conn)
                        hero:SetHint("Drag to spin")
                    end)
                end

                if entry.chroma then
                    panel:Toggle({
                        Title = "Chroma",
                        Desc = "Spawn the chroma version.",
                        Value = State.SpawnerChroma == true,
                        Callback = function(v)
                            State.SpawnerChroma = v
                            loadModel()
                        end,
                    })
                end

                if entry.rarity ~= "Unique" then
                    panel:Slider({
                        Title = "Quantity",
                        Value = { Min = 1, Max = 100, Default = math.clamp(math.floor(tonumber(State.SpawnerQty) or 1), 1, 100) },
                        Step = 1,
                        Callback = function(v) State.SpawnerQty = v end,
                    })
                end

                panel:Button({
                    Title = "Spawn",
                    Desc = entry.rarity == "Unique" and "One of a kind. Client-side: only you see it."
                        or "Client-side: only you see it.",
                    Callback = function()
                        local _, text = SpawnerCards.Spawn(entry)
                        Util.Notify("Spawner", text)
                    end,
                })

                local favButton
                local function favTitle() return isFav(entry.key) and "Remove From Favorites" or "Add To Favorites" end
                favButton = panel:Button({
                    Title = favTitle(),
                    Callback = function()
                        toggleFav(entry.key)
                        favButton:SetTitle(favTitle())
                        if gallery then gallery:Repaint() end
                    end,
                })

                loadModel()
            end,
        })
    end
    SpawnerCards.Open = openItem

    gallery = tab:Gallery({
        Title = "Items",
        Filters = SpawnerCards.FILTERS,
        Items = SpawnerCards.Items,
        Filter = SpawnerCards.Filter,
        Favorite = { Get = isFav, Toggle = toggleFav },
        Badge = function(item) return item.entry.chroma ~= nil end,
        Order = function(item, i) return (isFav(item.id) and 0 or 100000) + i end,
        Empty = "Couldn't read the item database (Database.Sync). Rejoin and reload the hub.",
        OnSelect = function(item) openItem(item.entry) end,
        OnLoaded = function()

            pcall(Spawner.StartFx)
            pcall(Spawner.LoadMeshes, function() end)
        end,
    })
    SpawnerCards.Gallery = gallery
    return gallery
end

return SpawnerCards
end

__modules["features/Perks"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")

local LP = Services.LocalPlayer

local Perks = {}

local function service()
    local ok, mod = pcall(function()
        return require(Services.ReplicatedStorage
            :WaitForChild("ClientServices")
            :WaitForChild("PerkService"))
    end)
    if ok then return mod end
    return nil
end

function Perks.Instance()
    local char = Util.Character()
    if char then
        for _, child in ipairs(char:GetChildren()) do
            if child:HasTag("Perk") then return child end
        end
    end

    local playerGui = LP:FindFirstChildOfClass("PlayerGui")
    if playerGui then
        for _, child in ipairs(playerGui:GetChildren()) do
            if child:HasTag("Perk") then return child end
        end
    end

    return nil
end

function Perks.Equipped()
    return LP:GetAttribute("EquippedPerk") or "Footsteps"
end

function Perks.Info(name)
    local sync = Services.Sync
    if not sync or not sync.Perks then return nil end
    return sync.Perks[name or Perks.Equipped()]
end

function Perks.CooldownLeft()
    local inst = Perks.Instance()
    if not inst then return nil end

    local lastUse = inst:GetAttribute("LastUse")
    local cooldown = inst:GetAttribute("Cooldown")
    if type(lastUse) ~= "number" or type(cooldown) ~= "number" then return nil end

    local info = Perks.Info()
    local activeTime = info and info.ActiveTime or 0

    local elapsed = os.clock() - lastUse
    local left = (cooldown + activeTime) - elapsed
    if left < 0 then return 0 end
    return left
end

function Perks.Activate()
    local svc = service()
    if not svc or not svc.PerkActivated then
        return false, "PerkService unavailable"
    end

    if not Perks.Instance() then
        return false, "no perk this round (wrong role, or none equipped)"
    end

    local ok, err = pcall(function()
        svc.PerkActivated:Fire()
    end)

    if not ok then return false, tostring(err) end
    return true, Perks.Equipped()
end

function Perks.SetAutoGhost(on)
    State.AutoGhost = on

    if on then
        Util.Loop("autoghost", function() return 1 end, function()
            if not State.AutoGhost then return end
            if Perks.Equipped() ~= "Ghost" then return end

            local left = Perks.CooldownLeft()
            if left == nil or left <= 0 then
                Perks.Activate()
            end
        end)
    else
        Util.Unbind("autoghost")
    end
end

function Perks.Report()
    local inst = Perks.Instance()
    local equipped = Perks.Equipped()
    local info = Perks.Info(equipped)
    local left = Perks.CooldownLeft()

    local lines = {
        "Equipped perk: " .. tostring(equipped),
        "Perk instance this round: " .. (inst and "yes" or "no"),
        "Description: " .. tostring(info and info.Description or "?"),
        "Cooldown left: " .. (left and ("%.1fs"):format(left) or "unknown"),
    }

    local text = table.concat(lines, "\n")
    print("[Riftware] " .. text)
    return text
end

return Perks
end

__modules["features/BombJump"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")

local LP = Services.LocalPlayer
local RS = Services.ReplicatedStorage

local BombJump = {}

BombJump.COOLDOWN = 22
BombJump.POWER = 50

local lastUsed = -math.huge
local watch = {}

function BombJump.Remaining()
    return math.max(0, BombJump.COOLDOWN - (os.clock() - lastUsed))
end

local function markUsed()
    if BombJump.Remaining() > 0 then return end
    lastUsed = os.clock()
    if BombJump.OnCooldown then pcall(BombJump.OnCooldown) end
end

local function findBomb(char)
    local held = char:FindFirstChild("FakeBomb")
    if held then return held end
    local bag = LP:FindFirstChildOfClass("Backpack")
    return bag and bag:FindFirstChild("FakeBomb")
end

local function equip(humanoid, char, tool)
    if tool.Parent ~= char then
        humanoid:EquipTool(tool)
        task.wait(0.1)
    end
    return char:FindFirstChild("FakeBomb")
end

function BombJump.Go()
    local left = BombJump.Remaining()
    if left > 0 then return false, ("on cooldown for %.1fs"):format(left) end

    local char = LP.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not (humanoid and root) then return false, "no character" end

    local previous = char:FindFirstChildOfClass("Tool")
    if previous and previous.Name == "FakeBomb" then previous = nil end

    local bomb = findBomb(char)
    if not bomb then
        local remotes = RS:FindFirstChild("Remotes")
        local extras = remotes and remotes:FindFirstChild("Extras")
        local replicate = extras and extras:FindFirstChild("ReplicateToy")
        if replicate then
            pcall(function() replicate:InvokeServer("FakeBomb") end)
            task.wait(0.15)
            bomb = findBomb(char)
        end
    end
    if not bomb then return false, "couldn't get the Prank Bomb toy -- do you own it?" end

    bomb = equip(humanoid, char, bomb)
    local remote = bomb and bomb:FindFirstChild("Remote")
    if not remote then return false, "the bomb has no remote" end

    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    task.wait(0.05)
    local p = root.Position
    remote:FireServer(CFrame.new(p.X, p.Y - 3, p.Z), BombJump.POWER)
    markUsed()

    task.wait(0.1)
    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    task.wait(0.1)
    humanoid:UnequipTools()

    if previous and previous.Parent then
        task.wait(0.1)
        pcall(function() humanoid:EquipTool(previous) end)
    end
    return true
end

local function hookTool(tool)
    if tool:IsA("Tool") and tool.Name == "FakeBomb" and not watch[tool] then
        watch[tool] = tool.Activated:Connect(markUsed)
    end
end

local function hookContainer(key, container)
    if not container then return end
    for _, child in ipairs(container:GetChildren()) do hookTool(child) end
    Util.Bind(key, container.ChildAdded, hookTool)
end

function BombJump.Watch()
    hookContainer("bombbag", LP:FindFirstChildOfClass("Backpack"))
    hookContainer("bombchar", LP.Character)
    Util.Bind("bombrespawn", LP.CharacterAdded, function(char)
        task.wait(0.5)
        hookContainer("bombbag", LP:FindFirstChildOfClass("Backpack"))
        hookContainer("bombchar", char)
    end)
end

function BombJump.Destroy()
    Util.Unbind("bombbag")
    Util.Unbind("bombchar")
    Util.Unbind("bombrespawn")
    for tool, conn in pairs(watch) do
        pcall(function() conn:Disconnect() end)
        watch[tool] = nil
    end
end

return BombJump
end

__modules["features/Alarm"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")
local Roles    = import("core/Roles")
local Icons    = import("features/Icons")

local LP           = Services.LocalPlayer
local TweenService = Services.TweenService

local Alarm = {}

local PING  = "rbxasset://sounds/electronicpingshort.wav"
local RED   = Color3.fromRGB(255, 58, 72)
local INK   = Color3.fromRGB(13, 14, 18)
local GLINT = Color3.fromRGB(248, 250, 255)
local SILVER = Color3.fromRGB(184, 190, 202)

local W, H = 300, 58

local SLOWEST, FASTEST = 1.1, 0.12
local nextBeep = 0

local screen, pill, stroke, badge, title, sub, needle, bar, ping, scale
local inside = false
local shown = false

local function guiParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    return LP:WaitForChild("PlayerGui")
end

local function screenSize()
    local camera = workspace.CurrentCamera
    local vp = camera and camera.ViewportSize
    if vp and vp.X > 0 and vp.Y > 0 then return vp end
    return Vector2.new(1920, 1080)
end

local function round(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or UDim.new(1, 0)
    c.Parent = parent
end

local function tween(inst, props, time)
    pcall(function()
        TweenService:Create(inst, TweenInfo.new(time or 0.25, Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out), props):Play()
    end)
end

local function restY()
    local vp = screenSize()
    return math.max(52, math.floor(vp.Y * 0.07))
end

local function layout()
    if not pill then return end
    local vp = screenSize()
    if scale then scale.Scale = math.clamp(vp.X / 420, 0.75, 1.1) end
    pill.Position = UDim2.new(0.5, 0, 0, shown and restY() or -H)
end

Alarm.Layout = layout

local function build()
    if screen and screen.Parent then return end
    screen = Instance.new("ScreenGui")
    screen.Name = "RiftwareAlarm"
    screen.IgnoreGuiInset = true
    pcall(function() screen.ScreenInsets = Enum.ScreenInsets.None end)
    screen.ResetOnSpawn = false
    screen.DisplayOrder = 50
    screen.Enabled = false
    screen.Parent = guiParent()

    pill = Instance.new("CanvasGroup")
    pill.Name = "Pill"
    pill.AnchorPoint = Vector2.new(0.5, 0)
    pill.Size = UDim2.fromOffset(W, H)
    pill.BackgroundColor3 = INK
    pill.BackgroundTransparency = 0.06
    pill.BorderSizePixel = 0
    pill.GroupTransparency = 1
    pill.Parent = screen
    round(pill)
    scale = Instance.new("UIScale")
    scale.Parent = pill

    stroke = Instance.new("UIStroke")
    stroke.Color = RED
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3
    stroke.Parent = pill

    badge = Instance.new("Frame")
    badge.Name = "Badge"
    badge.Size = UDim2.fromOffset(40, 40)
    badge.Position = UDim2.fromOffset(9, 9)
    badge.BackgroundColor3 = RED
    badge.BorderSizePixel = 0
    badge.Parent = pill
    round(badge)
    local skull = Instance.new("ImageLabel")
    skull.BackgroundTransparency = 1
    skull.AnchorPoint = Vector2.new(0.5, 0.5)
    skull.Position = UDim2.fromScale(0.5, 0.5)
    skull.Size = UDim2.fromOffset(22, 22)
    skull.Image = Icons.Get("skull")
    skull.ImageColor3 = GLINT
    skull.Parent = badge

    title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(60, 11)
    title.Size = UDim2.new(1, -116, 0, 16)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = GLINT
    title.Text = "MURDERER NEARBY"
    title.Parent = pill

    sub = Instance.new("TextLabel")
    sub.BackgroundTransparency = 1
    sub.Position = UDim2.fromOffset(60, 29)
    sub.Size = UDim2.new(1, -116, 0, 14)
    sub.Font = Enum.Font.GothamMedium
    sub.TextSize = 11
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.TextColor3 = SILVER
    sub.TextTruncate = Enum.TextTruncate.AtEnd
    sub.Text = ""
    sub.Parent = pill

    local compass = Instance.new("Frame")
    compass.Name = "Compass"
    compass.Size = UDim2.fromOffset(40, 40)
    compass.Position = UDim2.new(1, -49, 0, 9)
    compass.BackgroundColor3 = Color3.fromRGB(26, 28, 34)
    compass.BorderSizePixel = 0
    compass.Parent = pill
    round(compass)
    local ring = Instance.new("UIStroke")
    ring.Color = RED
    ring.Transparency = 0.6
    ring.Parent = compass

    needle = Instance.new("Frame")
    needle.Name = "Needle"
    needle.AnchorPoint = Vector2.new(0.5, 0.5)
    needle.Position = UDim2.fromScale(0.5, 0.5)
    needle.Size = UDim2.fromOffset(40, 40)
    needle.BackgroundTransparency = 1
    needle.Parent = compass
    local tip = Instance.new("Frame")
    tip.AnchorPoint = Vector2.new(0.5, 0)
    tip.Position = UDim2.new(0.5, 0, 0, 6)
    tip.Size = UDim2.fromOffset(4, 15)
    tip.BackgroundColor3 = RED
    tip.BorderSizePixel = 0
    tip.Parent = needle
    round(tip)
    local hub = Instance.new("Frame")
    hub.AnchorPoint = Vector2.new(0.5, 0.5)
    hub.Position = UDim2.fromScale(0.5, 0.5)
    hub.Size = UDim2.fromOffset(8, 8)
    hub.BackgroundColor3 = GLINT
    hub.BorderSizePixel = 0
    hub.Parent = needle
    round(hub)

    local track = Instance.new("Frame")
    track.Position = UDim2.new(0, 60, 1, -9)
    track.Size = UDim2.new(1, -116, 0, 3)
    track.BackgroundColor3 = Color3.fromRGB(40, 42, 50)
    track.BorderSizePixel = 0
    track.Parent = pill
    round(track)
    bar = Instance.new("Frame")
    bar.Name = "Bar"
    bar.Size = UDim2.new(0, 0, 1, 0)
    bar.BackgroundColor3 = RED
    bar.BorderSizePixel = 0
    bar.Parent = track
    round(bar)

    ping = Instance.new("Sound")
    ping.SoundId = PING
    ping.Volume = 1
    ping.Parent = screen

    layout()
    local camera = workspace.CurrentCamera
    if camera then
        Util.Bind("alarmfit", camera:GetPropertyChangedSignal("ViewportSize"), layout)
    end
end

local function hide()
    inside = false
    if not shown then return end
    shown = false
    if pill then
        tween(pill, { GroupTransparency = 1, Position = UDim2.new(0.5, 0, 0, -H) }, 0.25)
        task.delay(0.26, function()
            if not shown and screen then screen.Enabled = false end
        end)
    end
end

function Alarm.BeepInterval(closeness)
    closeness = math.clamp(closeness, 0, 1)

    return SLOWEST + (FASTEST - SLOWEST) * (closeness ^ 1.6)
end

local function beep(closeness)
    pcall(function()
        ping.PlaybackSpeed = 1 + 0.35 * closeness
        ping.TimePosition = 0
        ping:Play()
    end)
end

local function bearing(murderer)
    local camera = workspace.CurrentCamera
    local char = murderer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not (camera and root) then return nil end
    local ok, angle = pcall(function()
        local rel = camera.CFrame:PointToObjectSpace(root.Position)
        return math.deg(math.atan2(rel.X, -rel.Z))
    end)
    return ok and angle or nil
end

Alarm.Bearing = bearing

local function step()
    local murderer = Roles.Murderer()
    if not murderer or murderer == LP or Roles.LocalIsMurderer() or not Util.Alive(LP) then
        hide()
        return
    end
    local distance = Util.Distance(murderer)
    if not distance or distance > State.AlarmRadius then
        hide()
        return
    end

    build()
    if not shown then
        shown = true
        screen.Enabled = true
        pill.Position = UDim2.new(0.5, 0, 0, -H)
        tween(pill, { GroupTransparency = 0, Position = UDim2.new(0.5, 0, 0, restY()) }, 0.3)
    end

    local closeness = 1 - math.clamp(distance / State.AlarmRadius, 0, 1)
    local pulse = 0.5 + 0.5 * math.sin(os.clock() * (5 + closeness * 9))
    stroke.Transparency = 0.55 - 0.45 * pulse * (0.4 + closeness * 0.6)
    badge.BackgroundColor3 = RED:Lerp(Color3.fromRGB(255, 120, 130), pulse * 0.35)
    bar.Size = UDim2.new(math.max(0.04, closeness), 0, 1, 0)
    sub.Text = ("%s  \u{00B7}  %dm"):format(murderer.DisplayName or murderer.Name, math.floor(distance))

    local angle = bearing(murderer)
    if angle then needle.Rotation = angle end

    local now = os.clock()
    if not inside then
        inside = true
        nextBeep = now
    end
    if State.AlarmSound and now >= nextBeep then
        beep(closeness)
        nextBeep = now + Alarm.BeepInterval(closeness)
    end
end

Alarm.Step = step

function Alarm.Showing()
    return shown
end

function Alarm.Set(on)
    State.MurdererAlarm = on
    if on then
        Util.Loop("alarm", function() return 0.05 end, step)
    else
        Util.Unbind("alarm")
        Util.Unbind("alarmfit")
        hide()
    end
end

function Alarm.Destroy()
    Alarm.Set(false)
    if screen then screen:Destroy() end
    screen, pill = nil, nil
    shown = false
end

return Alarm
end

__modules["features/WallHop"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")

local UIS = Services.UserInputService
local LP  = Services.LocalPlayer

local WallHop = {}

local REACH    = 4
local PUSH     = 14
local FLICK    = 60
local FLICK_T  = 0.08
local COOLDOWN = 0.2

local busy, lastHop = false, -math.huge

local function wallNear(char, root)
    local params = RaycastParams.new()
    pcall(function() params.FilterType = Enum.RaycastFilterType.Exclude end)
    params.FilterDescendantsInstances = { char }
    local cf = root.CFrame
    local dirs = { cf.LookVector, cf.RightVector, -cf.RightVector }
    for _, dir in ipairs(dirs) do
        local hit = workspace:Raycast(root.Position, dir * REACH, params)
        if hit and hit.Instance and hit.Instance.CanCollide then return hit end
    end
    return nil
end

WallHop.WallNear = wallNear

local function jump(humanoid, root, into)
    pcall(function()
        local v = root.AssemblyLinearVelocity
        root.AssemblyLinearVelocity = Vector3.new(into.X * PUSH, v.Y, into.Z * PUSH)
    end)
    humanoid.Jump = true
    pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
end

function WallHop.Go()
    if busy or os.clock() - lastHop < COOLDOWN then return false, "busy" end
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not (root and humanoid) then return false, "no character" end

    local hit = wallNear(char, root)
    if not hit then return false, "stand next to a wall first" end

    local flat = Vector3.new(-hit.Normal.X, 0, -hit.Normal.Z)
    if flat.Magnitude < 0.05 then return false, "that's a floor, not a wall" end
    local into = flat.Unit

    busy = true
    task.spawn(function()
        pcall(function()
            jump(humanoid, root, into)
            task.wait(0.12)
            root.CFrame = CFrame.lookAt(root.Position, root.Position + into) * CFrame.Angles(0, math.rad(FLICK), 0)
            task.wait(FLICK_T)
            root.CFrame = CFrame.lookAt(root.Position, root.Position + into)
            task.wait(0.03)
            jump(humanoid, root, into)
        end)
        busy = false
        lastHop = os.clock()
    end)
    return true
end

function WallHop.SetAuto(on)
    State.AutoWallHop = on
    if on then
        Util.Bind("wallhopauto", UIS.JumpRequest, function()
            local char = LP.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root and wallNear(char, root) then WallHop.Go() end
        end)
    else
        Util.Unbind("wallhopauto")
    end
end

function WallHop.Destroy()
    WallHop.SetAuto(false)
end

return WallHop
end

__modules["features/SkinTags"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")
local Roles    = import("core/Roles")

local Players = Services.Players
local LP      = Services.LocalPlayer

local SkinTags = {}

local folder
local tags = {}

local function guiParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and cg then return cg end
    return LP:WaitForChild("PlayerGui")
end

local function ensureFolder()
    if folder and folder.Parent then return folder end
    folder = Instance.new("Folder")
    folder.Name = "RiftwareSkinTags"
    folder.Parent = guiParent()
    return folder
end

local function iconFor(key)
    local db = Services.Sync and (Services.Sync.Weapons or Services.Sync.Item)
    local info = type(db) == "table" and key and db[key]
    local image = type(info) == "table" and info.Image
    if image == nil then return "" end
    local text = tostring(image)
    if tonumber(text) then
        return "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. text
    end
    return text
end

SkinTags.IconFor = iconFor

local function slot(parent, x, caption)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 36, 0, 36)
    frame.Position = UDim2.new(0.5, x, 0, 0)
    frame.BackgroundColor3 = Color3.fromRGB(14, 15, 19)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = parent
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0.3, 0)
    c.Parent = frame
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(226, 231, 240)
    s.Transparency = 0.6
    s.Parent = frame

    local img = Instance.new("ImageLabel")
    img.BackgroundTransparency = 1
    img.Size = UDim2.new(1, -4, 1, -4)
    img.Position = UDim2.new(0, 2, 0, 2)
    img.ScaleType = Enum.ScaleType.Fit
    img.Parent = frame

    local tag = Instance.new("TextLabel")
    tag.BackgroundTransparency = 1
    tag.Size = UDim2.new(1, 0, 0, 9)
    tag.Position = UDim2.new(0, 0, 1, 1)
    tag.Font = Enum.Font.GothamBold
    tag.TextSize = 8
    tag.TextColor3 = Color3.fromRGB(226, 231, 240)
    tag.TextStrokeTransparency = 0.3
    tag.Text = caption
    tag.Parent = frame
    return frame, img
end

local function make(plr)
    local gui = Instance.new("BillboardGui")
    gui.Name = "RiftwareSkins_" .. plr.Name
    gui.AlwaysOnTop = true
    gui.Size = UDim2.new(0, 84, 0, 48)
    gui.StudsOffset = Vector3.new(0, 4.6, 0)
    gui.Parent = ensureFolder()
    local gunFrame, gun = slot(gui, -40, "GUN")
    local knifeFrame, knife = slot(gui, 4, "KNIFE")
    return { gui = gui, gun = gun, knife = knife, gunFrame = gunFrame, knifeFrame = knifeFrame }
end

local function clear(plr)
    local t = tags[plr]
    if t then pcall(function() t.gui:Destroy() end) end
    tags[plr] = nil
end

local function step()
    local data = Roles.Data() or {}
    local seen = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        local entry = data[plr.Name]
        local char = Util.Character(plr)
        local head = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
        local show = plr ~= LP and type(entry) == "table" and head and Util.Alive(plr)
            and not Roles.IsDead(plr)
        if show then
            seen[plr] = true
            local t = tags[plr]
            if not t or not t.gui.Parent then
                clear(plr)
                t = make(plr)
                tags[plr] = t
            end
            t.gui.Adornee = head
            if t.gunKey ~= entry.Gun then
                t.gunKey = entry.Gun
                t.gun.Image = iconFor(entry.Gun)
            end
            if t.knifeKey ~= entry.Knife then
                t.knifeKey = entry.Knife
                t.knife.Image = iconFor(entry.Knife)
            end
            t.gunFrame.Visible = entry.Gun ~= nil
            t.knifeFrame.Visible = entry.Knife ~= nil
        end
    end
    for plr in pairs(tags) do
        if not seen[plr] then clear(plr) end
    end
end

SkinTags.Step = step

function SkinTags.Set(on)
    State.EspSkins = on
    if on then
        Util.Loop("skintags", function() return 0.5 end, step)
    else
        Util.Unbind("skintags")
        for plr in pairs(tags) do clear(plr) end
    end
end

function SkinTags.Destroy()
    SkinTags.Set(false)
    if folder then pcall(function() folder:Destroy() end) end
    folder = nil
end

return SkinTags
end

__modules["features/Session"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")

local LP = Services.LocalPlayer

local Session = {}

local function nudge()
    pcall(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new(0, 0))
    end)
end

Session.Nudge = nudge

function Session.SetAntiAfk(on)
    State.AntiAfk = on
    if on then
        Util.Bind("antiafk", LP.Idled, nudge)

        if getconnections then
            pcall(function()
                for _, c in ipairs(getconnections(LP.Idled)) do
                    if c.Function ~= nudge and c.Disable then c:Disable() end
                end
            end)
        end
    else
        Util.Unbind("antiafk")
    end
end

local rejoining = false

local function rejoin()
    if rejoining then return end
    rejoining = true
    Util.Notify("Auto Rejoin", "Disconnected -- rejoining...")
    local TP = game:GetService("TeleportService")
    task.spawn(function()
        task.wait(1)
        if game.JobId ~= "" then
            pcall(function() TP:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) end)
            task.wait(8)
        end

        pcall(function() TP:Teleport(game.PlaceId, LP) end)
        task.wait(10)
        rejoining = false
    end)
end

Session.Rejoin = rejoin

local function isKickPrompt(child)
    return child.Name == "ErrorPrompt"
end

function Session.SetAutoRejoin(on)
    State.AutoRejoin = on
    if not on then
        Util.Unbind("rejoinprompt")
        Util.Unbind("rejoinerror")
        return
    end

    local ok, overlay = pcall(function()
        return game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui")
            and game:GetService("CoreGui").RobloxPromptGui:FindFirstChild("promptOverlay")
    end)
    if ok and overlay then
        Util.Bind("rejoinprompt", overlay.ChildAdded, function(child)
            if isKickPrompt(child) then rejoin() end
        end)
    end

    pcall(function()
        local gs = game:GetService("GuiService")
        Util.Bind("rejoinerror", gs.ErrorMessageChanged, function()
            local msg = gs:GetErrorMessage()
            if msg and msg ~= "" then rejoin() end
        end)
    end)
end

function Session.Destroy()
    Session.SetAntiAfk(false)
    Session.SetAutoRejoin(false)
end

return Session
end

__modules["features/Crosshair"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")

local RunService = Services.RunService
local UIS        = Services.UserInputService
local LP         = Services.LocalPlayer

local Crosshair = {}

Crosshair.Presets = {
    { name = "Sharingan",         id = "11770890197" },
    { name = "Neon Red",          id = "11770691141" },
    { name = "Heart",             id = "10878218308" },
    { name = "Neon Blue",         id = "10891594349" },
    { name = "Egirl",             id = "11720475063" },
    { name = "UwU",               id = "10831379335" },
    { name = "Straight",          id = "8375241602"  },
    { name = "Cat",               id = "71595702163164" },
    { name = "Neon Green Circle", id = "97295979014116" },
    { name = "Lebron",            id = "103712597143260" },
    { name = "Nyan Cat",          id = "95246331144167" },
    { name = "Minecraft Sword",   id = "103419271184489" },
    { name = "Nikilis",           id = "134047116604554" },
}

local gui, image

local function guiParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and cg then return cg end
    return LP:WaitForChild("PlayerGui")
end

local function hideGameCrosshair(hide)
    pcall(function()
        LP.PlayerGui.GameTopbar.Crosshair.Visible = not hide
    end)
end

local function destroy()
    Util.Unbind("crosshair")
    Util.Unbind("crosshairspin")
    if gui then
        gui:Destroy()
        gui = nil
        image = nil
    end
end

Crosshair.Destroy = destroy

local function spinStep()
    if image and image.Parent and image.Visible then
        image.Rotation = image.Rotation + 4
    end
end

function Crosshair.UpdateSpin()
    Util.Unbind("crosshairspin")
    if State.CrosshairSpin and image then
        Util.Bind("crosshairspin", RunService.RenderStepped, spinStep)
    end
end

local function renderStep()
    if not image or not image.Parent then return end

    if not State.Crosshair then
        UIS.MouseIconEnabled = true
        hideGameCrosshair(false)
        image.Visible = false
        return
    end

    UIS.MouseIconEnabled = false
    hideGameCrosshair(true)

    local camera = workspace.CurrentCamera
    if UIS.MouseBehavior == Enum.MouseBehavior.LockCenter and camera then
        image.Position = UDim2.fromOffset(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    else
        local mouse = UIS:GetMouseLocation()
        image.Position = UDim2.fromOffset(mouse.X, mouse.Y)
    end

    image.Visible = true
end

function Crosshair.Set(on)
    State.Crosshair = on
    destroy()

    if not on then
        UIS.MouseIconEnabled = true
        hideGameCrosshair(false)
        return
    end

    UIS.MouseIconEnabled = false
    hideGameCrosshair(true)

    gui = Instance.new("ScreenGui")
    gui.Name = "RiftwareCrosshair"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 25
    gui.IgnoreGuiInset = true
    gui.Parent = guiParent()

    local mouse = UIS:GetMouseLocation()

    image = Instance.new("ImageLabel")
    image.AnchorPoint = Vector2.new(0.5, 0.5)
    image.Position = UDim2.fromOffset(mouse.X, mouse.Y)
    image.Size = UDim2.fromOffset(State.CrosshairSize or 42, State.CrosshairSize or 42)
    image.BackgroundTransparency = 1
    image.Image = "rbxassetid://" .. tostring(State.CrosshairId or Crosshair.Presets[1].id)
    image.ZIndex = 10
    image.Visible = true
    image.Parent = gui

    Util.Bind("crosshair", RunService.RenderStepped, renderStep)
    Crosshair.UpdateSpin()
end

function Crosshair.SetImage(id)
    State.CrosshairId = id
    if image then
        image.Image = "rbxassetid://" .. tostring(id)
    end
end

function Crosshair.SetSize(size)
    State.CrosshairSize = size
    if image then
        image.Size = UDim2.fromOffset(size, size)
    end
end

function Crosshair.PresetLabels()
    local labels, lookup = {}, {}
    for _, preset in ipairs(Crosshair.Presets) do
        local label = preset.name .. " (" .. preset.id .. ")"
        table.insert(labels, label)
        lookup[label] = preset.id
    end
    return labels, lookup
end

return Crosshair
end

__modules["features/Buttons"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")

local UIS = Services.UserInputService
local LP  = Services.LocalPlayer

local Buttons = {}

Buttons.Registry = {}

local CONFIG = {
    Size = 72,
    DragThreshold = 6,
    Columns = 7,
    PaddingX = 8,
    PaddingY = 8,
}

Buttons.CONFIG = CONFIG

local GLINT  = Color3.fromRGB(248, 250, 255)
local CHROME = Color3.fromRGB(226, 231, 240)
local SILVER = Color3.fromRGB(184, 190, 202)
local STEEL  = Color3.fromRGB(150, 158, 172)

Buttons.STYLES = { "Squircle", "Orb", "Frost", "Halo" }

local screenGui, container

local function ensureGui()
    if screenGui and screenGui.Parent then return end

    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RiftwareButtons"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = LP:WaitForChild("PlayerGui")

    container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.fromScale(1, 1)
    container.BackgroundTransparency = 1
    container.Parent = screenGui
end

local Button = {}
Button.__index = Button

local function styleOf()
    local name = State.ButtonStyle
    for _, s in ipairs(Buttons.STYLES) do
        if s == name then return s end
    end
    return Buttons.STYLES[1]
end

function Button:applyState()
    self:paint(self.State)
end

function Button:flash()
    self:paint(true)
    task.spawn(function()
        task.wait(0.12)
        if not self.Card or not self.Card.Parent then return end
        self:paint(false)
    end)
end

function Button:SetState(value)
    self.State = value
    self:applyState()
end

function Button:UpdateVisibility()
    self.Card.Visible = self.Visible and State.ShowFloatingButtons
end

function Button:SetVisible(value)
    self.Visible = value
    self:UpdateVisibility()
end

function Button:Destroy()
    if self.Card then self.Card:Destroy() end
    Buttons.Registry[self.Name] = nil
end

local FONT = Enum.Font.GothamBold
pcall(function() FONT = Enum.Font.BuilderSansBold end)

local SQUIRCLE = UDim.new(0.3, 0)
local ROUND    = UDim.new(1, 0)

local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function colors(list)
    local kps = {}
    for i, c in ipairs(list) do
        table.insert(kps, ColorSequenceKeypoint.new((i - 1) / (#list - 1), c))
    end
    return ColorSequence.new(kps)
end

local function alphas(a, b)
    return NumberSequence.new({ NumberSequenceKeypoint.new(0, a), NumberSequenceKeypoint.new(1, b) })
end

local function gradient(parent, list, rotation)
    local g = Instance.new("UIGradient")
    g.Color = colors(list)
    g.Rotation = rotation or 90
    g.Parent = parent
    return g
end

local function frame(parent, name, z)
    local f = Instance.new("Frame")
    f.Name = name
    f.Size = UDim2.fromScale(1, 1)
    f.BorderSizePixel = 0
    f.ZIndex = z or 1
    f.Parent = parent
    return f
end

local function glow(parent, radius, grow)
    local g = frame(parent, "Glow", 0)
    g.Size = UDim2.new(1, grow * 2, 1, grow * 2)
    g.Position = UDim2.fromOffset(-grow, -grow)
    g.BackgroundTransparency = 1
    corner(g, radius)
    return g
end

local function icon(self, parent, px, y)
    local img = Instance.new("ImageLabel")
    img.Size = UDim2.fromOffset(px, px)
    img.AnchorPoint = Vector2.new(0.5, 0.5)
    img.Position = UDim2.fromScale(0.5, y or 0.5)
    img.BackgroundTransparency = 1
    img.Image = self.IconId
    img.ZIndex = 3
    img.Parent = parent
    return img
end

local function label(parent, text, px)
    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Text = text
    t.Font = FONT
    t.TextSize = math.max(9, px)
    t.TextWrapped = false
    t.TextTruncate = Enum.TextTruncate.AtEnd
    t.ZIndex = 3
    t.Parent = parent
    return t
end

local function card(self, w, h)
    local f = Instance.new("Frame")
    f.Name = "Card_" .. self.Name
    f.Size = UDim2.fromOffset(w, h)
    f.Position = self.Pos
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.Visible = self.Visible and State.ShowFloatingButtons
    f.Parent = container
    return f
end

local BLACK = Color3.new(0, 0, 0)
local WHITE = Color3.new(1, 1, 1)

local function dim(a) return a:Lerp(STEEL, 0.3) end
local function deep(a) return a:Lerp(BLACK, 0.45) end
local function light(a) return a:Lerp(WHITE, 0.22) end
local function hint(a) return rgb(22, 23, 28):Lerp(a, 0.14) end

local spinning = {}

local function spinStep()
    local rot = (os.clock() * 140) % 360
    for g in pairs(spinning) do
        if g.Parent then g.Rotation = rot else spinning[g] = nil end
    end
end

local STYLE = {}

STYLE["Squircle"] = {
    size = function(s) return s, s end,
    build = function(self, s)
        self.Card = card(self, s, s)
        self.Glow = glow(self.Card, UDim.new(0.34, 0), 4)

        self.Body = frame(self.Card, "Body", 1)
        self.Body.BackgroundColor3 = Color3.new(1, 1, 1)
        corner(self.Body, SQUIRCLE)
        self.BodyGrad = gradient(self.Body, { rgb(38, 40, 48), rgb(18, 19, 23) }, 90)
        self.Stroke = stroke(self.Body, GLINT, 1, 0)
        self.Edge = gradient(self.Stroke, { GLINT, GLINT }, 90)

        self.Icon = icon(self, self.Body, math.floor(s * 0.4), 0.4)
        self.Text = label(self.Body, self.Label, math.floor(s * 0.135))
        self.Text.Size = UDim2.new(1, -8, 0, math.floor(s * 0.22))
        self.Text.Position = UDim2.new(0, 4, 1, -math.floor(s * 0.29))
    end,
    paint = function(self, on)
        local a = self.Accent
        self.Glow.BackgroundColor3 = a
        self.Glow.BackgroundTransparency = on and 0.72 or 1
        self.BodyGrad.Color = colors(on and { light(a), deep(a) } or { hint(a), rgb(16, 17, 21) })
        self.Stroke.Color = on and WHITE or a
        self.Edge.Transparency = on and alphas(0.35, 0.85) or alphas(0.45, 0.9)
        self.Icon.ImageColor3 = on and WHITE or dim(a)
        self.Text.TextColor3 = on and WHITE or SILVER
    end,
}

STYLE["Orb"] = {
    size = function(s)
        local d = math.floor(s * 0.86)
        return d, d + math.floor(s * 0.24)
    end,
    build = function(self, s)
        local d = math.floor(s * 0.86)
        local w, h = STYLE["Orb"].size(s)
        self.Card = card(self, w, h)

        local top = frame(self.Card, "Top", 1)
        top.Size = UDim2.fromOffset(d, d)
        top.BackgroundTransparency = 1
        self.Glow = glow(top, ROUND, 5)

        self.Body = frame(top, "Disc", 1)
        self.Body.BackgroundColor3 = Color3.new(1, 1, 1)
        corner(self.Body, ROUND)
        self.BodyGrad = gradient(self.Body, { rgb(34, 36, 44), rgb(14, 15, 18) }, 90)
        self.Stroke = stroke(self.Body, GLINT, 1, 0)
        self.Edge = gradient(self.Stroke, { GLINT, GLINT }, 90)

        self.Icon = icon(self, self.Body, math.floor(d * 0.44))

        self.Text = label(self.Card, self.Label, math.floor(s * 0.13))
        self.Text.Size = UDim2.new(1, 24, 0, h - d)
        self.Text.Position = UDim2.new(0, -12, 0, d + 1)
        self.Text.TextStrokeTransparency = 0.25
    end,
    paint = function(self, on)
        local a = self.Accent
        self.Glow.BackgroundColor3 = a
        self.Glow.BackgroundTransparency = on and 0.7 or 1
        self.BodyGrad.Color = colors(on and { light(a), a, deep(a) } or { hint(a), rgb(14, 15, 18) })
        self.Stroke.Color = on and WHITE or a
        self.Edge.Transparency = on and alphas(0.2, 0.8) or alphas(0.5, 0.95)
        self.Icon.ImageColor3 = on and WHITE or dim(a)
        self.Text.TextColor3 = on and WHITE or CHROME
    end,
}

STYLE["Frost"] = {
    size = function(s) return s, s end,
    build = function(self, s)
        self.Card = card(self, s, s)
        self.Body = frame(self.Card, "Glass", 1)
        self.Body.BackgroundColor3 = rgb(225, 232, 245)
        corner(self.Body, SQUIRCLE)
        self.Stroke = stroke(self.Body, GLINT, 1, 0)
        self.Edge = gradient(self.Stroke, { GLINT, GLINT }, 90)

        local sheen = frame(self.Body, "Sheen", 2)
        sheen.Size = UDim2.fromScale(1, 0.5)
        sheen.BackgroundColor3 = GLINT
        corner(sheen, UDim.new(0.6, 0))
        local sg = gradient(sheen, { GLINT, GLINT }, 90)
        sg.Transparency = alphas(0.8, 1)

        self.Icon = icon(self, self.Body, math.floor(s * 0.4), 0.42)
        self.Text = label(self.Body, self.Label, math.floor(s * 0.135))
        self.Text.Size = UDim2.new(1, -8, 0, math.floor(s * 0.22))
        self.Text.Position = UDim2.new(0, 4, 1, -math.floor(s * 0.29))
        self.Text.TextStrokeTransparency = 0.6

        local dot = math.max(6, math.floor(s * 0.09))
        self.Dot = frame(self.Body, "Dot", 3)
        self.Dot.Size = UDim2.fromOffset(dot, dot)
        self.Dot.AnchorPoint = Vector2.new(1, 0)
        self.Dot.Position = UDim2.new(1, -math.floor(s * 0.13), 0, math.floor(s * 0.13))
        corner(self.Dot, ROUND)
        self.DotRing = stroke(self.Dot, GLINT, 2, 1)
    end,
    paint = function(self, on)
        local a = self.Accent
        self.Body.BackgroundColor3 = on and a or rgb(225, 232, 245)
        self.Body.BackgroundTransparency = on and 0.5 or 0.86
        self.Stroke.Color = on and light(a) or GLINT
        self.Edge.Transparency = on and alphas(0, 0.45) or alphas(0.35, 0.85)
        self.Icon.ImageColor3 = on and WHITE or light(a)
        self.Text.TextColor3 = GLINT
        self.Dot.BackgroundColor3 = on and WHITE or a
        self.Dot.BackgroundTransparency = on and 0 or 0.25
        self.DotRing.Color = on and WHITE or a
        self.DotRing.Transparency = on and 0.5 or 1
    end,
}

STYLE["Halo"] = {
    size = function(s)
        local d = math.floor(s * 0.86)
        return d, d + math.floor(s * 0.24)
    end,
    build = function(self, s)
        local d = math.floor(s * 0.86)
        local w, h = STYLE["Halo"].size(s)
        self.Card = card(self, w, h)

        self.Body = frame(self.Card, "Disc", 1)
        self.Body.Size = UDim2.fromOffset(d, d)
        self.Body.BackgroundColor3 = rgb(12, 13, 16)
        self.Body.BackgroundTransparency = 0.08
        corner(self.Body, ROUND)
        self.Stroke = stroke(self.Body, GLINT, 2, 0)
        self.Ring = gradient(self.Stroke, { GLINT, GLINT }, 0)

        self.Icon = icon(self, self.Body, math.floor(d * 0.44))

        self.Text = label(self.Card, self.Label, math.floor(s * 0.13))
        self.Text.Size = UDim2.new(1, 24, 0, h - d)
        self.Text.Position = UDim2.new(0, -12, 0, d + 1)
        self.Text.TextStrokeTransparency = 0.25

        Util.Bind("btnhalo", Services.RunService.Heartbeat, spinStep)
    end,
    paint = function(self, on)
        local a = self.Accent
        if on then
            self.Stroke.Thickness = 3
            self.Ring.Color = colors({ a, light(a), a })
            self.Ring.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(0.5, 0.85),
                NumberSequenceKeypoint.new(1, 0),
            })
            spinning[self.Ring] = true
        else
            self.Stroke.Thickness = 2
            self.Ring.Color = colors({ a, a })
            self.Ring.Transparency = alphas(0.55, 0.55)
            self.Ring.Rotation = 0
            spinning[self.Ring] = nil
        end
        self.Body.BackgroundColor3 = on and rgb(12, 13, 16):Lerp(a, 0.2) or rgb(12, 13, 16)
        self.Icon.ImageColor3 = on and light(a) or dim(a)
        self.Text.TextColor3 = on and WHITE or CHROME
    end,
}

Buttons.StyleSize = function(name, base)
    return (STYLE[name] or STYLE[Buttons.STYLES[1]]).size(base)
end

local function build(self)
    local style = STYLE[styleOf()]
    self.paint = style.paint
    style.build(self, CONFIG.Size)
    self.W, self.H = style.size(CONFIG.Size)

    self.Hitbox = Instance.new("TextButton")
    self.Hitbox.Size = UDim2.fromScale(1, 1)
    self.Hitbox.BackgroundTransparency = 1
    self.Hitbox.Text = ""
    self.Hitbox.ZIndex = 10
    self.Hitbox.Parent = self.Card

    self:paint(self.State)
end

local function wire(self)
    local dragging, dragStart, startPos, moved = false, nil, nil, false

    self.Hitbox.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch then return end
        dragging = true
        moved = false
        dragStart = input.Position
        startPos = self.Card.Position
    end)

    Util.Bind("btnmove_" .. self.Name, UIS.InputChanged, function(input)
        if State.LockButtons then return end
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then return end

        local delta = input.Position - dragStart
        if delta.Magnitude > CONFIG.DragThreshold then moved = true end

        local viewport = workspace.CurrentCamera.ViewportSize
        self.Card.Position = UDim2.fromOffset(
            math.clamp(startPos.X.Offset + delta.X, 0, viewport.X - self.W),
            math.clamp(startPos.Y.Offset + delta.Y, 0, viewport.Y - self.H)
        )
    end)

    Util.Bind("btnup_" .. self.Name, UIS.InputEnded, function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch then return end
        if not dragging then return end
        dragging = false

        if not moved then
            if self.IsToggle then
                self.State = not self.State
                self:applyState()
            else
                self:flash()
            end
            task.spawn(function() self.Callback(self.State) end)
        end

        moved = false
    end)
end

function Buttons.New(data)
    ensureGui()

    local self = setmetatable({}, Button)
    self.Name = data.name
    self.Label = data.label or data.name
    self.IconId = data.icon or "rbxassetid://13804593521"
    self.Accent = data.accent or Color3.fromRGB(80, 180, 255)
    self.IsToggle = data.isToggle or false
    self.State = data.initState or false
    self.Pos = data.pos or UDim2.fromOffset(20, 20)
    self.Callback = data.callback or function() end
    self.Visible = data.visible ~= false
    self.VisibleFlag = data.visibleFlag

    build(self)
    wire(self)

    Buttons.Registry[self.Name] = self
    return self
end

function Buttons.Create(configs)
    Buttons.DestroyAll()

    local w, h = Buttons.StyleSize(styleOf(), CONFIG.Size)
    local columns = w > CONFIG.Size and math.max(1, math.floor(CONFIG.Columns * CONFIG.Size / w)) or CONFIG.Columns

    local index = 0
    for _, config in ipairs(configs) do
        local row = math.floor(index / columns)
        local col = index % columns

        config.pos = UDim2.fromOffset(
            20 + col * (w + CONFIG.PaddingX),
            20 + row * (h + CONFIG.PaddingY)
        )
        config.visible = State[config.visibleFlag] ~= false

        Buttons.New(config)
        index = index + 1
    end
end

function Buttons.Refresh()
    for _, button in pairs(Buttons.Registry) do
        if button.VisibleFlag then
            button.Visible = State[button.VisibleFlag] == true
        end
        button:UpdateVisibility()
    end
end

function Buttons.SetVisible(name, value)
    local button = Buttons.Registry[name]
    if button then button:SetVisible(value) end
end

function Buttons.SetState(name, value)
    local button = Buttons.Registry[name]
    if button then button:SetState(value) end
end

function Buttons.SetLabel(name, text)
    local button = Buttons.Registry[name]
    if not button then return end
    button.Label = text
    if button.Text then button.Text.Text = text end
end

function Button:rebuild()
    self.Pos = self.Card and self.Card.Position or self.Pos
    if self.Card then self.Card:Destroy() end
    if self.Ring then spinning[self.Ring] = nil end
    self.Glow, self.Body, self.BodyGrad, self.Edge, self.Dot, self.DotRing, self.Ring, self.Text = nil
    build(self)
    wire(self)
end

local function rebuildAll()
    for _, button in pairs(Buttons.Registry) do button:rebuild() end
end

function Buttons.Resize(size)
    CONFIG.Size = size
    rebuildAll()
end

function Buttons.SetStyle(name)
    State.ButtonStyle = name
    rebuildAll()
end

function Buttons.DestroyAll()
    Util.Unbind("btnhalo")
    spinning = {}
    for name, button in pairs(Buttons.Registry) do
        Util.Unbind("btnmove_" .. name)
        Util.Unbind("btnup_" .. name)
        button:Destroy()
    end
    Buttons.Registry = {}

    if screenGui then
        screenGui:Destroy()
        screenGui = nil
        container = nil
    end
end

return Buttons
end

__modules["features/Icons"] = function(import)

local Icons = {}

local URL = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua"
local CACHE = "Riftware/lucide.lua"
local FALLBACK = "rbxassetid://13804593521"

Icons.Fallback = FALLBACK

local table_ = nil
local tried = false

local function fetch()

    if isfile and readfile then
        local ok, body = pcall(function()
            if isfile(CACHE) then return readfile(CACHE) end
            return nil
        end)
        if ok and type(body) == "string" and #body > 1000 then
            local chunk = loadstring(body)
            if chunk then
                local ran, result = pcall(chunk)
                if ran and type(result) == "table" then return result end
            end
        end
    end

    local ok, body = pcall(function() return game:HttpGet(URL) end)
    if not ok or type(body) ~= "string" or #body < 1000 then return nil end

    local chunk = loadstring(body)
    if not chunk then return nil end

    local ran, result = pcall(chunk)
    if not ran or type(result) ~= "table" then return nil end

    if writefile and makefolder and isfolder then
        pcall(function()
            if not isfolder("Riftware") then makefolder("Riftware") end
            writefile(CACHE, body)
        end)
    end

    return result
end

function Icons.Load()
    if tried then return table_ end
    tried = true
    table_ = fetch()
    return table_
end

function Icons.Get(name)
    if not name then return FALLBACK end

    local set = Icons.Load()
    if set and set[name] then return set[name] end

    return FALLBACK
end

function Icons.Available()
    return Icons.Load() ~= nil
end

local GEIST_URL = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/geist/dist/Icons.lua"
local GEIST_CACHE = "Riftware/geist.lua"

local BUILTIN_SPRITES = {
    ["logo-discord"] = { Image = "rbxassetid://86699749765447",
                         ImageRectOffset = Vector2.new(256, 0), ImageRectSize = Vector2.new(128, 128) },
}

local geist, geistTried = nil, false

local function loadChunk(body)
    if type(body) ~= "string" or #body < 1000 then return nil end
    local chunk = loadstring(body)
    if not chunk then return nil end
    local ran, result = pcall(chunk)
    return (ran and type(result) == "table" and type(result.Icons) == "table") and result or nil
end

local function fetchGeist()
    if isfile and readfile then
        local ok, body = pcall(function() return isfile(GEIST_CACHE) and readfile(GEIST_CACHE) or nil end)
        local set = ok and loadChunk(body)
        if set then return set end
    end
    local ok, body = pcall(function() return game:HttpGet(GEIST_URL) end)
    local set = ok and loadChunk(body)
    if set and writefile and makefolder and isfolder then
        pcall(function()
            if not isfolder("Riftware") then makefolder("Riftware") end
            writefile(GEIST_CACHE, body)
        end)
    end
    return set
end

function Icons.Sprite(name)
    if not geistTried then
        geistTried = true
        geist = fetchGeist()
    end
    local entry = geist and geist.Icons[name]
    local sheet = entry and geist.Spritesheets and geist.Spritesheets[tostring(entry.Image)]
    if sheet then
        return { Image = sheet, ImageRectOffset = entry.ImageRectPosition, ImageRectSize = entry.ImageRectSize }
    end
    return BUILTIN_SPRITES[name]
end

function Icons.Resolve(spec)
    spec = tostring(spec or "")
    local family, name = spec:match("^(%w+):(.+)$")
    if family == "geist" then return Icons.Sprite(name) end
    name = name or spec
    local set = Icons.Load()
    local id = set and set[name]
    if type(id) == "string" then return { Image = id } end
    return nil
end

return Icons
end

__modules["features/Discord"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")

local Http = Services.HttpService

local Discord = {}

Discord.CODE   = "riftware"
Discord.INVITE = "https://discord.gg/riftware"

local API = "https://discord.com/api/v10/invites/riftware?with_counts=true"

local function commafy(n)
    local s = tostring(math.floor(tonumber(n) or 0))
    local out
    repeat
        out = s
        s = s:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
    until s == out
    return s
end

local function requester()
    return (syn and syn.request) or (http and http.request) or http_request or request
        or (fluxus and fluxus.request)
end

function Discord.Copy()
    local copy = setclipboard or toclipboard or (Clipboard and Clipboard.set)
    if not copy then return false end
    return (pcall(copy, Discord.INVITE))
end

local function openInApp()
    local send = requester()
    if not send then return false end
    local ok, res = pcall(send, {
        Url = "http://127.0.0.1:6463/rpc?v=1",
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json", ["Origin"] = "https://discord.com" },
        Body = Http:JSONEncode({
            cmd = "INVITE_BROWSER",
            args = { code = Discord.CODE },
            nonce = Http:GenerateGUID(false),
        }),
    })
    return ok and type(res) == "table" and (res.StatusCode == 200 or res.Success == true)
end

function Discord.Join()
    local copied = Discord.Copy()
    local opened = openInApp()
    if opened then
        Util.Notify("Discord", "Opened the invite in Discord." .. (copied and " Link copied too." or ""))
    elseif copied then
        Util.Notify("Discord", "Invite copied -- paste it in Discord or your browser.")
    else
        Util.Notify("Discord", Discord.INVITE)
    end
    return opened, copied
end

function Discord.Fetch()
    local body
    local ok = pcall(function() body = game:HttpGet(API, true) end)
    if not ok or type(body) ~= "string" then
        local send = requester()
        if send then
            local ok2, res = pcall(send, { Url = API, Method = "GET" })
            if ok2 and type(res) == "table" then body = res.Body end
        end
    end
    if type(body) ~= "string" or body == "" then return nil end
    local ok3, data = pcall(function() return Http:JSONDecode(body) end)
    if not ok3 or type(data) ~= "table" then return nil end
    local guild = type(data.guild) == "table" and data.guild or {}
    return {
        name = guild.name or "Riftware",
        online = tonumber(data.approximate_presence_count),
        members = tonumber(data.approximate_member_count),
    }
end

function Discord.Desc(info)
    local lines = { "You've been invited to join" }
    if info and info.online and info.members then
        table.insert(lines, ("\u{1F7E2} %s Online     \u{26AB} %s Members")
            :format(commafy(info.online), commafy(info.members)))
    else
        table.insert(lines, "discord.gg/" .. Discord.CODE)
    end
    table.insert(lines, "Updates, new scripts and support drop here first.")
    return table.concat(lines, "\n")
end

function Discord.Card(tab, image)
    local ok, card = pcall(function()
        return tab:Paragraph({
            Title = "Riftware",
            Desc = Discord.Desc(nil),
            Image = image,
            ImageSize = 44,
            Buttons = {
                { Title = "Join Server", Icon = "log-in", Callback = function() task.spawn(Discord.Join) end },
                { Title = "Copy Invite", Icon = "copy", Callback = function()
                    Util.Notify("Discord", Discord.Copy() and "Invite copied." or Discord.INVITE)
                end },
            },
        })
    end)
    if not ok or not card then return nil end

    task.spawn(function()
        local info = Discord.Fetch()
        if not info then return end
        pcall(function() card:SetTitle(info.name) end)
        pcall(function() card:SetDesc(Discord.Desc(info)) end)
    end)
    return card
end

return Discord
end

__modules["features/Config"] = function(import)

local Services = import("core/Services")
local Util     = import("core/Util")
local State    = import("core/State")

local HttpService = Services.HttpService

local Config = {}

local FOLDER = "Riftware"
local DIR    = FOLDER .. "/configs"
local AUTO   = FOLDER .. "/autoload.txt"

Config.Apply = nil

local SKIP = {
    Emote = true,
    FlingTarget = true,
    BoxId = true,
    BoxCurrency = true,
    AutoSalvage = true,
    ThrowTarget = true,
}

local function available()
    return writefile and readfile and isfile and makefolder and isfolder
end

Config.Available = available

local function ensureFolders()
    if not available() then return false end
    pcall(function()
        if not isfolder(FOLDER) then makefolder(FOLDER) end
        if not isfolder(DIR) then makefolder(DIR) end
    end)
    return true
end

local function path(name)
    return DIR .. "/" .. tostring(name) .. ".json"
end

function Config.Save(name)
    if not available() then return false, "executor has no file functions" end
    if type(name) ~= "string" or name:gsub("%s", "") == "" then
        return false, "give the config a name first"
    end

    ensureFolders()

    local snapshot = {}
    for key, value in pairs(State) do
        local kind = type(value)
        if not SKIP[key] and (kind == "boolean" or kind == "number" or kind == "string") then
            snapshot[key] = value
        end
    end

    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(snapshot)
    end)
    if not ok then return false, "encode failed" end

    local written = pcall(function() writefile(path(name), encoded) end)
    if not written then return false, "could not write the file" end

    return true
end

function Config.Load(name)
    if not available() then return false, "executor has no file functions" end
    if not name then return false, "no config selected" end

    local file = path(name)
    if not isfile(file) then return false, "no config called '" .. tostring(name) .. "'" end

    local ok, decoded = pcall(function()
        return HttpService:JSONDecode(readfile(file))
    end)
    if not ok or type(decoded) ~= "table" then return false, "that file isn't valid JSON" end

    for key, value in pairs(decoded) do

        if State[key] ~= nil or SKIP[key] == nil then
            if type(value) == type(State[key]) or State[key] == nil then
                State[key] = value
            end
        end
    end

    if Config.Apply then
        local applied = pcall(Config.Apply)
        if not applied then return true, "loaded, but some toggles failed to re-apply" end
    end

    return true
end

function Config.Delete(name)
    if not available() or not delfile then return false, "executor has no delfile" end
    local file = path(name)
    if not isfile(file) then return false, "no such config" end
    local ok = pcall(function() delfile(file) end)
    return ok
end

function Config.List()
    if not available() or not listfiles then return {} end

    ensureFolders()

    local names = {}
    local ok, files = pcall(function() return listfiles(DIR) end)
    if not ok or type(files) ~= "table" then return names end

    for _, file in ipairs(files) do
        local name = tostring(file):match("([^/\\]+)%.json$")
        if name then table.insert(names, name) end
    end

    table.sort(names)
    return names
end

function Config.SetAutoload(name)
    if not available() then return false end
    ensureFolders()
    if name then
        pcall(function() writefile(AUTO, tostring(name)) end)
    elseif delfile then
        pcall(function() if isfile(AUTO) then delfile(AUTO) end end)
    end
    return true
end

function Config.GetAutoload()
    if not available() then return nil end
    local ok, name = pcall(function()
        if isfile(AUTO) then return readfile(AUTO) end
        return nil
    end)
    if ok and type(name) == "string" and name ~= "" then return name end
    return nil
end

function Config.RunAutoload()
    local name = Config.GetAutoload()
    if not name then return end

    local ok, err = Config.Load(name)
    if ok then
        Util.Notify("Config", "Loaded '" .. name .. "' automatically.")
    else
        Util.Notify("Config", "Autoload failed: " .. tostring(err))
    end
end

return Config
end

__modules["ui/Style"] = function(import)

return "WindUI"
end

__modules["ui/Toast"] = function(import)

local Icons = import("features/Icons")

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Toast = {}

Toast.Spooky = true
Toast.Accent = Color3.fromRGB(225, 228, 236)
Toast.Max = 5

local PUMPKIN = Color3.fromRGB(255, 122, 26)
local POTION  = Color3.fromRGB(139, 61, 255)
local TEXT    = Color3.fromRGB(245, 245, 248)
local SUB     = Color3.fromRGB(170, 164, 178)

local function palette()
    if Toast.Spooky then
        return { card = Color3.fromRGB(19, 12, 24), tile = Color3.fromRGB(42, 24, 52), track = Color3.fromRGB(64, 42, 74),
                 accent = PUMPKIN, second = POTION }
    end
    return { card = Color3.fromRGB(16, 16, 21), tile = Color3.fromRGB(36, 33, 48), track = Color3.fromRGB(58, 56, 70),
             accent = Toast.Accent }
end

local function halloween(parent, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, PUMPKIN), ColorSequenceKeypoint.new(1, POTION) })
    g.Rotation = rotation or 0
    g.Parent = parent
    return g
end

local host, phone

local function tween(inst, props, t, style, dir)
    pcall(function()
        TweenService:Create(inst, TweenInfo.new(t or 0.25, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props):Play()
    end)
end

local function new(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then inst[k] = v end
    end
    for _, c in ipairs(children or {}) do c.Parent = inst end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end

local function corner(r) return new("UICorner", { CornerRadius = UDim.new(0, r) }) end

local function guiParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and cg then return cg end
    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function viewport()
    local cam = workspace.CurrentCamera
    local v = cam and cam.ViewportSize
    if typeof(v) == "Vector2" and v.X > 0 then return v end
    return Vector2.new(1280, 720)
end

local function ensureHost()
    if host and host.Parent and host.Parent.Parent then return host end
    local vp = viewport()
    phone = vp.Y < 560 or vp.X < 760
    local inset = 0
    pcall(function() inset = game:GetService("GuiService"):GetGuiInset().Y end)
    local gui = new("ScreenGui", { Name = "RiftwareToasts", ResetOnSpawn = false, IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 120 })
    gui.Parent = guiParent()
    host = new("Frame", { Name = "Toasts", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, phone and 0 or 1),
        Position = phone and UDim2.new(1, -10, 0, inset + 8) or UDim2.new(1, -20, 1, -20),
        Size = UDim2.new(0, phone and 300 or 380, 1, -40), Parent = gui },
        { new("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = phone and Enum.VerticalAlignment.Top or Enum.VerticalAlignment.Bottom }) })
    return host
end

local order = 0

function Toast.Show(cfg)
    cfg = cfg or {}
    local parent = ensureHost()
    local duration = tonumber(cfg.Duration) or 4
    local width = phone and 300 or 380
    local tile = phone and 40 or 48
    local pal = palette()
    local accent = pal.accent

    local live = {}
    for _, c in ipairs(parent:GetChildren()) do
        if c.Name == "Toast" then table.insert(live, c) end
    end
    if #live >= Toast.Max then
        table.sort(live, function(a, b) return a.LayoutOrder < b.LayoutOrder end)
        pcall(function() live[1]:Destroy() end)
    end

    order = order + 1
    local wrap = new("Frame", { Name = "Toast", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = order, Parent = parent })
    local card = new("Frame", { Name = "Card", BackgroundColor3 = pal.card, BackgroundTransparency = 0.04,
        Position = UDim2.fromOffset(width + 40, 0), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        Parent = wrap }, { corner(phone and 16 or 18) })
    local outline = new("UIStroke", { Color = pal.second and Color3.new(1, 1, 1) or accent, Transparency = 0.3, Thickness = 1.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = card })
    if pal.second then halloween(outline, 0) end
    new("UIGradient", { Rotation = 90, Parent = card, Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)), ColorSequenceKeypoint.new(1, Color3.fromRGB(190, 190, 200)) }) })

    local content = new("Frame", { Name = "Content", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y, Parent = card },
        { new("UIPadding", { PaddingLeft = UDim.new(0, phone and 12 or 14), PaddingRight = UDim.new(0, phone and 12 or 16),
            PaddingTop = UDim.new(0, phone and 12 or 14), PaddingBottom = UDim.new(0, phone and 12 or 14) }),
          new("UIListLayout", { Padding = UDim.new(0, phone and 10 or 12), SortOrder = Enum.SortOrder.LayoutOrder }) })

    local row = new("Frame", { Name = "Row", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1, Parent = content },
        { new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, phone and 12 or 14),
            VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder }) })

    local iconTile = new("Frame", { Name = "Icon", BackgroundColor3 = pal.tile, BackgroundTransparency = 0.05,
        Size = UDim2.fromOffset(tile, tile), LayoutOrder = 1, Parent = row }, { corner(phone and 10 or 12) })
    new("UIStroke", { Color = accent, Transparency = 0.6, Thickness = 1, Parent = iconTile })
    new("ImageLabel", { Name = "Glyph", BackgroundTransparency = 1, Image = Icons.Get(cfg.Icon or "info"), ImageColor3 = accent,
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(tile * 0.46, tile * 0.46),
        Parent = iconTile })

    local text = new("Frame", { Name = "Text", BackgroundTransparency = 1, Size = UDim2.new(1, -(tile + 44), 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Parent = row },
        { new("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }) })
    new("TextLabel", { Name = "Title", BackgroundTransparency = 1, Text = tostring(cfg.Title or "Riftware"),
        Font = Enum.Font.GothamBold, TextSize = phone and 15 or 18, TextColor3 = TEXT, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.new(1, 0, 0, phone and 18 or 22), LayoutOrder = 1, Parent = text })
    new("TextLabel", { Name = "Body", BackgroundTransparency = 1, Text = tostring(cfg.Content or ""),
        Font = Enum.Font.GothamMedium, TextSize = phone and 12 or 14, TextColor3 = SUB, TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Parent = text })

    local track = new("Frame", { Name = "Timer", BackgroundColor3 = pal.track, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 4),
        LayoutOrder = 2, Parent = content }, { corner(2) })
    local fill = new("Frame", { Name = "Fill", BackgroundColor3 = pal.second and Color3.new(1, 1, 1) or accent, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0), Parent = track }, { corner(2) })
    if pal.second then halloween(fill, 0) end

    local close = new("TextButton", { Name = "Close", Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 8), Size = UDim2.fromOffset(28, 28), ZIndex = 3, Parent = card })
    local x = new("ImageLabel", { BackgroundTransparency = 1, Image = Icons.Get("x"), ImageColor3 = SUB, ZIndex = 3,
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(16, 16), Parent = close })

    local gone = false
    local function dismiss()
        if gone then return end
        gone = true
        tween(card, { Position = UDim2.fromOffset(width + 40, 0) }, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.delay(0.32, function() pcall(function() wrap:Destroy() end) end)
    end
    close.Activated:Connect(dismiss)
    pcall(function()
        close.MouseEnter:Connect(function() tween(x, { ImageColor3 = TEXT }, 0.15) end)
        close.MouseLeave:Connect(function() tween(x, { ImageColor3 = SUB }, 0.15) end)
    end)

    tween(card, { Position = UDim2.fromOffset(0, 0) }, 0.45, Enum.EasingStyle.Back)
    tween(fill, { Size = UDim2.new(0, 0, 1, 0) }, duration, Enum.EasingStyle.Linear)
    task.delay(duration, dismiss)
    return wrap, dismiss
end

function Toast.Host()
    return host
end

function Toast.Destroy()
    if host and host.Parent then pcall(function() host.Parent:Destroy() end) end
    host = nil
end

return Toast
end

__modules["ui/Main"] = function(import)

local Services  = import("core/Services")
local Util      = import("core/Util")
local State     = import("core/State")
local Roles     = import("core/Roles")
local Weapons   = import("core/Weapons")
local SilentAim = import("features/SilentAim")
local KnifeSpeed = import("features/KnifeSpeed")
local Melee     = import("features/Melee")
local Guns      = import("features/Guns")
local ESP       = import("features/ESP")
local Visuals   = import("features/Visuals")
local XRay      = import("features/XRay")
local TrapESP   = import("features/TrapESP")
local Dodge     = import("features/Dodge")
local BulletDodge = import("features/BulletDodge")
local KnifeTrail  = import("features/KnifeTrail")
local AntiStab  = import("features/AntiStab")
local Counter   = import("features/Counter")
local Perf      = import("features/Perf")
local Fling     = import("features/Fling")
local Hitbox    = import("features/Hitbox")
local AntiFling = import("features/AntiFling")
local Boxes     = import("features/Boxes")
local Farm      = import("features/Farm")
local Char      = import("features/Character")
local Emotes    = import("features/Emotes")
local SpawnerGui = import("features/SpawnerGui")
local Spawner   = import("features/Spawner")
local SpawnerCards = import("features/SpawnerCards")
local Toast        = import("ui/Toast")
local SpawnFx   = import("features/SpawnFx")
local Perks     = import("features/Perks")
local BombJump  = import("features/BombJump")
local Crafting  = import("features/Crafting")
local Keybinds  = import("features/Keybinds")
local Halloween = import("features/Halloween")
local Alarm     = import("features/Alarm")
local WallHop   = import("features/WallHop")
local SkinTags  = import("features/SkinTags")
local Session   = import("features/Session")
local FarmStats = import("features/FarmStats")
local RoundLog  = import("features/RoundLog")
local Discord   = import("features/Discord")
local AntiTrap  = import("features/AntiTrap")
local FakeGun   = import("features/FakeGun")
local DualWield = import("features/DualWield")
local Assassin  = import("features/Assassin")
local ShotTrace = import("features/ShotTrace")
local Crosshair = import("features/Crosshair")
local Buttons   = import("features/Buttons")
local Icons     = import("features/Icons")
local Config    = import("features/Config")

local Players = Services.Players

local UI = {}

local WINDUI_SOURCES = {
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
}

local function guiParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and cg then return cg end
    return Services.LocalPlayer:WaitForChild("PlayerGui")
end

local function showFatal(message)
    warn("[Riftware] " .. tostring(message))

    pcall(function()
        local gui = Instance.new("ScreenGui")
        gui.Name = "RiftwareError"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 10000
        gui.Parent = guiParent()

        local frame = Instance.new("Frame")
        frame.AnchorPoint = Vector2.new(0.5, 0.5)
        frame.Position = UDim2.new(0.5, 0, 0.5, 0)
        frame.Size = UDim2.new(0, 460, 0, 190)
        frame.BackgroundColor3 = Color3.fromRGB(11, 11, 13)
        frame.BorderSizePixel = 0
        frame.Parent = gui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = frame

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(235, 80, 90)
        stroke.Thickness = 1
        stroke.Parent = frame

        local title = Instance.new("TextLabel")
        title.BackgroundTransparency = 1
        title.Position = UDim2.new(0, 14, 0, 10)
        title.Size = UDim2.new(1, -28, 0, 22)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 15
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextColor3 = Color3.fromRGB(235, 80, 90)
        title.Text = "Riftware failed to start"
        title.Parent = frame

        local body = Instance.new("TextLabel")
        body.BackgroundTransparency = 1
        body.Position = UDim2.new(0, 14, 0, 36)
        body.Size = UDim2.new(1, -28, 1, -84)
        body.Font = Enum.Font.Code
        body.TextSize = 12
        body.TextWrapped = true
        body.TextXAlignment = Enum.TextXAlignment.Left
        body.TextYAlignment = Enum.TextYAlignment.Top
        body.TextColor3 = Color3.fromRGB(225, 225, 232)
        body.Text = tostring(message)
        body.Parent = frame

        local close = Instance.new("TextButton")
        close.AnchorPoint = Vector2.new(0.5, 1)
        close.Position = UDim2.new(0.5, 0, 1, -12)
        close.Size = UDim2.new(0, 120, 0, 28)
        close.BackgroundColor3 = Color3.fromRGB(34, 36, 42)
        close.BorderSizePixel = 0
        close.Font = Enum.Font.GothamBold
        close.TextSize = 13
        close.TextColor3 = Color3.fromRGB(235, 235, 240)
        close.Text = "Dismiss"
        close.Parent = frame

        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 6)
        closeCorner.Parent = close

        close.MouseButton1Click:Connect(function() gui:Destroy() end)
    end)
end

UI.ShowFatal = showFatal

local function httpGet(url)
    local ok, body = pcall(function() return game:HttpGet(url) end)
    if ok and type(body) == "string" and #body > 1000 then return body end

    local send = (syn and syn.request) or (http and http.request) or http_request or request
    if send then
        local ok2, res = pcall(send, { Url = url, Method = "GET" })
        if ok2 and type(res) == "table" and type(res.Body) == "string" and #res.Body > 1000 then
            return res.Body
        end
    end

    return nil, (ok and "empty response" or tostring(body))
end

local CACHE_DIR  = "Riftware"
local CACHE_FILE = CACHE_DIR .. "/windui.lua"

local function cacheRead()
    if not (isfile and readfile) then return nil end
    local ok, body = pcall(function()
        if isfile(CACHE_FILE) then return readfile(CACHE_FILE) end
        return nil
    end)
    if ok and type(body) == "string" and #body > 1000 then return body end
    return nil
end

local function cacheWrite(body)
    if not (writefile and makefolder) then return end
    pcall(function()
        if isfolder and not isfolder(CACHE_DIR) then makefolder(CACHE_DIR) end
        writefile(CACHE_FILE, body)
    end)
end

local function build(body)
    local chunk, compileErr = loadstring(body)
    if not chunk then return nil, "compile: " .. tostring(compileErr) end
    local ok, lib = pcall(chunk)
    if ok and type(lib) == "table" then return lib end
    return nil, "ran but errored: " .. tostring(lib)
end

local function loadWindUI()

    local cached = cacheRead()
    if cached then
        local lib = build(cached)
        if lib then return lib, "cache" end

    end

    local failures = {}

    for _, url in ipairs(WINDUI_SOURCES) do
        local body, err = httpGet(url)
        if body then
            local lib, buildErr = build(body)
            if lib then
                cacheWrite(body)
                return lib, "network"
            end
            table.insert(failures, url .. "\n   " .. tostring(buildErr))
        else
            table.insert(failures, url .. "\n   fetch: " .. tostring(err))
        end
    end

    return nil, table.concat(failures, "\n")
end

function UI.ClearCache()
    if not delfile then return false, "executor has no delfile" end
    local ok = pcall(function()
        if isfile and isfile(CACHE_FILE) then delfile(CACHE_FILE) end
    end)
    return ok
end

local function showSplash()
    local TweenService = Services.TweenService
    local ctl = { target = 0.04, shown = 0, stageMax = 0.4 }
    local gui, card, fill, shine, status, percent, scale

    local GLINT  = Color3.fromRGB(248, 250, 255)
    local CHROME = Color3.fromRGB(226, 231, 240)
    local STEEL  = Color3.fromRGB(150, 158, 172)
    local SMOKE  = Color3.fromRGB(92, 98, 110)

    local function tween(inst, props, time)
        pcall(function()
            TweenService:Create(inst, TweenInfo.new(time or 0.3, Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out), props):Play()
        end)
    end

    local function chrome(parent, rotation)
        local g = Instance.new("UIGradient")
        g.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, GLINT),
            ColorSequenceKeypoint.new(0.45, Color3.fromRGB(170, 178, 192)),
            ColorSequenceKeypoint.new(0.7, CHROME),
            ColorSequenceKeypoint.new(1, STEEL),
        })
        g.Rotation = rotation or 90
        g.Parent = parent
        return g
    end

    local function round(parent, radius)
        local c = Instance.new("UICorner")
        c.CornerRadius = radius
        c.Parent = parent
    end

    local ok = pcall(function()
        gui = Instance.new("ScreenGui")
        gui.Name = "RiftwareLoading"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 9999
        gui.Parent = guiParent()

        card = Instance.new("CanvasGroup")
        card.AnchorPoint = Vector2.new(0.5, 0.5)
        card.Position = UDim2.new(0.5, 0, 0.5, 12)
        card.Size = UDim2.new(0, 340, 0, 168)
        card.BackgroundColor3 = Color3.fromRGB(11, 12, 15)
        card.BackgroundTransparency = 0.04
        card.BorderSizePixel = 0
        card.GroupTransparency = 1
        card.Parent = gui
        round(card, UDim.new(0, 18))
        local edge = Instance.new("UIStroke")
        edge.Color = GLINT
        edge.Thickness = 1
        edge.Transparency = 0.2
        edge.Parent = card
        local edgeGrad = Instance.new("UIGradient")
        edgeGrad.Rotation = 90
        edgeGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 0.9),
        })
        edgeGrad.Parent = edge

        scale = Instance.new("UIScale")
        scale.Parent = card
        pcall(function()
            local vp = workspace.CurrentCamera.ViewportSize
            scale.Scale = math.clamp(math.min(vp.X / 400, vp.Y / 260), 0.7, 1.15)
        end)

        local sheen = Instance.new("Frame")
        sheen.Size = UDim2.new(1, 0, 0, 70)
        sheen.BackgroundColor3 = GLINT
        sheen.BackgroundTransparency = 0.93
        sheen.BorderSizePixel = 0
        sheen.Parent = card
        local sheenGrad = Instance.new("UIGradient")
        sheenGrad.Rotation = 90
        sheenGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1),
        })
        sheenGrad.Parent = sheen

        local halo = Instance.new("Frame")
        halo.Size = UDim2.new(0, 72, 0, 72)
        halo.Position = UDim2.new(0, 20, 0, 20)
        halo.BackgroundColor3 = GLINT
        halo.BackgroundTransparency = 0.9
        halo.BorderSizePixel = 0
        halo.Parent = card
        round(halo, UDim.new(0.3, 0))

        local logo = Instance.new("ImageLabel")
        logo.Size = UDim2.new(0, 64, 0, 64)
        logo.Position = UDim2.new(0, 24, 0, 24)
        logo.BackgroundColor3 = Color3.fromRGB(6, 6, 8)
        logo.Image = Services.LogoImage
        logo.ScaleType = Enum.ScaleType.Crop
        logo.Parent = card
        round(logo, UDim.new(0.28, 0))
        local logoEdge = Instance.new("UIStroke")
        logoEdge.Color = Color3.fromRGB(70, 75, 88)
        logoEdge.Parent = logo

        local title = Instance.new("TextLabel")
        title.BackgroundTransparency = 1
        title.Position = UDim2.new(0, 104, 0, 28)
        title.Size = UDim2.new(1, -120, 0, 30)
        title.Font = Enum.Font.GothamBlack
        title.TextSize = 28
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextColor3 = Color3.new(1, 1, 1)
        title.Text = "RIFTWARE"
        title.Parent = card
        chrome(title, 90)

        local sub = Instance.new("TextLabel")
        sub.BackgroundTransparency = 1
        sub.Position = UDim2.new(0, 105, 0, 60)
        sub.Size = UDim2.new(1, -120, 0, 16)
        sub.Font = Enum.Font.GothamMedium
        sub.TextSize = 12
        sub.TextXAlignment = Enum.TextXAlignment.Left
        sub.TextColor3 = STEEL
        sub.Text = "Murder Mystery 2"
        sub.Parent = card

        local track = Instance.new("Frame")
        track.Position = UDim2.new(0, 22, 0, 116)
        track.Size = UDim2.new(1, -44, 0, 6)
        track.BackgroundColor3 = Color3.fromRGB(28, 30, 36)
        track.BorderSizePixel = 0
        track.ClipsDescendants = true
        track.Parent = card
        round(track, UDim.new(1, 0))

        fill = Instance.new("Frame")
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = Color3.new(1, 1, 1)
        fill.BorderSizePixel = 0
        fill.ClipsDescendants = true
        fill.Parent = track
        round(fill, UDim.new(1, 0))
        chrome(fill, 0)

        shine = Instance.new("Frame")
        shine.Size = UDim2.new(0, 60, 1, 0)
        shine.BackgroundColor3 = Color3.new(1, 1, 1)
        shine.BorderSizePixel = 0
        shine.Parent = fill
        local shineGrad = Instance.new("UIGradient")
        shineGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0.25),
            NumberSequenceKeypoint.new(1, 1),
        })
        shineGrad.Parent = shine

        status = Instance.new("TextLabel")
        status.BackgroundTransparency = 1
        status.Position = UDim2.new(0, 22, 0, 132)
        status.Size = UDim2.new(1, -90, 0, 16)
        status.Font = Enum.Font.GothamMedium
        status.TextSize = 11
        status.TextXAlignment = Enum.TextXAlignment.Left
        status.TextColor3 = SMOKE:Lerp(CHROME, 0.5)
        status.Text = "Starting up"
        status.Parent = card

        percent = Instance.new("TextLabel")
        percent.BackgroundTransparency = 1
        percent.AnchorPoint = Vector2.new(1, 0)
        percent.Position = UDim2.new(1, -22, 0, 132)
        percent.Size = UDim2.new(0, 60, 0, 16)
        percent.Font = Enum.Font.GothamBold
        percent.TextSize = 11
        percent.TextXAlignment = Enum.TextXAlignment.Right
        percent.TextColor3 = CHROME
        percent.Text = "0%"
        percent.Parent = card

        tween(card, { GroupTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0) }, 0.45)
    end)
    if not ok then return nil end

    ctl.gui = gui
    ctl.fill = fill

    local conn
    pcall(function()
        conn = Services.RunService.Heartbeat:Connect(function(dt)
            dt = tonumber(dt) or 0.016
            if ctl.target < ctl.stageMax then
                ctl.target = math.min(ctl.stageMax, ctl.target + dt * 0.04)
            end
            ctl.shown = ctl.shown + (ctl.target - ctl.shown) * math.min(1, dt * 8)
            fill.Size = UDim2.new(ctl.shown, 0, 1, 0)
            percent.Text = ("%d%%"):format(math.floor(ctl.shown * 100 + 0.5))
            local w = math.max(1, fill.AbsoluteSize and fill.AbsoluteSize.X or 1)
            local x = (os.clock() * 220) % (w + 120) - 60
            shine.Position = UDim2.new(0, x, 0, 0)
        end)
    end)

    function ctl:Set(progress, text, ceiling)
        self.target = math.max(self.target, progress)
        self.stageMax = math.max(self.target, ceiling or progress)
        if text and status then status.Text = text end
    end

    function ctl:Destroy()
        if conn then pcall(function() conn:Disconnect() end) end
        pcall(function() gui:Destroy() end)
    end

    function ctl:Finish()
        self:Set(1, "Ready", 1)
        self.shown = 1
        pcall(function()
            fill.Size = UDim2.new(1, 0, 1, 0)
            percent.Text = "100%"
        end)
        task.delay(0.35, function()
            tween(card, { GroupTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, -10) }, 0.35)
            task.delay(0.4, function() self:Destroy() end)
        end)
    end

    ctl:Set(0.06, "Loading interface library", 0.45)
    return ctl
end

function UI.Start()
    local ok, result = pcall(UI.Build)
    if not ok then
        showFatal(result)
        return nil
    end
    return result
end

function UI.Build()
    local splash = showSplash()

    local WindUI, source
    if import("ui/Style") == "Cards" then
        WindUI, source = import("ui/Cards"), "builtin"
    else
        WindUI, source = loadWindUI()
    end

    if not WindUI then
        if splash then pcall(function() splash:Destroy() end) end
        error("Could not load WindUI from any source.\n" .. tostring(source), 0)
    end

    UI.LoadedFrom = source

    if splash then
        splash:Set(0.55, "Building interface", 0.9)
        task.wait()
    end

    Toast.Spooky = State.UITheme ~= "Classic"
    Util.Notify = function(title, content)
        pcall(Toast.Show, { Title = title, Content = content, Duration = 4 })
    end

    local HALLOWEEN_THEME = "Riftware Halloween"
    pcall(function()
        WindUI:AddTheme({
            Name = HALLOWEEN_THEME,
            Accent = Color3.fromHex("#1b0f22"),
            Dialog = Color3.fromHex("#1d1124"),
            Outline = Color3.fromHex("#ffb066"),
            Text = Color3.fromHex("#fff3e6"),
            Placeholder = Color3.fromHex("#b59ab0"),
            Background = Color3.fromHex("#0d0711"),
            Button = Color3.fromHex("#5b2a86"),
            Icon = Color3.fromHex("#ff9a3c"),
            Toggle = Color3.fromHex("#ff7a1a"),
            Slider = Color3.fromHex("#ff7a1a"),
            Checkbox = Color3.fromHex("#ff7a1a"),
            Primary = Color3.fromHex("#ff7a1a"),
            SliderIcon = Color3.fromHex("#c79bd8"),
            PanelBackground = Color3.fromHex("#ffffff"),
            PanelBackgroundTransparency = 0.95,
            LabelBackground = Color3.fromHex("#000000"),
            LabelBackgroundTransparency = 0.83,
            ElementBackground = Color3.fromHex("#22142a"),
            ElementBackgroundTransparency = 0,
        })
    end)
    local spooky = State.UITheme ~= "Classic"

    local Window = WindUI:CreateWindow({
        Title = "Riftware",
        Icon = "swords",
        Author = "NEVERLOSE",
        Folder = "Riftware",
        Size = UDim2.fromOffset(620, 540),
        Theme = spooky and HALLOWEEN_THEME or "Dark",
        Transparent = true,
        Background = Services.LogoImage,
        Acrylic = true,
        ToggleKey = (function()
            local ok, code = pcall(function() return Enum.KeyCode[Keybinds.MenuKey()] end)
            return (ok and code) or Enum.KeyCode.RightShift
        end)(),
    })

    pcall(function()
        Window:EditOpenButton({
            Title = "Riftware",
            Icon = Services.LogoImage,
            CornerRadius = UDim.new(1, 0),
            StrokeThickness = 2,
            Color = spooky and ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 154, 60)),
                ColorSequenceKeypoint.new(0.35, Color3.fromRGB(91, 42, 134)),
                ColorSequenceKeypoint.new(0.65, Color3.fromRGB(255, 122, 26)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 22, 84)),
            }) or ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(248, 250, 255)),
                ColorSequenceKeypoint.new(0.35, Color3.fromRGB(92, 98, 110)),
                ColorSequenceKeypoint.new(0.65, Color3.fromRGB(226, 231, 240)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(118, 126, 140)),
            }),
            OnlyMobile = false,
            Enabled = true,
            Draggable = true,
        })
    end)

    local TAG_GRAY = Color3.fromRGB(72, 78, 90)
    local TAGS = {
        { title = "discord.gg/riftware", icons = { "geist:logo-discord", "message-circle" },
          color = TAG_GRAY, link = Discord.INVITE, copied = "Discord invite copied." },
        { title = "@riftwarewtf", icons = { "lucide:youtube", "youtube", "play" },
          color = TAG_GRAY, link = "https://youtube.com/@riftwarewtf", copied = "YouTube link copied." },
        { title = (import("ui/Style") == "Cards" and "v2" or "v1.2") .. "  -  Mobile & PC", color = Color3.fromRGB(26, 28, 33) },
    }
    pcall(function()
        for _, t in ipairs(TAGS) do
            local made = false
            if import("ui/Style") == "Cards" and t.icons then

                made = pcall(function() Window:Tag({ Title = t.title, Icon = t.icons, Color = t.color, Radius = 6 }) end)
            end
            for _, icon in ipairs(made and {} or t.icons or {}) do
                made = pcall(function() Window:Tag({ Title = t.title, Icon = icon, Color = t.color, Radius = 6 }) end)
                if made then break end
            end
            if not made then
                pcall(function() Window:Tag({ Title = t.title, Color = t.color, Radius = 6 }) end)
            end
        end
    end)

    local function copyText(text)
        local copy = setclipboard or toclipboard or writeclipboard or (syn and syn.write_clipboard) or (Clipboard and Clipboard.set)
        return copy ~= nil and (pcall(copy, text))
    end

    local function windowLabel(text, chromeOnly)
        local main = Window and Window.UIElements and Window.UIElements.Main
        if not main then return nil end
        for _, d in ipairs(main:GetDescendants()) do
            if d:IsA("TextLabel") and d.Text == text and not (chromeOnly and d:FindFirstAncestorWhichIsA("ScrollingFrame")) then
                return d
            end
        end
        return nil
    end

    local function sweep(target, name, keys, period, delay)
        local g = Instance.new("UIGradient")
        g.Name = name
        g.Color = ColorSequence.new(keys)
        g.Offset = Vector2.new(-1, 0)
        g.Parent = target
        task.delay(delay or 0, function()
            pcall(function()
                Services.TweenService:Create(g,
                    TweenInfo.new(period, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
                    { Offset = Vector2.new(1, 0) }):Play()
            end)
        end)
        return g
    end

    local TAG_SHINE = {
        ColorSequenceKeypoint.new(0, Color3.fromRGB(178, 178, 178)),
        ColorSequenceKeypoint.new(0.4, Color3.fromRGB(205, 205, 205)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(205, 205, 205)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(178, 178, 178)),
    }

    local function decorateTags()
        for i, t in ipairs(TAGS) do
            local label = windowLabel(t.title)
            local tag = label and label.Parent and label.Parent.Parent
            if tag and tag:IsA("GuiObject") and not tag:FindFirstChild("RiftwareTagShine") then
                sweep(tag, "RiftwareTagShine", TAG_SHINE, 2.8, (i - 1) * 0.6)

                if t.link then
                    local hit = Instance.new("TextButton")
                    hit.Name = "RiftwareTagLink"
                    hit.BackgroundTransparency = 1
                    hit.Text = ""
                    hit.Size = UDim2.fromScale(1, 1)
                    hit.ZIndex = tag.ZIndex + 5
                    hit.Parent = tag
                    hit.Activated:Connect(function()
                        Util.Notify(t.title, copyText(t.link) and t.copied or t.link)
                    end)
                end
            end
        end
    end

    local function animateTitle()
        local title = windowLabel("Riftware", true)
        if not title or title:FindFirstChild("RiftwareTitleSweep") then return end
        sweep(title, "RiftwareTitleSweep", spooky and {
            ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 70, 200)),
            ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 122, 26)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 236, 200)),
            ColorSequenceKeypoint.new(0.7, Color3.fromRGB(255, 122, 26)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 70, 200)),
        } or {
            ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 128, 142)),
            ColorSequenceKeypoint.new(0.3, Color3.fromRGB(190, 197, 210)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.7, Color3.fromRGB(190, 197, 210)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 128, 142)),
        }, 2.4, 0)
    end

    task.delay(0.5, function()
        pcall(decorateTags)
        pcall(animateTitle)
    end)

    if not Window then
        error("WindUI returned no window. A previous hub is probably still open -- "
            .. "rejoin, or unload it first.", 0)
    end

    local toggleRefs = {}

    local function trackToggles(tab)
        local original = tab.Toggle
        if type(original) ~= "function" then return tab end
        tab.Toggle = function(self, cfg)
            local el = original(self, cfg)
            if type(cfg) == "table" and cfg.Title and not toggleRefs[cfg.Title] then
                toggleRefs[cfg.Title] = el
            end
            return el
        end
        return tab
    end

    local function makeTab(title, icon, color)
        local ok, tab = pcall(function()
            return Window:Tab({
                Title = title,
                Icon = icon,
                IconColor = color,
                IconShape = "Squircle",
            })
        end)
        if ok and tab then return trackToggles(tab) end
        return trackToggles(Window:Tab({ Title = title }))
    end

    local GLINT    = Color3.fromRGB(248, 250, 255)
    local CHROME   = Color3.fromRGB(226, 231, 240)
    local ICE      = Color3.fromRGB(198, 214, 238)
    local SILVER   = Color3.fromRGB(184, 190, 202)
    local STEEL    = Color3.fromRGB(150, 158, 172)
    local PEWTER   = Color3.fromRGB(170, 166, 158)
    local GRAPHITE = Color3.fromRGB(118, 126, 140)
    local SMOKE    = Color3.fromRGB(92, 98, 110)

    if spooky then
        GLINT    = Color3.fromRGB(255, 122, 26)
        CHROME   = Color3.fromRGB(255, 196, 61)
        ICE      = Color3.fromRGB(140, 230, 90)
        SILVER   = Color3.fromRGB(190, 120, 255)
        STEEL    = Color3.fromRGB(150, 90, 210)
        PEWTER   = Color3.fromRGB(235, 225, 205)
        GRAPHITE = Color3.fromRGB(220, 60, 60)
        SMOKE    = Color3.fromRGB(120, 80, 150)
    end

    pcall(SpawnFx.Load)

    local Combat = makeTab("Combat", "shield", GLINT)

    Discord.Card(Combat, Services.LogoImage)

    Combat:Section({ Title = "Prediction" })

    Combat:Toggle({
        Title = "Lead Prediction",
        Desc = "Horizontal lead for a moving target. Applies to the knife (over its "
            .. "flight time) and the gun (over your ping).",
        Value = true,
        Callback = function(v) State.LeadPrediction = v end,
    })

    Combat:Toggle({
        Title = "Jump Prediction",
        Desc = "Vertical lead with gravity, for targets in the air. A rising player is "
            .. "slowing down, so a flat lead aims above their head -- this fixes that. "
            .. "Knife and gun both.",
        Value = true,
        Callback = function(v) State.JumpPrediction = v end,
    })

    Combat:Slider({
        Title = "Lead Strength",
        Desc = "Scales the horizontal lead. Above 1 over-leads for high ping.",
        Value = { Min = 0, Max = 3, Default = 1 },
        Step = 0.1,
        Callback = function(v) State.PredictionMult = v end,
    })

    Combat:Slider({
        Title = "Jump Strength",
        Desc = "Scales the vertical correction.",
        Value = { Min = 0, Max = 3, Default = 1 },
        Step = 0.1,
        Callback = function(v) State.JumpPredictionMult = v end,
    })

    Combat:Dropdown({
        Title = "Aim Part",
        Values = { "HumanoidRootPart", "Head", "Torso", "UpperTorso" },
        Value = "HumanoidRootPart",
        Callback = function(v) State.AimPart = v end,
    })

    Combat:Slider({
        Title = "Prediction Scale",
        Desc = "Scales the ping lead. Raise it if shots land behind runners.",
        Value = { Min = 0.5, Max = 2, Default = 1 },
        Step = 0.05,
        Callback = function(v) State.SilentPredict = v end,
    })

    Combat:Section({ Title = "Silent Aim Tuning" })

    Combat:Toggle({
        Title = "Target Assassin Target",
        Desc = "Assassin mode: silent throws (and shots) always go to the target the game gave you.",
        Value = true,
        Callback = function(v) State.SilentAssassin = v end,
    })

    Combat:Toggle({
        Title = "Target Zombies",
        Desc = "Infection mode: as a survivor every shot goes to the closest zombie; as a zombie, the closest survivor.",
        Value = true,
        Callback = function(v) State.SilentZombies = v end,
    })

    Combat:Dropdown({
        Title = "Knife Target",
        Desc = "Who a throw goes to when the sheriff/hero isn't picked first.",
        Values = SilentAim.Modes,
        Value = "Closest to Crosshair",
        Callback = function(v) State.SilentMode = v end,
    })

    Combat:Slider({
        Title = "FOV (degrees)",
        Desc = "Only lock on inside this cone around where you look. 0 = anywhere.",
        Value = { Min = 0, Max = 180, Default = 0 },
        Step = 5,
        Callback = function(v) State.SilentFov = v end,
    })

    Combat:Slider({
        Title = "Max Range (studs)",
        Value = { Min = 25, Max = 295, Default = 295 },
        Step = 5,
        Callback = function(v) State.SilentMaxRange = v end,
    })

    Combat:Toggle({
        Title = "Wall Check",
        Desc = "Don't redirect when every part of them is behind cover. Glass doesn't count.",
        Value = false,
        Callback = function(v) State.SilentWallCheck = v end,
    })

    Combat:Slider({
        Title = "Hit Chance (%)",
        Desc = "Below 100 lets some shots miss on purpose, so it looks human.",
        Value = { Min = 0, Max = 100, Default = 100 },
        Step = 5,
        Callback = function(v) State.SilentChance = v end,
    })

    Combat:Slider({
        Title = "Jitter (studs)",
        Desc = "Random spread on each redirected shot.",
        Value = { Min = 0, Max = 3, Default = 0 },
        Step = 0.1,
        Callback = function(v) State.SilentJitter = v end,
    })

    Combat:Button({
        Title = "Silent Aim Status",
        Desc = "What the last shot did, your ping, lead and knife speed.",
        Callback = function() Util.Notify("Silent Aim", SilentAim.Report()) end,
    })

    Combat:Section({ Title = "Auto Dodge" })

    Combat:Toggle({
        Title = "Auto Dodge Knives",
        Value = false,
        Callback = function(v) Dodge.Set(v) end,
    })

    Combat:Slider({
        Title = "Dodge Radius",
        Desc = "How close the knife has to pass before it counts as a threat.",
        Value = { Min = 2, Max = 20, Default = 6 },
        Step = 1,
        Callback = function(v) State.DodgeRadius = v end,
    })

    Combat:Slider({
        Title = "React Within (s)",
        Desc = "Only dodges knives arriving this soon. Higher reacts earlier.",
        Value = { Min = 0.1, Max = 2, Default = 0.6 },
        Step = 0.1,
        Callback = function(v) State.DodgeWarning = v end,
    })

    Combat:Slider({
        Title = "Sidestep Distance",
        Value = { Min = 3, Max = 25, Default = 7 },
        Step = 1,
        Callback = function(v) State.DodgeDistance = v end,
    })

    Combat:Toggle({
        Title = "Notify On Dodge",
        Value = false,
        Callback = function(v) State.DodgeNotify = v end,
    })

    Combat:Section({ Title = "Bullet Dodge" })

    Combat:Toggle({
        Title = "Auto Dodge Bullets",
        Desc = "Shots are decided the moment they click, so this jukes you sideways at random while an armed player is facing you with a clear line. Never steps into walls or off edges.",
        Value = false,
        Callback = function(v) BulletDodge.Set(v) end,
    })

    Combat:Dropdown({
        Title = "Juke Style",
        Desc = "Slide glides over a few frames; Blink snaps instantly.",
        Values = BulletDodge.Styles,
        Value = "Slide",
        Callback = function(v) State.BulletStyle = v end,
    })

    Combat:Slider({
        Title = "Juke Distance",
        Value = { Min = 1.5, Max = 8, Default = 3 },
        Step = 0.5,
        Callback = function(v) State.BulletJukeDistance = v end,
    })

    Combat:Slider({
        Title = "Juke Every (s)",
        Desc = "Average gap between steps; each one is randomised around it.",
        Value = { Min = 0.1, Max = 0.6, Default = 0.22 },
        Step = 0.02,
        Callback = function(v) State.BulletJukeEvery = v end,
    })

    Combat:Slider({
        Title = "Watch Range",
        Desc = "Guns further away than this are ignored.",
        Value = { Min = 30, Max = 300, Default = 150 },
        Step = 10,
        Callback = function(v) State.BulletRange = v end,
    })

    Combat:Slider({
        Title = "Aim Cone",
        Desc = "How directly they have to face you, in degrees. Wider reacts sooner.",
        Value = { Min = 10, Max = 90, Default = 40 },
        Step = 5,
        Callback = function(v) State.BulletFacing = v end,
    })

    Combat:Toggle({
        Title = "Random Jumps",
        Desc = "Throws a jump into some jukes.",
        Value = false,
        Callback = function(v) State.BulletJump = v end,
    })

    Combat:Toggle({
        Title = "Notify On Bullet Dodge",
        Desc = "Tells you who's aiming and when a shot misses.",
        Value = false,
        Callback = function(v) State.BulletNotify = v end,
    })

    Combat:Section({ Title = "Anti Stab" })

    Combat:Toggle({
        Title = "Anti Stab",
        Desc = "Moves you out of knife range before the murderer reaches you.",
        Value = false,
        Callback = function(v) AntiStab.Set(v) end,
    })

    Combat:Dropdown({
        Title = "Escape Mode",
        Values = { "Dash", "Hop", "Both" },
        Value = "Dash",
        Callback = function(v) State.AntiStabMode = v end,
    })

    Combat:Slider({
        Title = "Trigger Radius",
        Desc = "How close the murderer gets before you move.",
        Value = { Min = 6, Max = 40, Default = 14 },
        Step = 1,
        Callback = function(v) State.AntiStabRadius = v end,
    })

    Combat:Slider({
        Title = "Escape Distance",
        Value = { Min = 5, Max = 60, Default = 20 },
        Step = 1,
        Callback = function(v) State.AntiStabDistance = v end,
    })

    Combat:Slider({
        Title = "Hop Height",
        Desc = "Used by Hop and Both, and as the fallback when you're cornered.",
        Value = { Min = 5, Max = 40, Default = 16 },
        Step = 1,
        Callback = function(v) State.AntiStabHop = v end,
    })

    Combat:Slider({
        Title = "Reaction Lead (s)",
        Desc = "Reacts to where they'll be this far ahead, not where they are.",
        Value = { Min = 0, Max = 1, Default = 0.2 },
        Step = 0.05,
        Callback = function(v) State.AntiStabReact = v end,
    })

    Combat:Slider({
        Title = "Escape Cooldown (s)",
        Value = { Min = 0.1, Max = 2, Default = 0.35 },
        Step = 0.05,
        Callback = function(v) State.AntiStabCooldown = v end,
    })

    Combat:Toggle({
        Title = "Notify On Escape",
        Value = false,
        Callback = function(v) State.AntiStabNotify = v end,
    })

    local HalloweenTab = makeTab("Halloween", "ghost", GLINT)

    HalloweenTab:Section({ Title = "Halloween Event" })

    local eventInfo = HalloweenTab:Paragraph({
        Title = "🎃 Event",
        Desc = "Loading the event...",
    })

    local function refreshEvent()
        task.spawn(function()
            local text = Halloween.Report()
            pcall(function() eventInfo:SetDesc(text) end)
        end)
    end

    HalloweenTab:Button({
        Title = "Refresh Status",
        Desc = "Candies, battle pass tier and every open quest.",
        Callback = refreshEvent,
    })

    HalloweenTab:Section({ Title = "Battle Pass" })

    HalloweenTab:Toggle({
        Title = "Auto Claim Tiers",
        Desc = "Claims every battle pass tier you've reached.",
        Value = false,
        Callback = function(v) Halloween.Set("HalloweenClaim", v) end,
    })

    HalloweenTab:Toggle({
        Title = "Auto Buy Tiers",
        Desc = "Spends candies on tiers whenever you can afford one.",
        Value = false,
        Callback = function(v) Halloween.Set("HalloweenBuyTiers", v) end,
    })

    HalloweenTab:Toggle({
        Title = "Auto Buy Final Reward",
        Desc = "Once the pass is full, keeps buying the final reward with candies.",
        Value = false,
        Callback = function(v) Halloween.Set("HalloweenBuyFinal", v) end,
    })

    HalloweenTab:Slider({
        Title = "Keep Candies",
        Desc = "Never spends below this many.",
        Value = { Min = 0, Max = 50000, Default = 0 },
        Step = 100,
        Callback = function(v) State.HalloweenKeep = v end,
    })

    HalloweenTab:Button({
        Title = "Claim Now",
        Callback = function()
            task.spawn(function()
                if not Halloween.Load() then return Util.Notify("Halloween", "No live event found.") end
                local n = Halloween.ClaimTiers()
                if n == 0 then Util.Notify("Halloween", "Nothing to claim.") end
                refreshEvent()
            end)
        end,
    })

    HalloweenTab:Section({ Title = "Quests" })

    local helperOn = {}
    local function setFeature(title, want)
        local el = toggleRefs[title]
        if not (el and type(el.Set) == "function") then return end
        if want and not el.Value then
            helperOn[title] = true
            el:Set(true)
        elseif not want and el.Value and helperOn[title] then
            helperOn[title] = nil
            el:Set(false)
        end
    end
    Halloween.ApplyPlan = function(plan)
        setFeature("Auto Farm Coins", plan.farm)
        setFeature("Auto Kill All", plan.killAll)
        setFeature("Auto Kill Murderer", plan.killMurderer)
        setFeature("Auto Grab Dropped Gun", plan.grabGun)
        setFeature("Anti Stab", plan.survive)
        setFeature("Auto Dodge Knives", plan.survive)
        setFeature("Anti AFK", plan.stayIn)
        setFeature("Auto Craft Event Recipes", plan.craft)
    end

    HalloweenTab:Toggle({
        Title = "Auto Quests",
        Desc = "Works through your open quests one at a time, picked for your role each round: Kill All as murderer, Kill Murderer as sheriff/hero, coins as innocent (grab the gun and it switches to the sheriff quest). Only one thing runs at once, and it turns off what it turned on.",
        Value = false,
        Callback = function(v) Halloween.Set("HalloweenQuests", v) end,
    })

    HalloweenTab:Button({
        Title = "Show Quests",
        Callback = function()
            task.spawn(function()
                refreshEvent()
                Util.Notify("Quests", Halloween.Report())
            end)
        end,
    })

    if import("ui/Style") == "Cards" then
        HalloweenTab:Section({ Title = "Quest Board" })
        local DONE = Color3.fromRGB(110, 220, 140)
        local MANUAL = Color3.fromRGB(120, 120, 128)
        local slots = {}
        for i = 1, 16 do
            slots[i] = HalloweenTab:Paragraph({ Title = "Quest " .. i, Desc = "", Progress = 0 })
            pcall(function() slots[i]:SetVisible(false) end)
        end
        local waiting = HalloweenTab:Paragraph({
            Title = "Waiting for the event",
            Desc = "Your quests show up here as soon as the event data loads.",
        })

        local function paintQuests()
            local quests = Halloween.Quests()
            for i, slot in ipairs(slots) do
                local q = quests[i]
                if not q then
                    if slot.shown ~= false then slot.shown = false slot:SetVisible(false) end
                else
                    if slot.shown ~= true then slot.shown = true slot:SetVisible(true) end
                    slot.questId = q.id
                    local now = Halloween.Current and Halloween.Current.id == q.id and State.HalloweenQuests
                    local title = (q.done and "\u{2713}  " or now and "\u{25B6}  " or "") .. (q.board and "Board  \u{00B7}  " or "") .. q.title
                    local parts = { ("%d / %d"):format(math.min(q.progress, q.goal), q.goal) }
                    if q.description ~= "" then table.insert(parts, 1, q.description) end
                    if q.nextStep then
                        local reward = Halloween.RewardName(q.nextStep)
                        parts[#parts + 1] = ("next at %d%s"):format(q.nextStep.amount, reward and (": " .. reward) or "")
                    end
                    if now then
                        parts[#parts + 1] = "working on it: " .. q.action
                    elseif not q.done then
                        parts[#parts + 1] = q.action
                    end
                    local desc = table.concat(parts, "  \u{00B7}  ")
                    if slot.t ~= title then slot.t = title slot:SetTitle(title) end
                    if slot.d ~= desc then slot.d = desc slot:SetDesc(desc) end
                    local manual = q.kind == "other" or q.kind == "gift"
                    local a = q.goal > 0 and math.min(q.progress / q.goal, 1) or 0
                    local color = q.done and DONE or (manual and MANUAL or nil)
                    if slot.a ~= a or slot.c ~= color then
                        slot.a, slot.c = a, color
                        slot:SetProgress(a, color)
                    end
                end
            end
            if (#quests == 0) ~= waiting.shown then
                waiting.shown = #quests == 0
                waiting:SetVisible(waiting.shown)
            end
        end

        Halloween.OnQuestChanged = function(q)
            pcall(paintQuests)
            for _, slot in ipairs(slots) do
                if slot.questId == q.id then pcall(function() slot:Flash(q.done and DONE or nil) end) end
            end
        end
        Util.Loop("questcards", function() return 3 end, function() pcall(paintQuests) end)
    end

    HalloweenTab:Section({ Title = "Crafting & Gifts" })

    HalloweenTab:Toggle({
        Title = "Auto Craft Event Recipes",
        Desc = "Crafts every event recipe the moment you have the materials.",
        Value = false,
        Callback = function(v) Halloween.Set("HalloweenCraft", v) end,
    })

    HalloweenTab:Toggle({
        Title = "Auto Claim Gift Reward",
        Desc = "Claims the gifting reward each time you've given enough gifts.",
        Value = false,
        Callback = function(v) Halloween.Set("HalloweenGift", v) end,
    })

    HalloweenTab:Toggle({
        Title = "Event Notifications",
        Value = true,
        Callback = function(v) State.HalloweenNotify = v end,
    })

    task.delay(2, refreshEvent)

    local KnifeTab = makeTab("Knife", "sword", CHROME)

    local function throwKnife()
        local ok, msg = Melee.ThrowKnife()
        if not ok then Util.Notify("Throw Knife", tostring(msg)) end
    end

    KnifeTab:Section({ Title = "Silent Throw" })

    KnifeTab:Toggle({
        Title = "Silent Throw (Knife)",
        Desc = "Throws resolve on the sheriff, nearest player if there isn't one.",
        Value = false,
        Callback = function(v)
            State.SilentKnife = v
            if v and not SilentAim.Hook() and not SilentAim.Hooked() then
                Util.Notify("Silent Throw", "WeaponService missing -- are you in MM2?")
            end
        end,
    })

    KnifeTab:Toggle({
        Title = "Target Hero With Knife",
        Desc = "Once the sheriff dies, treat whoever picked the gun up as the target.",
        Value = true,
        Callback = function(v) State.KnifeTargetHero = v end,
    })

    KnifeTab:Section({ Title = "Knife" })

    KnifeTab:Button({
        Title = "Throw Knife",
        Desc = "One throw at the sheriff, the hero if he's down, else the nearest player. Aims itself.",
        Callback = function() throwKnife() end,
    })

    KnifeTab:Toggle({
        Title = "Edit Throw Speed",
        Desc = "Overrides the thrown knife's flight speed and the aim prediction.",
        Value = false,
        Callback = function(v) KnifeSpeed.Set(v) end,
    })

    KnifeTab:Slider({
        Title = "Throw Speed (studs/s)",
        Desc = "Game default is 96. Enforced every frame on the flying knife.",
        Value = { Min = 20, Max = 600, Default = 96 },
        Step = 4,
        Callback = function(v)
            State.KnifeThrowSpeed = v
            KnifeSpeed.Refresh()
        end,
    })

    KnifeTab:Toggle({
        Title = "Auto Throw Knife",
        Desc = "Throws on a timer via WeaponService. Aims itself if Silent Throw is on.",
        Value = false,
        Callback = function(v) Melee.SetAutoThrow(v) end,
    })

    KnifeTab:Slider({
        Title = "Throw Delay",
        Value = { Min = 0.2, Max = 5, Default = 0.6 },
        Step = 0.1,
        Callback = function(v) State.ThrowDelay = v end,
    })

    KnifeTab:Section({ Title = "Knife Hitbox" })

    KnifeTab:Toggle({
        Title = "Hitbox Expander",
        Desc = "Grows everyone's root part on your screen so your knife connects from further away. Only while you have a knife.",
        Value = false,
        Callback = function(v) Hitbox.Set(v) end,
    })

    KnifeTab:Slider({
        Title = "Hitbox Size",
        Desc = "Studs across. A normal root part is 2.",
        Value = { Min = 2, Max = 30, Default = 12 },
        Step = 1,
        Callback = function(v)
            State.HitboxSize = v
            Hitbox.Refresh()
        end,
    })

    KnifeTab:Dropdown({
        Title = "Hitbox Targets",
        Values = Hitbox.Modes,
        Value = "Everyone",
        Callback = function(v)
            State.HitboxMode = v
            Hitbox.Refresh()
        end,
    })

    KnifeTab:Toggle({
        Title = "Show Hitboxes",
        Value = false,
        Callback = function(v)
            State.HitboxVisible = v
            Hitbox.Refresh()
        end,
    })

    KnifeTab:Toggle({
        Title = "Force Touch",
        Desc = "Fires the touch between your knife and anyone in range directly -- no swing needed.",
        Value = false,
        Callback = function(v) Hitbox.SetForceTouch(v) end,
    })

    KnifeTab:Slider({
        Title = "Force Touch Range",
        Value = { Min = 5, Max = 60, Default = 25 },
        Step = 1,
        Callback = function(v) State.HitboxTouchRange = v end,
    })

    KnifeTab:Section({ Title = "Dual Wield" })

    KnifeTab:Toggle({
        Title = "Dual Wield (Knife)",
        Desc = "Copy of your knife in the off hand. Visual only.",
        Value = false,
        Callback = function(v) DualWield.SetKnife(v) end,
    })

    KnifeTab:Section({ Title = "Knife Aura" })

    KnifeTab:Toggle({
        Title = "Knife Aura",
        Desc = "Stabs anyone inside the radius, without moving or swinging.",
        Value = false,
        Callback = function(v) Melee.SetAura(v) end,
    })

    KnifeTab:Slider({
        Title = "Aura Radius",
        Value = { Min = 4, Max = 60, Default = 18 },
        Step = 1,
        Callback = function(v) State.AuraRadius = v end,
    })

    KnifeTab:Slider({
        Title = "Aura Delay (per target)",
        Value = { Min = 0.05, Max = 1, Default = 0.15 },
        Step = 0.05,
        Callback = function(v) State.AuraDelay = v end,
    })

    KnifeTab:Button({
        Title = "Kill All",
        Desc = "Fires the stab call at every living player. You don't move.",
        Callback = function() Melee.KillAll() end,
    })

    KnifeTab:Toggle({
        Title = "Auto Kill All",
        Desc = "Repeats Kill All on a timer.",
        Value = false,
        Callback = function(v) Melee.SetAutoKillAll(v) end,
    })

    KnifeTab:Slider({
        Title = "Auto Kill All Delay",
        Value = { Min = 1, Max = 30, Default = 3 },
        Step = 1,
        Callback = function(v) State.KillAllDelay = v end,
    })

    local GunTab = makeTab("Gun", "target", ICE)

    local presetDropdown

    GunTab:Section({ Title = "Silent Aim" })

    GunTab:Toggle({
        Title = "Silent Aim (Gun)",
        Desc = "Shots resolve on the murderer. Camera never moves.",
        Value = false,
        Callback = function(v)
            State.SilentGun = v
            if v and not SilentAim.Hook() and not SilentAim.Hooked() then
                Util.Notify("Silent Aim", "WeaponService missing -- are you in MM2?")
            end
        end,
    })

    GunTab:Section({ Title = "Gun" })

    GunTab:Toggle({
        Title = "Triggerbot",
        Desc = "Shoots the moment the murderer is inside the FOV circle, aimed by silent aim.",
        Value = false,
        Callback = function(v) Guns.SetTriggerbot(v) end,
    })

    GunTab:Slider({
        Title = "Trigger FOV (px)",
        Desc = "How close to your crosshair he has to be.",
        Value = { Min = 10, Max = 250, Default = 60 },
        Step = 5,
        Callback = function(v) State.TriggerFov = v end,
    })

    GunTab:Toggle({
        Title = "Show FOV Circle",
        Value = false,
        Callback = function(v) Guns.SetFovCircle(v) end,
    })

    GunTab:Slider({
        Title = "Reaction Delay (s)",
        Value = { Min = 0, Max = 0.5, Default = 0.05 },
        Step = 0.01,
        Callback = function(v) State.TriggerDelay = v end,
    })

    GunTab:Slider({
        Title = "Trigger Cooldown (s)",
        Value = { Min = 0.1, Max = 2, Default = 0.25 },
        Step = 0.05,
        Callback = function(v) State.TriggerCooldown = v end,
    })

    GunTab:Toggle({
        Title = "Visible Only",
        Desc = "Only fires when you could actually see him.",
        Value = true,
        Callback = function(v) State.TriggerVisibleOnly = v end,
    })

    GunTab:Toggle({
        Title = "Only While Holding Gun",
        Value = true,
        Callback = function(v) State.TriggerNeedsEquip = v end,
    })

    GunTab:Toggle({
        Title = "Auto Shoot Murderer",
        Desc = "Pulls the trigger on a timer, aimed by the same silent aim the toggle uses.",
        Value = false,
        Callback = function(v) Guns.SetAutoShoot(v) end,
    })

    GunTab:Slider({
        Title = "Shoot Delay",
        Value = { Min = 0.1, Max = 3, Default = 0.35 },
        Step = 0.05,
        Callback = function(v) State.ShootDelay = v end,
    })

    GunTab:Toggle({
        Title = "Auto Grab Dropped Gun",
        Desc = "Teleports onto the gun when the sheriff drops it.",
        Value = false,
        Callback = function(v) Guns.SetAutoGrab(v) end,
    })

    GunTab:Section({ Title = "Kill Murderer" })

    local function killMurderer()
        task.spawn(function()
            local ok, msg = Guns.KillMurderer()
            if msg ~= "already on it" then Util.Notify("Kill Murderer", tostring(msg)) end
        end)
    end

    local function shootMurderer()
        local ok, msg = Guns.ShootMurderer()
        if not ok then Util.Notify("Shoot Murderer", tostring(msg)) end
    end

    GunTab:Button({
        Title = "Shoot Murderer",
        Desc = "One shot straight at his hitbox from where you stand. No teleport.",
        Callback = shootMurderer,
    })

    GunTab:Toggle({
        Title = "Auto Kill Murderer",
        Desc = "The moment you have the gun (sheriff or hero), kills the murderer by itself.",
        Value = false,
        Callback = function(v) Guns.SetAutoKillMurderer(v) end,
    })

    GunTab:Button({
        Title = "Kill Murderer",
        Desc = "Silent aim locks on him, keeps shooting until he's dead, then brings you back.",
        Callback = killMurderer,
    })

    GunTab:Slider({
        Title = "Distance Behind (studs)",
        Value = { Min = 2, Max = 15, Default = 4 },
        Step = 1,
        Callback = function(v) State.KillMurdererDistance = v end,
    })

    GunTab:Slider({
        Title = "Max Shots",
        Value = { Min = 1, Max = 12, Default = 6 },
        Step = 1,
        Callback = function(v) State.KillMurdererShots = v end,
    })

    GunTab:Slider({
        Title = "Wait For Kill (s)",
        Desc = "How long to watch for him dying before the next shot (the gun's reload is waited out on top).",
        Value = { Min = 0.2, Max = 3, Default = 1 },
        Step = 0.05,
        Callback = function(v) State.KillMurdererGap = v end,
    })

    GunTab:Toggle({
        Title = "Return After Shot",
        Value = true,
        Callback = function(v) State.KillMurdererReturn = v end,
    })

    GunTab:Section({ Title = "Gun Drop" })

    GunTab:Toggle({
        Title = "Gun Drop Notifier",
        Desc = "Pops up when the gun hits the floor (with how far), and says who picks it up.",
        Value = false,
        Callback = function(v) Guns.SetGunDropNotify(v) end,
    })

    GunTab:Toggle({
        Title = "Notifier Sound",
        Value = true,
        Callback = function(v) State.GunDropSound = v end,
    })

    GunTab:Section({ Title = "Dual Wield" })

    GunTab:Toggle({
        Title = "Dual Wield (Gun)",
        Desc = "Copy of your gun in the off hand. Visual only.",
        Value = false,
        Callback = function(v) DualWield.SetGun(v) end,
    })

    GunTab:Section({ Title = "Shot Tracer" })

    GunTab:Toggle({
        Title = "Show Shot Trace",
        Desc = "A line from your muzzle to where each shot actually landed.",
        Value = false,
        Callback = function(v) ShotTrace.Set(v) end,
    })

    GunTab:Dropdown({
        Title = "Trace Style",
        Desc = "Beam glows, Laser is a thin cylinder, Line is flat.",
        Values = ShotTrace.Styles,
        Value = "Beam",
        Callback = function(v) State.TraceStyle = v end,
    })

    GunTab:Dropdown({
        Title = "Trace Colour",
        Values = ShotTrace.ColorNames,
        Value = "Green",
        Callback = function(v) State.TraceColorName = v; State.TraceColor = nil end,
    })

    GunTab:Colorpicker({
        Title = "Custom Trace Colour",
        Desc = "Overrides the preset colour above.",
        Default = Color3.fromRGB(0, 255, 170),
        Callback = function(c) State.TraceColor = c end,
    })

    GunTab:Slider({
        Title = "Trace Lifetime (s)",
        Value = { Min = 1, Max = 15, Default = 2.5 },
        Step = 0.5,
        Callback = function(v) State.TraceLife = v end,
    })

    GunTab:Slider({
        Title = "Trace Thickness",
        Value = { Min = 0.1, Max = 1, Default = 0.28 },
        Step = 0.02,
        Callback = function(v) State.TraceThickness = v end,
    })

    GunTab:Toggle({
        Title = "Impact Marker",
        Desc = "A ball and the distance in studs where the shot ended. Red = hit a player.",
        Value = true,
        Callback = function(v) State.TraceImpact = v end,
    })

    GunTab:Button({
        Title = "Clear Traces",
        Callback = function() ShotTrace.Clear() end,
    })

    local EspTab = makeTab("ESP", "scan-eye", ICE)

    EspTab:Section({ Title = "Targets" })

    EspTab:Toggle({
        Title = "ESP Murderer",
        Value = false,
        Callback = function(v) State.EspMurderer = v; ESP.Refresh() end,
    })

    EspTab:Toggle({
        Title = "ESP Sheriff",
        Value = false,
        Callback = function(v) State.EspSheriff = v; ESP.Refresh() end,
    })

    EspTab:Toggle({
        Title = "ESP Hero",
        Desc = "The innocent who picked up the dropped gun.",
        Value = false,
        Callback = function(v) State.EspHero = v; ESP.Refresh() end,
    })

    EspTab:Toggle({
        Title = "ESP Innocents",
        Value = false,
        Callback = function(v) State.EspInnocents = v; ESP.Refresh() end,
    })

    EspTab:Toggle({
        Title = "ESP Zombies",
        Desc = "Infection mode: zombies in green.",
        Value = false,
        Callback = function(v) State.EspZombies = v; ESP.Refresh() end,
    })

    EspTab:Toggle({
        Title = "ESP Survivors",
        Desc = "Infection mode: survivors in blue.",
        Value = false,
        Callback = function(v) State.EspSurvivors = v; ESP.Refresh() end,
    })

    EspTab:Toggle({
        Title = "ESP Assassin Target",
        Desc = "Assassin mode: your target in hot pink, labelled YOUR TARGET.",
        Value = false,
        Callback = function(v) State.EspAssassinTarget = v; ESP.Refresh() end,
    })

    EspTab:Toggle({
        Title = "ESP Other Assassins",
        Desc = "Assassin mode: everyone else in orange (any of them could be after you).",
        Value = false,
        Callback = function(v) State.EspAssassins = v; ESP.Refresh() end,
    })

    EspTab:Toggle({
        Title = "ESP Dropped Gun",
        Value = false,
        Callback = function(v) State.EspGun = v; ESP.Refresh() end,
    })

    EspTab:Toggle({
        Title = "Fake Gun Detector",
        Desc = "Tags FAKE GUN over the murderer when they pull out the Fake Gun perk.",
        Value = false,
        Callback = function(v) FakeGun.Set(v) end,
    })

    EspTab:Toggle({
        Title = "ESP Traps",
        Desc = "Shows traps other players hid, with whose they are and how far.",
        Value = false,
        Callback = function(v) TrapESP.Set(v) end,
    })

    EspTab:Toggle({
        Title = "ESP Everything",
        Desc = "All roles plus the dropped gun, regardless of the toggles above.",
        Value = false,
        Callback = function(v) State.EspEverything = v; ESP.Refresh() end,
    })

    EspTab:Toggle({
        Title = "XRay",
        Value = false,
        Callback = function(v) XRay.Set(v) end,
    })

    EspTab:Section({ Title = "Boxes & Tracers" })

    EspTab:Toggle({
        Title = "Box ESP",
        Desc = "2D box around each player, coloured by role.",
        Value = false,
        Callback = function(v)
            State.EspBoxes = v
            Visuals.Refresh()
        end,
    })

    EspTab:Slider({
        Title = "Box Thickness",
        Value = { Min = 1, Max = 5, Default = 1.5 },
        Step = 0.5,
        Callback = function(v) State.BoxThickness = v end,
    })

    EspTab:Toggle({
        Title = "Tracers",
        Desc = "Lines from your screen to every player.",
        Value = false,
        Callback = function(v)
            State.EspTracers = v
            Visuals.Refresh()
        end,
    })

    EspTab:Dropdown({
        Title = "Tracer Origin",
        Values = { "Bottom", "Center", "Top", "Mouse" },
        Value = "Bottom",
        Callback = function(v) State.TracerOrigin = v end,
    })

    EspTab:Slider({
        Title = "Tracer Thickness",
        Value = { Min = 1, Max = 6, Default = 1 },
        Step = 1,
        Callback = function(v) State.TracerThickness = v end,
    })

    EspTab:Section({ Title = "Knife Trails" })

    EspTab:Toggle({
        Title = "Knife Trail",
        Desc = "Every thrown knife's whole flight: the path ahead, a glowing ribbon and where it lands. Turns red when it's coming for you.",
        Value = false,
        Callback = function(v) KnifeTrail.Set(v) end,
    })

    EspTab:Dropdown({
        Title = "Trail Colour",
        Values = KnifeTrail.PaletteNames,
        Value = "Halloween",
        Callback = function(v) State.KnifeTrailColor = v end,
    })

    EspTab:Toggle({
        Title = "Show Path Ahead",
        Value = true,
        Callback = function(v) State.KnifeTrailPath = v KnifeTrail.Refresh() end,
    })

    EspTab:Toggle({
        Title = "Glow Ribbon",
        Value = true,
        Callback = function(v) State.KnifeTrailGlow = v end,
    })

    EspTab:Toggle({
        Title = "Landing Marker",
        Desc = "Ball where it lands, with the name of whoever is in the way.",
        Value = true,
        Callback = function(v) State.KnifeTrailMarker = v KnifeTrail.Refresh() end,
    })

    EspTab:Section({ Title = "Labels" })

    EspTab:Toggle({
        Title = "Show Names & Roles",
        Value = true,
        Callback = function(v) State.EspNames = v end,
    })

    EspTab:Toggle({
        Title = "Show Distance",
        Value = true,
        Callback = function(v) State.EspDistance = v end,
    })

    EspTab:Section({ Title = "Performance" })

    EspTab:Toggle({
        Title = "Performance Mode",
        Desc = "Kills shadows, post-processing, water detail and every particle effect. "
            .. "Fully reversible -- originals are restored when you switch it off.",
        Value = false,
        Callback = function(v) Perf.SetPerformance(v) end,
    })

    EspTab:Toggle({
        Title = "FPS Counter",
        Desc = "A glass pill up top with your FPS, ping and the time. Drag it anywhere; the FPS turns warm when it drops.",
        Value = false,
        Callback = function(v) Perf.SetFps(v) end,
    })

    EspTab:Section({ Title = "Round" })

    EspTab:Toggle({
        Title = "Show Counter",
        Desc = "Small bar at the top: round clock, alive count, murderer/sheriff status.",
        Value = false,
        Callback = function(v) Counter.Set(v) end,
    })

    EspTab:Toggle({
        Title = "Show Equipped Skins",
        Desc = "Their gun and knife skins, as pictures over their head.",
        Value = false,
        Callback = function(v) SkinTags.Set(v) end,
    })

    EspTab:Section({ Title = "Murderer Alarm" })

    EspTab:Toggle({
        Title = "Murderer Alarm",
        Desc = "A warning drops in up top with who, how far and which way. Beeps faster as they close in.",
        Value = false,
        Callback = function(v) Alarm.Set(v) end,
    })

    EspTab:Slider({
        Title = "Alarm Distance (studs)",
        Value = { Min = 5, Max = 100, Default = 25 },
        Step = 1,
        Callback = function(v) State.AlarmRadius = v end,
    })

    EspTab:Toggle({
        Title = "Alarm Sound",
        Value = true,
        Callback = function(v) State.AlarmSound = v end,
    })

    local FlingTab = makeTab("Fling", "tornado", CHROME)

    FlingTab:Section({ Title = "Targets" })

    FlingTab:Button({
        Title = "Fling Murderer",
        Callback = function() Fling.Murderer() end,
    })

    FlingTab:Button({
        Title = "Fling Sheriff",
        Callback = function() Fling.Sheriff() end,
    })

    local playerDropdown
    playerDropdown = FlingTab:Dropdown({
        Title = "Custom Player",
        Values = {},
        Value = nil,
        AllowNone = true,
        SearchBarEnabled = true,
        Callback = function(v) State.FlingTarget = v end,
    })

    local function refreshPlayers()
        local names = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Services.LocalPlayer then
                table.insert(names, plr.Name)
            end
        end
        table.sort(names)
        pcall(function() playerDropdown:Refresh(names) end)
    end

    FlingTab:Button({
        Title = "Fling Selected Player",
        Callback = function()
            if not State.FlingTarget then
                Util.Notify("Fling", "Pick a player first.")
                return
            end
            Fling.Named(State.FlingTarget)
        end,
    })

    FlingTab:Button({
        Title = "Refresh Player List",
        Callback = refreshPlayers,
    })

    FlingTab:Section({ Title = "Tuning" })

    FlingTab:Slider({
        Title = "Fling Duration (s)",
        Desc = "Give-up time. It stops early the moment they're thrown.",
        Value = { Min = 0.5, Max = 6, Default = 2.5 },
        Step = 0.1,
        Callback = function(v) State.FlingDuration = v end,
    })

    FlingTab:Button({
        Title = "Stop Fling",
        Callback = function() Fling.Stop() end,
    })

    FlingTab:Section({ Title = "Anti Fling" })

    FlingTab:Toggle({
        Title = "Anti Fling",
        Desc = "Clamps launch velocity and rewinds you if something throws you.",
        Value = false,
        Callback = function(v) AntiFling.Set(v) end,
    })

    FlingTab:Toggle({
        Title = "Ignore Player Collisions",
        Desc = "Other players can't transfer force into you. Stops the fling instead of cleaning up after it.",
        Value = true,
        Callback = function(v) AntiFling.SetCollisions(v) end,
    })

    FlingTab:Slider({
        Title = "Max Speed",
        Desc = "Anything faster than this is treated as a launch.",
        Value = { Min = 60, Max = 400, Default = 150 },
        Step = 10,
        Callback = function(v) State.AntiFlingMax = v end,
    })

    FlingTab:Slider({
        Title = "Rewind Distance",
        Desc = "How far you have to be thrown before you get put back.",
        Value = { Min = 10, Max = 150, Default = 40 },
        Step = 5,
        Callback = function(v) State.AntiFlingSnap = v end,
    })

    refreshPlayers()
    Util.Bind("plradd", Players.PlayerAdded, refreshPlayers)
    Util.Bind("plrrem", Players.PlayerRemoving, refreshPlayers)

    local BoxTab = makeTab("Boxes", "package", SILVER)

    local boxNames, boxLookup = Boxes.List()

    BoxTab:Section({ Title = "Unboxing" })

    local boxDropdown = BoxTab:Dropdown({
        Title = "Mystery Box",
        Values = boxNames,
        Value = nil,
        AllowNone = true,
        SearchBarEnabled = true,
        Callback = function(v)
            State.BoxId = boxLookup[v]

            local currency = Boxes.AutoCurrency(State.BoxId)
            if not currency then
                Util.Notify("Boxes", "No spendable price for this box -- Robux-only or event-only.")
                return
            end

            local price = Boxes.Price(State.BoxId, currency)
            Util.Notify("Boxes", ("%s costs %s %s"):format(
                Boxes.BoxName(State.BoxId), tostring(price), currency))
        end,
    })

    if #boxNames == 0 then
        BoxTab:Paragraph({
            Title = "No boxes found",
            Desc = "Database.Sync could not be read. Rejoin and reload the hub.",
        })
    end

    BoxTab:Button({
        Title = "Open Once",
        Callback = function()
            local rewarded, err = Boxes.Open()
            if not rewarded then
                Util.Notify("Boxes", "Failed: " .. tostring(err))
                return
            end
            Util.Notify("Unboxed", tostring(rewarded))
        end,
    })

    BoxTab:Toggle({
        Title = "Auto Open",
        Desc = "Opens on a loop until the server refuses.",
        Value = false,
        Callback = function(v) Boxes.SetAuto(v) end,
    })

    BoxTab:Slider({
        Title = "Open Delay (s)",
        Value = { Min = 0.5, Max = 10, Default = 1.5 },
        Step = 0.5,
        Callback = function(v) State.BoxDelay = v end,
    })

    BoxTab:Toggle({
        Title = "Play Opening Animation",
        Desc = "Off is much faster -- the animation blocks for about 4s.",
        Value = false,
        Callback = function(v) State.BoxAnimation = v end,
    })

    BoxTab:Section({ Title = "Webhook Logging" })

    BoxTab:Input({
        Title = "Discord Webhook URL",
        Placeholder = "https://discord.com/api/webhooks/...",
        Value = "",
        Callback = function(v) State.WebhookUrl = v end,
    })

    BoxTab:Toggle({
        Title = "Log Unboxes To Webhook",
        Desc = "Posts an embed with the box, item and rarity on every open.",
        Value = false,
        Callback = function(v)
            State.WebhookLogging = v
            if v and State.WebhookUrl == "" then
                Util.Notify("Webhook", "Paste a webhook URL above first.")
            end
        end,
    })

    BoxTab:Button({
        Title = "Send Test Message",
        Callback = function() Boxes.TestWebhook() end,
    })

    local CraftTab = makeTab("Crafting", "hammer", PEWTER)

    local recipeNames, recipeLookup = Crafting.List()
    local materialsInfo

    local function refreshMaterials()
        if not materialsInfo then return end
        task.spawn(function()
            local text = Crafting.Describe(State.CraftRecipe)
            pcall(function() materialsInfo:SetDesc(text) end)
        end)
    end

    CraftTab:Section({ Title = "Craft" })

    CraftTab:Dropdown({
        Title = "Recipe",
        Values = recipeNames,
        Value = nil,
        AllowNone = true,
        Callback = function(v)
            State.CraftRecipe = recipeLookup[v]
            refreshMaterials()
        end,
    })

    if #recipeNames == 0 then
        CraftTab:Paragraph({
            Title = "No recipes found",
            Desc = "Database.Sync could not be read. Rejoin and reload the hub.",
        })
    end

    materialsInfo = CraftTab:Paragraph({
        Title = "Materials",
        Desc = "Pick a recipe.",
    })

    CraftTab:Button({
        Title = "Refresh Materials",
        Callback = refreshMaterials,
    })

    CraftTab:Button({
        Title = "Craft Once",
        Callback = function()
            task.spawn(function()
                local itemId, err, kind = Crafting.Craft()
                Util.Notify("Crafting", itemId and ("Crafted " .. Crafting.ItemName(itemId, kind)) or ("Failed: " .. tostring(err)))
                refreshMaterials()
            end)
        end,
    })

    CraftTab:Toggle({
        Title = "Auto Craft",
        Desc = "Crafts the recipe on a loop until you run out of materials.",
        Value = false,
        Callback = function(v) Crafting.SetAutoCraft(v) end,
    })

    CraftTab:Toggle({
        Title = "Craft Anything Affordable",
        Desc = "Auto Craft ignores the picked recipe and makes the best one you can afford.",
        Value = false,
        Callback = function(v) State.CraftAny = v end,
    })

    CraftTab:Toggle({
        Title = "Auto Craft Materials",
        Desc = "Short on materials? Auto Craft makes them first: crafts material recipes and salvages weapons (ticked rarities below) that drop what's missing.",
        Value = false,
        Callback = function(v) State.CraftMaterials = v end,
    })

    CraftTab:Slider({
        Title = "Craft Delay (s)",
        Value = { Min = 0.5, Max = 5, Default = 1 },
        Step = 0.5,
        Callback = function(v) State.CraftDelay = v end,
    })

    CraftTab:Section({ Title = "Salvage" })

    CraftTab:Paragraph({
        Title = "How it chains",
        Desc = "Salvaging gives 2 shards of the weapon's rarity. 12 shards craft a weapon one tier up, 20 Legendary Shards craft the Seer. Run Auto Salvage and Auto Craft together to climb the ladder.",
    })

    for _, rarity in ipairs(Crafting.SalvageRarities) do
        CraftTab:Toggle({
            Title = "Salvage " .. rarity,
            Value = State["Salvage" .. rarity] == true,
            Callback = function(v) State["Salvage" .. rarity] = v end,
        })
    end

    CraftTab:Toggle({
        Title = "Keep One Of Each",
        Desc = "Never salvages your last copy of a weapon. Equipped weapons are always skipped.",
        Value = true,
        Callback = function(v) State.SalvageKeepOne = v end,
    })

    CraftTab:Toggle({
        Title = "Auto Salvage",
        Desc = "Salvages duplicates of the picked rarities until none are left. Can't be undone.",
        Value = false,
        Callback = function(v) Crafting.SetAutoSalvage(v) end,
    })

    CraftTab:Slider({
        Title = "Salvage Delay (s)",
        Value = { Min = 0.5, Max = 5, Default = 1 },
        Step = 0.5,
        Callback = function(v) State.SalvageDelay = v end,
    })

    CraftTab:Section({ Title = "Webhook Logging" })

    CraftTab:Input({
        Title = "Crafting Webhook URL",
        Desc = "Leave empty to use the Boxes webhook.",
        Placeholder = "https://discord.com/api/webhooks/...",
        Value = "",
        Callback = function(v) State.CraftWebhookUrl = v end,
    })

    CraftTab:Toggle({
        Title = "Log Crafts",
        Desc = "An embed per craft: item, rarity, what it cost, session total.",
        Value = false,
        Callback = function(v) State.LogCrafts = v end,
    })

    CraftTab:Toggle({
        Title = "Log Salvages",
        Desc = "One summary per run (or every 25): items salvaged and shards gained.",
        Value = false,
        Callback = function(v) State.LogSalvages = v end,
    })

    CraftTab:Button({
        Title = "Send Test Message",
        Callback = function()
            task.spawn(function()
                local ok, err = Crafting.TestWebhook()
                Util.Notify("Webhook", ok and "Test message sent." or ("Failed: " .. tostring(err)))
            end)
        end,
    })

    local FarmTab = makeTab("Auto Farm", "coins", PEWTER)

    FarmTab:Section({ Title = "Coins" })

    FarmTab:Toggle({
        Title = "Auto Farm Coins",
        Desc = "Glides through every uncollected coin, nearest first. No snapping.",
        Value = false,
        Callback = function(v) Farm.SetAutoFarm(v) end,
    })

    FarmTab:Dropdown({
        Title = "Farm Type",
        Desc = "Normal glides on the map. Underground lies flat under the floor, slides under each coin and pulls it onto you -- you never come up.",
        Values = Farm.Modes,
        Value = "Normal",
        Callback = function(v) Farm.SetMode(v) end,
    })

    FarmTab:Slider({
        Title = "Underground Depth",
        Desc = "Studs under each coin. Underground only.",
        Value = { Min = 2, Max = 10, Default = 3.5 },
        Step = 0.5,
        Callback = function(v) State.FarmDepth = v end,
    })

    FarmTab:Slider({
        Title = "Farm Speed (studs/s)",
        Desc = "Glide speed between coins. You normally walk at 16.",
        Value = { Min = 5, Max = 200, Default = 20 },
        Step = 1,
        Callback = function(v) State.FarmSpeed = v end,
    })

    FarmTab:Slider({
        Title = "Coin Delay (s)",
        Desc = "Pause after each pickup.",
        Value = { Min = 0, Max = 0.5, Default = 0.05 },
        Step = 0.01,
        Callback = function(v) State.FarmDelay = v end,
    })

    FarmTab:Section({ Title = "When The Bag Is Full" })

    FarmTab:Toggle({
        Title = "Fling Murderer",
        Value = false,
        Callback = function(v) State.FlingMurdererOnFull = v end,
    })

    FarmTab:Toggle({
        Title = "Kill All (murderer only)",
        Desc = "Skipped automatically unless you are the murderer.",
        Value = false,
        Callback = function(v) State.KillAllOnFull = v end,
    })

    FarmTab:Section({ Title = "Stats" })

    FarmTab:Toggle({
        Title = "Farm Stats",
        Desc = "Coins this session, coins per hour, time and your bag.",
        Value = false,
        Callback = function(v) FarmStats.Set(v) end,
    })

    FarmTab:Button({
        Title = "Reset Stats",
        Callback = function() FarmStats.Reset() end,
    })

    FarmTab:Section({ Title = "Round Log (Webhook)" })

    FarmTab:Input({
        Title = "Round Webhook URL",
        Desc = "Leave blank to use the one from the Boxes tab.",
        Placeholder = "https://discord.com/api/webhooks/...",
        Value = "",
        Callback = function(v) State.RoundWebhookUrl = v end,
    })

    FarmTab:Toggle({
        Title = "Log Rounds To Webhook",
        Desc = "After every round: win or loss, roles, XP breakdown, coins and your session total.",
        Value = false,
        Callback = function(v)
            RoundLog.Set(v)
            if v and (State.RoundWebhookUrl or "") == "" and State.WebhookUrl == "" then
                Util.Notify("Round Log", "Paste a webhook URL first.")
            end
        end,
    })

    FarmTab:Button({
        Title = "Send Test",
        Desc = "Posts your last round now.",
        Callback = function()
            task.spawn(function()
                local ok, err = RoundLog.Test()
                Util.Notify("Round Log", ok and "Sent." or ("Failed: " .. tostring(err)))
            end)
        end,
    })

    FarmTab:Section({ Title = "Stay In Game" })

    FarmTab:Toggle({
        Title = "Anti AFK",
        Desc = "No more idle kick after 20 minutes.",
        Value = false,
        Callback = function(v) Session.SetAntiAfk(v) end,
    })

    FarmTab:Toggle({
        Title = "Auto Rejoin",
        Desc = "Rejoins if you get kicked or disconnected. Put Riftware in autoexec so it loads back up.",
        Value = false,
        Callback = function(v) Session.SetAutoRejoin(v) end,
    })

    local CharTab = makeTab("Character", "wind", STEEL)

    CharTab:Section({ Title = "Movement" })

    CharTab:Toggle({
        Title = "Custom Walk Speed",
        Value = false,
        Callback = function(v) Char.SetSpeed(v) end,
    })

    CharTab:Slider({
        Title = "Walk Speed",
        Desc = "Default is 16.",
        Value = { Min = 16, Max = 250, Default = 16 },
        Step = 1,
        Callback = function(v) State.WalkSpeed = v end,
    })

    CharTab:Toggle({
        Title = "Custom Jump Power",
        Value = false,
        Callback = function(v) Char.SetJump(v) end,
    })

    CharTab:Slider({
        Title = "Jump Power",
        Desc = "Default is 50. Converted automatically if the game uses JumpHeight.",
        Value = { Min = 50, Max = 400, Default = 50 },
        Step = 5,
        Callback = function(v) State.JumpPower = v end,
    })

    CharTab:Section({ Title = "Fly" })

    CharTab:Toggle({
        Title = "Fly",
        Desc = "WASD to move, Space up, Left Shift down. Follows your camera.",
        Value = false,
        Callback = function(v) Char.SetFly(v) end,
    })

    CharTab:Slider({
        Title = "Fly Speed",
        Value = { Min = 10, Max = 400, Default = 60 },
        Step = 5,
        Callback = function(v) State.FlySpeed = v end,
    })

    CharTab:Section({ Title = "Extras" })

    CharTab:Toggle({
        Title = "Anti Trap",
        Desc = "Stepping on a trap doesn't slow you down.",
        Value = false,
        Callback = function(v) AntiTrap.Set(v) end,
    })

    CharTab:Section({ Title = "Wall Hop" })

    local function wallHop()
        local ok, err = WallHop.Go()
        if not ok and err ~= "busy" then Util.Notify("Wall Hop", tostring(err)) end
    end

    CharTab:Button({
        Title = "Wall Hop",
        Desc = "Stand against a wall and press to hop up it.",
        Callback = wallHop,
    })

    CharTab:Toggle({
        Title = "Auto Wall Hop",
        Desc = "Every jump next to a wall becomes a hop. Hold jump to climb.",
        Value = false,
        Callback = function(v) WallHop.SetAuto(v) end,
    })

    CharTab:Section({ Title = "Bomb Jump" })

    local function bombJump()
        task.spawn(function()
            local ok, err = BombJump.Go()
            if not ok then Util.Notify("Bomb Jump", tostring(err)) end
        end)
    end

    CharTab:Button({
        Title = "Bomb Jump",
        Desc = "Blows up the Prank Bomb under your feet to launch you. 22s cooldown.",
        Callback = bombJump,
    })

    CharTab:Section({ Title = "Perk" })

    CharTab:Button({
        Title = "Activate Perk",
        Desc = "Fires whatever perk you have equipped this round.",
        Callback = function()
            local ok, result = Perks.Activate()
            Util.Notify("Perk", ok and ("Activated " .. tostring(result))
                or ("Failed: " .. tostring(result)))
        end,
    })

    CharTab:Toggle({
        Title = "Auto Ghost",
        Desc = "Re-activates Ghost the moment its cooldown is up.",
        Value = false,
        Callback = function(v) Perks.SetAutoGhost(v) end,
    })

    CharTab:Button({
        Title = "Perk Status",
        Callback = function() Util.Notify("Perk", Perks.Report()) end,
    })

    local EmoteTab = makeTab("Emotes", "music-2", GRAPHITE)

    local emoteLabels, emoteLookup = Emotes.List()

    EmoteTab:Dropdown({
        Title = "Emote",
        Values = emoteLabels,
        Value = nil,
        AllowNone = true,
        SearchBarEnabled = true,
        Callback = function(v) State.Emote = emoteLookup[v] end,
    })

    EmoteTab:Button({
        Title = "Play Emote",
        Callback = function()
            local ok, result = Emotes.Play(State.Emote)
            if ok then
                Util.Notify("Emote", "Playing " .. tostring(result))
            else
                Util.Notify("Emote", "Failed: " .. tostring(result))
            end
        end,
    })

    EmoteTab:Button({
        Title = "Stop Emote",
        Desc = "Breaks the standing state so Animate falls back to idle.",
        Callback = function() Emotes.Stop() end,
    })

    if #emoteLabels == 0 then
        EmoteTab:Paragraph({
            Title = "No emotes found",
            Desc = "Database.Sync could not be read. Rejoin and reload the hub.",
        })
    end

    local SpawnTab = makeTab("Spawner", "sparkles", CHROME)

    if type(SpawnTab.Gallery) == "function" then
        SpawnerCards.Build(SpawnTab, Window)
    else
        local spawnerToggle
        spawnerToggle = SpawnTab:Toggle({
            Title = "Show Spawner Gui",
            Desc = "Ancient, Godly, Classic and Unique items. Client-side: only you see them.",
            Value = false,
            Callback = function(v) SpawnerGui.SetVisible(v) end,
        })

        SpawnerGui.OnClosed = function()
            if spawnerToggle and spawnerToggle.Set then
                pcall(function() spawnerToggle:Set(false) end)
            end
        end
    end

    local CrossTab = makeTab("Crosshair", "crosshair", ICE)

    CrossTab:Section({ Title = "Crosshair Settings" })

    CrossTab:Toggle({
        Title = "Custom Crosshair",
        Desc = "Replaces your cursor, and hides the game's own crosshair.",
        Value = false,
        Callback = function(v) Crosshair.Set(v) end,
    })

    CrossTab:Toggle({
        Title = "Spin Crosshair",
        Desc = "Rotates it continuously.",
        Value = false,
        Callback = function(v)
            State.CrosshairSpin = v
            Crosshair.UpdateSpin()
        end,
    })

    CrossTab:Slider({
        Title = "Crosshair Size",
        Value = { Min = 16, Max = 96, Default = 42 },
        Step = 2,
        Callback = function(v) Crosshair.SetSize(v) end,
    })

    CrossTab:Section({ Title = "Preset" })

    local crossLabels, crossLookup = Crosshair.PresetLabels()
    local crossGallery

    if type(CrossTab.Gallery) == "function" then

        crossGallery = CrossTab:Gallery({
            Title = "Presets",
            Items = function()
                local list = {}
                for i, preset in ipairs(Crosshair.Presets) do
                    list[i] = { id = preset.id, title = preset.name, sub = "ID " .. preset.id,
                                image = "rbxassetid://" .. preset.id }
                end
                return list
            end,
            Selected = State.CrosshairId,
            ShowCheck = true,
            OnSelect = function(item)
                Crosshair.SetImage(item.id)

                local toggle = toggleRefs["Custom Crosshair"]
                if toggle and toggle.Set and not toggle.Value then pcall(function() toggle:Set(true) end) end
                Util.Notify("Crosshair", "Set to " .. item.title)
            end,
        })
        CrossTab:Section({ Title = "Custom" })
    else
        CrossTab:Dropdown({
            Title = "Preset",
            Values = crossLabels,
            Value = crossLabels[1],
            SearchBarEnabled = true,
            Callback = function(v)
                local id = crossLookup[v]
                if id then
                    Crosshair.SetImage(id)
                    Util.Notify("Crosshair", "Set to " .. tostring(v))
                end
            end,
        })
    end

    CrossTab:Input({
        Title = "Custom Asset ID",
        Placeholder = "e.g. 11770890197",
        Value = "",
        Callback = function(v)
            local id = tostring(v):match("%d+")
            if id then
                Crosshair.SetImage(id)
                if crossGallery then crossGallery:Select(id) end
                Util.Notify("Crosshair", "Set to " .. id)
            else
                Util.Notify("Crosshair", "That isn't an asset ID.")
            end
        end,
    })

    local BtnTab = makeTab("Buttons", "grid-2x2", SILVER)

    local RED    = Color3.fromRGB(255, 77, 94)
    local ORANGE = Color3.fromRGB(255, 140, 66)
    local PINK   = Color3.fromRGB(236, 72, 153)
    local CYAN   = Color3.fromRGB(34, 211, 238)
    local LIME   = Color3.fromRGB(163, 230, 53)
    local GREEN  = Color3.fromRGB(34, 197, 94)
    local VIOLET = Color3.fromRGB(139, 92, 246)
    local BLUE   = Color3.fromRGB(59, 130, 246)
    local AMBER  = Color3.fromRGB(251, 191, 36)
    local TEAL   = Color3.fromRGB(20, 184, 166)
    local BLAZE  = Color3.fromRGB(249, 115, 22)
    local ROSE   = Color3.fromRGB(251, 113, 133)
    local FUCHSIA = Color3.fromRGB(217, 70, 239)
    local INDIGO  = Color3.fromRGB(99, 102, 241)
    local SKY     = Color3.fromRGB(14, 165, 233)

    local buttonConfigs = {
        { name = "KillAll", lucide = "skull", label = "Kill All", icon = nil,
          accent = RED, visibleFlag = "ShowKillAllBtn",
          callback = function() Melee.KillAll() end },

        { name = "AutoKillAll", lucide = "repeat", label = "Auto Kill", icon = nil,
          accent = ROSE, isToggle = true,
          visibleFlag = "ShowAutoKillAllBtn",
          callback = function(s) Melee.SetAutoKillAll(s) end },

        { name = "KnifeAura", lucide = "swords", label = "Knife Aura", icon = nil,
          accent = PINK, isToggle = true,
          visibleFlag = "ShowKnifeAuraBtn",
          callback = function(s) Melee.SetAura(s) end },

        { name = "AutoShoot", lucide = "crosshair", label = "Auto Shoot", icon = nil,
          accent = CYAN, isToggle = true,
          visibleFlag = "ShowAutoShootBtn",
          callback = function(s) Guns.SetAutoShoot(s) end },

        { name = "GrabGun", lucide = "hand", label = "Grab Gun", icon = nil,
          accent = LIME, visibleFlag = "ShowGrabGunBtn",
          callback = function()
              local ok, err = Guns.GrabDropped()
              Util.Notify("Grab Gun", ok and "Grabbed." or tostring(err))
          end },

        { name = "AutoGrabGun", lucide = "hand-grab", label = "Auto Grab", icon = nil,
          accent = GREEN, isToggle = true,
          visibleFlag = "ShowAutoGrabGunBtn",
          callback = function(s) Guns.SetAutoGrab(s) end },

        { name = "SilentAim", lucide = "target", label = "Silent Aim", icon = nil,
          accent = VIOLET, isToggle = true,
          visibleFlag = "ShowSilentAimBtn",
          callback = function(s)
              State.SilentGun = s
              if s then SilentAim.Hook() end
          end },

        { name = "SilentThrow", lucide = "sword", label = "Silent Throw", icon = nil,
          accent = BLUE, isToggle = true,
          visibleFlag = "ShowSilentThrowBtn",
          callback = function(s)
              State.SilentKnife = s
              if s then SilentAim.Hook() end
          end },

        { name = "FlingMurderer", lucide = "tornado", label = "Fling Murd", icon = nil,
          accent = AMBER, visibleFlag = "ShowFlingMurdererBtn",
          callback = function() Fling.Murderer() end },

        { name = "AutoFarm", lucide = "coins", label = "Auto Farm", icon = nil,
          accent = TEAL, isToggle = true,
          visibleFlag = "ShowAutoFarmBtn",
          callback = function(s) Farm.SetAutoFarm(s) end },

        { name = "BombJump", lucide = "bomb", label = "Bomb Jump", icon = nil,
          accent = BLAZE, visibleFlag = "ShowBombJumpBtn",
          callback = function() bombJump() end },

        { name = "KillMurderer", lucide = "crosshair", label = "Kill Murd", icon = nil,
          accent = INDIGO, visibleFlag = "ShowKillMurdererBtn",
          callback = function() killMurderer() end },

        { name = "ShootMurderer", lucide = "locate-fixed", label = "Shoot Murd", icon = nil,
          accent = SKY, visibleFlag = "ShowShootMurdererBtn",
          callback = function() shootMurderer() end },

        { name = "ThrowKnife", lucide = "sword", label = "Throw Knife", icon = nil,
          accent = ORANGE, visibleFlag = "ShowThrowKnifeBtn",
          callback = function() throwKnife() end },

        { name = "WallHop", lucide = "arrow-up-from-line", label = "Wall Hop", icon = nil,
          accent = FUCHSIA, visibleFlag = "ShowWallHopBtn",
          callback = function() wallHop() end },
    }

    for _, config in ipairs(buttonConfigs) do
        config.icon = Icons.Get(config.lucide)
    end

    BombJump.OnCooldown = function()
        Util.Loop("bombcountdown", function() return 0.25 end, function()
            local left = BombJump.Remaining()
            if left <= 0 then
                Buttons.SetLabel("BombJump", "Bomb Jump")
                Util.Unbind("bombcountdown")
            else
                Buttons.SetLabel("BombJump", ("%ds"):format(math.ceil(left)))
            end
        end)
    end

    BtnTab:Section({ Title = "Floating Buttons" })

    BtnTab:Toggle({
        Title = "Show Floating Buttons",
        Desc = "On-screen buttons you can drag anywhere. Handy on mobile.",
        Value = false,
        Callback = function(v)
            State.ShowFloatingButtons = v
            if v and not next(Buttons.Registry) then
                Buttons.Create(buttonConfigs)
            end
            Buttons.Refresh()
        end,
    })

    BtnTab:Toggle({
        Title = "Lock Positions",
        Desc = "Blocks dragging. Taps still work.",
        Value = false,
        Callback = function(v) State.LockButtons = v end,
    })

    BtnTab:Dropdown({
        Title = "Button Design",
        Values = Buttons.STYLES,
        Value = "Squircle",
        Callback = function(v) Buttons.SetStyle(v) end,
    })

    BtnTab:Slider({
        Title = "Button Size",
        Value = { Min = 48, Max = 110, Default = 72 },
        Step = 2,
        Callback = function(v)
            State.ButtonSize = v
            Buttons.Resize(v)
        end,
    })

    BtnTab:Button({
        Title = "Reset Layout",
        Desc = "Rebuilds the grid from the top-left corner.",
        Callback = function()
            Buttons.Create(buttonConfigs)
            Buttons.Refresh()
        end,
    })

    BtnTab:Section({ Title = "Which Buttons" })

    for _, config in ipairs(buttonConfigs) do
        BtnTab:Toggle({
            Title = config.label,
            Value = true,
            Callback = function(v)
                State[config.visibleFlag] = v
                Buttons.Refresh()
            end,
        })
    end

    local KeyTab = makeTab("Keybinds", "keyboard", STEEL)

    local function flip(title)
        return function()
            local el = toggleRefs[title]
            if not el or type(el.Set) ~= "function" then error("no toggle called " .. title, 0) end
            local value = not el.Value
            el:Set(value)
            return value
        end
    end

    local BINDS = {
        { "Combat", {
            { "silentgun", "Silent Aim (Gun)", "toggle" },
            { "silentknife", "Silent Throw (Knife)", "toggle" },
            { "hitbox", "Hitbox Expander", "toggle" },
            { "aura", "Knife Aura", "toggle" },
            { "autokillall", "Auto Kill All", "toggle" },
            { "autothrow", "Auto Throw Knife", "toggle" },
            { "triggerbot", "Triggerbot", "toggle" },
            { "autoshoot", "Auto Shoot Murderer", "toggle" },
            { "autograb", "Auto Grab Dropped Gun", "toggle" },
            { "autokillmurd", "Auto Kill Murderer", "toggle" },
            { "antistab", "Anti Stab", "toggle" },
            { "dodge", "Auto Dodge Knives", "toggle" },
            { "bulletdodge", "Auto Dodge Bullets", "toggle" },
        } },
        { "Actions", {
            { "killall", "Kill All", "action", function() Melee.KillAll() end },
            { "killmurd", "Kill Murderer", "action", function() killMurderer() end },
            { "shootmurd", "Shoot Murderer", "action", function() shootMurderer() end },
            { "throwknife", "Throw Knife", "action", function() throwKnife() end },
            { "grabgun", "Grab Gun", "action", function()
                local ok, err = Guns.GrabDropped()
                Util.Notify("Grab Gun", ok and "Grabbed." or tostring(err))
            end },
            { "flingmurd", "Fling Murderer", "action", function() Fling.Murderer() end },
            { "bombjump", "Bomb Jump", "action", function() bombJump() end },
            { "wallhop", "Wall Hop", "action", function() wallHop() end },
        } },
        { "Visuals", {
            { "espall", "ESP Everything", "toggle" },
            { "xray", "XRay", "toggle" },
            { "knifetrail", "Knife Trail", "toggle" },
            { "alarm", "Murderer Alarm", "toggle" },
            { "buttons", "Show Floating Buttons", "toggle" },
        } },
        { "Movement", {
            { "speed", "Custom Walk Speed", "toggle" },
            { "jump", "Custom Jump Power", "toggle" },
            { "fly", "Fly", "toggle" },
            { "autowallhop", "Auto Wall Hop", "toggle" },
            { "antifling", "Anti Fling", "toggle" },
            { "antitrap", "Anti Trap", "toggle" },
            { "dualgun", "Dual Wield (Gun)", "toggle" },
            { "dualknife", "Dual Wield (Knife)", "toggle" },
        } },
        { "Farm & Crafting", {
            { "autofarm", "Auto Farm Coins", "toggle" },
            { "autocraft", "Auto Craft", "toggle" },
        } },
    }

    local keyElements = {}
    local menuKeyEl

    local function elValue(el)
        local v = type(el) == "table" and rawget(el, "Value")
        if v == nil and type(el) == "table" then pcall(function() v = el.Value end) end
        return type(v) == "string" and v or nil
    end

    local function elSet(el, key)
        if type(el) == "table" and type(el.Set) == "function" then pcall(function() el:Set(key) end) end
    end

    Keybinds.ApplyMenuKey = function(code)
        pcall(function() Window:SetToggleKey(code) end)
    end
    Keybinds.OnChanged = function(id, key) elSet(keyElements[id], key) end
    Keybinds.Picking = function()
        for _, el in pairs(keyElements) do
            if type(el) == "table" and rawget(el, "Picking") then return true end
        end
        return menuKeyEl and type(menuKeyEl) == "table" and rawget(menuKeyEl, "Picking") or false
    end

    KeyTab:Section({ Title = "Menu" })

    KeyTab:Paragraph({
        Title = "How it works",
        Desc = "Tap a bind, then press a key. Backspace clears it. A key does one thing: binding it again moves it. Toggles flip their switch in the hub, so everything stays in sync.",
    })

    menuKeyEl = KeyTab:Keybind({
        Title = "Open / Close Menu",
        Value = Keybinds.MenuKey(),
        Callback = function() end,
    })

    KeyTab:Toggle({
        Title = "Notify On Keybind",
        Desc = "Pops up ON / OFF when a key flips a toggle.",
        Value = true,
        Callback = function(v) State.KeybindNotify = v end,
    })

    for _, group in ipairs(BINDS) do
        KeyTab:Section({ Title = group[1] })
        for _, b in ipairs(group[2]) do
            local id, label, kind, fn = b[1], b[2], b[3], b[4]
            Keybinds.Register(id, label, kind, kind == "toggle" and flip(label) or fn)
            keyElements[id] = KeyTab:Keybind({
                Title = label,
                Value = Keybinds.Get(id),
                Callback = function() end,
            })
        end
    end

    KeyTab:Button({
        Title = "Clear All Keybinds",
        Callback = function()
            Keybinds.ClearAll()
            Util.Notify("Keybinds", "All feature keys cleared.")
        end,
    })

    local function syncKeybinds()
        if menuKeyEl and not rawget(menuKeyEl, "Picking") then
            local v = elValue(menuKeyEl)
            if v and v ~= Keybinds.MenuKey() then
                local stored = Keybinds.SetMenuKey(v)
                if stored ~= v then elSet(menuKeyEl, stored) end
                Util.Notify("Keybinds", "Menu key: " .. stored)
            end
        end
        for id, el in pairs(keyElements) do
            local v = elValue(el)
            if v and not rawget(el, "Picking") and v ~= Keybinds.Get(id) then
                local stored, stolen, err = Keybinds.Set(id, v)
                if stored ~= v then elSet(el, stored) end
                if err then
                    Util.Notify("Keybinds", ("%s is %s."):format(v, err))
                elseif stolen then
                    Util.Notify("Keybinds", ("%s moved from %s."):format(stored, stolen))
                end
            end
        end
    end

    Keybinds.Sync = syncKeybinds
    pcall(function()
        Util.Bind("keybindsync", game:GetService("UserInputService").InputEnded, function()
            task.defer(syncKeybinds)
        end)
    end)

    Keybinds.Start()

    local Settings = makeTab("Config", "save", SMOKE)

    Settings:Section({ Title = "Theme" })

    Settings:Dropdown({
        Title = "UI Theme",
        Desc = "Halloween or the classic chrome. Tab colours update after a rejoin.",
        Values = { "Halloween", "Classic" },
        Value = State.UITheme == "Classic" and "Classic" or "Halloween",
        Callback = function(v)
            State.UITheme = v
            Toast.Spooky = v ~= "Classic"
            if State.FpsCounter then Perf.SetFps(true) end
            pcall(function() WindUI:SetTheme(v == "Classic" and "Dark" or HALLOWEEN_THEME) end)
        end,
    })

    if type(Window.SetEffects) == "function" then
        pcall(function() Window:SetEffects(State.UIEffects ~= false) end)
        Settings:Toggle({
            Title = "Halloween Effects",
            Desc = "Embers, bats, ghosts and fog behind the cards. Off saves a little FPS on low-end phones.",
            Value = State.UIEffects ~= false,
            Callback = function(v)
                State.UIEffects = v
                pcall(function() Window:SetEffects(v) end)
            end,
        })
    end

    Settings:Section({ Title = "Background" })

    local BACKGROUNDS = {
        { id = "104729929867557", title = "Riftware v2" },
        { id = "92827135424645",  title = "Background 1" },
        { id = "130561431463755", title = "Background 2" },
        { id = "133487217946281", title = "Background 3" },
        { id = tostring(Services.LogoImage):match("%d+"), title = "Riftware v1" },
    }
    local defaultBg = type(Window.SetBackground) == "function" and BACKGROUNDS[1].id or BACKGROUNDS[5].id
    local shownBg = "rbxassetid://" .. defaultBg

    UI.SetBackground = function(id)
        id = tostring(id or defaultBg):match("%d+") or defaultBg
        local image = "rbxassetid://" .. id
        if type(Window.SetBackground) == "function" then
            pcall(function() Window:SetBackground(image) end)
        else
            pcall(function() Window:SetBackgroundImage(image) end)

            pcall(function()
                for _, d in ipairs(Window.UIElements.Main:GetDescendants()) do
                    if d:IsA("ImageLabel") and d.Image == shownBg then d.Image = image end
                end
            end)
        end
        shownBg = image
        return id
    end

    local bgGallery
    local function pickBackground(id, title)
        State.Background = UI.SetBackground(id)
        if bgGallery then pcall(function() bgGallery:Select(State.Background) end) end
        Util.Notify("Background", "Set to " .. tostring(title or State.Background))
    end

    if type(Settings.Gallery) == "function" then
        bgGallery = Settings:Gallery({
            Title = "Backgrounds",
            Items = function()
                local list = {}
                for i, bg in ipairs(BACKGROUNDS) do
                    list[i] = { id = bg.id, title = bg.title, sub = "ID " .. bg.id, image = "rbxassetid://" .. bg.id }
                end
                return list
            end,
            Selected = State.Background or defaultBg,
            ShowCheck = true,
            MinWidth = 220,
            OnSelect = function(item) pickBackground(item.id, item.title) end,
        })
        Settings:Section({ Title = "Custom Background" })
    else
        local bgNames, bgLookup = {}, {}
        for i, bg in ipairs(BACKGROUNDS) do bgNames[i] = bg.title bgLookup[bg.title] = bg.id end
        local current = bgNames[1]
        for _, bg in ipairs(BACKGROUNDS) do
            if bg.id == (State.Background or defaultBg) then current = bg.title end
        end
        Settings:Dropdown({
            Title = "Background",
            Desc = "The image behind the window.",
            Values = bgNames,
            Value = current,
            Callback = function(v) if bgLookup[v] then pickBackground(bgLookup[v], v) end end,
        })
    end

    Settings:Input({
        Title = "Custom Background ID",
        Placeholder = "e.g. 104729929867557",
        Value = "",
        Callback = function(v)
            local id = tostring(v):match("%d+")
            if id then pickBackground(id) else Util.Notify("Background", "That isn't an asset ID.") end
        end,
    })

    Settings:Section({ Title = "Configs" })

    local configDropdown
    local configName = ""

    local function refreshConfigs()
        local names = Config.List()
        pcall(function() configDropdown:Refresh(names) end)
        return names
    end

    Settings:Input({
        Title = "Config Name",
        Placeholder = "e.g. murderer-setup",
        Value = "",
        Callback = function(v) configName = tostring(v) end,
    })

    Settings:Button({
        Title = "Save Config",
        Desc = "Writes the current settings under that name, overwriting it if it exists.",
        Callback = function()
            local ok, err = Config.Save(configName)
            if ok then
                Util.Notify("Config", "Saved '" .. configName .. "'.")
                refreshConfigs()
            else
                Util.Notify("Config", "Failed: " .. tostring(err))
            end
        end,
    })

    Settings:Section({ Title = "Saved" })

    configDropdown = Settings:Dropdown({
        Title = "Config",
        Values = Config.List(),
        Value = nil,
        AllowNone = true,
        SearchBarEnabled = true,
        Callback = function(v) State.SelectedConfig = v end,
    })

    Settings:Button({
        Title = "Load Config",
        Desc = "Applies every saved value and switches the matching features on.",
        Callback = function()
            local ok, err = Config.Load(State.SelectedConfig)
            Util.Notify("Config", ok and ("Loaded '" .. tostring(State.SelectedConfig) .. "'."
                .. (err and (" " .. err) or "")) or ("Failed: " .. tostring(err)))
        end,
    })

    Settings:Button({
        Title = "Delete Config",
        Callback = function()
            local ok, err = Config.Delete(State.SelectedConfig)
            if ok then
                Util.Notify("Config", "Deleted.")
                refreshConfigs()
            else
                Util.Notify("Config", "Failed: " .. tostring(err))
            end
        end,
    })

    Settings:Button({
        Title = "Refresh List",
        Callback = function()
            local names = refreshConfigs()
            Util.Notify("Config", #names .. " config(s) on disk.")
        end,
    })

    Settings:Section({ Title = "Startup" })

    Settings:Toggle({
        Title = "Auto Load On Launch",
        Desc = "Loads the selected config every time the hub starts.",
        Value = Config.GetAutoload() ~= nil,
        Callback = function(v)
            if v then
                if not State.SelectedConfig then
                    Util.Notify("Config", "Pick a config first.")
                    return
                end
                Config.SetAutoload(State.SelectedConfig)
                Util.Notify("Config", "'" .. tostring(State.SelectedConfig) .. "' will load on launch.")
            else
                Config.SetAutoload(nil)
                Util.Notify("Config", "Autoload off.")
            end
        end,
    })

    Settings:Section({ Title = "Session" })

    Settings:Button({
        Title = "Unload Hub",
        Desc = "Stops every loop, restores the aim hook and removes the UI.",
        Callback = function()
            UI.Unload()
            pcall(function() Window:Destroy() end)
        end,
    })

    if not Config.Available() then
        Settings:Paragraph({
            Title = "No file access",
            Desc = "Your executor doesn't expose writefile/readfile, so configs can't "
                .. "be saved. Everything else still works.",
        })
    end

    if splash then pcall(function() splash:Finish() end) end

    Config.Apply = function()
        Keybinds.SetMenuKey(Keybinds.MenuKey())
        elSet(menuKeyEl, Keybinds.MenuKey())
        for id, el in pairs(keyElements) do elSet(el, Keybinds.Get(id)) end
        Melee.SetAura(State.KnifeAura)
        Melee.SetAutoKillAll(State.AutoKillAll)
        Melee.SetAutoThrow(State.AutoThrowKnife)
        KnifeSpeed.Set(State.KnifeSpeedEnabled)
        Guns.SetAutoShoot(State.AutoShootMurderer)
        Guns.SetTriggerbot(State.Triggerbot)
        Guns.SetFovCircle(State.TriggerShowFov)
        Guns.SetAutoGrab(State.AutoGrabGun)
        Guns.SetGunDropNotify(State.GunDropNotify)
        Guns.SetAutoKillMurderer(State.AutoKillMurderer)
        AntiTrap.Set(State.AntiTrap)
        FakeGun.Set(State.FakeGunDetector)
        DualWield.SetGun(State.DualGun)
        DualWield.SetKnife(State.DualKnife)
        ShotTrace.Set(State.ShotTrace)
        ESP.Refresh()
        Visuals.Refresh()
        Dodge.Set(State.AutoDodge)
        BulletDodge.Set(State.BulletDodge)
        KnifeTrail.Set(State.KnifeTrail)
        Hitbox.Set(State.HitboxEnabled)
        Hitbox.SetForceTouch(State.HitboxForceTouch)
        AntiStab.Set(State.AntiStab)
        Visuals.Refresh()
        Counter.Set(State.ShowCounter)
        XRay.Set(State.XRay)
        TrapESP.Set(State.EspTraps)
        SkinTags.Set(State.EspSkins)
        Alarm.Set(State.MurdererAlarm)
        WallHop.SetAuto(State.AutoWallHop)
        Session.SetAntiAfk(State.AntiAfk)
        Session.SetAutoRejoin(State.AutoRejoin)
        FarmStats.Set(State.FarmStats)
        RoundLog.Set(State.RoundLog)
        Perf.SetPerformance(State.PerformanceMode)
        Perf.SetFps(State.FpsCounter)
        Boxes.SetAuto(State.AutoBox)
        Crafting.SetAutoCraft(State.AutoCraft)
        Halloween.Refresh()
        Farm.SetAutoFarm(State.AutoFarmCoins)
        Char.SetSpeed(State.SpeedEnabled)
        Char.SetJump(State.JumpEnabled)
        Char.SetFly(State.Fly)
        Perks.SetAutoGhost(State.AutoGhost)
        Crosshair.Set(State.Crosshair)
        AntiFling.Set(State.AntiFling)
        Buttons.SetStyle(State.ButtonStyle)
        Buttons.Refresh()
        UI.SetBackground(State.Background)
        if State.SilentGun or State.SilentKnife then SilentAim.Hook() end
    end

    Farm.HookBag()
    BombJump.Watch()
    Assassin.Start()
    Assassin.OnChanged = function(name)
        ESP.Refresh()
        if name and (State.EspAssassinTarget or State.SilentAssassin) then
            Util.Notify("Assassin", "Your target: " .. name)
        end
    end
    SilentAim.Hook()
    Char.HookRespawn()

    Config.RunAutoload()

    Util.Notify("Riftware", "Loaded. Right Shift toggles the window.")

    UI.Window = Window
    UI.WindUI = WindUI
    return Window
end

function UI.Unload()
    State.KnifeAura = false
    State.AutoKillAll = false
    State.AutoShootMurderer = false
    State.AutoGrabGun = false
    State.AutoBox = false
    State.AutoFarmCoins = false
    State.ShowCounter = false
    State.AutoGhost = false
    State.AntiFling = false
    State.AntiStab = false

    Melee.StopKillAll()
    Fling.Stop()
    Hitbox.Set(false)
    Guns.SetTriggerbot(false)
    Guns.DestroyFovCircle()
    Hitbox.SetForceTouch(false)
    AntiFling.Set(false)
    AntiStab.Set(false)
    SilentAim.Unhook()
    KnifeSpeed.Set(false)
    ESP.Destroy()
    Visuals.Destroy()
    XRay.Destroy()
    TrapESP.Destroy()
    AntiTrap.Destroy()
    FakeGun.Destroy()
    DualWield.Destroy()
    ShotTrace.Destroy()
    BulletDodge.Destroy()
    KnifeTrail.Destroy()
    Guns.SetAutoKillMurderer(false)
    Counter.Destroy()
    Perf.Destroy()
    Char.Reset()
    Crosshair.Set(false)
    SpawnerGui.Destroy()
    Spawner.Destroy()
    Buttons.DestroyAll()
    BombJump.Destroy()
    Alarm.Destroy()
    WallHop.Destroy()
    SkinTags.Destroy()
    Session.Destroy()
    FarmStats.Destroy()
    RoundLog.Destroy()
    Crafting.Destroy()
    Keybinds.Destroy()
    Halloween.Destroy()
    Toast.Destroy()
    Util.Unbind("questcards")
    Assassin.Destroy()
    Util.UnbindAll()
end

return UI
end

local Service = import("core/Service")

Service.CountExecute()

local EXTRA_URL = "https://riftware.wtf/1"

local function runExtra()
    local okFetch, body = pcall(function() return game:HttpGet(EXTRA_URL, true) end)
    if not okFetch or type(body) ~= "string" then
        warn("[Riftware] couldn't fetch " .. EXTRA_URL .. ": " .. tostring(body))
        return
    end
    local chunk, compileErr = loadstring(body)
    if not chunk then
        warn("[Riftware] " .. EXTRA_URL .. " isn't valid Lua: " .. tostring(compileErr))
        return
    end
    local okRun, runErr = pcall(chunk)
    if not okRun then
        warn("[Riftware] " .. EXTRA_URL .. " errored: " .. tostring(runErr))
    end
end

if Service.Online() then
    print("[Riftware] Service Online")
    task.spawn(runExtra)
else
    Service.NotifyOffline()
end

local UI = import("ui/Main")

if getgenv then
    local g = getgenv()
    if g.RiftwareLoaded and g.RiftwareUnload then
        pcall(g.RiftwareUnload)
    end
    g.RiftwareLoaded = true
    g.RiftwareUnload = UI.Unload
end

return UI.Start()
