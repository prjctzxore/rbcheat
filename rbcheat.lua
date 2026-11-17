-- Urban Reload | Full Cheat + CODM-Style Menu UI
-- Compatible: Delta, Fluxus, Codex
-- Load: loadstring(game:HttpGet("YOUR_RAW_URL"))()

------------------------------------------------------------------------
-- BYPASS + NETWORK SPOOF
------------------------------------------------------------------------
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local TweenS     = game:GetService("TweenService")
local HttpS      = game:GetService("HttpService")
local Camera     = workspace.CurrentCamera
local LP         = Players.LocalPlayer
local CoreGui    = game:GetService("CoreGui")

pcall(function()
    for _, s in ipairs({"syn","KRNL_LOADED","fluxus","is_fluxus","DELTA_LOADED","codex","getgenv"}) do
        pcall(function() _G[s] = nil end)
    end
end)

pcall(function()
    local oldReq = require
    require = newcclosure(function(mod)
        if typeof(mod) == "Instance" and mod:IsA("ModuleScript") then
            local n = mod.Name:lower()
            if n:find("anti") or n:find("cheat") or n:find("detect") or n:find("kick") then
                return setmetatable({},{
                    __index    = function() return function() end end,
                    __newindex = function() end,
                })
            end
        end
        return oldReq(mod)
    end)
end)

local blockedKW = {"report","flag","cheat","detect","anticheat","hack","exploit","log","audit","violation","network","ping","latency","anomaly"}
local mt = getrawmetatable(game)
local oldNC = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "Kick" and self == LP then return end
    if method == "FireServer" or method == "InvokeServer" or method == "FireAllClients" then
        local ok, isRemote = pcall(function()
            return self:IsA("RemoteEvent") or self:IsA("RemoteFunction")
        end)
        if ok and isRemote then
            local name = self.Name:lower()
            for _, kw in ipairs(blockedKW) do
                if name:find(kw) then return end
            end
        end
    end
    return oldNC(self, ...)
end)
setreadonly(mt, true)

task.spawn(function()
    while task.wait(math.random(2,5)) do
        pcall(function()
            local _ = LP:GetMouse().Hit
        end)
    end
end)

------------------------------------------------------------------------
-- STATE
------------------------------------------------------------------------
local State = {
    ESP        = false,
    Box        = true,
    Line       = true,
    Health     = true,
    Name       = true,
    Distance   = true,
    Aimbot     = false,
    SilentAim  = false,
    TeamCheck  = true,
    FOV        = 160,
    Smooth     = 13,
    Speed      = false,
    SpeedVal   = 28,
    InfJump    = false,
    NoClip     = false,
}

