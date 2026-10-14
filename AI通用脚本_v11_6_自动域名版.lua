-- ============================================
-- AI通用脚本 v11.6 完整源码
-- ============================================

if _G.AILoaded then pcall(function() _G.AIDestroy() end) end
_G.AILoaded = true

local P = game:GetService("Players")
local R = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local C = game:GetService("CoreGui")
local L = P.LocalPlayer
local Mouse = L:GetMouse()

if not _G.AIW then
    _G.AIW = {
        UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))(),
        MainWindow = nil,
    }
end
local W = _G.AIW.UI

if _G.StandaloneW and _G.StandaloneW.Window then
    pcall(function() _G.StandaloneW.Window:Destroy() end)
    _G.StandaloneW = nil
end

local Win = W:CreateWindow({
    Title = "AI通用脚本", Author = "czy", Icon = "crown",
    Theme = "Dark", ToggleKey = Enum.KeyCode.RightShift,
})
Win:Tag({ Title = "v11.6", Color = "ElementBackground" })
W:Notify({ Title = "AI通用脚本", Content = "加载成功！RightShift 打开", Duration = 5 })

_G.AIW.MainWindow = Win

local S = {
    ESP = false, AI = true, Player = true,
    Name = true, Health = true, HpBar = true, Distance = true,
    MaxDist = 800,
    Aim = false, AimRadius = 200, AimPart = "Head",
    AimColor = Color3.fromRGB(0, 255, 150),
    AimTarget = "AI", AimMode = "Crosshair", AimSmooth = 5,
    ShowCircle = true,
    Noclip = false, Speed = false, SpeedValue = 50,
    NightVision = false,
}

local C2 = {
    Aimbot = false, AimMode = "Camera", OffAfterKill = false,
    AimKey = "E", AimPart = "Head",
    UseOffset = false, UseSensitivity = false, Sensitivity = 50, UseNoise = false,
    TriggerBot = false, TriggerKey = "V",
    TeamCheck = false, FriendCheck = false, WallCheck = false,
    FoVCheck = false, FoVRadius = 200, MagnitudeCheck = false, TriggerMagnitude = 500,
    ShowFoV = true, FoVColour = Color3.fromRGB(0, 255, 150),
}

local Aiming2, Triggering2, Target2, Tween2 = false, false, nil, nil
local OldMouseSens = UIS.MouseDeltaSensitivity

local function isNPC(m)
    local f = m:GetFullName()
    if f:find("Tycoons") or f:find("Creatures") then
        if m.Name ~= L.Name then return true end
    end
    return false
end

local function getNPCs()
    local l = {}
    for _, o in ipairs(workspace:GetDescendants()) do
        if o:IsA("Model") and o:FindFirstChildOfClass("Humanoid") and o:FindFirstChild("HumanoidRootPart") then
            if isNPC(o) then
                table.insert(l, {M = o, H = o:FindFirstChildOfClass("Humanoid"), R = o:FindFirstChild("HumanoidRootPart"), P = false})
            end
        end
    end
    return l
end

local function getPlrs()
    local l = {}
    for _, p in ipairs(P:GetPlayers()) do
        if p ~= L and p.Character then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            if r and h then
                table.insert(l, {M = p.Character, H = h, R = r, P = true, Pl = p})
            end
        end
    end
    return l
end

local function getTgts()
    local l = {}
    if S.AimTarget == "AI" or S.AimTarget == "All" then
        for _, n in ipairs(getNPCs()) do table.insert(l, n) end
    end
    if S.AimTarget == "Player" or S.AimTarget == "All" then
        for _, p in ipairs(getPlrs()) do table.insert(l, p) end
    end
    return l
end

local function IsReady(Target)
    if not Target then return false end
    local tHum = Target:FindFirstChildOfClass("Humanoid")
    local tPart = Target:FindFirstChild(C2.AimPart)
    local plr = P:GetPlayerFromCharacter(Target)
    if not tHum or tHum.Health <= 0 or not tPart then return false end
    if plr == L then return false end
    if C2.TeamCheck and plr and plr.TeamColor == L.TeamColor then return false end
    if C2.FriendCheck and plr and plr:IsFriendsWith(L.UserId) then return false end
    local myChar = L.Character
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    local myPart = myChar and myChar:FindFirstChild(C2.AimPart)
    if not myHum or myHum.Health <= 0 or not myPart then return false end
    if C2.WallCheck then
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {L.Character}
        local result = workspace:Raycast(myPart.Position, (tPart.Position - myPart.Position), params)
        if result and result.Instance and not result.Instance:FindFirstAncestor(plr.Name) then return false end
    end
    if C2.MagnitudeCheck and (tPart.Position - myPart.Position).Magnitude > C2.TriggerMagnitude then return false end
    local offset = Vector3.zero
    if C2.UseOffset then offset = Vector3.new(0, tPart.Position.Y * 1, 0) end
    local noise = Vector3.zero
    if C2.UseNoise then noise = Vector3.new(Random.new():NextNumber(0.5, 1), Random.new():NextNumber(0.5, 1), Random.new():NextNumber(0.5, 1)) end
    local finalPos = tPart.Position + offset + noise
    local vp, onScreen = workspace.CurrentCamera:WorldToViewportPoint(finalPos)
    if not onScreen then return false end
    return true, Target, vp, finalPos, tPart
