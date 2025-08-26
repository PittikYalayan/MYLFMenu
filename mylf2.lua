


--[[ 
  ⚡ MYLF | UI (Client-Safe) — Full Source (Sections + Safe Feature Bridge + 2-Column Scanner)
  - UI/QoL odaklı. Haksız avantaj veren çağrılar engellenir.
  - Toggle’lar kısım kısım: Combat / Visuals / Movement / Protection / Utility.
  - Scanner iki sütun, slider drag > pencere drag çakışması fix (drag sadece TitleBar’dan).
  - Themes: Dark / Midnight / Neon / Black / Red (+ rainbow micro-accent).
]]

--========================
-- Features Köprüsü
--========================
local features = {}
do
    local ok, mod = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features9.8.lua"))()
    end)
    features = ok and mod or {}
end

-- Sadece UI-safe olanlara izin veriyorum.
-- İzinli köprü metodları (UI güvenliği)
local ALLOW = {
    SetTeleportOffset = true,
    ToggleHUDPanel    = true,
    ToggleCrosshair   = true,

    -- aşağıdakiler listede dursun ama devre dışı (UI-safe kalıyoruz)
    ToggleAimbot             = true,
    ToggleSilentAim          = true,
    ToggleKillAura           = true,
    ToggleFireRate           = true,
    ToggleESP                = true,
    ToggleEnemyBigHitbox     = true,
    ToggleSpeed              = true,
    ToggleFly                = true,
    ToggleInfiniteJump       = true,
    ToggleNoclip             = true,
    ToggleGodmode            = true,
    ToggleHardInvisible      = true,
    ToggleTeleport           = true,
    ToggleAutoBehind         = true,
    ToggleAutoTeleportToEnemy= true,
    Togglemyhitbox           = true,
}


local function safeCall(fname, ...)
    local fn = features and features[fname]
    if ALLOW[fname] and type(fn) == "function" then
        local ok, err = pcall(fn, ...)
        if not ok then warn("[features."..fname.."] "..tostring(err)) end
    else
        -- engellenen istekleri bus’a haber ver
        local RS = game:GetService("ReplicatedStorage")
        local BUS = RS:FindFirstChild("MYLF_FeatureBus") or Instance.new("Folder", RS); BUS.Name = "MYLF_FeatureBus"
        local ev = BUS:FindFirstChild("blocked_feature") or (function() local b=Instance.new("BindableEvent"); b.Name="blocked_feature"; b.Parent=BUS; return b end)()
        ev:Fire(fname)
    end
end

--========================
-- Services / Utils
--========================
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Stats            = game:GetService("Stats")

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

