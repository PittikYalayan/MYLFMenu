--[[ 
    ⚡ MYLF Linoria+ Legit UI Framework (Client-Safe) + Ultra Scanner ⚡
    - Tek LocalScript (PlayerGui).
    - Hile/exploit/metamethod hook/remote patch/network bypass YOK.
    - Tamamen kozmetik/HUD ve client tarafı tarama/GUI ayarları.

    Aç/Kapa: LeftShift
]]

--// Services
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local HttpService        = game:GetService("HttpService")
local StarterGui         = game:GetService("StarterGui")
local Stats              = game:GetService("Stats")
local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

--// (İsteğin doğrultusunda) features bağlama
local features = setmetatable({}, { __index = function() return function() end end })
pcall(function()
    features = loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features9.8.lua"))()
end)

--// Utils
local function tween(o, ti, props, es, ed)
    return TweenService:Create(o, TweenInfo.new(ti, es or Enum.EasingStyle.Quad, ed or Enum.EasingDirection.Out), props)
end
local function clamp(n, a, b) if n < a then return a elseif n > b then return b else return n end end
local function round(n, p) p = p or 0 local m = 10^p return math.floor(n*m+0.5)/m end
local function makeCorner(o, r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=o; return c end
local function makeStroke(o, th, tr) local s=Instance.new("UIStroke"); s.Thickness=th or 1; s.Transparency=tr or 0; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=o; return s end
local function pad(o, px) local p=Instance.new("UIPadding"); p.PaddingTop=UDim.new(0,px); p.PaddingBottom=UDim.new(0,px); p.PaddingLeft=UDim.new(0,px); p.PaddingRight=UDim.new(0,px); p.Parent=o; return p end
local function hsl(h,s,l) local function f(n) local k=(n+h*12)%12 local a=s*math.min(l,1-l) return l-a*math.max(-1,math.min(math.min(k-3,9-k),1)) end return Color3.new(f(0),f(8),f(4)) end

-- path yazıcı
local function instancePath(obj)
    if not obj or not obj.Parent then return obj and obj.Name or "nil" end
    local names={}
    local cur=obj
    while cur and cur.Parent do
        table.insert(names,1,cur.Name)
        cur=cur.Parent
    end
    return table.concat(names,"/")
end

-- güvenli PrimaryPart/BasePart bulucu
local function findAttachablePart(inst)
    if not inst then return nil end
    if inst:IsA("BasePart") then return inst end
    if inst:IsA("Model") then
        if inst.PrimaryPart then return inst.PrimaryPart end
        for _,d in ipairs(inst:GetDescendants()) do
            if d:IsA("BasePart") then return d end
        end
    end
    for _,d in ipairs(inst:GetDescendants()) do
        if d:IsA("BasePart") then return d end
    end
    return nil
end

--// Theme Engine
local Themes = {
    Dark = {
        Bg = Color3.fromRGB(20,20,26), Panel = Color3.fromRGB(28,28,36),
        Accent = Color3.fromRGB(120,115,245), AccentSoft = Color3.fromRGB(95,90,210),
        Text = Color3.fromRGB(238,238,245), SubText = Color3.fromRGB(170,170,178),
        Stroke = Color3.fromRGB(60,60,72), Hover = Color3.fromRGB(40,40,52),
        Green = Color3.fromRGB(110,210,130), Red = Color3.fromRGB(230,90,96), Yellow=Color3.fromRGB(245,209,66)
    },
    Midnight = {
        Bg = Color3.fromRGB(12,14,24), Panel = Color3.fromRGB(18,20,34),
        Accent = Color3.fromRGB(80,180,255), AccentSoft = Color3.fromRGB(60,140,210),
        Text = Color3.fromRGB(228,232,240), SubText = Color3.fromRGB(150,158,172),
        Stroke = Color3.fromRGB(40,48,66), Hover = Color3.fromRGB(26,30,46),
        Green = Color3.fromRGB(90,205,140), Red = Color3.fromRGB(230,90,110), Yellow=Color3.fromRGB(245,209,66)
    },
    Neon = {
        Bg = Color3.fromRGB(18,18,22), Panel = Color3.fromRGB(22,22,28),
        Accent = Color3.fromRGB(255,80,200), AccentSoft = Color3.fromRGB(210,60,160),
        Text = Color3.fromRGB(245,245,255), SubText = Color3.fromRGB(172,170,190),
        Stroke = Color3.fromRGB(70,60,90), Hover = Color3.fromRGB(40,34,60),
        Green = Color3.fromRGB(110,240,200), Red = Color3.fromRGB(255,100,140), Yellow=Color3.fromRGB(255,230,120)
    }
}
local CurrentTheme = Themes.Dark

--// State + Keybinds
local State = { Visible = true, Dragging = false, BindListening = nil, Binds = {}, GlobalToggleKey = Enum.KeyCode.LeftShift }

--// Root GUI
local Gui = Instance.new("ScreenGui")
Gui.Name = "MYLF_LinoriaPlus"
Gui.IgnoreGuiInset = true
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

-- Notification layer
local NotifLayer = Instance.new("Frame"); NotifLayer.Name="NotifLayer"; NotifLayer.Size=UDim2.new(1,0,1,0); NotifLayer.BackgroundTransparency=1; NotifLayer.Parent=Gui
local function notify(text, dur)
    dur = dur or 2.5
    local t = Instance.new("TextLabel")
    t.BackgroundColor3 = CurrentTheme.Panel; t.TextColor3 = CurrentTheme.Text
    t.Font = Enum.Font.GothamSemibold; t.TextSize = 14; t.AutoLocalize=false
    t.Text = "  "..text; t.AnchorPoint = Vector2.new(1,0); t.Position = UDim2.new(1,-10,0,10)
    t.Size = UDim2.new(0,0,0,28); t.TextXAlignment = Enum.TextXAlignment.Left; t.Parent = NotifLayer
    makeCorner(t,6); makeStroke(t,1,.1); Instance.new("UISizeConstraint", t).MaxSize = Vector2.new(500,40)
    tween(t,.18,{Size=UDim2.new(0,math.clamp(t.TextBounds.X+22,140,460),0,28), BackgroundTransparency=0}):Play()
    task.delay(dur,function()
        local tw=tween(t,.18,{Position=UDim2.new(1,-10,0,-34), BackgroundTransparency=1})
        tw.Completed:Connect(function() t:Destroy() end) tw:Play()
    end)
end

--// Main Window
local Window = Instance.new("Frame"); Window.Name="Window"; Window.Size=UDim2.new(0, 720, 0, 460); Window.Position=UDim2.new(0.5,-360,0.5,-230)
Window.BackgroundColor3=CurrentTheme.Bg; Window.Active=true; Window.Parent=Gui
makeCorner(Window,10); makeStroke(Window,1,.2)

-- Drag
do
    local dragStart, startPos
    Window.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then
            State.Dragging=true; dragStart=input.Position; startPos=Window.Position
            input.Changed:Connect(function()
                if input.UserInputState==Enum.UserInputState.End then State.Dragging=false end
            end)
        end
    end)
    Window.InputChanged:Connect(function(input)
        if State.Dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
            local delta=input.Position-dragStart
            Window.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
        end
    end)
end