end

local function FindTarget2()
    local closest, bestDist = nil, math.huge
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    for _, u in ipairs(getPlrs()) do
        local ok, _, vp = IsReady(u.M)
        if ok and vp then
            local d = (mousePos - Vector2.new(vp.X, vp.Y)).Magnitude
            if d < bestDist then
                if not C2.FoVCheck or d <= C2.FoVRadius then
                    closest, bestDist = u.M, d
                end
            end
        end
    end
    return closest
end

R.RenderStepped:Connect(function()
    if not C2.Aimbot then
        if Tween2 then Tween2:Cancel() Tween2 = nil end
        UIS.MouseDeltaSensitivity = OldMouseSens
        return
    end
    if Aiming2 then
        if not IsReady(Target2) then Target2 = FindTarget2() end
        local ok, _, vp, worldPos = IsReady(Target2)
        if ok then
            if C2.AimMode == "Camera" then
                if C2.UseSensitivity then
                    Tween2 = TweenService:Create(workspace.CurrentCamera, TweenInfo.new(math.clamp(C2.Sensitivity, 9, 99) / 100, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, worldPos) })
                    Tween2:Play()
                else
                    workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, worldPos)
                end
            end
        else
            Target2 = nil
        end
    end
    if Triggering2 then
        if Mouse.Target then
            local m = Mouse.Target:FindFirstAncestorWhichIsA("Model")
            if IsReady(m) then
                pcall(function() if getfenv().mouse1click then getfenv().mouse1click() end end)
            end
        end
    end
end)

UIS.InputBegan:Connect(function(input)
    if UIS:GetFocusedTextBox() then return end
    local key = C2.AimKey == "RMB" and Enum.UserInputType.MouseButton2 or Enum.KeyCode[C2.AimKey]
    if C2.Aimbot and (input.KeyCode == key or input.UserInputType == key) then
        Aiming2 = true
        if not Target2 then Target2 = FindTarget2() end
    end
    local tkey = C2.TriggerKey == "RMB" and Enum.UserInputType.MouseButton2 or Enum.KeyCode[C2.TriggerKey]
    if C2.TriggerBot and (input.KeyCode == tkey or input.UserInputType == tkey) then Triggering2 = true end
end)

UIS.InputEnded:Connect(function(input)
    local key = C2.AimKey == "RMB" and Enum.UserInputType.MouseButton2 or Enum.KeyCode[C2.AimKey]
    if Aiming2 and (input.KeyCode == key or input.UserInputType == key) then
        Aiming2 = false Target2 = nil
        if Tween2 then Tween2:Cancel() Tween2 = nil end
    end
    local tkey = C2.TriggerKey == "RMB" and Enum.UserInputType.MouseButton2 or Enum.KeyCode[C2.TriggerKey]
    if Triggering2 and (input.KeyCode == tkey or input.UserInputType == tkey) then Triggering2 = false end
end)

local SG = Instance.new("ScreenGui")
SG.Name = "AIHUD"; SG.ResetOnSpawn = false; SG.Parent = C

local Cir = Instance.new("Frame")
Cir.Size = UDim2.new(0, S.AimRadius * 2, 0, S.AimRadius * 2)
Cir.Position = UDim2.new(0.5, -S.AimRadius, 0.5, -S.AimRadius)
Cir.BackgroundTransparency = 1 Cir.BorderSizePixel = 0 Cir.Visible = false Cir.Parent = SG
local CirC = Instance.new("UICorner"); CirC.CornerRadius = UDim.new(1, 0); CirC.Parent = Cir
local CirS = Instance.new("UIStroke"); CirS.Color = S.AimColor; CirS.Thickness = 2; CirS.Parent = Cir

local Cir2 = Instance.new("Frame")
Cir2.Size = UDim2.new(0, C2.FoVRadius * 2, 0, C2.FoVRadius * 2)
Cir2.Position = UDim2.new(0.5, -C2.FoVRadius, 0.5, -C2.FoVRadius)
Cir2.BackgroundTransparency = 1 Cir2.BorderSizePixel = 0 Cir2.Visible = false Cir2.Parent = SG
local Cir2C = Instance.new("UICorner"); Cir2C.CornerRadius = UDim.new(1, 0); Cir2C.Parent = Cir2
local Cir2S = Instance.new("UIStroke"); Cir2S.Color = C2.FoVColour; Cir2S.Thickness = 2; Cir2S.Transparency = 0.5; Cir2S.Parent = Cir2

local EF = Instance.new("Folder"); EF.Name = "AIESP"; EF.Parent = C
local EC = {}

