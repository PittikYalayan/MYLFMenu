-- ✨ GUI Menü Script ✨
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")

-- === Ana GUI ===
local gui = Instance.new("ScreenGui", playerGui)
gui.Name = "MainMenu"
gui.ResetOnSpawn = false

-- === Menü Butonu ===
local menuBtn = Instance.new("TextButton", gui)
menuBtn.Size = UDim2.new(0, 100, 0, 35)
menuBtn.Position = UDim2.new(1, -110, 0, 10)
menuBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 100)
menuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
menuBtn.Font = Enum.Font.SourceSansBold
menuBtn.Text = "☰ Menu"
menuBtn.TextSize = 18

-- === Panel ===
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 280, 0, 0)
frame.Position = UDim2.new(1, -300, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Visible = true
frame.ClipsDescendants = true
Instance.new("UICorner", frame)

-- Aç/Kapa Animasyonu
local panelOpen = false
menuBtn.MouseButton1Click:Connect(function()
    panelOpen = not panelOpen
    local goal = {}
    if panelOpen then
        goal.Size = UDim2.new(0, 280, 0, 680) -- ✨ daha uzun
    else
        goal.Size = UDim2.new(0, 280, 0, 0)
    end
    tweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal):Play()
end)

-- === Layout ===
local layout = Instance.new("UIListLayout", frame)
layout.Padding = UDim.new(0, 6) -- butonlar arası mesafe biraz daha küçük
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- === Genel Buton Yapıcı ===
local function makeButton(name, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35) -- ✨ genişlik tam frame (yanlardan 0 boşluk)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.Text = name
    btn.Parent = frame
    Instance.new("UICorner", btn)
    return btn
end

-- ==============================
-- === Özellikler ===
-- ==============================

-- 👀 ESP (MYLF full pack) – senin menu/makeButton yapına uygun tek blok
-- Özellikler: Rainbow Name, Skeleton (Drawing), Glow, Box, Box Stripes, Distance, Health Bar, Tracers,
--             Team Check, LOS Only, Range 300, ⬅ Offscreen Arrows, ⌞⌝ Corner Box 2D,
--             ⭐ Friend Whitelist, ⚡ Performance (High/Med/Low), ⟲ Refresh

local espBtn      = makeButton("👀 ESP OFF",            Color3.fromRGB(80,180,200))
local rainbowBtn  = makeButton("🌈 Rainbow Name OFF",   Color3.fromRGB(200,140,80))
local skeletonBtn = makeButton("🦴 Skeleton OFF",       Color3.fromRGB(150,100,200))
local glowBtn     = makeButton("✨ Glow (Rainbow) OFF", Color3.fromRGB(200,80,150))
local boxBtn      = makeButton("▣ Box OFF",             Color3.fromRGB(120,160,200))
local stripesBtn  = makeButton("≡ Box Stripes OFF",     Color3.fromRGB(120,120,120))
local distBtn     = makeButton("📏 Distance OFF",       Color3.fromRGB(100,140,200))
local hpBtn       = makeButton("❤️ Health Bar OFF",     Color3.fromRGB(200,100,100))
local tracerBtn   = makeButton("〽 Tracers OFF",        Color3.fromRGB(160,160,160))
local teamBtn     = makeButton("👥 Team Check OFF",     Color3.fromRGB(120,120,200))
local losBtn      = makeButton("🔭 LOS Only OFF",       Color3.fromRGB(120,120,160))
local rangeBtn    = makeButton("📡 Range Limit OFF",    Color3.fromRGB(120,160,120))
-- yeni
local arrowBtn    = makeButton("⬅ Offscreen Arrows OFF",Color3.fromRGB(140,140,140))
local cornerBtn   = makeButton("⌞⌝ Corner Box OFF",     Color3.fromRGB(120,140,160))
local perfBtn     = makeButton("⚡ Perf: HIGH",          Color3.fromRGB(80,180,120))
local refreshBtn  = makeButton("⟲ Refresh",             Color3.fromRGB(120,120,120))
local friendBtn   = makeButton("⭐ Friend Ignore OFF",    Color3.fromRGB(140,120,120))

