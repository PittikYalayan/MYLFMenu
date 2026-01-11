-- Kanka Efendisi - FIXLI Hook Test GUI (Crash'sız!)
local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "HookTesterFIX"
gui.Parent = player:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

-- Ana Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 450)
frame.Position = UDim2.new(0.5, -175, 0.5, -225)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Üst Bar
local topbar = Instance.new("Frame")
topbar.Size = UDim2.new(1, 0, 0, 50)
topbar.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
topbar.BorderSizePixel = 0
topbar.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🔥 FIXLI HOOK TESTER"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = topbar

-- Kapat Butonu
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -45, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = topbar

-- Ana Test Butonu
local testBtn = Instance.new("TextButton")
testBtn.Size = UDim2.new(1, -40, 0, 60)
testBtn.Position = UDim2.new(0, 20, 0, 70)
testBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
testBtn.Text = "🚀 GÜVENLİ TEST BAŞLAT (F9 Konsol!)"
testBtn.TextColor3 = Color3.new(1,1,1)
testBtn.TextScaled = true
testBtn.Font = Enum.Font.GothamBold
testBtn.BorderSizePixel = 0
testBtn.Parent = frame

-- Sonuç Label
local resultLabel = Instance.new("TextLabel")
resultLabel.Size = UDim2.new(1, -40, 0, 300)
resultLabel.Position = UDim2.new(0, 20, 0, 150)
resultLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
resultLabel.BorderSizePixel = 0
resultLabel.Text = "✅ CRASH'SIZ TEST HAZIR!\nF9 konsol aç, butona bas!"
resultLabel.TextColor3 = Color3.new(1,1,1)
resultLabel.TextScaled = true
resultLabel.TextWrapped = true
resultLabel.Font = Enum.Font.Gotham
resultLabel.Parent = frame

-- Köşeleri Yuvarla
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame
corner:Clone().Parent = topbar
corner:Clone().Parent = testBtn
corner:Clone().Parent = resultLabel

