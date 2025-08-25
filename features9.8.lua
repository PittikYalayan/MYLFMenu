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



--------------------------------------------------------------------------------
-- ============== ESP STATE / OPTIONS ==========================================
--------------------------------------------------------------------------------
features._espEnabled = false
features._espPerf    = "HIGH"           -- HIGH / MED / LOW (throttle)
features._espObjects = {}   -- [Model] = { highlight=..., billboard=..., label=TextLabel, ... }
features._espConns   = {}   -- bağlantılar (Disconnect için)
features._friends    = {}   -- whitelist

-- ESP seçenekleri (esp.lua ile birebir)
local opt = {
  rainbow     = false,
  skeleton    = false,
  glow        = false,
  box         = false,
  stripes     = false,
  showDist    = false,
  healthBar   = false,
  tracers     = false,
  teamCheck   = false,
  losOnly     = false,
  rangeLimit  = false,
  arrows      = false,
  corner2D    = false,
  friendIgnore= false,
}



-- ===== PUBLIC: Friends / Perf =====
function features.ESP_AddFriend(name) if name and #name>0 then features._friends[name]=true end end
function features.ESP_RemoveFriend(name) if name then features._friends[name]=nil end end
function features.ESP_ClearFriends() features._friends = {} end
function features.SetESPPerf(mode) if mode=="HIGH" or mode=="MED" or mode=="LOW" then features._espPerf = mode end end




-- ===== HELPERS =====
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

-- ===== BUILDERS =====
local function ensureBox(model, o)
  if not o.selectionBox then
    local sb = Instance.new("SelectionBox")
    sb.LineThickness       = 0.04
    sb.SurfaceTransparency = 0.85
    sb.SurfaceColor3       = Color3.fromRGB(255,255,255)
    sb.Color3              = sb.SurfaceColor3
    sb.Adornee             = model
    sb.Parent              = model
    o.selectionBox = sb
  end
  o.selectionBox.Visible = true
end

local function ensureStripes(model, o)
  local hrp = model:FindFirstChild("HumanoidRootPart"); if not hrp then return end
  o.atts = o.atts or {}; o.stripeBeams = o.stripeBeams or {}
  local names={"Top","Bottom","Left","Right","Front","Back"}
  local size=({model:GetBoundingBox()})[2]
  for _,n in ipairs(names) do
    if not o.atts[n] then
      o.atts[n] = Instance.new("Attachment"); o.atts[n].Name="MYLF_"..n; o.atts[n].Parent=hrp
    end
  end
  o.atts.Top.CFrame    = CFrame.new(0,  size.Y/2, 0)
  o.atts.Bottom.CFrame = CFrame.new(0, -size.Y/2, 0)
  o.atts.Left.CFrame   = CFrame.new(-size.X/2, 0, 0)
  o.atts.Right.CFrame  = CFrame.new( size.X/2, 0, 0)
  o.atts.Front.CFrame  = CFrame.new(0, 0, -size.Z/2)
  o.atts.Back.CFrame   = CFrame.new(0, 0,  size.Z/2)
  local function mk(i,a0,a1)
    if not o.stripeBeams[i] then
      local beam = Instance.new("Beam")
      beam.Width0=0.14; beam.Width1=0.14; beam.LightEmission=1; beam.FaceCamera=false; beam.Parent=hrp
      o.stripeBeams[i]=beam
    end
    o.stripeBeams[i].Attachment0=a0; o.stripeBeams[i].Attachment1=a1; o.stripeBeams[i].Enabled=true
  end
  mk(1,o.atts.Top,o.atts.Bottom); mk(2,o.atts.Left,o.atts.Right); mk(3,o.atts.Front,o.atts.Back)
end

