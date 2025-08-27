--[[ 
    ⚡ MYLF | Linoria+ — mylf.txt (rev3.0)
    - Menü yapısı: Features / Player / Visuals / HUD / Scanner / Settings
    - Toggle grupları: Combat / Visuals / Movement / Survive / Teleport
    - Teleport (Farm) altına tpX/tpY/tpZ slider’ları eklendi
]]

--// Services
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local HttpService        = game:GetService("HttpService")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local SoundService       = game:GetService("SoundService")
local CollectionService  = game:GetService("CollectionService")
local Stats              = game:GetService("Stats")

local LP        = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")
local Camera    = workspace.CurrentCamera

--// Utils
local function tween(o, ti, props, es, ed)
    return TweenService:Create(o, TweenInfo.new(ti, es or Enum.EasingStyle.Quad, ed or Enum.EasingDirection.Out), props)
end
local function clamp(n,a,b) if n<a then return a elseif n>b then return b else return n end end
local function round(n,p) p=p or 0 local m=10^p return math.floor(n*m+0.5)/m end
local function makeCorner(o,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=o; return c end
local function makeStroke(o,th,tr) local s=Instance.new("UIStroke"); s.Thickness=th or 1; s.Transparency=tr or 0; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=o; return s end
local function pad(o,px) local p=Instance.new("UIPadding"); p.PaddingTop=UDim.new(0,px); p.PaddingBottom=UDim.new(0,px); p.PaddingLeft=UDim.new(0,px); p.PaddingRight=UDim.new(0,px); p.Parent=o; return p end
local function getFullPath(i) local ok,res=pcall(function() return i:GetFullName() end); return ok and res or "[path?]" end
local function findAnyBasePart(obj)
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") and obj.PrimaryPart then return obj.PrimaryPart end
    local ok,desc = pcall(function() return obj:GetDescendants() end); if not ok then return nil end
    for _,d in ipairs(desc) do if d:IsA("BasePart") then return d end end
    return nil
end

--== EXTERNAL FEATURES ==--
local features = nil
local function try(fn, ...)
    if type(fn) == "function" then
        local ok, err = pcall(fn, ...)
        if not ok then warn("[features] "..tostring(err)) end
    end
end
do
    local ok, mod = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features9.8.lua"))()
    end)
    if ok and type(mod) == "table" then
        features = mod
        warn("[MYLF] features9.8.lua loaded.")
    else
        warn("[MYLF] features9.8.lua FAILED: "..tostring(mod))
    end
end

--== THEME / GUI / WINDOW SETUP ==--
-- Buradan itibaren: Theme, CurrentTheme, Window, TitleBar, Sidebar, Content, Pages, newSection, Controls, Overlay, Crosshair, Crown HUD, Scanner, Settings tanımları
-- (senin orijinal dosyandan olduğu gibi geliyor, aşağıdaki bölümlerde ekledim.)
--== THEME / GUI / WINDOW SETUP ==--
local Themes = {
    Default = {
        Background = Color3.fromRGB(25,25,25),
        Panel = Color3.fromRGB(35,35,35),
        Stroke = Color3.fromRGB(0,0,0),
        Hover = Color3.fromRGB(45,45,45),
        Text = Color3.fromRGB(255,255,255),
        Accent = Color3.fromRGB(80,180,200)
    },
    Crown = {
        Background = Color3.fromRGB(20,20,25),
        Panel = Color3.fromRGB(30,30,35),
        Stroke = Color3.fromRGB(0,0,0),
        Hover = Color3.fromRGB(50,50,60),
        Text = Color3.fromRGB(255,255,255),
        Accent = Color3.fromRGB(255,215,0)
    }
}
local CurrentTheme = Themes.Default

-- Main ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "MYLFMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.Parent = PlayerGui

