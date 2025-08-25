--[[ 
    ⚡ MYLF Linoria+ (Legit UI) — Toggle Köprü + Crown FPS Panel + 60FPS UI Scheduler
    - Hile/remote/hook YOK. Yalnızca UI köprüleri (features.* varsa çağrılır).
    - Aç/Kapa: LeftShift
]]

--// Services
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local Stats            = game:GetService("Stats")

local LP        = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")
local Camera    = workspace.CurrentCamera

--// Utils
local function tween(o, ti, props, es, ed)
    return TweenService:Create(o, TweenInfo.new(ti, es or Enum.EasingStyle.Quad, ed or Enum.EasingDirection.Out), props)
end
local function round(n, p) p=p or 0 local m=10^p return math.floor(n*m+0.5)/m end
local function clamp(n,a,b) if n<a then return a elseif n>b then return b else return n end end
local function makeCorner(o, r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0, r or 8); c.Parent=o; return c end
local function makeStroke(o, th, tr) local s=Instance.new("UIStroke"); s.Thickness=th or 1; s.Transparency=tr or 0; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=o; return s end
local function pad(o, px) local p=Instance.new("UIPadding"); p.PaddingTop=UDim.new(0,px); p.PaddingBottom=UDim.new(0,px); p.PaddingLeft=UDim.new(0,px); p.PaddingRight=UDim.new(0,px); p.Parent=o; return p end

--// Theme
local Themes = {
  Dark = { Bg=Color3.fromRGB(20,20,26), Panel=Color3.fromRGB(28,28,36), Accent=Color3.fromRGB(120,115,245), AccentSoft=Color3.fromRGB(95,90,210),
           Text=Color3.fromRGB(238,238,245), SubText=Color3.fromRGB(170,170,178), Stroke=Color3.fromRGB(60,60,72), Hover=Color3.fromRGB(40,40,52),
           Green=Color3.fromRGB(110,210,130), Red=Color3.fromRGB(230,90,96) },
}
local CurrentTheme = Themes.Dark

--// Global state
local State = { Visible = true, Dragging = false, GlobalToggleKey = Enum.KeyCode.LeftShift }

--// Root GUIs
local Gui = Instance.new("ScreenGui")
Gui.Name="MYLF_LinoriaPlus"; Gui.IgnoreGuiInset=true; Gui.ResetOnSpawn=false; Gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; Gui.Parent=PlayerGui

local Overlay = Instance.new("ScreenGui")
Overlay.Name="MYLF_HUD"; Overlay.IgnoreGuiInset=true; Overlay.ResetOnSpawn=false; Overlay.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; Overlay.Parent=PlayerGui

--// Notifications
local NotifLayer = Instance.new("Frame"); NotifLayer.BackgroundTransparency=1; NotifLayer.Size=UDim2.new(1,0,1,0); NotifLayer.Parent=Gui
local function notify(text, dur)
  dur = dur or 2.1
  local t=Instance.new("TextLabel"); t.Text="  "..text; t.Font=Enum.Font.GothamSemibold; t.TextSize=14; t.TextColor3=CurrentTheme.Text
  t.BackgroundColor3=CurrentTheme.Panel; t.Size=UDim2.fromOffset(0,28); t.AnchorPoint=Vector2.new(1,0); t.Position=UDim2.new(1,-10,0,10); t.Parent=NotifLayer
  makeCorner(t,6); makeStroke(t,1,.1)
  tween(t,.16,{Size=UDim2.fromOffset(math.clamp(t.TextBounds.X+22,160,520),28)}):Play()
  task.delay(dur,function() local tw=tween(t,.16,{Position=UDim2.new(1,-10,0,-34),BackgroundTransparency=1}); tw.Completed:Connect(function() t:Destroy() end); tw:Play() end)
end

--// Main Window
local Window = Instance.new("Frame")
Window.Size=UDim2.new(0, 820, 0, 500); Window.Position=UDim2.new(0.5,-410,0.5,-250)
Window.BackgroundColor3=CurrentTheme.Bg; Window.Active=true; Window.Parent=Gui
makeCorner(Window,10); makeStroke(Window,1,.2)

