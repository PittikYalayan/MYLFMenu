--[[ 
    ⚡ MYLF Linoria+ Legit UI Framework (Client-Safe) ⚡
    - Tek LocalScript (PlayerGui). Sadece UI/HUD ve güvenli köprü çağrıları.
    - features9.8.lua içindeki izinli fonksiyonlara (ALLOW) safeCall yapar.
    - Sekmeler: Features (grid, otomatik yerleşim), Player, Visuals, HUD, Scanner, Settings
    - Crown FPS Panel (tema + rainbow), Crosshair, TitleBar-only drag (slider sürüklerken menü kaymaz)
    - Global Aç/Kapa: LeftShift
]]

--// === Features Köprüsü ===
local features = {}
do
    local ok, mod = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features9.8.lua"))()
    end)
    features = ok and mod or {}
end

local ALLOW = {
    SetTeleportOffset = true,
    ToggleHUDPanel    = true,
    ToggleCrosshair   = true,

    ToggleAimbot              = true,
    ToggleSilentAim           = true,
    ToggleKillAura            = true,
    ToggleFireRate            = true,
    ToggleESP                 = true,
    ToggleEnemyBigHitbox      = true,
    Togglemyhitbox            = true,
    ToggleSpeed               = true,
    ToggleFly                 = true,
    ToggleInfiniteJump        = true,
    ToggleNoclip              = true,
    ToggleGodmode             = true,
    ToggleHardInvisible       = true,
    ToggleTeleport            = true,
    ToggleAutoBehind          = true,
    ToggleAutoTeleportToEnemy = true,
}

local function safeCall(fname, ...)
    local fn = features and features[fname]
    if ALLOW[fname] and type(fn) == "function" then
        local ok, err = pcall(fn, ...)
        if not ok then warn("[features."..fname.."] "..tostring(err)) end
    end
end

--// Services
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local HttpService        = game:GetService("HttpService")
local Stats              = game:GetService("Stats")

local LP        = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")
local Camera    = workspace.CurrentCamera

--// Utils
local function tween(o, ti, props, es, ed)
    return TweenService:Create(o, TweenInfo.new(ti, es or Enum.EasingStyle.Quad, ed or Enum.EasingDirection.Out), props)
