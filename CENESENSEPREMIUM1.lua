-- ═══════════════════════════════════════════════ --
-- memesense31.lua - MYLF MENU ESP FULL DETECT + REMNANTS FIX | Efendim için özel, Tüm Oyuncular + No Ghost <3
-- ═══════════════════════════════════════════════ --
-- Zaten yüklendiyse tekrar yükleme (anti-duplicate)

local Services = {
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    Workspace = game:GetService("Workspace"),
    Camera = workspace.CurrentCamera,
    Players = game:GetService("Players"),
    LocalPlayer = game.Players.LocalPlayer,
    Teams = game:GetService("Teams"),
    TweenService = game:GetService("TweenService"),
    HttpService = game:GetService("HttpService"),
    Stats = game:GetService("Stats"),
    TeleportService = game:GetService("TeleportService")
}
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
-- Yüklenme ekranını 15 saniye uzat (efendim için özel gecikme)
task.wait(2)
local Window = Rayfield:CreateWindow({
    Name = "CENESENSE",
    LoadingTitle = "CENESENSE Yüklüyor...",
    LoadingSubtitle = "Version 1.3.10c",
    Duration = 1,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MYLFMenu",
        FileName = "memesense31"
    },
    KeySystem = false
})
Rayfield:Notify({
    Title = "CENESENSE | PREMIUM",
    Content = "Version 1.3.10c",
    Duration = 1,
    Image = 4483362458
})
-- Features'i external linkten yükle (bağlam uyumlu, error handling ile – hata verirse inline fallback)
local success, features = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features1.5.5reall.lua"))()
end)
if not success or not features or type(features) ~= "table" then
    Rayfield:Notify({
        Title = "Features Load Error",
        Content = "External features yüklenemedi veya dönmedi, inline fallback kullanılıyor.",
        Duration = 5
    })
    -- Inline fallback (snippet'ten uyarlandı, bağlam aynı) - 0MS için: Throttles low
    features = {}
    features.ToggleSpeed = function(on)
        getgenv().ToggleSpeed = on
        local char = Services.LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char.Humanoid.WalkSpeed = on and (features._walkSpeed or 50) or 16
        end
    end
    features.ToggleFly = function(on)
        getgenv().ToggleFly = on
        local char = Services.LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local root = char.HumanoidRootPart
        local bv = root:FindFirstChild("FlyBV")
        if on then
            if bv then bv:Destroy() end
            bv = Instance.new("BodyVelocity")
            bv.Name = "FlyBV"
            bv.MaxForce = Vector3.new(4000, 4000, 4000)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = root
            local conn = Services.RunService.Heartbeat:Connect(function()
                if not getgenv().ToggleFly then conn:Disconnect() return end
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.LControl) then
                    local cam = Services.Camera.CFrame
                    bv.Velocity = cam.LookVector * (features._flySpeed or 50) + cam.UpVector * (Services.UserInputService:IsKeyDown(Enum.KeyCode.Space) and (features._flySpeed or 50) or Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and -(features._flySpeed or 50) or 0)
                else
                    bv.Velocity = Vector3.new(0, 0, 0)
                end
            end)
        else
            if bv then bv:Destroy() end
        end
    end
    features.ToggleInfiniteJump = function(on, jumpPower)
    getgenv().ToggleInfiniteJump = on  -- Orijinal global set'i korudum
    jumpPower = jumpPower or 100  -- Default jump gücü 100 (yüksek zıplama için)
    local defaultJumpPower = 50  -- Roblox default JumpPower
    
    if on then
        -- Önceki bağlantıyı temizle (eğer varsa)
        if getgenv()._infJumpConn then
            getgenv()._infJumpConn:Disconnect()
            getgenv()._infJumpConn = nil
        end
        
        getgenv()._infJumpConn = Services.UserInputService.JumpRequest:Connect(function()
            local char = Services.LocalPlayer.Character
            local h = char and char:FindFirstChildOfClass("Humanoid")
            if h then
                h:ChangeState(Enum.HumanoidStateType.Jumping)
                -- JumpPower'ı uygula (her jump'ta refresh için)
                if h.JumpPower ~= jumpPower then
                    h.JumpPower = jumpPower
                end
            end
        end)
        
        -- İlk başta JumpPower'ı da set et
        local char = Services.LocalPlayer.Character
        local h = char and char:FindFirstChildOfClass("Humanoid")
        if h then
            h.JumpPower = jumpPower
        end
    else
        -- Kapatırken bağlantıyı kes ve JumpPower'ı default'a döndür
        if getgenv()._infJumpConn then
            getgenv()._infJumpConn:Disconnect()
            getgenv()._infJumpConn = nil
        end
        local char = Services.LocalPlayer.Character
        local h = char and char:FindFirstChildOfClass("Humanoid")
        if h then
            h.JumpPower = defaultJumpPower
        end
    end
