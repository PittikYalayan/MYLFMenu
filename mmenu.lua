--[[ 
    ⚡ MYLF Linoria+ Legit UI Framework (Client-Safe) ⚡
    - Tek LocalScript ile çalışır (PlayerGui).
    - Hile, exploit, metamethod hook, remote patch, network bypass YOK.
    - Tamamen kozmetik/HUD ve client kamera/GUI ayarları.

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

--// Utils
local function tween(o, ti, props, es, ed)
    return TweenService:Create(o, TweenInfo.new(ti, es or Enum.EasingStyle.Quad, ed or Enum.EasingDirection.Out), props)
end

local function clamp(n, a, b)
    if n < a then return a elseif n > b then return b else return n end
end

local function round(n, p) 
    p = p or 0
    local m = 10^p
    return math.floor(n*m+0.5)/m
end

local function makeCorner(o, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = o
    return c
end

local function makeStroke(o, th, tr)
    local s = Instance.new("UIStroke")
    s.Thickness = th or 1
    s.Transparency = tr or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = o
    return s
end

local function pad(o, px)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, px)
    p.PaddingBottom = UDim.new(0, px)
    p.PaddingLeft = UDim.new(0, px)
    p.PaddingRight = UDim.new(0, px)
    p.Parent = o
    return p
end

local function hsl(h, s, l)
    -- 0..1 HSL -> Color3
    local function f(n)
        local k = (n + h*12) % 12
        local a = s * math.min(l, 1-l)
        return l - a * math.max(-1, math.min(math.min(k-3, 9-k), 1))
    end
    return Color3.new(f(0), f(8), f(4))
end

--// Theme Engine
local Themes = {
    Dark = {
        Bg = Color3.fromRGB(20,20,26),
        Panel = Color3.fromRGB(28,28,36),
        Accent = Color3.fromRGB(120,115,245),
        AccentSoft = Color3.fromRGB(95,90,210),
        Text = Color3.fromRGB(238,238,245),
        SubText = Color3.fromRGB(170,170,178),
        Stroke = Color3.fromRGB(60,60,72),
        Hover = Color3.fromRGB(40,40,52),
        Green = Color3.fromRGB(110,210,130),
        Red   = Color3.fromRGB(230,90,96),
        Yellow= Color3.fromRGB(245,209,66)
    },
    Midnight = {
        Bg = Color3.fromRGB(12,14,24),
        Panel = Color3.fromRGB(18,20,34),
        Accent = Color3.fromRGB(80,180,255),
        AccentSoft = Color3.fromRGB(60,140,210),
        Text = Color3.fromRGB(228,232,240),
        SubText = Color3.fromRGB(150,158,172),
        Stroke = Color3.fromRGB(40,48,66),
        Hover = Color3.fromRGB(26,30,46),
        Green = Color3.fromRGB(90,205,140),
        Red   = Color3.fromRGB(230,90,110),
        Yellow= Color3.fromRGB(245,209,66)
    },
    Neon = {
        Bg = Color3.fromRGB(18,18,22),
        Panel = Color3.fromRGB(22,22,28),
        Accent = Color3.fromRGB(255,80,200),
        AccentSoft = Color3.fromRGB(210,60,160),
        Text = Color3.fromRGB(245,245,255),
        SubText = Color3.fromRGB(172,170,190),
        Stroke = Color3.fromRGB(70,60,90),
        Hover = Color3.fromRGB(40,34,60),
        Green = Color3.fromRGB(110,240,200),
        Red   = Color3.fromRGB(255,100,140),
        Yellow= Color3.fromRGB(255,230,120)
    }
}
local CurrentTheme = Themes.Dark

local function applyTheme()
    -- color mapping doldurulacak, build sonrası çağrılır
end

--// State + Keybinds
local State = {
    Visible = true,
    Dragging = false,
    BindListening = nil, -- aktif bind dinleme kontrol id
    Binds = {},          -- [controlId] = Enum.KeyCode
    GlobalToggleKey = Enum.KeyCode.LeftShift
}

--// Root GUI
local Gui = Instance.new("ScreenGui")
Gui.Name = "MYLF_LinoriaPlus"
Gui.IgnoreGuiInset = true
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

-- Notification layer
local NotifLayer = Instance.new("Frame")
NotifLayer.Name = "NotifLayer"
NotifLayer.Size = UDim2.new(1,0,1,0)
NotifLayer.BackgroundTransparency = 1
NotifLayer.Parent = Gui

local function notify(text, dur)
    dur = dur or 2.5
    local t = Instance.new("TextLabel")
    t.BackgroundColor3 = CurrentTheme.Panel
    t.TextColor3 = CurrentTheme.Text
    t.Font = Enum.Font.GothamSemibold
    t.TextSize = 14
    t.AutoLocalize = false
    t.Text = "  "..text
    t.AnchorPoint = Vector2.new(1,0)
    t.Position = UDim2.new(1,-10,0,10)
    t.Size = UDim2.new(0, 0, 0, 28)
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = NotifLayer
    makeCorner(t, 6); makeStroke(t, 1, .1)
    local uisize = Instance.new("UISizeConstraint", t); uisize.MaxSize = Vector2.new(500, 40)
    tween(t, .18, {Size = UDim2.new(0, math.clamp(t.TextBounds.X+22, 140, 460), 0, 28), BackgroundTransparency = 0})
        :Play()
    task.delay(dur, function()
        local tw = tween(t, .18, {Position = UDim2.new(1, -10, 0, -34), BackgroundTransparency = 1})
        tw.Completed:Connect(function() t:Destroy() end)
        tw:Play()
    end)
end

--// Main Window
local Window = Instance.new("Frame")
Window.Name = "Window"
Window.Size = UDim2.new(0, 720, 0, 440)
Window.Position = UDim2.new(0.5, -360, 0.5, -220)
Window.BackgroundColor3 = CurrentTheme.Bg
Window.Active = true
Window.Parent = Gui
makeCorner(Window, 10); makeStroke(Window, 1, .2)

-- Drag
do
    local dragStart, startPos
    Window.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            State.Dragging = true
            dragStart = input.Position
            startPos = Window.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    State.Dragging = false
                end
            end)
        end
    end)
    Window.InputChanged:Connect(function(input)
        if State.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- TitleBar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1,0,0,42)