end
local function clamp(n, a, b) if n < a then return a elseif n > b then return b else return n end end
local function round(n, p) p = p or 0 local m = 10^p return math.floor(n*m+0.5)/m end
local function makeCorner(o, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = o; return c end
local function makeStroke(o, th, tr) local s = Instance.new("UIStroke"); s.Thickness = th or 1; s.Transparency = tr or 0; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=o; return s end
local function pad(o, px) local p=Instance.new("UIPadding"); p.PaddingTop=UDim.new(0,px); p.PaddingBottom=UDim.new(0,px); p.PaddingLeft=UDim.new(0,px); p.PaddingRight=UDim.new(0,px); p.Parent=o; return p end
local function hsl(h, s, l) local function f(n) local k=(n+h*12)%12 local a=s*math.min(l,1-l) return l - a*math.max(-1, math.min(math.min(k-3,9-k),1)) end return Color3.new(f(0),f(8),f(4)) end

--// Theme Engine
local Themes = {
    Dark =      {Bg=Color3.fromRGB(20,20,26),  Panel=Color3.fromRGB(28,28,36),  Accent=Color3.fromRGB(120,115,245), AccentSoft=Color3.fromRGB(95,90,210),  Text=Color3.fromRGB(238,238,245), SubText=Color3.fromRGB(170,170,178), Stroke=Color3.fromRGB(60,60,72), Hover=Color3.fromRGB(40,40,52), Green=Color3.fromRGB(110,210,130), Red=Color3.fromRGB(230,90,96), Yellow=Color3.fromRGB(245,209,66)},
    Midnight =  {Bg=Color3.fromRGB(12,14,24),  Panel=Color3.fromRGB(18,20,34),  Accent=Color3.fromRGB(80,180,255),  AccentSoft=Color3.fromRGB(60,140,210), Text=Color3.fromRGB(228,232,240), SubText=Color3.fromRGB(150,158,172), Stroke=Color3.fromRGB(40,48,66), Hover=Color3.fromRGB(26,30,46), Green=Color3.fromRGB(90,205,140),  Red=Color3.fromRGB(230,90,110),  Yellow=Color3.fromRGB(245,209,66)},
    Neon =      {Bg=Color3.fromRGB(18,18,22),  Panel=Color3.fromRGB(22,22,28),  Accent=Color3.fromRGB(255,80,200),  AccentSoft=Color3.fromRGB(210,60,160), Text=Color3.fromRGB(245,245,255), SubText=Color3.fromRGB(172,170,190), Stroke=Color3.fromRGB(70,60,90), Hover=Color3.fromRGB(40,34,60), Green=Color3.fromRGB(110,240,200), Red=Color3.fromRGB(255,100,140), Yellow=Color3.fromRGB(255,230,120)},
    Black =     {Bg=Color3.fromRGB(6,6,8),     Panel=Color3.fromRGB(14,14,18),  Accent=Color3.fromRGB(220,220,230), AccentSoft=Color3.fromRGB(190,190,210), Text=Color3.fromRGB(240,240,245), SubText=Color3.fromRGB(160,162,170), Stroke=Color3.fromRGB(38,38,48),  Hover=Color3.fromRGB(24,24,30),  Green=Color3.fromRGB(120,220,150), Red=Color3.fromRGB(230,80,100),  Yellow=Color3.fromRGB(235,210,110)},
    Red =       {Bg=Color3.fromRGB(24,8,10),   Panel=Color3.fromRGB(32,10,12),  Accent=Color3.fromRGB(230,66,80),   AccentSoft=Color3.fromRGB(190,46,60),  Text=Color3.fromRGB(250,240,242), SubText=Color3.fromRGB(200,150,156), Stroke=Color3.fromRGB(70,30,34),  Hover=Color3.fromRGB(46,16,20),  Green=Color3.fromRGB(120,220,150), Red=Color3.fromRGB(255,90,120),  Yellow=Color3.fromRGB(255,220,120)},
}
local CurrentTheme = Themes.Dark

--// State + Keybinds
local State = { Visible=true, Dragging=false, BindListening=nil, Binds={}, GlobalToggleKey=Enum.KeyCode.LeftShift }

--// Root GUI
local Gui = Instance.new("ScreenGui")
Gui.Name="MYLF_LinoriaPlus"; Gui.IgnoreGuiInset=true; Gui.ResetOnSpawn=false; Gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; Gui.Parent=PlayerGui

-- Notifications
local NotifLayer = Instance.new("Frame"); NotifLayer.Size=UDim2.new(1,0,1,0); NotifLayer.BackgroundTransparency=1; NotifLayer.Parent=Gui
local function notify(text, dur)
    dur = dur or 2.5
    local t=Instance.new("TextLabel"); t.BackgroundColor3=CurrentTheme.Panel; t.TextColor3=CurrentTheme.Text; t.Font=Enum.Font.GothamSemibold; t.TextSize=14
    t.Text="  "..text; t.AnchorPoint=Vector2.new(1,0); t.Position=UDim2.new(1,-10,0,10); t.Size=UDim2.new(0,0,0,28); t.TextXAlignment=Enum.TextXAlignment.Left; t.Parent=NotifLayer
    makeCorner(t,6); makeStroke(t,1,.1); Instance.new("UISizeConstraint", t).MaxSize=Vector2.new(520,40)
    tween(t,.18,{Size=UDim2.new(0, math.clamp(t.TextBounds.X+22,160,500),0,28)}):Play()
    task.delay(dur,function() local tw=tween(t,.18,{Position=UDim2.new(1,-10,0,-34), BackgroundTransparency=1}); tw.Completed:Connect(function() t:Destroy() end); tw:Play() end)
end

-- Main Window
local Window = Instance.new("Frame")
Window.Name="Window"; Window.Size=UDim2.new(0, 840, 0, 520); Window.Position=UDim2.new(0.5,-420,0.5,-260); Window.BackgroundColor3=CurrentTheme.Bg; Window.Active=true; Window.Parent=Gui
makeCorner(Window,10); makeStroke(Window,1,.2)

-- TitleBar (Drag sadece burada!)
local TitleBar = Instance.new("Frame")
TitleBar.Name="TitleBar"; TitleBar.Size=UDim2.new(1,0,0,44); TitleBar.BackgroundColor3=CurrentTheme.Panel; TitleBar.Parent=Window
makeCorner(TitleBar,10); makeStroke(TitleBar,1,.1)

local Title = Instance.new("TextLabel"); Title.BackgroundTransparency=1; Title.Text="⚡ MYLF | Linoria+ (Legit Dev UI)"; Title.Font=Enum.Font.GothamBold; Title.TextSize=16
Title.TextColor3=CurrentTheme.Text; Title.TextXAlignment=Enum.TextXAlignment.Left; Title.Size=UDim2.new(1,-180,1,0); Title.Position=UDim2.new(0,14,0,0); Title.Parent=TitleBar

local ThemeBtn = Instance.new("TextButton")
ThemeBtn.Text="Theme: Dark"; ThemeBtn.AutoButtonColor=false; ThemeBtn.Font=Enum.Font.GothamSemibold; ThemeBtn.TextSize=13; ThemeBtn.TextColor3=CurrentTheme.Text
ThemeBtn.BackgroundColor3=CurrentTheme.Hover; ThemeBtn.AnchorPoint=Vector2.new(1,0.5); ThemeBtn.Position=UDim2.new(1,-10,0.5,0); ThemeBtn.Size=UDim2.new(0,160,0,26); ThemeBtn.Parent=TitleBar
makeCorner(ThemeBtn,6); makeStroke(ThemeBtn,1,.15)

do -- Drag only on TitleBar
    local dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            State.Dragging = true; dragStart=input.Position; startPos=Window.Position
            input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then State.Dragging=false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if State.Dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
            local d=input.Position-dragStart
            Window.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
end

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.BackgroundColor3=CurrentTheme.Panel; Sidebar.Position=UDim2.new(0,10,0,58); Sidebar.Size=UDim2.new(0,180,1,-68); Sidebar.Parent=Window
makeCorner(Sidebar,8); makeStroke(Sidebar,1,.08); pad(Sidebar,8)
local SideList = Instance.new("UIListLayout", Sidebar); SideList.Padding=UDim.new(0,8)

local function makeTabButton(text, icon)
    local b=Instance.new("TextButton"); b.AutoButtonColor=false; b.Text=(icon and (icon.."  ") or "")..text; b.Font=Enum.Font.GothamSemibold; b.TextSize=14
    b.TextColor3=CurrentTheme.Text; b.BackgroundColor3=CurrentTheme.Hover; b.Size=UDim2.new(1,-4,0,34); b.Parent=Sidebar; makeCorner(b,6); makeStroke(b,1,.2)
    b.MouseEnter:Connect(function() tween(b,.08,{BackgroundColor3=CurrentTheme.AccentSoft}):Play() end)
    b.MouseLeave:Connect(function() tween(b,.12,{BackgroundColor3=CurrentTheme.Hover}):Play() end)
    return b
end

-- Content container (Features sayfası scrollable grid olacak)
local Content = Instance.new("Frame")
Content.BackgroundTransparency=1; Content.Position=UDim2.new(0,200,0,58); Content.Size=UDim2.new(1,-210,1,-68); Content.Parent=Window

-- Pages
local Pages={}
local function newPage(name)
    local p=Instance.new("Frame"); p.Visible=false; p.BackgroundColor3=CurrentTheme.Panel; p.Size=UDim2.new(1,0,1,0); p.Parent=Content
    makeCorner(p,8); makeStroke(p,1,.08); pad(p,10)
    Pages[name]=p; return p
end

-- Features için özel Grid sayfası (taşma fix: otomatik yerleşim)
local function newGridPage(name, cols, rows, padPx)
    local sf = Instance.new("ScrollingFrame")
    sf.Visible=false; sf.BackgroundColor3=CurrentTheme.Panel; sf.Size=UDim2.new(1,0,1,0); sf.Parent=Content
    sf.ScrollBarThickness=6; sf.CanvasSize=UDim2.new()
    makeCorner(sf,8); makeStroke(sf,1,.08); pad(sf,10)

    local grid = Instance.new("UIGridLayout", sf)
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.FillDirection = Enum.FillDirection.Horizontal
    grid.CellPadding = UDim2.new(0, padPx or 10, 0, padPx or 10)
    grid.FillDirectionMaxColumns = cols or 3
    -- Hücre boyutu: genişlik = 1/cols, yükseklik = 1/rows
    local cp = padPx or 10
    grid.CellSize = UDim2.new(1/(cols or 3), -((cp)*((cols or 3)-1))/ (cols or 3), 1/(rows or 2), -((cp)*((rows or 2)-1))/ (rows or 2))

    Pages[name] = sf
    return sf
end

local function newSection(parent, title)
    local s=Instance.new("Frame"); s.BackgroundColor3=CurrentTheme.Bg; s.Parent=parent
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
    l.TextColor3=CurrentTheme.SubText; l.Size=UDim2.new(0.6,0,1,0); l.Parent=f
    return f,l
end
function Controls.Toggle(parent,label,default,callback)
    local row,lab=makeRow(parent,label)
    local btn=Instance.new("TextButton"); btn.AutoButtonColor=false; btn.Text=default and "ON" or "OFF"; btn.Font=Enum.Font.GothamBold; btn.TextSize=12
    btn.TextColor3= default and CurrentTheme.Green or CurrentTheme.Red; btn.BackgroundColor3=CurrentTheme.Hover; btn.Size=UDim2.new(0,78,0,24)
    btn.Position=UDim2.new(1,-88,0.5,-12); btn.Parent=row; makeCorner(btn,6); makeStroke(btn,1,.2)
    local on=default or false
    btn.MouseButton1Click:Connect(function()
        on=not on; btn.Text=on and "ON" or "OFF"; btn.TextColor3= on and CurrentTheme.Green or CurrentTheme.Red
        tween(btn,.08,{BackgroundColor3= on and CurrentTheme.AccentSoft or CurrentTheme.Hover}):Play()
        if callback then task.spawn(callback,on) end
    end)
    return {Set=function(v) on=v; btn.Text=v and "ON" or "OFF"; btn.TextColor3=v and CurrentTheme.Green or CurrentTheme.Red; if callback then callback(v) end end, Get=function() return on end}
end
function Controls.Slider(parent,label,min,max,default,fmt,callback)
    local row,lab=makeRow(parent,label)
    local frame=Instance.new("Frame"); frame.Size=UDim2.new(0.38,0,0,24); frame.Position=UDim2.new(0.62,0,0.5,-12); frame.BackgroundColor3=CurrentTheme.Hover; frame.Parent=row
    makeCorner(frame,6); makeStroke(frame,1,.15)
    local fill=Instance.new("Frame"); fill.BackgroundColor3=CurrentTheme.Accent; fill.Size=UDim2.new((default-min)/(max-min),0,1,0); fill.Parent=frame; makeCorner(fill,6)
    local valText=Instance.new("TextLabel"); valText.BackgroundTransparency=1; valText.TextColor3=CurrentTheme.Text; valText.Font=Enum.Font.GothamSemibold; valText.TextSize=12
    valText.Size=UDim2.new(0,60,1,0); valText.AnchorPoint=Vector2.new(1,0); valText.Position=UDim2.new(1,-6,0,0); valText.Parent=frame; valText.Text=(fmt or "%d"):format(default)
    local dragging=false; local value=default or min
    local function setFromX(x)
        local rel=clamp((x-frame.AbsolutePosition.X)/frame.AbsoluteSize.X,0,1)
        value = round(min + (max-min)*rel, 2); fill.Size=UDim2.new((value-min)/(max-min),0,1,0); valText.Text=(fmt or "%d"):format(value)
        if callback then callback(value) end
    end
    frame.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; setFromX(input.Position.X) end end)
    frame.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then setFromX(input.Position.X) end end)
    return {Set=function(v) value=clamp(v,min,max); fill.Size=UDim2.new((value-min)/(max-min),0,1,0); valText.Text=(fmt or "%d"):format(value); if callback then callback(value) end end, Get=function() return value end}
