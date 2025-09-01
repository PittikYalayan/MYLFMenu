-- ⚡ MYLF | Hub ⚡ — FEATURES (Inspector YOK, Magic Bullet entegre, tek hook)
-- Aimbot: açı tabanlı (mesafeden bağımsız hedef seçimi) + opsiyonel auto-fire
-- ESP: join/leave/respawn canlı, NPC destekli
-- Noclip: restore’luTransparency
-- Fly: LCtrl aşağı
-- Magic Bullet (Fallback): Tool içi remotelere whitelist + tek __namecall hook
-- Silent Aim ile çatışmaz: öncelik Silent Aim > Magic Bullet

local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera    = Workspace.CurrentCamera
local Players    = game:GetService("Players")
local Player     = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

local features = {}
----------------------------------------------------------------
-- AIMBOT CONFIG
----------------------------------------------------------------
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

features = features or {}        -- güvenlik için
features._espObjects = features._espObjects or {}
features._targets = features._targets or {}
features._conns = features._conns or {}
features._t = features._t or 0


features._tpTargetId   = nil
features._tpTargetMap  = {}
features._tpBehindDist = 3

features.TriggerOnAim    = false     -- hedefteyken otomatik ateş
features.TriggerRate     = 0     -- tetikler arası min süre
features._lastTrigger    = 0 
features._aura = 1000
features.DamageAmount = 900
local DamageRemote = game:GetService("ReplicatedStorage"):WaitForChild("DamageRemote", 5)


local DamageRemote = game:GetService("ReplicatedStorage"):WaitForChild("DamageRemote", 5)

function features.ToggleKillAura(on)
    if on then
        if features._aura then features._aura:Disconnect() end
        features._aura = RunService.Heartbeat:Connect(function()
            local myChar = Player.Character
            local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local myHum  = myChar and myChar:FindFirstChildOfClass("Humanoid")
            local tool   = myChar and myChar:FindFirstChildOfClass("Tool")
            if not (myChar and myHRP and myHum and myHum.Health > 0) then return end

            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= Player and plr.Character then
                    local enemyChar = plr.Character
                    local enemyHRP  = enemyChar:FindFirstChild("HumanoidRootPart")
                    local enemyHum  = enemyChar:FindFirstChildOfClass("Humanoid")
                    if enemyHRP and enemyHum and enemyHum.Health > 0 then
                        local dist = (enemyHRP.Position - myHRP.Position).Magnitude
                        if dist < 20 then
                            if tool then pcall(function() tool:Activate() end) end
                            if DamageRemote then
                                pcall(function()
                                    DamageRemote:FireServer({Target = enemyChar, Damage = features.DamageAmount})
                                end)
                            end
                        end
                    end
                end
            end
        end)
        print("KillAura ON ✅")
    else
        if features._aura then features._aura:Disconnect(); features._aura=nil end
        print("KillAura OFF ❌")
    end
end




-- =====================================
-- MYLF ESP SYSTEM (features1.1.7.lua)
-- =====================================


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
-- Speed 50↔16
----------------------------------------------------------------

features._walkSpeed = features._walkSpeed or 16

function features.ToggleSpeed(on)
    local function apply()
        local h = Player.Character and Player.Character:FindFirstChild("Humanoid")
        if h then
            h.WalkSpeed = on and features._walkSpeed or 16
        end
    end

    if on then
        if features._spd then features._spd:Disconnect() end
        features._spd = RunService.Heartbeat:Connect(apply)
        Player.CharacterAdded:Connect(function()
            task.wait(0.5)
            apply()
        end)
    else
        if features._spd then features._spd:Disconnect() end
        apply()
    end
end

function features.SetWalkSpeed(val)
    features._walkSpeed = tonumber(val) or 16
    print("[MYLF] WalkSpeed set to", features._walkSpeed)
end


----------------------------------------------------------------
-- Godmode
----------------------------------------------------------------
----------------------------------------------------------------
-- ⚡ Gelişmiş Godmode (Multi-Hook + AutoHeal + AntiSlow)
----------------------------------------------------------------
----------------------------------------------------------------
-- ⚡ Full Godmode (Multi-Hook + Heal + AntiSlow + AntiRagdoll + AntiSit)
----------------------------------------------------------------
----------------------------------------------------------------
-- ⚡ Ultra Full Godmode (Hard Multi-Hook + Anti-Grab + Anti-Freeze)
----------------------------------------------------------------
--// Durum
local GodmodeActive = false
local GodHooks = {namecall=false, index=false, raycast=false}

--// Patch Damage Args (namecall için)
local function PatchDamageArgs(args)
    for i,v in ipairs(args) do
        local str = tostring(v):lower()
        if str:find("damage") or str:find("hit") or str:find("hurt") then
            if type(v) == "number" then
                args[i] = 0
            elseif typeof(v) == "table" then
                for k,val in pairs(v) do
                    local key = tostring(k):lower()
                    if key:find("damage") or key:find("hit") then
                        v[k] = 0
                    end
                end
            end
        end
    end
    return args
end

--// __namecall Hook
local function HookNamecall()
    if GodHooks.namecall then return end
    GodHooks.namecall = true

    local old
    old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if GodmodeActive and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction"))
        and (method == "FireServer" or method == "InvokeServer") then
            args = PatchDamageArgs(args)
            return old(self, table.unpack(args))
        end

        return old(self, ...)
    end))
end

--// __index Hook (Health okumalarını patchle)
local function HookIndex()
    if GodHooks.index then return end
    GodHooks.index = true

    local old
    old = hookmetamethod(game, "__index", newcclosure(function(self, key)
        if GodmodeActive and tostring(key):lower():find("health") then
            if self:IsA("Humanoid") and self == Player.Character:FindFirstChildOfClass("Humanoid") then
                return self.MaxHealth -- her zaman max döndür
            end
        end
        return old(self, key)
    end))
