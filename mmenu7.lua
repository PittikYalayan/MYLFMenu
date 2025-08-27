--// ⚡ MYLF Ultra Menu (No Linoria) – Full Source
--// Executor: Xeno vb.
--// Parent: CoreGui (ESC menüsünün üstünde kalmaya çalışır: yüksek DisplayOrder)
--// Visible Toggle: default RightShift (Settings'ten değiştirilebilir)
--// Update intervals
local HUD_UPDATE_INTERVAL = 0.1  -- 0.1s = 100ms
local SCAN_AUTO_INTERVAL = 3.0   -- Auto-Scan açıkken

--== Services & Shortcuts ==--
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local Stats          = game:GetService("Stats")
local HttpService    = game:GetService("HttpService")
local CoreGui        = game:GetService("CoreGui")
local StarterGui     = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LP = Players.LocalPlayer

--== External features module (9.8) ==--
local FEATURES_URL = "https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features9.8.lua"
local features = nil
do
    local ok, mod = pcall(function()
        local src = game:HttpGet(FEATURES_URL)
        return loadstring(src)()
    end)
    if ok then features = mod end
end

-- safe caller (tolerant)
local function callFeature(fname, ...)
    if not features then return end
    local f = features[fname]
    if typeof(f) == "function" then
        local ok, err = pcall(f, ...)
        if not ok then warn("Feature "..fname.." error:", err) end
    end
end

-- optional getter/setter fallbacks
local function setFeatureField(field, value)
    if features then
        local ok = pcall(function() features[field] = value end)
        if not ok then warn("Feature field set failed:", field) end
    end
end
local function getFeatureField(field, fallback)
    if not features then return fallback end
    local ok, val = pcall(function() return features[field] end)
    if ok then return val end
    return fallback
end

--== THEME ENGINE ==--
local Themes = {
    ["Dark-Red"] = {
        Bg = Color3.fromRGB(16,16,18),
        Panel = Color3.fromRGB(24,24,28),
        Accent = Color3.fromRGB(230, 57, 70),
        Text = Color3.fromRGB(235,235,240),
        SubText = Color3.fromRGB(170,170,180),
        Stroke = Color3.fromRGB(255,255,255),
        Shadow = Color3.fromRGB(0,0,0),
        Hover = Color3.fromRGB(34,34,38)
    },
    ["Neo-Purple"] = {
        Bg = Color3.fromRGB(14, 12, 22),
        Panel = Color3.fromRGB(26, 22, 45),
        Accent = Color3.fromRGB(153, 102, 255),
        Text = Color3.fromRGB(240,240,248),
        SubText = Color3.fromRGB(180,175,200),
        Stroke = Color3.fromRGB(255,255,255),
        Shadow = Color3.fromRGB(0,0,0),
        Hover = Color3.fromRGB(40, 35, 62)
    },
    ["Midnight"] = {
        Bg = Color3.fromRGB(10,12,16),
        Panel = Color3.fromRGB(20,24,30),
        Accent = Color3.fromRGB(0, 180, 216),
        Text = Color3.fromRGB(230,235,240),
        SubText = Color3.fromRGB(165,175,185),
        Stroke = Color3.fromRGB(255,255,255),
        Shadow = Color3.fromRGB(0,0,0),
        Hover = Color3.fromRGB(28,32,40)
    },
    ["Matrix-Green"] = {
        Bg = Color3.fromRGB(6,10,6),
        Panel = Color3.fromRGB(12,18,12),
        Accent = Color3.fromRGB(0, 255, 136),
        Text = Color3.fromRGB(220,255,230),
        SubText = Color3.fromRGB(150,190,160),
        Stroke = Color3.fromRGB(255,255,255),
        Shadow = Color3.fromRGB(0,0,0),
        Hover = Color3.fromRGB(20,28,22)
    },
    ["Ocean"] = {
        Bg = Color3.fromRGB(10,15,20),
        Panel = Color3.fromRGB(18,26,34),
        Accent = Color3.fromRGB(0, 180, 255),
        Text = Color3.fromRGB(230,245,255),
        SubText = Color3.fromRGB(170,195,210),
        Stroke = Color3.fromRGB(255,255,255),
        Shadow = Color3.fromRGB(0,0,0),
        Hover = Color3.fromRGB(26,36,46)
    }
}
local CurrentThemeName = "Dark-Red"
local Theme = Themes[CurrentThemeName]

