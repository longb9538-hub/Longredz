-- [[ Blox Fruits Rainbow Menu - Ban Offline v6.3 - 800+ Du Lieu + AI Fuzzy Match ]] --

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
math.randomseed(tick())

local MyScriptCore = {
    AutoFarmLevel = function(state)
        if state == true then print("Auto Farm: BAT") else print("Auto Farm: TAT") end
    end,
    TeleportSea3 = function() print("Dang bay sang Sea 3...") end,
    BringMob = function() print("Dang gom quai...") end
}

local OldMenu = CoreGui:FindFirstChild("Gemini_Offline_Core") or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Gemini_Offline_Core")
if OldMenu then OldMenu:Destroy() end

local CoreMenu = Instance.new("ScreenGui")
CoreMenu.Name = "Gemini_Offline_Core"
CoreMenu.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local success, err = pcall(function() CoreMenu.Parent = CoreGui end)
if not success then CoreMenu.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local BaseHolder = Instance.new("Frame")
local FinalSize = UDim2.new(0, 550, 0, 430)
BaseHolder.Name = "BaseHolder"
BaseHolder.Size = UDim2.new(0, 0, 0, 0)
BaseHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
BaseHolder.AnchorPoint = Vector2.new(0.5, 0.5)
BaseHolder.BackgroundTransparency = 1
BaseHolder.Active = true
BaseHolder.Parent = CoreMenu

local MainContainer = Instance.new("Frame")
MainContainer.Size = UDim2.new(1, 0, 1, 0)
MainContainer.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
MainContainer.BorderSizePixel = 0
MainContainer.ZIndex = 2
MainContainer.Parent = BaseHolder
local ContainerCorner = Instance.new("UICorner") ContainerCorner.CornerRadius = UDim.new(0, 14) ContainerCorner.Parent = MainContainer

local RainbowInlay = Instance.new("Frame")
RainbowInlay.Size = UDim2.new(1, -6, 1, -6)
RainbowInlay.Position = UDim2.new(0.5, 0, 0.5, 0)
RainbowInlay.AnchorPoint = Vector2.new(0.5, 0.5)
RainbowInlay.ZIndex = 3
RainbowInlay.Parent = MainContainer
local InlayCorner = Instance.new("UICorner") InlayCorner.CornerRadius = UDim.new(0, 12) InlayCorner.Parent = RainbowInlay

local RainbowGradient = Instance.new("UIGradient")
RainbowGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 180, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 150))
}
RainbowGradient.Parent = RainbowInlay

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -4, 1, -4)
ContentFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
ContentFrame.AnchorPoint = Vector2.new(0.5, 0.5)
ContentFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
ContentFrame.BorderSizePixel = 0
ContentFrame.ZIndex = 4
ContentFrame.ClipsDescendants = true
ContentFrame.Parent = RainbowInlay
local ContentCorner = Instance.new("UICorner") ContentCorner.CornerRadius = UDim.new(0, 10) ContentCorner.Parent = ContentFrame

local function playClickSound()
    local Sound = Instance.new("Sound") Sound.SoundId = "rbxasset://sounds/action_click.mp3" Sound.Volume = 0.5 Sound.Parent = SoundService Sound:Play() Sound.Ended:Connect(function() Sound:Destroy() end)
end

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 400, 0, 40)
Title.Position = UDim2.new(0, 20, 0, 10)
Title.Text = "GEMINI OFFLINE CORE v6.3"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.ZIndex = 5
Title.Parent = ContentFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 26, 0, 26)
CloseButton.Position = UDim2.new(1, -35, 0, 15)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
CloseButton.ZIndex = 5
CloseButton.Parent = ContentFrame
local CBCorner = Instance.new("UICorner") CBCorner.CornerRadius = UDim.new(0, 6) CBCorner.Parent = CloseButton

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -40, 0, 35)
TabBar.Position = UDim2.new(0, 20, 0, 55)
TabBar.BackgroundTransparency = 1
TabBar.ZIndex = 5
TabBar.Parent = ContentFrame

local CheatPage = Instance.new("Frame")
CheatPage.Size = UDim2.new(1, -40, 1, -110)
CheatPage.Position = UDim2.new(0, 20, 0, 100)
CheatPage.BackgroundTransparency = 1
CheatPage.ZIndex = 5
CheatPage.Parent = ContentFrame

local GeminiPage = Instance.new("Frame")
GeminiPage.Size = UDim2.new(1, -40, 1, -110)
GeminiPage.Position = UDim2.new(0, 20, 0, 100)
GeminiPage.BackgroundTransparency = 1
GeminiPage.Visible = false
GeminiPage.ZIndex = 5
GeminiPage.Parent = ContentFrame

local function createTabButton(text, pos, targetPage)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 140, 1, 0)
    Btn.Position = pos
    Btn.Text = text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13
    Btn.TextColor3 = Color3.fromRGB(140, 140, 145)
    Btn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    Btn.ZIndex = 6
    Btn.Parent = TabBar
    local TBC = Instance.new("UICorner") TBC.CornerRadius = UDim.new(0, 6) TBC.Parent = Btn

    Btn.MouseButton1Click:Connect(function()
        playClickSound()
        CheatPage.Visible = false
        GeminiPage.Visible = false
        for _, child in ipairs(TabBar:GetChildren()) do
            if child:IsA("TextButton") then child.TextColor3 = Color3.fromRGB(140, 140, 145) end
        end
        Btn.TextColor3 = Color3.fromRGB(0, 255, 150)
        targetPage.Visible = true
    end)
    return Btn
end

local Tab1 = createTabButton("Chuc Nang", UDim2.new(0, 0, 0, 0), CheatPage)
local Tab2 = createTabButton("Gemini Smart Chat", UDim2.new(0, 150, 0, 0), GeminiPage)
Tab1.TextColor3 = Color3.fromRGB(0, 255, 150)

local function createToggle(text, position, callback)
    local isActive = false
    local ToggleBG = Instance.new("Frame")
    ToggleBG.Size = UDim2.new(0, 230, 0, 40)
    ToggleBG.Position = position
    ToggleBG.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    ToggleBG.ZIndex = 6
    ToggleBG.Parent = CheatPage
    local TBC = Instance.new("UICorner") TBC.CornerRadius = UDim.new(0, 6) TBC.Parent = ToggleBG

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.Text = text
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 13
    Label.TextColor3 = Color3.fromRGB(200, 200, 205)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.ZIndex = 7
    Label.Parent = ToggleBG

    local StatusIndicator = Instance.new("TextButton")
    StatusIndicator.Size = UDim2.new(0, 45, 0, 24)
    StatusIndicator.Position = UDim2.new(1, -55, 0.5, -12)
    StatusIndicator.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    StatusIndicator.Text = "OFF"
    StatusIndicator.Font = Enum.Font.GothamBold
    StatusIndicator.TextSize = 10
    StatusIndicator.TextColor3 = Color3.fromRGB(150, 150, 155)
    StatusIndicator.ZIndex = 7
    StatusIndicator.Parent = ToggleBG
    local SIC = Instance.new("UICorner") SIC.CornerRadius = UDim.new(0, 12) SIC.Parent = StatusIndicator

    StatusIndicator.MouseButton1Click:Connect(function()
        playClickSound()
        isActive = not isActive
        if isActive then
            StatusIndicator.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
            StatusIndicator.TextColor3 = Color3.fromRGB(255, 255, 255)
            StatusIndicator.Text = "ON"
        else
            StatusIndicator.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            StatusIndicator.TextColor3 = Color3.fromRGB(150, 150, 155)
            StatusIndicator.Text = "OFF"
        end
        task.spawn(callback, isActive)
    end)
end

local function createActionButton(text, position, callback)
    local MainBtn = Instance.new("TextButton")
    MainBtn.Size = UDim2.new(0, 230, 0, 40)
    MainBtn.Position = position
    MainBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
    MainBtn.Text = text
    MainBtn.Font = Enum.Font.GothamBold
    MainBtn.TextSize = 13
    MainBtn.TextColor3 = Color3.fromRGB(230, 230, 235)
    MainBtn.ZIndex = 6
    MainBtn.Parent = CheatPage
    local MBC = Instance.new("UICorner") MBC.CornerRadius = UDim.new(0, 6) MBC.Parent = MainBtn
    MainBtn.MouseButton1Click:Connect(function() playClickSound() task.spawn(callback) end)
end

createToggle("Auto Farm Level", UDim2.new(0, 10, 0, 15), MyScriptCore.AutoFarmLevel)
createActionButton("Teleport Sea 3", UDim2.new(0, 260, 0, 15), MyScriptCore.TeleportSea3)
createActionButton("Gom Quai (Bring Mob)", UDim2.new(0, 10, 0, 65), MyScriptCore.BringMob)

local ChatLog = Instance.new("ScrollingFrame")
ChatLog.Size = UDim2.new(1, 0, 1, -50)
ChatLog.BackgroundTransparency = 0.98
ChatLog.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ChatLog.ScrollBarThickness = 4
ChatLog.CanvasSize = UDim2.new(0, 0, 0, 0)
ChatLog.AutomaticCanvasSize = Enum.AutomaticSize.Y
ChatLog.ZIndex = 6
ChatLog.Parent = GeminiPage

local LogLayout = Instance.new("UIListLayout") LogLayout.Padding = UDim.new(0, 10) LogLayout.SortOrder = Enum.SortOrder.LayoutOrder LogLayout.Parent = ChatLog

local InputBox = Instance.new("TextBox")
InputBox.Size = UDim2.new(1, -75, 0, 36)
InputBox.Position = UDim2.new(0, 0, 1, -36)
InputBox.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
InputBox.Text = ""
InputBox.PlaceholderText = "Hoi ve trai, dao, boss, vu khi, fighting style, code..."
InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
InputBox.TextSize = 13
InputBox.Font = Enum.Font.Gotham
InputBox.TextXAlignment = Enum.TextXAlignment.Left
InputBox.ClearTextOnFocus = false
InputBox.ZIndex = 6
InputBox.Parent = GeminiPage
Instance.new("UIPadding", InputBox).PaddingLeft = UDim.new(0, 12)
local IBC = Instance.new("UICorner") IBC.CornerRadius = UDim.new(0, 6) IBC.Parent = InputBox

