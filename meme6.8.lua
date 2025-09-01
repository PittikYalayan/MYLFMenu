--[[ 
    ⚡ MYLF | Linoria+ — mylf.txt (rev3: AIM/ESP sayfaları eklendi)
    - Menü yapısı: Features / AIM / ESP / Player / Visuals / HUD / Scanner / Settings
    - Crown FPS Panel: FPS | Ping | CPU | GPU  + tema-accent stroke + rainbow alt çizgi
    - Scanner: Kategori + Search + Type Filter + Auto Refresh + Highlight + Focus Camera + Copy Path + Sound Play/Stop
    - Keybind: Menü gizleme tuşu Settings ve TitleBar'da bağlanabilir
    - Global Aç/Kapa: varsayılan LeftShift (değiştirilebilir)
    - Client-safe (UI/HUD/Scanner); exploit/hook içermez
]]

--// Services
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera    = Workspace.CurrentCamera
local Players    = game:GetService("Players")
local Player     = Players.LocalPlayer

local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local HttpService        = game:GetService("HttpService")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local SoundService       = game:GetService("SoundService")
local CollectionService  = game:GetService("CollectionService")
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
local function getFullPath(i) local ok,res=pcall(function() return i:GetFullName() end); return ok and res or "[path?]" end
local function findAnyBasePart(obj)
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") and obj.PrimaryPart then return obj.PrimaryPart end
    local ok,desc = pcall(function() return obj:GetDescendants() end); if not ok then return nil end
    for _,d in ipairs(desc) do if d:IsA("BasePart") then return d end end
    return nil
end

--== EXTERNAL FEATURES (direct load) ==--
-- === FEATURES ===
local features   = loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features1.2.4.lua"))()


assert(type(features)=="table","[MYLF] features1.1.5.lua tablo döndürmedi, en sona 'return M' ekle!")

-- === Direct Feature Binder ===
local function bindFeatureToggle(group, key, label, fnName)
    local opt = group:AddToggle(key, { Text = label, Default = false })
    opt:OnChanged(function(on)
        local fn = features[fnName]
        if type(fn) == "function" then
            fn(on)  -- 🔥 direkt çağır
            print("[MYLF] "..fnName.." çağırıldı -> "..tostring(on))
        else
            warn("[MYLF] "..fnName.." bulunamadı (toggle: "..label..")")
        end
    end)
    return opt
end



--// Theme Engine (aynen korundu)
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
local ThemeRegistry = {}
local function registerThemeUpdater(key, fn) ThemeRegistry[key] = fn end
local function applyTheme(name)
    if name then CurrentTheme = Themes[name] or CurrentTheme end
    for _,fn in pairs(ThemeRegistry) do pcall(fn, CurrentTheme) end
end

--// State
local State = { Visible=true, Dragging=false, GlobalToggleKey=Enum.KeyCode.LeftShift }

--// ROOT GUI (aynen)
local Gui = Instance.new("ScreenGui")
Gui.Name="MYLF_LinoriaPlus"
Gui.IgnoreGuiInset=true
Gui.ResetOnSpawn=false
Gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
Gui.Parent=PlayerGui

-- Notifications (aynen)
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
    t.Parent=NotifLayer; makeCorner(t,6); local st=makeStroke(t,1,.1); st.Color = CurrentTheme.Stroke
    local size=tween(t,.16,{Size=UDim2.new(0, math.clamp(t.TextBounds.X+22,160,520),0,28)}); size:Play()
    task.delay(dur,function() local tw=tween(t,.16,{Position=UDim2.new(1,-10,0,-34), BackgroundTransparency=1}); tw.Completed:Connect(function() t:Destroy() end); tw:Play() end)
end

--== WINDOW ==--
local Window = Instance.new("Frame")
Window.Name="Window"; Window.Size=UDim2.new(0, 860, 0, 540); Window.Position=UDim2.new(0.5,-430,0.5,-270)
Window.Active=true; Window.Parent=Gui
local winStroke = makeStroke(Window,1,.2); makeCorner(Window,10)
registerThemeUpdater("Window", function(th) Window.BackgroundColor3 = th.Bg; winStroke.Color = th.Stroke end)

-- TitleBar + Theme + Bind (aynen)
local TitleBar = Instance.new("Frame"); TitleBar.Name="TitleBar"; TitleBar.Size=UDim2.new(1,0,0,44); TitleBar.Parent=Window
local tbStroke = makeStroke(TitleBar,1,.1); makeCorner(TitleBar,10)
local Title = Instance.new("TextLabel"); Title.BackgroundTransparency=1; Title.Text="⚡ MYLF | Linoria+"
Title.Font=Enum.Font.GothamBold; Title.TextSize=16; Title.TextXAlignment=Enum.TextXAlignment.Left
Title.Size=UDim2.new(1,-260,1,0); Title.Position=UDim2.new(0,14,0,0); Title.Parent=TitleBar
local ThemeBtn = Instance.new("TextButton"); ThemeBtn.Text="Theme: Dark"; ThemeBtn.AutoButtonColor=false
ThemeBtn.Font=Enum.Font.GothamSemibold; ThemeBtn.TextSize=13; ThemeBtn.AnchorPoint=Vector2.new(1,0.5)
ThemeBtn.Position=UDim2.new(1,-180,0.5,0); ThemeBtn.Size=UDim2.new(0,160,0,26); ThemeBtn.Parent=TitleBar
local BindBtn = Instance.new("TextButton"); BindBtn.Text="Bind: LeftShift"; BindBtn.AutoButtonColor=false
BindBtn.Font=Enum.Font.GothamSemibold; BindBtn.TextSize=13; BindBtn.AnchorPoint=Vector2.new(1,0.5)
BindBtn.Position=UDim2.new(1,-10,0.5,0); BindBtn.Size=UDim2.new(0,150,0,26); BindBtn.Parent=TitleBar
local tbtnStroke = makeStroke(ThemeBtn,1,.15); local bindStroke = makeStroke(BindBtn,1,.15); makeCorner(ThemeBtn,6); makeCorner(BindBtn,6)
registerThemeUpdater("TitleBar", function(th)
    TitleBar.BackgroundColor3 = th.Panel; tbStroke.Color = th.Stroke
    Title.TextColor3 = th.Text
    ThemeBtn.TextColor3 = th.Text; ThemeBtn.BackgroundColor3 = th.Hover; tbtnStroke.Color = th.Stroke
    BindBtn.TextColor3  = th.Text; BindBtn.BackgroundColor3  = th.Hover; bindStroke.Color = th.Stroke
end)

-- Drag only TitleBar (aynen)
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

-- Sidebar (aynen)
local Sidebar = Instance.new("Frame")
Sidebar.Position=UDim2.new(0,10,0,58); Sidebar.Size=UDim2.new(0,190,1,-68); Sidebar.Parent=Window
local sbStroke = makeStroke(Sidebar,1,.08); makeCorner(Sidebar,8); pad(Sidebar,8)
local SideList = Instance.new("UIListLayout", Sidebar); SideList.Padding=UDim.new(0,8)
registerThemeUpdater("Sidebar", function(th) Sidebar.BackgroundColor3 = th.Panel; sbStroke.Color = th.Stroke end)