--== GUI HELPERS ==--
local function corner(inst, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = inst
    return c
end
local function stroke(inst, thickness, trans)
    local s = Instance.new("UIStroke")
    s.Thickness = thickness or 1
    s.Transparency = trans or 0.1
    s.Color = Theme.Stroke
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = inst
    return s
end
local function padding(inst, px)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, px)
    p.PaddingBottom = UDim.new(0, px)
    p.PaddingLeft = UDim.new(0, px)
    p.PaddingRight = UDim.new(0, px)
    p.Parent = inst
    return p
end
local function vlist(parent, pad)
    local lay = Instance.new("UIListLayout")
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.Padding = UDim.new(0, pad or 6)
    lay.Parent = parent
    return lay
end

--== ScreenGui ==--
local gui = Instance.new("ScreenGui")
gui.Name = "MYLF_Ultra"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.DisplayOrder = 999999
pcall(function() gui.Parent = CoreGui end)

--== Main Window ==--
local Window = Instance.new("Frame")
Window.Name = "Window"
Window.Parent = gui
Window.Size = UDim2.new(0, 740, 0, 480)
Window.Position = UDim2.new(0.1, 0, 0.2, 0)
Window.BackgroundColor3 = Theme.Panel
corner(Window, 10); stroke(Window, 1, 0.15); padding(Window, 8)

-- Drop shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Parent = Window
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
Shadow.Size = UDim2.new(1, 40, 1, 40)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://5028857084"
Shadow.ImageTransparency = 0.5
Shadow.ImageColor3 = Theme.Shadow
Shadow.ZIndex = 0

-- TitleBar (only header is draggable)
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = Window
TitleBar.BackgroundColor3 = Theme.Bg
TitleBar.Size = UDim2.new(1, -16, 0, 44)
TitleBar.Position = UDim2.new(0, 8, 0, 8)
corner(TitleBar, 8); stroke(TitleBar, 1, 0.2); padding(TitleBar, 8)
local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, -160, 1, -8)
Title.Position = UDim2.new(0, 8, 0, 4)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamSemibold
Title.TextSize = 16
Title.TextColor3 = Theme.Text
Title.Text = "⚡ MYLF | Ultra Menu (Custom UI)"
Title.BackgroundTransparency = 1

-- Drag (header only)
do
    local dragging = false
    local dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Window.Position
        end
    end)
    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Tab Bar
local Tabs = Instance.new("Frame", Window)
Tabs.Name = "Tabs"
Tabs.BackgroundTransparency = 1
Tabs.Size = UDim2.new(1, -16, 0, 40)
Tabs.Position = UDim2.new(0, 8, 0, 64)
local tabsLayout = Instance.new("UIListLayout", Tabs)
tabsLayout.FillDirection = Enum.FillDirection.Horizontal
tabsLayout.Padding = UDim.new(0, 8)
tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder

local Pages = Instance.new("Frame", Window)
Pages.Name = "Pages"
Pages.BackgroundTransparency = 1
Pages.Size = UDim2.new(1, -16, 1, -120)
Pages.Position = UDim2.new(0, 8, 0, 112)

local function makeTab(name)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Parent = Tabs
    b.Text = name
    b.AutoButtonColor = false
    b.Size = UDim2.new(0, 110, 1, 0)
    b.BackgroundColor3 = Theme.Panel
    b.TextColor3 = Theme.Text
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 14
    corner(b, 8); stroke(b, 1, 0.15)
    b.MouseEnter:Connect(function() b.BackgroundColor3 = Theme.Hover end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = Theme.Panel end)

    local page = Instance.new("Frame")
    page.Name = name.."_Page"
    page.Parent = Pages
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Visible = false
    page.BackgroundColor3 = Theme.Panel
    corner(page, 8); stroke(page, 1, 0.1); padding(page, 10)
    vlist(page, 8)

    b.MouseButton1Click:Connect(function()
        for _, p in ipairs(Pages:GetChildren()) do
            if p:IsA("Frame") then p.Visible = false end
        end
        page.Visible = true
    end)

    return b, page