end
    
    features.ToggleHardInvisible = function(on)
        getgenv().ToggleHardInvisible = on
        local char = Services.LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = on and 1 or 0
                end
            end
        end
    end
    features.ToggleNoclip = function(on)
        getgenv().ToggleNoclip = on
        local conn
        if on then
            conn = Services.RunService.Stepped:Connect(function()
                local char = Services.LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        end
    end
    features.ToggleTeleport = function(on)
        getgenv().ToggleTeleport = on
        local conn
        if on then
            conn = Services.UserInputService.InputBegan:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.T then
                    local char = Services.LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(features._tpX or 0, features._tpY or 0, features._tpZ or 25)
                    end
                end
            end)
        end
    end
    features.ToggleAutoBehind = function(on)
        getgenv().ToggleAutoBehind = on
        coroutine.wrap(function()
            while getgenv().ToggleAutoBehind do
                local nearest = getNearest()
                if nearest and nearest.Character and nearest.Character:FindFirstChild("HumanoidRootPart") then
                    local myRoot = Services.LocalPlayer.Character and Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if myRoot then
                        myRoot.CFrame = nearest.Character.HumanoidRootPart.CFrame * CFrame.new(features._tpX or 0, features._tpY or 0, -(features._tpZ or 25))
                    end
                end
                task.wait(0.05) -- 0MS smooth, low throttle
            end
        end)()
    end
    features.ToggleAutoTeleportToEnemy = function(on)
        getgenv().ToggleAutoTeleportToEnemy = on
        coroutine.wrap(function()
            while getgenv().ToggleAutoTeleportToEnemy do
                local nearest = getNearest()
                if nearest and nearest.Character and nearest.Character:FindFirstChild("HumanoidRootPart") then
                    local myRoot = Services.LocalPlayer.Character and Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if myRoot then
                        myRoot.CFrame = nearest.Character.HumanoidRootPart.CFrame * CFrame.new(features._tpX or 0, features._tpY or 0, features._tpZ or 25)
                    end
                end
                task.wait(0.1) -- 0MS smooth, low throttle
            end
        end)()
    end
    features.SetWalkSpeed = function(val)
        getgenv()._walkSpeed = val
        local char = Services.LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char.Humanoid.WalkSpeed = val
        end
    end
    features.SetFlySpeed = function(val)
        getgenv()._flySpeed = val
    end
    features.SetTeleportOffset = function(x, y, z)
        getgenv()._tpX = x
        getgenv()._tpY = y
        getgenv()._tpZ = z
    end
    -- YENİ: SYNC Emote Fallback (yakındaki oyunculara emote kopyala, throttle'lı)
    features.ToggleSYNC = function(on)
        getgenv().EmoteSYNC = on
        if on then
            coroutine.wrap(function()
                while getgenv().EmoteSYNC do
                    if getgenv().CurrentEmoteTrack then
                        local myId = getgenv().CurrentEmoteTrack.Animation.AnimationId
                        for _, plr in ipairs(Services.Players:GetPlayers()) do
                            if plr ~= Services.LocalPlayer and plr.Character and (plr.Character.HumanoidRootPart.Position - Services.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 50 then
                                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                                if hum then
                                    local anim = Instance.new("Animation")
                                    anim.AnimationId = myId
                                    local track = hum:LoadAnimation(anim)
                                    track:Play()
                                    anim:Destroy()
                                end
                            end
                        end
                    end
                    task.wait(2) -- Throttle: Her 2s sync, spam önle
                end
            end)()
        end
    end
    -- FALLBACK İÇİN VISUAL FEATURES (boş/no-op, hata vermesin – external gelmezse çalışmasın ama crash olmasın)
    features.ToggleSkeleton = function(on)
        -- Basit skeleton ESP placeholder (gerçek implement external'da)
        print("ToggleSkeleton: " .. tostring(on) .. " (Fallback mode)")
    end
    features.ToggleBox = function(on)
        print("ToggleBox: " .. tostring(on) .. " (Fallback mode)")
    end
    features.ToggleRainbowName = function(on)
        print("ToggleRainbowName: " .. tostring(on) .. " (Fallback mode)")
    end
    features.ToggleTracers = function(on)
        print("ToggleTracers: " .. tostring(on) .. " (Fallback mode)")
    end
    features.ToggleGlow = function(on)
        print("ToggleGlow: " .. tostring(on) .. " (Fallback mode)")
    end
    features._walkSpeed = 16
    features._flySpeed = 50
    features._tpX = 0
    features._tpY = 0
    features._tpZ = 25
end
-- Custom FPS HUD Panel (Efendim'in örneğinden tam uyarlandı – Modern, dinamik, rainbow bar'lı) - Optimized: Grad update slowed
local PlayerGui = Services.LocalPlayer:WaitForChild("PlayerGui")
local Overlay = Instance.new("ScreenGui")
Overlay.Name = "MYLF_HUD"
Overlay.IgnoreGuiInset = true
Overlay.ResetOnSpawn = false
Overlay.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Overlay.Parent = game:GetService("CoreGui") -- CoreGui için, anti-detect
-- Yardımcı Fonksiyonlar (Örnekten uyarlandı)
local function round(num, digits)
    local mult = 10 ^ (digits or 0)
    return math.floor(num * mult + 0.5) / mult
end
local function pad(frame, size)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, size)
    padding.PaddingBottom = UDim.new(0, size)
    padding.PaddingLeft = UDim.new(0, size)
    padding.PaddingRight = UDim.new(0, size)
    padding.Parent = frame
end
local function makeStroke(frame, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness
    stroke.Transparency = transparency
    stroke.Color = Color3.fromRGB(255, 255, 255) -- Sabit accent
    stroke.Parent = frame
    return stroke -- Dönüş eklendi, CPS için
end
local function makeCorner(frame, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = frame
end
-- Global Theme Color (Başlangıç berry rengi: #990F4B, RGB 153,15,75)
getgenv().ThemeColor = Color3.fromRGB(153, 15, 75)
-- Panel Oluştur
local CrownPanel = Instance.new("Frame")
CrownPanel.AnchorPoint = Vector2.new(0.5, 0)
CrownPanel.Position = UDim2.new(0.5, 0, 0, 8)
CrownPanel.Size = UDim2.fromOffset(300, 26)
CrownPanel.BackgroundColor3 = getgenv().ThemeColor -- Theme'e bağlandı
CrownPanel.Parent = Overlay
pad(CrownPanel, 4)
local cps = makeStroke(CrownPanel, 1, 0.15)
cps.Color = getgenv().ThemeColor -- Stroke'u theme'e eşle
makeCorner(CrownPanel, 8)
local CrownText = Instance.new("TextLabel")
CrownText.BackgroundTransparency = 1
CrownText.Font = Enum.Font.GothamSemibold
CrownText.TextSize = 12
CrownText.TextXAlignment = Enum.TextXAlignment.Center
CrownText.TextColor3 = Color3.fromRGB(255, 255, 255) -- Sabit text
CrownText.Size = UDim2.new(1, -10, 1, -8)
CrownText.Position = UDim2.fromOffset(5, 0)
CrownText.Text = "FPS: 60 | Ping: ? | CPU: 0 ms | GPU: 0 ms | Live: 0"
CrownText.Parent = CrownPanel
local RainbowBar = Instance.new("Frame")
RainbowBar.BorderSizePixel = 0
RainbowBar.AnchorPoint = Vector2.new(0.5, 1)
RainbowBar.Position = UDim2.new(0.5, 0, 1, 0)
RainbowBar.Size = UDim2.new(1, -6, 0, 3)
RainbowBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
RainbowBar.Parent = CrownPanel
makeCorner(RainbowBar, 2)
local grad = Instance.new("UIGradient", RainbowBar)
-- Live API (Örnekten tam alındı – HWID'li, heartbeat/active) - Ping fix: Slower intervals
local exec = identifyexecutor and identifyexecutor() or "UnknownExec"
local realHWID = gethwid and gethwid() or "UnknownHWID"
local PC_HWID = Services.HttpService:UrlEncode(exec .. "_" .. realHWID)
local LIVE_BASE = "https://mylflive.bythekyol.workers.dev"
local http = (syn and syn.request) or request or http_request or (http and http.request)
local function httpJSON(method, url, bodyTable)
    local opt = {Url = url, Method = method, Headers = {["Content-Type"] = "application/json"}}
    if bodyTable then opt.Body = Services.HttpService:JSONEncode(bodyTable) end
    local ok, res = pcall(function() return http(opt) end)
    return ok and res or nil
end
local LiveActiveCount = 0
-- 60s heartbeat (balanced)
coroutine.wrap(function()
    while true do
        httpJSON("POST", LIVE_BASE .. "/heartbeat", { hwid = PC_HWID })
        task.wait(60)
    end
end)()
-- 30s active count (slower for ping)
coroutine.wrap(function()
    while true do
        local res = httpJSON("GET", LIVE_BASE .. "/active")
        if res and res.StatusCode == 200 then
            local ok, data = pcall(function() return Services.HttpService:JSONDecode(res.Body) end)
            if ok and type(data) == "table" then
                LiveActiveCount = tonumber(data.active) or 0
            end
        end
        task.wait(30)
    end
end)()
-- Hesaplamalar ve Update (Örnekten tam) - Optimized: Grad update every 1s now
local hbAvg, rsAvg, hbN, rsN, halfA, frameCount = 0, 0, 0, 0, 0, 0
local lastGradUpdate = 0
local gradTime = 0
Services.RunService.Heartbeat:Connect(function(dt)
    hbN = hbN + 1
    hbAvg = hbAvg + (dt - hbAvg) / hbN
end)
Services.RunService.RenderStepped:Connect(function(dt)
    rsN = rsN + 1
    rsAvg = rsAvg + (dt - rsAvg) / rsN
    halfA = halfA + dt
    frameCount = frameCount + 1
    -- Akıcı Rainbow (her 0.033s ~30 FPS smooth)
    gradTime = gradTime + dt
    if gradTime >= 0.033 then
        gradTime = 0
        local t = os.clock() * 0.33 -- Smooth hız
        grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0.00, Color3.fromHSV(t % 1, 1, 1)),
            ColorSequenceKeypoint.new(0.50, Color3.fromHSV((t + 0.33) % 1, 1, 1)),
            ColorSequenceKeypoint.new(1.00, Color3.fromHSV((t + 0.66) % 1, 1, 1)),
        }
    end
    if halfA >= 0.5 then
        local fps = round(frameCount / halfA, 0)
        frameCount = 0
        halfA = 0
        local ping = "?"
        pcall(function()
            local it = Services.Stats.Network.ServerStatsItem["Data Ping"]
            if it then ping = tostring(it:GetValueString()):gsub(" RTT", "") end
        end)
        CrownText.Text = ("FPS: %s | Ping: %s | CPU: %s ms | GPU: %s ms | Live: %d"):format(fps, ping, round(hbAvg * 1000, 1), round(rsAvg * 1000, 1), LiveActiveCount)
        local need = CrownText.TextBounds.X + 40
        CrownPanel.Size = UDim2.fromOffset(math.clamp(need, 260, 680), 26)
    end
end)
local TeamTab = Window:CreateTab("Team Selection", 4483362458)
local CombatTab = Window:CreateTab("AimBot", 4483362458)
local VisualTab = Window:CreateTab("ESP", 4483362458)
local MovementTab = Window:CreateTab("Movement", 4483362458)
local TeleportTab = Window:CreateTab("Teleport", 4483362458)
local CameraTab = Window:CreateTab("Camera View", 4483362458)
local EmotesTab = Window:CreateTab("Emotes", 4483362458) -- YENİ EMOTES TAB
local SettingsTab = Window:CreateTab("Info", 4483362458)
local MenuServerTab = Window:CreateTab("Settings", 4483362458)
-- Global Variables (Aimbot/ESP korundu, features external ile uyumlu)
getgenv().AimbotEnabled = false
getgenv().SilentAimEnabled = false
getgenv().AimbotFOV = 90
getgenv().AimbotHitpart = "Head"
getgenv().VisibleCheck = true
getgenv().DrawFOV = false
getgenv().SelectedEnemyTeams = {}
getgenv().TeamCheckEnabled = true
getgenv().BoxESP = false
getgenv().NameESP = false
getgenv().HealthESP = false
getgenv().TracerESP = false
getgenv().ChamsEnabled = false
getgenv().WallESP = false
getgenv().ESPDistance = 2000
-- Emotes Global (YENİ: Loop mode ve current track)
getgenv().EmotesLoopMode = false
getgenv().CurrentEmoteTrack = nil
-- Emotes Listesi (Efendimin Verdiği Tam Liste!)
local emotes = {
    {name = "susma", id = "rbxassetid://114829008360220"},
    {name = "?", id = "rbxassetid://121966805049108"},
    {name = "??", id = "rbxassetid://112089880074848"},
    {name = "???", id = "rbxassetid://136491428712959"},
    {name = "????", id = "rbxassetid://96357779735687"},
    {name = "?keko?", id = "rbxassetid://133841838295129"}, -- keko dans ile çakışıyor, ama eskiyi korudum; isterseniz birleştiririm
    {name = "GanGam Style", id = "rbxassetid://137133110548904"},
    {name = "Dararara", id = "rbxassetid://115781688996859"},
    {name = "Twice", id = "rbxassetid://14899980745"},
    {name = "Anime", id = "rbxassetid://114774556469581"},
    {name = "Aşkını İtiraf Et", id = "rbxassetid://108873777157620"},
    {name = "Billy Zıplaması", id = "rbxassetid://115607052226647"},
    {name = "Boksör", id = "rbxassetid://80933111363555"},
    {name = "DJ Bekleme Pozu", id = "rbxassetid://114486154887764"},
    {name = "Dougle Dansı", id = "rbxassetid://87574738912971"},
    {name = "Elektro Dansı", id = "rbxassetid://138785676658772"},
    {name = "Eller Yukarı", id = "rbxassetid://135395608251521"},
    {name = "Garry Dansı", id = "rbxassetid://124896171012585"},
    {name = "Gürültücü", id = "rbxassetid://136095999219650"},
    {name = "Havalı Tokat", id = "rbxassetid://118552217459650"},
    {name = "Horeg Dansı", id = "rbxassetid://110204898807330"},
    {name = "Jackpot Dansı", id = "rbxassetid://126041249033925"},
    {name = "Kadın Dansı", id = "rbxassetid://76240950459288"},
    {name = "Kafa Sallama", id = "rbxassetid://15517864808"},
    {name = "Kalça Dansı", id = "rbxassetid://138671912289772"},
    {name = "Kalça Döndürme", id = "rbxassetid://88593312682192"},
    {name = "Kalça Zıplaması", id = "rbxassetid://103606174140721"},
    {name = "Kedi Dansı", id = "rbxassetid://122639636262924"},
    {name = "Kendine Çekme", id = "rbxassetid://115605836623904"},
    {name = "Koşma Dansı", id = "rbxassetid://96147994216119"},
    {name = "Kıvırma", id = "rbxassetid://133551169796944"},
    {name = "Michael Myers Dansı", id = "rbxassetid://130628312209858"},
    {name = "Mutlu", id = "rbxassetid://4841405708"},
    {name = "NYC Dansı", id = "rbxassetid://140333103929828"},
    {name = "Nika Dansı", id = "rbxassetid://132930994178862"},
    {name = "Oryantal", id = "rbxassetid://136494657202841"},
    {name = "Otur", id = "rbxassetid://93120341268524"},
    {name = "Parti", id = "rbxassetid://113052435813981"},
    {name = "Popüler", id = "rbxassetid://93062298566806"},
    {name = "Rick Roll", id = "rbxassetid://133608432421494"},
    {name = "Sağlam Dans", id = "rbxassetid://99558490932154"},
    {name = "Umursamaz", id = "rbxassetid://97086109091396"},
    {name = "Uykucu", id = "rbxassetid://10714360343"},
    {name = "Yat", id = "rbxassetid://92747295139963"},
    {name = "Zafer Dansı", id = "rbxassetid://15505456446"},
    {name = "Zıplama", id = "rbxassetid://15609995579"},
    {name = "İmza Dansı", id = "rbxassetid://112931882473990"},
    {name = "Şapşal Dans", id = "rbxassetid://85062238386196"},
    -- Yeni düzeltilmiş eklemeler aşağıda (duplicate'ler güncellendi):
    {name = "Namaz Kılma", id = "rbxassetid://93009184159377"},
    {name = "Oyun Havası", id = "rbxassetid://104062506559570"},
    {name = "Namaz Kılma v2", id = "rbxassetid://127829093804907"},
    {name = "oturma", id = "rbxassetid://110071776811205"},
    {name = "YERE YATMA DELİRME", id = "rbxassetid://98719422024341"},
    {name = "keko dans", id = "rbxassetid://133841838295129"},
    {name = "twerk", id = "rbxassetid://99457675722909"},
    {name = "twerk gibi bişi", id = "rbxassetid://14548621256"},
    {name = "keko oturusu v2", id = "rbxassetid://84129863420846"},
    {name = "stres çarkı", id = "rbxassetid://108359356964182"},
    {name = "dans", id = "rbxassetid://71494363833326"},
    {name = "dans 2", id = "rbxassetid://113074782746670"},
    {name = "idle", id = "rbxassetid://102342919277367"},
    {name = "duvara yaslanma idle", id = "rbxassetid://106394178681320"},
    {name = "dans 3", id = "rbxassetid://116714406076290"},
    {name = "dans 4", id = "rbxassetid://140333103929828"},
    {name = "dans 5", id = "rbxassetid://102229339944611"},
    {name = "garip dans", id = "rbxassetid://76766009781388"},
    {name = "tekme", id = "rbxassetid://92249489340640"},
    {name = "uçan tekme", id = "rbxassetid://133566007754001"},
    {name = "Bully Maguire", id = "rbxassetid://87099200550143"},
    {name = "SkibiDopDop", id = "rbxassetid://98328399081636"},
    {name = "Tuff", id = "rbxassetid://99195149999804"},
    {name = "One pound fish", id = "rbxassetid://97705611021245"},
    {name = "Die Lit", id = "rbxassetid://134158476680452"},
    {name = "snops walk", id = "rbxassetid://110204898807330"},
    {name = "michael myers", id = "rbxassetid://94751338993179"},
    {name = "domalma", id = "rbxassetid://111057054738672"},
    {name = "foot job", id = "rbxassetid://88421489929073"},
    {name = "sakso", id = "rbxassetid://78354011045319"},
    {name = "kalp", id = "rbxassetid://85881727141841"},
    {name = "sexi", id = "rbxassetid://77780134372141"},
    {name = "nah", id = "rbxassetid://106494344727100"},
    {name = "anıme yatma", id = "rbxassetid://115619217455701"}
}
-- Team Check
local function isEnemy(plr)
    if not getgenv().TeamCheckEnabled then return true end
    if not plr.Team then return true end
    return table.find(getgenv().SelectedEnemyTeams, plr.Team.Name) ~= nil
end
-- Visible Check (Cache for 0lag, No Ghost fix) - 0MS: Raycast every 2 frames, per-char track
local VisibilityCache = {}
local frameCounter = 0
local lastRayFrame = {}
Services.RunService.Heartbeat:Connect(function() frameCounter = frameCounter + 1 end)
local function isVisible(targetPart)
    local char = targetPart.Parent
    if not char then return false end
    local posHash = math.floor(targetPart.Position.X + targetPart.Position.Y + targetPart.Position.Z) % 1000
    local key = tostring(char) .. (tick() // 0.5) .. "_" .. posHash
    if VisibilityCache[key] ~= nil then return VisibilityCache[key] end
    local nowFrame = frameCounter
    local lastFrame = lastRayFrame[char] or 0
    local framesSince = nowFrame - lastFrame
    local doRay = (framesSince % 2 == 0) or (framesSince > 3)
    if doRay then
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {Services.LocalPlayer.Character or Services.LocalPlayer.CharacterAdded:Wait()}
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        local ray = Services.Workspace:Raycast(Services.Camera.CFrame.Position, (targetPart.Position - Services.Camera.CFrame.Position).Unit * 1000, rayParams)
        local result = ray == nil or ray.Instance:IsDescendantOf(char)
        VisibilityCache[key] = result
        lastRayFrame[char] = nowFrame
    else
        local prevKey = tostring(char) .. ((tick() - 0.5) // 0.5) .. "_" .. posHash
        VisibilityCache[key] = VisibilityCache[prevKey] or false
        lastRayFrame[char] = nowFrame
    end
    task.delay(0.5, function() VisibilityCache[key] = nil; lastRayFrame[char] = nil end)
    if #VisibilityCache > 50 then VisibilityCache = {} end
    return VisibilityCache[key]
end
-- Get Nearest (Combat reuse) - 0MS: Cache 0.033s (2 frame), quick validate
local lastNearest = nil
local lastNearestTime = 0
local function getNearest()
    local now = tick()
    if now - lastNearestTime < 0.033 and lastNearest then
        local hitPart = lastNearest.Character and (lastNearest.Character:FindFirstChild(getgenv().AimbotHitpart) or lastNearest.Character.HumanoidRootPart)
        if hitPart and lastNearest.Character.Humanoid.Health > 0 and isVisible(hitPart) then return lastNearest end
        lastNearest = nil
    end
    local nearest = nil
    local shortest = getgenv().AimbotFOV
    local mousePos = Services.UserInputService:GetMouseLocation()
    for _, plr in ipairs(Services.Players:GetPlayers()) do
        if plr ~= Services.LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            if isEnemy(plr) then
                local root = plr.Character.HumanoidRootPart
                local hitPart = plr.Character:FindFirstChild(getgenv().AimbotHitpart) or root
                local screenPos, onScreen = Services.Camera:WorldToViewportPoint(root.Position)
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if onScreen and dist < shortest and isVisible(hitPart) then
                    shortest = dist
                    nearest = plr
                end
            end
        end
    end
    lastNearest = nearest
    lastNearestTime = now
    return nearest
end
-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = getgenv().AimbotFOV
FOVCircle.Color = Color3.fromRGB(255, 0, 255)
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.NumSides = 100
Services.RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Services.UserInputService:GetMouseLocation()
    FOVCircle.Radius = getgenv().AimbotFOV
    FOVCircle.Visible = getgenv().DrawFOV
end)
-- Aimbot - 0MS: Heartbeat every frame, optimized cache + re-check + smooth
local lastAimCFrame = Services.Camera.CFrame
Services.RunService.Heartbeat:Connect(function()
    if getgenv().AimbotEnabled then
        local target = getNearest()
        if target and target.Character then
            local part = target.Character:FindFirstChild(getgenv().AimbotHitpart)
            if part and isVisible(part) then
                local newCFrame = CFrame.new(Services.Camera.CFrame.Position, part.Position)
                local smooth = getgenv().AimbotSmooth or 0
                if smooth > 0 then
                    Services.Camera.CFrame = Services.Camera.CFrame:Lerp(newCFrame, smooth)
                else
                    Services.Camera.CFrame = newCFrame
                end
                lastAimCFrame = Services.Camera.CFrame
            else
                Services.Camera.CFrame = lastAimCFrame
            end
        end
    end
end)
-- ESP Table & Highlights (Korundu, remnants fix ile)
local ESPTable = {}
local Highlights = {}
local Connections = {}
-- Create ESP
local function createESP(plr)
    if ESPTable[plr] then return end
    local Box = Drawing.new("Square")
    Box.Thickness = 2
    Box.Filled = false
    Box.Transparency = 1
    Box.Color = Color3.fromRGB(255, 255, 255)
    local Name = Drawing.new("Text")
    Name.Size = 16
    Name.Center = true
    Name.Outline = true
    Name.Font = Drawing.Fonts.UI
    Name.Color = Color3.new(1,1,1)
    Name.Transparency = 1
    local HealthBG = Drawing.new("Square")
    HealthBG.Thickness = 1
    HealthBG.Filled = true
    HealthBG.Color = Color3.new(0,0,0)
    HealthBG.Transparency = 0.5
    local Health = Drawing.new("Square")
    Health.Thickness = 1
    Health.Filled = true
    Health.Color = Color3.new(0,1,0)
    local Tracer = Drawing.new("Line")
    Tracer.Thickness = 2
    Tracer.Color = Color3.fromRGB(255, 255, 255)
    Tracer.Transparency = 1
    ESPTable[plr] = {Box = Box, Name = Name, HealthBG = HealthBG, Health = Health, Tracer = Tracer}
    -- Auto Refresh
    Connections[plr] = {}
    table.insert(Connections[plr], plr.CharacterAdded:Connect(function()
        task.wait(0.1)
        createESP(plr)
    end))
    table.insert(Connections[plr], plr.CharacterRemoving:Connect(function()
        task.spawn(function() removeESP(plr) end)
    end))
end
local function removeESP(plr)
    if ESPTable[plr] then
        for _, obj in pairs(ESPTable[plr]) do
            if obj then obj:Remove() end
        end
        ESPTable[plr] = nil
    end
    if Highlights[plr] then
        Highlights[plr]:Destroy()
        Highlights[plr] = nil
    end
    if Connections[plr] then
        for _, conn in pairs(Connections[plr]) do
            if conn then conn:Disconnect() end
        end
        Connections[plr] = nil
    end
end
-- Initial Full Detect
for _, plr in ipairs(Services.Players:GetPlayers()) do
    if plr ~= Services.LocalPlayer then
        createESP(plr)
    end
end
-- New Players
Services.Players.PlayerAdded:Connect(function(plr)
    if plr ~= Services.LocalPlayer then
        task.wait(0.5) -- Slightly faster
        createESP(plr)
    end
end)
-- Player Leaving
Services.Players.PlayerRemoving:Connect(function(plr)
    task.spawn(function()
        removeESP(plr)
    end)
end)
-- ESP Update - 0MS: Screen cache every frame, optimized
local espFrameCounter = 0
local screenCache = {}
local chamsTime = 0
Services.RunService.RenderStepped:Connect(function()
    espFrameCounter = espFrameCounter + 1
    local camPos = Services.Camera.CFrame.Position
    for plr, esp in pairs(ESPTable) do
        if not plr.Parent or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") or not plr.Character:FindFirstChild("Humanoid") or plr.Character.Humanoid.Health <= 0 or not isEnemy(plr) then
            task.spawn(function() removeESP(plr) end)
        else
            local root = plr.Character.HumanoidRootPart
            local head = plr.Character:FindFirstChild("Head") or root
            local hum = plr.Character.Humanoid
            -- 0MS: Update screen cache every frame (optimized, no tick check)
            local rootScreen, onScreen = Services.Camera:WorldToViewportPoint(root.Position)
            local headScreen = Services.Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
            local legScreen = Services.Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
            screenCache[plr] = {rootScreen = rootScreen, headScreen = headScreen, legScreen = legScreen, onScreen = onScreen, time = tick(), dist = (root.Position - camPos).Magnitude}
            local sc = screenCache[plr]
            local dist = sc.dist
            local visible = isVisible(root)
            if sc.onScreen and dist <= getgenv().ESPDistance then
                local boxHeight = sc.headScreen.Y - sc.legScreen.Y
                local boxWidth = boxHeight / 2
                if getgenv().BoxESP then
                    esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                    esp.Box.Position = Vector2.new(sc.rootScreen.X - boxWidth / 2, sc.rootScreen.Y - boxHeight / 2)
                    esp.Box.Color = visible and Color3.fromRGB(0,255,0) or (getgenv().WallESP and Color3.fromRGB(255,0,0) or Color3.fromRGB(128,128,128))
                    esp.Box.Transparency = visible and 1 or (getgenv().WallESP and 0.5 or 0.2)
                    esp.Box.Visible = true
                else
                    esp.Box.Visible = false
                end
                if getgenv().NameESP then
                    esp.Name.Text = plr.Name .. " [" .. math.floor(dist) .. "]"
                    esp.Name.Position = Vector2.new(sc.rootScreen.X, sc.headScreen.Y - 40)
                    esp.Name.Color = visible and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
                    esp.Name.Visible = true
                else
                    esp.Name.Visible = false
                end
                if getgenv().HealthESP then
                    local healthPercent = hum.Health / hum.MaxHealth
                    esp.HealthBG.Size = Vector2.new(4, boxHeight)
                    esp.HealthBG.Position = Vector2.new(sc.rootScreen.X - boxWidth / 2 - 6, sc.rootScreen.Y - boxHeight / 2)
                    esp.Health.Size = Vector2.new(4, boxHeight * healthPercent)
                    esp.Health.Position = esp.HealthBG.Position + Vector2.new(0, boxHeight * (1 - healthPercent))
                    esp.Health.Color = Color3.fromHSV(healthPercent * 0.33, 1, 1)
                    esp.HealthBG.Visible = true
                    esp.Health.Visible = true
                else
                    esp.HealthBG.Visible = false
                    esp.Health.Visible = false
                end
                if getgenv().TracerESP then
                    esp.Tracer.From = Vector2.new(Services.Camera.ViewportSize.X / 2, Services.Camera.ViewportSize.Y)
                    esp.Tracer.To = Vector2.new(sc.rootScreen.X, sc.rootScreen.Y)
                    esp.Tracer.Color = visible and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
                    esp.Tracer.Visible = true
                else
                    esp.Tracer.Visible = false
                end
                if getgenv().ChamsEnabled then
                    if not Highlights[plr] then
                        local hl = Instance.new("Highlight")
                        hl.Parent = plr.Character
                        hl.Adornee = plr.Character
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.FillTransparency = 0.5
                        hl.OutlineTransparency = 0
                        Highlights[plr] = hl
                    end
                    local hl = Highlights[plr]
                    local t = tick() % 2
                    if visible then
                        hl.FillColor = Color3.fromRGB(0, 255, 255)
                    else
                        hl.FillColor = Color3.fromRGB(255, 0, 255)
                    end
                elseif Highlights[plr] then
                    Highlights[plr]:Destroy()
                    Highlights[plr] = nil
                end
            else
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.HealthBG.Visible = false
                esp.Health.Visible = false
                esp.Tracer.Visible = false
                if Highlights[plr] then
                    Highlights[plr]:Destroy()
                    Highlights[plr] = nil
                end
                if tick() - sc.time > 1 then screenCache[plr] = nil end -- Clean faster
            end
        end
    end
end)
-- Stale ESP Sweeper - Balanced: 1s
coroutine.wrap(function()
    while true do
        task.wait(1)
        for plr, esp in pairs(ESPTable) do
            if not plr.Parent or not plr.Character or (plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health <= 0) then
                task.spawn(function() removeESP(plr) end)
            end
        end
        -- Cache temizliği
        if #VisibilityCache > 50 then VisibilityCache = {} end
        local cacheSize = 0
        for _ in pairs(screenCache) do cacheSize = cacheSize + 1 end
        if cacheSize > 20 then screenCache = {} end
    end
end)()
-- Auto Scan - Balanced: 1s
coroutine.wrap(function()
    while true do
        task.wait(1)
        for _, plr in ipairs(Services.Players:GetPlayers()) do
            if plr ~= Services.LocalPlayer and isEnemy(plr) and not ESPTable[plr] then
                createESP(plr)
            end
        end
    end
end)()
-- UI Elements (Team/Combat/Visual korundu, features external ile toggle'lar bağlandı) – GÜVENLİ: features nil ise atla
local teamNames = {}
for _, team in ipairs(Services.Teams:GetTeams()) do
    if team.Name ~= "Neutral" and team.Name ~= "" then
        table.insert(teamNames, team.Name)
    end
end
if #teamNames > 0 then
    TeamTab:CreateDropdown({
        Name = "Düşman Takımlar",
        Options = teamNames,
        CurrentOption = {},
        MultipleOptions = true,
        Flag = "EnemyTeamsFlag",
        Callback = function(val)
            getgenv().SelectedEnemyTeams = val
        end
    })
end
TeamTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Flag = "TeamCheckFlag",
    Callback = function(val)
        getgenv().TeamCheckEnabled = val
    end
})
CombatTab:CreateToggle({
    Name = "Aimbot (Visible Only)",
    CurrentValue = false,
    Flag = "AimbotFlag",
    Callback = function(val)
        getgenv().AimbotEnabled = val
    end
})
CombatTab:CreateToggle({
    Name = "Silent Aim",
    CurrentValue = false,
    Flag = "SilentAimFlag",
    Callback = function(val)
        getgenv().SilentAimEnabled = val
    end
})
CombatTab:CreateSlider({
    Name = "Aimbot FOV",
    Range = {5, 500},
    Increment = 1,
    CurrentValue = 90,
    Flag = "FOVFlag",
    Callback = function(val)
        getgenv().AimbotFOV = val
    end
})
CombatTab:CreateToggle({
    Name = "FOV Çemberi",
    CurrentValue = false,
    Flag = "DrawFOVFlag",
    Callback = function(val)
        getgenv().DrawFOV = val
    end
})
VisualTab:CreateToggle({
    Name = "Rainbow Skeleton (All Player- R6&R15)",
    CurrentValue = false,
    Flag = "RainbowSkeletonFlag",
    Callback = function(val)
         if features and features.ToggleSkeleton then features.ToggleSkeleton(val) end
        end
    })
VisualTab:CreateToggle({
    Name = "Box ESP",
    CurrentValue = false,
    Flag = "BoxESPFlag",
    Callback = function(val)
        getgenv().BoxESP = val
    end
})
VisualTab:CreateToggle({
    Name = "3D Box (All Player)",
    CurrentValue = false,
    Flag = "RainbowBoxFlag",
    Callback = function(val)
         if features and features.ToggleBox then features.ToggleBox(val) end
        end
    })
VisualTab:CreateToggle({
    Name = "Name ESP",
    CurrentValue = false,
    Flag = "NameESPFlag",
    Callback = function(val)
        getgenv().NameESP = val
    end
})
VisualTab:CreateToggle({
    Name = "Rainbow Name (All Player)",
    CurrentValue = false,
    Flag = "RainbowNameFlag",
    Callback = function(val)
         if features and features.ToggleRainbowName then features.ToggleRainbowName(val) end
        end
    })
VisualTab:CreateToggle({
    Name = "Health ESP",
    CurrentValue = false,
    Flag = "HealthESPFlag",
    Callback = function(val)
        getgenv().HealthESP = val
    end
})
VisualTab:CreateToggle({
    Name = "Tracer ESP",
    CurrentValue = false,
    Flag = "TracerESPFlag",
    Callback = function(val)
        getgenv().TracerESP = val
    end
})
VisualTab:CreateToggle({
    Name = "Rainbow Tracer (All Player)",
    CurrentValue = false,
    Flag = "RainbowTracersFlag",
    Callback = function(val)
         if features and features.ToggleTracers then features.ToggleTracers(val) end
        end
    })
VisualTab:CreateToggle({
    Name = "Chams (Smooth Color)",
    CurrentValue = false,
    Flag = "ChamsFlag",
    Callback = function(val)
        getgenv().ChamsEnabled = val
    end
})
VisualTab:CreateToggle({
    Name = "Rainbow Chams (All Player)",
    CurrentValue = false,
    Flag = "RainbowChamsFlag",
    Callback = function(val)
         if features and features.ToggleGlow then features.ToggleGlow(val) end
        end
    })
VisualTab:CreateSlider({
    Name = "ESP Mesafe",
    Range = {100, 5000},
    Increment = 100,
    CurrentValue = 2000,
    Flag = "ESPDistanceFlag",
    Callback = function(val)
        getgenv().ESPDistance = val
    end
})
-- Movement Tab: Core movement
local MovementSection = MovementTab:CreateSection("Core Movement")
MovementTab:CreateToggle({
    Name = "⚡ Speed Boost (50)",
    CurrentValue = false,
    Flag = "SpeedFlag",
    Callback = function(val)
        if features and features.ToggleSpeed then features.ToggleSpeed(val) end
    end
})
MovementTab:CreateSlider({
    Name = "Walk Speed",
    Range = {1, 400},
    Increment = 1,
    CurrentValue = (features and features._walkSpeed) or 16,
    Flag = "WalkSpeedFlag",
    Callback = function(val)
        if features and features._walkSpeed then features._walkSpeed = val end
        if features and features.SetWalkSpeed then features.SetWalkSpeed(val) end
    end
})
MovementTab:CreateToggle({
    Name = "🕊️ Fly (LCtrl down)",
    CurrentValue = false,
    Flag = "FlyFlag",
    Callback = function(val)
        if features and features.ToggleFly then features.ToggleFly(val) end
    end
})
MovementTab:CreateSlider({
    Name = "Fly Speed",
    Range = {1, 400},
    Increment = 1,
    CurrentValue = (features and features._flySpeed) or 50,
    Flag = "FlySpeedFlag",
    Callback = function(val)
        if features and features.SetFlySpeed then features.SetFlySpeed(val) end
    end
})
MovementTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJumpFlag",
    Callback = function(val)
        if features and features.ToggleInfiniteJump then features.ToggleInfiniteJump(val) end
    end
})
MovementTab:CreateToggle({
    Name = "👻 Hard Invisible",
    CurrentValue = false,
    Flag = "HardInvisibleFlag",
    Callback = function(val)
        if features and features.ToggleHardInvisible then features.ToggleHardInvisible(val) end
    end
})
MovementTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Flag = "NoclipFlag",
    Callback = function(val)
        if features and features.ToggleNoclip then features.ToggleNoclip(val) end
    end
})
-- Teleport Tab: Tüm teleport özellikleri + auto farm/behind + X Y Z slider'lar
local TeleportSection = TeleportTab:CreateSection("Teleport Features")
TeleportTab:CreateToggle({
    Name = "Teleport (T Key)",
    CurrentValue = false,
    Flag = "TeleportFlag",
    Callback = function(val)
        if features and features.ToggleTeleport then features.ToggleTeleport(val) end
    end
})
TeleportTab:CreateToggle({
    Name = "⚡ Always Behind Enemy",
    CurrentValue = false,
    Flag = "AutoBehindFlag",
    Callback = function(val)
        if features and features.ToggleAutoBehind then features.ToggleAutoBehind(val) end
    end
     
})
TeleportTab:CreateToggle({
    Name = "⚡ Auto Farm Enemy",
    CurrentValue = false,
    Flag = "AutoFarmFlag",
    Callback = function(val)
        if features and features.ToggleAutoTeleportToEnemy then features.ToggleAutoTeleportToEnemy(val) end
    end
})
TeleportTab:CreateSlider({
    Name = "X Offset",
    Range = {-50, 50},
    Increment = 1,
    CurrentValue = (features and features._tpX) or 0,
    Flag = "tpXFlag",
    Callback = function(val)
        if features and features._tpX then features._tpX = val end
        if features and features.SetTeleportOffset then features.SetTeleportOffset(val, (features._tpY or 0), (features._tpZ or 25)) end
    end
})
TeleportTab:CreateSlider({
    Name = "Y Offset",
    Range = {-50, 50},
    Increment = 1,
    CurrentValue = (features and features._tpY) or 0,
    Flag = "tpYFlag",
    Callback = function(val)
        if features and features._tpY then features._tpY = val end
        if features and features.SetTeleportOffset then features.SetTeleportOffset((features._tpX or 0), val, (features._tpZ or 25)) end
    end
})
TeleportTab:CreateSlider({
    Name = "Z Offset",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = (features and features._tpZ) or 25,
    Flag = "tpZFlag",
    Callback = function(val)
        if features and features._tpZ then features._tpZ = val end
        if features and features.SetTeleportOffset then features.SetTeleportOffset((features._tpX or 0), (features._tpY or 0), val) end
    end
})
-----------------------------------------------------------------Camera View---------------------------------
local selectedPlayers = {}
local camViewActive = false
local dropdownRef = nil
local playerListCache = {}
local respawnConns = {}
local Plrs = game:GetService("Players")
local RS = game:GetService("RunService")
local LP = Plrs.LocalPlayer
local Cam = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")

---------------------------------------------------------
-- PLAYER LIST (Multi-Select)
---------------------------------------------------------
local function collectOptions()
    local list = {}
    for _, p in ipairs(Plrs:GetPlayers()) do
        if p ~= LP then
            table.insert(list, p.Name)
        end
    end
    return list
end

local function rebuildDropdown()
    if dropdownRef then dropdownRef:Destroy() end

    dropdownRef = CameraTab:CreateDropdown({
        Name = "Select Players",
        Options = collectOptions(),
        CurrentOption = {},
        MultipleOptions = true,

        Callback = function(names)
            for _,c in ipairs(respawnConns) do c:Disconnect() end
            respawnConns = {}

            selectedPlayers = {}

            for _, n in ipairs(names) do
                local p = Plrs:FindFirstChild(n)
                if p then
                    table.insert(selectedPlayers,p)

                    table.insert(respawnConns,
                        p.CharacterAdded:Connect(function()
                            if camViewActive then task.wait(0.1) end
                        end)
                    )
                end
            end
        end
    })
end

---------------------------------------------------------
-- AUTO REFRESH
---------------------------------------------------------
local function detectChanges()
    local now = {}
    for _,p in ipairs(Plrs:GetPlayers()) do
        if p ~= LP then now[p.Name] = true end
    end

    local changed = false

    for n in pairs(playerListCache) do
        if not now[n] then changed=true break end
    end
    for n in pairs(now) do
        if not playerListCache[n] then changed=true break end
    end

    if changed then
        playerListCache = now
        rebuildDropdown()

        for i=#selectedPlayers,1,-1 do
            if not Plrs:FindFirstChild(selectedPlayers[i].Name) then
                table.remove(selectedPlayers,i)
            end
        end
    end
end

Plrs.PlayerAdded:Connect(detectChanges)
Plrs.PlayerRemoving:Connect(detectChanges)
RS.Heartbeat:Connect(detectChanges)
rebuildDropdown()

---------------------------------------------------------
-- 🎥 CAMERA MOVEMENT (YAW • PITCH • ZOOM)
---------------------------------------------------------
local yaw     = math.rad(0)
local pitch   = math.rad(-10)
local dist    = 12
local minDist = 4
local maxDist = 80

local camConn = nil
local mouseConn = nil
local wheelConn = nil

local function stopCamFollow()
    if camConn then camConn:Disconnect() camConn = nil end
    if mouseConn then mouseConn:Disconnect() mouseConn = nil end
    if wheelConn then wheelConn:Disconnect() wheelConn = nil end

    Cam.CameraType = Enum.CameraType.Custom
    
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then Cam.CameraSubject = hum end
end

local function startCamFollow(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    Cam.CameraType = Enum.CameraType.Scriptable

    local sens = 0.003

    mouseConn = UIS.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then
            yaw = yaw - i.Delta.X * sens
            pitch = math.clamp(pitch - i.Delta.Y * sens, math.rad(-80), math.rad(80))
        end
    end)

    wheelConn = UIS.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseWheel then
            dist = math.clamp(dist - i.Position.Z * 2, minDist, maxDist)
        end
    end)

    camConn = RS.RenderStepped:Connect(function()
        if not targetPlayer.Character then return end
        local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local basePos = hrp.Position

        -- HRP merkezli, mouse kontrollü kamera
        local camCF =
            CFrame.new(basePos)
            * CFrame.Angles(pitch, yaw, 0)
            * CFrame.new(0, 3, dist)
            * CFrame.new(0, 0, -dist)

        Cam.CFrame = CFrame.new(camCF.Position, basePos)
    end)
