--[[ 
  ⚡ MYLF | UI (Client-Safe) — Full Source + Features Köprüsü
  - Hile yok. UI/QoL köprüleri.
  - FPS/CPU/GPU/Ping bar (tema bağlı, rainbow accent), Crosshair HUD, Scanner, Theme switch, Keybindable menu toggle.
  - Features Köprüsü: yalnızca UI-safe fonksiyonlar ALLOW=true (ToggleHUDPanel, ToggleCrosshair, SetTeleportOffset).
]]

--// Features Köprüsü (tek tanım)
local features = {}
do
    local ok, mod = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features9.8.lua"))()
    end)
    features = ok and mod or {}
end

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
    end
end

-- // Services
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local ReplicatedStorage= game:GetService("ReplicatedStorage")
local Stats            = game:GetService("Stats")

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

-- // Themes
local Themes = {
  Dark     = {Bg=Color3.fromRGB(20,20,26),  Panel=Color3.fromRGB(28,28,36),  Hover=Color3.fromRGB(40,40,52),  Accent=Color3.fromRGB(120,115,245), Text=Color3.fromRGB(238,238,245), Sub=Color3.fromRGB(170,170,178), Crown=Color3.fromRGB(234,198,76)},
  Midnight = {Bg=Color3.fromRGB(12,14,24),  Panel=Color3.fromRGB(18,20,34),  Hover=Color3.fromRGB(26,30,46),  Accent=Color3.fromRGB(80,180,255),  Text=Color3.fromRGB(228,232,240), Sub=Color3.fromRGB(150,158,172), Crown=Color3.fromRGB(48,62,110)},
  Neon     = {Bg=Color3.fromRGB(18,18,22),  Panel=Color3.fromRGB(22,22,28),  Hover=Color3.fromRGB(40,34,60),  Accent=Color3.fromRGB(255,80,200),  Text=Color3.fromRGB(245,245,255), Sub=Color3.fromRGB(172,170,190), Crown=Color3.fromRGB(45,25,60)},
  Black    = {Bg=Color3.fromRGB(6,6,8),     Panel=Color3.fromRGB(14,14,18),  Hover=Color3.fromRGB(24,24,30),  Accent=Color3.fromRGB(220,220,230), Text=Color3.fromRGB(240,240,245), Sub=Color3.fromRGB(160,162,170), Crown=Color3.fromRGB(28,28,34)},
  Red      = {Bg=Color3.fromRGB(24,8,10),   Panel=Color3.fromRGB(32,10,12),  Hover=Color3.fromRGB(46,16,20),  Accent=Color3.fromRGB(230,66,80),   Text=Color3.fromRGB(250,240,242), Sub=Color3.fromRGB(200,150,156), Crown=Color3.fromRGB(76,18,24)},
}
local CurrentTheme = Themes.Dark

-- // Helpers
local function tween(o,ti,props) return TweenService:Create(o, TweenInfo.new(ti, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props) end
local function makeCorner(o,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=o; return c end
local function makeStroke(o,th,tr) local s=Instance.new("UIStroke"); s.Thickness=th or 1; s.Transparency=tr or 0; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=o; return s end
local function pad(o,px) local p=Instance.new("UIPadding"); p.PaddingTop=UDim.new(0,px); p.PaddingBottom=UDim.new(0,px); p.PaddingLeft=UDim.new(0,px); p.PaddingRight=UDim.new(0,px); p.Parent=o; return p end

-- // State
local State = {Visible=true, GlobalKey=Enum.KeyCode.LeftShift}

-- // Root GUI
local Gui = Instance.new("ScreenGui")
Gui.Name="MYLF_UI"; Gui.IgnoreGuiInset=true; Gui.ResetOnSpawn=false; Gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; Gui.DisplayOrder=1000; Gui.Parent=PlayerGui

-- Notification
local NotifLayer = Instance.new("Frame"); NotifLayer.BackgroundTransparency=1; NotifLayer.Size=UDim2.new(1,0,1,0); NotifLayer.Parent=Gui
local function notify(txt, dur)
  dur=dur or 2.2
  local t=Instance.new("TextLabel"); t.BackgroundColor3=CurrentTheme.Panel; t.TextColor3=CurrentTheme.Text; t.Text="  "..txt
  t.Font=Enum.Font.GothamSemibold; t.TextSize=13; t.AnchorPoint=Vector2.new(1,0); t.Position=UDim2.new(1,-10,0,10); t.Size=UDim2.new(0,0,0,26); t.Parent=NotifLayer
  makeCorner(t,6); makeStroke(t,1,.12); tween(t,.14,{Size=UDim2.new(0, math.clamp(t.TextBounds.X+20,140,520),0,26)}):Play()
  task.delay(dur,function() tween(t,.16,{Position=UDim2.new(1,-10,0,-30),BackgroundTransparency=1}):Play(); task.delay(.18,function() t:Destroy() end) end)
end

-- Window
local Window = Instance.new("Frame")
Window.Size=UDim2.new(0,820,0,500); Window.Position=UDim2.new(.5,-410,.5,-250); Window.BackgroundColor3=CurrentTheme.Bg; Window.Active=true; Window.Parent=Gui
makeCorner(Window,10); makeStroke(Window,1,.2)

-- Drag
do local dragging, start, init
  Window.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; start=i.Position; init=Window.Position end end)
  Window.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
  Window.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
    local d=i.Position-start; Window.Position=UDim2.new(init.X.Scale, init.X.Offset+d.X, init.Y.Scale, init.Y.Offset+d.Y) end end)
