--==[ ⚡ MYLF UI Skeleton Library (Single-File) ]==--
-- Kullanım: local MYLF = loadstring(game:HttpGet(URL))()
-- API: :CreateWindow → :AddTab → :AddSection → :AddToggle/:AddSlider/:AddDropdown/:AddButton/:AddKeybind/:AddLabel
-- Bu sürümde: TopBar sağda FPS/RAM göstergesi + rainbow bar + stats hook noktaları

--// Services
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local HttpService        = game:GetService("HttpService")
local Stats              = game:GetService("Stats")

local LP = Players.LocalPlayer

--// Helpers
local function newInst(c, p) local i = Instance.new(c); if p then i.Parent = p end; return i end
local function round(n, r)
    r = r or 0
    if r <= 0 then return math.floor(n + 0.5) end
    local m = 10 ^ r
    return math.floor(n * m + 0.5) / m
end

local function Signal()
    local bind = Instance.new("BindableEvent")
    local sig = {}
    function sig:Connect(fn) return bind.Event:Connect(fn) end
    function sig:Fire(...) bind:Fire(...) end
    function sig:Wait() return bind.Event:Wait() end
    function sig:Destroy() bind:Destroy() end
    return sig
end

local function GiveSignal(self, conn)
    self._connections = self._connections or {}
    table.insert(self._connections, conn)
    return conn
end

local function MakeCorner(inst, r) local c = newInst("UICorner", inst); c.CornerRadius = UDim.new(0, r or 8); return c end
local function MakeStroke(inst, t, a)
    local s = newInst("UIStroke", inst)
    s.Thickness = t or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Color = Color3.fromRGB(255,255,255)
    s.Transparency = a or 0.85
    return s
end

local function Pad(inst, p) local u = newInst("UIPadding", inst); p = p or 8; u.PaddingTop = UDim.new(0,p); u.PaddingLeft = UDim.new(0,p); u.PaddingRight=UDim.new(0,p); u.PaddingBottom=UDim.new(0,p); return u end

-- owner: bağlantıları toplayacağımız table, frame: sürüklenecek frame, dragHandle: header
local function MakeDraggable(owner, frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging, dragStart, startPos
    GiveSignal(owner, dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos  = frame.Position
            GiveSignal(owner, input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end))
        end
    end))
    GiveSignal(owner, UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))
end

--// Theme Manager (basit)
local ThemeManager = {}
ThemeManager._themes = {
    ["Default"] = {
        Bg        = Color3.fromRGB(18,18,20),
        Panel     = Color3.fromRGB(28,28,32),
        Stroke    = Color3.fromRGB(255,255,255),
        Text      = Color3.fromRGB(235,235,240),
        SubText   = Color3.fromRGB(170,170,180),
        Accent    = Color3.fromRGB(80,160,255),
        Hover     = Color3.fromRGB(38,38,44),
        Good      = Color3.fromRGB(90,200,120),
        Bad       = Color3.fromRGB(255,95,95),
        Button    = Color3.fromRGB(40,40,48),
        Slider    = Color3.fromRGB(52,52,60),
        Rainbow1  = Color3.fromRGB(255,0,0),
        Rainbow2  = Color3.fromRGB(255,165,0),
        Rainbow3  = Color3.fromRGB(255,255,0),
        Rainbow4  = Color3.fromRGB(0,255,0),
        Rainbow5  = Color3.fromRGB(0,255,255),
        Rainbow6  = Color3.fromRGB(0,128,255),
        Rainbow7  = Color3.fromRGB(200,0,255),
    },
    ["Pink"] = {
        Bg        = Color3.fromRGB(20,16,20),
        Panel     = Color3.fromRGB(32,24,36),
        Stroke    = Color3.fromRGB(255,200,255),
        Text      = Color3.fromRGB(250,230,250),
        SubText   = Color3.fromRGB(210,170,210),
        Accent    = Color3.fromRGB(255,120,200),
        Hover     = Color3.fromRGB(42,30,48),
        Good      = Color3.fromRGB(120,220,160),
        Bad       = Color3.fromRGB(255,110,140),
        Button    = Color3.fromRGB(48,36,56),
        Slider    = Color3.fromRGB(60,44,68),
        Rainbow1  = Color3.fromRGB(255,0,128),
        Rainbow2  = Color3.fromRGB(255,128,0),
        Rainbow3  = Color3.fromRGB(255,255,0),
        Rainbow4  = Color3.fromRGB(0,255,128),
        Rainbow5  = Color3.fromRGB(0,255,255),
        Rainbow6  = Color3.fromRGB(0,128,255),
        Rainbow7  = Color3.fromRGB(200,0,255),
    }
}
function ThemeManager:Get(name) return self._themes[name] or self._themes["Default"] end
function ThemeManager:Set(name, t) self._themes[name] = t end

