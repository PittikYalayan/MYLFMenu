-- tek satırla kütüphaneyi çek:
local Library, ThemeManager, SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/mmenu.lua"))()

-- pencere
local Window = Library:CreateWindow({ Title = "⚡ MYLF | Hub ⚡", Center = true, AutoShow = true })

-- sekmeler
local Tabs = {
  Rage     = Window:AddTab("🔥 Rage"),
  Visuals  = Window:AddTab("👁 Visuals"),
  Player   = Window:AddTab("🕴 Player"),
  Teleport = Window:AddTab("⚡ Teleport"),
  World    = Window:AddTab("🌍 World"),
  Settings = Window:AddTab("⚙ Settings"),
}

-- örnek groupbox + kontroller
do
  local g = Tabs.Player:AddLeftGroupbox("Player Mods")
  g:AddToggle("demo_toggle", {Text="Example Toggle", Default=false}):OnChanged(function(v) print("toggle:", v) end)
  g:AddSlider("demo_speed", {Text="Speed", Min=0, Max=100, Default=50, Rounding=0}):OnChanged(function(v) print("speed:", v) end)
  g:AddDropdown("demo_preset", {Text="Preset", Values={"A","B","C"}, Default="A"}):OnChanged(function(v) print("preset:", v) end)
  g:AddInput("demo_name", {Text="Name", Placeholder="type..."}):OnChanged(function(v) print("name:", v) end)
  g:AddButton("Click Me", function() print("clicked!") end)
end

-- tema/konfig
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("MYLFHub/saves")
ThemeManager:SetFolder("MYLFHub")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

-- toggle key (Linoria stili)
Library.ToggleKeybind = Enum.KeyCode.LeftControl
