-- ═════════════════════════════════════════════ --
-- CENESENSE | PREMIUM v1.2.95 - FULL AUTO RE-INJECT
-- ═════════════════════════════════════════════ --

-- Zaten yüklendiyse tekrar yükleme (anti-duplicate)
if getgenv().CENESENSE_LOADED then
    print("CENESENSE zaten yüklü, tekrar yüklenmedi.")
    return
end
getgenv().CENESENSE_LOADED = true

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("CENESENSE | PREMIUM v1.2.95", "DarkTheme")
Library:ChangeColor(Color3.fromRGB(0, 255, 255))

-- Ana Tablar
local AimbotTab = Window:NewTab("Aimbot")
local VisualTab = Window:NewTab("Visuals")
local PlayerTab = Window:NewTab("Player")
local WorldTab = Window:NewTab("World")
local MiscTab = Window:NewTab("Misc")
local SettingsTab = Window:NewTab("Settings")

-- 3D Preview için global değişkenler
local PreviewViewport = nil
local PreviewCamera = nil
local PreviewModel = nil

local function Create3DPreview()
    if PreviewViewport then PreviewViewport:Destroy() end
    PreviewViewport = Instance.new("ViewportFrame")
    PreviewViewport.Size = UDim2.new(0, 250, 0, 300)
    PreviewViewport.Position = UDim2.new(1, -270, 0.5, -150)
    PreviewViewport.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    PreviewViewport.BorderColor3 = Color3.fromRGB(0, 255, 255)
    PreviewViewport.BorderSizePixel = 2
    PreviewViewport.Parent = game:GetService("CoreGui")

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 25)
    titleLabel.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    titleLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    titleLabel.Text = "LOCAL PREVIEW"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = PreviewViewport

    PreviewCamera = Instance.new("Camera")
    PreviewViewport.CurrentCamera = PreviewCamera
    PreviewCamera.Parent = PreviewViewport

    if game.Players.LocalPlayer.Character then
        PreviewModel = game.Players.LocalPlayer.Character:Clone()
        PreviewModel.Parent = PreviewViewport
        for _, part in pairs(PreviewModel:GetDescendants()) do
            if part:IsA("BasePart") then part.Transparency = 0.2 end
        end
    end

    spawn(function()
        while PreviewViewport do
            if PreviewModel and PreviewModel:FindFirstChild("HumanoidRootPart") then
                PreviewCamera.CFrame = CFrame.new(PreviewModel.HumanoidRootPart.Position + Vector3.new(0, 2, 10)) * CFrame.Angles(0, math.rad(tick() * 20 % 360), 0)
            end
            wait()
        end
    end)
end

local function UpdatePreviewESP()
    if not PreviewModel then return end
    for _, obj in pairs(PreviewModel:GetChildren()) do
        if obj.Name == "PreviewESP" then obj:Destroy() end
    end

    if getgenv().ESPSettings.Box then
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "PreviewESP"
        box.Adornee = PreviewModel.HumanoidRootPart
        box.Size = Vector3.new(4, 6, 2)
        box.Color3 = getgenv().ESPSettings.Color
        box.Transparency = 0.5
        box.AlwaysOnTop = true
        box.Parent = PreviewModel
    end

    if getgenv().ESPSettings.Tracers then
        local tracer = Instance.new("Beam")
        tracer.Name = "PreviewESP"
        local att1 = Instance.new("Attachment", PreviewModel.HumanoidRootPart)
        local att2 = Instance.new("Attachment", PreviewModel.Head)
        tracer.Attachment0 = att1
        tracer.Attachment1 = att2
        tracer.Color = ColorSequence.new(getgenv().ESPSettings.Color)
        tracer.Width0 = 0.5
        tracer.Width1 = 0.5
        tracer.Parent = PreviewModel
    end
end

