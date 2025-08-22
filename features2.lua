-- ⚡ MYLF | Hub ⚡ — FEATURES (Inspector YOK, Magic Bullet entegre, tek hook)
-- Aimbot: açı tabanlı (mesafeden bağımsız hedef seçimi) + opsiyonel auto-fire
-- ESP: join/leave/respawn canlı, NPC destekli
-- Noclip: restore’lu
-- Fly: LCtrl aşağı
-- Magic Bullet (Fallback): Tool içi remotelere whitelist + tek __namecall hook
-- Silent Aim ile çatışmaz: öncelik Silent Aim > Magic Bullet

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
features.AimRequireLOS   = false    -- true: duvar arkası görmez
features.AimUseFOV       = false    -- true: FOV (açı) sınırı uygular
features.AimMaxAngleDeg  = 360      -- AimUseFOV=true iken
features.AimMaxDistance  = 1800     -- ~500 metre (1 stud ≈ 0.28 m → 500m ≈ 1800 stud)

features.TriggerOnAim    = true     -- hedefteyken otomatik ateş
features.TriggerRate     = 0.12     -- tetikler arası min süre
features._lastTrigger    = 0

----------------------------------------------------------------
-- Hedef seçimi (mesafe önemsiz, açıya göre en iyi düşman)
----------------------------------------------------------------
local function getClosestVisibleHead()
    local cam    = workspace.CurrentCamera
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
                        local angle = math.deg(math.acos(dot)) -- 0° en iyi

                        if (not features.AimUseFOV) or (angle <= (features.AimMaxAngleDeg or 360)) then
                            local ok = true
                            if features.AimRequireLOS then
                                local rayLen = math.min(dist, features.AimMaxDistance or 1e6)
                                local hit = workspace:Raycast(origin, dirUnit * rayLen, rcParams)
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
    -- NOT: Player, RunService ve features zaten globalde var kabul ediliyor.
    local BIG = 1e9  -- math.huge bazı oyunlarda NaN/inf tetikleyebiliyor

    local function applyFor(char)
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            -- MaxHealth'i yukarı sabitle, Health'i doldur, ölümde eklemleri kırma
            if hum.MaxHealth < BIG then hum.MaxHealth = BIG end
            if hum.Health   < BIG then hum.Health   = BIG end
            pcall(function() hum.BreakJointsOnDeath = false end)
        end
    end

    local function start()
        -- Eski bağlantıları temizle (çift bağlanma/kaçak önler)
        if features._god then features._god:Disconnect() features._god = nil end
        if features._god_char then features._god_char:Disconnect() features._god_char = nil end
        if features._god_health then features._god_health:Disconnect() features._god_health = nil end

        -- Mevcut karaktere uygula
        local char = Player.Character or Player.CharacterAdded:Wait()
        applyFor(char)

        -- Her frame’de zorla (server damage resetliyorsa geri doldurur)
        features._god = RunService.Heartbeat:Connect(function()
            local c = Player.Character
            if c then applyFor(c) end
        end)

        -- Respawn olduğunda yeniden kur
        features._god_char = Player.CharacterAdded:Connect(function(newChar)
            -- Humanoid gelene kadar bekle (time-out ile)
            local hum = newChar:WaitForChild("Humanoid", 5)
            if hum then
                task.defer(applyFor, newChar)

                -- Sağlık değişirse anında geri it
                if features._god_health then features._god_health:Disconnect() features._god_health = nil end
                features._god_health = hum.HealthChanged:Connect(function()
                    applyFor(newChar)
                end)
            end
        end)
    end

    if on then
        start()
    else
        -- Tümüyle kapat
        if features._god then features._god:Disconnect() features._god = nil end
        if features._god_char then features._god_char:Disconnect() features._god_char = nil end
        if features._god_health then features._god_health:Disconnect() features._god_health = nil end
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
-- =========================
-- TEK __namecall HOOK
--  - Silent Aim ve Magic Bullet bu hook üstünden çalışır
--  - Öncelik: Silent Aim > Magic Bullet
-- =========================
----------------------------------------------------------------
features._nc_hooked  = false
features._nc_oldcall = nil

-- Magic Bullet yapılandırma
features._mb_on        = false
features._mb_patterns  = { "shoot", "fire", "ray", "bullet", "projectile", "weapon", "hit", "remote" }
features._mb_whitelist = {}  -- [Instance]=true
features._mb_conns     = {}  -- event bağlantıları

local function MB_MatchName(str)
    str = tostring(str):lower()
    for _,p in ipairs(features._mb_patterns) do
        if string.find(str, p) then return true end
    end
    return false
end

local function MB_FindTool()
    local ch = Player.Character
    if ch then
        for _,t in ipairs(ch:GetChildren()) do
            if t:IsA("Tool") then return t end
        end
    end
    local bp = Player:FindFirstChildOfClass("Backpack")
    if bp then
        for _,t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then return t end
        end
    end
    return nil
