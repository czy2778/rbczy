local v1 = game:GetService("Players")
local v2 = game:GetService("RunService")
local v3 = game:GetService("Workspace")
local v4 = game:GetService("CollectionService")
local v5 = v1.LocalPlayer
local v6 = Color3.fromRGB
local v7 = math.floor
local v8 = math.clamp

local r1 = {
  Aim = false,
  SilentAim = false,
  Smooth = 25,
  Wall = true,
  WallAim = false,
  Team = true,
  Prediction = false,
  PredictionTime = 0.12,
  TargetType = "全部",
  TargetRule = "离准心最近",
  PlayerPriority = true,
  Radius = 150,
  FOVColor = v6(255, 255, 255),
  PlayerESP = false,
  AIESP = false,
  UnknownESP = false,
  Names = true,
  Health = true,
  Distance = true,
  PlayerFill = v6(255, 50, 50),
  PlayerOutline = v6(255, 255, 255),
  AIFill = v6(255, 170, 0),
  AIOutline = v6(255, 255, 0),
  UnknownFill = v6(160, 100, 255),
  UnknownOutline = v6(255, 255, 255),
  ShowTarget = true,
  BehindWarning = true,
  BehindDistance = 80
}

local r2 = {}
local r3 = {}
local r4 = nil

local c1 = Instance.new("ScreenGui")
c1.Name = "AimESP_" .. tostring(os.clock())
c1.ResetOnSpawn = false
c1.IgnoreGuiInset = true
c1.Parent = v5:WaitForChild("PlayerGui")

local c2 = Instance.new("Frame")
c2.Name = "FOV"
c2.AnchorPoint = Vector2.new(0.5, 0.5)
c2.BackgroundTransparency = 1
c2.Parent = c1

local c3 = Instance.new("UICorner")
c3.CornerRadius = UDim.new(1, 0)
c3.Parent = c2

local c4 = Instance.new("UIStroke")
c4.Thickness = 2
c4.Color = r1.FOVColor
c4.Parent = c2

local c5 = Instance.new("TextLabel")
c5.Name = "TargetInfo"
c5.AnchorPoint = Vector2.new(0.5, 0)
c5.Size = UDim2.fromOffset(300, 32)
c5.BackgroundColor3 = v6(15, 15, 20)
c5.BackgroundTransparency = 0.2
c5.TextColor3 = v6(255, 255, 255)
c5.TextStrokeTransparency = 0.5
c5.TextSize = 15
c5.Font = Enum.Font.GothamBold
c5.Text = "当前未锁定目标"
c5.Visible = false
c5.Parent = c1

local c6 = Instance.new("UICorner")
c6.CornerRadius = UDim.new(0, 8)
c6.Parent = c5

local c7 = Instance.new("TextLabel")
c7.Name = "BehindWarning"
c7.AnchorPoint = Vector2.new(0.5, 1)
c7.Position = UDim2.new(0.5, 0, 0.9, 0)
c7.Size = UDim2.fromOffset(320, 42)
c7.BackgroundColor3 = v6(120, 15, 15)
c7.BackgroundTransparency = 0.15
c7.TextColor3 = v6(255, 255, 255)
c7.TextSize = 18
c7.TextScaled = true
c7.Font = Enum.Font.GothamBold
c7.Visible = false
c7.Parent = c1

local c8 = Instance.new("UICorner")
c8.CornerRadius = UDim.new(0, 8)
c8.Parent = c7

local function r5(r6)
  if not r6 then
    return nil
  end

  local r7 = r6:FindFirstChildOfClass("Humanoid")
  local r8 = r6:FindFirstChild("HumanoidRootPart")
  local r9 = r6:FindFirstChild("Head")

  if not r7 or not r8 or r7.Health <= 0 then
    return nil
  end

  return {
    Character = r6,
    Humanoid = r7,
    Root = r8,
    Head = r9 or r8
  }
end