TitleBar.BackgroundColor3 = CurrentTheme.Panel
TitleBar.Parent = Window
makeCorner(TitleBar, 10); makeStroke(TitleBar, 1, .1)

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Text = "⚡ MYLF | Linoria+ (Legit Dev UI)"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = CurrentTheme.Text
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Size = UDim2.new(1,-160,1,0)
Title.Position = UDim2.new(0,14,0,0)
Title.Parent = TitleBar

local ThemeDropdownBtn = Instance.new("TextButton")
ThemeDropdownBtn.Text = "Theme: Dark"
ThemeDropdownBtn.AutoButtonColor = false
ThemeDropdownBtn.Font = Enum.Font.GothamSemibold
ThemeDropdownBtn.TextSize = 13
ThemeDropdownBtn.TextColor3 = CurrentTheme.Text
ThemeDropdownBtn.BackgroundColor3 = CurrentTheme.Hover
ThemeDropdownBtn.AnchorPoint = Vector2.new(1,0.5)
ThemeDropdownBtn.Position = UDim2.new(1,-10,0.5,0)
ThemeDropdownBtn.Size = UDim2.new(0,140,0,26)
ThemeDropdownBtn.Parent = TitleBar
makeCorner(ThemeDropdownBtn, 6); makeStroke(ThemeDropdownBtn, 1, .15)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.BackgroundColor3 = CurrentTheme.Panel
Sidebar.Position = UDim2.new(0,10,0,58)
Sidebar.Size = UDim2.new(0,160,1,-68)
Sidebar.Parent = Window
makeCorner(Sidebar, 8); makeStroke(Sidebar, 1, .08)
pad(Sidebar, 8)

local SideList = Instance.new("UIListLayout", Sidebar)
SideList.Padding = UDim.new(0,8)
SideList.SortOrder = Enum.SortOrder.LayoutOrder

local function makeTabButton(text, icon)
    local b = Instance.new("TextButton")
    b.AutoButtonColor = false
    b.Text = (icon and (icon.."  ") or "")..text
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 14
    b.TextColor3 = CurrentTheme.Text
    b.BackgroundColor3 = CurrentTheme.Hover
    b.Size = UDim2.new(1, -4, 0, 34)
    b.Parent = Sidebar
    makeCorner(b, 6); local st = makeStroke(b, 1, .2)
    b.MouseEnter:Connect(function() tween(b,.12,{BackgroundColor3=CurrentTheme.AccentSoft}):Play() end)
    b.MouseLeave:Connect(function() tween(b,.18,{BackgroundColor3=CurrentTheme.Hover}):Play() end)
    return b
end

-- Content
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0,180,0,58)
Content.Size = UDim2.new(1,-190,1,-68)
Content.Parent = Window

-- Pages
local Pages = {}
local function newPage(name)
    local p = Instance.new("Frame")
    p.Visible = false
    p.BackgroundColor3 = CurrentTheme.Panel
    p.Size = UDim2.new(1,0,1,0)
    p.Parent = Content
    makeCorner(p, 8); makeStroke(p, 1, .08)
    pad(p, 10)
    local list = Instance.new("UIListLayout", p)
    list.Padding = UDim.new(0,10)
    list.FillDirection = Enum.FillDirection.Horizontal
    list.SortOrder = Enum.SortOrder.LayoutOrder
    local ac = Instance.new("UIAspectRatioConstraint", p); ac.AspectRatio = 16/9; ac.DominantAxis = Enum.DominantAxis.Width
    Pages[name] = p
    return p
end

local function newSection(parent, title)
    local s = Instance.new("Frame")
    s.BackgroundTransparency = 0
    s.BackgroundColor3 = CurrentTheme.Bg
    s.Size = UDim2.new(0.5,-8,1,-0)
    s.Parent = parent
    makeCorner(s, 8); makeStroke(s,1,.08)
    pad(s, 10)
    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Text = title
    t.Font = Enum.Font.GothamBold
    t.TextSize = 14
    t.TextColor3 = CurrentTheme.Text
    t.Size = UDim2.new(1,0,0,18)
    t.Parent = s
    local list = Instance.new("UIListLayout", s)
    list.Padding = UDim.new(0,8); list.SortOrder = Enum.SortOrder.LayoutOrder
    return s
end

-- Controls Factory
local Controls = {}

local function makeRow(parent, label)
    local f = Instance.new("Frame"); f.BackgroundTransparency=1; f.Size=UDim2.new(1,0,0,28); f.Parent=parent
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1; l.Text = label; l.Font = Enum.Font.Gotham; l.TextSize = 13; l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextColor3 = CurrentTheme.SubText; l.Size = UDim2.new(0.45,0,1,0); l.Parent = f
    return f, l
end