local function tween(o,ti,props) return TweenService:Create(o, TweenInfo.new(ti, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props) end
local function makeCorner(o,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=o; return c end
local function makeStroke(o,th,tr) local s=Instance.new("UIStroke"); s.Thickness=th or 1; s.Transparency=tr or 0; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=o; return s end
local function pad(o,px) local p=Instance.new("UIPadding"); p.PaddingTop=UDim.new(0,px); p.PaddingBottom=UDim.new(0,px); p.PaddingLeft=UDim.new(0,px); p.PaddingRight=UDim.new(0,px); p.Parent=o; return p end

--========================
-- Theme
--========================
local Themes = {
  Dark     = {Bg=Color3.fromRGB(20,20,26),  Panel=Color3.fromRGB(28,28,36),  Hover=Color3.fromRGB(40,40,52),  Accent=Color3.fromRGB(120,115,245), Text=Color3.fromRGB(238,238,245), Sub=Color3.fromRGB(170,170,178), Crown=Color3.fromRGB(234,198,76)},
  Midnight = {Bg=Color3.fromRGB(12,14,24),  Panel=Color3.fromRGB(18,20,34),  Hover=Color3.fromRGB(26,30,46),  Accent=Color3.fromRGB(80,180,255),  Text=Color3.fromRGB(228,232,240), Sub=Color3.fromRGB(150,158,172), Crown=Color3.fromRGB(48,62,110)},
  Neon     = {Bg=Color3.fromRGB(18,18,22),  Panel=Color3.fromRGB(22,22,28),  Hover=Color3.fromRGB(40,34,60),  Accent=Color3.fromRGB(255,80,200),  Text=Color3.fromRGB(245,245,255), Sub=Color3.fromRGB(172,170,190), Crown=Color3.fromRGB(45,25,60)},
  Black    = {Bg=Color3.fromRGB(6,6,8),     Panel=Color3.fromRGB(14,14,18),  Hover=Color3.fromRGB(24,24,30),  Accent=Color3.fromRGB(220,220,230), Text=Color3.fromRGB(240,240,245), Sub=Color3.fromRGB(160,162,170), Crown=Color3.fromRGB(28,28,34)},
  Red      = {Bg=Color3.fromRGB(24,8,10),   Panel=Color3.fromRGB(32,10,12),  Hover=Color3.fromRGB(46,16,20),  Accent=Color3.fromRGB(230,66,80),   Text=Color3.fromRGB(250,240,242), Sub=Color3.fromRGB(200,150,156), Crown=Color3.fromRGB(76,18,24)},
}
local CurrentTheme = Themes.Dark

--========================
-- Root GUIs + Window (drag sadece TitleBar’dan)
--========================
local Gui = Instance.new("ScreenGui")
Gui.Name="MYLF_UI"; Gui.IgnoreGuiInset=true; Gui.ResetOnSpawn=false; Gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; Gui.DisplayOrder=1000; Gui.Parent=PlayerGui

local NotifLayer = Instance.new("Frame"); NotifLayer.BackgroundTransparency=1; NotifLayer.Size=UDim2.new(1,0,1,0); NotifLayer.Parent=Gui
local function notify(txt, dur)
  dur=dur or 2.2
  local t=Instance.new("TextLabel"); t.BackgroundColor3=CurrentTheme.Panel; t.TextColor3=CurrentTheme.Text; t.Text="  "..txt
  t.Font=Enum.Font.GothamSemibold; t.TextSize=13; t.AnchorPoint=Vector2.new(1,0); t.Position=UDim2.new(1,-10,0,10); t.Size=UDim2.new(0,0,0,26); t.Parent=NotifLayer
  makeCorner(t,6); makeStroke(t,1,.12); tween(t,.14,{Size=UDim2.new(0, math.clamp(t.TextBounds.X+20,160,520),0,26)}):Play()
  task.delay(dur,function() tween(t,.16,{Position=UDim2.new(1,-10,0,-30),BackgroundTransparency=1}):Play(); task.delay(.18,function() t:Destroy() end) end)
end

local Window = Instance.new("Frame")
Window.Size=UDim2.new(0,860,0,520); Window.Position=UDim2.new(.5,-430,.5,-260); Window.BackgroundColor3=CurrentTheme.Bg; Window.Active=true; Window.Parent=Gui
makeCorner(Window,10); makeStroke(Window,1,.2)

local TitleBar=Instance.new("Frame"); TitleBar.Size=UDim2.new(1,0,0,44); TitleBar.BackgroundColor3=CurrentTheme.Panel; TitleBar.Parent=Window
makeCorner(TitleBar,10); makeStroke(TitleBar,1,.12)
local Title=Instance.new("TextLabel"); Title.BackgroundTransparency=1; Title.Text="⚡ MYLF | UI (Client-Safe)"; Title.Font=Enum.Font.GothamBold; Title.TextSize=16
Title.TextColor3=CurrentTheme.Text; Title.TextXAlignment=Enum.TextXAlignment.Left; Title.Position=UDim2.new(0,14,0,0); Title.Size=UDim2.new(1,-250,1,0); Title.Parent=TitleBar
local ThemeBtn=Instance.new("TextButton"); ThemeBtn.AutoButtonColor=false; ThemeBtn.Text="Theme: Dark"; ThemeBtn.Font=Enum.Font.GothamSemibold; ThemeBtn.TextSize=13
ThemeBtn.TextColor3=CurrentTheme.Text; ThemeBtn.BackgroundColor3=CurrentTheme.Hover; ThemeBtn.AnchorPoint=Vector2.new(1,.5); ThemeBtn.Position=UDim2.new(1,-10,.5,0)
ThemeBtn.Size=UDim2.new(0,160,0,26); ThemeBtn.Parent=TitleBar; makeCorner(ThemeBtn,6); makeStroke(ThemeBtn,1,.15)

-- drag ONLY from titlebar (slider sürüklerken menü kaymaz)
do
  local dragging, start, init
  TitleBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; start=i.Position; init=Window.Position end end)
  TitleBar.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
  TitleBar.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
    local d=i.Position-start; Window.Position=UDim2.new(init.X.Scale, init.X.Offset+d.X, init.Y.Scale, init.Y.Offset+d.Y) end end)
