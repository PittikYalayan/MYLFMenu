local runService = game:GetService("RunService")
local player = game.Players.LocalPlayer

local Features = {}
-- 🗂 Feature List
-- Aim: 🎯 Aimbot+NR+NS, 🤫 Silent Aim
-- Player: ⚡ Speed, ❤️ Godmode, 🕊️ Fly, ☁️ Infinite Jump, 👻 Invisible
-- Misc: 🌀 Teleport Tool, ⚔️ Kill Aura, 🛠 Tool Inspector
-- (Visual için slot boş, eklenebilir)




-- 🎯 Aimbot + NoRecoil + NoSpread (FireServer hook)
local aimbotBtn = makeButton(aimPage, "🎯 Aimbot OFF", Color3.fromRGB(180,120,60))
local aimbotEnabled, oldFire = false, nil

-- hedef seçici
local function getClosestHead()
    local closest, dist = nil, math.huge
    local cam = workspace.CurrentCamera
    for _,plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
            local head = plr.Character.Head
            local pos, onScreen = cam:WorldToViewportPoint(head.Position)
            if onScreen then
                local d = (Vector2.new(pos.X,pos.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
                if d < dist then dist, closest = d, head end
            end
        end
    end
    return closest
end

-- recoil/spread temizleyici
local function clearRecoilSpread(args)
    for i,v in ipairs(args) do
        if typeof(v)=="Vector3" then args[i]=Vector3.new(v.X, v.Y, 0) end
    end
    return args
end

aimbotBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    if aimbotEnabled then
        aimbotBtn.Text, aimbotBtn.BackgroundColor3 = "🎯 Aimbot ON", Color3.fromRGB(0,200,100)
        oldFire = hookmetamethod(game,"__namecall",function(self,...)
            local m, args = getnamecallmethod(), {...}
            if aimbotEnabled and m=="FireServer" and (tostring(self):lower():find("fire") or tostring(self):lower():find("shoot")) then
                local head = getClosestHead()
                if head then
                    -- hedef pozisyonu
                    if typeof(args[1])=="Vector3" then args[1]=head.Position
                    elseif typeof(args[2])=="Vector3" then args[2]=head.Position end
                end
                -- recoil & spread reset
                args = clearRecoilSpread(args)
                return oldFire(self, unpack(args))
            end
            return oldFire(self,...)
        end)
    else
        aimbotBtn.Text, aimbotBtn.BackgroundColor3 = "🎯 Aimbot OFF", Color3.fromRGB(180,120,60)
        if oldFire then hookmetamethod(game,"__namecall",oldFire) end
    end
end)

----------------- PLAYER -----------------

-- ⚡ Speed
local speedBtn = makeButton(playerPage, "⚡ Speed (16)", Color3.fromRGB(60,120,200))
local speedEnabled, speedConn = false, nil
local function applySpeed()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = speedEnabled and 50 or 16
    end
end
speedBtn.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    if speedEnabled then
        speedBtn.Text = "⚡ Speed (50)"
        speedBtn.BackgroundColor3 = Color3.fromRGB(0,200,100)
        speedConn = runService.Heartbeat:Connect(applySpeed)
    else
        speedBtn.Text = "⚡ Speed (16)"
        speedBtn.BackgroundColor3 = Color3.fromRGB(60,120,200)
        if speedConn then speedConn:Disconnect() end
        applySpeed()
    end
end)
player.CharacterAdded:Connect(function() task.wait(1) applySpeed() end)

-- ❤️ Godmode
local godBtn = makeButton(playerPage, "❤️ Godmode OFF", Color3.fromRGB(200,60,60))
local godEnabled, godConn = false, nil
local function applyGodmode()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.Health, char.Humanoid.MaxHealth = math.huge, math.huge
    end