end

---------------------------------------------------------
-- FOLLOW CAMERA (Yeni: HRP merkezli, mouse kontrollü)
---------------------------------------------------------
local function enableFollowCam()
    if #selectedPlayers == 0 then
        Rayfield:Notify({ Title="Error", Content="Oyuncu seç", Duration=2 })
        return false
    end

    camViewActive = true

    local target = selectedPlayers[1]
    startCamFollow(target)

    return true
end

local function disableFollowCam()
    camViewActive = false
    stopCamFollow()
end

---------------------------------------------------------
-- 🎥 CAMERA VIEW TOGGLE
---------------------------------------------------------
CameraTab:CreateToggle({
    Name = "🎥 Camera Follow",
    CurrentValue = false,

    Callback = function(val)
        if val then
            if not enableFollowCam() then
                return false
            end
        else
            disableFollowCam()
        end
    end
})

LP.CharacterAdded:Connect(function()
    if camViewActive then
        task.wait(0.2)
        enableFollowCam()
    end
end)

---------------------------------------------------------
-- ⚡ TELEPORT BUTTON
---------------------------------------------------------
CameraTab:CreateButton({
    Name = "⚡ Teleport Selected",
    Callback = function()
        if #selectedPlayers == 0 then
            Rayfield:Notify({
                Title="Error",
                Content="Oyuncu seç",
                Duration=2
            })
            return
        end

        task.spawn(function()
            for _,p in ipairs(selectedPlayers) do
                local targetHRP = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")

                if targetHRP and myHRP then
                    LP.Character:PivotTo(targetHRP.CFrame * CFrame.new(0,0,3))

                    Rayfield:Notify({
                        Title="TP",
                        Content = p.Name.." ✔",
                        Duration = 2
                    })
                end

                task.wait(1)
            end
        end)
    end
})

