local function mkESP(u, isP)
    if EC[u.M] then return end
    local bb = Instance.new("BillboardGui")
    bb.Adornee = u.R bb.Size = UDim2.new(0, 220, 0, 60) bb.StudsOffset = Vector3.new(0, 3, 0) bb.AlwaysOnTop = true bb.Parent = EF
    local n = Instance.new("TextLabel")
    n.Size = UDim2.new(1, 0, 0, 18) n.BackgroundTransparency = 1
    n.TextColor3 = isP and Color3.fromRGB(255,150,0) or Color3.fromRGB(255,60,60)
    n.TextStrokeTransparency = 0 n.TextScaled = true n.Font = Enum.Font.GothamBold n.Parent = bb
    local d = Instance.new("TextLabel")
    d.Size = UDim2.new(1, 0, 0, 14) d.Position = UDim2.new(0, 0, 0, 18) d.BackgroundTransparency = 1
    d.TextColor3 = Color3.fromRGB(255,255,100) d.TextStrokeTransparency = 0 d.TextScaled = true d.Parent = bb
    local hb = Instance.new("Frame")
    hb.Size = UDim2.new(1, 0, 0, 5) hb.Position = UDim2.new(0, 0, 0, 36)
    hb.BackgroundColor3 = Color3.fromRGB(40,40,40) hb.BorderSizePixel = 0 hb.Parent = bb
    local hr = Instance.new("Frame")
    hr.Size = UDim2.new(1, 0, 1, 0) hr.BackgroundColor3 = Color3.fromRGB(0,255,0) hr.BorderSizePixel = 0 hr.Parent = hb
    local hl = Instance.new("Highlight")
    hl.Adornee = u.M hl.FillColor = isP and Color3.fromRGB(255,150,0) or Color3.fromRGB(255,0,0)
    hl.FillTransparency = 0.5 hl.OutlineTransparency = 0 hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop hl.Parent = EF
    EC[u.M] = {b = bb, n = n, d = d, hr = hr, hb = hb, hl = hl, p = isP}
end

R.RenderStepped:Connect(function()
    local mr = L.Character and L.Character:FindFirstChild("HumanoidRootPart")
    local mp = mr and mr.Position or Vector3.zero
    local all = {}
    if S.AI then for _, n in ipairs(getNPCs()) do table.insert(all, n) end end
    if S.Player then for _, p in ipairs(getPlrs()) do table.insert(all, p) end end
    for _, u in ipairs(all) do if not EC[u.M] then mkESP(u, u.P) end end
    for m, c in pairs(EC) do
        local tOk = c.p and S.Player or S.AI
        if not m.Parent or not tOk then
            c.b:Destroy() c.hl:Destroy() EC[m] = nil
        else
            local r = m:FindFirstChild("HumanoidRootPart")
            local h = m:FindFirstChildOfClass("Humanoid")
            if r and h then
                local d = (r.Position - mp).Magnitude
                local sh = S.ESP and d <= S.MaxDist
                c.b.Enabled = sh c.hl.Enabled = sh
                if sh then
                    c.b.Adornee = r c.hl.Adornee = m
                    c.n.Visible = S.Name c.d.Visible = S.Distance c.hb.Visible = S.HpBar
                    c.d.Text = string.format("[%d m]", math.floor(d))
                    c.n.Text = S.Health and (m.Name .. " [" .. math.floor(h.Health) .. "]") or m.Name
                    local pp = h.Health / math.max(h.MaxHealth, 1)
                    c.hr.Size = UDim2.new(pp, 0, 1, 0)
                    c.hr.BackgroundColor3 = pp > 0.6 and Color3.fromRGB(0,255,0) or pp > 0.3 and Color3.fromRGB(255,200,0) or Color3.fromRGB(255,0,0)
                end
            end
        end
    end
end)

local function setupAim()
    R.RenderStepped:Connect(function()
        if not S.Aim then Cir.Visible = false return end
        Cir.Visible = S.ShowCircle
        Cir.Size = UDim2.new(0, S.AimRadius * 2, 0, S.AimRadius * 2)
        Cir.Position = UDim2.new(0.5, -S.AimRadius, 0.5, -S.AimRadius)
        CirS.Color = S.AimColor
        local cm = workspace.CurrentCamera
        local mr = L.Character and L.Character:FindFirstChild("HumanoidRootPart")
        if not mr then return end
        local mp = mr.Position
        local sz = cm.ViewportSize
        local ct = Vector2.new(sz.X / 2, sz.Y / 2)
        local list = getTgts()
        local best, bs = nil, math.huge
        for _, u in ipairs(list) do
            if u.H.Health > 0 then
                local p = u.M:FindFirstChild(S.AimPart) or u.R
                local sp, os = cm:WorldToViewportPoint(p.Position)
                if os then
                    local v = Vector2.new(sp.X, sp.Y)
                    local cd = (v - ct).Magnitude
                    if cd <= S.AimRadius then
                        local sc = S.AimMode == "Crosshair" and cd or (p.Position - mp).Magnitude
                        if sc < bs then best, bs = u, sc end
                    end
                end
            end
        end
        if best then
            local t = best.M:FindFirstChild(S.AimPart) or best.R
            local de = CFrame.new(cm.CFrame.Position, t.Position)
            if S.AimSmooth <= 1 then cm.CFrame = de
            else cm.CFrame = cm.CFrame:Lerp(de, 1/S.AimSmooth) end
        end
    end)
end

