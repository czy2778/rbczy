-- ============================================
-- 翻译+AI聊天脚本 v6（完整版）
-- 改动：聊天框 280x340 + API Key 自动补 sk-
-- ============================================

local P = game:GetService("Players")
local R = game:GetService("RunService")
local H = game:GetService("HttpService")
local L = P.LocalPlayer
local C = L:WaitForChild("PlayerGui")

if not _G.AIW then
    _G.AIW = {
        UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))(),
        MainWindow = nil,
    }
end
local W = _G.AIW.UI

local hasMain = _G.AIW.MainWindow ~= nil
local Win, TrTab, ChatTab

if hasMain then
    Win = _G.AIW.MainWindow
    if _G.AITrans and _G.AITrans.Tab then
        TrTab = _G.AITrans.Tab
        pcall(function() _G.AITrans.Label:Destroy() end)
        pcall(function() _G.AITrans.Btn:Destroy() end)
    else
        TrTab = Win:Tab({ Title = "翻译", Icon = "languages" })
    end
    if _G.AIChat and _G.AIChat.Tab then
        ChatTab = _G.AIChat.Tab
        pcall(function() _G.AIChat.Label:Destroy() end)
        pcall(function() _G.AIChat.Btn:Destroy() end)
    else
        ChatTab = Win:Tab({ Title = "AI聊天", Icon = "message-circle" })
    end
else
    Win = W:CreateWindow({
        Title = "通用翻译", Author = "czy", Icon = "languages",
        Theme = "Dark", ToggleKey = Enum.KeyCode.RightShift,
    })
    Win:Tag({ Title = "独立模式", Color = "ElementBackground" })
    local GenTab = Win:Tab({ Title = "通用", Icon = "home" })
    TrTab = Win:Tab({ Title = "翻译", Icon = "languages" })
    ChatTab = Win:Tab({ Title = "AI聊天", Icon = "message-circle" })
    GenTab:Paragraph({ Title = "通用脚本未加载", Desc = "点击下方按钮加载" })
    GenTab:Button({
        Title = "加载通用脚本",
        Callback = function()
            local function urlEncode(str)
                return str:gsub("([^%w%-%_%.%~])", function(c)
                    return string.format("%%%02X", string.byte(c))
                end)
            end
            local url = "https://raw.githubusercontent.com/czy2778/rbczy/main/" .. urlEncode("通用.lua")
            local ok, code = pcall(function() return game:HttpGet(url) end)
            if not ok then W:Notify({Title="通用", Content="拉取失败", Duration=4}) return end
            local fn = loadstring(code)
            if fn then pcall(fn) end
        end,
    })
    _G.StandaloneW = { Window = Win, Notify = W }
end

_G.AITrans = _G.AITrans or {}
_G.AITrans.Tab = TrTab
_G.AITrans.Window = Win
_G.AITrans.Notify = W
_G.AITrans.Active = true

_G.AIChat = _G.AIChat or {}
_G.AIChat.Tab = ChatTab
_G.AIChat.Window = Win
_G.AIChat.Notify = W
_G.AIChat.Active = true

-- ============ API 预设 ============
local ApiPresets = {
    MyMemory = {url = "", model = "免费"},
    DeepSeek = {url = "https://api.deepseek.com/v1/chat/completions", model = "deepseek-chat"},
    Zhipu = {url = "https://open.bigmodel.cn/api/paas/v4/chat/completions", model = "glm-4-flash"},
    Kimi = {url = "https://api.moonshot.cn/v1/chat/completions", model = "moonshot-v1-8k"},
    Doubao = {url = "https://ark.cn-beijing.volces.com/api/v3/chat/completions", model = "doubao-pro-32k"},
    OpenAI = {url = "https://api.openai.com/v1/chat/completions", model = "gpt-4o-mini"},
    Custom = {url = "", model = ""},
}

