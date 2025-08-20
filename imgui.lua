-- imgui.lua
-- Gelişmiş ImGui tarzı Lua UI helper (Roblox için)
-- ✅ Sekme sistemi
-- ✅ Toggle / Slider / Button
-- ✅ Draggable pencere
-- ✅ Tema renkleri

local ImGui = {}
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Tema renkleri
local Theme = {
    Background = Color3.fromRGB(25,25,25),
    Accent = Color3.fromRGB(100,180,255),
    Button = Color3.fromRGB(40,40,40),
    ButtonHover = Color3.fromRGB(70,70,70),
    Text = Color3.fromRGB(220,220,220)
}

-- Ana pencere
function ImGui.Window(name, size, pos)
    local gui = Instance.new("ScreenGui")
    gui.Name = name or "ImGuiWindow"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui

    local frame = Instance.new("Frame", gui)
    frame.Size = size or UDim2.new(0,400,0,300)
    frame.Position = pos or UDim2.new(0.3,0,0.3,0)
    frame.BackgroundColor3 = Theme.Background
    frame.Active = true
    frame.Draggable = true

    local layout = Instance.new("UIListLayout", frame)
    layout.Padding = UDim.new(0,5)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    return frame
end

-- Sekme sistemi
function ImGui.TabControl(parent)
    local tabs = Instance.new("Frame", parent)
    tabs.Size = UDim2.new(1,0,0,30)
    tabs.BackgroundTransparency = 1

    local buttons = Instance.new("Frame", parent)
    buttons.Size = UDim2.new(1,0,1,-30)
    buttons.Position = UDim2.new(0,0,0,30)
    buttons.BackgroundTransparency = 1

    local tabPages = {}
    local activeTab = nil

    function tabPages:AddTab(tabName)
        local btn = Instance.new("TextButton", tabs)
        btn.Size = UDim2.new(0,100,1,0)
        btn.Text = tabName
        btn.BackgroundColor3 = Theme.Button
        btn.TextColor3 = Theme.Text
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 14

        local page = Instance.new("ScrollingFrame", buttons)
        page.Size = UDim2.new(1,0,1,0)
        page.Visible = false
        page.CanvasSize = UDim2.new(0,0,0,0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.ScrollBarThickness = 4
        page.BackgroundTransparency = 1

        local layout = Instance.new("UIListLayout", page)
        layout.Padding = UDim.new(0,5)
        layout.FillDirection = Enum.FillDirection.Vertical

        btn.MouseButton1Click:Connect(function()
            for _,p in pairs(buttons:GetChildren()) do
                if p:IsA("ScrollingFrame") then p.Visible = false end
            end
            for _,b in pairs(tabs:GetChildren()) do
                if b:IsA("TextButton") then b.BackgroundColor3 = Theme.Button end
            end
            page.Visible = true
            btn.BackgroundColor3 = Theme.ButtonHover
            activeTab = page
        end)

        if not activeTab then
            activeTab = page
            page.Visible = true
            btn.BackgroundColor3 = Theme.ButtonHover
        end

        return page
    end

    return tabPages
end

-- Buton
function ImGui.Button(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0,200,0,30)
    btn.Text = text
    btn.BackgroundColor3 = Theme.Button
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Theme.ButtonHover
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Theme.Button
    end)
    btn.MouseButton1Click:Connect(callback or function() end)

    return btn
end

-- Toggle
function ImGui.Toggle(parent, text, default, callback)
    local state = default or false
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0,200,0,30)
    btn.Text = text .. " : " .. tostring(state)
    btn.BackgroundColor3 = Theme.Button
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14

    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. " : " .. tostring(state)
        if callback then callback(state) end
    end)

    return btn
end

-- Slider
function ImGui.Slider(parent, text, min, max, default, callback)
    local value = default or min
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0,200,0,40)
    frame.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1,0,0,20)
    lbl.Text = text .. ": " .. value
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 14

    local slider = Instance.new("TextButton", frame)
    slider.Size = UDim2.new(1,0,0,15)
    slider.Position = UDim2.new(0,0,0,20)
    slider.BackgroundColor3 = Theme.Button
    slider.Text = ""

    local drag = Instance.new("Frame", slider)
    drag.Size = UDim2.new(0,10,1,0)
    drag.BackgroundColor3 = Theme.Accent
    drag.Position = UDim2.new((value-min)/(max-min), -5, 0, 0)

    local uis = game:GetService("UserInputService")
    local dragging = false

    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    uis.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    uis.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = (input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
            rel = math.clamp(rel,0,1)
            value = math.floor(min + (max-min)*rel)
            drag.Position = UDim2.new(rel,-5,0,0)
            lbl.Text = text .. ": " .. value
            if callback then callback(value) end
        end
    end)

    return frame
end

return ImGui
