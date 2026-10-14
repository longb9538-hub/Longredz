--[[ LONGRDEZ HUB - Key Loader
     Dành riêng cho web key LONGRDEZ. Cách chạy:
     loadstring(game:HttpGet("LINK_RAW_CUA_FILE_NAY"))()
]]

-- ========== CẤU HÌNH (sửa 3 dòng này) ==========
local WEB_URL     = "https://your-site.com"                 -- link web lấy key
local MAIN_URL    = "https://your-site.com/main.lua"        -- script chính chạy sau khi mở khóa
local SALT        = "CHANGE_ME_LRZ"                         -- PHẢI GIỐNG HỆT biến SALT trong index.html
local KEY_FILE    = "longrdez_key.txt"
local EXPIRE_MIN  = 24 * 60                                 -- key sống 24 giờ
-- ===============================================

local DIGITS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

local function b36(n, len)
	local s = ""
	repeat
		local r = n % 36
		s = DIGITS:sub(r + 1, r + 1) .. s
		n = (n - r) / 36
	until n == 0
	return string.rep("0", len - #s) .. s
end

local function h32(str)
	local h = 5381
	for r = 0, 1 do
		for i = 1, #str do
			h = (h * 33 + string.byte(str, i) + r) % 4294967296
		end
	end
	return h
end

-- Mã thiết bị: mỗi máy một mã riêng (7 ký tự), key chỉ dùng được trên đúng mã này
local function getHWID()
	local raw
	pcall(function() raw = game:GetService("RbxAnalyticsService"):GetClientId() end)
	if not raw and gethwid then pcall(function() raw = gethwid() end) end
	raw = tostring(raw or game:GetService("Players").LocalPlayer.UserId)
	return b36(h32(raw .. "|LRZ"), 7)
end
local HW = getHWID()

-- Kiểm tra key: đúng định dạng + đúng checksum (gắn với thiết bị) + chưa hết hạn
local function checkKey(key)
	key = tostring(key or ""):upper():gsub("%s", "")
	local ts, rnd, chk = key:match("^LRZ%-(%w%w%w%w%w)(%w%w%w%w)%-(%w%w%w%w%w)$")
	if not ts then return false, "Sai định dạng key" end
	if b36(h32(ts .. rnd .. HW .. SALT) % 60466176, 5) ~= chk then
		return false, "Key sai hoặc không phải của máy này"
	end
	local age = os.time() / 60 - (tonumber(ts, 36) or 0)
	if age < -10 then return false, "Key không hợp lệ" end
	if age > EXPIRE_MIN then return false, "Key đã hết hạn (24h), lấy key mới" end
	return true
end

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local parent = (gethui and gethui()) or game:GetService("CoreGui")

local VIOLET, PINK = Color3.fromRGB(184, 107, 255), Color3.fromRGB(255, 0, 238)
local GREEN, RED, SOFT = "#00ffaa", "#ff5a78", "#e6d0ff"

local function readSaved()
	if isfile and readfile and isfile(KEY_FILE) then
		local ok, v = pcall(readfile, KEY_FILE)
		if ok then return v end
	end
end

local function mk(class, props, par)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	o.Parent = par
	return o
end
local function tw(o, t, p, style, dir)
	local tween = TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), p)
	tween:Play()
	return tween
end
local function loop(o, t, p, style, reverse)
	TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, reverse or false), p):Play()
end
local function corner(o, r) mk("UICorner", { CornerRadius = UDim.new(0, r) }, o) end

local MAXORDER = 2147483647
local function bump(g)
	if g and g.Parent then
		local par = g.Parent
		g.Parent = nil
		g.Parent = par
	end
end
-- Mỗi 1 giây nhấc GUI lên làm "mới nhất" ở lớp cao nhất: GUI nào bằng lớp mà cũ hơn sẽ nằm dưới.
-- Bỏ qua khi đang gõ vào ô nhập (nhấc lúc đó sẽ mất focus bàn phím).
local function keepOnTop(g)
	task.spawn(function()
		while g.Parent do
			task.wait(1)
			if g.DisplayOrder ~= MAXORDER then g.DisplayOrder = MAXORDER end
			if not UIS:GetFocusedTextBox() then
				bump(g)
				if g.Name ~= "LongrdezLogo" then   -- logo luôn nằm trên cả bảng loader
					bump(parent:FindFirstChild("LongrdezLogo"))
				end
			end
		end
	end)
end

-- In ra console danh sách GUI đang ở lớp rất cao (để biết GUI nào đang che)
local function dumpGuis()
	local boxes = { parent }
	pcall(function() table.insert(boxes, game:GetService("CoreGui")) end)
	pcall(function() table.insert(boxes, game:GetService("Players").LocalPlayer.PlayerGui) end)
	for _, box in ipairs(boxes) do
		local ok, kids = pcall(function() return box:GetChildren() end)
		if ok then
			for _, o in ipairs(kids) do
				if o:IsA("ScreenGui") and o.DisplayOrder >= 1000 then
					print(("[LONGRDEZ] %s / %s / DisplayOrder=%d / Enabled=%s"):format(box.Name, o.Name, o.DisplayOrder, tostring(o.Enabled)))
				end
			end
		end
	end
end

local old = parent:FindFirstChild("LongrdezKeyUI")
if old then old:Destroy() end
local gui = mk("ScreenGui", { Name = "LongrdezKeyUI", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = MAXORDER }, parent)
pcall(function() gui.ScreenInsets = Enum.ScreenInsets.None end)
pcall(function() gui.OnTopOfCoreBlur = true end)
keepOnTop(gui)

-- ===== Cửa sổ chính (hiện ra bằng hiệu ứng phóng to + mờ dần) =====
local main = mk("CanvasGroup", {
	AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(60, 60),
	BackgroundColor3 = Color3.fromRGB(12, 6, 28), BorderSizePixel = 0, GroupTransparency = 1, Visible = false,
}, gui)
corner(main, 14)
mk("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(22, 10, 48), Color3.fromRGB(8, 3, 18)), Rotation = 90 }, main)
local stroke = mk("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2 }, main)
local sg = mk("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, VIOLET), ColorSequenceKeypoint.new(0.5, PINK), ColorSequenceKeypoint.new(1, VIOLET),
	}),
}, stroke)
loop(sg, 4, { Rotation = 360 })                                   -- viền sáng xoay
loop(stroke, 1.3, { Thickness = 3.4 }, Enum.EasingStyle.Sine, true) -- viền nhịp thở

-- ===== Hiệu ứng nền: hạt sáng bay lên + tia quét + vòng xoay =====
for i = 1, 14 do
	task.spawn(function()
		task.wait(math.random() * 4)
		while gui.Parent do
			local sz = math.random(2, 4)
			local p = mk("Frame", {
				Size = UDim2.fromOffset(sz, sz), Position = UDim2.new(math.random(), 0, 1, 6),
				BackgroundColor3 = (math.random() > 0.5) and VIOLET or PINK, BackgroundTransparency = 0.2,
				BorderSizePixel = 0, ZIndex = 0,
			}, main)
			corner(p, 4)
			local dur = math.random(40, 80) / 10
			tw(p, dur, { Position = UDim2.new(p.Position.X.Scale, math.random(-30, 30), 0, -8), BackgroundTransparency = 1 }, Enum.EasingStyle.Sine)
			task.wait(dur)
			p:Destroy()
		end
	end)
end
local scan = mk("Frame", {
	Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = VIOLET, BackgroundTransparency = 0.82, BorderSizePixel = 0, ZIndex = 0,
}, main)
loop(scan, 2.8, { Position = UDim2.new(0, 0, 1, 0) })

local spinner = mk("Frame", {
	Position = UDim2.fromOffset(14, 14), Size = UDim2.fromOffset(24, 24), BackgroundTransparency = 1,
}, main)
corner(spinner, 12)
local sps = mk("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 3 }, spinner)
local spg = mk("UIGradient", {
	Color = ColorSequence.new(PINK, VIOLET),
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 0.1),
		NumberSequenceKeypoint.new(0.51, 1), NumberSequenceKeypoint.new(1, 1),
	}),
}, sps)
loop(spg, 1.1, { Rotation = 360 })

-- ===== Mưa ký tự Matrix chảy sau nền (9 cột) =====
local RAIN = "01LRZXE<>/#$%&"
for k = 1, 9 do
	task.spawn(function()
		local x = k * 38 - 20
		local col = mk("TextLabel", {
			Size = UDim2.fromOffset(14, 220), Position = UDim2.fromOffset(x, -220), BackgroundTransparency = 1,
			Font = Enum.Font.Code, TextSize = 12, TextColor3 = VIOLET, TextTransparency = 0.55, ZIndex = 0,
			TextYAlignment = Enum.TextYAlignment.Top, Text = "",
		}, main)
		mk("UIGradient", {
			Rotation = 90,
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }),
		}, col)
		task.wait(math.random() * 3)
		while gui.Parent do
			local t = {}
			for i = 1, 16 do
				local r = math.random(#RAIN)
				t[i] = RAIN:sub(r, r)
			end
			col.Text = table.concat(t, "\n")
			col.Position = UDim2.fromOffset(x, -220)
			local d = math.random(30, 60) / 10
			tw(col, d, { Position = UDim2.fromOffset(x, 270) }, Enum.EasingStyle.Linear)
			task.wait(d)
		end
	end)
end

-- ===== 2 sao chổi chạy vòng quanh viền cửa sổ (có đuôi) =====
local comets = {}
for c = 1, 2 do
	local trail = {}
	for k = 1, 7 do
		local d = mk("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(6 - k * 0.6, 6 - k * 0.6),
			BackgroundColor3 = (c == 1) and VIOLET or PINK, BackgroundTransparency = 0.05 + k * 0.13,
			BorderSizePixel = 0, ZIndex = 6,
		}, main)
		corner(d, 4)
		trail[k] = d
	end
	comets[c] = trail
end
local cometT = 0
local cometConn
cometConn = RunService.Heartbeat:Connect(function(dt)
	if not gui.Parent then cometConn:Disconnect() return end
	cometT = cometT + dt * 0.16
	local w, h = main.AbsoluteSize.X - 2, main.AbsoluteSize.Y - 2
	local per = 2 * (w + h)
	for c, trail in ipairs(comets) do
		for k, d in ipairs(trail) do
			local u = ((cometT + (c - 1) * 0.5 - k * 0.007) % 1) * per
			local x, y
			if u < w then x, y = u, 0
			elseif u < w + h then x, y = w, u - w
			elseif u < 2 * w + h then x, y = w - (u - w - h), h
			else x, y = 0, h - (u - 2 * w - h) end
			d.Position = UDim2.fromOffset(x + 1, y + 1)
		end
	end
end)

-- ======================================================================
-- KHỐI A: HIỆU ỨNG NỀN CỬA SỔ (quầng cực quang trôi + 4 góc neon nhịp thở)
-- ======================================================================
for i = 1, 4 do
	task.spawn(function()
		local orb = mk("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(150, 150),
			Position = UDim2.fromScale(math.random(), math.random()),
			BackgroundColor3 = (i % 2 == 0) and PINK or VIOLET, BackgroundTransparency = 0.9,
			BorderSizePixel = 0, ZIndex = 0,
		}, main)
		corner(orb, 75)
		while gui.Parent do
			local d = math.random(35, 70) / 10
			tw(orb, d, {
				Position = UDim2.fromScale(math.random(), math.random()),
				BackgroundTransparency = 0.84 + math.random() * 0.08,
			}, Enum.EasingStyle.Sine)
			task.wait(d)
		end
	end)
end

for _, c in ipairs({ { 0, 0 }, { 1, 0 }, { 0, 1 }, { 1, 1 } }) do
	local ax, ay = c[1], c[2]
	for _, horiz in ipairs({ true, false }) do
		local bar = mk("Frame", {
			AnchorPoint = Vector2.new(ax, ay), Position = UDim2.new(ax, ax == 0 and 6 or -6, ay, ay == 0 and 6 or -6),
			Size = horiz and UDim2.fromOffset(16, 2) or UDim2.fromOffset(2, 16),
			BackgroundColor3 = (ax == ay) and VIOLET or PINK, BorderSizePixel = 0, ZIndex = 7,
		}, main)
		loop(bar, 1.1, { BackgroundTransparency = 0.8 }, Enum.EasingStyle.Sine, true)
	end
end

local title = mk("TextLabel", {
	Size = UDim2.new(1, 0, 0, 34), Position = UDim2.fromOffset(0, 8), BackgroundTransparency = 1,
	Text = "LONGRDEZ HUB", Font = Enum.Font.GothamBold, TextSize = 20, TextColor3 = Color3.new(1, 1, 1),
}, main)
local tg = mk("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, VIOLET), ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)), ColorSequenceKeypoint.new(1, VIOLET),
	}),
	Offset = Vector2.new(-1, 0),
}, title)
loop(tg, 2.2, { Offset = Vector2.new(1, 0) })                     -- ánh chớp chạy qua chữ
mk("TextLabel", {
	Size = UDim2.new(1, 0, 0, 14), Position = UDim2.fromOffset(0, 40), BackgroundTransparency = 1,
	Text = "K E Y   P O R T A L", Font = Enum.Font.Code, TextSize = 10, TextColor3 = VIOLET,
}, main)

-- ===== Glitch tách màu định kỳ cho tiêu đề =====
local function ghost(col)
	return mk("TextLabel", {
		Size = UDim2.new(1, 0, 0, 34), Position = UDim2.fromOffset(0, 8), BackgroundTransparency = 1,
		Text = "LONGRDEZ HUB", Font = Enum.Font.GothamBold, TextSize = 20, TextColor3 = col, TextTransparency = 1, ZIndex = 0,
	}, main)
