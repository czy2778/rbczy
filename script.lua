--By XingQing 整合版
repeat task.wait() until game:IsLoaded()

--=====================================================
-- 加载 WindUI
--=====================================================
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/finendss/VowLibrary/refs/heads/main/WINDUI.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

--=====================================================
-- 全局设置
--=====================================================
_G.XQ = _G.XQ or {}
_G.XQ.Settings = {
    Aimbot = false, AimTarget = "Head", FOV = 150, Smoothness = 0.25,
    ShowFOV = true, ShowTargetName = true,
    ShowAimbotBtn = true,
    ShowLockBtn = true,
    LockMode = "Crosshair",
    AutoShoot = false, ShootDelay = 0.1,
    AutoSprint = false, SpeedHack = false, WalkSpeed = 16, JumpPower = 50,
    InfiniteJump = false, Noclip = false,
    ESPPlayer = false, ESPAI = false,
    ESPShowName = true, ESPShowHealth = true,
    ESPNameSize = 14, ESPHealthSize = 12,
    AutoInteract = false, InfiniteAmmo = false,
    FlyEnabled = false, FlySpeed = 1,
    AimMode = "Player",
}
local Settings = _G.XQ.Settings

--=====================================================
-- 创建窗口
--=====================================================
local Window = WindUI:CreateWindow({
    Title = '超级无敌牛逼雇佣兵脚本',
    Icon = "crown",
    Author = "Czy",
    Size = UDim2.fromOffset(600, 480),
    Transparent = true,
    Theme = "FIN",
    HideSearchBar = false,
    ScrollBarEnabled = true,
    Resizable = true,
})

Window:Tag({ Title = "豆大师版", Color = Color3.fromHex("#7FDBFF") })

Window:EditOpenButton({
    Title = "军事大亨脚本",
    Icon = "monitor",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("FF6B6B")),
    Draggable = true,
})

_G.XQ.Notify = function(t, c, d)
    WindUI:Notify({Title = t, Content = c, Duration = d or 3})
end

--=====================================================
-- UI 构建
--=====================================================
local Tab = Window:Tab({ Title = "主要功能", Icon = "settings" })

Tab:Section({ Title = "瞄准", TextXAlignment = "Left", TextSize = 17 })

Tab:Toggle({ Title = "Aimbot 锁头", Default = false, Callback = function(v) Settings.Aimbot = v end })
Tab:Toggle({ Title = "显示自瞄开关悬浮窗", Default = true, Callback = function(v) Settings.ShowAimbotBtn = v end })
Tab:Toggle({ Title = "显示锁定目标切换悬浮窗", Default = true, Callback = function(v) Settings.ShowLockBtn = v end })

Tab:Dropdown({
    Title = "锁人方式",
    Values = { "离准心最近", "离我最近" },
    Value = "离准心最近",
    Callback = function(v)
        Settings.LockMode = (v == "离我最近") and "Distance" or "Crosshair"
    end
})

Tab:Dropdown({ Title = "瞄准部位", Values = { "Head", "HumanoidRootPart", "UpperTorso" }, Value = "Head", Callback = function(v) Settings.AimTarget = v end })
Tab:Slider({ Title = "FOV范围", Value = { Min = 30, Max = 500, Default = 150 }, Increment = 5, Callback = function(v) Settings.FOV = v end })
Tab:Slider({ Title = "锁定平滑度", Value = { Min = 0.05, Max = 1, Default = 0.25 }, Increment = 0.05, Callback = function(v) Settings.Smoothness = v end })
Tab:Toggle({ Title = "显示FOV圈", Default = true, Callback = function(v) Settings.ShowFOV = v end })
Tab:Toggle({ Title = "FOV圈上方显示锁定敌人", Default = true, Callback = function(v) Settings.ShowTargetName = v end })
Tab:Toggle({ Title = "自动射击", Default = false, Callback = function(v) Settings.AutoShoot = v end })
Tab:Slider({ Title = "射击间隔", Value = { Min = 0.03, Max = 0.5, Default = 0.1 }, Increment = 0.01, Callback = function(v) Settings.ShootDelay = v end })

Tab:Section({ Title = "武器", TextXAlignment = "Left", TextSize = 17 })
Tab:Toggle({ Title = "无限子弹", Default = false, Callback = function(v) Settings.InfiniteAmmo = v end })

Tab:Section({ Title = "交互", TextXAlignment = "Left", TextSize = 17 })
Tab:Toggle({ Title = "自动交互", Default = false, Callback = function(v) Settings.AutoInteract = v end })
Tab:Toggle({ Title = "自动冲刺", Default = false, Callback = function(v) Settings.AutoSprint = v end })

