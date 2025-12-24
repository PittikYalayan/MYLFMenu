


local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "MYLF HUB - DOORS",
    LoadingTitle = "MYLF HUB - DOORS",
    LoadingSubtitle = "Doors v1.3.10c",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = nil,
        FileName = "DoorsESP"
    }
})

local Tab = Window:CreateTab("ESP Ayarlari", nil) -- Fluent tab

-- Kategori: Toggle Tanimlamalari (OFF baslar)
local toggles = {
    Entity2DBox = false,
    EntityHighlight = false,
    KeyLeverESP = false,
    DoorESP = false,
    SmartTorch = false,
    LibraryBooksESP = false
}

-- Kategori: Servisler & Degiskenler
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local Services = {HttpService = game:GetService("HttpService"), LocalPlayer = Players.LocalPlayer, RunService = RunService, Stats = Stats}  -- HUD fix: RunService ve Stats eklendi!
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local highlights = {}
local lights = {}
local drawings = {}  -- {model = {box = Drawing, name = Drawing}}

local entityNames = {"Rush","RushMoving","Ambush","Seek","Figure","FigureRig","Screech","Eyes","Halt","Jack","Hide","Dupe","Glitch","Spider","Bottom","TentacleD","TentacleE","Dread","ScreechRetro"}
local itemNames = {"Key","Lever"}
local bookNames = {"Book"}

local knownEntities = {}
local knownItems = {}
local knownBooks = {}

local RED = Color3.fromRGB(255,0,0)
local GREEN = Color3.fromRGB(0,255,0)
local CYAN = Color3.fromRGB(0,255,255)
local ORANGE = Color3.fromRGB(255,165,0)
local YELLOW = Color3.fromRGB(255,255,0)

local DOOR_BRIGHTNESS = 1.2
local DOOR_RANGE = 15
local DOOR_FILL_TRANS = 0.6
local ITEM_BRIGHTNESS = 2.0
local ITEM_RANGE = 20

local torchLight = nil

-- Kategori: Yardimci Fonksiyonlar
local function distanceFromPlayer(part)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return math.huge end
    return (part.Position - player.Character.HumanoidRootPart.Position).Magnitude
end

local function removeHighlightAndLight(part)
    if highlights[part] then highlights[part]:Destroy() highlights[part] = nil end
    if lights[part] then lights[part]:Destroy() lights[part] = nil end
end

local function addFluentHighlight(part, color, isDoor, isItem, isBook)
    if distanceFromPlayer(part) > 500 then return end
    
    local existing = highlights[part]
    if existing and existing.FillColor == color then return end
    
    if existing then removeHighlightAndLight(part) end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPHighlight"
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = part
    highlight.Parent = part
    
    local targetTrans = isDoor and DOOR_FILL_TRANS or 0.4
    TweenService:Create(highlight, TweenInfo.new(0.8), {FillTransparency = targetTrans}):Play()
    
    highlight.Enabled = (isDoor and toggles.DoorESP) or (isItem and toggles.KeyLeverESP) or (isBook and toggles.LibraryBooksESP) or toggles.EntityHighlight
    
    highlights[part] = highlight
    
    if isDoor and toggles.DoorESP and distanceFromPlayer(part) < 100 then
        local light = Instance.new("PointLight")
        light.Color = color
        light.Brightness = 0
        light.Range = DOOR_RANGE
        light.Parent = part
        TweenService:Create(light, TweenInfo.new(1.0), {Brightness = DOOR_BRIGHTNESS}):Play()
        lights[part] = light
    end
    
    if (isItem and toggles.KeyLeverESP or isBook and toggles.LibraryBooksESP) and distanceFromPlayer(part) < 150 then
        local light = Instance.new("PointLight")
        light.Color = color
        light.Brightness = 0
        light.Range = ITEM_RANGE
        light.Parent = part
        TweenService:Create(light, TweenInfo.new(1.0), { Brightness = ITEM_BRIGHTNESS}):Play()
        lights[part] = light
    end
end

-- Kategori: 2D Box & Name Fonksiyonlari
local function create2DBoxAndName(model)
    if drawings[model] then return end
    
    local box = Drawing.new("Square")
    box.Thickness = 3
    box.Transparency = 1
    box.Filled = false
    box.Visible = toggles.Entity2DBox
    
    local nameText = Drawing.new("Text")
    nameText.Text = model.Name:upper()
    nameText.Size = 28
    nameText.Font = Drawing.Fonts.Monospace
    nameText.Outline = true
    nameText.Transparency = 1
    nameText.Visible = toggles.Entity2DBox
    
    drawings[model] = {box = box, name = nameText}