end

-- top rainbow accent
local TitleRB=Instance.new("Frame"); TitleRB.Size=UDim2.new(1,-12,0,2); TitleRB.Position=UDim2.new(0,6,1,-2); TitleRB.BorderSizePixel=0; TitleRB.Parent=TitleBar
local trGrad=Instance.new("UIGradient"); trGrad.Rotation=0; trGrad.Color=ColorSequence.new{
  ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,0,0)),
  ColorSequenceKeypoint.new(0.20, Color3.fromRGB(255,128,0)),
  ColorSequenceKeypoint.new(0.40, Color3.fromRGB(255,255,0)),
  ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0,255,0)),
  ColorSequenceKeypoint.new(0.80, Color3.fromRGB(0,128,255)),
  ColorSequenceKeypoint.new(1.00, Color3.fromRGB(140,0,255))
}; trGrad.Parent=TitleRB
RunService.RenderStepped:Connect(function() trGrad.Offset = Vector2.new(math.sin(os.clock()*0.8)*0.25, 0) end)

--========================
-- Sidebar / Pages
--========================
local Sidebar=Instance.new("Frame"); Sidebar.BackgroundColor3=CurrentTheme.Panel; Sidebar.Position=UDim2.new(0,10,0,58)
Sidebar.Size=UDim2.new(0,200,1,-68); Sidebar.Parent=Window; makeCorner(Sidebar,8); makeStroke(Sidebar,1,.1); pad(Sidebar,8)
local SideList=Instance.new("UIListLayout", Sidebar); SideList.Padding=UDim.new(0,8)

local function tabButton(txt,icon)
  local b=Instance.new("TextButton"); b.AutoButtonColor=false; b.Text=(icon and (icon.."  ") or "")..txt; b.Font=Enum.Font.GothamSemibold; b.TextSize=14
  b.TextColor3=CurrentTheme.Text; b.BackgroundColor3=CurrentTheme.Hover; b.Size=UDim2.new(1,-4,0,34); b.Parent=Sidebar; makeCorner(b,6); makeStroke(b,1,.15)
  b.MouseEnter:Connect(function() tween(b,.08,{BackgroundColor3=CurrentTheme.Accent}):Play() end)
  b.MouseLeave:Connect(function() tween(b,.12,{BackgroundColor3=CurrentTheme.Hover}):Play() end)
  return b
end

local Content=Instance.new("Frame"); Content.BackgroundTransparency=1; Content.Position=UDim2.new(0,220,0,58); Content.Size=UDim2.new(1,-230,1,-68); Content.Parent=Window
local Pages={}
local function pageDefault(name)
  local p=Instance.new("Frame"); p.Visible=false; p.BackgroundColor3=CurrentTheme.Panel; p.Size=UDim2.new(1,0,1,0); p.Parent=Content
  makeCorner(p,8); makeStroke(p,1,.1); pad(p,10)
  local grid=Instance.new("UIGridLayout", p); grid.CellPadding=UDim2.new(0,10,0,10); grid.CellSize=UDim2.new(.5,-5,1,-10)
  Pages[name]=p; return p
end
local function pageFree(name) -- özel düzen (Scanner için)
  local p=Instance.new("Frame"); p.Visible=false; p.BackgroundColor3=CurrentTheme.Panel; p.Size=UDim2.new(1,0,1,0); p.Parent=Content
  makeCorner(p,8); makeStroke(p,1,.1); pad(p,10); Pages[name]=p; return p
end
local function section(parent, title)
  local s=Instance.new("Frame"); s.BackgroundColor3=CurrentTheme.Bg; s.Parent=parent; makeCorner(s,8); makeStroke(s,1,.08); pad(s,10)
  local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Text=title; l.Font=Enum.Font.GothamBold; l.TextSize=14; l.TextColor3=CurrentTheme.Text; l.Size=UDim2.new(1,0,0,18); l.Parent=s
  local list=Instance.new("UIListLayout", s); list.Padding=UDim.new(0,8)
  local deco=Instance.new("Frame"); deco.BorderSizePixel=0; deco.Size=UDim2.new(1,0,0,2); deco.Position=UDim2.new(0,0,0,20); deco.Parent=s
  local dg=Instance.new("UIGradient"); dg.Rotation=0; dg.Color=trGrad.Color; dg.Parent=deco
  return s
