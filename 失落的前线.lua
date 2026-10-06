if _G.K22 then return end _G.K22 = true
local a = cloneref or clonereference or function(x) return x end
local b = a(game:GetService("ReplicatedStorage"))
local c = a(game:GetService("RunService"))
local d = a(game:GetService("Players"))
local e = d.LocalPlayer
local f = workspace.CurrentCamera
local g = e:WaitForChild("PlayerGui")
local h
do
	local i, j = pcall(function() return require("./src/Init") end)
	if i and j then h = j
	elseif c:IsStudio() or not writefile then
		local k, l = pcall(function() return require(b:WaitForChild("WindUI"):WaitForChild("Init")) end)
		if k then h = l end
	else
		local m, n = pcall(function() return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))() end)
		if m then h = n end
	end
end
if not h then return end

local o = {}
local p = nil

local function q()
	local r = g:FindFirstChild("leaderboard")
	if not r then return false end
	local s = r:FindFirstChild("Frame")
	if not s then return false end
	local t = {}
	for _, u in ipairs({"defenders", "attackers"}) do
		local v = s:FindFirstChild(u)
		if v then
			for _, w in ipairs(v:GetDescendants()) do
				if w:IsA("TextLabel") and w.Name == "username" and w.Text ~= "" then
					local x = w.Text
					local y = d:FindFirstChild(x)
					if not y then
						for _, z in ipairs(d:GetPlayers()) do
							if z.Name == x or z.DisplayName == x then y = z break end
						end
					end
					if y then t[y] = u end
				end
			end
		end
	end
	for A, B in pairs(t) do o[A] = B end
	local C = e.Name
	for _, D in ipairs({"defenders", "attackers"}) do
		local E = s:FindFirstChild(D)
		if E then
			for _, F in ipairs(E:GetDescendants()) do
				if F:IsA("TextLabel") and F.Name == "username" then
					if F.Text == C or F.Text == e.DisplayName then p = D o[e] = D break end
				end
			end
		end
	end
	return true
end

task.spawn(function()
	task.wait(1)
	q()
	while true do task.wait(2) pcall(q) end
end)

local G = b:WaitForChild("network", 10)
if G then
	local H = G:FindFirstChild("joinedTeam")
	if H then
		H.OnClientEvent:Connect(function(I, J)
			if typeof(I) == "Instance" and I:IsA("Player") and typeof(J) == "string" then o[I] = J if I == e then p = J end end
		end)
	end
	local K = G:FindFirstChild("setClientRegistryData")
	if K then
		K.OnClientEvent:Connect(function(L, M) if L == "team" and typeof(M) == "string" then p = M o[e] = M end end)
	end
end

d.PlayerRemoving:Connect(function(N) o[N] = nil end)

local function O(P)
	if P == e then return true end
	local Q = p or o[e]
	if not Q then return true end
	local R = o[P]
	if not R then return true end
	return Q == R
end

local function S(T)
	if T == "defenders" then return Color3.fromRGB(60, 120, 255)
	elseif T == "attackers" then return Color3.fromRGB(255, 80, 80) end
	return Color3.fromRGB(0, 255, 120)
end

local U = {
	V=false, W=false, X=true, Y=false, Z=true, a1=true, b1=false, c1=false, d1=1500,
	e1=Color3.fromRGB(255, 60, 60), f1=Color3.fromRGB(255, 255, 255), g1=0.5, h1=14,
	i1=false, j1=300, k1="Head", l1=true, m1=false, n1=0.5, o1=0.6, p1=0.4, q1=true,
	r1=false, s1=16, t1=nil, u1=nil, v1=0, w1=nil,
}

local x1 = Instance.new("ScreenGui")
x1.Name = "LostFrontlineAI" x1.ResetOnSpawn = false x1.IgnoreGuiInset = true
x1.ZIndexBehavior = Enum.ZIndexBehavior.Sibling x1.DisplayOrder = 999999 x1.Parent = g

local function y1(z1)
	local A1 = Instance.new("Frame")
	A1.Size = UDim2.new(0, 12, 0, 12) A1.BackgroundColor3 = z1 A1.BorderSizePixel = 0 A1.ZIndex = 101 A1.Visible = false A1.Parent = x1
	Instance.new("UICorner", A1).CornerRadius = UDim.new(1, 0)
	return A1
end
local B1 = y1(Color3.fromRGB(255, 80, 80))
local C1 = y1(Color3.fromRGB(255, 80, 80))
local D1 = y1(Color3.fromRGB(255, 80, 80))
local E1 = y1(Color3.fromRGB(255, 80, 80))

