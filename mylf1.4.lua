--[[ 
    ⚡ MYLF Linoria+ Legit UI Framework (Client-Safe) ⚡
    - Tek LocalScript (PlayerGui). Sadece UI/HUD ve güvenli köprü çağrıları.
    - features9.8.lua içindeki fonksiyonlara DOĞRUDAN bağlanır (pcall ile güvenli).
    - Sekmeler: Features, Player(P1/P2), Visuals, HUD, Scanner, Settings
    - Crown FPS Panel (draggable + CPU/GPU + rainbow), Crosshair, TitleBar-only drag.
    - Global Aç/Kapa: LeftShift
]]

--== FEATURES MODULE (DİREKT BAĞLI) ==--
local features = loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features9.8.lua"))()

local function try(fn, ...)
    if type(fn) == "function" then
        local ok, err = pcall(fn, ...)
        if not ok then warn("[features] "..tostring(err)) end
    end
end

--== SERVICES ==--
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local HttpService        = game:GetService("HttpService")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local Stats              = game:GetService("Stats")

local LP        = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")
local Camera    = workspace.CurrentCamera

--== UTILS ==--
local function tween(o, ti, props, es, ed)
    return TweenService:Create(o, TweenInfo.new(ti, es or Enum.EasingStyle.Quad, ed or Enum.EasingDirection.Out), props)
