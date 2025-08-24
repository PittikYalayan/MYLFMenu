-- ⚡ MYLF | Hub ⚡ — LOADER (Inspector yok, Magic Bullet toggle eklendi)

local Library      = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

local features = loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/featurestest1.lua"))() --normali features2

-- AutoShow=false: inject anında mouse’u çalmaz
local Window = Library:CreateWindow({ Title = "⚡ MYLF | Hub ⚡", Center = true, AutoShow = false })

-- Menü toggle (fallback’lı)
local UIS = game:GetService("UserInputService")
local MENU_KEY = Enum.KeyCode.LeftShift
local function ToggleMenu() Library:Toggle() end
Library.ToggleKeybind = MENU_KEY
UIS.InputBegan:Connect(function(inp, gp)
    if not gp and inp.KeyCode == MENU_KEY then ToggleMenu() end
end)

-- Tabs
-- Tabs
local Tabs = {
    Combat   = Window:AddTab("Combat"),
    Movement = Window:AddTab("Movement"),
    Visuals  = Window:AddTab("Visuals"),
    Misc     = Window:AddTab("Misc")
}


local function bindToggle(group, flag, text, fn)
    group:AddToggle(flag, { Text = text, Default = false })
        :OnChanged(function(v) if type(fn)=="function" then pcall(fn, v) end end)
end

----------------------------------------------------------------
-- COMBAT
----------------------------------------------------------------
local cb = Tabs.Combat:AddLeftGroupbox("Combat")

cb:AddToggle("aimbot", { Text = "🎯 Aimbot", Default = false }):OnChanged(function(val)
    features.ToggleAimbot(val)
end)

cb:AddToggle("silent", { Text = "🔇 Silent Aim", Default = false }):OnChanged(function(val)
    features.ToggleSilentAim(val)
end)

cb:AddToggle("mb", { Text = "💥 Magic Bullet", Default = false }):OnChanged(function(val)
    features.ToggleMagicBullet(val)
end)

cb:AddToggle("kaura", { Text = "☠ Kill Aura", Default = false }):OnChanged(function(val)
    features.ToggleKillAura(val)
end)

cb:AddToggle("rapid", { Text = "⚡ Rapid Fire", Default = false }):OnChanged(function(val)
    features.ToggleRapidFire(val)
end)

do
----------------------------------------------------------------
-- MOVEMENT
----------------------------------------------------------------
local mv = Tabs.Movement:AddLeftGroupbox("Movement")

mv:AddToggle("fly", { Text = "🕊 Fly", Default = false }):OnChanged(function(val)
    features.ToggleFly(val)
end)

mv:AddToggle("infjump", { Text = "⛅ Infinite Jump", Default = false }):OnChanged(function(val)
    features.ToggleInfiniteJump(val)
end)

mv:AddToggle("noclip", { Text = "🚪 Noclip", Default = false }):OnChanged(function(val)
    features.ToggleNoclip(val)
end)

mv:AddToggle("speed", { Text = "🏃 Speed", Default = false }):OnChanged(function(val)
    features.ToggleSpeed(val)
end)

mv:AddToggle("tp", { Text = "📍 Teleport (T)", Default = false }):OnChanged(function(val)
    features.ToggleTeleport(val)
end)

do
----------------------------------------------------------------
-- VISUALS (ESP)
----------------------------------------------------------------
local visTab = Tabs.Visuals:AddLeftGroupbox("Player ESP")

visTab:AddToggle("espMaster", { Text = "Enable ESP", Default = false }):OnChanged(function(val)
    features.ToggleESP(val)
end)

visTab:AddToggle("espRainbow", { Text = "🌈 Rainbow Name", Default = false }):OnChanged(function(val)
    features.ToggleESPRainbow(val)
end)

visTab:AddToggle("espSkeleton", { Text = "🦴 Skeleton", Default = false }):OnChanged(function(val)
    features.ToggleESPSkeleton(val)
end)

visTab:AddToggle("espGlow", { Text = "✨ Glow", Default = false }):OnChanged(function(val)
    features.ToggleESPGlow(val)
end)

visTab:AddToggle("espBox", { Text = "▣ 3D Box", Default = false }):OnChanged(function(val)
    features.ToggleESPBox(val)
end)

visTab:AddToggle("espStripes", { Text = "≡ Box Stripes", Default = false }):OnChanged(function(val)
    features.ToggleESPStripes(val)
end)

visTab:AddToggle("espDist", { Text = "📏 Distance", Default = false }):OnChanged(function(val)
    features.ToggleESPDistance(val)
end)

visTab:AddToggle("espHP", { Text = "❤️ Health Bar", Default = false }):OnChanged(function(val)
    features.ToggleESPHealth(val)
end)

visTab:AddToggle("espTracers", { Text = "〽 Tracers", Default = false }):OnChanged(function(val)
    features.ToggleESPTracers(val)
end)

visTab:AddToggle("espArrows", { Text = "⬅ Offscreen Arrows", Default = false }):OnChanged(function(val)
    features.ToggleESPArrows(val)
end)

visTab:AddToggle("espCorner", { Text = "⌞⌝ Corner Box 2D", Default = false }):OnChanged(function(val)
    features.ToggleESPCorner(val)
end)

visTab:AddToggle("espTeam", { Text = "👥 Team Check", Default = false }):OnChanged(function(val)
    features.ToggleESPTeam(val)
end)

visTab:AddToggle("espLOS", { Text = "🔭 LOS Only", Default = false }):OnChanged(function(val)
    features.ToggleESPLos(val)
end)

visTab:AddToggle("espRange", { Text = "📡 Range 300", Default = false }):OnChanged(function(val)
    features.ToggleESPRange(val)
end)

visTab:AddToggle("espFriend", { Text = "⭐ Friend Ignore", Default = false }):OnChanged(function(val)
    features.ToggleESPFriends(val)
end)

----------------------------------------------------------------
-- MISC
do ----------------------------------------------------------------
local ms = Tabs.Misc:AddLeftGroupbox("Misc")

ms:AddToggle("god", { Text = "🛡 Godmode", Default = false }):OnChanged(function(val)
    features.ToggleGodmode(val)
end)

ms:AddToggle("inv", { Text = "👻 Invisible", Default = false }):OnChanged(function(val)
    features.ToggleInvisible(val)
end)


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