end

--// Raycast Hook
local function HookRaycast()
    if GodHooks.raycast then return end
    GodHooks.raycast = true

    local old = Workspace.Raycast
    Workspace.Raycast = newcclosure(function(self, origin, direction, params)
        if GodmodeActive then
            -- saldırı raycast’inde seni hedef almaya çalışsa bile boşa düşür
            local spoofOrigin = origin + Vector3.new(9999,9999,9999)
            return old(self, spoofOrigin, direction, params)
        end
        return old(self, origin, direction, params)
    end)
end

--// Toggle Fonksiyonu
function ToggleGodmode(on)
    GodmodeActive = (on == true)
    HookNamecall()
    HookIndex()
    HookRaycast()
    print("[Godmode] "..(GodmodeActive and "ON" or "OFF"))
end



----------------------------------------------------------------
-- HoverFly (yer efekti + havada emote desteği)
----------------------------------------------------------------
----------------------------------------------------------------
-- Fly (WASD + Space / Ctrl)
----------------------------------------------------------------
----------------------------------------------------------------
-- Fly / Hover Modes
-- Mode: "BV" (BodyVelocity), "BT" (BodyThrust), "AV" (AlignVelocity)
----------------------------------------------------------------
----------------------------------------------------------------
-- Fly (WASD + Space / Ctrl)
----------------------------------------------------------------
----------------------------------------------------------------
-- Hover Fly (stabil, VectorForce + AlignOrientation)
----------------------------------------------------------------
----------------------------------------------------------------
-- Ultra Fly (Server correction bypass + Camera yönlü)
----------------------------------------------------------------
-- Varsayılan değer
features._flySpeed = features._flySpeed or 60

function features.ToggleFly(on)
    local function ensureBV()
        local ch = Player.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local bv = hrp:FindFirstChildOfClass("BodyVelocity")
        if not bv then
            bv = Instance.new("BodyVelocity", hrp)
            bv.MaxForce = Vector3.new(4000,4000,4000)
            bv.Velocity = Vector3.zero
        end
        return bv, hrp
    end

    if on then
        if features._fly then features._fly:Disconnect() end
        features._fly = RunService.RenderStepped:Connect(function()
            local bv = ensureBV()
            if not bv then return end
            local dir = Vector3.zero
            local cf  = workspace.CurrentCamera.CFrame
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cf.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cf.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cf.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cf.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
            bv.Velocity = dir * (features._flySpeed or 60)
        end)
        Player.CharacterAdded:Connect(function()
            task.wait(0.5)
            if on then features.ToggleFly(true) end
        end)
    else
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = hrp:FindFirstChildOfClass("BodyVelocity")
            if bv then bv:Destroy() end
        end
        if features._fly then features._fly:Disconnect() end
    end
end

function features.SetFlySpeed(val)
    features._flySpeed = tonumber(val) or 60
    print("[MYLF] FlySpeed set to", features._flySpeed)
end



----------------------------------------------------------------
-- Infinite Jump
----------------------------------------------------------------
function features.ToggleInfiniteJump(on)
    if on then
        if features._inf then features._inf:Disconnect() end
        features._inf = UIS.JumpRequest:Connect(function()
            local h = Player.Character and Player.Character:FindFirstChild("Humanoid")
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if features._inf then features._inf:Disconnect(); features._inf=nil end
    end
end

----------------------------------------------------------------
-- Teleport (T)
----------------------------------------------------------------
function features.ToggleTeleport(on)
    local mouse = Player:GetMouse()
    if on then
        if features._tp then features._tp:Disconnect() end
        features._tp = RunService.Heartbeat:Connect(function()
            if UIS:IsKeyDown(Enum.KeyCode.T) then
                local ch = Player.Character
                local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
                if hrp then ch:MoveTo(mouse.Hit.p + Vector3.new(0,3,0)) end
            end
        end)
    else
        if features._tp then features._tp:Disconnect(); features._tp=nil end
    end
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
local oldRaycast = workspace.Raycast
workspace.Raycast = newcclosure(function(self, origin, direction, params)
    if SilentAimActive then
        local head = RageModeActive and getAnyHead() or getClosestHead()
        if head then
            direction = (head.Position - origin).Unit * direction.Magnitude
        end
    end
    return oldRaycast(self, origin, direction, params)
end)

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
local mt = getrawmetatable(game)
setreadonly(mt,false)
local oldIndex = mt.__index
mt.__index = newcclosure(function(t,k)
    if SilentAimActive and (t == UIS or tostring(t) == "Mouse") then
        if k == "Hit" or k == "Target" then
            local head = RageModeActive and getAnyHead() or getClosestHead()
            if head then
                return CFrame.new(head.Position)
            end
        end
    end
    return oldIndex(t,k)
end)
setreadonly(mt,true)

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


----------------------------------------------------------------
-- Rapid Fire Toggle
----------------------------------------------------------------
----------------------------------------------------------------
-- Hard Fire Rate (Local + Remote Spam birleşik)
----------------------------------------------------------------
--// Durum
local FireRateActive = false
local FireRateHooks  = {namecall=false, index=false, newindex=false, wait=false, heartbeat=false}

--// Arg Patch
local function PatchFireRateArgs(args)
    for i,v in ipairs(args) do
        if type(v) == "number" then
            if v > 0.05 then args[i] = 0 end
        elseif typeof(v) == "table" then
            for k,val in pairs(v) do
                local key = tostring(k):lower()
                if key:find("cooldown") or key:find("delay") or key:find("debounce") or key:find("rate") or key:find("speed") then
                    if type(val) == "number" and val > 0 then
                        v[k] = 0
                    end
                end
            end
        end
    end
    return args
end

--// __namecall Hook
local function HookNamecall()
    if FireRateHooks.namecall then return end
    FireRateHooks.namecall = true

    local old
    old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if FireRateActive 
        and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction"))
        and (method == "FireServer" or method == "InvokeServer") then
            args = PatchFireRateArgs(args)
            return old(self, table.unpack(args))
        end

        return old(self, ...)
    end))