end
local function clamp(n,a,b) if n<a then return a elseif n>b then return b else return n end end
local function round(n,p) p=p or 0 local m=10^p return math.floor(n*m+0.5)/m end
local function makeCorner(o,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=o; return c end
local function makeStroke(o,th,tr) local s=Instance.new("UIStroke"); s.Thickness=th or 1; s.Transparency=tr or 0; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=o; return s end
local function pad(o,px) local p=Instance.new("UIPadding"); p.PaddingTop=UDim.new(0,px); p.PaddingBottom=UDim.new(0,px); p.PaddingLeft=UDim.new(0,px); p.PaddingRight=UDim.new(0,px); p.Parent=o; return p end
local function hsl(h, s, l) local function f(n) local k=(n+h*12)%12 local a=s*math.min(l,1-l) return l - a * math.max(-1, math.min(math.min(k-3,9-k),1)) end return Color3.new(f(0),f(8),f(4)) end

--== THEMES ==--
local Themes = {
    Dark     ={Bg=Color3.fromRGB(20,20,26),   Panel=Color3.fromRGB(28,28,36),   Accent=Color3.fromRGB(120,115,245), AccentSoft=Color3.fromRGB(95,90,210),
               Text=Color3.fromRGB(238,238,245), SubText=Color3.fromRGB(170,170,178), Stroke=Color3.fromRGB(60,60,72), Hover=Color3.fromRGB(40,40,52),
               Green=Color3.fromRGB(110,210,130), Red=Color3.fromRGB(230,90,96), Yellow=Color3.fromRGB(245,209,66)},
    Midnight ={Bg=Color3.fromRGB(12,14,24),   Panel=Color3.fromRGB(18,20,34),   Accent=Color3.fromRGB(80,180,255),  AccentSoft=Color3.fromRGB(60,140,210),
               Text=Color3.fromRGB(228,232,240), SubText=Color3.fromRGB(150,158,172), Stroke=Color3.fromRGB(40,48,66), Hover=Color3.fromRGB(26,30,46),
               Green=Color3.fromRGB(90,205,140),  Red=Color3.fromRGB(230,90,110),  Yellow=Color3.fromRGB(245,209,66)},
    Neon     ={Bg=Color3.fromRGB(18,18,22),   Panel=Color3.fromRGB(22,22,28),   Accent=Color3.fromRGB(255,80,200),  AccentSoft=Color3.fromRGB(210,60,160),
               Text=Color3.fromRGB(245,245,255), SubText=Color3.fromRGB(172,170,190), Stroke=Color3.fromRGB(70,60,90), Hover=Color3.fromRGB(40,34,60),
               Green=Color3.fromRGB(110,240,200), Red=Color3.fromRGB(255,100,140), Yellow=Color3.fromRGB(255,230,120)},
    Black    ={Bg=Color3.fromRGB(6,6,8),      Panel=Color3.fromRGB(14,14,18),   Accent=Color3.fromRGB(220,220,230), AccentSoft=Color3.fromRGB(190,190,210),
               Text=Color3.fromRGB(240,240,245), SubText=Color3.fromRGB(160,162,170), Stroke=Color3.fromRGB(38,38,48),  Hover=Color3.fromRGB(24,24,30),
               Green=Color3.fromRGB(120,220,150), Red=Color3.fromRGB(230,80,100),  Yellow=Color3.fromRGB(235,210,110)},
    Red      ={Bg=Color3.fromRGB(24,8,10),    Panel=Color3.fromRGB(32,10,12),   Accent=Color3.fromRGB(230,66,80),   AccentSoft=Color3.fromRGB(190,46,60),
               Text=Color3.fromRGB(250,240,242), SubText=Color3.fromRGB(200,150,156), Stroke=Color3.fromRGB(70,30,34),  Hover=Color3.fromRGB(46,16,20),
               Green=Color3.fromRGB(120,220,150), Red=Color3.fromRGB(255,90,120),  Yellow=Color3.fromRGB(255,220,120)},
}
local CurrentTheme = Themes.Dark

--== STATE ==--
local State = { Visible=true, Dragging=false, BindListening=nil, Binds={}, GlobalToggleKey=Enum.KeyCode.LeftShift }

--== ROOT GUI ==--
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

--== MAIN WINDOW ==--
local Window = Instance.new("Frame")
Window.Name="Window"; Window.Size=UDim2.new(0, 860, 0, 540); Window.Position=UDim2.new(0.5,-430,0.5,-270); Window.BackgroundColor3=CurrentTheme.Bg; Window.Active=true; Window.Parent=Gui
makeCorner(Window,10); makeStroke(Window,1,.2)

-- TitleBar (drag only here)
local TitleBar = Instance.new("Frame")
TitleBar.Name="TitleBar"; TitleBar.Size=UDim2.new(1,0,0,44); TitleBar.BackgroundColor3=CurrentTheme.Panel; TitleBar.Parent=Window
makeCorner(TitleBar,10); makeStroke(TitleBar,1,.1)

local Title = Instance.new("TextLabel"); Title.BackgroundTransparency=1; Title.Text="⚡ MYLF | Linoria+ (Legit Dev UI)"; Title.Font=Enum.Font.GothamBold; Title.TextSize=16
Title.TextColor3=CurrentTheme.Text; Title.TextXAlignment=Enum.TextXAlignment.Left; Title.Size=UDim2.new(1,-180,1,0); Title.Position=UDim2.new(0,14,0,0); Title.Parent=TitleBar

local ThemeBtn = Instance.new("TextButton")
ThemeBtn.Text="Theme: Dark"; ThemeBtn.AutoButtonColor=false; ThemeBtn.Font=Enum.Font.GothamSemibold; ThemeBtn.TextSize=13; ThemeBtn.TextColor3=CurrentTheme.Text
ThemeBtn.BackgroundColor3=CurrentTheme.Hover; ThemeBtn.AnchorPoint=Vector2.new(1,0.5); ThemeBtn.Position=UDim2.new(1,-10,0.5,0); ThemeBtn.Size=UDim2.new(0,160,0,26); ThemeBtn.Parent=TitleBar
makeCorner(ThemeBtn,6); makeStroke(ThemeBtn,1,.15)

do
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
Sidebar.BackgroundColor3=CurrentTheme.Panel; Sidebar.Position=UDim2.new(0,10,0,58); Sidebar.Size=UDim2.new(0,190,1,-68); Sidebar.Parent=Window
makeCorner(Sidebar,8); makeStroke(Sidebar,1,.08); pad(Sidebar,8)
local SideList = Instance.new("UIListLayout", Sidebar); SideList.Padding=UDim.new(0,8)

local function makeTabButton(text, icon)
    local b=Instance.new("TextButton"); b.AutoButtonColor=false; b.Text=(icon and (icon.."  ") or "")..text; b.Font=Enum.Font.GothamSemibold; b.TextSize=14
    b.TextColor3=CurrentTheme.Text; b.BackgroundColor3=CurrentTheme.Hover; b.Size=UDim2.new(1,-4,0,34); b.Parent=Sidebar; makeCorner(b,6); makeStroke(b,1,.2)
    b.MouseEnter:Connect(function() tween(b,.08,{BackgroundColor3=CurrentTheme.AccentSoft}):Play() end)
    b.MouseLeave:Connect(function() tween(b,.12,{BackgroundColor3=CurrentTheme.Hover}):Play() end)
    return b
end

-- Content container
local Content = Instance.new("Frame")
Content.BackgroundTransparency=1; Content.Position=UDim2.new(0,210,0,58); Content.Size=UDim2.new(1,-220,1,-68); Content.Parent=Window

-- Pages
local Pages={}
local function newPage(name)
    local p=Instance.new("Frame"); p.Visible=false; p.BackgroundColor3=CurrentTheme.Panel; p.Size=UDim2.new(1,0,1,0); p.Parent=Content
    makeCorner(p,8); makeStroke(p,1,.08); pad(p,10)
    Pages[name]=p; return p
end
local function section(parent,title)
    local s=Instance.new("Frame"); s.BackgroundColor3=CurrentTheme.Bg; s.Size=UDim2.new(0.5,-8,1,0); s.Parent=parent
    makeCorner(s,8); makeStroke(s,1,.08); pad(s,10)
    local t=Instance.new("TextLabel"); t.BackgroundTransparency=1; t.Text=title; t.Font=Enum.Font.GothamBold; t.TextSize=14; t.TextColor3=CurrentTheme.Text; t.Size=UDim2.new(1,0,0,18); t.Parent=s
    local l=Instance.new("UIListLayout", s); l.Padding=UDim.new(0,8)
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
function Controls.Color(parent,label,default,callback)
    local row,lab=makeRow(parent,label)
    local box=Instance.new("TextButton"); box.AutoButtonColor=false; box.Text=""; box.Size=UDim2.new(0,36,0,24); box.Position=UDim2.new(1,-46,0.5,-12)
    box.BackgroundColor3=default or CurrentTheme.Accent; box.Parent=row; makeCorner(box,6); makeStroke(box,1,.15)
    local picking=false
    box.MouseButton1Click:Connect(function() picking=not picking; notify(picking and "Renk seç: ekrana tıkla." or "Renk seçimi kapalı.") end)
    UserInputService.InputBegan:Connect(function(input,gp)
        if not gp and picking and input.UserInputType==Enum.UserInputType.MouseButton1 then
            picking=false; local rel=(input.Position.X%512)/512; local c=hsl(rel,.7,.55); box.BackgroundColor3=c; if callback then callback(c) end
        end
    end)
    return {Set=function(c) box.BackgroundColor3=c; if callback then callback(c) end end, Get=function() return box.BackgroundColor3 end}
end
function Controls.Button(parent,label,text,callback)
    local row,lab=makeRow(parent,label)
    local btn=Instance.new("TextButton"); btn.AutoButtonColor=false; btn.Text=text or "Run"; btn.Font=Enum.Font.GothamSemibold; btn.TextSize=12; btn.TextColor3=CurrentTheme.Text
    btn.BackgroundColor3=CurrentTheme.Hover; btn.Size=UDim2.new(0,120,0,24); btn.Position=UDim2.new(1,-130,0.5,-12); btn.Parent=row; makeCorner(btn,6); makeStroke(btn,1,.15)
    btn.MouseEnter:Connect(function() tween(btn,.08,{BackgroundColor3=CurrentTheme.AccentSoft}):Play() end)
    btn.MouseLeave:Connect(function() tween(btn,.12,{BackgroundColor3=CurrentTheme.Hover}):Play() end)
    btn.MouseButton1Click:Connect(function() if callback then callback() end end)
    return btn
end

--== OVERLAY (Crosshair + Crown HUD) ==--
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

-- Crown HUD (movable, slim)
local CrownPanel=Instance.new("Frame"); CrownPanel.AnchorPoint=Vector2.new(.5,0); CrownPanel.Position=UDim2.new(.5,0,0,8); CrownPanel.Size=UDim2.fromOffset(300,26)
CrownPanel.BackgroundColor3=CurrentTheme.Panel; CrownPanel.Parent=Overlay; makeCorner(CrownPanel,8); makeStroke(CrownPanel,1,.15); pad(CrownPanel,4)
local CrownText=Instance.new("TextLabel"); CrownText.BackgroundTransparency=1; CrownText.Font=Enum.Font.GothamSemibold; CrownText.TextSize=12; CrownText.TextColor3=CurrentTheme.Text
CrownText.TextXAlignment=Enum.TextXAlignment.Center; CrownText.Size=UDim2.new(1,-10,1,-8); CrownText.Position=UDim2.fromOffset(5,0); CrownText.Parent=CrownPanel
local RainbowBar=Instance.new("Frame"); RainbowBar.BorderSizePixel=0; RainbowBar.AnchorPoint=Vector2.new(.5,1); RainbowBar.Position=UDim2.new(.5,0,1,0); RainbowBar.Size=UDim2.new(1,-6,0,3); RainbowBar.Parent=CrownPanel; makeCorner(RainbowBar,2)
local grad=Instance.new("UIGradient", RainbowBar)

do -- draggable crown
    local drag=false; local start; local base
    CrownPanel.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true; start=i.Position; base=CrownPanel.Position end end)
    CrownPanel.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
    CrownPanel.InputChanged:Connect(function(i) if drag and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-start; CrownPanel.Position=UDim2.new(base.X.Scale, base.X.Offset+d.X, base.Y.Scale, base.Y.Offset+d.Y) end end)