function Controls.Toggle(parent, label, default, callback)
    local row, lab = makeRow(parent, label)
    local btn = Instance.new("TextButton")
    btn.AutoButtonColor=false; btn.Text = default and "ON" or "OFF"
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 12
    btn.TextColor3 = default and CurrentTheme.Green or CurrentTheme.Red
    btn.BackgroundColor3 = CurrentTheme.Hover; btn.Size = UDim2.new(0,70,0,24)
    btn.Position = UDim2.new(1,-80,0.5,-12); btn.AnchorPoint = Vector2.new(0,0)
    btn.Parent = row
    makeCorner(btn,6); makeStroke(btn,1,.2)
    local on = default or false
    btn.MouseButton1Click:Connect(function()
        on = not on
        btn.Text = on and "ON" or "OFF"
        btn.TextColor3 = on and CurrentTheme.Green or CurrentTheme.Red
        tween(btn,.08,{BackgroundColor3 = on and CurrentTheme.AccentSoft or CurrentTheme.Hover}):Play()
        if callback then task.spawn(callback, on) end
    end)
    return {
        Set = function(v) on=v; btn.Text=v and "ON" or "OFF"; btn.TextColor3 = v and CurrentTheme.Green or CurrentTheme.Red end,
        Get = function() return on end,
        Button = btn,
        Row = row,
        Label = lab
    }
end

function Controls.Slider(parent, label, min, max, default, fmt, callback)
    local row, lab = makeRow(parent, label)
    local frame = Instance.new("Frame"); frame.Size = UDim2.new(0.52,0,0,24); frame.Position = UDim2.new(0.46,0,0.5,-12); frame.BackgroundColor3 = CurrentTheme.Hover; frame.Parent = row
    makeCorner(frame,6); makeStroke(frame,1,.15)
    local fill = Instance.new("Frame"); fill.BackgroundColor3=CurrentTheme.Accent; fill.Size=UDim2.new((default-min)/(max-min),0,1,0); fill.Parent=frame; makeCorner(fill,6)
    local valText = Instance.new("TextLabel"); valText.BackgroundTransparency=1; valText.TextColor3=CurrentTheme.Text; valText.Font=Enum.Font.GothamSemibold; valText.TextSize=12; valText.Size=UDim2.new(0,60,1,0)
    valText.AnchorPoint=Vector2.new(1,0); valText.Position=UDim2.new(1,-6,0,0); valText.Parent=frame; valText.Text = (fmt or "%d"):format(default)
    local dragging = false; local value = default or min
    local function setFromX(x)
        local rel = clamp((x - frame.AbsolutePosition.X)/frame.AbsoluteSize.X, 0, 1)
        value = round(min + (max-min)*rel, 2)
        fill.Size = UDim2.new((value-min)/(max-min),0,1,0)
        valText.Text = (fmt or "%d"):format(value)
        if callback then callback(value) end
    end
    frame.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; setFromX(input.Position.X) end
    end)
    frame.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then setFromX(input.Position.X) end
    end)
    return {
        Set = function(v) value = clamp(v,min,max); fill.Size = UDim2.new((value-min)/(max-min),0,1,0); valText.Text = (fmt or "%d"):format(value); if callback then callback(value) end end,
        Get = function() return value end
    }
end

