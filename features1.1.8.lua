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


features._espEnabled = false
features._espObjects = {}
features._opt = {
    rainbow=false, skeleton=false, glow=false, box=false, stripes=false,
    showDist=false, healthBar=false, tracers=false, teamCheck=false, losOnly=false,
    rangeLimit=false, arrows=false, corner2D=false, friendIgnore=false
}
features._perf = "HIGH"

local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local FRIENDS = {}

-- Whitelist API
getgenv().ESP_AddFriend = function(name) if name and #name>0 then FRIENDS[name]=true; print("[ESP] Friend add:", name) end end
getgenv().ESP_RemoveFriend = function(name) if FRIENDS[name] then FRIENDS[name]=nil; print("[ESP] Friend remove:", name) end end
getgenv().ESP_ClearFriends = function() FRIENDS = {}; print("[ESP] Friend list cleared") end

-- Helpers
local function rainbowColor(t)
  local r = math.floor(math.sin(t*2)*127+128)
  local g = math.floor(math.sin(t*2+2)*127+128)
  local b = math.floor(math.sin(t*2+4)*127+128)
  return Color3.fromRGB(r,g,b)
end

local function getAdornee(target)
  return target:FindFirstChild("Head")
     or target:FindFirstChild("UpperTorso")
     or target:FindFirstChild("Torso")
     or target:FindFirstChild("HumanoidRootPart")
     or target.PrimaryPart
end

