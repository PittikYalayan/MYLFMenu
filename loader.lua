-- ImGui çek


local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")

local features = {}

---------------------------------------------------------
-- SPEED
---------------------------------------------------------
local speedConn
function features.ToggleSpeed(state)
    if state then
        if speedConn then speedConn:Disconnect() end
        speedConn = runService.Heartbeat:Connect(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = 50
            end
        end)
    else
        if speedConn then speedConn:Disconnect() end
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = 16
        end
    end
end

---------------------------------------------------------
-- GODMODE
---------------------------------------------------------
local godConn
function features.ToggleGodmode(state)
    if state then
        if godConn then godConn:Disconnect() end
        godConn = runService.Heartbeat:Connect(function()
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.Health = math.huge
                char.Humanoid.MaxHealth = math.huge
            end
        end)
    else
        if godConn then godConn:Disconnect() end
    end
end

---------------------------------------------------------
-- FLY
---------------------------------------------------------
local flyConn
function features.ToggleFly(state)
    if state then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            if not hrp:FindFirstChild("BodyVelocity") then
                local bv = Instance.new("BodyVelocity", hrp)
                bv.MaxForce = Vector3.new(4000,4000,4000)
                bv.Velocity = Vector3.zero
            end
            flyConn = runService.RenderStepped:Connect(function()
                if hrp:FindFirstChild("BodyVelocity") then
                    local dir = Vector3.zero
                    local cam = workspace.CurrentCamera.CFrame
                    if uis:IsKeyDown(Enum.KeyCode.W) then dir += cam.LookVector end
                    if uis:IsKeyDown(Enum.KeyCode.S) then dir -= cam.LookVector end
                    if uis:IsKeyDown(Enum.KeyCode.A) then dir -= cam.RightVector end
                    if uis:IsKeyDown(Enum.KeyCode.D) then dir += cam.RightVector end
                    if uis:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
                    if uis:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
                    hrp.BodyVelocity.Velocity = dir * 60
                end
            end)
        end
    else
        if flyConn then flyConn:Disconnect() end
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart:FindFirstChild("BodyVelocity") then
            char.HumanoidRootPart.BodyVelocity:Destroy()
        end
    end
end

---------------------------------------------------------
-- AIMBOT / NoRecoil / NoSpread
---------------------------------------------------------
local aimConn, weaponConn
function features.ToggleAimbot(state)
    if state then
        local cam = workspace.CurrentCamera
        local function getClosestVisibleHead()
            local closest, dist = nil, math.huge
            for _, plr in pairs(game.Players:GetPlayers()) do
                if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
                    if not (player.Team and plr.Team and player.Team == plr.Team) then
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
            end
            return closest
        end
        aimConn = runService.RenderStepped:Connect(function()
            local head = getClosestVisibleHead()
            if head then cam.CFrame = CFrame.new(cam.CFrame.Position, head.Position) end
        end)
        weaponConn = runService.Heartbeat:Connect(function()
            local char = player.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    for _, v in pairs(tool:GetDescendants()) do
                        if v:IsA("NumberValue") or v:IsA("IntValue") then
                            local n = v.Name:lower()
                            if n:find("recoil") or n:find("spread") or n:find("accuracy") then
                                v.Value = 0
                            end
                        end
                    end
                end
            end
        end)
    else
        if aimConn then aimConn:Disconnect() end
        if weaponConn then weaponConn:Disconnect() end
    end
end

---------------------------------------------------------
-- TELEPORT
---------------------------------------------------------
function features.ToggleTeleport(state)
    if state then
        local mouse = player:GetMouse()
        spawn(function()
            while state do
                if uis:IsKeyDown(Enum.KeyCode.T) then
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char:MoveTo(mouse.Hit.p + Vector3.new(0,3,0))
                    end
                end
                task.wait(0.2)
            end
        end)
    end
end

