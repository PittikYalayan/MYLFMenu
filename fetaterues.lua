---------------box-
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local function createEsp(player)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255, 0, 0) -- Kırmızı kutu
    box.Thickness = 1
    box.Transparency = 1
    box.Filled = false

    local function update()
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local rPpt = player.Character.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToViewportPoint(rPpt.Position)

                if onScreen then
                    -- Mesafe bazlı boyut hesaplama (Optimize edilmiş)
                    local sizeX = 2000 / screenPos.Z
                    local sizeY = 3000 / screenPos.Z
                    
                    box.Size = Vector2.new(sizeX, sizeY)
                    box.Position = Vector2.new(screenPos.X - sizeX / 2, screenPos.Y - sizeY / 2)
                    box.Visible = true
                else
                    box.Visible = false
                end
            else
                box.Visible = false
                if not Players:FindFirstChild(player.Name) then
                    box:Remove()
                    connection:Disconnect()
                end
            end
        end)
    end
    coroutine.wrap(update)()
end

-- Mevcut ve yeni katılan oyuncular için başlat
for _, player in pairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer then
        createEsp(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    createEsp(player)
end)



----------------------------------------------------------------





local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local function createNameEsp(player)
    local nameText = Drawing.new("Text")
    nameText.Visible = false
    nameText.Center = true
    nameText.Outline = true -- Kalınlık hissi verir
    nameText.OutlineColor = Color3.fromRGB(0, 0, 0)
    
    -- FONT AYARI: 3 (Monospace) en kalın ve geniş duran seçenektir
    nameText.Font = 3 
    nameText.Size = 24 -- Boyutu daha da büyüttük
    nameText.Color = Color3.fromRGB(255, 255, 255)

    local function update()
        local connection
        connection = RunService.RenderStepped:Connect(function()
            local character = player.Character
            if character and character:FindFirstChild("Head") and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                local head = character.Head
                -- Yazının kafaya binmemesi için offseti artırdık
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 3, 0))

                if onScreen then
                    local distance = (Camera.CFrame.Position - head.Position).Magnitude
                    -- Mesafe uzaklaşsa bile yazının çok küçülüp incelmesini engelledik
                    local dynamicSize = math.clamp(3000 / distance, 18, 26)
                    
                    nameText.Size = dynamicSize
                    nameText.Position = Vector2.new(screenPos.X, screenPos.Y)
                    nameText.Text = player.Name:upper() -- Tamamı büyük harf (Kalın duruş için)
                    nameText.Visible = true
                else
                    nameText.Visible = false
                end
            else
                nameText.Visible = false
                if not Players:FindFirstChild(player.Name) then
                    nameText:Remove()
                    connection:Disconnect()
                end
            end
        end)
    end
    coroutine.wrap(update)()
end

-- Mevcut oyuncular
for _, player in pairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer then
        createNameEsp(player)
    end
end

-- Yeni gelenler
Players.PlayerAdded:Connect(function(player)
    createNameEsp(player)
end)


----------------------------------------------------------------



local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local function createTracer(player)
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = Color3.fromRGB(255, 255, 255) -- Beyaz çizgi (İstersen değiştirebilirsin)
    line.Thickness = 1.5 -- Çizgi kalınlığı
    line.Transparency = 0.7 -- Hafif şeffaflık (Göz yormaması için)

    local function update()
        local connection
        connection = RunService.RenderStepped:Connect(function()
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                local hrp = character.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

                if onScreen then
                    -- Çizginin başlangıç noktası: Ekranın üst ortası
                    line.From = Vector2.new(Camera.ViewportSize.X / 2, 0)
                    -- Çizginin bitiş noktası: Karakterin gövdesi
                    line.To = Vector2.new(screenPos.X, screenPos.Y)
                    line.Visible = true
                else
                    line.Visible = false
                end
            else
                line.Visible = false
                if not Players:FindFirstChild(player.Name) then
                    line:Remove()
                    connection:Disconnect()
                end
            end
        end)
    end
    coroutine.wrap(update)()
end

-- Mevcut oyuncular
for _, player in pairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer then
        createTracer(player)
    end
end

-- Yeni gelenler
Players.PlayerAdded:Connect(function(player)
    createTracer(player)
end)


aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa



local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui") -- Highlight'ı saklamak için en güvenli yer
 local RunService = game:GetService("RunService")

-- Premium Renk Paleti (İsteğe göre değiştirilebilir)
-- Öneri: Neon Cyan veya Mor çok premium durur.
local GLOW_COLOR = Color3.fromRGB(0, 255, 255) -- Neon Turkuaz (Cyan)
local OUTLINE_COLOR = Color3.fromRGB(255, 255, 255) -- Beyaz dış hat

-- Highlight ayarları için bir tablo (Optimize olması için dışarıda tanımladık)
local function applyPremiumSettings(highlight)
    highlight.FillColor = GLOW_COLOR
    highlight.OutlineColor = OUTLINE_COLOR
    highlight.FillTransparency = 0.5 -- İç dolgu şeffaflığı (Çok premium durur)
    highlight.OutlineTransparency = 0 -- Dış hat tam belirgin
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- DUVAR ARKASI GÖSTERİR
    highlight.Enabled = true
end

local function createGlowEsp(player)
    -- Karakterin yüklenmesini bekle (Optimize yol)
    player.CharacterAdded:Connect(function(character)
        -- Eğer önceden kalma bir highlight varsa temizle (Memory leak önleyici)
        if CoreGui:FindFirstChild(player.Name .. "_Glow") then
            CoreGui[player.Name .. "_Glow"]:Destroy()
        end

        -- Yeni bir Highlight oluştur
        local highlight = Instance.new("Highlight")
        highlight.Name = player.Name .. "_Glow"
        applyPremiumSettings(highlight)
        
        -- Highlight'ı karaktere bağla
        highlight.Adornee = character
        
        -- Parent'ı CoreGui yapıyoruz. Neden?
        -- 1. Oyuncunun workspace'ini kirletmez.
        -- 2. Client-side olduğu için lag yapmaz.
        highlight.Parent = CoreGui
    end)

    -- Eğer oyuncu oyuna girdiğinde karakteri zaten yüklüyse
    if player.Character then
        local character = player.Character
        if CoreGui:FindFirstChild(player.Name .. "_Glow") then
            CoreGui[player.Name .. "_Glow"]:Destroy()
        end
        local highlight = Instance.new("Highlight")
        highlight.Name = player.Name .. "_Glow"
        applyPremiumSettings(highlight)
        highlight.Adornee = character
        highlight.Parent = CoreGui
    end
end

-- Temizlik Fonksiyonu (Oyuncu çıktığında)
local function removeGlowEsp(player)
    if CoreGui:FindFirstChild(player.Name .. "_Glow") then
        CoreGui[player.Name .. "_Glow"]:Destroy()
    end
end

-- Başlatıcı ve Döngüler
for _, player in pairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer then
        createGlowEsp(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= Players.LocalPlayer then
        createGlowEsp(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeGlowEsp(player)
end)