local espEnabled = false
local opt = {
  rainbow=false, skeleton=false, glow=false, box=false, stripes=false,
  showDist=false, healthBar=false, tracers=false, teamCheck=false, losOnly=false, rangeLimit=false,
  arrows=false, corner2D=false,
}
local perf = "HIGH"   -- HIGH/MED/LOW (update periyodu)
local updateStep = 0  -- dinamik throttle

local espObjects = {}
local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local renderConn, plrAddedConns = nil, {}
local FRIENDS = {}    -- whitelist (ad -> true)

-- Whitelist helper'ları (konsoldan çağır: ESP_AddFriend("nick"))
getgenv().ESP_AddFriend = function(name) if name and #name>0 then FRIENDS[name]=true; print("[ESP] Friend add:", name) end end
getgenv().ESP_RemoveFriend = function(name) if FRIENDS[name] then FRIENDS[name]=nil; print("[ESP] Friend remove:", name) end end
getgenv().ESP_ClearFriends = function() FRIENDS = {}; print("[ESP] Friend list cleared") end

-- Renk döngüsü
local function rainbowColor(t)
  local r = math.clamp(math.floor(math.sin(t*2)*127+128),0,255)
  local g = math.clamp(math.floor(math.sin(t*2+2)*127+128),0,255)
  local b = math.clamp(math.floor(math.sin(t*2+4)*127+128),0,255)
  return Color3.fromRGB(r,g,b)
end

-- Adornee bulucu
local function getAdornee(target)
  return target:FindFirstChild("Head")
     or target:FindFirstChild("UpperTorso")
     or target:FindFirstChild("Torso")
     or target:FindFirstChild("HumanoidRootPart")
     or target.PrimaryPart
end

-- R6/R15 skeleton seçimi
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

-- Filtreler
local function sameTeam(char)
  if not opt.teamCheck then return false end
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
  if not opt.rangeLimit then return true end
  local hrp = char:FindFirstChild("HumanoidRootPart")
  if not hrp then return false end
  return (Camera.CFrame.Position - hrp.Position).Magnitude <= 300
end
local function losVisible(char)
  if not opt.losOnly then return true end
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

-- BOX
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

-- STRIPES (3 Beam HRP üzerinden)
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

-- HEALTH BAR (billboard altına)
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

-- Tracer (Drawing)
local function tryDrawing(kind)
  local ok, obj = pcall(function() return Drawing.new(kind) end)
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

-- Offscreen Arrow (Triangle fallback Line)
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
    obj.arrow.To = pos - dir*14
    obj.arrow.Color = col; obj.arrow.Visible = true
  end
end

-- Corner Box (8 çizgi)
local function ensureCorner(obj)
  if obj.corners then return end
  obj.corners = {}
  for i=1,8 do
    local ln = tryDrawing("Line")
    if ln then
      ln.Visible = false; ln.Thickness = 2
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

-- Skeleton (Drawing)
local function ensureSkeleton(target, obj)
  if obj.skeleton then return end
  obj.skeleton = {}
  for _,link in pairs(skeletonJointsFor(target)) do
    local line = tryDrawing("Line")
    if line then
      line.Thickness = 2
      line.Color = Color3.fromRGB(255,255,255)
      line.Visible = true
      table.insert(obj.skeleton, {parts = link, line = line})
    end
  end
end

-- ESP (Highlight + Name Billboard)
local function addESP(target, isNPC)
  local adornee = getAdornee(target)
  if not (target and adornee) then return end
  espObjects[target] = espObjects[target] or {}
  local obj = espObjects[target]

  if not obj.highlight or not obj.highlight.Parent then
    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255,255,255)
    highlight.Parent = target
    obj.highlight = highlight
  end

  if not obj.billboard or not obj.billboard.Parent then
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Name"
    billboard.Adornee = adornee
    billboard.Size = UDim2.new(0,140,0,22)
    billboard.StudsOffset = Vector3.new(0, 2.2, 0)
    billboard.AlwaysOnTop = true

    local text = Instance.new("TextLabel", billboard)
    text.Size = UDim2.new(1,0,1,0)
    text.BackgroundTransparency = 1
    text.Font = Enum.Font.SourceSansBold
    text.TextStrokeTransparency = 0
    text.TextScaled = true
    local owner = game.Players:GetPlayerFromCharacter(target)
    text.Text = isNPC and "NPC" or (owner and owner.DisplayName or "Player")

    billboard.Parent = adornee
    obj.billboard = billboard
    obj.label = text
  end