local function F1()
	local G1 = Instance.new("Frame")
	G1.BackgroundColor3 = Color3.fromRGB(255, 255, 255) G1.BackgroundTransparency = 0.3 G1.BorderSizePixel = 0 G1.ZIndex = 100 G1.Visible = false G1.Parent = x1
	return G1
end
local H1 = F1() local I1 = F1() local J1 = F1() local K1 = F1()

local L1 = Instance.new("Frame")
L1.Size = UDim2.new(0, 8, 0, 1) L1.BackgroundColor3 = Color3.fromRGB(255, 80, 80) L1.BorderSizePixel = 0 L1.ZIndex = 102 L1.Visible = false L1.Parent = x1

local M1 = Instance.new("Frame")
M1.Size = UDim2.new(0, 1, 0, 8) M1.BackgroundColor3 = Color3.fromRGB(255, 80, 80) M1.BorderSizePixel = 0 M1.ZIndex = 102 M1.Visible = false M1.Parent = x1

local function N1()
	if not (U.i1 and U.q1) then
		for _, O1 in ipairs({B1, C1, D1, E1, H1, I1, J1, K1, L1, M1}) do O1.Visible = false end
		return
	end
	local P1 = f.ViewportSize.X / 2
	local Q1 = f.ViewportSize.Y / 2
	local R1 = U.j1
	B1.Position = UDim2.new(0, P1 - R1 - 6, 0, Q1 - R1 - 6)
	C1.Position = UDim2.new(0, P1 + R1 - 6, 0, Q1 - R1 - 6)
	D1.Position = UDim2.new(0, P1 - R1 - 6, 0, Q1 + R1 - 6)
	E1.Position = UDim2.new(0, P1 + R1 - 6, 0, Q1 + R1 - 6)
	B1.Visible = true C1.Visible = true D1.Visible = true E1.Visible = true
	H1.Size = UDim2.new(0, R1*2, 0, 1) H1.Position = UDim2.new(0, P1 - R1, 0, Q1 - R1) H1.Visible = true
	I1.Size = UDim2.new(0, R1*2, 0, 1) I1.Position = UDim2.new(0, P1 - R1, 0, Q1 + R1) I1.Visible = true
	J1.Size = UDim2.new(0, 1, 0, R1*2) J1.Position = UDim2.new(0, P1 - R1, 0, Q1 - R1) J1.Visible = true
	K1.Size = UDim2.new(0, 1, 0, R1*2) K1.Position = UDim2.new(0, P1 + R1, 0, Q1 - R1) K1.Visible = true
	L1.Position = UDim2.new(0, P1 - 4, 0, Q1) L1.Visible = true
	M1.Position = UDim2.new(0, P1, 0, Q1 - 4) M1.Visible = true
end

local S1 = Instance.new("TextLabel")
S1.Size = UDim2.new(0, 600, 0, 34) S1.Position = UDim2.new(0.5, 0, 0, 50) S1.AnchorPoint = Vector2.new(0.5, 0)
S1.BackgroundTransparency = 1 S1.TextColor3 = Color3.fromRGB(255, 220, 60) S1.TextStrokeTransparency = 0
S1.TextStrokeColor3 = Color3.new(0, 0, 0) S1.Font = Enum.Font.GothamBold S1.TextSize = 20
S1.Visible = false S1.ZIndex = 100 S1.Parent = x1

local T1 = {}

