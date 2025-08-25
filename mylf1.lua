--[[ 
    ⚡ MYLF Linoria+ Legit UI Framework (Client-Safe) + Senin Toggle Entegrasyonu + Crown FPS Panel (Rainbow alt çizgi)
    - Hile/remote/hook YOK. Sadece UI/UX ve HUD.
    - Aç/Kapa: LeftShift
]]

--// Services
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local HttpService        = game:GetService("HttpService")
local Stats              = game:GetService("Stats")

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

--// Utils
local function tween(o, ti, props, es, ed)
    return TweenService:Create(o, TweenInfo.new(ti, es or Enum.EasingStyle.Quad, ed or Enum.EasingDirection.Out), props)
end
local function round(n, p) p=p or 0 local m=10^p return math.floor(n*m+0.5)/m end
local function clamp(n,a,b) if n<a then return a elseif n>b then return b else return n end end
local function makeCorner(o, r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0, r or 8); c.Parent=o; return c end
local function makeStroke(o, th, tr) local s=Instance.new("UIStroke"); s.Thickness=th or 1; s.Transparency=tr or 0; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=o; return s end
local function pad(o, px) local p=Instance.new("UIPadding"); p.PaddingTop=UDim.new(0,px); p.PaddingBottom=UDim.new(0,px); p.PaddingLeft=UDim.new(0,px); p.PaddingRight=UDim.new(0,px); p.Parent=o; return p end

-- HSL -> Color3
local function hsl(h, s, l)
    local function f(n)
        local k=(n+h*12)%12
        local a=s*math.min(l,1-l)
        return l - a*math.max(-1, math.min(math.min(k-3, 9-k), 1))
    end
    return Color3.new(f(0), f(8), f(4))
end

--// Theme Engine
local Themes = {
    Dark = {
        Bg = Color3.fromRGB(20,20,26), Panel = Color3.fromRGB(28,28,36),
        Accent = Color3.fromRGB(120,115,245), AccentSoft = Color3.fromRGB(95,90,210),
        Text = Color3.fromRGB(238,238,245), SubText = Color3.fromRGB(170,170,178),
        Stroke = Color3.fromRGB(60,60,72), Hover = Color3.fromRGB(40,40,52),
        Green = Color3.fromRGB(110,210,130), Red = Color3.fromRGB(230,90,96), Yellow= Color3.fromRGB(245,209,66)
    },
    Midnight = {
        Bg = Color3.fromRGB(12,14,24), Panel = Color3.fromRGB(18,20,34),
        Accent = Color3.fromRGB(80,180,255), AccentSoft = Color3.fromRGB(60,140,210),
        Text = Color3.fromRGB(228,232,240), SubText = Color3.fromRGB(150,158,172),
        Stroke = Color3.fromRGB(40,48,66), Hover = Color3.fromRGB(26,30,46),
        Green = Color3.fromRGB(90,205,140), Red = Color3.fromRGB(230,90,110), Yellow= Color3.fromRGB(245,209,66)
    },
    Neon = {
        Bg = Color3.fromRGB(18,18,22), Panel = Color3.fromRGB(22,22,28),
        Accent = Color3.fromRGB(255,80,200), AccentSoft = Color3.fromRGB(210,60,160),
        Text = Color3.fromRGB(245,245,255), SubText = Color3.fromRGB(172,170,190),
        Stroke = Color3.fromRGB(70,60,90), Hover = Color3.fromRGB(40,34,60),
        Green = Color3.fromRGB(110,240,200), Red = Color3.fromRGB(255,100,140), Yellow= Color3.fromRGB(255,230,120)
    }
}
local CurrentTheme = Themes.Dark

--// Global state
local State = { Visible = true, Dragging = false, GlobalToggleKey = Enum.KeyCode.LeftShift }

--// Root GUIs
local Gui = Instance.new("ScreenGui")
Gui.Name = "MYLF_LinoriaPlus"
Gui.IgnoreGuiInset = true
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

local Overlay = Instance.new("ScreenGui")
Overlay.Name = "MYLF_HUD"
Overlay.IgnoreGuiInset = true
Overlay.ResetOnSpawn = false
Overlay.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Overlay.Parent = PlayerGui

