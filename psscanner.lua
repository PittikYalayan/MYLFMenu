--== ⚡ MYLF Deep Remote Scanner ⚡ ==--

local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MYLF_RemotesScanner"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 600, 0, 400)
Frame.Position = UDim2.new(0.5, -300, 0.5, -200)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Frame.Visible = false
Frame.ZIndex = 1000
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(40,40,40)
Title.Text = "⚡ MYLF Deep Remote Scanner ⚡"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.ZIndex = 1001

local Scrolling = Instance.new("ScrollingFrame", Frame)
Scrolling.Position = UDim2.new(0, 0, 0, 30)
Scrolling.Size = UDim2.new(1, 0, 1, -70)
Scrolling.CanvasSize = UDim2.new(0,0,0,0)
Scrolling.BackgroundColor3 = Color3.fromRGB(25,25,25)
Scrolling.ZIndex = 1000

local Layout = Instance.new("UIListLayout", Scrolling)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 200, 0, 40)
ToggleBtn.Position = UDim2.new(0.5, -220, 0.9, 0)
ToggleBtn.Text = "Open Deep Remote Scanner"
ToggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
ToggleBtn.ZIndex = 1001
ToggleBtn.Parent = ScreenGui

-- Copy Button
local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0, 100, 0, 30)
CopyBtn.Position = UDim2.new(1, -110, 1, -40)
CopyBtn.Text = "📋 Copy All"
CopyBtn.TextColor3 = Color3.fromRGB(255,255,255)
CopyBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
CopyBtn.ZIndex = 1001
CopyBtn.Parent = Frame

-- Copied Label
local CopiedLabel = Instance.new("TextLabel")
CopiedLabel.Size = UDim2.new(0,100,0,20)
CopiedLabel.Position = UDim2.new(1, -110, 1, -70)
CopiedLabel.BackgroundTransparency = 1
CopiedLabel.Text = "Copied!"
CopiedLabel.TextColor3 = Color3.fromRGB(0,255,0)
CopiedLabel.Font = Enum.Font.GothamBold
CopiedLabel.TextSize = 14
CopiedLabel.Visible = false
CopiedLabel.ZIndex = 1002
CopiedLabel.Parent = Frame

-- Scanner Logic
local output = {}
local open = false

-- Full inspector: children, grandchildren, values
local function Inspect(obj, indent)
    indent = indent or ""
    local line = indent..obj.Name.." ["..obj.ClassName.."]"
    table.insert(output, line)

    -- Eğer Value objesi ise -> değerini yaz
    if obj:IsA("StringValue") or obj:IsA("IntValue") or obj:IsA("NumberValue") or obj:IsA("BoolValue") then
        table.insert(output, indent.."  > Value = "..tostring(obj.Value))
    end

    -- Remote ise işaretle
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        table.insert(output, indent.."  ⚡ REMOTE FOUND: "..obj.Name)
    end

    -- Çocukları gez
    for _,child in ipairs(obj:GetChildren()) do
        Inspect(child, indent.."   ")
    end
end

local function DeepScan()
    -- Clear UI + output
    for _,c in ipairs(Scrolling:GetChildren()) do
        if c:IsA("TextLabel") then c:Destroy() end
    end
    output = {}

    -- Ana klasörleri tara
    Inspect(workspace, "")
    Inspect(Players, "")
    Inspect(RS, "")

    for _,line in ipairs(output) do
        local lbl = Instance.new("TextLabel", Scrolling)
        lbl.Size = UDim2.new(1, -10, 0, 20)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.fromRGB(200,200,200)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Font = Enum.Font.Code
        lbl.TextSize = 13
        lbl.Text = line
        lbl.ZIndex = 1001
    end
    Scrolling.CanvasSize = UDim2.new(0,0,0,#output*20)

    if writefile then
        writefile("MYLF_DeepRemotes.txt", table.concat(output, "\n"))
        print("[MYLF] Deep Remote listesi kaydedildi: MYLF_DeepRemotes.txt")
    end
end

-- Copy All Action
CopyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(table.concat(output, "\n"))
        CopiedLabel.Visible = true
        task.delay(1.5, function() CopiedLabel.Visible = false end)
        print("[MYLF] Remote listesi panoya kopyalandı.")
    else
        warn("[MYLF] setclipboard API yok, kopyalama başarısız.")
    end
end)

-- Toggle Button Action
local function ToggleScanner()
    open = not open
    Frame.Visible = open
    if open then
        ToggleBtn.Text = "Close Deep Remote Scanner"
        DeepScan()
    else
        ToggleBtn.Text = "Open Deep Remote Scanner"
    end
end

ToggleBtn.MouseButton1Click:Connect(ToggleScanner)

-- Keybind (C tuşu ile aç/kapat)
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.C then
        ToggleScanner()
    end
end)