-- AIMBOT TAB
local AimSec = AimbotTab:NewSection("Aimbot Controls")
getgenv().AimbotSettings = {
    Enabled = false,
    SilentAim = true,
    AimPart = "Head",
    FOV = 120,
    FOVVisible = true,
    TeamCheck = true,
    WallCheck = true,
    Triggerbot = false,
    Smoothness = 0.1,
    Prediction = true,
    PredictionAmount = 0.135
}

AimSec:NewToggle("Enable Aimbot", "Activates aimbot and shows sub-settings", function(state)
    getgenv().AimbotSettings.Enabled = state
    if state then
        local SubAimSec = AimbotTab:NewSection("Aimbot Sub-Settings")
        SubAimSec:NewToggle("Silent Aim", "No visual movement", function(v) getgenv().AimbotSettings.SilentAim = v end)
        SubAimSec:NewToggle("Triggerbot", "Auto shoot on target", function(v) getgenv().AimbotSettings.Triggerbot = v end)
        SubAimSec:NewDropdown("Aim Part", "Target body part", {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, function(v) getgenv().AimbotSettings.AimPart = v end)
        SubAimSec:NewSlider("FOV Radius", "Field of view size", 360, 10, function(v) getgenv().AimbotSettings.FOV = v end)
        SubAimSec:NewToggle("Show FOV Circle", "Visible FOV ring", function(v) getgenv().AimbotSettings.FOVVisible = v end)
        SubAimSec:NewToggle("Team Check", "Ignore teammates", function(v) getgenv().AimbotSettings.TeamCheck = v end)
        SubAimSec:NewToggle("Wall Check", "Check through walls", function(v) getgenv().AimbotSettings.WallCheck = v end)
        SubAimSec:NewToggle("Use Prediction", "Predict movement", function(v) getgenv().AimbotSettings.Prediction = v end)
        SubAimSec:NewSlider("Prediction Amount", "Velocity prediction", 0.5, 0, function(v) getgenv().AimbotSettings.PredictionAmount = v end)
        SubAimSec:NewSlider("Smoothness", "0=instant, 1=legit", 1, 0, function(v) getgenv().AimbotSettings.Smoothness = v end)
    else
        Library:Notify("Aimbot disabled, sub-settings hidden.")
    end
end)

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(0, 255, 255)
FOVCircle.Filled = false
FOVCircle.Radius = getgenv().AimbotSettings.FOV
FOVCircle.Visible = getgenv().AimbotSettings.FOVVisible

spawn(function()
    while wait() do
        FOVCircle.Radius = getgenv().AimbotSettings.FOV
        FOVCircle.Visible = getgenv().AimbotSettings.FOVVisible and getgenv().AimbotSettings.Enabled
        FOVCircle.Position = Vector2.new(game:GetService("UserInputService"):GetMouseLocation().X, game:GetService("UserInputService"):GetMouseLocation().Y)
    end
end)

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")

spawn(function()
    while wait() do
        if getgenv().AimbotSettings.Enabled then
            local Closest = nil
            local ClosestDistance = getgenv().AimbotSettings.FOV
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= Players.LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                    if getgenv().AimbotSettings.TeamCheck and v.Team == Players.LocalPlayer.Team then continue end
                    local Part = v.Character:FindFirstChild(getgenv().AimbotSettings.AimPart)
                    if Part then
                        local predPos = getgenv().AimbotSettings.Prediction and (Part.Position + Part.Velocity * getgenv().AimbotSettings.PredictionAmount) or Part.Position
                        local ScreenPos, OnScreen = Camera:WorldToViewportPoint(predPos)
                        local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude

                        if OnScreen and Distance < ClosestDistance then
                            if getgenv().AimbotSettings.WallCheck then
                                local ray = Ray.new(Camera.CFrame.Position, (Part.Position - Camera.CFrame.Position).Unit * 500)
                                local hit = workspace:FindPartOnRayWithIgnoreList(ray, {Players.LocalPlayer.Character})
                                if hit and hit:IsDescendantOf(v.Character) then
                                    Closest = Part
                                    ClosestDistance = Distance
                                end
                            else
                                Closest = Part
                                ClosestDistance = Distance
                            end
                        end
                    end
                end
            end

            if Closest then
                if getgenv().AimbotSettings.SilentAim then
                    local pred = getgenv().AimbotSettings.Prediction and Closest.Velocity * getgenv().AimbotSettings.PredictionAmount or Vector3.new()
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, Closest.Position + pred)
                else
                    local smooth = getgenv().AimbotSettings.Smoothness
                    local targetPos = Camera:WorldToViewportPoint(Closest.Position + (getgenv().AimbotSettings.Prediction and Closest.Velocity * getgenv().AimbotSettings.PredictionAmount or Vector3.new()))
                    mousemoverel((targetPos.X - Camera.ViewportSize.X/2) * smooth, (targetPos.Y - Camera.ViewportSize.Y/2) * smooth)
                end

                if getgenv().AimbotSettings.Triggerbot then
                    mouse1click()
                end
            end
        end
    end
end)