end

-- Controls helpers
local function section(parent, title)
    local f = Instance.new("Frame")
    f.Parent = parent
    f.Size = UDim2.new(1, 0, 0, 42)
    f.BackgroundColor3 = Theme.Bg
    corner(f, 8); stroke(f, 1, 0.15); padding(f, 10)
    local t = Instance.new("TextLabel", f)
    t.BackgroundTransparency = 1
    t.Text = title
    t.Font = Enum.Font.GothamSemibold
    t.TextSize = 14
    t.TextColor3 = Theme.Text
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Size = UDim2.new(1, -10, 1, -10)
    t.Position = UDim2.new(0, 6, 0, 6)
    return f
end

local function toggle(parent, text, default, callback)
    local f = Instance.new("Frame")
    f.Parent = parent
    f.Size = UDim2.new(1, 0, 0, 38)
    f.BackgroundColor3 = Theme.Bg
    corner(f, 8); stroke(f, 1, 0.12); padding(f, 8)
    local lbl = Instance.new("TextLabel", f)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextColor3 = Theme.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Size = UDim2.new(1, -64, 1, 0)

    local btn = Instance.new("TextButton", f)
    btn.AutoButtonColor = false
    btn.Size = UDim2.new(0, 48, 0, 22)
    btn.Position = UDim2.new(1, -56, 0.5, -11)
    btn.Text = ""
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 68)
    corner(btn, 11); stroke(btn, 1, 0.15)

    local knob = Instance.new("Frame", btn)
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = Theme.Text
    corner(knob, 9)

    local state = default and true or false
    local function redraw()
        if state then
            btn.BackgroundColor3 = Theme.Accent
            knob:TweenPosition(UDim2.new(1, -20, 0.5, -9), "Out", "Quad", 0.12, true)
        else
            btn.BackgroundColor3 = Color3.fromRGB(60,60,68)
            knob:TweenPosition(UDim2.new(0, 2, 0.5, -9), "Out", "Quad", 0.12, true)
        end
    end
    redraw()
    btn.MouseButton1Click:Connect(function()
        state = not state
        redraw()
        if callback then
            local ok, err = pcall(callback, state)
            if not ok then warn("toggle cb error:", err) end
        end
    end)
    return {
        Set = function(v) state = v; redraw() end,
        Get = function() return state end
    }
end

local function slider(parent, text, min, max, default, callback)
    local f = Instance.new("Frame")
    f.Parent = parent
    f.Size = UDim2.new(1, 0, 0, 54)
    f.BackgroundColor3 = Theme.Bg
    corner(f, 8); stroke(f, 1, 0.12); padding(f, 10)

    local lbl = Instance.new("TextLabel", f)
    lbl.BackgroundTransparency = 1
    lbl.Text = string.format("%s  (%.2f)", text, default)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextColor3 = Theme.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Size = UDim2.new(1, 0, 0, 18)

    local bar = Instance.new("Frame", f)
    bar.Size = UDim2.new(1, -20, 0, 10)
    bar.Position = UDim2.new(0, 10, 0, 26)
    bar.BackgroundColor3 = Color3.fromRGB(60,60,68)
    corner(bar, 6); stroke(bar, 1, 0.1)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    corner(fill, 6)

    local dragging = false
    local value = default

    local function setValueFromX(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        value = min + (max-min)*rel
        fill.Size = UDim2.new(rel, 0, 1, 0)
        lbl.Text = string.format("%s  (%.2f)", text, value)
        if callback then
            local ok, err = pcall(callback, value)
            if not ok then warn("slider cb error:", err) end
        end
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            setValueFromX(input.Position.X)
        end
    end)
    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            setValueFromX(input.Position.X)
        end
    end)

    return {
        Set = function(v)
            v = math.clamp(v, min, max)
            value = v
            local rel = (v-min)/(max-min)
            fill.Size = UDim2.new(rel,0,1,0)
            lbl.Text = string.format("%s  (%.2f)", text, value)
        end,
        Get = function() return value end
    }