-- Emote Buttons (Her emote için button, Rayfield ile gruplanmış)
-- DÜZELTME: Emote Controls Section + PlayEmote Fonksiyonu (callback hatası için zorunlu)
local EmoteControlSection = EmotesTab:CreateSection("Emote Controls")
-- Değişkenler
local CurrentSpeed = 1
local Enabled = false
local Humanoid = nil


local applied = false

local function applyAnims()
    local player = game.Players.LocalPlayer
    if not player.Character or not player.Character:FindFirstChild("Humanoid") then return end
    
    local char = player.Character
    local hum = char.Humanoid
    local animate = char:FindFirstChild("Animate")
    if not animate then return end
    
    -- Animate reload
    animate.Disabled = true
    task.wait()
    animate.Disabled = false
    
    -- Yeni ID'ler
    animate.idle.Animation1.AnimationId = "rbxassetid://4211218409"
    animate.idle.Animation2.AnimationId = "rbxassetid://4211218409"
    
    animate.walk.WalkAnim.AnimationId = "rbxassetid://18537392113"      -- Run ID'sini walk'a da verdim (sigma akışı)
    
    animate.run.RunAnim.AnimationId = "rbxassetid://109168724482748"        -- Run
    
    animate.jump.JumpAnim.AnimationId = "rbxassetid://100901692455858"      -- Jump + Fly etkisi
    animate.fall.FallAnim.AnimationId = "rbxassetid://18537367238"      -- Fall da aynı
    animate.climb.ClimbAnim.AnimationId = "rbxassetid://88763136693023"    -- Climb sigma gibi
    
    -- Swim eski kaldı ama istersen değiştiririz
    if animate:FindFirstChild("swim") then
        animate.swim.Swim.AnimationId = "rbxassetid://18537376492"      -- Fly/swim için jump anim
        animate.swimidle.SwimIdle.AnimationId = "rbxassetid://10921288909"
    end
    
    Rayfield:Notify({
        Title = "Dev Animation Pack (Sigma)!",
        Content = "Yeni sigma animler aktif",
        Duration = 5,
    })
