-- ⚡ MYLF | Hub ⚡ — LOADER (Inspector yok, Magic Bullet toggle eklendi)

local Library      = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

local features = loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/featurestest1.lua"))() --normali features2

-- AutoShow=false: inject anında mouse’u çalmaz
local Window = Library:CreateWindow({ Title = "⚡ MYLF | Hub ⚡", Center = true, AutoShow = false })

-- Menü toggle (fallback’lı)
local UIS = game:GetService("UserInputService")
local MENU_KEY = Enum.KeyCode.LeftShift
local function ToggleMenu() 
    Library:ToggleUI() -- ✅ Doğru fonksiyon
end

Library.ToggleKeybind = MENU_KEY
UIS.InputBegan:Connect(function(inp, gp)
    if not gp and inp.KeyCode == MENU_KEY then 
        ToggleMenu() 
    end
end)

-- Tabs
-- Tabs
local Tabs = {
    Combat   = Window:AddTab("Combat"),
    Movement = Window:AddTab("Movement"),
    Visuals  = Window:AddTab("Visuals"),
    Misc     = Window:AddTab("Misc")
}


local function bindToggle(group, flag, text, fn)
    group:AddToggle(flag, { Text = text, Default = false })
        :OnChanged(function(v) if type(fn)=="function" then pcall(fn, v) end end)
end

-- Combat sekmesi (örnek butonlar)
local CombatGroup = Tabs.Combat:AddLeftGroupbox("Aimbot")
CombatGroup:AddToggle("aimbot", { Text = "Enable Aimbot", Default = false })
CombatGroup:AddToggle("silentaim", { Text = "Silent Aim", Default = false })
CombatGroup:AddToggle("magicbullet", { Text = "Magic Bullet", Default = false })

-- Visuals sekmesi (örnek)
local VisualGroup = Tabs.Visuals:AddLeftGroupbox("ESP")
VisualGroup:AddToggle("espMaster", { Text = "Enable ESP", Default = false })
VisualGroup:AddToggle("espRainbow", { Text = "🌈 Rainbow Name", Default = false })
VisualGroup:AddToggle("espGlow", { Text = "✨ Glow", Default = false })
VisualGroup:AddToggle("espBox", { Text = "▣ 3D Box", Default = false })

-- Misc sekmesi
local MiscGroup = Tabs.Misc:AddLeftGroupbox("Movement")
MiscGroup:AddToggle("fly", { Text = "Fly", Default = false })
MiscGroup:AddToggle("noclip", { Text = "Noclip", Default = false })
MiscGroup:AddToggle("infjump", { Text = "Infinite Jump", Default = false })

-- Settings / Tema
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
ThemeManager:SetFolder("MYLFHub")
SaveManager:SetFolder("MYLFHub/saves")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

-- Tema: siyah-kırmızı
local th = ThemeManager:CurrentTheme()
th.Accent     = Color3.fromRGB(230, 0, 35)
th.Background = Color3.fromRGB(20, 20, 20)
th.Outline    = Color3.fromRGB(180, 0, 0)