function Controls.Dropdown(parent, label, items, defaultIdx, callback)
    local row, lab = makeRow(parent, label)
    local btn = Instance.new("TextButton"); btn.AutoButtonColor=false; btn.Font=Enum.Font.GothamSemibold; btn.TextSize=12; btn.TextColor3=CurrentTheme.Text
    btn.BackgroundColor3=CurrentTheme.Hover; btn.Size=UDim2.new(0,160,0,24); btn.Position=UDim2.new(1,-170,0.5,-12); btn.Parent=row
    makeCorner(btn,6); makeStroke(btn,1,.15)
    local idx = defaultIdx or 1; btn.Text = items[idx] or "-"
    local open=false
    local listFrame = Instance.new("Frame"); listFrame.Visible=false; listFrame.BackgroundColor3=CurrentTheme.Panel; listFrame.Size=UDim2.new(0,160,0, math.min(6,#items)*24+10)
    listFrame.AnchorPoint=Vector2.new(0,0); listFrame.Position = UDim2.new(1,-170,0.5,14); listFrame.Parent=row; makeCorner(listFrame,6); makeStroke(listFrame,1,.15); pad(listFrame,6)
    local ul = Instance.new("UIListLayout", listFrame); ul.Padding=UDim.new(0,6)
    local buttons={}
    local function closeList() open=false; listFrame.Visible=false end
    local function openList() open=true; listFrame.Visible=true end
    for i,v in ipairs(items) do
        local it = Instance.new("TextButton"); it.AutoButtonColor=false; it.Font=Enum.Font.Gotham; it.TextSize=12; it.TextColor3=CurrentTheme.Text; it.Text=v
        it.BackgroundColor3=CurrentTheme.Hover; it.Size=UDim2.new(1,0,0,24); it.Parent=listFrame; makeCorner(it,6)
        it.MouseEnter:Connect(function() tween(it,.08,{BackgroundColor3=CurrentTheme.AccentSoft}):Play() end)
        it.MouseLeave:Connect(function() tween(it,.12,{BackgroundColor3=CurrentTheme.Hover}):Play() end)
        it.MouseButton1Click:Connect(function()
            idx=i; btn.Text=v; closeList(); if callback then callback(v,i) end
        end)
        table.insert(buttons,it)
    end
    btn.MouseButton1Click:Connect(function() if open then closeList() else openList() end end)
    return {
        SetIndex = function(i) if items[i] then idx=i; btn.Text=items[i]; if callback then callback(items[i],i) end end end,
        GetIndex = function() return idx end,
        GetValue = function() return items[idx] end
    }
end

function Controls.Color(parent, label, default, callback)
    local row, lab = makeRow(parent, label)
    local box = Instance.new("TextButton")
    box.AutoButtonColor=false; box.Text=""; box.Size=UDim2.new(0,36,0,24); box.Position=UDim2.new(1,-46,0.5,-12)
    box.BackgroundColor3 = default or CurrentTheme.Accent; box.Parent=row
    makeCorner(box,6); makeStroke(box,1,.15)
    local picking=false
    box.MouseButton1Click:Connect(function()
        picking = not picking
        notify(picking and "Renk seç: ekranın bir yerine tıkla." or "Renk seçimi kapatıldı.")
    end)
    UserInputService.InputBegan:Connect(function(input, gp)
        if picking and input.UserInputType==Enum.UserInputType.MouseButton1 then
            picking=false
            -- basit HSL döngü: fare X konumuna göre hue
            local rel = (input.Position.X % 512)/512
            local c = hsl(rel, .7, .55)
            box.BackgroundColor3 = c
            if callback then callback(c) end
        end
    end)
    return {
        Set = function(c) box.BackgroundColor3=c; if callback then callback(c) end end,
        Get = function() return box.BackgroundColor3 end
    }
end

function Controls.Button(parent, label, text, callback)
    local row, lab = makeRow(parent, label)
    local btn = Instance.new("TextButton")
    btn.AutoButtonColor=false; btn.Text=text or "Run"
    btn.Font=Enum.Font.GothamSemibold; btn.TextSize=12; btn.TextColor3=CurrentTheme.Text
    btn.BackgroundColor3=CurrentTheme.Hover; btn.Size=UDim2.new(0,120,0,24); btn.Position=UDim2.new(1,-130,0.5,-12)
    btn.Parent=row; makeCorner(btn,6); makeStroke(btn,1,.15)
    btn.MouseEnter:Connect(function() tween(btn,.08,{BackgroundColor3=CurrentTheme.AccentSoft}):Play() end)
    btn.MouseLeave:Connect(function() tween(btn,.12,{BackgroundColor3=CurrentTheme.Hover}):Play() end)
    btn.MouseButton1Click:Connect(function() if callback then callback() end end)
    return btn
end

--// Crosshair Overlay (GUI-based)
local Overlay = Instance.new("ScreenGui")
Overlay.Name = "MYLF_HUD"
Overlay.IgnoreGuiInset = true
Overlay.ResetOnSpawn = false
Overlay.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Overlay.Parent = PlayerGui

local Crosshair = Instance.new("Frame")
Crosshair.Name = "Crosshair"
Crosshair.AnchorPoint = Vector2.new(0.5,0.5)
Crosshair.Position = UDim2.fromScale(0.5,0.5)
Crosshair.Size = UDim2.fromOffset(2,2)
Crosshair.BackgroundTransparency = 1
Crosshair.Visible = true
Crosshair.Parent = Overlay

-- four arms
local arms = {}
for i=1,4 do
    local a = Instance.new("Frame")
    a.BackgroundColor3 = CurrentTheme.Accent
    a.BorderSizePixel = 0
    a.Parent = Crosshair
    makeCorner(a, 2)
    arms[i] = a
end

local CrosshairCfg = {
    Enabled = true,
    Gap = 6,
    Length = 8,
    Thickness = 2,
    Opacity = 1,
    Color = CurrentTheme.Accent
}

local function layoutCrosshair()
    for _,a in ipairs(arms) do a.BackgroundTransparency = 1 - CrosshairCfg.Opacity; a.BackgroundColor3 = CrosshairCfg.Color end
    arms[1].Size = UDim2.fromOffset(CrosshairCfg.Thickness, CrosshairCfg.Length)           -- up
    arms[1].Position = UDim2.fromOffset(-CrosshairCfg.Thickness/2, -(CrosshairCfg.Gap + CrosshairCfg.Length))
    arms[2].Size = UDim2.fromOffset(CrosshairCfg.Thickness, CrosshairCfg.Length)           -- down
    arms[2].Position = UDim2.fromOffset(-CrosshairCfg.Thickness/2, CrosshairCfg.Gap)
    arms[3].Size = UDim2.fromOffset(CrosshairCfg.Length, CrosshairCfg.Thickness)           -- left
    arms[3].Position = UDim2.fromOffset(-(CrosshairCfg.Gap + CrosshairCfg.Length), -CrosshairCfg.Thickness/2)
    arms[4].Size = UDim2.fromOffset(CrosshairCfg.Length, CrosshairCfg.Thickness)           -- right
    arms[4].Position = UDim2.fromOffset(CrosshairCfg.Gap, -CrosshairCfg.Thickness/2)
    Crosshair.Visible = CrosshairCfg.Enabled
end
layoutCrosshair()

-- FPS / Ping HUD
local HudTop = Instance.new("TextLabel")
HudTop.Name = "Perf"
HudTop.BackgroundTransparency = 1
HudTop.TextColor3 = CurrentTheme.SubText
HudTop.Font = Enum.Font.GothamSemibold
HudTop.TextSize = 13
HudTop.TextXAlignment = Enum.TextXAlignment.Left
HudTop.Position = UDim2.new(0,10,0,8)
HudTop.Size = UDim2.new(0,220,0,18)
HudTop.Parent = Overlay

local fps, dtAccum, dtCount = 60, 0, 0
RunService.RenderStepped:Connect(function(dt)
    dtAccum += dt; dtCount += 1
    if dtAccum >= 0.5 then
        fps = round(dtCount/dtAccum, 0)
        dtAccum, dtCount = 0, 0
        local pingStr = "?"
        pcall(function()
            local item = Stats.Network.ServerStatsItem["Data Ping"]
            if item then
                pingStr = tostring(item:GetValueString()):gsub(" RTT","")
            end
        end)
        HudTop.Text = ("FPS: %s   Ping: %s"):format(fps, pingStr)
    end
end)

-- Waypoints (client-only Billboard)
local WayFolder = Instance.new("Folder"); WayFolder.Name = "MYLF_Waypoints_Local"; WayFolder.Parent = workspace

local function createWaypoint(name, pos)
    local part = Instance.new("Part")
    part.Anchored = true; part.CanCollide=false; part.Transparency = 1; part.Size = Vector3.new(1,1,1)
    part.CFrame = CFrame.new(pos); part.Parent = WayFolder
    local att = Instance.new("Attachment", part)
    local bb = Instance.new("BillboardGui"); bb.Adornee = att; bb.Size = UDim2.fromOffset(160, 40); bb.AlwaysOnTop = true; bb.Parent = part
    local label = Instance.new("TextLabel"); label.Size = UDim2.new(1,0,1,0); label.BackgroundTransparency=0.2
    label.BackgroundColor3 = CurrentTheme.Panel; label.TextColor3 = CurrentTheme.Text; label.Font = Enum.Font.GothamBold; label.TextSize = 14; label.Text = "📍 "..name
    label.Parent = bb; makeCorner(label, 6); makeStroke(label,1,.15)
    return part
end

local function clearWaypoints() for _,v in ipairs(WayFolder:GetChildren()) do v:Destroy() end end

--// Build Pages
local pPlayer   = newPage("Player")
local pVisuals  = newPage("Visuals")
local pHUD      = newPage("HUD")
local pSettings = newPage("Settings")

-- Tabs
local tPlayer   = makeTabButton("Player",  "👤")
local tVisuals  = makeTabButton("Visuals", "🎨")
local tHUD      = makeTabButton("HUD",     "🧭")
local tSettings = makeTabButton("Settings","⚙️")

local function showPage(name)
    for k,frame in pairs(Pages) do frame.Visible = (k==name) end
end
showPage("Player")

tPlayer.MouseButton1Click:Connect(function() showPage("Player") end)
tVisuals.MouseButton1Click:Connect(function() showPage("Visuals") end)
tHUD.MouseButton1Click:Connect(function() showPage("HUD") end)
tSettings.MouseButton1Click:Connect(function() showPage("Settings") end)

-- PLAYER PAGE
local sMovement = newSection(pPlayer, "Movement / Camera")
local sTools    = newSection(pPlayer, "Utilities")

-- Camera Mode
Controls.Dropdown(sMovement, "Camera Mode", {"ThirdPerson","FirstPerson","Orbital"}, 1, function(v)
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
Controls.Slider(sMovement, "Field of View", 60, 100, Camera.FieldOfView, "%d", function(v)
    Camera.FieldOfView = v
end)

-- Smooth Shift-Look (client cam sway demo - kozmetik)
local swayConn
Controls.Toggle(sMovement, "Camera Sway", false, function(on)
    if swayConn then swayConn:Disconnect(); swayConn=nil end
    if on then
        local t=0
        swayConn = RunService.RenderStepped:Connect(function(dt)
            t+=dt
            Camera.CFrame = Camera.CFrame * CFrame.Angles(0,0, math.sin(t*1.2)*0.0008)
        end)
    end
end)

-- Waypoints
Controls.Button(sTools, "Waypoint", "Add Current", function()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local nm = "WP-"..string.sub(HttpService:GenerateGUID(false),1,4)
        createWaypoint(nm, hrp.Position + Vector3.new(0,3,0))
        notify("Waypoint eklendi: "..nm)
    else
        notify("Karakter bulunamadı.", 2.0)
    end
end)

Controls.Button(sTools, "Waypoint", "Clear All", function()
    clearWaypoints()
    notify("Tüm waypoint'ler silindi.")
end)

-- VISUALS PAGE
local sCross = newSection(pVisuals, "Crosshair")
local sTheme = newSection(pVisuals, "Theme / Colors")

local crossToggle = Controls.Toggle(sCross, "Enable Crosshair", true, function(on)
    CrosshairCfg.Enabled = on; layoutCrosshair()
end)

Controls.Slider(sCross, "Gap", 0, 30, CrosshairCfg.Gap, "%d", function(v) CrosshairCfg.Gap = v; layoutCrosshair() end)
Controls.Slider(sCross, "Length", 2, 40, CrosshairCfg.Length, "%d", function(v) CrosshairCfg.Length = v; layoutCrosshair() end)
Controls.Slider(sCross, "Thickness", 1, 8, CrosshairCfg.Thickness, "%d", function(v) CrosshairCfg.Thickness = v; layoutCrosshair() end)
Controls.Slider(sCross, "Opacity", 0, 1, CrosshairCfg.Opacity, "%.2f", function(v) CrosshairCfg.Opacity = v; layoutCrosshair() end)
Controls.Color(sCross, "Color", CrosshairCfg.Color, function(c) CrosshairCfg.Color = c; layoutCrosshair() end)

-- Theme demo accent color
Controls.Color(sTheme, "Accent Color (Override)", CurrentTheme.Accent, function(c)
    CrosshairCfg.Color = c; layoutCrosshair()
    CurrentTheme.Accent = c
    notify("Accent değişti.")
end)

-- HUD PAGE
local sHud = newSection(pHUD, "Performance")
local sHud2= newSection(pHUD, "Toggles")

local fpsToggle = Controls.Toggle(sHud2, "Show FPS/Ping", true, function(on)
    HudTop.Visible = on
end)
HudTop.Visible = true

Controls.Button(sHud, "Snapshot", "Notify Now", function()
    notify(("FPS %s  |  FOV %d"):format(tostring(round(fps,0)), round(Camera.FieldOfView,0)), 2.2)
end)

-- SETTINGS PAGE
local sBind = newSection(pSettings, "Keybinds")
local sMeta = newSection(pSettings, "Meta")

-- Simple per-control bind (demo: toggle crosshair with a custom key)
local bindLabel = Instance.new("TextLabel")
bindLabel.BackgroundTransparency = 1
bindLabel.Text = "Bind: Crosshair Toggle"
bindLabel.Font = Enum.Font.Gotham
bindLabel.TextSize = 13
bindLabel.TextColor3 = CurrentTheme.SubText
bindLabel.Size = UDim2.new(1,0,0,18)
bindLabel.Parent = sBind

local bindBtn = Instance.new("TextButton")
bindBtn.AutoButtonColor = false
bindBtn.Text = "Set Key (none)"
bindBtn.Font = Enum.Font.GothamSemibold
bindBtn.TextSize = 12
bindBtn.TextColor3 = CurrentTheme.Text
bindBtn.BackgroundColor3 = CurrentTheme.Hover
bindBtn.Size = UDim2.new(0,140,0,24)
bindBtn.Parent = sBind
makeCorner(bindBtn,6); makeStroke(bindBtn,1,.15)

bindBtn.MouseButton1Click:Connect(function()
    if State.BindListening then return end
    State.BindListening = "CrosshairToggle"
    bindBtn.Text = "Press any key..."
    notify("Crosshair için bir tuş seç.")
end)

local GlobalHint = Instance.new("TextLabel")
GlobalHint.BackgroundTransparency = 1
GlobalHint.Text = "Global Toggle: LeftShift (gizle/göster)"
GlobalHint.Font = Enum.Font.Gotham
GlobalHint.TextSize = 13
GlobalHint.TextColor3 = CurrentTheme.SubText
GlobalHint.Size = UDim2.new(1,0,0,18)
GlobalHint.Parent = sMeta

Controls.Button(sMeta, "Visibility", "Hide Window", function()
    State.Visible = not State.Visible
    Window.Visible = State.Visible
    notify(State.Visible and "Menü gösterildi." or "Menü gizlendi.")
end)

-- Theme dropdown from TitleBar
local themeOrder = {"Dark","Midnight","Neon"}
local function setThemeByName(name)
    local t = Themes[name] or Themes.Dark
    CurrentTheme = t
    -- repaint
    Window.BackgroundColor3 = t.Bg
    TitleBar.BackgroundColor3 = t.Panel
    Title.TextColor3 = t.Text
    ThemeDropdownBtn.TextColor3 = t.Text
    ThemeDropdownBtn.BackgroundColor3 = t.Hover
    Sidebar.BackgroundColor3 = t.Panel
    HudTop.TextColor3 = t.SubText
    for _,b in ipairs(Sidebar:GetChildren()) do
        if b:IsA("TextButton") then
            b.TextColor3 = t.Text
            b.BackgroundColor3 = t.Hover
        end
    end
    for name, page in pairs(Pages) do
        page.BackgroundColor3 = t.Panel
        for _,sec in ipairs(page:GetChildren()) do
            if sec:IsA("Frame") and sec ~= page then
                sec.BackgroundColor3 = t.Bg
            end
        end
    end
    layoutCrosshair()
end

local themeIndex = 1
ThemeDropdownBtn.MouseButton1Click:Connect(function()
    themeIndex = themeIndex % #themeOrder + 1
    local name = themeOrder[themeIndex]
    ThemeDropdownBtn.Text = "Theme: "..name
    setThemeByName(name)
    notify("Tema: "..name)
end)

-- Default theme paint
setThemeByName("Dark")

-- Key handling (global + binds)
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    -- listening bind?
    if State.BindListening and input.KeyCode ~= Enum.KeyCode.Unknown then
        local key = input.KeyCode
        if State.BindListening == "CrosshairToggle" then
            State.Binds["CrosshairToggle"] = key
            bindBtn.Text = "Set Key ("..key.Name..")"
            notify("Crosshair bind: "..key.Name)
        end
        State.BindListening = nil
        return
    end

    -- global toggle
    if input.KeyCode == State.GlobalToggleKey then
        State.Visible = not State.Visible
        Window.Visible = State.Visible
        notify(State.Visible and "Menü gösterildi." or "Menü gizlendi.")
        return
    end

    -- bound controls
    if State.Binds["CrosshairToggle"] and input.KeyCode == State.Binds["CrosshairToggle"] then
        CrosshairCfg.Enabled = not CrosshairCfg.Enabled
        crossToggle.Set(CrosshairCfg.Enabled)
        layoutCrosshair()
        notify("Crosshair: "..(CrosshairCfg.Enabled and "ON" or "OFF"))
    end
end)

-- Start toast
notify("MYLF Linoria+ yüklendi. LeftShift ile gizle/göster.", 3.2)

-- Safety: cleanup on character respawn keeps GUI
LP.CharacterAdded:Connect(function()
    task.delay(1.0, function()
        -- yeniden boyut/paint güvenliği
        layoutCrosshair()
        HudTop.Visible = fpsToggle.Get()
    end)
end)
--== [MYLF EXTENSION BLOCK — paste to end of your mylf.lua, change nothing above] ==--

-- 0) FEATURES bağla (senin istediğin gibi loadstring)
local features = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features9.8.lua"
))()