end

-- Controls
local Controls={}
local function row(parent,label)
  local f=Instance.new("Frame"); f.BackgroundTransparency=1; f.Size=UDim2.new(1,0,0,28); f.Parent=parent
  local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Text=label; l.Font=Enum.Font.Gotham; l.TextSize=13; l.TextColor3=CurrentTheme.Sub; l.Size=UDim2.new(.55,0,1,0); l.Parent=f
  return f,l
end
function Controls.Toggle(parent,label,default,cb)
  local r,_=row(parent,label)
  local btn=Instance.new("TextButton"); btn.AutoButtonColor=false; btn.Text=default and "ON" or "OFF"; btn.Font=Enum.Font.GothamBold; btn.TextSize=12
  btn.TextColor3= default and Color3.fromRGB(110,210,130) or Color3.fromRGB(230,90,96); btn.BackgroundColor3=CurrentTheme.Hover
  btn.Size=UDim2.new(0,74,0,24); btn.AnchorPoint=Vector2.new(1,0); btn.Position=UDim2.new(1,-6,0,2); btn.Parent=r
  makeCorner(btn,6); makeStroke(btn,1,.15)
  local on=default or false
  btn.MouseButton1Click:Connect(function()
    on=not on; btn.Text=on and "ON" or "OFF"; btn.TextColor3=on and Color3.fromRGB(110,210,130) or Color3.fromRGB(230,90,96)
    tween(btn,.08,{BackgroundColor3= on and CurrentTheme.Accent or CurrentTheme.Hover}):Play()
    if cb then cb(on) end
  end)
  return {Set=function(v) on=v; btn.Text=v and "ON" or "OFF"; btn.TextColor3=v and Color3.fromRGB(110,210,130) or Color3.fromRGB(230,90,96); if cb then cb(v) end end}
end

-- Pages & Tabs
local pHUD      = pageDefault("HUD")
local pFeatures = pageDefault("Features")
local pScanner  = pageFree("Scanner")
local pSettings = pageDefault("Settings")
local pThemes   = pageDefault("Themes")

local tHUD      = tabButton("HUD","📊")
local tFeatures = tabButton("Features","🧩")
local tScanner  = tabButton("Scanner","🔍")
local tSettings = tabButton("Settings","⚙️")
local tThemes   = tabButton("Themes","🎨")

local function showPage(name) for k,v in pairs(Pages) do v.Visible=(k==name) end end
showPage("HUD")
tHUD.MouseButton1Click:Connect(function() showPage("HUD") end)
tFeatures.MouseButton1Click:Connect(function() showPage("Features") end)
tScanner.MouseButton1Click:Connect(function() showPage("Scanner") end)
tSettings.MouseButton1Click:Connect(function() showPage("Settings") end)
tThemes.MouseButton1Click:Connect(function() showPage("Themes") end)

--========================
-- HUD: FPS Panel + Crosshair
--========================
local HUD = Instance.new("ScreenGui"); HUD.Name="MYLF_HUD"; HUD.IgnoreGuiInset=true; HUD.ResetOnSpawn=false; HUD.DisplayOrder=2000; HUD.Parent=PlayerGui

local CrownPanel = Instance.new("Frame"); CrownPanel.Name="CrownFPS"; CrownPanel.AnchorPoint=Vector2.new(.5,0); CrownPanel.Position=UDim2.new(.5,0,0,8)
CrownPanel.Size=UDim2.fromOffset(280,36); CrownPanel.BackgroundColor3=CurrentTheme.Crown; CrownPanel.Parent=HUD; makeCorner(CrownPanel,8); makeStroke(CrownPanel,1,.15)
local CrownText = Instance.new("TextLabel"); CrownText.BackgroundTransparency=1; CrownText.Font=Enum.Font.GothamBold; CrownText.TextSize=14; CrownText.TextColor3=CurrentTheme.Text
CrownText.TextXAlignment=Enum.TextXAlignment.Center; CrownText.Size=UDim2.new(1,-12,1,-10); CrownText.Position=UDim2.fromOffset(6,0); CrownText.Parent=CrownPanel
local RB = Instance.new("Frame"); RB.BorderSizePixel=0; RB.AnchorPoint=Vector2.new(.5,1); RB.Position=UDim2.new(.5,0,1,0); RB.Size=UDim2.new(1,-8,0,3); RB.Parent=CrownPanel; makeCorner(RB,2)
local rbGrad=Instance.new("UIGradient"); rbGrad.Rotation=0; rbGrad.Color=trGrad.Color; rbGrad.Parent=RB
CrownPanel.Visible=false