end
function Controls.Dropdown(parent,label,items,defaultIdx,callback)
    local row,lab=makeRow(parent,label)
    local btn=Instance.new("TextButton"); btn.AutoButtonColor=false; btn.Font=Enum.Font.GothamSemibold; btn.TextSize=12; btn.TextColor3=CurrentTheme.Text
    btn.BackgroundColor3=CurrentTheme.Hover; btn.Size=UDim2.new(0,160,0,24); btn.Position=UDim2.new(1,-170,0.5,-12); btn.Parent=row; makeCorner(btn,6); makeStroke(btn,1,.15)
    local idx=defaultIdx or 1; btn.Text=items[idx] or "-"
    local listFrame=Instance.new("Frame"); listFrame.Visible=false; listFrame.BackgroundColor3=CurrentTheme.Panel; listFrame.Size=UDim2.new(0,160,0, math.min(6,#items)*24+10)
    listFrame.AnchorPoint=Vector2.new(0,0); listFrame.Position=UDim2.new(1,-170,0.5,14); listFrame.Parent=row; makeCorner(listFrame,6); makeStroke(listFrame,1,.15); pad(listFrame,6)
    local ul=Instance.new("UIListLayout", listFrame); ul.Padding=UDim.new(0,6)
    for i,v in ipairs(items) do
        local it=Instance.new("TextButton"); it.AutoButtonColor=false; it.Font=Enum.Font.Gotham; it.TextSize=12; it.TextColor3=CurrentTheme.Text; it.Text=v
        it.BackgroundColor3=CurrentTheme.Hover; it.Size=UDim2.new(1,0,0,24); it.Parent=listFrame; makeCorner(it,6)
        it.MouseEnter:Connect(function() tween(it,.08,{BackgroundColor3=CurrentTheme.AccentSoft}):Play() end)
        it.MouseLeave:Connect(function() tween(it,.12,{BackgroundColor3=CurrentTheme.Hover}):Play() end)
        it.MouseButton1Click:Connect(function() idx=i; btn.Text=v; listFrame.Visible=false; if callback then callback(v,i) end end)
    end
    btn.MouseButton1Click:Connect(function() listFrame.Visible=not listFrame.Visible end)
    return {SetIndex=function(i) if items[i] then idx=i; btn.Text=items[i]; if callback then callback(items[i],i) end end end, GetIndex=function() return idx end, GetValue=function() return items[idx] end}
end

-- Overlay (Crosshair + Crown Panel)
local Overlay=Instance.new("ScreenGui"); Overlay.Name="MYLF_HUD"; Overlay.IgnoreGuiInset=true; Overlay.ResetOnSpawn=false; Overlay.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; Overlay.Parent=PlayerGui

-- Crosshair
local Crosshair=Instance.new("Frame"); Crosshair.Name="Crosshair"; Crosshair.AnchorPoint=Vector2.new(.5,.5); Crosshair.Position=UDim2.fromScale(.5,.5)
Crosshair.Size=UDim2.fromOffset(2,2); Crosshair.BackgroundTransparency=1; Crosshair.Visible=true; Crosshair.Parent=Overlay
local arms={} for i=1,4 do local a=Instance.new("Frame"); a.BorderSizePixel=0; a.Parent=Crosshair; arms[i]=a end
local CrosshairCfg={Enabled=true, Gap=6, Length=8, Thickness=2, Opacity=1, Color=CurrentTheme.Accent}
local function layoutCrosshair()
    for _,a in ipairs(arms) do a.BackgroundTransparency=1-CrosshairCfg.Opacity; a.BackgroundColor3=CrosshairCfg.Color end
    arms[1].Size=UDim2.fromOffset(CrosshairCfg.Thickness, CrosshairCfg.Length); arms[1].Position=UDim2.fromOffset(-CrosshairCfg.Thickness/2, -(CrosshairCfg.Gap+CrosshairCfg.Length))
    arms[2].Size=UDim2.fromOffset(CrosshairCfg.Thickness, CrosshairCfg.Length); arms[2].Position=UDim2.fromOffset(-CrosshairCfg.Thickness/2,  CrosshairCfg.Gap)
    arms[3].Size=UDim2.fromOffset(CrosshairCfg.Length, CrosshairCfg.Thickness); arms[3].Position=UDim2.fromOffset(-(CrosshairCfg.Gap+CrosshairCfg.Length),-CrosshairCfg.Thickness/2)
    arms[4].Size=UDim2.fromOffset(CrosshairCfg.Length, CrosshairCfg.Thickness); arms[4].Position=UDim2.fromOffset( CrosshairCfg.Gap, -CrosshairCfg.Thickness/2)
    Crosshair.Visible=CrosshairCfg.Enabled
end
layoutCrosshair()

-- Crown FPS Panel (tema + rainbow)
local CrownPanel=Instance.new("Frame"); CrownPanel.AnchorPoint=Vector2.new(.5,0); CrownPanel.Position=UDim2.new(.5,0,0,8); CrownPanel.Size=UDim2.fromOffset(280,34)
CrownPanel.BackgroundColor3=CurrentTheme.Yellow; CrownPanel.Parent=Overlay; makeCorner(CrownPanel,8); makeStroke(CrownPanel,1,.15); pad(CrownPanel,6)
local CrownText=Instance.new("TextLabel"); CrownText.BackgroundTransparency=1; CrownText.Font=Enum.Font.GothamBold; CrownText.TextSize=14; CrownText.TextColor3=Color3.fromRGB(20,20,25)
CrownText.TextXAlignment=Enum.TextXAlignment.Center; CrownText.Size=UDim2.new(1,-12,1,-10); CrownText.Position=UDim2.fromOffset(6,0); CrownText.Parent=CrownPanel
CrownText.Text="FPS: --  |  CPU: -- ms  |  GPU: -- ms  |  Ping: --"
local RainbowBar=Instance.new("Frame"); RainbowBar.BorderSizePixel=0; RainbowBar.AnchorPoint=Vector2.new(.5,1); RainbowBar.Position=UDim2.new(.5,0,1,0); RainbowBar.Size=UDim2.new(1,-8,0,3); RainbowBar.Parent=CrownPanel; makeCorner(RainbowBar,2)
local grad=Instance.new("UIGradient", RainbowBar)

local hbAvg, rsAvg, hbN, rsN, halfA, frameCount = 0,0,0,0,0,0
RunService.Heartbeat:Connect(function(dt) hbN+=1; hbAvg=hbAvg + (dt - hbAvg)/hbN end)
RunService.RenderStepped:Connect(function(dt)
    rsN+=1; rsAvg=rsAvg + (dt - rsAvg)/rsN
    halfA += dt; frameCount += 1
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromHSV((os.clock()*0.1)%1,1,1)),
        ColorSequenceKeypoint.new(0.50, Color3.fromHSV((os.clock()*0.1+0.33)%1,1,1)),
        ColorSequenceKeypoint.new(1.00, Color3.fromHSV((os.clock()*0.1+0.66)%1,1,1)),
    }
    if halfA >= 0.5 then
        local fps=round(frameCount/halfA,0); frameCount=0; halfA=0
        local ping="?"
        pcall(function() local it=Stats.Network.ServerStatsItem["Data Ping"]; if it then ping=tostring(it:GetValueString()):gsub(" RTT","") end end)
        CrownText.Text=("FPS: %s  |  CPU: %s ms  |  GPU: %s ms  |  Ping: %s"):format(fps, round(hbAvg*1000,1), round(rsAvg*1000,1), ping)
        local need=CrownText.TextBounds.X + 40; CrownPanel.Size=UDim2.fromOffset(math.clamp(need, 260, 600), 34)
    end
end)

