local v1 = game:GetService("Players")

local v2 = game:GetService("RunService")

local v3 = game:GetService("Workspace")

local v4 = game:GetService("ReplicatedStorage")

local v5 = game:GetService("UserInputService")

local v6 = v1.LocalPlayer

local v7 = v6:WaitForChild("PlayerGui")

local v8 = Color3.fromRGB

local r1 = {

  Aim = false,

  Radius = 180,

  Smooth = 25,

  FOVColor = v8(255, 255, 255),

  TeamCheck = true,

  WallCheck = true,

  SmartParts = true,

  TargetHold = true,

  Prediction = false,

  PredictionTime = 0.12,

  TargetRule = "离准心最近",

  ESP = false,

  EnemyOnly = false,

  Highlight = false,

  TeamColor = true,

  Names = true,

  Health = true,

  HealthBar = true,

  Distance = true,

  MaxDistance = 1500,

  FillColor = v8(255, 80, 80),

  OutlineColor = v8(255, 255, 255),

  FillTransparency = 0.5,

  WalkSpeed = 16,

  SpeedEnabled = false,

  Noclip = false,

  Fly = false,

  FlySpeed = 50,

  Farm = false,

  AutoFire = false,

  FarmDistance = 5,

  FarmInterval = 0.5

}

local r2 = {}

local r3 = {}

local r4 = nil

local r5 = nil

local r6 = true

local r7 = {}

local r8 = 0

local r9 = 0

local r10 = 0

local r11 = 0

local r12 = nil

local r13 = nil

local r14 = nil

local r15 = nil

local r16 = false

local function r17(r18)

  if r18 == "defenders" then

    return v8(60, 120, 255)

  elseif r18 == "attackers" then

    return v8(255, 80, 80)

  end

  return v8(0, 255, 120)

end

local function r19()

  local r20 = v7:FindFirstChild("leaderboard")

  local r21 = r20 and r20:FindFirstChild("Frame")

  if not r21 then

    return

  end

  for _, r22 in ipairs({"defenders", "attackers"}) do

    local r23 = r21:FindFirstChild(r22)

    if r23 then

      for _, r24 in ipairs(r23:GetDescendants()) do

        if r24:IsA("TextLabel")

          and r24.Name == "username"

          and r24.Text ~= "" then

          for _, r25 in ipairs(v1:GetPlayers()) do

            if r25.Name == r24.Text

              or r25.DisplayName == r24.Text then

              r2[r25] = r22

              if r25 == v6 then

                r5 = r22

              end

              break

            end

          end

        end

      end

    end

  end

end

local r26 = v4:FindFirstChild("network")

if r26 then

  local r27 = r26:FindFirstChild("joinedTeam")

  if r27 and r27:IsA("RemoteEvent") then

    r27.OnClientEvent:Connect(function(r28, r29)

      if typeof(r28) == "Instance"

        and r28:IsA("Player")

        and type(r29) == "string" then

        r2[r28] = string.lower(r29)

        if r28 == v6 then

          r5 = r2[r28]

        end

      end

    end)

  end

  local r30 = r26:FindFirstChild("setClientRegistryData")

  if r30 and r30:IsA("RemoteEvent") then

    r30.OnClientEvent:Connect(function(r31, r32)

      if r31 == "team" and type(r32) == "string" then

        r5 = string.lower(r32)

        r2[v6] = r5

      end

    end)

  end

end

task.spawn(function()

  task.wait(1)

  while r6 do

    pcall(r19)

    task.wait(2)

  end

end)

local function r33(r34)

  if r34 == v6 then

    return true

  end

  local r35 = r5 or r2[v6]

  local r36 = r2[r34]

  if not r35 or not r36 then

    return true

  end

  return r35 == r36

end

local function r37(r38)

  local r39 = r38.Character

  if not r39 or not r39:IsDescendantOf(v3) then

    return nil

  end

  local r40 = r39:FindFirstChildOfClass("Humanoid")

  local r41 = r39:FindFirstChild("HumanoidRootPart")

  if not r40 or not r41 or r40.Health <= 0 then

    return nil

  end

  return r39, r40, r41

