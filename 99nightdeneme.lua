local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local workspace = game:GetService("Workspace")
local replicatedStorage = game:GetService("ReplicatedStorage")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local virtualInputManager = game:GetService("VirtualInputManager")
local mouse = player:GetMouse()

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RaygunSpawner"
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 420, 0, 280)
frame.Position = UDim2.new(0.5, -210, 0.5, -140)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local uc = Instance.new("UICorner")
uc.CornerRadius = UDim.new(0, 12)
uc.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "🔥 Tüm Raygun Spawner + Orijinal Al (Yeni!)"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 60)
status.Position = UDim2.new(0, 10, 0, 55)
status.BackgroundTransparency = 1
status.Text = "Hazır - Spawn'a basın, klonlar önünüze düşer.\nMouse klon üzerine + E bas = Orijinali al (tp + E + geri)!"
status.TextColor3 = Color3.fromRGB(100,255,100)
status.Font = Enum.Font.Gotham
status.TextSize = 15
status.TextWrapped = true
status.Parent = frame

local spawnBtn = Instance.new("TextButton")
spawnBtn.Size = UDim2.new(0.85, 0, 0, 55)
spawnBtn.Position = UDim2.new(0.075, 0, 0.35, 0)
spawnBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
spawnBtn.Text = "🚀 Tüm Raygun'ları Önüme Spawn Et"
spawnBtn.TextColor3 = Color3.new(1,1,1)
spawnBtn.Font = Enum.Font.GothamBold
spawnBtn.TextSize = 20
spawnBtn.Parent = frame

local btnUC = Instance.new("UICorner")
btnUC.CornerRadius = UDim.new(0, 10)
btnUC.Parent = spawnBtn

local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(0.4, 0, 0, 40)
refreshBtn.Position = UDim2.new(0.075, 0, 0.7, 0)
refreshBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
refreshBtn.Text = "🔄 Yenile Tarama"
refreshBtn.TextColor3 = Color3.new(1,1,1)
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = 16
refreshBtn.Parent = frame

local refreshUC = Instance.new("UICorner")
refreshUC.CornerRadius = UDim.new(0, 8)
refreshUC.Parent = refreshBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -45, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 24
closeBtn.Parent = frame

local closeUC = Instance.new("UICorner")
closeUC.CornerRadius = UDim.new(0, 8)
closeUC.Parent = closeBtn

local highlights = {}
local espLabels = {}
local rayguns = {}
local originalPositions = {}  -- Orijinal pozisyon sakla (index ile)

local function clearHighlights()
    for _, hl in ipairs(highlights) do
        if hl and hl.Parent then hl:Destroy() end
    end
    highlights = {}
end

local function clearESP()
    for _, lbl in ipairs(espLabels) do
        if lbl and lbl.Parent then lbl:Destroy() end
    end
    espLabels = {}
end