local function U1(V1)
	if T1[V1] then return end
	local W1 = V1.Character
	if not W1 then return end
	local X1 = W1:FindFirstChild("Head") or W1:FindFirstChild("UpperTorso")
	if not X1 then return end
	local Y1 = Instance.new("BillboardGui")
	Y1.Size = UDim2.new(0, 160, 0, 60) Y1.StudsOffsetWorldSpace = Vector3.new(0, 3.2, 0)
	Y1.AlwaysOnTop = true Y1.LightInfluence = 0 Y1.MaxDistance = U.d1 Y1.Enabled = false Y1.Parent = X1
	local Z1 = Instance.new("TextLabel")
	Z1.Size = UDim2.new(1, 0, 0, 18) Z1.BackgroundTransparency = 1 Z1.TextColor3 = Color3.fromRGB(0, 255, 120)
	Z1.TextStrokeTransparency = 0 Z1.TextStrokeColor3 = Color3.new(0, 0, 0) Z1.Font = Enum.Font.GothamBold
	Z1.TextSize = U.h1 Z1.Text = V1.Name Z1.Parent = Y1
	local a2 = Instance.new("Frame")
	a2.Size = UDim2.new(0.8, 0, 0, 6) a2.Position = UDim2.new(0.1, 0, 0, 20)
	a2.BackgroundColor3 = Color3.fromRGB(30, 30, 30) a2.BorderSizePixel = 1 a2.Parent = Y1
	Instance.new("UICorner", a2).CornerRadius = UDim.new(0, 2)
	local b2 = Instance.new("Frame")
	b2.Size = UDim2.new(1, 0, 1, 0) b2.BackgroundColor3 = Color3.fromRGB(0, 255, 0) b2.BorderSizePixel = 0 b2.Parent = a2
	Instance.new("UICorner", b2).CornerRadius = UDim.new(0, 2)
	local c2 = Instance.new("TextLabel")
	c2.Size = UDim2.new(1, 0, 0, 16) c2.Position = UDim2.new(0, 0, 0, 28) c2.BackgroundTransparency = 1
	c2.TextColor3 = Color3.fromRGB(255, 255, 255) c2.TextStrokeTransparency = 0 c2.TextStrokeColor3 = Color3.new(0, 0, 0)
	c2.Font = Enum.Font.GothamBold c2.TextSize = U.h1 - 2 c2.Parent = Y1
	local d2 = Instance.new("TextLabel")
	d2.Size = UDim2.new(1, 0, 0, 14) d2.Position = UDim2.new(0, 0, 0, 44) d2.BackgroundTransparency = 1
	d2.TextColor3 = Color3.fromRGB(200, 200, 200) d2.TextStrokeTransparency = 0 d2.TextStrokeColor3 = Color3.new(0, 0, 0)
	d2.Font = Enum.Font.Gotham d2.TextSize = U.h1 - 2 d2.Parent = Y1
	T1[V1] = {e2=Y1, f2=Z1, g2=a2, h2=b2, i2=c2, j2=d2, k2=nil, l2=nil}
end

local function m2(n2)
	local o2 = T1[n2]
	if not o2 then return end
	if o2.e2 then o2.e2:Destroy() end
	if o2.k2 then o2.k2:Destroy() end
	T1[n2] = nil
end

local function p2(q2)
	local r2 = T1[q2]
	if not r2 then return end
	local s2 = q2.Character
	if not s2 or not s2:IsDescendantOf(workspace) then
		if r2.k2 then r2.k2.Enabled = false end
		return
	end
	if not U.Y then
		if r2.k2 then r2.k2.Enabled = false end
		return
	end
	if r2.k2 and (r2.k2.Parent ~= s2 or r2.l2 ~= s2) then r2.k2:Destroy() r2.k2 = nil end
	local t2 = U.e1
	if U.X then local u2 = o[q2] if u2 then t2 = S(u2) end end
	if not r2.k2 then
		local v2 = Instance.new("Highlight")
		v2.FillColor = t2 v2.OutlineColor = U.f1 v2.FillTransparency = U.g1
		v2.OutlineTransparency = 0 v2.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		v2.Adornee = s2 v2.Parent = s2 r2.k2 = v2 r2.l2 = s2
	else
		r2.k2.Adornee = s2 r2.k2.FillColor = t2 r2.k2.OutlineColor = U.f1
		r2.k2.FillTransparency = U.g1 r2.k2.Enabled = true
	end
end

