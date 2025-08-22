-- ✨ GUI Menü Script ✨
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")

-- === Ana GUI ===
local gui = Instance.new("ScreenGui", playerGui)
gui.Name = "MainMenu"
gui.ResetOnSpawn = false

-- === Menü Butonu ===
local menuBtn = Instance.new("TextButton", gui)
menuBtn.Size = UDim2.new(0, 100, 0, 35)
menuBtn.Position = UDim2.new(1, -110, 0, 10)
menuBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 100)
menuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
menuBtn.Font = Enum.Font.SourceSansBold
menuBtn.Text = "☰ Menu"
menuBtn.TextSize = 18

-- === Panel ===
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 280, 0, 0)
frame.Position = UDim2.new(1, -300, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Visible = true
frame.ClipsDescendants = true
Instance.new("UICorner", frame)

-- Aç/Kapa Animasyonu
local panelOpen = false
menuBtn.MouseButton1Click:Connect(function()
    panelOpen = not panelOpen
    local goal = {}
    if panelOpen then
        goal.Size = UDim2.new(0, 280, 0, 520) -- ✨ daha uzun
    else
        goal.Size = UDim2.new(0, 280, 0, 0)
    end
    tweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal):Play()
end)

-- === Layout ===
local layout = Instance.new("UIListLayout", frame)
layout.Padding = UDim.new(0, 6) -- butonlar arası mesafe biraz daha küçük
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- === Genel Buton Yapıcı ===
local function makeButton(name, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35) -- ✨ genişlik tam frame (yanlardan 0 boşluk)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.Text = name
    btn.Parent = frame
    Instance.new("UICorner", btn)
    return btn
end

-- ==============================
-- === Özellikler ===
-- ==============================

-- ⚡ Speed
-- ⚡ Speed
local speedBtn = makeButton("⚡ Speed (16)", Color3.fromRGB(60,120,200))
local speedEnabled = false
local speedConn

local function applySpeed()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        if speedEnabled then
            char.Humanoid.WalkSpeed = 50
        else
            char.Humanoid.WalkSpeed = 16
        end
    end
end

speedBtn.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    if speedEnabled then
        speedBtn.Text = "⚡ Speed (50)"
        speedBtn.BackgroundColor3 = Color3.fromRGB(0,200,100)

        -- Her frame kontrol → oyun resetlese bile geri 50 yapar
        speedConn = runService.Heartbeat:Connect(function()
            applySpeed()
        end)

    else
        speedBtn.Text = "⚡ Speed (16)"
        speedBtn.BackgroundColor3 = Color3.fromRGB(60,120,200)
        if speedConn then speedConn:Disconnect() end
        applySpeed()
    end
end)

-- Respawn sonrası tekrar uygula
player.CharacterAdded:Connect(function()
    task.wait(1) -- karakter yüklenmesini bekle
    applySpeed()
end)


-- ❤️ Godmode
-- ❤️ Godmode
local godBtn = makeButton("❤️ Godmode OFF", Color3.fromRGB(200,60,60))
local godEnabled = false
local godConn

local function applyGodmode()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.Health = math.huge
        char.Humanoid.MaxHealth = math.huge
    end
end

godBtn.MouseButton1Click:Connect(function()
    godEnabled = not godEnabled
    if godEnabled then
        godBtn.Text = "❤️ Godmode ON"
        godBtn.BackgroundColor3 = Color3.fromRGB(0,200,100)

        -- Her frame health resetle
        godConn = runService.Heartbeat:Connect(function()
            applyGodmode()
        end)
    else
        godBtn.Text = "❤️ Godmode OFF"
        godBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)
        if godConn then godConn:Disconnect() end
    end
end)

-- Respawn sonrası otomatik tekrar uygula
player.CharacterAdded:Connect(function()
    task.wait(1)
    if godEnabled then
        if godConn then godConn:Disconnect() end
        godConn = runService.Heartbeat:Connect(function()
            applyGodmode()
        end)
    end
end)


-- 🕊️ Fly
local flyBtn = makeButton("🕊️ Fly OFF", Color3.fromRGB(120,60,200))
local flyEnabled = false
local flyConn