local function setupNoclip()
    R.Stepped:Connect(function()
        if not S.Noclip then return end
        local ch = L.Character
        if ch then for _, p in ipairs(ch:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
        end end
    end)
end

local function setupSpeed()
    R.Heartbeat:Connect(function()
        if not S.Speed then return end
        local ch = L.Character
        local r = ch and ch:FindFirstChild("HumanoidRootPart")
        local h = ch and ch:FindFirstChildOfClass("Humanoid")
        if r and h and h.MoveDirection.Magnitude > 0 then
            local v = r.AssemblyLinearVelocity
            r.AssemblyLinearVelocity = Vector3.new(h.MoveDirection.X * S.SpeedValue, v.Y, h.MoveDirection.Z * S.SpeedValue)
        end
    end)
end

local NVSaved = {}
local function saveLighting()
    local Lg = game:GetService("Lighting")
    NVSaved = { Brightness = Lg.Brightness, Ambient = Lg.Ambient, OutdoorAmbient = Lg.OutdoorAmbient, GlobalShadows = Lg.GlobalShadows, FogEnd = Lg.FogEnd, FogStart = Lg.FogStart, ClockTime = Lg.ClockTime, ExposureCompensation = Lg.ExposureCompensation }
end
local function applyNightVision()
    local Lg = game:GetService("Lighting")
    Lg.Brightness = 3 Lg.Ambient = Color3.fromRGB(180, 180, 180) Lg.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
    Lg.GlobalShadows = false Lg.FogEnd = 100000 Lg.FogStart = 0 Lg.ClockTime = 14 Lg.ExposureCompensation = 1
    for _, e in ipairs(Lg:GetChildren()) do
        if e:IsA("BlurEffect") then e.Size = 0
        elseif e:IsA("ColorCorrectionEffect") then e.Brightness = 0.3 e.Contrast = 0.1 e.Saturation = 0 e.TintColor = Color3.fromRGB(255,255,255)
        elseif e:IsA("Atmosphere") then e.Density = 0 e.Haze = 0 end
    end
end
local function restoreLighting()
    local Lg = game:GetService("Lighting")
    if NVSaved.Brightness then Lg.Brightness = NVSaved.Brightness end
    if NVSaved.Ambient then Lg.Ambient = NVSaved.Ambient end
    if NVSaved.OutdoorAmbient then Lg.OutdoorAmbient = NVSaved.OutdoorAmbient end
    if NVSaved.GlobalShadows ~= nil then Lg.GlobalShadows = NVSaved.GlobalShadows end
    if NVSaved.FogEnd then Lg.FogEnd = NVSaved.FogEnd end
    if NVSaved.FogStart then Lg.FogStart = NVSaved.FogStart end
    if NVSaved.ClockTime then Lg.ClockTime = NVSaved.ClockTime end
    if NVSaved.ExposureCompensation ~= nil then Lg.ExposureCompensation = NVSaved.ExposureCompensation end
end
local function setupNightVision()
    R.Heartbeat:Connect(function() if S.NightVision then applyNightVision() end end)
end

local function getPlayerNames()
    local names = {}
    for _, p in ipairs(P:GetPlayers()) do if p ~= L then table.insert(names, p.Name) end end
    if #names == 0 then names = {"（无其他玩家）"} end
    return names
end

local function loadFromGitHub(url, label)
    local ok, code = pcall(function() return game:HttpGet(url) end)
    if not ok or not code or #code < 10 then
        W:Notify({ Title = label, Content = "拉取失败", Duration = 5 })
        return
    end
    local fn, err = loadstring(code)
    if not fn then
        W:Notify({ Title = label, Content = "编译失败: " .. tostring(err):sub(1,50), Duration = 5 })
        return
    end
    local ok2, err2 = pcall(fn)
    if not ok2 then
        W:Notify({ Title = label, Content = "执行失败: " .. tostring(err2):sub(1,50), Duration = 5 })
    else
        W:Notify({ Title = label, Content = "加载成功", Duration = 3 })
    end
end

local function loadFly()
    loadFromGitHub("https://raw.githubusercontent.com/czy2778/rbczy/main/fly.lua", "飞行脚本")
end

local function runSkidFling(targetName)
    local Targets = {targetName}
    local AllBool = false
    local Player = L
    local GetPlayer = function(Name)
        Name = Name:lower()
        if Name == "all" or Name == "others" or Name == "所有人" then AllBool = true return end
        for _, x in ipairs(P:GetPlayers()) do
            if x ~= Player then
                if x.Name:lower():match("^" .. Name) then return x
                elseif x.DisplayName:lower():match("^" .. Name) then return x end
            end
        end
    end
    local SkidFling = function(TargetPlayer)
        local Character = Player.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        local RootPart = Humanoid and Humanoid.RootPart
        local TCharacter = TargetPlayer.Character
        local THumanoid, TRootPart, THead
        if TCharacter:FindFirstChildOfClass("Humanoid") then THumanoid = TCharacter:FindFirstChildOfClass("Humanoid") end
        if THumanoid and THumanoid.RootPart then TRootPart = THumanoid.RootPart end
        if TCharacter:FindFirstChild("Head") then THead = TCharacter.Head end
        if Character and Humanoid and RootPart then
            if RootPart.Velocity.Magnitude < 50 then getgenv().OldPos = RootPart.CFrame end
            if THumanoid and THumanoid.Sit and not AllBool then return end
            local FPos = function(BasePart, Pos, Ang)
                RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
                Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
                RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
                RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
            end
            local SFBasePart = function(BasePart)
                local TimeToWait = 2
                local Time = tick()
                local Angle = 0
                repeat
                    if RootPart and THumanoid then
                        Angle = Angle + 100
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                    else break end
                until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TargetPlayer.Character or THumanoid.Sit or Humanoid.Health <= 0 or tick() > Time + TimeToWait
            end
            workspace.FallenPartsDestroyHeight = 0/0
            local BV = Instance.new("BodyVelocity")
            BV.Parent = RootPart
            BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
            BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
            if TRootPart and THead then
                if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then SFBasePart(THead)
                else SFBasePart(TRootPart) end
            elseif TRootPart and not THead then SFBasePart(TRootPart)
            elseif not TRootPart and THead then SFBasePart(THead)
            else return end
            BV:Destroy()
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
            repeat
                RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
                Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
                Humanoid:ChangeState("GettingUp")
                task.wait()
            until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
            workspace.FallenPartsDestroyHeight = getgenv().FPDH
        end
    end
    if AllBool then for _, x in ipairs(P:GetPlayers()) do SkidFling(x) end end
    for _, x in ipairs(Targets) do
        local tp = GetPlayer(x)
        if tp and tp ~= Player then SkidFling(tp) end
    end
end

-- UI Tab
local T1 = Win:Tab({ Title = "透视", Icon = "eye" })
local T2 = Win:Tab({ Title = "自瞄v1", Icon = "crosshair" })
local T2B = Win:Tab({ Title = "自瞄v2", Icon = "target" })
local T3 = Win:Tab({ Title = "玩家", Icon = "user" })
local T6 = Win:Tab({ Title = "属性", Icon = "settings" })
local T7 = Win:Tab({ Title = "其他脚本", Icon = "gamepad-2" })

T1:Toggle({ Title = "透视开关", Value = false, Callback = function(v) S.ESP = v end })
T1:Toggle({ Title = "显示AI", Value = true, Callback = function(v) S.AI = v end })
T1:Toggle({ Title = "显示玩家", Value = true, Callback = function(v) S.Player = v end })
T1:Toggle({ Title = "名字", Value = true, Callback = function(v) S.Name = v end })
T1:Toggle({ Title = "血量", Value = true, Callback = function(v) S.Health = v end })
T1:Toggle({ Title = "血条", Value = true, Callback = function(v) S.HpBar = v end })
T1:Toggle({ Title = "距离", Value = true, Callback = function(v) S.Distance = v end })
T1:Slider({ Title = "最大距离", Value = {Min=50, Max=3000, Default=800}, Callback = function(v) S.MaxDist = v end })

T2:Toggle({ Title = "自瞄开关", Value = false, Callback = function(v)
    S.Aim = v
    if v then setupAim() if S.ShowCircle then Cir.Visible = true end
    else Cir.Visible = false end
end })
T2:Dropdown({ Title = "锁定对象", Values = {"AI","Player","All"}, Value = "AI", Callback = function(v) S.AimTarget = v end })
T2:Dropdown({ Title = "模式", Values = {"Crosshair","Distance"}, Value = "Crosshair", Callback = function(v) S.AimMode = v end })
T2:Slider({ Title = "半径", Value = {Min=50, Max=800, Default=200}, Callback = function(v) S.AimRadius = v end })
T2:Slider({ Title = "平滑", Value = {Min=1, Max=20, Default=5}, Callback = function(v) S.AimSmooth = v end })
T2:Dropdown({ Title = "部位", Values = {"Head","Torso","UpperTorso","LowerTorso","HumanoidRootPart"}, Value = "Head", Callback = function(v) S.AimPart = v end })
T2:Toggle({ Title = "显示圈", Value = true, Callback = function(v) S.ShowCircle = v end })
T2:Colorpicker({ Title = "圈色", Default = Color3.fromRGB(0,255,150), Callback = function(v) S.AimColor = v end })

T2B:Paragraph({ Title = "自瞄v2", Desc = "仅对玩家" })
T2B:Toggle({ Title = "自瞄v2 开关", Value = false, Callback = function(v) C2.Aimbot = v end })
T2B:Dropdown({ Title = "瞄准模式", Values = {"Camera"}, Value = "Camera", Callback = function(v) C2.AimMode = v end })
T2B:Input({ Title = "瞄准键", Placeholder = "E", Value = "E", Callback = function(v) C2.AimKey = v end })
T2B:Input({ Title = "Trigger 键", Placeholder = "V", Value = "V", Callback = function(v) C2.TriggerKey = v end })
T2B:Dropdown({ Title = "瞄准部位", Values = {"Head","Torso","UpperTorso","LowerTorso","HumanoidRootPart"}, Value = "Head", Callback = function(v) C2.AimPart = v end })
T2B:Toggle({ Title = "队伍检查", Value = false, Callback = function(v) C2.TeamCheck = v end })
T2B:Toggle({ Title = "好友检查", Value = false, Callback = function(v) C2.FriendCheck = v end })
T2B:Toggle({ Title = "墙体检查", Value = false, Callback = function(v) C2.WallCheck = v end })
T2B:Toggle({ Title = "FoV 检查", Value = false, Callback = function(v) C2.FoVCheck = v end })
T2B:Slider({ Title = "FoV 半径", Value = {Min=50, Max=800, Default=200}, Callback = function(v) C2.FoVRadius = v end })
T2B:Toggle({ Title = "TriggerBot", Value = false, Callback = function(v) C2.TriggerBot = v end })

T3:Button({ Title = "加载飞行脚本", Callback = function() loadFly() end })
T3:Toggle({ Title = "穿墙", Value = false, Callback = function(v) S.Noclip = v if v then setupNoclip() end end })
T3:Toggle({ Title = "移速", Value = false, Callback = function(v) S.Speed = v if v then setupSpeed() end end })
T3:Slider({ Title = "移速值", Value = {Min=16, Max=200, Default=50}, Callback = function(v) S.SpeedValue = v end })
T3:Toggle({ Title = "夜视", Value = false, Callback = function(v)
    S.NightVision = v
    if v then saveLighting() applyNightVision() setupNightVision() else restoreLighting() end
end })

local teleportDropdown
local teleportTargetName = nil
teleportDropdown = T3:Dropdown({
    Title = "选择传送目标",
    Values = getPlayerNames(),
    Value = getPlayerNames()[1],
    Callback = function(v) teleportTargetName = v end,
})

T3:Button({
    Title = "传送到选中玩家",
    Callback = function()
        if not teleportTargetName then W:Notify({Title="传送", Content="未选择目标", Duration=3}) return end
        local target = P:FindFirstChild(teleportTargetName)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local myRoot = L.Character and L.Character:FindFirstChild("HumanoidRootPart")
            if myRoot then
                myRoot.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                W:Notify({Title="传送", Content="已传送到 " .. teleportTargetName, Duration=3})
            end
        else W:Notify({Title="传送", Content="目标无效", Duration=3}) end
    end,
})

T3:Input({
    Title = "传送坐标 (x,y,z)",
    Placeholder = "例: 100,50,200",
    Callback = function(v)
        local x, y, z = v:match("([^,]+),([^,]+),([^,]+)")
        if x and y and z then
            local myRoot = L.Character and L.Character:FindFirstChild("HumanoidRootPart")
            if myRoot then
                myRoot.CFrame = CFrame.new(tonumber(x), tonumber(y), tonumber(z))
                W:Notify({Title="传送", Content="已传送到 " .. v, Duration=3})
            end
        else W:Notify({Title="传送", Content="格式错误", Duration=3}) end
    end,
})

local flingDropdown
local flingTargetName = "所有人"
flingDropdown = T3:Dropdown({
    Title = "选择甩飞目标",
    Values = (function() local n = getPlayerNames() table.insert(n, 1, "所有人") return n end)(),
    Value = "所有人",
    Callback = function(v) flingTargetName = v end,
})

T3:Button({
    Title = "执行甩飞",
    Callback = function()
        if not flingTargetName then W:Notify({Title="甩飞", Content="未选择", Duration=3}) return end
        if flingTargetName == "所有人" then
            task.spawn(function() runSkidFling("all") end)
            W:Notify({Title="甩飞", Content="开始甩飞所有人", Duration=3})
        else
            task.spawn(function() runSkidFling(flingTargetName) end)
            W:Notify({Title="甩飞", Content="开始甩飞 " .. flingTargetName, Duration=3})
        end
    end,
})

T3:Button({
    Title = "刷新玩家列表",
    Callback = function()
        local tpNames = getPlayerNames()
        teleportTargetName = tpNames[1]
        if teleportDropdown then pcall(function() teleportDropdown:Refresh(tpNames) end) end
        local flNames = getPlayerNames()
        table.insert(flNames, 1, "所有人")
        flingTargetName = "所有人"
        if flingDropdown then pcall(function() flingDropdown:Refresh(flNames) end) end
        W:Notify({Title="刷新", Content="已刷新", Duration=2})
    end,
})

T6:Slider({ Title = "时间", Value = {Min=0, Max=24, Default=14}, Callback = function(v) game:GetService("Lighting").ClockTime = v end })
T6:Button({ Title = "天亮", Callback = function() game:GetService("Lighting").ClockTime = 12 end })
T6:Button({ Title = "天黑", Callback = function() game:GetService("Lighting").ClockTime = 0 end })
T6:Slider({ Title = "重力", Value = {Min=0, Max=500, Default=196}, Callback = function(v) workspace.Gravity = v end })

-- v11.6：直接写入主脚本，不再二次下载 GitHub 通用.lua
-- 加载 Tab 只保留网站脚本仓库，其他功能 Tab 不变。
local HttpService = game:GetService("HttpService")
local SiteSection = T7:Section({Title="2. Lua脚本站", Open=true})
-- Roblox 客户端无法直接获知网站新域名：通过固定 GitHub 配置文件获取。
-- 迁移域名时仅更新 GitHub 仓库 main 分支的 site_url.txt。
local SITE_CONFIG_URL = "https://raw.githubusercontent.com/czy2778/rbczy/main/site_url.txt"
local siteURL = "https://raw.jaychou.xyz" -- 配置暂时不可用时的旧站备用地址
local function refreshSiteURL()
    local ok, response = pcall(function()
        return game:HttpGet(SITE_CONFIG_URL .. "?t=" .. tostring(os.time()))
    end)
    if not ok or type(response) ~= "string" then return false end
    local url = response:match("^%s*(https://[%w%.%-]+:?%d*)%s*$")
    if not url then return false end
    siteURL = url:gsub("/+$", "")
    return true
end
refreshSiteURL()
local siteItems, siteQuery, resultElements = {}, "", {}
local function siteNotify(title, message)
    W:Notify({Title=title, Content=tostring(message):sub(1,250), Duration=5})
end
local function getSiteItems()
    refreshSiteURL()
    local ok, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(siteURL .. "/api/scripts.php?t=" .. tostring(os.time())))
    end)
    if not ok or type(result) ~= "table" or result.ok ~= true or type(result.scripts) ~= "table" then
        siteNotify("脚本站", "读取失败，请检查网站和执行器是否支持 HTTP")
        return nil
    end
    return result.scripts
