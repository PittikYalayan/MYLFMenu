-- ✨ GUI Menü Script ✨
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")

-- === Ana GUI ===
local gui = Instance.new("ScreenGui", playerGui)
gui.Name = "MainMenu"
gui.ResetOnSpawn = false

-- === Menü Butonu ===
local menuBtn = Instance.new("TextButton", gui)
menuBtn.Size = UDim2.new(0, 100, 0, 35)
menuBtn.Position = UDim2.new(1, -110, 0, 10)
menuBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 100)
menuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
menuBtn.Font = Enum.Font.SourceSansBold
menuBtn.Text = "☰ Menu"
menuBtn.TextSize = 18

-- === Panel ===
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 280, 0, 0)
frame.Position = UDim2.new(1, -300, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Visible = true
frame.ClipsDescendants = true
Instance.new("UICorner", frame)

-- Aç/Kapa Animasyonu
local panelOpen = false
menuBtn.MouseButton1Click:Connect(function()
    panelOpen = not panelOpen
    local goal = {}
    if panelOpen then
        goal.Size = UDim2.new(0, 280, 0, 680) -- ✨ daha uzun
    else
        goal.Size = UDim2.new(0, 280, 0, 0)
    end
    tweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal):Play()
end)

-- === Layout ===
local layout = Instance.new("UIListLayout", frame)
layout.Padding = UDim.new(0, 6) -- butonlar arası mesafe biraz daha küçük
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- === Genel Buton Yapıcı ===
local function makeButton(name, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35) -- ✨ genişlik tam frame (yanlardan 0 boşluk)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.Text = name
    btn.Parent = frame
    Instance.new("UICorner", btn)
    return btn
end





-- === Toggle butonu ===
local aimbotSilentBtn = makeButton("🎯🤫 Aimbot+Silent OFF", Color3.fromRGB(200,80,80))
local enabled = false
local aimConn, oldNamecall

-- En yakın kafa bulucu (zararlı amaçlı kullanılır)
local function getClosestVisibleHead()
    local cam = workspace.CurrentCamera
    local lp = game.Players.LocalPlayer
    local closest, dist = nil, math.huge
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= lp and plr.Character and plr.Character:FindFirstChild("Head") then
            local head = plr.Character.Head
            local screenPos, onScreen = cam:WorldToViewportPoint(head.Position)
            if onScreen then
                local mag = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
                if mag < dist then
                    dist, closest = mag, head
                end
            end
        end
    end
    return closest
end

-- Toggle click
aimbotSilentBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    if enabled then
        aimbotSilentBtn.Text = "🎯🤫 Aimbot+Silent ON"
        aimbotSilentBtn.BackgroundColor3 = Color3.fromRGB(0,200,100)

        -- [1] Aimbot Loop (zararlı)
        aimConn = game:GetService("RunService").RenderStepped:Connect(function()
            local head = getClosestVisibleHead()
            if head then
                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, head.Position)
            end
        end)

        -- [2] Silent Aim Hook (zararlı)
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            if enabled and method == "FireServer" then
                if tostring(self):lower():find("fire") or tostring(self):lower():find("shoot") then
                    local head = getClosestVisibleHead()
                    if head then
                        -- mermi pozisyonu kafaya zorlanıyor
                        if typeof(args[1]) == "Vector3" then
                            args[1] = head.Position
                        elseif args[2] and typeof(args[2]) == "Vector3" then
                            args[2] = head.Position
                        end
                        return oldNamecall(self, unpack(args))
                    end
                end
            end
            return oldNamecall(self, ...)
        end)

    else
        aimbotSilentBtn.Text = "🎯🤫 Aimbot+Silent OFF"
        aimbotSilentBtn.BackgroundColor3 = Color3.fromRGB(200,80,80)
        if aimConn then aimConn:Disconnect() end
        if oldNamecall then hookmetamethod(game,"__namecall",oldNamecall) end
    end
end)