-- Fly uygula
local function applyFly()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        if flyEnabled then
            if not hrp:FindFirstChild("BodyVelocity") then
                local bv = Instance.new("BodyVelocity", hrp)
                bv.MaxForce = Vector3.new(4000,4000,4000)
                bv.Velocity = Vector3.zero
            end
            flyConn = runService.RenderStepped:Connect(function()
                if hrp:FindFirstChild("BodyVelocity") then
                    local dir = Vector3.zero
                    local cam = workspace.CurrentCamera.CFrame
                    if uis:IsKeyDown(Enum.KeyCode.W) then dir += cam.LookVector end
                    if uis:IsKeyDown(Enum.KeyCode.S) then dir -= cam.LookVector end
                    if uis:IsKeyDown(Enum.KeyCode.A) then dir -= cam.RightVector end
                    if uis:IsKeyDown(Enum.KeyCode.D) then dir += cam.RightVector end
                    if uis:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
                    if uis:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
                    hrp.BodyVelocity.Velocity = dir * 60
                end
            end)
        else
            if hrp:FindFirstChild("BodyVelocity") then hrp.BodyVelocity:Destroy() end
            if flyConn then flyConn:Disconnect() end
        end
    end
end

-- Butona basınca
flyBtn.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    if flyEnabled then
        flyBtn.Text = "🕊️ Fly ON"
        flyBtn.BackgroundColor3 = Color3.fromRGB(0,200,100)
    else
        flyBtn.Text = "🕊️ Fly OFF"
        flyBtn.BackgroundColor3 = Color3.fromRGB(120,60,200)
    end
    applyFly()
end)

-- Klavye kısayol (E tuşu)
uis.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.E then
        flyEnabled = not flyEnabled
        if flyEnabled then
            flyBtn.Text = "🕊️ Fly ON"
            flyBtn.BackgroundColor3 = Color3.fromRGB(0,200,100)
        else
            flyBtn.Text = "🕊️ Fly OFF"
            flyBtn.BackgroundColor3 = Color3.fromRGB(120,60,200)
        end
        applyFly()
    end
end)

-- Respawn sonrası otomatik
player.CharacterAdded:Connect(function()
    task.wait(1)
    if flyEnabled then
        applyFly()
    end
end)

----Test Debug
-- Silent Aim senkronize Aimbot
local silentAimEnabled = false
local silentAimBtn = makeButton("🤫 Silent Aim OFF", Color3.fromRGB(120,120,200))

-- Remote spoofing için hook
local oldNamecall
silentAimBtn.MouseButton1Click:Connect(function()
    silentAimEnabled = not silentAimEnabled
    if silentAimEnabled then
        silentAimBtn.Text = "🤫 Silent Aim ON"
        silentAimBtn.BackgroundColor3 = Color3.fromRGB(0,200,200)

        -- Hook Namecall (FireServer override)
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}

            if silentAimEnabled and method == "FireServer" then
                -- Eğer bu Remote "Shoot" veya "Fire" tarzı ise
                if tostring(self):lower():find("fire") or tostring(self):lower():find("shoot") then
                    local head = getClosestVisibleHead()
                    if head then
                        -- Hedef pozisyonu kafaya çevir
                        if typeof(args[1]) == "Vector3" then
                            args[1] = head.Position
                        elseif args[2] and typeof(args[2]) == "Vector3" then
                            args[2] = head.Position
                        end
                        return oldNamecall(self, unpack(args))
                    end
                end
            end

            return oldNamecall(self, ...)
        end)

    else
        silentAimBtn.Text = "🤫 Silent Aim OFF"
        silentAimBtn.BackgroundColor3 = Color3.fromRGB(120,120,200)
        if oldNamecall then
            hookmetamethod(game, "__namecall", oldNamecall)
        end
    end
end)



-- 🔫 ROF (Rapid Fire)
-- 🔫 ROF (Rapid Fire mantıklı versiyon)
local rofBtn = makeButton("🔫 ROF OFF", Color3.fromRGB(180,80,200))
local rofEnabled = false
local rofConn

