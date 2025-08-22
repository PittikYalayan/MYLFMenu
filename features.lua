-- features.lua (MYLF) — scriptindeki buton mantıkları modüler hale getirildi
local runService = game:GetService("RunService")
local uis        = game:GetService("UserInputService")
local Players    = game:GetService("Players")
local player     = Players.LocalPlayer
local features   = {}

----------------------------------------------------------------
-- Helper: en yakın görünür kafa (LoS + takım kontrolü)
----------------------------------------------------------------
local function getClosestVisibleHead()
    local cam = workspace.CurrentCamera
    local closest, dist = nil, math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            -- Team check (aynı takım ise atla)
            if not (player.Team and plr.Team and player.Team == plr.Team) then
                local head = plr.Character.Head
                local headPos = head.Position

                local params = RaycastParams.new()
                params.FilterType = Enum.RaycastFilterType.Blacklist
                params.FilterDescendantsInstances = { player.Character }

                local res = workspace:Raycast(cam.CFrame.Position, (headPos - cam.CFrame.Position).Unit * 1e3, params)
                if res and res.Instance:IsDescendantOf(plr.Character) then
                    local screenPos, onScreen = cam:WorldToViewportPoint(headPos)
                    if onScreen then
                        local m = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
                        if m < dist then dist, closest = m, head end
                    end
                end
            end
        end
    end
    return closest
end

----------------------------------------------------------------
-- Speed (scriptteki 16 ↔ 50 toggle davranışı)
----------------------------------------------------------------
function features.ToggleSpeed(on)
    local function apply()
        local h = player.Character and player.Character:FindFirstChild("Humanoid")
        if h then h.WalkSpeed = on and 50 or 16 end
    end
    if on then
        if features._spdConn then features._spdConn:Disconnect() end
        features._spdConn = runService.Heartbeat:Connect(apply)
        player.CharacterAdded:Connect(function() task.wait(1); apply() end)
    else
        if features._spdConn then features._spdConn:Disconnect() end
        apply()
    end
end

----------------------------------------------------------------
-- Godmode
----------------------------------------------------------------
function features.ToggleGodmode(on)
    local function apply()
        local h = player.Character and player.Character:FindFirstChild("Humanoid")
        if h then h.Health, h.MaxHealth = math.huge, math.huge end
    end
    if on then
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

----------------------------------------------------------------
-- Fly (script: BodyVelocity; iniş tuşu çakışmasın diye LeftControl)
----------------------------------------------------------------
features._flySpeed = 60
function features.ToggleFly(on)
    local function ensureBV()
        local char = player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local bv = hrp:FindFirstChildOfClass("BodyVelocity")
        if not bv then
            bv = Instance.new("BodyVelocity", hrp)
            bv.MaxForce = Vector3.new(4000,4000,4000)
            bv.Velocity = Vector3.zero
        end
        return bv, hrp
    end

    if on then
        if features._flyConn then features._flyConn:Disconnect() end
        features._flyConn = runService.RenderStepped:Connect(function()
            local bv = ensureBV()
            if not bv then return end
            local dir = Vector3.zero
            local cam = workspace.CurrentCamera.CFrame
            if uis:IsKeyDown(Enum.KeyCode.W) then dir += cam.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.S) then dir -= cam.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.A) then dir -= cam.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.D) then dir += cam.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
            if uis:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end -- SHIFT çakışmasın
            bv.Velocity = dir * features._flySpeed
        end)
        player.CharacterAdded:Connect(function() task.wait(1); if on then features.ToggleFly(true) end end)
    else
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then local bv = hrp:FindFirstChildOfClass("BodyVelocity"); if bv then bv:Destroy() end end
        if features._flyConn then features._flyConn:Disconnect() end
    end
end