end

local hbAvg, rsAvg, hbN, rsN, halfA, frameCount = 0,0,0,0,0,0
RunService.Heartbeat:Connect(function(dt) hbN+=1; hbAvg=hbAvg + (dt - hbAvg)/hbN end)
RunService.RenderStepped:Connect(function(dt)
    rsN+=1; rsAvg=rsAvg + (dt - rsAvg)/rsN
    halfA += dt; frameCount += 1
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromHSV((os.clock()*0.7)%1,1,1)),
        ColorSequenceKeypoint.new(0.50, Color3.fromHSV((os.clock()*0.7+0.33)%1,1,1)),
        ColorSequenceKeypoint.new(1.00, Color3.fromHSV((os.clock()*0.7+0.66)%1,1,1)),
    }
    if halfA >= 0.5 then
        local fps=round(frameCount/halfA,0); frameCount=0; halfA=0
        local ping="?"; pcall(function() local it=Stats.Network.ServerStatsItem["Data Ping"]; if it then ping=tostring(it:GetValueString()):gsub(" RTT","") end end)
        CrownText.Text=("FPS: %s | Ping: %s | CPU: %s ms | GPU: %s ms"):format(fps, ping, round(hbAvg*1000,1), round(rsAvg*1000,1))
        local need=CrownText.TextBounds.X + 40; CrownPanel.Size=UDim2.fromOffset(math.clamp(need, 260, 680), 26)
    end
