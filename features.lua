local runService = game:GetService("RunService")
local player = game.Players.LocalPlayer
local features = {}

-- ========== SPEED ==========
local speedConn
function features.ToggleSpeed(state)
    if state then
        if not speedConn then
            speedConn = game:GetService("RunService").Heartbeat:Connect(function()
                pcall(function()
                    local hum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.WalkSpeed = 50 end
                end)
            end)
        end
    else
        if speedConn then
            speedConn:Disconnect()
            speedConn = nil
        end
        local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
end

-- ========== GODMODE ==========
local godConn
function features.ToggleGodmode(state)
    if state then
        if not godConn then
            godConn = game:GetService("RunService").Heartbeat:Connect(function()
                pcall(function()
                    local hum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Health = math.huge end
                end)
            end)
        end
    else
        if godConn then godConn:Disconnect(); godConn = nil end
    end
end

-- 🕊️ Fly
local flyConn
local flyEnabled = false

local function ApplyFly(state)
    flyEnabled = state
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

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
        if flyConn then flyConn:Disconnect() flyConn = nil end
    end
end
features.ToggleFly = ApplyFly

-- Respawn sonrası
player.CharacterAdded:Connect(function()
    task.wait(1)
    if flyEnabled then
        ApplyFly(true)
    end
end)

-- E tuşu toggle
uis.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.E then
        flyEnabled = not flyEnabled
        ApplyFly(flyEnabled)
    end
end)


-- ========== INFINITE JUMP ==========
local jumpConn
function features.ToggleInfiniteJump(state)
    local uis = game:GetService("UserInputService")
    if state then
        if not jumpConn then
            jumpConn = uis.JumpRequest:Connect(function()
                local lp = game.Players.LocalPlayer
                if lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
                    lp.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
                end
            end)
        end
    else
        if jumpConn then jumpConn:Disconnect(); jumpConn = nil end
    end
end

-- ========== AIMBOT ==========
-- 🎯 Aimbot + NoRecoil + NoSpread (Dinamik Enemy Takibi)
local aimbotEnabled = false
local aimConn, weaponConn, playerConn = {}, {}

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

-- === Feature entegrasyonu ===
function features.ToggleAimbot(state)
    aimbotEnabled = state
    if aimbotEnabled then
        -- Herkese bağlan
        for _, plr in pairs(game.Players:GetPlayers()) do
            bindPlayer(plr)
        end
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
        if aimConn then aimConn:Disconnect() aimConn = nil end
        if weaponConn then weaponConn:Disconnect() weaponConn = nil end
        for _, c in pairs(playerConn) do c:Disconnect() end
        playerConn = {}
    end
end

-- ========== KILL AURA ==========
local auraConn
function features.ToggleKillAura(state)
    local lp = game.Players.LocalPlayer
    if state then
        if not auraConn then
            auraConn = game:GetService("RunService").Heartbeat:Connect(function()
                for _,plr in ipairs(game.Players:GetPlayers()) do
                    if plr ~= lp and plr.Character and plr.Character:FindFirstChild("Humanoid") then
                        plr.Character.Humanoid.Health = 0
                    end
                end
            end)
        end
    else
        if auraConn then auraConn:Disconnect(); auraConn = nil end
    end
end

-- ========== TELEPORT TOOL ==========
-- === Misc Tab ===
local MiscBox = Tabs.Misc:AddLeftGroupbox('Misc')

-- Teleport Tool Toggle
MiscBox:AddToggle('TeleportTool', { Text = 'Teleport Tool (T tuşu)', Default = false }):OnChanged(function(val)
    tpEnabled = val
end)

-- === Teleport Tool ===
local tpEnabled = false
local mouse = player:GetMouse()

task.spawn(function()
    while true do
        if tpEnabled then
            if uis:IsKeyDown(Enum.KeyCode.T) then
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char:MoveTo(mouse.Hit.p + Vector3.new(0,3,0))
                end
                task.wait(0.2)
            end
        end
        task.wait()
    end
end)


-- 👀 ESP (Takım kontrol + NPC + Rainbow Fill + Rainbow Name + Skeleton)
local espEnabled = false
local espObjects = {}

-- Renk döngüsü (rainbow)
local function rainbowColor(t)
    local r = math.sin(t*2) * 127 + 128
    local g = math.sin(t*2 + 2) * 127 + 128
    local b = math.sin(t*2 + 4) * 127 + 128
    return Color3.fromRGB(r,g,b)
end