end

-- Respawn koruması
game.Players.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if applied then
        applyAnims()
    end
end)


-- Hız uygula
local function ApplySpeed(speed)
    if not Humanoid or not Enabled then return end
    for _, track in pairs(Humanoid:GetPlayingAnimationTracks()) do
        track:AdjustSpeed(speed)
    end
end

-- Karakter yükle
local function LoadCharacter(char)
    Humanoid = char:WaitForChild("Humanoid")
    ApplySpeed(CurrentSpeed)
    
    Humanoid.AnimationPlayed:Connect(function(track)
        if Enabled then
            track:AdjustSpeed(CurrentSpeed)
        end
    end)
end

local Player = game.Players.LocalPlayer
if Player.Character then
    LoadCharacter(Player.Character)
end
Player.CharacterAdded:Connect(LoadCharacter)


local function PlayEmote(id, name)
    local char = Services.LocalPlayer.Character
    if not char then 
        Rayfield:Notify({Title = "Emote Hatası", Content = "Karakter yüklenmedi, bekle.", Duration = 3})
        return 
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then 
        Rayfield:Notify({Title = "Emote Hatası", Content = "Humanoid bulunamadı.", Duration = 3})
        return 
    end
    -- Mevcut track'i durdur (loop varsa)
    if getgenv().CurrentEmoteTrack then
        getgenv().CurrentEmoteTrack:Stop(0.1)
        getgenv().CurrentEmoteTrack = nil
    end
    -- Animate'i devre dışı bırak (emote öncelikli)
    local animate = char:FindFirstChild("Animate")
    if animate then animate.Disabled = true end
    -- Yeni animasyon yükle ve oynat
    local anim = Instance.new("Animation")
    anim.AnimationId = id
    local track = hum:LoadAnimation(anim)
    track.Looped = getgenv().EmotesLoopMode  -- Loop toggle'ı uygula
    track:Play()
    getgenv().CurrentEmoteTrack = track
    -- Cleanup (anim objesi)
    anim:Destroy()
    Rayfield:Notify({Title = name .. " Oynatılıyor 💃", Content = getgenv().EmotesLoopMode and " (Loop ON)" or " (Tek sefer)", Duration = 2})
