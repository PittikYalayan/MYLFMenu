-- ⚡ MYLF | menutheme3 Loader + PRO Scanner (visible-on start + keybind) ⚡

--== Services
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats            = game:GetService("Stats")
local HttpService      = game:GetService("HttpService")
local LP = Players.LocalPlayer

--== Theme3 kütüphanesi
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/menutheme3.lua"))()

--== Window
local Window = Library:CreateWindow({
    Title   = "⚡ MYLF | Hub ⚡",
    Sub     = "menutheme3 • v8.3.5 layout + Scanner",
    Keybind = Enum.KeyCode.Insert, -- aç/kapa için varsayılan
    Theme   = "Default",
})

-- menü görünür gelsin:
task.defer(function()
    if Window.SetVisible then Window:SetVisible(true) end
end)

--== Tabs
local tPlayer   = Window:AddTab({ Text = "PLAYER" })
local tVisual   = Window:AddTab({ Text = "VISUALS" })
local tHUD      = Window:AddTab({ Text = "HUD" })
local tScanner  = Window:AddTab({ Text = "SCANNER" })
local tSettings = Window:AddTab({ Text = "SETTINGS" })

--== PLAYER (örnek)
do
    local sMove = tPlayer:AddSection("Movement")
    local tgSprint = sMove:AddToggle("autoSprint", { Text = "Auto Sprint", Default = false })
    tgSprint:OnChanged(function(v) print("[MYLF] AutoSprint:", v) end)

    local sStats = tPlayer:AddSection("Stats")
    local slWalk = sStats:AddSlider("walkspeed", { Text="WalkSpeed", Min=8, Max=32, Default=16, Rounding=0 })
    slWalk:OnChanged(function(v) print("[MYLF] WalkSpeed:", v) end)
end

--== VISUALS (tema seçici)
do
    local sTheme = tVisual:AddSection("Theme / UI")
    local ddTheme = sTheme:AddDropdown("theme", { Text="Theme", Values={"Default","Pink"}, Default="Default" })
    ddTheme:OnChanged(function(v)
        if Library.UseTheme then Library:UseTheme(v) end
        print("[MYLF] Theme:", v)
    end)
end

--== PERF BAR (draggable, slim, rainbow)
local function CreatePerfBar(opts)
    opts = opts or {}
    local W   = tonumber(opts.width) or 540
    local H   = tonumber(opts.height) or 24
    local HZ  = math.clamp(tonumber(opts.update_hz) or 4, 1, 30)
    local T   = 1 / HZ
    local anchor = opts.anchor or Vector2.new(1,0)
    local pos    = opts.position or UDim2.new(1,-14,0,14)

    local gui = Instance.new("ScreenGui")
    gui.Name = "MYLF_PerfBar"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.Parent = LP:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Name = "PerfBarRoot"
    frame.AnchorPoint = anchor
    frame.Position = pos
    frame.Size = UDim2.fromOffset(W, H)
    frame.BackgroundColor3 = Color3.fromRGB(28,28,32)
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui

    local c = Instance.new("UICorner", frame); c.CornerRadius = UDim.new(0, 8)
    local st= Instance.new("UIStroke", frame); st.Thickness = 1; st.Transparency = 0.85

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -12, 1, -12)
    label.Position = UDim2.new(0, 6, 0, 5)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.TextColor3 = Color3.fromRGB(235,235,240)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = "FPS: -- | Ping: -- | CPU: -- ms | GPU: -- ms"
    label.Parent = frame

    local bar = Instance.new("Frame")
    bar.AnchorPoint = Vector2.new(0.5,1)
    bar.Position = UDim2.new(0.5, 0, 1, -2)
    bar.Size = UDim2.new(1,-12,0,3)
    bar.BackgroundColor3 = Color3.fromRGB(255,255,255)
    bar.Parent = frame
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0,2)

    local grad = Instance.new("UIGradient", bar)
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,0,0)),
        ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255,165,0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255,255,0)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,255,0)),
        ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0,255,255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(0,128,255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(200,0,255)),
    }
    grad.Offset = Vector2.new(0,0)

    local function readPingMs()
        local ok,item = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"] end)
        if ok and item then
            local okS,str = pcall(function() return item:GetValueString() end)
            if okS and str then
                local n = tonumber((str:gsub(",", ".")):match("(%d+%.?%d*)"))
                if n then return n end
            end
            local okV,v = pcall(function() return item:GetValue() end)
            if okV and type(v)=="number" then return v end
        end
        return nil
    end
    local function tryReadGpuMs()
        local ok,val = pcall(function()
            local ps = Stats:FindFirstChild("PerformanceStats")
            if ps then
                for _,child in ipairs(ps:GetChildren()) do
                    if child.Name:lower():find("gpu") and child.GetValue then
                        local v = child:GetValue()
                        if type(v)=="number" then return v end
                    end
                end
            end
            return nil
        end)
        if ok then return val end
        return nil
    end

    local fpsSmooth, cpuSmooth, gpuSmooth = 60, 16.6, 16.6
    local gpuSupported = false
    local acc, gpuT = 0, 0

    local conn = RunService.RenderStepped:Connect(function(dt)
        grad.Offset = Vector2.new((grad.Offset.X + dt*0.5) % 1, 0)
        local instFPS = 1 / math.max(dt, 1/1000)
        fpsSmooth = fpsSmooth*0.90 + instFPS*0.10
        cpuSmooth = cpuSmooth*0.80 + (dt*1000)*0.20
        gpuT += dt
        if gpuT > 1.0 then
            gpuT = 0
            local gms = tryReadGpuMs()
            if type(gms)=="number" then gpuSupported=true; gpuSmooth = gpuSmooth*0.50 + gms*0.50 end
        end
        if not gpuSupported then gpuSmooth = gpuSmooth*0.90 + cpuSmooth*0.10 end
        acc += dt
        if acc >= T then
            local ping = readPingMs()
            label.Text = string.format("FPS: %d | Ping: %s | CPU: %.1f ms | GPU: %.1f ms",
                math.floor(fpsSmooth + 0.5),
                ping and (("%.1f ms"):format(ping)) or "--",
                cpuSmooth, gpuSmooth
            )
            acc = 0
        end
    end)

    local api = {}
    function api:Destroy() pcall(function() conn:Disconnect() end); gui:Destroy() end
    function api:SetVisible(b) frame.Visible = not not b end
    return api
