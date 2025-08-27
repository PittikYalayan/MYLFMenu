--[[ 
    ⚡ MYLF | Linoria+ — mylf.txt (rev3)
    - Menü yapısı: Features / Player / Visuals / HUD / Scanner / Settings
    - Crown FPS Panel + Crosshair + Scanner
    - External features: features9.8.lua
]]

--// Services
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

--== EXTERNAL FEATURES ==--
local features = nil
local function try(fn, ...)
    if type(fn) == "function" then
        local ok, err = pcall(fn, ...)
        if not ok then warn("[features] "..tostring(err)) end
    end
end
do
    local ok, mod = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features9.8.lua"))()
    end)
    if ok and type(mod) == "table" then
        features = mod
        warn("[MYLF] features9.8.lua loaded.")
    else
        warn("[MYLF] features9.8.lua FAILED: "..tostring(mod))
    end
end
--== THEME ENGINE ==--
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

--== STATE ==--
local State = { Visible=true, Dragging=false, GlobalToggleKey=Enum.KeyCode.LeftShift }

--== ROOT GUI ==--
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

-- TitleBar
local TitleBar = Instance.new("Frame")
TitleBar.Name="TitleBar"; TitleBar.Size=UDim2.new(1,0,0,44); TitleBar.Parent=Window
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

-- Drag logic
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
registerThemeUpdater("Sidebar", function(th) Sidebar.BackgroundColor3 = th.Panel; sbStroke.Color = th.Stroke end)

-- Tab buttons + Content
local Pages = {}
local function newPage(name)
    local p=Instance.new("Frame"); p.Visible=false; p.Size=UDim2.new(1,0,1,0); p.Parent=Window
    local pst = makeStroke(p,1,.08); makeCorner(p,8); pad(p,10)
    local list = Instance.new("UIListLayout", p); list.Padding=UDim.new(0,10); list.FillDirection=Enum.FillDirection.Horizontal
    registerThemeUpdater("page_"..name, function(th) p.BackgroundColor3 = th.Panel; pst.Color = th.Stroke end)
    Pages[name]=p; return p
end

local Content = Instance.new("Frame")
Content.BackgroundTransparency=1; Content.Position=UDim2.new(0,210,0,58); Content.Size=UDim2.new(1,-220,1,-68); Content.Parent=Window
-- Controls
local Controls = {}

function Controls.Toggle(parent,text,default,cb)
    local b=Instance.new("TextButton")
    b.AutoButtonColor=false; b.Text=text; b.Font=Enum.Font.GothamSemibold; b.TextSize=13
    b.Size=UDim2.new(1,-4,0,28); b.Parent=parent
    local st=makeStroke(b,1,.2); makeCorner(b,6)
    registerThemeUpdater("toggle_"..text,function(th)
        b.BackgroundColor3=th.Hover; b.TextColor3=th.Text; st.Color=th.Stroke
    end)
    local state=default or false
    local function update() b.Text=((state and "☑ ") or "☐ ")..text end
    update()
    b.MouseButton1Click:Connect(function()
        state=not state; update()
        if cb then cb(state) end
    end)
end

function Controls.Slider(parent,text,min,max,default,fmt,cb)
    local fr=Instance.new("Frame"); fr.Size=UDim2.new(1,-4,0,40); fr.Parent=parent; makeCorner(fr,6)
    local lb=Instance.new("TextLabel"); lb.BackgroundTransparency=1; lb.Text=text.." ("..string.format(fmt,default)..")"
    lb.Font=Enum.Font.GothamSemibold; lb.TextSize=13; lb.Size=UDim2.new(1,-10,0,20); lb.Position=UDim2.new(0,5,0,0); lb.Parent=fr
    local sl=Instance.new("TextButton"); sl.AutoButtonColor=false; sl.Size=UDim2.new(1,-10,0,12); sl.Position=UDim2.new(0,5,0,22); sl.Parent=fr
    local fill=Instance.new("Frame",sl); fill.BorderSizePixel=0; fill.Size=UDim2.new((default-min)/(max-min),0,1,0)
    local st=makeStroke(sl,1,.2); makeCorner(sl,6); makeCorner(fill,6)
    registerThemeUpdater("slider_"..text,function(th) fr.BackgroundColor3=th.Bg; lb.TextColor3=th.Text; sl.BackgroundColor3=th.Hover; fill.BackgroundColor3=th.Accent; st.Color=th.Stroke end)
    local val=default
    local function setv(v) v=clamp(v,min,max); val=v; lb.Text=text.." ("..string.format(fmt,v)..")"; fill.Size=UDim2.new((v-min)/(max-min),0,1,0); if cb then cb(v) end end
    setv(default)
    sl.MouseButton1Down:Connect(function(x,y)
        local con; con=RunService.RenderStepped:Connect(function()
            local mx=UserInputService:GetMouseLocation().X
            local percent=clamp((mx-sl.AbsolutePosition.X)/sl.AbsoluteSize.X,0,1)
            setv(min+(max-min)*percent)
        end)
        UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then con:Disconnect() end end)
    end)