end)

--== PAGES ==--
local pFeatures = newPage("Features")
local pPlayer   = newPage("Player")
local pVisuals  = newPage("Visuals")
local pHUD      = newPage("HUD")
local pScanner  = newPage("Scanner")
local pSettings = newPage("Settings")

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

--== FEATURES (Grid benzeri 3x2) ==--
local grid=Instance.new("UIGridLayout", pFeatures)
grid.CellPadding=UDim2.new(0,10,0,10); grid.FillDirection=Enum.FillDirection.Horizontal; grid.SortOrder=Enum.SortOrder.LayoutOrder
grid.FillDirectionMaxColumns=3; grid.CellSize=UDim2.new(1/3,-10,1/2,-10)

local sFCombat   = section(pFeatures, "Rage / Combat")
local sFVisuals  = section(pFeatures, "Visuals / ESP")
local sFMove     = section(pFeatures, "Movement")
local sFProt     = section(pFeatures, "Protection")
local sFUtil     = section(pFeatures, "Utility / TP")
local sFOffsets  = section(pFeatures, "Teleport Offsets")

-- Combat
Controls.Toggle(sFCombat,"Enable Aimbot",false,function(on) try(features.ToggleAimbot, on) end)
Controls.Toggle(sFCombat,"Force Headshot",false,function(on) try(features.ToggleHeadshotRedirect, on) end)
Controls.Toggle(sFCombat,"Hard Fire Rate",false,function(on) try(features.ToggleFireRate, on) end)
Controls.Toggle(sFCombat,"Silent Aim",false,function(on) try(features.ToggleSilentAim, on) end)
Controls.Toggle(sFCombat,"Magic Bullet (Fallback)",false,function(on) try(features.ToggleMagicBullet, on) end)
Controls.Toggle(sFCombat,"☠️ Kill Aura",false,function(on) try(features.ToggleKillAura, on) end)

