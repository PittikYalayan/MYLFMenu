local runService = game:GetService("RunService")
local player = game.Players.LocalPlayer
local features = {}

-- === FEATURES ===
local features = {}
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")

-- ⚡ Speed
features.SetSpeed = function(val)
    local function applySpeed()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = val
        end
    end
    if features._speedConn then features._speedConn:Disconnect() end
    features._speedConn = runService.Heartbeat:Connect(applySpeed)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        applySpeed()
    end)
end

-- ❤️ Godmode
features.ToggleGodmode = function(val)
    local function applyGodmode()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Health = math.huge
            player.Character.Humanoid.MaxHealth = math.huge
        end
    end
    if val then
        if features._godConn then features._godConn:Disconnect() end
        features._godConn = runService.Heartbeat:Connect(applyGodmode)
        player.CharacterAdded:Connect(function()
            task.wait(1)
            if features._godConn then features._godConn:Disconnect() end
            features._godConn = runService.Heartbeat:Connect(applyGodmode)
        end)
    else
        if features._godConn then features._godConn:Disconnect() end
    end
end

-- 🕊️ Fly
features._flySpeed = 60
features.SetFlySpeed = function(val) features._flySpeed = val end
features.ToggleFly = function(val)
    local uis = game:GetService("UserInputService")
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if val then
        if not hrp:FindFirstChild("BodyVelocity") then
            local bv = Instance.new("BodyVelocity", hrp)
            bv.MaxForce = Vector3.new(4000,4000,4000)
            bv.Velocity = Vector3.zero
        end
        if features._flyConn then features._flyConn:Disconnect() end
        features._flyConn = runService.RenderStepped:Connect(function()
            if hrp:FindFirstChild("BodyVelocity") then
                local dir = Vector3.zero
                local cam = workspace.CurrentCamera.CFrame
                if uis:IsKeyDown(Enum.KeyCode.W) then dir += cam.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.S) then dir -= cam.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.A) then dir -= cam.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.D) then dir += cam.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
                if uis:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
                hrp.BodyVelocity.Velocity = dir * (features._flySpeed or 60)
            end
        end)
        player.CharacterAdded:Connect(function()
            task.wait(1)
            if val then features.ToggleFly(true) end
        end)
    else
        if hrp:FindFirstChild("BodyVelocity") then hrp.BodyVelocity:Destroy() end
        if features._flyConn then features._flyConn:Disconnect() end
    end
end

-- ☁️ Infinite Jump
features.ToggleInfiniteJump = function(val)
    local uis = game:GetService("UserInputService")
    if val then
        if features._infConn then features._infConn:Disconnect() end
        features._infConn = uis.JumpRequest:Connect(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if features._infConn then features._infConn:Disconnect() features._infConn = nil end
    end
end

-- 🌀 Teleport
features.ToggleTeleport = function(val)
    local uis = game:GetService("UserInputService")
    local mouse = player:GetMouse()
    if val then
        if features._tpConn then features._tpConn:Disconnect() end
        features._tpConn = runService.Heartbeat:Connect(function()
            if uis:IsKeyDown(Enum.KeyCode.T) then
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char:MoveTo(mouse.Hit.p + Vector3.new(0,3,0))
                end
            end
        end)
    else
        if features._tpConn then features._tpConn:Disconnect() features._tpConn = nil end
    end
end

-- 🤫 Silent Aim
features.ToggleSilentAim = function(val)
    if val then
        if features._oldNamecall then return end
        features._silentAim = true
        features._oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            if features._silentAim and method == "FireServer" then
                local name = tostring(self):lower()
                if name:find("fire") or name:find("shoot") then
                    local head = getClosestVisibleHead and getClosestVisibleHead()
                    if head then
                        if typeof(args[1]) == "Vector3" then
                            args[1] = head.Position
                        elseif args[2] and typeof(args[2]) == "Vector3" then
                            args[2] = head.Position
                        end
                        return features._oldNamecall(self, unpack(args))
                    end
                end
            end
            return features._oldNamecall(self, ...)
        end)
    else
        features._silentAim = false
        if features._oldNamecall then
            hookmetamethod(game, "__namecall", features._oldNamecall)
            features._oldNamecall = nil
        end
    end