end

local function MB_ScanTool(tool)
    if not tool then return end
    for _,d in ipairs(tool:GetDescendants()) do
        if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
            if MB_MatchName(d.Name) or MB_MatchName(d:GetFullName()) then
                features._mb_whitelist[d] = true
            end
        end
    end
end

local function MB_RebuildWhitelist()
    features._mb_whitelist = {}
    MB_ScanTool(MB_FindTool())
end

local function MB_DisconnectAll()
    for _,c in ipairs(features._mb_conns) do pcall(function() c:Disconnect() end) end
    features._mb_conns = {}
end

local function MB_AttachWatchers()
    MB_DisconnectAll()
    local ch = Player.Character
    if ch then
        table.insert(features._mb_conns, ch.ChildAdded:Connect(function(obj)
            if features._mb_on and obj:IsA("Tool") then task.defer(MB_RebuildWhitelist) end
        end))
        table.insert(features._mb_conns, ch.ChildRemoved:Connect(function(obj)
            if features._mb_on and obj:IsA("Tool") then task.defer(MB_RebuildWhitelist) end
        end))
    end
    local bp = Player:FindFirstChildOfClass("Backpack")
    if bp then
        table.insert(features._mb_conns, bp.ChildAdded:Connect(function(obj)
            if features._mb_on and obj:IsA("Tool") then task.defer(MB_RebuildWhitelist) end
        end))
        table.insert(features._mb_conns, bp.ChildRemoved:Connect(function(obj)
            if features._mb_on and obj:IsA("Tool") then task.defer(MB_RebuildWhitelist) end
        end))
    end
    table.insert(features._mb_conns, Player.CharacterAdded:Connect(function()
        if not features._mb_on then return end
        task.wait(0.3)
        MB_RebuildWhitelist()
        MB_AttachWatchers()
    end))
end

local function RetargetArgsTo(headPos, args)
    for i=1,#args do
        local a = args[i]
        local t = typeof(a)
        if t == "Vector3" then
            args[i] = headPos
            return args
        elseif t == "CFrame" then
            args[i] = CFrame.new(a.Position, headPos)
            return args
        end
    end
    return args
end

local function EnsureNamecallHook()
    if features._nc_hooked then return end
    features._nc_hooked = true

    local old
    old = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args   = { ... }

        local isRemote = self:IsA("RemoteEvent") or self:IsA("RemoteFunction")
        if isRemote and (method == "FireServer" or method == "InvokeServer") then
            -- Önce Silent Aim
            if features._silent then
                local head = getClosestVisibleHead()
                if head then
                    return old(self, unpack(RetargetArgsTo(head.Position, args)))
                end
            -- Sonra Magic Bullet (fallback)
            elseif features._mb_on then
                local ok = features._mb_whitelist[self] or MB_MatchName(self.Name)
                if ok then
                    local head = getClosestVisibleHead()
                    if head then
                        return old(self, unpack(RetargetArgsTo(head.Position, args)))
                    end
                end
            end
        end

        return old(self, ...)
    end)

    features._nc_oldcall = old
end

----------------------------------------------------------------
-- Silent Aim (yalnızca flag; hook tek)
----------------------------------------------------------------
function features.ToggleSilentAim(on)
    features._silent = not not on
    EnsureNamecallHook()
end

----------------------------------------------------------------
-- Magic Bullet (Fallback) — toggle + yardımcı
----------------------------------------------------------------
function features.ToggleMagicBullet(on)
    features._mb_on = not not on
    EnsureNamecallHook()
    if on then
        MB_RebuildWhitelist()
        MB_AttachWatchers()
    else
        MB_DisconnectAll()
        features._mb_whitelist = {}
    end
end

function features.MagicBulletOnce()
    MB_RebuildWhitelist()
    local head = getClosestVisibleHead()
    if not head then warn("MB Once: enemy yok"); return end
    for rem,_ in pairs(features._mb_whitelist) do
        if rem:IsA("RemoteEvent") then
            pcall(function() rem:FireServer(head.Position) end)
            warn("MB Once: fired @", rem:GetFullName())
            return
        end
    end
    warn("MB Once: uygun remote bulunamadı")
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

        for _,plr in ipairs(Players:GetPlayers()) do
            if plr ~= Player then _espAttachPlayer(plr) end
        end

        table.insert(features._espConns, Players.PlayerAdded:Connect(function(plr)
            if not features._espOn then return end
            _espAttachPlayer(plr)
        end))
        table.insert(features._espConns, Players.PlayerRemoving:Connect(function(plr)
            if plr.Character then _espCleanupChar(plr.Character) end
        end))

        table.insert(features._espConns, workspace.ChildAdded:Connect(function(obj)
            if not features._espOn then return end
            if obj:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
                task.wait(0.2); _espAddForChar(obj, true)
            end
        end))

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

return features