-- Pages
local pFeatures = newGridPage("Features", 3, 2, 10) -- otomatik konumlanır, taşma yok (3 sütun x 2 satır)
local pPlayer   = newPage("Player")
local pVisuals  = newPage("Visuals")
local pHUD      = newPage("HUD")
local pScanner  = newPage("Scanner")
local pSettings = newPage("Settings")

-- Tabs
local tFeatures = makeTabButton("Features","🛠")
local tPlayer   = makeTabButton("Player","👤")
local tVisuals  = makeTabButton("Visuals","🎨")
local tHUD      = makeTabButton("HUD","📊")
local tScanner  = makeTabButton("Scanner","🔍")
local tSettings = makeTabButton("Settings","⚙️")

local function showPage(name) for k,f in pairs(Pages) do f.Visible=(k==name) end end
showPage("Features")
tFeatures.MouseButton1Click:Connect(function() showPage("Features") end)
tPlayer.MouseButton1Click:Connect(function() showPage("Player") end)
tVisuals.MouseButton1Click:Connect(function() showPage("Visuals") end)
tHUD.MouseButton1Click:Connect(function() showPage("HUD") end)
tScanner.MouseButton1Click:Connect(function() showPage("Scanner") end)
tSettings.MouseButton1Click:Connect(function() showPage("Settings") end)