local function ensureHealthBar(o)
  if not o.billboard then return end
  if not o.hpBack then
    local back = Instance.new("Frame", o.billboard)
    back.Name="HPBack"; back.Size=UDim2.new(1,0,0,8); back.Position=UDim2.new(0,0,0,20)
    back.BackgroundColor3=Color3.fromRGB(20,20,20); back.BorderSizePixel=0
    local fill = Instance.new("Frame", back)
    fill.Name="HPFill"; fill.Size=UDim2.new(1,0,1,0)
    fill.BackgroundColor3=Color3.fromRGB(0,200,80); fill.BorderSizePixel=0
    o.hpBack, o.hpFill = back, fill
  end
  o.hpBack.Visible = true
end

local function ensureTracer(o)
  if not o.tracer then
    local line = tryDrawing("Line")
    if line then line.Thickness=2; line.Color=Color3.fromRGB(255,255,255); line.Visible=true; o.tracer=line end
  end
  if o.tracer then o.tracer.Visible = true end
end

local function ensureArrow(o)
  if o.arrow ~= nil then return end
  local tri = tryDrawing("Triangle")
  if tri then tri.Filled=true; tri.Visible=true; o.arrow=tri; o.arrowIsTri=true
  else
    local ln = tryDrawing("Line")
    if ln then ln.Visible=true; ln.Thickness=3 end
    o.arrow=ln; o.arrowIsTri=false
  end
end
local function setArrow(o, pos, dir, col)
  if not o.arrow then return end
  if o.arrowIsTri then
    local base = pos - dir*14
    local perp = Vector2.new(-dir.Y, dir.X)
    o.arrow.PointA = pos
    o.arrow.PointB = base + perp*7
    o.arrow.PointC = base - perp*7
    o.arrow.Color = col; o.arrow.Visible=true
  else
    o.arrow.From = pos; o.arrow.To = pos - dir*14; o.arrow.Color=col; o.arrow.Visible=true
  end
end

local function ensureCorner(o)
  if o.corners then return end
  o.corners = {}
  for i=1,8 do
    local ln = tryDrawing("Line")
    if ln then ln.Visible=false; ln.Thickness=2; o.corners[i]=ln end
  end
end
local function setCorner(o, minV, maxV, col)
  if not o.corners then return end
  local w = maxV.X-minV.X; local h = maxV.Y-minV.Y
  local len = math.max(6, math.min(16, math.floor(math.min(w,h)/4)))
  local tl = Vector2.new(minV.X, minV.Y)
  local tr = Vector2.new(maxV.X, minV.Y)
  local bl = Vector2.new(minV.X, maxV.Y)
  local br = Vector2.new(maxV.X, maxV.Y)
  local L=o.corners
  local function seg(i,a,b) L[i].From=a; L[i].To=b; L[i].Color=col; L[i].Visible=true end
  seg(1, tl, tl+Vector2.new(len,0));  seg(2, tl, tl+Vector2.new(0,len))
  seg(3, tr, tr+Vector2.new(-len,0)); seg(4, tr, tr+Vector2.new(0,len))
  seg(5, bl, bl+Vector2.new(len,0));  seg(6, bl, bl+Vector2.new(0,-len))
  seg(7, br, br+Vector2.new(-len,0)); seg(8, br, br+Vector2.new(0,-len))
end
local function hideCorners(o) if o.corners then for _,ln in ipairs(o.corners) do ln.Visible=false end end end

local function ensureSkeleton(model, o)
  if o.skeleton then return end
  o.skeleton = {}
  for _, link in ipairs(skeletonJointsFor(model)) do
    local ln = tryDrawing("Line")
    if ln then ln.Thickness=2; ln.Color=Color3.fromRGB(255,255,255); ln.Visible=true; table.insert(o.skeleton,{parts=link,line=ln}) end
  end
end