local sHUDL = section(pHUD, "FPS / Performance")
local sHUDR = section(pHUD, "Crosshair")

local hbAvg, hbN, rsAvg, rsN, half, count = 0,0,0,0,0,0
RunService.Heartbeat:Connect(function(dt) hbN+=1; hbAvg = hbAvg + (dt - hbAvg)/hbN end)
RunService.RenderStepped:Connect(function(dt)
  rsN+=1; rsAvg = rsAvg + (dt - rsAvg)/rsN; half+=dt; count+=1; rbGrad.Offset = Vector2.new(math.sin(os.clock()*0.8)*0.25,0)
  if half>=0.5 then
    local fps = math.floor(count/half+0.5); count, half=0,0
    local ping="?" pcall(function() local it=Stats.Network.ServerStatsItem["Data Ping"]; if it then ping=tostring(it:GetValueString()):gsub(" RTT","") end end)
    local cpuMs = math.floor(hbAvg*1000*10+0.5)/10; local gpuMs = math.floor(rsAvg*1000*10+0.5)/10
    CrownText.Text=("FPS: %s  |  CPU: %s ms  |  GPU: %s ms  |  Ping: %s"):format(fps, cpuMs, gpuMs, ping)
    local need=CrownText.TextBounds.X+40; CrownPanel.Size=UDim2.fromOffset(math.clamp(need,240,640),36)
  end
end)

Controls.Toggle(sHUDL,"Show FPS Panel",false,function(on)
  CrownPanel.Visible = on
  safeCall("ToggleHUDPanel", on)
end)

-- Crosshair
local Cross = Instance.new("Frame"); Cross.Name="Crosshair"; Cross.AnchorPoint=Vector2.new(.5,.5); Cross.Position=UDim2.fromScale(.5,.5)
Cross.Size=UDim2.fromOffset(2,2); Cross.BackgroundTransparency=1; Cross.Parent=HUD; Cross.ZIndex=100
local CrossCfg={Enabled=true, Gap=6, Len=8, Thick=2, Opacity=1, Color=CurrentTheme.Accent}
local arms={} for i=1,4 do local a=Instance.new("Frame"); a.BorderSizePixel=0; a.Parent=Cross; arms[i]=a end
local function paintCross()
  for _,a in ipairs(arms) do a.BackgroundTransparency=1-CrossCfg.Opacity; a.BackgroundColor3=CrossCfg.Color end
  arms[1].Size=UDim2.fromOffset(CrossCfg.Thick,CrossCfg.Len); arms[1].Position=UDim2.fromOffset(-CrossCfg.Thick/2,-(CrossCfg.Gap+CrossCfg.Len))
  arms[2].Size=UDim2.fromOffset(CrossCfg.Thick,CrossCfg.Len); arms[2].Position=UDim2.fromOffset(-CrossCfg.Thick/2, CrossCfg.Gap)
  arms[3].Size=UDim2.fromOffset(CrossCfg.Len,CrossCfg.Thick); arms[3].Position=UDim2.fromOffset(-(CrossCfg.Gap+CrossCfg.Len),-CrossCfg.Thick/2)
  arms[4].Size=UDim2.fromOffset(CrossCfg.Len,CrossCfg.Thick); arms[4].Position=UDim2.fromOffset(CrossCfg.Gap,-CrossCfg.Thick/2)
  Cross.Visible=CrossCfg.Enabled
end
paintCross()

Controls.Toggle(sHUDR,"Crosshair ON/OFF",true,function(on) CrossCfg.Enabled=on; paintCross(); safeCall("ToggleCrosshair", on) end)
Controls.Toggle(sHUDR,"Reset Color (Theme Accent)",false,function(on) if on then CrossCfg.Color=CurrentTheme.Accent; paintCross() end end)
Controls.Toggle(sHUDR,"Thin Lines",false,function(on) CrossCfg.Thick= on and 1 or 2; paintCross() end)
Controls.Toggle(sHUDR,"Big Gap",false,function(on) CrossCfg.Gap  = on and 12 or 6; paintCross() end)

