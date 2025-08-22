-- ⚡ MYLF Premium Loader (Linoria) - FIXED & UPDATED
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

-- ✅ Features Modülü
local Features = loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features.lua"))()

-- === Ana Pencere ===
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
    Teleport = Window:AddTab('⚡ Teleport'),
    World    = Window:AddTab(' World'),
    Misc     = Window:AddTab(' Misc'),
    Settings = Window:AddTab('⚙️ Settings'),
}

-- === Legit Tab ===
local AimbotGroup = Tabs.Legit:AddLeftGroupbox('Aimbot')
AimbotGroup:AddToggle('AimEnabled', {Text = 'Enable'}):OnChanged(function(val) Features.ToggleAimbot(val) end)
AimbotGroup:AddToggle('AimWallCheck', {Text = 'Wall Check'}):OnChanged(function(val) Features.SetWallCheck(val) end)
AimbotGroup:AddToggle('AimTeamCheck', {Text = 'Team Check'}):OnChanged(function(val) Features.SetTeamCheck(val) end)
AimbotGroup:AddSlider('AimSmooth', {Text = 'Smoothness', Min = 1, Max = 10, Default = 5, Rounding = 1})
    :OnChanged(function(val) Features.SetSmoothness(val) end)
AimbotGroup:AddToggle('AimPrediction', {Text = 'Prediction'}):OnChanged(function(val) Features.SetPrediction(val) end)
AimbotGroup:AddToggle('AimSticky', {Text = 'Sticky Aim'}):OnChanged(function(val) Features.SetSticky(val) end)
AimbotGroup:AddKeyPicker('AimKey', {
    Default = 'MouseButton2', Mode = 'Hold', Text = 'Keybind',
    Callback = function(val) Features.SetAimKey(val) end
})

-- === Rage Tab ===
local RageGroup = Tabs.Rage:AddLeftGroupbox('Ragebot')
RageGroup:AddToggle('RageAimbot', {Text = 'Rage Aimbot'}):OnChanged(function(val) Features.ToggleRageAimbot(val) end)
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
PlayerGroup:AddToggle('Godmode', {Text = 'Godmode'}):OnChanged(function(val) Features.ToggleGodmode(val) end)
PlayerGroup:AddToggle('Fly', {Text = 'Fly'}):OnChanged(function(val) Features.ToggleFly(val) end)
PlayerGroup:AddToggle('InfJump', {Text = 'Infinite Jump'}):OnChanged(function(val) Features.ToggleInfiniteJump(val) end)
PlayerGroup:AddSlider('Speed', {Text = 'Walk Speed', Min = 16, Max = 300, Default = 16})
    :OnChanged(function(val) Features.SetSpeed(val) end)

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
ThemeManager:SetFolder('MYLFHu')
SaveManager:SetFolder('MYLFHu')
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

-- === Aç/Kapa Tuşu (LeftShift) ===
Library.ToggleKeybind = Enum.KeyCode.LeftShift
