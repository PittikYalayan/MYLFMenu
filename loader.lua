-- Linoria UI library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

local Window = Library:CreateWindow({
    Title = "⚡ MYLF Universal Hack Menu ⚡",
    Center = true, AutoShow = true,
})

local Tabs = {
    Main = Window:AddTab("Main"),
    Visuals = Window:AddTab("Visuals"),
    Misc = Window:AddTab("Misc"),
}

-- === ESP Tab ===
local ESPGroup = Tabs.Visuals:AddLeftGroupbox("ESP")
ESPGroup:AddToggle("ESPEnabled", {Text = "Enable ESP", Default = false})
ESPGroup:AddToggle("ESPName", {Text = "Show Names", Default = true})
ESPGroup:AddToggle("ESPSkeleton", {Text = "Show Skeleton", Default = false})
ESPGroup:AddColorPicker("ESPColor", {Text = "ESP Color", Default = Color3.fromRGB(0,255,0)})

-- === Aimbot Tab ===
local AimGroup = Tabs.Main:AddLeftGroupbox("Aimbot")
AimGroup:AddToggle("AimbotEnabled", {Text = "Enable Aimbot", Default = false})
AimGroup:AddSlider("FOV", {Text = "Aimbot FOV", Default = 50, Min = 10, Max = 500, Rounding = 0})

-- === Misc Tab ===
local MiscGroup = Tabs.Misc:AddLeftGroupbox("Misc")
MiscGroup:AddToggle("SpeedHack", {Text = "Speed Hack"})
MiscGroup:AddToggle("FlyHack", {Text = "Fly"})
MiscGroup:AddButton("Teleport to Cursor", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.LookVector * 50)
end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
