local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local player = game.Players.LocalPlayer

local Features = {}

-- === AIM ===
Features.AimbotEnabled = false
local oldFire

local function getClosestHead()
    local closest, dist = nil, math.huge
    local cam = workspace.CurrentCamera
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
            local head = plr.Character.Head
            local pos, onScreen = cam:WorldToViewportPoint(head.Position)
            if onScreen then
                local d = (Vector2.new(pos.X, pos.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
                if d < dist then dist, closest = d, head end
            end
        end
    end
    return closest
end

local function clearRecoilSpread(args)
    for i, v in ipairs(args) do
        if typeof(v) == "Vector3" then
            args[i] = Vector3.new(v.X, v.Y, 0)
        end
    end
    return args
end

function Features.ToggleAimbot()
    Features.AimbotEnabled = not Features.AimbotEnabled
    if Features.AimbotEnabled then
        oldFire = hookmetamethod(game, "__namecall", function(self, ...)
            local m, args = getnamecallmethod(), {...}
            if m == "FireServer" and (tostring(self):lower():find("fire") or tostring(self):lower():find("shoot")) then
                local head = getClosestHead()
                if head then
                    if typeof(args[1]) == "Vector3" then args[1] = head.Position
                    elseif typeof(args[2]) == "Vector3" then args[2] = head.Position end
                end
                args = clearRecoilSpread(args)
                return oldFire(self, unpack(args))
            end
            return oldFire(self, ...)
        end)
    else
        if oldFire then
            hookmetamethod(game, "__namecall", oldFire)
        end
    end
end

-- Silent Aim
Features.SilentAimEnabled = false
local oldNamecall
function Features.ToggleSilentAim()
    Features.SilentAimEnabled = not Features.SilentAimEnabled
    if Features.SilentAimEnabled then
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local m, args = getnamecallmethod(), {...}
            if m == "FireServer" and (tostring(self):lower():find("fire") or tostring(self):lower():find("shoot")) then
                local head = getClosestHead()
                if head then
                    if typeof(args[1]) == "Vector3" then args[1] = head.Position
                    elseif typeof(args[2]) == "Vector3" then args[2] = head.Position end
                end
                return oldNamecall(self, unpack(args))
            end
            return oldNamecall(self, ...)
        end)
    else
        if oldNamecall then
            hookmetamethod(game, "__namecall", oldNamecall)
        end
    end
end

-- === PLAYER ===
Features.SpeedEnabled = false
local speedConn
local function applySpeed()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = Features.SpeedEnabled and 50 or 16
    end
end
function Features.ToggleSpeed()
    Features.SpeedEnabled = not Features.SpeedEnabled
    if Features.SpeedEnabled then
        speedConn = runService.Heartbeat:Connect(applySpeed)
        applySpeed()
    else
        if speedConn then speedConn:Disconnect() end
        applySpeed()
    end
end

Features.GodEnabled = false
local godConn
local function applyGodmode()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.Health = math.huge
        char.Humanoid.MaxHealth = math.huge
    end
end
function Features.ToggleGodmode()
    Features.GodEnabled = not Features.GodEnabled
    if Features.GodEnabled then
        godConn = runService.Heartbeat:Connect(applyGodmode)
        applyGodmode()
    else
        if godConn then godConn:Disconnect() end
    end
end

Features.FlyEnabled = false
local flyConn
local function applyFly()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    if Features.FlyEnabled then
        if not hrp:FindFirstChild("BodyVelocity") then
            local bv = Instance.new("BodyVelocity", hrp)
            bv.MaxForce = Vector3.new(4000, 4000, 4000)
            bv.Velocity = Vector3.zero
        end
        flyConn = runService.RenderStepped:Connect(function()
            local dir, cam = Vector3.zero, workspace.CurrentCamera.CFrame
            if uis:IsKeyDown(Enum.KeyCode.W) then dir += cam.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.S) then dir -= cam.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.A) then dir -= cam.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.D) then dir += cam.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
            if uis:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
            hrp.BodyVelocity.Velocity = dir * 60
        end)
    else
        if hrp:FindFirstChild("BodyVelocity") then hrp.BodyVelocity:Destroy() end
        if flyConn then flyConn:Disconnect() end
    end
end
function Features.ToggleFly()
    Features.FlyEnabled = not Features.FlyEnabled
    applyFly()
end