end

local function update2DBoxAndName(model)
    local data = drawings[model]
    if not data then return end
    
    local rootPart = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChildOfClass("BasePart")
    if not rootPart or distanceFromPlayer(rootPart) > 500 then
        data.box.Visible = false
        data.name.Visible = false
        return
    end
    
    local vector, onScreen = camera:WorldToViewportPoint(rootPart.Position)
    if not onScreen then
        data.box.Visible = false
        data.name.Visible = false
        return
    end
    
    local size = math.max(40 / (distanceFromPlayer(rootPart) / 10), 20)
    data.box.Size = Vector2.new(size, size * 1.5)
    data.box.Position = Vector2.new(vector.X - data.box.Size.X / 2, vector.Y - data.box.Size.Y / 2)
    data.box.Visible = toggles.Entity2DBox
    
    local hue = (tick() % 5) / 5
    data.box.Color = Color3.fromHSV(hue, 1, 1)
    
    data.name.Position = Vector2.new(vector.X - data.box.Size.X / 2, vector.Y - data.box.Size.Y / 2 - data.name.Size - 5)
    data.name.Color = Color3.fromHSV(hue + 0.1, 1, 1)
    data.name.Visible = toggles.Entity2DBox
end

local function remove2DBoxAndName(model)
    if drawings[model] then
        drawings[model].box:Remove()
        drawings[model].name:Remove()
        drawings[model] = nil
    end
end

-- Kategori: Tracking Fonksiyonlari
local function trackEntity(child)
    if table.find(entityNames, child.Name) and child:IsA("Model") then
        knownEntities[child] = true
        if toggles.EntityHighlight then
            for _, part in pairs(child:GetChildren()) do
                if part:IsA("BasePart") then
                    addFluentHighlight(part, RED, false, false, false)
                end
            end
        end
        create2DBoxAndName(child)
        print("Entity tracked: " .. child.Name)
    end
end

local function trackItem(child)
    if table.find(itemNames, child.Name) and child:IsA("Model") then
        knownItems[child] = true
        if toggles.KeyLeverESP then
            for _, part in pairs(child:GetChildren()) do
                if part:IsA("BasePart") then
                    addFluentHighlight(part, CYAN, false, true, false)
                end
            end
        end
        print("Item tracked: " .. child.Name)
    end
end

local function trackBook(child)
    if table.find(bookNames, child.Name) and child:IsA("Model") then
        knownBooks[child] = true
        if toggles.LibraryBooksESP then
            for _, part in pairs(child:GetChildren()) do
                if part:IsA("BasePart") then
                    addFluentHighlight(part, YELLOW, false, false, true)
                end
            end
        end
        print("Book tracked: " .. child.Name)
    end
end

-- Kategori: Workspace Event'leri
workspace.ChildAdded:Connect(function(child)
    trackEntity(child)
    trackItem(child)
    trackBook(child)
end)

workspace.ChildRemoved:Connect(function(child)
    if knownEntities[child] then
        for _, part in pairs(child:GetChildren()) do
            if highlights[part] then removeHighlightAndLight(part) end
        end
        remove2DBoxAndName(child)
        knownEntities[child] = nil
    elseif knownItems[child] then
        for _, part in pairs(child:GetChildren()) do
            if highlights[part] then removeHighlightAndLight(part) end
        end
        knownItems[child] = nil
    elseif knownBooks[child] then
        for _, part in pairs(child:GetChildren()) do
            if highlights[part] then removeHighlightAndLight(part) end
        end
        knownBooks[child] = nil
    end
end)

for _, child in pairs(workspace:GetChildren()) do
    trackEntity(child)
    trackItem(child)
    trackBook(child)
end

-- Kategori: Door Scan Fonksiyonu
local function scanDoors()
    if not toggles.DoorESP then return end
    
    local currentRoomNum = player:GetAttribute("CurrentRoom")
    if not currentRoomNum or type(currentRoomNum) ~= "number" then return end
    local currentRooms = workspace:FindFirstChild("CurrentRooms")
    if not currentRooms then return end
    
    for _, room in pairs(currentRooms:GetChildren()) do
        local doorModel = room:FindFirstChild("Door")
        if doorModel then
            local doorPart = doorModel:FindFirstChild("Door")
            if doorPart and doorPart:IsA("BasePart") then
                local isCorrect = tonumber(room.Name) == currentRoomNum
                addFluentHighlight(doorPart, isCorrect and GREEN or RED, true, false, false)
            end
        end
    end