-- Notification layer
local NotifLayer = Instance.new("Frame")
NotifLayer.BackgroundTransparency = 1
NotifLayer.Size = UDim2.new(1,0,1,0)
NotifLayer.Parent = Gui
local function notify(text, dur)
    dur = dur or 2.2
    local t = Instance.new("TextLabel")
    t.Text = "  "..text
    t.Font = Enum.Font.GothamSemibold
    t.TextSize = 14
    t.TextColor3 = CurrentTheme.Text
    t.BackgroundColor3 = CurrentTheme.Panel
    t.Size = UDim2.fromOffset(0,28)
    t.AnchorPoint = Vector2.new(1,0); t.Position = UDim2.new(1,-10,0,10)
    t.Parent = NotifLayer
    makeCorner(t,6); makeStroke(t,1,.1)
    tween(t,.18,{Size=UDim2.fromOffset(math.clamp(t.TextBounds.X+22, 160, 520), 28)}):Play()
    task.delay(dur, function()
        local tw = tween(t,.18,{Position=UDim2.new(1,-10,0,-34), BackgroundTransparency=1})
        tw.Completed:Connect(function() t:Destroy() end); tw:Play()
    end)
end

--// Main Window
local Window = Instance.new("Frame")
Window.Name = "Window"
Window.Size = UDim2.new(0, 760, 0, 470)
Window.Position = UDim2.new(0.5, -380, 0.5, -235)
Window.BackgroundColor3 = CurrentTheme.Bg
Window.Active = true
Window.Parent = Gui
makeCorner(Window, 10); makeStroke(Window, 1, .2)

-- Dragging
do
    local dragStart, startPos
    Window.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            State.Dragging = true; dragStart = input.Position; startPos = Window.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then State.Dragging = false end
            end)
        end
    end)
    Window.InputChanged:Connect(function(input)
        if State.Dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
            local d = input.Position - dragStart
            Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- TitleBar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1,0,0,44)
TitleBar.BackgroundColor3 = CurrentTheme.Panel
TitleBar.Parent = Window
makeCorner(TitleBar, 10); makeStroke(TitleBar,1,.1)
local Title = Instance.new("TextLabel")
Title.BackgroundTransparency=1; Title.Text="⚡ MYLF | Linoria+ (Legit UI)"; Title.Font=Enum.Font.GothamBold; Title.TextSize=16
Title.TextColor3=CurrentTheme.Text; Title.TextXAlignment=Enum.TextXAlignment.Left; Title.Position=UDim2.new(0,14,0,0); Title.Size=UDim2.new(1,-160,1,0)
Title.Parent=TitleBar

-- Theme button
local ThemeBtn = Instance.new("TextButton")
ThemeBtn.AutoButtonColor=false; ThemeBtn.Text="Theme: Dark"; ThemeBtn.Font=Enum.Font.GothamSemibold; ThemeBtn.TextSize=13
ThemeBtn.TextColor3=CurrentTheme.Text; ThemeBtn.BackgroundColor3=CurrentTheme.Hover
ThemeBtn.AnchorPoint=Vector2.new(1,0.5); ThemeBtn.Position=UDim2.new(1,-10,0.5,0); ThemeBtn.Size=UDim2.new(0,140,0,26)
ThemeBtn.Parent=TitleBar; makeCorner(ThemeBtn,6); makeStroke(ThemeBtn,1,.15)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.BackgroundColor3=CurrentTheme.Panel; Sidebar.Position=UDim2.new(0,10,0,60); Sidebar.Size=UDim2.new(0,170,1,-70); Sidebar.Parent=Window
makeCorner(Sidebar,8); makeStroke(Sidebar,1,.08); pad(Sidebar,8)
local SideList = Instance.new("UIListLayout", Sidebar); SideList.Padding = UDim.new(0,8)

local function makeTabButton(text, icon)
    local b=Instance.new("TextButton"); b.AutoButtonColor=false; b.Text=(icon and (icon.."  ") or "")..text
    b.Font=Enum.Font.GothamSemibold; b.TextSize=14; b.TextColor3=CurrentTheme.Text; b.BackgroundColor3=CurrentTheme.Hover
    b.Size=UDim2.new(1,-4,0,34); b.Parent=Sidebar; makeCorner(b,6); makeStroke(b,1,.2)
    b.MouseEnter:Connect(function() tween(b,.08,{BackgroundColor3=CurrentTheme.AccentSoft}):Play() end)
    b.MouseLeave:Connect(function() tween(b,.12,{BackgroundColor3=CurrentTheme.Hover}):Play() end)
    return b
end

-- Content
local Content = Instance.new("Frame")
Content.BackgroundTransparency=1; Content.Position=UDim2.new(0,190,0,60); Content.Size=UDim2.new(1,-200,1,-70); Content.Parent=Window