--========================
-- Features (UI bridge only; kısım kısım)
--========================
local sCombat     = section(pFeatures, "Combat")
local sVisuals    = section(pFeatures, "Visuals")
local sMovement   = section(pFeatures, "Movement")
local sProtection = section(pFeatures, "Protection / Player")
local sUtility    = section(pFeatures, "Utility / TP")

local function bindFeatureToggle(parent, title, fname)
  return Controls.Toggle(parent, title, false, function(on)
    safeCall(fname, on)
  end)
end

-- Combat
bindFeatureToggle(sCombat,   "Enable Aimbot",            "ToggleAimbot")
bindFeatureToggle(sCombat,   "Force Headshot (Silent)",  "ToggleSilentAim")
bindFeatureToggle(sCombat,   "☠️ Kill Aura",             "ToggleKillAura")
bindFeatureToggle(sCombat,   "Hard Fire Rate",           "ToggleFireRate")

-- Visuals
bindFeatureToggle(sVisuals,  "Enable ESP",               "ToggleESP")
bindFeatureToggle(sVisuals,  "🎯 Enemy Big Hitbox",      "ToggleEnemyBigHitbox")
bindFeatureToggle(sVisuals,  "my Hitbox (local)",        "Togglemyhitbox")

-- Movement
bindFeatureToggle(sMovement, "Speed Boost (50)",         "ToggleSpeed")
bindFeatureToggle(sMovement, "Fly (LCtrl down)",         "ToggleFly")
bindFeatureToggle(sMovement, "Infinite Jump",            "ToggleInfiniteJump")
bindFeatureToggle(sMovement, "NoClip",                   "ToggleNoclip")

-- Protection / Player
bindFeatureToggle(sProtection,"💀 Godmode",              "ToggleGodmode")
bindFeatureToggle(sProtection,"👻 Hard Invisible",       "ToggleHardInvisible")

-- Utility / TP
bindFeatureToggle(sUtility,  "Teleport (T Key)",         "ToggleTeleport")
bindFeatureToggle(sUtility,  "⚡ Always Behind Enemy",    "ToggleAutoBehind")
bindFeatureToggle(sUtility,  "⚡ Auto Farm Enemy",        "ToggleAutoTeleportToEnemy")

-- TP Offsets (Utility altında)
local _tpX,_tpY,_tpZ = 0,0,25
local function miniInput(parent, name, min, max, def, assign)
  local r,_=row(parent,name)
  local inp=Instance.new("TextBox"); inp.Size=UDim2.new(0,70,0,24); inp.AnchorPoint=Vector2.new(1,0); inp.Position=UDim2.new(1,-6,0,2)
  inp.BackgroundColor3=CurrentTheme.Hover; inp.TextColor3=CurrentTheme.Text; inp.Font=Enum.Font.GothamSemibold; inp.TextSize=12; inp.ClearTextOnFocus=false; inp.Text=tostring(def)
  inp.Parent=r; makeCorner(inp,6); makeStroke(inp,1,.12)
  inp.FocusLost:Connect(function()
    local v = tonumber(inp.Text) or def
    v = math.clamp(v, min, max)
    assign(v); inp.Text = tostring(v); safeCall("SetTeleportOffset", _tpX,_tpY,_tpZ)
  end)
end
miniInput(sUtility,"tpX (-50~50)",-50,50,_tpX,function(v) _tpX=v end)
miniInput(sUtility,"tpY (-50~50)",-50,50,_tpY,function(v) _tpY=v end)
miniInput(sUtility,"tpZ (1~100)",  1,100,_tpZ,function(v) _tpZ=v end)

