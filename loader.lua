-- Linoria Library yükle
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

-- Features
local features = loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features.lua"))()

-- === UI ===
local Window = Library:CreateWindow({
    Title = '⚡ MYLF Hack Menu ⚡',
    Center = true,
    AutoShow = true,
})

local Tabs = {
    Legit = Window:AddTab('Legit'),
    Rage = Window:AddTab('Rage'),
    Visuals = Window:AddTab('Visuals'),
    Player = Window:AddTab('Player'),
    Teleport = Window:AddTab('Teleport'),
    World = Window:AddTab('World'),
    Misc = Window:AddTab('Misc'),
    Settings = Window:AddTab('Settings'),
}

-- === Legit (Aimbot) ===
local LegitBox = Tabs.Legit:AddLeftGroupbox('Aimbot')
LegitBox:AddToggle('AimbotEnable', { Text = 'Enable', Default = false })
    :OnChanged(function(val) features.ToggleAimbot(val) end)

LegitBox:AddToggle('WallCheck', { Text = 'Wall Check', Default = true })
    :OnChanged(function(val) features.WallCheck = val end)

LegitBox:AddToggle('TeamCheck', { Text = 'Team Check', Default = true })
    :OnChanged(function(val) features.TeamCheck = val end)

LegitBox:AddSlider('Smoothness', { Text = 'Smoothness', Min = 1, Max = 10, Default = 5, Rounding = 1 })
    :OnChanged(function(val) features.Smoothness = val end)

LegitBox:AddToggle('EnablePrediction', { Text = 'Enable Prediction', Default = false })
    :OnChanged(function(val) features.EnablePrediction = val end)

LegitBox:AddToggle('StickyAim', { Text = 'Sticky Aim', Default = false })
    :OnChanged(function(val) features.StickyAim = val end)

LegitBox:AddDropdown('Keybind', { Text = 'Keybind', Values = { 'Mouse Button1', 'Mouse Button2', 'Mouse Button3', 'E', 'Q' }, Default = 'Mouse Button2' })
    :OnChanged(function(val) features.AimbotKey = val end)

-- === Player ===
local PlayerBox = Tabs.Player:AddLeftGroupbox('Player Hacks')
PlayerBox:AddToggle('Godmode', { Text = 'Godmode', Default = false }):OnChanged(function(val) features.ToggleGodmode(val) end)

PlayerBox:AddSlider('SpeedSlider', { Text = 'Speed', Min = 1, Max = 300, Default = 16, Rounding = 0 })
    :OnChanged(function(val) features.SetSpeed(val) end)

PlayerBox:AddSlider('FlySlider', { Text = 'Fly Speed', Min = 1, Max = 300, Default = 50, Rounding = 0 })
    :OnChanged(function(val) features.SetFlySpeed(val) end)

PlayerBox:AddToggle('InfiniteJump', { Text = 'Infinite Jump', Default = false })
    :OnChanged(function(val) features.ToggleInfiniteJump(val) end)

-- === Teleport ===
local TeleportBox = Tabs.Teleport:AddLeftGroupbox('Teleport')
TeleportBox:AddToggle('TP', { Text = 'Teleport Tool (T)', Default = false })
    :OnChanged(function(val) features.ToggleTeleport(val) end)

-- === Visuals ===
local VisualsBox = Tabs.Visuals:AddLeftGroupbox('Visuals')
VisualsBox:AddToggle('ESP', { Text = 'ESP Master Toggle', Default = false }):OnChanged(function(val) features.ToggleESP(val) end)
VisualsBox:AddToggle('Skeleton', { Text = 'ESP Skeleton', Default = false }):OnChanged(function(val) features.ToggleSkeleton(val) end)
VisualsBox:AddToggle('Rainbow', { Text = 'ESP Rainbow Names', Default = false }):OnChanged(function(val) features.ToggleRainbowName(val) end)

-- === Misc ===
local MiscBox = Tabs.Misc:AddLeftGroupbox('Misc')
MiscBox:AddToggle('Invisible', { Text = 'Invisible', Default = false }):OnChanged(function(val) features.ToggleInvisible(val) end)
MiscBox:AddToggle('Inspector', { Text = 'Tool Inspector', Default = false }):OnChanged(function(val) features.ToggleInspector(val) end)

-- === Theme/Save ===
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Library:Notify('⚡ MYLF Menu Loaded!', 3)