--========== FEATURES (grid hücreleri: otomatik) ==========
-- 6 hücre: Combat / Visuals / Movement / Protection / Utility / Offsets
local sFCombat   = newSection(pFeatures, "Rage / Combat")
local sFVisuals  = newSection(pFeatures, "Visuals / ESP")
local sFMove     = newSection(pFeatures, "Movement")
local sFProt     = newSection(pFeatures, "Protection")
local sFUtil     = newSection(pFeatures, "Utility / TP")
local sFOffsets  = newSection(pFeatures, "Teleport Offsets")

-- Combat
Controls.Toggle(sFCombat,"Aimbot",false,function(on) safeCall("ToggleAimbot", on) end)
Controls.Toggle(sFCombat,"Silent Aim",false,function(on) safeCall("ToggleSilentAim", on) end)
Controls.Toggle(sFCombat,"☠️ Kill Aura",false,function(on) safeCall("ToggleKillAura", on) end)
Controls.Toggle(sFCombat,"Hard Fire Rate",false,function(on) safeCall("ToggleFireRate", on) end)

-- Visuals
Controls.Toggle(sFVisuals,"Enable ESP",false,function(on) safeCall("ToggleESP", on) end)
Controls.Toggle(sFVisuals,"🎯 Enemy Big Hitbox",false,function(on) safeCall("ToggleEnemyBigHitbox", on) end)
Controls.Toggle(sFVisuals,"My Hitbox",false,function(on) safeCall("Togglemyhitbox", on) end)