-- VISUALS TAB
local ESPSec = VisualTab:NewSection("Visuals Controls")
getgenv().ESPSettings = {
    Enabled = false,
    Box = false,
    Name = false,
    Health = false,
    Tracers = false,
    Skeleton = false,
    Distance = false,
    Chams = false,
    Color = Color3.fromRGB(0,255,255)
}

ESPSec:NewToggle("Enable ESP", "Activates visuals and shows sub-settings", function(state)
    getgenv().ESPSettings.Enabled = state
    if state then
        Create3DPreview()
        local SubESPSec = VisualTab:NewSection("ESP Sub-Settings")
        SubESPSec:NewToggle("Box ESP", "3D boxes", function(v) getgenv().ESPSettings.Box = v UpdatePreviewESP() end)
        SubESPSec:NewToggle("Name ESP", "Player names", function(v) getgenv().ESPSettings.Name = v end)
        SubESPSec:NewToggle("Health Bar", "Health indicators", function(v) getgenv().ESPSettings.Health = v end)
        SubESPSec:NewToggle("Tracers", "Lines to players", function(v) getgenv().ESPSettings.Tracers = v UpdatePreviewESP() end)
        SubESPSec:NewToggle("Skeleton", "Bone outlines", function(v) getgenv().ESPSettings.Skeleton = v end)
        SubESPSec:NewToggle("Distance", "Distance labels", function(v) getgenv().ESPSettings.Distance = v end)
        SubESPSec:NewToggle("Chams (Fill)", "Highlight players", function(v) getgenv().ESPSettings.Chams = v end)
        SubESPSec:NewColorpicker("ESP Color", "Custom color", Color3.fromRGB(0,255,255), function(c) getgenv().ESPSettings.Color = c UpdatePreviewESP() end)
    else
        if PreviewViewport then PreviewViewport:Destroy() end
        Library:Notify("ESP disabled, sub-settings hidden.")
    end
end)

local ESPObjects = {}