local function makeTabButton(text, icon)
    local b=Instance.new("TextButton"); b.AutoButtonColor=false; b.Text=(icon and (icon.."  ") or "")..text
    b.Font=Enum.Font.GothamSemibold; b.TextSize=14; b.Size=UDim2.new(1,-4,0,34); b.Parent=Sidebar
    local st = makeStroke(b,1,.2); makeCorner(b,6)
    b.MouseEnter:Connect(function() tween(b,.08,{BackgroundColor3=CurrentTheme.AccentSoft}):Play() end)
    b.MouseLeave:Connect(function() tween(b,.12,{BackgroundColor3=CurrentTheme.Hover}):Play() end)
    registerThemeUpdater("btn_"..text, function(th) b.TextColor3 = th.Text; b.BackgroundColor3 = th.Hover; st.Color = th.Stroke end)
    return b
end

-- Content (aynen)
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

-- Controls (aynen)
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
    registerThemeUpdater("toggle_"..label, function(th) btn.TextColor3 = default and th.Green or th.Red; btn.BackgroundColor3 = th.Hover; bst.Color = th.Stroke end)
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
    registerThemeUpdater("slider_"..label, function(th) frame.BackgroundColor3=th.Hover; fst.Color=th.Stroke; fill.BackgroundColor3=th.Accent; valText.TextColor3=th.Text end)
    local dragging=false; local value=default or min
    local function setFromX(x)
        local rel=math.clamp((x-frame.AbsolutePosition.X)/frame.AbsoluteSize.X,0,1)
        value = round(min + (max-min)*rel, 2); fill.Size=UDim2.new((value-min)/(max-min),0,1,0); valText.Text=(fmt or "%d"):format(value)
        if callback then callback(value) end
    end
    frame.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; setFromX(input.Position.X) end end)
    frame.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then setFromX(input.Position.X) end end)
    return {Set=function(v) value=math.clamp(v,min,max); fill.Size=UDim2.new((value-min)/(max-min),0,1,0); valText.Text=(fmt or "%d"):format(value); if callback then callback(value) end end, Get=function() return value end}
end
function Controls.Dropdown(parent,label,items,defaultIdx,callback)
    local row,lab=makeRow(parent,label)
    local btn=Instance.new("TextButton"); btn.AutoButtonColor=false; btn.Font=Enum.Font.GothamSemibold; btn.TextSize=12
    btn.Size=UDim2.new(0,160,0,24); btn.Position=UDim2.new(1,-170,0.5,-12); btn.Parent=row
    local bst = makeStroke(btn,1,.15); makeCorner(btn,6)
    local idx=defaultIdx or 1; btn.Text=items[idx] or "-"
    local listFrame=Instance.new("Frame"); listFrame.Visible=false; listFrame.Size=UDim2.new(0,160,0, math.min(6,#items)*24+10)
    listFrame.AnchorPoint=Vector2.new(0,0); listFrame.Position=UDim2.new(1,-170,0.5,14); listFrame.Parent=row; local lst = makeStroke(listFrame,1,.15); makeCorner(listFrame,6); pad(listFrame,6)
    registerThemeUpdater("dropdown_"..label, function(th) btn.TextColor3=th.Text; btn.BackgroundColor3=th.Hover; bst.Color=th.Stroke; listFrame.BackgroundColor3=th.Panel; lst.Color=th.Stroke end)
    local ul=Instance.new("UIListLayout", listFrame); ul.Padding=UDim.new(0,6)
    for i,v in ipairs(items) do
        local it=Instance.new("TextButton"); it.AutoButtonColor=false; it.Font=Enum.Font.Gotham; it.TextSize=12; it.Text=v
        it.Size=UDim2.new(1,0,0,24); it.Parent=listFrame; local ist = makeStroke(it,1,.0); makeCorner(it,6)
        registerThemeUpdater("dropdown_item_"..label.."_"..tostring(i), function(th) it.TextColor3=th.Text; it.BackgroundColor3=th.Hover; ist.Color=th.Stroke end)
        it.MouseEnter:Connect(function() tween(it,.08,{BackgroundColor3=CurrentTheme.AccentSoft}):Play() end)
        it.MouseLeave:Connect(function() tween(it,.12,{BackgroundColor3=CurrentTheme.Hover}):Play() end)
        it.MouseButton1Click:Connect(function() idx=i; btn.Text=v; listFrame.Visible=false; if callback then callback(v,i) end end)
    end
    btn.MouseButton1Click:Connect(function() listFrame.Visible=not listFrame.Visible end)
    return {SetIndex=function(i) if items[i] then idx=i; btn.Text=items[i]; if callback then callback(items[i],i) end end end, GetIndex=function() return idx end, GetValue=function() return items[idx] end}
end
function Controls.Button(parent,label,callback)
    local row,lab=makeRow(parent,label)
    lab.Size=UDim2.new(0.55,0,1,0); lab.Text=label
    local btn=Instance.new("TextButton"); btn.AutoButtonColor=false; btn.Text="Run"; btn.Font=Enum.Font.GothamSemibold; btn.TextSize=12
    btn.Size=UDim2.new(0,80,0,24); btn.Position=UDim2.new(1,-88,0.5,-12); btn.Parent=row
    local bst=makeStroke(btn,1,.15); makeCorner(btn,6)
    registerThemeUpdater("button_"..label, function(th) btn.TextColor3=th.Text; btn.BackgroundColor3=th.Hover; bst.Color=th.Stroke end)
    btn.MouseButton1Click:Connect(function() if callback then callback() end end)
    return btn
end
function Controls.Keybind(parent,label,initialKey, onChanged)
    local row,_ = makeRow(parent,label)
    local btn=Instance.new("TextButton"); btn.AutoButtonColor=false; btn.Text=tostring(initialKey and initialKey.Name or "None"); btn.Font=Enum.Font.GothamSemibold; btn.TextSize=12
    btn.Size=UDim2.new(0,120,0,24); btn.Position=UDim2.new(1,-128,0.5,-12); btn.Parent=row
    local bst=makeStroke(btn,1,.15); makeCorner(btn,6)
    registerThemeUpdater("keybind_"..label, function(th) btn.TextColor3=th.Text; btn.BackgroundColor3=th.Hover; bst.Color=th.Stroke end)
    btn.MouseButton1Click:Connect(function()
        btn.Text = "Press..."
        local listening = true
        local conn; conn = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                listening = false
                btn.Text = input.KeyCode.Name
                if onChanged then onChanged(input.KeyCode) end
                if conn then conn:Disconnect() end
            end
        end)
        task.delay(5, function() if listening and conn then conn:Disconnect(); btn.Text = tostring(initialKey and initialKey.Name or "None") end end)
    end)
    return {Set=function(k) btn.Text=(k and k.Name) or "None" end}
end

--== OVERLAY (Crosshair + Crown HUD) ==--
local Overlay=Instance.new("ScreenGui"); Overlay.Name="MYLF_HUD"; Overlay.IgnoreGuiInset=true; Overlay.ResetOnSpawn=false; Overlay.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; Overlay.Parent=PlayerGui

-- CROSSHAIR
local Crosshair=Instance.new("Frame"); Crosshair.Name="Crosshair"; Crosshair.AnchorPoint=Vector2.new(.5,.5); Crosshair.Position=UDim2.fromScale(.5,.5)
Crosshair.Size=UDim2.fromOffset(2,2); Crosshair.BackgroundTransparency=1; Crosshair.Visible=true; Crosshair.Parent=Overlay
local arms={} for i=1,4 do local a=Instance.new("Frame"); a.BorderSizePixel=0; a.Parent=Crosshair; arms[i]=a end
local CrosshairCfg={Enabled=true, Gap=6, Length=8, Thickness=2, Opacity=1, Color=Themes.Dark.Accent}
local function layoutCrosshair()
    for _,a in ipairs(arms) do a.BackgroundTransparency=1-CrosshairCfg.Opacity; a.BackgroundColor3=CrosshairCfg.Color end
    arms[1].Size=UDim2.fromOffset(CrosshairCfg.Thickness, CrosshairCfg.Length); arms[1].Position=UDim2.fromOffset(-CrosshairCfg.Thickness/2, -(CrosshairCfg.Gap+CrosshairCfg.Length))
    arms[2].Size=UDim2.fromOffset(CrosshairCfg.Thickness, CrosshairCfg.Length); arms[2].Position=UDim2.fromOffset(-CrosshairCfg.Thickness/2,  CrosshairCfg.Gap)
    arms[3].Size=UDim2.fromOffset(CrosshairCfg.Length, CrosshairCfg.Thickness); arms[3].Position=UDim2.fromOffset(-(CrosshairCfg.Gap+CrosshairCfg.Length),-CrosshairCfg.Thickness/2)
    arms[4].Size=UDim2.fromOffset(CrosshairCfg.Length, CrosshairCfg.Thickness); arms[4].Position=UDim2.fromOffset( CrosshairCfg.Gap, -CrosshairCfg.Thickness/2)
    Crosshair.Visible=CrosshairCfg.Enabled
end
layoutCrosshair()

-- CROWN HUD
local CrownPanel=Instance.new("Frame"); CrownPanel.AnchorPoint=Vector2.new(.5,0); CrownPanel.Position=UDim2.new(.5,0,0,8); CrownPanel.Size=UDim2.fromOffset(300,26)
CrownPanel.Parent=Overlay; pad(CrownPanel,4); local cps = makeStroke(CrownPanel,1,.15); makeCorner(CrownPanel,8)
local CrownText=Instance.new("TextLabel"); CrownText.BackgroundTransparency=1; CrownText.Font=Enum.Font.GothamSemibold; CrownText.TextSize=12; CrownText.TextXAlignment=Enum.TextXAlignment.Center
CrownText.Size=UDim2.new(1,-10,1,-8); CrownText.Position=UDim2.fromOffset(5,0); CrownText.Parent=CrownPanel
local RainbowBar=Instance.new("Frame"); RainbowBar.BorderSizePixel=0; RainbowBar.AnchorPoint=Vector2.new(.5,1); RainbowBar.Position=UDim2.new(.5,0,1,0); RainbowBar.Size=UDim2.new(1,-6,0,3); RainbowBar.Parent=CrownPanel; makeCorner(RainbowBar,2)
local grad=Instance.new("UIGradient", RainbowBar)
registerThemeUpdater("Crown", function(th) CrownPanel.BackgroundColor3 = th.Panel; cps.Color = th.Accent; CrownText.TextColor3 = th.Text; CrosshairCfg.Color = th.Accent; layoutCrosshair() end)
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
        local ping = "?"
        pcall(function()
            local it = Stats.Network.ServerStatsItem["Data Ping"]
            if it then ping = tostring(it:GetValueString()):gsub(" RTT","") end
        end)
        CrownText.Text=("FPS: %s | Ping: %s | CPU: %s ms | GPU: %s ms"):format(fps, ping, round(hbAvg*1000,1), round(rsAvg*1000,1))
        local need=CrownText.TextBounds.X + 40; CrownPanel.Size=UDim2.fromOffset(math.clamp(need, 260, 680), 26)
    end
end)