end

--// __index Hook (cooldown değerlerini sıfırla)
local function HookIndex()
    if FireRateHooks.index then return end
    FireRateHooks.index = true

    local old
    old = hookmetamethod(game, "__index", newcclosure(function(self, key)
        if FireRateActive and type(key) == "string" then
            local k = key:lower()
            if k:find("cooldown") or k:find("delay") or k:find("debounce") or k:find("firerate") then
                return 0
            end
        end
        return old(self, key)
    end))
end

--// __newindex Hook (yeni cooldown yazmaya çalışırsa engelle)
local function HookNewIndex()
    if FireRateHooks.newindex then return end
    FireRateHooks.newindex = true

    local old
    old = hookmetamethod(game, "__newindex", newcclosure(function(self, key, val)
        if FireRateActive and type(key) == "string" then
            local k = key:lower()
            if k:find("cooldown") or k:find("delay") or k:find("debounce") or k:find("firerate") then
                val = 0
            end
        end
        return old(self, key, val)
    end))
end

--// wait / task.wait Hook
local function HookWait()
    if FireRateHooks.wait then return end
    FireRateHooks.wait = true

    local old = wait
    getgenv().wait = newcclosure(function(t)
        if FireRateActive then return old(0) end
        return old(t)
    end)

    local taskWait = task.wait
    task.wait = newcclosure(function(t)
        if FireRateActive then return taskWait(0) end
        return taskWait(t)
    end)
end

--// Heartbeat Hook (frame gecikmelerini azalt)
local function HookHeartbeat()
    if FireRateHooks.heartbeat then return end
    FireRateHooks.heartbeat = true

    RunService.Heartbeat:Connect(function()
        if FireRateActive then
            -- burada tick tabanlı delay varsa resetlemiş gibi olur
        end
    end)
end

--// Toggle
function ToggleFireRate(on)
    FireRateActive = (on == true)
    HookNamecall()
    HookIndex()
    HookNewIndex()
    HookWait()
    HookHeartbeat()
    print("[FireRate] "..(FireRateActive and "ON" or "OFF"))
end

----------------------------------------------------------------
-- Kill Aura (15 stud, %100 çalışır)
----------------------------------------------------------------
----------------------------------------------------------------
-- Kill Aura (yakındaki düşmanlara otomatik saldırı + DamageRemote)
----------------------------------------------------------------
--// Durum
local KillAuraActive = false
local KillAuraHooks  = {namecall=false, index=false, newindex=false, wait=false, heartbeat=false}

--// Enemy Seçici
local function getClosestEnemy()
    local closest, dist = nil, math.huge
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            local mag = (hrp.Position - (Player.Character and Player.Character:FindFirstChild("HumanoidRootPart").Position or Vector3.new())).Magnitude
            if mag < dist then
                dist, closest = mag, plr
            end
        end
    end
    return closest
end

--// Patch Args → hedefi kafaya kilitle
local function PatchKillAuraArgs(args, headPos)
    for i,v in ipairs(args) do
        if typeof(v) == "Vector3" then
            args[i] = headPos
        elseif typeof(v) == "CFrame" then
            args[i] = CFrame.new(v.Position, headPos)
        elseif typeof(v) == "table" then
            for k,val in pairs(v) do
                if typeof(val) == "Vector3" then
                    v[k] = headPos
                elseif typeof(val) == "CFrame" then
                    v[k] = CFrame.new(val.Position, headPos)
                end
            end
        end
    end
    return args
end

--// __namecall
local function HookNamecall()
    if KillAuraHooks.namecall then return end
    KillAuraHooks.namecall = true

    local old
    old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if KillAuraActive 
        and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction"))
        and (method == "FireServer" or method == "InvokeServer") then
            local enemy = getClosestEnemy()
            if enemy and enemy.Character and enemy.Character:FindFirstChild("Head") then
                args = PatchKillAuraArgs(args, enemy.Character.Head.Position)
                return old(self, table.unpack(args))
            end
        end
        return old(self, ...)
    end))
end

--// __index / __newindex (cooldownları sıfırla)
local function HookIndex()
    if KillAuraHooks.index then return end
    KillAuraHooks.index = true

    local old
    old = hookmetamethod(game, "__index", newcclosure(function(self, key)
        if KillAuraActive and type(key) == "string" then
            local k = key:lower()
            if k:find("attack") or k:find("cooldown") or k:find("delay") then
                return 0
            end
        end
        return old(self, key)
    end))
end

local function HookNewIndex()
    if KillAuraHooks.newindex then return end
    KillAuraHooks.newindex = true

    local old
    old = hookmetamethod(game, "__newindex", newcclosure(function(self, key, val)
        if KillAuraActive and type(key) == "string" then
            local k = key:lower()
            if k:find("attack") or k:find("cooldown") or k:find("delay") then
                val = 0
            end
        end
        return old(self, key, val)
    end))
end

--// wait / task.wait override
local function HookWait()
    if KillAuraHooks.wait then return end
    KillAuraHooks.wait = true

    local old = wait
    getgenv().wait = newcclosure(function(t)
        if KillAuraActive then return old(0) end
        return old(t)
    end)

    local taskWait = task.wait
    task.wait = newcclosure(function(t)
        if KillAuraActive then return taskWait(0) end
        return taskWait(t)
    end)
end

