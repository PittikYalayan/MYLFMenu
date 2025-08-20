local base = "https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/"

-- 1. ImGui kütüphanesini çek
local ImGui = loadstring(game:HttpGet(base .. "imgui.lua"))()

-- 2. Ana pencere aç
local win = ImGui:CreateWindow({
    Title = "MYLF UI",
    Size = Vector2.new(600, 400),
    Position = UDim2.fromScale(0.3, 0.2),
})

-- 3. Sekme oluştur
local playerTab = win:CreateTab({ Name = "Player" })
local aimTab    = win:CreateTab({ Name = "Aimbot" })
local visTab    = win:CreateTab({ Name = "Visuals" })
local miscTab   = win:CreateTab({ Name = "Misc" })

-- 4. Modülleri yükle ve her sekmeye aktar
loadstring(game:HttpGet(base .. "modules/player.lua"))()(playerTab)
loadstring(game:HttpGet(base .. "modules/aimbot.lua"))()(aimTab)
loadstring(game:HttpGet(base .. "modules/visuals.lua"))()(visTab)
loadstring(game:HttpGet(base .. "modules/misc.lua"))()(miscTab)

-- 5. Menü göster
win:SetVisible(true)