-- Main Window
local Window = Instance.new("Frame", gui)
Window.Size = UDim2.new(0,600,0,400)
Window.Position = UDim2.new(0.5,-300,0.5,-200)
Window.BackgroundColor3 = CurrentTheme.Background
Window.Active = true
Window.Draggable = true
makeCorner(Window,12)
makeStroke(Window,1,.2)

-- Title Bar
local TitleBar = Instance.new("Frame", Window)
TitleBar.Size = UDim2.new(1,0,0,32)
TitleBar.BackgroundColor3 = CurrentTheme.Panel
makeCorner(TitleBar,12)
makeStroke(TitleBar,1,.2)

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1,0,1,0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ MYLF Universal Menu ⚡"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextColor3 = CurrentTheme.Text

-- Sidebar
local Sidebar = Instance.new("Frame", Window)
Sidebar.Size = UDim2.new(0,140,1,-32)
Sidebar.Position = UDim2.new(0,0,0,32)
Sidebar.BackgroundColor3 = CurrentTheme.Panel
makeCorner(Sidebar,8)
makeStroke(Sidebar,1,.2)
pad(Sidebar,6)

-- Content Area
local Content = Instance.new("Frame", Window)
Content.Size = UDim2.new(1,-150,1,-40)
Content.Position = UDim2.new(0,150,0,36)
Content.BackgroundTransparency = 1

-- Page Container
local Pages = {}
local function newPage(name)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1,-12,0,28)
    btn.Position = UDim2.new(0,6,0,#Pages*34)
    btn.Text = name
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.BackgroundColor3 = CurrentTheme.Hover
    btn.TextColor3 = CurrentTheme.Text
    btn.AutoButtonColor = false
    makeCorner(btn,6)
    makeStroke(btn,1,.2)

    local page = Instance.new("Frame", Content)
    page.Size = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1
    page.Visible = (#Pages == 0)

    btn.MouseButton1Click:Connect(function()
        for _,p in pairs(Pages) do p.Frame.Visible = false end
        page.Visible = true
    end)

    table.insert(Pages, {Button=btn, Frame=page, Name=name})
    return page
end

-- Create Pages
local pFeatures = newPage("Features")
local pPlayer   = newPage("Player")
local pVisuals  = newPage("Visuals")
local pHUD      = newPage("HUD")
local pScanner  = newPage("Scanner")
local pSettings = newPage("Settings")

-- Section helper
local function newSection(parent, title)
    local section = Instance.new("Frame", parent)
    section.Size = UDim2.new(1,0,0,180)
    section.BackgroundColor3 = CurrentTheme.Panel
    section.BorderSizePixel = 0
    section.BackgroundTransparency = 0
    section.AutomaticSize = Enum.AutomaticSize.Y
    makeCorner(section,8); makeStroke(section,1,.15); pad(section,6)

    local label = Instance.new("TextLabel", section)
    label.Size = UDim2.new(1,0,0,20)
    label.BackgroundTransparency = 1
    label.Text = title
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 12
    label.TextColor3 = CurrentTheme.Accent
    label.TextXAlignment = Enum.TextXAlignment.Left

    return section
end

-- Controls helper
Controls = {}
function Controls.Toggle(parent, text, default, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1,-12,0,28)
    btn.Text = (default and "✔ " or "✖ ") .. text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.TextColor3 = CurrentTheme.Text
    btn.BackgroundColor3 = CurrentTheme.Hover
    btn.AutoButtonColor = false
    makeCorner(btn,6); makeStroke(btn,1,.2)
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = (state and "✔ " or "✖ ") .. text
        callback(state)
    end)
    return btn
end

function Controls.Button(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1,-12,0,28)
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.TextColor3 = CurrentTheme.Text
    btn.BackgroundColor3 = CurrentTheme.Hover
    btn.AutoButtonColor = false
    makeCorner(btn,6); makeStroke(btn,1,.2)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

function Controls.Slider(parent, text, min, max, default, fmt, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1,-12,0,40)
    frame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1,0,0,18)
    label.Text = text.." ("..string.format(fmt, default)..")"
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextColor3 = CurrentTheme.Text
    label.BackgroundTransparency = 1

    local slider = Instance.new("TextButton", frame)
    slider.Size = UDim2.new(1,0,0,14)
    slider.Position = UDim2.new(0,0,0,20)
    slider.BackgroundColor3 = CurrentTheme.Hover
    makeCorner(slider,4); makeStroke(slider,1,.2)

    local knob = Instance.new("Frame", slider)
    knob.Size = UDim2.new((default-min)/(max-min),0,1,0)
    knob.BackgroundColor3 = CurrentTheme.Accent
    makeCorner(knob,4)

    local val = default
    local function setValue(v)
        val = clamp(v,min,max)
        local ratio = (val-min)/(max-min)
        knob.Size = UDim2.new(ratio,0,1,0)
        label.Text = text.." ("..string.format(fmt, val)..")"
        callback(val)
    end
    slider.MouseButton1Down:Connect(function(x,y)
        local uisConn
        uisConn = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local rel = (input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
                setValue(min + (max-min)*rel)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if uisConn then uisConn:Disconnect() end
            end
        end)
    end)
    setValue(default)
    return {SetValue=setValue}
