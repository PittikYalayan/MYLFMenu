-- ⚡ MYLF Universal Hub ⚡
local Library      = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

local Player = game.Players.LocalPlayer
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local features = {}

----------------------------------------------------------------
-- Combat Functionlar
----------------------------------------------------------------
function features.ToggleAimbot(on)
    if on then
        if features._aim then features._aim:Disconnect() end
        features._aim = RunService.RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera
            local target
            for _,plr in ipairs(Players:GetPlayers()) do
                if plr ~= Player and plr.Character and plr.Character:FindFirstChild("Head") then
                    target = plr.Character.Head
                    break
                end
            end
            if target then
                cam.CFrame = CFrame.new(cam.CFrame.Position, target.Position)
            end
        end)
    else
        if features._aim then features._aim:Disconnect(); features._aim=nil end
    end
end

function features.ToggleSilentAim(on)
    features.SilentAim = on
    if on and not features._ncHooked then
        features._ncHooked = true
        local old
        old = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            if features.SilentAim and self:IsA("RemoteEvent") and method == "FireServer" then
                for _,plr in ipairs(Players:GetPlayers()) do
                    if plr ~= Player and plr.Character and plr.Character:FindFirstChild("Head") then
                        args[1] = plr.Character.Head.Position
                        return old(self, unpack(args))
                    end
                end
            end
            return old(self, ...)
        end)
    end
end

function features.ToggleNoRecoil(on)
    if on then
        local ch = Player.Character
        local tool = ch and ch:FindFirstChildOfClass("Tool")
        if tool then
            for _,v in ipairs(tool:GetDescendants()) do
                if v:IsA("NumberValue") and v.Name:lower():find("recoil") then
                    v.Value = 0
                end
            end
        end
    end
end

function features.ToggleNoSpread(on)
    if on then
        local ch = Player.Character
        local tool = ch and ch:FindFirstChildOfClass("Tool")
        if tool then
            for _,v in ipairs(tool:GetDescendants()) do
                if v:IsA("NumberValue") and (v.Name:lower():find("spread") or v.Name:lower():find("accuracy")) then
                    v.Value = 0
                end
            end
        end
    end
end

----------------------------------------------------------------
-- Visuals Functionlar
----------------------------------------------------------------
function features.ToggleHighlight(on)
    if on then
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:FindFirstChild("MYLF_Highlight") then
                local hl = Instance.new("Highlight")
                hl.Name = "MYLF_Highlight"
                hl.FillColor = Color3.fromRGB(255,0,0)
                hl.OutlineColor = Color3.fromRGB(255,255,255)
                hl.Parent = obj
            end
        end
    else
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:FindFirstChild("MYLF_Highlight") then
                obj.MYLF_Highlight:Destroy()
            end
        end
    end
end

function features.ToggleBox3D(on)
    if on then
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:FindFirstChild("MYLF_Box3D") then
                local box = Instance.new("SelectionBox")
                box.Name = "MYLF_Box3D"
                box.Adornee = obj
                box.Color3 = Color3.fromRGB(0,255,0)
                box.Parent = obj
            end
        end
    else
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:FindFirstChild("MYLF_Box3D") then
                obj.MYLF_Box3D:Destroy()
            end
        end
    end
end

function features.ToggleRainbowName(on)
    if on then
        if features._rainbow then features._rainbow:Disconnect() end
        features._rainbow = RunService.Heartbeat:Connect(function()
            for _,obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local t = tick() * 2
                    local r = math.sin(t) * 127 + 128
                    local g = math.sin(t + 2) * 127 + 128
                    local b = math.sin(t + 4) * 127 + 128
                    pcall(function()
                        obj.Color = Color3.fromRGB(r,g,b)
                    end)
                end
            end
        end)
    else
        if features._rainbow then features._rainbow:Disconnect(); features._rainbow=nil end
    end
end

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

local CombatBox = Window:AddTab("Combat"):AddLeftGroupbox("Combat")
CombatBox:AddToggle("Aimbot", { Text = "Aimbot" }):OnChanged(features.ToggleAimbot)
CombatBox:AddToggle("SilentAim", { Text = "Silent Aim" }):OnChanged(features.ToggleSilentAim)
CombatBox:AddToggle("NoRecoil", { Text = "No Recoil" }):OnChanged(features.ToggleNoRecoil)
CombatBox:AddToggle("NoSpread", { Text = "No Spread" }):OnChanged(features.ToggleNoSpread)

local VisualsBox = Window:AddTab("Visuals"):AddLeftGroupbox("Visuals")
VisualsBox:AddToggle("Highlight", { Text = "Highlight" }):OnChanged(features.ToggleHighlight)
VisualsBox:AddToggle("Box3D", { Text = "3D Box" }):OnChanged(features.ToggleBox3D)
VisualsBox:AddToggle("RainbowName", { Text = "Rainbow Name" }):OnChanged(features.ToggleRainbowName)

local MiscBox = Window:AddTab("Misc"):AddLeftGroupbox("Scanner")
MiscBox:AddButton("🔍 Tara ve Uygula", function()
    features.ToggleHighlight(Toggles.Highlight.Value)
    features.ToggleBox3D(Toggles.Box3D.Value)
    features.ToggleRainbowName(Toggles.RainbowName.Value)
    features.ToggleNoRecoil(Toggles.NoRecoil.Value)
    features.ToggleNoSpread(Toggles.NoSpread.Value)
    Library:Notify("✅ Tarama ve özellikler uygulandı!", 5)
end)

----------------------------------------------------------------
-- Tema & Save
----------------------------------------------------------------
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("MYLFHub")
ThemeManager:SetFolder("MYLFHub")
SaveManager:BuildConfigSection(Window:AddTab("Misc"))
ThemeManager:ApplyToTab(Window:AddTab("Misc"))

----------------------------------------------------------------
-- CTRL ile menüyü gizle/göster
----------------------------------------------------------------
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.LeftControl then
        Library.MainFrame.Visible = not Library.MainFrame.Visible
    end
end)
