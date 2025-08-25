--[[ 
    ⚡ MYLF Linoria+ (Legit UI FX Edition)
    - UI Köprü: features.* fonksiyonları varsa güvenli çağırır (ALLOW whitelist)
    - Hile/remote/hook yok; sadece UI.
    - Aç/Kapa: LeftShift
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
    SetTeleportOffset              = true,
    ToggleHUDPanel                 = true,
    ToggleCrosshair                = true,
    ToggleAimbot                   = true,
    ToggleHeadshotRedirect         = true,
    ToggleKillAura                 = true,
    ToggleFireRate                 = true,
    ToggleESP                      = true,
    ToggleEnemyBigHitbox           = true,
    ToggleSpeed                    = true,
    ToggleFly                      = true,
    ToggleInfiniteJump             = true,
    ToggleNoclip                   = true,
    ToggleGodmode                  = true,
    ToggleHardInvisible            = true,
    ToggleTeleport                 = true,
    ToggleAutoBehind               = true,
    ToggleAutoTeleportToEnemy      = true,
}

local function safeCall(fname, ...)
    local fn = features and features[fname]
    if ALLOW[fname] and type(fn) == "function" then
        local ok, err = pcall(fn, ...)
        if not ok then warn("[features."..fname.."] "..tostring(err)) end
    end
end

--// Services
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Stats            = game:GetService("Stats")

local LP        = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

--// Utils
local function tween(o, ti, props, es, ed)
    return TweenService:Create(o, TweenInfo.new(ti, es or Enum.EasingStyle.Quad, ed or Enum.EasingDirection.Out), props)
end
local function round(n, p) p=p or 0 local m=10^p return math.floor(n*m+0.5)/m end
local function clamp(n,a,b) if n<a then return a elseif n>b then return b else return n end end
local function makeCorner(o, r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0, r or 8); c.Parent=o; return c end
local function makeStroke(o, th, tr) local s=Instance.new("UIStroke"); s.Thickness=th or 1; s.Transparency=tr or 0; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=o; return s end
local function pad(o, px) local p=Instance.new("UIPadding"); p.PaddingTop=UDim.new(0,px); p.PaddingBottom=UDim.new(0,px); p.PaddingLeft=UDim.new(0,px); p.PaddingRight=UDim.new(0,px); p.Parent=o; return p end

-- Küçük yıldırım (spark) üretici (GUI)
local function spawnSpark(parent, sz, life)
    local f = Instance.new("Frame")
    f.Size = UDim2.fromOffset(sz.X, sz.Y)
    f.BackgroundColor3 = Color3.fromHSV((os.clock()%1), 1, 1)
    f.BorderSizePixel = 0
    f.AnchorPoint = Vector2.new(0.5,0.5)
    f.Position = UDim2.fromScale(0.5 + (math.random()-0.5)*0.6, 0.5 + (math.random()-0.5)*0.6)
    f.Rotation = math.random(-50,50)
    f.BackgroundTransparency = 0.1
    f.Parent = parent
    task.spawn(function()
        tween(f, life or .18, {BackgroundTransparency = 1, Size = UDim2.fromOffset(0,0)}):Play()
        task.wait(life or .18)
        if f then f:Destroy() end
    end)
end

-- Debounce helper
local function debounced(wait, fn)
    local token = 0
    return function(...)
        token += 1
        local my = token
        local args = {...}
        task.delay(wait, function()
            if my == token then fn(table.unpack(args)) end
        end)
    end
end

--// Theme
local Themes = {
  Dark = {
    Bg=Color3.fromRGB(20,20,26), Panel=Color3.fromRGB(28,28,36),
    Accent=Color3.fromRGB(120,115,245), AccentSoft=Color3.fromRGB(95,90,210),
    Text=Color3.fromRGB(238,238,245), SubText=Color3.fromRGB(170,170,178),
    Stroke=Color3.fromRGB(60,60,72), Hover=Color3.fromRGB(40,40,52),
    Green=Color3.fromRGB(110,210,130), Red=Color3.fromRGB(230,90,96)
  },
}
local CurrentTheme = Themes.Dark

--// Global state
local State = { Visible = true, Dragging = false, GlobalToggleKey = Enum.KeyCode.LeftShift }

--// Root GUIs
local Gui = Instance.new("ScreenGui")
Gui.Name="MYLF_LinoriaPlusFX"; Gui.IgnoreGuiInset=true; Gui.ResetOnSpawn=false; Gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; Gui.Parent=PlayerGui

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

-- Dragging
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
local Title=Instance.new("TextLabel"); Title.BackgroundTransparency=1; Title.Text="⚡ MYLF | Linoria+ FX (UI Bridge)"; Title.Font=Enum.Font.GothamBold; Title.TextSize=16
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

-- Controls
local Controls={}
local function makeRow(parent,label)
  local f=Instance.new("Frame"); f.BackgroundTransparency=1; f.Size=UDim2.new(1,0,0,28); f.Parent=parent
  local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Text=label; l.Font=Enum.Font.Gotham; l.TextSize=13; l.TextXAlignment=Enum.TextXAlignment.Left
  l.TextColor3=CurrentTheme.SubText; l.Size=UDim2.new(0.5,0,1,0); l.Parent=f
  return f,l
end

-- Toggle (Rainbow yıldırım efektli)
function Controls.Toggle(parent,label,default,callback)
  local row,lab=makeRow(parent,label)
  local btn=Instance.new("TextButton"); btn.AutoButtonColor=false; btn.Text=default and "ON" or "OFF"
  btn.Font=Enum.Font.GothamBold; btn.TextSize=12; btn.TextColor3= default and CurrentTheme.Green or CurrentTheme.Red
  btn.BackgroundColor3=CurrentTheme.Hover; btn.Size=UDim2.new(0,78,0,24); btn.Position=UDim2.new(1,-88,0.5,-12); btn.Parent=row
  makeCorner(btn,6); makeStroke(btn,1,.2)

  local halo = Instance.new("UIStroke", btn)
  halo.Thickness=2; halo.Transparency=0.15; halo.Color=Color3.fromRGB(255,255,0); halo.Enabled=false

  local on=default or false
  local fxToken = 0

  local function startFx()
      fxToken += 1
      local my = fxToken
      halo.Enabled = true
      task.spawn(function()
          while on and btn.Parent and fxToken == my do
              halo.Color = Color3.fromHSV((os.clock()*0.5)%1,1,1)
              -- ufak yıldırım parçaları
              spawnSpark(btn, Vector2.new(2 + math.random(0,2), 8 + math.random(0,6)), .16 + math.random()*0.06)
              task.wait(0.08)
          end
      end)
  end
  local function stopFx()
      fxToken += 1
      halo.Enabled = false
  end

  local function applyVisual()
      btn.Text=on and "ON" or "OFF"
      btn.TextColor3= on and CurrentTheme.Green or CurrentTheme.Red
      tween(btn,.08,{BackgroundColor3= on and CurrentTheme.AccentSoft or CurrentTheme.Hover}):Play()
      if on then startFx() else stopFx() end
  end
  applyVisual()

  btn.MouseButton1Click:Connect(function()
    on = not on
    applyVisual()
    if callback then task.spawn(callback,on) end
  end)

  return {
    Get=function() return on end,
    Set=function(v) on = not not v; applyVisual(); if callback then callback(on) end end
  }
end

-- Slider (Alev/Yıldırım animasyonlu dolgu)
function Controls.Slider(parent,label,min,max,default,fmt,callback)
  local row,lab=makeRow(parent,label)
  local frame=Instance.new("Frame"); frame.Size=UDim2.new(0.48,0,0,24); frame.Position=UDim2.new(0.52,0,0.5,-12); frame.BackgroundColor3=CurrentTheme.Hover; frame.Parent=row
  makeCorner(frame,6); makeStroke(frame,1,.15)

  local fill=Instance.new("Frame"); fill.BackgroundColor3=CurrentTheme.Accent; fill.Size=UDim2.new((default-min)/(max-min),0,1,0); fill.Parent=frame; makeCorner(fill,6)

  local grad=Instance.new("UIGradient", fill)
  grad.Color=ColorSequence.new{
      ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,80,0)),   -- turuncu
      ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255,220,0)),  -- sarı (alev)
      ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,0,0))     -- kırmızı
  }
  grad.Rotation=0

  -- üstüne ince "enerji çizgisi"
  local sparkLine = Instance.new("Frame", fill)
  sparkLine.BorderSizePixel = 0
  sparkLine.AnchorPoint = Vector2.new(0.5,0)
  sparkLine.Position = UDim2.new(0.5,0,0,0)
  sparkLine.Size = UDim2.new(1,0,0,2)
  sparkLine.BackgroundColor3 = Color3.fromRGB(255,255,255)
  sparkLine.BackgroundTransparency = 0.35
  local sparkGrad = Instance.new("UIGradient", sparkLine)
  sparkGrad.Color = ColorSequence.new{
      ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
      ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,255,255)),
      ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
  }
  sparkGrad.Transparency = NumberSequence.new{
      NumberSequenceKeypoint.new(0, .7),
      NumberSequenceKeypoint.new(0.5, 0),
      NumberSequenceKeypoint.new(1, .7)
  }

  -- animasyon döngüsü
  task.spawn(function()
      while fill.Parent do
          grad.Offset = Vector2.new((os.clock()*0.4)%1, 0)
          sparkGrad.Offset = Vector2.new((os.clock()*1.2)%1, 0)
          grad.Rotation = (os.clock()*60)%360
          task.wait(0.05)
      end
  end)

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

  return { Get=function() return val end, Set=function(v) v=clamp(v,min,max); val=v; fill.Size=UDim2.new((val-min)/(max-min),0,1,0); valText.Text=(fmt or "%d"):format(val); if callback then callback(val) end end }