-- TitleBar
local TitleBar = Instance.new("Frame"); TitleBar.Name="TitleBar"; TitleBar.Size=UDim2.new(1,0,0,42); TitleBar.BackgroundColor3=CurrentTheme.Panel; TitleBar.Parent=Window
makeCorner(TitleBar,10); makeStroke(TitleBar,1,.1)
local Title = Instance.new("TextLabel"); Title.BackgroundTransparency=1; Title.Text="⚡ MYLF | Linoria+ (Legit Dev UI)"; Title.Font=Enum.Font.GothamBold; Title.TextSize=16
Title.TextColor3=CurrentTheme.Text; Title.TextXAlignment=Enum.TextXAlignment.Left; Title.Size=UDim2.new(1,-160,1,0); Title.Position=UDim2.new(0,14,0,0); Title.Parent=TitleBar
local ThemeDropdownBtn=Instance.new("TextButton"); ThemeDropdownBtn.Text="Theme: Dark"; ThemeDropdownBtn.AutoButtonColor=false; ThemeDropdownBtn.Font=Enum.Font.GothamSemibold
ThemeDropdownBtn.TextSize=13; ThemeDropdownBtn.TextColor3=CurrentTheme.Text; ThemeDropdownBtn.BackgroundColor3=CurrentTheme.Hover
ThemeDropdownBtn.AnchorPoint=Vector2.new(1,0.5); ThemeDropdownBtn.Position=UDim2.new(1,-10,0.5,0); ThemeDropdownBtn.Size=UDim2.new(0,140,0,26); ThemeDropdownBtn.Parent=TitleBar
makeCorner(ThemeDropdownBtn,6); makeStroke(ThemeDropdownBtn,1,.15)

-- Sidebar
local Sidebar = Instance.new("Frame"); Sidebar.Name="Sidebar"; Sidebar.BackgroundColor3=CurrentTheme.Panel; Sidebar.Position=UDim2.new(0,10,0,58); Sidebar.Size=UDim2.new(0,160,1,-68); Sidebar.Parent=Window
makeCorner(Sidebar,8); makeStroke(Sidebar,1,.08); pad(Sidebar,8)
local SideList = Instance.new("UIListLayout", Sidebar); SideList.Padding=UDim.new(0,8); SideList.SortOrder=Enum.SortOrder.LayoutOrder
local function makeTabButton(text, icon)
    local b=Instance.new("TextButton"); b.AutoButtonColor=false; b.Text=((icon and (icon.."  ")) or "")..text
    b.Font=Enum.Font.GothamSemibold; b.TextSize=14; b.TextColor3=CurrentTheme.Text; b.BackgroundColor3=CurrentTheme.Hover; b.Size=UDim2.new(1,-4,0,34); b.Parent=Sidebar
    makeCorner(b,6); makeStroke(b,1,.2)
    b.MouseEnter:Connect(function() tween(b,.12,{BackgroundColor3=CurrentTheme.AccentSoft}):Play() end)
    b.MouseLeave:Connect(function() tween(b,.18,{BackgroundColor3=CurrentTheme.Hover}):Play() end)
    return b
end

-- Content
local Content = Instance.new("Frame"); Content.Name="Content"; Content.BackgroundTransparency=1; Content.Position=UDim2.new(0,180,0,58); Content.Size=UDim2.new(1,-190,1,-68); Content.Parent=Window

-- Pages
local Pages = {}
local function newPage(name)
    local p=Instance.new("Frame"); p.Visible=false; p.BackgroundColor3=CurrentTheme.Panel; p.Size=UDim2.new(1,0,1,0); p.Parent=Content
    makeCorner(p,8); makeStroke(p,1,.08); pad(p,10)
    local list=Instance.new("UIListLayout", p); list.Padding=UDim.new(0,10); list.FillDirection=Enum.FillDirection.Horizontal; list.SortOrder=Enum.SortOrder.LayoutOrder
    Instance.new("UIAspectRatioConstraint", p).AspectRatio=16/9
    Pages[name]=p; return p
end
local function newSection(parent,title)
    local s=Instance.new("Frame"); s.BackgroundTransparency=0; s.BackgroundColor3=CurrentTheme.Bg; s.Size=UDim2.new(0.5,-8,1,0); s.Parent=parent
    makeCorner(s,8); makeStroke(s,1,.08); pad(s,10)
    local t=Instance.new("TextLabel"); t.BackgroundTransparency=1; t.Text=title; t.Font=Enum.Font.GothamBold; t.TextSize=14; t.TextColor3=CurrentTheme.Text; t.Size=UDim2.new(1,0,0,18); t.Parent=s
    local list=Instance.new("UIListLayout", s); list.Padding=UDim.new(0,8); list.SortOrder=Enum.SortOrder.LayoutOrder
    return s
end

-- Controls Factory
local Controls = {}
local function makeRow(parent,label)
    local f=Instance.new("Frame"); f.BackgroundTransparency=1; f.Size=UDim2.new(1,0,0,28); f.Parent=parent
    local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Text=label; l.Font=Enum.Font.Gotham; l.TextSize=13; l.TextXAlignment=Enum.TextXAlignment.Left
    l.TextColor3=CurrentTheme.SubText; l.Size=UDim2.new(0.45,0,1,0); l.Parent=f
    return f,l
end
function Controls.Toggle(parent,label,default,callback)
    local row,lab=makeRow(parent,label)
    local btn=Instance.new("TextButton"); btn.AutoButtonColor=false; btn.Text=default and "ON" or "OFF"; btn.Font=Enum.Font.GothamBold; btn.TextSize=12
    btn.TextColor3=default and CurrentTheme.Green or CurrentTheme.Red; btn.BackgroundColor3=CurrentTheme.Hover; btn.Size=UDim2.new(0,70,0,24)
    btn.Position=UDim2.new(1,-80,0.5,-12); btn.Parent=row; makeCorner(btn,6); makeStroke(btn,1,.2)
    local on=default or false
    btn.MouseButton1Click:Connect(function()
        on=not on; btn.Text=on and "ON" or "OFF"; btn.TextColor3=on and CurrentTheme.Green or CurrentTheme.Red
        tween(btn,.08,{BackgroundColor3=on and CurrentTheme.AccentSoft or CurrentTheme.Hover}):Play()
        if callback then task.spawn(callback,on) end
    end)
    return {
        Set=function(v) on=v; btn.Text=v and "ON" or "OFF"; btn.TextColor3=v and CurrentTheme.Green or CurrentTheme.Red; if callback then callback(v) end end,
        Get=function() return on end, Button=btn, Row=row, Label=lab
    }
