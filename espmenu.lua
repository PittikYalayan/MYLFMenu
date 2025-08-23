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
        goal.Size = UDim2.new(0, 280, 0, 520) -- ✨ daha uzun
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

-- 👀 ESP (Takım kontrol + NPC + Rainbow Fill + Rainbow Name + Skeleton + Extras)
local espBtn = makeButton("👀 ESP OFF", Color3.fromRGB(80,180,200))
local rainbowBtn   = makeButton("🌈 Rainbow Name OFF",   Color3.fromRGB(200,140,80))
local skeletonBtn  = makeButton("🦴 Skeleton OFF",       Color3.fromRGB(150,100,200))
local glowBtn      = makeButton("✨ Glow (Rainbow) OFF", Color3.fromRGB(200,80,150))
local boxBtn       = makeButton("▣ Box OFF",             Color3.fromRGB(120,160,200))
local stripesBtn   = makeButton("≡ Box Stripes OFF",     Color3.fromRGB(120,120,120))
local distBtn      = makeButton("📏 Distance OFF",       Color3.fromRGB(100,140,200))
local hpBtn        = makeButton("❤️ Health Bar OFF",     Color3.fromRGB(200,100,100))
local tracerBtn    = makeButton("〽 Tracers OFF",        Color3.fromRGB(160,160,160))
local teamBtn      = makeButton("👥 Team Check OFF",     Color3.fromRGB(120,120,200))
local losBtn       = makeButton("🔭 LOS Only OFF",       Color3.fromRGB(120,120,160))
local rangeBtn     = makeButton("📡 Range Limit OFF",    Color3.fromRGB(120,160,120))

local espEnabled = false
local opt = {
    rainbow = false, skeleton = false, glow = false, box = false, stripes = false,
    showDist = false, healthBar = false, tracers = false, teamCheck = false, losOnly = false, rangeLimit = false
}

local espObjects = {}
local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local renderConn, plrAddedConns = nil, {}

-- Renk döngüsü (rainbow)
local function rainbowColor(t)
    local r = math.clamp(math.floor(math.sin(t*2)     *127+128),0,255)
    local g = math.clamp(math.floor(math.sin(t*2 + 2) *127+128),0,255)
    local b = math.clamp(math.floor(math.sin(t*2 + 4) *127+128),0,255)
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

-- R6/R15 kemik listesi
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

-- yardımcı: hedef filtreleri
local function sameTeam(char)
    if not opt.teamCheck then return false end
    local a,b = game.Players:GetPlayerFromCharacter(char), player
    if a and b and a.Team and b.Team then return a.Team==b.Team end
    return false
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
local function ensureTracer(obj)
    if not obj.tracer then
        local ok, line = pcall(function() return Drawing.new("Line") end)
        if ok and line then
            line.Thickness = 2
            line.Color = Color3.fromRGB(255,255,255)
            line.Visible = true
            obj.tracer = line
        end
    end
    if obj.tracer then obj.tracer.Visible = true end
end

-- Skeleton çizgisi (Drawing)
local function ensureSkeleton(target, obj)
    if obj.skeleton then return end
    obj.skeleton = {}
    for _,link in pairs(skeletonJointsFor(target)) do
        local ok, line = pcall(function() return Drawing.new("Line") end)
        if ok and line then
            line.Thickness = 2
            line.Color = Color3.fromRGB(255,255,255)
            line.Visible = true
            table.insert(obj.skeleton, {parts = link, line = line})
        end
    end
end

-- ESP ekle (Highlight + Name)
local function addESP(target, isNPC)
    local adornee = getAdornee(target)
    if not (target and adornee) then return end
    espObjects[target] = espObjects[target] or {}
    local obj = espObjects[target]

    -- Highlight
    if not obj.highlight or not obj.highlight.Parent then
        local highlight = Instance.new("Highlight")
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.fromRGB(255,255,255)
        highlight.Parent = target
        obj.highlight = highlight
    end

    -- Billboard
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
        text.Text = isNPC and "NPC" or (game.Players:GetPlayerFromCharacter(target) and game.Players:GetPlayerFromCharacter(target).DisplayName or "Player")

        billboard.Parent = adornee
        obj.billboard = billboard
        obj.label = text
    end
end

