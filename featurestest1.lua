-- ⚡ MYLF | Hub ⚡ — Features (Full Functions Version)
-- Menü bağımlı: Toggles / Options üzerinden kontrol edilir
-- Çoklu hook destekli (Silent Aim + Magic Bullet)

local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Players    = game:GetService("Players")
local Player     = Players.LocalPlayer
local Camera     = workspace.CurrentCamera
local Workspace  = game:GetService("Workspace")

local features = {}
features._lastTrigger = 0

-- Rainbow helper
local function rainbowColor(t)
    local r = math.clamp(math.floor(math.sin(t*2)    *127+128),0,255)
    local g = math.clamp(math.floor(math.sin(t*2 +2) *127+128),0,255)
    local b = math.clamp(math.floor(math.sin(t*2 +4) *127+128),0,255)
    return Color3.fromRGB(r,g,b)
end

-- Simple TeamCheck
local function isEnemy(plr)
    if Toggles.espTeam and Toggles.espTeam.Value then
        return (Player.Team ~= nil and plr.Team ~= nil and Player.Team ~= plr.Team)
    end
    return true
end

----------------------------------------------------------------
-- Aimbot Toggle
----------------------------------------------------------------
function features.ToggleAimbot(on)
    local function step()
        local head = getClosestVisibleHead()
        if not head then return end
        local target = CFrame.new(Camera.CFrame.Position, head.Position)
        local s = tonumber(Options.smoothness.Value) or 1
        Camera.CFrame = (s > 1) and Camera.CFrame:Lerp(target, 1/s) or target

        if Toggles.triggerOnAim.Value then
            local now = tick()
            if (now - features._lastTrigger) >= (Options.triggerRate.Value or 0.12) then
                local tool = Player.Character and Player.Character:FindFirstChildOfClass("Tool")
                if tool then pcall(function() tool:Activate() end) end
                features._lastTrigger = now
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
-- TEK / ÇOKLU HOOK (Silent Aim + Magic Bullet)
-- Universal PatchArgs ile güçlendirilmiş
----------------------------------------------------------------
features._nc_hooked  = false
features._nc_oldcall = nil

-- Silent Aim flag
features.SilentAim   = false

-- Magic Bullet yapılandırma
features._mb_on        = false
features._mb_patterns  = { "shoot","fire","ray","bullet","projectile","weapon","hit","remote" }
features._mb_whitelist = {}  -- [Instance]=true
features._mb_conns     = {}  -- event bağlantıları

----------------------------------------------------------------
-- Magic Bullet Yardımcı
----------------------------------------------------------------
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
    for _,c in ipairs(features._mb_conns) do
        pcall(function() c:Disconnect() end)
    end
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

----------------------------------------------------------------
-- Universal Argüman Patch
----------------------------------------------------------------
local function PatchArgs(args, headPos)
    for i,v in ipairs(args) do
        local t = typeof(v)
        if t == "Vector3" then
            args[i] = headPos
        elseif t == "CFrame" then
            args[i] = CFrame.new(v.Position, headPos)
        elseif t == "table" then
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

----------------------------------------------------------------
-- Çoklu HOOK (hem namecall hem de index / method)
----------------------------------------------------------------
local function EnsureHooks()
    if features._nc_hooked then return end
    features._nc_hooked = true

    local old
    old = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args   = {...}

        if (self:IsA("RemoteEvent") or self:IsA("RemoteFunction"))
        and (method == "FireServer" or method == "InvokeServer") then
            if features.SilentAim then
                local head = getClosestVisibleHead()
                if head then
                    return old(self, unpack(PatchArgs(args, head.Position)))
                end
            elseif features._mb_on then
                local ok = features._mb_whitelist[self] or MB_MatchName(self.Name)
                if ok then
                    local head = getClosestVisibleHead()
                    if head then
                        return old(self, unpack(PatchArgs(args, head.Position)))
                    end
                end
            end
        end
        return old(self, ...)
    end)
    features._nc_oldcall = old

    -- Ekstra index / newindex hook (hard patch)
    local oldIndex, oldNewIndex
    oldIndex = hookmetamethod(game, "__index", function(self, k)
        return oldIndex(self,k)
    end)
    oldNewIndex = hookmetamethod(game, "__newindex", function(self, k, v)
        return oldNewIndex(self,k,v)
    end)
