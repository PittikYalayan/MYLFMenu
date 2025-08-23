-- ⚡ MYLF | Hub ⚡ Core + Combat

local Library      = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

local Players   = game:GetService("Players")
local RunService= game:GetService("RunService")
local UIS       = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local features = { SilentAim=false, DeathMode=false, espObjects={}, envObjects={} }

----------------------------------------------------------------
-- Hedef bulucu (Aimbot + SilentAim için)
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
                -- TeamCheck
                if not (Toggles.espTeam and Player.Team and plr.Team and Player.Team == plr.Team) then
                    local dir = (head.Position - origin)
                    local dist= dir.Magnitude
                    local dot = look:Dot(dir.Unit)
                    local angle = math.deg(math.acos(dot))

                    -- WallCheck
                    local ray = Workspace:Raycast(origin, dir, params)
                    if (not ray or ray.Instance:IsDescendantOf(plr.Character)) then
                        if angle < bestScore then
                            best, bestScore = plr, angle
                        end
                    end
                end
            end
        end
    end
    return best
end

----------------------------------------------------------------
-- Aimbot (Smooth + WallCheck + TeamCheck)
----------------------------------------------------------------
function features.ToggleAimbot(on)
    if on then
        if features._aim then features._aim:Disconnect() end
        features._aim = RunService.RenderStepped:Connect(function()
            local target = getClosestTarget()
            if target and target.Character:FindFirstChild("Head") then
                local cam = Workspace.CurrentCamera
                local s = (Options.Smoothness and Options.Smoothness.Value) or 1
                local new = CFrame.new(cam.CFrame.Position, target.Character.Head.Position)
                cam.CFrame = (s>1) and cam.CFrame:Lerp(new,1/s) or new
            end
        end)
    else
        if features._aim then features._aim:Disconnect(); features._aim=nil end
    end
end

----------------------------------------------------------------
-- Silent Aim (Normal + Hard Hook)
----------------------------------------------------------------
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
                    if features.DeathMode and target.Character:FindFirstChild("MYLF_GhostHRP") then
                        aimPos = target.Character.MYLF_GhostHRP.Position
                    end
                    for i=1,#args do
                        if typeof(args[i])=="Vector3" then args[i]=aimPos break end
                        if typeof(args[i])=="CFrame" then args[i]=CFrame.new(args[i].Position,aimPos) break end
                    end
                    return old(self, unpack(args))
                end
            end
            return old(self,...)
        end)
    end
end

----------------------------------------------------------------
-- DeathMode (FarmBot tarzı, Ghost HRP)
----------------------------------------------------------------
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
                if ghost then
                    ghost.CFrame = myHRP.CFrame * CFrame.new(0,0,-3)
                end
            end
        end)
    else
        if features._death then features._death:Disconnect(); features._death=nil end
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("MYLF_GhostHRP") then
                plr.Character.MYLF_GhostHRP:Destroy()
            end
        end
    end
end

----------------------------------------------------------------
-- NoRecoil / NoSpread
----------------------------------------------------------------
function features.ToggleNoRecoil(on)
    if on then
        if features._norc then features._norc:Disconnect() end
        features._norc = RunService.Heartbeat:Connect(function()
            local tool = Player.Character and Player.Character:FindFirstChildOfClass("Tool")
            if tool then
                for _,v in ipairs(tool:GetDescendants()) do
                    if v:IsA("NumberValue") and v.Name:lower():find("recoil") then
                        v.Value = 0
                    end
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
                    if v:IsA("NumberValue") and (v.Name:lower():find("spread") or v.Name:lower():find("accuracy")) then
                        v.Value = 0
                    end
                end
            end
        end)
    else
        if features._nosp then features._nosp:Disconnect(); features._nosp=nil end
    end
end
----------------------------------------------------------------
-- === ESP Motoru (espmenu2’den entegre)
----------------------------------------------------------------

local espSettings = {
    Rainbow = false,
    Skeleton = false,
    Glow = false,
    Box3D = false,
    Stripes = false,
    Distance = false,
    Health = false,
    Tracers = false,
    TeamCheck = false,
    LOS = false,
    Range = 300,
    Arrows = false,
    CornerBox = false,
    FriendIgnore = false,
    Performance = "HIGH"
}