end

-- Temizlik
local function clearDead()
  for obj, o in pairs(espObjects) do
    if (not obj.Parent) or (not getAdornee(obj)) then
      if o.highlight then pcall(function() o.highlight:Destroy() end) end
      if o.billboard then pcall(function() o.billboard:Destroy() end) end
      if o.skeleton then for _, s in pairs(o.skeleton) do pcall(function() s.line:Remove() end) end end
      if o.tracer then pcall(function() o.tracer:Remove() end) end
      if o.arrow then pcall(function() if o.arrowIsTri then o.arrow.Visible=false else o.arrow:Remove() end end) end
      if o.corners then for _,ln in ipairs(o.corners) do pcall(function() ln:Remove() end) end end
      espObjects[obj] = nil
    end
  end
end

-- İlk tarama
local function initialScan()
  for _, plr in pairs(game.Players:GetPlayers()) do
    if plr ~= player and plr.Character then addESP(plr.Character, false) end
    if not plrAddedConns[plr] then
      plrAddedConns[plr] = plr.CharacterAdded:Connect(function(char)
        if espEnabled then task.wait(0.5) addESP(char, false) end
      end)
    end
  end
  for _, obj in pairs(workspace:GetChildren()) do
    if obj:FindFirstChildOfClass("Humanoid") and getAdornee(obj) and not game.Players:GetPlayerFromCharacter(obj) then
      addESP(obj, true)
    end
  end
  local bots = workspace:FindFirstChild("Bots")
  if bots then
    for _, bot in pairs(bots:GetChildren()) do
      if bot:FindFirstChildOfClass("Humanoid") then addESP(bot, true) end
    end
    bots.ChildAdded:Connect(function(bot)
      if espEnabled and bot:FindFirstChildOfClass("Humanoid") then task.wait(0.5) addESP(bot, true) end
    end)
  end
  workspace.ChildAdded:Connect(function(obj)
    if espEnabled and obj:FindFirstChildOfClass("Humanoid") and getAdornee(obj) and not game.Players:GetPlayerFromCharacter(obj) then
      task.wait(0.5) addESP(obj, true)
    end
  end)
end

-- Viewport helper’ları
local function worldToScreen(v3)
  local v, on = Camera:WorldToViewportPoint(v3)
  return Vector2.new(v.X, v.Y), on, v.Z
end
local function modelAABB2D(model)
  local ok, cf, size = pcall(model.GetBoundingBox, model)
  if not ok then return nil end
  local pts = {}
  for dx=-0.5,0.5,1 do
    for dy=-0.5,0.5,1 do
      for dz=-0.5,0.5,1 do
        local world = (cf * CFrame.new(size.X*dx, size.Y*dy, size.Z*dz)).Position
        table.insert(pts, world)
      end
    end
  end
  local minV, maxV = Vector2.new(1e9,1e9), Vector2.new(-1e9,-1e9)
  local any = false
  for _,p in ipairs(pts) do
    local s, on = worldToScreen(p)
    if on then
      any = true
      if s.X < minV.X then minV = Vector2.new(s.X, minV.Y) end
      if s.Y < minV.Y then minV = Vector2.new(minV.X, s.Y) end
      if s.X > maxV.X then maxV = Vector2.new(s.X, maxV.Y) end
      if s.Y > maxV.Y then maxV = Vector2.new(maxV.X, s.Y) end
    end
  end
  if not any then return nil end
  return minV, maxV
end

