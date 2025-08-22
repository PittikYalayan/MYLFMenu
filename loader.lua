-- ⚡ MYLF Premium Loader (Linoria) - Modern Design v3
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

-- ✅ Features Modülü
local Features = loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features.lua"))()

-- === Tema Ayarları (Modern) ===
Library.BackgroundColor = Color3.fromRGB(25, 20, 30)
Library.MainColor       = Color3.fromRGB(160, 60, 180)
Library.AccentColor     = Color3.fromRGB(255, 0, 90)
Library.OutlineColor    = Color3.fromRGB(40, 40, 60)
Library.FontColor       = Color3.fromRGB(230, 230, 230)

-- === Ana Pencere ===
local Window = Library:CreateWindow({
    Title = '⚡ MYLF | Hub ⚡',
    Center = true,
    AutoShow = true,
})

-- === Sekmeler (ikonlarla) ===
local Tabs = {
    Legit    = Window:AddTab('Legit'),
    Rage     = Window:AddTab('Rage'),
    Visuals  = Window:AddTab('Visuals'),
    Player   = Window:AddTab('Player'),
    Teleport = Window:AddTab('Teleport'),
    World    = Window:AddTab('World'),
    Misc     = Window:AddTab('Misc'),
    Settings = Window:AddTab('Settings'),
}

-- === Rage Tab === (Aimbot buraya taşındı)
local RageGroup = Tabs.Rage:AddLeftGroupbox('Ragebot')

RageGroup:AddToggle('RageAimbot', {Text = 'Enable Rage Aimbot'}):OnChanged(function(val)
    Features.ToggleAimbot(val)
end)
RageGroup:AddToggle('RageWallCheck', {Text = 'Wall Check'}):OnChanged(function(val)
    Features.SetWallCheck(val)
end)
RageGroup:AddToggle('RageTeamCheck', {Text = 'Team Check'}):OnChanged(function(val)
    Features.SetTeamCheck(val)
end)
RageGroup:AddSlider('RageSmooth', {Text = 'Smoothness', Min = 1, Max = 10, Default = 5, Rounding = 1})
    :OnChanged(function(val) Features.SetSmoothness(val) end)
RageGroup:AddToggle('RagePrediction', {Text = 'Prediction'}):OnChanged(function(val)
    Features.SetPrediction(val)
end)
RageGroup:AddToggle('RageSticky', {Text = 'Sticky Aim'}):OnChanged(function(val)
    Features.SetSticky(val)
end)
RageGroup:AddKeyPicker('RageAimKey', {
    Default = 'MouseButton2',
    Mode = 'Hold',
    Text = 'Aimbot Key',
    Callback = function(val) Features.SetAimKey(val) end
})

-- Diğer Rage özellikleri
RageGroup:AddToggle('SilentAim', {Text = 'Silent Aim'}):OnChanged(function(val) Features.ToggleSilentAim(val) end)
RageGroup:AddToggle('NoRecoil', {Text = 'No Recoil / No Spread'}):OnChanged(function(val) Features.ToggleNoRecoilSpread(val) end)
RageGroup:AddToggle('KillAura', {Text = 'Kill Aura'}):OnChanged(function(val) Features.ToggleKillAura(val) end)
RageGroup:AddToggle('RapidFire', {Text = 'Rapid Fire'}):OnChanged(function(val) Features.ToggleRapidFire(val) end)

-- === Visuals Tab ===
local VisualGroup = Tabs.Visuals:AddLeftGroupbox('ESP / Visuals')
VisualGroup:AddToggle('ESP', {Text = 'ESP'}):OnChanged(function(val) Features.ToggleESP(val) end)
VisualGroup:AddToggle('Skeleton', {Text = 'Skeleton ESP'}):OnChanged(function(val) Features.ToggleSkeleton(val) end)
VisualGroup:AddToggle('Invisible', {Text = 'Invisible Mode'}):OnChanged(function(val) Features.ToggleInvisible(val) end)
VisualGroup:AddToggle('RainbowESP', {Text = 'Rainbow ESP'}):OnChanged(function(val) Features.ToggleRainbowESP(val) end)
VisualGroup:AddToggle('Tracers', {Text = 'Tracers'}):OnChanged(function(val) Features.ToggleTracers(val) end)
VisualGroup:AddToggle('Chams', {Text = 'Chams'}):OnChanged(function(val) Features.ToggleChams(val) end)

