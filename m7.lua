-- ⚡ MYLF | Hub ⚡ — mmenu9.lua tablı menü (dummy features, sadece görmek için)

local Library, ThemeManager, SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/mmenu9.lua"))()

-- Dummy features (şimdilik sadece print atar)
local features = setmetatable({}, {
    __index = function(_, k)
        return function(v) print("[Feature]", k, v) end
    end
})

-- Window
local Window = Library:CreateWindow({ Title = "⚡ MYLF | Hub ⚡", Center = true, AutoShow = true })

-- Tabs
local Tabs = {
    Rage     = Window:AddTab("🔥 Rage"),
    Visuals  = Window:AddTab("👁 Visuals"),
    Player   = Window:AddTab("🕴 Player"),
    Teleport = Window:AddTab("⚡ Teleport"),
    World    = Window:AddTab("🌍 World"),
    Settings = Window:AddTab("⚙ Settings"),
}

-- Helper
local function bindToggle(group, flag, text, fn)
    group:AddToggle(flag, { Text = text, Default = false })
        :OnChanged(function(v) if type(fn)=="function" then fn(v) end end)
end

-- Rage
do
    local g = Tabs.Rage:AddLeftGroupbox("Rage")
    bindToggle(g, "aimbot", "Enable Aimbot", features.ToggleAimbot)
    bindToggle(g, "silent", "Silent Aim", features.ToggleSilentAim)
    bindToggle(g, "magic", "Magic Bullet", features.ToggleMagicBullet)
end

-- Visuals
do
    local g = Tabs.Visuals:AddLeftGroupbox("Visuals")
    bindToggle(g, "esp", "Enable ESP", features.ToggleESP)
    bindToggle(g, "enemyBigHB", "Enemy Big Hitbox", features.ToggleEnemyBigHitbox)
end

-- Player
do
    local g = Tabs.Player:AddLeftGroupbox("Player Mods")
    bindToggle(g, "fly", "Fly", features.ToggleFly)
    bindToggle(g, "noclip", "NoClip", features.ToggleNoclip)
end

-- Teleport
do
    local g = Tabs.Teleport:AddLeftGroupbox("Teleport")
    bindToggle(g, "tpkey", "Teleport (T)", features.ToggleTeleport)
    g:AddSlider("tpX", {Text="X Offset", Min=-50, Max=50, Default=0, Rounding=1})
    g:AddSlider("tpY", {Text="Y Offset", Min=-50, Max=50, Default=0, Rounding=1})
    g:AddSlider("tpZ", {Text="Z Offset", Min=1, Max=100, Default=25, Rounding=1})
end

-- World
do
    local g = Tabs.World:AddLeftGroupbox("World")
    bindToggle(g, "tinyHitbox", "Tiny Hitbox", features.ToggleTinyHitbox)
    bindToggle(g, "multiHook", "MultiHook", features.ToggleMultiHook)
end

-- Settings / Tema
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

-- Tema
local th = ThemeManager:CurrentTheme()
th.Accent     = Color3.fromRGB(230, 0, 35)
th.Background = Color3.fromRGB(20, 20, 20)
th.Outline    = Color3.fromRGB(180, 0, 0)