-- Movement
Controls.Toggle(sFMove,"Speed Boost",false,function(on) safeCall("ToggleSpeed", on) end)
Controls.Toggle(sFMove,"Fly (LCtrl)",false,function(on) safeCall("ToggleFly", on) end)
Controls.Toggle(sFMove,"Infinite Jump",false,function(on) safeCall("ToggleInfiniteJump", on) end)
Controls.Toggle(sFMove,"NoClip",false,function(on) safeCall("ToggleNoclip", on) end)

-- Protection
Controls.Toggle(sFProt,"💀 Godmode",false,function(on) safeCall("ToggleGodmode", on) end)
Controls.Toggle(sFProt,"👻 Hard Invisible",false,function(on) safeCall("ToggleHardInvisible", on) end)

-- Utility / TP
Controls.Toggle(sFUtil,"Teleport (T)",false,function(on) safeCall("ToggleTeleport", on) end)
Controls.Toggle(sFUtil,"⚡ Always Behind",false,function(on) safeCall("ToggleAutoBehind", on) end)
Controls.Toggle(sFUtil,"⚡ Auto Farm Enemy",false,function(on) safeCall("ToggleAutoTeleportToEnemy", on) end)

-- Offsets (slider)
local tpX,tpY,tpZ = 0,0,25
Controls.Slider(sFOffsets,"tpX",-50,50,tpX,"%0.0f",function(v) tpX=v; safeCall("SetTeleportOffset", tpX,tpY,tpZ) end)
Controls.Slider(sFOffsets,"tpY",-50,50,tpY,"%0.0f",function(v) tpY=v; safeCall("SetTeleportOffset", tpX,tpY,tpZ) end)
Controls.Slider(sFOffsets,"tpZ",  1,100,tpZ,"%0.0f",function(v) tpZ=v; safeCall("SetTeleportOffset", tpX,tpY,tpZ) end)

--========== PLAYER ==========
local function newHalfSection(parent,title) local s=Instance.new("Frame"); s.BackgroundColor3=CurrentTheme.Bg; s.Size=UDim2.new(0.5,-8,1,0); s.Parent=parent; makeCorner(s,8); makeStroke(s,1,.08); pad(s,10)
local t=Instance.new("TextLabel"); t.BackgroundTransparency=1; t.Text=title; t.Font=Enum.Font.GothamBold; t.TextSize=14; t.TextColor3=CurrentTheme.Text; t.Size=UDim2.new(1,0,0,18); t.Parent=s
local l=Instance.new("UIListLayout", s); l.Padding=UDim.new(0,8); return s end

local sMovement = newHalfSection(pPlayer, "Movement / Camera")
local sTools    = newHalfSection(pPlayer, "Utilities")

Controls.Dropdown(sMovement, "Camera Mode", {"ThirdPerson","FirstPerson","Orbital"}, 1, function(v)
    if v=="ThirdPerson" then LP.CameraMode = Enum.CameraMode.Classic; Camera.CameraType=Enum.CameraType.Custom
    elseif v=="FirstPerson" then LP.CameraMode = Enum.CameraMode.LockFirstPerson; Camera.CameraType=Enum.CameraType.Custom
    elseif v=="Orbital" then LP.CameraMode = Enum.CameraMode.Classic; Camera.CameraType=Enum.CameraType.Orbital end
    notify("Kamera: "..v)
end)
Controls.Slider(sMovement, "Field of View", 60, 100, Camera.FieldOfView, "%d", function(v) Camera.FieldOfView=v end)

local swayConn
Controls.Toggle(sMovement, "Camera Sway", false, function(on)
    if swayConn then swayConn:Disconnect(); swayConn=nil end
    if on then local t=0; swayConn = RunService.RenderStepped:Connect(function(dt) t+=dt; Camera.CFrame = Camera.CFrame * CFrame.Angles(0,0, math.sin(t*1.2)*0.0008) end) end
end)

