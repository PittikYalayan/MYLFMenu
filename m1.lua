-- // ⚡ MYLF | Hub ⚡  — mmenu8.lua tabanlı kusursuz iskelet
-- // Gerekenler:
-- // 1) Library: https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/mmenu8.lua
-- // 2) Features: https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features9.8.lua

--== Load Library & Features ==--
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/mmenu8.lua"))()
local features = loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features9.8.lua"))()

-- Emniyetli çağırıcı
local function safecall(fn, ...)
    if type(fn) == "function" then
        local ok, err = pcall(fn, ...)
        if not ok then warn("[features] error:", err) end
    end
end

--== Window (AutoShow=false: injekte olurken mouse’u çalmaz) ==--
local Window = Library:CreateWindow({
    Title    = "⚡ MYLF | Hub ⚡",
    Center   = true,
    AutoShow = true
})

--== Menü toggle (LeftControl) ==--
local UIS = game:GetService("UserInputService")
local MENU_KEY = Enum.KeyCode.LeftControl
local function ToggleMenu() if Library and Library.Toggle then Library:Toggle() elseif Library and Library.ToggleUI then Library:ToggleUI() end end
Library.ToggleKeybind = MENU_KEY
UIS.InputBegan:Connect(function(inp, gp)
    if not gp and inp.KeyCode == MENU_KEY then ToggleMenu() end
end)

--== Tabs ==--
local Tabs = {
    Rage     = Window:AddTab("🔥 Rage"),
    Visuals  = Window:AddTab("👁 Visuals"),
    Player   = Window:AddTab("🕴 Player"),
    Teleport = Window:AddTab("⚡ Teleport"),
    World    = Window:AddTab("🌍 World"),
    Settings = Window:AddTab("⚙ Settings"),
}

-- Helper: Toggle bağlama (OnChanged → features)
local function bindToggle(group, flag, text, fn)
    local t = group:AddToggle(flag, { Text = text, Default = false })
    if t and t.OnChanged then
        t:OnChanged(function(v) safecall(fn, v) end)
    end
    return t
end

----------------------------------------------------------------
-- 🔥 RAGE
----------------------------------------------------------------
do
    local g = Tabs.Rage:AddLeftGroupbox("Rage")
    bindToggle(g, "aimbot",           "Enable Aimbot",            features.ToggleAimbot)
    bindToggle(g, "headshotRedirect", "Force Headshot",           features.ToggleHeadshotRedirect)
    bindToggle(g, "fireRate",         "Hard Fire Rate",           features.ToggleFireRate)
    bindToggle(g, "silent",           "Silent Aim",               features.ToggleSilentAim)
    bindToggle(g, "magic",            "Magic Bullet (Fallback)",  features.ToggleMagicBullet)
    bindToggle(g, "killAura",         "☠️ Kill Aura",             features.ToggleKillAura)

    local g2 = Tabs.Rage:AddRightGroupbox("Recoil / Spread")
    bindToggle(g2, "norecoil", "No Recoil", features.ToggleNoRecoil)
    bindToggle(g2, "nospread", "No Spread", features.ToggleNoSpread)
end

----------------------------------------------------------------
-- 👁 VISUALS
----------------------------------------------------------------
do
    local g = Tabs.Visuals:AddLeftGroupbox("ESP / Visuals")
    bindToggle(g, "esp",             "Enable ESP",         features.ToggleESP)
    bindToggle(g, "glow",            "Glow / Highlight",   features.ToggleGlow)
    bindToggle(g, "skeleton",        "Skeleton",           features.ToggleSkeleton)
    bindToggle(g, "box2d",           "2D Box (Corner)",    features.ToggleBox2D)
    bindToggle(g, "box3d",           "3D Box",             features.ToggleBox3D)
    bindToggle(g, "tracers",         "Tracers",            features.ToggleTracers)
    bindToggle(g, "offscreen",       "Offscreen Arrows",   features.ToggleOffscreenArrows)
    bindToggle(g, "rainbowName",     "Rainbow Name",       features.ToggleRainbowName)

    local g2 = Tabs.Visuals:AddRightGroupbox("Hitbox")
    bindToggle(g2, "enemyBigHB", "🎯 Enemy Big Hitbox", features.ToggleEnemyBigHitbox)