local SendBtn = Instance.new("TextButton")
SendBtn.Size = UDim2.new(0, 65, 0, 36)
SendBtn.Position = UDim2.new(1, -65, 1, -36)
SendBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
SendBtn.Text = "Gui"
SendBtn.Font = Enum.Font.GothamBold
SendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SendBtn.ZIndex = 6
SendBtn.Parent = GeminiPage
local SBC = Instance.new("UICorner") SBC.CornerRadius = UDim.new(0, 6) SBC.Parent = SendBtn

local function addMessage(senderName, text, color)
    local MsgFrame = Instance.new("Frame")
    MsgFrame.Size = UDim2.new(1, -10, 0, 0)
    MsgFrame.AutomaticSize = Enum.AutomaticSize.Y
    MsgFrame.BackgroundTransparency = 0.88
    MsgFrame.BackgroundColor3 = color
    MsgFrame.ZIndex = 7
    MsgFrame.Parent = ChatLog

    local MFC = Instance.new("UICorner") MFC.CornerRadius = UDim.new(0, 6) MFC.Parent = MsgFrame
    local Pad = Instance.new("UIPadding") Pad.PaddingTop = UDim.new(0, 8) Pad.PaddingBottom = UDim.new(0, 8) Pad.PaddingLeft = UDim.new(0, 10) Pad.PaddingRight = UDim.new(0, 10) Pad.Parent = MsgFrame

    local Content = Instance.new("TextLabel")
    Content.Size = UDim2.new(1, 0, 1, 0)
    Content.Text = "<b>" .. senderName .. ":</b> " .. text
    Content.TextColor3 = Color3.fromRGB(240, 240, 245)
    Content.TextSize = 13
    Content.Font = Enum.Font.Gotham
    Content.TextWrapped = true
    Content.RichText = true
    Content.BackgroundTransparency = 1
    Content.TextXAlignment = Enum.TextXAlignment.Left
    Content.ZIndex = 8
    Content.Parent = MsgFrame

    task.defer(function() ChatLog.CanvasPosition = Vector2.new(0, ChatLog.AbsoluteCanvasSize.Y) end)
    return MsgFrame
end

addMessage("He Thong", "Da kich hoat che do Offline Sieu Toc ban v6.3 voi hon 800 to hop du lieu Blox Fruits. Ho tro ca tieng Viet va tieng Anh (EN/VI), tu dong nhan biet ngon ngu ban dang go! Hoi thoai mai nhe, hoac go 'help' / 'huong dan' de xem vi du. 🥳", Color3.fromRGB(0, 200, 120))