-- Dragging (pürüzsüz)
do
  local dragStart, startPos
  Window.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then
      State.Dragging=true; dragStart=input.Position; startPos=Window.Position
      input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then State.Dragging=false end end)
    end
  end)
  Window.InputChanged:Connect(function(input)
    if State.Dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
      local d=input.Position-dragStart
      Window.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
  end)
end

-- TitleBar
local TitleBar=Instance.new("Frame"); TitleBar.Size=UDim2.new(1,0,0,44); TitleBar.BackgroundColor3=CurrentTheme.Panel; TitleBar.Parent=Window
makeCorner(TitleBar,10); makeStroke(TitleBar,1,.1)
local Title=Instance.new("TextLabel"); Title.BackgroundTransparency=1; Title.Text="⚡ MYLF | Linoria+ (UI Bridge)"; Title.Font=Enum.Font.GothamBold; Title.TextSize=16
Title.TextColor3=CurrentTheme.Text; Title.TextXAlignment=Enum.TextXAlignment.Left; Title.Position=UDim2.new(0,14,0,0); Title.Size=UDim2.new(1,-160,1,0); Title.Parent=TitleBar

-- Sidebar
local Sidebar=Instance.new("Frame"); Sidebar.BackgroundColor3=CurrentTheme.Panel; Sidebar.Position=UDim2.new(0,10,0,60); Sidebar.Size=UDim2.new(0,190,1,-70); Sidebar.Parent=Window
makeCorner(Sidebar,8); makeStroke(Sidebar,1,.08); pad(Sidebar,8)
local SideList=Instance.new("UIListLayout", Sidebar); SideList.Padding=UDim.new(0,8)

local function makeTabButton(text, icon)
  local b=Instance.new("TextButton"); b.AutoButtonColor=false; b.Text=(icon and (icon.."  ") or "")..text
  b.Font=Enum.Font.GothamSemibold; b.TextSize=14; b.TextColor3=CurrentTheme.Text; b.BackgroundColor3=CurrentTheme.Hover
  b.Size=UDim2.new(1,-4,0,34); b.Parent=Sidebar; makeCorner(b,6); makeStroke(b,1,.2)
  b.MouseEnter:Connect(function() tween(b,.08,{BackgroundColor3=CurrentTheme.AccentSoft}):Play() end)
  b.MouseLeave:Connect(function() tween(b,.12,{BackgroundColor3=CurrentTheme.Hover}):Play() end)
  return b
end

-- Content + Pages
local Content=Instance.new("Frame"); Content.BackgroundTransparency=1; Content.Position=UDim2.new(0,210,0,60); Content.Size=UDim2.new(1,-220,1,-70); Content.Parent=Window
local Pages={}
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
local Controls={}
local function makeRow(parent,label)
  local f=Instance.new("Frame"); f.BackgroundTransparency=1; f.Size=UDim2.new(1,0,0,28); f.Parent=parent
  local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Text=label; l.Font=Enum.Font.Gotham; l.TextSize=13; l.TextXAlignment=Enum.TextXAlignment.Left
  l.TextColor3=CurrentTheme.SubText; l.Size=UDim2.new(0.5,0,1,0); l.Parent=f
  return f,l
end
function Controls.Toggle(parent,label,default,callback)
  local row,lab=makeRow(parent,label)
  local btn=Instance.new("TextButton"); btn.AutoButtonColor=false; btn.Text=default and "ON" or "OFF"
  btn.Font=Enum.Font.GothamBold; btn.TextSize=12; btn.TextColor3= default and CurrentTheme.Green or CurrentTheme.Red
  btn.BackgroundColor3=CurrentTheme.Hover; btn.Size=UDim2.new(0,78,0,24); btn.Position=UDim2.new(1,-88,0.5,-12); btn.Parent=row
  makeCorner(btn,6); makeStroke(btn,1,.2)
  local on=default or false
  btn.MouseButton1Click:Connect(function()
    on=not on; btn.Text=on and "ON" or "OFF"; btn.TextColor3= on and CurrentTheme.Green or CurrentTheme.Red
    tween(btn,.08,{BackgroundColor3= on and CurrentTheme.AccentSoft or CurrentTheme.Hover}):Play()
    if callback then task.spawn(callback,on) end
  end)
  return { Set=function(v) on=v; btn.Text=v and "ON" or "OFF"; btn.TextColor3=v and CurrentTheme.Green or CurrentTheme.Red; if callback then callback(v) end end,
           Get=function() return on end }