end
EmotesTab:CreateToggle({
    Name = "🔄 Loop Mode (Sürekli Oynat)",
    CurrentValue = false,
    Flag = "EmoteLoopFlag",
    Callback = function(val)
        getgenv().EmotesLoopMode = val
        if getgenv().CurrentEmoteTrack then
            getgenv().CurrentEmoteTrack.Looped = val
            Rayfield:Notify({Title = "Loop Güncellendi", Content = val and "ON – Sürekli!" or "OFF – Tek sefer!", Duration = 2})
        end
    end
})
EmotesTab:CreateButton({
    Name = "🛑 Stop Current Emote",
    Callback = function()
        if getgenv().CurrentEmoteTrack then
            getgenv().CurrentEmoteTrack:Stop(0.1)
            getgenv().CurrentEmoteTrack = nil
            local animate = Services.LocalPlayer.Character and Services.LocalPlayer.Character:FindFirstChild("Animate")
            if animate then animate.Disabled = false end
            Rayfield:Notify({Title = "Emote Durduruldu", Content = "Normal animasyona döndü.", Duration = 2})
        else
            Rayfield:Notify({Title = "Uyarı", Content = "Aktif emote yok.", Duration = 2})
        end
    end
})
EmotesTab:CreateToggle({
    Name = "👥 Player Emote SYNC",
    CurrentValue = false, -- Başlangıçta kapalı, ama script varsayılanı aktif eder
    Flag = "SYNCFlag",
    Callback = function(val)
        if features and features.ToggleSYNC then features.ToggleSYNC(val) end -- Direkt eşleme: val true/false'a göre SYNC toggle
    end
})
local Button = EmotesTab:CreateButton({
    Name = "Dev Humanoid Anim Pack (Idle+Run+Jump/Fly...)",
    Callback = function()
        applied = true
        applyAnims()
    end
 })
