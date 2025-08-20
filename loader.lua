local ImGui = loadstring(game:HttpGet("https://raw.githubusercontent.com/depthso/Roblox-ImGUI/main/ImGui.lua"))()
local Features = loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features.lua"))()

-- Menü Aç/Kapa
local menuOpen = true
game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightShift then
        menuOpen = not menuOpen
    end
end)

-- Ana Menü
ImGui.SetWindowTitle("MYLF Premium Menu")
ImGui.SetTheme("Dark")

ImGui.OnRender(function()
    if not menuOpen then return end
    
    ImGui.Begin("MYLF Hub", UDim2.new(0,100,0,100), UDim2.new(0,500,0,400))

    -- === Sekmeler ===
    if ImGui.BeginTabBar("MainTabs") then
        
        -- 🎯 Aimbot
        if ImGui.BeginTab("🎯 Aimbot") then
            if ImGui.Button("Toggle Aimbot") then Features.ToggleAimbot() end
            if ImGui.Button("Toggle Silent Aim") then Features.ToggleSilentAim() end
            if ImGui.Button("Toggle NoRecoil/NoSpread") then Features.ToggleNoRecoilSpread() end
            ImGui.EndTab()
        end

        -- 👁 ESP
        if ImGui.BeginTab("👁 ESP") then
            if ImGui.Button("Toggle ESP") then Features.ToggleESP() end
            ImGui.EndTab()
        end

        -- ⚡ Movement
        if ImGui.BeginTab("⚡ Movement") then
            if ImGui.Button("Toggle Fly") then Features.ToggleFly() end
            if ImGui.Button("Toggle SpeedHack") then Features.ToggleSpeed() end
            ImGui.EndTab()
        end

        -- 🛡 Player
        if ImGui.BeginTab("🛡 Player") then
            if ImGui.Button("Toggle Godmode") then Features.ToggleGodmode() end
            ImGui.EndTab()
        end

        -- 🎨 Misc
        if ImGui.BeginTab("🎨 Misc") then
            if ImGui.Button("Toggle FOV Changer") then Features.ToggleFOV() end
            if ImGui.Button("Toggle Crosshair") then Features.ToggleCrosshair() end
            ImGui.EndTab()
        end

        ImGui.EndTabBar()
    end
    
    ImGui.End()
end)