end

-- Keybind
function Controls.Keybind(parent,label,defaultKeyCode,onChanged)
  local row,lab=makeRow(parent,label)
  local btn=Instance.new("TextButton"); btn.Size=UDim2.new(0,120,0,24); btn.BackgroundColor3=CurrentTheme.Hover; btn.Font=Enum.Font.GothamBold; btn.TextSize=12
  btn.TextColor3=CurrentTheme.Text; btn.Text=defaultKeyCode and defaultKeyCode.Name or "LeftShift"; btn.Parent=row; makeCorner(btn,6); makeStroke(btn,1,.2)

  local listening=false; local current=defaultKeyCode or Enum.KeyCode.LeftShift
  btn.MouseButton1Click:Connect(function() listening=true; btn.Text="Press..." end)
  UserInputService.InputBegan:Connect(function(input,gp)
    if not listening or gp then return end
    if input.KeyCode~=Enum.KeyCode.Unknown then
      listening=false; current=input.KeyCode; btn.Text=current.Name; if onChanged then onChanged(current) end
    end
  end)
  return {Get=function() return current end, Set=function(kc) current=kc or current; btn.Text=current.Name; if onChanged then onChanged(current) end end }
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

-- Sections
local sCombatL  = newSection(pCombat,   "Aimbot / Weapon")
local sCombatR  = newSection(pCombat,   "Aura / FireRate")
local sVisualsL = newSection(pVisuals,  "ESP / Hitbox")
local sVisualsR = newSection(pVisuals,  "Colors / Misc")
local sMoveL    = newSection(pMovement, "Speed / Fly")
local sMoveR    = newSection(pMovement, "Jump / Noclip / Protection")
local sUtilL    = newSection(pUtility,  "Teleport Controls")
local sUtilR    = newSection(pUtility,  "Auto TP (Offsets)")
local sHUDL     = newSection(pHUD,      "Crown FPS Panel")
local sHUDR     = newSection(pHUD,      "Crosshair / Perf")
local sSetL     = newSection(pSettings, "Global")
local sSetR     = newSection(pSettings, "About")