-- Render loop
local function bindRender()
  if renderConn then renderConn:Disconnect() end
  local t, acc = 0, 0
  renderConn = RunService.RenderStepped:Connect(function(dt)
    if not espEnabled then return end

    -- perf throttle
    local step = (perf=="HIGH" and 0) or (perf=="MED" and 0.016) or 0.04
    if step>0 then
      acc = acc + dt
      if acc < step then return end
      acc = 0
    end

    t = t + dt
    local col = rainbowColor(t)
    local vp = Camera.ViewportSize
    local center = Vector2.new(vp.X/2, vp.Y/2)
    local margin = 22

    for obj, o in pairs(espObjects) do
      local valid = obj and obj.Parent and not sameTeam(obj) and not (opt.teamCheck and isFriend(obj)) and withinRange(obj) and losVisible(obj)
      if valid then
        -- Label + Distance + Rainbow
        if o.label then
          local base = o.label.Text
          if opt.showDist then
            local hrp = obj:FindFirstChild("HumanoidRootPart")
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

        -- Highlight
        if o.highlight then
          if opt.glow or opt.rainbow then
            o.highlight.Enabled = true
            o.highlight.FillColor = col
            o.highlight.OutlineColor = col
          else
            o.highlight.Enabled = false
          end
        end

        -- Health Bar
        if opt.healthBar then
          ensureHealthBar(o)
          local hum = obj:FindFirstChildOfClass("Humanoid")
          if hum and o.hpFill then
            local max = hum.MaxHealth>0 and hum.MaxHealth or 100
            local ratio = math.clamp(hum.Health/max,0,1)
            o.hpFill.Size = UDim2.new(ratio,0,1,0)
            o.hpFill.BackgroundColor3 = Color3.fromRGB(255*(1-ratio), 255*ratio, 40)
          end
        elseif o.hpBack then
          o.hpBack.Visible = false
        end

        -- Skeleton
        if opt.skeleton then
          ensureSkeleton(obj, o)
          if o.skeleton then
            for _, s in pairs(o.skeleton) do
              local p1 = obj:FindFirstChild(s.parts[1], true)
              local p2 = obj:FindFirstChild(s.parts[2], true)
              if p1 and p2 then
                local v1, on1 = worldToScreen(p1.Position)
                local v2, on2 = worldToScreen(p2.Position)
                if on1 and on2 then
                  s.line.From = v1; s.line.To = v2
                  s.line.Color = col; s.line.Visible = true
                else
                  s.line.Visible = false
                end
              else
                s.line.Visible = false
              end
            end
          end
        elseif o.skeleton then
          for _, s in pairs(o.skeleton) do s.line.Visible=false end
        end

        -- Box 3D
        if opt.box then
          ensureBox(obj, o)
          if o.selectionBox then
            o.selectionBox.Visible = true
            o.selectionBox.Color3 = col
            o.selectionBox.SurfaceColor3 = col
          end
        elseif o.selectionBox then
          o.selectionBox.Visible = false
        end

        -- Stripes
        if opt.stripes then
          ensureStripes(obj, o)
          if o.stripeBeams then
            local seq = ColorSequence.new(col)
            for _,b in pairs(o.stripeBeams) do b.Color=seq; b.Enabled=true end
          end
        elseif o.stripeBeams then
          for _,b in pairs(o.stripeBeams) do b.Enabled=false end
        end

        -- Corner Box 2D
        if opt.corner2D then
          ensureCorner(o)
          local minV, maxV = modelAABB2D(obj)
          if minV and maxV then
            setCorner(o, minV, maxV, col)
          else
            hideCorners(o)
          end
        else
          hideCorners(o)
        end

        -- Tracers
        if opt.tracers then
          local hrp = obj:FindFirstChild("HumanoidRootPart")
          if hrp then
            ensureTracer(o)
            if o.tracer then
              local v, on = Camera:WorldToViewportPoint(hrp.Position)
              if on and v.Z>0 then
                o.tracer.Visible = true
                o.tracer.From = Vector2.new(center.X, vp.Y)  -- alt orta
                o.tracer.To = Vector2.new(v.X, v.Y)
                o.tracer.Color = col
              else
                o.tracer.Visible = false
              end
            end
          end
        elseif o.tracer then
          o.tracer.Visible = false
        end

        -- Offscreen Arrows
        if opt.arrows then
          local hrp = obj:FindFirstChild("HumanoidRootPart")
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
            elseif o.arrow then
              if o.arrowIsTri then o.arrow.Visible=false else o.arrow.Visible=false end
            end
          end
        elseif o.arrow then
          if o.arrowIsTri then o.arrow.Visible=false else o.arrow.Visible=false end
        end

      else
        -- filtreye takılan hedefi gizle
        if o.label then o.label.TextColor3 = Color3.fromRGB(255,255,255) end
        if o.highlight then o.highlight.Enabled = false end
        if o.selectionBox then o.selectionBox.Visible = false end
        if o.skeleton then for _, s in pairs(o.skeleton) do s.line.Visible = false end end
        if o.tracer then o.tracer.Visible = false end
        if o.arrow then if o.arrowIsTri then o.arrow.Visible=false else o.arrow.Visible=false end end
        hideCorners(o)
        if o.hpBack then o.hpBack.Visible = false end
      end
    end
    clearDead()
  end)