local function w2()
	if not U.V then
		for _, x2 in pairs(T1) do
			if x2.e2 then x2.e2.Enabled = false end
			if x2.k2 then x2.k2.Enabled = false end
		end
		return
	end
	for _, y2 in ipairs(d:GetPlayers()) do
		if y2 == e then continue end
		if U.W and O(y2) then
			local z2 = T1[y2]
			if z2 then
				if z2.e2 then z2.e2.Enabled = false end
				if z2.k2 then z2.k2.Enabled = false end
			end
			continue
		end
		local A2 = y2.Character
		local B2 = A2 and A2:FindFirstChildOfClass("Humanoid")
		local C2 = A2 and A2:FindFirstChild("HumanoidRootPart")
		if not (A2 and B2 and C2 and B2.Health > 0 and A2:IsDescendantOf(workspace)) then
			local D2 = T1[y2]
			if D2 then
				if D2.e2 then D2.e2.Enabled = false end
				if D2.k2 then D2.k2.Enabled = false end
			end
			continue
		end
		local E2 = T1[y2]
		if E2 and E2.e2 and E2.e2.Parent ~= (A2:FindFirstChild("Head") or A2:FindFirstChild("UpperTorso")) then m2(y2) E2 = nil end
		if not E2 then U1(y2) E2 = T1[y2] end
		if not E2 then continue end
		local F2 = (f.CFrame.Position - C2.Position).Magnitude
		if F2 > U.d1 then
			E2.e2.Enabled = false
			if E2.k2 then E2.k2.Enabled = false end
			continue
		end
		E2.e2.Enabled = true
		E2.e2.MaxDistance = U.d1
		local G2 = nil
		if U.X then
			local H2 = o[y2]
			if H2 then G2 = S(H2) end
			if not G2 and O(y2) then local I2 = p or o[e] if I2 then G2 = S(I2) end end
			if not G2 then G2 = Color3.fromRGB(255, 80, 80) end
		end
		E2.f2.Visible = U.Z E2.f2.Text = y2.Name E2.f2.TextSize = U.h1
		if G2 then E2.f2.TextColor3 = G2 end
		E2.g2.Visible = U.b1
		local J2 = math.clamp(B2.Health / math.max(B2.MaxHealth, 1), 0, 1)
		E2.h2.Size = UDim2.new(J2, 0, 1, 0)
		E2.h2.BackgroundColor3 = Color3.fromRGB(math.floor(255 * (1 - J2)), math.floor(255 * J2), 0)
		E2.i2.Visible = U.a1
		E2.i2.Text = string.format("%d / %d", math.floor(B2.Health), math.floor(B2.MaxHealth))
		E2.i2.TextSize = U.h1 - 2
		if G2 then E2.i2.TextColor3 = G2 end
		E2.j2.Visible = U.c1 E2.j2.Text = string.format("%.0fm", F2) E2.j2.TextSize = U.h1 - 2
		if G2 then E2.j2.TextColor3 = G2 end
		p2(y2)
	end
end

local function K2(L2)
	if U.k1 == "Head" then return L2:FindFirstChild("Head")
	elseif U.k1 == "HumanoidRootPart" then return L2:FindFirstChild("HumanoidRootPart")
	elseif U.k1 == "UpperTorso" then return L2:FindFirstChild("UpperTorso") or L2:FindFirstChild("Torso") end
	return L2:FindFirstChild("HumanoidRootPart")
end

local function M2(N2) return N2.Position end

local function O2(P2)
	local Q2 = RaycastParams.new()
	Q2.FilterType = Enum.RaycastFilterType.Exclude
	local R2 = { f }
	if e.Character then table.insert(R2, e.Character) end
	Q2.FilterDescendantsInstances = R2
	local S2 = workspace:Raycast(f.CFrame.Position, (P2.Position - f.CFrame.Position), Q2)
	if not S2 then return false end
	return S2.Instance == P2 or S2.Instance:IsDescendantOf(P2.Parent)
end

local function T2(U2, V2, W2, X2)
	local Y2 = U2.Character and U2.Character:FindFirstChildOfClass("Humanoid")
	if not Y2 or Y2.Health <= 0 then return math.huge end
	local Z2 = M2(V2)
	local a3, b3 = f:WorldToViewportPoint(Z2)
	if not b3 then return math.huge end
	local c3 = (Vector2.new(a3.X, a3.Y) - W2).Magnitude
	if c3 > U.j1 then return math.huge end
	if U.m1 and not O2(V2) then return math.huge end
	local d3 = (X2 - Z2).Magnitude
	return (c3 / U.j1) * U.o1 + math.min(d3 / 1000, 1) * U.p1
end

local function e3()
	local f3 = tick()
	local g3 = Vector2.new(f.ViewportSize.X / 2, f.ViewportSize.Y / 2)
	local h3 = f.CFrame.Position
	if U.w1 and U.w1.Character then
		local i3 = U.w1
		local j3 = i3.Character
		local k3 = j3 and j3:FindFirstChildOfClass("Humanoid")
		if k3 and k3.Health > 0 and not (U.l1 and O(i3)) then
			local l3 = K2(j3)
			if l3 then
				local m3 = T2(i3, l3, g3, h3)
				if m3 < math.huge and (f3 - U.v1) < U.n1 then U.v1 = f3 return i3, l3 end
			end
		end
	end
	local n3, o3, p3 = nil, nil, math.huge
	for _, q3 in ipairs(d:GetPlayers()) do
		if q3 == e then continue end
		if U.l1 and O(q3) then continue end
		local r3 = q3.Character
		if not r3 then continue end
		local s3 = K2(r3)
		if not s3 then continue end
		local t3 = T2(q3, s3, g3, h3)
		if t3 < p3 then p3 = t3 n3 = q3 o3 = s3 end
	end
	if n3 then U.w1 = n3 U.v1 = f3 end
	return n3, o3