end
function Controls.Slider(parent,label,min,max,default,fmt,callback)
    local row,lab=makeRow(parent,label)
    local frame=Instance.new("Frame"); frame.Size=UDim2.new(0.52,0,0,24); frame.Position=UDim2.new(0.46,0,0.5,-12); frame.BackgroundColor3=CurrentTheme.Hover; frame.Parent=row
    makeCorner(frame,6); makeStroke(frame,1,.15)
    local fill=Instance.new("Frame"); fill.BackgroundColor3=CurrentTheme.Accent; fill.Size=UDim2.new((default-min)/(max-min),0,1,0); fill.Parent=frame; makeCorner(fill,6)
    local valText=Instance.new("TextLabel"); valText.BackgroundTransparency=1; valText.TextColor3=CurrentTheme.Text; valText.Font=Enum.Font.GothamSemibold; valText.TextSize=12
    valText.Size=UDim2.new(0,60,1,0); valText.AnchorPoint=Vector2.new(1,0); valText.Position=UDim2.new(1,-6,0,0); valText.Parent=frame; valText.Text=(fmt or "%d"):format(default)
    local dragging=false; local value=default or min
    local function setFromX(x)
        local rel=clamp((x-frame.AbsolutePosition.X)/frame.AbsoluteSize.X,0,1)
        value=round(min+(max-min)*rel,2); fill.Size=UDim2.new((value-min)/(max-min),0,1,0)
        valText.Text=(fmt or "%d"):format(value); if callback then callback(value) end
    end
    frame.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; setFromX(input.Position.X) end end)
    frame.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then setFromX(input.Position.X) end end)
    return { Set=function(v) value=clamp(v,min,max); fill.Size=UDim2.new((value-min)/(max-min),0,1,0); valText.Text=(fmt or "%d"):format(value); if callback then callback(value) end end, Get=function() return value end }