end

----------------------------------------------------------------
-- Silent Aim Toggle
----------------------------------------------------------------
function features.ToggleSilentAim(on)
    features.SilentAim = not not on
    EnsureHooks()
    print("Silent Aim: " .. (on and "ON" or "OFF"))
end

----------------------------------------------------------------
-- Magic Bullet Toggle
----------------------------------------------------------------
function features.ToggleMagicBullet(on)
    features._mb_on = not not on
    EnsureHooks()
    if on then
        MB_RebuildWhitelist()
        MB_AttachWatchers()
    else
        MB_DisconnectAll()
        features._mb_whitelist = {}
    end
    print("Magic Bullet: " .. (on and "ON" or "OFF"))
end
--------------------------------------------------------------------------------
-- ESP CONFIG / STATE
--------------------------------------------------------------------------------
features._espEnabled = false
features._espPerf    = "HIGH"     -- HIGH / MED / LOW
features._espObjects = {}         -- [Model] = { highlight, billboard, label, vb. }
features._espConns   = {}         -- bağlantılar (Disconnect için)
features._friends    = {}         -- whitelist

-- ESP seçenekleri
local opt = {
  rainbow      = false,
  skeleton     = false,
  glow         = false,
  box          = false,
  stripes      = false,
  showDist     = false,
  healthBar    = false,
  tracers      = false,
  teamCheck    = false,
  losOnly      = false,
  rangeLimit   = false,
  arrows       = false,
  corner2D     = false,
  friendIgnore = false,
}

-- === FRIEND MANAGEMENT ===
function features.ESP_AddFriend(name) if name and #name>0 then features._friends[name]=true end end
function features.ESP_RemoveFriend(name) if name then features._friends[name]=nil end end
function features.ESP_ClearFriends() features._friends = {} end

-- === PERF MODE ===
function features.SetESPPerf(mode)
    if mode=="HIGH" or mode=="MED" or mode=="LOW" then features._espPerf = mode end
end

--------------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------------
local function rainbowColor(t)
  local r = math.clamp(math.floor(math.sin(t*2)    *127+128),0,255)
  local g = math.clamp(math.floor(math.sin(t*2 +2) *127+128),0,255)
  local b = math.clamp(math.floor(math.sin(t*2 +4) *127+128),0,255)
  return Color3.fromRGB(r,g,b)
end

local function getAdornee(model)
  if not model then return nil end
  return model:FindFirstChild("Head")
      or model:FindFirstChild("UpperTorso")
      or model:FindFirstChild("Torso")
      or model:FindFirstChild("HumanoidRootPart")
      or model.PrimaryPart
end

local function sameTeam(char)
  if not opt.teamCheck then return false end
  local a,b = Players:GetPlayerFromCharacter(char), Player
  if a and b and a.Team and b.Team then return a.Team==b.Team end
  return false
end

local function isFriend(char)
  if not opt.friendIgnore then return false end
  local plr = Players:GetPlayerFromCharacter(char)
  if not plr then return false end
  return features._friends[plr.Name] or features._friends[plr.DisplayName]
end

local function withinRange(char)
  if not opt.rangeLimit then return true end
  local hrp = char:FindFirstChild("HumanoidRootPart")
  if not hrp then return false end
  return (Camera.CFrame.Position - hrp.Position).Magnitude <= 300
end

local function losVisible(char)
  if not opt.losOnly then return true end
  local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return false end
  local origin = Camera.CFrame.Position
  local dir = (hrp.Position - origin)
  local params = RaycastParams.new()
  params.FilterType = Enum.RaycastFilterType.Blacklist
  params.FilterDescendantsInstances = {Player.Character, char}
  local hit = Workspace:Raycast(origin, dir, params)
  return hit==nil or (hit.Instance and hit.Instance:IsDescendantOf(char))
