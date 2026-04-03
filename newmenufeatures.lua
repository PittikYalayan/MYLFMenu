
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera    = Workspace.CurrentCamera
local Players    = game:GetService("Players")
local Player     = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

local features = {}
features._espObjects = {}
features._conns = {}
features._opt = {}
features._waypoints = {}
features._selected = nil
features.TeamCheck       = true     -- aynı takım hedeflenmez
features.Smoothness      = 1        -- 1 = anında bak; 3-6 = yumuşak
features.AimRequireLOS   = false    -- true: duvar arkası görmez
features.AimUseFOV       = false    -- true: FOV (açı) sınırı uygular
features.AimMaxAngleDeg  = 360      -- AimUseFOV=true iken
features.AimMaxDistance  = 1800     -- ~500 metre (1 stud ≈ 0.28 m → 500m ≈ 1800 stud)


----------------------------------------------------------------
-- Hedef seçimi (kafaya kilit, gövde içinden geçerek de algılar)
----------------------------------------------------------------
local function getClosestVisibleHead()
    local cam    = workspace.CurrentCamera
    local origin = cam.CFrame.Position
    local look   = cam.CFrame.LookVector

    local bestHead, bestScore = nil, math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            local hum  = plr.Character:FindFirstChildOfClass("Humanoid")
            local head = plr.Character:FindFirstChild("Head")
            if hum and head and hum.Health > 0 then
                if not (features.TeamCheck and Player.Team and plr.Team and plr.Team == Player.Team) then
                    local toHead = head.Position - origin
                    local dist   = toHead.Magnitude
                    if dist <= (features.AimMaxDistance or 1e9) then
                        local dirUnit = toHead.Unit
                        local dot   = math.clamp(look:Dot(dirUnit), -1, 1)
                        local angle = math.deg(math.acos(dot)) -- 0° en iyi

                        if (not features.AimUseFOV) or (angle <= (features.AimMaxAngleDeg or 360)) then
                            -- 🔒 Duvar arkası kontrol: ama düşmanın kendi gövdesini whitelist yap
                            local rcParams = RaycastParams.new()
                            rcParams.FilterType = Enum.RaycastFilterType.Blacklist
                            rcParams.FilterDescendantsInstances = { Player.Character } -- kendi karakterimizi hariç tut
                            
                            -- 🔑 gövdeyi engel sayma → düşman karakterini whitelist yap
                            local hit = workspace:Raycast(origin, dirUnit * dist, rcParams)
                            if not hit or (hit.Instance and hit.Instance:IsDescendantOf(plr.Character)) then
                                if angle < bestScore then
                                    bestScore, bestHead = angle, head
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return bestHead
end







----------------------------------------------------------------
-- Aimbot (açı tabanlı + opsiyonel otomatik ateş)
----------------------------------------------------------------
function features.ToggleAimbot(on)
    local cam = workspace.CurrentCamera
    local function step()
        local head = getClosestVisibleHead()
        if not head then return end
        local target = CFrame.new(cam.CFrame.Position, head.Position)
        local s = tonumber(features.Smoothness) or 1
        cam.CFrame = (s > 1) and cam.CFrame:Lerp(target, 1/s) or target

        if features.TriggerOnAim then
            local now = tick()
            if (now - (features._lastTrigger or 0)) >= (features.TriggerRate or 0.12) then
                local ch = Player.Character
                local tool = ch and ch:FindFirstChildOfClass("Tool")
                if tool then 
                    pcall(function() tool:Activate() end) 
                    features._lastTrigger = now 
                end
            end
        end
    end
    if on then
        if features._aim then features._aim:Disconnect() end
        features._aim = RunService.RenderStepped:Connect(step)
    else
        if features._aim then 
            features._aim:Disconnect()
            features._aim=nil 
        end
    end
end

----------------------------------------------------------------
-- Hedef bulucu: en yakın görünür kafa
----------------------------------------------------------------
--// Services
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Camera     = workspace.CurrentCamera
local Players    = game:GetService("Players")
local LP         = Players.LocalPlayer

--// Durum
local SilentAimActive = false
local RageModeActive  = false
local Hooked          = false

--// Head finder (legit + rage)
local function getClosestHead()
    local closest, dist = nil, math.huge
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            local hum  = plr.Character:FindFirstChildOfClass("Humanoid")
            if head and hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X,pos.Y) - UIS:GetMouseLocation()).Magnitude
                    if mag < dist then
                        dist = mag
                        closest = head
                    end
                end
            end
        end
    end
    return closest
end

local function getAnyHead()
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            local hum  = plr.Character:FindFirstChildOfClass("Humanoid")
            if head and hum and hum.Health > 0 then
                return head
            end
        end
    end
    return nil
end

--// Arg Patch
local function PatchArgs(args, headPos)
    for i,v in ipairs(args) do
        if typeof(v) == "Vector3" then
            args[i] = headPos
        elseif typeof(v) == "CFrame" then
            args[i] = CFrame.new(v.Position, headPos)
        elseif typeof(v) == "table" then
            for k,val in pairs(v) do
                local key = tostring(k):lower()
                if key:find("pos") or key:find("hit") or key:find("target") then
                    if typeof(val) == "Vector3" then
                        v[k] = headPos
                    elseif typeof(val) == "CFrame" then
                        v[k] = CFrame.new(val.Position, headPos)
                    end
                end
            end
        end
    end
    return args
end

--// Raycast hook




--// __namecall hook (Remote patch)
local function EnsureHook()
    if Hooked then return end
    Hooked = true

    local old
    old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args   = {...}

        if (self:IsA("RemoteEvent") or self:IsA("RemoteFunction"))
        and (method == "FireServer" or method == "InvokeServer") then
            if SilentAimActive then
                local head = RageModeActive and getAnyHead() or getClosestHead()
                if head then
                    args = PatchArgs(args, head.Position)
                    return old(self, table.unpack(args))
                end
            end
        end

        return old(self, ...)
    end))
end

--// Mouse.Hit spoof (bazı oyunlar bunu kullanır)


--// Toggle Fonksiyonları
function ToggleSilentAim(on)
    SilentAimActive = (on == true)
    EnsureHook()
    print("[SilentAim] "..(SilentAimActive and "ON" or "OFF"))
end

function ToggleRageMode(on)
    RageModeActive = (on == true)
    print("[RageMode] "..(RageModeActive and "ON" or "OFF"))
end







return features