end

-- Toggle’lar (ESP auto ON)
local function ensureOn()
  if not espEnabled then
    espEnabled = true
    espBtn.Text = "👀 ESP ON"
    espBtn.BackgroundColor3 = Color3.fromRGB(0,200,100)
    initialScan()
    bindRender()
  end
end

espBtn.MouseButton1Click:Connect(function()
  espEnabled = not espEnabled
  if espEnabled then
    espBtn.Text = "👀 ESP ON"
    espBtn.BackgroundColor3 = Color3.fromRGB(0,200,100)
    initialScan()
    bindRender()
  else
    espBtn.Text = "👀 ESP OFF"
    espBtn.BackgroundColor3 = Color3.fromRGB(80,180,200)
    if renderConn then renderConn:Disconnect() renderConn=nil end
    for _, o in pairs(espObjects) do
      if o.highlight then pcall(function() o.highlight:Destroy() end) end
      if o.billboard then pcall(function() o.billboard:Destroy() end) end
      if o.skeleton then for _, s in pairs(o.skeleton) do pcall(function() s.line:Remove() end) end end
      if o.tracer then pcall(function() o.tracer:Remove() end) end
      if o.arrow then pcall(function() if o.arrowIsTri then o.arrow.Visible=false else o.arrow:Remove() end end) end
      if o.corners then for _,ln in ipairs(o.corners) do pcall(function() ln:Remove() end) end end
      if o.selectionBox then pcall(function() o.selectionBox.Visible=false end) end
      if o.hpBack then o.hpBack.Visible=false end
    end
    espObjects = {}
  end
end)

local function setToggle(btn, flag, onText, offText, onCol, offCol)
  opt[flag] = not opt[flag]; ensureOn()
  btn.Text = opt[flag] and onText or offText
  btn.BackgroundColor3 = opt[flag] and onCol or offCol
end