--== PAGES ==--

local pAim      = newPage("AIM")     -- ✅ yeni
local pESP      = newPage("ESP")     -- ✅ yeni
local pPlayer   = newPage("Player")
local pTeleport = newPage("Teleport") 
local pCam      = newPage("CameraTP") 
local pEmotes   = newPage("Emotes")
local pScanner  = newPage("Scanner")
local pVisuals  = newPage("Visuals")
local pHUD      = newPage("HUD")
local pFeatures = newPage("Features")
local pSettings = newPage("Settings")


local tAim      = makeTabButton("AimBot","👑")
local tESPBtn   = makeTabButton("ESP","👁")
local tPlayer   = makeTabButton("Player","🧍")
local tTeleport = makeTabButton("TeleP","🔥")
local tCam      = makeTabButton("C View","🌀")
local tEmotes   = makeTabButton("Emotes","🏴‍☠️")
local tScanner  = makeTabButton("Scanner","🔮")
local tVisuals  = makeTabButton("CrossH","🕹")
local tHUD      = makeTabButton("MenuHud","🛰")
local tFeatures = makeTabButton("Features","💥")
local tSettings = makeTabButton("Settings","⚙️")

local function showPage(name) for k,f in pairs(Pages) do f.Visible=(k==name) end end
showPage("Features")

tAim.MouseButton1Click:Connect(function() showPage("AIM") end)
tESPBtn.MouseButton1Click:Connect(function() showPage("ESP") end)
tPlayer.MouseButton1Click:Connect(function() showPage("Player") end)
tTeleport.MouseButton1Click:Connect(function() showPage("Teleport") end)
tCam.MouseButton1Click:Connect(function() showPage("CameraTP") end)
tEmotes.MouseButton1Click:Connect(function() showPage("Emotes") end)
tScanner.MouseButton1Click:Connect(function() showPage("Scanner") end)
tVisuals.MouseButton1Click:Connect(function() showPage("Visuals") end)
tHUD.MouseButton1Click:Connect(function() showPage("HUD") end)
tFeatures.MouseButton1Click:Connect(function() showPage("Features") end)
tSettings.MouseButton1Click:Connect(function() showPage("Settings") end)

--== FEATURES (artık sadece HUD/Quick + bağlama şimi) ==--
do
    local left  = newSection(pFeatures, "HUD / Overlay")
    local right = newSection(pFeatures, "? - Person")

    Controls.Toggle(left, "Crown FPS Panel", true, function(on) CrownPanel.Visible = on end)
    Controls.Toggle(left, "Crosshair", true, function(on) Crosshair.Visible = on end)