end

function Controls.Button(parent,text,cb)
    local b=Instance.new("TextButton"); b.AutoButtonColor=false; b.Text=text
    b.Font=Enum.Font.GothamSemibold; b.TextSize=13; b.Size=UDim2.new(1,-4,0,28); b.Parent=parent
    local st=makeStroke(b,1,.2); makeCorner(b,6)
    registerThemeUpdater("btn_"..text,function(th) b.BackgroundColor3=th.Hover; b.TextColor3=th.Text; st.Color=th.Stroke end)
    b.MouseButton1Click:Connect(function() if cb then cb() end end)
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
grad.Color=ColorSequence.new{
    ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),
    ColorSequenceKeypoint.new(.16,Color3.fromRGB(255,255,0)),
    ColorSequenceKeypoint.new(.33,Color3.fromRGB(0,255,0)),
    ColorSequenceKeypoint.new(.5,Color3.fromRGB(0,255,255)),
    ColorSequenceKeypoint.new(.66,Color3.fromRGB(0,0,255)),
    ColorSequenceKeypoint.new(.83,Color3.fromRGB(255,0,255)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0))}
grad.Rotation=0
grad.Offset=Vector2.new(0,0)
grad.Transparency=NumberSequence.new(0)
grad.Enabled=true
grad.Name="RainbowGradient"
--== THEME AFFECTING HUD ==--
registerThemeUpdater("Crown", function(th)
    CrownPanel.BackgroundColor3 = th.Panel
    cps.Color = th.Accent
    CrownText.TextColor3 = th.Text
    CrosshairCfg.Color = th.Accent
    layoutCrosshair()
end)

--== PAGES ==--
local pFeatures = newPage("Features")
local pPlayer   = newPage("Player")
local pVisuals  = newPage("Visuals")
local pHUD      = newPage("HUD")
local pScanner  = newPage("Scanner")
local pSettings = newPage("Settings")

local function makeTab(name,icon)
    local b=Instance.new("TextButton"); b.AutoButtonColor=false; b.Text=(icon and (icon.."  ") or "")..name
    b.Font=Enum.Font.GothamSemibold; b.TextSize=14; b.Size=UDim2.new(1,-4,0,34); b.Parent=Sidebar
    local st=makeStroke(b,1,.2); makeCorner(b,6)
    registerThemeUpdater("tab_"..name,function(th) b.TextColor3=th.Text; b.BackgroundColor3=th.Hover; st.Color=th.Stroke end)
    b.MouseButton1Click:Connect(function()
        for k,f in pairs(Pages) do f.Visible=false end
        Pages[name].Visible=true
    end)
end

makeTab("Features","🛠")
makeTab("Player","👤")
makeTab("Visuals","🎨")
makeTab("HUD","📊")
makeTab("Scanner","🔍")
makeTab("Settings","⚙️")

Pages["Features"].Visible=true

--== SECTIONS ==--
local function newSection(parent,title)
    local s=Instance.new("Frame"); s.Size=UDim2.new(0.5,-8,1,0); s.Parent=parent
    local st=makeStroke(s,1,.08); makeCorner(s,8); pad(s,10)
    local t=Instance.new("TextLabel"); t.BackgroundTransparency=1; t.Text=title; t.Font=Enum.Font.GothamBold; t.TextSize=14; t.Size=UDim2.new(1,0,0,18); t.Parent=s
    registerThemeUpdater("section_"..title,function(th) s.BackgroundColor3=th.Bg; st.Color=th.Stroke; t.TextColor3=th.Text end)
    local l=Instance.new("UIListLayout",s); l.Padding=UDim.new(0,8)
    return s
end