local function r10(r11)
  local r12 = v1:GetPlayerFromCharacter(r11)

  if r12 then
    return "真人", r12
  end

  local r13 = {
    "IsBot",
    "IsAI",
    "IsNPC",
    "Bot",
    "NPC",
    "AI",
    "ArtificialIntelligence"
  }

  for _, r14 in ipairs(r13) do
    local r15 = r11:GetAttribute(r14)

    if r15 == true or r15 == 1 then
      return "AI", nil
    end

    if v4:HasTag(r11, r14) then
      return "AI", nil
    end
  end

  local r16 = r11.Parent

  while r16 and r16 ~= v3 do
    for _, r17 in ipairs(r13) do
      local r18 = r16:GetAttribute(r17)

      if r18 == true or r18 == 1 then
        return "AI", nil
      end

      if v4:HasTag(r16, r17) then
        return "AI", nil
      end
    end

    local r19 = string.lower(r16.Name)

    if r19 == "npcs"
      or r19 == "npc"
      or r19 == "bots"
      or r19 == "bot"
      or r19 == "enemies"
      or r19 == "ai" then
      return "AI", nil
    end

    r16 = r16.Parent
  end

  return "未知", nil
end

local function r20(r21)
  if not r21 or r21.Character == v5.Character then
    return false
  end

  if not r21.Character.Parent then
    return false
  end

  if not r21.Humanoid.Parent or r21.Humanoid.Health <= 0 then
    return false
  end

  if r21.Type == "真人" then
    local r22 = r21.Player

    if not r22 or r22 == v5 then
      return false
    end

    if r1.Team and v5.Team and r22.Team == v5.Team then
      return false
    end
  end

  return true
end

local function r23(r24)
  if not r1.Wall or r1.WallAim then
    return true
  end

  local r25 = v3.CurrentCamera

  if not r25 or not v5.Character then
    return false
  end

  local r26 = RaycastParams.new()
  r26.FilterType = Enum.RaycastFilterType.Exclude
  r26.FilterDescendantsInstances = {v5.Character}
  r26.IgnoreWater = true

  local r27 = r25.CFrame.Position
  local r28 = r24.Position - r27
  local r29 = v3:Raycast(r27, r28, r26)

  return r29 == nil or r29.Instance:IsDescendantOf(r24.Parent)
end

local function r30()
  local r31 = {}
  local r32 = {}

  for _, r33 in ipairs(v1:GetPlayers()) do
    if r33 ~= v5 and r33.Character then
      r32[r33.Character] = true

      local r34 = r5(r33.Character)

      if r34 then
        r34.Type = "真人"
        r34.Player = r33
        table.insert(r31, r34)
      end
    end
  end

  for _, r35 in ipairs(v3:GetDescendants()) do
    if r35:IsA("Humanoid") then
      local r36 = r35.Parent

      if r36
        and r36:IsA("Model")
        and not r32[r36]
        and r36 ~= v5.Character then

        local r37 = r5(r36)

        if r37 then
          local r38, r39 = r10(r36)

          r37.Type = r38
          r37.Player = r39

          table.insert(r31, r37)
          r32[r36] = true
        end
      end
    end
  end

  return r31
end

local function r40(r41)
  if r1.TargetType == "全部" then
    return r41 == "真人" or r41 == "AI"
  end

  return r41 == r1.TargetType
end

local function r42(r43)
  local r44 = r43.Head.Position

  if r1.Prediction then
    r44 = r44
      + r43.Root.AssemblyLinearVelocity * r1.PredictionTime
  end

  return r44
end

local function r45()
  local r46 = v3.CurrentCamera

  if not r46 then
    return nil
  end

  local r47 = nil
  local r48 = math.huge
  local r49 = math.huge
  local r50 = r46.ViewportSize / 2
  local r51 = v5.Character
  local r52 = r51 and r51:FindFirstChild("HumanoidRootPart")

  for _, r53 in ipairs(r3) do
    if not r40(r53.Type) then
      continue
    end

    if not r20(r53) then
      continue
    end

    local r54 = r42(r53)
    local r55, r56 = r46:WorldToViewportPoint(r54)

    if not r56 or r55.Z <= 0 then
      continue
    end

    local r57 = (
      Vector2.new(r55.X, r55.Y) - r50
    ).Magnitude

    if r57 > r1.Radius then
      continue
    end

    if not r23(r53.Head) then
      continue
    end

    local r58 = r57

    if r1.TargetRule == "离自己最近" then
      if not r52 then
        continue
      end

      r58 = (r52.Position - r53.Root.Position).Magnitude
    end

    local r59 = 1

    if r1.TargetType == "全部"
      and r1.PlayerPriority
      and r53.Type == "真人" then
      r59 = 0
    end

    if r59 < r49 or (r59 == r49 and r58 < r48) then
      r49 = r59
      r48 = r58
      r47 = r53
    end
  end

  return r47
