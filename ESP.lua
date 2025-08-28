-- features_practice_esp.lua
local features = {}

-- caches
features._targets = {}      -- [Model] = {bits...}
features._byConn  = {}      -- [Model] = { connA, connB, ... }
features._conns   = {}      -- named RenderStepped loops
features._tfolder = nil     -- target folder (Instance)
features._enabled = {}      -- feature flags (optional)

-- services & locals
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP         = Players.LocalPlayer
local Camera     = workspace.CurrentCamera

-- ========= helpers =========
local function rainbowColor(t)
  local r = math.floor(math.sin(t*2)   *127 + 128)
  local g = math.floor(math.sin(t*2+2) *127 + 128)
  local b = math.floor(math.sin(t*2+4) *127 + 128)
  return Color3.fromRGB(r,g,b)
end

local function tryDrawing(kind)
  local ok, obj = pcall(function() return Drawing.new(kind) end)
  return ok and obj or nil
end

local function getAdornee(m)
  if not m or not m.Parent then return nil end
  return m:FindFirstChild("Head")
      or m:FindFirstChild("UpperTorso")
      or m:FindFirstChild("Torso")
      or m:FindFirstChild("HumanoidRootPart")
      or (m.PrimaryPart and m.PrimaryPart)
end

local function isModelHumanoid(m)
  return m and m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") ~= nil
end

local function ensureTarget(model)
  if not isModelHumanoid(model) then return end
  if features._targets[model] then return end
  features._targets[model] = {}     -- per-model cache table
  -- auto-clean on destroy/ancestry change
  features._byConn[model] = features._byConn[model] or {}
  table.insert(features._byConn[model], model.AncestryChanged:Connect(function(_, parent)
    if not parent then
      -- cleanup
      local o = features._targets[model]
      if o then
        -- hide drawing/instances
        if o.tracer then pcall(function() o.tracer.Visible=false end) end
        if o.skeleton then for _,seg in ipairs(o.skeleton) do pcall(function() seg.line.Visible=false end) end end
        if o.selectionBox then pcall(function() o.selectionBox.Visible=false end) end
        if o.highlight then pcall(function() o.highlight.Enabled=false end) end
        if o.billboard then pcall(function() o.billboard:Destroy() end) end
        features._targets[model] = nil
      end
      if features._byConn[model] then
        for _,c in ipairs(features._byConn[model]) do pcall(function() c:Disconnect() end) end
        features._byConn[model] = nil
      end
    end
  end))
end

local function primeFolder(folder)
  if not folder or not folder:IsA("Instance") then return end
  for _,child in ipairs(folder:GetChildren()) do
    if isModelHumanoid(child) then ensureTarget(child) end
  end
  -- watch spawns
  folder.ChildAdded:Connect(function(ch)
    if isModelHumanoid(ch) then
      task.wait(0.2)
      ensureTarget(ch)
    end
  end)
end

-- public: set your practice folder, e.g. workspace.PracticeTargets
function features.SetTargetFolder(folder)
  features._tfolder = folder
  if folder then primeFolder(folder) end
end

-- public: add/remove single target (manual)
function features.AddTarget(model) ensureTarget(model) end
function features.RemoveTarget(model)
  if not features._targets[model] then return end
  -- trigger cleanup via parent nil:
  model.Parent = nil
end

-- also include your own character (for testing HUD)
local function hookLocalCharacter()
  if LP.Character then ensureTarget(LP.Character) end
  LP.CharacterAdded:Connect(function(char)
    task.wait(0.2)
    ensureTarget(char)
  end)
end
hookLocalCharacter()

-- ========= Skeleton joints =========
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

-- ========= Independent Toggles / Loops =========

-- 3D Box
function features.ToggleBox(on)
  if on and not features._conns.box then
    features._conns.box = RunService.RenderStepped:Connect(function()
      for model,o in pairs(features._targets) do
        if not o.selectionBox then
          local ad = getAdornee(model)
          if ad then
            local sb = Instance.new("SelectionBox")
            sb.LineThickness       = 0.04
            sb.SurfaceTransparency = 0.85
            sb.Color3              = Color3.fromRGB(0,255,0) -- RGB sabit
            sb.Adornee             = ad
            sb.Parent              = ad
            o.selectionBox = sb
          end
        end
        if o.selectionBox then o.selectionBox.Visible = true end
      end
    end)
  elseif not on and features._conns.box then
    features._conns.box:Disconnect(); features._conns.box=nil
    for _,o in pairs(features._targets) do if o.selectionBox then o.selectionBox.Visible=false end end
  end
end

-- Rainbow Highlight (Glow)
function features.ToggleGlow(on)
  if on and not features._conns.glow then
    features._conns.glow = RunService.RenderStepped:Connect(function(dt)
      features._t = (features._t or 0) + dt
      local col = rainbowColor(features._t)
      for model,o in pairs(features._targets) do
        if not o.highlight then
          local ad = getAdornee(model)
          if ad then
            local hl = Instance.new("Highlight")
            hl.FillTransparency = 0.5
            hl.OutlineColor     = Color3.fromRGB(255,255,255)
            hl.Parent           = ad
            o.highlight = hl
          end
        end
        if o.highlight then
          o.highlight.Enabled      = true
          o.highlight.FillColor    = col
          o.highlight.OutlineColor = col
        end
      end
    end)
  elseif not on and features._conns.glow then
    features._conns.glow:Disconnect(); features._conns.glow=nil
    for _,o in pairs(features._targets) do if o.highlight then o.highlight.Enabled=false end end
  end