end
local function runSite(item)
    local id = tonumber(item.id)
    if not id then return end
    local ok, err = pcall(function()
        local source = game:HttpGet(siteURL .. "/api/raw.php?id=" .. tostring(id))
        local fn, compileError = loadstring(source)
        if not fn then error(compileError) end
        fn()
    end)
    siteNotify(tostring(item.name or "脚本"), ok and "运行完成" or ("运行失败：" .. tostring(err)))
end
local function showScriptInfo(item)
    local lines = {"名称：" .. tostring(item.name or ""), "简介：" .. tostring(item.description or "")}
    for _, block in ipairs(type(item.blocks)=="table" and item.blocks or {}) do
        if block.type == "title" then
            table.insert(lines, "【" .. tostring(block.value or "") .. "】")
        elseif block.type == "text" then
            table.insert(lines, tostring(block.value or ""))
        elseif block.type == "image" then
            table.insert(lines, "图片地址：" .. tostring(block.value or ""))
        elseif block.type == "divider" then
            table.insert(lines, "----------------")
        end
    end
    table.insert(lines, "完整信息页：" .. siteURL .. "/info.php?id=" .. tostring(item.id))
    local text = table.concat(lines, "\n")
    local gui = Instance.new("ScreenGui")
    gui.Name = "PYScriptInfo116"
    gui.ResetOnSpawn = false
    gui.Parent = C
    local panel = Instance.new("Frame")
    panel.Size = UDim2.fromScale(.78,.72)
    panel.Position = UDim2.fromScale(.11,.14)
    panel.BackgroundColor3 = Color3.fromRGB(26,28,35)
    panel.Parent = gui
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0,12)
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0,50,0,40)
    close.Position = UDim2.new(1,-55,0,5)
    close.Text = "关闭"
    close.TextColor3 = Color3.new(1,1,1)
    close.BackgroundColor3 = Color3.fromRGB(75,77,90)
    close.Parent = panel
    close.MouseButton1Click:Connect(function() gui:Destroy() end)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Position = UDim2.new(0,12,0,52)
    scroll.Size = UDim2.new(1,-24,1,-64)
    scroll.BackgroundTransparency = 1
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize = UDim2.new()
    scroll.ScrollBarThickness = 5
    scroll.Parent = panel
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-8,0,0)
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSans
    label.TextSize = 19
    label.Text = text
    label.Parent = scroll
