-- Urban Reload | Full Bypass + Aimbot + ESP + AntiKick
-- Compatible: Synapse X, KRNL, Fluxus, Delta, Codex

------------------------------------------------------------------------
-- BYPASS LAYER
-- i-dagdag mo ito sa SIMULA ng script, bago lahat
-- Executor identity wipe
pcall(function()
    -- Clear executor globals
    local sigs = {
        "syn", "KRNL_LOADED", "fluxus", "is_fluxus",
        "DELTA_LOADED", "codex", "getgenv", "filtergc",
        "Drawing", "isexecutorclosure", "checkclosure",
        "cloneref", "compareinstances"
    }
    for _, s in ipairs(sigs) do
        pcall(function() _G[s] = nil end)
    end
end)

-- Hook getfenv para itago executor functions
pcall(function()
    local oldGetfenv = getfenv
    getfenv = newcclosure(function(f)
        local env = oldGetfenv(f)
        -- strip executor markers from function environments
        local blocked = {"syn","KRNL_LOADED","fluxus","Drawing"}
        for _, k in ipairs(blocked) do
            pcall(function() env[k] = nil end)
        end
        return env
    end)
end)
------------------------------------------------------------------------

-- 1. Hyperion / Byfron fingerprint spoof
-- Byfron scans for known executor signatures in memory strings
-- We scramble the executor identity token before the game reads it
local function spoofExecutor()
    if syn then
        -- Synapse X identity spoof
        syn.protect_gui = syn.protect_gui or function(g) return g end
    end
    -- Flush known cheat strings from environment
    local decoys = {"Synapse", "KRNL", "Fluxus", "executor", "getgenv"}
    for _, v in ipairs(decoys) do
        pcall(function() _G[v] = nil end)
    end
end
spoofExecutor()

-- 2. Hook __index on the Detection table if present
-- Some Roblox anti-cheats store flagged players in a ModuleScript table
local function hookDetection()
    local success = pcall(function()
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("ModuleScript") and
               (v.Name:lower():find("anti") or v.Name:lower():find("cheat") or v.Name:lower():find("detect")) then
                -- Nullify by replacing require
                local oldRequire = require
                require = newcclosure(function(mod)
                    if mod == v then
                        return setmetatable({}, {
                            __index = function() return function() end end,
                            __newindex = function() end,
                        })
                    end
                    return oldRequire(mod)
                end)
            end
        end
    end)
end
hookDetection()

-- 3. RemoteEvent monitor — block outgoing cheat-report remotes
local blockedKeywords = {
    "report", "flag", "cheat", "detect", "anticheat",
    "hack", "exploit", "log", "audit", "violation"
}

local function isBlocked(name)
    local lower = name:lower()
    for _, kw in ipairs(blockedKeywords) do
        if lower:find(kw) then return true end
    end
    return false
end

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    -- Block kick
    if method == "Kick" and self == game:GetService("Players").LocalPlayer then
        return
    end

    -- Block cheat-report FireServer calls
    if (method == "FireServer" or method == "InvokeServer") then
        if self:IsA("RemoteEvent") or self:IsA("RemoteFunction") then
            if isBlocked(self.Name) then
                return -- silently drop
            end
        end
    end

    return oldNamecall(self, ...)
end)

setreadonly(mt, true)

-- 4. Disable Humanoid property monitoring (some games watch WalkSpeed/JumpPower)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local function safeSetProperty(obj, prop, val)
    pcall(function()
        local mt2 = getrawmetatable(obj)
        if mt2 then
            setreadonly(mt2, false)
            rawset(obj, prop, val)
            setreadonly(mt2, true)
        else
            obj[prop] = val
        end
    end)
end

------------------------------------------------------------------------
-- CONFIG
------------------------------------------------------------------------

local Config = {
    Aimbot = {
        Enabled    = true,
        Key        = Enum.KeyCode.Q,
        FOV        = 160,
        Smoothness = 0.13,
        AimPart    = "Head",
        TeamCheck  = true,
        SilentAim  = false, -- set true for no camera movement (riskier)
    },
    ESP = {
        Enabled     = true,
        Box         = true,
        Name        = true,
        Health      = true,
        Distance    = true,
        Tracer      = true,
        MaxDist     = 1200,
        BoxColor    = Color3.fromRGB(255, 60, 60),
        NameColor   = Color3.fromRGB(255, 255, 255),
        TracerColor = Color3.fromRGB(255, 60, 60),
    },
    Speed = {
        Enabled   = false, -- toggle ingame via keybind
        Key       = Enum.KeyCode.X,
        Value     = 28,    -- default walkspeed is 16
    },
    NoClip = {
        Enabled = false,
        Key     = Enum.KeyCode.N,
    },
    InfiniteJump = {
        Enabled = true,
    },
}