-- Pages
local Pages = {}
local function newPage(name)
    local p=Instance.new("Frame"); p.Visible=false; p.BackgroundColor3=CurrentTheme.Panel; p.Size=UDim2.new(1,0,1,0); p.Parent=Content
    makeCorner(p,8); makeStroke(p,1,.08); pad(p,10)
    local list=Instance.new("UIListLayout", p); list.Padding=UDim.new(0,10); list.FillDirection=Enum.FillDirection.Horizontal
    Pages[name]=p; return p
end

local function newSection(parent, title)
    local s=Instance.new("Frame"); s.BackgroundColor3=CurrentTheme.Bg; s.Size=UDim2.new(0.5,-8,1,-0); s.Parent=parent
    makeCorner(s,8); makeStroke(s,1,.08); pad(s,10)
    local t=Instance.new("TextLabel"); t.BackgroundTransparency=1; t.Text=title; t.Font=Enum.Font.GothamBold; t.TextSize=14; t.TextColor3=CurrentTheme.Text; t.Size=UDim2.new(1,0,0,18); t.Parent=s
    local list=Instance.new("UIListLayout", s); list.Padding=UDim.new(0,8)
    return s
end

-- Controls factory
local Controls = {}

local function makeRow(parent, label)
    local f=Instance.new("Frame"); f.BackgroundTransparency=1; f.Size=UDim2.new(1,0,0,28); f.Parent=parent
    local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Text=label; l.Font=Enum.Font.Gotham; l.TextSize=13
    l.TextXAlignment=Enum.TextXAlignment.Left; l.TextColor3=CurrentTheme.SubText; l.Size=UDim2.new(0.46,0,1,0); l.Parent=f
    return f,l
end

function Controls.Toggle(parent, label, default, callback)
    local row,lab = makeRow(parent,label)
    local btn = Instance.new("TextButton")
    btn.AutoButtonColor=false; btn.Text= default and "ON" or "OFF"
    btn.Font=Enum.Font.GothamBold; btn.TextSize=12
    btn.TextColor3 = default and CurrentTheme.Green or CurrentTheme.Red
    btn.BackgroundColor3=CurrentTheme.Hover; btn.Size=UDim2.new(0,78,0,24)
    btn.Position=UDim2.new(1,-88,0.5,-12); btn.Parent=row
    makeCorner(btn,6); makeStroke(btn,1,.2)
    local on = default or false
    btn.MouseButton1Click:Connect(function()
        on = not on
        btn.Text = on and "ON" or "OFF"
        btn.TextColor3 = on and CurrentTheme.Green or CurrentTheme.Red
        tween(btn,.08,{BackgroundColor3 = on and CurrentTheme.AccentSoft or CurrentTheme.Hover}):Play()
        if callback then task.spawn(callback, on) end
    end)
    return {
        Set=function(v) on=v; btn.Text=v and "ON" or "OFF"; btn.TextColor3=v and CurrentTheme.Green or CurrentTheme.Red; if callback then callback(v) end end,
        Get=function() return on end
    }
end

function Controls.Slider(parent, label, min, max, default, fmt, callback)
    local row,lab = makeRow(parent,label)
    local frame=Instance.new("Frame"); frame.Size=UDim2.new(0.52,0,0,24); frame.Position=UDim2.new(0.46,0,0.5,-12); frame.BackgroundColor3=CurrentTheme.Hover; frame.Parent=row
    makeCorner(frame,6); makeStroke(frame,1,.15)
    local fill=Instance.new("Frame"); fill.BackgroundColor3=CurrentTheme.Accent; fill.Size=UDim2.new((default-min)/(max-min),0,1,0); fill.Parent=frame; makeCorner(fill,6)
    local val=default or min
    local valText=Instance.new("TextLabel"); valText.BackgroundTransparency=1; valText.TextColor3=CurrentTheme.Text; valText.Font=Enum.Font.GothamSemibold; valText.TextSize=12
    valText.Size=UDim2.new(0,60,1,0); valText.AnchorPoint=Vector2.new(1,0); valText.Position=UDim2.new(1,-6,0,0); valText.Parent=frame; valText.Text=(fmt or "%d"):format(val)
    local dragging=false
    local function setFromX(x)
        local rel=clamp((x-frame.AbsolutePosition.X)/frame.AbsoluteSize.X,0,1)
        val = round(min + (max-min)*rel, 2)
        fill.Size=UDim2.new((val-min)/(max-min),0,1,0)
        valText.Text=(fmt or "%d"):format(val)
        if callback then callback(val) end
    end
    frame.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; setFromX(input.Position.X) end end)
    frame.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then setFromX(input.Position.X) end end)
    return { Get=function() return val end, Set=function(v) val=clamp(v,min,max); fill.Size=UDim2.new((val-min)/(max-min),0,1,0); valText.Text=(fmt or "%d"):format(val); if callback then callback(val) end end }