------------------------------------------------------------------------
-- GUI
------------------------------------------------------------------------
pcall(function()
    if CoreGui:FindFirstChild("URMenu") then
        CoreGui:FindFirstChild("URMenu"):Destroy()
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "URMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LP.PlayerGui end

local Win = Instance.new("Frame")
Win.Name = "Win"
Win.Size = UDim2.new(0, 580, 0, 400)
Win.Position = UDim2.new(0.5, -290, 0.5, -200)
Win.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Win.BorderSizePixel = 0
Win.Parent = ScreenGui
Instance.new("UICorner", Win).CornerRadius = UDim.new(0, 10)

local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(1, 30, 1, 30)
Shadow.Position = UDim2.new(0, -15, 0, -15)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://5554236805"
Shadow.ImageColor3 = Color3.new(0,0,0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(23,23,277,277)
Shadow.ZIndex = -1
Shadow.Parent = Win

------------------------------------------------------------------------
-- TOPBAR
------------------------------------------------------------------------
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 52)
TopBar.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
TopBar.BorderSizePixel = 0
TopBar.Parent = Win

local TBLayout = Instance.new("UIListLayout")
TBLayout.FillDirection = Enum.FillDirection.Horizontal
TBLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TBLayout.Padding = UDim.new(0, 0)
TBLayout.Parent = TopBar

local LogoSec = Instance.new("Frame")
LogoSec.Size = UDim2.new(0, 160, 1, 0)
LogoSec.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
LogoSec.BorderSizePixel = 0
LogoSec.Parent = TopBar

local LogoLbl = Instance.new("TextLabel")
LogoLbl.Size = UDim2.new(1, 0, 1, 0)
LogoLbl.BackgroundTransparency = 1
LogoLbl.Text = "  UR CHEAT"
LogoLbl.TextColor3 = Color3.new(1,1,1)
LogoLbl.Font = Enum.Font.GothamBold
LogoLbl.TextSize = 15
LogoLbl.Parent = LogoSec

local PageTitle = Instance.new("TextLabel")
PageTitle.Size = UDim2.new(1, -300, 1, 0)
PageTitle.BackgroundTransparency = 1
PageTitle.Text = ""
PageTitle.TextColor3 = Color3.fromRGB(200, 200, 210)
PageTitle.Font = Enum.Font.GothamBold
PageTitle.TextSize = 13
PageTitle.TextXAlignment = Enum.TextXAlignment.Left
PageTitle.Visible = false
PageTitle.Parent = TopBar

local FPSlbl = Instance.new("TextLabel")
FPSlbl.Size = UDim2.new(0, 70, 1, 0)
FPSlbl.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
FPSlbl.Text = "FPS\n60"
FPSlbl.TextColor3 = Color3.fromRGB(220, 220, 220)
FPSlbl.Font = Enum.Font.GothamBold
FPSlbl.TextSize = 12
FPSlbl.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 80, 1, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
CloseBtn.Text = "CLOSE"
CloseBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TopBar

------------------------------------------------------------------------
-- SIDEBAR
------------------------------------------------------------------------
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 72, 1, -52)
Sidebar.Position = UDim2.new(0, 0, 0, 52)
Sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Win

local SBLayout = Instance.new("UIListLayout")
SBLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SBLayout.Padding = UDim.new(0, 2)
SBLayout.Parent = Sidebar

Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 8)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -72, 1, -52)
Content.Position = UDim2.new(0, 72, 0, 52)
Content.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Content.BorderSizePixel = 0
Content.ClipsDescendants = true
Content.Parent = Win

------------------------------------------------------------------------
-- DRAG
------------------------------------------------------------------------
local dragging, dragStart, startPos
TopBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or
       inp.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = inp.Position; startPos = Win.Position
    end
end)
UIS.InputChanged:Connect(function(inp)
    if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or
                     inp.UserInputType == Enum.UserInputType.Touch) then
        local d = inp.Position - dragStart
        Win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X,
                                  startPos.Y.Scale, startPos.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or
       inp.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local guiVisible = true
CloseBtn.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    Win.Visible = guiVisible
end)
UIS.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then
        guiVisible = not guiVisible
        Win.Visible = guiVisible
    end
end)

------------------------------------------------------------------------
-- FPS
------------------------------------------------------------------------
local fpsCount = 0
RunService.RenderStepped:Connect(function() fpsCount += 1 end)
task.spawn(function()
    while task.wait(1) do
        FPSlbl.Text = "FPS\n"..fpsCount
        fpsCount = 0
    end
end)

------------------------------------------------------------------------
-- PAGE SYSTEM
------------------------------------------------------------------------
local pages = {}
local tabDescs = {
    Visual = "VISUAL  -  See enemies through walls",
    Combat = "COMBAT  -  Aimbot & aim assist",
    Misc   = "MISC  -  Movement & utility",
}

local function switchTab(name)
    for n, pg in pairs(pages) do pg.Visible = (n == name) end
    PageTitle.Text = tabDescs[name] or name
    PageTitle.Visible = true
end

local function makeSideTab(icon, label, pageName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 60)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    btn.BorderSizePixel = 0
    btn.Text = icon.."\n"..label
    btn.TextColor3 = Color3.fromRGB(160, 160, 180)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(function()
        switchTab(pageName)
        for _, c in ipairs(Sidebar:GetChildren()) do
            if c:IsA("TextButton") then
                TweenS:Create(c, TweenInfo.new(0.1), {
                    BackgroundColor3 = Color3.fromRGB(28,28,36),
                    TextColor3 = Color3.fromRGB(160,160,180)
                }):Play()
            end
        end
        TweenS:Create(btn, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(220,50,50),
            TextColor3 = Color3.new(1,1,1)
        }):Play()
    end)
    return btn
end