-- ============ 翻译 ============
local Tr = {Enabled=false, Api="MyMemory", ApiKey="", CustomUrl="", CustomModel="", Translating=false, Done=0, Total=0, Cache={}}

local function trMM(text)
    local url = "https://api.mymemory.translated.net/get?q=" .. H:UrlEncode(text) .. "&langpair=en|zh-CN"
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if not ok then return nil, "网络失败" end
    local ok2, d = pcall(function() return H:JSONDecode(res) end)
    if not ok2 or not d or not d.responseData then return nil, "解析失败" end
    if d.responseData.translatedText == text then return nil, "MyMemory 未翻译（可能超量）" end
    return d.responseData.translatedText
end

local function trAI(text, url, key, model)
    if not key or key == "" then return nil, "缺 API Key" end
    -- ★ 自动补 sk-
    if Tr.Api ~= "Zhipu" and Tr.Api ~= "Custom" and not key:match("^sk%-") then
        key = "sk-" .. key
    end
    local body = H:JSONEncode({
        model = model,
        messages = {
            {role="system", content="Translate the following English text to Simplified Chinese. Only output the translation."},
            {role="user", content=text}
        },
        temperature = 0.3,
    })
    local hd = {["Content-Type"]="application/json", ["Authorization"]="Bearer " .. key}
    local res
    local ok = pcall(function() res = request({Url=url, Method="POST", Headers=hd, Body=body}) end)
    if not ok then return nil, "请求失败（request 不支持）" end
    if type(res) == "table" and res.Body then res = res.Body end
    local ok2, d = pcall(function() return H:JSONDecode(res) end)
    if not ok2 or not d then return nil, "JSON 解析失败" end
    if d.error then return nil, "API 错误: " .. tostring(d.error.message or d.error) end
    if d.choices and d.choices[1] and d.choices[1].message then
        return d.choices[1].message.content
    end
    return nil, "响应格式异常"
end

local function translate(text)
    if Tr.Cache[text] then return Tr.Cache[text], nil end
    local r, err
    if Tr.Api == "MyMemory" then
        r, err = trMM(text)
    else
        local preset = ApiPresets[Tr.Api]
        if not preset then return text, "未知 API" end
        local url = Tr.CustomUrl ~= "" and Tr.CustomUrl or preset.url
        local model = Tr.CustomModel ~= "" and Tr.CustomModel or preset.model
        r, err = trAI(text, url, Tr.ApiKey, model)
    end
    if not r then return text, err end
    Tr.Cache[text] = r
    return r, nil
end

local doneM = {}

local function collectTxt()
    local l = {}
    local function scan(p)
        for _, o in ipairs(p:GetDescendants()) do
            if (o:IsA("TextLabel") or o:IsA("TextButton")) and o.Text and #o.Text > 0 and o.Text:match("%a") and not doneM[o] then
                table.insert(l, o)
            end
        end
    end
    pcall(function() scan(L.PlayerGui) end)
    pcall(function() scan(game:GetService("CoreGui")) end)
    return l
end

local progressPara = TrTab:Paragraph({ Title = "翻译进度", Desc = "未开始" })

local function updProg()
    if Tr.Total == 0 then
        progressPara:SetTitle("翻译进度")
        progressPara:SetDesc("未开始")
        return
    end
    progressPara:SetTitle(string.format("翻译进度: %d / %d", Tr.Done, Tr.Total))
    progressPara:SetDesc(string.format("完成度: %.1f%%", Tr.Done / Tr.Total * 100))
end

local function runTr()
    if Tr.Translating then return end
    Tr.Translating = true
    local t = collectTxt()
    Tr.Total = #t
    Tr.Done = 0
    updProg()
    if #t == 0 then Tr.Translating = false return end
    for _, o in ipairs(t) do
        task.spawn(function()
            local r = translate(o.Text)
            pcall(function() o.Text = r end)
            doneM[o] = true
            Tr.Done = Tr.Done + 1
            updProg()
        end)
        task.wait(0.25)
    end
    Tr.Translating = false