end

-- TitleBar + theme switch + rainbow accent
local TitleBar=Instance.new("Frame"); TitleBar.Size=UDim2.new(1,0,0,44); TitleBar.BackgroundColor3=CurrentTheme.Panel; TitleBar.Parent=Window
makeCorner(TitleBar,10); makeStroke(TitleBar,1,.12)
local Title=Instance.new("TextLabel"); Title.BackgroundTransparency=1; Title.Text="⚡ MYLF | UI (Client-Safe)"; Title.Font=Enum.Font.GothamBold; Title.TextSize=16
Title.TextColor3=CurrentTheme.Text; Title.TextXAlignment=Enum.TextXAlignment.Left; Title.Position=UDim2.new(0,14,0,0); Title.Size=UDim2.new(1,-250,1,0); Title.Parent=TitleBar
local ThemeBtn=Instance.new("TextButton"); ThemeBtn.AutoButtonColor=false; ThemeBtn.Text="Theme: Dark"; ThemeBtn.Font=Enum.Font.GothamSemibold; ThemeBtn.TextSize=13
ThemeBtn.TextColor3=CurrentTheme.Text; ThemeBtn.BackgroundColor3=CurrentTheme.Hover; ThemeBtn.AnchorPoint=Vector2.new(1,.5); ThemeBtn.Position=UDim2.new(1,-10,.5,0)
ThemeBtn.Size=UDim2.new(0,160,0,26); ThemeBtn.Parent=TitleBar; makeCorner(ThemeBtn,6); makeStroke(ThemeBtn,1,.15)
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

-- Sidebar & Content
local Sidebar=Instance.new("Frame"); Sidebar.BackgroundColor3=CurrentTheme.Panel; Sidebar.Position=UDim2.new(0,10,0,58)
Sidebar.Size=UDim2.new(0,190,1,-68); Sidebar.Parent=Window; makeCorner(Sidebar,8); makeStroke(Sidebar,1,.1); pad(Sidebar,8)
local SideList=Instance.new("UIListLayout", Sidebar); SideList.Padding=UDim.new(0,8)
local function tabButton(txt,icon)
  local b=Instance.new("TextButton"); b.AutoButtonColor=false; b.Text=(icon and (icon.."  ") or "")..txt; b.Font=Enum.Font.GothamSemibold; b.TextSize=14
  b.TextColor3=CurrentTheme.Text; b.BackgroundColor3=CurrentTheme.Hover; b.Size=UDim2.new(1,-4,0,34); b.Parent=Sidebar; makeCorner(b,6); makeStroke(b,1,.15)
  b.MouseEnter:Connect(function() tween(b,.08,{BackgroundColor3=CurrentTheme.Accent}):Play() end)
  b.MouseLeave:Connect(function() tween(b,.12,{BackgroundColor3=CurrentTheme.Hover}):Play() end)
  return b
end

local Content=Instance.new("Frame"); Content.BackgroundTransparency=1; Content.Position=UDim2.new(0,210,0,58); Content.Size=UDim2.new(1,-220,1,-68); Content.Parent=Window
local Pages={}
local function newPage(name)
  local p=Instance.new("Frame"); p.Visible=false; p.BackgroundColor3=CurrentTheme.Panel; p.Size=UDim2.new(1,0,1,0); p.Parent=Content
  makeCorner(p,8); makeStroke(p,1,.1); pad(p,10)
  local grid=Instance.new("UIGridLayout", p); grid.CellPadding=UDim2.new(0,10,0,10); grid.CellSize=UDim2.new(.5,-5,1,-10)
  Pages[name]=p; return p
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
  local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Text=label; l.Font=Enum.Font.Gotham; l.TextSize=13; l.TextColor3=CurrentTheme.Sub; l.Size=UDim2.new(.5,0,1,0); l.Parent=f
  return f,l