----------------------------------------------------------------
-- Infinite Jump
----------------------------------------------------------------
function features.ToggleInfiniteJump(on)
    if on then
        if features._infConn then features._infConn:Disconnect() end
        features._infConn = uis.JumpRequest:Connect(function()
            local h = player.Character and player.Character:FindFirstChild("Humanoid")
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if features._infConn then features._infConn:Disconnect(); features._infConn=nil end
    end
end

----------------------------------------------------------------
-- Teleport (T key)
----------------------------------------------------------------
function features.ToggleTeleport(on)
    local mouse = player:GetMouse()
    if on then
        if features._tpConn then features._tpConn:Disconnect() end
        features._tpConn = runService.Heartbeat:Connect(function()
            if uis:IsKeyDown(Enum.KeyCode.T) then
                local char = player.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then char:MoveTo(mouse.Hit.p + Vector3.new(0,3,0)) end
            end
        end)
    else
        if features._tpConn then features._tpConn:Disconnect(); features._tpConn=nil end
    end
end

----------------------------------------------------------------
-- Aimbot (scriptteki kamera-aim + NR/NS ayrı loop’ta)
----------------------------------------------------------------
function features.ToggleAimbot(on)
    local cam = workspace.CurrentCamera
    if on then
        if features._aimConn then features._aimConn:Disconnect() end
        features._aimConn = runService.RenderStepped:Connect(function()
            local head = getClosestVisibleHead()
            if head then cam.CFrame = CFrame.new(cam.CFrame.Position, head.Position) end
        end)
    else
        if features._aimConn then features._aimConn:Disconnect(); features._aimConn=nil end
    end
end

----------------------------------------------------------------
-- Silent Aim (scriptin __namecall mantığı)
----------------------------------------------------------------
function features.ToggleSilentAim(on)
    if on then
        if features._oldNamecall then return end
        features._silentOn = true
        features._oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = { ... }
            if features._silentOn and method == "FireServer" then
                local lname = tostring(self):lower()
                if lname:find("fire") or lname:find("shoot") then
                    local head = getClosestVisibleHead()
                    if head then
                        if typeof(args[1]) == "Vector3" then
                            args[1] = head.Position
                        elseif typeof(args[2]) == "Vector3" then
                            args[2] = head.Position
                        end
                        return features._oldNamecall(self, unpack(args))
                    end
                end
            end
            return features._oldNamecall(self, ...)
        end)
    else
        features._silentOn = false
        if features._oldNamecall then
            hookmetamethod(game, "__namecall", features._oldNamecall)
            features._oldNamecall = nil
        end
    end
end

----------------------------------------------------------------
-- Rapid Fire (cooldown/attack/reload value’larını zorla küçült)
----------------------------------------------------------------
function features.ToggleRapidFire(on)
    if on then
        if features._rofConn then features._rofConn:Disconnect() end
        features._rofConn = runService.Heartbeat:Connect(function()
            local char = player.Character
            if not char then return end
            local tool = char:FindFirstChildOfClass("Tool")
            if not tool then return end
            for _, v in ipairs(tool:GetDescendants()) do
                if v:IsA("NumberValue") or v:IsA("IntValue") then
                    local n = v.Name:lower()
                    if n:find("cooldown") or n:find("fire") or n:find("attack") or n:find("reload") or n:find("speed") then
                        v.Value = 0.05
                    end
                end
            end
        end)
    else
        if features._rofConn then features._rofConn:Disconnect(); features._rofConn=nil end
    end
end

----------------------------------------------------------------
-- Kill Aura (15 stud menzil)
----------------------------------------------------------------
function features.ToggleKillAura(on)
    if on then
        if features._auraConn then features._auraConn:Disconnect() end
        features._auraConn = runService.Heartbeat:Connect(function()
            local char = player.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            local tool = char and char:FindFirstChildOfClass("Tool")
            if not (hrp and tool) then return end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    if (plr.Character.HumanoidRootPart.Position - hrp.Position).Magnitude < 15 then
                        tool:Activate()
                    end
                end
            end
        end)
    else
        if features._auraConn then features._auraConn:Disconnect(); features._auraConn=nil end
    end
end

----------------------------------------------------------------
-- ESP (Highlight + Billboard + takım rengi + NPC + rainbow isim)
----------------------------------------------------------------
features._espObjects = {}
local function teamColor(plr)
    local my = player.Team
    if not my then return Color3.fromRGB(255,0,0) end -- deathmatch
    return (plr.Team == my) and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