-- Adornee bulucu
local function getAdornee(target)
    return target:FindFirstChild("Head")
        or target:FindFirstChild("UpperTorso")
        or target:FindFirstChild("Torso")
        or target:FindFirstChild("HumanoidRootPart")
end

-- Skeleton için kullanılacak bağlantılar
local skeletonJoints = {
    {"Head","UpperTorso"},
    {"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},
    {"LeftUpperArm","LeftLowerArm"},
    {"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},
    {"RightUpperArm","RightLowerArm"},
    {"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},
    {"LeftUpperLeg","LeftLowerLeg"},
    {"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},
    {"RightUpperLeg","RightLowerLeg"},
    {"RightLowerLeg","RightFoot"},
}

-- ESP ekle
local function addESP(target, isNPC)
    local adornee = getAdornee(target)
    if target and adornee then
        if not espObjects[target] then espObjects[target] = {} end
        local obj = espObjects[target]

        -- Highlight
        if not obj.highlight or not obj.highlight.Parent then
            local highlight = Instance.new("Highlight")
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = Color3.fromRGB(255,255,255)
            highlight.Parent = target
            obj.highlight = highlight
        end

        -- Billboard
        if not obj.billboard or not obj.billboard.Parent then
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
            obj.billboard = billboard
            obj.label = text
        end

        -- Skeleton çizgileri
        if not obj.skeleton then
            obj.skeleton = {}
            for _,link in pairs(skeletonJoints) do
                local line = Drawing.new("Line")
                line.Thickness = 2
                line.Color = Color3.fromRGB(255,255,255)
                line.Visible = true
                table.insert(obj.skeleton, {parts = link, line = line})
            end
        end
    end
end

-- Ölü temizleme
local function clearDead()
    for obj, objs in pairs(espObjects) do
        if not obj.Parent or not getAdornee(obj) then
            if objs.highlight then objs.highlight:Destroy() end
            if objs.billboard then objs.billboard:Destroy() end
            if objs.skeleton then
                for _, s in pairs(objs.skeleton) do
                    s.line:Remove()
                end
            end
            espObjects[obj] = nil
        end
    end
end

-- === Feature entegrasyonu ===
function features.ToggleESP(state)
    espEnabled = state
    if espEnabled then
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

        -- RenderStepped loop (rainbow + skeleton update)
        local t = 0
        RunService.RenderStepped:Connect(function(dt)
            if not espEnabled then return end
            t = t + dt
            for obj, objs in pairs(espObjects) do
                -- Rainbow renk
                if objs.label then objs.label.TextColor3 = rainbowColor(t) end
                if objs.highlight then objs.highlight.FillColor = rainbowColor(t) end

                -- Skeleton çizimleri güncelle
                if objs.skeleton then
                    for _, s in pairs(objs.skeleton) do
                        local p1 = obj:FindFirstChild(s.parts[1])
                        local p2 = obj:FindFirstChild(s.parts[2])
                        if p1 and p2 then
                            local v1, onscreen1 = Camera:WorldToViewportPoint(p1.Position)
                            local v2, onscreen2 = Camera:WorldToViewportPoint(p2.Position)
                            if onscreen1 and onscreen2 then
                                s.line.From = Vector2.new(v1.X, v1.Y)
                                s.line.To = Vector2.new(v2.X, v2.Y)
                                s.line.Color = rainbowColor(t)
                                s.line.Visible = true
                            else
                                s.line.Visible = false
                            end
                        else
                            s.line.Visible = false
                        end
                    end
                end
            end
            clearDead()
        end)

    else
        for _, objs in pairs(espObjects) do
            if objs.highlight then objs.highlight:Destroy() end
            if objs.billboard then objs.billboard:Destroy() end
            if objs.skeleton then
                for _, s in pairs(objs.skeleton) do
                    s.line:Remove()
                end
            end
        end
        espObjects = {}
    end
end


-- ========== INVISIBLE ==========
function features.ToggleInvisible(state)
    local lp = game.Players.LocalPlayer
    if lp.Character and lp.Character:FindFirstChild("Head") then
        lp.Character.Head.Transparency = state and 1 or 0
    end
end

-- ========== TOOL INSPECTOR ==========
-- === Misc Tab ===
local MiscBox = Tabs.Misc:AddLeftGroupbox('Misc')

-- Tool Inspector Toggle
MiscBox:AddToggle('Inspector', { Text = 'Tool Inspector', Default = false }):OnChanged(function(val)
    inspector.Visible = val
end)

-- === Tool Inspector Panel ===
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

    -- Tool property’leri
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

return features