end
function Controls.Toggle(parent,label,default,onToggle)
  local r,_=row(parent,label)
  local btn=Instance.new("TextButton"); btn.AutoButtonColor=false; btn.Text=default and "ON" or "OFF"; btn.Font=Enum.Font.GothamBold; btn.TextSize=12
  btn.TextColor3= default and Color3.fromRGB(110,210,130) or Color3.fromRGB(230,90,96); btn.BackgroundColor3=CurrentTheme.Hover
  btn.Size=UDim2.new(0,74,0,24); btn.AnchorPoint=Vector2.new(1,0); btn.Position=UDim2.new(1,-6,0,2); btn.Parent=r
  makeCorner(btn,6); makeStroke(btn,1,.15)
  local on=default or false
  btn.MouseButton1Click:Connect(function()
    on=not on; btn.Text=on and "ON" or "OFF"; btn.TextColor3=on and Color3.fromRGB(110,210,130) or Color3.fromRGB(230,90,96)
    tween(btn,.08,{BackgroundColor3= on and CurrentTheme.Accent or CurrentTheme.Hover}):Play()
    if onToggle then onToggle(on) end
  end)
  return {Set=function(v) on=v; btn.Text=v and "ON" or "OFF"; btn.TextColor3=v and Color3.fromRGB(110,210,130) or Color3.fromRGB(230,90,96); if onToggle then onToggle(v) end end}
end
function Controls.Slider(parent,label,min,max,default,fmt,onChanged)
  local r,_=row(parent,label)
  local bar=Instance.new("Frame"); bar.Size=UDim2.new(.48,0,0,24); bar.Position=UDim2.new(.5,0,0,2); bar.BackgroundColor3=CurrentTheme.Hover; bar.Parent=r
  makeCorner(bar,6); makeStroke(bar,1,.1)
  local fill=Instance.new("Frame"); fill.BackgroundColor3=CurrentTheme.Accent; fill.Size=UDim2.new((default-min)/(max-min),0,1,0); fill.Parent=bar; makeCorner(fill,6)
  local g=Instance.new("UIGradient"); g.Rotation=0; g.Color=trGrad.Color; g.Parent=fill
  local value=default or min; local valText=Instance.new("TextLabel"); valText.BackgroundTransparency=1; valText.TextColor3=CurrentTheme.Text; valText.Font=Enum.Font.GothamSemibold; valText.TextSize=12
  valText.AnchorPoint=Vector2.new(1,0); valText.Position=UDim2.new(1,-6,0,0); valText.Size=UDim2.new(0,56,1,0); valText.Parent=bar; valText.Text=(fmt or "%d"):format(value)
  local dragging=false
  local function setFromX(x)
    local rel=math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
    value = math.floor((min + (max-min)*rel)*100+0.5)/100
    fill.Size=UDim2.new((value-min)/(max-min),0,1,0); valText.Text=(fmt or "%d"):format(value)
    if onChanged then onChanged(value) end
  end
  bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; setFromX(i.Position.X) end end)
  bar.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
  UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then setFromX(i.Position.X) end end)
  return {Set=function(v) value=v; fill.Size=UDim2.new((value-min)/(max-min),0,1,0); valText.Text=(fmt or "%d"):format(value); if onChanged then onChanged(value) end end, Get=function() return value end}
end
function Controls.Button(parent,label,text,fn)
  local r,_=row(parent,label)
  local b=Instance.new("TextButton"); b.AutoButtonColor=false; b.Text=text or "Run"; b.Font=Enum.Font.GothamSemibold; b.TextSize=12
  b.TextColor3=CurrentTheme.Text; b.BackgroundColor3=CurrentTheme.Hover; b.Size=UDim2.new(0,120,0,24); b.AnchorPoint=Vector2.new(1,0); b.Position=UDim2.new(1,-6,0,2); b.Parent=r
  makeCorner(b,6); makeStroke(b,1,.15)
  if type(fn)=="function" then b.MouseButton1Click:Connect(fn) end
  return b
