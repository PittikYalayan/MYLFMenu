-- ═══════════════════════════════════════════════ --
-- memesense31.lua - MYLF MENU ESP FULL DETECT + REMNANTS FIX | Efendim için özel, Tüm Oyuncular + No Ghost <3
-- ═══════════════════════════════════════════════ --
-- Zaten yüklendiyse tekrar yükleme (anti-duplicate)
if getgenv().CENESENSE_LOADED then
    print("CENESENSE zaten yüklü, tekrar yüklenmedi.")
    return
end
getgenv().CENESENSE_LOADED = true
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
    LoadingSubtitle = "v1.3.05",
    Duration = 6,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MYLFMenu",
        FileName = "memesense31"
    },
    KeySystem = false
})
Rayfield:Notify({
    Title = "CENESENSE | PREMIUM",
    Content = "v1.3.0a - REFRESH + CAMERA ULTIMATE FIX + EMOTES TAB",
    Duration = 10,
    Image = 4483362458
})
-- Features'i external linkten yükle (bağlam uyumlu, error handling ile – hata verirse inline fallback)
local success, features = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features1.5.5.lua"))()
end)
if not success then
    Rayfield:Notify({
        Title = "Features Load Error",
        Content = "External features yüklenemedi, inline fallback kullanılıyor.",
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
    features.ToggleInfiniteJump = function(on)
        getgenv().ToggleInfiniteJump = on
        if on then
            local conn = Services.UserInputService.JumpRequest:Connect(function()
                local char = Services.LocalPlayer.Character
                if char and char:FindFirstChildOfClass("Humanoid") then
                    char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
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
    {name = "?", id = "rbxassetid://121966805049108"},
    {name = "??", id = "rbxassetid://112089880074848"},
    {name = "???", id = "rbxassetid://136491428712959"},
    {name = "????", id = "rbxassetid://96357779735687"},
    {name = "?keko?", id = "rbxassetid://133841838295129"}, -- keko dans ile çakışıyor, ama eskiyi korudum; isterseniz birleştiririm
    {name = "GanGam Style", id = "rbxassetid://14618196485"},
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
-- UI Elements (Team/Combat/Visual korundu, features external ile toggle'lar bağlandı)
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
         if features.ToggleSkeleton then features.ToggleSkeleton(val) end
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
         if features.ToggleBox then features.ToggleBox(val) end
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
         if features.ToggleRainbowName then features.ToggleRainbowName(val) end
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
         if features.ToggleTracers then features.ToggleTracers(val) end
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
         if features.ToggleGlow then features.ToggleGlow(val) end
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
        if features.ToggleSpeed then features.ToggleSpeed(val) end
    end
})
MovementTab:CreateSlider({
    Name = "Walk Speed",
    Range = {1, 400},
    Increment = 1,
    CurrentValue = features._walkSpeed or 16,
    Flag = "WalkSpeedFlag",
    Callback = function(val)
        if features._walkSpeed then features._walkSpeed = val end
        if features.SetWalkSpeed then features.SetWalkSpeed(val) end
    end
})
MovementTab:CreateToggle({
    Name = "🕊️ Fly (LCtrl down)",
    CurrentValue = false,
    Flag = "FlyFlag",
    Callback = function(val)
        if features.ToggleFly then features.ToggleFly(val) end
    end
})
MovementTab:CreateSlider({
    Name = "Fly Speed",
    Range = {1, 400},
    Increment = 1,
    CurrentValue = features._flySpeed or 50,
    Flag = "FlySpeedFlag",
    Callback = function(val)
        if features.SetFlySpeed then features.SetFlySpeed(val) end
    end
})
MovementTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJumpFlag",
    Callback = function(val)
        if features.ToggleInfiniteJump then features.ToggleInfiniteJump(val) end
    end
})
MovementTab:CreateToggle({
    Name = "👻 Hard Invisible",
    CurrentValue = false,
    Flag = "HardInvisibleFlag",
    Callback = function(val)
        if features.ToggleHardInvisible then features.ToggleHardInvisible(val) end
    end
})
MovementTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Flag = "NoclipFlag",
    Callback = function(val)
        if features.ToggleNoclip then features.ToggleNoclip(val) end
    end
})
-- Teleport Tab: Tüm teleport özellikleri + auto farm/behind + X Y Z slider'lar
local TeleportSection = TeleportTab:CreateSection("Teleport Features")
TeleportTab:CreateToggle({
    Name = "Teleport (T Key)",
    CurrentValue = false,
    Flag = "TeleportFlag",
    Callback = function(val)
        if features.ToggleTeleport then features.ToggleTeleport(val) end
    end
})
TeleportTab:CreateToggle({
    Name = "⚡ Always Behind Enemy",
    CurrentValue = false,
    Flag = "AutoBehindFlag",
    Callback = function(val)
        if features.ToggleAutoBehind then features.ToggleAutoBehind(val) end
    end
     
})
TeleportTab:CreateToggle({
    Name = "⚡ Auto Farm Enemy",
    CurrentValue = false,
    Flag = "AutoFarmFlag",
    Callback = function(val)
        if features.ToggleAutoTeleportToEnemy then features.ToggleAutoTeleportToEnemy(val) end
    end
})
TeleportTab:CreateSlider({
    Name = "X Offset",
    Range = {-50, 50},
    Increment = 1,
    CurrentValue = features._tpX or 0,
    Flag = "tpXFlag",
    Callback = function(val)
        if features._tpX then features._tpX = val end
        if features.SetTeleportOffset then features.SetTeleportOffset(val, features._tpY or 0, features._tpZ or 25) end
    end
})
TeleportTab:CreateSlider({
    Name = "Y Offset",
    Range = {-50, 50},
    Increment = 1,
    CurrentValue = features._tpY or 0,
    Flag = "tpYFlag",
    Callback = function(val)
        if features._tpY then features._tpY = val end
        if features.SetTeleportOffset then features.SetTeleportOffset(features._tpX or 0, val, features._tpZ or 25) end
    end
})
TeleportTab:CreateSlider({
    Name = "Z Offset",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = features._tpZ or 25,
    Flag = "tpZFlag",
    Callback = function(val)
        if features._tpZ then features._tpZ = val end
        if features.SetTeleportOffset then features.SetTeleportOffset(features._tpX or 0, features._tpY or 0, val) end
    end
})
-- Camera View Tab: FREE ORBIT CAMERA - Mouse ile özgür dön, zoom, FPS drop yok, ultra smooth RenderStepped
-- MULTIPLE OPTIONS: Dropdown multi-select, camera average center for group view, teleport sequential
local CameraSection = CameraTab:CreateSection("Camera View")
local selectedPlayers = {} -- CHANGED: Table for multiple
local camActive = false
local playerDropdown = nil -- FIXED: Global dropdown ref for destroy
local lastRefreshTime = 0 -- FIXED: Debounce for manual refresh
local characterAddedConns = {} -- CHANGED: Array for multiple respawn handling
local playerListCache = {} -- NEW: Cache for fast change detection (optimize, no loop spam)
-- FREE CAMERA VARS: Yaw/Pitch/Distance for orbit (radyan)
local yaw = math.rad(180) -- Başlangıç: Arkadan bakar
local pitch = math.rad(-15) -- Hafif yukarı
local distance = 20 -- Başlangıç mesafe
local minDistance = 5
local maxDistance = 150
local cameraRenderConn = nil -- RenderStepped for ultra smooth NO LAG
local mouseMoveConn = nil -- UserInputService for mouse delta
local mouseWheelConn = nil -- Zoom
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Players = game:GetService("Players")
local function getPlayerOptions()
    local opts = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer then
            table.insert(opts, plr.Name)
        end
    end
    return opts
