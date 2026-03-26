--// SETTINGS
local range = 35 -- NPC arama menzili
local attackDistance = 3.5 -- Modelin senin ne kadar önünde duracağı (Biraz mesafe iyidir)
local attackSpeed = 0.15 -- Vuruş hızı (Saniye)

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// HELPER: SİLAH SEÇİCİ
local function equipBestWeapon()
    local char = player.Character
    if not char then return end
    
    if char:FindFirstChildOfClass("Tool") then return char:FindFirstChildOfClass("Tool") end
    
    -- Envanterdeki ilk tool'u çek (Balta, kılıç, mızrak fark etmez)
    local tool = player.Backpack:FindFirstChildOfClass("Tool")
    if tool then
        char.Humanoid:EquipTool(tool)
        return tool
    end
end

--// ANA DÖNGÜ
task.spawn(function()
    while true do
        task.wait(attackSpeed)
        
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
        local hrp = char.HumanoidRootPart
        
        -- Dump'taki Characters klasörünü tara
        local charFolder = workspace:FindFirstChild("Characters")
        if not charFolder then continue end

        for _, npcModel in pairs(charFolder:GetChildren()) do
            -- Model ve Can Kontrolü
            local hum = npcModel:FindFirstChildOfClass("Humanoid") or npcModel:FindFirstChild("NPC")
            if hum and hum.Health > 0 then
                
                -- NPC'nin ana parçasını bul (Head veya Root)
                local npcMainPart = npcModel:FindFirstChild("HumanoidRootPart") or npcModel:FindFirstChild("Head")
                
                if npcMainPart then
                    local dist = (hrp.Position - npcMainPart.Position).Magnitude
                    
                    if dist <= range then
                        -- 1. Silahı al
                        local weapon = equipBestWeapon()
                        
                        -- 2. MODELİ KOMPLE ÖNÜNE ÇEK
                        -- PivotTo kullanarak modeli tüm parçalarıyla beraber ışınlıyoruz
                        pcall(function()
                            -- Karakterin bakış yönüne göre 3.5 metre önü ve sana bakacak şekilde rotasyon
                            local targetCFrame = hrp.CFrame * CFrame.new(0, 0, -attackDistance) * CFrame.Angles(0, math.pi, 0)
                            npcModel:PivotTo(targetCFrame)
                            
                            -- Vururken sağa sola kaçmaması için ana parçayı sabitliyoruz
                            npcMainPart.Anchored = true 
                        end)

                        -- 3. VURUŞ VE TIKLAMA SİMÜLASYONU
                        task.spawn(function()
                            -- Görsel Tıklama (Virtual Mouse)
                            local screenPos = Camera:WorldToScreenPoint(npcMainPart.Position)
                            VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, game, 0)
                            task.wait(0.02)
                            VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, game, 0)
                            
                            -- Fiziksel Dokunma (Touch)
                            if weapon and weapon:FindFirstChildWhichIsA("BasePart") then
                                firetouchinterest(weapon:FindFirstChildWhichIsA("BasePart"), npcMainPart, 0)
                                task.wait()
                                firetouchinterest(weapon:FindFirstChildWhichIsA("BasePart"), npcMainPart, 1)
                            end
                            
                            -- Tool Fonksiyonunu Çalıştır
                            if weapon then weapon:Activate() end
                        end)
                    else
                        -- Menzilden çıkarsa sabitlemeyi kaldır ki NPC normal hayatına dönsün
                        pcall(function() npcMainPart.Anchored = false end)
                    end
                end
            end
        end
    end
end)

print("Full Model Kill Aura Aktif! NPC'ler artık komple önünüzde.")