end

-- 🔫 Rapid Fire
features.ToggleRapidFire = function(val)
    if val then
        if features._rofConn then features._rofConn:Disconnect() end
        features._rofConn = runService.Heartbeat:Connect(function()
            local char = player.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    for _, obj in pairs(tool:GetDescendants()) do
                        if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                            local name = obj.Name:lower()
                            if name:find("cooldown") or name:find("fire") or name:find("attack") or name:find("reload") or name:find("speed") then
                                obj.Value = 0.05
                            end
                        end
                    end
                end
            end
        end)
    else
        if features._rofConn then features._rofConn:Disconnect() features._rofConn = nil end
    end
end

-- 🚪 Noclip
features.ToggleNoclip = function(val)
    if val then
        if features._noclipConn then features._noclipConn:Disconnect() end
        features._noclipConn = runService.Stepped:Connect(function()
            local char = player.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if features._noclipConn then features._noclipConn:Disconnect() features._noclipConn = nil end
    end
end

-- 👀 ESP
features.ToggleESP = function(val) 
    -- 👀 ESP (uyarlanmış)
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local player = game.Players.LocalPlayer

local espObjects = {}
local function rainbowColor(t)
    local r = math.sin(t*2) * 127 + 128
    local g = math.sin(t*2 + 2) * 127 + 128
    local b = math.sin(t*2 + 4) * 127 + 128
    return Color3.fromRGB(r,g,b)
end
local function getAdornee(target)
    return target:FindFirstChild("Head")
        or target:FindFirstChild("UpperTorso")
        or target:FindFirstChild("Torso")
        or target:FindFirstChild("HumanoidRootPart")
end
local skeletonJoints = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}

local function addESP(target, isNPC)
    local adornee = getAdornee(target)
    if target and adornee then
        if not espObjects[target] then espObjects[target] = {} end
        local obj = espObjects[target]

        if not obj.highlight or not obj.highlight.Parent then
            local highlight = Instance.new("Highlight")
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = Color3.fromRGB(255,255,255)
            highlight.Parent = target
            obj.highlight = highlight
        end

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

features.ToggleESP = function(val)
    if val then
        -- tüm oyuncular
        for _, plr in pairs(game.Players:GetPlayers()) do
            plr.CharacterAdded:Connect(function(char)
                task.wait(1)
                addESP(char, false)
            end)
            if plr.Character then addESP(plr.Character, false) end
        end
        -- NPC’ler
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:FindFirstChildOfClass("Humanoid") and getAdornee(obj) and not game.Players:GetPlayerFromCharacter(obj) then
                addESP(obj, true)
            end
        end
        workspace.ChildAdded:Connect(function(obj)
            if obj:FindFirstChildOfClass("Humanoid") and getAdornee(obj) and not game.Players:GetPlayerFromCharacter(obj) then
                task.wait(1)
                addESP(obj, true)
            end
        end)

        -- update loop
        if features._espConn then features._espConn:Disconnect() end
        local t = 0
        features._espConn = RunService.RenderStepped:Connect(function(dt)
            t += dt
            for _, objs in pairs(espObjects) do
                if features._espRainbow and objs.label then
                    objs.label.TextColor3 = rainbowColor(t)
                end
                if objs.highlight then
                    objs.highlight.FillColor = features._espRainbow and rainbowColor(t) or Color3.fromRGB(0,255,0)
                end
                if features._espSkeleton and objs.skeleton then
                    for _, s in pairs(objs.skeleton) do
                        local p1 = _:FindFirstChild(s.parts[1])
                        local p2 = _:FindFirstChild(s.parts[2])
                        if p1 and p2 then
                            local v1, onscreen1 = Camera:WorldToViewportPoint(p1.Position)
                            local v2, onscreen2 = Camera:WorldToViewportPoint(p2.Position)
                            if onscreen1 and onscreen2 then
                                s.line.From = Vector2.new(v1.X, v1.Y)
                                s.line.To = Vector2.new(v2.X, v2.Y)
                                s.line.Color = features._espRainbow and rainbowColor(t) or Color3.fromRGB(255,255,255)
                                s.line.Visible = true
                            else
                                s.line.Visible = false
                            end
                        end
                    end
                end
            end
            clearDead()
        end)
    else
        if features._espConn then features._espConn:Disconnect() end
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