end

local function tryDrawing(kind)
  local ok, obj = pcall(function() return Drawing.new(kind) end)
  if ok then return obj end
  return nil
end
--------------------------------------------------------------------------------
-- RENDER + TOGGLES
--------------------------------------------------------------------------------
local _renderConn

-- WorldToScreen helper
local function worldToScreen(p3)
  local v, on = Camera:WorldToViewportPoint(p3)
  return Vector2.new(v.X, v.Y), on, v.Z
end

-- Model’in ekran bounding box’ını çıkar
local function modelAABB2D(model)
  local ok, cf, size = pcall(model.GetBoundingBox, model)
  if not ok then return nil end
  local pts={}
  for dx=-0.5,0.5,1 do
    for dy=-0.5,0.5,1 do
      for dz=-0.5,0.5,1 do
        table.insert(pts, (cf * CFrame.new(size.X*dx, size.Y*dy, size.Z*dz)).Position)
      end
    end
  end
  local minV, maxV = Vector2.new(1e9,1e9), Vector2.new(-1e9,-1e9)
  local any=false
  for _,p in ipairs(pts) do
    local s,on = worldToScreen(p)
    if on then
      any=true
      if s.X<minV.X then minV=Vector2.new(s.X,minV.Y) end
      if s.Y<minV.Y then minV=Vector2.new(minV.X,s.Y) end
      if s.X>maxV.X then maxV=Vector2.new(s.X,maxV.Y) end
      if s.Y>maxV.Y then maxV=Vector2.new(maxV.X,s.Y) end
    end
  end
  if not any then return nil end
  return minV, maxV
end

-- Auto refresh (player join/leave, NPC ekleme)
local function bindAutoRefresh()
  for _,c in pairs(features._espConns) do pcall(function() c:Disconnect() end) end
  features._espConns = {}

  features._espConns.playerAdded = Players.PlayerAdded:Connect(function(plr)
    features._espConns["charAdded_"..plr.UserId] = plr.CharacterAdded:Connect(function(char)
      if features._espEnabled then task.defer(addESP, char, false) end
    end)
  end)

  for _,plr in ipairs(Players:GetPlayers()) do
    features._espConns["charAdded_"..plr.UserId] = plr.CharacterAdded:Connect(function(char)
      if features._espEnabled then task.defer(addESP, char, false) end
    end)
  end

  features._espConns.workspaceAdded = Workspace.ChildAdded:Connect(function(obj)
    if features._espEnabled and obj:FindFirstChildOfClass("Humanoid") and getAdornee(obj) and not Players:GetPlayerFromCharacter(obj) then
      task.defer(addESP, obj, true)
    end
  end)
end

-- ESP Start / Stop
function features._espStart()
  features._espEnabled = true
  initialScan()
  bindAutoRefresh()
  bindRender()
end

function features._espStop()
  features._espEnabled = false
  if _renderConn then _renderConn:Disconnect(); _renderConn=nil end
  for _, c in pairs(features._espConns) do pcall(function() c:Disconnect() end) end
  features._espConns = {}
  for _, o in pairs(features._espObjects) do
    if o.highlight then pcall(function() o.highlight:Destroy() end) end
    if o.billboard then pcall(function() o.billboard:Destroy() end) end
    if o.skeleton then for _,s in pairs(o.skeleton) do pcall(function() s.line:Remove() end) end end
    if o.tracer then pcall(function() o.tracer:Remove() end) end
    if o.arrow then pcall(function() o.arrow:Remove() end) end
    if o.corners then for _,ln in pairs(o.corners) do pcall(function() ln:Remove() end) end end
  end
  features._espObjects = {}
end

-- Master toggle
function features.ToggleESP(on)
  if on then features._espStart() else features._espStop() end
end

-- Alt toggle’lar (menu ile çalışacak)
local function guard() return features._espEnabled end