end
godBtn.MouseButton1Click:Connect(function()
    godEnabled = not godEnabled
    if godEnabled then
        godBtn.Text = "❤️ Godmode ON"
        godBtn.BackgroundColor3 = Color3.fromRGB(0,200,100)
        godConn = runService.Heartbeat:Connect(applyGodmode)
    else
        godBtn.Text = "❤️ Godmode OFF"
        godBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)
        if godConn then godConn:Disconnect() end
    end
end)
player.CharacterAdded:Connect(function() if godEnabled then godConn = runService.Heartbeat:Connect(applyGodmode) end end)

-- 🕊️ Fly
local flyBtn = makeButton(playerPage, "🕊️ Fly OFF", Color3.fromRGB(120,60,200))
local flyEnabled, flyConn = false, nil
local function applyFly()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    if flyEnabled then
        if not hrp:FindFirstChild("BodyVelocity") then
            local bv = Instance.new("BodyVelocity", hrp)
            bv.MaxForce, bv.Velocity = Vector3.new(4000,4000,4000), Vector3.zero
        end
        flyConn = runService.RenderStepped:Connect(function()
            if hrp:FindFirstChild("BodyVelocity") then
                local dir, cam = Vector3.zero, workspace.CurrentCamera.CFrame
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
flyBtn.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    flyBtn.Text, flyBtn.BackgroundColor3 = flyEnabled and "🕊️ Fly ON" or "🕊️ Fly OFF",
        flyEnabled and Color3.fromRGB(0,200,100) or Color3.fromRGB(120,60,200)
    applyFly()
end)
uis.InputBegan:Connect(function(input,gp) if not gp and input.KeyCode == Enum.KeyCode.E then flyBtn:Activate() end end)
player.CharacterAdded:Connect(function() if flyEnabled then applyFly() end end)

