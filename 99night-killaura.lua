--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// SETTINGS
local range = 30 
local teleportDistance = 5 
local attackSpeed = 0.1 
local killauraEnabled = true
local lastAttackTime = 0
local lastTargetCount = -1 -- Liste optimizasyonu için

--// MODERN UI (NOVA STYLE)
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "MYLFHUB"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 240, 0, 320)
mainFrame.Position = UDim2.new(0.5, -120, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local topBar = Instance.new("Frame", mainFrame)
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
topBar.BorderSizePixel = 0
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", topBar)
title.Size = UDim2.new(1, -10, 1, 0); title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "MYLFHUB | KILL AURA"; title.TextColor3 = Color3.fromRGB(180, 100, 255)
title.Font = Enum.Font.GothamBold; title.TextSize = 14; title.TextXAlignment = Enum.TextXAlignment.Left; title.BackgroundTransparency = 1

local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(0.9, 0, 0, 35); toggleBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); toggleBtn.Text = "STATUS: ENABLED"
toggleBtn.TextColor3 = Color3.fromRGB(180, 100, 255); toggleBtn.Font = Enum.Font.GothamSemibold; toggleBtn.TextSize = 12
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

local listContainer = Instance.new("ScrollingFrame", mainFrame)
listContainer.Size = UDim2.new(0.9, 0, 0.65, 0); listContainer.Position = UDim2.new(0.05, 0, 0.3, 0)
listContainer.BackgroundTransparency = 1; listContainer.CanvasSize = UDim2.new(0, 0, 0, 0); listContainer.ScrollBarThickness = 0

-- LİSTEYİ ALT ALTA DİZEN ASIL KISIM (SABİT KALMALI)
local layout = Instance.new("UIListLayout", listContainer)
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder

--// DRAGGING
local dragging, dragStart, startPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = mainFrame.Position end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

--// TOGGLE & RIGHT CTRL
toggleBtn.MouseButton1Click:Connect(function()
    killauraEnabled = not killauraEnabled
    toggleBtn.Text = killauraEnabled and "STATUS: ENABLED" or "STATUS: DISABLED"
    toggleBtn.TextColor3 = killauraEnabled and Color3.fromRGB(180, 100, 255) or Color3.fromRGB(255, 100, 100)
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl then mainFrame.Visible = not mainFrame.Visible end
end)

--// NPC LISTER (FIXED)
local function updateUIList(targets)
    -- Eğer menzildeki NPC sayısı değişmediyse listeyi boşuna yenileme (Kasmayı önler)
    if #targets == lastTargetCount then return end
    lastTargetCount = #targets

    -- Mevcut etiketleri temizle (UIListLayout hariç)
    for _, child in pairs(listContainer:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    -- Yeni NPC'leri ekle
    for _, npc in pairs(targets) do
        local frame = Instance.new("Frame", listContainer)
        frame.Size = UDim2.new(1, 0, 0, 30)
        frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        frame.BorderSizePixel = 0
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
        
        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(1, -10, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.Text = "  " .. npc.Name
        lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
        lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12; lbl.BackgroundTransparency = 1
    end
    listContainer.CanvasSize = UDim2.new(0, 0, 0, #targets * 35)
end

--// FUNCTIONS (ORIGINAL)
local function equipWeapon()
    local char = player.Character
    if not char then return end
    local current = char:FindFirstChildOfClass("Tool")
    if current then return current end
    local tool = player.Backpack:FindFirstChildOfClass("Tool")
    if tool then char.Humanoid:EquipTool(tool); return tool end
end

local function getAllNPCsInRange()
    local charFolder = workspace:FindFirstChild("Characters")
    if not charFolder then return {} end
    local targets = {}
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return {} end

    for _, npc in pairs(charFolder:GetChildren()) do
        local hum = npc:FindFirstChildOfClass("Humanoid") or npc:FindFirstChild("NPC")
        local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Head")
        if hum and hum.Health > 0 and root then
            local dist = (hrp.Position - root.Position).Magnitude
            if dist <= range then table.insert(targets, npc) end
        end
    end
    return targets
end

--// MAIN LOOP
RunService.RenderStepped:Connect(function()
    if not killauraEnabled then 
        updateUIList({}) 
        return 
    end

    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local targets = getAllNPCsInRange()
    updateUIList(targets)

    local targetPositionCFrame = hrp.CFrame * CFrame.new(0, 0, -teleportDistance)

    for _, targetNPC in pairs(targets) do
        local mainPart = targetNPC:FindFirstChild("HumanoidRootPart") or targetNPC:FindFirstChild("Head")
        if mainPart then
            if not mainPart.Anchored then mainPart.Anchored = true end
            targetNPC:PivotTo(targetPositionCFrame * CFrame.Angles(0, math.pi, 0))

            if tick() - lastAttackTime >= attackSpeed then
                lastAttackTime = tick()
                local weapon = equipWeapon()
                
                task.spawn(function()
                    if weapon then weapon:Activate() end
                    local screenPos = Camera:WorldToScreenPoint(mainPart.Position)
                    VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, game, 0)
                    task.wait(0.01)
                    VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, game, 0)
                    
                    local toolPart = weapon and weapon:FindFirstChildWhichIsA("BasePart", true)
                    if toolPart then
                        firetouchinterest(toolPart, mainPart, 0)
                        firetouchinterest(toolPart, mainPart, 1)
                    end
                end)
            end
        end
    end
end)

print("Fixlendi! İsimler artık listede alt alta görünecek.")
