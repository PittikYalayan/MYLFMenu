-- ⚡ MYLF | menutheme3 Loader (v8.3.5 style) ⚡
-- direkt çalıştır: loadstring(game:HttpGet("RAW_URL_BU_DOSYA.lua"))()

--== Services
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats            = game:GetService("Stats")
local LP = Players.LocalPlayer

--== Theme3 kütüphanesi
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/menutheme3.lua"))()

--== Window
local Window = Library:CreateWindow({
    Title   = "⚡ MYLF | Hub ⚡",
    Sub     = "menutheme3 • v8.3.5 layout",
    Keybind = Enum.KeyCode.RightShift,
    Theme   = "Default",
})

--== Tabs
local tPlayer   = Window:AddTab({ Text = "PLAYER" })
local tVisual   = Window:AddTab({ Text = "VISUALS" })
local tHUD      = Window:AddTab({ Text = "HUD" })
local tScanner  = Window:AddTab({ Text = "SCANNER" })
local tSettings = Window:AddTab({ Text = "SETTINGS" })

--== PLAYER
do
    local sMove = tPlayer:AddSection("Movement")
    local tgSprint = sMove:AddToggle("autoSprint", { Text = "Auto Sprint", Default = false })
    tgSprint:OnChanged(function(v) print("[MYLF] AutoSprint:", v) end)

    local sStats = tPlayer:AddSection("Stats")
    local slWalk = sStats:AddSlider("walkspeed", { Text="WalkSpeed", Min=8, Max=32, Default=16, Rounding=0 })
    slWalk:OnChanged(function(v) print("[MYLF] WalkSpeed:", v) end)

    local slJump = sStats:AddSlider("jumppower", { Text="JumpPower", Min=30, Max=150, Default=50, Rounding=0 })
    slJump:OnChanged(function(v) print("[MYLF] JumpPower:", v) end)
end

--== VISUALS
do
    local sTheme = tVisual:AddSection("Theme / UI")
    local ddTheme = sTheme:AddDropdown("theme", { Text="Theme", Values={"Default","Pink"}, Default="Default" })
    ddTheme:OnChanged(function(v)
        if Library.UseTheme then Library:UseTheme(v) end
        print("[MYLF] Theme:", v)
    end)

    local sOverlay = tVisual:AddSection("Overlay")
    local tgOutline = sOverlay:AddToggle("uiOutline", { Text="Outline UI", Default=true })
    tgOutline:OnChanged(function(v) print("[MYLF] UI Outline:", v) end)
end

--== PERF BAR (draggable, slim, rainbow)  — ayrı fonksiyon
local function CreatePerfBar(opts)
    opts = opts or {}
    local W   = tonumber(opts.width) or 520
    local H   = tonumber(opts.height) or 24
    local HZ  = math.clamp(tonumber(opts.update_hz) or 4, 1, 30)  -- güncelleme hızı
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
            perfWidget = CreatePerfBar({
                width = 540, height = 24, update_hz = 4,
                anchor = Vector2.new(1,0), position = UDim2.new(1,-14,0,14)
            })
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

    -- başlangıçta açık
    task.defer(function() tgMini:Set(true) end)
end

--== SCANNER (placeholder)
do
    local sScan = tScanner:AddSection("Scanner")
    sScan:AddLabel("Scanner burada olacak (sen dolduracaksın).")
end

--== SETTINGS
do
    local sKb = tSettings:AddSection("Keybinds")
    local kbMenu = sKb:AddKeybind("menuToggle", { Text="Menu Toggle", Default=Enum.KeyCode.RightShift })
    kbMenu:OnChanged(function(key)
        if Window.SetKeybind then Window:SetKeybind(key) end
        print("[MYLF] MenuKey:", key)
    end)
end

-- hoş geldin
pcall(function() if Library.Notify then Library:Notify("MYLF menutheme3 loader hazır 🚀", 3) end end)