end
local function clearResults()
    for _, element in ipairs(resultElements) do
        pcall(function() element:Destroy() end)
    end
    table.clear(resultElements)
end
local function renderResults()
    clearResults()
    local q = string.lower(siteQuery)
    local count = 0
    for _, item in ipairs(siteItems) do
        local haystack = string.lower(tostring(item.name or "") .. " " .. tostring(item.description or ""))
        if q == "" or string.find(haystack, q, 1, true) then
            count += 1
            local button = SiteSection:Button({Title="▶ " .. tostring(item.name or "未命名"), Desc=tostring(item.description or ""), Callback=function() runSite(item) end})
            local info = SiteSection:Button({Title="ℹ 查看信息 · " .. tostring(item.name or "未命名"), Callback=function() showScriptInfo(item) end})
            table.insert(resultElements, button)
            table.insert(resultElements, info)
        end
    end
    siteNotify("Lua脚本站", "找到 " .. count .. " 个脚本")
end
SiteSection:Input({Title="搜索", Placeholder="搜索脚本名称或简介", Callback=function(value)
    siteQuery = tostring(value or "")
    renderResults()
end})
SiteSection:Button({Title="刷新网站脚本", Callback=function()
    local items = getSiteItems()
    if items then siteItems = items; renderResults() end
end})
task.spawn(function()
    local items = getSiteItems()
    if items then siteItems = items; renderResults() end
end)