end

local function r42(r43, r44)

  if not r1.WallCheck then

    return true

  end

  local r45 = v3.CurrentCamera

  if not r45 then

    return false

  end

  local r46 = RaycastParams.new()

  r46.FilterType = Enum.RaycastFilterType.Exclude

  r46.FilterDescendantsInstances = {

    v6.Character

  }

  r46.IgnoreWater = true

  local r47 = r45.CFrame.Position

  local r48 = v3:Raycast(

    r47,

    r44 - r47,

    r46

  )

  return r48 == nil or r48.Instance:IsDescendantOf(r43)

end

local function r49(r50)

  local r51 = r50.Character

  if not r51 then

    return nil

  end

  local r52 = {}

  if r1.SmartParts then

    r52 = {

      "Head",

      "UpperTorso",

      "Torso",

      "LeftUpperArm",

      "RightUpperArm",

      "Left Arm",

      "Right Arm",

      "LowerTorso",

      "LeftUpperLeg",

      "RightUpperLeg",

      "Left Leg",

      "Right Leg"

    }

  else

    r52 = {"Head"}

  end

  local r53 = v3.CurrentCamera

  if not r53 then

    return nil

  end

  local r54 = r53.ViewportSize / 2

  for _, r55 in ipairs(r52) do

    local r56 = r51:FindFirstChild(r55)

    if r56 and r56:IsA("BasePart") then

      local r57 = r56.Position

      if r1.Prediction then

        local r58 = r51:FindFirstChild("HumanoidRootPart")

        if r58 then

          r57 = r57

            + r58.AssemblyLinearVelocity * r1.PredictionTime

        end

      end

      local r59, r60 = r53:WorldToViewportPoint(r57)

      if r60 and r59.Z > 0 then

        local r61 = (

          Vector2.new(r59.X, r59.Y) - r54

        ).Magnitude

        if r61 <= r1.Radius and r42(r51, r57) then

          return r57, r61

        end

      end

    end

  end

  return nil

end

local function r62(r63)

  local r64 = v3.CurrentCamera

  if not r64 then

    return nil

  end

  local r65 = nil

  local r66 = math.huge

  local r67 = v6.Character

  local r68 = r67 and r67:FindFirstChild("HumanoidRootPart")

  for _, r69 in ipairs(v1:GetPlayers()) do

    if r69 == v6 then

      continue

    end

    if r1.TeamCheck and r33(r69) then

      continue

    end

    local r70, r71, r72 = r37(r69)

    if not r70 then

      continue

    end

    local r73, r74 = r49(r69)

    if not r73 then

      continue

    end

    local r75 = r74

    if r1.TargetRule == "离自己最近" then

      if not r68 then

        continue

      end

      r75 = (r68.Position - r72.Position).Magnitude

    end

    if r75 < r66 then

      r66 = r75

      r65 = {

        Player = r69,

        Position = r73

      }

    end

  end

  if r1.TargetHold and r63 then

    local r76 = r63.Player

    if r76 and (not r1.TeamCheck or not r33(r76)) then

      local r77 = r37(r76)

      if r77 then

        local r78 = r49(r76)

        if r78 then

          return {

            Player = r76,

            Position = r78

          }

        end

      end

    end

  end

  return r65

end

local function r79(r80)

  local r81 = r3[r80]

  if not r81 then

    return

  end

  if r81.Billboard then

    r81.Billboard:Destroy()

  end

  if r81.Highlight then

    r81.Highlight:Destroy()

  end

  r3[r80] = nil

end