end

-- Pages & Tabs
local pPlayer   = newPage("Player")
local pVisuals  = newPage("Visuals")
local pHUD      = newPage("HUD")
local pSettings = newPage("Settings")

local tPlayer   = makeTabButton("Player","👤")
local tVisuals  = makeTabButton("Visuals","🎨")
local tHUD      = makeTabButton("HUD","🧭")
local tSettings = makeTabButton("Settings","⚙️")

local function showPage(name) for k,f in pairs(Pages) do f.Visible=(k==name) end end
showPage("Player")
tPlayer.MouseButton1Click:Connect(function() showPage("Player") end)
tVisuals.MouseButton1Click:Connect(function() showPage("Visuals") end)
tHUD.MouseButton1Click:Connect(function() showPage("HUD") end)
tSettings.MouseButton1Click:Connect(function() showPage("Settings") end)

--========================
-- CROSSHAIR (kozmetik)
--========================
local Crosshair = Instance.new("Frame")
Crosshair.Name="Crosshair"; Crosshair.AnchorPoint=Vector2.new(0.5,0.5); Crosshair.Position=UDim2.fromScale(0.5,0.5)
Crosshair.Size=UDim2.fromOffset(2,2); Crosshair.BackgroundTransparency=1; Crosshair.Parent=Overlay

local CrosshairCfg = { Enabled=true, Gap=6, Length=8, Thickness=2, Opacity=1, Color=Themes.Dark.Accent }
local arms={}
for i=1,4 do local a=Instance.new("Frame"); a.BorderSizePixel=0; a.Parent=Crosshair; arms[i]=a end
local function layoutCrosshair()
    for _,a in ipairs(arms) do a.BackgroundTransparency=1-CrosshairCfg.Opacity; a.BackgroundColor3=CrosshairCfg.Color end
    arms[1].Size=UDim2.fromOffset(CrosshairCfg.Thickness, CrosshairCfg.Length); arms[1].Position=UDim2.fromOffset(-CrosshairCfg.Thickness/2, -(CrosshairCfg.Gap+CrosshairCfg.Length))
    arms[2].Size=UDim2.fromOffset(CrosshairCfg.Thickness, CrosshairCfg.Length); arms[2].Position=UDim2.fromOffset(-CrosshairCfg.Thickness/2, CrosshairCfg.Gap)
    arms[3].Size=UDim2.fromOffset(CrosshairCfg.Length, CrosshairCfg.Thickness); arms[3].Position=UDim2.fromOffset(-(CrosshairCfg.Gap+CrosshairCfg.Length), -CrosshairCfg.Thickness/2)
    arms[4].Size=UDim2.fromOffset(CrosshairCfg.Length, CrosshairCfg.Thickness); arms[4].Position=UDim2.fromOffset(CrosshairCfg.Gap, -CrosshairCfg.Thickness/2)
    Crosshair.Visible = CrosshairCfg.Enabled
end
layoutCrosshair()

--========================
-- CROWN FPS PANEL + Rainbow underline
--========================
local CrownPanel = Instance.new("Frame")
CrownPanel.Name="CrownFPS"
CrownPanel.AnchorPoint = Vector2.new(0.5,0)       -- üstte ortalı
CrownPanel.Position = UDim2.new(0.5, 0, 0, 8)
CrownPanel.Size = UDim2.fromOffset(260, 30)
CrownPanel.BackgroundColor3 = Color3.fromRGB(234, 198, 76) -- crown altın
CrownPanel.Parent = Overlay
makeCorner(CrownPanel, 8)
makeStroke(CrownPanel, 1, .15)
pad(CrownPanel, 6)

local CrownText = Instance.new("TextLabel")
CrownText.BackgroundTransparency=1
CrownText.Font = Enum.Font.GothamBold
CrownText.TextSize = 14
CrownText.TextColor3 = Color3.fromRGB(20,20,25)
CrownText.TextXAlignment = Enum.TextXAlignment.Center
CrownText.Size = UDim2.new(1, -12, 1, -10)
CrownText.Position = UDim2.fromOffset(6, 2)
CrownText.Parent = CrownPanel
CrownText.Text = "FPS: --  |  Ping: --"