Tab:Section({ Title = "角色", TextXAlignment = "Left", TextSize = 17 })
Tab:Toggle({ Title = "加速", Default = false, Callback = function(v) Settings.SpeedHack = v end })
Tab:Slider({ Title = "移动速度", Value = { Min = 16, Max = 200, Default = 16 }, Increment = 1, Callback = function(v) Settings.WalkSpeed = v end })
Tab:Slider({ Title = "跳跃力", Value = { Min = 50, Max = 300, Default = 50 }, Increment = 1, Callback = function(v) Settings.JumpPower = v end })
Tab:Toggle({ Title = "无限跳", Default = false, Callback = function(v) Settings.InfiniteJump = v end })
Tab:Toggle({ Title = "穿墙", Default = false, Callback = function(v) Settings.Noclip = v end })

Tab:Section({ Title = "飞行", TextXAlignment = "Left", TextSize = 17 })
Tab:Button({
    Title = "加载飞行面板",
    Callback = function()
        if _G.XQ.LoadFly then _G.XQ.LoadFly()
        else WindUI:Notify({Title = "飞行", Content = "稍等，正在加载", Duration = 3}) end
    end
})

Tab:Section({ Title = "视觉", TextXAlignment = "Left", TextSize = 17 })

Tab:Toggle({ Title = "玩家透视（绿色）", Default = false, Callback = function(v) Settings.ESPPlayer = v end })
Tab:Toggle({ Title = "AI透视（橙色）", Default = false, Callback = function(v) Settings.ESPAI = v end })
Tab:Toggle({ Title = "ESP显示名字", Default = true, Callback = function(v) Settings.ESPShowName = v end })
Tab:Slider({ Title = "名字大小", Value = { Min = 8, Max = 30, Default = 14 }, Increment = 1, Callback = function(v) Settings.ESPNameSize = v end })
Tab:Toggle({ Title = "ESP显示血量", Default = true, Callback = function(v) Settings.ESPShowHealth = v end })
Tab:Slider({ Title = "血量大小", Value = { Min = 8, Max = 30, Default = 12 }, Increment = 1, Callback = function(v) Settings.ESPHealthSize = v end })

_G.XQ.Notify("UI已加载", "功能正在后台加载", 3)