local function scanRayguns()
    rayguns = {}
    originalPositions = {}
    clearHighlights()
    status.Text = "Tarama yapılıyor..."
    
    local index = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("Tool") or obj:IsA("Model") or obj:IsA("BasePart")) and obj.Name:lower():find("raygun") then
            index += 1
            table.insert(rayguns, obj)
            originalPositions[index] = obj:IsA("Model") and obj:GetPivot() or obj.CFrame
            print("🔴 Workspace raygun: " .. obj:GetFullName())
        end
    end
    
    for _, obj in ipairs(replicatedStorage:GetDescendants()) do
        if (obj:IsA("Tool") or obj:IsA("Model") or obj:IsA("BasePart")) and obj.Name:lower():find("raygun") then
            index += 1
            table.insert(rayguns, obj)
            originalPositions[index] = CFrame.new(0,0,0)  -- Replicated için pozisyon yok, skip
            print("🟢 Replicated raygun: " .. obj:GetFullName())
        end
    end
    
    status.Text = #rayguns .. " raygun bulundu! Spawn'a basın.\nMouse klon üzerine + E = Orijinali al."
    print("=== " .. #rayguns .. " raygun hazır ===")
end

local function spawnAllRayguns()
    character = player.Character or player.CharacterAdded:Wait()
    if not character or not character:FindFirstChild("HumanoidRootPart") or #rayguns == 0 then return end
    
    local hrp = character.HumanoidRootPart
    local spawnedCount = 0
    
    for i, raygun in ipairs(rayguns) do
        local cloned = raygun:Clone()
        cloned.Parent = workspace
        
        -- Orijinal index/pozisyon sakla (attribute)
        cloned:SetAttribute("OriginalIndex", i)
        
        local handle = cloned:FindFirstChild("Handle") or cloned.PrimaryPart or cloned:FindFirstChildWhichIsA("BasePart")
        if handle then
            local offset = math.random(-3,3)
            handle.CFrame = hrp.CFrame * CFrame.new(offset, 3, -6)
            handle.AssemblyLinearVelocity = Vector3.new(math.random(-5,5), -10, math.random(-10,0))
            handle.CanCollide = true
            handle.Anchored = false
            
            local hl = Instance.new("Highlight")
            hl.Adornee = cloned
            hl.FillColor = Color3.fromRGB(0, 255, 255)
            hl.OutlineColor = Color3.fromRGB(255, 255, 0)
            hl.FillTransparency = 0.4
            hl.Parent = cloned
            table.insert(highlights, hl)
        end
        
        spawnedCount += 1
    end
    
    status.Text = spawnedCount .. " klon spawn edildi! Mouse tut + E = Orijinali al."
    print("🟢 " .. spawnedCount .. " raygun klon spawn!")
end

-- Realtime mouse ESP for klon
runService.Heartbeat:Connect(function()
    clearESP()
    
    local unitRay = workspace.CurrentCamera:ScreenPointToRay(mouse.X, mouse.Y)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    
    local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 500, params)
    if result and result.Instance then
        local hit = result.Instance
        local klon = hit:FindFirstAncestorWhichIsA("Model") or hit:FindFirstAncestorWhichIsA("Tool") or hit
        
        if klon and klon:GetAttribute("OriginalIndex") then
            local hl = Instance.new("Highlight")
            hl.Adornee = klon
            hl.FillColor = Color3.fromRGB(255, 0, 255)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.3
            hl.Parent = klon
            table.insert(highlights, hl)
            
            local bill = Instance.new("BillboardGui")
            bill.Adornee = klon
            bill.Size = UDim2.new(0, 200, 0, 50)
            bill.StudsOffset = Vector3.new(0, 5, 0)
            bill.Parent = klon
            local text = Instance.new("TextLabel")
            text.Size = UDim2.new(1, 0, 1, 0)
            text.BackgroundTransparency = 1
            text.Text = "E BAS = Orijinali al (tp + pickup + geri)"
            text.TextColor3 = Color3.new(1, 0, 1)
            text.Font = Enum.Font.GothamBold
            text.TextSize = 20
            text.Parent = bill
            table.insert(espLabels, bill)
        end
    end
end)

-- E tuşu dinle + orijinal al
userInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then
        local unitRay = workspace.CurrentCamera:ScreenPointToRay(mouse.X, mouse.Y)
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {character}
        params.FilterType = Enum.RaycastFilterType.Blacklist
        
        local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 500, params)
        if result and result.Instance then
            local hit = result.Instance
            local klon = hit:FindFirstAncestorWhichIsA("Model") or hit:FindFirstAncestorWhichIsA("Tool") or hit
            
            if klon and klon:GetAttribute("OriginalIndex") then
                local index = klon:GetAttribute("OriginalIndex")
                local originalPos = originalPositions[index]
                if originalPos and originalPos.p then  -- Pozisyon varsa (dropped ise)
                    local oldPos = hrp.CFrame
                    
                    -- Tp orijinal yere
                    hrp.CFrame = originalPos * CFrame.new(0, 3, -3)
                    wait(0.2)
                    
                    -- E bas (pickup)
                    virtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    wait(0.1)
                    virtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    
                    wait(0.3)
                    
                    -- Geri eski pos
                    hrp.CFrame = oldPos
                    
                    print("🟢 Orijinal raygun alındı! (tp + E + geri)")
                    status.Text = "Orijinal alındı! Tekrar spawn için yenile."
                else
                    print("🔴 Bu raygun replicated (pozisyon yok), orijinal alılamaz.")
                end
            end
        end
    end
end)

spawnBtn.MouseButton1Click:Connect(spawnAllRayguns)
refreshBtn.MouseButton1Click:Connect(scanRayguns)
closeBtn.MouseButton1Click:Connect(function()
    clearHighlights()
    clearESP()
    screenGui:Destroy()
end)

-- İlk tarama
scanRayguns()

print("🛡️ Raygun Spawner + Orijinal Al yüklendi! Mouse klon tut + E = Orijinali al efendim 🚀")
