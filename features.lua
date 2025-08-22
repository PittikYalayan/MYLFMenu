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

-- ========== FLY ==========
local flyConn
function features.ToggleFly(state)
    local player = game.Players.LocalPlayer
    if state then
        if not flyConn then
            flyConn = game:GetService("RunService").Heartbeat:Connect(function()
                local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Physics)
                    player.Character:TranslateBy(Vector3.new(0,0.5,0))
                end
            end)
        end
    else
        if flyConn then flyConn:Disconnect(); flyConn = nil end
    end
end

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
features.FOV = 120
local aimConn
function features.ToggleAimbot(state)
    if state then
        if not aimConn then
            local cam = workspace.CurrentCamera
            aimConn = game:GetService("RunService").RenderStepped:Connect(function()
                local closest, dist = nil, math.huge
                for _,plr in ipairs(game.Players:GetPlayers()) do
                    if plr ~= game.Players.LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                        local pos, vis = cam:WorldToViewportPoint(plr.Character.Head.Position)
                        if vis then
                            local mag = (Vector2.new(pos.X,pos.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
                            if mag < dist and mag < features.FOV then
                                dist = mag
                                closest = plr
                            end
                        end
                    end
                end
                if closest and closest.Character and closest.Character:FindFirstChild("Head") then
                    cam.CFrame = CFrame.new(cam.CFrame.Position, closest.Character.Head.Position)
                end
            end)
        end
    else
        if aimConn then aimConn:Disconnect(); aimConn = nil end
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
function features.ToggleTeleport(state)
    local lp = game.Players.LocalPlayer
    if state then
        if not lp.Backpack:FindFirstChild("ClickTP") then
            local tool = Instance.new("Tool", lp.Backpack)
            tool.RequiresHandle = false
            tool.Name = "ClickTP"
            tool.Activated:Connect(function()
                local mouse = lp:GetMouse()
                if mouse.Hit then lp.Character:MoveTo(mouse.Hit.p) end
            end)
        end
    else
        if lp.Backpack:FindFirstChild("ClickTP") then
            lp.Backpack.ClickTP:Destroy()
        end
    end
end

-- ========== ESP ==========
local espObjects = {}
function features.ToggleESP(state)
    if state then
        for _,plr in ipairs(game.Players:GetPlayers()) do
            if plr ~= game.Players.LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                local highlight = Instance.new("Highlight", plr.Character)
                highlight.FillTransparency = 0.5
                highlight.OutlineColor = Color3.fromRGB(0,255,0)
                espObjects[plr] = highlight
            end
        end
    else
        for plr,obj in pairs(espObjects) do
            if obj then obj:Destroy() end
        end
        espObjects = {}
    end
end

-- ========== ESP Skeleton (EKLENDİ) ==========
function features.ToggleSkeleton(state)
    if state then
        print("Skeleton ESP ON") -- Buraya çizgi çizdirme kodları entegre edebilirsin
    else
        print("Skeleton ESP OFF")
    end
end

-- ========== ESP Rainbow Name (EKLENDİ) ==========
local rainbowConn
function features.ToggleRainbowName(state)
    if state then
        if not rainbowConn then
            rainbowConn = game:GetService("RunService").Heartbeat:Connect(function()
                local t = tick()
                local r = math.sin(t*2) * 127 + 128
                local g = math.sin(t*2 + 2) * 127 + 128
                local b = math.sin(t*2 + 4) * 127 + 128
                for _,plr in ipairs(game.Players:GetPlayers()) do
                    if plr.Character and plr.Character:FindFirstChild("Head") then
                        plr.NameDisplayDistance = 200
                        plr.NameDisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                        plr.Character.Head.BillboardGui.TextLabel.TextColor3 = Color3.fromRGB(r,g,b)
                    end
                end
            end)
        end
    else
        if rainbowConn then rainbowConn:Disconnect(); rainbowConn = nil end
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
function features.ToggleInspector(state)
    if state then
        for _,plr in ipairs(game.Players:GetPlayers()) do
            if plr.Character then
                for _,tool in ipairs(plr.Backpack:GetChildren()) do
                    print(plr.Name.." has tool: "..tool.Name)
                end
            end
        end
    end
end

return features