--// Library Root
local Library = {
    __VERSION  = "1.1-skeleton-fpsram",
    _connections = {},
    _toasts = {},
}

function Library:_mountGui()
    if self._gui then return end
    local gui = newInst("ScreenGui", LP:WaitForChild("PlayerGui"))
    gui.Name = "MYLF_UI"
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    self._gui = gui
end

-- basit toast
function Library:Notify(text, duration)
    duration = duration or 2.5
    self:_mountGui()
    local root = self._toastRoot
    if not root then
        root = newInst("Frame", self._gui)
        root.Name = "ToastRoot"
        root.AnchorPoint = Vector2.new(1,1)
        root.Position = UDim2.new(1,-16,1,-16)
        root.Size = UDim2.new(0, 300, 0, 200)
        root.BackgroundTransparency = 1
        local list = newInst("UIListLayout", root)
        list.HorizontalAlignment = Enum.HorizontalAlignment.Right
        list.VerticalAlignment   = Enum.VerticalAlignment.Bottom
        list.Padding = UDim.new(0,8)
        self._toastRoot = root
    end
    local t = newInst("Frame", root)
    t.AutomaticSize = Enum.AutomaticSize.Y
    t.Size = UDim2.new(1, 0, 0, 0)
    t.BackgroundColor3 = self._theme.Panel
    MakeCorner(t, 8); MakeStroke(t, 1, .9); Pad(t, 10)
    local lbl = newInst("TextLabel", t)
    lbl.Size = UDim2.new(1, 0, 0, 0)
    lbl.AutomaticSize = Enum.AutomaticSize.Y
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 14
    lbl.TextColor3 = self._theme.Text
    lbl.TextWrapped = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = tostring(text)
    task.spawn(function()
        task.wait(duration)
        TweenService:Create(t, TweenInfo.new(.2), {BackgroundTransparency = 1}):Play()
        task.wait(.25)
        t:Destroy()
    end)
end

--// Window Class
local Window = {}
Window.__index = Window