end

local function button(parent, text, callback)
    local b = Instance.new("TextButton")
    b.Parent = parent
    b.Size = UDim2.new(1, 0, 0, 36)
    b.BackgroundColor3 = Theme.Bg
    b.AutoButtonColor = false
    b.Text = text
    b.TextColor3 = Theme.Text
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 14
    corner(b, 8); stroke(b, 1, 0.12)
    b.MouseEnter:Connect(function() b.BackgroundColor3 = Theme.Hover end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = Theme.Bg end)
    b.MouseButton1Click:Connect(function()
        if callback then
            local ok, err = pcall(callback)
            if not ok then warn("button cb error:", err) end
        end
    end)
    return b
end

local function listBox(parent, title, height)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, 0, 0, height or 220)
    frame.BackgroundColor3 = Theme.Bg
    corner(frame, 8); stroke(frame,1,0.12); padding(frame,8)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Text = title
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 14
    lbl.TextColor3 = Theme.Text
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local sc = Instance.new("ScrollingFrame", frame)
    sc.Position = UDim2.new(0, 0, 0, 24)
    sc.Size = UDim2.new(1, 0, 1, -28)
    sc.BackgroundTransparency = 1
    sc.ScrollBarThickness = 6
    local lay = vlist(sc, 4)

    local items = {}

    local function clear()
        for _, c in ipairs(sc:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        items = {}
    end

    local function addLine(text, ref)
        local line = Instance.new("Frame", sc)
        line.Size = UDim2.new(1, -8, 0, 26)
        line.BackgroundColor3 = Theme.Panel
        corner(line, 6); stroke(line,1,0.08); padding(line,6)
        local t = Instance.new("TextLabel", line)
        t.BackgroundTransparency = 1
        t.Text = text
        t.Font = Enum.Font.Gotham
        t.TextSize = 12
        t.TextColor3 = Theme.SubText
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Size = UDim2.new(1, 0, 1, 0)
        table.insert(items, {frame=line, text=text, ref=ref})
    end

    return {
        Clear = clear,
        Add = addLine,
        Items = function() return items end,
        Scroller = sc
    }
end

--== TABS ==--
local tCombat, pCombat = makeTab("Combat")
local tVisuals,pVisuals= makeTab("Visuals")
local tPlayer, pPlayer = makeTab("Player")
local tWorld,  pWorld  = makeTab("World")
local tHUD,    pHUD    = makeTab("HUD")
local tScanner,pScanner= makeTab("Scanner")
local tSettings,pSettings=makeTab("Settings")
pCombat.Visible = true

--== COMBAT ==--
section(pCombat, "Aimbot / Aim Assist")
toggle(pCombat, "Enable Aimbot", false, function(v) callFeature("ToggleAimbot", v) end)
toggle(pCombat, "Silent Aim",    false, function(v) callFeature("ToggleSilentAim", v) end)
toggle(pCombat, "Magic Bullet (Fallback)", false, function(v) callFeature("ToggleMagicBullet", v) end)
toggle(pCombat, "Headshot Redirect", false, function(v) callFeature("ToggleHeadshotRedirect", v) end)
toggle(pCombat, "Hard Fire Rate", false, function(v) callFeature("ToggleFireRate", v) end)
toggle(pCombat, "☠ Kill Aura", false, function(v) callFeature("ToggleKillAura", v) end)

section(pCombat, "Recoil / Spread")
toggle(pCombat, "No Recoil", false, function(v) callFeature("ToggleNoRecoil", v) end)
toggle(pCombat, "No Spread", false, function(v) callFeature("ToggleNoSpread", v) end)

--== VISUALS ==--
section(pVisuals, "ESP Package")
toggle(pVisuals, "Enable ESP", false, function(v) callFeature("ToggleESP", v) end)
toggle(pVisuals, "Glow / Highlight", false, function(v) callFeature("ToggleGlow", v) end)
toggle(pVisuals, "Skeleton", false, function(v) callFeature("ToggleSkeleton", v) end)
toggle(pVisuals, "2D Box (Corner)", false, function(v) callFeature("ToggleBox2D", v) end)
toggle(pVisuals, "3D Box", false, function(v) callFeature("ToggleBox3D", v) end)
toggle(pVisuals, "Tracers", false, function(v) callFeature("ToggleTracers", v) end)
toggle(pVisuals, "Offscreen Arrows", false, function(v) callFeature("ToggleOffscreenArrows", v) end)
toggle(pVisuals, "Rainbow Name", false, function(v) callFeature("ToggleRainbowName", v) end)

--== PLAYER ==--
section(pPlayer, "Local Movement")
slider(pPlayer, "WalkSpeed", 8, 64, 16, function(val) callFeature("SetWalkSpeed", val) end)
slider(pPlayer, "JumpPower", 20, 200, 50, function(val) callFeature("SetJumpPower", val) end)
toggle(pPlayer, "Fly", false, function(v) callFeature("ToggleFly", v) end)
toggle(pPlayer, "Noclip", false, function(v) callFeature("ToggleNoclip", v) end)

section(pPlayer, "Teleport (TPX/TPY/TPZ)")
local tpX = slider(pPlayer, "TP X", -10000, 10000, getFeatureField("TPX", 0), function(val) setFeatureField("TPX", math.floor(val)) end)
local tpY = slider(pPlayer, "TP Y", -10000, 10000, getFeatureField("TPY", 5), function(val) setFeatureField("TPY", math.floor(val)) end)
local tpZ = slider(pPlayer, "TP Z", -10000, 10000, getFeatureField("TPZ", 0), function(val) setFeatureField("TPZ", math.floor(val)) end)
button(pPlayer, "TP Now (HumanoidRootPart)", function()
    local char = LP.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local x = getFeatureField("TPX", tpX.Get())
        local y = getFeatureField("TPY", tpY.Get())
        local z = getFeatureField("TPZ", tpZ.Get())
        char.HumanoidRootPart.CFrame = CFrame.new(x,y,z)
    end
end)

--== WORLD ==--
section(pWorld, "World Tweaks")
toggle(pWorld, "Third Person", false, function(v) callFeature("ToggleThirdPerson", v) end)
toggle(pWorld, "Field of View Boost", false, function(v) callFeature("ToggleFOVBoost", v) end)
slider(pWorld, "Time of Day", 0, 24, 12, function(val) callFeature("SetTimeOfDay", val) end)

--== HUD (FPS / CPU? / GPU? / RAM) ==--
-- HUD widget (draggable) with rainbow underline
local HUD = Instance.new("Frame")
HUD.Name = "MYLF_HUD"
HUD.Parent = gui
HUD.Size = UDim2.new(0, 240, 0, 86)
HUD.Position = UDim2.new(0.78, 0, 0.12, 0)
HUD.BackgroundColor3 = Theme.Panel
corner(HUD, 10); stroke(HUD, 1, 0.15); padding(HUD, 8)

local HUDTitle = Instance.new("TextLabel", HUD)
HUDTitle.BackgroundTransparency = 1
HUDTitle.Size = UDim2.new(1, 0, 0, 18)
HUDTitle.TextXAlignment = Enum.TextXAlignment.Left
HUDTitle.Font = Enum.Font.GothamSemibold
HUDTitle.TextSize = 13
HUDTitle.TextColor3 = Theme.Text
HUDTitle.Text = "HUD • Performance"

local HUDBody = Instance.new("TextLabel", HUD)
HUDBody.BackgroundTransparency = 1
HUDBody.Position = UDim2.new(0,0,0,24)
HUDBody.Size = UDim2.new(1, 0, 1, -28)
HUDBody.TextXAlignment = Enum.TextXAlignment.Left
HUDBody.TextYAlignment = Enum.TextYAlignment.Top
HUDBody.Font = Enum.Font.Code
HUDBody.TextSize = 13
HUDBody.TextColor3 = Theme.SubText
HUDBody.Text = "FPS: --\nCPU: --\nGPU: --\nRAM: --"
HUDBody.LineHeight = 1.05

-- Rainbow underline
local Under = Instance.new("Frame", HUD)
Under.Name = "Underline"
Under.AnchorPoint = Vector2.new(0.5, 1)
Under.Position = UDim2.new(0.5,0,1,0)
Under.Size = UDim2.new(1, -12, 0, 3)
Under.BackgroundColor3 = Color3.fromRGB(255,255,255)
corner(Under, 3)
local grad = Instance.new("UIGradient", Under)
grad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0.0, Color3.fromHSV(0.0,1,1)),
    ColorSequenceKeypoint.new(0.2, Color3.fromHSV(0.2,1,1)),
    ColorSequenceKeypoint.new(0.4, Color3.fromHSV(0.4,1,1)),
    ColorSequenceKeypoint.new(0.6, Color3.fromHSV(0.6,1,1)),
    ColorSequenceKeypoint.new(0.8, Color3.fromHSV(0.8,1,1)),
    ColorSequenceKeypoint.new(1.0, Color3.fromHSV(1.0,1,1)),
}
grad.Rotation = 0