end

local function r60(r61)
  local r62 = r2[r61]

  if not r62 then
    return
  end

  pcall(function()
    r62.Highlight:Destroy()
    r62.Billboard:Destroy()
  end)

  r2[r61] = nil
end

local function r63(r64)
  if r2[r64.Character] then
    return r2[r64.Character]
  end

  local c9 = Instance.new("Highlight")
  c9.Name = "TargetHighlight"
  c9.Adornee = r64.Character
  c9.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
  c9.FillTransparency = 0.5
  c9.OutlineTransparency = 0
  c9.Parent = c1

  local c10 = Instance.new("BillboardGui")
  c10.Name = "TargetBillboard"
  c10.Adornee = r64.Head
  c10.AlwaysOnTop = true
  c10.Size = UDim2.fromOffset(200, 70)
  c10.StudsOffset = Vector3.new(0, 3, 0)
  c10.Parent = c1

  local c11 = Instance.new("TextLabel")
  c11.Size = UDim2.fromScale(1, 1)
  c11.BackgroundTransparency = 1
  c11.TextColor3 = v6(255, 255, 255)
  c11.TextStrokeTransparency = 0
  c11.TextScaled = true
  c11.Font = Enum.Font.GothamBold
  c11.Parent = c10

  r2[r64.Character] = {
    Highlight = c9,
    Billboard = c10,
    Label = c11
  }

  return r2[r64.Character]
end

local function r65(r66)
  if r66.Type == "真人" then
    return r1.PlayerESP
  elseif r66.Type == "AI" then
    return r1.AIESP
  end

  return r1.UnknownESP
end

local function r67(r68)
  local r69 = r63(r68)

  if r68.Type == "真人" then
    r69.Highlight.FillColor = r1.PlayerFill
    r69.Highlight.OutlineColor = r1.PlayerOutline
  elseif r68.Type == "AI" then
    r69.Highlight.FillColor = r1.AIFill
    r69.Highlight.OutlineColor = r1.AIOutline
  else
    r69.Highlight.FillColor = r1.UnknownFill
    r69.Highlight.OutlineColor = r1.UnknownOutline
  end

  local r70 = {}

  if r1.Names then
    local r71 = r68.Player
      and r68.Player.DisplayName
      or r68.Character.Name

    table.insert(r70, "[" .. r68.Type .. "] " .. r71)
  end

  if r1.Health then
    table.insert(r70, "HP: " .. v7(r68.Humanoid.Health))
  end

  if r1.Distance then
    local r72 = v5.Character
    local r73 = r72 and r72:FindFirstChild("HumanoidRootPart")

    if r73 then
      local r74 = (r73.Position - r68.Root.Position).Magnitude
      table.insert(r70, v7(r74) .. " studs")
    end
  end

  r69.Label.Text = table.concat(r70, "\n")
  r69.Billboard.Enabled = #r70 > 0
end

local function r75()
  local r76 = {}

  for _, r77 in ipairs(r3) do
    r76[r77.Character] = true

    if r65(r77) and r20(r77) then
      r67(r77)
    else
      r60(r77.Character)
    end
  end

  for r78 in pairs(r2) do
    if not r76[r78] or not r78.Parent then
      r60(r78)
    end
  end
end

local function r79()
  local r80 = v3.CurrentCamera

  if not r80 then
    return
  end

  local r81 = r80.ViewportSize

  c2.Position = UDim2.fromOffset(r81.X / 2, r81.Y / 2)
  c2.Size = UDim2.fromOffset(r1.Radius * 2, r1.Radius * 2)
  c2.Visible = r1.Aim
  c4.Color = r1.FOVColor

  c5.Position = UDim2.fromOffset(r81.X / 2, 65)
  c5.Visible = r1.Aim and r1.ShowTarget