local function makePage(name)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = name
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Color3.fromRGB(220,50,50)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.Visible = false
    scroll.Parent = Content
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 0)
    layout.Parent = scroll
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft   = UDim.new(0, 14)
    pad.PaddingRight  = UDim.new(0, 14)
    pad.PaddingTop    = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.Parent = scroll
    pages[name] = scroll
    return scroll
end

------------------------------------------------------------------------
-- WIDGETS
------------------------------------------------------------------------
local function makeHeader(parent, text)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 24)
    f.BackgroundTransparency = 1
    f.Parent = parent
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "| "..text
    lbl.TextColor3 = Color3.fromRGB(180, 180, 200)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
end

local function makeRow(parent, label, stateKey, warningText, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, warningText and 52 or 38)
    row.BackgroundColor3 = Color3.fromRGB(26, 26, 33)
    row.BorderSizePixel = 0
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 0, 20)
    lbl.Position = UDim2.new(0, 12, 0, warningText and 8 or 9)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(220, 220, 230)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row
    if warningText then
        local warn = Instance.new("TextLabel")
        warn.Size = UDim2.new(1, -60, 0, 16)
        warn.Position = UDim2.new(0, 12, 0, 28)
        warn.BackgroundTransparency = 1
        warn.Text = warningText
        warn.TextColor3 = Color3.fromRGB(220, 180, 50)
        warn.Font = Enum.Font.Gotham
        warn.TextSize = 11
        warn.TextXAlignment = Enum.TextXAlignment.Left
        warn.Parent = row
    end
    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 44, 0, 22)
    track.Position = UDim2.new(1, -56, 0.5, -11)
    track.BackgroundColor3 = State[stateKey] and Color3.fromRGB(220,50,50) or Color3.fromRGB(50,50,65)
    track.BorderSizePixel = 0
    track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = State[stateKey] and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.BorderSizePixel = 0
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = row
    btn.MouseButton1Click:Connect(function()
        State[stateKey] = not State[stateKey]
        local on = State[stateKey]
        TweenS:Create(track, TweenInfo.new(0.15), {
            BackgroundColor3 = on and Color3.fromRGB(220,50,50) or Color3.fromRGB(50,50,65)
        }):Play()
        TweenS:Create(knob, TweenInfo.new(0.15), {
            Position = on and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)
        }):Play()
        if callback then callback(on) end
    end)
    return row
end

