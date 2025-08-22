-- ⚡ MYLF | Hub ⚡
-- Loader (features.lua'ya bağlı)

-- Lib yükleme
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

-- Features
local features = loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features.lua"))()

-- === Ana Pencere ===
local Window = Library:CreateWindow({
    Title = "⚡ MYLF | Hub ⚡",
    Center = true,
    AutoShow = true,
})

-- === Sekmeler ===
local Tabs = {
    Legit    = Window:AddTab("🔍 Legit"),
    Rage     = Window:AddTab("🔥 Rage"),
    Visuals  = Window:AddTab("👁 Visuals"),
    Player   = Window:AddTab("🕴 Player"),
    Teleport = Window:AddTab("⚡ Teleport"),
    World    = Window:AddTab("🌍 World"),
    Misc     = Window:AddTab("🛠 Misc"),
    Settings = Window:AddTab("⚙ Settings"),
}

-- === Legit ===
local AimbotGroup = Tabs.Legit:AddLeftGroupbox("Aimbot")
AimbotGroup:AddToggle("aimbot", { Text = "Enable Aimbot", Default = false }):OnChanged(features.ToggleAimbot)
AimbotGroup:AddToggle("rcs", { Text = "No Recoil", Default = false }):OnChanged(features.ToggleNoRecoil)
AimbotGroup:AddToggle("nospread", { Text = "No Spread", Default = false }):OnChanged(features.ToggleNoSpread)

-- === Rage ===
local RageGroup = Tabs.Rage:AddLeftGroupbox("Rage")
RageGroup:AddToggle("silent", { Text = "Silent Aim", Default = false }):OnChanged(features.ToggleSilentAim)
RageGroup:AddToggle("rapid", { Text = "Rapid Fire", Default = false }):OnChanged(features.ToggleRapidFire)

-- === Visuals ===
local VisualsGroup = Tabs.Visuals:AddLeftGroupbox("Visuals")
VisualsGroup:AddToggle("esp", { Text = "ESP", Default = false }):OnChanged(features.ToggleESP)
VisualsGroup:AddToggle("chams", { Text = "Chams", Default = false }):OnChanged(features.ToggleChams)
VisualsGroup:AddToggle("fov", { Text = "FOV Circle", Default = false }):OnChanged(features.ToggleFOVCircle)

-- === Player ===
local PlayerGroup = Tabs.Player:AddLeftGroupbox("Player Mods")
PlayerGroup:AddToggle("fly", { Text = "Fly", Default = false }):OnChanged(features.ToggleFly)
PlayerGroup:AddToggle("speed", { Text = "Speed Hack", Default = false }):OnChanged(features.ToggleSpeed)
PlayerGroup:AddToggle("god", { Text = "God Mode", Default = false }):OnChanged(features.ToggleGodMode)

-- === Teleport ===
local TeleportGroup = Tabs.Teleport:AddLeftGroupbox("Teleport")
TeleportGroup:AddButton("TP to Spawn", features.TeleportToSpawn)
TeleportGroup:AddButton("TP to Random", features.TeleportRandom)

-- === World ===
local WorldGroup = Tabs.World:AddLeftGroupbox("World")
WorldGroup:AddToggle("fullbright", { Text = "FullBright", Default = false }):OnChanged(features.ToggleFullBright)
WorldGroup:AddToggle("ncllip", { Text = "NoClip", Default = false }):OnChanged(features.ToggleNoClip)

-- === Misc ===
local MiscGroup = Tabs.Misc:AddLeftGroupbox("Misc")
MiscGroup:AddToggle("bhop", { Text = "Bunny Hop", Default = false }):OnChanged(features.ToggleBhop)
MiscGroup:AddToggle("antiafk", { Text = "Anti-AFK", Default = false }):OnChanged(features.ToggleAntiAFK)

-- === Settings ===
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

ThemeManager:SetFolder("MYLFHub")
SaveManager:SetFolder("MYLFHub/saves")

SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

-- 🔑 Menü toggle key
Library.ToggleKeybind = Enum.KeyCode.LeftShift

-- === Tema ===
local theme = ThemeManager:CurrentTheme()
theme.Accent = Color3.fromRGB(230, 0, 35)        -- kırmızı vurgu
theme.Background = Color3.fromRGB(20, 20, 20)    -- koyu arka plan
theme.Outline = Color3.fromRGB(180, 0, 0)        -- siyah/kırmızı kenar