function Library:CreateWindow(opts)
    self:_mountGui()
    self._theme = ThemeManager:Get((opts and opts.Theme) or "Default")

    local win = setmetatable({
        _library = self,
        _theme   = self._theme,
        _connections = {},
        _tabs    = {},
        _tick    = Signal(),
        Title    = (opts and opts.Title) or "MYLF Window",
        Sub      = (opts and opts.Sub) or "",
        Visible  = true,
        Keybind  = (opts and opts.Keybind) or Enum.KeyCode.RightShift,
        _statsProvider = nil, -- hook: custom fps/mem sağlayıcı
        _fps = 0, _mem = 0,
    }, Window)

    -- Root panel
    local root = newInst("Frame", self._gui)
    root.Name = "Window"
    root.Size = UDim2.new(0, 740, 0, 460)
    root.Position = UDim2.new(0.5, -370, 0.5, -230)
    root.BackgroundColor3 = self._theme.Bg
    MakeCorner(root, 12); MakeStroke(root, 1, .88); Pad(root, 10)
    win._root = root

    -- TopBar
    local top = newInst("Frame", root)
    top.Name = "TopBar"
    top.Size = UDim2.new(1, 0, 0, 44)
    top.BackgroundColor3 = self._theme.Panel
    MakeCorner(top, 8); MakeStroke(top, 1, .85); Pad(top, 10)

    local title = newInst("TextLabel", top)
    title.BackgroundTransparency = 1
    title.Text = win.Title
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextColor3 = win._theme.Text
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Size = UDim2.new(1, -240, 1, -20)
    title.Position = UDim2.new(0, 8, 0, 10)
    win._titleLabel = title

    local sub = newInst("TextLabel", top)
    sub.BackgroundTransparency = 1
    sub.Text = win.Sub
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 12
    sub.TextColor3 = win._theme.SubText
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Size = UDim2.new(1, -240, 0, 14)
    sub.Position = UDim2.new(0, 8, 0, 24)
    win._subLabel = sub

    -- Close / Visibility
    local closeBtn = newInst("TextButton", top)
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -36, 0, 8)
    closeBtn.AutoButtonColor = false
    closeBtn.Text = "–"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.TextColor3 = win._theme.Text
    closeBtn.BackgroundColor3 = win._theme.Button
    MakeCorner(closeBtn, 6); MakeStroke(closeBtn,1,.8)
    GiveSignal(win, closeBtn.MouseButton1Click:Connect(function()
        win:SetVisible(not win.Visible)
    end))

    -- PERF CLUSTER (FPS/RAM + Rainbow bar)
    local perf = newInst("Frame", top)
    perf.Name = "Perf"
    perf.Size = UDim2.new(0, 180, 0, 28)
    perf.Position = UDim2.new(1, -220, 0, 8)
    perf.BackgroundColor3 = win._theme.Button
    MakeCorner(perf, 6); MakeStroke(perf,1,.8); Pad(perf,8)

    local perfLbl = newInst("TextLabel", perf)
    perfLbl.Name = "Label"
    perfLbl.BackgroundTransparency = 1
    perfLbl.Font = Enum.Font.GothamSemibold
    perfLbl.TextSize = 13
    perfLbl.TextColor3 = win._theme.Text
    perfLbl.TextXAlignment = Enum.TextXAlignment.Center
    perfLbl.Size = UDim2.new(1, 0, 1, -8)
    perfLbl.Position = UDim2.new(0,0,0,0)
    perfLbl.Text = "FPS -- • RAM -- MB"

    local bar = newInst("Frame", perf)
    bar.Name = "Rainbow"
    bar.Size = UDim2.new(1, -8, 0, 2)
    bar.Position = UDim2.new(0, 4, 1, -4)
    bar.BackgroundTransparency = 0
    MakeCorner(bar, 2)

    local grad = newInst("UIGradient", bar)
    grad.Rotation = 0
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, win._theme.Rainbow1),
        ColorSequenceKeypoint.new(0.16, win._theme.Rainbow2),
        ColorSequenceKeypoint.new(0.33, win._theme.Rainbow3),
        ColorSequenceKeypoint.new(0.50, win._theme.Rainbow4),
        ColorSequenceKeypoint.new(0.66, win._theme.Rainbow5),
        ColorSequenceKeypoint.new(0.83, win._theme.Rainbow6),
        ColorSequenceKeypoint.new(1.00, win._theme.Rainbow7),
    })
    grad.Offset = Vector2.new(0,0)

    -- Body: Tabs (left) + Pages (right)
    local body = newInst("Frame", root)
    body.Name = "Body"
    body.BackgroundTransparency = 1
    body.Position = UDim2.new(0, 0, 0, 60)
    body.Size = UDim2.new(1, 0, 1, -70)

    local tabs = newInst("Frame", body)
    tabs.Name = "TabBar"
    tabs.Size = UDim2.new(0, 160, 1, 0)
    tabs.BackgroundColor3 = win._theme.Panel
    MakeCorner(tabs, 8); MakeStroke(tabs,1,.9); Pad(tabs,8)
    local tabsList = newInst("UIListLayout", tabs)
    tabsList.Padding = UDim.new(0, 6)
    tabsList.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabsList.VerticalAlignment   = Enum.VerticalAlignment.Top

    local pages = newInst("Frame", body)
    pages.Name = "Pages"
    pages.Position = UDim2.new(0, 176, 0, 0)
    pages.Size = UDim2.new(1, -176, 1, 0)
    pages.BackgroundColor3 = win._theme.Panel
    MakeCorner(pages, 8); MakeStroke(pages,1,.9); Pad(pages,12)

    win._tabsRoot = tabs
    win._pagesRoot = pages

    -- Visibility keybind
    GiveSignal(win, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == win.Keybind then
            win:SetVisible(not win.Visible)
        end
    end))

    -- Draggable
    MakeDraggable(win, root, top)

    --== PERF UPDATE LOOP + RAINBOW ANIM ==--
    local fpsAvg = 60
    local tAccum = 0
    local gradShift = 0
    GiveSignal(win, RunService.RenderStepped:Connect(function(dt)
        -- fps (exponential smoothing)
        local cur = 1 / math.max(dt, 1/1000)
        fpsAvg = fpsAvg * 0.90 + cur * 0.10

        -- rainbow akışı
        gradShift = (gradShift + dt * 0.5) % 1
        grad.Offset = Vector2.new(gradShift, 0)

        tAccum = tAccum + dt
        if tAccum >= 0.25 then
            local mem
            if win._statsProvider then
                local f, m = win._statsProvider()
                if typeof(f) == "number" then fpsAvg = f end
                if typeof(m) == "number" then mem = m end
            end
            mem = mem or (Stats and Stats:GetTotalMemoryUsageMb() or 0)
            win._fps = math.floor(fpsAvg + 0.5)
            win._mem = math.floor(mem + 0.5)
            perfLbl.Text = ("FPS %d • RAM %d MB"):format(win._fps, win._mem)
            win._tick:Fire(dt, win._fps, win._mem)
            tAccum = 0
        end
    end))

    return win