--=====================================================
-- 功能代码（后台加载，避免卡UI）
--=====================================================
task.spawn(function()
    task.wait(1)  -- 等待UI渲染完成

    print(">>> 功能代码开始加载")

    --=================================================
    -- 两个悬浮窗
    --=================================================
    local aimbotBtn, lockBtn

    pcall(function()
        local pg = LocalPlayer:WaitForChild("PlayerGui", 5)
        local sg = Instance.new("ScreenGui")
        sg.Name = "XQ_AimbotBtn"
        sg.IgnoreGuiInset = true
        sg.ResetOnSpawn = false
        sg.DisplayOrder = 998
        sg.Parent = pg

        aimbotBtn = Instance.new("TextButton")
        aimbotBtn.Size = UDim2.fromOffset(100, 45)
        aimbotBtn.Position = UDim2.new(0, 20, 0.5, -60)
        aimbotBtn.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
        aimbotBtn.BackgroundTransparency = 0.15
        aimbotBtn.Text = "自瞄:关"
        aimbotBtn.TextColor3 = Color3.new(1, 1, 1)
        aimbotBtn.TextSize = 16
        aimbotBtn.Font = Enum.Font.GothamBold
        aimbotBtn.Active = true
        aimbotBtn.Draggable = true
        aimbotBtn.Visible = false
        aimbotBtn.Parent = sg

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = aimbotBtn

        aimbotBtn.MouseButton1Click:Connect(function()
            Settings.Aimbot = not Settings.Aimbot
        end)
    end)

    pcall(function()
        local pg = LocalPlayer:WaitForChild("PlayerGui", 5)
        local sg = Instance.new("ScreenGui")
        sg.Name = "XQ_LockBtn"
        sg.IgnoreGuiInset = true
        sg.ResetOnSpawn = false
        sg.DisplayOrder = 998
        sg.Parent = pg

        lockBtn = Instance.new("TextButton")
        lockBtn.Size = UDim2.fromOffset(100, 45)
        lockBtn.Position = UDim2.new(0, 20, 0.5, -10)
        lockBtn.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
        lockBtn.BackgroundTransparency = 0.15
        lockBtn.Text = "锁:玩家"
        lockBtn.TextColor3 = Color3.new(1, 1, 1)
        lockBtn.TextSize = 16
        lockBtn.Font = Enum.Font.GothamBold
        lockBtn.Active = true
        lockBtn.Draggable = true
        lockBtn.Visible = false
        lockBtn.Parent = sg

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = lockBtn

        lockBtn.MouseButton1Click:Connect(function()
            if Settings.AimMode == "Player" then
                Settings.AimMode = "AI"
            else
                Settings.AimMode = "Player"
            end
        end)
    end)

    task.spawn(function()
        while task.wait(0.2) do
            pcall(function()
                if aimbotBtn then
                    aimbotBtn.Visible = Settings.ShowAimbotBtn
                    if Settings.Aimbot then
                        aimbotBtn.Text = "自瞄:开"
                        aimbotBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
                    else
                        aimbotBtn.Text = "自瞄:关"
                        aimbotBtn.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
                    end
                end
                if lockBtn then
                    lockBtn.Visible = Settings.ShowLockBtn and Settings.Aimbot
                    if Settings.AimMode == "AI" then
                        lockBtn.Text = "锁:AI"
                        lockBtn.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
                    else
                        lockBtn.Text = "锁:玩家"
                        lockBtn.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
                    end
                end
            end)
        end
    end)

    --=================================================
    -- FOV圈
    --=================================================
    local fovGui, fovFrame, targetLabel
    pcall(function()
        local pg = LocalPlayer:WaitForChild("PlayerGui", 5)
        fovGui = Instance.new("ScreenGui")
        fovGui.Name = "XQ_FOV"
        fovGui.IgnoreGuiInset = true
        fovGui.ResetOnSpawn = false
        fovGui.DisplayOrder = 999
        fovGui.Parent = pg

        fovFrame = Instance.new("Frame")
        fovFrame.BackgroundTransparency = 1
        fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        fovFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        fovFrame.Size = UDim2.fromOffset(Settings.FOV * 2, Settings.FOV * 2)
        fovFrame.Parent = fovGui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = fovFrame

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1.5
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Transparency = 0.3
        stroke.Parent = fovFrame

        targetLabel = Instance.new("TextLabel")
        targetLabel.BackgroundTransparency = 1
        targetLabel.AnchorPoint = Vector2.new(0.5, 1)
        targetLabel.Position = UDim2.new(0.5, 0, 0.5, -(Settings.FOV + 20))
        targetLabel.Size = UDim2.fromOffset(300, 30)
        targetLabel.Font = Enum.Font.GothamBold
        targetLabel.TextSize = 18
        targetLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        targetLabel.TextStrokeTransparency = 0
        targetLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        targetLabel.Text = ""
        targetLabel.Parent = fovGui
    end)

    task.spawn(function()
        while task.wait(0.05) do
            pcall(function()
                if not fovGui then return end
                fovGui.Enabled = Settings.ShowFOV or Settings.ShowTargetName
                if fovFrame then
                    fovFrame.Visible = Settings.ShowFOV
                    fovFrame.Size = UDim2.fromOffset(Settings.FOV * 2, Settings.FOV * 2)
                end
                if targetLabel then
                    targetLabel.Visible = Settings.ShowTargetName
                    targetLabel.Position = UDim2.new(0.5, 0, 0.5, -(Settings.FOV + 20))
                end
            end)
        end
    end)

    --=================================================
    -- 找目标
    --=================================================
    local function getTarget()
        local myChar = LocalPlayer.Character
        if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
        local myPos = myChar.HumanoidRootPart.Position
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local closest, bestScore = nil, math.huge

        local function checkChar(char, isPlayer)
            if char == myChar then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then return end
            local part = char:FindFirstChild(Settings.AimTarget) or char:FindFirstChild("HumanoidRootPart")
            if not part then return end
            local worldDist = (part.Position - myPos).Magnitude
            if worldDist >= 800 then return end
            local sp, on = Camera:WorldToViewportPoint(part.Position)
            if not on then return end
            local screenDist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
            if screenDist > Settings.FOV then return end
            local score = (Settings.LockMode == "Distance") and worldDist or screenDist
            if score < bestScore then
                bestScore = score
                closest = {char = char, part = part, hum = hum, isPlayer = isPlayer}
            end
        end

        if Settings.AimMode == "Player" then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    checkChar(plr.Character, true)
                end
            end
        else
            local map = workspace:FindFirstChild("Map")
            local creatures = map and map:FindFirstChild("Creatures")
            if creatures then
                for _, c in pairs(creatures:GetChildren()) do
                    checkChar(c, false)
                end
            end
        end
        return closest
    end

    --=================================================
    -- Aimbot
    --=================================================
    RunService.RenderStepped:Connect(function()
        pcall(function()
            if not Settings.Aimbot then return end
            local t = getTarget()
            if not t or not t.part then
                if targetLabel then targetLabel.Text = "" end
                return
            end
            local targetCF = CFrame.new(Camera.CFrame.Position, t.part.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, Settings.Smoothness)
            if targetLabel then
                local nm = t.isPlayer and t.char.Name or ("AI: " .. t.char.Name)
                targetLabel.Text = "锁定: " .. nm
                targetLabel.TextColor3 = t.isPlayer and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 165, 0)
            end
        end)
    end)

    --=================================================
    -- 自动射击
    --=================================================
    task.spawn(function()
        while task.wait(Settings.ShootDelay) do
            if Settings.AutoShoot then
                pcall(function()
                    local pg = LocalPlayer:FindFirstChild("PlayerGui")
                    local gunUi = pg and pg:FindFirstChild("GunUi")
                    local shootBtn = gunUi and gunUi:FindFirstChild("ShootButton")
                    local activate = shootBtn and shootBtn:FindFirstChild("ActivateButton")
                    if activate then
                        for _, c in pairs(activate:GetDescendants()) do
                            if (c:IsA("TextButton") or c:IsA("ImageButton")) and c.Visible then
                                if firesignal then firesignal(c.MouseButton1Click) else c.MouseButton1Click:Fire() end
                            end
                        end
                    end
                end)
            end
        end
    end)

    --=================================================
    -- 无限子弹
    --=================================================
    task.spawn(function()
        while task.wait(0.1) do
            if Settings.InfiniteAmmo then
                pcall(function()
                    local char = LocalPlayer.Character
                    if char then
                        for _, tool in pairs(char:GetChildren()) do
                            if tool:IsA("Tool") then
                                for _, v in pairs(tool:GetDescendants()) do
                                    if v:IsA("IntValue") or v:IsA("NumberValue") then
                                        local n = v.Name:lower()
                                        if n:find("ammo") or n:find("clip") or n:find("mag") then
                                            v.Value = 999
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)

    --=================================================
    -- 自动冲刺
    --=================================================
    local SprintSwitch
    pcall(function()
        local Events = ReplicatedStorage:WaitForChild("Events", 10)
        SprintSwitch = Events and Events:WaitForChild("SprintSwitch", 5)
    end)

    task.spawn(function()
        while task.wait(0.8) do
            if Settings.AutoSprint and SprintSwitch then
                pcall(function()
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") and char.Humanoid.MoveDirection.Magnitude > 0 then
                        SprintSwitch:FireServer(true)
                    end
                end)
            end
        end
    end)

    --=================================================
    -- 自动交互
    --=================================================
    task.spawn(function()
        while task.wait(0.3) do
            if Settings.AutoInteract then
                pcall(function()
                    if not fireproximityprompt then return end
                    local char = LocalPlayer.Character
                    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                    local myPos = char.HumanoidRootPart.Position
                    for _, d in pairs(workspace:GetDescendants()) do
                        if d:IsA("ProximityPrompt") and d.Enabled then
                            local p = d.Parent
                            if p and p:IsA("BasePart") and (p.Position - myPos).Magnitude < 25 then
                                fireproximityprompt(d)
                            end
                        end
                    end
                end)
            end
        end
    end)

    --=================================================
    -- 角色功能
    --=================================================
    RunService.Heartbeat:Connect(function()
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            if Settings.SpeedHack and not Settings.FlyEnabled then
                hum.WalkSpeed = Settings.WalkSpeed
                hum.UseJumpPower = true
                hum.JumpPower = Settings.JumpPower
            end
            if Settings.Noclip then
                for _, p in pairs(char:GetDescendants()) do
                    if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
                end
            end
        end)
    end)

    UIS.JumpRequest:Connect(function()
        pcall(function()
            if Settings.InfiniteJump then
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    end)

    --=================================================
    -- ESP
    --=================================================
    local PlayerESP = {}
    local AIESP = {}

    local PLAYER_COLOR = Color3.fromRGB(0, 255, 0)
    local AI_COLOR = Color3.fromRGB(255, 165, 0)

    local function makeESP(char, name, color, store, key)
        if store[key] then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
        if not hum or not hrp then return end

        local hl = Instance.new("Highlight")
        hl.FillColor = color
        hl.FillTransparency = 1
        hl.OutlineColor = color
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee = char
        hl.Parent = char

        local nameBB = Instance.new("BillboardGui")
        nameBB.Adornee = hrp
        nameBB.Size = UDim2.new(0, 200, 0, 25)
        nameBB.StudsOffset = Vector3.new(0, 3.5, 0)
        nameBB.AlwaysOnTop = true
        nameBB.Parent = char

        local nameText = Instance.new("TextLabel")
        nameText.Size = UDim2.new(1, 0, 1, 0)
        nameText.BackgroundTransparency = 1
        nameText.Text = name
        nameText.TextColor3 = color
        nameText.TextStrokeTransparency = 0
        nameText.TextStrokeColor3 = Color3.new(0, 0, 0)
        nameText.Font = Enum.Font.GothamBold
        nameText.TextSize = Settings.ESPNameSize
        nameText.Parent = nameBB

        local hpBB = Instance.new("BillboardGui")
        hpBB.Adornee = hrp
        hpBB.Size = UDim2.new(0, 200, 0, 20)
        hpBB.StudsOffset = Vector3.new(0, 2.7, 0)
        hpBB.AlwaysOnTop = true
        hpBB.Parent = char

        local hpText = Instance.new("TextLabel")
        hpText.Size = UDim2.new(1, 0, 1, 0)
        hpText.BackgroundTransparency = 1
        hpText.Text = "100"
        hpText.TextColor3 = Color3.fromRGB(0, 255, 100)
        hpText.TextStrokeTransparency = 0
        hpText.TextStrokeColor3 = Color3.new(0, 0, 0)
        hpText.Font = Enum.Font.GothamBold
        hpText.TextSize = Settings.ESPHealthSize
        hpText.Parent = hpBB

        store[key] = {hl = hl, nameBB = nameBB, hpBB = hpBB, nameText = nameText, hpText = hpText, char = char, color = color}
    end

    local function destroyESP(obj)
        pcall(function()
            if obj.hl then obj.hl:Destroy() end
            if obj.nameBB then obj.nameBB:Destroy() end
            if obj.hpBB then obj.hpBB:Destroy() end
        end)
    end

    task.spawn(function()
        while task.wait(0.15) do
            pcall(function()
                if Settings.ESPPlayer then
                    for _, plr in pairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                            if not PlayerESP[plr] then
                                makeESP(plr.Character, plr.Name, PLAYER_COLOR, PlayerESP, plr)
                            end
                        end
                    end
                    for plr, obj in pairs(PlayerESP) do
                        local char = plr.Character
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        if not char or not hum or hum.Health <= 0 then
                            destroyESP(obj)
                            PlayerESP[plr] = nil
                        else
                            obj.hl.OutlineColor = PLAYER_COLOR
                            obj.nameText.TextColor3 = PLAYER_COLOR
                            obj.nameText.Text = plr.Name
                            obj.nameBB.Enabled = Settings.ESPShowName
                            obj.hpBB.Enabled = Settings.ESPShowHealth
                            obj.nameText.TextSize = Settings.ESPNameSize
                            obj.hpText.TextSize = Settings.ESPHealthSize
                            local hp = math.floor(hum.Health)
                            local maxHp = math.floor(hum.MaxHealth)
                            obj.hpText.Text = hp .. " / " .. maxHp
                            local r = hum.Health / math.max(hum.MaxHealth, 1)
                            obj.hpText.TextColor3 = Color3.fromRGB(math.floor(255*(1-r)), math.floor(255*r), 50)
                        end
                    end
                else
                    for k, obj in pairs(PlayerESP) do destroyESP(obj) PlayerESP[k] = nil end
                end

                if Settings.ESPAI then
                    local map = workspace:FindFirstChild("Map")
                    local creatures = map and map:FindFirstChild("Creatures")
                    if creatures then
                        for _, c in pairs(creatures:GetChildren()) do
                            if c:FindFirstChildOfClass("Humanoid") and c:FindFirstChild("HumanoidRootPart") then
                                if not AIESP[c] then
                                    makeESP(c, "AI: " .. c.Name, AI_COLOR, AIESP, c)
                                end
                            end
                        end
                    end
                    for c, obj in pairs(AIESP) do
                        local hum = c:FindFirstChildOfClass("Humanoid")
                        if not c.Parent or not hum or hum.Health <= 0 then
                            destroyESP(obj)
                            AIESP[c] = nil
                        else
                            obj.hl.OutlineColor = AI_COLOR
                            obj.nameText.TextColor3 = AI_COLOR
                            obj.nameText.Text = "AI: " .. c.Name
                            obj.nameBB.Enabled = Settings.ESPShowName
                            obj.hpBB.Enabled = Settings.ESPShowHealth
                            obj.nameText.TextSize = Settings.ESPNameSize
                            obj.hpText.TextSize = Settings.ESPHealthSize
                            local hp = math.floor(hum.Health)
                            local maxHp = math.floor(hum.MaxHealth)
                            obj.hpText.Text = hp .. " / " .. maxHp
                            local r = hum.Health / math.max(hum.MaxHealth, 1)
                            obj.hpText.TextColor3 = Color3.fromRGB(math.floor(255*(1-r)), math.floor(255*r), 50)
                        end
                    end
                else
                    for k, obj in pairs(AIESP) do destroyESP(obj) AIESP[k] = nil end
                end
            end)
        end
    end)

    Players.PlayerRemoving:Connect(function(plr)
        if PlayerESP[plr] then
            destroyESP(PlayerESP[plr])
            PlayerESP[plr] = nil
        end
    end)

    --=================================================
    -- 飞行（优化UI版）
    --=================================================
    _G.XQ.LoadFly = function()
        if _G.XQ_FlyLoaded then
            WindUI:Notify({Title = "飞行", Content = "已经加载过了", Duration = 3})
            return
        end
        _G.XQ_FlyLoaded = true

        pcall(function()
            local old = LocalPlayer.PlayerGui:FindFirstChild("XQ_FlyUI")
            if old then old:Destroy() end
        end)

        local main = Instance.new("ScreenGui")
        main.Name = "XQ_FlyUI"
        main.Parent = LocalPlayer:WaitForChild("PlayerGui")
        main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        main.ResetOnSpawn = false
        main.IgnoreGuiInset = true
        main.DisplayOrder = 1000

        local Frame = Instance.new("Frame")
        Frame.Name = "Panel"
        Frame.Parent = main
        Frame.BackgroundColor3 = Color3.fromRGB(25, 28, 35)
        Frame.BackgroundTransparency = 0.15
        Frame.BorderSizePixel = 0
        Frame.Position = UDim2.new(0.1, 0, 0.35, 0)
        Frame.Size = UDim2.new(0, 210, 0, 120)
        Frame.Active = true
        Frame.Draggable = true

        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 12)
        frameCorner.Parent = Frame

        local frameStroke = Instance.new("UIStroke")
        frameStroke.Color = Color3.fromRGB(80, 200, 255)
        frameStroke.Thickness = 1.5
        frameStroke.Transparency = 0.3
        frameStroke.Parent = Frame

        local titleBar = Instance.new("Frame")
        titleBar.Parent = Frame
        titleBar.BackgroundColor3 = Color3.fromRGB(40, 45, 55)
        titleBar.BackgroundTransparency = 0.1
        titleBar.BorderSizePixel = 0
        titleBar.Position = UDim2.new(0, 0, 0, 0)
        titleBar.Size = UDim2.new(1, 0, 0, 30)

        local titleCorner = Instance.new("UICorner")
        titleCorner.CornerRadius = UDim.new(0, 12)
        titleCorner.Parent = titleBar

        local titleText = Instance.new("TextLabel")
        titleText.Parent = titleBar
        titleText.BackgroundTransparency = 1
        titleText.Position = UDim2.new(0, 35, 0, 0)
        titleText.Size = UDim2.new(1, -100, 1, 0)
        titleText.Font = Enum.Font.GothamBold
        titleText.Text = "飞行控制"
        titleText.TextColor3 = Color3.fromRGB(220, 240, 255)
        titleText.TextSize = 14
        titleText.TextXAlignment = Enum.TextXAlignment.Left

        local closeBtn = Instance.new("TextButton")
        closeBtn.Parent = titleBar
        closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        closeBtn.BackgroundTransparency = 0.2
        closeBtn.BorderSizePixel = 0
        closeBtn.Position = UDim2.new(1, -30, 0, 4)
        closeBtn.Size = UDim2.new(0, 22, 0, 22)
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.Text = "×"
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.TextSize = 16
        closeBtn.AutoButtonColor = false

        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(1, 0)
        closeCorner.Parent = closeBtn

        local minBtn = Instance.new("TextButton")
        minBtn.Parent = titleBar
        minBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 60)
        minBtn.BackgroundTransparency = 0.2
        minBtn.BorderSizePixel = 0
        minBtn.Position = UDim2.new(1, -58, 0, 4)
        minBtn.Size = UDim2.new(0, 22, 0, 22)
        minBtn.Font = Enum.Font.GothamBold
        minBtn.Text = "−"
        minBtn.TextColor3 = Color3.fromRGB(40, 40, 40)
        minBtn.TextSize = 16
        minBtn.AutoButtonColor = false

        local minCorner = Instance.new("UICorner")
        minCorner.CornerRadius = UDim.new(1, 0)
        minCorner.Parent = minBtn

        local function makeBtn(parent, text, pos, size, color)
            local btn = Instance.new("TextButton")
            btn.Parent = parent
            btn.BackgroundColor3 = color or Color3.fromRGB(55, 60, 75)
            btn.BackgroundTransparency = 0.1
            btn.BorderSizePixel = 0
            btn.Position = pos
            btn.Size = size
            btn.Font = Enum.Font.GothamBold
            btn.Text = text
            btn.TextColor3 = Color3.fromRGB(230, 240, 255)
            btn.TextSize = 16
            btn.AutoButtonColor = false

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = btn

            btn.MouseButton1Down:Connect(function()
                btn.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
            end)
            btn.MouseButton1Up:Connect(function()
                btn.BackgroundColor3 = color or Color3.fromRGB(55, 60, 75)
            end)
            return btn
        end

        local up = makeBtn(Frame, "▲", UDim2.new(0, 12, 0, 40), UDim2.new(0, 50, 0, 32), Color3.fromRGB(60, 180, 100))
        local down = makeBtn(Frame, "▼", UDim2.new(0, 12, 0, 78), UDim2.new(0, 50, 0, 32), Color3.fromRGB(180, 120, 60))
        local mine = makeBtn(Frame, "−", UDim2.new(0, 70, 0, 40), UDim2.new(0, 40, 0, 32), Color3.fromRGB(100, 100, 120))
        local plus = makeBtn(Frame, "+", UDim2.new(0, 158, 0, 40), UDim2.new(0, 40, 0, 32), Color3.fromRGB(100, 100, 120))

        local speed = Instance.new("TextLabel")
        speed.Parent = Frame
        speed.BackgroundColor3 = Color3.fromRGB(40, 45, 55)
        speed.BackgroundTransparency = 0.1
        speed.BorderSizePixel = 0
        speed.Position = UDim2.new(0, 114, 0, 40)
        speed.Size = UDim2.new(0, 40, 0, 32)
        speed.Font = Enum.Font.GothamBold
        speed.Text = "1"
        speed.TextColor3 = Color3.fromRGB(255, 200, 100)
        speed.TextSize = 18

        local speedCorner = Instance.new("UICorner")
        speedCorner.CornerRadius = UDim.new(0, 8)
        speedCorner.Parent = speed

        local onof = makeBtn(Frame, "开启飞行", UDim2.new(0, 70, 0, 80), UDim2.new(0, 128, 0, 32), Color3.fromRGB(255, 180, 60))
        onof.TextColor3 = Color3.fromRGB(40, 40, 40)

        local expandBtn = makeBtn(main, "飞行", UDim2.new(0, 20, 0.4, 0), UDim2.new(0, 70, 0, 34), Color3.fromRGB(255, 180, 60))
        expandBtn.TextColor3 = Color3.fromRGB(40, 40, 40)
        expandBtn.Visible = false

        closeBtn.MouseButton1Click:Connect(function()
            main:Destroy()
        end)

        minBtn.MouseButton1Click:Connect(function()
            Frame.Visible = false
            expandBtn.Visible = true
        end)

        expandBtn.MouseButton1Click:Connect(function()
            Frame.Visible = true
            expandBtn.Visible = false
        end)

        -- 飞行核心
        speeds = 1
        nowe = false

        local function toggleFly()
            if not LocalPlayer.Character then return end
            local ch = LocalPlayer.Character
            if not ch:FindFirstChildOfClass("Humanoid") then return end

            if nowe == true then
                nowe = false
                onof.Text = "开启飞行"
                onof.BackgroundColor3 = Color3.fromRGB(255, 180, 60)

                ch.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,true)
                ch.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)
                ch.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,true)
                ch.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,true)
                ch.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,true)
                ch.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,true)
                ch.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,true)
                ch.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,true)
                ch.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,true)
                ch.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,true)
                ch.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,true)
                ch.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,true)
                ch.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
                ch.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,true)
                ch.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,true)
                ch.Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
            else
                nowe = true
                onof.Text = "关闭飞行"
                onof.BackgroundColor3 = Color3.fromRGB(80, 220, 130)

                for i = 1, speeds do
                    spawn(function()
                        local hb = game:GetService("RunService").Heartbeat
                        tpwalking = true
                        local c = game.Players.LocalPlayer.Character
                        local h = c and c:FindFirstChildWhichIsA("Humanoid")
                        while tpwalking and hb:Wait() and c and h and h.Parent do
                            if h.MoveDirection.Magnitude > 0 then
                                c:TranslateBy(h.MoveDirection)
                            end
                        end
                    end)
                end
                if ch:FindFirstChild("Animate") then
                    ch.Animate.Disabled = true
                end
                local Hum = ch:FindFirstChildOfClass("Humanoid") or ch:FindFirstChildOfClass("AnimationController")
                if Hum then
                    for i,v in next, Hum:GetPlayingAnimationTracks() do
                        v:AdjustSpeed(0)
                    end
                end

                ch.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,false)
                ch.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
                ch.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,false)
                ch.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,false)
                ch.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)
                ch.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
                ch.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,false)
                ch.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,false)
                ch.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,false)
                ch.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
                ch.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,false)
                ch.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,false)
                ch.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
                ch.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,false)
                ch.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,false)
                ch.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
            end

            if ch:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then
                local torso = ch.Torso
                if not torso then return end
                local ctrl = {f = 0, b = 0, l = 0, r = 0}
                local lastctrl = {f = 0, b = 0, l = 0, r = 0}
                local maxspeed = 50
                local sp = 0

                local bg = Instance.new("BodyGyro", torso)
                bg.P = 9e4
                bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
                bg.cframe = torso.CFrame
                local bv = Instance.new("BodyVelocity", torso)
                bv.velocity = Vector3.new(0,0.1,0)
                bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
                if nowe then ch.Humanoid.PlatformStand = true end

                while nowe == true and ch and ch.Parent and ch:FindFirstChildOfClass("Humanoid") do
                    game:GetService("RunService").RenderStepped:Wait()
                    if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
                        sp = sp+.5+(sp/maxspeed)
                        if sp > maxspeed then sp = maxspeed end
                    elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and sp ~= 0 then
                        sp = sp-1
                        if sp < 0 then sp = 0 end
                    end
                    if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
                        bv.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - workspace.CurrentCamera.CoordinateFrame.p))*sp
                        lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
                    elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and sp ~= 0 then
                        bv.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - workspace.CurrentCamera.CoordinateFrame.p))*sp
                    else
                        bv.velocity = Vector3.new(0,0,0)
                    end
                    bg.cframe = workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*sp/maxspeed),0,0)
                end
                bg:Destroy()
                bv:Destroy()
                if ch:FindFirstChildOfClass("Humanoid") then
                    ch.Humanoid.PlatformStand = false
                end
                if ch:FindFirstChild("Animate") then
                    ch.Animate.Disabled = false
                end
                tpwalking = false
            else
                local UpperTorso = ch:FindFirstChild("UpperTorso")
                if not UpperTorso then return end
                local ctrl = {f = 0, b = 0, l = 0, r = 0}
                local lastctrl = {f = 0, b = 0, l = 0, r = 0}
                local maxspeed = 50
                local sp = 0

                local bg = Instance.new("BodyGyro", UpperTorso)
                bg.P = 9e4
                bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
                bg.cframe = UpperTorso.CFrame
                local bv = Instance.new("BodyVelocity", UpperTorso)
                bv.velocity = Vector3.new(0,0.1,0)
                bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
                if nowe then ch.Humanoid.PlatformStand = true end

                while nowe == true and ch and ch.Parent and ch:FindFirstChildOfClass("Humanoid") do
                    wait()
                    if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
                        sp = sp+.5+(sp/maxspeed)
                        if sp > maxspeed then sp = maxspeed end
                    elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and sp ~= 0 then
                        sp = sp-1
                        if sp < 0 then sp = 0 end
                    end
                    if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
                        bv.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - workspace.CurrentCamera.CoordinateFrame.p))*sp
                        lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
                    elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and sp ~= 0 then
                        bv.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - workspace.CurrentCamera.CoordinateFrame.p))*sp
                    else
                        bv.velocity = Vector3.new(0,0,0)
                    end
                    bg.cframe = workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*sp/maxspeed),0,0)
                end
                bg:Destroy()
                bv:Destroy()
                if ch:FindFirstChildOfClass("Humanoid") then
                    ch.Humanoid.PlatformStand = false
                end
                if ch:FindFirstChild("Animate") then
                    ch.Animate.Disabled = false
                end
                tpwalking = false
            end
        end

        onof.MouseButton1Down:Connect(toggleFly)

        local tis
        up.MouseButton1Down:Connect(function()
            tis = up.MouseEnter:Connect(function()
                while tis do
                    wait()
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,1,0)
                    end
                end
            end)
        end)
        up.MouseLeave:Connect(function()
            if tis then tis:Disconnect() tis = nil end
        end)

        local dis
        down.MouseButton1Down:Connect(function()
            dis = down.MouseEnter:Connect(function()
                while dis do
                    wait()
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,-1,0)
                    end
                end
            end)
        end)
        down.MouseLeave:Connect(function()
            if dis then dis:Disconnect() dis = nil end
        end)

        plus.MouseButton1Down:Connect(function()
            speeds = speeds + 1
            speed.Text = tostring(speeds)
            if nowe == true then
                tpwalking = false
                for i = 1, speeds do
                    spawn(function()
                        local hb = game:GetService("RunService").Heartbeat
                        tpwalking = true
                        local c = game.Players.LocalPlayer.Character
                        local h = c and c:FindFirstChildWhichIsA("Humanoid")
                        while tpwalking and hb:Wait() and c and h and h.Parent do
                            if h.MoveDirection.Magnitude > 0 then
                                c:TranslateBy(h.MoveDirection)
                            end
                        end
                    end)
                end
            end
        end)

        mine.MouseButton1Down:Connect(function()
            if speeds <= 1 then
                speed.Text = "1"
            else
                speeds = speeds - 1
                speed.Text = tostring(speeds)
                if nowe == true then
                    tpwalking = false
                    for i = 1, speeds do
                        spawn(function()
                            local hb = game:GetService("RunService").Heartbeat
                            tpwalking = true
                            local c = game.Players.LocalPlayer.Character
                            local h = c and c:FindFirstChildWhichIsA("Humanoid")
                            while tpwalking and hb:Wait() and c and h and h.Parent do
                                if h.MoveDirection.Magnitude > 0 then
                                    c:TranslateBy(h.MoveDirection)
                                end
                            end
                        end)
                    end
                end
            end
        end)

        WindUI:Notify({Title = "飞行加载成功", Content = "拖动面板，点'开启飞行'起飞", Duration = 5})
    end

    print(">>> 功能代码加载完成")
    _G.XQ.Notify("功能已加载", "所有功能可用", 3)
end)