-- Visuals
Controls.Toggle(sFVisuals,"Enable ESP",false,function(on) try(features.ToggleESP, on) end)
Controls.Toggle(sFVisuals,"🎯 Enemy Big Hitbox",false,function(on) try(features.ToggleEnemyBigHitbox, on) end)
Controls.Toggle(sFVisuals,"My Hitbox",false,function(on) try(features.Togglemyhitbox, on) end)

-- Movement
Controls.Toggle(sFMove,"Speed Boost",false,function(on) try(features.ToggleSpeed, on) end)
Controls.Toggle(sFMove,"Fly (LCtrl)",false,function(on) try(features.ToggleFly, on) end)
Controls.Toggle(sFMove,"Infinite Jump",false,function(on) try(features.ToggleInfiniteJump, on) end)
Controls.Toggle(sFMove,"NoClip",false,function(on) try(features.ToggleNoclip, on) end)

-- Protection
Controls.Toggle(sFProt,"💀 Godmode",false,function(on) try(features.ToggleGodmode, on) end)
Controls.Toggle(sFProt,"👻 Hard Invisible",false,function(on) try(features.ToggleHardInvisible, on) end)

-- Utility / TP
Controls.Toggle(sFUtil,"Teleport (T Key)",false,function(on) try(features.ToggleTeleport, on) end)
Controls.Toggle(sFUtil,"⚡ Always Behind Enemy",false,function(on) try(features.ToggleAutoBehind, on) end)
Controls.Toggle(sFUtil,"⚡ Auto Farm Enemy",false,function(on) try(features.ToggleAutoTeleportToEnemy, on) end)

-- Offsets
features._tpX = features._tpX or 0; features._tpY = features._tpY or 0; features._tpZ = features._tpZ or 25
Controls.Slider(sFOffsets,"X Offset",-50,50,features._tpX,"%0.0f",function(v) features._tpX=v; try(features.SetTeleportOffset, features._tpX, features._tpY, features._tpZ) end)
Controls.Slider(sFOffsets,"Y Offset",-50,50,features._tpY,"%0.0f",function(v) features._tpY=v; try(features.SetTeleportOffset, features._tpX, features._tpY, features._tpZ) end)
Controls.Slider(sFOffsets,"Z Offset",  1,100,features._tpZ,"%0.0f",function(v) features._tpZ=v; try(features.SetTeleportOffset, features._tpX, features._tpY, features._tpZ) end)