end

local function u3(v3)
	local w3 = f.CFrame.Position
	if (v3 - w3).Magnitude > 0.5 then f.CFrame = CFrame.new(w3, v3) end
end

c.Heartbeat:Connect(function(x3)
	if not U.r1 then return end
	if U.s1 <= 16 then return end
	local y3 = e.Character
	if not y3 then return end
	local z3 = y3:FindFirstChild("HumanoidRootPart")
	local A3 = y3:FindFirstChildOfClass("Humanoid")
	if not (z3 and A3) then return end
	local B3 = A3.MoveDirection
	if B3.Magnitude > 0.1 then
		local C3 = U.s1
		local D3 = z3.AssemblyLinearVelocity
		z3.AssemblyLinearVelocity = Vector3.new(B3.X * C3, D3.Y, B3.Z * C3)
	end
end)

c.RenderStepped:Connect(function(E3)
	pcall(w2) pcall(N1)
	if U.i1 then
		local F3, G3 = e3()
		U.t1 = F3 U.u1 = G3
		if F3 and G3 then pcall(u3, M2(G3)) end
	else
		U.t1 = nil U.u1 = nil U.w1 = nil
	end
	if U.t1 and U.u1 and U.i1 then
		local H3 = U.t1.Character and U.t1.Character:FindFirstChildOfClass("Humanoid")
		local I3 = H3 and math.floor(H3.Health) or 0
		local J3 = (f.CFrame.Position - U.u1.Position).Magnitude
		local K3 = o[U.t1] or "?"
		S1.Visible = true
		S1.Text = string.format("%s [%s] %dHP %.0fm", U.t1.Name, tostring(K3), I3, J3)
	else
		S1.Visible = false
	end
end)

local function L3(M3)
	if M3 == e then return end
	M3.CharacterAdded:Connect(function()
		if T1[M3] then m2(M3) end
		task.wait(0.4)
		if U.V then U1(M3) p2(M3) end
	end)
end
for _, N3 in ipairs(d:GetPlayers()) do L3(N3) end
d.PlayerAdded:Connect(L3)
d.PlayerRemoving:Connect(function(O3) m2(O3) o[O3] = nil end)

local P3 = h:CreateWindow({
	Title = "失落的前线 AI",
	Author = "",
	Icon = "solar:target-bold",
	Theme = "Dark",
	ToggleKey = Enum.KeyCode.RightShift,
})

local Q3 = P3:Tab({ Title = "自瞄", Icon = "crosshair" })
local R3 = Q3:Section({ Title = "AIM", Icon = "target", Box = true, BoxBorder = true })
R3:Toggle({ Title = "自瞄", Value = false, Callback = function(S3) U.i1 = S3 end })
R3:Toggle({ Title = "FOV", Value = true, Callback = function(T3) U.q1 = T3 end })
R3:Toggle({ Title = "队伍", Value = true, Callback = function(U3) U.l1 = U3 end })
R3:Toggle({ Title = "墙检测", Value = false, Callback = function(V3) U.m1 = V3 end })
R3:Slider({ Title = "半径", Value = { Min = 30, Max = 800, Default = 300 }, Callback = function(W3) U.j1 = W3 end })
R3:Slider({ Title = "屏权重", Value = { Min = 0, Max = 1, Default = 0.6, Decimals = 2 }, Callback = function(X3) U.o1 = X3 end })
R3:Slider({ Title = "距权重", Value = { Min = 0, Max = 1, Default = 0.4, Decimals = 2 }, Callback = function(Y3) U.p1 = Y3 end })
R3:Slider({ Title = "粘滞", Value = { Min = 0.1, Max = 2, Default = 0.5, Decimals = 2 }, Callback = function(Z3) U.n1 = Z3 end })
R3:Dropdown({ Title = "部位", Values = { "Head", "HumanoidRootPart", "UpperTorso" }, Value = "Head", Callback = function(a4) U.k1 = a4 end })

