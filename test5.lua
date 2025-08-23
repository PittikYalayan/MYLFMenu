-- ⚡ MYLF Universal Hub ⚡
local Library      = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local features = {
    espObjects = {},
    envObjects = {},
    SilentAim = false
}

----------------------------------------------------------------
-- Combat
----------------------------------------------------------------
function features.ToggleAimbot(on)
    if on then
        if features._aim then features._aim:Disconnect() end
        features._aim = RunService.RenderStepped:Connect(function()
            local cam = Workspace.CurrentCamera
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
        local tool = Player.Character and Player.Character:FindFirstChildOfClass("Tool")
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
        local tool = Player.Character and Player.Character:FindFirstChildOfClass("Tool")
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
-- Player ESP
----------------------------------------------------------------
local function ApplyPlayerESP(plr)
    if not Toggles.espMaster.Value then return end
    if not plr.Character then return end
    local head = plr.Character:FindFirstChild("Head")
    if not head then return end

    -- 🌈 Rainbow Name
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

    -- ✨ Glow
    if Toggles.espGlow.Value and not plr.Character:FindFirstChild("MYLF_Highlight") then
        local hl = Instance.new("Highlight")
        hl.Name = "MYLF_Highlight"
        hl.FillColor = Color3.fromRGB(255,0,0)
        hl.OutlineColor = Color3.fromRGB(255,255,255)
        hl.Parent = plr.Character
    end

    -- ▣ 3D Box
    if Toggles.espBox.Value and not plr.Character:FindFirstChild("MYLF_PlayerBox") then
        local box = Instance.new("SelectionBox")
        box.Name = "MYLF_PlayerBox"
        box.Adornee = plr.Character
        box.Color3 = Color3.fromRGB(0,255,0)
        box.Parent = plr.Character
    end

    -- 📏 Distance
    if Toggles.espDist.Value and not head:FindFirstChild("MYLF_Dist") then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "MYLF_Dist"
        billboard.Adornee = head
        billboard.Size = UDim2.new(0,200,0,50)
        billboard.StudsOffset = Vector3.new(0,2,0)
        billboard.AlwaysOnTop = true
        billboard.Parent = head
        local text = Instance.new("TextLabel", billboard)
        text.Size = UDim2.new(1,0,1,0)
        text.BackgroundTransparency = 1
        text.TextColor3 = Color3.fromRGB(255,255,0)
        text.TextScaled = true
        RunService.RenderStepped:Connect(function()
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (Player.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                text.Text = string.format("[%dm]", dist)
            end
        end)
    end

    -- ❤️ HP Bar
    if Toggles.espHP.Value and not head:FindFirstChild("MYLF_HP") then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "MYLF_HP"
        billboard.Adornee = head
        billboard.Size = UDim2.new(0,40,0,100)
        billboard.StudsOffset = Vector3.new(2,0,0)
        billboard.AlwaysOnTop = true
        billboard.Parent = head
        local frame = Instance.new("Frame", billboard)
        frame.Size = UDim2.new(1,0,1,0)
        frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
        local bar = Instance.new("Frame", frame)
        bar.BackgroundColor3 = Color3.fromRGB(0,255,0)
        bar.AnchorPoint = Vector2.new(0,1)
        bar.Position = UDim2.new(0,0,1,0)
        RunService.RenderStepped:Connect(function()
            local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                bar.Size = UDim2.new(1,0,hum.Health/hum.MaxHealth,0)
                bar.BackgroundColor3 = Color3.fromRGB(255*(1-hum.Health/hum.MaxHealth),255*(hum.Health/hum.MaxHealth),0)
            end
        end)
    end

    -- 〽 Tracers
    if Toggles.espTracers.Value then
        local line = Drawing.new("Line")
        line.Thickness = 1.5
        line.Color = Color3.fromRGB(0,255,0)
        RunService.RenderStepped:Connect(function()
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local pos, onscreen = Workspace.CurrentCamera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                if onscreen then
                    local screenSize = Workspace.CurrentCamera.ViewportSize
                    line.From = Vector2.new(screenSize.X/2, screenSize.Y)
                    line.To = Vector2.new(pos.X,pos.Y)
                    line.Visible = true
                else
                    line.Visible = false
                end
            else
                line.Visible = false
            end
        end)
    end

    -- ⬅ Offscreen Arrows
    if Toggles.espArrows.Value then
        local arrow = Drawing.new("Triangle")
        arrow.Color = Color3.fromRGB(255,255,0)
        arrow.Filled = true
        RunService.RenderStepped:Connect(function()
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local pos, onscreen = Workspace.CurrentCamera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                local screenSize = Workspace.CurrentCamera.ViewportSize
                if not onscreen then
                    local center = Vector2.new(screenSize.X/2, screenSize.Y/2)
                    local dir = (Vector2.new(pos.X,pos.Y) - center).Unit
                    local arrowCenter = center + dir*150
                    arrow.PointA = arrowCenter
                    arrow.PointB = arrowCenter + Vector2.new(-dir.Y,dir.X)*10
                    arrow.PointC = arrowCenter + Vector2.new(dir.Y,-dir.X)*10
                    arrow.Visible = true
                else
                    arrow.Visible = false
                end
            else
                arrow.Visible = false
            end
        end)
    end

    -- ⌞⌝ Corner Box 2D
    if Toggles.espCorner.Value then
        local lines = {}
        for i=1,4 do
            local l = Drawing.new("Line")
            l.Color = Color3.fromRGB(0,255,255)
            l.Thickness = 2
            table.insert(lines,l)
        end
        RunService.RenderStepped:Connect(function()
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = plr.Character.HumanoidRootPart
                local min,max = hrp.Position-Vector3.new(2,3,1), hrp.Position+Vector3.new(2,3,1)
                local cam = Workspace.CurrentCamera
                local a,visA = cam:WorldToViewportPoint(min)
                local b,visB = cam:WorldToViewportPoint(max)
                if visA and visB then
                    local tl = Vector2.new(a.X,a.Y)
                    local br = Vector2.new(b.X,b.Y)
                    lines[1].From, lines[1].To = tl, tl+Vector2.new(20,0)
                    lines[2].From, lines[2].To = tl, tl+Vector2.new(0,20)
                    lines[3].From, lines[3].To = br, br-Vector2.new(20,0)
                    lines[4].From, lines[4].To = br, br-Vector2.new(0,20)
                    for _,l in ipairs(lines) do l.Visible = true end
                else
                    for _,l in ipairs(lines) do l.Visible = false end
                end
            else
                for _,l in ipairs(lines) do l.Visible = false end
            end
        end)
    end
end

-- Refresh + Auto Add
local function RefreshAllPlayers()
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then
            ApplyPlayerESP(plr)
        end
    end
end
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(1)
        ApplyPlayerESP(plr)
    end)
end)