rainbowBtn.MouseButton1Click:Connect(function()
  setToggle(rainbowBtn, "rainbow", "🌈 Rainbow Name ON", "🌈 Rainbow Name OFF",
            Color3.fromRGB(0,200,120), Color3.fromRGB(200,140,80))
end)
skeletonBtn.MouseButton1Click:Connect(function()
  setToggle(skeletonBtn, "skeleton", "🦴 Skeleton ON", "🦴 Skeleton OFF",
            Color3.fromRGB(0,200,120), Color3.fromRGB(150,100,200))
end)
glowBtn.MouseButton1Click:Connect(function()
  setToggle(glowBtn, "glow", "✨ Glow (Rainbow) ON", "✨ Glow (Rainbow) OFF",
            Color3.fromRGB(0,200,120), Color3.fromRGB(200,80,150))
end)
boxBtn.MouseButton1Click:Connect(function()
  setToggle(boxBtn, "box", "▣ Box ON", "▣ Box OFF",
            Color3.fromRGB(0,200,120), Color3.fromRGB(120,160,200))
end)
stripesBtn.MouseButton1Click:Connect(function()
  setToggle(stripesBtn, "stripes", "≡ Box Stripes ON", "≡ Box Stripes OFF",
            Color3.fromRGB(0,200,120), Color3.fromRGB(120,120,120))
end)
distBtn.MouseButton1Click:Connect(function()
  setToggle(distBtn, "showDist", "📏 Distance ON", "📏 Distance OFF",
            Color3.fromRGB(0,200,120), Color3.fromRGB(100,140,200))
end)
hpBtn.MouseButton1Click:Connect(function()
  setToggle(hpBtn, "healthBar", "❤️ Health Bar ON", "❤️ Health Bar OFF",
            Color3.fromRGB(0,200,120), Color3.fromRGB(200,100,100))
end)
tracerBtn.MouseButton1Click:Connect(function()
  setToggle(tracerBtn, "tracers", "〽 Tracers ON", "〽 Tracers OFF",
            Color3.fromRGB(0,200,120), Color3.fromRGB(160,160,160))
end)
teamBtn.MouseButton1Click:Connect(function()
  setToggle(teamBtn, "teamCheck", "👥 Team Check ON", "👥 Team Check OFF",
            Color3.fromRGB(0,200,120), Color3.fromRGB(120,120,200))
end)
losBtn.MouseButton1Click:Connect(function()
  setToggle(losBtn, "losOnly", "🔭 LOS Only ON", "🔭 LOS Only OFF",
            Color3.fromRGB(0,200,120), Color3.fromRGB(120,120,160))
end)
rangeBtn.MouseButton1Click:Connect(function()
  setToggle(rangeBtn, "rangeLimit", "📡 Range Limit 300 ON", "📡 Range Limit OFF",
            Color3.fromRGB(0,200,120), Color3.fromRGB(120,160,120))
end)
arrowBtn.MouseButton1Click:Connect(function()
  setToggle(arrowBtn, "arrows", "⬅ Offscreen Arrows ON", "⬅ Offscreen Arrows OFF",
            Color3.fromRGB(0,200,120), Color3.fromRGB(140,140,140))
end)
cornerBtn.MouseButton1Click:Connect(function()
  setToggle(cornerBtn, "corner2D", "⌞⌝ Corner Box ON", "⌞⌝ Corner Box OFF",
            Color3.fromRGB(0,200,120), Color3.fromRGB(120,140,160))
end)
friendBtn.MouseButton1Click:Connect(function()
  opt.friendIgnore = not opt.friendIgnore; ensureOn()
  friendBtn.Text = opt.friendIgnore and "⭐ Friend Ignore ON" or "⭐ Friend Ignore OFF"
  friendBtn.BackgroundColor3 = opt.friendIgnore and Color3.fromRGB(0,200,120) or Color3.fromRGB(140,120,120)
end)

perfBtn.MouseButton1Click:Connect(function()
  if perf=="HIGH" then perf="MED"
  elseif perf=="MED" then perf="LOW"
  else perf="HIGH" end
  perfBtn.Text = "⚡ Perf: "..perf
  perfBtn.BackgroundColor3 = (perf=="HIGH" and Color3.fromRGB(80,180,120))
                          or (perf=="MED" and Color3.fromRGB(180,160,80))
                          or Color3.fromRGB(200,120,80)
end)

refreshBtn.MouseButton1Click:Connect(function()
  if not espEnabled then ensureOn() return end
  for _, o in pairs(espObjects) do
    if o.highlight then pcall(function() o.highlight:Destroy() end) end
    if o.billboard then pcall(function() o.billboard:Destroy() end) end
    if o.skeleton then for _, s in pairs(o.skeleton) do pcall(function() s.line:Remove() end) end end
    if o.tracer then pcall(function() o.tracer:Remove() end) end
    if o.arrow then pcall(function() if o.arrowIsTri then o.arrow.Visible=false else o.arrow:Remove() end end) end
    if o.corners then for _,ln in ipairs(o.corners) do pcall(function() ln:Remove() end) end end
  end
  espObjects = {}
  initialScan()
  print("⟲ ESP refreshed.")
end)

-- İlk açılınca bağlam
local function ensureOn()
  if not espEnabled then
    espEnabled = true
    espBtn.Text = "👀 ESP ON"
    espBtn.BackgroundColor3 = Color3.fromRGB(0,200,100)
    initialScan()
    bindRender()
  end
end
-- butonların ilki zaten espBtn; diğerleri tıklanınca ensureOn() çağırıyor