end

-- Kategori: Akilli Mesale Fonksiyonlari
local function updateTorchLight()
    if not torchLight or not torchLight.Parent or not toggles.SmartTorch then return end
    local isDark = Lighting.Brightness < 1.2 and Lighting.Ambient == Color3.new(0,0,0)
    local targetBrightness = isDark and 1.8 or 0
    TweenService:Create(torchLight, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {Brightness = targetBrightness}):Play()
end

local function addSmartTorchLight(char)
    local hand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm") or char:FindFirstChild("Head")
    if not hand then return end
    
    if hand:FindFirstChild("SmartTorchLight") then
        torchLight = hand.SmartTorchLight
        return
    end
    
    torchLight = Instance.new("PointLight")
    torchLight.Name = "SmartTorchLight"
    torchLight.Color = ORANGE
    torchLight.Brightness = 0
    torchLight.Range = 35
    torchLight.Shadows = false
    torchLight.Enabled = toggles.SmartTorch
    torchLight.Parent = hand
    
    spawn(function()
        while torchLight and torchLight.Parent do
            if torchLight.Brightness > 0.5 and toggles.SmartTorch then
                wait(0.5)
                TweenService:Create(torchLight, TweenInfo.new(0.3), {Brightness = 1.6}):Play()
                wait(0.5)
                TweenService:Create(torchLight, TweenInfo.new(0.3), { Brightness = 2.0}):Play()
            else
                wait(1)
            end
        end
    end)
end

player.CharacterAdded:Connect(addSmartTorchLight)
if player.Character then addSmartTorchLight(player.Character) end

RunService.Heartbeat:Connect(updateTorchLight)
Lighting.Changed:Connect(updateTorchLight)

player:GetAttributeChangedSignal("CurrentRoom"):Connect(scanDoors)

local function onCurrentRooms(child)
    if child.Name == "CurrentRooms" then
        child.ChildAdded:Connect(scanDoors)
        child.ChildRemoved:Connect(scanDoors)
        scanDoors()
    end
end
workspace.ChildAdded:Connect(onCurrentRooms)
if workspace:FindFirstChild("CurrentRooms") then onCurrentRooms(workspace.CurrentRooms) end

-- Kategori: Realtime Update Loop
RunService.RenderStepped:Connect(function()
    for part, _ in pairs(highlights) do
        if not part.Parent or distanceFromPlayer(part) > 500 then
            removeHighlightAndLight(part)
        end
    end
    
    for model, _ in pairs(knownEntities) do
        if model.Parent then
            update2DBoxAndName(model)
        else
            remove2DBoxAndName(model)
        end
    end
end)

-- Kategori: NoDamage BoolValue
if not player:FindFirstChild("NoDamage") then
    local noDamage = Instance.new("BoolValue")
    noDamage.Name = "NoDamage"
    noDamage.Value = false
    noDamage.Parent = player
else
    player.NoDamage.Value = false
end