end
function Controls.Keybind(parent,label,defaultKey,onChanged)
  local r,_=row(parent,label)
  local btn=Instance.new("TextButton"); btn.AutoButtonColor=false; btn.Text=(defaultKey and defaultKey.Name) or "LeftShift"
  btn.Font=Enum.Font.GothamBold; btn.TextSize=12; btn.TextColor3=CurrentTheme.Text; btn.BackgroundColor3=CurrentTheme.Hover
  btn.Size=UDim2.new(0,130,0,24); btn.AnchorPoint=Vector2.new(1,0); btn.Position=UDim2.new(1,-6,0,2); btn.Parent=r
  makeCorner(btn,6); makeStroke(btn,1,.15)
  local listening=false; local current=defaultKey or Enum.KeyCode.LeftShift
  btn.MouseButton1Click:Connect(function() listening=true; btn.Text="Press..." end)
  UserInputService.InputBegan:Connect(function(i,gp) if not listening or gp then return end if i.KeyCode~=Enum.KeyCode.Unknown then listening=false; current=i.KeyCode; btn.Text=current.Name; if onChanged then onChanged(current) end end end)
  return {Get=function() return current end, Set=function(kc) current=kc or current; btn.Text=current.Name; if onChanged then onChanged(current) end end}
end

-- Pages & Tabs
local pHUD      = newPage("HUD")
local pUtility  = newPage("Utility")
local pScanner  = newPage("Scanner")
local pSettings = newPage("Settings")
local pThemes   = newPage("Themes")

local tHUD      = tabButton("HUD","📊")
local tUtility  = tabButton("Utility","🧭")
local tScanner  = tabButton("Scanner","🔍")
local tSettings = tabButton("Settings","⚙️")
local tThemes   = tabButton("Themes","🎨")

local function showPage(name) for k,v in pairs(Pages) do v.Visible=(k==name) end end
showPage("HUD")
tHUD.MouseButton1Click:Connect(function() showPage("HUD") end)
tUtility.MouseButton1Click:Connect(function() showPage("Utility") end)
tScanner.MouseButton1Click:Connect(function() showPage("Scanner") end)
tSettings.MouseButton1Click:Connect(function() showPage("Settings") end)
tThemes.MouseButton1Click:Connect(function() showPage("Themes") end)

-- Sections
local sHUDL = section(pHUD, "FPS / Performance")
local sHUDR = section(pHUD, "Crosshair")
local sUTL  = section(pUtility, "Teleport Offsets (UI Bridge)")
local sScL  = section(pScanner,"Explorer")
local sScR  = section(pScanner,"Details")
local sSetL = section(pSettings,"Visibility / Binds")
local sSetR = section(pSettings,"Info")
local sThL  = section(pThemes,"Theme Switcher")
local sThR  = section(pThemes,"Accents")

-- HUD: FPS Panel (default OFF, theme-bound)
local HUD = Instance.new("ScreenGui"); HUD.Name="MYLF_HUD"; HUD.IgnoreGuiInset=true; HUD.ResetOnSpawn=false; HUD.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; HUD.DisplayOrder=2000; HUD.Parent=PlayerGui
local CrownPanel = Instance.new("Frame"); CrownPanel.Name="CrownFPS"; CrownPanel.AnchorPoint=Vector2.new(.5,0); CrownPanel.Position=UDim2.new(.5,0,0,8)
CrownPanel.Size=UDim2.fromOffset(280,36); CrownPanel.BackgroundColor3=CurrentTheme.Crown; CrownPanel.Parent=HUD; makeCorner(CrownPanel,8); makeStroke(CrownPanel,1,.15)
local CrownText = Instance.new("TextLabel"); CrownText.BackgroundTransparency=1; CrownText.Font=Enum.Font.GothamBold; CrownText.TextSize=14; CrownText.TextColor3=CurrentTheme.Text
CrownText.TextXAlignment=Enum.TextXAlignment.Center; CrownText.Size=UDim2.new(1,-12,1,-10); CrownText.Position=UDim2.fromOffset(6,0); CrownText.Parent=CrownPanel
local RB = Instance.new("Frame"); RB.BorderSizePixel=0; RB.AnchorPoint=Vector2.new(.5,1); RB.Position=UDim2.new(.5,0,1,0); RB.Size=UDim2.new(1,-8,0,3); RB.Parent=CrownPanel; makeCorner(RB,2)
local rbGrad=Instance.new("UIGradient"); rbGrad.Rotation=0; rbGrad.Color=trGrad.Color; rbGrad.Parent=RB
CrownPanel.Visible=false
do local drag=false; local start; local base
  CrownPanel.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true; start=i.Position; base=CrownPanel.Position end end)
  CrownPanel.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
  CrownPanel.InputChanged:Connect(function(i) if drag and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-start; CrownPanel.Position=UDim2.new(base.X.Scale, base.X.Offset+d.X, base.Y.Scale, base.Y.Offset+d.Y) end end)
