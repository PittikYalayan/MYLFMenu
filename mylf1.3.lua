--[[ 
    ⚡ MYLF Linoria+ Legit UI Framework (Client-Safe) ⚡
    - Tek LocalScript (PlayerGui).
    - Features9.8.lua bağlandı (toggle + slider doğrudan features fonksiyonlarına bağlı).
    - Sekmeler: Features, Player, Visuals, HUD, Scanner, Settings
    - Crosshair + FPS HUD + Waypoints + Theme
    - Aç/Kapa: LeftShift
]]

--// === Features ===
local features = {}
do
    local ok,mod = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features9.8.lua"))()
    end)
    features = ok and mod or {}
end

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

--// Utils
local function tween(o, ti, props) return TweenService:Create(o,TweenInfo.new(ti,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),props) end
local function clamp(n,a,b) if n<a then return a elseif n>b then return b else return n end end
local function round(n,p) local m=10^(p or 0); return math.floor(n*m+0.5)/m end
local function makeCorner(o,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=o; return c end
local function makeStroke(o,th,tr) local s=Instance.new("UIStroke"); s.Thickness=th or 1; s.Transparency=tr or 0; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=o; return s end
local function pad(o,px) local p=Instance.new("UIPadding"); p.PaddingTop=UDim.new(0,px); p.PaddingBottom=UDim.new(0,px); p.PaddingLeft=UDim.new(0,px); p.PaddingRight=UDim.new(0,px); p.Parent=o; return p end

--// Theme
local Themes = {
    Dark     ={Bg=Color3.fromRGB(20,20,26),Panel=Color3.fromRGB(28,28,36),Accent=Color3.fromRGB(120,115,245),Text=Color3.fromRGB(238,238,245),Hover=Color3.fromRGB(40,40,52)},
    Midnight ={Bg=Color3.fromRGB(12,14,24),Panel=Color3.fromRGB(18,20,34),Accent=Color3.fromRGB(80,180,255), Text=Color3.fromRGB(228,232,240),Hover=Color3.fromRGB(26,30,46)},
    Neon     ={Bg=Color3.fromRGB(18,18,22),Panel=Color3.fromRGB(22,22,28),Accent=Color3.fromRGB(255,80,200), Text=Color3.fromRGB(245,245,255),Hover=Color3.fromRGB(40,34,60)},
    Black    ={Bg=Color3.fromRGB(6,6,8),Panel=Color3.fromRGB(14,14,18),Accent=Color3.fromRGB(220,220,230),Text=Color3.fromRGB(240,240,245),Hover=Color3.fromRGB(24,24,30)},
    Red      ={Bg=Color3.fromRGB(24,8,10),Panel=Color3.fromRGB(32,10,12),Accent=Color3.fromRGB(230,66,80), Text=Color3.fromRGB(250,240,242),Hover=Color3.fromRGB(46,16,20)},
}
local CurrentTheme = Themes.Dark

--// State
local State={Visible=true,GlobalToggleKey=Enum.KeyCode.LeftShift,Binds={},BindListening=nil}

--// Root GUI
local Gui=Instance.new("ScreenGui"); Gui.Name="MYLF_UI"; Gui.IgnoreGuiInset=true; Gui.ResetOnSpawn=false; Gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; Gui.Parent=PlayerGui

-- Window
local Window=Instance.new("Frame"); Window.Size=UDim2.new(0,860,0,520); Window.Position=UDim2.new(.5,-430,.5,-260)
Window.BackgroundColor3=CurrentTheme.Bg; Window.Parent=Gui; Window.Active=true; makeCorner(Window,10); makeStroke(Window,1,.2)

-- TitleBar
local TitleBar=Instance.new("Frame"); TitleBar.Size=UDim2.new(1,0,0,44); TitleBar.BackgroundColor3=CurrentTheme.Panel; TitleBar.Parent=Window; makeCorner(TitleBar,10)
local Title=Instance.new("TextLabel"); Title.BackgroundTransparency=1; Title.Text="⚡ MYLF | Linoria+ UI"; Title.Font=Enum.Font.GothamBold; Title.TextSize=16
Title.TextColor3=CurrentTheme.Text; Title.TextXAlignment=Enum.TextXAlignment.Left; Title.Size=UDim2.new(1,-160,1,0); Title.Position=UDim2.new(0,14,0,0); Title.Parent=TitleBar

-- Drag only TitleBar
local dragStart,startPos
TitleBar.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragStart=input.Position; startPos=Window.Position end end)
UserInputService.InputChanged:Connect(function(input) if dragStart and input.UserInputType==Enum.UserInputType.MouseMovement then
    local d=input.Position-dragStart; Window.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y) end end)