rofBtn.MouseButton1Click:Connect(function()
    rofEnabled = not rofEnabled
    if rofEnabled then
        rofBtn.Text = "🔫 ROF ON"
        rofBtn.BackgroundColor3 = Color3.fromRGB(0,200,100)

        rofConn = runService.Heartbeat:Connect(function()
            local char = player.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    for _, obj in pairs(tool:GetDescendants()) do
                        -- AttackSpeed, Cooldown, FireRate, ReloadSpeed gibi değerleri küçült
                        if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                            local name = obj.Name:lower()
                            if string.find(name, "cooldown") 
                            or string.find(name, "fire") 
                            or string.find(name, "attack") 
                            or string.find(name, "reload") 
                            or string.find(name, "speed") then
                                obj.Value = 0.05 -- çok hızlı
                            end
                        end
                    end
                end
            end
        end)

    else
        rofBtn.Text = "🔫 ROF OFF"
        rofBtn.BackgroundColor3 = Color3.fromRGB(180,80,200)
        if rofConn then rofConn:Disconnect() end
    end
end)


-- 🚪 Noclip
local noclipBtn = makeButton("🚪 Noclip OFF", Color3.fromRGB(60,200,200))
local noclipEnabled = false
local noclipConn
noclipBtn.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    if noclipEnabled then
        noclipBtn.Text = "🚪 Noclip ON"
        noclipBtn.BackgroundColor3 = Color3.fromRGB(0,200,100)
        noclipConn = runService.Stepped:Connect(function()
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        noclipBtn.Text = "🚪 Noclip OFF"
        noclipBtn.BackgroundColor3 = Color3.fromRGB(60,200,200)
        if noclipConn then noclipConn:Disconnect() end
    end
end)

-- 👀 ESP
local RunService = game:GetService("RunService")

-- 👀 ESP (Takım kontrol + NPC + Rainbow Fill + Rainbow Name)
local espBtn = makeButton("👀 ESP OFF", Color3.fromRGB(80,180,200))
local espEnabled = false
local espObjects = {}

local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Renk döngüsü (rainbow)
local function rainbowColor(t)
    local r = math.sin(t*2) * 127 + 128
    local g = math.sin(t*2 + 2) * 127 + 128
    local b = math.sin(t*2 + 4) * 127 + 128
    return Color3.fromRGB(r,g,b)
end

-- Takım kontrol
local function getTeamColor(plr)
    local myTeam = player.Team
    if not myTeam then
        return Color3.fromRGB(255,0,0)
    end
    if plr.Team == myTeam then
        return Color3.fromRGB(0,255,0)
    else
        return Color3.fromRGB(255,0,0)
    end
end

-- Adornee bulucu (Head yoksa Torso / HRP)
local function getAdornee(target)
    return target:FindFirstChild("Head")
        or target:FindFirstChild("UpperTorso")
        or target:FindFirstChild("Torso")
        or target:FindFirstChild("HumanoidRootPart")
end

-- ESP ekle
local function addESP(target, isNPC)
    local adornee = getAdornee(target)
    if target and adornee then
        if not espObjects[target] then espObjects[target] = {} end

        -- Highlight
        if not espObjects[target].highlight or not espObjects[target].highlight.Parent then
            local highlight = Instance.new("Highlight")
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = Color3.fromRGB(255,255,255)
            highlight.Parent = target
            espObjects[target].highlight = highlight
        end

        -- Billboard
        if not espObjects[target].billboard or not espObjects[target].billboard.Parent then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "ESP_Name"
            billboard.Adornee = adornee
            billboard.Size = UDim2.new(0,100,0,20)
            billboard.StudsOffset = Vector3.new(0, 2, 0)
            billboard.AlwaysOnTop = true

            local text = Instance.new("TextLabel", billboard)
            text.Size = UDim2.new(1,0,1,0)
            text.BackgroundTransparency = 1
            text.Font = Enum.Font.SourceSansBold
            text.TextStrokeTransparency = 0
            text.TextScaled = true
            text.Text = isNPC and "NPC" or (game.Players:GetPlayerFromCharacter(target) and game.Players:GetPlayerFromCharacter(target).Name or "?")

            billboard.Parent = adornee
            espObjects[target].billboard = billboard
            espObjects[target].label = text
        end
    end
end

-- Ölü temizleme
local function clearDead()
    for obj, objs in pairs(espObjects) do
        if not obj.Parent or not getAdornee(obj) then
            if objs.highlight then objs.highlight:Destroy() end
            if objs.billboard then objs.billboard:Destroy() end
            espObjects[obj] = nil
        end
    end
end