-- Toggle helper (köprü)
local function addToggle(section, label, featureFnName)
    return Controls.Toggle(section, label, false, function(on)
        safeCall(featureFnName, on)
    end)
end

-- Sliders event bus
local Options, _listeners = {}, {}
local function addSlider(section, key, cfg)
    local fmt = (cfg.Rounding and cfg.Rounding > 0) and ("%."..tostring(cfg.Rounding).."f") or "%d"
    local sl = Controls.Slider(section, cfg.Text or key, cfg.Min or 0, cfg.Max or 100, cfg.Default or 0, fmt, function(v)
        local ls = _listeners[key]
        if ls then for _,fn in ipairs(ls) do pcall(fn, v) end end
    end)
    Options[key] = {
        Get = function() return sl.Get() end,
        Set = function(v) sl.Set(v) end,
        OnChanged = function(fn)
            local t = _listeners[key]
            if not t then t = {}; _listeners[key] = t end
            table.insert(t, fn)
        end
    }
    return Options[key]
end

-- === Combat
addToggle(sCombatL, "🎯 Enable Aimbot",          "ToggleAimbot")
addToggle(sCombatL, "Force Headshot",            "ToggleHeadshotRedirect")
addToggle(sCombatR, "☠️ Kill Aura",              "ToggleKillAura")
addToggle(sCombatR, "Hard Fire Rate",            "ToggleFireRate")