-- Alt kısımda rainbow hareketli çizgi
local RainbowBar = Instance.new("Frame")
RainbowBar.BorderSizePixel=0
RainbowBar.AnchorPoint = Vector2.new(0.5,1)
RainbowBar.Position = UDim2.new(0.5,0,1,0)
RainbowBar.Size = UDim2.new(1,-8,0,3)
RainbowBar.Parent = CrownPanel
makeCorner(RainbowBar, 2)

local grad = Instance.new("UIGradient")
grad.Rotation = 0
grad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,0,0)),
    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,127,0)),
    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255,255,0)),
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,255,0)),
    ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0,127,255)),
    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(139,0,255)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,0,127))
}
grad.Parent = RainbowBar

-- Rainbow akış animasyonu
task.spawn(function()
    local t=0
    while RainbowBar.Parent do
        t += RunService.RenderStepped:Wait()
        grad.Offset = Vector2.new(math.sin(t*0.8)*0.25, 0) -- sağa-sola akış
    end
end)

-- FPS/Ping hesapla ve panele sığdır
local fps, dtA, dtC = 60, 0, 0
RunService.RenderStepped:Connect(function(dt)
    dtA += dt; dtC += 1
    if dtA >= 0.5 then
        fps = round(dtC/dtA,0)
        dtA, dtC = 0, 0
        local ping="?"
        pcall(function()
            local item=Stats.Network.ServerStatsItem["Data Ping"]
            if item then ping = tostring(item:GetValueString()):gsub(" RTT","") end
        end)
        CrownText.Text = ("FPS: %s  |  Ping: %s"):format(fps, ping)

        -- Metne göre otomatik genişlik (çok kısaysa uzat)
        local need = CrownText.TextBounds.X + 40
        local targetW = math.clamp(need, 220, 520)
        tween(CrownPanel,.12,{Size=UDim2.fromOffset(targetW, 30)}):Play()
        RainbowBar.Size = UDim2.new(1, -8, 0, 3)
    end
end)

--========================
-- Player / Visuals / HUD / Settings
--========================
local sMovement = newSection(pPlayer, "Movement / Camera")
local sTools    = newSection(pPlayer, "Utilities")

-- FOV slider (meşru)
Controls.Slider(sMovement, "Field of View", 60, 100, Camera.FieldOfView, "%d", function(v) Camera.FieldOfView = v end)

-- Crosshair ayarları (Visuals)
local sCross = newSection(pVisuals, "Crosshair")
local sTheme = newSection(pVisuals, "Theme / Colors")

local crossToggle = Controls.Toggle(sCross, "Enable Crosshair", true, function(on) CrosshairCfg.Enabled=on; layoutCrosshair() end)
Controls.Slider(sCross, "Gap", 0, 30, CrosshairCfg.Gap, "%d", function(v) CrosshairCfg.Gap=v; layoutCrosshair() end)
Controls.Slider(sCross, "Length", 2, 40, CrosshairCfg.Length, "%d", function(v) CrosshairCfg.Length=v; layoutCrosshair() end)
Controls.Slider(sCross, "Thickness", 1, 8, CrosshairCfg.Thickness, "%d", function(v) CrosshairCfg.Thickness=v; layoutCrosshair() end)
Controls.Slider(sCross, "Opacity", 0, 1, CrosshairCfg.Opacity, "%.2f", function(v) CrosshairCfg.Opacity=v; layoutCrosshair() end)

--========================
-- SENİN İSTEDİĞİN TOGGLE LİSTESİ (UI-only / legit)
-- Aynı "bindToggle(...)" mantığı yerine doğrudan bizim Toggle komponenti:
--========================
local sMYLF_Left  = newSection(pHUD, "MYLF Toggles (UI)")
local sMYLF_Right = newSection(pHUD, "Offsets / Sliders")

-- Toggle’lar: sadece UI state (oyun mekaniği YOK)
local toggles = {}

local function addToggle(where, key, title)
    toggles[key] = Controls.Toggle(where, title, false, function(on)
        -- burası sadece UI state; istersen log/notify:
        -- notify(title..": "..(on and "ON" or "OFF"))
        -- örnek: "esp" için sadece client etiketi düşünüyorsan, burada kendi HUD overlay’ine bağlayabilirsin.
    end)
end

