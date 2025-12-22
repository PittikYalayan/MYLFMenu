local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local runService = game:GetService("RunService")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EquippedInfoGUI"
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 450, 0, 400)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "🛡️ Elindeki Eşya Bilgisi (Real-Time)"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 55)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Bekleniyor... (Eşya equipped edin)"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 16
statusLabel.Parent = mainFrame

local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, -20, 1, -140)
scrollingFrame.Position = UDim2.new(0, 10, 0, 90)
scrollingFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarThickness = 8
scrollingFrame.Parent = mainFrame

local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim.new(0, 8)
scrollCorner.Parent = scrollingFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = scrollingFrame

local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(0, 80, 0, 35)
refreshBtn.Position = UDim2.new(0, 15, 1, -40)
refreshBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
refreshBtn.Text = "🔄 Yenile"
refreshBtn.TextColor3 = Color3.new(1,1,1)
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = 16
refreshBtn.Parent = mainFrame

local refreshCorner = Instance.new("UICorner")
refreshCorner.CornerRadius = UDim.new(0, 8)
refreshCorner.Parent = refreshBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -45, 1, -40)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 20
closeBtn.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

local highlights = {}
local function clearHighlights()
    for _, hl in ipairs(highlights) do
        if hl and hl.Parent then hl:Destroy() end
    end
    highlights = {}
end

local function clearList()
    for _, child in ipairs(scrollingFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
end

local function addItemFrame(item, itemType)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 70)
    frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    frame.Parent = scrollingFrame
    
    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(0, 8)
    fCorner.Parent = frame
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -100, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 10, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = item.Name .. " (" .. itemType .. ")"
    nameLabel.TextColor3 = Color3.new(1,1,1)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 18
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = frame
    
    local pathLabel = Instance.new("TextLabel")
    pathLabel.Size = UDim2.new(1, -10, 0.5, 0)
    pathLabel.Position = UDim2.new(0, 5, 0.5, 0)
    pathLabel.BackgroundTransparency = 1
    pathLabel.Text = item:GetFullName()
    pathLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
    pathLabel.Font = Enum.Font.Gotham
    pathLabel.TextSize = 14
    pathLabel.TextXAlignment = Enum.TextXAlignment.Left
    pathLabel.TextWrapped = true
    pathLabel.Parent = frame
    
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, 90, 0, 30)
    copyBtn.Position = UDim2.new(1, -100, 0.15, 0)
    copyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    copyBtn.Text = "📋 Kopyala"
    copyBtn.TextColor3 = Color3.new(1,1,1)
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = 14
    copyBtn.Parent = frame
    
    local copyCorner = Instance.new("UICorner")
    copyCorner.CornerRadius = UDim.new(0, 6)
    copyCorner.Parent = copyBtn
    
    copyBtn.MouseButton1Click:Connect(function()
        setclipboard(item:GetFullName())
        copyBtn.Text = "✅ Kopyalandı!"
        wait(1)
        copyBtn.Text = "📋 Kopyala"
    end)
    
    -- Highlight ekle
    local hl = Instance.new("Highlight")
    hl.Adornee = item
    hl.FillColor = Color3.fromRGB(0, 255, 0)
    hl.OutlineColor = Color3.fromRGB(0, 255, 0)
    hl.FillTransparency = 0.6
    hl.OutlineTransparency = 0
    hl.Parent = item
    table.insert(highlights, hl)
    
    print("🟢 Equipped: " .. item.Name .. " | Path: " .. item:GetFullName())
end

local function scanEquipped(character)
    clearHighlights()
    clearList()
    local found = false
    
    -- Character child Tool/Model/Accessory tara
    for _, obj in ipairs(character:GetChildren()) do
        if obj:IsA("Tool") or obj:IsA("Model") or obj:IsA("Accessory") then
            addItemFrame(obj, obj.ClassName)
            found = true
        end
    end
    
    -- Player'da custom inventory tara (Folder/Value vs)
    for _, obj in ipairs(player:GetChildren()) do
        if obj:IsA("Folder") and (obj.Name:lower():find("inventory") or obj.Name:lower():find("loadout") or obj.Name:lower():find("backpack")) then
            for _, item in ipairs(obj:GetChildren()) do
                if item:IsA("Tool") or item:IsA("Model") then
                    addItemFrame(item, obj.Name .. " > " .. item.ClassName)
                    found = true
                end
            end
        end
    end
    
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
    end)
    
    if found then
        statusLabel.Text = "Bulundu: " .. #scrollingFrame:GetChildren() .. " eşya"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        statusLabel.Text = "Hiçbir eşya equipped değil!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end

local function onCharacterAdded(char)
    scanEquipped(char)
    -- Real-time update connections
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") or child:IsA("Model") or child:IsA("Accessory") then
            wait(0.1) -- Kısa delay animasyon için
            scanEquipped(char)
        end
    end)
    char.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") or child:IsA("Model") or child:IsA("Accessory") then
            wait(0.1)
            scanEquipped(char)
        end
    end)
end

-- İlk scan
if player.Character then
    onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

refreshBtn.MouseButton1Click:Connect(function()
    if player.Character then
        scanEquipped(player.Character)
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    clearHighlights()
    screenGui:Destroy()
end)

print("🛡️ Elindeki Eşya Tracker yüklendi! Equipped değiştirin, izleyin efendim.")
