--[[ 
    ⚡ MYLF | Linoria+ (Legit Dev UI) — mylf.txt
    - Menü yapısı: Features, Player, Visuals, HUD, Scanner, Settings  (mylf1.txt tab isimleri baz alındı)
    - Crown FPS Panel: FPS | Ping | CPU | GPU  + alt tarafta rainbow çizgi, tema Accent rengine bağlı stroke
    - Scanner: Solda kategori, ortada listbox, sağda detay paneli. Refresh + Search var. (client-safe)
    - Global Aç/Kapa: LeftShift

    Not: Bu dosya client-safe kozmetik/HUD ve inceleme amaçlıdır. Herhangi bir exploit/hook/remote patch içermez.
]]

--// Services
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

--// Utils
local function tween(o, ti, props, es, ed)
    return TweenService:Create(o, TweenInfo.new(ti, es or Enum.EasingStyle.Quad, ed or Enum.EasingDirection.Out), props)
end
local function clamp(n,a,b) if n<a then return a elseif n>b then return b else return n end end
local function round(n,p) p=p or 0 local m=10^p return math.floor(n*m+0.5)/m end
local function makeCorner(o,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=o; return c end
local function makeStroke(o,th,tr) local s=Instance.new("UIStroke"); s.Thickness=th or 1; s.Transparency=tr or 0; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=o; return s end
local function pad(o,px) local p=Instance.new("UIPadding"); p.PaddingTop=UDim.new(0,px); p.PaddingBottom=UDim.new(0,px); p.PaddingLeft=UDim.new(0,px); p.PaddingRight=UDim.new(0,px); p.Parent=o; return p end
local function hsl(h, s, l) local function f(n) local k=(n+h*12)%12 local a=s*math.min(l,1-l) return l - a * math.max(-1, math.min(math.min(k-3,9-k),1)) end return Color3.new(f(0),f(8),f(4)) end
local function getFullPath(i) local ok,res=pcall(function() return i:GetFullName() end); return ok and res or "[path?]" end

--// Theme Engine
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

-- Theme registry: tema değişince yeniden boyanacak öğeler burada tutulur
local ThemeRegistry = {}
local function registerThemeUpdater(key, fn) ThemeRegistry[key] = fn end
local function applyTheme(name)
    if name then CurrentTheme = Themes[name] or CurrentTheme end
    for k,fn in pairs(ThemeRegistry) do
        pcall(fn, CurrentTheme)
    end
end

--// State
local State = { Visible=true, Dragging=false, GlobalToggleKey=Enum.KeyCode.LeftShift }

--// ROOT GUI
local Gui = Instance.new("ScreenGui")
Gui.Name="MYLF_LinoriaPlus"
Gui.IgnoreGuiInset=true
Gui.ResetOnSpawn=false
Gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
Gui.Parent=PlayerGui

-- Notifications
local NotifLayer = Instance.new("Frame")
NotifLayer.Size=UDim2.new(1,0,1,0)
NotifLayer.BackgroundTransparency=1
NotifLayer.Parent=Gui
local function notify(text, dur)
    dur = dur or 2.2
    local t=Instance.new("TextLabel")
    t.BackgroundColor3=CurrentTheme.Panel; t.TextColor3=CurrentTheme.Text
    t.Font=Enum.Font.GothamSemibold; t.TextSize=14; t.Text="  "..text
    t.AnchorPoint=Vector2.new(1,0); t.Position=UDim2.new(1,-10,0,10)
    t.Size=UDim2.new(0,0,0,28); t.TextXAlignment=Enum.TextXAlignment.Left
    t.Parent=NotifLayer; makeCorner(t,6); makeStroke(t,1,.1)
    local size=tween(t,.16,{Size=UDim2.new(0, math.clamp(t.TextBounds.X+22,160,520),0,28)}); size:Play()
    task.delay(dur,function() local tw=tween(t,.16,{Position=UDim2.new(1,-10,0,-34), BackgroundTransparency=1}); tw.Completed:Connect(function() t:Destroy() end); tw:Play() end)
end

--== WINDOW ==--
local Window = Instance.new("Frame")
Window.Name="Window"; Window.Size=UDim2.new(0, 860, 0, 540); Window.Position=UDim2.new(0.5,-430,0.5,-270)
Window.BackgroundColor3=CurrentTheme.Bg; Window.Active=true; Window.Parent=Gui
local winStroke = makeStroke(Window,1,.2); makeCorner(Window,10)

registerThemeUpdater("Window", function(th)
    Window.BackgroundColor3 = th.Bg
    winStroke.Color = th.Stroke
end)

-- TitleBar
local TitleBar = Instance.new("Frame")
TitleBar.Name="TitleBar"; TitleBar.Size=UDim2.new(1,0,0,44); TitleBar.Parent=Window
local tbStroke = makeStroke(TitleBar,1,.1); makeCorner(TitleBar,10)
local Title = Instance.new("TextLabel"); Title.BackgroundTransparency=1; Title.Text="⚡ MYLF | Linoria+"
Title.Font=Enum.Font.GothamBold; Title.TextSize=16; Title.TextXAlignment=Enum.TextXAlignment.Left
Title.Size=UDim2.new(1,-180,1,0); Title.Position=UDim2.new(0,14,0,0); Title.Parent=TitleBar
local ThemeBtn = Instance.new("TextButton"); ThemeBtn.Text="Theme: Dark"; ThemeBtn.AutoButtonColor=false
ThemeBtn.Font=Enum.Font.GothamSemibold; ThemeBtn.TextSize=13; ThemeBtn.AnchorPoint=Vector2.new(1,0.5)
ThemeBtn.Position=UDim2.new(1,-10,0.5,0); ThemeBtn.Size=UDim2.new(0,160,0,26); ThemeBtn.Parent=TitleBar
local tbtnStroke = makeStroke(ThemeBtn,1,.15); makeCorner(ThemeBtn,6)
registerThemeUpdater("TitleBar", function(th)
    TitleBar.BackgroundColor3 = th.Panel
    tbStroke.Color = th.Stroke
    Title.TextColor3 = th.Text
    ThemeBtn.TextColor3 = th.Text
    ThemeBtn.BackgroundColor3 = th.Hover
    tbtnStroke.Color = th.Stroke
end)

-- Drag only TitleBar
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
Sidebar.Position=UDim2.new(0,10,0,58); Sidebar.Size=UDim2.new(0,190,1,-68); Sidebar.Parent=Window
local sbStroke = makeStroke(Sidebar,1,.08); makeCorner(Sidebar,8); pad(Sidebar,8)
local SideList = Instance.new("UIListLayout", Sidebar); SideList.Padding=UDim.new(0,8)
registerThemeUpdater("Sidebar", function(th)
    Sidebar.BackgroundColor3 = th.Panel
    sbStroke.Color = th.Stroke
end)

local function makeTabButton(text, icon)
    local b=Instance.new("TextButton"); b.AutoButtonColor=false; b.Text=(icon and (icon.."  ") or "")..text
    b.Font=Enum.Font.GothamSemibold; b.TextSize=14; b.Size=UDim2.new(1,-4,0,34); b.Parent=Sidebar
    local st = makeStroke(b,1,.2); makeCorner(b,6)
    b.MouseEnter:Connect(function() tween(b,.08,{BackgroundColor3=CurrentTheme.AccentSoft}):Play() end)
    b.MouseLeave:Connect(function() tween(b,.12,{BackgroundColor3=CurrentTheme.Hover}):Play() end)
    registerThemeUpdater("btn_"..text, function(th)
        b.TextColor3 = th.Text; b.BackgroundColor3 = th.Hover; st.Color = th.Stroke
    end)
    return b
end

-- Content
local Content = Instance.new("Frame")
Content.BackgroundTransparency=1; Content.Position=UDim2.new(0,210,0,58); Content.Size=UDim2.new(1,-220,1,-68); Content.Parent=Window

-- Pages
local Pages={}
local function newPage(name)
    local p=Instance.new("Frame"); p.Visible=false; p.Size=UDim2.new(1,0,1,0); p.Parent=Content
    local pst = makeStroke(p,1,.08); makeCorner(p,8); pad(p,10)
    local list = Instance.new("UIListLayout", p); list.Padding=UDim.new(0,10); list.FillDirection=Enum.FillDirection.Horizontal
    registerThemeUpdater("page_"..name, function(th) p.BackgroundColor3 = th.Panel; pst.Color = th.Stroke end)
    Pages[name]=p; return p
end

local function newSection(parent, title)
    local s=Instance.new("Frame"); s.Size=UDim2.new(0.5,-8,1,0); s.Parent=parent
    local sst = makeStroke(s,1,.08); makeCorner(s,8); pad(s,10)
    local t=Instance.new("TextLabel"); t.BackgroundTransparency=1; t.Text=title; t.Font=Enum.Font.GothamBold; t.TextSize=14; t.Size=UDim2.new(1,0,0,18); t.Parent=s
    registerThemeUpdater("section_"..title, function(th) s.BackgroundColor3 = th.Bg; sst.Color = th.Stroke; t.TextColor3 = th.Text end)
    local l=Instance.new("UIListLayout", s); l.Padding=UDim.new(0,8)
    return s
end

-- Controls
local Controls={}
local function makeRow(parent,label)
    local f=Instance.new("Frame"); f.BackgroundTransparency=1; f.Size=UDim2.new(1,0,0,28); f.Parent=parent
    local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Text=label; l.Font=Enum.Font.Gotham; l.TextSize=13; l.TextXAlignment=Enum.TextXAlignment.Left
    l.Size=UDim2.new(0.55,0,1,0); l.Parent=f
    registerThemeUpdater("row_"..label, function(th) l.TextColor3=th.SubText end)
    return f,l
end
function Controls.Toggle(parent,label,default,callback)
    local row,lab=makeRow(parent,label)
    local btn=Instance.new("TextButton"); btn.AutoButtonColor=false; btn.Text=default and "ON" or "OFF"; btn.Font=Enum.Font.GothamBold; btn.TextSize=12
    btn.Size=UDim2.new(0,78,0,24); btn.Position=UDim2.new(1,-88,0.5,-12); btn.Parent=row
    local bst = makeStroke(btn,1,.2); makeCorner(btn,6)
    registerThemeUpdater("toggle_"..label, function(th)
        btn.TextColor3 = default and th.Green or th.Red
        btn.BackgroundColor3 = th.Hover; bst.Color = th.Stroke
    end)
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
    local frame=Instance.new("Frame"); frame.Size=UDim2.new(0.4,0,0,24); frame.Position=UDim2.new(0.58,0,0.5,-12); frame.Parent=row
    local fst = makeStroke(frame,1,.15); makeCorner(frame,6)
    local fill=Instance.new("Frame"); fill.Size=UDim2.new((default-min)/(max-min),0,1,0); fill.Parent=frame; makeCorner(fill,6)
    local valText=Instance.new("TextLabel"); valText.BackgroundTransparency=1; valText.Font=Enum.Font.GothamSemibold; valText.TextSize=12
    valText.Size=UDim2.new(0,60,1,0); valText.AnchorPoint=Vector2.new(1,0); valText.Position=UDim2.new(1,-6,0,0); valText.Parent=frame; valText.Text=(fmt or "%d"):format(default)
    registerThemeUpdater("slider_"..label, function(th)
        frame.BackgroundColor3=th.Hover; fst.Color=th.Stroke; fill.BackgroundColor3=th.Accent; valText.TextColor3=th.Text
    end)
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
    local btn=Instance.new("TextButton"); btn.AutoButtonColor=false; btn.Font=Enum.Font.GothamSemibold; btn.TextSize=12
    btn.Size=UDim2.new(0,160,0,24); btn.Position=UDim2.new(1,-170,0.5,-12); btn.Parent=row
    local bst = makeStroke(btn,1,.15); makeCorner(btn,6)
    local idx=defaultIdx or 1; btn.Text=items[idx] or "-"
    local listFrame=Instance.new("Frame"); listFrame.Visible=false; listFrame.Size=UDim2.new(0,160,0, math.min(6,#items)*24+10)
    listFrame.AnchorPoint=Vector2.new(0,0); listFrame.Position=UDim2.new(1,-170,0.5,14); listFrame.Parent=row; local lst = makeStroke(listFrame,1,.15); makeCorner(listFrame,6); pad(listFrame,6)
    registerThemeUpdater("dropdown_"..label, function(th)
        btn.TextColor3=th.Text; btn.BackgroundColor3=th.Hover; bst.Color=th.Stroke
        listFrame.BackgroundColor3=th.Panel; lst.Color=th.Stroke
    end)
    local ul=Instance.new("UIListLayout", listFrame); ul.Padding=UDim.new(0,6)
    for i,v in ipairs(items) do
        local it=Instance.new("TextButton"); it.AutoButtonColor=false; it.Font=Enum.Font.Gotham; it.TextSize=12; it.Text=v
        it.Size=UDim2.new(1,0,0,24); it.Parent=listFrame; local ist = makeStroke(it,1,.0); makeCorner(it,6)
        registerThemeUpdater("dropdown_item_"..label.."_"..tostring(i), function(th)
            it.TextColor3=th.Text; it.BackgroundColor3=th.Hover; ist.Color=th.Stroke
        end)
        it.MouseEnter:Connect(function() tween(it,.08,{BackgroundColor3=CurrentTheme.AccentSoft}):Play() end)
        it.MouseLeave:Connect(function() tween(it,.12,{BackgroundColor3=CurrentTheme.Hover}):Play() end)
        it.MouseButton1Click:Connect(function() idx=i; btn.Text=v; listFrame.Visible=false; if callback then callback(v,i) end end)
    end
    btn.MouseButton1Click:Connect(function() listFrame.Visible=not listFrame.Visible end)
    return {SetIndex=function(i) if items[i] then idx=i; btn.Text=items[i]; if callback then callback(items[i],i) end end end, GetIndex=function() return idx end, GetValue=function() return items[idx] end}
end

--== OVERLAY (Crosshair + Crown HUD) ==--
local Overlay=Instance.new("ScreenGui"); Overlay.Name="MYLF_HUD"; Overlay.IgnoreGuiInset=true; Overlay.ResetOnSpawn=false; Overlay.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; Overlay.Parent=PlayerGui

-- CROSSHAIR
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

-- CROWN HUD (tema accent'e bağlı stroke + rainbow alt çizgi) — screenshot benzeri
local CrownPanel=Instance.new("Frame"); CrownPanel.AnchorPoint=Vector2.new(.5,0); CrownPanel.Position=UDim2.new(.5,0,0,8); CrownPanel.Size=UDim2.fromOffset(300,26)
CrownPanel.Parent=Overlay; pad(CrownPanel,4); local cps = makeStroke(CrownPanel,1,.15); makeCorner(CrownPanel,8)
local CrownText=Instance.new("TextLabel"); CrownText.BackgroundTransparency=1; CrownText.Font=Enum.Font.GothamSemibold; CrownText.TextSize=12; CrownText.TextXAlignment=Enum.TextXAlignment.Center
CrownText.Size=UDim2.new(1,-10,1,-8); CrownText.Position=UDim2.fromOffset(5,0); CrownText.Parent=CrownPanel
local RainbowBar=Instance.new("Frame"); RainbowBar.BorderSizePixel=0; RainbowBar.AnchorPoint=Vector2.new(.5,1); RainbowBar.Position=UDim2.new(.5,0,1,0); RainbowBar.Size=UDim2.new(1,-6,0,3); RainbowBar.Parent=CrownPanel; makeCorner(RainbowBar,2)
local grad=Instance.new("UIGradient", RainbowBar)

registerThemeUpdater("Crown", function(th)
    CrownPanel.BackgroundColor3 = th.Panel
    cps.Color = th.Accent
    CrownText.TextColor3 = th.Text
end)

-- Crown metrikleri
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

--== FEATURES (kozm.) ==--
do
    local left  = newSection(pFeatures, "HUD / Overlay")
    local right = newSection(pFeatures, "Quick Actions")

    Controls.Toggle(left, "Crown FPS Panel", true, function(on) CrownPanel.Visible = on end)
    Controls.Toggle(left, "Crosshair", true, function(on) Crosshair.Visible = on end)

    Controls.Button(right, "Crown", "Snap Now", function()
        notify(("FPS %s | FOV %d"):format(tostring(Camera:GetRenderCFrame() and "OK" and round( (function() return 0 end)(),0) or "?"), round(Camera.FieldOfView,0)))
    end)
end

--== PLAYER ==--
do
    local left  = newSection(pPlayer, "Movement / Camera")
    local right = newSection(pPlayer, "Waypoints")

    -- Camera Mode
    Controls.Dropdown(left, "Camera Mode", {"ThirdPerson","FirstPerson","Orbital"}, 1, function(v)
        if v=="ThirdPerson" then
            LP.CameraMode = Enum.CameraMode.Classic
            Camera.CameraType = Enum.CameraType.Custom
        elseif v=="FirstPerson" then
            LP.CameraMode = Enum.CameraMode.LockFirstPerson
            Camera.CameraType = Enum.CameraType.Custom
        elseif v=="Orbital" then
            LP.CameraMode = Enum.CameraMode.Classic
            Camera.CameraType = Enum.CameraType.Orbital
        end
        notify("Kamera: "..v)
    end)

    -- FOV
    Controls.Slider(left, "Field of View", 60, 100, Camera.FieldOfView, "%d", function(v)
        Camera.FieldOfView = v
    end)

    -- Waypoints (client-only Billboard)
    local WayFolder = Instance.new("Folder"); WayFolder.Name = "MYLF_Waypoints_Local"; WayFolder.Parent = workspace
    local function createWaypoint(name, pos)
        local part = Instance.new("Part"); part.Anchored = true; part.CanCollide=false; part.Transparency = 1; part.Size = Vector3.new(1,1,1); part.CFrame = CFrame.new(pos); part.Parent = WayFolder
        local att = Instance.new("Attachment", part)
        local bb = Instance.new("BillboardGui"); bb.Adornee = att; bb.Size = UDim2.fromOffset(160, 40); bb.AlwaysOnTop = true; bb.Parent = part
        local label = Instance.new("TextLabel"); label.Size = UDim2.new(1,0,1,0); label.BackgroundTransparency=0.2; label.Text = "📍 "..name
        local lst = makeStroke(label,1,.15); makeCorner(label,6); label.Parent = bb
        registerThemeUpdater("wp_"..name, function(th) label.BackgroundColor3 = th.Panel; lst.Color = th.Stroke; label.TextColor3 = th.Text end)
        return part
    end
    local function clearWaypoints() for _,v in ipairs(WayFolder:GetChildren()) do v:Destroy() end end

    Controls.Button(right, "Waypoint", "Add Current", function()
        local char = LP.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then local nm = "WP-"..string.sub(HttpService:GenerateGUID(false),1,4); createWaypoint(nm, hrp.Position + Vector3.new(0,3,0)); notify("Waypoint eklendi: "..nm) else notify("Karakter bulunamadı.", 2.0) end
    end)
    Controls.Button(right, "Waypoint", "Clear All", function() clearWaypoints(); notify("Tüm waypoint'ler silindi.") end)
end

--== VISUALS ==--
do
    local left  = newSection(pVisuals, "Crosshair")
    local right = newSection(pVisuals, "Theme / Accent")

    Controls.Toggle(left, "Enable Crosshair", true, function(on) CrosshairCfg.Enabled = on; layoutCrosshair() end)
    Controls.Slider(left, "Gap", 0, 30, CrosshairCfg.Gap, "%d", function(v) CrosshairCfg.Gap=v; layoutCrosshair() end)
    Controls.Slider(left, "Length", 2, 40, CrosshairCfg.Length, "%d", function(v) CrosshairCfg.Length=v; layoutCrosshair() end)
    Controls.Slider(left, "Thickness", 1, 8, CrosshairCfg.Thickness, "%d", function(v) CrosshairCfg.Thickness=v; layoutCrosshair() end)
    Controls.Slider(left, "Opacity", 0, 1, CrosshairCfg.Opacity, "%.2f", function(v) CrosshairCfg.Opacity=v; layoutCrosshair() end)

    Controls.Dropdown(right, "Theme", {"Dark","Midnight","Neon","Black","Red"}, 1, function(v)
        ThemeBtn.Text = "Theme: "..v
        applyTheme(v)
    end)
end

--== HUD ==--
do
    local left  = newSection(pHUD, "Performance")
    local right = newSection(pHUD, "Toggles")

    local fpsToggle = Controls.Toggle(right, "Show FPS/Ping/CPU/GPU", true, function(on) CrownPanel.Visible = on end)
    CrownPanel.Visible = true

    Controls.Button(left, "Snapshot", "Notify Now", function()
        local okPing="?" pcall(function() local it=Stats.Network.ServerStatsItem["Data Ping"]; if it then okPing=tostring(it:GetValueString()):gsub(" RTT","") end end)
        notify(("FPS %s | Ping %s | FOV %d"):format("?", okPing, round(Camera.FieldOfView,0)), 2.2)
    end)
end

--== SCANNER ==--
do
    local left   = newSection(pScanner, "Categories")
    local middle = newSection(pScanner, "Results")
    local right  = newSection(pScanner, "Details")

    -- Search box + refresh
    local searchRow = Instance.new("Frame"); searchRow.BackgroundTransparency=1; searchRow.Size=UDim2.new(1,0,0,28); searchRow.Parent=left
    local searchBox = Instance.new("TextBox"); searchBox.PlaceholderText="Search..."; searchBox.Font=Enum.Font.Gotham; searchBox.TextSize=12; searchBox.ClearTextOnFocus=false
    searchBox.Size=UDim2.new(1,-90,1,0); searchBox.Parent=searchRow
    local sst = makeStroke(searchBox,1,.15); makeCorner(searchBox,6)
    registerThemeUpdater("scanner_search", function(th) searchBox.TextColor3=th.Text; searchBox.PlaceholderColor3=th.SubText; searchBox.BackgroundColor3=th.Hover; sst.Color=th.Stroke end)
    local refreshBtn = Instance.new("TextButton"); refreshBtn.AutoButtonColor=false; refreshBtn.Text="Refresh"; refreshBtn.Font=Enum.Font.GothamSemibold; refreshBtn.TextSize=12
    refreshBtn.Size=UDim2.new(0,80,1,0); refreshBtn.Position=UDim2.new(1,-80,0,0); refreshBtn.Parent=searchRow
    local rbst=makeStroke(refreshBtn,1,.15); makeCorner(refreshBtn,6)
    registerThemeUpdater("scanner_refresh", function(th) refreshBtn.BackgroundColor3=th.Hover; refreshBtn.TextColor3=th.Text; rbst.Color=th.Stroke end)

    -- Category buttons
    local catList = {"Players","Workspace","ReplicatedStorage","Lighting","StarterGui"}
    local catFrame = Instance.new("Frame"); catFrame.BackgroundTransparency=1; catFrame.Size=UDim2.new(1,0,1,-34); catFrame.Position=UDim2.new(0,0,0,34); catFrame.Parent=left
    local catLayout = Instance.new("UIListLayout", catFrame); catLayout.Padding=UDim.new(0,6)
    local currentCat = "Players"

    local function makeCat(text)
        local b=Instance.new("TextButton"); b.AutoButtonColor=false; b.Text=text; b.Font=Enum.Font.GothamSemibold; b.TextSize=12; b.Size=UDim2.new(1,0,0,24); b.Parent=catFrame
        local bst=makeStroke(b,1,.15); makeCorner(b,6)
        registerThemeUpdater("scanner_cat_"..text, function(th) b.TextColor3=th.Text; b.BackgroundColor3 = (currentCat==text) and th.AccentSoft or th.Hover; bst.Color=th.Stroke end)
        b.MouseButton1Click:Connect(function() currentCat=text; applyTheme() end)
    end
    for _,c in ipairs(catList) do makeCat(c) end

    -- Results listbox
    local results = Instance.new("ScrollingFrame"); results.CanvasSize=UDim2.new(0,0,0,0); results.ScrollBarThickness=6
    results.Size=UDim2.new(1,0,1,-0); results.Parent=middle; results.AutomaticCanvasSize=Enum.AutomaticSize.Y
    local rlst = Instance.new("UIListLayout", results); rlst.Padding=UDim.new(0,4)
    local rst = makeStroke(results,1,.08); makeCorner(results,6); pad(results,6)
    registerThemeUpdater("scanner_results", function(th) results.BackgroundColor3=th.Hover; results.ScrollBarImageColor3=th.Accent; rst.Color=th.Stroke end)

    local function addResultLine(text, ref)
        local row=Instance.new("TextButton"); row.AutoButtonColor=false; row.TextXAlignment=Enum.TextXAlignment.Left
        row.Font=Enum.Font.Gotham; row.TextSize=12; row.Size=UDim2.new(1,0,0,24); row.Text="  "..text; row.Parent=results
        local rst=makeStroke(row,1,.0); makeCorner(row,6)
        registerThemeUpdater("scanner_row_"..text, function(th) row.TextColor3=th.Text; row.BackgroundColor3=th.Panel; rst.Color=th.Stroke end)
        row.MouseButton1Click:Connect(function()
            -- write details
            for _,v in ipairs(right:GetChildren()) do if v:IsA("Frame") or v:IsA("TextLabel") or v:IsA("ScrollingFrame") then v:Destroy() end end
            local head = Instance.new("TextLabel"); head.BackgroundTransparency=1; head.Font=Enum.Font.GothamBold; head.TextSize=14; head.Text="Details"; head.Size=UDim2.new(1,0,0,20); head.Parent=right
            registerThemeUpdater("scanner_details_head", function(th) head.TextColor3=th.Text end)
            local box = Instance.new("TextLabel"); box.TextWrapped=true; box.TextXAlignment=Enum.TextXAlignment.Left; box.TextYAlignment=Enum.TextYAlignment.Top
            box.Size=UDim2.new(1,-0,1,-24); box.Position=UDim2.new(0,0,0,24); box.Parent=right
            registerThemeUpdater("scanner_details_box", function(th) box.BackgroundTransparency=1; box.TextColor3=th.SubText end)
            local info = {}
            table.insert(info, "Name: "..tostring(ref.Name))
            table.insert(info, "Class: "..tostring(ref.ClassName))
            table.insert(info, "Path: "..getFullPath(ref))
            local ch = 0; pcall(function() ch = #ref:GetChildren() end)
            table.insert(info, "Children: "..tostring(ch))
            box.Text = table.concat(info, "\n")
        end)
    end

    local function iterateCategory(cat, query)
        for _,v in ipairs(results:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        local function push(obj, tag)
            if query and query~="" then
                if not string.find(string.lower(obj.Name), string.lower(query), 1, true) then return end
            end
            addResultLine((tag and (tag.." | ") or "")..obj.Name, obj)
        end
        if cat=="Players" then
            for _,plr in ipairs(Players:GetPlayers()) do push(plr, "Player") end
        elseif cat=="Workspace" then
            for _,child in ipairs(workspace:GetChildren()) do push(child, "WS") end
        elseif cat=="ReplicatedStorage" then
            local rs = ReplicatedStorage
            for _,child in ipairs(rs:GetChildren()) do
                if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                    push(child, "Remote")
                else
                    push(child, "RS")
                end
            end
        else
            local svc = game:GetService(cat) or nil
            if svc then
                for _,child in ipairs(svc:GetChildren()) do push(child, cat) end
            end
        end
    end

    local function refresh()
        iterateCategory(currentCat, searchBox.Text)
    end

    refreshBtn.MouseButton1Click:Connect(refresh)
    searchBox:GetPropertyChangedSignal("Text"):Connect(function() refresh() end)
    refresh()
end

--== SETTINGS ==--
do
    local left  = newSection(pSettings, "Menu / Keys")
    local right = newSection(pSettings, "About")

    -- Global Toggle (dinleyici)
    Controls.Toggle(left, "Change Menu Key (press after ON)", false, function(on)
        if on then
            local waiting=true
            notify("Yeni tuşu bas…")
            local conn; conn = UserInputService.InputBegan:Connect(function(input, gp)
                if gp then return end
                if input.KeyCode ~= Enum.KeyCode.Unknown then
                    State.GlobalToggleKey = input.KeyCode
                    notify("Menu key: "..tostring(State.GlobalToggleKey))
                    waiting=false
                    if conn then conn:Disconnect() end
                end
            end)
            task.delay(5, function() if waiting and conn then conn:Disconnect(); notify("Key atama iptal.") end end)
        end
    end)

    local about = Instance.new("TextLabel"); about.BackgroundTransparency=1; about.TextWrapped=true
    about.Font=Enum.Font.Gotham; about.TextSize=12; about.TextXAlignment=Enum.TextXAlignment.Left; about.TextYAlignment=Enum.TextYAlignment.Top
    about.Size=UDim2.new(1,0,1,-0); about.Parent=right
    registerThemeUpdater("about", function(th) about.TextColor3=th.SubText end)
    about.Text = "MYLF Linoria+ — client-safe UI/HUD/Scanner paketi.\nTema Accent rengine bağlı crown stroke + rainbow underline.\nBuild: mylf.txt"
end

-- Global menu toggle
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode == State.GlobalToggleKey then
        Window.Visible = not Window.Visible
    end
end)

-- Theme cycler (TitleBar)
local themeList = {"Dark","Midnight","Neon","Black","Red"}
local themeIdx=1
ThemeBtn.MouseButton1Click:Connect(function()
    themeIdx = themeIdx % #themeList + 1
    ThemeBtn.Text = "Theme: "..themeList[themeIdx]
    applyTheme(themeList[themeIdx])
end)

-- İlk boyama
applyTheme("Dark")