-- === Visuals
addToggle(sVisualsL, "Enable ESP",               "ToggleESP")
addToggle(sVisualsL, "🎯 Enemy Big Hitbox",      "ToggleEnemyBigHitbox")

-- === Movement
addToggle(sMoveL, "Speed Boost (50)",            "ToggleSpeed")
addToggle(sMoveL, "Fly (LCtrl down)",            "ToggleFly")
addToggle(sMoveR, "Infinite Jump",               "ToggleInfiniteJump")
addToggle(sMoveR, "NoClip",                      "ToggleNoclip")
addToggle(sMoveR, "💀 Godmode",                  "ToggleGodmode")
addToggle(sMoveR, "👻 Hard Invisible",           "ToggleHardInvisible")

-- === Utility / TP
addToggle(sUtilL, "Teleport (T Key)",            "ToggleTeleport")
addToggle(sUtilL, "⚡ Always Behind Enemy",      "ToggleAutoBehind")
addToggle(sUtilL, "⚡ Auto Farm Enemy",          "ToggleAutoTeleportToEnemy")

-- === TP Offsets
addSlider(sUtilR, "tpX", {Text="X Offset", Min=-50, Max=50, Default=0, Rounding=0})
addSlider(sUtilR, "tpY", {Text="Y Offset", Min=-50, Max=50, Default=0, Rounding=0})
addSlider(sUtilR, "tpZ", {Text="Z Offset", Min=1, Max=100, Default=25, Rounding=0})

local _tpX, _tpY, _tpZ = 0, 0, 25
local applyTP = debounced(0.08, function()
    safeCall("SetTeleportOffset", _tpX, _tpY, _tpZ)
    if features then features._tpX = _tpX; features._tpY = _tpY; features._tpZ = _tpZ end
end)
Options.tpX:OnChanged(function(v) _tpX = v; applyTP() end)
Options.tpY:OnChanged(function(v) _tpY = v; applyTP() end)
Options.tpZ:OnChanged(function(v) _tpZ = v; applyTP() end)

--========================================================
-- Crown FPS Panel (draggable) + CPU/GPU approx + rainbow underline
--========================================================
local CrownPanel = Instance.new("Frame")
CrownPanel.Name="CrownFPS"; CrownPanel.AnchorPoint=Vector2.new(0.5,0); CrownPanel.Position=UDim2.new(0.5,0,0,8)
CrownPanel.Size=UDim2.fromOffset(260, 34); CrownPanel.BackgroundColor3=Color3.fromRGB(234,198,76)
CrownPanel.Parent=Overlay; makeCorner(CrownPanel,8); makeStroke(CrownPanel,1,.15); pad(CrownPanel,6)