features.ToggleSkeleton = function(val)
    features._espSkeleton = val
end
features.ToggleRainbowName = function(val)
    features._espRainbow = val
end
-- (detaylı esp kodu burada yukarda uyarladığımız)
end
features.ToggleSkeleton = function(val) features._espSkeleton = val end
features.ToggleRainbowName = function(val) features._espRainbow = val end

-- 🎯 Aimbot + NoRecoil + NoSpread
features.TeamCheck = true
features.Smoothness = 5
features.ToggleAimbot = function(val) 
    -- 🎯 Aimbot + NoRecoil + NoSpread (uyarlanmış)
local runService = game:GetService("RunService")
local cam = workspace.CurrentCamera
local player = game.Players.LocalPlayer

local function getClosestVisibleHead()
    local closest, dist = nil, math.huge
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            if not (features.TeamCheck and player.Team and plr.Team and player.Team == plr.Team) then
                local head = plr.Character.Head
                local headPos = head.Position

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

features.ToggleAimbot = function(val)
    if val then
        if features._aimConn then features._aimConn:Disconnect() end
        if features._weaponConn then features._weaponConn:Disconnect() end

        -- aim loop
        features._aimConn = runService.RenderStepped:Connect(function()
            local head = getClosestVisibleHead()
            if head then
                -- Smooth aiming
                if features.Smoothness and features.Smoothness > 1 then
                    local targetCF = CFrame.new(cam.CFrame.Position, head.Position)
                    cam.CFrame = cam.CFrame:Lerp(targetCF, 1 / features.Smoothness)
                else
                    cam.CFrame = CFrame.new(cam.CFrame.Position, head.Position)
                end
            end
        end)

        -- no recoil & no spread loop
        features._weaponConn = runService.Heartbeat:Connect(function()
            local char = player.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    removeRecoilSpread(tool)
                end
            end
        end)
    else
        if features._aimConn then features._aimConn:Disconnect() features._aimConn = nil end
        if features._weaponConn then features._weaponConn:Disconnect() features._weaponConn = nil end
    end
end
-- (yukarda verdiğimiz aimbot kodu burada)
end

-- ⚔️ Kill Aura
features.ToggleKillAura = function(val)
    if val then
        if features._auraConn then features._auraConn:Disconnect() end
        features._auraConn = runService.Heartbeat:Connect(function()
            local char = player.Character
            if char and char:FindFirstChildOfClass("Tool") then
                local tool = char:FindFirstChildOfClass("Tool")
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
        if features._auraConn then features._auraConn:Disconnect() features._auraConn = nil end
    end
end

-- 👻 Invisible
features.ToggleInvisible = function(val)
    local char = player.Character or player.CharacterAdded:Wait()
    if val then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 1
                if part:FindFirstChild("face") then part.face:Destroy() end
            end
        end
    else
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 0
            end
        end
    end
end

-- 🛠 Tool Inspector
features.ToggleInspector = function(val) 
    -- 🛠 Tool Inspector (uyarlanmış)
features.ToggleInspector = function(val)
    local player = game.Players.LocalPlayer
    local runService = game:GetService("RunService")

    if not features._inspectorUI then
        local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
        gui.Name = "InspectorUI"
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Enabled = true

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

        local function inspectTool(tool)
            for _, obj in pairs(scroll:GetChildren()) do
                if obj:IsA("Frame") then obj:Destroy() end
            end

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

        -- store
        features._inspectorUI = inspector
        features._inspectTool = inspectTool
    end

    -- toggle UI
    features._inspectorUI.Visible = val

    if val then
        -- sürekli güncel tutsun
        if features._inspectorConn then features._inspectorConn:Disconnect() end
        features._inspectorConn = runService.Heartbeat:Connect(function()
            local char = player.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    features._inspectTool(tool)
                end
            end
        end)
    else
        if features._inspectorConn then features._inspectorConn:Disconnect() end
    end
end
-- (uyarladığımız inspector kodu buraya)
end

return features