end

--== HUD (label + mini widget toggle)
local hudFpsLbl, hudRamLbl
local perfWidget
do
    local sPerf = tHUD:AddSection("Performance")
    hudFpsLbl = sPerf:AddLabel("FPS: --")
    hudRamLbl = sPerf:AddLabel("RAM: -- MB")

    local tgMini = sPerf:AddToggle("miniPerf", { Text="Show Top-Right Perf Bar", Default=true })
    tgMini:OnChanged(function(v)
        if v and not perfWidget then
            perfWidget = CreatePerfBar({ width = 540, height = 24, update_hz = 4, anchor = Vector2.new(1,0), position = UDim2.new(1,-14,0,14) })
        elseif (not v) and perfWidget then
            perfWidget:Destroy()
            perfWidget = nil
        end
    end)

    local acc, upd = 0, 0.25
    RunService.RenderStepped:Connect(function(dt)
        acc += dt
        if acc >= upd then
            local fps = math.floor(1 / math.max(dt, 1/1000) + 0.5)
            local mem = Stats and Stats:GetTotalMemoryUsageMb() or 0
            if hudFpsLbl and hudFpsLbl._root then hudFpsLbl._root.Text = "FPS: "..fps end
            if hudRamLbl and hudRamLbl._root then hudRamLbl._root.Text = "RAM: "..math.floor(mem+0.5).." MB" end
            acc = 0
        end
    end)
    task.defer(function() tgMini:Set(true) end)
end