end

local function espAdd(char, isNPC)
    if not char or not char.Parent then return end
    local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    if not head then return end

    local obj = features._espObjects[char]
    if not obj then obj = {}; features._espObjects[char] = obj end

    if not obj.highlight or not obj.highlight.Parent then
        local hl = Instance.new("Highlight")
        hl.FillTransparency = 0.5
        hl.OutlineColor = Color3.fromRGB(255,255,255)
        hl.Parent = char
        obj.highlight = hl
    end

    if not obj.billboard or not obj.billboard.Parent then
        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.fromOffset(120, 20)
        bb.AlwaysOnTop = true
        bb.Adornee = head
        bb.Parent = head
        local tl = Instance.new("TextLabel")
        tl.Size = UDim2.fromScale(1,1)
        tl.BackgroundTransparency = 1
        tl.TextScaled = true
        tl.Font = Enum.Font.SourceSansBold
        tl.TextStrokeTransparency = 0.3
        local pl = Players:GetPlayerFromCharacter(char)
        tl.Text = isNPC and "NPC" or (pl and pl.Name or "?")
        tl.Parent = bb
        obj.billboard, obj.label = bb, tl
    end
end

local function espCleanup(char)
    local obj = features._espObjects[char]
    if not obj then return end
    if obj.highlight then obj.highlight:Destroy() end
    if obj.billboard then obj.billboard:Destroy() end
    features._espObjects[char] = nil
end

function features.ToggleESP(on)
    if on then
        -- ilk yükleme
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character then espAdd(plr.Character, false) end
            plr.CharacterAdded:Connect(function(c) task.wait(1); if features._espOn then espAdd(c, false) end end)
        end
        -- NPC
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
                espAdd(obj, true)
            end
        end
        features._espWorldConn = workspace.ChildAdded:Connect(function(obj)
            if obj:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
                task.wait(1); if features._espOn then espAdd(obj, true) end
            end
        end)

        -- update döngüleri
        features._espOn = true
        if features._espConn then features._espConn:Disconnect() end
        local t = 0
        features._espConn = runService.RenderStepped:Connect(function(dt)
            t += dt
            for char, obj in pairs(features._espObjects) do
                if not char or not char.Parent then espCleanup(char) else
                    if obj.label then obj.label.TextColor3 = Color3.fromHSV((t%1), 1, 1) end -- rainbow
                    local pl = Players:GetPlayerFromCharacter(char)
                    if obj.highlight then
                        if pl then
                            obj.highlight.FillColor = teamColor(pl)
                        else
                            obj.highlight.FillColor = Color3.fromRGB(160,60,200) -- NPC mor
                        end
                    end
                end
            end
        end)
    else
        features._espOn = false
        if features._espConn then features._espConn:Disconnect() end
        if features._espWorldConn then features._espWorldConn:Disconnect() end
        for char,_ in pairs(features._espObjects) do espCleanup(char) end
        features._espObjects = {}
    end
end

----------------------------------------------------------------
-- Noclip (restore’lu)
----------------------------------------------------------------
function features.ToggleNoclip(on)
    local function setChar(state)
        features._noclipRestore = features._noclipRestore or {}
        local char = player.Character
        if not char then return end
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

    if on then
        if features._noclipConn then features._noclipConn:Disconnect() end
        features._noclipConn = runService.Stepped:Connect(function() setChar(true) end)
    else
        if features._noclipConn then features._noclipConn:Disconnect() end
        setChar(false)
        features._noclipRestore = {}
    end
end

----------------------------------------------------------------
-- Invisible
----------------------------------------------------------------
function features.ToggleInvisible(on)
    local char = player.Character or player.CharacterAdded:Wait()
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = on and 1 or 0
            if on and part:FindFirstChild("face") then part.face:Destroy() end
        end
    end
end

----------------------------------------------------------------
-- Tool Inspector (placeholder)
----------------------------------------------------------------
function features.ToggleInspector(on)
    warn(on and "Inspector ON" or "Inspector OFF")
end

return features
