local ImGui = loadstring(game:HttpGet('https://raw.githubusercontent.com/depthso/Roblox-ImGUI/main/ImGui.lua'))()
local Features = loadstring(game:HttpGet('https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features.lua'))()

-- Menü Aç/Kapa (RightShift)
local menuOpen = true
game:GetService("UserInputService").InputBegan:Connect(function(input,gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightShift then
        menuOpen = not menuOpen
    end
end)

-- === Ana Menü ===
ImGui.SetWindowTitle("MYLF Premium Menu")
ImGui.SetTheme("Dark")

ImGui.OnRender(function()
    if not menuOpen then return end
    
    ImGui.Begin("MYLF Hub", UDim2.new(0.2,0,0.2,0), UDim2.new(0,600,0,450))

    -- === TabBar ===
    if ImGui.BeginTabBar("MainTabs") then

        -- 🎯 Aimbot
        if ImGui.BeginTab("🎯 Aimbot") then
            ImGui.Button("Toggle Aimbot", Features.ToggleAimbot)
            ImGui.Button("Toggle Silent Aim", Features.ToggleSilentAim)
            ImGui.EndTab()
        end

        -- 👁 ESP
        if ImGui.BeginTab("👁 ESP") then
            ImGui.Button("Toggle ESP", Features.ToggleESP)
            ImGui.EndTab()
        end

        -- ⚡ Player
        if ImGui.BeginTab("⚡ Player") then
            ImGui.Button("Toggle Speed", Features.ToggleSpeed)
            ImGui.Button("Toggle Godmode", Features.ToggleGodmode)
            ImGui.Button("Toggle Fly", Features.ToggleFly)
            ImGui.Button("Toggle Infinite Jump", Features.ToggleInfiniteJump)
            ImGui.Button("Toggle Invisible", Features.ToggleInvisible)
            ImGui.EndTab()
        end

        -- 🌀 Misc
        if ImGui.BeginTab("🌀 Misc") then
            ImGui.Button("Toggle Teleport Tool (T key)", Features.ToggleTeleportTool)
            ImGui.Button("Toggle Kill Aura", Features.ToggleKillAura)
            ImGui.Button("Toggle Noclip", Features.ToggleNoclip)
            ImGui.EndTab()
        end

        ImGui.EndTabBar()
    end

    ImGui.End()
end)
