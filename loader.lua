-- ⚡ MYLF | Hub ⚡
-- Loader (features.lua'ya bağlı, full sync)

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

local features = loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features.lua"))()

-- === Ana Pencere ===
local Window = Library:CreateWindow({
    Title = "⚡ MYLF | Hub ⚡",
    Center = true,
    AutoShow = true,
})

-- === Sekmeler ===
local Tabs = {
    Rage     = Window:AddTab("Rage"),
    Visuals  = Window:AddTab("Visuals"),
    Player   = Window:AddTab("Player"),
    Teleport = Window:AddTab("Teleport"),
    World    = Window:AddTab("World"),
    Misc     = Window:AddTab("Misc"),
    Settings = Window:AddTab("Settings"),
}

-- === Rage ===
local RageGroup = Tabs.Rage:AddLeftGroupbox("Rage")
RageGroup:AddToggle("aimbot", { Text = "Enable Aimbot", Default = false })
    :OnChanged(function(val) if features.ToggleAimbot then features.ToggleAimbot(val) end end)
RageGroup:AddToggle("silent", { Text = "Silent Aim", Default = false })
    :OnChanged(function(val) if features.ToggleSilentAim then features.ToggleSilentAim(val) end end)
RageGroup:AddToggle("rapid", { Text = "Rapid Fire", Default = false })
    :OnChanged(function(val) if features.ToggleRapidFire then features.ToggleRapidFire(val) end end)
RageGroup:AddToggle("killaura", { Text = "Kill Aura", Default = false })
    :OnChanged(function(val) if features.ToggleKillAura then features.ToggleKillAura(val) end end)

-- === Visuals ===
local VisualsGroup = Tabs.Visuals:AddLeftGroupbox("Visuals")
VisualsGroup:AddToggle("esp", { Text = "Enable ESP", Default = false })
    :OnChanged(function(val) if features.ToggleESP then features.ToggleESP(val) end end)
VisualsGroup:AddToggle("skeleton", { Text = "Show Skeleton", Default = false })
    :OnChanged(function(val)
        if features.ToggleSkeleton then features.ToggleSkeleton(val) end
        if Library.Flags.esp then features.ToggleESP(true) end
    end)
VisualsGroup:AddToggle("rainbow", { Text = "Rainbow Names", Default = false })
    :OnChanged(function(val)
        if features.ToggleRainbowName then features.ToggleRainbowName(val) end
        if Library.Flags.esp then features.ToggleESP(true) end
    end)

-- === Player ===
local PlayerGroup = Tabs.Player:AddLeftGroupbox("Player Mods")
PlayerGroup:AddToggle("fly", { Text = "Fly", Default = false })
    :OnChanged(function(val) if features.ToggleFly then features.ToggleFly(val) end end)
PlayerGroup:AddSlider("flyspeed", { Text = "Fly Speed", Default = 60, Min = 20, Max = 150, Rounding = 0 })
    :OnChanged(function(val) if features.SetFlySpeed then features.SetFlySpeed(val) end end)
PlayerGroup:AddToggle("infjump", { Text = "Infinite Jump", Default = false })
    :OnChanged(function(val) if features.ToggleInfiniteJump then features.ToggleInfiniteJump(val) end end)
PlayerGroup:AddToggle("god", { Text = "God Mode", Default = false })
    :OnChanged(function(val) if features.ToggleGodmode then features.ToggleGodmode(val) end end)
PlayerGroup:AddSlider("speed", { Text = "WalkSpeed", Default = 16, Min = 16, Max = 200, Rounding = 0 })
    :OnChanged(function(val) if features.SetSpeed then features.SetSpeed(val) end end)
PlayerGroup:AddToggle("invisible", { Text = "Invisible", Default = false })
    :OnChanged(function(val) if features.ToggleInvisible then features.ToggleInvisible(val) end end)

-- === Teleport ===
local TeleportGroup = Tabs.Teleport:AddLeftGroupbox("Teleport")
TeleportGroup:AddToggle("tp", { Text = "Teleport (T Key)", Default = false })
    :OnChanged(function(val) if features.ToggleTeleport then features.ToggleTeleport(val) end end)

-- === World ===
local WorldGroup = Tabs.World:AddLeftGroupbox("World")
WorldGroup:AddToggle("noclip", { Text = "NoClip", Default = false })
    :OnChanged(function(val) if features.ToggleNoclip then features.ToggleNoclip(val) end end)

-- === Misc ===
local MiscGroup = Tabs.Misc:AddLeftGroupbox("Misc")
MiscGroup:AddToggle("inspector", { Text = "Tool Inspector", Default = false })
    :OnChanged(function(val) if features.ToggleInspector then features.ToggleInspector(val) end end)

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
theme.Accent = Color3.fromRGB(230, 0, 35)
theme.Background = Color3.fromRGB(20, 20, 20)
theme.Outline = Color3.fromRGB(180, 0, 0)