-- Drag HUD
do
    local dragging = false
    local dragStart, startPos
    HUD.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = HUD.Position
        end
    end)
    HUD.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local d = input.Position - dragStart
            HUD.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- HUD controls on page
section(pHUD, "HUD Controls")
toggle(pHUD, "Show HUD", true, function(v) HUD.Visible = v end)
slider(pHUD, "HUD Size", 160, 340, 240, function(val) HUD.Size = UDim2.new(0, math.floor(val), 0, 86) end)

-- HUD updater (FPS; RAM via Luau; 'CPU/GPU' approximations)
local accum, lastUpdate = 0, 0
local fpsCounter, fpsElapsed, fpsFrames = 0, 0, 0
RunService.RenderStepped:Connect(function(dt)
    -- animate gradient
    grad.Rotation = (grad.Rotation + 60*dt) % 360

    -- fps
    fpsElapsed += dt
    fpsFrames += 1
    if fpsElapsed >= HUD_UPDATE_INTERVAL then
        local fps = math.floor(fpsFrames / fpsElapsed + 0.5)
        fpsElapsed, fpsFrames = 0, 0

        -- RAM (Luau heap KB -> MB)
        local luaMB = collectgarbage("count")/1024
        -- total dev memory estimate (not exact)
        local devMem = 0
        local ok, mem = pcall(function()
            -- try several tags to get a rough sum
            local tags = Enum.DeveloperMemoryTag:GetEnumItems()
            local sum = 0
            for _, tag in ipairs(tags) do
                local mb = Stats:GetMemoryUsageMbForTag(tag)
                if type(mb) == "number" then sum += mb end
            end
            return sum
        end)
        if ok and type(mem)=="number" then devMem = mem end

        -- rough CPU load proxy using frame-time vs 60fps
        local framems = dt*1000
        local cpuLoadApprox = math.clamp((dt / (1/60)) * 100, 0, 300) -- %
        -- GPU 'proxy' = render share (cannot read true GPU); show frame ms
        local gpuProxy = string.format("%.1f ms", framems)

        HUDBody.Text = string.format("FPS: %d\nCPU: ~%.0f%% (proxy)\nGPU: %s (frame)\nRAM: Lua %.1f MB | Dev ~%.1f MB",
            fps, cpuLoadApprox, gpuProxy, luaMB, devMem)
    end
end)