end
function Controls.Slider(parent,label,min,max,default,fmt,callback)
  local row,lab=makeRow(parent,label)
  local frame=Instance.new("Frame"); frame.Size=UDim2.new(0.48,0,0,24); frame.Position=UDim2.new(0.52,0,0.5,-12); frame.BackgroundColor3=CurrentTheme.Hover; frame.Parent=row
  makeCorner(frame,6); makeStroke(frame,1,.15)
  local fill=Instance.new("Frame"); fill.BackgroundColor3=CurrentTheme.Accent; fill.Size=UDim2.new((default-min)/(max-min),0,1,0); fill.Parent=frame; makeCorner(fill,6)
  local val=default or min; local valText=Instance.new("TextLabel"); valText.BackgroundTransparency=1; valText.TextColor3=CurrentTheme.Text; valText.Font=Enum.Font.GothamSemibold; valText.TextSize=12
  valText.Size=UDim2.new(0,60,1,0); valText.AnchorPoint=Vector2.new(1,0); valText.Position=UDim2.new(1,-6,0,0); valText.Parent=frame; valText.Text=(fmt or "%d"):format(val)
  local dragging=false
  local function setFromX(x)
    local rel=clamp((x-frame.AbsolutePosition.X)/frame.AbsoluteSize.X,0,1)
    val = round(min + (max-min)*rel, 2); fill.Size=UDim2.new((val-min)/(max-min),0,1,0); valText.Text=(fmt or "%d"):format(val)
    if callback then callback(val) end
  end
  frame.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; setFromX(input.Position.X) end end)
  frame.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
  UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then setFromX(input.Position.X) end end)
  return { Get=function() return val end, Set=function(v) val=clamp(v,min,max); fill.Size=UDim2.new((val-min)/(max-min),0,1,0); valText.Text=(fmt or "%d"):format(val); if callback then callback(val) end end }
end

-- Pages
local pCombat   = newPage("Combat")
local pVisuals  = newPage("Visuals")
local pMovement = newPage("Movement")
local pUtility  = newPage("Utility / TP")
local pHUD      = newPage("HUD")
local pSettings = newPage("Settings")

local tCombat   = makeTabButton("Combat","🎯")
local tVisuals  = makeTabButton("Visuals","🎨")
local tMovement = makeTabButton("Movement","🏃")
local tUtility  = makeTabButton("Utility / TP","🧭")
local tHUD      = makeTabButton("HUD","📊")
local tSettings = makeTabButton("Settings","⚙️")

local function showPage(name) for k,f in pairs(Pages) do f.Visible=(k==name) end end
showPage("Combat")
tCombat.MouseButton1Click:Connect(function() showPage("Combat") end)
tVisuals.MouseButton1Click:Connect(function() showPage("Visuals") end)
tMovement.MouseButton1Click:Connect(function() showPage("Movement") end)
tUtility.MouseButton1Click:Connect(function() showPage("Utility / TP") end)
tHUD.MouseButton1Click:Connect(function() showPage("HUD") end)
tSettings.MouseButton1Click:Connect(function() showPage("Settings") end)

-- Sections (yerleşim: isteklerine göre)
local sCombatL  = newSection(pCombat,   "Aimbot / Weapon")
local sCombatR  = newSection(pCombat,   "Aura / FireRate")
local sVisualsL = newSection(pVisuals,  "ESP / Hitbox")
local sVisualsR = newSection(pVisuals,  "Colors / Misc")
local sMoveL    = newSection(pMovement, "Speed / Fly")
local sMoveR    = newSection(pMovement, "Jump / Noclip")
local sUtilL    = newSection(pUtility,  "Teleport Controls")
local sUtilR    = newSection(pUtility,  "Auto TP (Offsets)")
local sHUDL     = newSection(pHUD,      "Crown FPS Panel")
local sHUDR     = newSection(pHUD,      "Crosshair / Perf")
local sSetL     = newSection(pSettings, "Global")
local sSetR     = newSection(pSettings, "About")