--== SCANNER (PRO)
do
    local sScan = tScanner:AddSection("Scanner")
    local searchLbl = sScan:AddLabel("Search: (name/class/path)")
    -- kendi TextBox'ımız (menutheme3'te TextBox yoksa custom ekliyoruz)
    local host = sScan._inner or sScan._frame or tScanner._page -- en mantıklı parent
    local theme = Library._theme or {Panel=Color3.fromRGB(32,32,36), Text=Color3.fromRGB(235,235,240), Hover=Color3.fromRGB(40,40,46), Button=Color3.fromRGB(40,40,48)}

    local ui = Instance.new("Frame", host); ui.Name="ScannerUI"; ui.Size = UDim2.new(1, -6, 0, 220); ui.BackgroundColor3 = theme.Panel
    local cr = Instance.new("UICorner", ui); cr.CornerRadius = UDim.new(0,8)
    local st = Instance.new("UIStroke", ui); st.Thickness = 1; st.Transparency = .88
    local pad = Instance.new("UIPadding", ui); pad.PaddingTop=UDim.new(0,8); pad.PaddingLeft=UDim.new(0,8); pad.PaddingRight=UDim.new(0,8); pad.PaddingBottom=UDim.new(0,8)

    -- üst bar: sekmeler + arama + refresh + auto
    local top = Instance.new("Frame", ui); top.BackgroundTransparency = 1; top.Size = UDim2.new(1,0,0,28)

    local function mkTabBtn(txt, x)
        local b = Instance.new("TextButton", top); b.Size=UDim2.new(0,90,1,-4); b.Position=UDim2.new(0,x,0,2)
        b.AutoButtonColor=false; b.Font=Enum.Font.GothamSemibold; b.TextSize=13; b.TextColor3=theme.Text
        b.Text=txt; b.BackgroundColor3 = theme.Button; local c=Instance.new("UICorner", b); c.CornerRadius=UDim.new(0,6)
        b.MouseEnter:Connect(function() b.BackgroundColor3 = theme.Hover end)
        b.MouseLeave:Connect(function() b.BackgroundColor3 = theme.Button end)
        return b
    end

    local tabPlayers  = mkTabBtn("Players", 0)
    local tabWorld    = mkTabBtn("Workspace", 96)
    local tabBackpack = mkTabBtn("Backpack", 192)

    local tb = Instance.new("TextBox", top)
    tb.PlaceholderText = "Ara: ör. 'sword', 'Tool', 'Workspace.Model.Part'..."
    tb.Font = Enum.Font.Gotham; tb.TextSize = 13; tb.TextColor3 = theme.Text
    tb.Size = UDim2.new(1,-360,1,-4); tb.Position = UDim2.new(0,290,0,2)
    tb.BackgroundColor3 = theme.Button; tb.ClearTextOnFocus=false
    local tbc = Instance.new("UICorner", tb); tbc.CornerRadius = UDim.new(0,6)

    local btnRefresh = Instance.new("TextButton", top)
    btnRefresh.Size=UDim2.new(0,80,1,-4); btnRefresh.Position=UDim2.new(1,-168,0,2); btnRefresh.AutoButtonColor=false
    btnRefresh.Text="Refresh"; btnRefresh.Font=Enum.Font.GothamSemibold; btnRefresh.TextSize=13; btnRefresh.TextColor3=theme.Text; btnRefresh.BackgroundColor3=theme.Button
    Instance.new("UICorner", btnRefresh).CornerRadius=UDim.new(0,6)

    local autoToggle = Instance.new("TextButton", top)
    autoToggle.Size=UDim2.new(0,80,1,-4); autoToggle.Position=UDim2.new(1,-84,0,2); autoToggle.AutoButtonColor=false
    autoToggle.Text="Auto: OFF"; autoToggle.Font=Enum.Font.GothamSemibold; autoToggle.TextSize=13; autoToggle.TextColor3=theme.Text; autoToggle.BackgroundColor3=theme.Button
    Instance.new("UICorner", autoToggle).CornerRadius=UDim.new(0,6)

    -- liste alanı
    local list = Instance.new("ScrollingFrame", ui); list.Position = UDim2.new(0,0,0,36); list.Size = UDim2.new(1,0,1,-76)
    list.BackgroundTransparency = 1; list.CanvasSize = UDim2.new(0,0,0,0); list.ScrollBarThickness = 6
    local layout = Instance.new("UIListLayout", list); layout.Padding = UDim.new(0,6)

    local bottom = Instance.new("Frame", ui); bottom.BackgroundTransparency=1; bottom.Size=UDim2.new(1,0,0,34); bottom.Position = UDim2.new(0,0,1,-34)

    local lblCount = Instance.new("TextLabel", bottom)
    lblCount.BackgroundTransparency=1; lblCount.Font=Enum.Font.Gotham; lblCount.TextSize=13; lblCount.TextColor3=theme.Text
    lblCount.TextXAlignment = Enum.TextXAlignment.Left; lblCount.Size = UDim2.new(.5, -6, 1, 0); lblCount.Position = UDim2.new(0,0,0,0)
    lblCount.Text = "0 sonuç"

    local function mkAction(txt, x, cb)
        local b = Instance.new("TextButton", bottom); b.Size=UDim2.new(0,120,1,-4); b.Position=UDim2.new(1,-x,0,2)
        b.AutoButtonColor=false; b.Text=txt; b.Font=Enum.Font.GothamSemibold; b.TextSize=13; b.TextColor3=theme.Text; b.BackgroundColor3=theme.Button
        Instance.new("UICorner", b).CornerRadius=UDim.new(0,6)
        b.MouseButton1Click:Connect(function() if cb then cb() end end)
        return b
    end

    local currentSel = nil
    local highlight : Highlight? = nil
    local trackBBG : BillboardGui? = nil
    local function clearHighlight()
        if highlight then highlight:Destroy() highlight=nil end
        if trackBBG then trackBBG:Destroy() trackBBG=nil end
    end

    -- Actions
    mkAction("Highlight", 372, function()
        clearHighlight()
        if currentSel and currentSel:IsDescendantOf(game) then
            highlight = Instance.new("Highlight")
            highlight.FillTransparency = 0.75
            highlight.OutlineTransparency = 0
            highlight.OutlineColor = Color3.fromRGB(80,160,255)
            -- Model ise modele, değilse parent model/part’a uygula
            local target = currentSel
            if target:IsA("Model") then
                highlight.Adornee = target
            elseif target:IsA("BasePart") then
                highlight.Adornee = target
            else
                local p = currentSel:FindFirstAncestorOfClass("Model") or currentSel:FindFirstAncestorWhichIsA("BasePart")
                highlight.Adornee = p
            end
            highlight.Parent = workspace
        end
    end)

    mkAction("Teleport", 248, function()
        if not (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")) then return end
        if not currentSel then return end
        local hrp = LP.Character.HumanoidRootPart
        local pos
        if currentSel:IsA("BasePart") then pos = currentSel.Position
        elseif currentSel:IsA("Model") and currentSel.PrimaryPart then pos = currentSel.PrimaryPart.Position end
        if pos then
            hrp.CFrame = CFrame.new(pos + Vector3.new(0, 4, 0))
        end
    end)

    mkAction("Copy Path", 124, function()
        if not currentSel then return end
        local function fullPath(i)
            local parts = {}
            local node = i
            while node and node ~= game do
                table.insert(parts, 1, node.Name)
                node = node.Parent
            end
            return "game."..table.concat(parts, ".")
        end
        local path = fullPath(currentSel)
        if setclipboard then pcall(setclipboard, path) end
        print("[MYLF] Path:", path)
    end)

    -- sekme state
    local MODE = "Players"  -- Players / Workspace / Backpack
    tabPlayers.BackgroundColor3 = Color3.fromRGB(64,64,100)

    local function setMode(m)
        MODE = m
        tabPlayers.BackgroundColor3  = theme.Button
        tabWorld.BackgroundColor3    = theme.Button
        tabBackpack.BackgroundColor3 = theme.Button
        if m=="Players" then tabPlayers.BackgroundColor3  = Color3.fromRGB(64,64,100)
        elseif m=="Workspace" then tabWorld.BackgroundColor3= Color3.fromRGB(64,64,100)
        else tabBackpack.BackgroundColor3= Color3.fromRGB(64,64,100) end
    end
    tabPlayers.MouseButton1Click:Connect(function() setMode("Players") end)
    tabWorld.MouseButton1Click:Connect(function() setMode("Workspace") end)
    tabBackpack.MouseButton1Click:Connect(function() setMode("Backpack") end)

    -- satır oluşturucu
    local function addRow(item, text, dist)
        local b = Instance.new("TextButton", list)
        b.AutoButtonColor = false
        b.Size = UDim2.new(1,-6,0,26)
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.Text = text .. (dist and ("   ·  "..tostring(math.floor(dist)).."m") or "")
        b.Font = Enum.Font.Gotham
        b.TextSize = 13
        b.TextColor3 = theme.Text
        b.BackgroundColor3 = theme.Button
        local c = Instance.new("UICorner", b); c.CornerRadius = UDim.new(0,6)
        b.MouseEnter:Connect(function() b.BackgroundColor3 = theme.Hover end)
        b.MouseLeave:Connect(function()
            b.BackgroundColor3 = (currentSel == item) and Color3.fromRGB(80,160,255) or theme.Button
        end)
        b.MouseButton1Click:Connect(function()
            currentSel = item
            -- seçileni vurgula
            for _,child in ipairs(list:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = theme.Button
                end
            end
            b.BackgroundColor3 = Color3.fromRGB(80,160,255)
        end)
    end

    local MAX_ROWS = 200
    local function wipeList()
        for _,ch in ipairs(list:GetChildren()) do
            if ch:IsA("TextButton") then ch:Destroy() end
        end
        list.CanvasSize = UDim2.new(0,0,0,0)
        currentSel = nil
        clearHighlight()
    end

    local function distTo(item)
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        local p
        if item:IsA("BasePart") then p = item.Position
        elseif item:IsA("Model") and item.PrimaryPart then p = item.PrimaryPart.Position end
        if p then return (p - hrp.Position).Magnitude end
        return nil
    end

    local function scanPlayers(q)
        local results = {}
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP and pl.Character then
                local name = pl.Name:lower()
                if (not q) or name:find(q, 1, true) then
                    table.insert(results, pl.Character)
                end
            end
        end
        return results
    end

    local function scanBackpack(q)
        local results = {}
        local bp = LP:FindFirstChild("Backpack")
        if not bp then return results end
        for _,it in ipairs(bp:GetChildren()) do
            local nm = it.Name:lower()
            local cls = it.ClassName:lower()
            if (not q) or nm:find(q,1,true) or cls:find(q,1,true) then
                table.insert(results, it)
            end
        end
        return results
    end

    local function scanWorkspace(q)
        local results = {}
        local function okType(x)
            return x:IsA("Model") or x:IsA("BasePart") or x:IsA("Tool")
        end
        local n = 0
        for _,x in ipairs(workspace:GetDescendants()) do
            if okType(x) then
                local nm = x.Name:lower()
                local cls = x.ClassName:lower()
                -- path eşleşmesi için:
                local pathOk = false
                if q then
                    local node=x; local pieces={}
                    while node and node~=game do table.insert(pieces,1,node.Name); node=node.Parent end
                    local path=("game."..table.concat(pieces,".")):lower()
                    pathOk = path:find(q,1,true) ~= nil
                end
                if (not q) or nm:find(q,1,true) or cls:find(q,1,true) or pathOk then
                    table.insert(results, x)
                    n = n + 1
                    if n>=1500 then break end -- aşırı derin oyunlar için sert limit
                end
            end
        end
        return results
    end

    local function refresh()
        wipeList()
        local q = tb.Text
        q = (q and q ~= "") and q:lower() or nil

        local items = {}
        if MODE=="Players" then items = scanPlayers(q)
        elseif MODE=="Backpack" then items = scanBackpack(q)
        else items = scanWorkspace(q) end

        -- mesafeye göre sırala (varsa)
        table.sort(items, function(a,b)
            local da, db = distTo(a) or math.huge, distTo(b) or math.huge
            return da < db
        end)

        local shown = 0
        for _,it in ipairs(items) do
            local d = distTo(it)
            local label = string.format("[%s] %s", it.ClassName, it.Name)
            addRow(it, label, d)
            shown += 1
            if shown >= MAX_ROWS then break end
        end
        lblCount.Text = string.format("%d sonuç%s", shown, (#items>shown and " (limit)" or ""))
        -- canvas yüksekliğini ayarla
        list.CanvasSize = UDim2.new(0, 0, 0, shown * 32)
    end

    btnRefresh.MouseButton1Click:Connect(refresh)
    tb.FocusLost:Connect(function() refresh() end)

    local autoOn = false
    local autoT = 0
    local autoInterval = 1.0
    autoToggle.MouseButton1Click:Connect(function()
        autoOn = not autoOn
        autoToggle.Text = "Auto: " .. (autoOn and "ON" or "OFF")
    end)

    tabPlayers.MouseButton1Click:Connect(refresh)
    tabWorld.MouseButton1Click:Connect(refresh)
    tabBackpack.MouseButton1Click:Connect(refresh)

    RunService.RenderStepped:Connect(function(dt)
        if autoOn then
            autoT += dt
            if autoT >= autoInterval then
                autoT = 0
                refresh()
            end
        end
    end)

    -- ilk tarama
    task.defer(refresh)
end

--== SETTINGS (Menu Toggle Keybind + görünürlük garantisi)
do
    local sKb = tSettings:AddSection("Keybinds")
    local kbMenu = sKb:AddKeybind("menuToggle", { Text="Menu Toggle", Default=Enum.KeyCode.Insert })
    kbMenu:OnChanged(function(key)
        if Window.SetKeybind then Window:SetKeybind(key) end
        print("[MYLF] MenuKey:", key)
    end)

    -- ekstra: global yakalama (Library'nin keybind’i çalışmazsa fallback)
    UserInputService.InputBegan:Connect(function(input,gpe)
        if gpe then return end
        local current = kbMenu:Get() or Enum.KeyCode.Insert
        if input.KeyCode == current then
            if Window.SetVisible then Window:SetVisible(not Window.Visible) end
        end
    end)
end

-- hoş geldin
pcall(function() if Library.Notify then Library:Notify("MYLF menutheme3 + PRO Scanner hazır 🚀", 3) end end)
