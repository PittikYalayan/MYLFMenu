-- ⚡ MYLF Auto Character ESP ⚡
-- Executor ile çalışır
-- Sadece Workspace.Characters içindeki modeller için çalışır
-- Yeni gelenlere otomatik ekler, gidenleri otomatik temizler

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Characters klasörü
local charsFolder = Workspace:FindFirstChild("Characters")
if not charsFolder then
    warn("⚠️ Workspace.Characters bulunamadı!")
    return
end

-- Rainbow color
local function rainbowColor(offset)
    return Color3.fromHSV((tick() * 0.2 + offset) % 1, 1, 1)
end

-- Highlight + name ekleme
local function addCharESP(model)
    if not model:IsA("Model") then return end
    if model:FindFirstChild("MYLF_Highlight") then return end

    -- Highlight
    local hl = Instance.new("Highlight")
    hl.Name = "MYLF_Highlight"
    hl.Parent = model
    hl.FillTransparency = 1
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    -- Billboard
    local part = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
    if not part then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "MYLF_Name"
    billboard.Size = UDim2.new(0, 120, 0, 25)
    billboard.StudsOffset = Vector3.new(0, 5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = part

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = model.Name
    text.TextScaled = false
    text.TextSize = 14 -- küçük
    text.Font = Enum.Font.GothamBold
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.Parent = billboard

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(0, 0, 0)
    stroke.Transparency = 0.2
    stroke.Parent = text
end

-- Temizleme
local function removeCharESP(model)
    local hl = model:FindFirstChild("MYLF_Highlight")
    if hl then hl:Destroy() end

    local part = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
    if part then
        local gui = part:FindFirstChild("MYLF_Name")
        if gui then gui:Destroy() end
    end
end

-- Mevcut karakterler
for _, char in pairs(charsFolder:GetChildren()) do
    addCharESP(char)
end

-- Yeni eklenenler
charsFolder.ChildAdded:Connect(function(char)
    task.wait(0.2)
    addCharESP(char)
end)

-- Silinenler
charsFolder.ChildRemoved:Connect(function(char)
    removeCharESP(char)
end)

-- Rainbow updater
RunService.RenderStepped:Connect(function()
    for _, char in pairs(charsFolder:GetChildren()) do
        local hl = char:FindFirstChild("MYLF_Highlight")
        if hl then
            hl.OutlineColor = rainbowColor(0)
        end
        local part = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart")
        if part then
            local gui = part:FindFirstChild("MYLF_Name")
            if gui then
                local text = gui:FindFirstChildOfClass("TextLabel")
                if text then
                    text.TextColor3 = rainbowColor(0.3)
                end
            end
        end
    end
end)