-- Attığın isimlerle birebir (başlıklar korunuyor), fakat UI-only:
addToggle(sMYLF_Left, "aimbot",           "Enable Aimbot")
addToggle(sMYLF_Left, "headshotRedirect", "Force Headshot")
addToggle(sMYLF_Left, "killAura",         "☠️ Kill Aura")
addToggle(sMYLF_Left, "esp",              "Enable ESP")
addToggle(sMYLF_Left, "enemyBigHB",       "🎯 Enemy Big Hitbox")
addToggle(sMYLF_Left, "speed",            "Speed Boost (50)")
addToggle(sMYLF_Left, "fly",              "Fly (LCtrl down)")
addToggle(sMYLF_Left, "infjump",          "Infinite Jump")
addToggle(sMYLF_Left, "godmode",          "💀 Godmode")
addToggle(sMYLF_Left, "hardInvis",        "👻 Hard Invisible")
addToggle(sMYLF_Left, "noclip",           "NoClip")
addToggle(sMYLF_Left, "fireRate",         "Hard Fire Rate")
addToggle(sMYLF_Left, "tpkey",            "Teleport (T Key)")
addToggle(sMYLF_Left, "autoBehind",       "⚡ Always Behind Enemy")
addToggle(sMYLF_Left, "autoTP",           "⚡ Auto Farm Enemy")

-- Slider’lar (tpX/Y/Z adları korunuyor). UI’da HUD offset/scale’e mapliyoruz:
local hudOffX, hudOffY, hudScale = 0, 0, 1.0
local function applyHudTransform()
    CrownPanel.Position = UDim2.new(0.5, hudOffX, 0, 8 + hudOffY)
    CrownPanel.Size = UDim2.fromOffset(CrownPanel.Size.X.Offset * hudScale, 30)
end

local s_tpX = Controls.Slider(sMYLF_Right, "X Offset", -50, 50, 0, "%d", function(v) hudOffX=v; applyHudTransform() end)
local s_tpY = Controls.Slider(sMYLF_Right, "Y Offset", -50, 50, 0, "%d", function(v) hudOffY=v; applyHudTransform() end)
local s_tpZ = Controls.Slider(sMYLF_Right, "HUD Scale", 0.5, 2.0, 1.0, "%.2f", function(v) hudScale=v; applyHudTransform() end)

--========================
-- Settings: Global toggle hint
--========================
local sMeta = newSection(pSettings, "Meta")
local GlobalHint = Instance.new("TextLabel")
GlobalHint.BackgroundTransparency=1
GlobalHint.Text="Global Toggle: LeftShift (gizle/göster)"
GlobalHint.Font=Enum.Font.Gotham; GlobalHint.TextSize=13; GlobalHint.TextColor3=Themes.Dark.SubText
GlobalHint.Size=UDim2.new(1,0,0,18); GlobalHint.Parent=sMeta

-- Theme cycle
local themeOrder = {"Dark","Midnight","Neon"}; local themeIndex=1
local function repaintTheme(t)
    Window.BackgroundColor3=t.Bg; TitleBar.BackgroundColor3=t.Panel; Title.TextColor3=t.Text
    ThemeBtn.TextColor3=t.Text; ThemeBtn.BackgroundColor3=t.Hover
    Sidebar.BackgroundColor3=t.Panel
    for _,b in ipairs(Sidebar:GetChildren()) do if b:IsA("TextButton") then b.TextColor3=t.Text; b.BackgroundColor3=t.Hover end end
    for _,p in pairs(Pages) do p.BackgroundColor3=t.Panel; for _,sec in ipairs(p:GetChildren()) do if sec:IsA("Frame") and sec~=p then sec.BackgroundColor3=t.Bg end end end
end
local function setThemeByName(name) CurrentTheme=Themes[name] or Themes.Dark; repaintTheme(CurrentTheme) end
ThemeBtn.MouseButton1Click:Connect(function() themeIndex = themeIndex % #themeOrder + 1; local n=themeOrder[themeIndex]; ThemeBtn.Text="Theme: "..n; setThemeByName(n); notify("Tema: "..n) end)
setThemeByName("Dark")

-- Global key
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == State.GlobalToggleKey then
        State.Visible = not State.Visible
        Window.Visible = State.Visible
        notify(State.Visible and "Menü gösterildi." or "Menü gizlendi.")
    end
end)

-- Başlangıç toast
notify("MYLF Linoria+ yüklendi. LeftShift ile gizle/göster. Crown FPS panel aktif.", 3.0)