local function r82(r83)

  if r3[r83] then

    return r3[r83]

  end

  local r84 = r83.Character

  local r85 = r84 and (

    r84:FindFirstChild("Head")

    or r84:FindFirstChild("UpperTorso")

    or r84:FindFirstChild("HumanoidRootPart")

  )

  if not r85 then

    return nil

  end

  local c1 = Instance.new("BillboardGui")

  c1.Size = UDim2.fromOffset(160, 65)

  c1.StudsOffsetWorldSpace = Vector3.new(0, 3.2, 0)

  c1.Adornee = r85

  c1.AlwaysOnTop = true

  c1.LightInfluence = 0

  c1.MaxDistance = r1.MaxDistance

  c1.Parent = v7

  local c2 = Instance.new("TextLabel")

  c2.Size = UDim2.new(1, 0, 0, 20)

  c2.BackgroundTransparency = 1

  c2.TextStrokeTransparency = 0

  c2.TextColor3 = v8(255, 255, 255)

  c2.TextSize = 14

  c2.Font = Enum.Font.GothamBold

  c2.Parent = c1

  local c3 = Instance.new("Frame")

  c3.Position = UDim2.new(0.1, 0, 0, 22)

  c3.Size = UDim2.new(0.8, 0, 0, 6)

  c3.BackgroundColor3 = v8(30, 30, 30)

  c3.Parent = c1

  local c4 = Instance.new("Frame")

  c4.Size = UDim2.fromScale(1, 1)

  c4.BackgroundColor3 = v8(0, 255, 0)

  c4.BorderSizePixel = 0

  c4.Parent = c3

  local c5 = Instance.new("TextLabel")

  c5.Position = UDim2.fromOffset(0, 30)

  c5.Size = UDim2.new(1, 0, 0, 16)

  c5.BackgroundTransparency = 1

  c5.TextStrokeTransparency = 0

  c5.TextColor3 = v8(255, 255, 255)

  c5.TextSize = 13

  c5.Font = Enum.Font.GothamBold

  c5.Parent = c1

  local c6 = Instance.new("TextLabel")

  c6.Position = UDim2.fromOffset(0, 46)

  c6.Size = UDim2.new(1, 0, 0, 16)

  c6.BackgroundTransparency = 1

  c6.TextStrokeTransparency = 0

  c6.TextColor3 = v8(255, 255, 255)

  c6.TextSize = 13

  c6.Font = Enum.Font.GothamBold

  c6.Parent = c1

  local c7 = Instance.new("Highlight")

  c7.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

  c7.Adornee = r84

  c7.Parent = r84

  r3[r83] = {

    Character = r84,

    Billboard = c1,

    Name = c2,

    BarBackground = c3,

    Bar = c4,

    Health = c5,

    Distance = c6,

    Highlight = c7

  }

  return r3[r83]

end

local function r86()

  for _, r87 in ipairs(v1:GetPlayers()) do

    if r87 == v6 then

      continue

    end

    local r88 = r3[r87]

    if not r1.ESP

      or (r1.EnemyOnly and r33(r87)) then

      if r88 then

        r88.Billboard.Enabled = false

        r88.Highlight.Enabled = false

      end

      continue

    end

    local r89, r90, r91 = r37(r87)

    if not r89 then

      if r88 then

        r88.Billboard.Enabled = false

        r88.Highlight.Enabled = false

      end

      continue

    end

    local r92 = v3.CurrentCamera

    if not r92 then

      continue

    end

    local r93 = (r92.CFrame.Position - r91.Position).Magnitude

    if r93 > r1.MaxDistance then

      if r88 then

        r88.Billboard.Enabled = false

        r88.Highlight.Enabled = false

      end

      continue

    end

    r88 = r82(r87)

    if not r88 then

      continue

    end

    local r94 = r1.FillColor

    if r1.TeamColor then

      r94 = r17(r2[r87])

    end

    local r95 = math.clamp(

      r90.Health / math.max(r90.MaxHealth, 1),

      0,

      1

    )

    r88.Billboard.Enabled = true

    r88.Billboard.MaxDistance = r1.MaxDistance

    r88.Name.Visible = r1.Names

    r88.Name.Text = r87.Name

    r88.Name.TextColor3 = r94

    r88.BarBackground.Visible = r1.HealthBar

    r88.Bar.Size = UDim2.new(r95, 0, 1, 0)

    r88.Bar.BackgroundColor3 = v8(

      math.floor(255 * (1 - r95)),

      math.floor(255 * r95),

      0

    )

    r88.Health.Visible = r1.Health

    r88.Health.Text = string.format(

      "%d / %d",

      math.floor(r90.Health),

      math.floor(r90.MaxHealth)

    )

    r88.Distance.Visible = r1.Distance

    r88.Distance.Text = string.format("%.0fm", r93)

    r88.Highlight.Enabled = r1.Highlight

    r88.Highlight.FillColor = r94

    r88.Highlight.OutlineColor = r1.OutlineColor

    r88.Highlight.FillTransparency = r1.FillTransparency

  end