-- ===== CORE: addESP / clearDead / scans / render =====
local function addESP(target, isNPC)
  local adornee = getAdornee(target)
  if not (target and adornee) then return end
  local o = features._espObjects[target] or {}; features._espObjects[target]=o

  if not o.highlight or not o.highlight.Parent then
    local hl = Instance.new("Highlight")
    hl.FillTransparency     = 0.5
    hl.OutlineColor         = Color3.fromRGB(255,255,255)
    hl.OutlineTransparency  = 0
    hl.DepthMode            = Enum.HighlightDepthMode.AlwaysOnTop -- görünürlük
    hl.Parent = target
    o.highlight = hl
  end

  if not o.billboard or not o.billboard.Parent then
    local bill = Instance.new("BillboardGui")
    bill.Name="ESP_Name"; bill.Adornee=adornee; bill.Size=UDim2.new(0,140,0,22)
    bill.StudsOffset=Vector3.new(0,2.2,0); bill.AlwaysOnTop=true
    local text = Instance.new("TextLabel", bill)
    text.Size=UDim2.new(1,0,1,0); text.BackgroundTransparency=1
    text.Font=Enum.Font.SourceSansBold; text.TextStrokeTransparency=0; text.TextScaled=true
    local owner = Players:GetPlayerFromCharacter(target)
    text.Text = isNPC and "NPC" or (owner and owner.DisplayName or "Player")
    bill.Parent = adornee
    o.billboard, o.label = bill, text
  end
end

local function clearDead()
  for model, o in pairs(features._espObjects) do
    if (not model.Parent) or (not getAdornee(model)) then
      if o.highlight then pcall(function() o.highlight:Destroy() end) end
      if o.billboard then pcall(function() o.billboard:Destroy() end) end
      if o.skeleton then for _,s in pairs(o.skeleton) do pcall(function() s.line:Remove() end) end end
      if o.tracer then pcall(function() o.tracer:Remove() end) end
      if o.arrow then pcall(function() if o.arrowIsTri then o.arrow.Visible=false else o.arrow:Remove() end end) end
      if o.corners then for _,ln in ipairs(o.corners) do pcall(function() ln:Remove() end) end end
      features._espObjects[model]=nil
    end
  end
end

local function initialScan()
  for _, plr in ipairs(Players:GetPlayers()) do
    if plr~=Player and plr.Character then addESP(plr.Character,false) end
  end
  for _, obj in ipairs(Workspace:GetChildren()) do
    if obj:FindFirstChildOfClass("Humanoid") and getAdornee(obj) and not Players:GetPlayerFromCharacter(obj) then
      addESP(obj,true)
    end
  end
  local bots = Workspace:FindFirstChild("Bots")
  if bots then
    for _, bot in ipairs(bots:GetChildren()) do
      if bot:FindFirstChildOfClass("Humanoid") then addESP(bot,true) end
    end
  end
end

local function bindAutoRefresh()
  -- eski conns off
  for k, c in pairs(features._espConns) do pcall(function() c:Disconnect() end); features._espConns[k]=nil end

  features._espConns.playerAdded = Players.PlayerAdded:Connect(function(plr)
    features._espConns["charAdded_"..plr.UserId] = plr.CharacterAdded:Connect(function(char)
      if features._espEnabled then task.defer(addESP, char, false) end
    end)
  end)

  for _, plr in ipairs(Players:GetPlayers()) do
    features._espConns["charAdded_"..plr.UserId] = plr.CharacterAdded:Connect(function(char)
      if features._espEnabled then task.defer(addESP, char, false) end
    end)
  end

  features._espConns.workspaceAdded = Workspace.ChildAdded:Connect(function(obj)
    if features._espEnabled and obj:FindFirstChildOfClass("Humanoid") and getAdornee(obj) and not Players:GetPlayerFromCharacter(obj) then
      task.defer(addESP, obj, true)
    end
  end)

  local bots = Workspace:FindFirstChild("Bots")
  if bots then
    features._espConns.botsAdded = bots.ChildAdded:Connect(function(bot)
      if features._espEnabled and bot:FindFirstChildOfClass("Humanoid") then task.defer(addESP, bot, true) end
    end)
  end
end

local function worldToScreen(p3)
  local v, on = Camera:WorldToViewportPoint(p3)
  return Vector2.new(v.X, v.Y), on, v.Z
end

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

