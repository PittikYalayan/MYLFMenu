-- ⚡ MYLF Universal Hub ⚡
local Library      = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local features = {
    espObjects = {},
    envObjects = {}
}

----------------------------------------------------------------
-- Player ESP Functions
----------------------------------------------------------------
local function ApplyESP(plr)
    if not Toggles.espMaster.Value then return end
    if not plr.Character then return end
    local head = plr.Character:FindFirstChild("Head")
    if not head then return end

    -- 3D Box
    if Toggles.espBox.Value and not features.espObjects[plr] then
        local box = Instance.new("SelectionBox")
        box.Name = "MYLF_PlayerBox"
        box.Adornee = plr.Character
        box.Color3 = Color3.fromRGB(0,255,0)
        box.Parent = plr.Character
        features.espObjects[plr] = { Box = box }
    end

    -- Highlight
    if Toggles.espGlow.Value and not plr.Character:FindFirstChild("MYLF_Highlight") then
        local hl = Instance.new("Highlight")
        hl.Name = "MYLF_Highlight"
        hl.FillColor = Color3.fromRGB(255, 0, 0)
        hl.OutlineColor = Color3.fromRGB(255,255,255)
        hl.Parent = plr.Character
    end

    -- Rainbow Name
    if Toggles.espRainbow.Value and not head:FindFirstChild("MYLF_Name") then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "MYLF_Name"
        billboard.Adornee = head
        billboard.Size = UDim2.new(0,200,0,50)
        billboard.AlwaysOnTop = true
        billboard.Parent = head
        local text = Instance.new("TextLabel", billboard)
        text.Size = UDim2.new(1,0,1,0)
        text.BackgroundTransparency = 1
        text.Text = plr.Name
        text.TextColor3 = Color3.fromRGB(255,255,255)
        text.TextScaled = true
        task.spawn(function()
            while Toggles.espRainbow.Value and billboard.Parent do
                local t = tick()*2
                local r = math.sin(t)*127+128
                local g = math.sin(t+2)*127+128
                local b = math.sin(t+4)*127+128
                text.TextColor3 = Color3.fromRGB(r,g,b)
                task.wait(0.1)
            end
        end)
    end
end

local function RefreshAllPlayers()
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then
            ApplyESP(plr)
        end
    end
    if workspace:FindFirstChild("Bots") then
        for _,bot in ipairs(workspace.Bots:GetChildren()) do
            if bot:FindFirstChild("Head") then
                ApplyESP({Character = bot, Name = bot.Name})
            end
        end
    end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(1)
        ApplyESP(plr)
    end)
end)

----------------------------------------------------------------
-- Environment ESP Functions
----------------------------------------------------------------
local function ApplyEnvESP(obj)
    if not Toggles.envMaster.Value then return end
    if not obj:IsA("BasePart") then return end

    if Toggles.envBox.Value and not obj:FindFirstChild("MYLF_EnvBox") then
        local box = Instance.new("SelectionBox")
        box.Name = "MYLF_EnvBox"
        box.Adornee = obj
        box.Color3 = Color3.fromRGB(0,200,200)
        box.Parent = obj
    end

    if Toggles.envHighlight.Value and not obj:FindFirstChild("MYLF_EnvHL") then
        local hl = Instance.new("Highlight")
        hl.Name = "MYLF_EnvHL"
        hl.FillColor = Color3.fromRGB(0,0,255)
        hl.OutlineColor = Color3.fromRGB(255,255,0)
        hl.Parent = obj
    end
end

local function RefreshEnvironment()
    for _,obj in ipairs(workspace:GetDescendants()) do
        ApplyEnvESP(obj)
    end
end

workspace.DescendantAdded:Connect(function(obj)
    if Toggles.envMaster.Value then
        ApplyEnvESP(obj)
    end
end)

----------------------------------------------------------------
-- Combat (dummy bağlanabilir)
----------------------------------------------------------------
function features.ToggleAimbot(on) print("Aimbot:", on) end
function features.ToggleSilentAim(on) print("Silent Aim:", on) end
function features.ToggleNoRecoil(on) print("No Recoil:", on) end
function features.ToggleNoSpread(on) print("No Spread:", on) end

----------------------------------------------------------------
-- Menü Kurulumu
----------------------------------------------------------------
local Window = Library:CreateWindow({
    Title = "⚡ MYLF Universal Hub ⚡",
    Center = true,
    AutoShow = true
})

-- Combat
local CombatBox = Window:AddTab("Combat"):AddLeftGroupbox("Combat")
CombatBox:AddToggle("Aimbot", { Text = "Aimbot" }):OnChanged(features.ToggleAimbot)
CombatBox:AddToggle("SilentAim", { Text = "Silent Aim" }):OnChanged(features.ToggleSilentAim)
CombatBox:AddToggle("NoRecoil", { Text = "No Recoil" }):OnChanged(features.ToggleNoRecoil)
CombatBox:AddToggle("NoSpread", { Text = "No Spread" }):OnChanged(features.ToggleNoSpread)

-- Player ESP
local PlayerESP = Window:AddTab("Visuals"):AddLeftGroupbox("Player ESP")
PlayerESP:AddToggle("espMaster", { Text = "Enable Player ESP" })
PlayerESP:AddToggle("espRainbow", { Text = "🌈 Rainbow Name" })
PlayerESP:AddToggle("espSkeleton", { Text = "🦴 Skeleton" })
PlayerESP:AddToggle("espGlow", { Text = "✨ Glow" })
PlayerESP:AddToggle("espBox", { Text = "▣ 3D Box" })
PlayerESP:AddToggle("espDist", { Text = "📏 Distance" })
PlayerESP:AddToggle("espHP", { Text = "❤️ Health Bar" })
PlayerESP:AddToggle("espTracers", { Text = "〽 Tracers" })
PlayerESP:AddToggle("espArrows", { Text = "⬅ Offscreen Arrows" })
PlayerESP:AddToggle("espCorner", { Text = "⌞⌝ Corner Box 2D" })
PlayerESP:AddToggle("espTeam", { Text = "👥 Team Check" })
PlayerESP:AddToggle("espLOS", { Text = "🔭 LOS Only" })
PlayerESP:AddToggle("espRange", { Text = "📡 Range 300" })
PlayerESP:AddToggle("espFriend", { Text = "⭐ Friend Ignore" })

-- Environment ESP
local EnvESP = Window:AddTab("Visuals"):AddRightGroupbox("Environment ESP")
EnvESP:AddToggle("envMaster", { Text = "Enable Env ESP" })
EnvESP:AddToggle("envBox", { Text = "▣ 3D Box" })
EnvESP:AddToggle("envName", { Text = "📝 Name Tags" })
EnvESP:AddToggle("envHighlight", { Text = "✨ Highlight" })
EnvESP:AddToggle("envDist", { Text = "📏 Distance" })

-- Misc
local MiscBox = Window:AddTab("Misc"):AddLeftGroupbox("Scanner")
MiscBox:AddButton("🔍 Refresh ESP", function()
    RefreshAllPlayers()
    RefreshEnvironment()
    Library:Notify("ESP refreshed", 5)
end)

----------------------------------------------------------------
-- Tema & Save
----------------------------------------------------------------
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
ThemeManager:SetFolder("MYLFHub")
SaveManager:SetFolder("MYLFHub")
SaveManager:BuildConfigSection(Window:AddTab("Misc"))
ThemeManager:ApplyToTab(Window:AddTab("Misc"))

----------------------------------------------------------------
-- CTRL ile menü gizle/göster
----------------------------------------------------------------
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.LeftControl then
        Library:ToggleUI()
    end
end)
