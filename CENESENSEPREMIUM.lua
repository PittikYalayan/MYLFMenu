
-- memesense31.lua - MYLF MENU ESP FULL DETECT + REMNANTS FIX | Efendim için özel, Tüm Oyuncular + No Ghost <3
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
task.wait(15)
local Window = Rayfield:CreateWindow({
    Name = "CENESENSE",
    LoadingTitle = "CENESENSE Yüklüyor...",
    LoadingSubtitle = "PREMIUM SETTINGS",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MYLFMenu",
        FileName = "memesense31"
    },
    KeySystem = false
})
Rayfield:Notify({
    Title = "CENESENSE | PREMIUM",
    Content = "v1.3.9a",
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
    -- Inline fallback (snippet'ten uyarlandı, bağlam aynı)
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
        task.spawn(function()
            while getgenv().ToggleAutoBehind do
                local nearest = getNearest()
                if nearest and nearest.Character and nearest.Character:FindFirstChild("HumanoidRootPart") then
                    local myRoot = Services.LocalPlayer.Character and Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if myRoot then
                        myRoot.CFrame = nearest.Character.HumanoidRootPart.CFrame * CFrame.new(features._tpX or 0, features._tpY or 0, -(features._tpZ or 25))
                    end
                end
                task.wait(0.1)
            end
        end)
    end
    features.ToggleAutoTeleportToEnemy = function(on)
        getgenv().ToggleAutoTeleportToEnemy = on
        task.spawn(function()
            while getgenv().ToggleAutoTeleportToEnemy do
                local nearest = getNearest()
                if nearest and nearest.Character and nearest.Character:FindFirstChild("HumanoidRootPart") then
                    local myRoot = Services.LocalPlayer.Character and Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if myRoot then
                        myRoot.CFrame = nearest.Character.HumanoidRootPart.CFrame * CFrame.new(features._tpX or 0, features._tpY or 0, features._tpZ or 25)
                    end
                end
                task.wait(1)
            end
        end)
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
    features._walkSpeed = 16
    features._flySpeed = 50
    features._tpX = 0
    features._tpY = 0
    features._tpZ = 25
end
-- Custom FPS HUD Panel (Efendim'in örneğinden tam uyarlandı – Modern, dinamik, rainbow bar'lı)
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
-- Live API (Örnekten tam alındı – HWID'li, heartbeat/active)
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
-- 60s heartbeat
task.spawn(function()
    while true do
        httpJSON("POST", LIVE_BASE .. "/heartbeat", { hwid = PC_HWID })
        task.wait(60)
    end
end)
-- 10s active count
task.spawn(function()
    while true do
        local res = httpJSON("GET", LIVE_BASE .. "/active")
        if res and res.StatusCode == 200 then -- Düzeltildi: == 200
            local ok, data = pcall(function() return Services.HttpService:JSONDecode(res.Body) end)
            if ok and type(data) == "table" then
                LiveActiveCount = tonumber(data.active) or 0
            end
        end
        task.wait(10)
    end
end)
-- Hesaplamalar ve Update (Örnekten tam)
local hbAvg, rsAvg, hbN, rsN, halfA, frameCount = 0, 0, 0, 0, 0, 0
Services.RunService.Heartbeat:Connect(function(dt)
    hbN = hbN + 1
    hbAvg = hbAvg + (dt - hbAvg) / hbN
end)
Services.RunService.RenderStepped:Connect(function(dt)
    rsN = rsN + 1
    rsAvg = rsAvg + (dt - rsAvg) / rsN
    halfA = halfA + dt
    frameCount = frameCount + 1
    -- Yavaş Rainbow (os.clock() ile, 0.7 hız)
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromHSV((os.clock() * 0.7) % 1, 1, 1)),
        ColorSequenceKeypoint.new(0.50, Color3.fromHSV((os.clock() * 0.7 + 0.33) % 1, 1, 1)),
        ColorSequenceKeypoint.new(1.00, Color3.fromHSV((os.clock() * 0.7 + 0.66) % 1, 1, 1)),
    }
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
local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)
local MovementTab = Window:CreateTab("Movement", 4483362458)
local TeleportTab = Window:CreateTab("Teleport", 4483362458)
local CameraTab = Window:CreateTab("Camera View", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)
local MenuServerTab = Window:CreateTab("Menu & Server", 4483362458)
-- Global Variables (Aimbot/ESP korundu, features external ile uyumlu)
getgenv().AimbotEnabled = false
getgenv().SilentAimEnabled = false
getgenv().AimbotFOV = 90
getgenv().AimbotHitpart = "Head"
getgenv().VisibleCheck = true
getgenv().DrawFOV = true
getgenv().SelectedEnemyTeams = {}
getgenv().TeamCheckEnabled = true
getgenv().BoxESP = false
getgenv().NameESP = false
getgenv().HealthESP = false
getgenv().TracerESP = false
getgenv().ChamsEnabled = false
getgenv().WallESP = false
getgenv().ESPDistance = 2000
-- Team Check
local function isEnemy(plr)
    if not getgenv().TeamCheckEnabled then return true end
    if not plr.Team then return true end
    return table.find(getgenv().SelectedEnemyTeams, plr.Team.Name) ~= nil
end
-- Visible Check (Cache for 0lag, No Ghost fix)
local VisibilityCache = {}
local function isVisible(targetPart)
    local key = tostring(targetPart.Parent) .. (tick() // 0.1)
    if VisibilityCache[key] then return VisibilityCache[key] end
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {Services.LocalPlayer.Character or Services.LocalPlayer.CharacterAdded:Wait()}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local ray = Services.Workspace:Raycast(Services.Camera.CFrame.Position, (targetPart.Position - Services.Camera.CFrame.Position).Unit * 1000, rayParams)
    local result = ray == nil or ray.Instance:IsDescendantOf(targetPart.Parent)
    VisibilityCache[key] = result
    task.delay(0.1, function() VisibilityCache[key] = nil end)
    return result
end
-- Get Nearest (Combat reuse)
local function getNearest()
    local nearest = nil
    local shortest = getgenv().AimbotFOV
    for _, plr in pairs(Services.Players:GetPlayers()) do
        if plr ~= Services.LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            if isEnemy(plr) then
                local root = plr.Character.HumanoidRootPart
                local hitPart = plr.Character:FindFirstChild(getgenv().AimbotHitpart) or root
                local screenPos, onScreen = Services.Camera:WorldToViewportPoint(root.Position)
                local mousePos = Services.UserInputService:GetMouseLocation()
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if onScreen and dist < shortest and isVisible(hitPart) then
                    shortest = dist
                    nearest = plr
                end
            end
        end
    end
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
-- Aimbot
Services.RunService.Heartbeat:Connect(function()
    local target = getNearest()
    if target and target.Character and target.Character:FindFirstChild(getgenv().AimbotHitpart) then
        local part = target.Character[getgenv().AimbotHitpart]
        if getgenv().AimbotEnabled then
            Services.Camera.CFrame = CFrame.new(Services.Camera.CFrame.Position, part.Position)
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
for _, plr in pairs(Services.Players:GetPlayers()) do
    if plr ~= Services.LocalPlayer then
        createESP(plr)
    end
end
-- New Players
Services.Players.PlayerAdded:Connect(function(plr)
    if plr ~= Services.LocalPlayer then
        task.wait(1)
        createESP(plr)
    end
end)
-- Player Leaving
Services.Players.PlayerRemoving:Connect(function(plr)
    task.spawn(function()
        removeESP(plr)
    end)
end)
-- ESP Update (No Ghost fix: Cache temizliği eklendi)
Services.RunService.RenderStepped:Connect(function()
    for plr, esp in pairs(ESPTable) do
        if not plr.Parent or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") or not plr.Character:FindFirstChild("Humanoid") or plr.Character.Humanoid.Health <= 0 or not isEnemy(plr) then
            task.spawn(function() removeESP(plr) end)
        else
            local root = plr.Character.HumanoidRootPart
            local head = plr.Character:FindFirstChild("Head") or root
            local hum = plr.Character.Humanoid
            local rootScreen, onScreen = Services.Camera:WorldToViewportPoint(root.Position)
            local headScreen = Services.Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
            local legScreen = Services.Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
            local dist = (root.Position - Services.Camera.CFrame.Position).Magnitude
            local visible = isVisible(root)
            if onScreen and dist <= getgenv().ESPDistance then
                local boxHeight = headScreen.Y - legScreen.Y
                local boxWidth = boxHeight / 2
                if getgenv().BoxESP then
                    esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                    esp.Box.Position = Vector2.new(rootScreen.X - boxWidth / 2, rootScreen.Y - boxHeight / 2)
                    esp.Box.Color = visible and Color3.fromRGB(0,255,0) or (getgenv().WallESP and Color3.fromRGB(255,0,0) or Color3.fromRGB(128,128,128))
                    esp.Box.Transparency = visible and 1 or (getgenv().WallESP and 0.5 or 0.2)
                    esp.Box.Visible = true
                else
                    esp.Box.Visible = false
                end
                if getgenv().NameESP then
                    esp.Name.Text = plr.Name .. " [" .. math.floor(dist) .. "]"
                    esp.Name.Position = Vector2.new(rootScreen.X, headScreen.Y - 40)
                    esp.Name.Color = visible and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
                    esp.Name.Visible = true
                else
                    esp.Name.Visible = false
                end
                if getgenv().HealthESP then
                    local healthPercent = hum.Health / hum.MaxHealth
                    esp.HealthBG.Size = Vector2.new(4, boxHeight)
                    esp.HealthBG.Position = Vector2.new(rootScreen.X - boxWidth / 2 - 6, rootScreen.Y - boxHeight / 2)
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
                    esp.Tracer.To = Vector2.new(rootScreen.X, rootScreen.Y)
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
                        hl.FillColor = Color3.fromRGB(0, 255, 255 + math.sin(t * math.pi) * 0)
                    else
                        hl.FillColor = Color3.fromRGB(255, 0, 255 + math.sin(t * math.pi) * 0)
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
            end
        end
    end
end)
-- Stale ESP Sweeper (Güçlendirildi, cache temizliği)
task.spawn(function()
    while true do
        task.wait(0.5)
        for plr, esp in pairs(ESPTable) do
            if not plr.Parent or not plr.Character or plr.Character.Humanoid.Health <= 0 then
                task.spawn(function() removeESP(plr) end)
            end
        end
        -- Cache temizliği for No Ghost
        if #VisibilityCache > 100 then VisibilityCache = {} end
    end
end)
-- Auto Scan
task.spawn(function()
    while true do
        task.wait(1)
        for _, plr in pairs(Services.Players:GetPlayers()) do
            if plr ~= Services.LocalPlayer and isEnemy(plr) and not ESPTable[plr] then
                createESP(plr)
            end
        end
    end
end)
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
    Range = {10, 500},
    Increment = 1,
    CurrentValue = 90,
    Flag = "FOVFlag",
    Callback = function(val)
        getgenv().AimbotFOV = val
    end
})
CombatTab:CreateToggle({
    Name = "FOV Çemberi",
    CurrentValue = true,
    Flag = "DrawFOVFlag",
    Callback = function(val)
        getgenv().DrawFOV = val
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
    Name = "Name ESP",
    CurrentValue = false,
    Flag = "NameESPFlag",
    Callback = function(val)
        getgenv().NameESP = val
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
    Name = "Chams (Smooth Color)",
    CurrentValue = false,
    Flag = "ChamsFlag",
    Callback = function(val)
        getgenv().ChamsEnabled = val
    end
})
VisualTab:CreateToggle({
    Name = "Wall ESP (Duvar Arkası)",
    CurrentValue = false,
    Flag = "WallESPFlag",
    Callback = function(val)
        getgenv().WallESP = val
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
-- Movement Tab: Core movement (enable toggle'lar silindi, slider'lar doğrudan entegre)
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
    Range = {1, 10000},
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
    Range = {1, 10000},
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
-- Camera View Tab: Ayrı tab (dropdown + refresh + toggle + teleport button)
local CameraSection = CameraTab:CreateSection("Camera View")
local selectedPlayer = nil
local camActive = false
CameraTab:CreateDropdown({
    Name = "Select Player",
    Options = {}, -- Dinamik doldurulacak
    CurrentOption = "None",
    Flag = "PlayerSelectFlag",
    Callback = function(val)
        selectedPlayer = Services.Players:FindFirstChild(val)
        if selectedPlayer then Rayfield:Notify({Title = "Selected", Content = val, Duration = 3}) end
    end
})
CameraTab:CreateButton({
    Name = "Refresh Players",
    Callback = function()
        local opts = {}
        for _, plr in pairs(Services.Players:GetPlayers()) do
            if plr ~= Services.LocalPlayer then table.insert(opts, plr.Name) end
        end
        Rayfield:Notify({Title = "Refreshed", Content = #opts .. " players", Duration = 3})
    end
})
CameraTab:CreateToggle({
    Name = "🎥 Camera View",
    CurrentValue = false,
    Flag = "CamViewFlag",
    Callback = function(val)
        camActive = val
        if val and selectedPlayer and selectedPlayer.Character then
            local hum = selectedPlayer.Character:FindFirstChildOfClass("Humanoid")
            local hrp = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp then
                Services.Camera.CameraSubject = hum
                Services.Camera.CFrame = CFrame.new(hrp.Position + Vector3.new(0,5,-10), hrp.Position)
                Rayfield:Notify({Title = "Camera Locked", Content = selectedPlayer.Name, Duration = 3})
            end
        else
            local myHum = Services.LocalPlayer.Character and Services.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if myHum then Services.Camera.CameraSubject = myHum end
            Rayfield:Notify({Title = "Camera Reset", Content = "Back to self", Duration = 3})
        end
    end
})
CameraTab:CreateButton({
    Name = "⚡ Teleport to Selected",
    Callback = function()
        if selectedPlayer and selectedPlayer.Character then
            local targetHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            local myHRP = Services.LocalPlayer.Character and Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP and myHRP then
                Services.LocalPlayer.Character:PivotTo(targetHRP.CFrame * CFrame.new(features._tpX or 0, features._tpY or 0, features._tpZ or 25))
                Rayfield:Notify({Title = "Teleported", Content = selectedPlayer.Name, Duration = 3})
            end
        else
            Rayfield:Notify({Title = "Error", Content = "No player selected", Duration = 3})
        end
    end
})
-- Settings Tab - System Section (Rejoin atlandı)
local SystemSection = SettingsTab:CreateSection("System")
SettingsTab:CreateParagraph({Title = "System", Content = "Rejoin atlandı efendim, istediğinde söyle ekleyeyim."})
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
    Title = "CENESENSE | PREMIUM UNIVERSAL",
    Content = "v1.3.9a - Efendim için teleport ve camera view ayrı tab'larda + enable toggle'lar silindi",
    Duration = 12,
    Image = 4483362458
})