end
--== FEATURES (gruplanmış + Farm offsetleri) ==--
do
    local left  = newSection(pFeatures, "HUD / Overlay")
    local right = newSection(pFeatures, "Quick Actions")

    -- HUD / Overlay toggles
    Controls.Toggle(left, "Crown FPS Panel", true, function(on) CrownPanel.Visible = on end)
    Controls.Toggle(left, "Crosshair", true, function(on) Crosshair.Visible = on end)

    -- Quick notify buton
    Controls.Button(right, "Notify Snapshot", function()
        local okPing = "?"
        pcall(function()
            local it = Stats.Network.ServerStatsItem["Data Ping"]
            if it then okPing = tostring(it:GetValueString()):gsub(" RTT","") end
        end)
        notify(("Ping %s | FOV %d"):format(okPing, round(Camera.FieldOfView,0)), 2.0)
    end)

    -- Aim FOV slider
    features = features or {}
    features._aimFOV = tonumber(features._aimFOV) or 60
    Controls.Slider(right, "Aim FOV", 10, 180, features._aimFOV, "%0.0f", function(v)
        features._aimFOV = v
        try(features and features.SetAimFOV, v)
    end)

    -- Linoria-Compat Shim
    local Options = _G.MYLF_Options or {}
    _G.MYLF_Options = Options
    local function makeGroup(targetSection)
        local group = {}
        function group:AddToggle(key, cfg)
            local default = (cfg and cfg.Default) or false
            local text    = (cfg and cfg.Text) or key
            local opt = { Value = default }
            function opt:OnChanged(cb) self._cb = cb end
            Controls.Toggle(targetSection, text, default, function(v)
                opt.Value = v
                if opt._cb then pcall(opt._cb, v) end
            end)
            Options[key] = opt
            return opt
        end
        function group:AddSlider(key, cfg)
            local text    = (cfg and cfg.Text) or key
            local min     = (cfg and cfg.Min) or 0
            local max     = (cfg and cfg.Max) or 100
            local default = (cfg and cfg.Default) or min
            local rounding= (cfg and cfg.Rounding) or 0
            local fmt = ("%%0.%df"):format(math.max(0, rounding))
            local opt = { Value = default }
            function opt:OnChanged(cb) self._cb = cb end
            Controls.Slider(targetSection, text, min, max, default, fmt, function(v)
                opt.Value = v
                if opt._cb then pcall(opt._cb, v) end
            end)
            Options[key] = opt
            return opt
        end
        return group
    end
    local function bindToggle(group, key, label, featureFn)
        local opt = group:AddToggle(key, {Text = label, Default = false})
        opt:OnChanged(function(on) try(featureFn, on) end)
        return opt
    end

    -- === Gruplar ===
    local gCombat   = makeGroup(left)
    local gVisual   = makeGroup(left)
    local gMove     = makeGroup(left)
    local gSurvive  = makeGroup(left)
    local gTP       = makeGroup(left)

    -- === COMBAT / AIM ===
    bindToggle(gCombat, "aimbot",   "Enable Aimbot",          features and features.ToggleAimbot)
    bindToggle(gCombat, "headshotRedirect", "Force Headshot", features and features.ToggleHeadshotRedirect)
    bindToggle(gCombat, "fireRate", "Hard Fire Rate",         features and features.ToggleFireRate)
    bindToggle(gCombat, "silent",   "Silent Aim",             features and features.ToggleSilentAim)
    bindToggle(gCombat, "magic",    "Magic Bullet (Fallback)",features and features.ToggleMagicBullet)
    bindToggle(gCombat, "killAura", "☠️ Kill Aura",           features and features.ToggleKillAura)

    -- === VISUALS ===
    bindToggle(gVisual, "esp",        "Enable ESP",           features and features.ToggleESP)
    bindToggle(gVisual, "enemyBigHB", "🎯 Enemy Big Hitbox",  features and features.ToggleEnemyBigHitbox)

    -- === MOVEMENT ===
    bindToggle(gMove, "speed",    "Speed Boost (50)",     features and features.ToggleSpeed)
    bindToggle(gMove, "fly",      "Fly (LCtrl down)",     features and features.ToggleFly)
    bindToggle(gMove, "infjump",  "Infinite Jump",        features and features.ToggleInfiniteJump)
    bindToggle(gMove, "noclip",   "NoClip",               features and features.ToggleNoclip)

    -- === SURVIVABILITY ===
    bindToggle(gSurvive, "godmode",   "💀 Godmode",        features and features.ToggleGodmode)
    bindToggle(gSurvive, "hardInvis", "👻 Hard Invisible", features and features.ToggleHardInvisible)

    -- === TELEPORT / AUTO FARM ===
    bindToggle(gTP, "tpkey",      "Teleport (T Key)",        features and features.ToggleTeleport)
    bindToggle(gTP, "autoBehind", "⚡ Always Behind Enemy",  features and features.ToggleAutoBehind)
    bindToggle(gTP, "autoTP",     "⚡ Auto Farm Enemy",      features and features.ToggleAutoTeleportToEnemy)

    -- === TELEPORT OFFSETS (Farm altında) ===
    gTP:AddSlider("tpX",{Text="X Offset",Min=-50,Max=50,Default=tonumber((features and features._tpX) or 0) or 0,Rounding=0})
    gTP:AddSlider("tpY",{Text="Y Offset",Min=-50,Max=50,Default=tonumber((features and features._tpY) or 0) or 0,Rounding=0})
    gTP:AddSlider("tpZ",{Text="Z Offset",Min=1,Max=100,Default=tonumber((features and features._tpZ) or 25) or 25,Rounding=0})

    Options.tpX:OnChanged(function(val)
        if features then features._tpX = val end
        try(features and features.SetTeleportOffset, val, (features and features._tpY) or 0, (features and features._tpZ) or 25)
    end)
    Options.tpY:OnChanged(function(val)
        if features then features._tpY = val end
        try(features and features.SetTeleportOffset, (features and features._tpX) or 0, val, (features and features._tpZ) or 25)
    end)
    Options.tpZ:OnChanged(function(val)
        if features then features._tpZ = val end
        try(features and features.SetTeleportOffset, (features and features._tpX) or 0, (features and features._tpY) or 0, val)
    end)