end

local c8 = Instance.new("ScreenGui")

c8.Name = "KAG_Control_" .. tostring(os.clock())

c8.ResetOnSpawn = false

c8.IgnoreGuiInset = true

c8.Parent = v7

local c9 = Instance.new("Frame")

c9.Name = "FlyControl"

c9.Size = UDim2.fromOffset(145, 170)

c9.Position = UDim2.new(1, -160, 0.45, 0)

c9.BackgroundColor3 = v8(25, 25, 30)

c9.BackgroundTransparency = 0.15

c9.Visible = false

c9.Active = true

c9.Draggable = true

c9.Parent = c8

local c10 = Instance.new("UICorner")

c10.CornerRadius = UDim.new(0, 12)

c10.Parent = c9

local c11 = Instance.new("TextLabel")

c11.Size = UDim2.new(1, 0, 0, 30)

c11.BackgroundTransparency = 1

c11.Text = "KAG 飞行控制"

c11.TextColor3 = v8(255, 255, 255)

c11.TextSize = 15

c11.Font = Enum.Font.GothamBold

c11.Parent = c9

local function r96(r97, r98, r99)

  local c12 = Instance.new("TextButton")

  c12.Size = UDim2.fromOffset(110, 36)

  c12.Position = UDim2.fromOffset(17, r98)

  c12.BackgroundColor3 = r99

  c12.Text = r97

  c12.TextColor3 = v8(255, 255, 255)

  c12.TextSize = 16

  c12.Font = Enum.Font.GothamBold

  c12.Parent = c9

  local c13 = Instance.new("UICorner")

  c13.CornerRadius = UDim.new(0, 8)

  c13.Parent = c12

  return c12

end

local c14 = r96("上升", 35, v8(45, 130, 80))

local c15 = r96("下降", 78, v8(150, 85, 45))

local c16 = r96("关闭飞行", 121, v8(150, 45, 45))

local function r100(r101, r102)

  r101.MouseButton1Down:Connect(function()

    r7[r102] = true

  end)

  r101.MouseButton1Up:Connect(function()

    r7[r102] = false

  end)

  r101.MouseLeave:Connect(function()

    r7[r102] = false

  end)

end

r100(c14, "Up")

r100(c15, "Down")

local function r103(r104)

  r1.Fly = r104

  c9.Visible = r104

  if not r104 then

    r7.Up = false

    r7.Down = false

    local r105 = v6.Character

    local r106 = r105 and r105:FindFirstChild("HumanoidRootPart")

    if r106 then

      r106.AssemblyLinearVelocity = Vector3.zero

    end

  end

end

c16.MouseButton1Click:Connect(function()

  r103(false)

end)

local function r107()

  local r108 = v6.Character

  local r109 = r108 and r108:FindFirstChild("Humanoid")

  local r110 = r108 and r108:FindFirstChild("HumanoidRootPart")

  if not r109 or not r110 then

    return

  end

  if r1.SpeedEnabled then

    r109.WalkSpeed = r1.WalkSpeed

  end

  if r1.Noclip then

    for _, r111 in ipairs(r108:GetDescendants()) do

      if r111:IsA("BasePart") then

        r111.CanCollide = false

      end

    end

  end

  if r1.Fly then

    local r112 = v3.CurrentCamera

    if not r112 then

      return

    end

    local r113 = r109.MoveDirection

    local r114 = Vector3.zero

    if r113.Magnitude > 0 then

      r114 = r113.Unit * r1.FlySpeed

    end

    if r7.Up then

      r114 += Vector3.new(0, r1.FlySpeed, 0)

    end

    if r7.Down then

      r114 -= Vector3.new(0, r1.FlySpeed, 0)

    end

    r110.AssemblyLinearVelocity = r114

  end