end

function Window:SetVisible(v)
    self.Visible = not not v
    self._root.Visible = self.Visible
end

function Window:SetKeybind(keycode) self.Keybind = keycode end
function Window:SetTitle(t) self.Title = t; if self._titleLabel then self._titleLabel.Text = t end end
function Window:SetSubtitle(t) self.Sub = t; if self._subLabel then self._subLabel.Text = t end end

-- Hook: kendi istatistik sağlayıcını ver → her güncellemede çağrılır
-- Beklenen dönüş: return fpsNumber, memMbNumber (ikisi de optional; vermediğini biz hesaplarız)
function Window:SetStatsProvider(fn) self._statsProvider = fn end

-- Hook: her frame tetiklenir (smoothed fps & mem ile)
function Window:OnTick(fn) return self._tick:Connect(fn) end

function Window:GetFPS() return self._fps or 0 end
function Window:GetRAMMB() return self._mem or 0 end

--// Tab Class
local Tab = {} ; Tab.__index = Tab
function Window:AddTab(def)
    def = def or {}
    local tab = setmetatable({
        _window = self,
        _theme  = self._theme,
        _connections = {},
        Text = def.Text or "Tab",
        Icon = def.Icon,
        IconRectOffset = def.IconRectOffset,
        IconRectSize   = def.IconRectSize,
        _active = false,
        _sections = {},
    }, Tab)

    -- Tab Button
    local b = newInst("TextButton", self._tabsRoot)
    b.Size = UDim2.new(1, -8, 0, 34)
    b.AutoButtonColor = false
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.BackgroundColor3 = tab._theme.Button
    MakeCorner(b, 8); MakeStroke(b,1,.85); Pad(b,10)
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 14
    b.TextColor3 = tab._theme.Text
    b.Text = tab.Text

    if tab.Icon then
        local img = newInst("ImageLabel", b)
        img.BackgroundTransparency = 1
        img.Size = UDim2.new(0, 18, 0, 18)
        img.Position = UDim2.new(0, 6, 0, 8)
        img.Image = tab.Icon
        if tab.IconRectOffset and tab.IconRectSize then
            img.ImageRectOffset = tab.IconRectOffset
            img.ImageRectSize   = tab.IconRectSize
        end
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.Text = "       " .. (tab.Text or "")
    end

    tab._button = b

    -- Page
    local page = newInst("ScrollingFrame", self._pagesRoot)
    page.Name = "Page_" .. (tab.Text or "Tab")
    page.BackgroundTransparency = 1
    page.Visible = false
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.ScrollBarThickness = 6
    local list = newInst("UIListLayout", page)
    list.Padding = UDim.new(0, 10)
    list.HorizontalAlignment = Enum.HorizontalAlignment.Left
    list.VerticalAlignment   = Enum.VerticalAlignment.Top
    tab._page = page
    tab._list = list

    GiveSignal(tab, b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(.15), {BackgroundColor3 = tab._theme.Hover}):Play()
    end))
    GiveSignal(tab, b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(.15), {BackgroundColor3 = tab._active and tab._theme.Accent or tab._theme.Button}):Play()
    end))
    GiveSignal(tab, b.MouseButton1Click:Connect(function() tab:Show() end))

    table.insert(self._tabs, tab)
    if #self._tabs == 1 then tab:Show() end

    return tab
end