-- Ölü/ayrılan temizleme
local function clearDead()
    for obj, o in pairs(espObjects) do
        if (not obj.Parent) or (not getAdornee(obj)) then
            if o.highlight then pcall(function() o.highlight:Destroy() end) end
            if o.billboard then pcall(function() o.billboard:Destroy() end) end
            if o.skeleton then for _,s in pairs(o.skeleton) do pcall(function() s.line:Remove() end) end end
            if o.tracer then pcall(function() o.tracer:Remove() end) end
            espObjects[obj] = nil
        end
    end
end

-- Hedef listesi (Player + NPC + Bots)
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
            if espEnabled and bot:FindFirstChildOfClass("Humanoid") then
                task.wait(0.5) addESP(bot, true)
            end
        end)
    end
    workspace.ChildAdded:Connect(function(obj)
        if espEnabled and obj:FindFirstChildOfClass("Humanoid") and getAdornee(obj) and not game.Players:GetPlayerFromCharacter(obj) then
            task.wait(0.5) addESP(obj, true)
        end
    end)
end

-- RenderStepped loop (tüm opsiyonlar)
local function bindRender()
    if renderConn then renderConn:Disconnect() end
    local t = 0
    renderConn = RunService.RenderStepped:Connect(function(dt)
        if not espEnabled then return end
        t = t + dt
        local col = rainbowColor(t)
        local vp = Camera.ViewportSize
        local screenBottom = Vector2.new(vp.X/2, vp.Y)

        for obj, o in pairs(espObjects) do
            if obj and obj.Parent and not sameTeam(obj) and withinRange(obj) and losVisible(obj) then
                -- Label + Distance
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

                -- Highlight (Glow veya Rainbow Name açıkken)
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
                        local max = hum.MaxHealth > 0 and hum.MaxHealth or 100
                        local ratio = math.clamp(hum.Health / max, 0, 1)
                        o.hpFill.Size = UDim2.new(ratio,0,1,0)
                        o.hpFill.BackgroundColor3 = Color3.fromRGB(255*(1-ratio), 255*ratio, 40)
                    end
                elseif o.hpBack then
                    o.hpBack.Visible = false
                end

                -- Skeleton (Drawing)
                if opt.skeleton then
                    ensureSkeleton(obj, o)
                    if o.skeleton then
                        for _, s in pairs(o.skeleton) do
                            local p1 = obj:FindFirstChild(s.parts[1], true)
                            local p2 = obj:FindFirstChild(s.parts[2], true)
                            if p1 and p2 then
                                local v1, on1 = Camera:WorldToViewportPoint(p1.Position)
                                local v2, on2 = Camera:WorldToViewportPoint(p2.Position)
                                if on1 and on2 then
                                    s.line.From = Vector2.new(v1.X, v1.Y)
                                    s.line.To   = Vector2.new(v2.X, v2.Y)
                                    s.line.Color = col
                                    s.line.Visible = true
                                else
                                    s.line.Visible = false
                                end
                            else
                                s.line.Visible = false
                            end
                        end
                    end
                elseif o.skeleton then
                    for _, s in pairs(o.skeleton) do s.line.Visible = false end
                end

                -- Box
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
                        for _,b in pairs(o.stripeBeams) do b.Color = seq; b.Enabled = true end
                    end
                elseif o.stripeBeams then
                    for _,b in pairs(o.stripeBeams) do b.Enabled = false end
                end

                -- Tracers (Drawing)
                if opt.tracers then
                    local hrp = obj:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        ensureTracer(o)
                        if o.tracer then
                            local v, on = Camera:WorldToViewportPoint(hrp.Position)
                            if on and v.Z>0 then
                                local to = Vector2.new(v.X, v.Y)
                                local delta = to - screenBottom
                                local len = delta.Magnitude
                                o.tracer.Visible = true
                                o.tracer.From = screenBottom
                                o.tracer.To = to
                                o.tracer.Color = col
                            else
                                o.tracer.Visible = false
                            end
                        end
                    end
                elseif o.tracer then
                    o.tracer.Visible = false
                end
            else
                -- filtreye takılan hedefi gizle
                if o.label then o.label.TextColor3 = Color3.fromRGB(255,255,255) end
                if o.highlight then o.highlight.Enabled = false end
                if o.selectionBox then o.selectionBox.Visible = false end
                if o.skeleton then for _, s in pairs(o.skeleton) do s.line.Visible = false end end
                if o.tracer then o.tracer.Visible = false end
                if o.hpBack then o.hpBack.Visible = false end
            end
        end
        clearDead()
    end)
end