end

local function r82()
  if not r1.Aim then
    r4 = nil
    c5.Text = "当前未锁定目标"
    return
  end

  local r83 = v3.CurrentCamera

  if not r83 then
    return
  end

  r4 = r45()

  if not r4 then
    c5.Text = "当前未锁定目标"
    return
  end

  local r84 = r42(r4)
  local r85 = r4.Player
    and r4.Player.DisplayName
    or r4.Character.Name

  c5.Text = "锁定: " .. r85 .. " [" .. r4.Type .. "]"

  if r1.SilentAim then
    return
  end

  local r86 = r83.CFrame
  local r87 = CFrame.lookAt(r86.Position, r84)

  if r1.Smooth <= 0 then
    r83.CFrame = r87
  else
    local r88 = 1 - r1.Smooth / 105
    r88 = v8(r88, 0.01, 1)
    r83.CFrame = r86:Lerp(r87, r88)
  end
end

local function r89()
  if not r1.BehindWarning then
    c7.Visible = false
    return
  end

  local r90 = v5.Character
  local r91 = r90 and r90:FindFirstChild("HumanoidRootPart")

  if not r91 then
    c7.Visible = false
    return
  end

  local r92 = nil
  local r93 = r1.BehindDistance

  for _, r94 in ipairs(r3) do
    if not r20(r94) then
      continue
    end

    local r95 = r94.Root.Position - r91.Position
    local r96 = r95.Magnitude

    if r96 > 0 and r96 <= r93 then
      local r97 = r91.CFrame.LookVector:Dot(r95.Unit)

      if r97 < -0.3 then
        r92 = r94
        r93 = r96
      end
    end
  end

  if r92 then
    local r98 = r92.Player
      and r92.Player.DisplayName
      or r92.Character.Name

    c7.Text = "身后有敌人: "
      .. r98
      .. " ["
      .. r92.Type
      .. "] "
      .. v7(r93)
      .. " studs"

    c7.Visible = true
  else
    c7.Visible = false
  end
end

local r99 = 0

v2.RenderStepped:Connect(function(r100)
  pcall(r79)
  pcall(r82)
  pcall(r89)

  r99 = r99 + r100

  if r99 >= 0.3 then
    r99 = 0

    pcall(function()
      r3 = r30()
      r75()
    end)
  end
end)

v1.PlayerRemoving:Connect(function(r101)
  if r101.Character then
    r60(r101.Character)
  end
end)

local c12

do
  local r102, r103 = pcall(function()
    return loadstring(game:HttpGet(
      "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
    ))()
  end)

  if r102 then
    c12 = r103
  else
    warn("WindUI 加载失败: " .. tostring(r103))
    return
  end
end

local c13 = c12:CreateWindow({
  Title = "Aim & ESP",
  Author = "Client",
  Icon = "solar:target-bold",
  Theme = "Dark",
  ToggleKey = Enum.KeyCode.F
})

local c14 = c13:Tab({
  Title = "自动瞄准",
  Icon = "crosshair"
})

local c15 = c13:Tab({
  Title = "ESP透视",
  Icon = "eye"
})

local c16 = c13:Tab({
  Title = "其他设置",
  Icon = "settings"
})

c14:Toggle({
  Title = "开启自动瞄准",
  Value = false,
  Callback = function(r104)
    r1.Aim = r104
  end
})

c14:Toggle({
  Title = "静默自瞄",
  Desc = "需要开启自动瞄准；仅保持视角不变，尚未接入射击判定",
  Value = false,
  Callback = function(r104)
    r1.SilentAim = r104
  end
})

c14:Slider({
  Title = "自瞄平滑度",
  Desc = "0为瞬间锁定，数值越大越平滑",
  Value = {
    Min = 0,
    Max = 100,
    Default = 25
  },
  Callback = function(r104)
    r1.Smooth = r104
  end
})

c14:Dropdown({
  Title = "锁定目标类型",
  Values = {
    "真人",
    "AI",
    "全部"
  },
  Value = "全部",
  Callback = function(r104)
    if type(r104) == "table" then
      r104 = r104[1]
    end

    if type(r104) == "string" then
      r1.TargetType = r104
    end
  end
})