end
local function createPlayerDropdown()
    if playerDropdown then playerDropdown:Destroy() end
    local opts = getPlayerOptions()
    playerDropdown = CameraTab:CreateDropdown({
        Name = "Select Players (Multi)",
        Options = opts,
        CurrentOption = {}, -- CHANGED: Empty table for multi
        MultipleOptions = true, -- NEW: Multiple selection ✅
        Flag = "PlayerSelectFlag",
        Callback = function(val) -- val: table of names
            -- Eski conn'ları disconnect
            for _, conn in ipairs(characterAddedConns) do conn:Disconnect() end
            characterAddedConns = {}
            selectedPlayers = {}
            for _, name in ipairs(val) do
                local plr = Players:FindFirstChild(name)
                if plr then
                    table.insert(selectedPlayers, plr)
                    -- Multi respawn relock
                    local conn = plr.CharacterAdded:Connect(function()
                        if camActive then
                            task.wait(0.1) -- Ultra fast
                        end
                    end)
                    table.insert(characterAddedConns, conn)
                end
            end
            if #selectedPlayers > 0 then
                local names = {}
                for _, plr in selectedPlayers do table.insert(names, plr.Name) end
                Rayfield:Notify({Title = "Selected ✅", Content = table.concat(names, ", ") .. " - Hazır! (Multi destekli)", Duration = 3})
            else
                Rayfield:Notify({Title = "Error ❌", Content = "Oyuncu bulunamadı, yeniden seç", Duration = 3})
            end
        end
    })
