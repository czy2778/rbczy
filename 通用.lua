if _G.AILoaded then pcall(function() _G.AIDestroy() end) end
_G.AILoaded = true

local P = game:GetService("Players")
local R = game:GetService("RunService")
local C = game:GetService("CoreGui")
local L = P.LocalPlayer

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
Win:Tag({ Title = "v5.0", Color = "ElementBackground" })
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
}

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

local SG = Instance.new("ScreenGui")
SG.Name = "AIHUD"; SG.ResetOnSpawn = false; SG.Parent = C

local Cir = Instance.new("Frame")
Cir.Size = UDim2.new(0, S.AimRadius * 2, 0, S.AimRadius * 2)
Cir.Position = UDim2.new(0.5, -S.AimRadius, 0.5, -S.AimRadius)
Cir.BackgroundTransparency = 1
Cir.BorderSizePixel = 0
Cir.Visible = false
Cir.Parent = SG
local CirC = Instance.new("UICorner"); CirC.CornerRadius = UDim.new(1, 0); CirC.Parent = Cir
local CirS = Instance.new("UIStroke"); CirS.Color = S.AimColor; CirS.Thickness = 2; CirS.Parent = Cir

local EF = Instance.new("Folder"); EF.Name = "AIESP"; EF.Parent = C
local EC = {}

local function mkESP(u, isP)
    if EC[u.M] then return end
    local bb = Instance.new("BillboardGui")
    bb.Adornee = u.R
    bb.Size = UDim2.new(0, 220, 0, 60)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = EF
    local n = Instance.new("TextLabel")
    n.Size = UDim2.new(1, 0, 0, 18)
    n.BackgroundTransparency = 1
    n.TextColor3 = isP and Color3.fromRGB(255,150,0) or Color3.fromRGB(255,60,60)
    n.TextStrokeTransparency = 0
    n.TextScaled = true
    n.Font = Enum.Font.GothamBold
    n.Parent = bb
    local d = Instance.new("TextLabel")
    d.Size = UDim2.new(1, 0, 0, 14)
    d.Position = UDim2.new(0, 0, 0, 18)
    d.BackgroundTransparency = 1
    d.TextColor3 = Color3.fromRGB(255,255,100)
    d.TextStrokeTransparency = 0
    d.TextScaled = true
    d.Parent = bb
    local hb = Instance.new("Frame")
    hb.Size = UDim2.new(1, 0, 0, 5)
    hb.Position = UDim2.new(0, 0, 0, 36)
    hb.BackgroundColor3 = Color3.fromRGB(40,40,40)
    hb.BorderSizePixel = 0
    hb.Parent = bb
    local hr = Instance.new("Frame")
    hr.Size = UDim2.new(1, 0, 1, 0)
    hr.BackgroundColor3 = Color3.fromRGB(0,255,0)
    hr.BorderSizePixel = 0
    hr.Parent = hb
    local hl = Instance.new("Highlight")
    hl.Adornee = u.M
    hl.FillColor = isP and Color3.fromRGB(255,150,0) or Color3.fromRGB(255,0,0)
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = EF
    EC[u.M] = {b = bb, n = n, d = d, hr = hr, hb = hb, hl = hl, p = isP}
end