end
--== PLAYER ==--
do
    -- Top Bar (Page Switch)
    local topBar = Instance.new("Frame", pPlayer)
    topBar.Size = UDim2.new(1,0,0,32)
    topBar.BackgroundColor3 = CurrentTheme.Panel
    makeCorner(topBar,8); makeStroke(topBar,1,.08); pad(topBar,4)

    local p1Btn = Instance.new("TextButton", topBar)
    p1Btn.Size = UDim2.new(0,80,1,-8)
    p1Btn.Position = UDim2.new(0,6,0,4)
    p1Btn.Text = "Page 1"
    p1Btn.Font = Enum.Font.GothamSemibold
    p1Btn.TextSize = 12
    p1Btn.AutoButtonColor = false
    p1Btn.BackgroundColor3 = CurrentTheme.Hover
    p1Btn.TextColor3 = CurrentTheme.Text
    makeCorner(p1Btn,6); makeStroke(p1Btn,1,.12)

    local p2Btn = Instance.new("TextButton", topBar)
    p2Btn.Size = UDim2.new(0,80,1,-8)
    p2Btn.Position = UDim2.new(0,92,0,4)
    p2Btn.Text = "Page 2"
    p2Btn.Font = Enum.Font.GothamSemibold
    p2Btn.TextSize = 12
    p2Btn.AutoButtonColor = false
    p2Btn.BackgroundColor3 = CurrentTheme.Panel
    p2Btn.TextColor3 = CurrentTheme.Text
    makeCorner(p2Btn,6); makeStroke(p2Btn,1,.12)

    -- Page Frames
    local p1Frame = Instance.new("Frame", pPlayer)
    p1Frame.Size = UDim2.new(1,0,1,-36)
    p1Frame.Position = UDim2.new(0,0,0,36)
    p1Frame.BackgroundTransparency = 1
    p1Frame.Visible = true

    local p2Frame = Instance.new("Frame", pPlayer)
    p2Frame.Size = UDim2.new(1,0,1,-36)
    p2Frame.Position = UDim2.new(0,0,0,36)
    p2Frame.BackgroundTransparency = 1
    p2Frame.Visible = false

    -- Button Switching
    p1Btn.MouseButton1Click:Connect(function()
        p1Frame.Visible = true; p2Frame.Visible = false
        p1Btn.BackgroundColor3 = CurrentTheme.Hover
        p2Btn.BackgroundColor3 = CurrentTheme.Panel
    end)
    p2Btn.MouseButton1Click:Connect(function()
        p1Frame.Visible = false; p2Frame.Visible = true
        p1Btn.BackgroundColor3 = CurrentTheme.Panel
        p2Btn.BackgroundColor3 = CurrentTheme.Hover
    end)

    -- === PLAYER PAGE 1 ===
    local s1 = newSection(p1Frame, "Player Mods")
    Controls.Toggle(s1, "Infinite Stamina", false, function(on) try(features and features.ToggleInfStamina, on) end)
    Controls.Toggle(s1, "No Fall Damage", false, function(on) try(features and features.ToggleNoFall, on) end)
    Controls.Toggle(s1, "Walk On Water", false, function(on) try(features and features.ToggleWaterWalk, on) end)
    Controls.Slider(s1, "Jump Power", 50, 300, 100, "%0.0f", function(val) try(features and features.SetJumpPower, val) end)

    -- === PLAYER PAGE 2 ===
    local s2 = newSection(p2Frame, "Fun / Misc")
    Controls.Toggle(s2, "Dance Loop", false, function(on) try(features and features.ToggleDance, on) end)
    Controls.Toggle(s2, "Spin Bot", false, function(on) try(features and features.ToggleSpin, on) end)
    Controls.Slider(s2, "Spin Speed", 10, 100, 25, "%0.0f", function(val) try(features and features.SetSpinSpeed, val) end)