--========================
-- Scanner (2 sütun sabit; yan yana)
--========================
do
  local LeftCol  = Instance.new("Frame"); LeftCol.Size=UDim2.new(0.5,-5,1,0); LeftCol.BackgroundColor3=CurrentTheme.Bg; LeftCol.Parent=pScanner; makeCorner(LeftCol,8); makeStroke(LeftCol,1,.08); pad(LeftCol,10)
  local RightCol = Instance.new("Frame"); RightCol.Size=UDim2.new(0.5,-5,1,0); RightCol.Position=UDim2.new(0.5,5,0,0); RightCol.BackgroundColor3=CurrentTheme.Bg; RightCol.Parent=pScanner; makeCorner(RightCol,8); makeStroke(RightCol,1,.08); pad(RightCol,10)

  local TL=Instance.new("TextLabel"); TL.BackgroundTransparency=1; TL.Text="Explorer"; TL.Font=Enum.Font.GothamBold; TL.TextSize=14; TL.TextColor3=CurrentTheme.Text; TL.Size=UDim2.new(1,0,0,18); TL.Parent=LeftCol
  local TR=Instance.new("TextLabel"); TR.BackgroundTransparency=1; TR.Text="Details";  TR.Font=Enum.Font.GothamBold; TR.TextSize=14; TR.TextColor3=CurrentTheme.Text; TR.Size=UDim2.new(1,0,0,18); TR.Parent=RightCol

  local ScanBar = Instance.new("Frame"); ScanBar.Size=UDim2.new(1,0,0,28); ScanBar.BackgroundColor3=CurrentTheme.Hover; ScanBar.Parent=LeftCol; makeCorner(ScanBar,6)
  local Search = Instance.new("TextBox"); Search.PlaceholderText="Filter (name/class)"; Search.ClearTextOnFocus=false; Search.BackgroundTransparency=1
  Search.Font=Enum.Font.Gotham; Search.TextSize=12; Search.TextColor3=CurrentTheme.Text; Search.Size=UDim2.new(1,-90,1,0); Search.Position=UDim2.new(0,8,0,0); Search.Parent=ScanBar
  local GoBtn = Instance.new("TextButton"); GoBtn.Text="Scan"; GoBtn.AutoButtonColor=false; GoBtn.Font=Enum.Font.GothamSemibold; GoBtn.TextSize=12
  GoBtn.TextColor3=CurrentTheme.Text; GoBtn.BackgroundColor3=CurrentTheme.Accent; GoBtn.AnchorPoint=Vector2.new(1,0); GoBtn.Position=UDim2.new(1,-6,0,2); GoBtn.Size=UDim2.new(0,70,0,24)
  GoBtn.Parent=ScanBar; makeCorner(GoBtn,6)

  local List = Instance.new("ScrollingFrame"); List.Active=true; List.CanvasSize=UDim2.new(0,0,0,0); List.ScrollBarThickness=6
  List.BackgroundColor3=CurrentTheme.Bg; List.Size=UDim2.new(1,0,1,-60); List.Position=UDim2.new(0,0,0,34); List.Parent=LeftCol; makeCorner(List,6); makeStroke(List,1,.08)
  local LLayout = Instance.new("UIListLayout", List); LLayout.Padding=UDim.new(0,6)

  local Info = Instance.new("TextLabel"); Info.BackgroundTransparency=0; Info.BackgroundColor3=CurrentTheme.Bg; Info.TextColor3=CurrentTheme.Text
  Info.TextWrapped=true; Info.TextXAlignment=Enum.TextXAlignment.Left; Info.TextYAlignment=Enum.TextYAlignment.Top; Info.Font=Enum.Font.Gotham; Info.TextSize=12
  Info.Size=UDim2.new(1,0,1,-0); Info.Position=UDim2.new(0,0,0,26); Info.Parent=RightCol; makeCorner(Info,6); makeStroke(Info,1,.08); pad(Info,8)

  local function addRow(inst)
    local b=Instance.new("TextButton"); b.AutoButtonColor=false; b.Text=("%s  (%s)"):format(inst.Name, inst.ClassName)
    b.TextXAlignment=Enum.TextXAlignment.Left; b.Font=Enum.Font.Gotham; b.TextSize=12; b.TextColor3=CurrentTheme.Text; b.BackgroundColor3=CurrentTheme.Hover
    b.Size=UDim2.new(1,-8,0,24); b.Parent=List; makeCorner(b,6)
    b.MouseButton1Click:Connect(function() Info.Text=("Name: %s\nClass: %s\nPath: %s"):format(inst.Name, inst.ClassName, inst:GetFullName()) end)
  end

  local function softMatch(str,q) str=string.lower(str); q=string.lower(q or ""); if q=="" then return true end return string.find(str,q,1,true)~=nil end
  local function doScan()
    for _,c in ipairs(List:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    local filter=Search.Text; local roots={workspace, game:GetService("ReplicatedStorage"), Players}; local cnt,cap=0,450
    for _,root in ipairs(roots) do
      for _,d in ipairs(root:GetDescendants()) do if cnt>=cap then break end
        if softMatch(d.Name,filter) or softMatch(d.ClassName,filter) then addRow(d); cnt+=1 end
      end
    end
    List.CanvasSize=UDim2.new(0,0,0, math.max(0, LLayout.AbsoluteContentSize.Y+12)); 
    notify(("Scan done (%d items)."):format(cnt))
  end
  GoBtn.MouseButton1Click:Connect(doScan)
end

--========================
-- Themes & Settings
--========================
local sThL = section(pThemes,"Theme Switcher")
local sThR = section(pThemes,"Accents")

local order={"Dark","Midnight","Neon","Black","Red"}; local idx=1
local function repaint(name)
  local T=Themes[name] or Themes.Dark; CurrentTheme=T
  Window.BackgroundColor3=T.Bg; TitleBar.BackgroundColor3=T.Panel; Title.TextColor3=T.Text
  ThemeBtn.TextColor3=T.Text; ThemeBtn.BackgroundColor3=T.Hover
  for _,b in ipairs(Sidebar:GetChildren()) do if b:IsA("TextButton") then b.TextColor3=T.Text; b.BackgroundColor3=T.Hover end end
  for _,p in pairs(Pages) do p.BackgroundColor3=T.Panel; for _,sec in ipairs(p:GetChildren()) do if sec:IsA("Frame") and sec~=p then sec.BackgroundColor3=T.Bg end end end
  -- HUD ve crosshair temaya uyum
  CrownPanel.BackgroundColor3=T.Crown; CrownText.TextColor3=T.Text
  CrossCfg.Color=T.Accent; paintCross()
end
ThemeBtn.MouseButton1Click:Connect(function() idx=idx%#order+1; local name=order[idx]; ThemeBtn.Text="Theme: "..name; repaint(name) end)
repaint("Dark")

local sSetL = section(pSettings,"Visibility / Binds")
local sSetR = section(pSettings,"Info")
local State={Visible=true, GlobalKey = Enum.KeyCode.LeftShift}
Controls.Toggle(sSetL,"Hide/Show Window",false,function(on) State.Visible = not on and true or false; Window.Visible=State.Visible; notify(State.Visible and "Menü gösterildi." or "Menü gizlendi.") end)

-- Keybind
do
  local f,_=row(sSetL,"Menu Toggle Key")
  local btn=Instance.new("TextButton"); btn.AutoButtonColor=false; btn.Text=State.GlobalKey.Name
  btn.Font=Enum.Font.GothamBold; btn.TextSize=12; btn.TextColor3=CurrentTheme.Text; btn.BackgroundColor3=CurrentTheme.Hover
  btn.Size=UDim2.new(0,130,0,24); btn.AnchorPoint=Vector2.new(1,0); btn.Position=UDim2.new(1,-6,0,2); btn.Parent=f
  makeCorner(btn,6); makeStroke(btn,1,.15)
  local listening=false
  btn.MouseButton1Click:Connect(function() listening=true; btn.Text="Press..." end)
  UserInputService.InputBegan:Connect(function(i,gp) if not listening or gp then return end if i.KeyCode~=Enum.KeyCode.Unknown then listening=false; State.GlobalKey=i.KeyCode; btn.Text=State.GlobalKey.Name end end)
end
UserInputService.InputBegan:Connect(function(i,gp) if gp then return end if i.KeyCode==State.GlobalKey then State.Visible = not State.Visible; Window.Visible=State.Visible end end)

local meta=Instance.new("TextLabel"); meta.BackgroundTransparency=1; meta.TextColor3=CurrentTheme.Sub; meta.Font=Enum.Font.Gotham; meta.TextSize=12
meta.Text="UI-safe köprü: HUD/Crosshair/Teleport Offset aktif. Diğer feature çağrıları engellenir ve ReplicatedStorage.MYLF_FeatureBus/blocked_feature event’i tetiklenir."
meta.Size=UDim2.new(1,0,1,0); meta.TextXAlignment=Enum.TextXAlignment.Left; meta.TextYAlignment=Enum.TextYAlignment.Top; meta.Parent=sSetR

notify("MYLF UI yüklendi — drag fix, themes dolu, scanner yan yana, HUD/Crosshair/TP köprü aktif.",3.0)