--== FEATURES ==--
do
    local left  = newSection(pFeatures, "Combat / Visuals")
    local right = newSection(pFeatures, "Movement / Teleport")

    -- Linoria-style options container
    local Options = _G.MYLF_Options or {}
    _G.MYLF_Options = Options

    local function makeGroup(targetSection)
        local group = {}
        function group:AddToggle(key,cfg)
            local default=(cfg and cfg.Default) or false
            local text=(cfg and cfg.Text) or key
            local opt={Value=default}
            function opt:OnChanged(cb) self._cb=cb end
            Controls.Toggle(targetSection,text,default,function(v)
                opt.Value=v; if opt._cb then pcall(opt._cb,v) end
            end)
            Options[key]=opt; return opt
        end
        function group:AddSlider(key,cfg)
            local text=(cfg and cfg.Text) or key
            local min=(cfg and cfg.Min) or 0
            local max=(cfg and cfg.Max) or 100
            local default=(cfg and cfg.Default) or min
            local rounding=(cfg and cfg.Rounding) or 0
            local fmt=("%%0.%df"):format(math.max(0,rounding))
            local opt={Value=default}
            function opt:OnChanged(cb) self._cb=cb end
            Controls.Slider(targetSection,text,min,max,default,fmt,function(v)
                opt.Value=v; if opt._cb then pcall(opt._cb,v) end
            end)
            Options[key]=opt; return opt
        end
        return group
    end

    local function bindToggle(group,key,label,featureFn)
        local opt=group:AddToggle(key,{Text=label,Default=false})
        opt:OnChanged(function(on) try(featureFn,on) end)
        return opt
    end

    local gCombat = makeGroup(left)
    local gMove   = makeGroup(right)

    -- 🎯 AIM / COMBAT
    bindToggle(gCombat,"aimbot","Enable Aimbot",features and features.ToggleAimbot)
    bindToggle(gCombat,"headshotRedirect","Force Headshot",features and features.ToggleHeadshotRedirect)
    bindToggle(gCombat,"fireRate","Hard Fire Rate",features and features.ToggleFireRate)
    bindToggle(gCombat,"silent","Silent Aim",features and features.ToggleSilentAim)
    bindToggle(gCombat,"magic","Magic Bullet (Fallback)",features and features.ToggleMagicBullet)
    bindToggle(gCombat,"killAura","☠️ Kill Aura",features and features.ToggleKillAura)

    -- 👁 VISUALS
    bindToggle(gCombat,"esp","Enable ESP",features and features.ToggleESP)
    bindToggle(gCombat,"enemyBigHB","🎯 Enemy Big Hitbox",features and features.ToggleEnemyBigHitbox)

    -- 🏃 MOVEMENT
    bindToggle(gMove,"speed","Speed Boost (50)",features and features.ToggleSpeed)
    bindToggle(gMove,"fly","Fly (LCtrl down)",features and features.ToggleFly)
    bindToggle(gMove,"infjump","Infinite Jump",features and features.ToggleInfiniteJump)
    bindToggle(gMove,"godmode","💀 Godmode",features and features.ToggleGodmode)
    bindToggle(gMove,"hardInvis","👻 Hard Invisible",features and features.ToggleHardInvisible)
    bindToggle(gMove,"noclip","NoClip",features and features.ToggleNoclip)

    -- 🌀 TELEPORT
    bindToggle(gMove,"tpkey","Teleport (T Key)",features and features.ToggleTeleport)
    bindToggle(gMove,"autoBehind","⚡ Always Behind Enemy",features and features.ToggleAutoBehind)
    bindToggle(gMove,"autoTP","⚡ Auto Farm Enemy",features and features.ToggleAutoTeleportToEnemy)

    -- 📐 TELEPORT OFFSETS
    gMove:AddSlider("tpX",{Text="X Offset",Min=-50,Max=50,Default=tonumber((features and features._tpX) or 0) or 0,Rounding=0})
    gMove:AddSlider("tpY",{Text="Y Offset",Min=-50,Max=50,Default=tonumber((features and features._tpY) or 0) or 0,Rounding=0})
    gMove:AddSlider("tpZ",{Text="Z Offset",Min=1,Max=100,Default=tonumber((features and features._tpZ) or 25) or 25,Rounding=0})

    Options.tpX:OnChanged(function(val)
        if features then features._tpX=val end
        try(features and features.SetTeleportOffset,val,(features and features._tpY) or 0,(features and features._tpZ) or 25)
    end)
    Options.tpY:OnChanged(function(val)
        if features then features._tpY=val end
        try(features and features.SetTeleportOffset,(features and features._tpX) or 0,val,(features and features._tpZ) or 25)
    end)
    Options.tpZ:OnChanged(function(val)
        if features then features._tpZ=val end
        try(features and features.SetTeleportOffset,(features and features._tpX) or 0,(features and features._tpY) or 0,val)
    end)