--// Heartbeat
local function HookHeartbeat()
    if KillAuraHooks.heartbeat then return end
    KillAuraHooks.heartbeat = true

    RunService.Heartbeat:Connect(function()
        if KillAuraActive then
            -- debounce timer reset gibi davranır
        end
    end)
end

--// Toggle
function ToggleKillAura(on)
    KillAuraActive = (on == true)
    HookNamecall()
    HookIndex()
    HookNewIndex()
    HookWait()
    HookHeartbeat()
    print("[KillAura] "..(KillAuraActive and "ON" or "OFF"))
end


----------------------------------------------------------------
-- ESP (join/leave/respawn canlı + NPC + cleanup)
----------------------------------------------------------------


----------------------------------------------------------------
-- NoClip (restore’lu)
----------------------------------------------------------------
function features.ToggleNoclip(on)
    local function setChar(state)
        features._noclipRestore = features._noclipRestore or {}
        local ch = Player.Character
        if not ch then return end
        for _, part in ipairs(ch:GetDescendants()) do
            if part:IsA("BasePart") then
                if state then
                    if features._noclipRestore[part] == nil then
                        features._noclipRestore[part] = part.CanCollide
                    end
                    part.CanCollide = false
                else
                    if features._noclipRestore[part] ~= nil then
                        part.CanCollide = features._noclipRestore[part]
                    else
                        part.CanCollide = true
                    end
                end
            end
        end
    end
    if on then
        if features._noclip then features._noclip:Disconnect() end
        features._noclip = RunService.Stepped:Connect(function() setChar(true) end)
    else
        if features._noclip then features._noclip:Disconnect() end
        setChar(false)
        features._noclipRestore = {}
    end
end

----------------------------------------------------------------
-- Invisible (Local + Remote Attempt)
----------------------------------------------------------------
----------------------------------------------------------------
-- Hard Hook Invisible (Multi-Hook)
----------------------------------------------------------------
-- Invisible Remote (dummy)
function features.ToggleHardInvisible(on)
    InvisibleRemote:FireServer(on) -- server'a isteği gönder

    if on then
        print("[MYLF] Hard Invisible: ON (herkes seni göremeyecek)")
    else
        print("[MYLF] Hard Invisible: OFF (geri görünürsün)")
    end
end
----------------------------------------------------------------
-- AutoTeleportToEnemy (Her zaman düşmanın arkasına)
----------------------------------------------------------------
features._autoBehind = false

function features.ToggleAutoBehind(on)
    if on then
        if features._autoBehindConn then features._autoBehindConn:Disconnect() end

        features._autoBehindConn = RunService.RenderStepped:Connect(function()
            local target = getClosestVisibleHead()
            if target and target.Parent then
                local enemy = target.Parent
                local enemyHRP = enemy:FindFirstChild("HumanoidRootPart")
                local myChar  = Player.Character
                local myHRP   = myChar and myChar:FindFirstChild("HumanoidRootPart")

                if enemyHRP and myHRP then
                    -- Düşmanın baktığı yön
                    local lookVec = enemyHRP.CFrame.LookVector
                    -- Arkasına pozisyon (3 stud arkası + biraz aşağı kaydırma)
                    local behindPos = enemyHRP.Position - lookVec * 3

                    -- Işınlama
                    myHRP.CFrame = CFrame.new(behindPos, enemyHRP.Position)
                end
            end
        end)

        print("AutoTeleportToEnemy (Behind): ON ✅")
    else
        if features._autoBehindConn then
            features._autoBehindConn:Disconnect()
            features._autoBehindConn = nil
        end
        print("AutoTeleportToEnemy (Behind): OFF ❌")
    end
end

----------------------------------------------------------------
-- Headshot Redirect (body → head, wall ignore)
----------------------------------------------------------------
features._headshotRedirect = false

local function PatchBulletArgs(args, headPos)
    for i,v in ipairs(args) do
        if typeof(v) == "Vector3" then
            args[i] = headPos
        elseif typeof(v) == "CFrame" then
            args[i] = CFrame.new(v.Position, headPos)
        elseif typeof(v) == "table" then
            for k,val in pairs(v) do
                local key = tostring(k):lower()
                if key:find("pos") or key:find("hit") or key:find("cf") or key:find("aim") or key:find("target") then
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

local function EnsureBulletHook()
    if features._bulletHook then return end
    features._bulletHook = true

    local old
    old = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args   = {...}

        if (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) 
        and (method == "FireServer" or method == "InvokeServer") then
            if features._headshotRedirect then
                local target = getClosestVisibleHead()
                if target then
                    -- 🧠 Direkt kafaya kitlen
                    return old(self, unpack(PatchBulletArgs(args, target.Position)))
                end
            end
        end
        return old(self, ...)
    end)
end

function features.ToggleHeadshotRedirect(on)
    features._headshotRedirect = not not on
    if on then EnsureBulletHook() end
    print("Headshot Redirect: " .. (on and "ON" or "OFF"))
end
-- Flag
features._multiHook = false

-- Hooklar için eski fonksiyonlar
local oldNamecall, oldIndex, oldNewIndex

-- Argüman Patch
local function PatchArgs(args, headPos)
    for i,v in ipairs(args) do
        local t = typeof(v)
        if t == "Vector3" then
            args[i] = headPos
        elseif t == "CFrame" then
            local cam = workspace.CurrentCamera
            local fakePos = cam.CFrame.Position + cam.CFrame.LookVector * 5
            args[i] = CFrame.new(fakePos, headPos)
        elseif t == "table" then
            for k,val in pairs(v) do
                local key = tostring(k):lower()
                if key:find("pos") or key:find("hit") or key:find("target") then
                    if typeof(val) == "Vector3" then
                        v[k] = headPos
                    elseif typeof(val) == "CFrame" then
                        local cam = workspace.CurrentCamera
                        local fakePos = cam.CFrame.Position + cam.CFrame.LookVector * 5
                        v[k] = CFrame.new(fakePos, headPos)
                    end
                end
            end
        end
    end
    return args
