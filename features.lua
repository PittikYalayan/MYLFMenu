-- ⚡ MYLF | Hub ⚡ — FEATURES (full)
-- Not: Aimbot mesafe bağımsızdır; kameraya göre en küçük açıdaki düşmanı seçer.
--      İstersen otomatik ateş (TriggerOnAim) açık gelir; kapatmak için false yap.

local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Players    = game:GetService("Players")
local Player     = Players.LocalPlayer

local features = {}

----------------------------------------------------------------
-- AIMBOT CONFIG
----------------------------------------------------------------
features.TeamCheck       = true     -- aynı takım hedeflenmez
features.Smoothness      = 1        -- 1 = anında bak; 3-6 = yumuşak
features.AimRequireLOS   = false    -- true: çizgisel görüş şart (duvar arkası yok)
features.AimUseFOV       = false    -- true: ekran içi açı sınırı uygula
features.AimMaxAngleDeg  = 360      -- AimUseFOV=true iken geçerli
features.AimMaxDistance  = 1e9      -- pratikte sınırsız

features.TriggerOnAim    = true     -- hedefteyken otomatik ateş
features.TriggerRate     = 0.12     -- tetikler arası min süre (sn)
features._lastTrigger    = 0        -- iç sayaç

----------------------------------------------------------------
-- Utility: en uygun hedef (mesafe önemsiz, açıya göre)
----------------------------------------------------------------
local function getClosestVisibleHead()
    local cam = workspace.CurrentCamera
    local origin = cam.CFrame.Position
    local look   = cam.CFrame.LookVector

    local bestHead, bestScore = nil, math.huge

    local rcParams = RaycastParams.new()
    rcParams.FilterType = Enum.RaycastFilterType.Blacklist
    rcParams.FilterDescendantsInstances = { Player.Character }

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
                        local angle = math.deg(math.acos(dot)) -- 0° daha iyi

                        if (not features.AimUseFOV) or (angle <= (features.AimMaxAngleDeg or 360)) then
                            local ok = true
                            if features.AimRequireLOS then
                                local hit = workspace:Raycast(origin, dirUnit * dist, rcParams)
                                ok = (hit and hit.Instance and hit.Instance:IsDescendantOf(plr.Character)) or false
                            end
                            if ok and angle < bestScore then
                                bestScore, bestHead = angle, head
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
function features.ToggleSpeed(on)
    local function apply()
        local h = Player.Character and Player.Character:FindFirstChild("Humanoid")
        if h then h.WalkSpeed = on and 50 or 16 end
    end
    if on then
        if features._spd then features._spd:Disconnect() end
        features._spd = RunService.Heartbeat:Connect(apply)
        Player.CharacterAdded:Connect(function() task.wait(0.5); apply() end)
    else
        if features._spd then features._spd:Disconnect() end
        apply()
    end
end

----------------------------------------------------------------
-- Godmode
----------------------------------------------------------------
function features.ToggleGodmode(on)
    local function apply()
        local h = Player.Character and Player.Character:FindFirstChild("Humanoid")
        if h then h.Health, h.MaxHealth = math.huge, math.huge end
    end
    if on then
        if features._god then features._god:Disconnect() end
        features._god = RunService.Heartbeat:Connect(apply)
        Player.CharacterAdded:Connect(function()
            task.wait(0.5)
            if features._god then features._god:Disconnect() end
            features._god = RunService.Heartbeat:Connect(apply)
        end)
    else
        if features._god then features._god:Disconnect() end
    end
end

----------------------------------------------------------------
-- Fly (LeftControl aşağı)
----------------------------------------------------------------
features._flySpeed = 60
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
        Player.CharacterAdded:Connect(function() task.wait(0.5); if on then features.ToggleFly(true) end end)
    else
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then local bv = hrp:FindFirstChildOfClass("BodyVelocity"); if bv then bv:Destroy() end end
        if features._fly then features._fly:Disconnect() end
    end
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
-- AIMBOT (açı tabanlı + opsiyonel otomatik ateş)
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
                if tool then pcall(function() tool:Activate() end); features._lastTrigger = now end
            end
        end
    end
    if on then
        if features._aim then features._aim:Disconnect() end
        features._aim = RunService.RenderStepped:Connect(step)
    else
        if features._aim then features._aim:Disconnect(); features._aim=nil end
    end
end

----------------------------------------------------------------
-- Silent Aim (basit __namecall patch)
----------------------------------------------------------------
function features.ToggleSilentAim(on)
    if on then
        if features._oldNC then return end
        features._silent = true
        features._oldNC = hookmetamethod(game, "__namecall", function(self, ...)
            local m = getnamecallmethod()
            local args = { ... }
            if features._silent and m == "FireServer" then
                local n = tostring(self):lower()
                if n:find("fire") or n:find("shoot") then
                    local head = getClosestVisibleHead()
                    if head then
                        if typeof(args[1])=="Vector3" then args[1]=head.Position
                        elseif typeof(args[2])=="Vector3" then args[2]=head.Position end
                        return features._oldNC(self, unpack(args))
                    end
                end
            end
            return features._oldNC(self, ...)
        end)
    else
        features._silent = false
        if features._oldNC then hookmetamethod(game, "__namecall", features._oldNC); features._oldNC=nil end
    end
end

----------------------------------------------------------------
-- Rapid Fire
----------------------------------------------------------------
function features.ToggleRapidFire(on)
    if on then
        if features._rof then features._rof:Disconnect() end
        features._rof = RunService.Heartbeat:Connect(function()
            local ch = Player.Character; if not ch then return end
            local tool = ch:FindFirstChildOfClass("Tool"); if not tool then return end
            for _,v in ipairs(tool:GetDescendants()) do
                if v:IsA("NumberValue") or v:IsA("IntValue") then
                    local n = v.Name:lower()
                    if n:find("cooldown") or n:find("fire") or n:find("attack") or n:find("reload") or n:find("speed") then
                        v.Value = 0.05
                    end
                end
            end
        end)
    else
        if features._rof then features._rof:Disconnect(); features._rof=nil end
    end