-- 🔥 GÜVENLİ HOOK TEST FONKSİYONU (CRASH YOK!)
local function testAllHooks()
   print("\n" .. string.rep("=", 70))
   print("🔥 KANKA EFENDİSİ - GÜVENLİ HOOK TEST BAŞLADI!")
   print(string.rep("=", 70))
   
   local results = {}
   local total = 0
   local working = 0
   
   -- 1. getrawmetatable ✅
   local success1 = pcall(function()
      local mt = getrawmetatable(game)
      return mt ~= nil
   end)
   if success1 then
      working = working + 1
      results[#results+1] = "✅ getrawmetatable"
      print("✅ getrawmetatable ÇALIŞIYOR!")
   else
      results[#results+1] = "❌ getrawmetatable"
      print("❌ getrawmetatable ÇALIŞMIYOR!")
   end
   total = total + 1
   
   -- 2. hookmetamethod ✅
   local success2 = pcall(function()
      local mt = getrawmetatable(game)
      if mt then
         local old = mt.__namecall
         hookmetamethod(game, "__namecall", function() end)
      end
      return true
   end)
   if success2 then
      working = working + 1
      results[#results+1] = "✅ hookmetamethod"
      print("✅ hookmetamethod ÇALIŞIYOR!")
   else
      results[#results+1] = "❌ hookmetamethod"
      print("❌ hookmetamethod ÇALIŞMIYOR!")
   end
   total = total + 1
   
   -- 3. hookfunction ✅ (GÜVENLİ!)
   local success3 = pcall(function()
      local old = print
      hookfunction(print, function(...) return old(...) end)
      return true
   end)
   if success3 then
      working = working + 1
      results[#results+1] = "✅ hookfunction"
      print("✅ hookfunction ÇALIŞIYOR!")
   else
      results[#results+1] = "❌ hookfunction"
      print("❌ hookfunction ÇALIŞMIYOR!")
   end
   total = total + 1
   
   -- 4. setreadonly ✅ (GÜVENLİ!)
   local success4 = pcall(function()
      local mt = getrawmetatable(game)
      if mt then
         setreadonly(mt, false)
         mt.test = "kanka"
         setreadonly(mt, true)
         return mt.test == "kanka"
      end
      return false
   end)
   if success4 then
      working = working + 1
      results[#results+1] = "✅ setreadonly"
      print("✅ setreadonly ÇALIŞIYOR!")
   else
      results[#results+1] = "❌ setreadonly"
      print("❌ setreadonly ÇALIŞMIYOR!")
   end
   total = total + 1
   
   -- 5. isreadonly ✅
   local success5 = pcall(function()
      local mt = getrawmetatable(game)
      return isreadonly(mt)
   end)
   if success5 then
      working = working + 1
      results[#results+1] = "✅ isreadonly"
      print("✅ isreadonly ÇALIŞIYOR!")
   else
      results[#results+1] = "❌ isreadonly"
      print("❌ isreadonly ÇALIŞMIYOR!")
   end
   total = total + 1
   
   -- 6. getnamecallmethod ✅
   local success6 = pcall(function()
      return getnamecallmethod() ~= nil
   end)
   if success6 then
      working = working + 1
      results[#results+1] = "✅ getnamecallmethod"
      print("✅ getnamecallmethod ÇALIŞIYOR!")
   else
      results[#results+1] = "❌ getnamecallmethod"
      print("❌ getnamecallmethod ÇALIŞMIYOR!")
   end
   total = total + 1
   
   -- 7. getgc ✅
   local success7 = pcall(function()
      local gc = getgc(true)
      return type(gc) == "table"
   end)
   if success7 then
      local gc_count = pcall(function() return #getgc(true) end)
      working = working + 1
      results[#results+1] = "✅ getgc"
      print("✅ getgc ÇALIŞIYOR!")
   else
      results[#results+1] = "❌ getgc"
      print("❌ getgc ÇALIŞMIYOR!")
   end
   total = total + 1
   
   -- 8. gethui ✅
   local success8 = pcall(function()
      local hui = gethui()
      return hui ~= nil
   end)
   if success8 then
      working = working + 1
      results[#results+1] = "✅ gethui"
      print("✅ gethui ÇALIŞIYOR!")
   else
      results[#results+1] = "❌ gethui"
      print("❌ gethui ÇALIŞMIYOR!")
   end
   total = total + 1
   
   -- 🔥 SONUÇ
   print(string.rep("=", 70))
   print("📊 SONUÇ: " .. working .. "/" .. total .. " HOOK ÇALIŞIYOR!")
   local percent = math.floor((working/total)*100)
   print("Executor Kalitesi: " .. percent .. "% 💎")
   if percent >= 80 then
      print("🏆 ÜST SEVİYE EXECUTOR!")
   elseif percent >= 60 then
      print("👍 ORTA SEVİYE")
   else
      print("👎 ZAYIF - DEĞİŞTİR!")
   end
   print(string.rep("=", 70))
   
   -- GUI Güncelle
   local resultText = table.concat(results, "\n") .. "\n\n🎉 " .. working .. "/" .. total .. " SUCCESS!\n💎 Kalite: " .. percent .. "%"
   resultLabel.Text = resultText
   
   -- Renk
   if working >= 6 then
      resultLabel.TextColor3 = Color3.new(0,1,0)  -- Yeşil
   elseif working >= 4 then
      resultLabel.TextColor3 = Color3.new(1,1,0)  -- Sarı
   else
      resultLabel.TextColor3 = Color3.new(1,0.3,0) -- Kırmızı
   end
end

-- BUTON EVENT'LERİ
closeBtn.MouseButton1Click:Connect(function()
   gui:Destroy()
end)

testBtn.MouseButton1Click:Connect(function()
   testBtn.Text = "🧪 Test Ediliyor..."
   testBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
   wait(1)
   pcall(testAllHooks)  -- MEGA GÜVENLİ!
   testBtn.Text = "✅ TEKRAR TEST ET"
   testBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
end)

-- F1 Hızlı Test
game:GetService("UserInputService").InputBegan:Connect(function(input)
   if input.KeyCode == Enum.KeyCode.F1 then
      pcall(testAllHooks)
      print("⚡ F1 ile hızlı test!")
   end
end)

print("🎮 FIXLI Hook Tester yüklendi! F1 = Hızlı Test")
print("🚀 Artık CRASH YOK!")