-- Küçük yardımcı: güvenli toggle çağrısı
local function ToggleSafe(fn)
    return function(on)
        if typeof(fn) == "function" then
            local ok, err = pcall(fn, on)
            if not ok then warn("[MYLF] feature error:", err) end
        else
            warn("[MYLF] missing feature fn")
        end
    end
end

-- 1) Yeni Tabs + Pages (mevcut yapıyı kullan)
local tAim      = makeTabButton("P-Aim",      "🎯")
local tESP      = makeTabButton("P-ESP",      "👁")
local tMove     = makeTabButton("P-Movement", "🏃")
local tTP       = makeTabButton("P-Teleport", "🌀")
local tScan     = makeTabButton("Scanner",    "🔍")
local tSet      = makeTabButton("P-Settings", "⚙️")

local pAim      = newPage("P-Aim")
local pESP      = newPage("P-ESP")
local pMove     = newPage("P-Movement")
local pTP       = newPage("P-Teleport")
local pScan     = newPage("Scanner")
local pSetExt   = newPage("P-Settings")

-- showPage zaten base’de var; sadece tab-click bağları:
tAim.MouseButton1Click:Connect(function() showPage("P-Aim") end)
tESP.MouseButton1Click:Connect(function() showPage("P-ESP") end)
tMove.MouseButton1Click:Connect(function() showPage("P-Movement") end)
tTP.MouseButton1Click:Connect(function() showPage("P-Teleport") end)
tScan.MouseButton1Click:Connect(function() showPage("Scanner") end)
tSet.MouseButton1Click:Connect(function() showPage("P-Settings") end)