function Tab:Show()
    for _, t in ipairs(self._window._tabs) do
        t._active = false
        t._button.BackgroundColor3 = t._theme.Button
        t._page.Visible = false
    end
    self._active = true
    self._button.BackgroundColor3 = self._theme.Accent
    self._page.Visible = true
end

--// Section Class
local Section = {} ; Section.__index = Section
function Tab:AddSection(title)
    local s = setmetatable({
        _tab = self,
        _theme = self._theme,
        _connections = {},
        _controls = {},
        Title = title or "Section",
    }, Section)

    local frame = newInst("Frame", self._page)
    frame.Size = UDim2.new(1, -6, 0, 0)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.BackgroundColor3 = s._theme.Bg
    MakeCorner(frame, 8); MakeStroke(frame,1,.9); Pad(frame, 10)
    s._frame = frame

    local lbl = newInst("TextLabel", frame)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 14
    lbl.TextColor3 = s._theme.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.Text = s.Title

    local inner = newInst("Frame", frame)
    inner.Name = "Inner"
    inner.BackgroundColor3 = s._theme.Panel
    inner.Size = UDim2.new(1, 0, 0, 0)
    inner.AutomaticSize = Enum.AutomaticSize.Y
    inner.Position = UDim2.new(0, 0, 0, 26)
    MakeCorner(inner, 8); MakeStroke(inner,1,.9); Pad(inner, 10)
    local list = newInst("UIListLayout", inner)
    list.Padding = UDim.new(0, 8)
    s._inner = inner

    return s
end

--// Controls
local function ControlBase(section, kind, id)
    return {
        _section = section,
        _theme   = section._theme,
        _id      = id or HttpService:GenerateGUID(false),
        _kind    = kind,
        _changed = Signal(),
        _connections = {},
        GetId = function(self) return self._id end,
        OnChanged = function(self, fn) return self._changed:Connect(fn) end,
        FireChanged = function(self, ...) self._changed:Fire(...) end,
        Destroy = function(self)
            for _,c in ipairs(self._connections) do pcall(function() c:Disconnect() end) end
            self._changed:Destroy()
            if self._root then self._root:Destroy() end
        end
    }
end

function Section:AddLabel(text)
    local c = ControlBase(self, "Label")
    local r = newInst("TextLabel", self._inner)
    c._root = r
    r.BackgroundTransparency = 1
    r.Font = Enum.Font.Gotham
    r.TextSize = 13
    r.TextColor3 = c._theme.SubText
    r.TextXAlignment = Enum.TextXAlignment.Left
    r.Size = UDim2.new(1, 0, 0, 18)
    r.Text = text or "Label"
    return c
end

function Section:AddButton(text, callback)
    local c = ControlBase(self, "Button")
    local b = newInst("TextButton", self._inner)
    c._root = b
    b.Size = UDim2.new(1, 0, 0, 32)
    b.AutoButtonColor = false
    b.Text = text or "Button"
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 14
    b.TextColor3 = c._theme.Text
    b.BackgroundColor3 = c._theme.Button
    MakeCorner(b, 8); MakeStroke(b,1,.88)
    table.insert(c._connections, b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(.12), {BackgroundColor3 = c._theme.Hover}):Play() end))
    table.insert(c._connections, b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(.12), {BackgroundColor3 = c._theme.Button}):Play() end))
    table.insert(c._connections, b.MouseButton1Click:Connect(function() if callback then callback() end end))
    return c
end

function Section:AddToggle(id, opts)
    opts = opts or {}
    local c = ControlBase(self, "Toggle", id)
    c.Value = not not opts.Default
    c.Text  = opts.Text or "Toggle"

    local f = newInst("Frame", self._inner)
    c._root = f
    f.Size = UDim2.new(1, 0, 0, 32)
    f.BackgroundColor3 = c._theme.Slider
    MakeCorner(f, 8); MakeStroke(f,1,.9); Pad(f, 8)

    local lbl = newInst("TextLabel", f)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextColor3 = c._theme.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Size = UDim2.new(1, -44, 1, 0)
    lbl.Text = c.Text

    local btn = newInst("TextButton", f)
    btn.AutoButtonColor = false
    btn.Size = UDim2.new(0, 28, 0, 20)
    btn.Position = UDim2.new(1, -34, 0.5, -10)
    btn.BackgroundColor3 = c.Value and c._theme.Good or c._theme.Bad
    btn.Text = ""
    MakeCorner(btn, 10); MakeStroke(btn,1,.8)

    local dot = newInst("Frame", btn)
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = UDim2.new(c.Value and 1 or 0, c.Value and -14 or 2, 0.5, -6)
    dot.BackgroundColor3 = Color3.fromRGB(255,255,255)
    MakeCorner(dot, 12)

    local function render(v)
        btn.BackgroundColor3 = v and c._theme.Good or c._theme.Bad
        dot.Position = UDim2.new(v and 1 or 0, v and -14 or 2, 0.5, -6)
    end

    table.insert(c._connections, btn.MouseButton1Click:Connect(function()
        c.Value = not c.Value
        render(c.Value)
        c:FireChanged(c.Value)
    end))

    function c:Set(v) v = not not v; if c.Value == v then return end; c.Value = v; render(v); c:FireChanged(v) end
    function c:Get() return c.Value end

    render(c.Value)
    return c
