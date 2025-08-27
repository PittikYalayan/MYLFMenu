--[[  ⚡ MYLF | Loader (menutheme2 tabanlı) ⚡
Kullanım:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/loader-theme2-vX.lua"))()

Notlar:
  - menü: Library -> Window -> Tab -> Section -> Controls
  - HUD tab'ında FPS/RAM label’ları canlı güncellenir.
  - İsteğe bağlı mini FPS/RAM widget (sağ üstte, draggable + rainbow bar).
  - Scanner sekmesi placeholder; sen dolduracaksın.
]]--

--== Services
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats            = game:GetService("Stats")

local LP = Players.LocalPlayer

--== 1) UI Library'yi yükle (menutheme2.lua)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/menutheme3.lua"))()

--== 2) Pencere
local Window = Library:CreateWindow({
    Title   = "⚡ MYLF | Hub ⚡",
    Sub     = "v8.3.5 style • theme2",
    Keybind = Enum.KeyCode.RightShift, -- menüyü gizle/göster
    Theme   = "Default"
})

--== 3) Sekmeler
local tabPlayer   = Window:AddTab({ Text = "PLAYER" })
local tabVisual   = Window:AddTab({ Text = "VISUALS" })
local tabHUD      = Window:AddTab({ Text = "HUD" })
local tabScanner  = Window:AddTab({ Text = "SCANNER" })
local tabSettings = Window:AddTab({ Text = "SETTINGS" })

--== 4) PLAYER
do
    local sMove = tabPlayer:AddSection("Movement")
    local tSprint = sMove:AddToggle("autoSprint", { Text = "Auto Sprint", Default = false })
    tSprint:OnChanged(function(v) print("[MYLF] AutoSprint:", v) end)

    local sStats = tabPlayer:AddSection("Player Stats")
    local slWalk = sStats:AddSlider("walkspeed", { Text = "WalkSpeed", Min = 4, Max = 32, Default = 16, Rounding = 0 })
    slWalk:OnChanged(function(v) print("[MYLF] WalkSpeed:", v) end)

    local slFOV = sStats:AddSlider("fov", { Text = "Camera FOV", Min = 60, Max = 120, Default = 80, Rounding = 0 })
    slFOV:OnChanged(function(v) print("[MYLF] FOV:", v) end)
end

--== 5) VISUALS
do
    local sTheme = tabVisual:AddSection("Theme")
    local ddTheme = sTheme:AddDropdown("theme", { Text = "Select Theme", Values = {"Default","Pink"}, Default = "Default" })
    ddTheme:OnChanged(function(v)
        if Library.UseTheme then
            Library:UseTheme(v)
        end
        print("[MYLF] Theme:", v)
    end)

    local sOverlay = tabVisual:AddSection("Overlay")
    local tOutline = sOverlay:AddToggle("outline", { Text = "Outline UI", Default = true })
    tOutline:OnChanged(function(v) print("[MYLF] Outline:", v) end)
end

--== 6) HUD  (FPS/RAM göstergesi buradan yönetiliyor)
local hudFpsLbl, hudRamLbl
do
    local sPerf = tabHUD:AddSection("Performance")
    hudFpsLbl = sPerf:AddLabel("FPS: --")
    hudRamLbl = sPerf:AddLabel("RAM: -- MB")

    local slUpdate = sPerf:AddSlider("hudUpdate", { Text = "Update Rate (ms)", Min = 100, Max = 1000, Default = 250, Rounding = 0 })
    local updateMs = 250
    slUpdate:OnChanged(function(v) updateMs = math.max(100, v) end)

    -- iç HUD label'larını düzenli güncelle
    local acc = 0
    RunService.RenderStepped:Connect(function(dt)
        acc += dt
        if acc >= (updateMs/1000) then
            local fps  = math.floor(1/math.max(dt, 1/1000) + 0.5)
            local mem  = Stats and Stats:GetTotalMemoryUsageMb() or 0
            if hudFpsLbl then
                -- Label control'ü "TextLabel" değil; bu iskelette .Text set etmek yerine yeni label basmak yerine:
                -- kolay yol: label'ı Destroy edip yeniden oluşturma yerine küçük hile → parent'ında yeni label
                -- fakat menutheme2 label kontrolü metni değiştir kancası yoksa, yeniden oluştur:
                pcall(function()
                    hudFpsLbl._root.Text = "FPS: "..tostring(fps)
                end)
            end
            if hudRamLbl then
                pcall(function()
                    hudRamLbl._root.Text = "RAM: "..tostring(math.floor(mem + 0.5)).." MB"
                end)
            end
            acc = 0
        end
    end)
