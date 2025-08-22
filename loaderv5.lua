-- ⚡ MYLF | Hub ⚡ — LOADER (menu hide fix + sadece var olanlar)

local Library      = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

local features = loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features.lua"))()

-- Pencere: AutoShow=false (inject anında mouse’u çalmaz)
local Window = Library:CreateWindow({ Title = "⚡ MYLF | Hub ⚡", Center = true, AutoShow = false })

-- Menü toggle (sağlam fallback)
local UIS = game:GetService("UserInputService")
local MENU_KEY = Enum.KeyCode.LeftShift
local MenuOpen = false
local function ToggleMenu()
    MenuOpen = not MenuOpen
    Library:Toggle()  -- Linoria’nın kendi toggle’ı
end

-- Linoria’ya yine key atıyoruz; olmazsa aşağıdaki InputBegan çalışır
Library.ToggleKeybind = MENU_KEY
UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == MENU_KEY then
        ToggleMenu()
    end
end)

-- ==== Sekmeler (sadece mevcut özellikler) ====
local Tabs = {
    Rage     = Window:AddTab("🔥 Rage"),
    Visuals  = Window:AddTab("👁 Visuals"),
    Player   = Window:AddTab("🕴 Player"),
    Teleport = Window:AddTab("⚡ Teleport"),
    World    = Window:AddTab("🌍 World"),
    Misc     = Window:AddTab("🛠 Misc"),
    Settings = Window:AddTab("⚙ Settings"),
}

local function bindToggle(group, flag, text, fn)
    group:AddToggle(flag, { Text = text, Default = false })
        :OnChanged(function(v) if type(fn)=="function" then pcall(fn, v) end end)
end

-- Rage
do
    local g = Tabs.Rage:AddLeftGroupbox("Rage")
    bindToggle(g, "aimbot",   "Enable Aimbot",  features.ToggleAimbot)     -- Aimbot eski sade sürüm
    bindToggle(g, "silent",   "Silent Aim",     features.ToggleSilentAim)
    bindToggle(g, "rapid",    "Rapid Fire",     features.ToggleRapidFire)
    bindToggle(g, "killaura", "Kill Aura",      features.ToggleKillAura)
end

-- Visuals
do
    local g = Tabs.Visuals:AddLeftGroupbox("Visuals")
    bindToggle(g, "esp", "Enable ESP", features.ToggleESP)  -- tek toggle; içerde join/respawn takip ediyor
end

-- Player
do
    local g = Tabs.Player:AddLeftGroupbox("Player Mods")
    bindToggle(g, "speed",     "Speed Boost (50)", features.ToggleSpeed)   -- 50↔16
    bindToggle(g, "fly",       "Fly (LCtrl down)", features.ToggleFly)     -- iniş: LeftControl
    bindToggle(g, "infjump",   "Infinite Jump",    features.ToggleInfiniteJump)
    bindToggle(g, "god",       "God Mode",         features.ToggleGodmode)
    bindToggle(g, "invisible", "Invisible",        features.ToggleInvisible)
end

-- Teleport
do
    local g = Tabs.Teleport:AddLeftGroupbox("Teleport")
    bindToggle(g, "tpkey", "Teleport (T Key)", features.ToggleTeleport)
end

-- World
do
    local g = Tabs.World:AddLeftGroupbox("World")
    bindToggle(g, "noclip", "NoClip", features.ToggleNoclip) -- restore’lu
end

-- Misc
do
    local g = Tabs.Misc:AddLeftGroupbox("Misc")
    bindToggle(g, "inspector", "Tool Inspector", features.ToggleInspector)
end

-- Settings / Tema
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
ThemeManager:SetFolder("MYLFHub")
SaveManager:SetFolder("MYLFHub/saves")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

-- Tema: siyah-kırmızı
local th = ThemeManager:CurrentTheme()
th.Accent     = Color3.fromRGB(230, 0, 35)
th.Background = Color3.fromRGB(20, 20, 20)
th.Outline    = Color3.fromRGB(180, 0, 0)