--== SCANNER ==--
local lsPlayers = listBox(pScanner, "Players", 140)
local lsTools   = listBox(pScanner, "Tools (Workspace + Backpacks)", 180)
local lsItems   = listBox(pScanner, "Items (Common classes)", 180)

local actions = section(pScanner, "Actions")
button(pScanner, "Scan Now", function()
    -- Players
    lsPlayers.Clear()
    for _, pl in ipairs(Players:GetPlayers()) do
        local who = (pl == LP) and "(You)" or ""
        lsPlayers.Add(string.format("%s %s", pl.Name, who), pl)
    end

    -- Tools (in workspace and backpacks)
    lsTools.Clear()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") then
            local owner = obj.Parent and obj.Parent.Name or "?"
            lsTools.Add(string.format("[W] %s  (Parent: %s)", obj.Name, owner), obj)
        end
    end
    for _, pl in ipairs(Players:GetPlayers()) do
        local bp = pl:FindFirstChildOfClass("Backpack")
        if bp then
            for _, t in ipairs(bp:GetChildren()) do
                if t:IsA("Tool") then
                    lsTools.Add(string.format("[BP:%s] %s", pl.Name, t.Name), t)
                end
            end
        end
    end

    -- Items (common)
    lsItems.Clear()
    local classes = { "Part","MeshPart","UnionOperation","Model" }
    for _, obj in ipairs(workspace:GetDescendants()) do
        if table.find(classes, obj.ClassName) then
            lsItems.Add(string.format("[%s] %s", obj.ClassName, obj.Name), obj)
        end
    end
end)