TitleBar.InputEnded:Connect(function() dragStart=nil end)

-- Sidebar
local Sidebar=Instance.new("Frame"); Sidebar.Size=UDim2.new(0,180,1,-68); Sidebar.Position=UDim2.new(0,10,0,58); Sidebar.BackgroundColor3=CurrentTheme.Panel; Sidebar.Parent=Window
makeCorner(Sidebar,8); makeStroke(Sidebar,1,.08); pad(Sidebar,8)
local SideList=Instance.new("UIListLayout",Sidebar); SideList.Padding=UDim.new(0,8)

local function makeTabButton(txt,icon) local b=Instance.new("TextButton"); b.Text=(icon.."  "..txt); b.Font=Enum.Font.GothamSemibold; b.TextSize=14; b.TextColor3=CurrentTheme.Text
b.BackgroundColor3=CurrentTheme.Hover; b.Size=UDim2.new(1,-4,0,34); b.Parent=Sidebar; makeCorner(b,6); makeStroke(b,1,.2); return b end

-- Content
local Content=Instance.new("Frame"); Content.Size=UDim2.new(1,-200,1,-68); Content.Position=UDim2.new(0,200,0,58); Content.BackgroundTransparency=1; Content.Parent=Window

-- Pages
local Pages={}
local function newPage(name) local p=Instance.new("Frame"); p.Visible=false; p.Size=UDim2.new(1,0,1,0); p.BackgroundColor3=CurrentTheme.Panel; p.Parent=Content
makeCorner(p,8); makeStroke(p,1,.08); pad(p,10); Pages[name]=p; return p end

local pFeatures=newPage("Features")
local pPlayer=newPage("Player")
local pVisuals=newPage("Visuals")
local pHUD=newPage("HUD")
local pScanner=newPage("Scanner")
local pSettings=newPage("Settings")

-- Tabs
local tFeatures=makeTabButton("Features","🛠")
local tPlayer=makeTabButton("Player","👤")
local tVisuals=makeTabButton("Visuals","🎨")
local tHUD=makeTabButton("HUD","📊")
local tScanner=makeTabButton("Scanner","🔍")
local tSettings=makeTabButton("Settings","⚙️")

local function showPage(name) for k,f in pairs(Pages) do f.Visible=(k==name) end end
showPage("Features")
tFeatures.MouseButton1Click:Connect(function() showPage("Features") end)
tPlayer.MouseButton1Click:Connect(function() showPage("Player") end)
tVisuals.MouseButton1Click:Connect(function() showPage("Visuals") end)
tHUD.MouseButton1Click:Connect(function() showPage("HUD") end)
tScanner.MouseButton1Click:Connect(function() showPage("Scanner") end)
tSettings.MouseButton1Click:Connect(function() showPage("Settings") end)
--// Controls
local Controls={}

local function makeRow(parent,label)
    local f=Instance.new("Frame"); f.BackgroundTransparency=1; f.Size=UDim2.new(1,0,0,28); f.Parent=parent
    local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Text=label; l.Font=Enum.Font.Gotham; l.TextSize=13; l.TextXAlignment=Enum.TextXAlignment.Left
    l.TextColor3=CurrentTheme.Text; l.Size=UDim2.new(0.55,0,1,0); l.Parent=f
    return f,l
end