local espObjects = {}
function ApplyPlayerESP(plr)
    if not Toggles or not Toggles.espMaster or not Toggles.espMaster.Value then return end
    if not plr.Character then return end
    local head = plr.Character:FindFirstChild("Head")
    local hrp  = plr.Character:FindFirstChild("HumanoidRootPart")
    if not head or not hrp then return end

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
                text.TextColor3 = Color3.fromRGB(
                    math.sin(tick()*2)*127+128,
                    math.sin(tick()*2+2)*127+128,
                    math.sin(tick()*2+4)*127+128
                )
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
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and plr.Character and hrp then
                local dist = (Player.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
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
    if Drawing and Toggles.espTracers.Value then
        local line = Drawing.new("Line")
        line.Thickness = 1.5
        line.Color = Color3.fromRGB(0,255,0)
        RunService.RenderStepped:Connect(function()
            if hrp and plr.Character then
                local pos, onscreen = Workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
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
    if Drawing and Toggles.espArrows.Value then
        local arrow = Drawing.new("Triangle")
        arrow.Color = Color3.fromRGB(255,255,0)
        arrow.Filled = true
        RunService.RenderStepped:Connect(function()
            if hrp and plr.Character then
                local pos, onscreen = Workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
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
    if Drawing and Toggles.espCorner.Value then
        local lines = {}
        for i=1,4 do
            local l = Drawing.new("Line")
            l.Color = Color3.fromRGB(0,255,255)
            l.Thickness = 2
            table.insert(lines,l)
        end
        RunService.RenderStepped:Connect(function()
            if hrp and plr.Character then
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

    -- 🦴 Skeleton
    if Drawing and Toggles.espSkeleton.Value and plr.Character then
        local bones = {}
        RunService.RenderStepped:Connect(function()
            if plr.Character then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.RigType == Enum.HumanoidRigType.R15 then
                    local parts = {
                        { "Head","UpperTorso" },{ "UpperTorso","LowerTorso" },
                        { "UpperTorso","LeftUpperArm" },{ "LeftUpperArm","LeftLowerArm" },{ "LeftLowerArm","LeftHand" },
                        { "UpperTorso","RightUpperArm" },{ "RightUpperArm","RightLowerArm" },{ "RightLowerArm","RightHand" },
                        { "LowerTorso","LeftUpperLeg" },{ "LeftUpperLeg","LeftLowerLeg" },{ "LeftLowerLeg","LeftFoot" },
                        { "LowerTorso","RightUpperLeg" },{ "RightUpperLeg","RightLowerLeg" },{ "RightLowerLeg","RightFoot" },
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

    -- ≡ Box Stripes
    if Toggles.espStripes.Value and not plr.Character:FindFirstChild("MYLF_Stripes") then
        if hrp and head then
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
        end
    end
end

-- === Auto Add ===
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(1)
        ApplyPlayerESP(plr)
    end)
end)
----------------------------------------------------------------
-- === Environment ESP
----------------------------------------------------------------
function ApplyEnvESP(obj)
    if not Toggles.envMaster.Value then return end
    if not obj:IsA("BasePart") then return end
    local head = obj -- environment için "head" yerine objenin kendisini baz alıyoruz

    -- 🌈 Rainbow Label
    if Toggles.envRainbow and not obj:FindFirstChild("MYLF_EnvName") then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "MYLF_EnvName"
        billboard.Adornee = obj
        billboard.Size = UDim2.new(0,150,0,50)
        billboard.AlwaysOnTop = true
        billboard.Parent = obj
        local text = Instance.new("TextLabel", billboard)
        text.Size = UDim2.new(1,0,1,0)
        text.BackgroundTransparency = 1
        text.Text = obj.Name
        text.TextColor3 = Color3.fromRGB(255,255,255)
        text.TextScaled = true
        task.spawn(function()
            while Toggles.envRainbow.Value and billboard.Parent do
                text.TextColor3 = Color3.fromRGB(
                    math.sin(tick()*2)*127+128,
                    math.sin(tick()*2+2)*127+128,
                    math.sin(tick()*2+4)*127+128
                )
                task.wait(0.1)
            end
        end)
    end

    -- ✨ Highlight
    if Toggles.envHighlight.Value and not obj:FindFirstChild("MYLF_EnvHL") then
        local hl = Instance.new("Highlight")
        hl.Name = "MYLF_EnvHL"
        hl.FillColor = Color3.fromRGB(0,200,255)
        hl.OutlineColor = Color3.fromRGB(255,255,255)
        hl.Parent = obj
    end

    -- ▣ 3D Box
    if Toggles.envBox.Value and not obj:FindFirstChild("MYLF_EnvBox") then
        local box = Instance.new("SelectionBox")
        box.Name = "MYLF_EnvBox"
        box.Adornee = obj
        box.Color3 = Color3.fromRGB(0,255,0)
        box.Parent = obj
    end

    -- 📏 Distance (kamera mesafesi)
    if Toggles.envDist and not obj:FindFirstChild("MYLF_EnvDist") then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "MYLF_EnvDist"
        billboard.Adornee = obj
        billboard.Size = UDim2.new(0,100,0,50)
        billboard.StudsOffset = Vector3.new(0,2,0)
        billboard.AlwaysOnTop = true
        billboard.Parent = obj
        local text = Instance.new("TextLabel", billboard)
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
    end
end

-- Auto add environment (her yeni obje geldiğinde)
Workspace.DescendantAdded:Connect(function(obj)
    if Toggles.envMaster.Value then
        ApplyEnvESP(obj)
    end
end)

-- Auto refresh environment (her 5 saniyede bir)
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            for _,obj in ipairs(Workspace:GetDescendants()) do
                ApplyEnvESP(obj)
            end
        end)
    end
end)
----------------------------------------------------------------
-- === Menü Kurulumu
----------------------------------------------------------------
local Window = Library:CreateWindow({ 
    Title = "⚡ MYLF | Hub ⚡", 
    Center = true, 
    AutoShow = false 
})

-- Combat Tab
local CombatBox = Window:AddTab("Combat"):AddLeftGroupbox("Combat")
CombatBox:AddToggle("Aimbot", { Text="🎯 Aimbot" }):OnChanged(features.ToggleAimbot)
CombatBox:AddToggle("SilentAim", { Text="👀 Silent Aim" }):OnChanged(features.ToggleSilentAim)
CombatBox:AddToggle("DeathMode", { Text="☠ Death Mode" }):OnChanged(features.ToggleDeathMode)
CombatBox:AddToggle("NoRecoil", { Text="🔫 No Recoil" }):OnChanged(features.ToggleNoRecoil)
CombatBox:AddToggle("NoSpread", { Text="🎲 No Spread" }):OnChanged(features.ToggleNoSpread)

-- Player ESP Tab
local PlayerESP = Window:AddTab("Visuals"):AddLeftGroupbox("Player ESP")
PlayerESP:AddToggle("espMaster", { Text="Enable Player ESP" })
PlayerESP:AddToggle("espRainbow", { Text="🌈 Rainbow Name" })
PlayerESP:AddToggle("espSkeleton", { Text="🦴 Skeleton" })
PlayerESP:AddToggle("espGlow", { Text="✨ Glow" })
PlayerESP:AddToggle("espBox", { Text="▣ 3D Box" })
PlayerESP:AddToggle("espStripes", { Text="≡ Box Stripes" })
PlayerESP:AddToggle("espDist", { Text="📏 Distance" })
PlayerESP:AddToggle("espHP", { Text="❤️ Health Bar" })
PlayerESP:AddToggle("espTracers", { Text="〽 Tracers" })
PlayerESP:AddToggle("espArrows", { Text="⬅ Offscreen Arrows" })
PlayerESP:AddToggle("espCorner", { Text="⌞⌝ Corner Box 2D" })
PlayerESP:AddToggle("espTeam", { Text="👥 Team Check" })
PlayerESP:AddToggle("espLOS", { Text="🔭 LOS Only" })
PlayerESP:AddToggle("espRange", { Text="📡 Range 300" })
PlayerESP:AddToggle("espFriend", { Text="⭐ Friend Ignore" })
PlayerESP:AddDropdown("espPerf", { Values={"HIGH","MED","LOW"}, Default=1, Text="Performance" })

-- Environment ESP Tab
local EnvESP = Window:AddTab("Visuals"):AddRightGroupbox("Environment ESP")
EnvESP:AddToggle("envMaster", { Text="Enable Env ESP" })
EnvESP:AddToggle("envRainbow", { Text="🌈 Rainbow Name" })
EnvESP:AddToggle("envBox", { Text="▣ 3D Box" })
EnvESP:AddToggle("envDist", { Text="📏 Distance" })
EnvESP:AddToggle("envHighlight", { Text="✨ Highlight" })

----------------------------------------------------------------
-- === Config, Theme Manager
----------------------------------------------------------------
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
ThemeManager:SetFolder("MYLFHub")
SaveManager:SetFolder("MYLFHub")
SaveManager:BuildConfigSection(Window:AddTab("Config"))
ThemeManager:ApplyToTab(Window:AddTab("Config"))

----------------------------------------------------------------
-- === Menü Toggle (LeftShift)
----------------------------------------------------------------
local MENU_KEY = Enum.KeyCode.LeftShift
local function ToggleMenu() 
    if Library.MainFrame then
        Library.MainFrame.Visible = not Library.MainFrame.Visible
    else
        Library:Toggle()
    end
end
Library.ToggleKeybind = MENU_KEY
UIS.InputBegan:Connect(function(inp,gp)
    if not gp and inp.KeyCode == MENU_KEY then ToggleMenu() end
end)