end

local trConn
local function startTr()
    if trConn then return end
    trConn = R.Heartbeat:Connect(function()
        if not Tr.Enabled or Tr.Translating then return end
        local t = collectTxt()
        if #t > 0 then runTr() end
    end)
end

TrTab:Toggle({ Title = "翻译开关", Value = false, Callback = function(v) Tr.Enabled = v if v then startTr() runTr() end end })
TrTab:Dropdown({
    Title = "翻译 API",
    Values = {"MyMemory", "DeepSeek", "Zhipu", "Kimi", "Doubao", "OpenAI", "Custom"},
    Value = "MyMemory",
    Callback = function(v) Tr.Api = v end,
})
TrTab:Input({ Title = "API Key", Placeholder = "填 Key（MyMemory 不用）", Callback = function(v) Tr.ApiKey = v end })
TrTab:Input({ Title = "自定义地址", Placeholder = "仅 Custom 填", Callback = function(v) Tr.CustomUrl = v end })
TrTab:Input({ Title = "自定义模型", Placeholder = "仅 Custom 填", Callback = function(v) Tr.CustomModel = v end })
TrTab:Button({ Title = "立即翻译", Callback = function() runTr() end })
TrTab:Button({ Title = "清空缓存", Callback = function() Tr.Cache = {} doneM = {} end })
TrTab:Button({
    Title = "测试翻译 API",
    Callback = function()
        local testText = "Hello world"
        Tr.Cache = {}
        local r, err = translate(testText)
        if err then
            W:Notify({ Title = "翻译测试失败", Content = err, Duration = 8 })
        else
            W:Notify({ Title = "翻译测试成功", Content = "原: " .. testText .. "\n译: " .. r, Duration = 8 })
        end
    end,
})

-- ============ AI 聊天 ============
local Chat = {History = {}, ApiKey = "", Api = "DeepSeek", System = "You are a helpful assistant.", CustomUrl = "", CustomModel = ""}

local chatWin = Instance.new("ScreenGui")
chatWin.Name = "AIChatWindow"
chatWin.ResetOnSpawn = false
chatWin.Parent = C
chatWin.Enabled = false

-- ★ 聊天框缩小 280x340
local chatFrame = Instance.new("Frame")
chatFrame.Size = UDim2.new(0, 280, 0, 340)
chatFrame.Position = UDim2.new(0.5, -140, 0.5, -170)
chatFrame.BackgroundColor3 = Color3.fromRGB(18,18,24)
chatFrame.BorderSizePixel = 0
chatFrame.Active = true
chatFrame.Draggable = true
chatFrame.Parent = chatWin
local chatWC = Instance.new("UICorner"); chatWC.CornerRadius = UDim.new(0,10); chatWC.Parent = chatFrame
local chatWS = Instance.new("UIStroke"); chatWS.Color = Color3.fromRGB(80,200,255); chatWS.Thickness = 1.5; chatWS.Parent = chatFrame

local chatTitle = Instance.new("TextLabel")
chatTitle.Size = UDim2.new(1, -60, 0, 26)
chatTitle.Position = UDim2.new(0, 10, 0, 2)
chatTitle.BackgroundTransparency = 1
chatTitle.Text = "AI 聊天"
chatTitle.TextColor3 = Color3.fromRGB(80,200,255)
chatTitle.TextScaled = true
chatTitle.Font = Enum.Font.GothamBold
chatTitle.TextXAlignment = Enum.TextXAlignment.Left
chatTitle.Parent = chatFrame