-- === Player Tab ===
local PlayerGroup = Tabs.Player:AddLeftGroupbox('Player Mods')

-- Godmode
PlayerGroup:AddToggle('Godmode', {Text = 'Godmode'}):OnChanged(function(val)
    Features.ToggleGodmode(val)
end)

-- Fly (Enable + keybind)
PlayerGroup:AddToggle('FlyEnabled', {Text = 'Enable Fly'}):OnChanged(function(val)
    Features.ToggleFly(val)
end)
PlayerGroup:AddKeyPicker('FlyKey', {
    Default = 'F',
    Mode = 'Toggle',
    Text = 'Fly Key',
    Callback = function(val) Features.SetFlyKey(val) end
})

-- Speed (Enable + slider + keybind)
PlayerGroup:AddToggle('SpeedEnabled', {Text = 'Enable Walk Speed'}):OnChanged(function(val)
    Features.ToggleSpeed(val)
end)
PlayerGroup:AddSlider('SpeedValue', {Text = 'Walk Speed', Min = 16, Max = 300, Default = 16})
    :OnChanged(function(val) Features.SetSpeed(val) end)
PlayerGroup:AddKeyPicker('SpeedKey', {
    Default = 'LeftShift',
    Mode = 'Hold',
    Text = 'Speed Key',
    Callback = function(val) Features.SetSpeedKey(val) end
})

-- Infinite Jump (Enable + keybind)
PlayerGroup:AddToggle('InfJumpEnabled', {Text = 'Enable Infinite Jump'}):OnChanged(function(val)
    Features.ToggleInfiniteJump(val)
end)
PlayerGroup:AddKeyPicker('InfJumpKey', {
    Default = 'Space',
    Mode = 'Hold',
    Text = 'Infinite Jump Key',
    Callback = function(val) Features.SetInfiniteJumpKey(val) end
})

-- === Teleport Tab ===
local TPGroup = Tabs.Teleport:AddLeftGroupbox('Teleport')
TPGroup:AddButton('Safe Zone', function() Features.TeleportSafeZone() end)
TPGroup:AddButton('Enemy Base', function() Features.TeleportEnemyBase() end)
TPGroup:AddButton('Random Player', function() Features.TeleportRandom() end)

-- === World Tab ===
local WorldGroup = Tabs.World:AddLeftGroupbox('World Mods')
WorldGroup:AddToggle('FullBright', {Text = 'Full Bright'}):OnChanged(function(val) Features.ToggleFullBright(val) end)
WorldGroup:AddToggle('NoFog', {Text = 'No Fog'}):OnChanged(function(val) Features.ToggleNoFog(val) end)
WorldGroup:AddToggle('NightVision', {Text = 'Night Vision'}):OnChanged(function(val) Features.ToggleNightVision(val) end)

-- === Misc Tab ===
local MiscGroup = Tabs.Misc:AddLeftGroupbox('Misc')
MiscGroup:AddButton('Tool Inspector', function() Features.ToggleInspector(true) end)
MiscGroup:AddToggle('Noclip', {Text = 'Noclip'}):OnChanged(function(val) Features.ToggleNoclip(val) end)
MiscGroup:AddToggle('Bhop', {Text = 'Bunny Hop'}):OnChanged(function(val) Features.ToggleBhop(val) end)
MiscGroup:AddToggle('ThirdPerson', {Text = 'Third Person'}):OnChanged(function(val) Features.ToggleThirdPerson(val) end)
MiscGroup:AddSlider('FOV', {Text = 'FOV Changer', Min = 70, Max = 120, Default = 90})
    :OnChanged(function(val) Features.SetFov(val) end)

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