local VN_MAP = {
    ["à"]="a",["á"]="a",["ả"]="a",["ã"]="a",["ạ"]="a",["ă"]="a",["ằ"]="a",["ắ"]="a",["ẳ"]="a",["ẵ"]="a",["ặ"]="a",
    ["â"]="a",["ầ"]="a",["ấ"]="a",["ẩ"]="a",["ẫ"]="a",["ậ"]="a",
    ["è"]="e",["é"]="e",["ẻ"]="e",["ẽ"]="e",["ẹ"]="e",["ê"]="e",["ề"]="e",["ế"]="e",["ể"]="e",["ễ"]="e",["ệ"]="e",
    ["ì"]="i",["í"]="i",["ỉ"]="i",["ĩ"]="i",["ị"]="i",
    ["ò"]="o",["ó"]="o",["ỏ"]="o",["õ"]="o",["ọ"]="o",["ô"]="o",["ồ"]="o",["ố"]="o",["ổ"]="o",["ỗ"]="o",["ộ"]="o",
    ["ơ"]="o",["ờ"]="o",["ớ"]="o",["ở"]="o",["ỡ"]="o",["ợ"]="o",
    ["ù"]="u",["ú"]="u",["ủ"]="u",["ũ"]="u",["ụ"]="u",["ư"]="u",["ừ"]="u",["ứ"]="u",["ử"]="u",["ữ"]="u",["ự"]="u",
    ["ỳ"]="y",["ý"]="y",["ỷ"]="y",["ỹ"]="y",["ỵ"]="y",
    ["đ"]="d",
}
-- Bang teencode / viet tat thong dung, giup hieu duoc cach nhan tin "cao cap" hon
-- (khong dau, viet tat, tieng long) thay vi chi khop nguyen van
local SLANG_MAP = {
    ["ko"]="khong", ["k"]="khong", ["kg"]="khong", ["hok"]="khong", ["hong"]="khong",
    ["hem"]="khong", ["khum"]="khong", ["kh"]="khong",
    ["dc"]="duoc", ["dk"]="duoc",
    ["vs"]="voi", ["z"]="vay", ["j"]="gi", ["jz"]="gi vay", ["sao"]="the nao",
    ["ntn"]="nhu the nao", ["nt"]="nhu the", ["ns"]="noi",
    ["bt"]="binh thuong", ["bth"]="binh thuong",
    ["cx"]="cung", ["cug"]="cung",
    ["r"]="roi", ["rui"]="roi",
    ["mik"]="minh", ["mk"]="minh",
    ["b"]="ban", ["ny"]="ban",
    ["tks"]="cam on", ["thx"]="cam on", ["thank"]="cam on",
    ["ok"]="duoc roi", ["oke"]="duoc roi", ["okla"]="duoc roi",
    ["plz"]="lam on", ["pls"]="lam on",
    ["fr"]="trai", ["fruit"]="trai",
    ["op"]="manh", ["broken"]="manh", ["banh"]="manh", ["dinh"]="manh",
    ["cui"]="yeu", ["te"]="yeu", ["gay"]="yeu",
    ["nch"]="noi chung", ["ncc"]="noi chung",
}
local function applySlang(text)
    local words = {}
    for w in string.gmatch(text, "%S+") do
        words[#words+1] = SLANG_MAP[w] or w
    end
    return table.concat(words, " ")
end

local function normalize(str)
    str = string.lower(str)
    local out = {}
    for _, codepoint in utf8.codes(str) do
        local ch = utf8.char(codepoint)
        out[#out+1] = VN_MAP[ch] or ch
    end
    return applySlang(table.concat(out))
end

local function splitPipe(s)
    local t = {}
    for part in string.gmatch(s, "([^|]+)") do t[#t+1] = part end
    return t
end

local function tokenize(text)
    local words = {}
    for w in string.gmatch(text, "[%a%d]+") do
        if #w >= 2 then words[#words+1] = w end
    end
    return words
end

-- Tu dong nhan biet nguoi choi dang nhan tin bang tieng Anh hay tieng Viet
local VN_HINT_WORDS = {
    " la gi"," khong"," gi ", " cua "," va "," voi "," nao"," the nao"," o dau",
    " manh"," yeu"," gia"," danh sach"," so sanh"," bao nhieu"," duoc khong",
}
local EN_HINT_WORDS = {
    "what is","what's","how ","where ","is it","are you","which ","best ",
    "worst ","strong","weak","compare","list ","help","good","tier","worth",
    "please","fruit","island","boss","weapon","style","awaken","location",
}
local function detectLanguage(rawText, normalizedText)
    -- Dau tieng Viet co dau la tin hieu chac chan nhat
    for ch in string.gmatch(rawText, utf8.charpattern) do
        if VN_MAP[ch] then return "vi" end
    end
    local vnScore, enScore = 0, 0
    for _, w in ipairs(VN_HINT_WORDS) do
        if string.find(normalizedText, w, 1, true) then vnScore = vnScore + 1 end
    end
    local lowerRaw = " " .. string.lower(rawText) .. " "
    for _, w in ipairs(EN_HINT_WORDS) do
        if string.find(lowerRaw, w, 1, true) then enScore = enScore + 1 end
    end
    if enScore > vnScore then return "en" end
    return "vi"
end

local function anyMatch(text, keywords)
    for _, kw in ipairs(keywords) do
        if string.find(text, kw, 1, true) then return true end
    end
    return false
end

local function countMatches(text, keywords)
    local c = 0
    for _, kw in ipairs(keywords) do
        if string.find(text, kw, 1, true) then c = c + 1 end
    end
    return c
end

local function levenshtein(a, b)
    local la, lb = #a, #b
    if la == 0 then return lb end
    if lb == 0 then return la end
    local prev = {}
    for j = 0, lb do prev[j] = j end
    for i = 1, la do
        local cur = {[0] = i}
        local ca = string.byte(a, i)
        for j = 1, lb do
            local cost = (string.byte(b, j) == ca) and 0 or 1
            cur[j] = math.min(prev[j] + 1, cur[j-1] + 1, prev[j-1] + cost)
        end
        prev = cur
    end
    return prev[lb]
end

local EMOJI = {
    hype  = {"🥳","😁"},
    funny = {"🤣"},
    cute  = {"🥹","🥰"},
    love  = {"🥰","😁"},
    sad   = {"😭"},
    neutral = {"😁","🥹"},
}
local function emo(mood)
    local pool = EMOJI[mood] or EMOJI.neutral
    return pool[math.random(1, #pool)]
end
local function tierMood(tier)
    if string.find(tier, "S") then return "hype" end
    if tier == "F" or tier == "D" then return "sad" end
    return "cute"
end

local FRUITS_RAW = {
    {"dragon","Dragon (Dong/Tay)","Beast","S/SS","ca PvP lan PvE","Co dong cuc cao, sat thuong dien rong, mot trong nhung trai dat va manh nhat game.","dragon|rong"},
    {"kitsune","Kitsune","Beast","S","ca PvP lan PvE","Bien hinh nhanh, combo AoE manh, rat duoc ua chuong de san boss lan bounty hunt, tong sat thuong combo thuoc top dau game.","kitsune"},
    {"leopard","Leopard","Beast","S","PvE (farm)","Bien hinh cuc nhanh nhat game, combo AoE rong, cuc manh de cay quai va farm sat thuong don muc tieu.","leopard|bao"},
    {"mammoth","Mammoth","Beast","S","ca PvP lan PvE","Melee manh, khong che dien rong, mot trong cac trai toan dien nhat.","mammoth|voi ma mut"},
    {"buddha","Buddha","Beast","A/S","PvE (cay cap)","Vua cay cap nho tam danh sieu rong khi hoa khong lo va giam sat thuong chiu vao, rat de dung cho nguoi moi, gan nhu bat buoc de farm raid.","buddha|phat to"},
    {"dough","Dough","Natural","A/S","PvP","Sau khi thuc tinh (Dough V2), combo khong che cuc manh, la noi am anh trong PvP neu bat duoc stun dau tien.","dough|banh my|banh mi"},
    {"portal","Portal","Natural","S/SS","PvP","Dich chuyen tuc thoi giup ne don va mo combo cuc nhanh, hien dang dung dau meta PvP nho combo ca van sat thuong.","portal|cong khong gian"},
    {"venom","Venom","Natural","A","ca PvP lan PvE","Sat thuong doc theo thoi gian rat kho chiu, manh trong khong gian hep, kho doi pho khi bi dinh combo lien tuc.","venom|doc"},
    {"trex","T-Rex","Beast","A","ca PvP lan PvE","Can chien manh, sat thuong cao, la lua chon thay the tot cho Kitsune.","t-rex|trex|khung long"},
    {"magma","Magma","Elemental","A","PvE (san quai bien)","Sat thuong cao khi thuc tinh, hien la trai gay sat thuong cao nhat cho viec san quai bien nguy hiem.","magma|dung nham"},
    {"gas","Gas","Elemental","B","PvP","Khong che dien rong nhung kho dung, cong dong van tranh cai ve do manh thuc te vi don kho trung nguoi choi gioi.","gas|khi doc"},
    {"tiger","Tiger","Beast","S","ca PvP lan PvE","Duoc lam lai (thay the vi tri cua Leopard cu) va manh hon han ban goc, nam trong nhom trai top hien tai.","tiger|ho"},
    {"yeti","Yeti","Beast","S","ca PvP lan PvE","Can chien bang gia manh, con co bien the hiem Fiend manh hon nua.","yeti|nguoi tuyet"},
    {"lightning","Lightning","Elemental","S","PvP","Truoc day ten la Rumble (doi ten khi lam lai). Toc do tan cong va co dong cao, co stun dien rong, gay ap luc lien tuc len doi thu.","lightning|set|sam set|rumble"},
    {"control","Control","Paramecia","A","PvP","Khong che manh, duoc ua chuong du doi hoi ky nang cao de land don.","control|dieu khien"},
    {"quake","Quake","Paramecia","A","ca PvP lan PvE","Day lui dien rong, gom quai va hit nhieu muc tieu tot de cay cap.","quake|dong dat"},
    {"string","String","Paramecia","A","PvP","Keo dai combo tot, ho tro tot cho loi danh can chien kieu extender.","string|day"},
    {"creation","Creation","Paramecia","A","ca PvP lan PvE","Ban lam lai cua Barrier, on dinh trong giao tranh va co kha nang phong thu tot.","creation|tao vat|barrier"},
    {"spirit","Spirit","Elemental","S","ca PvP lan PvE","Sat thuong cao, combo linh hoat, de ket hop voi fighting style can chien.","spirit|linh khi"},
    {"sound","Sound","Elemental","S","PvP","Co dong va ap luc tot trong cac tran PvP nho toc do ra don nhanh.","sound|am thanh"},
    {"ice","Ice","Elemental","B","ca PvP lan PvE","Sat thuong on, co ky nang truot bang giup di chuyen nhanh, de dung cho nguoi moi.","ice|bang"},
    {"light","Light","Elemental","B","di chuyen nhanh","Bay nhanh nhat game, rat tot cho First Sea va di chuyen duong dai, co mien nhiem nguyen to voi NPC yeu.","light|anh sang"},
    {"phoenix","Phoenix","Elemental","B","PvE","Tu hoi mau, do ben cao, giup giam thoi gian chet khi cay.","phoenix|phuong hoang"},
    {"blizzard","Blizzard","Elemental","B","PvP","Khong che dong bang dien rong kha tot trong combo.","blizzard|bao tuyet"},
    {"spider","Spider","Natural","B","PvP","Ky nang bay, combo tot khi dung dung cach de bat bai doi thu.","spider|nhen"},
    {"soul","Soul","Natural","A","PvP","Combo kho doan, thuong duoc dung lam trai phu de pha the doi thu.","soul|linh hon"},
    {"shadow","Shadow","Natural","B","ca PvP lan PvE","Co dong tot, phu hop loi choi theo nhom va ne don.","shadow|bong toi"},
    {"gravity","Gravity","Natural","B","PvP","Khong che keo va khoa muc tieu kha tot, hay dung de lock combo.","gravity|trong luc"},
    {"rubber","Rubber","Natural","D","PvP","Yeu ve sat thuong, kha de bi bat bai trong PvP hien tai so voi cac trai moi.","rubber|cao su"},
    {"sand","Sand","Natural","D","PvE","Tung manh nhung da bi giam suc manh, hien kha yeu so voi mat bang chung.","sand|cat"},
    {"spike","Spike","Natural","F","PvE","Sat thuong rat thap, chu yeu de choi cho vui hoac hoai niem.","spike|gai"},
    {"chop","Chop","Natural","F","PvE","Chi hieu qua khi doi dau nguoi dung kiem, con lai kha yeu.","chop|chem"},
    {"bomb","Bomb","Natural","D","PvE","Sat thuong thap, it duoc dung o giai doan cuoi game.","bomb|bom"},
    {"spin","Spin","Natural","F","PvE","Gan nhu khong con hieu qua o thoi diem hien tai.","spin|xoay"},
    {"rocket","Rocket","Natural","F","di chuyen","Chu yeu dung de bay nhanh giai doan dau, sat thuong rat thap.","rocket|ten lua"},
    {"spring","Spring","Natural","F","di chuyen","Ho tro nhay cao, gan nhu khong co gia tri chien dau.","spring|lo xo"},
    {"dark","Dark","Elemental","B","PvE","Tung manh nhung loi choi da hoi loi thoi so voi cac trai moi hon.","dark|bong den"},
    {"flame","Flame","Elemental","B","PvE","Sat thuong on cho giai doan dau va giua game, de tiep can.","flame|lua"},
    {"eagle","Eagle","Beast","C/B","di chuyen + PvE","Truoc day ten la Falcon, duoc lam lai va doi ten vao Update 26 (4/2025) voi chieu thuc moi va long vu no, gio co dong va huu ich hon han ban goc.","eagle|chim ung|falcon"},
    {"fiend","Fiend","Beast","S","ca PvP lan PvE","Bien the hiem cua Yeti (ra mat dau 2026), suc manh vao top S ngay khi ra mat va kho so huu hon trai thuong.","fiend"},
    {"diamond","Diamond","Elemental","B","PvE (phong thu)","Phong thu cuc cao nho giap kim cuong, sat thuong vua phai, phu hop loi choi tank chiu don. Cung la trai ma boss Diamond su dung.","diamond|kim cuong"},
    {"smoke","Smoke","Elemental","B","ca PvP lan PvE","Ky nang gay choang va che khuat tam nhin, ho tro combo mo dau kha tot. Co the bay (toc do cham).","smoke|khoi"},
    {"pain","Pain","Natural","A","PvP (rui ro cao, phan thuong cao)","Truoc day ten la Paw (doi ten vi ly do ban quyen). Co co che hoi sinh dac biet 'Last Stand' khi het mau, bien thanh dang buff toan dien tam thoi nhung khoa vu khi khac trong luc do.","pain|paw"},
    {"love","Love","Natural","B","PvP (gay roi)","Ky nang gay me/roi loan doi thu (Cupid's Zone, Heart Shot...), mang tinh ho tro va khong che nhieu hon la sat thuong thuan.","love|tinh yeu"},
    {"ghost","Ghost","Natural","B","cheo va kho chiu trong PvP","Co the tang hinh tam thoi va choang doi thu bang hieu ung so hai, kho bi phat hien khi mo dau combo.","ghost|ma"},
    {"revive","Revive","Natural","B","ho tro dong doi","Ho tro hoi sinh dong doi da nga trong mot so che do choi theo doi, mang tinh utility hon la sat thuong.","revive|hoi sinh"},
    {"blade","Blade","Natural","A","can chien voi kiem","Trieu hoi luoi kiem bay xung quanh nguoi choi, sat thuong tot khi ket hop build kiem.","blade|luoi kiem"},
}

local ISLANDS_RAW = {
    {"pirate_starter","Dao Cuop Bien (Xuat Phat)","Sea 1","Noi bat dau hanh trinh phe cuop bien, co NPC day ky nang co ban.","dao cuop bien|xuat phat cuop bien"},
    {"marine_starter","Dao Hai Quan (Xuat Phat)","Sea 1","Noi bat dau hanh trinh phe hai quan, phu hop lam nhiem vu som.","dao hai quan xuat phat"},
    {"middle_town","Thi Tran Trung Tam","Sea 1","Co Blox Fruit Dealer ban trai ac quy, la diem giao dich quan trong.","middle town|thi tran trung tam"},
    {"jungle","Rung Ram","Sea 1","Co quai vua suc de cay cap thap giai doan dau.","jungle|rung ram"},
    {"pirate_village","Lang Cuop Bien","Sea 1","Khu vuc cay cap va lam nhiem vu dau game.","pirate village|lang cuop bien"},
    {"desert","Sa Mac","Sea 1","Dia hinh rong, thich hop cay quai tam trung dau game.","desert|sa mac"},
    {"frozen_village","Lang Bang","Sea 1","Khu vuc bang gia voi quai phu hop cap do dau-giua game.","frozen village|lang bang"},
    {"marine_fortress","Phao Dai Hai Quan","Sea 1","Can cu hai quan voi nhieu linh canh gac.","marine fortress|phao dai hai quan"},
    {"skylands","Dao Troi","Sea 1","Khu vuc tren khong, can ky nang bay hoac trai ho tro di chuyen.","skylands|dao troi"},
    {"prison","Nha Tu","Sea 1","Noi giam giu tu nhan, co chuoi nhiem vu lien quan cot truyen.","prison|nha tu"},
    {"colosseum","Dau Truong","Sea 1","Noi to chuc cac tran dau PvE/PvP nho.","colosseum|dau truong"},
    {"magma_village","Lang Dung Nham","Sea 1","Khu vuc nui lua voi quai sat thuong lua.","magma village|lang dung nham"},
    {"underwater_city","Thanh Pho Duoi Nuoc","Sea 1","Thanh pho ngam duoi bien, co quest va NPC dac biet.","underwater city|thanh pho duoi nuoc"},
    {"fountain_city","Thanh Pho Suoi Nguon","Sea 1","Khu vuc cuoi First Sea voi quai cap cao hon.","fountain city|thanh pho suoi nguon"},
    {"upper_skylands","Dao Troi Thuong (Upper Skylands)","Sea 1","Khu vuc cao hon cua Skylands, tiep noi Dao Troi voi quai manh hon.","upper skylands|dao troi thuong"},
    {"kingdom_of_rose","Vuong Quoc Hoa Hong","Sea 2","Khu vuc mo dau Second Sea voi chuoi nhiem vu cot truyen lon.","kingdom of rose|vuong quoc hoa hong"},
    {"green_zone","Khu Vuc Xanh","Sea 2","Vung cay cap tam trung cua Second Sea.","green zone|khu vuc xanh"},
    {"graveyard","Dao Nghia Dia","Sea 2","Khu vuc u am voi quai he bong toi.","graveyard|nghia dia"},
    {"dark_arena","Dau Truong Bong Toi","Sea 2","Dau truong voi quai va boss he toi manh.","dark arena|dau truong bong toi"},
    {"snow_mountain","Nui Tuyet","Sea 2","Khu vuc bang tuyet voi boss Chief Summit.","snow mountain|nui tuyet"},
    {"cursed_ship","Tau Ma","Sea 2","Con tau bi nguyen rua voi quai ma cap cao va boss Cursed Captain.","cursed ship|tau ma"},
    {"forgotten_island","Dao Bi Lang Quen","Sea 2","Dao an voi quai manh va phan thuong hiem.","forgotten island|dao bi lang quen"},
    {"hot_and_cold","Nong Lanh (Hot and Cold)","Sea 2","Khu vuc dac biet ket hop dia hinh nui lua va bang gia trong cung mot dao.","hot and cold|nong lanh"},
    {"ice_castle","Lau Dai Bang (Ice Castle)","Sea 2","Lau dai bang gia, noi co NPC Thunder God lien quan toi trai Lightning (Rumble).","ice castle|lau dai bang"},
    {"remote_island","Dao Heo Lanh (Remote Island)","Sea 2","Hon dao xa xoi it nguoi ghe qua, phu hop cay cap yen tinh.","remote island|dao heo lanh"},
    {"port_town","Thi Tran Cang","Sea 3","Diem khoi dau cua Third Sea, noi Dealer trai xuat hien.","port town|thi tran cang"},
    {"hydra_island","Dao Hydra","Sea 3","Dao co quai ran nhieu dau cap cao.","hydra island|dao hydra"},
    {"great_tree","Dai Thu","Sea 3","Khu vuc rung cay khong lo voi quest dac biet.","great tree|dai thu"},
    {"floating_turtle","Rua Noi (Floating Turtle)","Sea 3","Hon dao dac biet nam tren lung mot con rua khong lo, co khu vuc cay cap rieng biet.","floating turtle|rua noi"},
    {"haunted_castle","Lau Dai Ma Am","Sea 3","Lau dai voi quai ma va boss cap cao Third Sea.","haunted castle|lau dai ma am"},
    {"castle_on_the_sea","Lau Dai Tren Bien (Castle on the Sea)","Sea 3","Phao dai noi giua bien, noi dien ra su kien phong thu truoc cuop bien de co co hoi nhan trai ac quy.","castle on the sea|lau dai tren bien"},
    {"sea_of_treats","Bien Banh Keo (Sea of Treats)","Sea 3","Khu vuc chu de banh keo gan lien voi cot truyen va Raid Dough.","sea of treats|bien banh keo"},
    {"tiki_outpost","Tien Don Tiki (Tiki Outpost)","Sea 3","Noi tru an cua boss Tyrant of the Skies, co ti le rot trai Eagle.","tiki outpost|tien don tiki"},
}

local BOSSES_RAW = {
    {"dough_king","King Dough","Boss giu chia khoa mo Raid Dough, can chuan bi mau cao va ne don tot.","king dough"},
    {"don_swan","Don Swan","Boss dung trai Spider voi bo ky nang nang cap.","don swan"},
    {"saber_expert","Saber Expert","Boss kiem si manh xuat hien o khu vuc Second Sea.","saber expert"},
    {"cake_prince","Cake Prince","Boss o Third Sea voi don tan cong dien rong.","cake prince"},
    {"tide_keeper","Tide Keeper","Boss Third Sea voi sat thuong lien quan toi nuoc kha cao.","tide keeper"},
    {"chief_summit","Chief Summit","Boss tran giu khu vuc nui tuyet Second Sea.","chief summit"},
    {"fajita","Fajita","NPC/boss quan trong gan lien voi cot truyen toc V4.","fajita"},
    {"diamond_boss","Diamond","Boss su dung trai Diamond, phong thu rat cao.","diamond boss"},
    {"smoke_boss","Smoke","Boss o First Sea su dung trai Smoke.","smoke boss"},
    {"swan_pirates","Swan Pirates","Bang cuop bien canh gac khu vuc Kingdom of Rose.","swan pirates"},
    {"tyrant_of_skies","Tyrant of the Skies","Boss bay hiem, co ti le nho rot trai Eagle.","tyrant of the skies|bao chua bau troi"},
    {"leviathan","Leviathan","Quai bien khong lo o Sea 3, nen di theo nhom dong nguoi.","leviathan"},
    {"terrorshark","Terrorshark","Ca map khong lo xuat hien o vung bien nguy hiem.","terrorshark"},
    {"grand_brigade","Grand Brigade","Doi cuop bien trong Ship Raid, co ti le rot trai ngau nhien.","grand brigade"},
    {"factory_boss","Boss Nha May (Factory)","Can gay sat thuong cao nhat trong raid de nhan trai thuong.","factory boss|boss nha may"},
    {"death_king","Death King","Boss su kien Halloween, co the rot trai vat ly hiem.","death king"},
    {"nautical_captain","Nautical Captain","Boss can chien manh o Third Sea.","nautical captain"},
    {"midnight_general","Midnight General","Boss o Dark Arena voi ky nang bong toi manh.","midnight general"},
    {"swordsman_of_rose","Swordsman of Rose","Boss kiem si giu chia khoa vao khu vuc noi thanh Kingdom of Rose.","swordsman of rose"},
    {"cursed_captain","Cursed Captain","Boss chi huy tren Tau Ma (Cursed Ship), thuong di cung dam thuy thu nguyen rua, sat thuong cao va co ky nang khong che tam gan.","cursed captain|thuyen truong nguyen rua"},
    {"agony_boss","Agony","Boss dau tien su dung phien ban lam lai cua trai Pain, thua huong co che hoi sinh 'Last Stand' nen co the bat ngo hoi lai va manh hon o giai doan cuoi tran.","agony"},
}

local WEAPONS_RAW = {
    {"tushita","Tushita","Kiem huyen thoai pho bien, sat thuong va tam danh tot cho build kiem.","tushita"},
    {"saddi","Saddi","Vu khi manh cho build kiem, doi hoi thao tac combo chuan.","saddi"},
    {"yama","Yama","Vu khi ba luoi noi tieng voi sat thuong cao khi combo dung cach.","yama"},
    {"shark_saw","Shark Saw","Vu khi phu hop cho build can chien/sung ket hop.","shark saw"},
    {"soul_cane","Soul Cane","Vu khi ho tro tot cho cac build combo dai hoi.","soul cane"},
    {"dark_blade","Dark Blade","Kiem hiem voi hieu ung bong toi dac trung.","dark blade"},
    {"cursed_dual_katana","Cursed Dual Katana","Song kiem nguyen, toc do ra don nhanh.","cursed dual katana"},
    {"pole_v2","Pole V2","Vu khi thuc tinh manh cho build Superhuman.","pole v2|pole"},
    {"rengoku","Rengoku","Vu khi sat thuong lua manh cho cac build kiem nang cao.","rengoku"},
    {"dragon_trident","Dragon Trident","Dinh ba rong, phu hop loi danh tam trung.","dragon trident"},
    {"chaser","Chaser","Vu khi co kha nang truy duoi muc tieu tot trong PvP.","chaser"},
    {"hallow_scythe","Hallow Scythe","Luoi hai voi hieu ung dien rong dac trung.","hallow scythe"},
    {"acidum_rifle","Acidum Rifle","Sung gay sat thuong an mon theo thoi gian.","acidum rifle"},
    {"serpent_bow","Serpent Bow","Cung tam xa phu hop loi danh giu khoang cach.","serpent bow"},
    {"falcon_gun","Falcon Gun","Sung toc do ban nhanh, ho tro tot cho build sung.","falcon gun"},
    {"true_triple_katana","True Triple Katana","Bien the nang cap cua Triple Katana, sat thuong va toc do vung chem deu cao hon.","true triple katana|triple katana"},
    {"buddy_sword","Buddy Sword","Kiem pho thong de kiem giai doan dau, danh nhanh nhung sat thuong khong cao.","buddy sword"},
    {"combat_knife","Combat Knife","Dao gam toc do ra don rat nhanh, phu hop combo mo man.","combat knife"},
    {"cutlass","Cutlass","Kiem co dien de kiem, thuong dung lam vu khi tam thoi giai doan dau.","cutlass"},
    {"bisento","Bisento","Vu khi tam danh rong, phu hop gom nhieu muc tieu cung luc.","bisento"},
    {"iron_mace","Iron Mace","Chuy sat sat thuong choang tot, huu ich de ngat combo doi thu.","iron mace"},
    {"death_scythe","Death Scythe","Luoi hai tu than, hieu ung hinh anh dac trung va sat thuong on dinh.","death scythe"},
    {"ice_blade","Ice Blade","Kiem bang gia co kha nang lam cham doi thu khi trung don.","ice blade"},
}

local FIGHTING_STYLES_RAW = {
    {"superhuman","Superhuman","Fighting style co ban de nang cap som, thao tac don gian, phu hop nguoi moi lam quen combo tay khong.","superhuman|sieu nhan"},
    {"electric_claw","Electric Claw","Toc do ra don rat nhanh voi hieu ung dien giat, tot de gom combo lien tuc.","electric claw|mong vuot dien"},
    {"dragon_talon","Dragon Talon","Cac don da lien hoan manh, tot cho loi choi can chien don gian ma hieu qua.","dragon talon|mong rong"},
    {"sharkman_karate","Sharkman Karate","Sat thuong tang manh khi o duoi nuoc, la lua chon tot cho nguoi choi thich chien dau tren bien.","sharkman karate|vo ca map"},
    {"death_step","Death Step","Ky nang dich chuyen ne don rat manh, gan nhu bat buoc de ne cac don AoE nguy hiem cua boss/raid.","death step|buoc chan tu than"},
    {"godhuman","Godhuman","Fighting style cuoi cung, sat thuong cao va combo linh hoat, gan nhu tieu chuan cho nguoi choi late-game.","godhuman|con nguoi than thanh"},
    {"dragon_claw","Dragon Claw","Ban nang cap cua Dragon Talon, tam danh va sat thuong lien hoan tot hon.","dragon claw|vuot rong"},
    {"cyborg","Cyborg (V2)","Fighting style co kha nang bien hinh cyborg, tang chi so trong thoi gian ngan, ho tro tot cho farm va PvP.","cyborg|nguoi may"},
    {"superman_run","Superhuman Sprint","Ky nang chay/lao nhanh giup rut ngan khoang cach voi doi thu hoac muc tieu farm.","superhuman sprint|chay nhanh"},
}

-- ================= ENGLISH NOTES (short summaries, one per entry id) =================
local EN_FRUIT_NOTES = {
    dragon="Very mobile, wide AoE damage, one of the strongest and most expensive fruits.",
    kitsune="Fast transformation, strong AoE combos, top-tier for bossing and PvP.",
    leopard="Fastest transformation in the game, wide combo range, great for grinding.",
    mammoth="Strong melee with wide crowd control, very well-rounded.",
    buddha="Huge attack range when giant-formed and reduced damage taken, easiest fruit to grind with.",
    dough="After awakening (V2), extremely strong crowd-control combos in PvP.",
    portal="Instant teleport skills for dodging and starting combos, top of current PvP meta.",
    venom="Damage-over-time poison, hard to deal with in close quarters.",
    trex="Strong melee damage, a good alternative to Kitsune.",
    magma="High damage after awakening, best for hunting dangerous sea beasts.",
    gas="Wide crowd control but hard to land on skilled players.",
    tiger="Reworked and stronger than its old version (Leopard), currently top tier.",
    yeti="Strong ice melee, has a rare Fiend variant that's even stronger.",
    lightning="Formerly Rumble. High attack speed and mobility with wide stuns.",
    control="Strong crowd control, requires high skill to land hits.",
    quake="Wide knockback, good for grouping mobs and grinding.",
    string="Great combo extension for melee playstyles.",
    creation="Reworked Barrier, stable in fights with solid defense.",
    spirit="High damage, flexible combos, pairs well with melee fighting styles.",
    sound="Great mobility and pressure in PvP thanks to fast attacks.",
    ice="Decent damage, ice-skate mobility skill, beginner friendly.",
    light="Fastest flight in the game, great for First Sea and long travel.",
    phoenix="Self-healing, high durability, less downtime while grinding.",
    blizzard="Solid freeze crowd-control in combos.",
    spider="Trap-based skills, good combos when used correctly.",
    soul="Unpredictable combos, often used as a secondary fruit to break stances.",
    shadow="Good mobility, suits group play and dodging.",
    gravity="Decent pull/lock skills, often used to lock combos.",
    rubber="Weak damage, easy to counter compared to newer fruits.",
    sand="Was strong before, now weak after nerfs.",
    spike="Very low damage, mostly for fun or nostalgia.",
    chop="Only effective vs sword users, otherwise weak.",
    bomb="Low damage, rarely used late game.",
    spin="Barely effective nowadays.",
    rocket="Mostly used for early mobility, very low damage.",
    spring="High jump utility, almost no combat value.",
    dark="Was strong before, playstyle a bit outdated now.",
    flame="Decent damage for early-mid game, easy to pick up.",
    eagle="Formerly Falcon, reworked with new moves, now much more mobile and useful.",
    fiend="Rare Yeti variant, top S-tier as soon as it releases, harder to obtain.",
    diamond="Very high defense from diamond armor, moderate damage, tanky playstyle.",
    smoke="Stun and vision-blocking skills, good combo opener, can fly slowly.",
    pain="Formerly Paw. Has a 'Last Stand' revive mechanic when low HP.",
    love="Confusion/CC skills (Cupid's Zone, Heart Shot...), more support than raw damage.",
    ghost="Temporary invisibility and fear-based stuns, sneaky combo starter.",
    revive="Team-support utility to revive fallen allies in certain modes.",
    blade="Summons flying blades around you, good damage with sword builds.",
}
local EN_ROLE_MAP = {
    ["cả PvP lẫn PvE"]="both PvP and PvE", ["ca PvP lan PvE"]="both PvP and PvE",
    ["PvP"]="PvP", ["PvE"]="PvE", ["PvE (farm)"]="PvE grinding", ["PvE (cày cấp)"]="PvE leveling",
    ["PvE (cay cap)"]="PvE leveling", ["PvE (săn quái biển)"]="hunting sea beasts",
    ["PvE (san quai bien)"]="hunting sea beasts", ["di chuyển nhanh"]="fast travel",
    ["di chuyen nhanh"]="fast travel", ["PvP (rủi ro cao, phần thưởng cao)"]="high-risk high-reward PvP",
    ["PvP (rui ro cao, phan thuong cao)"]="high-risk high-reward PvP",
    ["PvP (gây rối)"]="PvP disruption", ["PvP (gay roi)"]="PvP disruption",
    ["PvE (phòng thủ)"]="tanky PvE", ["PvE (phong thu)"]="tanky PvE",
    ["cheo va kho chiu trong PvP"]="sneaky, annoying in PvP", ["ho tro dong doi"]="team support",
    ["can chien voi kiem"]="sword melee", ["di chuyen"]="mobility/travel",
    ["di chuyen + PvE"]="mobility and PvE",
}

local EN_ISLAND_NOTES = {
    pirate_starter="Pirate faction starting island with basic skill trainers.",
    marine_starter="Marine faction starting island, good for early quests.",
    middle_town="Home of the Blox Fruit Dealer, main trading hub.",
    jungle="Weak mobs suited for very early grinding.",
    pirate_village="Early-game grinding and quest area.",
    desert="Large terrain, decent for early-mid mobs.",
    frozen_village="Icy area with early-mid level mobs.",
    marine_fortress="Marine base guarded by many soldiers.",
    skylands="Aerial area, needs flight skill or fruit.",
    prison="Prison island with a story-related quest chain.",
    colosseum="Small PvE/PvP arena battles.",
    magma_village="Volcanic area with fire-damage mobs.",
    underwater_city="Underwater city with special quests and NPCs.",
    fountain_city="End of First Sea, higher level mobs.",
    upper_skylands="Higher continuation of Skylands with stronger mobs.",
    kingdom_of_rose="Opens Second Sea with a big story questline.",
    green_zone="Mid-level Second Sea grinding area.",
    graveyard="Dark-themed island with shadow mobs.",
    dark_arena="Arena with strong dark-element mobs and bosses.",
    snow_mountain="Snowy area guarded by boss Chief Summit.",
    cursed_ship="Cursed ship with high-level ghost mobs and Cursed Captain.",
    forgotten_island="Hidden island with strong mobs and rare drops.",
    hot_and_cold="Special island combining volcanic and icy terrain.",
    ice_castle="Ice castle, home of the Thunder God NPC tied to Lightning.",
    remote_island="Quiet, out-of-the-way grinding spot.",
    port_town="Third Sea starting town, Fruit Dealer spawns here.",
    hydra_island="Island with high-level multi-headed serpent mobs.",
    great_tree="Giant tree area with a special quest.",
    floating_turtle="Special island on the back of a giant turtle.",
    haunted_castle="Haunted castle with ghost mobs and a high-level Third Sea boss.",
    castle_on_the_sea="Floating fortress with a pirate-defense event for fruit chances.",
    sea_of_treats="Candy-themed area tied to the Dough raid storyline.",
    tiki_outpost="Hideout of boss Tyrant of the Skies, drops Eagle fruit rarely.",
}

local EN_BOSS_NOTES = {
    dough_king="Holds the key to the Dough raid, bring high HP and dodge well.",
    don_swan="Uses Spider fruit with an upgraded moveset.",
    saber_expert="Strong swordsman boss found in Second Sea.",
    cake_prince="Third Sea boss with wide-area attacks.",
    tide_keeper="Third Sea boss with high water-based damage.",
    chief_summit="Guards the snow mountain area in Second Sea.",
    fajita="Important NPC/boss tied to the V4 race storyline.",
    diamond_boss="Uses the Diamond fruit, very high defense.",
    smoke_boss="First Sea boss using the Smoke fruit.",
    swan_pirates="Pirate crew guarding Kingdom of Rose.",
    tyrant_of_skies="Rare flying boss, small chance to drop Eagle fruit.",
    leviathan="Giant sea monster in Sea 3, fight with a group.",
    terrorshark="Giant shark found in dangerous waters.",
    grand_brigade="Pirate crew in Ship Raid, random fruit drop chance.",
    factory_boss="Deal the most damage in the raid to earn a fruit reward.",
    death_king="Halloween event boss, chance to drop a rare physical fruit.",
    nautical_captain="Strong melee boss in Third Sea.",
    midnight_general="Dark Arena boss with strong shadow skills.",
    swordsman_of_rose="Swordsman boss guarding inner Kingdom of Rose.",
    cursed_captain="Cursed Ship's captain, high damage with close-range CC.",
    agony_boss="First boss using the reworked Pain fruit, can revive via 'Last Stand'.",
}

local EN_WEAPON_NOTES = {
    tushita="Popular legendary sword, good damage and reach for sword builds.",
    saddi="Strong sword-build weapon, needs precise combo execution.",
    yama="Famous three-blade weapon with high combo damage.",
    shark_saw="Good fit for melee/gun hybrid builds.",
    soul_cane="Great support weapon for long combo chains.",
    dark_blade="Rare sword with a signature dark effect.",
    cursed_dual_katana="Dual katana with very fast attack speed.",
    pole_v2="Strong awakened weapon for Superhuman builds.",
    rengoku="Powerful fire-damage weapon for advanced sword builds.",
    dragon_trident="Trident suited for mid-range combat.",
    chaser="Good target-tracking weapon in PvP.",
    hallow_scythe="Scythe with a signature wide-area effect.",
    acidum_rifle="Gun that deals acid damage over time.",
    serpent_bow="Long-range bow for keep-away playstyles.",
    falcon_gun="Fast-firing gun, good for gun builds.",
    true_triple_katana="Upgraded Triple Katana, higher damage and swing speed.",
    buddy_sword="Common early sword, fast but low damage.",
    combat_knife="Very fast dagger, good for opening combos.",
    cutlass="Classic starter sword, usually temporary early gear.",
    bisento="Wide-reach weapon, good for hitting multiple targets.",
    iron_mace="Mace with strong stun, good for interrupting combos.",
    death_scythe="Reaper scythe with a signature look and steady damage.",
    ice_blade="Ice sword that can slow enemies on hit.",
}

local EN_STYLE_NOTES = {
    superhuman="Basic fighting style, easy to level early, simple bare-hand combos.",
    electric_claw="Very fast attacks with an electric shock effect, great for chain combos.",
    dragon_talon="Strong combo chains, simple yet effective melee playstyle.",
    sharkman_karate="Bonus damage underwater, great for players who fight at sea.",
    death_step="Powerful dodge/teleport skill, almost required to avoid AoE boss attacks.",
    godhuman="Final fighting style, high damage and flexible combos, late-game standard.",
    dragon_claw="Upgraded Dragon Talon with better range and combo damage.",
    cyborg="Cyborg transformation boosts stats briefly, good for farming and PvP.",
    superman_run="Sprint/dash skill to quickly close distance to a target.",
}

local ENTRY_INDEX = {}
local ALL_ALIAS_TOKENS = {}

local function registerEntry(entry)
    ENTRY_DB[#ENTRY_DB+1] = entry
    ENTRY_INDEX[entry.id] = entry
    for _, alias in ipairs(entry.aliases) do
        for _, word in ipairs(tokenize(alias)) do
            ALL_ALIAS_TOKENS[word] = ALL_ALIAS_TOKENS[word] or {}
            table.insert(ALL_ALIAS_TOKENS[word], entry.id)
        end
    end
end

local function buildFruitEntry(row)
    local id, name, kind, tier, role, note, aliasStr = table.unpack(row)
    local aliases = splitPipe(aliasStr)
    local mood = tierMood(tier)
    local templates = {
        { patterns = {"la gi","loai gi","la trai gi"},
          build = function() return string.format("<b>[%s]:</b> Day la trai he %s, thuong duoc xep %s tier. %s %s", name, kind, tier, note, emo(mood)) end },
        { patterns = {"manh khong","co manh khong","danh gia"},
          build = function() return string.format("<b>[%s - DANH GIA]:</b> Xep hang %s tier, phu hop %s. %s %s", name, tier, role, note, emo(mood)) end },
        { patterns = {"gia bao nhieu","gia the nao","dat khong"},
          build = function() return string.format("<b>[%s - GIA]:</b> Gia dao dong theo do hiem cua fruit. Ban nen kiem tra Blox Fruit Dealer hoac cho trade de biet gia chuan o phien ban hien tai nhe %s", name, emo("cute")) end },
        { patterns = {"thuc tinh","awaken","cach thuc tinh"},
          build = function() return string.format("<b>[%s - THUC TINH]:</b> Can tim NPC thuc tinh tuong ung va hoan thanh nhiem vu/nguyen lieu rieng cho trai nay de tang sat thuong va mo khoa hieu ung ky nang. %s", name, emo("cute")) end },
        { patterns = {"hop loi choi nao","choi the nao","pve hay pvp"},
          build = function() return string.format("<b>[%s - LOI CHOI]:</b> Phu hop nhat cho %s. %s %s", name, role, note, emo(mood)) end },
        { patterns = {"cay co tot khong","farm co tot khong","len level"},
          build = function() return string.format("<b>[%s - CAY CAP]:</b> %s %s", name, note, emo(mood)) end },
        { patterns = {"nen mua khong","co nen lay khong","co dang khong"},
          build = function() return string.format("<b>[%s - CO NEN LAY]:</b> Neu ban uu tien %s thi trai nay dang can nhac, hien dang o muc %s tier. %s", name, role, tier, emo(mood)) end },
        { patterns = {"kiem o dau","lay o dau","mua o dau"},
          build = function() return string.format("<b>[%s - CACH LAY]:</b> Mua tu Blox Fruit Dealer (neu con hang), quay Gacha, nhat trai roi ngau nhien tren ban do, hoac trade voi nguoi choi khac. %s", name, emo("cute")) end },
        { patterns = {"khac che","bi khac che","yeu diem","diem yeu"},
          build = function() return string.format("<b>[%s - DIEM YEU]:</b> Nhu hau het cac trai khac, %s de bi khac che boi doi thu co mobility cao hon hoac co combo pha the (stun/knockback) truoc khi ban kip ra don. Nen luyen phan xa ne/block de bu lai. %s", name, string.lower(name), emo("neutral")) end },
        { patterns = {"build gi","ket hop","fighting style nao","di chung voi gi"},
          build = function() return string.format("<b>[%s - GOI Y BUILD]:</b> Nen ket hop cung mot fighting style can chien manh (nhu Electric Claw, Sharkman Karate hoac Godhuman) cung vu khi co combo tot de toi uu sat thuong lien hoan. %s", name, emo("hype")) end },
    }
    registerEntry({ id = id, aliases = aliases, templates = templates, kind = "fruit", subkind = kind, tier = tier, role = role, note = note, name = name, en_note = EN_FRUIT_NOTES[id], en_role = EN_ROLE_MAP[role] or role })
end
for _, row in ipairs(FRUITS_RAW) do buildFruitEntry(row) end

local function buildIslandEntry(row)
    local id, name, sea, note, aliasStr = table.unpack(row)
    local aliases = splitPipe(aliasStr)
    local templates = {
        { patterns = {"o dau","vi tri","nam o dau"},
          build = function() return string.format("<b>[%s]:</b> Thuoc khu vuc %s. Dung la ban hoac thuyen de di chuyen toi day nhe %s", name, sea, emo("cute")) end },
        { patterns = {"co gi","lam gi o day","co gi hay"},
          build = function() return string.format("<b>[%s]:</b> %s %s", name, note, emo("neutral")) end },
        { patterns = {"quai manh khong","nguy hiem khong"},
          build = function() return string.format("<b>[%s - QUAI]:</b> Do kho tuy khu vuc trong %s, nen kiem tra level khuyen nghi truoc khi vao cay de tranh gay doi hinh %s", name, sea, emo("funny")) end },
        { patterns = {"co boss khong","boss gi","co quest khong"},
          build = function() return string.format("<b>[%s - BOSS/QUEST]:</b> Nhieu dao trong %s co NPC hoac boss rieng gan voi cot truyen. Hoi minh ten boss cu the de biet them chi tiet nhe! %s", name, sea, emo("hype")) end },
    }
    registerEntry({ id = id, aliases = aliases, templates = templates, kind = "island", name = name, sea = sea, en_note = EN_ISLAND_NOTES[id] })
end
for _, row in ipairs(ISLANDS_RAW) do buildIslandEntry(row) end

local function buildBossEntry(row)
    local id, name, note, aliasStr = table.unpack(row)
    local aliases = splitPipe(aliasStr)
    local templates = {
        { patterns = {"danh the nao","cach danh","chien thuat"},
          build = function() return string.format("<b>[%s]:</b> %s Nen chuan bi mau cao va luyen ne don (dash/block) truoc khi danh truc dien. %s", name, note, emo("hype")) end },
        { patterns = {"roi gi","phan thuong","cho gi"},
          build = function() return string.format("<b>[%s - PHAN THUONG]:</b> Thuong rot tien trong game, Fragment, hoac co ti le nho rot vat pham/trai hiem tuy do hiem cua boss. %s", name, emo("cute")) end },
        { patterns = {"o dau","tim o dau","xuat hien o dau"},
          build = function() return string.format("<b>[%s - VI TRI]:</b> Xuat hien tai khu vuc gan lien voi cot truyen hoac nhiem vu lien quan toi boss nay, thuong co chi dan quest tren ban do. %s", name, emo("neutral")) end },
        { patterns = {"manh khong","kho khong","de danh khong"},
          build = function() return string.format("<b>[%s - DO KHO]:</b> %s Khong nen danh solo neu level con thap. %s", name, note, emo("funny")) end },
    }
    registerEntry({ id = id, aliases = aliases, templates = templates, kind = "boss", name = name, en_note = EN_BOSS_NOTES[id] })
end
for _, row in ipairs(BOSSES_RAW) do buildBossEntry(row) end

local function buildWeaponEntry(row)
    local id, name, note, aliasStr = table.unpack(row)
    local aliases = splitPipe(aliasStr)
    local templates = {
        { patterns = {"manh khong","dang dung khong","tot khong"},
          build = function() return string.format("<b>[%s]:</b> %s %s", name, note, emo("hype")) end },
        { patterns = {"lay o dau","kiem o dau","farm o dau"},
          build = function() return string.format("<b>[%s - CACH LAY]:</b> Thuong roi tu boss, mua o NPC dac biet, hoac che tao tu nguyen lieu hiem tuy vu khi. %s", name, emo("cute")) end },
        { patterns = {"gia bao nhieu","dat khong"},
          build = function() return string.format("<b>[%s - GIA]:</b> Gia tri tren thi truong trade bien dong kha nhieu, nen tham khao cong dong truoc khi mua ban. %s", name, emo("neutral")) end },
    }
    registerEntry({ id = id, aliases = aliases, templates = templates, kind = "weapon", name = name, en_note = EN_WEAPON_NOTES[id] })
end
for _, row in ipairs(WEAPONS_RAW) do buildWeaponEntry(row) end

local function buildFightingStyleEntry(row)
    local id, name, note, aliasStr = table.unpack(row)
    local aliases = splitPipe(aliasStr)
    local templates = {
        { patterns = {"manh khong","dang tap khong","tot khong"},
          build = function() return string.format("<b>[%s]:</b> %s %s", name, note, emo("hype")) end },
        { patterns = {"hoc o dau","lay o dau","train o dau"},
          build = function() return string.format("<b>[%s - CACH HOC]:</b> Tim NPC day fighting style tuong ung (thuong o cac dao chinh cua tung Sea) va hoan thanh dieu kien/nhiem vu di kem. %s", name, emo("cute")) end },
        { patterns = {"combo the nao","danh the nao","ket hop gi"},
          build = function() return string.format("<b>[%s - COMBO]:</b> Nen luyen tap thu tu don co ban truoc, sau do ket hop voi mot vu khi hoac trai co dong de noi combo muot hon. %s", name, emo("neutral")) end },
    }
    registerEntry({ id = id, aliases = aliases, templates = templates, kind = "style", name = name, en_note = EN_STYLE_NOTES[id] })
end
for _, row in ipairs(FIGHTING_STYLES_RAW) do buildFightingStyleEntry(row) end

registerEntry({ id = "v4", aliases = {"toc v4","v4","tong tien boi"}, kind = "topic", templates = {
    { patterns = {}, build = function() return "<b>[CAM NANG TOC V4]:</b> Yeu cau max level, ha boss Rip_Indra va lam thu thach Trial tai Den Tho Thoi Gian. Hoi tiep 'o dau' hoac 'phan thuong' nhe! 😁" end },
    { patterns = {"o dau","dao nao"}, build = function() return "<b>[TOC V4 - VI TRI]:</b> Canh dem trang tron o Sea 3, ra bien tim dao Huyen Bi (Mirage Island), bat Haki quan sat nhin len mat trang de tim luong sang phan chieu roi nhat banh rang an quanh dao. 🥹" end },
    { patterns = {"phan thuong","duoc gi"}, build = function() return "<b>[TOC V4 - PHAN THUONG]:</b> Tang manh chi so can chien, sung va trai ac quy, cung bo trang phuc V4 doc quyen theo chung toc. 🥳" end },
}})

registerEntry({ id = "rip_indra", aliases = {"rip indra","rip_indra","boss den v4"}, kind = "topic", templates = {
    { patterns = {}, build = function() return "<b>[BOSS RIP_INDRA]:</b> Boss cap cao dung de mo toc V4, co don AoE set dien rong. Nen mang mau cao va ne theo huong chi bao truoc khi no ra don. 🥳" end },
}})

registerEntry({ id = "code", aliases = {"code","ma code"}, kind = "topic", templates = {
    { patterns = {}, build = function() return "<b>[MA X2 EXP]:</b> Code hay thay doi va het han lien tuc, minh khuyen ban kiem tra kenh thong bao chinh thuc hoac Discord cua game de lay code moi nhat con hieu luc, tranh dung code cu da het han! 🥳" end },
}})

registerEntry({ id = "sea_event", aliases = {"sea event","leviathan event","boss bien"}, kind = "topic", templates = {
    { patterns = {}, build = function() return "<b>[BOSS BIEN]:</b> Lai thuyen ra vung nguy hiem cap 5-6 tai Sea 3 ban dem de san Terrorshark hoac tim Leviathan. Nen di theo team dong nguoi vi mau boss rat trau. 😁" end },
}})

registerEntry({ id = "tier_list", aliases = {"tier list","trai nao manh nhat","top trai"}, kind = "topic", templates = {
    { patterns = {}, build = function() return "<b>[TIER LIST TONG QUAN 2026]:</b> Nhom manh nhat hien tai (T0/S) thuong gom Portal, Kitsune, Dragon, Buddha, kem theo Leopard, Mammoth, Tiger, Yeti, Fiend o nhom sat ngay duoi. Go ten mot trai cu the hoac 'so sanh X va Y' de minh phan tich ky hon nhe! 🥳" end },
}})

registerEntry({ id = "reroll", aliases = {"doi trai","reroll","chuyen trai"}, kind = "topic", templates = {
    { patterns = {}, build = function() return "<b>[DOI/REROLL TRAI]:</b> Dung NPC Trader gan khu vuc trung tam de doi trai ac quy, thuong ton tien trong game hoac Fragment tuy loai trai. 😁" end },
}})

registerEntry({ id = "greeting", aliases = {"chao","hello","hi","alo"}, kind = "topic", templates = {
    { patterns = {}, build = function() return "Chao ban! Minh la tro ly offline hon 800 to hop du lieu ve Blox Fruits 🥰 Hoi minh ve trai, dao, boss, vu khi, fighting style, code, hoac thu go 'so sanh dragon va kitsune' nhe!" end },
}})

registerEntry({ id = "thanks", aliases = {"cam on","thank you","thanks"}, kind = "topic", templates = {
    { patterns = {}, build = function() return "Khong co gi dau, chuc ban cay trai vui ve nha! 🥰 Can hoi gi them cu go tiep nhe." end },
}})

registerEntry({ id = "help", aliases = {"huong dan","help","cach dung","cach hoi","co the hoi gi"}, kind = "topic", templates = {
    { patterns = {}, build = function() return "<b>[HUONG DAN NHANH]:</b> Ban co the nhan tin tu nhien, viet tat, khong dau deu duoc, vi du:\n• 'buddha manh khong', 'kitsune build gi'\n• 'so sanh dragon va kitsune' (so sanh 2 trai)\n• 'tushita vs saddi cai nao ngon' (hoi gop nhieu muc)\n• 'danh sach trai / dao / boss / vu khi / fighting style'\n• 'toc v4', 'code', 'rip indra'\nCu nhan tin thoai mai nhu nhan tin binh thuong, minh se co gang hieu nhe! 🥳" end },
}})

local function buildListText(rawList, header)
    local names = {}
    for _, row in ipairs(rawList) do names[#names+1] = row[2] end
    return string.format("<b>[%s]:</b> %s %s", header, table.concat(names, ", "), emo("cute"))
end

local function findFruitRowById(id)
    for _, row in ipairs(FRUITS_RAW) do
        if row[1] == id then return row end
    end
    return nil
end

local function findFruitIdInText(text)
    local bestId, bestScore = nil, 0
    for _, entry in ipairs(ENTRY_DB) do
        if entry.kind == "fruit" then
            local score = countMatches(text, entry.aliases)
            if score > bestScore then bestId, bestScore = entry.id, score end
        end
    end
    return bestId
end

local function tryCompare(text, lang)
    if not (string.find(text, "so sanh", 1, true) or string.find(text, " vs ", 1, true) or string.find(text, "hay hon", 1, true) or string.find(text, "compare", 1, true)) then
        return nil
    end
    local firstHalf, secondHalf = text, text
    local splitPos = string.find(text, " va ") or string.find(text, " vs ") or string.find(text, " hay ") or string.find(text, " and ")
    if splitPos then
        firstHalf = string.sub(text, 1, splitPos)
        secondHalf = string.sub(text, splitPos)
    end
    local idA = findFruitIdInText(firstHalf)
    local idB = findFruitIdInText(secondHalf)
    if idA and idB and idA ~= idB then
        local rowA, rowB = findFruitRowById(idA), findFruitRowById(idB)
        local entryA, entryB = ENTRY_INDEX[idA], ENTRY_INDEX[idB]
        if rowA and rowB then
            if lang == "en" then
                return string.format(
                    "<b>[COMPARE %s vs %s]:</b>\n• %s: %s tier, best for %s. %s\n• %s: %s tier, best for %s. %s\n=> Both are strong in their own way, pick based on whether you prioritize PvP or PvE! %s",
                    rowA[2], rowB[2],
                    rowA[2], rowA[4], entryA.en_role or rowA[5], entryA.en_note or "",
                    rowB[2], rowB[4], entryB.en_role or rowB[5], entryB.en_note or "",
                    emo("hype")
                )
            end
            return string.format(
                "<b>[SO SANH %s vs %s]:</b>\n• %s: %s tier, phu hop %s. %s\n• %s: %s tier, phu hop %s. %s\n=> Ca hai deu manh theo cach rieng, chon tuy theo ban uu tien PvP hay PvE nhe! %s",
                rowA[2], rowB[2],
                rowA[2], rowA[4], rowA[5], rowA[6],
                rowB[2], rowB[4], rowB[5], rowB[6],
                emo("hype")
            )
        end
    end
    return nil
end

local currentContext = nil

local function findFreshEntry(text)
    local best, bestScore = nil, 0
    for _, entry in ipairs(ENTRY_DB) do
        local score = countMatches(text, entry.aliases)
        if score > bestScore then
            best, bestScore = entry, score
        end
    end
    return best
end

-- Phat hien nhieu chu de trong cung mot cau (vd: "buddha va dragon manh khong",
-- "cho hoi tushita, saddi, yama cai nao ngon") de tra loi gop mot luot thay vi
-- chi bat dung 1 tu khoa dau tien
local function findMultipleEntries(text)
    local found, seen = {}, {}
    for _, entry in ipairs(ENTRY_DB) do
        if entry.kind ~= "topic" and countMatches(text, entry.aliases) > 0 and not seen[entry.id] then
            seen[entry.id] = true
            found[#found+1] = entry
        end
    end
    return found
end

local function findFuzzyEntry(text)
    local words = tokenize(text)
    local votes = {}
    for _, w in ipairs(words) do
        local bestToken, bestDist = nil, math.huge
        for aliasWord, _ in pairs(ALL_ALIAS_TOKENS) do
            if math.abs(#aliasWord - #w) <= 2 then
                local d = levenshtein(w, aliasWord)
                if d < bestDist then bestDist, bestToken = d, aliasWord end
            end
        end
        local threshold = (#w <= 4) and 1 or 2
        if bestToken and bestDist <= threshold then
            for _, id in ipairs(ALL_ALIAS_TOKENS[bestToken]) do
                votes[id] = (votes[id] or 0) + 1
            end
        end
    end
    local bestId, bestCount = nil, 0
    for id, count in pairs(votes) do
        if count > bestCount then bestId, bestCount = id, count end
    end
    return bestId and ENTRY_INDEX[bestId] or nil
end

local function resolveTemplate(entry, text)
    for _, tmpl in ipairs(entry.templates) do
        if #tmpl.patterns > 0 and anyMatch(text, tmpl.patterns) then
            return tmpl
        end
    end
    return entry.templates[1]
end

-- ================= ENGLISH ANSWERS =================
local EN_TOPIC_ANSWERS = {
    greeting = "Hi there! I'm an offline assistant with 800+ Blox Fruits data points 🥰 Ask me about fruits, islands, bosses, weapons, fighting styles, codes, or try 'compare dragon and kitsune'!",
    thanks = "You're welcome! Happy grinding! 🥰 Feel free to ask me anything else.",
    help = "<b>[QUICK HELP]:</b> You can chat naturally in English or Vietnamese, for example:\n• 'is buddha good', 'what to build with kitsune'\n• 'compare dragon and kitsune'\n• 'tushita vs saddi which is better'\n• 'list fruits / islands / bosses / weapons / fighting styles'\n• 'v4 race', 'codes', 'rip indra'\nJust type naturally, I'll do my best to understand! 🥳",
    v4 = "<b>[V4 RACE GUIDE]:</b> Requires max level, defeating boss Rip_Indra, and completing the Trial at the Temple of Time. Ask 'where' or 'reward' for more detail!",
    rip_indra = "<b>[BOSS RIP_INDRA]:</b> High-level boss required to unlock the V4 race, has a wide lightning AoE attack. Bring high HP and dodge based on the warning indicator.",
    code = "<b>[X2 EXP CODES]:</b> Codes change and expire often, check the game's official announcement channel or Discord for the newest valid codes instead of using old expired ones.",
    sea_event = "<b>[SEA BOSSES]:</b> Sail to level 5-6 danger zones in Sea 3 at night to hunt Terrorshark or find Leviathan. Go with a group, their HP is very high.",
    tier_list = "<b>[OVERALL TIER LIST 2026]:</b> Current top tier (T0/S) usually includes Portal, Kitsune, Dragon, Buddha, with Leopard, Mammoth, Tiger, Yeti, Fiend right behind. Ask about a specific fruit or 'compare X and Y' for more!",
    reroll = "<b>[FRUIT REROLL]:</b> Use the Trader NPC near the main hub to reroll your devil fruit, usually costs in-game money or Fragments depending on the fruit.",
}

local function buildEnglishAnswer(entry)
    if entry.kind == "topic" then
        return EN_TOPIC_ANSWERS[entry.id] or string.format("<b>[%s]:</b> English detail coming soon, try asking in Vietnamese for the full detail! %s", entry.name, emo("cute"))
    elseif entry.kind == "fruit" then
        return string.format("<b>[%s]:</b> %s tier %s-type fruit. Best for %s. %s %s",
            entry.name, entry.tier, entry.subkind or "?", entry.en_role or entry.role,
            entry.en_note or "No detailed English info yet, ask in Vietnamese for more.", emo(tierMood(entry.tier)))
    elseif entry.kind == "island" then
        return string.format("<b>[%s]:</b> Located in %s. %s %s",
            entry.name, entry.sea or "?", entry.en_note or "More detail coming soon.", emo("cute"))
    else
        local label = (entry.kind == "boss" and "BOSS") or (entry.kind == "weapon" and "WEAPON") or "FIGHTING STYLE"
        return string.format("<b>[%s - %s]:</b> %s %s",
            entry.name, label, entry.en_note or "More detail coming soon, ask in Vietnamese for full info.", emo("neutral"))
    end
end

local EN_LIST_HEADERS = {
    ["DANH SACH TRAI"]="FRUIT LIST", ["DANH SACH DAO"]="ISLAND LIST",
    ["DANH SACH BOSS"]="BOSS LIST", ["DANH SACH VU KHI"]="WEAPON LIST",
    ["DANH SACH FIGHTING STYLE"]="FIGHTING STYLE LIST",
}

local function processOmniIntelligence(prompt)
    local text = normalize(prompt)
    local lang = detectLanguage(prompt, text)

    local compareResult = tryCompare(text, lang)
    if compareResult then
        currentContext = nil
        return compareResult
    end

    if string.find(text, "danh sach", 1, true) or string.find(text, "list ", 1, true) then
        local header, rawList = nil, nil
        if anyMatch(text, {"trai","fruit"}) then header, rawList = "DANH SACH TRAI", FRUITS_RAW end
        if anyMatch(text, {"dao","island"}) then header, rawList = "DANH SACH DAO", ISLANDS_RAW end
        if anyMatch(text, {"boss"}) then header, rawList = "DANH SACH BOSS", BOSSES_RAW end
        if anyMatch(text, {"vu khi","weapon"}) then header, rawList = "DANH SACH VU KHI", WEAPONS_RAW end
        if anyMatch(text, {"fighting style","phong cach","style"}) then header, rawList = "DANH SACH FIGHTING STYLE", FIGHTING_STYLES_RAW end
        if header then
            local finalHeader = (lang == "en") and (EN_LIST_HEADERS[header] or header) or header
            return buildListText(rawList, finalHeader)
        end
    end

    -- Cau hoi kieu "cao cap": nhac toi nhieu chu de cung luc (2-4 muc) ma
    -- khong dung tu "so sanh" -> gop tra loi ngan gon cho tung muc luon
    local multi = findMultipleEntries(text)
    if #multi >= 2 and #multi <= 4 then
        local parts = {}
        for _, e in ipairs(multi) do
            parts[#parts+1] = (lang == "en") and buildEnglishAnswer(e) or resolveTemplate(e, text).build()
        end
        currentContext = multi[#multi].id
        return table.concat(parts, "\n\n")
    end

    local freshEntry = findFreshEntry(text)

    if not freshEntry then
        freshEntry = findFuzzyEntry(text)
    end

    local activeEntry = freshEntry
    if not activeEntry and currentContext then
        activeEntry = ENTRY_INDEX[currentContext]
    end

    if activeEntry then
        currentContext = activeEntry.id
        if lang == "en" then
            return buildEnglishAnswer(activeEntry)
        end
        local tmpl = resolveTemplate(activeEntry, text)
        return tmpl.build()
    end

    currentContext = nil
    if lang == "en" then
        return "<b>[RESULT]:</b> I didn't catch that 😭 Try typing a fruit name (e.g. 'buddha'), an island, a boss, a weapon, a fighting style (e.g. 'godhuman'), 'v4 race', 'codes', 'list fruits', 'compare dragon and kitsune', or type 'help' to see how to ask!"
    end
    return "<b>[KET QUA]:</b> Toi chua hieu tu khoa nay 😭 Thu go ten mot trai (vd 'buddha'), mot dao, mot boss, mot vu khi, mot fighting style (vd 'godhuman'), 'toc v4', 'code', 'danh sach trai', 'so sanh dragon va kitsune', hoac go 'huong dan' de xem cach hoi nhe!"
end

local function onSend()
    local text = InputBox.Text
    if text ~= "" then
        playClickSound()
        InputBox.Text = ""
        addMessage("Ban", text, Color3.fromRGB(0, 150, 255))

        local ThinkingMsg = addMessage("He Thong", "<i>[Dang tra du lieu...]</i>", Color3.fromRGB(130, 130, 135))
        task.spawn(function()
            local responseText = processOmniIntelligence(text)
            task.wait(0.2)
            ThinkingMsg:Destroy()
            addMessage("He Thong", responseText, Color3.fromRGB(0, 220, 140))
        end)
    end
end

SendBtn.MouseButton1Click:Connect(onSend)
InputBox.FocusLost:Connect(function(enterPressed) if enterPressed then onSend() end end)

local rotSpeed = 90
RunService.RenderStepped:Connect(function(dt) RainbowGradient.Rotation = (RainbowGradient.Rotation + (rotSpeed * dt)) % 360 end)
TweenService:Create(BaseHolder, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = FinalSize}):Play()

local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    BaseHolder.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
BaseHolder.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = BaseHolder.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
BaseHolder.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)

CloseButton.MouseButton1Click:Connect(function()
    playClickSound()
    local close = TweenService:Create(BaseHolder, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
    close:Play()
    close.Completed:Connect(function() CoreMenu:Destroy() end)
end)