local highlightState = {}
local function toggleHighlight(inst, on)
    if not inst or not inst:IsDescendantOf(game) then return end
    if on then
        if highlightState[inst] and highlightState[inst].Parent then return end
        local h = Instance.new("Highlight")
        h.FillTransparency = 1
        h.OutlineColor = Theme.Accent
        h.OutlineTransparency = 0
        h.Adornee = inst:IsA("Model") and inst or inst:FindFirstChildWhichIsA("Model") or inst
        h.Parent = inst
        highlightState[inst] = h
    else
        if highlightState[inst] then
            highlightState[inst]:Destroy()
            highlightState[inst] = nil
        end
    end
end

local scButtons = Instance.new("Frame", pScanner)
scButtons.Size = UDim2.new(1, 0, 0, 40)
scButtons.BackgroundTransparency = 1
local scGrid = Instance.new("UIGridLayout", scButtons)
scGrid.CellPadding = UDim2.new(0,8,0,8)
scGrid.CellSize    = UDim2.new(0.33, -10, 1, 0)

local function clickSelection(listObj, handler)
    for _, it in ipairs(listObj.Items()) do
        local btn = button(scButtons, "Do on: "..(it.text:sub(1, 24)..".."), function()
            handler(it.ref, it.text)
        end)
        btn.Size = UDim2.new(0,0,1,0) -- grid handles size
    end
end

-- Basic actions (local-only; no remote calls)
button(pScanner, "Highlight All (Players+Tools+Items)", function()
    for _, it in ipairs(lsPlayers.Items()) do
        local pl = it.ref
        if pl and pl.Character then toggleHighlight(pl.Character, true) end
    end
    for _, it in ipairs(lsTools.Items()) do
        toggleHighlight(it.ref, true)
    end
    for _, it in ipairs(lsItems.Items()) do
        toggleHighlight(it.ref, true)
    end
end)
button(pScanner, "Clear Highlights", function()
    for inst, h in pairs(highlightState) do
        if h then h:Destroy() end
    end
    highlightState = {}
end)
button(pScanner, "Teleport to Selected (pick below)", function()
    local picked = nil
    -- Pick the first (if any) by recreating quick buttons and storing last
    -- (Practical approach: user clicks a generated button under lists)
end)

-- Generate per-item quick buttons (safe, local)
local quickNote = section(pScanner, "Quick Apply (create buttons for current results)")
button(pScanner, "Build Quick Buttons For Players", function()
    scButtons:ClearAllChildren()
    clickSelection(lsPlayers, function(ref, txt)
        if typeof(ref)=="Instance" and ref:IsA("Player") and ref.Character and ref.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = ref.Character.HumanoidRootPart
            local my = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if my then my.CFrame = hrp.CFrame + Vector3.new(0,2,0) end
        end
    end)
end)
button(pScanner, "Build Quick Buttons For Tools", function()
    scButtons:ClearAllChildren()
    clickSelection(lsTools, function(ref, txt)
        if typeof(ref)=="Instance" then
            toggleHighlight(ref, true)
        end
    end)
end)
button(pScanner, "Build Quick Buttons For Items", function()
    scButtons:ClearAllChildren()
    clickSelection(lsItems, function(ref, txt)
        if typeof(ref)=="Instance" then
            toggleHighlight(ref, true)
        end
    end)
end)