end

-- Toggle Fonksiyonu
function features.ToggleMultiHook(on)
    features._multiHook = not not on

    if on then
        -- __namecall hook
        if not oldNamecall then
            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                local args = {...}
                if features._multiHook 
                and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction"))
                and (method == "FireServer" or method == "InvokeServer") then
                    local head = getClosestVisibleHead()
                    if head then
                        return oldNamecall(self, unpack(PatchArgs(args, head.Position)))
                    end
                end
                return oldNamecall(self, ...)
            end)
        end

        -- __index hook
        if not oldIndex then
            oldIndex = hookmetamethod(game, "__index", function(self, key)
                if features._multiHook and key == "CFrame" then
                    local head = getClosestVisibleHead()
                    if head then
                        return CFrame.new(workspace.CurrentCamera.CFrame.Position, head.Position)
                    end
                end
                return oldIndex(self, key)
            end)
        end

        -- __newindex hook
        if not oldNewIndex then
            oldNewIndex = hookmetamethod(game, "__newindex", function(self, key, val)
                if features._multiHook and key == "CFrame" and typeof(val) == "CFrame" then
                    local head = getClosestVisibleHead()
                    if head then
                        return oldNewIndex(self, key, CFrame.new(val.Position, head.Position))
                    end
                end
                return oldNewIndex(self, key, val)
            end)
        end
    else
        -- kapatınca flag false, hooklar pasifleşir
        features._multiHook = false
    end

    print("Multi-Hook: " .. (on and "ON ✅" or "OFF ❌"))
end
----------------------------------------------------------------
-- Auto Teleport To Enemy (Always Behind / In Front)
----------------------------------------------------------------
----------------------------------------------------------------
-- Auto Teleport To Enemy (Always In Front/Behind)
----------------------------------------------------------------
----------------------------------------------------------------
-- Auto Teleport To Enemy (Always In Front, NO visibility check)
----------------------------------------------------------------
----------------------------------------------------------------
-- Auto Teleport To Enemy (Always In Front, NO visibility check)
----------------------------------------------------------------
features._tpEnemy  = nil
features._tpOffset = Vector3.new(0, 0, 25) -- başlangıç

-- Slider bağlantıları (menu.lua'dan çağırılacak)
features._tpX = 0
features._tpY = 0
features._tpZ = 25

-- Offset ayarlama (slider’lar buna bağlanır)
function features.SetTeleportOffset(x, y, z)
    features._tpX = x
    features._tpY = y
    features._tpZ = z
end

function features.ToggleAutoTeleportToEnemy(on)
    if on then
        if features._tpEnemy then features._tpEnemy:Disconnect() end
        features._tpEnemy = RunService.RenderStepped:Connect(function()
            local head = getClosestVisibleHead() -- görünürlük kontrolünü kaldırmak istersen direkt target seç
            if head and head.Parent then
                local myHRP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                if myHRP then
                    -- her frame güncel offset
                    local look = workspace.CurrentCamera.CFrame.LookVector
                    local offset = look * features._tpZ + Vector3.new(features._tpX, features._tpY, 0)
                    head.Parent:MoveTo(myHRP.Position + offset)
                end
            end
        end)
    else
        if features._tpEnemy then features._tpEnemy:Disconnect(); features._tpEnemy=nil end
    end
end


----------------------------------------------------------------
-- Tiny Hitbox (Hard + Multi-Hook)
----------------------------------------------------------------
local hitParts = {
    "Head","UpperTorso","LowerTorso","HumanoidRootPart",
    "LeftUpperArm","RightUpperArm","LeftUpperLeg","RightUpperLeg"
}
local tinySize = Vector3.new(0.001,0.001,0.001)

function features.ToggleTinyHitbox(on)
    if on then
        -- Namecall hook (Silent Aim + Hitbox patch)
        if not features._tinyHooked then
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                local method = getnamecallmethod()
                local args   = {...}

                if (self:IsA("RemoteEvent") or self:IsA("RemoteFunction"))
                and (method == "FireServer" or method == "InvokeServer") then
                    if features.SilentAim then
                        local head = getClosestVisibleHead()
                        if head then
                            args[1] = head.Position
                            return oldNamecall(self, unpack(args))
                        end
                    end
                end

                return oldNamecall(self, ...)
            end))

            -- __index hook → anti-cheat “Size” sorarsa default ver
            local oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
                if (tostring(key):lower() == "size") and features._tinyActive then
                    return Vector3.new(2,2,1) -- sahte normal değer
                end
                return oldIndex(self, key)
            end))

            -- __newindex hook → oyun size değiştirmeye çalışırsa blockla
            local oldNewIndex = hookmetamethod(game, "__newindex", newcclosure(function(self, key, val)
                if (tostring(key):lower() == "size") and features._tinyActive then
                    return -- block
                end
                return oldNewIndex(self, key, val)
            end))

            features._tinyHooked  = true
            features._tinyActive  = true
            features._tinyOldCall = oldNamecall
            features._tinyOldIdx  = oldIndex
            features._tinyOldNew  = oldNewIndex
        end

        -- Heartbeat → sürekli küçült
        if features._tinyConn then features._tinyConn:Disconnect() end
        features._tinyConn = RunService.Heartbeat:Connect(function()
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= Player and plr.Character then
                    for _, partName in ipairs(hitParts) do
                        local part = plr.Character:FindFirstChild(partName)
                        if part and part:IsA("BasePart") then
                            part.Size = tinySize
                            part.Transparency = 1
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)

        print("🛡️ TinyHitbox HardHook: ON")
    else
        if features._tinyConn then features._tinyConn:Disconnect(); features._tinyConn=nil end
        features._tinyActive = false
        print("🛡️ TinyHitbox HardHook: OFF")
    end