R.RenderStepped:Connect(function()
    local mr = L.Character and L.Character:FindFirstChild("HumanoidRootPart")
    local mp = mr and mr.Position or Vector3.zero
    local all = {}
    if S.AI then for _, n in ipairs(getNPCs()) do table.insert(all, n) end end
    if S.Player then for _, p in ipairs(getPlrs()) do table.insert(all, p) end end
    for _, u in ipairs(all) do
        if not EC[u.M] then mkESP(u, u.P) end
    end
    for m, c in pairs(EC) do
        local tOk = c.p and S.Player or S.AI
        if not m.Parent or not tOk then
            c.b:Destroy(); c.hl:Destroy(); EC[m] = nil
        else
            local r = m:FindFirstChild("HumanoidRootPart")
            local h = m:FindFirstChildOfClass("Humanoid")
            if r and h then
                local d = (r.Position - mp).Magnitude
                local sh = S.ESP and d <= S.MaxDist
                c.b.Enabled = sh; c.hl.Enabled = sh
                if sh then
                    c.b.Adornee = r; c.hl.Adornee = m
                    c.n.Visible = S.Name
                    c.d.Visible = S.Distance
                    c.hb.Visible = S.HpBar
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

local aConn
local function setupAim()
    if aConn then return end
    aConn = R.RenderStepped:Connect(function()
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

local nConn
local function setupNoclip()
    if nConn then return end
    nConn = R.Stepped:Connect(function()
        if not S.Noclip then return end
        local ch = L.Character
        if ch then
            for _, p in ipairs(ch:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
            end
        end
    end)
end

local sConn
local function setupSpeed()
    if sConn then return end
    sConn = R.Heartbeat:Connect(function()
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

-- ★ GitHub 拉取（中文路径用 %E9%80%9A%E7%94%A8 等 URL 编码）
local GITHUB_BASE = "https://raw.githubusercontent.com/czy2778/rbczy/main/"
local function loadFromGitHub(filename, label)
    local url = GITHUB_BASE .. filename
    local ok, code = pcall(function() return game:HttpGet(url) end)
    if not ok or not code or #code < 10 then
        W:Notify({ Title = label, Content = "拉取失败", Duration = 4 })
        return false
    end
    local fn, err = loadstring(code)
    if not fn then
        W:Notify({ Title = label, Content = "编译失败: " .. tostring(err):sub(1, 50), Duration = 5 })
        return false
    end
    local ok2, err2 = pcall(fn)
    if not ok2 then
        W:Notify({ Title = label, Content = "执行失败: " .. tostring(err2):sub(1, 50), Duration = 5 })
        return false
    end
    W:Notify({ Title = label, Content = "加载成功", Duration = 3 })
    return true
end

local T1 = Win:Tab({ Title = "透视", Icon = "eye" })
local T2 = Win:Tab({ Title = "自瞄", Icon = "crosshair" })
local T3 = Win:Tab({ Title = "移动", Icon = "move" })

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

T3:Button({ Title = "加载飞行脚本", Callback = function() loadFromGitHub("fly.lua", "飞行") end })
T3:Toggle({ Title = "穿墙", Value = false, Callback = function(v) S.Noclip = v if v then setupNoclip() end end })
T3:Toggle({ Title = "移速", Value = false, Callback = function(v) S.Speed = v if v then setupSpeed() end end })
T3:Slider({ Title = "移速值", Value = {Min=16, Max=200, Default=50}, Callback = function(v) S.SpeedValue = v end })

local T4 = Win:Tab({ Title = "翻译", Icon = "languages" })
local T4Label = T4:Paragraph({ Title = "翻译脚本未加载", Desc = "点击下方按钮加载" })
local T4Btn = T4:Button({
    Title = "加载翻译脚本",
    Callback = function() loadFromGitHub("%E7%BF%BB%E8%AF%91.lua", "翻译") end,
})
_G.AITrans = { Tab = T4, Label = T4Label, Btn = T4Btn, Window = Win, Notify = W, Active = false }

local T5 = Win:Tab({ Title = "AI聊天", Icon = "message-circle" })
local T5Label = T5:Paragraph({ Title = "AI聊天脚本未加载", Desc = "点击下方按钮加载" })
local T5Btn = T5:Button({
    Title = "加载 AI聊天脚本",
    Callback = function() loadFromGitHub("chat.lua", "AI聊天") end,
})
_G.AIChat = { Tab = T5, Label = T5Label, Btn = T5Btn, Window = Win, Notify = W, Active = false }

_G.AIDestroy = function()
    for _, c in pairs(EC) do c.b:Destroy() c.hl:Destroy() end
    EF:Destroy()
    SG:Destroy()
    _G.AILoaded = false
end

print("✅ 通用脚本已加载")