-- 2) P-Aim
do
    local sAim = newSection(pAim, "Aim / Combat")
    Controls.Toggle(sAim, "Enable Aimbot",          false, ToggleSafe(features.ToggleAimbot))
    Controls.Toggle(sAim, "Silent Aim",             false, ToggleSafe(features.ToggleSilentAim))
    Controls.Toggle(sAim, "Force Headshot",         false, ToggleSafe(features.ToggleHeadshotRedirect))
    Controls.Toggle(sAim, "Hard Fire Rate",         false, ToggleSafe(features.ToggleFireRate))
    Controls.Toggle(sAim, "Magic Bullet (Fallback)",false, ToggleSafe(features.ToggleMagicBullet))
    Controls.Toggle(sAim, "☠️ Kill Aura",           false, ToggleSafe(features.ToggleKillAura))
end

-- 3) P-ESP (scrollable page içi)
do
    -- sayfa layout’unu bozmayalım: içinde scroll alanı aç
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "ESPScroll"
    scroll.Parent = pESP
    scroll.BackgroundTransparency = 1
    scroll.Position = UDim2.new(0,10,0,10)
    scroll.Size = UDim2.new(1,-20,1,-20)
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.ScrollBarThickness = 6

    local container = Instance.new("Frame", scroll)
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1,-6,0,0)
    container.Position = UDim2.new(0,3,0,0)

    local list = Instance.new("UIListLayout", container)
    list.Padding = UDim.new(0,10)
    list.SortOrder = Enum.SortOrder.LayoutOrder

    local function add(label, fn)
        Controls.Toggle(container, label, false, ToggleSafe(fn))
    end

    add("Enable ESP",         features.ToggleESP)
    add("Rainbow Name",       features.ToggleESPRainbow)
    add("Skeleton ESP",       features.ToggleESPSkeleton)
    add("Glow ESP",           features.ToggleESPGlow)
    add("3D Box ESP",         features.ToggleESPBox)
    add("Box Stripes",        features.ToggleESPStripes)
    add("Distance",           features.ToggleESPDistance)
    add("Health Bar",         features.ToggleESPHealth)
    add("Tracers",            features.ToggleESPTracers)
    add("Team Check",         features.ToggleESPTeam)
    add("Line of Sight",      features.ToggleESPLos)
    add("Range Limit",        features.ToggleESPRange)
    add("Offscreen Arrows",   features.ToggleESPArrows)
    add("Corner Box",         features.ToggleESPCorner)
    add("Friend Whitelist",   features.ToggleESPFriends)

    -- canvas boyutunu dinamik ayarla
    local function recalc()
        task.wait() -- layout ölçülsün
        local total = 0
        for _,child in ipairs(container:GetChildren()) do
            if child:IsA("Frame") then total += child.AbsoluteSize.Y + 10 end
        end
        scroll.CanvasSize = UDim2.new(0,0,0, math.max(0, total))
    end
    container.ChildAdded:Connect(recalc)
    container.ChildRemoved:Connect(recalc)
    recalc()