----------------------------------------------------------------
-- Environment ESP (kısaltılmış)
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
end
Workspace.DescendantAdded:Connect(ApplyEnvESP)

----------------------------------------------------------------
-- Menü Kurulumu (Combat / Player ESP / Env ESP / Misc)
----------------------------------------------------------------
local Window = Library:CreateWindow({Title="⚡ MYLF Universal Hub ⚡",Center=true,AutoShow=true})
local CombatBox = Window:AddTab("Combat"):AddLeftGroupbox("Combat")
CombatBox:AddToggle("Aimbot", { Text="Aimbot" }):OnChanged(features.ToggleAimbot)
CombatBox:AddToggle("SilentAim", { Text="Silent Aim" }):OnChanged(features.ToggleSilentAim)
CombatBox:AddToggle("NoRecoil", { Text="No Recoil" }):OnChanged(features.ToggleNoRecoil)
CombatBox:AddToggle("NoSpread", { Text="No Spread" }):OnChanged(features.ToggleNoSpread)

local PlayerESP = Window:AddTab("Visuals"):AddLeftGroupbox("Player ESP")
PlayerESP:AddToggle("espMaster", { Text="Enable Player ESP" })
PlayerESP:AddToggle("espRainbow", { Text="🌈 Rainbow Name" })
PlayerESP:AddToggle("espGlow", { Text="✨ Glow" })
PlayerESP:AddToggle("espBox", { Text="▣ 3D Box" })
PlayerESP:AddToggle("espDist", { Text="📏 Distance" })
PlayerESP:AddToggle("espHP", { Text="❤️ Health Bar" })
PlayerESP:AddToggle("espTracers", { Text="〽 Tracers" })
PlayerESP:AddToggle("espArrows", { Text="⬅ Offscreen Arrows" })
PlayerESP:AddToggle("espCorner", { Text="⌞⌝ Corner Box 2D" })

local EnvESP = Window:AddTab("Visuals"):AddRightGroupbox("Environment ESP")
EnvESP:AddToggle("envMaster", { Text="Enable Env ESP" })
EnvESP:AddToggle("envBox", { Text="▣ 3D Box" })
EnvESP:AddToggle("envHighlight", { Text="✨ Highlight" })

local MiscBox = Window:AddTab("Misc"):AddLeftGroupbox("Scanner")
MiscBox:AddButton("🔍 Refresh ESP", function()
    RefreshAllPlayers()
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
-- CTRL Gizle/Göster
----------------------------------------------------------------
UIS.InputBegan:Connect(function(input,gpe)
    if gpe then return end
    if input.KeyCode==Enum.KeyCode.LeftControl then
        Library:ToggleUI()
    end
end)