end
local gA, gB = ghost(PINK), ghost(Color3.fromRGB(0, 240, 255))
task.spawn(function()
	while gui.Parent do
		task.wait(math.random(30, 60) / 10)
		for _ = 1, 6 do
			local dx = math.random(-5, 5)
			gA.Position = UDim2.fromOffset(dx, 8 + math.random(-1, 1))
			gB.Position = UDim2.fromOffset(-dx, 8 + math.random(-1, 1))
			gA.TextTransparency, gB.TextTransparency = 0.3, 0.3
			title.Position = UDim2.fromOffset(math.random(-2, 2), 8)
			task.wait(0.04)
		end
		gA.TextTransparency, gB.TextTransparency = 1, 1
		title.Position = UDim2.fromOffset(0, 8)
	end
end)

local closeBtn = mk("TextButton", {
	Size = UDim2.fromOffset(26, 26), Position = UDim2.new(1, -32, 0, 6), BackgroundTransparency = 1,
	Text = "X", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.fromRGB(150, 110, 200),
}, main)

local function closeUI()
	tw(main, 0.4, { GroupTransparency = 1, Size = UDim2.fromOffset(400, 280) })
	task.wait(0.45)
	gui:Destroy()
end
closeBtn.MouseButton1Click:Connect(closeUI)
closeBtn.MouseEnter:Connect(function() tw(closeBtn, 0.15, { TextColor3 = Color3.fromRGB(255, 90, 120) }) end)
closeBtn.MouseLeave:Connect(function() tw(closeBtn, 0.15, { TextColor3 = Color3.fromRGB(150, 110, 200) }) end)

-- ===== Hai trang: boot (log + thanh tải) và key =====
local function newPage()
	return mk("CanvasGroup", {
		Position = UDim2.fromOffset(0, 64), Size = UDim2.new(1, 0, 1, -64),
		BackgroundTransparency = 1, GroupTransparency = 1, Visible = false,
	}, main)
end
local bootPage, keyPage = newPage(), newPage()
local current
local staggerKey
local function show(p)
	if current == p then return end
	if current and current ~= p then
		local c = current
		tw(c, 0.25, { GroupTransparency = 1, Position = UDim2.fromOffset(0, 50) })
		task.delay(0.25, function() if current ~= c then c.Visible = false end end)
	end
	current = p
	p.Position = UDim2.fromOffset(0, 82)
	p.Visible = true
	tw(p, 0.45, { GroupTransparency = 0, Position = UDim2.fromOffset(0, 64) }, Enum.EasingStyle.Back)
	if p == keyPage and staggerKey then staggerKey() end
end

-- Trang boot: terminal + thanh tiến trình
local term = mk("Frame", {
	Position = UDim2.fromOffset(16, 0), Size = UDim2.new(1, -32, 0, 104), BackgroundColor3 = Color3.fromRGB(5, 2, 14),
}, bootPage)
corner(term, 10)
mk("UIStroke", { Color = Color3.fromRGB(90, 50, 150), Thickness = 1 }, term)
local logBox = mk("TextLabel", {
	Position = UDim2.fromOffset(8, 6), Size = UDim2.new(1, -16, 1, -12), BackgroundTransparency = 1, Text = "",
	RichText = true, Font = Enum.Font.Code, TextSize = 12, TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextColor3 = Color3.new(1, 1, 1),
}, term)
local stage = mk("TextLabel", {
	Position = UDim2.fromOffset(16, 112), Size = UDim2.new(1, -100, 0, 16), BackgroundTransparency = 1, Text = "",
	Font = Enum.Font.Code, TextSize = 11, TextColor3 = VIOLET, TextXAlignment = Enum.TextXAlignment.Left,
}, bootPage)
local pct = mk("TextLabel", {
	Position = UDim2.new(1, -76, 0, 112), Size = UDim2.fromOffset(60, 16), BackgroundTransparency = 1, Text = "0%",
	Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Right,
}, bootPage)
local barBg = mk("Frame", {
	Position = UDim2.fromOffset(16, 134), Size = UDim2.new(1, -32, 0, 8), BackgroundColor3 = Color3.fromRGB(34, 18, 64),
}, bootPage)
corner(barBg, 4)
local fill = mk("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = Color3.new(1, 1, 1) }, barBg)
corner(fill, 4)
mk("UIGradient", { Color = ColorSequence.new(PINK, VIOLET) }, fill)
fill.ClipsDescendants = true
local shine = mk("Frame", {
	Size = UDim2.fromScale(0.35, 1), Position = UDim2.fromScale(-0.4, 0), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
}, fill)
mk("UIGradient", {
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.35), NumberSequenceKeypoint.new(1, 1),
	}),
}, shine)
loop(shine, 1.1, { Position = UDim2.fromScale(1.05, 0) })

local pv = mk("NumberValue", { Value = 0 }, gui)
pv.Changed:Connect(function(v) pct.Text = math.floor(v + 0.5) .. "%" end)

local headDot = mk("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(12, 12),
	BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 3,
}, barBg)
corner(headDot, 6)
mk("UIStroke", { Color = PINK, Thickness = 2, Transparency = 0.2 }, headDot)
local hdScale = mk("UIScale", { Scale = 1 }, headDot)
loop(hdScale, 0.6, { Scale = 1.45 }, Enum.EasingStyle.Sine, true)

-- Thanh 3 bước: nút tròn sáng dần + đường nối lấp đầy + sóng ping
local NODE_X = { 60, 180, 300 }
local NODE_LB = { "XÁC THỰC", "TẢI SCRIPT", "KHỞI CHẠY" }
local nodes, lines = {}, {}
for i = 1, 3 do
	if i < 3 then
		local ln = mk("Frame", {
			Position = UDim2.fromOffset(NODE_X[i] + 12, 160), Size = UDim2.fromOffset(NODE_X[i + 1] - NODE_X[i] - 24, 2),
			BackgroundColor3 = Color3.fromRGB(40, 22, 74), BorderSizePixel = 0,
		}, bootPage)
		lines[i] = mk("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = VIOLET, BorderSizePixel = 0 }, ln)
	end
	local nd = mk("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(NODE_X[i], 161), Size = UDim2.fromOffset(18, 18),
		BackgroundColor3 = Color3.fromRGB(20, 10, 40), BorderSizePixel = 0,
	}, bootPage)
	corner(nd, 9)
	local st = mk("UIStroke", { Color = Color3.fromRGB(70, 40, 120), Thickness = 2 }, nd)
	mk("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromOffset(NODE_X[i], 176), Size = UDim2.fromOffset(90, 12),
		BackgroundTransparency = 1, Text = NODE_LB[i], Font = Enum.Font.Code, TextSize = 9, TextColor3 = Color3.fromRGB(150, 110, 200),
	}, bootPage)
	nodes[i] = { f = nd, s = st, on = false }
end
local function updateStep(n)
	for i = 1, 3 do
		local nd = nodes[i]
		local want = i <= n
		if want and not nd.on then
			nd.on = true
			tw(nd.f, 0.3, { BackgroundColor3 = VIOLET }, Enum.EasingStyle.Back)
			tw(nd.s, 0.3, { Color = Color3.new(1, 1, 1) })
			local ping = mk("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(18, 18), BackgroundTransparency = 1,
			}, nd.f)
			corner(ping, 30)
			local ps = mk("UIStroke", { Color = VIOLET, Thickness = 2 }, ping)
			tw(ping, 0.7, { Size = UDim2.fromOffset(46, 46) })
			tw(ps, 0.7, { Transparency = 1 })
			task.delay(0.75, function() ping:Destroy() end)
		elseif not want and nd.on then
			nd.on = false
			tw(nd.f, 0.2, { BackgroundColor3 = Color3.fromRGB(20, 10, 40) })
			tw(nd.s, 0.2, { Color = Color3.fromRGB(70, 40, 120) })
		end
		if i < 3 then tw(lines[i], 0.4, { Size = UDim2.fromScale((n > i) and 1 or 0, 1) }) end
	end
end

local logLines = {}
local function render(extra)
	local t = table.concat(logLines, "\n")
	if extra then t = t .. (t ~= "" and "\n" or "") .. extra end
	logBox.Text = t
end
local function typeLine(text, hex)
	hex = hex or SOFT
	local shown = ""
	for _, cp in utf8.codes(text) do
		shown = shown .. utf8.char(cp)
		render('<font color="' .. hex .. '">> ' .. shown .. "▌</font>")
		task.wait(0.012)
	end
	table.insert(logLines, '<font color="' .. hex .. '">> ' .. text .. "</font>")
	if #logLines > 6 then table.remove(logLines, 1) end
	render()
end
local function setProgress(p, label)
	tw(fill, 0.35, { Size = UDim2.fromScale(p / 100, 1) })
	tw(pv, 0.35, { Value = p })
	tw(headDot, 0.35, { Position = UDim2.fromScale(p / 100, 0.5) })
	updateStep(p >= 100 and 3 or p >= 50 and 2 or p > 0 and 1 or 0)
	if label then stage.Text = label end
end

-- Trang key
local box = mk("TextBox", {
	Position = UDim2.fromOffset(20, 0), Size = UDim2.new(1, -40, 0, 38), BackgroundColor3 = Color3.fromRGB(20, 10, 40),
	Text = "", PlaceholderText = "Dán key vào đây...", PlaceholderColor3 = Color3.fromRGB(120, 90, 160),
	TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.Code, TextSize = 14, ClearTextOnFocus = false,
}, keyPage)
corner(box, 8)
local boxStroke = mk("UIStroke", { Color = Color3.fromRGB(90, 50, 150), Thickness = 1 }, box)
box.Focused:Connect(function() tw(boxStroke, 0.2, { Color = VIOLET, Thickness = 2 }) end)
box.FocusLost:Connect(function() tw(boxStroke, 0.2, { Color = Color3.fromRGB(90, 50, 150), Thickness = 1 }) end)
local status = mk("TextLabel", {
	Position = UDim2.fromOffset(20, 44), Size = UDim2.new(1, -40, 0, 18), BackgroundTransparency = 1,
	Text = "Bấm GET KEY để lấy link web", Font = Enum.Font.Code, TextSize = 12,
	TextColor3 = Color3.fromRGB(207, 168, 255), TextXAlignment = Enum.TextXAlignment.Left,
}, keyPage)
local idLbl = mk("TextLabel", {
	Position = UDim2.fromOffset(20, 62), Size = UDim2.new(1, -40, 0, 14), BackgroundTransparency = 1,
	Text = "ID thiết bị: " .. HW .. "  (key chỉ dùng được trên máy này)", Font = Enum.Font.Code, TextSize = 10,
	TextColor3 = Color3.fromRGB(150, 110, 200), TextXAlignment = Enum.TextXAlignment.Left,
}, keyPage)
local function decorate(b)
	local sc = mk("UIScale", { Scale = 1 }, b)
	b.ClipsDescendants = true
	b.MouseEnter:Connect(function() tw(sc, 0.15, { Scale = 1.06 }, Enum.EasingStyle.Back) end)
	b.MouseLeave:Connect(function() tw(sc, 0.15, { Scale = 1 }) end)
	b.MouseButton1Down:Connect(function() tw(sc, 0.08, { Scale = 0.92 }) end)
	b.MouseButton1Up:Connect(function() tw(sc, 0.2, { Scale = 1.06 }, Enum.EasingStyle.Back) end)
	local sh = mk("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0 }, b)
	mk("UIGradient", {
		Rotation = 20, Offset = Vector2.new(-1, 0),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.78), NumberSequenceKeypoint.new(1, 1),
		}),
	}, sh)
	loop(sh:FindFirstChildOfClass("UIGradient"), 2.4, { Offset = Vector2.new(1, 0) })
end

local function burst(color)
	local ring = mk("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(20, 20),
		BackgroundTransparency = 1, ZIndex = 5,
	}, main)
	corner(ring, 200)
	local rs = mk("UIStroke", { Color = color or Color3.fromRGB(0, 255, 170), Thickness = 4 }, ring)
	tw(ring, 0.8, { Size = UDim2.fromOffset(420, 420) })
	tw(rs, 0.8, { Transparency = 1, Thickness = 1 })
	task.delay(0.85, function() ring:Destroy() end)
end

local function shake(o)
	local p = o.Position
	for _, dx in ipairs({ -8, 8, -5, 5, 0 }) do
		tw(o, 0.05, { Position = UDim2.new(p.X.Scale, p.X.Offset + dx, p.Y.Scale, p.Y.Offset) })
		task.wait(0.05)
	end
end