-- ☁️ Infinite Jump
local infJumpBtn = makeButton(playerPage, "☁️ Infinite Jump OFF", Color3.fromRGB(100,180,120))
local infJumpEnabled = false
local infJumpConn
infJumpBtn.MouseButton1Click:Connect(function()
    infJumpEnabled = not infJumpEnabled
    if infJumpEnabled then
        infJumpBtn.Text = "☁️ Infinite Jump ON"
        infJumpBtn.BackgroundColor3 = Color3.fromRGB(0,200,100)
        if not infJumpConn then
            infJumpConn = uis.JumpRequest:Connect(function()
                if infJumpEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    else
        infJumpBtn.Text = "☁️ Infinite Jump OFF"
        infJumpBtn.BackgroundColor3 = Color3.fromRGB(100,180,120)
    end
end)

-- 👻 Invisible
local invBtn = makeButton(playerPage, "👻 Invisible OFF", Color3.fromRGB(120,120,120))
local invEnabled = false
invBtn.MouseButton1Click:Connect(function()
    invEnabled = not invEnabled
    local char = player.Character or player.CharacterAdded:Wait()
    if invEnabled then
        invBtn.Text, invBtn.BackgroundColor3 = "👻 Invisible ON", Color3.fromRGB(0,200,100)
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 1
                if part:FindFirstChild("face") then part.face:Destroy() end
            end
        end
    else
        invBtn.Text, invBtn.BackgroundColor3 = "👻 Invisible OFF", Color3.fromRGB(120,120,120)
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 0
            end
        end
    end
end)

----------------- AIM -----------------

-- 🤫 Silent Aim
local silentAimBtn = makeButton(aimPage, "🤫 Silent Aim OFF", Color3.fromRGB(120,120,200))
local silentAimEnabled, oldNamecall = false, nil
silentAimBtn.MouseButton1Click:Connect(function()
    silentAimEnabled = not silentAimEnabled
    if silentAimEnabled then
        silentAimBtn.Text, silentAimBtn.BackgroundColor3 = "🤫 Silent Aim ON", Color3.fromRGB(0,200,200)
        oldNamecall = hookmetamethod(game,"__namecall",function(self,...)
            local m, args = getnamecallmethod(), {...}
            if silentAimEnabled and m=="FireServer" and (tostring(self):lower():find("fire") or tostring(self):lower():find("shoot")) then
                local head = getClosestVisibleHead()
                if head then
                    if typeof(args[1])=="Vector3" then args[1]=head.Position
                    elseif typeof(args[2])=="Vector3" then args[2]=head.Position end
                    return oldNamecall(self, unpack(args))
                end
            end
            return oldNamecall(self,...)
        end)
    else
        silentAimBtn.Text, silentAimBtn.BackgroundColor3 = "🤫 Silent Aim OFF", Color3.fromRGB(120,120,200)
        if oldNamecall then hookmetamethod(game,"__namecall",oldNamecall) end
    end
end)

-- 🎯 Aimbot + NoRecoil + NoSpread
-- (buradaki getClosestVisibleHead ve removeRecoilSpread fonksiyonlarını yukarıya koydum, aynı şekilde çalışır)

----------------- MISC -----------------

-- 🌀 Teleport Tool
local tpBtn = makeButton(miscPage, "🌀 Teleport Tool OFF", Color3.fromRGB(150,100,200))
local tpEnabled, mouse = false, player:GetMouse()
tpBtn.MouseButton1Click:Connect(function()
    tpEnabled = not tpEnabled
    tpBtn.Text, tpBtn.BackgroundColor3 = tpEnabled and "🌀 Teleport Tool ON" or "🌀 Teleport Tool OFF",
        tpEnabled and Color3.fromRGB(0,200,100) or Color3.fromRGB(150,100,200)
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
end)

-- ⚔️ Kill Aura
local auraBtn = makeButton(miscPage, "⚔️ Kill Aura OFF", Color3.fromRGB(200,80,80))
local auraEnabled, auraConn = false, nil
auraBtn.MouseButton1Click:Connect(function()
    auraEnabled = not auraEnabled
    if auraEnabled then
        auraBtn.Text, auraBtn.BackgroundColor3 = "⚔️ Kill Aura ON", Color3.fromRGB(0,200,100)
        auraConn = runService.Heartbeat:Connect(function()
            local char, tool = player.Character, player.Character and player.Character:FindFirstChildOfClass("Tool")
            if char and tool then
                for _, plr in pairs(game.Players:GetPlayers()) do
                    if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        if (plr.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude < 15 then
                            tool:Activate()
                        end
                    end
                end
            end
        end)
    else
        auraBtn.Text, auraBtn.BackgroundColor3 = "⚔️ Kill Aura OFF", Color3.fromRGB(200,80,80)
        if auraConn then auraConn:Disconnect() end
    end
end)

-- 🛠 Tool Inspector
local inspectBtn = makeButton(miscPage, "🛠 Tool Inspector", Color3.fromRGB(100,150,200))
local inspector = Instance.new("Frame", miscPage)
inspector.Size = UDim2.new(0.9,0,0,200)
inspector.BackgroundColor3 = Color3.fromRGB(30,30,30)
inspector.Visible = false
Instance.new("UICorner", inspector)
local scroll = Instance.new("ScrollingFrame", inspector)
scroll.Size = UDim2.new(1,0,1,0)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1
local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,5)

local function addRow(name,value)
    local row = Instance.new("TextLabel", scroll)
    row.Size = UDim2.new(1,0,0,20)
    row.Text, row.BackgroundTransparency, row.TextColor3 = name..": "..tostring(value),1,Color3.fromRGB(200,200,200)
end
local function inspectTool(tool)
    for _, c in pairs(scroll:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
    for _, v in pairs(tool:GetDescendants()) do
        if v:IsA("NumberValue") or v:IsA("StringValue") or v:IsA("BoolValue") then addRow(v.Name,v.Value) end
    end
end
inspectBtn.MouseButton1Click:Connect(function()
    inspector.Visible = not inspector.Visible
    if inspector.Visible then
        local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
        if tool then inspectTool(tool) end
    end
end)
