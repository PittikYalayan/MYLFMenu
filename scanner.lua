--== ⚡ MYLF Scanner ⚡ ==--

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MYLF_Scanner"
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 450, 0, 320)
Frame.Position = UDim2.new(0.5, -225, 0.5, -160)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
Frame.Visible = false
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(40,40,40)
Title.Text = "⚡ MYLF Scanner ⚡"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

local Scrolling = Instance.new("ScrollingFrame", Frame)
Scrolling.Position = UDim2.new(0, 0, 0, 30)
Scrolling.Size = UDim2.new(1, 0, 1, -70)
Scrolling.CanvasSize = UDim2.new(0,0,0,0)
Scrolling.BackgroundColor3 = Color3.fromRGB(30,30,30)

local Layout = Instance.new("UIListLayout", Scrolling)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Copy All Button
local CopyBtn = Instance.new("TextButton", Frame)
CopyBtn.Size = UDim2.new(0, 100, 0, 30)
CopyBtn.Position = UDim2.new(0, 10, 1, -35)
CopyBtn.Text = "📋 Copy All"
CopyBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
CopyBtn.TextColor3 = Color3.fromRGB(255,255,255)

-- Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 150, 0, 40)
ToggleBtn.Position = UDim2.new(0.5, -75, 0.9, 0)
ToggleBtn.Text = "Open Scanner"
ToggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
ToggleBtn.Parent = ScreenGui

-- Scanner Logic
local output = {}

local function Traverse(obj, indent)
    indent = indent or ""
    table.insert(output, indent..obj.Name.." ["..obj.ClassName.."]")

    for _,child in ipairs(obj:GetChildren()) do
        table.insert(output, indent.."  - "..child.Name.." ["..child.ClassName.."]")

        if child:IsA("StringValue") or child:IsA("IntValue") or child:IsA("NumberValue") or child:IsA("BoolValue") then
            table.insert(output, indent.."     > Value = "..tostring(child.Value))
        end

        Traverse(child, indent.."   ")
    end
end

local function Scan()
    -- Clear UI + output
    for _,c in ipairs(Scrolling:GetChildren()) do
        if c:IsA("TextLabel") then c:Destroy() end
    end
    output = {}

    -- Taramalar
    Traverse(workspace, "")
    Traverse(Players, "")
    Traverse(RS, "")

    for _,line in ipairs(output) do
        local lbl = Instance.new("TextLabel", Scrolling)
        lbl.Size = UDim2.new(1, -10, 0, 20)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.fromRGB(220,220,220)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Font = Enum.Font.Code
        lbl.TextSize = 13
        lbl.Text = line
    end
    Scrolling.CanvasSize = UDim2.new(0,0,0,#output*20)

    -- Masaüstüne txt yazdır (exploit API gerekiyorsa)
    if writefile then
        writefile("MYLF_Scanner.txt", table.concat(output, "\n"))
        print("[MYLF] Scanner output yazıldı: MYLF_Scanner.txt")
    else
        warn("[MYLF] writefile desteklenmiyor (Synapse, Script-Ware vb. gerekiyor)")
    end
end

-- Copy All Action
CopyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(table.concat(output, "\n"))
        print("[MYLF] Scanner çıktısı panoya kopyalandı!")
    else
        warn("[MYLF] setclipboard API yok, kopyalama başarısız.")
    end
end)

-- Toggle Button Action
local open = false
ToggleBtn.MouseButton1Click:Connect(function()
    open = not open
    Frame.Visible = open
    if open then
        ToggleBtn.Text = "Close Scanner"
        Scan()
    else
        ToggleBtn.Text = "Open Scanner"
    end
end)