local b4 = P3:Tab({ Title = "透视", Icon = "eye" })
local c4 = b4:Section({ Title = "ESP", Icon = "scan", Box = true, BoxBorder = true })
c4:Toggle({ Title = "ESP", Value = false, Callback = function(d4)
	U.V = d4
	if not d4 then for e4 in pairs(T1) do m2(e4) end
	else for _, f4 in ipairs(d:GetPlayers()) do if f4 ~= e then U1(f4) p2(f4) end end end
end })
c4:Toggle({ Title = "仅敌", Value = false, Callback = function(g4) U.W = g4 end })
c4:Toggle({ Title = "队色", Value = true, Callback = function(h4) U.X = h4 end })
c4:Toggle({ Title = "描边", Value = false, Callback = function(i4) U.Y = i4 end })
c4:Toggle({ Title = "名字", Value = true, Callback = function(j4) U.Z = j4 end })
c4:Toggle({ Title = "血量", Value = true, Callback = function(k4) U.a1 = k4 end })
c4:Toggle({ Title = "血条", Value = false, Callback = function(l4) U.b1 = l4 end })
c4:Toggle({ Title = "距离", Value = false, Callback = function(m4) U.c1 = m4 end })
c4:Slider({ Title = "最大距", Value = { Min = 100, Max = 5000, Default = 1500 }, Callback = function(n4) U.d1 = n4 end })

local o4 = P3:Tab({ Title = "玩家", Icon = "user" })
local p4 = o4:Section({ Title = "SPD", Icon = "wind", Box = true, BoxBorder = true })
p4:Toggle({ Title = "移速", Value = false, Callback = function(q4) U.r1 = q4 end })
p4:Slider({ Title = "速度", Value = { Min = 16, Max = 80, Default = 16, Decimals = 0 }, Callback = function(r4) U.s1 = r4 end })

local q4b = P3:Tab({ Title = "日志", Icon = "file-text" })
local r4b = q4b:Section({ Title = "调试", Icon = "bug", Box = true, BoxBorder = true })
r4b:Button({ Title = "打印队伍状态", Callback = function()
	print("=== 队伍 ===")
	print("我的队伍:", p or o[e] or "未知")
	for _, s4 in ipairs(d:GetPlayers()) do
		if s4 == e then continue end
		print(string.format("  %s | 队=%s | 同=%s", s4.Name, tostring(o[s4]), tostring(O(s4))))
	end
end })
r4b:Button({ Title = "打印玩家列表", Callback = function()
	print("=== 玩家 ===")
	local t4 = f.CFrame.Position
	for _, u4 in ipairs(d:GetPlayers()) do
		if u4 == e then continue end
		local v4 = u4.Character
		local w4 = v4 and v4:FindFirstChildOfClass("Humanoid")
		local x4 = v4 and v4:FindFirstChild("HumanoidRootPart")
		if w4 and x4 then
			print(string.format("  %s | %d/%d | %.0fm | %s",
				u4.Name, math.floor(w4.Health), math.floor(w4.MaxHealth),
				(t4 - x4.Position).Magnitude, tostring(o[u4])))
		else
			print(string.format("  %s | 无角色 | %s", u4.Name, tostring(o[u4])))
		end
	end
end })
r4b:Button({ Title = "打印自瞄状态", Callback = function()
	print("=== 自瞄 ===")
	print("启用:", U.i1, "| 队伍检测:", U.l1, "| FOV:", U.j1)
	if U.t1 then
		local y4 = U.t1.Character and U.t1.Character:FindFirstChildOfClass("Humanoid")
		print("目标:", U.t1.Name, "| HP:", y4 and math.floor(y4.Health) or "?", "| 队:", tostring(o[U.t1]))
	else
		print("无目标")
	end
end })
r4b:Button({ Title = "打印网络对象", Callback = function()
	print("=== network ===")
	local z4 = b:FindFirstChild("network")
	if z4 then
		for _, A4 in ipairs(z4:GetChildren()) do print("  " .. A4.Name .. " [" .. A4.ClassName .. "]") end
	else
		print("  无")
	end
end })
r4b:Button({ Title = "打印我的角色", Callback = function()
	print("=== 我的角色 ===")
	local B4 = e.Character
	if not B4 then print("  无角色") return end
	local C4 = B4:FindFirstChildOfClass("Humanoid")
	local D4 = B4:FindFirstChild("HumanoidRootPart")
	print("  名:", B4.Name)
	print("  Humanoid:", C4 and "有" or "无")
	print("  HRP:", D4 and "有" or "无")
	if C4 then print("  WalkSpeed:", C4.WalkSpeed, "| HP:", C4.Health) end
	if D4 then print("  位置:", tostring(D4.Position)) end
end })