end

--== 7) Mini FPS/RAM Widget (sağ-üstte, draggable + rainbow bar)
local function makeMiniStatsWidget()
    local gui = Instance.new("ScreenGui")
    gui.Name = "MYLF_MiniStats"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.Parent = LP:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame", gui)
    frame.Name = "Box"
    frame.AnchorPoint = Vector2.new(1,0)
    frame.Position = UDim2.new(1,-14,0,14)
    frame.Size = UDim2.new(0, 180, 0, 48)
    frame.BackgroundColor3 = Color3.fromRGB(28,28,32)
    frame.Active = true
    frame.Draggable = true

    do -- corner + stroke
        local c = Instance.new("UICorner", frame); c.CornerRadius = UDim.new(0,10)
        local s = Instance.new("UIStroke", frame); s.Thickness = 1; s.Transparency = 0.85
    end

    local lbl = Instance.new("TextLabel", frame)
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1,-12,1,-14)
    lbl.Position = UDim2.new(0,6,0,6)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.fromRGB(235,235,240)
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.Text = "FPS -- • RAM -- MB"

    local bar = Instance.new("Frame", frame)
    bar.AnchorPoint = Vector2.new(0.5,1)
    bar.Position = UDim2.new(0.5,0,1,-4)
    bar.Size = UDim2.new(1,-12,0,3)
    bar.BackgroundColor3 = Color3.fromRGB(255,255,255)
    local bc = Instance.new("UICorner", bar); bc.CornerRadius = UDim.new(0,2)

    local grad = Instance.new("UIGradient", bar)
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,0,0)),
        ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255,165,0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255,255,0)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,255,0)),
        ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0,255,255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(0,128,255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(200,0,255)),
    }
    grad.Offset = Vector2.new(0,0)

    -- anim + değer güncelle
    local last = 0
    RunService.RenderStepped:Connect(function(dt)
        last += dt
        grad.Offset = Vector2.new((grad.Offset.X + dt*0.5) % 1, 0)
        if last >= 0.25 then
            local fps = math.floor(1/math.max(dt, 1/1000) + 0.5)
            local mem = Stats and Stats:GetTotalMemoryUsageMb() or 0
            lbl.Text = ("FPS %d • RAM %d MB"):format(fps, math.floor(mem + 0.5))
            last = 0
        end
    end)

    return gui
end

local miniWidget = nil

do
    local sMini = tabHUD:AddSection("Mini Widget")
    local tShow = sMini:AddToggle("miniStats", { Text = "Show Mini Stats (Top-Right)", Default = true })
    tShow:OnChanged(function(v)
        if v and not miniWidget then
            miniWidget = makeMiniStatsWidget()
        elseif (not v) and miniWidget then
            miniWidget:Destroy()
            miniWidget = nil
        end
    end)
    -- başta açık:
    task.defer(function() tShow:Set(true) end)
end

--== 8) SCANNER (placeholder)
do
    local sScan = tabScanner:AddSection("Scanner")
    sScan:AddLabel("Scanner burada olacak. (Sen dolduracaksın.)")
end

--== 9) SETTINGS
do
    local sKey = tabSettings:AddSection("Keybinds")
    local kbMenu = sKey:AddKeybind("menuKey", { Text = "Menu Toggle", Default = Enum.KeyCode.RightShift })
    kbMenu:OnChanged(function(key)
        -- Library'nin SetKeybind API'si varsa kullan:
        if Window.SetKeybind then Window:SetKeybind(key) end
        print("[MYLF] Menu key:", key)
    end)
end

-- isteğe bağlı hoş geldin bildirimi
pcall(function() if Library.Notify then Library:Notify("MYLF Theme2 Loader hazır 🚀", 3) end end)