Features.InfJumpEnabled = false
function Features.ToggleInfiniteJump()
    Features.InfJumpEnabled = not Features.InfJumpEnabled
    if Features.InfJumpEnabled then
        uis.JumpRequest:Connect(function()
            if Features.InfJumpEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end

Features.InvisibleEnabled = false
function Features.ToggleInvisible()
    Features.InvisibleEnabled = not Features.InvisibleEnabled
    local char = player.Character or player.CharacterAdded:Wait()
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = Features.InvisibleEnabled and 1 or 0
            if part.Name ~= "HumanoidRootPart" and part:FindFirstChild("face") then
                if Features.InvisibleEnabled then part.face:Destroy() end
            end
        end
    end
end

-- === MISC ===
Features.TeleportEnabled = false
function Features.ToggleTeleportTool()
    Features.TeleportEnabled = not Features.TeleportEnabled
    spawn(function()
        while Features.TeleportEnabled do
            if uis:IsKeyDown(Enum.KeyCode.T) then
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char:MoveTo(player:GetMouse().Hit.p + Vector3.new(0,3,0))
                end
            end
            task.wait(0.2)
        end
    end)
end

Features.KillAuraEnabled = false
local auraConn
function Features.ToggleKillAura()
    Features.KillAuraEnabled = not Features.KillAuraEnabled
    if Features.KillAuraEnabled then
        auraConn = runService.Heartbeat:Connect(function()
            local char = player.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            if char and tool then
                for _, plr in ipairs(game.Players:GetPlayers()) do
                    if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        if (plr.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude < 15 then
                            tool:Activate()
                        end
                    end
                end
            end
        end)
    else
        if auraConn then auraConn:Disconnect() end
    end
end

Features.NoclipEnabled = false
local noclipConn
function Features.ToggleNoclip()
    Features.NoclipEnabled = not Features.NoclipEnabled
    if Features.NoclipEnabled then
        noclipConn = runService.Stepped:Connect(function()
            local char = player.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() end
    end
end

Features.ESPEnabled = false
local espObjects = {}
local function rainbowColor(t)
    return Color3.fromHSV((t*0.1)%1,1,1)
end
local function isEnemy(plr)
    local myTeam = player.Team
    if myTeam and plr.Team then return plr.Team ~= myTeam end
    return true
end
local function addESP(plr, t)
    if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
        espObjects[plr] = espObjects[plr] or {}
        if not espObjects[plr].highlight then
            local highlight = Instance.new("Highlight")
            highlight.FillTransparency = 0.5
            highlight.FillColor = isEnemy(plr) and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0)
            highlight.OutlineColor = Color3.fromRGB(255,255,255)
            highlight.Parent = plr.Character
            espObjects[plr].highlight = highlight
        end
        if not espObjects[plr].billboard then
            local billboard = Instance.new("BillboardGui", plr.Character.Head)
            billboard.Size = UDim2.new(0,100,0,20)
            billboard.StudsOffset = Vector3.new(0,2,0)
            billboard.AlwaysOnTop = true
            local label = Instance.new("TextLabel", billboard)
            label.Size = UDim2.new(1,0,1,0)
            label.BackgroundTransparency = 1
            label.Text = plr.Name
            label.TextColor3 = isEnemy(plr) and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0)
            label.Font = Enum.Font.SourceSansBold
            label.TextScaled = true
            espObjects[plr].billboard = billboard
            espObjects[plr].label = label
        end
        espObjects[plr].label.TextColor3 = rainbowColor(t)
    end
end
function Features.ToggleESP()
    Features.ESPEnabled = not Features.ESPEnabled
    if Features.ESPEnabled then
        spawn(function()
            local t = 0
            while Features.ESPEnabled do
                for _, plr in ipairs(game.Players:GetPlayers()) do
                    addESP(plr, t)
                end
                for plr, objs in pairs(espObjects) do
                    if not plr.Character or not plr.Character:FindFirstChild("Head") then
                        if objs.highlight then objs.highlight:Destroy() end
                        if objs.billboard then objs.billboard:Destroy() end
                        espObjects[plr] = nil
                    end
                end
                t = t + 1
                task.wait(0.1)
            end
        end)
    else
        for _, objs in pairs(espObjects) do
            if objs.highlight then objs.highlight:Destroy() end
            if objs.billboard then objs.billboard:Destroy() end
        end
        espObjects = {}
    end
end

return Features