-- Toggle
espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        espBtn.Text = "👀 ESP ON"
        espBtn.BackgroundColor3 = Color3.fromRGB(0,200,100)

        -- Player spawn
        for _, plr in pairs(game.Players:GetPlayers()) do
            plr.CharacterAdded:Connect(function(char)
                if espEnabled then
                    task.wait(1)
                    addESP(char, false)
                end
            end)
            if plr.Character then addESP(plr.Character, false) end
        end

        -- NPC ESP
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:FindFirstChildOfClass("Humanoid") and getAdornee(obj) and not game.Players:GetPlayerFromCharacter(obj) then
                addESP(obj, true)
            end
        end
        workspace.ChildAdded:Connect(function(obj)
            if espEnabled and obj:FindFirstChildOfClass("Humanoid") and getAdornee(obj) and not game.Players:GetPlayerFromCharacter(obj) then
                task.wait(1)
                addESP(obj, true)
            end
        end)

        -- Güncelleme loop
        spawn(function()
            while espEnabled do
                for _, plr in pairs(game.Players:GetPlayers()) do
                    if plr.Character and espObjects[plr.Character] and espObjects[plr.Character].highlight then
                        espObjects[plr.Character].highlight.FillColor = getTeamColor(plr)
                    end
                end
                for obj, objs in pairs(espObjects) do
                    if objs.highlight and objs.label and objs.label.Text == "NPC" then
                        objs.highlight.FillColor = Color3.fromRGB(160, 60, 200)
                    end
                end
                clearDead()
                task.wait(0.2)
            end
        end)

        -- RenderStepped rainbow akışı (isim + dolgu)
        local t = 0
        RunService.RenderStepped:Connect(function(dt)
            if not espEnabled then return end
            t = t + dt
            for obj, objs in pairs(espObjects) do
                if objs.label then
                    objs.label.TextColor3 = rainbowColor(t)
                end
                if objs.highlight then
                    objs.highlight.FillColor = rainbowColor(t) -- 🌈 iç dolgu rainbow
                end
            end
        end)

    else
        espBtn.Text = "👀 ESP OFF"
        espBtn.BackgroundColor3 = Color3.fromRGB(80,180,200)
        for _, objs in pairs(espObjects) do
            if objs.highlight then objs.highlight:Destroy() end
            if objs.billboard then objs.billboard:Destroy() end
        end
        espObjects = {}
    end
end)


-- 🎯 Aimbot + NoRecoil + NoSpread (Dinamik Enemy Takibi)
local aimbotBtn = makeButton("🎯 Aimbot OFF", Color3.fromRGB(200,120,60))
local aimbotEnabled = false
local aimConn, weaponConn, playerConn = {}, {}

local runService = game:GetService("RunService")
local cam = workspace.CurrentCamera
local player = game.Players.LocalPlayer

-- en yakın kafa (Line of Sight + Team Check)
local function getClosestVisibleHead()
    local closest, dist = nil, math.huge
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            -- Takım kontrolü
            if not (player.Team and plr.Team and player.Team == plr.Team) then
                local head = plr.Character.Head
                local headPos = head.Position

                -- Line of Sight
                local ray = RaycastParams.new()
                ray.FilterType = Enum.RaycastFilterType.Blacklist
                ray.FilterDescendantsInstances = {player.Character}
                local result = workspace:Raycast(cam.CFrame.Position, (headPos - cam.CFrame.Position).Unit * 1000, ray)

                if result and result.Instance:IsDescendantOf(plr.Character) then
                    local screenPos, onScreen = cam:WorldToViewportPoint(headPos)
                    if onScreen then
                        local mag = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
                        if mag < dist then
                            dist, closest = mag, head
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- Recoil & Spread fix (senkronize)
local function removeRecoilSpread(tool)
    if not tool then return end
    for _, v in pairs(tool:GetDescendants()) do
        if v:IsA("NumberValue") or v:IsA("IntValue") then
            local n = v.Name:lower()
            if n:find("recoil") or n:find("spread") or n:find("accuracy") then
                v.Value = 0
            end
        end
    end
end

-- Yeni gelen enemy’leri sürekli dinle
local function bindPlayer(plr)
    if plr == player then return end
    -- Respawn olduğunda tekrar takip et
    playerConn[plr] = plr.CharacterAdded:Connect(function()
        if aimbotEnabled then
            task.wait(1) -- karakter yüklenmesini bekle
        end
    end)