--== PLAYER (İçinde P1/P2 alt sayfası) ==--
local topBar=Instance.new("Frame", pPlayer); topBar.Size=UDim2.new(1,0,0,32); topBar.BackgroundColor3=CurrentTheme.Panel; makeCorner(topBar,8); makeStroke(topBar,1,.08); pad(topBar,4)
local p1Btn=Instance.new("TextButton", topBar); p1Btn.Size=UDim2.new(0,80,1,-8); p1Btn.Position=UDim2.new(0,6,0,4); p1Btn.Text="Page 1"; p1Btn.Font=Enum.Font.GothamSemibold; p1Btn.TextSize=12
p1Btn.AutoButtonColor=false; p1Btn.BackgroundColor3=CurrentTheme.Hover; p1Btn.TextColor3=CurrentTheme.Text; makeCorner(p1Btn,6); makeStroke(p1Btn,1,.12)

local p2Btn=Instance.new("TextButton", topBar); p2Btn.Size=UDim2.new(0,80,1,-8); p2Btn.Position=UDim2.new(0,92,0,4); p2Btn.Text="Page 2"; p2Btn.Font=Enum.Font.GothamSemibold; p2Btn.TextSize=12
p2Btn.AutoButtonColor=false; p2Btn.BackgroundColor3=CurrentTheme.Hover; p2Btn.TextColor3=CurrentTheme.Text; makeCorner(p2Btn,6); makeStroke(p2Btn,1,.12)

local subHolder=Instance.new("Frame", pPlayer)
subHolder.Size=UDim2.new(1,0,1,-42); subHolder.Position=UDim2.new(0,0,0,38)
subHolder.BackgroundTransparency=1

-- her alt sayfanın iskeleti
local function newSubPage(parent)
    local f=Instance.new("Frame", parent)
    f.Size=UDim2.new(1,0,1,0); f.BackgroundTransparency=1
    local lay=Instance.new("UIListLayout", f)
    lay.FillDirection=Enum.FillDirection.Horizontal
    lay.Padding=UDim.new(0,10)
    lay.SortOrder=Enum.SortOrder.LayoutOrder
    return f
end

local p1 = newSubPage(subHolder)
local p2 = newSubPage(subHolder)

-- tema highlight
local function paintTabSel()
    p1Btn.BackgroundColor3 = p1.Visible and CurrentTheme.AccentSoft or CurrentTheme.Hover
    p2Btn.BackgroundColor3 = p2.Visible and CurrentTheme.AccentSoft or CurrentTheme.Hover
end
local function showSub(idx)
    p1.Visible = (idx==1)
    p2.Visible = (idx==2)
    paintTabSel()
end
showSub(1)
p1Btn.MouseButton1Click:Connect(function() showSub(1) end)
p2Btn.MouseButton1Click:Connect(function() showSub(2) end)

-- küçük yardımcılar
local function bindFeatureToggle(parent, label, fn)
    Controls.Toggle(parent, label, false, function(on)
        if type(fn)=="function" then
            local ok,err=pcall(fn,on)
            if not ok then warn("[features] "..label..":", err) end
        end
    end)
end

-- Options benzeri slider API
local Options={}
local function addSlider(parent, key, cfg)
    local fmt = cfg.Rounding and ("%0."..tostring(cfg.Rounding).."f") or "%d"
    local sl = Controls.Slider(parent, cfg.Text or key, cfg.Min or 0, cfg.Max or 100, cfg.Default or 0, fmt, function(v)
        local slot = Options[key]
        if slot and slot._listeners then
            for _,fn in ipairs(slot._listeners) do
                local ok,err=pcall(fn,v); if not ok then warn("OnChanged "..key,err) end
            end
        end
    end)
    Options[key] = {Get=sl.Get, Set=sl.Set, _listeners={}}
    function Options[key]:OnChanged(fn) table.insert(self._listeners, fn) end
    return Options[key]
