-- ⚡ MYLF | Hub ⚡ — mmenu9 test loader (features yok, dummy fonksiyonlar var)

local Library, ThemeManager, SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/mmenu9.lua"))()

-- Dummy features (şimdilik sadece print)
local features = setmetatable({}, {
    __index = function(_, k)
        return function(v) print("[Feature Call]", k, v) end
    end
})

-- Window
local Window = Library:CreateWindow({ Title = "⚡ MYLF | Hub ⚡", Center = true, AutoShow = false })

-- Menü toggle
local UIS = game:GetService("UserInputService")
local MENU_KEY = Enum.KeyCode.LeftControl
Library.ToggleKeybind = MENU_KEY
UIS.InputBegan:Connect(function(inp, gp)
    if not gp and inp.KeyCode == MENU_KEY then
        if Library.Toggle then Library:Toggle() end
    end
end)

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
    group:AddToggle(flag, {
        Text = text,
        Default = false,
        Callback = function(v) if type(fn)=="function" then fn(v) end end
    })
end

-- Rage
do
    local g = Tabs.Rage:AddLeftGroupbox("Rage")
    bindToggle(g, "aimbot", "Enable Aimbot", features.ToggleAimbot)
    bindToggle(g, "silent", "Silent Aim", features.ToggleSilentAim)
end

-- Visuals
do
    local g = Tabs.Visuals:AddLeftGroupbox("Visuals")
    bindToggle(g, "esp", "Enable ESP", features.ToggleESP)
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

    g:AddSlider("tpX", {Text="X Offset", Min=-50, Max=50, Default=0, Rounding=1, Callback=function(val)
        print("tpX changed to", val)
    end})
end

-- World
do
    local g = Tabs.World:AddLeftGroupbox("World")
    bindToggle(g, "tinyHitbox", "Tiny Hitbox", features.ToggleTinyHitbox)
end

-- Settings
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

-- Tema
local th = ThemeManager:CurrentTheme()
th.Accent     = Color3.fromRGB(230, 0, 35)
th.Background = Color3.fromRGB(20, 20, 20)
th.Outline    = Color3.fromRGB(180, 0, 0)
