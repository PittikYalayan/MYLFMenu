local ImGui = loadstring(game:HttpGet('https://raw.githubusercontent.com/depthso/Roblox-ImGUI/main/ImGui.lua'))()
local Features = loadstring(game:HttpGet('https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features.lua'))()

-- Menü Aç/Kapa
local menuOpen = true
game:GetService("UserInputService").InputBegan:Connect(function(input,gp)
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

    -- === Sidebar ===
    if ImGui.BeginTabBar("MainTabs") then
        if ImGui.BeginTab("🎯 Aimbot") then
            if ImGui.Button("Toggle Aimbot") then
                Features.ToggleAimbot()
            end
            ImGui.EndTab()
        end
        
        if ImGui.BeginTab("👁 ESP") then
            if ImGui.Button("Toggle ESP") then
                Features.ToggleESP()
            end
            ImGui.EndTab()
        end
        
        if ImGui.BeginTab("⚡ Speed") then
            if ImGui.Button("Toggle Speed Hack") then
                Features.ToggleSpeed()
            end
            ImGui.EndTab()
        end

        -- Buraya diğer hile sekmelerini ekle (Visuals, Misc vs.)
        
        ImGui.EndTabBar()
    end
    
    ImGui.End()
end)