end
-- INITIAL CREATE
createPlayerDropdown()
-- AUTO REFRESH: Event-based + Heartbeat minimal check (ultra fast, no lag)
local function refreshDropdownIfChanged()
    local currentPlayers = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer then
            currentPlayers[plr.Name] = true
        end
    end
    local changed = false
    for name in pairs(playerListCache) do
        if not currentPlayers[name] then changed = true break end
    end
    for name in pairs(currentPlayers) do
        if not playerListCache[name] then changed = true break end
    end
    if changed then
        playerListCache = currentPlayers
        createPlayerDropdown() -- Auto recreate on change
        -- Check selectedPlayers for left players
        local toRemove = {}
        for i, plr in ipairs(selectedPlayers) do
            if not Players:FindFirstChild(plr.Name) then
                table.insert(toRemove, i)
            end
        end
        for _, idx in ipairs(toRemove) do
            table.remove(selectedPlayers, idx)
        end
        if #toRemove > 0 then
            Rayfield:Notify({Title = "Uyarı ⚠️", Content = #toRemove .. " oyuncu ayrıldı, liste güncellendi", Duration = 3})
        end
    end
end
-- EVENTS: Player eklen/çıkınca direkt trigger (en hızlı)
Players.PlayerAdded:Connect(refreshDropdownIfChanged)
Players.PlayerRemoving:Connect(refreshDropdownIfChanged)
-- HEARTBEAT: Her frame check (0.016s ~0.01ms yakın, ama event'lar ana trigger)
local autoRefreshConn = RS.Heartbeat:Connect(refreshDropdownIfChanged)
-- MANUAL REFRESH (hala var, ama auto yüzünden nadir kullan)
CameraTab:CreateButton({
    Name = "Refresh Players (Manual)",
    Callback = function()
        local now = tick()
        if now - lastRefreshTime < 1 then
            Rayfield:Notify({Title = "Cooldown", Content = "Bekle 1s", Duration = 2})
            return
        end
        lastRefreshTime = now
        refreshDropdownIfChanged()
        Rayfield:Notify({Title = "Refreshed ✅", Content = "Liste güncellendi (Auto zaten yapıyor!)", Duration = 3})
    end
})
-- FREE ORBIT CAMERA CORE: Multi-player support - Average center + auto distance
local function lockCameraToPlayer(targetPlayers, active)
    -- Tüm conn'ları temizle
    if cameraRenderConn then cameraRenderConn:Disconnect() cameraRenderConn = nil end
    if mouseMoveConn then mouseMoveConn:Disconnect() mouseMoveConn = nil end
    if mouseWheelConn then mouseWheelConn:Disconnect() mouseWheelConn = nil end
   
    if not active or #targetPlayers == 0 then
        Services.Camera.CameraType = Enum.CameraType.Custom
        local myHum = Services.LocalPlayer.Character and Services.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if myHum then Services.Camera.CameraSubject = myHum end
        return
    end
   
    Services.Camera.CameraType = Enum.CameraType.Scriptable
   
    -- MOUSE DELTA SENSITIVITY (optimize: low for smooth)
    local sensitivity = 0.005 -- Radyan per pixel, FPS drop yok
   
    -- Mouse Move: Yaw/Pitch update (sadece mouse move'de, efficient)
    mouseMoveConn = UIS.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            yaw = yaw - input.Delta.X * sensitivity
            pitch = math.clamp(pitch - input.Delta.Y * sensitivity, math.rad(-80), math.rad(80)) -- Pitch limit (ters dönmesin)
        end
    end)
   
    -- Mouse Wheel: Zoom (ultra responsive)
    mouseWheelConn = UIS.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseWheel then
            distance = math.clamp(distance - input.Position.Z * 2, minDistance, maxDistance)
        end
    end)
   
    -- RENDER STEPPED LOOP: Ultra smooth, NO LAG, her frame update (Roblox optimized)
    cameraRenderConn = RS.RenderStepped:Connect(function()
        pcall(function()
            local positions = {}
            for _, plr in ipairs(targetPlayers) do
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    table.insert(positions, plr.Character.HumanoidRootPart.Position)
                end
            end
            if #positions > 0 then
                -- Average center for multi
                local center = Vector3.new(0,0,0)
                for _, pos in positions do center = center + pos end
                center = center / #positions
               
                -- Auto distance adjust for bounds (multi için hepsi framede olsun)
                local maxDist = 0
                for _, pos in positions do
                    local dist = (pos - center).Magnitude
                    if dist > maxDist then maxDist = dist end
                end
                local effectiveDist = math.max(distance, maxDist * 1.5) -- Zoom override if needed
               
                -- SPHERICAL ORBIT CALC: Özgür açı + mesafe
                local camCFrame = CFrame.new(center) * CFrame.Angles(pitch, yaw, 0) * CFrame.new(0, 0, -effectiveDist)
               
                Services.Camera.CFrame = camCFrame
            end
        end)
    end)
end
CameraTab:CreateToggle({
    Name = "🎥 Free Camera View", -- Özgür mouse dön/zoom, ultra optimize, multi-player center
    CurrentValue = false,
    Flag = "CamViewFlag",
    Callback = function(val)
        if #selectedPlayers == 0 then
            Rayfield:Notify({Title = "Error ❌", Content = "Önce oyuncu(lar) seç! (Multi destekli)", Duration = 3})
            return false -- Toggle'ı kapat
        end
        camActive = val
        lockCameraToPlayer(selectedPlayers, val)
        if val then
            local names = {}
            for _, plr in selectedPlayers do table.insert(names, plr.Name) end
            Rayfield:Notify({Title = "Free Cam ON ✅", Content = table.concat(names, ", ") .. " - Mouse ile dön/zoom (wheel)", Duration = 4})
        else
            Rayfield:Notify({Title = "Free Cam OFF", Content = "Normal kameraya döndü", Duration = 3})
        end
    end
})
-- LocalPlayer respawn: Relock
Services.LocalPlayer.CharacterAdded:Connect(function()
    if camActive and #selectedPlayers > 0 then
        task.wait(0.1)
        lockCameraToPlayer(selectedPlayers, true)
    end
end)
-- BONUS: Reset Angles Button (multi için de çalışır)
CameraTab:CreateButton({
    Name = "🔄 Reset Camera Angles",
    Callback = function()
        if #selectedPlayers > 0 then
            yaw = math.rad(180)
            pitch = math.rad(-15)
            distance = 20
            Rayfield:Notify({Title = "Reset ✅", Content = "Arkadan bakışa döndü (Multi center)", Duration = 2})
        else
            Rayfield:Notify({Title = "Error ❌", Content = "Önce oyuncu(lar) seç!", Duration = 2})
        end
    end
})
CameraTab:CreateButton({
    Name = "⚡ Teleport to Selected (Multi Sequential)",
    Callback = function()
        if #selectedPlayers == 0 then
            Rayfield:Notify({Title = "Error ❌", Content = "Önce oyuncu(lar) seç! (Multi destekli)", Duration = 3})
            return
        end
        task.spawn(function()
            for _, targetPlr in ipairs(selectedPlayers) do
                local maxRetries = 10
                local retries = 0
                while retries < maxRetries do
                    if targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart") then
                        local targetHRP = targetPlr.Character.HumanoidRootPart
                        local myChar = Services.LocalPlayer.Character
                        if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                            local myHRP = myChar.HumanoidRootPart
                            myHRP.CFrame = targetHRP.CFrame * CFrame.new(features._tpX or 0, features._tpY or 0, features._tpZ or 25)
                            Rayfield:Notify({Title = "Teleported ✅", Content = targetPlr.Name .. " - Başarılı! (Multi devam ediyor)", Duration = 3})
                            break
                        end
                    end
                    retries = retries + 1
                    task.wait(1)
                end
                if retries >= maxRetries then
                    Rayfield:Notify({Title = "Error ❌", Content = targetPlr.Name .. " - Retry failed", Duration = 3})
                end
                task.wait(1) -- Multi için delay, spam olmasın
            end
        end)
    end
})
-- CLEANUP: Script destroy'da conn'ları disconnect (gerekli değil ama ekstra clean)
script.Destroying:Connect(function()
    if autoRefreshConn then autoRefreshConn:Disconnect() end
    for _, conn in ipairs(characterAddedConns) do conn:Disconnect() end
end)
-- Emote Buttons (Her emote için button, Rayfield ile gruplanmış)
-- DÜZELTME: Emote Controls Section + PlayEmote Fonksiyonu (callback hatası için zorunlu)
local EmoteControlSection = EmotesTab:CreateSection("Emote Controls")
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
        features.ToggleSYNC(val) -- Direkt eşleme: val true/false'a göre SYNC toggle
    end
})
local emoteSections = {
    {
        title = "Emotes: Developer Section",
        emotes = {
            {name = "?", id = "rbxassetid://121966805049108"},
            {name = "??", id = "rbxassetid://112089880074848"},
            {name = "???", id = "rbxassetid://136491428712959"},
            {name = "????", id = "rbxassetid://96357779735687"},
            {name = "?keko?", id = "rbxassetid://133841838295129"},
            {name = "Namaz Kılma", id = "rbxassetid://93009184159377"},
            {name = "Namaz Kılma v2", id = "rbxassetid://127829093804907"}
        }
    },
    {
        title = "Emotes: Popüler Danslar",
        emotes = {
            {name = "GanGam Style", id = "rbxassetid://14618196485"},
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
    Title = "Version 1.3.05",
    Content = [[En son güncellemeler ve düzeltmeler (sabit log):
• Fix: Menüde Oluşan Bir Aksaklık Giderildi Kullanıma Hazır Hale Getirildi.
• Update: Camera View Update Getirildi Herşey Daha Gerçekci Oyuncu Kamerası Gibi Hareket Sağlandı.
        Version 1.3.0a
        En son güncellemeler ve düzeltmeler (sabit log):
• Update 1.5: Yeni emote'lar (twerk, keko dans vb.) entegre edildi.
• Fix: ID çakışmaları ve isim parse hataları giderildi.
• Update 1.4: Sections kategorileri optimize edildi.
• Fix: Flat emotes listesi ile sections tam uyumlu hale getirildi.!
• Fix 1.3.0a: Emote callback hatası (PlayEmote + SYNC fallback) giderildi.]]        
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
    Name = "MYLF PREMIUM",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/meme11.6.lua"))()
    end
})
Rayfield:Notify({
    Title = "CENESENSE | PREMIUM",
    Content = "v1.3.05 - Updated",
    Duration = 12,
    Image = 4483362458
})
-- ════════════════════════════════════════════════ --
-- AUTO RE-INJECT SİSTEMİ (INFINITE YIELD GİBİ)
-- ════════════════════════════════════════════════ --
local queue_on_teleport = (queue_on_teleport or syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport) or (queueonteleport)
game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.Started then
        if queue_on_teleport then
            queue_on_teleport([[
                if getgenv().CENESENSE_LOADED then
                    print("CENESENSE zaten yüklü, tekrar yüklenmedi.")
                    return
                end
                loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/CENESENSEPREMIUM.lua"))()
                getgenv().CENESENSE_LOADED = true
            ]])
        end
    end
end)
print("CENESENSE | REINJECT OPTIMIZED + CAMERA RESPAWN FIX + EMOTES INTEGRASYON")