end

-- Toggle
aimbotBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    if aimbotEnabled then
        aimbotBtn.Text = "🎯 Aimbot+NR+NS ON"
        aimbotBtn.BackgroundColor3 = Color3.fromRGB(0,200,100)

        -- Herkese bağlan
        for _, plr in pairs(game.Players:GetPlayers()) do
            bindPlayer(plr)
        end
        -- Yeni giren oyuncular
        game.Players.PlayerAdded:Connect(function(plr)
            bindPlayer(plr)
        end)

        -- Aim loop
        aimConn = runService.RenderStepped:Connect(function()
            local head = getClosestVisibleHead()
            if head then
                cam.CFrame = CFrame.new(cam.CFrame.Position, head.Position)
            end
        end)

        -- Weapon loop (No Recoil & No Spread)
        weaponConn = runService.Heartbeat:Connect(function()
            local char = player.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    removeRecoilSpread(tool)
                end
            end
        end)

    else
        aimbotBtn.Text = "🎯 Aimbot OFF"
        aimbotBtn.BackgroundColor3 = Color3.fromRGB(200,120,60)

        if aimConn then aimConn:Disconnect() end
        if weaponConn then weaponConn:Disconnect() end
        for _, c in pairs(playerConn) do c:Disconnect() end
        playerConn = {}
    end
end)

-- === Teleport (Tuş: T) ===
local tpBtn = makeButton("🌀 Teleport Tool OFF", Color3.fromRGB(150, 100, 200))
local tpEnabled = false
local mouse = player:GetMouse()
tpBtn.MouseButton1Click:Connect(function()
    tpEnabled = not tpEnabled
    if tpEnabled then
        tpBtn.Text = "🌀 Teleport Tool ON"
        tpBtn.BackgroundColor3 = Color3.fromRGB(0,200,100)
        spawn(function()
            while tpEnabled do
                if uis:IsKeyDown(Enum.KeyCode.T) then
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char:MoveTo(mouse.Hit.p + Vector3.new(0,3,0))
                    end
                end
                task.wait(0.2)
            end
        end)
    else
        tpBtn.Text = "🌀 Teleport Tool OFF"
        tpBtn.BackgroundColor3 = Color3.fromRGB(150,100,200)
    end
end)