-----------------------------------

   

    -------------------------
    Controls.Button(left, "Notify Snapshot", function()
        local okPing = "?"
        pcall(function()
            local it = Stats.Network.ServerStatsItem["Data Ping"]
            if it then okPing = tostring(it:GetValueString()):gsub(" RTT","") end
        end)
        notify(("Ping %s | FOV %d"):format(okPing, round(Camera.FieldOfView,0)), 2.0)
    end)
end

-- Helper: Linoria-Compat Shim (tekrar kullanılacak)
local Options = _G.MYLF_Options or {}; _G.MYLF_Options = Options
local function makeGroup(targetSection)
    local group = {}
    function group:AddToggle(key, cfg)
        local default = (cfg and cfg.Default) or false
        local text    = (cfg and cfg.Text) or key
        local opt = { Value = default }
        function opt:OnChanged(cb) self._cb = cb end
        Controls.Toggle(targetSection, text, default, function(v)
            opt.Value = v
            if opt._cb then pcall(opt._cb, v) end
        end)
        Options[key] = opt
        return opt
    end
    function group:AddSlider(key, cfg)
        local text    = (cfg and cfg.Text) or key
        local min     = (cfg and cfg.Min) or 0
        local max     = (cfg and cfg.Max) or 100
        local default = (cfg and cfg.Default) or min
        local rounding= (cfg and cfg.Rounding) or 0
        local fmt = ("%%0.%df"):format(math.max(0, rounding))
        local opt = { Value = default }
        function opt:OnChanged(cb) self._cb = cb end
        Controls.Slider(targetSection, text, min, max, default, fmt, function(v)
            opt.Value = v
            if opt._cb then pcall(opt._cb, v) end
        end)
        Options[key] = opt
        return opt
    end
    return group
end
local function bindToggle(group, key, label, featureFn)
    local opt = group:AddToggle(key, {Text = label, Default = false})
    opt:OnChanged(function(on) try(featureFn, on) end)
    return opt
end

--== AIM (kategori) ==--
do
    local left  = newSection(pAim, "Targeting")
    local right = newSection(pAim, "Parameters")

    local g      = makeGroup(left)
    local gRight = makeGroup(right)

    -- Bağlantılar
 

    -- Parametreler
    features._aimFOV = tonumber(features._aimFOV) or 60
    gRight:AddSlider("aimFOV", {Text="Aim FOV", Min=10, Max=180, Default=features._aimFOV, Rounding=0})
    Options.aimFOV:OnChanged(function(v)
        features._aimFOV = v
        try(features.SetAimFOV, v)
    end)
     Controls.Toggle(left, "Enable Aimbot", false, function(on)
        if features.ToggleAimbot then features.ToggleAimbot(on) end
    end)

    Controls.Toggle(left, "Silent Aim", false, function(on)
        if features.ToggleSilentAim then features.ToggleSilentAim(on) end
    end)

    Controls.Toggle(left, "Magic Bullet (Fallback)", false, function(on)
        if features.ToggleMagicBullet then features.ToggleMagicBullet(on) end
    end)

    Controls.Toggle(left, "Force Headshot", false, function(on)
        if features.ToggleHeadshotRedirect then features.ToggleHeadshotRedirect(on) end
    end)

    Controls.Toggle(left, "Hard Fire Rate", false, function(on)
        if features.ToggleFireRate then features.ToggleFireRate(on) end
    end)

    Controls.Toggle(left, "☠️ Kill Aura", false, function(on)
        if features.ToggleKillAura then features.ToggleKillAura(on) end
    end)
    

    -- Hızlı aksiyonlar (AIM ile alakalı kısayollar istersen buraya eklenir)
end

--== ESP (kategori) ==--
do
    local left  = newSection(pESP, "ESP Core")
    local right = newSection(pESP, "Hitbox / Visual Extras")

    local g      = makeGroup(left)
    local gRight = makeGroup(right)

-- ESP Sekmesi içinde
Controls.Toggle(left, "🦴 Skeleton", false, function(on)
    if features.ToggleSkeleton then features.ToggleSkeleton(on) end
end)

Controls.Toggle(left, "📦 3D Box", false, function(on)
    if features.ToggleBox then features.ToggleBox(on)  end
end)

Controls.Toggle(left, "🌈 Rainbow Name", false, function(on)
    if features.ToggleRainbowName then features.ToggleRainbowName(on) end
end)

Controls.Toggle(left, "✨ Rainbow Glow", false, function(on)
    if features.ToggleGlow then features.ToggleGlow(on) end
end)

Controls.Toggle(left, "〽 Tracers", false, function(on)
    if features.ToggleTracers then features.ToggleTracers(on) end
end)

    Controls.Toggle(right, "🎯 Enemy Big Hitbox", false, function(on)
        if features.ToggleEnemyBigHitbox then features.ToggleEnemyBigHitbox(on) end
    end)

end

