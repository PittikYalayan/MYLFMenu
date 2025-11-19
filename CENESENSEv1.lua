-- ═════════════════════════════════════════════ --
-- CENESENSE | PREMIUM v1.2.95 - FEATURES ENTEGRE
-- ═════════════════════════════════════════════ --

-- Features scriptini yukle
local features = loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features%2B%2B.lua"))()

-- Kavo UI yukle
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
    SilentAim = false,
    AimPart = "Head",
    FOV = 120,
    FOVVisible = false,
    TeamCheck = true,
    WallCheck = true,
    Triggerbot = false,
    Smoothness = 0.1,
    Prediction = true,
    PredictionAmount = 0.135
}

-- Features ayarlarını menü ile senkronize et
features.TeamCheck = getgenv().AimbotSettings.TeamCheck or true
features.AimRequireLOS = not getgenv().AimbotSettings.WallCheck or false -- tersine cevir
features.AimUseFOV = true -- FOV kullansin
features.AimMaxAngleDeg = getgenv().AimbotSettings.FOV or 120
features.Prediction = getgenv().AimbotSettings.Prediction or true
features.PredictionAmount = getgenv().AimbotSettings.PredictionAmount or 0.135
features.Smoothness = getgenv().AimbotSettings.Smoothness or 0.1
features.TriggerOnAim = getgenv().AimbotSettings.Triggerbot or false