end

----------------------------------------------------------------
-- 🕴 PLAYER
----------------------------------------------------------------
do
    local g = Tabs.Player:AddLeftGroupbox("Player Mods")
    bindToggle(g, "speed",     "Speed Boost (50)", features.ToggleSpeed)
    bindToggle(g, "fly",       "Fly (LCtrl down)", features.ToggleFly)
    bindToggle(g, "infjump",   "Infinite Jump",    features.ToggleInfiniteJump)
    bindToggle(g, "godmode",   "💀 Godmode",       features.ToggleGodmode)
    bindToggle(g, "hardInvis", "👻 Hard Invisible",features.ToggleHardInvisible)
    bindToggle(g, "noclip",    "NoClip",           features.ToggleNoclip)
end

----------------------------------------------------------------
-- ⚡ TELEPORT  (TP Key, Always Behind, Auto Farm Enemy + Offset Slider’lar)
----------------------------------------------------------------
local Options = rawget(getfenv(), "Options") or getgenv().Options or _G.Options or (Library and Library.Options)
do
    local g = Tabs.Teleport:AddLeftGroupbox("Teleport")

    bindToggle(g, "tpkey",      "Teleport (T Key)",           features.ToggleTeleport)            -- T'ye basınca TP (features içinde)
    bindToggle(g, "autoBehind", "⚡ Always Behind Enemy",      features.ToggleAutoBehind)         -- sürekli arkaya
    bindToggle(g, "autoTP",     "⚡ Auto Farm Enemy",          features.ToggleAutoTeleportToEnemy)

    -- TP Offset Slider’ları (X/Y/Z) – Options ile senkron, değişince features.SetTeleportOffset çağır
    local tpX = g:AddSlider("tpX", { Text = "X Offset", Min = -50, Max = 50, Default = 0, Rounding = 1 })
    local tpY = g:AddSlider("tpY", { Text = "Y Offset", Min = -50, Max = 50, Default = 0, Rounding = 1 })
    local tpZ = g:AddSlider("tpZ", { Text = "Z Offset", Min = 1, Max = 100, Default = 25, Rounding = 1 })

    local function pushOffsets()
        local x = (tpX and tpX.Value) or (Options and Options.tpX and Options.tpX.Value) or 0
        local y = (tpY and tpY.Value) or (Options and Options.tpY and Options.tpY.Value) or 0
        local z = (tpZ and tpZ.Value) or (Options and Options.tpZ and Options.tpZ.Value) or 25
        -- cache (features içi alan kullanıyorsan güncelle)
        features._tpX, features._tpY, features._tpZ = x, y, z
        safecall(features.SetTeleportOffset, x, y, z)
    end

    if tpX and tpX.OnChanged then tpX:OnChanged(pushOffsets) end
    if tpY and tpY.OnChanged then tpY:OnChanged(pushOffsets) end
    if tpZ and tpZ.OnChanged then tpZ:OnChanged(pushOffsets) end
    pushOffsets()

    -- Sağ tarafa Behind Enemy TP Offset + Manual tuş
    local gr = Tabs.Teleport:AddRightGroupbox("Behind Enemy")
    local behind = gr:AddSlider("behindOffset", { Text = "Behind Offset", Min = 2, Max = 20, Default = 4, Rounding = 0 })
    if behind and behind.OnChanged then
        behind:OnChanged(function(v) safecall(features.SetBehindOffset, math.floor(v + 0.5)) end)
    end
    gr:AddButton("TP Behind Nearest (Instant)", function()
        safecall(features.TeleportBehindNearest)  -- features tarafında varsa direkt çağır
    end)
end