end

function Section:AddSlider(id, opts)
    opts = opts or {}
    local c = ControlBase(self, "Slider", id)
    c.Min = opts.Min or 0
    c.Max = opts.Max or 100
    c.Value = math.clamp(opts.Default or c.Min, c.Min, c.Max)
    c.Rounding = (opts.Rounding or 0)
    c.Text = opts.Text or "Slider"

    local f = newInst("Frame", self._inner)
    c._root = f
    f.Size = UDim2.new(1, 0, 0, 44)
    f.BackgroundColor3 = c._theme.Slider
    MakeCorner(f, 8); MakeStroke(f,1,.9); Pad(f, 8)

    local top = newInst("Frame", f)
    top.BackgroundTransparency = 1
    top.Size = UDim2.new(1, 0, 0, 18)
    local label = newInst("TextLabel", top)
    label.BackgroundTransparency = 1
    label.Text = c.Text .. "  •  " .. tostring(c.Value)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextColor3 = c._theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Size = UDim2.new(1, 0, 1, 0)

    local bar = newInst("Frame", f)
    bar.Size = UDim2.new(1, 0, 0, 10)
    bar.Position = UDim2.new(0, 0, 0, 26)
    bar.BackgroundColor3 = c._theme.Button
    MakeCorner(bar, 6)

    local fill = newInst("Frame", bar)
    fill.Size = UDim2.new((c.Value - c.Min)/(c.Max - c.Min), 0, 1, 0)
    fill.BackgroundColor3 = c._theme.Accent
    MakeCorner(fill, 6)

    local dragging = false
    local function setFromX(x)
        local abs = x - bar.AbsolutePosition.X
        local pct = math.clamp(abs / bar.AbsoluteSize.X, 0, 1)
        local v = c.Min + pct * (c.Max - c.Min)
        v = round(v, c.Rounding)
        c.Value = v
        fill.Size = UDim2.new(pct, 0, 1, 0)
        label.Text = c.Text .. "  •  " .. tostring(v)
        c:FireChanged(v)
    end

    table.insert(c._connections, bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            setFromX(input.Position.X)
        end
    end))
    table.insert(c._connections, bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end))
    table.insert(c._connections, UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            setFromX(input.Position.X)
        end
    end))

    function c:Set(v)
        v = math.clamp(v, c.Min, c.Max)
        c.Value = v
        local pct = (v - c.Min)/(c.Max - c.Min)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        label.Text = c.Text .. "  •  " .. tostring(v)
        c:FireChanged(v)
    end
    function c:Get() return c.Value end

    c:Set(c.Value)
    return c
end