-- === Kill Aura ===
local auraBtn = makeButton("⚔️ Kill Aura OFF", Color3.fromRGB(200, 80, 80))
local auraEnabled = false
local auraConn
auraBtn.MouseButton1Click:Connect(function()
    auraEnabled = not auraEnabled
    if auraEnabled then
        auraBtn.Text = "⚔️ Kill Aura ON"
        auraBtn.BackgroundColor3 = Color3.fromRGB(0,200,100)
        auraConn = runService.Heartbeat:Connect(function()
            local char = player.Character
            if char and char:FindFirstChildOfClass("Tool") then
                local tool = char:FindFirstChildOfClass("Tool")
                for _, plr in pairs(game.Players:GetPlayers()) do
                    if plr ~= player and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("HumanoidRootPart") then
                        if (plr.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude < 15 then
                            tool:Activate() -- yakınındaki herkese vurur
                        end
                    end
                end
            end
        end)
    else
        auraBtn.Text = "⚔️ Kill Aura OFF"
        auraBtn.BackgroundColor3 = Color3.fromRGB(200,80,80)
        if auraConn then auraConn:Disconnect() end
    end
end)

-- === Infinite Jump ===
local infJumpBtn = makeButton("☁️ Infinite Jump OFF", Color3.fromRGB(100, 180, 120))
local infJumpEnabled = false
infJumpBtn.MouseButton1Click:Connect(function()
    infJumpEnabled = not infJumpEnabled
    if infJumpEnabled then
        infJumpBtn.Text = "☁️ Infinite Jump ON"
        infJumpBtn.BackgroundColor3 = Color3.fromRGB(0,200,100)
        uis.JumpRequest:Connect(function()
            if infJumpEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        infJumpBtn.Text = "☁️ Infinite Jump OFF"
        infJumpBtn.BackgroundColor3 = Color3.fromRGB(100,180,120)
    end
end)


-- === Invisible ===
local invBtn = makeButton("👻 Invisible OFF", Color3.fromRGB(120, 120, 120))
local invEnabled = false
invBtn.MouseButton1Click:Connect(function()
    invEnabled = not invEnabled
    local char = player.Character or player.CharacterAdded:Wait()
    if invEnabled then
        invBtn.Text = "👻 Invisible ON"
        invBtn.BackgroundColor3 = Color3.fromRGB(0,200,100)
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 1
                if part:FindFirstChild("face") then
                    part.face:Destroy()
                end
            end
        end
    else
        invBtn.Text = "👻 Invisible OFF"
        invBtn.BackgroundColor3 = Color3.fromRGB(120,120,120)
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 0
            end
        end
    end
end)


-- Tool Inspector Panel
local inspector = Instance.new("Frame", gui)
inspector.Size = UDim2.new(0, 320, 0, 400)
inspector.Position = UDim2.new(0.5, -160, 0.5, -200)
inspector.BackgroundColor3 = Color3.fromRGB(30,30,30)
inspector.Visible = false
Instance.new("UICorner", inspector)

local title = Instance.new("TextLabel", inspector)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.Text = "🔍 Tool Inspector"
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(255,255,255)

local scroll = Instance.new("ScrollingFrame", inspector)
scroll.Size = UDim2.new(1,0,1,-40)
scroll.Position = UDim2.new(0,0,0,40)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,5)

-- Helper: satır ekle
local function addRow(name, value, callback)
    local row = Instance.new("Frame", scroll)
    row.Size = UDim2.new(1,0,0,30)
    row.BackgroundColor3 = Color3.fromRGB(50,50,50)
    Instance.new("UICorner", row)

    local nameLbl = Instance.new("TextLabel", row)
    nameLbl.Size = UDim2.new(0.5,0,1,0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = name
    nameLbl.TextColor3 = Color3.fromRGB(200,200,200)
    nameLbl.Font = Enum.Font.SourceSans
    nameLbl.TextSize = 14

    local box = Instance.new("TextBox", row)
    box.Size = UDim2.new(0.5,0,1,0)
    box.Position = UDim2.new(0.5,0,0,0)
    box.Text = tostring(value)
    box.TextColor3 = Color3.fromRGB(255,255,255)
    box.BackgroundColor3 = Color3.fromRGB(70,70,70)
    box.Font = Enum.Font.SourceSans
    box.TextSize = 14

    box.FocusLost:Connect(function(enter)
        if enter then
            callback(box.Text)
        end
    end)
end

-- Tool tarayıcı
local function inspectTool(tool)
    for _, obj in pairs(scroll:GetChildren()) do
        if obj:IsA("Frame") then obj:Destroy() end
    end

    -- Tool property’leri (readonly olmayanları deneyelim)
    local props = {"Name","Parent","Enabled","GripForward","GripRight","GripUp","ToolTip"}
    for _, prop in ipairs(props) do
        local ok, val = pcall(function() return tool[prop] end)
        if ok then
            addRow(prop, val, function(newVal)
                pcall(function()
                    if typeof(val) == "boolean" then
                        tool[prop] = (newVal:lower()=="true")
                    elseif typeof(val) == "number" then
                        tool[prop] = tonumber(newVal)
                    else
                        tool[prop] = newVal
                    end
                end)
            end)
        end
    end

    -- İçindeki Value objeleri
    for _, v in pairs(tool:GetDescendants()) do
        if v:IsA("NumberValue") or v:IsA("StringValue") or v:IsA("BoolValue") or v:IsA("IntValue") then
            addRow(v.Name, v.Value, function(newVal)
                if tonumber(newVal) then
                    v.Value = tonumber(newVal)
                elseif newVal:lower()=="true" or newVal:lower()=="false" then
                    v.Value = (newVal:lower()=="true")
                else
                    v.Value = newVal
                end
            end)
        end
    end
end

-- Inspector toggle butonu
local inspectBtn = makeButton("🛠 Tool Inspector", Color3.fromRGB(100,150,200))
inspectBtn.MouseButton1Click:Connect(function()
    inspector.Visible = not inspector.Visible
    if inspector.Visible then
        local char = player.Character
        if char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                inspectTool(tool)
            end
        end
    end
end)

-- Sürekli güncel tutsun
runService.Heartbeat:Connect(function()
    if inspector.Visible then
        local char = player.Character
        if char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                inspectTool(tool)
            end
        end
    end
end)

