--// SETTINGS
local range = 30 
local attackDistance = 3.5 
local attackSpeed = 0.1 -- Vuruş hızı (Saniye)

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local targetNPC = nil
local lastAttackTime = 0

--// SİLAH SEÇİCİ
local function equipWeapon()
    local char = player.Character
    if not char then return end
    local current = char:FindFirstChildOfClass("Tool")
    if current then return current end
    
    local tool = player.Backpack:FindFirstChildOfClass("Tool")
    if tool then
        char.Humanoid:EquipTool(tool)
        return tool
    end
end

--// EN YAKIN NPC'Yİ BULMA
local function getClosestNPC()
    local charFolder = workspace:FindFirstChild("Characters")
    if not charFolder then return nil end
    
    local closest = nil
    local shortestDist = range
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    for _, npc in pairs(charFolder:GetChildren()) do
        local hum = npc:FindFirstChildOfClass("Humanoid") or npc:FindFirstChild("NPC")
        local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Head")
        
        if hum and hum.Health > 0 and root then
            local dist = (hrp.Position - root.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                closest = npc
            end
        end
    end
    return closest
end

--// SMOOTH TELEPORT DÖNGÜSÜ (60 FPS AKICILIK)
RunService.RenderStepped:Connect(function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Her karede en yakın NPC'yi bul
    targetNPC = getClosestNPC()

    if targetNPC then
        local mainPart = targetNPC:FindFirstChild("HumanoidRootPart") or targetNPC:FindFirstChild("Head")
        if mainPart then
            -- NPC'yi dondur (Fizik motoruyla çakışmaması için)
            if not mainPart.Anchored then mainPart.Anchored = true end
            
            -- AKICI TAKİP: Her karede tam önünde olsun
            -- Lerp kullanmıyoruz çünkü seninle birebir aynı hızda gitmesi lazım
            local targetCFrame = hrp.CFrame * CFrame.new(0, 0, -attackDistance) * CFrame.Angles(0, math.pi, 0)
            targetNPC:PivotTo(targetCFrame)

            -- VURUŞ ZAMANI GELDİ Mİ?
            if tick() - lastAttackTime >= attackSpeed then
                lastAttackTime = tick()
                
                local weapon = equipWeapon()
                
                -- Mouse1 ve Etkileşim
                task.spawn(function()
                    if weapon then weapon:Activate() end
                    
                    -- Screen Point Tıklama
                    local screenPos = Camera:WorldToScreenPoint(mainPart.Position)
                    VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, game, 0)
                    task.wait(0.01)
                    VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, game, 0)
                    
                    -- TouchInterest Yedek
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

print("Smooth Kill Aura Aktif! Takılma sorunu çözüldü.")