---------------------------------------------------------
-- KILL AURA
---------------------------------------------------------
local auraConn
function features.ToggleKillAura(state)
    if state then
        auraConn = runService.Heartbeat:Connect(function()
            local char = player.Character
            if char and char:FindFirstChildOfClass("Tool") then
                local tool = char:FindFirstChildOfClass("Tool")
                for _, plr in pairs(game.Players:GetPlayers()) do
                    if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        if (plr.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude < 15 then
                            tool:Activate()
                        end
                    end
                end
            end
        end)
    else
        if auraConn then auraConn:Disconnect() end
    end
end

---------------------------------------------------------
-- INFINITE JUMP
---------------------------------------------------------
local infJumpConn
function features.ToggleInfiniteJump(state)
    if state then
        infJumpConn = uis.JumpRequest:Connect(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if infJumpConn then infJumpConn:Disconnect() end
    end
end

---------------------------------------------------------
-- INVISIBLE
---------------------------------------------------------
function features.ToggleInvisible(state)
    local char = player.Character or player.CharacterAdded:Wait()
    if state then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 1
                if part:FindFirstChild("face") then part.face:Destroy() end
            end
        end
    else
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 0
            end
        end
    end
end

---------------------------------------------------------
-- ESP (Highlight + Rainbow Name + Skeleton)
---------------------------------------------------------
local espConn
function features.ToggleESP(state)
    local espObjects = {}
    local Camera = workspace.CurrentCamera

    local function rainbowColor(t)
        return Color3.fromRGB(
            math.sin(t*2) * 127 + 128,
            math.sin(t*2 + 2) * 127 + 128,
            math.sin(t*2 + 4) * 127 + 128
        )
    end
    local skeletonJoints = {
        {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
        {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
        {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
        {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
        {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
    }

    if state then
        espConn = runService.RenderStepped:Connect(function(dt)
            local t = tick()
            for _, plr in pairs(game.Players:GetPlayers()) do
                if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
                    -- Highlight
                    if not espObjects[plr] then
                        espObjects[plr] = {skeleton={}}
                        local h = Instance.new("Highlight", plr.Character)
                        h.FillTransparency = 0.5
                        espObjects[plr].highlight = h

                        local bb = Instance.new("BillboardGui", plr.Character.Head)
                        bb.Size = UDim2.new(0,100,0,20)
                        bb.AlwaysOnTop = true
                        local lbl = Instance.new("TextLabel", bb)
                        lbl.Size = UDim2.new(1,0,1,0)
                        lbl.BackgroundTransparency = 1
                        lbl.Text = plr.Name
                        lbl.TextStrokeTransparency = 0
                        espObjects[plr].label = lbl

                        for _, link in pairs(skeletonJoints) do
                            local line = Drawing.new("Line")
                            line.Thickness = 2
                            table.insert(espObjects[plr].skeleton,{parts=link,line=line})
                        end
                    end
                    -- Update rainbow
                    espObjects[plr].highlight.FillColor = rainbowColor(t)
                    espObjects[plr].label.TextColor3 = rainbowColor(t)

                    for _,s in pairs(espObjects[plr].skeleton) do
                        local p1=plr.Character:FindFirstChild(s.parts[1])
                        local p2=plr.Character:FindFirstChild(s.parts[2])
                        if p1 and p2 then
                            local v1,ok1=Camera:WorldToViewportPoint(p1.Position)
                            local v2,ok2=Camera:WorldToViewportPoint(p2.Position)
                            if ok1 and ok2 then
                                s.line.From=Vector2.new(v1.X,v1.Y)
                                s.line.To=Vector2.new(v2.X,v2.Y)
                                s.line.Color=rainbowColor(t)
                                s.line.Visible=true
                            else s.line.Visible=false end
                        end
                    end
                end
            end
        end)
    else
        if espConn then espConn:Disconnect() end
        for _,objs in pairs(espObjects) do
            if objs.highlight then objs.highlight:Destroy() end
            if objs.label then objs.label.Parent:Destroy() end
            for _,s in pairs(objs.skeleton) do s.line:Remove() end
        end
        espObjects = {}
    end
end

---------------------------------------------------------
-- TOOL INSPECTOR
---------------------------------------------------------
local inspectorFrame
function features.ToggleInspector(state)
    if state then
        inspectorFrame = Instance.new("Frame", player.PlayerGui)
        inspectorFrame.Size = UDim2.new(0, 320, 0, 400)
        inspectorFrame.Position = UDim2.new(0.5,-160,0.5,-200)
        inspectorFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
        local scroll = Instance.new("ScrollingFrame", inspectorFrame)
        scroll.Size = UDim2.new(1,0,1,0)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        local layout = Instance.new("UIListLayout", scroll)
        layout.Padding=UDim.new(0,5)
        local function addRow(name,value,callback)
            local row=Instance.new("Frame",scroll)
            row.Size=UDim2.new(1,0,0,30)
            row.BackgroundColor3=Color3.fromRGB(50,50,50)
            local nameLbl=Instance.new("TextLabel",row)
            nameLbl.Size=UDim2.new(0.5,0,1,0)
            nameLbl.Text=name
            nameLbl.TextColor3=Color3.fromRGB(200,200,200)
            local box=Instance.new("TextBox",row)
            box.Size=UDim2.new(0.5,0,1,0)
            box.Position=UDim2.new(0.5,0,0,0)
            box.Text=tostring(value)
            box.FocusLost:Connect(function(enter) if enter then callback(box.Text) end end)
        end
        local function inspectTool(tool)
            for _,obj in pairs(scroll:GetChildren()) do if obj:IsA("Frame") then obj:Destroy() end end
            for _,v in pairs(tool:GetDescendants()) do
                if v:IsA("NumberValue") or v:IsA("StringValue") or v:IsA("BoolValue") or v:IsA("IntValue") then
                    addRow(v.Name,v.Value,function(newVal)
                        if tonumber(newVal) then v.Value=tonumber(newVal)
                        elseif newVal:lower()=="true" or newVal:lower()=="false" then
                            v.Value=(newVal:lower()=="true")
                        else v.Value=newVal end
                    end)
                end
            end
        end
        runService.Heartbeat:Connect(function()
            local char=player.Character
            if char then
                local tool=char:FindFirstChildOfClass("Tool")
                if tool then inspectTool(tool) end
            end
        end)
    else
        if inspectorFrame then inspectorFrame:Destroy() inspectorFrame=nil end
    end
end

---------------------------------------------------------
-- ImGui MENU
---------------------------------------------------------
ImGui.Window("⚡ MYLF Hack Menu ⚡", function()
    ImGui.Text("Movement")
    features.ToggleSpeed(ImGui.Checkbox("⚡ Speed", false))
    features.ToggleGodmode(ImGui.Checkbox("❤️ Godmode", false))
    features.ToggleFly(ImGui.Checkbox("🕊️ Fly", false))

    ImGui.Separator()
    ImGui.Text("Combat")
    features.ToggleAimbot(ImGui.Checkbox("🎯 Aimbot+NR+NS", false))
    features.ToggleKillAura(ImGui.Checkbox("⚔️ Kill Aura", false))
    features.ToggleTeleport(ImGui.Checkbox("🌀 Teleport Tool (T)", false))

    ImGui.Separator()
    ImGui.Text("Visuals")
    features.ToggleESP(ImGui.Checkbox("👀 ESP + Skeleton", false))
    features.ToggleInvisible(ImGui.Checkbox("👻 Invisible", false))

    ImGui.Separator()
    ImGui.Text("Misc")
    features.ToggleInfiniteJump(ImGui.Checkbox("☁️ Infinite Jump", false))
    features.ToggleInspector(ImGui.Checkbox("🛠 Tool Inspector", false))
end)