-- 信息 Tab：玩家资料、可旋转 3D 模型、服务器、在线玩家、脚本信息
local InfoTab = Win:Tab({Title="信息", Icon="info"})
InfoTab:Paragraph({Title="当前玩家", Desc=L.DisplayName .. " (@" .. L.Name .. ")  ID:" .. L.UserId})
InfoTab:Paragraph({Title="游玩服务器", Desc="PlaceId: " .. tostring(game.PlaceId) .. "\nJobId: " .. tostring(game.JobId)})
local function playerNames()
    local names = {}
    for _, player in ipairs(P:GetPlayers()) do
        table.insert(names, player.DisplayName .. " (@" .. player.Name .. ")")
    end
    return table.concat(names, "\n")
end
local playersLabel = InfoTab:Paragraph({Title="服务器玩家列表", Desc=playerNames()})
InfoTab:Button({Title="刷新玩家列表", Callback=function()
    pcall(function() playersLabel:SetDesc(playerNames()) end)
    siteNotify("玩家列表", playerNames())
end})
InfoTab:Button({Title="查看我的 3D 人物模型", Callback=function()
    local character = L.Character
    if not character then siteNotify("玩家模型", "角色尚未生成"); return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "PYPlayerPreview116"
    gui.ResetOnSpawn = false
    gui.Parent = C
    local panel = Instance.new("Frame")
    panel.Size = UDim2.fromScale(.65,.68)
    panel.Position = UDim2.fromScale(.175,.16)
    panel.BackgroundColor3 = Color3.fromRGB(25,27,33)
    panel.Parent = gui
    Instance.new("UICorner",panel).CornerRadius = UDim.new(0,12)
    local viewport = Instance.new("ViewportFrame")
    viewport.Size = UDim2.new(1,-20,1,-65)
    viewport.Position = UDim2.fromOffset(10,50)
    viewport.BackgroundTransparency = 1
    viewport.Parent = panel
    local close = Instance.new("TextButton")
    close.Size = UDim2.fromOffset(65,36)
    close.Position = UDim2.new(1,-75,0,7)
    close.Text = "关闭"
    close.Parent = panel
    close.MouseButton1Click:Connect(function() gui:Destroy() end)
    local world = Instance.new("WorldModel")
    world.Parent = viewport
    local oldArchivable = character.Archivable
    character.Archivable = true
    local ok, clone = pcall(function() return character:Clone() end)
    character.Archivable = oldArchivable
    if not ok or not clone then gui:Destroy(); siteNotify("玩家模型", "无法复制角色模型"); return end
    for _, desc in ipairs(clone:GetDescendants()) do
        if desc:IsA("Script") or desc:IsA("LocalScript") then desc:Destroy() end
    end
    clone.Parent = world
    clone:PivotTo(CFrame.new(0,0,0))
    local camera = Instance.new("Camera")
    camera.CFrame = CFrame.lookAt(Vector3.new(0,2,9), Vector3.new(0,1,0))
    camera.Parent = viewport
    viewport.CurrentCamera = camera
    local dragging, lastX = false, 0
    viewport.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; lastX = input.Position.X
        end
    end)
    viewport.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    viewport.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            clone:PivotTo(clone:GetPivot() * CFrame.Angles(0,(input.Position.X-lastX)*.012,0))
            lastX = input.Position.X
        end
    end)