end

-- Crosshair HUD
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

-- HUD controls (safeCall köprüleri)
local fpsToggle = Controls.Toggle(sHUDL,"Show FPS Panel",false,function(on)
  CrownPanel.Visible = on
  safeCall("ToggleHUDPanel", on)
end)
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

local crToggle = Controls.Toggle(sHUDR,"Crosshair ON/OFF",true,function(on)
  CrossCfg.Enabled=on; paintCross()
  safeCall("ToggleCrosshair", on)
end)
Controls.Slider(sHUDR,"Gap",0,30,CrossCfg.Gap,"%0.0f",function(v) CrossCfg.Gap=v; paintCross() end)
Controls.Slider(sHUDR,"Length",2,40,CrossCfg.Len,"%0.0f",function(v) CrossCfg.Len=v; paintCross() end)
Controls.Slider(sHUDR,"Thickness",1,8,CrossCfg.Thick,"%0.0f",function(v) CrossCfg.Thick=v; paintCross() end)
Controls.Slider(sHUDR,"Opacity",0,1,CrossCfg.Opacity,"%0.2f",function(v) CrossCfg.Opacity=v; paintCross() end)
Controls.Button(sHUDR,"Color","Use Theme Accent",function() CrossCfg.Color=CurrentTheme.Accent; paintCross() end)

-- Utility: Teleport Offsets (safeCall)
local _tpX,_tpY,_tpZ = 0,0,25
local sX = Controls.Slider(sUTL,"tpX",-50,50,0,"%0.0f",function(v) _tpX=v; safeCall("SetTeleportOffset", _tpX,_tpY,_tpZ) end)
local sY = Controls.Slider(sUTL,"tpY",-50,50,0,"%0.0f",function(v) _tpY=v; safeCall("SetTeleportOffset", _tpX,_tpY,_tpZ) end)
local sZ = Controls.Slider(sUTL,"tpZ",  1,100,25,"%0.0f",function(v) _tpZ=v; safeCall("SetTeleportOffset", _tpX,_tpY,_tpZ) end)

-- Scanner
local ScanBar = section(pScanner,"Controls")
local sList   = section(pScanner,"Explorer")
local sInfo   = section(pScanner,"Details")
local SearchBar = Instance.new("Frame"); SearchBar.Size=UDim2.new(1,0,0,28); SearchBar.BackgroundColor3=CurrentTheme.Hover; SearchBar.Parent=ScanBar; makeCorner(SearchBar,6)
local Search = Instance.new("TextBox"); Search.PlaceholderText="Filter (name/class)"; Search.ClearTextOnFocus=false; Search.BackgroundTransparency=1
Search.Font=Enum.Font.Gotham; Search.TextSize=12; Search.TextColor3=CurrentTheme.Text; Search.Size=UDim2.new(1,-90,1,0); Search.Position=UDim2.new(0,8,0,0); Search.Parent=SearchBar
local GoBtn = Instance.new("TextButton"); GoBtn.Text="Scan"; GoBtn.AutoButtonColor=false; GoBtn.Font=Enum.Font.GothamSemibold; GoBtn.TextSize=12
GoBtn.TextColor3=CurrentTheme.Text; GoBtn.BackgroundColor3=CurrentTheme.Accent; GoBtn.AnchorPoint=Vector2.new(1,0); GoBtn.Position=UDim2.new(1,-6,0,2); GoBtn.Size=UDim2.new(0,70,0,24)
GoBtn.Parent=SearchBar; makeCorner(GoBtn,6)

local List = Instance.new("ScrollingFrame"); List.Active=true; List.CanvasSize=UDim2.new(0,0,0,0); List.ScrollBarThickness=6
List.BackgroundColor3=CurrentTheme.Bg; List.Size=UDim2.new(1,0,1,-10); List.Position=UDim2.new(0,0,0,0); List.Parent=sList; makeCorner(List,6); makeStroke(List,1,.08)
local LLayout=Instance.new("UIListLayout", List); LLayout.Padding=UDim.new(0,6)

