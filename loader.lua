-- ⚡ MYLF Premium Loader (Linoria) - ORİJİNAL KORUNDU

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

local Features = loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features.lua"))()

-- === Pencere ===
local Window = Library:CreateWindow({
    Title = '⚡ MYLF Hub ⚡',
    Center = true,
    AutoShow = true,
})

-- === Sekmeler ===
local Tabs = {
    Legit    = Window:AddTab(' Legit'),
    Rage     = Window:AddTab(' Rage'),
    Visuals  = Window:AddTab(' Visuals'),
    Player   = Window:AddTab(' Player'),
    Teleport = Window:AddTab('Teleport'),
    World    = Window:AddTab(' World'),
    Misc     = Window:AddTab(' Misc'),
    Settings = Window:AddTab('Settings'),
}

-- === Legit Tab ===
local AimbotGroup = Tabs.Legit:AddLeftGroupbox('Aimbot')
AimbotGroup:AddToggle('AimEnabled', {
    Text = 'Enable', Default = false,
}):OnChanged(function(val)
    Features.ToggleAimbot(val)
end)
AimbotGroup:AddToggle('AimWallCheck', {
    Text = 'Wall Check', Default = false,
}):OnChanged(function(val)
    Features.SetWallCheck(val)
end)
AimbotGroup:AddToggle('AimTeamCheck', {
    Text = 'Team Check', Default = false,
}):OnChanged(function(val)
    Features.SetTeamCheck(val)
end)
AimbotGroup:AddSlider('AimSmooth', {
    Text = 'Smoothness',
    Min = 1, Max = 10, Default = 5, Rounding = 1,
    Callback = function(val)
        Features.SetSmoothness(val)
    end
})
AimbotGroup:AddToggle('AimPrediction', {
    Text = 'Enable Prediction', Default = false,
}):OnChanged(function(val)
    Features.SetPrediction(val)
end)
AimbotGroup:AddToggle('AimSticky', {
    Text = 'Sticky Aim', Default = false,
}):OnChanged(function(val)
    Features.SetSticky(val)
end)
AimbotGroup:AddKeyPicker('AimKey', {
    Default = 'MouseButton2',
    SyncToggleState = false,
    Text = 'Keybind',
    Mode = 'Hold',
    Callback = function(val)
        Features.SetAimKey(val)
    end,
})

-- === Rage Tab ===
local RageGroup = Tabs.Rage:AddLeftGroupbox('Ragebot')
RageGroup:AddToggle('RageAimbot', {
    Text = 'Enable Rage Aimbot', Default = false,
}):OnChanged(function(val)
    Features.ToggleRageAimbot(val)
end)
RageGroup:AddToggle('SilentAim', {
    Text = 'Silent Aim', Default = false,
}):OnChanged(function(val)
    Features.ToggleSilentAim(val)
end)
RageGroup:AddToggle('NoRecoil', {
    Text = 'No Recoil / No Spread', Default = false,
}):OnChanged(function(val)
    Features.ToggleNoRecoilSpread(val)
end)
RageGroup:AddToggle('KillAura', {
    Text = 'Kill Aura', Default = false,
}):OnChanged(function(val)
    Features.ToggleKillAura(val)
end)
RageGroup:AddToggle('RapidFire', {
    Text = 'Rapid Fire', Default = false,
}):OnChanged(function(val)
    Features.ToggleRapidFire(val)
end)

-- === Visuals Tab ===
local VisualGroup = Tabs.Visuals:AddLeftGroupbox('ESP / Visuals')
VisualGroup:AddToggle('ESP', {
    Text = 'ESP', Default = false,
}):OnChanged(function(val)
    Features.ToggleESP(val)
end)
VisualGroup:AddToggle('Skeleton', {
    Text = 'Skeleton ESP', Default = false,
}):OnChanged(function(val)
    Features.ToggleSkeleton(val)
end)
VisualGroup:AddToggle('Invisible', {
    Text = 'Invisible Mode', Default = false,
}):OnChanged(function(val)
    Features.ToggleInvisible(val)
end)

-- === Player Tab ===
local PlayerGroup = Tabs.Player:AddLeftGroupbox('Player Mods')
PlayerGroup:AddToggle('Godmode', {
    Text = 'Godmode', Default = false,
}):OnChanged(function(val)
    Features.ToggleGodmode(val)
end)
PlayerGroup:AddToggle('Fly', {
    Text = 'Fly', Default = false,
}):OnChanged(function(val)
    Features.ToggleFly(val)
end)
PlayerGroup:AddToggle('InfJump', {
    Text = 'Infinite Jump', Default = false,
}):OnChanged(function(val)
    Features.ToggleInfiniteJump(val)
end)
PlayerGroup:AddSlider('Speed', {
    Text = 'Walk Speed',
    Min = 16, Max = 300, Default = 16,
    Callback = function(val)
        Features.SetSpeed(val)
    end
})

-- === Misc Tab ===
local MiscGroup = Tabs.Misc:AddLeftGroupbox('Misc')
MiscGroup:AddButton('Tool Inspector', function()
    Features.ToggleInspector(true)
end)
MiscGroup:AddToggle('Noclip', {
    Text = 'Noclip', Default = false,
}):OnChanged(function(val)
    Features.ToggleNoclip(val)
end)

-- === Tema & Kaydetme ===
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
ThemeManager:SetFolder('MYLFHub')
SaveManager:SetFolder('MYLFHub')
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

-- === Aç/Kapa Tuşu (LeftShift) ===
Library.ToggleKeybind = Enum.KeyCode.LeftShift