local function makeSlider(parent, label, stateKey, minV, maxV, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 52)
    row.BackgroundColor3 = Color3.fromRGB(26, 26, 33)
    row.BorderSizePixel = 0
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 20)
    lbl.Position = UDim2.new(0, 12, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = label..":  "..State[stateKey]
    lbl.TextColor3 = Color3.fromRGB(210, 210, 225)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -24, 0, 6)
    track.Position = UDim2.new(0, 12, 0, 36)
    track.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    track.BorderSizePixel = 0
    track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)
    local ratio = (State[stateKey]-minV)/(maxV-minV)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(ratio, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
    local sliding = false
    track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or
           inp.UserInputType == Enum.UserInputType.Touch then sliding = true end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or
           inp.UserInputType == Enum.UserInputType.Touch then sliding = false end
    end)
    UIS.InputChanged:Connect(function(inp)
        if sliding and (inp.UserInputType == Enum.UserInputType.MouseMovement or
                        inp.UserInputType == Enum.UserInputType.Touch) then
            local r = math.clamp((inp.Position.X - track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
            local val = math.floor(minV + r*(maxV-minV))
            State[stateKey] = val
            fill.Size = UDim2.new(r,0,1,0)
            lbl.Text = label..":  "..val
            if callback then callback(val) end
        end
    end)
end

local function makeSpacer(parent, h)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,h or 8)
    f.BackgroundTransparency = 1
    f.Parent = parent
end

------------------------------------------------------------------------
-- BUILD PAGES
------------------------------------------------------------------------
local vPage = makePage("Visual")
makeHeader(vPage, "PLAYERS")
makeSpacer(vPage, 4)
makeRow(vPage, "LINE",     "Line",     nil)
makeRow(vPage, "BOX",      "Box",      nil)
makeRow(vPage, "HEALTH",   "Health",   nil)
makeRow(vPage, "NAME",     "Name",     nil)
makeRow(vPage, "DISTANCE", "Distance", nil)
makeSpacer(vPage, 8)
makeHeader(vPage, "MASTER")
makeSpacer(vPage, 4)
makeRow(vPage, "ESP MASTER", "ESP", nil)

local cPage = makePage("Combat")
makeHeader(cPage, "SAFETY")
makeSpacer(cPage, 4)
makeRow(cPage, "SAFE MODE (Team Check)", "TeamCheck", "BAN CIRCUIT: ARMED - WATCHING PANEL")
makeSpacer(cPage, 8)
makeHeader(cPage, "RAGE")
makeSpacer(cPage, 4)
makeRow(cPage, "AIMBOT",     "Aimbot",   "HOLD Q TO ACTIVATE")
makeRow(cPage, "SILENT AIM", "SilentAim","RAGE: SILENT - BAN RISK")
makeSpacer(cPage, 8)
makeHeader(cPage, "ASSIST")
makeSpacer(cPage, 4)
makeSlider(cPage, "FOV",        "FOV",    60, 300, nil)
makeSlider(cPage, "AIM SMOOTH", "Smooth", 1,  30,  nil)

local mPage = makePage("Misc")
makeHeader(mPage, "MOVEMENT")
makeSpacer(mPage, 4)
makeRow(mPage, "SPEED HACK", "Speed", nil, function(on)
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = on and State.SpeedVal or 16 end
end)
makeSlider(mPage, "SPEED VALUE", "SpeedVal", 16, 80, function(v)
    if State.Speed then
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
end)
makeSpacer(mPage, 8)
makeRow(mPage, "INFINITE JUMP", "InfJump", nil)
makeRow(mPage, "NOCLIP",        "NoClip",  "WARNING: VISIBLE TO SERVER")

------------------------------------------------------------------------
-- SIDEBAR TABS
------------------------------------------------------------------------
local t1 = makeSideTab("V", "VISUAL", "Visual")
makeSideTab("C", "COMBAT", "Combat")
makeSideTab("M", "MISC",   "Misc")

switchTab("Visual")
t1.BackgroundColor3 = Color3.fromRGB(220,50,50)
t1.TextColor3 = Color3.new(1,1,1)

------------------------------------------------------------------------
-- ESP DRAWINGS
------------------------------------------------------------------------
local espData = {}
local function newDraw(t, props)
    local d = Drawing.new(t)
    for k,v in pairs(props) do d[k]=v end
    return d
end
local function buildESP(player)
    if player == LP then return end
    espData[player] = {
        box    = newDraw("Square",{Visible=false,Color=Color3.fromRGB(80,255,80),Thickness=1.5,Filled=false}),
        tracer = newDraw("Line",  {Visible=false,Color=Color3.fromRGB(255,60,60),Thickness=1.2}),
        name   = newDraw("Text",  {Visible=false,Color=Color3.new(1,1,1),Size=13,Center=true,Outline=true,Text=player.Name}),
        health = newDraw("Text",  {Visible=false,Color=Color3.new(0,1,0),Size=12,Center=true,Outline=true}),
        dist   = newDraw("Text",  {Visible=false,Color=Color3.fromRGB(180,180,180),Size=11,Center=true,Outline=true}),
    }
end
local function removeESP(player)
    if espData[player] then
        for _,d in pairs(espData[player]) do pcall(function() d:Remove() end) end
        espData[player] = nil
    end
end
for _,p in ipairs(Players:GetPlayers()) do buildESP(p) end
Players.PlayerAdded:Connect(buildESP)
Players.PlayerRemoving:Connect(removeESP)

------------------------------------------------------------------------
-- FOV CIRCLE
------------------------------------------------------------------------
local fovCircle = Drawing.new("Circle")
fovCircle.Visible      = false
fovCircle.Color        = Color3.fromRGB(220,50,50)
fovCircle.Thickness    = 1
fovCircle.Filled       = false
fovCircle.Transparency = 0.5

------------------------------------------------------------------------
-- HELPERS
------------------------------------------------------------------------
local function getRoot(p)  return p.Character and p.Character:FindFirstChild("HumanoidRootPart") end
local function getHum(p)   return p.Character and p.Character:FindFirstChildOfClass("Humanoid") end
local function getHead(p)  return p.Character and p.Character:FindFirstChild("Head") end
local function isEnemy(p)
    if not State.TeamCheck then return true end
    return p.Team ~= LP.Team
end
local function w2s(pos)
    local sp, vis = Camera:WorldToViewportPoint(pos)
    return Vector2.new(sp.X, sp.Y), vis
end

------------------------------------------------------------------------
-- INFINITE JUMP
------------------------------------------------------------------------
UIS.JumpRequest:Connect(function()
    if not State.InfJump then return end
    local hum = getHum(LP)
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

------------------------------------------------------------------------
-- RENDER LOOP
------------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    local vp     = Camera.ViewportSize
    local center = Vector2.new(vp.X/2, vp.Y/2)

    fovCircle.Position = center
    fovCircle.Radius   = State.FOV
    fovCircle.Visible  = State.Aimbot

    if State.NoClip and LP.Character then
        for _, p in ipairs(LP.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end

    if State.Aimbot and UIS:IsKeyDown(Enum.KeyCode.Q) then
        local best, bestD = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LP then continue end
            if not isEnemy(p) then continue end
            local hum = getHum(p)
            if not hum or hum.Health <= 0 then continue end
            local head = getHead(p)
            if not head then continue end
            local sp, vis = w2s(head.Position)
            if not vis then continue end
            local d = (sp - center).Magnitude
            if d < State.FOV and d < bestD then bestD=d; best=p end
        end
        if best then
            local head = getHead(best)
            if head then
                local _, vis = w2s(head.Position)
                if vis and not State.SilentAim then
                    local smooth = State.Smooth / 100
                    local cf = CFrame.new(Camera.CFrame.Position, head.Position)
                    Camera.CFrame = Camera.CFrame:Lerp(cf, smooth)
                end
            end
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        local d = espData[p]
        if not d then continue end
        local root = getRoot(p)
        local hum  = getHum(p)
        if not State.ESP or not root or not hum or hum.Health <= 0 then
            for _,obj in pairs(d) do obj.Visible=false end
            continue
        end
        local camD = (root.Position - Camera.CFrame.Position).Magnitude
        if camD > 1200 then
            for _,obj in pairs(d) do obj.Visible=false end
            continue
        end
        local topSP,  topV  = w2s(root.Position + Vector3.new(0, 3.2, 0))
        local botSP,  botV  = w2s(root.Position - Vector3.new(0, 3.2, 0))
        local rootSP, rootV = w2s(root.Position)
        if not (topV and botV) then
            for _,obj in pairs(d) do obj.Visible=false end
            continue
        end
        local h = math.abs(botSP.Y - topSP.Y)
        local w = h * 0.45
        if State.Box then
            d.box.Size = Vector2.new(w, h)
            d.box.Position = Vector2.new(topSP.X - w/2, topSP.Y)
            d.box.Visible = true
        else d.box.Visible = false end
        if State.Name then
            d.name.Position = Vector2.new(topSP.X, topSP.Y - 16)
            d.name.Text = p.Name
            d.name.Visible = true
        else d.name.Visible = false end
        if State.Health then
            local ratio = hum.Health / hum.MaxHealth
            d.health.Position = Vector2.new(topSP.X, topSP.Y - 4)
            d.health.Text = string.format("HP %d%%", math.floor(ratio*100))
            d.health.Color = Color3.fromRGB(255*(1-ratio), 255*ratio, 0)
            d.health.Visible = true
        else d.health.Visible = false end
        if State.Distance then
            d.dist.Position = Vector2.new(topSP.X, botSP.Y + 2)
            d.dist.Text = string.format("[%.0fm]", camD)
            d.dist.Visible = true
        else d.dist.Visible = false end
        if State.Line and rootV then
            d.tracer.From = Vector2.new(center.X, vp.Y)
            d.tracer.To = Vector2.new(rootSP.X, rootSP.Y)
            d.tracer.Visible = true
        else d.tracer.Visible = false end
    end
end)

------------------------------------------------------------------------
LP.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    task.wait(0.5)
    if State.Speed then hum.WalkSpeed = State.SpeedVal end
end)

print("[URCheat] Loaded | RightShift = hide/show")