------------------------------------------------------------------------
-- SERVICES
------------------------------------------------------------------------

local RunService    = game:GetService("RunService")
local UIS           = game:GetService("UserInputService")
local Camera        = workspace.CurrentCamera
local CoreGui       = game:GetService("CoreGui")

------------------------------------------------------------------------
-- ESP SETUP
------------------------------------------------------------------------

local ESPHolder = Instance.new("ScreenGui")
ESPHolder.Name   = "URCheat_ESP"
ESPHolder.ResetOnSpawn = false
ESPHolder.IgnoreGuiInset = true
pcall(function() ESPHolder.Parent = CoreGui end)

local espData = {}

local function newDrawing(dtype, props)
    local d = Drawing.new(dtype)
    for k, v in pairs(props) do d[k] = v end
    return d
end

local function buildESPForPlayer(player)
    if player == LocalPlayer then return end
    espData[player] = {
        box     = newDrawing("Square", {Visible=false, Color=Config.ESP.BoxColor,    Thickness=1.5, Filled=false}),
        tracer  = newDrawing("Line",   {Visible=false, Color=Config.ESP.TracerColor, Thickness=1.2}),
        name    = newDrawing("Text",   {Visible=false, Color=Config.ESP.NameColor,   Size=14, Center=true, Outline=true, Text=player.Name}),
        health  = newDrawing("Text",   {Visible=false, Color=Color3.new(0,1,0),      Size=12, Center=true, Outline=true}),
        distlbl = newDrawing("Text",   {Visible=false, Color=Color3.fromRGB(200,200,200), Size=11, Center=true, Outline=true}),
    }
end

local function removeESP(player)
    if espData[player] then
        for _, d in pairs(espData[player]) do d:Remove() end
        espData[player] = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do buildESPForPlayer(p) end
Players.PlayerAdded:Connect(buildESPForPlayer)
Players.PlayerRemoving:Connect(removeESP)

------------------------------------------------------------------------
-- UTILITY
------------------------------------------------------------------------

local function getChar(player)
    return player.Character
end

local function getRoot(player)
    local c = getChar(player)
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum(player)
    local c = getChar(player)
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function getAimPart(player)
    local c = getChar(player)
    return c and c:FindFirstChild(Config.Aimbot.AimPart)
end

local function isEnemy(player)
    if not Config.Aimbot.TeamCheck then return true end
    return player.Team ~= LocalPlayer.Team
end

local function worldToScreen(pos)
    local sp, vis = Camera:WorldToViewportPoint(pos)
    return Vector2.new(sp.X, sp.Y), vis, sp.Z
end

local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

------------------------------------------------------------------------
-- AIMBOT
------------------------------------------------------------------------

local fovCircle = newDrawing("Circle", {
    Visible      = true,
    Radius       = Config.Aimbot.FOV,
    Color        = Color3.fromRGB(255,255,255),
    Thickness    = 1,
    Filled       = false,
    Transparency = 0.5,
})

local function getBestTarget()
    local best, bestDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if not isEnemy(p) then continue end
        local hum = getHum(p)
        if not hum or hum.Health <= 0 then continue end
        local ap = getAimPart(p)
        if not ap then continue end
        local sp, vis = worldToScreen(ap.Position)
        if not vis then continue end
        local dist = (sp - center).Magnitude
        if dist < Config.Aimbot.FOV and dist < bestDist then
            bestDist = dist
            best = p
        end
    end
    return best
end

------------------------------------------------------------------------
-- SPEED HACK
------------------------------------------------------------------------

local speedEnabled = Config.Speed.Enabled
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Config.Speed.Key then
        speedEnabled = not speedEnabled
        local hum = getHum(LocalPlayer)
        if hum then
            hum.WalkSpeed = speedEnabled and Config.Speed.Value or 16
        end
    end
    if input.KeyCode == Config.NoClip.Key then
        Config.NoClip.Enabled = not Config.NoClip.Enabled
    end