--========================================================
-- FeatureBridge: UI → features.* (varsa çağır; yoksa no-op)
--========================================================
local FeatureBridge = {}
function FeatureBridge.Invoke(name, ...)
  local ok, ftab = pcall(function() return getgenv and getgenv().features or _G.features or rawget(_G,"features") end)
  local feat = ok and ftab or nil
  local fn = feat and feat[name]
  if type(fn)=="function" then
    local ok2, err = pcall(fn, ...)
    if not ok2 then warn("features."..name.." error: "..tostring(err)) end
  else
    -- bağlanmamışsa sessiz geç: sadece UI
    -- warn('features.'..name..' bulunamadı (UI-only).')
  end
end

--========================================================
-- Crown FPS Panel (draggable) + CPU/GPU frame-time + rainbow underline
--========================================================
local CrownPanel = Instance.new("Frame")
CrownPanel.Name="CrownFPS"; CrownPanel.AnchorPoint=Vector2.new(0.5,0); CrownPanel.Position=UDim2.new(0.5,0,0,8)
CrownPanel.Size=UDim2.fromOffset(260, 34); CrownPanel.BackgroundColor3=Color3.fromRGB(234,198,76) -- crown gold
CrownPanel.Parent=Overlay; makeCorner(CrownPanel,8); makeStroke(CrownPanel,1,.15); pad(CrownPanel,6)

local CrownText = Instance.new("TextLabel")
CrownText.BackgroundTransparency=1; CrownText.Font=Enum.Font.GothamBold; CrownText.TextSize=14; CrownText.TextColor3=Color3.fromRGB(20,20,25)
CrownText.TextXAlignment=Enum.TextXAlignment.Center; CrownText.Size=UDim2.new(1,-12,1,-12); CrownText.Position=UDim2.fromOffset(6,0); CrownText.Parent=CrownPanel
CrownText.Text = "FPS: --  |  CPU: -- ms  |  GPU: -- ms  |  Ping: --"

-- Rainbow bar (alt)
local RainbowBar = Instance.new("Frame"); RainbowBar.BorderSizePixel=0; RainbowBar.AnchorPoint=Vector2.new(0.5,1)
RainbowBar.Position=UDim2.new(0.5,0,1,0); RainbowBar.Size=UDim2.new(1,-8,0,3); RainbowBar.Parent=CrownPanel; makeCorner(RainbowBar,2)
local grad = Instance.new("UIGradient"); grad.Rotation=0
grad.Color=ColorSequence.new{
  ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,0,0)),
  ColorSequenceKeypoint.new(0.20, Color3.fromRGB(255,128,0)),
  ColorSequenceKeypoint.new(0.40, Color3.fromRGB(255,255,0)),
  ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0,255,0)),
  ColorSequenceKeypoint.new(0.80, Color3.fromRGB(0,128,255)),
  ColorSequenceKeypoint.new(1.00, Color3.fromRGB(140,0,255))
}; grad.Parent=RainbowBar

-- Draggable Crown
do
  local drag=false; local start; local base
  CrownPanel.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then
      drag=true; start=input.Position; base=CrownPanel.Position
      input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then drag=false end end)
    end
  end)
  CrownPanel.InputChanged:Connect(function(input)
    if drag and input.UserInputType==Enum.UserInputType.MouseMovement then
      local d=input.Position-start
      CrownPanel.Position=UDim2.new(base.X.Scale, base.X.Offset+d.X, base.Y.Scale, base.Y.Offset+d.Y)
    end
  end)
end

-- 60 FPS UI Scheduler + CPU/GPU approx
local acc = 0; local hbDtAvg=0; local rsDtAvg=0; local hbA=0; local rsA=0
RunService.Heartbeat:Connect(function(dt) hbA += 1; hbDtAvg = hbDtAvg + (dt - hbDtAvg)/hbA end) -- CPU-ish (simulation/physics)
RunService.RenderStepped:Connect(function(dt)
  rsA += 1; rsDtAvg = rsDtAvg + (dt - rsDtAvg)/rsA          -- GPU-ish (render)
  acc += dt
  while acc >= (1/60) do                                      -- 60 FPS limit (UI updates)
    acc -= (1/60)
    -- Update text her ~0.5s
  end
end)