Controls.Button(sTools,"Waypoint","Add Current",function()
    local char=LP.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if hrp then local nm="WP-"..string.sub(HttpService:GenerateGUID(false),1,4); local f=workspace:FindFirstChild("MYLF_Waypoints_Local"); if not f then f=Instance.new("Folder",workspace); f.Name="MYLF_Waypoints_Local" end
        local part=Instance.new("Part"); part.Anchored=true; part.CanCollide=false; part.Transparency=1; part.Size=Vector3.new(1,1,1); part.CFrame=CFrame.new(hrp.Position+Vector3.new(0,3,0)); part.Parent=f
        local att=Instance.new("Attachment", part); local bb=Instance.new("BillboardGui"); bb.Adornee=att; bb.Size=UDim2.fromOffset(160,40); bb.AlwaysOnTop=true; bb.Parent=part
        local label=Instance.new("TextLabel"); label.Size=UDim2.new(1,0,1,0); label.BackgroundColor3=CurrentTheme.Panel; label.TextColor3=CurrentTheme.Text; label.Font=Enum.Font.GothamBold; label.TextSize=14; label.Text="📍 "..nm; label.Parent=bb; makeCorner(label,6); makeStroke(label,1,.15)
        notify("Waypoint eklendi: "..nm)
    else notify("Karakter bulunamadı.",2.0) end
end)
Controls.Button(sTools,"Waypoint","Clear All",function()
    local f=workspace:FindFirstChild("MYLF_Waypoints_Local"); if f then f:Destroy() end; notify("Tüm waypoint'ler silindi.")
end)

--========== VISUALS ==========
local sCross = newHalfSection(pVisuals, "Crosshair")
local sTheme = newHalfSection(pVisuals, "Theme / Colors")

local crossToggle = Controls.Toggle(sCross, "Enable Crosshair", true, function(on)
    CrosshairCfg.Enabled=on; layoutCrosshair(); safeCall("ToggleCrosshair", on)
end)
Controls.Slider(sCross,"Gap",0,30,CrosshairCfg.Gap,"%d",function(v) CrosshairCfg.Gap=v; layoutCrosshair() end)
Controls.Slider(sCross,"Length",2,40,CrosshairCfg.Length,"%d",function(v) CrosshairCfg.Length=v; layoutCrosshair() end)
Controls.Slider(sCross,"Thickness",1,8,CrosshairCfg.Thickness,"%d",function(v) CrosshairCfg.Thickness=v; layoutCrosshair() end)
Controls.Slider(sCross,"Opacity",0,1,CrosshairCfg.Opacity,"%.2f",function(v) CrosshairCfg.Opacity=v; layoutCrosshair() end)
Controls.Color(sCross,"Color", CrosshairCfg.Color, function(c) CrosshairCfg.Color=c; layoutCrosshair() end)

local themeOrder={"Dark","Midnight","Neon","Black","Red"}
local function repaintTheme(name)
    local T=Themes[name] or Themes.Dark; CurrentTheme=T
    Window.BackgroundColor3=T.Bg; TitleBar.BackgroundColor3=T.Panel; Title.TextColor3=T.Text
    ThemeBtn.TextColor3=T.Text; ThemeBtn.BackgroundColor3=T.Hover; Sidebar.BackgroundColor3=T.Panel
    for _,b in ipairs(Sidebar:GetChildren()) do if b:IsA("TextButton") then b.TextColor3=T.Text; b.BackgroundColor3=T.Hover end end
    for _,p in pairs(Pages) do
        p.BackgroundColor3=T.Panel
        for _,sec in ipairs(p:GetChildren()) do if sec:IsA("Frame") and sec~=p then sec.BackgroundColor3=T.Bg end end
    end
    CrosshairCfg.Color = CrosshairCfg.Color or T.Accent; layoutCrosshair()
    CrownPanel.BackgroundColor3=T.Yellow
end
Controls.Dropdown(sTheme,"Theme", themeOrder, 1, function(val)
    repaintTheme(val); ThemeBtn.Text="Theme: "..val; notify("Tema: "..val)
end)
Controls.Color(sTheme, "Accent Override", CurrentTheme.Accent, function(c) CurrentTheme.Accent=c; layoutCrosshair(); notify("Accent güncellendi.") end)

--========== HUD ==========
local sHudL = newHalfSection(pHUD, "Crown Performance Panel")
local sHudR = newHalfSection(pHUD, "HUD Toggles")

local hudToggle = Controls.Toggle(sHudR, "Show Crown Panel", true, function(on)
    CrownPanel.Visible=on; safeCall("ToggleHUDPanel", on)
end)
Controls.Button(sHudL, "Snapshot", "Notify Now", function()
    notify("HUD aktif — Crown panel üstte.", 2.0)
end)

--========== SCANNER ==========
local sScanL = newHalfSection(pScanner,"Explorer")
local sScanR = newHalfSection(pScanner,"Details")

local bar=Instance.new("Frame", sScanL); bar.Size=UDim2.new(1,0,0,28); bar.BackgroundColor3=CurrentTheme.Hover; makeCorner(bar,6)
local search=Instance.new("TextBox",bar); search.Size=UDim2.new(1,-80,1,0); search.Position=UDim2.new(0,6,0,0)
search.ClearTextOnFocus=false; search.PlaceholderText="Filter (name/class)"; search.Text=""; search.TextColor3=CurrentTheme.Text; search.Font=Enum.Font.Gotham; search.TextSize=12; search.BackgroundTransparency=1
local btn=Instance.new("TextButton",bar); btn.Text="Scan"; btn.Size=UDim2.new(0,66,1,0); btn.AnchorPoint=Vector2.new(1,0); btn.Position=UDim2.new(1,-6,0,0)
btn.Font=Enum.Font.GothamSemibold; btn.TextSize=12; btn.TextColor3=CurrentTheme.Text; btn.BackgroundColor3=CurrentTheme.Accent; makeCorner(btn,6)