----------------------------------------------------------------
-- 🌍 WORLD
----------------------------------------------------------------
do
    local g = Tabs.World:AddLeftGroupbox("MultiHook")
    bindToggle(g, "multiHook",       "🔒 AntiCheat Multi-Hook",      features.ToggleMultiHook)
    bindToggle(g, "multiHookSilent", "⚡ Multi-Hook Silent Aim",     features.ToggleMultiHook) -- aynı fonk kullanıyorsan birleşik
    bindToggle(g, "tinyHitbox",      "🛡️ Tiny Hitbox (Hard)",       features.ToggleTinyHitbox)

    local g2 = Tabs.World:AddRightGroupbox("World Tweaks")
    local tod = g2:AddSlider("timeofday", { Text = "Time of Day", Min = 0, Max = 24, Default = 12, Rounding = 0 })
    if tod and tod.OnChanged then tod:OnChanged(function(v) safecall(features.SetTimeOfDay, v) end) end
    local fov = g2:AddSlider("fovboost", { Text = "FOV Boost", Min = 70, Max = 120, Default = 90, Rounding = 0 })
    if fov and fov.OnChanged then fov:OnChanged(function(v) safecall(features.SetFOV, v) end) end
end

----------------------------------------------------------------
-- ⚙ SETTINGS (Tema, Menü Keybind, HUD)
----------------------------------------------------------------
do
    local g = Tabs.Settings:AddLeftGroupbox("Appearance")
    local theme = g:AddDropdown("theme", {
        Text = "Theme",
        Values = {"Dark-Red","Neo-Purple","Midnight"},
        Default = "Dark-Red"
    })
    if theme and theme.OnChanged then
        theme:OnChanged(function(v)
            if Library and Library.SetTheme then Library:SetTheme(v) end
        end)
    end

    local g2 = Tabs.Settings:AddRightGroupbox("Menu")
    g2:AddButton("Change Menu Key (click then press)", function()
        local txt = "Press any key..."
        if g2.SetSubtitle then g2:SetSubtitle(txt) end
        local conn
        conn = UIS.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                MENU_KEY = input.KeyCode
                Library.ToggleKeybind = MENU_KEY
                if g2.SetSubtitle then g2:SetSubtitle("Key: "..tostring(MENU_KEY)) end
                conn:Disconnect()
            end
        end)
    end)

    -- HUD seçenekleri (aşağıda gerçek HUD var)
    local hudGroup = Tabs.Settings:AddLeftGroupbox("HUD")
    local showHudT = hudGroup:AddToggle("showhud", { Text = "Show HUD", Default = true })
    if showHudT and showHudT.OnChanged then
        showHudT:OnChanged(function(v)
            local h = game:GetService("CoreGui"):FindFirstChild("MYLF_HUD")
            if h then h.Enabled = v end
        end)
    end
end

