local base = "https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/"

local suc, ImGui = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/depthso/Roblox-ImGUI/main/ImGui.lua"))()
end)

if not suc or not ImGui then
    warn("❌ ImGui yüklenemedi!", ImGui)
    return
else
    print("✅ ImGui yüklendi")
end