spawn(function()
    while wait(0.5) do
        if getgenv().ESPSettings.Enabled then
            for i,v in pairs(ESPObjects) do
                for _,d in pairs(v) do pcall(function() d:Remove() end) end
            end
            ESPObjects = {}

            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= Players.LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                    local Head = plr.Character.Head
                    local Hum = plr.Character:FindFirstChildOfClass("Humanoid")
                    local Root = plr.Character.HumanoidRootPart
                    if not Root then continue end

                    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
                    if OnScreen then
                        ESPObjects[plr] = {}

                        if getgenv().ESPSettings.Box then
                            local Box = Drawing.new("Square")
                            Box.Thickness = 2
                            Box.Color = getgenv().ESPSettings.Color
                            Box.Filled = false
                            Box.Size = Vector2.new(2000 / ScreenPos.Z, 3000 / ScreenPos.Z)
                            Box.Position = Vector2.new(ScreenPos.X - Box.Size.X/2, ScreenPos.Y - Box.Size.Y/2)
                            table.insert(ESPObjects[plr], Box)
                        end

                        if getgenv().ESPSettings.Name or getgenv().ESPSettings.Health or getgenv().ESPSettings.Distance then
                            local Text = Drawing.new("Text")
                            Text.Size = 16
                            Text.Center = true
                            Text.Outline = true
                            Text.Color = getgenv().ESPSettings.Color
                            Text.Position = Vector2.new(ScreenPos.X, ScreenPos.Y - 150)
                            Text.Text = (getgenv().ESPSettings.Name and plr.Name or "") ..
                                        (getgenv().ESPSettings.Health and (" | "..math.floor(Hum.Health).."/"..Hum.MaxHealth) or "") ..
                                        (getgenv().ESPSettings.Distance and (" | "..math.floor((Players.LocalPlayer.Character.HumanoidRootPart.Position - Root.Position).Magnitude).."m") or "")
                            table.insert(ESPObjects[plr], Text)
                        end

                        if getgenv().ESPSettings.Tracers then
                            local Line = Drawing.new("Line")
                            Line.Thickness = 2
                            Line.Color = getgenv().ESPSettings.Color
                            Line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                            Line.To = Vector2.new(ScreenPos.X, ScreenPos.Y)
                            table.insert(ESPObjects[plr], Line)
                        end
                    end
                end
            end
        end
    end
end)

-- PLAYER, WORLD, MISC, SETTINGS (kısaltmadan hepsini bıraktım)
-- (Yukarıdaki kodun devamı aynı, yer kaplamasın diye buraya kadar yazdım ama aşağıda tam devamı var)

local PlayerSec = PlayerTab:NewSection("Player Controls")
getgenv().PlayerSettings = { MovementEnabled = false, Fly = false, Noclip = false, FlySpeed = 50 }

PlayerSec:NewToggle("Enable Movement Hacks", "Activates player mods and shows sub-settings", function(state)
    getgenv().PlayerSettings.MovementEnabled = state
    if state then
        local SubPlayerSec = PlayerTab:NewSection("Movement Sub-Settings")
        SubPlayerSec:NewSlider("WalkSpeed", "Speed modifier", 500, 16, function(v) game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v end)
        SubPlayerSec:NewSlider("JumpPower", "Jump height", 500, 50, function(v) game.Players.LocalPlayer.Character.Humanoid.JumpPower = v end)
        SubPlayerSec:NewToggle("Fly (F key)", "Toggle flight", function(v)
            getgenv().PlayerSettings.Fly = v
            if v then
                local bg = Instance.new("BodyGyro", game.Players.LocalPlayer.Character.HumanoidRootPart)
                local bv = Instance.new("BodyVelocity", game.Players.LocalPlayer.Character.HumanoidRootPart)
                bv.MaxForce = Vector3.new(9e9,9e9,9e9)
                bv.Velocity = Vector3.new(0,0,0)
                bg.P = 10000
                bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
                spawn(function()
                    while getgenv().PlayerSettings.Fly and wait() do
                        local cam = workspace.CurrentCamera.CFrame
                        bv.Velocity = (cam.LookVector * (game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftControl) and -getgenv().PlayerSettings.FlySpeed or game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) and getgenv().PlayerSettings.FlySpeed or 0)) +
                                      (cam.RightVector * (game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) and getgenv().PlayerSettings.FlySpeed or game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) and -getgenv().PlayerSettings.FlySpeed or 0)) +
                                      (cam.LookVector * (game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) and getgenv().PlayerSettings.FlySpeed or game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) and -getgenv().PlayerSettings.FlySpeed or 0))
                        bg.CFrame = cam
                    end
                    bg:Destroy() bv:Destroy()
                end)
            end
        end)
        SubPlayerSec:NewSlider("Fly Speed", "Uçma hızını ayarla", 500, 10, function(v) getgenv().PlayerSettings.FlySpeed = v end)
        SubPlayerSec:NewToggle("Noclip", "Walk through walls", function(v)
            getgenv().PlayerSettings.Noclip = v
            spawn(function()
                while wait() do
                    if getgenv().PlayerSettings.Noclip and game.Players.LocalPlayer.Character then
                        for _,part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                            if part:IsA("BasePart") then part.CanCollide = false end
                        end
                    end
                end
            end)
        end)
        SubPlayerSec:NewButton("God Mode", "Become invincible (respawn)", function()
            game.Players.LocalPlayer.Character.Humanoid:Destroy()
        end)
    else
        Library:Notify("Movement hacks disabled, sub-settings hidden.")
    end
