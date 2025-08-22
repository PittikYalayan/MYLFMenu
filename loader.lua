-- Linoria Library yükle
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

-- Features al
local features = loadstring(readfile("features.lua"))()

-- UI Setup
local Window = Library:CreateWindow({
    Title = '⚡ MYLF Hack Menu ⚡',
    Center = true,
    AutoShow = true,
})

local Tabs = {
    Player = Window:AddTab('Player'),
    Combat = Window:AddTab('Combat'),
    Visuals = Window:AddTab('Visuals'),
    Misc = Window:AddTab('Misc'),
}

-- === Player Tab ===
local PlayerBox = Tabs.Player:AddLeftGroupbox('Player Hacks')
PlayerBox:AddToggle('Speed', { Text = 'Speed', Default = false }):OnChanged(function(val) features.ToggleSpeed(val) end)
PlayerBox:AddToggle('Godmode', { Text = 'Godmode', Default = false }):OnChanged(function(val) features.ToggleGodmode(val) end)
PlayerBox:AddToggle('Fly', { Text = 'Fly', Default = false }):OnChanged(function(val) features.ToggleFly(val) end)
PlayerBox:AddToggle('Jump', { Text = 'Infinite Jump', Default = false }):OnChanged(function(val) features.ToggleInfiniteJump(val) end)

-- === Combat Tab ===
local CombatBox = Tabs.Combat:AddLeftGroupbox('Combat')
CombatBox:AddToggle('Aimbot', { Text = 'Silent Aim', Default = false }):OnChanged(function(val) features.ToggleAimbot(val) end)
CombatBox:AddSlider('FOV', { Text = 'Aimbot FOV', Default = 120, Min = 50, Max = 500, Rounding = 0 }):OnChanged(function(val) features.FOV = val end)
CombatBox:AddToggle('Aura', { Text = 'Kill Aura', Default = false }):OnChanged(function(val) features.ToggleKillAura(val) end)
CombatBox:AddToggle('TP', { Text = 'Teleport Tool (T)', Default = false }):OnChanged(function(val) features.ToggleTeleport(val) end)

-- === Visuals Tab ===
local VisualsBox = Tabs.Visuals:AddLeftGroupbox('Visuals')
VisualsBox:AddToggle('ESP', { Text = 'ESP Master Toggle', Default = false }):OnChanged(function(val) features.ToggleESP(val) end)
VisualsBox:AddToggle('Skeleton', { Text = 'ESP Skeleton', Default = false }):OnChanged(function(val) features.ToggleSkeleton(val) end)
VisualsBox:AddToggle('Rainbow', { Text = 'ESP Rainbow Names', Default = false }):OnChanged(function(val) features.ToggleRainbowName(val) end)

-- === Misc Tab ===
local MiscBox = Tabs.Misc:AddLeftGroupbox('Misc')
MiscBox:AddToggle('Invisible', { Text = 'Invisible', Default = false }):OnChanged(function(val) features.ToggleInvisible(val) end)
MiscBox:AddToggle('Inspector', { Text = 'Tool Inspector', Default = false }):OnChanged(function(val) features.ToggleInspector(val) end)

-- === Theme/Save ===
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
ThemeManager:ApplyToTab(Tabs.Misc)
SaveManager:BuildConfigSection(Tabs.Misc)

Library:Notify('MYLF Menu Loaded!', 3)