-- ===== Animation ổ khóa mở + tia lửa =====
local function unlockAnim()
	local G = Color3.fromRGB(0, 255, 170)
	local ov = mk("Frame", {
		Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(8, 3, 18), BackgroundTransparency = 1,
		BorderSizePixel = 0, ZIndex = 20, Active = true,
	}, main)
	tw(ov, 0.25, { BackgroundTransparency = 0.08 })
	local lock = mk("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.46), Size = UDim2.fromOffset(64, 64),
		BackgroundTransparency = 1, ZIndex = 21,
	}, ov)
	local us = mk("UIScale", { Scale = 0.2 }, lock)
	local body = mk("Frame", {
		AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 30), Size = UDim2.fromOffset(40, 30),
		BackgroundColor3 = VIOLET, BorderSizePixel = 0, ZIndex = 22,
	}, lock)
	corner(body, 7)
	local hole = mk("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.45), Size = UDim2.fromOffset(7, 7),
		BackgroundColor3 = Color3.fromRGB(20, 8, 40), BorderSizePixel = 0, ZIndex = 23,
	}, body)
	corner(hole, 4)
	local clip = mk("Frame", {
		AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 8), Size = UDim2.fromOffset(38, 22),
		BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 22,
	}, lock)
	local sh = mk("Frame", { Position = UDim2.fromOffset(6, 5), Size = UDim2.fromOffset(26, 26), BackgroundTransparency = 1, ZIndex = 22 }, clip)
	corner(sh, 13)
	local shs = mk("UIStroke", { Color = VIOLET, Thickness = 5 }, sh)
	local msg = mk("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.72), Size = UDim2.fromOffset(260, 18),
		BackgroundTransparency = 1, Text = "ĐANG XÁC THỰC KEY...", Font = Enum.Font.GothamBold, TextSize = 13,
		TextColor3 = Color3.fromRGB(207, 168, 255), ZIndex = 22,
	}, ov)

	tw(us, 0.4, { Scale = 1 }, Enum.EasingStyle.Back)
	task.wait(0.5)
	for _, r in ipairs({ -8, 8, -6, 6, 0 }) do   -- khóa rung vì bị bẻ
		tw(lock, 0.05, { Rotation = r })
		task.wait(0.05)
	end
	task.wait(0.1)
	tw(clip, 0.35, { Position = UDim2.new(0.5, 0, 0, -4), Rotation = -24 }, Enum.EasingStyle.Back)
	tw(body, 0.3, { BackgroundColor3 = G })
	tw(shs, 0.3, { Color = G })
	msg.Text = "ĐÃ MỞ KHÓA"
	tw(msg, 0.3, { TextColor3 = G })
	tw(us, 0.25, { Scale = 1.15 })
	for k = 1, 14 do
		local a = math.rad(k * 360 / 14)
		local sp = mk("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.46), Size = UDim2.fromOffset(5, 5),
			BackgroundColor3 = (k % 2 == 0) and G or Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 24,
		}, ov)
		corner(sp, 3)
		local dist = math.random(70, 120)
		tw(sp, 0.7, { Position = UDim2.new(0.5, math.cos(a) * dist, 0.46, math.sin(a) * dist), BackgroundTransparency = 1, Size = UDim2.fromOffset(1, 1) })
		task.delay(0.75, function() sp:Destroy() end)
	end
	for d = 0, 1 do
		task.delay(d * 0.18, function()
			local w = mk("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.46), Size = UDim2.fromOffset(40, 40),
				BackgroundTransparency = 1, ZIndex = 21,
			}, ov)
			corner(w, 300)
			local ws = mk("UIStroke", { Color = G, Thickness = 4 }, w)
			tw(w, 0.8, { Size = UDim2.fromOffset(340, 340) })
			tw(ws, 0.8, { Transparency = 1, Thickness = 1 })
			task.delay(0.85, function() w:Destroy() end)
		end)
	end
	task.wait(0.8)
	tw(ov, 0.3, { BackgroundTransparency = 1 })
	tw(us, 0.3, { Scale = 0.2 }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	tw(msg, 0.3, { TextTransparency = 1 })
	task.wait(0.3)
	ov:Destroy()
end

local function button(text, x, color)
	local b = mk("TextButton", {
		Position = UDim2.new(0, x, 0, 86), Size = UDim2.new(0.5, -26, 0, 40), BackgroundColor3 = color,
		Text = text, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.new(1, 1, 1),
	}, keyPage)
	corner(b, 10)
	decorate(b)
	return b
end
local getBtn = button("GET KEY", 20, Color3.fromRGB(90, 40, 170))
local chkBtn = button("MỞ KHÓA", 0, Color3.fromRGB(150, 40, 200))
chkBtn.Position = UDim2.new(0.5, 6, 0, 86)
local keyItems = {}
for _, o in ipairs({ box, status, idLbl, getBtn, chkBtn }) do keyItems[#keyItems + 1] = { o = o, p = o.Position } end
staggerKey = function()
	for i, it in ipairs(keyItems) do
		local p = it.p
		it.o.Position = UDim2.new(p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset + 24)
		task.delay(0.12 + (i - 1) * 0.08, function()
			tw(it.o, 0.5, { Position = p }, Enum.EasingStyle.Back)
		end)
	end
end
local function say(t, ok)
	status.Text = t
	status.TextColor3 = ok == nil and Color3.fromRGB(207, 168, 255)
		or (ok and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(255, 90, 120))
	if ok == false then
		task.spawn(shake, box)
		boxStroke.Color = Color3.fromRGB(255, 90, 120)
		tw(boxStroke, 0.8, { Color = Color3.fromRGB(90, 50, 150) })
	elseif ok then
		boxStroke.Color = Color3.fromRGB(0, 255, 170)
		tw(boxStroke, 0.8, { Color = Color3.fromRGB(90, 50, 150) })
	end
end

-- ======================================================================
-- KHỐI B: CINEMATIC "VÀO SCRIPT CHÍNH" (~5 giây)
-- Cửa sổ co lại -> xoáy năng lượng -> cổng 4 vòng -> ACCESS GRANTED đập xuống
-- -> BÙNG NỔ (sóng, tia, mảnh vỡ, rung, zoom) -> cột sáng -> tan vào game
-- ======================================================================
-- ======================================================================
-- KHỐI B (NÂNG CẤP): CINEMATIC "VÀO SCRIPT CHÍNH" ~5.6 giây
-- Thay TOÀN BỘ hàm `local function epicEnter() ... end` cũ bằng khối này.
-- Dùng lại các biến sẵn có: mk, tw, loop, corner, gui, main, VIOLET, PINK, RunService
--
-- 0.0s  cửa sổ co lại + dải đen điện ảnh + camera lùi
-- 0.3s  HYPERSPACE: tia sáng phóng ra từ tâm + vòng đường hầm
-- 1.3s  lõi năng lượng + 3 vòng con quay + 10 hạt quỹ đạo
-- 1.9s  "ACCESS GRANTED" giáng từng chữ (tách màu RGB, rung)
-- 3.3s  NÉN NĂNG LƯỢNG (hút vào, zoom, rung tăng dần, trắng nóng)
-- 3.9s  BÙNG NỔ: chớp trắng, sóng xung kích, nứt màn hình, cột sáng,
--       mảnh vỡ, nan hoa, tia flare ngang, FOV bật ra
-- 4.9s  dư chấn rồi tan vào game
-- ======================================================================
local function epicEnter()
	local cam = workspace.CurrentCamera
	local fov0 = cam and cam.FieldOfView or 70
	local WHITE = Color3.new(1, 1, 1)
	local GOLD = Color3.fromRGB(255, 196, 90)
	local CYAN = Color3.fromRGB(0, 240, 255)
	local GRN = Color3.fromRGB(0, 255, 170)
	local Q, IN, OUT = Enum.EasingStyle.Quad, Enum.EasingDirection.In, Enum.EasingDirection.Out
	local alive = true
	local T0 = os.clock()
	local rnd, pi = math.random, math.pi

	local function later(t, fn)
		task.delay(t, function() if alive then fn() end end)
	end

	-- Camera + blur
	local blur
	pcall(function()
		blur = Instance.new("BlurEffect")
		blur.Size = 0
		blur.Parent = game:GetService("Lighting")
	end)
	local function camFx(f, b, t, style, dir)
		if cam then pcall(function() tw(cam, t, { FieldOfView = f }, style, dir) end) end
		if blur then pcall(function() tw(blur, t, { Size = b }, style, dir) end) end
	end

	-- Lớp phủ
	local ov = mk("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 90, Active = true }, gui)
	local bg = mk("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(3, 1, 9), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 90 }, ov)
	local world = mk("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 91 }, ov)
	local ctr = mk("Frame", { Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1, ZIndex = 92 }, world)
	local vw = (cam and cam.ViewportSize.X) or 700
	local S = math.clamp(vw / 700, 0.6, 1.25)
	mk("UIScale", { Scale = S }, ctr)

	-- Dải đen điện ảnh
	local barT = mk("Frame", { Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 130 }, ov)
	local barB = mk("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 130 }, ov)
	tw(barT, 0.6, { Size = UDim2.new(1, 0, 0.08, 0) }, Enum.EasingStyle.Quint)
	tw(barB, 0.6, { Size = UDim2.new(1, 0, 0.08, 0) }, Enum.EasingStyle.Quint)

	-- Vignette tối mép
	for _, v in ipairs({
		{ UDim2.new(1, 0, 0.3, 0), UDim2.fromScale(0, 0), Vector2.new(0, 0), 90 },
		{ UDim2.new(1, 0, 0.3, 0), UDim2.fromScale(0, 1), Vector2.new(0, 1), 270 },
		{ UDim2.new(0.2, 0, 1, 0), UDim2.fromScale(0, 0), Vector2.new(0, 0), 0 },
		{ UDim2.new(0.2, 0, 1, 0), UDim2.fromScale(1, 0), Vector2.new(1, 0), 180 },
	}) do
		local f = mk("Frame", { Size = v[1], Position = v[2], AnchorPoint = v[3], BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 91 }, ov)
		mk("UIGradient", { Rotation = v[4], Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.25), NumberSequenceKeypoint.new(1, 1) }) }, f)
	end

	-- Rung màn hình + hạt quỹ đạo (chung 1 Heartbeat)
	local shakeAmt, orbitR, orbitT = 0, 0, 0
	local function kick(a) shakeAmt = math.max(shakeAmt, a) end
	local dots = {}
	for i = 1, 10 do
		local d = mk("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(5, 5), BackgroundTransparency = 1,
			BackgroundColor3 = (i % 2 == 0) and PINK or WHITE, BorderSizePixel = 0, ZIndex = 100,
		}, ctr)
		corner(d, 3)
		dots[i] = d
	end
	local conn = RunService.Heartbeat:Connect(function(dt)
		local t = os.clock() - T0
		orbitR = orbitR + (orbitT - orbitR) * math.min(1, dt * 6)
		for i, d in ipairs(dots) do
			local a = t * 2.4 + i * (pi * 2 / #dots)
			local depth = (math.sin(a) + 1) / 2
			d.Position = UDim2.fromOffset(math.cos(a) * orbitR, math.sin(a) * orbitR * 0.3)
			local sz = 3 + depth * 5
			d.Size = UDim2.fromOffset(sz, sz)
			d.BackgroundTransparency = (orbitR < 5) and 1 or (0.65 - depth * 0.6)
		end
		shakeAmt = shakeAmt * 0.88
		if shakeAmt < 0.2 then
			world.Position = UDim2.fromOffset(0, 0)
		else
			world.Position = UDim2.fromOffset((rnd() * 2 - 1) * shakeAmt, (rnd() * 2 - 1) * shakeAmt)
		end
	end)

	-- ===== Công cụ hiệu ứng =====
	local function flash(a, t, col)
		local fl = mk("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = col or WHITE, BackgroundTransparency = a, BorderSizePixel = 0, ZIndex = 125 }, ov)
		tw(fl, t, { BackgroundTransparency = 1 })
		task.delay(t + 0.05, function() fl:Destroy() end)
	end
	local function wave(delay_, col, size, thick, dur)
		later(delay_, function()
			local w = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(30, 30), BackgroundTransparency = 1, ZIndex = 96 }, ctr)
			corner(w, 900)
			local ws = mk("UIStroke", { Color = col, Thickness = thick or 4 }, w)
			dur = dur or 1.1
			tw(w, dur, { Size = UDim2.fromOffset(size, size) }, Enum.EasingStyle.Quart)
			tw(ws, dur, { Transparency = 1, Thickness = 1 })
			task.delay(dur + 0.05, function() w:Destroy() end)
		end)
	end
	-- tia hyperspace: bắn từ tâm ra, dài dần, nhanh dần
	local function warp(dur)
		local a = rnd() * pi * 2
		local len = rnd(60, 180)
		local st = mk("Frame", {
			AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.fromOffset(4, rnd(1, 3)),
			Position = UDim2.fromOffset(math.cos(a) * 20, math.sin(a) * 20), Rotation = math.deg(a),
			BackgroundColor3 = ({ VIOLET, PINK, WHITE, CYAN })[rnd(4)], BorderSizePixel = 0, ZIndex = 93,
		}, ctr)
		mk("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }) }, st)
		local d = rnd(520, 900)
		tw(st, dur, { Position = UDim2.fromOffset(math.cos(a) * d, math.sin(a) * d), Size = UDim2.fromOffset(len, st.Size.Y.Offset) }, Q, IN)
		task.delay(dur + 0.05, function() st:Destroy() end)
	end
	local function streakIn(dur, r0)
		local a = rnd() * pi * 2
		local r = r0 or rnd(260, 480)
		local st = mk("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(rnd(40, 100), 2),
			Position = UDim2.fromOffset(math.cos(a) * r, math.sin(a) * r), Rotation = math.deg(a),
			BackgroundColor3 = (rnd() > 0.5) and VIOLET or PINK, BorderSizePixel = 0, ZIndex = 93,
		}, ctr)
		mk("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }) }, st)
		tw(st, dur, { Position = UDim2.fromOffset(math.cos(a) * 14, math.sin(a) * 14) }, Q, IN)
		task.delay(dur, function() st:Destroy() end)
	end
	local function streakOut()
		local a = rnd() * pi * 2
		local st = mk("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(rnd(80, 240), rnd(2, 4)),
			Position = UDim2.fromOffset(math.cos(a) * 30, math.sin(a) * 30), Rotation = math.deg(a),
			BackgroundColor3 = (rnd() > 0.4) and WHITE or PINK, BorderSizePixel = 0, ZIndex = 100,
		}, ctr)
		mk("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }) }, st)
		local d, dur = rnd(360, 760), rnd(5, 10) / 10
		tw(st, dur, { Position = UDim2.fromOffset(math.cos(a) * d, math.sin(a) * d), BackgroundTransparency = 1 }, Enum.EasingStyle.Quart)
		task.delay(dur + 0.05, function() st:Destroy() end)
	end
	local function rays(n, dist, len)
		for k = 0, n - 1 do
			local deg = k * (360 / n)
			local th = math.rad(deg)
			local ray = mk("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5), Rotation = deg + 90, Size = UDim2.fromOffset(3, 10),
				Position = UDim2.fromOffset(math.cos(th) * 40, math.sin(th) * 40),
				BackgroundColor3 = (k % 2 == 0) and VIOLET or PINK, BorderSizePixel = 0, ZIndex = 98,
			}, ctr)
			tw(ray, 0.9, { Size = UDim2.fromOffset(3, len), BackgroundTransparency = 1, Position = UDim2.fromOffset(math.cos(th) * dist, math.sin(th) * dist) }, Enum.EasingStyle.Quart)
			task.delay(1, function() ray:Destroy() end)
		end
	end
	local function debris(n)
		for i = 1, n do
			local a, d = rnd() * pi * 2, rnd(160, 640)
			local s = rnd(4, 14)
			local p = mk("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(s, math.max(2, s * (rnd(30, 100) / 100))),
				BackgroundColor3 = ({ WHITE, PINK, VIOLET, GOLD, CYAN })[(i % 5) + 1], BorderSizePixel = 0,
				Rotation = rnd(0, 360), ZIndex = 99,
			}, ctr)
			local dur = rnd(8, 18) / 10
			tw(p, dur, {
				Position = UDim2.fromOffset(math.cos(a) * d, math.sin(a) * d + rnd(20, 110)),
				Rotation = rnd(-720, 720), BackgroundTransparency = 1, Size = UDim2.fromOffset(1, 1),
			}, Q)
			task.delay(dur + 0.05, function() p:Destroy() end)
		end
	end
	-- vết nứt màn hình
	local function cracks(n)
		for _ = 1, n do
			local a = rnd() * pi * 2
			local x, y = 0, 0
			local segs = rnd(5, 8)
			for i = 1, segs do
				local na = a + (rnd() - 0.5) * 0.9
				local l = rnd(40, 110)
				local nx, ny = x + math.cos(na) * l, y + math.sin(na) * l
				local seg = mk("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset((x + nx) / 2, (y + ny) / 2),
					Size = UDim2.fromOffset(l + 2, 2), Rotation = math.deg(math.atan2(ny - y, nx - x)),
					BackgroundColor3 = (i % 2 == 0) and WHITE or CYAN, BorderSizePixel = 0, ZIndex = 101,
				}, ctr)
				seg.BackgroundTransparency = 1
				task.delay(i * 0.025, function()
					if not seg.Parent then return end
					seg.BackgroundTransparency = 0
					tw(seg, 0.7, { BackgroundTransparency = 1, Size = UDim2.fromOffset(l + 2, 0) })
				end)
				task.delay(1, function() seg:Destroy() end)
				x, y, a = nx, ny, na
			end
		end
	end
	-- cột sáng khổng lồ xuyên màn hình
	local function beam()
		local b = mk("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0, 0, 3, 0), BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 97,
		}, ctr)
		mk("UIGradient", {
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) }),
		}, b)
		tw(b, 0.25, { Size = UDim2.new(0, 90, 3, 0) }, Enum.EasingStyle.Quint)
		task.delay(0.25, function() tw(b, 0.8, { Size = UDim2.new(0, 0, 3, 0) }, Enum.EasingStyle.Quint, IN) end)
		task.delay(1.1, function() b:Destroy() end)
	end
	local function flare()
		local f = mk("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0, 0, 0, 4), BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 97,
		}, ctr)
		mk("UIGradient", {
			Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, CYAN), ColorSequenceKeypoint.new(0.5, WHITE), ColorSequenceKeypoint.new(1, PINK) }),
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) }),
		}, f)
		tw(f, 0.5, { Size = UDim2.new(0, 1800, 0, 4) }, Enum.EasingStyle.Quint)
		task.delay(0.35, function() tw(f, 0.7, { BackgroundTransparency = 1, Size = UDim2.new(0, 1800, 0, 0) }) end)
		task.delay(1.2, function() f:Destroy() end)
	end
	local function lightning()
		local a = rnd() * pi * 2
		local x2, y2 = math.cos(a) * rnd(160, 280), math.sin(a) * rnd(160, 280)
		local pts = { { 0, 0 } }
		for i = 1, 5 do pts[#pts + 1] = { x2 * i / 6 + rnd(-18, 18), y2 * i / 6 + rnd(-18, 18) } end
		pts[#pts + 1] = { x2, y2 }
		for layer = 1, 2 do
			for i = 1, #pts - 1 do
				local p, q = pts[i], pts[i + 1]
				local dx, dy = q[1] - p[1], q[2] - p[2]
				local len = math.sqrt(dx * dx + dy * dy) + 2
				local seg = mk("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset((p[1] + q[1]) / 2, (p[2] + q[2]) / 2),
					Size = UDim2.fromOffset(len, layer == 1 and 5 or 2), Rotation = math.deg(math.atan2(dy, dx)),
					BackgroundColor3 = (layer == 1) and CYAN or WHITE, BackgroundTransparency = (layer == 1) and 0.5 or 0,
					BorderSizePixel = 0, ZIndex = 100 + layer,
				}, ctr)
				tw(seg, 0.3, { BackgroundTransparency = 1, Size = UDim2.fromOffset(len, 0) })
				task.delay(0.35, function() seg:Destroy() end)
			end
		end
	end

	-- ===== 0.0s: cửa sổ co lại =====
	tw(main, 0.55, { Size = UDim2.fromOffset(40, 40), GroupTransparency = 1 }, Enum.EasingStyle.Back, IN)
	tw(bg, 0.5, { BackgroundTransparency = 0.06 })
	camFx(fov0 + 8, 6, 0.7, Q, OUT)

	-- ===== 0.3-2.0s: HYPERSPACE + vòng đường hầm =====
	task.spawn(function()
		task.wait(0.3)
		local t0 = os.clock()
		while alive and os.clock() - t0 < 1.9 do
			local k = (os.clock() - t0) / 1.9
			for _ = 1, 2 + math.floor(k * 5) do warp(0.7 - k * 0.3) end
			task.wait(0.04)
		end
	end)
	task.spawn(function()
		task.wait(0.4)
		local t0 = os.clock()
		while alive and os.clock() - t0 < 1.6 do
			local r = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(20, 20), BackgroundTransparency = 1, ZIndex = 92 }, ctr)
			corner(r, 900)
			local rs = mk("UIStroke", { Color = (rnd() > 0.5) and VIOLET or PINK, Thickness = 1, Transparency = 0.6 }, r)
			tw(r, 0.9, { Size = UDim2.fromOffset(1100, 1100) }, Q, IN)
			tw(rs, 0.9, { Thickness = 5, Transparency = 1 }, Q, IN)
			task.delay(0.95, function() r:Destroy() end)
			task.wait(0.16)
		end
	end)

	-- ===== 1.3s: LÕI + 3 vòng con quay + halo =====
	local orb = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(0, 0), BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 97 }, ctr)
	corner(orb, 400)
	mk("UIGradient", { Color = ColorSequence.new(WHITE, PINK), Rotation = 90 }, orb)
	local halos = {}
	for i, sz in ipairs({ 200, 300, 420 }) do
		local h = mk("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(0, 0), BackgroundColor3 = (i == 2) and PINK or VIOLET,
			BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 94,
		}, ctr)
		corner(h, 600)
		halos[i] = { f = h, sz = sz, tr = ({ 0.8, 0.88, 0.93 })[i] }
	end
	local gyros = {}
	for i, sz in ipairs({ 110, 170, 230 }) do
		local r = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1, ZIndex = 98 }, ctr)
		corner(r, 600)
		local sk = mk("UIStroke", { Color = WHITE, Thickness = 5 - i }, r)
		local g = mk("UIGradient", {
			Color = ColorSequence.new((i % 2 == 0) and PINK or CYAN, VIOLET),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.4, 0.1),
				NumberSequenceKeypoint.new(0.55, 1), NumberSequenceKeypoint.new(1, 1),
			}),
		}, sk)
		loop(g, 1.2 + i * 0.6, { Rotation = (i % 2 == 0) and -360 or 360 })
		later(1.3 + i * 0.1, function() tw(r, 0.6, { Size = UDim2.fromOffset(sz, sz) }, Enum.EasingStyle.Back) end)
		gyros[i] = { r = r, s = sk, sz = sz }
	end
	later(1.3, function()
		tw(orb, 0.6, { Size = UDim2.fromOffset(50, 50) }, Enum.EasingStyle.Back)
		for _, h in ipairs(halos) do
			tw(h.f, 0.9, { Size = UDim2.fromOffset(h.sz, h.sz), BackgroundTransparency = h.tr }, Enum.EasingStyle.Back)
			loop(h.f, 0.8, { BackgroundTransparency = h.tr + 0.05 }, Enum.EasingStyle.Sine, true)
		end
		orbitT = 120
		wave(0, WHITE, 260, 3, 0.7)
	end)

	-- ===== 1.9s: ACCESS GRANTED =====
	local TXT = "ACCESS GRANTED"
	local letters = {}
	local STEP = 28
	for i = 1, #TXT do
		local ch = TXT:sub(i, i)
		if ch ~= " " then
			local x = (i - (#TXT + 1) / 2) * STEP
			local function lbl(col, z)
				return mk("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x, 4), Size = UDim2.fromOffset(30, 40),
					BackgroundTransparency = 1, Text = ch, Font = Enum.Font.GothamBlack, TextSize = 32,
					TextColor3 = col, TextTransparency = 1, ZIndex = z,
				}, ctr)
			end
			local main_ = lbl(WHITE, 112)
			local ga, gb = lbl(PINK, 110), lbl(CYAN, 110)
			local sc = mk("UIScale", { Scale = 3.5 }, main_)
			letters[#letters + 1] = { m = main_, a = ga, b = gb, x = x }
			later(1.9 + i * 0.055, function()
				main_.TextColor3 = GRN
				tw(main_, 0.1, { TextTransparency = 0 })
				tw(sc, 0.28, { Scale = 1 }, Enum.EasingStyle.Quint, IN)
				task.delay(0.28, function()
					if not alive then return end
					kick(5)
					tw(main_, 0.8, { TextColor3 = WHITE })
					ga.TextTransparency, gb.TextTransparency = 0.3, 0.3
					ga.Position = UDim2.fromOffset(x + 6, 4)
					gb.Position = UDim2.fromOffset(x - 6, 4)
					tw(ga, 0.4, { TextTransparency = 1, Position = UDim2.fromOffset(x, 4) })
					tw(gb, 0.4, { TextTransparency = 1, Position = UDim2.fromOffset(x, 4) })
				end)
			end)
		end
	end
	-- glitch định kỳ
	task.spawn(function()
		task.wait(3.0)
		while alive and os.clock() - T0 < 3.5 do
			for _, l in ipairs(letters) do
				local dx = rnd(-7, 7)
				l.a.Position = UDim2.fromOffset(l.x + dx, 4 + rnd(-2, 2))
				l.b.Position = UDim2.fromOffset(l.x - dx, 4 + rnd(-2, 2))
				l.a.TextTransparency, l.b.TextTransparency = 0.35, 0.35
			end
			task.wait(0.05)
			for _, l in ipairs(letters) do l.a.TextTransparency, l.b.TextTransparency = 1, 1 end
			task.wait(rnd(25, 50) / 100)
		end
	end)

	local name = "PLAYER"
	pcall(function() name = game:GetService("Players").LocalPlayer.DisplayName end)
	local subTxt = "CHÀO MỪNG, " .. string.upper(name)
	local sub = mk("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(0, 50), Size = UDim2.fromOffset(420, 16),
		BackgroundTransparency = 1, Text = "", Font = Enum.Font.Code, TextSize = 13, TextColor3 = VIOLET, ZIndex = 112,
	}, ctr)
	local line = mk("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(0, 74), Size = UDim2.fromOffset(0, 2),
		BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 112,
	}, ctr)
	mk("UIGradient", {
		Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, VIOLET), ColorSequenceKeypoint.new(0.5, PINK), ColorSequenceKeypoint.new(1, VIOLET) }),
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) }),
	}, line)
	later(2.9, function()
		tw(line, 0.7, { Size = UDim2.fromOffset(420, 2) }, Enum.EasingStyle.Quint)
		task.spawn(function()
			for _, cp in utf8.codes(subTxt) do
				if not alive then return end
				sub.Text = sub.Text .. utf8.char(cp)
				task.wait(0.025)
			end
		end)
	end)

	-- ===== 2.4s: va chạm nhỏ + sét =====
	later(2.4, function()
		flash(0.5, 0.5)
		kick(20)
		camFx(fov0 - 12, 12, 0.08, Q, OUT)
		task.delay(0.12, function() camFx(fov0, 0, 0.8, Q, OUT) end)
		wave(0, WHITE, 560, 7)
		wave(0.1, PINK, 460, 5)
		wave(0.2, VIOLET, 380, 4)
		rays(28, 240, 80)
		debris(24)
		for _ = 1, 20 do streakOut() end
	end)
	task.spawn(function()
		task.wait(2.8)
		while alive and os.clock() - T0 < 3.4 do
			lightning()
			kick(2.5)
			task.wait(0.09)
		end
	end)

	-- ===== 3.3s: NÉN NĂNG LƯỢNG =====
	later(3.3, function()
		orbitT = 30
		tw(orb, 0.6, { Size = UDim2.fromOffset(100, 100) }, Q, IN)
		for i, g in ipairs(gyros) do tw(g.r, 0.6, { Size = UDim2.fromOffset(40 + i * 14, 40 + i * 14) }, Q, IN) end
		for _, h in ipairs(halos) do tw(h.f, 0.6, { Size = UDim2.fromOffset(h.sz * 0.4, h.sz * 0.4), BackgroundTransparency = 0.6 }, Q, IN) end
		camFx(fov0 - 16, 12, 0.6, Q, IN)
		task.spawn(function()
			local t0 = os.clock()
			while alive and os.clock() - t0 < 0.6 do
				local k = (os.clock() - t0) / 0.6
				kick(2 + k * 9)
				for _ = 1, 4 do streakIn(0.35, rnd(150, 420)) end
				task.wait(0.04)
			end
		end)
	end)

	-- ===== 3.9s: BÙNG NỔ =====
	later(3.9, function()
		flash(0, 1.2)
		kick(46)
		camFx(fov0 + 30, 32, 0.1, Q, OUT)
		task.delay(0.15, function() camFx(fov0, 0, 1.4, Q, OUT) end)
		wave(0, WHITE, 1200, 10)
		wave(0.08, CYAN, 1000, 6)
		wave(0.16, PINK, 860, 8)
		wave(0.26, VIOLET, 700, 6)
		wave(0.38, GOLD, 520, 4)
		rays(48, 340, 100)
		beam()
		flare()
		cracks(9)
		debris(70)
		for _ = 1, 54 do streakOut() end
		orbitT = 260
		tw(orb, 0.7, { Size = UDim2.fromOffset(1300, 1300), BackgroundTransparency = 1 }, Enum.EasingStyle.Quart)
		for i, g in ipairs(gyros) do
			tw(g.r, 0.8, { Size = UDim2.fromOffset(560 + i * 180, 560 + i * 180) }, Enum.EasingStyle.Quart)
			tw(g.s, 0.8, { Transparency = 1 })
		end
		for _, h in ipairs(halos) do
			tw(h.f, 0.9, { Size = UDim2.fromOffset(h.sz * 3, h.sz * 3), BackgroundTransparency = 1 }, Enum.EasingStyle.Quart)
		end
		for _, l in ipairs(letters) do
			l.m.TextColor3 = GOLD
			tw(l.m, 0.5, { TextColor3 = WHITE })
			tw(l.m, 0.5, { TextTransparency = 1, Position = UDim2.fromOffset(l.x * 1.6, -40) }, Enum.EasingStyle.Quart, IN)
		end
		tw(sub, 0.4, { TextTransparency = 1 })
		tw(line, 0.4, { Size = UDim2.fromOffset(0, 2) })
		task.spawn(function()
			for k = 1, 4 do
				task.wait(0.28)
				if not alive then return end
				kick(14 - k * 3)
				wave(0, (k % 2 == 0) and VIOLET or PINK, 460, 3)
			end
		end)
	end)

	-- ===== 4.9s: dải đen rút ra, nền tan vào game =====
	task.wait(4.9)
	tw(barT, 0.4, { Size = UDim2.new(1, 0, 0, 0) })
	tw(barB, 0.4, { Size = UDim2.new(1, 0, 0, 0) })
	tw(bg, 0.6, { BackgroundTransparency = 1 })
	task.wait(0.7)
	alive = false
	conn:Disconnect()
	world.Position = UDim2.fromOffset(0, 0)
	if blur then pcall(function() blur:Destroy() end) end
	if cam then pcall(function() cam.FieldOfView = fov0 end) end
	ov:Destroy()