local list=Instance.new("ScrollingFrame", sScanL); list.Active=true; list.CanvasSize=UDim2.new(); list.ScrollBarThickness=6
list.BackgroundColor3=CurrentTheme.Bg; list.Size=UDim2.new(1,0,1,-40); list.Position=UDim2.new(0,0,0,34); makeCorner(list,6); makeStroke(list,1,.08)
local lay=Instance.new("UIListLayout", list); lay.Padding=UDim.new(0,6)

local info=Instance.new("TextLabel", sScanR); info.Size=UDim2.new(1,0,1,0); info.BackgroundColor3=CurrentTheme.Bg; info.TextColor3=CurrentTheme.Text
info.TextWrapped=true; info.TextXAlignment=Enum.TextXAlignment.Left; info.TextYAlignment=Enum.TextYAlignment.Top; info.Font=Enum.Font.Gotham; info.TextSize=12; info.Text="Select an object"
makeCorner(info,6); makeStroke(info,1,.08); pad(info,8)

local function softMatch(str,q) str=string.lower(str or ""); q=string.lower(q or ""); if q=="" then return true end; return string.find(str,q,1,true)~=nil end
local function addRow(inst)
    local b=Instance.new("TextButton", list); b.Size=UDim2.new(1,-6,0,24); b.TextXAlignment=Enum.TextXAlignment.Left
    b.Font=Enum.Font.Gotham; b.TextSize=12; b.TextColor3=CurrentTheme.Text; b.BackgroundColor3=CurrentTheme.Hover; b.Text=("%s  (%s)"):format(inst.Name, inst.ClassName); makeCorner(b,6)
    b.MouseButton1Click:Connect(function() info.Text=("Name: %s\nClass: %s\nPath: %s"):format(inst.Name, inst.ClassName, inst:GetFullName()) end)
end
local function doScan()
    for _,c in ipairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    local filter=search.Text; local roots={workspace, game:GetService("ReplicatedStorage"), Players}; local count,cap=0,500
    for _,root in ipairs(roots) do
        for _,desc in ipairs(root:GetDescendants()) do
            if count>=cap then break end
            if softMatch(desc.Name,filter) or softMatch(desc.ClassName,filter) then addRow(desc); count+=1 end
        end
    end
    list.CanvasSize=UDim2.new(0,0,0, lay.AbsoluteContentSize.Y+12); notify(("Scan done (%d items)."):format(count))
end
btn.MouseButton1Click:Connect(doScan)

--========== SETTINGS ==========
local sBind = newHalfSection(pSettings, "Keybinds / Visibility")
local sMeta = newHalfSection(pSettings, "Meta / Theme Button")

local bindBtn = Controls.Button(sBind, "Crosshair Bind", "Set Key (none)", function()
    if State.BindListening then return end; State.BindListening="CrosshairToggle"; notify("Crosshair için bir tuşa bas.")
end)
Controls.Button(sBind, "Visibility", "Hide/Show Window", function()
    State.Visible = not State.Visible; Window.Visible=State.Visible
    notify(State.Visible and "Menü gösterildi." or "Menü gizlendi.")
end)

local themeOrder={"Dark","Midnight","Neon","Black","Red"}; local themeIdx=1
local function setThemeByName(name) repaintTheme(name); ThemeBtn.Text="Theme: "..name end
ThemeBtn.MouseButton1Click:Connect(function() themeIdx = themeIdx % #themeOrder + 1; setThemeByName(themeOrder[themeIdx]); notify("Tema: "..themeOrder[themeIdx]) end)
setThemeByName("Dark")

-- Key handling
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    -- bind listening
    if State.BindListening and input.KeyCode ~= Enum.KeyCode.Unknown then
        if State.BindListening=="CrosshairToggle" then
            State.Binds["CrosshairToggle"]=input.KeyCode
            bindBtn.Text="Set Key ("..input.KeyCode.Name..")"
            notify("Crosshair bind: "..input.KeyCode.Name)
        end
        State.BindListening=nil
        return
    end

    -- global toggle
    if input.KeyCode == State.GlobalToggleKey then
        State.Visible = not State.Visible; Window.Visible=State.Visible
        notify(State.Visible and "Menü gösterildi." or "Menü gizlendi.")
        return
    end

    -- bound actions
    if State.Binds["CrosshairToggle"] and input.KeyCode==State.Binds["CrosshairToggle"] then
        CrosshairCfg.Enabled = not CrosshairCfg.Enabled
        layoutCrosshair()
        safeCall("ToggleCrosshair", CrosshairCfg.Enabled)
        notify("Crosshair: "..(CrosshairCfg.Enabled and "ON" or "OFF"))
    end
end)

-- Start toast
notify("MYLF Linoria+ yüklendi. LeftShift ile gizle/göster.", 3.0)

-- Respawn safety
LP.CharacterAdded:Connect(function()
    task.delay(1.0, function()
        layoutCrosshair()
        CrownPanel.Visible = true
    end)
end)
