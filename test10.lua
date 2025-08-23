-- ⚡ MYLF | Hub ⚡ Core Setup
local Library      = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

local Players   = game:GetService("Players")
local RunService= game:GetService("RunService")
local UIS       = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local features = {}

----------------------------------------------------------------
-- Aim Target Finder
----------------------------------------------------------------
local function getClosestTarget()
    local cam = Workspace.CurrentCamera
    local origin = cam.CFrame.Position
    local look   = cam.CFrame.LookVector
    local best, bestScore = nil, math.huge

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {Player.Character}

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local head= plr.Character:FindFirstChild("Head")
            if hum and head and hum.Health > 0 then
                local dir = (head.Position - origin)
                local dist= dir.Magnitude
                local dot = look:Dot(dir.Unit)
                local angle = math.deg(math.acos(dot))

                local ray = Workspace:Raycast(origin, dir, params)
                if (not ray or ray.Instance:IsDescendantOf(plr.Character)) then
                    if angle < bestScore then
                        best, bestScore = plr, angle
                    end
                end
            end
        end
    end
    return best
end

----------------------------------------------------------------
-- Combat Functions
----------------------------------------------------------------
function features.ToggleAimbot(on)
    if on then
        if features._aim then features._aim:Disconnect() end
        features._aim = RunService.RenderStepped:Connect(function()
            local target = getClosestTarget()
            if target and target.Character:FindFirstChild("Head") then
                local cam = Workspace.CurrentCamera
                local new = CFrame.new(cam.CFrame.Position, target.Character.Head.Position)
                cam.CFrame = cam.CFrame:Lerp(new, 0.2) -- smooth aiming
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
        old = hookmetamethod(game, "__namecall", function(self,...)
            local method = getnamecallmethod()
            local args   = {...}
            if features.SilentAim and self:IsA("RemoteEvent") and (method=="FireServer" or method=="InvokeServer") then
                local target = getClosestTarget()
                if target and target.Character and target.Character:FindFirstChild("Head") then
                    local aimPos = target.Character.Head.Position
                    for i=1,#args do
                        if typeof(args[i])=="Vector3" then args[i]=aimPos break end
                        if typeof(args[i])=="CFrame" then args[i]=CFrame.new(args[i].Position, aimPos) break end
                    end
                    return old(self, unpack(args))
                end
            end
            return old(self,...)
        end)
    end
end

function features.ToggleDeathMode(on)
    features.DeathMode = on
    if on then
        if features._death then features._death:Disconnect() end
        features._death = RunService.Heartbeat:Connect(function()
            local myChar = Player.Character
            local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myHRP then return end
            local target = getClosestTarget()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = target.Character.HumanoidRootPart
                if not target.Character:FindFirstChild("MYLF_GhostHRP") then
                    local ghost = hrp:Clone()
                    ghost.Name = "MYLF_GhostHRP"
                    ghost.CanCollide = false
                    ghost.Transparency = 1
                    ghost.Parent = target.Character
                end
                local ghost = target.Character:FindFirstChild("MYLF_GhostHRP")
                if ghost then ghost.CFrame = myHRP.CFrame * CFrame.new(0,0,-3) end
            end
        end)
    else
        if features._death then features._death:Disconnect(); features._death=nil end
    end
end

function features.ToggleNoRecoil(on)
    if on then
        if features._norc then features._norc:Disconnect() end
        features._norc = RunService.Heartbeat:Connect(function()
            local tool = Player.Character and Player.Character:FindFirstChildOfClass("Tool")
            if tool then
                for _,v in ipairs(tool:GetDescendants()) do
                    if v:IsA("NumberValue") and v.Name:lower():find("recoil") then v.Value=0 end
                end
            end
        end)
    else
        if features._norc then features._norc:Disconnect(); features._norc=nil end
    end
end

function features.ToggleNoSpread(on)
    if on then
        if features._nosp then features._nosp:Disconnect() end
        features._nosp = RunService.Heartbeat:Connect(function()
            local tool = Player.Character and Player.Character:FindFirstChildOfClass("Tool")
            if tool then
                for _,v in ipairs(tool:GetDescendants()) do
                    if v:IsA("NumberValue") and (v.Name:lower():find("spread") or v.Name:lower():find("accuracy")) then v.Value=0 end
                end
            end
        end)
    else
        if features._nosp then features._nosp:Disconnect(); features._nosp=nil end
    end
end
----------------------------------------------------------------
-- === Player ESP Fonksiyonları (functions.lua mantığıyla)
----------------------------------------------------------------

-- 🌈 Rainbow Name
function features.ToggleESPRainbow(on)
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            if head then
                if on and not head:FindFirstChild("MYLF_Name") then
                    local gui = Instance.new("BillboardGui", head)
                    gui.Name = "MYLF_Name"
                    gui.Adornee = head
                    gui.Size = UDim2.new(0,200,0,50)
                    gui.AlwaysOnTop = true
                    local text = Instance.new("TextLabel", gui)
                    text.Size = UDim2.new(1,0,1,0)
                    text.BackgroundTransparency = 1
                    text.Text = plr.Name
                    text.TextScaled = true
                    task.spawn(function()
                        while on and gui.Parent do
                            text.TextColor3 = Color3.fromRGB(
                                math.sin(tick()*2)*127+128,
                                math.sin(tick()*2+2)*127+128,
                                math.sin(tick()*2+4)*127+128
                            )
                            task.wait(0.1)
                        end
                    end)
                elseif not on and head:FindFirstChild("MYLF_Name") then
                    head.MYLF_Name:Destroy()
                end
            end
        end
    end
end

-- ✨ Glow
function features.ToggleESPGlow(on)
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            if on and not plr.Character:FindFirstChild("MYLF_Highlight") then
                local hl = Instance.new("Highlight", plr.Character)
                hl.Name = "MYLF_Highlight"
                hl.FillColor = Color3.fromRGB(255,0,0)
                hl.OutlineColor = Color3.fromRGB(255,255,255)
            elseif not on and plr.Character:FindFirstChild("MYLF_Highlight") then
                plr.Character.MYLF_Highlight:Destroy()
            end
        end
    end
end

-- ▣ 3D Box
function features.ToggleESPBox(on)
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            if on and not plr.Character:FindFirstChild("MYLF_PlayerBox") then
                local box = Instance.new("SelectionBox", plr.Character)
                box.Name = "MYLF_PlayerBox"
                box.Adornee = plr.Character
                box.Color3 = Color3.fromRGB(0,255,0)
            elseif not on and plr.Character:FindFirstChild("MYLF_PlayerBox") then
                plr.Character.MYLF_PlayerBox:Destroy()
            end
        end
    end
end

-- 📏 Distance
function features.ToggleESPDistance(on)
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            if head then
                if on and not head:FindFirstChild("MYLF_Dist") then
                    local gui = Instance.new("BillboardGui", head)
                    gui.Name = "MYLF_Dist"
                    gui.Adornee = head
                    gui.Size = UDim2.new(0,200,0,50)
                    gui.AlwaysOnTop = true
                    local text = Instance.new("TextLabel", gui)
                    text.Size = UDim2.new(1,0,1,0)
                    text.BackgroundTransparency = 1
                    text.TextColor3 = Color3.fromRGB(255,255,0)
                    text.TextScaled = true
                    RunService.RenderStepped:Connect(function()
                        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") 
                           and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (Player.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                            text.Text = string.format("[%dm]", dist)
                        end
                    end)
                elseif not on and head:FindFirstChild("MYLF_Dist") then
                    head.MYLF_Dist:Destroy()
                end
            end
        end
    end
end

-- ❤️ Health Bar
function features.ToggleESPHealth(on)
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            if head then
                if on and not head:FindFirstChild("MYLF_HP") then
                    local gui = Instance.new("BillboardGui", head)
                    gui.Name = "MYLF_HP"
                    gui.Adornee = head
                    gui.Size = UDim2.new(0,40,0,100)
                    gui.AlwaysOnTop = true
                    local frame = Instance.new("Frame", gui)
                    frame.Size = UDim2.new(1,0,1,0)
                    frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
                    local bar = Instance.new("Frame", frame)
                    bar.AnchorPoint = Vector2.new(0,1)
                    bar.Position = UDim2.new(0,0,1,0)
                    bar.BackgroundColor3 = Color3.fromRGB(0,255,0)
                    RunService.RenderStepped:Connect(function()
                        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                        if hum then
                            bar.Size = UDim2.new(1,0,hum.Health/hum.MaxHealth,0)
                            bar.BackgroundColor3 = Color3.fromRGB(255*(1-hum.Health/hum.MaxHealth),255*(hum.Health/hum.MaxHealth),0)
                        end
                    end)
                elseif not on and head:FindFirstChild("MYLF_HP") then
                    head.MYLF_HP:Destroy()
                end
            end
        end
    end
end
-- 〽 Tracers
function features.ToggleESPTracers(on)
    if not Drawing then return end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if on then
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
        end
    end
end

-- ⬅ Offscreen Arrows
function features.ToggleESPArrows(on)
    if not Drawing then return end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then
            if on then
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
        end
    end
end

-- ⌞⌝ Corner Box 2D
function features.ToggleESPCorner(on)
    if not Drawing then return end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then
            if on then
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
    end
end

-- 🦴 Skeleton
function features.ToggleESPSkeleton(on)
    if not Drawing then return end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            if on then
                local bones = {}
                RunService.RenderStepped:Connect(function()
                    if plr.Character then
                        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                        if hum and hum.RigType == Enum.HumanoidRigType.R15 then
                            local parts = {
                                {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
                                {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
                                {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
                                {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
                                {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
                            }
                            for _,pair in ipairs(parts) do
                                local a = plr.Character:FindFirstChild(pair[1])
                                local b = plr.Character:FindFirstChild(pair[2])
                                if a and b then
                                    local line = bones[pair] or Drawing.new("Line")
                                    line.Color = Color3.fromRGB(255,255,255)
                                    line.Thickness = 1
                                    local p1,ok1 = Workspace.CurrentCamera:WorldToViewportPoint(a.Position)
                                    local p2,ok2 = Workspace.CurrentCamera:WorldToViewportPoint(b.Position)
                                    if ok1 and ok2 then
                                        line.From = Vector2.new(p1.X,p1.Y)
                                        line.To   = Vector2.new(p2.X,p2.Y)
                                        line.Visible = true
                                    else
                                        line.Visible = false
                                    end
                                    bones[pair] = line
                                end
                            end
                        end
                    end
                end)
            end
        end
    end
end

-- ≡ Box Stripes (Beam)
function features.ToggleESPStripes(on)
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local head= plr.Character:FindFirstChild("Head")
            if on and hrp and head and not plr.Character:FindFirstChild("MYLF_Stripes") then
                local att1 = Instance.new("Attachment", hrp)
                local att2 = Instance.new("Attachment", head)
                local beam = Instance.new("Beam")
                beam.Name = "MYLF_Stripes"
                beam.Attachment0 = att1
                beam.Attachment1 = att2
                beam.Width0 = 0.2
                beam.Width1 = 0.2
                beam.Color = ColorSequence.new(Color3.fromRGB(255,0,255))
                beam.Parent = plr.Character
            elseif not on and plr.Character:FindFirstChild("MYLF_Stripes") then
                plr.Character.MYLF_Stripes:Destroy()
            end
        end
    end
end
----------------------------------------------------------------
-- === Environment ESP Fonksiyonları
----------------------------------------------------------------

-- 🌈 Rainbow Name
function features.ToggleEnvRainbow(on)
    for _,obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if on and not obj:FindFirstChild("MYLF_EnvName") then
                local gui = Instance.new("BillboardGui", obj)
                gui.Name = "MYLF_EnvName"
                gui.Adornee = obj
                gui.Size = UDim2.new(0,150,0,50)
                gui.AlwaysOnTop = true
                local text = Instance.new("TextLabel", gui)
                text.Size = UDim2.new(1,0,1,0)
                text.BackgroundTransparency = 1
                text.Text = obj.Name
                text.TextScaled = true
                task.spawn(function()
                    while on and gui.Parent do
                        text.TextColor3 = Color3.fromRGB(
                            math.sin(tick()*2)*127+128,
                            math.sin(tick()*2+2)*127+128,
                            math.sin(tick()*2+4)*127+128
                        )
                        task.wait(0.1)
                    end
                end)
            elseif not on and obj:FindFirstChild("MYLF_EnvName") then
                obj.MYLF_EnvName:Destroy()
            end
        end
    end
end

-- ✨ Highlight
function features.ToggleEnvHighlight(on)
    for _,obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if on and not obj:FindFirstChild("MYLF_EnvHL") then
                local hl = Instance.new("Highlight", obj)
                hl.Name = "MYLF_EnvHL"
                hl.FillColor = Color3.fromRGB(0,200,255)
                hl.OutlineColor = Color3.fromRGB(255,255,255)
            elseif not on and obj:FindFirstChild("MYLF_EnvHL") then
                obj.MYLF_EnvHL:Destroy()
            end
        end
    end
end

-- ▣ 3D Box
function features.ToggleEnvBox(on)
    for _,obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if on and not obj:FindFirstChild("MYLF_EnvBox") then
                local box = Instance.new("SelectionBox", obj)
                box.Name = "MYLF_EnvBox"
                box.Adornee = obj
                box.Color3 = Color3.fromRGB(0,255,0)
            elseif not on and obj:FindFirstChild("MYLF_EnvBox") then
                obj.MYLF_EnvBox:Destroy()
            end
        end
    end
end

-- 📏 Distance
function features.ToggleEnvDistance(on)
    for _,obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if on and not obj:FindFirstChild("MYLF_EnvDist") then
                local gui = Instance.new("BillboardGui", obj)
                gui.Name = "MYLF_EnvDist"
                gui.Adornee = obj
                gui.Size = UDim2.new(0,100,0,50)
                gui.StudsOffset = Vector3.new(0,2,0)
                gui.AlwaysOnTop = true
                local text = Instance.new("TextLabel", gui)
                text.Size = UDim2.new(1,0,1,0)
                text.BackgroundTransparency = 1
                text.TextColor3 = Color3.fromRGB(255,255,0)
                text.TextScaled = true
                RunService.RenderStepped:Connect(function()
                    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (Player.Character.HumanoidRootPart.Position - obj.Position).Magnitude
                        text.Text = string.format("[%dm]", dist)
                    end
                end)
            elseif not on and obj:FindFirstChild("MYLF_EnvDist") then
                obj.MYLF_EnvDist:Destroy()
            end
        end
    end
end

----------------------------------------------------------------
-- === Auto Refresh (Yeni objeler eklendiğinde)
----------------------------------------------------------------
Workspace.DescendantAdded:Connect(function(obj)
    if features.EnvRainbow then features.ToggleEnvRainbow(true) end
    if features.EnvHighlight then features.ToggleEnvHighlight(true) end
    if features.EnvBox then features.ToggleEnvBox(true) end
    if features.EnvDistance then features.ToggleEnvDistance(true) end
end)
----------------------------------------------------------------
-- === Menü Setup (Linoria)
----------------------------------------------------------------
local Window = Library:CreateWindow({
    Title = "⚡ MYLF | Hub ⚡",
    Center = true,
    AutoShow = true
})

-- Combat Tab
local CombatTab = Window:AddTab("Combat")
local CombatBox = CombatTab:AddLeftGroupbox("Combat")
CombatBox:AddToggle("Aimbot", { Text="🎯 Aimbot" }):OnChanged(features.ToggleAimbot)
CombatBox:AddToggle("SilentAim", { Text="👀 Silent Aim" }):OnChanged(features.ToggleSilentAim)
CombatBox:AddToggle("DeathMode", { Text="☠ Death Mode" }):OnChanged(features.ToggleDeathMode)
CombatBox:AddToggle("NoRecoil", { Text="🔫 No Recoil" }):OnChanged(features.ToggleNoRecoil)
CombatBox:AddToggle("NoSpread", { Text="🎲 No Spread" }):OnChanged(features.ToggleNoSpread)

-- Player ESP Tab
local VisualsTab = Window:AddTab("Visuals")
local PlayerESP = VisualsTab:AddLeftGroupbox("Player ESP")
PlayerESP:AddToggle("espRainbow", { Text="🌈 Rainbow Name" }):OnChanged(features.ToggleESPRainbow)
PlayerESP:AddToggle("espGlow",    { Text="✨ Glow" }):OnChanged(features.ToggleESPGlow)
PlayerESP:AddToggle("espBox",     { Text="▣ 3D Box" }):OnChanged(features.ToggleESPBox)
PlayerESP:AddToggle("espDist",    { Text="📏 Distance" }):OnChanged(features.ToggleESPDistance)
PlayerESP:AddToggle("espHP",      { Text="❤️ Health Bar" }):OnChanged(features.ToggleESPHealth)
PlayerESP:AddToggle("espTracers", { Text="〽 Tracers" }):OnChanged(features.ToggleESPTracers)
PlayerESP:AddToggle("espArrows",  { Text="⬅ Offscreen Arrows" }):OnChanged(features.ToggleESPArrows)
PlayerESP:AddToggle("espCorner",  { Text="⌞⌝ Corner Box 2D" }):OnChanged(features.ToggleESPCorner)
PlayerESP:AddToggle("espSkeleton",{ Text="🦴 Skeleton" }):OnChanged(features.ToggleESPSkeleton)
PlayerESP:AddToggle("espStripes", { Text="≡ Box Stripes" }):OnChanged(features.ToggleESPStripes)

-- Environment ESP Tab
local EnvESP = VisualsTab:AddRightGroupbox("Environment ESP")
EnvESP:AddToggle("envRainbow", { Text="🌈 Rainbow Name" }):OnChanged(features.ToggleEnvRainbow)
EnvESP:AddToggle("envHighlight", { Text="✨ Highlight" }):OnChanged(features.ToggleEnvHighlight)
EnvESP:AddToggle("envBox", { Text="▣ 3D Box" }):OnChanged(features.ToggleEnvBox)
EnvESP:AddToggle("envDist", { Text="📏 Distance" }):OnChanged(features.ToggleEnvDistance)

-- Config Tab
local ConfigTab = Window:AddTab("Config")
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
ThemeManager:SetFolder("MYLFHub")
SaveManager:SetFolder("MYLFHub")
SaveManager:BuildConfigSection(ConfigTab)
ThemeManager:ApplyToTab(ConfigTab)

----------------------------------------------------------------
-- === Menü Toggle (LeftShift)
----------------------------------------------------------------
-- Menü toggle (garantili)
local UIS = game:GetService("UserInputService")
local MENU_KEY = Enum.KeyCode.LeftShift

local function ToggleMenu()
    if Library.Toggle then
        Library:Toggle()
    elseif Library.ToggleUI then
        Library:ToggleUI()
    end
end

-- Hem Linoria keybind, hem bizim fallback
Library.ToggleKeybind = MENU_KEY
UIS.InputBegan:Connect(function(inp, gp)
    if not gp and inp.KeyCode == MENU_KEY then
        ToggleMenu()
    end
end)