end

----------------------------------------------------------------
-- Enemy Big Hitbox (Hook + Loop)
----------------------------------------------------------------
local hitParts = {
    "Head","UpperTorso","LowerTorso","HumanoidRootPart",
    "LeftUpperArm","RightUpperArm","LeftUpperLeg","RightUpperLeg"
}
local bigSize = Vector3.new(15,15,15) -- devasa hitbox
features._bigHBConn = nil

function features.ToggleEnemyBigHitbox(on)
    if on then
        -- Normal loop
        if features._bigHBConn then features._bigHBConn:Disconnect() end
        features._bigHBConn = RunService.Heartbeat:Connect(function()
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= Player and plr.Team ~= Player.Team and plr.Character then
                    for _, partName in ipairs(hitParts) do
                        local part = plr.Character:FindFirstChild(partName)
                        if part and part:IsA("BasePart") then
                            part.Size = bigSize
                            part.CanCollide = false
                            part.Transparency = 1
                        end
                    end
                end
            end
        end)

        -- Hook → anti-cheat eski boyuta çekerse override et
        if not features._hbHooked then
            local mt = getrawmetatable(game)
            local oldNewIndex = mt.__newindex
            setreadonly(mt, false)
            mt.__newindex = newcclosure(function(self, key, val)
                if tostring(key):lower() == "size" and self:IsA("BasePart") then
                    local char = self.Parent
                    local plr = Players:GetPlayerFromCharacter(char)
                    if plr and plr.Team ~= Player.Team then
                        -- Düşmanın hitbox'unu küçültmeye çalışma → engelle
                        return
                    end
                end
                return oldNewIndex(self, key, val)
            end)
            setreadonly(mt, true)
            features._hbHooked = true
        end

        print("🎯 Enemy Big Hitbox: ON ✅")
    else
        if features._bigHBConn then features._bigHBConn:Disconnect(); features._bigHBConn=nil end
        print("🎯 Enemy Big Hitbox: OFF ❌")
    end
end

----------------------------------------------------------------
-- My Tiny Hitbox (Only LocalPlayer)
----------------------------------------------------------------
features._myTinyHB_on = false

-- Toggle (sade ve düzgün kapanan sürüm)
function features.ToggleMyTinyHitbox(on)
    features._myTinyHB_on = on
    local char = Player.Character
    if char and on then
        for _, partName in ipairs({
            "Head","UpperTorso","LowerTorso","HumanoidRootPart",
            "LeftUpperArm","RightUpperArm","LeftUpperLeg","RightUpperLeg"
        }) do
            local part = char:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                part.Size = Vector3.new(0.001,0.001,0.001)
                part.CanCollide = false
                part.Massless = true
            end
        end
        print("⚡ My Tiny Hitbox: Aktif (sadece sen)")
    else
        print("⚡ My Tiny Hitbox: Pasif")
    end
end

    
---------------------------------------------------
--ESP---------------------------------------------
-- Rainbow renk döngüsü
local function rainbowColor(t)
    local r = math.floor(math.sin(t*2)   *127+128)
    local g = math.floor(math.sin(t*2+2) *127+128)
    local b = math.floor(math.sin(t*2+4) *127+128)
    return Color3.fromRGB(r,g,b)
end

local function addTarget(char)
    if not char:FindFirstChild("HumanoidRootPart") then return end
    features._targets[char] = features._targets[char] or {}
end

for _,plr in ipairs(Players:GetPlayers()) do
    if plr.Character then addTarget(plr.Character) end
    plr.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        addTarget(char)
    end)
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        addTarget(char)
    end)
end)

