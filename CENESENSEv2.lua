-- ═════════════════════════════════════════════ --
-- CENESENSE | PREMIUM v1.2.95 - FULL AUTO RE-INJECT
-- ═════════════════════════════════════════════ --
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
local AimbotSubSection = nil
AimSec:NewToggle("Enable Aimbot", "Activates aimbot and shows sub-settings", function(state)
    getgenv().AimbotSettings.Enabled = state
    if state then
        if not AimbotSubSection then
            AimbotSubSection = AimbotTab:NewSection("Aimbot Sub-Settings")
            AimbotSubSection:NewToggle("Silent Aim", "No visual movement", function(v) getgenv().AimbotSettings.SilentAim = v end)
            AimbotSubSection:NewToggle("Triggerbot", "Auto shoot on target", function(v) getgenv().AimbotSettings.Triggerbot = v end)
            AimbotSubSection:NewDropdown("Aim Part", "Target body part", {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, function(v) getgenv().AimbotSettings.AimPart = v end)
            AimbotSubSection:NewSlider("FOV Radius", "Field of view size", 360, 10, function(v) getgenv().AimbotSettings.FOV = v end)
            AimbotSubSection:NewToggle("Show FOV Circle", "Visible FOV ring", function(v) getgenv().AimbotSettings.FOVVisible = v end)
            AimbotSubSection:NewToggle("Team Check", "Ignore teammates", function(v) getgenv().AimbotSettings.TeamCheck = v end)
            AimbotSubSection:NewToggle("Wall Check", "Check through walls", function(v) getgenv().AimbotSettings.WallCheck = v end)
            AimbotSubSection:NewToggle("Use Prediction", "Predict movement", function(v) getgenv().AimbotSettings.Prediction = v end)
            AimbotSubSection:NewSlider("Prediction Amount", "Velocity prediction", 0.5, 0, function(v) getgenv().AimbotSettings.PredictionAmount = v end)
            AimbotSubSection:NewSlider("Smoothness", "0=instant, 1=legit", 1, 0, function(v) getgenv().AimbotSettings.Smoothness = v end)
        end
        AimbotSubSection.sectorFrame.Visible = true
    else
        getgenv().AimbotSettings.SilentAim = false
        getgenv().AimbotSettings.Triggerbot = false
        getgenv().AimbotSettings.FOVVisible = false
        getgenv().AimbotSettings.TeamCheck = false
        getgenv().AimbotSettings.WallCheck = false
        getgenv().AimbotSettings.Prediction = false
        if AimbotSubSection then
            AimbotSubSection.sectorFrame.Visible = false
        end
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
local ESPSubSection = nil
ESPSec:NewToggle("Enable ESP", "Activates visuals and shows sub-settings", function(state)
    getgenv().ESPSettings.Enabled = state
    if state then
        if not ESPSubSection then
            ESPSubSection = VisualTab:NewSection("ESP Sub-Settings")
            ESPSubSection:NewToggle("Box ESP", "3D boxes", function(v) getgenv().ESPSettings.Box = v end)
            ESPSubSection:NewToggle("Name ESP", "Player names", function(v) getgenv().ESPSettings.Name = v end)
            ESPSubSection:NewToggle("Health Bar", "Health indicators", function(v) getgenv().ESPSettings.Health = v end)
            ESPSubSection:NewToggle("Tracers", "Lines to players", function(v) getgenv().ESPSettings.Tracers = v end)
            ESPSubSection:NewToggle("Skeleton", "Bone outlines", function(v) getgenv().ESPSettings.Skeleton = v end)
            ESPSubSection:NewToggle("Distance", "Distance labels", function(v) getgenv().ESPSettings.Distance = v end)
            ESPSubSection:NewToggle("Chams (Fill)", "Highlight players", function(v) getgenv().ESPSettings.Chams = v end)
            ESPSubSection:NewColorpicker("ESP Color", "Custom color", Color3.fromRGB(0,255,255), function(c) getgenv().ESPSettings.Color = c end)
        end
        ESPSubSection.sectorFrame.Visible = true
    else
        getgenv().ESPSettings.Box = false
        getgenv().ESPSettings.Name = false
        getgenv().ESPSettings.Health = false
        getgenv().ESPSettings.Tracers = false
        getgenv().ESPSettings.Skeleton = false
        getgenv().ESPSettings.Distance = false
        getgenv().ESPSettings.Chams = false
        if ESPSubSection then
            ESPSubSection.sectorFrame.Visible = false
        end
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
-- PLAYER TAB
local PlayerSec = PlayerTab:NewSection("Player Controls")
getgenv().PlayerSettings = { MovementEnabled = false, Fly = false, Noclip = false, FlySpeed = 50 }
local PlayerSubSection = nil
PlayerSec:NewToggle("Enable Movement Hacks", "Activates player mods and shows sub-settings", function(state)
    getgenv().PlayerSettings.MovementEnabled = state
    if state then
        if not PlayerSubSection then
            PlayerSubSection = PlayerTab:NewSection("Movement Sub-Settings")
            PlayerSubSection:NewSlider("WalkSpeed", "Speed modifier", 500, 16, function(v) game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v end)
            PlayerSubSection:NewSlider("JumpPower", "Jump height", 500, 50, function(v) game.Players.LocalPlayer.Character.Humanoid.JumpPower = v end)
            PlayerSubSection:NewToggle("Fly (F key)", "Toggle flight", function(v)
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
            PlayerSubSection:NewSlider("Fly Speed", "Uçma hızını ayarla", 500, 10, function(v) getgenv().PlayerSettings.FlySpeed = v end)
            PlayerSubSection:NewToggle("Noclip", "Walk through walls", function(v)
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
            PlayerSubSection:NewButton("God Mode", "Become invincible (respawn)", function()
                game.Players.LocalPlayer.Character.Humanoid:Destroy()
            end)
        end
        PlayerSubSection.sectorFrame.Visible = true
    else
        getgenv().PlayerSettings.Fly = false
        getgenv().PlayerSettings.Noclip = false
        if PlayerSubSection then
            PlayerSubSection.sectorFrame.Visible = false
        end
        Library:Notify("Movement hacks disabled, sub-settings hidden.")
    end
end)
-- WORLD TAB
local WorldSec = WorldTab:NewSection("World Controls")
getgenv().WorldSettings = { EnvEnabled = false }
local WorldSubSection = nil
WorldSec:NewToggle("Enable Environment Hacks", "Activates world mods and shows sub-settings", function(state)
    getgenv().WorldSettings.EnvEnabled = state
    if state then
        if not WorldSubSection then
            WorldSubSection = WorldTab:NewSection("Environment Sub-Settings")
            WorldSubSection:NewToggle("Fullbright", "Max visibility", function(v)
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
            WorldSubSection:NewSlider("Time Changer", "Set game time (0-24)", 24, 0, function(v)
                game.Lighting.ClockTime = v
            end)
            WorldSubSection:NewButton("Remove Anti-Cheat", "Delete anti scripts", function()
                for _,v in pairs(game:GetDescendants()) do
                    if v:IsA("Script") and (string.find(v.Source:lower(), "anti") or string.find(v.Name:lower(), "anti")) then
                        v:Destroy()
                    end
                end
            end)
        end
        WorldSubSection.sectorFrame.Visible = true
    else
        if WorldSubSection then
            WorldSubSection.sectorFrame.Visible = false
        end
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