AimSec:NewToggle("Enable Aimbot", "Activates aimbot and shows sub-settings", function(state)
    getgenv().AimbotSettings.Enabled = state
    features.ToggleAimbot(state)
    if state then
        local SubAimSec = AimbotTab:NewSection("Aimbot Sub-Settings")
        SubAimSec:NewToggle("Silent Aim", "No visual movement", function(v) 
            getgenv().AimbotSettings.SilentAim = v 
            features.ToggleSilentAim(v)
        end)
        SubAimSec:NewToggle("Triggerbot", "Auto shoot on target", function(v) 
            getgenv().AimbotSettings.Triggerbot = v 
            features.TriggerOnAim = v
        end)
        SubAimSec:NewDropdown("Aim Part", "Target body part", {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, function(v) 
            getgenv().AimbotSettings.AimPart = v 
            -- features'a entegre yoksa ignore
        end)
        SubAimSec:NewSlider("FOV Radius", "Field of view size", 360, 10, function(v) 
            getgenv().AimbotSettings.FOV = v 
            features.AimMaxAngleDeg = v
        end)
        SubAimSec:NewToggle("Show FOV Circle", "Visible FOV ring", function(v) 
            getgenv().AimbotSettings.FOVVisible = v 
            -- features'da yok, ignore veya custom FOV circle kodunu bırak
        end)
        SubAimSec:NewToggle("Team Check", "Ignore teammates", function(v) 
            getgenv().AimbotSettings.TeamCheck = v 
            features.TeamCheck = v
        end)
        SubAimSec:NewToggle("Wall Check", "Check through walls", function(v) 
            getgenv().AimbotSettings.WallCheck = v 
            features.AimRequireLOS = not v
        end)
        SubAimSec:NewToggle("Use Prediction", "Predict movement", function(v) 
            getgenv().AimbotSettings.Prediction = v 
            features.Prediction = v
        end)
        SubAimSec:NewSlider("Prediction Amount", "Velocity prediction", 0.5, 0, function(v) 
            getgenv().AimbotSettings.PredictionAmount = v 
            features.PredictionAmount = v
        end)
        SubAimSec:NewSlider("Smoothness", "0=instant, 1=legit", 1, 0, function(v) 
            getgenv().AimbotSettings.Smoothness = v 
            features.Smoothness = v
        end)
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
        SubESPSec:NewToggle("Box ESP", "3D boxes", function(v) 
            getgenv().ESPSettings.Box = v 
            features.ToggleBox(v)
            UpdatePreviewESP() 
        end)
        SubESPSec:NewToggle("Name ESP", "Player names", function(v) 
            getgenv().ESPSettings.Name = v 
            features.ToggleRainbowName(v)
        end)
        SubESPSec:NewToggle("Health Bar", "Health indicators", function(v) 
            getgenv().ESPSettings.Health = v 
            -- Health için custom kod, features'da yok
        end)
        SubESPSec:NewToggle("Tracers", "Lines to players", function(v) 
            getgenv().ESPSettings.Tracers = v 
            features.ToggleTracers(v)
            UpdatePreviewESP() 
        end)
        SubESPSec:NewToggle("Skeleton", "Bone outlines", function(v) 
            getgenv().ESPSettings.Skeleton = v 
            features.ToggleSkeleton(v)
        end)
        SubESPSec:NewToggle("Distance", "Distance labels", function(v) 
            getgenv().ESPSettings.Distance = v 
            -- Distance için custom kod, features'da yok
        end)
        SubESPSec:NewToggle("Chams (Fill)", "Highlight players", function(v) 
            getgenv().ESPSettings.Chams = v 
            features.ToggleGlow(v)
        end)
        SubESPSec:NewColorpicker("ESP Color", "Custom color", Color3.fromRGB(0,255,255), function(c) 
            getgenv().ESPSettings.Color = c 
            UpdatePreviewESP() 
            -- features'da color set yok, rainbow varsay
        end)
    else
        if PreviewViewport then PreviewViewport:Destroy() end
        Library:Notify("ESP disabled, sub-settings hidden.")
        -- Tüm ESP'leri kapat
        features.ToggleBox(false)
        features.ToggleRainbowName(false)
        features.ToggleTracers(false)
        features.ToggleSkeleton(false)
        features.ToggleGlow(false)
    end
end)

-- PLAYER TAB
local PlayerSec = PlayerTab:NewSection("Player Controls")
getgenv().PlayerSettings = { 
    MovementEnabled = false, 
    Fly = false, 
    Noclip = false, 
    FlySpeed = 50 
}

PlayerSec:NewToggle("Enable Movement Hacks", "Activates player mods and shows sub-settings", function(state)
    getgenv().PlayerSettings.MovementEnabled = state
    if state then
        local SubPlayerSec = PlayerTab:NewSection("Movement Sub-Settings")
        SubPlayerSec:NewSlider("WalkSpeed", "Speed modifier", 500, 16, function(v) 
            features.SetWalkSpeed(v)
            features.ToggleSpeed(true) -- her seferinde toggle et
        end)
        SubPlayerSec:NewSlider("JumpPower", "Jump height", 500, 50, function(v) 
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = v 
        end)
        SubPlayerSec:NewToggle("Fly (F key)", "Toggle flight", function(v) 
            getgenv().PlayerSettings.Fly = v 
            features.ToggleFly(v)
        end)
        SubPlayerSec:NewSlider("Fly Speed", "Uçma hızını ayarla", 500, 10, function(v) 
            getgenv().PlayerSettings.FlySpeed = v 
            features.SetFlySpeed(v)
        end)
        SubPlayerSec:NewToggle("Noclip", "Walk through walls", function(v) 
            getgenv().PlayerSettings.Noclip = v 
            features.ToggleNoclip(v)
        end)
        SubPlayerSec:NewButton("God Mode", "Become invincible (respawn)", function() 
            features.ToggleGodmode(true)
        end)
    else
        Library:Notify("Movement hacks disabled, sub-settings hidden.")
        features.ToggleSpeed(false)
        features.ToggleFly(false)
        features.ToggleNoclip(false)
        features.ToggleGodmode(false)
    end
end)

-- WORLD TAB (degismedi, features'da yok)
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

-- MISC TAB
local MiscSec = MiscTab:NewSection("Miscellaneous")
MiscSec:NewButton("MYLF Menu", "Yükle", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/meme11.6.lua"))()
end)
MiscSec:NewButton("Discord", "Kopyala", function()
    setclipboard("discord.gg/cenemarket")
end)

-- SETTINGS TAB
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