end

local function makeLogo()
	local old2 = parent:FindFirstChild("LongrdezLogo")
	if old2 then old2:Destroy() end
	local lg = mk("ScreenGui", {
		Name = "LongrdezLogo", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 2147483647,
	}, parent)
	pcall(function() lg.OnTopOfCoreBlur = true end)
	local btn = mk("TextButton", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 36, 0.4, 0), Size = UDim2.fromOffset(52, 52),
		BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
	}, lg)
	local sc = mk("UIScale", { Scale = 0.1 }, btn)

	-- nền tròn tối + viền gradient xoay + nhịp thở
	local disc = mk("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(40, 40),
		BackgroundColor3 = Color3.fromRGB(12, 6, 28), BorderSizePixel = 0,
	}, btn)
	corner(disc, 20)
	local ds = mk("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2 }, disc)
	local dg = mk("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, VIOLET), ColorSequenceKeypoint.new(0.5, PINK), ColorSequenceKeypoint.new(1, VIOLET),
		}),
	}, ds)
	loop(dg, 3, { Rotation = 360 })
	loop(ds, 1.2, { Thickness = 3.2 }, Enum.EasingStyle.Sine, true)

	-- lục giác xoay quanh
	local hx = mk("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(52, 52), BackgroundTransparency = 1,
	}, btn)
	local R = 24
	for i = 0, 5 do
		local th = math.rad(i * 60 - 90)
		mk("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, math.cos(th) * R * 0.866, 0.5, math.sin(th) * R * 0.866),
			Size = UDim2.fromOffset(R + 2, 2), Rotation = i * 60, BackgroundColor3 = (i % 2 == 0) and VIOLET or PINK,
			BorderSizePixel = 0, BackgroundTransparency = 0.15,
		}, hx)
	end
	loop(hx, 10, { Rotation = 360 })

	-- chữ L
	local Lb = mk("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(30, 30), BackgroundTransparency = 1,
		Text = "L", Font = Enum.Font.GothamBlack, TextSize = 22, TextColor3 = Color3.new(1, 1, 1),
	}, btn)
	mk("UIGradient", { Color = ColorSequence.new(Color3.new(1, 1, 1), PINK), Rotation = 90 }, Lb)
	local lbs = mk("UIScale", { Scale = 1 }, Lb)
	loop(lbs, 0.9, { Scale = 1.12 }, Enum.EasingStyle.Sine, true)

	-- hiện ra từ nhỏ xíu, rồi 2 sóng chào
	tw(sc, 0.7, { Scale = 1 }, Enum.EasingStyle.Back)

	local function pulse()
		for d = 0, 1 do
			task.delay(d * 0.15, function()
				local w = mk("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(40, 40), BackgroundTransparency = 1,
				}, btn)
				corner(w, 100)
				local ws = mk("UIStroke", { Color = (d == 0) and VIOLET or PINK, Thickness = 3 }, w)
				tw(w, 0.7, { Size = UDim2.fromOffset(130, 130) })
				tw(ws, 0.7, { Transparency = 1, Thickness = 1 })
				task.delay(0.75, function() w:Destroy() end)
			end)
		end
		tw(sc, 0.1, { Scale = 0.85 })
		task.delay(0.1, function() tw(sc, 0.3, { Scale = 1 }, Enum.EasingStyle.Back) end)
	end
	task.delay(0.7, pulse)

	-- kéo thả (kéo > 5px thì là kéo, ngắn hơn là chạm)
	local dragging, moved, startMouse, startPos = false, false, nil, nil
	btn.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging, moved, startMouse, startPos = true, false, i.Position, btn.Position
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then
					dragging = false
					if not moved then pulse() end
				end
			end)
		end
	end)
	local mv = UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - startMouse
			if d.Magnitude > 5 then moved = true end
			if moved then
				btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end
	end)
	lg.Destroying:Connect(function() mv:Disconnect() end)

	keepOnTop(lg)