end

local function r115(r116)

  local r117 = v6.Character

  local r118 = r117 and r117:FindFirstChild("HumanoidRootPart")

  local r119, r120, r121 = r37(r116)

  if not r118 or not r119 then

    return false

  end

  local r122 = r121.CFrame.LookVector

  local r123 = r121.Position

    - r122 * r1.FarmDistance

  r118.CFrame = CFrame.lookAt(

    r123,

    r121.Position

  )

  return true

end

local function r124()

  local r125 = nil

  local r126 = math.huge

  local r127 = v6.Character

  local r128 = r127 and r127:FindFirstChild("HumanoidRootPart")

  if not r128 then

    return nil

  end

  for _, r129 in ipairs(v1:GetPlayers()) do

    if r129 ~= v6 and not r33(r129) then

      local r130, r131, r132 = r37(r129)

      if r130 then

        local r133 = (r128.Position - r132.Position).Magnitude

        if r133 < r126 then

          r126 = r133

          r125 = r129

        end

      end

    end

  end

  return r125

end

local function r134(r135)

  local r136 = v3.CurrentCamera

  if not r136 or not r135 then

    return

  end

  local r137 = r135.Position

  local r138 = r136.CFrame

  r136.CFrame = r138:Lerp(

    CFrame.lookAt(r138.Position, r137),

    math.clamp(r135.Alpha or 1, 0, 1)

  )

end

local function r139()

  if not r1.AutoFire then

    if r16 and type(mouse1release) == "function" then

      pcall(mouse1release)

    end

    r16 = false

    return

  end

  if type(mouse1press) == "function" then

    if not r16 then

      pcall(mouse1press)

      r16 = true

    end

  end

end

local function r140()

  if not r1.Farm then

    r139()

    return

  end

  local r141 = r124()

  if not r141 then

    r139()

    return

  end

  local r142, r143, r144 = r37(r141)

  if not r142 then

    r139()

    return

  end

  local r145 = os.clock()

  if r145 - r11 >= r1.FarmInterval then

    r11 = r145

    r115(r141)

  end

  local r146 = r49(r141)

  if not r146 then

    local r147 = r142:FindFirstChild("Head")

      or r144

    r146 = r147.Position

  end

  r134({

    Position = r146,

    Alpha = 1

  })

  r139()

end

local c17 = Instance.new("Frame")

c17.AnchorPoint = Vector2.new(0.5, 0.5)

c17.BackgroundTransparency = 1

c17.Parent = c8

local c18 = Instance.new("UICorner")

c18.CornerRadius = UDim.new(1, 0)

c18.Parent = c17

local c19 = Instance.new("UIStroke")

c19.Thickness = 2

c19.Color = r1.FOVColor

c19.Parent = c17

local c20 = Instance.new("TextLabel")

c20.AnchorPoint = Vector2.new(0.5, 0)

c20.Size = UDim2.fromOffset(300, 30)

c20.BackgroundColor3 = v8(20, 20, 25)

c20.BackgroundTransparency = 0.2

c20.TextColor3 = v8(255, 255, 255)

c20.TextSize = 15

c20.Font = Enum.Font.GothamBold

c20.Visible = false

c20.Parent = c8

local r148 = 0

v2.RenderStepped:Connect(function(r149)

  if not r6 then

    return

  end

  pcall(r107)

  local r150 = v3.CurrentCamera

  if r150 then

    local r151 = r150.ViewportSize

    c17.Position = UDim2.fromOffset(

      r151.X / 2,

      r151.Y / 2

    )

    c17.Size = UDim2.fromOffset(

      r1.Radius * 2,

      r1.Radius * 2

    )

    c17.Visible = r1.Aim

    c19.Color = r1.FOVColor

    c20.Position = UDim2.fromOffset(

      r151.X / 2,

      65

    )

  end

  if r1.Farm then

    pcall(r140)

  elseif r1.Aim then

    r4 = r62(r4)

    if r4 then

      c20.Text = "锁定: " .. r4.Player.Name

      c20.Visible = true

      local r152 = v3.CurrentCamera

      if r152 then

        local r153 = r152.CFrame

        local r154 = CFrame.lookAt(

          r153.Position,

          r4.Position

        )

        local r155 = r1.Smooth <= 0

          and 1

          or math.clamp(

            1 - math.exp(

              -(101 - r1.Smooth) * r149 * 0.65

            ),

            0,

            1

          )

        r152.CFrame = r153:Lerp(r154, r155)

      end

    else

      c20.Visible = false

    end

  else

    r4 = nil

    c20.Visible = false

  end

  r148 += r149

  if r148 >= 0.1 then

    r148 = 0

    pcall(r86)

  end

end)