local CrownText = Instance.new("TextLabel")
CrownText.BackgroundTransparency=1; CrownText.Font=Enum.Font.GothamBold; CrownText.TextSize=14; CrownText.TextColor3=Color3.fromRGB(20,20,25)
CrownText.TextXAlignment=Enum.TextXAlignment.Center; CrownText.Size=UDim2.new(1,-12,1,-12); CrownText.Position=UDim2.fromOffset(6,0); CrownText.Parent=CrownPanel
CrownText.Text = "FPS: --  |  CPU: -- ms  |  GPU: -- ms  |  Ping: --"

-- Rainbow bar
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

-- CPU/GPU approx + update
local hbDtAvg, rsDtAvg, hbA, rsA = 0,0,0,0
RunService.Heartbeat:Connect(function(dt) hbA += 1; hbDtAvg = hbDtAvg + (dt - hbDtAvg)/hbA end)
local halfA, frameCount = 0, 0
RunService.RenderStepped:Connect(function(dt)
  rsA += 1; rsDtAvg = rsDtAvg + (dt - rsDtAvg)/rsA
  grad.Offset = Vector2.new(math.sin(os.clock()*0.8)*0.25, 0)
  halfA += dt; frameCount += 1
  if halfA >= 0.5 then
    local fps = round(frameCount/0.5,0); frameCount=0; halfA=0
    local ping="?"
    pcall(function()
      local item = Stats.Network.ServerStatsItem["Data Ping"]; if item then ping = tostring(item:GetValueString()):gsub(" RTT","") end
    end)
    local cpuMs = round(hbDtAvg*1000,1)
    local gpuMs = round(rsDtAvg*1000,1)
    CrownText.Text = ("FPS: %s  |  CPU: %s ms  |  GPU: %s ms  |  Ping: %s"):format(fps, cpuMs, gpuMs, ping)
    local need = CrownText.TextBounds.X + 40
    CrownPanel.Size = UDim2.fromOffset(math.clamp(need, 240, 560), 34)
  end
end)

-- HUD toggles (UI tarafı + köprü)
Controls.Toggle(sHUDL, "Show Crown Panel", false, function(on)
    CrownPanel.Visible = on
    safeCall("ToggleHUDPanel", on)
end)
Controls.Toggle(sHUDR, "Crosshair ON/OFF", false, function(on)
    safeCall("ToggleCrosshair", on)
end)

-- Basit crosshair (UI kozmetik; default kapalı, köprü üstünden açılabilir)
local Crosshair = Instance.new("Frame")
Crosshair.Name="Crosshair"; Crosshair.AnchorPoint=Vector2.new(0.5,0.5); Crosshair.Position=UDim2.fromScale(0.5,0.5)
Crosshair.Size=UDim2.fromOffset(2,2); Crosshair.BackgroundTransparency=1; Crosshair.Parent=Overlay
local CrosshairCfg = { Enabled=false, Gap=6, Length=8, Thickness=2, Opacity=1, Color=CurrentTheme.Accent }
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

-- Settings: Menu keybind + info
local defaultKey = (State and State.GlobalToggleKey) or Enum.KeyCode.LeftShift
Controls.Keybind(sSetL, "Menu Toggle Key", defaultKey, function(kc)
    if State then State.GlobalToggleKey = kc end
    notify("Menu toggle key → "..kc.Name)
end)
local info=Instance.new("TextLabel"); info.BackgroundTransparency=1; info.Font=Enum.Font.Gotham; info.TextSize=12; info.TextColor3=CurrentTheme.SubText
info.Text="UI update cadence ~60 FPS | FX aktif"; info.Size=UDim2.new(1,0,0,16); info.Parent=sSetL

-- Global key toggle
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == State.GlobalToggleKey then
        Window.Visible = not Window.Visible
        notify(Window.Visible and "Menü gösterildi." or "Menü gizlendi.")
    end
end)

-- Sidebar tab bind (en sonda kalsın)
local function bindTab(button, name) button.MouseButton1Click:Connect(function() showPage(name) end) end
bindTab(tCombat,"Combat"); bindTab(tVisuals,"Visuals"); bindTab(tMovement,"Movement")
bindTab(tUtility,"Utility / TP"); bindTab(tHUD,"HUD"); bindTab(tSettings,"Settings")

notify("MYLF Hub Premium Menu (FX)", 3.0)