end

-- Rainbow Name Label
function features.ToggleRainbowName(on)
  if on and not features._conns.rname then
    features._conns.rname = RunService.RenderStepped:Connect(function(dt)
      features._t = (features._t or 0) + dt
      local col = rainbowColor(features._t)
      for model,o in pairs(features._targets) do
        if not o.billboard then
          local ad = getAdornee(model)
          if ad then
            local bb  = Instance.new("BillboardGui")
            bb.Size   = UDim2.new(0,120,0,20)
            bb.Adornee= ad
            bb.AlwaysOnTop = true
            local txt = Instance.new("TextLabel")
            txt.Size  = UDim2.new(1,0,1,0)
            txt.BackgroundTransparency = 1
            txt.Font = Enum.Font.SourceSansBold
            txt.TextScaled = true
            txt.TextStrokeTransparency = 0
            txt.Text = model.Name
            txt.TextColor3 = Color3.fromRGB(255,255,255)
            txt.Parent = bb
            bb.Parent = ad
            o.billboard = bb
            o.label = txt
          end
        end
        if o.label then o.label.TextColor3 = col end
      end
    end)
  elseif not on and features._conns.rname then
    features._conns.rname:Disconnect(); features._conns.rname=nil
    for _,o in pairs(features._targets) do if o.label then o.label.TextColor3 = Color3.fromRGB(255,255,255) end end
  end
end

-- Tracers (from bottom-center)
function features.ToggleTracers(on)
  if on and not features._conns.tracers then
    features._conns.tracers = RunService.RenderStepped:Connect(function()
      local vp = Camera.ViewportSize
      local origin = Vector2.new(vp.X/2, vp.Y)
      for model,o in pairs(features._targets) do
        if not o.tracer then
          o.tracer = tryDrawing("Line")
          if o.tracer then o.tracer.Thickness=2; o.tracer.Color=Color3.fromRGB(255,255,255) end
        end
        local hrp = model:FindFirstChild("HumanoidRootPart")
        if hrp and o.tracer then
          local v, on = Camera:WorldToViewportPoint(hrp.Position)
          if on and v.Z > 0 then
            o.tracer.Visible = true
            o.tracer.From    = origin
            o.tracer.To      = Vector2.new(v.X, v.Y)
            o.tracer.Color   = Color3.fromRGB(255,255,255) -- RGB sabit
          else
            o.tracer.Visible = false
          end
        end
      end
    end)
  elseif not on and features._conns.tracers then
    features._conns.tracers:Disconnect(); features._conns.tracers=nil
    for _,o in pairs(features._targets) do if o.tracer then o.tracer.Visible=false end end
  end
end

-- Skeleton (Drawing lines)
local function skeletonLinesFor(model, o)
  if o.skeleton then return end
  o.skeleton = {}
  for _,link in ipairs(skeletonJointsFor(model)) do
    local ln = tryDrawing("Line")
    if ln then
      ln.Thickness = 2
      ln.Color     = Color3.fromRGB(255,255,255)
      ln.Visible   = true
      table.insert(o.skeleton, {parts = link, line = ln})
    end
  end
end

function features.ToggleSkeleton(on)
  if on and not features._conns.skeleton then
    features._conns.skeleton = RunService.RenderStepped:Connect(function()
      for model,o in pairs(features._targets) do
        skeletonLinesFor(model, o)
        if o.skeleton then
          for _,seg in ipairs(o.skeleton) do
            local p1 = model:FindFirstChild(seg.parts[1], true)
            local p2 = model:FindFirstChild(seg.parts[2], true)
            if p1 and p2 then
              local v1,on1 = Camera:WorldToViewportPoint(p1.Position)
              local v2,on2 = Camera:WorldToViewportPoint(p2.Position)
              if on1 and on2 then
                seg.line.From   = Vector2.new(v1.X, v1.Y)
                seg.line.To     = Vector2.new(v2.X, v2.Y)
                seg.line.Color  = Color3.fromRGB(255,255,255)
                seg.line.Visible= true
              else
                seg.line.Visible= false
              end
            else
              seg.line.Visible = false
            end
          end
        end
      end
    end)
  elseif not on and features._conns.skeleton then
    features._conns.skeleton:Disconnect(); features._conns.skeleton=nil
    for _,o in pairs(features._targets) do
      if o.skeleton then for _,seg in ipairs(o.skeleton) do seg.line.Visible=false end end
    end
  end
end

-- ========= bootstrap =========
-- Varsayılan: workspace.PracticeTargets klasörünü otomatik bağla
task.defer(function()
  local defaultFolder = workspace:FindFirstChild("PracticeTargets")
  if defaultFolder then features.SetTargetFolder(defaultFolder) end
end)

return features