end

-- 4) P-Movement
do
    local s1 = newSection(pMove, "Movement")
    Controls.Toggle(s1, "Speed Boost (50)", false, ToggleSafe(features.ToggleSpeed))
    Controls.Toggle(s1, "Fly (LCtrl down)", false, ToggleSafe(features.ToggleFly))
    Controls.Toggle(s1, "Infinite Jump",    false, ToggleSafe(features.ToggleInfiniteJump))
    Controls.Toggle(s1, "NoClip",           false, ToggleSafe(features.ToggleNoclip))

    local s2 = newSection(pMove, "States")
    Controls.Toggle(s2, "💀 Godmode",       false, ToggleSafe(features.ToggleGodmode))
    Controls.Toggle(s2, "👻 Hard Invisible",false, ToggleSafe(features.ToggleHardInvisible))
    Controls.Toggle(s2, "Tiny Hitbox",      false, ToggleSafe(features.ToggleTinyHitbox))
    Controls.Toggle(s2, "My Tiny Hitbox",   false, ToggleSafe(features.ToggleMyTinyHitbox))
end

-- 5) P-Teleport (tp sliders burada)
do
    local sCore   = newSection(pTP, "Teleport / Farm")
    local sOffset = newSection(pTP, "Offsets")

    Controls.Toggle(sCore, "Teleport (T Key)",        false, ToggleSafe(features.ToggleTeleport))
    Controls.Toggle(sCore, "⚡ Always Behind Enemy",   false, ToggleSafe(features.ToggleAutoBehind))
    Controls.Toggle(sCore, "⚡ Auto Farm Enemy",       false, ToggleSafe(features.ToggleAutoTeleportToEnemy))

    local tpX, tpY, tpZ = 0, 0, 25
    Controls.Slider(sOffset, "X Offset", -50, 50, 0,  "%d", function(v) tpX = v; if features.SetTeleportOffset then pcall(features.SetTeleportOffset, tpX, tpY, tpZ) end end)
    Controls.Slider(sOffset, "Y Offset", -50, 50, 0,  "%d", function(v) tpY = v; if features.SetTeleportOffset then pcall(features.SetTeleportOffset, tpX, tpY, tpZ) end end)
    Controls.Slider(sOffset, "Z Offset",   1,100, 25, "%d", function(v) tpZ = v; if features.SetTeleportOffset then pcall(features.SetTeleportOffset, tpX, tpY, tpZ) end end)
end