--== PLAYER ==--
do
    local left  = newSection(pPlayer, "Movement / Toggles")
    local right = newSection(pPlayer, "Waypoints")

    -- Player hareket ve utility (özellikler direkt bağlandı)
    local g = makeGroup(left)
    local gright = makeGroup(right)
    

    -- Kamera/FOV bu sayfadan da erişilebilir istersen (Visuals'ta da var)
Controls.Toggle(left, "⚡ Speed Boost (50)", false, function(on)
        if features.ToggleSpeed then features.ToggleSpeed(on) end
    end)

    Controls.Toggle(left, "🕊️ Fly (LCtrl down)", false, function(on)
        if features.ToggleFly then features.ToggleFly(on) end
    end)

    Controls.Toggle(left, "Infinite Jump", false, function(on)
        if features.ToggleInfiniteJump then features.ToggleInfiniteJump(on) end
    end)

    Controls.Toggle(left, "💀 Godmode", false, function(on)
        if features.ToggleGodmode then features.ToggleGodmode(on) end
    end)

    Controls.Toggle(left, "👻 Hard Invisible", false, function(on)
        if features.ToggleHardInvisible then features.ToggleHardInvisible(on) end
    end)

    Controls.Toggle(left, "NoClip", false, function(on)
        if features.ToggleNoclip then features.ToggleNoclip(on) end
    end)

   

    gright:AddSlider("walkSpeed", {Text="Walk Speed", Min=1, Max=200, Default=features._walkSpeed, Rounding=0})
    Options.walkSpeed:OnChanged(function(val) features.SetWalkSpeed(val) end)

    gright:AddSlider("flySpeed", {Text="Fly Speed", Min=1, Max=200, Default=features._flySpeed, Rounding=0})
    Options.flySpeed:OnChanged(function(val) features.SetFlySpeed(val) end)



  
    -- Varsayılan







   


    -- Waypoints
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

    Controls.Button(right, "Add Waypoint", function()
        local char = LP.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then local nm = "WP-"..string.sub(HttpService:GenerateGUID(false),1,4); createWaypoint(nm, hrp.Position + Vector3.new(0,3,0)); notify("Waypoint eklendi: "..nm) else notify("Karakter bulunamadı.", 2.0) end
    end)
    Controls.Button(right, "Clear Waypoints", function() clearWaypoints(); notify("Tüm waypoint'ler silindi.") end)
end

--.-=Teleport=-.--
do 

    -- pTeleport sayfasında 2 bölüm
   local left   = newSection(pTeleport, "Teleport ")
   local right  = newSection(pTeleport, "Values")
    
   local g      = makeGroup(left)
   local gRight = makeGroup(right)


    Controls.Toggle(left, "Teleport (T Key)", false, function(on) if features.ToggleTeleport then features.ToggleTeleport(on) end end)

    Controls.Toggle(left, "⚡ Always Behind Enemy", false, function(on)  if features.ToggleAutoBehind then features.ToggleAutoBehind(on) end end)

    Controls.Toggle(left, "⚡ Auto Farm Enemy", false, function(on) if features.ToggleAutoTeleportToEnemy then features.ToggleAutoTeleportToEnemy(on) end end)

        
    
    features._tpX = tonumber(features._tpX) or 0
    features._tpY = tonumber(features._tpY) or 0
    features._tpZ = tonumber(features._tpZ) or 25
    
    gRight:AddSlider("tpX", {Text="X Offset", Min=-50, Max=50, Default= tonumber((features and features._tpX) or 0) or 0, Rounding=0})
    gRight:AddSlider("tpY", {Text="Y Offset", Min=-50, Max=50, Default= tonumber((features and features._tpY) or 0) or 0, Rounding=0})
    gRight:AddSlider("tpZ", {Text="Z Offset", Min=1, Max=100, Default= tonumber((features and features._tpZ) or 25) or 25, Rounding=0})
    Options.tpX:OnChanged(function(val) if features then features._tpX = val end try(features and features.SetTeleportOffset, val, (features and features._tpY) or 0, (features and features._tpZ) or 25) end)
    Options.tpY:OnChanged(function(val)  if features then features._tpY = val end  try(features and features.SetTeleportOffset, (features and features._tpX) or 0, val, (features and features._tpZ) or 25) end)
    Options.tpZ:OnChanged(function(val) if features then features._tpZ = val end try(features and features.SetTeleportOffset, (features and features._tpX) or 0, (features and features._tpY) or 0, val) end)

end


--== CAMERA VIEW ==--
do
     local left  = newSection(pCam, "PlayerCam")
    local right = newSection(pCam, "TP Controls")

    local g      = makeGroup(left)
    local gRight = makeGroup(right)

    local selectedPlayer = nil
    local camActive      = false
    local rainbowLabels  = {}
    local btnRecords     = {}   -- { [plr]= {btn=..., stroke=...} }
    local selectedBtn    = nil

    -- Scrollable list (Scanner tarzı)
    local playerList = Instance.new("ScrollingFrame")
    playerList.Size = UDim2.new(1,0,1,-0)
    playerList.Parent = left
    playerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    playerList.ScrollBarThickness = 6
    local listLayout = Instance.new("UIListLayout", playerList)
    listLayout.Padding = UDim.new(0,4)

    -- tek yerden boyayan helper (theme ile uyumlu)
    local function paintBtn(th, btn, stroke, isSelected)
        if not btn or not btn.Parent then return end
        btn.BackgroundColor3 = isSelected and th.AccentSoft or th.Hover
        if stroke then stroke.Color = th.Stroke end
        -- not: TextColor3'e dokunmuyoruz (rainbow akacak)
    end

    local function reapplyThemeForList()
        for _,rec in pairs(btnRecords) do
            paintBtn(CurrentTheme, rec.btn, rec.stroke, rec.btn == selectedBtn)
        end
    end

    local function goToSelectedIfActive()
        if not camActive then return end
        if selectedPlayer and selectedPlayer.Character then
            local hum = selectedPlayer.Character:FindFirstChildOfClass("Humanoid")
            local hrp = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp then
                Camera.CameraSubject = hum
                Camera.CFrame = CFrame.new(hrp.Position + Vector3.new(0,5,-10), hrp.Position)
            end
        end
    end

    local function refreshPlayers()
        -- temizle
        for _,child in ipairs(playerList:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        rainbowLabels = {}
        btnRecords    = {}
        selectedBtn   = nil  -- liste tazelendi, seçim görseli sıfırlansın

        -- yeniden doldur
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1,0,0,24)
                btn.Text = "👤 "..plr.Name
                btn.Font = Enum.Font.GothamSemibold
                btn.TextSize = 12
                btn.AutoButtonColor = false
                btn.Parent = playerList
                makeCorner(btn,6)
                local st = makeStroke(btn,1,.1)

                -- rainbow ismi için kaydet
                table.insert(rainbowLabels, btn)
                btnRecords[plr] = { btn = btn, stroke = st }

                -- theme updater: sadece BG + stroke (yazıya dokunma)
                local key = "camlist_bg_"..tostring(plr.UserId)
                registerThemeUpdater(key, function(th)
                    paintBtn(th, btn, st, btn == selectedBtn)
                end)

                -- click -> seç, highlightla, kamera aktifse hemen git
                btn.MouseButton1Click:Connect(function()
                    selectedPlayer = plr
                    selectedBtn    = btn
                    notify("Seçildi: "..plr.Name)
                    reapplyThemeForList()   -- highlight anında güncellensin
                    goToSelectedIfActive()  -- Camera View ON ise anında geç
                end)
            end
        end

        -- liste ilk kez boyansın
        reapplyThemeForList()
    end

    refreshPlayers()
    Players.PlayerAdded:Connect(refreshPlayers)
    Players.PlayerRemoving:Connect(refreshPlayers)

    -- Rainbow akışı (sadece yazı rengi)
    RunService.RenderStepped:Connect(function()
        local t = tick() * 0.35
        for i, lbl in ipairs(rainbowLabels) do
            if lbl and lbl.Parent then
                lbl.TextColor3 = Color3.fromHSV((t + i * 0.08) % 1, 1, 1)
            end
        end
    end)

    -- Camera View toggle (açıkken seçim değişirse direkt yeni hedefe gider)
    Controls.Toggle(right, "🎥 Camera View", false, function(on)
        camActive = on
        if on then
            if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChildOfClass("Humanoid") then
                goToSelectedIfActive()
                notify("Camera kilitlendi: "..selectedPlayer.Name)
            else
                notify("Player seçilmedi, listeden seç.")
            end
        else
            local myHum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if myHum then
                Camera.CameraSubject = myHum
            end
            notify("Camera eski haline döndü.")
        end
    end)
    
end



-- == EMOTES PAGE ==
do
    local left  = newSection(pEmotes,"Categories")
    local right = newSection(pEmotes,"Animations")
    
    local gLeft  = makeGroup(left)
    local gRight = makeGroup(right)

       local activeDropdown = nil

    local EmotePacks = {
        ["🎭 Default R15"] = {
            {"Idle",507766666},{"Walk",507777826},{"Run",507767714},
            {"Jump",507765000},{"Fall",507767968},{"Climb",507765644},
            {"Sit",507768133},{"Wave",507770239},{"Point",507770818},
            {"Laugh",507770453},{"Cheer",507770677},
            {"Dance1",507771019},{"Dance2",507776043},{"Dance3",507777268}
        },
        ["🧟 Zombie Pack"] = {
            {"Walk",616168032},{"Idle",616158929},{"Jump",616161997},
            {"Fall",616157476},{"Run",616163682}
        },
        ["🥷 Ninja Pack"] = {
            {"Run",913376220},{"Jump",656117878},{"Idle",656118852},
            {"Fall",656115606},{"Climb",656114359}
        },
        ["🧓 Elder Pack"] = {
            {"Idle",845397899},{"Walk",845403856},{"Run",845386501},
            {"Jump",845398858},{"Fall",845396048}
        },
        ["🧛 Vampire Pack"] = {
            {"Idle",1083445855},{"Walk",1083473930},{"Run",1083462077},
            {"Jump",1083455352},{"Fall",1083443587}
        },
        ["🚀 Astronaut Pack"] = {
            {"Idle",891621366},{"Walk",891636393},{"Run",891636393},
            {"Jump",891627522},{"Fall",891617961}
        },
        ["🏴‍☠️ Pirate Pack"] = {
            {"Idle",750781874},{"Walk",750785693},{"Run",750783738},
            {"Jump",750782230},{"Fall",750779899}
        }
    }

    -- her kategori için ayrı toggle
    for packName, anims in pairs(EmotePacks) do
        Controls.Toggle(gLeft, packName, false, function(on)
            if on then
                -- önce varsa eski dropdown’u kaldır
                if activeDropdown then
                    activeDropdown.Visible = false
                end

                -- yeni dropdown yarat
                local animNames = {}
                for _,a in ipairs(anims) do
                    table.insert(animNames, a[1])
                end

                local dropdown = Controls.Dropdown(gRight, "Choose Animation", animNames, 1, function(selected)
                    for _,a in ipairs(anims) do
                        if a[1] == selected then
                            if game.ReplicatedStorage:FindFirstChild("PlayEmote") then
                                game.ReplicatedStorage.PlayEmote:FireServer(a[2])
                            else
                                local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                                if hum then
                                    local anim = Instance.new("Animation")
                                    anim.AnimationId = "rbxassetid://"..a[2]
                                    local track = hum:LoadAnimation(anim)
                                    track:Play()
                                end
                            end
                        end
                    end
                end)

                dropdown.Visible = true
                activeDropdown = dropdown
            else
                if activeDropdown then
                    activeDropdown.Visible = false
                    activeDropdown = nil
                end
            end
        end)
    end
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

    Controls.Dropdown(right, "Theme", {"Dark","Midnight","Neon","Black","Red"}, 1, function(v) ThemeBtn.Text = "Theme: "..v; applyTheme(v) end)
end

--== HUD ==--
do
    local left  = newSection(pHUD, "Performance")
    local right = newSection(pHUD, "Toggles")

    Controls.Toggle(right, "Show FPS/Ping/CPU/GPU", true, function(on) CrownPanel.Visible = on end)
    CrownPanel.Visible = true

    Controls.Button(left, "Notify Perf Snapshot", function()
        local okPing = "?"
        pcall(function()
            local it = Stats.Network.ServerStatsItem["Data Ping"]
            if it then okPing = tostring(it:GetValueString()):gsub(" RTT","") end
        end)
        notify(("FPS? | Ping %s | FOV %d"):format(okPing, round(Camera.FieldOfView,0)), 2.2)
    end)
end

--== SCANNER (gelişmiş) ==--
do
    local left   = newSection(pScanner, "Categories")
    local middle = newSection(pScanner, "Results")
    local right  = newSection(pScanner, "Details")

    -- Search + Type Filter + Auto Refresh
    local searchRow = Instance.new("Frame"); searchRow.BackgroundTransparency=1; searchRow.Size=UDim2.new(1,0,0,28); searchRow.Parent=left
    local searchBox = Instance.new("TextBox"); searchBox.PlaceholderText="Search by name..."; searchBox.Font=Enum.Font.Gotham; searchBox.TextSize=12; searchBox.ClearTextOnFocus=false
    searchBox.Size=UDim2.new(1,-190,1,0); searchBox.Parent=searchRow
    local sst = makeStroke(searchBox,1,.15); makeCorner(searchBox,6)
    local refreshBtn = Instance.new("TextButton"); refreshBtn.AutoButtonColor=false; refreshBtn.Text="Refresh"; refreshBtn.Font=Enum.Font.GothamSemibold; refreshBtn.TextSize=12
    refreshBtn.Size=UDim2.new(0,80,1,0); refreshBtn.Position=UDim2.new(1,-180,0,0); refreshBtn.Parent=searchRow
    local rbst=makeStroke(refreshBtn,1,.15); makeCorner(refreshBtn,6)
    local autoToggle = Instance.new("TextButton"); autoToggle.AutoButtonColor=false; autoToggle.Text="Auto: OFF"; autoToggle.Font=Enum.Font.GothamSemibold; autoToggle.TextSize=12
    autoToggle.Size=UDim2.new(0,90,1,0); autoToggle.Position=UDim2.new(1,-90,0,0); autoToggle.Parent=searchRow
    local abst=makeStroke(autoToggle,1,.15); makeCorner(autoToggle,6)
    local autoOn=false; local autoLoop=nil

    registerThemeUpdater("scanner_search", function(th)
        searchBox.TextColor3=th.Text; searchBox.PlaceholderColor3=th.SubText; searchBox.BackgroundColor3=th.Hover; sst.Color=th.Stroke
        refreshBtn.BackgroundColor3=th.Hover; refreshBtn.TextColor3=th.Text; rbst.Color=th.Stroke
        autoToggle.BackgroundColor3=th.Hover; autoToggle.TextColor3=th.Text; abst.Color=th.Stroke
    end)

    local filterRow = Instance.new("Frame"); filterRow.BackgroundTransparency=1; filterRow.Size=UDim2.new(1,0,0,28); filterRow.Parent=left
    local typeFilter = "All"
    local dd = Controls.Dropdown(filterRow, "Type Filter", {"All","Remote","Tool","NPC(Humanoid)","ProximityPrompt","ClickDetector","Sound","BillboardGui","Part","Model","Camera","UI(TextLabel)","Accessory","MeshPart"}, 1, function(v) typeFilter = v end)

    -- Category buttons
    local catList = {"Players","NPCs","Workspace","Remotes","Proximity","ClickDetectors","Sounds","PlayerGui","StarterGui","Lighting","Teams","Accessories"}
    local catFrame = Instance.new("Frame"); catFrame.BackgroundTransparency=1; catFrame.Size=UDim2.new(1,0,1,-64); catFrame.Position=UDim2.new(0,0,0,64); catFrame.Parent=left
    local catLayout = Instance.new("UIListLayout", catFrame); catLayout.Padding=UDim.new(0,6)
    local currentCat = "Players"
    local catButtons = {}
    local function makeCat(text)
        local b=Instance.new("TextButton"); b.AutoButtonColor=false; b.Text=text; b.Font=Enum.Font.GothamSemibold; b.TextSize=12; b.Size=UDim2.new(1,0,0,24); b.Parent=catFrame
        local bst=makeStroke(b,1,.15); makeCorner(b,6)
        registerThemeUpdater("scanner_cat_"..text, function(th) b.TextColor3=th.Text; b.BackgroundColor3 = (currentCat==text) and th.AccentSoft or th.Hover; bst.Color=th.Stroke end)
        b.MouseButton1Click:Connect(function() currentCat=text; for n,btn in pairs(catButtons) do applyTheme() end; end)
        catButtons[text]=b
    end
    for _,c in ipairs(catList) do makeCat(c) end

    -- Results listbox
    local results = Instance.new("ScrollingFrame"); results.CanvasSize=UDim2.new(0,0,0,0); results.ScrollBarThickness=6
    results.Size=UDim2.new(1,0,1,-0); results.Parent=middle; results.AutomaticCanvasSize=Enum.AutomaticSize.Y
    local rlst = Instance.new("UIListLayout", results); rlst.Padding=UDim.new(0,4)
    local rst = makeStroke(results,1,.08); makeCorner(results,6); pad(results,6)
    registerThemeUpdater("scanner_results", function(th) results.BackgroundColor3=th.Hover; results.ScrollBarImageColor3=th.Accent; rst.Color=th.Stroke end)

    -- Right details helpers
    local function clearRight()
        for _,v in ipairs(right:GetChildren()) do if v:IsA("Frame") or v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("ScrollingFrame") or v:IsA("TextButton") then v:Destroy() end end
    end
    local function labelRight(text, size)
        local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Font=Enum.Font.Gotham; l.TextSize=size or 12; l.TextXAlignment=Enum.TextXAlignment.Left; l.TextYAlignment=Enum.TextYAlignment.Top; l.TextWrapped=true
        l.Size=UDim2.new(1,0,0, math.max(24, size==14 and 20 or 18)); l.Parent=right; registerThemeUpdater("scanner_rlabel_"..HttpService:GenerateGUID(false), function(th) l.TextColor3=th.SubText end); l.Text=text; return l
    end
    local function buttonRight(text, cb)
        local b=Instance.new("TextButton"); b.AutoButtonColor=false; b.Text=text; b.Font=Enum.Font.GothamSemibold; b.TextSize=12; b.Size=UDim2.new(0,120,0,24); b.Parent=right
        local bst=makeStroke(b,1,.15); makeCorner(b,6); registerThemeUpdater("scanner_rbtn_"..text, function(th) b.TextColor3=th.Text; b.BackgroundColor3=th.Hover; bst.Color=th.Stroke end)
        b.MouseButton1Click:Connect(function() if cb then cb() end end); return b
    end

    -- Selection highlight
    local SelHL = Instance.new("Highlight"); SelHL.Enabled=false; SelHL.FillTransparency=1; SelHL.OutlineColor = CurrentTheme.Accent; SelHL.Parent = Overlay
    registerThemeUpdater("scanner_selhl", function(th) SelHL.OutlineColor = th.Accent end)
    local limitMax = 1200

    local function isTypeAllowed(obj, filter)
        if filter=="All" then return true end
        if filter=="Remote" then return obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") end
        if filter=="Tool" then return obj:IsA("Tool") end
        if filter=="NPC(Humanoid)" then return (obj:IsA("Model") or obj:IsA("Folder")) and (obj:FindFirstChildOfClass("Humanoid") ~= nil) end
        if filter=="ProximityPrompt" then return obj:IsA("ProximityPrompt") end
        if filter=="ClickDetector" then return obj:IsA("ClickDetector") end
        if filter=="Sound" then return obj:IsA("Sound") end
        if filter=="BillboardGui" then return obj:IsA("BillboardGui") end
        if filter=="Part" then return obj:IsA("BasePart") end
        if filter=="Model" then return obj:IsA("Model") end
        if filter=="Camera" then return obj:IsA("Camera") end
        if filter=="UI(TextLabel)" then return obj:IsA("TextLabel") end
        if filter=="Accessory" then return obj:IsA("Accessory") end
        if filter=="MeshPart" then return obj:IsA("MeshPart") end
        return true
    end

    local function addResultLine(text, ref)
        local row=Instance.new("TextButton"); row.AutoButtonColor=false; row.TextXAlignment=Enum.TextXAlignment.Left
        row.Font=Enum.Font.Gotham; row.TextSize=12; row.Size=UDim2.new(1,0,0,24); row.Text="  "..text; row.Parent=results
        local r_st=makeStroke(row,1,.0); makeCorner(row,6)
        registerThemeUpdater("scanner_row_"..text, function(th) row.TextColor3=th.Text; row.BackgroundColor3=th.Panel; r_st.Color=th.Stroke end)
        row.MouseButton1Click:Connect(function()
            clearRight()
            local head = Instance.new("TextLabel"); head.BackgroundTransparency=1; head.Font=Enum.Font.GothamBold; head.TextSize=14; head.Text="Details"; head.Size=UDim2.new(1,0,0,20); head.Parent=right
            registerThemeUpdater("scanner_details_head", function(th) head.TextColor3=th.Text end)

            local tags = {}
            local okTags, tagList = pcall(function() return CollectionService:GetTags(ref) end)
            if okTags and tagList then tags = tagList end
            local attrCount = 0; local attrsStr=""
            local okAttr, attrs = pcall(function() return ref:GetAttributes() end)
            if okAttr and attrs then for k,v in pairs(attrs) do attrCount += 1; attrsStr = attrsStr..tostring(k)..": "..tostring(v).."\n" end end

            labelRight("Name: "..tostring(ref.Name), 12)
            labelRight("Class: "..tostring(ref.ClassName), 12)
            labelRight("Path: "..getFullPath(ref), 12)
            labelRight("Tags: "..( (#tags>0) and table.concat(tags,", ") or "-" ), 12)
            labelRight("Attributes ("..attrCount.."):\n"..(attrsStr ~= "" and attrsStr or "-"), 12)

            local bp = findAnyBasePart(ref)
            buttonRight("Highlight", function() if bp or ref:IsA("Model") then SelHL.Adornee = ref; SelHL.Enabled=true else SelHL.Enabled=false end end)
            buttonRight("Unhighlight", function() SelHL.Enabled=false end)
            if bp then
                buttonRight("Focus Camera", function()
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, bp.Position)
                    notify("Camera focused.")
                end)
            end
            if ref:IsA("Sound") then
                buttonRight("Play", function() ref:Play() end)
                buttonRight("Stop", function() ref:Stop() end)
            end

            local copyBox = Instance.new("TextBox"); copyBox.ClearTextOnFocus=false; copyBox.TextEditable=true; copyBox.Text=getFullPath(ref)
            copyBox.Size=UDim2.new(1,0,0,26); copyBox.Parent=right; makeCorner(copyBox,6); local cbst=makeStroke(copyBox,1,.1)
            registerThemeUpdater("scanner_copybox", function(th) copyBox.TextColor3=th.Text; copyBox.BackgroundColor3=th.Hover; cbst.Color=th.Stroke end)
        end)
    end

    local function iterateCategory(cat, query)
        for _,v in ipairs(results:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        local shown=0
        local function tryPush(obj, tag)
            if shown>=limitMax then return end
            if query and query~="" then
                if not string.find(string.lower(obj.Name), string.lower(query), 1, true) then return end
            end
            if not isTypeAllowed(obj, typeFilter) then return end
            addResultLine((tag and (tag.." | ") or "")..obj.Name, obj); shown+=1
        end

        if cat=="Players" then
            for _,plr in ipairs(Players:GetPlayers()) do
                tryPush(plr, "Player")
                if plr.Backpack then for _,tool in ipairs(plr.Backpack:GetChildren()) do tryPush(tool, "Tool") end end
                local char = plr.Character; if char then tryPush(char, "Character") end
            end
        elseif cat=="NPCs" then
            local desc = workspace:GetDescendants()
            for _,d in ipairs(desc) do local hum = d:IsA("Model") and d:FindFirstChildOfClass("Humanoid"); if hum then tryPush(d, "NPC") end end
        elseif cat=="Workspace" then
            for _,child in ipairs(workspace:GetChildren()) do tryPush(child, "WS") end
        elseif cat=="Remotes" then
            local searchSpaces = {ReplicatedStorage, workspace}
            for _,space in ipairs(searchSpaces) do
                local desc = space:GetDescendants()
                for _,d in ipairs(desc) do if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then tryPush(d, "Remote") end end
            end
        elseif cat=="Proximity" then
            for _,d in ipairs(workspace:GetDescendants()) do if d:IsA("ProximityPrompt") then tryPush(d, "Prompt") end end
        elseif cat=="ClickDetectors" then
            for _,d in ipairs(workspace:GetDescendants()) do if d:IsA("ClickDetector") then tryPush(d, "Click") end end
        elseif cat=="Sounds" then
            for _,d in ipairs(SoundService:GetDescendants()) do if d:IsA("Sound") then tryPush(d, "SoundService") end end
            for _,d in ipairs(workspace:GetDescendants()) do if d:IsA("Sound") then tryPush(d, "WS") end end
        elseif cat=="PlayerGui" then
            for _,d in ipairs(LP:WaitForChild("PlayerGui"):GetDescendants()) do
                if d:IsA("TextLabel") or d:IsA("ImageLabel") or d:IsA("BillboardGui") then tryPush(d, "UI") end
            end
        elseif cat=="StarterGui" then
            local sg = game:GetService("StarterGui")
            for _,d in ipairs(sg:GetDescendants()) do
                if d:IsA("TextLabel") or d:IsA("ImageLabel") or d:IsA("BillboardGui") then tryPush(d, "UI") end
            end
        elseif cat=="Lighting" then
            for _,d in ipairs(game:GetService("Lighting"):GetChildren()) do tryPush(d, "Light") end
        elseif cat=="Teams" then
            for _,d in ipairs(game:GetService("Teams"):GetChildren()) do tryPush(d, "Team") end
        elseif cat=="Accessories" then
            for _,d in ipairs(workspace:GetDescendants()) do if d:IsA("Accessory") then tryPush(d, "Acc") end end
        else
            for _,child in ipairs(workspace:GetChildren()) do tryPush(child, cat) end
        end
        addResultLine(("— %d item(s) —"):format(shown), right)
    end

    local function refresh() iterateCategory(currentCat, searchBox.Text) end
    refreshBtn.MouseButton1Click:Connect(refresh)
    searchBox:GetPropertyChangedSignal("Text"):Connect(function() refresh() end)
    autoToggle.MouseButton1Click:Connect(function()
        autoOn = not autoOn
        autoToggle.Text = "Auto: "..(autoOn and "ON" or "OFF")
        if autoOn then
            task.spawn(function()
                while autoOn do refresh(); task.wait(1.5) end
            end)
        end
    end)
    refresh()
end

--== SETTINGS ==--
do
    local left  = newSection(pSettings, "Menu / Keys")
    local right = newSection(pSettings, "About")

    local kb = Controls.Keybind(left, "Menu Toggle Key", State.GlobalToggleKey, function(newKey)
        State.GlobalToggleKey = newKey
        BindBtn.Text = "Bind: "..newKey.Name
        notify("Menu key -> "..newKey.Name)
    end)

    local about = Instance.new("TextLabel"); about.BackgroundTransparency=1; about.TextWrapped=true
    about.Font=Enum.Font.Gotham; about.TextSize=12; about.TextXAlignment=Enum.TextXAlignment.Left; about.TextYAlignment=Enum.TextYAlignment.Top
    about.Size=UDim2.new(1,0,1,-0); about.Parent=right
    registerThemeUpdater("about", function(th) about.TextColor3=th.SubText end)
    about.Text = "MYLF Linoria+ — client-safe UI/HUD/Scanner.\nCrown stroke tema renklerine bağlı, altta rainbow bar.\nBuild: mylf.txt rev3 (AIM/ESP pages)."
end

-- Global menu toggle (aynen)
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode == State.GlobalToggleKey then
        Window.Visible = not Window.Visible
    end
end)

-- TitleBar: Theme cycler + Keybind capture (aynen)
local themeList = {"Dark","Midnight","Neon","Black","Red"}
local themeIdx=1
ThemeBtn.MouseButton1Click:Connect(function()
    themeIdx = themeIdx % #themeList + 1
    ThemeBtn.Text = "Theme: "..themeList[themeIdx]
    applyTheme(themeList[themeIdx])
end)
BindBtn.MouseButton1Click:Connect(function()
    BindBtn.Text = "Bind: ..."
    local listening = true
    local conn; conn = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            State.GlobalToggleKey = input.KeyCode
            BindBtn.Text = "Bind: "..input.KeyCode.Name
            notify("Menu key -> "..input.KeyCode.Name)
            if conn then conn:Disconnect() end
        end
    end)
    task.delay(5, function() if listening and conn then conn:Disconnect(); BindBtn.Text="Bind: "..(State.GlobalToggleKey and State.GlobalToggleKey.Name or "None") end end)
end)

-- İlk boyama
applyTheme("Dark")