function Section:AddDropdown(id, opts)
    opts = opts or {}
    local c = ControlBase(self, "Dropdown", id)
    c.Text   = opts.Text or "Dropdown"
    c.Values = opts.Values or {}
    c.Value  = opts.Default or c.Values[1]

    local f = newInst("Frame", self._inner)
    c._root = f
    f.Size = UDim2.new(1, 0, 0, 34)
    f.BackgroundColor3 = c._theme.Slider
    MakeCorner(f, 8); MakeStroke(f,1,.9); Pad(f, 8)

    local lbl = newInst("TextLabel", f)
    lbl.Size = UDim2.new(.5, -6, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextColor3 = c._theme.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = c.Text

    local btn = newInst("TextButton", f)
    btn.Size = UDim2.new(.5, 0, 1, -2)
    btn.Position = UDim2.new(.5, 0, 0, 1)
    btn.AutoButtonColor = false
    btn.Text = tostring(c.Value or "Select")
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.TextColor3 = c._theme.Text
    btn.BackgroundColor3 = c._theme.Button
    MakeCorner(btn, 6); MakeStroke(btn,1,.85)

    local open = false
    local popup
    local function closePopup()
        open = false
        if popup then popup:Destroy() popup = nil end
    end
    local function openPopup()
        closePopup()
        open = true
        popup = newInst("Frame", f)
        popup.Position = UDim2.new(.5, 0, 1, 6)
        popup.Size = UDim2.new(.5, 0, 0, math.min(6, #c.Values)*28 + 8)
        popup.BackgroundColor3 = c._theme.Panel
        MakeCorner(popup, 8); MakeStroke(popup,1,.85); Pad(popup,6)
        local list = newInst("UIListLayout", popup); list.Padding = UDim.new(0,6)
        for _,v in ipairs(c.Values) do
            local it = newInst("TextButton", popup)
            it.Size = UDim2.new(1,0,0,22)
            it.AutoButtonColor = false
            it.Text = tostring(v)
            it.Font = Enum.Font.Gotham
            it.TextSize = 13
            it.TextColor3 = c._theme.Text
            it.BackgroundColor3 = c._theme.Button
            MakeCorner(it, 6)
            it.MouseButton1Click:Connect(function()
                c.Value = v
                btn.Text = tostring(v)
                c:FireChanged(v)
                closePopup()
            end)
        end
    end

    table.insert(c._connections, btn.MouseButton1Click:Connect(function()
        if open then closePopup() else openPopup() end
    end))
    table.insert(c._connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if open and input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- dış tıkta kapansın (yaklaşık kontrol)
            closePopup()
        end
    end))

    function c:Set(v) c.Value = v; btn.Text = tostring(v); c:FireChanged(v) end
    function c:Get() return c.Value end

    return c
end

function Section:AddKeybind(id, opts)
    opts = opts or {}
    local c = ControlBase(self, "Keybind", id)
    c.Text = opts.Text or "Keybind"
    c.Value = opts.Default or Enum.KeyCode.RightShift
    c._binding = false

    local f = newInst("Frame", self._inner)
    c._root = f
    f.Size = UDim2.new(1, 0, 0, 34)
    f.BackgroundColor3 = c._theme.Slider
    MakeCorner(f,8); MakeStroke(f,1,.9); Pad(f,8)

    local lbl = newInst("TextLabel", f)
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(.5, -6, 1, 0)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextColor3 = c._theme.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = c.Text

    local btn = newInst("TextButton", f)
    btn.Size = UDim2.new(.5, 0, 1, -2)
    btn.Position = UDim2.new(.5, 0, 0, 1)
    btn.AutoButtonColor = false
    btn.Text = c.Value.Name
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.TextColor3 = c._theme.Text
    btn.BackgroundColor3 = c._theme.Button
    MakeCorner(btn,6); MakeStroke(btn,1,.85)

    table.insert(c._connections, btn.MouseButton1Click:Connect(function()
        c._binding = true
        btn.Text = "Press any key..."
        btn.BackgroundColor3 = c._theme.Hover
    end))
    table.insert(c._connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or not c._binding then return end
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            c._binding = false
            c.Value = input.KeyCode
            btn.Text = c.Value.Name
            btn.BackgroundColor3 = c._theme.Button
            c:FireChanged(c.Value)
        end
    end))

    function c:Set(key)
        c.Value = key
        btn.Text = key and key.Name or "None"
        c:FireChanged(c.Value)
    end
    function c:Get() return c.Value end

    return c
end

--// Destroyers
function Window:Destroy()
    for _,t in ipairs(self._tabs or {}) do
        for _,c in ipairs(t._connections or {}) do pcall(function() c:Disconnect() end) end
        if t._page then t._page:Destroy() end
        if t._button then t._button:Destroy() end
    end
    for _,c in ipairs(self._connections or {}) do pcall(function() c:Disconnect() end) end
    if self._root then self._root:Destroy() end
end

function Library:SetTheme(name, def) ThemeManager:Set(name, def) end
function Library:UseTheme(name) self._theme = ThemeManager:Get(name) end
function Library:Destroy()
    for _,c in ipairs(self._connections or {}) do pcall(function() c:Disconnect() end) end
    if self._gui then self._gui:Destroy() end
end

return Library