function Controls.Toggle(parent,label,default,callback)
    local row,lab=makeRow(parent,label)
    local btn=Instance.new("TextButton"); btn.AutoButtonColor=false; btn.Text=default and "ON" or "OFF"; btn.Font=Enum.Font.GothamBold; btn.TextSize=12
    btn.TextColor3=default and Color3.fromRGB(110,210,130) or Color3.fromRGB(230,90,96); btn.BackgroundColor3=CurrentTheme.Hover; btn.Size=UDim2.new(0,78,0,24)
    btn.Position=UDim2.new(1,-88,0.5,-12); btn.Parent=row; makeCorner(btn,6); makeStroke(btn,1,.2)
    local on=default
    btn.MouseButton1Click:Connect(function()
        on=not on; btn.Text=on and "ON" or "OFF"; btn.TextColor3=on and Color3.fromRGB(110,210,130) or Color3.fromRGB(230,90,96)
        tween(btn,.08,{BackgroundColor3=on and CurrentTheme.Accent or CurrentTheme.Hover}):Play()
        if callback then callback(on) end
    end)
    return {Set=function(v) on=v; btn.Text=v and "ON" or "OFF"; if callback then callback(v) end end, Get=function() return on end}
end

function Controls.Slider(parent,label,min,max,default,fmt,callback)
    local row,lab=makeRow(parent,label)
    local frame=Instance.new("Frame"); frame.Size=UDim2.new(0.38,0,0,24); frame.Position=UDim2.new(0.62,0,0.5,-12); frame.BackgroundColor3=CurrentTheme.Hover; frame.Parent=row
    makeCorner(frame,6); makeStroke(frame,1,.15)
    local fill=Instance.new("Frame"); fill.BackgroundColor3=CurrentTheme.Accent; fill.Size=UDim2.new((default-min)/(max-min),0,1,0); fill.Parent=frame; makeCorner(fill,6)
    local valText=Instance.new("TextLabel"); valText.BackgroundTransparency=1; valText.TextColor3=CurrentTheme.Text; valText.Font=Enum.Font.GothamSemibold; valText.TextSize=12
    valText.Size=UDim2.new(0,60,1,0); valText.AnchorPoint=Vector2.new(1,0); valText.Position=UDim2.new(1,-6,0,0); valText.Parent=frame; valText.Text=(fmt or "%d"):format(default)
    local dragging=false; local value=default
    local function setFromX(x)
        local rel=clamp((x-frame.AbsolutePosition.X)/frame.AbsoluteSize.X,0,1)
        value=round(min+(max-min)*rel,2); fill.Size=UDim2.new((value-min)/(max-min),0,1,0); valText.Text=(fmt or "%d"):format(value)
        if callback then callback(value) end
    end
    frame.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; setFromX(input.Position.X) end end)
    frame.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then setFromX(input.Position.X) end end)
    return {Get=function() return value end, Set=function(v) value=clamp(v,min,max); fill.Size=UDim2.new((value-min)/(max-min),0,1,0); valText.Text=(fmt or "%d"):format(value); if callback then callback(value) end end}
end