end

-- ===== INTRO BÁ KHÍ 10 GIÂY =====
-- 0-1.3s năng lượng hút vào | 1.35s chữ L giáng xuống, rung màn hình | 1.9-3s chữ LONGRDEZ đập xuống
-- 3-6.6s sét + sóng xung kích | 6.8-7.9s nén năng lượng (zoom + mờ) | 7.9s NỔ TUNG | 9.5s thu vào cửa sổ
local skipIntro = false

local function playIntro()
	local cam = workspace.CurrentCamera
	local vh = cam and cam.ViewportSize.Y or 430
	local BASE = math.clamp(vh / 430, 0.75, 1.25)
	local T0 = os.clock()
	local alive = true
	local WHITE = Color3.new(1, 1, 1)
	local GOLD = Color3.fromRGB(255, 196, 90)
	local CYAN = Color3.fromRGB(0, 240, 255)
	local Q, B = Enum.EasingStyle.Quad, Enum.EasingStyle.Back
	local IN, OUT = Enum.EasingDirection.In, Enum.EasingDirection.Out

	local function waitUntil(t)
		while os.clock() - T0 < t and not skipIntro do task.wait() end
	end
	local function at(t, fn)
		waitUntil(t)
		if not skipIntro then fn() end
	end

	-- Camera: zoom FOV + làm mờ nền game (có pcall, hỏng cũng không sao)
	local blur
	pcall(function()
		blur = Instance.new("BlurEffect")
		blur.Size = 0
		blur.Parent = game:GetService("Lighting")
	end)
	local fov0 = cam and cam.FieldOfView or 70
	local function camFx(f, b, t, style, dir)
		if cam then pcall(function() tw(cam, t, { FieldOfView = f }, style, dir) end) end
		if blur then pcall(function() tw(blur, t, { Size = b }, style, dir) end) end
	end

	-- Rung màn hình
	local shakeAmt = 0
	local function kick(a) shakeAmt = math.max(shakeAmt, a) end

	local intro = mk("Frame", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 50, Active = true,
	}, gui)
	intro.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then skipIntro = true end
	end)

	-- Nền đen
	local backdrop = mk("Frame", {
		Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(3, 1, 9), BackgroundTransparency = 1,
		BorderSizePixel = 0, ZIndex = 1,
	}, intro)
	tw(backdrop, 0.5, { BackgroundTransparency = 0.08 })

	-- "world": mọi thứ nằm trong này để rung được
	local world = mk("Frame", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 5,
	}, intro)

	-- Vignette tối 4 mép cho có chiều sâu
	for _, v in ipairs({
		{ UDim2.new(1, 0, 0.3, 0), UDim2.fromScale(0, 0), Vector2.new(0, 0), 90 },
		{ UDim2.new(1, 0, 0.3, 0), UDim2.fromScale(0, 1), Vector2.new(0, 1), 270 },
		{ UDim2.new(0.22, 0, 1, 0), UDim2.fromScale(0, 0), Vector2.new(0, 0), 0 },
		{ UDim2.new(0.22, 0, 1, 0), UDim2.fromScale(1, 0), Vector2.new(1, 0), 180 },
	}) do
		local f = mk("Frame", {
			Size = v[1], Position = v[2], AnchorPoint = v[3], BackgroundColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0, ZIndex = 8,
		}, intro)
		mk("UIGradient", {
			Rotation = v[4],
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) }),
		}, f)
	end

	-- Hai dải đen điện ảnh trượt vào
	local barT = mk("Frame", {
		Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 70,
	}, intro)
	local barBt = mk("Frame", {
		AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 70,
	}, intro)
	tw(barT, 0.8, { Size = UDim2.new(1, 0, 0.09, 0) }, Enum.EasingStyle.Quint)
	tw(barBt, 0.8, { Size = UDim2.new(1, 0, 0.09, 0) }, Enum.EasingStyle.Quint)

	mk("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -6), Size = UDim2.fromOffset(240, 14),
		BackgroundTransparency = 1, Text = "chạm để bỏ qua", Font = Enum.Font.Code, TextSize = 10,
		TextColor3 = Color3.fromRGB(170, 130, 220), TextTransparency = 0.4, ZIndex = 80,
	}, intro)

	-- Quầng sáng sau logo
	local glows, gsz = {}, { 460, 340, 240 }
	for gi = 1, 3 do
		local gl = mk("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.42),
			Size = UDim2.fromOffset(gsz[gi] * BASE, gsz[gi] * BASE), BackgroundColor3 = (gi == 3) and PINK or VIOLET,
			BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 2,
		}, world)
		corner(gl, 600)
		local tr = ({ 0.94, 0.89, 0.84 })[gi]
		task.delay(1.3, function() if gl.Parent then tw(gl, 1.2, { BackgroundTransparency = tr }) end end)
		task.delay(2.6 + gi * 0.2, function()
			if gl.Parent and alive then loop(gl, 1.2 + gi * 0.3, { BackgroundTransparency = tr + 0.06 }, Enum.EasingStyle.Sine, true) end
		end)
		glows[gi] = gl
	end

	-- Sao + tia quét
	for i = 1, 30 do
		local sz = math.random(1, 3)
		local st = mk("Frame", {
			Size = UDim2.fromOffset(sz, sz), Position = UDim2.fromScale(math.random(), math.random()),
			BackgroundColor3 = (i % 3 == 0) and PINK or WHITE, BackgroundTransparency = 0.15, BorderSizePixel = 0, ZIndex = 3,
		}, world)
		corner(st, 2)
		loop(st, 0.5 + math.random() * 1.3, { BackgroundTransparency = 0.9 }, Enum.EasingStyle.Sine, true)
		tw(st, 10, { Position = UDim2.new(st.Position.X.Scale, 0, math.max(st.Position.Y.Scale - 0.25, -0.05), 0) }, Enum.EasingStyle.Linear)
	end
	local sweep = mk("Frame", {
		Size = UDim2.new(0, 2, 1, 0), BackgroundColor3 = VIOLET, BackgroundTransparency = 0.6, BorderSizePixel = 0, ZIndex = 3,
	}, world)
	loop(sweep, 2.4, { Position = UDim2.fromScale(1, 0) })

	-- Tàn lửa bay lên liên tục (nhiều hơn sau vụ nổ)
	local emberRate = 0.07
	task.spawn(function()
		while alive and not skipIntro do
			local sz = math.random(2, 5)
			local x = math.random()
			local e = mk("Frame", {
				Size = UDim2.fromOffset(sz, sz), Position = UDim2.new(x, 0, 1, 10), Rotation = math.random(0, 90),
				BackgroundColor3 = ({ VIOLET, PINK, GOLD, WHITE })[math.random(4)], BackgroundTransparency = 0.1,
				BorderSizePixel = 0, ZIndex = 4,
			}, world)
			local dur = math.random(25, 55) / 10
			tw(e, dur, {
				Position = UDim2.new(x, math.random(-70, 70), -0.05, 0), BackgroundTransparency = 1, Rotation = math.random(180, 540),
			}, Enum.EasingStyle.Sine)
			task.delay(dur + 0.1, function() e:Destroy() end)
			task.wait(emberRate)
		end
	end)

	-- ===== Lõi (ẩn cho đến khi chữ L giáng xuống) =====
	local core = mk("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.42), Size = UDim2.fromOffset(240, 240),
		BackgroundTransparency = 1, ZIndex = 10,
	}, world)
	local cs = mk("UIScale", { Scale = 0.01 }, core)

	-- Chữ L (nằm ngoài lõi để giáng xuống trước)
	local function makeL(col, z)
		return mk("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.42), Size = UDim2.fromOffset(70, 70),
			BackgroundTransparency = 1, Text = "L", Font = Enum.Font.GothamBlack, TextSize = 54, TextColor3 = col,
			TextTransparency = 1, ZIndex = z,
		}, world)
	end
	local L = makeL(WHITE, 12)
	mk("UIGradient", { Color = ColorSequence.new(WHITE, PINK), Rotation = 90 }, L)
	local ls = mk("UIScale", { Scale = 4 * BASE }, L)
	local gA, gB = makeL(PINK, 11), makeL(CYAN, 11)
	local gsA, gsB = mk("UIScale", { Scale = BASE }, gA), mk("UIScale", { Scale = BASE }, gB)
	local function glitchL()
		task.spawn(function()
			for _ = 1, 7 do
				local dx = math.random(4, 10) * BASE
				gA.Position = UDim2.new(0.5, dx, 0.42, math.random(-2, 2))
				gB.Position = UDim2.new(0.5, -dx, 0.42, math.random(-2, 2))
				gA.TextTransparency, gB.TextTransparency = 0.3, 0.3
				task.wait(0.04)
			end
			gA.TextTransparency, gB.TextTransparency = 1, 1
		end)
	end

	-- ===== Công cụ hiệu ứng =====
	local function flash(a, t, col)
		local fl = mk("Frame", {
			Size = UDim2.fromScale(1, 1), BackgroundColor3 = col or WHITE, BackgroundTransparency = a, BorderSizePixel = 0, ZIndex = 60,
		}, intro)
		tw(fl, t, { BackgroundTransparency = 1 })
		task.delay(t + 0.05, function() fl:Destroy() end)
	end

	local function wave(delay_, col, size, thick)
		task.delay(delay_, function()
			if not core.Parent then return end
			local w = mk("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(30, 30), BackgroundTransparency = 1,
			}, core)
			corner(w, 600)
			local ws = mk("UIStroke", { Color = col, Thickness = thick or 4 }, w)
			tw(w, 1, { Size = UDim2.fromOffset(size or 300, size or 300) }, Enum.EasingStyle.Quart)
			tw(ws, 1, { Transparency = 1, Thickness = 1 })
			task.delay(1.05, function() w:Destroy() end)
		end)
	end

	-- vệt năng lượng bị hút vào tâm
	local function streakIn(dur, r0)
		local a = math.random() * math.pi * 2
		local r = r0 or math.random(260, 420)
		local st = mk("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(math.random(40, 90), 2),
			Position = UDim2.new(0.5, math.cos(a) * r, 0.5, math.sin(a) * r), Rotation = math.deg(a),
			BackgroundColor3 = (math.random() > 0.5) and VIOLET or PINK, BorderSizePixel = 0, ZIndex = 6,
		}, core)
		mk("UIGradient", {
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }),
		}, st)
		tw(st, dur, { Position = UDim2.new(0.5, math.cos(a) * 18, 0.5, math.sin(a) * 18) }, Q, IN)
		task.delay(dur, function() st:Destroy() end)
	end

	-- vệt sáng bắn ra khi nổ
	local function streakOut()
		local a = math.random() * math.pi * 2
		local len = math.random(80, 200)
		local st = mk("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(len, math.random(2, 4)),
			Position = UDim2.new(0.5, math.cos(a) * 30, 0.5, math.sin(a) * 30), Rotation = math.deg(a),
			BackgroundColor3 = (math.random() > 0.4) and WHITE or PINK, BorderSizePixel = 0, ZIndex = 16,
		}, core)
		mk("UIGradient", {
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }),
		}, st)
		local d = math.random(300, 560)
		local dur = math.random(5, 9) / 10
		tw(st, dur, { Position = UDim2.new(0.5, math.cos(a) * d, 0.5, math.sin(a) * d), BackgroundTransparency = 1 }, Enum.EasingStyle.Quart)
		task.delay(dur + 0.05, function() st:Destroy() end)
	end

	-- tia sáng nan hoa
	local function rays(n, dist, len)
		n = n or 24
		for k = 0, n - 1 do
			local deg = k * (360 / n)
			local th = math.rad(deg)
			local ray = mk("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5), Rotation = deg + 90, Size = UDim2.fromOffset(3, 10),
				Position = UDim2.new(0.5, math.cos(th) * 45, 0.5, math.sin(th) * 45),
				BackgroundColor3 = (k % 2 == 0) and VIOLET or PINK, BorderSizePixel = 0, BackgroundTransparency = 0.05, ZIndex = 14,
			}, core)
			tw(ray, 0.9, {
				Size = UDim2.fromOffset(3, len or 60), BackgroundTransparency = 1,
				Position = UDim2.new(0.5, math.cos(th) * (dist or 200), 0.5, math.sin(th) * (dist or 200)),
			}, Enum.EasingStyle.Quart)
			task.delay(1, function() ray:Destroy() end)
		end
	end

	-- sét
	local function bolt()
		local a = math.random() * math.pi * 2
		local x1, y1 = math.cos(a) * 30, math.sin(a) * 30
		local r2 = math.random(150, 235)
		local x2, y2 = math.cos(a) * r2, math.sin(a) * r2
		local pts, n = { { x1, y1 } }, 6
		for i = 1, n - 1 do
			local t = i / n
			pts[#pts + 1] = { x1 + (x2 - x1) * t + math.random(-16, 16), y1 + (y2 - y1) * t + math.random(-16, 16) }
		end
		pts[#pts + 1] = { x2, y2 }
		for layer = 1, 2 do
			local col = (layer == 1) and PINK or WHITE
			local th = (layer == 1) and 5 or 2
			for i = 1, #pts - 1 do
				local p, q = pts[i], pts[i + 1]
				local dx, dy = q[1] - p[1], q[2] - p[2]
				local len = math.sqrt(dx * dx + dy * dy) + 2
				local seg = mk("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, (p[1] + q[1]) / 2, 0.5, (p[2] + q[2]) / 2),
					Size = UDim2.fromOffset(len, th), Rotation = math.deg(math.atan2(dy, dx)), BackgroundColor3 = col,
					BackgroundTransparency = (layer == 1) and 0.5 or 0, BorderSizePixel = 0, ZIndex = 15 + layer,
				}, core)
				tw(seg, 0.3, { BackgroundTransparency = 1, Size = UDim2.fromOffset(len, 0) })
				task.delay(0.35, function() seg:Destroy() end)
			end
		end
	end

	-- mảnh vỡ bay tung toé
	local function debris(n)
		for i = 1, n do
			local a = math.random() * math.pi * 2
			local d = math.random(160, 520) * BASE
			local s = math.random(4, 10)
			local p = mk("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(s, s), Position = UDim2.fromScale(0.5, 0.42),
				BackgroundColor3 = (i % 3 == 0) and WHITE or ((i % 2 == 0) and PINK or VIOLET), BorderSizePixel = 0,
				Rotation = math.random(0, 360), ZIndex = 14,
			}, world)
			local dur = math.random(8, 16) / 10
			tw(p, dur, {
				Position = UDim2.new(0.5, math.cos(a) * d, 0.42, math.sin(a) * d + math.random(20, 90)),
				Rotation = p.Rotation + math.random(-540, 540), BackgroundTransparency = 1, Size = UDim2.fromOffset(1, 1),
			}, Q)
			task.delay(dur + 0.05, function() p:Destroy() end)
		end
	end

	-- cột sáng phóng từ đáy màn hình
	local function pillars()
		for i = 1, 9 do
			local w = math.random(6, 18)
			local pl = mk("Frame", {
				AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale((i - 0.5) / 9, 1), Size = UDim2.new(0, w, 0, 0),
				BackgroundColor3 = (i % 2 == 0) and PINK or VIOLET, BorderSizePixel = 0, BackgroundTransparency = 0.1, ZIndex = 3,
			}, world)
			mk("UIGradient", {
				Rotation = 90,
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.15) }),
			}, pl)
			task.delay(math.abs(i - 5) * 0.04, function()
				tw(pl, 0.35, { Size = UDim2.new(0, w, 1.1, 0) }, Enum.EasingStyle.Quart)
				task.delay(0.35, function() tw(pl, 0.7, { BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1.1, 0) }) end)
				task.delay(1.15, function() pl:Destroy() end)
			end)
		end
	end

	-- vệt flare ngang kiểu phim
	local function flare()
		local f = mk("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.42), Size = UDim2.new(0, 0, 0, 3),
			BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 11,
		}, world)
		mk("UIGradient", {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1),
			}),
		}, f)
		tw(f, 0.5, { Size = UDim2.new(1.5, 0, 0, 3) }, Enum.EasingStyle.Quint)
		task.delay(0.35, function() tw(f, 0.6, { BackgroundTransparency = 1, Size = UDim2.new(1.5, 0, 0, 0) }) end)
		task.delay(1.1, function() f:Destroy() end)
	end

	-- 3 vòng cung xoay ngược chiều
	local RING_SIZES = { 220, 180, 140 }
	local rings = {}
	local function ring(size, thick, col, dur, rev)
		local r = mk("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1,
		}, core)
		corner(r, 300)
		local sk = mk("UIStroke", { Color = WHITE, Thickness = thick }, r)
		local g = mk("UIGradient", {
			Color = ColorSequence.new(col, VIOLET),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.4, 0.15),
				NumberSequenceKeypoint.new(0.6, 1), NumberSequenceKeypoint.new(1, 1),
			}),
		}, sk)
		loop(g, dur, { Rotation = rev and -360 or 360 })
		rings[#rings + 1] = r
	end
	ring(RING_SIZES[1], 2, PINK, 5, false)
	ring(RING_SIZES[2], 3, VIOLET, 3.5, true)
	ring(RING_SIZES[3], 2, Color3.fromRGB(230, 200, 255), 2.4, false)

	-- lục giác tự dựng từng cạnh
	local function hex(R, thick, col)
		local h = mk("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(R * 2, R * 2), BackgroundTransparency = 1,
		}, core)
		local ap = R * 0.866
		for i = 0, 5 do
			local th = math.rad(i * 60 - 90)
			local bar = mk("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, math.cos(th) * ap, 0.5, math.sin(th) * ap),
				Size = UDim2.fromOffset(0, thick), Rotation = i * 60, BackgroundColor3 = col, BorderSizePixel = 0,
			}, h)
			task.delay(0.1 + i * 0.07, function() tw(bar, 0.3, { Size = UDim2.fromOffset(R + 2, thick) }, B) end)
		end
		return h
	end

	-- 7 hạt quay quanh quỹ đạo elip
	local orbK = mk("NumberValue", { Value = 1 }, gui)
	local orbit = mk("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(0, 0),
		BackgroundTransparency = 1, Rotation = -22,
	}, core)
	local dots = {}
	for i = 1, 7 do
		dots[i] = mk("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(5, 5), BackgroundTransparency = 1,
			BackgroundColor3 = (i % 2 == 0) and PINK or WHITE, BorderSizePixel = 0,
		}, orbit)
		corner(dots[i], 3)
	end
	local conn = RunService.Heartbeat:Connect(function()
		local t = os.clock() - T0
		local grow = math.clamp((t - 1.4) / 0.6, 0, 1) * orbK.Value
		for i, d in ipairs(dots) do
			local a = t * 1.8 + i * (math.pi * 2 / #dots)
			local depth = (math.sin(a) + 1) / 2
			d.Position = UDim2.fromOffset(math.cos(a) * 105 * grow, math.sin(a) * 28 * grow)
			local sz = 3 + depth * 5
			d.Size = UDim2.fromOffset(sz, sz)
			d.BackgroundTransparency = 1 - math.min(1, grow) * (0.35 + depth * 0.65)
		end
		shakeAmt = shakeAmt * 0.88
		if shakeAmt < 0.2 then
			world.Position = UDim2.fromOffset(0, 0)
		else
			world.Position = UDim2.fromOffset((math.random() * 2 - 1) * shakeAmt, (math.random() * 2 - 1) * shakeAmt)
		end
	end)

	-- Chữ LONGRDEZ: từng chữ đập xuống
	local word, DEC = "LONGRDEZ", "01LRZX#<>/$%"
	local letters = {}
	for i = 1, #word do
		local lb = mk("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, (i - 4.5) * 24, 0.5, 28), Size = UDim2.fromOffset(24, 30),
			BackgroundTransparency = 1, Text = word:sub(i, i), Font = Enum.Font.GothamBlack, TextSize = 26, TextColor3 = WHITE, TextTransparency = 1,
		}, core)
		letters[i] = lb
		task.delay(1.9 + i * 0.09, function()
			if not alive then return end
			lb.TextColor3 = PINK
			tw(lb, 0.12, { TextTransparency = 0 })
			tw(lb, 0.5, { Position = UDim2.new(0.5, (i - 4.5) * 24, 0.5, 118) }, Enum.EasingStyle.Bounce, OUT)
			tw(lb, 0.9, { TextColor3 = WHITE })
			task.delay(0.28, function() if alive then kick(3) end end)
		end)
	end
	local sub = mk("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 142), Size = UDim2.fromOffset(260, 14), BackgroundTransparency = 1,
		Text = "K E Y   P O R T A L", Font = Enum.Font.Code, TextSize = 11, TextColor3 = VIOLET, TextTransparency = 1,
	}, core)
	task.delay(3.0, function() tw(sub, 0.6, { TextTransparency = 0 }) end)

	-- Thanh tiến trình 0 -> 100%
	local stat = mk("TextLabel", {
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0.5, -130, 0.5, 166), Size = UDim2.fromOffset(210, 14), BackgroundTransparency = 1,
		Text = "", Font = Enum.Font.Code, TextSize = 10, TextColor3 = VIOLET, TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1,
	}, core)
	local pctL = mk("TextLabel", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(0.5, 130, 0.5, 166), Size = UDim2.fromOffset(50, 14), BackgroundTransparency = 1,
		Text = "0%", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = WHITE, TextXAlignment = Enum.TextXAlignment.Right, TextTransparency = 1,
	}, core)
	local barB = mk("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 182), Size = UDim2.fromOffset(260, 4),
		BackgroundColor3 = Color3.fromRGB(34, 18, 64), BorderSizePixel = 0, BackgroundTransparency = 1,
	}, core)
	corner(barB, 2)
	local barF = mk("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0 }, barB)
	corner(barF, 2)
	mk("UIGradient", { Color = ColorSequence.new(PINK, VIOLET) }, barF)
	task.delay(2.4, function()
		tw(stat, 0.5, { TextTransparency = 0 })
		tw(pctL, 0.5, { TextTransparency = 0 })
		tw(barB, 0.5, { BackgroundTransparency = 0 })
	end)
	local STAGES = {
		{ 0, "KHỞI TẠO LÕI HỆ THỐNG" }, { 18, "NẠP MODULE ĐỒ HỌA" }, { 38, "QUÉT THIẾT BỊ" },
		{ 58, "KẾT NỐI MÁY CHỦ LONGRDEZ" }, { 78, "MÃ HÓA PHIÊN LÀM VIỆC" }, { 96, "SẴN SÀNG" },
	}
	local pv2 = mk("NumberValue", { Value = 0 }, gui)
	pv2.Changed:Connect(function(v)
		barF.Size = UDim2.fromScale(v / 100, 1)
		pctL.Text = math.floor(v + 0.5) .. "%"
		for i = #STAGES, 1, -1 do
			if v >= STAGES[i][1] then stat.Text = "> " .. STAGES[i][2] break end
		end
		stat.TextColor3 = (v >= 96) and Color3.fromRGB(0, 255, 170) or VIOLET
	end)
	tw(pv2, 9.2, { Value = 100 }, Enum.EasingStyle.Linear)

	-- ===== GIAI ĐOẠN 0 (0.2-1.3s): năng lượng từ mọi phía bị hút vào tâm =====
	task.spawn(function()
		task.wait(0.2)
		while alive and not skipIntro and os.clock() - T0 < 1.3 do
			local k = (os.clock() - T0) / 1.3
			for _ = 1, 1 + math.floor(k * 3) do streakIn(0.55) end
			task.wait(0.05)
		end
	end)

	-- ===== GIAI ĐOẠN 1: chữ L giáng xuống + VA CHẠM (1.0s -> 1.35s) =====
	at(1.0, function()
		tw(L, 0.3, { TextTransparency = 0 })
		tw(ls, 0.35, { Scale = BASE }, Enum.EasingStyle.Quint, IN)
	end)
	at(1.35, function()
		kick(18)
		flash(0.45, 0.5)
		camFx(fov0 - 10, 10, 0.08, Q, OUT)
		task.delay(0.1, function() camFx(fov0, 0, 0.7, Q, OUT) end)
		tw(cs, 0.7, { Scale = BASE }, B)
		wave(0, WHITE, 360, 6)
		wave(0.1, PINK, 300, 4)
		wave(0.2, VIOLET, 240, 3)
		rays(20, 160, 50)
		for _ = 1, 14 do streakOut() end
		debris(12)
		glitchL()
		loop(ls, 0.9, { Scale = BASE * 1.12 }, Enum.EasingStyle.Sine, true)
		loop(hex(60, 3, VIOLET), 12, { Rotation = 360 })
		loop(hex(38, 2, PINK), 8, { Rotation = -360 })
	end)

	-- ===== GIAI ĐOẠN 2 (2.8-6.6s): sét + sóng xung kích + glitch =====
	task.spawn(function()
		task.wait(2.8)
		while alive and not skipIntro and os.clock() - T0 < 6.6 do
			bolt()
			if math.random() > 0.55 then bolt() end
			kick(2.5)
			task.wait(math.random(35, 70) / 100)
		end
	end)
	task.spawn(function()
		task.wait(3.2)
		local k = 0
		while alive and not skipIntro and os.clock() - T0 < 6.6 do
			k = k + 1
			wave(0, (k % 2 == 0) and PINK or VIOLET, 320, 4)
			task.wait(1.1)
		end
	end)
	task.spawn(function()
		task.wait(3.6)
		while alive and not skipIntro and os.clock() - T0 < 8 do
			glitchL()
			for i, lb in ipairs(letters) do
				task.spawn(function()
					task.wait(i * 0.04)
					for _ = 1, 4 do
						local r = math.random(#DEC)
						lb.Text = DEC:sub(r, r)
						lb.TextColor3 = PINK
						task.wait(0.04)
					end
					lb.Text = word:sub(i, i)
					lb.TextColor3 = WHITE
				end)
			end
			task.wait(1.8)
		end
	end)

	-- ===== GIAI ĐOẠN 3 (6.8-7.9s): NÉN NĂNG LƯỢNG - zoom, mờ, rung tăng dần =====
	at(6.8, function()
		tw(orbK, 1.0, { Value = 0.2 }, Q, IN)
		for i, r in ipairs(rings) do
			tw(r, 1.0, { Size = UDim2.fromOffset(60 + i * 14, 60 + i * 14) }, Q, IN)
		end
		tw(ls, 1.0, { Scale = BASE * 1.6 }, Q, IN)
		for i, gl in ipairs(glows) do
			tw(gl, 1.0, { Size = UDim2.fromOffset(gsz[i] * BASE * 1.6, gsz[i] * BASE * 1.6), BackgroundTransparency = 0.7 }, Q, IN)
		end
		camFx(fov0 - 14, 8, 1.0, Q, IN)
		task.spawn(function()
			local t0 = os.clock()
			while alive and not skipIntro and os.clock() - T0 < 7.9 do
				local k = (os.clock() - t0) / 1.1
				kick(1 + k * 7)
				for _ = 1, 3 do streakIn(0.4, math.random(180, 380)) end
				task.wait(0.05)
			end
		end)
	end)

	-- ===== GIAI ĐOẠN 4 (7.9s): BÙNG NỔ =====
	at(7.9, function()
		flash(0, 1.0)
		kick(36)
		camFx(fov0 + 26, 30, 0.1, Q, OUT)
		task.delay(0.14, function() camFx(fov0, 0, 1.2, Q, OUT) end)
		wave(0, WHITE, 900, 9)
		wave(0.1, PINK, 740, 7)
		wave(0.2, VIOLET, 600, 5)
		wave(0.32, GOLD, 460, 3)
		rays(28, 240, 80)
		flare()
		pillars()
		debris(44)
		for _ = 1, 40 do streakOut() end
		tw(orbK, 0.8, { Value = 1.5 }, B)
		for i, r in ipairs(rings) do
			tw(r, 0.8, { Size = UDim2.fromOffset(RING_SIZES[i], RING_SIZES[i]) }, B)
		end
		tw(ls, 0.5, { Scale = BASE }, B)
		task.delay(0.6, function() if alive then loop(ls, 0.9, { Scale = BASE * 1.12 }, Enum.EasingStyle.Sine, true) end end)
		for i, gl in ipairs(glows) do
			gl.BackgroundTransparency = 0.45
			tw(gl, 1.2, { Size = UDim2.fromOffset(gsz[i] * BASE * 1.25, gsz[i] * BASE * 1.25), BackgroundTransparency = ({ 0.94, 0.89, 0.84 })[i] }, Q, OUT)
		end
		for _, lb in ipairs(letters) do
			lb.TextColor3 = PINK
			tw(lb, 0.9, { TextColor3 = WHITE })
		end
		glitchL()
		emberRate = 0.015
		task.delay(0.9, function() emberRate = 0.04 end)
		-- dư chấn
		task.spawn(function()
			for k = 1, 3 do
				task.wait(0.35)
				if not alive then return end
				kick(12 - k * 3)
				wave(0, (k % 2 == 0) and VIOLET or PINK, 380, 3)
			end
		end)
	end)

	-- Dải đen điện ảnh rút ra
	at(9.1, function()
		tw(barT, 0.4, { Size = UDim2.new(1, 0, 0, 0) })
		tw(barBt, 0.4, { Size = UDim2.new(1, 0, 0, 0) })
	end)

	-- ===== Kết thúc ở giây 9.5, thu logo vào trong 0.5s => tổng đúng 10 giây =====
	waitUntil(9.5)
	alive = false
	conn:Disconnect()
	world.Position = UDim2.fromOffset(0, 0)
	camFx(fov0, 0, 0.3, Q, OUT)
	tw(cs, 0.5, { Scale = 0.15 }, B, IN)
	tw(ls, 0.5, { Scale = 0.1 }, B, IN)
	tw(L, 0.4, { TextTransparency = 1 })
	tw(backdrop, 0.5, { BackgroundTransparency = 1 })
	tw(barT, 0.3, { Size = UDim2.new(1, 0, 0, 0) })
	tw(barBt, 0.3, { Size = UDim2.new(1, 0, 0, 0) })
	tw(sweep, 0.3, { BackgroundTransparency = 1 })
	for _, gl in ipairs(glows) do tw(gl, 0.4, { BackgroundTransparency = 1 }) end
	task.wait(0.5)
	intro:Destroy()
	orbK:Destroy()
	pv2:Destroy()
	if blur then pcall(function() blur:Destroy() end) end
	if cam then pcall(function() cam.FieldOfView = fov0 end) end
end

-- ##################### PHẦN 1: MENU KEY BÁ KHÍ #####################
local WHT = Color3.new(1, 1, 1)
local GRNC = Color3.fromRGB(0, 255, 170)
local CYN = Color3.fromRGB(0, 240, 255)
local HEXS = "0123456789ABCDEF"

-- Nền sống động trong cửa sổ: lưới trôi, radar xoay, dòng hex 2 bên, xung từ tâm
local function menuAmbient()
	-- 7 đường lưới ngang trôi lên liên tục
	for i = 1, 7 do
		task.spawn(function()
			local ln = mk("Frame", {
				Size = UDim2.new(1, 0, 0, 1), Position = UDim2.fromScale(0, i / 7), BackgroundColor3 = VIOLET,
				BackgroundTransparency = 0.88, BorderSizePixel = 0, ZIndex = 0,
			}, main)
			mk("UIGradient", { Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1),
			}) }, ln)
			local y = i / 7
			while gui.Parent do
				tw(ln, y * 7, { Position = UDim2.fromScale(0, 0) }, Enum.EasingStyle.Linear)
				task.wait(y * 7)
				ln.Position = UDim2.fromScale(0, 1)
				y = 1
			end
		end)
	end

	-- 2 vòng radar mờ xoay ngược chiều sau tiêu đề
	for i, sz in ipairs({ 300, 220 }) do
		local r = mk("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(sz, sz),
			BackgroundTransparency = 1, ZIndex = 0,
		}, main)
		corner(r, 400)
		local sk = mk("UIStroke", { Color = WHT, Thickness = 2, Transparency = 0.55 }, r)
		local g = mk("UIGradient", {
			Color = ColorSequence.new((i == 1) and VIOLET or PINK, VIOLET),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.3, 0.2),
				NumberSequenceKeypoint.new(0.5, 1), NumberSequenceKeypoint.new(1, 1),
			}),
		}, sk)
		loop(g, 5 + i * 2, { Rotation = (i == 1) and 360 or -360 })
	end

	-- cột mã hex chạy 2 bên mép
	for side = 0, 1 do
		local lb = mk("TextLabel", {
			Position = UDim2.new(side, side == 0 and 5 or -37, 0, 52), Size = UDim2.fromOffset(32, 190), BackgroundTransparency = 1,
			Font = Enum.Font.Code, TextSize = 9, TextColor3 = VIOLET, TextTransparency = 0.6, ZIndex = 0,
			TextYAlignment = Enum.TextYAlignment.Top, TextXAlignment = (side == 0) and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right, Text = "",
		}, main)
		task.spawn(function()
			while gui.Parent do
				local t = {}
				for i = 1, 16 do
					local a, b, c = math.random(16), math.random(16), math.random(16)
					t[i] = HEXS:sub(a, a) .. HEXS:sub(b, b) .. HEXS:sub(c, c) .. HEXS:sub(a, a)
				end
				lb.Text = table.concat(t, "\n")
				task.wait(0.12)
			end
		end)
	end

	-- xung sóng từ tâm mỗi 2.6 giây
	task.spawn(function()
		while gui.Parent do
			task.wait(2.6)
			local w = mk("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(20, 20),
				BackgroundTransparency = 1, ZIndex = 0,
			}, main)
			corner(w, 600)
			local ws = mk("UIStroke", { Color = VIOLET, Thickness = 2, Transparency = 0.3 }, w)
			tw(w, 1.6, { Size = UDim2.fromOffset(420, 420) }, Enum.EasingStyle.Quart)
			tw(ws, 1.6, { Transparency = 1 })
			task.delay(1.7, function() w:Destroy() end)
		end
	end)