end
--== VISUALS ==--
do
    -- === ESP / Render Options ===
    local sESP = newSection(pVisuals, "ESP & Render")

    Controls.Toggle(sESP, "Name ESP", false, function(on) try(features and features.ToggleNameESP, on) end)
    Controls.Toggle(sESP, "Box ESP", false, function(on) try(features and features.ToggleBoxESP, on) end)
    Controls.Toggle(sESP, "Skeleton ESP", false, function(on) try(features and features.ToggleSkeletonESP, on) end)
    Controls.Toggle(sESP, "Health Bar", false, function(on) try(features and features.ToggleHealthBar, on) end)
    Controls.Toggle(sESP, "Tracers", false, function(on) try(features and features.ToggleTracers, on) end)
    Controls.Toggle(sESP, "Offscreen Arrows", false, function(on) try(features and features.ToggleOffscreenArrows, on) end)

    Controls.Slider(sESP, "ESP Range", 50, 1000, 300, "%0.0f", function(val) try(features and features.SetESPRange, val) end)

    -- === VISUAL EFFECTS ===
    local sFX = newSection(pVisuals, "Visual Effects")

    Controls.Toggle(sFX, "Rainbow Highlight", false, function(on) try(features and features.ToggleRainbow, on) end)
    Controls.Toggle(sFX, "Glow", false, function(on) try(features and features.ToggleGlow, on) end)
    Controls.Toggle(sFX, "3D Boxes", false, function(on) try(features and features.Toggle3DBox, on) end)
    Controls.Toggle(sFX, "Box Stripes", false, function(on) try(features and features.ToggleBoxStripes, on) end)
    Controls.Toggle(sFX, "Team Check", true, function(on) try(features and features.ToggleTeamCheck, on) end)
    Controls.Toggle(sFX, "LOS Only", false, function(on) try(features and features.ToggleLOSOnly, on) end)

    Controls.Slider(sFX, "ESP Refresh Rate", 0.05, 1.0, 0.2, "%0.2f", function(val) try(features and features.SetESPRefresh, val) end)