for _, r156 in ipairs(v1:GetPlayers()) do

  if r156 ~= v6 then

    r156.CharacterAdded:Connect(function()

      r79(r156)

    end)

  end

end

v1.PlayerAdded:Connect(function(r157)

  r157.CharacterAdded:Connect(function()

    r79(r157)

  end)

end)

v1.PlayerRemoving:Connect(function(r158)

  r79(r158)

  r2[r158] = nil

end)

local r159, c21 = pcall(function()

  return loadstring(game:HttpGet(

    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"

  ))()

end)

if not r159 then

  warn("WindUI 加载失败:", c21)

  return

end

local c22 = c21:CreateWindow({

  Title = "KAG Ultimate",

  Author = "KAG",

  Icon = "solar:target-bold",

  Theme = "Dark",

  ToggleKey = Enum.KeyCode.F

})

local c23 = c22:Tab({

  Title = "自动瞄准",

  Icon = "crosshair"

})

local c24 = c22:Tab({

  Title = "ESP透视",

  Icon = "eye"

})

local c25 = c22:Tab({

  Title = "玩家修改",

  Icon = "user"

})

local c26 = c22:Tab({

  Title = "传送",

  Icon = "map-pin"

})

local c27 = c22:Tab({

  Title = "刷钱辅助",

  Icon = "coins"

})

c23:Toggle({

  Title = "开启自动瞄准",

  Value = false,

  Callback = function(r160)

    r1.Aim = r160

  end

})

c23:Toggle({

  Title = "多部位智能锁定",

  Desc = "敌人局部露出时自动检测可见部位",

  Value = true,

  Callback = function(r160)

    r1.SmartParts = r160

  end

})

c23:Toggle({

  Title = "目标保持",

  Value = true,

  Callback = function(r160)

    r1.TargetHold = r160

  end

})

c23:Toggle({

  Title = "队伍检测",

  Value = true,

  Callback = function(r160)

    r1.TeamCheck = r160

  end

})

c23:Toggle({

  Title = "墙壁检测",

  Value = true,

  Callback = function(r160)

    r1.WallCheck = r160

  end

})

c23:Slider({

  Title = "FOV范围",

  Value = {

    Min = 30,

    Max = 500,

    Default = 180

  },

  Callback = function(r160)

    r1.Radius = r160

  end

})

c23:Slider({

  Title = "自瞄平滑度",

  Value = {

    Min = 0,

    Max = 100,

    Default = 25

  },

  Callback = function(r160)

    r1.Smooth = r160

  end

})

c23:Dropdown({

  Title = "锁定规则",

  Values = {

    "离准心最近",

    "离自己最近"

  },

  Value = "离准心最近",

  Callback = function(r160)

    if type(r160) == "table" then

      r160 = r160[1]

    end

    if type(r160) == "string" then

      r1.TargetRule = r160

    end

  end

})

c23:Toggle({

  Title = "移动目标预判",

  Value = false,

  Callback = function(r160)

    r1.Prediction = r160

  end

})

c23:Slider({

  Title = "预判时间",

  Value = {

    Min = 0,

    Max = 50,

    Default = 12

  },

  Callback = function(r160)

    r1.PredictionTime = r160 / 100

  end

})

c23:Colorpicker({

  Title = "FOV颜色",

  Default = r1.FOVColor,

  Callback = function(r160)

    if typeof(r160) == "Color3" then

      r1.FOVColor = r160

    end

  end

})