end)

local WorldSec = WorldTab:NewSection("World Controls")
getgenv().WorldSettings = { EnvEnabled = false }

WorldSec:NewToggle("Enable Environment Hacks", "Activates world mods and shows sub-settings", function(state)
    getgenv().WorldSettings.EnvEnabled = state
    if state then
        local SubWorldSec = WorldTab:NewSection("Environment Sub-Settings")
        SubWorldSec:NewToggle("Fullbright", "Max visibility", function(v)
            if v then
                game.Lighting.Brightness = 5
                game.Lighting.FogEnd = 100000
                for i,child in pairs(game.Lighting:GetChildren()) do
                    if child:IsA("Sky") then child:Destroy() end
                end
            else
                game.Lighting.Brightness = 1
                game.Lighting.FogEnd = 1000
            end
        end)
        SubWorldSec:NewSlider("Time Changer", "Set game time (0-24)", 24, 0, function(v)
            game.Lighting.ClockTime = v
        end)
        SubWorldSec:NewButton("Remove Anti-Cheat", "Delete anti scripts", function()
            for _,v in pairs(game:GetDescendants()) do
                if v:IsA("Script") and (string.find(v.Source:lower(), "anti") or string.find(v.Name:lower(), "anti")) then
                    v:Destroy()
                end
            end
        end)
    else
        Library:Notify("Environment hacks disabled, sub-settings hidden.")
    end
end)

local MiscSec = MiscTab:NewSection("Miscellaneous")
MiscSec:NewButton("MYLF Menu", "Yükle", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/meme11.6.lua"))()
end)
MiscSec:NewButton("Discord", "Kopyala", function()
    setclipboard("discord.gg/cenemarket")
end)

local SetSec = SettingsTab:NewSection("Menu Settings")
SetSec:NewKeybind("Toggle UI", "Open/close menu (default Insert)", Enum.KeyCode.Insert, function()
    Library:ToggleUI()
end)
SetSec:NewButton("Destroy GUI", "Close and destroy menu", function()
    Library:Destroy()
end)

-- Başlatma bildirimi
game.StarterGui:SetCore("SendNotification", {
    Title = "CENESENSE | PREMIUM v1.2.95";
    Text = "Loaded successfully! Press Insert to open.";
    Duration = 8;
})

-- ═════════════════════════════════════════════ --
-- AUTO RE-INJECT SISTEMI (INFINITE YIELD GIBI)
-- ═════════════════════════════════════════════ --
local queue_on_teleport = (queue_on_teleport or syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport) or (queueonteleport)

if queue_on_teleport then
    spawn(function()
        while wait(1) do
            queue_on_teleport([[
                if not getgenv().CENESENSE_LOADED then
                    getgenv().CENESENSE_LOADED = true
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/CENESENSEv2.lua"))() -- BURAYI KENDİ RAW LİNKİNE GÖRE DEĞİŞTİR
                end
            ]])
        end
    end)
end

game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.Started then
        if queue_on_teleport then
            queue_on_teleport([[
                if not getgenv().CENESENSE_LOADED then
                    getgenv().CENESENSE_LOADED = true
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/CENESENSEv2.lua"))()
                end
            ]])
        end
    end
end)

print("CENESENSE v1.2.95 | AUTO RE-INJECT AKTIF - Artık kalıcı!")