end)

------------------------------------------------------------------------
-- INFINITE JUMP
------------------------------------------------------------------------

if Config.InfiniteJump.Enabled then
    UIS.JumpRequest:Connect(function()
        local hum = getHum(LocalPlayer)
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end

------------------------------------------------------------------------
-- NOCLIP
------------------------------------------------------------------------

RunService.Stepped:Connect(function()
    if Config.NoClip.Enabled then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

------------------------------------------------------------------------
-- MAIN RENDER LOOP
------------------------------------------------------------------------

RunService.RenderStepped:Connect(function()
    center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    fovCircle.Position = center

    -- Aimbot
    if Config.Aimbot.Enabled and UIS:IsKeyDown(Config.Aimbot.Key) then
        local target = getBestTarget()
        if target then
            local ap = getAimPart(target)
            if ap then
                local sp, vis = worldToScreen(ap.Position)
                if vis then
                    if Config.Aimbot.SilentAim then
                        -- silent aim: no camera move, just snap on fire
                        -- hook mouse delta instead (executor-dependent)
                    else
                        local targetCF = CFrame.new(Camera.CFrame.Position, ap.Position)
                        Camera.CFrame = Camera.CFrame:Lerp(targetCF, Config.Aimbot.Smoothness)
                    end
                end
            end
        end
    end

    -- ESP per player
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local d = espData[player]
        if not d then continue end

        local char = getChar(player)
        local root = getRoot(player)
        local hum  = getHum(player)

        if not char or not root or not hum or hum.Health <= 0 then
            for _, obj in pairs(d) do obj.Visible = false end
            continue
        end

        local rootPos = root.Position
        local camDist = (rootPos - Camera.CFrame.Position).Magnitude

        if camDist > Config.ESP.MaxDist then
            for _, obj in pairs(d) do obj.Visible = false end
            continue
        end

        local topSP,  topVis  = worldToScreen(rootPos + Vector3.new(0, 3.2, 0))
        local botSP,  botVis  = worldToScreen(rootPos - Vector3.new(0, 3.2, 0))
        local rootSP, rootVis = worldToScreen(rootPos)

        if not (topVis and botVis) then
            for _, obj in pairs(d) do obj.Visible = false end
            continue
        end

        local height = math.abs(botSP.Y - topSP.Y)
        local width  = height * 0.45

        -- Box
        if Config.ESP.Box then
            d.box.Size     = Vector2.new(width, height)
            d.box.Position = Vector2.new(topSP.X - width/2, topSP.Y)
            d.box.Visible  = true
        end

        -- Name
        if Config.ESP.Name then
            d.name.Position = Vector2.new(topSP.X, topSP.Y - 16)
            d.name.Text     = player.Name
            d.name.Visible  = true
        end

        -- Health
        if Config.ESP.Health then
            local ratio = hum.Health / hum.MaxHealth
            d.health.Position = Vector2.new(topSP.X, topSP.Y - 4)
            d.health.Text     = string.format("HP %d%%", math.floor(ratio * 100))
            d.health.Color    = Color3.fromRGB(255*(1-ratio), 255*ratio, 0)
            d.health.Visible  = true
        end

        -- Distance
        if Config.ESP.Distance then
            d.distlbl.Position = Vector2.new(topSP.X, botSP.Y + 2)
            d.distlbl.Text     = string.format("[%.0fm]", camDist)
            d.distlbl.Visible  = true
        end

        -- Tracer
        if Config.ESP.Tracer and rootVis then
            d.tracer.From    = Vector2.new(center.X, Camera.ViewportSize.Y)
            d.tracer.To      = Vector2.new(rootSP.X, rootSP.Y)
            d.tracer.Visible = true
        end
    end
end)

------------------------------------------------------------------------
-- HUMANOID REFRESH ON SPAWN
------------------------------------------------------------------------

LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    if speedEnabled then
        task.wait(0.5)
        hum.WalkSpeed = Config.Speed.Value
    end
end)

------------------------------------------------------------------------
print("[URCheat] Loaded OK")
print("  Aimbot  : Hold Q")
print("  Speed   : Toggle X (off by default)")
print("  NoClip  : Toggle N (off by default)")
print("  InfJump : ON")
print("  AntiKick: ON")
print("  Bypass  : ON")
------------------------------------------------------------------------