----------------------------------------------------------------
-- 🖥 Watermark / HUD (FPS | Ping | CPU ms | GPU ms) + Rainbow underline
----------------------------------------------------------------
do
    local CoreGui = game:GetService("CoreGui")
    local StarterGui = game:GetService("StarterGui")
    local Stats = game:GetService("Stats")
    local RunService = game:GetService("RunService")
    pcall(function() StarterGui:SetCore("TopbarEnabled", true) end)

    local sg = Instance.new("ScreenGui")
    sg.Name = "MYLF_HUD"
    sg.IgnoreGuiInset = true
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Global
    sg.DisplayOrder = 999999999
    sg.Parent = CoreGui

    -- kapsül
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 420, 0, 42)
    frame.Position = UDim2.new(0.6, 0, 0.08, 0)
    frame.BackgroundColor3 = Color3.fromRGB(24,24,28)

    local function corner(inst, r) local c=Instance.new("UICorner", inst); c.CornerRadius=UDim.new(0,r or 12) return c end
    local function stroke(inst, t, tr) local s=Instance.new("UIStroke", inst); s.Thickness=t or 1; s.Transparency=tr or .1; s.Color=Color3.fromRGB(255,255,255); return s end
    local function padding(inst, px) local p=Instance.new("UIPadding", inst); p.PaddingTop=UDim.new(0,px); p.PaddingBottom=UDim.new(0,px); p.PaddingLeft=UDim.new(0,px); p.PaddingRight=UDim.new(0,px) end
    corner(frame, 14); stroke(frame, 1, 0.16); padding(frame, 8)

    local text = Instance.new("TextLabel", frame)
    text.BackgroundTransparency = 1
    text.Font = Enum.Font.Gotham
    text.TextSize = 13
    text.TextColor3 = Color3.fromRGB(235,235,240)
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Size = UDim2.new(1, -16, 1, -16)
    text.Position = UDim2.new(0, 10, 0, 6)
    text.Text = "FPS: -- | Ping: -- (--%CV) | CPU: -- ms | GPU: -- ms"

    local underline = Instance.new("Frame", frame)
    underline.AnchorPoint = Vector2.new(0.5, 1)
    underline.Position = UDim2.new(0.5, 0, 1, -3)
    underline.Size = UDim2.new(1, -18, 0, 3)
    underline.BackgroundColor3 = Color3.fromRGB(255,255,255)
    corner(underline, 3)
    local grad = Instance.new("UIGradient", underline)
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromHSV(0.00,1,1)),
        ColorSequenceKeypoint.new(0.20, Color3.fromHSV(0.20,1,1)),
        ColorSequenceKeypoint.new(0.40, Color3.fromHSV(0.40,1,1)),
        ColorSequenceKeypoint.new(0.60, Color3.fromHSV(0.60,1,1)),
        ColorSequenceKeypoint.new(0.80, Color3.fromHSV(0.80,1,1)),
        ColorSequenceKeypoint.new(1.00, Color3.fromHSV(1.00,1,1)),
    }

    -- sürüklenebilir
    do
        local dragging, start, startPos = false, nil, nil
        frame.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging, start, startPos = true, i.Position, frame.Position
            end
        end)
        frame.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local d = i.Position - start
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end)
    end

    -- HUD updater (0.1s)
    local acc, frames = 0, 0
    local pingSamples, maxS = {}, 50
    local function pushPing(ms)
        pingSamples[#pingSamples+1] = ms
        if #pingSamples > maxS then table.remove(pingSamples,1) end
    end
    local function meanCV(t)
        if #t == 0 then return 0, 0 end
        local s=0; for _,v in ipairs(t) do s+=v end
        local m = s / #t
        local var=0; for _,v in ipairs(t) do var+=(v-m)*(v-m) end
        var = var / #t
        local sd = math.sqrt(var)
        local cv = (m ~= 0) and (sd/m*100) or 0
        return m, cv
    end

    RunService.RenderStepped:Connect(function(dt)
        grad.Rotation = (grad.Rotation + 80*dt) % 360
        acc += dt; frames += 1
        if acc >= 0.1 then
            local fps = math.max(1, math.floor(frames/acc + 0.5))
            local framems = (acc/frames)*1000
            frames, acc = 0, 0

            local pingMs = 0
            pcall(function()
                local net = Stats and Stats.Network
                local item = net and net.ServerStatsItem and net.ServerStatsItem["Data Ping"]
                if item then
                    local v = item:GetValue()
                    if typeof(v) == "number" then pingMs = v end
                end
            end)
            pushPing(pingMs)
            local mp, cv = meanCV(pingSamples)

            local cpuMs = framems
            local gpuMs = framems
            text.Text = string.format("FPS: %d | Ping: %.1f (%.0f%%CV) | CPU: %.1f ms | GPU: %.1f ms", fps, mp, cv, cpuMs, gpuMs)
        end
    end)
end

----------------------------------------------------------------
-- (Opsiyonel) İlk açılışta otomatik gösterme — AutoShow=false olduğu için:
----------------------------------------------------------------
-- ToggleMenu() -- istersen burada ilk açılışta göster

-- Bitti. UI hazır; features9.8 içindeki tüm fonksiyonlar bağlandı.
