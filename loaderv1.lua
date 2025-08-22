-- ⚡ MYLF | Hub ⚡
-- Loader (features.lua ile %100 uyumlu, sadece bağlama/menü — features'a dokunmaz)

-- == Libs ==
local Library      = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

-- == Features (senin dosyan) ==
local features = loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features.lua"))()

-- == Window ==
local Window = Library:CreateWindow({
    Title = "⚡ MYLF | Hub ⚡",
    Center = true,
    AutoShow = true
})

-- == Helper bağlayıcılar (nil/pcall korumalı) ==
local function bindToggle(group, flag, text, fn)
    group:AddToggle(flag, { Text = text, Default = false })
        :OnChanged(function(val)
            if type(fn) == "function" then pcall(fn, val) end
        end)
end

local function bindSlider(group, flag, text, min, max, default, fn)
    group:AddSlider(flag, { Text = text, Min = min, Max = max, Default = default, Rounding = 0 })
        :OnChanged(function(val)
            if type(fn) == "function" then pcall(fn, val) end
        end)
end

-- == Tabs ==
local Tabs = {
    Legit    = Window:AddTab("🔍 Legit"),    -- şimdilik boş; istersen buraya başka şey taşırız
    Rage     = Window:AddTab("🔥 Rage"),
    Visuals  = Window:AddTab("👁 Visuals"),
    Player   = Window:AddTab("🕴 Player"),
    Teleport = Window:AddTab("⚡ Teleport"),
    World    = Window:AddTab("🌍 World"),
    Misc     = Window:AddTab("🛠 Misc"),
    Settings = Window:AddTab("⚙ Settings")
}

-- == Rage ==
do
    local g = Tabs.Rage:AddLeftGroupbox("Rage")
    bindToggle(g, "aimbot",     "Enable Aimbot",  features.ToggleAimbot)      -- Aimbot RAGE’e taşındı
    bindToggle(g, "silent",     "Silent Aim",     features.ToggleSilentAim)
    bindToggle(g, "rapid",      "Rapid Fire",     features.ToggleRapidFire)
    bindToggle(g, "killaura",   "Kill Aura",      features.ToggleKillAura)
end

-- == Visuals ==
do
    local g = Tabs.Visuals:AddLeftGroupbox("Visuals")
    bindToggle(g, "esp",        "Enable ESP",     features.ToggleESP)          -- Library.Flags.esp KULLANILMIYOR (nil hatası fix)
    bindToggle(g, "skeleton",   "ESP Skeleton",   features.ToggleSkeleton)
    bindToggle(g, "rainbownm",  "Rainbow Names",  features.ToggleRainbowName)
end

-- == Player ==
do
    local g = Tabs.Player:AddLeftGroupbox("Player Mods")
    bindToggle(g, "fly",        "Fly",            features.ToggleFly)
    bindSlider(g, "flyspeed",   "Fly Speed",      20, 150, 60,  features.SetFlySpeed)
    bindToggle(g, "infjump",    "Infinite Jump",  features.ToggleInfiniteJump)
    bindToggle(g, "god",        "God Mode",       features.ToggleGodmode)
    bindSlider(g, "walkspd",    "WalkSpeed",      16, 200, 16,   features.SetSpeed)
    bindToggle(g, "invisible",  "Invisible",      features.ToggleInvisible)
end

-- == Teleport ==
do
    local g = Tabs.Teleport:AddLeftGroupbox("Teleport")
    bindToggle(g, "tpkey",      "Teleport (T Key)", features.ToggleTeleport)
end

-- == World ==
do
    local g = Tabs.World:AddLeftGroupbox("World")
    bindToggle(g, "noclip",     "NoClip",         features.ToggleNoclip)
end

-- == Misc ==
do
    local g = Tabs.Misc:AddLeftGroupbox("Misc")
    bindToggle(g, "inspector",  "Tool Inspector", features.ToggleInspector)
end

-- == Settings / Tema / Kayıt ==
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

ThemeManager:SetFolder("MYLFHub")
SaveManager:SetFolder("MYLFHub/saves")

SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

-- Menü toggle key
Library.ToggleKeybind = Enum.KeyCode.LeftShift

-- Tema: siyah-kırmızı
local theme = ThemeManager:CurrentTheme()
theme.Accent     = Color3.fromRGB(230, 0, 35)
theme.Background = Color3.fromRGB(20, 20, 20)
theme.Outline    = Color3.fromRGB(180, 0, 0)