-- Toggle
EmotesTab:CreateToggle({
    Name = "Animasyon Hızı Aktif",
    CurrentValue = true,
    Flag = "AnimEnabled",
    Callback = function(Value)
        Enabled = Value
        if not Value then
            ApplySpeed(1) -- Kapatınca normale dön
        else
            ApplySpeed(CurrentSpeed)
        end
    end
})

-- Slider
EmotesTab:CreateSlider({
    Name = "Animasyon Hız Çarpanı",
    Range = {0.1, 10},
    Increment = 0.1,
    Suffix = "x",
    CurrentValue = 1,
    Flag = "AnimMultiplier",
    Callback = function(Value)
        CurrentSpeed = Value
        if Enabled then
            ApplySpeed(CurrentSpeed)
        end
    end
})

local emoteSections = {
    {
        title = "Emotes: Developer Section",
        emotes = {
            {name = "susma", id = "rbxassetid://114829008360220"},
            {name = "SkibiDopDop", id = "rbxassetid://98328399081636"},
            {name = "Oyun Havası", id = "rbxassetid://104062506559570"},
            {name = "Turkish Keko Dance", id = "rbxassetid://133841838295129"},
            {name = "Vol1", id = "rbxassetid://121966805049108"},
            {name = "Vol2", id = "rbxassetid://112089880074848"},
            {name = "Vol3", id = "rbxassetid://136491428712959"},
            {name = "Vol4", id = "rbxassetid://96357779735687"}
        }
    },
    {
        title = "Muslim Emotes",
        emotes = {
            {name = "Namaz Kılma", id = "rbxassetid://93009184159377"},
            {name = "Namaz Kılma v2", id = "rbxassetid://127829093804907"}
        }
    },
    {
        title = "Emotes: Popüler Danslar",
        emotes = {
            {name = "GanGam Style", id = "rbxassetid://137133110548904"},
            {name = "Dararara", id = "rbxassetid://115781688996859"},
            {name = "Twice", id = "rbxassetid://14899980745"},
            {name = "Anime", id = "rbxassetid://114774556469581"},
            {name = "keko dans", id = "rbxassetid://133841838295129"},
            {name = "dans", id = "rbxassetid://71494363833326"},
            {name = "dans 2", id = "rbxassetid://113074782746670"},
            {name = "dans 3", id = "rbxassetid://116714406076290"},
            {name = "dans 4", id = "rbxassetid://140333103929828"},
            {name = "dans 5", id = "rbxassetid://102229339944611"},
            {name = "garip dans", id = "rbxassetid://76766009781388"}
        }
    },
    {
        title = "Emotes: Havalı Pozlar",
        emotes = {
            {name = "Aşkını İtiraf Et", id = "rbxassetid://108873777157620"},
            {name = "Billy Zıplaması", id = "rbxassetid://115607052226647"},
            {name = "Boksör", id = "rbxassetid://80933111363555"},
            {name = "oturma", id = "rbxassetid://110071776811205"},
            {name = "domalma", id = "rbxassetid://111057054738672"}
        }
    },
    {
        title = "Emotes: DJ & Parti",
        emotes = {
            {name = "DJ Bekleme Pozu", id = "rbxassetid://114486154887764"},
            {name = "Dougle Dansı", id = "rbxassetid://87574738912971"},
            {name = "Elektro Dansı", id = "rbxassetid://138785676658772"}
        }
    },
    {
        title = "Emotes: Kalça & Zıplama",
        emotes = {
            {name = "Eller Yukarı", id = "rbxassetid://135395608251521"},
            {name = "Garry Dansı", id = "rbxassetid://124896171012585"},
            {name = "Gürültücü", id = "rbxassetid://136095999219650"},
            {name = "twerk", id = "rbxassetid://99457675722909"},
            {name = "twerk gibi bişi", id = "rbxassetid://14548621256"},
            {name = "keko oturusu v2", id = "rbxassetid://84129863420846"}
        }
    },
    {
        title = "Emotes: Havalı & Horeg",
        emotes = {
            {name = "Havalı Tokat", id = "rbxassetid://118552217459650"},
            {name = "Horeg Dansı", id = "rbxassetid://110204898807330"},
            {name = "Jackpot Dansı", id = "rbxassetid://126041249033925"},
            {name = "Die Lit", id = "rbxassetid://134158476680452"}
        }
    },
    {
        title = "Emotes: Kadın & Kafa",
        emotes = {
            {name = "Kadın Dansı", id = "rbxassetid://76240950459288"},
            {name = "Kafa Sallama", id = "rbxassetid://15517864808"},
            {name = "Kalça Dansı", id = "rbxassetid://138671912289772"}
        }
    },
    {
        title = "Emotes: Kedi & Koşma",
        emotes = {
            {name = "Kalça Döndürme", id = "rbxassetid://88593312682192"},
            {name = "Kalça Zıplaması", id = "rbxassetid://103606174140721"},
            {name = "Kedi Dansı", id = "rbxassetid://122639636262924"}
        }
    },
    {
        title = "Emotes: Kıvırma & Michael",
        emotes = {
            {name = "Kendine Çekme", id = "rbxassetid://115605836623904"},
            {name = "Koşma Dansı", id = "rbxassetid://96147994216119"},
            {name = "Kıvırma", id = "rbxassetid://133551169796944"},
            {name = "michael myers", id = "rbxassetid://94751338993179"}
        }
    },
    {
        title = "Emotes: Mutlu & NYC",
        emotes = {
            {name = "Michael Myers Dansı", id = "rbxassetid://130628312209858"},
            {name = "Mutlu", id = "rbxassetid://4841405708"},
            {name = "NYC Dansı", id = "rbxassetid://140333103929828"}
        }
    },
    {
        title = "Emotes: Oryantal & Otur",
        emotes = {
            {name = "Nika Dansı", id = "rbxassetid://132930994178862"},
            {name = "Oryantal", id = "rbxassetid://136494657202841"},
            {name = "Otur", id = "rbxassetid://93120341268524"}
        }
    },
    {
        title = "Emotes: Parti & Popüler",
        emotes = {
            {name = "Parti", id = "rbxassetid://113052435813981"},
            {name = "Popüler", id = "rbxassetid://93062298566806"},
            {name = "Rick Roll", id = "rbxassetid://133608432421494"}
        }
    },
    {
        title = "Emotes: Sağlam & Umursamaz",
        emotes = {
            {name = "Sağlam Dans", id = "rbxassetid://99558490932154"},
            {name = "Umursamaz", id = "rbxassetid://97086109091396"},
            {name = "Uykucu", id = "rbxassetid://10714360343"}
        }
    },
    {
        title = "Emotes: Yat & Zafer",
        emotes = {
            {name = "Yat", id = "rbxassetid://92747295139963"},
            {name = "Zafer Dansı", id = "rbxassetid://15505456446"},
            {name = "Zıplama", id = "rbxassetid://15609995579"},
            {name = "YERE YATMA DELİRME", id = "rbxassetid://98719422024341"},
            {name = "anıme yatma", id = "rbxassetid://115619217455701"}
        }
    },
    {
        title = "Emotes: İmza & Şapşal",
        emotes = {
            {name = "İmza Dansı", id = "rbxassetid://112931882473990"},
            {name = "Şapşal Dans", id = "rbxassetid://85062238386196"}
        }
    },
    {
        title = "Emotes: Idle & Rahat Pozlar",
        emotes = {
            {name = "idle", id = "rbxassetid://102342919277367"},
            {name = "duvara yaslanma idle", id = "rbxassetid://106394178681320"},
            {name = "stres çarkı", id = "rbxassetid://108359356964182"}
        }
    },
    {
        title = "Emotes: Aksiyon & Tekmeler",
        emotes = {
            {name = "tekme", id = "rbxassetid://92249489340640"},
            {name = "uçan tekme", id = "rbxassetid://133566007754001"}
        }
    },
    {
        title = "Emotes: Eğlence & Meme Danslar",
        emotes = {
            {name = "Bully Maguire", id = "rbxassetid://87099200550143"},
            {name = "Tuff", id = "rbxassetid://99195149999804"},
            {name = "One pound fish", id = "rbxassetid://97705611021245"},
            {name = "snops walk", id = "rbxassetid://110204898807330"},
            {name = "nah", id = "rbxassetid://106494344727100"},
            {name = "kalp", id = "rbxassetid://85881727141841"}
        }
    },
    {
        title = "Emotes: Yetişkin Emotes",
        emotes = {
            {name = "foot job", id = "rbxassetid://88421489929073"},
            {name = "sakso", id = "rbxassetid://78354011045319"},
            {name = "sexi", id = "rbxassetid://77780134372141"}
        }
    }
}
for _, section in ipairs(emoteSections) do
    local sec = EmotesTab:CreateSection(section.title)
    for _, emote in ipairs(section.emotes) do
        EmotesTab:CreateButton({
            Name = emote.name .. " 💃",
            Callback = function()
                PlayEmote(emote.id, emote.name)
            end
        })
    end