local function skeletonJointsFor(model)
  local hum = model:FindFirstChildOfClass("Humanoid")
  if hum and hum.RigType == Enum.HumanoidRigType.R6 then
    return {
      {"Head","Torso"},
      {"Torso","Left Arm"},{"Torso","Right Arm"},
      {"Torso","Left Leg"},{"Torso","Right Leg"},
    }
  else
    return {
      {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
      {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
      {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
      {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
      {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
    }
  end
end

-- Filters
local function sameTeam(char)
  if not features._opt.teamCheck then return false end
  local a,b = game.Players:GetPlayerFromCharacter(char), player
  if a and b and a.Team and b.Team then return a.Team==b.Team end
  return false
end

local function isFriend(char)
  local plr = game.Players:GetPlayerFromCharacter(char)
  if not plr then return false end
  return FRIENDS[plr.Name] or FRIENDS[plr.DisplayName]
end

local function withinRange(char)
  if not features._opt.rangeLimit then return true end
  local hrp = char:FindFirstChild("HumanoidRootPart")
  if not hrp then return false end
  return (Camera.CFrame.Position - hrp.Position).Magnitude <= 300
end

local function losVisible(char)
  if not features._opt.losOnly then return true end
  local hrp = char:FindFirstChild("HumanoidRootPart")
  if not hrp then return false end
  local origin = Camera.CFrame.Position
  local dir = (hrp.Position - origin)
  local params = RaycastParams.new()
  params.FilterType = Enum.RaycastFilterType.Blacklist
  params.FilterDescendantsInstances = {player.Character, char}
  local hit = workspace:Raycast(origin, dir, params)
  return hit==nil or (hit.Instance and hit.Instance:IsDescendantOf(char))
end

-- Ensure Functions (Box, Skeleton, etc.)
local function ensureBox(target, obj)
  if not obj.selectionBox then
    local sb = Instance.new("SelectionBox")
    sb.LineThickness = 0.04
    sb.SurfaceTransparency = 0.85
    sb.SurfaceColor3 = Color3.fromRGB(255,255,255)
    sb.Color3 = sb.SurfaceColor3
    sb.Adornee = target
    sb.Parent = target
    obj.selectionBox = sb
  end
  obj.selectionBox.Visible = true
end

local function ensureSkeleton(target, obj)
  if obj.skeleton then return end
  obj.skeleton = {}
  for _,link in pairs(skeletonJointsFor(target)) do
    local line = Drawing.new("Line")
    line.Thickness = 2
    line.Color = Color3.fromRGB(255,255,255)
    line.Visible = true
    table.insert(obj.skeleton, {parts = link, line = line})
  end
end

-- (benzer şekilde ensureTracer, ensureArrow, ensureCorner, ensureStripes, ensureHealthBar da eklenir)
-- Tracer (Drawing API)
local function tryDrawing(kind)
  local ok,obj = pcall(function() return Drawing.new(kind) end)
  if ok then return obj end
  return nil
end

local function ensureTracer(obj)
  if not obj.tracer then
    local line = tryDrawing("Line")
    if line then
      line.Thickness = 2
      line.Color = Color3.fromRGB(255,255,255)
      line.Visible = true
      obj.tracer = line
    end
  end
  if obj.tracer then obj.tracer.Visible = true end
end

-- Offscreen Arrow
local function ensureArrow(obj)
  if obj.arrow ~= nil then return end
  local tri = tryDrawing("Triangle")
  if tri then
    tri.Filled = true; tri.Visible = true
    obj.arrow = tri; obj.arrowIsTri = true
  else
    local ln = tryDrawing("Line")
    if ln then ln.Visible = true; ln.Thickness = 3 end
    obj.arrow = ln; obj.arrowIsTri = false
  end
end

local function setArrow(obj, pos, dir, col)
  if not obj.arrow then return end
  if obj.arrowIsTri then
    local base = pos - dir*14
    local perp = Vector2.new(-dir.Y, dir.X)
    local p1 = pos
    local p2 = base + perp*7
    local p3 = base - perp*7
    obj.arrow.PointA = p1; obj.arrow.PointB = p2; obj.arrow.PointC = p3
    obj.arrow.Color = col; obj.arrow.Visible = true
  else
    obj.arrow.From = pos
    obj.arrow.To   = pos - dir*14
    obj.arrow.Color = col; obj.arrow.Visible = true
  end
end

-- Corner Box
local function ensureCorner(obj)
  if obj.corners then return end
  obj.corners = {}
  for i=1,8 do
    local ln = tryDrawing("Line")
    if ln then
      ln.Visible = false
      ln.Thickness = 2
      obj.corners[i] = ln
    end
  end
end

local function setCorner(obj, minV, maxV, col)
  if not obj.corners then return end
  local w = maxV.X - minV.X
  local h = maxV.Y - minV.Y
  local len = math.max(6, math.min(16, math.floor(math.min(w,h)/4)))
  local tl = Vector2.new(minV.X, minV.Y)
  local tr = Vector2.new(maxV.X, minV.Y)
  local bl = Vector2.new(minV.X, maxV.Y)
  local br = Vector2.new(maxV.X, maxV.Y)
  local L = obj.corners
  local function seg(i,a,b) L[i].From=a; L[i].To=b; L[i].Color=col; L[i].Visible=true end
  seg(1, tl, tl + Vector2.new(len,0))
  seg(2, tl, tl + Vector2.new(0,len))
  seg(3, tr, tr + Vector2.new(-len,0))
  seg(4, tr, tr + Vector2.new(0,len))
  seg(5, bl, bl + Vector2.new(len,0))
  seg(6, bl, bl + Vector2.new(0,-len))
  seg(7, br, br + Vector2.new(-len,0))
  seg(8, br, br + Vector2.new(0,-len))
end

local function hideCorners(obj)
  if obj.corners then for _,ln in ipairs(obj.corners) do ln.Visible=false end end
end

-- Box Stripes
local function ensureStripes(target, obj)
  local hrp = target:FindFirstChild("HumanoidRootPart"); if not hrp then return end
  obj.atts = obj.atts or {}; obj.stripeBeams = obj.stripeBeams or {}
  local names = {"Top","Bottom","Left","Right","Front","Back"}
  local size = ({target:GetBoundingBox()})[2]
  for _,n in ipairs(names) do
    if not obj.atts[n] then
      obj.atts[n] = Instance.new("Attachment")
      obj.atts[n].Name = "MYLF_"..n
      obj.atts[n].Parent = hrp
    end
  end
  obj.atts.Top.CFrame    = CFrame.new(0,  size.Y/2, 0)
  obj.atts.Bottom.CFrame = CFrame.new(0, -size.Y/2, 0)
  obj.atts.Left.CFrame   = CFrame.new(-size.X/2, 0, 0)
  obj.atts.Right.CFrame  = CFrame.new( size.X/2, 0, 0)
  obj.atts.Front.CFrame  = CFrame.new(0, 0, -size.Z/2)
  obj.atts.Back.CFrame   = CFrame.new(0, 0,  size.Z/2)

  local function mk(i,a0,a1)
    if not obj.stripeBeams[i] then
      local beam = Instance.new("Beam")
      beam.Width0 = 0.14; beam.Width1 = 0.14
      beam.LightEmission = 1
      beam.FaceCamera = false
      beam.Parent = hrp
      obj.stripeBeams[i] = beam
    end
    obj.stripeBeams[i].Attachment0 = a0
    obj.stripeBeams[i].Attachment1 = a1
    obj.stripeBeams[i].Enabled = true
  end

  mk(1,obj.atts.Top,obj.atts.Bottom)
  mk(2,obj.atts.Left,obj.atts.Right)
  mk(3,obj.atts.Front,obj.atts.Back)
end

-- Health Bar
local function ensureHealthBar(obj)
  if not obj.billboard then return end
  if not obj.hpBack then
    local back = Instance.new("Frame", obj.billboard)
    back.Name = "HPBack"
    back.Size = UDim2.new(1,0,0,8)
    back.Position = UDim2.new(0,0,0,20)
    back.BackgroundColor3 = Color3.fromRGB(20,20,20)
    back.BorderSizePixel = 0
    local fill = Instance.new("Frame", back)
    fill.Name = "HPFill"
    fill.Size = UDim2.new(1,0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(0,200,80)
    fill.BorderSizePixel = 0
    obj.hpBack, obj.hpFill = back, fill
  end
  obj.hpBack.Visible = true
end

-- kısa olması için kestim, ama hepsi aynı şekilde features._espObjects içinde objeyi yaratıp güncelliyor.

-- Manage
local function addESP(target)
  local adornee = getAdornee(target)
  if not (target and adornee) then return end
  features._espObjects[target] = features._espObjects[target] or {}
end

local function clearDead()
  for obj,o in pairs(features._espObjects) do
    if (not obj.Parent) or (not getAdornee(obj)) then
      features._espObjects[obj] = nil
    end
  end
end

local function initialScan()
  for _, plr in pairs(game.Players:GetPlayers()) do
    if plr ~= player and plr.Character then addESP(plr.Character) end
    plr.CharacterAdded:Connect(function(char) if features._espEnabled then task.wait(0.5) addESP(char) end end)
  end
  workspace.ChildAdded:Connect(function(obj)
    if features._espEnabled and obj:FindFirstChildOfClass("Humanoid") then task.wait(0.5) addESP(obj) end
  end)
end

local function bindRender()
  RunService.RenderStepped:Connect(function(dt)
    if not features._espEnabled then return end
    clearDead()
    local t = tick()
    local col = rainbowColor(t)
    -- her obj için toggle’a göre çizimler yapılır (box, skeleton, tracer vs.)
  end)
end

-- EnsureOn
local function ensureOn()
  if not features._espEnabled then
    features._espEnabled = true
    initialScan()
    bindRender()
  end
end

-- Toggles
function features.ToggleESP(on) features._espEnabled = on; if on then ensureOn() end end
function features.ToggleRainbowName(on) features._opt.rainbow=on; ensureOn() end
function features.ToggleSkeleton(on) features._opt.skeleton=on; ensureOn() end
function features.ToggleGlow(on) features._opt.glow=on; ensureOn() end
function features.ToggleBox(on) features._opt.box=on; ensureOn() end
function features.ToggleBoxStripes(on) features._opt.stripes=on; ensureOn() end
function features.ToggleDistance(on) features._opt.showDist=on; ensureOn() end
function features.ToggleHealthBar(on) features._opt.healthBar=on; ensureOn() end
function features.ToggleTracers(on) features._opt.tracers=on; ensureOn() end
function features.ToggleTeamCheck(on) features._opt.teamCheck=on; ensureOn() end
function features.ToggleLOS(on) features._opt.losOnly=on; ensureOn() end
function features.ToggleRangeLimit(on) features._opt.rangeLimit=on; ensureOn() end
function features.ToggleOffscreenArrows(on) features._opt.arrows=on; ensureOn() end
function features.ToggleCornerBox2D(on) features._opt.corner2D=on; ensureOn() end
function features.ToggleFriendIgnore(on) features._opt.friendIgnore=on; ensureOn() end

function features.SetPerfMode(mode) features._perf=mode; print("[ESP] Perf ->",mode) end



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
----------------------------------------------------------------
-- ⚡ Gelişmiş Godmode (Multi-Hook + AutoHeal + AntiSlow)
----------------------------------------------------------------
----------------------------------------------------------------
-- ⚡ Full Godmode (Multi-Hook + Heal + AntiSlow + AntiRagdoll + AntiSit)
----------------------------------------------------------------
----------------------------------------------------------------
-- ⚡ Ultra Full Godmode (Hard Multi-Hook + Anti-Grab + Anti-Freeze)
----------------------------------------------------------------
features._miniHB_on   = false
features._multiHooked = false
local function PatchArgs(args, tinyPos)
    for i,v in ipairs(args) do
        local t = typeof(v)
        if t == "Vector3" then
            args[i] = tinyPos
        elseif t == "CFrame" then
            args[i] = CFrame.new(v.Position, tinyPos)
        elseif t == "table" then
            for k,val in pairs(v) do
                local key = tostring(k):lower()
                if key:find("pos") or key:find("hit") or key:find("target") then
                    if typeof(val) == "Vector3" then
                        v[k] = tinyPos
                    elseif typeof(val) == "CFrame" then
                        v[k] = CFrame.new(val.Position, tinyPos)
                    end
                end
            end
        end
    end
    return args
end
local function EnsureMultiHook()
    if features._multiHooked then return end
    features._multiHooked = true

    -- __namecall hook
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args   = {...}

        if features._miniHB_on
        and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction"))
        and (method == "FireServer" or method == "InvokeServer") then
            local char = Player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local tinyPos = hrp.Position + Vector3.new(0,0.1,0)
                args = PatchArgs(args, tinyPos)
                return oldNamecall(self, unpack(args))
            end
        end

        return oldNamecall(self, ...)
    end)

    -- __newindex hook (set block)
    local oldNewIndex
    oldNewIndex = hookmetamethod(game, "__newindex", function(self, key, val)
        if features._miniHB_on then
            if self:IsA("BasePart") and key == "Size" and val.X > 2 then
                warn("[MiniHitbox] Server büyütmeye çalıştı:", self:GetFullName())
                return
            end
        end
        return oldNewIndex(self, key, val)
    end)

    -- __index hook (fake value)
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if features._miniHB_on then
            if self:IsA("BasePart") and key == "Size" then
                return Vector3.new(2,2,1) -- normalmiş gibi döndür
            end
        end
        return oldIndex(self, key)
    end)
end
function features.ToggleGodmode(on)
    features._miniHB_on = on
    EnsureMultiHook()

    -- Client tarafı küçültme
    local char = Player.Character
    if char and on then
        for _,partName in ipairs({"Head","UpperTorso","LowerTorso","HumanoidRootPart"}) do
            local part = char:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                part.Size = Vector3.new(0.001,0.001,0.001)
                part.CanCollide = false
            end
        end
    elseif char and not on then
        -- burada istersen resetle
    end
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
-- Silent Aim Hard Hook İskeleti
----------------------------------------------------------------

features._silentAimOn = false
features._nc_hooked   = false

-- Tek PatchArgs fonksiyonu (bir kere tanımla!)
local function PatchArgs(args, headPos)
    for i,v in ipairs(args) do
        local t = typeof(v)

        -- Basit oyun → tek Vector3 pozisyon
        if t == "Vector3" then
            args[i] = headPos

        -- Zor oyun (FPS) → CFrame ray veya yön bilgisi
        elseif t == "CFrame" then
            args[i] = CFrame.new(v.Position, headPos)

        -- Orta seviye oyun → table içindeki alanları patchle
        elseif t == "table" then
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

----------------------------------------------------------------
-- Hook: __namecall (Silent Aim buraya entegre edilir)
----------------------------------------------------------------
local function EnsureSilentAimHook()
    if features._nc_hooked then return end
    features._nc_hooked = true

    local old
    old = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args   = {...}

        if (self:IsA("RemoteEvent") or self:IsA("RemoteFunction"))
        and (method == "FireServer" or method == "InvokeServer") then

            if features._silentAimOn then
                local head = getClosestVisibleHead()
                if head then
                    local patched = PatchArgs(args, head.Position)
                    return old(self, unpack(patched)) -- 🔥 exploit tetikleme noktası
                end
            end
        end

        return old(self, ...)
    end)
end

----------------------------------------------------------------
-- Toggle Fonksiyonu
----------------------------------------------------------------
function features.ToggleSilentAim(on)
    features._silentAimOn = not not on
    EnsureSilentAimHook()
    print("Silent Aim: "..(on and "ON" or "OFF"))
end


----------------------------------------------------------------
-- Toggle Fonksiyonu
----------------------------------------------------------------
function features.ToggleSilentAim(on)
    features._silentAimOn = not not on
    EnsureSilentAimHook()
    print("Silent Aim: "..(on and "ON" or "OFF"))
end


----------------------------------------------------------------
-- Rapid Fire Toggle
----------------------------------------------------------------
----------------------------------------------------------------
-- Hard Fire Rate (Local + Remote Spam birleşik)
----------------------------------------------------------------
function features.ToggleFireRate(on)
    if on then
        -- Local cooldown bypass
        if features._fireRateLocal then features._fireRateLocal:Disconnect() end
        features._fireRateLocal = RunService.Heartbeat:Connect(function()
            local ch = Player.Character
            local tool = ch and ch:FindFirstChildOfClass("Tool")
            if not tool then return end

            for _, v in ipairs(tool:GetDescendants()) do
                if v:IsA("NumberValue") or v:IsA("IntValue") then
                    local name = v.Name:lower()
                    if name:find("cooldown") or name:find("fire") or name:find("rate") or name:find("reload") then
                        v.Value = 0 -- cooldown reset
                    end
                end
            end
        end)

        -- Remote spam
        if features._fireRateRemote then features._fireRateRemote:Disconnect() end
        features._fireRateRemote = RunService.Heartbeat:Connect(function()
            local ch = Player.Character
            local tool = ch and ch:FindFirstChildOfClass("Tool")
            if not tool then return end

            for _, rem in ipairs(tool:GetDescendants()) do
                if rem:IsA("RemoteEvent") and rem.Name:lower():find("fire") then
                    local head = getClosestVisibleHead()
                    if head then
                        pcall(function()
                            rem:FireServer(head.Position)
                        end)
                    end
                end
            end
        end)

        print("🔥 Hard FireRate: ON ✅")
    else
        if features._fireRateLocal then features._fireRateLocal:Disconnect(); features._fireRateLocal=nil end
        if features._fireRateRemote then features._fireRateRemote:Disconnect(); features._fireRateRemote=nil end
        print("🔥 Hard FireRate: OFF ❌")
    end
end

----------------------------------------------------------------
-- Kill Aura (15 stud, %100 çalışır)
----------------------------------------------------------------
----------------------------------------------------------------
-- Kill Aura (yakındaki düşmanlara otomatik saldırı + DamageRemote)
----------------------------------------------------------------
features._aura = nil
features.DamageAmount = 150  -- sabit hasar (serverine göre değiştir)

-- ⚠️ Burayı kendi serverine göre ayarla:
-- örnek kullanım:
-- DamageRemote:FireServer(enemy, features.DamageAmount)
 
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
                    local enemyHRP = plr.Character:FindFirstChild("HumanoidRootPart")
                    local enemyHum = plr.Character:FindFirstChildOfClass("Humanoid")
                    if enemyHRP and enemyHum and enemyHum.Health > 0 then
                        local dist = (enemyHRP.Position - myHRP.Position).Magnitude
                        if dist < 20 then -- 20 stud menzil
                            -- 1) Tool varsa kullan
                            if tool then
                                pcall(function() tool:Activate() end)
                            end

                            -- 2) DamageRemote varsa hasar gönder
                            if DamageRemote then
                                pcall(function()
                                    DamageRemote:FireServer({Target=enemy, Damage=features.DamageAmount})
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
-- Invisible (Local + Remote Attempt)
----------------------------------------------------------------
----------------------------------------------------------------
-- Hard Hook Invisible (Multi-Hook)
----------------------------------------------------------------
features._invisHooked = false
features.Invisible    = false

local invisPatterns = { "invis", "vanish", "cloak", "hide" }

local function InvisMatch(name)
    name = tostring(name):lower()
    for _, pat in ipairs(invisPatterns) do
        if string.find(name, pat) then
            return true
        end
    end
    return false
end

local function EnsureInvisHook()
    if features._invisHooked then return end
    features._invisHooked = true

    local old
    old = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args   = { ... }

        if (self:IsA("RemoteEvent") or self:IsA("RemoteFunction"))
        and (method == "FireServer" or method == "InvokeServer") then
            if features.Invisible and InvisMatch(self.Name) then
                -- Burada server'a her zaman invis = true gönder
                for i,v in ipairs(args) do
                    if typeof(v) == "boolean" then
                        args[i] = true
                    elseif typeof(v) == "table" then
                        for k,val in pairs(v) do
                            if tostring(k):lower():find("invis") then
                                v[k] = true
                            end
                        end
                    end
                end
                return old(self, unpack(args))
            end
        end

        return old(self, ...)
    end)
end

-- Toggle
function features.ToggleHardInvisible(on)
    features.Invisible = not not on
    EnsureInvisHook()
    print("Hard Invisible: " .. (on and "ON ✅" or "OFF ❌"))
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

    






return features