end

-- Màn hiện menu: vạch sáng -> mở dọc -> sóng xung kích + khung góc lao vào + tiêu đề giải mã
local function menuReveal()
	main.Size = UDim2.fromOffset(0, 2)
	main.GroupTransparency = 0

	local hb = mk("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(0, 3),
		BackgroundColor3 = WHT, BorderSizePixel = 0, ZIndex = 6,
	}, gui)
	mk("UIGradient", {
		Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, VIOLET), ColorSequenceKeypoint.new(0.5, WHT), ColorSequenceKeypoint.new(1, PINK) }),
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) }),
	}, hb)
	tw(hb, 0.4, { Size = UDim2.fromOffset(700, 3) }, Enum.EasingStyle.Quint)
	task.wait(0.25)
	tw(main, 0.35, { Size = UDim2.fromOffset(360, 2) }, Enum.EasingStyle.Quint)
	task.wait(0.35)
	tw(hb, 0.4, { BackgroundTransparency = 1 })
	tw(main, 0.55, { Size = UDim2.fromOffset(360, 256) }, Enum.EasingStyle.Back)

	-- chớp + 3 sóng xung kích
	local fl = mk("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHT, BackgroundTransparency = 0.7, BorderSizePixel = 0, ZIndex = 4 }, gui)
	tw(fl, 0.5, { BackgroundTransparency = 1 })
	task.delay(0.6, function() fl:Destroy() end)
	for k, col in ipairs({ WHT, PINK, VIOLET }) do
		task.delay((k - 1) * 0.1, function()
			local w = mk("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(20, 20),
				BackgroundTransparency = 1, ZIndex = 5,
			}, gui)
			corner(w, 900)
			local s = mk("UIStroke", { Color = col, Thickness = 5 }, w)
			tw(w, 0.9, { Size = UDim2.fromOffset(620, 620) }, Enum.EasingStyle.Quart)
			tw(s, 0.9, { Transparency = 1, Thickness = 1 })
			task.delay(0.95, function() w:Destroy() end)
		end)
	end

	-- 4 khung góc lao vào, thở nhẹ rồi tan
	local brs = {}
	for _, sx in ipairs({ -1, 1 }) do
		for _, sy in ipairs({ -1, 1 }) do
			local ax, ay = (sx < 0) and 0 or 1, (sy < 0) and 0 or 1
			local br = mk("Frame", {
				AnchorPoint = Vector2.new(ax, ay), Size = UDim2.fromOffset(30, 30), BackgroundTransparency = 1, ZIndex = 5,
				Position = UDim2.new(0.5, sx * 420, 0.5, sy * 320),
			}, gui)
			mk("Frame", {
				AnchorPoint = Vector2.new(ax, ay), Position = UDim2.fromScale(ax, ay), Size = UDim2.new(1, 0, 0, 2),
				BackgroundColor3 = (sx == sy) and VIOLET or PINK, BorderSizePixel = 0,
			}, br)
			mk("Frame", {
				AnchorPoint = Vector2.new(ax, ay), Position = UDim2.fromScale(ax, ay), Size = UDim2.new(0, 2, 1, 0),
				BackgroundColor3 = (sx == sy) and VIOLET or PINK, BorderSizePixel = 0,
			}, br)
			tw(br, 0.6, { Position = UDim2.new(0.5, sx * 190, 0.5, sy * 138) }, Enum.EasingStyle.Back)
			brs[#brs + 1] = br
		end
	end
	task.delay(2.4, function()
		for _, br in ipairs(brs) do
			for _, f in ipairs(br:GetChildren()) do tw(f, 0.5, { BackgroundTransparency = 1 }) end
			task.delay(0.6, function() br:Destroy() end)
		end
	end)
	task.delay(0.9, function() hb:Destroy() end)

	menuAmbient()

	-- tiêu đề giải mã: ký tự nhiễu -> chữ thật từ trái sang phải
	task.spawn(function()
		local final, noise = "LONGRDEZ HUB", "01LRZX#<>/$%&@"
		for step = 1, #final + 6 do
			local s = ""
			for i = 1, #final do
				local c = final:sub(i, i)
				if c == " " or i <= step - 5 then
					s = s .. c
				else
					local r = math.random(#noise)
					s = s .. noise:sub(r, r)
				end
			end
			title.Text = s
			task.wait(0.05)
		end
		title.Text = final
	end)
end

-- Gõ phím: viền nháy + tia lửa; key đúng => viền xanh ngọc
do
	local function spark(x, y, col)
		local sp = mk("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(4, 4),
			BackgroundColor3 = col, BorderSizePixel = 0, ZIndex = 5,
		}, keyPage)
		corner(sp, 2)
		tw(sp, 0.45, {
			Position = UDim2.fromOffset(x + math.random(-26, 26), y + math.random(-6, 20)),
			BackgroundTransparency = 1, Size = UDim2.fromOffset(1, 1),
		}, Enum.EasingStyle.Quad)
		task.delay(0.5, function() sp:Destroy() end)
	end
	box:GetPropertyChangedSignal("Text"):Connect(function()
		tw(boxStroke, 0.06, { Thickness = 3.5 })
		task.delay(0.08, function() tw(boxStroke, 0.2, { Thickness = 2 }) end)
		local okk = checkKey(box.Text)
		boxStroke.Color = okk and GRNC or VIOLET
		local x = 20 + math.min(box.AbsoluteSize.X - 12, box.TextBounds.X + 16)
		for _ = 1, 4 do spark(x, 19, okk and GRNC or ((math.random() > 0.5) and PINK or VIOLET)) end
	end)

	-- viền gradient xoay quanh 2 nút
	for _, b in ipairs({ getBtn, chkBtn }) do
		local s = mk("UIStroke", { Color = WHT, Thickness = 2 }, b)
		local g = mk("UIGradient", { Color = ColorSequence.new((b == chkBtn) and PINK or CYN, VIOLET) }, s)
		loop(g, 2.2, { Rotation = 360 })
	end
end

-- Trang loading: tia quét trong terminal + ping & tia lửa ở đầu thanh tiến trình
do
	term.ClipsDescendants = true
	local sc = mk("Frame", {
		Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = VIOLET, BackgroundTransparency = 0.55, BorderSizePixel = 0, ZIndex = 5,
	}, term)
	loop(sc, 1.6, { Position = UDim2.new(0, 0, 1, 0) })

	local _setProgress = setProgress
	setProgress = function(p, label)
		_setProgress(p, label)
		task.spawn(function()
			local ping = mk("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(p / 100, 0.5), Size = UDim2.fromOffset(12, 12),
				BackgroundTransparency = 1, ZIndex = 4,
			}, barBg)
			corner(ping, 30)
			local ps = mk("UIStroke", { Color = (p >= 100) and GRNC or PINK, Thickness = 2 }, ping)
			tw(ping, 0.6, { Size = UDim2.fromOffset(44, 44) })
			tw(ps, 0.6, { Transparency = 1 })
			task.delay(0.65, function() ping:Destroy() end)
			for _ = 1, 5 do
				local sp = mk("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(p / 100, 0.5), Size = UDim2.fromOffset(3, 3),
					BackgroundColor3 = (math.random() > 0.5) and WHT or PINK, BorderSizePixel = 0, ZIndex = 4,
				}, barBg)
				tw(sp, 0.5, { Position = UDim2.new(p / 100, math.random(-22, 22), 0.5, math.random(-18, 18)), BackgroundTransparency = 1 })
				task.delay(0.55, function() sp:Destroy() end)
			end
		end)
	end