local _renderConn
local function bindRender()
  if _renderConn then _renderConn:Disconnect(); _renderConn=nil end
  local t, acc = 0, 0
  _renderConn = RunService.RenderStepped:Connect(function(dt)
    if not features._espEnabled then return end

    local step = (features._espPerf=="HIGH" and 0) or (features._espPerf=="MED" and 0.016) or 0.04
    if step>0 then acc += dt; if acc < step then return end; acc = 0 end

    t += dt
    local col = rainbowColor(t)
    local vp  = Camera.ViewportSize
    local center = Vector2.new(vp.X/2, vp.Y/2)
    local bottom = Vector2.new(vp.X/2, vp.Y)
    local margin = 22

    for model, o in pairs(features._espObjects) do
      local alive = model and model.Parent and model:FindFirstChildOfClass("Humanoid")
      local pass  = alive and not sameTeam(model) and not isFriend(model) and withinRange(model) and losVisible(model)

      if pass then
        -- Name (rainbow + distance)
        if o.label then
          local base = o.label.Text
          if opt.showDist then
            local hrp = model:FindFirstChild("HumanoidRootPart")
            if hrp then
              local d = (Camera.CFrame.Position - hrp.Position).Magnitude
              base = base:gsub("%s%[.-%]","")
              base = string.format("%s  [%.0fu]", base, d)
            end
          else
            base = base:gsub("%s%[.-%]","")
          end
          o.label.Text = base
          o.label.TextColor3 = opt.rainbow and col or Color3.fromRGB(255,255,255)
        end

        -- Glow (Highlight)
        if o.highlight then
          if opt.glow or opt.rainbow then
            o.highlight.Enabled = true
            o.highlight.FillColor = col
            o.highlight.OutlineColor = col
          else
            o.highlight.Enabled = false
          end
        end

        -- Health
        if opt.healthBar then
          ensureHealthBar(o)
          local hum = model:FindFirstChildOfClass("Humanoid")
          if hum and o.hpFill then
            local max = (hum.MaxHealth>0 and hum.MaxHealth or 100)
            local ratio = math.clamp(hum.Health/max,0,1)
            o.hpFill.Size = UDim2.new(ratio,0,1,0)
            o.hpFill.BackgroundColor3 = Color3.fromRGB(255*(1-ratio), 255*ratio, 40)
          end
        elseif o.hpBack then
          o.hpBack.Visible=false
        end

        -- Skeleton (Drawing)
        if opt.skeleton then
          ensureSkeleton(model, o)
          if o.skeleton then
            for _, s in pairs(o.skeleton) do
              local p1 = model:FindFirstChild(s.parts[1], true)
              local p2 = model:FindFirstChild(s.parts[2], true)
              if p1 and p2 then
                local v1,on1 = worldToScreen(p1.Position)
                local v2,on2 = worldToScreen(p2.Position)
                if on1 and on2 then
                  s.line.From=v1; s.line.To=v2; s.line.Color=col; s.line.Visible=true
                else
                  s.line.Visible=false
                end
              else
                s.line.Visible=false
              end
            end
          end
        elseif o.skeleton then
          for _, s in pairs(o.skeleton) do s.line.Visible=false end
        end

        -- 3D Box
        if opt.box then
          ensureBox(model, o)
          if o.selectionBox then
            o.selectionBox.Visible=true
            o.selectionBox.Color3=col
            o.selectionBox.SurfaceColor3=col
          end
        elseif o.selectionBox then
          o.selectionBox.Visible=false
        end

        -- Stripes
        if opt.stripes then
          ensureStripes(model, o)
          if o.stripeBeams then
            local seq = ColorSequence.new(col)
            for _, b in pairs(o.stripeBeams) do b.Color=seq; b.Enabled=true end
          end
        elseif o.stripeBeams then
          for _, b in pairs(o.stripeBeams) do b.Enabled=false end
        end

        -- Corner 2D
        if opt.corner2D then
          ensureCorner(o)
          local minV,maxV = modelAABB2D(model)
          if minV and maxV then setCorner(o, minV, maxV, col) else hideCorners(o) end
        else
          hideCorners(o)
        end

        -- Tracers
        if opt.tracers then
          local hrp = model:FindFirstChild("HumanoidRootPart")
          if hrp then
            ensureTracer(o)
            if o.tracer then
              local v,on = Camera:WorldToViewportPoint(hrp.Position)
              if on and v.Z>0 then
                o.tracer.Visible=true
                o.tracer.From = bottom
                o.tracer.To   = Vector2.new(v.X, v.Y)
                o.tracer.Color= col
              else
                o.tracer.Visible=false
              end
            end
          end
        elseif o.tracer then
          o.tracer.Visible=false
        end

        -- Offscreen arrows
        if opt.arrows then
          local hrp = model:FindFirstChild("HumanoidRootPart")
          if hrp then
            ensureArrow(o)
            local v, on, z = Camera:WorldToViewportPoint(hrp.Position)
            local onScreen = on and z>0 and v.X>0 and v.X<vp.X and v.Y>0 and v.Y<vp.Y
            if not onScreen and o.arrow then
              local dir = (Vector2.new(v.X, v.Y) - center)
              if dir.Magnitude < 1e-3 then dir = Vector2.new(1,0) else dir = dir.Unit end
              local sx = (vp.X/2 - margin)/math.abs(dir.X)
              local sy = (vp.Y/2 - margin)/math.abs(dir.Y)
              local scale = math.min(sx, sy)
              local pos = center + dir*scale
              setArrow(o, pos, dir, col)
            else
              o.arrow.Visible=false
            end
          end
        elseif o.arrow then
          o.arrow.Visible=false
        end

      else
        -- filtreye girenleri gizle
        if o.label then o.label.TextColor3 = Color3.fromRGB(255,255,255) end
        if o.highlight then o.highlight.Enabled = false end
        if o.selectionBox then o.selectionBox.Visible=false end
        if o.skeleton then for _, s in pairs(o.skeleton) do s.line.Visible=false end end
        if o.tracer then o.tracer.Visible=false end
        if o.arrow then o.arrow.Visible=false end
        hideCorners(o)
        if o.hpBack then o.hpBack.Visible=false end
      end
    end

    clearDead()
  end)