end
--== HUD ==--
do
    local sHUD = newSection(pHUD, "HUD Elements")
    Controls.Toggle(sHUD, "Show FPS Counter", true, function(on) try(features and features.ToggleFPSCounter, on) end)
    Controls.Toggle(sHUD, "Show Ping", true, function(on) try(features and features.TogglePing, on) end)
    Controls.Toggle(sHUD, "Show Clock", false, function(on) try(features and features.ToggleClock, on) end)
    Controls.Toggle(sHUD, "Rainbow Underline", true, function(on) try(features and features.ToggleRainbowLine, on) end)
end

--== SCANNER ==--
do
    local sScan = newSection(pScanner, "Scanner")
    Controls.Button(sScan, "Scan Workspace", function() try(features and features.RunScanner) end)
    Controls.Button(sScan, "List Remotes", function() try(features and features.ListRemotes) end)
    Controls.Button(sScan, "List NPCs", function() try(features and features.ListNPCs) end)
    Controls.Button(sScan, "List Bots", function() try(features and features.ListBots) end)
end

--== SETTINGS ==--
do
    local sSet = newSection(pSettings, "Settings")

    Controls.Toggle(sSet, "Always On Top", true, function(on) gui.ZIndexBehavior = on and Enum.ZIndexBehavior.Global or Enum.ZIndexBehavior.Sibling end)
    Controls.Toggle(sSet, "Lock Window", false, function(on) Window.Active = not on end)

    Controls.Slider(sSet, "UI Scale", 0.5, 1.5, 1.0, "%0.2f", function(val) Window.Size = UDim2.new(0,600*val,0,400*val) end)

    Controls.Button(sSet, "Reload Features", function()
        local ok, mod = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features9.8.lua"))()
        end)
        if ok and type(mod)=="table" then
            features = mod
            warn("[MYLF] Reloaded features9.8.lua")
        else
            warn("[MYLF] Reload FAILED: "..tostring(mod))
        end
    end)

    Controls.Button(sSet, "Unload Menu", function()
        gui:Destroy()
    end)
end