-- Toggles (her biri ESP’yi otomatik açar)
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
            if o.selectionBox then pcall(function() o.selectionBox.Visible=false end) end
            if o.hpBack then o.hpBack.Visible=false end
        end
        espObjects = {}
    end
end)

rainbowBtn.MouseButton1Click:Connect(function()
    opt.rainbow = not opt.rainbow; ensureOn()
    rainbowBtn.Text = opt.rainbow and "🌈 Rainbow Name ON" or "🌈 Rainbow Name OFF"
    rainbowBtn.BackgroundColor3 = opt.rainbow and Color3.fromRGB(0,200,120) or Color3.fromRGB(200,140,80)
end)
skeletonBtn.MouseButton1Click:Connect(function()
    opt.skeleton = not opt.skeleton; ensureOn()
    skeletonBtn.Text = opt.skeleton and "🦴 Skeleton ON" or "🦴 Skeleton OFF"
    skeletonBtn.BackgroundColor3 = opt.skeleton and Color3.fromRGB(0,200,120) or Color3.fromRGB(150,100,200)
end)
glowBtn.MouseButton1Click:Connect(function()
    opt.glow = not opt.glow; ensureOn()
    glowBtn.Text = opt.glow and "✨ Glow (Rainbow) ON" or "✨ Glow (Rainbow) OFF"
    glowBtn.BackgroundColor3 = opt.glow and Color3.fromRGB(0,200,120) or Color3.fromRGB(200,80,150)
end)
boxBtn.MouseButton1Click:Connect(function()
    opt.box = not opt.box; ensureOn()
    boxBtn.Text = opt.box and "▣ Box ON" or "▣ Box OFF"
    boxBtn.BackgroundColor3 = opt.box and Color3.fromRGB(0,200,120) or Color3.fromRGB(120,160,200)
end)
stripesBtn.MouseButton1Click:Connect(function()
    opt.stripes = not opt.stripes; ensureOn()
    stripesBtn.Text = opt.stripes and "≡ Box Stripes ON" or "≡ Box Stripes OFF"
    stripesBtn.BackgroundColor3 = opt.stripes and Color3.fromRGB(0,200,120) or Color3.fromRGB(120,120,120)
end)
distBtn.MouseButton1Click:Connect(function()
    opt.showDist = not opt.showDist; ensureOn()
    distBtn.Text = opt.showDist and "📏 Distance ON" or "📏 Distance OFF"
    distBtn.BackgroundColor3 = opt.showDist and Color3.fromRGB(0,200,120) or Color3.fromRGB(100,140,200)
end)
hpBtn.MouseButton1Click:Connect(function()
    opt.healthBar = not opt.healthBar; ensureOn()
    hpBtn.Text = opt.healthBar and "❤️ Health Bar ON" or "❤️ Health Bar OFF"
    hpBtn.BackgroundColor3 = opt.healthBar and Color3.fromRGB(0,200,120) or Color3.fromRGB(200,100,100)
end)
tracerBtn.MouseButton1Click:Connect(function()
    opt.tracers = not opt.tracers; ensureOn()
    tracerBtn.Text = opt.tracers and "〽 Tracers ON" or "〽 Tracers OFF"
    tracerBtn.BackgroundColor3 = opt.tracers and Color3.fromRGB(0,200,120) or Color3.fromRGB(160,160,160)
end)
teamBtn.MouseButton1Click:Connect(function()
    opt.teamCheck = not opt.teamCheck; ensureOn()
    teamBtn.Text = opt.teamCheck and "👥 Team Check ON" or "👥 Team Check OFF"
    teamBtn.BackgroundColor3 = opt.teamCheck and Color3.fromRGB(0,200,120) or Color3.fromRGB(120,120,200)
end)
losBtn.MouseButton1Click:Connect(function()
    opt.losOnly = not opt.losOnly; ensureOn()
    losBtn.Text = opt.losOnly and "🔭 LOS Only ON" or "🔭 LOS Only OFF"
    losBtn.BackgroundColor3 = opt.losOnly and Color3.fromRGB(0,200,120) or Color3.fromRGB(120,120,160)
end)
rangeBtn.MouseButton1Click:Connect(function()
    opt.rangeLimit = not opt.rangeLimit; ensureOn()
    rangeBtn.Text = opt.rangeLimit and "📡 Range Limit 300 ON" or "📡 Range Limit OFF"
    rangeBtn.BackgroundColor3 = opt.rangeLimit and Color3.fromRGB(0,200,120) or Color3.fromRGB(120,160,120)
end)