function features.ToggleESPRainbow(on)     if not guard() then return end opt.rainbow      = on end
function features.ToggleESPSkeleton(on)    if not guard() then return end opt.skeleton     = on end
function features.ToggleESPGlow(on)        if not guard() then return end opt.glow         = on end
function features.ToggleESPBox(on)         if not guard() then return end opt.box          = on end
function features.ToggleESPStripes(on)     if not guard() then return end opt.stripes      = on end
function features.ToggleESPDistance(on)    if not guard() then return end opt.showDist     = on end
function features.ToggleESPHealth(on)      if not guard() then return end opt.healthBar    = on end
function features.ToggleESPTracers(on)     if not guard() then return end opt.tracers      = on end
function features.ToggleESPArrows(on)      if not guard() then return end opt.arrows       = on end
function features.ToggleESPCorner(on)      if not guard() then return end opt.corner2D     = on end
function features.ToggleESPTeam(on)        if not guard() then return end opt.teamCheck    = on end
function features.ToggleESPLos(on)         if not guard() then return end opt.losOnly      = on end
function features.ToggleESPRange(on)       if not guard() then return end opt.rangeLimit   = on end
function features.ToggleESPFriends(on)     if not guard() then return end opt.friendIgnore = on end
----------------------------------------------------------------
-- Hedef seçimi (en iyi head bulucu)
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
                local toHead = head.Position - origin
                local dist   = toHead.Magnitude
                if dist <= (features.AimMaxDistance or 1e9) then
                    local dot   = math.clamp(look:Dot(toHead.Unit), -1, 1)
                    local angle = math.deg(math.acos(dot))
                    local hit = workspace:Raycast(origin, toHead, rcParams)
                    if hit and hit.Instance and hit.Instance:IsDescendantOf(plr.Character) then
                        if angle < bestScore then
                            bestScore, bestHead = angle, head
                        end
                    end
                end
            end
        end
    end
    return bestHead
end

----------------------------------------------------------------
-- Aimbot
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
                local tool = Player.Character and Player.Character:FindFirstChildOfClass("Tool")
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
-- Silent Aim + Magic Bullet (Multi-hook)
----------------------------------------------------------------
features._nc_hooks = {}

local function PatchArgs(args, headPos)
    for i,v in ipairs(args) do
        if typeof(v) == "Vector3" then args[i] = headPos
        elseif typeof(v) == "CFrame" then args[i] = CFrame.new(v.Position, headPos)
        elseif typeof(v) == "table" then
            for k,val in pairs(v) do
                local key = tostring(k):lower()
                if key:find("pos") or key:find("hit") then
                    if typeof(val)=="Vector3" then v[k]=headPos end
                end
            end
        end
    end
    return args
end

local function hookSilentAndMagic()
    if features._nc_hooks.main then return end
    local old; old = hookmetamethod(game, "__namecall", function(self, ...)
        local m = getnamecallmethod()
        local args = {...}
        if (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) and (m=="FireServer" or m=="InvokeServer") then
            if features.SilentAim then
                local head=getClosestVisibleHead()
                if head then return old(self, unpack(PatchArgs(args, head.Position))) end
            elseif features._mb_on then
                local head=getClosestVisibleHead()
                if head then return old(self, unpack(PatchArgs(args, head.Position))) end
            end
        end
        return old(self, ...)
    end)
    features._nc_hooks.main = old
end

function features.ToggleSilentAim(on)
    features.SilentAim = not not on
    hookSilentAndMagic()
end

function features.ToggleMagicBullet(on)
    features._mb_on = not not on
    hookSilentAndMagic()
end

----------------------------------------------------------------
-- Rapid Fire
----------------------------------------------------------------
function features.ToggleRapidFire(on)
    if on then
        if features._rof then features._rof:Disconnect() end
        features._rof = RunService.Heartbeat:Connect(function()
            local tool = Player.Character and Player.Character:FindFirstChildOfClass("Tool")
            if not tool then return end
            for _,v in ipairs(tool:GetDescendants()) do
                if v:IsA("NumberValue") or v:IsA("IntValue") then
                    local n = v.Name:lower()
                    if n:find("cooldown") or n:find("fire") then v.Value=0 end
                end
            end
        end)
    else
        if features._rof then features._rof:Disconnect(); features._rof=nil end
    end