end})
InfoTab:Paragraph({Title="脚本信息", Desc="AI通用脚本 v11.6｜原版功能 + GitHub分区 + Lua脚本站 + 搜索 + 信息页"})
InfoTab:Button({Title="查看网站脚本信息", Callback=function()
    if #siteItems == 0 then siteNotify("脚本信息", "网站暂无脚本"); return end
    showScriptInfo(siteItems[1])
end})

local T4 = Win:Tab({ Title = "翻译", Icon = "languages" })
local T4Label = T4:Paragraph({ Title = "翻译脚本未加载", Desc = "点击下方按钮加载" })
local T4Btn = T4:Button({
    Title = "加载翻译脚本",
    Callback = function()
        loadFromGitHub("https://raw.githubusercontent.com/czy2778/rbczy/main/%E7%BF%BB%E8%AF%91.lua", "翻译")
    end,
})
_G.AITrans = { Tab = T4, Label = T4Label, Btn = T4Btn, Window = Win, Notify = W, Active = false }

local T5 = Win:Tab({ Title = "AI聊天", Icon = "message-circle" })
local T5Label = T5:Paragraph({ Title = "AI聊天脚本未加载", Desc = "点击下方按钮加载" })
local T5Btn = T5:Button({
    Title = "加载 AI聊天脚本",
    Callback = function()
        loadFromGitHub("https://raw.githubusercontent.com/czy2778/rbczy/main/%E7%BF%BB%E8%AF%91.lua", "AI聊天")
    end,
})
_G.AIChat = { Tab = T5, Label = T5Label, Btn = T5Btn, Window = Win, Notify = W, Active = false }

_G.AIDestroy = function()
    for _, c in pairs(EC) do c.b:Destroy() c.hl:Destroy() end
    EF:Destroy() SG:Destroy()
    _G.AILoaded = false
end

print("✅ AI通用脚本 v11.6 完整源码已加载")