-- Auto-scan toggle
local autoScanT = toggle(pScanner, "Auto-Scan (every "..SCAN_AUTO_INTERVAL.."s)", false, nil)
local lastScan = 0
RunService.Heartbeat:Connect(function(dt)
    if autoScanT.Get() then
        lastScan += dt
        if lastScan >= SCAN_AUTO_INTERVAL then
            lastScan = 0
            pcall(function()
                for _, b in ipairs(pScanner:GetChildren()) do
                    -- reuse the button "Scan Now"
                end
            end)
            -- call scan
            for _, c in ipairs(pScanner:GetChildren()) do
                if c:IsA("TextButton") and c.Text == "Scan Now" then
                    c:Activate()
                    break
                end
            end
        end
    end
end)

--== Exploit "Skeleton" (text-only; no execution) ==--
local sk = listBox(pScanner, "Exploit Skeleton (metin – uygulamaz)", 150)
sk.Clear()
sk.Add("- - hookmetamethod(game, '__namecall', function(self, ...))", nil)
sk.Add("- - if getnamecallmethod() == 'FireServer' then -- inspect args end", nil)
sk.Add("- - remote:InvokeServer('--params--')", nil)
sk.Add("- - obj.FireServer(obj, '--params--')", nil)
sk.Add("- - -- burada sadece İSKELET gösterimi var, gerçek çağrı yok", nil)

--== SETTINGS ==--
section(pSettings, "Theme")
local themeBtns = Instance.new("Frame", pSettings)
themeBtns.Size = UDim2.new(1,0,0,40)
themeBtns.BackgroundTransparency = 1
local grid = Instance.new("UIGridLayout", themeBtns)
grid.CellPadding = UDim2.new(0,8,0,8)
grid.CellSize = UDim2.new(0.33, -10, 1, 0)

for name,_ in pairs(Themes) do
    button(themeBtns, "Theme: "..name, function()
        CurrentThemeName = name
        Theme = Themes[name]
        -- simple recolor pass
        Window.BackgroundColor3 = Theme.Panel
        TitleBar.BackgroundColor3 = Theme.Bg
        Title.TextColor3 = Theme.Text
        HUD.BackgroundColor3 = Theme.Panel
        HUDTitle.TextColor3 = Theme.Text
        HUDBody.TextColor3 = Theme.SubText
    end)
end

section(pSettings, "Visibility Keybind")
local keyTxt = Instance.new("TextLabel", pSettings)
keyTxt.BackgroundTransparency = 1
keyTxt.TextXAlignment = Enum.TextXAlignment.Left
keyTxt.Font = Enum.Font.Gotham
keyTxt.TextSize = 14
keyTxt.TextColor3 = Theme.Text
keyTxt.Text = "Toggle Key: RightShift (click below and press a key)"
keyTxt.Size = UDim2.new(1,0,0,20)

local keyBtn = button(pSettings, "Click to set new toggle key", nil)
local currentToggleKey = Enum.KeyCode.RightShift
keyBtn.MouseButton1Click:Connect(function()
    keyTxt.Text = "Press any key..."
    local conn; conn = UserInputService.InputBegan:Connect(function(input,gp)
        if gp then return end
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            currentToggleKey = input.KeyCode
            keyTxt.Text = "Toggle Key: "..tostring(currentToggleKey)
            conn:Disconnect()
        end
    end)
end)

-- Window visibility
local visible = true
local function setVisible(v)
    visible = v
    Window.Visible = v
end
setVisible(true)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == currentToggleKey then
        setVisible(not visible)
    end
end)

-- Try to layer above ESC menu as much as possible
pcall(function()
    StarterGui:SetCore("TopbarEnabled", true)
end)

-- Default select first tab
tCombat:Activate()

-- Safety: If features module exposes an init, call once
callFeature("InitMYLF")