end

----------------------------------------------------------------
-- Kill Aura
----------------------------------------------------------------
function features.ToggleKillAura(on)
    if on then
        if features._aura then features._aura:Disconnect() end
        features._aura = RunService.Heartbeat:Connect(function()
            local ch = Player.Character
            local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
            local tool = ch and ch:FindFirstChildOfClass("Tool")
            if not (hrp and tool) then return end
            for _,plr in ipairs(Players:GetPlayers()) do
                if plr~=Player and plr.Character then
                    local enemyHRP=plr.Character:FindFirstChild("HumanoidRootPart")
                    if enemyHRP and (enemyHRP.Position-hrp.Position).Magnitude<15 then
                        pcall(function() tool:Activate() end)
                    end
                end
            end
        end)
    else
        if features._aura then features._aura:Disconnect(); features._aura=nil end
    end
end
----------------------------------------------------------------
-- Speed Hack (50 ↔ 16)
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
        if features._spd then features._spd:Disconnect(); features._spd=nil end
        apply()
    end
end

----------------------------------------------------------------
-- Fly (WASD + Space/LCtrl)
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
            local bv,hrp = ensureBV()
            if not bv then return end
            local dir = Vector3.zero
            local cf = workspace.CurrentCamera.CFrame
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
-- Teleport (T tuşu)
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
-- Godmode
----------------------------------------------------------------
function features.ToggleGodmode(on)
    local BIG = 1e9 -- math.huge yerine bazı oyunlarda güvenli
    local function applyFor(char)
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            if hum.MaxHealth < BIG then hum.MaxHealth = BIG end
            if hum.Health   < BIG then hum.Health   = BIG end
            pcall(function() hum.BreakJointsOnDeath = false end)
        end
    end

    if on then
        if features._god then features._god:Disconnect(); features._god=nil end
        if features._god_char then features._god_char:Disconnect(); features._god_char=nil end
        if features._god_health then features._god_health:Disconnect(); features._god_health=nil end

        local char = Player.Character or Player.CharacterAdded:Wait()
        applyFor(char)

        features._god = RunService.Heartbeat:Connect(function()
            local c = Player.Character
            if c then applyFor(c) end
        end)

        features._god_char = Player.CharacterAdded:Connect(function(newChar)
            task.wait(0.2)
            applyFor(newChar)
            local hum = newChar:FindFirstChildOfClass("Humanoid")
            if hum then
                if features._god_health then features._god_health:Disconnect(); features._god_health=nil end
                features._god_health = hum.HealthChanged:Connect(function()
                    applyFor(newChar)
                end)
            end
        end)
    else
        if features._god then features._god:Disconnect(); features._god=nil end
        if features._god_char then features._god_char:Disconnect(); features._god_char=nil end
        if features._god_health then features._god_health:Disconnect(); features._god_health=nil end
    end
end

----------------------------------------------------------------
-- Invisible (Local + Remote attempt)
----------------------------------------------------------------
function features.ToggleInvisible(on)
    local ch = Player.Character or Player.CharacterAdded:Wait()

    -- 🌙 Local invis (sadece sende görünmez)
    for _, p in ipairs(ch:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            p.Transparency = on and 1 or 0
            if on and p:FindFirstChild("face") then p.face:Destroy() end
        end
    end

    -- 🌐 Server-side (varsa remote tetikle)
    local patterns = { "invis","invisible","vanish","cloak","hide" }
    local function tryRemote(remote)
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer(on)
            elseif remote:IsA("RemoteFunction") then
                remote:InvokeServer(on)
            end
            warn("[Invisible] Remote tetiklendi:", remote:GetFullName())
        end)
    end
    for _, d in ipairs(game:GetDescendants()) do
        if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
            local name = d.Name:lower()
            for _, p in ipairs(patterns) do
                if string.find(name, p) then
                    tryRemote(d)
                end
            end
        end
    end
end
