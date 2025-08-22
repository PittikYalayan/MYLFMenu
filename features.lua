-- === FEATURES (clean) ===
local runService = game:GetService("RunService")
local player     = game.Players.LocalPlayer
local features   = {}

-- ===== Speed =====
function features.SetSpeed(val)
    local function apply()
        local h = player.Character and player.Character:FindFirstChild("Humanoid")
        if h then h.WalkSpeed = val end
    end
    if features._speedConn then features._speedConn:Disconnect() end
    features._speedConn = runService.Heartbeat:Connect(apply)
    player.CharacterAdded:Connect(function() task.wait(1); apply() end)
end

-- ===== Godmode =====
function features.ToggleGodmode(val)
    local function apply()
        local h = player.Character and player.Character:FindFirstChild("Humanoid")
        if h then h.Health, h.MaxHealth = math.huge, math.huge end
    end
    if val then
        if features._godConn then features._godConn:Disconnect() end
        features._godConn = runService.Heartbeat:Connect(apply)
        player.CharacterAdded:Connect(function()
            task.wait(1)
            if features._godConn then features._godConn:Disconnect() end
            features._godConn = runService.Heartbeat:Connect(apply)
        end)
    else
        if features._godConn then features._godConn:Disconnect() end
    end
end

-- ===== Fly (⚠ LeftShift çakışmasını kaldırdım → iniş: LeftControl) =====
features._flySpeed = 60
function features.SetFlySpeed(v) features._flySpeed = v end
function features.ToggleFly(val)
    local uis = game:GetService("UserInputService")
    local function ensureBV()
        local char = player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        local bv = hrp:FindFirstChildOfClass("BodyVelocity")
        if not bv then
            bv = Instance.new("BodyVelocity", hrp)
            bv.MaxForce = Vector3.new(4000,4000,4000)
            bv.Velocity = Vector3.zero
        end
        return bv, hrp
    end
    if val then
        if features._flyConn then features._flyConn:Disconnect() end
        features._flyConn = runService.RenderStepped:Connect(function()
            local bv, hrp = ensureBV()
            if not (bv and hrp) then return end
            local dir = Vector3.zero
            local cam = workspace.CurrentCamera.CFrame
            if uis:IsKeyDown(Enum.KeyCode.W) then dir += cam.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.S) then dir -= cam.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.A) then dir -= cam.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.D) then dir += cam.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
            if uis:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end -- değişti
            bv.Velocity = dir * (features._flySpeed or 60)
        end)
        player.CharacterAdded:Connect(function() task.wait(1); if val then features.ToggleFly(true) end end)
    else
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then local bv = hrp:FindFirstChildOfClass("BodyVelocity"); if bv then bv:Destroy() end end
        if features._flyConn then features._flyConn:Disconnect() end
    end
end