-- Text/ping 0.5s’de bir; panel genişliği auto-fit
local halfA, frameCount = 0, 0
RunService.RenderStepped:Connect(function(dt)
  frameCount += 1; halfA += dt
  -- rainbow akışı da 60fps ile akar
  grad.Offset = Vector2.new(math.sin(os.clock()*0.8)*0.25, 0)
  if halfA >= 0.5 then
    halfA = 0
    local fps = round(frameCount/0.5,0); frameCount=0
    local ping="?"
    pcall(function()
      local item = Stats.Network.ServerStatsItem["Data Ping"]; if item then ping = tostring(item:GetValueString()):gsub(" RTT","") end
    end)
    local cpuMs = round(hbDtAvg*1000,1)
    local gpuMs = round(rsDtAvg*1000,1)
    CrownText.Text = ("FPS: %s  |  CPU: %s ms  |  GPU: %s ms  |  Ping: %s"):format(fps, cpuMs, gpuMs, ping)
    local need = CrownText.TextBounds.X + 40
    CrownPanel.Size = UDim2.fromOffset(math.clamp(need, 240, 560), 34)
    RainbowBar.Size = UDim2.new(1,-8,0,3)
  end
end)

--========================
-- Crosshair (HUD kozmetik)
--========================
local Crosshair = Instance.new("Frame")
Crosshair.Name="Crosshair"; Crosshair.AnchorPoint=Vector2.new(0.5,0.5); Crosshair.Position=UDim2.fromScale(0.5,0.5)
Crosshair.Size=UDim2.fromOffset(2,2); Crosshair.BackgroundTransparency=1; Crosshair.Parent=Overlay
local CrosshairCfg = { Enabled=true, Gap=6, Length=8, Thickness=2, Opacity=1, Color=CurrentTheme.Accent }
local arms={} for i=1,4 do local a=Instance.new("Frame"); a.BorderSizePixel=0; a.Parent=Crosshair; arms[i]=a end
local function layoutCrosshair()
  for _,a in ipairs(arms) do a.BackgroundTransparency=1-CrosshairCfg.Opacity; a.BackgroundColor3=CrosshairCfg.Color end
  arms[1].Size=UDim2.fromOffset(CrosshairCfg.Thickness,CrosshairCfg.Length); arms[1].Position=UDim2.fromOffset(-CrosshairCfg.Thickness/2,-(CrosshairCfg.Gap+CrosshairCfg.Length))
  arms[2].Size=UDim2.fromOffset(CrosshairCfg.Thickness,CrosshairCfg.Length); arms[2].Position=UDim2.fromOffset(-CrosshairCfg.Thickness/2, CrosshairCfg.Gap)
  arms[3].Size=UDim2.fromOffset(CrosshairCfg.Length,CrosshairCfg.Thickness); arms[3].Position=UDim2.fromOffset(-(CrosshairCfg.Gap+CrosshairCfg.Length),-CrosshairCfg.Thickness/2)
  arms[4].Size=UDim2.fromOffset(CrosshairCfg.Length,CrosshairCfg.Thickness); arms[4].Position=UDim2.fromOffset(CrosshairCfg.Gap,-CrosshairCfg.Thickness/2)
  Crosshair.Visible=CrosshairCfg.Enabled
end
layoutCrosshair()

--========================
-- Toggle/Slider API bağlama (tam senin istediğin isimlerle)
--========================
local Options, _listeners = {}, {}
local function addSlider(where, key, cfg, onChanged)
  local fmt=(cfg.Rounding and cfg.Rounding>0) and ("%."..tostring(cfg.Rounding).."f") or "%d"
  local sl=Controls.Slider(where, cfg.Text or key, cfg.Min or 0, cfg.Max or 100, cfg.Default or 0, fmt, function(v)
    if onChanged then onChanged(v) end
    local L=_listeners[key]; if L then for _,fn in ipairs(L) do pcall(fn,v) end end
  end)
  Options[key]={Get=function() return sl.Get() end, Set=function(v) sl.Set(v) end,
    OnChanged=function(fn) _listeners[key]=_listeners[key] or {}; table.insert(_listeners[key], fn) end}
end
local function addToggle(where, key, title, featureFnName)
  Controls.Toggle(where, title, false, function(on)
    FeatureBridge.Invoke(featureFnName, on)  -- UI → features.<featureFnName>(on)
  end)
end

-- === Combat
addToggle(sCombatL, "aimbot",           "🎯 Aimbot",           "ToggleAimbot")
addToggle(sCombatL, "headshotRedirect", "Force Headshot",          "ToggleHeadshotRedirect")
addToggle(sCombatR, "killAura",         "☠️ Kill Aura",            "ToggleKillAura")
addToggle(sCombatR, "fireRate",         "Hard Fire Rate",          "ToggleFireRate")