end
function Controls.Dropdown(parent,label,items,defaultIdx,callback)
    local row,lab=makeRow(parent,label)
    local btn=Instance.new("TextButton"); btn.AutoButtonColor=false; btn.Font=Enum.Font.GothamSemibold; btn.TextSize=12; btn.TextColor3=CurrentTheme.Text
    btn.BackgroundColor3=CurrentTheme.Hover; btn.Size=UDim2.new(0,160,0,24); btn.Position=UDim2.new(1,-170,0.5,-12); btn.Parent=row
    makeCorner(btn,6); makeStroke(btn,1,.15)
    local idx=defaultIdx or 1; btn.Text=items[idx] or "-"
    local open=false
    local listFrame=Instance.new("Frame"); listFrame.Visible=false; listFrame.BackgroundColor3=CurrentTheme.Panel; listFrame.Size=UDim2.new(0,160,0, math.min(6,#items)*24+10)
    listFrame.AnchorPoint=Vector2.new(0,0); listFrame.Position=UDim2.new(1,-170,0.5,14); listFrame.Parent=row; makeCorner(listFrame,6); makeStroke(listFrame,1,.15); pad(listFrame,6)
    local ul=Instance.new("UIListLayout", listFrame); ul.Padding=UDim.new(0,6)
    for i,v in ipairs(items) do
        local it=Instance.new("TextButton"); it.AutoButtonColor=false; it.Font=Enum.Font.Gotham; it.TextSize=12; it.TextColor3=CurrentTheme.Text; it.Text=v
        it.BackgroundColor3=CurrentTheme.Hover; it.Size=UDim2.new(1,0,0,24); it.Parent=listFrame; makeCorner(it,6)
        it.MouseEnter:Connect(function() tween(it,.08,{BackgroundColor3=CurrentTheme.AccentSoft}):Play() end)
        it.MouseLeave:Connect(function() tween(it,.12,{BackgroundColor3=CurrentTheme.Hover}):Play() end)
        it.MouseButton1Click:Connect(function() idx=i; btn.Text=v; listFrame.Visible=false; open=false; if callback then callback(v,i) end end)
    end
    btn.MouseButton1Click:Connect(function() open=not open; listFrame.Visible=open end)
    return { SetIndex=function(i) if items[i] then idx=i; btn.Text=items[i]; if callback then callback(items[i],i) end end end, GetIndex=function() return idx end, GetValue=function() return items[idx] end }
end
function Controls.Color(parent,label,default,callback)
    local row,lab=makeRow(parent,label)
    local box=Instance.new("TextButton"); box.AutoButtonColor=false; box.Text=""; box.Size=UDim2.new(0,36,0,24); box.Position=UDim2.new(1,-46,0.5,-12)
    box.BackgroundColor3=default or CurrentTheme.Accent; box.Parent=row; makeCorner(box,6); makeStroke(box,1,.15)
    local picking=false
    box.MouseButton1Click:Connect(function() picking=not picking; notify(picking and "Renk seç: ekrana tıkla." or "Renk seçimi kapatıldı.") end)
    UserInputService.InputBegan:Connect(function(input,gp)
        if picking and input.UserInputType==Enum.UserInputType.MouseButton1 then
            picking=false; local rel=(input.Position.X%512)/512; local c=hsl(rel,.7,.55); box.BackgroundColor3=c; if callback then callback(c) end
        end
    end)
    return { Set=function(c) box.BackgroundColor3=c; if callback then callback(c) end end, Get=function() return box.BackgroundColor3 end }
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

--// Crosshair Overlay (GUI-based)
local Overlay = Instance.new("ScreenGui"); Overlay.Name="MYLF_HUD"; Overlay.IgnoreGuiInset=true; Overlay.ResetOnSpawn=false; Overlay.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; Overlay.Parent=PlayerGui
local Crosshair = Instance.new("Frame"); Crosshair.Name="Crosshair"; Crosshair.AnchorPoint=Vector2.new(0.5,0.5); Crosshair.Position=UDim2.fromScale(0.5,0.5); Crosshair.Size=UDim2.fromOffset(2,2)
Crosshair.BackgroundTransparency=1; Crosshair.Visible=true; Crosshair.Parent=Overlay
local arms={}
for i=1,4 do local a=Instance.new("Frame"); a.BackgroundColor3=Themes.Dark.Accent; a.BorderSizePixel=0; a.Parent=Crosshair; makeCorner(a,2); arms[i]=a end
local CrosshairCfg={ Enabled=true, Gap=6, Length=8, Thickness=2, Opacity=1, Color=Themes.Dark.Accent }
local function layoutCrosshair()
    for _,a in ipairs(arms) do a.BackgroundTransparency=1-CrosshairCfg.Opacity; a.BackgroundColor3=CrosshairCfg.Color end
    arms[1].Size=UDim2.fromOffset(CrosshairCfg.Thickness, CrosshairCfg.Length); arms[1].Position=UDim2.fromOffset(-CrosshairCfg.Thickness/2, -(CrosshairCfg.Gap+CrosshairCfg.Length))
    arms[2].Size=UDim2.fromOffset(CrosshairCfg.Thickness, CrosshairCfg.Length); arms[2].Position=UDim2.fromOffset(-CrosshairCfg.Thickness/2, CrosshairCfg.Gap)
    arms[3].Size=UDim2.fromOffset(CrosshairCfg.Length, CrosshairCfg.Thickness); arms[3].Position=UDim2.fromOffset(-(CrosshairCfg.Gap+CrosshairCfg.Length), -CrosshairCfg.Thickness/2)
    arms[4].Size=UDim2.fromOffset(CrosshairCfg.Length, CrosshairCfg.Thickness); arms[4].Position=UDim2.fromOffset(CrosshairCfg.Gap, -CrosshairCfg.Thickness/2)
    Crosshair.Visible=CrosshairCfg.Enabled
end
layoutCrosshair()

-- FPS / Ping HUD
local HudTop=Instance.new("TextLabel"); HudTop.Name="Perf"; HudTop.BackgroundTransparency=1; HudTop.TextColor3=CurrentTheme.SubText; HudTop.Font=Enum.Font.GothamSemibold; HudTop.TextSize=13
HudTop.TextXAlignment=Enum.TextXAlignment.Left; HudTop.Position=UDim2.new(0,10,0,8); HudTop.Size=UDim2.new(0,240,0,18); HudTop.Parent=Overlay
local fps, dtAccum, dtCount = 60, 0, 0
RunService.RenderStepped:Connect(function(dt)
    dtAccum+=dt; dtCount+=1
    if dtAccum>=0.5 then
        fps=round(dtCount/dtAccum,0); dtAccum,dtCount=0,0
        local pingStr="?"
        pcall(function() local item=Stats.Network.ServerStatsItem["Data Ping"]; if item then pingStr=tostring(item:GetValueString()):gsub(" RTT","") end end)
        HudTop.Text=("FPS: %s   Ping: %s"):format(fps,pingStr)
    end
end)

-- Waypoints / Ping
local WayFolder=Instance.new("Folder"); WayFolder.Name="MYLF_Waypoints_Local"; WayFolder.Parent=workspace
local function createWaypoint(name,pos)
    local part=Instance.new("Part"); part.Anchored=true; part.CanCollide=false; part.Transparency=1; part.Size=Vector3.new(1,1,1); part.CFrame=CFrame.new(pos); part.Parent=WayFolder
    local att=Instance.new("Attachment", part)
    local bb=Instance.new("BillboardGui"); bb.Adornee=att; bb.Size=UDim2.fromOffset(160,40); bb.AlwaysOnTop=true; bb.Parent=part
    local label=Instance.new("TextLabel"); label.Size=UDim2.new(1,0,1,0); label.BackgroundTransparency=0.2; label.BackgroundColor3=CurrentTheme.Panel; label.TextColor3=CurrentTheme.Text
    label.Font=Enum.Font.GothamBold; label.TextSize=14; label.Text="📍 "..name; label.Parent=bb; makeCorner(label,6); makeStroke(label,1,.15)
    return part
end
local function clearWaypoints() for _,v in ipairs(WayFolder:GetChildren()) do v:Destroy() end end

--// Build Pages
local pPlayer   = newPage("Player")
local pScanner  = newPage("Scanner")
local pVisuals  = newPage("Visuals")
local pHUD      = newPage("HUD")
local pSettings = newPage("Settings")

-- Tabs
local tPlayer   = makeTabButton("Player","👤")
local tScanner  = makeTabButton("Scanner","🔎")
local tVisuals  = makeTabButton("Visuals","🎨")
local tHUD      = makeTabButton("HUD","🧭")
local tSettings = makeTabButton("Settings","⚙️")

local function showPage(name) for k,frame in pairs(Pages) do frame.Visible=(k==name) end end
showPage("Player")
tPlayer.MouseButton1Click:Connect(function() showPage("Player") end)
tScanner.MouseButton1Click:Connect(function() showPage("Scanner") end)
tVisuals.MouseButton1Click:Connect(function() showPage("Visuals") end)
tHUD.MouseButton1Click:Connect(function() showPage("HUD") end)
tSettings.MouseButton1Click:Connect(function() showPage("Settings") end)

-- PLAYER PAGE
local sMovement = newSection(pPlayer, "Movement / Camera")
local sTools    = newSection(pPlayer, "Utilities")

-- Camera Mode
Controls.Dropdown(sMovement, "Camera Mode", {"ThirdPerson","FirstPerson","Orbital"}, 1, function(v)
    if v=="ThirdPerson" then LP.CameraMode=Enum.CameraMode.Classic; Camera.CameraType=Enum.CameraType.Custom
    elseif v=="FirstPerson" then LP.CameraMode=Enum.CameraMode.LockFirstPerson; Camera.CameraType=Enum.CameraType.Custom
    elseif v=="Orbital" then LP.CameraMode=Enum.CameraMode.Classic; Camera.CameraType=Enum.CameraType.Orbital end
    notify("Kamera: "..v)
end)
-- FOV
Controls.Slider(sMovement, "Field of View", 60, 100, Camera.FieldOfView, "%d", function(v) Camera.FieldOfView=v end)
-- Sway (kozmetik)
local swayConn
Controls.Toggle(sMovement, "Camera Sway", false, function(on)
    if swayConn then swayConn:Disconnect(); swayConn=nil end
    if on then local t=0 swayConn=RunService.RenderStepped:Connect(function(dt) t+=dt; Camera.CFrame=Camera.CFrame*CFrame.Angles(0,0, math.sin(t*1.2)*0.0008) end) end
end)

-- Waypoints
Controls.Button(sTools, "Waypoint", "Add Current", function()
    local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if hrp then local nm="WP-"..string.sub(HttpService:GenerateGUID(false),1,4); createWaypoint(nm, hrp.Position + Vector3.new(0,3,0)); notify("Waypoint eklendi: "..nm)
    else notify("Karakter bulunamadı.", 2.0) end
end)
Controls.Button(sTools, "Waypoint", "Clear All", function() clearWaypoints(); notify("Tüm waypoint'ler silindi.") end)

-- VISUALS PAGE (Crosshair)
local sCross = newSection(pVisuals, "Crosshair")
local sTheme = newSection(pVisuals, "Theme / Colors")
local crossToggle = Controls.Toggle(sCross, "Enable Crosshair", true, function(on) CrosshairCfg.Enabled=on; layoutCrosshair() end)
Controls.Slider(sCross,"Gap",0,30,CrosshairCfg.Gap,"%d",function(v) CrosshairCfg.Gap=v; layoutCrosshair() end)
Controls.Slider(sCross,"Length",2,40,CrosshairCfg.Length,"%d",function(v) CrosshairCfg.Length=v; layoutCrosshair() end)
Controls.Slider(sCross,"Thickness",1,8,CrosshairCfg.Thickness,"%d",function(v) CrosshairCfg.Thickness=v; layoutCrosshair() end)
Controls.Slider(sCross,"Opacity",0,1,CrosshairCfg.Opacity,"%.2f",function(v) CrosshairCfg.Opacity=v; layoutCrosshair() end)
Controls.Color(sCross,"Color",CrosshairCfg.Color,function(c) CrosshairCfg.Color=c; layoutCrosshair() end)
Controls.Color(sTheme,"Accent Color (Override)",CurrentTheme.Accent,function(c) CrosshairCfg.Color=c; layoutCrosshair(); CurrentTheme.Accent=c; notify("Accent değişti.") end)

-- HUD PAGE
local sHud  = newSection(pHUD, "Performance")
local sHud2 = newSection(pHUD, "Toggles")
local fpsToggle = Controls.Toggle(sHud2, "Show FPS/Ping", true, function(on) HudTop.Visible=on end); HudTop.Visible=true
Controls.Button(sHud, "Snapshot", "Notify Now", function() notify(("FPS %s  |  FOV %d"):format(tostring(round(fps,0)), round(Camera.FieldOfView,0)), 2.2) end)

-- SETTINGS PAGE
local sBind = newSection(pSettings, "Keybinds")
local sMeta = newSection(pSettings, "Meta")
local bindLabel=Instance.new("TextLabel"); bindLabel.BackgroundTransparency=1; bindLabel.Text="Bind: Crosshair Toggle"; bindLabel.Font=Enum.Font.Gotham; bindLabel.TextSize=13
bindLabel.TextColor3=CurrentTheme.SubText; bindLabel.Size=UDim2.new(1,0,0,18); bindLabel.Parent=sBind
local bindBtn=Instance.new("TextButton"); bindBtn.AutoButtonColor=false; bindBtn.Text="Set Key (none)"; bindBtn.Font=Enum.Font.GothamSemibold; bindBtn.TextSize=12; bindBtn.TextColor3=CurrentTheme.Text
bindBtn.BackgroundColor3=CurrentTheme.Hover; bindBtn.Size=UDim2.new(0,140,0,24); bindBtn.Parent=sBind; makeCorner(bindBtn,6); makeStroke(bindBtn,1,.15)
bindBtn.MouseButton1Click:Connect(function() if State.BindListening then return end State.BindListening="CrosshairToggle"; bindBtn.Text="Press any key..."; notify("Crosshair için bir tuş seç.") end)
local GlobalHint=Instance.new("TextLabel"); GlobalHint.BackgroundTransparency=1; GlobalHint.Text="Global Toggle: LeftShift (gizle/göster)"; GlobalHint.Font=Enum.Font.Gotham; GlobalHint.TextSize=13
GlobalHint.TextColor3=CurrentTheme.SubText; GlobalHint.Size=UDim2.new(1,0,0,18); GlobalHint.Parent=sMeta
Controls.Button(sMeta,"Visibility","Hide Window",function() State.Visible=not State.Visible; Window.Visible=State.Visible; notify(State.Visible and "Menü gösterildi." or "Menü gizlendi.") end)

-- Theme dropdown
local themeOrder={"Dark","Midnight","Neon"}
local function setThemeByName(name)
    local t=Themes[name] or Themes.Dark; CurrentTheme=t
    Window.BackgroundColor3=t.Bg; TitleBar.BackgroundColor3=t.Panel; Title.TextColor3=t.Text; ThemeDropdownBtn.TextColor3=t.Text; ThemeDropdownBtn.BackgroundColor3=t.Hover
    Sidebar.BackgroundColor3=t.Panel; HudTop.TextColor3=t.SubText
    for _,b in ipairs(Sidebar:GetChildren()) do if b:IsA("TextButton") then b.TextColor3=t.Text; b.BackgroundColor3=t.Hover end end
    for _,page in pairs(Pages) do page.BackgroundColor3=t.Panel; for _,sec in ipairs(page:GetChildren()) do if sec:IsA("Frame") and sec~=page then sec.BackgroundColor3=t.Bg end end end
    layoutCrosshair()
end
local themeIndex=1
ThemeDropdownBtn.MouseButton1Click:Connect(function() themeIndex=themeIndex%#themeOrder+1; local name=themeOrder[themeIndex]; ThemeDropdownBtn.Text="Theme: "..name; setThemeByName(name); notify("Tema: "..name) end)
setThemeByName("Dark")

-- Key handling
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if State.BindListening and input.KeyCode~=Enum.KeyCode.Unknown then
        local key=input.KeyCode
        if State.BindListening=="CrosshairToggle" then State.Binds["CrosshairToggle"]=key; bindBtn.Text="Set Key ("..key.Name..")"; notify("Crosshair bind: "..key.Name) end
        State.BindListening=nil; return
    end
    if input.KeyCode==State.GlobalToggleKey then State.Visible=not State.Visible; Window.Visible=State.Visible; notify(State.Visible and "Menü gösterildi." or "Menü gizlendi."); return end
    if State.Binds["CrosshairToggle"] and input.KeyCode==State.Binds["CrosshairToggle"] then
        CrosshairCfg.Enabled=not CrosshairCfg.Enabled; crossToggle.Set(CrosshairCfg.Enabled); layoutCrosshair(); notify("Crosshair: "..(CrosshairCfg.Enabled and "ON" or "OFF"))
    end
end)

-- Safety respawn
LP.CharacterAdded:Connect(function() task.delay(1.0,function() layoutCrosshair(); HudTop.Visible=fpsToggle.Get() end) end)

-- Start toast
notify("MYLF Linoria+ yüklendi. LeftShift ile gizle/göster.", 3.2)

-- ======================================================================
-- ============================== SCANNER ================================
-- ======================================================================

-- Sağ/alt kaydırmalı, detaylı içerik + filtre + arama + ping/track + JSON OUT

-- Config
local ScannerState = {
    Enabled = true,
    AutoRefresh = true,
    Interval = 2.0,
    Deep = true,
    MaxItems = 300,
    Search = "",
    SectionFilter = "All", -- All / Players / Workspace / Backpack
    IncludePrompts = true,
    IncludeClickDetectors = true,
    IncludeTools = true,
    IncludeRemoteObjects = false, -- sadece isim gösterir, işlem yapmaz
}

local ScanResults = { Players = {}, Workspace = {}, Backpack = {} }
local Tracked = {} -- [Instance] = {billboard=..., label=..., conn=...}

-- UI: pScanner → ScrollingFrame
local scRoot = Instance.new("ScrollingFrame")
scRoot.Size = UDim2.new(1,0,1,0)
scRoot.CanvasSize = UDim2.new(0,0,0,1200)
scRoot.ScrollBarThickness = 4
scRoot.ScrollingDirection = Enum.ScrollingDirection.Y
scRoot.BackgroundTransparency = 1
scRoot.Parent = pScanner
pad(scRoot,8)
local scList = Instance.new("UIListLayout", scRoot); scList.Padding=UDim.new(0,10); scList.SortOrder=Enum.SortOrder.LayoutOrder

-- Üst: Filtre/Arama/AutoRefresh barı (yatay kaydırmalı mini-bar)
local bar = Instance.new("ScrollingFrame"); bar.Size=UDim2.new(1,0,0,64); bar.CanvasSize=UDim2.new(0,1200,0,0); bar.ScrollBarThickness=3
bar.ScrollingDirection = Enum.ScrollingDirection.X; bar.BackgroundColor3=CurrentTheme.Bg; bar.Parent=scRoot; makeCorner(bar,8); makeStroke(bar,1,.08); pad(bar,8)
local barList = Instance.new("UIListLayout", bar); barList.Padding=UDim.new(0,8); barList.FillDirection=Enum.FillDirection.Horizontal

-- Search box
local searchBox = Instance.new("TextBox"); searchBox.PlaceholderText="Search name/path..."; searchBox.Font=Enum.Font.Gotham; searchBox.TextSize=13
searchBox.TextColor3=CurrentTheme.Text; searchBox.PlaceholderColor3=CurrentTheme.SubText; searchBox.BackgroundColor3=CurrentTheme.Hover
searchBox.Size=UDim2.new(0,240,1,-16); searchBox.Parent=bar; makeCorner(searchBox,6); makeStroke(searchBox,1,.12); pad(searchBox,6)
searchBox.FocusLost:Connect(function() ScannerState.Search = string.lower(searchBox.Text or "") end)

-- Section filter
local secFilterBtn = Instance.new("TextButton"); secFilterBtn.Text="Section: All"; secFilterBtn.AutoButtonColor=false; secFilterBtn.Font=Enum.Font.GothamSemibold; secFilterBtn.TextSize=12
secFilterBtn.TextColor3=CurrentTheme.Text; secFilterBtn.BackgroundColor3=CurrentTheme.Hover; secFilterBtn.Size=UDim2.new(0,140,1,-16); secFilterBtn.Parent=bar; makeCorner(secFilterBtn,6); makeStroke(secFilterBtn,1,.12)
local secOrder={"All","Players","Workspace","Backpack"}; local secIndex=1
secFilterBtn.MouseButton1Click:Connect(function() secIndex=secIndex%#secOrder+1; ScannerState.SectionFilter=secOrder[secIndex]; secFilterBtn.Text="Section: "..ScannerState.SectionFilter end)

-- Auto refresh toggle + interval
local autoBtn = Instance.new("TextButton"); autoBtn.Text="Auto: ON"; autoBtn.AutoButtonColor=false; autoBtn.Font=Enum.Font.GothamSemibold; autoBtn.TextSize=12
autoBtn.TextColor3=CurrentTheme.Green; autoBtn.BackgroundColor3=CurrentTheme.Hover; autoBtn.Size=UDim2.new(0,100,1,-16); autoBtn.Parent=bar; makeCorner(autoBtn,6); makeStroke(autoBtn,1,.12)
autoBtn.MouseButton1Click:Connect(function() ScannerState.AutoRefresh = not ScannerState.AutoRefresh; autoBtn.Text = "Auto: "..(ScannerState.AutoRefresh and "ON" or "OFF"); autoBtn.TextColor3 = ScannerState.AutoRefresh and CurrentTheme.Green or CurrentTheme.Red end)
local intHolder = Instance.new("Frame"); intHolder.Size=UDim2.new(0,280,1,-16); intHolder.BackgroundTransparency=1; intHolder.Parent=bar
local intLab = Instance.new("TextLabel"); intLab.BackgroundTransparency=1; intLab.Text="Interval (sec)"; intLab.Font=Enum.Font.Gotham; intLab.TextSize=12; intLab.TextColor3=CurrentTheme.SubText; intLab.Size=UDim2.new(0,100,1,0); intLab.Parent=intHolder
local dummy={}; function dummy.cb(v) ScannerState.Interval=v end
local intSlider = Controls.Slider(intHolder,"",0.2,10,ScannerState.Interval,"%.1f",dummy.cb); intSlider.Set(ScannerState.Interval)

-- Dahil edilecek türler
local typesBar = Instance.new("Frame"); typesBar.Size=UDim2.new(0,520,1,-16); typesBar.BackgroundTransparency=1; typesBar.Parent=bar
local function addMiniToggle(parent, label, key)
    local btn=Instance.new("TextButton"); btn.AutoButtonColor=false; btn.Text=label..": "..(ScannerState[key] and "ON" or "OFF")
    btn.Font=Enum.Font.GothamSemibold; btn.TextSize=12; btn.TextColor3=ScannerState[key] and CurrentTheme.Green or CurrentTheme.Red
    btn.BackgroundColor3=CurrentTheme.Hover; btn.Size=UDim2.new(0,160,1,-16); btn.Parent=parent; makeCorner(btn,6); makeStroke(btn,1,.12)
    btn.MouseButton1Click:Connect(function()
        ScannerState[key]=not ScannerState[key]
        btn.Text=label..": "..(ScannerState[key] and "ON" or "OFF")
        btn.TextColor3=ScannerState[key] and CurrentTheme.Green or CurrentTheme.Red
    end)
end
addMiniToggle(typesBar,"Deep","Deep")
addMiniToggle(typesBar,"Tools","IncludeTools")
addMiniToggle(typesBar,"Prompts","IncludePrompts")
addMiniToggle(typesBar,"ClickDetectors","IncludeClickDetectors")
addMiniToggle(typesBar,"RemoteObjs","IncludeRemoteObjects")

-- JSON Export
local exportBtn = Instance.new("TextButton"); exportBtn.Text="Export JSON"; exportBtn.AutoButtonColor=false; exportBtn.Font=Enum.Font.GothamSemibold; exportBtn.TextSize=12
exportBtn.TextColor3=CurrentTheme.Text; exportBtn.BackgroundColor3=CurrentTheme.Hover; exportBtn.Size=UDim2.new(0,120,1,-16); exportBtn.Parent=bar; makeCorner(exportBtn,6); makeStroke(exportBtn,1,.12)

-- Stats strip
local statStrip = Instance.new("TextLabel"); statStrip.BackgroundColor3=CurrentTheme.Panel; statStrip.TextColor3=CurrentTheme.SubText; statStrip.Font=Enum.Font.GothamSemibold; statStrip.TextSize=12
statStrip.TextXAlignment=Enum.TextXAlignment.Left; statStrip.Size=UDim2.new(1,0,0,26); statStrip.Text="Players: 0 | Workspace: 0 | Backpack: 0"; statStrip.Parent=scRoot
makeCorner(statStrip,6); makeStroke(statStrip,1,.08); pad(statStrip,6)

-- Bölümler
local secPlayers = newSection(scRoot, "Players")
local secWorkspace = newSection(scRoot, "Workspace")
local secBackpack = newSection(scRoot, "Backpack")

-- Inspector Modal
local Inspector = Instance.new("Frame"); Inspector.Size=UDim2.new(0,540,0,360); Inspector.Position=UDim2.new(0.5,-270,0.5,-180)
Inspector.BackgroundColor3=CurrentTheme.Panel; Inspector.Visible=false; Inspector.Parent=Gui; makeCorner(Inspector,10); makeStroke(Inspector,1,.12); pad(Inspector,10)
local insTitle=Instance.new("TextLabel"); insTitle.BackgroundTransparency=1; insTitle.Text="Inspector"; insTitle.Font=Enum.Font.GothamBold; insTitle.TextSize=16; insTitle.TextColor3=CurrentTheme.Text; insTitle.Size=UDim2.new(1,0,0,20); insTitle.Parent=Inspector
local insClose=Instance.new("TextButton"); insClose.Text="Close"; insClose.AutoButtonColor=false; insClose.Font=Enum.Font.GothamSemibold; insClose.TextSize=12; insClose.TextColor3=CurrentTheme.Text
insClose.BackgroundColor3=CurrentTheme.Hover; insClose.Size=UDim2.new(0,80,0,24); insClose.AnchorPoint=Vector2.new(1,0); insClose.Position=UDim2.new(1,-6,0,6); insClose.Parent=Inspector; makeCorner(insClose,6); makeStroke(insClose,1,.12)
local insBody=Instance.new("TextBox"); insBody.ClearTextOnFocus=false; insBody.MultiLine=true; insBody.TextWrapped=false; insBody.TextXAlignment=Enum.TextXAlignment.Left; insBody.TextYAlignment=Enum.TextYAlignment.Top
insBody.Font=Enum.Font.Code; insBody.TextSize=12; insBody.TextColor3=CurrentTheme.Text; insBody.BackgroundColor3=CurrentTheme.Bg; insBody.Size=UDim2.new(1,-12,1,-38); insBody.Position=UDim2.new(0,6,0,32); insBody.Parent=Inspector; makeCorner(insBody,8); makeStroke(insBody,1,.08); pad(insBody,8)
insClose.MouseButton1Click:Connect(function() Inspector.Visible=false end)

local function showInspector(tbl, title)
    local ok, json = pcall(function() return HttpService:JSONEncode(tbl) end)
    insTitle.Text = title or "Inspector"
    insBody.Text = ok and json or "encode error"
    Inspector.Visible=true
end
exportBtn.MouseButton1Click:Connect(function() showInspector(ScanResults, "ScanResults (JSON)") end)

-- Render helpers
local function clearChildren(frame) for _,ch in ipairs(frame:GetChildren()) do if ch:IsA("Frame") then ch:Destroy() end end end
local function miniRow(parent, title, subtitle)
    local f=Instance.new("Frame"); f.BackgroundColor3=CurrentTheme.Hover; f.Size=UDim2.new(1,0,0,54); f.Parent=parent; makeCorner(f,8); makeStroke(f,1,.08); pad(f,6)
    local t=Instance.new("TextLabel"); t.BackgroundTransparency=1; t.Text=title; t.Font=Enum.Font.GothamSemibold; t.TextSize=13; t.TextColor3=CurrentTheme.Text; t.Size=UDim2.new(1, -220, 0, 20); t.Parent=f
    local s=Instance.new("TextLabel"); s.BackgroundTransparency=1; s.Text=subtitle or ""; s.Font=Enum.Font.Gotham; s.TextSize=12; s.TextColor3=CurrentTheme.SubText; s.Size=UDim2.new(1,-220,0,18); s.Position=UDim2.new(0,0,0,22); s.Parent=f
    local btnBox=Instance.new("Frame"); btnBox.BackgroundTransparency=1; btnBox.Size=UDim2.new(0,210,1,0); btnBox.AnchorPoint=Vector2.new(1,0); btnBox.Position=UDim2.new(1,0,0,0); btnBox.Parent=f
    local ul=Instance.new("UIListLayout", btnBox); ul.Padding=UDim.new(0,6); ul.FillDirection=Enum.FillDirection.Horizontal
    local function mk(text,cb)
        local b=Instance.new("TextButton"); b.AutoButtonColor=false; b.Text=text; b.Font=Enum.Font.GothamSemibold; b.TextSize=12; b.TextColor3=CurrentTheme.Text
        b.BackgroundColor3=CurrentTheme.Bg; b.Size=UDim2.new(0,100,0,24); b.Parent=btnBox; makeCorner(b,6); makeStroke(b,1,.12); b.MouseButton1Click:Connect(cb)
        b.MouseEnter:Connect(function() tween(b,.08,{BackgroundColor3=CurrentTheme.AccentSoft}):Play() end)
        b.MouseLeave:Connect(function() tween(b,.12,{BackgroundColor3=CurrentTheme.Bg}):Play() end)
        return b
    end
    return f, mk
end

-- Track/Ping helpers
local function pingInstance(inst, label)
    local part=findAttachablePart(inst)
    if not part then notify("Ping: uygun konum bulunamadı."); return end
    createWaypoint(label or inst.Name, part.Position + Vector3.new(0,3,0))
    notify("Ping atıldı: "..(label or inst.Name))
end
local function trackInstance(inst)
    if Tracked[inst] then -- kapat
        local t=Tracked[inst]; if t.conn then t.conn:Disconnect() end
        if t.gui then t.gui:Destroy() end; Tracked[inst]=nil; notify("Tracking kapatıldı: "..inst.Name); return
    end
    local part=findAttachablePart(inst)
    if not part then notify("Track: BasePart bulunamadı."); return end
    local bb=Instance.new("BillboardGui"); bb.Adornee=part; bb.Size=UDim2.fromOffset(160, 38); bb.AlwaysOnTop=true; bb.Parent=Overlay
    local lab=Instance.new("TextLabel"); lab.Size=UDim2.new(1,0,1,0); lab.BackgroundColor3=CurrentTheme.Panel; lab.TextColor3=CurrentTheme.Text; lab.Font=Enum.Font.GothamBold; lab.TextSize=13
    lab.Text="👁 "..inst.Name; lab.Parent=bb; makeCorner(lab,6); makeStroke(lab,1,.12)
    local conn=RunService.RenderStepped:Connect(function()
        pcall(function()
            local p=part.Position; local my=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"); if my then
                local d=(p-my.Position).Magnitude; lab.Text=("👁 %s  |  %.1fm"):format(inst.Name, d)
            end
        end)
    end)
    Tracked[inst]={gui=bb, conn=conn}
    notify("Tracking açıldı: "..inst.Name)
end

-- ========= SCAN LOGIC =========

local function matchesSearch(nameOrPath)
    local s=ScannerState.Search
    if s=="" then return true end
    local txt=string.lower(nameOrPath or "")
    return string.find(txt, s, 1, true) ~= nil
end

-- Players scan
local function scanPlayers()
    local out={}
    for _,plr in ipairs(Players:GetPlayers()) do
        local entry={ Name=plr.Name, DisplayName=plr.DisplayName or plr.Name, Team=tostring(plr.Team and plr.Team.Name or "-") }
        local char=plr.Character
        if char then
            local hum=char:FindFirstChildOfClass("Humanoid")
            entry.CharacterPath=instancePath(char)
            entry.Health = hum and round(hum.Health,1) or nil
            entry.MaxHealth = hum and round(hum.MaxHealth,1) or nil
            entry.ToolsOnCharacter={}
            for _,ch in ipairs(char:GetChildren()) do
                if ch:IsA("Tool") then table.insert(entry.ToolsOnCharacter, ch.Name) end
            end
        end
        local bp=plr:FindFirstChild("Backpack")
        if bp then
            entry.BackpackPath=instancePath(bp)
            entry.BackpackTools={}
            for _,ch in ipairs(bp:GetChildren()) do
                if ch:IsA("Tool") then table.insert(entry.BackpackTools, ch.Name) end
            end
        end
        if matchesSearch((entry.DisplayName.." "..(entry.CharacterPath or "").." "..(entry.BackpackPath or ""))) then
            table.insert(out, entry)
            if #out>=ScannerState.MaxItems then break end
        end
    end
    ScanResults.Players = out
end

-- Workspace scan (Tools, Prompts, ClickDetectors, RemoteObjects)
local function scanWorkspace()
    local out={ Tools={}, Prompts={}, ClickDetectors={}, Remotes={} }
    local function push(where, inst)
        if matchesSearch(instancePath(inst)) then
            table.insert(where, { Name=inst.Name, Class=inst.ClassName, Path=instancePath(inst) })
        end
    end
    local function scan(root)
        for _,d in ipairs(root:GetDescendants()) do
            if ScannerState.IncludeTools and d:IsA("Tool") then push(out.Tools, d) end
            if ScannerState.IncludePrompts and d:IsA("ProximityPrompt") then push(out.Prompts, d) end
            if ScannerState.IncludeClickDetectors and d:IsA("ClickDetector") then push(out.ClickDetectors, d) end
            if ScannerState.IncludeRemoteObjects and (d:IsA("RemoteEvent") or d:IsA("RemoteFunction") or d:IsA("BindableEvent") or d:IsA("BindableFunction")) then
                push(out.Remotes, d)
            end
            if (#out.Tools + #out.Prompts + #out.ClickDetectors + #out.Remotes) >= ScannerState.MaxItems then break end
        end
    end
    if ScannerState.Deep then scan(workspace) else
        for _,ch in ipairs(workspace:GetChildren()) do scan(ch); if (#out.Tools + #out.Prompts + #out.ClickDetectors + #out.Remotes) >= ScannerState.MaxItems then break end end
    end
    ScanResults.Workspace = out
end

-- Backpack scan (LocalPlayer)
local function scanBackpack()
    local out={}
    local bp=LP:FindFirstChild("Backpack")
    if bp then
        for _,ch in ipairs(bp:GetChildren()) do
            if ch:IsA("Tool") then
                local e={ Name=ch.Name, Path=instancePath(ch), Handle=false, ChildrenCount=#ch:GetChildren() }
                if ch:FindFirstChild("Handle") then e.Handle=true end
                if matchesSearch(e.Name.." "..e.Path) then table.insert(out,e) end
                if #out>=ScannerState.MaxItems then break end
            end
        end
    end
    ScanResults.Backpack = out
end

local function runScan()
    if ScannerState.SectionFilter=="All" or ScannerState.SectionFilter=="Players" then scanPlayers() end
    if ScannerState.SectionFilter=="All" or ScannerState.SectionFilter=="Workspace" then scanWorkspace() end
    if ScannerState.SectionFilter=="All" or ScannerState.SectionFilter=="Backpack" then scanBackpack() end
end

-- Render UI
local function renderPlayers()
    clearChildren(secPlayers)
    for _,e in ipairs(ScanResults.Players or {}) do
        local subt = ("Team: %s   |   HP: %s/%s   |   BP Tools: %d  |  Char Tools: %d"):format(
            e.Team or "-", tostring(e.Health or "-"), tostring(e.MaxHealth or "-"),
            e.BackpackTools and #e.BackpackTools or 0, e.ToolsOnCharacter and #e.ToolsOnCharacter or 0
        )
        local row, mk = miniRow(secPlayers, (e.DisplayName or e.Name), subt)
        mk("Ping", function()
            local target = (Players:FindFirstChild(e.Name) and Players[e.Name].Character) or workspace:FindFirstChild(e.DisplayName or e.Name)
            pingInstance(target or workspace:FindFirstChild(e.Name) or workspace:FindFirstChildOfClass("Model"), e.DisplayName or e.Name)
        end)
        mk("Track", function()
            local target = Players:FindFirstChild(e.Name) and Players[e.Name].Character
            if not target then notify("Track: karakter yok."); return end
            trackInstance(target)
        end)
        mk("Inspect", function() showInspector(e, "Player: "..(e.DisplayName or e.Name)) end)
    end
end

local function renderWorkspace()
    clearChildren(secWorkspace)
    local W=ScanResults.Workspace or {Tools={},Prompts={},ClickDetectors={},Remotes={}}
    local groups = {
        {"Tools", W.Tools},
        {"ProximityPrompts", W.Prompts},
        {"ClickDetectors", W.ClickDetectors},
        {"RemoteObjects", W.Remotes},
    }
    for _,pair in ipairs(groups) do
        local title, list = pair[1], pair[2]
        if list and #list>0 then
            for _,e in ipairs(list) do
                local subt = ("%s   |   %s"):format(e.Class or "-", e.Path or "-")
                local row, mk = miniRow(secWorkspace, e.Name or "-", subt)
                mk("Ping", function()
                    local inst = game:GetService("Workspace"):FindFirstChild(e.Name, true)
                    if not inst then
                        -- path üzerinden bulmayı dene
                        pcall(function()
                            local cur=workspace
                            for seg in string.gmatch(e.Path or "", "[^/]+") do
                                cur = (cur and cur:FindFirstChild(seg)) or nil
                            end
                            inst=cur
                        end)
                    end
                    if inst then pingInstance(inst, e.Name) else notify("Nesne bulunamadı.") end
                end)
                mk("Track", function()
                    local inst = game:GetService("Workspace"):FindFirstChild(e.Name, true)
                    if inst then trackInstance(inst) else notify("Nesne bulunamadı.") end
                end)
                mk("Inspect", function() showInspector(e, "Workspace: "..(e.Name or "-")) end)
            end
        end
    end
end

local function renderBackpack()
    clearChildren(secBackpack)
    for _,e in ipairs(ScanResults.Backpack or {}) do
        local subt = ("%s   |   Children: %d   |   Path: %s"):format(e.Handle and "Has Handle" or "No Handle", e.ChildrenCount or 0, e.Path or "-")
        local row, mk = miniRow(secBackpack, e.Name or "-", subt)
        mk("Ping", function()
            local inst = LP:FindFirstChild("Backpack") and LP.Backpack:FindFirstChild(e.Name)
            if inst then pingInstance(inst, e.Name) else notify("Backpack objesi bulunamadı.") end
        end)
        mk("Inspect", function() showInspector(e, "Backpack: "..(e.Name or "-")) end)
    end
end

local function renderAll()
    statStrip.Text = ("Players: %d | Workspace: %d (T:%d P:%d C:%d R:%d) | Backpack: %d"):format(
        #(ScanResults.Players or {}),
        ((ScanResults.Workspace and ((ScanResults.Workspace.Tools and #ScanResults.Workspace.Tools or 0) + (ScanResults.Workspace.Prompts and #ScanResults.Workspace.Prompts or 0) + (ScanResults.Workspace.ClickDetectors and #ScanResults.Workspace.ClickDetectors or 0) + (ScanResults.Workspace.Remotes and #ScanResults.Workspace.Remotes or 0))) or 0),
        (ScanResults.Workspace and ScanResults.Workspace.Tools and #ScanResults.Workspace.Tools or 0),
        (ScanResults.Workspace and ScanResults.Workspace.Prompts and #ScanResults.Workspace.Prompts or 0),
        (ScanResults.Workspace and ScanResults.Workspace.ClickDetectors and #ScanResults.Workspace.ClickDetectors or 0),
        (ScanResults.Workspace and ScanResults.Workspace.Remotes and #ScanResults.Workspace.Remotes or 0),
        #(ScanResults.Backpack or {})
    )
    if ScannerState.SectionFilter=="All" or ScannerState.SectionFilter=="Players" then renderPlayers() else clearChildren(secPlayers) end
    if ScannerState.SectionFilter=="All" or ScannerState.SectionFilter=="Workspace" then renderWorkspace() else clearChildren(secWorkspace) end
    if ScannerState.SectionFilter=="All" or ScannerState.SectionFilter=="Backpack" then renderBackpack() else clearChildren(secBackpack) end
end

-- İlk tarama + auto refresh döngüsü
runScan(); renderAll()
local accum=0
RunService.RenderStepped:Connect(function(dt)
    if not ScannerState.AutoRefresh then return end
    accum+=dt
    if accum>=ScannerState.Interval then
        accum=0
        runScan()
        renderAll()
    end
end)

-- Manuel refresh (search/filtre değişince)
searchBox.FocusLost:Connect(function()
    runScan()
    renderAll()
end)

-- Tema güncellenince Scanner boyaması otomatik (setThemeByName zaten repaint ediyor)

-- bitti.
