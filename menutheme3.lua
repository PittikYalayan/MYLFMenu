-- ⚡ MYLF PerfBar (draggable, slim, rainbow) ⚡
-- Kullanım:
--   local perf = MYLF_CreatePerfBar({ -- hepsi opsiyonel
--       anchor = Vector2.new(1,0),                   -- sağ-üst
--       position = UDim2.new(1,-14,0,14),           -- ekranda konum
--       width = 520, height = 28,                   -- ince bar
--       update_hz = 4,                              -- 4 Hz -> 0.25s
--   })
--   -- perf:Destroy()  -- kapatmak istersen

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local Stats            = game:GetService("Stats")

local LP = Players.LocalPlayer

local function clamp(v,a,b) return math.max(a, math.min(b, v)) end

local function readPingMs()
    -- Roblox ping yolları executora göre değişebilir; hepsini deneriz.
    local ok,item = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"] end)
    if ok and item then
        local okS, s = pcall(function() return item:GetValueString() end)
        if okS and s then
            local num = tonumber((s:gsub(",", ".")):match("(%d+%.?%d*)"))
            if num then return num end
        end
        local okV, v = pcall(function() return item:GetValue() end)
        if okV and type(v)=="number" then return v end
    end
    return nil
end

local function tryReadGpuMs()
    -- çoğu ortamda GPU ms exposed değil; varsa yakala, yoksa nil döndür.
    -- ileride özel executor API’n varsa buraya entegre edersin.
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

local function MYLF_CreatePerfBar(opts)
    opts = opts or {}
    local W   = tonumber(opts.width) or 520
    local H   = tonumber(opts.height) or 28
    local HZ  = clamp(tonumber(opts.update_hz) or 4, 1, 30)      -- 1–30 Hz
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

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 1
    stroke.Transparency = 0.85

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -12, 1, -12)
    label.Position = UDim2.new(0, 6, 0, 6)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.TextColor3 = Color3.fromRGB(235,235,240)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = "FPS: -- | Ping: -- (CV: --%) | CPU: -- ms | GPU: -- ms"
    label.Parent = frame

    local bar = Instance.new("Frame")
    bar.AnchorPoint = Vector2.new(0.5,1)
    bar.Position = UDim2.new(0.5, 0, 1, -2)
    bar.Size = UDim2.new(1,-12,0,3)
    bar.BackgroundColor3 = Color3.fromRGB(255,255,255)
    bar.Parent = frame
    local barCorner = Instance.new("UICorner", bar)
    barCorner.CornerRadius = UDim.new(0,2)

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

    -- smooting + ping CV buffer
    local fpsSmooth = 60
    local cpuSmooth = 16.6
    local gpuSmooth = 16.6
    local acc = 0
    local pingBuf, pingN = {}, 0
    local pingGpuTimer = 0
    local gpuSupported = false

    local function pushPing(p)
        if not p then return end
        pingBuf[#pingBuf+1] = p
        if #pingBuf > 60 then table.remove(pingBuf,1) end
    end

    local function pingCV()
        local n = #pingBuf
        if n < 5 then return nil end
        local sum = 0
        for _,x in ipairs(pingBuf) do sum = sum + x end
        local mean = sum / n
        if mean <= 0 then return nil end
        local var = 0
        for _,x in ipairs(pingBuf) do
            local d = x - mean
            var = var + d*d
        end
        var = var / (n-1)
        local sd = math.sqrt(var)
        return (sd / mean) * 100
    end

    -- ana döngü
    local con = RunService.RenderStepped:Connect(function(dt)
        -- rainbow akışı
        grad.Offset = Vector2.new((grad.Offset.X + dt*0.5) % 1, 0)

        -- smooth fps/cpu
        local instFPS = 1 / math.max(dt, 1/1000)
        fpsSmooth = fpsSmooth*0.90 + instFPS*0.10
        local cpuMs   = dt*1000
        cpuSmooth = cpuSmooth*0.80 + cpuMs*0.20

        -- GPU ms: varsa oku (nadiren exposed), yoksa CPU’ya yakın tahmin
        pingGpuTimer = pingGpuTimer + dt
        if pingGpuTimer > 1.0 then
            pingGpuTimer = 0
            local gms = tryReadGpuMs()
            if type(gms)=="number" then gpuSupported = true; gpuSmooth = gpuSmooth*0.50 + gms*0.50 end
        end
        if not gpuSupported then
            -- tahmini: cpuSmooth’a yakın tut
            gpuSmooth = gpuSmooth*0.90 + cpuSmooth*0.10
        end

        acc = acc + dt
        if acc >= T then
            local ping = readPingMs()
            pushPing(ping)
            local cv = pingCV()
            local txt = string.format(
                "FPS: %d | Ping: %s%s | CPU: %.1f ms | GPU: %.1f ms",
                math.floor(fpsSmooth + 0.5),
                ping and string.format("%.1f ms", ping) or "--",
                cv and string.format(" (%.0f%% CV)", cv) or "",
                cpuSmooth,
                gpuSmooth
            )
            label.Text = txt
            acc = 0
        end
    end)

    local api = {}
    function api:Destroy()
        pcall(function() con:Disconnect() end)
        gui:Destroy()
    end
    function api:SetPosition(u2) frame.Position = u2 end
    function api:SetAnchor(v2) frame.AnchorPoint = v2 end
    function api:SetSize(w,h) frame.Size = UDim2.fromOffset(w,h or H) end

    return api
end

-- dışarı export et
getgenv().MYLF_CreatePerfBar = MYLF_CreatePerfBar

-- otomatik başlatmak istersen şunu aç:
-- return MYLF_CreatePerfBar()
-- (mylf.lua veya loader’ının en altına)
local perf = MYLF_CreatePerfBar({
  anchor = Vector2.new(1,0),
  position = UDim2.new(1,-14,0,14),
  width = 520, height = 28,
  update_hz = 4,
})