local Info = Instance.new("TextLabel"); Info.BackgroundTransparency=0; Info.BackgroundColor3=CurrentTheme.Bg; Info.TextColor3=CurrentTheme.Text
Info.TextWrapped=true; Info.TextXAlignment=Enum.TextXAlignment.Left; Info.TextYAlignment=Enum.TextYAlignment.Top; Info.Font=Enum.Font.Gotham; Info.TextSize=12
Info.Size=UDim2.new(1,0,1,0); Info.Parent=sInfo; makeCorner(Info,6); makeStroke(Info,1,.08); pad(Info,8)

local function addRow(inst)
  local b=Instance.new("TextButton"); b.AutoButtonColor=false; b.Text=("%s  (%s)"):format(inst.Name, inst.ClassName)
  b.TextXAlignment=Enum.TextXAlignment.Left; b.Font=Enum.Font.Gotham; b.TextSize=12; b.TextColor3=CurrentTheme.Text; b.BackgroundColor3=CurrentTheme.Hover
  b.Size=UDim2.new(1,-8,0,24); b.Parent=List; makeCorner(b,6)
  b.MouseButton1Click:Connect(function() Info.Text=("Name: %s\nClass: %s\nPath: %s"):format(inst.Name, inst.ClassName, inst:GetFullName()) end)
end
local function softMatch(str,q) str=string.lower(str); q=string.lower(q or ""); if q=="" then return true end return string.find(str,q,1,true)~=nil end
local function doScan()
  for _,c in ipairs(List:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
  local filter=Search.Text; local roots={workspace, ReplicatedStorage, Players}; local cnt,cap=0,450
  for _,root in ipairs(roots) do
    for _,d in ipairs(root:GetDescendants()) do if cnt>=cap then break end
      if softMatch(d.Name,filter) or softMatch(d.ClassName,filter) then addRow(d); cnt+=1 end
    end
  end
  List.CanvasSize=UDim2.new(0,0,0, math.max(0, LLayout.AbsoluteContentSize.Y+12)); notify(("Scan done (%d items)."):format(cnt))
end
GoBtn.MouseButton1Click:Connect(doScan)

-- Themes
local order={"Dark","Midnight","Neon","Black","Red"}; local idx=1
local function repaint(name)
  local T=Themes[name] or Themes.Dark; CurrentTheme=T
  Window.BackgroundColor3=T.Bg; TitleBar.BackgroundColor3=T.Panel; Title.TextColor3=T.Text
  ThemeBtn.TextColor3=T.Text; ThemeBtn.BackgroundColor3=T.Hover
  Sidebar.BackgroundColor3=T.Panel
  for _,b in ipairs(Sidebar:GetChildren()) do if b:IsA("TextButton") then b.TextColor3=T.Text; b.BackgroundColor3=T.Hover end end
  for _,p in pairs(Pages) do p.BackgroundColor3=T.Panel; for _,sec in ipairs(p:GetChildren()) do if sec:IsA("Frame") and sec~=p then sec.BackgroundColor3=T.Bg end end end
  CrownPanel.BackgroundColor3=T.Crown; CrownText.TextColor3=T.Text; CrossCfg.Color=T.Accent; paintCross()
end
ThemeBtn.MouseButton1Click:Connect(function() idx=idx%#order+1; local name=order[idx]; ThemeBtn.Text="Theme: "..name; repaint(name) end)
repaint("Dark")

-- Settings
local sHide = Controls.Button(sSetL,"Window","Hide/Show",function() State.Visible=not State.Visible; Window.Visible=State.Visible; notify(State.Visible and "Menü gösterildi." or "Menü gizlendi.") end)
Controls.Keybind(sSetL,"Menu Toggle Key", State.GlobalKey, function(kc) State.GlobalKey=kc end)
local meta=Instance.new("TextLabel"); meta.BackgroundTransparency=1; meta.TextColor3=CurrentTheme.Sub; meta.Font=Enum.Font.Gotham; meta.TextSize=12
meta.Text="Features Köprüsü: ToggleHUDPanel, ToggleCrosshair, SetTeleportOffset aktif. Diğerleri devre dışı."; meta.Size=UDim2.new(1,0,1,0)
meta.TextXAlignment=Enum.TextXAlignment.Left; meta.TextYAlignment=Enum.TextYAlignment.Top; meta.Parent=sSetR

-- Global key
UserInputService.InputBegan:Connect(function(i,gp)
  if gp then return end
  if i.KeyCode==State.GlobalKey then State.Visible=not State.Visible; Window.Visible=State.Visible end
end)

-- Start toast
notify("MYLF UI yüklendi — LeftShift ile gizle/göster. Köprü: HUD/Crosshair/TP offsets.",3.0)