end
-- Respawn Güvenlik (Emotes için)
Services.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    -- Stop all emotes on respawn
    pcall(function()
        local char = Services.LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                for _, track in pairs(hum:GetPlayingAnimationTracks()) do
                    track:Stop(0.1)
                end
            end
            local animate = char:FindFirstChild("Animate")
            if animate then animate.Disabled = false end
        end
        getgenv().CurrentEmoteTrack = nil
    end)
end)
-- Settings Tab - System Section (Rejoin atlandı)
local SystemSection = SettingsTab:CreateSection("Update")
SettingsTab:CreateParagraph({
    Title = "Version 1.3.10c",
    Content = [[En son güncellemeler ve düzeltmeler (sabit log):
• Update 1.6: Yeni emote Speed Eklendi]]
})
-- Menu & Server Tab - Theme Section
local ThemeSection = MenuServerTab:CreateSection("Theme")
MenuServerTab:CreateColorPicker({
    Name = "Tema Rengi",
    Color = Color3.fromRGB(153, 15, 75), -- Berry başlangıç rengi
    Flag = "ThemeColorFlag",
    Callback = function(Color)
        getgenv().ThemeColor = Color
        CrownPanel.BackgroundColor3 = Color
        cps.Color = Color
    end
})
-- Rejoin Button (Theme section altında)
MenuServerTab:CreateButton({
    Name = "Rejoin",
    Callback = function()
        Services.TeleportService:Teleport(game.PlaceId, Services.LocalPlayer)
    end
})
-- Scripts Section (Altında)
local ScriptsSection = MenuServerTab:CreateSection("Scripts")
-- Load Script Button
MenuServerTab:CreateButton({
    Name = "MYLF HUB",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/meme11.6.lua"))()
    end
})
MenuServerTab:CreateButton({
    Name = "[MYLF HUB] 99 NIGHT NPC",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/MYLFHUB/Anti-obfuscate/main/99nightnpc.lua"))()
    end
})
Rayfield:Notify({
    Title = "CENESENSE | PREMIUM",
    Content = "V 1.3.10c",
    Duration = 1,
    Image = 4483362458
})
-- ═════════════════════════════════════════════ --
-- AUTO RE-INJECT SISTEMI (INFINITE YIELD GIBI)
-- ═════════════════════════════════════════════ --
local queue_on_teleport = (queue_on_teleport or syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport) or (queueonteleport)
if queue_on_teleport then
    spawn(function()
        while wait(1) do
            queue_on_teleport([[
                if not getgenv().CENESENSE_LOADED then
                    getgenv().CENESENSE_LOADED = true
                    loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/MYLFHUB/CENESENSEPremium/main/Cenesense.lua"))() -- BURAYI KENDİ RAW LİNKİNE GÖRE DEĞİŞTİR
                end
            ]])
        end
    end)
end
game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.Started then
        if queue_on_teleport then
            queue_on_teleport([[
                if not getgenv().CENESENSE_LOADED then
                    getgenv().CENESENSE_LOADED = true
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/MYLFHUB/CENESENSEPremium/main/Cenesense.lua"))()
                end
            ]])
        end
    end
end)