end

----------------------------------------------------------------
-- Kill Aura (15 stud)
----------------------------------------------------------------
function features.ToggleKillAura(on)
    if on then
        if features._aura then features._aura:Disconnect() end
        features._aura = RunService.Heartbeat:Connect(function()
            local ch = Player.Character
            local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
            local tool = ch and ch:FindFirstChildOfClass("Tool")
            if not (hrp and tool) then return end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= Player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    if (plr.Character.HumanoidRootPart.Position - hrp.Position).Magnitude < 15 then
                        tool:Activate()
                    end
                end
            end
        end)
    else
        if features._aura then features._aura:Disconnect(); features._aura=nil end
    end
end

----------------------------------------------------------------
-- ESP (join/leave/respawn canlı + NPC + cleanup)
----------------------------------------------------------------
features._espMap   = {}   -- [char] = {hl, bb, lbl, conns={}}
features._espOn    = false
features._espConns = {}

local function _espCleanupChar(char)
    local o = features._espMap[char]
    if not o then return end
    if o.conns then for _,c in ipairs(o.conns) do pcall(function() c:Disconnect() end) end end
    if o.hl then pcall(function() o.hl:Destroy() end) end
    if o.bb then pcall(function() o.bb:Destroy() end) end
    features._espMap[char] = nil
end

local function _espAddForChar(char, isNPC)
    if not char or not char.Parent then return end
    local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    if not head then return end

    local o = features._espMap[char]
    if not o then o = { conns = {} }; features._espMap[char] = o end

    if not o.hl or not o.hl.Parent then
        local hl = Instance.new("Highlight")
        hl.FillTransparency = 0.5
        hl.OutlineColor = Color3.fromRGB(255,255,255)
        hl.Parent = char
        o.hl = hl
    end

    if not o.bb or not o.bb.Parent then
        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.fromOffset(120, 20)
        bb.AlwaysOnTop = true
        bb.Adornee = head
        bb.Parent = head

        local tl = Instance.new("TextLabel")
        tl.Size = UDim2.fromScale(1,1)
        tl.BackgroundTransparency = 1
        tl.TextScaled = true
        tl.Font = Enum.Font.SourceSansBold
        tl.TextStrokeTransparency = 0.3
        local pl = Players:GetPlayerFromCharacter(char)
        tl.Text = pl and pl.Name or (isNPC and "NPC" or "Enemy")
        tl.Parent = bb

        o.bb, o.lbl = bb, tl
    end

    -- Temizlik bağları
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then table.insert(o.conns, hum.Died:Connect(function() _espCleanupChar(char) end)) end
    table.insert(o.conns, char.AncestryChanged:Connect(function(_, parent)
        if not parent then _espCleanupChar(char) end
    end))
end

local function _espAttachPlayer(plr)
    if plr.Character then _espAddForChar(plr.Character, false) end
    table.insert(features._espConns, plr.CharacterAdded:Connect(function(c)
        task.wait(0.2); if features._espOn then _espAddForChar(c, false) end
    end))
end

function features.ToggleESP(on)
    if on then
        if features._espOn then return end
        features._espOn = true

        -- mevcut oyuncular
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr ~= Player then _espAttachPlayer(plr) end
        end

        -- join/leave
        table.insert(features._espConns, Players.PlayerAdded:Connect(function(plr)
            if not features._espOn then return end
            _espAttachPlayer(plr)
        end))
        table.insert(features._espConns, Players.PlayerRemoving:Connect(function(plr)
            if plr.Character then _espCleanupChar(plr.Character) end
        end))

        -- NPC takibi
        table.insert(features._espConns, workspace.ChildAdded:Connect(function(obj)
            if not features._espOn then return end
            if obj:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
                task.wait(0.2); _espAddForChar(obj, true)
            end
        end))

        -- renk/isim güncelle
        if features._espTick then features._espTick:Disconnect() end
        local t = 0
        features._espTick = RunService.RenderStepped:Connect(function(dt)
            t += dt
            for char, o in pairs(features._espMap) do
                if not char or not char.Parent then _espCleanupChar(char) else
                    if o.lbl then o.lbl.TextColor3 = Color3.fromHSV((t%1),1,1) end
                    if o.hl then
                        local pl = Players:GetPlayerFromCharacter(char)
                        if pl and Player.Team then
                            o.hl.FillColor = (pl.Team == Player.Team) and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
                        else
                            o.hl.FillColor = Color3.fromRGB(160,60,200) -- NPC
                        end
                    end
                end
            end
        end)
    else
        features._espOn = false
        if features._espTick then features._espTick:Disconnect(); features._espTick=nil end
        for _,c in ipairs(features._espConns) do pcall(function() c:Disconnect() end) end
        features._espConns = {}
        for char,_ in pairs(features._espMap) do _espCleanupChar(char) end
        features._espMap = {}
    end
end

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
-- Invisible
----------------------------------------------------------------
function features.ToggleInvisible(on)
    local ch = Player.Character or Player.CharacterAdded:Wait()
    for _, p in ipairs(ch:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            p.Transparency = on and 1 or 0
            if on and p:FindFirstChild("face") then p.face:Destroy() end
        end
    end
end

----------------------------------------------------------------
-- Tool Inspector (placeholder)
----------------------------------------------------------------
function features.ToggleInspector(on)
    warn(on and "Inspector ON" or "Inspector OFF")
end

return features