function Controls.Dropdown(parent,label,items,defaultIdx,callback)
    local row,lab=makeRow(parent,label)
    local btn=Instance.new("TextButton"); btn.AutoButtonColor=false; btn.Font=Enum.Font.GothamSemibold; btn.TextSize=12; btn.TextColor3=CurrentTheme.Text
    btn.BackgroundColor3=CurrentTheme.Hover; btn.Size=UDim2.new(0,160,0,24); btn.Position=UDim2.new(1,-170,0.5,-12); btn.Parent=row; makeCorner(btn,6); makeStroke(btn,1,.15)
    local idx=defaultIdx or 1; btn.Text=items[idx]
    local listFrame=Instance.new("Frame"); listFrame.Visible=false; listFrame.BackgroundColor3=CurrentTheme.Panel; listFrame.Size=UDim2.new(0,160,0,math.min(6,#items)*24+10)
    listFrame.Position=UDim2.new(1,-170,0.5,14); listFrame.Parent=row; makeCorner(listFrame,6); makeStroke(listFrame,1,.15); pad(listFrame,6)
    local ul=Instance.new("UIListLayout",listFrame); ul.Padding=UDim.new(0,6)
    for i,v in ipairs(items) do
        local it=Instance.new("TextButton"); it.Text=v; it.Font=Enum.Font.Gotham; it.TextSize=12; it.TextColor3=CurrentTheme.Text
        it.Size=UDim2.new(1,0,0,24); it.BackgroundColor3=CurrentTheme.Hover; it.Parent=listFrame; makeCorner(it,6)
        it.MouseButton1Click:Connect(function() idx=i; btn.Text=v; listFrame.Visible=false; if callback then callback(v,i) end end)
    end
    btn.MouseButton1Click:Connect(function() listFrame.Visible=not listFrame.Visible end)
    return {GetValue=function() return items[idx] end}
end

--// Crosshair
local Overlay=Instance.new("ScreenGui"); Overlay.Name="MYLF_HUD"; Overlay.IgnoreGuiInset=true; Overlay.Parent=PlayerGui
local Crosshair=Instance.new("Frame"); Crosshair.AnchorPoint=Vector2.new(.5,.5); Crosshair.Position=UDim2.fromScale(.5,.5); Crosshair.Size=UDim2.fromOffset(2,2)
Crosshair.BackgroundTransparency=1; Crosshair.Parent=Overlay
local arms={}; for i=1,4 do local a=Instance.new("Frame"); a.BorderSizePixel=0; a.Parent=Crosshair; arms[i]=a end
local CrosshairCfg={Enabled=true,Gap=6,Length=8,Thickness=2,Opacity=1,Color=CurrentTheme.Accent}
local function layoutCrosshair()
    for _,a in ipairs(arms) do a.BackgroundTransparency=1-CrosshairCfg.Opacity; a.BackgroundColor3=CrosshairCfg.Color end
    arms[1].Size=UDim2.fromOffset(CrosshairCfg.Thickness,CrosshairCfg.Length); arms[1].Position=UDim2.fromOffset(-CrosshairCfg.Thickness/2,-(CrosshairCfg.Gap+CrosshairCfg.Length))
    arms[2].Size=UDim2.fromOffset(CrosshairCfg.Thickness,CrosshairCfg.Length); arms[2].Position=UDim2.fromOffset(-CrosshairCfg.Thickness/2,CrosshairCfg.Gap)
    arms[3].Size=UDim2.fromOffset(CrosshairCfg.Length,CrosshairCfg.Thickness); arms[3].Position=UDim2.fromOffset(-(CrosshairCfg.Gap+CrosshairCfg.Length),-CrosshairCfg.Thickness/2)
    arms[4].Size=UDim2.fromOffset(CrosshairCfg.Length,CrosshairCfg.Thickness); arms[4].Position=UDim2.fromOffset(CrosshairCfg.Gap,-CrosshairCfg.Thickness/2)
    Crosshair.Visible=CrosshairCfg.Enabled
end
layoutCrosshair()

--// HUD Panel (FPS/Ping)
local CrownPanel=Instance.new("Frame"); CrownPanel.AnchorPoint=Vector2.new(.5,0); CrownPanel.Position=UDim2.new(.5,0,0,6); CrownPanel.Size=UDim2.fromOffset(300,28)
CrownPanel.BackgroundColor3=CurrentTheme.Hover; CrownPanel.Parent=Overlay; makeCorner(CrownPanel,6); makeStroke(CrownPanel,1,.1)
local CrownText=Instance.new("TextLabel"); CrownText.BackgroundTransparency=1; CrownText.Font=Enum.Font.GothamSemibold; CrownText.TextSize=13
CrownText.TextColor3=CurrentTheme.Text; CrownText.Size=UDim2.new(1,-12,1,0); CrownText.Position=UDim2.fromOffset(6,0); CrownText.Parent=CrownPanel; CrownText.Text="FPS: -- | Ping: --"

local fps,accum,count=60,0,0
RunService.RenderStepped:Connect(function(dt)
    accum+=dt; count+=1; if accum>=0.5 then fps=round(count/accum,0); accum,count=0,0
        local ping="?"; pcall(function() local it=Stats.Network.ServerStatsItem["Data Ping"]; if it then ping=tostring(it:GetValueString()):gsub(" RTT","") end end)
        CrownText.Text=("FPS: %s | Ping: %s"):format(fps,ping)
    end
end)

--// Scanner
local sScanL=Instance.new("Frame",pScanner); sScanL.Size=UDim2.new(0.5,-6,1,0); sScanL.BackgroundColor3=CurrentTheme.Bg; makeCorner(sScanL,8); makeStroke(sScanL,1,.08); pad(sScanL,6)
local sScanR=Instance.new("Frame",pScanner); sScanR.Size=UDim2.new(0.5,-6,1,0); sScanR.Position=UDim2.new(0.5,6,0,0); sScanR.BackgroundColor3=CurrentTheme.Bg; makeCorner(sScanR,8); makeStroke(sScanR,1,.08); pad(sScanR,6)

local search=Instance.new("TextBox",sScanL); search.Size=UDim2.new(1,0,0,26); search.PlaceholderText="Filter (name/class)"; search.TextColor3=CurrentTheme.Text; search.BackgroundColor3=CurrentTheme.Panel; makeCorner(search,6)
local btn=Instance.new("TextButton",sScanL); btn.Size=UDim2.new(0,60,0,26); btn.Position=UDim2.new(1,-66,0,0); btn.Text="Scan"; btn.BackgroundColor3=CurrentTheme.Accent; makeCorner(btn,6)

local list=Instance.new("ScrollingFrame",sScanL); list.Position=UDim2.new(0,0,0,34); list.Size=UDim2.new(1,0,1,-34); list.CanvasSize=UDim2.new(); list.ScrollBarThickness=6; list.BackgroundColor3=CurrentTheme.Panel; makeCorner(list,6)
local lay=Instance.new("UIListLayout",list); lay.Padding=UDim.new(0,4)
local info=Instance.new("TextLabel",sScanR); info.Size=UDim2.new(1,0,1,0); info.TextColor3=CurrentTheme.Text; info.BackgroundColor3=CurrentTheme.Panel; info.Text="Select object"; info.TextXAlignment=Enum.TextXAlignment.Left; info.TextYAlignment=Enum.TextYAlignment.Top; info.TextWrapped=true; makeCorner(info,6); makeStroke(info,1,.08)

local function addRow(inst)
    local b=Instance.new("TextButton"); b.Size=UDim2.new(1,-4,0,22); b.Text=("%s (%s)"):format(inst.Name,inst.ClassName); b.Font=Enum.Font.Gotham; b.TextSize=12; b.TextColor3=CurrentTheme.Text; b.BackgroundColor3=CurrentTheme.Hover
    b.Parent=list; makeCorner(b,6)
    b.MouseButton1Click:Connect(function() info.Text=("Name: %s\nClass: %s\nPath: %s"):format(inst.Name,inst.ClassName,inst:GetFullName()) end)
end
local function doScan()
    for _,c in ipairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    local filter=string.lower(search.Text); local count=0
    for _,root in ipairs({workspace,Players,game.ReplicatedStorage}) do
        for _,desc in ipairs(root:GetDescendants()) do
            if count>300 then break end
            if filter=="" or string.find(string.lower(desc.Name),filter) or string.find(string.lower(desc.ClassName),filter) then addRow(desc); count+=1 end
        end
    end
    list.CanvasSize=UDim2.new(0,0,0,lay.AbsoluteContentSize.Y+6)
end
btn.MouseButton1Click:Connect(doScan)
--========== FEATURES ==========
local function newSection(parent,title)
    local s=Instance.new("Frame"); s.BackgroundColor3=CurrentTheme.Bg; s.Size=UDim2.new(0.5,-6,0,200); s.Parent=parent
    makeCorner(s,8); makeStroke(s,1,.08); pad(s,8)
    local t=Instance.new("TextLabel"); t.BackgroundTransparency=1; t.Text=title; t.Font=Enum.Font.GothamBold; t.TextSize=14
    t.TextColor3=CurrentTheme.Text; t.Size=UDim2.new(1,0,0,18); t.Parent=s
    local list=Instance.new("UIListLayout",s); list.Padding=UDim.new(0,6)
    return s
end

-- Combat
local sCombat=newSection(pFeatures,"Rage / Combat")
Controls.Toggle(sCombat,"Aimbot",false,function(on) if features.ToggleAimbot then features.ToggleAimbot(on) end end)
Controls.Toggle(sCombat,"Silent Aim",false,function(on) if features.ToggleSilentAim then features.ToggleSilentAim(on) end end)
Controls.Toggle(sCombat,"☠ Kill Aura",false,function(on) if features.ToggleKillAura then features.ToggleKillAura(on) end end)
Controls.Toggle(sCombat,"Hard Fire Rate",false,function(on) if features.ToggleFireRate then features.ToggleFireRate(on) end end)

-- Visuals
local sVisuals=newSection(pFeatures,"Visuals / ESP")
Controls.Toggle(sVisuals,"Enable ESP",false,function(on) if features.ToggleESP then features.ToggleESP(on) end end)
Controls.Toggle(sVisuals,"Enemy Big Hitbox",false,function(on) if features.ToggleEnemyBigHitbox then features.ToggleEnemyBigHitbox(on) end end)
Controls.Toggle(sVisuals,"My Hitbox",false,function(on) if features.Togglemyhitbox then features.Togglemyhitbox(on) end end)

-- Movement
local sMove=newSection(pFeatures,"Movement")
Controls.Toggle(sMove,"Speed Boost",false,function(on) if features.ToggleSpeed then features.ToggleSpeed(on) end end)
Controls.Toggle(sMove,"Fly (LCtrl)",false,function(on) if features.ToggleFly then features.ToggleFly(on) end end)
Controls.Toggle(sMove,"Infinite Jump",false,function(on) if features.ToggleInfiniteJump then features.ToggleInfiniteJump(on) end end)
Controls.Toggle(sMove,"NoClip",false,function(on) if features.ToggleNoclip then features.ToggleNoclip(on) end end)

-- Protection
local sProt=newSection(pFeatures,"Protection")
Controls.Toggle(sProt,"💀 Godmode",false,function(on) if features.ToggleGodmode then features.ToggleGodmode(on) end end)
Controls.Toggle(sProt,"👻 Hard Invisible",false,function(on) if features.ToggleHardInvisible then features.ToggleHardInvisible(on) end end)

-- Utility
local sUtil=newSection(pFeatures,"Utility / TP")
Controls.Toggle(sUtil,"Teleport (T)",false,function(on) if features.ToggleTeleport then features.ToggleTeleport(on) end end)
Controls.Toggle(sUtil,"⚡ Always Behind",false,function(on) if features.ToggleAutoBehind then features.ToggleAutoBehind(on) end end)
Controls.Toggle(sUtil,"⚡ Auto Farm Enemy",false,function(on) if features.ToggleAutoTeleportToEnemy then features.ToggleAutoTeleportToEnemy(on) end end)

-- Offsets
local sOffsets=newSection(pFeatures,"Teleport Offsets")
local tpX,tpY,tpZ=0,0,25
Controls.Slider(sOffsets,"tpX",-50,50,tpX,"%0.0f",function(v) tpX=v; if features.SetTeleportOffset then features.SetTeleportOffset(tpX,tpY,tpZ) end end)
Controls.Slider(sOffsets,"tpY",-50,50,tpY,"%0.0f",function(v) tpY=v; if features.SetTeleportOffset then features.SetTeleportOffset(tpX,tpY,tpZ) end end)
Controls.Slider(sOffsets,"tpZ",1,100,tpZ,"%0.0f",function(v) tpZ=v; if features.SetTeleportOffset then features.SetTeleportOffset(tpX,tpY,tpZ) end end)

--========== PLAYER ==========
local sMovement=newSection(pPlayer,"Movement / Camera")
local sTools=newSection(pPlayer,"Utilities")

Controls.Dropdown(sMovement,"Camera Mode",{"ThirdPerson","FirstPerson","Orbital"},1,function(v)
    if v=="ThirdPerson" then LP.CameraMode=Enum.CameraMode.Classic; Camera.CameraType=Enum.CameraType.Custom
    elseif v=="FirstPerson" then LP.CameraMode=Enum.CameraMode.LockFirstPerson; Camera.CameraType=Enum.CameraType.Custom
    elseif v=="Orbital" then LP.CameraMode=Enum.CameraMode.Classic; Camera.CameraType=Enum.CameraType.Orbital end
end)
Controls.Slider(sMovement,"Field of View",60,100,Camera.FieldOfView,"%d",function(v) Camera.FieldOfView=v end)

Controls.Button(sTools,"Waypoint","Add Current",function()
    local char=LP.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local part=Instance.new("Part"); part.Anchored=true; part.CanCollide=false; part.Transparency=1; part.Size=Vector3.new(1,1,1)
        part.CFrame=CFrame.new(hrp.Position+Vector3.new(0,3,0)); part.Parent=workspace
        local att=Instance.new("Attachment",part); local bb=Instance.new("BillboardGui"); bb.Adornee=att; bb.Size=UDim2.fromOffset(160,40); bb.AlwaysOnTop=true; bb.Parent=part
        local label=Instance.new("TextLabel"); label.Size=UDim2.new(1,0,1,0); label.Text="📍 WP"; label.TextColor3=CurrentTheme.Text; label.Font=Enum.Font.GothamBold; label.TextSize=14; label.Parent=bb
    end
end)

--========== VISUALS ==========
local sCross=newSection(pVisuals,"Crosshair")
local crossToggle=Controls.Toggle(sCross,"Enable Crosshair",true,function(on) CrosshairCfg.Enabled=on; layoutCrosshair(); if features.ToggleCrosshair then features.ToggleCrosshair(on) end end)
Controls.Slider(sCross,"Gap",0,30,CrosshairCfg.Gap,"%d",function(v) CrosshairCfg.Gap=v; layoutCrosshair() end)
Controls.Slider(sCross,"Length",2,40,CrosshairCfg.Length,"%d",function(v) CrosshairCfg.Length=v; layoutCrosshair() end)
Controls.Slider(sCross,"Thickness",1,8,CrosshairCfg.Thickness,"%d",function(v) CrosshairCfg.Thickness=v; layoutCrosshair() end)

--========== HUD ==========
local sHud=newSection(pHUD,"Crown Panel")
Controls.Toggle(sHud,"Show HUD",true,function(on) CrownPanel.Visible=on; if features.ToggleHUDPanel then features.ToggleHUDPanel(on) end end)

--========== SETTINGS ==========
local sBind=newSection(pSettings,"Keybinds")
local bindBtn=Controls.Button(sBind,"Crosshair Bind","Set Key",function() State.BindListening="CrosshairToggle" end)

UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if State.BindListening and input.KeyCode~=Enum.KeyCode.Unknown then
        if State.BindListening=="CrosshairToggle" then
            State.Binds["CrosshairToggle"]=input.KeyCode
            bindBtn.Text="Set Key ("..input.KeyCode.Name..")"
        end
        State.BindListening=nil; return
    end
    if input.KeyCode==State.GlobalToggleKey then
        State.Visible=not State.Visible; Window.Visible=State.Visible
    end
    if State.Binds["CrosshairToggle"] and input.KeyCode==State.Binds["CrosshairToggle"] then
        CrosshairCfg.Enabled=not CrosshairCfg.Enabled; layoutCrosshair()
    end
end)

-- Final notify
print("⚡ MYLF Linoria+ loaded. Toggle menu with LeftShift.")
