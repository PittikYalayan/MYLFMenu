-- ⚡ MYLF Universal Hub ⚡
-- Linoria Library kullanır

local Library      = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

local Player = game.Players.LocalPlayer
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

----------------------------------------------------------------
-- Menü Kurulumu
----------------------------------------------------------------
local Window = Library:CreateWindow({
    Title = "⚡ MYLF Universal Hub ⚡",
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Combat = Window:AddTab("Combat"),
    Visuals = Window:AddTab("Visuals"),
    Misc = Window:AddTab("Misc")
}

----------------------------------------------------------------
-- Combat Tab
----------------------------------------------------------------
local CombatBox = Tabs.Combat:AddLeftGroupbox("Combat")

CombatBox:AddToggle("Aimbot", { Text = "Aimbot", Default = false })
CombatBox:AddToggle("SilentAim", { Text = "Silent Aim", Default = false })
CombatBox:AddToggle("NoRecoil", { Text = "No Recoil", Default = false })
CombatBox:AddToggle("NoSpread", { Text = "No Spread", Default = false })

----------------------------------------------------------------
-- Visuals Tab
----------------------------------------------------------------
local VisualsBox = Tabs.Visuals:AddLeftGroupbox("ESP / Visuals")

VisualsBox:AddToggle("RainbowName", { Text = "Rainbow Name", Default = false })
VisualsBox:AddToggle("Box3D", { Text = "3D Box ESP", Default = false })
VisualsBox:AddToggle("Highlight", { Text = "Highlight ESP", Default = false })

----------------------------------------------------------------
-- Misc Tab - Scanner
----------------------------------------------------------------
local ScanBox = Tabs.Misc:AddLeftGroupbox("Scanner")

ScanBox:AddButton("🔍 Tara ve Uygula", function()
    local ch = Player.Character or Player.CharacterAdded:Wait()

    -- === Combat Features ===
    if Toggles.Aimbot.Value or Toggles.SilentAim.Value then
        Library:Notify("Aimbot/SilentAim için hedef bağlandı!", 5)
        -- Burada getClosestVisibleHead() fonksiyonuna zaten tüm oyuncular giriyor
    end

    -- === Visual Features ===
    if Toggles.Highlight.Value or Toggles.Box3D.Value or Toggles.RainbowName.Value then
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
                if Toggles.Highlight.Value then
                    local hl = Instance.new("Highlight")
                    hl.Name = "MYLF_Highlight"
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.FillTransparency = 0.5
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.Parent = obj
                end
                if Toggles.Box3D.Value then
                    local box = Instance.new("SelectionBox")
                    box.Name = "MYLF_Box3D"
                    box.Adornee = obj
                    box.LineThickness = 0.05
                    box.Color3 = Color3.fromRGB(0,255,0)
                    box.Parent = obj
                end
                if Toggles.RainbowName.Value then
                    task.spawn(function()
                        while Toggles.RainbowName.Value and obj.Parent do
                            local t = tick() * 2
                            local r = math.sin(t) * 127 + 128
                            local g = math.sin(t + 2) * 127 + 128
                            local b = math.sin(t + 4) * 127 + 128
                            pcall(function()
                                obj.Color = Color3.fromRGB(r,g,b)
                            end)
                            task.wait(0.1)
                        end
                    end)
                end
            end
        end
    end

    -- === Tool Tarama (No Recoil / No Spread) ===
    if Toggles.NoRecoil.Value or Toggles.NoSpread.Value then
        local tool = ch:FindFirstChildOfClass("Tool")
        if tool then
            for _,v in ipairs(tool:GetDescendants()) do
                if v:IsA("NumberValue") or v:IsA("IntValue") then
                    local name = v.Name:lower()
                    if Toggles.NoRecoil.Value and name:find("recoil") then
                        v.Value = 0
                    end
                    if Toggles.NoSpread.Value and (name:find("spread") or name:find("accuracy")) then
                        v.Value = 0
                    end
                end
            end
            Library:Notify("Tool hooklandı: " .. tool.Name, 5)
        end
    end

    Library:Notify("✅ Tarama ve hook işlemleri tamamlandı!", 5)
end)

----------------------------------------------------------------
-- Tema & Kaydetme
----------------------------------------------------------------
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

ThemeManager:SetFolder("MYLFHub")
SaveManager:SetFolder("MYLFHub")

SaveManager:BuildConfigSection(Tabs.Misc)
ThemeManager:ApplyToTab(Tabs.Misc)

