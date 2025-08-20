-- loader.lua
-- gelişmiş arayüz, imgui.lua bağlantılı

local base = "https://raw.githubusercontent.com/MYLFHub/RobloxUI/main/"
local ImGui = loadstring(game:HttpGet(base .. "imgui.lua"))()

-- ana pencere
local win = ImGui.Window("🔥 MYLF Hub", UDim2.new(0,500,0,350), UDim2.new(0.25,0,0.25,0))
local tabs = ImGui.TabControl(win)

-- sekmeler
local tabPlayer = tabs:AddTab("👤 Player")
local tabAim    = tabs:AddTab("🎯 Aimbot")
local tabVis    = tabs:AddTab("👁 ESP / Visuals")
local tabMisc   = tabs:AddTab("⚙️ Misc")

-- === Player Sekmesi ===
ImGui.Toggle(tabPlayer, "Infinite Jump", false, function(state)
    print("Infinite Jump:", state)
end)

ImGui.Slider(tabPlayer, "WalkSpeed", 16, 200, 50, function(val)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
end)

ImGui.Slider(tabPlayer, "JumpPower", 50, 300, 100, function(val)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = val
end)

-- === Aimbot Sekmesi ===
ImGui.Toggle(tabAim, "Enable Aimbot", false, function(state)
    print("Aimbot aktif:", state)
end)

ImGui.Slider(tabAim, "Aimbot FOV", 10, 300, 100, function(val)
    print("Aimbot FOV:", val)
end)

ImGui.Slider(tabAim, "Aimbot Smooth", 1, 20, 5, function(val)
    print("Aimbot Smooth:", val)
end)

-- === Visuals Sekmesi ===
ImGui.Toggle(tabVis, "Enable ESP", false, function(state)
    print("ESP aktif:", state)
end)

ImGui.Toggle(tabVis, "Show Names", true, function(state)
    print("ESP Names:", state)
end)

ImGui.Toggle(tabVis, "Show Boxes", true, function(state)
    print("ESP Boxes:", state)
end)

-- === Misc Sekmesi ===
ImGui.Button(tabMisc, "🌀 Fly Hack", function()
    print("Fly aktif edildi")
end)

ImGui.Button(tabMisc, "💾 Save Settings", function()
    print("Ayarlar kaydedildi!")
end)

ImGui.Button(tabMisc, "❌ Close Menu", function()
    win.Parent:Destroy()
end)