end


-- ##################### PHẦN 2: NỔ VÀO SCRIPT BÁ KHÍ+ #####################
-- Chạy SONG SONG với epicEnter (bản trước hoặc bản gốc): thêm vòng thoi, xoắn ốc thiên hà,
-- mưa cột sáng, viền màn hình bùng cháy, chữ LONGRDEZ khổng lồ đập xuống, nổ lần 2.
local _epicBase = epicEnter
epicEnter = function()
	task.spawn(function()
		local cam = workspace.CurrentCamera
		local vw = (cam and cam.ViewportSize.X) or 700
		local S = math.clamp(vw / 700, 0.6, 1.25)
		local GOLD = Color3.fromRGB(255, 196, 90)
		local pi, rnd = math.pi, math.random
		local alive = true
		local fx = mk("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 140 }, gui)
		local c = mk("Frame", { Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1, ZIndex = 141 }, fx)
		mk("UIScale", { Scale = S }, c)
		local function later(t, fn)
			task.delay(t, function() if alive and fx.Parent then fn() end end)
		end

		-- vòng thoi (hình thoi) nở ra / co vào
		local function diamond(s0, s1, col, thick, dur, easeDir)
			local d = mk("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(s0, s0), Rotation = 45, BackgroundTransparency = 1, ZIndex = 142,
			}, c)
			local st = mk("UIStroke", { Color = col, Thickness = thick }, d)
			tw(d, dur, { Size = UDim2.fromOffset(s1, s1), Rotation = 45 + (easeDir == Enum.EasingDirection.In and -90 or 90) }, Enum.EasingStyle.Quart, easeDir)
			tw(st, dur, { Transparency = 1, Thickness = 1 })
			task.delay(dur + 0.05, function() d:Destroy() end)
		end

		-- 3.0-3.9s: thoi co vào hút năng lượng
		task.spawn(function()
			task.wait(3.0)
			local t0 = os.clock()
			while alive and fx.Parent and os.clock() - t0 < 0.9 do
				diamond(700, 40, (rnd() > 0.5) and PINK or CYN, 3, 0.5, Enum.EasingDirection.In)
				task.wait(0.11)
			end
		end)

		-- 3.9s: NỔ
		later(3.9, function()
			for k = 1, 4 do
				task.delay(k * 0.09, function()
					if fx.Parent then diamond(40, 1100 + k * 100, ({ WHT, PINK, CYN, GOLD })[k], 6 - k, 0.9, Enum.EasingDirection.Out) end
				end)
			end

			-- xoắn ốc thiên hà: 3 nhánh x 18 hạt
			for arm = 0, 2 do
				for i = 1, 18 do
					local a = arm * (2 * pi / 3) + i * 0.26
					local r = (30 + i * 30) * 1.1
					local sz = math.max(2, math.floor(8 - i * 0.3))
					local p = mk("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(sz, sz),
						BackgroundColor3 = ({ WHT, PINK, VIOLET, CYN })[(i % 4) + 1], BorderSizePixel = 0, ZIndex = 143,
					}, c)
					corner(p, 4)
					task.delay(i * 0.018, function()
						if not p.Parent then return end
						tw(p, 0.9, { Position = UDim2.fromOffset(math.cos(a) * r, math.sin(a) * r) }, Enum.EasingStyle.Quart)
						task.delay(0.4, function() tw(p, 0.7, { BackgroundTransparency = 1 }) end)
					end)
					task.delay(1.5, function() p:Destroy() end)
				end
			end

			-- mưa cột sáng rơi từ trên xuống
			for i = 1, 16 do
				local w = rnd(3, 9)
				local col = mk("Frame", {
					AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale((i - 0.5) / 16, -0.05), Size = UDim2.new(0, w, 0.5, 0),
					BackgroundColor3 = (i % 2 == 0) and PINK or VIOLET, BorderSizePixel = 0, ZIndex = 141,
				}, fx)
				mk("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }) }, col)
				task.delay(rnd(0, 30) / 100, function()
					tw(col, 0.7, { Position = UDim2.fromScale((i - 0.5) / 16, 1.6) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
				end)
				task.delay(1.2, function() col:Destroy() end)
			end

			-- viền màn hình bùng cháy
			local edge = mk("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 144 }, fx)
			local es = mk("UIStroke", { Color = WHT, Thickness = 36 }, edge)
			mk("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, PINK), ColorSequenceKeypoint.new(0.5, WHT), ColorSequenceKeypoint.new(1, VIOLET) }) }, es)
			tw(es, 1.2, { Thickness = 0, Transparency = 1 }, Enum.EasingStyle.Quart)
			task.delay(1.3, function() edge:Destroy() end)
		end)

		-- 4.1s: chữ LONGRDEZ khổng lồ đập xuống từng chữ (tách màu RGB)
		local word = "LONGRDEZ"
		local STEP = 50
		for i = 1, #word do
			local x = (i - (#word + 1) / 2) * STEP
			local function lbl(col, z)
				return mk("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x, -10), Size = UDim2.fromOffset(52, 70),
					BackgroundTransparency = 1, Text = word:sub(i, i), Font = Enum.Font.GothamBlack, TextSize = 58,
					TextColor3 = col, TextTransparency = 1, ZIndex = z,
				}, c)
			end
			local m, ga, gb = lbl(WHT, 150), lbl(PINK, 148), lbl(CYN, 148)
			local sc = mk("UIScale", { Scale = 3 }, m)
			mk("UIGradient", { Color = ColorSequence.new(WHT, Color3.fromRGB(230, 190, 255)), Rotation = 90 }, m)
			later(4.1 + i * 0.05, function()
				tw(m, 0.08, { TextTransparency = 0 })
				tw(sc, 0.25, { Scale = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
				task.delay(0.25, function()
					if not fx.Parent then return end
					ga.TextTransparency, gb.TextTransparency = 0.25, 0.25
					ga.Position = UDim2.fromOffset(x + 8, -10)
					gb.Position = UDim2.fromOffset(x - 8, -10)
					tw(ga, 0.5, { TextTransparency = 1, Position = UDim2.fromOffset(x, -10) })
					tw(gb, 0.5, { TextTransparency = 1, Position = UDim2.fromOffset(x, -10) })
					local w = mk("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x, 30), Size = UDim2.fromOffset(10, 4),
						BackgroundColor3 = GOLD, BorderSizePixel = 0, ZIndex = 147,
					}, c)
					tw(w, 0.35, { Size = UDim2.fromOffset(70, 1), BackgroundTransparency = 1 })
					task.delay(0.4, function() w:Destroy() end)
				end)
			end)
			later(5.15, function() tw(m, 0.35, { TextTransparency = 1 }) end)
		end

		-- 4.6s: nổ lần 2 (vàng)
		later(4.6, function()
			local fl = mk("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = GOLD, BackgroundTransparency = 0.6, BorderSizePixel = 0, ZIndex = 160 }, fx)
			tw(fl, 0.5, { BackgroundTransparency = 1 })
			diamond(60, 900, GOLD, 5, 0.8, Enum.EasingDirection.Out)
			diamond(60, 700, WHT, 3, 0.7, Enum.EasingDirection.Out)
		end)

		task.wait(5.7)
		alive = false
		fx:Destroy()
	end)
	_epicBase()
end

-- ===== Chuỗi khởi động =====
task.spawn(function()
	playIntro()
	makeLogo()
	main.Visible = true
	dumpGuis()
	menuReveal()
	task.wait(1.2)
	show(bootPage)
	local saved = readSaved()
	local valid = saved and checkKey(saved)

	typeLine("Khởi tạo giao thức bảo mật...", SOFT)  setProgress(15, "KHỞI TẠO")
	typeLine("Đang lấy HWID thiết bị...", SOFT)       setProgress(32, "NHẬN DIỆN THIẾT BỊ")
	typeLine("Kết nối Server LONGRDEZ... OK", GREEN)  setProgress(50, "KẾT NỐI")
	typeLine("Nạp module giao diện...", SOFT)         setProgress(68, "NẠP MODULE")
	typeLine("Kiểm tra key đã lưu...", SOFT)          setProgress(85, "XÁC THỰC")
	task.wait(0.3)
	if valid then
		typeLine("Phát hiện key còn hạn - tự động mở khóa!", GREEN)
		setProgress(100, "SẴN SÀNG")
		task.wait(0.6)
		download()
	else
		typeLine("Chưa có key hợp lệ - yêu cầu xác thực.", "#ffcc00")
		setProgress(100, "SẴN SÀNG")
		task.wait(0.6)
		show(keyPage)
	end
end)