-- ===== Infinite Jump =====
function features.ToggleInfiniteJump(val)
    local uis = game:GetService("UserInputService")
    if val then
        if features._infConn then features._infConn:Disconnect() end
        features._infConn = uis.JumpRequest:Connect(function()
            local h = player.Character and player.Character:FindFirstChild("Humanoid")
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if features._infConn then features._infConn:Disconnect() features._infConn=nil end
    end
end

-- ===== Teleport (T) =====
function features.ToggleTeleport(val)
    local uis = game:GetService("UserInputService")
    local mouse = player:GetMouse()
    if val then
        if features._tpConn then features._tpConn:Disconnect() end
        features._tpConn = runService.Heartbeat:Connect(function()
            if uis:IsKeyDown(Enum.KeyCode.T) then
                local char = player.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then char:MoveTo(mouse.Hit.p + Vector3.new(0,3,0)) end
            end
        end)
    else
        if features._tpConn then features._tpConn:Disconnect() features._tpConn=nil end
    end
end

-- ===== Aimbot (basit, dışarıdan Smoothness/TeamCheck okunur) =====
features.TeamCheck  = true
features.Smoothness = 5
function features.ToggleAimbot(val)
    local cam = workspace.CurrentCamera
    local function closestHead()
        local best, dist = nil, math.huge
        for _, plr in ipairs(game.Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid") then
                if not (features.TeamCheck and player.Team and plr.Team and player.Team==plr.Team) then
                    local head = plr.Character.Head
                    local v, on = cam:WorldToViewportPoint(head.Position)
                    if on then
                        local m = (Vector2.new(v.X,v.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
                        if m < dist then dist, best = m, head end
                    end
                end
            end
        end
        return best
    end
    if val then
        if features._aimConn then features._aimConn:Disconnect() end
        features._aimConn = runService.RenderStepped:Connect(function()
            local head = closestHead()
            if head then
                local target = CFrame.new(cam.CFrame.Position, head.Position)
                local s = (features.Smoothness or 1)
                cam.CFrame = (s>1) and cam.CFrame:Lerp(target, 1/s) or target
            end
        end)
    else
        if features._aimConn then features._aimConn:Disconnect() features._aimConn=nil end
    end
end

-- ===== Silent Aim / Rapid Fire / Kill Aura (senin mantık korunur) =====
-- (Bu üç fonksiyon sende zaten çalışıyordu; isimler değişmedi)
-- features.ToggleSilentAim(val)  -- <== mevcut senin fonksiyon içeriğin
-- features.ToggleRapidFire(val)  -- <== mevcut senin fonksiyon içeriğin
-- features.ToggleKillAura(val)   -- <== mevcut senin fonksiyon içeriğin

-- ===== ESP (FIX: tek tanım, düzgün cleanup, skeleton opsiyonel) =====
features._espRainbow  = features._espRainbow or false
features._espSkeleton = features._espSkeleton or false
features._espObjects  = {}

local function _espAdd(char, isNPC)
    if not char or not char.Parent then return end
    local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    if not head then return end
    local obj = features._espObjects[char]
    if not obj then obj = {}; features._espObjects[char] = obj end

    if not obj.highlight or not obj.highlight.Parent then
        local hl = Instance.new("Highlight")
        hl.FillTransparency = 0.5
        hl.OutlineColor     = Color3.fromRGB(255,255,255)
        hl.Parent = char
        obj.highlight = hl
    end

    if not obj.billboard or not obj.billboard.Parent then
        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.fromOffset(120, 20)
        bb.AlwaysOnTop = true
        bb.Adornee = head
        bb.Parent  = head
        local tl = Instance.new("TextLabel", bb)
        tl.Size = UDim2.fromScale(1,1)
        tl.BackgroundTransparency = 1
        tl.TextScaled = true
        tl.Font = Enum.Font.SourceSansBold
        tl.TextStrokeTransparency = 0.3
        local pl = game.Players:GetPlayerFromCharacter(char)
        tl.Text = pl and pl.Name or (isNPC and "NPC" or "Enemy")
        tl.TextColor3 = Color3.fromRGB(255,255,255)
        obj.billboard, obj.label = bb, tl
    end
end

local function _espCleanup(char)
    local obj = features._espObjects[char]
    if not obj then return end
    if obj.highlight then obj.highlight:Destroy() end
    if obj.billboard then obj.billboard:Destroy() end
    if obj.lines then for _,ln in ipairs(obj.lines) do pcall(function() ln:Remove() end) end end
    features._espObjects[char] = nil
end

function features.ToggleESP(val)
    if val then
        -- başlangıç yüklemesi
        for _, plr in ipairs(game.Players:GetPlayers()) do
            if plr.Character then _espAdd(plr.Character, false) end
            plr.CharacterAdded:Connect(function(c) task.wait(1); _espAdd(c, false) end)
        end
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:FindFirstChildOfClass("Humanoid") and not game.Players:GetPlayerFromCharacter(obj) then
                _espAdd(obj, true)
            end
        end
        features._espWorldConn = workspace.ChildAdded:Connect(function(obj)
            if obj:FindFirstChildOfClass("Humanoid") and not game.Players:GetPlayerFromCharacter(obj) then
                task.wait(1); _espAdd(obj, true)
            end
        end)

        -- update loop
        if features._espConn then features._espConn:Disconnect() end
        local t = 0
        features._espConn = runService.RenderStepped:Connect(function(dt)
            t += dt
            for char, obj in pairs(features._espObjects) do
                if not char or not char.Parent then _espCleanup(char) else
                    if obj.label then
                        if features._espRainbow then
                            local h = (t%1)
                            obj.label.TextColor3 = Color3.fromHSV(h,1,1)
                        else
                            obj.label.TextColor3 = Color3.fromRGB(255,255,255)
                        end
                    end
                    if obj.highlight then
                        obj.highlight.FillColor = features._espRainbow
                            and Color3.fromHSV((t%1),1,1)
                            or Color3.fromRGB(0,255,0)
                    end
                end
            end
        end)
    else
        if features._espConn then features._espConn:Disconnect() end
        if features._espWorldConn then features._espWorldConn:Disconnect() end
        for char,_ in pairs(features._espObjects) do _espCleanup(char) end
        features._espObjects = {}
    end
end
function features.ToggleSkeleton(val)  features._espSkeleton  = val end   -- Drawing desteği varsa ekleyebilirsin
function features.ToggleRainbowName(val) features._espRainbow = val end

-- ===== NoClip (FIX: restore) =====
function features.ToggleNoclip(val)
    local function setCharCollision(char, state)
        features._noclipRestore = features._noclipRestore or {}
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                if state then
                    if features._noclipRestore[part] == nil then
                        features._noclipRestore[part] = part.CanCollide
                    end
                    part.CanCollide = false
                else
                    if features._noclipRestore[part] ~= nil then
                        part.CanCollide = features._noclipRestore[part]
                    else
                        part.CanCollide = true
                    end
                end
            end
        end
    end
    if val then
        if features._noclipConn then features._noclipConn:Disconnect() end
        features._noclipConn = runService.Stepped:Connect(function()
            local char = player.Character
            if char then setCharCollision(char, true) end
        end)
    else
        if features._noclipConn then features._noclipConn:Disconnect() end
        local char = player.Character
        if char then setCharCollision(char, false) end
        features._noclipRestore = {}
    end
end

-- ===== Invisible =====
function features.ToggleInvisible(val)
    local char = player.Character or player.CharacterAdded:Wait()
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = val and 1 or 0
            if val and part:FindFirstChild("face") then part.face:Destroy() end
        end
    end
end

-- ===== Inspector (placeholder) =====
function features.ToggleInspector(val) warn(val and "Inspector On" or "Inspector Off") end

return features