end

-- ===== PUBLIC START/STOP =====
function features._espStart()
  if features._espEnabled then
    initialScan()
    bindAutoRefresh()
    bindRender()
  end
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
    if o.arrow then pcall(function() if o.arrowIsTri then o.arrow.Visible=false else o.arrow:Remove() end end) end
    if o.corners then for _,ln in ipairs(o.corners) do pcall(function() ln:Remove() end) end end
    if o.selectionBox then pcall(function() o.selectionBox.Visible=false end) end
    if o.hpBack then o.hpBack.Visible=false end
  end
  features._espObjects = {}
end

-- ===== MASTER & ALT TOGGLES =====
function features.ToggleESP(on)
  on = not not on
  if on == features._espEnabled then return end
  features._espEnabled = on
  if on then features._espStart() else features._espStop() end
end

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

-- Manuel refresh (buton istersen)
function features.RefreshESP()
  -- render açık kalır; sahayı temizleyip yeniden tarar
  for _, o in pairs(features._espObjects) do
    if o.highlight then pcall(function() o.highlight:Destroy() end) end
    if o.billboard then pcall(function() o.billboard:Destroy() end) end
    if o.skeleton then for _,s in pairs(o.skeleton) do pcall(function() s.line:Remove() end) end end
    if o.tracer then pcall(function() o.tracer:Remove() end) end
    if o.arrow then pcall(function() if o.arrowIsTri then o.arrow.Visible=false else o.arrow:Remove() end end) end
    if o.corners then for _,ln in ipairs(o.corners) do pcall(function() ln:Remove() end) end end
  end
  features._espObjects = {}
  if features._espEnabled then initialScan() end
end
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
                            part.Transparency = 0.95
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
                            part.Transparency = 0.7
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


return features