-- 6) P-Settings (ek)
do
    local sGen = newSection(pSetExt, "General")
    Controls.Toggle(sGen, "Always On Top", false, function(on)
        -- base Gui ismi: MYLF_LinoriaPlus (bkz. base)
        local gui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("MYLF_LinoriaPlus")
        if gui then gui.DisplayOrder = on and 10000 or 1000 end
    end)

    local sTheme = newSection(pSetExt, "Theme Accent")
    Controls.Toggle(sTheme, "Switch Accent (Alt)", false, function(on)
        -- ThemeDropdownBtn zaten tab’dan değişiyor; burada sadece ufak alternatif accent dokunuşu
        -- (base repaint mekanizması setThemeByName ile çalışıyor)
    end)
end

-- 7) Scanner (Backpack/Character/Workspace)
do
    local sTop = newSection(pScan, "Scanner / Tools")
    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Name = "ScanList"
    listFrame.Parent = pScan
    listFrame.BackgroundTransparency = 1
    listFrame.Size = UDim2.new(1,-20,1,-120)
    listFrame.Position = UDim2.new(0,10,0,10)
    listFrame.CanvasSize = UDim2.new(0,0,0,0)
    listFrame.ScrollBarThickness = 6

    local ul = Instance.new("UIListLayout", listFrame)
    ul.Padding = UDim.new(0,6)
    ul.SortOrder = Enum.SortOrder.LayoutOrder

    local detailText = Instance.new("TextLabel", pScan)
    detailText.BackgroundTransparency = 1
    detailText.Text = "Detaylar..."
    detailText.TextWrapped = true
    detailText.TextXAlignment = Enum.TextXAlignment.Left
    detailText.TextYAlignment = Enum.TextYAlignment.Top
    detailText.Font = Enum.Font.Code
    detailText.TextSize = 12
    detailText.TextColor3 = Color3.fromRGB(220,220,230)
    detailText.Size = UDim2.new(1,-20,0,64)
    detailText.Position = UDim2.new(0,10,1,-100)

    local function collect()
        local LP = game.Players.LocalPlayer
        local items = {}
        local function pull(root, owner)
            if not root then return end
            for _,o in ipairs(root:GetDescendants()) do
                if o:IsA("Tool") then
                    table.insert(items, {
                        obj=o,
                        name=o.Name,
                        owner=owner,
                        hasHandle = o:FindFirstChild("Handle") ~= nil
                    })
                end
            end
        end
        pull(workspace, "world")
        pull(LP.Character, "character")
        pull(LP.Backpack, "backpack")
        return items
    end

    local selection = nil
    local function redraw()
        listFrame:ClearAllChildren()
        local total = 0
        for _,it in ipairs(collect()) do
            local row = Instance.new("TextButton")
            row.BackgroundColor3 = Color3.fromRGB(40,40,52)
            row.TextColor3 = Color3.fromRGB(235,235,245)
            row.Font = Enum.Font.Gotham
            row.TextSize = 12
            row.TextXAlignment = Enum.TextXAlignment.Left
            row.Text = string.format("[%s] %s  | owner=%s  | handle=%s", "Tool", it.name, it.owner, tostring(it.hasHandle))
            row.Size = UDim2.new(1, -6, 0, 28)
            row.Parent = listFrame
            row.MouseButton1Click:Connect(function()
                selection = it
                local ok, path = pcall(function() return it.obj:GetFullName() end)
                detailText.Text = string.format("Name: %s\nOwner: %s\nHandle: %s\nPath: %s",
                    it.name, it.owner, tostring(it.hasHandle), ok and path or "?")
            end)
            total += 34
        end
        listFrame.CanvasSize = UDim2.new(0,0,0,total)
        if not selection then detailText.Text = "Detaylar..." end
    end

    Controls.Button(sTop, "Refresh", "Scan Now", redraw)
    Controls.Button(sTop, "Action", "Equip", function()
        if not selection then return end
        local LP = game.Players.LocalPlayer
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum and selection.obj and selection.obj.Parent == LP.Backpack then
            pcall(function() hum:EquipTool(selection.obj) end)
        end
    end)
    Controls.Button(sTop, "Action", "Backpack’e Ekle", function()
        if not selection then return end
        local LP = game.Players.LocalPlayer
        if selection.obj and selection.obj:IsDescendantOf(LP.Character) then
            pcall(function() selection.obj.Parent = LP.Backpack end)
        else
            warn("[Scanner] World → Backpack ancak kendi server API'n varsa.")
        end
        redraw()
    end)
    Controls.Button(sTop, "Camera", "Kamerayı Odakla", function()
        if not selection then return end
        local cam = workspace.CurrentCamera
        local target = selection.obj:FindFirstChild("Handle") or selection.obj
        if target and target:IsA("BasePart") then
            cam.CFrame = CFrame.new(cam.CFrame.Position, target.Position)
        end
    end)

    redraw()
end

-- 8) Slider sürüklerken pencere kayma FIX (yapıyı bozmadan)
do
    local UIS = game:GetService("UserInputService")
    local allowDrag = false
    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Drag sadece TitleBar üzerinde başlarsa izin ver
            if TitleBar and TitleBar.AbsoluteSize then
                local pos = input.Position
                local tl = TitleBar.AbsolutePosition
                local br = tl + TitleBar.AbsoluteSize
                allowDrag = (pos.X>=tl.X and pos.X<=br.X and pos.Y>=tl.Y and pos.Y<=br.Y)
            else
                allowDrag = true
            end
        end
    end)
    UIS.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then allowDrag=false end end)
    UIS.InputChanged:Connect(function()
        if State and State.Dragging and not allowDrag then
            State.Dragging = false -- anında iptal: slider çekerken pencere kıpırdamaz
        end
    end)
end

--== [/MYLF EXTENSION BLOCK] ==--