function features.ToggleSkeleton(on)
    if on and not features._conns.skeleton then
        local t=0
        features._conns.skeleton = RunService.RenderStepped:Connect(function(dt)
            t+=dt
            local col = rainbowColor(t)

            for model,o in pairs(features._targets) do
                local hum = model:FindFirstChildOfClass("Humanoid")
                if not hum then 
                    -- temizle (ölmüş ya da silinmiş)
                    if o.skeleton then
                        for _,seg in ipairs(o.skeleton) do
                            if seg.line then seg.line:Remove() end
                        end
                        o.skeleton = nil
                    end
                    features._targets[model] = nil
                    continue 
                end

                -- çizgiler yoksa oluştur
                if not o.skeleton then
                    o.skeleton = {}
                    local joints
                    if hum.RigType == Enum.HumanoidRigType.R6 then
                        joints = {
                            {"Head","Torso"},
                            {"Torso","Left Arm"},{"Torso","Right Arm"},
                            {"Torso","Left Leg"},{"Torso","Right Leg"},
                        }
                    else -- R15
                        joints = {
                            {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
                            {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
                            {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
                            {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
                            {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
                        }
                    end

                    for _,link in ipairs(joints) do
                        local ln = Drawing.new("Line")
                        ln.Thickness = 2
                        ln.Visible = false
                        table.insert(o.skeleton, {parts=link, line=ln})
                    end
                end

                -- update
                for _,seg in ipairs(o.skeleton) do
                    local p1 = model:FindFirstChild(seg.parts[1], true)
                    local p2 = model:FindFirstChild(seg.parts[2], true)
                    if p1 and p2 then
                        local v1,on1 = Camera:WorldToViewportPoint(p1.Position)
                        local v2,on2 = Camera:WorldToViewportPoint(p2.Position)
                        if on1 and on2 then
                            seg.line.Visible = true
                            seg.line.From   = Vector2.new(v1.X,v1.Y)
                            seg.line.To     = Vector2.new(v2.X,v2.Y)
                            seg.line.Color  = col
                        else
                            seg.line.Visible = false
                        end
                    else
                        seg.line.Visible = false
                    end
                end
            end
        end)
    elseif not on and features._conns.skeleton then
        features._conns.skeleton:Disconnect()
        features._conns.skeleton = nil
        for _,o in pairs(features._targets) do
            if o.skeleton then
                for _,seg in ipairs(o.skeleton) do
                    if seg.line then seg.line:Remove() end
                end
                o.skeleton = nil
            end
        end
    end
end


function features.ToggleBox(on)
    if on and not features._conns.box then
        local t = 0
        features._conns.box = RunService.RenderStepped:Connect(function(dt)
            t += dt
            local col = rainbowColor(t)
            for model,o in pairs(features._targets) do
                if not o.box then
                    local ad = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
                    if ad then
                        local sb = Instance.new("SelectionBox")
                        sb.LineThickness = 0.06
                        sb.SurfaceTransparency = 0.8
                        sb.Adornee = model
                        sb.Parent = ad
                        o.box = sb
                    end
                end
                if o.box then
                    o.box.Visible = true
                    o.box.Color3 = col
                    o.box.SurfaceColor3 = col
                end
            end
        end)
    elseif not on and features._conns.box then
        features._conns.box:Disconnect()
        features._conns.box=nil
        for _,o in pairs(features._targets) do
            if o.box then o.box.Visible=false end
        end
    end
end

function features.ToggleRainbowName(on)
    if on and not features._conns.rainbow then
        local t=0
        features._conns.rainbow = RunService.RenderStepped:Connect(function(dt)
            t+=dt
            local col = rainbowColor(t)

            for model,o in pairs(features._targets) do
                local hum = model:FindFirstChildOfClass("Humanoid")
                if hum and model.Parent then
                    -- Billboard yoksa yeniden ekle
                    if not o.label or not o.label.Parent then
                        local adornee = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
                        if adornee then
                            local bb = Instance.new("BillboardGui")
                            bb.Name = "MYLF_NameESP"
                            bb.Size = UDim2.new(0,100,0,20)
                            bb.StudsOffset = Vector3.new(0,2,0)
                            bb.AlwaysOnTop = true
                            bb.Adornee = adornee

                            local txt = Instance.new("TextLabel")
                            txt.Size = UDim2.new(1,0,1,0)
                            txt.BackgroundTransparency = 1
                            txt.Text = model.Name
                            txt.TextScaled = true
                            txt.Font = Enum.Font.SourceSansBold
                            txt.TextStrokeTransparency = 0
                            txt.TextColor3 = Color3.fromRGB(255,255,255)
                            txt.Parent = bb

                            bb.Parent = adornee
                            o.billboard = bb
                            o.label = txt
                        end
                    end
                    -- Renk güncelle
                    if o.label then
                        o.label.TextColor3 = col
                    end
                end
            end
        end)
    elseif not on and features._conns.rainbow then
        features._conns.rainbow:Disconnect()
        features._conns.rainbow=nil
        for _,o in pairs(features._targets) do
            if o.label then o.label.TextColor3=Color3.fromRGB(255,255,255) end
        end
    end
end


function features.ToggleGlow(on)
    if on and not features._conns.glow then
        local t=0
        features._conns.glow = RunService.RenderStepped:Connect(function(dt)
            t+=dt
            local col = rainbowColor(t)

            for model,o in pairs(features._targets) do
                local hum = model:FindFirstChildOfClass("Humanoid")
                if hum and model.Parent then
                    -- Highlight yoksa ya da silindiyse yeniden ekle
                    if not o.hl or not o.hl.Parent then
                        local hl = Instance.new("Highlight")
                        hl.FillTransparency = 0.5
                        hl.OutlineTransparency = 0 -- dış çizgi de net olsun
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = model      -- ✅ direkt modelin içine
                        o.hl = hl
                    end

                    -- renk güncelle
                    if o.hl then
                        o.hl.Enabled = true
                        o.hl.FillColor = col
                        o.hl.OutlineColor = col
                    end
                end
            end
        end)
    elseif not on and features._conns.glow then
        features._conns.glow:Disconnect()
        features._conns.glow=nil
        for _,o in pairs(features._targets) do
            if o.hl then o.hl.Enabled=false end
        end
    end
end



function features.ToggleTracers(on)
    if on and not features._conns.tracers then
        features._conns.tracers = RunService.RenderStepped:Connect(function(dt)
            features._t = (features._t or 0) + dt
            local col = rainbowColor(features._t)
            local vp = Camera.ViewportSize
            local origin = Vector2.new(vp.X/2, vp.Y)

            for model, o in pairs(features._targets) do
                -- Eğer model silinmişse → tracer'ı yok et
                if not model.Parent then
                    if o.tracer then
                        o.tracer:Remove()
                        o.tracer = nil
                    end
                    features._targets[model] = nil
                    continue
                end

                -- tracer çizgisi yoksa oluştur
                if not o.tracer then
                    o.tracer = Drawing.new("Line")
                    o.tracer.Thickness = 2
                end

                -- güncelle
                local hrp = model:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local v, onScr = Camera:WorldToViewportPoint(hrp.Position)
                    if onScr and v.Z > 0 then
                        o.tracer.Visible = true
                        o.tracer.From    = origin
                        o.tracer.To      = Vector2.new(v.X, v.Y)
                        o.tracer.Color   = col
                    else
                        o.tracer.Visible = false
                    end
                else
                    -- HRP yoksa tracer'i gizle
                    if o.tracer then o.tracer.Visible = false end
                end
            end
        end)

    elseif not on and features._conns.tracers then
        features._conns.tracers:Disconnect()
        features._conns.tracers = nil

        -- tüm kalan tracer'ları sil
        for _, o in pairs(features._targets) do
            if o.tracer then
                o.tracer:Remove()
                o.tracer = nil
            end
        end
    end
end


-- Temizlik: Skeleton + Tracers
local function clearDeadSkeletonAndTracers()
    for model, o in pairs(features._espObjects) do
        if not model.Parent then
            -- Skeleton çizgileri sil
            if o.skeleton then
                for _, seg in ipairs(o.skeleton) do
                    if seg.line then
                        seg.line:Remove() -- Drawing objesini RAM'den tamamen sil
                    end
                end
                o.skeleton = nil
            end

            -- Tracers sil
            if o.tracer then
                o.tracer:Remove()
                o.tracer = nil
            end

            -- Objeyi listeden temizle
            features._espObjects[model] = nil
        end
    end
end


------------------
------------------------
-- == EMOTE PACK FUNCTIONS ==
local function applyCorePack(pack)
    local char = Player.Character or Player.CharacterAdded:Wait()
    local animate = char:FindFirstChild("Animate")
    if not animate then return end
    for slot,id in pairs(pack) do
        local anim = animate:FindFirstChild(slot, true)
        if anim and anim:IsA("Animation") then
            anim.AnimationId = "rbxassetid://"..id
        end
    end
end

-- Tüm Paketler
local Packs = {
    Default = {
        Idle = 507766666,
        WalkAnim = 507777826,
        RunAnim = 507767714,
        JumpAnim = 507765000,
        FallAnim = 507767968,
        ClimbAnim = 507765644,
        Swim = 507784897,
        SwimIdle = 507785072,
        SitAnim = 2506281703
    },
    Zombie = {
        Idle = 616158929,
        WalkAnim = 616168032,
        RunAnim = 616163682,
        JumpAnim = 616161997,
        FallAnim = 616157476,
        ClimbAnim = 616156119
    },
    Ninja = {
        Idle = 656118852,
        WalkAnim = 656121766,
        RunAnim = 913376220,
        JumpAnim = 656117878,
        FallAnim = 656115606,
        ClimbAnim = 656114359
    },
    Elder = {
        Idle = 845397899,
        WalkAnim = 845403856,
        RunAnim = 845386501,
        JumpAnim = 845398858,
        FallAnim = 845396048,
        ClimbAnim = 845392038
    },
    Vampire = {
        Idle = 1083456611,
        WalkAnim = 1083473930,
        RunAnim = 1083462077,
        JumpAnim = 1083455794,
        FallAnim = 1083450166,
        ClimbAnim = 1083443587
    },
    Astronaut = {
        Idle = 891621366,
        WalkAnim = 891633237,
        RunAnim = 891636393,
        JumpAnim = 891627522,
        FallAnim = 891617961,
        ClimbAnim = 891609353
    },
    Pirate = {
        Idle = 750781874,
        WalkAnim = 750785693,
        RunAnim = 750783738,
        JumpAnim = 750782230,
        FallAnim = 750780242,
        ClimbAnim = 750779899
    },
    Superhero = {
        Idle = 619528125,
        WalkAnim = 619529601,
        RunAnim = 619528716,
        JumpAnim = 619528412,
        FallAnim = 619527817,
        ClimbAnim = 619527470,
        SwimAnim = 619529095
    },
    Bubbly = {
        Idle = 910004836,
        WalkAnim = 910034870,
        RunAnim = 910025107,
        JumpAnim = 910016857,
        FallAnim = 910001910,
        ClimbAnim = 910009958
    },
    Mage = {
        Idle = 707742142,
        WalkAnim = 707897309,
        RunAnim = 707861613,
        JumpAnim = 707853694,
        FallAnim = 707829716,
        ClimbAnim = 707826056
    },
    Robot = {
        Idle = 616088211,
        WalkAnim = 616095330,
        RunAnim = 616091570,
        JumpAnim = 616090535,
        FallAnim = 616087089,
        ClimbAnim = 616086996
    },
    Toy = {
        Idle = 782841498,
        WalkAnim = 782843345,
        RunAnim = 782842708,
        JumpAnim = 782847020,
        FallAnim = 782846423,
        ClimbAnim = 782845736
    },
    Werewolf = {
        Idle = 1083195517,
        WalkAnim = 1083178339,
        RunAnim = 1083216690,
        JumpAnim = 1083218792,
        FallAnim = 1083182000,
        ClimbAnim = 1083182000
    },
        Moderation = {
        Idle = 113960239878969,
        WalkAnim = 126516908191316,
        RunAnim = 135431679610889,
        JumpAnim = 99563839802389,
        SwimAnim = 88425531063616,
        ClimbAnim = 110511723808460
    }

}

-- Toggle Fonksiyonları
function features.ToggleDefault(on) if on then applyCorePack(Packs.Default) end end
function features.ToggleZombie(on) if on then applyCorePack(Packs.Zombie) end end
function features.ToggleNinja(on) if on then applyCorePack(Packs.Ninja) end end
function features.ToggleElder(on) if on then applyCorePack(Packs.Elder) end end
function features.ToggleVampire(on) if on then applyCorePack(Packs.Vampire) end end
function features.ToggleAstronaut(on) if on then applyCorePack(Packs.Astronaut) end end
function features.TogglePirate(on) if on then applyCorePack(Packs.Pirate) end end
function features.ToggleSuperhero(on) if on then applyCorePack(Packs.Superhero) end end
function features.ToggleBubbly(on) if on then applyCorePack(Packs.Bubbly) end end
function features.ToggleMage(on) if on then applyCorePack(Packs.Mage) end end
function features.ToggleRobot(on) if on then applyCorePack(Packs.Robot) end end
function features.ToggleToy(on) if on then applyCorePack(Packs.Toy) end end
function features.ToggleWerewolf(on) if on then applyCorePack(Packs.Werewolf) end end
function features.ToggleModeration(on) if on then applyCorePack(Packs.Moderation) end end

------------------------------
------------------------------
return features