end
--== PLAYER ==--
do
    local left = newSection(pPlayer,"Movement")
    Controls.Slider(left,"Walkspeed",0,100,16,"%d",function(v)
        pcall(function() LP.Character.Humanoid.WalkSpeed=v end)
    end)
    Controls.Slider(left,"JumpPower",0,200,50,"%d",function(v)
        pcall(function() LP.Character.Humanoid.JumpPower=v end)
    end)
    Controls.Toggle(left,"Infinite Jump",false,function(on)
        if features then features.ToggleInfiniteJump(on) end
    end)
    Controls.Toggle(left,"Fly (Ctrl)",false,function(on)
        if features then features.ToggleFly(on) end
    end)
end

--== VISUALS ==--
do
    local left = newSection(pVisuals,"Crosshair")
    Controls.Slider(left,"Gap",0,20,6,"%d",function(v)
        CrosshairCfg.Gap=v; layoutCrosshair()
    end)
    Controls.Slider(left,"Length",0,20,8,"%d",function(v)
        CrosshairCfg.Length=v; layoutCrosshair()
    end)
    Controls.Slider(left,"Thickness",1,5,2,"%d",function(v)
        CrosshairCfg.Thickness=v; layoutCrosshair()
    end)
    Controls.Slider(left,"Opacity",0,1,1,"%.2f",function(v)
        CrosshairCfg.Opacity=v; layoutCrosshair()
    end)

    local right = newSection(pVisuals,"Theme")
    Controls.Button(right,"Dark Theme",function() applyTheme("Dark") end)
    Controls.Button(right,"Midnight Theme",function() applyTheme("Midnight") end)
    Controls.Button(right,"Neon Theme",function() applyTheme("Neon") end)
    Controls.Button(right,"Black Theme",function() applyTheme("Black") end)
    Controls.Button(right,"Red Theme",function() applyTheme("Red") end)
end

--== HUD ==--
do
    local left = newSection(pHUD,"FPS / Ping")
    Controls.Toggle(left,"Show Crown Panel",true,function(on)
        CrownPanel.Visible=on
    end)
    Controls.Toggle(left,"Show Crosshair",true,function(on)
        Crosshair.Visible=on
    end)

    local right = newSection(pHUD,"Notifications")
    Controls.Button(right,"Test Notify",function()
        notify("This is a test notification!")
    end)
end
--== SCANNER ==--
do
    local left = newSection(pScanner,"Objects")
    Controls.Button(left,"Refresh",function()
        notify("Scanner refreshed.")
    end)

    local right = newSection(pScanner,"Auto")
    Controls.Toggle(right,"Auto Refresh",false,function(on)
        notify("AutoRefresh: "..tostring(on))
    end)
end

--== SETTINGS ==--
do
    local left = newSection(pSettings,"Menu")
    Controls.Button(left,"Rejoin",function()
        game:GetService("TeleportService"):Teleport(game.PlaceId,LP)
    end)
    Controls.Button(left,"Copy Discord",function()
        setclipboard("https://discord.gg/mylf")
        notify("Discord link copied to clipboard!")
    end)
end

--== GLOBAL MENU TOGGLE ==--
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode == State.GlobalToggleKey then
        Window.Visible = not Window.Visible
    end
end)

--== TITLEBAR BUTTONS ==--
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
    local conn; conn = UserInputService.InputBegan:Connect(function(input,gp)
        if gp then return end
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            State.GlobalToggleKey = input.KeyCode
            BindBtn.Text = "Bind: "..input.KeyCode.Name
            notify("Menu key -> "..input.KeyCode.Name)
            if conn then conn:Disconnect() end
        end
    end)
    task.delay(5,function()
        if listening and conn then conn:Disconnect()
            BindBtn.Text="Bind: "..(State.GlobalToggleKey and State.GlobalToggleKey.Name or "None")
        end
    end)
end)

--== APPLY THEME ON START ==--
applyTheme("Dark")