-- Kategori: Live API (Ornekten tam alindi – HWID'li, heartbeat/active) - Ping fix: Slower intervals
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

-- Kategori: Custom FPS HUD Panel (Efendim'in orneginden tam uyarlandi – Modern, dinamik, rainbow bar'li) - Optimized: Grad update slowed
local PlayerGui = Services.LocalPlayer:WaitForChild("PlayerGui")
local Overlay = Instance.new("ScreenGui")
Overlay.Name = "MYLF_HUD"
Overlay.IgnoreGuiInset = true
Overlay.ResetOnSpawn = false
Overlay.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Overlay.Parent = game:GetService("CoreGui") -- CoreGui icin, anti-detect
-- Yardimci Fonksiyonlar (Ornekten uyarlandi)
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
    return stroke -- Donus eklendi, CPS icin
end
local function makeCorner(frame, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = frame
end
-- Global Theme Color (Baslangic berry rengi: #990F4B, RGB 153,15,75)
getgenv().ThemeColor = Color3.fromRGB(153, 15, 75)
-- Panel Olustur
local CrownPanel = Instance.new("Frame")
CrownPanel.AnchorPoint = Vector2.new(0.5, 0)
CrownPanel.Position = UDim2.new(0.5, 0, 0, 8)
CrownPanel.Size = UDim2.fromOffset(300, 26)
CrownPanel.BackgroundColor3 = getgenv().ThemeColor -- Theme'e baglandi
CrownPanel.Parent = Overlay
pad(CrownPanel, 4)
local cps = makeStroke(CrownPanel, 1, 0.15)
cps.Color = getgenv().ThemeColor -- Stroke'u theme'e esle
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
-- Hesaplamalar ve Update (Ornekten tam) - Optimized: Grad update every 1s now
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
    -- Akici Rainbow (her 0.033s ~30 FPS smooth)
    gradTime = gradTime + dt
    if gradTime >= 0.033 then
        gradTime = 0
        local t = os.clock() * 0.33 -- Smooth hiz
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

-- Kategori: Live API (Ornekten tam alindi – HWID'li, heartbeat/active) - Ping fix: Slower intervals
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

-- Kategori: Rayfield Toggle'lar (fluent animasyonlu)
local Entity2DBoxToggle = Tab:CreateToggle({
    Name = "Entities 2D Box (Rainbow)",
    CurrentValue = false,
    Flag = "Entity2DBox",
    Callback = function(Value)
        toggles.Entity2DBox = Value
        for model, data in pairs(drawings) do
            data.box.Visible = Value
            data.name.Visible = Value
        end
        Rayfield:Notify({Title = "Ayar Degisti", Content = "Entities 2D Box: " .. (Value and "ON" or "OFF")})
    end,
})
local EntityHighlightToggle = Tab:CreateToggle({
    Name = "Entity Highlight (Kirmizi Glow)",
    CurrentValue = false,
    Flag = "EntityHighlight",
    Callback = function(Value)
        toggles.EntityHighlight = Value
        for model, _ in pairs(knownEntities) do
            for _, part in pairs(model:GetChildren()) do
                if part:IsA("BasePart") and highlights[part] then
                    highlights[part].Enabled = Value
                end
            end
        end
        Rayfield:Notify({Title = "Ayar Degisti", Content = "Entity Highlight: " .. (Value and "ON" or "OFF")})
    end,
})
local KeyLeverESPToggle = Tab:CreateToggle({
    Name = "Key/Lever ESP (Cyan Glow + Isik)",
    CurrentValue = false,
    Flag = "KeyLeverESP",
    Callback = function(Value)
        toggles.KeyLeverESP = Value
        for model, _ in pairs(knownItems) do
            for _, part in pairs(model:GetChildren()) do
                if part:IsA("BasePart") and highlights[part] then
                    highlights[part].Enabled = Value
                end
            end
        end
        Rayfield:Notify({Title = "Ayar Degisti", Content = "Key/Lever ESP: " .. (Value and "ON" or "OFF")})
    end,
})
local DoorESPToggle = Tab:CreateToggle({
    Name = "Door ESP (Yesil/ Kirmizi Los)",
    CurrentValue = false,
    Flag = "DoorESP",
    Callback = function(Value)
        toggles.DoorESP = Value
        scanDoors()
        Rayfield:Notify({Title = "Ayar Degisti", Content = "Door ESP: " .. (Value and "ON" or "OFF")})
    end,
})
local SmartTorchToggle = Tab:CreateToggle({
    Name = "Akilli Mesale (Otomatik Karanlik)",
    CurrentValue = false,
    Flag = "SmartTorch",
    Callback = function(Value)
        toggles.SmartTorch = Value
        if torchLight then torchLight.Enabled = Value end
        Rayfield:Notify({Title = "Ayar Degisti", Content = "Akilli Mesale: " .. (Value and "ON" or "OFF")})
    end,
})
local LibraryBooksESPToggle = Tab:CreateToggle({
    Name = "Library Books ESP (Sari Glow + Isik)",
    CurrentValue = false,
    Flag = "LibraryBooksESP",
    Callback = function(Value)
        toggles.LibraryBooksESP = Value
        for model, _ in pairs(knownBooks) do
            for _, part in pairs(model:GetChildren()) do
                if part:IsA("BasePart") and highlights[part] then
                    highlights[part].Enabled = Value
                end
            end
        end
        Rayfield:Notify({Title = "Ayar Degisti", Content = "Library Books ESP: " .. (Value and "ON" or "OFF")})
    end,
})



-- Kategori: Baslangic Mesaji
Rayfield:Notify({
    Title = "Script Executed",
    Content = "Version 1.3.10c",
    Duration = 5,
    Image = nil
})

