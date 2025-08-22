-- ⚡ MYLF Universal Hack Features ⚡
-- Player / Aim / Visuals / Misc kategorili

local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local cam = workspace.CurrentCamera
local mouse = player:GetMouse()

local features = {}

--------------------------------------------------
-- PLAYER
--------------------------------------------------

-- 🕊️ Fly (Slider ile hız ayarlı)
features.Fly = {
    Enabled = false,
    Speed = 60,
}

local flyConn
local function applyFly()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        if features.Fly.Enabled then
            if not hrp:FindFirstChild("BodyVelocity") then
                local bv = Instance.new("BodyVelocity", hrp)
                bv.MaxForce = Vector3.new(4000,4000,4000)
                bv.Velocity = Vector3.zero
            end
            flyConn = runService.RenderStepped:Connect(function()
                if hrp:FindFirstChild("BodyVelocity") then
                    local dir = Vector3.zero
                    local camCFrame = workspace.CurrentCamera.CFrame
                    if uis:IsKeyDown(Enum.KeyCode.W) then dir += camCFrame.LookVector end
                    if uis:IsKeyDown(Enum.KeyCode.S) then dir -= camCFrame.LookVector end
                    if uis:IsKeyDown(Enum.KeyCode.A) then dir -= camCFrame.RightVector end
                    if uis:IsKeyDown(Enum.KeyCode.D) then dir += camCFrame.RightVector end
                    if uis:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
                    if uis:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
                    hrp.BodyVelocity.Velocity = dir * features.Fly.Speed
                end
            end)
        else
            if hrp:FindFirstChild("BodyVelocity") then hrp.BodyVelocity:Destroy() end
            if flyConn then flyConn:Disconnect() end
        end
    end
end
features.ApplyFly = applyFly

-- ⚡ Speed Hack (Slider)
features.Speed = {
    Enabled = false,
    Value = 50
}

local speedConn
local function applySpeed()
    if features.Speed.Enabled then
        speedConn = runService.Stepped:Connect(function()
            local char = player.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                char:FindFirstChildOfClass("Humanoid").WalkSpeed = features.Speed.Value
            end
        end)
    else
        if speedConn then speedConn:Disconnect() end
        local char = player.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
        end
    end
end
features.ApplySpeed = applySpeed

-- 🌀 Teleport Tool (T ile)
features.Teleport = {
    Enabled = false
}
function features.ToggleTeleport()
    features.Teleport.Enabled = not features.Teleport.Enabled
    if features.Teleport.Enabled then
        spawn(function()
            while features.Teleport.Enabled do
                if uis:IsKeyDown(Enum.KeyCode.T) then
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char:MoveTo(mouse.Hit.p + Vector3.new(0,3,0))
                    end
                end
                task.wait(0.2)
            end
        end)
    end
end

--------------------------------------------------
-- AIM
--------------------------------------------------

-- 🎯 Aimbot (Takım kontrol + no recoil/no spread)
features.Aimbot = {
    Enabled = false,
    TargetPart = "Head"
}

local function getClosestVisibleHead()
    local closest, dist = nil, math.huge
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            if not (player.Team and plr.Team and player.Team == plr.Team) then
                local head = plr.Character.Head
                local pos, vis = cam:WorldToViewportPoint(head.Position)
                if vis then
                    local mag = (Vector2.new(pos.X,pos.Y) - uis:GetMouseLocation()).Magnitude
                    if mag < dist then
                        closest, dist = head, mag
                    end
                end
            end
        end
    end
    return closest
end
features.GetClosestVisibleHead = getClosestVisibleHead

--------------------------------------------------
-- VISUALS
--------------------------------------------------

-- 👀 ESP (Rainbow + NPC + Skeleton)
features.ESP = {
    Enabled = false,
    Objects = {}
}

local function rainbowColor(t)
    local r = math.sin(t*2) * 127 + 128
    local g = math.sin(t*2 + 2) * 127 + 128
    local b = math.sin(t*2 + 4) * 127 + 128
    return Color3.fromRGB(r,g,b)
end
features.RainbowColor = rainbowColor

--------------------------------------------------
-- MISC
--------------------------------------------------

-- 🛠 Tool Inspector
features.ToolInspector = {
    Enabled = false
}

return features
