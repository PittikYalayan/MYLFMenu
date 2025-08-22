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
    Legit    = Window:AddTab("Legit"),
    Rage     = Window:AddTab("Rage"),
    Visuals  = Window:AddTab("Visuals"),
    Player   = Window:AddTab("Player"),
    Teleport = Window:AddTab("Teleport"),
    World    = Window:AddTab("World"),
    Misc     = Window:AddTab("Misc"),
    Settings = Window:AddTab("Settings"),
}

-- === Legit ===
local AimbotGroup = Tabs.Legit:AddLeftGroupbox("Aimbot")
AimbotGroup:AddToggle("aimbot", { Text = "Enable Aimbot", Default = false }):OnChanged(features.ToggleAimbot)

-- === Rage ===
local RageGroup = Tabs.Rage:AddLeftGroupbox("Rage")
RageGroup:AddToggle("silent", { Text = "Silent Aim", Default = false }):OnChanged(features.ToggleSilentAim)
RageGroup:AddToggle("rapid", { Text = "Rapid Fire", Default = false }):OnChanged(features.ToggleRapidFire)
RageGroup:AddToggle("killaura", { Text = "Kill Aura", Default = false }):OnChanged(features.ToggleKillAura)

-- === Visuals ===
local VisualsGroup = Tabs.Visuals:AddLeftGroupbox("Visuals")
VisualsGroup:AddToggle("esp", { Text = "ESP", Default = false }):OnChanged(features.ToggleESP)
VisualsGroup:AddToggle("skeleton", { Text = "ESP Skeleton", Default = false }):OnChanged(features.ToggleSkeleton)
VisualsGroup:AddToggle("rainbownames", { Text = "Rainbow Names", Default = false }):OnChanged(features.ToggleRainbowName)

-- === Player ===
local PlayerGroup = Tabs.Player:AddLeftGroupbox("Player Mods")
PlayerGroup:AddToggle("fly", { Text = "Fly", Default = false }):OnChanged(features.ToggleFly)
PlayerGroup:AddSlider("flyspeed", { Text = "Fly Speed", Default = 60, Min = 20, Max = 150, Rounding = 0 }):OnChanged(features.SetFlySpeed)
PlayerGroup:AddToggle("infjump", { Text = "Infinite Jump", Default = false }):OnChanged(features.ToggleInfiniteJump)
PlayerGroup:AddToggle("god", { Text = "God Mode", Default = false }):OnChanged(features.ToggleGodmode)
PlayerGroup:AddSlider("speed", { Text = "WalkSpeed", Default = 16, Min = 16, Max = 200, Rounding = 0 }):OnChanged(features.SetSpeed)
PlayerGroup:AddToggle("invisible", { Text = "Invisible", Default = false }):OnChanged(features.ToggleInvisible)

-- === Teleport ===
local TeleportGroup = Tabs.Teleport:AddLeftGroupbox("Teleport")
TeleportGroup:AddToggle("tp", { Text = "Teleport (T Key)", Default = false }):OnChanged(features.ToggleTeleport)

-- === World ===
local WorldGroup = Tabs.World:AddLeftGroupbox("World")
WorldGroup:AddToggle("noclip", { Text = "NoClip", Default = false }):OnChanged(features.ToggleNoclip)

-- === Misc ===
local MiscGroup = Tabs.Misc:AddLeftGroupbox("Misc")
MiscGroup:AddToggle("inspector", { Text = "Tool Inspector", Default = false }):OnChanged(features.ToggleInspector)

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
