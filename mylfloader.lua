-- 📌 Library yükleme
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/mylf.lua"))()
local features = loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features9.8.lua"))() --normali features2
-- ⚡ Ana pencere
local Window = Library:CreateWindow({
    Title = "⚡ MYLF | Hub ⚡",
    Center = true,
    AutoShow = true,
})

-- 📂 Tabs
local Tabs = {
    Combat   = Window:AddTab("Combat"),
    Visuals  = Window:AddTab("Visuals"),
    Player   = Window:AddTab("Player"),
    Movement = Window:AddTab("Movement"),
    Misc     = Window:AddTab("Misc"),
    Settings = Window:AddTab("Settings"),
}

-- 📦 Misc grubu
local miscGroupLeft  = Tabs.Misc:AddLeftGroupbox("Misc Settings")

-- 📦 Player grubu
local playerGroupLeft = Tabs.Player:AddLeftGroupbox("Player Settings")

----------------------------------------------------------------
-- ⚡ Misc içine Teleport Offset Slider’ları
----------------------------------------------------------------
miscGroupLeft:AddSlider("tpX", {
    Text = "X Offset",
    Min = -50,
    Max = 50,
    Default = 0,
    Rounding = 1,
})

miscGroupLeft:AddSlider("tpY", {
    Text = "Y Offset",
    Min = -50,
    Max = 50,
    Default = 0,
    Rounding = 1,
})

miscGroupLeft:AddSlider("tpZ", {
    Text = "Z Offset",
    Min = 1,
    Max = 100,
    Default = 25,
    Rounding = 1,
})

Options.tpX:OnChanged(function(val)
    features.SetTeleportOffset(val, Options.tpY.Value, Options.tpZ.Value)
end)

Options.tpY:OnChanged(function(val)
    features.SetTeleportOffset(Options.tpX.Value, val, Options.tpZ.Value)
end)

Options.tpZ:OnChanged(function(val)
    features.SetTeleportOffset(Options.tpX.Value, Options.tpY.Value, val)
end)

----------------------------------------------------------------
-- ⚡ Player içine örnek toggle
----------------------------------------------------------------
playerGroupLeft:AddToggle("godmode", {
    Text = "💀 Godmode",
    Default = false,
    Callback = function(val)
        features.ToggleGodmode(val)
    end
})

playerGroupLeft:AddToggle("infiniteJump", {
    Text = "🦘 Infinite Jump",
    Default = false,
    Callback = function(val)
        features.ToggleInfiniteJump(val)
    end
})
-- ⚙️ Settings Tab
local settingsGroup = Tabs.Settings:AddLeftGroupbox("UI Settings")

-- Menü Toggle Tuşu
settingsGroup:AddLabel("Menu Key"):AddKeyPicker("MenuKeybind", {
    Default = "LeftControl", -- başlangıçta atanmış tuş
    SyncToggleState = false,
    Mode = "Toggle",
    Text = "Menu Toggle",
    NoUI = false,
})

-- Keybind değiştiğinde menüyü bağla
Options.MenuKeybind:OnClick(function()
    Library:Toggle()
end)