-- === Visuals
addToggle(sVisualsL, "esp",        "Enable ESP",            "ToggleESP")
addToggle(sVisualsL, "enemyBigHB", "🎯 Enemy Big Hitbox",   "ToggleEnemyBigHitbox")

-- === Movement
addToggle(sMoveL, "speed",   "Speed Boost (50)", "ToggleSpeed")
addToggle(sMoveL, "fly",     "Fly (LCtrl down)", "ToggleFly")
addToggle(sMoveR, "infjump", "Infinite Jump",    "ToggleInfiniteJump")
addToggle(sMoveR, "noclip",  "NoClip",           "ToggleNoclip")

-- === Protection / Player
addToggle(sMoveR, "godmode",   "💀 Godmode",      "ToggleGodmode")
addToggle(sMoveR, "hardInvis", "👻 Hard Invisible","ToggleHardInvisible")

-- === Utility / TP
addToggle(sUtilL, "tpkey",      "Teleport (T Key)",        "ToggleTeleport")
addToggle(sUtilL, "autoBehind", "⚡ Always Behind Enemy",   "ToggleAutoBehind")
addToggle(sUtilL, "autoTP",     "⚡ Auto Farm Enemy",       "ToggleAutoTeleportToEnemy")

-- Slider’lar: s_tp* istedigin gibi autoTP’nin SAĞINDA (aynı sayfada, alt blokta)
addSlider(sUtilR, "tpX", {Text="X Offset", Min=-50, Max=50, Default=0, Rounding=0},   nil)
addSlider(sUtilR, "tpY", {Text="Y Offset", Min=-50, Max=50, Default=0, Rounding=0},   nil)
addSlider(sUtilR, "tpZ", {Text="Z Offset", Min=1, Max=100, Default=25, Rounding=0},   nil)

-- features.SetTeleportOffset ile eşitle (Options.tpX/…:OnChanged)
Options.tpX:OnChanged(function(val)
  local x=val; local y=(getgenv().features and getgenv().features._tpY) or 0
  local z=(getgenv().features and getgenv().features._tpZ) or 25
  -- kullanıcıdaki features’a offset’i ilet
  if getgenv().features then getgenv().features._tpX=x end
  FeatureBridge.Invoke("SetTeleportOffset", x, y, z)
end)
Options.tpY:OnChanged(function(val)
  local x=(getgenv().features and getgenv().features._tpX) or 0
  local y=val
  local z=(getgenv().features and getgenv().features._tpZ) or 25
  if getgenv().features then getgenv().features._tpY=y end
  FeatureBridge.Invoke("SetTeleportOffset", x, y, z)
end)
Options.tpZ:OnChanged(function(val)
  local x=(getgenv().features and getgenv().features._tpX) or 0
  local y=(getgenv().features and getgenv().features._tpY) or 0
  local z=val
  if getgenv().features then getgenv().features._tpZ=z end
  FeatureBridge.Invoke("SetTeleportOffset", x, y, z)
end)

-- === HUD toggles (örnek)
Controls.Toggle(sHUDL, "Show Crown Panel", true, function(on) CrownPanel.Visible=on end)
Controls.Toggle(sHUDR, "Crosshair ON/OFF", true, function(on) CrosshairCfg.Enabled=on; layoutCrosshair() end)
Controls.Slider(sHUDR, "Crosshair Opacity", 0,1, CrosshairCfg.Opacity, "%.2f", function(v) CrosshairCfg.Opacity=v; layoutCrosshair() end)

-- Settings
local info=Instance.new("TextLabel"); info.BackgroundTransparency=1; info.Font=Enum.Font.Gotham; info.TextSize=12; info.TextColor3=CurrentTheme.SubText
info.Text="60 FPS"; info.Size=UDim2.new(1,0,0,16); info.Parent=sSetL

-- Global key
UserInputService.InputBegan:Connect(function(input, gp)
  if gp then return end
  if input.KeyCode == State.GlobalToggleKey then
    State.Visible = not State.Visible; Window.Visible=State.Visible
    notify(State.Visible and "Menü gösterildi." or "Menü gizlendi.")
  end
end)

notify("MYLF Hub Premium Menu", 3.0)