c24:Toggle({

  Title = "ESP总开关",

  Value = false,

  Callback = function(r160)

    r1.ESP = r160

  end

})

c24:Toggle({

  Title = "仅显示敌人",

  Value = false,

  Callback = function(r160)

    r1.EnemyOnly = r160

  end

})

c24:Toggle({

  Title = "人物高亮",

  Value = false,

  Callback = function(r160)

    r1.Highlight = r160

  end

})

c24:Toggle({

  Title = "队伍颜色",

  Value = true,

  Callback = function(r160)

    r1.TeamColor = r160

  end

})

c24:Toggle({

  Title = "显示名称",

  Value = true,

  Callback = function(r160)

    r1.Names = r160

  end

})

c24:Toggle({

  Title = "显示血量",

  Value = true,

  Callback = function(r160)

    r1.Health = r160

  end

})

c24:Toggle({

  Title = "显示血条",

  Value = true,

  Callback = function(r160)

    r1.HealthBar = r160

  end

})

c24:Toggle({

  Title = "显示距离",

  Value = true,

  Callback = function(r160)

    r1.Distance = r160

  end

})

c24:Slider({

  Title = "最大显示距离",

  Value = {

    Min = 50,

    Max = 3000,

    Default = 1500

  },

  Callback = function(r160)

    r1.MaxDistance = r160

  end

})

c24:Colorpicker({

  Title = "填充颜色",

  Default = r1.FillColor,

  Callback = function(r160)

    if typeof(r160) == "Color3" then

      r1.FillColor = r160

    end

  end

})

c24:Colorpicker({

  Title = "描边颜色",

  Default = r1.OutlineColor,

  Callback = function(r160)

    if typeof(r160) == "Color3" then

      r1.OutlineColor = r160

    end

  end

})

c24:Slider({

  Title = "填充透明度",

  Value = {

    Min = 0,

    Max = 100,

    Default = 50

  },

  Callback = function(r160)

    r1.FillTransparency = r160 / 100

  end

})

c25:Toggle({

  Title = "修改移动速度",

  Value = false,

  Callback = function(r160)

    r1.SpeedEnabled = r160

  end

})

c25:Slider({

  Title = "移动速度",

  Value = {

    Min = 16,

    Max = 200,

    Default = 16

  },

  Callback = function(r160)

    r1.WalkSpeed = r160

  end

})

c25:Toggle({

  Title = "穿墙",

  Value = false,

  Callback = function(r160)

    r1.Noclip = r160

  end

})

c25:Toggle({

  Title = "开启飞行",

  Desc = "开启后显示手机悬浮控制窗",

  Value = false,

  Callback = function(r160)

    r103(r160)

  end

})

c25:Slider({

  Title = "飞行速度",

  Value = {

    Min = 10,

    Max = 200,

    Default = 50

  },

  Callback = function(r160)

    r1.FlySpeed = r160

  end

})

c26:Button({

  Title = "传送到最近敌人身后",

  Callback = function()

    local r161 = r124()

    if r161 then

      r115(r161)

    else

      warn("[KAG] 没有找到已确认的敌人")

    end

  end

})

c26:Slider({

  Title = "敌人身后传送距离",

  Value = {

    Min = 2,

    Max = 20,

    Default = 5

  },

  Callback = function(r160)

    r1.FarmDistance = r160

  end

})

c27:Toggle({

  Title = "开启刷钱辅助",

  Desc = "寻找敌人、传送到身后并持续瞄准",

  Value = false,

  Callback = function(r160)

    r1.Farm = r160

    if not r160 then

      r1.AutoFire = false

      r139()

    end

  end

})

c27:Toggle({

  Title = "自动开火",

  Desc = "需要执行器支持 mouse1press；不保证游戏接受",

  Value = false,

  Callback = function(r160)

    r1.AutoFire = r160

    if not r160 then

      r139()

    end

  end

})

c27:Slider({

  Title = "传送刷新间隔",

  Value = {

    Min = 1,

    Max = 30,

    Default = 5

  },

  Callback = function(r160)

    r1.FarmInterval = r160 / 10

  end

})