c14:Dropdown({
  Title = "锁定规则",
  Values = {
    "离准心最近",
    "离自己最近"
  },
  Value = "离准心最近",
  Callback = function(r104)
    if type(r104) == "table" then
      r104 = r104[1]
    end

    if type(r104) == "string" then
      r1.TargetRule = r104
    end
  end
})

c14:Toggle({
  Title = "真人优先锁定",
  Desc = "选择全部目标时优先锁定真人",
  Value = true,
  Callback = function(r104)
    r1.PlayerPriority = r104
  end
})

c14:Slider({
  Title = "FOV范围",
  Value = {
    Min = 30,
    Max = 500,
    Default = 150
  },
  Callback = function(r104)
    r1.Radius = r104
  end
})

c14:Colorpicker({
  Title = "FOV颜色",
  Default = r1.FOVColor,
  Callback = function(r104)
    if typeof(r104) == "Color3" then
      r1.FOVColor = r104
    end
  end
})

c14:Toggle({
  Title = "墙壁检测",
  Value = true,
  Callback = function(r104)
    r1.Wall = r104
  end
})

c14:Toggle({
  Title = "穿墙瞄准",
  Desc = "允许锁定墙后目标，不改变子弹伤害判定",
  Value = false,
  Callback = function(r104)
    r1.WallAim = r104
  end
})

c14:Toggle({
  Title = "队伍检测",
  Value = true,
  Callback = function(r104)
    r1.Team = r104
  end
})

c14:Toggle({
  Title = "显示锁定目标",
  Value = true,
  Callback = function(r104)
    r1.ShowTarget = r104
  end
})

c14:Toggle({
  Title = "移动目标预判",
  Value = false,
  Callback = function(r104)
    r1.Prediction = r104
  end
})

c14:Slider({
  Title = "预判时间",
  Value = {
    Min = 0,
    Max = 50,
    Default = 12
  },
  Callback = function(r104)
    r1.PredictionTime = r104 / 100
  end
})

c15:Toggle({
  Title = "真人ESP",
  Value = false,
  Callback = function(r104)
    r1.PlayerESP = r104
  end
})

c15:Colorpicker({
  Title = "真人填充颜色",
  Default = r1.PlayerFill,
  Callback = function(r104)
    if typeof(r104) == "Color3" then
      r1.PlayerFill = r104
    end
  end
})

c15:Colorpicker({
  Title = "真人描边颜色",
  Default = r1.PlayerOutline,
  Callback = function(r104)
    if typeof(r104) == "Color3" then
      r1.PlayerOutline = r104
    end
  end
})

c15:Toggle({
  Title = "AI ESP",
  Value = false,
  Callback = function(r104)
    r1.AIESP = r104
  end
})

c15:Colorpicker({
  Title = "AI填充颜色",
  Default = r1.AIFill,
  Callback = function(r104)
    if typeof(r104) == "Color3" then
      r1.AIFill = r104
    end
  end
})

c15:Colorpicker({
  Title = "AI描边颜色",
  Default = r1.AIOutline,
  Callback = function(r104)
    if typeof(r104) == "Color3" then
      r1.AIOutline = r104
    end
  end
})

c15:Toggle({
  Title = "显示未知类型角色",
  Desc = "用于检查未被识别的AI",
  Value = false,
  Callback = function(r104)
    r1.UnknownESP = r104
  end
})

c15:Toggle({
  Title = "显示名称",
  Value = true,
  Callback = function(r104)
    r1.Names = r104
  end
})

c15:Toggle({
  Title = "显示血量",
  Value = true,
  Callback = function(r104)
    r1.Health = r104
  end
})

c15:Toggle({
  Title = "显示距离",
  Value = true,
  Callback = function(r104)
    r1.Distance = r104
  end
})

c16:Toggle({
  Title = "身后敌人预警",
  Desc = "检测身后接近的敌人",
  Value = true,
  Callback = function(r104)
    r1.BehindWarning = r104
  end
})

c16:Slider({
  Title = "身后预警距离",
  Value = {
    Min = 20,
    Max = 300,
    Default = 80
  },
  Callback = function(r104)
    r1.BehindDistance = r104
  end
})