end

----------------------------------------------------------------
-- PAGE 1: Combat + Visuals  (1.3’teki combat/visuals toggle’ları)
----------------------------------------------------------------
local sP1L = newSection(p1, "Combat")
local sP1R = newSection(p1, "Visuals")

-- Combat
bindFeatureToggle(sP1L, "Enable Aimbot",                features and features.ToggleAimbot)
bindFeatureToggle(sP1L, "Force Headshot",               features and features.ToggleHeadshotRedirect)
bindFeatureToggle(sP1L, "Hard Fire Rate",               features and features.ToggleFireRate)
bindFeatureToggle(sP1L, "Silent Aim",                   features and features.ToggleSilentAim)
bindFeatureToggle(sP1L, "Magic Bullet (Fallback)",      features and features.ToggleMagicBullet)
bindFeatureToggle(sP1L, "☠️ Kill Aura",                 features and features.ToggleKillAura)

-- Visuals
bindFeatureToggle(sP1R, "Enable ESP",                   features and features.ToggleESP)
bindFeatureToggle(sP1R, "🎯 Enemy Big Hitbox",          features and features.ToggleEnemyBigHitbox)

----------------------------------------------------------------
-- PAGE 2: Utility / TP  (teleport toggle’ları + offset slider’ları)
----------------------------------------------------------------
local sP2L = newSection(p2, "Utility / Teleport")
local sP2R = newSection(p2, "Teleport Offsets")

bindFeatureToggle(sP2L, "Teleport (T Key)",             features and features.ToggleTeleport)
bindFeatureToggle(sP2L, "⚡ Always Behind Enemy",       features and features.ToggleAutoBehind)
bindFeatureToggle(sP2L, "⚡ Auto Farm Enemy",           features and features.ToggleAutoTeleportToEnemy)

-- Slider’lar (tpX/Y/Z) + features.SetTeleportOffset bağları
features._tpX = tonumber(features._tpX) or 0
features._tpY = tonumber(features._tpY) or 0
features._tpZ = tonumber(features._tpZ) or 25

addSlider(sP2R, "tpX", {Text="X Offset", Min=-50, Max=50,  Default=features._tpX, Rounding=1})
addSlider(sP2R, "tpY", {Text="Y Offset", Min=-50, Max=50,  Default=features._tpY, Rounding=1})
addSlider(sP2R, "tpZ", {Text="Z Offset", Min=1,   Max=100, Default=features._tpZ, Rounding=1})

if Options.tpX then
    Options.tpX:OnChanged(function(val)
        features._tpX = val
        if type(features.SetTeleportOffset)=="function" then
            pcall(features.SetTeleportOffset, features._tpX, features._tpY, features._tpZ)
        end
    end)
end
if Options.tpY then
    Options.tpY:OnChanged(function(val)
        features._tpY = val
        if type(features.SetTeleportOffset)=="function" then
            pcall(features.SetTeleportOffset, features._tpX, features._tpY, features._tpZ)
        end
    end)
end
if Options.tpZ then
    Options.tpZ:OnChanged(function(val)
        features._tpZ = val
        if type(features.SetTeleportOffset)=="function" then
            pcall(features.SetTeleportOffset, features._tpX, features._tpY, features._tpZ)
        end
    end)
end

-- alt sayfa buton hover renkleri
local function wireHover(btn)
    btn.MouseEnter:Connect(function() tween(btn,.08,{BackgroundColor3=CurrentTheme.AccentSoft}):Play() end)
    btn.MouseLeave:Connect(function() paintTabSel() end)
end
wireHover(p1Btn); wireHover(p2Btn)
paintTabSel()