local chatClose = Instance.new("TextButton")
chatClose.Size = UDim2.new(0, 22, 0, 22)
chatClose.Position = UDim2.new(1, -26, 0, 4)
chatClose.BackgroundColor3 = Color3.fromRGB(200,60,60)
chatClose.BorderSizePixel = 0
chatClose.Text = "×"
chatClose.TextColor3 = Color3.fromRGB(255,255,255)
chatClose.TextScaled = true
chatClose.Font = Enum.Font.GothamBold
chatClose.Parent = chatFrame
local chatCloseC = Instance.new("UICorner"); chatCloseC.CornerRadius = UDim.new(0,5); chatCloseC.Parent = chatClose
chatClose.MouseButton1Click:Connect(function() chatWin.Enabled = false end)

local chatMsg = Instance.new("ScrollingFrame")
chatMsg.Size = UDim2.new(1, -16, 1, -84)
chatMsg.Position = UDim2.new(0, 8, 0, 30)
chatMsg.BackgroundColor3 = Color3.fromRGB(25,25,32)
chatMsg.BorderSizePixel = 0
chatMsg.ScrollBarThickness = 3
chatMsg.CanvasSize = UDim2.new(0,0,0,0)
chatMsg.AutomaticCanvasSize = Enum.AutomaticSize.Y
chatMsg.Parent = chatFrame
local chatMsgC = Instance.new("UICorner"); chatMsgC.CornerRadius = UDim.new(0,6); chatMsgC.Parent = chatMsg
local chatMsgL = Instance.new("UIListLayout")
chatMsgL.Padding = UDim.new(0,4); chatMsgL.SortOrder = Enum.SortOrder.LayoutOrder; chatMsgL.Parent = chatMsg
local chatMsgP = Instance.new("UIPadding")
chatMsgP.PaddingTop = UDim.new(0,4); chatMsgP.PaddingBottom = UDim.new(0,4)
chatMsgP.PaddingLeft = UDim.new(0,4); chatMsgP.PaddingRight = UDim.new(0,4)
chatMsgP.Parent = chatMsg

local function addMsg(who, txt, col)
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(1, 0, 0, 0)
    lb.AutomaticSize = Enum.AutomaticSize.Y
    lb.BackgroundTransparency = 1
    lb.Text = who .. ": " .. txt
    lb.TextColor3 = col
    lb.TextSize = 12
    lb.TextWrapped = true
    lb.Font = Enum.Font.Gotham
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.Parent = chatMsg
    task.wait(0.05)
    chatMsg.CanvasPosition = Vector2.new(0, chatMsg.AbsoluteCanvasSize.Y)
end

local chatIn = Instance.new("TextBox")
chatIn.Size = UDim2.new(1, -70, 0, 26)
chatIn.Position = UDim2.new(0, 8, 1, -34)
chatIn.BackgroundColor3 = Color3.fromRGB(35,35,42)
chatIn.BorderSizePixel = 0
chatIn.Text = ""
chatIn.PlaceholderText = "输入..."
chatIn.TextColor3 = Color3.fromRGB(255,255,255)
chatIn.PlaceholderColor3 = Color3.fromRGB(120,120,130)
chatIn.TextScaled = true
chatIn.Font = Enum.Font.Gotham
chatIn.Parent = chatFrame
local chatInC = Instance.new("UICorner"); chatInC.CornerRadius = UDim.new(0,6); chatInC.Parent = chatIn

local chatSend = Instance.new("TextButton")
chatSend.Size = UDim2.new(0, 52, 0, 26)
chatSend.Position = UDim2.new(1, -60, 1, -34)
chatSend.BackgroundColor3 = Color3.fromRGB(0,150,90)
chatSend.BorderSizePixel = 0
chatSend.Text = "发送"
chatSend.TextColor3 = Color3.fromRGB(255,255,255)
chatSend.TextScaled = true
chatSend.Font = Enum.Font.GothamBold
chatSend.Parent = chatFrame
local chatSendC = Instance.new("UICorner"); chatSendC.CornerRadius = UDim.new(0,6); chatSendC.Parent = chatSend

local function chatReq(um)
    table.insert(Chat.History, {role="user", content=um})
    local url, key, model
    if Chat.Api == "Custom" then
        url, key, model = Chat.CustomUrl, Chat.ApiKey, Chat.CustomModel
    else
        local preset = ApiPresets[Chat.Api]
        if not preset then addMsg("系统", "未知 API", Color3.fromRGB(255,100,100)) return end
        url, key, model = preset.url, Chat.ApiKey, preset.model
    end
    if not key or key == "" then addMsg("系统", "请先设置 API Key", Color3.fromRGB(255,100,100)) return end
    -- ★ 自动补 sk-
    if Chat.Api ~= "Zhipu" and Chat.Api ~= "Custom" and not key:match("^sk%-") then
        key = "sk-" .. key
    end
    local msgs = {{role="system", content=Chat.System}}
    for _, m in ipairs(Chat.History) do table.insert(msgs, m) end
    local body = H:JSONEncode({model=model, messages=msgs, temperature=0.7})
    local res
    local ok = pcall(function() res = request({Url=url, Method="POST", Headers={["Content-Type"]="application/json", ["Authorization"]="Bearer " .. key}, Body=body}) end)
    if not ok then addMsg("系统", "请求失败", Color3.fromRGB(255,100,100)) return end
    if type(res) == "table" and res.Body then res = res.Body end
    local ok2, d = pcall(function() return H:JSONDecode(res) end)
    if not ok2 or not d then addMsg("系统", "JSON 失败", Color3.fromRGB(255,100,100)) return end
    if d.error then
        addMsg("系统", "API 错误: " .. tostring(d.error.message or d.error), Color3.fromRGB(255,100,100))
        print("[API 错误详情]", H:JSONEncode(d.error))
        return
    end
    if d.choices and d.choices[1] and d.choices[1].message then
        local rp = d.choices[1].message.content
        table.insert(Chat.History, {role="assistant", content=rp})
        addMsg("AI", rp, Color3.fromRGB(200,200,255))
    else
        addMsg("系统", "格式异常", Color3.fromRGB(255,100,100))
    end
end

chatSend.MouseButton1Click:Connect(function()
    local m = chatIn.Text
    if m == "" then return end
    chatIn.Text = ""
    addMsg("我", m, Color3.fromRGB(200,255,200))
    task.spawn(function() chatReq(m) end)
end)

chatIn.FocusLost:Connect(function(en)
    if en and chatIn.Text ~= "" then
        local m = chatIn.Text
        chatIn.Text = ""
        addMsg("我", m, Color3.fromRGB(200,255,200))
        task.spawn(function() chatReq(m) end)
    end
end)

ChatTab:Dropdown({
    Title = "AI 接口",
    Values = {"DeepSeek", "Zhipu", "Kimi", "Doubao", "OpenAI", "Custom"},
    Value = "DeepSeek",
    Callback = function(v) Chat.Api = v end,
})
ChatTab:Input({ Title = "API Key", Placeholder = "填 Key（不用加 sk-）", Callback = function(v) Chat.ApiKey = v end })
ChatTab:Input({ Title = "自定义地址", Placeholder = "仅 Custom 填", Callback = function(v) Chat.CustomUrl = v end })
ChatTab:Input({ Title = "自定义模型", Placeholder = "仅 Custom 填", Callback = function(v) Chat.CustomModel = v end })
ChatTab:Input({ Title = "系统提示词", Placeholder = "You are a helpful assistant.", Callback = function(v) Chat.System = v end })
ChatTab:Button({ Title = "打开聊天框", Callback = function()
    chatWin.Enabled = true
    W:Notify({Title="聊天", Content="窗口已打开", Duration=2})
end })
ChatTab:Button({ Title = "清空对话记录", Callback = function()
    Chat.History = {}
    for _, c in ipairs(chatMsg:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
end })

W:Notify({ Title = "翻译+AI聊天", Content = hasMain and "已接入通用脚本" or "独立模式已加载", Duration = 4 })

print("✅ 翻译+AI聊天脚本 v6 已加载")
